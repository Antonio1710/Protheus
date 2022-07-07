#include "totvs.ch"

/*/{Protheus.doc} User Function F200GLOG
    PE retorno cobrança - Se baixou o titulo e existir o arquivo de LOG, grava as informacoes pertinentes para futuro reprocessamento se preciso for.
    Tabelas FI0 e FI1
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
User Function F200GLOG()

    Local lPELog := .t.
    Local cLog200 := ""
    Local cLog100 := ""

    cLog200 := "Lote da Baixa: " + cLoteFin +;
                " Banco/Agencia/Conta/SubConta: " + MV_PAR06 + "/" + MV_PAR07 + "/" + MV_PAR08 + "/" + MV_PAR09 +;
                " Arquivo Retorno: " + AllTrim(MV_PAR04) +;
                " Leiaute: " + AllTrim(MV_PAR05)

    cLog100 := "E1_FILIAL/E1_PREFIXO/E1_NUM/E1_PARCELA/E1_TIPO " + SE1->E1_FILIAL+"/"+SE1->E1_PREFIXO+"/"+SE1->E1_NUM+"/"+SE1->E1_PARCELA+"/"+SE1->E1_TIPO

    //gera log 
    /*
    ZBE_LOG	varchar	no	200
    ZBE_PARAME	varchar	no	100
    ZBE_MODULO	varchar	no	20
    ZBE_ROTINA	varchar	no	20
    ZBE_EQUIPA	varchar	no	40
    ZBE_USURED	varchar	no	40

  	Replace ZBE_LOG	    WITH ALLTRIM(cLog)
  	Replace ZBE_MODULO	WITH cModulo
  	Replace ZBE_ROTINA	WITH cRotina
  	Replace ZBE_PARAME  WITH ALLTRIM(cParamer)
  	Replace ZBE_EQUIPA  WITH UPPER(Alltrim(cEquipam))
  	Replace ZBE_USURED  WITH UPPER(Alltrim(cUserRed))
    */

    //GrLogZBE(dDate,cTime,cUser,cLog,cModulo,cRotina,cParamer,cEquipam,cUserRed)
    u_GrLogZBE( msDate(), TIME(), cUserName, cLog200, "FINA200", "F200GLOG", cLog100, ComputerName(), LogUserName() )

Return lPELog
