#include "protheus.ch"
#include "rwmake.ch"

/*/{Protheus.doc} User Function F240GAVE
Ponto de entrada que permite a manipulação dos dados de filtro para montagem do borderô
@type  Function
@author Abel Babini
@since 04/01/2021
@history Ticket   4883 - Abel Babini - 04/01/2021 - Geração de borderôs automática
@history Ticket   4883 - Abel Babini - 05/01/2021 - Correção para execução da rotina de borderô manual
@history Ticket 70142   - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/

User Function F240GAVE()
	Local aTemp := aClone(ParamIxb)

	Local _nPort	:= FWTamSX3("EA_PORTADO")[1]
	Local _nAgen	:= FWTamSX3("EA_AGEDEP")[1]
	Local _nNCon	:= FWTamSX3("EA_NUMCON")[1]
	Local _nNCtr	:= FWTamSX3("EE_NUMCTR")[1]

	//INICIO Ticket   4883 - Abel Babini - 05/01/2021 - Correção para execução da rotina de borderô manual
	Local lJFilBco      := SuperGetMv( "MV_JFILBCO", .F., .F. ) .And. FindFunction("JURF3SA6") .And. FindFunction("JurVldSA6") //Indica se filtra as contas correntes vinculadas ao escritório logado - SIGAPFS.
	Local cEscrit       := Iif(lJFilBco, JurGetDados("NS7", 4, xFilial("NS7") + cFilant + cEmpAnt, "NS7_COD"), "") // Código do escritório relacionado a filial logada - SIGAPFS.
	Local cF3Bco        := Iif(lJFilBco, "SA6JUR", "SA6")
	Local cContrato		:= CriaVar("E9_NUMERO")
	Local cMoeda240		:= ""
	Local cVar 			:= ""
	//Local aMoedas 		:= STATIC CALL(FINA240,GetMoedas)
	//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	Local aMoedas 		:= u_40GAVEA0()
	Local lBlqBor		:= .T.

	cMoeda240 := cVar := aMoedas[1]
	//FIM Ticket   4883 - Abel Babini - 05/01/2021 - Correção para execução da rotina de borderô manual

	IF FWIsInCallStack("xAutBor")
		nExecBor	+= 1
		aTemp[2]	:= dDtBordI																	//Período de
		aTemp[3]	:= dDtBordF 																//Período até
		aTemp[4]	:= aBACBord[nItBAC,8]
		aTemp[5]	:= Alltrim(aBACBord[nItBAC,5]) + Space(_nPort - Len( Alltrim(aBACBord[nItBAC,5])))         	//Banco
		aTemp[6]	:= Alltrim(aBACBord[nItBAC,6]) + Space(_nAgen - Len( Alltrim(aBACBord[nItBAC,6])))       	 	//Agência
		aTemp[7]	:= Alltrim(aBACBord[nItBAC,7]) + Space(_nNCon - Len( Alltrim(aBACBord[nItBAC,7])))   				//conta
		aTemp[8]	:= Space(_nNCtr)   												//contrato
		// aTemp[10]:= nil
		aTemp[11]	:= Alltrim(aBACBord[nItBAC,2])           	//Modo de Pagamento
		aTemp[12]	:= Alltrim(aBACBord[nItBAC,3])           	//Tipo de Pagamento
		
		//Controle de Execução quando não tiver títulos
		IF nExecBor > 1
			aTemp[13]	:= 2              													//nOpc
		ELSE
			aTemp[13]	:= 1              													//nOpc
		ENDIF

		AADD(aTemp,dDataBase)																//Data do Bordero (Posição 14 do array)

	ELSE //INICIO Ticket   4883 - Abel Babini - 05/01/2021 - Correção para execução da rotina de borderô manual
		aSize := MSADVSIZE()
		nEspLarg := 2
		nEspLin  := 2
		DEFINE MSDIALOG oDlg FROM  15,6 TO 219,404 TITLE OemToAnsi("Borderôs de Pagamentos") PIXEL  //"Border“s de Pagamentos"
		oDlg:lMaximized := .F.
		oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20)
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT

		@ 00+nEspLin, nEspLarg TO 29+nEspLin, 196+nEspLarg OF oPanel  PIXEL
		@ 34+nEspLin, nEspLarg TO 63+nEspLin, 196+nEspLarg OF oPanel  PIXEL
		@ 68+nEspLin, nEspLarg TO 97+nEspLin, 196+nEspLarg OF oPanel  PIXEL

		nEspLarg := nEspLarg -1

		@ 06+nEspLin, 009+nEspLarg SAY OemToAnsi("Número")	   SIZE 23, 7 OF oPanel PIXEL
		@ 06+nEspLin, 045+nEspLarg SAY OemToAnsi("Vencto de")		SIZE 32, 7 OF oPanel PIXEL
		@ 06+nEspLin, 090+nEspLarg SAY OemToAnsi("Até")		SIZE 32, 7 OF oPanel PIXEL
		@ 06+nEspLin, 135+nEspLarg SAY OemToAnsi("Limite Valor")		SIZE 53, 7 OF oPanel PIXEL
		@ 40+nEspLin, 009+nEspLarg SAY OemToAnsi("Banco")		SIZE 23, 7 OF oPanel PIXEL
		@ 40+nEspLin, 045+nEspLarg SAY OemToAnsi("Agência")		SIZE 32, 7 OF oPanel PIXEL
		@ 40+nEspLin, 085+nEspLarg SAY OemToAnsi("Conta")		SIZE 32, 7 OF oPanel PIXEL
		@ 40+nEspLin, 151+nEspLarg SAY OemToAnsi("Contrato")		SIZE 53, 7 OF oPanel PIXEL
		@ 73+nEspLin, 009+nEspLarg SAY OemToAnsi("Moeda")		SIZE 23, 7 OF oPanel PIXEL
		@ 73+nEspLin, 063+nEspLarg SAY OemToAnsi("Modelo")		SIZE 22, 7 OF oPanel PIXEL
		@ 73+nEspLin, 097+nEspLarg SAY OemToAnsi("Tipo Pagto")		SIZE 32, 7 OF oPanel PIXEL
		// IF ExistBlock("F240BOR")
		// 	lBlqBor:= ExecBlock("F240BOR",.F.,.F.,{lBlqBor})
		// Endif

		//Linha 1
		@ 15+nEspLin, 009+nEspLarg MSGET cNumBor         		SIZE 32, 10 OF oPanel PIXEL Picture "@!" Valid If(nOpc<>0,!Empty(cNumBor).And.FA240Num(cNumBor),.T.) when lBlqBor
		@ 15+nEspLin, 045+nEspLarg MSGET dVenIni240        	SIZE 45, 10 OF oPanel PIXEL HASBUTTON
		@ 15+nEspLin, 090+nEspLarg MSGET dVenFim240        	SIZE 45, 10 OF oPanel PIXEL HASBUTTON Valid   If(nOpc<>0,FA240DATA(dVenIni240,dVenFim240),.T.)
		@ 15+nEspLin, 135+nEspLarg MSGET nLimite         		SIZE 60, 10 OF oPanel PIXEL HASBUTTON Picture "@E 999,999,999,999.99"  Valid If(nOpc<>0,nLimite >= 0,.T.)
		//Linha 2
		@ 49+nEspLin,   9+nEspLarg MSGET cPort240        		SIZE 10, 10 OF oPanel PIXEL HASBUTTON Picture "@!" F3 cF3Bco Valid F240VldBco(@cPort240,@cAgen240,@cConta240) .And. Iif(lJFilBco, JurVldSA6("1", {cEscrit, cPort240, cAgen240, cConta240}), .T.)
		@ 49+nEspLin,  45+nEspLarg MSGET cAgen240        		SIZE 26, 10 OF oPanel PIXEL Picture "@!" Valid CarregaSA6(@cPort240,@cAgen240,,.T.)  .And. Iif(lJFilBco, JurVldSA6("2", {cEscrit, cPort240, cAgen240, cConta240}), .T.)
		@ 49+nEspLin,  85+nEspLarg MSGET cConta240       		SIZE 62, 10 OF oPanel PIXEL Picture "@!" Valid CarregaSA6(@cPort240,@cAgen240,@cConta240,.T.,,.T.) .And. Iif(lJFilBco, JurVldSA6("3", {cEscrit, cPort240, cAgen240, cConta240}), .T.)
		@ 49+nEspLin, 151+nEspLarg MSGET cContrato       		SIZE 42, 10 OF oPanel PIXEL Picture "@S3"

		//Linha 3
		@ 82+nEspLin, 009+nEspLarg MSCOMBOBOX oCbx VAR cMoeda240 ITEMS aMoedas SIZE 46, 13 OF oPanel PIXEL Valid F240VldMd(cPort240,cAgen240,cConta240,Val(cMoeda240))
		@ 82+nEspLin, 063+nEspLarg MSGET cModPgto        		SIZE 25, 10 OF oPanel PIXEL Picture "@!"  Valid If(nOpc<>0,ExistCpo("SX5", + "58" + cModPgto),.T.) F3 "58" HASBUTTON
		@ 82+nEspLin, 097+nEspLarg MSGET cTipoPag        		SIZE 25, 10 OF oPanel PIXEL Picture "@!"  Valid If(nOpc<>0,ExistCpo("SX5", + "59" + cTipoPag),.T.) F3 "59" HASBUTTON

		DEFINE SBUTTON FROM 83, 140 TYPE 1 ENABLE OF oPanel ACTION (cVar:=cMoeda240,nOpc:=1,Iif(F240TudoOk(oDlg),oDlg:End(),nOpc:=0))
		DEFINE SBUTTON FROM 83, 170 TYPE 2 ENABLE OF oPanel ACTION (aTemp[13]	:= 2, oDlg:End())

		ACTIVATE MSDIALOG oDlg CENTERED

		If nOpc == 1
			aTemp[1]	:= cNumBor
			aTemp[2]	:= dVenIni240																	//Período de
			aTemp[3]	:= dVenFim240 																//Período até
			aTemp[4]	:= nLimite
			aTemp[5]	:= cPort240         	//Banco
			aTemp[6]	:= cAgen240       	 	//Agência
			aTemp[7]	:= cConta240   				//conta
			aTemp[8]	:= cContrato   												//contrato
			aTemp[09]:= cMoeda240
			aTemp[10]:= aMoedas
			aTemp[11]	:= cModPgto           	//Modo de Pagamento
			aTemp[12]	:= cTipoPag           	//Tipo de Pagamento
			aTemp[13]	:= 1              													//nOpc

			AADD(aTemp,dDataBase)																//Data do Bordero (Posição 14 do array)
		Endif
		//FIM Ticket   4883 - Abel Babini - 05/01/2021 - Correção para execução da rotina de borderô manual
	EndIf

Return aTemp

/*/{Protheus.doc} u_40GAVEA0
Ticket 70142 - Substituicao de funcao Static Call por User Function MP 12.1.33
@type function
@version 1.0
@author Edvar   / Flek Solution
@since 16/03/2022
@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
Function u_40GAVEA0()
Return( GetMoedas() )

/*/{Protheus.doc} GetMoedas
Ticket 70142 - Substituicao de funcao Static Call por User Function MP 12.1.33
@type function
@version 1.0
@author Edvar   / Flek Solution
@since 16/03/2022
@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
Static Function GetMoedas()
	Local aRet     := {}
	Local aArea    := GetArea()
	Local aAreaSx6 := Sx6->(GetArea())
	Local cFilSx6

	// Inicializa array com as moedas existentes.
	GetMv("MV_MOEDA1")
	cFilSx6 := SX6->X6_FIL
	While Substr(SX6->X6_VAR,1,8) == "MV_MOEDA" .And. ;
			SX6->(!Eof()) .And. SX6->X6_FIL == cFilSx6
		If Substr(SX6->X6_VAR,9,1) != "P" .AND. Substr(SX6->X6_VAR,9,2) != "CM" // Desconsiderar plural e MV_MOEDACM
			Aadd( aRet, StrZero(Val(Substr(SX6->X6_VAR,9,2)),2) + " " + GetMv(SX6->X6_VAR) )
		Endif
		SX6->(DbSkip())
	EndDo
	ASort(aRet)
	Sx6->(RestArea(aAreaSx6))
	RestArea(aArea)

Return aRet
