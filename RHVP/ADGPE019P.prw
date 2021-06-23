#Include "PROTHEUS.CH"   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADGPE019P ºAutor  ³CONSULTORIA TROMBINIº Data ³  02/03/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ função para validar a alteração de salario.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADGPE019P()

	Private nPerc             := GetMv('MV_#VLDPER')
	Private nValor            := GetMv('MV_#VLDVA')
	Private nSalAnt           := SRA->RA_SALARIO
	Private nSalAlt           := M->RA_SALARIO
	Private nVariacaoSalarial := (M->RA_SALARIO - SRA->RA_SALARIO)
	Private lRet              := .T.
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'função para validar a alteração de salario.')

	IF ( (nSalAlt / nSalAnt -1 ) *100 ) > nPerc .AND. nVariacaoSalarial <= nValor //nSalAlt > nValor
	
		lRet := Senha()
		
	ELSEIF ( (nSalAlt / nSalAnt -1 ) *100 ) > nPerc .AND. nVariacaoSalarial > nValor //nSalAlt <= nValor 
		
		MsgInfo("Alteração Salarial ultrapassa o percentual permitido.Não Permitido.") 
		M->RA_SALARIO := nSalAnt       
	
	ELSE
	
		M->RA_SALARIO := nSalAlt       
		
	ENDIF

Return lRet  

Static Function Senha()

Local oButton1
Local oGet1
Local cGet1		:= space(20)
Local oSay1
Local oDlg
Local cPass := GetMv('MV_#PASSAL') 
Local nOpc  := 2
Local lRet  := .F.
Local cRet	:= ""
Local lFim	:= .T.

	DEFINE MSDIALOG oDlg TITLE "Autorização" FROM 000, 000  TO 065, 315 COLORS 0, 16777215 PIXEL

     @ 012, 009 SAY oSay1 PROMPT "Senha:" SIZE 023, 009 OF oDlg COLORS 0, 16777215 PIXEL
     @ 011, 040 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PASSWORD PIXEL
	 @ 010, 110 BUTTON oButton1 PROMPT "Confirmar" Action(nOpc:=1,oDlg:end()) SIZE 037, 012 OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED 
	
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
  			lRet := .T.
  		ELSE
  			Msginfo("Senha incorreta.")
  			M->RA_SALARIO := nSalAnt
  			oEnchSra:Refresh()
  		ENDIF
	ENDIF  
	
	IF nOpc == 2
	
		M->RA_SALARIO := nSalAnt
  		oEnchSra:Refresh()
  			
  	ENDIF		

Return lRet       