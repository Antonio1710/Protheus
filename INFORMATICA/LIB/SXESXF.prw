#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function SXESXF
    Função para ser utilizada no campo X3_RELACAO em substituição do comando padrão GetSX8Num(tabela)
    @type  Function
    @author FWNM
    @since 29/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE
    @history chamado 050729 - FWNM              - 01/07/2020 - Implementações de Produto e Solicitações ao Armazém
    @history chamado 050729 - FWNM              - 03/07/2020 - Implementações checagem da origem para Solicitações ao Armazém e manutenção de ativo
    @history chamado 059977 - Adriana Oliveira  - 24/07/2020 - Desconsiderar códigos com tamanho diferente de 6 para o sequencial SA2
    @history chamado T.I.   - Everson           - 04/08/2020 - Correção de numeração das tabelas de controle de frete.
    @history ticket  39     – FWNM              - 11/11/2020 - Projeto RM
    @history ticket  3873   - Fernando Macieira - 23/11/2020 - Projeto - Contrato e Controle de Entradas - São Carlos
    @history ticket  TI     - Fernando Macieira - 01/12/2020 - Conflitos na numeração quando threads concorrentes
    @history ticket  6608   - Abel Babini       - 14/12/2020 - Correção de numeração da tabela ZAM - Inventário
    @history ticket 11556   - Fernando Macieira - 10/05/2021 - Processo Trabalhista - Títulos
    @history ticket 15111   - Abel Babini       - 07/06/2021 - Ajuste para considerar quando não existem registros na tabela
    @history ticket 68607   - Fernando Macieira - 31/03/2022 - Acordos trabalhistas
/*/
User Function SXESXF(cSX2)

    Local cNextCod := ""
    Local cQuery   := ""
    Local cFilTab  := GetMV("MV_#SXESXF",,"UNIAO|MUNIC|INPS02|INPS01|INPS|ESTADO|159938")

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    If AllTrim(cSX2) == "SA1"
        
        cQuery := " SELECT MAX(A1_COD) AS NEXT_COD "
        cQuery += " FROM " + RetSqlName("SA1") + " (NOLOCK) "
        cQuery += " WHERE A1_FILIAL='"+FWxFilial("SA1")+"' "
        cQuery += " AND A1_COD NOT IN " + FormatIn(cFilTab,"|")
        cQuery += " AND D_E_L_E_T_='' "

    ElseIf AllTrim(cSX2) == "SA2"
        
        cQuery := " SELECT MAX(A2_COD) AS NEXT_COD
        cQuery += " FROM " + RetSqlName("SA2") + " (NOLOCK)
        cQuery += " WHERE A2_FILIAL='"+FWxFilial("SA2")+"'
        cQuery += " AND A2_COD NOT IN " + FormatIn(cFilTab,"|")
        cQuery += " AND LEN(A2_COD) >= 6" // chamado 059977 - Adriana Oliveira - 24/07/2020
        cQuery += " AND A2_COD NOT LIKE 'F%' " // @history ticket 39      – FWNM    - 11/11/2020 - Projeto RM
        cQuery += " AND D_E_L_E_T_='' "

    ElseIf AllTrim(cSX2) == "SB1"
        
        cQuery := " SELECT MAX(B1_COD2) AS NEXT_COD
        cQuery += " FROM " + RetSqlName("SB1") + " (NOLOCK)
        cQuery += " WHERE B1_FILIAL='"+FWxFilial("SB1")+"'
        cQuery += " AND B1_COD NOT IN " + FormatIn(cFilTab,"|")
        cQuery += " AND D_E_L_E_T_='' "

    ElseIf AllTrim(cSX2) == "SCP" // Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - FWNM - 01/07/2020
        
        cQuery := " SELECT MAX(CP_NUM) AS NEXT_COD
        cQuery += " FROM " + RetSqlName("SCP") + " (NOLOCK)
        cQuery += " WHERE CP_FILIAL='"+FWxFilial("SCP")+"'
        cQuery += " AND CP_NUM NOT IN " + FormatIn(cFilTab,"|")

        // Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - FWNM - 03/07/2020
        If nModulo == 19 .or. Upper(AllTrim(cModulo)) == "MNT"
            cQuery += " AND CP_NUM LIKE 'S%' "
        Else
            cQuery += " AND CP_NUM NOT LIKE 'S%' "
        EndIf
        //

        cQuery += " AND D_E_L_E_T_='' "

    ElseIf AllTrim(cSX2) == "ZFA" //Everson - 04/08/2020. Chamado T.I.
        cQuery := " SELECT MAX(ZFA_COD) AS NEXT_COD "
        cQuery += " FROM " + RetSqlName("ZFA") + " (NOLOCK) "
        cQuery += " WHERE ZFA_FILIAL='"+FWxFilial("ZFA")+"' "
        cQuery += " AND D_E_L_E_T_='' "

    ElseIf AllTrim(cSX2) == "ZFK" //Everson - 04/08/2020. Chamado T.I.
        cQuery := " SELECT MAX(ZFK_COD) AS NEXT_COD "
        cQuery += " FROM " + RetSqlName("ZFK") + " (NOLOCK) "
        cQuery += " WHERE ZFK_FILIAL='"+FWxFilial("ZFK")+"' "
        cQuery += " AND D_E_L_E_T_='' "

    ElseIf AllTrim(cSX2) == "SC7" // @history ticket    3873 - Fernando Macieira - 23/11/2020 - Projeto - Contrato e Controle de Entradas - São Carlos
        
        cQuery := " SELECT MAX(C7_NUM) AS NEXT_COD
        cQuery += " FROM " + RetSqlName("SC7") + " (NOLOCK)
        cQuery += " WHERE C7_FILIAL='"+FWxFilial("SC7")+"'
        cQuery += " AND C7_NUM NOT IN " + FormatIn(cFilTab,"|")
        cQuery += " AND C7_NUM NOT LIKE 'S%' "
        cQuery += " AND D_E_L_E_T_='' "

    ElseIf AllTrim(cSX2) == "ZAM" // ticket  6608   - Abel Babini       - 14/12/2020 - Correção de numeração da tabela ZAM - Inventário
        
        cQuery := " SELECT MAX(ZAM_NUM) AS NEXT_COD
        cQuery += " FROM " + RetSqlName("ZAM") + " (NOLOCK)
        cQuery += " WHERE ZAM_FILIAL='"+FWxFilial("ZAM")+"'
        cQuery += " AND ZAM_NUM NOT IN " + FormatIn(cFilTab,"|")
        cQuery += " AND D_E_L_E_T_='' "

    ElseIf AllTrim(cSX2) == "RC1" // @history ticket 11556   - Fernando Macieira - 10/05/2021 - Processo Trabalhista - Títulos
        
        cQuery := " SELECT MAX(RC1_NUMTIT) AS NEXT_COD 
        cQuery += " FROM " + RetSqlName("RC1") + " (NOLOCK) 
        cQuery += " WHERE RC1_FILIAL='"+FWxFilial("RC1")+"' 
        cQuery += " AND D_E_L_E_T_='' 

    ElseIf AllTrim(cSX2) == "ZHC" // @history ticket 68607   - Fernando Macieira - 31/03/2022 - Acordos trabalhistas
        
        cQuery := " SELECT MAX(ZHC_CODIGO) AS NEXT_COD
        cQuery += " FROM " + RetSqlName("ZHC") + " (NOLOCK)
        cQuery += " WHERE ZHC_FILIAL='"+FWxFilial("ZHC")+"'
        cQuery += " AND D_E_L_E_T_='' "

    EndIf                                          

    tcQuery cQuery New Alias "Work"

    // @history ticket 68607   - Fernando Macieira - 31/03/2022 - Acordos trabalhistas
    If Empty(AllTrim(Work->NEXT_COD))
        cNextCod := Soma1(Work->NEXT_COD)
    Else
        cNextCod := Soma1(AllTrim(Work->NEXT_COD))
    EndIf

    /*
    //ticket 15111   - Abel Babini       - 07/06/2021 - Ajuste para considerar quando não existem registros na tabela
    IF AllTrim(Work->NEXT_COD) == ''
        cNextCod := '1'
    ELSE
        cNextCod := Soma1(AllTrim(Work->NEXT_COD))
    ENDIF
    */

    //

    // Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - FWNM - 01/07/2020
    If AllTrim(cSX2) == "SB1"

        Do While .T.

            If Select("WorkB1COD2") > 0
                WorkB1COD2->( dbCloseArea() )
            EndIf

            cQuery := " SELECT COUNT(1) TT
            cQuery += " FROM " + RetSqlName("SB1") + " (NOLOCK)
            cQuery += " WHERE B1_COD LIKE '%"+cNextCod+"'
            cQuery += " AND D_E_L_E_T_='' 

            tcQuery cQuery New Alias "WorkB1COD2"

            If WorkB1COD2->TT >= 1

                cNextCod := Soma1(AllTrim(cNextCod))

            Else

                RecLock("SB1", .F.)
                    SB1->B1_COD2 := cNextCod
                SB1->( msUnLock() )

                Exit
            
            EndIf

        EndDo

        If Select("WorkB1COD2") > 0
            WorkB1COD2->( dbCloseArea() )
        EndIf

    EndIf
    //

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    // @history ticket  TI     - Fernando Macieira - 01/12/2020 - Conflitos na numeração quando threads concorrentes
    ChkCodMem(@cNextCod, cSX2)

    dbSelectArea(cSX2)
    ConfirmSX8()
    //

Return cNextCod

/*/{Protheus.doc} Static Function ChkCodMem()
    Checa codigos reservados em memoria
    @type  Static Function
    @author Fernando Macieira
    @since 01/12/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    ticket  TI     - Fernando Macieira - 01/12/2020 - Conflitos na numeração quando threads concorrentes
/*/
Static Function ChkCodMem(cNextCod, cSX2)

    Local cQuery := ""
    Local lTemX5 := .f.
    Local cTabX5 := GetMV("MV_#SXESTB",,"X8")

    Do While .t.

        lTemX5 := .f.

        If Select("WorkX5") > 0
            WorkX5->( dbCloseArea() )
        EndIf

        cQuery := " SELECT ISNULL(MAX(X5_DESCRI),0) AS COD_MEM
        cQuery += " FROM " + RetSqlName("SX5") + " (NOLOCK)
        cQuery += " WHERE X5_FILIAL='"+FWxFilial("SX5")+"' 
        cQuery += " AND X5_TABELA='"+cTabX5+"'
        cQuery += " AND X5_CHAVE='"+AllTrim(FWxFilial(cSX2)) + AllTrim(cSX2)+"' 
        cQuery += " AND X5_DESCRI='"+AllTrim(cNextCod)+"' 
        cQuery += " AND D_E_L_E_T_=''

        tcQuery cQuery New Alias "WorkX5"

        WorkX5->( dbGoTop() )

        If WorkX5->( !EOF() ) .and. AllTrim(WorkX5->COD_MEM) <> "0"
            lTemX5 := .t.
        EndIf

        If lTemX5
            cNextCod := Soma1(AllTrim(WorkX5->COD_MEM))
        Else
            Exit
        EndIf

    EndDo

    // Gravo em memoria o numero reservado
    If AllTrim(cNextCod) <> "0"
        RecLock("SX5", .T.)
            SX5->X5_FILIAL := FWxFilial("SX5")
            SX5->X5_TABELA := cTabX5
            SX5->X5_CHAVE  := AllTrim(FWxFilial(cSX2)) + AllTrim(cSX2)
            SX5->X5_DESCRI := cNextCod
        SX5->( msUnLock() )
    EndIf

    If Select("WorkX5") > 0
        WorkX5->( dbCloseArea() )
    EndIf
    
Return
