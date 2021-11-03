#Include "Protheus.ch"

/*/{Protheus.doc} User Function MTA110EC
    Ponto de entrada bloqueia a edição de campos do cabeçalho da Solicitação de Compras.
    https://tdn.totvs.com/pages/releaseview.action?pageId=347441557
    @type  Function
    @author Everson
    @since 08/10/2021
    @version 01
    /*/
User Function MTA110EC()

    //Variáveis.
    Local aArea   := GetArea()
    Local cCampos := ""
    Local cFil    := GetMv("MV_#COMSC",,"")

    //
    If ALTERA .And. cFilAnt $cFil
        cCampos := "C1_CODCOMP"

    EndIf

    //
    RestArea(aArea)

Return cCampos
