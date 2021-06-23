#Include "PROTHEUS.CH"   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADGPE021P ºAutor  ³CONSULTORIA TROMBINIº Data ³  02/03/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para gerar senha criptografada                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADGPE021P()

	Local oButton1
	Local oButton2
	Local oGet1
	Local oGet2
	Local cGet1		:= space(20)
	Local cGet2		:= space(20)
	Local oSay1
	Local oSay2
	Local oDlg
	Local nOpc  	:= 2 
	Local cRet  	:= ""
	Local cPass 	:= GetMv('MV_#PASSAL')
	Local lFim		:= .T.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela para gerar senha criptografada')

  DEFINE MSDIALOG oDlg TITLE "Geração de Senha" FROM 000, 000  TO 200, 300 COLORS 0, 16777215 PIXEL

    @ 019, 019 SAY oSay1 PROMPT "Senha Anterior:" SIZE 048, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 043, 019 SAY oSay2 PROMPT "Nova Senha:" SIZE 037, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 017, 065 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PASSWORD PIXEL
    @ 041, 065 MSGET oGet2 VAR cGet2 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PASSWORD PIXEL
    @ 068, 025 BUTTON oButton1 PROMPT "Confirmar" Action(nOpc:=1,oDlg:end()) SIZE 037, 012 OF oDlg PIXEL
    @ 068, 079 BUTTON oButton2 PROMPT "Cancelar" Action(nOpc:=2,oDlg:end()) SIZE 037, 012 OF oDlg PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED
    
	IF !Empty(cPass)
	
		While lFim
			cRet += chr(CTON(Substr(cPass,1,2), 16))
			cPass := Substr(cPass,3,100)
			
			IF Empty(cPass)
				lFim := .F.
			ENDIF
		Enddo 
		
		cPass := rc4crypt(cRet, "123456789", .F.)
	
		IF nOpc == 1
			IF Alltrim(Upper(cGet1)) == Alltrim(Upper(cPass)) 
	  			IF nOpc == 1 
		 
					cGet2 := Alltrim(cGet2)
					dbselectarea("SX6")
					SX6->(dbsetorder(1)) 
					IF SX6->(dbseek( SPACE(LEN(SX6->X6_FIL)) + "MV_#PASSAL" ))
						cRet = rc4crypt( cGet2 ,"123456789", .T.)
						RECLOCK("SX6",.F.)
						X6_CONTEUD := cRet
						SX6->( MsUnlock() )
					ENDIF
					
					Msginfo("Senha alterada com sucesso.")
				ENDIF
	  		ELSE
	  			Msginfo("Senha incorreta.")
	  		ENDIF
		ENDIF
	ELSE
 		IF nOpc == 1 
 
			cGet2 := Alltrim(cGet2)
			dbselectarea("SX6")
			SX6->(dbsetorder(1)) 
			IF SX6->(dbseek( SPACE(LEN(SX6->X6_FIL)) + "MV_#PASSAL" ))
				cRet = rc4crypt( cGet2 ,"123456789", .T.)
				RECLOCK("SX6",.F.)
				X6_CONTEUD := cRet
				SX6->( MsUnlock() )
			ENDIF 
			
			Msginfo("Senha alterada com sucesso.")
		ENDIF	
	ENDIF
Return 