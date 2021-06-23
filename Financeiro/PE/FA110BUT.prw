#include "protheus.ch"
#include "topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA110BUT  �Autor  �Fernando Macieira   � Data �  12/07/18   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada para manuten��o dos titulos antes baixa   ���
���          � - CHAMADO N. 045499                                        ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FA110BUT()

	Local aButtons := {}
	
	// Botoes a adicionar
	aadd(aButtons,{ 'Acresc/Decresc' 		,{||  U_AltValor() },'Acresc/Decresc','Acresc/Decresc' } )
	aadd(aButtons,{ 'Exclui AB-'   			,{||  U_ExcAB() },'Exclui AB-','Exclui AB-' } )
	aadd(aButtons,{ 'Exclui AB- (em lote)'  ,{||  U_ExcABLt() },'Exclui AB- (em lote)','Exclui AB- (em lote)' } )
	
	oMark:oBrowse:Refresh(.t.)

Return aButtons

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AltValor  �Autor  �Microsiga           � Data �  12/07/18   ���
�������������������������������������������������������������������������͹��
���Desc.     � Recurso de acrescimo/decrescimo                            ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AltValor()

	Local lOK      := .f.
	Local nAcresc  := QRYSE1->E1_ACRESC
	Local nDecresc := QRYSE1->E1_DECRESC
	
	Local oCmp  := Array(02)
	Local oBtn  := Array(02)
	
	DEFINE MSDIALOG oDlg TITLE "Acr�scimo/Decr�scimo" FROM 0,0 TO 100,350  OF oMainWnd PIXEL
	
	@ 003, 003 TO 050,165 PIXEL OF oDlg
	
	@ 010,020 Say "Acr�scimo:" of oDlg PIXEL
	@ 005,060 MsGet oCmp Var nAcresc SIZE 70,12 of oDlg PIXEL Valid Positivo() Picture "@E 999,999.99"
	
	@ 020,020 Say "Decr�scimo:" of oDlg PIXEL
	@ 015,060 MsGet oCmp Var nDecresc SIZE 70,12 of oDlg PIXEL Valid (Positivo() .and. nDecresc < QRYSE1->E1_SALDO) Picture "@E 999,999.99"
	
	@ 030,015 BUTTON oBtn[01] PROMPT "Confirma"     of oDlg   SIZE 68,12 PIXEL ACTION (lOK := .t. , oDlg:End())
	@ 030,089 BUTTON oBtn[02] PROMPT "Cancela"      of oDlg   SIZE 68,12 PIXEL ACTION oDlg:End()
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If lOK
		
		aAreaSE1 := SE1->( GetArea() )
		
		SE1->( dbSetOrder(1) ) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
		
		If SE1->( dbSeek(QRYSE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)) )
			RecLock("SE1", .f.)
			SE1->E1_ACRESC := nAcresc
			SE1->E1_DECRESC := nDecresc
			SE1->( msUnLock() )
		EndIf
		
		RestArea( aAreaSE1 )
		
		oMark:oBrowse:Refresh(.t.)
		
	Endif
	
	oMark:oBrowse:Refresh(.t.)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ExcAB     �Autor  �Fernando Macieira   � Data �  12/10/18   ���
�������������������������������������������������������������������������͹��
���Desc.     � Exclui AB-                                                 ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function ExcAB()

	Local cTipo    := "AB-"
	Local aAreaSE1 := SE1->( GetArea() )
	
	SE1->( dbSetOrder(1) ) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
	If SE1->( dbSeek(QRYSE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+cTipo)) )
		
		If msgYesNo("Confirma exclus�o do AB- no valor de R$ " + Transform(SE1->E1_SALDO, "@E 999,999,999.99") + " ?" )
			
			RecLock("SE1", .f.)
		   		SE1->( dbDelete() )
			SE1->( msUnLock() )
			
			oMark:oBrowse:Refresh(.t.)
					
			msgInfo("Ab- n. " + QRYSE1->E1_NUM + " exclu�do com sucesso! Recarregue o browse ou remarque o t�tulo para atualiza��o do saldo na tela...")
			
		EndIf
		
	Else
		msgAlert("T�tulo n. " + QRYSE1->E1_NUM + "/" + QRYSE1->E1_PARCELA + " n�o possui AB-!")
	EndIf
	
	RestArea( aAreaSE1 )
	
	oMark:oBrowse:Refresh(.t.)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ExcABLt   �Autor  �Fernando Macieira   � Data �  12/10/18   ���
�������������������������������������������������������������������������͹��
���Desc.     � Exclui AB- em lote                                         ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function ExcABLt()

	Local cTipo    := "AB-"
	Local aAreaSE1 := SE1->( GetArea() )
	Local aAreaQRY := QRYSE1->( GetArea() )
	
	If msgYesNo("Tem certeza de que deseja excluir todos os AB- marcados desta lista?")
	
		SE1->( dbSetOrder(1) ) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
		
		ProcRegua(0)
		
		QRYSE1->( dbGoTop() )
		Do While QRYSE1->( !EOF() )
		
			IncProc(QRYSE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+cTipo))
			
			If !Empty(QRYSE1->E1_OK) // Marcado
			
				If SE1->( dbSeek(QRYSE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+cTipo)) )
				
					RecLock("SE1", .f.)
				   		SE1->( dbDelete() )
					SE1->( msUnLock() )
					
					oMark:oBrowse:Refresh(.t.)
							
				EndIf
			
			EndIf
			
			QRYSE1->( dbSkip() )
			
		EndDo
	
	EndIf	
	
	RestArea( aAreaSE1 )
	RestArea( aAreaQRY )
	
	oMark:oBrowse:Refresh(.t.)

Return