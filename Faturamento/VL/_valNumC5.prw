//VALIDA A SEQUENCIA CORRETA DO SC5.

#INCLUDE "PROTHEUS.CH"

User Function _valNumC5()

	Local cPedido := ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	// @history 08/09/2021, Macieir, Chamado T.I. Refor�a na Valida��o do n�mero sequencial do pedido de venda ap�s golive cloud
	Do While .t.

		cPedido := GetSxeNum("SC5","C5_NUM")
		
		// SC5
		dbSelectArea("SC5")
		SC5->( dbSetOrder( 01 ) )
		While SC5->( dbSeek( xFilial( "SC5" ) + cPedido ) )
			ConfirmSX8()
			cPedido := GetSxeNum( "SC5", "C5_NUM" )
		EndDo
		ConfirmSX8() 

		//Everson - 07/06/2018. Chamado 037261. SalesForce.
		DbSelectArea("ZCI")
		ZCI->( DbSetOrder( 2 ) )
		While ZCI->( dbSeek( xFilial( "ZCI" ) + cPedido ) )
			ConfirmSX8()
			cPedido := GetSxeNum( "SC5", "C5_NUM" )
		EndDo
		ConfirmSX8() 

		// Checo ap�s ZCI
		SC5->( dbSetOrder(1) )
		If SC5->( !dbSeek(FWxFilial("SC5")+cPedido) )
			Exit
		EndIf

	EndDo
                 
Return cPedido
