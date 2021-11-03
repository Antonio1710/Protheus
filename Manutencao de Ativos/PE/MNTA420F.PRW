#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} User Function MNTA420F()
  Checagem de validação antes da exclusão da O.S na tela da OS Corretiva
  @type  Function
  @author Tiago Stocco
  @since 18/10/202
/*/	

User Function MNTA420F()

Local cOS       := STJ->TJ_ORDEM
Local cOP       := Alltrim(cOS)+"OS001"
Local cAliasC1  := "TMPSC1"
Local cAliasC7  := "TMPSC7"
Local cQryC1    := ""
Local cQryC7    := ""
Local usrCancOS := SuperGetMV("MV_#USRCOS",.F.,"000000")

If Alltrim(RetCodUsr()) $ usrCancOS
    cQryC1  := " SELECT * "
    cQryC1  += " FROM " + RetSqlName("SC1") + " SC1 "
    cQryC1  += " WHERE "
    cQryC1  += " C1_FILIAL = '"+xFilial("SC1")+"' "
    cQryC1  += " AND C1_OP = '"+cOP+"' "
    cQryC1  += " AND SC1.D_E_L_E_T_ = '' "
    IF Select (cAliasC1) > 0
	    (cAliasC1)->(DbCloseArea())
    EndIf
    DbUseArea(.T., "TOPCONN", TcGenQry(,,cQryC1), cAliasC1)
    DbSelectArea(cAliasC1)
    DbGotop()
   If (cAliasC1)->(!EOF())
        MSGALERT("A ordem não pode ser cancelada pois existem SC vinculadas a Ordem, exclua a SC para poder cancelar a OS.", "PE:MNTA400G" )
        (cAliasC1)->(DbCloseArea())
        Return .F.
    ENDIF

    cQryC7  := " SELECT * "
    cQryC7  += " FROM " + RetSqlName("SC7") + " SC7 "
    cQryC7  += " WHERE "
    cQryC7  += " C7_FILIAL = '"+xFilial("SC7")+"' "
    cQryC7  += " AND C7_OP = '"+cOP+"' "
    cQryC7  += " AND SC7.D_E_L_E_T_ = '' "
    IF Select (cAliasC7) > 0
	    (cAliasC7)->(DbCloseArea())
    EndIf
    DbUseArea(.T., "TOPCONN", TcGenQry(,,cQryC7), cAliasC7)
    DbSelectArea(cAliasC7)
    DbGotop()
    If (cAliasC7)->(!EOF())
        (cAliasC7)->(DbCloseArea())
        MSGALERT("A ordem não pode ser cancelada pois existem PC vinculados a Ordem, exclua o Pedido de Compra para poder cancelar a OS.", "PE:MNTA400G" )
        Return .F.
    ENDIF
Else
    MSGALERT("Você não tem permissão de Cancelar OS", "PE:MNTA420F - MV_#USRCOS" )
    Return .F.
EndIf

Return .t.

