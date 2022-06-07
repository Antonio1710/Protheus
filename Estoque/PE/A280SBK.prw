#include "totvs.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function A280SBK
    Fechamento Estoque - Itens com Problemas
    @type  Function
    @author FWNM
    @since 24/05/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @ticket 73261 - Produtos que controlam Endereçamento com divergências entre SB9
/*/
User Function A280SBK()

    Local cQuery := ""
    Local l1End  := .F.

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    // Checo se o produto possui 1 único endereço
    cQuery := " SELECT COUNT(1) TT
    cQuery += " FROM " + RetSqlName("SBK") + " (NOLOCK)
    cQuery += " WHERE BK_FILIAL='"+FWxFilial("SBK")+"'
    cQuery += " AND BK_DATA='"+DtoS(SB9->B9_DATA)+"'
    cQuery += " AND BK_COD='"+SB9->B9_COD+"'
    cQuery += " AND BK_LOCAL='"+SB9->B9_LOCAL+"'
    cQuery += " AND D_E_L_E_T_=''

    tcQuery cQuery New Alias "Work"

    Work->( dbGoTop() )
    If Work->TT == 1
        l1End := .T.
    EndIf

    If l1End

        // Saldo Inicial do endereço
        RecLock("SBK", .F.)
            SBK->BK_QINI    := SB9->B9_QINI
            SBK->BK_QISEGUM := SB9->B9_QISEGUM
        SBK->( msUnLock() )

        // Saldo Atual do endereço
        RecLock("SBF", .F.)
            SBF->BF_QUANT   := SB2->B2_QATU
            SBF->BF_QTSEGUM := SB2->B2_QTSEGUM
        SBF->( msUnLock() )

        //gera log
        u_GrLogZBE(msDate(), TIME(), cUserName, "VIRADA SALDO","ESTOQUE","A280SBK",;
        "FIX ITENS DIF - COD/LOCAL/END " + AllTrim(SB9->B9_COD) + "/" + AllTrim(SB9->B9_LOCAL) + "/" + AllTrim(SBK->BK_LOCALIZ), ComputerName(), LogUserName())

    EndIf

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

Return

