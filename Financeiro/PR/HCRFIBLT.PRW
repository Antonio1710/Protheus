#INCLUDE "TOPCONN.CH"    
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"   
#INCLUDE "RWMAKE.CH" 

/*/{Protheus.doc} User Function HCRFIBLT
	Emissao de Boleto de acordo com parametros informados
	@type  Function
	@author HCConsys
	@since Ago/2008
	@version 01
	@history chamado TI     - D-TECH              - 01/02/2010 - Migracao Protheus 10
	@history chamado TI     - Paulo               - 21/07/2011 - Alterado para imprimir o valor do saldo
	@history chamado 045459 - Sigoli              - 27/11/2018 - Alterar a conta corrente da KOBOLD de 91898-2 para 02680-2
	@history chamado 048733 - Sigoli              - 29/04/2019 - Alterar desconto de percentual para valor R$
	@history chamado 050420 - William             - ??/??/???? - || OS 051718 || FINANCAS || EDUARDO || 8352 || NOVA CONTA BRADESCO - Boleto Bradesco conta vinculada
	@history chamado 051514 - William             - ??/??/???? - || OS 052842 || FINANCAS || ANDREA || 8319 || BANCO SAFRA - Ajustado Posicao 5 linha digitavel do Safra
	@history chamado 056544 - FWNM                - 09/04/2020 - || OS 058692 || FINANCAS || WAGNER || 11940283101 || ITAU - VINCULADA
	@history chamado 056247 - Fernando Macieira   - 18/03/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history chamado 058260 - William             - 20/05/2020 - Adicionado comando de Round de 2 nos descontos de clientes
    @history chamado 056247 - FWNM                - 21/05/2020 - Error log apenas via execauto na criação do arquivo e inclusao de ZBE em diversos pontos
	@history chamado 056247 - FWNM                - 26/05/2020 - Inclusão de novos LOGZBE
	@history chamado 056247 - FWNM                - 17/06/2020 - Boleto Adiantamento impresso/gerado em PDF com data de emissao e vencimento com data do servidor
	@history chamado 059655 - FWNM                - 21/07/2020 - || OS 061193 || FINANCAS || MARILIA || 8353 || CANCELAMENTO RA
	@history chamado 059415 - FWNM                - 05/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - FKCOMMIT
	@history chamado 060193 - Everson   		  - 11/08/2020 - Alterado os dizeres de protesto.
	@history Ticket  1715   - William Costa       - 16/11/2020 - Novo boleto para a Empresa SAFEGG
	@history Ticket  T.I	- Andre Vinagre       - 02/12/2020 - IMPBOLETO() - Adicionado SM0->(GetArea())SM0->(GetArea())
	@history Ticket  7075   - Sigoli              - 06/01/2010 - Alteração da instrução de protesto
	@history Proj.PIX/LNK   - Rodrigo Mello       - 04/02/2022 - Adicionadas condicoes quando a condicao de pagamento e PIX/LNK, enviando apenas o lgo quando ocorreu erro.
	@history ticket 68450   - Fernando Macieira   - 18/02/2022 - Email em duplicidade para o cliente/vendedor
	@history TICKET: 69826  - ADRIANO SAVOINE     - 25/03/2022 - Alterado Ndevice para imprimir Spool.
/*/
User Function HCRFIBLT(aParamIXB)

	Local _cRet 			:= ""
	
	Private _cDV_NNUM   	:= SPACE(1)
	Private _cDV_SAFRA  	:= SPACE(1)                                     
	Private _cDV_BARRA  	:= SPACE(1)
	Private _RE_Campo       := SPACE(1) // CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
	Private _ccBARRA    	:= ""
	Private _cLineDig   	:= ""
	Private _cNumBoleta 	:= ""
	Private _cnDigito   	:= ""
	Private _cPedaco    	:= ""
	Private _cB_DVCam      := "" // CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17 
	Private _cNome_Bco 		:= Space(20)
	Private _cCod_Comp		:= Space(07)
	Private	_cAg_Conta  	:= Space(08)
	Private	ContaHSBC   	:= Space(08)
	Private	_cCarteira  	:= Space(02)
	Private	_cAceite    	:= Space(01)
	Private	_cB_Campo  		:= ""
	Private _cCodBarras 	:= ""
	Private cDigNNr     	:= ""
	Private n6_Dig      	:= 0
	Private n2_Dig      	:= 0
	Private n3_Dig      	:= 0
	Private n4_Dig      	:= 0
	Private n5_Dig      	:= 0
	Private n1_Dig      	:= 0
	Private nDigCB      	:= 0
	Private cVencto     	:= ""
	Private cVlrFim     	:= ""
	Private cPerg			:= "HCRFIBLT" 	// "HCRBLX"
	Private _nVlrBol   		:= 0
	Private _nVlrAbat   	:= 0
	PRIVATE oPrint			//:= TReport():New("HCRFIBLT","Emissao de Boletos",,{|oPrint|fBoletaOk()})  

	// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 23/04/2020
	Default aParamIXB := {}
	
	If IsInCallStack("u_GeraBlPV") .or. Len(aParamIXB) > 0

		// Inicializo ambiente
		rpcClearEnv()
		rpcSetType(3)
			
		If !rpcSetEnv(aParamIXB[1], aParamIXB[2],,,,,{"SM0"})
			logZBE(aParamIXB[4] + " GERABLPV - Não foi possível inicializar o ambiente, empresa/filial " + aParamIXB[1] + "/" + aParamIXB[2])  // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 26/05/2020
			ConOut( " M410STTS - GERABLPV - Não foi possível inicializar o ambiente, empresa/filial " + aParamIXB[1] + "/" + aParamIXB[2] )
			Return
		EndIf

		logZBE(aParamIXB[4] + " GERABLPV - Inicializando ambiente da empresa/filial [" + cEmpAnt + "/" + cFilAnt + "]")  // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 26/05/2020
		ConOut( " M410STTS - GERABLPV - Inicializado ambiente, empresa/filial/PV " + cEmpAnt + "/" + cFilAnt + " - " + aParamIXB[4] )
		PtInternal( 1, " M410STTS - GERABLPV - Inicializando ambiente da empresa/filial [" + cEmpAnt + "/" + cFilAnt + "]")

		Pergunte (cPerg, .F.) 
		ConOut( " CPERG " + CPERG )

		MV_PAR01 := ""
		MV_PAR02 := "z"
		MV_PAR03 := aParamIXB[3]
		MV_PAR04 := aParamIXB[3]
		MV_PAR05 := aParamIXB[4]
		MV_PAR06 := aParamIXB[4]
		MV_PAR07 := aParamIXB[5]
		MV_PAR08 := aParamIXB[5]
		MV_PAR09 := ""
		MV_PAR10 := ""
		MV_PAR11 := aParamIXB[6]
		MV_PAR12 := aParamIXB[6]

	//	aParamJob := { cEmpAnt, cFilAnt, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_EMISSAO, SE1->E1_NUMBCO, SA1->A1_EMAIL, SA3->A3_EMAIL, "JOB", .T. }
		ConOut( " M410STTS - GERABLPV - Carregou MVs ambiente, empresa/filial/PV " + cEmpAnt + "/" + cFilAnt + " - " + aParamIXB[4] )
		CONOUT(" MV_PAR03 " + MV_PAR03 )
		CONOUT(" MV_PAR04 " + MV_PAR04 )
		CONOUT(" MV_PAR05 " + MV_PAR05 )
		CONOUT(" MV_PAR06 " + MV_PAR06 )

		// Posiciono tabelas
		SC5->( dbSetOrder(1) ) // C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_
		SC5->( dbSeek(FWxFilial("SC5")+aParamIXB[4]) )
		
		SA1->( dbSetOrder(1) ) // A1_FILIAL+A1_COD+A1_LOJA
		SA1->( dbSeek(FWxFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)) )

		SA3->( dbSetOrder(1) ) // A3_FILIAL, A3_COD, R_E_C_N_O_, D_E_L_E_T_
		SA3->( dbSeek(FWxFilial("SA3")+SC5->C5_VEND1) )

		FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
		FIE->( dbSeek(SC5->C5_FILIAL+"R"+SC5->C5_NUM) )

		SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
		SE1->( dbSeek(FWxFilial("SE1")+FIE->(FIE_PREFIX+FIE_NUM+FIE_PARCEL+FIE_TIPO)) )

		CONOUT(" TABELAS POSICIONADAS SC5 " + SC5->C5_NUM )
		CONOUT(" TABELAS POSICIONADAS SA1 " + SA1->A1_COD )
		CONOUT(" TABELAS POSICIONADAS FIE " + FIE->FIE_PEDIDO )
		CONOUT(" TABELAS POSICIONADAS SE1 " + SE1->E1_NUM )

		logZBE(SC5->C5_NUM + " GERABLPV - Tabelas posicionadas - SC5 " + SC5->C5_NUM + " SA1 " + SA1->A1_COD + " FIE " + FIE->FIE_PEDIDO + " SE1 " + SE1->E1_NUM)  // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 26/05/2020		

	Else	
	
		If IsInCallStack("u_RunHCRFB")

			Pergunte (cPerg, .F.) 

			MV_PAR01 := ""
			MV_PAR02 := "z"
			MV_PAR03 := SE1->E1_PREFIXO
			MV_PAR04 := SE1->E1_PREFIXO
			MV_PAR05 := SE1->E1_NUM
			MV_PAR06 := SE1->E1_PREFIXO
			MV_PAR07 := SE1->E1_EMISSAO
			MV_PAR08 := SE1->E1_EMISSAO
			MV_PAR09 := ""
			MV_PAR10 := ""
			MV_PAR11 := SE1->E1_NUMBCO
			MV_PAR12 := SE1->E1_NUMBCO

		Else

			If !Pergunte(cPerg, .T.)
				
				ValidPerg()
				lOpcA := pergunte (cPerg, .T.)
				
				If lOpcA == .F.
					Return
				EndIf
				
			EndIf

		EndIf

	EndIf                                                                     

	oPrint:= TReport():New("HCRFIBLT","Emissao de Boletos",,{|oPrint|fBoletaOk(aParamIXB)})  
	oPrint:lHeaderVisible 	:= .F.

	If IsInCallStack("u_GeraRAPV") .or. IsInCallStack("u_GeraBlPV") .or. Len(aParamIXB) > 0

		logZBE(SE1->E1_NUM + " esta na funcao HCRFIBLT gerando boleto em PDF e enviando email") // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 21/05/2020

		oPrint:nRemoteType := NO_REMOTE        // FORMA DE GERAÇÃO DO RELATÓRIO
		oPrint:nDevice     := 8 				//8 ENVIO DE .PDF VIA E-MAIL

		oPrint:oPage:nPaperSize 	:= 22	

		cCpOcul            := GetMV("MV_#WSMATI",,"fernando.sigoli@adoro.com.br")
		oPrint:cEmail      := AllTrim(aParamIXB[7]) + ";" + AllTrim(aParamIXB[8]) + ";" + cCpOcul
		//oPrint:cEmail      := "fwnmacieira@gmail.com;fernando.macieira@piocom.com.br;fernando.sigoli@adoro.com.br" // debug

		cNomArq := "BOLETO_PV_"+AllTrim(SE1->E1_NUM)+"_"+StrTran(Time(),":","")
		oPrint:SetReportPortal(cNomArq) // DEFINE O NOME DO RELATÓRIO

		oPrint:Print()

		ConOut( " M410STTS - GERABLPV - Gerou boleto PDF, empresa/filial/PV " + cEmpAnt + "/" + cFilAnt + " - APARAMIXB[4] " + aParamIXB[4] + "SE1->E1_NUM " + SE1->E1_NUM)

		// Gravo flag no PV registrando que o boleto foi enviado para não ser reprocessado pela rotina JOB ADFIN087P 
		RecLock("SC5", .F.)
			SC5->C5_XWSBOLG := "S"
		SC5->( msUnLock() )
		SC5->( fkCommit() ) // chamado 059415 - FWNM                - 05/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - FKCOMMIT

		logZBE(SC5->C5_NUM + " gravou C5_XWSBOLG = 'S'")  // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 21/05/2020

	Else
		
		oPrint:oPage:nPaperSize 	:= 9	//// Definido tamanho do Papel Default: 	A4
		oPrint:nDevice				:= 2	//// Definido Impressao Default: 			1= ARQUIVO  / 2=SPOOL   
		// TICKET: 69826 - ADRIANO SAVOINE - 25/03/2022
		oPrint:PrintDialog()
	
	EndIf
	
Return()

/* Funcao para emissao de boletos selecionados */
Static Function fBoletaOK(aParamIXB)

	Local lBcoOk			:= .T.
	Local cAliasT01			:= GetNextAlias()  
	
	PRIVATE oFont1 		:= TFont():New("Arial"      	,09,08,,.F.,,,,,.F.) // Titulos dos Campos
	PRIVATE oFont1A		:= TFont():New("Arial"      	,09,08,,.F.,,,,,.F.) // Titulos dos Campos
	PRIVATE oFontA		:= TFont():New("Arial"      	,09,11,,.T.,,,,,.F.) // Nome do Banco
	PRIVATE oFont2 		:= TFont():New("Arial"      	,09,10,,.F.,,,,,.F.) // Conteudo dos Campos
	PRIVATE oFont3Bold 	:= TFont():New("Arial Black"	,09,18,,.T.,,,,,.F.) // Nome do Banco
	PRIVATE oFont4Bold 	:= TFont():New("Arial Black"	,09,13,,.T.,,,,,.F.) // Nome do Banco
	PRIVATE oFont4 		:= TFont():New("Arial"      	,09,12,,.T.,,,,,.F.) // Dados do Recibo de Entrega
	PRIVATE oFont5 		:= TFont():New("Arial"      	,09,18,,.T.,,,,,.F.) // Codigo de Compensação do Banco
	PRIVATE oFont6 		:= TFont():New("Arial"          ,09,14,,.T.,,,,,.F.) // Codigo de Compensação do Banco
	PRIVATE oFont7 		:= TFont():New("Arial"          ,09,10,,.F.,,,,,.F.) // Conteudo dos Campos em Negrito
	PRIVATE oFont8 		:= TFont():New("Arial"          ,09,09,,.F.,,,,,.F.) // Dados do Cliente
	PRIVATE oFont9 		:= TFont():New("Times New Roman",09,15,,.T.,,,,,.F.) // Linha Digitavel
	PRIVATE oFont10Bold	:= TFont():New("Times New Roman",09,18,,.T.,,,,,.F.) // Nome banco HSBC - critica 270509
	PRIVATE oFont8Bold := TFont():New("Arial"          ,09,14,,.T.,,,,,.F.) // MENSAGEM QDO FOR GMSBS
	
	Private cE1PORTADO 	:= CriaVar("A6_COD",.F.)
	Private cE1AGEDEP 	:= CriaVar("A6_AGENCIA",.F.)
	Private cE1CONTA 	:= CriaVar("A6_NUMCON",.F.)
	Private cTipoBanco := Space(01)	// Controle Bradesco/Banco ABC
	
	Private _lImprime	:= .t.

	Default aParamIXB := {}
	
	// Paulo  - 21/07/2011 - TDS - Aqui havia redundência do campo E1_VALLIQ. No caso em questão, este campo fo retirado
	// e incluido o campo E1_SALDO
	cQuery := " SELECT SE1.E1_FILIAL ,SE1.E1_ROTEIRO,SE1.E1_PREFIXO,SE1.E1_NUM ,SE1.E1_PORTADO,SE1.E1_NUMBCO  ,SE1.E1_AGEDEP,SE1.E1_CONTA , "
	cQuery += "        SE1.E1_DVNBCO ,SE1.E1_VALOR  ,SE1.E1_ISS    ,SE1.E1_INSS,SE1.E1_CSLL   ,SE1.E1_COFINS  ,SE1.E1_PIS   ,SE1.E1_VENCTO, "
	cQuery += "        SE1.E1_SALDO  ,SE1.E1_EMISSAO,SE1.E1_PARCELA,SA1.A1_COD ,SA1.A1_LOJA   ,SA1.A1_NOME    ,SA1.A1_CGC   ,SA1.A1_ENDCOB, "
	cQuery += "        SA1.A1_BAIRROC,SA1.A1_CEPC   ,SA1.A1_MUNC   ,SA1.A1_ESTC,SE1.E1_BANCO  ,SA1.A1_ZZDESCB ,SE1.E1_TIPO "
	cQuery += " FROM " + RETSQLNAME("SE1") + " SE1 "
	cQuery += " INNER JOIN " + RETSQLNAME("SA1") + " SA1 ON "
	cQuery += "       SE1.E1_CLIENTE 	= SA1.A1_COD 	AND "
	cQuery += "       SE1.E1_LOJA		= SA1.A1_LOJA 	AND "
	cQuery += "       SA1.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SE1.E1_FILIAL 	= '" + xFilial("SE1") 			+ "' AND "
	cQuery += "       SE1.E1_ROTEIRO 	>= '" 	+  MV_PAR01 		+ "' AND SE1.E1_ROTEIRO 	<= '" 		+  MV_PAR02 		+ "' AND "
	cQuery += "       SE1.E1_PREFIXO 	>= '" 	+  MV_PAR03 		+ "' AND SE1.E1_PREFIXO 	<= '" 		+  MV_PAR04 		+ "' AND "
	cQuery += "       SE1.E1_NUM 		>= '"  	+  MV_PAR05 		+ "' AND SE1.E1_NUM 		<=	'" 		+  MV_PAR06 		+ "' AND "
	cQuery += "       SE1.E1_EMISSAO 	>= '"  	+  Dtos(MV_PAR07) 	+ "' AND SE1.E1_EMISSAO 	<=	'" 		+  Dtos(MV_PAR08) 	+ "' AND "
	cQuery += "       SE1.E1_TIPO       <> 'AB-' AND " //chamado 027642, alterado para não carregar o AB- William Costa
	cQuery += "       SE1.D_E_L_E_T_ 	= ' ' AND  SE1.E1_BANCO <> '' " 	// Habilitar aqui na Adoro
	cQuery += "ORDER BY SE1.E1_ROTEIRO,SE1.E1_PREFIXO,SE1.E1_NUM,SE1.E1_PARCELA"
	
	If Select("TSE1A") > 0
		TSE1A->(dbCloseArea())
	Endif

	TcQuery cQuery New Alias "TSE1A"

	TSE1A->(dbGoTop())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Abertura de tabelas e posicionamento de indices  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA6")
	SA6->(dbSetOrder(1))	//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
	dbSelectArea("SE1")
	SE1->(dbSetOrder(1))	//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	dbSelectArea("SEE")
	SEE->(dbSetOrder(1))	//EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
	dbSelectArea("SF2")
	SF2->(dbSetOrder(1))	//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	dbSelectArea("SE4")
	SE4->(dbSetorder(1))	//E4_FILIAL+E4_CODIGO
	Do While !TSE1A->(Eof())
		If !Empty(TSE1A->E1_NUMBCO)                                      
			cQuery := "SELECT A6_COD, A6_AGENCIA, A6_NUMCON, (R_E_C_N_O_) NUMREG "
			cQuery += "FROM " + RetSQLName("SA6") + "  "
	      	cQuery += "WHERE D_E_L_E_T_ = ' ' AND A6_FILIAL = '" + XFILIAL("SA6") + "' "
	      	cQuery += "AND A6_COD = '" + TSE1A->E1_BANCO + "' AND A6_ZZBLT = 'S' "
	      	dbUseArea(.T.,__cRDD,TcGenQry(,,ChangeQuery(cQuery)),cAliasT01,.T.,.F.)
	      	(cAliasT01)->(dbGoTop())
	      	//Ajustar o dicionario de dados
	      	U_AjustaTC(cAliasT01,SA6->(dbStruct()))
	      	If !(cAliasT01)->(Eof())
				cE1PORTADO 	:= (cAliasT01)->A6_COD
				cE1AGEDEP 	:= (cAliasT01)->A6_AGENCIA
				cE1CONTA 	:= (cAliasT01)->A6_NUMCON
				//Posicionar a SA6 para referencias posteriores
				SA6->(dbGoTo(GetDToVal(AllToChar((cAliasT01)->NUMREG))))
				If SA6->(Eof())
					lBcoOk := !lBcoOk
				Endif
		   	Else
		   		lBcoOk := !lBcoOk
		   	Endif
		   	U_FecArTMP(cAliasT01)
			If !lBcoOk
				TSE1A->(dbSkip())
				Loop
			Endif	   
		Else
			TSE1A->(dbSkip())
			Loop
		Endif
		
		SEE->(dbSeek(xFilial("SEE") + cE1PORTADO + cE1AGEDEP + cE1CONTA))
		cAuxNNr			:= Alltrim(TSE1A->E1_NUMBCO)
		cNossoNr		:= "00/"+Alltrim(TSE1A->E1_NUMBCO)+"-"+Alltrim(TSE1A->E1_DVNBCO)
		cDigNNr   		:= Val(AllTrim(TSE1A->E1_DVNBCO))
		_cDV_NNUM 		:= AllTrim(TSE1A->E1_DVNBCO) 
		_cNumBoleta		:= Alltrim(TSE1A->E1_NUMBCO)
		_nSeqParcela	:= LocParcela()
	
		oPrint:StartPage()
	
		// Calculos a serem impressos na boleta e gravados no SE1
		Do Case
			// Atenção: Acrescentar aqui os codigos dos demais bancos
			Case cE1PORTADO == "001"
				_cNome_Bco := "Banco do Brasil"
				_cCod_Comp := "|001-9|"
				_cAg_Conta := Substr(SA6->A6_AGENCIA,1,4)+"-"+Substr(SA6->A6_AGENCIA,5,1)+"/"+Substr(SA6->A6_NUMCON,1,5)+"-"+Substr(SA6->A6_NUMCON,7,1)
				_cCarteira := "17/027"          //Renato,alterado de 17/019 p/ 17/027 em 26/10/2011
				_cAceite   := "N"
			//Case cE1PORTADO $ "422/SAF"               //ALEX BORGES 03/04/12
			Case cE1PORTADO $ "SAF"   					// fernando sigoli 29/10/2017 Chamado: 036517
				_cNome_Bco := "BRADESCO"
				_cCod_Comp := "|237-2|"
				_cAg_Conta := "3114-3/0176300-8"
				_cCarteira := "09"
				_cAceite   := "N"				 
			
			Case cE1PORTADO $ "422"            // fernando sigoli 29/10/2017 Chamado: 036517        
				
				_cNome_Bco := "BANCO SAFRA S.A"
				_cCod_Comp := "|422-7|"
				_cAg_Conta := Substr(SA6->A6_AGENCIA,1,4)+"-"+Alltrim(SA6->A6_DVAGE)+"/"+Substr(SA6->A6_NUMCON,1,6)+"-"+Alltrim(SA6->A6_DVCTA)
				_cCarteira := "01"
				_cAceite   := "N"				
			          
			Case cE1PORTADO $ "SFF"            // fernando sigoli 29/10/2017 Chamado: 036517        
				
				_cNome_Bco := "BANCO SAFRA S.A"
				_cCod_Comp := "|422-7|"
				_cAg_Conta := Substr(SA6->A6_AGENCIA,1,4)+"-"+Alltrim(SA6->A6_DVAGE)+"/"+Substr(SA6->A6_NUMCON,1,6)+"-"+Alltrim(SA6->A6_DVCTA)
				_cCarteira := "02"
				_cAceite   := "N"				
			
			
			Case cE1PORTADO $ "237/RED/BRD"	// Bradesco / RED FACTOR
				
				_cNome_Bco := "BRADESCO"
				_cCod_Comp := "|237-2|"
				If cE1PORTADO = "RED"
					_cAg_Conta := Substr(SA6->A6_AGENCIA,2,4)+"-"+SA6->A6_DVAGE+"/"+Substr(SA6->A6_NUMCON,4,6)+"-"+SA6->A6_DVCTA
				Else
					_cAg_Conta := Substr(SA6->A6_AGENCIA,1,4)+"-"+Substr(SA6->A6_AGENCIA,5,1)+"/0"+Substr(SA6->A6_NUMCON,1,6)+"-"+Substr(SA6->A6_NUMCON,8,1)
				EndIf
				
				// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 01/04/2020
				If !Empty(SE1->E1_XWSBRAC)
					_cCarteira := GetMV("MV_#WSCART",,"04")
				Else
					_cCarteira := "09"
				EndIf
				//
				//_cCarteira := "09"
				_cAceite   := "N"
				
			// *** INICIO CHAMADO 050420	
			Case cE1PORTADO == "BRV"	
				_cNome_Bco := "BRADESCO"
				_cCod_Comp := "|237-2|"
				_cAg_Conta := ALLTRIM(SA6->A6_AGENCIA)+"-"+Alltrim(SA6->A6_DVAGE)+"/"+ALLTRIM(SA6->A6_NUMCON)+"-"+Alltrim(SA6->A6_DVCTA)
				_cCarteira := "02"
				_cAceite   := "N"	
			// *** FINAL CHAMADO 050420
			
			Case cE1PORTADO == "246"	// ABC
				_cNome_Bco := "BRADESCO"
				_cCod_Comp := "|237-2|"
				_cAg_Conta := Substr(SA6->A6_AGENCIA,1,4)+"-"+Substr(SA6->A6_AGENCIA,5,1)+"/0"+Substr(SA6->A6_NUMCON,1,6)+"-"+Substr(SA6->A6_NUMCON,8,1)
				_cCarteira := "009"
				_cAceite   := "N"
			
			Case cE1PORTADO = "399"	// HSBC
				_cNome_Bco := "HSBC"
				_cCod_Comp := "|399-9|"
				_cAg_Conta := Substr(SA6->A6_AGENCIA,1,4)+"-"+Substr(SA6->A6_AGENCIA,1,4)+Substr(SA6->A6_NUMCON,1,7)	
				ContaHSBC  := Substr(SA6->A6_AGENCIA,1,4)+"/"+Substr(SA6->A6_NUMCON,1,5)+"-"+Substr(SA6->A6_NUMCON,6,2)	// Somente na impressao
				_cCarteira := "CSB"
				_cAceite   := "N"          
			
			Case cE1PORTADO == "033"	// SANTANDER
				_cNome_Bco := "SANTANDER"
				_cCod_Comp := "|033-7|"
				_cAg_Conta := Substr(SA6->A6_AGENCIA,1,4)+"/" + "1809571"	// Alterado em 09/07/09
				_cCarteira := "101"
				_cAceite   := "N"
			
			Case cE1PORTADO $ "KOB"	// KOB
				_cNome_Bco := "Banco Itaú SA"
				_cCod_Comp := "|341-7|"
				//_cAg_Conta := "2001" + "/" + "91898"+"-"+"2" //chamado:045459 27/11/2018
				_cAg_Conta := "2001" + "/" + "02680"+"-"+"2" 
				_cCarteira := "109"
				_cAceite   := "A" 			
			
			Case cE1PORTADO $ "341/655/ITV"	// ITAU
				_cNome_Bco := "Banco Itaú SA"
				_cCod_Comp := "|341-7|"
				_cAg_Conta := SUBSTR(SA6->A6_AGENCIA,1,4) + "/" + SUBSTR(SA6->A6_NUMCON,1,5)+"-"+IIF(ALLTRIM(SA6->A6_DVCTA) == '',SUBSTR(SA6->A6_NUMCON,Len(Alltrim(SA6->A6_NUMCON)),1),SA6->A6_DVCTA)
				_cCarteira := "109"
				_cAceite   := "A" 
			
			Case cE1PORTADO = "637"	// SOFISA
				_cNome_Bco := "HSBC"
				_cCod_Comp := "|399-9|"
				_cAg_Conta  := Substr(SA6->A6_AGENCIA,1,4)+"/"+Substr(SA6->A6_NUMCON,1,5)+"-"+Substr(SA6->A6_NUMCON,6,2)	// Somente na impressao
				_cCarteira := "CSB"
				_cAceite   := "N"       
			
			Case cE1PORTADO = "104"	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
				_cNome_Bco := "CX EC.FEDERAL"
				_cCod_Comp := "|104-0|"
				_cAg_Conta := Substr(SA6->A6_AGENCIA,1,4)+" / "+Posicione("SEE",1,xFilial("SEE")+cE1PORTADO+cE1AGEDEP+cE1CONTA,"EE_CODEMP") 	// Somente na impressao
				_cCarteira := "14"
				_cAceite   := "N" 
				//SEE->(dbSeek(xFilial("SEE") + cE1PORTADO + cE1AGEDEP + cE1CONTA))
		EndCase
		
		SF2->(dbSeek(xFilial("SF2") + TSE1A->E1_NUM + "1"))
		SE4->(dbSeek(xFilial("SE4") + SF2->F2_COND))
	
		// Calculo do fator de Vencimento para atender ao Banco do Brasil
		If IsInCallStack("u_GeraRAPV") .or. IsInCallStack("u_GeraBlPV") .or. Len(aParamIXB) > 0 .or. IsInCallStack("u_RunHCRFB")
			_cFatorVcto := Str((msDate() - CtoD("07/10/1997")),4) // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 17/06/2020
		Else
			_cFatorVcto := Str((StoD(TSE1A->E1_VENCTO) - CtoD("07/10/1997")),4)
		EndIf
	
		// Paulo (Ghost Rider) - 21/07/2011 - Aqui foi alterado para impressão do titulo com o valor do SALDO restante
		_nVlrBol  := TSE1A->E1_SALDO //TSE1A->E1_VALOR - TSE1A->E1_ISS - TSE1A->E1_INSS - TSE1A->E1_CSLL - TSE1A->E1_COFINS - TSE1A->E1_PIS - TSE1A->E1_VALLIQ
		_nVlrAbat := 0               //TSE1A->E1_VALLIQ - Paulo - TDS - 22/06/2011
				
		// Montagem do Codigo de Barras da Boleta
		Do Case
			
			Case cE1PORTADO == "001" // Banco do Brasil
			    //Codigo convenio 7 posições - Mauricio 21/10/11.
				// Calculo do Codigo de Barras
				_cB_Campo 	:= "001" 												// 03 posicoes   B
				_cB_Campo 	+= "9" 													// 01
				_cB_Campo 	+= _cFatorVcto											// 04 posicoes 
				_cB_Campo 	+= StrZero(Int(Round(_nVlrBol*100,2)),10)   	        // 10 posicoes
				_cB_Campo   += "000000"                                             // Zeros 6 posições
				_cB_Campo   += Alltrim(_cNumboleta)+"17"                            //Nosso numero 17 posições(CONVENIO+SEQUENCIAL)+ 02 posições Carteira
				//_cB_Campo 	+= Alltrim(_cNumboleta) + Substr(cE1AGEDEP,1,4)+StrZero(Val(SubStr(cE1CONTA,1,5)),8)+"17" 
	
				BarraDV()
	
				_cCodBarras := cE1PORTADO  + "9" + _cDV_BARRA + _cFatorVcto
				_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10)
				_cCodBarras += "000000"
				_cCodBarras += Alltrim(_cNumboleta) + "17"
				//_cCodBarras += Alltrim(_cNumboleta) + Substr(cE1AGEDEP,1,4)+StrZero(Val(SubStr(cE1CONTA,1,5)),8)+"17" 
		  
			//Case cE1PORTADO $ "422/SAF" // Banco Safra         //ALEX BORGES 03/04/12
			Case cE1PORTADO $ "SAF" // Banco Safra			// fernando sigoli 29/10/2017 Chamado: 036517
			
				_cB_Campo := "237"  + "9" 
				_cB_Campo += _cFatorVcto + StrZero(Int(Round(_nVlrBol*100,2)),10)
				_cB_Campo += "3114" + SUBSTR(_cCarteira,1,2) + RIGHT(DTOC(DDATABASE),2) + SUBSTR(ALLTRIM(_cNumboleta),1,8)+_cDV_NNUM+"01763000"  			
				
				
				// Calculo do Digito do Codigo de Barras
				BarraDV()
				
				//Compor a barra com o Digito verificador
				_cCodBarras := "237"  + "9" + _cDV_BARRA
				_cCodBarras += _cFatorVcto + StrZero(Int(Round(_nVlrBol*100,2)),10)
				_cCodBarras += "3114" + SUBSTR(_cCarteira,1,2) + RIGHT(DTOC(DDATABASE),2) + SUBSTR(ALLTRIM(_cNumboleta),1,8)+_cDV_NNUM+"01763000"
			
			Case cE1PORTADO $ "422/SFF" // Banco Safra         // fernando sigoli 29/10/2017 Chamado: 036517
				
				_cB_Campo := "422" + "9" + "7"           								//posição 01 a 05 -- 422 9 7
				_cB_Campo += Substr(SA6->A6_AGENCIA,1,4) 								//posição 06 a 09 -- 0100
				_cB_Campo += Substr(_cAg_Conta,06,01)                  					//posição 11 a 11 -- 1
				_cB_Campo += padl(Substr(_cAg_Conta,8,6),8,"0")+Substr(_cAg_Conta,15,1) //posição 12 a 20 -- Codigo cliente
				_cB_Campo += SUBSTR(ALLTRIM(_cNumboleta),1,8)+_cDV_NNUM 				//posição 22 a 30 -- Nosso Numero
				_cB_Campo += '2'                         								//posição 31 a 31 -- Tipo de Cobranca (fixo 2)
				_cB_Campo += _cFatorVcto                   								//posição 34 a 37 -- Data Vencimento do Boleto
				_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10)  					//posição 38 a 47 -- Valor do Boleto
				
				//Calculo do Digito do Codigo de Barras
				//Compor a barra com o Digito verificador
				_cCodBarras  := Substr(_cB_Campo,1,4)+_cFatorVcto
				_cCodBarras  += StrZero(Int(Round(_nVlrBol*100,2)),10)+'7'
				_cCodBarras  += Substr(_cB_Campo,6,5)+Substr(_cB_Campo,11,9)
				_cCodBarras  += Alltrim(_cNumboleta)+_cDV_NNUM+"2"
				
			   	u_DgVerECF(_cCodBarras)
				
				_cCodBarras := Substr(_cCodBarras,1,4)+_cB_DVCam+Substr(_cCodBarras,5,40)
				
			Case cE1PORTADO $ "237/RED/BRD" // Bradesco 
				
				_cB_Campo := "237"  + "9" + _cFatorVcto
				_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10)
				_cB_Campo += Substr(SA6->A6_AGENCIA,1,4)+_cCarteira+Alltrim(_cNumboleta) +StrZero(Val(Substr(SA6->A6_NUMCON,1,6)),7) +"0" // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 01/04/2020
				//_cB_Campo += Substr(SA6->A6_AGENCIA,1,4)+"09"+Alltrim(_cNumboleta) +StrZero(Val(Substr(SA6->A6_NUMCON,1,6)),7) +"0"

				// Calculo do Digito do Codigo de Barras
				BarraDV()
				
				//Compor a barra com o Digito verificador
				_cCodBarras := "237"  + "9" + _cDV_BARRA + _cFatorVcto
				_cCodBarras := _cCodBarras + StrZero(Int(Round(_nVlrBol*100,2)),10)
				_cCodBarras := _cCodBarras + Substr(SA6->A6_AGENCIA,1,4)+_cCarteira+Alltrim(_cNumboleta) +"0"+Substr(SA6->A6_NUMCON,1,6) + "0" // +Substr(SA6->A6_NUMCON,8,1) //+"0" // 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 01/04/2020
				//_cCodBarras := _cCodBarras + Substr(SA6->A6_AGENCIA,1,4)+"09"+Alltrim(_cNumboleta) +"0"+Substr(SA6->A6_NUMCON,1,6) + "0" // +Substr(SA6->A6_NUMCON,8,1) //+"0" // 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 01/04/2020
				//_cCodBarras := _cCodBarras + Substr(SA6->A6_AGENCIA,1,4)+"09"+_cNumboleta +Substr(SA6->A6_NUMCON,2,7) +"0" 
			
			// *** INICIO CHAMADO 050420	
			Case cE1PORTADO $ "BRV" // Bradesco 
				
				_cB_Campo := "237"  + "9" + _cFatorVcto
				_cB_Campo := _cB_Campo + StrZero(Int(Round(_nVlrBol*100,2)),10)
				_cB_Campo := _cB_Campo + ALLTRIM(SA6->A6_AGENCIA)+"02"+Alltrim(_cNumboleta) +ALLTRIM(SA6->A6_NUMCON)+"0" 
		
				BarraDV()
		
				_cCodBarras := "237"  + "9" + _cDV_BARRA + _cFatorVcto
				_cCodBarras := _cCodBarras + StrZero(Int(Round(_nVlrBol*100,2)),10)
				_cCodBarras := _cCodBarras + ALLTRIM(SA6->A6_AGENCIA)+"02"+Alltrim(_cNumboleta) +ALLTRIM(SA6->A6_NUMCON)+"0"
		
				// *** FINAL CHAMADO 050420
			
			Case cE1PORTADO == "246" // ABC
				
				_cB_Campo := "237"  + "9" + _cFatorVcto
				_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10)
				_cB_Campo += Substr(SA6->A6_AGENCIA,1,4)+"09"+Alltrim(_cNumboleta) +StrZero(Val(Substr(SA6->A6_NUMCON,1,6)),7) +"0"
				
				// Calculo do Digito do Codigo de Barras
				BarraDV()
				
				//Compor a barra com o Digito verificador
				_cCodBarras := "237"  + "9" + _cDV_BARRA + _cFatorVcto
				_cCodBarras := _cCodBarras + StrZero(Int(Round(_nVlrBol*100,2)),10)
				_cCodBarras := _cCodBarras + Substr(SA6->A6_AGENCIA,1,4)+"09"+Alltrim(_cNumboleta) +"0"+Substr(SA6->A6_NUMCON,1,6) + "0" // +Substr(SA6->A6_NUMCON,8,1) //+"0" 
			
			Case cE1PORTADO == "399" // HSBC
	
				_cB_Campo := "399"  + "9" + _cFatorVcto
				_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10) + Alltrim(_cNumboleta) + _cDV_NNUM
				_cB_Campo += Substr(SA6->A6_AGENCIA,1,4)+Substr(SA6->A6_NUMCON,1,7) +"00"+"1"	
	
				BarraDV()
				
				_cCodBarras := "399"  + "9" + _cDV_BARRA + _cFatorVcto
				_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10) + Alltrim(_cNumboleta) + _cDV_NNUM
				_cCodBarras += Substr(SA6->A6_AGENCIA,1,4)+Substr(SA6->A6_NUMCON,1,7) +"00"+"1"	
				
		    Case cE1PORTADO == "637" // SOFISA
	
				_cB_Campo := "399"  + "9" + _cFatorVcto
				_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10) + Alltrim(_cNumboleta) + _cDV_NNUM
				_cB_Campo += Substr(SA6->A6_AGENCIA,1,4)+Substr(SA6->A6_NUMCON,1,7) +"00"+"1"	
	
				BarraDV()
				
				_cCodBarras := "399"  + "9" + _cDV_BARRA + _cFatorVcto
				_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10) + Alltrim(_cNumboleta) + _cDV_NNUM
				_cCodBarras += Substr(SA6->A6_AGENCIA,1,4)+Substr(SA6->A6_NUMCON,1,7) +"00"+"1"				
	
			Case cE1PORTADO == "033" // SANTANDER
				_cB_Campo := "033"  + "9" + _cFatorVcto
				_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10)
				_cB_Campo += "9" + "1809571" + Alltrim(_cNumboleta) + _cDV_NNUM + "0" + "101"
	
				BarraDV()
				
				_cCodBarras := "033"  + "9" + _cDV_BARRA + _cFatorVcto
				_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10) 
				_cCodBarras += "9" + "1809571" + Alltrim(_cNumboleta) + _cDV_NNUM + "0" + "101"
	                                         
			Case cE1PORTADO == "KOB" // KOBOL
				
				_cB_Campo := "341"  + "9" + _cFatorVcto
				_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10)
			   //_cB_Campo += "109" + Alltrim(_cNumboleta) + _cDV_NNUM + "2001" + "91898"  + "2" + "000" //chamado:045459 27/11/2018
	           	_cB_Campo += "109" + Alltrim(_cNumboleta) + _cDV_NNUM + "2001" + "02680"  + "2" + "000"
	                          //CARTEIRA
				BarraDV()
				
				_cCodBarras := "341"  + "9" + _cDV_BARRA + _cFatorVcto
				_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10) 
				//	_cCodBarras += "109" + Alltrim(_cNumboleta) + _cDV_NNUM + "2001" + "91898"  + "2" + "000" //chamado:045459 27/11/2018
				_cCodBarras += "109" + Alltrim(_cNumboleta) + _cDV_NNUM + "2001" + "02680"  + "2" + "000"
	                                                 
	       	Case cE1PORTADO $ "341" // ITAU  X
				
				_cB_Campo := "341"  + "9" + _cFatorVcto
				_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10)
				_cB_Campo += "109" + Alltrim(_cNumboleta) + _cDV_NNUM + SUBSTR(SA6->A6_AGENCIA,1,4) + SUBSTR(SA6->A6_NUMCON,1,5)  + IIF(ALLTRIM(SA6->A6_DVCTA) == '',SUBSTR(SA6->A6_NUMCON,Len(Alltrim(SA6->A6_NUMCON)),1),SA6->A6_DVCTA) + "000"
	                          //CARTEIRA
				BarraDV()
				
				_cCodBarras := "341"  + "9" + _cDV_BARRA + _cFatorVcto
				_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10) 
				_cCodBarras += "109" + Alltrim(_cNumboleta) + _cDV_NNUM + SUBSTR(SA6->A6_AGENCIA,1,4) + SUBSTR(SA6->A6_NUMCON,1,5)  + IIF(ALLTRIM(SA6->A6_DVCTA) == '',SUBSTR(SA6->A6_NUMCON,Len(Alltrim(SA6->A6_NUMCON)),1),SA6->A6_DVCTA) + "000"
	        
	       	Case cE1PORTADO $ "ITV" // Chamado n. 056544 || OS 058692 || FINANCAS || WAGNER || 11940283101 || ITAU - VINCULADA - FWNM - 09/04/2020
				
				/*
				Deve conter 44 (quarenta e quatro) posições, sendo:

				01 a 03 - Código do Banco na Câmara de Compensação = '341' 
				04 a 04 - Código da Moeda = '9'
				05 a 05 - DAC código de Barras (Anexo 2) 
				06 a 09 - Fator de Vencimento (Anexo 6)
				10 a 19 - Valor 
				20 a 22 - Carteira
				23 a 30 - Nosso Número 
				31 a 31 - DAC [Agência /Conta/Carteira/Nosso Número] (Anexo 4)
				32 a 35 - N.º da Agência BENEFICIÁRIO 
				36 a 40 - N.º da Conta Corrente
				41 a 41 - DAC [Agência/Conta Corrente] (Anexo 3) 
				42 a 44 - Zeros
				*/

				//cDACNN := Modulo10( Left(AllTrim(SA6->A6_AGENCIA),4) + Subs(SA6->A6_NUMCON,1,5) + AllTrim(SA6->A6_DVCTA) + AllTrim(_cCarteira) + AllTrim(_cNumBoleta) )
				cDACNN := _cDV_NNUM 		// _cDV_NNUM 		:= AllTrim(TSE1A->E1_DVNBCO) 

				// Codigo de barras sem o DAC do Código de Barras - exemplo 
				/*
				3419?166700000123451101234567880057123457000
				onde:
				341 = Código do Banco
				9 = Código da Moeda
				? = DAC do Código de Barras
				1667 = Fator de Vencimento (01/05/2002)
				0000012345 = Valor do Título (123,45)
				110123456788 = Carteira / Nosso Número/DAC (110/12345678-8)
				0057123457 = Agência / Conta Corrente/DAC (0057/12345-7)
				000 = Posições Livres (zeros)
				*/
				
				_cCodBarras := "341"
				_cCodBarras += "9"
				_cCodBarras += _cFatorVcto
				_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10)
				_cCodBarras += _cCarteira
				_cCodBarras += Alltrim(_cNumboleta)
				_cCodBarras += cDACNN //DAC [Agência /Conta/Carteira/Nosso Número] (Anexo 4)
				_cCodBarras += Left(AllTrim(SA6->A6_AGENCIA),4)
				_cCodBarras += Subs(SA6->A6_NUMCON,1,5)
				_cCodBarras += AllTrim(SA6->A6_DVCTA) //DAC [Agência/Conta Corrente] (Anexo 3) 
				_cCodBarras += "000"

				cDACCB := Modulo11( _cCodBarras )
				
				_cCodBarras := "341"
				_cCodBarras += "9"
				_cCodBarras += cDACCB //DAC código de Barras (Anexo 2) 
				_cCodBarras += _cFatorVcto
				_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10)
				_cCodBarras += _cCarteira
				_cCodBarras += Alltrim(_cNumboleta)
				_cCodBarras += cDACNN //DAC [Agência /Conta/Carteira/Nosso Número] (Anexo 4)
				_cCodBarras += Left(AllTrim(SA6->A6_AGENCIA),4)
				_cCodBarras += Subs(SA6->A6_NUMCON,1,5)
				_cCodBarras += AllTrim(SA6->A6_DVCTA) //DAC [Agência/Conta Corrente] (Anexo 3) 
				_cCodBarras += "000"

	        Case cE1PORTADO == "655" // VOTORANTIM
				
				//_cB_Campo := "655"  + "9" + _cFatorVcto
				_cB_Campo := "341"  + "9" + _cFatorVcto
				_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10)
				_cB_Campo += "109" + Alltrim(_cNumboleta) + _cDV_NNUM + SUBSTR(SA6->A6_AGENCIA,1,4) + SUBSTR(SA6->A6_NUMCON,1,5)  + IIF(ALLTRIM(SA6->A6_DVCTA) == '',SUBSTR(SA6->A6_NUMCON,Len(Alltrim(SA6->A6_NUMCON)),1),SA6->A6_DVCTA) + "000"
	                          //CARTEIRA
				BarraDV()
				
				//_cCodBarras := "655"  + "9" + _cDV_BARRA + _cFatorVcto
				_cCodBarras := "341"  + "9" + _cDV_BARRA + _cFatorVcto
				_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10) 
				_cCodBarras += "109" + Alltrim(_cNumboleta) + _cDV_NNUM + SUBSTR(SA6->A6_AGENCIA,1,4) + SUBSTR(SA6->A6_NUMCON,1,5)  + IIF(ALLTRIM(SA6->A6_DVCTA) == '',SUBSTR(SA6->A6_NUMCON,Len(Alltrim(SA6->A6_NUMCON)),1),SA6->A6_DVCTA) + "000"
			
	        
	        Case cE1PORTADO == "104" //  // CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
			
				_cB_Campo 	:= "104" 												//01-03 [03]- Idetificação Banco
				_cB_Campo 	+= "9" 													//04-04 [01]- Moeda  
				_cB_Campo 	+= _cFatorVcto											//06-09 [04]- Fator Vcnto
				_cB_Campo 	+= StrZero(Int(Round(_nVlrBol*100,2)),10)   	        //10-19 [10]- Posicoes
				_cB_Campo   += "8325375"                                            //20-26 [07]- Posições
				_cB_Campo   += SUBSTR(_cNumboleta,3,3)                              //27-29 [03]- Nosso numero 17 posições(CARTEIRA+15 POSIÇOES E1_NUMBCO)
				_cB_Campo   += SUBSTR(_cNumboleta,1,1)    							//30-30 [01]- Nosso numero 17 posições(CARTEIRA+15 POSIÇOES E1_NUMBCO)
				_cB_Campo   += SUBSTR(_cNumboleta,6,3)                              //31-33 [01]- Nosso numero 17 posições(CARTEIRA+15 POSIÇOES E1_NUMBCO)
				_cB_Campo   += SUBSTR(_cNumboleta,2,1)                              //34-34 [01]- Nosso numero 17 posições(CARTEIRA+15 POSIÇOES E1_NUMBCO)
				_cB_Campo   += SUBSTR(_cNumboleta,9,9)                              //35-43 [01]- Nosso numero 17 posições(CARTEIRA+15 POSIÇOES E1_NUMBCO)
				_cB_Campo   += u_Dgcmpliv("8325375"+SUBSTR(_cNumboleta,3,3)+SUBSTR(_cNumboleta,1,1)+;
			                   SUBSTR(_cNumboleta,6,3)+SUBSTR(_cNumboleta,2,1)+SUBSTR(_cNumboleta,9,9)) //44-44 [01]- DV DO CAMPO LIVRE
			
				_cDV_BARRA := u_DgVerECF(_cB_Campo) //Calcula digito verificador do codigo de barras completo.
	
				_cCodBarras := cE1PORTADO  + "9" + _cDV_BARRA + _cFatorVcto
				_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10)
				_cCodBarras += "8325375" 
		   		_cCodBarras += SUBSTR(_cNumboleta,3,3)                                           
				_cCodBarras += SUBSTR(_cNumboleta,1,1)                                               
				_cCodBarras += SUBSTR(_cNumboleta,6,3)                             
				_cCodBarras += SUBSTR(_cNumboleta,2,1)                                               
				_cCodBarras += SUBSTR(_cNumboleta,9,9)                            
				_cCodBarras += _RE_Campo                                               
			
		EndCase

			
		IMPBOLETO(aParamIXB) 		////  Rotina de impressao do Boleto com codigo de Barras 
			
		TSE1A->(dbSkip())
		
		oPrint:EndPage()
		
	EndDo

	U_FecArTMP("TSE1A")

Return

/*
Função de montagem da linha digitavel utilizaada no padrões do banco do Brasil como no Banco Bradesco 
*/
Static Function MontaLinha() 

	_cLineDig := ""
	_cnDigito := ""
	_cPedaco  := ""
	
	Do Case
		
		Case cE1PORTADO == "001"	// Banco do Brasil
			
			_cLineDig := ""
			_cnDigito := ""
			_cPedaco  := ""
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Primeiro Campo                                                             ³
			//³Codigo do Banco + Moeda + 5 primeiras posições do campo livre do Cod Barras³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_cPedaco := Substr(_cCodBarras,01,03) + Substr(_cCodBarras,04,01) + Substr(_cCodBarras,20,5)
			DV_LINHA()
			_cLineDig := Substr(_cCodBarras,1,3)+Substr(_cCodBarras,4,1)+Substr(_cCodBarras,20,1)+"."+;
			Substr(_cCodBarras,21,4) + _cnDigito + Space(2)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Segundo Campo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_cPedaco  := Substr(_cCodBarras,25,10)
			DV_LINHA()
			_cLineDig := _cLineDig+Substr(_cPedaco,1,5)+"."+Substr(_cPedaco,6,5)+;
			_cnDigito+Space(2)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Terceiro Campo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_cPedaco  := Substr(_cCodBarras,35,10)
			DV_LINHA()
			_cLineDig := _cLineDig + Substr(_cPedaco,1,5)+"."+Substr(_cPedaco,6,5)+_cnDigito+Space(2)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quarto Campo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_cLineDig := _cLineDig + _cDV_BARRA + Space(2)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quinto Campo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_cLineDig  := _cLineDig + _cFatorVcto + StrZero(Int(Round(_nVlrBol*100,2)),10)
	    
	    //Case cE1PORTADO $ "422/SAF"	// Banco Safra       //ALEX BORGES 03/04/12
		Case cE1PORTADO $ "SAF"	// Banco Safra      
		
			_cLineDig := ""
			_cnDigito := ""
			_cPedaco  := ""
			
			_cCodBr	 := Substr(_cCodBarras,20,44)
			
			//Primeiro Campo
			//Codigo do Banco + Moeda + 5 primeiras posições do campo livre do Cod Barras
			_cPedaco := Substr(_cCodBarras,01,03) + Substr(_cCodBarras,04,01) + "3114" + SUBSTR(_cCarteira,1,1)
			DV_LINHA()
			_cLineDig := Substr(_cCodBarras,01,03) + Substr(_cCodBarras,04,01) + "3.114" + SUBSTR(_cCarteira,1,1)+_cnDigito+Space(2)
			
			//Segundo Campo                                                                                     
			//Alterado Ana Helena - 01/02/12 - Pois o digito verificador estava incorreto		
			//_cPedaco  := SUBSTR(_cCarteira,2,1) + RIGHT(DTOC(DDATABASE),2) + SUBSTR(ALLTRIM(_cNumboleta),3,5) 
			_cPedaco  := SUBSTR(_cCarteira,2,1) + RIGHT(DTOC(DDATABASE),2) + SUBSTR(ALLTRIM(_cNumboleta),1,7) 
			DV_LINHA()   
			_cLineDig += SUBSTR(_cCarteira,2,1) + RIGHT(DTOC(DDATABASE),2) + SUBSTR(ALLTRIM(_cNumboleta),1,2) +"." + SUBSTR(ALLTRIM(_cNumboleta),3,5)+_cnDigito+Space(2)
			
			//Terceiro Campo
		   _cPedaco  := SUBSTR(ALLTRIM(_cNumboleta),8,1) + ALLTRIM(_cDV_NNUM) + "01763000"
			DV_LINHA()
			_cLineDig += SUBSTR(ALLTRIM(_cNumboleta),8,1) + ALLTRIM(_cDV_NNUM) + "017.63000"+_cnDigito+Space(2)
			
			//Quarto Campo
			_cLineDig += _cDV_BARRA + Space(2)
			
			//Quinto Campo
			_cLineDig  += _cFatorVcto + StrZero(Int(Round(_nVlrBol*100,2)),10) 
			
		Case cE1PORTADO $ "422/SFF"	// Banco Safra    // fernando sigoli 29/10/2017 Chamado: 036517
		
			_cLineDig := ""
			_cnDigito := ""
			_cPedaco  := ""
			
			//Primeiro Campo
			_cPedaco  := Substr(_cCodBarras,01,04) + '7' + Substr(_cCodBarras,21,04) // WILLIAM COSTA 05/09/2019 CHAMADO 051514 || OS 052842 || FINANCAS || ANDREA || 8319 || BANCO SAFRA
			_cLineDig := Substr(_cPedaco,01,05)+"."+ Substr(_cPedaco,06,04)+ADMOD10(2,_cPedaco)+ Space(2)
			
			//Segundo Campo 
			_cPedaco := ""
			_cPedaco := Substr(_cCodBarras,25,1) + Substr(_cCodBarras,26,9)
			_cLineDig += Substr(_cPedaco,01,05) +"."+ Substr(_cPedaco,06,05) + ADMOD10(1,_cPedaco) + Space(2)
			  
			//Terceiro Campo 
			_cPedaco := ""
			_cPedaco := substr(_cCodBarras,35,10)
		    _cLineDig += Substr(_cPedaco,1,5) +"."+ Substr(_cPedaco,6,5) + ADMOD10(1,_cPedaco)+ Space(2)
			
			//Quarto Campo
			_cLineDig += Substr(_cCodBarras,5,1) + Space(2) //Calcula digito verificador do codigo de barras completo.
	
			//Quinto Campo
			_cLineDig  += _cFatorVcto + StrZero(Int(Round(_nVlrBol*100,2)),10) 	
			
		Case cE1PORTADO $ "237/RED/BRD"	// Bradesco / RED FACTOR 
	
	      // da 20 a 44                                                                     
			_cLineDig := ""
			_cnDigito := ""
			_cPedaco  := ""
			
			_cCodBr	 := Substr(_cCodBarras,20,44)
			
			//Primeiro Campo
			//Codigo do Banco + Moeda + 5 primeiras posições do campo livre do Cod Barras
			_cPedaco := Substr(_cCodBarras,01,03) + Substr(_cCodBarras,04,01) + Substr(_cCodBr,01,05)
			DV_LINHA()
			_cLineDig := Substr(_cCodBarras,1,3)+Substr(_cCodBarras,4,1)+Substr(_cCodBr,01,01)+"."+Substr(_cCodBr,02,04) + _cnDigito + Space(2)
			
			//Segundo Campo
			_cPedaco  := Substr(_cCodBr,06,10)
			DV_LINHA()
			_cLineDig := _cLineDig+Substr(_cPedaco,1,5)+"."+Substr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Terceiro Campo
		   _cPedaco  := Substr(_cCodBr,16,10)
			DV_LINHA()
			_cLineDig := _cLineDig + Substr(_cPedaco,1,5)+"."+Substr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Quarto Campo
			_cLineDig := _cLineDig + _cDV_BARRA + Space(2)
			
			//Quinto Campo
			_cLineDig  := _cLineDig + _cFatorVcto + StrZero(Int(Round(_nVlrBol*100,2)),10)      
		
		// *** INICIO CHAMADO 050420	
		Case cE1PORTADO $ "BRV"	// Bradesco / RED FACTOR 
	
	      // da 20 a 44                                                                     
			_cLineDig := ""
			_cnDigito := ""
			_cPedaco  := ""
			
			_cCodBr	 := Substr(_cCodBarras,20,44)
			
			//Primeiro Campo
			//Codigo do Banco + Moeda + 5 primeiras posições do campo livre do Cod Barras
			_cPedaco := Substr(_cCodBarras,01,03) + Substr(_cCodBarras,04,01) + Substr(_cCodBr,01,05)
			DV_LINHA()
			_cLineDig := Substr(_cCodBarras,1,3)+Substr(_cCodBarras,4,1)+Substr(_cCodBr,01,01)+"."+Substr(_cCodBr,02,04) + _cnDigito + Space(2)
			
			//Segundo Campo
			_cPedaco  := Substr(_cCodBr,06,10)
			DV_LINHA()
			_cLineDig := _cLineDig+Substr(_cPedaco,1,5)+"."+Substr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Terceiro Campo
		   _cPedaco  := Substr(_cCodBr,16,10)
			DV_LINHA()
			_cLineDig := _cLineDig + Substr(_cPedaco,1,5)+"."+Substr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Quarto Campo
			_cLineDig := _cLineDig + _cDV_BARRA + Space(2)
			
			//Quinto Campo
			_cLineDig  := _cLineDig + _cFatorVcto + StrZero(Int(Round(_nVlrBol*100,2)),10)
				
	    // *** FINAL CHAMADO 050420
	      
		Case cE1PORTADO == "246"	// ABC
	
			_cLineDig := ""
			_cnDigito := ""
			_cPedaco  := ""
			
			_cCodBr	 := Substr(_cCodBarras,20,44)
			
			//Primeiro Campo
			//Codigo do Banco + Moeda + 5 primeiras posições do campo livre do Cod Barras
			_cPedaco := Substr(_cCodBarras,01,03) + Substr(_cCodBarras,04,01) + Substr(_cCodBr,01,05)
			DV_LINHA()
			_cLineDig := Substr(_cCodBarras,1,3)+Substr(_cCodBarras,4,1)+Substr(_cCodBr,01,01)+"."+Substr(_cCodBr,02,04) + _cnDigito + Space(2)
			
			//Segundo Campo
			_cPedaco  := Substr(_cCodBr,06,10)
			DV_LINHA()
			_cLineDig := _cLineDig+Substr(_cPedaco,1,5)+"."+Substr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Terceiro Campo
		   _cPedaco  := Substr(_cCodBr,16,10)
			DV_LINHA()
			_cLineDig := _cLineDig + Substr(_cPedaco,1,5)+"."+Substr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Quarto Campo
			_cLineDig := _cLineDig + _cDV_BARRA + Space(2)
			
			//Quinto Campo
			_cLineDig  := _cLineDig + _cFatorVcto + StrZero(Int(Round(_nVlrBol*100,2)),10)      
		Case cE1PORTADO $ "399/637"		// HSBC
	
			_cLineDig := ""
			_cnDigito := ""
			_cPedaco  := ""
			
			//Primeiro Campo
			//Codigo do Banco + Moeda + 5 primeiras posições do campo livre do Cod Barras
			_cPedaco := Substr(_cCodBarras,01,03) + Substr(_cCodBarras,04,01) + Substr(_cCodBarras,20,5)
			DV_LINHA()
			_cLineDig := Substr(_cCodBarras,1,3)+Substr(_cCodBarras,4,1)+Substr(_cCodBarras,20,1)+"."+Substr(_cCodBarras,21,4) + _cnDigito + Space(2)
			
			//Segundo Campo
			_cPedaco  := Substr(_cCodBarras,25,10)
			DV_LINHA()
			_cLineDig := _cLineDig+Substr(_cPedaco,1,5)+"."+Substr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Terceiro Campo
			_cPedaco  := Substr(_cCodBarras,35,10)
			DV_LINHA()
			_cLineDig := _cLineDig + Substr(_cPedaco,1,5)+"."+Substr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Quarto Campo
			_cLineDig := _cLineDig + _cDV_BARRA + Space(2)
			
			//Quinto Campo
			_cLineDig  := _cLineDig + _cFatorVcto + StrZero(Int(Round(_nVlrBol*100,2)),10)						
			
		Case cE1PORTADO == "033"		// SATANDER
			
			_cLineDig := ""
			_cnDigito := ""
			_cPedaco  := ""
			
			//Primeiro Campo
			//Codigo do Banco + Moeda + 5 primeiras posições do campo livre do Cod Barras
			_cPedaco := Substr(_cCodBarras,01,03) + Substr(_cCodBarras,04,01) + Substr(_cCodBarras,20,5)
			//_cPedaco := "033" + "9" + "9" + "018"
			DV_LINHA()
			_cLineDig := Substr(_cCodBarras,1,3)+Substr(_cCodBarras,4,1)+Substr(_cCodBarras,20,1)+"."+Substr(_cCodBarras,21,4) + _cnDigito + Space(2)
			
			//Segundo Campo
			_cPedaco  := Substr(_cCodBarras,25,10)
			DV_LINHA()
			_cLineDig := _cLineDig+Substr(_cPedaco,1,5)+"."+Substr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Terceiro Campo
			_cPedaco  := Substr(_cCodBarras,35,10)
			DV_LINHA()
			_cLineDig := _cLineDig + Substr(_cPedaco,1,5)+"."+Substr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Quarto Campo
			_cLineDig := _cLineDig + _cDV_BARRA + Space(2)
			
			//Quinto Campo
			_cLineDig  := _cLineDig + _cFatorVcto + StrZero(Int(Round(_nVlrBol*100,2)),10)		
			
		Case cE1PORTADO $ "KOB"		// KOBOLD
			
			_cLineDig := ""
			_cnDigito := ""
			_cPedaco  := ""
			
			//Primeiro Campo
			_cPedaco := Substr(_cCodBarras,01,03) + Substr(_cCodBarras,04,01) + Substr(_cCodBarras,20,5)
			DV_LINHA()
			_cLineDig := Substr(_cCodBarras,1,3)+Substr(_cCodBarras,4,1)+Substr(_cCodBarras,20,1)+"."+Substr(_cCodBarras,21,4) + _cnDigito + Space(2)
			
			//Segundo Campo
			_cPedaco  := Substr(_cCodBarras,25,10)
			DV_LINHA()
			_cLineDig := _cLineDig+Substr(_cPedaco,1,5)+"."+Substr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Terceiro Campo
			_cPedaco  := Substr(_cCodBarras,35,10)
			DV_LINHA()
			_cLineDig := _cLineDig + Substr(_cPedaco,1,5)+"."+Substr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Quarto Campo
			_cLineDig := _cLineDig + _cDV_BARRA + Space(2)
			
			//Quinto Campo
			_cLineDig  := _cLineDig + _cFatorVcto + StrZero(Int(Round(_nVlrBol*100,2)),10)		
	
		Case cE1PORTADO $ "655" // 
			
			_cLineDig := ""
			_cnDigito := ""
			_cPedaco  := ""
			
			//Primeiro Campo
			//Codigo do Banco + Moeda + 5 primeiras posições do campo livre do Cod Barras
			_cPedaco := Substr(_cCodBarras,01,03) + Substr(_cCodBarras,04,01) + Substr(_cCodBarras,20,5)
			//_cPedaco := "033" + "9" + "9" + "018"
			DV_LINHA()
			_cLineDig := Substr(_cCodBarras,1,3)+Substr(_cCodBarras,4,1)+Substr(_cCodBarras,20,1)+"."+Substr(_cCodBarras,21,4) + _cnDigito + Space(2)
			
			//Segundo Campo
			_cPedaco  := Substr(_cCodBarras,25,10)
			DV_LINHA()
		    _cLineDig := _cLineDig+Substr(_cPedaco,1,5)+"."+Substr(_cPedaco,6,5)+_cnDigito+Space(2)
			                  
			
			//Terceiro Campo
			_cPedaco  := Substr(_cCodBarras,35,10)
			DV_LINHA()
			_cLineDig := _cLineDig + Substr(_cPedaco,1,5)+"."+Substr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Quarto Campo
			_cLineDig := _cLineDig + _cDV_BARRA + Space(2)
			
			//Quinto Campo
			_cLineDig  := _cLineDig + _cFatorVcto + StrZero(Int(Round(_nVlrBol*100,2)),10)				
		
		Case cE1PORTADO $ "341"		// ITAU -- fernando sigoli 16/07
			
			_cLineDig := ""
			_cnDigito := ""
			_cPedaco  := ""
			
			//Primeiro Campo
			//Codigo do Banco + Moeda + 5 primeiras posições do campo livre do Cod Barras
			_cPedaco := Substr(_cCodBarras,01,03) + Substr(_cCodBarras,04,01) + Substr(_cCodBarras,20,5)
			//_cPedaco := "033" + "9" + "9" + "018"
			DV_LINHA()
			_cLineDig := Substr(_cCodBarras,1,3)+Substr(_cCodBarras,4,1)+Substr(_cCodBarras,20,1)+"."+Substr(_cCodBarras,21,4) + _cnDigito + Space(2)
			
			//Segundo Campo
			_cPedaco := Substr(_cCodBarras,25,1) + Substr(_cCodBarras,26,9)
			_cLineDig += Substr(_cPedaco,01,05) +"."+ Substr(_cPedaco,06,05) + ADMOD10(1,_cPedaco) + Space(2)
			  
			
			//Terceiro Campo
			_cPedaco  := Substr(_cCodBarras,35,10)
			DV_LINHA()
			_cLineDig := _cLineDig + Substr(_cPedaco,1,5)+"."+Substr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Quarto Campo
			_cLineDig := _cLineDig + _cDV_BARRA + Space(2)
			
			//Quinto Campo
			_cLineDig  := _cLineDig + _cFatorVcto + StrZero(Int(Round(_nVlrBol*100,2)),10)				
					                                                                                
		Case cE1PORTADO $ "ITV" // Chamado n. 056544 || OS 058692 || FINANCAS || WAGNER || 11940283101 || ITAU - VINCULADA - FWNM - 09/04/2020
			
			_cLineDig := ""
			_cnDigito := ""
			_cPedaco  := ""

			/*
			Campo 1 (AAABC.CCDDX)
			AAA = Código do Banco na Câmara de Compensação (Itaú=341)
			B   = Código da moeda = "9" (*)
			CCC = Código da carteira de cobrança 
			DD  = Dois primeiros dígitos do Nosso Número
			X   = DAC que amarra o campo 1 (Anexo3)
			*/
			_cCampo1 := Left(AllTrim(_cCodBarras),3) // AAA
			_cCampo1 += "9"							 // B
			_cCampo1 += _cCarteira					 // CCC
			_cCampo1 += Left(AllTrim(_cNumBoleta),2) // DD
			_cCampo1 += Modulo10(_cCampo1)

			/*
			Campo 2 (DDDDD.DEFFFY)
			DDDDDD = Restante do Nosso Número 
			E      = DAC do campo [Agência/Conta/Carteira/ Nosso Número] (Anexo 4)
			FFF    = Três primeiros números que identificam a Agência 
			Y      = DAC que amarra o campo 2 (Anexo 3)			
			*/
			_cCampo2 := Right(AllTrim(_cNumBoleta),6)    // DDDDDD
			_cCampo2 += Subs(AllTrim(_cCodBarras),31,1)  // E
			_cCampo2 += Left(AllTrim(SA6->A6_AGENCIA),3) // FFF
			_cCampo2 += Modulo10(_cCampo2)

			/*
			Campo 3 (FGGGG.GGHHHZ)
			F      = Restante do número que identifica a agência 
			GGGGGG = Número da conta corrente + DAC
			HHH    = Zeros ( Não utilizado ) 
			Z      = DAC que amarra o campo 3 (Anexo 3)
			*/
			_cCampo3 := Right(AllTrim(SA6->A6_AGENCIA),1) 				 // F
			_cCampo3 += AllTrim(SA6->A6_NUMCON) + AllTrim(SA6->A6_DVCTA) // GGGGGG
			_cCampo3 += "000"                                            // HHH
			_cCampo3 += Modulo10(_cCampo3)

			/*
			Campo 4 (K)
			K = DAC do Código de Barras (Anexo 2)
			*/
			_cCampo4 := Subs(AllTrim(_cCodBarras),5,1)  // K

			/*
			Campo 5 (UUUUVVVVVVVVVV)
			UUUU = Fator de vencimento 
			VVVVVVVVVV = Valor do Título (*)
			*/
			_cCampo5 := Subs(AllTrim(_cCodBarras),6,4)  // UUUU
			_cCampo5 += Subs(AllTrim(_cCodBarras),10,10)  // VVVVVVVVVV

			// Linha digitável
			_cLineDig := Left(AllTrim(_cCampo1),5) + "." + Right(AllTrim(_cCampo1),5)
			_cLineDig += + Space(2)

			_cLineDig += Left(AllTrim(_cCampo2),5) + "." + Right(AllTrim(_cCampo2),6)
			_cLineDig += + Space(2)

			_cLineDig += Left(AllTrim(_cCampo3),5) + "." + Right(AllTrim(_cCampo3),6)
			_cLineDig += + Space(2)

			_cLineDig += _cCampo4
			_cLineDig += + Space(2)

			_cLineDig += _cCampo5
			_cLineDig += + Space(2)

		Case cE1PORTADO == "104" // CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
			_cLineDig := ""
			_cnDigito := ""
			_cPedaco  := ""
			
			//Primeiro Campo
			_cPedaco := Substr(_cCodBarras,01,03) + Substr(_cCodBarras,04,01) + Substr(_cCodBarras,20,5)
			DV_LINHA()
			_cLineDig := Substr(_cCodBarras,1,4)+Substr(_cCodBarras,20,1)+"."+Substr(_cCodBarras,21,4) + _cnDigito + Space(2)
			
			//Segundo Campo
			_cPedaco  := Substr(_cCodBarras,25,10)
			DV_LINHA()
			_cLineDig := _cLineDig+Substr(_cPedaco,1,5)+"."+Substr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Terceiro Campo
			_cPedaco  := Substr(_cCodBarras,35,10)
			DV_LINHA()
			_cLineDig := _cLineDig + Substr(_cPedaco,1,5)+"."+Substr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Quarto Campo
			_cLineDig := _cLineDig + _cDV_BARRA + Space(2)
			
			//Quinto Campo
			_cLineDig  := _cLineDig + _cFatorVcto + StrZero(Int(Round(_nVlrBol*100,2)),10)				
		
	EndCase

Return

/*
³Função de calculo do digito da linha digitavel utilizada para os bancos 
*/
Static Function DV_LINHA()

	Local i := 0

	Do Case
		// Banco do Brasil
		Case cE1PORTADO == "001"
			nCont  := 0
			_cPeso := 2
			
			For i := Len(_cPedaco) to 1 Step -1
				
				If _cPeso == 3
					_cPeso := 1
				Endif
				
				If Val(SUBSTR(_cPedaco,i,1))*_cPeso >= 10
					nVal  := Val(SUBSTR(_cPedaco,i,1)) * _cPeso
					nCont := nCont+(Val(SUBSTR(Str(nVal,2),1,1))+Val(SUBSTR(Str(nVal,2),2,1)))
				Else
					nCont:=nCont+(Val(SUBSTR(_cPedaco,i,1))* _cPeso)
				Endif
				
				_cPeso := _cPeso + 1
			Next
			
			_cDezena  := Substr(Str(nCont,2),1,1)
			_cResto   := ( (Val(_cDezena)+1) * 10) - nCont
			If _cResto   == 10
				_cnDigito := "0"
			Else
				_cnDigito := Str(_cResto,1)
			Endif
		
		  Case cE1PORTADO $ "422/SAF/SFF"	// ALEX BORGES 03/04/12
			nCont  := 0
			_cPeso   := 2
			
			For i := Len(_cPedaco) to 1 Step -1
				
				If _cPeso == 3
					_cPeso := 1
				Endif
				
				If Val(SUBSTR(_cPedaco,i,1))*_cPeso >= 10
					nVal  := Val(SUBSTR(_cPedaco,i,1)) * _cPeso
					nCont := nCont+(Val(SUBSTR(Str(nVal,2),1,1))+Val(SUBSTR(Str(nVal,2),2,1)))
				Else
					nCont:=nCont+(Val(SUBSTR(_cPedaco,i,1))* _cPeso)
				Endif
				
				_cPeso := _cPeso + 1
			Next
			
			_cDezena  := Substr(Str(nCont,2),1,1)    
			_cResto   := ( (Val(_cDezena)+1) * 10) - nCont
	
			If _cResto   >= 10
				_cnDigito := "0"
			Else
				_cnDigito := Str(_cResto,1)
			Endif
	      
		Case cE1PORTADO $ "237/RED/BRD"		// Bradesco / RED FACTOR 
			nCont  := 0
			_cPeso   := 2
			
			For i := Len(_cPedaco) to 1 Step -1
				
				If _cPeso == 3
					_cPeso := 1
				Endif
				
				If Val(SUBSTR(_cPedaco,i,1))*_cPeso >= 10
					nVal  := Val(SUBSTR(_cPedaco,i,1)) * _cPeso
					nCont := nCont+(Val(SUBSTR(Str(nVal,2),1,1))+Val(SUBSTR(Str(nVal,2),2,1)))
				Else
					nCont:=nCont+(Val(SUBSTR(_cPedaco,i,1))* _cPeso)
				Endif
				
				_cPeso := _cPeso + 1
			Next
			
			_cDezena  := Substr(Str(nCont,2),1,1)    
			_cResto   := ( (Val(_cDezena)+1) * 10) - nCont
	
			If _cResto   >= 10
				_cnDigito := "0"
			Else
				_cnDigito := Str(_cResto,1)
			Endif
		
		// *** INICIO CHAMADO 050420	
		Case cE1PORTADO $ "BRV"
			nCont  := 0
			_cPeso   := 2
			
			For i := Len(_cPedaco) to 1 Step -1
				
				If _cPeso == 3
					_cPeso := 1
				Endif
				
				If Val(SUBSTR(_cPedaco,i,1))*_cPeso >= 10
					nVal  := Val(SUBSTR(_cPedaco,i,1)) * _cPeso
					nCont := nCont+(Val(SUBSTR(Str(nVal,2),1,1))+Val(SUBSTR(Str(nVal,2),2,1)))
				Else
					nCont:=nCont+(Val(SUBSTR(_cPedaco,i,1))* _cPeso)
				Endif
				
				_cPeso := _cPeso + 1
			Next
			
			_cDezena  := Substr(Str(nCont,2),1,1)    
			_cResto   := ( (Val(_cDezena)+1) * 10) - nCont
	
			If _cResto   >= 10
				_cnDigito := "0"
			Else
				_cnDigito := Str(_cResto,1)
			Endif
		// *** FINAL CHAMADO 050420	
	
		Case cE1PORTADO == "246"		// ABC
			nCont  := 0
			_cPeso   := 2
			
			For i := Len(_cPedaco) to 1 Step -1
				
				If _cPeso == 3
					_cPeso := 1
				Endif
				
				If Val(SUBSTR(_cPedaco,i,1))*_cPeso >= 10
					nVal  := Val(SUBSTR(_cPedaco,i,1)) * _cPeso
					nCont := nCont+(Val(SUBSTR(Str(nVal,2),1,1))+Val(SUBSTR(Str(nVal,2),2,1)))
				Else
					nCont:=nCont+(Val(SUBSTR(_cPedaco,i,1))* _cPeso)
				Endif
				
				_cPeso := _cPeso + 1
			Next
			
			_cDezena  := Substr(Str(nCont,2),1,1)    
			_cResto   := ( (Val(_cDezena)+1) * 10) - nCont
	
			If _cResto   >= 10
				_cnDigito := "0"
			Else
				_cnDigito := Str(_cResto,1)
			Endif
			
		Case cE1PORTADO $ "399/637"		// HSBC
			nCont  := 0
			_cPeso   := 2
			
			For i := Len(_cPedaco) to 1 Step -1
				
				If _cPeso == 3
					_cPeso := 1
				Endif
				
				If Val(SUBSTR(_cPedaco,i,1))*_cPeso >= 10
					nVal  := Val(SUBSTR(_cPedaco,i,1)) * _cPeso
					nCont := nCont+(Val(SUBSTR(Str(nVal,2),1,1))+Val(SUBSTR(Str(nVal,2),2,1)))
				Else
					nCont:=nCont+(Val(SUBSTR(_cPedaco,i,1))* _cPeso)
				Endif
				
				_cPeso := _cPeso + 1
			Next
			
			_cDezena  := Substr(Str(nCont,2),1,1)
			_cResto   := ( (Val(_cDezena)+1) * 10) - nCont
			If _cResto   == 10
				_cnDigito := "0"
			Else
				_cnDigito := Str(_cResto,1)
			Endif		
			
		Case cE1PORTADO == "033"		// SANTANDER
			nCont  := 0
			_cPeso   := 2
			
			For i := Len(_cPedaco) to 1 Step -1
				
				If _cPeso == 3
					_cPeso := 1
				Endif
				
				If Val(SUBSTR(_cPedaco,i,1))*_cPeso >= 10
					nVal  := Val(SUBSTR(_cPedaco,i,1)) * _cPeso
					nCont := nCont+(Val(SUBSTR(Str(nVal,2),1,1))+Val(SUBSTR(Str(nVal,2),2,1)))
				Else
					nCont:=nCont+(Val(SUBSTR(_cPedaco,i,1))* _cPeso)
				Endif
				
				_cPeso := _cPeso + 1
			Next
			
			_cDezena  := Substr(Str(nCont,2),1,1)
			_cResto   := ( (Val(_cDezena)+1) * 10) - nCont
			If _cResto   == 10
				_cnDigito := "0"
			Else
				_cnDigito := Str(_cResto,1)
			Endif 
			
		Case cE1PORTADO $ "KOB"		// ITAU E VOTORANTIM
			nCont  := 0
			_cPeso   := 2
			
			For i := Len(_cPedaco) to 1 Step -1
				
				If _cPeso == 3
					_cPeso := 1
				Endif
				
				If Val(SUBSTR(_cPedaco,i,1))*_cPeso >= 10
					nVal  := Val(SUBSTR(_cPedaco,i,1)) * _cPeso
					nCont := nCont+(Val(SUBSTR(Str(nVal,2),1,1))+Val(SUBSTR(Str(nVal,2),2,1)))
				Else
					nCont:=nCont+(Val(SUBSTR(_cPedaco,i,1))* _cPeso)
				Endif
				
				_cPeso := _cPeso + 1
			Next
			
			_cDezena  := Substr(Str(nCont,2),1,1)
			_cResto   := ( (Val(_cDezena)+1) * 10) - nCont
			_cnDigito := If((_cResto = 10),"0",StrZero(_cResto,1)) 				
	
		Case cE1PORTADO $ "341/655/ITV"		// ITAU E VOTORANTIM
			nCont  := 0
			_cPeso   := 2
			
			For i := Len(_cPedaco) to 1 Step -1
				
				If _cPeso == 3
					_cPeso := 1
				Endif
				
				If Val(SUBSTR(_cPedaco,i,1))*_cPeso >= 10
					nVal  := Val(SUBSTR(_cPedaco,i,1)) * _cPeso
					nCont := nCont+(Val(SUBSTR(Str(nVal,2),1,1))+Val(SUBSTR(Str(nVal,2),2,1)))
				Else
					nCont:=nCont+(Val(SUBSTR(_cPedaco,i,1))* _cPeso)
				Endif
				
				_cPeso := _cPeso + 1
			Next
			
			_cDezena  := Substr(Str(nCont,2),1,1)
			_cResto   := ( (Val(_cDezena)+1) * 10) - nCont
			 If cE1PORTADO == "655"
			 	_cnDigito := If((_cResto==0 .Or. _cResto >= 10),"0",StrZero(_cResto,1)) 
			 Else
			    _cnDigito := If((_cResto==0 .Or. _cResto == 1 .Or. _cResto >= 10),"1",StrZero(_cResto,1))      
			 Endif	
		
		Case cE1PORTADO == "104"	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
			nCont  := 0
			_cPeso := 2
			
			For i := Len(_cPedaco) to 1 Step -1
				
				If _cPeso == 3
					_cPeso := 1
				Endif
				
				If Val(SUBSTR(_cPedaco,i,1))*_cPeso >= 10
					nVal  := Val(SUBSTR(_cPedaco,i,1)) * _cPeso
					nCont := nCont+(Val(SUBSTR(Str(nVal,2),1,1))+Val(SUBSTR(Str(nVal,2),2,1)))
				Else
					nCont:=nCont+(Val(SUBSTR(_cPedaco,i,1))* _cPeso)
				Endif
				
				_cPeso := _cPeso + 1
			Next
			
			
			_cDezena  := Substr(Str(nCont,2),1,1)
			_cResto   := ( (Val(_cDezena)+1) * 10) - nCont
			
			If _cResto   == 10
				_cnDigito := "0"
			Else
				_cnDigito := Str(_cResto,1)
			Endif
			
	EndCase
	
Return

/*
Função de Calculo do Digito de Verificação do Codigo de Barras utilizado para os bancos 
*/
Static Function BarraDV()

	Local i := 0

	Do Case
		
		Case cE1PORTADO == "001"			// Banco do Brasil
			_cnCont := 0
			_ccPeso := 2
			For i := 43 To 1 Step -1
				_cnCont := _cnCont + ( Val( SUBSTR( _cB_Campo,i,1 )) * _ccPeso )
				_ccPeso := _ccPeso + 1
				If _ccPeso >  9
					_ccPeso := 2
				Endif
			Next
	
			_cResto  := ( _cnCont % 11 )
			_cResult := ( 11 - _cResto )
			Do Case
				Case _cResult == 10 .or. _cResult == 11 .or. _cResult == 0
					_cDV_BARRA := "1"
				OtherWise
					_cDV_BARRA := Str(_cResult,1)
			EndCase
			
		Case cE1PORTADO $ "SAF"			// Banco SAFRA       //ALEX BORGES 03/04/12
			
			_cnCont := 0
			_ccPeso := 2
			
			For i := 43 To 1 Step -1
				_cnCont += ( Val( SUBSTR( _cB_Campo,i,1 )) * _ccPeso )
				_ccPeso += 1
				If _ccPeso >  9
					_ccPeso := 2
				Endif
			Next
			
			_cResto  := ( _cnCont % 11 )
			_cResult := _cResto
			_cResult := ( 11 - _cResto )
			Do Case
				Case _cResult == 0 .OR. _cResult == 1 .OR. _cResult > 9
					_cDV_BARRA := "1"
				OtherWise
					_cDV_BARRA := Str(_cResult,1)
			EndCase  
		
		Case cE1PORTADO $ "237/RED/BRD"	// Bradesco / RED FACTOR 
			_cnCont := 0
			_ccPeso := 2
			For i := 43 To 1 Step -1
				_cnCont += ( Val( SUBSTR( _cB_Campo,i,1 )) * _ccPeso )
				_ccPeso += 1
				If _ccPeso >  9
					_ccPeso := 2
				Endif
			Next
			_cResto  := ( _cnCont % 11 )
			_cResult := _cResto
			_cResult := ( 11 - _cResto )
			Do Case
				Case _cResult == 0 .OR. _cResult == 1 .OR. _cResult > 9
					_cDV_BARRA := "1"
				OtherWise
					_cDV_BARRA := Str(_cResult,1)
			EndCase
			
		// *** INICIO CHAMADO 050420	
		Case cE1PORTADO $ "BRV"
		
			//_cDV_BARRA := MODULO11(_cB_Campo,43,1)
			
			_cnCont := 0
			_ccPeso := 2
			For i := 43 To 1 Step -1
				_cnCont += ( Val( SUBSTR( _cB_Campo,i,1 )) * _ccPeso )
				_ccPeso += 1
				If _ccPeso >  9
					_ccPeso := 2
				Endif
			Next
			_cResto  := ( _cnCont % 11 )
			_cResult := _cResto
			_cResult := ( 11 - _cResto )
			Do Case
				Case _cResult == 0 .OR. _cResult == 1 .OR. _cResult > 9
					_cDV_BARRA := "1"
				OtherWise
					_cDV_BARRA := Str(_cResult,1)
			EndCase
				      
		// *** FINAL CHAMADO 050420
			
		Case cE1PORTADO == "246"	// ABC
			_cnCont := 0
			_ccPeso := 2
			For i := 43 To 1 Step -1
				_cnCont += ( Val( SUBSTR( _cB_Campo,i,1 )) * _ccPeso )
				_ccPeso += 1
				If _ccPeso >  9
					_ccPeso := 2
				Endif
			Next
			_cResto  := ( _cnCont % 11 )
			_cResult := _cResto
			_cResult := ( 11 - _cResto )
			Do Case
				Case _cResult == 0 .OR. _cResult == 1 .OR. _cResult > 9
					_cDV_BARRA := "1"
				OtherWise
					_cDV_BARRA := Str(_cResult,1)
			EndCase      
			
		Case cE1PORTADO $ "399/637"	// HSBC
			
			_cnCont := 0
			_ccPeso := 2
			For i := 43 To 1 Step -1
				_cnCont := _cnCont + ( Val( SUBSTR( _cB_Campo,i,1 )) * _ccPeso )
				_ccPeso := _ccPeso + 1
				If _ccPeso >  9
					_ccPeso := 2
				Endif
			Next
			_cResto  := ( _cnCont % 11 )
			_cResult := ( 11 - _cResto )
			Do Case
				Case _cResult == 10 .or. _cResult == 11
					_cDV_BARRA := "1"
				OtherWise
					_cDV_BARRA := Str(_cResult,1)
			EndCase		
			
		Case cE1PORTADO == "033"	// SANTANDER
			
			_cnCont := 0
			_ccPeso := 2
			For i := 43 To 1 Step -1
				_cnCont := _cnCont + ( Val( SUBSTR( _cB_Campo,i,1 )) * _ccPeso )
				_ccPeso := _ccPeso + 1
				If _ccPeso >  9
					_ccPeso := 2
				Endif
			Next
			_cResto  := ( _cnCont % 11 )
			_cResult := ( 11 - _cResto )
			Do Case
				Case _cResult == 0 .OR. _cResult == 1 .OR. _cResult >= 10 
					_cDV_BARRA := "1"
				OtherWise
					_cDV_BARRA := Str(_cResult,1)
			EndCase
	
		Case cE1PORTADO $ "341/655/KOB/ITV"	// ITAU E VOTORANTIM
			
			_cnCont := 0
			_ccPeso := 2
			For i := 43 To 1 Step -1
				_cnCont := _cnCont + ( Val( SUBSTR( _cB_Campo,i,1 )) * _ccPeso )
				_ccPeso := _ccPeso + 1
				If _ccPeso >  9
					_ccPeso := 2
				Endif
			Next
			_cResto  := ( _cnCont % 11 )
			_cResult := ( 11 - _cResto )
			Do Case
				Case _cResult == 0 .OR. _cResult == 1 .OR. _cResult >= 10 
					_cDV_BARRA := "1"
				OtherWise
					_cDV_BARRA := Str(_cResult,1)
			EndCase		
	EndCase

Return

/*
Função de Impressão dos boletos dos bancos 
*/
Static Function IMPBOLETO(aParamIXB)

	Local aAreaSM0 := SM0->(GetArea())

	//Adicionado filial como 01, pq para a empresa a Adoro o CNPJ, tem que ser sempre para a Matriz e para as outras empresas sempre 01 William Costa 16/11/2020
	Private cNome     := ALLTRIM(Posicione("SM0",1,cEmpAnt+'01',"M0_NOMECOM")) + ', ' // alteração chamado 022248 - William Costa
	Private cEndereco := ALLTRIM(Posicione("SM0",1,cEmpAnt+'01',"M0_ENDENT"))  + ', ' // alteração chamado 022248 - William Costa
	Private cBairro   := ALLTRIM(Posicione("SM0",1,cEmpAnt+'01',"M0_BAIRENT")) + ', ' // alteração chamado 022248 - William Costa
	Private cCidade   := ALLTRIM(Posicione("SM0",1,cEmpAnt+'01',"M0_CIDENT"))  + ', ' // alteração chamado 022248 - William Costa
	Private cCNPJ     := ALLTRIM(Posicione("SM0",1,cEmpAnt+'01',"M0_CGC"))            // alteração chamado 022248 - William Costa
	
	Default aParamIXB := {}

	cCNPJ     := transform(cCNPJ,"@R 99.999.999/9999-99")                       // alteração chamado 022248 - William Costa

	// Primeira Parte da Boleta
	
	If cE1PORTADO $ "001/655/KOB" 
	  	
	  	If cE1PORTADO = "KOB"   	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
			oPrint:Saybitmap(0800,0100,"KOB.BMP",0400,200) //APARECE O LOG DA ADORO
		
	    EndIf
		
		oPrint:Say(1139,0100,_cNome_Bco,oFont4Bold,100)
		oPrint:say(1150,0700,_cCod_Comp,oFont6,100)
	Elseif cE1PORTADO $ "399/637"
		oPrint:Say(1135,0100,_cNome_Bco,oFont10Bold,100)  
		oPrint:say(1150,0700,_cCod_Comp,oFont5,100)
	Elseif cE1PORTADO $ "422/SAF/SFF"   // ALEX BORGES 03/04/12
		oPrint:Say(1135,0100,_cNome_Bco,oFont4Bold,100)
		oPrint:say(1150,0700,_cCod_Comp,oFont5,100)	
	
	Elseif cE1PORTADO == "104"   	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
		oPrint:Saybitmap(1135,0100,"cef.BMP",0280,100)
		//oPrint:say(1150,0700,_cCod_Comp,oFont5,100)	
	
	Elseif cE1PORTADO $ "341/ITV"   // itau  - sigoli 13/07/18
		oPrint:Saybitmap(1135,0100,"ITAU.BMP",0280,100)
		//oPrint:say(1150,0700,_cCod_Comp,oFont5,100)	
	
	Else
		oPrint:Say(1135,0100,_cNome_Bco,oFont3Bold,100)
		oPrint:say(1150,0700,_cCod_Comp,oFont5,100)
	Endif	
	
	oPrint:Say(1160,1700,"RECIBO DO PAGADOR",oFont4,100) // alteração chamado 022248 - William Costa
	                            
	oPrint:Box(1230,0100,1310,1500)
	oPrint:Box(1230,1500,1310,2200)
	oPrint:box(1310,0100,1390,1500)
	oPrint:box(1310,1500,1390,2200)
	If cE1PORTADO == '033'
		oPrint:box(1390,0100,1470,0397)	// Data Documento
		oPrint:box(1390,0397,1470,0694)	// Numero Documento
		oPrint:box(1390,0694,1470,0991)	// Esp. Doc.
		oPrint:box(1390,0991,1470,1181) // Aceite
		oPrint:box(1390,1181,1470,1500)	// Data Proces.
		oPrint:box(1390,1500,1470,2200)	// Nosso Numero   
		
		oPrint:box(1470,0100,1550,0650)	// Carteira
		oPrint:box(1470,0500,1550,0650)	// Especie
		oPrint:box(1470,0650,1550,1060)	// Quantidade
		oPrint:box(1470,1060,1550,1500)	// Valor
		oPrint:box(1470,1500,1550,2200)	// Valor Documento
	
	ElseIf cE1PORTADO $ '422/SAF/SFF'  // ALEX BORGES 03/04/12	                
		oPrint:box(1390,0100,1470,0350)	// Data Documento
		oPrint:box(1390,0350,1470,0700)	// Numero Documento
		oPrint:box(1390,0700,1470,0850)	// Esp. Doc.
		oPrint:box(1390,0850,1470,1060) // Aceite
		oPrint:box(1390,1060,1470,1500)	// Data Proces.
		oPrint:box(1390,1500,1470,2200)	// Nosso Numero  
		
		oPrint:box(1470,0100,1550,0350)	// Uso do Banco
		oPrint:box(1470,0350,1550,0400)	// CIP	
		oPrint:box(1470,0400,1550,0500)	// Carteira
		oPrint:box(1470,0500,1550,0650)	// Especie
		oPrint:box(1470,0650,1550,1060)	// Quantidade
		oPrint:box(1470,1060,1550,1500)	// Valor
		oPrint:box(1470,1500,1550,2200)	// Valor Documento
			
	Else
		oPrint:box(1390,0100,1470,0350)	// Data Documento
		oPrint:box(1390,0350,1470,0700)	// Numero Documento
		oPrint:box(1390,0700,1470,0850)	// Esp. Doc.
		oPrint:box(1390,0850,1470,1060) // Aceite
		oPrint:box(1390,1060,1470,1500)	// Data Proces.
		oPrint:box(1390,1500,1470,2200)	// Nosso Numero  
		
		oPrint:box(1470,0100,1550,0350)	// Uso do Banco
		oPrint:box(1470,0350,1550,0500)	// Carteira
		oPrint:box(1470,0500,1550,0650)	// Especie
		oPrint:box(1470,0650,1550,1060)	// Quantidade
		oPrint:box(1470,1060,1550,1500)	// Valor
		oPrint:box(1470,1500,1550,2200)	// Valor Documento
		
	Endif	
		
		oPrint:box(1550,0100,1950,1500)
		oPrint:box(1550,1500,1630,2200)
		oPrint:box(1630,1500,1710,2200)
		oPrint:box(1710,1500,1790,2200)
		oPrint:box(1790,1500,1870,2200)
		oPrint:box(1870,1500,1950,2200)
		oPrint:box(1950,0100,2150,2200)
		
	If cE1PORTADO $ "341/655/KOB/ITV"
		oPrint:say(1230,0120,"Local de Pagamento  " ,oFont1,100)                               
		oPrint:say(1230,0120,"                             ATÉ O VENCIMENTO PAGUE PREFERENCIALMENTE NO ITAÚ",oFont2,100)	
	Else
		oPrint:say(1230,0120,"Local de Pagamento",oFont1,100)
	Endif	
	
	oPrint:say(1230,1520,"Vencimento",oFont1,100)
	
	If cE1PORTADO $ "237/246/RED/BRD/BRV" // *** INICIO CHAMADO 050420
		oPrint:say(1260,0120,"PAGAVEL PREFERENCIALMENTE NAS AGENCIAS DO BRADESCO",oFont2,100)
	
	ElseIf cE1PORTADO $ "399/637"
		oPrint:say(1260,0120,"PAGAR PREFERENCIALMENTE EM AGÊNCIA DO HSBC",oFont2,100)
	
	ElseIf cE1PORTADO == "341/KOB/ITV"	// ITAU
		oPrint:say(1270,0120,"APÓS O VENCIMENTO PAGUE SOMENTE NO ITAÚ",oFont2,100)	
	
	ElseIf cE1PORTADO $ "SAF"	// SAFRA    //ALEX BORGES 03/04/12
		oPrint:say(1260,0120,"Até a data do vencimento pagável em qualquer banco.Após o vencimento, apenas nas agências do Bradesco",oFont1A,100)
	
	ElseIf cE1PORTADO == "001"	    // Banco do Brasil       //Renato, incluido por solicitação do banco em 26/10/2011
		oPrint:say(1260,0120,"PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO",oFont2,100)	
	
	ElseIf cE1PORTADO == "104"		// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
		oPrint:say(1260,0120,"PREFERENCIALMENTE NAS CASAS LOTERICAS ATE O VALOR LIMITE",oFont2,100)	
	
	Else
		oPrint:say(1260,0120,"PAGAVEL EM QUALQUER BANCO ATE A DATA DE VENCIMENTO",oFont2,100)
	Endif
	
	If IsInCallStack("u_GeraRAPV") .or. IsInCallStack("u_GeraBlPV") .or. Len(aParamIXB) > 0 .or. IsInCallStack("u_RunHCRFB")
		_dDtAux1 := DtoS(msDate())
	Else
		_dDtAux1 := TSE1A->E1_VENCTO
	EndIf

	_dDtAux2 := Substr(_dDtAux1,7,2) + "/" + Substr(_dDtAux1,5,2) + "/" + Substr(_dDtAux1,1,4)
	oPrint:say(1260,1930,_dDtAux2,oFont9,100)
	
	oPrint:say(1310,0120,"Beneficiário",oFont1,100) // alteração chamado 022248 - William Costa
	
	If cE1PORTADO == "033"
		oPrint:say(1310,1520,"Agência/Ident.Beneficiário",oFont1,100) // alteração chamado 022248 - William Costa
	Else
		oPrint:say(1310,1520,"Agência/Código Beneficiário",oFont1,100) // alteração chamado 022248 - William Costa
	Endif
	
	If cE1PORTADO == '655'
		oPrint:say(1340,0120,"BANCO VOTORANTIM S/A",oFont2,100)
	ElseIf cE1PORTADO == '637'// 02/09 Alex Borges
		oPrint:say(1340,0120,"BANCO SOFISA S/A",oFont2,100)		
	ElseIf cE1PORTADO $ 'SAF'// ALEX BORGES 03/04/12
		oPrint:say(1340,0120,"BANCO SAFRA S/A",oFont2,100)
	
	ElseIf cE1PORTADO == 'RED' // ALEX BORGES 09/04/12
		oPrint:say(1340,0120,"RED S/A",oFont2,100)
	ElseIf cE1PORTADO == 'KOB'
		//oPrint:say(1340,0120,"KOBOLD FIDC MERC FINANC II          CNPJ - 10.756.703/0001-06",oFont2,100) 
		oPrint:say(1340,0120,"KOBOLD MFS FUNDO INVES EM DIREITOS CREDIT NÃO-PADRONIZADOS CNPJ: 10.756.703/0001-06",oFont2,100)
			
	ElseIf cE1PORTADO == 'BRD'
		oPrint:say(1340,0120,"GMSBS PRESTACOES DE SERVICOS S/A     CNPJ:  13.362.692/0001-60",oFont2,100)	
	ElseIf cE1PORTADO == '104' //   // CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17    
		//oPrint:say(1310,0260,"ADORO S/A                          CNPJ:  60.037.058/0003-01",oFont2,100)	
		//oPrint:say(1340,0120,"Estrada de Acesso SP 053/332 Km 04 – Bairro do Mursa Varzea Paulista/SP",oFont2,100)
		
		oPrint:say(1310,0260,"ADORO S/A                          CNPJ: "+cCNPJ,oFont2,100)	
		oPrint:say(1345,0120,cEndereco+" "+cBairro+" "+cCidade,oFont1,100)
		
	ElseIf cE1PORTADO $ 'SFF/BRV' // fernando sigoli 30/04/2018 // CHAMADO 050420 - WILLIAM COSTA
	 
		oPrint:say(1310,0260,"ADORO S/A                  CNPJ:  60.037.058/0001-31" ,oFont2,100)
		oPrint:say(1345,0120,cEndereco+" "+cBairro+" "+cCidade,oFont1,100) 
		
	Else  

		IF cEmpAnt == '01'                   

			oPrint:say(1310,0260,"ADORO S/A                  CNPJ: "+cCNPJ ,oFont2,100)

		ELSE 
	
			oPrint:say(1310,0260, SUBSTRING(cNome,1,9) + "                  CNPJ: "+cCNPJ ,oFont2,100)


		ENDIF

		oPrint:say(1345,0120,cEndereco+" "+cBairro+" "+cCidade,oFont1,100) 
	        
	EndIF
	                               
	If cE1PORTADO $ '399/637'                         //Renato 08/07/2011
		oPrint:say(1340,1700,IF( cE1PORTADO == '399',ContaHSBC,_cAg_Conta),oFont7,100)
	
	ElseIf cE1PORTADO $ '422/SFF'                            //fernando Sigoli 08/11/2017 - 
		oPrint:say(1340,1700,Substr(_cAg_Conta,1,4)+Substr(_cAg_Conta,6,1)+'/'+padl(Substr(_cAg_Conta,8,6),8,"0")+;
		Substr(_cAg_Conta,15,1),oFont7,100)
			
	ElseIf cE1PORTADO $ '341/ITV'  // fernando Sigoli 13/07/2018
		oPrint:say(1340,1950,_cAg_Conta,oFont7,100)
	
	Else
	
		oPrint:say(1340,1700,_cAg_Conta,oFont7,100)
	
	EndIf	
	
	If cE1PORTADO == '033'
		oPrint:say(1390,0120,"Data do Documento",oFont1,100)
		oPrint:say(1390,0417,"Número Documento",oFont1,100)
		oPrint:say(1390,0714,"Espécie Documento",oFont1,100)
		oPrint:say(1390,1050,"Aceite",oFont1,100)
		oPrint:say(1390,1201,"Data Processamento",oFont1,100)
	Else
		oPrint:say(1390,0120,"Dt Documento",oFont1,100)
		oPrint:say(1390,0360,"Número do Documento",oFont1,100)
		oPrint:say(1390,0720,"Esp.Doc.",oFont1,100)
		oPrint:say(1390,0870,"Aceite",oFont1,100)
		oPrint:say(1390,1080,"Data Processamento",oFont1,100)
	Endif	

	oPrint:say(1390,1520,"Nosso Número",oFont1,100)
	
	If cE1PORTADO == '033'
	
		oPrint:say(1420,0120,DtoC(STOD(TSE1A->E1_EMISSAO)),oFont2,100)
		oPrint:say(1420,0417,Alltrim(TSE1A->E1_PREFIXO) + "-" + Alltrim(TSE1A->E1_NUM) + Iif(!Empty(TSE1A->E1_PARCELA),"-" +TSE1A->E1_PARCELA,""),oFont2,100) // Numero do Documento
	
	Else

		If IsInCallStack("u_GeraRAPV") .or. IsInCallStack("u_GeraBlPV") .or. Len(aParamIXB) > 0 .or. IsInCallStack("u_RunHCRFB")
			oPrint:say(1420,0120,DtoC(msDate()),oFont2,100) // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 18/06/2020
		Else
			oPrint:say(1420,0120,DtoC(STOD(TSE1A->E1_EMISSAO)),oFont2,100)
		EndIf

		oPrint:say(1420,0370,Alltrim(TSE1A->E1_PREFIXO) + "-" + Alltrim(TSE1A->E1_NUM) + Iif(!Empty(TSE1A->E1_PARCELA),"-" +TSE1A->E1_PARCELA,""),oFont2,100) // Numero do Documento
	
	Endif
	
	//correcao da data para dois digitos
		
	If cE1PORTADO $ "399/637"
		oPrint:say(1420,0720,"PD",oFont2,100)
		oPrint:say(1420,0870,"NÃO",oFont2,100)
		oPrint:say(1420,1090,Dtoc(Date()),oFont2,100)	// Reginaldo 12/09/08
		
	ElseIf cE1PORTADO == "033"
		oPrint:say(1420,0714,"DM",oFont2,100)
		oPrint:say(1420,1050,_cAceite,oFont2,100)
		oPrint:say(1420,1201,Dtoc(Date()),oFont2,100)	// Reginaldo 12/09/08
	
	ElseIf cE1PORTADO $ "341/655/KOB/ITV"
		oPrint:say(1420,0714,"DP",oFont2,100)
		oPrint:say(1420,1000,_cAceite,oFont2,100)
		oPrint:say(1420,1201,Dtoc(Date()),oFont2,100)	// Reginaldo 12/09/08	
	
	Else
		oPrint:say(1420,0720,"DM",oFont2,100)
		oPrint:say(1420,0870,_cAceite,oFont2,100)                            
		oPrint:say(1420,1090,Dtoc(Date()),oFont2,100)	// Reginaldo 12/09/08
	
	Endif                           
	
	Do Case
		
		Case cE1PORTADO $ "422/SAF/SFF" // Banco Safra      // ALEX BORGES 03/04/12
			
			_cNBolSaf:= ALLTRIM(_cCarteira)+RIGHT(DTOC(DDATABASE),2)+ALLTRIM(_cNumBoleta)+ALLTRIM(_cDV_NNUM)
	
			_cnContSaf 	:= 0
			_ccPesoSaf 	:= 9
			_cNBolSaf := Alltrim(_cNBolSaf)
	
			nP1Saf := Val(Substr(_cNBolSaf,01,1)) * 2
			nP2Saf := Val(Substr(_cNBolSaf,02,1)) * 7
			nP3Saf := Val(Substr(_cNBolSaf,03,1)) * 6
			nP4Saf := Val(Substr(_cNBolSaf,04,1)) * 5
			nP5Saf := Val(Substr(_cNBolSaf,05,1)) * 4
			nP6Saf := Val(Substr(_cNBolSaf,06,1)) * 3
			nP7Saf := Val(Substr(_cNBolSaf,07,1)) * 2
			nP8Saf := Val(Substr(_cNBolSaf,08,1)) * 7
			nP9Saf := Val(Substr(_cNBolSaf,09,1)) * 6
			nP10Saf := Val(Substr(_cNBolSaf,10,1)) * 5
			nP11Saf := Val(Substr(_cNBolSaf,11,1)) * 4
			nP12Saf := Val(Substr(_cNBolSaf,12,1)) * 3
			nP13Saf := Val(Substr(_cNBolSaf,13,1)) * 2                    
	        
			_nValorSaf := nP1Saf + nP2Saf + nP3Saf + nP4Saf + nP5Saf + nP6Saf + nP7Saf + nP8Saf + nP9Saf + nP10Saf + nP11Saf + nP12Saf + nP13Saf
			_cRestoSaf :=  _nValorSaf % 11 
			If _cRestoSaf == 0
				_cDV_Saf := '0'
			ElseIf _cRestoSaf == 1
				_cDV_Saf := 'P'
			Else
				_cRestoSaf := 11 - _cRestoSaf
				_cDV_Saf := AllTrim(Str(_cRestoSaf))
			EndIf            
				
			If cE1PORTADO $ "422/SFF"
				oPrint:say(1420,1700,ALLTRIM(_cNumBoleta)+ALLTRIM(_cDV_NNUM),oFont7,100)  		
	  		Else
	  		  	oPrint:say(1420,1700,_cCarteira+"/"+Substr(_cNumBoleta,1,11)+"-"+_cDV_NNUM,oFont7,100)
	  		EndIf
	  		
		Case cE1PORTADO $ "237/RED/BRD/BRV" // Bradesco / RED FACTOR // *** INICIO CHAMADO 050420
			oPrint:say(1420,1700,_cCarteira+"/"+Substr(_cNumBoleta,1,11)+"-"+_cDV_NNUM,oFont7,100)
	
		Case cE1PORTADO == "246" // ABC
			oPrint:say(1420,1700,_cCarteira+"/"+Substr(_cNumBoleta,1,11)+"-"+_cDV_NNUM,oFont7,100)
	
		Case cE1PORTADO == '001' // Banco do Brasil 
		    //Mauricio 19/10/11 - Substituido para impressao sem digito do nosso numero conforme solicitado Sr.Renato/Reginaldo.
			//oPrint:Say(1420,1700,_cNumBoleta+"-"+_cDV_NNUM,oFont7,100)
			oPrint:Say(1420,1700,_cNumBoleta,oFont7,100)
	
		Case cE1PORTADO == "033" // SANTANDER
			oPrint:Say(1420,1700,Substr(_cNumBoleta,6,7)+" "+_cDV_NNUM,oFont7,100) 		
	
		Case cE1PORTADO $ "399/637" // HSBC
			oPrint:Say(1420,1700,_cNumBoleta+"-"+_cDV_NNUM,oFont7,100) 
	
		Case cE1PORTADO $ "655/KOB" // ITAU E VOTORANTIM
			oPrint:Say(1420,1700,"109" + "/" + _cNumBoleta+"-"+_cDV_NNUM,oFont7,100) 	// 102 E A CARTEIRA ? VERIFICAR NO SUPORTE
	    
	    Case cE1PORTADO $ "341/ITV" // ITAU 13/07/2018 
			oPrint:Say(1420,1910,"109" + "/" + _cNumBoleta+"-"+_cDV_NNUM,oFont7,100) 
		
		Case cE1PORTADO == "104"  // CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
			oPrint:say(1420,1700,Substr(_cNumBoleta,1,17)+"-"+_cDV_NNUM,oFont7,100)
			 
	EndCase
	
	If cE1PORTADO == "033"
	
		oPrint:say(1470,0120,"Carteira",oFont1,100)
		oPrint:say(1470,0520,"Espécie",oFont1,100)
		oPrint:say(1470,0670,"Quantidade",oFont1,100)
		oPrint:say(1470,1090,"Valor",oFont1,100)     
	
	ElseIf cE1PORTADO $ "422/SAF/SFF"   //Renato 26/01/12 add CIP
		oPrint:say(1470,0120,"Data de Operação",oFont1,100)
	    oPrint:say(1470,0360,"CIP",oFont1,100)
		oPrint:say(1470,0405,"Carteira",oFont1,100)
		oPrint:say(1470,0520,"Espécie",oFont1,100)
		oPrint:say(1470,0670,"Quantidade",oFont1,100)
		oPrint:say(1470,1090,"Valor",oFont1,100)     
	
	Else
		oPrint:say(1470,0120,"Uso do Banco",oFont1,100)
		oPrint:say(1470,0370,"Carteira",oFont1,100)
		oPrint:say(1470,0520,"Espécie",oFont1,100)
		oPrint:say(1470,0670,"Quantidade",oFont1,100)
		oPrint:say(1470,1090,"Valor",oFont1,100)     
	
	Endif	                
	
	oPrint:say(1470,1520,"(=) Valor do Documento",oFont1,100)
	If cE1PORTADO == "033"
	
		oPrint:say(1500,120,"SIMPLES - RCR",oFont2,100)
		oPrint:say(1500,520,"REAL",oFont2,100)
	
	ElseIf cE1PORTADO $ "422/SAF/SFF"  //ALEX BORGES 03/04/12
	//ElseIf cE1PORTADO == "422"
		oPrint:say(1500,120,Dtoc(dDataBase),oFont2,100)
	    oPrint:say(1500,350,"130",oFont2,100)
		oPrint:say(1500,410,_cCarteira,oFont2,100)
		oPrint:say(1500,520,"R$",oFont2,100)
	
	Else
	
		oPrint:say(1500,370,_cCarteira,oFont2,100)
		oPrint:say(1500,520,"R$",oFont2,100)
	
	Endif	
	
	oPrint:say(1500,1900,Transform(_nVlrBol,"@E 999,999,999.99"),oFont9,100)
	oPrint:say(1550,120,"Instruções",oFont1,100)
	oPrint:say(1550,120,"                 " + "(Todas as informações deste bloqueto são de exclusiva responsabilidade do Beneficiário)",oFont1A,100) // alteração chamado 022248 - William Costa
	
	If cE1PORTADO == "033"
		oPrint:say(1550,1520,"(-) Desconto",oFont1,100)
	Else
		oPrint:say(1550,1520,"(-) Desconto/Abatimento",oFont1,100)
	Endif
	
	If !cE1PORTADO $ "001/237/246/422/SFF/SAF/RED/BRD/104/341/BRV/ITV" 	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17 // *** INICIO CHAMADO 050420
		oPrint:say(1580,1750,Transform(_nVlrAbat,"@E 999,999,999.99"),oFont7,100)
	Endif
		
	If cE1PORTADO == "033"
		oPrint:say(1630,1520,"(-) Abatimento",oFont1,100)
		oPrint:say(1710,1520,"(+) Mora",oFont1,100)     
	ElseIf cE1PORTADO $ "655"
		oPrint:say(1630,1520,"",oFont1,100)     
		oPrint:say(1710,1520,"(+) Mora/Multa",oFont1,100)
	Else
		oPrint:say(1630,1520,"(-) Outras Deduções",oFont1,100)     
		oPrint:say(1710,1520,"(+) Mora/Multa",oFont1,100)
	Endif	
	
	If !(cE1PORTADO $ "655") 
		oPrint:say(1790,1520,"(+) Outros Acréscimos",oFont1,100)
	EndIf	
	
	oPrint:say(1870,1520,"(=) Valor Cobrado",oFont1,100)
	oPrint:say(1950,0120,"Pagador",oFont1,100) // alteração chamado 022248 - William Costa
	oPrint:say(1970,0250,TSE1A->A1_NOME,oFont8,100)
	oPrint:say(1970,1500,transform(TSE1A->A1_CGC,"@R 99.999.999/9999-99"),oFont8,100)
	oPrint:say(2010,0250,TSE1A->A1_ENDCOB+" "+TSE1A->A1_BAIRROC,oFont8,100)
	oPrint:say(2050,0250,TSE1A->A1_CEPC+" "+TSE1A->A1_MUNC+TSE1A->A1_ESTC,oFont8,100)
	oPrint:say(2100,0120,"Sacador/Avalista",oFont1,100) // alteração chamado 022248 - William Costa
	If cE1PORTADO != "033"
		oPrint:say(2100,1520,"Cód.Baixa",oFont1,100)
		oPrint:say(2095,1720,"Autenticação Mecânica",oFont1,100)
	Endif	       
	//Incluido 26/04/11
	If cE1PORTADO $ "655/637/SAF/KOB/RED/BRD" // 02/09 - Alex Borges 
	            
	    oPrint:say(2100,0400, cNome + cEndereco + cCidade + cCNPJ ,oFont1,100) // alteração chamado 022248 - William Costa
	    
	Endif 
	
	If cE1PORTADO $ "SAF" // ALEX BORGES 03/04/12
		oPrint:say(2100,0400,"GMSBS PRESTACOES DE SERVICOS S/A     CNPJ:  13.362.692/0001-60",oFont1,100)
	Endif	
	
	oPrint:say(2140,0001,replicate(".",1900),oFont1,100)
	
	// Impressao das Instrucoes
	                                                         
	_nLinInst := 1580 // 1280 // 000480 -> Aqui
	If !(cE1PORTADO $ "655/422/SFF/KOB/SAF")   //INCLUIDO 655 (VOTORANTIM) 26/04/11 e 422 em 26/01/12  e SAF em 03/04/12
	
		oPrint:say(_nLinInst,0120,"*** VALORES EXPRESSOS EM REAIS *** ",oFont8,100)	// Instruções  
		
	Endif	                 
	
	_nLinInst += 50
	
	If cE1PORTADO == "246" // Tratamento BANCO ABC
		oPrint:say(_nLinInst,0120,"Título transferido ao Banco ABC Brasil S/A.",oFont8,100)	// Instruções 
	EndIf
	_nLinInst += 00050                
	                               
	//Incluido 26/04/11
	If cE1PORTADO == '655'                                    
		oPrint:Say(_nLinInst,0120,"Titulo entregue em cessão fiduciaria em favor do beneficiário acima" ,oFont8,100) // alteração chamado 022248 - William Costa
		_nLinInst += 00050	
	End IF
	
	//If cE1PORTADO $ "422/SAF"       
	//If cE1PORTADO == '422' 
	If cE1PORTADO $ "SAF/SFF"
		
		If SEE->EE_ZZMORA > 0	
			nValMora := ( _nVlrBol * ( SEE->EE_ZZMORA / 100) ) / 30 	
			oPrint:Say(_nLinInst,0120,"Não dispensar mora de R$ " + Alltrim(Transform(nValMora,"@E 999,999,999.99")) + " por dia de atraso" ,oFont8,100)
			_nLinInst += 00050
		Endif
	
		If SEE->EE_ZZDIAAT > 0 .AND. SEE->EE_ZZPERMU > 0
			oPrint:Say(_nLinInst,0120,"Após o vencimento cobrar multa de R$ " + Alltrim(Transform(_nVlrBol * (SEE->EE_ZZPERMU/100),"@E 999,999,999.99")),oFont8,100)
			_nLinInst += 00050
		Endif                  
		
		If TSE1A->A1_ZZDESCB > 0 .AND. TSE1A->E1_TIPO <> 'NDC'
		  
			oPrint:Say(_nLinInst,0120,"Conceder desconto de R$ " + Alltrim(Transform(ROUND(_nVlrBol * (TSE1A->A1_ZZDESCB/100),2),"@E 999,999.99")),oFont8,100) //Chamado: 048733 Fernando Sigoli 29/04/2019
			_nLinInst += 00050

		Endif
		
		If SEE->EE_ZZDDPRO > 0
			//oPrint:Say(_nLinInst,0120,"Após " + Strzero(SEE->EE_ZZDDPRO,2) + " dias do vencimento, protestar o titulo ",oFont8,100)
			oPrint:Say(_nLinInst,0120,"SUJEITO A PROTESTO APÓS O VENCIMENTO" ,oFont8,100) //tkt 7075 -  Fernando Sigoli - Alteração da instrução de protesto
			_nLinInst += 00050
		Endif
	
		
		If cE1PORTADO == 'SAF' 
			_nLinInst += 00025
			oPrint:Say(_nLinInst,0120,"BOLETO REFERENTE A NF "+ Alltrim(TSE1A->E1_NUM) + Iif(!Empty(TSE1A->E1_PARCELA),"-" +TSE1A->E1_PARCELA,"")+" EMITIDA POR AD'ORO S/A",oFont8Bold,100)
			_nLinInst += 00050
		Endif	
		//
		If cE1PORTADO = "SFF" 
			_nLinInst += 00025
			oPrint:Say(_nLinInst,0120,"ESTE BOLETO REPRESENTA DUPLICATA CEDIDA FIDUCIARIAMENTE ",oFont8,100)
			_nLinInst += 00040
			oPrint:Say(_nLinInst,0120,"AO BANCO SAFRA S/A,VEDADO O PAGAMENTO DE QUALQUER OUTRA ",oFont8,100) 
			_nLinInst += 00040
			oPrint:Say(_nLinInst,0120,"FORMA QUE NÃO ATRAVÉS DO PRESENTE BOLETO",oFont8,100)
			_nLinInst += 00040
		Endif	
	
	ElseIf cE1PORTADO == 'KOB' 
	    
		If SEE->EE_ZZMORA > 0	
			nValMora := ( _nVlrBol * ( SEE->EE_ZZMORA / 100) ) / 30 	
			oPrint:Say(_nLinInst,0120,"APÓS O VENCIMENTO COBRAR MORA DE R$ " + Alltrim(Transform(nValMora,"@E 999,999,999.99")) + " AO DIA" ,oFont8,100)
			_nLinInst += 00050 
			oPrint:Say(_nLinInst,0120,"DIREITO DE CREDITO CEDIDO AO BENEFICIÁRIO - PAGAVEL SOMENTE EM BANCO" ,oFont8,100)
			_nLinInst += 00050
			oPrint:Say(_nLinInst,0120,"COBRANCA ESCRITURAL" ,oFont8,100)
			_nLinInst += 00050 
			oPrint:Say(_nLinInst,0120,"SUJEITO A PROTESTO APÓS O VENCIMENTO" ,oFont8,100) //Everson - 11/08/2020. Chamado 060193.
			_nLinInst += 00050						
		Endif                  
		
		If TSE1A->A1_ZZDESCB > 0 .AND. TSE1A->E1_TIPO <> 'NDC'
		  
			oPrint:Say(_nLinInst,0120,"Conceder desconto de R$ " + Alltrim(Transform(ROUND(_nVlrBol * (TSE1A->A1_ZZDESCB/100),2),"@E 999,999.99")),oFont8,100) //Chamado: 048733 Fernando Sigoli 29/04/2019
			_nLinInst += 00050

		Endif
		
	ElseIf cE1PORTADO $ '341/ITV'  //fernando sigoli 13/07/2018
	
		If SEE->EE_ZZMORA > 0	
			nValMora := ( _nVlrBol * ( SEE->EE_ZZMORA / 100) ) / 30 	
			oPrint:Say(_nLinInst,0120,"Após o vencimento cobrar mora de R$ " + Alltrim(Transform(nValMora,"@E 999,999,999.99")) + " ao dia" ,oFont8,100)
			_nLinInst += 00050
		Endif
	
		If SEE->EE_ZZDDPRO > 0
			//oPrint:Say(_nLinInst,0120,"Após " + Strzero(SEE->EE_ZZDDPRO,2) + " dias do vencimento, protestar o titulo ",oFont8,100)
			oPrint:Say(_nLinInst,0120,"SUJEITO A PROTESTO APÓS O VENCIMENTO" ,oFont8,100) //tkt 7075 -  Fernando Sigoli - Alteração da instrução de protesto
			_nLinInst += 00050
		Endif
	
		If SEE->EE_ZZDIAAT > 0 .AND. SEE->EE_ZZPERMU > 0
			oPrint:Say(_nLinInst,0120,"Após o " + Alltrim(Str(SEE->EE_ZZDIAAT)) + "° dia útil do vencimento cobrar multa de " + Transform(SEE->EE_ZZPERMU,"@E 999,999.99") + "%",oFont8,100)
			_nLinInst += 00050
		Endif
	
		If TSE1A->A1_ZZDESCB > 0 .AND. TSE1A->E1_TIPO <> 'NDC'
		  
			oPrint:Say(_nLinInst,0120,"Conceder desconto de R$ " + Alltrim(Transform(ROUND(_nVlrBol * (TSE1A->A1_ZZDESCB/100),2),"@E 999,999.99")),oFont8,100) //Chamado: 048733 Fernando Sigoli 29/04/2019
			_nLinInst += 00050

		Endif
	
	Else
	
		If SEE->EE_ZZMORA > 0	
			nValMora := ( _nVlrBol * ( SEE->EE_ZZMORA / 100) ) / 30 	
			oPrint:Say(_nLinInst,0120,"Após o vencimento mora dia: " + Transform(nValMora,"@E 999,999,999.99") ,oFont8,100)
			_nLinInst += 00050
		Endif
	
		If SEE->EE_ZZDDPRO > 0
			//oPrint:Say(_nLinInst,0120,"Após " + Strzero(SEE->EE_ZZDDPRO,2) + " dias do vencimento, protestar o titulo ",oFont8,100)
			oPrint:Say(_nLinInst,0120,"SUJEITO A PROTESTO APÓS O VENCIMENTO" ,oFont8,100) //tkt 7075 -  Fernando Sigoli - Alteração da instrução de protesto
			_nLinInst += 00050
		Endif
	
		If SEE->EE_ZZDIAAT > 0 .AND. SEE->EE_ZZPERMU > 0
			oPrint:Say(_nLinInst,0120,"Após o " + Alltrim(Str(SEE->EE_ZZDIAAT)) + "° dia útil do vencimento cobrar multa de " + Transform(SEE->EE_ZZPERMU,"@E 999,999.99") + "%",oFont8,100)
			_nLinInst += 00050
		Endif
	
		If TSE1A->A1_ZZDESCB > 0 .AND. TSE1A->E1_TIPO <> 'NDC'
		  
			oPrint:Say(_nLinInst,0120,"Conceder desconto de R$ " + Alltrim(Transform(ROUND(_nVlrBol * (TSE1A->A1_ZZDESCB/100),2),"@E 999,999.99")),oFont8,100) //Chamado: 048733 Fernando Sigoli 29/04/2019
			_nLinInst += 00050

		Endif
		
		If cE1PORTADO == 'BRD' 
			_nLinInst += 00025
			oPrint:Say(_nLinInst,0120,"BOLETO REFERENTE A NF "+ Alltrim(TSE1A->E1_NUM) + Iif(!Empty(TSE1A->E1_PARCELA),"-" +TSE1A->E1_PARCELA,"")+" EMITIDA POR AD'ORO S/A",oFont8Bold,100)
			_nLinInst += 00050
		Endif	
		
		  
	Endif
	
	oPrint:say(_nLinInst,0120,mv_par09,oFont8,100)	// Instruções de parametro
	_nLinInst += 50
	oPrint:say(_nLinInst,0120,mv_par10,oFont8,100)  	// Instruções de parametro
	
	//Terceira parte da Boleta
	
	//Montar a Linha Digitavel da Boleta
	MontaLinha()
	
	
	//Segunda Parte da Boleta
	
	If cE1PORTADO $ "001/655/KOB" 
		oPrint:Say(002198,0100,_cNome_Bco,oFont4Bold,100)
		oPrint:say(002210,0580,_cCod_Comp,oFont6,100)
	Elseif cE1PORTADO $ "399/637"
		oPrint:Say(002195,0100,_cNome_Bco,oFont10Bold,100)   
		oPrint:say(002210,0570,_cCod_Comp,oFont5,100)	
	Elseif cE1PORTADO $ "422/SAF/SFF"
		oPrint:Say(002195,0100,_cNome_Bco,oFont4Bold,100)   
		oPrint:say(002210,0570,_cCod_Comp,oFont5,100)		
	
	Elseif cE1PORTADO =="104"	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
		oPrint:Saybitmap(002195,0100,"cef.BMP",0280,100)   
		oPrint:say(002210,0590,_cCod_Comp,oFont5,100)		
		
	Elseif cE1PORTADO $ "341/ITV"      // itau  - sigoli 13/07/18
		oPrint:Saybitmap(002195,0100,"ITAU.BMP",0280,100)   
		oPrint:say(002210,0590,_cCod_Comp,oFont5,100)		
		
	Else 
		oPrint:Say(002195,0100,_cNome_Bco,oFont3Bold,100)
		oPrint:say(002210,0570,_cCod_Comp,oFont6,100)
	Endif	
	                       
	//Impressão da Linha Digitavel
	oPrint:Say(002220,0770,_cLineDig,oFont9,080)  
	                           
	oPrint:Box(002290,0100,2370,1500)
	oPrint:Box(002290,1500,2370,2200)
	oPrint:box(002370,0100,2450,1500)
	oPrint:box(002370,1500,2450,2200)   
	
	If cE1PORTADO == '033'
	
		oPrint:box(002450,0100,2530,0397)	// Data Documento
		oPrint:box(002450,0397,2530,0694)	// Numero Documento
		oPrint:box(002450,0694,2530,0991)	// Esp. Doc.
		oPrint:box(002450,0991,2530,1181)	// Aceite
		oPrint:box(002450,1181,2530,1500)	// Data Proces.
		oPrint:box(002450,1500,2530,2200)	// Nosso Numero   
		
		oPrint:box(002530,0100,2610,0500)	// Carteira
		oPrint:box(002530,0500,2610,0650)	// Especie
		oPrint:box(002530,0650,2610,1060)	// Quantidade
		oPrint:box(002530,1060,2610,1500)	// Valor
		oPrint:box(002530,1500,2610,2200)	// Valor Documento    
		
	ElseIf cE1PORTADO $ '422/SAF/SFF'
	//ElseIf cE1PORTADO == '422'
		oPrint:box(002450,0100,2530,0350)	
		oPrint:box(002450,0350,2530,0700)
		oPrint:box(002450,0700,2530,0850)
		oPrint:box(002450,0850,2530,1060)
		oPrint:box(002450,1060,2530,1500)
		oPrint:box(002450,1500,2530,2200)
		oPrint:box(002530,0100,2610,0350)
		oPrint:box(002530,0350,2610,0400)	
		oPrint:box(002530,0400,2610,0500)
		oPrint:box(002530,0500,2610,0650)
		oPrint:box(002530,0650,2610,1060)
		oPrint:box(002530,1060,2610,1500)
		oPrint:box(002530,1500,2610,2200)	
	Else
	
		oPrint:box(002450,0100,2530,0350)
		oPrint:box(002450,0350,2530,0700)
		oPrint:box(002450,0700,2530,0850)
		oPrint:box(002450,0850,2530,1060)
		oPrint:box(002450,1060,2530,1500)
		oPrint:box(002450,1500,2530,2200)
		oPrint:box(002530,0100,2610,0350)
		oPrint:box(002530,0350,2610,0500)
		oPrint:box(002530,0500,2610,0650)
		oPrint:box(002530,0650,2610,1060)
		oPrint:box(002530,1060,2610,1500)
		oPrint:box(002530,1500,2610,2200)
	
	Endif         
	
	oPrint:box(002610,0100,3010,1500)
	oPrint:box(002610,1500,2690,2200)
	oPrint:box(002690,1500,2770,2200)
	oPrint:box(002770,1500,2850,2200)
	oPrint:box(002850,1500,2930,2200)
	oPrint:box(002930,1500,3010,2200)
	oPrint:box(003010,0100,3210,2200)
	
	If cE1PORTADO $ "341/655/KOB/ITV"                                     
		oPrint:say(002290,0120,"Local de Pagamento",oFont1,100)
		oPrint:say(002290,0120,"                               ATÉ O VENCIMENTO PAGUE PREFERENCIALMENTE NO ITAÚ",oFont2,100)	
	Else	
		oPrint:say(002290,0120,"Local de Pagamento",oFont1,100)
	Endif	
	oPrint:say(002290,1520,"Vencimento",oFont1,100)
	If cE1PORTADO $ "237/246/RED/BRD/BRV" // *** INICIO CHAMADO 050420
		oPrint:say(002320,0120,"PAGAVEL PREFERENCIALMENTE NAS AGENCIAS DO BRADESCO",oFont2,100)
	ElseIf cE1PORTADO $ "399/637"
		oPrint:say(002320,0120,"PAGAR PREFERENCIALMENTE EM AGÊNCIA DO HSBC",oFont2,100)	
	ElseIf 	cE1PORTADO $ "341/655/KOB/ITV"	// ITAU
		oPrint:say(002320,0120,"APÓS O VENCIMENTO PAGUE SOMENTE NO ITAÚ",oFont2,100)		
	ElseIf cE1PORTADO $ "SAF"	// SAFRA                //ALEX BORGES 03/04/12
		oPrint:say(002320,0120,"Até a data do vencimento pagável em qualquer banco. Após o vencimento, apenas nas agências do Bradesco",oFont1A,100)	
	ElseIf cE1PORTADO == "001"	// Banco do Brasil       //Renato, incluido por solicitação do banco em 26/10/2011
		oPrint:say(002320,0120,"PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO",oFont2,100)
	ElseIf cE1PORTADO == "104"	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
		oPrint:say(002320,0120,"PREFERENCIALMENTE NAS CASAS LOTERICAS ATE O VALOR LIMITE",oFont2,100)
	Else
		oPrint:say(002320,0120,"PAGAVEL EM QUALQUER BANCO ATE A DATA DE VENCIMENTO",oFont2,100)
	Endif
	
	If IsInCallStack("u_GeraRAPV") .or. IsInCallStack("u_GeraBlPV") .or. Len(aParamIXB) > 0 .or. IsInCallStack("u_RunHCRFB")
		_dDtAux1 := DtoS(msDate())
	Else
		_dDtAux1 := TSE1A->E1_VENCTO
	EndIf

	_dDtAux2 := Substr(_dDtAux1,7,2) + "/" + Substr(_dDtAux1,5,2) + "/" + Substr(_dDtAux1,1,4)
	oPrint:say(002320,1930,_dDtAux2,oFont9,100)
	
	oPrint:say(002370,0120,"Beneficiário",oFont1,100) // alteração chamado 022248 - William Costa
	
	If cE1PORTADO == "033"
		oPrint:say(002370,1520,"Agência/Ident.Beneficiário",oFont1,100) // alteração chamado 022248 - William Costa
	Else
		oPrint:say(002370,1520,"Agência/Código Beneficiário",oFont1,100) // alteração chamado 022248 - William Costa
	Endif	
	
	//oPrint:say(002400,0120,"ADORO S/A",oFont2,100) --Alterado 26/04/11
	If cE1PORTADO == '655'
		oPrint:say(002400,0120,"BANCO VOTORANTIM S/A",oFont2,100)
	ElseIf cE1PORTADO == '637'//02/09 - Alex Borges
		oPrint:say(002400,0120,"BANCO SOFISA S/A",oFont2,100)
	ElseIf cE1PORTADO $ 'SAF'  // ALEX BORGES 03/04/12
	//ElseIf cE1PORTADO == '422'
		oPrint:say(002400,0120,"BANCO SAFRA S/A",oFont2,100)  
	ElseIf cE1PORTADO == 'RED' // ALEX BORGES 09/04/12
		oPrint:say(002400,0120,"RED S/A",oFont2,100)	
	ElseIf cE1PORTADO == 'KOB'
		//oPrint:say(002400,0120,"KOBOLD FIDC MERC FINANC II          CNPJ - 10.756.703/0001-06",oFont2,100)
		oPrint:say(002400,0120,"KOBOLD MFS FUNDO INVES EM DIREITOS CREDIT NÃO-PADRONIZADOS CNPJ: 10.756.703/0001-06",oFont2,100)
			
	
	ElseIf cE1PORTADO == 'BRD'
		oPrint:say(002400,0120,"GMSBS PRESTACOES DE SERVICOS S/A    CNPJ:  13.362.692/0001-60",oFont2,100)	
	
	ElseIf cE1PORTADO == '104'	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
	  
		oPrint:say(002370,0260,"ADORO S/A                  CNPJ: "+cCNPJ,oFont2,100)
		oPrint:say(002405,0120,cEndereco+" "+cBairro+" "+cCidade,oFont1,100)
	
	ElseIf cE1PORTADO = 'SFF'	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
	  
		oPrint:say(002370,0260,"ADORO S/A                  CNPJ: 60.037.058/0001-31 "+cCNPJ,oFont2,100)
		oPrint:say(002405,0120,cEndereco+" "+cBairro+" "+cCidade,oFont1,100)
		
	ElseIf cE1PORTADO = 'BRV'	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
	  
		oPrint:say(002370,0260,"ADORO S/A                  CNPJ: 60.037.058/0001-31 ",oFont2,100)
		oPrint:say(002405,0120,cEndereco+" "+cBairro+" "+cCidade,oFont1,100)	
	     
	Else
		//oPrint:say(002400,0120,"ADORO S/A",oFont2,100)  

		IF cEmpAnt == '01'                   

			oPrint:say(002370,0260,"ADORO S/A                  CNPJ: "+cCNPJ ,oFont2,100)

		ELSE 
	
			oPrint:say(002370,0260,SUBSTRING(cNome,1,9) + "                  CNPJ: "+cCNPJ ,oFont2,100)
			
		ENDIF

		oPrint:say(002405,0120,cEndereco+" "+cBairro+" "+cCidade,oFont1,100) 
	
	EndIF
	                                             
	If cE1PORTADO $ '399/637'
		oPrint:say(002400,1700,IF( cE1PORTADO == '399',ContaHSBC,_cAg_Conta),oFont7,100)
	
	ElseIf cE1PORTADO $ '422/SFF'                            //fernando Sigoli 08/11/2017 - 
		oPrint:say(002400,1700,Substr(_cAg_Conta,1,4)+Substr(_cAg_Conta,6,1)+'/'+padl(Substr(_cAg_Conta,8,6),8,"0")+;
		Substr(_cAg_Conta,15,1),oFont7,100)
	
	ElseIf cE1PORTADO $ 'SAF'
		oPrint:say(002400,1700,"3114-3/0176300-8",oFont7,100)
	
	ElseIf cE1PORTADO $ '341/ITV'  // fernando Sigoli 13/07/2018
		oPrint:say(002400,1950,_cAg_Conta,oFont7,100)
	Else
		oPrint:say(002400,1700,_cAg_Conta,oFont7,100)
	
	EndIf	
	
	If cE1PORTADO == '033'
		oPrint:say(002450,0120,"Data do Documento",oFont1,100)
		oPrint:say(002450,0417,"Número Documento",oFont1,100)
		oPrint:say(002450,0714,"Espécie Documento",oFont1,100)
		oPrint:say(002450,1050,"Aceite",oFont1,100)
		oPrint:say(002450,1201,"Data Processamento",oFont1,100)
	ElseIf cE1PORTADO $ '422/SAF/SFF'   // ALEX BORGES 03/04/12
	//ElseIf cE1PORTADO == '422'   // Renato add 26/01/12
		oPrint:say(002450,0120,"Dt Documento",oFont1,100)
		oPrint:say(002450,0370,"Número do Documento",oFont1,100)
		oPrint:say(002450,0720,"Esp.Doc.",oFont1,100)
		oPrint:say(002450,0870,"Aceite",oF`ont1,100)
		oPrint:say(002450,1080,"Data Movimento",oFont1,100)
	Else
		oPrint:say(002450,0120,"Dt Documento",oFont1,100)
		oPrint:say(002450,0370,"Número do Documento",oFont1,100)
		oPrint:say(002450,0720,"Esp.Doc.",oFont1,100)
		oPrint:say(002450,0870,"Aceite",oF`ont1,100)
		oPrint:say(002450,1080,"Data Processamento",oFont1,100)
	Endif                                                     
	
	oPrint:say(002450,1520,"Nosso Número",oFont1,100)
	                                                               
	If cE1PORTADO == '033'

		oPrint:say(002480,0120,DtoC(STOD(TSE1A->E1_EMISSAO)),oFont2,100)
		oPrint:say(002480,0417,Alltrim(TSE1A->E1_PREFIXO) + "-" + Alltrim(TSE1A->E1_NUM) + Iif(!Empty(TSE1A->E1_PARCELA),"-" +TSE1A->E1_PARCELA,""),oFont2,100) // Numero do Documento
	
	Else

		If IsInCallStack("u_GeraRAPV") .or. IsInCallStack("u_GeraBlPV") .or. Len(aParamIXB) > 0 .or. IsInCallStack("u_RunHCRFB")
			oPrint:say(002480,0120,DtoC(msDate()),oFont2,100) // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 18/06/2020
		Else
			oPrint:say(002480,0120,DtoC(STOD(TSE1A->E1_EMISSAO)),oFont2,100)
		EndIf

		oPrint:say(002480,0370,Alltrim(TSE1A->E1_PREFIXO) + "-" + Alltrim(TSE1A->E1_NUM) + Iif(!Empty(TSE1A->E1_PARCELA),"-" +TSE1A->E1_PARCELA,""),oFont2,100) // Numero do Documento
	
	Endif	
	
	If cE1PORTADO $ "399/637"
		oPrint:say(002480,0720,"PD",oFont2,100)
		oPrint:say(002480,0870,"NÃO",oFont2,100)
		oPrint:say(002480,1090,Dtoc(Date()),oFont2,100)
	
	ElseIf cE1PORTADO == "033"  
	
		oPrint:say(002480,0714,"DM",oFont2,100)
		oPrint:say(002480,1050,_cAceite,oFont2,100)
		oPrint:say(002480,1201,Dtoc(Date()),oFont2,100)	// Reginaldo 12/09/08	
	
	ElseIf cE1PORTADO $ "341/655/KOB/ITV"
	
		oPrint:say(002480,0714,"DP",oFont2,100)
		oPrint:say(002480,1000,_cAceite,oFont2,100)
		oPrint:say(002480,1201,Dtoc(Date()),oFont2,100)	// Reginaldo 12/09/08		
	
	Else
		oPrint:say(002480,0720,"DM",oFont2,100)
		oPrint:say(002480,0870,_cAceite,oFont2,100)
		oPrint:say(002480,1090,Dtoc(Date()),oFont2,100)
	
	Endif
	
	Do Case
	    Case cE1PORTADO $ "422/SAF/SFF" // Banco Safra    //ALEX BORGES 03/04/12 
			
			_cNBolSaf	:= ALLTRIM(_cCarteira)+RIGHT(DTOC(DDATABASE),2)+ALLTRIM(_cNumBoleta)+ALLTRIM(_cDV_NNUM)
	
			_cnContSaf 	:= 0
			_ccPesoSaf 	:= 9
			_cNBolSaf 	:= Alltrim(_cNBolSaf)
	
			nP1Saf := Val(Substr(_cNBolSaf,01,1)) * 2
			nP2Saf := Val(Substr(_cNBolSaf,02,1)) * 7
			nP3Saf := Val(Substr(_cNBolSaf,03,1)) * 6
			nP4Saf := Val(Substr(_cNBolSaf,04,1)) * 5
			nP5Saf := Val(Substr(_cNBolSaf,05,1)) * 4
			nP6Saf := Val(Substr(_cNBolSaf,06,1)) * 3
			nP7Saf := Val(Substr(_cNBolSaf,07,1)) * 2
			nP8Saf := Val(Substr(_cNBolSaf,08,1)) * 7
			nP9Saf := Val(Substr(_cNBolSaf,09,1)) * 6
			nP10Saf := Val(Substr(_cNBolSaf,10,1)) * 5
			nP11Saf := Val(Substr(_cNBolSaf,11,1)) * 4
			nP12Saf := Val(Substr(_cNBolSaf,12,1)) * 3
			nP13Saf := Val(Substr(_cNBolSaf,13,1)) * 2                    
	        
			_nValorSaf := nP1Saf + nP2Saf + nP3Saf + nP4Saf + nP5Saf + nP6Saf + nP7Saf + nP8Saf + nP9Saf + nP10Saf + nP11Saf + nP12Saf + nP13Saf
			_cRestoSaf :=  _nValorSaf % 11 
			
			If _cRestoSaf == 0
				_cDV_Saf := '0'
			
			ElseIf _cRestoSaf == 1
				_cDV_Saf := 'P'
			
			Else
				_cRestoSaf := 11 - _cRestoSaf
				_cDV_Saf := AllTrim(Str(_cRestoSaf))
			EndIf            
			
			If cE1PORTADO $ "422/SFF"		
				oPrint:say(2480,1700, ALLTRIM(_cNumBoleta)+ALLTRIM(_cDV_NNUM) ,oFont7,100)  				
			Else
				oPrint:Say(2480,1700,_cCarteira+"/"+SubStr(_cNumBoleta,1,11)+"-"+_cDV_NNUM,oFont7,100)
			EndIf
		
		Case cE1PORTADO $ "237/RED/BRD/BRV" // Bradesco / RED FACTOR // CHAMADO 050420
			oPrint:say(2480,1700,_cCarteira+"/"+Substr(_cNumBoleta,1,11)+"-"+_cDV_NNUM,oFont7,100)		
		
		Case cE1PORTADO == "246" // ABC
			oPrint:say(2480,1700,_cCarteira+"/"+Substr(_cNumBoleta,1,11)+"-"+_cDV_NNUM,oFont7,100)
		
		Case cE1PORTADO == '001' // Banco do Brasil 
		    //Mauricio 19/10/11 - Substituido para impressao sem digito do nosso numero conforme solicitado Sr.Renato/Reginaldo.
			//oPrint:Say(2480,1700,_cNumBoleta+"-"+_cDV_NNUM,oFont7,100) 
			oPrint:Say(2480,1700,_cNumBoleta,oFont7,100) 
		
		Case cE1PORTADO == "033" // SANTANDER
			//oPrint:Say(2480,1700,_cNumBoleta+" "+_cDV_NNUM,oFont7,100) 		
			oPrint:Say(2480,1700,Substr(_cNumBoleta,6,7)+" "+_cDV_NNUM,oFont7,100) 		
		
		Case cE1PORTADO $ "399/637" // HSBC
			oPrint:Say(2480,1700,_cNumBoleta+"-"+_cDV_NNUM,oFont7,100) 
		
		Case cE1PORTADO $ "655/KOB"  // KOBOLD
			oPrint:Say(2480,1700,"109" + "/" + _cNumBoleta+"-"+_cDV_NNUM,oFont7,100) 	// 102 E A CARTEIRA ? VERIFICAR NO SUPORTE
		
		Case cE1PORTADO $ "341/ITV" // ITAU 13/07/2018 
			oPrint:Say(2480,1910,"109" + "/" + _cNumBoleta+"-"+_cDV_NNUM,oFont7,100) 
		
		Case cE1PORTADO == "104" 	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
			oPrint:say(2480,1700,Substr(_cNumBoleta,1,17)+"-"+_cDV_NNUM,oFont7,100)		
		
	EndCase                                   
	
	If cE1PORTADO == "033"
		oPrint:say(002530,0120,"Carteira",oFont1,100)
		oPrint:say(002530,0520,"Espécie",oFont1,100)
		oPrint:say(002530,0670,"Quantidade",oFont1,100)
		oPrint:say(002530,1090,"Valor",oFont1,100)       
	
	ElseIf cE1PORTADO $ "422/SAF/SFF" //ALEX BORGES 03/04/12
		oPrint:say(2530,0120,"Data de OPeração",oFont1,100)
		oPrint:say(2530,0360,"CIP",oFont1,100)
		oPrint:say(2530,0405,"Carteira",oFont1,100)
		oPrint:say(2530,0520,"Espécie",oFont1,100)
		oPrint:say(2530,0670,"Quantidade",oFont1,100)
		oPrint:say(2530,1090,"Valor",oFont1,100)     
	
	Else
		oPrint:say(002530,0120,"Uso do Banco",oFont1,100)
		oPrint:say(002530,0370,"Carteira",oFont1,100)
		oPrint:say(002530,0520,"Espécie",oFont1,100)
		oPrint:say(002530,0670,"Quantidade",oFont1,100)
		oPrint:say(002530,1090,"Valor",oFont1,100)
	
	Endif	                                       
	
	oPrint:say(002530,1520,"(=) Valor do Documento",oFont1,100)
	If cE1PORTADO == "033"
		oPrint:say(002560,0120,"SIMPLES - RCR",oFont2,100)
		oPrint:say(002560,0520,"REAL",oFont2,100)
	
	ElseIf cE1PORTADO $ "SAF/422/SFF"  //ALEX BORGES 03/04/12
		
		oPrint:say(2560,120,Dtoc(dDataBase),oFont2,100)
		oPrint:say(2560,350,"130",oFont2,100)
		oPrint:say(2560,410,_cCarteira,oFont2,100)
		oPrint:say(2560,520,"R$",oFont2,100)
	
	Else
		oPrint:say(002560,0370,_cCarteira,oFont2,100)
		oPrint:say(002560,0520,"R$",oFont2,100)
	
	Endif	                         
	
	oPrint:say(002560,1900,transform(_nVlrBol,"@E 999,999,999.99"),oFont9,100)
	oPrint:say(002610,0120,"Instruções",oFont1,100)
	oPrint:say(002610,0120,"               "+ "(Todas as informações deste bloqueto são de exclusiva responsabilidade do Beneficiário)",oFont1A,100) // alteração chamado 022248 - William Costa
	
	If cE1PORTADO == "033"
		oPrint:say(002610,1520,"(-) Desconto",oFont1,100)            
		oPrint:say(002770,1520,"(+) Mora",oFont1,100)
	
	ElseIf cE1PORTADO $ "655"
		oPrint:say(1630,1520,"",oFont1,100)     
		oPrint:say(1710,1520,"(+) Mora/Multa",oFont1,100)	
	
	Else
		oPrint:say(002610,1520,"(-) Desconto/Abatimento",oFont1,100)
		oPrint:say(002770,1520,"(+) Mora/Multa",oFont1,100)
	
	Endif	                                            
	
	If !cE1PORTADO $ "001/237/246/422/SFF/SAF/RED/BRD/104/341/BRV/ITV"  	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17 // CHAMADO 050420
		oPrint:say(002640,1750,Transform(_nVlrAbat,"@E 999,999,999.99"),oFont7,100)
	EndIf	
	
	If cE1PORTADO == "033"
		oPrint:say(002690,1520,"(-) Abatimento",oFont1,100)
	Else
		oPrint:say(002690,1520,"(-) Outras Deduções",oFont1,100)
	Endif	
	
	If !(cE1PORTADO $ "655" )
		oPrint:say(002850,1520,"(+) Outros Acréscimos",oFont1,100)
	Endif
		
	oPrint:say(002930,1520,"(=) Valor Cobrado",oFont1,100)
	oPrint:say(003010,0120,"Pagador",oFont1,100) // alteração chamado 022248 - William Costa 
	oPrint:say(003040,0250,TSE1A->A1_NOME,oFont8,100)
	oPrint:say(003040,1500,transform(TSE1A->A1_CGC,"@R 99.999.999/9999-99"),oFont8,100)
	oPrint:say(003070,0250,TSE1A->A1_ENDCOB+" "+TSE1A->A1_BAIRROC,oFont8,100)
	oPrint:say(003100,0250,TSE1A->A1_CEPC+" "+TSE1A->A1_MUNC+TSE1A->A1_ESTC,oFont8,100)
	oPrint:say(003170,0120,"Sacador/Avalista",oFont1,100) // alteração chamado 022248 - William Costa
	If cE1PORTADO != "033"
		oPrint:say(003170,1520,"Cód.Baixa",oFont1,100)
		oPrint:say(003170,1750,"Autenticação Mecânica",oFont1,100)
		oPrint:say(003210,1730,"FICHA DE COMPENSAÇÃO",oFont2,100)
	Else
		oPrint:say(003210,1750,"Autenticação Mecânica",oFont1,100)
		oPrint:say(003310,1730,"FICHA DE COMPENSAÇÃO",oFont2,100)	
	Endif	                                                      
	        
	//Incluido 26/04/11
	If cE1PORTADO $ "655/637/SAF/KOB/RED/BRD" // 02/09 - Alex Borges
	 
		oPrint:say(003170,0400, cNome + cEndereco + cCidade + cCNPJ ,oFont1,100) // alteração chamado 022248 - William Costa
		
	Endif	              
	
	//Incluido 03/04/12
	If cE1PORTADO $ "SAF" // ALEX BORGES 03/04/12
	    oPrint:say(003170,0400,"GMSBS PRESTACOES DE SERVICOS S/A     CNPJ:  13.362.692/0001-60",oFont8,100)
	Endif	
	
	// Impressao das Instrucoes
	                                                         
	_nLinInst := 2640 // 2590 // 2570 //001540 -- 2340            
	
	If !(cE1PORTADO $ "655/422/SFF/KOB/SAF") //INCLUIDO 655 (VOTORANTIM) 26/04/11 e SAF em 03/04/12
	
		oPrint:say(_nLinInst,0120,"*** VALORES EXPRESSOS EM REAIS *** ",oFont8,100)	// Instruções 
	Endif	
	_nLinInst += 00050
	If cE1PORTADO == "246"	// Tratamento BANCO ABC
		oPrint:say(_nLinInst,0120,"Título transferido ao Banco ABC Brasil S/A.",oFont8,100)	
	EndIf  
	
	_nLinInst += 00050 
	            
	             
	//Incluido 26/04/11
	If cE1PORTADO == '655'                                    
		oPrint:Say(_nLinInst,0120,"Titulo entregue em cessão fiduciaria em favor do beneficiário acima" ,oFont8,100) // alteração chamado 022248 - William Costa
		_nLinInst += 00050	
	End IF
	                      
	If cE1PORTADO $ 'SAF/SFF' 
	//If cE1PORTADO == '422'     
		If SEE->EE_ZZMORA > 0	
			nValMora := ( _nVlrBol * ( SEE->EE_ZZMORA / 100) ) / 30 	
			oPrint:Say(_nLinInst,0120,"Não dispensar mora de R$ " + Alltrim(Transform(nValMora,"@E 999,999,999.99")) + " por dia de atraso" ,oFont8,100)
			_nLinInst += 00050
		Endif
	
		If SEE->EE_ZZDIAAT > 0 .AND. SEE->EE_ZZPERMU > 0
			oPrint:Say(_nLinInst,0120,"Após o vencimento cobrar multa de R$ " + Alltrim(Transform(_nVlrBol * (SEE->EE_ZZPERMU/100),"@E 999,999,999.99")),oFont8,100)
			_nLinInst += 00050
		Endif   
		
		If TSE1A->A1_ZZDESCB > 0 .AND. TSE1A->E1_TIPO <> 'NDC' 
		  
			oPrint:Say(_nLinInst,0120,"Conceder desconto de R$ " + Alltrim(Transform(ROUND(_nVlrBol * (TSE1A->A1_ZZDESCB/100),2),"@E 999,999.99")),oFont8,100) //Chamado: 048733 Fernando Sigoli 29/04/2019
			_nLinInst += 00050

		Endif
		
		If SEE->EE_ZZDDPRO > 0
			//oPrint:Say(_nLinInst,0120,"Após " + Strzero(SEE->EE_ZZDDPRO,2) + " dias do vencimento, protestar o titulo ",oFont8,100)
			oPrint:Say(_nLinInst,0120,"SUJEITO A PROTESTO APÓS O VENCIMENTO" ,oFont8,100) //tkt 7075 -  Fernando Sigoli - Alteração da instrução de protesto
			_nLinInst += 00050
		Endif
		
		If cE1PORTADO == 'SAF' 
			_nLinInst += 00025
			oPrint:Say(_nLinInst,0120,"BOLETO REFERENTE A NF "+ Alltrim(TSE1A->E1_NUM) + Iif(!Empty(TSE1A->E1_PARCELA),"-" +TSE1A->E1_PARCELA,"")+" EMITIDA POR AD'ORO S/A",oFont8Bold,100)
			_nLinInst += 00050
		Endif
		
	ElseIf cE1PORTADO == 'KOB' 
	    
		If SEE->EE_ZZMORA > 0	
			nValMora := ( _nVlrBol * ( SEE->EE_ZZMORA / 100) ) / 30 	
			oPrint:Say(_nLinInst,0120,"APÓS O VENCIMENTO COBRAR MORA DE R$ " + Alltrim(Transform(nValMora,"@E 999,999,999.99")) + " AO DIA" ,oFont8,100)
			_nLinInst += 00050 
			oPrint:Say(_nLinInst,0120,"DIREITO DE CREDITO CEDIDO AO BENEFICIÁRIO - PAGAVEL SOMENTE EM BANCO" ,oFont8,100)
			_nLinInst += 00050
			oPrint:Say(_nLinInst,0120,"COBRANCA ESCRITURAL" ,oFont8,100)
			_nLinInst += 00050
			oPrint:Say(_nLinInst,0120,"SUJEITO A PROTESTO APÓS O VENCIMENTO" ,oFont8,100) //Everson - 11/08/2020. Chamado 060193.
			_nLinInst += 00050						
		Endif
		
		If TSE1A->A1_ZZDESCB > 0 .AND. TSE1A->E1_TIPO <> 'NDC' 
		  
			oPrint:Say(_nLinInst,0120,"Conceder desconto de R$ " + Alltrim(Transform(ROUND(_nVlrBol * (TSE1A->A1_ZZDESCB/100),2),"@E 999,999.99")),oFont8,100) //Chamado: 048733 Fernando Sigoli 29/04/2019
			_nLinInst += 00050

		Endif		
	
	ElseIf cE1PORTADO $ '341/ITV'  //fernando sigoli 13/07/2018
	
		If SEE->EE_ZZMORA > 0	
			nValMora := ( _nVlrBol * ( SEE->EE_ZZMORA / 100) ) / 30 	
			oPrint:Say(_nLinInst,0120,"Após o vencimento cobrar mora de R$ " + Alltrim(Transform(nValMora,"@E 999,999,999.99")) + " ao dia" ,oFont8,100)
			_nLinInst += 00050
		Endif
	
		If SEE->EE_ZZDDPRO > 0
			//oPrint:Say(_nLinInst,0120,"Após " + Strzero(SEE->EE_ZZDDPRO,2) + " dias do vencimento, protestar o titulo ",oFont8,100)
			oPrint:Say(_nLinInst,0120,"SUJEITO A PROTESTO APÓS O VENCIMENTO" ,oFont8,100) //tkt 7075 -  Fernando Sigoli - Alteração da instrução de protesto
			_nLinInst += 00050
		Endif
	
		If SEE->EE_ZZDIAAT > 0 .AND. SEE->EE_ZZPERMU > 0
			oPrint:Say(_nLinInst,0120,"Após o " + Alltrim(Str(SEE->EE_ZZDIAAT)) + "° dia útil do vencimento cobrar multa de " + Transform(SEE->EE_ZZPERMU,"@E 999,999.99") + "%",oFont8,100)
			_nLinInst += 00050
		Endif
	
		If TSE1A->A1_ZZDESCB > 0 .AND. TSE1A->E1_TIPO <> 'NDC'
		  
			oPrint:Say(_nLinInst,0120,"Conceder desconto de R$ " + Alltrim(Transform(ROUND(_nVlrBol * (TSE1A->A1_ZZDESCB/100),2),"@E 999,999.99")),oFont8,100) //Chamado: 048733 Fernando Sigoli 29/04/2019
			_nLinInst += 00050

		Endif
	
	Else
	
		If SEE->EE_ZZMORA > 0
			nValMora := ( _nVlrBol * ( SEE->EE_ZZMORA / 100) ) / 30 	
			oPrint:Say(_nLinInst,0120,"Após o vencimento mora dia: " + Transform(nValMora,"@E 999,999,999.99") ,oFont8,100)
			_nLinInst += 00050
		Endif
	
		If SEE->EE_ZZDDPRO > 0
			//oPrint:Say(_nLinInst,0120,"Após " + Strzero(SEE->EE_ZZDDPRO,2) + " dias do vencimento, protestar o titulo ",oFont8,100)
			oPrint:Say(_nLinInst,0120,"SUJEITO A PROTESTO APÓS O VENCIMENTO" ,oFont8,100) //tkt 7075 -  Fernando Sigoli - Alteração da instrução de protesto
			_nLinInst += 00050
		Endif
	
		If SEE->EE_ZZDIAAT > 0 .AND. SEE->EE_ZZPERMU > 0
			oPrint:Say(_nLinInst,0120,"Após o " + Alltrim(Str(SEE->EE_ZZDIAAT)) + "° dia útil do vencimento cobrar multa de " + Transform(SEE->EE_ZZPERMU,"@E 999,999.99") + "%",oFont8,100)
			_nLinInst += 00050
		Endif
	
		If TSE1A->A1_ZZDESCB > 0 .AND. TSE1A->E1_TIPO <> 'NDC' 
		  
			oPrint:Say(_nLinInst,0120,"Conceder desconto de R$ " + Alltrim(Transform(ROUND(_nVlrBol * (TSE1A->A1_ZZDESCB/100),2),"@E 999,999.99")),oFont8,100) //Chamado: 048733 Fernando Sigoli 29/04/2019
			_nLinInst += 00050

		Endif
		
		If cE1PORTADO == 'BRD' 
			_nLinInst += 00025
			oPrint:Say(_nLinInst,0120,"BOLETO REFERENTE A NF "+ Alltrim(TSE1A->E1_NUM) + Iif(!Empty(TSE1A->E1_PARCELA),"-" +TSE1A->E1_PARCELA,"")+" EMITIDA POR AD'ORO S/A",oFont8Bold,100)
			_nLinInst += 00050
		Endif
		
	Endif	
	
	oPrint:say(_nLinInst,0140,mv_par09,oFont8,100)	// Instruções de parametro
	_nLinInst += 50
	oPrint:say(_nLinInst,0140,mv_par10,oFont8,100)  	// Instruções de parametro
	
	// Impressao do Codigo de Barras
	// Posicionamento Antigo 11/01/10 // MSBAR("INT25",28.0,1.1,_cCodBarras,oPrint,.F.,,.T.,0.025,1.3,NIL,NIL,NIL,.F.)
	
	//MSBAR("INT25",28.0,1.1,_cCodBarras,oPrint:oPrint,.F.,Nil,Nil,0.025,1.3,NIL,NIL,"A",.F.)

	If IsInCallStack("u_GeraBlPV") .or. Len(aParamIXB) > 0 // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 23/04/2020
		MSBAR("INT25",27.5,1.1,_cCodBarras,oPrint:oPrint,.F.,Nil,Nil,0.110,1.5,NIL,NIL,"A",.F.)
	Else
		If "P2050" $ oPrint:cPrinterName
			MSBAR("INT25",16.0,1.1,_cCodBarras,oPrint:oPrint,.F.,Nil,Nil,0.016,0.8,NIL,NIL,,.F.)
		Else	
			MSBAR("INT25",28.0,1.1,_cCodBarras,oPrint:oPrint,.F.,Nil,Nil,0.025,1.3,NIL,NIL,"A",.F.)
		EndIf	
	EndIf
	
	//if cE1PORTADO $ 'BRD'
	    //cBitMap := GetSrvProfString("Startpath","") + "logo.png"  	//desabilitado por Adriana em 03/10/2016 conforme chamado 030747
		//oPrint:SayBitmap(0300,0100,cBitMap,400,330)					//desabilitado por Adriana em 03/10/2016 conforme chamado 030747
	//    cBitMap := GetSrvProfString("Startpath","") + "logomil.png"
	//    oPrint:SayBitmap(0200,0100,cBitMap,2115,700)
	//endif
	SM0->(RestArea(aAreaSM0))
Return(Nil)

Static Function CadBar()

	// Encontra o Fator de Vencimento
	If IsInCallStack("u_GeraRAPV") .or. IsInCallStack("u_GeraBlPV") .or. Len(aParamIXB) > 0 .or. IsInCallStack("u_RunHCRFB")
		cVencto := StrZero( msDate() - Ctod("07/10/1997") ,4) // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 17/06/2020
	Else
		cVencto := StrZero( STOD(TSE1A->E1_VENCTO) - Ctod("07/10/1997") ,4)
	EndIf

	cNossoNr := Alltrim(cNossoNr)
	
	_cCoditau := cE1PORTADO + "9" + _cFatorVcto +StrZero(Val(AllTrim(cVlrFim)),10)+SUBSTR(cNossoNr,1,3)+SUBSTR(cNossoNr,5,7)+SUBSTR(cNossoNr,13,1)+TSE1A->E1_PREFIXO+SA6->A6_NUMCON+"00"
	
	nVal001 := Val(SubStr(_cCoditau,01,01)) * 4
	nVal002 := Val(SubStr(_cCoditau,02,01)) * 3
	nVal003 := Val(SubStr(_cCoditau,03,01)) * 2
	nVal004 := Val(SubStr(_cCoditau,04,01)) * 9
	nVal005 := Val(SubStr(_cCoditau,05,01)) * 8
	nVal006 := Val(SubStr(_cCoditau,06,01)) * 7
	nVal007 := Val(SubStr(_cCoditau,07,01)) * 6
	nVal008 := Val(SubStr(_cCoditau,08,01)) * 5
	nVal009 := Val(SubStr(_cCoditau,09,01)) * 4
	nVal010 := Val(SubStr(_cCoditau,10,01)) * 3
	nVal011 := Val(SubStr(_cCoditau,11,01)) * 2
	nVal012 := Val(SubStr(_cCoditau,12,01)) * 9
	nVal013 := Val(SubStr(_cCoditau,13,01)) * 8
	nVal014 := Val(SubStr(_cCoditau,14,01)) * 7
	nVal015 := Val(SubStr(_cCoditau,15,01)) * 6
	nVal016 := Val(SubStr(_cCoditau,16,01)) * 5
	nVal017 := Val(SubStr(_cCoditau,17,01)) * 4
	nVal018 := Val(SubStr(_cCoditau,18,01)) * 3
	nVal019 := Val(SubStr(_cCoditau,19,01)) * 2
	nVal020 := Val(SubStr(_cCoditau,20,01)) * 9
	nVal021 := Val(SubStr(_cCoditau,21,01)) * 8
	nVal022 := Val(SubStr(_cCoditau,22,01)) * 7
	nVal023 := Val(SubStr(_cCoditau,23,01)) * 6
	nVal024 := Val(SubStr(_cCoditau,24,01)) * 5
	nVal025 := Val(SubStr(_cCoditau,25,01)) * 4
	nVal026 := Val(SubStr(_cCoditau,26,01)) * 3
	nVal027 := Val(SubStr(_cCoditau,27,01)) * 2
	nVal028 := Val(SubStr(_cCoditau,28,01)) * 9
	nVal029 := Val(SubStr(_cCoditau,29,01)) * 8
	nVal030 := Val(SubStr(_cCoditau,30,01)) * 7
	nVal031 := Val(SubStr(_cCoditau,31,01)) * 6
	nVal032 := Val(SubStr(_cCoditau,32,01)) * 5
	nVal033 := Val(SubStr(_cCoditau,33,01)) * 4
	nVal034 := Val(SubStr(_cCoditau,34,01)) * 3
	nVal035 := Val(SubStr(_cCoditau,35,01)) * 2
	nVal036 := Val(SubStr(_cCoditau,36,01)) * 9
	nVal037 := Val(SubStr(_cCoditau,37,01)) * 8
	nVal038 := Val(SubStr(_cCoditau,38,01)) * 7
	nVal039 := Val(SubStr(_cCoditau,39,01)) * 6
	nVal040 := Val(SubStr(_cCoditau,40,01)) * 5
	nVal041 := Val(SubStr(_cCoditau,41,01)) * 4
	nVal042 := Val(SubStr(_cCoditau,42,01)) * 3
	nVal043 := Val(SubStr(_cCoditau,43,01)) * 2
	
	_nTtcod := nVal001 + nVal002 + nVal003 + nVal004 + nVal005 + nVal006 + nVal007 + nVal008 + nVal009 + nVal010 + nVal011 + nVal012 + nVal013 + nVal014
	_nTtcod := _nTtcod + nVal015 + nVal016 + nVal017 + nVal018 + nVal019 + nVal020 + nVal021 + nVal022 + nVal023
	_nTtcod := _nTtcod + nVal024 + nVal025 + nVal026 + nVal027 + nVal028 + nVal029 + nVal030 + nVal031 + nVal032
	_nTtcod := _nTtcod + nVal033 + nVal034 + nVal035 + nVal036 + nVal037 + nVal038 + nVal039 + nVal040 + nVal041 + nVal042  + nVal043
	
	nRstDig := MOD(_nTtcod,11)
	nRstDi1 := 11 - nRstDig
	
	If nRstDi1 == 10
		nRstDi1 := 1
	ELSEIF nRstDi1 == 11
		nRstDi1 := 1
	ELSE
		nRstDi1 := nRstDi1
	ENDIF
	
	_cCoditau := cE1PORTADO + "9" + Alltrim(STR(nRstDi1)) +_cFatorVcto +StrZero(Val(AllTrim(cVlrFim)),10)+SUBSTR(cNossoNr,1,3)+SUBSTR(cNossoNr,5,7)+SUBSTR(cNossoNr,13,1)+TSE1A->E1_PREFIXO+SA6->A6_NUMCON+"00"
	_cCodbarras := cE1PORTADO + "9" + Alltrim(STR(nRstDi1)) +_cFatorVcto +StrZero(Val(AllTrim(cVlrFim)),10)+SUBSTR(cNossoNr,1,3)+SUBSTR(cNossoNr,5,7)+SUBSTR(cNossoNr,13,1)+TSE1A->E1_PREFIXO+SA6->A6_NUMCON+"00"

Return(_cCodbarras)

Static Function LocParcela()

	IF Alltrim(TSE1A->E1_PARCELA) == "A"
		_nSeqPar := "01"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "B"
		_nSeqPar := "02"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "C"
		_nSeqPar := "03"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "D"
		_nSeqPar := "04"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "E"
		_nSeqPar := "05"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "F"
		_nSeqPar := "06"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "G"
		_nSeqPar := "07"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "H"
		_nSeqPar := "08"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "I"
		_nSeqPar := "09"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "J"
		_nSeqPar := "10"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "K"
		_nSeqPar := "11"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "L"
		_nSeqPar := "12"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "M"
		_nSeqPar := "13"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "N"
		_nSeqPar := "14"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "O"
		_nSeqPar := "15"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "P"
		_nSeqPar := "16"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "Q"
		_nSeqPar := "17"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "R"
		_nSeqPar := "18"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "S"
		_nSeqPar := "19"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "T"
		_nSeqPar := "20"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "U"
		_nSeqPar := "21"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "V"
		_nSeqPar := "22"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "X"
		_nSeqPar := "23"
	ELSEIF  Alltrim(TSE1A->E1_PARCELA) == "Z"
		_nSeqPar := "24"
	ELSEIF Empty(TSE1A->E1_PARCELA)
		_nSeqPar := "01"
	ELSE
		_nSeqPar := Alltrim(TSE1A->E1_PARCELA)
	ENDIF

Return(_nSeqPar)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunção    ³VALIDPERG º Autor ³ AP5 IDE            º Data ³  01/03/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Verifica a existencia das perguntas criando-as caso seja   º±±
±±º          ³ necessario (caso nao existam).                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Static Function ValidPerg()

	Local _sAlias := Alias()
	Local aRegs   := {}
	Local i, j
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg, 10)
	
	aAdd(aRegs,{cPerg,"01","Roteiro de  ? " 		,"" ,"" ,"mv_ch1"	,"C",03,0,0,"G","","mv_par01","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Roteiro ate ?  " 		,"" ,"" ,"mv_ch2"	,"C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Serie de       "   		,"" ,"" ,"mv_ch3"	,"C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Serie ate      "   		,"" ,"" ,"mv_ch4"	,"C",03,0,0,"G","","mv_par04","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","NF de 			"   	,"" ,"" ,"mv_ch5"	,"C",09,0,0,"G","","mv_par05","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","NF Ate 			"   	,"" ,"" ,"mv_ch6"	,"C",09,0,0,"G","","mv_par06","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Emissao de ? 	"   	,"" ,"" ,"mv_ch7"	,"D",08,0,0,"G","","mv_par07","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08","Emissao Ate ? 	"   	,"" ,"" ,"mv_ch8"	,"D",08,0,0,"G","","mv_par08","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","1- Instruções"     		,"" ,"" ,"mv_ch9"	,"C",90,0,0,"G","","mv_par09","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"10","2- Instruções"     		,"" ,"" ,"mv_cha"	,"C",90,0,0,"G","","mv_par10","","","","","","","","","","","","","",""})
	
	For i := 1 to Len(aRegs)
		If !dbSeek(cPerg + aRegs[i, 2])
			RecLock("SX1", .T.)
			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j, aRegs[i, j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
	
	dbSelectArea(_sAlias)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fCALCNNR  ºAutor  ³Microsiga           º Data ³  30/05/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula e grava o Numero-Digito do Nosso Numero            º±±
±±º          ³ para o Banco Itau                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8.11                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fCalcNNr()

	cDigNNr		 := " "
	_cNumboleta  := TSE1A->E1_NUM + _nSeqParcela
	
	nAgen01 := Val(SubStr(_cAg,1,1))
	nAgen02 := Val(SubStr(_cAg,2,1))        
	nAgen03 := Val(SubStr(_cAg,3,1))
	nAgen04 := Val(SubStr(_cAg,4,1))
	nCont01 := Val(SubStr(_cCc,1,1))
	nCont02 := Val(SubStr(_cCc,2,1))
	nCont03 := Val(SubStr(_cCc,3,1))
	nCont04 := Val(SubStr(_cCc,4,1))
	nCont05 := Val(SubStr(_cCc,5,1))
	nCart01 := Val(SubStr(Alltrim(Str(_nCart)),1,1)) //--1
	nCart02 := Val(SubStr(Alltrim(Str(_nCart)),2,1)) //--7
	nCart03 := Val(SubStr(Alltrim(Str(_nCart)),3,1)) //--9
	nNNum01 := Val(SubStr(_cNumboleta,1,1))
	nNNum02 := Val(SubStr(_cNumboleta,2,1))
	nNNum03 := Val(SubStr(_cNumboleta,3,1))
	nNNum04 := Val(SubStr(_cNumboleta,4,1))
	nNNum05 := Val(SubStr(_cNumboleta,5,1))
	nNNum06 := Val(SubStr(_cNumboleta,6,1))
	nNNum07 := Val(SubStr(_cNumboleta,7,1))
	nNNum08 := Val(SubStr(_cNumboleta,8,1))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Multiplica Numero a Numero³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nAux101 := nAgen01 * 1
	If nAux101 >= 10
		cAux101 := STR(nAux101)
		nAux101 := Val(SubStr(ALLTrim(cAux101),1,1))+Val(SubStr(ALLTrim(cAux101),2,1))
	EndIf
	
	nAux102 := nAgen02 * 2
	If nAux102 >= 10
		cAux102 := STR(nAux102)
		nAux102 := Val(SubStr(ALLTrim(cAux102),1,1))+Val(SubStr(ALLTrim(cAux102),2,1))
	EndIf
	nAux103 := nAgen03 * 1
	
	If nAux103 >= 10
		cAux103 := STR(nAux103)
		nAux103 := Val(SubStr(ALLTrim(cAux103),1,1))+Val(SubStr(ALLTrim(cAux103),2,1))
	EndIf
	
	nAux104 := nAgen04 * 2
	If nAux104 >= 10
		cAux104 := STR(nAux104)
		nAux104 := Val(SubStr(ALLTrim(cAux104),1,1))+Val(SubStr(ALLTrim(cAux104),2,1))
	EndIf
	
	nAux105 := nCont01 * 1
	If nAux105 >= 10
		cAux105 := STR(nAux105)
		nAux105 := Val(SubStr(ALLTrim(cAux105),1,1))+Val(SubStr(ALLTrim(cAux105),2,1))
	EndIf
	
	nAux106 := nCont02 * 2
	If nAux106 >= 10
		cAux106 := STR(nAux106)
		nAux106 := Val(SubStr(ALLTrim(cAux106),1,1))+Val(SubStr(ALLTrim(cAux106),2,1))
	EndIf
	
	nAux107 := nCont03 * 1
	If nAux107 >= 10
		cAux107 := STR(nAux107)
		nAux107 := Val(SubStr(ALLTrim(cAux107),1,1))+Val(SubStr(ALLTrim(cAux107),2,1))
	EndIf
	
	nAux108 := nCont04 * 2
	If nAux108 >= 10
		cAux108 := STR(nAux108)
		nAux108 := Val(SubStr(ALLTrim(cAux108),1,1))+Val(SubStr(ALLTrim(cAux108),2,1))
	EndIf
	
	nAux109 := nCont05 * 1
	If nAux109 >= 10
		cAux109 := STR(nAux109)
		nAux109 := Val(SubStr(ALLTrim(cAux109),1,1))+Val(SubStr(ALLTrim(cAux109),2,1))
	EndIf
	
	nAux110 := nCart01 * 2
	If nAux110 >= 10
		cAux110 := STR(nAux110)
		nAux110 := Val(SubStr(ALLTrim(cAux110),1,1))+Val(SubStr(ALLTrim(cAux110),2,1))
	EndIf
	
	nAux111 := nCart02 * 1
	If nAux111 >= 10
		cAux111 := STR(nAux111)
		nAux111 := Val(SubStr(ALLTrim(cAux111),1,1))+Val(SubStr(ALLTrim(cAux111),2,1))
	EndIf
	nAux112 := nCart03 * 2
	If nAux112 >= 10
		cAux112 := STR(nAux112)
		nAux112 := Val(SubStr(ALLTrim(cAux112),1,1))+Val(SubStr(ALLTrim(cAux112),2,1))
	EndIf
	nAux113 := nNNum01 * 1
	If nAux113 >= 10
		cAux113 := STR(nAux113)
		nAux113 := Val(SubStr(ALLTrim(cAux113),1,1))+Val(SubStr(ALLTrim(cAux113),2,1))
	EndIf
	nAux114 := nNNum02 * 2
	If nAux114 >= 10
		cAux114 := STR(nAux114)
		nAux114 := Val(SubStr(ALLTrim(cAux114),1,1))+Val(SubStr(ALLTrim(cAux114),2,1))
	EndIf
	nAux115 := nNNum03 * 1
	If nAux115 >= 10
		cAux115 := STR(nAux115)
		nAux115 := Val(SubStr(ALLTrim(cAux115),1,1))+Val(SubStr(ALLTrim(cAux115),2,1))
	EndIf
	nAux116 := nNNum04 * 2
	If nAux116 >= 10
		cAux116 := STR(nAux116)
		nAux116 := Val(SubStr(ALLTrim(cAux116),1,1))+Val(SubStr(ALLTrim(cAux116),2,1))
	EndIf
	nAux117 := nNNum05 * 1
	If nAux117 >= 10
		cAux117 := STR(nAux117)
		nAux117 := Val(SubStr(ALLTrim(cAux117),1,1))+Val(SubStr(ALLTrim(cAux117),2,1))
	EndIf
	nAux118 := nNNum06 * 2
	If nAux118 >= 10
		cAux118 := STR(nAux118)
		nAux118 := Val(SubStr(ALLTrim(cAux118),1,1))+Val(SubStr(ALLTrim(cAux118),2,1))
	EndIf
	nAux119 := nNNum07 * 1
	If nAux119 >= 10
		cAux119 := STR(nAux119)
		nAux119 := Val(SubStr(ALLTrim(cAux119),1,1))+Val(SubStr(ALLTrim(cAux119),2,1))
	EndIf
	nAux120 := nNNum08 * 2
	If nAux120 >= 10
		cAux120 := STR(nAux120)
		nAux120 := Val(SubStr(ALLTrim(cAux120),1,1))+Val(SubStr(ALLTrim(cAux120),2,1))
	EndIf
	
	nTot1:=nAux101+nAux102+nAux103+nAux104+nAux105+nAux106+nAux107+nAux108+nAux109
	nTot1:=nTot1+nAux110+nAux111+nAux112+nAux113+nAux114+nAux115+nAux116+nAux117+nAux118+nAux119+nAux120 // nAux119
	
	nRstDig := MOD(nTot1,10)
	cDigNNr := 10 - nRstDig
	cDigNNr := IIf(cDigNNr == 10,0,cDigNNr)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem do Nosso Numero³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNossoNr:=Alltrim(Str(_nCart))+"/"+cAuxNNr+"-"+Str(cDigNNr,1)

Return(.T.) 

/* Funcao para Calculo de DAC Itau */
Static Function fDACITAU(cAgenConta)

	Local cRet 	:= ""
	
	Local nP1 	:= Val(Substr(cAgenConta,01,1)) * 2
	Local nP2 	:= Val(Substr(cAgenConta,02,1)) * 1
	Local nP3 	:= Val(Substr(cAgenConta,03,1)) * 2
	Local nP4 	:= Val(Substr(cAgenConta,04,1)) * 1
	Local nP5 	:= Val(Substr(cAgenConta,05,1)) * 2
	Local nP6 	:= Val(Substr(cAgenConta,06,1)) * 1
	Local nP7 	:= Val(Substr(cAgenConta,07,1)) * 2
	Local nP8 	:= Val(Substr(cAgenConta,08,1)) * 1
	Local nP9 	:= Val(Substr(cAgenConta,09,1)) * 2
	Local nDC 	:= nP1 + nP2 + nP3 + nP4 + nP5 + nP6 + nP7 + nP8 + nP9 
	Local nResto:= ( nDC % 10 ) 
	Local nRet	:= 10 - nResto
	
	If nRet >= 10
		cRet := "0"
	Else
		cRet := StrZero(nRet,1)
	Endif

Return(cRet)  



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ DgVerECF º Autor ³ FERNANDO SIGOLI    º Data ³  06/01/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ calcula Difito Verificar codigo de barras banco Caixa       ±±
±±ºEconomica Federal.  Chamado 032158                                      ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DgVerECF(cCodBarra)

	Local _nRSANT := 0

	U_ADINF009P('HCRFIBLT' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Emissao de Boleto de acordo com parametros informados')
	
	nR01 := Val(Substr(cCodBarra,01,1)) * 4
	nR02 := Val(Substr(cCodBarra,02,1)) * 3
    nR03 := Val(Substr(cCodBarra,03,1)) * 2
    nR04 := Val(Substr(cCodBarra,04,1)) * 9
    nR05 := Val(Substr(cCodBarra,05,1)) * 8
    nR06 := Val(Substr(cCodBarra,06,1)) * 7
    nR07 := Val(Substr(cCodBarra,07,1)) * 6
    nR08 := Val(Substr(cCodBarra,08,1)) * 5
    nR09 := Val(Substr(cCodBarra,09,1)) * 4
    nR10 := Val(Substr(cCodBarra,10,1)) * 3
    nR11 := Val(Substr(cCodBarra,11,1)) * 2
    nR12 := Val(Substr(cCodBarra,12,1)) * 9
    nR13 := Val(Substr(cCodBarra,13,1)) * 8 
    nR14 := Val(Substr(cCodBarra,14,1)) * 7 
    nR15 := Val(Substr(cCodBarra,15,1)) * 6
    nR16 := Val(Substr(cCodBarra,16,1)) * 5 
    nR17 := Val(Substr(cCodBarra,17,1)) * 4 
    nR18 := Val(Substr(cCodBarra,18,1)) * 3
    nR19 := Val(Substr(cCodBarra,19,1)) * 2
    nR20 := Val(Substr(cCodBarra,20,1)) * 9 
    nR21 := Val(Substr(cCodBarra,21,1)) * 8
    nR22 := Val(Substr(cCodBarra,22,1)) * 7
    nR23 := Val(Substr(cCodBarra,23,1)) * 6 
    nR24 := Val(Substr(cCodBarra,24,1)) * 5 
    nR25 := Val(Substr(cCodBarra,25,1)) * 4 
    nR26 := Val(Substr(cCodBarra,26,1)) * 3 
    nR27 := Val(Substr(cCodBarra,27,1)) * 2 
    nR28 := Val(Substr(cCodBarra,28,1)) * 9 
    nR29 := Val(Substr(cCodBarra,29,1)) * 8 
    nR30 := Val(Substr(cCodBarra,30,1)) * 7 
    nR31 := Val(Substr(cCodBarra,31,1)) * 6 
    nR32 := Val(Substr(cCodBarra,32,1)) * 5
    nR33 := Val(Substr(cCodBarra,33,1)) * 4 
    nR34 := Val(Substr(cCodBarra,34,1)) * 3 
    nR35 := Val(Substr(cCodBarra,35,1)) * 2 
    nR36 := Val(Substr(cCodBarra,36,1)) * 9 
    nR37 := Val(Substr(cCodBarra,37,1)) * 8 
    nR38 := Val(Substr(cCodBarra,38,1)) * 7 
    nR39 := Val(Substr(cCodBarra,39,1)) * 6 
    nR40 := Val(Substr(cCodBarra,40,1)) * 5
    nR41 := Val(Substr(cCodBarra,41,1)) * 4 
    nR42 := Val(Substr(cCodBarra,42,1)) * 3 
    nR43 := Val(Substr(cCodBarra,43,1)) * 2 
    
   _nRSANT := nR01 + nR02 + nR03 + nR04 + nR05 + nR06 + nR07 + nR08 + nR09 + nR10 + nR11 + nR12+;
  	          nR13 + nR14 + nR15 + nR16 + nR17 + nR18 + nR19 + nR20 + nR21 + nR22 + nR23 + nR24+;
  	          nR25 + nR26 + nR27 + nR28 + nR29 + nR30 + nR31 + nR32 + nR33 + nR34 + nR35 + nR36+;
  	          nR37 + nR38 + nR39 + nR40 + nR41 + nR42 + nR43
  	                                                               
   _nResto := ( _nRSANT % 11 ) //calcula para achar o resto da divisão
   
   _nResto := 11-_nResto       //subtrair o resto da divisao por 11
   
   If _nResto == 0 .or. _nResto > 9  //se _nResto igual a zerou ou maior que 9, o DV será um a 1
 		_cB_DVCam := "1"
   Else
    	_cB_DVCam := Str(_nResto,1)
   Endif    
        
Return _cB_DVCam

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ Dgcmpliv º Autor ³ FERNANDO SIGOLI    º Data ³  06/01/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ calcula Difito Verificar codigo do campo livre             º±±
±±ºEconomica Federal.  Chamado 032158                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function Dgcmpliv(cCampoLiv)

	Local _nRSANT := 0

	U_ADINF009P('HCRFIBLT' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Emissao de Boleto de acordo com parametros informados')

	nD01 := Val(Substr(cCampoLiv,01,1)) * 9
	nD02 := Val(Substr(cCampoLiv,02,1)) * 8
    nD03 := Val(Substr(cCampoLiv,03,1)) * 7
    nD04 := Val(Substr(cCampoLiv,04,1)) * 6
    nD05 := Val(Substr(cCampoLiv,05,1)) * 5
    nD06 := Val(Substr(cCampoLiv,06,1)) * 4
    nD07 := Val(Substr(cCampoLiv,07,1)) * 3
    nD08 := Val(Substr(cCampoLiv,08,1)) * 2
    nD09 := Val(Substr(cCampoLiv,09,1)) * 9
    nD10 := Val(Substr(cCampoLiv,10,1)) * 8
    nD11 := Val(Substr(cCampoLiv,11,1)) * 7
    nD12 := Val(Substr(cCampoLiv,12,1)) * 6
    nD13 := Val(Substr(cCampoLiv,13,1)) * 5 
    nD14 := Val(Substr(cCampoLiv,14,1)) * 4 
    nD15 := Val(Substr(cCampoLiv,15,1)) * 3
    nD16 := Val(Substr(cCampoLiv,16,1)) * 2 
    nD17 := Val(Substr(cCampoLiv,17,1)) * 9 
    nD18 := Val(Substr(cCampoLiv,18,1)) * 8
    nD19 := Val(Substr(cCampoLiv,19,1)) * 7
    nD20 := Val(Substr(cCampoLiv,20,1)) * 6 
    nD21 := Val(Substr(cCampoLiv,21,1)) * 5
    nD22 := Val(Substr(cCampoLiv,22,1)) * 4
    nD23 := Val(Substr(cCampoLiv,23,1)) * 3 
    nD24 := Val(Substr(cCampoLiv,24,1)) * 2 
       
   _nRSANT := nD01 + nD02 + nD03 + nD04 + nD05 + nD06 + nD07 + nD08 + nD09 + nD10 + nD11 + nD12+;
  	          nD13 + nD14 + nD15 + nD16 + nD17 + nD18 + nD19 + nD20 + nD21 + nD22 + nD23 + nD24

  	                                                               
   _nResto := ( _nRSANT % 11 ) //calcula para achar o resto da divisão
   
   _nResto := 11-_nResto       //subtrair o resto da divisao por 11
   
   If _nResto > 9  //se _nResto maior que 9, o DV será um a 0
 		_RE_Campo := "0"
   Else
    	_RE_Campo := Str(_nResto,1)
   Endif    
        
Return _RE_Campo    
        
//modelo 10
Static Function ADMOD10(_nCnt,_cCampo)

	Local _nI   := 1
	Local _nAux := 0
	Local _nInt := 0
	
	Private _nDigito := 0
	
	For _nI := 1 to Len(_cCampo)
		
		_nAux := Val(Substr(_cCampo,_nI,1)) * _nCnt
		
		If _nAux >= 10
			_nAux:= (Val(Substr(Str(_nAux,2),1,1))+Val(Substr(Str(_nAux,2),2,1)))
		Endif
		
		_nCnt += 1
		If _nCnt > 2
			_nCnt := 1
		Endif
		_nDigito += _nAux
		
	Next _nI
	
	If (_nDigito%10) > 0
		_nInt    := Int(_nDigito/10) + 1
	Else
		_nInt    := Int(_nDigito/10)
	Endif
	
	_nInt    := _nInt * 10
	_nDigito := _nInt - _nDigito

Return(cvaltochar(_nDigito))

/*/{Protheus.doc} Static Function Modulo10
	(long_description)
	@type  Static Function
	@author FWNM
	@since 09/04/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado n. 056544 || OS 058692 || FINANCAS || WAGNER || 11940283101 || ITAU - VINCULADA
/*/
Static Function Modulo10(cData)

	Local L	:= Len(cData)
	Local D	:= 0
	Local P := 0
	Local B	:= .T.

	While L > 0
		P := Val(SubStr(cData, L, 1))
		If (B)
			P := P * 2
			If P > 9
				P := P - 9
			EndIf
		EndIf
		D := D + P
		L := L - 1
		B := !B
	EndDo

	D := 10 - (Mod(D,10))

	If D = 10
		D := 0
	EndIf

Return(AllTrim(Str(D,1)))

/*/{Protheus.doc} Static Function Modulo11
	(long_description)
	@type  Static Function
	@author FWNM
	@since 09/04/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado n. 056544 || OS 058692 || FINANCAS || WAGNER || 11940283101 || ITAU - VINCULADA
/*/
Static Function Modulo11(cData)

	Local L	:= Len(cData)
	Local D	:= 0
	Local P	:= 1

	While L > 0
		P := P + 1
		D := D + (Val(SubStr(cData, L, 1)) * P)
		If P = 9
			P := 1
		EndIf
		L := L - 1
	EndDo

	D := 11 - (mod(D,11))

	If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
		D := 1
	EndIf

Return(AllTrim(Str(D,1)))

/*/{Protheus.doc} User Function GeraBlPV
	Gera boleto do RA do PV
	@type  Function
	@author FWNM
	@since 23/04/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
/*/
User Function GeraBlPV(cEmpAnt, cFilAnt, cNumPV)

	Local aParamJob := {}
	Local cCodRetOk := GetMV("MV_#WSOCOK",,"00")
	Local cCodRet69 := GetMV("MV_#WSOC69",,"69") // chamado 059655 - FWNM - 21/07/2020 - || OS 061193 || FINANCAS || MARILIA || 8353 || CANCELAMENTO RA
	Private cCondPix  := alltrim(GetNewPar("MV_#CONPIX", "PIX"))
	Private cCondLnk  := alltrim(GetNewPar("MV_#CONLNK", "LNK"))

	logZBE(cNumPV + " esta na funcao GERABLPV para gerar boleto em PDF e enviar email")  // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 21/05/2020

	// Posiciono tabelas
	SC5->( dbSetOrder(1) ) // C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_
	SC5->( dbSeek(FWxFilial("SC5")+cNumPV) )
	
	SA1->( dbSetOrder(1) ) // A1_FILIAL+A1_COD+A1_LOJA
	SA1->( dbSeek(FWxFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)) )

	SA3->( dbSetOrder(1) ) // A3_FILIAL, A3_COD, R_E_C_N_O_, D_E_L_E_T_
	SA3->( dbSeek(FWxFilial("SA3")+SC5->C5_VEND1) )

	FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
	FIE->( dbSeek(SC5->C5_FILIAL+"R"+SC5->C5_NUM) )

	SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
	SE1->( dbSeek(FWxFilial("SE1")+FIE->(FIE_PREFIX+FIE_NUM+FIE_PARCEL+FIE_TIPO)) )

	if ( SC5->C5_CONDPAG == cCondPix .or. SC5->C5_CONDPAG == cCondLnk ) .and. ( SE1->E1_XLOGPIX != "ERR" .or. SE1->E1_XLOGLNK != "ERR" )
		return
	endif

	// @history ticket 68450   - Fernando Macieira     - 18/02/2022 - Email em duplicidade para o cliente/vendedor
	If AllTrim(SC5->C5_XWSBOLG) == "S"
		Return
	EndIf
	//

	//If !Empty(SE1->E1_NUMBCO) .and. !Empty(SE1->E1_XWSBRAC) .and. Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRetOk))
	If !Empty(SE1->E1_NUMBCO) .and. !Empty(SE1->E1_XWSBRAC) .and. ( Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRetOk)) .or. Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRet69)) ) // chamado 059655 - FWNM - 21/07/2020 - || OS 061193 || FINANCAS || MARILIA || 8353 || CANCELAMENTO RA

		logZBE(cNumPV + " ira executar startjob da funcao U_HCRFIBLT para gerar boleto em PDF e enviar por email ao vendedor e cliente")  // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 21/05/2020

		aParamJob := { cEmpAnt, cFilAnt, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_EMISSAO, SE1->E1_NUMBCO, SA1->A1_EMAIL, SA3->A3_EMAIL, "JOB", .T. }
		StartJob("U_HCRFIBLT", GetEnvServer(), .T., aParamJob)
		//u_HCRFIBLT(aParamJob) // debug

	Else

		logZBE(cNumPV + " esta enviando email ao vendedor para avisar sobre erro no registro do boleto no bradesco")  // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 21/05/2020

		// Envia email ao vendedor para avisar sobre erro no registro do boleto no Bradesco 
		EnvMailErr()	
	
	EndIf

Return

/*/{Protheus.doc} Static Function EnvMailErr
	Envia email ao vendedor para avisar sobre erro no registro do boleto no Bradesco 
	@type  Static Function
	@author Fernando Macieira
	@since 27/04/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
/*/
Static Function EnvMailErr()

	Local cMensagem	:= ""
	Local cQuery	:= ""
	Local cAssunto	:= "[ Boleto Bradesco ] - Pedidos Vendas com adiantamento - n. " + SC5->C5_NUM + " - Não registrado junto ao banco devido erro abaixo - Verifique dados cadastrais e registre/gere boleto manualmente"
	Local cMails    := SA3->A3_EMAIL
	//Local cMails    := "fwnmacieira@gmail.com;fernando.macieira@piocom.com.br;fernando.sigoli@adoro.com.br" // debug

	// Cabeçalho
	cMensagem += '<html>'
	cMensagem += '<body>'
	cMensagem += '<p style="color:red">'+cValToChar(cAssunto)+'</p>'
	cMensagem += '<hr>'
	cMensagem += '<table border="1">'
	cMensagem += '<tr style="background-color: black;color:white">'
	cMensagem += '<td>Pedido Venda</td>'
	cMensagem += '<td>Cliente</td>'
	cMensagem += '<td>Valor Total</td>'
	cMensagem += '<td>Banco|Agência|Conta</td>'
	cMensagem += '<td>Boleto não registrado no banco devido erro abaixo</td>'
	cMensagem += '</tr>'

	// Detalhes
	cMensagem += '<tr>'
	cMensagem += '<td>' + cValToChar(SC5->C5_NUM)    + '</td>'
	cMensagem += '<td>' + cValToChar(SE1->E1_NOMCLI)     + '</td>'
	cMensagem += '<td>' + cValToChar(Transform(SE1->E1_VALOR,"@E 999,999,999.99"))   + '</td>'
	cMensagem += '<td>' + cValToChar(SE1->E1_PORTADO) + " | "+ cValToChar(SE1->E1_AGEDEP) + " | " + cValToChar(SE1->E1_CONTA) + '</td>'
	if ( alltrim(SC5->C5_CONDPAG) == cCondPix .or. alltrim(SC5->C5_CONDPAG) == cCondLnk )
		cMensagem += '<td>' +  cValToChar(SC5->C5_CONDPAG) + "|" + SE1->E1_XMEMPIX + SE1->E1_XMEMLNK + '</td>'	
	else
		cMensagem += '<td>' + cValToChar(SE1->E1_XWSBRAC + " | " + SE1->E1_XWSBRAD)    + '</td>'
	endif

	cMensagem += '</tr>'

	cMensagem += '</table>'
	cMensagem += '</body>'
	cMensagem += '</html>'

	ProcessarEmail(cAssunto,cMensagem,cMails)

Return

/*/{Protheus.doc} Static Function PROCESSAREMAIL
	Configurações EMAIL
	@type  Static Function
	@author Fernando Macieira
	@since 18/04/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ProcessarEmail(cAssunto,cMensagem,email)

	Local lOk           := .T.
	Local cBody         := cMensagem
	Local cErrorMsg     := ""
	Local aFiles        := {}
	Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
	Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
	Local cFrom         := AllTrim(GetMv("MV_RELFROM")) 
	Local cTo           := email
	Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)
	Local lAutOk        := .F.
	Local cAtach        := ""
	Local cSubject      := ""
	Local cCopia        := ""
	Local cCpOcul       := GetMV("MV_#WSMATI",,"fernando.sigoli@adoro.com.br")

	//Assunto do e-mail.
	cSubject := cAssunto

	//Conecta ao servidor SMTP.
	Connect Smtp Server cServer Account cAccount  Password cPassword Result lOk

	If !lAutOk
		If ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)
		Else
			lAutOk := .T.
		EndIf
	EndIf

	If lOk .And. lAutOk

		//Envia o e-mail.
		Send Mail From cFrom To cTo CC cCopia BCC cCpOcul Subject cSubject Body cBody ATTACHMENT cAtach Result lOk
		//Send Mail From cDe To cPara CC cCopia Subject cAssunto Body cMensag Attachment cAnexo Result lOk
		//Send Mail From cDe To cPara CC cCopia BCC cCpOcul Subject cAssunto Body cMensag Attachment cAnexo Result lOk


		//Tratamento de erro no envio do e-mail.
		If !lOk
			Get Mail Error cErrorMsg
			ConOut("3 - " + cErrorMsg)
		Else
			ApMsgStop( "[HCRFIBLT] - JOB - BOLETO BRADESCO - Email enviado com sucesso sobre erro cadastral!"  + email )
			ConOut(	"[HCRFIBLT] - JOB - BOLETO BRADESCO - Email enviado com sucesso sobre erro cadastral!"  + email )

			RecLock("SC5", .F.)
				SC5->C5_XWSBOLG := ""
			SC5->( msUnLock() )
			SC5->( fkCommit() ) // chamado 059415 - FWNM                - 05/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - FKCOMMIT
		EndIf

	Else
	
		Get Mail Error cErrorMsg
		ConOut("4 - " + cErrorMsg)

	EndIf

	If lOk
		Disconnect Smtp Server
	EndIf

Return

/*/{Protheus.doc} Static Function LOGZBE
	Gera log ZBE
	@type  Static Function
	@author Everson
	@since 24/05/2019
	@version 01
	@history chamado 056247 - FWNM - 21/05/2020 - Error log apenas via execauto na criação do arquivo e inclusao de ZBE em diversos pontos
/*/
Static Function logZBE(cMensagem)

	Local aArea	:= GetArea()

	RecLock("ZBE", .T.)
		Replace ZBE_FILIAL 	   	With FWxFilial("ZBE")
		Replace ZBE_DATA 	   	With msDate()
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With cMensagem
		Replace ZBE_MODULO	    With "SIGAFIN"
		Replace ZBE_ROTINA	    With "ADFIN087P" 
	ZBE->( msUnlock() )

Return
