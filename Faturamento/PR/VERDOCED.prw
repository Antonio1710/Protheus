#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"
#DEFINE GD_INSERT	1
#DEFINE GD_DELETE	4	
#DEFINE GD_UPDATE	2 

User Function VERDOCED()
                        
_dDtEntr := ddatabase
_cPlaca := space(7)
nOpc := 0
_cDocEdata := ""

//Static oDlg
Static oButtonOk
Static oCheckBoxFar
Static lCkBxFar := .F.
Static oCheckBoxLodo
Static lCkBxLodo := .F.
Static oCheckBoxOleo
Static lCkBxOleo := .F.
Static oCheckBoxOsso
Static lCkBxOsso := .F.
Static oCheckBoxSuc
Static lCkBxSuc := .F.
Static oDoc1
Static oDoc2
Static oDoc3
Static oDoc4
Static oDoc5
Static oDt1
Static oDt2
Static oDt3
Static oDt4
Static oDt5
Static oGetDt
Static cGetDt := ddatabase
Static oGetPlc
Static cGetPlc := space(7)
Static oGroup1
Static oGroup2
Static oGroup3
Static oRot1
Static oRot2
Static oRot3
Static oRot4
Static oRot5
Static oSay1
Static oSay2
Static oSay3
Static oSay4
Static oSay5    

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

  DEFINE MSDIALOG oDlg TITLE "Numero Documento Edata" FROM 000, 000  TO 340, 500 COLORS 0, 16777215 PIXEL

    @ 003, 004 GROUP oGroup1 TO 163, 250 PROMPT "Dados para Pesagem" OF oDlg COLOR 0, 16777215 PIXEL
    //@ 046, 015 GROUP oGroup2 TO 115, 147 PROMPT "Marque o Produto que será utilizado: " OF oDlg COLOR 0, 16777215 PIXEL
    @ 018, 017 SAY oSay1 PROMPT "Placa:" SIZE 021, 008 OF oDlg COLORS 0, 16777215 PIXEL
    @ 032, 017 SAY oSay2 PROMPT "Data de Entrega:" SIZE 046, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 016, 066 MSGET oGetPlc VAR cGetPlc SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 031, 066 MSGET oGetDt VAR cGetDt SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    /*
    @ 060, 021 CHECKBOX oCheckBoxFar VAR lCkBxFar PROMPT "Farinha" SIZE 029, 011 OF oDlg COLORS 0, 16777215 PIXEL
    @ 070, 021 CHECKBOX oCheckBoxOleo VAR lCkBxOleo PROMPT "Oleo" SIZE 045, 008 OF oDlg COLORS 0, 16777215 PIXEL
    @ 080, 021 CHECKBOX oCheckBoxOsso VAR lCkBxOsso PROMPT "Osso" SIZE 047, 012 OF oDlg COLORS 0, 16777215 PIXEL
    @ 090, 021 CHECKBOX oCheckBoxLodo VAR lCkBxLodo PROMPT "Lodo" SIZE 048, 008 OF oDlg COLORS 0, 16777215 PIXEL
    @ 100, 021 CHECKBOX oCheckBoxSuc VAR lCkBxSuc PROMPT "Sucata" SIZE 048, 008 OF oDlg COLORS 0, 16777215 PIXEL
    */
    @ 055, 015 GROUP oGroup3 TO 128, 240 PROMPT "Utilizar no Edata: " OF oDlg COLOR 0, 16777215 PIXEL
    @ 064, 022 SAY oSay3 PROMPT "Documento" SIZE 030, 007 OF oDlg COLORS 128, 16777215 PIXEL
    @ 064, 067 SAY oSay4 PROMPT "Dt Entrega" SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 064, 114 SAY oSay5 PROMPT "Roteiro" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 074, 022 SAY oDoc1 PROMPT " " SIZE 025, 007 OF oDlg COLORS 255, 16777215 PIXEL
    @ 084, 022 SAY oDoc2 PROMPT " " SIZE 025, 007 OF oDlg COLORS 255, 16777215 PIXEL
    @ 094, 022 SAY oDoc3 PROMPT " " SIZE 025, 007 OF oDlg COLORS 255, 16777215 PIXEL
    @ 105, 022 SAY oDoc4 PROMPT " " SIZE 025, 007 OF oDlg COLORS 255, 16777215 PIXEL
    @ 115, 022 SAY oDoc5 PROMPT " " SIZE 025, 007 OF oDlg COLORS 255, 16777215 PIXEL
    @ 074, 067 SAY oDt1 PROMPT " " SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 084, 067 SAY oDt2 PROMPT " " SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 094, 067 SAY oDt3 PROMPT " " SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 105, 067 SAY oDt4 PROMPT " " SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 115, 067 SAY oDt5 PROMPT " " SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 074, 114 SAY oRot1 PROMPT " " SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 084, 114 SAY oRot2 PROMPT " " SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 094, 114 SAY oRot3 PROMPT " " SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 105, 114 SAY oRot4 PROMPT " " SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 115, 114 SAY oRot5 PROMPT " " SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL 
    
    @ 142, 100 BUTTON oButtonOk PROMPT "Ok" SIZE 034, 013 OF oDlg ACTION (ExbDocED(cGetPlc,oGetDt)) PIXEL      
    
//DEFINE SBUTTON FROM (196),(040) TYPE 1 ENABLE OF _oDlg ACTION (_oDlg:End(),nOpc:=1)
//DEFINE SBUTTON FROM (196),(060) TYPE 2 ENABLE OF _oDlg ACTION (_oDlg:END())    
  ACTIVATE MSDIALOG oDlg CENTERED

Return

//Static Function ExbDocED(cGetPlc,oGetDt,lCkBxFar,lCkBxOleo,lCkBxOsso,lCkBxLodo,lCkBxSuc)
Static Function ExbDocED(cGetPlc,oGetDt)

//If nOpc == 1

	Close(oDlg)

	_cDocEdata := "" 

	IF SELECT("TMP0") > 0
		TMP0->( DBCLOSEAREA())
	ENDIF	

	cQuery := " SELECT " + RetSqlName("SC5") + ".R_E_C_N_O_ AS DOCEDT,C5_ROTEIRO, C6_ENTREG, SUBSTRING(C6_DESCRI,1,20) AS C6_DESCRI FROM " + RetSqlName("SC6")
	cQuery += " INNER JOIN " + RetSqlName("SC5") + " ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM "
	cQuery += " WHERE C6_ENTREG <= '" + DTOS(cGetDt) + "'"
	cQuery += " AND C6_ENTREG >= '" + DTOS(cGetDt-7) + "'"	
	cQuery += " AND " + RetSqlName("SC5")+ ".D_E_L_E_T_ <> '*' "
	cQuery += " AND " + RetSqlName("SC6")+ ".D_E_L_E_T_ <> '*' "
	cQuery += " AND C6_TES IN "
	cQuery += " (SELECT F4_CODIGO FROM " + RetSqlName("SF4")+ " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND F4_XTIPO = '2') "
	cQuery += " AND C6_FILIAL = '" + xFilial("SC6") + "' "
	cQuery += " AND C5_PLACA = '" + UPPER(cGetPlc) + "' "
	cQuery += " AND C5_PLACA <> '' "	
	cQuery += " AND C5_NOTA = '' "	
	cQuery += " AND C5_XINT = '3' "
	cQuery += " AND C5_XFLAGE <> '2' "	
	/*	
	If lCkBxFar
		cQuery += " AND C6_PRODUTO IN ('100097','100098') "	
	Endif
	If lCkBxOleo
		cQuery += " AND C6_PRODUTO IN ('100096','391129','590189') "	
	Endif
	If lCkBxOsso
		cQuery += " AND C6_PRODUTO IN ('302229') "	
	Endif
	//If lCkBxLodo
   //		cQuery += " AND C6_COD IN ('100097','100098') "	
   //	Endif
	If lCkBxSuc
		cQuery += " AND C6_PRODUTO IN ('812674','812934','884863') "	
	Endif
	*/			
	cQuery += " ORDER BY C6_ENTREG DESC "	
	
	TCQUERY cQuery new alias "TMP0"
	TMP0->(dbgotop())
	
	_aDocEd := {}
	
	dbSelectArea("TMP0")
	TMP0->(dbgotop())	
	While !Eof()
		aadd(_aDocEd,{TMP0->DOCEDT,STOD(TMP0->C6_ENTREG),TMP0->C5_ROTEIRO,Alltrim(TMP0->C6_DESCRI)})
		TMP0->(dbsKip())
	Enddo 			
    
	nLin := 40
	
  DEFINE MSDIALOG oDlg TITLE "Numero Documento Edata" FROM 000, 000  TO 340, 500 COLORS 0, 16777215 PIXEL

    @ 003, 004 GROUP oGroup1 TO 163, 250 PROMPT "Dados para Pesagem" OF oDlg COLOR 0, 16777215 PIXEL
    //@ 046, 015 GROUP oGroup2 TO 115, 147 PROMPT "Marque o Produto que será utilizado: " OF oDlg COLOR 0, 16777215 PIXEL
    @ 018, 017 SAY oSay1 PROMPT "Placa:" SIZE 021, 008 OF oDlg COLORS 0, 16777215 PIXEL
    @ 032, 017 SAY oSay2 PROMPT "Data de Entrega:" SIZE 046, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 016, 066 MSGET oGetPlc VAR cGetPlc SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 031, 066 MSGET oGetDt VAR cGetDt SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    /*
    @ 060, 021 CHECKBOX oCheckBoxFar VAR lCkBxFar PROMPT "Farinha" SIZE 029, 011 OF oDlg COLORS 0, 16777215 PIXEL
    @ 070, 021 CHECKBOX oCheckBoxOleo VAR lCkBxOleo PROMPT "Oleo" SIZE 045, 008 OF oDlg COLORS 0, 16777215 PIXEL
    @ 080, 021 CHECKBOX oCheckBoxOsso VAR lCkBxOsso PROMPT "Osso" SIZE 047, 012 OF oDlg COLORS 0, 16777215 PIXEL
    @ 090, 021 CHECKBOX oCheckBoxLodo VAR lCkBxLodo PROMPT "Lodo" SIZE 048, 008 OF oDlg COLORS 0, 16777215 PIXEL
    @ 100, 021 CHECKBOX oCheckSuc VAR lCkBxSuc PROMPT "Sucata" SIZE 048, 008 OF oDlg COLORS 0, 16777215 PIXEL
    */
    @ 055, 015 GROUP oGroup3 TO 128, 240 PROMPT "Utilizar no Edata: " OF oDlg COLOR 0, 16777215 PIXEL
    @ 064, 022 SAY oSay3 PROMPT "Documento" SIZE 030, 007 OF oDlg COLORS 128, 16777215 PIXEL
    @ 064, 067 SAY oSay4 PROMPT "Dt Entrega" SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 064, 114 SAY oSay5 PROMPT "Roteiro" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 064, 140 SAY oSay5 PROMPT "Produto" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    If len(_aDocEd) >= 1    
	    @ 074, 022 SAY oDoc1 PROMPT _aDocEd[1][1] SIZE 025, 007 OF oDlg COLORS 255, 16777215 PIXEL
    	@ 074, 067 SAY oDt1 PROMPT _aDocEd[1][2] SIZE 037, 007 OF oDlg COLORS 0, 16777215 PIXEL    
	    @ 074, 114 SAY oRot1 PROMPT _aDocEd[1][3] SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL    
	    @ 074, 140 SAY oRot1 PROMPT _aDocEd[1][4] SIZE 070, 007 OF oDlg COLORS 0, 16777215 PIXEL    	    
	Else
		@ 074, 022 Say "Não localizado" Size 035,050 OF oDlg COLOR CLR_HBLUE PIXEL
	Endif    
    If len(_aDocEd) >= 2
	    @ 084, 022 SAY oDoc2 PROMPT _aDocEd[2][1] SIZE 025, 007 OF oDlg COLORS 255, 16777215 PIXEL
	    @ 084, 067 SAY oDt2 PROMPT _aDocEd[2][2] SIZE 037, 007 OF oDlg COLORS 0, 16777215 PIXEL	    
	    @ 084, 114 SAY oRot2 PROMPT _aDocEd[2][3] SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL	    
	    @ 084, 140 SAY oRot1 PROMPT _aDocEd[2][4] SIZE 070, 007 OF oDlg COLORS 0, 16777215 PIXEL    	    	    
    Endif
    If len(_aDocEd) >= 3    
	    @ 094, 022 SAY oDoc3 PROMPT _aDocEd[3][1] SIZE 025, 007 OF oDlg COLORS 255, 16777215 PIXEL
	    @ 094, 067 SAY oDt3 PROMPT _aDocEd[3][2] SIZE 037, 007 OF oDlg COLORS 0, 16777215 PIXEL	    
	    @ 094, 114 SAY oRot3 PROMPT _aDocEd[3][3] SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL	    
	    @ 094, 140 SAY oRot1 PROMPT _aDocEd[3][4] SIZE 070, 007 OF oDlg COLORS 0, 16777215 PIXEL    	    	    
	Endif 
	If len(_aDocEd) >= 4   
	    @ 105, 022 SAY oDoc4 PROMPT _aDocEd[4][1] SIZE 025, 007 OF oDlg COLORS 255, 16777215 PIXEL
	    @ 105, 067 SAY oDt4 PROMPT _aDocEd[4][2] SIZE 037, 007 OF oDlg COLORS 0, 16777215 PIXEL	    
	    @ 105, 114 SAY oRot4 PROMPT _aDocEd[4][3] SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL	    
	    @ 105, 140 SAY oRot1 PROMPT _aDocEd[4][4] SIZE 070, 007 OF oDlg COLORS 0, 16777215 PIXEL    	    	    
	Endif    
	If len(_aDocEd) >= 5
	    @ 115, 022 SAY oDoc5 PROMPT _aDocEd[5][1] SIZE 025, 007 OF oDlg COLORS 255, 16777215 PIXEL
    	@ 115, 067 SAY oDt5 PROMPT _aDocEd[5][2] SIZE 037, 007 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 115, 114 SAY oRot5 PROMPT _aDocEd[5][3] SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 115, 140 SAY oRot1 PROMPT _aDocEd[5][4] SIZE 070, 007 OF oDlg COLORS 0, 16777215 PIXEL    	    	    
	Endif 
	
    @ 142, 100 BUTTON oButtonOk PROMPT "Ok" SIZE 034, 013 OF oDlg ACTION (Retorno()) PIXEL
	   
  ACTIVATE MSDIALOG oDlg CENTERED

//Endif

Return() 

Static Function Retorno() //GRAVA VARIAVEIS

Close(oDlg)

Return
