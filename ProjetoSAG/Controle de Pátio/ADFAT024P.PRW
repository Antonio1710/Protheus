#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"
#Include "Apwebsrv.ch"

Static cTbMast := "ZIH"
Static cTitulo := "Pesagem Guardian"
Static cTiMast := "Dados da pesagem Guardian"
Static xPula   := Chr(13) + Chr(10)

PUBLISH USER MODEL REST NAME pesagensguardian

/*/{Protheus.doc} User Function ADFAT024P
    Pesagens Guardian.
    Cad Pesagens Guardian
    Chamado 18465.
    @type  Function
    @author Everson
    @since 02/12/2021
    @version 01
/*/
User Function ADFAT024P() // U_ADFAT024P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADFAT024P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 02/12/2021
    @version 01
/*/
Static Function BrowseDef()

    //Variáveis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    oBrowse:SetMenuDef("ADFAT024P")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 02/12/2021
    @version 01
/*/
Static Function MenuDef()

    //Variáveis.
    Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar" 		ACTION "PesqBrw"          	OPERATION 1   ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 		ACTION "VIEWDEF.ADFAT024P" 	OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    		ACTION "VIEWDEF.ADFAT024P" 	OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    		ACTION "VIEWDEF.ADFAT024P" 	OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    		ACTION "VIEWDEF.ADFAT024P" 	OPERATION MODEL_OPERATION_DELETE ACCESS 0
	ADD OPTION aRotina TITLE "Importar Dados"   ACTION "U_ADFT2414()"       OPERATION 10  ACCESS 0

Return aRotina
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 02/12/2021
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local bPre      := {|| .T. }
    Local bPost     := {|| .T. }
    Local bCancel   := {|| .T. }
    Local oModel    := MPFormModel():New("ADFAT24", bPre, bPost, /*bCommit*/, bCancel)
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
    @since 02/12/2021
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oView     := FwFormView():New()
    Local oModel    := FwLoadModel("ADFAT024P")
    Local oStrMast  := FwFormStruct(2, cTbMast)

    oView:SetModel(oModel)

    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")

Return oView
/*/{Protheus.doc} ADFT241
    Cadastro de ticket de pesagem no Guardian. 
    @type  User Function
    @author Everson
    @since 01/12/2021
    @version 01
/*/
User Function ADFT241(cUrl,oRetSolic,cErro,cPlcCarret,cPlcVeic,cTag,cFluxo,cTickProth,nPesIni,cPerifIni,cOpPesIni)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oGuardian := WSWS_GUARDIAN():New()

    oGuardian:_URL := cUrl
    oGuardian:OWSDADOSTICKET:cCodigo := cTickProth
    oGuardian:OWSDADOSTICKET:cPlacaCarreta  := cPlcCarret
    oGuardian:OWSDADOSTICKET:cPlacaVeiculo  := cPlcVeic
    oGuardian:OWSDADOSTICKET:cTagAssociado  := cTag
    oGuardian:OWSDADOSTICKET:cFluxo := cFluxo
    oGuardian:OWSDADOSTICKET:cReferenciaIntegracao := cTickProth

    If nPesIni > 0
        oGuardian:OWSDADOSTICKET:nPesoDaPesagemInicial := nPesIni
        oGuardian:OWSDADOSTICKET:cPerifericoDaPesagemInicial := cPerifIni
        oGuardian:OWSDADOSTICKET:cOperacaoDaPesagemInicial := cOpPesIni

    EndIf
    
    If oGuardian:CadastraTicketGuardian()
        
        If oGuardian:nErro = 303221
            lRet := .T.
            oRetSolic := oGuardian:oWSCadastraTicketGuardianResult

        Else
            cErro := cValToChar(oGuardian:nErro) + " " + Alltrim(cValToChar(oGuardian:cErroMSG))

        EndIf

    Else
        cErro := "GetWSCError " + GetWSCError()
        
    EndIf 

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFT242
    Altera a tag. 
    @type  User Function
    @author Everson
    @since 02/12/2021
    @version 01
/*/
User Function ADFT242(cUrl,oRetSolic,cErro,cPlcCarret,cPlcVeic,cTag,cFluxo,cTickProth)
    
    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.
    Local oGuardian := WSWS_GUARDIAN():New()

    oGuardian:_URL := cUrl
    oGuardian:OWSDADOSTICKET:cCodigo := cTickProth
    oGuardian:OWSDADOSTICKET:cPlacaCarreta  := cPlcCarret
    oGuardian:OWSDADOSTICKET:cPlacaVeiculo  := cPlcVeic
    oGuardian:OWSDADOSTICKET:cTagAssociado  := cTag
    oGuardian:OWSDADOSTICKET:nPesoTotalOrigem := 0

    oGuardian:oWSCFGALTERACAO:lIgnoraTransportadora := .T.
    oGuardian:oWSCFGALTERACAO:lIgnoraEmissor := .T.
    oGuardian:oWSCFGALTERACAO:lIgnoraItens := .T.
    oGuardian:oWSCFGALTERACAO:lIgnoraMotorista := .T.
    oGuardian:oWSCFGALTERACAO:lIgnoraDocumentos := .T.
    oGuardian:oWSCFGALTERACAO:lIgnoraCamposAdicionais := .T.
    oGuardian:oWSCFGALTERACAO:lIgnoraFatorCorrecao := .T.
    oGuardian:oWSCFGALTERACAO:lIgnoraConteineres := .T.
    oGuardian:oWSCFGALTERACAO:lIgnoraFluxo := .T.
    
    If oGuardian:AlteraTicketGuardian()
    
        If oGuardian:nErro = 303221
            lRet := .T.
            oRetSolic := oGuardian:oWSAlteraTicketGuardianResult

        Else
            cErro := cValToChar(oGuardian:nErro) + " " + Alltrim(cValToChar(oGuardian:cErroMSG))

        EndIf

    Else
        cErro := "GetWSCError " + GetWSCError()
        
    EndIf 

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFT243
    Exporta dados do ticket de pesagem. 
    @type  User Function
    @author Everson
    @since 02/12/2021
    @version 01
/*/
User Function ADFT243(cUrl,oRetSolic,cErro)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.
    Local oGuardian := WSWS_GUARDIAN():New()

    oGuardian:_URL := cUrl
    
    If oGuardian:ExportaTicketsMarcados()
        
        If oGuardian:nErro = 0
            lRet := .T.
            oRetSolic := oGuardian:oWSExportaTicketsMarcadosResult

        Else
            cErro := cValToChar(oGuardian:nErro) + " " + Alltrim(cValToChar(oGuardian:cErroMSG))

        EndIf

    Else
        cErro := "GetWSCError " + GetWSCError()
        
    EndIf 

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFT244
    Confirma leitura dos tickets exportados. 
    @type  User Function
    @author Everson
    @since 02/12/2021
    @version 01
/*/
User Function ADFT244()
    
    //Variáveis.
    Local aArea := GetArea()
    

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFT245
    Remonta fluxo. 
    @type  User Function
    @author Everson
    @since 02/12/2021
    @version 01
/*/
User Function ADFT245(cUrl, cErro, cCodTicket, cFluxo, cProduto, cCodigo)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.
    Local oGuardian := WSWS_GUARDIAN():New()

    oGuardian:_URL := cUrl
    oGuardian:cticketCodigo := cCodTicket
    oGuardian:cfluxoCodigo  := cFluxo
    oGuardian:cproduto := cProduto
    oGuardian:ccodigo := cCodigo
    
    If oGuardian:RemontaFluxo()
        lRet := oGuardian:lRemontaFluxoResult

    Else
        cErro := "GetWSCError " + GetWSCError()
        
    EndIf 

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFT246
    Cancela última operação.
    @type  User Function
    @author Everson
    @since 02/12/2021
    @version 01
/*/
User Function ADFT246(cUrl,cErro,cCodTicket,cProduto,cCodigo)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.
    Local oGuardian := WSWS_GUARDIAN():New()

    oGuardian:_URL := cUrl
    oGuardian:cticketCodigo := cCodTicket
    oGuardian:cproduto := cProduto
    oGuardian:ccodigo := cCodigo
    
    If oGuardian:CancelaUltimaOperacaoAtiva()

        If oGuardian:nSaiErro = 0
            lRet := oGuardian:lCancelaUltimaOperacaoAtivaResult

        Else 
            cErro := Alltrim(cValToChar(oGuardian:nSaiErro)) + " " + Alltrim(cValToChar(oGuardian:cSaiErroMSG))

        EndIf 

    Else
        cErro := "GetWSCError " + GetWSCError()
        
    EndIf 

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFT247
    Refaz última operação. 
    @type  User Function
    @author Everson
    @since 02/12/2021
    @version 01
/*/
User Function ADFT247(cUrl,cErro,cCodTicket,cProduto,cCodigo)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.
    Local oGuardian := WSWS_GUARDIAN():New()

    oGuardian:_URL := cUrl
    oGuardian:cticketCodigo := cCodTicket
    oGuardian:cproduto := cProduto
    oGuardian:ccodigo := cCodigo
    
    If oGuardian:RefazUltimaOperacaoAtiva()

        If oGuardian:nSaiErro = 0
            lRet := oGuardian:lRefazUltimaOperacaoAtivaResult

        Else 
            cErro := Alltrim(cValToChar(oGuardian:nSaiErro)) + " " + Alltrim(cValToChar(oGuardian:cSaiErroMSG))

        EndIf 

    Else
        cErro := "GetWSCError " + GetWSCError()
        
    EndIf 

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFT248
    Envia mensagem para o display.
    @type  User Function
    @author Everson
    @since 02/12/2021
    @version 01
/*/
User Function ADFT248(cUrl,nRetSolic,cErro,cPontoCont,nPosicao,cMensagem,nTempo)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.
    Local oGuardian := WSWS_GUARDIAN():New()

    oGuardian:_URL := cUrl
    oGuardian:cPontoControle := cPontoCont
    oGuardian:nPosicao := nPosicao
    oGuardian:cMensagem := cMensagem
    oGuardian:nTempo := nTempo

    If oGuardian:EnviaMensagemDisplay()

        If oGuardian:nErro = 0
            lRet := .T.
            nRetSolic := oGuardian:nEnviaMensagemDisplayResult

        Else
            cErro := cValToChar(oGuardian:nErro) + " " + Alltrim(cValToChar(oGuardian:cErroMSG))

        EndIf

    Else
        cErro := "GetWSCError " + GetWSCError()

    EndIf 

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFT249
    Manutenção de ticket. 
    1 = Bloquear, 2 = Desbloquear, 3 = Encerrar, 4 = Cancelar  
    @type  User Function
    @author Everson
    @since 02/12/2021
    @version 01
/*/
User Function ADFT249(cUrl,cErro,cCodTicket,nNumOp,cProduto,cCodigo)
    
    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.
    Local oGuardian := WSWS_GUARDIAN():New()

    oGuardian:_URL := cUrl
    oGuardian:cticketCodigo := cCodTicket
    oGuardian:nnumOperacao  := nNumOp
    oGuardian:cproduto := cProduto
    oGuardian:ccodigo := cCodigo
    
    If oGuardian:ManutencaoTicket()
        lRet := oGuardian:lManutencaoTicketResult

    Else
        cErro := "GetWSCError " + GetWSCError()
        
    EndIf 

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFT2410
    Solicita foto avulsa. 
    @type  User Function
    @author Everson
    @since 02/12/2021
    @version 01
/*/
User Function ADFT2410(cUrl,nNumRet,cErro,cCodPonCont,cPosCam,cCaminho,cNmFoto,cProduto,cCodigo)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.
    Local oGuardian := WSWS_GUARDIAN():New()

    oGuardian:_URL := cUrl
    oGuardian:ccodigoPontoControle := cCodPonCont
    oGuardian:cposicaoCamera := cPosCam
    oGuardian:ccaminhoFoto := cCaminho
    oGuardian:cnomeFoto := cNmFoto
    oGuardian:cproduto := cProduto
    oGuardian:ccodigo := cCodigo

    If oGuardian:SolicitaFotoAvulsa()

        If oGuardian:nErro = 0
            lRet := .T.
            nNumRet := Val(cValToChar(oGuardian:nSolicitaFotoAvulsaResult))

        Else
            cErro := cValToChar(oGuardian:nErro) + " " + Alltrim(cValToChar(oGuardian:cErroMSG))

        EndIf

    Else
        cErro := "GetWSCError " + GetWSCError()

    EndIf 

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFT2411
    Solicita retorno da foto avulsa. 
    @type  User Function
    @author Everson
    @since 02/12/2021
    @version 01
/*/
User Function ADFT2411(cUrl,oRetSolic,nIdSolic,cProduto,cCodigo)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oGuardian := WSWS_GUARDIAN():New()

    oGuardian:_URL := cUrl
    oGuardian:nidSolicitacaoAvulsa := nIdSolic
    oGuardian:cproduto := cProduto
    oGuardian:ccodigo := cCodigo

    If oGuardian:SolicitaRetornoFotoAvulsa()
        lRet := .T.
        oRetSolic := oGuardian:oWSSolicitaRetornoFotoAvulsaResult

    Else
        cErro := "GetWSCError " + GetWSCError()

    EndIf 

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFT2412
    Obtém registros de pesagem.
    @type  User Function
    @author Everson
    @since 02/12/2021
    @version 01
/*/
User Function ADFT2412()

    //Variáveis.
    Local oRetSolic := Nil
    Local cErro     := ""
    Local aRet      := {}
    Local cBalanca  := Alltrim(cValToChar(GetMv("MV_#URLBAL",,"000002")))
    Local cUrl      := Alltrim(cValToChar(Posicione("DX5", 1, FWxFilial("DX5") + cBalanca, "DX5_URL")))
    Local nCount    := 0

    If Empty(cUrl)
        Help(Nil, Nil, "Função ADFT2412(ADFAT024P)", Nil, "Balança " + cBalanca + " não possui URL vinculado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    EndIf

    While .T. .And. nCount <= 10

        If U_ADFT243(cUrl, @oRetSolic, @cErro)
        
            aRet := oRetSolic:OWSTICKET

            If Len(aRet) <= 0
                Exit 

            EndIf

            slvPesa(aRet)

        Else
            Help(Nil, Nil, "Função ADFT2412(ADFAT024P)", Nil, "Erro na consula à balança (ADFT243)." + xPula + cErro, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

        FreeObj(oRetSolic)
        oRetSolic := NIL
        nCount++

    End

Return .T.
/*/{Protheus.doc} slvPesa
    Salva registros de pesagem.
    @type  Static Function
    @author Everson
    @since 03/12/2021
    @version 01
/*/
Static Function slvPesa(aRet)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local cMsgError := ""
    Local nAux      := 1
    Local oReg      := Nil
    Local nAux2     := 1
    Local oModel    := Nil
    Local lInsert   := .T.
    Local cTickProth:= ""
    Local cTktGuad  := ""
    Local cPlaca    := ""
    Local nPeso     := 0
    Local nPesoLiq  := 0
    Local cFluxo    := ""
    Local cCodSitu  := ""
    Local cTag      := ""
    Local dDTPesa   := Nil
    Local cHrPesa   := ""
    Local cCodigo   := ""

    For nAux := 1 To Len(aRet)

        cTickProth  := Alltrim(cValToChar(aRet[nAux]:CREFERENCIAINTEGRACAO))
        cTktGuad    := Alltrim(cValToChar(aRet[nAux]:CCODIGO))
        cTag        := Alltrim(cValToChar(aRet[nAux]:CTAGASSOCIADO))
        cFluxo      := Alltrim(cValToChar(aRet[nAux]:CCODIGOFLUXOTICKET))
        dDTPesa     := SToD(StrTran(Substr(Alltrim(cValToChar(aRet[nAux]:CDATAPESAGEM)),1,10),"-",""))
        cHrPesa     := Substr(Alltrim(cValToChar(aRet[nAux]:CDATAPESAGEM)),12,8)
        
        oReg := aRet[nAux]:OWSOPERACAOTICKET:OWSOPERACAOTICKET
        
        For nAux2 := 1 To Len(oReg)

            cCodigo     := Alltrim(cValToChar(oReg[nAux2]:CCODIGO))
            cTpOp       := Alltrim(cValToChar(oReg[nAux2]:NTIPOOPERACAOCODIGO))
            cPlaca      := StrTran(Alltrim(cValToChar(oReg[nAux2]:CPLACAVEICULO)),"-","")
            cCodSitu    := Alltrim(cValToChar(oReg[nAux2]:NESTADO))
            nPeso       := Val(cValToChar(oReg[nAux2]:NPESO))
            nPesoLiq    := Val(cValToChar(oReg[nAux2]:NPESOLIQOBTIDO))
            
            oModel := FwLoadModel("ADFAT024P")

            lInsert := .T.
            DbSelectArea("ZIH")
            ZIH->(DbSetOrder(4))
            If ZIH->(DbSeek( FWxFilial("ZIH") + cTktGuad + cCodigo ))
                oModel:SetOperation(MODEL_OPERATION_UPDATE)
                lInsert := .F.

            Else
                oModel:SetOperation(MODEL_OPERATION_INSERT)

            EndIf

            oModel:Activate() 

            If lInsert
                oModel:SetValue("MD_MASTER", "ZIH_TKTPRO", cTickProth)
                oModel:SetValue("MD_MASTER", "ZIH_TKTGUA", cTktGuad)
                oModel:SetValue("MD_MASTER", "ZIH_CODIGO", cCodigo)

            EndIf

            oModel:SetValue("MD_MASTER", "ZIH_PLACA" , cPlaca)
            oModel:SetValue("MD_MASTER", "ZIH_SITUAC", cCodSitu)
            oModel:SetValue("MD_MASTER", "ZIH_CODOPE", cTpOp)
            oModel:SetValue("MD_MASTER", "ZIH_DTOPER", dDTPesa)
            oModel:SetValue("MD_MASTER", "ZIH_HROPER", cHrPesa)
            oModel:SetValue("MD_MASTER", "ZIH_PESO"  , nPeso)
            oModel:SetValue("MD_MASTER", "ZIH_PESOLI", nPesoLiq)
            oModel:SetValue("MD_MASTER", "ZIH_FLUXO" , cFluxo)
            oModel:SetValue("MD_MASTER", "ZIH_TAG"   , cTag)

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
                Help(Nil, Nil, "Função slvPesa(ADFAT024P)", Nil, "Erro: " + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

            EndIf

        Next nAux2

    Next nAux

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFT2413
    Processa registros de pesagem.
    @type  User Function
    @author Everson
    @since 06/12/2021
    @version 01
/*/
User Function ADFT2413()

    //Variáveis.
    Local aArea     := GetArea()
    Local cQuery    := ""
    Local nTpPesa   := ""
    Local cMsgError := ""
    Local lRetAtu   := .F.
    Local aRecAtu   := {}

    cQuery += " SELECT  " 
    cQuery += " ZIH_TKTPRO, ZIH_CODOPE, ZIH_PESO, ZIH_PESOLI,  " 
    cQuery += " ZIH_DTOPER, ZIH_HROPER, R_E_C_N_O_ AS REC " 
    cQuery += " FROM  " 
    cQuery += " " + RetSqlName("ZIH") + "  " 
    cQuery += " (NOLOCK) AS ZIH  " 
    cQuery += " WHERE  " 
    cQuery += " ZIH_FILIAL = '" + FWxFilial("ZIH") + "'  " 
    cQuery += " AND ZIH_CODOPE IN  ('2','3')  " 
    cQuery += " AND ZIH_PROCES = '1' " 
    cQuery += " AND ZIH.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY  " 
    cQuery += " ZIH_TKTPRO " 

    TcQuery cQuery New Alias "D_TKT"
    DbSelectArea("D_TKT")
    While ! D_TKT->(Eof())

        nTpPesa     := Iif( Alltrim(cValToChar(D_TKT->ZIH_CODOPE)) == "2", 1, 2)
        cMsgError   := ""

        lRetAtu     := atuTkt(D_TKT->ZIH_TKTPRO, nTpPesa, D_TKT->ZIH_PESO, D_TKT->ZIH_PESOLI, @cMsgError)
            
        Aadd(aRecAtu, {D_TKT->REC, lRetAtu, cMsgError})

        D_TKT->(DbSkip())

    End
    D_TKT->(DbCloseArea())

    If Len(aRecAtu) > 0
        atuPeGua(aRecAtu)

    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} atuTkt
    Atualiza ticket de pesagem.
    @type  User Function
    @author Everson
    @since 06/12/2021
    @version 01
/*/
Static Function atuTkt(cTicket, nTpPesa, nPeso, nPesoLiq, cMsgError)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.

            //ADFT171(cTicket, nPTotal, nTpPesa, cAutomatica, cManual, nPesoLiq, cSolPesMan)
    lRet := U_ADFT171(cTicket, nPeso, nTpPesa, "2", "1", nPesoLiq, "", @cMsgError)

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} atuPeG
    Atualiza pesagem Guardian.
    @type  User Function
    @author Everson
    @since 06/12/2021
    @version 01
/*/
Static Function atuPeGua(aRecAtu)

    //Variáveis.
    Local aArea     := GetArea()
    Local nAux      := 1
    Local lRet      := .F.
    Local oModel    := Nil
    Local cMsgError := ""

    For nAux := 1 To Len(aRecAtu)
    
        DbSelectArea("ZIH")
        ZIH->(DbGoTo(aRecAtu[nAux][1]))

        oModel := FwLoadModel("ADFAT024P")
        oModel:SetOperation(MODEL_OPERATION_UPDATE)
        oModel:Activate()

        If aRecAtu[nAux][2]
            oModel:SetValue("MD_MASTER", "ZIH_PROCES", "2")

        Else
            oModel:SetValue("MD_MASTER", "ZIH_ERRO", aRecAtu[nAux][3])
            
        EndIf

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
            Help(Nil, Nil, "Função atuPeGua(ADFAT024P)", Nil, "Erro na atualização de registro de pesagem Guardian." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

    Next nAux

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFT2414
    Processa importação.
    @type  User Function
    @author Everson
    @since 06/12/2021
    @version 01
/*/
User Function ADFT2414()

    MsAguarde({|| U_ADFT2412() },"Aguarde","Obtendo dados...")
    MsAguarde({|| U_ADFT2413() },"Aguarde","Processando registros...")

Return Nil
