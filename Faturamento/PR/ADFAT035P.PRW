#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"

Static oRoteiro:= Nil
Static oPlaca  := Nil
Static cRoteiro:= Space(TamSX3("ZIR_ORAGRP")[1])
Static cPlaca  := Space(TamSX3("ZIB_PLACA")[1])
Static cGavetas:= ""
Static oOrdPes   := Nil
Static aOrdPes   := {}
Static cOrdSlc   := ""
Static lCarrega  := .F.

/*/{Protheus.doc} User Function ADFAT035P
    Rotina para alteração de expedição apontamento de lacre, silo e caixa do veículo.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 01/03/2022
    @version 01
    /*/
User Function ADFAT035P() // U_ADFAT035P()

    //Variáveis.
    Local aArea     := GetArea()
    Local oJnPrinc  := Nil

    Local oPnOrdem  := Nil
    Local oAltLt    := Nil
    Local oDupMv    := Nil
    Local oIniCar   := Nil
    Local oCanCar   := Nil
    Local oFimCar   := Nil
    Local bLibApt   := {}
    Local bBlqApt   := {}
    Local bSelRt    := {}
    Local oBtnRot   := Nil
    Local cInfLacre := Space(TamSx3("ZIT_LACRE")[1])
    Local lRetLC    := .T.
    Local oAtua     := Nil
    Local oFont     := TFont():New("Courier new",,22)

    Private oInLacre  := Nil
    Private oLacre    := Nil
    Private aHLacre   := {}
    Private aCLacre   := {}

    Private oInGav    := Nil
    Private oGaveta   := Nil
    Private aHGaveta  := {}
    Private aCGaveta  := {}

    Private oInSilo   := Nil
    Private oSilo     := Nil
    Private aHSilo    := {}
    Private aCSilo    := {}

    lmpVrEst()

    //Bloco executado na inicialização do carregamento.
    bLibApt := {|| oDupMv:Disable(),;
                   oAltLt:Disable(),;
                   oCanCar:Enable(),;
                   oFimCar:Enable(),;
                   oLacre:Enable(),;
                   oInLacre:Enable(),;
                   oGaveta:Enable(),;
                   oInGav:Enable(),;
                   oSilo:Enable(),;
                   oInSilo:Enable(),;
                   oIniCar:Disable(),;
                   oOrdPes:Disable(),;
                   oAtua:Disable();
                }
    
    //Bloco executado na finalização e cancelamento de carregamento.
    bBlqApt := {|| cOrdSlc := "",;
                   carDados(cOrdSlc),;
                   carOrdens(cRoteiro, aOrdPes, oOrdPes),;
                   oCanCar:Disable(),;
                   oFimCar:Disable(),;
                   oLacre:Disable(),;
                   oInLacre:Disable(),;
                   oGaveta:Disable(),;
                   oInGav:Disable(),;
                   oSilo:Disable(),;
                   oInSilo:Disable(),;
                   oOrdPes:Enable(),;
                   oAtua:Enable(),;
                   oRoteiro:SetFocus();
                }

    oJnPrinc		   := MsDialog():Create()
	oJnPrinc:cName     := "oJnPrinc"
	oJnPrinc:cCaption  := "Alteração de Expedição e Controle de Lacre"
	oJnPrinc:nLeft     := 34
	oJnPrinc:nTop      := 222
	oJnPrinc:nWidth    := 1200
	oJnPrinc:nHeight   := 600
	oJnPrinc:lShowHint := .F.
	oJnPrinc:lCentered := .T.

        oRoteiro := TGet():New(005,005,{|u| if( PCount() > 0, cRoteiro := u, cRoteiro ) } , oJnPrinc,50,010,,,,,,,,.T.,,,,,,,,,,"cRoteiro",,,,,,,"Carga",1)
        oRoteiro:Disable()

        bSelRt := {|| Eval(bBlqApt), lRetR := U_ADFAT35E(), Iif(!lRetR, NIl, Eval({|| cRoteiro := ZIR->ZIR_ORAGRP, cPlaca := ZIR->ZIR_PLACA, oRoteiro:Refresh(), oPlaca:Refresh(), carOrdens(cRoteiro, @aOrdPes, @oOrdPes) }) ) }
        oBtnRot := TButton():New(010, 057, "Rt", oJnPrinc, bSelRt, 020, 015,,,.F.,.T.,.F.,,.F.,,,.F. )
        oBtnRot:bWhen := {|| ! lCarrega }
        
        oPlaca := TGet():New(005, 085,{|u| if( PCount() > 0, cPlaca := u, cPlaca ) } , oJnPrinc,50,010,,{|| .T. },,,,,,.T.,,,,,,,,,,"cPlaca",,,,,,,"Placa",1)
        oPlaca:bWhen := {|| .F. }

        TSay():New(005, 145, {||"Ordem de pesagem selecionada: " + Iif(Empty(cOrdSlc), "-", cOrdSlc) },oJnPrinc,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
        
        oAtua := TButton():New(010,555, "Atualizar" ,oJnPrinc,;
        {|| cOrdSlc := "", aOrdPes := {}, oOrdPes:setArray(aOrdPes), carOrdens(cRoteiro, aOrdPes, oOrdPes) },;
        040, 010,,,.F.,.T.,.F.,,.F.,,,.F. )
        oAtua:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #0000CC, stop: 1 #190033);color: white}")

        oPnOrdem := TPanel():New(030,005,,oJnPrinc,,,,,,590,120)
 
        oOrdPes := FwBrowse():New()
        oOrdPes:setOwner(oPnOrdem)
        oOrdPes:setDataArray()
        oOrdPes:setArray(aOrdPes)
        oOrdPes:disableConfig()
        oOrdPes:disableReport()

            oOrdPes:AddStatusColumns({|| U_ADFAT17G("R", aOrdPes[oOrdPes:nAt,12]) })
            oOrdPes:SetDoubleClick( {|| If(!lCarrega .And. Len(aOrdPes) > 0, Eval( {|| carDados( aOrdPes[oOrdPes:nAt,02] ), oDupMv:Enable(), oAltLt:Enable(), oIniCar:Enable()} ), Nil) } )
            oOrdPes:SetDelete(.F.)
            oOrdPes:SetInsert(.F.)

            oOrdPes:addColumn({"Ord. Pes."         , {||aOrdPes[oOrdPes:nAt,02]}, "C", ""                  , 1, 010    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,02]",, .F., .T., , "ID02" })
            oOrdPes:addColumn({"Ord. Car."         , {||aOrdPes[oOrdPes:nAt,14]}, "C", ""                  , 2, 010    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,14]",, .F., .T., , "ID14" })
            oOrdPes:addColumn({"Ticket"            , {||aOrdPes[oOrdPes:nAt,15]}, "C", ""                  , 2, 010    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,15]",, .F., .T., , "ID15" })
            oOrdPes:addColumn({"Seq."              , {||aOrdPes[oOrdPes:nAt,03]}, "C", ""                  , 2, 010    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,03]",, .F., .T., , "ID03" })
            oOrdPes:addColumn({"Destino"           , {||aOrdPes[oOrdPes:nAt,04]}, "C", ""                  , 1, 010    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,04]",, .F., .T., , "ID04" })
            oOrdPes:addColumn({"Produto"           , {||aOrdPes[oOrdPes:nAt,05]}, "C", ""                  , 1, 020    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,05]",, .F., .T., , "ID05" })
            oOrdPes:addColumn({"Lote Produto"      , {||aOrdPes[oOrdPes:nAt,06]}, "C", ""                  , 1, 010    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,06]",, .F., .T., , "ID06" })
            oOrdPes:addColumn({"Qtde"              , {||aOrdPes[oOrdPes:nAt,07]}, "N", "@E 999,999,999.999", 2, 010    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,07]",, .F., .T., , "ID07" })
            oOrdPes:addColumn({"Situação"          , {||aOrdPes[oOrdPes:nAt,08]}, "C", ""                  , 1, 030    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,08]",, .F., .T., , "ID08" })
            oOrdPes:addColumn({"Peso Líquido"      , {||aOrdPes[oOrdPes:nAt,09]}, "N", "@E 999,999,999.999", 2, 010    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,09]",, .F., .T., , "ID09" })
            oOrdPes:addColumn({"Saldo"             , {||aOrdPes[oOrdPes:nAt,10]}, "N", "@E 999,999,999.999", 2, 010    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,10]",, .F., .T., , "ID10" })
            oOrdPes:addColumn({"Pesagem"           , {||aOrdPes[oOrdPes:nAt,11]}, "C", ""                  , 1, 030    ,   , .T. , , .F.,, "aOrdPes[oOrdPes:nAt,11]",, .F., .T., , "ID11" })
  
        oOrdPes:Activate()
        
        oAltLt := TButton():New(155,005, "Altera Produto/Lote" ,oJnPrinc,{|| altLtPrd(@lCarrega), Iif(lCarrega, Nil, Eval(bBlqApt)) }, 100, 015,,,.F.,.T.,.F.,,.F.,,,.F. )
        oAltLt:Disable()

        oDupMv  := TButton():New(155,110, "Duplica Movimento"   ,oJnPrinc,{|| dupliMv(@lCarrega), Iif(lCarrega, Nil, Eval(bBlqApt)) }, 100, 015,,,.F.,.T.,.F.,,.F.,,,.F. )
        oDupMv:Disable()

        oIniCar := TButton():New(155,215,"Inicia Carregamento"  ,oJnPrinc,{|| iniCar(@lCarrega), Iif(!lCarrega, Nil, Eval(bLibApt))  }, 100, 015,,,.F.,.T.,.F.,,.F.,,,.F. )
        oIniCar:Disable()

        oCanCar := TButton():New(155,320,"Cancela Carregamento" ,oJnPrinc,{|| canCar(@lCarrega), Iif(lCarrega, Nil, Eval(bBlqApt)) }, 100, 015,,,.F.,.T.,.F.,,.F.,,,.F. )
        oCanCar:Disable()

        oFimCar := TButton():New(155,425,"Finaliza Carregamento",oJnPrinc,{|| fimCar(@lCarrega), Iif(lCarrega, Nil, Eval(bBlqApt)) }, 100, 015,,,.F.,.T.,.F.,,.F.,,,.F. )
        oFimCar:Disable()

        //Lacre.
        oInLacre := TGet():New(173,005,{|u| if( PCount() > 0, cInfLacre := u, cInfLacre ) } , oJnPrinc,100,013,,,,,,,,.T.,,,,,,,,,,"cInfLacre",,,,,,,"")
        oInLacre:bValid := {|| lRetLC := U_ADFAT35A("I", @cInfLacre, @oInLacre), cInfLacre := Space(TamSx3("ZIT_LACRE")[1]), oInLacre:Refresh(), lRetLC }
        oInLacre:Disable()

        //oInLacre := TButton():New(173,120,"+L", oJnPrinc,{|| U_ADFAT35A("I") },020,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        //oInLacre:Disable()
        
        Aadd(aHLacre,{"Lacre", "LACRE", "", TamSX3("ZIT_LACRE")[1], 0,"","" ,"C","",""})
        oLacre := MsNewGetDados():New(190, 005, 285, 195,, Nil, "Allwaystrue()", "", {"LACRE"}, Nil, 999, Nil, Nil, Nil, oJnPrinc, aHLacre, @aCLacre)
        oLacre:oBrowse:bLDblClick := {|| Iif(lCarrega, U_ADFAT35A("E"), Nil) }
        oLacre:Disable()
        
        //Gaveta.
        oInGav := TButton():New(173,205,"+G", oJnPrinc,{|| U_ADFAT35B("I") },020,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        Aadd(aHGaveta,{"Gaveta", "GAVETA", "", TamSX3("ZIX_NUMERO")[1], 0,"","" ,"C","ZIXLCR",""})
        oGaveta := MsNewGetDados():New(190, 205, 285, 395, , , "Allwaystrue()", "", {"GAVETA"}, Nil, 999, Nil, Nil, Nil, oJnPrinc, aHGaveta, @aCGaveta)
        oGaveta:oBrowse:bLDblClick := {|| Iif(lCarrega, U_ADFAT35B("E"), Nil) }
        oGaveta:Disable()
        oInGav:Disable()

        //Silo.
        oInSilo := TButton():New(173,405,"+S", oJnPrinc,{|| U_ADFAT35C("I") },020,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        Aadd(aHSilo,{"Silo", "CSILO", "", TamSX3("ZIW_NUMERO")[1], 0,"","" ,"C","ZIWLCR",""})
        Aadd(aHSilo,{"Desc", "DSILO", "", TamSX3("ZIW_DESC")[1], 0,"","" ,"C","",""})
        oSilo := MsNewGetDados():New(190, 405, 285, 595, , , "Allwaystrue()", "", {"CSILO"}, Nil, 999, Nil, Nil, Nil, oJnPrinc, aHSilo, @aCSilo)
        oSilo:oBrowse:bLDblClick := {|| Iif(lCarrega, U_ADFAT35C("E"), Nil) }
        oSilo:Disable()
        oInSilo:Disable()

    oJnPrinc:Activate(,,,.T.,{||.T.},, {||  })

    FreeObj(oJnPrinc)
    oJnPrinc := Nil

    lmpVrEst()

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} lmpVrEst
    Limpa variáveis estáticas.
    @type  Static Function
    @author Everson
    @since 23/03/2022
    @version 01
/*/
Static Function lmpVrEst()

    //Variáveis.

    If ValType(oRoteiro) == "O"
        FreeObj(oRoteiro)
        oRoteiro := Nil

    EndIf

    If ValType(oPlaca) == "O"
        FreeObj(oPlaca)
        oPlaca := Nil

    EndIf

    If ValType(oOrdPes) == "O"
        FreeObj(oOrdPes)
        oOrdPes := Nil

    EndIf

    cRoteiro  := Space(TamSX3("ZIR_ORAGRP")[1])
    cPlaca    := Space(TamSX3("ZIB_PLACA")[1])
    cGavetas  := ""
    aOrdPes   := {}
    cOrdSlc   := ""
    lCarrega  := .F.

Return Nil
/*/{Protheus.doc} carOrdens
    Carrega ordens de carregamento vinculadas ao roteiro selecionado.
    @type  Static Function
    @author Everson
    @since 01/03/2022
    @version 01
/*/
Static Function carOrdens(cRoteiro, aOrdPes, oOrdPes)

    //Variáveis.
    Local aArea     := GetArea()
    Local cQuery    := ""
    Local aSituacao := {}
    Local nPosTpSeq := 0
    Local cDesTpSe  := ""
    Local aTpSeq    := RetSX3Box(GetSX3Cache("ZIG_TPSEQU", "X3_CBOX"),,,1)
    Local cProd     := ""
    Local cNmLote   := ""
    Local nSaldo    := ""
    Local cStatLC   := ""
    Local aSituCarr := {}
    
    cPlaca := ""
    oPlaca:Refresh()
    aOrdPes := {}
    oOrdPes:setArray(aOrdPes)
    oOrdPes:Refresh()

    If Empty(cRoteiro)
        RestArea(aArea)
        Return Nil

    EndIf

    cPlaca := Posicione("ZIR", 2, FWxFilial("ZIR") + cRoteiro, "ZIR_PLACA")
    oPlaca:Refresh()
    
    If Empty(cPlaca)
        RestArea(aArea)
        Return Nil

    EndIf

    cQuery += " SELECT * " 
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("ZIF") + " (NOLOCK) AS ZIF " 
    cQuery += " INNER JOIN " 
    cQuery += " " + RetSqlName("ZIR") + " (NOLOCK) AS ZIR ON " 
    cQuery += " ZIF_FILIAL = ZIR_FILIAL " 
    cQuery += " AND ZIF_ORDRAC = ZIR_NUMERO " 
    cQuery += " INNER JOIN " 
    cQuery += " " + RetSqlName("ZIG") + " (NOLOCK) AS ZIG ON " 
    cQuery += " ZIF_FILIAL = ZIG_FILIAL " 
    cQuery += " AND ZIF_NUMERO = ZIG_ORDEM " 
    cQuery += " WHERE " 
    cQuery += " ZIF_FILIAL = '" + FWxFilial("ZIF") + "' " 
    cQuery += " AND ZIR_ORAGRP = '" + cRoteiro + "' " 
    cQuery += " AND ZIR_PLACA = '" + cPlaca + "' " 
    cQuery += " AND ZIR.D_E_L_E_T_ = '' " 
    cQuery += " AND ZIF.D_E_L_E_T_ = '' " 
    cQuery += " AND ZIG.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY ZIG_SEQTKT " 

    If Select("D_ORDENS") > 0
        D_ORDENS->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_ORDENS"
    DbSelectArea("D_ORDENS")
    While ! D_ORDENS->(Eof())

        //Situação do lacre da ordem de pesagem.
        cStatLC   := ""
        aSituCarr := {}
        If getSituacao(D_ORDENS->ZIF_NUMERO, @aSituCarr) .And. Len(aSituCarr) > 0
            cStatLC := aSituCarr[1][2]

        EndIf

        //Situação da ordem de pesagem.
        aSituacao := U_ADFAT17H(D_ORDENS->ZIF_TPMOVI, Alltrim(cValToChar(D_ORDENS->ZIF_STATUS)))
        nPosTpSeq:= 0
        cDesTpSe := ""
        If D_ORDENS->ZIG_TPSEQU <> "0"
            nPosTpSeq := AScan(aTpSeq, {|x| Alltrim(cValToChar(x[2]))  == Alltrim(cValToChar(D_ORDENS->ZIG_TPSEQU))})
            cDesTpSe  := " - " + aTpSeq[nPosTpSeq,3]

            If D_ORDENS->ZIG_TPSEQU == "1" .And. ! Empty(D_ORDENS->ZIG_DTLSEQ) //Sequestro por quebra de peso com liberação do sequestro.
                cStatLC := "Aguardando Nova Pesagem"

            Else
                cStatLC := aSituacao[1,2] + cDesTpSe
                
            EndIf

        EndIf

        cProd := U_ADFAT176(D_ORDENS->ZIF_PRDSAG, D_ORDENS->ZIF_PRDPRO)
        cNmLote := Posicione("ZI8",1, FWxFilial("ZI8") + D_ORDENS->ZIF_LOTE ,"ZI8_DESLOT")
        nSaldo  := Posicione("ZI8",1, FWxFilial("ZI8") + D_ORDENS->ZIF_LOTE ,"ZI8_LTSALD")

        Aadd(aOrdPes,{.F.,;                  //01 - Flag.
                      D_ORDENS->ZIF_NUMERO,; //02 - Numero da ordem.
                      D_ORDENS->ZIG_SEQTKT,; //03 - Sequência de pesagem.
                      D_ORDENS->ZIR_DESGRJ,; //04 - Destino.
                      cProd,;                //05 - Produto
                      cNmLote            ,;  //06 - Lote do produto.
                      D_ORDENS->ZIF_QUANT,;  //07 - Quantidade.
                      cStatLC,;              //08 - Situação.
                      D_ORDENS->ZIG_PESOLI,; //09 - Peso Líquido.
                      nSaldo,;               //10 - Saldo.
                      aSituacao[1,2] + cDesTpSe,;   //11 - Pesagem.
                      D_ORDENS->ZIF_STATUS,;  //12 - Status da ordem de pesagem.
                      D_ORDENS->ZIF_CTPATI,;  //13 - Controle de pátio.
                      D_ORDENS->ZIF_ORDRAC,;  //14 - Ordem de carregamento.
                      D_ORDENS->ZIG_NUMERO;   //15 - Ticket.
                      })

        D_ORDENS->(DbSkip())

    End
    D_ORDENS->(DbCloseArea())

    oOrdPes:setArray(aOrdPes)
    oOrdPes:Refresh()

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} carDados
    Retorna a situação do carregamento.
    @type  Static Function
    @author Everson
    @since 02/03/2022
    @version 01
/*/
Static Function getSituacao(cNmOrdem, aSituCarr)

    //Variáveis.
    Local aArea     := GetArea()
    Local aStatLC   := RetSX3Box(GetSX3Cache("ZIF_STATLC", "X3_CBOX"),,,1)
    Local nStatLC   := 0
    Local cStatLC   := ""

    If ! U_ADFAT16A(cNmOrdem)
        MsgInfo("Ordem de pesagem " + cNmOrdem + " não localizada", "Função getSituacao(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If ! Empty(ZIF->ZIF_STATLC)
        nStatLC  := AScan(aStatLC, {|x| Alltrim(cValToChar(x[2]))  == Alltrim(cValToChar(ZIF->ZIF_STATLC))})
        cStatLC := aStatLC[nStatLC,3]

        Aadd(aSituCarr,{ZIF->ZIF_STATLC, cStatLC})

    EndIf


    RestArea(aArea)

Return .T.
/*/{Protheus.doc} carDados
    Carrega dados do apontamento de lacres, gavetas e silos.
    @type  Static Function
    @author Everson
    @since 01/03/2022
    @version 01
/*/
Static Function carDados(cNmOrdem)

    //Variáveis.
    Local aArea := GetArea()
    
    cOrdSlc := cNmOrdem

    oLacre:aCols := {}

    oGaveta:aCols := {}

    oSilo:aCols := {}

    //Lacre.
    DbSelectArea("ZIT")
    ZIT->(DbSetOrder(3))
    ZIT->(DbGoTop())
    If ZIT->( DbSeek( FWxFilial("ZIT") + cOrdSlc ) )

        While ! ZIT->(Eof()) .And. ZIT->ZIT_FILIAL == FWxFilial("ZIT") .And. ZIT->ZIT_ORDEM == cOrdSlc

            Aadd(oLacre:aCols , Array(Len(aHLacre) + 1) )
		    oLacre:aCols[Len(oLacre:aCols), Len(oLacre:aCols[1]) ] := .F.

            oLacre:aCols[Len(oLacre:aCols),Ascan(aHLacre,{|x| AllTrim(x[2]) == "LACRE" })] := ZIT->ZIT_LACRE

            ZIT->(DbSkip())
            
        End

    EndIf

    //Gaveta.
    DbSelectArea("ZIZ")
    ZIZ->(DbSetOrder(3))
    ZIZ->(DbGoTop())
    If ZIZ->( DbSeek( FWxFilial("ZIZ") + cOrdSlc ) )

        While ! ZIZ->(Eof()) .And. ZIZ->ZIZ_FILIAL == FWxFilial("ZIZ") .And. ZIZ->ZIZ_ORDEM == cOrdSlc

            Aadd(oGaveta:aCols , Array(Len(aHGaveta) + 1) )
		    oGaveta:aCols[Len(oGaveta:aCols), Len(oGaveta:aCols[1]) ] := .F.

            oGaveta:aCols[Len(oGaveta:aCols),Ascan(aHGaveta,{|x| AllTrim(x[2]) == "GAVETA" })] := ZIZ->ZIZ_CAIXA

            ZIZ->(DbSkip())

        End

    EndIf

    //Silo.
    DbSelectArea("ZIY")
    ZIY->(DbSetOrder(3))
    ZIY->(DbGoTop())
    If ZIY->( DbSeek( FWxFilial("ZIY") + cOrdSlc ) )

        While ! ZIY->(Eof()) .And. ZIY->ZIY_FILIAL == FWxFilial("ZIY") .And. ZIY->ZIY_ORDEM == cOrdSlc

            Aadd(oSilo:aCols , Array(Len(aHSilo) + 1) )
		    oSilo:aCols[Len(oSilo:aCols), Len(oSilo:aCols[1]) ] := .F.

            oSilo:aCols[Len(oSilo:aCols),Ascan(aHSilo,{|x| AllTrim(x[2]) == "CSILO" })] := ZIY->ZIY_SILO
            oSilo:aCols[Len(oSilo:aCols),Ascan(aHSilo,{|x| AllTrim(x[2]) == "DSILO" })] := Posicione("ZIW", 1, FWxFilial("ZIW") + ZIY->ZIY_SILO, "ZIW_DESC")

            ZIY->(DbSkip())

        End

    EndIf

    If Len(oLacre:aCols) <= 0
        Aadd(oLacre:aCols , Array(Len(aHLacre) + 1) )
	    oLacre:aCols[Len(oLacre:aCols), Len(oLacre:aCols[1]) ] := .F.
        oLacre:aCols[Len(oLacre:aCols),Ascan(aHLacre,{|x| AllTrim(x[2]) == "LACRE" })] := ""

    EndIf

    If Len(oGaveta:aCols) <= 0
        Aadd(oGaveta:aCols , Array(Len(aHGaveta) + 1) )
		oGaveta:aCols[Len(oGaveta:aCols), Len(oGaveta:aCols[1]) ] := .F.
        oGaveta:aCols[Len(oGaveta:aCols),Ascan(aHGaveta,{|x| AllTrim(x[2]) == "GAVETA" })] := ""

    EndIf
    
    If Len(oSilo:aCols) <= 0
        Aadd(oSilo:aCols , Array(Len(aHSilo) + 1) )
        oSilo:aCols[Len(oSilo:aCols), Len(oSilo:aCols[1]) ] := .F.
        oSilo:aCols[Len(oSilo:aCols),Ascan(aHSilo,{|x| AllTrim(x[2]) == "CSILO" })] := ""

    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} corEstOrd
    Retorna a cor de status da ordem de pesagem.
    @type  Static Function
    @author Everson
    @since 01/03/2022
    @version 01
/*/
Static Function corEstOrd()

    //Variáveis.

Return "BR_BRANCO"
/*/{Protheus.doc} altLtPrd
    Alteração de lote e produto.
    @type  Static Function
    @author Everson
    @since 08/03/2022
    @version 01
/*/
Static Function altLtPrd(lCarrega)

    //Variáveis.
    Local aArea     := GetArea()
    Local nLinha    := oOrdPes:nAt

    If Empty(cOrdSlc) .Or. nLinha <= 0 .Or. Len(aOrdPes) <= 0
        MsgInfo("Selecione uma ordem de carregamento.","Função altLtPrd(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(cRoteiro) .Or. Empty(cPlaca)
        MsgInfo("Roteiro e/ou placa não definidos.","Função altLtPrd(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If ! U_ADFAT16A(cOrdSlc)
        MsgInfo("Ordem de pesagem não localizada.","Função altLtPrd(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If ZIF->ZIF_STATLC <> "A"
        MsgInfo("Ordem de pesagem não está aberta.","Função altLtPrd(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    EndIf

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(2))
    ZIG->(DbGoTop())
    If ! ZIG->( DbSeek( FWxFilial("ZIG") + cOrdSlc))
        MsgInfo("Ticket de pesagem referente à ordem " + cOrdSlc + " não localizado.","Função altLtPrd(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    Else

        If ZIG->ZIG_INICIA == "3"
            MsgInfo("Pesagem encerrada.","Função altLtPrd(ADFAT035P)")
            RestArea(aArea)
            Return .F.

        EndIf

    EndIf

    If ! Pergunte("ADEST691", .T.)
        RestArea(aArea)
        Return .F.

    EndIf

    If ! U_ADFAT354()
        RestArea(aArea)
        Return .F.

    EndIf

    Begin Transaction

        If ! U_ADFAT165(cOrdSlc, "ZIF_PRDPRO", ZI8->ZI8_PRDPRT)
            DisarmTransaction()
            Break

        EndIf

        If ! U_ADFAT165(cOrdSlc, "ZIF_PRDSAG", ZI8->ZI8_PRDSAG)
            DisarmTransaction()
            Break

        EndIf

        If ! U_ADFAT165(cOrdSlc, "ZIF_LOTE", ZI8->ZI8_CDLOTE)
            DisarmTransaction()
            Break

        EndIf

        lCarrega := .F.

        //Produto ativo
        //Produto ração
        //Lote aberto/uso

    End Transaction

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFAT354
    Valida pergunta ADEST691.
    @type  User Function
    @author Everson
    @since 01/03/2022
    @version 01
/*/
User Function ADFAT354()

    //Variáveis.
    Local cLote    := Alltrim(cValToChar(MV_PAR01))

    If Empty(cLote)
        MsgInfo("Informe o lote.", "Função ADFAT354(ADFAT035P)")
        Return .F.

    EndIf

    DbSelectArea("ZI8")
    ZI8->(DbSetOrder(1))
    If ! ZI8->( DbSeek( FWxFilial("ZI8") + cLote) )
        MsgInfo("Lote " + cLote + " não localizado.", "Função ADFAT354(ADFAT035P)")
        Return .F.

    EndIf

    If ZI8->ZI8_LAUTO == "1"
        MsgInfo("Lote " + cLote + " automático.", "Função ADFAT354(ADFAT035P)")
        Return .F.

    EndIf

    If ZI8->ZI8_LAUTO == "1" .Or. ! (ZI8->ZI8_STATUS $ "1/2")
        MsgInfo("Lote " + cLote + " não está aberto ou em uso.", "Função ADFAT354(ADFAT035P)")
        Return .F.

    EndIf

    DbSelectArea("ZIM")
    ZIM->( DbSetOrder(1) )
    If ! ZIM->( DbSeek( FWxFilial("ZIM") + ZI8->ZI8_PRDSAG))
        MsgInfo("Produto " + ZI8->ZI8_PRDSAG + " não localizado.", "Função ADFAT354(ADFAT035P)")
        Return .F.

    EndIf

Return .T.
/*/{Protheus.doc} dupliMv
    Duplicação de movimento.
    @type  Static Function
    @author Everson
    @since 08/03/2022
    @version 01
/*/
Static Function dupliMv(lCarrega)

    //Variáveis.
    Local aArea     := GetArea()
    Local nLinha    := oOrdPes:nAt
    Local cOrdemC   := ""
    Local cPrdSAG   := ""
    Local oPrdOrg   := Nil
    Local cPrdOrg   := ""
    Local cQtdSolic := 0
    Local oQtdSolic := Nil
    Local nQtdNv    := 0
    Local oQtdNv    := Nil
    Local oQtdDst   := Nil
    Local nQtdDst   := 0
    Local cLote     := ""
    Local cCP       := ""
    Local cBalanca  := ""
    Local cRotPesa  := ""
    Local oModal    := Nil
    Local aButtons  := {}
    Local bConfirmar:= Nil
    Local oContainer:= Nil

    If Empty(cOrdSlc) .Or. nLinha <= 0 .Or. Len(aOrdPes) <= 0
        MsgInfo("Selecione uma ordem de carregamento.","Função dupliMv(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(cRoteiro) .Or. Empty(cPlaca)
        MsgInfo("Roteiro e/ou placa não definidos.","Função dupliMv(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If ! U_ADFAT16A(cOrdSlc)
        MsgInfo("Ordem de pesagem não localizada.","Função dupliMv(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If ZIF->ZIF_STATLC <> "E"
        MsgInfo("Ordem de pesagem não está com status 'Encerrada'.","Função dupliMv(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    EndIf

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(2))
    ZIG->(DbGoTop())
    If ! ZIG->( DbSeek( FWxFilial("ZIG") + cOrdSlc))
        MsgInfo("Ticket de pesagem referente à ordem " + cOrdSlc + " não localizado.","Função dupliMv(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    Else

        If ZIG->ZIG_INICIA == "3"
            MsgInfo("Pesagem encerrada.","Função dupliMv(ADFAT035P)")
            RestArea(aArea)
            Return .F.

        EndIf

    EndIf

    cOrdemC     := ZIF->ZIF_ORDRAC
    cPrdSAG     := ZIF->ZIF_PRDSAG
    cPrdOrg     := Alltrim(cValToChar(Posicione("ZIM", 1 , FWxFilial("ZIM") + cPrdSAG, "ZIM_DESSAG")))
    cQtdSolic   := Alltrim(cValToChar(Transform(ZIF->ZIF_QUANT, "@E 999,999,999.999")))
    cLote       := ZIF->ZIF_LOTE
    cCP         := ZIG->ZIG_CTPATI
    cBalanca    := ZIG->ZIG_BALANC
    cRotPesa    := ZIG->ZIG_ROTEIR

    bConfirmar := {|| Iif(! U_ADFAT35F(ZIG->ZIG_NUMERO, ZIG->ZIG_SEQTKT, cOrdSlc, cOrdemC, cPrdSAG, cLote, ZIF->ZIF_QUANT, nQtdNv, nQtdDst,;
                                      cCP, cPlaca,;
                                      cBalanca, cRotPesa),;
                           Nil,;
                           oModal:DeActivate();
                      );
                  }

    oModal := FWDialogModal():New()        
	oModal:SetEscClose(.F.)
	oModal:setTitle("Duplicação de Movimentos")
	oModal:setSize(100, 275)
	oModal:createDialog()

        Aadd(aButtons,{Nil,"Confimar", bConfirmar,"","",.T.,.F.})
        Aadd(aButtons,{Nil,"Cancelar", {|| oModal:DeActivate() },"","",.T.,.F.})

        oModal:addButtons(aButtons)

        oContainer := TPanel():New(025,,, oModal:getPanelMain())
        oContainer:Align := CONTROL_ALIGN_ALLCLIENT
        
        oPrdOrg := TGet():New(005,005,{|u| if( PCount() > 0, cPrdOrg := u, cPrdOrg ) } , oContainer,100,010,,,,,,,,.T.,,,,,,,,,,"cPrdOrg",,,,,,,"Produto Origem",1)
        oPrdOrg:Disable()
        
        oQtdSolic := TGet():New(005,110,{|u| if( PCount() > 0, cQtdSolic := u, cQtdSolic ) } , oContainer,50,010,,,,,,,,.T.,,,,,,,,,,"cQtdSolic",,,,,,,"Qtde Solicitada",1)
        oQtdSolic:Disable()

        oQtdNv := TGet():New(005,165,{|u| if( PCount() > 0, nQtdNv := u, nQtdNv ) } , oContainer,50,010,"@E 999,999,999",,,,,,,.T.,,,,,,,,,,"nQtdNv",,,,,,,"Qtde Origem",1)
        oQtdNv:bValid := {|| nQtdDst := (ZIF->ZIF_QUANT - nQtdNv), oQtdDst:Refresh() , .T.}
        
        oQtdDst := TGet():New(005,220,{|u| if( PCount() > 0, nQtdDst := u, nQtdDst ) } , oContainer,50,010,"@E 999,999,999.999",,,,,,,.T.,,,,,,,,,,"nQtdDst",,,,,,,"Qtde Destino",1)
        oQtdDst:Disable()

    oModal:Activate()

    lCarrega := .F.

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFAT35F
    Processa duplicação de movimento.
    @type  User Function
    @author Everson
    @since 22/03/2022
    @version 01
/*/
User Function ADFAT35F(cTicket, cSeqTkt, cOrdSlc, cOrdemC, cPrdSAG, cLote, nQtdOrg, nQtdNv, nQtdDst,;
                          cCP, cPlaca,;
                          cBalanca, cRotPesa)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local cNvOrdC   := ""
    Local cNvOrdP   := ""
    Local aDados    := {}

    If nQtdOrg <= nQtdNv .Or. nQtdNv <= 0 .Or. nQtdDst <= 0
        MsgInfo("Quantidade inválida.", "Função ADFAT35F(ADFAT035P)")
        RestArea(aArea)
        Return .F.
        
    EndIf

    Begin Transaction

        //Atualiza quantidade da ordem de carregamento atual.
        Aadd(aDados,{"ZIR_QUANT", nQtdNv})
        If ! U_ADFAT32D(cOrdemC, aDados)
            DisarmTransaction()
            Break

        EndIf

        //Atualiza quantidade da ordem de pesagem atual.
        If ! U_ADFAT165(cOrdSlc, "ZIF_QUANT", nQtdNv)
            DisarmTransaction()
            Break

        EndIf

        //Atualiza quantidade do ticket de pesagem atual.
        If ! U_ADFAT191(cTicket, "ZIG_PESORD", nQtdNv)
            DisarmTransaction()
            Break

        EndIf

        //Criar ordem de carregamento.
        If ! U_ADFAT32F(cOrdemC, cPrdSAG, cLote, nQtdDst, @cNvOrdC)
            DisarmTransaction()
            Break

        EndIf

        //Criar ordem de pesagem.
        If ! U_ADFAT17A(cCP, cPlaca, @cNvOrdP)
            DisarmTransaction()
            Break

        EndIf

        //Atribuir ticket.
        cSeqTkt := cValToChar(Val(cSeqTkt) + 1)
        If ! U_ADFAT17K(cCP, cNvOrdP, nQtdDst, cBalanca, cRotPesa, cSeqTkt)
            DisarmTransaction()
            Break
            
        EndIf

        lRet := .T.

    End Transaction

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} iniCar
    Inicia carregamento, apontamento de lacres, gavetas e silos.
    @type  Static Function
    @author Everson
    @since 01/03/2022
    @version 01
/*/
Static Function iniCar(lCarrega)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local nLinha    := oOrdPes:nAt
    Local cStatLC   := ""
    Local aSituCarr := {}
    Local cCP       := ""

    If Empty(cOrdSlc) .Or. nLinha <= 0 .Or. Len(aOrdPes) <= 0
        MsgInfo("Selecione uma ordem de carregamento.","Função iniCar(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(cRoteiro) .Or. Empty(cPlaca)
        MsgInfo("Roteiro e/ou placa não definidos.","Função iniCar(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    EndIf
    
    If ! U_ADFAT16A(cOrdSlc)
        MsgInfo("Ordem de carregamento " + cOrdSlc + " não encontrada.","Função iniCar(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    EndIf

    cCP := ZIF->ZIF_CTPATI

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(2))
    ZIG->(DbGoTop())
    If ! ZIG->( DbSeek( FWxFilial("ZIG") + cOrdSlc))
        MsgInfo("Ticket de pesagem referente à ordem " + cOrdSlc + " não localizado.","Função iniCar(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    Else

        If ZIG->ZIG_INICIA == "3"
            MsgInfo("Pesagem encerrada.","Função iniCar(ADFAT035P)")
            RestArea(aArea)
            Return .F.

        EndIf

    EndIf

    DbSelectArea("ZIF")
    ZIF->(DbSetOrder(9))
    ZIF->(DbGoTop())
    If ZIF->(DbSeek( FWxFilial("ZIF") + cCP + "C" ))
        If ZIF->ZIF_NUMERO <> cOrdSlc
            MsgInfo("O roteiro " + cRoteiro + " já possui a ordem " + ZIF->ZIF_NUMERO + " com status 'Carregando'.","Função iniCar(ADFAT035P)")
            RestArea(aArea)
            Return .F.

        EndIf

    EndIf

    DbSelectArea("ZIF")
    ZIF->(DbSetOrder(9))
    ZIF->(DbGoTop())
    If ZIF->(DbSeek( FWxFilial("ZIF") + cCP + "E" ))

        If ZIF->ZIF_NUMERO <> cOrdSlc

            DbSelectArea("ZIG")
            ZIG->(DbSetOrder(2))
            ZIG->(DbGoTop())
            If ZIG->( DbSeek( FWxFilial("ZIG") + ZIF->ZIF_NUMERO))

                If ZIG->ZIG_INICIA <> "3"
                    MsgInfo("Existem ordens de pesagem encerradas, mas sem peso final.","Função iniCar(ADFAT035P)")
                    RestArea(aArea)
                    Return .F.

                EndIf

            Else
                MsgInfo("Ticket de pesagem referente à ordem " + ZIF->ZIF_NUMERO + " não localizado.","Função iniCar(ADFAT035P)")
                RestArea(aArea)
                Return .F.

            EndIf

        EndIf

    EndIf

    // DbSelectArea("ZIG")
    // ZIG->(DbSetOrder(5))
    // ZIG->(DbGoTop())
    // If ZIG->(DbSeek( FWxFilial("ZIG") + cCP ))

    //     While ! ZIG->(Eof()) .And. ZIG->ZIG_FILIAL == FWxFilial("ZIG") .And. ZIG->ZIG_CTPATI == cCP

    //         If ZIG->ZIG_ORDEM <> cOrdSlc .And. ZIG->ZIG_INICIA $"4/5"
    //             MsgInfo("Há ordem de pesagem em processo de sequestro (" + ZIG->ZIG_ORDEM + ").","Função iniCar(ADFAT035P)")
    //             RestArea(aArea)
    //             Return .F.

    //         EndIf

    //         ZIG->(DbSkip())

    //     End

    // EndIf

    Begin Transaction

        If ! U_ADFAT165(cOrdSlc, "ZIF_STATLC", "C")
            DisarmTransaction()
            Break

        EndIf

        If getSituacao(cOrdSlc, @aSituCarr) .And. Len(aSituCarr) > 0
            cStatLC := aSituCarr[1][2]

        EndIf
        aOrdPes[nLinha][8] := cStatLC
        oOrdPes:setArray(aOrdPes)
        oOrdPes:Refresh()

        lCarrega := .T.

        lRet := .T.

    End Transaction

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} canCar
    Cancela carregamento.
    @type  Static Function
    @author Everson
    @since 03/03/2022
    @version 01
/*/
Static Function canCar(lCarrega)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local nLinha    := oOrdPes:nAt
    Local nAux      := 1
    Local cLacre    := ""
    Local cGaveta   := ""
    Local cSilo     := ""

    If Empty(cOrdSlc) .Or. nLinha <= 0 .Or. Len(aOrdPes) <= 0
        MsgInfo("Selecione uma ordem de carregamento.","Função canCar(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(cRoteiro) .Or. Empty(cPlaca)
        MsgInfo("Roteiro e/ou placa não definidos.","Função canCar(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    EndIf

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(2))
    ZIG->(DbGoTop())
    If ! ZIG->( DbSeek( FWxFilial("ZIG") + cOrdSlc))
        MsgInfo("Ticket de pesagem referente à ordem " + cOrdSlc + " não localizado.","Função canCar(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    Else

        If ZIG->ZIG_INICIA == "3"
            MsgInfo("Pesagem encerrada.","Função canCar(ADFAT035P)")
            RestArea(aArea)
            Return .F.

        EndIf

    EndIf

    Begin Transaction

        //Deleta registros de lacre.
        For nAux := 1 To Len(oLacre:aCols)
            
            cLacre := oLacre:aCols[nAux, Ascan(aHLacre,{|x| AllTrim(x[2]) == "LACRE" })]

            If ! Empty(cLacre) .And. ! U_ADFAT38B(cRoteiro, cPlaca, cLacre, cOrdSlc)
                DisarmTransaction()
                Break

            EndIf

        Next nAux
        
        //Deleta registros de caixas.
        For nAux := 1 To Len(oGaveta:aCols)
            
            cGaveta := oGaveta:aCols[nAux, Ascan(aHGaveta,{|x| AllTrim(x[2]) == "GAVETA" })]

            If ! Empty(cGaveta) .And. ! U_ADFAT39B(cRoteiro, cPlaca, cGaveta, cOrdSlc)
                DisarmTransaction()
                Break

            EndIf

        Next nAux
        
        //Deleta registros de silos.
        For nAux := 1 To Len(oSilo:aCols)
            
            cSilo := oSilo:aCols[nAux, Ascan(aHSilo,{|x| AllTrim(x[2]) == "CSILO" })]

            If ! Empty(cSilo) .And. ! U_ADFAT40B(cRoteiro, cPlaca, cOrdSlc, cSilo)
                DisarmTransaction()
                Break

            EndIf

        Next nAux

        //Altera status de lacre da ordem de carregamento.
        If ! U_ADFAT165(cOrdSlc, "ZIF_STATLC", "A")
            DisarmTransaction()
            Break

        EndIf

        lCarrega := .F.

        lRet := .T.

    End Transaction

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} fimCar
    Finaliza carregamento.
    @type  Static Function
    @author Everson
    @since 01/03/2022
    @version 01
/*/
Static Function fimCar(lCarrega)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local nLinha    := oOrdPes:nAt
    Local cCP       := ""
    Local cSeqNV    := ""
    Local aSituCarr := {}
    Local cTktNv    := ""
    Local aDSeqP    := {}

    If Empty(cOrdSlc) .Or. nLinha <= 0 .Or. Len(aOrdPes) <= 0
        MsgInfo("Selecione uma ordem de carregamento.","Função fimCar(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(cRoteiro) .Or. Empty(cPlaca)
        MsgInfo("Roteiro e/ou placa não definidos.","Função fimCar(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If ! U_ADFAT16A(cOrdSlc)
        MsgInfo("Ordem de carregamento " + cOrdSlc + " não encontrada.","Função fimCar(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    EndIf

    DbSelectArea("ZIT")
    ZIT->(DbSetOrder(3))
    ZIT->(DbGoTop())
    If ! ZIT->( DbSeek( FWxFilial("ZIT") + cOrdSlc) )
        MsgInfo("Não há lacre vinculado à ordem de pesagem " + cOrdSlc + ".","Função fimCar(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    EndIf

    DbSelectArea("ZIZ")
    ZIZ->(DbSetOrder(3))
    ZIZ->(DbGoTop())
    If ! ZIZ->( DbSeek( FWxFilial("ZIZ") + cOrdSlc) )
        MsgInfo("Não há gaveta de transporte vinculada à ordem de pesagem " + cOrdSlc + ".","Função fimCar(ADFAT035P)")
        RestArea(aArea)
        Return .F.

    EndIf

    Begin Transaction

        //Ajusta a sequência do ticket de pesagem.
        cCP    := aOrdPes[nLinha][13]
        aDSeqP := getSeqP(cCP, cRoteiro)

        If Len(aDSeqP) <= 0
            DisarmTransaction()
            Break

        EndIf

        cTktNv := aDSeqP[1]
        cSeqNV := aDSeqP[2]

        If ! U_ADFAT192(cCP, cOrdSlc, cTktNv, cSeqNV)
            DisarmTransaction()
            Break

        EndIf

        //Marca o status do lacre como encerrado.
        If ! U_ADFAT165(cOrdSlc, "ZIF_STATLC", "E")
            DisarmTransaction()
            Break

        EndIf

        //Obtém o status para atualizar o FwBrowse.
        If getSituacao(cOrdSlc, @aSituCarr) .And. Len(aSituCarr) > 0
            cStatLC := aSituCarr[1][2]

        EndIf
        aOrdPes[nLinha][8] := cStatLC
        oOrdPes:setArray(aOrdPes)
        oOrdPes:Refresh()

        lCarrega := .F.

        lRet := .T.

    End Transaction

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} getSeqP
    Obtém sequência de pesagem. 
    de produtos ensacados.
    @type  Static Function
    @author Everson
    @since 02/03/2022
    @version 01
/*/
Static Function getSeqP(cCP, cRoteiro)

    //Variáveis.
    Local aArea     := GetArea()
    Local cSeq      := ""
    Local cTicket   := ""
    Local cQuery    := ""

    //Ticket que está com pesagem inicial.
    cQuery := ""
    cQuery += " SELECT  " 
    cQuery += " MIN(ZIG_NUMERO) AS ZIG_NUMERO "
    cQuery += " FROM  " 
    cQuery += " " + RetSqlName("ZIG") + " (NOLOCK) AS ZIG  " 
    cQuery += " INNER JOIN " 
    cQuery += " " + RetSqlName("ZIR") + " (NOLOCK) AS ZIR ON " 
    cQuery += " ZIG_FILIAL = ZIR_FILIAL " 
    cQuery += " AND ZIG_ORDEM = ZIR_ORDEM " 
    cQuery += " WHERE  " 
    cQuery += " ZIG_FILIAL = '" + FWxFilial("ZIG") + "'  " 
    cQuery += " AND ZIG_CTPATI = '" + cCP + "'  " 
    cQuery += " AND ZIR_ORAGRP = '" + cRoteiro + "' " 
    cQuery += " AND ZIG_INICIA IN ('2','4') " //Peso inicial, pesagem sequestrada.
    cQuery += " AND ZIG.D_E_L_E_T_ = '' " 
    cQuery += " AND ZIR.D_E_L_E_T_ = '' " 

    If Select("D_TKT") > 0
        D_TKT->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_TKT"
    DbSelectArea("D_TKT")

        cTicket   := D_TKT->ZIG_NUMERO

    D_TKT->(DbCloseArea())

    //Menor sequência de pesagem disponível
    cQuery := ""
    cQuery += " SELECT  " 
    cQuery += " MIN(ZIG_SEQTKT) AS ZIG_SEQTKT "
    cQuery += " FROM  " 
    cQuery += " " + RetSqlName("ZIG") + " (NOLOCK) AS ZIG  " 
    cQuery += " INNER JOIN " 
    cQuery += " " + RetSqlName("ZIR") + " (NOLOCK) AS ZIR ON " 
    cQuery += " ZIG_FILIAL = ZIR_FILIAL " 
    cQuery += " AND ZIG_ORDEM = ZIR_ORDEM " 
    cQuery += " WHERE  " 
    cQuery += " ZIG_FILIAL = '" + FWxFilial("ZIG") + "'  " 
    cQuery += " AND ZIG_CTPATI = '" + cCP + "'  " 
    cQuery += " AND ZIR_ORAGRP = '" + cRoteiro + "' " 
    cQuery += " AND ZIG_INICIA IN ('1', '2', '4') " //Pesagem não iniciada, Peso inicial, sequestrada.
    cQuery += " AND ZIG.D_E_L_E_T_ = '' " 
    cQuery += " AND ZIR.D_E_L_E_T_ = '' " 

    If Select("D_SEQ") > 0
        D_SEQ->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_SEQ"
    DbSelectArea("D_SEQ")

        cSeq := D_SEQ->ZIG_SEQTKT

    D_SEQ->(DbCloseArea())

    RestArea(aArea)

Return {cTicket, cSeq}
/*/{Protheus.doc} ADFAT351
    Retorna placa selecionada.
    @type  User Function
    @author Everson
    @since 01/03/2022
    @version 01
/*/
User Function ADFAT351()
Return Alltrim(cValToChar(cPlaca))
/*/{Protheus.doc} ADFAT35D
    Retorna gavetas já selecionadas.
    @type  User Function
    @author Everson
    @since 01/03/2022
    @version 01
/*/
User Function ADFAT35D()
Return cGavetas
/*/{Protheus.doc} ADFAT35A
    Valida lacre.
    @type  User Function
    @author Everson
    @since 01/03/2022
    @version 01
/*/
User Function ADFAT35A(cOpc, cLacre, oInLacre)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .T.
    Local nLinha    := oOrdPes:nAt
    Local cCP       := ""
    Local cMsgError := ""

    Default cLacre  := ""

    If cOpc == "I" .And. Empty(cLacre)
        RestArea(aArea)
        Return .T.

    EndIF

    If nLinha <= 0
        RestArea(aArea)
        Return .T.
        
    EndIf

    If Len(aOrdPes) <= 0
        RestArea(aArea)
        Return .T.

    EndIf

    cCP    := aOrdPes[nLinha][13]

    If cOpc == "I"
        If ! Empty(cLacre)
            U_ADFAT38A(cCP, cRoteiro, cOrdSlc, cPlaca, cLacre, @cMsgError)

        EndIf

    ElseIf cOpc == "E"
        cLacre := oLacre:aCols[oLacre:nAt, Ascan(aHLacre,{|x| AllTrim(x[2]) == "LACRE" })]
        If ! Empty(cLacre)
            U_ADFAT38B(cRoteiro, cPlaca, cLacre, cOrdSlc, @cMsgError)

        EndIf

    EndIf

    carDados(cOrdSlc)

    oLacre:GoBottom()
    oLacre:GoTop()

    If cOpc == "I"
        lRet := .F.

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT35B
    Valida gaveta.
    @type  User Function
    @author Everson
    @since 01/03/2022
    @version 01
/*/
User Function ADFAT35B(cOpc)

    //Variáveis.
    Local aArea     := GetArea()
    Local nLinha    := oOrdPes:nAt
    Local cCP       := ""
    Local cNmOrdem  := ""
    Local cGaveta   := ""
    Local cMsgError := ""

    If nLinha <= 0
        RestArea(aArea)
        Return .T.
        
    EndIf

    If Len(aOrdPes) <= 0
        RestArea(aArea)
        Return .T.

    EndIf

    If cOpc == "I" .And. ! Pergunte("ADFAT352", .T.)
        RestArea(aArea)
        Return .T.
        
    EndIf

    cCP    := aOrdPes[nLinha][13]
    cNmOrdem := aOrdPes[nLinha][2]

    If cOpc == "I"
        cGaveta := Alltrim(cValToChar(MV_PAR01))
        If ! Empty(cGaveta)

            If U_ADFAT39A(cCP, cRoteiro, cNmOrdem, cPlaca, cGaveta, @cMsgError)

                If ! cGaveta $cGavetas
                    cGavetas += cGavetas + "/"

                EndIf

            EndIf

        EndIf

    ElseIf cOpc == "E"
        cGaveta := oGaveta:aCols[oGaveta:nAt, Ascan(aHGaveta,{|x| AllTrim(x[2]) == "GAVETA" })]
        If ! Empty(cGaveta)
            U_ADFAT39B(cRoteiro, cPlaca, cGaveta, cOrdSlc, @cMsgError)

        EndIf

    EndIf

    carDados(cNmOrdem)
    oGaveta:GoBottom()
    oGaveta:GoTop()

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} ADFAT35C
    Valida silo.
    @type  User Function
    @author Everson
    @since 01/03/2022
    @version 01
/*/
User Function ADFAT35C(cOpc)

    //Variáveis.
    Local aArea     := GetArea()
    Local nLinha    := oOrdPes:nAt
    Local cCP       := ""
    Local cNmOrdem  := ""
    Local cSilo     := ""
    Local cMsgError := ""

    If nLinha <= 0
        RestArea(aArea)
        Return .T.
        
    EndIf

    If Len(aOrdPes) <= 0
        RestArea(aArea)
        Return .T.

    EndIf

    If cOpc == "I" .And. ! Pergunte("ADFAT353", .T.)
        RestArea(aArea)
        Return .T.
        
    EndIf

    cCP    := aOrdPes[nLinha][13]
    cNmOrdem := aOrdPes[nLinha][2]

    If cOpc == "I"
        cSilo := Alltrim(cValToChar(MV_PAR01))
        If ! Empty(cSilo)
            U_ADFAT40A(cCP, cRoteiro, cNmOrdem, cPlaca, cSilo, @cMsgError)
 
        EndIf

    ElseIf cOpc == "E"
        cSilo := oSilo:aCols[oSilo:nAt, Ascan(aHSilo,{|x| AllTrim(x[2]) == "CSILO" })]
        If ! Empty(cSilo)
            U_ADFAT40B(cRoteiro, cPlaca, cNmOrdem, cSilo, @cMsgError)

        EndIf

    EndIf

    carDados(cNmOrdem)
    oSilo:GoBottom()
    oSilo:GoTop()

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} ADFAT35E
    Consulta padrão específica.
    @type  User Function
    @author Everson
    @since 02/03/2022
    @version 01
/*/
User Function ADFAT35E()

    //Variáveis.
    Local oDlg, oLbx
    Local aCpos  := {}
    Local aRet   := {}
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local lRet   := .F.

    cQuery += " SELECT  " 
    cQuery += " ZIR_ORAGRP, ZIR_PLACA, SUM(CASE WHEN ZIG_INICIA = '2' OR (ZIG_INICIA IN ('4','5') AND ZIG_ACASEQ <> 'S' AND ZIG_ACASEQ <> '') THEN 1 ELSE 0 END) AS QTDLIB  " 
    cQuery += " FROM  " 
    cQuery += " " + RetSqlName("ZIR") + " (NOLOCK) AS ZIR " 
    cQuery += " INNER JOIN " 
    cQuery += " " + RetSqlName("ZIF") + " (NOLOCK) AS ZIF ON " 
    cQuery += " ZIR_FILIAL = ZIF_FILIAL " 
    cQuery += " AND ZIR_ORDEM = ZIF_NUMERO " 
    cQuery += " INNER JOIN " 
    cQuery += " " + RetSqlName("ZIB") + " (NOLOCK) AS ZIB ON " 
    cQuery += " ZIF_FILIAL = ZIB_FILIAL " 
    cQuery += " AND ZIF_CTPATI = ZIB_NUMERO " 

    cQuery += " INNER JOIN " 
    cQuery += " " + RetSqlName("ZIG") + " (NOLOCK) AS ZIG ON " 
    cQuery += " ZIR_FILIAL = ZIG_FILIAL " 
    cQuery += " AND ZIR_ORDEM = ZIG_ORDEM " 

    cQuery += " WHERE " 
    cQuery += " ZIR_FILIAL = '" + FWxFilial("ZIR") + "' " 
    cQuery += " AND ZIR_ORAGRP <> '' " 
    cQuery += " AND ZIR_ORDEM <> '' " 
    cQuery += " AND ZIB_STATUS NOT IN ('5','6') " 
    cQuery += " AND ZIR.D_E_L_E_T_ = '' " 
    cQuery += " AND ZIF.D_E_L_E_T_ = '' " 
    cQuery += " AND ZIB.D_E_L_E_T_ = '' " 
    cQuery += " AND ZIG.D_E_L_E_T_ = '' " 
    cQuery += " GROUP BY ZIR_ORAGRP, ZIR_PLACA " 
    cQuery += " ORDER BY  ZIR_ORAGRP " 

    cQuery := ChangeQuery(cQuery)

    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

    While (cAlias)->(!Eof())

        If Val(cValToChar((cAlias)->QTDLIB)) <= 0
            (cAlias)->(DbSkip())
            Loop

        EndIf

        Aadd(aCpos,{(cAlias)->(ZIR_ORAGRP), (cAlias)->(ZIR_PLACA)})

        (cAlias)->(DbSkip())

    End
    (cAlias)->(DbCloseArea())

    If Len(aCpos) < 1
        Aadd(aCpos,{" "," "})

    EndIf

    DEFINE MSDIALOG oDlg TITLE /*STR0083*/ "Roteiro" FROM 0,0 TO 240,500 PIXEL

        @ 10,10 LISTBOX oLbx FIELDS HEADER 'Roteiro' /*"Roteiro"*/, 'Placa' /*"Placa"*/ SIZE 230,95 OF oDlg PIXEL

        oLbx:SetArray( aCpos )
        oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2] }}
        oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2] }}}

    DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2] })  ENABLE OF oDlg
    ACTIVATE MSDIALOG oDlg CENTER

    If Len(aRet) > 0 .And. lRet
        If Empty(aRet[1])
            lRet := .F.

        Else
            ZIR->(DbSetOrder(2))
            ZIR->(DbSeek( FWxFilial("ZIR")+aRet[1]) )

        EndIf

    EndIf

Return lRet
