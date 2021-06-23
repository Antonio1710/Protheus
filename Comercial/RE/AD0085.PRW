#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} User Function AD0085
	Relatorio de Faturamento por Vendedor
	@type  Function
	@author Daniel
	@since 01/04/2006
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
    @history chamado 050729 - FWNM - 26/06/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE
/*/
User Function AD0085()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Relatório "
	Local cPict          := ""
	Local titulo         := "Relatorio Por Regiao "
	Local nLin           := 80
	Local Cabec1         := "Faturamento Por Regiao"
	Local imprime        := .T.
	Local aOrd 				:= {}

	Private ImpCli 		:= {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "AD0085" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 15
	//Private aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 0}
	Private _TipCliRed   := ''
	Private nLastKey     := 0
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "AD0085" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cPerg        := "AD0085"
	Private _lSup			:=0  //Verifica se e vendedor ou superior
	Private _nFatu			:=0  //total faturado
	Private _cVend    	:= ''
	Private _nQtde     	:= 0
	Private _nFat      	:= 0
	Private _cVendedor 	:= ''
	Private _nSpmedio  	:= 0
	Private _nQtde_Det 	:= 0
	Private _nValorDet 	:= 0
	Private _nNPed			:=0 //Numero de pedidos, Conta o Numero de Pedidos
	Private _nNPedGV		:=0 //Numero total de Pedidos
	Private _nNPed			:=0 //Numero total de Pedidos
	Private _dft			:=0  //Devolucao FAT
	Private _dqt			:=0  //Devolucao QTD

	/*REDE*/
	Private _RDNOME 		:='' //NOME DA REDE
	Private _RDCOD 		:=''    //CODIGO DA REDE
	Private _RDCGC 		:=''    //CGC
	Private _nFRd			:=0        //TOTAL DA REDE
	pRIVATE cCod			:=''  //cODIGO DO CLIENETE
	pRIVATE _FATREDE		:=0 //TOTAL DA REDE
	pRIVATE _LRede			:=.F.
	pRIVATE _nRdqt			:=0
	Private _rdft 			:= 0  //DEVOLUCAO FATURADO
	Private _rdqt 			:= 0  //DEVOLUCAO QUANTIDADE
	Private _TnQtd  		:= 0
	Private _cVNome 		:= ''
	Private _TfLiq			:= 0
	Private cRetTES		:= fRetTES()	&& Retorna TES utilizadas em Bonificacao conf. parametro ZZ_TESBONI

	/*TOTAIS GERAIS DML */
	public _nFatG 			:=0
	public _nPerG 			:=0
	public _nPMedG			:=0
	public _nQtdeG			:=0

	/*TOTAL GERAL DML */
	public _nFatGG 		:=0
	public _nPerGG 		:=0
	public _nPMedGG		:=0
	public _nQtdeGG		:=0  

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Faturamento por Vendedor Analitico')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRUPO DE TES VALIDOS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_nGTes:= Getmv("MV_CLIATI")
	_nGTes:=alltrim(_nGTes)
	_nGNf:= Getmv("MV_TIPONFS")
	_nGNf:=alltrim(_nGNf)

	Private cString := "SD2"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//³ avaliando quem é o usuario para saber se é vendedor                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DBSELECTAREA("SA3")
	DBSETORDER(2)             //FILIAL+NOME
	IF DBSEEK(xFilial("SA3")+ALLTRIM(CUSERNAME),.T.)
		cPerg   := "AD085a"
		
		pergunte(cPerg,.T.)
		_dDatIni  := DTOS(mv_par01)   //data inicial
		_dDataFim := DTOS(mv_par02)   //data final
		wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .T., Tamanho,, .T.)
		_cTipoRel := 0    //Tipo de Relatorio Sintetico/Analitico
		
		_cCodSup1  := ''      //Supervisor Inicial
		_cCodSup2  := ''      //Supervisor Final
		
		_cCodVen1  := ''      //Vendedor Inicial
		_cCodVen2  := ''      //Vendedor Final
		
	Else
		pergunte(cPerg,.T.)
		_dDatIni  := DTOS(mv_par01)   //data inicial
		_dDataFim := DTOS(mv_par02)   //data final
		wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .T., Tamanho,, .T.)
		_cTipoRel := mv_par03   //Tipo de Relatorio Sintetico/Analitico
		
		_cCodSup1  := mv_par04   //Supervisor Inicial
		_cCodSup2  := mv_par05   //Supervisor Final
		
		_cCodVen1  := mv_par06   //Vendedor Inicial
		_cCodVen2  := mv_par07   //Vendedor Final
		
	Endif

	Private Cabec2         := "Periodo De "+DTOC(mv_par01)+"  Até "+DTOC(mv_par02)

	//wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .T., Tamanho,, .T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 26/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem

	dbSelectArea(cString)
	dbSetOrder(1)

	//MONTA ARQUIVO DE TRABALHO PARA IMPRIMIR NA ORDEM DE FATURAMENTO.
	AADD (ImpCli,{"TipoRel" ,"C",6,0})   	//TIPO RELATORIO CLINTES / REDES
	AADD (ImpCli,{"CodCli"  ,"C",08})     	//CODIGO CLIENTE
	AADD (ImpCli,{"LojCli"  ,"C",02})     	//LOJA CLIENTE
	AADD (ImpCli,{"NomCli"  ,"C",48})      	//NOME CLIENTE
	AADD (ImpCli,{"CodVen"  ,"C",06})     	//CODIGO VENDEDOR
	AADD (ImpCli,{"ValFat"  ,"N",14,2})     //VALOR DO FATURAMENTO
	AADD (ImpCli,{"ValDev"  ,"N",10,02})   	//VALOR DA DEVOLUÇÃO
	AADD (ImpCli,{"QtdFat"  ,"N",10,02})   	//QUANTIDADE FATURADA
	AADD (ImpCli,{"QtdDev"  ,"N",10})      	//QUANTIDADE DEVOLVIDA
	AADD (ImpCli,{"DesFin"  ,"N",12,2})     //DESCONTO FINANCEIRO
	AADD (ImpCli,{"CodRed"  ,"C",06})      	//CODIGO DA REDE
	AADD (ImpCli,{"PercFat" ,"N",13,02})    //PERCENTUAL EM RELAÇÃO AO FATURAMENTO
	AADD (ImpCli,{"OrderFat" ,"N",14,03})   //PERCENTUAL EM RELAÇÃO AO FATURAMENTO

	// Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - FWNM - 26/06/2020
	
	//Criar tabela temporária
	_cNom:=CriaTrab(IMPCLI, .T.)

	//Definir indices da tabela	
	cIndice1 := Alltrim(CriaTrab(,.F.))
	cIndice2 := Alltrim(CriaTrab(,.F.))
	cIndice3 := Alltrim(CriaTrab(,.F.))

	cIndice1 := Left(cIndice1,5)+Right(cIndice1,2)+"A"
	cIndice2 := Left(cIndice2,5)+Right(cIndice2,2)+"B"
	cIndice3 := Left(cIndice3,5)+Right(cIndice3,2)+"C"

	If File(cIndice1+OrdBagExt())
		FErase(cIndice1+OrdBagExt())
	EndIf

	If File(cIndice2+OrdBagExt())
		FErase(cIndice2+OrdBagExt())
	EndIf

	If File(cIndice3+OrdBagExt())
		FErase(cIndice3+OrdBagExt())
	EndIf

	//Criar e abrir a tabela
	dbUseArea(.T.,,_cNom,"TEMP",Nil,.F.)
	
	/*Criar indice*/
	IndRegua("TEMP", cIndice1, "Tiporel+Codcli+Lojcli"	,,, "Indice 1...")
	IndRegua("TEMP", cIndice2, "CodRed+CodCli+LojCli","D",, "Indice 2...")
	IndRegua("TEMP", cIndice3, "STR(OrderFat,14,3)","D",, "Indice 3...")

    dbClearIndex()
	
    dbSetIndex(cIndice1+OrdBagExt())
	dbSetIndex(cIndice2+OrdBagExt())
	dbSetIndex(cIndice3+OrdBagExt())

    TEMP->( dbSetOrder(1) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³CONTROLE DE VENDEDORES                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//PROCURA NO CADASTRO DE VENDEDORES O USUARIO LOGADO
	//PRCURO O NOME DO USURIO NO CADASTRO DE VENDEDORES
	//SE ENCONTROU GRAVA SEU CODIGO
	//PROCURA SE O USUARIO E SUPERVISOR
	//SE FOR SUPERVISOR MARCO FLAG DE SUPERVISOR
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	_cVended:=''
	_lSup:=.F.

	DBSELECTAREA("SA3")
	DBSETORDER(2)             //FILIAL+NOME
	IF DBSEEK(xFilial("SA3")+ALLTRIM(CUSERNAME),.T.)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³VENDEDOR                                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_cVended:=A3_COD
		
		bBloco := {|lEnd| impV()}
		MsAguarde(bBloco,"Aguarde, Gerando Relatorio","Processando...",.T.)
		DBCLOSEAREA("VEND")                     //FECHANDO AREA
		DBSELECTAREA("SUP")                     //VOLTANDO PARA AREA ANTERIOR
		bBloco := {|lEnd| REDES()}
		MsAguarde(bBloco,"Aguarde, Gerando Relatorio","Processando...",.T.)
		
		DBCLOSEAREA("VEND")
		
	ELSE
		DBSELECTAREA("SZR")
		DBSETORDER(2)          //FILIAL + NOME
		IF DBSEEK(xFilial("SZR")+ALLTRIM(CUSERNAME),.T.)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SUPERVISOR                                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_cSup:=ZR_CODIGO
			_lSup:=.T.
			
			/*SELECIONO APENAS OS VENDEDORES DESSE SUPERVISOR*/
			
			cQuery1:="SELECT A3_COD FROM "+RETSQLNAME("SA3")+" WHERE A3_CODSUP='"+_cSup+"'  ORDER BY A3_COD"
			TCQUERY cQuery1 new alias "SUP"
			
			dbSelectArea ("SUP")
			DBGOTOP()
			WHILE !EOF()

				_cVended   :=SUP->A3_COD       //Vendedor Final
				bBloco := {|lEnd| impV()}
				MsAguarde(bBloco,"Aguarde, Gerando Relatorio","Processando...",.T.)
				DBCLOSEAREA("VEND")                     //FECHANDO AREA
				DBSELECTAREA("SUP")                     //VOLTANDO PARA AREA ANTERIOR

				bBloco := {|lEnd| REDES()}
				MsAguarde(bBloco,"Aguarde, Gerando Relatorio","Processando...",.T.)
				DBCLOSEAREA("VEND")                     //FECHANDO AREA
				DBSELECTAREA("SUP")                     //VOLTANDO PARA AREA ANTERIOR

				//Limpo o Arquivo Temporario

				/*
				dbSelectArea("TEMP")
				DBSETORDER(1)
				Zap
				INDEX ON Tiporel + Codcli + Lojcli  TO cIndex1
				*/

				TEMP->( dbCloseArea() )

				fErase(_cNom)

				If File(cIndice1+OrdBagExt())
					fErase(cIndice1+OrdBagExt())
				EndIf

				If File(cIndice2+OrdBagExt())
					fErase(cIndice2+OrdBagExt())
				EndIf

				If File(cIndice3+OrdBagExt())
					fErase(cIndice3+OrdBagExt())
				EndIf

				//Criar tabela temporária
				_cNom:=CriaTrab(IMPCLI, .T.)

				//Definir indices da tabela	
				cIndice1 := Alltrim(CriaTrab(,.F.))
				cIndice2 := Alltrim(CriaTrab(,.F.))
				cIndice3 := Alltrim(CriaTrab(,.F.))

				cIndice1 := Left(cIndice1,5)+Right(cIndice1,2)+"A"
				cIndice2 := Left(cIndice2,5)+Right(cIndice2,2)+"B"
				cIndice3 := Left(cIndice3,5)+Right(cIndice3,2)+"C"

				If File(cIndice1+OrdBagExt())
					FErase(cIndice1+OrdBagExt())
				EndIf

				If File(cIndice2+OrdBagExt())
					FErase(cIndice2+OrdBagExt())
				EndIf

				If File(cIndice3+OrdBagExt())
					FErase(cIndice3+OrdBagExt())
				EndIf

				//Criar e abrir a tabela
				dbUseArea(.T.,,_cNom,"TEMP",Nil,.F.)
				
				/*Criar indice*/
				IndRegua("TEMP", cIndice1, "Tiporel+Codcli+Lojcli"	,,, "Indice 1...")
				IndRegua("TEMP", cIndice2, "CodRed+CodCli+LojCli","D",, "Indice 2...")
				IndRegua("TEMP", cIndice3, "STR(OrderFat,14,3)","D",, "Indice 3...")

				dbClearIndex()
				
				dbSetIndex(cIndice1+OrdBagExt())
				dbSetIndex(cIndice2+OrdBagExt())
				dbSetIndex(cIndice3+OrdBagExt())

				TEMP->( dbSetOrder(1) )
				//

				DBSELECTAREA("SUP")                     //VOLTANDO PARA AREA ANTERIOR
				DBSKIP()
			ENDDO
		ELSE
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SE NAO FOR VENDEDOR OU SUPERVISOR                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			// _cCodSup1   //Supervisor Inicial
			// _cCodSup2   //Supervisor Final
			
			//  _cCodVen1   //Vendedor Inicial
			//  _cCodVen2   //Vendedor Final
			cQuery1:= "SELECT A3_CODSUP,A3_COD FROM "+RETSQLNAME("SA3")
			If !Empty(_cCodVen2)
				cQuery1+=" WHERE (A3_COD >= '"+ _cCodVen1 +"' AND A3_COD <='"+ _cCodVen2 +"') "
			ENDIF
			If !Empty(_cCodSup2)
				cQuery1+=" AND ( A3_CODSUP >= '"+ _cCodSup1 +"' AND A3_CODSUP <='"+ _cCodSup2 +"') "
			Endif
			cQuery1+= " ORDER BY A3_CODSUP,A3_COD "
			TCQUERY cQuery1 new alias "SUP"
			dbSelectArea ("SUP")
			DBGOTOP()
			WHILE !EOF()
				_cVended   :=SUP->A3_COD       //Vendedor Final
				bBloco := {|lEnd| impV()}
				MsAguarde(bBloco,"Aguarde, Gerando Relatorio","Processando...",.T.)
				DBCLOSEAREA("VEND")                     //FECHANDO AREA
				DBSELECTAREA("SUP")                     //VOLTANDO PARA AREA ANTERIOR

				//Limpo o Arquivo Temporario
				/*
				dbSelectArea("TEMP")
				DBSETORDER(1)
				Zap
				INDEX ON Tiporel + Codcli + Lojcli  TO cIndex1
				*/

				TEMP->( dbCloseArea() )

				fErase(_cNom)

				If File(cIndice1+OrdBagExt())
					fErase(cIndice1+OrdBagExt())
				EndIf

				If File(cIndice2+OrdBagExt())
					fErase(cIndice2+OrdBagExt())
				EndIf

				If File(cIndice3+OrdBagExt())
					fErase(cIndice3+OrdBagExt())
				EndIf

				//Criar tabela temporária
				_cNom:=CriaTrab(IMPCLI, .T.)

				//Definir indices da tabela	
				cIndice1 := Alltrim(CriaTrab(,.F.))
				cIndice2 := Alltrim(CriaTrab(,.F.))
				cIndice3 := Alltrim(CriaTrab(,.F.))

				cIndice1 := Left(cIndice1,5)+Right(cIndice1,2)+"A"
				cIndice2 := Left(cIndice2,5)+Right(cIndice2,2)+"B"
				cIndice3 := Left(cIndice3,5)+Right(cIndice3,2)+"C"

				If File(cIndice1+OrdBagExt())
					FErase(cIndice1+OrdBagExt())
				EndIf

				If File(cIndice2+OrdBagExt())
					FErase(cIndice2+OrdBagExt())
				EndIf

				If File(cIndice3+OrdBagExt())
					FErase(cIndice3+OrdBagExt())
				EndIf

				//Criar e abrir a tabela
				dbUseArea(.T.,,_cNom,"TEMP",Nil,.F.)
				
				/*Criar indice*/
				IndRegua("TEMP", cIndice1, "Tiporel+Codcli+Lojcli"	,,, "Indice 1...")
				IndRegua("TEMP", cIndice2, "CodRed+CodCli+LojCli","D",, "Indice 2...")
				IndRegua("TEMP", cIndice3, "STR(OrderFat,14,3)","D",, "Indice 3...")

				dbClearIndex()
				
				dbSetIndex(cIndice1+OrdBagExt())
				dbSetIndex(cIndice2+OrdBagExt())
				dbSetIndex(cIndice3+OrdBagExt())

				TEMP->( dbSetOrder(1) )
				//

				//
				bBloco := {|lEnd| REDES()}
				MsAguarde(bBloco,"Aguarde, Gerando Relatorio","Processando...",.T.)
				DBSELECTAREA("VEND")                     //VOLTANDO PARA AREA ANTERIOR
				DBCLOSEAREA("VEND")                     //FECHANDO AREA

				//Limpo o Arquivo Temporario
				dbSelectArea("TEMP")
				
				/*
				DBSETORDER(1)
				Zap
				INDEX ON Tiporel + Codcli + Lojcli  TO cIndex1
				*/
				
								TEMP->( dbCloseArea() )

				fErase(_cNom)

				If File(cIndice1+OrdBagExt())
					fErase(cIndice1+OrdBagExt())
				EndIf

				If File(cIndice2+OrdBagExt())
					fErase(cIndice2+OrdBagExt())
				EndIf

				If File(cIndice3+OrdBagExt())
					fErase(cIndice3+OrdBagExt())
				EndIf

				//Criar tabela temporária
				_cNom:=CriaTrab(IMPCLI, .T.)

				//Definir indices da tabela	
				cIndice1 := Alltrim(CriaTrab(,.F.))
				cIndice2 := Alltrim(CriaTrab(,.F.))
				cIndice3 := Alltrim(CriaTrab(,.F.))

				cIndice1 := Left(cIndice1,5)+Right(cIndice1,2)+"A"
				cIndice2 := Left(cIndice2,5)+Right(cIndice2,2)+"B"
				cIndice3 := Left(cIndice3,5)+Right(cIndice3,2)+"C"

				If File(cIndice1+OrdBagExt())
					FErase(cIndice1+OrdBagExt())
				EndIf

				If File(cIndice2+OrdBagExt())
					FErase(cIndice2+OrdBagExt())
				EndIf

				If File(cIndice3+OrdBagExt())
					FErase(cIndice3+OrdBagExt())
				EndIf

				//Criar e abrir a tabela
				dbUseArea(.T.,,_cNom,"TEMP",Nil,.F.)
				
				/*Criar indice*/
				IndRegua("TEMP", cIndice1, "Tiporel+Codcli+Lojcli"	,,, "Indice 1...")
				IndRegua("TEMP", cIndice2, "CodRed+CodCli+LojCli","D",, "Indice 2...")
				IndRegua("TEMP", cIndice3, "STR(OrderFat,14,3)","D",, "Indice 3...")

				dbClearIndex()
				
				dbSetIndex(cIndice1+OrdBagExt())
				dbSetIndex(cIndice2+OrdBagExt())
				dbSetIndex(cIndice3+OrdBagExt())

				TEMP->( dbSetOrder(1) )
				//

				//
				DBSELECTAREA("SUP")                     //VOLTANDO PARA AREA ANTERIOR
				DBSKIP()
			ENDDO
		ENDIF
	ENDIF
	DBSELECTAREA("SUP")                     //VOLTANDO PARA AREA ANTERIOR
	DBCLOSEAREA("SUP")                     //FECHANDO AREA
	dbSelectArea("TEMP")

	//COPIA PARA ARQUIVO
	//dbselectarea("TEMP")
	//dbgotop()
	//_cArq:= "TMP"+DTOS(DDATABASE)+".DBF"
	//COPY  TO &(_cArq)
	//fErase(_cNom+'.*')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³TOTALIZANDO RELATORIO                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//
	//
	//1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//         10        20        30        40        50        60        70        80        90        100       110       120

	nlin:=60
	IF (_nFatGG +  _nQtdeGG) > 0
		nlin++
		@ nLin,01 PSAY "|------------------------------------------------------------|--------------|-----------|----------------|"
		nLin++
		@ nLin,01 PSAY  "|                 <<<TOTAL GERAL>>>        |"
		@ nLin,62 PSAY  " |" + TRANSFORM(_nFatGG,"@E 99,999,999.99")
		@ nLin,89  PSAY  " |"
		@ nLin,90  PSAY  TRANSFORM(_nQtdeGG,"@E 99,999,999.99")
		@ nLin,106 PSAY  "|"
		nlin++
		@ nLin,01 PSAY "|------------------------------------------------------------|--------------|-----------|----------------|"
	Endif

	DBCLOSEAREA("DEV1")
	DBCLOSEAREA("VEND")
	DBCLOSEAREA("SA3")
	DBCLOSEAREA("SZR")
	DBCLOSEAREA("SUP")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 26/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static function ImpV ()  //IMPRIME RELATORIO

	/*VARIAVEIS*/
	PRIVATE nLin := 85
	PRIVATE _nPer:=0
	Private _nDesc:=0
	Public _FLiq:=0

	D1tot:=0 		//total DEVOLUCAO
	D1Qtd:=0    	//quantidade DEVOLUCAO

	/*PROCURO O NNOME DO VENDEDOR EM QUE ESTOU*/
	DBSELECTAREA("SA3")
	DBSETORDER(1)
	IF DBSEEK(xFilial("SA3")+_cVended,.T.)
		_cVNome:=SA3->A3_NOME   //NOME DO VENDEDOR
	Else
		_cVNome:="::"
	EndIf
	DBCLOSEAREA("SA3")

	cQuery:=" SELECT A1_REDE,A1_COD,A1_LOJA, A1_NOME,A1_VEND,A1_DESC,D2_TOTAL,D2_VALDEV, D2_TP ,"
	cQuery+=" D2_QUANT,D2_QTDEDEV,D2_TIPO, D2_TES, D2_CLIENTE,D2_COD,D2_EMISSAO,D2_SERIE , D2_DOC "
	cQuery+=" FROM "+retsqlname("SA1")+" A,"+retsqlname("SD2")+" B,"+retsqlname("SF2")+" C "
	cQuery+=" WHERE A1_COD = D2_CLIENTE "
	cQuery+=" AND D2_FILIAL='"+xFilial("SD2")+"' "
	cQuery+=" AND F2_CLIENTE = D2_CLIENTE "
	cQuery+=" AND F2_DOC     = D2_DOC  "
	cQuery+=" AND F2_SERIE   = D2_SERIE "

	cQuery+=" AND F2_LOJA=A1_LOJA "
	cQuery+=" AND D2_LOJA=A1_LOJA "
	cQuery+=" AND A1_COD=D2_CLIENTE "
	cQuery+=" AND A1_COD=F2_CLIENTE "

	cQuery+= "AND D2_TES NOT IN " + cRetTES + "  " 
	//cQuery += "AND D2_CLIENTE = '007002' "	&& Testes

	cQuery+=" AND F2_VEND1 ='"+_cVended+"' "

	cQuery+=" AND (D2_EMISSAO BETWEEN '"+ dtos(mv_par01) +"' AND  '"+dtos(mv_par02) +"') "
	cQuery+=" AND A.D_E_L_E_T_='' "
	cQuery+=" AND B.D_E_L_E_T_='' "
	cQuery+=" ORDER BY A1_REDE,A1_COD,A1_LOJA "
	TCQUERY cQuery new alias "VEND"
	dbSelectArea ("VEND")
	DBGOTOP()

	_TfLiq := 0
	_TnQtd := 0
	_cCliDev:= ''
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³SOMANDO OS TOTAIS PARA CALCULAR O PERCENTUAL                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	WHILE !EOF()
		
		MSproctxt("PROCESSANDO CLIENTE: " + VEND->A1_COD+" LOJA: "+VEND->A1_LOJA)//EXIBE MENSSAGEN NA TELA
		_cFatura := VEND->D2_TES $ _nGTes
		
		IF (VEND->D2_TIPO $ _nGNf) .OR. !_cFatura
			dbSkip()
			Loop
		ENDIF
		// se nao for produto acabado desconsidera
		If VEND->D2_TP != "PA"
			dbskip()
			Loop
		Endif
		
		_DesFi := (VEND->D2_TOTAL)*(VEND->A1_DESC/100)    //DESCONTO FINANCEIRO
		_loja  := VEND->A1_LOJA       						//LOJA DO CLIENTE
		_cDcli := VEND->D2_CLIENTE   						//CODIGO DO CLIENTE
		D1tot := 0   										//TOTAL DEVOLVIDO - FATURADO
		D1Qtd := 0  										//TOTAL DEVLOVIVO - QUANTIDADE
		If _cCliDev <> _cDcli
			GetDev()
			DBSELECTAREA("DEV1")
			WHILE !EOF()
				If (DEV1->F1_LOJA = _loja)  .AND.  (DEV1->F1_FORNECE  =  _cDcli )
					D1tot+=DEV1->D1_TOTAL 					//TOTAL DEVOLVIDO - FATURADO
					D1Qtd+=DEV1->D1_QUANT 					//TOTAL DEVLOVIVO - QUANTIDADE
				ENDIF
				DBSKIP()
			ENDDO
			_cCliDev := VEND->D2_CLIENTE   					//CODIGO DO CLIENTE
			DBCLOSEAREA("DEV1")
		Endif
		DBSELECTAREA("VEND")
		
		// Subtrai as devoluções
		If D1tot <> 0
			_nFatu := VEND->D2_TOTAL - D1tot   				//ACUMULANDO VALOR REAL - DEVOLUÇÃO
			_FLiq  := VEND->D2_TOTAL - D1tot   				//ACUMULANDO VALOR REAL - DEVOLUÇÃO
		Else
			_nFatu := VEND->D2_TOTAL-_DesFi
			_FLiq  := VEND->D2_TOTAL-_DesFi
		Endif
		_TfLiq := _TfLiq + _FLiq                  //ACUMULANDO VALOR REAL PARA CALC. PERCENTUAL
		_TnQtd := _TnQtd + (VEND->D2_QUANT - D1Qtd)  //QUANTIDADE PARA CALCULAR O PERCENTUAL
		DBSKIP()
	ENDDO

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³PROCESSANDO CLIENTES³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cCliDev := ''
	DBSELECTAREA("VEND")
	DBGOTOP()
	Do While !EOF()
		
		Msproctxt("PROCESSANDO CLIENTE: " + VEND->A1_COD+" LOJA: "+VEND->A1_LOJA+" - ")//EXIBE MENSSAGEN NA TELA
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o faturmento esta dentro dos TES validos                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_cFatura := VEND->D2_TES $ _nGTes
		
		IF (VEND->D2_TIPO $ _nGNf) .OR. !_cFatura
			dbSkip()
			Loop
		ENDIF
		// se nao for produto acabado desconsidera
		If VEND->D2_TP != "PA"
			dbskip()
			Loop
		Endif
		
		_loja   := VEND->A1_LOJA       //LOJA DO CLIENTE
		_cVend  := VEND->A1_VEND   		//CODIGO DO VENDEDOR
		_cCcod  := VEND->A1_COD    		//CODIGO DO CLIENTE
		_cCNome := VEND->A1_NOME   		//NOME DEO CLIENTE
		_cDcli  := VEND->D2_CLIENTE   	//CODIGO DO CLIENTE
		_cDemis := VEND->D2_EMISSAO 	//DATA DE EMISSAO
		_cDCod  := VEND->D2_COD  		//CODIGO PRODUTO
		_nAdesc := VEND->A1_DESC  		//DESCONTO FINANCEIRO
		_Rede   := VEND->A1_REDE      	//REDE
		
		/*VERIFICA SE E REDE*/
		_nRede := 0
		_qRede := 0
		_nFrd  := 0
		_nRdqt := 0
		_rMarca:="  "
		IF !EMPTY(_Rede)
			_LRede:=.T.
			DBSELECTAREA("SA1")
			DBSETORDER(1)
			IF DBSEEK(xFilial("SA1")+_Rede,.T.)
				_rMarca := "* "
				_RDNOME :=A1_NOME
				_RDCOD :=A1_COD
			ENDIF
			DBSELECTAREA("VEND")
			_cCliDev := ''
			/*ENQUANTO ESTIVER NA MESMA REDE*/
			WHILE (VEND->A1_REDE=_REDE)
				_nRede := VEND->D2_TOTAL
				_qRede := VEND->D2_QUANT
				_loja  := VEND->A1_LOJA       //LOJA DO CLIENTE
				_cDcli := VEND->D2_CLIENTE   //CODIGO DO CLIENTE
				/*VERIFICO SE QUEBROU CLIENTE
				VERIFICO AS DEVOLUCOES DESSE CLIENTE*/
				_rdft  := 0  //DEVOLUCAO FATURADO
				_rdqt  := 0  //DEVOLUCAO QUANTIDADE
				If _cCliDev <> _cDcli
					GetDev()
					DBSELECTAREA("DEV1")
					WHILE !EOF()
						If (DEV1->F1_LOJA = _loja)  .AND.  (DEV1->F1_FORNECE  =  _cDcli )
							MSPROCTXT("DEVOLUCAO, CLIENTE: "+DEV1->F1_LOJA+" "+DEV1->F1_FORNECE)
							_rdft+=DEV1->D1_TOTAL //DEVOLUCAO FATURADO
							_rdqt+=DEV1->D1_QUANT //DEVOLUCAO QUANTIDADE
						Endif
						DBSKIP()
					ENDDO
					DBCLOSEAREA("DEV1")
					_cCliDev := VEND->D2_CLIENTE   //CODIGO DO CLIENTE
				Endif
				DBSELECTAREA("VEND")
				/*APLICO AS DEVOLUCOES*/
				_nFrd  := _nFrd  + (_nRede - _rdft)
				_nRdqt := _nRdqt + (_qRede - _rdqt)
				Dbskip()
			ENDDO
			// Aplico desconto da rede
			If _nAdesc > 0
				_nFrd = _nFrd - (_nFrd*(_nAdesc/100))
			ENDIF
			// Total do Vendedor para calcular o %
			If _TnQtd > 0
				//		_nPer:=_nFrd/_TfLiq*100
				//			_nPer:=_nFrd/_TnQtd*100
			Else
				_nPer:= 0
			Endif
			
			
			//Gravo arquivo de Trabalho
			_TipRel := 'R'
			dbSelectArea("TEMP")
			IF !dbSeek(_TipRel + _rMarca + _Rede + _loja)
				RecLock("TEMP",.T.)
				TEMP->TipoRel 		:=	_TipRel     	    //TIPO RELATORIO CLINTES / REDES
				TEMP->CodCli 		:=	_rMarca+_Rede  	    //TIPO RELATORIO CLINTES / REDES
				TEMP->LojCli		:=	_loja       	//CODIGO CLIENTE
				TEMP->NomCli 		:=	_cCNome        	//LOJA CLIENTE
				TEMP->CodVen    :=  _cVend         	//CODIGO VENDEDOR
				TEMP->ValFat      :=	_nFrd           //VALOR DO FATURAMENTO
				TEMP->ValDev 		:=	_rdft       	//VALOR DA DEVOLUÇÃO
				TEMP->QtdFat 		:=	_nRdqt  		//QUANTIDADE FATURADA
				TEMP->QtdDev 		:=	_rdqt   	 	//QUANTIDADE DEVOLVIDA
				TEMP->DesFin      := 	_nAdesc   //DESCONTO FINANCEIRO
				If _TfLiq > 0  .and.  TEMP->ValFat > 0
					TEMP->PercFat 		:=	TEMP->ValFat/_TfLiq*100        	//PERCENTUAL EM RELAÇÃO AO FATURAMENTO
				Else
					TEMP->PercFat 		:=	0                            	//PERCENTUAL EM RELAÇÃO AO FATURAMENTO
				Endif
				TEMP->OrderFat      :=  (TEMP->ValFat-TEMP->ValDev)*-1 //(_nFrd-_rdqt)*-1  //FORÇO INVERTER O VALOR PARA CRIAR ORDEM DESCRECENTE
			Else
				RecLock("TEMP",.F.)
				TEMP->ValFat   	:=	TEMP->ValFat + _nFrd           //VALOR DO FATURAMENTO
				TEMP->ValDev 		:=	TEMP->ValDev + _rdft       	//VALOR DA DEVOLUÇÃO
				TEMP->QtdFat 		:=	TEMP->QtdFat + _nRdqt  		//QUANTIDADE FATURADA
				TEMP->QtdDev 		:=	TEMP->QtdDev + _rdqt   	 	//QUANTIDADE DEVOLVIDA
				TEMP->DesFin        := 	_nAdesc   //DESCONTO FINANCEIRO
				If _TfLiq > 0 .and.	TEMP->ValFat > 0
					TEMP->PercFat 		:=	TEMP->ValFat/_TfLiq*100        	//PERCENTUAL EM RELAÇÃO AO FATURAMENTO
				Else
					TEMP->PercFat 	:=	 0         	//PERCENTUAL EM RELAÇÃO AO FATURAMENTO
				Endif
				TEMP->OrderFat      :=  (TEMP->ValFat-TEMP->ValDev)*-1  //FORÇO INVERTER O VALOR PARA CRIAR ORDEM DESCRECENTE
			Endif
			DBSELECTAREA("VEND")                     //VOLTANDO PARA AREA ANTERIOR
			/*
			//Imprime a somatoria da rede
			If (_nFrd + _nRdqt) <> 0
			@ nLin,01  PSAY  "|* "+_RDCOD + " " + SUBSTR(_RDNOME,1,40)
			@ nLin,62  PSAY  "|" + TRANSFORM(_nFrd  ,"@E 99,999,999.99")
			@ nLin,77  PSAY  "|"
			@ nLin,78  PSAY  TRANSFORM(_nPer,"@E 9999.99")+" %"
			@ nLin,89  PSAY  "|"
			@ nLin,90  PSAY  TRANSFORM(_nRdqt,"@E 99,999,999.99")
			@ nLin,106 PSAY  "|"
			NLIN++
			Endif
			*/
			_nFatG  := _nFatG  + _nFrd
			_nQtdeG := _nQtdeG + _nRdqt
			_nFrd  := 0
			_nPer  := 0
			_nRdqt := 0
		ELSE
			DbSelectArea("VEND")
			/*ENQUANTO ESTIVER NO MESMO CLIENTE*/
			// Se For Analitico forço passar no loop
			WHILE (VEND->D2_CLIENTE =_cDcli .AND. VEND->A1_LOJA = _loja)
				_nQtd    := VEND->D2_QUANT  //QUANTIDADE
				_nVlr     := VEND->D2_TOTAL  //TOTAL DA NOTA
				_cDoc   := VEND->D2_DOC    //DOCUMENTO
				_cCcod  := VEND->A1_COD    		//CODIGO DO CLIENTE
				_loja      := VEND->A1_LOJA       						//LOJA DO CLIENTE
				_dft := 0     // DEVOLUCAO FATURADO
				_dqt := 0     // DEVOLUCAO QUANTIDADE
				IF _cCliDev<>_cDcli
					/*CALCULO AS DEVOLUCOES DESSE CLIENTE*/
					// DBSELECTAREA("DEV1")
					//SET FILTER TO (DEV1->F1_LOJA = loja)  .AND.  (DEV1->F1_FORNECE  =  _cDcli )
					//Dbgotop()
					GetDev()
					WHILE !EOF()
						If (DEV1->F1_LOJA = _loja)  .AND.  (DEV1->F1_FORNECE  =  _cDcli )
							//MSPROCTXT("DEVOLUCAO, CLIENTE: "+DEV1->F1_LOJA+" "+DEV1->F1_FORNECE)
							_dft+=DEV1->D1_TOTAL //DEVOLUCAO FATURADO
							_dqt+=DEV1->D1_QUANT //DEVOLUCAO QUANTIDADE
						Endif
						DBSKIP()
					ENDDO
					DBCLOSEAREA("DEV1")
					_cCliDev :=  VEND->D2_CLIENTE    //CODIGO DO CLIENTE
				Endif
				DBSELECTAREA("VEND")
				_nFat  := _nFat  + (_nVlr  - _dft)      //FATURADO
				_nQtde := _nQtde + (_nQtd  - _dqt)      //PESO
				If _TnQtd > 0
					//			_TfLiq
					//			_nPer  := _nFat / _TfLiq * 100
					//				_nPer  := _nQtde / _TnQtd * 100
				Else
					_nPer  := 0
				Endif
				DBSKIP()
				
				//Imprimir cliente a Cliente
				
				//	 _cTipoRel := 1
				If _cTipoRel = 1
					_cCNome:= _cCNome+" "+_cDoc
					// Forço não entrar no Loop
					_TipRel := _cDoc
				Else
					_TipRel := 'C-----'
				Endif
				
				//Gravo arquivo de Trabalho
				dbSelectArea("TEMP")
				IF !dbSeek(_TipRel +_rMarca +_cCcod + _loja)
					RecLock("TEMP",.T.)
					TEMP->TipoRel 		:=	_TipRel     	//TIPO RELATORIO CLINTES / REDES
					TEMP->CodCli 		:=	_rMarca + _cCcod//TIPO RELATORIO CLINTES / REDES
					TEMP->LojCli		:=	_loja       	//CODIGO CLIENTE
					TEMP->NomCli 		:=	_cCNome        	//LOJA CLIENTE
					TEMP->CodVen     :=  _cVend         	//CODIGO VENDEDOR
					TEMP->ValFat       :=	_nVlr           //VALOR DO FATURAMENTO
					TEMP->ValDev 		:=	_dft        	//VALOR DA DEVOLUÇÃO
					TEMP->QtdFat 		:=	_nQtd   		//QUANTIDADE FATURADA
					TEMP->DesFin      := 	_nAdesc   		//DESCONTO FINANCEIRO
					TEMP->QtdDev 		:=	_dqt    	 	//QUANTIDADE DEVOLVIDA
					If _TfLiq > 0 .and.	TEMP->ValFat > 0
						TEMP->PercFat 	:=	TEMP->ValFat/ _TfLiq * 100        	//PERCENTUAL EM RELAÇÃO AO FATURAMENTO
					Else
						TEMP->PercFat 	:=	0
					Endif
					TEMP->OrderFat      :=  (TEMP->ValFat - TEMP->ValDev)*-1//(_nVlr - _dft )*-1  //FORÇO INVERTER O VALOR PARA CRIAR ORDEM DESCRECENTE
				Else
					RecLock("TEMP",.F.)
					TEMP->ValFat   	:=	TEMP->ValFat + _nVlr        //VALOR DO FATURAMENTO
					TEMP->ValDev 		:=	TEMP->ValDev + _dft       	//VALOR DA DEVOLUÇÃO
					TEMP->QtdFat 		:=	TEMP->QtdFat + _nQtd   		//QUANTIDADE FATURADA
					TEMP->QtdDev 		:=	TEMP->QtdDev + _dqt   	 	//QUANTIDADE DEVOLVIDA
					If _TfLiq > 0 .and.	TEMP->ValFat > 0
						TEMP->PercFat 	:=	TEMP->ValFat/ _TfLiq * 100        	//PERCENTUAL EM RELAÇÃO AO FATURAMENTO
					Else
						TEMP->PercFat 	:=	0
					Endif
					TEMP->OrderFat      :=  (TEMP->ValFat - TEMP->ValDev)*-1  //FORÇO INVERTER O VALOR PARA CRIAR ORDEM DESCRECENTE
				Endif
				/*ZERANDO VARIAVES DA DEVOLUCAO
				PARA NOVO CALCULO*/
				_dft:=0
				_dqt:=0
				DBSELECTAREA("VEND")                     //VOLTANDO PARA AREA ANTERIOR
				//Se relatorio é analitico forço sair do loop
				//Imprimir cliente a Cliente
				If _cTipoRel = 1
					Exit
				Endif
				
			Enddo
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cliente com total                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			/*
			IF (_nQtde + _nFat ) <> 0
			//IF _cTipoRel<>1       //ANALITICO
			//	@ nLin,01 PSAY "|------------------------------------------------------------|--------------|-----------|----------------|"
			//	NLIN++
			//ENDIF
			@ nLin,01  PSAY  "|  "+_cCcod + " " +SUBSTR(_cCNome,1,48)
			@ nLin,62  PSAY  "|"+ TRANSFORM(_nFat  ,"@E 99,999,999.99")
			@ nLin,77  PSAY  "|"
			@ nLin,78  PSAY  TRANSFORM(_nPer,"@E 9999.99")+" %"
			@ nLin,89  PSAY  "|"
			@ nLin,90  PSAY  TRANSFORM(_nQtde,"@E 99,999,999.99")
			@ nLin,106 PSAY  "|"
			nlin++
			/*
			/*TOTAL GERAL*/
			_nFatG  := _nFatG  + _nFat
			_nQtdeG := _nQtdeG + _nQtde
			/*ZERANDO SOMADORES PARA PROXIMO
			CLIENTE*/
			_nFat   :=0
			_nPer   :=0
			_nSpmedio :=0
			_nQtde  :=0
			//		ENDIF
			
		ENDIF
		_nFRd    :=0
		
	Enddo
	_TipCliRed = "C"



	// Imprime Arquivo de Trabalho
	Imp_rel()

Return

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 26/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
STATIC FUNCTION REDES()

	/*VARIAVEIS*/
	_REDE:=''
	nLin:=85
	_nPer:=0
	_RDNOME :='' //NOME DA REDE
	_RDCOD :=''    //CODIGO DA REDE
	_RDCGC :=''    //CGC
	_nFRd :=0     //TOTAL DA REDE
	cCod :='' //cODIGO DO CLIENETE
	_FATREDE:=0  //TOTAL DA REDE


	_nQtde   :=0 //ACUMULANDO QUANTIDADE REAL
	_nSpmedio:=0 //PRECO MEDIO TOTAL
	_nPer  :=0 //PORCENTAGEM DE FATURAMENTO

	PorcentFat:=0
	PesoTotal :=0
	FatuTotal :=0
	PesoMedTo :=0

	POGR:=0
	PEGR:=0
	FTGR:=0
	PMGR:=0

	TGPE:=0
	TGFT:=0
	TGPM:=0


	/*CONTENPLO SOMENTE AS REDES*/

	cQuery:=" SELECT A1_REDE,A1_COD,A1_LOJA, A1_NOME,A1_VEND,A1_DESC,D2_TOTAL,D2_VALDEV, D2_TP ,"
	cQuery+=" D2_QUANT,D2_QTDEDEV,D2_TIPO, D2_TES, D2_CLIENTE,D2_COD,D2_EMISSAO,D2_SERIE "
	cQuery+=" FROM "+retsqlname("SA1")+" A,"+retsqlname("SD2")+" B,"+retsqlname("SF2")+" C "
	cQuery+=" WHERE A1_COD = D2_CLIENTE "
	cQuery+=" AND D2_FILIAL='"+xFilial("SD2")+"' "
	cQuery+=" AND F2_CLIENTE = D2_CLIENTE "
	cQuery+=" AND F2_DOC     = D2_DOC  "
	cQuery+=" AND F2_SERIE   = D2_SERIE "

	cQuery+=" AND F2_LOJA=A1_LOJA "
	cQuery+=" AND D2_LOJA=A1_LOJA "
	cQuery+=" AND A1_COD=D2_CLIENTE "
	cQuery+=" AND A1_COD=F2_CLIENTE "

	//cQuery += "AND D2_CLIENTE = '007002' "	&& Testes
	cQuery+= "AND D2_TES NOT IN " + cRetTES + "  " 

	cQuery+=" AND F2_VEND1 ='"+_cVended+"' "

	cQuery+=" AND A1_REDE<>'' "
	cQuery+=" AND (D2_EMISSAO BETWEEN '"+ dtos(mv_par01) +"' AND  '"+dtos(mv_par02) +"') "
	cQuery+=" AND A.D_E_L_E_T_='' "
	cQuery+=" AND B.D_E_L_E_T_='' "
	cQuery+=" ORDER BY A1_REDE,A1_COD,A1_LOJA "
	TCQUERY cQuery new alias "VEND"


	dbSelectArea ("VEND")
	DBGOTOP()

	WHILE !EOF()
		Msproctxt("PROCESSANDO REDE: " + VEND->A1_REDE+" LOJA: "+VEND->A1_LOJA)//EXIBE MENSSAGEN NA TELA
		/*
		@ nLin,01 PSAY  "|------------------------------------------------------------|--------------|-----------|----------------|"
		nLin ++
		@ nLin,01 PSAY  "|                        Cliente                             | Faturamento  |   % Fat   |  Quantidade    |"
		nLin ++
		@ nLin,01 PSAY  "|------------------------------------------------------------|--------------|-----------|----------------|"
		//                                                                                                                 xxx,xxx,xxx.xx    xxxx.xx
		//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
		//0         1         2         3         4         5         6         7         8         9        10        11        12        13         14       15        16        17        18        19         20       21        22
		nLin ++
		Endif
		*/
		//SO SOMATISO AS REDES QUE ESTAO NO TES VALIDO E NA NOTA VALIDA
		_cFatura := VEND->D2_TES $ _nGTes
		IF (VEND->D2_TIPO $ _nGNf) .OR. !_cFatura
			dbSkip()
			Loop
		ENDIF
		// se nao for produto acabado desconsidera
		If VEND->D2_TP != "PA"
			dbskip()
			Loop
		Endif
		
		/*PROCURO A MATRIS*/
		DBSELECTAREA("SA1")
		DBSETORDER(1)
		IF DBSEEK(xFilial("SA1")+VEND->A1_REDE,.T.)
			_RDNOME:=A1_NOME
			_RDCOD :=A1_COD
		ENDIF
		DBSELECTAREA("VEND")
		_REDE := VEND->A1_REDE
		NOMER := VEND->A1_NOME
		FatLiq  := 0
		PesoFat := 0
		
		/*ENQUANTO ESTIVER NA MESMA REDE*/
		WHILE (VEND->A1_REDE = _REDE)
			
			cCod := VEND->A1_COD
			cloj := VEND->A1_LOJA
			Nome := VEND->A1_NOME
			Desconto := VEND->A1_DESC
			_cCliDev := ''
			/* ENQUANTO ESTIVER DENTRO DO MESMO CLIENTE */
			
			WHILE(VEND->A1_COD=cCod).AND.(cloj=VEND->A1_LOJA)
				// Se for a Matriz faço a marca
				If A1_REDE = A1_COD
					_rMarca:="* "
				Else
					_rMarca:="  "
				Endif
				Faturado := VEND->D2_TOTAL
				Peso     := VEND->D2_QUANT
				/*DEVOLUCOES*/
				_loja  := VEND->A1_LOJA       //LOJA DO CLIENTE
				_cDcli := VEND->D2_CLIENTE    //CODIGO DO CLIENTE
				_dft:=0
				_dqt:=0
				//*VERIFICO SE QUEBROU CLIENTE*//
				IF _cCliDev<>_cDcli
					//DBSELECTAREA("DEV1")
					//Dbgotop()
					GetDev()
					WHILE !EOF()
						If (DEV1->F1_LOJA = _loja)  .AND.  (DEV1->F1_FORNECE  =  _cDcli )
							MSPROCTXT("DEVOLUCAO, CLIENTE: "+DEV1->F1_LOJA+" "+DEV1->F1_FORNECE)
							_dft+=DEV1->D1_TOTAL //DEVOLUCAO FATURADO
							_dqt+=DEV1->D1_QUANT //DEVOLUCAO QUANTIDADE
						Endif
						_cCliDev := VEND->D2_CLIENTE   //CODIGO DO CLIENTE
						DBSKIP()
					ENDDO
					DBCLOSEAREA("DEV")
				Endif
				
				DBSELECTAREA("VEND")
				// Verifico se Devolução é total
				If _dft = Faturado
					Faturado := 0
					Peso  	 := 0
				Else
					Faturado := Faturado  - _dft
					Peso     := Peso -	_dqt
				EndIf
				FatLiq  := FatLiq  + Faturado
				PesoFat := PesoFat + Peso
				//			PorcentFat := FatLiq / _TfLiq * 100
				//PorcentFat := FatLiq / _TnQtd * 100
				DBSKIP()
			ENDDO
			//Desconto Finaceiro
			FatLiq := FatLiq - (FatLiq * Desconto / 100)
			//Gravo arquivo de Trabalho
			_TipRel := 'R'
			dbSelectArea("TEMP")
			DBSETORDER(1)
			IF !dbSeek(_TipRel + _rMarca + cCod + cloj)
				RecLock("TEMP",.T.)
				TEMP->TipoRel 		:=	_TipRel     	    //TIPO RELATORIO CLINTES / REDES
				TEMP->CodCli 		:=	_rMarca+cCod    	    //TIPO RELATORIO CLINTES / REDES
				TEMP->LojCli		:=	cloj       	//CODIGO CLIENTE
				TEMP->NomCli 		:=	Nome +" "+ _REDE   	//LOJA CLIENTE
				TEMP->CodVen        :=  _cVend         	//CODIGO VENDEDOR
				TEMP->CodRed        :=  _REDE    	//QUANTIDADE DEVOLVIDA
				TEMP->ValFat   		:=	FatLiq           //VALOR DO FATURAMENTO
				TEMP->ValDev 		:=	_dft        	//VALOR DA DEVOLUÇÃO
				TEMP->QtdFat 		:=	PesoFat    		//QUANTIDADE FATURADA
				TEMP->QtdDev 		:=	_dqt   	 	//QUANTIDADE DEVOLVIDA
				If _TfLiq > 0 .and.	TEMP->ValFat > 0
					TEMP->PercFat 		:=	TEMP->ValFat/ _TfLiq * 100    	//PERCENTUAL EM RELAÇÃO AO FATURAMENTO
				Else
					TEMP->PercFat 		:=	0
				Endif
				TEMP->OrderFat      :=  (TEMP->QtdFat-TEMP->QtdDev)*-1//(FatLiq)*-1  //FORÇO INVERTER O VALOR PARA CRIAR ORDEM DESCRECENTE
			Else
				RecLock("TEMP",.F.)
				TEMP->ValFat   		:=	TEMP->ValFat + FatLiq       //VALOR DO FATURAMENTO
				TEMP->ValDev 		:=	TEMP->ValDev + _dft       	//VALOR DA DEVOLUÇÃO
				TEMP->QtdFat 		:=	TEMP->QtdFat + PesoFat  		//QUANTIDADE FATURADA
				TEMP->QtdDev 		:=	TEMP->QtdDev + _dqt   	 	//QUANTIDADE DEVOLVIDA
				If _TfLiq > 0 .and.	TEMP->ValFat > 0
					TEMP->PercFat 		:=	TEMP->ValFat / _TfLiq * 100    	//PERCENTUAL EM RELAÇÃO AO FATURAMENTO
				Else
					TEMP->PercFat 		:=	0
				Endif
				//			TEMP->PercFat 		:=	TEMP->ValFat / _TnQtd * 100    	//PERCENTUAL EM RELAÇÃO AO FATURAMENTO
				TEMP->OrderFat      :=  (TEMP->QtdFat-TEMP->QtdDev)*-1  //FORÇO INVERTER O VALOR PARA CRIAR ORDEM DESCRECENTE
			Endif
			
			//*********************************
			DBSELECTAREA("VEND")                     //VOLTANDO PARA AREA ANTERIOR
			
			/*
			IF FatLiq  > 0
			@ nLin,01 PSAY "|  "+cCod + " " +SUBSTR(Nome,1,30)
			@ nLin,62 PSAY "|"+ TRANSFORM(FatLiq ,"@E 99,999,999.99")
			@nLin,77    PSAY "|"
			@nLin,78    PSAY TRANSFORM(PorcentFat,"@E 9999.99")+" %"
			@nLin,89    PSAY "|"
			@nLin,90    PSAY TRANSFORM(PesoFat ,"@E 99,999,999.999")
			@nLin,106   PSAY "|"
			nlin++
			*/
			PesoTotal := PesoTotal + PesoFat
			FatuTotal := FatuTotal + FatLiq
			//ENDIF
			FatLiq     := 0
			PesoFat    := 0
			If _TnQtd > 0
				PorcentFat := PesoTotal / _TnQtd * 100
			Else
				PorcentFat := 0
			Endif
			/*TOTAL GERAL DA REDE*/
			POGR:= PorcentFat
			PEGR:= PesoTotal
			FTGR:= FatuTotal
		ENDDO
		//********************************
		//Gravo Novamento o Total da Rede
		//*********************************
		//Gravo arquivo de Trabalho
		_TipRel := 'T'
		dbSelectArea("TEMP")
		IF !dbSeek(_TipRel + _REDE + cloj)
			RecLock("TEMP",.T.)
			TEMP->TipoRel 		:=	_TipRel     	    //TIPO RELATORIO CLINTES / REDES
			TEMP->CodCli 		:=	_REDE    	    //TIPO RELATORIO CLINTES / REDES
			TEMP->LojCli		:=	cloj       	//CODIGO CLIENTE
			TEMP->NomCli 		:=	_RDNOME + " Matriz"        	//LOJA CLIENTE
			TEMP->CodVen        :=  _cVend         	//CODIGO VENDEDOR
			TEMP->CodRed        :=  _REDE    	//QUANTIDADE DEVOLVIDA
			TEMP->ValFat   		:=	FatuTotal           //VALOR DO FATURAMENTO
			TEMP->QtdFat 		:=	PesoTotal    		//QUANTIDADE FATURADA
			If _TfLiq > 0 .and.	TEMP->ValFat > 0
				TEMP->PercFat 		:=	TEMP->ValFat / _TfLiq * 100    	//PERCENTUAL EM RELAÇÃO AO FATURAMENTO
			Else
				TEMP->PercFat 		:=	0
			Endif
			TEMP->OrderFat      :=  (TEMP->QtdFat-TEMP->QtdDev)*-1//(FatuTotal)*-1  //FORÇO INVERTER O VALOR PARA CRIAR ORDEM DESCRECENTE
		Else
			RecLock("TEMP",.F.)
			TEMP->ValFat   		:=	TEMP->ValFat + FatuTotal       //VALOR DO FATURAMENTO
			TEMP->QtdFat 		:=	TEMP->QtdFat + PesoTotal  		//QUANTIDADE FATURADA
			//_TfLiq
			If _TfLiq > 0 .and.	TEMP->ValFat > 0
				TEMP->PercFat 		:=	TEMP->ValFat / _TfLiq * 100    	//PERCENTUAL EM RELAÇÃO AO FATURAMENTO
			Else
				TEMP->PercFat 		:=	0
			Endif
			//		TEMP->PercFat 		:=	TEMP->ValFat / _TnQtd * 100    	//PERCENTUAL EM RELAÇÃO AO FATURAMENTO
			TEMP->OrderFat      :=  (TEMP->QtdFat-TEMP->QtdDev)*-1  //FORÇO INVERTER O VALOR PARA CRIAR ORDEM DESCRECENTE
		Endif
		/*
		IF FTGR > 0
		@ nLin,01  PSAY "|* "+ _REDE + " " + SUBSTR(_RDNOME,1,48)
		@ nLin,62  PSAY "|" + TRANSFORM(FTGR,"@E 99,999,999.99")
		@ nLin,77  PSAY "|"
		@ nLin,78  PSAY TRANSFORM(POGR,"@E 9999.99")+" %"
		@ nLin,89  PSAY "|"
		@ nLin,90  PSAY TRANSFORM(PEGR,"@E 99,999,999.999")
		@ nLin,106 PSAY "|"
		nlin++
		/*ZERANDO TOTAL GERAL DA REDE*/
		
		TGPE+=PEGR //PESO
		TGFT+=FTGR //FATURADO
		PorcentFat := 0
		PesoTotal  := 0
		FatuTotal  := 0
		
		//	ENDIF
		/*ZERANDO TOTAL GERAL DA REDE*/
		POGR :=0
		PEGR :=0
		FTGR :=0
	ENDDO
	_TipCliRed :=	"R"
	// Imprime Arquivo de Trabalho
	Imp_rel()


	/*
	IF (TGPE + TGFT) > 0
	If _TnQtd > 0
	POGR := TGFT / _TnQtd * 100
	Else
	POGR := 0
	Endif

	@ nLin,01 PSAY  "|------------------------------------------------------------|--------------|-----------|----------------|"
	nLin++
	@ nLin,01  PSAY "|                        <<<TOTAL DAS REDES>>>               "
	@ nLin,62  PSAY "|"+ TRANSFORM(TGFT,"@E 99,999,999.99")
	@ nLin,78  PSAY TRANSFORM(POGR,"@E 9999.99")+" %"
	@ nLin,89  PSAY "|"
	@ nLin,90  PSAY TRANSFORM(TGPE,"@E 99,999,999.99")
	@ nLin,106 PSAY "|"
	nLin ++
	@ nLin,01 PSAY   "|------------------------------------------------------------|--------------|-----------|----------------|"
	nLin++
	ENDIF
	*/

RETURN

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 26/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static function GetDev()//Gera select DEV1 com Parametros

	Local cQuery := ""

	&& Modificado HCCONSYS em 09/01/09
	cQuery := " SELECT D1_TOTAL,D1_QUANT,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA   "
	cQuery += "FROM " + RETSQLNAME("SF1") + " SF1 , " + RETSQLNAME("SD1") + " SD1  " 
	cQuery += "WHERE    "
	cQuery += "    SF1.F1_FILIAL = '" + XFILIAL("SF1") +"' AND SF1.D_E_L_E_T_ = ' ' " 
	cQuery += "AND SD1.D1_FILIAL = '" + XFILIAL("SD1") +"' AND SD1.D_E_L_E_T_ = ' ' " 
	cQuery += "AND SD1.D1_DOC		= SF1.F1_DOC  "
	cQuery += "AND SD1.D1_SERIE	= SF1.F1_SERIE "
	cQuery += "AND SD1.D1_FORNECE	= SF1.F1_FORNECE "
	cQuery += "AND SD1.D1_LOJA		= SF1.F1_LOJA "
	cQuery += "AND (F1_EMISSAO BETWEEN '" 	+ DTOS(MV_PAR01) 	+ "' AND  '" + DTOS(MV_PAR02) + "') "
	cQuery += "AND F1_FORNECE		='" 		+_cDcli				+"' "
	cQuery += "AND F1_LOJA			='"		+_loja				+"' "
	cQuery += "AND SD1.D1_TIPO='D'  "
	cQuery += "ORDER BY SF1.F1_LOJA,SF1.F1_FORNECE "
	&& Modificado HCCONSYS em 09/01/09

	/* Query && Desabilitado por HCCONSYS em 09/01/09
	cQuery:=" SELECT D1_TOTAL,D1_QUANT,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA  "
	//cQuery+=" FROM SF1010,SD1010  "
	cQuery+=" WHERE   "
	cQuery+=" (F1_EMISSAO BETWEEN '"+ dtos(mv_par01) +"' AND  '"+dtos(mv_par02) +"') "
	cQuery+=" AND F1_FORNECE='"+_cDcli+"' "
	cQuery+=" AND F1_LOJA='"+_loja+"' "
	cQuery+=" AND D1_TIPO='D' "
	cQuery+=" AND D1_DOC=F1_DOC "
	cQuery+=" AND F1_SERIE=D1_SERIE "
	cQuery+=" ORDER BY F1_LOJA,F1_FORNECE "
	*/

	TCQUERY cQuery New Alias "DEV1"       

	DbSelectArea("DEV1")
	DEV1->(DbGoTop())

Return()

//********************************
// Função Imprimir Relatório
//********************************
STATIC FUNCTION Imp_rel()

	//faco a vetorizacao do relatorio
	Private  _aZr:={}   //vetor zero
	Private  _aFull:={} //vetor full
	Private  _aRds:={}  //vetor redes
	Private  _lZr:=.F.  //condicao zero

	//ordenando Arq de trabalho
	dbSelectArea("TEMP")

	_nFatG  := 0
	_nQtdeG := 0
	_cRed_old  :=  ''                     	//CODIGO REDE

	If _TipCliRed = 'R'
		//INDEX ON CodRed+CodCli+LojCli  TO INDTRAB DESC
		TEMP->( dbSetOrder(2) ) // CODRED+CODCLI+LOJCLI
	Else
		//INDEX ON STR(OrderFat,14,3)  TO INDTRAB DESC
		TEMP->( dbSetOrder(3) ) // ORDERFAT
	Endif
	
	//SET INDEX TO INDTRAB
	//SET ORDER TO cIndex2
	
	Dbgotop()
	If !eof()
		
		Do While !eof()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impressao do cabecalho do relatorio se ultrapassar o limite das linhas ou quebrar vendedor ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			If (nLin > 65)
				
				/************cabec padrao*********************/
				titulo       := "Relatorio de Vendas "
				Cabec1       := "Faturamento Por Regiao"
				nomeprog     := "AD0085"
				nTipo        := 15
				/**********************************************/
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				
				nLin := 10
				If _TipCliRed = 'R'
					_cRedes := "CONTROLE DE REDES"
				Else
					_cRedes := ""
				Endif
				@ nLin,01 PSAY  "Nome da Regiao: " +_cVend + " " + "-"  + " " + _cVNome+"          "+_cRedes
				nLin ++
				@ nLin,01 PSAY  "|------------------------------------------------------------|--------------|-----------|----------------|"
				nLin ++
				@ nLin,01 PSAY  "|                        Cliente                             | Faturamento  |   % Fat   |  Quantidade    |"
				nLin ++
				@ nLin,01 PSAY  "|------------------------------------------------------------|--------------|-----------|----------------|"
				nLin ++
				//                                                                                                                 xxx,xxx,xxx.xx    xxxx.xx
				//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
				//0         1         2         3         4         5         6         7         8         9        10        11        12        13         14       15        16        17        18        19         20       21        22
			Endif
			
			//If TEMP->TipoRel 	== _TipCliRed	        //TIPO RELATORIO CLINTES / REDES
			_cCcod     := TEMP->CodCli 			    	//TIPO RELATORIO CLINTES / REDES
			_loja         :=	TEMP->LojCli		         	//CODIGO CLIENTE
			_cCodRed := TEMP->CodRed                   	//CODIGO REDE
			_cCNome :=	TEMP->NomCli 		        	//LOJA CLIENTE
			_nFat       :=	TEMP->ValFat -  TEMP->ValDev   //VALOR DO FATURAMENTO
			_nQtde     :=	TEMP->QtdFat -  TEMP->QtdDev
			If _nFat > 0
				_nPer  :=   TEMP->PercFat
			Else
				_nPer  :=   0
			Endif
			
			// Se for Rede
			// Quando trocar o código da Rede pulo um linha
			If  TEMP->TipoRel = "T"                    	//Total da rede
				@ nLin,01  PSAY  "| "
				@ nLin,62  PSAY  "|"
				@ nLin,77  PSAY  "|"
				@ nLin,89  PSAY  "|"
				@ nLin,106 PSAY  "|"
				nlin++
			Endif
			
			@ nLin,01  PSAY  "|  "+_cCcod + " " +SUBSTR(_cCNome,1,48)
			@ nLin,62  PSAY  "|"+ TRANSFORM(_nFat  ,"@E 99,999,999.99")
			@ nLin,77  PSAY  "|"
			@ nLin,78  PSAY  TRANSFORM(_nPer,"@E 9999.99")+" %"
			@ nLin,89  PSAY  "|"
			@ nLin,90  PSAY  TRANSFORM(_nQtde,"@E 99,999,999.99")
			@ nLin,106 PSAY  "|"
			nlin++
			
			_cRed_old  := TEMP->CodRed                   	//CODIGO REDE
			/*TOTAL GERAL*/
			If TEMP->TipoRel <> "T"
				_nFatG  := _nFatG  + _nFat
				_nQtdeG := _nQtdeG + _nQtde
			Endif
			DbSkip()
		Enddo
		//Total do Vendedor
		@ nLin,01 PSAY  "|------------------------------------------------------------|--------------|-----------|----------------|"
		nLin++
		IF (_nFatG + _nQtdeG) <> 0                          //-D1TOT fat -D1QTD qtd
			If _TnQtd > 0
				//	_TfLiq
				_nPer  := _nFatG / _TfLiq * 100
				//		_nPer  := _nQtdeG / _TnQtd * 100
			Else
				_nPer  := 0
			Endif
			If _TipCliRed = "C"
				@ nLin,01 PSAY "|                             Total        "
			Else
				@ nLin,01 PSAY "|                          Total Redes      "
			Endif
			@ nLin,62 PSAY "|" + TRANSFORM(_nFatG,"@E 99,999,999.99")
			@ nLin,77 PSAY "|"
			@ nLin,78  PSAY  TRANSFORM(_nPer,"@E 9999.99")+" %"
			@ nLin,89 PSAY "|"
			@ nLin,90 PSAY  TRANSFORM(_nQtdeG,"@E 99,999,999.99")
			@ nLin,106 PSAY   "|"
			nLin ++
			@ nLin,01 PSAY  "|------------------------------------------------------------|--------------|-----------|----------------|"
			nLin++
		Endif
		
		MsprocTxt("Imprimindo...")
		
		
		// TOTAL GERAL
		
		_nFatGG +=_nFatG
		_nPerGG +=_nPerG
		_nPMedGG+=_nPMedG
		_nQtdeGG+=_nQtdeG
		
		
		// ZERANDO TOTAIS
		_nFatG  :=0
		_nPerG  :=0
		_nPMedG :=0
		_nQtdeG :=0
		_nFatu:=0
		_nDesc:=0
		
	Endif

	DBSELECTAREA("VEND")                     //VOLTANDO PARA AREA ANTERIOR
	//

Return


/* Retorno de grupo de TES para validacao em filtro */
Static Function fRetTes()

	Local cRet	:= ""
	Local aArea	:= GetArea()
	Local cParam:= Alltrim(GetMV("ZZ_TESBONI"))
	Local nTam	:= Len(cParam)

	For n1 := 1 to nTam
		If n1 == 1
			cRet := "(" + "'" + Substr(cParam,n1,3) + "'" + ","
			n1 += 3
		Else
			cRet += "'" + Substr(cParam,n1,3) + "'" 
			n1 += 3
			If n1 + 1 < nTam
				cRet += ","
			Endif	
		Endif
		
	Next n1 		                     

	If !Empty(cRet)	
		cRet += ")"
	Endif

	RestArea(aArea)

Return(cRet)