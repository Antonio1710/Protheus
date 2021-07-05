#include "TOTVS.CH"
#Include "Topconn.ch"
#Include "FWMVCDEF.CH"

#DEFINE LAYOUT_ALIGN_LEFT     1
#DEFINE LAYOUT_ALIGN_RIGHT    2
#DEFINE LAYOUT_ALIGN_HCENTER  4
#DEFINE LAYOUT_ALIGN_TOP      32
#DEFINE LAYOUT_ALIGN_BOTTOM   64
#DEFINE LAYOUT_ALIGN_VCENTER  128

// Alinhamento para preenchimento dos componentes no TLinearLayout
#define LAYOUT_LINEAR_L2R 0 // LEFT TO RIGHT
#define LAYOUT_LINEAR_R2L 1 // RIGHT TO LEFT
#define LAYOUT_LINEAR_T2B 2 // TOP TO BOTTOM
#define LAYOUT_LINEAR_B2T 3 // BOTTOM TO TOP

// Grids
#DEFINE CONSULTA_VENDIDOS       1
#DEFINE CONSULTA_CANCELADOS     2
#DEFINE CONSULTA_EMBARQUES      3
#DEFINE CONSULTA_EXPORTACAO     4
#DEFINE CONSULTA_PAISES         5
#DEFINE CONSULTA_ESTOQUE        6

#DEFINE PANEL01_VIEW            11
#DEFINE PANEL02_VIEW            12

// Defines dos campos.
#DEFINE CONSULTA_VENDIDOS_CAMPOS    "EE7_PEDIDO,EE7_REFIMP,EE7_PEDFAT,EE7_DTPROC,EE8_DTENTR,EE7_IMPORT,EE7_IMPODE,EE7_CONSIG,A1_NOME,EE7_INCOTE,EE8_SEQUEN,B1_DESC,EE8_COD_I,EE8_SLDINI,EE8_PRECOI,EE8_PRCINC,EE8_PRCTOT,PAY,EE8FRUNIT,EE8_VLFRET,EE7_DEST,Y9_DESCR,Y9_CIDADE,EE7_ESTUFA,EEC_EMBARC,EEC_DTEMBA,EEC_DTESTU,EE7_XINDOC,EE7_XBOOKI,EE7_XDLDRA,EE7_XDLCAR,EE7_XPAGAM,C5_ROTEIRO,C5_PLACA,C9_NFISCAL,BLOQ_CRED,BLOQ_COM,C5_DTBLOQ,C5_HRBLOQ,C5_DTLIB3,C5_HRLIB3,EE7_STATUS,EE7_STTDES"

#DEFINE CONSULTA_ITENS_EXPORTACAO   "EE8_SEQUEN,B1_DESC,EE8_COD_I,EE8_SLDINI,EE8_PRECOI,EE8_PRCINC"
#DEFINE CONSULTA_PAISES_HOMOL       "YA_CODGI,YA_DESCR"
#DEFINE CONSULTA_SALDO_ESTOQUE      "C6_ENTREG,DESCRI,C6_QTDVEN,SALDO"

/*/{Protheus.doc} User Function ADEEC006P
    Tela de gestão dos processos de exportação.
    Chamado 8465
    @type  Function
    @author Leonardo P. Monteiro
    @since 15/03/2021
    @version 01
    @history Chamado 8465 - Leonardo P. Monteiro - 15/03/2021 - Desenvolvimento da consulta para gestão das exportações.
    @history Chamado 8465 - Leonardo P. Monteiro - 16/03/2021 - Correção no filtro de datas.
    @history Chamado 8465 - Leonardo P. Monteiro - 16/03/2021 - Correção nos saldos em estoque do eData.
    @history Chamado 8465 - Leonardo P. Monteiro - 02/07/2021 - Implementação dos novos recursos de integração com o App da qualidade.
/*/
user function ADEEC006P()
    Local cTitle    := "..:: Monitor de Exportação ::.."
    Local nAlt      := 0
    Local nLarg     := 0
    Local aSize     := {}
    Private oWnd

    Private oLayer
    Private oLayp01
    
    Private oBExpo
    Private oBItEx
    Private oBPaHo
    Private oBMoEx

    // Monitoramento de Pedidos Exportação.
    Private aExpoCab    := {}
    Private aExpoCam    := {}
    Private aExpoDad    := {}
    Private nPosStat    := 0
    // Consulta aos itens do Processo de Exportação.
    Private aItExCab    := {}
    Private aItExCam    := {}
    Private aItExDad    := {}
    // Consulta aos países homologados.
    Private aPaHoCab    := {}
    Private aPaHoCam    := {}
    Private aPaHoDad    := {}
    // Consulta aos países homologados.
    Private aMoExCab    := {}
    Private aMoExCam    := {}
    Private aMoExDad    := {}

    Private oEE7PED
    Private oDTDE
    Private oDTATE
    Private oIMPORT
    Private oCONSIG
    Private oSTATUS
    Private oPanel01
    Private oPanel02
    Private oChart
    Private oPedExp
    Private oPedVen
    Private oRazao
    Private oSauExp
    Private oSayVen
    Private oSayRaz
    Private oSayEsp


    Private cEE7PED     :=Space(15)
    Private dDTDE       := Stod(cValtoChar(YEAR(Date()))+"0101" )
    Private dDTATE      := Stod(cValtochar(YEAR(Date()))+"1231" )
    Private cIMPORT     := Space(06)
    Private cCONSIG     := Space(06)
    Private cSTATUS     := Space(40)
    Private nSTATUS     := 1
    Private aSTATUS     := {{"1=Teste"}}
    Private aLegenda    := {}
    Private nLegenda    := 0
    Private cLayCSS     := ""
    Private cBtnCss     := ""

    Private cPedExp     := Space(20)
    Private cPedVen     := Space(06)
    Private cRazao      := Space(40)

    Private oDblClick   := {|| fDblClick(PANEL01_VIEW)}
    Private oChgItEx    := {|| fChgItEx() }


    cLayCSS := "QFrame{ margin-top: 10px; } TButton{ margin-bottom: 7px; } TSay{ margin-bottom: 7px; margin-top: 7px; }"
    
    cBtnCss := " QFrame{ margin: 7px; } "
    cBtnCss += " QPushButton {"
	cBtnCss += "    background-color: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #FDFDFD, stop:1 #E7E7E7);"
	cBtnCss += "    border-radius: 08px;"
	cBtnCss += "    border: 1px solid #D8D8D8;"
	cBtnCss += "    font: bold 10em;"
	cBtnCss += "}"
	cBtnCss += " QPushButton:hover { background-color: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #FCFCFC, stop:1 #C7CBCC); }"
	cBtnCss += " QPushButton:pressed {"
	cBtnCss += "    background-color: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #C7CBCC, stop:1 #FCFCFC);"
	cBtnCss += "}"
    
    fDefLeg()
    
    aSTATUS := fGetLeg(1)
    
    if type("cFilAnt") == "U"
        //RpcsetType(3)
        //Rpcsetenv("01","02","LEONARDO_MONTEIRO","")
        nAlt    := GetScreenRes()[02]*0.965
        nLarg   := GetScreenRes()[01]
    else
        aSize   := MsAdvSize(.T.)
        nAlt    := aSize[06]
        nLarg   := aSize[05]
    endif
    
    oWnd            := Msdialog():Create()
    oWnd:cTitle     := cTitle
    ownd:nWidth     := nLarg
    oWnd:nHeight    := nAlt
    oWnd:lMaximized := .T.
    oWnd:SetCSS("QWidget{ font: bold 12px; } TTabs{ margin: 0px; } ")

    oLayer := FWLayer():new()
    
    oLayer:init(oWnd,.F.)
    oLayer:opanel:nHeight    := nAlt*1.01

    layGrid()
    layPanel()
    //layOpcoes()
    //layFooter()

    oWnd:Activate()
return

Static Function layGrid()
    
    oLayer:addLine("L01",82, .F.)
    oLayer:addCollumn("L01C01", 100, .F., "L01")
    oL01C01 := oLayer:getColPanel("L01C01", "L01")
    //oLayer:addCollumn("L01C02", 030, .F., "L01")
    
    //Painél de visualização e consulta dos Pedidos de Exportação
    fsetPanel1()
    //Tela de detalhes do Processo de Exportação.
    fsetPanel2()

return

Static Function fsetPanel1()
    Local aSeek         := {}

    oPanel01                    := TPanel():New(0,0,'',oL01C01,,,,,,0,0,,.T.)
    oPanel01:Align              := CONTROL_ALIGN_ALLCLIENT
    oPanel01:lVisibleControl    := .T.

    oLayp01 := FWLayer():new()
    oLayp01:init(oPanel01,.F.)
    oLayp01:addLine("L01",100, .F.)
    oLayp01:addCollumn("L01C01", 100, .F., "L01")
    oLayp01:addWindow("L01C01", "Win01", "Processos de Exportação/Itens"		, 100,.F.,.F.,{||"" },"L01",{||""})
    
    oLayp01:GetLinePanel("L01"):SetCSS("QFrame{ background-color: #FFFFFF;}")

    //**************************************************
    // Sessão de consulta aos processos de exportação.
    //**************************************************

    aExpoCab		:= getCampos(CONSULTA_VENDIDOS)
    aExpoDad		:= getDadosBrw(CONSULTA_VENDIDOS)
    
    oCoWin01 := oLayp01:GetWinPanel("L01C01","Win01","L01")

    oBExpo := FWBrowse():New(oCoWin01)
    oBExpo:addStatusColumns({|| condLeg()},{|oBExpo| LegStatVolume(1) /*Função de DOUBLECLICK*/})
    oBExpo:addStatusColumns({|| fLibera()},{|oBExpo| LegStatVolume(2) /*Função de DOUBLECLICK*/})
    oBExpo:setColumns(aExpoCab)
	oBExpo:setDataArray()
	oBExpo:disableReport()
	oBExpo:disableConfig()
    oBExpo:setArray(aExpoDad)
    oBExpo:setDoubleClick(oDblClick)
    //oBExpo:setChange(bCoBPro)
    
    nPosStat := aScan(aExpoCam, "EE7_STATUS")

    aAdd(aSeek,{"Pedido"    , {{"","C",15,0, "EE7_PEDIDO",}}})
    aAdd(aSeek,{"Produto"   , {{"","C",45,0, "EE8_COD_I",}}})
    
    oBExpo:setSeek({|oSeek, oBrowse| filtraProd(oSeek, oBrowse, aExpoCam)}, aSeek)
    
    oBExpo:setFieldFilter({ {"EE7_PEDIDO"   ,getSx3Cache("EE7_PEDIDO", "X3_TITULO") ,getSx3Cache("EE7_PEDIDO", "X3_TIPO") ,getSx3Cache("EE7_PEDIDO", "X3_TAMANHO") ,getSx3Cache("EE7_PEDIDO", "X3_DECIMAL") ,getSx3Cache("EE7_PEDIDO", "X3_PICTURE") },;
                             {"EE8_COD_I"   ,getSx3Cache("EE8_COD_I", "X3_TITULO")  ,getSx3Cache("EE8_COD_I", "X3_TIPO")  ,getSx3Cache("EE8_COD_I", "X3_TAMANHO")  ,getSx3Cache("EE8_COD_I", "X3_DECIMAL")  ,getSx3Cache("EE8_COD_I", "X3_PICTURE")  };
						    })
    
    oBExpo:SetBlkBackColor({|| IIF(!Empty(aExpoDad[oBExpo:At(), aScan(aExpoCam, "EE7_XBOOKI")]) , CLR_HGREEN,; 
                                    IIF(!Empty(aExpoDad[oBExpo:At(), aScan(aExpoCam, "EEC_EMBARC")]) , CLR_YELLOW , Nil ) ) })
    
    oBExpo:bGotFocus := {|| nBrwFocused := 1}
    oCoWin01:Refresh( .T. ) 
    oBExpo:Activate()
return

static function filtraProd(oSeek, oBrowse,cArray)
	local cFiltro	:= oSeek:getSeek()
	local nOrder	:= oSeek:getOrder()
	local nPosPed	:= aScan(cArray, "EE7_PEDIDO")
	local nPosPrd	:= aScan(cArray, "EE8_COD_I")
	local nPosRet	:= 1

    if nOrder == 1
	    nPosRet := aScan(oBrowse:oData:aArray, {|x| allTrim(cFiltro) $ x[nPosPed]})
    elseif nOrder == 2
        nPosRet := aScan(oBrowse:oData:aArray, {|x| allTrim(cFiltro) $ x[nPosPrd]})
    endif

	if nPosRet == 0
        Msginfo("Não foi encontrado nenhum registro!")
		nPosRet := 1
	endIf

return(nPosRet)

Static Function fsetPanel2()
    
    oPanel02                    := TPanel():New(0,0,'',oL01C01,,,,,,0,0,,.T.)
    oPanel02:Align              := CONTROL_ALIGN_ALLCLIENT
    oPanel02:lVisibleControl    := .F.

    oLayp02 := FWLayer():new()
    oLayp02:init(oPanel02,.F.)
    oLayp02:addLine("L01",010, .F.)
    oLayp02:addLine("L02",090, .F.)
    oLayp02:addCollumn("L02C01", 050, .F., "L02")
    oLayp02:addCollumn("L02C02", 050, .F., "L02")
    //oLayp02:addCollumn("L02C03", 030, .F., "L02")
    
    oLayp02:addWindow("L02C01", "Win01", "Itens Exportados"		, 060,.F.,.F.,{||"" },"L02",{||""})
    oLayp02:addWindow("L02C01", "Win02", "Países Homologados"   , 040,.F.,.F.,{||"" },"L02",{||""})
    
    oLayp02:addWindow("L02C02", "Win03", "saldos Estoque"		, 050,.F.,.F.,{||"" },"L02",{||""})
    oLayp02:addWindow("L02C02", "Win04", "Previsão Estoque"		, 050,.F.,.F.,{||"" },"L02",{||""})

    oLayp02:GetLinePanel("L01"):SetCSS("QFrame{ background-color: #FFFFFF;}")
    oLayp02:GetLinePanel("L02"):SetCSS("QFrame{ background-color: #FFFFFF;}")

    oLineTop     := oLayp02:GetLinePanel("L01")
    oGrid01     := tLinearLayout():New(oLineTop, LAYOUT_LINEAR_R2L ,CONTROL_ALIGN_ALLCLIENT)
    oGrid01:setCss(cLayCSS)

    //**************************************************
    // Cabeçalho Panel 01.
    //**************************************************

    oSayExp := TSay():New( 0, 0, {|| "  Pedido Exportação"}   , oLineTop,,,,,,.T.,,,70,15)
    oPedExp  := TGet():New(000,000,{|u|If(PCount() == 0,cPedExp,cPedExp := u)},oLineTop,070,010, "",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cPedExp",,,,.T.,,,,1) 
    oPedExp:lVisibleControl := .T.

    oSayVen := TSay():New( 0, 0, {|| "  Pedido Venda"}   , oLineTop,,,,,,.T.,,,70,15)
    oPedVen  := TGet():New(000,000,{|u|If(PCount() == 0,cPedVen,cPedVen := u)},oLineTop,070,010, "",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cPedVen",,,,.T.,,,,1) 
    oPedVen:lVisibleControl := .T.

    oSayRaz := TSay():New( 0, 0, {|| "  Razão Social"}   , oLineTop,,,,,,.T.,,,70,15)
    oRazao  := TGet():New(000,000,{|u|If(PCount() == 0,cRazao,cRazao := u)},oLineTop,200,010, "",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cRazao",,,,.T.,,,,1) 
    oRazao:lVisibleControl := .T.

    oBtnRet := TButton():New( 0, 0, "< Voltar"   , oLineTop,{|| fDblClick(PANEL02_VIEW) }, 25,15,,,.F.,.T.,.F.,,.F.,{|| .T.},,.F. )
    oSayEsp := TSay():New( 0, 0, {|| " "}   , oLineTop,,,,,,.T.,,,5,15)
    oBtnRet:setCss(cBtnCss)

    oGrid01:addInLayout(oSayEsp)
    oGrid01:addInLayout(oBtnRet)
    oGrid01:addInLayout(oRazao)
    oGrid01:addInLayout(oSayRaz)
    oGrid01:addInLayout(oPedVen)
    oGrid01:addInLayout(oSayVen)
    oGrid01:addInLayout(oPedExp)
    oGrid01:addInLayout(oSayExp)
    
    oGrid01:addSpacer(3)

    //**************************************************
    // Cabeçalho Panel 02 - Itens Exportados.
    //**************************************************

    // Itens Exportados.
    aItExCab		:= getCampos(CONSULTA_EXPORTACAO)
    aItExDad		:= getDadosBrw(CONSULTA_EXPORTACAO)
    
    oItWin01 := oLayp02:GetWinPanel("L02C01","Win01","L02")

    oBItEx := FWBrowse():New(oItWin01)
    //oDeItEx:addStatusColumns({|| condLeg()},{|oBExpo| LegStatVolume(1) /*Função de DOUBLECLICK*/})
    oBItEx:setColumns(aItExCab)
	oBItEx:setDataArray()
	oBItEx:disableReport()
	oBItEx:disableConfig()
    oBItEx:setArray(aItExDad)
    oBItEx:setChange(oChgItEx)
    //oDeItEx:setDoubleClick(oDblClick)
    oBItEx:Activate()

    //**************************************************
    // Cabeçalho Panel 02 - Países homologados.
    //**************************************************

    // Itens Exportados.
    aPaHoCab		:= getCampos(CONSULTA_PAISES)
    aItExDad		:= getDadosBrw(CONSULTA_PAISES)
    
    oItWin02 := oLayp02:GetWinPanel("L02C01","Win02","L02")

    oBPaHo := FWBrowse():New(oItWin02)
    //oDeItEx:addStatusColumns({|| condLeg()},{|oBExpo| LegStatVolume(1) /*Função de DOUBLECLICK*/})
    oBPaHo:setColumns(aPaHoCab)
	oBPaHo:setDataArray()
	oBPaHo:disableReport()
	oBPaHo:disableConfig()
    oBPaHo:setArray(aPaHoDad)
    //oDeItEx:setDoubleClick(oDblClick)
    oBPaHo:Activate()

    //********************************************
    // Cabeçalho Panel 02 - Gráficos.
    //********************************************
    oItWin03 := oLayp02:GetWinPanel("L02C02","Win03","L02")
    //oCoGd01   := tGridLayout():New(oCoWin02,CONTROL_ALIGN_ALLCLIENT)
    oChart := FWChartFactory():New()
    oChart:SetOwner(oItWin03)
    //TEMP
    fGrafico()

    //**************************************************
    // Cabeçalho Panel 02 - Exportações Previstas.
    //**************************************************

    // Itens Exportados.
    aMoExCab		:= getCampos(CONSULTA_ESTOQUE)
    aMoExDad		:= getDadosBrw(CONSULTA_ESTOQUE)
    
    oItWin04 := oLayp02:GetWinPanel("L02C02","Win04","L02")

    oBMoEx := FWBrowse():New(oItWin04)
    //oDeItEx:addStatusColumns({|| condLeg()},{|oBExpo| LegStatVolume(1) /*Função de DOUBLECLICK*/})
    oBMoEx:setColumns(aMoExCab)
	oBMoEx:setDataArray()
	oBMoEx:disableReport()
	oBMoEx:disableConfig()
    oBMoEx:setArray(aMoExDad)
    oBMoEx:Activate()

return

Static Function fChgItEx()
    
    if Type("oBPaHo") == "O"
        aPaHoDad := getDadosBrw(CONSULTA_PAISES)
        oBPaHo:setArray(aPaHoDad)
        oBPaHo:refresh()
    Endif
    if Type("oBMoEx") == "O"
        aMoExDad := getDadosBrw(CONSULTA_ESTOQUE)
        oBMoEx:setArray(aMoExDad)
        oBMoEx:refresh()
    Endif
    if Type("oChart") == "O"
        //TEMP
        fGrafico()
    endif
return

Static Function fDblClick(nPanel)
    
    oPanel01:lVisibleControl    := iif(nPanel == PANEL02_VIEW,.T. , .F.)
    oPanel02:lVisibleControl    := iif(nPanel == PANEL01_VIEW,.T. , .F.)
    
    if nPanel == PANEL01_VIEW
        cPedExp := Alltrim(aExpoDad[oBExpo:At(), aScan(aExpoCam, "EE7_PEDIDO")])
        cPedVen := Alltrim(aExpoDad[oBExpo:At(), aScan(aExpoCam, "EE7_PEDFAT")])
        cRazao  := Alltrim(aExpoDad[oBExpo:At(), aScan(aExpoCam, "EE7_IMPODE")])
        
        oPedExp:refresh()
        oPedVen:refresh()
        oRazao:refresh()

        aItExDad := getDadosBrw(CONSULTA_EXPORTACAO)
        oBItEx:setArray(aItExDad)
        oBItEx:refresh()

        aMoExDad := getDadosBrw(CONSULTA_ESTOQUE)
        oBMoEx:setArray(aMoExDad)
        oBMoEx:refresh()

        //TEMP
        fGrafico()
    endif

return

static function LegStatVolume(nTpLeg)
	Local aLegLib := {}

    if nTpLeg == 1
        if nLegenda > 0
            BrwLegenda("Legenda" , "Legenda", aLegenda)
        endif
    Elseif nTpLeg == 2
        aAdd(aLegLib,{"BR_AZUL"           , "Bloqueio Comercial"})
        aAdd(aLegLib,{"BR_VERMELHO"       , "Bloqueio Financeiro/Estoque"})
        aAdd(aLegLib,{"BR_VERDE"          , "Pedido liberado p/ faturamento"})
        aAdd(aLegLib,{"BR_PRETO"          , "Pedido faturados"})
        aAdd(aLegLib,{"BR_WHITE"          , "Status outros"})
        BrwLegenda("Legenda" , "Legenda", aLegLib)
    endif

return(.T.)

static function condLeg()
	local cLegenda	:= ""
	local cStatus	:= aExpoDad[oBExpo:At(), nPosStat]
	
	cLegenda := fGetLeg(2, cStatus)
	
return(cLegenda)

static function fLibera()
	local cLegenda	:= ""
	local cBlqCred  := Left(aExpoDad[oBExpo:At(), aScan(aExpoCam, "BLOQ_CRED")],1)
	local cBlqCome  := left(aExpoDad[oBExpo:At(), aScan(aExpoCam, "BLOQ_COM")],1)

    if cBlqCome == "N"
        cLegenda := "BR_AZUL"
    Else
        IF cBlqCred$"A,B"
            cLegenda := "BR_VERMELHO"
        elseif cBlqCred == "F"
            cLegenda := "BR_PRETO"
        Elseif cBlqCred == "L"
            cLegenda := "BR_VERDE"
        Elseif cBlqCred == "N"
            cLegenda := "BR_WHITE"
        endif
    endif
	
return(cLegenda)


Static Function layPanel()
    
    oLayer:addLine("L02",18, .F.)
    oLayer:addCollumn("L02C01", 065, .F., "L02")
    oLayer:addCollumn("L02C02", 035, .F., "L02")

    oLayer:addWindow("L02C01", "Win01", "Filtros"   , 100,.F.,.F.,{||"" },"L02",{||""})
    oLayer:addWindow("L02C02", "Win02", "Opções"    , 100,.F.,.F.,{||"" },"L02",{||""})
    
    oLayer:GetLinePanel("L02"):SetCSS("QFrame{ background-color: #FFFFFF;}")
    
    oBot := oLayer:getWinPanel("L02C01","Win01","L02")
    oSize := FWDefSize():New(.F.)
	
    oSize:AddObject( "OBJ01"	, 50, 50, .T., .T. )
    oSize:AddObject( "OBJ02"	, 50, 50, .T., .T. )
    oSize:AddObject( "OBJ03"	, 50, 50, .T., .T. )
    oSize:AddObject( "OBJ04"	, 40, 50, .T., .T. )
    oSize:AddObject( "OBJ05"	, 40, 50, .T., .T. )
    oSize:AddObject( "OBJ06"	, 80, 50, .T., .T. )
    oSize:AddObject( "OBJ07"	, 40, 50, .T., .T. )
    
	oSize:lLateral	:= .T. // Elementos um do lado do outro
	oSize:lProp		:= .T. // Cálculo dos botões proporcionais
	oSize:SetWindowSize({000, 000, oBot:nHeight, oBot:nWidth})
	oSize:Process() 		// executa os calculos

    //**************************************************
    // Sessão de filtros.
    //**************************************************

	oEE7PED  := TGet():New(002,oSize:GetDimension("OBJ01","COLINI")+2,{|u|If(PCount() == 0, cEE7PED, cEE7PED := u)},oBot,oSize:GetDimension("OBJ01","XSIZE"),010,"",,0,16777215,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F. ,,"cEE7PED",,,,.T.,,,"Pedido",1) 
    oEE7PED:lVisibleControl := .T.

    oDTDE  := TGet():New(002,oSize:GetDimension("OBJ02","COLINI"),{|u|If(PCount() == 0, dDTDE, dDTDE := u)},oBot,oSize:GetDimension("OBJ02","XSIZE"), 010,"",,0,16777215,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F. ,,"dDTDE",,,,.T.,,,"Dt. De",1)
    oDTDE:lVisibleControl := .T.
    
    oDTATE  := TGet():New(002,oSize:GetDimension("OBJ03","COLINI"),{|u|If(PCount() == 0, dDTATE, dDTATE := u)},oBot,oSize:GetDimension("OBJ03","XSIZE"), 010,"",,0,16777215,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F. ,,"dDTDE",,,,.T.,,,"Dt. Até",1)
    oDTATE:lVisibleControl := .T.
    
    oIMPORT   := TGet():New(002,oSize:GetDimension("OBJ04","COLINI"),{|u|If(PCount() == 0, cIMPORT, cIMPORT := u)},oBot,oSize:GetDimension("OBJ04","XSIZE"), 010,"",,0,16777215,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F. ,"SA1","cIMPORT",,,,.T.,,,"Importador",1)
    oIMPORT:lVisibleControl := .T.

    oCONSIG  := TGet():New(002,oSize:GetDimension("OBJ05","COLINI"),{|u|If(PCount() == 0, cCONSIG, cCONSIG := u)},oBot,oSize:GetDimension("OBJ05","XSIZE"), 010,"",,0,16777215,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F. ,"SA1","cCONSIG",,,,.T.,,,"Consignatário",1)
    oCONSIG:lVisibleControl := .T.

    //aSTATUS  := {{"01=Teste"}}
    //oSTATUS 	:= tComboBox():New(002,oSize:GetDimension("OBJ06","COLINI"),{|u|if(PCount()>0, cSTATUS := u, oSTATUS)},aSTATUS,oSize:GetDimension("OBJ06","XSIZE"),013,oBot,,{|| .T.},,,,.T.,,,,{|| .T.},,,,,'nSTATUS', "Status",1)
	oSTATUS  := TGet():New(002,oSize:GetDimension("OBJ06","COLINI"),{|u|If(PCount() == 0, cSTATUS, cSTATUS := u)},oBot,oSize:GetDimension("OBJ06","XSIZE"), 010,"",,0,16777215,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F. ,"STAEXP","cSTATUS",,,,.T.,,,"Status",1)
    oSTATUS:lVisibleControl := .T.

    oButPesq := TButton():New( 0, oSize:GetDimension("OBJ07","COLINI"), "Filtrar", oBot,{|| fGetFiltro()}, oSize:GetDimension("OBJ07","XSIZE"),oSize:GetDimension("OBJ07","YSIZE"),,,.F.,.T.,.F.,,.F.,,,.F. )

    //**************************************************
    // Sessão de opções e menu.
    //**************************************************
    
    oOpc := oLayer:getWinPanel("L02C02","Win02","L02")
    oSize := FWDefSize():New(.F.)
	
    oSize:AddObject( "OBJ01"	, 50, 50, .T., .T. )
    oSize:AddObject( "OBJ02"	, 50, 50, .T., .T. )
    oSize:AddObject( "OBJ03"	, 50, 50, .T., .T. )
    oSize:AddObject( "OBJ04"	, 50, 50, .T., .T. )
    oSize:AddObject( "OBJ05"	, 50, 50, .T., .T. )
    
	oSize:lLateral	:= .T. // Elementos um do lado do outro
	oSize:lProp		:= .T. // Cálculo dos botões proporcionais
	oSize:SetWindowSize({000, 000, oOpc:nHeight, oOpc:nWidth})
	oSize:Process() 		// executa os calculos
    
    oButExp := TButton():New( 0, oSize:GetDimension("OBJ01","COLINI"), "Relatórios", oOpc  ,{|| }   , oSize:GetDimension("OBJ01","XSIZE"),;
                        oSize:GetDimension("OBJ01","YSIZE"),,,.F.,.T.,.F.,,.F.,,,.F. )
    
    // cria os submenus
    oMenu01 := tMenu():new(0, 0, 0, 0, .T.)
    // cria os itens dos submenus
    
    oMenu0101 := tMenuItem():new(oWnd, "Exp. Excel"         , , ,       , {|| fAcao(1, 1, .F.)},,,,,,,,,.T.)
    oMenu0101 := tMenuItem():new(oWnd, "Ord. Carregametno"  , , ,       , {|| fAcao(1, 2, .F.)},,,,,,,,,.T.)
    
    oMenu01:add(oMenu0101)
    oButExp:setPopupMenu(oMenu01)

    oButPed := TButton():New( 0, oSize:GetDimension("OBJ02","COLINI"), "Manutenção", oOpc,{|| } , oSize:GetDimension("OBJ02","XSIZE"),;
                        oSize:GetDimension("OBJ02","YSIZE"),,,.F.,.T.,.F.,,.F.,,,.F. )
    // cria os submenus
    oMenu02 := tMenu():new(0, 0, 0, 0, .T.)
    // cria os itens dos submenus
    
    oMenu0201 := tMenuItem():new(oWnd, "Consulta/Confecção"     , , ,       , {|| fAcao(2,   1, .F.)},,,,,,,,,.T.)
    oMenu0202 := tMenuItem():new(oWnd, "Cons. Manutenção"       , , ,       , {|| fAcao(2,   2, .F.)},,,,,,,,,.T.)
    oMenu0203 := tMenuItem():new(oWnd, "Atual. Dados"           , , ,       , {|| fAcao(2,   3, .T.)},,,,,,,,,.T.)
    oMenu0204 := tMenuItem():new(oWnd, "Consulta"               , , ,       , {|| fAcao(2,   4, .T.)},,,,,,,,,.T.)

    oMenu02:add(oMenu0201)
    oMenu02:add(oMenu0202)
    oMenu02:add(oMenu0203)
    oMenu02:add(oMenu0204)
    oButPed:setPopupMenu(oMenu02)

    oButEmb := TButton():New( 0, oSize:GetDimension("OBJ03","COLINI"), "Workflows", oOpc,{|| fAcao(3, nil, .F.)}  , oSize:GetDimension("OBJ03","XSIZE"),;
                        oSize:GetDimension("OBJ03","YSIZE"),,,.F.,.T.,.F.,,.F.,,,.F. )
    // cria os submenus
    oMenu03 := tMenu():new(0, 0, 0, 0, .T.)
    // cria os itens dos submenus
    
    oMenu0301 := tMenuItem():new(oWnd, "Prev. Embarques"    , , ,       , {|| fAcao(3,   1, .F.)},,,,,,,,,.T.)
    oMenu0302 := tMenuItem():new(oWnd, "Noti. Embarques"    , , ,       , {|| fAcao(3,   2, .F.)},,,,,,,,,.T.)
    oMenu0303 := tMenuItem():new(oWnd, "Inspec. Qualidade"  , , ,       , {|| fAcao(3,   3, .F.)},,,,,,,,,.T.)

    oMenu03:add(oMenu0301)
    oMenu03:add(oMenu0302)
    oMenu03:add(oMenu0303)
    oButEmb:setPopupMenu(oMenu03)

    oButDet := TButton():New( 0, oSize:GetDimension("OBJ04","COLINI"), "Monitor", oOpc,{|| }    , oSize:GetDimension("OBJ04","XSIZE"),;
                        oSize:GetDimension("OBJ04","YSIZE"),,,.F.,.T.,.F.,,.F.,,,.F. )
    // cria os submenus
    oMenu04 := tMenu():new(0, 0, 0, 0, .T.)
    // cria os itens dos submenus
    
    oMenu0401 := tMenuItem():new(oWnd, "Dados adic", , ,      , {|| fAcao(4,   1, .F.)},,,,,,,,,.T.)
    oMenu0402 := tMenuItem():new(oWnd, "PGA-SigSif", , ,      , {|| fAcao(4,   2, .F.)},,,,,,,,,.T.)
    
    oMenu04:add(oMenu0401)
    oMenu04:add(oMenu0402)
    oButDet:setPopupMenu(oMenu04)
    
    oButLeg := TButton():New( 0, oSize:GetDimension("OBJ05","COLINI"), "Legenda", oOpc,{|| }    , oSize:GetDimension("OBJ05","XSIZE"),;
                        oSize:GetDimension("OBJ05","YSIZE"),,,.F.,.T.,.F.,,.F.,,,.F. )
    
     // cria os submenus
    oMenu05 := tMenu():new(0, 0, 0, 0, .T.)
    // cria os itens dos submenus
    
    oMenu0501 := tMenuItem():new(oWnd, "St. Processo", , ,      , {|| fAcao(5,   1, .F.)},,,,,,,,,.T.)
    oMenu0502 := tMenuItem():new(oWnd, "St. Aprovação", , ,     , {|| fAcao(5,   2, .F.)},,,,,,,,,.T.)
    
    oMenu05:add(oMenu0501)
    oMenu05:add(oMenu0502)
    oButLeg:setPopupMenu(oMenu05)

return

Static Function fAcao(nAcao, nOper, lRefresh)
    Local cAlias        := "EE7"
    Local nReg          := 0
    Local nPosPed       := aScan(aExpoCam, "EE7_PEDIDO")
    Local cTitulo       := ""
    Local cModel        := ""
    Local nOperation    := 4
    Local aParamBox     := {}
    Local aRet          := {}
    Private cPedExp     := ""
    

    // 1. Relatório/Exportação de dados
    if nAcao == 1
        //Exportar para Excel.
        if nOper == 1
            fExporta()
        elseif nOper == 2
            U_ADEEC011R()
        endif
    
    //2. Manutenção.
    elseif nAcao == 2
        DbSelectArea("EE7")
        EE7->(DbSetOrder(1))
        cAlias  := "EE7"
        nReg    := 0
        cPedExp := Alltrim(aExpoDad[oBExpo:At(), nPosPed])

        if EE7->(Dbseek(xFilial("EE7")+cPedExp))
            nReg := EE7->(Recno())
        endif

        //Pedidos de Exportação.
        if nOper == 1
            EECAP100()
        //Embarques.
        elseif nOper == 2
            EECAE100()
        elseif nOper == 3
            cTitulo     := "Pedido de Exportação"
            cModel      := "ADEEC009P"
            nOperation  := 4
            nConfirma := FWExecView(cTitulo,cModel, nOperation, , { || .T. }, , 0, )
        elseif nOper == 4
            cTitulo     := "Pedido de Exportação - Consulta"
            cModel      := "ADEEC009P"
            nOperation  := 1
            nConfirma := FWExecView(cTitulo,cModel, nOperation, , { || .T. }, , 0, )
        endif
    
    // 3. Workflows e Integrações.
    elseif nAcao == 3
        
        // Processa envio do workflow de previsão de embarque.
        if nOper == 1    
            If msgYesNo("Deseja enviar o workflow das previsões de embarque?")
                U_ADEEC008P()
            endif

        // Processa envio do workflow de notificação de embarque.
        elseif nOper == 2
            If msgYesNo("Deseja enviar o workflow de notificação de embarque?")
                U_ADEEC010P()
            endif
        // Importa as inspeções da qualidade.
        elseif nOper == 3
            Aadd( aParamBox ,{1,"Data Embarque?"						,dDatabase,"" ,'.T.',"",'.T.',80,.F.})
            aAdd( aParamBox	,{3,"Reprocessar todos?"		        ,1,{'Importar todos','Somente pendentes'},100,"",.F.})
            
            if ParamBox(aParamBox,"Parâmetros",@aRet)
                MsAguarde({|| U_ADQUA002(MV_PAR01, MV_PAR02) }, "Processando", "Importando os resultados das inspeções...")
                msginfo("Processamento finalizado!")
            else
                msginfo("Operação cancelada pelo operador!")
            endif
        endif
    
    // 4. Detalhamento dos processos.
    elseif nAcao == 4
        
        if nOper == 1
            fDblClick(PANEL01_VIEW)
        elseif nOper == 2
            U_ADEST055P(2)
        endif
    
    //Legenda.
    elseif nAcao == 5
            LegStatVolume(nOper)
    endif
    
    if lRefresh
        fGetFiltro()
    endif
return

Static Function fExporta()
    
    Local oExcel        := FWMSEXCELEX():New()
    Local cArq		    := "ADEEC006P_"+Dtos(date())+"-"+replace(Alltrim(Time()),":","")+".XML"
    Local cWorkSh       := "Exportacao"
    Local cTabName      := "Exportacao"
    Local oObj          := nil
    Local cDiret        := ""
    //Local nTabDad       := {}
    Local cDiret        := ""
    
    cDiret := Alltrim(cGetFile('Arquivo|*.*|Arquivo *|*.*','Selecione o arquivo',0,'C:\temp\',.T.,GETF_RETDIRECTORY+GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.))
    
    if lIsDir(cDiret)
        oExcel:AddworkSheet(cWorkSh)
        oExcel:AddTable (cWorkSh,cTabName)
        
        nTable := Len(aExpoCab)
        for nA := 1 to nTable
            oObj := aExpoCab[nA]
            oExcel:AddColumn(cWorkSh,cTabName,Alltrim(oObj:cTitle)  ,1,1)
        next nA
        
        nTable := Len(aExpoDad)
        For nA := 1 To nTable
            oExcel:AddRow(cWorkSh,cTabName, aSize(aExpoDad[nA],len(aExpoDad[nA])-1)) 
        next nA

        oExcel:Activate()
        oExcel:GetXMLFile(cDiret+cArq)
        
        oMsExcel := MsExcel():New()
        oMsExcel:WorkBooks:Open(cDiret+cArq)
        oMsExcel:SetVisible( .T. )
        oMsExcel:Destroy()
    else
        msginfo("Rotina cancelada pelo operador!")
    endif
return


Static Function fGetFiltro()
    aExpoDad		:= getDadosBrw(CONSULTA_VENDIDOS)
    oBExpo:setArray(aExpoDad)
    oBExpo:refresh()

return

static function getCampos(nTypeBrowse)
	local aCpoRet	:= {}
    local aCampos   := {}
	local nCampos   := 0
    local nX        := 0

	if nTypeBrowse == CONSULTA_VENDIDOS
		aCampos		:= strToKarr(CONSULTA_VENDIDOS_CAMPOS, ",")
        aExpoCab    := {}
        aExpoCam    := aCampos
    Elseif nTypeBrowse == CONSULTA_EXPORTACAO
        aCampos		:= strToKarr(CONSULTA_ITENS_EXPORTACAO, ",")
        aItExCab    := {}
        aItExCam    := aCampos
    Elseif nTypeBrowse == CONSULTA_PAISES
        aCampos		:= strToKarr(CONSULTA_PAISES_HOMOL, ",")
        aPaHoCab    := {}
        aPaHoCam    := aCampos
    Elseif nTypeBrowse == CONSULTA_ESTOQUE
        aCampos		:= strToKarr(CONSULTA_SALDO_ESTOQUE, ",")
        aMoExCab    := {}
        aMoExCam    := aCampos
    endIf

    nCampos := Len(aCampos)

    nCampos := Len(aCampos)
	for nX := 1 to nCampos
		cCampo	:= Alltrim(aCampos[nX])
        
        if nTypeBrowse == CONSULTA_VENDIDOS
            cValue := "{|| aExpoDad[oBExpo:At(), " + cValToChar(nX) + "]}"
		    //aAdd(aExpoCab, cCampo)
        Elseif nTypeBrowse == CONSULTA_EXPORTACAO
            cValue := "{|| aItExDad[oBItEx:At(), " + cValToChar(nX) + "]}"
		    //aAdd(aItExCab, cCampo)
        Elseif nTypeBrowse == CONSULTA_PAISES
            cValue := "{|| aPaHoDad[oBPaHo:At(), " + cValToChar(nX) + "]}"
		    //aAdd(aPaHoCab, cCampo)
        Elseif nTypeBrowse == CONSULTA_ESTOQUE
            cValue := "{|| aMoExDad[oBMoEx:At(), " + cValToChar(nX) + "]}"
		    //aAdd(aMoExCab, cCampo)
        endif

		oColumn := FWBrwColumn():New()
		oColumn:SetData(&(cValue))
        
        if Alltrim(cCampo) == "EE8FRUNIT"
            cTitulo := "$ Frete Unit"
        ELSEif Alltrim(cCampo) == "PAY"
            cTitulo := "Pagamento"
        Elseif Alltrim(cCampo) == "SALDO"
            cTitulo := "Saldo (KG)"
        Elseif Alltrim(cCampo) == "BLOQ_CRED"
            cTitulo := "Bloq. Crédito"
        Elseif Alltrim(cCampo) == "BLOQ_COM"
            cTitulo := "Bloq. Comercial"
        Elseif Alltrim(cCampo) == "DESCRI"
            cTitulo := "Desc. Mov."
        else
            cTitulo := getSx3Cache(cCampo, "X3_TITULO")
        endif

        if Alltrim(cCampo) == "EE8FRUNIT"
		    oColumn:SetTitle("Pagamento")
		    oColumn:SetSize(20)
            oColumn:SetType("N")
        elseif Alltrim(cCampo) == "PAY"
		    oColumn:SetTitle("Pagamento")
		    oColumn:SetSize(15)
            oColumn:SetType("C")
        Elseif Alltrim(cCampo) == "SALDO"
		    oColumn:SetTitle("Saldo (KG)")
		    oColumn:SetSize(20)
            oColumn:SetType("N")
        Elseif Alltrim(cCampo) == "BLOQ_CRED"
		    oColumn:SetTitle("Bloq. Crédito")
		    oColumn:SetSize(10)
            oColumn:SetType("C")
        Elseif Alltrim(cCampo) == "BLOQ_COM"
		    oColumn:SetTitle("Bloq. Comercial")
		    oColumn:SetSize(10)
            oColumn:SetType("C")
        Elseif Alltrim(cCampo) == "DESCRI"
		    oColumn:SetTitle("Desc. Mov.")
		    oColumn:SetSize(20)
            oColumn:SetType("C")
        else
            oColumn:SetTitle(getSx3Cache(cCampo, "X3_TITULO"))
		    oColumn:SetSize(getSx3Cache(cCampo, "X3_TAMANHO"))
            oColumn:SetType(getSx3Cache(cCampo, "X3_TIPO"))
        endif
        // u_ad
        if cCampo$"EE7_PEDIDO,EE7_REFIMP,EE7_PEDFAT,EE7_DTPROC,EE8_DTENTR,EE7_IMPORT,EE7_CONSIG,EE7_INCOTE,EE8_SEQUEN,EE8_COD_I,EE8_SLDINI,EE8_PRECOI,EE8_PRCINC,EE8_PRCTOT,EE8FRUNIT,EE8_VLFRET,EE7_DEST,EE7_ESTUFA,EEC_EMBARC,EEC_DTEMBA,EEC_DTESTU,EE7_STATUS"
            oColumn:SetSize(10)
        elseif cCampo$"EE7_IMPODE,A1_NOME,B1_DESC,Y9_DESCR,Y9_CIDADE,EE7_STTDES,DESCRI"
            oColumn:SetSize(25)
        endif
        
        aAdd(aCpoRet, oColumn)

	next nX
return(aCpoRet)

//Array de dados
static function getDadosBrw(nTypeBrowse)
	local cQuery	:= ""
	local cAlias 	:= getNextAlias()
	local aDados	:= {}
	local aDado		:= {}
	local aCampos	:= {}
    local cCampos   := ""
	local nX		:= 1
	local cTipoCp	:= ""
    local cPictur   := ""
    Local cQebra    := chr(13)+chr(10)
    Local nPosPed   := 0
    Local cPedExp   := ""
    Local aSaldo    := {}
    Local nSaldo    := 0

    if nTypeBrowse == CONSULTA_VENDIDOS .OR. nTypeBrowse == CONSULTA_CANCELADOS .OR. nTypeBrowse == CONSULTA_EMBARQUES
        if nTypeBrowse == CONSULTA_VENDIDOS
		    aCampos := strToKarr(CONSULTA_VENDIDOS_CAMPOS, ",")
            cCampos := CONSULTA_VENDIDOS_CAMPOS
        endif

        cQuery := " SELECT  EE7_PEDIDO,EE7_REFIMP, EE7_PEDFAT, EE7_DTPROC, EE7_IMPORT+'-'+EE7_IMLOJA EE7_IMPORT, " +cQebra
        cQuery += "         EE7_IMPODE, A1_NOME, EE7_INCOTE, EE8_SEQUEN, B1_DESC,EE8_COD_I EE8_COD_I, " +cQebra
        cQuery += "         CASE WHEN EE7_CONSIG!='' THEN EE7_CONSIG+'-'+EE7_COLOJA ELSE '' END EE7_CONSIG, " +cQebra
        cQuery += "         EE8_SLDINI, round(EE8_PRECOI,4) EE8_PRECOI, EE8_PRCINC, " +cQebra
        cQuery += "         ROUND(EE8_VLFRET/EE8_SLDINI,4) EE8FRUNIT, EE8_PRCTOT, EE8_DTENTR, " +cQebra
        cQuery += "         EE8_VLFRET, EE7_DEST, Y9_DESCR, Y9_CIDADE, EE7_ESTUFA, EE7_STATUS, " +cQebra
        cQuery += "         EE7_STTDES, EEC_EMBARC,EEC_DTEMBA,EEC_DTESTU, " +cQebra
        cQuery += "         CASE WHEN EE7.EE7_CONDPA !='' THEN Ltrim(Rtrim(EE7.EE7_CONDPA))+'-'+LTRIM(RTRIM(ISNULL(YPA.YP_TEXTO,''))) +' '+ LTRIM(RTRIM(ISNULL(YPB.YP_TEXTO,''))) ELSE '' END PAY,  " +cQebra
        cQuery += "         ISNULL(EE6_NOME,'') EEC_EMBARC, " +cQebra
        cQuery += "         isnull(cast(cast(EE7_XINDOC as varbinary(8000)) as varchar(8000)),'') EE7_XINDOC, EE7_XBOOKI, EE7_XDLDRA, EE7_XDLCAR, EE7_XPAGAM, " +cQebra
        cQuery += "         CASE WHEN C5.C5_APROV3 != '' AND C5.C5_LIBER3 = 'S' THEN 'S-Liberado' WHEN C5.C5_APROV3 != '' AND C5.C5_LIBER3 != 'S' THEN 'N-Bloqueado' ELSE 'A-Aprov Autom' END BLOQ_COM, " +cQebra
        cQuery += "         C5.C5_DTBLOQ, C5.C5_HRBLOQ, C5.C5_DTLIB3, C5.C5_HRLIB3, " +cQebra
        cQuery += "         C5.C5_ROTEIRO, C5.C5_PLACA, " +cQebra
        cQuery += "         CASE WHEN ISNULL(C9.C9_NFISCAL,'ZZ') ='ZZ' THEN 'A-Pend. aprov comercial' " +cQebra
        cQuery += "              WHEN ISNULL(C9.C9_NFISCAL,'') !='' THEN 'F-Faturado' " +cQebra
        cQuery += "              WHEN ISNULL(C9.C9_BLCRED,'') != '' OR ISNULL(C9.C9_BLEST,'') !='' THEN 'B-Bloqueado' " +cQebra
        cQuery += "              WHEN ISNULL(C9.C9_BLCRED,'')  = '' OR ISNULL(C9.C9_BLEST,'')  =''  THEN 'L-Liberado' " +cQebra
        cQuery += "              ELSE 'N-Na' END BLOQ_CRED, " +cQebra
        cQuery += "         CASE WHEN C9.C9_NFISCAL !='' THEN C9.C9_NFISCAL+'/'+C9.C9_SERIENF ELSE '' END C9_NFISCAL " +cQebra
        cQuery += "    FROM "+ RetSqlName("EE7") +" (NOLOCK) EE7 INNER JOIN "+ RetSqlName("EE8") +" (NOLOCK) EE8 ON EE8.EE8_FILIAL=EE7.EE7_FILIAL AND EE8.EE8_PEDIDO=EE7.EE7_PEDIDO " +cQebra
        cQuery += "                    INNER JOIN "+ RetSqlName("SB1") +" (NOLOCK)  B1 ON B1.D_E_L_E_T_='' AND B1.B1_COD=EE8.EE8_COD_I " +cQebra
        cQuery += "                    LEFT  JOIN "+ RetSqlName("SC5") +" (NOLOCK)  C5 ON C5.D_E_L_E_T_='' AND C5.C5_FILIAL='"+ xFilial("SC5") +"' AND EE7.EE7_FILIAL='"+ xFilial("EE7") +"' AND C5.C5_PEDEXP=EE7.EE7_PEDIDO " +cQebra
        cQuery += "                    LEFT  JOIN "+ RetSqlName("SC9") +" (NOLOCK)  C9 ON C9.D_E_L_E_T_='' AND C9.C9_FILIAL=C5.C5_FILIAL AND C9.C9_PEDIDO=EE7.EE7_PEDFAT AND C9.C9_ITEM=EE8.EE8_FATIT " +cQebra
        cQuery += "                    LEFT  JOIN "+ RetSqlName("EEC") +" (NOLOCK) EEC ON EEC.D_E_L_E_T_='' AND EEC.EEC_FILIAL='"+ xFilial("EEC") +"' AND  EE7.EE7_FILIAL='"+ xFilial("EE7") +"' AND EE7.EE7_PEDIDO=EEC.EEC_PEDREF " +cQebra
        cQuery += "                    LEFT  JOIN "+ RetSqlName("EE6") +" (NOLOCK) EE6 ON EE6.D_E_L_E_T_='' AND EE6.EE6_FILIAL='"+ xFilial("EE6") +"' AND  EE6.EE6_COD = EEC.EEC_EMBARC " +cQebra
        cQuery += "                    LEFT  JOIN "+ RetSqlName("SY9") +" (NOLOCK)  Y9 ON Y9.D_E_L_E_T_=''  AND Y9.Y9_COD=EE7.EE7_DEST " +cQebra
        cQuery += "                    LEFT  JOIN "+ RetSqlName("SA1") +" (NOLOCK)  A1 ON A1.D_E_L_E_T_=''  AND EE7.EE7_CONSIG=A1.A1_COD AND EE7.EE7_COLOJA=A1.A1_LOJA " +cQebra
        cQuery += "                    LEFT  JOIN "+ RetSqlName("SY6") +" (NOLOCK)  Y6 ON Y6.D_E_L_E_T_=''  AND Y6.Y6_FILIAL='"+ xFilial("SYA") +"' AND Y6.Y6_COD =EE7.EE7_CONDPA " +cQebra
        cQuery += "                    LEFT  JOIN "+ RetSqlName("SYP") +" (NOLOCK) YPA ON Y6.D_E_L_E_T_=''  AND YPA.D_E_L_E_T_='' AND YPA.YP_CAMPO='Y6_DESC_P' AND Y6.Y6_DESC_P= YPA.YP_CHAVE AND YPA.YP_SEQ='001' " +cQebra
        cQuery += "                    LEFT  JOIN "+ RetSqlName("SYP") +" (NOLOCK) YPB ON Y6.D_E_L_E_T_=''  AND YPB.D_E_L_E_T_='' AND YPB.YP_CAMPO='Y6_DESC_P' AND Y6.Y6_DESC_P= YPB.YP_CHAVE AND YPB.YP_SEQ='002' " +cQebra
        cQuery += "    WHERE EE7.D_E_L_E_T_='' " +cQebra
        
        if !Empty(dDtDe) .or. !Empty(dDtAte)
            cQuery += " AND EE8.EE8_DTENTR BETWEEN '"+ Dtos(dDtDe) +"' AND '"+ Dtos(dDtAte) +"' "
        endif

        if !Empty(cEE7PED)
            cQuery += " AND EE7.EE7_PEDIDO = '"+ cEE7PED +"' "
        endif
        
        if !Empty(cIMPORT)
            cQuery += " AND EE7.EE7_IMPORT ='"+ cImport +"' "
        endif

        if !Empty(cCONSIG)
            cQuery += " AND EE7.EE7_CONSIG ='"+ cCONSIG +"' "
        endif

        if !Empty(cSTATUS) .AND. Left(cStatus,1) != "Z"
            cQuery += " AND EE7.EE7_STATUS IN "+ formatin(replace(cSTATUS,"0","*"),",") +" "
        elseIF Empty(cSTATUS)
            cQuery += " AND EE7.EE7_STATUS != 'D' "
        endif
        
        cQuery += "    ORDER BY EE8.EE8_DTENTR DESC; "
    
    elseif nTypeBrowse == CONSULTA_EXPORTACAO
        aCampos := strToKarr(CONSULTA_ITENS_EXPORTACAO, ",")
        cCampos := CONSULTA_VENDIDOS_CAMPOS
        
        cQuery := " SELECT " + CONSULTA_ITENS_EXPORTACAO + " " +cQebra
        cQuery += "    FROM "+ RetSqlName("EE8") +" EE8 INNER JOIN "+ RetSqlName("SB1") +"  B1 ON B1.D_E_L_E_T_='' AND B1.B1_COD=EE8.EE8_COD_I " +cQebra
        cQuery += "    WHERE EE8.D_E_L_E_T_='' "
        
        if Type("oBExpo") == "O" .and. Len(aExpoDad)> 0
            nPosPed   := aScan(aExpoCam, "EE7_PEDIDO")
            cPedExp	:= Alltrim(aExpoDad[oBExpo:At(), nPosPed])
        else
            cProd	:= ""
        endif
        
        cQuery += " AND EE8.EE8_PEDIDO='"+ cPedExp +"' "
        cQuery += "    ORDER BY EE8.EE8_SEQUEN; "

    elseif nTypeBrowse == CONSULTA_PAISES
        aCampos := strToKarr(CONSULTA_PAISES_HOMOL, ",")
        cCampos := CONSULTA_PAISES_HOMOL
        
        cQuery := " SELECT " + CONSULTA_PAISES_HOMOL
        cQuery += " FROM "+ RetSqlName("ZE4") +" (NOLOCK) ZE4 INNER JOIN "+ RetSqlName("SYA") +" (NOLOCK) YA ON ZE4.ZE4_FILIAL=YA.YA_FILIAL AND ZE4.ZE4_ZE3SYA=YA.YA_CODGI "
        cQuery += " WHERE ZE4.D_E_L_E_T_='' AND YA.D_E_L_E_T_='' AND ZE4.ZE4_FILIAL='"+ xFilial("ZE4") +"' "
        
        if Type("oBExpo") == "O" .and. Len(aExpoDad)> 0
            cPedExp	    := Alltrim(aExpoDad[oBExpo:At(), aScan(aExpoCam, "EE7_PEDIDO")])
            cProd	    := Alltrim(aItExDad[oBItEx:At(), aScan(aItExCam, "EE8_COD_I")])

            DbSelectArea("EE7")
            EE7->(DbSetOrder(1))
            if EE7->(Dbseek(xFilial("EE7")+cPedExp))
                cQuery += " AND ZE4.ZE4_CODPRD='"+ cProd +"' AND ZE4.ZE4_ZE3SYA='"+ EE7->EE7_PAISET +"'"
            else
                cQuery += " AND ZE4.ZE4_CODPRD='' AND ZE4.ZE4_ZE3SYA=''"
            Endif

        else
             cQuery += " AND ZE4.ZE4_CODPRD='' AND ZE4.ZE4_ZE3SYA=''"
        endif

    elseif nTypeBrowse == CONSULTA_ESTOQUE
        aCampos := strToKarr(CONSULTA_SALDO_ESTOQUE, ",")
        cCampos := CONSULTA_SALDO_ESTOQUE
        
        //TEMP
        aSaldo  := fGetEst()
        //AADD(aSaldo,{0, 0, 0, 0})
        cQuery := " SELECT C6.C6_ENTREG, LTRIM(RTRIM(EE7.EE7_PEDIDO)) EE7_PEDIDO, C6.C6_NUM, C6.C6_QTDVEN-C6.C6_QTDENT C6_QTDVEN" +cQebra
        cQuery += "    FROM "+ RetSqlName("SC6") +" C6 INNER JOIN "+ RetSqlName("SC5") +"  C5 ON  C6.D_E_L_E_T_='' AND C5.D_E_L_E_T_='' AND C6.C6_FILIAL=C5.C5_FILIAL AND C6.C6_NUM=C5.C5_NUM " +cQebra
        cQuery += "                                    INNER JOIN "+ RetSqlName("EE7") +" EE7 ON EE7.D_E_L_E_T_='' AND C5.C5_FILIAL='"+ xFilial("SC5") +"' AND EE7.EE7_FILIAL='"+ xFilial("EE7") +"' AND C5.C5_PEDEXP=EE7.EE7_PEDIDO "
        cQuery += "    WHERE C6.D_E_L_E_T_='' AND C6.C6_FILIAL='"+ xFilial("SC6") +"' AND C6.C6_ENTREG >='20200101' AND C6.C6_BLQ !='R' AND C5.C5_NOTA='' AND C6.C6_QTDVEN-C6.C6_QTDENT > 0 "
        
        if Type("oBItEx") == "O" .and. Len(aItExDad)> 0
            cProd	:= Alltrim(aItExDad[oBItEx:At(), aScan(aItExCam, "EE8_COD_I")])
            cQuery += " AND C6.C6_PRODUTO ='"+ cProd +"' "
        else
            cQuery += " AND C6.C6_PRODUTO ='' "
        endif
        
        cQuery += "    ORDER BY C6.C6_ENTREG, C6.C6_NUM; "
    
    endif

	tcQuery cQuery new alias &cAlias

	(cAlias)->(DbGoTop())

	if (cAlias)-> (!eof())

        if nTypeBrowse == CONSULTA_ESTOQUE
            if Len(aSaldo) > 0
                aAdd(aDados, {Date(), 'Saldo Inicial', Transform(aSaldo[01][02], "@E 999,999,999.99"), Transform(aSaldo[01][02], "@E 999,999,999.99")})
                nSaldo := aSaldo[01][02]
            else
                aAdd(aDados, {Date(), 'Saldo Inicial', Transform(0, "@E 999,999,999.99"), Transform(0, "@E 999,999,999.99")})
                nSaldo := 0
            Endif
            
        endif

		While (cAlias)->(!eof())
			aDado := {}
            
            if nTypeBrowse == CONSULTA_ESTOQUE
                nSaldo  := nSaldo-(cAlias)->C6_QTDVEN

                aAdd(aDado, STOD((cAlias)->C6_ENTREG))
                aAdd(aDado, IIF(eMPTY((cAlias)->EE7_PEDIDO),"Pedido:"+(cAlias)->C6_NUM,"Pedido Exp.:"+ALLTRIM((cAlias)->EE7_PEDIDO)+'('+(cAlias)->C6_NUM+')'))
                aAdd(aDado, Transform((cAlias)->C6_QTDVEN , "@E 999,999,999.99"))
                aAdd(aDado, Transform(nSaldo , "@E 999,999,999.99"))
                
            else
                for nX := 1 to Len(aCampos)
                    if Alltrim(aCampos[nX]) == "EE8FRUNIT"
                        cTipoCp	:= "N"
                        cPictur	:= "@E 999,999,999.99"
                    Elseif Alltrim(aCampos[nX]) == "PAY"
                        cTipoCp	:= "C"
                        cPictur	:= ""
                    elseif Alltrim(aCampos[nX]) == "SALDO"
                        cTipoCp	:= "N"
                        cPictur	:= "@E 999,999,999.99"
                    else
                        cTipoCp	:= allTrim(getSx3Cache(aCampos[nX], "X3_TIPO"))
                        cPictur	:= allTrim(getSx3Cache(aCampos[nX], "X3_PICTURE"))
                    endif

                    if cTipoCp == "N"
                        aAdd(aDado,  Transform((cAlias)-> &(aCampos[nX]), cPictur))
                    elseif cTipoCp == "D"
                        aAdd(aDado, sToD((cAlias)-> &(aCampos[nX])))
                    else
                        aAdd(aDado, (cAlias)-> &(aCampos[nX]))
                    endif
                    
                next nX

            endif

            aAdd(aDado, .F.)
			aAdd(aDados, aDado)
			(cAlias)->(DbSkip())
		EndDo
	endIf

return(aDados)


Static Function fDefLeg()
    
    aAdd(aLegenda,{"BR_CANCEL"         , "Cancelado"                            ,"*" })
    aAdd(aLegenda,{"BR_MARROM"         , "Aguardando Solicitacao de Credito"    ,"1" })
    aAdd(aLegenda,{"BR_MARRON_OCEAN"   , "Aguardando Liberacao de Credito"      ,"2" })
    aAdd(aLegenda,{"BR_PINK"           , "Credito Liberado"                     ,"3" })                  
    aAdd(aLegenda,{"BR_AZUL_CLARO"     , "Aguardando Confeccao Documentos"      ,"4" })
    aAdd(aLegenda,{"BR_VIOLETA"        , "Aguardando Embarque"                  ,"5" })
    aAdd(aLegenda,{"BR_AZUL"           , "Embarcado"                            ,"6" })
    aAdd(aLegenda,{"BR_AZUL"           , "Embarcado - Em Transito"              ,"G" })
    aAdd(aLegenda,{"BR_AZUL"           , "Embarcado - Estoque em Consignacao"   ,"H" })
    aAdd(aLegenda,{"BR_PRETO_1"        , "Lancado na Fase de Embarque"          ,"7" })
    aAdd(aLegenda,{"BR_VERDE"          , "Lanc.Parcial na Fase de Embarque"     ,"E" })
    aAdd(aLegenda,{"BR_VERDE_ESCURO"   , "Cambio a Contratar"                   ,"8" })
    aAdd(aLegenda,{"BR_VERDE_ESCURO"   , "Cambio Parcial"                       ,"9" })
    aAdd(aLegenda,{"BR_VERDE_ESCURO"   , "Cambio Contratado"                    ,"A" })
    aAdd(aLegenda,{"BR_AMARELO"        , "Aguardando Faturamento"               ,"B" })
    aAdd(aLegenda,{"BR_PRETO_0"        , "Faturado Parcialmente"                ,"C" })
    aAdd(aLegenda,{"BR_VERMELHO"       , "Faturado"                             ,"D" })
    aAdd(aLegenda,{"BR_PRETO"          , "Pedido especial para geracao de R.V. desvinculada"    ,"F" })
    aAdd(aLegenda,{"BR_CINZA"          , "Wash-Out In"                          ,"I" })
    aAdd(aLegenda,{"BR_CINZA"          , "Wash-Out Out"                         ,"J" })
    aAdd(aLegenda,{"BR_CINZA"          , "Wash-Out Nothing"                     ,"K" })
    aAdd(aLegenda,{"BR_CINZA"          , "Wash-Out de RV"                       ,"L" })
    aAdd(aLegenda,{"BR_CINZA"          , "Wash-Out a definir"                   ,"M" })

    nLegenda := Len(aLegenda)
return

Static Function fGetLeg(nLeg, cStatus)
    Local uRetLeg   := nil
    Local nA        := 0

    // Retorna as opções do campo de seleção do filtro.
    if nLeg == 1
        uRetLeg := {}
        AADD(uRetLeg,"Z=Todos")
        for nA := 1 to nLegenda'
            AADD(uRetLeg,aLegenda[nA][3]+"="+aLegenda[nA][2])
        next nA
    // retorna os valores em cores da legenda do campo.
    elseif nLeg == 2
        nA  := aScan(aLegenda,{|x| AllTrim(x[3])==Alltrim(cStatus)})
    
        if nA == 0
            uRetLeg     := "BR_WHITE"
        else
            uRetLeg     := aLegenda[nA][01]
        endif
    // Retorna as legendas para a tela de consulta.
    elseif nLeg == 3
        uRetLeg := {}

        for nA := 1 to nLegenda'
            AADD(uRetLeg,{aLegenda[nA][1],aLegenda[nA][2]})
        next nA
    endif
return uRetLeg


Static function fGetEst()
    Local aDados    := {}
    Local cQuery    := ""
    Local cProd     := ""
    Local nReg      := Len(aItExDad)
    
    if nReg == 0 .or. Type("oBItEx") != "O"
        cProd   := ""
    else
        cProd	:= Alltrim(aItExDad[oBITex:at(), aScan(aItExCam, "EE8_COD_I")])
    endif

    AADD(aDados,{"Qtd. Endereçada KG ",0})
    AADD(aDados,{"Qtd. Túnel KG ",0})
    AADD(aDados,{"Qtd. Produzida KG ",0})
    AADD(aDados,{"Qtd. Programada KG ",0})

    cQuery := " SELECT [ID_PRODMATEEMBA] "
    cQuery += "   ,[IE_MATEEMBA]
    cQuery += "   ,[NM_PRODMATEEMBA]
    cQuery += "   ,[NM_CATEMATE]
    cQuery += "   ,[QN_ENDE]
    cQuery += "   ,[QN_PESOENDE]
    cQuery += "   ,[QN_TUNE]
    cQuery += "   ,[QN_PESOTUNE]
    cQuery += "   ,[QN_PROD]
    cQuery += "   ,[QN_PESOPROD]
    cQuery += "   ,[QN_PROG]
    cQuery += "   ,[QN_PESOPROG]
    cQuery += " FROM [LNKMIMS].SMART.dbo.[VW_ESTOQUE_SALDO]
    cQuery += " WHERE [IE_MATEEMBA]='"+ cProd +"' "

    TcQuery cQuery ALIAS "QEST" NEW

    If QEST->(!EOF())
        aDados[1][1]    := aDados[1][1]+"- "+Alltrim(TRANSFORM(QEST->QN_PESOENDE, "@E 999,999,999.99"))+"(CX "+Alltrim(TRANSFORM(QEST->QN_ENDE, "@E 999,999,999.99"))+")"
        aDados[2][1]    := aDados[2][1]+"- "+Alltrim(TRANSFORM(QEST->QN_PESOTUNE, "@E 999,999,999.99"))+"(CX "+Alltrim(TRANSFORM(QEST->QN_TUNE, "@E 999,999,999.99"))+")"
        aDados[3][1]    := aDados[3][1]+"- "+Alltrim(TRANSFORM(QEST->QN_PESOPROD, "@E 999,999,999.99"))+"(CX "+Alltrim(TRANSFORM(QEST->QN_PROD, "@E 999,999,999.99"))+")"
        aDados[4][1]    := aDados[4][1]+"- "+Alltrim(TRANSFORM(QEST->QN_PESOPROG, "@E 999,999,999.99"))+"(CX "+Alltrim(TRANSFORM(QEST->QN_PROG, "@E 999,999,999.99"))+")"

        aDados[1][2]    := QEST->QN_PESOENDE
        aDados[2][2]    := QEST->QN_PESOTUNE
        aDados[3][2]    := QEST->QN_PESOPROD
        aDados[4][2]    := QEST->QN_PESOPROG
    endif

    QEST->(DbCloseArea())
return aDados


Static Function fGrafico()
    Local nA        := 1
    Local aDados    := {}
    Local nDados    := 0

    if Type("oChart") == "O"
        oChart:Deactivate()
    endif
    
    //oChart:addSerie('Apresentação teste',   96 )
    //oChart:addSerie('Qualificação teste',   100  )

    aDados  := fgetEst()
    nDados  := Len(aDados)

    for nA := 1 to nDados
        oChart:addSerie(aDados[nA][1], aDados[nA][2])
    next nA

    oChart:setPicture("@E 999,999,999.99")
    oChart:setMask(" *@*")
    //oChart:setColor("Random")
    oChart:SetLegend(CONTROL_ALIGN_LEFT)
    //oChart:setTitle("Titulo do Grafico", CONTROL_ALIGN_CENTER)
    oChart:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)
    oChart:EnableMenu(.T.)
    oChart:SetChartDefault(FUNNELCHART)
    
    oChart:Activate()
return
