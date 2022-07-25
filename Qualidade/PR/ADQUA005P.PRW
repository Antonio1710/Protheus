#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZHU"
Static cTitulo := "Item Análise Laboratorial"
Static cTiMast := "Item Dados da Análise Laboratorial"

Static cTipoD  := "1"

/*/{Protheus.doc} User Function ADQUA005P
    Item Análise laboratorial
    Chamado 18465.
    @type  Function
    @author Everson
    @since 25/07/2022
    @version 01
/*/
User Function ADQUA005P() // U_ADQUA005P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADQUA005P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 25/07/2022
    @version 01
/*/
Static Function BrowseDef()

    //Variáveis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    // oBrowse:SetFilterDefault(" " + cTbMast + "_FILIAL = '" + FWxFilial(cTbMast) + "' ")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 25/07/2022
    
    @version 01
/*/
Static Function MenuDef()

    //Variáveis
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ADFAT015P" OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"    ACTION "U_ADQUA51()"       OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"    ACTION "U_ADQUA52(4)"      OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"    ACTION "U_ADQUA52(5)"      OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Imprimir"   ACTION "VIEWDEF.ADFAT015P" OPERATION 8 ACCESS 0

Return aRotina
/*/{Protheus.doc} User Function ADQUA51
    Inclusão de item de análise.
    @type  Function
    @author Everson
    @since 25/07/2022
    @version 01
/*/
User Function ADQUA51()

    //Variáveis.
    Local aArea := GetArea()
    
    //Tipo de dado.
    If ! Pergunte("ADQUA0051",.T.)
        RestArea(aArea)
        Return Nil

    EndIf

    cTipoD := Alltrim(cValToChar(MV_PAR01))

    If Empty(cTipoD)
        RestArea(aArea)
        Return Nil

    EndIF

    FWExecView("", "ADQUA005P", 3)

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} User Function ADQUA52
    Alteração de item de análise.
    @type  Function
    @author Everson
    @since 25/07/2022
    @version 01
/*/
User Function ADQUA52(nOPc)

    //Variáveis.
    Local aArea := GetArea()

    cTipoD := ZHU->ZHU_TPDADO

    FWExecView("", "ADQUA005P", nOPc)

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} User Function ADQUA53
    Tipo de dado.
    @type  Function
    @author Everson
    @since 25/07/2022
    @version 01
/*/
User Function ADQUA53()
Return cTipoD
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 25/07/2022
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local oModel    := Nil
    Local oStrMast  := FWFormStruct(1, cTbMast, {|cCampo| AllTRim(cCampo) $ getCampos()})
    Local oStrGrid  := FWFormStruct(1, cTbMast)
 
    oModel := MPFormModel():New("ADQUA5", /*bPreValidacao*/, /*{|oModel| fValidGrid(oModel)}*/, /*bCommit*/, /*bCancel*/ )
 
    oModel:AddFields("MD_MASTER", NIL, oStrMast)
    oModel:AddGrid("MD_GRID", "MD_MASTER", oStrGrid, ,)
 
    oModel:SetRelation("MD_GRID", {;
            {"ZHU_FILIAL", 'FWxFilial("' + cTbMast + '")'},;
            {"ZHU_NUMERO", "ZHU_NUMERO"},;
            {"ZHU_NOME"  , "ZHU_NOME"},;
            {"ZHU_TPDADO", "ZHU_TPDADO"},;
            {"ZHU_UN"    , "ZHU_UN"};
        }, (cTbMast)->(IndexKey(1)))

    oModel:SetDescription(cTiMast)
    oModel:SetPrimaryKey({"ZHU_FILIAL","ZHU_NUMERO"})

Return oModel
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 25/07/2022
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oView     := Nil
    Local oModel    := FWLoadModel("ADQUA005P")
    Local cCampos   := getCampos()
    Local oStrMast  := FWFormStruct(2, cTbMast, {|cCampo| AllTRim(cCampo) $ cCampos})
    Local oStrGrid  := FWFormStruct(2, cTbMast, {|cCampo| !(Alltrim(cCampo) $ cCampos)})

    oView:= FWFormView():New() 
    oView:SetModel(oModel)              
 
    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")
    oView:AddGrid("VW_GRID",    oStrGrid, "MD_GRID",,{|| gridFocus(oView) })
 
    oView:CreateHorizontalBox("MAIN", 25)
    oView:CreateHorizontalBox("GRID", 75)

    oView:SetOwnerView("VW_MASTER", 'MAIN')
    oView:SetOwnerView("VW_GRID", 'GRID')
    oView:EnableControlBar(.T.)
 
    oView:AddIncrementField("VW_GRID", "ZHU_ITEM")

    If cTipoD == "1"
        oStrGrid:RemoveField("ZHU_MINIMO")
        oStrGrid:RemoveField("ZHU_MAXIMO")
        
    ElseIf cTipoD == "2"
        oStrGrid:RemoveField("ZHU_VLRTXT")

    EndIf

Return oView
/*/{Protheus.doc} gridFocus
    Função executada quando a grid ganha foco.
    @type  Static Function
    @author Everson
    @since 25/07/2022
    @version 01
/*/
Static Function gridFocus(oView)

    //Variáveis.
    Local aArea   := GetArea()
    Local oModel  := oView:GetModel()
    Local cNome   := oModel:GetValue("MD_MASTER","ZHU_NOME")
    //Local cTpDado := oModel:GetValue("MD_MASTER","ZHU_TPDADO")
    Local cUnidade:= oModel:GetValue("MD_MASTER","ZHU_UN")

    If Empty(cNome)
        Help(Nil, Nil, "Função gridFocus(ADQUA005P)", Nil, "Necessário informar o nome do item.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZHU_NOME"):OCtrl:SetFocus()
        Return Nil
    
    // ElseIf Empty(cTpDado)
    //     Help(Nil, Nil, "Função gridFocus(ADQUA005P)", Nil, "Necessário informar o tipo do dado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
    //     oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZHU_TPDADO"):OCtrl:SetFocus()

    ElseIf Empty(cUnidade)
        Help(Nil, Nil, "Função gridFocus(ADQUA005P)", Nil, "Necessário informar a unidade de medida.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZHU_UN"):OCtrl:SetFocus()
    
    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} getCampos
    Retorna campos do cabeçalho.
    @type  Static Function
    @author Everson
    @since 25/07/2022
    @version 01
/*/
Static Function getCampos()
Return "ZHU_FILIAL;ZHU_NUMERO;ZHU_NOME;ZHU_TPDADO;ZHU_UN;"
