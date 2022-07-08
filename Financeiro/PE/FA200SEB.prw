#include "totvs.ch"

/*/{Protheus.doc} User Function FA200SEB
    (long_description)
    @type  Function
    @author FWNM
    @since 06/07/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @ticket 75186 - 06/07/2022 - As baixas estão gerando totalizados em portador errado
    @ticket 75186 - 07/07/2022 - Melhoria nos logs para filtragem, análise e acompanhamento
/*/
User Function FA200SEB()

    Local lProcessa := .t.

    //gera log 
    u_GrLogZBE( msDate(), TIME(), cUserName, "LOTE: " + cLoteFin, "FINA200", "FA200SEB",;
    "RETORNO " + AllTrim(MV_PAR04) + " LEIAUTE " + AllTrim(MV_PAR05) + " BANCO/AGENCIA/CONTA/SUBCTA " + MV_PAR06 + "/" + MV_PAR07 + "/" + MV_PAR08 + "/" + MV_PAR09, ComputerName(), LogUserName() )

Return lProcessa
