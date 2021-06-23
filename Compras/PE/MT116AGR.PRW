#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} User Function MT116AGR
  PE para corrigir a natureza financeira dos títulos gerados pela rotina de Conhecimento de Frete, pois o mesmo está trazendo a natureza do fornecedor e não a natureza informada na Central XML.
  @type  Function
  @author Abel
  @since 23/03/2020
  @history Chamado n.056718 - OS n.058181 - Abel Babini - 23/03/2020 - ADM || LUCINEIA || 3575 || CTE - NATUREZA FINAN - Corrigir Natureza Financeira do título para respeitar o que foi informado pela Central XML
  /*/

USER FUNCTION MT116AGR()
  Local aArea := GetArea()
  Local cAlS116
  Local nPosNat  := aScan(aAutoCab,{ |x| Upper(AllTrim(x[1])) == "NF_NATUREZA"})
  IF INCLUI .and. ( IsInCallStack("U_CENTNFEXM") .or. IsInCallStack("U_RECNFEXML") .or. IsInCallStack("U_RECNFECTE") )
    If Select(cAlS116) > 0
      (cAlS116)->(dbCloseArea())
    Endif
    cAlS116:=GetNextAlias()

    BeginSQL  Alias cAlS116
      SELECT 
        E2_PREFIXO,
        E2_NUM,
        E2_PARCELA,
        E2_TIPO,
        E2_FORNECE,
        E2_LOJA,
        E2_NATUREZ
      FROM %TABLE:SE2% SE2
      WHERE SE2.E2_FILIAL = %xFilial:SE2%
      AND SE2.E2_PREFIXO = %Exp:SF1->F1_SERIE%
      AND SE2.E2_NUM = %Exp:SF1->F1_DOC%
      AND SE2.E2_FORNECE = %Exp:SF1->F1_FORNECE%
      AND SE2.E2_LOJA = %Exp:SF1->F1_LOJA%
      AND SE2.%notDel%
    EndSQL

    DbSelectArea(cAlS116)
    (cAlS116)->(DbGoTop())
    dbSelectArea('SE2')
    SE2->(dbSetOrder(1))
    While !(cAlS116)->(eof())
      
      IF SE2->(DbSeek(xFilial('SE2')+(cAlS116)->E2_PREFIXO+(cAlS116)->E2_NUM+(cAlS116)->E2_PARCELA+(cAlS116)->E2_TIPO+(cAlS116)->E2_FORNECE+(cAlS116)->E2_LOJA))
        IF Alltrim(SE2->E2_NATUREZ) <> Alltrim(aAutoCab[nPosNat,2])
          RECLOCK('SE2',.F.)
            SE2->E2_NATUREZ := aAutoCab[nPosNat,2]
          MSUNLOCK()
        ENDIF
      ENDIF
      (cAlS116)->(DbSkip())
    EndDo

    (cAlS116)->(dbCloseArea())
  ENDIF
  RestArea(aArea)
RETURN