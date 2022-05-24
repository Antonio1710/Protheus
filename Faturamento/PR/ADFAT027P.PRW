#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"

Static cTbMast := "ZIQ"
Static cTitulo := "Registro do Barramento"
Static cTiMast := "Dados do registro do barramento"

Static xPula   := Chr(13) + Chr(10)

/*/{Protheus.doc} User Function ADFAT027P
    Cadastro de Registro do Barramento.
    Cad Registro do Barramento
    Chamado 18465.
    @type  Function
    @author Everson
    @since 08/02/2022
    @version 01
    @history Everson, 25/03/2022. Criado parâmetro para gravar ou não dados na tabela ZIQ.
    /*/
User Function ADFAT027P() // U_ADFAT027P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADFAT027P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 08/02/2022
    @version 01
/*/
Static Function BrowseDef()

    //Variáveis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)
    oBrowse:SetMenuDef("ADFAT027P")

    oBrowse:AddLegend("ZIQ_PROCES = '2'", "BLUE", "Não Processado") 

    oBrowse:AddLegend("ZIQ_TIPO = 'S' .And. ZIQ_PROCES = '1' .And. ZIQ_STATPR = '2'", "RED", "Processado com erro") 
    oBrowse:AddLegend("ZIQ_TIPO = 'S' .And. ZIQ_PROCES = '1' .And. ZIQ_STATPR = '1'", "GREEN", "Processado") 

    oBrowse:AddLegend("ZIQ_TIPO = 'E' .And. ZIQ_PROCES = '1' .And. ZIQ_STATPR = '2'", "RED", "Processado com erro") 
    oBrowse:AddLegend("ZIQ_TIPO = 'E' .And. ZIQ_PROCES = '1' .And. ZIQ_STATPR = '1'", "GREEN", "Processado") 

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 08/02/2022
    @version 01
/*/
Static Function MenuDef()

    //Variáveis.
	Local aRotina 	:= {}

	ADD OPTION aRotina TITLE "Pesquisar"    ACTION "PesqBrw"          	OPERATION 1   ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.ADFAT027P" 	OPERATION MODEL_OPERATION_VIEW      ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" 	    ACTION "VIEWDEF.ADFAT027P" 	OPERATION MODEL_OPERATION_INSERT    ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"      ACTION "VIEWDEF.ADFAT027P" 	OPERATION MODEL_OPERATION_UPDATE    ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" 	    ACTION "VIEWDEF.ADFAT027P" 	OPERATION MODEL_OPERATION_DELETE    ACCESS 0
    ADD OPTION aRotina TITLE "Proc Integr." ACTION "U_ADFAT27A()"       OPERATION 10  ACCESS 0

Return aRotina
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 08/02/2022
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local bPre      := {|| .T. }
    Local bPost     := {|| .T. }
    Local bCancel   := {|| .T. }
    Local oModel    := MPFormModel():New("ADFAT27", bPre, bPost, /*bCommit*/, bCancel)
    Local oStrMast  := FwFormStruct(1, cTbMast)                                                
     
    //AddFields(<cId >, <cOwner >, <oModelStruct >, <bPre >, <bPost >, <bLoad >)
    oModel:AddFields("MD_MASTER", Nil, oStrMast)

    oModel:SetPrimaryKey({})

    oModel:SetDescription(cTitulo)

    oModel:GetModel("MD_MASTER"):SetDescription(cTiMast)

Return oModel
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 08/02/2022
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oView     := FwFormView():New()
    Local oModel    := FwLoadModel("ADFAT027P")
    Local oStrMast  := FwFormStruct(2, cTbMast)

    oView:SetModel(oModel)

    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")

Return oView
/*/{Protheus.doc} ADFAT27A
    Processa registros pendentes de integração vindos do barramento.
    @type  User Function
    @author Everson
    @since 10/02/2022
    @version 01
/*/
User Function ADFAT27A()

    //Variáveis.
    Local aArea := GetArea()

    MsAguarde({|| U_ADFAT29A() }, "Aguarde", "Processando...", .F.)

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFAT27B
    Gera registro para envio ao barramento.
    @type  User Function
    @author Everson
    @since 11/02/2022
    @version 01
/*/
User Function ADFAT27B(cOperacao, cTopico, cId, cDados, cData, cHora, cTipo, cChave, cEmpD, cFilD)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel    := Nil 
    Local aError    := {} 
    Local cMsgError := ""
    Local lGrvZIQ   := GetMv("MV_#GRVZIQ",,.F.) //Everson - 25/03/2022. Chamado 18465.

    Default cChave  := ""
    Default cTipo   := "S"
    Default cEmpD   := cEmpAnt
    Default cFilD   := cFilAnt

    If ! lGrvZIQ
        RestArea(aArea)
        Return .T.

    EndIf

    If Empty(cDados)
        RestArea(aArea)
        Return lRet

    EndIf

    oModel := FwLoadModel("ADFAT027P")
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()

    oModel:SetValue("MD_MASTER", "ZIQ_TIPO", cTipo)
    oModel:SetValue("MD_MASTER", "ZIQ_EMPRES", cEmpD)
    oModel:SetValue("MD_MASTER", "ZIQ_FILINT", cFilD)
    oModel:SetValue("MD_MASTER", "ZIQ_OPERAC", cOperacao)
    oModel:SetValue("MD_MASTER", "ZIQ_DTGRV", Date())
    oModel:SetValue("MD_MASTER", "ZIQ_HRGRV", Time())
    oModel:SetValue("MD_MASTER", "ZIQ_SISGER", "PROTHEUS")
    oModel:SetValue("MD_MASTER", "ZIQ_TOPICO", cTopico)
    oModel:SetValue("MD_MASTER", "ZIQ_UUID", cId)
    oModel:SetValue("MD_MASTER", "ZIQ_DADOS", cDados)
    oModel:SetValue("MD_MASTER", "ZIQ_DTORIG", SToD(cData))
    oModel:SetValue("MD_MASTER", "ZIQ_HRORIG", cHora)
    oModel:SetValue("MD_MASTER", "ZIQ_PROCES", "2")
    oModel:SetValue("MD_MASTER", "ZIQ_HASH"  , SHA1(cDados))
    oModel:SetValue("MD_MASTER", "ZIQ_CHAVE" , cChave)

    If oModel:VldData()
        oModel:CommitData()
        lRet := .T.

    Else
        aError := oModel:GetErrorMessage()
        cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

    EndIf

    oModel:DeActivate()
    oModel:Destroy()
    oModel := Nil

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função ADFAT27B(ADFAT027P)", Nil, "Erro na geração de registro de barramento " + cId + "." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT27C
    Carrega dados de cadastro sem grid.
    @type  User Function
    @author Everson
    @since 11/02/2022
    @version 01
/*/
User Function ADFAT27C(cTabela, nIndex, cTopico, cOperacao, cChave, lCabec, lConvStr, lGerEnv, cId, cCmpI, cCmpEx, lDelOn)

    //Variáveis.
    Local aArea     := GetArea()
    Local xDados    := Nil
    Local oJson     := JsonObject():New()
    Local oJsonD    := Nil
    Local aCampos   := TCStruct(RetSqlName(cTabela))
    Local cData     := DToS(Date())
    Local cHora     := Time()  
    
    Default lCabec  := .T.
    Default lConvStr:= .T.
    Default lGerEnv := .T.
    Default cId     := FWUUIDV1(.T.)
    Default lDelOn  := .F.

    If lCabec 
        cabecDados(@oJson, cData, cHora, cId, cTopico, cOperacao)

    EndIf

    If cOperacao == "D" .And. ! lDelOn
        SET DELETED off

    EndIf

        DbSelectArea(cTabela)
        (cTabela)->(DbSetOrder(nIndex))
        If (cTabela)->( DbSeek( cChave ) )

            oJsonD := carDados(cTabela, aCampos, cCmpI, cCmpEx)

            If lCabec
                oJson['dados'] := oJsonD

            Else
                oJson := oJsonD

            EndIf

            If lConvStr
                xDados := oJson:toJson() //Converte para string json.

                If lGerEnv
                    U_ADFAT27B(cOperacao, cTopico, cId, xDados, cData, cHora) //Gera registro para ser enviado ao barramento.

                EndIf

            Else
                xDados := oJson

            EndIf

            FreeObj(oJson)
            oJson := Nil

            FreeObj(oJsonD)
            oJsonD := Nil

        EndIf

    If cOperacao == "D" .And. ! lDelOn
        SET DELETED on

    EndIf

    RestArea(aArea)

Return xDados
/*/{Protheus.doc} cabecDados
    Adiciona cabeçalho padrão aos dados.
    @type  Static Function
    @author Everson
    @since 11/02/2022
    @version 01
/*/
Static Function cabecDados(oJson, cData, cHora, cId, cTopico, cOperacao)

    //Variáveis.

    oJson['uuid'] := cId
    oJson['empresa'] := cEmpAnt
    oJson['filial'] := cFilAnt
    oJson['data'] := cData
    oJson['hora'] := cHora
    oJson['sistGera'] := "PROTHEUS"
    oJson['topico'] := cTopico
    oJson['operacao'] := cOperacao
    oJson['dados'] := Nil

Return Nil
/*/{Protheus.doc} carDados
    Carrega dados no objeto json.
    @type  Static Function
    @author Everson
    @since 11/02/2022
    @version 01
/*/
Static Function carDados(cTabela, aCampos, cCmpI, cCmpEx)

    //Variáveis.
    Local aArea     := GetArea()
    Local nAux      := 1
    Local cCampo    := ""
    Local cTipo     := ""
    Local xValor    := Nil
    Local oJsonD    := JsonObject():New()

    Default cCmpI   := ""
    Default cCmpEx  := ""

    For nAux := 1 To Len(aCampos)

        cCampo := Alltrim(cValToChar(aCampos[nAux][1]))

        If cCampo == "D_E_L_E_T_" .Or. cCampo == "R_E_C_N_O_" .Or. cCampo == "R_E_C_D_E_L_" .Or.; 
           Empty(cCampo) .Or. cCampo == Nil .Or. "USERGI" $cCampo .Or. "USERGA" $cCampo .Or.;
           "USERLGA" $cCampo .Or. "USERLGI" $cCampo
            Loop
            
        EndIf

        If !Empty(cCmpI) .And. !(cCampo $cCmpI)
            Loop
            
        EndIf

        If !Empty(cCmpI) .And. (cCampo $cCmpEx)
            Loop
            
        EndIf

        cTipo  := aCampos[nAux][6]
        xValor := (cTabela)->&(cCampo)

        If cTipo == "C"
            xValor := U_ADFAT50O(Alltrim(cValToChar(xValor)))

        ElseIf cTipo == "D"
            If Empty(xValor)
                xValor := StrTran(Alltrim(cValToChar(xValor)),"/","")

            Else
                xValor := DToS(xValor)

            EndIf

        EndIf

        oJsonD[cCampo] := xValor

    Next nAux

    RestArea(aArea)

Return oJsonD
/*/{Protheus.doc} ADFAT27D
    Carrega dados de cadastro com grid.
    @type  User Function
    @author Everson
    @since 11/02/2022
    @version 01
/*/
User Function ADFAT27D(cTab1, nInd1, cChav1,;
                       cTab2, nInd2, cChav2, cCmpItem, cFilter,;
                       cTopico, cOperacao,;
                       lCabec, lConvStr, lGerEnv,;
                       cCabModel2,;
                       cNomeItem)

    //Variáveis.
    Local aArea     := GetArea()
    Local xDados    := Nil
    Local oCabec    := Nil
    Local oItem     := Nil 
    Local aItens    := {}
    Local cData     := DToS(Date())
    Local cHora     := Time()  
    Local cId       := FWUUIDV1(.T.)
    Local aCamCab   := Nil
    Local aCamItem  := Nil
    Local nAux1     := 1
    Local cChave2E  := ""

    Default lCabec      := .T.
    Default lConvStr    := .T.
    Default lGerEnv     := .T.
    Default cCabModel2  := ""
    Default cNomeItem   := "items"
    
    oCabec := U_ADFAT27C(cTab1, nInd1, cTopico, cOperacao, cChav1, .T., .F., .F., cId, cCabModel2, Nil)

    If oCabec == Nil
        RestArea(aArea)
        Return xDados

    EndIf

    If cOperacao == "D"
        SET DELETED off

    EndIf

        DbSelectArea(cTab2)
        (cTab2)->(DbSetOrder(nInd2))
        If (cTab2)->( DbSeek( cChav2 ) )

            (cTab2)->(DbSetFilter({|| &cFilter}, cFilter))
            (cTab2)->( DbGoTop() )

            While ! (cTab2)->(Eof())

                cChave2E := cChav2 + (cTab2)->&(cCmpItem)

                oItem := U_ADFAT27C(cTab2, nInd2, cTopico, cOperacao, cChave2E, .F., .F., .F., Nil, Nil, cCabModel2, .T.)
                Aadd(aItens, oItem)

                (cTab2)->(DbSkip())

            End

            (cTab2)->(DBClearFilter())

        EndIf
        
        oCabec['dados'][cNomeItem] := aItens

        If lConvStr
            xDados := oCabec:toJson() //Converte para string json.

            If lGerEnv
                U_ADFAT27B(cOperacao, cTopico, cId, xDados, cData, cHora) //Gera registro para ser enviado ao barramento.

            EndIf

        Else
            xDados := oCabec

        EndIf

    If cOperacao == "D"
        SET DELETED on

    EndIf

    RestArea(aArea)

Return xDados
