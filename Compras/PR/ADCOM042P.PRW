#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZIO"
Static cTitulo := "Contrato de Compra de Matéria Prima"

/*/{Protheus.doc} User Function tstmvc
    Contrato de Compra de Matéria Prima.
    Cad Padr Prod Compra
    Chamado 18465.
    @type  Function
    @author Everson
    @since 07/12/2021
    @version 01
/*/
User Function ADCOM042P() // ADCOM042P()

    //Variáveis.
    Local oBrowse := Nil

    U_ADCOM417()

    oBrowse := FwLoadBrw("ADCOM042P")

    oBrowse:Activate()

    U_ADCOM417()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 07/12/2021
    @version 01
/*/
Static Function BrowseDef()

    //Variáveis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    oBrowse:AddLegend("ZIO->ZIO_STATUS = '1'", "BR_BRANCO"   , "Aberto")
    oBrowse:AddLegend("ZIO->ZIO_STATUS = '2'", "BR_AZUL"     , "Enviado para Aprovação")
    oBrowse:AddLegend("ZIO->ZIO_STATUS = '3'", "BR_VERDE"    , "Aprovado")
    oBrowse:AddLegend("ZIO->ZIO_STATUS = '4'", "BR_VERMELHO" , "Reprovado")
    oBrowse:AddLegend("ZIO->ZIO_STATUS = '5'", "BR_MARROM"   , "Ped Gerado")
    oBrowse:AddLegend("ZIO->ZIO_STATUS = '6'", "BR_PRETO"    , "Encerrado")
    oBrowse:AddLegend("ZIO->ZIO_STATUS = '7'", "BR_LARANJA"  , "Parcialmente Atendido")
    oBrowse:AddLegend("ZIO->ZIO_STATUS = '8'", "BR_PINK"     , "Encerrado Manual")

    // oBrowse:SetFilterDefault(" " + cTbMast + "_FILIAL = '" + FWxFilial(cTbMast) + "' ")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 07/12/2021
    @version 01
/*/
Static Function MenuDef()

    //Variáveis.
    Local aRotina := {}
    Local cAprova := Alltrim(cValToChar(GetMv("MV_#COM411",,"")))

    ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"          	OPERATION 1   ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ADCOM042P" 	OPERATION MODEL_OPERATION_VIEW      ACCESS 0
    ADD OPTION aRotina TITLE "Incluir" 	  ACTION "U_ADCOM421()" 	    OPERATION MODEL_OPERATION_INSERT    ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"    ACTION "U_ADCOM422()"   	    OPERATION MODEL_OPERATION_UPDATE    ACCESS 0
    ADD OPTION aRotina TITLE "Excluir" 	  ACTION "U_ADCOM423()"   	    OPERATION MODEL_OPERATION_DELETE    ACCESS 0

    If FWIsAdmin() .Or. __cUserID $cAprova
        ADD OPTION aRotina TITLE "Aprovar" ACTION "U_ADCOM424(ZIO->ZIO_NUMERO, ZIO->ZIO_VERSAO)" OPERATION 10  ACCESS 0

    EndIf

    ADD OPTION aRotina TITLE "Env Aprovacao"  ACTION "U_ADCOM427()" OPERATION 10  ACCESS 0

    ADD OPTION aRotina TITLE "Ger Ped Compra" ACTION "U_ADCOM429()" OPERATION 11  ACCESS 0

    ADD OPTION aRotina TITLE "Encerrar Manual" ACTION "U_ADCOM429()" OPERATION 12  ACCESS 0

Return aRotina
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 07/12/2021
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local oModel    := Nil
    Local oStrMast  := FWFormStruct(1, cTbMast, {|cCampo| AllTRim(cCampo) $ getCmps()})
    Local oStrGrid  := FWFormStruct(1, cTbMast)
    Local bPost     := {|oModel| vldPos(oModel) }
    Local bLinhaOk  := {|oModel| fValidGrid(oModel) }
 
    oModel := MPFormModel():New("ADCOM42", /*bPreValidacao*/, bPost, /*bCommit*/, /*bCancel*/ )
 
    oModel:AddFields("MD_MASTER", NIL, oStrMast)
    oModel:AddGrid("MD_GRID", "MD_MASTER", oStrGrid,, bLinhaOk)
 
    oModel:SetRelation("MD_GRID", {;
            {"ZIO_FILIAL", 'FWxFilial("' + cTbMast + '")'},;
            {"ZIO_NUMERO", "ZIO_NUMERO"},;
            {"ZIO_VERSAO", "ZIO_VERSAO"},;
            {"ZIO_DESC"  , "ZIO_DESC"},;
            {"ZIO_TIPO"  , "ZIO_TIPO"},;
            {"ZIO_STATUS", "ZIO_STATUS"},;
            {"ZIO_DTINI" , "ZIO_DTINI"},;
            {"ZIO_DTFIM ", "ZIO_DTFIM"},;
            {"ZIO_INCLUS", "ZIO_INCLUS"},;
            {"ZIO_ALTERA", "ZIO_ALTERA"},;
            {"ZIO_DTAPRO", "ZIO_DTAPRO"},;
            {"ZIO_HRAPRO", "ZIO_HRAPRO"},;
            {"ZIO_CODAPR", "ZIO_CODAPR"},;
            {"ZIO_NMAPRO", "ZIO_NMAPRO"},;
            {"ZIO_LGENCM", "ZIO_LGENCM"};
        }, (cTbMast)->(IndexKey(2)))

    oModel:SetPrimaryKey({})

Return oModel
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 07/12/2021
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oView     := Nil
    Local oModel    := FWLoadModel('ADCOM042P')
    Local cCampos   := getCmps()
    Local oStrMast  := FWFormStruct(2, cTbMast, {|cCampo| AllTRim(cCampo)   $ cCampos})
    Local oStrGrid  := FWFormStruct(2, cTbMast, {|cCampo| !(Alltrim(cCampo) $ cCampos)})

    oView:= FWFormView():New() 
    oView:SetModel(oModel)              
 
    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")
    oView:AddGrid("VW_GRID",    oStrGrid, "MD_GRID",,{|| gridFocus(oView) })
 
    oView:CreateHorizontalBox("MAIN", 35)
    oView:CreateHorizontalBox("GRID", 65)

    oView:SetOwnerView("VW_MASTER", 'MAIN')
    oView:SetOwnerView("VW_GRID", 'GRID')
    oView:EnableControlBar(.T.)
 
    oView:AddIncrementField("VW_GRID", "ZIO_ITEM")

    oView:SetViewProperty( "VW_GRID" , "ENABLENEWGRID" ) 
    // oView:SetViewProperty( "VW_GRID", "GRIDNOORDER")
    oView:SetViewProperty( "VW_GRID", "GRIDFILTER", {.T.}) 
    oView:SetViewProperty( "VW_GRID", "GRIDSEEK", {.T.})

    oView:AddUserButton("Padrão Para Compra","",{|oView| U_ADCOM428(oView) } ,"",, {MODEL_OPERATION_INSERT ,MODEL_OPERATION_UPDATE} , .T. )   

Return oView
/*/{Protheus.doc} getCmps
    Retorna campos do cabeçalho.
    @type  Static Function
    @author Everson
    @since 04/08/2022
    @version 01
/*/
Static Function getCmps()
Return "ZIO_FILIAL;ZIO_NUMERO;ZIO_VERSAO;ZIO_DESC;ZIO_TIPO;ZIO_DTINI;ZIO_DTFIM;ZIO_STATUS;ZIO_INCLUS;ZIO_ALTERA;ZIO_DTAPRO;ZIO_HRAPRO;ZIO_CODAPR;ZIO_NMAPRO;ZIO_LGENCM;"
/*/{Protheus.doc} fValidGrid
    Valida linha.
    @type  Static Function
    @author Everson
    @since 04/08/2022
    @version 01
/*/
Static Function fValidGrid(oModelGRID)

    //Variáveis.
    Local lRet       := .T.
    Local nAux       := 0
 
    For nAux := 1 To oModelGRID:Length() 

        oModelGRID:GoLine(nAux) 
         
        If ! oModelGRID:IsDeleted()

            If Empty(oModelGRID:GetValue("ZIO_CODPRO")) .Or. Empty(oModelGRID:GetValue("ZIO_DESPRD"));
               .Or. oModelGRID:GetValue("ZIO_VLUNIT") <= 0 .Or. oModelGRID:GetValue("ZIO_QUANT") <= 0;
               .Or. oModelGRID:GetValue("ZIO_VLRTOT") <= 0 .Or. Empty(oModelGRID:GetValue("ZIO_CODFOR"));
               .Or. Empty(oModelGRID:GetValue("ZIO_LJFORN")) .Or. Empty(oModelGRID:GetValue("ZIO_CONDPA"))

                lRet := .F.
                Help(Nil, Nil, "fValidGrid vldPos(ADCOM042P)", Nil, "Necessário informar o produto, valor unitário, quantidade, fornecedor e condição de pagamento.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
                Exit
                
            EndIf

        EndIf

    Next nAux
 
Return lRet
/*/{Protheus.doc} vldPos
    Pós validação.
    @type  Static Function
    @author Everson
    @since 04/08/2022
    @version 01
/*/
Static Function vldPos(oModel)

    //Variáveis.
    Local aArea      := GetArea()
    Local lRet       := .T.
    Local nOperation := oModel:GetOperation()
    Local cDesc      := oModel:GetValue("MD_MASTER","ZIO_DESC")
    Local cDtIni     := oModel:GetValue("MD_MASTER","ZIO_DTINI")
    Local cDtFim     := oModel:GetValue("MD_MASTER","ZIO_DTFIM")
    Local cTipo      := oModel:GetValue("MD_MASTER","ZIO_TIPO")


    If lRet .And. nOperation == MODEL_OPERATION_INSERT

        If Empty(cDesc) .Or. Empty(cDtIni) .Or. Empty(cDtFim) .Or. Empty(cTipo)
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADCOM042P)", Nil, "Necessário preencher descrição, data inicial, data final e tipo do contrato.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        
        EndIf

        If lRet
            oModel:SetValue("MD_MASTER", "ZIO_INCLUS", DToC(Date()) + " " + Time() + " " + Alltrim(cUserName))

        EndIf

    EndIf

    If lRet .And. nOperation == MODEL_OPERATION_UPDATE

        oModel:SetValue("MD_MASTER", "ZIO_ALTERA", DToC(Date()) + " " + Time() + " " + Alltrim(cUserName))

        If lRet .And. ! IsInCallStack("U_ADCOM427") .And. ! IsInCallStack("U_ADCOM427")
            oModel:SetValue("MD_MASTER", "ZIO_DTAPRO"   , CToD(" / / "))
            oModel:SetValue("MD_MASTER", "ZIO_HRAPRO"   , "")
            oModel:SetValue("MD_MASTER", "ZIO_CODAPR"   , "")
            oModel:SetValue("MD_MASTER", "ZIO_NMAPRO"   , "")
            oModel:SetValue("MD_MASTER", "ZIO_STATUS"   , "1")

        EndIf

    EndIf

    If lRet .And. nOperation == MODEL_OPERATION_DELETE
        

    EndIf

    RestArea(aArea)

Return lRet
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
    Local cDesc   := oModel:GetValue("MD_MASTER","ZIO_DESC")
    Local cDtIni  := oModel:GetValue("MD_MASTER","ZIO_DTINI")
    Local cDtFim  := oModel:GetValue("MD_MASTER","ZIO_DTFIM")
    Local cTipo   := oModel:GetValue("MD_MASTER","ZIO_TIPO")

    If Empty(cDesc) .Or. Empty(cDtIni) .Or. Empty(cDtFim) .Or. Empty(cTipo)
        Help(Nil, Nil, "Função gridFocus(ADCOM042P)", Nil, "Necessário preencher descrição, data inicial, data final e tipo do contrato.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZIO_DESC"):OCtrl:SetFocus()
    
    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} User Function ADCOM421
    Inclusão.
    @type  Function
    @author user
    @since 04/08/2022
    @version 01
/*/
User Function ADCOM421()

    //Variáveis.

    FWExecView("", "ADCOM042P", 3)

Return Nil
/*/{Protheus.doc} User Function ADCOM422
    Alteração.
    @type  Function
    @author Everson
    @since 04/08/2022
    @version 01
/*/
User Function ADCOM422()

    //Variáveis.
    Local aArea  := GetArea()

    If ZIO_STATUS $ "6/8"
        Help(Nil, Nil, "Função ADCOM422(ADCOM042P)", Nil, "Operação não permitida, contrato encerrado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIF

    If ZIO->ZIO_STATUS $"1/2/3/4" //Aberto, enviado para aprovação, aprovado, reprovado.
    
        FWExecView("", "ADCOM042P", 4)

    Else

        If ! MsgYesNo("O status do contrato não permite alteração. Deseja criar uma nova versão?", "Função ADCOM422(ADCOM042P)")
            RestArea(aArea)
            Return Nil
        
        EndIf

        FWExecView("", "ADCOM042P", 9)

    EndIf
    
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} User Function ADCOM422
    Exclusão.
    @type  Function
    @author Everson
    @since 04/08/2022
    @version 01
/*/
User Function ADCOM423()

    //Variáveis.
    Local aArea  := GetArea()

    If ! (ZIO->ZIO_STATUS $"1/2/3/4") //Aberto, enviado para aprovação, aprovado, reprovado.
        Help(Nil, Nil, "Função ADCOM423(ADCOM042P)", Nil, "Operação não permitida.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    FWExecView("", "ADCOM042P", 5)
    
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} User Function ADCOM424
    Aprova contrato.
    @type  Function
    @author Everson
    @since 04/08/2022
    @version 01
/*/
User Function ADCOM424(cContrato, cVersao, lAut, cMsgError)

    //Variáveis.
    Local aArea  := GetArea()
    Local lRet   := .F.
    Local oModel := Nil
    Local aError := {}

    Default lAut      := .F.
    Default cMsgError := ""

    If ! U_ADCOM425(cContrato, cVersao)
        cMsgError := "Contrato " + cContrato + " versão " + cVersao + " não localizado."
        Help(Nil, Nil, "Função ADCOM424(ADCOM042P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    If ZIO->ZIO_STATUS <> "2"
        cMsgError := "Operação não permitida, contrato precisa ser enviado para aprovação, ou já passou pelo processo de aprovação."
        Help(Nil, Nil, "Função ADCOM424(ADCOM042P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .T.

    EndIf

    If ! lAut .And. ! MsgYesNo("Deseja aprovar o contrato " + cContrato + " versão " + cVersao + "?", "Função ADCOM424(ADCOM042P)")
        RestArea(aArea)
        Return .F.

    EndIf

    oModel := FwLoadModel("ADCOM042P")
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:Activate()

    oModel:SetValue("MD_MASTER", "ZIO_DTAPRO"   , Date())
    oModel:SetValue("MD_MASTER", "ZIO_HRAPRO"   , Time())
    oModel:SetValue("MD_MASTER", "ZIO_CODAPR"   , __cUserID)
    oModel:SetValue("MD_MASTER", "ZIO_NMAPRO"   , cUserName)
    oModel:SetValue("MD_MASTER", "ZIO_STATUS"   , "3")

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
       Help(Nil, Nil, "Função ADCOM424(ADCOM042P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} User Function ADCOM424
    Posiciona no registro.
    @type  Function
    @author Everson
    @since 04/08/2022
    @version 01
/*/
User Function ADCOM425(cContrato, cVersao)

    //Variáveis.
    Local lRet := .F.

    Default cContrato := ""
    Default cVersao   := ""

    DbSelectArea("ZIO")
    ZIO->(DbSetOrder(2))
    lRet := ZIO->( DbSeek( FWxFilial("ZIO") + cContrato + cVersao ) )

Return lRet
/*/{Protheus.doc} User Function ADCOM426
    Atualiza campo.
    @type  Function
    @author Everson
    @since 04/08/2022
    @version 01
/*/
User Function ADCOM426(cContrato, cVersao, cCampo, xValor, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local aError    := {}
    Local oModel    := Nil
    
    Default cMsgError := ""

    If ! U_ADCOM425(cContrato, cVersao)
        cMsgError := "Contrato " + cContrato + " versão " + cVersao + " não localizado."
        Help(Nil, Nil, "Função ADCOM426(ADCOM042P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    oModel := FwLoadModel("ADCOM042P")
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:Activate()

    oModel:SetValue("MD_MASTER", cCampo, xValor)
    oModel:SetValue("MD_MASTER", cCampo, xValor)

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
       Help(Nil, Nil, "Função ADCOM426(ADCOM042P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} User Function ADCOM427
    Envia para aprovação.
    @type  Function
    @author Everson
    @since 04/08/2022
    @version 01
/*/
User Function ADCOM427()

    //Variáveis.
    Local aArea  := GetArea()

    If ZIO->ZIO_STATUS <> "1"
        Help(Nil, Nil, "Função ADCOM427(ADCOM042P)", Nil, "Contrato " + ZIO->ZIO_NUMERO + " versão " + ZIO->ZIO_VERSAO + " já passou por processo de aprovação.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .T.

    EndIf

    If ! MsgYesNo("Deseja enviar o contrato " + ZIO->ZIO_NUMERO + " versão " + ZIO->ZIO_VERSAO + " para aprovação?", "Função ADCOM427(ADCOM042P)")
        RestArea(aArea)
        Return .F.

    EndIf

    lRet := U_ADCOM426(ZIO->ZIO_NUMERO, ZIO->ZIO_VERSAO, "ZIO_STATUS", "2")

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} User Function ADCOM428
    Lançamento de padrão de compra.
    @type  Function
    @author user
    @since 04/08/2022
    @version 01
/*/
User Function ADCOM428(oView)

    //Variáveis.
    Local aArea     := GetArea()
    Local oHeader   := oView:GetModel("MD_MASTER")
    Local oGrid     := oView:GetModel("MD_GRID")
    Local cProduto  := oGrid:GetValue("ZIO_CODPRO")
    Local cContrato := oHeader:GetValue("ZIO_NUMERO")
    Local cVersao   := oHeader:GetValue("ZIO_VERSAO")
    Local cItemCT   := oGrid:GetValue("ZIO_ITEM")
    Local cFornece  := oGrid:GetValue("ZIO_CODFOR")
    Local cLoja     := oGrid:GetValue("ZIO_LJFORN")
    Local cNmFornec := oGrid:GetValue("ZIO_NMFORN")

    If ! fValidGrid(oGrid)
        RestArea(aArea)
        Return .F.

    EndIf

    If ! U_ADQUA71(cProduto)
        Help(Nil, Nil, "Função ADCOM428(ADCOM042P)", Nil, "Não há exame cadastrado para o produto " + cProduto + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    If ! MsgYesNo("Deseja fazer o preenchimento do padrão de compra?", "Função ADCOM428(ADCOM042P)")
        RestArea(aArea)
        Return .F.
        
    EndIf

    If ! U_ADCOM412(cContrato, cVersao, cItemCT, cFornece, cLoja, cProduto) .And. ! U_ADCOM411(cContrato, cVersao, cItemCT, cFornece, cLoja, cNmFornec, cProduto)
        Help(Nil, Nil, "Função ADCOM428(ADCOM042P)", Nil, "Não foi possível carregar os registros.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf
    
    If U_ADCOM412(cContrato, cVersao, cItemCT, cFornece, cLoja, cProduto) 
        FWExecView("", "ADCOM041P", 4)

    Else
        Help(Nil, Nil, "Função ADCOM428(ADCOM042P)", Nil, "Não foi possível carregar os registros.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    RestArea(aArea)
    
Return .T.
/*/{Protheus.doc} lmpPdr
    Apaga lançamentos de padrão de compra.
    @type  Static Function
    @author Everson
    @since 04/08/2022
    @version 01
/*/
Static Function lmpPdr(cContrato, cVersao)

    //Variáveis.
    Local aArea  := GetArea()

    If ! U_ADCOM425(cContrato, cVersao) //Verifica se padrão de compra vinculado ao contrato.

        U_ADCOM414(cContrato, cVersao)  //Exclui os registros de padrão de compra.

    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADCOM429
    Gera pedido de compra.
    @type  Static Function
    @author Everson
    @since 04/08/2022
    @version 01
/*/
User Function ADCOM429()

    //Variáveis.
    Local aArea     := GetArea()
    Local cContrato := ZIO->ZIO_NUMERO
    Local cVersao   := ZIO->ZIO_VERSAO

    If ! U_ADCOM425(cContrato, cVersao)
        Help(Nil, Nil, "Função ADCOM429(ADCOM042P)", Nil, "Contrato " + cContrato + " versão " + cVersao + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    If ZIO->ZIO_STATUS <> "3"
        Help(Nil, Nil, "Função ADCOM429(ADCOM042P)", Nil, "Operação não permitida.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    MsgInfo("Processo finalizado.", "Função ADCOM429(ADCOM042P)")

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} User Function ADCOM430
    Encerrar contrato manualmente.
    @type  Function
    @author user
    @since 05/08/2022
    @version 01
/*/
User Function ADCOM430()

    //Variáveis.
    Local aArea  := GetArea()

    If ZIO->ZIO_STATUS <> "5/7"
        Help(Nil, Nil, "Função ADCOM430(ADCOM042P)", Nil, "Para ser encerrado, o contrato precisa estar com status de 'Ped Gerado' ou 'Parcialmente Atendido'.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .T.

    EndIf

    If ! MsgYesNo("Deseja encerrar o contrato " + ZIO->ZIO_NUMERO + " versão " + ZIO->ZIO_VERSAO + "?", "Função ADCOM430(ADCOM042P)")
        RestArea(aArea)
        Return .F.

    EndIf

    Begin Transaction

        If ! cncPdCom()
            DisarmTransaction()
            Break

        EndIf

        If U_ADCOM426(ZIO->ZIO_NUMERO, ZIO->ZIO_VERSAO, "ZIO_STATUS", "7")
            DisarmTransaction()
            Break

        EndIf

    End Transaction

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} cncPdCom
    Cancela pedidos de compra vinculados ao contrato.
    @type  Static Function
    @author Everson
    @since 05/08/2022
    @version 01
/*/
Static Function cncPdCom(cContrato, cVersao)

    //Variáveis.
    Local aArea  := GetArea()

    If U_ADCOM425(cContrato, cVersao)
        Help(Nil, Nil, "Função cncPdCom(ADCOM042P)", Nil, "Contrato " + cContrato + " versão " + cVersao + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    While ! ZIO->(Eof()) .And. ZIO->ZIO_FILIAL == FWxFilial("ZIO") .And. ZIO->ZIO_NUMERO == cContrato .And. ZIO->ZIO_VERSAO == cVersao


        ZIO->(DbSkip())

    End
    
    RestArea(aArea)
    
Return .T.
/*/{Protheus.doc} User Function ADVN110
    Ponto de entrada.
    @type  Function
    @author Everson
    @since 01/08/2022
    @version 01
/*/
User Function ADCOM42()

    //Variáveis.
    Local aParam    := PARAMIXB 
    Local xRet      := .T. 
    Local oObj      := "" 
    Local cIdPonto  := "" 
    Local cIdModel  := "" 
    Local oModelX   := nil
    Local oView     := Nil
    Local cNumero   := ""

    If aParam <> NIL
    
        oObj     := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
    
        If cIdPonto == "BUTTONBAR"
    
            oModelX := FwModelActive()

            cNumero := oModelX:GetValue("MD_MASTER","ZIO_NUMERO")
        
            If oModelX:IsCopy()

                FWFldPut("ZIO_VERSAO", obtVersao(cNumero))
                FWFldPut("ZIO_STATUS", "1")
                FWFldPut("ZIO_DTINI" , CToD(" / /"))
                FWFldPut("ZIO_DTFIM" , CToD(" / /"))
                
                oView := FWViewActive()
                oView:Refresh()
                oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZIO_DTINI"):OCtrl:SetFocus()
            
            EndIf
        
        EndIf
    
    EndIf

Return xRet
/*/{Protheus.doc} Function obtVersao
    Obtém próximo número de versão.
    @type  Static Function
    @author Everson
    @since 01/08/2022
    @version 01
/*/
Static Function obtVersao(cContrato)

    //Variáveis.
    Local aArea   := GetArea()
    Local cVersao := "001"

    If U_ADCOM425(cContrato)

        While ! ZIO->(Eof()) .And. ZIO->ZIO_FILIAL == FWxFilial("ZIO") .And. ZIO->ZIO_NUMERO == cContrato

            If ZIO->ZIO_VERSAO > cVersao
                cVersao := ZIO->ZIO_VERSAO

            EndIf

            ZIO->(DbSkip())
            
        End

        cVersao := Soma1(cVersao)

    EndIf

    RestArea(aArea)

Return cVersao
