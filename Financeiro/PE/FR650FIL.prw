#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function FR650FIL
    O ponto de entrada FR650FIL recebe os Títulos do arquivo de retorno de comunicação bancária.
    @type  Function
    @author FWNM
    @since 19/05/2020
    @version 01
    @history chamado 056247 - FWNM    - 19/05/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
    @history chamado 059612 - Everson - 24/07/2020 - Tratamento para títulos que não são do Bradesco.
    @history ticket 745     - FWNM    - 08/10/2020 - Retorno CNAB Cobrança - Título não encontrado
    @history ticket 3375    - FWNM    - 13/10/2020 - Adicionado o else, pois só estava funcionando para o banco bradesco que estava no IF os outros bancos estavam errados pois a varivavel lAchouTit ficava como falso. 
/*/
User Function FR650FIL()

    Local aArea      := GetArea()
    Local lAchouTit  := .f.
    Local aPARAMIXB  := PARAMIXB[1]
    Local cKey1SE1WS := Subs(AllTrim(PARAMIXB[1,14]),71,11)
    Local cKey2SE1WS := Subs(AllTrim(PARAMIXB[1,14]),135,11)
    Local cKey3SE1WS := Subs(AllTrim(PARAMIXB[1,14]),117,10) // E1_IDCNAB // @history ticket 745 - FWNM - 08/10/2020 - Retorno CNAB Cobrança - Título não encontrado
    Local cQuery     := ""
    Local lBradWS    := AllTrim(MV_PAR03) == "237"
    Local aAreaSE1   := SE1->( GetArea() )

    //Everson - 24/07/2020. Chamado 059612.
    /*
    If  !lBradWS
        RestArea(aArea)
        Return .T.
    EndIf
    */
    //

    If lBradWS .and. mv_par07 == 1 // receber

        // Chave 1
        If Select("Work") > 0
            Work->( dbCloseArea() )
        EndIf

        cQuery := " SELECT E1_NUMBCO, E1_IDCNAB, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, R_E_C_N_O_ RECNO
        cQuery += " FROM " + RetSqlName("SE1") + " (NOLOCK)
        cQuery += " WHERE E1_NUMBCO='"+cKey1SE1WS+"'
        cQuery += " AND E1_NUMBCO<>''
        cQuery += " AND D_E_L_E_T_=''

        tcQuery cQuery New Alias "Work"

        SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
        If SE1->( dbSeek( Work->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) ) )
            lAchouTit := .t.
        EndIf

        If Select("Work") > 0
            Work->( dbCloseArea() )
        EndIf

        If !lAchouTit

            // Chave 2
            If Select("Work") > 0
                Work->( dbCloseArea() )
            EndIf

            cQuery := " SELECT E1_NUMBCO, E1_IDCNAB, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, R_E_C_N_O_ RECNO
            cQuery += " FROM " + RetSqlName("SE1") + " (NOLOCK)
            cQuery += " WHERE E1_NUMBCO='"+cKey2SE1WS+"'
            cQuery += " AND E1_NUMBCO<>''
            cQuery += " AND D_E_L_E_T_=''

            tcQuery cQuery New Alias "Work"

            SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
            If SE1->( dbSeek( Work->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) ) )
                lAchouTit := .t.
            EndIf

            If Select("Work") > 0
                Work->( dbCloseArea() )
            EndIf

        EndIf

        // @history ticket 745 - FWNM - 08/10/2020 - Retorno CNAB Cobrança - Título não encontrado
        If !lAchouTit

            // Chave 3 - E1_IDCNAB
            If Select("Work") > 0
                Work->( dbCloseArea() )
            EndIf

            cQuery := " SELECT E1_NUMBCO, E1_IDCNAB, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, R_E_C_N_O_ RECNO
            cQuery += " FROM " + RetSqlName("SE1") + " (NOLOCK)
            cQuery += " WHERE E1_IDCNAB='"+cKey3SE1WS+"'
            cQuery += " AND E1_IDCNAB<>''
            cQuery += " AND D_E_L_E_T_=''

            tcQuery cQuery New Alias "Work"

            SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
            If SE1->( dbSeek( Work->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) ) )

                lAchouTit := .t.

                cNossoNum := SE1->E1_NUMBCO
                ParamIXB[1,4] := cNossoNum
                
                cNumTit   := SE1->E1_IDCNAB
                ParamIXB[1,1] := cNumTit

            EndIf

            If Select("Work") > 0
                Work->( dbCloseArea() )
            EndIf

        EndIf

        If !lAchouTit
            RestArea( aAreaSE1 )
        EndIf

    ELSE    
    
        lAchouTit := .T.

    EndIf

    //
    RestArea(aArea)
    
Return(lAchouTit)
