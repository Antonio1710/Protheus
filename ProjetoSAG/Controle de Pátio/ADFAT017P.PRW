#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"

Static cTbMast  := "ZIB"
Static cTitulo  := "Controle de Pátio"
Static cTiMast  := "Dados do Controle de Pátio"
Static xPula    := Chr(13) + Chr(10)
Static oDdLeitor:= Nil
Static cLeitor  := ""

PUBLISH USER MODEL REST NAME controlesdepatio

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

    If FWIsAdmin() .And. MsgNoYes("Abrir cadastro?", "Cadastro x Controle de Pátio(ADFAT017P)")
        oBrowse := FwLoadBrw("ADFAT017P")
        oBrowse:Activate()
        Return Nil

    EndIf

    contlPatio()

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
    Local dData      := oModel:GetValue("MD_MASTER", "ZIB_DATA")
    Local cHora      := oModel:GetValue("MD_MASTER", "ZIB_HORA")
    Local cUsuario   := oModel:GetValue("MD_MASTER", "ZIB_USUARI")
    Local cTpMovi    := oModel:GetValue("MD_MASTER", "ZIB_TPMOVI")
    Local cPlaca     := oModel:GetValue("MD_MASTER", "ZIB_PLACA")
    Local cNmOrdem   := Alltrim(cValToChar(Posicione("ZIF",1, FWxFilial("ZIF") + cCP, "ZIF_NUMERO")))
    Local cStatus    := oModel:GetValue("MD_MASTER", "ZIB_STATUS")

    If lRet .And. cTpMovi == "O" .And. ( nOperation == MODEL_OPERATION_INSERT .Or. (nOperation == MODEL_OPERATION_UPDATE .And. Empty(cNmOrdem)))
        lRet := U_ADFT161(cCP, dData, cHora, cUsuario, cPlaca)

    EndIf

    If lRet .And. (cTpMovi == "R" .Or. cTpMovi == "S") .And. (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)
        
        If ! ExistCpo("ZV4", cPlaca, 1)
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT017P)", Nil, "Cadastro do veículo " + cPlaca + " não encontrado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

    EndIf

    If lRet .And. nOperation == MODEL_OPERATION_DELETE

        If ! Empty(cNmOrdem)
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT017P)", Nil, "Há a ordem de pesagem " + cNmOrdem + " vinculada ao controle de pátio.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

    EndIf

    If lRet .And. nOperation == MODEL_OPERATION_UPDATE

        If cStatus == "1" .And. contTkt(cCP) > 0 //Voltar ao status inicial, com mais de um ticket vinculado.            
            oModel:SetValue("MD_MASTER", "ZIB_STATUS", ZIB->ZIB_STATUS)

        EndIf

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

	oView:AddUserButton("Ler Tag","",{|oView| lerTag(oView, .T.) } ,"",, {MODEL_OPERATION_INSERT ,MODEL_OPERATION_UPDATE} , .T. )   

Return oView
/*/{Protheus.doc} selecBal
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
/*/{Protheus.doc} contlPatio
    @type  Static Function
    Interface do Controle de Pátio.
    @author Everson
    @since 18/11/2021
/*/
Static Function contlPatio()

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
    //Local oTagDev    := Nil
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
    Local oTxtAtu    := Nil
    Local cBalanca   := ""
    Local oGrpOBtn   := Nil
    Local oAttTBtn   := Nil
    Local oEnBaBtn   := Nil
    Local oPesSBtn   := Nil
    Local oPesMBtn   := Nil
    Local oImpTkt    := Nil
    Local oCanTkt    := Nil
    Local oDevTag    := Nil
    Local oAltTag    := Nil
    Local oExcTag    := Nil

    Local oPnMaster  := Nil
    Local oOrdPes    := Nil
    //Local lMarker    := .T.
    Local aOrdPes    := {}
    Local oLeitores  := Nil
    Local aDdBalAut  := {}
    Local aLeitores  := {}
    Local aParBal    := {}
    Local lPesaAut   := {}

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
    
    bLOrd  := {|| Iif(Val(cValToChar(oVecPt:nAt)) > 0, carOrdens(oVecPt:nAt, oVecPt, aHVcPt, @oOrdPes, @aOrdPes, cTpOP, aTpOrdem, aStatLb, dDtIni, dDtFim), Eval(bApgOrd)) }

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

        oTxtAtu := TSay():New(005,005,{||""},oCtlPatio,,,,,,.T.,CLR_RED,CLR_WHITE,100,010)
        TGet():New(013,010,{|u|If(PCount() == 0,nTmpRef,nTmpRef := u)},oCtlPatio,020,010,"@E 99",{|| Iif(Val(cValToChar(nTmpRef)) >= 10,Nil,Help(Nil, Nil, "Função atrTicket(ADFAT017P)", Nil, "Digite um número maior ou igual a 10.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})), Val(cValToChar(nTmpRef)) >= 10  },0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nTmpRef",,,,.T.,,,"Interv.(seg)",2) 
		
        cTagDev := aTagDev[1]
	    oTagDev := TComboBox():New(003,065,{|u|if(PCount() > 0 ,cTagDev := u,cTagDev)},;
	    aTagDev,040,15,oCtlPatio,,{|| },,,,.T.,,,,,,,,,"cTagDev","Exi Tag Dev",1)
       
        oDtIni := TGet():New(003,110,{|u|If(PCount() == 0,dDtIni,dDtIni := u)},oCtlPatio,070,010,"@D",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtIni",,,,.T.,,,"Data Inicial",1) 

        oDtFim := TGet():New(003,185,{|u|If(PCount() == 0,dDtFim,dDtFim := u)},oCtlPatio,070,010,"@D",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtFim",,,,.T.,,,"Data Final",1) 

		cTpOP := aTpOP[1]
	    oTpOP := TComboBox():New(003,260,{|u|if(PCount() > 0 ,cTpOP := u,cTpOP)},;
	    aTpOP,100,15,oCtlPatio,,{|| },,,,.T.,,,,,,,,,"cTpOP","Tipo de Ordem",1)

        oPlaca := TGet():New(003,365,{|u|If(PCount() == 0,cPlaca,cPlaca := u)},oCtlPatio,050,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cPlaca",,,,.T.,,,"Placa",1) 

        oProduto := TGet():New(003,420,{|u|If(PCount() == 0,cProduto,cProduto := u)},oCtlPatio,050,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cProduto",,,,.T.,,,"Produto",1) 

        TButton():New(010,475,"Filtrar",oCtlPatio,{||;
            MsAguarde({|| Eval(bCarCP),;
                          Eval(bLOrd) }, "Aguarde", "Carregando registros...");
        },035,011,,,.F.,.T.,.F.,,.F.,,,.F. )

        // oTxtAtu := TSay():New(005,525,{||""},oCtlPatio,,,,,,.T.,CLR_RED,CLR_WHITE,100,010)
        // TGet():New(015,525,{|u|If(PCount() == 0,nTmpRef,nTmpRef := u)},oCtlPatio,020,010,"@E 99",{|| Iif(Val(cValToChar(nTmpRef)) >= 10,Nil,Help(Nil, Nil, "Função atrTicket(ADFAT017P)", Nil, "Digite um número maior ou igual a 10.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})), Val(cValToChar(nTmpRef)) >= 10  },0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nTmpRef",,,,.T.,,,"Interv.(seg)",2) 
       
        //TGroup():New(030,513,265,597,"",oCtlPatio,,,.T.)
            TButton():New(030,515,"Ad Veículo" ,oCtlPatio,{|| addVeic(), Eval(bCarCP),;
                                                                                Eval(bLOrd) },037,15,,,.F.,.T.,.F.,,.F.,,,.F. )

            TButton():New(030,557,"Alt CP" ,oCtlPatio,{|| altCP(oVecPt, aHVcPt), Eval(bCarCP),;
                                                                                Eval(bLOrd) },037,15,,,.F.,.T.,.F.,,.F.,,,.F. )
            
            TButton():New(050,515,"Central XML"       ,oCtlPatio,{|| U_CENTNFEXM() },080,15,,,.F.,.T.,.F.,,.F.,,,.F. )
            TButton():New(070,515,"Emitir NF"         ,oCtlPatio,{|| },080,15,,,.F.,.T.,.F.,,.F.,,,.F. )

        Aadd(aHVcPt,{" ","LEG"    	,"@BMP"     ,001, 0,.T.,"","","","R","","",.F.,"V","","","",""})
        Aadd(aHVcPt,{"Número" 	    ,"NUMER","" ,006, 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Operação" 	,"OPERA","" ,030, 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Placa" 		,"PLACA","" ,007, 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Produto" 	    ,"PRODU","" ,008, 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Ordem" 	    ,"ORDEM","" ,008, 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Data/Hora" 	,"DTHR" ,"" ,020, 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Tag" 		    ,"TAG"  ,"" ,008, 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"N Tag" 	    ,"NTAG" ,"" ,030, 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Situação" 	,"SITUA","" ,025, 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Motorista" 	,"MOTO" ,"" ,008, 0,"","" ,"C","",""})
        			
        oVecPt := MsNewGetDados():New(030,005,155,510,,"Allwaystrue()","Allwaystrue()","",{},Nil,999,Nil,Nil,Nil,oCtlPatio,aHVcPt,@aColsVcPt)
        oVecPt:oBrowse:bLDblClick := {|| carOrdens(oVecPt:nAt, oVecPt, aHVcPt, @oOrdPes, @aOrdPes, cTpOP, aTpOrdem, aStatLb, dDtIni, dDtFim) }
        
        TGroup():New(157,005,200,155,"Balança | Leitor",oCtlPatio,,,.T.)
            TButton():New(165,010,"SB",oCtlPatio,{|| aLeitores := {}, selecBal(.T., @aParBal, @aDdBalAut, @aLeitores), lPodPesar := ! aParBal[1,4], lPesaAut := aDdBalAut[1,1], cBalanca := aParBal[1,1], oLeitores:SetItems(aLeitores),Iif(Len(aLeitores) <=0 , Nil, cLeitor := aLeitores[1]), oLeitores:Refresh(), Eval(bAtuBtn) },020,15,,,.F.,.T.,.F.,,.F.,,,.F. )	
            TGet():New(165,032,{|u|If(PCount() == 0,cBalanca,cBalanca := u)},oCtlPatio,063,013,"@C",,0,16777215,,.F.,,.T.,,.F.,{|| .F.},.F.,.F.,,.F.,.F. ,,"cBalanca",,,,.T.,,,"",1)
            oLeitores := TComboBox():New(165,100,{|u|if(PCount() > 0 ,cLeitor := u,cLeitor)},;
            aLeitores,050,15,oCtlPatio,,{|| },,,,.T.,,,,,,,,,"cLeitor","",1)

        oGrpOBtn := TButton():New(165,160,"Agrupar Ordem"   ,oCtlPatio,{|| dfAgpOrd(oOrdPes, aOrdPes, aTpOrdem),  Eval(bLOrd)  },045,15,,,.F.,.T.,.F.,,.F.,,,.F. )	
        oGrpOBtn:lActive := .F.
        oAttTBtn := TButton():New(165,210,"Atribuir Ticket" ,oCtlPatio,{|| atrTicket(oOrdPes, aOrdPes), Eval(bLOrd), Eval(bCarCP) },045,15,,,.F.,.T.,.F.,,.F.,,,.F. )	       
        oEnBaBtn := TButton():New(165,290,"Env. Balança"    ,oCtlPatio,{|| envBlcAut(oOrdPes, aOrdPes, cBalanca), Eval(bLOrd), Eval(bCarCP) },045,15,,,.F.,.T.,.F.,,.F.,,,.F. )	
        oPesSBtn := TButton():New(165,340,"Pes. Semiaut"    ,oCtlPatio,{|| pesaSemAut(.F., @aParBal, oOrdPes, aOrdPes), Eval(bLOrd), Eval(bCarCP) },045,15,,,.F.,.T.,.F.,,.F.,,,.F. )	
        oPesMBtn := TButton():New(165,390,"Pes. Manual"     ,oCtlPatio,{|| pesaManu(@aParBal, oOrdPes, aOrdPes), Eval(bLOrd), Eval(bCarCP) },045,15,,,.F.,.T.,.F.,,.F.,,,.F. )	
        oImpTkt  := TButton():New(165,465,"Imprimir Ticket" ,oCtlPatio,{|| impTkt(oOrdPes, aOrdPes) },045,15,,,.F.,.T.,.F.,,.F.,,,.F. )	
                
        oPnMaster := TPanel():New(182,005,,oCtlPatio,,,,,,505,100)
 
        oOrdPes := FwBrowse():New()
        oOrdPes:setOwner(oPnMaster)
        oOrdPes:setDataArray()
        oOrdPes:setArray(aOrdPes)
        oOrdPes:disableConfig()
        oOrdPes:disableReport()
    
        // oOrdPes:AddMarkColumns({|| IIf(aOrdPes[oOrdPes:nAt,01], "LBOK", "LBNO")},;
        //                           {|| selecReg(oOrdPes, @aOrdPes)},;
        //                           {|| selecTReg(oOrdPes, @aOrdPes, @lMarker) })

        oOrdPes:AddStatusColumns({||corOrdP( aOrdPes[oOrdPes:nAt,14], aOrdPes[oOrdPes:nAt,17] )})
    
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
        oOrdPes:addColumn({"Sol Pes Manual"    , {||aOrdPes[oOrdPes:nAt,20]}, "C", ""                  , 2, 010    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,20]",, .F., .T., , "ID20" })
    
        oOrdPes:Activate()

        oCanTkt := TButton():New(182,515,"Cancelar Ticket" ,oCtlPatio,{|| cancTkt(oOrdPes, aOrdPes), Eval(bLOrd), Eval(bCarCP) },080,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        oDevTag := TButton():New(202,515,"Devolver Tag"    ,oCtlPatio,{|| devoTag(oOrdPes, aOrdPes, cBalanca), Eval(bLOrd), Eval(bCarCP) },080,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        oAltTag := TButton():New(222,515,"Alterar Tag"     ,oCtlPatio,{||  altTag(oOrdPes, aOrdPes, cBalanca) , Eval(bLOrd), Eval(bCarCP) },080,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        oExcTag := TButton():New(242,515,"Excluir Tag"     ,oCtlPatio,{||  excTag(oOrdPes, aOrdPes, cBalanca) , Eval(bLOrd), Eval(bCarCP) },080,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        
        oFechar := TButton():New(270,555,"Fechar",oCtlPatio,{|| oCtlPatio:End() },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )
        oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")	

        oTimer := TTimer():New(nTmpRef * 1000, {|| Eval(bCarCP),;
                                                   Eval(bLOrd) }, oCtlPatio)

        oTimer:Activate()

    oCtlPatio:Activate(,,,.T.,{||.T.},, {|| Eval(bCarCP), Eval(bLOrd), Eval(bAtuBtn) })

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} corOrdP
    Retorna a cor de status da ordem de pesagem.
    @type  Static Function
    @author Everson
    @since 18/11/2021
    @version 01
/*/
Static Function corOrdP(cTpOrdem, cStatus)

    //Variáveis.
    Local aSituacao := getStOP(cTpOrdem, cStatus)

Return aSituacao[1,3]
/*/{Protheus.doc} carInit
    Carga de veículo no controle de pátio.
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
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "OPERA" })] := D_VEIC->ZI9_ROTEIR
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "PLACA" })] := D_VEIC->ZIB_PLACA
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "PRODU" })] := getDesPrd(D_VEIC->ZIB_NUMERO)
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "ORDEM" })] := ""
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "DTHR"  })] := DToC(SToD(D_VEIC->ZIB_DATA)) + " " + D_VEIC->ZIB_HORA
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "TAG"   })] := Iif(!Empty(Alltrim(cValtoChar(D_VEIC->ZIB_TAG))),"Sim","Não")
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "NTAG"  })] := D_VEIC->ZIB_TAG
        
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
    Retorna produtos da carga para o controle de pátio.
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

        If ! Empty(Alltrim(cValToChar(D_PRD->B1_DESC))) .And. !(Alltrim(cValToChar(D_PRD->B1_DESC)) $cDescPrd)
            cDescPrd += Alltrim(cValToChar(D_PRD->B1_DESC)) + ", "

        EndIf

        D_PRD->(DbSkip())

    End
    D_PRD->(DbCloseArea())

    If ! Empty(cDescPrd)
        cDescPrd := Substr(cDescPrd,1,Len(cDescPrd)-2)

    EndIf

Return cDescPrd
/*/{Protheus.doc} addVeic
    Incluir veículo no controle de pátio.
    @type  Static Function
    @author Everson
    @since 18/11/2021
    @version 01
/*/
Static Function addVeic()

    FWExecView("Adicionar Veículo", "ADFAT017P", 3)
    
Return Nil
/*/{Protheus.doc} altCP
    Altera controle de pátio.
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

    If ! Empty(cNmOrdem)
        Help(Nil, Nil, "Função altCP(ADFAT017P)", Nil, "Controle de pátio " + cCP +" está vinculado à ordem de pesagem " + cNmOrdem + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    DbSelectArea("ZIB")
    ZIB->(DbSetOrder(1))
    If ! ZIB->(DbSeek( FWxFilial("ZIB") + cCP))
        Help(Nil, Nil, "Função altCP(ADFAT017P)", Nil, "Controle de pátio " + cCP + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    FWExecView("Adicionar Veículo", "ADFAT017P", 4)

    RestArea(aArea)
    
Return Nil
/*/{Protheus.doc} selecReg
    Marca registro.
    @type  Static Function
    @author Everson
    @since 22/11/2021
    @version 01
/*/
Static Function selecReg(oBrowse, aArquivo)

    aArquivo[oBrowse:nAt,01] := !aArquivo[oBrowse:nAt,1]
    oBrowse:Refresh()

Return Nil
/*/{Protheus.doc} selecTReg
    Marca todos os registros.
    @type  Static Function
    @author Everson
    @since 22/11/2021
    @version 01
/*/
Static Function selecTReg(oBrowse, aArquivo, lMarker)

    //Variáveis.
    Local nAux := 1

    For nAux := 1 to len(aArquivo)
        aArquivo[nAux,01] := lMarker

    Next

    oBrowse:Refresh()
    lMarker:=!lMarker

Return Nil
/*/{Protheus.doc} carOrdens
    Carga de ordens de pesagem.
    @type  Static Function
    @author Everson
    @since 18/11/2021
    @version 01
/*/
Static Function carOrdens(nLinha, oVecPt, aHVcPt, oOrdPes, aOrdPes, cTpOP, aTpOrdem, aStatLb, dDtIni, dDtFim)

    //Variáveis.
    Local aArea	    := GetArea()
    Local cCP       := Alltrim(cValToChar(oVecPt:aCols[nLinha][aScan(aHVcPt,{|x| Alltrim(cValToChar(x[2])) == "NUMER"})]))
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

        cForn    := (cQryT3)->ZIF_FORNEC + " " + (cQryT3)->ZIF_LJFORN + " " + (cQryT3)->ZIF_NMFOR
        cProd    := U_ADFT176((cQryT3)->ZIF_PRDSAG, (cQryT3)->ZIF_PRDPRO)
        nPTpOrd  := AScan(aTpOrdem, {|x| Alltrim(cValToChar(x[2])) == Alltrim(cValToChar((cQryT3)->ZIF_TPMOVI))})
        nStatLab := AScan(aStatLb, {|x| Alltrim(cValToChar(x[2]))  == Alltrim(cValToChar((cQryT3)->ZIF_STATLA))})
        cAgrupada:= Iif(Alltrim(cValToChar((cQryT3)->ZIF_EAGRUP))  == "1","Sim", Iif(Alltrim(cValToChar((cQryT3)->ZIF_EAGRUP))  == "2","Não",""))
        aSituacao:= getStOP((cQryT3)->ZIF_TPMOVI, Alltrim(cValToChar((cQryT3)->ZIF_STATUS)))
            
        cTktGua := ""
        cTicket := ""
        cSeqTkt := ""
        nQtdAgr := 0
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
            aSituacao[1,2],;        //12-Situação.
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
            cNmLote;                //25-Nome do lote.
        })
    
        (cQryT3)->(dbSkip())

    End

    (cQryT3)->(dbCloseArea())

    oOrdPes:setArray(aOrdPes)
    oOrdPes:Refresh()

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} dfAgpOrd
    Define o agrupamento as ordens.
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
    Local cTpOrdem  := ""
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

    cTpOrdem := aOrdPes[nLinha,14]
    If cTpOrdem  $"O/R"
        Help(Nil, Nil, "Função dfAgpOrd(ADFAT017P)", Nil, "Esse tipo de ordem não pode ser agrupado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    cCP := aOrdPes[nLinha,16]
    If Empty(cCP)
        Help(Nil, Nil, "Função dfAgpOrd(ADFAT017P)", Nil, "Controle de pátio não selecionado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    cTicket := Alltrim(cValToChar(aOrdPes[nLinha,11]))
    If ! Empty(cTicket)
        Help(Nil, Nil, "Função dfAgpOrd(ADFAT017P)", Nil, "Ordem de pesagem está vinculada ao ticket de pesagem " + cTicket + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    carOrdAg(cCP, @aOrdens, aTpOrdem)
    
    If Len(aOrdens) <= 1
        U_ADFT165(cNmOrdem, "ZIF_EAGRUP", "2")
        MsgInfo("Não há ordens de pesagens a serem agrupadas no controle de pátio " + cCP + ".","Função dfAgpOrd(ADFAT017P)")
        Return Nil

    EndIf

    oModal := FWDialogModal():New()        
	oModal:SetEscClose(.F.)
	oModal:setTitle("Agrupamento de Ordens de Pesagem - CP " + cCP)
	oModal:setSize(150, 350)
	oModal:createDialog()
	oModal:addCloseButton(Nil, "Fechar")
    Aadd(aButtons,{Nil,"Confimar",{|| Iif(! prcAgrp(aOrdens), Nil, oModal:DeActivate()) },"","",.T.,.F.})
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
    Processa agrupamento de ordens.
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
    Local cRoteiro  := ""
    Local cNmOrdem  := ""
    Local cTpAgrup  := ""
    Local cPrAgrup  := ""
    Local cAgrupador:= ""
    Local cMsgError := ""
    Local nCountAgrp:= 0

    DbSelectArea("ZIA")
    ZIA->(DbSetOrder(2))
    ZIA->(DbGoTop())

    DbSelectArea("ZIF")
    ZIF->(DbSetOrder(2))
    ZIF->(DbGoTop())

    Begin Transaction

        For nAux := 1 To Len(aOrdens)
                
            cNmOrdem := Alltrim(cValToChar(aOrdens[nAux][3]))

            If ! ZIF->(DbSeek( FWxFilial("ZIF") + cNmOrdem ))
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
                cRoteiro := Posicione("ZIB", 1, FWxFilial("ZIB") + cCP, "ZIB_CODROT")

                If ! ZIA->(DbSeek( FWxFilial("ZIA") + cRoteiro + cProdSAG ))
                    cMsgError := "O produto " + Alltrim(cValToChar(cProdSAG)) + " não pode ser pesado no roteiro " + Alltrim(cValToChar(cRoteiro)) + "."
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

                If ! U_ADFT165(cNmOrdem, "ZIF_AGRUPA", cAgrupador, @cMsgError)
                    DisarmTransaction()
                    Break

                EndIf
            
                If ! U_ADFT165(cNmOrdem, "ZIF_EAGRUP", "1", @cMsgError)
                    DisarmTransaction()
                    Break

                EndIf

                nCountAgrp++

            Else

                If ! U_ADFT165(cNmOrdem, "ZIF_AGRUPA", "", @cMsgError)
                    DisarmTransaction()
                    Break

                EndIf

                If ! U_ADFT165(cNmOrdem, "ZIF_EAGRUP", "2", @cMsgError)
                    DisarmTransaction()
                    Break

                EndIf                

            EndIf

            If Alltrim(cValToChar(ZIF->ZIF_STATLA)) == "1" .And. Empty(Alltrim(cValToChar(ZIF->ZIF_EAGRUP)))

                If ! U_ADFT164(cNmOrdem, "3", 1)
                    DisarmTransaction()
                    Break

                EndIf

            ElseIf Empty(Alltrim(cValToChar(ZIF->ZIF_EAGRUP)))

                If ! U_ADFT164(cNmOrdem, "2", 1)
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
/*/{Protheus.doc} carOrdAg
    Carrega dados para agrupar ordens de pesagem.
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
        cProduto := U_ADFT176(D_AGRO->ZIF_PRDSAG, D_AGRO->ZIF_PRDPRO)
        Aadd(aOrdens,{.F., D_AGRO->ZIF_CTPATI, D_AGRO->ZIF_NUMERO, aTpOrdem[nPTpOrd,3], cProduto, D_AGRO->ZIF_AGRUPA, D_AGRO->ZIF_PRDSAG, D_AGRO->ZIF_PRDPRO})
        
        D_AGRO->(Dbskip())

    End

    D_AGRO->(DbCloseArea())

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFT176
    Obtém descrição do produto.
    @type  User Function
    @author Everson
    @since 09/12/2021
    @version 01
/*/
User Function ADFT176(cCodSAG, cCodProth, nOPc)

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
Static Function atrTicket(oOrdPes, aOrdPes)

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

    cCP      := Alltrim(cValToChar(aOrdPes[nLinha,16]))
    nQuant   := getPesToOr(cNmOrdem)
    
    If cTpOrdem == "O" //Outras.
        gerTkOt(nLinha, oOrdPes, aOrdPes, cCP, cNmOrdem, nQuant)

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

        gerTkEn(nLinha, oOrdPes, aOrdPes, cCP, cNmOrdem, nQuant, lAgrup, cOrdAgrup)

    ElseIf cTpOrdem == "S" //Saída.

        
    ElseIf cTpOrdem == "R" //Ração.
        

    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} vldLote
    Valida lote do produto.
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
    Processa a validação de lote do produto.
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
/*/{Protheus.doc} gerTkOt
    Atribui ticket à ordem do tipo "Outras".
    @type  Static Function
    @author Everson
    @since 22/11/2021
    @version 01
/*/
Static Function gerTkOt(nLinha, oOrdPes, aOrdPes, cCP, cNmOrdem, nQuant)

    //Variáveis.
    Local oTckOt    := Nil
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

    oTckOt := FwLoadModel("ADFAT019P")

    oTckOt:SetOperation(MODEL_OPERATION_INSERT)
    oTckOt:Activate() 

    oTckOt:SetValue("MD_MASTER","ZIG_SEQTKT" ,"1")
    oTckOt:SetValue("MD_MASTER","ZIG_USUARI" ,__cUserId)
    oTckOt:SetValue("MD_MASTER","ZIG_PLACA"  ,cPlaca)
    oTckOt:SetValue("MD_MASTER","ZIG_TRANSP" ,cTransp)
    oTckOt:SetValue("MD_MASTER","ZIG_LJTRAN" ,cLjTransp)
    oTckOt:SetValue("MD_MASTER","ZIG_MOTORI" ,cMotori)
    oTckOt:SetValue("MD_MASTER","ZIG_TAG"    ,cTag)
    oTckOt:SetValue("MD_MASTER","ZIG_TPMOV"  ,"O")
    oTckOt:SetValue("MD_MASTER","ZIG_ORDEM"  ,cNmOrdem)
    oTckOt:SetValue("MD_MASTER","ZIG_CTPATI" ,cCP)
    oTckOt:SetValue("MD_MASTER","ZIG_PESORD" ,nQuant)

    Begin Transaction

        If oTckOt:VldData()
            oTckOt:CommitData()

            If ! U_ADFT175(cNmOrdem, "2", 1) //Atualiza status da ordem.
                DisarmTransaction()
                Break

            EndIf

            If ! U_ADFT174(cCP, "ZIB_STATUS", "3") //Atualiza status do controle de pátio.
                DisarmTransaction()
                Break

            EndIf

            MsgInfo("Ticket de pesagem gerado " + cValToChar(ZIG->ZIG_NUMERO) + ".","gerTkOt(ADFAT017P")

        Else
            aError := oTckOt:GetErrorMessage()
            cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

        EndIf

    End Transaction

    oTckOt:DeActivate()
    oTckOt:Destroy()
    oTckOt := Nil

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função gerTkOt(ADFAT017P)", Nil, "Erro na geração de registro de ticket de pesagem." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

Return Nil
/*/{Protheus.doc} gerTkEn
    Atribui ticket à ordem do tipo "Entrada".
    @type  Static Function
    @author Everson
    @since 13/12/2021
    @version 01
/*/
Static Function gerTkEn(nLinha, oOrdPes, aOrdPes, cCP, cNmOrdem, nQuant, lAgrup, cOrdAgrup)

    //Variáveis.
    Local oTckOt    := Nil
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

    oTckOt := FwLoadModel("ADFAT019P")

    oTckOt:SetOperation(MODEL_OPERATION_INSERT)
    oTckOt:Activate() 

    oTckOt:SetValue("MD_MASTER","ZIG_SEQTKT" ,"1")
    oTckOt:SetValue("MD_MASTER","ZIG_USUARI" ,__cUserId)
    oTckOt:SetValue("MD_MASTER","ZIG_PLACA"  ,cPlaca)
    oTckOt:SetValue("MD_MASTER","ZIG_TRANSP" ,cTransp)
    oTckOt:SetValue("MD_MASTER","ZIG_LJTRAN" ,cLjTransp)
    oTckOt:SetValue("MD_MASTER","ZIG_MOTORI" ,cMotori)
    oTckOt:SetValue("MD_MASTER","ZIG_TAG"    ,cTag)
    oTckOt:SetValue("MD_MASTER","ZIG_TPMOV"  ,"E")
    oTckOt:SetValue("MD_MASTER","ZIG_ORDEM"  ,Iif(lAgrup,cOrdAgrup,cNmOrdem))
    oTckOt:SetValue("MD_MASTER","ZIG_AGRUPA" ,Iif(lAgrup,"1","2"))
    oTckOt:SetValue("MD_MASTER","ZIG_CTPATI" ,cCP)
    oTckOt:SetValue("MD_MASTER","ZIG_PESORD" ,nQuant)

    Begin Transaction

        If oTckOt:VldData()
            oTckOt:CommitData()

            If ! U_ADFT175(cNmOrdem, "8", 1) //Atualiza status da ordem.
                DisarmTransaction()
                Break

            EndIf

            If ! U_ADFT174(cCP, "ZIB_STATUS", "3") //Atualiza status do controle de pátio.
                DisarmTransaction()
                Break

            EndIf

            MsgInfo("Ticket de pesagem gerado " + cValToChar(ZIG->ZIG_NUMERO) + ".","gerTkOt(ADFAT017P")

        Else
            aError := oTckOt:GetErrorMessage()
            cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

        EndIf

    End Transaction

    oTckOt:DeActivate()
    oTckOt:Destroy()
    oTckOt := Nil

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função gerTkOt(ADFAT017P)", Nil, "Erro na geração de registro de ticket de pesagem." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

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
    Local nLinha    := Val(cValToChar(oOrdPes:nAt))
    Local cOrdAgrup := ""
    Local cTicket   := ""
    Local cCP       := ""
    Local cNmOrdem  := ""
    Local cTpOrdem  := ""

    If nLinha <= 0 .Or. Len(aOrdPes) <= 0
        Help(Nil, Nil, "Função cancTkt(ADFAT017P)", Nil, "Não há dados.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    cOrdAgrup := aOrdPes[nLinha,18]
    cTpOrdem := aOrdPes[nLinha,14]
    cTicket  := Alltrim(cValToChar(aOrdPes[nLinha,11]))

    If ! MsgYesNo("Deseja cancelar o ticket de pesagem " + cTicket + "?","cancTkt(ADFAT017P)")
        Return Nil

    EndIf

    cCP     := aOrdPes[nLinha,16]
    cNmOrdem:= aOrdPes[nLinha,08]

    U_ADFT172(cCP, cNmOrdem, cTicket, cTpOrdem)

Return Nil
/*/{Protheus.doc} ADFT172
    Processa cancelamento de ticket de pesagem.
    @type  User Function
    @author Everson
    @since 10/12/2021
    @version 01
/*/
User Function ADFT172(cCP, cNmOrdem, cTicket, cTpOrdem)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oTckOt    := Nil
    Local aError    := {}
    Local cMsgError := ""
    Local cStatOrd  := ""
    Local cStatCp   := ""

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(1))
    If ! ZIG->(DbSeek( FWxFilial("ZIG") + cTicket ))
        Help(Nil, Nil, "Função cancTkt(ADFAT017P)", Nil, "Ticket não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    oTckOt := FwLoadModel("ADFAT019P")
    oTckOt:SetOperation(MODEL_OPERATION_DELETE)
    oTckOt:Activate() 

    Begin Transaction

        If oTckOt:VldData()
            oTckOt:CommitData()

            If cTpOrdem == "O"
                cStatOrd := "1"
                cStatCp  := "1"

            ElseIf cTpOrdem == "E"
                eGetStEn(cNmOrdem, @cStatOrd, @cStatCp)

            ElseIf cTpOrdem == "S"

            ElseIf cTpOrdem == "R"

            EndIf
            
            If ! U_ADFT175(cNmOrdem, cStatOrd, 1) //Atualiza status da ordem.
                DisarmTransaction()
                Break

            EndIf

            If ! U_ADFT174(cCP, "ZIB_STATUS", cStatCp) //Atualiza status do controle de pátio.
                DisarmTransaction()
                Break

            EndIf

            lRet := .T.
            MsgInfo("Ticket de pesagem cancelado.","cancTkt(ADFAT017P)")

        Else
            aError := oTckOt:GetErrorMessage()
            cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

        EndIf

        oTckOt:DeActivate()
        oTckOt:Destroy()
        oTckOt := Nil

    End Transaction

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função cancTkt(ADFAT017P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} eGetStEn
    Obtém estatus da ordem de pesagem do tipo "Entrada" e controle de pátio,
    após a exclusão do ticket de pesagem.
    @type  Static Function
    @author Everson
    @since 13/12/2021
    @version 01
/*/
Static Function eGetStEn(cNmOrdem, cStatOrd, cStatCp)
    
    //Verifica se há aprovação comercial.
    cStatOrd := "3"
    cStatCp  := "2"

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
    Local nLinha        := Val(cValToChar(oOrdPes:nAt))
    Local cCP           := ""
    Local cNmOrdem      := ""
    Local cTpOrdem      := ""
    Local cStatOrd      := ""
    Local cAgrup        := ""
    Local cUrl          := Alltrim(cValToChar(Posicione("DX5" , 1, FwxFilial("DX5") + cBalanca, "DX5_URL")))
    Local oRetSolic     := Nil
    Local cErro         := ""
    Local cPlaca        := ""
    Local cTag          := ""
    Local cTktGuard     := ""
    Local cRot          := ""
    Local cFluxoGuard   := ""
    Local cTktProtheus  := ""
    Local lRetBal       := .F.

    If Empty(cUrl)
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Url da balança não está definido.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    If nLinha <= 0 .Or. Len(aOrdPes) <= 0
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Não há dados.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    cTktGuard := Alltrim(cValToChar(aOrdPes[nLinha,10]))
    If ! Empty(cTktGuard)
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Já há o ticket Guardian " + cTktGuard + " associado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    cCP := aOrdPes[nLinha,16]
    ZIB->()
    If Empty(cCP)
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Controle de pátio não selecionado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
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
        Return Nil

    EndIf

    cTktProtheus  := aOrdPes[nLinha,11]
    If Empty(Alltrim(cValToChar(cTktProtheus)))
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Não há ticket associado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(1))
    If ! ZIG->( DbSeek(FWxFilial("ZIG") + cTktProtheus) )
        Help(Nil, Nil, "Função pesaSemAut(ADFAT017P)", Nil, "Ticket de pesagem " + cTktProtheus + " não encontrado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    If Alltrim(cValToChar(ZIG->ZIG_INICIA))  $"3/4"
        Help(Nil, Nil, "Função pesaSemAut(ADFAT017P)", Nil, "A pesagem está encerrada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    cTag := Alltrim(cValToChar( Posicione("ZIB", 1, FwxFilial("ZIB") + cCP, "ZIB_TAG" ) ))
    If Empty(cTag)
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Não há tag associada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    cRot := Alltrim(cValToChar( Posicione("ZIB", 1, FwxFilial("ZIB") + cCP, "ZIB_CODROT") ))
    If Empty(cRot)
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Não há roteiro associado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    cFluxoGuard := Alltrim(cValToChar( Posicione("ZI9", 1, FwxFilial("ZI9") + cRot, "ZI9_FXGURD") ))
    If Empty(cFluxoGuard)
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Não há fluxo Guardian associado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    cPlaca := Alltrim(cValToChar( Posicione("ZIB", 1, FwxFilial("ZIB") + cCP, "ZIB_PLACA") ))
    If Empty(cPlaca)
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Não há placa associada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    FWMsgRun(,{|| lRetBal := U_ADFT241(cUrl, @oRetSolic, @cErro, cPlaca, cPlaca, cTag, cFluxoGuard, cTktProtheus, 0, "", "") }, "Função envBlcAut(ADFAT017P)",;
               "Enviando " + cUrl)

    If ! lRetBal
        Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Ocorreu erro no envio de pesagem para balança." + xPula + cErro, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf
    
    cTktGuard :=  cValToChar(oRetSolic:cCodigo)

    If ! Empty(cTktGuard)

        If cTpOrdem == "O"
            cStatOrd := "3"
        
        ElseIf cTpOrdem == "E"
            cStatOrd := "9"
        
        ElseIf cTpOrdem == "S"

        ElseIf cTpOrdem == "R"

        EndIf

        If U_ADFT191(cTktProtheus, "ZIG_NUMGUA", cTktGuard) .And. U_ADFT175(cNmOrdem, cStatOrd, 1)
            Help(Nil, Nil, "Função envBlcAut(ADFAT017P)", Nil, "Ticket Guardian gerado " + cTktGuard + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

    EndIf

Return Nil
/*/{Protheus.doc} pesaSemAut
    Pesagem semiautomática.
    @type  Static Function
    @author Everson
    @since 22/11/2021
    @version 01
/*/
Static Function pesaSemAut(lPesagManu, aParBal, oOrdPes, aOrdPes)

    //Variáveis.
    Local nLinha    := Val(cValToChar(oOrdPes:nAt))
    Local cTicket   := ""
    Local cNmOrdem  := ""
    //Local cOrdAgrup := ""
    Local cAgrup    := ""
    Local cForn     := ""
    Local cPlaca    := ""
    Local nQtdOrd   := ""
    Local cProduto  := ""
    Local nPeso1    := 0
    Local nPeso2    := 0
    Local nPeso3    := 0
    Local nPTotal   := 0
    Local bAutTot   := Nil
    Local oPesSemiA := Nil
    Local oContainer:= Nil
    Local aButtons  := {}
    Local cTpPes    := ""
    Local nPesoLiq  := 0
    Local nPOrLi    := 0
    Local nTpPesa   := 1
    Local nPesIni   := 0
    Local cSolPesMan:= ""
    Local lRetSlv   := .F.

    If nLinha <= 0 .Or. Len(aOrdPes) <= 0
        Help(Nil, Nil, "Função pesaSemAut(ADFAT017P)", Nil, "Não há dados.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    cNmOrdem := aOrdPes[nLinha,08]
    If Empty(Alltrim(cValToChar(cNmOrdem)))
        Help(Nil, Nil, "Função pesaSemAut(ADFAT017P)", Nil, "Selecione uma ordem de pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    cAgrup := aOrdPes[nLinha,09]
    If Empty(Alltrim(cValToChar(cAgrup)))
        Help(Nil, Nil, "Função pesaSemAut(ADFAT017P)", Nil, "Defina o agrupamento da ordem de pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    // cOrdAgrup := aOrdPes[nLinha,18]
    // If ! Empty(Alltrim(cValToChar(cOrdAgrup)))
    //     Help(Nil, Nil, "Função pesaSemAut(ADFAT017P)", Nil, "Selecione a ordem agrupadora " + cOrdAgrup + " para realizar a pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
    //     Return Nil

    // EndIf

    cTicket  := aOrdPes[nLinha,11]
    If Empty(Alltrim(cValToChar(cTicket)))
        Help(Nil, Nil, "Função pesaSemAut(ADFAT017P)", Nil, "Não há ticket associado à ordem de pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(1))
    If ! ZIG->( DbSeek(FWxFilial("ZIG") + cTicket) )
        Help(Nil, Nil, "Função pesaSemAut(ADFAT017P)", Nil, "Ticket de pesagem " + cTicket + " não encontrado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    If Alltrim(cValToChar(ZIG->ZIG_INICIA))  $"3/4"
        Help(Nil, Nil, "Função pesaSemAut(ADFAT017P)", Nil, "A pesagem está encerrada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    cNmOrdem := Iif(!Empty(aOrdPes[nLinha,18]),aOrdPes[nLinha,18],cNmOrdem)
    cCP      := ZIG->ZIG_CTPATI
    cForn    := aOrdPes[nLinha,03]
    cPlaca   := ZIG->ZIG_PLACA
    nQtdOrd  := ZIG->ZIG_PESORD
    cProduto := aOrdPes[nLinha,04]
    cTpPes   := Iif(ZIG->ZIG_PESINI == 0,"Peso Inicial","Peso Final")
    nPesIni  := ZIG->ZIG_PESINI
    nTpPesa  := Iif(ZIG->ZIG_PESINI == 0,1,2)
    cManual  := Iif(lPesagManu,"2","1")

    bAutTot   := {|| nPTotal := nPeso1 + nPeso2 + nPeso3, Iif(nTpPesa == 1,Nil,Eval({||nPesoLiq := Abs(nPTotal - nPesIni), nPOrLi := nPesoLiq - nQtdOrd})) }

    oPesSemiA := FWDialogModal():New()        
	oPesSemiA:SetEscClose(.F.)
	oPesSemiA:setTitle("Múltiplos Pesos")
	oPesSemiA:setSize( 290 , 200 )
	oPesSemiA:createDialog()
	oPesSemiA:addCloseButton(Nil, "Cancelar")
    Aadd(aButtons,{Nil,"Confimar",{|| lRetSlv := U_ADFT171(cTicket, nPTotal, nTpPesa, "1", cManual, nPesoLiq, @cSolPesMan), Iif( ! lRetSlv, Nil, oPesSemiA:DeActivate() ) },"","",.T.,.F.})
	oPesSemiA:addButtons(aButtons)

    	oContainer := TPanel():New( ,,, oPesSemiA:getPanelMain() )
	    oContainer:Align := CONTROL_ALIGN_ALLCLIENT

        TGroup():New(005,005,105,195,"Dados da ordem/ticket de pesagem",oContainer,,,.T.)
            TSay():New(015,010,{||"Fornecedor " + cForn}   ,oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,010)
            TSay():New(030,010,{||"Placa " + cPlaca}       ,oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,010)
            TSay():New(045,010,{||"Ticket " + cTicket}     ,oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,010)
            TSay():New(060,010,{||"Ordem " + cNmOrdem}       ,oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,010)
            TSay():New(075,010,{||"Qtde. Ordem " + Transform(nQtdOrd,"@E 999,999,999.999")},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,010)
            TSay():New(090,010,{||"Produto " + cProduto}    ,oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,010)

        TGroup():New(110,005,240,195,"Captura de Peso",oContainer,,,.T.)
            TGet():New(120,010,{|u|If(PCount() == 0,cTpPes,cTpPes := u)},oContainer,050,013,"",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cTpPes",,,,.T.,,,"Pesagem",1) 
            TGet():New(120,065,{|u|If(PCount() == 0,nPesoLiq,nPesoLiq := u)},oContainer,060,013,"@E 99,999,999,999",{|| .T.  },0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nPesoLiq",,,,.T.,,,"Peso Líquido",1) 
            TGet():New(120,130,{|u|If(PCount() == 0,nPOrLi,nPOrLi := u)},oContainer,060,013,"@E 999,999.999",{|| .T. },0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nPOrLi",,,,.T.,,,"Ordem Líquido(Quebra)",1) 
            
            TButton():New(150,010,Iif(!lPesagManu, "Peso 1","Digitar Peso 1") ,oContainer,{|| nPeso1 := Iif(!lPesagManu,obtPeso(aParBal),getPesMan()), Eval(bAutTot) },080,15,,,.F.,.T.,.F.,,.F.,{|| .T. },,.F. )
            
            TGet():New(150,100,{|u|If(PCount() == 0,nPeso1,nPeso1 := u)},oContainer,090,013,"@E 99,999,999,999",{|| .T.  },0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nPeso1",,,,.T.,,,"",2) 

            TButton():New(170,010,Iif(!lPesagManu, "Peso 2","Digitar Peso 2") ,oContainer,{|| nPeso2 := Iif(!lPesagManu,obtPeso(aParBal),getPesMan()), Eval(bAutTot) },080,15,,,.F.,.T.,.F.,,.F.,{|| .T. },,.F. )
            TGet():New(170,100,{|u|If(PCount() == 0,nPeso2,nPeso2 := u)},oContainer,090,013,"@E 99,999,999,999",{|| .T. },0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nPeso2",,,,.T.,,,"",2) 

            TButton():New(190,010,Iif(!lPesagManu, "Peso 3","Digitar Peso 3") ,oContainer,{|| nPeso3 := Iif(!lPesagManu,obtPeso(aParBal),getPesMan()), Eval(bAutTot) },080,15,,,.F.,.T.,.F.,,.F.,{|| .T. },,.F. )
            TGet():New(190,100,{|u|If(PCount() == 0,nPeso3,nPeso3 := u)},oContainer,090,013,"@E 99,999,999,999",{|| .T.  },0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nPeso3",,,,.T.,,,"",2) 
            
            TGet():New(220,087,{|u|If(PCount() == 0,nPTotal,nPTotal := u)},oContainer,090,013,"@E 99,999,999,999",{|| .T. },0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nPTotal",,,,.T.,,,"Total ",2) 
    
    oPesSemiA:Activate()

    If ! lRetSlv .And. ! Empty(cSolPesMan)
        exSolLiM(cSolPesMan)

    EndIf

Return Nil
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
/*/{Protheus.doc} ADFT171
    Salva pesagem no ticket.
    @type  User Function
    @author Everson
    @since 23/11/2021
    @version 01
/*/
User Function ADFT171(cTicket, nPTotal, nTpPesa, cAutomatica,;
                      cManual, nPesoLiq, cSolPesMan, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local cCP       := ""
    Local cRoteiro  := ""
    Local cPlaca    := ""
    Local cNmOrdem  := ""
    Local cProduto  := ""
    Local cProdPro  := ""
    Local nQtdOrd   := 0
    Local oTckOt    := Nil
    Local aDdSeq    := {}
    Local cStatOrd  := ""
    Local lSequestra:= .F.
    Local lEncCP    := .F.
    Local lEnsacado := .F.
    
    Default cMsgError := ""

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(1))
    If ! ZIG->(DbSeek( FWxFilial("ZIG") + cTicket ))
        cMsgError := "Ticket de pesagem " + cTicket + " não localizado."
        Help(Nil, Nil, "Função ADFT171(ADFAT017P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return lRet

    EndIf

    cCP       := ZIG->ZIG_CTPATI
    cRoteiro  := Posicione("ZIB", 1, FWxFilial("ZIB") + cCP, "ZIB_CODROT")
    lEnsacado := Posicione("ZI9", 1, FWxFilial("ZI9") + cRoteiro,"ZI9_ENSACA") == "1"
    cNmOrdem  := ZIG->ZIG_ORDEM
    cPlaca    := ZIG->ZIG_PLACA
    cProdSAG  := Posicione("ZIF", Iif(ZIG->ZIG_AGRUPA <> "1",1,3), FWxFilial("ZIF") + cNmOrdem, "ZIF_PRDSAG")
    cProdPro  := Posicione("ZIF", Iif(ZIG->ZIG_AGRUPA <> "1",1,3), FWxFilial("ZIF") + cNmOrdem, "ZIF_PRDPRO")
    cProduto  := U_ADFT176(cProdSAG, cProdPro)
    nQtdOrd   := ZIG->ZIG_PESORD

    If Empty(cProdSAG)
        cProdSAG  := Posicione("ZIM", 2, FWxFilial("ZIM") + cProdPro, "ZIM_PRDSAG")

    EndIf

    If nPTotal <= 0 
        Help(Nil, Nil, "Função ADFT171(ADFAT017P)", Nil, "Peso inválido.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    //Valida pesagem manual.
    If cManual == "2" .And. ! chkLiMan(cTicket, cNmOrdem, cPlaca, cProduto, nQtdOrd, nPTotal, @cSolPesMan)        
        RestArea(aArea)
        Return .F.

    EndIf

    //Valida se há apontamento para produtos ensacados.
    If nTpPesa == 2 .And. lEnsacado .And. ! U_ADFT178(lEnsacado, cRoteiro, cCP, cNmOrdem)
        RestArea(aArea)
        Return .F.

    EndIf

    //Valida quebra de peso.
    aDdSeq := {}
    If nTpPesa == 2 .And. ! U_ADFT177(cRoteiro, cCP, cProdSAG, nQtdOrd, nPesoLiq, @aDdSeq)
        RestArea(aArea)
        Return .F.

    EndIf

    lSequestra := Len(aDdSeq) > 0 .And. ! aDdSeq[1][1] .And. aDdSeq[1][2] <> "L"

    If ZIG->ZIG_TPMOV == "O"
        cStatOrd  := Iif(nTpPesa == 1, "4", Iif(lSequestra,"6","5"))

    ElseIf ZIG->ZIG_TPMOV == "E"
        cStatOrd := Iif(nTpPesa == 1, "10", Iif(lSequestra,"12","11"))

    ElseIf ZIG->ZIG_TPMOV == "S"

    ElseIf ZIG->ZIG_TPMOV == "R"

    EndIf

    oTckOt := FwLoadModel("ADFAT019P")
    oTckOt:SetOperation(MODEL_OPERATION_UPDATE)
    oTckOt:Activate() 
    
    oTckOt:SetValue("MD_MASTER","ZIG_AUTOMA", cAutomatica)
    oTckOt:SetValue("MD_MASTER","ZIG_MANUAL", cManual)

    If nTpPesa == 1
        oTckOt:SetValue("MD_MASTER","ZIG_PESINI", nPTotal)
        oTckOt:SetValue("MD_MASTER","ZIG_DTPES1", Date())
        oTckOt:SetValue("MD_MASTER","ZIG_HRPES1", Time())
        oTckOt:SetValue("MD_MASTER","ZIG_INICIA", "2")

    ElseIf nTpPesa == 2
        oTckOt:SetValue("MD_MASTER","ZIG_PESFIM", nPTotal)
        oTckOt:SetValue("MD_MASTER","ZIG_DTPES2", Date())
        oTckOt:SetValue("MD_MASTER","ZIG_HRPES2", Time())
        oTckOt:SetValue("MD_MASTER","ZIG_INICIA", Iif(lSequestra,"4","3"))
        oTckOt:SetValue("MD_MASTER","ZIG_PESOLI", nPesoLiq)
        oTckOt:SetValue("MD_MASTER","ZIG_UNTOLE", aDdSeq[1][3])
        oTckOt:SetValue("MD_MASTER","ZIG_QTTOLE", aDdSeq[1][4])
        oTckOt:SetValue("MD_MASTER","ZIG_QUEBRA", aDdSeq[1][5])
        oTckOt:SetValue("MD_MASTER","ZIG_TPSEQU", Iif(!aDdSeq[1][1], "", "1"))
        oTckOt:SetValue("MD_MASTER","ZIG_ENVBAR", aDdSeq[1][7])

    EndIf

    Begin Transaction

        If oTckOt:VldData()
            oTckOt:CommitData()

            If ! U_ADFT175(cNmOrdem, cStatOrd, 1) //Atualiza status da ordem.
                DisarmTransaction()
                Break

            EndIf

            If nTpPesa == 1

                If ! U_ADFT174(cCP, "ZIB_STATUS", "4") //Atualiza status do controle de pátio.
                    DisarmTransaction()
                    Break

                EndIf

            ElseIf nTpPesa == 2
                
                lEncCP := chkLiTOrd(cCP, ZIG->ZIG_TPMOV)

                If lEncCP

                    If ! U_ADFT174(cCP, "ZIB_STATUS", Iif(nTpPesa == 1,"4", "5")) //Atualiza status do controle de pátio.
                        DisarmTransaction()
                        Break

                    EndIf

                EndIf

            EndIf

            If nTpPesa == 2 .And. lEnsacado .And. ! U_ADEST675(cNmOrdem, 3, "ZIL_PESADO", "1", "")
                DisarmTransaction()
                Break

            EndIf

            If lSequestra
                acaoSeq(aDdSeq)

            EndIf

            lRet := .T.

            If lSequestra
                Help(Nil, Nil, "Função ADFT171(ADFAT017P)", Nil, "Pesagem sequestrada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
                
            EndIf

        Else
            aError := oTckOt:GetErrorMessage()
            cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

        EndIf

    End Transaction

    oTckOt:DeActivate()
    oTckOt:Destroy()
    oTckOt := Nil

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função ADFT171(ADFAT017P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} chkLiTOrd
    Verifica se todas as ordens vinculadas ao controle de pátio estão encerradas.
    @type  Static Function
    @author Everson
    @since 15/12/2021
    @version 01
/*/
Static Function chkLiTOrd(cCP, cTpOrdem)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .T.

    DbSelectArea("ZIF")
    ZIF->(DbSetOrder(2))
    ZIF->(DbGoTop())
    While ! ZIF->(Eof()) .And. ZIF->ZIF_FILIAL == FWxFilial("ZIF") .And. ZIF->ZIF_CTPATI == cCP

        If cTpOrdem == "O" .And. ! (ZIF->ZIF_STATUS $"5/6/7")
            lRet := .F.
            Exit

        ElseIf cTpOrdem == "E" .And. ! (ZIF->ZIF_STATUS $"11/12/13")
            lRet := .F.
            Exit

        ElseIf cTpOrdem == "S" .And. ! (ZIF->ZIF_STATUS $"")
            lRet := .F.
            Exit

        ElseIf cTpOrdem == "R" .And. ! (ZIF->ZIF_STATUS $"")
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
Static Function chkLiMan(cTicket, cNmOrdem, cPlaca, cProduto, nQtdOrd, nPTotal, cSolPesMan)

    //Variáveis.
    Local lRet := .F.

    If chkRgLib()
        lRet := .T.
        Return lRet

    Endif

    DbSelectArea("ZIK")
    ZIK->(DbSetOrder(2))
    If ! ZIK->( DbSeek(FWxFilial("ZIK") +  cTicket))
        criaSolLiM(cTicket, cNmOrdem, cPlaca, cProduto, nQtdOrd, nPTotal, @cSolPesMan)
        Return lRet

    EndIf

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
Static Function chkRgLib()

    //Variáveis.
    Local lRet := .F.
    Local cQuery := " SELECT COUNT(ZIK_NUMERO) AS TOT_LIB FROM " + RetSqlName("ZIK") + " (NOLOCK) AS ZIK WHERE ZIK_FILIAL = '" + FWxFilial("ZIK") + "' AND ZIK_RDATA = '" + DToS(Date()) + "' AND ZIK_RHORA >= '" + Time() + "' AND ZIK.D_E_L_E_T_ = '' "

    If Select("D_TOTL") > 0
        D_TOTL->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_TOTL"
    DbSelectArea("D_TOTL")
        If Val(cValToChar(D_TOTL->TOT_LIB)) > 0
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
Static Function criaSolLiM(cTicket, cNmOrdem, cPlaca, cProduto, nQtdOrd, nPTotal, cSolPesMan)

    //Variáveis.
    Local oSolMan   := FwLoadModel("ADFAT021P")
    Local cMotivo   := ""
    Local cDescMot  := ""
    Local cMsgError := ""

    Pergunte("ZIC0101", .T.)
    cMotivo := MV_PAR01
    cDescMot := Posicione("ZIC",1, FWxFilial("ZIC") + cMotivo, "ZIC_DESC")

    oSolMan:SetOperation(MODEL_OPERATION_INSERT)
    oSolMan:Activate() 

    oSolMan:SetValue("MD_MASTER","ZIK_TICKET" , cTicket)
    oSolMan:SetValue("MD_MASTER","ZIK_ORDEM"  , cNmOrdem)
    oSolMan:SetValue("MD_MASTER","ZIK_PLACA"  , cPlaca)
    oSolMan:SetValue("MD_MASTER","ZIK_PRODUT" , cProduto)
    oSolMan:SetValue("MD_MASTER","ZIK_QTDORD" , nQtdOrd)
    oSolMan:SetValue("MD_MASTER","ZIK_PESMAN" , nPTotal)
    oSolMan:SetValue("MD_MASTER","ZIK_MOTIVO" , cMotivo)
    oSolMan:SetValue("MD_MASTER","ZIK_MOTDES" , cDescMot)
    oSolMan:SetValue("MD_MASTER","ZIK_NMSOLI" , cUserName)

    If oSolMan:VldData()
        oSolMan:CommitData()
        cSolPesMan := ZIK->ZIK_NUMERO
        MsgInfo("Solicitação gerada " + cSolPesMan + ".","criaSolLiM(ADFAT017P")

    Else
        aError := oSolMan:GetErrorMessage()
        cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

    EndIf

    oSolMan:DeActivate()
    oSolMan:Destroy()
    oSolMan := Nil

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função criaSolLiM(ADFAT017P)", Nil, "Erro na geração de solicitação de pesagem manual." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

Return Nil
/*/{Protheus.doc} exSolLiM
    Cria solicitação de liberação de pesagem manual.
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
/*/{Protheus.doc} pesaManu
    Pesagem manual.
    @type  Static Function
    @author Everson
    @since 23/11/2021
    @version 01
/*/
Static Function pesaManu(aParBal, oOrdPes, aOrdPes)

    //Variáveis.
    Local nLinha   := Val(cValToChar(oOrdPes:nAt))

    If nLinha <= 0 .Or. Len(aOrdPes) <= 0
        Help(Nil, Nil, "Função pesaManu(ADFAT017P)", Nil, "Não há dados.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf
    
    pesaSemAut(.T., @aParBal, oOrdPes, aOrdPes)

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
/*/{Protheus.doc} getStOP
    Obtém situação da ordem de pesagem outras.
    @type  Static Function
    @author Everson
    @since 24/11/2021
    @version 01
/*/
Static Function getStOP(cTpOrdem, cStatus)
    
    //Variáveis.
    Local aSituacao := U_ADFAT161(cTpOrdem, cStatus)

Return aSituacao
/*/{Protheus.doc} ADFT175
    Atualiza status da ordem de pesagem.
    @type  User Function
    @author Everson
    @since 24/11/2021
    @version 01
/*/
User Function ADFT175(cNmOrdem, cStatus, nStatus)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local cNmOrAgr  := ""
    
    DbSelectArea("ZIF")
    ZIF->(DbSetOrder(2))
    If ! ZIF->(DbSeek( FWxFilial("ZIF") + cNmOrdem ))

        ZIF->(DbSetOrder(3))
        If ! ZIF->(DbSeek( FWxFilial("ZIF") + cNmOrdem ))
            Help(Nil, Nil, "Função ADFT175(ADFAT017P)", Nil, "Ordem de pesagem " + cNmOrdem + " não encontrada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
            RestArea(aArea)
            Return lRet

        Else
            cNmOrdem := ZIF->ZIF_NUMERO

        EndIf

    EndIf

    cNmOrAgr := Alltrim(cValToChar(ZIF->ZIF_AGRUPA))

    Begin Transaction

        lRet := execAStO(cNmOrdem, cStatus, nStatus)
        If ! lRet
            DisarmTransaction()
            Break

        EndIf

        If lRet .And. ! Empty(cNmOrAgr)

            DbSelectArea("ZIF")
            ZIF->(DbSetOrder(3))
            If ZIF->(DbSeek( FWxFilial("ZIF") + cNmOrAgr))

                While ! ZIF->(Eof()) .And. ZIF->ZIF_FILIAL == FWxFilial("ZIF") .And. ZIF->ZIF_AGRUPA == cNmOrAgr

                    lRet := execAStO(ZIF->ZIF_NUMERO, cStatus, nStatus)

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
/*/{Protheus.doc} execAStO
    Executa a atualização de status da ordem de pesagem.
    @type  Static Function
    @author Everson
    @since 24/11/2021
    @version 01
/*/
Static Function execAStO(cNmOrdem, cStatus, nStatus)
    
    //Variáveis.
    Local lRet := U_ADFT164(cNmOrdem, cStatus, nStatus)

Return lRet
/*/{Protheus.doc} ADFT174
    Atualiza controle de pátio.
    @type  User Function
    @author Everson
    @since 25/11/2021
    @version 01
/*/
User Function ADFT174(cCP, cCampo, xValor, cMsgError)

    //Variáveis.
    Local lRet      := .F.
    Local oModel    := Nil
    
    Default cMsgError := ""
    
    DbSelectArea("ZIB")
    ZIB->(DbSetOrder(1))
    If ! ZIB->(DbSeek( FWxFilial("ZIB") + cCP ))
        Help(Nil, Nil, "Função ADFT174(ADFAT017P)", Nil, "Controle de pátio " + cCP + " não encontrado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return lRet

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
        Help(Nil, Nil, "Função ADFT174(ADFAT017P)", Nil, "Erro na atualização de registro de controle de pátio." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

Return lRet
/*/{Protheus.doc} contTkt
    Obtém a quantidade de tickets vinculada ao controle de pátio.
    @type  Static Function
    @author Everson
    @since 25/11/2021
    @version 01
/*/
Static Function contTkt(cCP)

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
Static Function lerTag(oView, lAtuView)

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
    Local aDdConn := {}

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
        If !Empty(cTag) .And. chkTag(cTag)
            FWFldPut("ZIB_TAG",cTag)

        EndIf
        
        oView:Refresh()

    EndIf

    RestArea(aArea)

Return cTag
/*/{Protheus.doc} chkTag
    Verifica se a tag já está em uso.
    @type  Static Function
    @author Everson
    @since 29/11/2021
    @version 01
/*/
Static Function chkTag(cTag)

    //Variáveis.
    Local lRet      := .T.
    Local cAliasT   := GetNextAlias()
    Local cQuery    := " SELECT ZIB_NUMERO, ZIB_DATA, ZIB_PLACA FROM " + RetSqlName("ZIB") + " (NOLOCK) AS ZIB WHERE ZIB_FILIAL = '" + FWxFilial("ZIB") + "' AND ZIB_TAG = '" + cTag + "' AND ZIB_STATUS <> '6' AND D_E_L_E_T_ = '' "

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
/*/{Protheus.doc} ADFT177
    Verifica se houve quebra na pesagem.
    @type  User Function
    @author Everson
    @since 01/12/2021
    @version 01
/*/
User Function ADFT177(cRoteiro, cCP, cProdSAG, nQtdOrd, nPesoLiq, aDdSeq)

    //Variáveis.
    Local aArea     := GetArea()
    Local cRot      := Posicione("ZIB",1 ,FWxFilial("ZIB") + cCP, "ZIB_CODROT")
    Local cAcaoDiv  := ""
    Local nTolRot   := 0
    Local cUnRot    := ""
    Local nQrbKg    := Abs(nPesoLiq - nQtdOrd)
    Local nQrbPer   := Iif(nQtdOrd <= 0, 0, (nQrbKg/nQtdOrd)) * 100
    Local lLib      := .F.
    Local cAnLabo   := ""

    DbSelectArea("ZI9")
    ZI9->(DbSetOrder(1))
    If ! ZI9->( DbSeek( FWxFilial("ZI9") + cRot ) )
        Help(Nil, Nil, "Função ADFT177(ADFAT019P)", Nil, "Roteiro " + cRot + " não encontrado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    cAcaoDiv:= ZI9->ZI9_ACINCO
    cUnRot  := ZI9->ZI9_UNTOLE
    nTolRot := ZI9->ZI9_QTTOLE

    DbSelectArea("ZIA")
    ZIA->(DbSetOrder(2))
    ZIA->(DbGoTop())
    If ZIA->(DbSeek( FWxFilial("ZIA") + cRoteiro + cProdSAG ))
        cUnRot  := ZIA->ZIA_UNTOLE
        nTolRot := ZIA->ZIA_QTTOLE
        cAnLabo := ZIA->ZIA_ANLABO

    EndIf

    If cUnRot == "KG"
        lLib := nTolRot >= nQrbKg

    Else
        lLib := nTolRot >= nQrbPer

    EndIf

    Aadd(aDdSeq, { lLib, cAcaoDiv, cUnRot, nTolRot, (nPesoLiq - nQtdOrd), Iif(nQtdOrd <= 0, 0, ((nPesoLiq - nQtdOrd)/nQtdOrd)) * 100, cAnLabo, nQtdOrd })

    RestArea(aArea)
    
Return .T.
/*/{Protheus.doc} ADFT178
    Valida fluxo de produto ensacado.
    @type  User Function
    @author Everson
    @since 20/12/2021
    @version 01
/*/
User Function ADFT178(lEnsacado, cRoteiro, cCP, cNmOrdem)

    //Variáveis.
    Local aArea     := GetArea()

    If ! lEnsacado
        RestArea(aArea)
        Return .T.

    EndIf

    DbSelectArea("ZIL")
    ZIL->(DbSetOrder(3))
    If ZIL->( DbSeek( FWxFilial("ZIL") + cNmOrdem))
        RestArea(aArea)
        Return .T.

    EndIf

    //Desenvolver rotina para remontar a pesagem.

    Help(Nil, Nil, "Função ADFT178(ADFAT017P)", Nil, "Não há apontamento de ensacados para ordem " + cNmOrdem + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
    
Return .F.
/*/{Protheus.doc} acaoSeq
    Ação a ser tomada, quando há sequestro de pesagem.
    @type  Static Function
    @author Everson
    @since 01/12/2021
    @version 01
/*/
Static Function acaoSeq(aDdSeq)

Return Nil
/*/{Protheus.doc} devoTag
    Devolve tag de pesagem.
    @type  Static Function
    @author Everson
    @since 02/12/2021
    @version 01
/*/
Static Function devoTag(oOrdPes, aOrdPes, cBalanca)

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
    Local cFluxo        := ""
    Local cTktGuard     := ""
    Local cTktProtheus  := ""
    Local lRetSlv       := Nil
    Local lTagFixa      := .F.

    If nLinha <= 0 .Or. Len(aOrdPes) <= 0
        Help(Nil, Nil, "Função devoTag(ADFAT017P)", Nil, "Não há dados.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    cCP := aOrdPes[nLinha,16]
    If Empty(cCP)
        Help(Nil, Nil, "Função devoTag(ADFAT017P)", Nil, "Controle de pátio não selecionado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    DbSelectArea("ZIB")
    ZIB->(DbSetOrder(1))
    If ! ZIB->(DbSeek( FWxFilial("ZIB") + cCP ))
        Help(Nil, Nil, "Função devoTag(ADFAT017P)", Nil, "Controle de pátio não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    cTktGuard   := aOrdPes[nLinha,10]
    cTktProtheus:= aOrdPes[nLinha,11]
    cPlaca      := ZIB->ZIB_PLACA
    cTagAtual   := ZIB->ZIB_TAG
    cFluxo      := Posicione("ZI9", 1, FwxFilial("ZI9") + ZIB->ZIB_CODROT, "ZI9_FXGURD")

    DbSelectArea("ZV4")
    ZV4->(DbSetOrder(1))
    If ZV4->( DbSeek( FWxFilial("ZV4") + cPlaca ) )
        cNovaTag := Alltrim(cValToChar(ZV4->ZV4_TGFIXA))
        lTagFixa  := .T.

    EndIf
	
    oModal:SetEscClose(.F.)
	oModal:setTitle("Devolver Tag de Pesagem")
	oModal:setSize( 150 , 130 )
	oModal:createDialog()
	oModal:addCloseButton(Nil, "Fechar")

    bSalvar := {|| lRetSlv := procDevTag(cCP, cTagAtual, cNovaTag), Iif(!lRetSlv, Nil, oModal:DeActivate()) }
                                               
    Aadd(aButtons,{Nil, "Confimar", bSalvar, "", "", .T., .F.})
	oModal:addButtons(aButtons)

        oContainer := TPanel():New(025,,, oModal:getPanelMain())
        oContainer:Align := CONTROL_ALIGN_ALLCLIENT

        TSay():New(015,010,{||"Controle de Pátio " + cCP},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,140,010)
        TSay():New(025,010,{||"Fluxo " + cFluxo},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,140,010)
        TSay():New(035,010,{||"Placa " + cPlaca},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,140,010)
        TSay():New(045,010,{||"Ticket Protheus " + cTktProtheus},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,140,010)
        TSay():New(055,010,{||"Tag Atual " + cTagAtual},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,140,010)
        
        TButton():New(070,025,"Ler Tag", oContainer,{|| cNovaTag := lerTag(Nil, .F.) },080,15,,,.F.,.T.,.F.,,.F.,{|| ! Empty(cTagAtual) .And. ! lTagFixa },,.F. )
        TGet():New(090,010,{|u|If(PCount() == 0, cNovaTag, cNovaTag := u)},oContainer,110,010,"",{|| .T. },0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cNovaTag",,,,.T.,,,"",1) 

	oModal:Activate()

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} procDevTag
    Processa devolução de tag.
    @type  Static Function
    @author Everson
    @since 02/12/2021
    @version 01
/*/
Static Function procDevTag(cCP, cTagAtual, cNovaTag)

    //Variáveis.

    If ! Empty(cTagAtual) .And. Alltrim(cValToChar(cTagAtual)) <> Alltrim(cValToChar(cNovaTag))
        Help(Nil, Nil, "Função procDevTag(ADFAT017P)", Nil, "As tags são diferentes.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    U_ADFT174(cCP, "ZIB_STATUS", "6")

Return .T.
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
        Return Nil

    EndIf

    cCP := aOrdPes[nLinha,16]
    If Empty(cCP)
        Help(Nil, Nil, "Função altTag(ADFAT017P)", Nil, "Controle de pátio não selecionado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    DbSelectArea("ZIB")
    ZIB->(DbSetOrder(1))
    If ! ZIB->(DbSeek( FWxFilial("ZIB") + cCP ))
        Help(Nil, Nil, "Função altTag(ADFAT017P)", Nil, "Controle de pátio não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

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
	oModal:addCloseButton(Nil, "Fechar")
                                               //atuaTag(cBalanca, cCP, cFluxo, cPlaca, cTktProtheus, cNovaTag)
    Aadd(aButtons,{Nil,"Confimar",{|| lRetSlv := atuaTag(cBalanca, cCP, cFluxo, cPlaca, cTktProtheus, cNovaTag, cTktGuard), Iif(!lRetSlv, Nil, oModal:DeActivate()) },"","",.T.,.F.})
	oModal:addButtons(aButtons)

        oContainer := TPanel():New(025,,, oModal:getPanelMain())
        oContainer:Align := CONTROL_ALIGN_ALLCLIENT

        TSay():New(005,010,{||"Balança " + cBalanca},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,140,010)
        TSay():New(015,010,{||"Controle de Pátio " + cCP},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,140,010)
        TSay():New(025,010,{||"Fluxo " + cFluxo},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,140,010)
        TSay():New(035,010,{||"Placa " + cPlaca},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,140,010)
        TSay():New(045,010,{||"Ticket Protheus " + cTktProtheus},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,140,010)
        TSay():New(055,010,{||"Tag Atual " + cTagAtual},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE,140,010)
        
        TButton():New(070,025,"Ler Tag", oContainer,{|| cNovaTag := lerTag(Nil, .F.) },080,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        TGet():New(090,010,{|u|If(PCount() == 0, cNovaTag, cNovaTag := u)},oContainer,110,010,"",{|| .T. },0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cNovaTag",,,,.T.,,,"",1) 

	oModal:Activate()

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} atuaTag
    (long_description)
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

        FWMsgRun(,{|| lRetBal := U_ADFT242(cUrl, @oRetSolic, cErro, cPlaca, cPlaca, cNovaTag, cFluxo, cTktProtheus) }, "Função atuaTag(ADFAT017P)",;
                    "Alterando " + cUrl)

        If ! lRetBal
            Help(Nil, Nil, "Função atuaTag(ADFAT017P)", Nil, "Ocorreu erro na alteração da tag." + xPula + cErro, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
            Return .F.

        EndIf

    EndIf
    
    U_ADFT174(cCP, "ZIB_TAG", cNovaTag)
    
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

    DbSelectArea("ZIB")
    ZIB->(DbSetOrder(1))
    If ! ZIB->( DbSeek( FWxFilial("ZIB") + cCP ))
        Help(Nil, Nil, "Função excTag(ADFAT017P)", Nil, "Controle de pátio " + cCP + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
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

    // If Alltrim(cValToChar(ZIB->ZIB_STATUS)) <> "5"
    //     Help(Nil, Nil, "Função excTag(ADFAT017P)", Nil, "Controle de pátio não pode ser cancelado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
    //     Return .F.

    // EndIf 

    If ! MsgYesNo("Deseja realizar a exclusão da tag de pesagem vinculada ao ticket Guardian " + cTktGuard + "?","excTag(ADFAT017P)")
        Return .F.

    EndIf

    FWMsgRun(,{|| lRetBal := U_ADFT249(cUrl,@cErro,cTktGuard,4,"WS G","01") }, "Função excTag(ADFAT017P)",;
                  "Excluindo " + cUrl)

    If ! lRetBal
        Help(Nil, Nil, "Função excTag(ADFAT017P)", Nil, "Ocorreu erro no cancelamento da tag." + xPula + cErro, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return .F.

    Else
        U_ADFT174(cCP, "ZIB_STATUS", "6")

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

    MsAguarde({|| lRet := U_ADFAT026R(cTicket, cTpOrdem)}, "Aguarde", "Imprimindo ticket " + cTicket + " (" + cTpOrdem + ")...", .F.)

Return lRet
