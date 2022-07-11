#include "totvs.ch"

/*/{Protheus.doc} User Function F200BXAG
    PE retorno cobrança - Gravacao complementar dos dados da baixa aglutinada
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
User Function F200BXAG()

    Local cLog200 := ""
    Local cLog100 := ""

    cLog200 := "Lote da Baixa: " + cLoteFin +;
                " Banco/Agencia/Conta/SubConta: " + MV_PAR06 + "/" + MV_PAR07 + "/" + MV_PAR08 + "/" + MV_PAR09 +;
                " Arquivo Retorno: " + AllTrim(MV_PAR04) +;
                " Leiaute: " + AllTrim(MV_PAR05) +;
                " SEE " + AllTrim(SEE->EE_CODIGO) + "/" + AllTrim(SEE->EE_AGENCIA) + "/" + AllTrim(SEE->EE_CONTA) + "/" + AllTrim(SEE->EE_SUBCTA) + "/" + AllTrim(SEE->EE_LOTE) +;
                " SA6 " + AllTrim(SA6->A6_COD) + "/" + AllTrim(SA6->A6_AGENCIA) + "/" + AllTrim(SA6->A6_NUMCON) +;
                " Privates " + AllTrim(cBanco) + "/" + AllTrim(cAgencia) + "/" + AllTrim(cConta) + "/" + AllTrim(cSubCta)

    cLog100 := AllTrim(Str(TRB->TOTAL))

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
    u_GrLogZBE( msDate(), TIME(), cUserName, cLog200, "FINA200", "F200BXAG", cLog100, ComputerName(), LogUserName() )

Return
