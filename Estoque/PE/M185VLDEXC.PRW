#Include "Protheus.ch"
/*/{Protheus.doc} User Function M185VLDEXC
    Ponto de entrada valida exclusão de pré-requisição.
    https://tdn.totvs.com/display/public/PROT/M185VLDEXC.
    @type  Function
    @author Everson
    @since 16/06/2020
    @version 01
    /*/
User Function M185VLDEXC()

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .T.

    //
    If ! Empty(Alltrim(SCP->CP_XCOMBUS)) 
        MsgStop("Registro lançado por processo automático não pode ser excluído.","Função M185VLDEXC(M185VLDEXC)")
        lRet := .F.

    EndIf

    //
    RestArea(aArea)

Return lRet