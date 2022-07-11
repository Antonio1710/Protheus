#include "totvs.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function F200PORT
    PE para alterar portador
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
User Function F200PORT()

    Local lAltPort := .f.
    Local cBoxTit  := "PARAMETROS SELECIONADOS"
    Local cBoxTxt  := ""
    
    // Grava Lote
    FixLote()

    cBoxTxt  := "Lote da Baixa: " + cLoteFin + chr(13)+chr(10)+;
                "Banco/Agencia/Conta/SubConta: " + MV_PAR06 + "/" + MV_PAR07 + "/" + MV_PAR08 + "/" + MV_PAR09 + chr(13)+chr(10)+;
                "Arquivo Retorno: " + AllTrim(MV_PAR04) + chr(13)+chr(10)+;
                "Leiaute: " + AllTrim(MV_PAR05)

    MESSAGEBOX( cBoxTxt, cBoxTit, 8 )

    //gera log 
    //GrLogZBE(dDate,cTime,cUser,cLog,cModulo,cRotina,cParamer,cEquipam,cUserRed)
    u_GrLogZBE( msDate(), TIME(), cUserName, cBoxTxt, "FINA200", "F200PORT",;
    "ARQUIVO RETORNO " + AllTrim(MV_PAR04) + " LEIAUTE " + AllTrim(MV_PAR05) + " BANCO/AGENCIA/CONTA/SUBCTA " + MV_PAR06 + "/" + MV_PAR07 + "/" + MV_PAR08 + "/" + MV_PAR09, ComputerName(), LogUserName() )
    
Return lAltPort

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author FWNM
    @since 06/07/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function FixLote()

    Local nTamLote := TamSX3("EE_LOTE")[1]
    Local cFixLote := cLoteFin
    
    If Left(AllTrim(cFixLote),3) <> AllTrim(MV_PAR06)
        cFixLote := AllTrim(MV_PAR06)+StrZero(0,nTamLote-3)
    EndIf

    Do While .t.

        If Select("Work") > 0
            Work->( dbCloseArea() )
        EndIf

        cQuery := " SELECT E5_LOTE
        cQuery += " FROM " + RetSqlName("SE5") + " (NOLOCK)
        cQuery += " WHERE E5_LOTE='"+cFixLote+"' 
        cQuery += " AND D_E_L_E_T_=''

        tcQuery cQuery New Alias "Work"

        Work->( dbGoTop() )
        If Work->( !EOF() )
            cFixLote := Soma1(cFixLote)
        Else
            //gera log 
            u_GrLogZBE( msDate(), TIME(), cUserName, "FINANCEIRO", "FINA200", "F200PORT",;
            "EE_LOTE AJUSTADO DE/PARA " + SEE->EE_LOTE + "/" + cFixLote + " - BANCO/AGENCIA/CONTA/SUBCTA " + SEE->EE_CODIGO + "/" + AllTrim(SEE->EE_AGENCIA) + "/" + AllTrim(SEE->EE_CONTA) + "/" + AllTrim(SEE->EE_SUBCTA), ComputerName(), LogUserName() )
            Exit
        EndIf

    EndDo

    RecLock("SEE", .F.)
        SEE->EE_LOTE := cFixLote
    SEE->( msUnLock() )

    cLoteFin := cFixLote

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

Return
