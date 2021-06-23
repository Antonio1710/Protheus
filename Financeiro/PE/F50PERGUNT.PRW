#Include "RwMake.ch"

// ##############################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : F50PERGUNT
// ---------+-------------------+------------------------------------------------+---------------
// Data     | Autor             | Descricao                                      | Chamado
// ---------+-------------------+------------------------------------------------+---------------
// 12/03/18 | Ricardo Lima      | Integração no Financeiro de PA Gerada pelo SAG | 
// ---------+-------------------+------------------------------------------------+---------------
// ##############################################################################################

User Function F50PERGUNT

Local cOpc := SuperGetMv( "MV_#F50PER" , .F. , 1  ,  )

    If CEMPANT $ "01|02"
        if cOpc = 1
            MV_PAR05 := 2 // Gera Chq. para Adiantamento == Nao
            MV_PAR09 := 1 // Gera movimento sem cheque   == Sim	
        else
            MV_PAR05 := 2 // Gera Chq. para Adiantamento == Nao
            MV_PAR09 := 2 // Gera movimento sem cheque   == Nao
        endif
    Endif

Return
