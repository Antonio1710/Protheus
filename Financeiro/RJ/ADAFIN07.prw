#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADAFIN07  �Autor  �Microsiga           � Data �  06/10/19   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������͹��
���Chamado   � 049746 || OS 051039 || FINANCAS || ANA || 8384 ||          ���
���          � || REL. PARCELAS RJAP - FWNM - 10/06/2019                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function ADAFIN07()

	Local aCores   		:= {}
	Private bOk			:= {|| fAtualiza() }
	Private nOp			:= Nil                             
	Private cAlias		:= "ZAH"
	Private cCadastro 	:= OemToAnsi('Atualizacao de Parcelas') 
	Private aRotina		:= MenuDef()
	
	&&Public lSimulaAtu	:= .F.
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	MBrowse( 6,1,22,75,'ZAH',,,,,,aCores,,,,,,,,)
	
	dbSelectArea(cAlias)
	dbSetOrder(1)
	dbClearFilter()
	
	Return(.T.)             
	

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADAFIN07  �Autor  �Microsiga           � Data �  06/10/19   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MenuDef()
	
	Private aRotina := {	{ OemToAnsi("Simular")	,"U_ADA7Simula()"	,0,3,0 ,NIL},;		//Simulacao da Correcao
								{ OemToAnsi("Aplicar")	,"U_ADA7Aplicar()"	,0,4,20,NIL} }		//Aplicar Correcao					
	
Return(aRotina)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADAFIN07  �Autor  �Microsiga           � Data �  06/10/19   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function fEnchBar(oDlg1,bOk)

	Local oBar, oBtOk
	
	Define ButtonBar oBar SIZE 25,25 3D TOP Of oDlg1                                             
	
	&&Define Button Resource "S4WB008N"	Of oBar Group	Action Calculadora()		Tooltip ""
	&&Define Button Resource "S4WB010N"	Of oBar 		Action OurSpool() 			Tooltip "Spool"
	&&Define Button Resource "S4WB016N"	Of oBar Group	Action HelProg() 			Tooltip "Help"
	Define Button Resource "OK"			Of oBar Group	Action Eval(bOk)			&&Tooltip "Ok"
	Define Button Resource "Cancel"		Of oBar Group	Action oDlg1:End()			&&Tooltip "Cancela"
	                  
Return()                                 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADAFIN07  �Autor  �Microsiga           � Data �  06/10/19   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function fAtualiza(oDlg1)

	Local lRet		:= .T.
	Local cQuery	:= ''
	Local nTot		:= 0
	
	cQuery := "SELECT * FROM " + RetSqlName("ZAG") + " WHERE D_E_L_E_T_ = '' AND ZAG_FILIAL = '" + xFilial("ZAG") + "'  "
	cQuery += "AND ZAG_DATAIN >=  '" + Dtos(dIni) + "' AND ZAG_DATAIN <= '" + Dtos(dFim) + "' AND ZAG_CODIGO = '" + cCodigo + "' "
	
	tcQuery cQuery New Alias "TZAG"
	
	Count to nTot
	
	Alert(Str(nTot))
	
	TZAG->(dbCloseArea())
	
	oDlg1:End()	

Return(lRet)