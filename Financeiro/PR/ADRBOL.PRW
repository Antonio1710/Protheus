#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "font.ch"       
#INCLUDE "topconn.ch"
#INCLUDE "ParmType.ch" 
      
/*/{Protheus.doc} User Function ADRBOL
	Reemissão de boletos, em caso da não geração durante a rotina do faturamento
	@type  Function
	@author Paulo TDS
	@since 25/05/2011
	@history chamado TI     - Sigoli        - 20/05/2011 - O desenvolvimento desta reemissão foi solicitada pelo Sr. Reginaldo para que fosse re-emitido apenas um boleto de cada vez.
	@history chamado TI     - Sigoli        - 27/05/2011 - Por solicitação do Sr. Reginaldo, o valor do boleto será pelo saldo do titulo e o nosso numero será gerado pelo banco cobrador
	@history chamado 045459 - Sigoli        - 27/11/2018 - alterar a conta corrente da KODOLD de 91898-2 para 02680-2
	@history chamado 048048 - Sigoli        - 20/13/2019 - Para os bancos 341/655/KOB/422/SAF/SFF - tratar o sequencia do numero bancario EE_FAXATU sem tratamento com parte do numero (substring) 
	@history chamado 048733 - Sigoli        - 29/04/2019 - Alterar desconto de Percentual para Valor R$
	@history chamado 050420 - William       - ??/??/???? - || OS 051718 || FINANCAS || EDUARDO || 8352 || NOVA CONTA BRADESCO - Boleto Bradesco conta vinculada
	@history chamado 051514 - William       - ??/??/???? - || OS 052842 || FINANCAS || ANDREA || 8319 || BANCO SAFRA - Ajustado Posicao 5 linha digitavel do Safra
	@history chamado 056544 - FWNM          - 09/04/2020 - || OS 058692 || FINANCAS || WAGNER || 11940283101 || ITAU - VINCULADA
	@history chamado 056247 - FWNM          - 27/03/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history chamado 058260 - William       - 20/05/2020 - Adicionado comando de Round de 2 nos descontos de clientes
	@history chamado 059415 - FWNM          - 05/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Ajuste na geração do E1_IDCNAB devido desativação das customizações antigas 
	@history chamado 060193 - Everson       - 11/08/2020 - Alterado os dizeres de protesto.
	@history Ticket  1715   - William Costa - 16/11/2020 - Novo boleto para a Empresa SAFEGG
	@history Ticket  T.I	- Andre Vinagre - 02/12/2020 - IMPBOLETO() - Adicionado SM0->(GetArea())SM0->(GetArea())
	@history Ticket  7075   - Sigoli        - 06/01/2010 - Alteração da instrução de protesto
/*/

User Function ADRBOL()

	Private _cDV_NNUM   := SPACE(01)
	Private _cDV_SAFRA  := SPACE(01)
	Private _cDV_BARRA  := SPACE(01)
	Private _RE_Campo   := SPACE(1) // CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
	Private _ccBARRA    := ""           
	Private _cLineDig   := ""
	Private _cNumBoleta := ""
	Private _cNBoletaBB := ""
	Private _cnDigito   := ""
	Private _cPedaco    := ""
	Private _cB_DVCam   := "" // CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17 
	Private _cNome_Bco 	:= Space(20)
	Private _cCod_Comp	:= Space(07)
	Private	_cAg_Conta  := Space(08)
	Private	ContaHSBC   := Space(08)
	Private	_cCarteira  := Space(02)
	Private	_cAceite    := Space(01)
	Private _cFatorVcto := ""
	Private	_cB_Campo  	:= ""
	Private _cCodBarras := ""
	Private cDigNNr     := ""
	Private n6_Dig      := 0
	Private n2_Dig      := 0
	Private n3_Dig      := 0
	Private n4_Dig      := 0
	Private n5_Dig      := 0
	Private n1_Dig      := 0
	Private nDigCB      := 0
	Private cVencto     := ""
	Private cVlrFim     := ""
	Private _nVlrBol    := 0
	Private _nVlrAbat   := 0
	Private cPerg       := PADR("ADRBOL",10," ")
	Private oPrint      := TReport():New("ADRBOL","Re-emissão de Boletos",,{|oPrint|fBoletaOk()})
	Private   _cConv    := "2228147" 

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Reemissão de boletos, em caso da não geração durante a rotina do faturamento')
	
	oPrint:lHeaderVisible := .F.
	
	If !Pergunte(cPerg,.T.)
		
		ValidPerg()
		lOpcA := Pergunte(cPerg,.T.)
		
		If lOpcA == .F.
			Return
		EndIf
		
	EndIf
	
	oPrint:nDevice			:= 1	// Definido Impressao Default: 			1= ARQUIVO  / 2=SPOOL
	oPrint:oPage:nPaperSize := 9	// Definido tamanho do Papel Default: 	A4
	oPrint:PrintDialog()

Return()

/*/{Protheus.doc} Static Function fBoletaOK
	Reemissão de boletos, em caso da não geração durante a rotina do faturamento
	@type  Function
	@author Lt. Paulo - TDS
	@since 25/05/2011
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function fBoletaOK()

	Local _cQuery  		:= ""
	Local _cAgencia 	:= ""
	Local _cConta 		:= ""
	Local _nRecCnt 		:= 0
	Local nTamBco		:= TamSX3("A6_COD")[1]
	Local aTMP			:= {}
	
	PRIVATE oFont1 		:= TFont():New("Arial"      	 	,09,08,,.F.,,,,,.F.)   	// Titulos dos Campos
	PRIVATE oFont1A		:= TFont():New("Arial"      	 	,09,08,,.F.,,,,,.F.)   	// Titulos dos Campos
	PRIVATE oFontA		:= TFont():New("Arial"      	 	,09,11,,.T.,,,,,.F.)   	// Nome do Banco
	PRIVATE oFont2 		:= TFont():New("Arial"      	 	,09,10,,.F.,,,,,.F.)   	// Conteudo dos Campos
	PRIVATE oFont3Bold 	:= TFont():New("Arial Black"	 	,09,18,,.T.,,,,,.F.)   	// Nome do Banco
	PRIVATE oFont4Bold 	:= TFont():New("Arial Black"	 	,09,13,,.T.,,,,,.F.)   	// Nome do Banco
	PRIVATE oFont4 		:= TFont():New("Arial"      	 	,09,12,,.T.,,,,,.F.)   	// Dados do Recibo de Entrega
	PRIVATE oFont5 		:= TFont():New("Arial"      	 	,09,18,,.T.,,,,,.F.)	// Codigo de Compensação do Banco
	PRIVATE oFont6 		:= TFont():New("Arial"          	,09,14,,.T.,,,,,.F.)	// Codigo de Compensação do Banco
	PRIVATE oFont7 		:= TFont():New("Arial"          	,09,10,,.F.,,,,,.F.)   	// Conteudo dos Campos em Negrito
	PRIVATE oFont8 		:= TFont():New("Arial"          	,09,09,,.F.,,,,,.F.)	// Dados do Cliente
	PRIVATE oFont9 		:= TFont():New("Times New Roman"    ,09,15,,.T.,,,,,.F.)	// Linha Digitavel
	PRIVATE oFont10Bold	:= TFont():New("Times New Roman"    ,09,18,,.T.,,,,,.F.)	// Nome banco HSBC - critica 270509 
	PRIVATE oFont8Bold := TFont():New("Arial"              ,09,14,,.T.,,,,,.F.) // MENSAGEM QDO FOR GMSBS
	
	Private cE1PORTADO := CriaVar("A6_COD",.F.)
	Private cE1AGEDEP  := CriaVar("A6_AGENCIA",.F.)
	Private cE1CONTA   := CriaVar("A6_NUMCON",.F.)
	
	_cQuery := "SELECT SE1.E1_FILIAL ,SE1.E1_PREFIXO,SE1.E1_NUM ,SE1.E1_PARCELA,SE1.E1_TIPO  ,SE1.E1_BANCO  , "
	_cQuery += "       SE1.E1_DVNBCO ,SE1.E1_SALDO  ,SE1.E1_ISS ,SE1.E1_INSS   ,SE1.E1_CSLL  ,SE1.E1_COFINS , "
	_cQuery += "       SE1.E1_CLIENTE,SE1.E1_LOJA   ,SE1.E1_PIS ,SE1.E1_VALLIQ ,SE1.E1_VENCTO,SE1.E1_EMISSAO, "
	_cQuery += "       SE1.E1_PARCELA,SE1.E1_PORTADO,SA1.A1_COD ,SE1.E1_VALOR  ,SA1.A1_LOJA   ,SA1.A1_NOME  , "
	_cQuery += "       SA1.A1_ZZDESCB,SA1.A1_CGC    ,SA1.A1_ENDCOB ,SA1.A1_MUNC,SA1.A1_ESTC   ,SA1.A1_CEPC  , "
	_cQuery += "       SA1.A1_BCO1   ,SA1.A1_BAIRROC "
	_cQuery += "FROM "+RetSqlName("SE1")+" SE1 ,"+RetSqlName("SA1")+" SA1 "
	_cQuery += "WHERE SE1.E1_CLIENTE = SA1.A1_COD     AND "
	_cQuery += "      SE1.E1_LOJA    = SA1.A1_LOJA    AND "
	// Solicitado pelo Sr. Reginaldo em 27/05/11 (O banco tem de ser aquele que será o cobrador do cliente)
	_cQuery += "      SA1.A1_BCO1    <> ''            AND "
	_cQuery += "      SE1.E1_FILIAL  = '"+xFilial("SE1")+"' AND "
	_cQuery += "      SE1.E1_EMISSAO BETWEEN '"+Dtos(Mv_Par01)+"' AND '"+Dtos(Mv_Par02)+"' AND "
	_cQuery += "      SE1.E1_NUM 	 = '"+Mv_Par03+"' AND "
	_cQuery += "      SE1.E1_PREFIXO = '"+Mv_Par04+"' AND "
	// Solicitado pelo Sr. Reginaldo em 08/06/11 (Deverá ser impressa a parcela seleccionada)
	_cQuery += "      SE1.E1_PARCELA = '"+Mv_Par05+"' AND "
	_cQuery += "      SE1.E1_NUMBOR  = ''             AND "
	_cQuery += "      SE1.E1_NUMBCO  = ''             AND "
	// Solicitado pelo Sr. Reginaldo em 10/06/11 (Só reemitir quando o portador estiver em branco)
	_cQuery += "      SE1.E1_PORTADO = ''             AND "
	// Solicitado pelo Sr. Reginaldo em 27/05/11 (Valor maior que zero, mesmo com baixa parcial)
	_cQuery += "      SE1.E1_SALDO   > 0              AND "
	_cQuery += "      SE1.E1_TIPO   IN ( 'NF' ,'NCI','NDI','NDC')  AND "
	_cQuery += "      SE1.E1_DATABOR = ''             AND "
	// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 27/03/2020
	_cQuery += "      SE1.E1_XWSBRAC = ''             AND "
	//
	_cQuery += "      SA1.D_E_L_E_T_ = ''             AND "
	_cQuery += "      SE1.D_E_L_E_T_ = ' ' "
	_cQuery += "ORDER BY SE1.E1_PREFIXO,SE1.E1_NUM,SE1.E1_PARCELA,SE1.E1_TIPO"
	
	TcQuery _cQuery New Alias "TSE1A"
	// Converto as datas de STRING para DATA
	TcSetField("TSE1A","E1_VENCTO","D",8,0)
	TcSetField("TSE1A","E1_EMISSAO","D",8,0)
	
	// Inicia o processo para a impressão do boleto
	dbSelectArea("TSE1A")
	TSE1A->(dbEval({|| _nRecCnt++}))
	TSE1A->(dbGoTop())
	
	dbSelectArea("SA6")
	SA6->(dbSetOrder(1))	//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
	// Se a query foi atendida - Paulo - TDS - 31/05/2011
	// Conforme solicitação do Sr. Reginaldo: se não atender as condições especificadas no filtro, emitir mensagem
	If _nRecCnt > 0
		Do While !TSE1A->(Eof())
			// Solicitado pelo Sr. Reginaldo em 27/05/11
			// Busca o banco do cliente no titulo e pesquisa no parâmetro de bancos, os dados de agencia e conta, para a formação do nosso numero
			cE1PORTADO := Posicione("SA1",1,xFilial("SA1") + TSE1A->(E1_CLIENTE + E1_LOJA),"A1_BCO1")
			
			// O portador deverá ser aquele que emite boletos, conforme o cadastro de bancos - Paulo - TDS - 15/06/2011
			SA6->(dbSeek(xFilial("SA6") + cE1PORTADO))
			Do While !SA6->(Eof()) .AND. PadR(SA6->A6_COD,nTamBco) == PadR(cE1PORTADO,nTamBco)
				If SA6->A6_ZZBLT == "S"
					_cAgencia := SA6->A6_AGENCIA
					_cConta   := SA6->A6_NUMCON
					Exit
				EndIf
				SA6->(dbSkip())
			EndDo
			If Len(aTMP := GetAdvFVal("SEE",{"EE_AGENCIA","EE_CONTA"},xFilial("SEE") + cE1PORTADO + _cAgencia + _cConta,1)) == 2
				cE1AGEDEP := aTMP[1]
				cE1CONTA  := aTMP[2]
			Endif		
			// Calcula Nosso Numero
			fCalcBlt(TSE1A->E1_PREFIXO,TSE1A->E1_NUM,TSE1A->E1_PARCELA,TSE1A->E1_TIPO)
			
			// Impressão do Boleto
			IMPBOLETO()
			
			oPrint:EndPage()
			
			TSE1A->(dbSkip())
			
		EndDo
	Else
		// Solicitado pelo Sr. Reginaldo em 31/05/2011 - As condições do filtro não foram satisfeitas, emite a mensagem abaixo
		ApMsgAlert(OemToAnsi("Não foi possivel fazer a re-emissão de boleto para o titulo informado."),OemToAnsi("A T E N Ç Ã O"))
	EndIf
	Ms_Flush()
	U_FecArTMP("TSE1A")

Return

/*/{Protheus.doc} Static Function IMPBOLETO
	Reemissão de boletos, em caso da não geração durante a rotina do faturamento
	@type  Function
	@author Lt. Paulo - TDS
	@since 25/05/2011
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function IMPBOLETO()

	Local aAreaSM0 := SM0->(GetArea())
	//Foi adicionado a filial 01, pq sempre tem que ir para Adoro Matriz, e para as outras filiais. WILLIAM COSTA - 16/11/2020
	Private cNome     := ALLTRIM(Posicione("SM0",1,cEmpAnt+'01',"M0_NOMECOM")) + ', ' // alteração chamado 022248 - William Costa
	Private cEndereco := ALLTRIM(Posicione("SM0",1,cEmpAnt+'01',"M0_ENDENT"))  + ', ' // alteração chamado 022248 - William Costa
	Private cBairro   := ALLTRIM(Posicione("SM0",1,cEmpAnt+'01',"M0_BAIRENT")) + ', ' // alteração chamado 022248 - William Costa
	Private cCidade   := ALLTRIM(Posicione("SM0",1,cEmpAnt+'01',"M0_CIDENT"))  + ', ' // alteração chamado 022248 - William Costa
	Private cCNPJ     := ALLTRIM(Posicione("SM0",1,cEmpAnt+'01',"M0_CGC"))            // alteração chamado 022248 - William Costa
	
	cCNPJ     := transform(cCNPJ,"@R 99.999.999/9999-99")                       // alteração chamado 022248 - William Costa

	// Primeira Parte da Boleta
	
	If cE1PORTADO $ "001/655/KOB"
		oPrint:Say(1139,0100,_cNome_Bco,oFont4Bold,100)
		oPrint:Say(1150,0700,_cCod_Comp,oFont6,100)
	ElseIf cE1PORTADO $ "399/637"
		oPrint:Say(1135,0100,_cNome_Bco,oFont10Bold,100)
		oPrint:Say(1150,0700,_cCod_Comp,oFont5,100)
	ElseIf cE1PORTADO $ "422/SAF/SFF" //ALEX BORGES 03/04/12
		oPrint:Say(1135,0100,_cNome_Bco,oFont4Bold,100)
		oPrint:say(1150,0700,_cCod_Comp,oFont5,100)	
	
	Elseif cE1PORTADO == "104"   	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
		oPrint:Saybitmap(1135,0100,"cef.BMP",0280,100)
		
	Elseif cE1PORTADO $ "341/ITV"   	// 	// itau 032158 sigoli 13/07/18
		oPrint:Saybitmap(1135,0100,"ITAU.BMP",0280,100)
		//oPrint:say(1150,0700,_cCod_Comp,oFont5,100)	
		
	Else
		oPrint:Say(1135,0100,_cNome_Bco,oFont3Bold,100)
		oPrint:Say(1150,0700,_cCod_Comp,oFont5,100)
	EndIf
	
	oPrint:Say(1160,1700,"RECIBO DO PAGADOR",oFont4,100)
	
	oPrint:Box(1230,0100,1310,1500)
	oPrint:Box(1230,1500,1310,2200)
	oPrint:Box(1310,0100,1390,1500)
	oPrint:Box(1310,1500,1390,2200)
	
	If cE1PORTADO == '033'
		oPrint:Box(1390,0100,1470,0397)	// Data Documento
		oPrint:Box(1390,0397,1470,0694)	// Numero Documento
		oPrint:Box(1390,0694,1470,0991)	// Esp. Doc.
		oPrint:Box(1390,0991,1470,1181) // Aceite
		oPrint:Box(1390,1181,1470,1500)	// Data Proces.
		oPrint:Box(1390,1500,1470,2200)	// Nosso Numero
		
		oPrint:Box(1470,0100,1550,0650)	// Carteira
		oPrint:Box(1470,0500,1550,0650)	// Especie
		oPrint:Box(1470,0650,1550,1060)	// Quantidade
		oPrint:Box(1470,1060,1550,1500)	// Valor
		oPrint:Box(1470,1500,1550,2200)	// Valor Documento 
		
	ElseIf cE1PORTADO $ '422/SAF/SFF'  // ALEX BORGES 03/04/12
	//ElseIf cE1PORTADO == '422'
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
		oPrint:Box(1390,0100,1470,0350)	// Data Documento
		oPrint:Box(1390,0350,1470,0700)	// Numero Documento
		oPrint:Box(1390,0700,1470,0850)	// Esp. Doc.
		oPrint:Box(1390,0850,1470,1060) // Aceite
		oPrint:Box(1390,1060,1470,1500)	// Data Proces.
		oPrint:Box(1390,1500,1470,2200)	// Nosso Numero
		
		oPrint:Box(1470,0100,1550,0350)	// Uso do Banco
		oPrint:Box(1470,0350,1550,0500)	// Carteira
		oPrint:Box(1470,0500,1550,0650)	// Especie
		oPrint:Box(1470,0650,1550,1060)	// Quantidade
		oPrint:Box(1470,1060,1550,1500)	// Valor
		oPrint:Box(1470,1500,1550,2200)	// Valor Documento
		
	EndIf
	
	oPrint:Box(1550,0100,1950,1500)
	oPrint:Box(1550,1500,1630,2200)
	oPrint:Box(1630,1500,1710,2200)
	oPrint:Box(1710,1500,1790,2200)
	oPrint:Box(1790,1500,1870,2200)
	oPrint:Box(1870,1500,1950,2200)
	oPrint:Box(1950,0100,2150,2200)
	
	If cE1PORTADO $ "341/655/KOB/ITV"
		oPrint:Say(1230,0120,"Local de Pagamento  " ,oFont1,100)
		oPrint:Say(1230,0120,"                             ATÉ O VENCIMENTO PAGUE PREFERENCIALMENTE NO ITAÚ",oFont2,100)
	Else
		oPrint:Say(1230,0120,"Local de Pagamento",oFont1,100)
	EndIf
	
	oPrint:Say(1230,1520,"Vencimento",oFont1,100)
	
	If cE1PORTADO $ "237|246|RED|BRD|BRV" // CHAMADO 050420
		oPrint:Say(1260,0120,"PAGAVEL PREFERENCIALMENTE NAS AGENCIAS DO BRADESCO",oFont2,100)
	ElseIf cE1PORTADO $ "399/637"
		oPrint:Say(1260,0120,"PAGAR PREFERENCIALMENTE EM AGÊNCIA DO HSBC",oFont2,100)
	ElseIf cE1PORTADO == "341/KOB/ITV"	// ITAU
		oPrint:Say(1270,0120,"APÓS O VENCIMENTO PAGUE SOMENTE NO ITAÚ",oFont2,100)
	ElseIf cE1PORTADO $ "SAF"	// SAFRA
		oPrint:say(1260,0120,"Até a data do vencimento pagável em qualquer banco.Após o vencimento, apenas nas agências do Bradesco",oFont1A,100)
	ElseIf cE1PORTADO == "001"	// Banco do Brasil       //Renato, incluido por solicitação do banco em 26/10/2011
		oPrint:say(1260,0120,"PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO",oFont2,100)	
	ElseIf cE1PORTADO == "104"	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
		oPrint:say(1260,0120,"PREFERENCIALMENTE NAS CASAS LOTERICAS ATE O VALOR LIMITE",oFont2,100)
	Else
		oPrint:Say(1260,0120,"PAGAVEL EM QUALQUER BANCO ATE A DATA DE VENCIMENTO",oFont2,100)
	EndIf
	
	_dDtAux1 := DtoS(TSE1A->E1_VENCTO)
	_dDtAux2 := SubStr(_dDtAux1,7,2) + "/" + SubStr(_dDtAux1,5,2) + "/" + SubStr(_dDtAux1,1,4)
	oPrint:Say(1260,1930,_dDtAux2,oFont9,100)
	
	oPrint:Say(1310,0120,"Beneficiario",oFont1,100)
	
	If cE1PORTADO == "033"
		oPrint:Say(1310,1520,"Agência/Ident.Pagador",oFont1,100)
	Else
		oPrint:Say(1310,1520,"Agência/Código Beneficiario",oFont1,100)
	EndIf
	
	If cE1PORTADO == '655'
		oPrint:Say(1340,0120,"BANCO VOTORANTIM S/A",oFont2,100)
	ElseIf cE1PORTADO == '637' // 02/09 Alex Borges
			oPrint:say(1340,0120,"BANCO SOFISA S/A",oFont2,100)   
	ElseIf cE1PORTADO $ 'SAF'  //ALEX BORGES 03/04/12
		oPrint:say(1340,0120,"BANCO SAFRA S/A",oFont2,100)
	ElseIf cE1PORTADO == 'RED' // ALEX BORGES 09/04/12
		oPrint:say(1340,0120,"RED S/A",oFont2,100)
	ElseIf cE1PORTADO == 'KOB'
		//oPrint:say(1340,0120,"KOBOLD FIDC MERC FINANC II          CNPJ - 10.756.703/0001-06",oFont2,100)	
		oPrint:say(1340,0120,"KOBOLD MFS FUNDO INVES EM DIREITOS CREDIT NÃO-PADRONIZADOS CNPJ: 10.756.703/0001-06",oFont2,100)
	ElseIf cE1PORTADO == 'BRD'
		oPrint:say(1340,0120,"GMSBS PRESTACOES DE SERVICOS S/A     CNPJ:  13.362.692/0001-60",oFont2,100)	
	ElseIf cE1PORTADO == '104' //   // CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17    
		
		oPrint:say(1310,0260,"ADORO S/A                          CNPJ: "+cCNPJ,oFont2,100)	
		oPrint:say(1345,0120,cEndereco+" "+cBairro+" "+cCidade,oFont1,100)
		
	ElseIf  cE1PORTADO = 'SFF' // fernando sigoli 30/04/2018 
	 
		oPrint:say(1310,0260,"ADORO S/A                  CNPJ:  60.037.058/0001-31" ,oFont2,100)
		oPrint:say(1345,0120,cEndereco+" "+cBairro+" "+cCidade,oFont1,100) 
	
	Else

		IF cEmpAnt == '01'                   

			oPrint:say(1310,0260,"ADORO S/A                  CNPJ: "+cCNPJ ,oFont2,100)

		ELSE 
	
			oPrint:say(1310,0260, SUBSTRING(cNome,1,9) + "                  CNPJ: "+cCNPJ ,oFont2,100)


		ENDIF
		
		oPrint:say(1345,0120,cEndereco+" "+cBairro+" "+cCidade,oFont1,100) 
		
	EndIf
	                    
	
	If cE1PORTADO = '399'
		oPrint:Say(1340,1700,ContaHSBC,oFont7,100) 
		
	ElseIf cE1PORTADO $ '422/SFF'                            //fernando Sigoli 08/11/2017 - 
		oPrint:say(1340,1700,Substr(_cAg_Conta,1,4)+Substr(_cAg_Conta,6,1)+'/'+padl(Substr(_cAg_Conta,8,6),8,"0")+;
		Substr(_cAg_Conta,15,1),oFont7,100)
		
	ElseIf cE1PORTADO $ '341/ITV'  // fernando Sigoli 13/07/2018
		oPrint:say(1340,1950,_cAg_Conta,oFont7,100)
	
	Else
	
		oPrint:Say(1340,1700,_cAg_Conta,oFont7,100)
	
	EndIf
	
	If cE1PORTADO == '033'
		oPrint:Say(1390,0120,"Data do Documento",oFont1,100)
		oPrint:Say(1390,0417,"Número Documento",oFont1,100)
		oPrint:Say(1390,0714,"Espécie Documento",oFont1,100)
		oPrint:Say(1390,1050,"Aceite",oFont1,100)
		oPrint:Say(1390,1201,"Data Processamento",oFont1,100)
	Else
		oPrint:Say(1390,0120,"Dt Documento",oFont1,100)
		oPrint:Say(1390,0360,"Número do Documento",oFont1,100)
		oPrint:Say(1390,0720,"Esp.Doc.",oFont1,100)
		oPrint:Say(1390,0870,"Aceite",oFont1,100)
		oPrint:Say(1390,1080,"Data Processamento",oFont1,100)
	EndIf
	
	oPrint:Say(1390,1520,"Nosso Número",oFont1,100)
	
	If cE1PORTADO == '033'
		oPrint:Say(1420,0120,DtoC(TSE1A->E1_EMISSAO),oFont2,100)
		oPrint:Say(1420,0417,AllTrim(TSE1A->E1_PREFIXO)+"-"+AllTrim(TSE1A->E1_NUM)+If(!Empty(TSE1A->E1_PARCELA),"-"+TSE1A->E1_PARCELA,""),oFont2,100) // Numero do Documento
	Else
		oPrint:Say(1420,0120,DtoC(TSE1A->E1_EMISSAO),oFont2,100)
		oPrint:Say(1420,0370,AllTrim(TSE1A->E1_PREFIXO)+"-"+AllTrim(TSE1A->E1_NUM)+If(!Empty(TSE1A->E1_PARCELA),"-"+TSE1A->E1_PARCELA,""),oFont2,100) // Numero do Documento
	EndIf
	
	//correcao da data para dois digitos
	
	If cE1PORTADO $ "399/637"
		oPrint:Say(1420,0720,"PD",oFont2,100)
		oPrint:Say(1420,0870,"NÃO",oFont2,100)
		oPrint:Say(1420,1090,Dtoc(Date()),oFont2,100)	// Reginaldo 12/09/08
	ElseIf cE1PORTADO == "033"
		oPrint:Say(1420,0714,"DM",oFont2,100)
		oPrint:Say(1420,1050,_cAceite,oFont2,100)
		oPrint:Say(1420,1201,Dtoc(Date()),oFont2,100)	// Reginaldo 12/09/08
	ElseIf cE1PORTADO $ "341/655/KOB/ITV"
		oPrint:Say(1420,0714,"DP",oFont2,100)
		oPrint:Say(1420,1000,_cAceite,oFont2,100)
		oPrint:Say(1420,1201,Dtoc(Date()),oFont2,100)	// Reginaldo 12/09/08
	Else
		oPrint:Say(1420,0720,"DM",oFont2,100)
		oPrint:Say(1420,0870,_cAceite,oFont2,100)
		oPrint:Say(1420,1090,Dtoc(Date()),oFont2,100)	// Reginaldo 12/09/08
	EndIf
	
	Do Case
		Case cE1PORTADO $ "422/SAF/SFF" // Banco Safra   //ALEX BORGES 03/04/12
			
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
			        oPrint:Say(1420,1700,_cCarteira+"/"+SubStr(_cNumBoleta,1,11)+"-"+_cDV_NNUM,oFont7,100)
			    EndIf
			
		Case cE1PORTADO $ "237|RED|BRD|BRV|" // Bradesco / RED FACTOR // *** INICIO CHAMADO 050420
			oPrint:Say(1420,1700,_cCarteira+"/"+SubStr(_cNumBoleta,1,11)+"-"+_cDV_NNUM,oFont7,100)
		Case cE1PORTADO == "246" // ABC
			oPrint:Say(1420,1700,_cCarteira+"/"+SubStr(_cNumBoleta,1,11)+"-"+_cDV_NNUM,oFont7,100)
		Case cE1PORTADO == '001' // Banco do Brasil
			//Mauricio 19/10/11 - Substituido para impressao sem digito do nosso numero conforme solicitado Sr.Renato/Reginaldo.
			//oPrint:Say(1420,1700,_cNumBoleta+"-"+_cDV_NNUM,oFont7,100)
			oPrint:Say(1420,1700,_cNumBoleta,oFont7,100)
		
		Case cE1PORTADO == "033" // SANTANDER
			oPrint:Say(1420,1700,SubStr(_cNumBoleta,6,7)+" "+_cDV_NNUM,oFont7,100)
		
		Case cE1PORTADO $ "399/637" // HSBC
			oPrint:Say(1420,1700,_cNumBoleta+"-"+_cDV_NNUM,oFont7,100)
		
		Case cE1PORTADO $ "655/KOB" // ITAU E VOTORANTIM
			oPrint:Say(1420,1700,"109/"+_cNumBoleta+"-"+_cDV_NNUM,oFont7,100) 	// 102 E A CARTEIRA ? VERIFICAR NO SUPORTE
		
		Case cE1PORTADO $ "341/ITV" // ITAU 13/07/2018 
			oPrint:Say(1420,1910,"109" + "/" + _cNumBoleta+"-"+_cDV_NNUM,oFont7,100) 
		
		Case cE1PORTADO == "104"  // CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
			oPrint:say(1420,1700,Substr(_cNumBoleta,1,17)+"-"+_cDV_NNUM,oFont7,100) 
	EndCase
	
	If  cE1PORTADO == "033"
		oPrint:Say(1470,0120,"Carteira",oFont1,100)
		oPrint:Say(1470,0520,"Espécie",oFont1,100)
		oPrint:Say(1470,0670,"Quantidade",oFont1,100)
		oPrint:Say(1470,1090,"Valor",oFont1,100)
	ElseIf cE1PORTADO $ "422/SAF/SFF"  //ALEX BORGES 03/04/12
		oPrint:say(1470,0120,"Data de Operação",oFont1,100)
	    oPrint:say(1470,0360,"CIP",oFont1,100)
		oPrint:say(1470,0405,"Carteira",oFont1,100)
		oPrint:say(1470,0520,"Espécie",oFont1,100)
		oPrint:say(1470,0670,"Quantidade",oFont1,100)
		oPrint:say(1470,1090,"Valor",oFont1,100)	
	Else
		oPrint:Say(1470,0120,"Uso do Banco",oFont1,100)
		oPrint:Say(1470,0370,"Carteira",oFont1,100)
		oPrint:Say(1470,0520,"Espécie",oFont1,100)
		oPrint:Say(1470,0670,"Quantidade",oFont1,100)
		oPrint:Say(1470,1090,"Valor",oFont1,100)
	EndIf
	
	oPrint:Say(1470,1520,"(=) Valor do Documento",oFont1,100)
	
	If  cE1PORTADO == "033"
		oPrint:Say(1500,120,"SIMPLES - RCR",oFont2,100)
		oPrint:Say(1500,520,"REAL",oFont2,100)
	ElseIf cE1PORTADO $ "422/SAF/SFF" // ALEX BORGES 03/04/12
		oPrint:say(1500,120,Dtoc(dDataBase),oFont2,100)
	    oPrint:say(1500,350,"130",oFont2,100)
		oPrint:say(1500,410,_cCarteira,oFont2,100)
		oPrint:say(1500,520,"R$",oFont2,100)	
	Else
		oPrint:Say(1500,370,_cCarteira,oFont2,100)
		oPrint:Say(1500,520,"R$",oFont2,100)
	EndIf
	
	oPrint:Say(1500,1900,Transform(_nVlrBol,"@E 999,999,999.99"),oFont9,100)
	oPrint:Say(1550,120,"Instruções",oFont1,100)
	oPrint:Say(1550,120,"                 " + "(Todas as informações deste bloqueto são de exclusiva responsabilidade do Beneficiario)",oFont1A,100)
	
	If cE1PORTADO == "033"
		oPrint:Say(1550,1520,"(-) Desconto",oFont1,100)
	Else
		oPrint:Say(1550,1520,"(-) Desconto/Abatimento",oFont1,100)
	EndIf
	
	If !cE1PORTADO $ "001|237|246|422|SFF|SAF|RED|BRD|104|341|BRV|ITV" // CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17 // *** INICIO CHAMADO 050420
		oPrint:Say(1580,1750,Transform(_nVlrAbat,"@E 999,999,999.99"),oFont7,100)
	EndIf
	
	If cE1PORTADO == "033"
		oPrint:Say(1630,1520,"(-) Abatimento",oFont1,100)
		oPrint:Say(1710,1520,"(+) Mora",oFont1,100)
	ElseIf cE1PORTADO $ "655"
		oPrint:Say(1630,1520,"",oFont1,100)
		oPrint:Say(1710,1520,"(+) Mora/Multa",oFont1,100)
	Else
		oPrint:Say(1630,1520,"(-) Outras Deduções",oFont1,100)
		oPrint:Say(1710,1520,"(+) Mora/Multa",oFont1,100)
	EndIf
	
	If !(cE1PORTADO $ "655")
		oPrint:Say(1790,1520,"(+) Outros Acréscimos",oFont1,100)
	EndIf
	
	oPrint:Say(1870,1520,"(=) Valor Cobrado",oFont1,100)
	oPrint:Say(1950,0120,"Pagador",oFont1,100)
	oPrint:Say(1970,0250,TSE1A->A1_NOME,oFont8,100)
	oPrint:Say(1970,1500,Transform(TSE1A->A1_CGC,"@R 99.999.999/9999-99"),oFont8,100)
	oPrint:Say(2010,0250,TSE1A->A1_ENDCOB+" "+TSE1A->A1_BAIRROC,oFont8,100)
	oPrint:Say(2050,0250,TSE1A->A1_CEPC+" "+TSE1A->A1_MUNC+TSE1A->A1_ESTC,oFont8,100)
	oPrint:Say(2100,0120,"Sacador/Avalista",oFont1,100)
	
	If cE1PORTADO != "033"
		oPrint:Say(2100,1520,"Cód.Baixa",oFont1,100)
		oPrint:Say(2095,1720,"Autenticação Mecânica",oFont1,100)
	EndIf
	
	If cE1PORTADO $ "655/637/SAF/KOB/RED/BRD" // 02/09 - Alex Borges
		oPrint:say(2100,0400, cNome + cEndereco + cCidade + cCNPJ ,oFont1,100) // alteração chamado 022248 - William Costa
	    
	EndIf
	
	If cE1PORTADO $ "SAF" // ALEX BORGES 03/04/12
		oPrint:say(2100,0400,"GMSBS PRESTACOES DE SERVICOS S/A     CNPJ:  13.362.692/0001-60",oFont1,100)
	Endif	
	
	oPrint:Say(2140,0001,replicate(".",1900),oFont1,100)
	
	// Impressao das Instrucoes
	
	_nLinInst := 1580
	//_nLinInst := 1480 //FERNANDO SIGOLI 02/05/2018
	
	If !(cE1PORTADO $ "655/422/SFF/KOB/SAF")
		
	    	oPrint:say(_nLinInst,0120,"*** VALORES EXPRESSOS EM REAIS *** ",oFont8,100)	// Instruções 
	
	EndIf
	
	_nLinInst += 50
	
	If cE1PORTADO == "246"
		oPrint:Say(_nLinInst,0120,"Título transferido ao Banco ABC Brasil S/A.",oFont8,100)	// Instruções
	EndIf
	
	_nLinInst += 50
	
	//Incluido 26/04/11
	
	If cE1PORTADO == '655'
		oPrint:Say(_nLinInst,0120,"Titulo entregue em cessão fiduciaria em favor do Pagador acima" ,oFont8,100)
		_nLinInst += 50
	EndIf    
	
	//If cE1PORTADO $ "422/SAF"
	//If cE1PORTADO == '422'    
	If cE1PORTADO $ "SAF/SFF" 
	
		If SEE->EE_ZZMORA > 0	
			nValMora := ( _nVlrBol * ( SEE->EE_ZZMORA / 100) ) / 30 	
			oPrint:Say(_nLinInst,0120,"Não dispensar mora de R$ " + Alltrim(Transform(nValMora,"@E 999,999,999.99")) + " por dia de atraso" ,oFont8,100)
			_nLinInst += 00050
		Endif
	
		If SEE->EE_ZZDIAAT > 0 .AND. SEE->EE_ZZPERMU > 0
			oPrint:Say(_nLinInst,0120,"Após o vencimento cobrar multa de R$ " + Alltrim(Transform(_nVlrBol * (SEE->EE_ZZPERMU/100),"@E 999,999.99")),oFont8,100)
			_nLinInst += 00050
		Endif 
		
		If TSE1A->A1_ZZDESCB > 0 .AND. TSE1A->E1_TIPO <> 'NDC'
		
			oPrint:Say(_nLinInst,0120,"Conceder desconto de R$ " + Alltrim(Transform(ROUND(_nVlrBol * (TSE1A->A1_ZZDESCB/100),2),"@E 999,999.99")),oFont8,100) //Chamado: 048733 Fernando Sigoli 29/04/2019
			_nLinInst += 50

		EndIf
		//
		If SEE->EE_ZZDDPRO > 0
		   //oPrint:Say(_nLinInst,0120,"Após " + Strzero(SEE->EE_ZZDDPRO,2) + " dias do vencimento, protestar o titulo ",oFont8,100)
			 oPrint:Say(_nLinInst,0120,"SUJEITO A PROTESTO APÓS O VENCIMENTO" ,oFont8,100) //tkt 7075 -  Fernando Sigoli - Alteração da instrução de protesto
			_nLinInst += 00050
		Endif
	    //	
		If cE1PORTADO == "SAF" 
			_nLinInst += 00025
			oPrint:Say(_nLinInst,0120,"BOLETO REFERENTE A NF "+ Alltrim(TSE1A->E1_NUM) + Iif(!Empty(TSE1A->E1_PARCELA),"-" +TSE1A->E1_PARCELA,"")+" EMITIDA POR AD'ORO S/A",oFont8Bold,100)
			_nLinInst += 00050
		Endif	
		//
		If cE1PORTADO = "SFF" 
			//_nLinInst += 00025
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
			oPrint:Say(_nLinInst,0120,"DIREITO DE CREDITO CEDIDO AO PAGADOR - PAGAVEL SOMENTE EM BANCO" ,oFont8,100)
			_nLinInst += 00050
			oPrint:Say(_nLinInst,0120,"COBRANCA ESCRITURAL" ,oFont8,100)
			_nLinInst += 00050 
			oPrint:Say(_nLinInst,0120,"SUJEITO A PROTESTO APÓS O VENCIMENTO" ,oFont8,100) //Everson - 11/08/2020. Chamado 060193.
			_nLinInst += 00050						
		Endif	    
		
		If TSE1A->A1_ZZDESCB > 0 .AND. TSE1A->E1_TIPO <> 'NDC'
			
			oPrint:Say(_nLinInst,0120,"Conceder desconto de R$ " + Alltrim(Transform(ROUND(_nVlrBol * (TSE1A->A1_ZZDESCB/100),2),"@E 999,999.99")),oFont8,100) //Chamado: 048733 Fernando Sigoli 29/04/2019
			_nLinInst += 50

		EndIf	
	
	
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
			_nLinInst += 50
		EndIf
	
		If SEE->EE_ZZDDPRO > 0
		  //oPrint:Say(_nLinInst,0120,"Após " + Strzero(SEE->EE_ZZDDPRO,2) + " dias do vencimento, protestar o titulo ",oFont8,100)
			oPrint:Say(_nLinInst,0120,"SUJEITO A PROTESTO APÓS O VENCIMENTO" ,oFont8,100) //tkt 7075 -  Fernando Sigoli - Alteração da instrução de protesto
			_nLinInst += 50
		EndIf
	
		If SEE->EE_ZZDIAAT > 0 .And. SEE->EE_ZZPERMU > 0
			oPrint:Say(_nLinInst,0120,"Após o " + AllTrim(Str(SEE->EE_ZZDIAAT)) + "° dia útil do vencimento cobrar multa de " + Transform(SEE->EE_ZZPERMU,"@E 999,999.99") + "%",oFont8,100)
			_nLinInst += 50
		EndIf
	
		If TSE1A->A1_ZZDESCB > 0 .AND. TSE1A->E1_TIPO <> 'NDC'
		  
			oPrint:Say(_nLinInst,0120,"Conceder desconto de R$ " + Alltrim(Transform(ROUND(_nVlrBol * (TSE1A->A1_ZZDESCB/100),2),"@E 999,999.99")),oFont8,100) //Chamado: 048733 Fernando Sigoli 29/04/2019
			_nLinInst += 50

		EndIf
		
		If cE1PORTADO == "BRD" 
			_nLinInst += 00025
			oPrint:Say(_nLinInst,0120,"BOLETO REFERENTE A NF "+ Alltrim(TSE1A->E1_NUM) + Iif(!Empty(TSE1A->E1_PARCELA),"-" +TSE1A->E1_PARCELA,"")+" EMITIDA POR AD'ORO S/A",oFont8Bold,100)
			_nLinInst += 00050
		Endif	
	
		  
	Endif	
	
	oPrint:Say(_nLinInst,0120,Mv_Par06,oFont8,100)	// Instruções de parametro
	_nLinInst += 50
	oPrint:Say(_nLinInst,0120,Mv_Par07,oFont8,100)   	// Instruções de parametro
	
	//Segunda parte da Boleta
	//Montar a Linha Digitavel da Boleta
	MontaLinha()
	
	//Segunda Parte da Boleta
	If cE1PORTADO $ "001/655/KOB"
		oPrint:Say(002198,0100,_cNome_Bco,oFont4Bold,100)
		oPrint:Say(002210,0580,_cCod_Comp,oFont6,100)
	ElseIf cE1PORTADO $ "399/637"
		oPrint:Say(002195,0100,_cNome_Bco,oFont10Bold,100)
		oPrint:Say(002210,0570,_cCod_Comp,oFont5,100)
	ElseIf cE1PORTADO $ "422/SAF/SFF"   //ALEX BORGES 03/04/12 
		
		oPrint:Say(002195,0100,_cNome_Bco,oFont4Bold,100) //05/12/2017  
		oPrint:say(002210,0570,_cCod_Comp,oFont5,100)		
	
	Elseif cE1PORTADO =="104"	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
		oPrint:Saybitmap(002195,0100,"cef.BMP",0280,100)   
		oPrint:say(002210,0590,_cCod_Comp,oFont5,100)
	
	Elseif cE1PORTADO $ "341/ITV"		// itau 032158 sigoli 13/07/18
		oPrint:Saybitmap(002195,0100,"ITAU.BMP",0280,100)   
		oPrint:say(002210,0590,_cCod_Comp,oFont5,100)
		
				
	Else
		oPrint:Say(002195,0100,_cNome_Bco,oFont3Bold,100)
		oPrint:Say(002210,0570,_cCod_Comp,oFont6,100)
	EndIf
	
	//Impressão da Linha Digitavel
	oPrint:Say(002220,0770,_cLineDig,oFont9,080)
	
	oPrint:Box(002290,0100,2370,1500)
	oPrint:Box(002290,1500,2370,2200)
	oPrint:Box(002370,0100,2450,1500)
	oPrint:Box(002370,1500,2450,2200)
	
	If cE1PORTADO == '033'
		
		oPrint:Box(002450,0100,2530,0397)	// Data Documento
		oPrint:Box(002450,0397,2530,0694)	// Numero Documento
		oPrint:Box(002450,0694,2530,0991)	// Esp. Doc.
		oPrint:Box(002450,0991,2530,1181)	// Aceite
		oPrint:Box(002450,1181,2530,1500)	// Data Proces.
		oPrint:Box(002450,1500,2530,2200)	// Nosso Numero
		
		oPrint:Box(002530,0100,2610,0500)	// Carteira
		oPrint:Box(002530,0500,2610,0650)	// Especie
		oPrint:Box(002530,0650,2610,1060)	// Quantidade
		oPrint:Box(002530,1060,2610,1500)	// Valor
		oPrint:Box(002530,1500,2610,2200)	// Valor Documento         
		
	ElseIf cE1PORTADO $ '422/SAF/SFF'  //ALEX BORGES 03/04/12
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
		
		oPrint:Box(002450,0100,2530,0350)
		oPrint:Box(002450,0350,2530,0700)
		oPrint:Box(002450,0700,2530,0850)
		oPrint:Box(002450,0850,2530,1060)
		oPrint:Box(002450,1060,2530,1500)
		oPrint:Box(002450,1500,2530,2200)
		oPrint:Box(002530,0100,2610,0350)
		oPrint:Box(002530,0350,2610,0500)
		oPrint:Box(002530,0500,2610,0650)
		oPrint:Box(002530,0650,2610,1060)
		oPrint:Box(002530,1060,2610,1500)
		oPrint:Box(002530,1500,2610,2200)
		
	EndIf
	
	oPrint:Box(002610,0100,3010,1500)
	oPrint:Box(002610,1500,2690,2200)
	oPrint:Box(002690,1500,2770,2200)
	oPrint:Box(002770,1500,2850,2200)
	oPrint:Box(002850,1500,2930,2200)
	oPrint:Box(002930,1500,3010,2200)
	oPrint:Box(003010,0100,3210,2200)
	
	If cE1PORTADO $ "341/655/KOB/ITV"
		oPrint:Say(002290,0120,"Local de Pagamento",oFont1,100)
		oPrint:Say(002290,0120,"                               ATÉ O VENCIMENTO PAGUE PREFERENCIALMENTE NO ITAÚ",oFont2,100)
	Else
		oPrint:Say(002290,0120,"Local de Pagamento",oFont1,100)
	EndIf
	
	oPrint:Say(002290,1520,"Vencimento",oFont1,100)
	
	If cE1PORTADO $ "237|246|RED|BRD|BRV" // *** INICIO CHAMADO 050420
		oPrint:Say(002320,0120,"PAGAVEL PREFERENCIALMENTE NAS AGENCIAS DO BRADESCO",oFont2,100)
	ElseIf cE1PORTADO $ "399/637"
		oPrint:Say(002320,0120,"PAGAR PREFERENCIALMENTE EM AGÊNCIA DO HSBC",oFont2,100)
	ElseIf cE1PORTADO $ "341/655/KOB/ITV"	// ITAU/VOTORANTIM
		oPrint:Say(002320,0120,"APÓS O VENCIMENTO PAGUE SOMENTE NO ITAÚ",oFont2,100)
	ElseIf cE1PORTADO $ "SAF"   // SAFRA   ALEX BORGES 03/04/12
		oPrint:say(002320,0120,"Até a data do vencimento pagável em qualquer banco. Após o vencimento, apenas nas agências do Bradesco",oFont1A,100)		
	ElseIf cE1PORTADO == "001"	// Banco do Brasil       //Renato, incluido por solicitação do banco em 26/10/2011
		oPrint:say(002320,0120,"PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO",oFont2,100)	
	ElseIf cE1PORTADO == "104"	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
		oPrint:say(002320,0120,"PREFERENCIALMENTE NAS CASAS LOTERICAS ATE O VALOR LIMITE",oFont2,100)
	Else
		oPrint:Say(002320,0120,"PAGAVEL EM QUALQUER BANCO ATE A DATA DE VENCIMENTO",oFont2,100)
	EndIf
	
	_dDtAux1 := DtoS(TSE1A->E1_VENCTO)
	_dDtAux2 := SubStr(_dDtAux1,7,2) + "/" + SubStr(_dDtAux1,5,2) + "/" + SubStr(_dDtAux1,1,4)
	oPrint:Say(002320,1930,_dDtAux2,oFont9,100)
	
	oPrint:Say(002370,0120,"Beneficiario",oFont1,100)
	
	If cE1PORTADO == "033"
		oPrint:Say(002370,1520,"Agência/Ident.Pagador",oFont1,100)
	Else
		oPrint:Say(002370,1520,"Agência/Código Beneficiario",oFont1,100)
	EndIf
	
	If cE1PORTADO == '655'
		oPrint:Say(002400,0120,"BANCO VOTORANTIM S/A",oFont2,100)
	ElseIf cE1PORTADO == '637' //02/09 - Alex Borges
			oPrint:say(002400,0120,"BANCO SOFISA S/A",oFont2,100)
	ElseIf cE1PORTADO $ "SAF"  // ALEX BORGES 03/04/12
		oPrint:say(002400,0120,"BANCO SAFRA S/A",oFont2,100)		
	ElseIf cE1PORTADO == 'RED' // ALEX BORGES 09/04/12
		oPrint:say(002400,0120,"RED S/A",oFont2,100)
	ElseIf cE1PORTADO == 'KOB'
	   //oPrint:say(002400,0120,"KOBOLD FIDC MERC FINANC II          CNPJ - 10.756.703/0001-06",oFont2,100)  /fernando sigoli 03/05/2018
		oPrint:say(002400,0120,"KOBOLD MFS FUNDO INVES EM DIREITOS CREDIT NÃO-PADRONIZADOS CNPJ: 10.756.703/0001-06",oFont2,100)
	ElseIf cE1PORTADO == 'BRD'
		oPrint:say(002400,0120,"GMSBS PRESTACOES DE SERVICOS S/A     CNPJ:  13.362.692/0001-60",oFont2,100)	
	ElseIf cE1PORTADO == '104'	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
	
		oPrint:say(002370,0260,"ADORO S/A                  CNPJ: "+cCNPJ,oFont2,100)
		oPrint:say(002405,0120,cEndereco+" "+cBairro+" "+cCidade,oFont1,100)
		
	ElseIf cE1PORTADO = 'SFF'	//  fernando sigoli 30/04/2018
	
		oPrint:say(002370,0260,"ADORO S/A                  CNPJ: 60.037.058/0001-31 ",oFont2,100)
		oPrint:say(002405,0120,cEndereco+" "+cBairro+" "+cCidade,oFont1,100)
		
	ElseIf cE1PORTADO = 'BRV'	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17 // *** INICIO CHAMADO 050420
	  
		oPrint:say(002370,0260,"ADORO S/A                  CNPJ: 60.037.058/0001-31 ",oFont2,100)
		oPrint:say(002405,0120,cEndereco+" "+cBairro+" "+cCidade,oFont1,100)
	Else 
	
		oPrint:say(002370,0260,"ADORO S/A                  CNPJ: "+cCNPJ ,oFont2,100)
		oPrint:say(002405,0120,cEndereco+" "+cBairro+" "+cCidade,oFont1,100) 
	
	EndIf
	                                                        
	
	If cE1PORTADO = '399'
		oPrint:Say(002400,1700,ContaHSBC,oFont7,100)
	
	ElseIf cE1PORTADO $ '422/SFF'                            //fernando Sigoli 08/11/2017 - 
		
		oPrint:say(002400,1700,Substr(_cAg_Conta,1,4)+Substr(_cAg_Conta,6,1)+'/'+padl(Substr(_cAg_Conta,8,6),8,"0")+;
		Substr(_cAg_Conta,15,1),oFont7,100)
		
	ElseIf cE1PORTADO $ '341/ITV'  // fernando Sigoli 13/07/2018
		oPrint:say(002400,1950,_cAg_Conta,oFont7,100)
	
	Else
	
		oPrint:Say(002400,1700,_cAg_Conta,oFont7,100)
	
	EndIf
	
	If cE1PORTADO == '033'
		oPrint:Say(002450,0120,"Data do Documento",oFont1,100)
		oPrint:Say(002450,0417,"Número Documento",oFont1,100)
		oPrint:Say(002450,0714,"Espécie Documento",oFont1,100)
		oPrint:Say(002450,1050,"Aceite",oFont1,100)
		oPrint:Say(002450,1201,"Data Processamento",oFont1,100) 
	ElseIf cE1PORTADO $ "422/SAF/SFF"   // ALEX BORGES 03/04/12
		
		oPrint:say(002450,0120,"Dt Documento",oFont1,100)
		oPrint:say(002450,0370,"Número do Documento",oFont1,100)
		oPrint:say(002450,0720,"Esp.Doc.",oFont1,100)
		oPrint:say(002450,0870,"Aceite",oF`ont1,100)
		oPrint:say(002450,1080,"Data Movimento",oFont1,100)	
	
	Else
	
		oPrint:Say(002450,0120,"Dt Documento",oFont1,100)
		oPrint:Say(002450,0370,"Número do Documento",oFont1,100)
		oPrint:Say(002450,0720,"Esp.Doc.",oFont1,100)
		oPrint:Say(002450,0870,"Aceite",oF`ont1,100)
		oPrint:Say(002450,1080,"Data Processamento",oFont1,100)
	EndIf
	
	oPrint:Say(002450,1520,"Nosso Número",oFont1,100)
	
	If cE1PORTADO == '033'
		oPrint:Say(002480,0120,DtoC(TSE1A->E1_EMISSAO),oFont2,100)
		oPrint:Say(002480,0417,AllTrim(TSE1A->E1_PREFIXO) + "-" + AllTrim(TSE1A->E1_NUM) + If(!Empty(TSE1A->E1_PARCELA),"-" +TSE1A->E1_PARCELA,""),oFont2,100) // Numero do Documento
	Else
		oPrint:Say(002480,0120,DtoC(TSE1A->E1_EMISSAO),oFont2,100)
		oPrint:Say(002480,0370,AllTrim(TSE1A->E1_PREFIXO) + "-" + AllTrim(TSE1A->E1_NUM) + If(!Empty(TSE1A->E1_PARCELA),"-" +TSE1A->E1_PARCELA,""),oFont2,100) // Numero do Documento
	EndIf
	
	If cE1PORTADO $ "399/637"
		oPrint:Say(002480,0720,"PD",oFont2,100)
		oPrint:Say(002480,0870,"NÃO",oFont2,100)
		oPrint:Say(002480,1090,Dtoc(Date()),oFont2,100)
	ElseIf cE1PORTADO == "033"
		oPrint:Say(002480,0714,"DM",oFont2,100)
		oPrint:Say(002480,1050,_cAceite,oFont2,100)
		oPrint:Say(002480,1201,Dtoc(Date()),oFont2,100)	// Reginaldo 12/09/08
	ElseIf cE1PORTADO $ "341/655/KOB/ITV"
		oPrint:Say(002480,0714,"DP",oFont2,100)
		oPrint:Say(002480,1000,_cAceite,oFont2,100)
		oPrint:Say(002480,1201,Dtoc(Date()),oFont2,100)	// Reginaldo 12/09/08
	Else
		oPrint:Say(002480,0720,"DM",oFont2,100)
		oPrint:Say(002480,0870,_cAceite,oFont2,100)
		oPrint:Say(002480,1090,Dtoc(Date()),oFont2,100)
	EndIf
	
	Do Case
		Case cE1PORTADO $ "422/SAF/SFF" // Banco Safra     ALEX BORGES 03/04/12
		//Case cE1PORTADO == "422" // Banco Safra
			//oPrint:Say(2480,1700,_cNumBoleta+"-"+_cDV_NNUM,oFont7,100)
			
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
				oPrint:say(2480,1700, ALLTRIM(_cNumBoleta)+ALLTRIM(_cDV_NNUM) ,oFont7,100)   		
	  		Else
			    oPrint:Say(2480,1700,_cCarteira+"/"+SubStr(_cNumBoleta,1,11)+"-"+_cDV_NNUM,oFont7,100)
			EndIf
		
		Case cE1PORTADO $ "237|RED|BRD|BRV" // Bradesco / RED FACTOR // *** INICIO CHAMADO 050420
			oPrint:Say(2480,1700,_cCarteira+"/"+SubStr(_cNumBoleta,1,11)+"-"+_cDV_NNUM,oFont7,100)
		
		Case cE1PORTADO == "246" // ABC
			oPrint:Say(2480,1700,_cCarteira+"/"+SubStr(_cNumBoleta,1,11)+"-"+_cDV_NNUM,oFont7,100)
		
		Case cE1PORTADO == '001' // Banco do Brasil
			//Mauricio 19/10/11 - Substituido para impressao sem digito do nosso numero conforme solicitado Sr.Renato/Reginaldo.
			//oPrint:Say(2480,1700,_cNumBoleta+"-"+_cDV_NNUM,oFont7,100)
			oPrint:Say(2480,1700,_cNumBoleta,oFont7,100)
		
		Case cE1PORTADO == "033" // SANTANDER
			oPrint:Say(2480,1700,SubStr(_cNumBoleta,6,7)+" "+_cDV_NNUM,oFont7,100)
		
		Case cE1PORTADO $ "399/637" // HSBC
			oPrint:Say(2480,1700,_cNumBoleta+"-"+_cDV_NNUM,oFont7,100)
		
		Case cE1PORTADO $ "655/KOB" // ITAU
			oPrint:Say(2480,1700,"109/" + _cNumBoleta+"-"+_cDV_NNUM,oFont7,100) 	// 102 E A CARTEIRA ? VERIFICAR NO SUPORTE
		
		Case cE1PORTADO $ "341/ITV" // ITAU 13/07/2018 
			oPrint:Say(2480,1910,"109" + "/" + _cNumBoleta+"-"+_cDV_NNUM,oFont7,100) 
		
		Case cE1PORTADO == "104" 	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 18/01/17
			oPrint:say(2480,1700,Substr(_cNumBoleta,1,17)+"-"+_cDV_NNUM,oFont7,100)		
	
	EndCase
	
	If cE1PORTADO == "033"
		oPrint:Say(002530,0120,"Carteira",oFont1,100)
		oPrint:Say(002530,0520,"Espécie",oFont1,100)
		oPrint:Say(002530,0670,"Quantidade",oFont1,100)
		oPrint:Say(002530,1090,"Valor",oFont1,100)
	ElseIf cE1PORTADO $ "422/SAF/SFF"   // ALEX BORGES 03/04/12 
		oPrint:say(2530,0120,"Data de OPeração",oFont1,100)
		oPrint:say(2530,0360,"CIP",oFont1,100)
		oPrint:say(2530,0405,"Carteira",oFont1,100)
		oPrint:say(2530,0520,"Espécie",oFont1,100)
		oPrint:say(2530,0670,"Quantidade",oFont1,100)
		oPrint:say(2530,1090,"Valor",oFont1,100) 	
	Else
		oPrint:Say(002530,0120,"Uso do Banco",oFont1,100)
		oPrint:Say(002530,0370,"Carteira",oFont1,100)
		oPrint:Say(002530,0520,"Espécie",oFont1,100)
		oPrint:Say(002530,0670,"Quantidade",oFont1,100)
		oPrint:Say(002530,1090,"Valor",oFont1,100)
	EndIf
	
	oPrint:Say(002530,1520,"(=) Valor do Documento",oFont1,100)
	
	If cE1PORTADO == "033"
		oPrint:Say(002560,0120,"SIMPLES - RCR",oFont2,100)
		oPrint:Say(002560,0520,"REAL",oFont2,100)
	ElseIf cE1PORTADO $ "422/SAF/SFF"  //ALEX BORGES 03/04/12
		oPrint:say(2560,120,Dtoc(dDataBase),oFont2,100)
		oPrint:say(2560,350,"130",oFont2,100)
		oPrint:say(2560,410,_cCarteira,oFont2,100)
		oPrint:say(2560,520,"R$",oFont2,100)	
	Else
		oPrint:Say(002560,0370,_cCarteira,oFont2,100)
		oPrint:Say(002560,0520,"R$",oFont2,100)
	EndIf
	
	oPrint:Say(002560,1900,transform(_nVlrBol,"@E 999,999,999.99"),oFont9,100)
	oPrint:Say(002610,0120,"Instruções",oFont1,100)
	oPrint:Say(002610,0120,"               "+ "(Todas as informações deste bloqueto são de exclusiva responsabilidade do Beneficiario)",oFont1A,100)
	
	If cE1PORTADO == "033"
		oPrint:Say(002610,1520,"(-) Desconto",oFont1,100)
		oPrint:Say(002770,1520,"(+) Mora",oFont1,100)
		
	ElseIf cE1PORTADO $ "655"
		oPrint:Say(1630,1520,"",oFont1,100)
		oPrint:Say(1710,1520,"(+) Mora/Multa",oFont1,100)
	
	Else
		oPrint:Say(002610,1520,"(-) Desconto/Abatimento",oFont1,100)
		oPrint:Say(002770,1520,"(+) Mora/Multa",oFont1,100)
	EndIf
	
	If !cE1PORTADO $ "001|237|246|422|SFF|SAF|RED|BRD|104|341|BRV|ITV" // *** INICIO CHAMADO 050420
		oPrint:Say(002640,1750,Transform(_nVlrAbat,"@E 999,999,999.99"),oFont7,100)
	EndIf
	
	If cE1PORTADO == "033"
		oPrint:Say(002690,1520,"(-) Abatimento",oFont1,100)
	Else
		oPrint:Say(002690,1520,"(-) Outras Deduções",oFont1,100)
	EndIf
	
	If !(cE1PORTADO $ "655" )
		oPrint:Say(002850,1520,"(+) Outros Acréscimos",oFont1,100)
	EndIf
	
	oPrint:Say(002930,1520,"(=) Valor Cobrado",oFont1,100)
	oPrint:Say(003010,0120,"Pagador",oFont1,100)
	oPrint:Say(003040,0250,TSE1A->A1_NOME,oFont8,100)
	oPrint:Say(003040,1500,transform(TSE1A->A1_CGC,"@R 99.999.999/9999-99"),oFont8,100)
	oPrint:Say(003070,0250,TSE1A->A1_ENDCOB+" "+TSE1A->A1_BAIRROC,oFont8,100)
	oPrint:Say(003100,0250,TSE1A->A1_CEPC+" "+TSE1A->A1_MUNC+TSE1A->A1_ESTC,oFont8,100)
	oPrint:Say(003170,0120,"Sacador/Avalista",oFont1,100)
	
	If cE1PORTADO != "033"
		oPrint:Say(003170,1520,"Cód.Baixa",oFont1,100)
		oPrint:Say(003170,1750,"Autenticação Mecânica",oFont1,100)
		oPrint:Say(003210,1730,"FICHA DE COMPENSAÇÃO",oFont2,100)
	Else
		oPrint:Say(003210,1750,"Autenticação Mecânica",oFont1,100)
		oPrint:Say(003310,1730,"FICHA DE COMPENSAÇÃO",oFont2,100)
	EndIf
	
	If cE1PORTADO $ "655/637/SAF/KOB/RED/BRD" // 02/09 - Alex Borges
	
		oPrint:say(003170,0400, cNome + cEndereco + cCidade + cCNPJ ,oFont1,100) // alteração chamado 022248 - William Costa
	
	EndIf
	
	If cE1PORTADO $ "SAF" // ALEX BORGES 03/04/12
		oPrint:Say(003170,0400,"GMSBS PRESTACOES DE SERVICOS S/A     CNPJ:  13.362.692/0001-60",oFont1,100)
	EndIf
	
	
	// Impressao das Instruções
	
	_nLinInst := 2640
	
	If !(cE1PORTADO $ "655/422/SFF/KOB/SAF") //INCLUIDO 655 (VOTORANTIM) 26/04/11 SAF em 03/04/12
	
		oPrint:Say(_nLinInst,0120,"*** VALORES EXPRESSOS EM REAIS *** ",oFont8,100)	// Instruções

	EndIf
	
	_nLinInst += 50
	
	If cE1PORTADO == "246"	// Tratamento BANCO ABC
		oPrint:Say(_nLinInst,0120,"Título transferido ao Banco ABC Brasil S/A.",oFont8,100)
	EndIf
	
	_nLinInst += 50
	
	//Incluido 26/04/11
	If cE1PORTADO == '655'
		oPrint:Say(_nLinInst,0120,"Titulo entregue em cessão fiduciaria em favor do Pagador acima" ,oFont8,100)
		_nLinInst += 50
	EndIf    
	
	If cE1PORTADO $ 'SAF/SFF'  //ALEX BORGES 03/04/12
	//If cE1PORTADO == '422'
		If SEE->EE_ZZMORA > 0	
			nValMora := ( _nVlrBol * ( SEE->EE_ZZMORA / 100) ) / 30 	
			oPrint:Say(_nLinInst,0120,"Não dispensar mora de R$ " + Alltrim(Transform(nValMora,"@E 999,999,999.99")) + " por dia de atraso" ,oFont8,100)
			_nLinInst += 00050
		Endif
	
		If SEE->EE_ZZDIAAT > 0 .AND. SEE->EE_ZZPERMU > 0
			oPrint:Say(_nLinInst,0120,"Após o vencimento cobrar multa de R$ " + Alltrim(Transform(_nVlrBol * (SEE->EE_ZZPERMU/100),"@E 999,999.99")),oFont8,100)
			_nLinInst += 00050
		Endif
		
		If TSE1A->A1_ZZDESCB > 0 .AND. TSE1A->E1_TIPO <> 'NDC'
		  
			oPrint:Say(_nLinInst,0120,"Conceder desconto de R$ " + Alltrim(Transform(ROUND(_nVlrBol * (TSE1A->A1_ZZDESCB/100),2),"@E 999,999.99")),oFont8,100) //Chamado: 048733 Fernando Sigoli 29/04/2019
			_nLinInst += 50

		EndIf
		//
		If SEE->EE_ZZDDPRO > 0
		  //oPrint:Say(_nLinInst,0120,"Após " + Strzero(SEE->EE_ZZDDPRO,2) + " dias do vencimento, protestar o titulo ",oFont8,100)
			oPrint:Say(_nLinInst,0120,"SUJEITO A PROTESTO APÓS O VENCIMENTO" ,oFont8,100) //tkt 7075 -  Fernando Sigoli - Alteração da instrução de protesto
			_nLinInst += 00050
		Endif
	    //
		
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
			oPrint:Say(_nLinInst,0120,"DIREITO DE CREDITO CEDIDO AO PAGADOR - PAGAVEL SOMENTE EM BANCO" ,oFont8,100)
			_nLinInst += 00050
			oPrint:Say(_nLinInst,0120,"COBRANCA ESCRITURAL" ,oFont8,100)
			_nLinInst += 00050 
			oPrint:Say(_nLinInst,0120,"SUJEITO A PROTESTO APÓS O VENCIMENTO" ,oFont8,100) //Everson - 11/08/2020. Chamado 060193.
			_nLinInst += 00050						
		Endif
		
		If TSE1A->A1_ZZDESCB > 0 .AND. TSE1A->E1_TIPO <> 'NDC'
		  
			oPrint:Say(_nLinInst,0120,"Conceder desconto de R$ " + Alltrim(Transform(ROUND(_nVlrBol * (TSE1A->A1_ZZDESCB/100),2),"@E 999,999.99")),oFont8,100) //Chamado: 048733 Fernando Sigoli 29/04/2019
			_nLinInst += 50

		EndIf		
	
	
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
			_nLinInst += 50
		EndIf
	
		If SEE->EE_ZZDDPRO > 0
			//oPrint:Say(_nLinInst,0120,"Após " + Strzero(SEE->EE_ZZDDPRO,2) + " dias do vencimento, protestar o titulo ",oFont8,100)
			oPrint:Say(_nLinInst,0120,"SUJEITO A PROTESTO APÓS O VENCIMENTO" ,oFont8,100) //tkt 7075 -  Fernando Sigoli - Alteração da instrução de protesto
			_nLinInst += 50
		EndIf
	
		If SEE->EE_ZZDIAAT > 0 .And. SEE->EE_ZZPERMU > 0
			oPrint:Say(_nLinInst,0120,"Após o " + AllTrim(Str(SEE->EE_ZZDIAAT)) + "° dia útil do vencimento cobrar multa de " + Transform(SEE->EE_ZZPERMU,"@E 999,999.99") + "%",oFont8,100)
			_nLinInst += 50
		EndIf
	
		If TSE1A->A1_ZZDESCB > 0 .AND. TSE1A->E1_TIPO <> 'NDC'
		  
			oPrint:Say(_nLinInst,0120,"Conceder desconto de R$ " + Alltrim(Transform(ROUND(_nVlrBol * (TSE1A->A1_ZZDESCB/100),2),"@E 999,999.99")),oFont8,100) //Chamado: 048733 Fernando Sigoli 29/04/2019
			_nLinInst += 50

		EndIf
		
		If cE1PORTADO == 'BRD' 
			_nLinInst += 00025
			oPrint:Say(_nLinInst,0120,"BOLETO REFERENTE A NF "+ Alltrim(TSE1A->E1_NUM) + Iif(!Empty(TSE1A->E1_PARCELA),"-" +TSE1A->E1_PARCELA,"")+" EMITIDA POR AD'ORO S/A",oFont8Bold,100)
			_nLinInst += 00050
		Endif	      
		
		
	Endif	
	
	//
	oPrint:Say(_nLinInst,0140,Mv_Par06,oFont8,100)	// Instruções de parametro
	_nLinInst += 50
	oPrint:Say(_nLinInst,0140,Mv_Par07,oFont8,100) 	// Instruções de parametro
	
	// Impressao do Codigo de Barras
	//MSBAR("INT25",28.0,1.1,_cCodBarras,oPrint:oPrint,.F.,Nil,Nil,0.025,1.3,NIL,NIL,"A",.F.)
	     
	If "P2050" $ oPrint:cPrinterName
		MSBAR("INT25",16.0,1.1,_cCodBarras,oPrint:oPrint,.F.,Nil,Nil,0.016,0.8,NIL,NIL,,.F.)
	Else	
		MSBAR("INT25",28.0,1.1,_cCodBarras,oPrint:oPrint,.F.,Nil,Nil,0.025,1.3,NIL,NIL,"A",.F.)
	EndIf	
	
	//if cE1PORTADO $ 'SAF/BRD'
	    //cBitMap := GetSrvProfString("Startpath","") + "logo.png"   	//desabilitado por Adriana em 03/10/2016 conforme chamado 030747
	    //oPrint:SayBitmap(0300,0100,cBitMap,400,330)              		//desabilitado por Adriana em 03/10/2016 conforme chamado 030747
	//    cBitMap := GetSrvProfString("Startpath","") + "logomil.png"
	//    oPrint:SayBitmap(0200,0100,cBitMap,2115,700) //2115,800
	//endif
	SM0->(RestArea(aAreaSM0))
Return(Nil)

/*/{Protheus.doc} Static Function fCalcBlt
	Calcula nosso numero
	@type  Function
	@author Lt. Paulo - TDS
	@since 25/05/2011
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function fCalcBlt(cPrefixo,cNum,cParcela,cTipTit)

	Local lRet				:= .T.
	Local aArea				:= SaveArea1({"SEE","SE1","SA6","SF2","SE4"})
	Local cChave			:= cE1PORTADO + cE1AGEDEP + cE1CONTA
	
	Private cIDCNAB	:= "" //CriaVar("E1_IDCNAB",.F.) // Chamado n. 059415 - FWNM         - 05/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Ajuste na geração do E1_IDCNAB devido desativação das customizações antigas 
	
	PARAMTYPE 0	VAR cPrefixo	AS Character	OPTIONAL	DEFAULT Space(TamSX3("E1_PREFIXO")[1])
	PARAMTYPE 1	VAR cNum		AS Character	OPTIONAL	DEFAULT Space(TamSX3("E1_NUM")[1])
	PARAMTYPE 2	VAR cParcela	AS Character	OPTIONAL	DEFAULT Space(TamSX3("E1_PARCELA")[1])
	PARAMTYPE 3	VAR cTipTit		AS Character	OPTIONAL	DEFAULT Space(TamSX3("E1_TIPO")[1])
	
	dbSelectArea("SEE")
	SEE->(dbSetOrder(1))	//EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
	dbSelectArea("SE1")
	SE1->(dbSetOrder(1))	//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	dbSelectArea("SA6")
	SA6->(dbSetOrder(1))	//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
	dbSelectArea("SF2")
	SF2->(dbSetOrder(1))	//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	dbSelectArea("SE4")
	SE4->(dbSetOrder(1))	//E4_FILIAL+E4_CODIGO
	If SEE->(dbSeek(xFilial("SEE") + cChave))
		If cE1PORTADO == "033"     // SANTANDER
			_cNumBoleta := SubStr(SEE->EE_FAXATU,1,5)+StrZero(Val(SubStr(SEE->EE_FAXATU,6,7))+1,7)
		ElseIf cE1PORTADO $ "399"	   // HSBC
			_cNumBoleta := SubStr(SEE->EE_FAXATU,1,5)+StrZero(Val(SubStr(SEE->EE_FAXATU,6,5))+1,5)
		ElseIf cE1PORTADO == "637"	// SOFISA
			_cNumBoleta := Substr(SEE->EE_FAXATU,1,5) + StrZero( (Val( Substr(SEE->EE_FAXATU,6,5) )+1),05)
		
			//ElseIf cE1PORTADO $ "422/SAF/SFF"    // SAFRA   ALEX BORGES 03/04/12                         //20/03/19-Chamado:048048 - Fernando Sigoli 
			//_cNumBoleta := SubStr(SEE->EE_FAXATU,1,4)+StrZero(Val(SubStr(SEE->EE_FAXATU,5,4))+1,4)       //20/03/19-Chamado:048048 - Fernando Sigoli 
		
		ElseIf cE1PORTADO $ "341/655/KOB/422/SAF/SFF/ITV"     // ITAU //SAFRA     //20/03/19-Chamado:048048 - Fernando Sigoli 
			_cNumBoleta := StrZero(Val(AllTrim(SEE->EE_FAXATU))+1,8)
		
		ElseIf cE1PORTADO == "246"	   // ABC
			_cNumBoleta := SubStr(SEE->EE_FAXATU,1,5)+StrZero(Val(SubStr(SEE->EE_FAXATU,6,6))+1,6)
			//Mauricio 19/10/11 - Incluido tratamento para banco do Brasil por mudanca no tamanho do codigo do convenio (4 p/ 7) o qual não mais é parte da faixa.
		Elseif cE1PORTADO == "001"
			_cNumBoleta := "2228147"+StrZero(Val(SubStr(SEE->EE_FAXATU,1,10))+1,10)
			_cNBoletaBB := StrZero(Val(SubStr(SEE->EE_FAXATU,1,10))+1,10)
		Elseif cE1PORTADO == "104" 	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
			_cNumBoleta := "14000" + StrZero( (Val( Substr(SEE->EE_FAXATU,1,12) )+1),12) 
			_cNBoletCEF := StrZero(Val(SubStr(SEE->EE_FAXATU,1,12))+1,12)
		Else
			_cNumBoleta := SubStr(SEE->EE_FAXATU,1,4)+StrZero(Val(SubStr(SEE->EE_FAXATU,5,7))+1,7)
		EndIf

		// Chamado n. 059415 - FWNM         - 05/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Ajuste na geração do E1_IDCNAB devido desativação das customizações antigas 
		/*
		If !FindFunction("U_RtPrxIDC")
			ExUserException("A função necessária para o levantamento do próximo ID CNAB (RtPrxIDC) não pode ser encontrada!")
			RestArea1(aArea)
			Return .F.
		Else
			cIDCNAB := U_RtPrxIDC(cPrefixo,cNum,cParcela,cTipTit,.f.)
	   	Endif	
		*/
		//

		// Atualizacao do campo de multa mora dia
		If SEE->EE_ZZMORA > 0
			// Paulo - TDS - 27/05/2011 - Será utilizado o valor do SALDO, conforme solicitação do Sr. Reginaldo
			_nVlrBol := TSE1A->E1_SALDO - TSE1A->E1_ISS - TSE1A->E1_INSS - TSE1A->E1_CSLL - TSE1A->E1_COFINS - TSE1A->E1_PIS - TSE1A->E1_VALLIQ
			nValMora := (_nVlrBol*(SEE->EE_ZZMORA/100))/30
			If nValMora > 0
				If SE1->(dbSeek(xFilial("SE1") + TSE1A->(E1_PREFIXO + E1_NUM + E1_PARCELA)))
					RecLock("SE1",.F.)
					SE1->E1_VLMULTA := nValMora
					MsUnLock()
				EndIf
			EndIf
		EndIf
	Else
		ApMsgInfo(OemToAnsi("CNAB nao configurado para este Banco. Boleto para impressao cancelada para este titulo. Verifique!!"),;
		OemToAnsi("A T E N Ç Ã O"))
		lRet := .f.
		RestArea1(aArea)
		Return(lRet)
	EndIf
	// Posiciona tabela de Bancos
	SA6->(dbSeek(xFilial("SA6") + cChave))
	SEE->(dbSeek(xFilial("SEE") + cChave))
	
	If cE1PORTADO == "KOB"
		//NNumDV( "2001" + "91898" + "109" + Alltrim(_cNumBoleta)  )//chamado:045459 27/11/2018
		NNumDV( "2001" + "02680" + "109" + Alltrim(_cNumBoleta)  )
		
	ElseIf cE1PORTADO == "104" 	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 18/01/17
		NNumDV(Alltrim(_cNumBoleta))
	Else
		NNumDV(SubStr(SA6->A6_AGENCIA,1,4)+SubStr(SA6->A6_NUMCON,1,5)+"109"+Alltrim(_cNumBoleta))	// Calculo dos Boletos
	Endif
		
	// Alterado por Adriano dias 25/10/2011
	If cE1PORTADO == "001"
		cQuery := "UPDATE "+RETSQLNAME("SE1")+" "
		cQuery += "SET E1_NUMBCO  = '"+(_cConv)+AllTrim(_cNBoletaBB)+"', "
	    cQuery += "    E1_BANCO  = '"+cE1PORTADO+"' , "
		//cQuery += "    E1_IDCNAB  = '"+cIDCNAB+"', " // Chamado n. 059415 - FWNM         - 05/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Ajuste na geração do E1_IDCNAB devido desativação das customizações antigas 
		cQuery += "    E1_DVNBCO  = '"+AllTrim(_cDV_NNUM)  +"', "
		cQuery += "    E1_NUMBCO1 = '"+(_cConv)+AllTrim(_cNBoletaBB)+"'  " // Salva também uma "cópia" do campo E1_NUMBCO - Paulo - TDS - 26/05/2011
		cQuery += "WHERE E1_FILIAL  = '"+TSE1A->E1_FILIAL +"' AND "
		cQuery += "      E1_PREFIXO = '"+TSE1A->E1_PREFIXO+"' AND "
		cQuery += "      E1_NUM     = '"+TSE1A->E1_NUM+"'     AND "
		cQuery += "      E1_PARCELA = '"+TSE1A->E1_PARCELA+"' AND "
		cQuery += "      E1_TIPO   <>  'AB-' AND " //chamado 027642, alterado para não carregar o AB- William Costa
		// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 27/03/2020
		cQuery += "      E1_XWSBRAC = ''             AND "
		//
		cQuery += "      D_E_L_E_T_ = ' ' "
	Else
		cQuery := "UPDATE "+RETSQLNAME("SE1")+" "
		cQuery += "SET E1_NUMBCO  = '"+AllTrim(_cNumBoleta)+"', "
	    cQuery += "    E1_BANCO  = '"+cE1PORTADO+"' , "
		//cQuery += "    E1_IDCNAB  = '"+cIDCNAB+"', " // Chamado n. 059415 - FWNM         - 05/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Ajuste na geração do E1_IDCNAB devido desativação das customizações antigas 
		cQuery += "    E1_DVNBCO  = '"+AllTrim(_cDV_NNUM)  +"', "
		cQuery += "    E1_NUMBCO1 = '"+AllTrim(_cNumBoleta)+"'  " // Salva também uma "cópia" do campo E1_NUMBCO - Paulo - TDS - 26/05/2011
		cQuery += "WHERE E1_FILIAL  = '"+TSE1A->E1_FILIAL +"' AND "
		cQuery += "      E1_PREFIXO = '"+TSE1A->E1_PREFIXO+"' AND "
		cQuery += "      E1_NUM     = '"+TSE1A->E1_NUM+"'     AND "
		cQuery += "      E1_PARCELA = '"+TSE1A->E1_PARCELA+"' AND "
		cQuery += "      E1_TIPO   <>  'AB-' AND " //chamado 027642, alterado para não carregar o AB- William Costa
		// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 27/03/2020
		cQuery += "      E1_XWSBRAC = ''             AND "
		//
		cQuery += "      D_E_L_E_T_ = ' ' "
	Endif
	
	If TCSQLExec(cQuery) != 0
		Aviso(FunDesc(),TCSQLERROR(),{"OK"})
	EndIf
	
	TcSqlExec("COMMIT")
	
	If cE1PORTADO == "001"
		
		cQuery := "UPDATE "+RETSQLNAME("SEE")+" SET EE_FAXATU = '"+AllTrim(_cNBoletaBB)+ "' "
		cQuery += "WHERE EE_FILIAL  = '"+xFilial("SEE")+"' AND "
		cQuery += "      EE_CODIGO  = '"+cE1PORTADO+"'     AND "
		cQuery += "      EE_AGENCIA = '"+cE1AGEDEP+"'      AND "
		cQuery += "      EE_CONTA   = '"+cE1CONTA+"'       AND "
		cQuery += "      D_E_L_E_T_	= ' ' "
	
	ElseIf cE1PORTADO == "104" 	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 05/01/17
		   
		cQuery := "UPDATE "+RETSQLNAME("SEE")+" SET EE_FAXATU = '"+AllTrim(_cNBoletCEF)+ "' "
		cQuery += "WHERE EE_FILIAL  = '"+xFilial("SEE")+"' AND "
		cQuery += "      EE_CODIGO  = '"+cE1PORTADO+"'     AND "
		cQuery += "      EE_AGENCIA = '"+cE1AGEDEP+"'      AND "
		cQuery += "      EE_CONTA   = '"+cE1CONTA+"'       AND "
		cQuery += "      D_E_L_E_T_	= ' ' "
	Else
		cQuery := "UPDATE "+RETSQLNAME("SEE")+" SET EE_FAXATU = '"+AllTrim(_cNumBoleta)+ "' "
		cQuery += "WHERE EE_FILIAL  = '"+xFilial("SEE")+"' AND "
		cQuery += "      EE_CODIGO  = '"+cE1PORTADO+"'     AND "
		cQuery += "      EE_AGENCIA = '"+cE1AGEDEP+"'      AND "
		cQuery += "      EE_CONTA   = '"+cE1CONTA+"'       AND "
		cQuery += "      D_E_L_E_T_	= ' ' "
	Endif
	
	If TCSQLExec(cQuery) != 0
		Aviso(FunDesc(),TCSQLERROR(),{"OK"})
	EndIf
	
	TcSqlExec("COMMIT")
	
	Do Case
		// Atenção: Acrescentar aqui os codigos dos demais bancos
		Case cE1PORTADO == "001"	// BANCO DO BRASIL
			_cNome_Bco := "Banco do Brasil"
			_cCod_Comp := "|001-9|"
			_cAg_Conta := SubStr(SA6->A6_AGENCIA,1,4)+"-"+SubStr(SA6->A6_AGENCIA,5,1)+"/"+SubStr(SA6->A6_NUMCON,1,5)+"-"+SubStr(SA6->A6_NUMCON,7,1)
		    _cCarteira := "17/027"          //Renato,alterado de 17/019 p/ 17/027 em 26/10/2011
			_cAceite   := "N"
	
		Case cE1PORTADO $ "SAF"	// SAFRA    ALEX BORGES 03/04/12
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
						
		Case cE1PORTADO $ "237|RED|BRD"	// Bradesco / RED FACTOR
			_cNome_Bco := "BRADESCO"
			_cCod_Comp := "|237-2|"
			If cE1PORTADO = "RED"
				_cAg_Conta := Substr(SA6->A6_AGENCIA,2,4)+"-"+SA6->A6_DVAGE+"/"+Substr(SA6->A6_NUMCON,4,6)+"-"+SA6->A6_DVCTA
			Else
				_cAg_Conta := Substr(SA6->A6_AGENCIA,1,4)+"-"+Substr(SA6->A6_AGENCIA,5,1)+"/0"+Substr(SA6->A6_NUMCON,1,6)+"-"+Substr(SA6->A6_NUMCON,8,1)
			EndIf
			_cCarteira := "09"
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
			_cAg_Conta := SubStr(SA6->A6_AGENCIA,1,4)+"-"+SubStr(SA6->A6_AGENCIA,5,1)+"/"+SubStr(SA6->A6_NUMCON,1,7)+"-"+SubStr(SA6->A6_NUMCON,8,1)
			_cCarteira := "009"
			_cAceite   := "N"
	
		Case cE1PORTADO = "399"	// HSBC
			_cNome_Bco := "HSBC"
			_cCod_Comp := "|399-9|"
			_cAg_Conta := SubStr(SA6->A6_AGENCIA,1,4)+"-"+SubStr(SA6->A6_AGENCIA,1,4)+SubStr(SA6->A6_NUMCON,1,7)
			_cCarteira := "CSB"
			_cAceite   := "N"
	
		Case cE1PORTADO == "033"			// BANESPA SANTANDER
			_cNome_Bco := "SANTANDER"
			_cCod_Comp := "|033-7|"
			_cAg_Conta := SubStr(SA6->A6_AGENCIA,1,4)+"/" + "1809571"
			_cCarteira := "101"
			_cAceite   := "N"    
	
		Case cE1PORTADO $ "KOB"	// KOB
			_cNome_Bco := "Banco Itaú SA"
			_cCod_Comp := "|341-7|"
			//_cAg_Conta := "2001" + "/" + "91898"+"-"+"2" //chamado:045459 27/11/2018
			_cAg_Conta := "2001" + "/" + "02680"+"-"+"2"
			_cCarteira := "109"
			_cAceite   := "A" 		
	
		Case cE1PORTADO $ "341/655/ITV"			// BANCO ITAU E VOTORANTIM
			_cNome_Bco := "Banco Itaú SA"
			_cCod_Comp := "|341-7|"
			_cAg_Conta := SubStr(SA6->A6_AGENCIA,1,4) + "/" + SubStr(SA6->A6_NUMCON,1,5)+"-"+IIF(ALLTRIM(SA6->A6_DVCTA) == '',SUBSTR(SA6->A6_NUMCON,Len(Alltrim(SA6->A6_NUMCON)),1),SA6->A6_DVCTA)
			_cCarteira := "109"
			_cAceite   := "A"
	
		Case cE1PORTADO = "637"	// SOFISA
			_cNome_Bco := "HSBC"
			_cCod_Comp := "|399-9|"
			_cAg_Conta := Substr(SA6->A6_AGENCIA,1,5)+"/"+Substr(SA6->A6_NUMCON,1,5)+"-"+Substr(SA6->A6_NUMCON,6,2)
			_cCarteira := "CSB"
			_cAceite   := "N"
		Case cE1PORTADO = "104"	// CAIXA ECONOMICA FEDERAL  - Chamado 032158 sigoli 18/01/17
			_cNome_Bco := "CX EC.FEDERAL"
			_cCod_Comp := "|104-0|"
			_cAg_Conta := Substr(SA6->A6_AGENCIA,1,4)+" / "+Posicione("SEE",1,xFilial("SEE")+cE1PORTADO+cE1AGEDEP+cE1CONTA,"EE_CODEMP") 	// Somente na impressao
			_cCarteira := "14"
			_cAceite   := "N" 
	EndCase
	SF2->(dbSeek(xFilial("SF2") + TSE1A->(E1_NUM + E1_PREFIXO)))
	SE4->(dbSeek(xFilial("SE4") + SF2->F2_COND))
	// Calculo do fator de Vencimento para atender ao Banco do Brasil
	_cFatorVcto := Str((TSE1A->E1_VENCTO - Ctod("07/10/1997")),4)
	
	// Paulo - TDS - 27/05/2011 - O valor do boleto será o SALDO e não o valor principal, conforme solicitação do Sr. Reginaldo
	_nVlrBol  := TSE1A->E1_SALDO
	_nVlrAbat := 0 // Verificar em 22/06/2011 - Paulo (TDS)
	
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
		
		Case cE1PORTADO $ "SAF" // Banco Safra     ALEX BORGES 03/04/12
			
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
				
			   	DgVerECF(_cCodBarras)
				
				_cCodBarras := Substr(_cCodBarras,1,4)+_cB_DVCam+Substr(_cCodBarras,5,40)
			
			
		Case cE1PORTADO $ "237|RED|BRD" // Bradesco / RED FACTOR
			
			_cB_Campo := "237" + "9" + _cFatorVcto
			_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cB_Campo += SubStr(SA6->A6_AGENCIA,1,4)+"09"+_cNumboleta +SubStr(SA6->A6_NUMCON,1,6)+SubStr(SA6->A6_NUMCON,8,1)+"0"
			
			BarraDV()
			
			_cCodBarras := "237" + "9" + _cDV_BARRA + _cFatorVcto
			_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cCodBarras += SubStr(SA6->A6_AGENCIA,1,4)+"09"+_cNumboleta +SubStr(SA6->A6_NUMCON,1,6)+SubStr(SA6->A6_NUMCON,8,1) +"0"
		
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
			
			_cB_Campo := "237"+"9"+_cFatorVcto
			_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cB_Campo += SubStr(SA6->A6_AGENCIA,1,4)+"09"+_cNumboleta +SubStr(SA6->A6_NUMCON,1,6)+SubStr(SA6->A6_NUMCON,8,1)+"0"
			
			BarraDV()
			
			_cCodBarras := "237"+"9"+_cDV_BARRA+_cFatorVcto
			_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cCodBarras += SubStr(SA6->A6_AGENCIA,1,4)+"09"+_cNumboleta+SubStr(SA6->A6_NUMCON,1,6)+SubStr(SA6->A6_NUMCON,8,1) +"0"
			
		Case cE1PORTADO == "399" // HSBC
			_cB_Campo := "399"+"9"+_cFatorVcto
			_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10)+_cNumboleta+_cDV_NNUM
			_cB_Campo += SubStr(SA6->A6_AGENCIA,1,4)+SubStr(SA6->A6_NUMCON,1,7)+"00"+"1"
			
			BarraDV()
			
			_cCodBarras := "399"+"9"+_cDV_BARRA+_cFatorVcto
			_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10)+_cNumboleta+_cDV_NNUM
			_cCodBarras += SubStr(SA6->A6_AGENCIA,1,4)+SubStr(SA6->A6_NUMCON,1,7)+"00"+"1"
			
		Case cE1PORTADO == "637" // SOFISA
			_cB_Campo := "399"+"9"+_cFatorVcto
			_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10)+_cNumboleta+_cDV_NNUM
			_cB_Campo += SubStr(SA6->A6_AGENCIA,1,5)+SubStr(SA6->A6_NUMCON,1,7)+"00"+"1"
			
			BarraDV()
			
			_cCodBarras := "399"+"9"+_cDV_BARRA+_cFatorVcto
			_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10)+_cNumboleta+_cDV_NNUM
			_cCodBarras += SubStr(SA6->A6_AGENCIA,1,5)+SubStr(SA6->A6_NUMCON,1,7)+"0"+"1"
			
		Case cE1PORTADO == "033" // SANTANDER
			
			_cB_Campo := "033"+"9"+_cFatorVcto
			_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cB_Campo += "9"+"1809571"+_cNumboleta+_cDV_NNUM+"0"+"101"
			
			BarraDV()
			
			_cCodBarras := "033"+"9"+_cDV_BARRA+_cFatorVcto
			_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cCodBarras += "9"+"1809571"+_cNumboleta+_cDV_NNUM+"0"+"101"
			
		Case cE1PORTADO == "KOB" // KOBOLD
				
			_cB_Campo := "341"  + "9" + _cFatorVcto
			_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10)
			//_cB_Campo += "109" + Alltrim(_cNumboleta) + _cDV_NNUM + "2001" + "91898"  + "2" + "000"   //chamado:045459 27/11/2018
			_cB_Campo += "109" + Alltrim(_cNumboleta) + _cDV_NNUM + "2001" + "02680"  + "2" + "000"
			
	    
			BarraDV()
			
			_cCodBarras := "341"  + "9" + _cDV_BARRA + _cFatorVcto
			_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10) 
		   //	_cCodBarras += "109" + Alltrim(_cNumboleta) + _cDV_NNUM + "2001" + "91898"  + "2" + "000"  //chamado:045459 27/11/2018		
			_cCodBarras += "109" + Alltrim(_cNumboleta) + _cDV_NNUM + "2001" + "02680"  + "2" + "000"		
			
		Case cE1PORTADO $ "341" // ITAU
			
			//_cB_Campo := "341"+"9"+_cFatorVcto
			//_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10)
			//_cB_Campo += "109"+_cNumboleta+_cDV_NNUM+SubStr(SA6->A6_AGENCIA,1,4)+SubStr(SA6->A6_NUMCON,1,5)+fDACITAU(SubStr(SA6->A6_AGENCIA,1,4)+SubStr(SA6->A6_NUMCON,1,5))+"000"
			  
			_cB_Campo := "341"  + "9" + _cFatorVcto
			_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cB_Campo += "109" + Alltrim(_cNumboleta) + _cDV_NNUM + SUBSTR(SA6->A6_AGENCIA,1,4) + SUBSTR(SA6->A6_NUMCON,1,5)  + IIF(ALLTRIM(SA6->A6_DVCTA) == '',SUBSTR(SA6->A6_NUMCON,Len(Alltrim(SA6->A6_NUMCON)),1),SA6->A6_DVCTA) + "000"
			
			BarraDV()
			
			_cCodBarras := "341"+"9"+_cDV_BARRA+_cFatorVcto
			_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cCodBarras += "109"+_cNumboleta+_cDV_NNUM+SubStr(SA6->A6_AGENCIA,1,4)+SubStr(SA6->A6_NUMCON,1,5)+ IIF(ALLTRIM(SA6->A6_DVCTA) == '',SUBSTR(SA6->A6_NUMCON,Len(Alltrim(SA6->A6_NUMCON)),1),SA6->A6_DVCTA) +"000"
			
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

		Case cE1PORTADO == "655" // ITAU/VOTORANTIM
			
			_cB_Campo := "341"+"9"+_cFatorVcto
			_cB_Campo += StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cB_Campo += "109"+_cNumboleta+_cDV_NNUM+SubStr(SA6->A6_AGENCIA,1,4)+SubStr(SA6->A6_NUMCON,1,5)+fDACITAU(SubStr(SA6->A6_AGENCIA,1,4)+SubStr(SA6->A6_NUMCON,1,5) )+"000"
			
			BarraDV()
			
			_cCodBarras := "341"+"9"+_cDV_BARRA+_cFatorVcto
			_cCodBarras += StrZero(Int(Round(_nVlrBol*100,2)),10)
			_cCodBarras += "109"+_cNumboleta+_cDV_NNUM+SubStr(SA6->A6_AGENCIA,1,4)+SubStr(SA6->A6_NUMCON,1,5)+fDACITAU(SubStr(SA6->A6_AGENCIA,1,4)+SubStr(SA6->A6_NUMCON,1,5))+"000"
			
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
			_cB_Campo   += u_Dgdvpct("8325375"+SUBSTR(_cNumboleta,3,3)+SUBSTR(_cNumboleta,1,1)+;
		                   SUBSTR(_cNumboleta,6,3)+SUBSTR(_cNumboleta,2,1)+SUBSTR(_cNumboleta,9,9)) //44-44 [01]- DV DO CAMPO LIVRE
			
			_cDV_BARRA := DgVerECF(_cB_Campo) //Calcula digito verificador do codigo de barras completo.
	
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
	//RestArea1(aArea)

Return(lRet)

/*/{Protheus.doc} Static Function MontaLinha
	Procede com a montagem da linha digitavel formados
	@type  Function
	@author Lt. Paulo - TDS
	@since 25/05/2011
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function MontaLinha()

	Do Case
		
		Case cE1PORTADO == "001"	// Banco do Brasil
			
			_cLineDig := ""
			_cnDigito := ""
			_cPedaco  := ""
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Primeiro Campo                                                             ³
			//³Codigo do Banco + Moeda + 5 primeiras posições do campo livre do Cod Barras³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_cPedaco := SubStr(_cCodBarras,01,03) + SubStr(_cCodBarras,04,01) + SubStr(_cCodBarras,20,5)
			DV_LINHA()
			_cLineDig := SubStr(_cCodBarras,1,3)+SubStr(_cCodBarras,4,1)+SubStr(_cCodBarras,20,1)+"."+SubStr(_cCodBarras,21,4) + _cnDigito + Space(2)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Segundo Campo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_cPedaco  := SubStr(_cCodBarras,25,10)
			DV_LINHA()
			_cLineDig += SubStr(_cPedaco,1,5)+"."+SubStr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Terceiro Campo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_cPedaco  := SubStr(_cCodBarras,35,10)
			DV_LINHA()
			_cLineDig += SubStr(_cPedaco,1,5)+"."+SubStr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quarto Campo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_cLineDig += _cDV_BARRA + Space(2)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quinto Campo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_cLineDig += _cFatorVcto + StrZero(Int(Round(_nVlrBol*100,2)),10)
			
		Case cE1PORTADO $ "SAF"	// Banco Safra   ALEX BORGES 03/04/12
			
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
			//_cPedaco  := SUBSTR(_cCarteira,2,1) + RIGHT(DTOC(DDATABASE),2) + SUBSTR(ALLTRIM(_cNumboleta),1,5) 
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
		
			
		Case cE1PORTADO $ "237|RED|BRD"	// Bradesco / RED FACTOR
			_cLineDig := ""
			_cnDigito := ""
			_cPedaco  := ""
			
			_cCodBr := SubStr(_cCodBarras,20,44)
			
			//Primeiro Campo
			//Codigo do Banco + Moeda + 5 primeiras posições do campo livre do Cod Barras
			_cPedaco := SubStr(_cCodBarras,01,03) + SubStr(_cCodBarras,04,01) + SubStr(_cCodBr,01,05)
			DV_LINHA()
			_cLineDig := SubStr(_cCodBarras,1,3)+SubStr(_cCodBarras,4,1)+SubStr(_cCodBr,01,01)+"."+SubStr(_cCodBr,02,04) + _cnDigito + Space(2)
			
			//Segundo Campo
			_cPedaco  := SubStr(_cCodBr,06,10)
			DV_LINHA()
			_cLineDig += SubStr(_cPedaco,1,5)+"."+SubStr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Terceiro Campo
			_cPedaco  := SubStr(_cCodBr,16,10)
			DV_LINHA()
			_cLineDig += SubStr(_cPedaco,1,5)+"."+SubStr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Quarto Campo
			_cLineDig += _cDV_BARRA + Space(2)
			
			//Quinto Campo
			_cLineDig += _cFatorVcto + StrZero(Int(Round(_nVlrBol*100,2)),10)
			
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
			
		Case cE1PORTADO $ "399/637"		// HSBC
			
			_cLineDig := ""
			_cnDigito := ""
			_cPedaco  := ""
			
			//Primeiro Campo
			//Codigo do Banco + Moeda + 5 primeiras posições do campo livre do Cod Barras
			_cPedaco := SubStr(_cCodBarras,01,03) + SubStr(_cCodBarras,04,01) + SubStr(_cCodBarras,20,5)
			DV_LINHA()
			_cLineDig := SubStr(_cCodBarras,1,3)+SubStr(_cCodBarras,4,1)+SubStr(_cCodBarras,20,1)+"."+SubStr(_cCodBarras,21,4) + _cnDigito + Space(2)
			
			//Segundo Campo
			_cPedaco  := SubStr(_cCodBarras,25,10)
			DV_LINHA()
			_cLineDig += SubStr(_cPedaco,1,5)+"."+SubStr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Terceiro Campo
			_cPedaco  := SubStr(_cCodBarras,35,10)
			DV_LINHA()
			_cLineDig += SubStr(_cPedaco,1,5)+"."+SubStr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Quarto Campo
			_cLineDig += _cDV_BARRA + Space(2)
			
			//Quinto Campo
			_cLineDig += _cFatorVcto + StrZero(Int(Round(_nVlrBol*100,2)),10)
			
		Case cE1PORTADO == "033"		// SATANDER
			
			_cLineDig := ""
			_cnDigito := ""
			_cPedaco  := ""
			
			//Primeiro Campo
			//Codigo do Banco + Moeda + 5 primeiras posições do campo livre do Cod Barras
			_cPedaco := SubStr(_cCodBarras,01,03) + SubStr(_cCodBarras,04,01) + SubStr(_cCodBarras,20,5)
			DV_LINHA()
			_cLineDig := SubStr(_cCodBarras,1,3)+SubStr(_cCodBarras,4,1)+SubStr(_cCodBarras,20,1)+"."+SubStr(_cCodBarras,21,4) + _cnDigito + Space(2)
			
			//Segundo Campo
			_cPedaco  := SubStr(_cCodBarras,25,10)
			DV_LINHA()
			_cLineDig += SubStr(_cPedaco,1,5)+"."+SubStr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Terceiro Campo
			_cPedaco  := SubStr(_cCodBarras,35,10)
			DV_LINHA()
			_cLineDig += SubStr(_cPedaco,1,5)+"."+SubStr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Quarto Campo
			_cLineDig += _cDV_BARRA + Space(2)
			
			//Quinto Campo
			_cLineDig += _cFatorVcto + StrZero(Int(Round(_nVlrBol*100,2)),10)
			
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
			
		Case cE1PORTADO $ "655"		// VOTORANTIM
			
			_cLineDig := ""
			_cnDigito := ""
			_cPedaco  := ""
			
			//Primeiro Campo
			//Codigo do Banco + Moeda + 5 primeiras posições do campo livre do Cod Barras
			_cPedaco := SubStr(_cCodBarras,01,03) + SubStr(_cCodBarras,04,01) + SubStr(_cCodBarras,20,5)
			DV_LINHA()
			_cLineDig := SubStr(_cCodBarras,1,3)+SubStr(_cCodBarras,4,1)+SubStr(_cCodBarras,20,1)+"."+SubStr(_cCodBarras,21,4) + _cnDigito + Space(2)
			
			//Segundo Campo
			_cPedaco  := SubStr(_cCodBarras,25,10)
			DV_LINHA()
			_cLineDig += SubStr(_cPedaco,1,5)+"."+SubStr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Terceiro Campo
			_cPedaco  := SubStr(_cCodBarras,35,10)
			DV_LINHA()
			_cLineDig += SubStr(_cPedaco,1,5)+"."+SubStr(_cPedaco,6,5)+_cnDigito+Space(2)
			
			//Quarto Campo
			_cLineDig += _cDV_BARRA + Space(2)
			
			//Quinto Campo
			_cLineDig += _cFatorVcto + StrZero(Int(Round(_nVlrBol*100,2)),10)
		
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
			//_cLineDig := _cLineDig + Substr(_cPedaco,1,5)+"."+Substr(_cPedaco,6,5)+_cnDigito+Space(2)
		    _cLineDig += Substr(_cPedaco,1,5) +"."+ Substr(_cPedaco,6,5) + ADMOD10(1,_cPedaco)+ Space(2)
	
		
			//Quarto Campo
			_cLineDig += _cDV_BARRA + Space(2)
			
			
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

/*/{Protheus.doc} Static Function DV_LINHA
	Calculo do digito da linha digitaval 
	@type  Function
	@author Lt. Paulo - TDS
	@since 25/05/2011
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function DV_LINHA()

	Do Case
		
		// Banco do Brasil
		Case cE1PORTADO == "001"
			nCont  := 0
			_cPeso := 2
			
			For i := Len(_cPedaco) to 1 Step -1
				
				If _cPeso == 3
					_cPeso := 1
				EndIf
				
				If Val(SubStr(_cPedaco,i,1))*_cPeso >= 10
					nVal  := Val(SubStr(_cPedaco,i,1)) * _cPeso
					nCont += (Val(SubStr(Str(nVal,2),1,1))+Val(SubStr(Str(nVal,2),2,1)))
				Else
					nCont += (Val(SubStr(_cPedaco,i,1)) * _cPeso)
				EndIf
				
				_cPeso++
				
			Next
			
			_cDezena  := SubStr(Str(nCont,2),1,1)
			_cResto   := ((Val(_cDezena)+1) * 10) - nCont
			
			// Paulo - TDS - 30/05/11
			_cnDigito := If(_cResto==10,"0",StrZero(_cResto,1))
			
		Case cE1PORTADO $ "422/SAF/SFF" 
			
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
			
		Case cE1PORTADO $ "237|RED|BRD"		// Bradesco / RED FACTOR
			nCont  := 0
			_cPeso := 2
			
			For i := Len(_cPedaco) to 1 Step -1
				
				If _cPeso == 3
					_cPeso := 1
				EndIf
				
				If Val(SubStr(_cPedaco,i,1))*_cPeso >= 10
					nVal  := Val(SubStr(_cPedaco,i,1)) * _cPeso
					nCont += (Val(SubStr(Str(nVal,2),1,1))+Val(SubStr(Str(nVal,2),2,1)))
				Else
					nCont += (Val(SubStr(_cPedaco,i,1)) * _cPeso)
				EndIf
				
				_cPeso++
				
			Next
			
			_cDezena := SubStr(Str(nCont,2),1,1)
			_cResto  := ((Val(_cDezena)+1) * 10) - nCont
			
			// Paulo - TDS - 30/05/11
			_cnDigito := If(_cResto>=10,"0",StrZero(_cResto,1))
			
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
			
		Case cE1PORTADO $ "399/637"		// HSBC
			nCont  := 0
			_cPeso := 2
			
			For i := Len(_cPedaco) to 1 Step -1
				
				If _cPeso == 3
					_cPeso := 1
				EndIf
				
				If Val(SubStr(_cPedaco,i,1)) * _cPeso >= 10
					nVal  := Val(SubStr(_cPedaco,i,1)) * _cPeso
					nCont += (Val(SubStr(Str(nVal,2),1,1))+Val(SubStr(Str(nVal,2),2,1)))
				Else
					nCont += (Val(SubStr(_cPedaco,i,1)) * _cPeso)
				EndIf
				
				_cPeso++
				
			Next
			
			_cDezena := SubStr(Str(nCont,2),1,1)
			_cResto  := ((Val(_cDezena)+1) * 10) - nCont
			
			// Paulo - TDS - 30/05/11
			_cnDigito := If(_cResto==10,"0",StrZero(_cResto,1))
			
		Case cE1PORTADO == "033"		// SANTANDER
			nCont  := 0
			_cPeso := 2
			
			For i := Len(_cPedaco) to 1 Step -1
				
				If _cPeso == 3
					_cPeso := 1
				EndIf
				
				If Val(SubStr(_cPedaco,i,1)) * _cPeso >= 10
					nVal  := Val(SubStr(_cPedaco,i,1)) * _cPeso
					nCont += (Val(SubStr(Str(nVal,2),1,1))+Val(SubStr(Str(nVal,2),2,1)))
				Else
					nCont += (Val(SubStr(_cPedaco,i,1)) * _cPeso)
				EndIf
				
				_cPeso++
				
			Next
			
			_cDezena  := SubStr(Str(nCont,2),1,1)
			_cResto   := ((Val(_cDezena)+1) * 10) - nCont
			
			// Paulo - TDS - 30/05/11
			_cnDigito := If(_cResto==10,"0",StrZero(_cResto,1))  
			
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
			
		Case cE1PORTADO $ "341/655/ITV"		// ITAU/VOTORANTIM
			nCont  := 0
			_cPeso := 2
			
			For i := Len(_cPedaco) to 1 Step -1
				
				If _cPeso == 3
					_cPeso := 1
				EndIf
				
				If Val(SubStr(_cPedaco,i,1)) * _cPeso >= 10
					nVal  := Val(SubStr(_cPedaco,i,1)) * _cPeso
					nCont += (Val(SubStr(Str(nVal,2),1,1))+Val(SubStr(Str(nVal,2),2,1)))
				Else
					nCont += (Val(SubStr(_cPedaco,i,1)) * _cPeso)
				EndIf
				
				_cPeso++
				
			Next
			
			_cDezena  := SubStr(Str(nCont,2),1,1)
			_cResto   := ((Val(_cDezena)+1) * 10) - nCont
			
			// Paulo - TDS - 30/05/11
			If cE1PORTADO == "655"
				_cnDigito := If((_cResto==0 .Or. _cResto >= 10),"0",StrZero(_cResto,1))
			Else
				_cnDigito := If((_cResto==0 .Or. _cResto == 1 .Or. _cResto >= 10),"1",StrZero(_cResto,1))
			EndIf
		
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

/*/{Protheus.doc} Static Function fDACItau
	Calcula DAC Itau
	@type  Function
	@author Lt. Paulo - TDS
	@since 25/05/2011
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function fDACITAU(cAgenConta)

	Local cRet := ""
	
	Local nP1 	 := Val(SubStr(cAgenConta,01,1)) * 2
	Local nP2 	 := Val(SubStr(cAgenConta,02,1)) * 1
	Local nP3 	 := Val(SubStr(cAgenConta,03,1)) * 2
	Local nP4 	 := Val(SubStr(cAgenConta,04,1)) * 1
	Local nP5 	 := Val(SubStr(cAgenConta,05,1)) * 2
	Local nP6 	 := Val(SubStr(cAgenConta,06,1)) * 1
	Local nP7 	 := Val(SubStr(cAgenConta,07,1)) * 2
	Local nP8 	 := Val(SubStr(cAgenConta,08,1)) * 1
	Local nP9 	 := Val(SubStr(cAgenConta,09,1)) * 2
	Local nDC 	 := nP1 + nP2 + nP3 + nP4 + nP5 + nP6 + nP7 + nP8 + nP9
	Local nResto := ( nDC % 10 )
	Local nRet	 := 10 - nResto
	
	cRet := If(nRet >= 10,"0",StrZero(nRet,1))

Return(cRet)

/*/{Protheus.doc} Static Function NNumDV
	Calculo digito verificador nosso numero
	@type  Function
	@author Lt. Paulo - TDS
	@since 25/05/2011
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function NNumDV(cDACItau)

	Do Case
		
		Case cE1PORTADO == "001"	// Banco do Brasil
			
			_cnCont := 0
			_ccPeso := 9
			
			For i := 11 To 1 Step -1
				_cnCont += (Val(SubStr(_cNumBoleta,i,1))) * _ccPeso
				_ccPeso := _ccPeso - 1
				
				If _ccPeso == 1
					_ccPeso := 9
				EndIf
			Next
			
			_cResto := ( _cnCont % 11 )
			
			// Paulo - TDS - 30/05/2011
			
			_cDV_NNUM := If(_cResto < 10,StrZero(_cResto,1),"X")
			
		Case cE1PORTADO $ "422/SAF/SFF"	// Banco Safra   ALEX BORGES 03/04/12
		//Case cE1PORTADO == "422"	// Banco Safra	
			_cnCont   := 0
			_ccPeso   := 9
			_cnBoleta := _cNumBoleta
			
			nP1 := Val(SubStr(_cNumBoleta,01,1)) * 9
			nP2 := Val(SubStr(_cNumBoleta,02,1)) * 8
			nP3 := Val(SubStr(_cNumBoleta,03,1)) * 7
			nP4 := Val(SubStr(_cNumBoleta,04,1)) * 6
			nP5 := Val(SubStr(_cNumBoleta,05,1)) * 5
			nP6 := Val(SubStr(_cNumBoleta,06,1)) * 4
			nP7 := Val(SubStr(_cNumBoleta,07,1)) * 3
			nP8 := Val(SubStr(_cNumBoleta,08,1)) * 2
			
			_nValor := nP1 + nP2 + nP3 + nP4 + nP5 + nP6 + nP7 + nP8
			_cResto := _nValor % 11
			
			If     _cResto == 0
				_cDV_NNUM := '1'
			ElseIf _cResto == 1
				_cDV_NNUM := '0'
			Else
				_cResto := 11 - _cResto
				_cDV_NNUM := AllTrim(Str(_cResto))
			EndIf
			
		Case cE1PORTADO $ "237|RED|BRD"	// Bradesco / RED FACTOR
			
			_cnCont   := 0
			_ccPeso   := 2
			_cnBoleta := "09" + _cNumBoleta
			
			For i := 13 To 1 Step -1
				
				_cnCont += (Val(SubStr(_cnBoleta,i,1))) * _ccPeso
				
				_ccPeso++
				
				If _ccPeso == 8
					_ccPeso := 2
				EndIf
				
			Next
			
			_cResto := ( _cnCont % 11 )
			
			Do Case
				Case _cResto == 1
					_cDV_NNUM := "P"
				Case _cResto == 0
					_cDV_NNUM := "0"
				OtherWise
					_cResto   := ( 11 - _cResto )
					_cDV_NNUM := AllTrim(Str(_cResto))
			EndCase
			
		// *** INICIO CHAMADO 050420	
		Case cE1PORTADO $ "BRV"	// Bradesco

			_cnCont   := 0
			_ccPeso   := 2
			_cnBoleta :="02" + Alltrim(_cNumBoleta)
	
			For i := 13 To 1 Step -1
	
				_cnCont := _cnCont + (Val(SUBSTR(_cnBoleta,i,1))) * _ccPeso
	
				_ccPeso := _ccPeso + 1
	
				If _ccPeso == 8
					_ccPeso := 2
				Endif
	
			Next
	
			_cResto := ( _cnCont % 11 )
	
			Do Case
				Case _cResto == 1
				_cDV_NNUM := "P"
				Case _cResto == 0
				_cDV_NNUM := "0"
				OtherWise
				_cResto   := ( 11 - _cResto )
				_cDV_NNUM := AllTrim(Str(_cResto))
			EndCase	
			
		// *** FINAL CHAMADO 050420		
			
		Case cE1PORTADO == "246"	// ABC
			_cnCont   := 0
			_ccPeso   := 2
			_cnBoleta := "09" + _cNumBoleta
			
			For i := 13 To 1 Step -1
				
				_cnCont += (Val(SubStr(_cnBoleta,i,1))) * _ccPeso
				_ccPeso++
				
				If _ccPeso == 8
					_ccPeso := 2
				EndIf
			Next
			
			_cResto := ( _cnCont % 11 )
			
			Do Case
				Case _cResto == 1
					_cDV_NNUM := "P"
				Case _cResto == 0
					_cDV_NNUM := "0"
				OtherWise
					_cResto   := ( 11 - _cResto )
					_cDV_NNUM := AllTrim(Str(_cResto))
			EndCase
			
		Case cE1PORTADO == "399"	// HSBC
			
			nP1 := Val(SubStr(_cNumBoleta,01,1)) * 5
			nP2 := Val(SubStr(_cNumBoleta,02,1)) * 4
			nP3 := Val(SubStr(_cNumBoleta,03,1)) * 3
			nP4 := Val(SubStr(_cNumBoleta,04,1)) * 2
			nP5 := Val(SubStr(_cNumBoleta,05,1)) * 7
			nP6 := Val(SubStr(_cNumBoleta,06,1)) * 6
			nP7 := Val(SubStr(_cNumBoleta,07,1)) * 5
			nP8 := Val(SubStr(_cNumBoleta,08,1)) * 4
			nP9 := Val(SubStr(_cNumBoleta,09,1)) * 3
			nP0 := Val(SubStr(_cNumBoleta,10,1)) * 2
			
			_nRHSBC := nP1 + nP2 + nP3 + nP4 + nP5 + nP6 + nP7 + nP8 + nP9 + nP0
			_nResto := ( _nRHSBC % 11 )
			
			If _nResto == 0 .Or. _nResto == 1
				_nResto := 0
			Else
				_nResto := 11 - _nResto
			EndIf
			
			_cDV_NNUM := Str(_nResto,1)
			
		Case cE1PORTADO == "637"	// SOFISA
			
			nP1 := Val(SubStr(_cNumBoleta,01,1)) * 5
			nP2 := Val(SubStr(_cNumBoleta,02,1)) * 4
			nP3 := Val(SubStr(_cNumBoleta,03,1)) * 3
			nP4 := Val(SubStr(_cNumBoleta,04,1)) * 2
			nP5 := Val(SubStr(_cNumBoleta,05,1)) * 7
			nP6 := Val(SubStr(_cNumBoleta,06,1)) * 6
			nP7 := Val(SubStr(_cNumBoleta,07,1)) * 5
			nP8 := Val(SubStr(_cNumBoleta,08,1)) * 4
			nP9 := Val(SubStr(_cNumBoleta,09,1)) * 3
			nP0 := Val(SubStr(_cNumBoleta,10,1)) * 2
			
			_nRHSBC := nP1 + nP2 + nP3 + nP4 + nP5 + nP6 + nP7 + nP8 + nP9 + nP0
			_nResto := ( _nRHSBC % 11 )
			
			If _nResto == 0 .Or. _nResto == 1
				_nResto := 0
			Else
				_nResto := 11 - _nResto
			EndIf
			
			_cDV_NNUM := Str(_nResto,1)
			
		Case cE1PORTADO == "033"	// SANTANDER
			
			nP01 := Val(SubStr(_cNumBoleta,12,1)) * 2
			nP02 := Val(SubStr(_cNumBoleta,11,1)) * 3
			nP03 := Val(SubStr(_cNumBoleta,10,1)) * 4
			nP04 := Val(SubStr(_cNumBoleta,09,1)) * 5
			nP05 := Val(SubStr(_cNumBoleta,08,1)) * 6
			nP06 := Val(SubStr(_cNumBoleta,07,1)) * 7
			nP07 := Val(SubStr(_cNumBoleta,06,1)) * 8
			nP08 := Val(SubStr(_cNumBoleta,05,1)) * 9
			nP09 := Val(SubStr(_cNumBoleta,04,1)) * 2
			nP10 := Val(SubStr(_cNumBoleta,03,1)) * 3
			nP11 := Val(SubStr(_cNumBoleta,02,1)) * 4
			nP12 := Val(SubStr(_cNumBoleta,01,1)) * 5
			
			_nRSANT := nP01 + nP02 + nP03 + nP04 + nP05 + nP06 + nP07 + nP08 + nP09 + nP10 + nP11 + nP12
			
			_nResto := ( _nRSANT % 11 )
			If     _nResto == 10
				_cDV_NNUM := "1"
			ElseIf _nResto == 1 .Or. _nResto == 0
				_cDV_NNUM := "0"
			Else
				_nResto := 11 - _nResto
				_cDV_NNUM := Str(_nResto,1)
			EndIf
		    Case cE1PORTADO == "104"	// caixa economica federal
	        
	        _cNumBoleta := Alltrim(_cNumBoleta)
	       
	        nP01 := Val(Substr(_cNumBoleta,17,1)) * 2
	        nP02 := Val(Substr(_cNumBoleta,16,1)) * 3
	        nP03 := Val(Substr(_cNumBoleta,15,1)) * 4
	        nP04 := Val(Substr(_cNumBoleta,14,1)) * 5
	        nP05 := Val(Substr(_cNumBoleta,13,1)) * 6
	        nP06 := Val(Substr(_cNumBoleta,12,1)) * 7
	        nP07 := Val(Substr(_cNumBoleta,11,1)) * 8
	        nP08 := Val(Substr(_cNumBoleta,10,1)) * 9
	        nP09 := Val(Substr(_cNumBoleta,09,1)) * 2
	        nP10 := Val(Substr(_cNumBoleta,08,1)) * 3
	        nP11 := Val(Substr(_cNumBoleta,07,1)) * 4
	        nP12 := Val(Substr(_cNumBoleta,06,1)) * 5
	        nP13 := Val(Substr(_cNumBoleta,05,1)) * 6
	        nP14 := Val(Substr(_cNumBoleta,04,1)) * 7
	        nP15 := Val(Substr(_cNumBoleta,03,1)) * 8
	        nP16 := Val(Substr(_cNumBoleta,02,1)) * 9
	        nP17 := Val(Substr(_cNumBoleta,01,1)) * 2
	        
	        _nRSANT := nP01 + nP02 + nP03 + nP04 + nP05 + nP06 + nP07 + nP08 + nP09 + nP10 + nP11 + nP12+;
	                   nP13 + nP14 + nP15 + nP16 + nP17
	  
	        _nResto := ( _nRSANT % 11 )
	        
	        _nResto := 11 - _nResto
	        
	        If _nResto > 9
	       	
	       		_cDV_NNUM := "0"
	        
	        Else
	       	
	       		_cDV_NNUM := Str(_nResto,1)
	        
	        Endif		
		
		Case cE1PORTADO  $  "341/655/KOB/ITV"	// VOTORANTIM
			
			nP01 := Val(SubStr(cDACItau,01,01)) * 1
			If nP01 > 9
				nP01 := AllTrim(Str(nP01))
				nP01 := Val(SubStr(nP01,1,1)) + Val(SubStr(nP01,2,1))
			EndIf
			
			nP02 := Val(SubStr(cDACItau,02,01)) * 2
			If nP02 > 9
				nP02 := AllTrim(Str(nP02))
				nP02 := Val(SubStr(nP02,1,1)) + Val(SubStr(nP02,2,1))
			EndIf
			
			nP03 := Val(SubStr(cDACItau,03,01)) * 1
			If nP03 > 9
				nP03 := AllTrim(Str(nP03))
				nP03 := Val(SubStr(nP03,1,1)) + Val(SubStr(nP03,2,1))
			EndIf
			
			nP04 := Val(SubStr(cDACItau,04,01)) * 2
			If nP04 > 9
				nP04 := AllTrim(Str(nP04))
				nP04 := Val(SubStr(nP04,1,1)) + Val(SubStr(nP04,2,1))
			EndIf
			
			nP05 := Val(SubStr(cDACItau,05,01)) * 1
			If nP05 > 9
				nP05 := AllTrim(Str(nP05))
				nP05 := Val(SubStr(nP05,1,1)) + Val(SubStr(nP05,2,1))
			EndIf
			
			nP06 := Val(SubStr(cDACItau,06,01)) * 2
			If nP06 > 9
				nP06 := AllTrim(Str(nP06))
				nP06 := Val(SubStr(nP06,1,1)) + Val(SubStr(nP06,2,1))
			EndIf
			
			nP07 := Val(SubStr(cDACItau,07,01)) * 1
			If nP07 > 9
				nP07 := AllTrim(Str(nP07))
				nP07 := Val(SubStr(nP07,1,1)) + Val(SubStr(nP07,2,1))
			EndIf
			
			nP08 := Val(SubStr(cDACItau,08,01)) * 2
			If nP08 > 9
				nP08 := AllTrim(Str(nP08))
				nP08 := Val(SubStr(nP08,1,1)) + Val(SubStr(nP08,2,1))
			EndIf
			
			nP09 := Val(SubStr(cDACItau,09,01)) * 1
			If nP09 > 9
				nP09 := AllTrim(Str(nP01))
				nP09 := Val(SubStr(nP09,1,1)) + Val(SubStr(nP09,2,1))
			EndIf
			
			nP10 := Val(SubStr(cDACItau,10,01)) * 2
			If nP10 > 9
				nP10 := AllTrim(Str(nP10))
				nP10 := Val(SubStr(nP10,1,1)) + Val(SubStr(nP10,2,1))
			EndIf
			
			nP11 := Val(SubStr(cDACItau,11,01)) * 1
			If nP11 > 9
				nP11 := AllTrim(Str(nP11))
				nP11 := Val(SubStr(nP11,1,1)) + Val(SubStr(nP11,2,1))
			EndIf
			
			nP12 := Val(SubStr(cDACItau,12,01)) * 2
			If nP12 > 9
				nP12 := AllTrim(Str(nP12))
				nP12 := Val(SubStr(nP12,1,1)) + Val(SubStr(nP12,2,1))
			EndIf
			
			nP13 := Val(SubStr(cDACItau,13,01)) * 1
			If nP13 > 9
				nP13 := AllTrim(Str(nP13))
				nP13 := Val(SubStr(nP13,1,1)) + Val(SubStr(nP13,2,1))
			EndIf
			
			nP14 := Val(SubStr(cDACItau,14,01)) * 2
			If nP14 > 9
				nP14 := AllTrim(Str(nP14))
				nP14 := Val(SubStr(nP14,1,1)) + Val(SubStr(nP14,2,1))
			EndIf
			
			nP15 := Val(SubStr(cDACItau,15,01)) * 1
			If nP15 > 9
				nP15 := AllTrim(Str(nP15))
				nP15 := Val(SubStr(nP15,1,1)) + Val(SubStr(nP15,2,1))
			EndIf
			
			nP16 := Val(SubStr(cDACItau,16,01)) * 2
			If nP16 > 9
				nP16 := AllTrim(Str(nP16))
				nP16 := Val(SubStr(nP16,1,1)) + Val(SubStr(nP16,2,1))
			EndIf
			
			nP17 := Val(SubStr(cDACItau,17,01)) * 1
			If nP17 > 9
				nP17 := AllTrim(Str(nP17))
				nP17 := Val(SubStr(nP17,1,1)) + Val(SubStr(nP17,2,1))
			EndIf
			
			nP18 := Val(SubStr(cDACItau,18,01)) * 2
			If nP18 > 9
				nP18 := AllTrim(Str(nP18))
				nP18 := Val(SubStr(nP18,1,1)) + Val(SubStr(nP18,2,1))
			EndIf
			
			nP19 := Val(SubStr(cDACItau,19,01)) * 1
			If nP19 > 9
				nP19 := AllTrim(Str(nP19))
				nP19 := Val(SubStr(nP19,1,1)) + Val(SubStr(nP19,2,1))
			EndIf
			
			nP20 := Val(SubStr(cDACItau,20,01)) * 2
			If nP20 > 9
				nP20 := AllTrim(Str(nP20))
				nP20 := Val(SubStr(nP20,1,1)) + Val(SubStr(nP20,2,1))
			EndIf
			
			_nRSANT := nP01+nP02+nP03+nP04+nP05+nP06+nP07+nP08+nP09+nP10+nP11+nP12+nP13+nP14+nP15+nP16+nP17+nP18+nP19+nP20
			_nResto := ( _nRSANT % 10 )
			
			If _nResto > 0
				_nResto := 10 - _nResto
			EndIf
			
			If _nResto >= 10
				_cDV_NNUM := "0"
			Else
				_cDV_NNUM := Str(_nResto,1)
			EndIf
			
	EndCase
	
Return

/*/{Protheus.doc} Static Function BarraDV
	Calculo digito verificacao codigo barras
	@type  Function
	@author Lt. Paulo - TDS
	@since 25/05/2011
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function BarraDV()

	Do Case
		
		Case cE1PORTADO == "001"			// Banco do Brasil
			
			_cnCont := 0
			_ccPeso := 2
			
			For i := 43 To 1 Step -1
				_cnCont += (Val(SubStr(_cB_Campo,i,1)) * _ccPeso)
				_ccPeso++
				
				If _ccPeso >  9
					_ccPeso := 2
				EndIf
			Next
			
			_cResto  := (_cnCont % 11)
			_cResult := (11 - _cResto)
			
			Do Case
				Case _cResult == 10 .Or. _cResult == 11 .Or. _cResult == 0
					_cDV_BARRA := "1"
				OtherWise
					_cDV_BARRA := Str(_cResult,1)
			EndCase
			
		Case cE1PORTADO $ "422/SAF/SFF"			// Banco Safra    ALEX BORGES 03/04/12
			
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
			
		Case cE1PORTADO $ "237|RED|BRD"	// Bradesco / RED FACTOR
			
			_cnCont := 0
			_ccPeso := 2
			
			For i := 43 To 1 Step -1
				_cnCont += (Val(SubStr(_cB_Campo,i,1)) * _ccPeso)
				_ccPeso++
				
				If _ccPeso >  9
					_ccPeso := 2
				EndIf
			Next
			
			_cResto  := (_cnCont % 11)
			_cResult := (11 - _cResto)
			
			Do Case
				Case _cResult == 10 .Or. _cResult == 11
					_cDV_BARRA := "1"
				OtherWise
					_cDV_BARRA := Str(_cResult,1)
			EndCase
		
		// *** INICIO CHAMADO 050420
		Case cE1PORTADO $ "BRV"	// Bradesco

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
			
		Case cE1PORTADO $ "399/637"	// HSBC
			
			_cnCont := 0
			_ccPeso := 2
			
			For i := 43 To 1 Step -1
				_cnCont += (Val(SubStr(_cB_Campo,i,1)) * _ccPeso)
				_ccPeso++
				
				If _ccPeso >  9
					_ccPeso := 2
				EndIf
				
			Next
			
			_cResto  := (_cnCont % 11)
			_cResult := (11 - _cResto)
			
			Do Case
				Case _cResult == 10 .Or. _cResult == 11
					_cDV_BARRA := "1"
				OtherWise
					_cDV_BARRA := Str(_cResult,1)
			EndCase
			
		Case cE1PORTADO == "033"	// SANTANDER
			
			_cnCont := 0
			_ccPeso := 2
			
			For i := 43 To 1 Step -1
				_cnCont += (Val(SubStr(_cB_Campo,i,1)) * _ccPeso)
				_ccPeso++
				
				If _ccPeso >  9
					_ccPeso := 2
				EndIf
				
			Next
			
			_cResto  := (_cnCont % 11)
			_cResult := (11 - _cResto)
			
			Do Case
				Case _cResult == 0 .Or. _cResult == 1 .Or. _cResult == 10
					_cDV_BARRA := "1"
				OtherWise
					_cDV_BARRA := Str(_cResult,1)
			EndCase
			
		Case cE1PORTADO $ "341/655/KOB/ITV"	// ITAU
			
			_cnCont := 0
			_ccPeso := 2
			
			For i := 43 To 1 Step -1
				_cnCont += (Val(SubStr(_cB_Campo,i,1)) * _ccPeso)
				_ccPeso++
				
				If _ccPeso >  9
					_ccPeso := 2
				EndIf
			Next
			
			_cResto  := (_cnCont % 11)
			_cResult := (11 - _cResto)
			
			Do Case
				Case _cResult == 0 .Or. _cResult == 1 .Or. _cResult >= 10
					_cDV_BARRA := "1"
				OtherWise
					_cDV_BARRA := Str(_cResult,1)
			EndCase
			
	EndCase

Return()

/*/{Protheus.doc} Static Function Validaperg
	SX1 - PERGUNTE
	@type  Function
	@author Lt. Paulo - TDS
	@since 25/05/2011
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ValidPerg()

	Local _sAlias := Alias()
	Local aRegs   := {}
	Local i, j
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	
	cPerg := PADR(cPerg,10," ")
	
	AADD(aRegs,{cPerg,"01","Emissao de  ","","","mv_ch1","D",08,0,0,"G","","Mv_Par01","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Emissao Ate ","","","mv_ch2","D",08,0,0,"G","","Mv_Par02","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Titulo   	","","","mv_ch3","C",TAMSX3("E1_NUM")[1],0,0,"G","","Mv_Par03","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Prefixo     ","","","mv_ch4","C",03,0,0,"G","","Mv_Par04","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Parcela     ","","","mv_ch5","C",01,0,0,"G","","Mv_Par05","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"06","1-Instruções","","","mv_ch6","C",90,0,0,"G","","Mv_Par06","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"07","2-Instruções","","","mv_ch7","C",90,0,0,"G","","Mv_Par07","","","","","","","","","","","","","",""})
	
	For i := 1 to Len(aRegs)
		If !dbSeek(cPerg + aRegs[i, 2])
			RecLock("SX1",.T.)
			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j, aRegs[i, j])
				EndIf
			Next
			MsUnlock()
		EndIf
	Next
	
	dbSelectArea(_sAlias)

Return

/*/{Protheus.doc} User Function DgDvpct
	Calcula digito verificador - codigo campo livre CEF
	@type  Function
	@author Fernando Sigoli
	@since 06/01/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 032158
/*/
User Function Dgdvpct(cCampoLiv)

	Local _nRSANT := 0

	U_ADINF009P('ADRBOL' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Reemissão de boletos, em caso da não geração durante a rotina do faturamento')

	
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

/*/{Protheus.doc} Static Function DgVerECF
	Calcula digito verificador - codigo barras banco CEF
	@type  Function
	@author Fernando Sigoli
	@since 06/01/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 032158
/*/
Static Function DgVerECF(cCodBarra)

	Local _nRSANT := 0

	
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

/*/{Protheus.doc} Static Function ADMOD10
	Modelo 10
	@type  Function
	@author
	@since 
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
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
