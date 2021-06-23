#include "protheus.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA080VEST ºAutor  ³ Fernando Macieira  º Data ³ 09/08/2019  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a data da estorno da baixa a pagar   de acordo com a º±±
±±º          ³database do sistema                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºChamado   ³ n. 051017 - Desenvolver tratativa no estorno e             º±±
±±º          ³ cancelamento na mesma data da baixa - TI - FWNM - 09/08/19 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºChamado   ³ n. 051017 - Fornecer aviso ao usuario sobre as diferencas  º±±
±±º          ³ de datas entre baixa e estorno      - TI - FWNM - 10/09/19 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºChamado   ³ 052159 || OS 053501 || FINANCAS || ANA || 8384 ||          º±±
±±º          ³ || ESTONO DE TITULO - FWNM - 30/09/19                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FA080VEST()

	Local lRet	    := .T.
	Local lEncBaixa	:= .F.
	Local nValor  	:= 0.00
	Local cSeq		:= ""
	Local cChave 	:= ""
	Local dDtSE5    := CTOD("")
	Local dData   	:= CTOD("")
	Local dDataFin  := GetMV("MV_DATAFIN")
	Local aArea		:= GetArea()
	Local aAreaSE5	:= SE5->(GetArea())
	Local aAreaSEF	:= SEF->(GetArea())
	
	If dDataBase < dDataFin
		lRet := .f.
		Aviso("FA080VEST-01", "Estorno não permitido! Financeiro bloqueado nesta data. Ajuste a database ou contate o departamento financeiro...",{"OK"},3 , "MV_DATAFIN: " + DtoC(dDataFin))
	EndIf
	
	If lRet
		//³Valida se a data da baixa esta igual a database                                   ³
		If Type("cListBox") <> "U"
			// 052159 || OS 053501 || FINANCAS || ANA || 8384 || ESTONO DE TITULO - FWNM - 30/09/2019 - cListBox muda dependendo da configuracao do usuario no formato da data, entre 2 e 4 digitos no ano
			//dData  := CtoD(Substr(cListBox,41,08))
			dData  := CtoD(Substr(cListBox,41,11))
			//
			cSeq   := Right(AllTrim(cListBox),2)
			cChave := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA+cSeq

			SE5->( dbSetOrder(7) ) // E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
			If SE5->( dbSeek(FWxFilial("SE5")+cChave) )
				Do While SE5->( !EOF() ) .and. SE5->E5_FILIAL+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA+SE5->E5_SEQ == FWxFilial("SE5")+cChave
					If SE5->E5_DTDISPO == dData .and. SE5->E5_SEQ == cSeq
						lEncBaixa := .T.
						dDtSE5 := SE5->E5_DTDISPO
						Exit
					Endif
					SE5->( dbSkip() )
				EndDo
			EndIf
			
			If lEncBaixa
				// Checo se o recebimento foi com CH - Nao utilizam conceito de cmp do cheque (Liber Ch)
				SEF->( dbSetOrder(3) ) // EF_FILIAL+EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+EF_NUM+EF_SEQUENC
				If SEF->( !dbSeek(xFilial("SEF")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)) )
					If dDataBase <> dDtSE5
						lRet := .F.
						// Chamado n. 051017 - FWNM - 10/09/2019
						//Aviso("FA080VEST-02","A database do sistema ("+DtoC(dDataBase)+") deve ser a mesma da data de baixa do título a pagar ("+DtoC(dDTSE5)+"). Mude a database do sistema para a data desejada. ",{"Ok"},3 ,"Atencao! Estorno não realizado...")
						Aviso("FA080VEST-02","A database do sistema ("+DtoC(dDataBase)+") não é a mesma da data de baixa do título a pagar ("+DtoC(dDTSE5)+"). Confirme se o estorno ocorrerá mesmo em database do sistema diferente... ",{"Ok"},3 ,"Atencao! Estorno em database diferente...")
						If msgYesNo("Confirma o estorno em database diferente da baixa?")
							lRet := .t.
						EndIf
						//
					Endif
				Endif
			Else
				lRet := .F.
				Aviso("FA080VEST-03","Não foi possivel localizar a baixa do titulo selecionado. ",{"Ok"},3 ,"Atencao! Estorno não realizado...")
			Endif
			
		Else
			cChave := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA
			SE5->( dbSetOrder(7) ) // E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
			If SE5->( dbSeek(FWxFilial("SE5")+cChave) )
				Do While SE5->( !EOF() ) .and. SE5->E5_FILIAL+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA == FWxFilial("SE5")+cChave
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
					// Chamado n. 051017 - FWNM - 10/09/2019
					//Aviso("FA080VEST-04","A database do sistema ("+DtoC(dDataBase)+") deve ser a mesma da data de baixa do título a pagar ("+DtoC(dDtSE5)+"). Mude a database do sistema para a data desejada. ",{"Ok"},3 ,"Atencao! Estorno não realizado...")
					Aviso("FA080VEST-04","A database do sistema ("+DtoC(dDataBase)+") não é a mesma da data de baixa do título a pagar ("+DtoC(dDTSE5)+"). Confirme se o estorno ocorrerá mesmo em database do sistema diferente... ",{"Ok"},3 ,"Atencao! Estorno em database diferente...")
					If msgYesNo("Confirma o estorno em database diferente da baixa?")
						lRet := .t.
					EndIf
					//	
				Endif
			Else
				lRet := .F.
				Aviso("FA080VEST-05","Não foi possivel localizar a baixa do titulo selecionado. ",{"Ok"},3 ,"Atencao! Estorno não realizado...")
			Endif
		Endif
	EndIf
	
	RestArea(aAreaSEF)
	RestArea(aAreaSE5)
	RestArea(aArea)

Return lRet