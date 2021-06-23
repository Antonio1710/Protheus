#include "protheus.ch"

/*{Protheus.doc} User Function LP812001
	Contabilizacao on-line da baixa de adiantamento (projetos) no ativo fixo - utilizado nos LPs 812-001 e 812-002
	@type  Function
	@author FWNM
	@since 01/11/2019
	@version 01
	@history Chamado 049953 - FWNM            - 01/11/2019 - 049953 || OS 051296 || CONTROLADORIA || MONIK_MACEDO || 8956 || CONTAB. IMBOLIZADO  
*/

User Function LP812001(cEntidade)

	Local cRet     := ""
	Local aAreaSN1 := SN1->( GetArea() )
	Local aAreaSN4 := SN4->( GetArea() )

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	Default cEntidade := ""
	
	// Tratamento variavel Valor
	If cEntidade == "VALOR"
		cRet := 0
	EndIf
	
	// Tratamento para buscar dados do novo bem (N4_TIPO = 01) que foi gerado a partir dos movimentos de adiantamento (N4_TIPO = 03) 	
	SN4->( dbSetOrder(1) ) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ
	If SN4->( dbSeek( FWxFilial("SN4")+cBase+cItemAtivo+"01"+DtoS(dDataBase) ) )
		
		If cEntidade == "VALOR"

			If !Empty(SN4->N4_DCONTAB)
				cRet := 0
			
			Else
				cRet := SN4->N4_VLROC1

				RecLock("SN4", .f.)
					SN4->N4_DCONTAB := dDataBase
				SN4->( msUnLock() )

			EndIf

		ElseIf cEntidade == "CONTA"
			cRet := SN4->N4_CONTA
			
		ElseIf cEntidade == "HISTORICO"
			SN1->( dbSetOrder(1) ) //N1_FILIAL+N1_CBASE+N1_ITEM
			If SN1->( dbSeek( SN4->N4_FILIAL+cBase+cItemAtivo ) )
				cRet := AllTrim(SN1->N1_DESCRIC)
			EndIf

		ElseIf cEntidade == "ITEM"
			
			If SN4->N4_FILIAL=="01"
				cRet := "121"
			
			ElseIf SN4->N4_FILIAL=="02"
				cRet := "121"

			ElseIf SN4->N4_FILIAL=="03"  
				cRet := "114"
				
				If AllTrim(SN4->N4_CCUSTO)=="5131"
					cRet := "113"
				EndIf

			ElseIf SN4->N4_FILIAL=="04"  
				cRet := "112"

			ElseIf SN4->N4_FILIAL=="05"  
				cRet := "114"

			ElseIf SN4->N4_FILIAL=="08"  
				cRet := "115"

			EndIf

		EndIf
		
	EndIf

	RestArea( aAreaSN1 )
	RestArea( aAreaSN4 )
	
Return cRet