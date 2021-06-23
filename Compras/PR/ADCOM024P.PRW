#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"

// ############################################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : ADCOM023P
// ---------+-------------------+--------------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                    | Chamado
// ---------+-------------------+--------------------------------------------------------------+---------------
// 13/08/18 | Ricardo Lima      | Bloqueia o uso da inscrição estadual para mais de um CNPJ    | 043099
// ---------+-------------------+--------------------------------------------------------------+---------------
// ############################################################################################################
User Function ADCOM024P( A2CNPJ , A2INSCR )  //U_ADCOM024P(M->A2_CGC,M->A2_INSCR)

    Local lRet := .T.
    Local cQuery := ""
    Local nInscrA := SuperGetMv( "MV_#ADC024" , .F. , 1 ,  )

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

    cQuery := " SELECT COUNT(A2_INSCR) NUM_INSCR "
    cQuery += " FROM "+RetSqlName("SA2")+" A2 "
    cQuery += " WHERE A2_CGC = '"+A2CNPJ+"' AND A2_INSCR = '"+A2INSCR+"' "
    cQuery += " AND A2.D_E_L_E_T_ = ' ' "
    If Select("TSA2") > 0
        TSA2->(DbCloseArea())
    EndIf
    TcQuery cQuery New Alias "TSA2"

    IF TSA2->NUM_INSCR >= nInscrA
        lRet := .F.
        ApMsgInfo('Inscrição Estadual já utilizada para o mesmo CNPJ, Verifique!','Cadastro de Fornecedor')
    EndIf

Return(lRet)