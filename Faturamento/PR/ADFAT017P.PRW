#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"

Static cTbMast  := "ZIB"
Static cTitulo  := "Controle de Pátio"
Static cTiMast  := "Dados do Controle de Pátio"
Static xPula    := Chr(13) + Chr(10)
Static oDdLeitor:= Nil
Static cLeitor  := ""
Static cBalanca := ""
Static cpEncerrado := "5/6"

/*/{Protheus.doc} User Function ADFAT017P
    Cadastro de Controle de Pátio.
    Cad Controle de Pátio
    Chamado 18465.
    @type  Function
    @author Everson
    @since 17/11/2021
    @version 01
/*/
User Function ADFAT017P() // U_ADFAT017P()

    //Variáveis.
    Local oBrowse := Nil
    Local cFilter := " ZIB_FILIAL = '" + FWxFilial("ZIB") + "' "

    (cTbMast)->(DbSetFilter( {|| &cFilter }, cFilter ))


    //Verifica se há ordem de saída para ser excluída.
    U_ADFAT17Q()

    If FWIsAdmin() .And. MsgNoYes("Abrir cadastro?", "Cadastro x Controle de Pátio(ADFAT017P)")
        oBrowse := FwLoadBrw("ADFAT017P")
        oBrowse:Activate()
        Return Nil

    EndIf

    //Interface do controle de pátio.
    U_ADFAT17Y()

    (cTbMast)->(DBClearFilter())

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 17/11/2021
    @version 01
/*/
Static Function BrowseDef()

    //Variáveis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    oBrowse:SetMenuDef("ADFAT017P")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 17/11/2021
    @version 01
/*/
Static Function MenuDef()
Return (FwMVCMenu("ADFAT017P"))
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 17/11/2021
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local bPre      := {|| .T. }
    Local bPost     := {|oModel| vldPos(oModel) }
    Local bCancel   := {|| .T. }
    Local oModel    := MPFormModel():New("ADFAT17", bPre, bPost, /*bCommit*/, bCancel)
    Local oStrMast  := FwFormStruct(1, cTbMast)                                                
     
    //AddFields(<cId >, <cOwner >, <oModelStruct >, <bPre >, <bPost >, <bLoad >)
    oModel:AddFields("MD_MASTER", Nil, oStrMast)

    oModel:SetPrimaryKey({})

    oModel:SetDescription(cTitulo)

    oModel:GetModel("MD_MASTER"):SetDescription(cTiMast)

Return oModel
/*/{Protheus.doc} vldPos
    Pós validação.
    @type  Static Function
    @author Everson
    @since 19/11/2021
    @version 01
/*/
Static Function vldPos(oModel)

    //Variáveis.
    Local aArea      := GetArea()
    Local lRet       := .T.
    Local nOperation := oModel:GetOperation()
    Local cCP        := oModel:GetValue("MD_MASTER", "ZIB_NUMERO")
    Local cTpMovi    := oModel:GetValue("MD_MASTER", "ZIB_TPMOVI")
    Local cPlaca     := oModel:GetValue("MD_MASTER", "ZIB_PLACA")
    Local cTag       := Alltrim(cValToChar(oModel:GetValue("MD_MASTER", "ZIB_TAG")))
    Local cNmOrdem   := Alltrim(cValToChar(Posicione("ZIF",1, FWxFilial("ZIF") + cCP, "ZIF_NUMERO")))
    Local cStatus    := oModel:GetValue("MD_MASTER", "ZIB_STATUS")
    Local cCp2       := ""
    Local lTagObg    := GetMv("MV_#ADF171",, .F.)

    // If lRet .And. cTpMovi == "S" .And. (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)
        
    //     If lRet .And. ! ExistCpo("ZV4", cPlaca, 1) //Valida placa.
    //         lRet := .F.
    //         Help(Nil, Nil, "Função vldPos(ADFAT017P)", Nil, "Cadastro do veículo " + cPlaca + " não encontrado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    //     EndIf

    // EndIf

    If lRet .And. cTpMovi == "R" .And. (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)

        If lRet .And. ! ExistCpo("ZV4", cPlaca, 1) //Valida placa.
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT017P)", Nil, "Cadastro do veículo " + cPlaca + " não encontrado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

    EndIf

    If lRet .And. nOperation == MODEL_OPERATION_UPDATE

        If lRet .And.;
            ! U_ADFAT179(cPlaca, cCP, @cCp2, .F.) //Verifica se há controla de pátio aberto para placa informada.
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT017P)", Nil, "Há registro de controle de pátio não finalizado vinculado (" + cCp2 + ") à placa.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

        //Voltar ao status inicial, com mais de um ticket vinculado.
        If lRet .And. cStatus == "1" .And.;
            U_ADFAT17W(cCP) > 0  //Obtém a quantidade de tickets vinculados ao controle de pátio.          
            oModel:SetValue("MD_MASTER", "ZIB_STATUS", ZIB->ZIB_STATUS)

        EndIf

        If lRet .And. lTagObg .And. Empty(cTag)
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT017P)", Nil, "Necessário informar tag.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

        If lRet .And. ! Empty(cTag) .And. ! Empty(cCP)
            lRet := chkTag(cTag, cCP) //Verifica se a tag de pesagem não está em uso.

        EndIf

    EndIf

    If lRet .And. nOperation == MODEL_OPERATION_INSERT

        If lRet .And.;
            ! U_ADFAT179(cPlaca, cCP, @cCp2, .F.) //Verifica se há controla de pátio aberto para placa informada.
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT017P)", Nil, "Há registro de controle de pátio não finalizado vinculado (" + cCp2 + ") à placa.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        
        EndIf

        If lRet .And. lTagObg .And. Empty(cTag)
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT017P)", Nil, "Necessário informar tag.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

        If lRet .And. ! Empty(cTag) .And. ! Empty(cCP)
            lRet := chkTag(cTag, cCP) //Verifica se a tag de pesagem não está em uso.

        EndIf

    EndIf

    If lRet .And. nOperation == MODEL_OPERATION_DELETE

        If lRet .And. ! Empty(cNmOrdem) //Não exclui controle de pátio se houver ordem de pesagem vinculada.
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT017P)", Nil, "Há a ordem de pesagem " + cNmOrdem + " vinculada ao controle de pátio.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

    EndIf
    
    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT179
    Verifica se há controla de pátio aberto para placa informada.
    @type  User Function
    @author Everson
    @since 24/02/2022
    @version 01
    1=Aberto;2=Analisado Laboratorio;3=Liberado/Aguardando;4=Peso Inicial;5=Encerrado;6=Tag Devolvida                               
/*/
User Function ADFAT179(cPlaca, cCP, cCp2, lExibe)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .T.
    Local cQuery := " SELECT ZIB_NUMERO FROM " + RetSqlName("ZIB") + " (NOLOCK) AS ZIB WHERE ZIB_FILIAL = '" + FWxFilial("ZIB") + "' AND ZIB_PLACA = '" + cPlaca + "' AND ZIB_STATUS NOT IN ('5','6') AND ZIB_NUMERO <> '" + cCP + "' AND ZIB.D_E_L_E_T_ = '' "

    Default cCp2   := ""
    Default lExibe := .T.

    If Empty(cPlaca)
        RestArea(aArea)
        Return .T.

    EndIf

    If Select("C_CPPLACA") > 0
        C_CPPLACA->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "C_CPPLACA"
    DbSelectArea("C_CPPLACA")
    If ! C_CPPLACA->(Eof())
        lRet := .F.
        cCp2 := C_CPPLACA->ZIB_NUMERO

    EndIf
    C_CPPLACA->(DbCloseArea())

    If !lRet .And. lExibe
        MsgInfo("Há registro de controle de pátio para o veículo " + cPlaca + " não finalizado (" + cCp2 + "). Controle de pátio atual " + cCP + ".", "Função ADFAT179(ADFAT017P)")

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 17/11/2021
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oView     := FwFormView():New()
    Local oModel    := FwLoadModel("ADFAT017P")
    Local oStrMast  := FwFormStruct(2, cTbMast)

    oView:SetModel(oModel)

    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")

	oView:AddUserButton("Ler Tag","",{|oView| lerTag(oView, .T., Nil) } ,"",, {MODEL_OPERATION_INSERT ,MODEL_OPERATION_UPDATE} , .T. )   

Return oView
/*/{Protheus.doc} selecBal
    Função para selecionar a balança para pesagem.
    @type  Static Function
    Seleciona a balança.
    @author Everson
    @since 24/11/2021
/*/
Static Function selecBal(lAlt, aRet, aDdBalAut, aLeitores)

    //Variáveis.
    Local cId	        := __cUserID
    Local cBalanca		:= CriaVar('DX5_CODIGO',.F.)
	Local __lPsAuto		:= .F.
	Local __lPsManual	:= .F.
	Local __lPsNao		:= .T.

    If ValType("oDdLeitor") == "O"
        FreeObj(oDdLeitor)

    EndIf
    
    oDdLeitor  := THashMap():New()
    
    Aadd(aDdBalAut,{.F.})

    If ! Pergunte("OGA050001", .T.)
        Return aRet

    EndIf

    aRet := {}
    aLeitores  := {}

    cBalanca := MV_PAR01

    If ! Empty(AllTrim( cValToChar(cBalanca)))
        DX5->(DbSelectArea("DX5"))
        DX5->(DbSetOrder(1))
        If DX5->(MsSeek(FWxFilial( "DX5" ) + cBalanca ))
            
            aDdBalAut := {}
            Aadd(aDdBalAut, { Iif(DX5->DX5_TPBAL == "1", .F., .T.), Alltrim(cValToChar(DX5->DX5_URL)) } )

            If ! Empty(Alltrim(cValToChar(DX5->DX5_XDLEI1)))
                Aadd(aLeitores, Alltrim(cValToChar(DX5->DX5_XDLEI1)))
                oDdLeitor:Set(Alltrim(cValToChar(DX5->DX5_XDLEI1)), { Alltrim(cValToChar(DX5->DX5_XELEI1)), Val(DX5->DX5_XPLEI1) })

            EndIf

            If ! Empty(Alltrim(cValToChar(DX5->DX5_XDLEI2)))
                Aadd(aLeitores, Alltrim(cValToChar(DX5->DX5_XDLEI2)))
                oDdLeitor:Set(Alltrim(cValToChar(DX5->DX5_XDLEI2)), { Alltrim(cValToChar(DX5->DX5_XELEI2)), Val(DX5->DX5_XPLEI2) })

            EndIf

            If ! Empty(Alltrim(cValToChar(DX5->DX5_XDLEI3)))
                Aadd(aLeitores, Alltrim(cValToChar(DX5->DX5_XDLEI3)))
                oDdLeitor:Set(Alltrim(cValToChar(DX5->DX5_XDLEI3)), { Alltrim(cValToChar(DX5->DX5_XELEI3)), Val(DX5->DX5_XPLEI3) })

            EndIf

            DX6->(DbSelectArea("DX6"))
            DX6->(DbSetOrder(1))
            If DX6->(MsSeek( FWxFilial("DX6") + cId + cBalanca ))
                If DX6->DX6_STATUS = "1"
                    __lPsAuto   := ( DX6->DX6_MODAL = "0" .Or. DX6->DX6_MODAL = "2" )
                    __lPsManual := .F.//( DX6->DX6_MODAL = "1" .Or. DX6->DX6_MODAL = "2" )
                    __lPsNao    := .F.
                    
                Else
                    Help(,,"Função selecBal(ADFAT017P)",,"Usuario não autorizado a efetuar pesagens nesta balança!", 1, 0 )
                    __lPsNao := .T.
                EndIf
            
            Else	
               Help(,,"Função selecBal(ADFAT017P)",,"Usuario não autorizado a efetuar pesagens nesta balança!", 1, 0 )
                __lPsNao := .T.
            EndIf
            
            DX6->(dbclosearea())

        Else
            Help(,,"Função selecBal(ADFAT017P)",,"Código da balança informado não está cadastrado.", 1, 0 )
            __lPsNao := .T.

        EndIf

        DX5->(dbclosearea())

    Else
        Help(,,"Função selecBal(ADFAT017P)",,"Código da balança informado não está cadastrado.", 1, 0 )

    EndIf

    If Len(aLeitores) <= 0
        Aadd(aLeitores, {})

    EndIf

    Aadd(aRet, { cBalanca, __lPsAuto, __lPsManual, __lPsNao })

Return aRet
/*/{Protheus.doc} ADFAT17Y
    Interface do controle de pátio.
    @type  Static Function
    Interface do Controle de Pátio.
    @author Everson
    @since 18/11/2021
/*/
User Function ADFAT17Y()

    //Variáveis.
    Local aArea      := GetArea()
    Local oCtlPatio  := Nil
    Local bCarCP     := Nil
    Local bApgOrd    := Nil
    Local bAtuBtn    := Nil
    Local oVecPt     := Nil
    Local aHVcPt     := {}
    Local aColsVcPt  := {}
    Local oTimer     := Nil
    Local nTmpRef    := 60
    Local oTagDev    := Nil
    Local cTagDev    := ""
    Local aTagDev    := {}
    Local oDtIni     := Nil
    Local dDtIni     := Date()-30
    Local oDtFim     := Nil
    Local dDtFim     := Date()
    Local oTpOP      := Nil
    Local cTpOP      := ""
    Local aTpOP      := {}
    Local oPlaca     := Nil
    Local cPlaca     := Space(7)
    Local oProduto   := Nil
    Local cProduto   := Space(15)
    Local aStatCP    := {}
    Local aTpOrdem   := {}
    Local aStatLb    := {}
    Local aTpSeq     := {}
    Local oTxtAtu    := Nil
    Local oGrpOBtn   := Nil
    Local oAttTBtn   := Nil
    Local oEnBaBtn   := Nil
    Local oPesSBtn   := Nil
    Local oPesMBtn   := Nil
    Local oImpTkt    := Nil
    Local oCanTkt    := Nil
    Local oAltTag    := Nil
    Local oExcTag    := Nil
    Local oPnMaster  := Nil
    Local oOrdPes    := Nil
    Local aOrdPes    := {}
    Local oLeitores  := Nil
    Local aDdBalAut  := {}
    Local aLeitores  := {}
    Local aParBal    := {}
    Local lPesaAut   := {}
    Local lPodPesar  := .F.
    Local bTimer     := Nil
    Local oProcInt   := Nil

    Aadd(aParBal, { "", .F., .F., .T. })

    selecBal(.F., @aParBal, @aDdBalAut, @aLeitores)
    lPesaAut   := aDdBalAut[1,1]
    lPodPesar  := ! aParBal[1,4]

    If ! lPodPesar
        Return Nil

    EndIf

    cBalanca := aParBal[1,1]

    bCarCP := {|| oTxtAtu:SetText("Atualizando..."), oTxtAtu:CtrlRefresh(),;
                  carVcPt(aStatCP, oVecPt, aHVcPt, cTagDev, dDtIni, dDtFim, cTpOP, cPlaca, cProduto),;
                  oTxtAtu:SetText("Atualizado às " + Time()), oTxtAtu:CtrlRefresh() }

    bApgOrd := {|| aOrdPes := {}, oOrdPes:setArray(aOrdPes), oOrdPes:Refresh() }
    
    bLOrd  := {|| Iif(Val(cValToChar(oVecPt:nAt)) > 0, carOrdens(oVecPt:nAt, oVecPt, aHVcPt, @oOrdPes, @aOrdPes, cTpOP, aTpOrdem, aStatLb, aTpSeq, dDtIni, dDtFim), Eval(bApgOrd)) }

    bAtuBtn := {|| oGrpOBtn:lActive := lPodPesar,;
                   oAttTBtn:lActive := lPodPesar,;
                   oEnBaBtn:lActive := lPodPesar .And. lPesaAut,;
                   oPesSBtn:lActive := lPodPesar .And. ! lPesaAut,;
                   oPesMBtn:lActive := lPodPesar .And. ! lPesaAut,;
                   oImpTkt:lActive  := lPodPesar,;
                   oCanTkt:lActive  := lPodPesar;
                }

    aStatCP := RetSX3Box(GetSX3Cache("ZIB_STATUS", "X3_CBOX"),,,1)
    aTpOrdem:= RetSX3Box(GetSX3Cache("ZIF_TPMOVI", "X3_CBOX"),,,1)
    aStatLb := RetSX3Box(GetSX3Cache("ZIF_STATLA", "X3_CBOX"),,,1)
    aTpSeq  := RetSX3Box(GetSX3Cache("ZIG_TPSEQU", "X3_CBOX"),,,1)

    Aadd(aTagDev,"1=Não")
    Aadd(aTagDev,"2=Sim")

    Aadd(aTpOP,"T=Todos")
    Aadd(aTpOP,"E=Entrada")
    Aadd(aTpOP,"S=Saída")
    Aadd(aTpOP,"O=Outras")
    Aadd(aTpOP,"R=Ração")

    oCtlPatio			 := MsDialog():Create()
	oCtlPatio:cName     := "oCtlPatio"
	oCtlPatio:cCaption  := "Controle de Pátio"
	oCtlPatio:nLeft     := 34
	oCtlPatio:nTop      := 222
	oCtlPatio:nWidth    := 1200
	oCtlPatio:nHeight   := 600
	oCtlPatio:lShowHint := .F.
	oCtlPatio:lCentered := .T.

        oTxtAtu := TSay():New(003,005,{||""},oCtlPatio,,,,,,.T.,CLR_RED,CLR_WHITE,100,010)

        bTimer := {|| oTimer:DeActivate(), oTimer:nInterval := nTmpRef *1000,  oTimer:Activate()}

        TGet():New(010,005,{|u|If(PCount() == 0,nTmpRef,nTmpRef := u)},oCtlPatio,020,010,"@E 99",{|| Iif(Val(cValToChar(nTmpRef)) >= 10, Eval(bTimer) ,Help(Nil, Nil, "Função atrTicket(ADFAT017P)", Nil, "Digite um número maior ou igual a 10.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})), Val(cValToChar(nTmpRef)) >= 10  },0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nTmpRef",,,,.T.,,,"Interv.(seg)",2) 
		
        cTagDev := aTagDev[1]
	    oTagDev := TComboBox():New(003,065,{|u|if(PCount() > 0 ,cTagDev := u,cTagDev)},;
	    aTagDev,040,15,oCtlPatio,,{|| },,,,.T.,,,,,,,,,"cTagDev","Exi Tag Dev",1)
        oTagDev:bChange := {|| MsAguarde({|| Eval(bCarCP), Eval(bApgOrd) }, "Aguarde", "Carregando registros...")}
       
        oDtIni := TGet():New(003,110,{|u|If(PCount() == 0,dDtIni,dDtIni := u)},oCtlPatio,070,010,"@D",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtIni",,,,.T.,,,"Data Inicial",1) 

        oDtFim := TGet():New(003,185,{|u|If(PCount() == 0,dDtFim,dDtFim := u)},oCtlPatio,070,010,"@D",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtFim",,,,.T.,,,"Data Final",1) 

		cTpOP := aTpOP[1]
	    oTpOP := TComboBox():New(003,260,{|u|if(PCount() > 0 ,cTpOP := u,cTpOP)},;
	    aTpOP,100,15,oCtlPatio,,{|| },,,,.T.,,,,,,,,,"cTpOP","Tipo de Ordem",1)

        oPlaca := TGet():New(003,365,{|u|If(PCount() == 0,cPlaca,cPlaca := u)},oCtlPatio,050,010,"@!",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cPlaca",,,,.T.,,,"Placa",1) 

        oProduto := TGet():New(003,420,{|u|If(PCount() == 0,cProduto,cProduto := u)},oCtlPatio,050,010,"@!",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cProduto",,,,.T.,,,"Produto",1) 

        TButton():New(010,475,"Filtrar",oCtlPatio,{||;
            MsAguarde({|| Eval(bTimer),;
                          Eval(bCarCP),;
                          Eval(bLOrd) }, "Aguarde", "Carregando registros...");
        },035,011,,,.F.,.T.,.F.,,.F.,,,.F. )

        oProcInt := TButton():New(010,515,"Sinc Pesa" ,oCtlPatio,{|| FWMsgRun(,{|| U_ADFAT251(), Eval(bCarCP), Eval(bLOrd) }, "Função ADFAT17Y(ADFAT017P)", "Processando...") },037,11,,,.F.,.T.,.F.,,.F.,{|| .F. },,.F. )
        oProcInt:bWhen := {|| FWIsAdmin() .And. lPesaAut }

        TButton():New(010,557,"Log OP"          ,oCtlPatio,{|| carLog(oOrdPes, aOrdPes) },037,11,,,.F.,.T.,.F.,,.F.,,,.F. )

        TButton():New(030,515,"Incluir CP"      ,oCtlPatio,{|| addVeic(), Eval(bCarCP), Eval(bLOrd) },037,15,,,.F.,.T.,.F.,,.F.,,,.F. )

        TButton():New(030,557,"Alterar CP"      ,oCtlPatio,{|| altCP(oVecPt, aHVcPt), Eval(bCarCP), Eval(bLOrd) },037,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        
        TButton():New(050,515,"Central XML"     ,oCtlPatio,{|| U_CENTNFEXM() },080,15,,,.F.,.T.,.F.,,.F.,{|| .F. },,.F. )

        TButton():New(070,515,"Ord Racao"       ,oCtlPatio,{|| U_ADFAT032P(), Eval(bLOrd) },037,15,,,.F.,.T.,.F.,,.F.,,,.F. )

        TButton():New(070,557,"Agrp Racao"      ,oCtlPatio,{|| U_ADFAT034P(), Eval(bLOrd) },037,15,,,.F.,.T.,.F.,,.F.,,,.F. )

        TButton():New(090,515,"Apontar Lacre"   ,oCtlPatio,{|| U_ADFAT035P(), Eval(bCarCP), Eval(bApgOrd) },080,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        
        TButton():New(110,515,"Gera Ped"        ,oCtlPatio,{|| gerPedS(oVecPt:aCols[oVecPt:nAt,Ascan(aHVcPt,{|x| AllTrim(x[2]) == "NUMER" })]), Eval(bCarCP), Eval(bApgOrd) },037,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        
        TButton():New(110,557,"Gera NF"         ,oCtlPatio,{|| U_ADFAT041P(), Eval(bCarCP), Eval(bApgOrd) },037,15,,,.F.,.T.,.F.,,.F.,,,.F. )

        TButton():New(130,515,"Devolver Tag"    ,oCtlPatio,{|| devoTag(oVecPt, aHVcPt), Eval(bCarCP), Eval(bApgOrd) },080,15,,,.F.,.T.,.F.,,.F.,,,.F. )

        Aadd(aHVcPt,{" ","LEG"    	,"@BMP"     ,001, 0,.T.,"","","","R","","",.F.,"V","","","",""})
        Aadd(aHVcPt,{"Número" 	    ,"NUMER","" ,TamSX3("ZIB_NUMERO")[1], 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Cod Oper." 	,"CODROT","" ,TamSX3("ZI9_CODROT")[1], 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Operação" 	,"OPERA","" ,030, 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Placa" 		,"PLACA","" ,TamSX3("ZIB_PLACA")[1], 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Produto" 	    ,"PRODU","" ,008, 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Ordem" 	    ,"ORDEM","" ,008, 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Data/Hora" 	,"DTHR" ,"" ,020, 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Tag" 		    ,"TAG"  ,"" ,008, 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"N Tag" 	    ,"NTAG" ,"" ,030, 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Situação" 	,"SITUA","" ,025, 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Motorista" 	,"MOTO" ,"" ,008, 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Tipo Mov" 	,"TPMOV",""  ,TamSX3("ZIB_TPMOVI")[1], 0,"","" ,"C","",""})
        			
        oVecPt := MsNewGetDados():New(030,005,155,510,,"Allwaystrue()","Allwaystrue()","",{},Nil,999,Nil,Nil,Nil,oCtlPatio,aHVcPt,@aColsVcPt)
        oVecPt:oBrowse:bLDblClick := {|| Eval(bTimer), carOrdens(oVecPt:nAt, oVecPt, aHVcPt, @oOrdPes, @aOrdPes, cTpOP, aTpOrdem, aStatLb, aTpSeq, dDtIni, dDtFim),;
                                         geraOrd(oVecPt:nAt, oVecPt, aHVcPt, @oOrdPes, @aOrdPes, cTpOP, aTpOrdem, aStatLb, aTpSeq, dDtIni, dDtFim) }

        TGroup():New(157,005,200,155,"Balança | Leitor",oCtlPatio,,,.T.)
            TButton():New(165,010,"SB",oCtlPatio,{|| aLeitores := {}, selecBal(.T., @aParBal, @aDdBalAut, @aLeitores), lPodPesar := ! aParBal[1,4], lPesaAut := aDdBalAut[1,1], cBalanca := aParBal[1,1], oLeitores:SetItems(aLeitores),Iif(Len(aLeitores) <=0 , Nil, cLeitor := aLeitores[1]), oLeitores:Refresh(), Eval(bAtuBtn) },020,15,,,.F.,.T.,.F.,,.F.,,,.F. )	
            TGet():New(165,032,{|u|If(PCount() == 0,cBalanca,cBalanca := u)},oCtlPatio,063,013,"@C",,0,16777215,,.F.,,.T.,,.F.,{|| .F.},.F.,.F.,,.F.,.F. ,,"cBalanca",,,,.T.,,,"",1)
            oLeitores := TComboBox():New(165,100,{|u|if(PCount() > 0 ,cLeitor := u,cLeitor)},;
            aLeitores,050,15,oCtlPatio,,{|| },,,,.T.,,,,,,,,,"cLeitor","",1)

        oGrpOBtn := TButton():New(165,160,"Agrupar Ordem"   ,oCtlPatio,{|| dfAgpOrd(oOrdPes, aOrdPes, aTpOrdem),  Eval(bLOrd)  },045,15,,,.F.,.T.,.F.,,.F.,,,.F. )	
        oGrpOBtn:lActive := .F.
        oAttTBtn := TButton():New(165,210,"Atribuir Ticket" ,oCtlPatio,{|| atrTicket(oOrdPes, aOrdPes, cBalanca), Eval(bLOrd), Eval(bCarCP) },045,15,,,.F.,.T.,.F.,,.F.,,,.F. )	       
        oEnBaBtn := TButton():New(165,290,"Env. Balança"    ,oCtlPatio,{|| envBlcAut(oOrdPes, aOrdPes, cBalanca), Eval(bLOrd), Eval(bCarCP) },045,15,,,.F.,.T.,.F.,,.F.,,,.F. )	
        oPesSBtn := TButton():New(165,340,"Pes. Semiaut"    ,oCtlPatio,{|| pesaSemAut(.F., @aParBal, oOrdPes, aOrdPes, cBalanca), Eval(bLOrd), Eval(bCarCP) },045,15,,,.F.,.T.,.F.,,.F.,,,.F. )	
        oPesMBtn := TButton():New(165,390,"Pes. Manual"     ,oCtlPatio,{|| pesaManu(@aParBal, oOrdPes, aOrdPes, cBalanca), Eval(bLOrd), Eval(bCarCP) },045,15,,,.F.,.T.,.F.,,.F.,,,.F. )	
        oImpTkt  := TButton():New(165,465,"Imprimir Ticket" ,oCtlPatio,{|| impTkt(oOrdPes, aOrdPes) },045,15,,,.F.,.T.,.F.,,.F.,,,.F. )	
                
        oPnMaster := TPanel():New(182,005,,oCtlPatio,,,,,,505,100)
 
        oOrdPes := FwBrowse():New()
        oOrdPes:setOwner(oPnMaster)
        oOrdPes:setDataArray()
        oOrdPes:setArray(aOrdPes)
        oOrdPes:disableConfig()
        oOrdPes:disableReport()

        oOrdPes:AddStatusColumns({|| U_ADFAT17G( aOrdPes[oOrdPes:nAt,14], aOrdPes[oOrdPes:nAt,17] )})
    
        oOrdPes:addColumn({"Contr. Pátio"      , {||aOrdPes[oOrdPes:nAt,16]}, "C", ""                  , 2, 006    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,16]",, .F., .T., , "ID16" })
        oOrdPes:addColumn({"Agrupador"         , {||aOrdPes[oOrdPes:nAt,18]}, "C", ""                  , 2, 010    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,18]",, .F., .T., , "ID18" })
        oOrdPes:addColumn({"Qtd. Agrupador"    , {||aOrdPes[oOrdPes:nAt,24]}, "N", "@E 999,999,999.999", 2, 010    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,24]",, .F., .T., , "ID24" })
        oOrdPes:addColumn({"Ordem"             , {||aOrdPes[oOrdPes:nAt,08]}, "C", ""                  , 2, 010    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,08]",, .F., .T., , "ID8" })
        oOrdPes:addColumn({"Tp Ordem"          , {||aOrdPes[oOrdPes:nAt,02]}, "C", ""                  , 1, 010    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,02]",, .F., .T., , "ID2" })
        oOrdPes:addColumn({"Fornecedor"        , {||aOrdPes[oOrdPes:nAt,03]}, "C", ""                  , 1, 030    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,03]",, .F., .T., , "ID3" })
        oOrdPes:addColumn({"Produto"           , {||aOrdPes[oOrdPes:nAt,04]}, "C", ""                  , 1, 020    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,04]",, .F., .T., , "ID4" })
        oOrdPes:addColumn({"Lote"              , {||aOrdPes[oOrdPes:nAt,05]}, "C", ""                  , 2, 004    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,05]",, .F., .T., , "ID5" })
        oOrdPes:addColumn({"Nm Lote"           , {||aOrdPes[oOrdPes:nAt,25]}, "C", ""                  , 1, 010    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,25]",, .F., .T., , "ID25"})
        oOrdPes:addColumn({"Quantidade"        , {||aOrdPes[oOrdPes:nAt,06]}, "N", "@E 999,999,999.999", 2, 010    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,06]",, .F., .T., , "ID6" })
        oOrdPes:addColumn({"Situação"          , {||aOrdPes[oOrdPes:nAt,12]}, "C", ""                  , 1, 017    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,12]",, .F., .T., , "ID12" })
        oOrdPes:addColumn({"Laboratório"       , {||aOrdPes[oOrdPes:nAt,07]}, "C", ""                  , 1, 020    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,07]",, .F., .T., , "ID7" })
        oOrdPes:addColumn({"Agrupada"          , {||aOrdPes[oOrdPes:nAt,09]}, "C", ""                  , 1, 003    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,09]",, .F., .T., , "ID9" })
        oOrdPes:addColumn({"Ticket Guardian"   , {||aOrdPes[oOrdPes:nAt,10]}, "C", ""                  , 2, 010    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,10]",, .F., .T., , "ID10" })
        oOrdPes:addColumn({"Ticket"            , {||aOrdPes[oOrdPes:nAt,11]}, "C", ""                  , 2, 010    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,11]",, .F., .T., , "ID11" })
        oOrdPes:addColumn({"Seq"               , {||aOrdPes[oOrdPes:nAt,13]}, "C", ""                  , 0, 003    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,13]",, .F., .T., , "ID13" })
        
        oOrdPes:addColumn({"Peso Inicial"      , {||aOrdPes[oOrdPes:nAt,27]}, "N", "@E 999,999,999"    , 2, 010    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,27]",, .F., .T., , "ID27" })
        oOrdPes:addColumn({"Peso Final"        , {||aOrdPes[oOrdPes:nAt,28]}, "N", "@E 999,999,999"    , 2, 010    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,28]",, .F., .T., , "ID28" })
        oOrdPes:addColumn({"Peso Liquido"      , {||aOrdPes[oOrdPes:nAt,29]}, "N", "@E 999,999,999"    , 2, 010    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,29]",, .F., .T., , "ID29" })
        
        oOrdPes:addColumn({"Sol Pes Manual"    , {||aOrdPes[oOrdPes:nAt,20]}, "C", ""                  , 2, 010    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,20]",, .F., .T., , "ID20" })
        oOrdPes:addColumn({"Pedidos de Saída"  , {||aOrdPes[oOrdPes:nAt,26]}, "C", ""                  , 1, 015    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,26]",, .F., .T., , "ID26" })
        oOrdPes:addColumn({"Notas Fiscais"     , {||aOrdPes[oOrdPes:nAt,30]}, "C", ""                  , 1, 035    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,30]",, .F., .T., , "ID30" })
    
        oOrdPes:Activate()
                   
                   TButton():New(187,515,"Transferência Ordem" ,oCtlPatio,{|| transOrd(oOrdPes, aOrdPes), Eval(bLOrd), Eval(bCarCP) },080,15,,,.F.,.T.,.F.,,.F.,,,.F. )
                   TButton():New(207,515,"Rom. Ped. Venda"     ,oCtlPatio,{|| impRoPV(oOrdPes, aOrdPes) , Eval(bLOrd), Eval(bCarCP) },080,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        oCanTkt := TButton():New(227,515,"Cancelar Ticket"     ,oCtlPatio,{|| cancTkt(oOrdPes, aOrdPes), Eval(bLOrd), Eval(bCarCP) },080,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        oAltTag := TButton():New(247,515,"Alterar Tag"         ,oCtlPatio,{||  altTag(oOrdPes, aOrdPes, cBalanca) , Eval(bLOrd), Eval(bCarCP) },080,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        oExcTag := TButton():New(267,515,"Excluir Tag"         ,oCtlPatio,{||  excTag(oOrdPes, aOrdPes, cBalanca) , Eval(bApgOrd), Eval(bCarCP) },080,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        
        // oFechar := TButton():New(270,555,"Fechar",oCtlPatio,{|| oCtlPatio:End() },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )
        // oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")	

        oTimer := TTimer():New(nTmpRef * 1000, {|| Eval(bCarCP),;
                                                   Eval(bLOrd) }, oCtlPatio)

        oTimer:Activate()

    oCtlPatio:Activate(,,,.T.,{||.T.},, {|| Eval(bCarCP), Eval(bLOrd), Eval(bAtuBtn) })

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} carLog
    Carrega logs de processamento da ordem de pesagem.
    @type  Static Function
    @author Everson
    @since 17/05/2022
    @version 01
/*/
Static Function carLog(oOrdPes, aOrdPes)

    //Variáveis.
    Local aArea     := GetArea()
    Local cQuery    := ""
    Local nLinha    := Val(cValToChar(oOrdPes:nAt))
    Local cNmOrdem  := ""
    Local cTexto    := ""

    If nLinha <= 0 .Or. Len(aOrdPes) <= 0
        Help(Nil, Nil, "Função carLog(ADFAT017P)", Nil, "Não há dados.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    EndIf

    cNmOrdem := aOrdPes[nLinha,08]
    If Empty(cNmOrdem)
        Help(Nil, Nil, "Função carLog(ADFAT017P)", Nil, "Ordem de pesagem não selecionada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    cQuery += " SELECT  " 
    cQuery += " ZBE_DATA, ZBE_HORA, ZBE_MODULO, ZBE_LOG " 
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("ZBE") + " (NOLOCK) AS ZBE " 
    cQuery += " WHERE " 
    cQuery += " ZBE_FILIAL = '" + FWxFilial("ZBE") + "' " 
    cQuery += " AND ZBE_PARAME = '" + cNmOrdem + "' " 
    cQuery += " AND ZBE_ROTINA = 'ADFAT017P' " 
    cQuery += " ORDER BY ZBE_DATA DESC, ZBE_HORA DESC " 

    If Select("D_DLOG") > 0
        D_DLOG->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_DLOG"
    DbSelectArea("D_DLOG")
    While ! D_DLOG->(Eof())

        cTexto += DToC(SToD(D_DLOG->ZBE_DATA)) + " " + Alltrim(cValToChar(D_DLOG->ZBE_HORA)) + " --- " + PadR(Alltrim(cValToChar(D_DLOG->ZBE_MODULO)), 15, " ") + xPula + Alltrim(cValToChar(D_DLOG->ZBE_LOG)) + xPula + xPula

        D_DLOG->(DbSkip())

    End
    D_DLOG->(DbCloseArea())


    U_TExTelaMen("Logs OP: " +  cNmOrdem, cTexto, "Arial",10,,.F.,.F.)

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} transOrd
    Interface para transferência de ordem de pesagem.
    @type  Static Function
    @author Everson
    @since 11/05/2022
    @version 01
/*/
Static Function transOrd(oOrdPes, aOrdPes)

    //Variáveis.
    Local aArea     := GetArea()
    Local nLinha    := Val(cValToChar(oOrdPes:nAt))
    Local lRet      := .F.
    Local oModal    := Nil
    Local oContainer:= Nil
    Local aButtons  := {}
    Local cTpOrdem  := ""
    Local cCP       := ""
    Local cNmOrdem  := ""
    Local cRoteiro  := ""
    Local cOrdOrg   := Space(TamSX3("ZIF_NUMERO")[1])
    Local cOrdDes   := Space(TamSX3("ZIF_NUMERO")[1])
    Local bOO       := Nil
    Local bOD       := Nil
    Local lRetC     := .F.
    Local oGetOO    := Nil
    Local oGetOD    := Nil

    If nLinha <= 0 .Or. Len(aOrdPes) <= 0
        Help(Nil, Nil, "Função transOrd(ADFAT017P)", Nil, "Não há dados.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    EndIf

    cTpOrdem := aOrdPes[nLinha,14]
    If cTpOrdem <> "R"
        Help(Nil, Nil, "Função transOrd(ADFAT017P)", Nil, "Tipo de ordem inválido.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    EndIf

    cCP := aOrdPes[nLinha,16]
    If Empty(cCP)
        Help(Nil, Nil, "Função transOrd(ADFAT017P)", Nil, "Controle de pátio não selecionado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    EndIf

    //Verifica se o controle de pátio está encerrado.
    If U_ADFAT17L(cCP)
        Help(Nil, Nil, "Função transOrd(ADFAT017P)", Nil, "Controle de pátio " + cCP + " encerrado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    cNmOrdem := aOrdPes[nLinha,08]
    If Empty(cNmOrdem)
        Help(Nil, Nil, "Função transOrd(ADFAT017P)", Nil, "Ordem de pesagem não selecionada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf
    
    //Posiciona na ordem de pesagem.
    If ! U_ADFAT16A(cNmOrdem)
        Help(Nil, Nil, "Função transOrd(ADFAT017P)", Nil, "Ordem de pesagem não localizada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    cRoteiro := ZIF->ZIF_ROTEIR

    If Empty(cRoteiro)
        Help(Nil, Nil, "Função transOrd(ADFAT017P)", Nil, "Ordem de pesagem não possui roteiro.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    oModal := FWDialogModal():New()        
	oModal:SetEscClose(.F.)
	oModal:setTitle("Transferência Ordem - CP " + cCP)
	oModal:setSize(100, 200)
	oModal:createDialog()

    Aadd(aButtons,{Nil,"Confirmar", {|| lRet := confTran(cOrdOrg, cOrdDes), Iif(!lRet, Nil, oModal:DeActivate()) },"","",.T.,.F.})
    Aadd(aButtons,{Nil,"Cancelar",  {|| oModal:DeActivate() },"","",.T.,.F.})

	oModal:addButtons(aButtons)

        oContainer := TPanel():New(025,,, oModal:getPanelMain())
        oContainer:Align := CONTROL_ALIGN_ALLCLIENT

        TSay():New(005,010,{||"Roteiro " + cRoteiro}   ,oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,010)

        bOO := {|| lRetC := pesOrdTr(1, cRoteiro), Iif(!lRetC, Nil, Eval({|| cOrdOrg := ZIF->ZIF_NUMERO, oGetOO:Refresh() }) ) }
        oGetOO := TGet():New(020,010,{|u|If(PCount() == 0,cOrdOrg,cOrdOrg := u)}, oContainer,060,013,"",{|| .T. },0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cOrdOrg",,,,.T.,,,"Ordem Origem",1) 
        TButton():New(027,070,"OO", oContainer, bOO,020,15,,,.F.,.T.,.F.,,.F.,,,.F. )	
        
        bOD := {|| lRetC := pesOrdTr(2, cRoteiro, cOrdOrg), Iif(!lRetC, Nil, Eval({|| cOrdDes := ZIF->ZIF_NUMERO, oGetOD:Refresh() }) ) }
        oGetOD := TGet():New(020,115,{|u|If(PCount() == 0,cOrdDes,cOrdDes := u)}, oContainer,060,013,"",{|| .T. },0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cOrdDes",,,,.T.,,,"Ordem Destino",1) 
        TButton():New(027,175,"OD", oContainer, bOD,020,15,,,.F.,.T.,.F.,,.F.,,,.F. )	

	oModal:Activate()

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} confTran
    Confirma transferência de ordem de pesagem.
    @type  Static Function
    @author Everson
    @since 10/05/2022
    @version 01
/*/
Static Function confTran(cOrdOrg, cOrdDes)

    //Variáveis.
    Local aArea    := GetArea()
    Local lRet     := .F.
    Local cTktNv   := ""
    Local cStatNv  := ""
    Local cStat2   := ""
    Local cOrdemC  := ""
    Local lGemba   := GetMV("MV_#UGEMBA",,.F.) 
    Local cMsgError:= ""
    Local lErrGemba:= .F.

    If Empty(cOrdOrg) .Or. Empty(cOrdDes)
        MsgInfo("É necessário selecionar as ordens de origem e destino.", "Função confTran(ADFAT017P)")
        RestArea(aArea)
        Return .F.

    EndIf

    //Ordem de origem.
    If ! U_ADFAT16A(cOrdOrg)
        MsgInfo("Ordem de pesagem de origem " + cValToChar(cOrdOrg) + " não localizada.", "Função confTran(ADFAT017P)")
        RestArea(aArea)
        Return .F.

    EndIf

    cStatNv := ZIF->ZIF_STATUS
    cOrdemC := ZIF->ZIF_ORDRAC

    //Ticket da ordem de origem.
    If ! U_ADFAT196(cOrdOrg)
        MsgInfo("Ticket de pesagem da ordem de pesagem de origem " + cValToChar(cOrdOrg) + " não localizado.", "Função confTran(ADFAT017P)")
        RestArea(aArea)
        Return .F.

    EndIf

    cTktNv := ZIG->ZIG_NUMERO

    //Ordem de destino.
    If ! U_ADFAT16A(cOrdDes)
        MsgInfo("Ordem de pesagem de destino " + cValToChar(cOrdDes) + " não localizada.", "Função confTran(ADFAT017P)")
        RestArea(aArea)
        Return .F.

    EndIf

    cStat2 := ZIF->ZIF_STATUS


    Begin Transaction

        //Altera o status da ordem selecionada.
        If ! U_ADFAT164(cOrdDes, cStatNv, 1, @cMsgError)
            DisarmTransaction()
            Break

        EndIf
        
        //Altera o status da ordem tomada.
        If ! U_ADFAT164(cOrdOrg, cStat2, 1, @cMsgError)
            DisarmTransaction()
            Break

        EndIf

        //Altera a ordem do ticket de pesagem selecionado.
        If ! U_ADFAT191(cTktNv, "ZIG_ORDEM", cOrdDes, @cMsgError)
            DisarmTransaction()
            Break

        EndIf

        If ! U_ADFAT166(cOrdOrg, @cMsgError)
            DisarmTransaction()
            Break

        EndIf

        //Cancela ordem de carregamento de ração.
        If ! Empty(cOrdemC) .And. ! U_ADFAT32H(cOrdemC, @cMsgError)
            DisarmTransaction()
            Break

        EndIf

        //Cancela ordem de pesagem original no Gemba.
        If lGemba .And. ! U_ADFAT50G(cOrdOrg, @cMsgError)
            lErrGemba := .T.
            DisarmTransaction()
            Break

        EndIf

        //Envia nova ordem de pesagem para o Gemba.
        If lGemba .And. ! U_ADFAT50F(cOrdDes, @cMsgError)
            lErrGemba := .T.
            DisarmTransaction()
            Break

        EndIf

        lRet := .T.

    End transaction
    
    If ! lRet
        U_ADFAT173("Transferência de ordem : " + cMsgError, cOrdDes, "", "PROTHEUS")

    Else

        TcSqlExec(" UPDATE " + RetSqlName("ZBE") + " SET ZBE_PARAME = '" + cOrdDes + "' WHERE ZBE_FILIAL = '" + FWxFilial("ZBE") + "' AND ZBE_PARAME = '" + cOrdOrg + "' AND ZBE_ROTINA = 'ADFAT017P' AND D_E_L_E_T_ = '' ")

        U_ADFAT173("Transferência de ordem : realizada com sucesso", cOrdDes, "", "PROTHEUS")

    EndIf

    If lErrGemba
        MsgInfo("Não foi realizar as integrações com o Gemba. " + xPula + cMsgError, "Função confTran(ADFAT017P)")
        RestArea(aArea)
        Return .F.

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} pesOrdTr
    Consulta padrão específica.
    @type  Static Function
    @author Everson
    @since 10/05/2022
    @version 01
/*/
Static Function pesOrdTr(nTipo, cRoteiro, cOrdOrg)

    //Variáveis.
    Local oDlg, oLbx
    Local aCpos  := {}
    Local aRet   := {}
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local lRet   := .F.

    Default cOrdOrg := ""

    If nTipo == 2 .And. Empty(cOrdOrg)
        MsgInfo("Selecione a ordem de origem.", "Função pesOrdTr(ADFAT017P)")
        Return Nil

    EndIf

    cQuery += ""
    cQuery += " SELECT  " 
    cQuery += " ZIF_NUMERO, ZIF_PRDSAG, ZIF_PRDPRO " 
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("ZIF") + " (NOLOCK) AS ZIF " 
    cQuery += " WHERE " 
    cQuery += " ZIF_FILIAL = '" + FWxFilial("ZIF") + "' " 
    cQuery += " AND ZIF_ROTEIR = '" + cRoteiro + "' " 
    cQuery += " AND ZIF_TPMOVI = 'R' " 

    If nTipo == 2
        cQuery += " AND ZIF_NUMERO <> '" + cOrdOrg + "' " 

    EndIf

    cQuery += " AND ZIF.D_E_L_E_T_ = '' "
    cQuery += " AND ZIF_NUMERO NOT IN ( " 
    cQuery += " SELECT ZIT_ORDEM FROM " + RetSqlName("ZIT") + " (NOLOCK) AS ZIT WHERE ZIT_FILIAL = '" + FWxFilial("ZIT") + "' AND ZIT.D_E_L_E_T_ = '' " 
    cQuery += " UNION ALL " 
    cQuery += " SELECT ZIZ_ORDEM FROM " + RetSqlName("ZIZ") + " (NOLOCK) AS ZIZ WHERE ZIZ_FILIAL = '" + FWxFilial("ZIZ") + "' AND ZIZ.D_E_L_E_T_ = '' " 
    cQuery += " UNION ALL " 
    cQuery += " SELECT ZIY_ORDEM FROM " + RetSqlName("ZIY") + " (NOLOCK) AS ZIY WHERE ZIY_FILIAL = '" + FWxFilial("ZIY") + "' AND ZIY.D_E_L_E_T_ = '' " 
    cQuery += " ) " 
    cQuery += " ORDER BY ZIF_NUMERO " 

    cQuery := ChangeQuery(cQuery)

    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

    While (cAlias)->(!Eof())

        If nTipo == 1
        
            If ! U_ADFAT196((cAlias)->(ZIF_NUMERO)) //Localiza ticket de pesagem pelo número da ordem de pesagem.
                (cAlias)->(DbSkip())
                Loop

            EndIf

            If ZIG->ZIG_INICIA <> "2" //A ordem de pesagem original precisa ter peso inicial, pois a ordem já deve ter sido integrada no Gemba.
                (cAlias)->(DbSkip())
                Loop

            EndIf

        EndIf

        If nTipo == 2 .And.   U_ADFAT196((cAlias)->(ZIF_NUMERO)) //Localiza ticket de pesagem pelo número da ordem de pesagem.
            (cAlias)->(DbSkip())
            Loop

        EndIf

        Aadd(aCpos,{(cAlias)->(ZIF_NUMERO), (cAlias)->(ZIF_PRDSAG), (cAlias)->(ZIF_PRDPRO)})

        (cAlias)->(DbSkip())

    End
    (cAlias)->(DbCloseArea())

    If Len(aCpos) < 1
        Aadd(aCpos,{" ", " ", ""})

    EndIf

    DEFINE MSDIALOG oDlg TITLE /*STR0083*/ "Ordem de Pesagem" FROM 0,0 TO 240,500 PIXEL

        @ 10,10 LISTBOX oLbx FIELDS HEADER 'Ordem de Pesagem' , 'Produto',  'Produto Protheus' SIZE 230,95 OF oDlg PIXEL

        oLbx:SetArray( aCpos )
        oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3] }}
        oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1], oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3] }}}

    DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1], oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3] })  ENABLE OF oDlg
    ACTIVATE MSDIALOG oDlg CENTER

    If Len(aRet) > 0 .And. lRet
        If Empty(aRet[1])
            lRet := .F.

        Else
            ZIF->(DbSetOrder(2))
            ZIF->(DbSeek( FWxFilial("ZIF") + aRet[1] ) )

        EndIf

    EndIf

Return lRet
/*/{Protheus.doc} gerPedS
    Gera pedido de saída.
    @type  Static Function
    @author Everson
    @since 10/03/2022
    @version 01
/*/
Static Function gerPedS(cCP)

    //Variáveis.
    Local aArea     := GetArea()
    Local cTpMovi   := ""
    Local cNmOrdem  := ""
    Local aCampo    := {}
    Local cFornece  := ""
    Local cLjForn   := ""
    Local cGranja   := ""
    Local cGranjada := ""
    Local cMemNf2   := ""
    Local cTpFrt    := ""
    Local cPlaca    := ""
    Local cUFPlaca  := ""
    Local cTransp   := ""
    Local nPesoLiq  := ""
    Local cTpPed    := ""
    Local cProduto  := ""
    Local cLocPad   := ""
    Local cTes      := ""
    Local nVlrUnit  := 0
    Local nTotal    := 0
    Local cNvPed    := ""
    Local cPedidos  := ""
    Local lRetPed   := .F.
    Local cMsgError := ""
    Local cUUids    := ""
    Local cPedGer   := ""

    Default cCP     := """

    If Empty(cCP)
        MsgInfo("Selecione um registro para emissão de pedido de saída.", "Função gerPedS(ADFAT017P)")
        RestArea(aArea)
        Return .F.

    EndIf
    
    //Posiciona no registro de pátio selecionado.
    If ! U_ADFAT17U(cCP)
        MsgInfo("Controle de pátio " + cCP + " não localizado.", "Função gerPedS(ADFAT017P)")
        RestArea(aArea)
        Return .F.

    EndIf

    cTpMovi := ZIB->ZIB_TPMOVI

    //Somente movimento do tipo "Ração" pode gerar pedido de saída.
    If cTpMovi <> "R"
        MsgInfo("Tipo de movimento não permite emissão de pedido de saída(" + cTpMovi + ").", "Função gerPedS(ADFAT017P)")
        RestArea(aArea)
        Return .F.

    EndIf

    DbSelectArea("ZIF")
    ZIF->(DbSetOrder(1))
    If ! ZIF->( DbSeek( FWxFilial("ZIF") + cCP))
        MsgInfo("Não há ordens de pesagem vinculadas ao controle de pátio " + cCP + ".", "Função gerPedS(ADFAT017P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If ! MsgYesNo("Deseja emitir pedido de saída para o controle de pátio " + cCP + "?", "Função gerPedS(ADFAT017P)")
        RestArea(aArea)
        Return .F.

    EndIf

    While ! ZIF->(Eof()) .And. ZIF->ZIF_FILIAL == FWxFilial("ZIF") .And. ZIF->ZIF_CTPATI == cCP

        cNvPed   := ""

        cPedGer  := getPedSa(ZIF->ZIF_NUMERO) 
        If ! Empty(cPedGer)
            MsgInfo("Ordem de pesagem " + ZIF->ZIF_NUMERO + " está vinculada ao(s) pedido(s) " + cPedGer + ".", "Função gerPedS(ADFAT017P)")
            ZIF->(DbSkip())
            Loop

        EndIf
    
        //Posiciona no registro de ticket de pesagem pela ordem de pesagem.
        If ! U_ADFAT196(ZIF->ZIF_NUMERO) //Localiza ticket de pesagem.
            ZIF->(DbSkip())
            Loop

        EndIf

        //Valida status do ticket (encerrado/pesagem sequestrada liberada) de pesagem e ordem de pesagem (encerrada).
        If ! (ZIG->ZIG_INICIA $"3/5") .Or. Alltrim(cValToChar(ZIF->ZIF_STATUS)) <> "5"
            ZIF->(DbSkip())
            Loop

        EndIf

        DbSelectArea("ZI8")
        ZI8->(DbSetOrder(1))
        ZI8->(DbGoTop())
        If ! ZI8->( DbSeek( FWxFilial("ZI8") + ZIF->ZIF_LOTE))
            MsgInfo("Lote " + ZIF->ZIF_LOTE + " não localizado.", "Função gerPedS(ADFAT017P)")
            ZIF->(DbSkip())
            Loop

        EndIf       

        DbSelectArea("ZV4")
        ZV4->(DbSetOrder(1))
        ZV4->(DbGoTop())
        If ! ZV4->( DbSeek( FWxFilial("ZV4") + ZIF->ZIF_PLACA))
            MsgInfo("Veículo " + ZIF->ZIF_PLACA + " não localizado.", "Função gerPedS(ADFAT017P)")
            ZIF->(DbSkip())
            Loop

        EndIf

        If ! U_ADFAT32G(ZIF->ZIF_ORDRAC)
            MsgInfo("Ordem de carregamento de ração " + ZIF->ZIF_ORDRAC + " não localizada.", "Função gerPedS(ADFAT017P)")
            ZIF->(DbSkip())
            Loop

        EndIf

        DbSelectArea("ZIS")
        ZIS->(DbSetOrder(1))
        ZIS->(DbGoTop())
        If ! ZIS->( DbSeek( FWxFilial("ZIS") + ZIR->ZIR_CODGRJ ))
            MsgInfo("Granjada " + ZIR->ZIR_CODGRJ + " não localizada.", "Função gerPedS(ADFAT017P)")
            ZIF->(DbSkip())
            Loop

        EndIf

        If ! U_ADFAT15B(ZIB->ZIB_CODROT)
            MsgInfo("Roteiro de pesagem " +  ZIB->ZIB_CODROT + " não localizado.", "Função gerPedS(ADFAT017P)")
            ZIF->(DbSkip())
            Loop

        EndIf      

        DbSelectArea("ZIA")
        ZIA->(DbSetOrder(2))
        ZIA->(DbGoTop())
        If ! ZIA->( DbSeek( FWxFilial("ZIA") + ZIB->ZIB_CODROT + ZIF->ZIF_PRDSAG))
            MsgInfo("Item do roteiro de pesagem " +  ZIB->ZIB_CODROT + " " + ZIF->ZIF_PRDSAG + " não localizado.", "Função gerPedS(ADFAT017P)")
            ZIF->(DbSkip())
            Loop

        EndIf      

        If ! getInfo(ZIF->ZIF_CLIFOR, @aCampo, @cTpPed, ZIF->ZIF_FORNEC, ZIF->ZIF_LJFORN)
            ZIF->(DbSkip())
            Loop

        EndIf

        cNmOrdem := ZIF->ZIF_NUMERO
        cFornece := ZIF->ZIF_FORNEC
        cLjForn  := ZIF->ZIF_LJFORN
        cGranja  := ZIS->ZIS_GRANJA
        cGranjada:= ZIS->ZIS_GRAJDA
        cMemNf2  := "Granja.: " + ZIS->ZIS_DESC
        cTpFrt   := "C"
        cPlaca   := ZIF->ZIF_PLACA
        cUFPlaca := ""

        cUFPlaca := ZV4->ZV4_EST
        cTransp  := ZV4->ZV4_FORNEC
        cProduto := ZIF->ZIF_PRDPRO
        
        nVlrUnit := Round(ZI8->ZI8_LTCUST + ZI9->ZI9_CUSTAD,TamSX3("C6_PRCVEN")[2]) // Custo do lote do produto + Custo adicional.
        nPesoLiq := Round(ZIG->ZIG_PESOLI, TamSX3("C6_QTDVEN")[2])
        nTotal   := Round(nPesoLiq * nVlrUnit, TamSX3("C6_VALOR")[2])
        cTes     := Iif(Alltrim(cValToChar(aCampo[2,2])) == "SP", ZI9->ZI9_TESEST, ZI9->ZI9_TESINT) //Pega Tes do cabeçalho do roteiro.

        DbSelectArea("ZIU")
        ZIU->(DbSetOrder(3))
        ZIU->(DbGoTop())
        If ZIU->( DbSeek( FWxFilial("ZIU") + ZIA->ZIA_CODROT + ZIF->ZIF_CLIFOR + cFornece + cLjForn )) //Verifica se tem cadastro de exceção de tes por fornecedor / cliente.
            cTes := ZIU->ZIU_TES

        Else

            //Pega Tes do cadastro do item do roteiro de pesagem.
            If Alltrim(cValToChar(aCampo[2,2])) == "SP" .And. ! Empty(ZIA->ZIA_TESEST)
                cTes := ZIA->ZIA_TESEST

            ElseIf  Alltrim(cValToChar(aCampo[2,2])) <> "SP" .And. ! Empty(ZIA->ZIA_TESINT)
                cTes := ZIA->ZIA_TESINT

            EndIf

        EndIf        

        If ! RetArqProd(cProduto)
            cLocPad := Posicione("SBZ",1, FWxFilial("SBZ") + cProduto, "BZ_LOCPAD")
            
        Else
            cLocPad := Posicione("SB1",1, FWxFilial("SB1") + cProduto, "B1_LOCPAD")
    
        EndIf

        Begin Transaction

            //Gera pedido de saída.
            cNvPed := ""
            MsAguarde({|| lRetPed := U_ADFAT17N(@cNvPed, cTpPed, cFornece, cLjForn, aCampo, cMemNf2, cGranja, cGranjada, cTpFrt,;
                        cPlaca, cTransp, cUFPlaca, nPesoLiq, cProduto, nVlrUnit, nTotal, cTes, cLocPad, cNmOrdem, "", .F., @cMsgError) },;
                        "Função gerPedS(ADFAT017P)", "Gerando pedido - OP " + ZIF->ZIF_NUMERO + "", .F.)

            //Valida se o pedido foi gerado.
            If ! lRetPed
                cNvPed := ""
                cPedidos := ""
                DisarmTransaction()
                Break

            End

            //Adicionada o pedido à variável para exibição na mensagem final.
            cPedidos += cNvPed + xPula
            
            //Gera pedidos adicionais.
            MsAguarde({|| lRetPed := pedAdic(cTpMovi, @cPedidos, cNmOrdem, cTpPed, cFornece, cLjForn, ZIF->ZIF_CLIFOR, aCampo, cMemNf2, cGranja, cGranjada, cTpFrt,;
                        cPlaca, cTransp, cUFPlaca, nPesoLiq, cProduto, nVlrUnit, nTotal, cTes, cLocPad, cNmOrdem, cNvPed, @cUUids, @cMsgError;
                        ) }, "Função gerPedS(ADFAT017P)", "Checando pedidos adicionais - OP " + ZIF->ZIF_NUMERO + "", .F.)

            //Valida retorno dos pedidos adicionais.
            If !lRetPed
                cPedidos := ""
                DisarmTransaction()
                Break

            EndIf

        End Transaction

        ZIF->(DbSkip())

    End

    If InTransact() .Or. FwInTTSBreak()
		MsgStop("Sistema está em transação ou TTSBreak - abortando operação.","Função gerPedS(ADFAT017P)")
		Final()

	EndIf

    If Empty(cPedidos)
        cPedidos := "Não há pedidos gerados."

    EndIF

    U_TExTelaMen("Geração de Pedido de Saída", "Pedidos gerados: " + xPula + cPedidos + xPula + xPula + "Erro: " + xPula + cMsgError, "Arial",10,,.F.,.F.)
    
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} getInfo
    Obtém informações de cliente e fornecedor.
    @type  Static Function
    @author Everson
    @since 11/03/2022
    @version 01
/*/
Static Function getInfo(cCliFor, aCampo, cTpPed, cCodCF, cLoja)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.

    DbSelectArea("SA1")
    SA1->(DbSetOrder(1))
    SA1->(DbGoTop())

    DbSelectArea("SA2")
    SA2->(DbSetOrder(1))
    SA2->(DbGoTop())

    If cCliFor == "C"

        If ! SA1->( DbSeek( FWxFilial("SA1") + cCodCF + cLoja))
            MsgInfo("Cliente " + cCodCF + cLoja + " não localizado.", "Função gerPedS(ADFAT017P)")

        Else
            lRet := .T.
            aCampo  := {{"A1_END", SA1->A1_END}, {"A1_EST", SA1->A1_EST}, {"A1_BAIRRO", SA1->A1_BAIRRO}, {"A1_CIDADE", SA1->A1_Mun}, {"A1_COND", SA1->A1_COND}}
            cTpPed  := "N"

        EndIf

    Else

        If ! SA2->( DbSeek( FWxFilial("SA2") + cCodCF + cLoja))
            MsgInfo("Fornecedor " + cCodCF + cLoja + " não localizado.", "Função gerPedS(ADFAT017P)")

        Else
            lRet := .T.
            aCampo  := {{"A2_END", SA2->A2_END}, {"A2_EST", SA2->A2_EST}, {"A2_BAIRRO", SA2->A2_BAIRRO}, {"A2_CIDADE", SA2->A2_Mun}, {"A2_COND", SA2->A2_COND},  {"A2_COND", SA2->A2_COND}}
            cTpPed  := "B"

        EndIf

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT17N
    Gera pedido SC5.
    @type  User Function
    @author Everson
    @since 10/03/2022
    @version 01
/*/
User Function ADFAT17N(cNvPed, cTpPed, cFornece, cLjForn, aCampo, cMemNf2, cGranja, cGranjada, cTpFrt,;
                       cPlaca, cTransp, cUFPlaca, nPesoLiq, cProduto, nVlrUnit, nTotal, cTes, cLocPad, cNmOrdem, cTabGene, lPedSag, cMsgError)

    //Variáveis.
    Local aArea  := GetArea()
    Local lRet   := .F.
    Local aCabec := {}
    Local aLinha := {}
    Local aItens := {}

    Private lMsErroAuto    := .F.
    Private lMsHelpAuto    := .T.
    Private lAutoErrNoFile := .F.

    Default cMsgError := ""
    Default lPedSag   := .F.

    Aadd( aCabec, { "C5_TIPO"	  , cTpPed, Nil } )
    Aadd( aCabec, { "C5_CLIENTE"  , cFornece, Nil } )
    Aadd( aCabec, { "C5_LOJACLI"  , cLjForn, Nil } )
    Aadd( aCabec, { "C5_LOJAENT"  , cLjForn, Nil } )
    Aadd( aCabec, { "C5_CONDPAG"  , aCampo[5,2], Nil } )
    Aadd( aCabec, { "C5_ENDERE"   , aCampo[1,2], Nil } )
    Aadd( aCabec, { "C5_EST"      , aCampo[2,2], Nil } )
    Aadd( aCabec, { "C5_BAIRRO"   , aCampo[3,2], Nil } )
    Aadd( aCabec, { "C5_CIDADE"   , aCampo[4,2], Nil } )
    Aadd( aCabec, { "C5_DTENTR"   , Date() + 7 , Nil } )
    Aadd( aCabec, { "C5_EMISSAO"  , Date()   , Nil } )
    Aadd( aCabec, { "C5_MENNOT2"  , cMemNf2  , Nil } )
    Aadd( aCabec, { "C5_GRANJA"   , cGranja  , Nil } )
    Aadd( aCabec, { "C5_GRANJDA"  , cGranjada, Nil} )

    Aadd( aCabec, { "C5_TPFRETE"  , cTpFrt  , .F. } )
    Aadd( aCabec, { "C5_FRETE"    , 0       , .F. } )
    Aadd( aCabec, { "C5_PLACA"    , cPlaca  , .F. } )
    Aadd( aCabec, { "C5_TRANSP"   , cTransp , .F. } )
    Aadd( aCabec, { "C5_UFPLACA"  , cUFPlaca, .F. } )
    Aadd( aCabec, { "C5_PESOL"    , nPesoLiq, Nil } )
    Aadd( aCabec, { "C5_PESOTOT"  , nPesoLiq, Nil } )
    Aadd( aCabec, { "C5_XORDPES"  , cNmOrdem, .F. } )
    Aadd( aCabec, { "C5_TABEGEN"  , cTabGene, .F. } )

    If lPedSag
        Aadd( aCabec, { "C5_PEDSAG"   , "INTPROT", .F. } )

    EndIf

    //Item.
    Aadd( aLinha, { "C6_ITEM"	 , "001"	, Nil } )
    Aadd( aLinha, { "C6_PRODUTO" , cProduto	, Nil } )
    Aadd( aLinha, { "C6_UNSVEN"	 , nPesoLiq	,0 , Nil } )
    Aadd( aLinha, { "C6_PRCVEN"	 , nVlrUnit	,0 , Nil } )
    Aadd( aLinha, { "C6_VALOR"	 , nTotal	,0 , Nil } )
    Aadd( aLinha, { "C6_TES"	 , cTes	    ,.F. } )
    Aadd( aLinha, { "C6_LOCAL"	 , cLocPad  , Nil } )
    Aadd( aLinha, { "C6_PRUNIT"	 , nVlrUnit	,0 , Nil } )

    //Itens.
    Aadd(aItens, aLinha)

    MSExecAuto( { |x, y, z, p| MATA410(x, y, z,,,,,,, p) }, aCabec, aItens, 3 )

    If lMsErroAuto
        cMsgError := MostraErro() 

    Else
        cNvPed := SC5->C5_NUM
        lRet := .T.

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} pedAdic
    Gera pedidos adicionais a serem gerados.
    @type  Static Function
    @author Everson
    @since 11/03/2022
    @version 01
/*/
Static Function pedAdic(cTpMovi, cPedidos, cNmOrdem, cTpPed, cFornece, cLjForn, cCliFor, aCampo, cMemNf2, cGranja, cGranjada, cTpFrt,;
                        cPlaca, cTransp, cUFPlaca, nPesoLiq, cProduto, nVlrUnit, nTotal, cTes, cLocPad, cNmOrdem, cPedPrinc, cUUids,cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .T.
    Local cNvPed    := ""
    Local cNvTes    := ""
    Local cNVTpPed  := ""
    Local cNvForn   := ""
    Local cNvLjForn := ""
    Local cNvTpFrt  := ""
    Local cId       := ""
    Local cDados    := ""
    Local oJson     := Nil
 
    Default cMsgError := ""

    DbSelectArea("ZIJ")
    ZIJ->(DbSetOrder(4))
    If ! ZIJ->( DbSeek( FWxFilial("ZIJ") + cTes + cTpMovi))
        RestArea(aArea)
        Return .T.

    EndIf

    While ! ZIJ->(Eof()) .And. ZIJ->ZIJ_FILIAL == FWxFilial("ZIJ") .And. ZIJ->ZIJ_CONDIC == cTes

        cNvPed := ""

        If ZIJ->ZIJ_TIPOPR == "D"
            cNvTes    := ZIJ->ZIJ_TES
            cNVTpPed  := Iif(ZIJ->ZIJ_CLIFOR == "C", "N", "B")
            cNvForn   := ZIJ->ZIJ_COD
            cNvLjForn := ZIJ->ZIJ_LOJA
            cNvTpFrt  := ZIJ->ZIJ_FRETE

        ElseIf ZIJ->ZIJ_TIPOPR == "M" .And. ZIJ->ZIJ_COD == cFornece .And. ZIJ->ZIJ_LOJA == cLjForn
            cNvTes    := ZIJ->ZIJ_TES
            cNVTpPed  := Iif(cCliFor == "C", "N", "B")
            cNvForn   := cFornece
            cNvLjForn := cLjForn
            cNvTpFrt  := ZIJ->ZIJ_FRETE

        Else
            ZIJ->(DbSkip())
            Loop

        EndIf

        If ! getInfo(ZIJ->ZIJ_CLIFOR, @aCampo, @cTpPed, cNvForn, cNvLjForn)
            lRet := .F.
            Exit

        EndIf

        If ZIJ->ZIJ_FILAPL == FWxFilial("ZIJ")
        

            lRet := U_ADFAT17N(@cNvPed, cNVTpPed, cNvForn, cNvLjForn, aCampo, cMemNf2, "", "", cNvTpFrt,;
                            cPlaca, cTransp, cUFPlaca, nPesoLiq, cProduto, nVlrUnit, nTotal, cNvTes, cLocPad, cNmOrdem, "", .F., @cMsgError)

        Else
            
            cId := FWUUIDV1(.T.)
            oJson := JsonObject():New()

            oJson['EmpDes']     := cEmpAnt      
            oJson['filDes']     := ZIJ->ZIJ_FILAPL
            oJson['empOri']     := cEmpAnt
            oJson['filOr']      := FWxFilial("ZIJ")
            oJson['tpPed']      := cNVTpPed
            oJson['forne']      := cNvForn
            oJson['loja']       := cNvLjForn
            oJson['ddForn']     := aCampo
            oJson['msgNota']    := cMemNf2
            oJson['granja']     := cGranja
            oJson['grjada']     := cGranjada
            oJson['tipoFrt']    := cNvTpFrt
            oJson['placa']      := cPlaca
            oJson['pesLiq']     := nPesoLiq
            oJson['produto']    := cProduto
            oJson['vlrUnit']    := nVlrUnit
            oJson['vlrTotal']   := nTotal
            oJson['tes']        := cNvTes
            oJson['ordPes']     := cNmOrdem
            oJson['tabGene']    := "PO16MVES"
            oJson['pedPrinc']   := cPedPrinc

            cDados := oJson:toJson()
            FreeObj(oJson)
            oJson := Nil

            U_ADFAT27B("I", "pedidos_de_saida_entre_filiais_protheus", cId, cDados, DToS(Date()), Time(), "E", cEmpAnt + cFilAnt + cPedPrinc)

            If Empty(cUUids)
                cUUids += "'" + cId + "'"

            Else
                cUUids += ",'" + cId + "'"

            EndIf

        EndIf

        If ! lRet
            Exit

        EndIf
        
        cPedidos += cNvPed + xPula

        ZIJ->(DbSkip())

    End

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT17M
    Inicia nova thread para gerar pedido em outra filial.
    @type  Static Function
    @author Everson
    @since 10/03/2022
    @version 01
/*/
User Function ADFAT17M(cEmpD, cFilD, cEmpO, cFilO, cTpPed, cFornece, cLjForn, aCampo, cMemNf2, cGranja, cGranjada, cTpFrt,;
                       cPlaca, nPesoLiq, cProduto, nVlrUnit, nTotal, cTes, cNmOrdem, cTabGene, lPedSAG)

    //Variáveis.
    Local lRet      := .F.
    Local cMsgError := ""
    Local cTransp   := ""
    Local cUFPlaca  := ""
    Local cLocPad   := ""
    Local cNvPed    := ""

    Default lPedSAG := .F.

	RPCSetType(3)
	RpcSetEnv(cEmpD, cFilD,,,,GetEnvServer(),{ })

        DbSelectArea("SC5")
        SC5->(DbSetOrder(28))
        SC5->(DbGoTop())
        If SC5->( DbSeek( FWxFilial("SC5") + cNmOrdem))

            If ! Empty(SC5->C5_PEDSAG)
                Return {.T., SC5->C5_NUM, ""}
                
            EndIf

        EndIf

        DbSelectArea("ZV4")
        ZV4->(DbSetOrder(1))
        ZV4->(DbSeek( FWxFilial("ZV4") + cPlaca ))
        cTransp  := ZV4->ZV4_FORNEC
        cUFPlaca := ZV4->ZV4_EST

        If ! RetArqProd(cProduto)
            cLocPad := Posicione("SBZ",1, FWxFilial("SBZ") + cProduto, "BZ_LOCPAD")
            
        Else
            cLocPad := Posicione("SB1",1, FWxFilial("SB1") + cProduto, "B1_LOCPAD")
    
        EndIf
        
        Sleep(Random(0, 3)*1000)

        lRet := U_ADFAT17N(@cNvPed, cTpPed, cFornece, cLjForn, aCampo, cMemNf2, cGranja, cGranjada, cTpFrt,;
                        cPlaca, cTransp, cUFPlaca, nPesoLiq, cProduto, nVlrUnit, nTotal, cTes, cLocPad, cNmOrdem, cTabGene, lPedSAG, @cMsgError)

        conout(lRet)

    RpcClearEnv()

Return {lRet, cNvPed, cMsgError}
/*/{Protheus.doc} ADFAT17G
    Retorna a cor de status da ordem de pesagem.
    @type  User Function
    @author Everson
    @since 18/11/2021
    @version 01
/*/
User Function ADFAT17G(cTpOrdem, cStatus)

    //Variáveis.
    Local aSituacao := U_ADFAT17H(cTpOrdem, cStatus)

Return aSituacao[1,3]
/*/{Protheus.doc} carVcPt
    Carga de dados na grid de veículos no controle de pátio.
    @type  Static Function
    @author Everson
    @since 18/11/2021
    @version 01
/*/
Static Function carVcPt(aStatCP, oVecPt, aHVcPt, cTagDev, dDtIni, dDtFim, cTpOP, cPlaca, cProduto)

    //Variáveis.
    Local cQuery   := ""
    Local oBranco  := LoadBitmap( GetResources(), "BR_BRANCO")
    Local oAzul    := LoadBitmap( GetResources(), "BR_AZUL")
    Local oLaranja := LoadBitmap( GetResources(), "BR_LARANJA")
    Local oVerde   := LoadBitmap( GetResources(), "BR_VERDE")
    Local oMarrom  := LoadBitmap( GetResources(), "BR_MARROM")
    Local oVermelho:= LoadBitmap( GetResources(), "BR_VERMELHO")
    Local nPStatCP := 0
    Local cProd    := ""

    cQuery += " SELECT * " 
    cQuery += " FROM  " 
    cQuery += " " + RetSqlName("ZIB") + " (NOLOCK) AS ZIB " 

    cQuery += " INNER JOIN " 
    cQuery += " " + RetSqlName("ZI9") + " (NOLOCK) AS ZI9 ON " 
    cQuery += " ZIB_FILIAL = ZI9_FILIAL "
    cQuery += " AND ZIB_CODROT = ZI9_CODROT "

    cQuery += " WHERE " 
    cQuery += " ZIB_FILIAL = '" + FWxFilial("ZIB") + "' " 

    If cTpOP <> "T"
        cQuery += " AND ZIB_TPMOVI = '" + cTpOP + "' " 

    EndIf

    If ! Empty(cPlaca)
        cQuery += " AND ZIB_PLACA LIKE '%" + cPlaca + "%' " 

    EndIf

    If cTagDev == "1"
        cQuery += " AND ZIB_STATUS <> '6' " 

    EndIf

    cQuery += " AND ZIB_DATA BETWEEN '" + DToS(dDtIni) + "' AND '" + DToS(dDtFim) + "' " 
    cQuery += " AND ZIB.D_E_L_E_T_ = '' " 
    cQuery += " AND ZI9.D_E_L_E_T_ = '' " 

    If Select("D_VEIC") > 0
        D_VEIC->(DbCloseArea())

    EndIf

    oVecPt:aCols := {}

    TcQuery cQuery New Alias "D_VEIC"
    DbSelectArea("D_VEIC")
    D_VEIC->(DbGoTop())
    While ! D_VEIC->(Eof())

        cProd := getDesPrd(D_VEIC->ZIB_NUMERO)
        
        If ! Empty(cProduto) .And. !( Upper(Alltrim(cValToChar(cProduto))) $Upper(cProd) )
            D_VEIC->(DbSkip())
            Loop

        EndIf
    	
        Aadd(oVecPt:aCols , Array(Len(aHVcPt) + 1) )
		oVecPt:aCols[Len(oVecPt:aCols), Len(oVecPt:aCols[1]) ] := .F.

        If Alltrim(cValToChar(D_VEIC->ZIB_STATUS)) == "1"
		    oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "LEG" })] := oBranco

        ElseIf Alltrim(cValToChar(D_VEIC->ZIB_STATUS)) == "2"
            oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "LEG" })] := oAzul

        ElseIf Alltrim(cValToChar(D_VEIC->ZIB_STATUS)) == "3"
            oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "LEG" })] := oLaranja

        ElseIf Alltrim(cValToChar(D_VEIC->ZIB_STATUS)) == "4"
            oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "LEG" })] := oVerde

        ElseIf Alltrim(cValToChar(D_VEIC->ZIB_STATUS)) == "5"
            oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "LEG" })] := oMarrom

        ElseIf Alltrim(cValToChar(D_VEIC->ZIB_STATUS)) == "6"
            oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "LEG" })] := oVermelho

        EndIf

        oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "NUMER" })] := D_VEIC->ZIB_NUMERO
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "CODROT" })] := D_VEIC->ZIB_CODROT
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "OPERA" })] := D_VEIC->ZI9_ROTEIR
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "PLACA" })] := D_VEIC->ZIB_PLACA
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "PRODU" })] := getDesPrd(D_VEIC->ZIB_NUMERO)
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "ORDEM" })] := ""
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "DTHR"  })] := DToC(SToD(D_VEIC->ZIB_DATA)) + " " + D_VEIC->ZIB_HORA
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "TAG"   })] := Iif(!Empty(Alltrim(cValtoChar(D_VEIC->ZIB_TAG))),"Sim","Não")
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "NTAG"  })] := D_VEIC->ZIB_TAG
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "TPMOV" })] := D_VEIC->ZIB_TPMOVI
        
        nPStatCP := AScan(aStatCP, {|x| Alltrim(cValToChar(x[2])) == Alltrim(cValToChar(D_VEIC->ZIB_STATUS)) })
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "SITUA" })] := aStatCP[nPStatCP,3]
		
        oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "MOTO"  })] := Alltrim(D_VEIC->ZIB_MOTORI) + " " + Posicione("ZVC",1, FWxFilial("ZVC") + ZIB->ZIB_MOTORI ,"ZVC_MOTORI")

        D_VEIC->(DbSkip())

    End

    D_VEIC->(DbCloseArea())

    If Len(oVecPt:aCols) == 0
		Aadd(oVecPt:aCols , Array(Len(aHVcPt) + 1) )
		oVecPt:aCols[Len(oVecPt:aCols), Len(oVecPt:aCols[1]) ] := .F.
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "PLACA" })] := ""

	EndIf

    oVecPt:Refresh()

Return Nil
/*/{Protheus.doc} getDesPrd
    Retorna string com descrição/código de produtos da carga.
    @type  Static Function
    @author Everson
    @since 25/11/2021
    @version 01
/*/
Static Function getDesPrd(cCP)

    //Variáveis.
    Local cDescPrd  := ""
    Local cQuery    := ""

    cQuery += " SELECT  " 
        cQuery += " ZIM_DESSAG, B1_DESC " 
    cQuery += " FROM " 
        cQuery += " " + RetSqlName("ZIF") + " (NOLOCK) AS ZIF " 
        cQuery += " LEFT OUTER JOIN " 
        cQuery += " " + RetSqlName("ZIM") + " (NOLOCK) AS ZIM ON " 
        cQuery += " ZIF_PRDSAG = ZIM_PRDSAG " 
        cQuery += " AND ZIM.D_E_L_E_T_ = '' " 
        cQuery += " LEFT OUTER JOIN "
        cQuery += " " + RetSqlName("SB1") + " (NOLOCK) SB1 ON "
        cQuery += " ZIM_PRDPRO = B1_COD "
        cQuery += " AND SB1.D_E_L_E_T_ = '' "
    cQuery += " WHERE " 
        cQuery += " ZIF_FILIAL = '" + FWxFilial("ZIF") + "' " 
        cQuery += " AND ZIF_CTPATI = '" + cCP + "' " 
        cQuery += " AND ZIF.D_E_L_E_T_ = '' " 

    If Select("D_PRD") > 0
        D_PRD->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_PRD"
    DbSelectArea("D_PRD")
    While ! D_PRD->(Eof())

        If ! Empty(Alltrim(cValToChar(D_PRD->ZIM_DESSAG))) .And. !(Alltrim(cValToChar(D_PRD->ZIM_DESSAG)) $cDescPrd)

            If Empty(cDescPrd)
                cDescPrd += Alltrim(cValToChar(D_PRD->ZIM_DESSAG))

            Else
                cDescPrd += ", " + Alltrim(cValToChar(D_PRD->ZIM_DESSAG))

            EndIf

        EndIf

        D_PRD->(DbSkip())

    End
    D_PRD->(DbCloseArea())

Return cDescPrd
/*/{Protheus.doc} addVeic
    Incluir registro de veículo no controle de pátio.
    @type  Static Function
    @author Everson
    @since 18/11/2021
    @version 01
/*/
Static Function addVeic()

    FWExecView("Incluir Controle de Pátio", "ADFAT017P", 3)
    
Return Nil
/*/{Protheus.doc} altCP
    Altera registro de veículo no controle de pátio.
    @type  Static Function
    @author Everson
    @since 15/12/2021
    @version 01
/*/
Static Function altCP(oVecPt, aHVcPt)

    //Variáveis.
    Local aArea    := GetArea()
    Local nLinha   := Val(cValToChar(oVecPt:nAt))
    Local cCP      := ""
    Local cNmOrdem := ""

    If nLinha <= 0 .Or. Len(aHVcPt) <= 0
        Help(Nil, Nil, "Função altCP(ADFAT017P)", Nil, "Não há dados.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    cCP := Alltrim(cValToChar(oVecPt:aCols[nLinha][aScan(aHVcPt,{|x| Alltrim(cValToChar(x[2])) == "NUMER"})]))
    If Empty(cCP)
        Help(Nil, Nil, "Função altCP(ADFAT017P)", Nil, "Controle de pátio não selecionado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    cNmOrdem := Alltrim(cValToChar(Posicione("ZIF", 1, FWxFilial("ZIF") + cCP, "ZIF_NUMERO")))

    If ! FWIsAdmin() .And. ! Empty(cNmOrdem)
        Help(Nil, Nil, "Função altCP(ADFAT017P)", Nil, "Controle de pátio " + cCP +" está vinculado à ordem de pesagem " + cNmOrdem + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    //Posiciona no registro de pátio selecionado.
    If ! U_ADFAT17U(cCP)
        Help(Nil, Nil, "Função altCP(ADFAT017P)", Nil, "Controle de pátio " + cCP + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    FWExecView("Alterar Controle de Pátio", "ADFAT017P", 4)

    RestArea(aArea)
    
Return Nil
/*/{Protheus.doc} carOrdens
    Carrega gride de ordens de pesagem.
    @type  Static Function
    @author Everson
    @since 18/11/2021
    @version 01
/*/
Static Function carOrdens(nLinha, oVecPt, aHVcPt, oOrdPes, aOrdPes, cTpOP, aTpOrdem, aStatLb, aTpSeq, dDtIni, dDtFim)

    //Variáveis.
    Local aArea	    := GetArea()
    Local cCP       := Alltrim(cValToChar(oVecPt:aCols[nLinha][aScan(aHVcPt,{|x| Alltrim(cValToChar(x[2])) == "NUMER"})]))
    Local cPlaca    := Alltrim(cValToChar(oVecPt:aCols[nLinha][aScan(aHVcPt,{|x| Alltrim(cValToChar(x[2])) == "PLACA"})]))
    Local cTpMovi   := Alltrim(cValToChar(oVecPt:aCols[nLinha][aScan(aHVcPt,{|x| Alltrim(cValToChar(x[2])) == "TPMOV"})]))
    Local cQuery    := ""
    Local cQryT3    := GetNextAlias()
    Local cForn     := ""
    Local cProd     := ""
    Local nPTpOrd   := 0
    Local nStatLab  := 0
    Local cAgrupada := ""
    Local aSituacao := ""
    Local cTktGua   := ""
    Local cTicket   := ""
    Local cSeqTkt   := ""
    Local cSPesManu := ""
    Local nQtdAgr   := 0
    Local cNmLote   := ""
    Local nPosTpSeq := 0
    Local cDesTpSe  := ""
    Local cPedSaida := ""
    Local cNF       := ""

    //Verifica se há ordem de pesagem de ração para ser gerada.
    If cTpMovi == "R" .And. ! Empty(cCP) .And. ! Empty(cPlaca)
        U_ADFAT17A(cCP, cPlaca)

    EndIf

    //Verifica se há ordem de saída para ser excluída.
    U_ADFAT17Q()

    //Verifica se há ordem de saída para ser gerada.
    If cTpMovi == "S" .And. ! Empty(cCP) .And. ! Empty(cPlaca)
        U_ADFAT17O(cCP, cPlaca)

    EndIf
    
    aOrdPes:= {}
    
    cQuery += " SELECT  " 
    cQuery += " *  " 
    cQuery += " FROM  " 
    cQuery += " " + RetSqlName("ZIF") + " (NOLOCK) AS ZIF " 

    cQuery += " INNER JOIN "
    cQuery += " " + RetSqlName("ZIB") + "  (NOLOCK) AS ZIB ON "
    cQuery += " ZIF_FILIAL = ZIB_FILIAL "
    cQuery += " AND ZIF_CTPATI = ZIB_NUMERO "

    cQuery += " LEFT OUTER JOIN "
    cQuery += " " + RetSqlName("ZIG") + " (NOLOCK) AS ZIG ON "
    cQuery += " ZIF_FILIAL = ZIG_FILIAL "
    cQuery += " AND ZIF_NUMERO = ZIG_ORDEM "
    cQuery += " AND ZIG.D_E_L_E_T_ = '' "

    cQuery += " WHERE " 
    cQuery += " ZIF_FILIAL = '" + FWxFilial("ZIF") + "' " 
    cQuery += " AND ZIF_CTPATI = '" + cCP + "' "

    cQuery += " AND ZIF_DATA BETWEEN '" + DToS(dDtIni) + "' AND '" + DToS(dDtFim) + "' " 
    cQuery += " AND ZIF.D_E_L_E_T_ = '' " 
    cQuery += " AND ZIB.D_E_L_E_T_ = '' "

    DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryT3, .T., .F. )
    
    (cQryT3)->(DbGoTop())
    While (cQryT3)->(!EOF())

        cForn     := (cQryT3)->ZIF_FORNEC + " " + (cQryT3)->ZIF_LJFORN + " " + (cQryT3)->ZIF_NMFOR
        cProd     := U_ADFAT176((cQryT3)->ZIF_PRDSAG, (cQryT3)->ZIF_PRDPRO)
        nPTpOrd   := AScan(aTpOrdem, {|x| Alltrim(cValToChar(x[2])) == Alltrim(cValToChar((cQryT3)->ZIF_TPMOVI))})
        nStatLab  := AScan(aStatLb, {|x| Alltrim(cValToChar(x[2]))  == Alltrim(cValToChar((cQryT3)->ZIF_STATLA))})
        cAgrupada := Iif(Alltrim(cValToChar((cQryT3)->ZIF_EAGRUP))  == "1","Sim", Iif(Alltrim(cValToChar((cQryT3)->ZIF_EAGRUP))  == "2","Não",""))
        aSituacao := U_ADFAT17H((cQryT3)->ZIF_TPMOVI, Alltrim(cValToChar((cQryT3)->ZIF_STATUS)), (cQryT3)->ZIG_TPSEQU)

        nPosTpSeq:= 0
        cDesTpSe := ""
        If (cQryT3)->ZIG_TPSEQU <> "0"
            nPosTpSeq := AScan(aTpSeq, {|x| Alltrim(cValToChar(x[2]))  == Alltrim(cValToChar((cQryT3)->ZIG_TPSEQU))})
            cDesTpSe  := " - " + aTpSeq[nPosTpSeq,3]

        EndIf
            
        cTktGua   := ""
        cTicket   := ""
        cSeqTkt   := ""
        nQtdAgr   := 0
        
        If ! Empty(Alltrim(cValToChar((cQryT3)->ZIF_AGRUPA)))
            cTktGua  := Posicione("ZIG", 2, FWxFilial("ZIG") + (cQryT3)->ZIF_AGRUPA ,"ZIG_NUMGUA")
            cTicket  := Posicione("ZIG", 2, FWxFilial("ZIG") + (cQryT3)->ZIF_AGRUPA ,"ZIG_NUMERO")
            cSeqTkt  := Posicione("ZIG", 2, FWxFilial("ZIG") + (cQryT3)->ZIF_AGRUPA ,"ZIG_SEQTKT")
            nQtdAgr  := getPesToOr((cQryT3)->ZIF_NUMERO)

        Else
            cTktGua  := (cQryT3)->ZIG_NUMGUA
            cTicket  := (cQryT3)->ZIG_NUMERO
            cSeqTkt  := (cQryT3)->ZIG_SEQTKT

        EndIf

        cSPesManu := Posicione("ZIK",2, FWxFilial("ZIK") + cTicket ,"ZIK_NUMERO")

        cNmLote   := Posicione("ZI8",1, FWxFilial("ZI8") + (cQryT3)->ZIF_LOTE ,"ZI8_DESLOT")

        cPedSaida := getPedSa((cQryT3)->ZIF_NUMERO)

        cNF       := getNF(cPedSaida)

        Aadd(aOrdPes,{;
            .F.,;                   //01-Marca browse.
            aTpOrdem[nPTpOrd,3],;   //02-Descrição tp Ordem.
            cForn,;                 //03-Fornecedor.
            cProd,;                 //04-Produto.
            (cQryT3)->ZIF_LOTE,;    //05-Lote.
            (cQryT3)->ZIF_QUANT,;   //06-Quantidade.
            aStatLb[nStatLab,3],;   //07-Laboratório.
            (cQryT3)->ZIF_NUMERO,;  //08-Ordem.
            cAgrupada,;             //09-Agrupada.
            cTktGua,;               //10-Ticket Guardian.
            cTicket,;               //11-Ticket.
            aSituacao[1,2] + cDesTpSe,;        //12-Situação.
            cSeqTkt,;               //13-Seq.
            (cQryT3)->ZIF_TPMOVI,;  //14-Tp Ordem.
            (cQryT3)->ZIF_CLIFOR,;  //15-C=Cliente/F=Fornecedor.
            (cQryT3)->ZIF_CTPATI,;  //16-Controle de pátio.
            aSituacao[1,1],;        //17-Código do status.
            (cQryT3)->ZIF_AGRUPA,;  //18-Ordem agrupadora.
            (cQryT3)->ZIF_PLACA,;   //19-Placa.
            cSPesManu,;             //20-Pesagem manual.
            (cQryT3)->ZIF_PRDSAG,;  //21-Código produto SAG.
            (cQryT3)->ZIF_PRDPRO,;  //22-Código produto Protheus.
            (cQryT3)->ZIF_STATUS,;  //23-Status da ordem de pesagem.
            nQtdAgr,;               //24-Quantidade agrupador.
            cNmLote,;               //25-Nome do lote.
            cPedSaida,;             //26-Pedido de saída (SC5).
            (cQryT3)->ZIG_PESINI,;  //27-Peso inicial.
            (cQryT3)->ZIG_PESFIM,;  //28-Peso final.
            (cQryT3)->ZIG_PESOLI,;  //29-Peso liquido.
            cNF;                    //30-Peso liquido.
        })
    
        (cQryT3)->(dbSkip())

    End

    (cQryT3)->(dbCloseArea())

    oOrdPes:setArray(aOrdPes)
    oOrdPes:Refresh()

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} carOrdens
    Carrega gride de ordens de pesagem.
    @type  Static Function
    @author Everson
    @since 18/11/2021
    @version 01
/*/
Static Function geraOrd(nLinha, oVecPt, aHVcPt, oOrdPes, aOrdPes, cTpOP, aTpOrdem, aStatLb, aTpSeq, dDtIni, dDtFim)

    //Variáveis.
    Local aArea     := GetArea()
    // Local cCP       := Alltrim(cValToChar(oVecPt:aCols[nLinha][aScan(aHVcPt,{|x| Alltrim(cValToChar(x[2])) == "NUMER"})]))
    // Local cPlaca    := Alltrim(cValToChar(oVecPt:aCols[nLinha][aScan(aHVcPt,{|x| Alltrim(cValToChar(x[2])) == "PLACA"})]))
    // Local cTpMovi   := Alltrim(cValToChar(oVecPt:aCols[nLinha][aScan(aHVcPt,{|x| Alltrim(cValToChar(x[2])) == "TPMOV"})]))

    //Verifica se há ordem de pesagem de ração para ser gerada.
    // If cTpMovi == "R" .And. ! Empty(cCP) .And. ! Empty(cPlaca)
    //     U_ADFAT17A(cCP, cPlaca)

    // EndIf

    //Verifica se há ordem de saída para ser gerada.
    // If cTpMovi == "S" .And. ! Empty(cCP) .And. ! Empty(cPlaca)
    //     U_ADFAT17O(cCP, cPlaca)

    // EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} getPedSa
    Obtém pedidos de saída vinculados a ordem de pesagem.
    @type  Static Function
    @author Everson
    @since 14/03/2022
    @version 01
/*/
Static Function getPedSa(cNmOrdem)

    //Variáveis.
    Local aArea     := GetArea()
    Local cPedidos  := ""

    DbSelectArea("SC5")
    SC5->(DbSetOrder(28))
    If SC5->( DbSeek( FWxFilial("SC5") + cNmOrdem))

        While ! SC5->(Eof()) .And. SC5->C5_FILIAL == FWxFilial("SC5") .And. SC5->C5_XORDPES == cNmOrdem 
        
            If Empty(SC5->C5_PEDSAG)

                cPedidos += SC5->C5_NUM + ", "

            EndIf

            SC5->(DbSkip())

        End

    EndIf

    If Empty(cPedidos)

        DbSelectArea("SC6")
        SC6->(DbSetOrder(17))
        SC6->(DbGoTop())

        If SC6->(DbSeek( FWxFilial("SC6") + cNmOrdem ))

            While ! SC6->(Eof()) .And. SC6->C6_FILIAL == FWxFilial("SC6") .And. SC6->C6_XORDPES == cNmOrdem

                If ! ( SC6->C6_NUM $cPedidos)
                    cPedidos += SC6->C6_NUM + ", "

                EndIf

                SC6->(DbSkip())

            End

        EndIf

    EndIf

    RestArea(aArea)

Return cPedidos
/*/{Protheus.doc} getNF
    Obtém notas de saída.
    @type  Static Function
    @author Everson
    @since 19/05/2022
    @version 01
/*/
Static Function getNF(cPedSaida)

    //Variáveis.
    Local aArea    := GetArea()
    Local cNF      := ""
    Local aPedidos := {}
    Local cPed     := ""
    Local nAux     := 1
    Local cQuery   := ""

    If Empty(cPedSaida)
        Return ""

    EndIf

    aPedidos := Separa(cPedSaida, ",", .F.)

    For nAux := 1 To Len(aPedidos)

        If Empty(aPedidos[nAux])
            Loop

        EndIf

        If Empty(cPed)
            cPed += "'" + cValToChar(Alltrim(aPedidos[nAux])) + "'"
        Else
            cPed += ",'" + cValToChar(Alltrim(aPedidos[nAux])) + "'"

        EndIf

    Next nAux

    cQuery := ""
    cQuery += " SELECT " 
    cQuery += " C5_NOTA + '-' + C5_SERIE AS NOTA " 
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
    cQuery += " WHERE " 
    cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "' " 
    cQuery += " AND C5_NUM IN (" + cPed + ") " 
    cQuery += " AND C5_NOTA <> '' " 
    cQuery += " AND SC5.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY C5_NOTA " 

    If Select("D_DNFS")
        D_DNFS->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_DNFS"
    DbSelectArea("D_DNFS")
    D_DNFS->(DbGoTop())
    While ! D_DNFS->(Eof())

        cNF += Alltrim(cValToChar(D_DNFS->NOTA)) + ", "

        D_DNFS->(DbSkip())

    End
    D_DNFS->(DbCloseArea())

    RestArea(aArea)

Return cNF
/*/{Protheus.doc} dfAgpOrd
    Define o agrupamento das ordens de pesagem.
    @type  Static Function
    @author Everson
    @since 24/11/2021
    @version 01
/*/
Static Function dfAgpOrd(oOrdPes, aOrdPes, aTpOrdem)

    //Variáveis.
    Local nLinha    := Val(cValToChar(oOrdPes:nAt))
    Local cNmOrdem  := ""
    Local oModal    := Nil
    Local oContainer:= Nil
    Local aButtons  := {}
    Local cCP       := ""
    Local oOrdPAgr  := Nil
    Local aOrdens   := {}
    // Local cTpOrdem  := ""
    Local lMarker   := .F.
    Local cTicket   := ""

    If nLinha <= 0 .Or. Len(aOrdPes) <= 0
        Help(Nil, Nil, "Função dfAgpOrd(ADFAT017P)", Nil, "Não há dados.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    cNmOrdem := aOrdPes[nLinha,08]
    If Empty(cNmOrdem)
        Help(Nil, Nil, "Função dfAgpOrd(ADFAT017P)", Nil, "Selecione uma ordem de pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    // cTpOrdem := aOrdPes[nLinha,14]
    // If cTpOrdem  $"O/R/S"
    //     Help(Nil, Nil, "Função dfAgpOrd(ADFAT017P)", Nil, "Esse tipo de ordem não pode ser agrupado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
    //     Return Nil

    // EndIf

    cCP := aOrdPes[nLinha,16]
    If Empty(cCP)
        Help(Nil, Nil, "Função dfAgpOrd(ADFAT017P)", Nil, "Controle de pátio não selecionado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    //Verifica se o controle de pátio está encerrado.
    If U_ADFAT17L(cCP)
        Help(Nil, Nil, "Função dfAgpOrd(ADFAT017P)", Nil, "Controle de pátio " + cCP + " encerrado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    cTicket := Alltrim(cValToChar(aOrdPes[nLinha,11]))
    If ! Empty(cTicket)
        Help(Nil, Nil, "Função dfAgpOrd(ADFAT017P)", Nil, "Ordem de pesagem está vinculada ao ticket de pesagem " + cTicket + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    carOrdAg(cCP, @aOrdens, aTpOrdem)
    
    If Len(aOrdens) <= 1
        U_ADFAT165(cNmOrdem, "ZIF_EAGRUP", "2")
        MsgInfo("Não há ordens de pesagens a serem agrupadas no controle de pátio " + cCP + ".","Função dfAgpOrd(ADFAT017P)")
        Return Nil

    EndIf

    oModal := FWDialogModal():New()        
	oModal:SetEscClose(.F.)
	oModal:setTitle("Agrupamento de Ordens de Pesagem - CP " + cCP)
	oModal:setSize(150, 350)
	oModal:createDialog()

    Aadd(aButtons,{Nil,"Confimar",{|| Iif(! prcAgrp(aOrdens), Nil, oModal:DeActivate()) },"","",.T.,.F.})
    Aadd(aButtons,{Nil,"Cancelar", {|| oModal:DeActivate() },"","",.T.,.F.})

	oModal:addButtons(aButtons)

        oContainer := TPanel():New(025,,, oModal:getPanelMain())
        oContainer:Align := CONTROL_ALIGN_ALLCLIENT

        oOrdPAgr := FwBrowse():New()
        oOrdPAgr:setOwner(oContainer)
        oOrdPAgr:setDataArray()
        oOrdPAgr:setArray(aOrdens)
        oOrdPAgr:disableConfig()
        oOrdPAgr:disableReport()
    
        oOrdPAgr:AddMarkColumns({|| Iif(aOrdens[oOrdPAgr:nAt,01], "LBOK", "LBNO")},;
                                {|| selecAgr(oOrdPAgr, @aOrdens)},;
                                {|| selecTAgr(oOrdPAgr, @aOrdens, @lMarker)})
    
        oOrdPAgr:addColumn({"Contr. Pátio" , {||aOrdens[oOrdPAgr:nAt,02]}, "C", "", 1, 006 , , .T. , , .F.,, "aOrdens[oOrdPes:nAt,02]",, .F., .T., , "ID02" })
        oOrdPAgr:addColumn({"Ordem"        , {||aOrdens[oOrdPAgr:nAt,03]}, "C", "", 1, 010 , , .T. , , .F.,, "aOrdens[oOrdPes:nAt,03]",, .F., .T., , "ID03" })
        oOrdPAgr:addColumn({"Agrupador"    , {||aOrdens[oOrdPAgr:nAt,06]}, "C", "", 1, 010 , , .T. , , .F.,, "aOrdens[oOrdPes:nAt,06]",, .F., .T., , "ID06" })
        oOrdPAgr:addColumn({"Tp Ordem"     , {||aOrdens[oOrdPAgr:nAt,04]}, "C", "", 1, 010 , , .T. , , .F.,, "aOrdens[oOrdPes:nAt,04]",, .F., .T., , "ID04" })
        oOrdPAgr:addColumn({"Produto"      , {||aOrdens[oOrdPAgr:nAt,05]}, "C", "", 1, 060 , , .T. , , .F.,, "aOrdens[oOrdPes:nAt,05]",, .F., .T., , "ID05" })
       
        oOrdPAgr:Activate()

	oModal:Activate()

Return Nil
/*/{Protheus.doc} selecAgr
    Marca registro.
    @type  Static Function
    @author Everson
    @since 09/12/2021
    @version 01
/*/
Static Function selecAgr(oBrowse, aArquivo)

    aArquivo[oBrowse:nAt,01] := !aArquivo[oBrowse:nAt,1]
    oBrowse:Refresh()

Return Nil
/*/{Protheus.doc} selecTAgr
    Marca todos os registros.
    @type  Static Function
    @author Everson
    @since 10/12/2021
    @version 01
/*/
Static Function selecTAgr(oBrowse, aArquivo, lMarker)

    //Variáveis.
    Local nAux := 1

    For nAux := 1 to len(aArquivo)
        aArquivo[nAux,01] := lMarker

    Next

    oBrowse:Refresh()
    lMarker:=!lMarker

Return Nil
/*/{Protheus.doc} prcAgrp
    Processa agrupamento das ordens de pesagem.
    @type  Static Function
    @author Everson
    @since 30/11/2021
    @version 01
/*/
Static Function prcAgrp(aOrdens)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local nAux      := 1
    Local cProdSAG  := ""
    Local cCP       := ""
    Local cRotPesa  := ""
    Local cNmOrdem  := ""
    Local cTpAgrup  := ""
    Local cPrAgrup  := ""
    Local cAgrupador:= ""
    Local cMsgError := ""
    Local nCountAgrp:= 0

    DbSelectArea("ZIA")
    ZIA->(DbSetOrder(2))
    ZIA->(DbGoTop())

    Begin Transaction

        For nAux := 1 To Len(aOrdens)
                
            cNmOrdem := Alltrim(cValToChar(aOrdens[nAux][3]))

            If ! U_ADFAT16A(cNmOrdem)
                cMsgError := "Ordem de pesagem " + cNmOrdem + " não localizada."
                DisarmTransaction()
                Break

            EndIf

            If aOrdens[nAux][1]

                If ! Empty(Alltrim(cValToChar(ZIF->ZIF_AGRUPA)))
                    cMsgError := "Ordem de pesagem " + cNmOrdem + " já está vinculada ao agrupador " + ZIF->ZIF_AGRUPA + "."
                    DisarmTransaction()
                    Break

                EndIf 

                cCP      := Alltrim(cValToChar(aOrdens[nAux][2]))
                cProdSAG := Alltrim(cValToChar(Posicione("ZIM", 2, FWxFilial("ZIM") + Alltrim(cValToChar(aOrdens[nAux][8])), "ZIM_PRDSAG")))
                cRotPesa := Posicione("ZIB", 1, FWxFilial("ZIB") + cCP, "ZIB_CODROT")

                If ! ZIA->(DbSeek( FWxFilial("ZIA") + cRotPesa + cProdSAG ))
                    cMsgError := "O produto " + Alltrim(cValToChar(cProdSAG)) + " não pode ser pesado no roteiro " + Alltrim(cValToChar(cRotPesa)) + "."
                    DisarmTransaction()
                    Break

                EndIf

                If Alltrim(cValToChar(ZIA->ZIA_AGRPRD)) == "0" //Valida se o produto pode ser agrupado.
                    cMsgError := "O produto " + Alltrim(cValToChar(cProdSAG)) + " não pode ser agrupado."
                    DisarmTransaction()
                    Break

                EndIf

                If ! Empty(cTpAgrup) .And. Alltrim(cValToChar(ZIA->ZIA_AGRPRD)) <> cTpAgrup //Valida se há apenas um tipo de agrupamento.
                    cMsgError := "O produto " + Alltrim(cValToChar(cProdSAG)) + " não pode ser agrupado, pois há tipos de agrupamento diferentes na carga."
                    DisarmTransaction()
                    Break

                ElseIf Empty(cTpAgrup)
                    cTpAgrup := Alltrim(cValToChar(ZIA->ZIA_AGRPRD))

                EndIf

                If ! Empty(cPrAgrup) .And. cTpAgrup == "1" .And. cProdSAG <> cPrAgrup //Valida produtos iguais para o tipo 1 de agrupamento.
                    cMsgError := "O produto " + Alltrim(cValToChar(cProdSAG)) + " não pode ser agrupado, pois há produtos diferentes na carga."
                    DisarmTransaction()
                    Break

                ElseIf Empty(cPrAgrup)
                    cPrAgrup := cProdSAG

                EndIf

                If Empty(cAgrupador)
                    cAgrupador := GetSxeNum("ZIF","ZIF_NUMERO")
                    ConfirmSx8()

                EndIf

                If ! U_ADFAT165(cNmOrdem, "ZIF_AGRUPA", cAgrupador, @cMsgError)
                    DisarmTransaction()
                    Break

                EndIf
            
                If ! U_ADFAT165(cNmOrdem, "ZIF_EAGRUP", "1", @cMsgError)
                    DisarmTransaction()
                    Break

                EndIf

                nCountAgrp++

            Else

                If ! U_ADFAT165(cNmOrdem, "ZIF_AGRUPA", "", @cMsgError)
                    DisarmTransaction()
                    Break

                EndIf

                If ! U_ADFAT165(cNmOrdem, "ZIF_EAGRUP", "2", @cMsgError)
                    DisarmTransaction()
                    Break

                EndIf                

            EndIf

            If Alltrim(cValToChar(ZIF->ZIF_STATLA)) == "1" .And. Empty(Alltrim(cValToChar(ZIF->ZIF_EAGRUP)))

                If ! U_ADFAT164(cNmOrdem, "3", 1)
                    DisarmTransaction()
                    Break

                EndIf

            ElseIf Empty(Alltrim(cValToChar(ZIF->ZIF_EAGRUP)))

                If ! U_ADFAT164(cNmOrdem, "2", 1)
                    DisarmTransaction()
                    Break

                EndIf

            EndIf

        Next nAux

        If nCountAgrp = 1
            cMsgError := "Não é possível haver apenas uma ordem de pesagem vinculada a um agrupador."
            DisarmTransaction()
            Break

        EndIf

    End Transaction

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função prcAgrp(ADFAT017P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    Else
        lRet := .T.
        If ! Empty(cAgrupador)
            MsgInfo("Gerado agrupador " + cAgrupador + ".", "Função prcAgrp(ADFAT017P)")

        EndIf

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} getPesToOr
    Obtém o peso total das ordens agrupadas.
    @type  Static Function
    @author Everson
    @since 25/11/2021
    @version 01
/*/
Static Function getPesToOr(cNmOrdem)

    //Variáveis.
    Local nQuant := 0
    Local cAgrupa:= Alltrim(cValToChar(Posicione("ZIF", 2, FWxFilial("ZIF") + cNmOrdem, "ZIF_AGRUPA")))
    Local cQuery := ""
    
    If Empty(cAgrupa)
        cQuery := " SELECT ISNULL(SUM(ZIF_QUANT),0) AS ZIF_QUANT FROM " + RetSqlName("ZIF") + " AS ZIF (NOLOCK) WHERE ZIF_FILIAL = '" + FWxFilial("ZIF") + "' AND ZIF_NUMERO = '" + cNmOrdem + "' AND ZIF.D_E_L_E_T_ = '' "

    Else
        cQuery := " SELECT ISNULL(SUM(ZIF_QUANT),0) AS ZIF_QUANT FROM " + RetSqlName("ZIF") + " AS ZIF (NOLOCK) WHERE ZIF_FILIAL = '" + FWxFilial("ZIF") + "' AND ZIF_AGRUPA = '" + cAgrupa + "' AND ZIF.D_E_L_E_T_ = '' "

    EndIf

    If Select("D_QTAGR") > 0
        cQuery->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_QTAGR"
    DbSelectArea("D_QTAGR")
        nQuant := Val(cValToChar(D_QTAGR->ZIF_QUANT))
    D_QTAGR->(DbCloseArea())

Return nQuant
/*/{Protheus.doc} carOrdAg
    Carrega dados de ordens de pesagem para serem agrupadas.
    @type  Static Function
    @author Everson
    @since 19/11/2021
    @version 01
/*/
Static Function carOrdAg(cCP, aOrdens, aTpOrdem)

    //Variáveis.
    Local aArea     := GetArea()
    Local cQuery    := " SELECT * FROM " + RetSqlName("ZIF") + " (NOLOCK) AS ZIF WHERE ZIF_FILIAL = '" + FWxFilial("ZIF") + "' AND ZIF_CTPATI = '" + cCP + "' AND ZIF.D_E_L_E_T_ = '' "
    Local cProduto  := ""
    Local nPTpOrd   := 0
    Local cNmOrdem  := ""

    If Select("D_AGRO") > 0
        D_AGRO->(DbCloseArea())

    EndIf

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(2))
    ZIG->(DbGoTop())

    TcQuery cQuery New Alias "D_AGRO"
    DbSelectArea("D_AGRO")
    While ! D_AGRO->(Eof())

        If D_AGRO->ZIF_EAGRUP == "1"
            cNmOrdem := D_AGRO->ZIF_AGRUPA

        Else
            cNmOrdem := D_AGRO->ZIF_NUMERO

        EndIf

        If ZIG->(DbSeek( FWxFilial("ZIG") + cNmOrdem ))

            //If ZIG->ZIG_INICIA <> "1" .Or. ! Empty(Alltrim(cValToChar(ZIG->ZIG_NUMGUA)))
                D_AGRO->(Dbskip())
                Loop

            //EndIf

        EndIf

        nPTpOrd  := AScan(aTpOrdem, {|x| Alltrim(cValToChar(x[2])) == Alltrim(cValToChar(D_AGRO->ZIF_TPMOVI))})
        cProduto := U_ADFAT176(D_AGRO->ZIF_PRDSAG, D_AGRO->ZIF_PRDPRO)
        Aadd(aOrdens,{.F., D_AGRO->ZIF_CTPATI, D_AGRO->ZIF_NUMERO, aTpOrdem[nPTpOrd,3], cProduto, D_AGRO->ZIF_AGRUPA, D_AGRO->ZIF_PRDSAG, D_AGRO->ZIF_PRDPRO})
        
        D_AGRO->(Dbskip())

    End

    D_AGRO->(DbCloseArea())

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFAT176
    Obtém descrição do produto.
    @type  User Function
    @author Everson
    @since 09/12/2021
    @version 01
/*/
User Function ADFAT176(cCodSAG, cCodProth, nOPc)

    //Variáveis.
    Local cProduto := ""

    Default cCodSAG   := ""
    Default cCodProth := ""
    Default nOPc      := 1
    
    If !Empty(cCodSAG)

        If nOPc == 1
            cProduto := Alltrim(cCodSAG)   + " " + Alltrim(Posicione("ZIM",1, FWxFilial("ZIM") + cCodSAG, "ZIM_DESSAG"))

        ElseIf nOpc == 2
            cProduto := Alltrim(Posicione("ZIM",1, FWxFilial("ZIM") + cCodSAG, "ZIM_DESSAG"))

        EndIf

    ElseIf !Empty(cCodProth)

        If nOPc == 1
            cProduto := Alltrim(cCodProth) + " " + Alltrim(Posicione("SB1",1, FWxFilial("SB1") + cCodProth, "B1_DESC"))

        ElseIf nOpc == 2
            cProduto := Alltrim(Posicione("SB1",1, FWxFilial("SB1") + cCodProth, "B1_DESC"))

        EndIf

    EndIf

Return cProduto  
/*/{Protheus.doc} atrTicket
    Atribui ticket à ordem de pesagem.
    @type  Static Function
    @author Everson
    @since 19/11/2021
    @version 01
/*/
Static Function atrTicket(oOrdPes, aOrdPes, cBalanca)

    //Variáveis.
    Local aArea    := GetArea()
    Local cTpOrdem := ""
    Local cNmOrdem := ""
    Local cTicket  := ""
    Local nLinha   := Val(cValToChar(oOrdPes:nAt))
    Local cAgrup   := ""
    Local cOrdAgrup:= ""
    Local cCP      := ""
    Local nQuant   := 0
    Local cMsg     := ""
    Local lAgrup   := .F.
    Local cLote    := ""
    Local cSitOrd  := ""
    Local cRotPesa := ""

    If nLinha <= 0 .Or. Len(aOrdPes) <= 0
        Help(Nil, Nil, "Função atrTicket(ADFAT017P)", Nil, "Não há dados.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf
    
    cNmOrdem := aOrdPes[nLinha,08]
    cTpOrdem := aOrdPes[nLinha,14]
    cTicket  := Alltrim(cValToChar(aOrdPes[nLinha,11]))
    cOrdAgrup:= aOrdPes[nLinha,18]
    If ! Empty(cTicket)
        Help(Nil, Nil, "Função atrTicket(ADFAT017P)", Nil, "Já há o ticket " + cTicket + " associado à ordem " + Iif(Empty(cOrdAgrup),cNmOrdem,cOrdAgrup) + "("+ cTpOrdem +").", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    cAgrup   := Alltrim(cValToChar(aOrdPes[nLinha,09]))
    cSitOrd  := Alltrim(cValToChar(aOrdPes[nLinha,17])) 
    cLote    := aOrdPes[nLinha,05]

    If Empty(cOrdAgrup)
        cMsg := "Deseja atribuir ticket de pesagem à ordem " + cNmOrdem + "?"

    Else
        lAgrup := .T.
        cMsg := "Deseja atribuir ticket de pesagem ao agrupador " + cOrdAgrup + "?"

    EndIf
    
    If ! MsgYesNo(cMsg,"atrTicket(ADFAT017P)")
        RestArea(aArea)
        Return Nil

    EndIf

    cCP := Alltrim(cValToChar(aOrdPes[nLinha,16]))

    //Verifica se o controle de pátio está encerrado.
    If U_ADFAT17L(cCP)
        Help(Nil, Nil, "Função atrTicket(ADFAT017P)", Nil, "Controle de pátio " + cCP + " encerrado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    cRotPesa := Posicione("ZIB", 1, FWxFilial("ZIB") + cCP, "ZIB_CODROT")
    nQuant   := getPesToOr(cNmOrdem)
    
    If cTpOrdem == "O" //Outras.
        gerTkOt(nLinha, oOrdPes, aOrdPes, cCP, cNmOrdem, nQuant, cBalanca, cRotPesa)

    ElseIf cTpOrdem == "E" //Entrada.

        If Empty(cAgrup)
            Help(Nil, Nil, "Função atrTicket(ADFAT017P)", Nil, "Defina o agrupamento da ordem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
            RestArea(aArea)
            Return Nil

        EndIf

        If !(cSitOrd $"3/5") // Aprovado laboratório / Aprovado comercial
            Help(Nil, Nil, "Função atrTicket(ADFAT017P)", Nil, "A situação da ordem de pesagem não permite atribuição de ticket de pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
            RestArea(aArea)
            Return .F.
        
        EndIf

        If ! vldLote(cOrdAgrup, cLote)
            RestArea(aArea)
            Return .F.

        EndIF

        gerTkEn(nLinha, oOrdPes, aOrdPes, cCP, cNmOrdem, nQuant, lAgrup, cOrdAgrup, cBalanca, cRotPesa)

    ElseIf cTpOrdem == "S" //Saída.

        If ! Empty(cLote) .And. ! vldLote(cOrdAgrup, cLote)
            RestArea(aArea)
            Return .F.

        EndIF
        
        gerTkSa(nLinha, oOrdPes, aOrdPes, cCP, cNmOrdem, nQuant, cBalanca, cRotPesa)
        
    ElseIf cTpOrdem == "R" //Ração.
        
        If ! vldLote(cOrdAgrup, cLote)
            RestArea(aArea)
            Return .F.

        EndIF

        If U_ADFAT17K(cCP, cNmOrdem, nQuant, cBalanca, cRotPesa)
            procEnvGb(cNmOrdem)

        EndIf

    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} cancTkt
    Cancela ticket de pesagem.
    @type  Static Function
    @author Everson
    @since 22/11/2021
    @version 01
/*/
Static Function cancTkt(oOrdPes, aOrdPes)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local nLinha    := Val(cValToChar(oOrdPes:nAt))
    Local cOrdAgrup := ""
    Local cTicket   := ""
    Local cCP       := ""
    Local cNmOrdem  := ""
    Local cTpOrdem  := ""

    If nLinha <= 0 .Or. Len(aOrdPes) <= 0
        Help(Nil, Nil, "Função cancTkt(ADFAT017P)", Nil, "Não há dados.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    EndIf

    cOrdAgrup := aOrdPes[nLinha,18]
    cTpOrdem := aOrdPes[nLinha,14]
    cTicket  := Alltrim(cValToChar(aOrdPes[nLinha,11]))

    If Empty(cTicket)
        Help(Nil, Nil, "Função cancTkt(ADFAT017P)", Nil, "Não há ticket vinculado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    cCP := aOrdPes[nLinha,16]

    //Verifica se o controle de pátio está encerrado.
    If U_ADFAT17L(cCP)
        Help(Nil, Nil, "Função cancTkt(ADFAT017P)", Nil, "Controle de pátio " + cCP + " encerrado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    If ! MsgYesNo("Deseja cancelar o ticket de pesagem " + cTicket + "?","cancTkt(ADFAT017P)")
        RestArea(aArea)
        Return .F.

    EndIf
    
    cNmOrdem:= aOrdPes[nLinha,08]

    lRet := U_ADFAT172(cCP, cNmOrdem, cTicket, cTpOrdem, .T.)

    //Cancela ordem no Gemba.
    If lRet
        U_ADFAT50G(cNmOrdem)

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT172
    Processa cancelamento de ticket de pesagem.
    @type  User Function
    @author Everson
    @since 10/12/2021
    @version 01
/*/
User Function ADFAT172(cCP, cNmOrdem, cTicket, cTpOrdem, lExMsg)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local cMsgError := ""
    Local cStatOrd  := ""
    Local cStatCp   := ""

    Default lExMsg  := .T.
 
    Begin Transaction

        If ! U_ADFAT193(cTicket, @cMsgError) //Cancela ticket de pesagem.
            DisarmTransaction()
            Break

        EndIf

        If ! U_ADFAT17J(cCP, cNmOrdem, cTpOrdem, @cStatOrd, @cStatCp, @cMsgError) //Atualiza status da ordem de pesagem e controle de pátio.
            DisarmTransaction()
            Break

        EndIf

        lRet := .T.

        If lExMsg
            MsgInfo("Ticket de pesagem cancelado.","cancTkt(ADFAT017P)")

        EndIf

    End Transaction

    If ! Empty(cMsgError)
        U_ADFAT173("Cancelar ticket de pesagem : " + cMsgError, cNmOrdem, "", "PROTHEUS")

    Else
        U_ADFAT173("Cancelar ticket de pesagem : " + "ticket de pesagem cancelado " + ZIG->ZIG_NUMERO, cNmOrdem, "", "PROTHEUS")

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT17J
    Atualiza status da ordem de pesagem e ticket de pesagem, após cancelamento de ticket de pesagem.
    @type  User Function
    @author Everson
    @since 07/03/2022
    @version 01
/*/
User Function ADFAT17J(cCP, cNmOrdem, cTpOrdem, cStatOrd, cStatCp, cMsgError)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.

    Default cStatOrd := ""
    Default cStatCp  := ""
    Default cMsgError:= ""

    Begin Transaction

        If cTpOrdem $"O/R/S"
            cStatOrd := "1"
            cStatCp  := "1"

        ElseIf cTpOrdem == "E"
            cStatOrd := "3"
            cStatCp  := "2"

        EndIf
        
        If ! U_ADFAT175(cNmOrdem, cStatOrd, 1, @cMsgError) //Atualiza status da ordem.
            DisarmTransaction()
            Break

        EndIf

        If ! U_ADFAT174(cCP, "ZIB_STATUS", cStatCp, @cMsgError) //Atualiza status do controle de pátio.
            DisarmTransaction()
            Break

        EndIf

        lRet := .T.

    End Transaction

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} vldLote
    Valida lote de produto.
    @type  Static Function
    @author Everson
    @since 15/12/2021
    @version 01
/*/
Static Function vldLote(cOrdAgrup, cLote)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .T.

    If Empty(cOrdAgrup)
        lRet := prVldLote(cLote)

    Else

        DbSelectArea("ZIF")
        ZIF->(DbSetOrder(3))
        If ! ZIF->(DbSeek( FWxFilial("ZIF") + cOrdAgrup ))
            Help(Nil, Nil, "Função vldLote(ADFAT017P)", Nil, "Agrupador " + cOrdAgrup + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
            RestArea(aArea)
            Return .F.

        EndIf

        While ! ZIF->(Eof()) .And. FWxFilial("ZIF") == ZIF->ZIF_FILIAL .And. ZIF->ZIF_AGRUPA == cOrdAgrup

            lRet := prVldLote(ZIF->ZIF_LOTE)

            If ! lRet
                Exit

            EndIF

            ZIF->(DbSkip())

        End

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} prVldLote
    Processa a validação de lote de produto.
    @type  Static Function
    @author Everson
    @since 15/12/2021
    @version 01
/*/
Static Function prVldLote(cLote)

    //Variáveis.
    Local aArea := GetArea()

    DbSelectArea("ZI8")
    ZI8->(DbSetOrder(1))
    If ! ZI8->( DbSeek( FWxFilial("ZI8") + cLote ) )
        Help(Nil, Nil, "Função prVldLote(ADFAT017P)", Nil, "Lote " + cLote + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    If ZI8->ZI8_LAUTO == "1"
        Help(Nil, Nil, "Função prVldLote(ADFAT017P)", Nil, "Lote " + Alltrim(cValToChar(ZI8->ZI8_DESLOT)) + " não é válido(automático).", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    If ZI8->ZI8_STATUS == "4"
        Help(Nil, Nil, "Função prVldLote(ADFAT017P)", Nil, "Lote " + Alltrim(cValToChar(ZI8->ZI8_DESLOT)) + " não é válido(encerrado).", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} gerTkOt
    Atribui ticket de pesagem à ordem do tipo "Outras".
    @type  Static Function
    @author Everson
    @since 22/11/2021
    @version 01
/*/
Static Function gerTkOt(nLinha, oOrdPes, aOrdPes, cCP, cNmOrdem, nQuant, cBalanca, cRotPesa)

    //Variáveis.
    Local oTicket    := Nil
    Local aError    := {}
    Local cMsgError := ""
    Local cTicket   := Alltrim(cValToChar(Posicione("ZIG",2,FWxFilial("ZIG") + cNmOrdem , "ZIG_NUMERO")))
    Local cPlaca    := Posicione("ZIF",2,FWxFilial("ZIF") + cNmOrdem,"ZIF_PLACA")
    Local cTransp   := Posicione("ZV4",1,FWxFilial("ZV4") + cPlaca,"ZV4_FORNEC")
    Local cLjTransp := Posicione("ZV4",1,FWxFilial("ZV4") + cPlaca,"ZV4_LOJFOR")
    Local cMotori   := Posicione("ZV4",1,FWxFilial("ZV4") + cPlaca,"ZV4_CPF")
    Local cTag      := Posicione("ZIB",1,FWxFilial("ZIB") + cCP,"ZIB_TAG")

    If ! Empty(cTicket)
        Help(Nil, Nil, "Função gerTkOt(ADFAT017P)", Nil, "Já há o ticket de pesagem " + cTicket + " vinculado à ordem " + cValToChar(cNmOrdem) + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    //Posiciona no registro de pátio selecionado.
    U_ADFAT17U(cCP)

    oTicket := FwLoadModel("ADFAT019P")

    oTicket:SetOperation(MODEL_OPERATION_INSERT)
    oTicket:Activate() 

    oTicket:SetValue("MD_MASTER","ZIG_USUARI" ,__cUserId)
    oTicket:SetValue("MD_MASTER","ZIG_PLACA"  ,cPlaca)
    oTicket:SetValue("MD_MASTER","ZIG_TRANSP" ,cTransp)
    oTicket:SetValue("MD_MASTER","ZIG_LJTRAN" ,cLjTransp)
    oTicket:SetValue("MD_MASTER","ZIG_MOTORI" ,cMotori)
    oTicket:SetValue("MD_MASTER","ZIG_TAG"    ,cTag)
    oTicket:SetValue("MD_MASTER","ZIG_TPMOV"  ,"O")
    oTicket:SetValue("MD_MASTER","ZIG_ORDEM"  ,cNmOrdem)
    oTicket:SetValue("MD_MASTER","ZIG_CTPATI" ,cCP)
    oTicket:SetValue("MD_MASTER","ZIG_PESORD" ,nQuant)
    oTicket:SetValue("MD_MASTER","ZIG_BALANC" ,cBalanca)
    oTicket:SetValue("MD_MASTER","ZIG_ROTEIR" ,cRotPesa)

    Begin Transaction

        If oTicket:VldData()
            oTicket:CommitData()

            If ! U_ADFAT175(cNmOrdem, "2", 1) //Atualiza status da ordem.
                DisarmTransaction()
                Break

            EndIf

            If ZIB->ZIB_STATUS $"1/2" .And. ! U_ADFAT174(cCP, "ZIB_STATUS", "3") //Atualiza status do controle de pátio.
                DisarmTransaction()
                Break

            EndIf

            MsgInfo("Ticket de pesagem gerado " + cValToChar(ZIG->ZIG_NUMERO) + ".","gerTkOt(ADFAT017P")

        Else
            aError := oTicket:GetErrorMessage()
            cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

        EndIf

    End Transaction

    oTicket:DeActivate()
    oTicket:Destroy()
    oTicket := Nil

    If ! Empty(cMsgError)
        U_ADFAT173("Atribuir ticket de pesagem : " + cMsgError, cNmOrdem, "", "PROTHEUS")
        Help(Nil, Nil, "Função gerTkOt(ADFAT017P)", Nil, "Erro na geração de registro de ticket de pesagem." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    Else
        U_ADFAT173("Atribuir ticket de pesagem : " + "ticket gerado " + ZIG->ZIG_NUMERO, cNmOrdem, "", "PROTHEUS")

    EndIf

Return Nil
/*/{Protheus.doc} gerTkEn
    Atribui ticket à ordem de pesagem do tipo "Entrada".
    @type  Static Function
    @author Everson
    @since 13/12/2021
    @version 01
/*/
Static Function gerTkEn(nLinha, oOrdPes, aOrdPes, cCP, cNmOrdem, nQuant, lAgrup, cOrdAgrup, cBalanca, cRotPesa, cSeqTkt, cMsgError)

    //Variáveis.
    Local oTicket    := Nil
    Local aError    := {}
    Local cTicket   := Alltrim(cValToChar(Posicione("ZIG",2,FWxFilial("ZIG") + cNmOrdem , "ZIG_NUMERO")))
    Local cPlaca    := Posicione("ZIF",2,FWxFilial("ZIF") + cNmOrdem,"ZIF_PLACA")
    Local cTransp   := Posicione("ZV4",1,FWxFilial("ZV4") + cPlaca,"ZV4_FORNEC")
    Local cLjTransp := Posicione("ZV4",1,FWxFilial("ZV4") + cPlaca,"ZV4_LOJFOR")
    Local cMotori   := Posicione("ZV4",1,FWxFilial("ZV4") + cPlaca,"ZV4_CPF")
    Local cTag      := Posicione("ZIB",1,FWxFilial("ZIB") + cCP,"ZIB_TAG")

    Default cSeqTkt     := ""
    Default cMsgError   := ""

    If ! Empty(cTicket)
        Help(Nil, Nil, "Função gerTkOt(ADFAT017P)", Nil, "Já há o ticket de pesagem " + cTicket + " vinculado à ordem " + cValToChar(cNmOrdem) + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    //Posiciona no registro de pátio selecionado.
    U_ADFAT17U(cCP)

    oTicket := FwLoadModel("ADFAT019P")

    oTicket:SetOperation(MODEL_OPERATION_INSERT)
    oTicket:Activate() 

    If ! Empty(cSeqTkt)
        oTicket:SetValue("MD_MASTER","ZIG_SEQTKT" ,cSeqTkt)

    EndIf

    oTicket:SetValue("MD_MASTER","ZIG_USUARI" ,__cUserId)
    oTicket:SetValue("MD_MASTER","ZIG_PLACA"  ,cPlaca)
    oTicket:SetValue("MD_MASTER","ZIG_TRANSP" ,cTransp)
    oTicket:SetValue("MD_MASTER","ZIG_LJTRAN" ,cLjTransp)
    oTicket:SetValue("MD_MASTER","ZIG_MOTORI" ,cMotori)
    oTicket:SetValue("MD_MASTER","ZIG_TAG"    ,cTag)
    oTicket:SetValue("MD_MASTER","ZIG_TPMOV"  ,"E")
    oTicket:SetValue("MD_MASTER","ZIG_ORDEM"  ,Iif(lAgrup,cOrdAgrup,cNmOrdem))
    oTicket:SetValue("MD_MASTER","ZIG_AGRUPA" ,Iif(lAgrup,"1","2"))
    oTicket:SetValue("MD_MASTER","ZIG_CTPATI" ,cCP)
    oTicket:SetValue("MD_MASTER","ZIG_PESORD" ,nQuant)
    oTicket:SetValue("MD_MASTER","ZIG_BALANC", cBalanca)
    oTicket:SetValue("MD_MASTER","ZIG_ROTEIR", cRotPesa)

    Begin Transaction

        If oTicket:VldData()
            oTicket:CommitData()

            If ! U_ADFAT175(cNmOrdem, "8", 1) //Atualiza status da ordem.
                DisarmTransaction()
                Break

            EndIf

            If ZIB->ZIB_STATUS $"1/2" .And. ! U_ADFAT174(cCP, "ZIB_STATUS", "3") //Atualiza status do controle de pátio.
                DisarmTransaction()
                Break

            EndIf

            MsgInfo("Ticket de pesagem gerado " + cValToChar(ZIG->ZIG_NUMERO) + ".","gerTkOt(ADFAT017P")

        Else
            aError := oTicket:GetErrorMessage()
            cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

        EndIf

    End Transaction

    oTicket:DeActivate()
    oTicket:Destroy()
    oTicket := Nil

    If ! Empty(cMsgError)
        U_ADFAT173("Atribuir ticket de pesagem : " + cMsgError, cNmOrdem, "", "PROTHEUS")
        Help(Nil, Nil, "Função gerTkOt(ADFAT017P)", Nil, "Erro na geração de registro de ticket de pesagem." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    Else
        U_ADFAT173("Atribuir ticket de pesagem : " + "ticket gerado " + ZIG->ZIG_NUMERO, cNmOrdem, "", "PROTHEUS")

    EndIf

Return Nil
/*/{Protheus.doc} ADFAT17K
    Atribui ticket à ordem de pesagem do tipo "Ração".
    @type  User Function
    @author Everson
    @since 24/02/2022
    @version 01
/*/
User Function ADFAT17K(cCP, cNmOrdem, nQuant, cBalanca, cRotPesa, cSeqTkt, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oTicket   := Nil
    Local aError    := {}
    Local cTicket   := Alltrim(cValToChar(Posicione("ZIG",2,FWxFilial("ZIG") + cNmOrdem , "ZIG_NUMERO")))
    Local cPlaca    := Posicione("ZIF",2,FWxFilial("ZIF") + cNmOrdem,"ZIF_PLACA")
    Local cTransp   := Posicione("ZV4",1,FWxFilial("ZV4") + cPlaca,"ZV4_FORNEC")
    Local cLjTransp := Posicione("ZV4",1,FWxFilial("ZV4") + cPlaca,"ZV4_LOJFOR")
    Local cMotori   := Posicione("ZV4",1,FWxFilial("ZV4") + cPlaca,"ZV4_CPF")
    Local cTag      := Posicione("ZIB",1,FWxFilial("ZIB") + cCP,"ZIB_TAG")

    Default cSeqTkt   := ""
    Default cMsgError := ""

    If ! Empty(cTicket)
        cMsgError := "Já há o ticket de pesagem " + cTicket + " vinculado à ordem " + cValToChar(cNmOrdem) + "."
        Help(Nil, Nil, "Função ADFAT17K(ADFAT017P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    //Posiciona no registro de pátio selecionado.
    U_ADFAT17U(cCP)

    oTicket := FwLoadModel("ADFAT019P")

    oTicket:SetOperation(MODEL_OPERATION_INSERT)
    oTicket:Activate() 

    If ! Empty(cSeqTkt)
        oTicket:SetValue("MD_MASTER","ZIG_SEQTKT" ,cSeqTkt)

    EndIf
    
    oTicket:SetValue("MD_MASTER","ZIG_USUARI" ,__cUserId)
    oTicket:SetValue("MD_MASTER","ZIG_PLACA"  ,cPlaca)
    oTicket:SetValue("MD_MASTER","ZIG_TRANSP" ,cTransp)
    oTicket:SetValue("MD_MASTER","ZIG_LJTRAN" ,cLjTransp)
    oTicket:SetValue("MD_MASTER","ZIG_MOTORI" ,cMotori)
    oTicket:SetValue("MD_MASTER","ZIG_TAG"    ,cTag)
    oTicket:SetValue("MD_MASTER","ZIG_TPMOV"  ,"R")
    oTicket:SetValue("MD_MASTER","ZIG_ORDEM"  ,cNmOrdem)
    oTicket:SetValue("MD_MASTER","ZIG_CTPATI" ,cCP)
    oTicket:SetValue("MD_MASTER","ZIG_PESORD" ,nQuant)
    oTicket:SetValue("MD_MASTER","ZIG_BALANC", cBalanca)
    oTicket:SetValue("MD_MASTER","ZIG_ROTEIR", cRotPesa)		

    Begin Transaction

        If oTicket:VldData()
            oTicket:CommitData()

            If ! U_ADFAT175(cNmOrdem, "2", 1) //Atualiza status da ordem.
                DisarmTransaction()
                Break

            EndIf

            If ZIB->ZIB_STATUS $"1/2" .And. ! U_ADFAT174(cCP, "ZIB_STATUS", "3") //Atualiza status do controle de pátio.
                DisarmTransaction()
                Break

            EndIf

            lRet := .T.

            MsgInfo("Ticket de pesagem gerado " + cValToChar(ZIG->ZIG_NUMERO) + ".","ADFAT17K(ADFAT017P")

        Else
            lRet := .F.
            aError := oTicket:GetErrorMessage()
            cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

        EndIf

    End Transaction

    oTicket:DeActivate()
    oTicket:Destroy()
    oTicket := Nil

    If ! Empty(cMsgError)
        U_ADFAT173("Atribuir ticket de pesagem : " + cMsgError, cNmOrdem, "", "PROTHEUS")
        Help(Nil, Nil, "Função ADFAT17K(ADFAT017P)", Nil, "Erro na geração de registro de ticket de pesagem." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    Else
        U_ADFAT173("Atribuir ticket de pesagem : " + "ticket gerado " + ZIG->ZIG_NUMERO, cNmOrdem, "", "PROTHEUS")

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} gerTkSa
    Atribui ticket de pesagem à ordem do tipo "Saída".
    @type  Static Function
    @author Everson
    @since 23/03/2022
    @version 01
/*/
Static Function gerTkSa(nLinha, oOrdPes, aOrdPes, cCP, cNmOrdem, nQuant, cBalanca, cRotPesa)

    //Variáveis.
    Local oTicket    := Nil
    Local aError    := {}
    Local cMsgError := ""
    Local cTicket   := Alltrim(cValToChar(Posicione("ZIG",2,FWxFilial("ZIG") + cNmOrdem , "ZIG_NUMERO")))
    Local cPlaca    := Posicione("ZIF",2,FWxFilial("ZIF") + cNmOrdem,"ZIF_PLACA")
    Local cTransp   := Posicione("ZV4",1,FWxFilial("ZV4") + cPlaca,"ZV4_FORNEC")
    Local cLjTransp := Posicione("ZV4",1,FWxFilial("ZV4") + cPlaca,"ZV4_LOJFOR")
    Local cMotori   := Posicione("ZV4",1,FWxFilial("ZV4") + cPlaca,"ZV4_CPF")
    Local cTag      := Posicione("ZIB",1,FWxFilial("ZIB") + cCP,"ZIB_TAG")

    If ! Empty(cTicket)
        Help(Nil, Nil, "Função gerTkOt(ADFAT017P)", Nil, "Já há o ticket de pesagem " + cTicket + " vinculado à ordem " + cValToChar(cNmOrdem) + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    //Posiciona no registro de pátio selecionado.
    U_ADFAT17U(cCP)

    oTicket := FwLoadModel("ADFAT019P")

    oTicket:SetOperation(MODEL_OPERATION_INSERT)
    oTicket:Activate() 

    oTicket:SetValue("MD_MASTER","ZIG_USUARI" ,__cUserId)
    oTicket:SetValue("MD_MASTER","ZIG_PLACA"  ,cPlaca)
    oTicket:SetValue("MD_MASTER","ZIG_TRANSP" ,cTransp)
    oTicket:SetValue("MD_MASTER","ZIG_LJTRAN" ,cLjTransp)
    oTicket:SetValue("MD_MASTER","ZIG_MOTORI" ,cMotori)
    oTicket:SetValue("MD_MASTER","ZIG_TAG"    ,cTag)
    oTicket:SetValue("MD_MASTER","ZIG_TPMOV"  ,"S")
    oTicket:SetValue("MD_MASTER","ZIG_ORDEM"  ,cNmOrdem)
    oTicket:SetValue("MD_MASTER","ZIG_CTPATI" ,cCP)
    oTicket:SetValue("MD_MASTER","ZIG_PESORD" ,nQuant)
    oTicket:SetValue("MD_MASTER","ZIG_BALANC" ,cBalanca)
    oTicket:SetValue("MD_MASTER","ZIG_ROTEIR" ,cRotPesa)

    Begin Transaction

        If oTicket:VldData()
            oTicket:CommitData()

            If ! U_ADFAT175(cNmOrdem, "2", 1) //Atualiza status da ordem.
                DisarmTransaction()
                Break

            EndIf

            If ZIB->ZIB_STATUS $"1/2" .And. ! U_ADFAT174(cCP, "ZIB_STATUS", "3") //Atualiza status do controle de pátio.
                DisarmTransaction()
                Break

            EndIf

            MsgInfo("Ticket de pesagem gerado " + cValToChar(ZIG->ZIG_NUMERO) + ".","gerTkSa(ADFAT017P")

        Else
            aError := oTicket:GetErrorMessage()
            cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

        EndIf

    End Transaction

    oTicket:DeActivate()
    oTicket:Destroy()
    oTicket := Nil

    If ! Empty(cMsgError)
        U_ADFAT173("Atribuir ticket de pesagem : " + cMsgError, cNmOrdem, "", "PROTHEUS")
        Help(Nil, Nil, "Função gerTkSa(ADFAT017P)", Nil, "Erro na geração de registro de ticket de pesagem." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    Else
        U_ADFAT173("Atribuir ticket de pesagem : " + "ticket gerado " + ZIG->ZIG_NUMERO, cNmOrdem, "", "PROTHEUS")

    EndIf

Return Nil
/*/{Protheus.doc} envBlcAut
    Envia ticket de pesagem para balança automática.
    @type  Static Function
    @author Everson
    @since 19/11/2021
    @version 01
/*/
Static Function envBlcAut(oOrdPes, aOrdPes, cBalanca)
    
    //Variáveis.
    Local aArea         := GetArea()
    Local nLinha        := Val(cValToChar(oOrdPes:nAt))
    Local cCP           := ""
    Local cNmOrdem      := ""
    Local cTpOrdem      := ""
    Local cAgrup        := ""
    Local cPlaca        := ""
    Local cTag          := ""
    Local cTktGuard     := ""
    Local cRot          := ""
    Local cFluxoGuard   := ""
    Local cTktProtheus  := ""

    If nLinha <= 0 .Or. Len(aOrdPes) <= 0
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Não há dados.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    cTktGuard := Alltrim(cValToChar(aOrdPes[nLinha,10]))
    If ! Empty(cTktGuard)
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Já há o ticket Guardian " + cTktGuard + " associado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    cCP := aOrdPes[nLinha,16]
    If Empty(cCP)
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Controle de pátio não selecionado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    cNmOrdem := aOrdPes[nLinha,08]
    cTpOrdem := aOrdPes[nLinha,14]
    If Empty(cNmOrdem)
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Selecione uma ordem de pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    cAgrup := aOrdPes[nLinha,08]
    If Empty(cAgrup)
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Defina o agrupamento da ordem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    cTktProtheus  := aOrdPes[nLinha,11]
    If Empty(Alltrim(cValToChar(cTktProtheus)))
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Não há ticket associado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    If ! U_ADFAT195(cTktProtheus)
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Ticket de pesagem " + cTktProtheus + " não encontrado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    If (ZIG->ZIG_INICIA == "4" .And. ZIG->ZIG_ACASEQ == "S") .Or.; //Sequestro com liberação automática.
        ZIG->ZIG_INICIA  $"3/5" //Peso final ou Sequestro liberado.
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "A pesagem está encerrada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    cTag := Alltrim(cValToChar( Posicione("ZIB", 1, FwxFilial("ZIB") + cCP, "ZIB_TAG" ) ))
    If Empty(cTag)
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Não há tag associada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    cRot := Alltrim(cValToChar( Posicione("ZIB", 1, FwxFilial("ZIB") + cCP, "ZIB_CODROT") ))
    If Empty(cRot)
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Não há roteiro associado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    cFluxoGuard := Alltrim(cValToChar( Posicione("ZI9", 1, FwxFilial("ZI9") + cRot, "ZI9_FXGURD") ))
    If Empty(cFluxoGuard)
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Não há fluxo Guardian associado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    cPlaca := Alltrim(cValToChar( Posicione("ZIB", 1, FwxFilial("ZIB") + cCP, "ZIB_PLACA") ))
    If Empty(cPlaca)
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Não há placa associada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    //Verifica se há ordem de pesagem com peso inicial e sem peso final.
    If ! vldOrdAb(cCP, cNmOrdem)
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Há ordem de pesagem com peso inicial, mas não finalizada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIF

    //Verifica se há ticket de pesagem com sequência menor que a selecionada.
    If chkVldSq(cCP, cTktProtheus)
        RestArea(aArea)
        Return Nil

    EndIf

    //Verifica se o controle de pátio está encerrado.
    If U_ADFAT17L(cCP)
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Controle de pátio " + cCP + " encerrado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    FWMsgRun(,{|| U_ADFAT17S(cTpOrdem, cPlaca, cTag, cTktProtheus, cFluxoGuard, cNmOrdem, 0) }, "Função envBlcAut(ADFAT017P)", "Enviando " + cTktProtheus + "...")

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFAT17S
    Envia ticket de pesagem para web service da balança.
    @type  User Function
    @author Everson
    @since 29/03/2022
    @version 01
/*/
User Function ADFAT17S(cTpOrdem, cPlaca, cTag, cTktProtheus, cFluxoGuard, cNmOrdem, nPesIni, cBalanca, cUrl, cOpIni, cPerPesIni, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local cPreFx    := "Envio Balança: "
    Local cTktGuard := ""
    Local cStatOrd  := ""
    Local oRetSolic := Nil
    Local cPlcFmt   := ""

    Default cBalanca  := U_ADFAT17V()
    Default cUrl      := U_ADFAT17X()
    Default cMsgError := ""
    Default cOpIni    := ""
    Default cPerPesIni:= ""

    If Empty(cUrl)
        cMsgError := "Url da balança " + cBalanca + " não está definido."
        U_ADFAT173(cPreFx + cMsgError, cNmOrdem, "", "GUARDIAN")
        Help(Nil, Nil, "Função ADFAT17S(ADFAT017P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    cPlcFmt := Substr(cPlaca, 1, 3) + "-" + Substr(cPlaca, 4, 4)

    If !  U_ADFAT241(cUrl, @oRetSolic, @cMsgError, cPlcFmt, cPlcFmt, cTag, cFluxoGuard, cTktProtheus, nPesIni, cOpIni, cPerPesIni)
        U_ADFAT173(cPreFx + cMsgError, cNmOrdem, "", "GUARDIAN")
        cMsgError := "Ocorreu erro no envio de pesagem para balança." + xPula + cMsgError
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    cTktGuard := cValToChar(oRetSolic:cCodigo)

    If ! Empty(cTktGuard)

        cStatOrd := Iif(cTpOrdem == "E", "9", "3")

        If U_ADFAT191(cTktProtheus, "ZIG_NUMGUA", cTktGuard, @cMsgError) 
        
            If nPesIni == 0 .And.;
               U_ADFAT175(cNmOrdem, cStatOrd, 1, @cMsgError)
               Help(Nil, Nil, "Função ADFAT17S(ADFAT017P)", Nil, "Ticket Guardian gerado " + cTktGuard + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

            EndIf

        Else
            U_ADFAT173(cPreFx + cMsgError, cNmOrdem, "", "GUARDIAN")
            Help(Nil, Nil, "Função ADFAT17S(ADFAT017P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

    Else
        cMsgError := "Não há ticket do Guardian gerado."
        U_ADFAT173(cPreFx + cMsgError, cNmOrdem, "", "GUARDIAN")
        Help(Nil, Nil, "Função ADFAT17S(ADFAT017P)", Nil, "Função ADFAT17S(ADFAT017P)-Ticket Guardian gerado para o ticket Protheus " + cTktProtheus + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    U_ADFAT173(cPreFx + "ordem de pesagem enviada para o Guardian ", cNmOrdem, "", "GUARDIAN")

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} pesaManu
    Pesagem manual.
    @type  Static Function
    @author Everson
    @since 23/11/2021
    @version 01
/*/
Static Function pesaManu(aParBal, oOrdPes, aOrdPes, cBalanca)

    //Variáveis.
    Local nLinha   := Val(cValToChar(oOrdPes:nAt))

    If nLinha <= 0 .Or. Len(aOrdPes) <= 0
        Help(Nil, Nil, "Função pesaManu(ADFAT017P)", Nil, "Não há dados.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf
    
    pesaSemAut(.T., @aParBal, oOrdPes, aOrdPes, cBalanca)

Return Nil
/*/{Protheus.doc} pesaSemAut
    Pesagem semiautomática.
    @type  Static Function
    @author Everson
    @since 22/11/2021
    @version 01
/*/
Static Function pesaSemAut(lPesagManu, aParBal, oOrdPes, aOrdPes, cBalanca)

    //Variáveis.
    Local aArea     := GetArea()
    Local nLinha    := Val(cValToChar(oOrdPes:nAt))
    Local cTicket   := ""
    Local cTktGuard := ""
    Local cNmOrdem  := ""
    Local cAgrup    := ""
    Local cForn     := ""
    Local cPlaca    := ""
    Local nQtdOrd   := ""
    Local cProduto  := ""
    Local nPeso1    := 0
    Local nPeso2    := 0
    Local nPeso3    := 0
    Local nPesTot   := 0
    Local bAutTot   := Nil
    Local oPesSemiA := Nil
    Local oContainer:= Nil
    Local bConfirm  := {}
    Local aButtons  := {}
    Local cDTpPes    := ""
    Local nPesoLiq  := 0
    Local nPOrLi    := 0
    Local nTpPesa   := 1
    Local nPesIni   := 0
    Local cSolPesMan:= ""
    Local lRetSlv   := .F.
    Local aDdPAnt   := {}
    Local oFont     := TFont():New(,,,,.T.)
    Local nTpSeq    := 0
    Local cAcaSeq   := ""
    Local lSequestra:= .F.

    If nLinha <= 0 .Or. Len(aOrdPes) <= 0
        Help(Nil, Nil, "Função pesaSemAut(ADFAT017P)", Nil, "Não há dados.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    cNmOrdem := aOrdPes[nLinha,08]
    If Empty(Alltrim(cValToChar(cNmOrdem)))
        Help(Nil, Nil, "Função pesaSemAut(ADFAT017P)", Nil, "Selecione uma ordem de pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    cAgrup := aOrdPes[nLinha,09]
    If Empty(Alltrim(cValToChar(cAgrup)))
        Help(Nil, Nil, "Função pesaSemAut(ADFAT017P)", Nil, "Defina o agrupamento da ordem de pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    cTicket  := aOrdPes[nLinha,11]
    If Empty(Alltrim(cValToChar(cTicket)))
        Help(Nil, Nil, "Função pesaSemAut(ADFAT017P)", Nil, "Não há ticket associado à ordem de pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    If ! U_ADFAT195(cTicket)
        Help(Nil, Nil, "Função pesaSemAut(ADFAT017P)", Nil, "Ticket de pesagem " + cTicket + " não encontrado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    If (ZIG->ZIG_INICIA == "4" .And. ZIG->ZIG_ACASEQ == "S") .Or.; //Sequestro com liberação automática.
        ZIG->ZIG_INICIA  $"3" //Peso final ou Sequestro liberado.
        Help(Nil, Nil, "Função pesaSemAut(ADFAT017P)", Nil, "A pesagem está encerrada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        RestArea(aArea)
        Return Nil

    EndIf

    cCP := ZIG->ZIG_CTPATI

    //Verifica se o controle de pátio está encerrado.
    If U_ADFAT17L(cCP)
        Help(Nil, Nil, "Função atrTicket(ADFAT017P)", Nil, "Controle de pátio " + cCP + " encerrado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    cNmOrdem := Iif(!Empty(aOrdPes[nLinha,18]),aOrdPes[nLinha,18],cNmOrdem)
    cForn    := aOrdPes[nLinha,03]
    cPlaca   := ZIG->ZIG_PLACA
    nQtdOrd  := ZIG->ZIG_PESORD
    cProduto := aOrdPes[nLinha,04]
    cManual  := Iif(lPesagManu,"1","2")
    cTktGuard:= ZIG->ZIG_NUMGUA
    cSituacao:= aOrdPes[nLinha,12]

    //Verifica se há ordem de pesagem com peso inicial e sem peso final.
    If ! vldOrdAb(cCP, cNmOrdem)
        Help(Nil, Nil, "Função pesaSemAut(ADFAT017P)", Nil, "Há ordem de pesagem com peso inicial, mas não finalizada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIF

    nPesIni  := ZIG->ZIG_PESINI
    nTpPesa  := Iif(ZIG->ZIG_PESINI == 0,1,2)
    cDTpPes  := Iif(nTpPesa == 1,"Peso Inicial","Peso Final")
    
    //Verifica se há ticket de pesagem com sequência menor que a selecionada.
    If nTpPesa == 1 .And. chkVldSq(cCP, cTicket)
        RestArea(aArea)
        Return Nil

    EndIf

    bAutTot := {|| nPesTot := nPeso1 + nPeso2 + nPeso3, Iif(nTpPesa == 1,Nil,Eval({||nPesoLiq := Abs(nPesTot - nPesIni), nPOrLi := nPesoLiq - nQtdOrd})) }

    bConfirm := {||;
                    lRetSlv := U_ADFAT171(cBalanca, cTicket, nPesTot, nPesoLiq, nTpPesa, "2", cManual, @cSolPesMan, aDdPAnt, @nTpSeq, @cAcaSeq, @lSequestra),;
            Iif(  ! lRetSlv, Nil,;
                    lRetSlv := U_ADFAT17I(nTpPesa, cBalanca, cCP, cTicket, nPesTot, "2", cManual, @cSolPesMan, aDdPAnt, nTpSeq, cAcaSeq, lSequestra);
                ),;
            Iif(  ! lRetSlv, Nil, oPesSemiA:DeActivate() );
    }

    oPesSemiA := FWDialogModal():New()        
	oPesSemiA:SetEscClose(.F.)
	oPesSemiA:setTitle("Múltiplos Pesos")
	oPesSemiA:setSize( 290 , 200 )
	oPesSemiA:createDialog()

    Aadd(aButtons,{Nil,"Confimar", bConfirm,"","",.T.,.F.})
    Aadd(aButtons,{Nil,"Cancelar", {|| oPesSemiA:DeActivate() },"","",.T.,.F.})
	
        oPesSemiA:addButtons(aButtons)

    	oContainer := TPanel():New( ,,, oPesSemiA:getPanelMain() )
	    oContainer:Align := CONTROL_ALIGN_ALLCLIENT

        TGroup():New(005,005,106,195,"Dados da ordem/ticket de pesagem",oContainer,,,.T.)
            TSay():New(015,010,{||"Fornecedor " + cForn}   ,oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,010)
            TSay():New(027,010,{||"Placa " + cPlaca}       ,oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,010)
            TSay():New(037,010,{||"Ticket " + cTicket}     ,oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,010)
            TSay():New(047,010,{||"Ticket Guardian " + cTktGuard}     ,oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,010)
            TSay():New(057,010,{||"Ordem " + cNmOrdem}       ,oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,010)
            TSay():New(067,010,{||"Produto " + cProduto}    ,oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,010)
            TSay():New(077,010,{||"Qtde. Ordem " + Transform(nQtdOrd,"@E 999,999,999.999")}   ,oContainer,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,100,010)
            TSay():New(087,010,{||"Peso Inicial " + TransForm(nPesIni, "@E 99,999,999,999")}  ,oContainer,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,100,010)
            TSay():New(097,010,{||"Situação " + cSituacao}  ,oContainer,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,010)

        TGroup():New(110,005,240,195,"Captura de Peso",oContainer,,,.T.)
            TGet():New(120,010,{|u|If(PCount() == 0,cDTpPes,cDTpPes := u)},oContainer,050,013,"",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cDTpPes",,,,.T.,,,"Pesagem",1) 
            TGet():New(120,065,{|u|If(PCount() == 0,nPesoLiq,nPesoLiq := u)},oContainer,060,013,"@E 99,999,999,999",{|| .T.  },0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nPesoLiq",,,,.T.,,,"Peso Líquido",1) 
            TGet():New(120,130,{|u|If(PCount() == 0,nPOrLi,nPOrLi := u)},oContainer,060,013,"@E 999,999.999",{|| .T. },0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nPOrLi",,,,.T.,,,"Ordem Líquido(Quebra)",1) 
            
            TButton():New(150,010,Iif(!lPesagManu, "Peso 1","Digitar Peso 1") ,oContainer,{|| nPeso1 := Iif(!lPesagManu,obtPeso(aParBal),getPesMan()), Eval(bAutTot) },080,15,,,.F.,.T.,.F.,,.F.,{|| Empty(cSolPesMan) },,.F. )
            
            TGet():New(150,100,{|u|If(PCount() == 0,nPeso1,nPeso1 := u)},oContainer,090,013,"@E 99,999,999,999",{|| .T.  },0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nPeso1",,,,.T.,,,"",2) 

            TButton():New(170,010,Iif(!lPesagManu, "Peso 2","Digitar Peso 2") ,oContainer,{|| nPeso2 := Iif(!lPesagManu,obtPeso(aParBal),getPesMan()), Eval(bAutTot) },080,15,,,.F.,.T.,.F.,,.F.,{|| Empty(cSolPesMan) },,.F. )
            
            TGet():New(170,100,{|u|If(PCount() == 0,nPeso2,nPeso2 := u)},oContainer,090,013,"@E 99,999,999,999",{|| .T. },0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nPeso2",,,,.T.,,,"",2) 

            TButton():New(190,010,Iif(!lPesagManu, "Peso 3","Digitar Peso 3") ,oContainer,{|| nPeso3 := Iif(!lPesagManu,obtPeso(aParBal),getPesMan()), Eval(bAutTot) },080,15,,,.F.,.T.,.F.,,.F.,{|| Empty(cSolPesMan) },,.F. )
            
            TGet():New(190,100,{|u|If(PCount() == 0,nPeso3,nPeso3 := u)},oContainer,090,013,"@E 99,999,999,999",{|| .T.  },0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nPeso3",,,,.T.,,,"",2) 
            
            TGet():New(220,087,{|u|If(PCount() == 0,nPesTot,nPesTot := u)},oContainer,090,013,"@E 99,999,999,999",{|| .T. },0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nPesTot",,,,.T.,,,"Total ",2) 
    
    oPesSemiA:Activate()

    If ! lRetSlv .And. ! Empty(cSolPesMan)
        exSolLiM(cSolPesMan)

    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFAT17I
    Gera pesagem inicial para o próximo ticket da sequência.
    @type  Static Function
    @author Everson
    @since 03/03/2022
    @version 01
/*/
User Function ADFAT17I(nTpPesa, cBalanca, cCP, cTicket, nPesTot, cPesAuto, cManual, cSolPesMan, aDdPAnt,;
                       nTpSeq, cAcaSeq, lSequestra, cMsgError)
    
    //Variáveis
    Local aArea     := GetArea()
    Local lRet      := .T.
    Local cPrxTkt   := ""
    Local cQuery    := ""

    Default cMsgError := ""

    cQuery += " SELECT " 
    cQuery += " TOP 1 ZIG_NUMERO, ZIG_SEQTKT " 
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("ZIG") + " (NOLOCK) AS ZIG " 
    cQuery += " WHERE " 
    cQuery += " ZIG_FILIAL = '" + FWxFilial("ZIG") + "' " 
    cQuery += " AND ZIG_CTPATI = '" + cCP + "' " 
    cQuery += " AND ZIG_INICIA = '1' " 
    cQuery += " AND ZIG_NUMERO <> '" + cTicket + "' " 
    cQuery += " AND ZIG.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY ZIG_SEQTKT " 

    If Select("D_PRXTK") > 0
        D_PRXTK->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_PRXTK"
    DbSelectArea("D_PRXTK")
    If ! D_PRXTK->(Eof())
        cPrxTkt := Alltrim(cValToChar(D_PRXTK->ZIG_NUMERO))
    EndIf
    D_PRXTK->(DbCloseArea())

    If nTpPesa == 2 .And. ! Empty(cPrxTkt) .And. (! lSequestra .Or. (lSequestra .And. cAcaSeq = "S"))
        lRet := U_ADFAT171(cBalanca, cPrxTkt, nPesTot, 0, 1, cPesAuto, cManual, @cSolPesMan, aDdPAnt, Nil, Nil, Nil,  @cMsgError)

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} vldOrdAb
    Verifica se há ordem de pesagem com peso inicial e sem peso final.
    @type  Static Function
    @author Everson
    @since 03/03/2022
    @version 01
/*/
Static Function vldOrdAb(cCP, cNmOrdem)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .T.

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(5))
    ZIG->(DbGoTop())
    If ZIG->( DbSeek( FWxFilial("ZIG") + cCP ) )

        While ! ZIG->(Eof()) .And. ZIG->ZIG_FILIAL == FWxFilial("ZIG") .And. ZIG->ZIG_CTPATI == cCP

            If ZIG->ZIG_INICIA $"2/4/5" .And.; //Peso inicial, Sequestrada e Sequestro Liberado.
               ZIG->ZIG_ORDEM <> cNmOrdem
                lRet := .F.
                Exit
                
            EndIf

            ZIG->(DbSkip())
            
        End

    EndIf
    RestArea(aArea)

Return lRet
/*/{Protheus.doc} getPesMan
    Interface para digitação de peso manual.
    @type  Static Function
    @author Everson
    @since 25/11/2021
    @version 01
/*/
Static Function getPesMan()

    //Variáveis.
    Local oPeso     := Nil
    Local nPeso     := 0
    Local oModel    := FWDialogModal():New() 
    Local oContainer:= Nil 

	oModel:SetEscClose(.F.)
	oModel:setTitle("Peso Manual")
	oModel:setSize( 100 , 150 )
	oModel:createDialog()
        
        oModel:AddButton( "Confirmar", {|| oModel:DeActivate() }, "Confirmar", , .T., .F., .T., )

     	oContainer := TPanel():New( ,,, oModel:getPanelMain() )
	    oContainer:Align := CONTROL_ALIGN_ALLCLIENT

        oPeso := TGet():New(020,005,{|u|If(PCount() == 0,nPeso,nPeso := u)},oContainer,140,015,"@E 999,999.999",{|| .T. },0,16777215,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F. ,,"nPeso",,,,.T.,,,"",2) 
        oPeso:setFocus()

    oModel:Activate()

Return nPeso
/*/{Protheus.doc} ADFAT171
    Salva pesagem no ticket.
    @type  User Function
    @author Everson
    @since 23/11/2021
    @version 01
/*/
User Function ADFAT171(cBalanca, cTicket, nPesTot, nPesoLiq, nTpPesa, cPesAuto,;
                       cManual, cSolPesMan, aDdPAnt, nTpSeq, cAcaSeq, lSequestra, cMsgError)

    //Variáveis.
    Local aArea       := GetArea()
    Local cPreFx      := "Pesagem: "
    Local lRet        := .T.
    Local cPlaca      := ""
    Local cNmOrdem    := ""
    Local nQtdOrd     := 0
    Local cCP         := ""
    Local cRotPesa    := ""
    Local cTpMovi     := ""
    Local lOutras     := .F.
    Local lEntrada    := .F.
    Local lRacao      := ""
    Local lSaida      := .F.
    Local cProdSAG    := ""
    Local cProdPro    := ""
    Local cProduto    := ""
    Local lEnsacado   := .F.
    Local lLacre      := .F.
    Local aDdSeq      := {}
    Local nPesIni     := 0
    Local cEnvBar     := ""
    Local lGemba      := GetMV("MV_#UGEMBA",,.F.)    
    
    Default aDdPAnt   := {}
    Default nTpSeq    := 0
    Default cAcaSeq   := ""
    Default lSequestra:= .F. 
    Default cMsgError := ""

    //Localiza ticket de pesagem.
    If ! U_ADFAT195(cTicket)
        cMsgError := "Ticket de pesagem " + cTicket + " não localizado."
        Help(Nil, Nil, "Função ADFAT171(ADFAT017P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    cPlaca    := ZIG->ZIG_PLACA
    cNmOrdem  := ZIG->ZIG_ORDEM
    nQtdOrd   := ZIG->ZIG_PESORD
    nPesIni   := ZIG->ZIG_PESINI
    cCP       := ZIG->ZIG_CTPATI

    //Valida peso informado/capturado.
    If nPesTot <= 0 
        cMsgError := "Peso inválido."
        U_ADFAT173(cPreFx + cMsgError, cNmOrdem, "", "GUARDIAN")
        Help(Nil, Nil, "Função ADFAT171(ADFAT017P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    //Posiciona no registro de pátio selecionado.
    If ! U_ADFAT17U(cCP)
        cMsgError := "Controle de pátio " + cCP + " não localizado."
        U_ADFAT173(cPreFx + cMsgError, cNmOrdem, "", "GUARDIAN")
        Help(Nil, Nil, "Função ADFAT171(ADFAT017P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    cRotPesa  := ZIB->ZIB_CODROT
    cTpMovi   := ZIB->ZIB_TPMOVI
    lOutras   := cTpMovi == "O"
    lEntrada  := cTpMovi == "E"
    lRacao    := cTpMovi == "R"
    lSaida    := cTpMovi == "S"

    //Localiza ordem de pesagem.
    If ! U_ADFAT16A(cNmOrdem)
        cMsgError := "Ordem de pesagem " + cNmOrdem + " não localizada."
        U_ADFAT173(cPreFx + cMsgError, cNmOrdem, "", "GUARDIAN")
        Help(Nil, Nil, "Função ADFAT171(ADFAT017P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIF

    cProdSAG   := ZIF->ZIF_PRDSAG
    cProdPro   := ZIF->ZIF_PRDPRO
    cProduto   := U_ADFAT176(cProdSAG, cProdPro)
    cEnvBar    := ZIF->ZIF_ENVBAR

    //Localiza roteiro de pesagem.
    If ! U_ADFAT15B(cRotPesa)
        cMsgError := "Roteiro de pesagem " + cRotPesa + " não localizado."
        U_ADFAT173(cPreFx + cMsgError, cNmOrdem, "", "GUARDIAN")
        Help(Nil, Nil, "Função ADFAT171(ADFAT017P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    lEnsacado  := ZI9->ZI9_ENSACA == "1"
    lLacre     := ZI9->ZI9_LACRE == "1"

    //Valida pesagem manual.
    If cManual == "1" .And. ! chkLiMan(cTicket, cNmOrdem, cPlaca, cProduto, nQtdOrd, nPesTot, @cSolPesMan)       
        RestArea(aArea)
        Return .F.

    EndIf

    If lRet

        //Pesagem final.
        If nTpPesa == 2

            //Rotina para executar corte automático na ordem de pesagem e pedido de venda.
            lRet := lRet .And. U_ADFAT17R(cRotPesa, cNmOrdem, cProdSAG, @nQtdOrd, cTicket, nPesoLiq, @cMsgError)

            //Obtém dados de quebra da pesagem.
            If lRet .And. U_ADFAT177(cRotPesa, cCP, cProdSAG, nQtdOrd, nPesIni, nPesoLiq, @aDdSeq, @cMsgError)

                //Valida dados de quebra da pesagem.
                lRet := U_ADFAT17T(aDdSeq, cPlaca, cTicket, cNmOrdem, @nTpSeq, @cAcaSeq, @cMsgError)

            Else
                lRet := .F.

            EndIf

            //Valida se há apontamento para produtos ensacados.
            If lRet .And. lEnsacado .And. ! U_ADFAT178(cRotPesa, cCP, cNmOrdem)
                nTpSeq := 3 
                cAcaSeq:= "R"

            EndIf

            //Valida se há apontamento de lacre.
            If lRet .And. lLacre .And. ! U_ADFAT17F(cRotPesa, cCP, cNmOrdem)
                nTpSeq := 2
                cAcaSeq:= "R"

            EndIf

        EndIf
        
        lSequestra := nTpSeq > 0
            
        If lOutras //Fluxo do tipo "Outras".
            lRet := lRet .And. U_ADFAT17D(cBalanca, cTicket, cRotPesa, nTpPesa, cRotPesa, cCP, cProdSAG, nQtdOrd, nPesoLiq,;
                            cPesAuto, cManual, nPesTot, aDdPAnt, cNmOrdem, cTpMovi, lEnsacado, aDdSeq, nTpSeq,;
                            lSequestra, cAcaSeq, lLacre, cEnvBar, @cMsgError)

        ElseIf lEntrada //Fluxo do tipo "Entrada".
            lRet := U_ADFAT17C(cBalanca, cTicket, cRotPesa, nTpPesa, cRotPesa, cCP, cProdSAG, nQtdOrd, nPesoLiq,;
                            cPesAuto, cManual, nPesTot, aDdPAnt, cNmOrdem, cTpMovi, lEnsacado, aDdSeq, nTpSeq,;
                            lSequestra, cAcaSeq, lLacre, cEnvBar, @cMsgError)

        ElseIf lRacao //Fluxo do tipo "Ração".
            lRet := U_ADFAT17B(cBalanca, cTicket, cRotPesa, nTpPesa, cRotPesa, cCP, cProdSAG, nQtdOrd, nPesoLiq,;
                            cPesAuto, cManual, nPesTot, aDdPAnt, cNmOrdem, cTpMovi, lEnsacado, aDdSeq, nTpSeq,;
                            lSequestra, cAcaSeq, lLacre, cEnvBar, @cMsgError)

        ElseIf lSaida //Fluxo do tipo "Saída".
            lRet := U_ADFAT17E(cBalanca, cTicket, cRotPesa, nTpPesa, cRotPesa, cCP, cProdSAG, nQtdOrd, nPesoLiq,;
                            cPesAuto, cManual, nPesTot, aDdPAnt, cNmOrdem, cTpMovi, lEnsacado, aDdSeq, nTpSeq,;
                            lSequestra, cAcaSeq, lLacre, cEnvBar, @cMsgError)

        Else
            lRet := .F.
            cMsgError := "ADFAT017P - ADFAT171 - Tipo de roteiro de pesagem não informado."

        EndIf

    EndIf

    If ! lRet
        U_ADFAT173(cPreFx + cMsgError, cNmOrdem, "", "GUARDIAN")
        Help(Nil, Nil, "Função ADFAT171(ADFAT017P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        cMsgError += "ADFAT171(ADFAT017P)-" + cMsgError 

    Else
        U_ADFAT173(cPreFx + Iif(nTpPesa == 1, "Primeira", "Segunda") + " pesagem realizada", cNmOrdem, "", "PROTHEUS")

        //Envia registro de pesagem para o Gemba. ******* Deixar o envio para o Gemba como última operação. ***********
        If lRacao .And. lGemba .And. nTpPesa == 1

            envGemba(cCP)

        ElseIf lRacao .And. lGemba .And. nTpPesa == 2

            //Envia a pesagem final para o Gemba.
            If ! U_ADFAT50N(cNmOrdem, @cMsgError) 
                U_ADFAT173("Envio de pesagem final: " + cMsgError, cNmOrdem, "", "GEMBA")

            EndIf

        EndIf

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} envGemba
    Envia as ordem de pesagem para o Gemba.
    @type  User Function
    @author Everson
    @since 17/05/2022
    @version 01
/*/
Static Function envGemba(cCP, cMsgError)

    //Variáveis.
    Local aArea  := GetArea()
    Local cPreFx := "Envio OP: "
    
    Default cMsgError := ""

    DbSelectArea("ZIF")
    ZIF->(DbSetOrder(1))
    ZIF->(DbGoTop())
    If ! ZIF->( DbSeek( FWxFilial("ZIF") + cCP ) )
        U_ADFAT173(cPreFx + "ordem de pesagem não localizada pelo controle de pátio " + cCP + ".", ZIF->ZIF_NUMERO, "", "GEMBA")
        RestArea(aArea)
        Return Nil

    EndIf

    While ! ZIF->(Eof()) .And. ZIF->ZIF_FILIAL == FWxFilial("ZIF") .And. ZIF->ZIF_CTPATI == cCP

        If chkEnGemba(ZIF->ZIF_NUMERO)
            ZIF->(DbSkip())
            Loop

        EndIF

        cMsgError := ""
        procEnvGb(ZIF->ZIF_NUMERO, @cMsgError)

        ZIF->(DbSkip())

    End

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} procEnvGb
    Process envio de ordem de pesagem para o Gemba.
    @type  User Function
    @author Everson
    @since 18/05/2022
    @version 01
/*/
Static Function procEnvGb(cNmOrdem, cMsgError)
    
    //Variáveis.
    Local aArea  := GetArea()
    Local lRet   := .F.
    Local cPreFx := "Envio OP: "

    Default cMsgError := ""

    lRet := U_ADFAT50F(cNmOrdem, @cMsgError)

    If ! lRet
        U_ADFAT173(cPreFx + cMsgError, cNmOrdem, "", "GEMBA")

    Else
        U_ADFAT173(cPreFx + "enviada com sucesso.", cNmOrdem, "", "GEMBA")

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} chkEnGemba
    Verifica se a ordem de pesagem já foi enviada para o Gemba.
    @type  User Function
    @author Everson
    @since 17/05/2022
    @version 01
/*/
Static Function chkEnGemba(cNmOrdem)

    //Variáveis.
    Local aArea  := GetArea()
    Local lRet   := .F.
    Local cQuery := ""

    cQuery := "SELECT ZBE_DATA FROM " + RetSqlName("ZBE") + " (NOLOCK) AS ZBE WHERE ZBE_FILIAL = '" + FWxFilial("ZBE") + "' AND ZBE_PARAME = '" + cNmOrdem + "' AND ZBE_LOG = 'enviada com sucesso.' AND ZBE.D_E_L_E_T_ = ''"

    If Select("D_CHKZBE") > 0
        D_CHKZBE->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_CHKZBE"
    DbSelectArea("D_CHKZBE")
    D_CHKZBE->(DbGoTop())
    If ! D_CHKZBE->(Eof())
        lRet := .T.

    EndIf

    D_CHKZBE->(DbCloseArea())

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT17T
    Valida os dados de quebra da pesagem.
    @type  User Function
    @author Everson
    @since 30/03/2022
    @version 01
/*/
User Function ADFAT17T(aDdSeq, cPlaca, cTicket, cNmOrdem, nTpSeq, cAcaSeq, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local cPreFx    := "Qbr Pesagem: "

    Default cAcaSeq   := ""
    Default cMsgError := ""

    If Len(aDdSeq) > 0 .And. ! aDdSeq[1][1]

        cAcaSeq := aDdSeq[1][2]

        If cAcaSeq <> "L" 

            If chkLibSq(cTicket)
                U_ADFAT173(cPreFx + "Pesagem com quebra com liberação de sequestro", cNmOrdem, "", "PROTHEUS")

            Else
                nTpSeq := 1

            EndIf

        Else
            cAcaSeq := ""
            U_ADFAT173(cPreFx + "Pesagem com quebra de peso liberada pelo cadastro de roteiro", cNmOrdem, "", "PROTHEUS")

        EndIf

    EndIf

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} ADFAT17R
    Efetua corte na ordem de pesagem e pedido de saída.
    @type  User Function
    @author Everson
    @since 24/03/2022
    @version 01
/*/
User Function ADFAT17R(cRotPesa, cNmOrdem, cProdSAG, nQtdOrd, cTicket, nPesoLi, cMsgError)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.

    If nQtdOrd < nPesoLi
        RestArea(aArea)
        Return .T.

    EndIf

    DbSelectArea("ZIA")
    ZIA->(DbSetOrder(2))
    If ! ZIA->( DbSeek( FWxFilial("ZIA") + cRotPesa + cProdSAG))
        RestArea(aArea)
        Return .T.

    EndIf

    If ZIA->ZIA_COAUTO <> "1" //Verifica se o item pode ser cortado.
        RestArea(aArea)
        Return .T.

    EndIf

    Begin Transaction

        If ! U_ADFAT165(cNmOrdem, "ZIF_QUANT", nPesoLi) //Altera quantidade na ordem de pesagem.
            DisarmTransaction()
            Break

        EndIf

        If ! U_ADFAT191(cTicket, "ZIG_PESORD", nPesoLi) //Altera a quantidade da ordem no ticket de pesagem.
            DisarmTransaction()
            Break

        EndIf

        If ! cortaPed(cNmOrdem, nPesoLi, @cMsgError) //Altera a quantidade do pedido de saída.
            DisarmTransaction() 
            Break

        EndIf

        nQtdOrd := nPesoLi

        lRet := .T.

    End Transaction

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} cortaPed
    Altera a quantidade do pedido de saída.
    @type  User Function
    @author Everson
    @since 24/03/2022
    @version 01
/*/
Static Function cortaPed(cNmOrdem, nNvQtd1, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local cProduto  := ""
    Local cSgUnMed  := ""
    Local cTpConver := ""
    Local nConversor:= 0
    Local nNvQtd2   := 0
    Local cPedS     := ""
    Local cItem     := ""
    Local cFilter   := ""
	
	DbSelectArea("SC6")
	SC6->(DbSetOrder(17))
	SC6->(DbGoTop())
	If ! SC6->(DbSeek( FwxFilial("SC6") + cNmOrdem ))
		RestArea(aArea)
		Return .T.
			
	EndIf

	If (nNvQtd1 > SC6->C6_QTDVEN)
		cMsgError := "cortaPed - Quantidade de corte maior que quantidade liberada (Qtd Lib " + Transform(SC6->C6_QTDVEN,"@E 999,999,999.999") + ")"
		RestArea(aArea)
		Return .F.
			
	EndIf

    cPedS    := SC6->C6_NUM
    cItem    := SC6->C6_ITEM
    cProduto := SC6->C6_PRODUTO

    DbSelectArea("SC5")
    SC5->(DbSetOrder(1))
    SC5->(DbGoTop())
    If ! SC5->( DbSeek( FwxFilial("SC5") + cPedS ))
        cMsgError := "cortaPed - Pedido " + cPedS + " não localizado na tabela SC5"
		RestArea(aArea)
		Return .F.

    EndIf
	
	DbSelectArea("SC9")
	SC9->(DbSetOrder(1))
	SC9->(DbGoTop())
	If ! SC9->( DbSeek( FWxFilial("SC9") + cPedS + cItem ))
        cMsgError := "cortaPed - Pedido " + cPedS + " não localizado na tabela SC9"
		RestArea(aArea)
		Return .F.

    EndIf

    cSgUnMed := Alltrim(cValToChar(Posicione("SB1",1,xFilial("SB1") + cProduto,"B1_SEGUM")))

    If ! Empty(cSgUnMed)
        
        cTpConver	:= Alltrim(cValToChar(Posicione("SB1",1,xFilial("SB1") + cProduto,"B1_TIPCONV")))
        nConversor	:= Val(cValToChar(Posicione("SB1",1,xFilial("SB1") + cProduto,"B1_CONV")))
        
        If Upper(cTpConver) == 'D'    	
            nNvQtd2 := Int(nNvQtd1 / Iif(nConversor == 0,1,nConversor)) //Divisor.
            
        Else	                                                    
            nNvQtd2 := Int(nNvQtd1 * Iif(nConversor == 0,1,nConversor)) //Multiplicador.
            
        EndIf
    
    EndIf
	
	RecLock("SC9",.F.)
		Replace C9_QTDLIB  With nNvQtd1
		Replace C9_QTDLIB2 With Iif(nNvQtd2 == 0,nNvQtd1,nNvQtd2)
	SC9->(MsUnlock())

    Reclock("SC6",.F.)
        Replace C6_QTDORI  With C6_QTDVEN
        Replace C6_QTDORI2 With C6_UNSVEN
        Replace C6_QTDVEN  With nNvQtd1
        Replace C6_UNSVEN  With Iif(nNvQtd2 == 0,nNvQtd1,nNvQtd2)
        Replace C6_QTDLIB  With nNvQtd1
        Replace C6_QTDLIB2 With Iif(nNvQtd2 == 0,nNvQtd1,nNvQtd2)
        Replace C6_VALOR   With C6_QTDVEN * C6_PRCVEN
        Replace C6_QTDEMP  With nNvQtd1
        Replace C6_QTDEMP2 With Iif(nNvQtd2 == 0,nNvQtd1,nNvQtd2)
        Replace C6_XLIBSAG With "2"
    SC6->(Msunlock())

    lRet := pesTotPed(cPedS, @cMsgError)

    If lRet

    	cFilter := " C6_FILIAL ='" + FWxFilial("SC6") + "' .And. C6_NUM = '" + cPedS + "' "
	
        U_ADFAT27D("SC5", 1, FWxFilial("SC5") + cPedS,;
                "SC6", 1, FWxFilial("SC6") + cPedS, "C6_ITEM",cFilter,;
                "pedidos_de_saida_protheus", "A",;
                .T., .T.,.T., Nil)

    EndIf
		
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} pesTotPed
	Calcula peso do pedido baseado nos itens liberados, ajusta cabeçalho do pedido.
	@type  Static Function
	@author Everson
	@since 24/03/2022
	@version 01
	/*/
Static Function pesTotPed(cPedS, cMsgError)

	//Variáveis.
	Local aArea			:= GetArea()
	Local nTotalVol		:= 0
	Local nTotalPeso	:= 0
	Local nTotalBruto	:= 0
	Local lLibSC6		:= .T.
	
    DbSelectArea("SC5")
    SC5->(DbSetOrder(1))
    SC5->(DbGoTop())
    If ! SC5->(DbSeek(FwxFilial("SC5") + cPedS))
        cMsgError := "pesTotPed - Pedido " + cPedS + " não encontrado na tabela SC5."
        RestArea(aArea)
        Return .F.
        
    EndIf
    
    DbSelectArea("SC6")
    SC6->(DbSetOrder(1))
    SC6->(DbGoTop())
    If ! SC6->(DbSeek(FWxFilial("SC6") + cPedS))
        cMsgError := "pesTotPed - Pedido " + cPedS + " não encontrado na tabela SC6."
        RestArea(aArea)
        Return .F.
        
    EndIf

    DbSelectArea("SC9")
    SC9->(DbSetOrder(1))
    SC9->(DbGoTop())
    If ! SC9->(DbSeek(FWxFilial("SC9") + cPedS))
        cMsgError := "pesTotPed - Pedido " + cPedS + " não encontrado na tabela SC9."
        RestArea(aArea)
        Return .F.
            
    EndIf

    DbSelectArea("SZC")
    SZC->(DbSetOrder(1))
    SZC->(DbGoTop())

    DbSelectArea("SB1")
    SB1->(DbSetOrder(1))
    SB1->(DbGoTop())
    
    While SC9->(! Eof()) .And. FwxFilial("SC9") == Alltrim(cValToChar(SC9->C9_FILIAL )) .And. Alltrim(cValToChar(SC9->C9_PEDIDO)) == cPedS
            
        If ! SB1->(DbSeek(xFilial("SB1") + SC9->C9_PRODUTO))
            cMsgError := "pesTotPed - Produto não encontrado na tabela SB1 " + Alltrim(cValToChar(SC9->C9_PRODUTO))
            RestArea(aArea)
            Return .F.
                        
        EndIf
        
        nTotalVol   := nTotalVol   + SC9->C9_QTDLIB2
        
        nTotalPeso  := nTotalPeso  + SC9->C9_QTDLIB
        
        If SZC->(DbSeek(xFilial("SZC") + SB1->B1_SEGUM))
            nTotalBruto   += SC9->C9_QTDLIB2  * SZC->ZC_TARA
            
        Else
            nTotalBruto   += SC9->C9_QTDLIB
            
        EndIf
        
        DbSelectArea("SC9")
        Reclock("SC9",.F.)
            Replace C9_ROTEIRO With SC5->C5_ROTEIRO
            Replace C9_DTENTR  With SC5->C5_DTENTR
            Replace C9_VEND1   With SC5->C5_VEND1
            Replace C9_PLACA   With SC5->C5_PLACA
        Msunlock()
        
        SC9->(Dbskip())
        
    End
    
    lLibSC6 := U_ADFAT16D(cPedS)

    RecLock("SC5",.F.)
        SC5->C5_PBRUTO  := nTotalBruto + nTotalPeso
        SC5->C5_PESOL   := nTotalPeso
        SC5->C5_VOLUME1 := nTotalVol
        SC5->C5_XLIBSAG	:= Iif(lLibSC6,"2","1")
    SC5->(MsUnlock())
    
	RestArea(aArea)
	
Return .T.
/*/{Protheus.doc} chkLibSq
    Verifica se há liberação de sequestro, para pesagens sequestradas.
    @type  User Function
    @author Everson
    @since 07/03/2022
    @version 01
/*/
Static Function chkLibSq(cTicket)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.

    If U_ADFAT195(cTicket)
        If Alltrim(cValToChar(ZIG->ZIG_TPLSEQ)) <> ""
            lRet := .T.

        EndIf

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT17D
    Fluxo do tipo "Outras".
    @type  User Function
    @author Everson
    @since 25/02/2022
    @version 01
/*/
User Function ADFAT17D(cBalanca, cTicket, cRotPesa, nTpPesa, cRotPesa, cCP, cProdSAG, nQtdOrd, nPesoLiq,;
                       cPesAuto, cManual, nPesTot, aDdPAnt, cNmOrdem, cTpMovi, lEnsacado, aDdSeq, nTpSeq,;
                       lSequestra, cAcaSeq, lLacre, cEnvBar, cMsgError)

    //Variáveis.
    Local aArea      := GetArea()
    Local lRet       := .F.
    Local cStatOrd   := ""
    Local cStatCp    := ""
    
    Default cMsgError:= ""

    If nTpPesa == 1
        cStatOrd := "4"
        cStatCp  := "4"

    ElseIf nTpPesa == 2
        cStatOrd := Iif(lSequestra,"6","5")
        cStatCp  := "5"

    EndIf

    lRet := grvPesagem(cBalanca, cTicket, cRotPesa, cPesAuto, cManual, nTpPesa, nPesTot, aDdPAnt, nTpSeq, lSequestra, cAcaSeq,;
                       nPesoLiq, aDdSeq, cNmOrdem, cStatOrd, cStatCp, cCP, cTpMovi, lEnsacado, lLacre, cEnvBar, @cMsgError)

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT17C
    Fluxo do tipo  "Entrada".
    @type  User Function
    @author Everson
    @since 25/02/2022
    @version 01
/*/
User Function ADFAT17C(cBalanca, cTicket, cRotPesa, nTpPesa, cRotPesa, cCP, cProdSAG, nQtdOrd, nPesoLiq,;
                       cPesAuto, cManual, nPesTot, aDdPAnt, cNmOrdem, cTpMovi, lEnsacado, aDdSeq, nTpSeq,;
                       lSequestra, cAcaSeq, lLacre, cEnvBar, cMsgError)

    //Variáveis.
    Local aArea      := GetArea()
    Local lRet       := .F.
    Local cStatOrd   := ""
    Local cStatCp    := ""

    Default cMsgError:= ""

    If nTpPesa == 1
        cStatOrd := "10"
        cStatCp  := "4"

    ElseIf nTpPesa == 2
        cStatOrd := Iif(lSequestra,"12","11")
        cStatCp  := "5"

    EndIf

    lRet := grvPesagem(cBalanca, cTicket, cRotPesa, cPesAuto, cManual, nTpPesa, nPesTot, aDdPAnt, nTpSeq, lSequestra, cAcaSeq,;
                       nPesoLiq, aDdSeq, cNmOrdem, cStatOrd, cStatCp, cCP, cTpMovi, lEnsacado, lLacre, cEnvBar, @cMsgError)

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT17B
    Fluxo do tipo "Ração".
    @type  User Function
    @author Everson
    @since 24/02/2022
    @version 01
/*/
User Function ADFAT17B(cBalanca, cTicket, cRotPesa, nTpPesa, cRotPesa, cCP, cProdSAG, nQtdOrd, nPesoLiq,;
                       cPesAuto, cManual, nPesTot, aDdPAnt, cNmOrdem, cTpMovi, lEnsacado, aDdSeq, nTpSeq,;
                       lSequestra, cAcaSeq, lLacre, cEnvBar, cMsgError)

    //Variáveis.
    Local aArea      := GetArea()
    Local lRet       := .F.
    Local cStatOrd   := ""
    Local cStatCp    := ""
    
    Default cMsgError:= ""

    If nTpPesa == 1
        cStatOrd := "4"
        cStatCp  := "4"

    ElseIf nTpPesa == 2
        cStatOrd := Iif(lSequestra,"6","5")
        cStatCp  := "5"

    EndIf

    lRet := grvPesagem(cBalanca, cTicket, cRotPesa, cPesAuto, cManual, nTpPesa, nPesTot, aDdPAnt, nTpSeq, lSequestra, cAcaSeq,;
                       nPesoLiq, aDdSeq, cNmOrdem, cStatOrd, cStatCp, cCP, cTpMovi, lEnsacado, lLacre, cEnvBar, @cMsgError)

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT17E
    Fluxo do tipo "Saída".
    @type  User Function
    @author Everson
    @since 25/02/2022
    @version 01
/*/
User Function ADFAT17E(cBalanca, cTicket, cRotPesa, nTpPesa, cRotPesa, cCP, cProdSAG, nQtdOrd, nPesoLiq,;
                       cPesAuto, cManual, nPesTot, aDdPAnt, cNmOrdem, cTpMovi, lEnsacado, aDdSeq, nTpSeq,;
                       lSequestra, cAcaSeq, lLacre, cEnvBar, cMsgError)

    //Variáveis.
    Local lRet := .F.

    If nTpPesa == 1
        cStatOrd := "4"
        cStatCp  := "4"

    ElseIf nTpPesa == 2
        cStatOrd := Iif(lSequestra,"6","5")
        cStatCp  := "5"

    EndIf

    lRet := grvPesagem(cBalanca, cTicket, cRotPesa, cPesAuto, cManual, nTpPesa, nPesTot, aDdPAnt, nTpSeq, lSequestra, cAcaSeq,;
                    nPesoLiq, aDdSeq, cNmOrdem, cStatOrd, cStatCp, cCP, cTpMovi, lEnsacado, lLacre, cEnvBar, @cMsgError)

Return lRet
/*/{Protheus.doc} ADFAT177
    Valida quebra de peso na pesagem.
    @type  User Function
    @author Everson
    @since 01/12/2021
    @version 01
/*/
User Function ADFAT177(cRotPesa, cCP, cProdSAG, nQtdOrd, nPesIni, nPesoLiq, aDdSeq, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local cAcaSeq   := ""
    Local nTolRot   := 0
    Local cUnRot    := ""
    Local nQrbKg    := Abs(nPesoLiq - nQtdOrd)
    Local nQrbPer   := 0
    Local lLib      := .F.
    Local cAnLabo   := ""

    Default cMsgError := ""

    If nQtdOrd > 0
        nQrbPer := (nQrbKg/nQtdOrd) * 100

    Else
        nQrbPer := (nQrbKg/nPesIni) * 100

    EndIf

    If ! U_ADFAT15B(cRotPesa)
        cMsgError := "Roteiro " + cRotPesa + " não encontrado."
        Help(Nil, Nil, "Função ADFAT177(ADFAT019P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    cAcaSeq := ZI9->ZI9_ACINCO
    cUnRot  := ZI9->ZI9_UNTOLE
    nTolRot := ZI9->ZI9_QTTOLE

    DbSelectArea("ZIA")
    ZIA->(DbSetOrder(2))
    ZIA->(DbGoTop())
    If ZIA->(DbSeek( FWxFilial("ZIA") + cRotPesa + cProdSAG ))
        cUnRot  := ZIA->ZIA_UNTOLE
        nTolRot := ZIA->ZIA_QTTOLE
        cAnLabo := ZIA->ZIA_ANLABO
        lLib := ZIA->ZIA_VLDTOL == "2"

    EndIf

    If  ! lLib .And. cUnRot == "KG"
        lLib := nTolRot >= nQrbKg

    ElseIf ! lLib .And. cUnRot == "PC"
        lLib := nTolRot >= nQrbPer

    EndIf

    Aadd(aDdSeq, { lLib, cAcaSeq, cUnRot, nTolRot, (nPesoLiq - nQtdOrd), Iif(nQtdOrd <= 0, 0, ((nPesoLiq - nQtdOrd)/nQtdOrd)) * 100, nQtdOrd })

    RestArea(aArea)
    
Return .T.
/*/{Protheus.doc} ADFAT178
    Valida apontamento de ensacado.
    @type  User Function
    @author Everson
    @since 20/12/2021
    @version 01
/*/
User Function ADFAT178(cRotPesa, cCP, cNmOrdem)

    //Variáveis.
    Local aArea     := GetArea()

    DbSelectArea("ZIL")
    ZIL->(DbSetOrder(3))
    If ZIL->( DbSeek( FWxFilial("ZIL") + cNmOrdem))
        RestArea(aArea)
        Return .T.

    EndIf

    Help(Nil, Nil, "Função ADFAT178(ADFAT017P)", Nil, "Não há apontamento de ensacados para ordem " + cNmOrdem + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    RestArea(aArea)
    
Return .F.
/*/{Protheus.doc} ADFAT17F
    Validação apontamento de lacre.
    @type  User Function
    @author Everson
    @since 20/12/2021
    @version 01
/*/
User Function ADFAT17F(cRotPesa, cCP, cNmOrdem)

    //Variáveis.
    Local aArea     := GetArea()

    DbSelectArea("ZIT")
    ZIT->(DbSetOrder(3))
    If ZIT->( DbSeek( FWxFilial("ZIT") + cNmOrdem))
        RestArea(aArea)
        Return .T.

    EndIf

    Help(Nil, Nil, "Função ADFAT17F(ADFAT017P)", Nil, "Não há apontamento de lacre para ordem " + cNmOrdem + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
    
Return .F.
/*/{Protheus.doc} grvPesagem
    Grava pesagem no ticket de pesagem.
    @type  Static Function
    @author Everson
    @since 25/02/2022
    @version 01
/*/
Static function grvPesagem(cBalanca,;
                           cTicket,;
                           cRotPesa,;
                           cPesAuto,;
                           cManual,;
                           nTpPesa,;
                           nPesTot,;
                           aDdPAnt,;
                           nTpSeq,;
                           lSequestra,;
                           cAcaSeq,;
                           nPesoLiq,;
                           aDdSeq,;
                           cNmOrdem,;
                           cStatOrd,;
                           cStatCp,;
                           cCP,;
                           cTpMovi,;
                           lEnsacado,;
                           lLacre,;
                           cEnvBar,;
                           cMsgError)

    //Variáveis.
    Local aArea         := GetArea()
    Local lRet          := .F.
    Local oTicket       := Nil
    Local aError        := {}
    Local aDOrdR        := {}
    
    Default lEnsacado := .F.
    Default cMsgError := ""

    If ! U_ADFAT195(cTicket)
        cMsgError := "Ticket de pesagem " + cTicket + " não localizado."
        RestArea(aArea)
        Return .F.

    EndIf

    Begin Transaction

        oTicket := FwLoadModel("ADFAT019P")
        oTicket:SetOperation(MODEL_OPERATION_UPDATE)
        oTicket:Activate() 
        
        oTicket:SetValue("MD_MASTER","ZIG_BALANC", cBalanca)
        oTicket:SetValue("MD_MASTER","ZIG_ROTEIR", cRotPesa)
        oTicket:SetValue("MD_MASTER","ZIG_AUTOMA", cPesAuto)
        oTicket:SetValue("MD_MASTER","ZIG_MANUAL", cManual)
        oTicket:SetValue("MD_MASTER","ZIG_ENVBAR", cEnvBar)

        If nTpPesa == 1 //Pesagem inicial.
            oTicket:SetValue("MD_MASTER","ZIG_PESINI", nPesTot)
            oTicket:SetValue("MD_MASTER","ZIG_DTPES1", Date())
            oTicket:SetValue("MD_MASTER","ZIG_HRPES1", Time())
            oTicket:SetValue("MD_MASTER","ZIG_INICIA", "2")

        ElseIf nTpPesa == 2 //Pesagem final.

            If Len(aDdPAnt) > 0
                oTicket:SetValue("MD_MASTER","ZIG_PESINI", aDdPAnt[1][2])
                oTicket:SetValue("MD_MASTER","ZIG_DTPES1", SToD(aDdPAnt[1][3]))
                oTicket:SetValue("MD_MASTER","ZIG_HRPES1", aDdPAnt[1][4])

            EndIf

            oTicket:SetValue("MD_MASTER","ZIG_PESFIM", nPesTot)
            oTicket:SetValue("MD_MASTER","ZIG_DTPES2", Date())
            oTicket:SetValue("MD_MASTER","ZIG_HRPES2", Time())
            oTicket:SetValue("MD_MASTER","ZIG_INICIA", Iif(lSequestra,"4","3"))
            oTicket:SetValue("MD_MASTER","ZIG_PESOLI", nPesoLiq)
            oTicket:SetValue("MD_MASTER","ZIG_UNTOLE", aDdSeq[1][3])
            oTicket:SetValue("MD_MASTER","ZIG_QTTOLE", aDdSeq[1][4])
            oTicket:SetValue("MD_MASTER","ZIG_QUEBRA", aDdSeq[1][5])
            oTicket:SetValue("MD_MASTER","ZIG_TPSEQU", cValToChar(nTpSeq))
            oTicket:SetValue("MD_MASTER","ZIG_ACASEQ", cAcaSeq)

        EndIf

        If oTicket:VldData()
            oTicket:CommitData()

            If ! U_ADFAT175(cNmOrdem, cStatOrd, 1, @cMsgError) //Atualiza status da ordem.
                DisarmTransaction()
                Break

            EndIf

            If nTpPesa == 2 .And. lLacre .And. ! U_ADFAT165(cNmOrdem, "ZIF_STATLC", "P", @cMsgError) //Atualiza status do controle de lacre da ordem de pesagem.
                DisarmTransaction()
                Break

            EndIf

            If nTpPesa == 2 .And. ! Empty(ZIF->ZIF_ORDRAC) //Atualiza status da ordem de carregamento de ração.

                Aadd(aDOrdR,{"ZIR_STATUS", "4"})

                If ! U_ADFAT32D(ZIF->ZIF_ORDRAC, aDOrdR, @cMsgError)//Atualiza status do controle de lacre da ordem de pesagem.
                    DisarmTransaction()
                    Break

                EndIf

            EndIf

            If nTpPesa == 1 .And. ! U_ADFAT174(cCP, "ZIB_STATUS", cStatCp, @cMsgError) //Pesagem inicial, atualiza status do controle de pátio.
                DisarmTransaction()
                Break

            ElseIf nTpPesa == 2
            
                If chkLiTOrd(cCP, cTpMovi, .T.)

                    If ! U_ADFAT174(cCP, "ZIB_STATUS", cStatCp, @cMsgError) //Pesagem final, verifica se todas as ordens vinculadas ao controle de pátio estão encerradas para encerrar o controle de pátio.
                        DisarmTransaction()
                        Break
                        
                    EndIf

                EndIf

            EndIf

            If nTpPesa == 2 .And. lEnsacado .And. ! U_ADEST735(cNmOrdem, 3, "ZIL_PESADO", "1", @cMsgError) //Marca conferência de ensacado como pesada.
                DisarmTransaction()
                Break

            EndIf

            lRet := .T.

        Else
            aError := oTicket:GetErrorMessage()
            cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

        EndIf

    End Transaction

    If Empty(cMsgError) .And. lSequestra
        cMsgError := "Pesagem sequestrada."

    EndIf

    oTicket:DeActivate()
    oTicket:Destroy()
    oTicket := Nil

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} chkLiTOrd
    Verifica se todas as ordens vinculadas ao controle de pátio estão encerradas.
    @type  Static Function
    @author Everson
    @since 15/12/2021
    @version 01
/*/
Static Function chkLiTOrd(cCP, cTpOrdem, lChkTkt)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .T.
    Local cStatus   := ""

    Default lChkTkt := .T.

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(2))
    ZIG->(DbGoTop())

    DbSelectArea("ZIF")
    ZIF->(DbSetOrder(1))
    ZIF->(DbGoTop())
    ZIF->(DbSeek( FWxFilial("ZIF") + cCP ))
    While ! ZIF->(Eof()) .And. ZIF->ZIF_FILIAL == FWxFilial("ZIF") .And. ZIF->ZIF_CTPATI == cCP
        
        //Verifica se há ticket de pesagem.
        If lChkTkt .And. ! ZIG->(DbSeek( FWxFilial("ZIG") + ZIF->ZIF_NUMERO ))
            ZIF->(DbSkip())
            Loop

        EndIf

        cStatus := Alltrim(cValToChar(ZIF->ZIF_STATUS ))

        If cTpOrdem == "O" .And. (! (cStatus $"5/6/7") .Or.; //Encerrada/Sequestrada/Sequestro liberado.
            (Alltrim(cValToChar(ZIG->ZIG_ACASEQ)) <> "" .And. ZIG->ZIG_ACASEQ <> "S" .And. Alltrim(cValToChar(ZIG->ZIG_TPLSEQ)) == "") ) //Sequestrada sem liberação automática e sem aprovação.
            lRet := .F.
            Exit

        ElseIf cTpOrdem == "E" .And. (! (cStatus $"11/12/13") .Or.; //Encerrada/Sequestrada/Sequestro liberado.
            (Alltrim(cValToChar(ZIG->ZIG_ACASEQ)) <> "" .And. ZIG->ZIG_ACASEQ <> "S" .And. Alltrim(cValToChar(ZIG->ZIG_TPLSEQ)) == "") ) //Sequestrada sem liberação automática e sem aprovação.
            lRet := .F.
            Exit

        ElseIf cTpOrdem == "S" .And. (! (cStatus $"5/6/7") .Or.; //Encerrada/Sequestrada/Sequestro liberado.
            (Alltrim(cValToChar(ZIG->ZIG_ACASEQ)) <> "" .And. ZIG->ZIG_ACASEQ <> "S" .And. Alltrim(cValToChar(ZIG->ZIG_TPLSEQ)) == "") ) //Sequestrada sem liberação automática e sem aprovação.
            lRet := .F.
            Exit

        ElseIf cTpOrdem == "R" .And. (! (cStatus $"5/6/7") .Or.; //Encerrada/Sequestrada/Sequestro liberado.
            (Alltrim(cValToChar(ZIG->ZIG_ACASEQ)) <> "" .And. ZIG->ZIG_ACASEQ <> "S" .And. Alltrim(cValToChar(ZIG->ZIG_TPLSEQ)) == "") ) //Sequestrada sem liberação automática e sem aprovação.
            lRet := .F.
            Exit

        EndIf

        ZIF->(DbSkip())

    End

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} chkLiMan
    Verifica se a pesagem manual está liberada.
    @type  Static Function
    @author Everson
    @since 29/11/2021
    @version 01
/*/
Static Function chkLiMan(cTicket, cNmOrdem, cPlaca, cProduto, nQtdOrd, nPesTot, cSolPesMan)

    //Variáveis.
    Local lRet := .F.

    If chkRgLib(@cSolPesMan)
        lRet := .T.
        Return lRet

    Endif

    DbSelectArea("ZIK")
    ZIK->(DbSetOrder(2))
    If ! ZIK->( DbSeek(FWxFilial("ZIK") +  cTicket))

        criaSolLiM(cTicket, cNmOrdem, cPlaca, cProduto, nQtdOrd, nPesTot, @cSolPesMan)
        If Empty(cSolPesMan)
            Help(Nil, Nil, "Função chkLiMan(ADFAT017P)", Nil, "Não foi possível criar a solicitação de pesagem manual.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        
        EndIf
        Return .F.

    EndIf

    cSolPesMan := ZIK->ZIK_NUMERO

    If Alltrim(cValToChar(ZIK->ZIK_STATUS)) == "1"
        Help(Nil, Nil, "Função chkLiMan(ADFAT017P)", Nil, "A solicitação " + ZIK->ZIK_NUMERO + " não está aprovada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return lRet

    EndIf

    If Alltrim(cValToChar(ZIK->ZIK_STATUS)) == "3"
        Help(Nil, Nil, "Função chkLiMan(ADFAT017P)", Nil, "A solicitação " + ZIK->ZIK_NUMERO + " está reprovada. Inicie uma nova pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return lRet

    EndIf

    lRet := .T.

Return lRet
/*/{Protheus.doc} chkRgLib
    Verifica range de data/hora de liberação de pesagem manual.
    @type  Static Function
    @author Everson
    @since 29/11/2021
    @version 01
/*/
Static Function chkRgLib(cSolPesMan)

    //Variáveis.
    Local lRet := .F.
    Local cQuery := " SELECT TOP 1 * FROM " + RetSqlName("ZIK") + " (NOLOCK) AS ZIK WHERE ZIK_FILIAL = '" + FWxFilial("ZIK") + "' AND ZIK_RDATA + ZIK_RHORA >= '" + DToS(Date()) + Time() + "' AND ZIK.D_E_L_E_T_ = '' ORDER BY ZIK_NUMERO "
    If Select("D_TOTL") > 0
        D_TOTL->(DbCloseArea())
    EndIf
    TcQuery cQuery New Alias "D_TOTL"
    DbSelectArea("D_TOTL")
        If ! D_TOTL->(Eof())
            cSolPesMan := D_TOTL->ZIK_NUMERO
            lRet := .T.
        EndIf
    D_TOTL->(DbCloseArea())

Return lRet
/*/{Protheus.doc} criaSolLiM
    Cria solicitação de liberação de pesagem manual.
    @type  Static Function
    @author Everson
    @since 29/11/2021
    @version 01
/*/
Static Function criaSolLiM(cTicket, cNmOrdem, cPlaca, cProduto, nQtdOrd, nPesTot, cSolPesMan)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oSolMan   := FwLoadModel("ADFAT021P")
    Local cMotivo   := ""
    Local cDescMot  := ""
    Local cMsgError := ""

    If ! Pergunte("ZIC0101", .T.)
        RestArea(aArea)
        Return .F.

    EndIf

    cMotivo := MV_PAR01
    cDescMot := Posicione("ZIC",1, FWxFilial("ZIC") + cMotivo, "ZIC_DESC")

    oSolMan:SetOperation(MODEL_OPERATION_INSERT)
    oSolMan:Activate() 

    oSolMan:SetValue("MD_MASTER","ZIK_TICKET" , cTicket)
    oSolMan:SetValue("MD_MASTER","ZIK_ORDEM"  , cNmOrdem)
    oSolMan:SetValue("MD_MASTER","ZIK_PLACA"  , cPlaca)
    oSolMan:SetValue("MD_MASTER","ZIK_PRODUT" , cProduto)
    oSolMan:SetValue("MD_MASTER","ZIK_QTDORD" , nQtdOrd)
    oSolMan:SetValue("MD_MASTER","ZIK_PESMAN" , nPesTot)
    oSolMan:SetValue("MD_MASTER","ZIK_MOTIVO" , cMotivo)
    oSolMan:SetValue("MD_MASTER","ZIK_MOTDES" , cDescMot)
    oSolMan:SetValue("MD_MASTER","ZIK_NMSOLI" , cUserName)

    If oSolMan:VldData()
        oSolMan:CommitData()
        lRet := .T.
        cSolPesMan := ZIK->ZIK_NUMERO
        MsgInfo("Solicitação gerada " + cSolPesMan + ".","criaSolLiM(ADFAT017P")

    Else
        lRet := .F.
        aError := oSolMan:GetErrorMessage()
        cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

    EndIf

    oSolMan:DeActivate()
    oSolMan:Destroy()
    oSolMan := Nil

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função criaSolLiM(ADFAT017P)", Nil, "Erro na geração de solicitação de pesagem manual." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} exSolLiM
    Exclui solicitação de liberação de pesagem manual.
    @type  Static Function
    @author Everson
    @since 29/11/2021
    @version 01
/*/
Static Function exSolLiM(cSolPesMan)

    //Variáveis.
    Local aArea     := GetArea()
    Local oSolMan   := Nil
    Local cMsgError := ""

    DbSelectArea("ZIK")
    ZIK->(DbSetOrder(1))
    If ! ZIK->( DbSeek( FWxFilial("ZIK") + cSolPesMan ) )
        RestArea(aArea)
        Return Nil

    EndIf

    oSolMan := FwLoadModel("ADFAT021P")
    oSolMan:SetOperation(MODEL_OPERATION_DELETE)
    oSolMan:Activate() 

    If oSolMan:VldData()
        oSolMan:CommitData()

    Else
        aError := oSolMan:GetErrorMessage()
        cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

    EndIf

    oSolMan:DeActivate()
    oSolMan:Destroy()
    oSolMan := Nil

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função exSolLiM(ADFAT017P)", Nil, "Erro na exclusão de solicitação de pesagem manual." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} obtPeso
    Obtém peso da balança serial.
    @type  Static Function
    @author Everson
    @since 23/11/2021
    @version 01
/*/
Static Function obtPeso(aParBal)

    //Variáveis.
    Local nPeso    := 0
    Local aConfig  := {}

    If Len(aParBal) <= 0
         Help(Nil, Nil, "Função obtPeso(ADFAT017P)", Nil, "Não há balança selecionada." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    Aadd(aConfig,aParBal[1,1])
    Aadd(aConfig,aParBal[1,2])
    Aadd(aConfig,aParBal[1,3])
    Aadd(aConfig,aParBal[1,4])

    AGRX003A(@nPeso, .F., aConfig, /*cMask*/, .F.)

Return nPeso
/*/{Protheus.doc} ADFAT17H
    Obtém situação da ordem de pesagem.
    @type  User Function
    @author Everson
    @since 24/11/2021
    @version 01
/*/
User Function ADFAT17H(cTpOrdem, cStatus, cCodSeq)
    
    //Variáveis.
    Local aSituacao := U_ADFAT161(cTpOrdem, cStatus)

Return aSituacao
/*/{Protheus.doc} ADFAT175
    Atualiza status da ordem de pesagem.
    @type  User Function
    @author Everson
    @since 24/11/2021
    @version 01
/*/
User Function ADFAT175(cNmOrdem, cStatus, nStatus, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local cNmOrAgr  := ""

    Default cMsgError := ""
    
    If ! U_ADFAT16A(cNmOrdem)

        ZIF->(DbSetOrder(3))
        If ! ZIF->(DbSeek( FWxFilial("ZIF") + cNmOrdem ))
            cMsgError := "Ordem de pesagem " + cNmOrdem + " não encontrada."
            Help(Nil, Nil, "Função ADFAT175(ADFAT017P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
            RestArea(aArea)
            Return lRet

        Else
            cNmOrdem := ZIF->ZIF_NUMERO

        EndIf

    EndIf

    cNmOrAgr := Alltrim(cValToChar(ZIF->ZIF_AGRUPA))

    Begin Transaction

        lRet := U_ADFAT164(cNmOrdem, cStatus, nStatus, cMsgError)
        If ! lRet
            DisarmTransaction()
            Break

        EndIf

        If lRet .And. ! Empty(cNmOrAgr)

            DbSelectArea("ZIF")
            ZIF->(DbSetOrder(3))
            If ZIF->(DbSeek( FWxFilial("ZIF") + cNmOrAgr))

                While ! ZIF->(Eof()) .And. ZIF->ZIF_FILIAL == FWxFilial("ZIF") .And. ZIF->ZIF_AGRUPA == cNmOrAgr

                    lRet := U_ADFAT164(ZIF->ZIF_NUMERO, cStatus, nStatus, cMsgError)

                    If ! lRet
                        DisarmTransaction()
                        Break

                    EndIf

                    ZIF->(DbSkip())

                End

            EndIf

        EndIf

    End Transaction

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT174
    Atualiza controle de pátio.
    @type  User Function
    @author Everson
    @since 25/11/2021
    @version 01
/*/
User Function ADFAT174(cCP, cCampo, xValor, cMsgError)

    //Variáveis.
    Local lRet      := .F.
    Local oModel    := Nil
    
    Default cMsgError := ""
    
    //Posiciona no registro de pátio selecionado.
    If ! U_ADFAT17U(cCP)
        cMsgError := "Controle de pátio " + cCP + " não encontrado."
        Help(Nil, Nil, "Função ADFAT174(ADFAT017P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    oModel := FwLoadModel("ADFAT017P")
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:Activate()
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
        Help(Nil, Nil, "Função ADFAT174(ADFAT017P)", Nil, "Erro na atualização de registro de controle de pátio." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

Return lRet
/*/{Protheus.doc} ADFAT17W
    Obtém a quantidade de tickets vinculados ao controle de pátio.
    @type  User Function
    @author Everson
    @since 25/11/2021
    @version 01
/*/
User Function ADFAT17W(cCP)

    //Variáveis.
    Local nNum   := 0
    Local cQuery := " SELECT COUNT(ZIG_NUMERO) AS TOTTKT FROM " + RetSqlName("ZIG") + " AS ZIG (NOLOCK) WHERE ZIG_FILIAL = '" + FWxFilial("ZIG") + "' AND ZIG_CTPATI = '" + cCP + "' AND ZIG.D_E_L_E_T_ = '' "

    If Select("QTDTKT") > 0
        QTDTKT->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "QTDTKT"
    DbSelectArea("QTDTKT")
        nNum := Val(cValToChar(QTDTKT->TOTTKT))
    QTDTKT->(DbCloseArea())

Return nNum
/*/{Protheus.doc} lerTag
    Leitura de tag para pesagem.
    @type  Static Function
    @author Everson
    @since 26/11/2021
    @version 01
/*/
Static Function lerTag(oView, lAtuView, cCP)

    //variáveis.
    Local aArea     := GetArea()
    Local oObj      := TSocketClient():New()
    Local nPort     := 0
    Local cIp       := ""
    Local nTEspC    := 10000
    Local nResp     := -1
    Local nTEspR    := 10000
    Local cTag      := ""
    Local cErro     := ""   
    Local aDdConn   := {}

    Default cCP     := ""

    If Empty(cCP) .And. ValType(oView) == "O"
        cCP := FWFldGet("ZIB_NUMERO") 

    EndIf      

    oDdLeitor:Get(cLeitor, @aDdConn)

    If Len(aDdConn) <= 0 
        Help(Nil, Nil, "Função lerTag(ADFAT017P)", Nil, "Parâmetros do leitor não informados.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    cIp   := aDdConn[1]
    nPort := aDdConn[2] 
    
    FWMsgRun(, {|oSay| nResp := oObj:Connect( nPort,cIp, nTEspC ) }, "Função lerTag(ADFAT017P)",;
                "Conectando " + cLeitor + " (" + cIp + " " + cValToChar(nPort) + ")...")        
     
    If(!oObj:IsConnected())
        Help(Nil, Nil, "Função lerTag(ADFAT017P)", Nil, "Não foi possível estabelecer conexão.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil 

    EndIf 
    
    FWMsgRun(, {|oSay| nResp := oObj:Receive( @cTag, nTEspR ) }, "Função lerTag(ADFAT017P)",;
                "Leitura... " + cLeitor + " (" + cIp + " " + cValToChar(nPort) + ")...")    

    If nResp < 0
        oObj:GetError(@cErro)
        Help(Nil, Nil, "Função lerTag(ADFAT017P)", Nil, "Ocorreu erro na leitura dos dados." + xPula + cValToChar(cErro) , 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf 
 
    oObj:CloseConnection()

    cTag := Alltrim(cValToChar(StrTran(StrTran(cTag,Chr(2),""),Chr(3),"")))

    If lAtuView
        If !Empty(cTag) .And.;
            chkTag(cTag, cCP) //Verifica se a tag de pesagem não está em uso.
            FWFldPut("ZIB_TAG",cTag)
            oView:lModify := .T.

        EndIf
        
        oView:Refresh()

    EndIf

    RestArea(aArea)

Return cTag
/*/{Protheus.doc} chkTag
    Verifica se a tag de pesagem não está em uso.
    @type  Static Function
    @author Everson
    @since 29/11/2021
    @version 01
/*/
Static Function chkTag(cTag, cCP)

    //Variáveis.
    Local lRet      := .T.
    Local cAliasT   := GetNextAlias()
    Local cQuery    := " SELECT ZIB_NUMERO, ZIB_DATA, ZIB_PLACA FROM " + RetSqlName("ZIB") + " (NOLOCK) AS ZIB WHERE ZIB_FILIAL = '" + FWxFilial("ZIB") + "' AND ZIB_TAG = '" + cTag + "' AND ZIB_NUMERO <> '" + cCP + "' AND ZIB_STATUS <> '6' AND D_E_L_E_T_ = '' "

    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.T.,.T.)
    DbSelectArea(cAliasT)
    If ! (cAliasT)->(Eof())
        lRet := .F.
        Help(Nil, Nil, "Função chkTag(ADFAT017P)", Nil, "A tag já está sendo utilizada. " + xPula +;
                                                        "Controle de pátio " + cValToChar((cAliasT)->ZIB_NUMERO) + xPula +;
                                                        "Data " + DToC(SToD((cAliasT)->ZIB_DATA)) + xPula +;
                                                        "Placa " + cValToChar((cAliasT)->ZIB_PLACA), 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
    EndIf
    (cAliasT)->(DbCloseArea())

Return lRet
/*/{Protheus.doc} devoTag
    Devolve tag de pesagem.
    @type  Static Function
    @author Everson
    @since 02/12/2021
    @version 01
/*/
Static Function devoTag(oVecPt, aHVcPt)

    //Variáveis.
    Local aArea         := GetArea()
    Local nLinhaC       := oVecPt:nAt
    Local oModal        := FWDialogModal():New() 
    Local aButtons      := {}   
    Local oContainer    := Nil  
    Local cCP           := ""
    Local cPlaca        := ""
    Local cTagAtual     := ""
    Local cNovaTag      := ""
    Local cFluxo        := ""
    Local cTktProtheus  := ""
    Local lRetSlv       := Nil
    Local cTpMovi       := ""

    If nLinhaC <= 0
        Help(Nil, Nil, "Função devoTag(ADFAT017P)", Nil, "1-Selecione um registro de controle de pátio.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    cCP := oVecPt:aCols[nLinhaC, Ascan(aHVcPt,{|x| AllTrim(x[2]) == "NUMER"})]

    If Empty(cCP)
        Help(Nil, Nil, "Função devoTag(ADFAT017P)", Nil, "2-Selecione um registro de controle de pátio.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    //Posiciona no registro de pátio selecionado.
    If ! U_ADFAT17U(cCP)
        Help(Nil, Nil, "Função devoTag(ADFAT017P)", Nil, "Controle de pátio não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    cTpMovi     := ZIB->ZIB_TPMOVI
    cPlaca      := ZIB->ZIB_PLACA
    cTagAtual   := ZIB->ZIB_TAG
    cFluxo      := Posicione("ZI9", 1, FwxFilial("ZI9") + ZIB->ZIB_CODROT, "ZI9_FXGURD")

    If ZIB->ZIB_STATUS == "6"
        Help(Nil, Nil, "Função devoTag(ADFAT017P)", Nil, "Tag " + cTagAtual + " já devolvida.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    DbSelectArea("ZV4")
    ZV4->(DbSetOrder(1))
    If ZV4->( DbSeek( FWxFilial("ZV4") + cPlaca ) )
        cNovaTag := Alltrim(cValToChar(ZV4->ZV4_TGFIXA))

    EndIf
	
    oModal:SetEscClose(.F.)
	oModal:setTitle("Devolver Tag de Pesagem")
	oModal:setSize( 150 , 130 )
	oModal:createDialog()

    bSalvar := {|| lRetSlv := procDevTag(cTpMovi, cCP, cTagAtual, cNovaTag), Iif(!lRetSlv, Nil, oModal:DeActivate()) }

    Aadd(aButtons,{Nil, "Confimar", bSalvar, "", "", .T., .F.})
    Aadd(aButtons,{Nil,"Cancelar", {|| oModal:DeActivate() },"","",.T.,.F.})

	oModal:addButtons(aButtons)

        oContainer := TPanel():New(025,,, oModal:getPanelMain())
        oContainer:Align := CONTROL_ALIGN_ALLCLIENT

        TSay():New(015,010,{||"Controle de Pátio " + cCP},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,140,010)
        TSay():New(025,010,{||"Fluxo " + cFluxo},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,140,010)
        TSay():New(035,010,{||"Placa " + cPlaca},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,140,010)
        TSay():New(045,010,{||"Ticket Protheus " + cTktProtheus},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,140,010)
        TSay():New(055,010,{||"Tag Atual " + cTagAtual},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,140,010)
        
        TButton():New(070,025,"Ler Tag Devolvida", oContainer,{|| cNovaTag := lerTag(Nil, .F., cCP) },080,15,,,.F.,.T.,.F.,,.F.,{|| .T. },,.F. )
        TGet():New(090,010,{|u|If(PCount() == 0, cNovaTag, cNovaTag := u)},oContainer,110,010,"",{|| .T. },0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cNovaTag",,,,.T.,,,"",1) 

	oModal:Activate()

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} procDevTag
    Processa devolução de tag de pesagem.
    @type  Static Function
    @author Everson
    @since 02/12/2021
    @version 01
/*/
Static Function procDevTag(cTpMovi, cCP, cTagAtual, cNovaTag)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.

    If ! Empty(cTagAtual) .And. Alltrim(cValToChar(cTagAtual)) <> Alltrim(cValToChar(cNovaTag))
        Help(Nil, Nil, "Função procDevTag(ADFAT017P)", Nil, "As tags são diferentes.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    If ! chkLiTOrd(cCP, cTpMovi, .F.) .And. ! MsgYesNo("Há ordens não encerradas vinculadas ao controle de pátio. Deseja prosseguir?", "Função procDevTag(ADFAT017P)")
        RestArea(aArea)
        Return Nil

    EndIf

    Begin Transaction

        //Exclui todos os tickets de pesagem não pesados.
        If ! U_ADFAT17P(cCP)
            DisarmTransaction()
            Break
            
        EndIf

        //Exclui ordens de pesagem do tipo saída não utilizadas.
        If cTpMovi == "S" .And. ! U_ADFAT16B(cCP)
            DisarmTransaction()
            Break
            
        EndIf

        //Altera status do controle de pátio.
        If ! U_ADFAT174(cCP, "ZIB_STATUS", "6") 
            DisarmTransaction()
            Break
            
        EndIf

        lRet := .T.

    End Transaction

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT17P
    Deleta todos os tickets de pesagem não utilizados e vinculados a controle de pátio.
    @type  Static Function
    @author Everson
    @since 23/03/2022
    @version 01
/*/
User Function ADFAT17P(cCP)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .T.

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(5))
    ZIG->(DbGoTop())

    If ZIG->( DbSeek( FWxFilial("ZIG") + cCP ) )

        While ! ZIG->(Eof()) .And. ZIG->ZIG_CTPATI == cCP

            If ZIG->ZIG_INICIA == "1" .And. ! U_ADFAT193(ZIG->ZIG_NUMERO) 
                lRet := .F.
                Exit

            EndIf

            ZIG->(DbSkip())

        End

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} altTag
    Altera tag de pesagem.
    @type  Static Function
    @author Everson
    @since 02/12/2021
    @version 01
/*/
Static Function altTag(oOrdPes, aOrdPes, cBalanca)

    //Variáveis.
    Local aArea         := GetArea()
    Local nLinha        := Val(cValToChar(oOrdPes:nAt))
    Local oModal        := FWDialogModal():New() 
    Local aButtons      := {}   
    Local oContainer    := Nil  
    Local cCP           := ""
    Local cPlaca        := ""
    Local cTagAtual     := ""
    Local cNovaTag      := ""
    Local lRetSlv       := .F.
    Local cFluxo        := ""
    Local cTktGuard     := ""
    Local cTktProtheus  := ""

    If nLinha <= 0 .Or. Len(aOrdPes) <= 0
        Help(Nil, Nil, "Função altTag(ADFAT017P)", Nil, "Não há dados.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    cCP := aOrdPes[nLinha,16]
    If Empty(cCP)
        Help(Nil, Nil, "Função altTag(ADFAT017P)", Nil, "Controle de pátio não selecionado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    //Posiciona no registro de pátio selecionado.
    If ! U_ADFAT17U(cCP)
        Help(Nil, Nil, "Função altTag(ADFAT017P)", Nil, "Controle de pátio não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    cTktGuard   := aOrdPes[nLinha,10]
    cTktProtheus:= aOrdPes[nLinha,11]
    cPlaca      := ZIB->ZIB_PLACA
    cTagAtual   := ZIB->ZIB_TAG
    cFluxo      := Posicione("ZI9", 1, FwxFilial("ZI9") + ZIB->ZIB_CODROT, "ZI9_FXGURD")
	
    oModal:SetEscClose(.F.)
	oModal:setTitle("Alterar Tag de Pesagem")
	oModal:setSize( 150 , 130 )
	oModal:createDialog()
	
    Aadd(aButtons,{Nil,"Confimar",{|| lRetSlv := atuaTag(cBalanca, cCP, cFluxo, cPlaca, cTktProtheus, cNovaTag, cTktGuard), Iif(!lRetSlv, Nil, oModal:DeActivate()) },"","",.T.,.F.})
    Aadd(aButtons,{Nil,"Cancelar", {|| oModal:DeActivate() },"","",.T.,.F.})
	
    oModal:addButtons(aButtons)

        oContainer := TPanel():New(025,,, oModal:getPanelMain())
        oContainer:Align := CONTROL_ALIGN_ALLCLIENT

        TSay():New(005,010,{||"Balança " + cBalanca},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,140,010)
        TSay():New(015,010,{||"Controle de Pátio " + cCP},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,140,010)
        TSay():New(025,010,{||"Fluxo " + cFluxo},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,140,010)
        TSay():New(035,010,{||"Placa " + cPlaca},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,140,010)
        TSay():New(045,010,{||"Ticket Protheus " + cTktProtheus},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,140,010)
        TSay():New(055,010,{||"Tag Atual " + cTagAtual},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,140,010)
        
        TButton():New(070,025,"Ler Tag", oContainer,{|| cNovaTag := lerTag(Nil, .F., cCP) },080,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        TGet():New(090,010,{|u|If(PCount() == 0, cNovaTag, cNovaTag := u)},oContainer,110,010,"",{|| .T. },0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cNovaTag",,,,.T.,,,"",1) 

	oModal:Activate()

    RestArea(aArea)

Return lRetSlv
/*/{Protheus.doc} atuaTag
    Atualiza tag de pesagem.
    @type  Static Function
    @author Everson
    @since 02/12/2021
    @version 01
/*/
Static Function atuaTag(cBalanca, cCP, cFluxo, cPlaca, cTktProtheus, cNovaTag, cTktGuard)

    //Variáveis.
    Local cUrl      := Alltrim(cValToChar(Posicione("DX5" , 1, FwxFilial("DX5") + cBalanca, "DX5_URL")))
    Local cErro     := ""
    Local oRetSolic := Nil
    Local lRetBal   := .F.

    If Empty(cUrl)
        Help(Nil, Nil, "Função atuaTag(ADFAT017P)", Nil, "Url da balança não está definido.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    EndIf

    If Empty(cNovaTag)
        Help(Nil, Nil, "Função atuaTag(ADFAT017P)", Nil, "Tag inválida.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    EndIf

    If ! Empty(cTktGuard)

        FWMsgRun(,{|| lRetBal := U_ADFAT242(cUrl, @oRetSolic, cErro, cPlaca, cPlaca, cNovaTag, cFluxo, cTktProtheus) }, "Função atuaTag(ADFAT017P)",;
                    "Alterando " + cUrl)

        If ! lRetBal
            Help(Nil, Nil, "Função atuaTag(ADFAT017P)", Nil, "Ocorreu erro na alteração da tag." + xPula + cErro, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
            Return .F.

        EndIf

    EndIf
    
    U_ADFAT174(cCP, "ZIB_TAG", cNovaTag)
    
Return .T.
/*/{Protheus.doc} excTag
    Exclui tag de pesagem.
    @type  Static Function
    @author Everson
    @since 02/12/2021
    @version 01
/*/
Static Function excTag(oOrdPes, aOrdPes, cBalanca)

    //Variáveis.
    Local nLinha    := Val(cValToChar(oOrdPes:nAt))
    Local cCP       := ""
    Local lRetBal   := .F.
    Local cErro     := ""
    Local cUrl      := Alltrim(cValToChar(Posicione("DX5" , 1, FwxFilial("DX5") + cBalanca, "DX5_URL")))
    Local cTktGuard := ""

    If Empty(cUrl)
        Help(Nil, Nil, "Função excTag(ADFAT017P)", Nil, "Url da balança não está definido.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    EndIf

    If nLinha <= 0 .Or. Len(aOrdPes) <= 0
        Help(Nil, Nil, "Função excTag(ADFAT017P)", Nil, "Não há dados.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    EndIf

    cCP := aOrdPes[nLinha,16]
    If Empty(cCP)
        Help(Nil, Nil, "Função excTag(ADFAT017P)", Nil, "Controle de pátio não selecionado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    EndIf

    //Posiciona no registro de pátio selecionado.
    If ! U_ADFAT17U(cCP)
        Help(Nil, Nil, "Função excTag(ADFAT017P)", Nil, "Controle de pátio " + cCP + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(Alltrim(cValToChar(ZIB->ZIB_TAG)))
        Help(Nil, Nil, "Função excTag(ADFAT017P)", Nil, "Não há tag associada ao controle de pátio.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    EndIf 

    cTktGuard := aOrdPes[nLinha,10]
    If Empty(cTktGuard)
        Help(Nil, Nil, "Função excTag(ADFAT017P)", Nil, "Ticket Guardian não selecionado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    EndIf

    If ! MsgYesNo("Deseja realizar a exclusão da tag de pesagem vinculada ao ticket Guardian " + cTktGuard + "?","excTag(ADFAT017P)")
        Return .F.

    EndIf

    FWMsgRun(,{|| lRetBal := U_ADFAT249(cUrl,@cErro,cTktGuard,4,"WS G","01") }, "Função excTag(ADFAT017P)",;
                  "Excluindo " + cUrl)

    If ! lRetBal
        Help(Nil, Nil, "Função excTag(ADFAT017P)", Nil, "Ocorreu erro no cancelamento da tag." + xPula + cErro, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    Else
        U_ADFAT174(cCP, "ZIB_STATUS", "6")

    EndIf

Return .T.
/*/{Protheus.doc} impTkt
    Imprimir ticket de pesagem.
    @type  Static Function
    @author Everson
    @since 06/12/2021
    @version 01
/*/
Static Function impTkt(oOrdPes, aOrdPes)

    //Variáveis.
    Local lRet      := .F.
    Local nLinha    := Val(cValToChar(oOrdPes:nAt))
    Local cTicket   := ""

    If nLinha <= 0 .Or. Len(aOrdPes) <= 0
        Help(Nil, Nil, "Função impTkt(ADFAT017P)", Nil, "Não há dados.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    EndIf

    cTicket  := Alltrim(cValToChar(aOrdPes[nLinha,11]))
    cTpOrdem := aOrdPes[nLinha,14]
    If Empty(cTicket)
        Help(Nil, Nil, "Função impTkt(ADFAT017P)", Nil, "Ticket de pesagem não selecionado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    EndIf

    If ! U_ADFAT195(cTicket)
        Help(Nil, Nil, "Função impTkt(ADFAT017P)", Nil, "Ticket de pesagem " + cTicket + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    EndIf

    If (ZIG->ZIG_INICIA == "4" .And. ZIG->ZIG_ACASEQ <> "S") //Sequestro por peso e não liberado.
        Help(Nil, Nil, "Função impTkt(ADFAT017P)", Nil, "Pesagem sequestrada, não é possível imprimir o ticket de pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    EndIf

    MsAguarde({|| lRet := U_ADFAT026R(cTicket, cTpOrdem)}, "Aguarde", "Imprimindo ticket " + cTicket + " (" + cTpOrdem + ")...", .F.)

Return lRet
/*/{Protheus.doc} impTkt
    Imprimir romaneio de carregamento de pedido de venda.
    @type  Static Function
    @author Everson
    @since 25/03/2022
    @version 01
/*/
Static Function impRoPV(oOrdPes, aOrdPes) 

    //Variáveis.
    Local lRet      := .F.
    Local nLinha    := Val(cValToChar(oOrdPes:nAt))
    Local cNmOrdem  := ""

    If nLinha <= 0 .Or. Len(aOrdPes) <= 0
        Help(Nil, Nil, "Função impRoPV(ADFAT017P)", Nil, "Não há dados.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    EndIf

    cTicket  := Alltrim(cValToChar(aOrdPes[nLinha,11]))
    cTpOrdem := aOrdPes[nLinha,14]
    If Empty(cTicket)
        Help(Nil, Nil, "Função impRoPV(ADFAT017P)", Nil, "Ticket de pesagem não selecionado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    EndIf

    If ! U_ADFAT195(cTicket)
        Help(Nil, Nil, "Função impRoPV(ADFAT017P)", Nil, "Ticket de pesagem " + cTicket + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    EndIf

    cNmOrdem := aOrdPes[nLinha,08]
    If Empty(cNmOrdem)
        Help(Nil, Nil, "Função impRoPV(ADFAT017P)", Nil, "Ordem de pesagem não selecionada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    EndIf

    MsAguarde({|| lRet := U_ADFAT026R(cTicket, "IMPRO")}, "Aguarde", "Imprimindo Ordem de Carregamento " + cNmOrdem + "...", .F.)

Return lRet
/*/{Protheus.doc} ADFAT17A
    Gera ordem de pesagem do tipo "Ração".
    @type  Static Function
    @author Everson
    @since 23/02/2022
    @version 01
/*/
User Function ADFAT17A(cCP, cPlaca)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .T.
    Local cQuery    := ""
    Local aDados    := {}
    Local cNvOrdP   := ""

    //Verifica se o controle de pátio está encerrado.
    If U_ADFAT17L(cCP)
        RestArea(aArea)
        Return .T.
        
    EndIf

    cQuery += " SELECT * " 
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("ZIR") + " (NOLOCK) AS ZIR " 
    cQuery += " WHERE " 
    cQuery += " ZIR_FILIAL = '" + FWxFilial("ZIR") + "' " 
    cQuery += " AND ZIR_PLACA = '" + cPlaca + "' " 
    cQuery += " AND ZIR_ORDEM = '' " 
    cQuery += " AND ZIR_STATUS = '2' " 
    cQuery += " AND ZIR_ORAGRP <> '' " 
    cQuery += " AND ZIR_FORNEC <> '' " 
    cQuery += " AND ZIR_LOJA   <> '' " 
    cQuery += " AND ZIR_NOME   <> '' " 
    cQuery += " AND ZIR_LOTPRD <> '' " 
    cQuery += " AND ZIR_PRDSAG <> '' " 
    cQuery += " AND ZIR_PRDPRO <> '' " 
    cQuery += " AND ZIR_QUANT > 0 " 
    cQuery += " AND ZIR.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY ZIR_NUMERO " 

    If Select("D_ZIR") > 0
        D_ZIR->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_ZIR"
    DbSelectArea("D_ZIR")
    D_ZIR->(DbGoTop())

    Begin Transaction

        While ! D_ZIR->(Eof())

            cNvOrdP:= ""
            aDados := {}

            Sleep(Random(0, 2)*1000)

            If U_ADFAT16E(D_ZIR->ZIR_NUMERO)
                D_ZIR->(DbSkip())
                Loop

            EndIf

            //Gera ordem de pesagem.
            If ! U_ADFAT167(@cNvOrdP,;
                           cCP,;
                           cPlaca,;
                           D_ZIR->ZIR_NUMERO,;
                           D_ZIR->ZIR_ORAGRP,;
                           D_ZIR->ZIR_FORNEC,;
                           D_ZIR->ZIR_LOJA,;
                           D_ZIR->ZIR_INTCOD,;
                           D_ZIR->ZIR_LOTPRD,;
                           D_ZIR->ZIR_PRDSAG,;
                           D_ZIR->ZIR_PRDPRO,;
                           D_ZIR->ZIR_QUANT)

                lRet := .F.
                DisarmTransaction()
                Break

            EndIf

            Aadd(aDados,{"ZIR_ORDEM", cNvOrdP})

            If ! U_ADFAT32D(D_ZIR->ZIR_NUMERO, aDados) //Atribui o número da ordem de pesagem.
                lRet := .F.
                DisarmTransaction()
                Break

            EndIf

            D_ZIR->(DbSkip())

        End

    End Transaction

    D_ZIR->(DbCloseArea())

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT17O
    Gera ordem de pesagem do tipo "Saída".
    @type  Static Function
    @author Everson
    @since 23/03/2022
    @version 01
/*/
User Function ADFAT17O(cCP, cPlaca)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .T.
    Local cQuery    := ""
    Local cNvOrdP   := ""
    Local nQtd      := 0
    Local cMsgError := ""

    //Verifica se o controle de pátio está encerrado.
    If U_ADFAT17L(cCP)
        RestArea(aArea)
        Return .T.
        
    EndIf

    DbSelectArea("SC6")
    SC6->(DbSetOrder(1))
    SC6->(DbGoTop())

    If Select("D_PEDS") > 0
        D_PEDS->(DbCloseArea())

    EndIf

    cQuery += " SELECT  " 
    cQuery += " * " 
    cQuery += " FROM " 
        cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
        cQuery += " INNER JOIN " 
        cQuery += " " + RetSqlName("SC6") + " (NOLOCK) AS SC6 ON " 
        cQuery += " C5_FILIAL = C6_FILIAL " 
        cQuery += " AND C5_NUM = C6_NUM " 
    cQuery += " WHERE " 
        cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "' " 
        cQuery += " AND C5_PLACA  = '" + cPlaca + "' " 
        cQuery += " AND C5_DTENTR >= '" + DToS(Date()) + "' " 
        cQuery += " AND C5_NOTA = '' " 
        cQuery += " AND C5_TIPO = 'N' " 
        cQuery += " AND C6_XORDPES = '' " 
        cQuery += " AND SC5.D_E_L_E_T_ = '' " 
        cQuery += " AND SC6.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY C6_NUM, C6_ITEM " 

    TcQuery cQuery New Alias "D_PEDS"
    DbSelectArea("D_PEDS")
    D_PEDS->(DbGoTop())

    Begin Transaction

        While ! D_PEDS->(Eof())

            cPedido := D_PEDS->C5_NUM

            Sleep(Random(0, 2)*1000)

            If SC6->(DbSeek( FWxFilial("SC6") + cPedido ))

                If ! Empty(SC6->C6_XORDPES)
                    D_PEDS->(DbSkip())
                    Loop

                EndIf

            EndIf

            // Valida se há item com bloqueio por estoque ou financeiro.
            If itemBlc(D_PEDS->C5_NUM)

                While ! D_PEDS->(Eof()) .And. D_PEDS->C5_NUM == cPedido

                    D_PEDS->(DbSkip())

                End
                Loop

            EndIf

            cMsgError := ""
            cNvOrdP   := ""
            cProdSAG  := Posicione("ZIM", 2, FWxFilial("ZIM") + D_PEDS->C6_PRODUTO, "ZIM_PRDSAG")

            If D_PEDS->C6_UM == "KG"
                nQtd := D_PEDS->C6_QTDVEN

            ElseIf D_PEDS->C6_SEGUM == "KG"
                nQtd := D_PEDS->C6_UNSVEN

            Else
                nQtd := C6_QTDVEN

            EndIf

            //Gera ordem de pesagem.
            If ! U_ADFAT168(@cNvOrdP,;
                            D_PEDS->C5_NUM,;
                            D_PEDS->C6_ITEM,;
                            D_PEDS->C6_PRODUTO,;
                            cCP,;
                            D_PEDS->C5_PLACA,;
                            "C",;
                            D_PEDS->C5_CLIENTE,;
                            D_PEDS->C5_LOJACLI,;
                            D_PEDS->C5_NOMECLI,;
                            D_PEDS->C6_XLOTES,;
                            cProdSAG,;
                            D_PEDS->C6_PRODUTO,;
                            nQtd)
                
                lRet := .F.
                DisarmTransaction()
                Break

            EndIf

            D_PEDS->(DbSkip())

        End

    End Transaction

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função ADFAT17O(ADFAT017P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    D_PEDS->(DbCloseArea())

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT17Q
    Deleta ordem de pesagem do tipo "Saída" que não possui pedido de saída vinculado.
    @type  Static Function
    @author Everson
    @since 23/03/2022
    @version 01
/*/
User Function ADFAT17Q(cNmOrdem)

    //Variávies.
    Local aArea := GetArea()
    Local cQuery:= ""

    Default cNmOrdem := ""

    cQuery += " SELECT  " 
    cQuery += " ZIF_NUMERO, C6_XORDPES, ZIF_PLACA, ZIF_CTPATI " 
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("ZIB") + " (NOLOCK) AS ZIB " 
    cQuery += " INNER JOIN " 
    cQuery += " " + RetSqlName("ZIF") + " (NOLOCK) AS ZIF ON " 
    cQuery += " ZIB_FILIAL = ZIF_FILIAL " 
    cQuery += " AND ZIB_NUMERO = ZIF_CTPATI " 
    cQuery += " LEFT OUTER JOIN " 
    cQuery += " " + RetSqlName("SC6") + " (NOLOCK) AS SC6 ON " 
    cQuery += " ZIF_FILIAL = C6_FILIAL " 
    cQuery += " AND ZIF_NUMERO = C6_XORDPES " 
    cQuery += " AND SC6.D_E_L_E_T_ = '' " 
    cQuery += " WHERE " 
    cQuery += " ZIB_FILIAL = '" + FWxFilial("SC6") + "' " 
    cQuery += " AND ZIB_TPMOVI = 'S' " 

    If !Empty(cNmOrdem)
        cQuery += " AND ZIF_NUMERO = '" + cNmOrdem + "' " 

    EndIf

    cQuery += " AND C6_XORDPES IS NULL " 
    cQuery += " AND ZIB.D_E_L_E_T_ = '' " 
    cQuery += " AND ZIF.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY ZIF_NUMERO " 

    If Select("D_EXOS") > 0
        D_EXOS->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_EXOS"
    DbSelectArea("D_EXOS")
    D_EXOS->(DbGoTop())

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(2))
    ZIG->(DbGoTop())

    While ! D_EXOS->(Eof())

        If ! U_ADFAT179(D_EXOS->ZIF_PLACA, D_EXOS->ZIF_CTPATI, "", .F.) //Verifica se há controla de pátio aberto para placa informada.
            D_EXOS->(DbSkip())
            Loop

        EndIf

        If ZIG->( DbSeek( FWxFilial("ZIG") + D_EXOS->ZIF_NUMERO ) ) .And. ZIG->ZIG_INICIA == "1" .And. ! U_ADFAT172(ZIG->ZIG_CTPATI, D_EXOS->ZIF_NUMERO , ZIG->ZIG_NUMERO, "S", .F.)
            D_EXOS->(DbSkip())
            Loop

        EndIf

        U_ADFAT16C(D_EXOS->ZIF_NUMERO)

        D_EXOS->(DbSkip())
        
    End

    D_EXOS->(DbCloseArea())

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} Static Function itemBlc
	Valida se há item com bloqueio por estoque ou financeiro.
	@type  Static Function
	@author Everson
	@since 23/03/2022
	@version 01
/*/
Static Function itemBlc(cPedS)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.

    DbSelectArea("SC9")
    SC9->(DbsetOrder(1))
    SC9->(DbGoTop())

    If ! SC9->( DbSeek( FWxFilial("SC9") + cPedS ) )
        lRet := .T.

    Else

        While ! SC9->(Eof()) .And. SC9->C9_FILIAL == FWxFilial("SC9") .And. SC9->C9_PEDIDO == cPedS

            If ! Empty(SC9->C9_BLEST) .Or. ! Empty(SC9->C9_BLCRED)
                lRet := .T.
                Exit

            EndIf

            SC9->(DbSkip())

        End
    
    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT17U
	Posiciona no registro de pátio selecionado.
	@type  User Function
	@author Everson
	@since 04/03/2022
	@version 01
/*/
User Function ADFAT17U(cCP)

    //Variáveis.

    DbSelectArea("ZIB")
    ZIB->(DbSetOrder(1))
    ZIB->(DbGoTop())
    If ! ZIB->( DbSeek( FWxFilial("ZIB") + cCP ) )
        Return .F.

    EndIf

Return .T.
/*/{Protheus.doc} Static Function ADFAT17L
	Verifica se o controle de pátio está encerrado.
	@type  User Function
	@author Everson
	@since 04/03/2022
	@version 01
/*/
User Function ADFAT17L(cCP)

    //Variáveis.
    Local aArea := GetArea()

    //Posiciona no registro de pátio selecionado.
    If ! U_ADFAT17U(cCP)
        RestArea(aArea)
        Return .T.

    EndIf

    If ZIB->ZIB_STATUS $cpEncerrado
        RestArea(aArea)
        Return .T.

    EndIf

    RestArea(aArea)

Return .F.
/*/{Protheus.doc} Static Function chkVldSq
	Verifica se há ticket de pesagem com sequência menor que a selecionada.
	@type  Static Function
	@author Everson
	@since 04/03/2022
	@version 01
/*/
Static Function chkVldSq(cCP, cTicket)

    //Variáveis.
    Local aArea   := GetArea()
    Local lRet    := .F.
    Local nSeqTkt := Val(cValToChar(Posicione("ZIG", 1, FWxFilial("ZIG") + cTicket, "ZIG_SEQTKT")))
    Local nSeqMr  := nSeqTkt
    Local cTktMr  := ""

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(5))
    ZIG->(DbGoTop())
    If ! ZIG->( DbSeek( FWxFilial("ZIG") + cCP))
         Help(Nil, Nil, "Função chkVldSq(ADFAT017P)", Nil, "Controle de pátio " + cCP + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
         RestArea(aArea)
         Return .T.

    EndIf

    While ! ZIG->(Eof()) .And. ZIG->ZIG_FILIAL == FWxFilial("ZIG") .And. ZIG->ZIG_CTPATI == cCP

        If ZIG->ZIG_NUMERO <> cTicket .And. Val(cValToChar(ZIG->ZIG_SEQTKT)) < nSeqMr .And. ZIG->ZIG_INICIA == "1"
            nSeqMr := Val(cValToChar(ZIG->ZIG_SEQTKT))
            cTktMr := ZIG->ZIG_NUMERO 

        EndIf

        ZIG->(DbSkip())
        
    End
    
    If ! Empty(cTktMr)
        lRet := .T.
        Help(Nil, Nil, "Função chkVldSq(ADFAT017P)", Nil, "O ticket de pesagem " + cTktMr + " possui sequência de pesagem anterior ao ticket selecionado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} Static Function ADFAT173
	Gera log ZBE
	@type  Static Function
	@author Everson
	@since 24/02/2022
	@version 01
/*/
User Function ADFAT173(cMsg, cParam, cLog, cModulo)

    //Variáveis.

    Default cMsg    := ""
    Default cParam  := ""
    Default cLog    := ""
    Default cModulo := "FATURAMENTO"

	RecLock("ZBE", .T.)
		Replace ZBE_FILIAL 	   	With FWxFilial("ZBE")
		Replace ZBE_DATA 	   	With msDate()
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With cMsg
		Replace ZBE_PARAME	    With cParam
        Replace ZBE_LOGMEM	    With cLog
		Replace ZBE_MODULO	    With cModulo
		Replace ZBE_ROTINA	    With "ADFAT017P" 
	ZBE->( msUnlock() )

Return Nil
/*/{Protheus.doc} ADFAT17
    Ponto de entrada.
    @type  User Function
    @author Everson
    @since 25/03/2022
    @version 01
/*/
User Function ADFAT17()

    //Variáveis.
    Local aArea     := GetArea()
	Local aParam	:= PARAMIXB
	Local xRet 		:= .T.
	Local oObj 		:= ""
	Local cIdPonto 	:= ""
	Local cIdModel 	:= ""
    Local oModelx   := Nil
    Local nOperation:= 0
    Local cNumero   := ""
    Local cTpMovi   := ""
    Local cPlaca    := ""

	If aParam <> Nil

		oObj 	    := aParam[1]
		cIdPonto    := aParam[2]
		cIdModel    := aParam[3]
        nOperation  := oObj:GetOperation()

		If cIdPonto == "MODELCOMMITNTTS"

            oModelx := FWModelActive()
            cNumero := oModelx:GetValue("MD_MASTER", "ZIB_NUMERO")
            cTpMovi := oModelx:GetValue("MD_MASTER", "ZIB_TPMOVI")
            cPlaca  := oModelx:GetValue("MD_MASTER", "ZIB_PLACA")

            If nOperation == MODEL_OPERATION_INSERT
                cOperacao := "I"

                If cTpMovi == "O"
                    U_ADFAT169(cNumero, cPlaca) //Gera ordem de pesagem do tipo "Outras".

                ElseIf cTpMovi == "S"
                    U_ADFAT17O(cNumero, cPlaca) //Gera ordem de pesagem do tipo "Saída".

                ElseIf cTpMovi == "R"
                    U_ADFAT17A(cNumero, cPlaca) //Gera ordem de pesagem do tipo "Ração".

                EndIf

            ElseIf nOperation == MODEL_OPERATION_UPDATE
                cOperacao := "A"

            ElseIf nOperation == MODEL_OPERATION_DELETE
                cOperacao := "D"

            EndIf

            If ! Empty(cOperacao) .And. ! Empty(cNumero)
                grvBarr(cOperacao, cNumero)

            EndIf

		EndIf

	EndIf

    RestArea(aArea)

Return xRet
/*/{Protheus.doc} grvBarr
    Salva o registro para enviar ao barramento.
    @type  User Function
    @author Everson
    @since 25/03/2022
    @version 01
/*/
Static Function grvBarr(cOperacao, cNumero)

    //Variáveis.
    Local aArea := GetArea()

	U_ADFAT27C("ZIB", 1, "controle_de_patio_protheus", cOperacao, FWxFilial("ZIB") + cNumero)

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} grvBarr
    Retorna o código da balança em uso.
    @type  User Function
    @author Everson
    @since 30/03/2022
    @version 01
/*/
User Function ADFAT17V()
Return cBalanca
/*/{Protheus.doc} grvBarr
    Retorna a URL do web service da balança em uso.
    @type  User Function
    @author Everson
    @since 30/03/2022
    @version 01
/*/
User Function ADFAT17X()
Return Alltrim(cValToChar(Posicione("DX5" , 1, FwxFilial("DX5") + U_ADFAT17V(), "DX5_URL")))
