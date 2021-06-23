#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"

User Function ADAFIN02()

Local aCores   		:= {}
Private bOk			:= {|| fAtualiza() }
Private nOp			:= Nil                             
Private cAlias		:= "ZAF"
Private cCadastro 	:= OemToAnsi('Obrigacoes a Pagar') 
Private aRotina		:= MenuDef()
             
Private aCores 		:= {	{"Empty(ZAF_LEGEND)"		,'ENABLE' }	,;	&& Parcela s Vencer Liquidada
							{"!Empty(ZAF_LEGEND)"		,'DISABLE'}}	&& Parcela Liquidada
							
U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

MBrowse( 6,1,22,75,'ZAF',,,,,,aCores,,,,,,,,)

dbSelectArea(cAlias)
dbSetOrder(1)
dbClearFilter()

Return(.T.)             

Static Function MenuDef()

Private aRotina := {	{ OemToAnsi("Pesquisar"),"AxPesqui"			,0,1,0 ,.F.},;		//"Pesquisar"
						{ OemToAnsi("Visual")	,"U_ADAFIN04()"		,0,2,0 ,NIL},;		//"Visual"
						{ OemToAnsi("Legenda")	,"U_ADA2Legend()"	,0,0,0 ,.F.} }		//"Legenda"

&&						{ OemToAnsi("Incluir")	,"U_ADAFIN05()"		,0,3,0 ,NIL},;		//"Inclusao"					

Return(aRotina)

Static Function fEnchBar(oDlg1,bOk)

Local oBar, oBtOk

Define ButtonBar oBar SIZE 25,25 3D TOP Of oDlg1                                             

&&Define Button Resource "S4WB008N"	Of oBar Group	Action Calculadora()		Tooltip ""
&&Define Button Resource "S4WB010N"	Of oBar 		Action OurSpool() 			Tooltip "Spool"
&&Define Button Resource "S4WB016N"	Of oBar Group	Action HelProg() 			Tooltip "Help"
Define Button Resource "OK"			Of oBar Group	Action Eval(bOk)			&&Tooltip "Ok"
Define Button Resource "Cancel"		Of oBar Group	Action oDlg1:End()			&&Tooltip "Cancela"
	                  
Return()                                 

Static Function fAtualiza(oDlg1)

Local lRet		:= .T.
Local cQuery	:= ''
Local nTot		:= 0

cQuery := "SELECT * FROM " + RetSqlName("ZAG") + " WHERE D_E_L_E_T_ = '' AND ZAG_FILIAL = '" + xFilial("ZAG") + "'  "
cQuery += "AND ZAG_DATAIN >=  '" + Dtos(dIni) + "' AND ZAG_DATAIN <= '" + Dtos(dFim) + "' AND ZAG_CODIGO = '" + cCodigo + "' "

tcQuery cQuery New Alias "TZAG"

Count to nTot

TZAG->(dbCloseArea())

If Inclui
	If nTot > 0
		MsgInfo("Período informado não permitido. Verifique os parametros informados.")
		lRet := .F.
	Else
		RecLock("ZAG",.T.)
			ZAG->ZAG_FILIAL		:= XFILIAL("ZAG")
			ZAG->ZAG_CODIGO		:= cCodigo
			ZAG->ZAG_DATAIN		:= dini
			ZAG->ZAG_DATAFI		:= dFim
			ZAG->ZAG_JUROS		:= nJuros
			ZAG->ZAG_TR			:= nTR
			ZAG->ZAG_CORREC		:= nCorrec
		MsUnlock("ZAG")
	EndIf	
ElseIf Altera
	If !Empty(ZAG->ZAG_LEGEND)
		MsgInfo("Alteracao não permitida para indice ja aplicado. Verifique os parametros informados.")
		lRet := .F.                   
	ElseIf nTot > 0
		MsgInfo("Período informado não permitido. Verifique!!")
		lRet := .F.	
	Else
		RecLock("ZAG",.F.)
			ZAG->ZAG_CODIGO		:= cCodigo
			ZAG->ZAG_DATAIN		:= dini
			ZAG->ZAG_DATAFI		:= dFim
			ZAG->ZAG_JUROS		:= nJuros
			ZAG->ZAG_TR			:= nTR
			ZAG->ZAG_CORREC		:= nCorrec
		MsUnlock("ZAG")
	EndIf	  
Else
	If !Empty(ZAG->ZAG_LEGEND)
		MsgInfo("Exclusao não permitida para indice ja aplicado. Verifique!!")
		lRet := .F.                   
	EndIf	
Endif

oDlg1:End()	
Return(lRet)                                                     

User Function ADA2Legend()

Local aCores := {}

U_ADINF009P('ADAFIN02' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

aCores := {	{"ENABLE"	,'Parcela a Vencer'},; 
			{"DISABLE"	,'Parcela Liquidada'}}

BrwLegenda(cCadastro,'Legenda Obrigacoes a Pagar',aCores)

Return(.T.)