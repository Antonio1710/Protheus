#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function F370E5F
    Ponto Entrada CTBAFIN para filtrar registros do SE5
    @type  Function
    @author FWNM
    @since 17/09/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history ticket 1678 - Duplicidade lote no contábil
    @history ticket 2144 - FWNM - 05/10/2020 - Baixas nos pagamentos não subiram para a contabilidade.
    @history ticket 9237 - Leonardo P. Monteiro - 09/02/2021 - Melhoria na performance e custo de execução da consulta SQL.
/*/
User Function F370E5F()

    Local cQry       := PARAMIXB
    Local cFilDuplic := ""
    Local cQuery     := ""

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    cQry := ChangeQuery(cQry)
    tcQuery cQry New Alias "Work"

    Work->( dbGoTop() )
    Do While Work->( !EOF() )

        // CV3
        If Select("WorkCV3") > 0
            WorkCV3->( dbCloseArea() )
        EndIf

        //Ticket 2144 - FWNM - 05/10/2020 - Baixas nos pagamentos não subiram para a contabilidade.
        //Ticket 9237 - Leonardo P. Monteiro - 09/02/2021 - Melhoria na performance e custo de execução da consulta SQL.
        cQuery := " SELECT CV3_RECDES
        cQuery += " FROM " + RetSqlName("CV3") + " (NOLOCK)
        cQuery += " WHERE CV3_FILIAL='"+ xFilial("CV3") +"' AND CV3_TABORI='SE5' " 
        cQuery += " AND CV3_RECORI='"+AllTrim(Str(Work->SE5RECNO))+"' "
        cQuery += " AND D_E_L_E_T_='' "

        tcQuery cQuery New Alias "WorkCV3"

        WorkCV3->( dbGoTop() )
        If WorkCV3->( !EOF() )

            Do While WorkCV3->( !EOF() ) // ticket 2144 - FWNM - 05/10/2020 - Baixas nos pagamentos não subiram para a contabilidade
            
                // CT2
                If Select("WorkCT2") > 0
                    WorkCT2->( dbCloseArea() )
                EndIf
                
                cQuery := " SELECT COUNT(1) TTCT2
                cQuery += " FROM " + RetSqlName("CT2") + " (NOLOCK)
                cQuery += " WHERE R_E_C_N_O_='"+AllTrim(WorkCV3->CV3_RECDES)+"' 
                cQuery += " AND D_E_L_E_T_=''

                tcQuery cQuery New Alias "WorkCT2"

                If WorkCT2->TTCT2 >= 1 
                    // Registro já contabilizado!
                    cFilDuplic += AllTrim(Str(Work->SE5RECNO)) + "|"
                EndIf

                If Select("WorkCT2") > 0
                    WorkCT2->( dbCloseArea() )
                EndIf

                WorkCV3->( dbSkip() ) // ticket 2144 - FWNM - 05/10/2020 - Baixas nos pagamentos não subiram para a contabilidade

            EndDo

        EndIf

        If Select("WorkCV3") > 0
            WorkCV3->( dbCloseArea() )
        EndIf
        // 

        Work->( dbSkip() )

    EndDo

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    // Retiro os registros já contabilizados!
    If !Empty(AllTrim(cFilDuplic))
        cQry := cQry + " AND SE5.R_E_C_N_O_ NOT IN " + FormatIn(cFilDuplic,"|")
    EndIf

Return cQry
