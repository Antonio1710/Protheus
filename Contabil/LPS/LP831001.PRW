#include "protheus.ch"

/*{Protheus.doc} User Function LP831001
	Contabilizacao on-line da baixa de ativo fixo - utilizado nos LPs 831-001 e 831-002
	@type  Function
	@author Abel Babini
	@since 24/08/2020
	@version 01
	@history Ticket 000001 - Abel Babini  - 28/09/2020 - Contabilização da baixa do ativo
*/

User Function LP831001(cEntidade)

	Local cRet     := ""
	Local aAreaSN1 := SN1->( GetArea() )
	Local aAreaSN4 := SN4->( GetArea() )

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	Default cEntidade := ""
	// Tratamento para buscar dados do novo bem (N4_TIPO = 01) que foi gerado a partir dos movimentos de adiantamento (N4_TIPO = 03) 	
	SN4->( dbSetOrder(1) ) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ
	If SN4->( dbSeek( FWxFilial("SN4")+SN1->N1_CBASE+SN1->N1_ITEM+'01'+DtoS(dDataBase) ) )
		
		If cEntidade == "ITEM_C"
				
				If FNR->FNR_FILORI=="01"
					cRet := "121"
				
				ElseIf FNR->FNR_FILORI=="02"
					cRet := "121"

				ElseIf FNR->FNR_FILORI=="03"  
					cRet := "114"
					
					If AllTrim(SN4->N4_CCUSTO)=="5131"
						cRet := "113"
					EndIf

				ElseIf FNR->FNR_FILORI=="04"  
					cRet := "112"

				ElseIf FNR->FNR_FILORI=="05"  
					cRet := "114"

				ElseIf FNR->FNR_FILORI=="08"  
					cRet := "115"

				EndIf

			ELSEIF cEntidade == "ITEM_D"
		
				If FNR->FNR_FILDES=="01"
					cRet := "121"
				
				ElseIf FNR->FNR_FILDES=="02"
					cRet := "121"

				ElseIf FNR->FNR_FILDES=="03"  
					cRet := "114"
					
					If AllTrim(SN4->N4_CCUSTO)=="5131"
						cRet := "113"
					EndIf

				ElseIf FNR->FNR_FILDES=="04"  
					cRet := "112"

				ElseIf FNR->FNR_FILDES=="05"  
					cRet := "114"

				ElseIf FNR->FNR_FILDES=="08"  
					cRet := "115"

				EndIf
		
		EndIf
		
	EndIf

	RestArea( aAreaSN1 )
	RestArea( aAreaSN4 )
	
Return cRet
