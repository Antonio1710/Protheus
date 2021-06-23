//VALIDA A SEQUENCIA CORRETA DO SC5.

#INCLUDE "PROTHEUS.CH"

User Function _valNumC5()
Local cPedido := GetSxeNum("SC5","C5_NUM")   

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

SC5->( dbSetOrder( 01 ) )

While SC5->( dbSeek( xFilial( "SC5" ) + cPedido ) )
	ConfirmSX8()
	cPedido := GetSxeNum( "SC5", "C5_NUM" )
EndDo

	//Everson - 07/06/2018. Chamado 037261. SalesForce.
	DbSelectArea("ZCI")
	ZCI->( DbSetOrder( 2 ) )
	
	While ZCI->( dbSeek( xFilial( "ZCI" ) + cPedido ) )
		ConfirmSX8()
		cPedido := GetSxeNum( "SC5", "C5_NUM" )
		
	EndDo
                         
Return cPedido