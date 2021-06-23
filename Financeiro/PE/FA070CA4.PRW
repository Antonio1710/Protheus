#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function FA070CA4
	Valida a data da estorno da baixa a receber de acordo com a database do sistema.
	@type  Function
	@author Fernando Macieira
	@since 09/08/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 12214 - Fernando Macieira - 12/04/2021 - Erro ao estornar título
/*/
User Function FA070CA4()

	Local lRet	    := .T.
	Local dData   	:= CTOD("")
	Local cSeq		:= ""
	Local cChave 	:= ""
	Local aArea		:= GetArea()
	Local aAreaSE5	:= SE5->(GetArea())
	Local aAreaSEF	:= SEF->(GetArea())
	Local lEncBaixa	:= .F.
	Local dDtSE5    := CTOD("")
	Local dDataFin  := GetMV("MV_DATAFIN")
	
	If dDataBase < dDataFin
		lRet := .f.
		Aviso("FA070CA4-01", "Estorno não permitido! Financeiro bloqueado nesta data. Ajuste a database ou contate o departamento financeiro...",{"OK"},3 , "MV_DATAFIN: " + DtoC(dDataFin))
	EndIf
	
	If lRet
		
		//³Valida se a data da baixa esta igual a database                                   ³
		If Type("cListBox") <> "U"
		
			dData  := CtoD(Subs(cListBox,42,11))
			cSeq   := Right(AllTrim(cListBox),2)
			cChave := SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA+cSeq
			
			SE5->( dbSetOrder(7) ) // E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
			If SE5->( dbSeek(FWxFilial("SE5")+cChave) )

				Do While SE5->( !EOF() ) .and. SE5->E5_FILIAL+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA+SE5->E5_SEQ == FWxFilial("SE5")+cChave
					//If SE5->E5_DTDISPO == dData .and. SE5->E5_SEQ == cSeq
					If SE5->E5_DATA == dData .and. SE5->E5_SEQ == cSeq // @history ticket 12214 - Fernando Macieira - 12/04/2021 - Erro ao estornar título
						lEncBaixa := .T.
						//dDtSE5 := SE5->E5_DTDISPO
						dDtSE5 := SE5->E5_DATA // @history ticket 12214 - Fernando Macieira - 12/04/2021 - Erro ao estornar título
						Exit
					Endif
					SE5->( dbSkip() )
				EndDo

			EndIf
			
			If lEncBaixa
				// Checo se o recebimento foi com CH - Nao utilizam conceito de cmp do cheque (MV_SLDBXCR)
				SEF->( dbSetOrder(3) ) // EF_FILIAL+EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+EF_NUM+EF_SEQUENC
				If SEF->( !dbSeek(xFilial("SEF")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)) )
					If dDataBase <> dDtSE5
						lRet := .F.
						Aviso("FA070CA4-02","A database do sistema ("+DtoC(dDataBase)+") não é a mesma da data de baixa do título a pagar ("+DtoC(dDTSE5)+"). Confirme se o estorno ocorrerá mesmo em database do sistema diferente... ",{"Ok"},3 ,"Atencao! Estorno em database diferente...")
						If msgYesNo("Confirma o estorno em database diferente da baixa?")
							lRet := .t.
						EndIf
					Endif
				Endif
			Else
				lRet := .F.
				Aviso("FA070CA4-03","Não foi possivel localizar a baixa do titulo selecionado. ",{"Ok"},3 ,"Atencao! Estorno não realizado...")
			Endif

		Else

			cChave := SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA
			SE5->( dbSetOrder(7) ) // E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
			If SE5->( dbSeek(FWxFilial("SE5")+cChave) )
				Do While SE5->( !EOF() ) .and. SE5->E5_FILIAL+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA == xFilial("SE5")+cChave
					If SE5->E5_TIPODOC $ "BA/VL/LJ/V2"
						lEncBaixa := .t.
						dDtSE5 := SE5->E5_DTDISPO
						Exit
					Endif
					SE5->( dbSkip() )
				EndDo
			EndIf
			
			If lEncBaixa
				If dDataBase <> dDtSE5
					lRet := .F.
					Aviso("FA070CA4-04","A database do sistema ("+DtoC(dDataBase)+") não é a mesma da data de baixa do título a pagar ("+DtoC(dDTSE5)+"). Confirme se o estorno ocorrerá mesmo em database do sistema diferente... ",{"Ok"},3 ,"Atencao! Estorno em database diferente...")
					If msgYesNo("Confirma o estorno em database diferente da baixa?")
						lRet := .t.
					EndIf
				Endif
			Else
				lRet := .F.
				Aviso("FA070CA4-05","Não foi possivel localizar a baixa do titulo selecionado. ",{"Ok"},3 ,"Atencao! Estorno não realizado...")
			Endif
		
		Endif

	EndIf

	RestArea(aAreaSEF)
	RestArea(aAreaSE5)
	RestArea(aArea)

Return lRet
