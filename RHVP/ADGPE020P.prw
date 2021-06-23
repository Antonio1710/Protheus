#Include "PROTHEUS.CH"   
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADGPE020P �Autor  �CONSULTORIA TROMBINI� Data �  03/03/2015 ���
�������������������������������������������������������������������������͹��
���Desc.     � fun��o para validar os valores dos lan�amentos de verbas   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAGPE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function ADGPE020P()

Private nValor := GetMv('MV_#VLDVB')
Private lRet   := .T.
Private nValVb := M->RC_VALOR

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'fun��o para validar os valores dos lan�amentos de verbas')

	IF nValVb > nValor
		lRet := Senha()
	ENDIF

Return lRet 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Senha     �Autor  �CONSULTORIA TROMBINI� Data �  02/03/2015 ���
�������������������������������������������������������������������������͹��
���Desc.     � Tela para digitar a senha de autoriza��o                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAGPE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

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

	DEFINE MSDIALOG oDlg TITLE "Autoriza��o" FROM 000, 000  TO 065, 315 COLORS 0, 16777215 PIXEL

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
  			M->RC_VALOR := nValVb 
  			lRet := .F.
  		ENDIF
	ENDIF
	
	IF nOpc == 2
		
  		M->RC_VALOR := nValVb 
  		lRet := .F.
  		
	ENDIF

Return lRet          