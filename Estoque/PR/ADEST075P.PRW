#Include "Totvs.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} User Function ADEST075P
    Liberação de sequestro de pesagem.
    Lib sequestro pesagem
    Chamado 18465.
    @type  Function
    @author Everson
    @since 05/04/2022
    @version 01
/*/
User Function ADEST075P() // U_ADEST075P()

    //Variáveis.
    Local oLibSeq   := Nil
    Local oFechar   := Nil
    Local oPnMaster := Nil
    Local oPesagens := Nil
    Local aPesagens := {}
    Local oDtIni    := Nil
    Local dDtIni    := Date()-30
    Local oDtFim    := Nil
    Local dDtFim    := Date()
    Local cObservao := Space(100)
    Local aRadio    := {}
    Local oFilDest  := Nil
    Local cFilDest  := ""
    Local aFilDest  := getFiliais(cEmpAnt)
    
    Private oConfirm  := Nil
    Private oRadio    := Nil
    Private nRadio    := 1
    Private nQtdOrd   := 0
    Private nQtdBal   := 0
    Private nQtdDif   := 0
    Private nPerTot   := 0
    Private nPerDif   := 0

    oLibSeq			  := MsDialog():Create()
	oLibSeq:cName     := "oLibSeq"
	oLibSeq:cCaption  := "Liberação de Pesagens Sequestradas"
	oLibSeq:nLeft     := 34
	oLibSeq:nTop      := 222
	oLibSeq:nWidth    := 1200
	oLibSeq:nHeight   := 600
	oLibSeq:lShowHint := .F.
	oLibSeq:lCentered := .T.

        oDtIni := TGet():New(003,005,{|u|If(PCount() == 0,dDtIni,dDtIni := u)}, oLibSeq,070,010,"@D",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtIni",,,,.T.,,,"Data Inicial",1) 

        oDtFim := TGet():New(003,080,{|u|If(PCount() == 0,dDtFim,dDtFim := u)}, oLibSeq,070,010,"@D",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtFim",,,,.T.,,,"Data Final",1) 

        TButton():New(010,155,"Filtrar", oLibSeq,{||;
            MsAguarde({|| carPesagens(dDtIni, dDtFim, oPesagens, @aPesagens) }, "Aguarde", "Carregando registros...");
        },035,011,,,.F.,.T.,.F.,,.F.,,,.F. )

        TGet():New(003,195,{|u|If(PCount() == 0,nQtdOrd,nQtdOrd := u)}, oLibSeq, 070,015,"@E 999,999,999.999",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nQtdOrd",,,,.T.,,,"Qtde. Ordem",1)  
        TGet():New(003,270,{|u|If(PCount() == 0,nQtdBal,nQtdBal := u)}, oLibSeq, 070,015,"@E 999,999,999.999",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nQtdBal",,,,.T.,,,"Qtde. Balança",1)  
        TGet():New(003,345,{|u|If(PCount() == 0,nQtdDif,nQtdDif := u)}, oLibSeq, 070,015,"@E 999,999,999.999",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nQtdDif",,,,.T.,,,"Qtde. Diferença",1)  
        TGet():New(003,420,{|u|If(PCount() == 0,nPerTot,nPerTot := u)}, oLibSeq, 070,015,"@E 999,999,999.999",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nPerTot",,,,.T.,,,"%Tot",1)  
        TGet():New(003,495,{|u|If(PCount() == 0,nPerDif,nPerDif := u)}, oLibSeq, 070,015,"@E 999,999,999.999",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nPerDif",,,,.T.,,,"%Dif",1)  

        oPnMaster := TPanel():New(030,005,,oLibSeq,,,,,,590,200)
 
        oPesagens := FwBrowse():New()
        oPesagens:setOwner(oPnMaster)
        oPesagens:setDataArray()
        oPesagens:setArray(aPesagens)
        oPesagens:disableConfig()
        oPesagens:disableReport()
    
        oPesagens:AddMarkColumns({|| Iif(aPesagens[oPesagens:nAt,01], "LBOK", "LBNO")},;
                                  {|| selecReg(oPesagens, @aPesagens)})
    
        oPesagens:addColumn({"Data"              , {||aPesagens[oPesagens:nAt,02]}, "D", ""                  , 1, 010    ,   , .T. , , .F.,, "aPesagens[oPesagens:nAt,02]",, .F., .T., , "ID2" })
        oPesagens:addColumn({"Hora"              , {||aPesagens[oPesagens:nAt,03]}, "C", ""                  , 1, 008    ,   , .T. , , .F.,, "aPesagens[oPesagens:nAt,03]",, .F., .T., , "ID3" })
        oPesagens:addColumn({"Produto"           , {||aPesagens[oPesagens:nAt,04]}, "C", ""                  , 1, 060    ,   , .T. , , .F.,, "aPesagens[oPesagens:nAt,04]",, .F., .T., , "ID4" })
        oPesagens:addColumn({"Ordem/Agrup."      , {||aPesagens[oPesagens:nAt,05]}, "C", ""                  , 1, 010    ,   , .T. , , .F.,, "aPesagens[oPesagens:nAt,05]",, .F., .T., , "ID5" })
        oPesagens:addColumn({"Tipo"              , {||aPesagens[oPesagens:nAt,15]}, "C", ""                  , 1, 005    ,   , .T. , , .F.,, "aPesagens[oPesagens:nAt,15]",, .F., .T., , "ID15"})
        oPesagens:addColumn({"Operação"          , {||aPesagens[oPesagens:nAt,06]}, "C", ""                  , 1, 020    ,   , .T. , , .F.,, "aPesagens[oPesagens:nAt,06]",, .F., .T., , "ID6" })
        oPesagens:addColumn({"Veículo"           , {||aPesagens[oPesagens:nAt,07]}, "C", ""                  , 1, 007    ,   , .T. , , .F.,, "aPesagens[oPesagens:nAt,07]",, .F., .T., , "ID7" })
        oPesagens:addColumn({"Peso Inicial"      , {||aPesagens[oPesagens:nAt,08]}, "N", "@E 999,999,999.999", 2, 015    ,   , .T. , , .F.,, "aPesagens[oPesagens:nAt,08]",, .F., .T., , "ID8" })
        oPesagens:addColumn({"Peso Final"        , {||aPesagens[oPesagens:nAt,09]}, "N", "@E 999,999,999.999", 2, 015    ,   , .T. , , .F.,, "aPesagens[oPesagens:nAt,09]",, .F., .T., , "ID9" })
        oPesagens:addColumn({"Peso Liquido"      , {||aPesagens[oPesagens:nAt,10]}, "N", "@E 999,999,999.999", 2, 015    ,   , .T. , , .F.,, "aPesagens[oPesagens:nAt,10]",, .F., .T., , "ID10"})

        oPesagens:Activate()
        
        aRadio := {"Desconto Financeiro","Quebra de Estoque",;
                   "Devolução Fornecedor","Transferência Filial",;
                   "Liberação Fábrica", "Complemento Fornecedor"}

        oRadio := TRadMenu():New (235,005,aRadio,,oLibSeq,,,,,,,,500,15,,,,.T.)
        oRadio:bSetGet := {|u| Iif(PCount() == 0, nRadio, nRadio := u)}
        oRadio:lHoriz := .T.
        oRadio:bChange := {|| Iif(nRadio <> 4 , oFilDest:disable(), oFilDest:enable()) }
        oRadio:disable()

        TGet():New(250,005,{|u|If(PCount() == 0,cObservao,cObservao := u)}, oLibSeq, 255,015,"",,0,16777215,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F. ,,"cObservao",,,,.T.,,,"Obs.:",1)  

	    oFilDest := TComboBox():New(250,265,{|u|if(PCount() > 0 ,cFilDest := u,cFilDest)},;
	    aFilDest,100,15, oLibSeq,,{|| },,,,.T.,,,,/*{|| nRadio == 4 }*/,,,,,"cFilDest","Filial Destino",1)

        oFechar := TButton():New(270,510,"Fechar", oLibSeq,{|| oLibSeq:End() },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )
        oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")	

        oConfirm := TButton():New(270,555,"Confirmar", oLibSeq,{|| Iif( ! confirmar(oPesagens, aPesagens, nRadio, cObservao), Nil, Eval({||carPesagens(dDtIni, dDtFim, oPesagens, @aPesagens), zeraDados()}) ) },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )
        oConfirm:disable()

    oLibSeq:Activate(,,,.T.,{||.T.},, {|| carPesagens(dDtIni, dDtFim, oPesagens, @aPesagens) })

Return Nil
/*/{Protheus.doc} getFiliais
    Retorna filiais.
    @type  Static Function
    @author Everson
    @since 05/04/2022
    @version 01
/*/
Static Function getFiliais(cEmp)

    //Variáveis.
    Local aArea     := GetArea()
    Local aFiliais  := {}
    Local aFilAux   := FWAllFilial()
    Local nAux      := 1
    Local aSM0Data2 := {}

    For nAux := 1 To Len(aFilAux)

        aSM0Data2 := FWSM0Util():GetSM0Data(cEmp, aFilAux[nAux])

        Aadd(aFiliais, Alltrim(cValToChar(aSM0Data2[2][2])) + "=" + Alltrim(cValToChar(aSM0Data2[3][2])))

    Next nAux

    RestArea(aArea)

Return aFiliais
/*/{Protheus.doc} carPesagens
    Carrega registros de pesagens s equestradas.
    @type  Static Function
    @author Everson
    @since 05/04/2022
    @version 01
/*/
Static Function carPesagens(dDtIni, dDtFim, oPesagens, aPesagens)

    //Variáveis.
    Local aArea     := GetArea()
    Local cQuery    := ""
    Local cProduto  := ""
    Local cOperacao := ""
    Local nIndex    := 0

    cQuery    := " SELECT * FROM " + RetSqlName("ZIG") + " (NOLOCK) AS ZIG WHERE ZIG_FILIAL = '" + FWxFilial("ZIG") + "' AND ZIG_DTPES2 >= '" + DToS(dDtIni) + "' AND ZIG_DTPES2 <= '" + DToS(dDtFim) + "' AND ZIG_INICIA = '4' AND ZIG_TPSEQU = '1' AND ZIG.D_E_L_E_T_ = '' ORDER BY ZIG_ORDEM "

    aPesagens := {}

    If Select("D_PES") > 0 
        D_PES->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_PES"
    DbSelectArea("D_PES")
    While ! D_PES->(Eof())

        nIndex := Iif(D_PES->ZIG_AGRUPA == "1", 3, 2)
        cProduto := getDes(D_PES->ZIG_ORDEM, nIndex)

        If ! U_ADFAT17U(D_PES->ZIG_CTPATI)
            D_PES->(DbSkip())
            Loop
            
        EndIf

        If ZIG->ZIG_TPMOV == "R" .And. ZIB->ZIB_STATUS == "6"
            D_PES->(DbSkip())
            Loop

        EndIf

        cOperacao := Alltrim(cValToChar(Posicione("ZI9", 1, FWxFilial("ZI9") + ZIB->ZIB_CODROT, "ZI9_ROTEIR")))

        Aadd(aPesagens,{;
            .F.,;                       //01 - Marcação.
            SToD(D_PES->ZIG_DTPES2),;   //02 - Data da última pesagem.
            D_PES->ZIG_HRPES2,;         //03 - Hora da última pesagem.
            cProduto,;                  //04 - Produtos.
            D_PES->ZIG_ORDEM,;          //05 - Ordem de pesagem.
            cOperacao,;                 //06 - Operação.
            D_PES->ZIG_PLACA,;          //07 - Placa.
            D_PES->ZIG_PESINI,;         //08 - Pesagem inicial.
            D_PES->ZIG_PESFIM,;         //09 - Pesagem final.
            D_PES->ZIG_PESOLI,;         //10 - Peso liquido.
            D_PES->ZIG_PESORD,;         //11 - Peso da ordem.
            D_PES->ZIG_UNTOLE,;         //12 - Unidade de medida da tolerância.
            D_PES->ZIG_QTTOLE,;         //13 - Tolerância.
            D_PES->ZIG_QUEBRA,;         //14 - Quebra.
            D_PES->ZIG_TPMOV,;          //15 - Tipo movimento.
            D_PES->ZIG_AGRUPA,;         //16 - Agrupada.
            D_PES->ZIG_NUMERO;          //17 - Número do ticket de pesagem.
        })

        D_PES->(DbSkip())

    End
    D_PES->(DbCloseArea())

    oPesagens:setArray(aPesagens)
    oPesagens:Refresh()

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} getDes
    Carrega produtos.
    @type  Static Function
    @author Everson
    @since 05/04/2022
    @version 01
/*/
Static Function getDes(cNmOrdem, nIndex)

    //Variáveis.
    Local aArea     := GetArea()
    Local cProduto  := ""

    DbSelectArea("ZIF")
    ZIF->(DbSetOrder(nIndex))
    If ! ZIF->( DbSeek( FWxFilial("ZIF") + cNmOrdem ) )
        MsgInfo("Ordem/agrupador " + cNmOrdem + " não localizada(o).", "Função getDes(ADEST075P)")
        RestArea(aArea)
        RestArea(aArea)

    EndIf

    If nIndex == 2

         cProduto := U_ADFAT176(ZIF->ZIF_PRDSAG, ZIF->ZIF_PRDPRO)

    ElseIf nIndex == 3

        While ! ZIF->(Eof()) .And. FWxFilial("ZIF") == ZIF->ZIF_FILIAL .And. ZIF->ZIF_AGRUPA == cNmOrdem

            cProduto += U_ADFAT176(ZIF->ZIF_PRDSAG, ZIF->ZIF_PRDPRO) + Space(1)

            ZIF->(DbSkip())

        End

    EndIf

    RestArea(aArea)

Return cProduto
/*/{Protheus.doc} selecReg
    Marca registro.
    @type  Static Function
    @author Everson
    @since 05/04/2022
    @version 01
/*/
Static Function selecReg(oBrowse, aArquivo)

    //Variáveis.
    Local nAux      := 1
    Local nLinha    := oBrowse:nAt
    Local lMarca    := !aArquivo[oBrowse:nAt,1]
    Local nPerCTol  := 0
    Local nPerCDif  := 0
    Local cTpMovi   := Alltrim(cValToChar(aArquivo[oBrowse:nAt,15]))

    aArquivo[oBrowse:nAt,01] := lMarca
    
    For nAux := 1 To Len(aArquivo)

        If nAux <> nLinha
            aArquivo[nAux, 01] := .F.

        EndIf

    Next nAux

    If !lMarca
        
        zeraDados()
        oRadio:setOption(1)
        oRadio:disable()
        oConfirm:disable()

    Else

        If aArquivo[oBrowse:nAt,12] == "PC"
            nPerCTol := aArquivo[oBrowse:nAt,13]

        Else
            nPerCTol := Iif(aArquivo[oBrowse:nAt,11] == 0, 0, Round(aArquivo[oBrowse:nAt,13]/aArquivo[oBrowse:nAt,11] * 100,2))

        EndIf

        nPerCDif := Iif(aArquivo[oBrowse:nAt,11] == 0, 0, Round(aArquivo[oBrowse:nAt,14]/aArquivo[oBrowse:nAt,11] * 100,2))

        nQtdOrd   := aArquivo[oBrowse:nAt,11]
        nQtdBal   := aArquivo[oBrowse:nAt,10]
        nQtdDif   := aArquivo[oBrowse:nAt,14]
        nPerTot   := nPerCTol
        nPerDif   := nPerCDif

        oRadio:enable()

        If cTpMovi == "E"
            oRadio:setOption(1)
            oRadio:enableItem(5, .F.)

            oConfirm:enable()

        ElseIf cTpMovi == "O"
            oRadio:setOption(1)
            oRadio:enableItem(5, .T.)

            oConfirm:enable()

        ElseIf cTpMovi == "R"
            oRadio:enableItem(1, .F.)
            oRadio:enableItem(2, .F.)
            oRadio:enableItem(3, .F.)
            oRadio:enableItem(4, .F.)
            oRadio:enableItem(5, .T.)
            oRadio:enableItem(6, .F.)
            oRadio:setOption(5)
            
            oConfirm:enable()

        ElseIf cTpMovi == "S"
            oRadio:disable()
            oConfirm:disable()

        EndIf

    EndIf

    oBrowse:Refresh()

Return Nil
/*/{Protheus.doc} zeraDados
    Zera variáveis do cabeçalho da interface.
    @type  Static Function
    @author Everson
    @since 05/04/2022
    @version 01
/*/
Static Function zeraDados()

    nQtdOrd   := 0
    nQtdBal   := 0
    nQtdDif   := 0
    nPerTot   := 0
    nPerDif   := 0

Return Nil
/*/{Protheus.doc} confirmar
    Processa a ação da liberação do sequestro da pesagem.
    @type  Static Function
    @author Everson
    @since 05/04/2022
    @version 01
/*/
Static Function confirmar(oPesagens, aPesagens, nRadio, cObservao)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local cTicket   := ""
    Local aDados    := ""
    Local nAux      := 1
    Local cNmOrdem  := ""

    If nRadio == Nil .Or. nRadio <= 0
        MsgInfo("Selecione uma opção.", "Função confirmar(ADEST075P)")
        RestArea(aArea)
        Return .F.

    EndIf

    For nAux := 1 To Len(aPesagens)
        If aPesagens[nAux,01]
            aDados := AClone(aPesagens[nAux])

        EndIf

    Next nAux

    If Len(aDados) <= 0
        MsgInfo("Selecione uma pesagem sequestrada.", "Função confirmar(ADEST075P)")
        RestArea(aArea)
        Return .F.

    EndIf

    cNmOrdem := aDados[5]

    If ! MsgYesNo("Deseja liberar a ordem de pesagem " + cNmOrdem + ".", "Função confirmar(ADEST075P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If nRadio == 1 //Desconto financeiro.
        lRet := descFin(oPesagens, aPesagens, @cTicket)

    ElseIf nRadio == 2 //Quebra de estoque.
        lRet := lancQbr(cNmOrdem, aDados, nRadio, cObservao)

    ElseIf nRadio == 3 //Devolução Fornecedor.
        lRet := devFor()

    ElseIf nRadio == 4 //Transferência Filial.
        lRet := transFil()

    ElseIf nRadio == 5 //Liberaçãõ Fábrica.
        lRet := libFabr(cNmOrdem, aDados, nRadio, cObservao)

    ElseIf nRadio == 6 //Complemento Fornecedor.
        lRet := compForn()

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} descFin
    Efetua desconto financeiro.
    @type  Static Function
    @author Everson
    @since 05/04/2022
    @version 01
/*/
Static Function descFin(oPesagens, aPesagens, cTicket)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local nAux      := 1
    Local cNmOrdem  := ""
    Local nIndex    := 0
    Local cTitulo   := ""
    Local cFornec   := ""
    Local cLoja     := ""
    Local cCond     := ""
    Local nTotLiq   := 0
    Local cHist     := ""
    Local cNaturez  := ""
    Local cItemC    := ""
    Local cCTADeb   := ""
    Local cCTACre   := ""
    Local cCCC      := ""
    Local cStatOrd  := ""

    For nAux := 1 To Len(aPesagens)

        If aPesagens[nAux][1]

            cNmOrdem := Alltrim(cValToChar(aPesagens[nAux][5]))
            nIndex   := Iif(aPesagens[nAux][16] == "1", 3, 2)
            cTicket  := Alltrim(cValToChar(aPesagens[nAux][17]))

        EndIf

    Next nAux

    If nAux > 2
        MsgInfo("Há mais de um registro selecionado.","Função descFin(ADEST075P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(cNmOrdem)
        MsgInfo("Ordem de pesagem não selecionada.","Função descFin(ADEST075P)")
        RestArea(aArea)
        Return .F.

    EndIf

    DbSelectArea("ZIF")
    ZIF->(DbSetOrder(nIndex))
    If ! ZIF->( DbSeek( FWxFilial("ZIF") + cNmOrdem ) )
        MsgInfo("Ordem de pesagem " + cNmOrdem + " não localizada.","Função descFin(ADEST075P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If ZIF->ZIF_TPMOVI == "O"
        cStatOrd := "7"

    ElseIf ZIF->ZIF_TPMOVI == "E"
        cStatOrd := "13"

    ElseIf ZIF->ZIF_TPMOVI == "S"
        cStatOrd := ""

    ElseIf ZIF->ZIF_TPMOVI == "R"
        cStatOrd := ""

    EndIf

    Begin Transaction

        If nIndex == 2
            cFornec   := ZIF->ZIF_FORNEC
            cLoja     := ZIF->ZIF_LJFORN

            lRet := pDescFin(cTitulo, cFornec, cLoja, cCond, nTotLiq, cHist, cNaturez, cItemC, cCTADeb, cCTACre, cCCC)

            If ! lRet
                DisarmTransaction()
                Break

            EndIf

        ElseIf nIndex == 3

            While ! ZIF->(Eof()) .And. FWxFilial("ZIF") == ZIF->ZIF_FILIAL .And. ZIF->ZIF_AGRUPA == cNmOrdem

                cFornec := ZIF->ZIF_FORNEC
                cLoja   := ZIF->ZIF_LJFORN

                lRet := pDescFin(cTitulo, cFornec, cLoja, cCond, nTotLiq, cHist, cNaturez, cItemC, cCTADeb, cCTACre, cCCC)

                If ! lRet
                    DisarmTransaction()
                    Break
                    
                EndIf

                If ! U_ADFAT165(ZIF->ZIF_NUMERO, "ZIF_STATUS", cStatOrd, "") //Atualiza status da ordem de pesagem.
                    DisarmTransaction()
                    Break

                EndIf

                ZIF->(DbSkip())

            End

        EndIf

        If ! U_ADFAT191(cTicket, "ZIG_INICIA", "5") //Atualiza status do ticket de pesagem.
            DisarmTransaction()
            Break

        EndIf

    End Transaction

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} pDescFin
    Processa desconto financeiro.
    @type  Static Function
    @author Everson
    @since 05/04/2022
    @version 01
/*/
Static Function pDescFin(cTitulo, cFornec, cLoja, cCond, nTotLiq, cHist, cNaturez, cItemC, cCTADeb, cCTACre, cCCC)

	//Variáveis.
	Local aArea	 	:= GetArea()
	Local lRet		:= .F.
	Local aArray 	:= {}
	Local dData		:= Nil
	Local aRet		:= {}
	Local cParcela	:= Padl("1",TamSX3("E2_PARCELA")[1],"0")
	Local cQuery	:= ""
	
	Private lMsErroAuto := .F.

    return .T.
	
	If Empty(cNaturez) .Or. Empty(cItemC) .Or. Empty(cCTADeb) .Or. Empty(cCTACre) .Or. Empty(cCCC)
		MsgInfo("Há parâmetro(s), para lançamento de NDF, não parametrizados.","Função pDescFin(ADEST075P)")
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	cQuery += " SELECT  " 
	cQuery += " MAX(E2_PARCELA) AS E2_PARCELA  " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SE2") + " (NOLOCK) AS SE2 " 
	cQuery += " WHERE " 
	cQuery += " E2_FILIAL = '" + FWxFilial("SE2") + "' " 
	cQuery += " AND E2_PREFIXO = 'MAN' " 
	cQuery += " AND E2_NUM = '" + cTitulo + "' " 
	cQuery += " AND E2_TIPO = 'NDF' " 
	cQuery += " AND E2_FORNECE = '" + cFornec + "' " 
	cQuery += " AND E2_LOJA    = '" + cLoja + "' " 
	cQuery += " AND SE2.D_E_L_E_T_ = '' " 
	
	If Select("D_PARCSE2") > 0
		D_PARCSE2->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "D_PARCSE2"
	DbSelectArea("D_PARCSE2")
	D_PARCSE2->(DbGoTop())
		cParcela := Soma1( Iif( Empty(Alltrim(cValToChar(D_PARCSE2->E2_PARCELA))),"0",Alltrim(cValToChar(D_PARCSE2->E2_PARCELA)) ) )
		cParcela := Padl(cParcela,TamSX3("E2_PARCELA")[1],"0")
	D_PARCSE2->(DbCloseArea())

    aRet := Condicao(nTotLiq,cCond,,Date())
	
	dData := aRet[1][1]
	
	aArray := { { "E2_PREFIXO"  , "MAN"     , Nil },;
	            { "E2_NUM"      , cTitulo   , Nil },;
	            { "E2_PARCELA"  , cParcela  , Nil },;
	            { "E2_TIPO"     , "NDF"     , Nil },;
	            { "E2_NATUREZ"  , cNaturez  , Nil },;
	            { "E2_FORNECE"  , cFornec   , Nil },;
	            { "E2_LOJA"     , cLoja     , Nil },;
	            { "E2_EMISSAO"  , Date()    , Nil },;
	            { "E2_HIST"     , cHist     , Nil },;
	            { "E2_VENCTO"   , dData     , Nil },;
	            { "E2_VENCREA"  , dData     , Nil },;
	            { "E2_VALOR"    , nTotLiq   , Nil },;		                        
	            { "E2_ITEMD"    , cItemC    , Nil },;
	            { "E2_ITEMC"    , cItemC    , Nil },;
	            { "E2_DEBITO"   , cCTADeb   , Nil },;
	            { "E2_CREDIT"   , cCTACre   , Nil },;
	            { "E2_CCC"      , cCCC      , Nil }}
	
	// aArray := FWVetByDic(aArray ,"SE2", .F., 1)
	// SetFunName("FINA050")
	// MsExecAuto( {|x,y,z| FINA050(x,y,z)}, aArray,, 3)
	 
	If lMsErroAuto
	    MostraErro()
	
    Else
        lRet := .T.
	    
	EndIf

Return lRet
/*/{Protheus.doc} lancQbr
    Lança quebra de estoque.
    @type  Static Function
    @author Everson
    @since 05/04/2022
    @version 01
/*/
Static Function lancQbr(cNmOrdem, aDados, nRadio, cObservao)
    
    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local cTicket   := aDados[17]
    Local cQuery    := ""

    If U_ADFAT16A(cNmOrdem)

        Begin Transaction

            lRet := procLib(cNmOrdem, cTicket, aDados, nRadio, cObservao)

            If ! lRet
                DisarmTransaction()
                Break

            EndIf

        End Transaction

    ElseIf U_ADFAT16F(cNmOrdem)

        cQuery := " SELECT ZIF_NUMERO FROM " + RetSqlName("ZIF") + " (NOLOCK) AS ZIF WHERE ZIF_FILIAL = '" + FWxFilial("ZIF") + "' AND ZIF_AGRUPA = '" + cNmOrdem + "' AND ZIF.D_E_L_E_T_ = '' ORDER BY ZIF_NUMERO "

        If Select("D_ORDLIB") > 0
            D_ORDLIB->(DbCloseArea())

        EndIf

        TcQuery cQuery New Alias "D_ORDLIB"
        DbSelectArea("D_ORDLIB")
        D_ORDLIB->(DbGoTop())

        Begin Transaction

            While ! D_ORDLIB->(Eof())

                If ! procLib(D_ORDLIB->ZIF_NUMERO, cTicket, aDados, nRadio, cObservao)
                    DisarmTransaction()
                    Break

                EndIf

                D_ORDLIB->(DbSkip())

            End

            lRet := .T.

        End Transaction

    Else
        Help(Nil, Nil, "Função lancQbr(ADEST075P)", Nil, "Ordem de pesagem/agrupador " + cNmOrdem + " não localizado." , 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} procLib
    Process liberação.
    @type  Static Function
    @author Everson
    @since 18/07/2022
    @version 01
/*/
Static Function procLib(cNmOrdem, cTicket, aDados, nRadio, cObservao)

    //Variáveis.
    Local aArea  := GetArea()
    Local lRet   := .F.

    If ! U_ADFAT194(cTicket, cValToChar(nRadio), cObservao) //Atualiza o status do ticket de pesagem.
        RestArea(aArea)
        Return .F.

    EndIf

    If ! U_ADFAT164(cNmOrdem, "13", 1) //Atualiza status da ordem de pesagem.
        RestArea(aArea)
        Return .F.

    EndIf

    lRet := .T.

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} lancQbr
    Processa devolução para o fornecedor.
    @type  Static Function
    @author Everson
    @since 05/04/2022
    @version 01
/*/
Static Function devFor()

    //Variáveis.

Return .T.
/*/{Protheus.doc} transFil
    Processa transferência entre filiais.
    @type  Static Function
    @author Everson
    @since 05/04/2022
    @version 01
/*/
Static Function transFil()

    //Variáveis.

Return .T.
/*/{Protheus.doc} libFabr
    Processa liberação fábrica.
    Processo de liberação utilizado apenas para o tipo de pesagem R - Ração.
    @type  Static Function
    @author Everson
    @since 05/04/2022
    @version 01
/*/
Static Function libFabr(cNmOrdem, aDados, nRadio, cObservao)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local cTicket   := aDados[17]

    Begin Transaction

        If ! U_ADFAT194(cTicket, cValToChar(nRadio), cObservao) //Atualiza o status do ticket de pesagem.
            DisarmTransaction()
            Break

        EndIf

        If ! U_ADFAT164(cNmOrdem, "7", 1) //Atualiza status da ordem de pesagem.
            DisarmTransaction()
            Break

        EndIf

        lRet := .T.

    End Transaction

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} compForn
    Processa complemento fornecedor.
    @type  Static Function
    @author Everson
    @since 05/04/2022
    @version 01
/*/
Static Function compForn()

    //Variáveis.

Return .T.
