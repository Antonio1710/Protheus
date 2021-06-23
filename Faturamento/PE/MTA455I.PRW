#include "rwmake.ch"

/*/{Protheus.doc} User Function nomeFuncMTA450Ition
	Ponto de Entrada no MATA456 (Liberacao de Credito e estoque gravar SC9, para gravar o campo C9_ROTEIRO,C9_DTENTR
	@type  Function
	@author hcconsys
	@since 04/11/08
	@history Ticket 8 - Abel Babini - 11/05/2021 - Força a liberação de estoque dos pedidos conforme orientação de Fernando Sigoli nesta data
	/*/
User Function MTA455I()      // DELMTA450T()  RENOMEADA PARA DEL PARA TESTAR

Local _aArea		:= GetArea()    

dbSelectArea("SC6")
dbSetOrder(1)
if dbseek(xfilial("SC6") + SC5->C5_NUM)
	
	DO WHILE .NOT. EOF() .AND. SC6->C6_FILIAL == SC5->C5_FILIAL .AND. SC6->C6_NUM == SC5->C5_NUM
		
		dbSelectArea("SC9")
		dbSetOrder(1)
		if dbseek(xfilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM )
			
			RecLock("SC9",.F.)
			Replace C9_ROTEIRO With SC6->C6_ROTEIRO
			Replace C9_DTENTR  with SC6->C6_ENTREG     // ALTERADO EM 29/10/08 POR HCCONSYS P/ TRATAR NUMERO DO LACRE NA ROTINA MENUBALA()
			Replace C9_VEND1   with SC5->C5_VEND1
			//Ticket 8 - Abel Babini - 11/05/2021 - Força a liberação de estoque dos pedidos conforme orientação de Fernando Sigoli nesta data
			Replace C9_BLEST   with ''
			MsUnlock()
			
		endif
		dbSelectArea("SC6")
		dbSetOrder(1)
		dbskip()
	enddo
	
endif
	
	RestArea( _aArea )
	
	Return
