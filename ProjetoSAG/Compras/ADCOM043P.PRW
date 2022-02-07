#Include "Totvs.ch"
#Include "Topconn.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZIF"
Static cTitulo := "Lib Comercial de Carga"

/*/{Protheus.doc} User Function ADCOM043P
    Liberação comercial de carga
    Lib comercial de carga
    Chamado 18465.
    @type  Function
    @author Everson
    @since 27/12/2021
    @version 01
/*/
User Function ADCOM043P() // U_ADCOM043P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADCOM043P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 27/12/2021
    @version 01
/*/
Static Function BrowseDef()

    //Variáveis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)
    oBrowse:SetFilterDefault("ZIF_STATLA = '4' .AND. ZIF_TPMOVI = 'E'")

    oBrowse:AddLegend("ZIF_STATUS = '4'"  ,"BLUE" , "Pendente")
	oBrowse:AddLegend("ZIF_STATUS = '5'"  ,"GREEN", "Aprovada")
	oBrowse:AddLegend("ZIF_STATUS = '14'" ,"RED"  , "Reprovada")

    oBrowse:SetMenuDef("ADCOM043P")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 27/12/2021
    @version 01
/*/
Static Function MenuDef()

    //Variáveis.
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Pesquisar"        ACTION "PesqBrw"          	OPERATION 1   ACCESS 0
	ADD OPTION aRotina TITLE "Liberar/Reprovar" ACTION "U_ADCOM431()" 	    OPERATION 10 ACCESS 0

Return aRotina
/*/{Protheus.doc} User Function ADCOM431
    Rotina para aprovação/reprovação.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 27/12/2021
    @version 01
/*/
User Function ADCOM431()

    //Variáveis.
    Local oLibCom   := Nil
    Local oFechar   := Nil
    Local oPnMaster := Nil
    Local oPesagens := Nil
    Local aPesagens := {}
    Local cObservao := Space(100)
    Local cNmOrdem  := Iif(!Empty(ZIF->ZIF_AGRUPA), ZIF->ZIF_AGRUPA, ZIF->ZIF_NUMERO)
    Local lAgrupa   := Iif(!Empty(ZIF->ZIF_AGRUPA), .T., .F.)
    Local oFont     := TFont():New(,,-18,,.F.)
    
    Private oAutoriza  := Nil
    Private oReprova   := Nil

    aPesagens := carDados(cNmOrdem, lAgrupa)

    If Len(aPesagens) <= 0
        MsgInfo("Não há dados.", "Função ADCOM431(ADCOM043P)")
        Return Nil

    EndIf

    oLibCom			  := MsDialog():Create()
	oLibCom:cName     := "oLibCom"
	oLibCom:cCaption  := "Aprovação Análise Comercial"
	oLibCom:nLeft     := 34
	oLibCom:nTop      := 222
	oLibCom:nWidth    := 1200
	oLibCom:nHeight   := 600
	oLibCom:lShowHint := .F.
	oLibCom:lCentered := .T.

        TSay():New(010,005,{||"Ordem/Agrupamento " + cNmOrdem},oLibCom,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)

        oPnMaster := TPanel():New(030,005,,oLibCom,,,,,,590,200)
 
        oPesagens := FwBrowse():New()
        oPesagens:setOwner(oPnMaster)
        oPesagens:setDataArray()
        oPesagens:setArray(aPesagens)
        oPesagens:disableConfig()
        oPesagens:disableReport()
    
        // oPesagens:AddMarkColumns({|| Iif(aPesagens[oPesagens:nAt,01], "LBOK", "LBNO")},;
        //                           {|| selecReg(oPesagens, @aPesagens)},;
        //                           {||  })
    
        oPesagens:addColumn({"Nota Fiscal"   , {||aPesagens[oPesagens:nAt,02]}, "C", "", 1, 012, , .T., , .F.,, "aPesagens[oPesagens:nAt,02]",, .F., .T., , "ID02" })
        oPesagens:addColumn({"Fornecedor"    , {||aPesagens[oPesagens:nAt,03]}, "C", "", 1, 035, , .T., , .F.,, "aPesagens[oPesagens:nAt,03]",, .F., .T., , "ID03" })
        oPesagens:addColumn({"Produto"       , {||aPesagens[oPesagens:nAt,04]}, "C", "", 1, 035, , .T., , .F.,, "aPesagens[oPesagens:nAt,04]",, .F., .T., , "ID04" })
        oPesagens:addColumn({"Exame"         , {||aPesagens[oPesagens:nAt,05]}, "C", "", 1, 010, , .T., , .F.,, "aPesagens[oPesagens:nAt,05]",, .F., .T., , "ID05" })
        oPesagens:addColumn({"Tipo"          , {||aPesagens[oPesagens:nAt,06]}, "C", "", 1, 008, , .T., , .F.,, "aPesagens[oPesagens:nAt,06]",, .F., .T., , "ID06" })
        oPesagens:addColumn({"Resultado"     , {||aPesagens[oPesagens:nAt,07]}, "C", "", 1, 060, , .T., , .F.,, "aPesagens[oPesagens:nAt,07]",, .F., .T., , "ID07" })
        oPesagens:addColumn({"Valor/Texto"   , {||aPesagens[oPesagens:nAt,08]}, "C", "", 1, 010, , .T., , .F.,, "aPesagens[oPesagens:nAt,08]",, .F., .T., , "ID08" })
        oPesagens:addColumn({"Data Análise"  , {||aPesagens[oPesagens:nAt,09]}, "D", "", 1, 010, , .T., , .F.,, "aPesagens[oPesagens:nAt,09]",, .F., .T., , "ID09" })
        oPesagens:addColumn({"Padrão Mínimo" , {||aPesagens[oPesagens:nAt,10]}, "N", "@E 999,999.999", 1, 011, , .T., , .F.,, "aPesagens[oPesagens:nAt,10]",, .F., .T., , "ID10" })
        oPesagens:addColumn({"Padrão Máximo" , {||aPesagens[oPesagens:nAt,11]}, "N", "@E 999,999.999", 1, 011, , .T., , .F.,, "aPesagens[oPesagens:nAt,11]",, .F., .T., , "ID11" })

        oPesagens:Activate()

        TGet():New(250,005,{|u|If(PCount() == 0,cObservao,cObservao := u)}, oLibCom, 255,015,"",,0,16777215,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F. ,,"cObservao",,,,.T.,,,"Obs.:",1)  

        oAutoriza := TButton():New(270,465,"Autorizar",  oLibCom,{|| Iif(!confirmar(cNmOrdem, lAgrupa, cObservao), Nil, oLibCom:End()), carDados(cNmOrdem, lAgrupa) },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )
        
        oReprova  := TButton():New(270,510,"Reprovar"  , oLibCom,{|| Iif(!reprovar(cNmOrdem, lAgrupa, cObservao),  Nil, oLibCom:End()), carDados(cNmOrdem, lAgrupa) },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )

        oFechar := TButton():New(270,555,"Fechar", oLibCom,{|| oLibCom:End() },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )
        oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")	

    oLibCom:Activate(,,,.T.,{||.T.},, {|| })

Return Nil
/*/{Protheus.doc} carDados
    Carrega dados da análise.
    @type  Static Function
    @author Everson
    @since 29/12/2021
    @version 01
/*/
Static Function carDados(cNmOrdem, lAgrupa)

    //Variáveis.
    Local aDados    := {}
    Local cQuery    := " SELECT DISTINCT ZIF_PRDPRO, ZIF_PRDSAG,ZIF_ENVBAR, ZIF_FORNEC, ZIF_LJFORN, ZIF_NMFOR, ZIF_NF, ZIF_SERIE FROM " + RetSqlName("ZIF") + " (NOLOCK) AS ZIF WHERE ZIF_FILIAL = '" + FWxFilial("ZIF") + "' AND (ZIF_NUMERO = '" + cNmOrdem + "' OR ZIF_AGRUPA = '" + cNmOrdem + "') AND ZIF.D_E_L_E_T_ = '' "
    Local cProduto  := ""

    If Select("D_ORDEM") > 0
        D_ORDEM->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_ORDEM"
    DbSelectArea("D_ORDEM")
    D_ORDEM->(DbGoTop())
    While ! D_ORDEM->(Eof())

        cProduto := U_ADFT176(, D_ORDEM->ZIF_PRDPRO)

        Aadd(aDados,{;
            .F.,; //01-Flag.
            D_ORDEM->ZIF_NF + " " + D_ORDEM->ZIF_SERIE,; //02-Nota fiscal.
            D_ORDEM->ZIF_FORNEC + " " + D_ORDEM->ZIF_LJFORN + " " + D_ORDEM->ZIF_NMFOR,; //03-Fornecedor.
            cProduto,; //04-Produto.
            Nil,; //05-Exame.
            Nil,; //06-Tipo.
            Nil,; //07-Resultado.
            Nil,; //08-Valor/Texto.
            Nil,; //09-Data Análise.
            Nil,; //10-Padrão Mínimo.
            Nil;  //11-Padrão Máximo.
        })

        D_ORDEM->(DbSkip())

    End
    D_ORDEM->(DbCloseArea())

Return aDados
/*/{Protheus.doc} selecReg
    Marca registro.
    @type  Static Function
    @author Everson
    @since 27/12/2021
    @version 01
/*/
Static Function selecReg(oBrowse, aArquivo)

    //Variáveis.
    Local nAux      := 1
    Local nLinha    := oBrowse:nAt
    Local lMarca    := !aArquivo[oBrowse:nAt,1]

    aArquivo[oBrowse:nAt,01] := lMarca
    
    For nAux := 1 To Len(aArquivo)

        If nAux <> nLinha
            aArquivo[oBrowse:nAt,01] := .F.

        EndIf

    Next nAux

    If ! lMarca
        oAutoriza:disable()
        oReprova:disable()

    Else
        oAutoriza:enable()
        oReprova:enable()

    EndIf

    oBrowse:Refresh()

Return Nil
/*/{Protheus.doc} confirmar
    Processa a ação de aprovação.
    @type  Static Function
    @author Everson
    @since 27/12/2021
    @version 01
/*/
Static Function confirmar(cNmOrdem, lAgrupa, cObservao)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .T.

    If ZIF->ZIF_STATUS <> "4"
        MsgInfo("Registro já passou pelo processo de aprovação.", "Função confirmar(ADCOM043P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If ! MsgYesNo("Deseja aprovar?", "Função confirmar(ADCOM043P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If ! lAgrupa
        lRet := U_ADFT164(cNmOrdem, "5", 1)

    Else

        DbSelectArea("ZIF")
        ZIF->(DbSetOrder(3))
        If ! ZIF->( DbSeek( FWxFilial("ZIF") + cNmOrdem ) )
            MsgInfo("Agrupador " + cNmOrdem + " não localizado.", "Função confirmar(ADCOM043P)")
            RestArea(aArea)
            Return .F.

        EndIf

        Begin Transaction

            While ! ZIF->(Eof()) .And. ZIF->ZIF_FILIAL == FWxFilial("ZIF") .And. ZIF->ZIF_AGRUPA == cNmOrdem

                lRet := U_ADFT164(ZIF->ZIF_NUMERO, "5", 1)
                If ! lRet
                    DisarmTransaction()
                    Break

                EndIf

                ZIF->(DbSkip())

            End

        End Transaction

    EndIf
 
    RestArea(aArea)

Return lRet
/*/{Protheus.doc} reprovar
    Processa a ação de reprovação.
    @type  Static Function
    @author Everson
    @since 27/12/2021
    @version 01
/*/
Static Function reprovar(cNmOrdem, lAgrupa, cObservao)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .T.

    If ZIF->ZIF_STATUS <> "4"
        MsgInfo("Registro já passou pelo processo de aprovação.", "Função reprovar(ADCOM043P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If ! MsgYesNo("Deseja reprovar?", "Função reprovar(ADCOM043P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If ! lAgrupa
        lRet := U_ADFT164(cNmOrdem, "5", 1)

    Else

        DbSelectArea("ZIF")
        ZIF->(DbSetOrder(3))
        If ! ZIF->( DbSeek( FWxFilial("ZIF") + cNmOrdem ) )
            MsgInfo("Agrupador " + cNmOrdem + " não localizado.", "Função reprovar(ADCOM043P)")
            RestArea(aArea)
            Return .F.

        EndIf

        Begin Transaction

            While ! ZIF->(Eof()) .And. ZIF->ZIF_FILIAL == FWxFilial("ZIF") .And. ZIF->ZIF_AGRUPA == cNmOrdem

                lRet := U_ADFT164(ZIF->ZIF_NUMERO, "14", 1)
                If ! lRet
                    DisarmTransaction()
                    Break
                    
                EndIf

                ZIF->(DbSkip())

            End

        End Transaction

    EndIf
 
    RestArea(aArea)

Return lRet
