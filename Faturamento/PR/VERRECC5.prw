#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"
#DEFINE GD_INSERT	1
#DEFINE GD_DELETE	4	
#DEFINE GD_UPDATE	2 

User Function VERRECC5()
                        
cPerg 	:= PADR("VERRECC5",10," ")
Pergunte	(cPerg,.T.)

Static oButtonOk
Static oGetDtE
Static oGetNum
Static oGetRot
Static oGetPlac
Static oGetNome
Static oGetStP
Static oGroup1
Static oGetXflage
Static oGetXint
Static oSay1
Static oSay2
Static oSay3
Static oSay4
Static oSay5                      
Static oSay6
Static oSay7

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

IF SELECT("TMP0") > 0
	TMP0->( DBCLOSEAREA())
ENDIF	

cQuery := " SELECT C5_NUM, C5_ROTEIRO, C5_DTENTR, C5_NOMECLI, C5_PLACA, C5_XINT, C5_XFLAGE, D_E_L_E_T_ AS STPED FROM " + RetSqlName("SC5")
cQuery += " WHERE R_E_C_N_O_ = '" + Alltrim(mv_par01) + "' "
	
TCQUERY cQuery new alias "TMP0"

dbSelectArea("TMP0")
TMP0->(dbgotop())

cNumPed :=TMP0->C5_NUM
cRot    :=TMP0->C5_ROTEIRO
cDtEntr :=STOD(TMP0->C5_DTENTR)
cNomeCli:=TMP0->C5_NOMECLI
cPlaca  :=TMP0->C5_PLACA
cStPed  :=TMP0->STPED

If TMP0->C5_XINT == "1"
	cXint := "Pendente Envio Edata"
ElseIf TMP0->C5_XINT == "2"
	cXint := "Estornado"
ElseIf TMP0->C5_XINT == "3"	
	cXint := "Enviado"      
ElseIf TMP0->C5_XINT == "4"	
	cXint := "Erro na integração"	
Else
	cXint := ""
Endif	
	
If TMP0->C5_XFLAGE == "1"	
	cXflage := "Pendente"      
ElseIf TMP0->C5_XFLAGE == "2"	
	cXflage := "Disponivel para Faturamento"	
Else
	cXflage := ""
Endif

If Alltrim(cNumPed) <> ""	
   
	DEFINE MSDIALOG oDlg TITLE "Informações do Pedido" FROM 000, 000  TO 300, 400 COLORS 0, 16777215 PIXEL

	@ 003, 004 GROUP oGroup1 TO 140, 200 PROMPT "Dados" OF oDlg COLOR 0, 16777215 PIXEL
	@ 018, 017 SAY oSay1 PROMPT "Numero:" SIZE 021, 008 OF oDlg COLORS 255, 16777215 PIXEL  
    @ 018, 047 SAY oGetNum PROMPT cNumPed SIZE 060, 010 OF oDlg COLORS CLR_HBLUE PIXEL   
	@ 018, 100 SAY oSay2 PROMPT "Roteiro:" SIZE 046, 007 OF oDlg COLORS 255, 16777215 PIXEL
    @ 018, 140 SAY oGetRot PROMPT cRot SIZE 060, 010 OF oDlg COLORS CLR_HBLUE PIXEL    
	@ 036, 017 SAY oSay5 PROMPT "Placa:" SIZE 025, 007 OF oDlg COLORS 255, 16777215 PIXEL        
    @ 036, 047 SAY oGetPlac PROMPT cPlaca SIZE 060, 010 OF oDlg COLORS CLR_HBLUE PIXEL    	
	@ 036, 100 SAY oSay3 PROMPT "Dt Entrega:" SIZE 030, 007 OF oDlg COLORS 255, 16777215 PIXEL 
    @ 036, 140 SAY oGetDtE PROMPT cDtEntr SIZE 060, 010 OF oDlg COLORS CLR_HBLUE PIXEL        		
	@ 054, 017 SAY oSay4 PROMPT "Nome:" SIZE 035, 007 OF oDlg COLORS 255, 16777215 PIXEL
    @ 054, 047 SAY oGetNome PROMPT cNomeCli SIZE 060, 010 OF oDlg COLORS CLR_HBLUE PIXEL
	@ 072, 017 SAY oSay5 PROMPT "Integração Edata:" SIZE 050, 007 OF oDlg COLORS 255, 16777215 PIXEL
    @ 072, 060 SAY oGetXint PROMPT cXint SIZE 060, 010 OF oDlg COLORS CLR_HBLUE PIXEL    
	@ 090, 017 SAY oSay6 PROMPT "Retorno Edata:" SIZE 050, 007 OF oDlg COLORS 255, 16777215 PIXEL
    @ 090, 060 SAY oGetXflage PROMPT cXflage SIZE 070, 010 OF oDlg COLORS CLR_HBLUE PIXEL    
    If Alltrim(cStPed) <> ""
		@ 108, 017 SAY oSay7 PROMPT "Status: PEDIDO EXCLUIDO" SIZE 080, 007 OF oDlg COLORS 255, 16777215 PIXEL
    Endif	
	
	@ 120, 100 BUTTON oButtonOk PROMPT "Ok" SIZE 034, 013 PIXEL ACTION oDlg:End()  
	   
	ACTIVATE MSDIALOG oDlg CENTERED
Else
	Alert("Pedido não localizado")
Endif	

Return() 