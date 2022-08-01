#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"

Static cTbMast := "ZHY"
Static cTitulo := "Visita Promotor"
Static cTiMast := "Dados da visita promotor"

Static xPula := Chr(13) + Chr(10)

/*/{Protheus.doc} User Function ADVEN110P
    Visita Esporadica Promotor
    @type  Function
    @author Everson
    @since 31/07/2022
    /*/
User Function ADVEN110P() // U_ADVEN110P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADVEN110P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
Static Function BrowseDef()

    //Variáveis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    oBrowse:SetMenuDef("ADVEN110P")

    oBrowse:SetFilterDefault(" " + cTbMast + "_FILIAL = '" + FWxFilial(cTbMast) + "' ")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
Static Function MenuDef()

    //Variáveis.
	Local aRotina 	:= {}

	ADD OPTION aRotina TITLE "Pesquisar"    ACTION "PesqBrw"          	OPERATION 1   ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.ADVEN110P" 	OPERATION MODEL_OPERATION_VIEW      ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" 	    ACTION "U_ADVN1105()" 	    OPERATION MODEL_OPERATION_INSERT    ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"      ACTION "U_ADVN1103(4)" 	    OPERATION MODEL_OPERATION_UPDATE    ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" 	    ACTION "U_ADVN1103(5)" 	    OPERATION MODEL_OPERATION_DELETE    ACCESS 0
    ADD OPTION aRotina TITLE "Proc Integr." ACTION "U_ADVN1101()"       OPERATION 10  ACCESS 0

Return aRotina
/*/{Protheus.doc} User Function ADVN1105
    Inclusão.
    @type  Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
User Function ADVN1105()

    //Variáveis.
    Local aArea := GetArea()
    
    FWExecView("", "ADVEN110P", 3)

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} User Function ADVN1103
    Alteração e exclusão.
    @type  Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
User Function ADVN1103(nOPc)

    //Variáveis.
    Local aArea := GetArea()
    
    FWExecView("", "ADVEN110P", nOPc)

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local oModel    := Nil
    Local oStrMast  := FWFormStruct(1, cTbMast, {|cCampo| AllTRim(cCampo) $ getCmps()})
    Local oStrGrid  := FWFormStruct(1, cTbMast)
 
    oModel := MPFormModel():New("ADVN110", /*bPreValidacao*/, , /*bCommit*/, /*bCancel*/ )
 
    oModel:AddFields("MD_MASTER", NIL, oStrMast)
    oModel:AddGrid("MD_GRID", "MD_MASTER", oStrGrid, ,)
 
    oModel:SetRelation("MD_GRID", {;
            {"ZHY_FILIAL", 'FWxFilial("' + cTbMast + '")'},;
            {"ZHY_NUMERO", "ZHY_NUMERO"},;
            {"ZHY_DESC"  , "ZHY_DESC"},;
            {"ZHY_DTINI" , "ZHY_DTINI"},;
            {"ZHY_TIPO"  , "ZHY_TIPO"};
        }, (cTbMast)->(IndexKey(1)))

    oModel:GetModel("MD_GRID"):SetUniqueLine({"ZHY_PROMOT", "ZHY_CLIENT", "ZHY_LOJA"})

    oModel:SetDescription(cTiMast)
    oModel:SetPrimaryKey({})

Return oModel
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oView     := Nil
    Local oModel    := FWLoadModel("ADVEN110P")
    Local cCampos   := getCmps()
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
 
    oView:AddIncrementField("VW_GRID", "ZHY_ITEM")

Return oView
/*/{Protheus.doc} gridFocus
    Função executada quando a grid ganha foco.
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
Static Function gridFocus(oView)

    //Variáveis.
    Local aArea   := GetArea()
    Local oModel  := oView:GetModel()
    Local cDesc   := oModel:GetValue("MD_MASTER","ZHY_DESC")
    Local cDtIni  := oModel:GetValue("MD_MASTER","ZHY_DTINI")

    If Empty(cDesc)
        Help(Nil, Nil, "Função gridFocus(ADVEN110P)", Nil, "Necessário informar a descrição.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZHY_DESC"):OCtrl:SetFocus()

    ElseIf Empty(cDtIni)
        Help(Nil, Nil, "Função gridFocus(ADVEN110P)", Nil, "Necessário informar a data de início.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZHY_DTINI"):OCtrl:SetFocus()

    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} getCmps
    Retorna campos do cabeçalho.
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
Static Function getCmps()
Return "ZHY_FILIAL;ZHY_NUMERO;ZHY_DESC;ZHY_DTINI;ZHY_TIPO;"
/*/{Protheus.doc} ADVN1101
    Integra registros de visitas.
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
User Function ADVN1101()

    //Variáveis.
    Local aArea     := GetArea()
    Local lReRest   := .F.
    Local cUrl      := Alltrim(cValToChar(GetMV("MV_#VEN591",,"http://3.23.20.133:8082/api")))
    Local cToken    := ""
    Local cMsgError := ""
    Local cQuery    := ""
    Local data      := ""
    Local portfolio := ""
    Local cCliente  := ""
    Local cLoja     := ""
    Local cTopico   := ""
    Local cTipo     := ""
    Local cHInicio  := ""
    Local cHFim     := ""
    Local cDiaSema  := ""
    Local cData     := ""

    MsAguarde({|| lReRest := U_ADVEN592(cUrl, @cToken, @cMsgError) }, "Função ADVN1101(ADVEN110P)", "Efetuando login...")

	If ! lReRest
		MsgInfo("Não foi possível efetuar login " + xPula + cMsgError, "Função ADVN1101(ADVEN110P)")
		RestArea(aArea)
		Return Nil

	EndIf

    cDiaSema := cValToChar(Dow(Date()+1))

    cQuery := ""
    cQuery += " SELECT *, " 


    If cDiaSema == "2"
        cQuery += " ZHY_SEGUND AS HORARIO " 

    ElseIf cDiaSema == "3"
        cQuery += " ZHY_TERCA AS HORARIO " 

    ElseIf cDiaSema == "4"
        cQuery += " ZHY_QUARTA AS HORARIO' " 

    ElseIf cDiaSema == "5"
        cQuery += " ZHY_QUINTA AS HORARIO " 

    ElseIf cDiaSema == "6"
        cQuery += " ZHY_SEXTA AS HORARIO " 

    EndIf

    cQuery += " FROM " 
        cQuery += " " + RetSqlName("ZHY") + " (NOLOCK) AS ZHY " 
    cQuery += " WHERE " 
        cQuery += " ZHY_FILIAL = '" + FWxFilial("ZHY") + "' " 

    If cDiaSema == "2"
        cQuery += " AND ZHY_SEGUND <> '' " 

    ElseIf cDiaSema == "3"
        cQuery += " AND ZHY_TERCA <> '' " 

    ElseIf cDiaSema == "4"
        cQuery += " AND ZHY_QUARTA <> '' " 

    ElseIf cDiaSema == "5"
        cQuery += " AND ZHY_QUINTA <> '' " 

    ElseIf cDiaSema == "6"
        cQuery += " AND ZHY_SEXTA <> '' " 

    EndIf

    cQuery += " AND D_E_L_E_T_ = '' " 

	If Select("D_VISPRO") > 0
		D_VISPRO->(DbCloseArea())

	EndIf

	TcQuery cQuery New Alias "D_VISPRO"
	DbSelectArea("D_VISPRO")
	D_VISPRO->(DbGoTop())

    While ! D_VISPRO->(Eof())

        cData    := DToS(Date()+1)

        data      := SubStr(cData, 1, 4) + "-" + Padl(SubStr(cData, 5, 2), 2, "0") + "-" + Padl(SubStr(cData, 8, 2), 2, "0")
        portfolio := Alltrim(cValToChar(D_VISPRO->ZHY_PROMOT))
        cCliente  := Alltrim(cValToChar(D_VISPRO->ZHY_CLIENT))
        cLoja     := Alltrim(cValToChar(D_VISPRO->ZHY_LOJA))
        cTopico   := "Visita de Rotina"
        cTipo     := "programed"
        cHInicio  := Padl(Alltrim(cValToChar(D_VISPRO->HORARIO)), 2, "0") + ":00" 
        cHFim     := Padl(Alltrim(cValToChar(Val(D_VISPRO->HORARIO)+1)), 2, "0") + ":00" 

        MsAguarde({|| U_ADVN1092(.F., cUrl, cToken,;
                                 data, portfolio, cCliente, cLoja, cTopico, cTipo, cHInicio, cHFim) }, "Função ADVN1101(ADVEN110P)", "Enviando visitas...")

        D_VISPRO->(DbSkip())

	End

	D_VISPRO->(DbCloseArea())

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADVN1102
    Job para integrar registros de visitas.
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
User Function ADVN1102() // U_ADVN1102()

    RPCSetType(3)
	RpcSetEnv("01","02",,,,GetEnvServer(),{ })

        U_ADVN1101()

	RpcClearEnv()

Return Nil
