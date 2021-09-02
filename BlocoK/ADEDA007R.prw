#Include "RwMake.ch"             
#Include "Protheus.ch"
#Include "Topconn.ch" 
#INCLUDE "MntTRCell.ch"

//Posicao da estrutura TCBrowse
#DEFINE TCB_POS_CMP	1
#DEFINE TCB_POS_PIC	2
#DEFINE TCB_POS_TIT	3
#DEFINE TCB_POS_TAM	4
#DEFINE TCB_POS_TIP	5

//Largura das colunas FWLayer
#DEFINE LRG_COL01		20
#DEFINE LRG_COL02		70
#DEFINE LRG_COL03		10

//Posicoes do pergunte do SX1
#DEFINE POS_X1DES		1
#DEFINE POS_X1TIP		2
#DEFINE POS_X1TAM		3
#DEFINE POS_X1OBJ		6
#DEFINE POS_X1VLD		7
#DEFINE POS_X1VAL		8
#DEFINE POS_X1CB1		9
#DEFINE POS_X1CB2		10
#DEFINE POS_X1CB3		11
#DEFINE POS_X1CB4		12
#DEFINE POS_X1CB5		13
#DEFINE POS_X1VAR		14

Static nQtdePerg:= 7
Static nTamFil	:= IIf(FindFunction("FWSizeFilial"),FWSizeFilial(),2)
Static nTamArq	:= 500
Static nTopCont	:= 003
Static nEsqCont	:= 001
Static nAltCont	:= 009
Static nDistPad	:= 002
Static nAltBot	:= 013
Static nDistAPad:= 004
Static nDistEtq	:= 001
Static nAltEtq	:= 007
Static nLargEtq	:= 035 
Static nLargBot	:= 040
Static cHK		:= "&"
Static cMsgIni	:= "Inicia Processamento do item: "
Static cMsgFim	:= "Termina Processamento do item: "

/*/{Protheus.doc} User Function nomeFunction
	(long_description)
	@type  Function
	@author user
	@since 05/03/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 10248 - Fernando Macieira - 05/03/2021 - Revisใo das rotinas de apontamento de OPดs
	@history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA
    @history ticket 11639 - Fernando Macieira - 26/05/2021 - Projeto - OPS Documento de entrada - Industrializa็ใo/Beneficiamento
/*/
User Function ADEDA007R()

	Local oDlg

	Private cPerg := "ADEDA007R"

	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA
	/*
	Private _cNomBco1  := GetPvProfString("INTEDTBD","BCO1","ERROR",GetADV97())
	Private _cSrvBco1  := GetPvProfString("INTEDTBD","SRV1","ERROR",GetADV97())
	Private _cPortBco1 := Val(GetPvProfString("INTEDTBD","PRT1","ERROR",GetADV97()) )
	Private _cNomBco2  := GetPvProfString("INTEDTBD","BCO2","ERROR",GetADV97())
	Private _cSrvBco2  := GetPvProfString("INTEDTBD","SRV2","ERROR",GetADV97())
	Private _cPortBco2 := Val(GetPvProfString("INTEDTBD","PRT2","ERROR",GetADV97()))
	Private _nTcConn1  := advConnection()
	Private _nTcConn2  := 0
	*/

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	// @history Fernando Macieira, 05/03/2021, Ticket 10248. Revisใo das rotinas de apontamento de OPดs
	// Garanto uma ๚nica thread sendo executada
	If !LockByName("ADEDA007R", .T., .F.)
		Aviso("Aten็ใo", "Existe outro processamento sendo executado! Verifique com seu colega de trabalho...", {"OK"}, 3)
		Return
	EndIf
	//

	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA
	/*
	If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2))<0
		_lRet     := .F.
		cMsgError := "Nใo foi possํvel  conectar ao banco integra็ใo"
		MsgInfo("Nใo foi possํvel  conectar ao banco integra็ใo, verifique com administrador","ERROR")	
	EndIf

	TcSetConn(_nTcConn1) //fernando sigoli 01/05/2018
	*/

	/*Cria as perguntas no SX1*/
	AjustaSX1(cPerg)         

	/*Mostra a tela de perguntas*/
	Pergunte(cPerg,.F.)    	

	DEFINE MSDIALOG oDlg FROM  96,9 TO 320,612 TITLE OemToAnsi("Tela de filtro") PIXEL
	@ 11,6 TO 90,287 LABEL "" OF oDlg  PIXEL
	@ 16, 15 SAY OemToAnsi("Este programa faz o processamento no Protheus da carga do EDATA") SIZE 268, 8 OF oDlg PIXEL

	DEFINE SBUTTON FROM 93, 163 TYPE 15 ACTION Processa({|lEnd| ADEDA007D()},OemToAnsi("Log"),OemToAnsi("Processando..."),.F.) ENABLE OF oDlg
	DEFINE SBUTTON FROM 93, 193 TYPE 5  ACTION Pergunte(cPerg,.T.) ENABLE OF oDlg
	DEFINE SBUTTON FROM 93, 223 TYPE 1  ACTION If(.T.,(Processa({|lEnd| ADEDA007A()},OemToAnsi("Processando a carga"),OemToAnsi("Processando..."),.F.),oDlg:End()),) ENABLE OF oDlg
	DEFINE SBUTTON FROM 93, 253 TYPE 2  ACTION oDlg:End() ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED

	//TcSetConn(_nTcConn1)	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ?
	//ณDestrava a rotina para o usuแrio	    ?
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ?
	UnLockByName("ADEDA007R") // @history Fernando Macieira, 05/03/2021, Ticket 10248. Revisใo das rotinas de apontamento de OPดs

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณADEDA007A   บAutor ณLeonardo Rios     บ Data ณ25/09/2014     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.    ณTela para mostrar o itens retornados conforme a query a ser  บฑฑ
ฑฑบ         ณ contruida com base na regra o nos parametros de filtro      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ADEDA007A

	Local oArea		:= FWLayer():New()
	Local aCoord	:= FWGetDialogSize(oMainWnd)
	Local aTamObj	:= Array(4)
	Local oDlg
	Local aHeader   := {}
	Local aCols     := {}
	Local aAux		:= {}
	Local aCampos   := {}  /*Array aCampos utilizado para colocar quais campos deverแ fazer uma busca para o array aHeader*/
	Local aPergunte	:= {}
	Local cMens		:= ""

	Local cAliasT
	Local nOpc      := Nil   /*op็ใo 2 para apenas visualizar os meus itens da tela*/ 	//2
	Local nCoefDif	:= 1
	Local oOk 		:= LoadBitmap(GetResources(),"LBOK")
	Local oNo 		:= LoadBitmap(GetResources(),"LBNO")
	Local bAtGD		:= {|lAtGD,lFoco| IIf(lAtGD,(oGD01:SetArray(aCols),oGD01:bLine := &(cLine01),oGD01:GoTop()),.T.),;
							IIf(ValType(lFoco) == "L" .AND. lFoco,(oGD01:SetFocus(), oGD01:Refresh()),.T.)}
	Local bAtFim	:= {|| ( oTela:End() ) }	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA
	//Local bAtFim	:= {|| ( TcUnLink(_nTcConn1), TcUnLink(_nTcConn2), oTela:End() ) }	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA

	//Objetos graficos
	Local oTela
	Local oPainel01
	Local oPainel02
	Local oPainel03
	Local oPainelS01
	Local oGD01

	//Cores
	Local oGreen   	:= LoadBitmap( GetResources(), "BR_VERDE")
	Local oRed    	:= LoadBitmap( GetResources(), "BR_VERMELHO")
	Local oBlack	:= LoadBitmap( GetResources(), "BR_PRETO")
	Local oYellow	:= LoadBitmap( GetResources(), "BR_AMARELO")
	Local oBrown	:= LoadBitmap( GetResources(), "BR_MARROM")
	Local oBlue		:= LoadBitmap( GetResources(), "BR_AZUL")
	Local oOrange	:= LoadBitmap( GetResources(), "BR_LARANJA")
	Local oViolet	:= LoadBitmap( GetResources(), "BR_VIOLETA")
	Local oPink		:= LoadBitmap( GetResources(), "BR_PINK")
	Local oGray		:= LoadBitmap( GetResources(), "BR_CINZA")
	Local y,x,z,ni

	Private cLine01	:= ""
	Private ALTERA	  := .T.
	Private aAux	  := {} //Array auxiliar utilizado para guardar informa็๕es que serใo necessarias

	//Private cPlaca	  := ""
	Private nPerg01Tip := mv_par01 // Tabela
	Private dPerg02Dta := mv_par02 // Perํodo De
	Private dPerg03Dta := mv_par03 // Perํodo Ate
	Private cPerg04Pdt := mv_par04 // Produto De
	Private cPerg05Pdt := mv_par05 // Produto Ate
	Private cPerg06Sta := mv_par06 // Status
	Private cPerg07Ope := mv_par07 // Tipo de Opera็ใo
	Private cPerg08Prd := mv_par08 // Produ็ใo (Pr๓pria/Terceiro) // @history ticket 11639 - Fernando Macieira - 26/05/2021 - Projeto - OPS Documento de entrada - Industrializa็ใo/Beneficiamento
	Private oBot01
	Private oBot02
	Private oBot03
	Private oBot04
	Private oBot05

	aFill(aTamObj,0)

	AADD( aCampos, {"C2_FILIAL", "C2_PRODUTO", "B1_DESC", "C2_QUANT", "C2_EMISSAO"} )
	     
	aAdd( aHeader, { '', 'CLEGEND' , '@BMP', 10 , 0, , , 'C', , 'V' ,  ,  , 		, 'V', 'S' } )
	aAdd( aHeader, { '', 'CHECKBOL', '@BMP', 10 , 0, , , 'L', , 'V' ,  ,  , 'mark'  , 'V', 'S' } )
	
	// Carrega aHeader
	dbSelectArea( "SX3" )
	SX3->( dbSetOrder( 2 ) ) // Campo                
	For x:=1 To Len(aCampos)
		For y:= 1 To Len(aCampos[x]) //s๓ estou usando a variavel x porque tamb้m possui o valor 3
			If SX3->( dbSeek( aCampos[x, y] ) )
				AADD( aHeader, { 	AllTrim( X3Titulo() ),; // 01 - Titulo
									SX3->X3_CAMPO		 ,;			// 02 - Campo
									SX3->X3_Picture		 ,;			// 03 - Picture
									SX3->X3_TAMANHO		 ,;			// 04 - Tamanho
									SX3->X3_DECIMAL		 ,;			// 05 - Decimal
									SX3->X3_Valid  		 ,;			// 06 - Valid
									SX3->X3_USADO  		 ,;			// 07 - Usado
									SX3->X3_TIPO   		 ,;			// 08 - Tipo
									SX3->X3_F3			 ,;			// 09 - F3
									SX3->X3_CONTEXT 	 ,;         // 10 - Contexto
									SX3->X3_CBOX		 ,; 		// 11 - ComboBox
									SX3->X3_RELACAO 	 ,;         // 12 - Relacao
									SX3->X3_INIBRW  	 ,;			// 13 - Inicializador Browse
									SX3->X3_Browse  	 ,;			// 14 - Mostra no Browse
									SX3->X3_VISUAL  } )
			EndIf
		Next y
	Next x
	
	//aOutros := {'MSEXP', 'STATUS', 'OPERACAO', 'TIPO'}
    aOutros := {'MSEXP', 'STATUS', 'OPERACAO', 'TIPO', 'LOCAL', 'PRODUCAO'} // @history ticket 11639 - Fernando Macieira - 26/05/2021 - Projeto - OPS Documento de entrada - Industrializa็ใo/Beneficiamento
	
    SX3->( dbSeek( "C2_OBS" ) )
	For x:=1 To Len(aOutros)
		AADD( aHeader, { 	AllTrim( aOutros[x] ),; // 01 - Titulo
							SX3->X3_CAMPO		 ,;			// 02 - Campo
							SX3->X3_Picture		 ,;			// 03 - Picture
							SX3->X3_TAMANHO		 ,;			// 04 - Tamanho
							SX3->X3_DECIMAL		 ,;			// 05 - Decimal
							SX3->X3_Valid  		 ,;			// 06 - Valid
							SX3->X3_USADO  		 ,;			// 07 - Usado
							SX3->X3_TIPO   		 ,;			// 08 - Tipo
							SX3->X3_F3			 ,;			// 09 - F3
							SX3->X3_CONTEXT 	 ,;         // 10 - Contexto
							SX3->X3_CBOX		 ,; 		// 11 - ComboBox
							SX3->X3_RELACAO 	 ,;         // 12 - Relacao
							SX3->X3_INIBRW  	 ,;			// 13 - Inicializador Browse
							SX3->X3_Browse  	 ,;			// 14 - Mostra no Browse
							SX3->X3_VISUAL  } )
	Next x
	
	If nPerg01Tip <> 4

		cAliasT	:= GetNextAlias()
		
		ADEDA007RF(@cAliasT, nPerg01Tip)
		
		(cAliasT)->(dbGoTop())
		
		Do While !(cAliasT)->(Eof())
			
			DO CASE
				CASE (cAliasT)->STATUS == "I"
					xCor := oGreen
				CASE (cAliasT)->STATUS == "S"
					xCor := oBlue
				CASE (cAliasT)->STATUS == "E"
					xCor := oRed
				OTHERWISE
					xCor := oGray
			ENDCASE
			
			//TcSetConn(_nTcConn1)	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA
			
			cDescri := ""
			SB1->(DbSetOrder(1))
			If SB1->(DbSeek( xFilial("SB1") + Padr((cAliasT)->PRODUTO, TamSx3("B1_COD")[1]) ))
				cDescri := SB1->B1_DESC
			EndIf
			
			//TcSetConn(_nTcConn2)	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA
			
			AADD(aCols,	{	xCor				,;
							.F.                 ,;
							(cAliasT)->FILIAL	,;
		   		   			(cAliasT)->PRODUTO	,;
		   		   			cDescri             ,;
		   					(cAliasT)->QUANT	,;
		  					(cAliasT)->DATA		,;
		  					(cAliasT)->MSEXP	  })
		 	
		 	DO CASE
				CASE (cAliasT)->STATUS == "I"
					AADD( aCols[Len(aCols)], "Integrado" )
				CASE (cAliasT)->STATUS == "S"
					AADD( aCols[Len(aCols)], "Processado" )
				CASE (cAliasT)->STATUS == "E"
					AADD( aCols[Len(aCols)], "Erro" )
				OTHERWISE
					AADD( aCols[Len(aCols)], "" )
			ENDCASE
		 	
		 	DO CASE
				CASE (cAliasT)->OPERACAO == "I"
					AADD( aCols[Len(aCols)], "Inclusใo" )
				CASE (cAliasT)->OPERACAO == "A"
					AADD( aCols[Len(aCols)], "Altera็ใo" )
				CASE (cAliasT)->OPERACAO == "E"
					AADD( aCols[Len(aCols)], "Exclusใo" )
				OTHERWISE
					AADD( aCols[Len(aCols)], "" )
			ENDCASE
			
			DO CASE
				CASE nPerg01Tip == 1
					AADD( aCols[Len(aCols)], "OPR" )
				CASE nPerg01Tip == 2
					AADD( aCols[Len(aCols)], "MOV" )
				CASE nPerg01Tip == 3
					AADD( aCols[Len(aCols)], "INV" )
				OTHERWISE
					AADD( aCols[Len(aCols)], "" )
			ENDCASE

            // @history ticket 11639 - Fernando Macieira - 26/05/2021 - Projeto - OPS Documento de entrada - Industrializa็ใo/Beneficiamento
            aAdd( aCols[Len(aCols)], (cAliasT)->LOCAL )
            aAdd( aCols[Len(aCols)], (cAliasT)->PRODUCAO )
            //

			AADD( aCols[Len(aCols)], .F. )
			
			AADD( aAux,	{ (cAliasT)->REC 	  } )

			(cAliasT)->(dbSkip())
	
		EndDo
		
		U_FecArTMP(cAliasT)
		
	Else

		For z:=1 To 3

			cAliasT	:= GetNextAlias()
	
			ADEDA007RF(@cAliasT, z)
			
			(cAliasT)->(dbGoTop())
		
			Do While !(cAliasT)->(Eof())

				DO CASE
					CASE (cAliasT)->STATUS == "I"
						xCor := oGreen
					CASE (cAliasT)->STATUS == "S"
						xCor := oBlue
					CASE (cAliasT)->STATUS == "E"
						xCor := oRed
					OTHERWISE
						xCor := oGray
				ENDCASE
				
				//TcSetConn(_nTcConn1)	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA
				
				cDescri := ""
				SB1->(DbSetOrder(1))
				If SB1->(DbSeek( xFilial("SB1") + Padr((cAliasT)->PRODUTO, TamSx3("B1_COD")[1]) ))
					cDescri := SB1->B1_DESC
				EndIf
				
				//TcSetConn(_nTcConn2)	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA
				
				AADD(aCols,	{	xCor				,;
								.F.                 ,;
								(cAliasT)->FILIAL	,;
			   		   			(cAliasT)->PRODUTO	,;
			   		   			cDescri             ,;
			   					(cAliasT)->QUANT	,;
			  					(cAliasT)->DATA		,;
			  					(cAliasT)->MSEXP	  })
			 	
			 	DO CASE
					CASE (cAliasT)->STATUS == "I"
						AADD( aCols[Len(aCols)], "Integrado" )
					CASE (cAliasT)->STATUS == "S"
						AADD( aCols[Len(aCols)], "Processado" )
					CASE (cAliasT)->STATUS == "E"
						AADD( aCols[Len(aCols)], "Erro" )
					OTHERWISE
						AADD( aCols[Len(aCols)], "" )
				ENDCASE
			 	
			 	DO CASE
					CASE (cAliasT)->OPERACAO == "I"
						AADD( aCols[Len(aCols)], "Inclusใo" )
					CASE (cAliasT)->OPERACAO == "A"
						AADD( aCols[Len(aCols)], "Altera็ใo" )
					CASE (cAliasT)->OPERACAO == "E"
						AADD( aCols[Len(aCols)], "Exclusใo" )
					OTHERWISE
						AADD( aCols[Len(aCols)], "" )
				ENDCASE
				
				DO CASE
					CASE z == 1
						AADD( aCols[Len(aCols)], "OPR" )
					CASE z == 2
						AADD( aCols[Len(aCols)], "MOV" )
					CASE z == 3
						AADD( aCols[Len(aCols)], "INV" )
					OTHERWISE
						AADD( aCols[Len(aCols)], "" )
				ENDCASE

                // @history ticket 11639 - Fernando Macieira - 26/05/2021 - Projeto - OPS Documento de entrada - Industrializa็ใo/Beneficiamento
                aAdd( aCols[Len(aCols)], (cAliasT)->LOCAL )
                aAdd( aCols[Len(aCols)], (cAliasT)->PRODUCAO )
                //

				AADD( aCols[Len(aCols)], .F. )
				
				AADD( aAux,	{ (cAliasT)->REC 	  } )
			    
				(cAliasT)->(dbSkip())
		
			EndDo
			
			U_FecArTMP(cAliasT)

		Next z

	EndIf	

    If Len(aCols) < 1

		xCor := oGray
		AADD(aCols,	{	xCor,;
						.F. ,;
						""	,;
						""	,;
	   		   			""	,;
						""	,;
						""	,;
	  					""	  })
	 	
		AADD( aCols[Len(aCols)], "" )
		AADD( aCols[Len(aCols)], "" )
		AADD( aCols[Len(aCols)], "" )

        // @history ticket 11639 - Fernando Macieira - 26/05/2021 - Projeto - OPS Documento de entrada - Industrializa็ใo/Beneficiamento
		AADD( aCols[Len(aCols)], "" )
		AADD( aCols[Len(aCols)], "" )
        //

		AADD( aCols[Len(aCols)], .T. )

	EndIf

	/*
		Montar o codeblock para montar as listas de dados da GD
	*/
	cLine01 := "{|| Iif( Len(aCols) < 1, {}, "
	cLine01 += " { aCols[oGD01:nAt,1], "
	cLine01 += "IIf(aCols[oGD01:nAt,2],oOk,oNo),"
	For ni := 3 to 13
		cLine01 += "aCols[oGD01:nAt," + cValToChar(ni) + "]" + IIf(ni < 13,",","")
	Next ni
	cLine01 += "} ) }"

	/*
		Substituir o nome dos campos pelos titulos
	*/
	//For ni := 1 to Len(aCampos)
	//	aCampos[ni] := Posicione("SX3",2,PadR(aCampos[ni],10),"X3Titulo()")
	//Next ni
	
	/*
		Interface
	*/
	aCoord[3] := aCoord[3] * 0.95
	aCoord[4] := aCoord[4] * 0.95
	If U_ApRedFWL(.T.)
		nCoefDif := 0.95
	Endif
	
	DEFINE MSDIALOG oTela TITLE "Integra็ใo Protheus x Edata" FROM aCoord[1],aCoord[2] TO aCoord[3],aCoord[4] OF oMainWnd COLOR "W+/W" PIXEL

		oArea:Init(oTela,.F.)

		/*Mapeamento da area*/	
		oArea:AddLine("L01",100 * nCoefDif,.T.)

	
		/*Colunas*/
		oArea:AddCollumn("L01C01",LRG_COL01,.F.,"L01")
		oArea:AddCollumn("L01C02",LRG_COL02,.F.,"L01")
		oArea:AddCollumn("L01C03",LRG_COL03,.F.,"L01")
	
	
		/*Paineis*/
		oArea:AddWindow("L01C01","L01C01P01","Parโmetros",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
		oPainel01 := oArea:GetWinPanel("L01C01","L01C01P01","L01")
		
		oArea:AddWindow("L01C02","L01C02P01","Dados adicionais",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
		oPainel02 := oArea:GetWinPanel("L01C02","L01C02P01","L01")
		
		oArea:AddWindow("L01C03","L01C03P01","Fun็๕es",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
		oPainel03 := oArea:GetWinPanel("L01C03","L01C03P01","L01")
	
	
	
		/*
			Painel 01 - Filtros
		*/
	
		/*PERGUNTAS*/
		U_DefTamObj(@aTamObj,000,000,(oPainel01:nClientHeight / 2) * 0.9,oPainel01:nClientWidth / 2)
		oPainelS01 := tPanel():New(aTamObj[1],aTamObj[2],"",oPainel01,,.F.,.F.,,CLR_WHITE,aTamObj[4],aTamObj[3],.T.,.F.)
	
		/*Parametriza็ใo das perguntas que serใo mostradas em tela*/
		Pergunte(cPerg,.T.,,.F.,oPainelS01,,@aPergunte,.T.,.F.)
	
		/*Atualiza as informa็๕es da tela ap๓s ter utilizado a pergunta*/
		ADEDA007C(aClone(aHeader),@aCols, @aAux)
	
		/*BOTAO PESQUISA*/
		U_DefTamObj(@aTamObj, (oPainel01:nClientHeight / 2) - nAltBot, 000, (oPainel01:nClientWidth / 2), nAltBot, .T.)
		oBotPesq := tButton():New(aTamObj[1], aTamObj[2], cHK + "Pesquisar", oPainel01,;
								{|| IIf(ADEDA007RE(cPerg, @aPergunte),;
										MsAguarde({|| CursorWait(), ADEDA007C(aClone(aHeader), @aCols, @aAux), Eval(bAtGD,.T.,.T.), CursorArrow()},;
											"Pre-Processamento","Pesquisando",.F.),;
										.F.)},;
										aTamObj[3], aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
	
	
		/*
			Painel 02 - Lista de dados
		*/
		/*Cria tela com os dados*/
		//oGD01 := TCBrowse():New(000,000,000,000,/*bLine*/,{' ', ' ', 'FILIAL', 'PRODUTO', 'DESCRICAO', 'QUANTIDADE', 'DATA', 'MSEXP', 'STATUS', 'OPERACAO', 'TIPO'},,oPainel02,,,,/*bChange*/,/*bLDblClick*/,/*bRClick*/,/*oFont*/,,,,,,,.T.,/*bWhen*/,,/*bValid*/,.T.,.T.)
        oGD01 := TCBrowse():New(000,000,000,000,/*bLine*/,{' ', ' ', 'FILIAL', 'PRODUTO', 'DESCRICAO', 'QUANTIDADE', 'DATA', 'MSEXP', 'STATUS', 'OPERACAO', 'TIPO', 'LOCAL', 'PRODUCAO'},,oPainel02,,,,/*bChange*/,/*bLDblClick*/,/*bRClick*/,/*oFont*/,,,,,,,.T.,/*bWhen*/,,/*bValid*/,.T.,.T.) // @history ticket 11639 - Fernando Macieira - 26/05/2021 - Projeto - OPS Documento de entrada - Industrializa็ใo/Beneficiamento
		oGD01:bHeaderClick	:= {|oObj,nCol| ADEDA007G(2,@aCols,@oGD01,nCol,aClone(aHeader)),oGD01:Refresh()}
		oGD01:blDblClick	:= {|| ADEDA007B(1,@aCols,@oGD01,,aClone(aHeader)),oGD01:Refresh()}
		oGD01:Align 		:= CONTROL_ALIGN_ALLCLIENT
		
		/*
		
			Bloco de execu็ใo para executar os seguintes m้todos:
				oGD01:SetArray(aCols)
				oGD01:bLine := {|| {aCols[oGD01:nAt,01], Iif(aCols[oGD01:nAt,02],oOk,oNo),aCols[oGD01:nAt,03], aCols[oGD01:nAt,04], Transform(aCols[oGD01:nAt,05],'@E 99,999,999,999.99'), aCols[oGD01:nAt,06], aCols[oGD01:nAt,07], aCols[oGD01:nAt,08], aCols[oGD01:nAt,09], aCols[oGD01:nAt,10]} }
				oGD01:GoTop()
				oGD01:SetFocus()
		*/
		Eval(bAtGD,.T.,.F.)
	
	
	
		/*
			Painel 03 - Bot๕es e Suas Fun็๕es
		*/
		/*Libera็ใo*/
		U_DefTamObj(@aTamObj, 000, 000, (oPainel03:nClientWidth / 2), nAltBot, .T.)
		oBot01 := tButton():New(aTamObj[1], aTamObj[2], cHK + "Processamento", oPainel03,;
								{|| IIf(.T., MsAguarde({|| CursorWait(), lOk := ADEDA007A1(aClone(aCols), aClone(aAux)), CursorArrow(),;
												IIf(lOk, (ADEDA007C(aClone(aHeader), @aCols, @aAux), Eval(bAtGD, .T., .T.)), AllwaysTrue())},;
												"ADEDA007R", "Processando",.F.),;
											MsgAlert("Para processar ้ necessแrio que ao menos um registro seja selecionado!", "Processa"))},;
								aTamObj[3], aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
	
	
		/*Estorno*/
		U_DefTamObj(@aTamObj, aTamObj[1] + nAltBot + (nDistPad*2))
		oBot02 := tButton():New(aTamObj[1], aTamObj[2], cHK + "Estorno", oPainel03,;
								{|| IIf(.T., MsAguarde({|| CursorWait(), lOk := ADEDA007RH(aClone(aCols), aClone(aAux)), CursorArrow(),;
												IIf(lOk, (ADEDA007C(aClone(aHeader), @aCols, @aAux), Eval(bAtGD, .T., .T.)), AllwaysTrue())},;
												"ADEDA007R", "Processando", .F.),;
											MsgAlert(cNomeUs + ", para processar ้ necessแrio que ao menos um registro seja selecionado!", "Estorno"))},;
								aTamObj[3], aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
	
			
		/*Legenda*/
		U_DefTamObj(@aTamObj, aTamObj[1] + nAltBot + (nDistPad*2))
		oBot03 := tButton():New(aTamObj[1], aTamObj[2], cHK + "Legenda", oPainel03, {|| Legenda()}, aTamObj[3], aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
	
	
		/*Sair*/
		U_DefTamObj(@aTamObj, aTamObj[1] + nAltBot + (nDistPad*2) )
		oBot04 := tButton():New(aTamObj[1], aTamObj[2], cHK + "Sair", oPainel03, bAtFim, aTamObj[3], aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
		
		/*Log*/
		U_DefTamObj(@aTamObj, aTamObj[1] + nAltBot + (nDistPad*3) )
		oBot05 := tButton():New(aTamObj[1], aTamObj[2], cHK + "Log", oPainel03, {|| ADEDA007D() }, aTamObj[3], aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
		
		
		If cPerg06Sta  == 1
			oBot02:Hide()
		ElseIf cPerg06Sta  == 2
			oBot01:Hide()
		EndIf
		
	oTela:Activate(,,,.T.,/*valid*/,,{|| .T.})

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณValidData  บAutor ณLeonardo Rios     บ Data ณ25/09/2014   	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.    ณ Fun็ใo para valida็ใo das linhas ap๓s clicar no botใo		  บฑฑ
ฑฑบ         ณ confirmar da tela											  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ADEDA007A1(aCols, aAux)

    Local aOPR 		:= {}
    Local aMOV		:= {}
    Local aINV 		:= {}
    Local cMsg		:= ""
    Local cMsgLog	:= ""
    Local lRet		:= .F.
    Local x,y

    Private _MsgMotivo := ""

    /*
    TcConType("TCPIP")
    If (_nTcConn1 := TcLink(_cNomBco1,_cSrvBco1,_cPortBco1))<0
        _lRet     := .F.
        cMsgError := "Nใo foi possํvel  conectar ao banco Protheus"
        MsgInfo("Nใo foi possํvel  conectar ao banco produ็ใo, verifique com administrador","ERROR")	
    EndIf

    If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2))<0
        _lRet     := .F.
        cMsgError := "Nใo foi possํvel  conectar ao banco integra็ใo"
        MsgInfo("Nใo foi possํvel  conectar ao banco integra็ใo, verifique com administrador","ERROR")	
    EndIf
    */

    /*BEGINDOC
    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
    //ณExemplo da estrutura dos arrays aOPR, aMOV e aINV ณ
    //ณaOPR[a]          								 ณ
    //ณ   aCols[a,1]    								 ณ
    //ณ       cor 		[a,1, 1]						 ณ
    //ณ       checkbox 	[a,1, 2]						 ณ
    //ณ       filial 	[a,1, 3]						 ณ
    //ณ       produto   [a,1, 4]						 ณ
    //ณ       produto   [a,1, 5]						 ณ
    //ณ       quantidade[a,1, 6]						 ณ
    //ณ       dt emissao[a,1, 7]						 ณ
    //ณ       msexp     [a,1, 8]						 ณ
    //ณ       status    [a,1, 9]						 ณ
    //ณ       operacao  [a,1,10]						 ณ
    //ณ       tipo      [a,1,11]						 ณ
    //ณ   aAux[a,2]     								 ณ
    //ณ       rec 		[a,2, 1]						 ณ
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    ENDDOC*/

    //Begin Transaction
	
   	For x:=1 To Len(aCols)
		//If aCols[x,2] .AND. !aCols[x,12]
        If aCols[x,2] .AND. !aCols[x,14]
			If aCols[x,11] == "OPR"
				AADD(aOPR, { aCols[x], aAux[x] } )
			ElseIf aCols[x,11] == "MOV"
				AADD(aMOV, { aCols[x], aAux[x] } )
			Else
				AADD(aINV, { aCols[x], aAux[x] } )
			EndIf
  		EndIf
	Next x
    
	If Len(aOPR) < 1 .AND. Len(aMOV) < 1 .AND. Len(aINV) < 1
		MsgAlert("Nใo existem itens para serem processados")
		Return .F.
	EndIf

	aArrays := {aOPR, aMOV, aINV}
	cMsgLog := ""
	
	For x:=1 To Len(aArrays)
		
		For y:=1 To Len(aArrays[x])
		
			//Begin Transaction
		
				cMsg := "FILIAL=" + ALLTRIM(aArrays[x,y,1,3]) + "; PRODUTO=" + ALLTRIM(aArrays[x,y,1,4]) + "; DESCRI=" + ALLTRIM(aArrays[x,y,1,5]) +;
						"; QUANTIDADE=" + ALLTRIM( STR(aArrays[x,y,1,6]) ) + "; RECEDATA=" + ALLTRIM( StrZero(aArrays[x,y,2,1], 10) ) + "; "
				
				/* Condi็ใo para assegurar que estแ incluindo itens apenas que nใo foram processados ainda(campo MSEXP vazio) */
				// If ! EMPTY( ALLTRIM( aArrays[x,y,1,8] ))
				// 	LOOP
				// EndIf


				//TcSetConn(_nTcConn1)	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA

				If x == 1

					U_CCSGrvLog(cMsgIni+cMsg, "OPR", aArrays[x,y,2,1], 6, aArrays[x,y,1,3], .T.)
					
					lRet := U_ADEDA003P( aArrays[x,y,2,1] ) //nRec
					//TcSetConn(_nTcConn1)	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA
					
					U_CCSGrvLog(cMsgFim+cMsg, "OPR", aArrays[x,y,2,1], 6, aArrays[x,y,1,3], .T.)
					
				ElseIf x == 2

					U_CCSGrvLog(cMsgIni+cMsg, "MOV", aArrays[x,y,2,1], 6, aArrays[x,y,1,3], .T.)
					
					lRet :=	IIF( aArrays[x,y,1,10] == "Exclusใo", U_ADEDA005P(aArrays[x,y,2,1], .F.), U_ADEDA004P( aArrays[x,y,2,1] ) )
					//TcSetConn(_nTcConn1)	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA
					
					U_CCSGrvLog(cMsgFim+cMsg, "MOV", aArrays[x,y,2,1], 6, aArrays[x,y,1,3], .T.)
					
				Else

					U_CCSGrvLog(cMsgIni+cMsg, "INV", aArrays[x,y,2,1], 6, aArrays[x,y,1,3], .T.)
					
					lRet :=	IIF( aArrays[x,y,1,10] == "Exclusใo", U_ADEDA006P(aArrays[x,y,2,1], .F., .F.), U_ADEDA006P( aArrays[x,y,2,1], .T. ) )					
					//TcSetConn(_nTcConn1)	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA
					
					U_CCSGrvLog(cMsgFim+cMsg, "INV", aArrays[x,y,2,1], 6, aArrays[x,y,1,3], .T.)

				EndIf
				
				If !lRet
					cMsgLog += " - Problema na gera็ใo do item: " + cMsg + CHR(13) + CHR(10) + " - MOTIVO=" + _MsgMotivo + CHR(13) + CHR(10) + " " + CHR(13) + CHR(10)
				EndIf

				MsUnlockAll()
				
			//End Transaction

		Next y

	Next x
	
	//TcSetConn(_nTcConn2)		// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA
	
	//alerta nใo foi selecionado nenhum valor		
	cMens := "Todos os itens selecionados foram processados! Verifique o log para verificar erros por favor no botใo 'Visualizar' "
	cMens +=  CHR(13) + CHR(10) + cMsgLog
		
	U_ExTelaMen("Gera็ใo dos itens",cMens,"Arial",10,,.F.,.T.)

	MsUnlockAll()
	
    //End Transaction
	
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณADEDA007B บAutor  ณccskf				    บ Data ณ04/06/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina pra fazer o tratamento de selecao de dados                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAdoro                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ADEDA007B(nOpc,aDados,oGDSel,nColSel,aHead)

	Local ni		:= 0
	Local cRoteiro	:= ""

	DEFAULT nOpc	:= 0
	DEFAULT aDados	:= Array(0)
	DEFAULT oGDSel  := Nil
	DEFAULT nColSel	:= 1
	DEFAULT aHead	:= Array(0)

	If nOpc == 1
		If !aDados[oGDSel:nAt][14]
			aDados[oGDSel:nAt][2] := !aDados[oGDSel:nAt][2]
		EndIf
	Endif

	//Forcar a atualizacao do browse
	oGDSel:DrawSelect()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณADEDA007C   บAutor  ณCCSKF			    บ Data ณ04/06/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de atualizacao da lista de dados                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAdoro                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ADEDA007C(aHeader,aCols, aAux)

	Local cAliasT
	Local oBlue		:= LoadBitmap( GetResources(), "BR_AZUL")
	Local oGreen   	:= LoadBitmap( GetResources(), "BR_VERDE")
	Local oRed    	:= LoadBitmap( GetResources(), "BR_VERMELHO")
	Local oOrange	:= LoadBitmap( GetResources(), "BR_LARANJA")
	Local oGray		:= LoadBitmap( GetResources(), "BR_CINZA")
	Local z

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤgฟ
	//ณDefinicoes de filtros  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aCols := {}
	aAux  := {}

	If nPerg01Tip <> 4

		cAliasT	:= GetNextAlias()
		
		ADEDA007RF(@cAliasT, nPerg01Tip)
		
		(cAliasT)->(dbGoTop())
		
		Do While !(cAliasT)->(Eof())
			DO CASE
				CASE (cAliasT)->STATUS == "I"
					xCor := oGreen
				CASE (cAliasT)->STATUS == "S"
					xCor := oBlue
				CASE (cAliasT)->STATUS == "E"
					xCor := oRed
				OTHERWISE
					xCor := oGray
			ENDCASE
			
			//TcSetConn(_nTcConn1)	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA
			
			cDescri := ""
			SB1->(DbSetOrder(1))
			If SB1->(DbSeek( xFilial("SB1") + Padr((cAliasT)->PRODUTO, TamSx3("B1_COD")[1]) ))
				cDescri := SB1->B1_DESC
			EndIf
			
			//TcSetConn(_nTcConn2)	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA
				
			AADD(aCols,	{	xCor				,;
							.F.                 ,;
							(cAliasT)->FILIAL	,;
		   		   			(cAliasT)->PRODUTO	,;
		   		   			cDescri				,;
		   					(cAliasT)->QUANT	,;
		  					(cAliasT)->DATA		,;
		  					(cAliasT)->MSEXP	  })
		 	
		 	DO CASE
				CASE (cAliasT)->STATUS == "I"
					AADD( aCols[Len(aCols)], "Integrado" )
				CASE (cAliasT)->STATUS == "S"
					AADD( aCols[Len(aCols)], "Processado" )
				CASE (cAliasT)->STATUS == "E"
					AADD( aCols[Len(aCols)], "Erro" )
				OTHERWISE
					AADD( aCols[Len(aCols)], "" )
			ENDCASE
		 	
		 	DO CASE
				CASE (cAliasT)->OPERACAO == "I"
					AADD( aCols[Len(aCols)], "Inclusใo" )
				CASE (cAliasT)->OPERACAO == "A"
					AADD( aCols[Len(aCols)], "Altera็ใo" )
				CASE (cAliasT)->OPERACAO == "E"
					AADD( aCols[Len(aCols)], "Exclusใo" )
				OTHERWISE
					AADD( aCols[Len(aCols)], "" )
			ENDCASE
			
			DO CASE
				CASE nPerg01Tip == 1
					AADD( aCols[Len(aCols)], "OPR" )
				CASE nPerg01Tip == 2
					AADD( aCols[Len(aCols)], "MOV" )
				CASE nPerg01Tip == 3
					AADD( aCols[Len(aCols)], "INV" )
				OTHERWISE
					AADD( aCols[Len(aCols)], "" )
			ENDCASE

            // @history ticket 11639 - Fernando Macieira - 26/05/2021 - Projeto - OPS Documento de entrada - Industrializa็ใo/Beneficiamento
            aAdd( aCols[Len(aCols)], (cAliasT)->LOCAL )
            aAdd( aCols[Len(aCols)], (cAliasT)->PRODUCAO )
            //

			AADD( aCols[Len(aCols)], .F. )

			AADD( aAux,	{ (cAliasT)->REC 	  } )
		    
			(cAliasT)->(dbSkip())
	
		EndDo
		
		U_FecArTMP(cAliasT)
		
	Else
		For z:=1 To 3
			cAliasT	:= GetNextAlias()
	
			ADEDA007RF(@cAliasT, z)
			
			(cAliasT)->(dbGoTop())
		
			Do While !(cAliasT)->(Eof())
				DO CASE
					CASE (cAliasT)->STATUS == "I"
						xCor := oGreen
					CASE (cAliasT)->STATUS == "S"
						xCor := oBlue
					CASE (cAliasT)->STATUS == "E"
						xCor := oRed
					OTHERWISE
						xCor := oGray
				ENDCASE
				
				//TcSetConn(_nTcConn1)	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA
				
				cDescri := ""
				SB1->(DbSetOrder(1))
				If SB1->(DbSeek( xFilial("SB1") + Padr((cAliasT)->PRODUTO, TamSx3("B1_COD")[1]) ))
					cDescri := SB1->B1_DESC
				EndIf
				
				//TcSetConn(_nTcConn2)	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA
				
				AADD(aCols,	{	xCor				,;
								.F.                 ,;
								(cAliasT)->FILIAL	,;
			   		   			(cAliasT)->PRODUTO	,;
			   		   			cDescri				,;
			   					(cAliasT)->QUANT	,;
			  					(cAliasT)->DATA		,;
			  					(cAliasT)->MSEXP	  })
			 	
			 	DO CASE
					CASE (cAliasT)->STATUS == "I"
						AADD( aCols[Len(aCols)], "Integrado" )
					CASE (cAliasT)->STATUS == "S"
						AADD( aCols[Len(aCols)], "Processado" )
					CASE (cAliasT)->STATUS == "E"
						AADD( aCols[Len(aCols)], "Erro" )
					OTHERWISE
						AADD( aCols[Len(aCols)], "" )
				ENDCASE
			 	
			 	DO CASE
					CASE (cAliasT)->OPERACAO == "I"
						AADD( aCols[Len(aCols)], "Inclusใo" )
					CASE (cAliasT)->OPERACAO == "A"
						AADD( aCols[Len(aCols)], "Altera็ใo" )
					CASE (cAliasT)->OPERACAO == "E"
						AADD( aCols[Len(aCols)], "Exclusใo" )
					OTHERWISE
						AADD( aCols[Len(aCols)], "" )
				ENDCASE
				
				DO CASE
					CASE z == 1
						AADD( aCols[Len(aCols)], "OPR" )
					CASE z == 2
						AADD( aCols[Len(aCols)], "MOV" )
					CASE z == 3
						AADD( aCols[Len(aCols)], "INV" )
					OTHERWISE
						AADD( aCols[Len(aCols)], "" )
				ENDCASE

                // @history ticket 11639 - Fernando Macieira - 26/05/2021 - Projeto - OPS Documento de entrada - Industrializa็ใo/Beneficiamento
                aAdd( aCols[Len(aCols)], (cAliasT)->LOCAL )
                aAdd( aCols[Len(aCols)], (cAliasT)->PRODUCAO )
                //

				AADD( aCols[Len(aCols)], .F. )
				
				AADD( aAux,	{ (cAliasT)->REC 	  } )
			    
				(cAliasT)->(dbSkip())
		
			EndDo
			
			U_FecArTMP(cAliasT)
		Next z
	EndIf
	
    If Len(aCols) < 1
    
    	MsgAlert("Nใo foram encontrados itens para o filtro feito")

		xCor := oGray
		AADD(aCols,	{	xCor,;
						.F. ,;
						""	,;
						""	,;
	   		   			""	,;
						""	,;
						""	,;
	  					""	  })
		AADD( aCols[Len(aCols)], "" )
		AADD( aCols[Len(aCols)], "" )
		AADD( aCols[Len(aCols)], "" )
		AADD( aCols[Len(aCols)], "" )
		AADD( aCols[Len(aCols)], "" )
		AADD( aCols[Len(aCols)], .T. )

	EndIf
	
	mv_par01 := nPerg01Tip // Tabela
	mv_par02 := dPerg02Dta // Perํodo De
	mv_par03 := dPerg03Dta // Perํodo Ate
	mv_par04 := cPerg04Pdt // Produto De
	mv_par05 := cPerg05Pdt // Produto Ate
	mv_par06 := cPerg06Sta // Status
	mv_par07 := cPerg07Ope // Tipo de Opera็ใo
	mv_par08 := cPerg08Prd // Produ็ใo (Pr๓pria/Terceiro) // @history ticket 11639 - Fernando Macieira - 26/05/2021 - Projeto - OPS Documento de entrada - Industrializa็ใo/Beneficiamento


Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADEDA007D บAutor  ณMicrosiga           บ Data ณ  01/12/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Visualiza Log das tabelas OPR, MOV e INV                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ADEDA007R                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ADEDA007D

Local oDlg
Local oTcBrowse
Local aValues 	:= {}
Local cAlias 	:= GetNextAlias()
Local cAcao		:= ""

/*
TcConType("TCPIP")
If (_nTcConn1 := TcLink(_cNomBco1,_cSrvBco1,_cPortBco1))<0
	_lRet     := .F.
	cMsgError := "Nใo foi possํvel  conectar ao banco Protheus"
	MsgInfo("Nใo foi possํvel  conectar ao banco produ็ใo, verifique com administrador","ERROR")	
EndIf

If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2))<0
	_lRet     := .F.
	cMsgError := "Nใo foi possํvel  conectar ao banco integra็ใo"
	MsgInfo("Nใo foi possํvel  conectar ao banco integra็ใo, verifique com administrador","ERROR")	
EndIf
*/

//TcSetConn(_nTcConn1)	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA

BeginSql Alias cAlias
	SELECT ZA1_FILIAL, ZA1_TABELA, ZA1_ACAO, (SUBSTRING(ZA1_DATA,7,2)+'/'+SUBSTRING(ZA1_DATA,5,2)+'/'+SUBSTRING(ZA1_DATA,1,4)) AS ZA1_DAT, ZA1_HORA, ZA1_MENSAG, ZA1_USER
	FROM ZA1010 ZA1 (NOLOCK)
	WHERE ZA1.%notDel%
	AND ZA1_TABELA IN ('OPR', 'MOV', 'INV')	
	ORDER BY ZA1_DATA DESC, ZA1_HORA DESC
EndSql

Do While !(cAlias)->(Eof())
	DO CASE
		CASE (cAlias)->ZA1_ACAO == "I"
			cAcao := "Inclusใo"
		CASE (cAlias)->ZA1_ACAO == "A"
			cAcao := "Altera็ใo"
		CASE (cAlias)->ZA1_ACAO == "E"
			cAcao := "Exclusใo"
		CASE (cAlias)->ZA1_ACAO == "P"
			cAcao := "Processamento"
		OTHERWISE
			cAcao := ""
	ENDCASE
	
	AADD(aValues,{	(cAlias)->ZA1_FILIAL		 ,;
   		   			(cAlias)->ZA1_TABELA		 ,;
   					cAcao						 ,;
  					(cAlias)->ZA1_DAT			 ,;
 					(cAlias)->ZA1_HORA			 ,;
 					ALLTRIM((cAlias)->ZA1_MENSAG),;
 					(cAlias)->ZA1_USER 			   })
	(cAlias)->(DbSkip())
EndDo
	
DEFINE MSDIALOG oDlg FROM  0,0 TO 520,970 TITLE OemToAnsi("Tela de Logs") PIXEL

	oTcBrowse := TCBrowse():New(000,000,000,000,/*bLine*/,{'FILIAL', 'TABELA', 'ACAO', 'DATA', 'HORA', 'MENSAGEM', 'USUARIO'},/*aColsSpace*/,oDlg,,,,/*bChange*/,/*bLDblClick*/,/*bRClick*/,/*oFont*/,,,,,,,.T.,/*bWhen*/,,/*bValid*/,.T.,.T.)
	oTcBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oTcBrowse:SetArray(aValues)
	oTcBrowse:bLine := {|| {aValues[oTcBrowse:nAt,1], aValues[oTcBrowse:nAt,2], aValues[oTcBrowse:nAt,3], aValues[oTcBrowse:nAt,4], aValues[oTcBrowse:nAt,5], aValues[oTcBrowse:nAt,6], aValues[oTcBrowse:nAt,7]} }
	oTcBrowse:GoTop()
	oTcBrowse:SetFocus()
	
ACTIVATE MSDIALOG oDlg CENTERED	


Return









/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณADEDA007RE  บAutor  ณCCSKF				    บ Data ณ04/06/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para validacao do SX1 da rotina                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAdoro                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ADEDA007RE(cPerg,aPergunte)

Local lRet				:= .T.
Local ni				:= 0

	//Gravar variaveis no grupo de perguntas do SX1
	__SaveParam(cPerg,@aPergunte)	
	//Reinicializar as perguntas
	ResetMVRange()
	For ni := 1 to Len(aPergunte)
		//Inicializar as perguntas c/ array caso existam diferencas, para as validacoes
		Do Case
			Case AllTrim(aPergunte[ni][POS_X1OBJ]) == "C"
				aPergunte[ni][POS_X1VAL] := &(aPergunte[ni][POS_X1VAR])
			Otherwise
				&(aPergunte[ni][POS_X1VAR]) := aPergunte[ni][POS_X1VAL]
		EndCase
		//Definir a variavel corrente como sendo o parametro a validar, para aquelas validacoes que utilizar a variavel de campo posicionado
		__ReadVar := aPergunte[ni][POS_X1VAR]
		//Executar validacao
		If !Eval(&("{|| " + aPergunte[ni][POS_X1VLD] + "}"))
			MsgAlert(cNomeUs + ", inconsist๊ncia na pergunta " + StrZero(ni,2) + " (" + StrTran(AllTrim(Capital(aPergunte[ni][POS_X1DES])),"?","") + ")")
			Return !lRet
		Endif
	Next ni
	
	nPerg01Tip := mv_par01 // Tabela
	dPerg02Dta := mv_par02 // Perํodo De
	dPerg03Dta := mv_par03 // Perํodo Ate
	cPerg04Pdt := mv_par04 // Produto De
	cPerg05Pdt := mv_par05 // Produto Ate
	cPerg06Sta := mv_par06 // Status
	cPerg07Ope := mv_par07 // Tipo de Opera็ใo
	cPerg08Prd := mv_par08 // Produ็ใo (Pr๓pria/Terceiro) // @history ticket 11639 - Fernando Macieira - 26/05/2021 - Projeto - OPS Documento de entrada - Industrializa็ใo/Beneficiamento

	oBot01:Show()
	oBot02:Show()

	If cPerg06Sta  == 1
		oBot02:Hide()
	ElseIf cPerg06Sta  == 2
		oBot01:Hide()
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADEDA007RF  บAutor  ณMicrosiga         บ Data ณ  12/15/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณQuery do relat๓rio                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณADEDA007R                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ADEDA007RF(cAliasT, nOpc)

	Local cCampos 	:= "*"
	Local cSTATUS 	:= ""
	Local cOPERACAO	:= ""
	Local cPrdPTA   := "A" // @history ticket 11639 - Fernando Macieira - 26/05/2021 - Projeto - OPS Documento de entrada - Industrializa็ใo/Beneficiamento

	/*
	TcConType("TCPIP")
	If (_nTcConn1 := TcLink(_cNomBco1,_cSrvBco1,_cPortBco1))<0
		_lRet     := .F.
		cMsgError := "Nใo foi possํvel  conectar ao banco Protheus"
		MsgInfo("Nใo foi possํvel  conectar ao banco produ็ใo, verifique com administrador","ERROR")	
	EndIf

	If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2))<0
		_lRet     := .F.
		cMsgError := "Nใo foi possํvel  conectar ao banco integra็ใo"
		MsgInfo("Nใo foi possํvel  conectar ao banco integra็ใo, verifique com administrador","ERROR")	
	EndIf
	*/
	//TcSetConn(_nTcConn2)	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA

	DO CASE
		CASE cPerg06Sta == 1
			cSTATUS := "I"
		CASE cPerg06Sta == 2
			cSTATUS := "S"
		OTHERWISE
			cSTATUS := "E"
	ENDCASE

	DO CASE
		CASE cPerg07Ope == 1
			cOPERACAO := "I"
		CASE cPerg07Ope == 2
			cOPERACAO := "A"
		OTHERWISE
			cOPERACAO := "E"
	ENDCASE

	// @history ticket 11639 - Fernando Macieira - 26/05/2021 - Projeto - OPS Documento de entrada - Industrializa็ใo/Beneficiamento
	If cPerg08Prd == 1 // produ็ใo PRำPRIA
		cPrdPTA := "P"
	ElseIf cPerg08Prd == 2 // produ็ใo TERCEIROS
		cPrdPTA := "T"
	EndIf
	//

	If nOpc == 1

		// @history ticket 11639 - Fernando Macieira - 27/05/2021 - Projeto - OPS Documento de entrada - Industrializa็ใo/Beneficiamento
		If cPerg08Prd == 1 // produ็ใo = PROPRIO
		
			BeginSQL Alias cAliasT

				//SELECT FILIAL, PRODUTO, QUANT, (SUBSTRING(DATA,7,2)+'/'+SUBSTRING(DATA,5,2)+'/'+SUBSTRING(DATA,1,4)) AS DATA, MSEXP, STATUS, OPERACAO, REC
				SELECT FILIAL, PRODUTO, QUANT, (SUBSTRING(DATA,7,2)+'/'+SUBSTRING(DATA,5,2)+'/'+SUBSTRING(DATA,1,4)) AS DATA, MSEXP, STATUS, OPERACAO, REC, LOCAL, PRODUCAO // @history ticket 11639 - Fernando Macieira - 26/05/2021 - Projeto - OPS Documento de entrada - Industrializa็ใo/Beneficiamento
						
				FROM OPR010 (NOLOCK)
				
				WHERE DATA BETWEEN %Exp:dPerg02Dta% AND %Exp:dPerg03Dta%
					AND PRODUTO BETWEEN %Exp:cPerg04Pdt% AND %Exp:cPerg05Pdt%
					AND STATUS = %Exp:cSTATUS%
					AND OPERACAO = %Exp:cOPERACAO%  
					AND PRODUCAO = %Exp:cPrdPTA%
					AND QUANT>0
					AND D_E_L_E_T_=' '
			EndSQL

		ElseIf cPerg08Prd == 2 // produ็ใo = TERCEIROS
		
			BeginSQL Alias cAliasT

				//SELECT FILIAL, PRODUTO, QUANT, (SUBSTRING(DATA,7,2)+'/'+SUBSTRING(DATA,5,2)+'/'+SUBSTRING(DATA,1,4)) AS DATA, MSEXP, STATUS, OPERACAO, REC
				SELECT FILIAL, PRODUTO, QUANT, (SUBSTRING(DATA,7,2)+'/'+SUBSTRING(DATA,5,2)+'/'+SUBSTRING(DATA,1,4)) AS DATA, MSEXP, STATUS, OPERACAO, REC, LOCAL, PRODUCAO // @history ticket 11639 - Fernando Macieira - 26/05/2021 - Projeto - OPS Documento de entrada - Industrializa็ใo/Beneficiamento
						
				FROM OPR010 (NOLOCK)
				
				WHERE DATA BETWEEN %Exp:dPerg02Dta% AND %Exp:dPerg03Dta%
					AND PRODUTO BETWEEN %Exp:cPerg04Pdt% AND %Exp:cPerg05Pdt%
					AND STATUS = %Exp:cSTATUS%
					AND OPERACAO = %Exp:cOPERACAO%  
					AND PRODUCAO = %Exp:cPrdPTA%
					AND QUANT>0
					AND D_E_L_E_T_=' '
			EndSQL

		Else

			BeginSQL Alias cAliasT

				SELECT FILIAL, PRODUTO, QUANT, (SUBSTRING(DATA,7,2)+'/'+SUBSTRING(DATA,5,2)+'/'+SUBSTRING(DATA,1,4)) AS DATA, MSEXP, STATUS, OPERACAO, REC, LOCAL, PRODUCAO
				FROM OPR010 (NOLOCK)
				WHERE DATA BETWEEN %Exp:dPerg02Dta% AND %Exp:dPerg03Dta%
					AND PRODUTO BETWEEN %Exp:cPerg04Pdt% AND %Exp:cPerg05Pdt%
					AND STATUS = %Exp:cSTATUS%
					AND OPERACAO = %Exp:cOPERACAO%  
					AND QUANT>0
					AND D_E_L_E_T_=' '
			EndSQL

		EndIf
		
	ElseIf nOpc == 2

		BeginSQL Alias cAliasT

			SELECT FILIAL, TM, PRODUTO, QUANT, (SUBSTRING(DATA,7,2)+'/'+SUBSTRING(DATA,5,2)+'/'+SUBSTRING(DATA,1,4)) AS DATA, LOTEEDATA, MSEXP, STATUS, OPERACAO, REC, '' LOCAL, '' PRODUCAO
					
			FROM MOV010 (NOLOCK)

			WHERE DATA BETWEEN %Exp:dPerg02Dta% AND %Exp:dPerg03Dta%
				AND PRODUTO BETWEEN %Exp:cPerg04Pdt% AND %Exp:cPerg05Pdt%
				AND STATUS = %Exp:cSTATUS%
				AND OPERACAO = %Exp:cOPERACAO%
				AND QUANT>0
				AND D_E_L_E_T_=' '
		EndSQL
		
	ElseIf nOpc == 3

		BeginSQL Alias cAliasT

			SELECT FILIAL, PRODUTO, QUANT, (SUBSTRING(DATA,7,2)+'/'+SUBSTRING(DATA,5,2)+'/'+SUBSTRING(DATA,1,4)) AS DATA, MSEXP, STATUS, OPERACAO, REC, '' LOCAL, '' PRODUCAO
					
			FROM INV010 (NOLOCK)
			
			WHERE DATA BETWEEN %Exp:dPerg02Dta% AND %Exp:dPerg03Dta%
				AND PRODUTO BETWEEN %Exp:cPerg04Pdt% AND %Exp:cPerg05Pdt%
				AND STATUS = %Exp:cSTATUS%
				AND OPERACAO = %Exp:cOPERACAO%
				AND QUANT>0
				AND D_E_L_E_T_=' '
		EndSQL

	EndIf

Return cAliasT

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณADEDA007G  บAutor  ณCCSKF				    บ Data ณ04/06/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para validacao do SX1 da rotina                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAdoro                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ADEDA007G(nOpc,aDados,oGDSel,nColSel,aHead)

    Local ni		:= 0
    Local cRoteiro	:= ""

    If nColSel == 2
        For ni := 1 to Len(aDados)
            //If !Empty(aDados[ni][5]) .AND. !aDados[ni][12]
            If !Empty(aDados[ni][5]) .AND. !aDados[ni][14]
                aDados[ni][2] := !aDados[ni][2]
            EndIf
        Next ni
    EndIf

    //Forcar a atualizacao do browse
    oGDSel:DrawSelect()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออษออออออออออัอออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณADEDA007RH    			บAutor  					ณLeonardo Rios		   					บ Data ณ  27/04/17   	ฐฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออฬออออออออออุออออออออออสอออออออฯอออออออออออออออฬออออออออออุออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo executada ao clicar no botใo 'Estorno' para validar as linhas selecionadas antes e processar o estorno 		บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออออฯออออออออออออออออออฯออออออออออออออออออฯออออออออออออออนฑฑ
ฑฑณParโmetrosณ aParam[1]  	:[A] aCols    	- Array que contem os dados apresentados em tela para verificar quais foram selecionadosณฑฑ
ฑฑณ			 ณ aParam[2]  	:[A] aAux       - Array auxiliar ao aCols que cont้m os valores do campo RECNO dos dados 				ณฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออออฯออออออออออออออออออฯออออออออออออออออออฯออออออออออออออนฑฑ
ฑฑบRetorno   ณ lRet[L] - Array contendo os nomes dos campos da query que serใo utilizados no preenchimento do grid					ณฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออออฯออออออออออออออออออฯออออออออออออออออออฯออออออออออออออนฑฑ
ฑฑบUso       ณADEDA007R - Tela de interface Protheus x Edata 																		ณฑฑ
ฑฑบ		     ณM๓dulo Estoque/Custos (04)		                          															บฑฑ
ฑฑบ		     ณProjeto Protheus x Edata			                          															บฑฑ
ฑฑบ		     ณAdoro 					                          		  															บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออฯออออออออออออออออออฯออออออออออออออออออฯอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ADEDA007RH(aCols, aAux)

	Local aOPR		:= {}
	Local aMOV		:= {}
	Local aINV		:= {}
	Local aArrays 	:= {}
	Local cMsg		:= ""
	Local lRet		:= .F.
	Local cMsgLog	:= ""
	Local cTabela	:= ""
	Local x,y

	Private _MsgMotivo := ""


		/*BEGINDOC
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณExemplo da estrutura dos arrays aOPR, aMOV e aINV ณ
		//ณaOPR[a]          								 ณ
		//ณ   aCols[a,1]    								 ณ
		//ณ       cor 		[a,1, 1]						 ณ
		//ณ       checkbox 	[a,1, 2]						 ณ
		//ณ       filial 	[a,1, 3]						 ณ
		//ณ       produto   [a,1, 4]						 ณ
		//ณ       produto   [a,1, 5]						 ณ
		//ณ       quantidade[a,1, 6]						 ณ
		//ณ       dt emissao[a,1, 7]						 ณ
		//ณ       msexp     [a,1, 8]						 ณ
		//ณ       status    [a,1, 9]						 ณ
		//ณ       operacao  [a,1,10]						 ณ
		//ณ       tipo      [a,1,11]						 ณ
		//ณ   aAux[a,2]     								 ณ
		//ณ       rec 		[a,2, 1]						 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		ENDDOC*/
		For x:=1 To Len(aCols)
			//If aCols[x,2] .AND. !aCols[x,12]
            If aCols[x,2] .AND. !aCols[x,14]
				If aCols[x,11] == "OPR"
					AADD(aOPR, { aCols[x], aAux[x] } )
				ElseIf aCols[x,11] == "MOV"
					AADD(aMOV, { aCols[x], aAux[x] } )
				Else
					AADD(aINV, { aCols[x], aAux[x] } )
				EndIf
			EndIf
		Next x
		
		If Len(aOPR) < 1 .AND. Len(aMOV) < 1 .AND. Len(aINV) < 1
			MsgAlert("Nใo existem itens selecionados para serem processados o estorno deles")
			Return .F.
		EndIf

		aArrays := {aOPR, aMOV, aINV}
		cMsgLog := ""
		For x:=1 To Len(aArrays) 
			For y:=1 To Len(aArrays[x])
			
				If aArrays[x,y,1,9] == "Processado" .AND. !EMPTY( ALLTRIM( aArrays[x,y,1,8] ) )

					cMsg := "FILIAL=" + ALLTRIM(aArrays[x,y,1,3]) + "; PRODUTO=" + ALLTRIM(aArrays[x,y,1,4]) + "; DESCRI=" + ALLTRIM(aArrays[x,y,1,5]) +;
							"; QUANTIDADE=" + ALLTRIM( STR(aArrays[x,y,1,6]) ) + "; RECEDATA=" + ALLTRIM( StrZero(aArrays[x,y,2,1], 10) ) + "; " + "MOTIVO="

					//TcSetConn(_nTcConn1)	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA

					/* Condi็ใo criada para garantir que apenas itens que jแ foram processados e estejam com o campo igual a 'S' sejam estornados */
					// If ALLTRIM( aArrays[x,y,1,9] ) <> "S"
					// 	LOOP
					// EndIf

					If x == 1
					
						U_CCSGrvLog(cMsgIni+cMsg, "OPR", aArrays[x,y,2,1], 6, aArrays[x,y,1,3], .T.)
						
						/*
							ADEDA003P(nRec, lExclui)
						*/
						lRet := U_ADEDA003P( aArrays[x,y,2,1], .T. )
						//TcSetConn(_nTcConn1)	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA
						cTabela := "OPR010"
							
						U_CCSGrvLog(cMsgFim+cMsg+_MsgMotivo, "OPR", aArrays[x,y,2,1], 6, aArrays[x,y,1,3], .T.)

					ElseIf x == 2

						U_CCSGrvLog(cMsgIni+cMsg, "MOV", aArrays[x,y,2,1], 6, aArrays[x,y,1,3], .T.)
						
						/*
							ADEDA005P(nRec)
						*/
						lRet := U_ADEDA005P( aArrays[x,y,2,1], .T. ) //nRec
						//TcSetConn(_nTcConn1)	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA
						cTabela := "MOV010"
						
						U_CCSGrvLog(cMsgFim+cMsg+_MsgMotivo, "MOV", aArrays[x,y,2,1], 6, aArrays[x,y,1,3], .T.)

					Else
						
						U_CCSGrvLog(cMsgIni+cMsg, "INV", aArrays[x,y,2,1], 6, aArrays[x,y,1,3], .T.)
						
						/*
							U_ADEDA006P(nRec, lInclui)
						*/
						lRet := U_ADEDA006P( aArrays[x,y,2,1], .F., .T. ) 
						//TcSetConn(_nTcConn1)	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA
						cTabela := "INV010"
						
						U_CCSGrvLog(cMsgFim+cMsg+_MsgMotivo, "INV", aArrays[x,y,2,1], 6, aArrays[x,y,1,3], .T.)
					
					EndIf
					
					MsUnlockAll()
					
					If !lRet
						cMsgLog += " - Problema no estorno do item: " + cMsg + _MsgMotivo + CHR(13) + CHR(10)
					Else
						//TcSetConn(_nTcConn2)	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA
						TcSqlExec("UPDATE " + cTabela + " SET D_E_L_E_T_='*' WHERE REC = " + ALLTRIM( StrZero(aArrays[x,y,2,1], 10) ) )	
					EndIf
					
					lRet := .F.
				EndIf
			Next y
		Next x

		MsUnlockAll()
		
		//TcSetConn(_nTcConn2)		// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revisใo das integra็๕es e gera็ใo das OPS - Banco DBINTEREDATA
				
		cMens := "Todos os itens selecionados foram processados! Verifique o log clicando no botใo 'Log'" + CHR(13) + CHR(10)
		cMens +=  CHR(13) + CHR(10) + cMsgLog

		U_ExTelaMen("Estorno dos itens",cMens,"Arial",10,,.F.,.T.)		
	
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLegenda   บAutor  ณMicrosiga           บ Data ณ  12/22/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLegenda das cores                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณADEDA007R                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Legenda()

    Local aLegenda := {}
    
    AADD(aLegenda,{"BR_VERDE"   	,"Integrado" 		}) 
    AADD(aLegenda,{"BR_AZUL"    	,"Processado" 		})
    AADD(aLegenda,{"BR_VERMELHO"	,"Erro" 			})
    AADD(aLegenda,{"BR_CINZA"   	,"Status Indefinido"})
    
    BrwLegenda("Legenda", "Legenda", aLegenda)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณAjustaSX1 บAutor  ณLeonardo Rios    บ Data ณ24/09/2014   	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.    ณInsere novas perguntas ao sx1 para a tela de perguntas da    บฑฑ
ฑฑบ         ณfuncionalidade de corre็ใo financeira na devolu็ใo de vendas บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSX1(cPerg)

    Local aMensSX1 := {}

//					  1				2						3						4				  5			6						  7	 8		  9   10	 11	   		12  		13	  	  	  14  	  15  	 16  	 		17   	  		18   	  	  19  	  20  21  	  	  22  	  	 23  	  	  24  25  26  		27  	28  	  29  30  31  32  33  34  35      36   37  38  39	
    AADD( aMensSX1, {"01", "Tipo?"				, "Tipo?"				, "Tipo?"					,"N"	,001						,00, 0		,"C", ""	,"OPR"		,"OPR" 		,"OPR"		, ""	, ""	, "MOV"			, "MOV" 	 , "MOV"		, ""	, "", "INV"		, "INV"		, "INV" 	, "", "", "Todos", "Todos", "Todos"	, "", "", "", "", "", "", ""    , "S", "", "", "" })
    AADD( aMensSX1, {"02", "Perํodo De?"		, "Perํodo De?"			, "Perํodo De?"				,"D"	,008						,00, 0		,"G", ""	,""			,""			,"" 		, ""	, ""	, ""			, "" 		 , "" 			, ""	, "", ""		, ""		, ""		, "", "", ""	 , ""	  , ""		, "", "", "", "", "", "", ""    , "S", "", "", "" })
	AADD( aMensSX1, {"03", "Perํodo Ate?"		, "Perํodo Ate?"		, "Perํodo Ate?"	    	,"D"	,008						,00, 0		,"G", ""	,""			,""			,""			, ""	, ""	, ""			, "" 		 , "" 			, ""	, "", ""		, ""		, ""		, "", "", ""	 , ""	  , ""		, "", "", "", "", "", "", ""    , "S", "", "", "" })
	AADD( aMensSX1, {"04", "Produto De?"		, "Produto De?"	    	, "Produto De?"		   		,"C"	,TamSX3("B1_COD")[1]		,00, 0		,"G", ""	,""			,""			,"" 		, ""	, ""	, ""			, "" 		 , "" 			, ""	, "", ""		, ""		, ""		, "", "", ""	 , ""	  , ""		, "", "", "", "", "", "", "SB1" , "S", "", "", "" })
	AADD( aMensSX1, {"05", "Produto Ate?"		, "Produto Ate?"		, "Produto Ate?"			,"C"	,TamSX3("B1_COD")[1]		,00, 0		,"G", ""	,""			,""			,"" 		, ""	, ""	, ""			, "" 	 	 , "" 			, ""	, "", ""		, ""		, ""		, "", "", ""	 , ""	  , ""		, "", "", "", "", "", "", "SB1" , "S", "", "", "" })
	AADD( aMensSX1, {"06", "Status?"			, "Status?"				, "Status?"	    			,"C"	,001						,00, 0		,"C", ""	,"Integrado","Integrado","Integrado", ""	, ""	, "Processado" 	,"Processado", "Processado"	, ""	, "", "Erro"	, "Erro"	, "Erro"	, "", "", ""	 , ""	  , ""		, "", "", "", "", "", "", ""    , "S", "", "", "" })
	AADD( aMensSX1, {"07", "Opera็ใo?"			, "Opera็ใo?"			, "Lista Cแlculo ?"	    	,"C"	,001						,00, 0		,"C", ""	,"Inclusใo"	,"Inclusใo"	,"Inclusใo"	, ""	, ""	, "Altera็ใo" 	,"Altera็ใo" , "Altera็ใo"	, ""	, "", "Exclusใo", "Exclusใo", "Exclusใo", "", "", ""	 , ""	  , ""		, "", "", "", "", "", "", ""    , "S", "", "", "" })
	AADD( aMensSX1, {"08", "Produ็ใo?"			, "Produ็ใo?"			, "Produ็ใo?"	    	    ,"C"	,001						,00, 0		,"C", ""	,"Pr๓pria"	,"Pr๓pria"	,"Pr๓pria"	, ""	, ""	, "Terceiro" 	,"Terceiro"  , "Terceiro"	, ""	, "", "Ambos"   , "Ambos"   , "Ambos"   , "", "", ""	 , ""	  , ""		, "", "", "", "", "", "", ""    , "S", "", "", "" }) // @history ticket 11639 - Fernando Macieira - 26/05/2021 - Projeto - OPS Documento de entrada - Industrializa็ใo/Beneficiamento

    U_newGrSX1(cPerg, aMensSX1)

Return
