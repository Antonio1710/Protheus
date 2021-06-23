
#include "protheus.ch"
#include "topconn.ch"
/*/{Protheus.doc} User Function MT131WF
	Ponto de Entrada executado na geracao da cotacao.
	Visa garantir o preenchimento do campo C8_PROJETO.
	Chamado n. 043947 - Reginaldo Fagian
	@type  Function
	@author Fernando Macieira
	@since 09/18/2018
	@version 01
	@history Everson, 04/11/2020, Chamado 2562. Tratamento para gravar o número do estudo do projeto.
	/*/
User Function MT131WF()
	
	Local cNumCot   := PARAMIXB[1]

	Local aArea     := GetArea()
	Local aAreaSC1  := SC1->( GetArea() )
	Local aAreaSC8  := SC8->( GetArea() )

	SC8->( dbGoTop() )

	SC8->( dbSetOrder(1) ) // C8_FILIAL + C8_NUM
	If SC8->( dbSeek( FWxFilial("SC8")+cNumCot ) )
		Do While SC8->( !EOF() ) .and. SC8->C8_FILIAL == FWxFilial("SC8")
			
			SC1->( dbSetOrder(1) ) // C1_FILIAL + C1_NUM + C1_ITEM
			If SC1->( dbSeek( SC8->C8_FILIAL+SC8->C8_NUMSC+SC8->C8_ITEMSC ) )
				
				RecLock("SC8", .f.)
				
				SC8->C8_PROJETO := SC1->C1_PROJADO
				SC8->C8_CC      := SC1->C1_CC
				SC8->C8_CONTA   := SC1->C1_CONTA
				SC8->C8_XITEMST := SC1->C1_XITEMST //Everson - 04/11/2020. Chamado 2562.
				
				SC8->( msUnLock() )

			EndIf
			
			SC8->( dbSkip() )
			
		EndDo
		
	EndIf

	RestArea( aArea )
	RestArea( aAreaSC1 )
	RestArea( aAreaSC8 )

	Aviso("MT131WF-01", "Gerada cotação n. " + cNumCot, {"OK"}, 3, "Geração cotação")

Return Nil
