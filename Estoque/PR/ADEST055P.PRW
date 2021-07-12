//#Include "Protheus.ch"
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

// Cabeçalho - Tabela de Estabelecimentos.
#DEFINE ZE0_CAMPO_VIEW  "ZE0_REGIST, ZE0_CNPJ, ZE0_RAZAO, ZE0_AMBINS"
#DEFINE ZE0_CAMPO_MODEL "ZE0_FILILAL, ZE0_REGIST, ZE0_CNPJ, ZE0_RAZAO, ZE0_AMBINS"

// Grids
#DEFINE CONSULTA_PRODUTO    1
#DEFINE CONSULTA_PAIS       2
#DEFINE PGA_REQMER          3
#DEFINE PGA_MERCADO         4
#DEFINE PGA_PAIS            5
#DEFINE PGA_PRODUTO         6
#DEFINE PGA_PRD_HOMOL       7
#DEFINE GRI_REQMER          8
#DEFINE HOM_PAIS            9
#DEFINE HOM_CLI            10
#DEFINE HOM_EXI            11
#DEFINE HOM_CSI            12

// Defines dos campos.
#DEFINE CONSULTA_PAIS_CAMPOS        "YA_CODGI,YA_DESCR"
#DEFINE CONSULTA_PRODUTO_CAMPOS     "B1_COD,B1_DESC,B1_TIPO, ZE1_REGIST, ZE1_DENOMI"
#DEFINE PGA_REQMER_CAMPOS           "ZE1_REGIST, ZE1_DENOMI"
#DEFINE PGA_MERCADO_CAMPOS          "ZE2_MERCAD,X5_DESCRI"
#DEFINE PGA_PAIS_CAMPOS             "YA_CODGI,YA_DESCR"
#DEFINE PGA_PRODUTO_CAMPOS          "B1_COD,B1_DESC,B1_TIPO,B1_XREQTEC,B1_XDTUPLD"
#DEFINE PGA_PRD_HOMOL_CAMPOS        "B1_COD,B1_DESC,B1_TIPO"
#DEFINE HOM_PAIS_CAMPOS             "YA_CODGI,YA_DESCR"
#DEFINE HOM_CLI_CAMPOS              "A1_NOME,A1_COD, A1_LOJA"
#DEFINE HOM_EXI_CAMPOS              "ZEZ_COD,ZEZ_DESCRI,ZEZ_OBSERV"
#DEFINE HOM_CSI_CAMPOS              "ZEA_COD,ZEA_DESCRI,ZEA_OBSERV"
//#DEFINE HOM_PAIS_CAMPOS           "B1_COD,B1_DESC,B1_TIPO"

/*/{Protheus.doc} User Function ADEST055P u_ADEST055P()
    Tela de gestão dos cadastros PGA.
    Chamado 8465
    @type  Function
    @author Leonardo P. Monteiro
    @since 23/02/2021
    @version 01
    @history Chamado 8465 - Leonardo P. Monteiro - 04/03/2021 - Inclusão das validações do projeto de exportação.
    @history Chamado 8465 - Leonardo P. Monteiro - 10/04/2021 - Melhoria na inclusão de registros de produtos.
    @history Chamado 8465 - Leonardo P. Monteiro - 30/04/2021 - Melhoria na rotina para criação da sub-categoria do PGA.
    @history Chamado 8465 - Leonardo P. Monteiro - 05/05/2021 - Correção de error.log na execução da rotina.
    @history Chamado 8465 - Leonardo P. Monteiro - 28/05/2021 - Inclusão da opção de integração via Web-bot PGA.
    @history Chamado 8465 - Leonardo P. Monteiro - 06/07/2021 - Implementação dos modelos CSI e exigências por país.
/*/

user function ADEST055P(nOperac)
    Local nConfirma := 1
    Local cTitulo   := ""
    Local cModel    := ""
    Local nAcao     := 0

    DbSelectArea("ZE0")
    ZE0->(DbsetOrder(1))

    if ZE0->(Eof())
        cTitulo   := "Inclusão de novo estabelecimento"
        cModel    := "ADEST056P"
        nAcao     := 3
        
        nConfirma := FWExecView(cTitulo,cModel, nAcao, , { || .T. }, , 60, )
        
        if nConfirma == 0
            fProcessa()
        else
            MsgInfo("Não foi cadastrado um estabelecimento para iniciar a rotina!")
        endif
    Else
        ZE0->(DbGotop())

        fProcessa(nOperac)
    endif

return

Static Function fProcessa(nOperac)
//user function ADEST055P()
    Local nRet      := .T.
    Local cTitle    := ""
    //Local aZE0      := {}
    // Componentes de tela
    Private oLayer
    Private oSize
    Private oFont 	    := TFont():New(,,-14,.T.)
    Private oTTabs
    Private oChart
    Private bMudaAba	:=  {|| fMudaaba() }
    Private nBrwFocused := 0

    Private bMark       := {|oPgBPrd| fMark(oPgBPrd)}
    Private bDblClk     := {|oPgBPrd| fDblClk(oPgBPrd) /*Função DoubleClick*/ }
    Private bHeaClk     := {|oPgBPrd| fHeaClk(oPgBPrd) /* Função de HEADERCLICK*/}
    Private bPgBPai     := {|| iif(nBrwFocused == PGA_PAIS, foBrwPrd(PGA_PRD_HOMOL), ) }
    Private bPgBMer     := {|| iif(nBrwFocused == PGA_MERCADO, foBrwPrd(PGA_PRODUTO), ) }

    Private bCoBPro     := {|| fCoBPro() }
    //Private bHoBPai     := {|| fHoBPai() }


    PRIVATE oFoCol1
    // --------------------------------------------
    // Componentes do Cabeçalho
    // --------------------------------------------
    // Campos
    Private oZE0REGIST
	Private cZE0REGIST  := ""

    Private oZE0CNPJ
	Private cZE0CNPJ    := ""
    
    Private oZE0RAZAO
	Private cZE0RAZAO   := ""

    Private oZE0AMBINS
	Private cZE0AMBINS  := ""
    Private nZE0AMBINS  := 0
    Private aZE0AMBINS  := {}

    // --------------------------------------------
    // Componentes de Tela
    // --------------------------------------------
    // Panels
    Private oCoPnl01
    Private oPgPnl01
    Private oHoPnl01

    // TGridLayout
    Private oCoGd01

    // FwBrowsers
    Private oCoBPrd
    Private oCoBPHo
    Private oPgBRme
    Private oPgBMer
    Private oPgBPai
    Private oPgBPrd
    Private oHoBPai
    Private oHoBCli
    Private oHoBExi
    Private oHoBCsi
    

    //Dbtree
    Private oPgTRMe
    Private oRmTRMe
    //Button

    Private oBtnCons
    Private oBtnIncl
    Private oBtnAlte
    Private oBtnExcl
    Private oBtnProd
    Private oBtnUpEt
    Private oBtnDwEt
    Private oBtnDwEtA
    // Say
    Private oSayProd
    Private oSayRePr
    // Layers
    Private oCoLay01
    Private oCoLay02
    Private oCoLay03
    Private oPgLay01

    // Window
    Private oCoWin01
    Private oCoWin02
    Private oCoWin03

    Private oPgWin01
    Private oPgWin02
    Private oPgWin03
    Private oPgWin04
    Private oPgWin05
    
    //Array o Browser CONSULTA_PRODUTOS
    Private aCoPrdCab       := {}
    Private aCoPrdCam       := {}
    Private aCoPrdDad       := {}

    //Array o Browser CONSULTA_PAIS
    Private aCoPHoCab       := {}
    Private aCoPHoCam       := {}
    Private aCoPHoDad       := {}

    //Array o Browser PGA_REQMER
    Private aPgRMeCab       := {}
    Private aPgRMeCam       := {}
    Private aPgRMeDad       := {}

    //Array o Browser PGA_MERCADO
    Private aPgMerCab       := {}
    Private aPgMerCam       := {}
    Private aPgMerDad       := {}

    //Array o Browser PGA_PAIS
    Private aPgPaiCab       := {}
    Private aPgPaiCam       := {}
    Private aPgPaiDad       := {}

    //Array o Browser PGA_PRODUTO
    Private aPgPrdCab       := {}
    Private aPgPrdCam       := {}
    Private aPgPrdDad       := {}
    Private nPgPrdCam       := 0

    //Array o Browser HOM_PAIS
    Private aHoPaiCab       := {}
    Private aHoPaiCam       := {}
    Private aHoPaiDad       := {}

    //Array o Browser HOM_CLIENTE
    Private aHoCliCab       := {}
    Private aHoCliCam       := {}
    Private aHoCliDad       := {}

    //Array o Browser HOM_CSI
    Private aHoCsiCab       := {}
    Private aHoCsiCam       := {}
    Private aHoCsiDad       := {}

    //Array o Browser HOM_EXI
    Private aHoExiCab       := {}
    Private aHoExiCam       := {}
    Private aHoExiDad       := {}

    // Campos
    Private oZE1REGT
    Private cZE1REGT
    Private oZE1REGG
    Private cZE1REGG
    
    Private oZE1DENT
    Private cZE1DENT
    Private oZE1DENG
    Private cZE1DENG

    Private oSldEstT
    Private oSldEstG
    Private nSldEstG    := 0

    Private oSldBlqT
    Private oSldBlqG
    Private nSldBlqG    := 0
    Private cBtnCss     := ""
    Private cLayCSS     := ""

    Private ARMAZEM := "ARMAZEM"
    Private IMAGE5  := "FOLDER5"
    Private IMAGE6  := "FOLDER6"
    Private IMAGE10 := "FOLDER10"
    Private IMAGE11 := "FOLDER11"
    Private aNodes  := {}
    Private aSeek   := {}

    private nOpcFilter		:= 0
	private nOpcBrowse		:= 1

    Private nOper   := 4
    Default nOperac := 4
    
    nOper := nOperac

    /*
    2 - Visualiza
    3 - Inclusão
    4 - Alteração
    5 - Exclusão
    */
    
    //cLayCSS := "QFrame{ margin-top: 10px; padding-left:03px; padding-right:03px} TButton{ margin-bottom: 7px; }"
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

    DbselectArea("ZE0")
    ZE0->(Dbgotop())
    DbselectArea("ZE1")
    DbselectArea("ZE2")
    DbselectArea("ZE3")



    if nOper == 3
        cTitle  := "Inclusão"
    elseif nOper == 4
        cTitle  := "Alteração"
    elseif nOper == 5
        cTitle  := "Exclusão"
    else
        cTitle  := "Visualizar"
    endif

    oWnd            := Msdialog():Create()
    oWnd:cTitle     := "SIGSIF - PGA ("+cTitle+")"
    ownd:nWidth     := nLarg
    oWnd:nHeight    := nAlt
    oWnd:lMaximized := .T.
    oWnd:SetCSS("QWidget{ font: bold 12px; } TTabs{ margin: 0px; } ")

    oLayer := FWLayer():new()
    
    oLayer:init(oWnd,.T.)
    oLayer:opanel:nHeight    := nAlt*1.01

    layHeader()
    layDetail()
    //layFooter()

    oWnd:Activate()

return nRet

Static Function fMudaAba()
    oCoPnl01:lVisibleControl      := (oTTabs:nOption == 1)
    oPgPnl01:lVisibleControl      := (oTTabs:nOption == 2)
    oHoPnl01:lVisibleControl      := (oTTabs:nOption == 3)
return

/* Layoutdet - Carrega os componentes da sessão de detalhes. */
Static function layDetail()
    Local aTabs     := {"Consultas","Cadastro PGA","Grp. Inspeção"}
    Local aTamObj   := {}
    Local nBot      := 26
    Local nRight    := 1.9
    Local nRow      := 0
    Local nCol      := 0
    Local nHeight   := 0
    Local nWidth    := 0
        
    //Tela de talhada com os grids e folders.
    //olayer:addLine("L02",70, .F.)
    olayer:addLine("L02",80, .F.)
    oLayer:addCollumn("L02C01", 100, .F., "L02")
    oLayer:GetLinePanel("L02"):SetCSS("QFrame{ background-color: #FFFFFF;}")
    
    oL02C01 := oLayer:getColPanel("L02C01","L02")
    oL02C01:SetCSS("TTabs{ margin: 0px; }")

    oSize := FWDefSize():New(.F.)
	oSize:AddObject( "FOLDER"	, 100, 100, .T., .T. )
	
	oSize:lLateral	:= .T. // Elementos um do lado do outro
	oSize:lProp		:= .T. // Cálculo dos botões proporcionais
	oSize:SetWindowSize({000, 000, oL02C01:nHeight, oL02C01:nWidth})
	oSize:Process() 		// executa os calculos
    
    oTTabs := TTabs():New(oSize:GetDimension("FOLDER","LININI"),;
                          oSize:GetDimension("FOLDER","COLINI"),;
                          aTabs,Nil,oL02C01,Nil,CLR_HRED,Nil,.T.,Nil,;
                          oSize:GetDimension("FOLDER","XSIZE")-03,;
                          oSize:GetDimension("FOLDER","YSIZE")+10)
    //oTTabs:SetCSS("QFrame{ background-color: #FFFFFF; }")
    

    U_DefTamObj(@aTamObj,001,001,(oTTabs:nClientHeight / 2)-nBot,(oTTabs:nClientWidth / 2)-nRight)

    nRow    := aTamObj[1]
    nCol    := aTamObj[2]
    nHeight := aTamObj[3]
    nWidth  := aTamObj[4]

    // Panel consultas
    fPanel1("::.. Consultas"        , nRow, nCol, nHeight, nWidth)
    // Cadastro PGA 
    fPanel2("::.. Cadastro PGA"     , nRow, nCol, nHeight, nWidth)
    //Grupos de Inspeção
    fPanel3("::.. Grp. Inspeção"  , nRow, nCol, nHeight, nWidth)

    oTTabs:SetOption(1)

    oTTabs:bAction := bMudaAba
	Eval(bMudaAba)

 


return nil

Static Function fCoBPro() // oCoBPro
    //Local nPos  := oCoBPrd:At()
    //Local cProd	:= aCoPrdDad[oBrwProntos:At(), aScan(aCoPrdCam, "B1_COD")]
    
    
    if Type("oCoBPHo") == "O"

        aCoPHoDad := getDadosBrw(CONSULTA_PAIS)
        
        oCoBPHo:setArray(aCoPHoDad)
        oCoBPHo:Refresh()
        //TMP    
        //fGrafico()
    endif

Return

Static function fGetEst()
    Local aDados    := {}
    Local cQuery    := ""
    Local nReg      := Len(aCoPrdDad)
    if nReg == 0
        cProd   := ""
    elseif Type("oCoBPrd") != "O"
        cProd	:= Alltrim(aCoPrdDad[1, aScan(aCoPrdCam, "B1_COD")])
    else
        cProd	:= Alltrim(aCoPrdDad[oCoBPrd:At(), aScan(aCoPrdCam, "B1_COD")])
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

/**************************************************** 
  Aba de Consulta aos cadastros e estoque do produto.
****************************************************/
Static function fPanel1(cDescri, nRow, nCol, nHeight, nWidth)
    
    //Local aRet      := {}
    
    oCoPnl01 := TPanel():New(nRow,nCol,'',oTTabs,,,,,,nWidth,nHeight,,.T.)
    oCoPnl01:lVisibleControl  := .F.
    
    oCoLay01 := FWLayer():new()
    oCoLay01:init(oCoPnl01,.T.)

    oCoLay01:addLine("LMAIN",100, .F.)
    oCoLay01:addCollumn("C01", 44, .F., "LMAIN")
    oCoLay01:addCollumn("C02", 06, .F., "LMAIN")
    oCoLay01:addCollumn("C03", 50, .F., "LMAIN")
    
    oCoLay01:addWindow("C01", "Win01", "Produtos"		        , 100,.F.,.F.,{||"" },"LMAIN",{||""})
    oCoLay01:addWindow("C03", "Win02", "Detalhes"		        , 050,.F.,.F.,{||"" },"LMAIN",{||""})
    oCoLay01:addWindow("C03", "Win03", "Países Homologados"		, 050,.F.,.F.,{||"" },"LMAIN",{||""})
    
    oCoLay01:GetLinePanel("LMAIN"):SetCSS("QFrame{ background-color: #FFFFFF;}")

    oCoLay01:show()
    
    //********************************************
    // Sessão de produtos
    //********************************************
    
    aCoPrdCab		:= getCampos(CONSULTA_PRODUTO)
    aCoPrdDad		:= getDadosBrw(CONSULTA_PRODUTO)
    
    oCoWin01 := oCoLay01:GetWinPanel("C01","Win01","LMAIN")

    // Grid de consulta de produtos
    oCoBPrd := FWBrowse():New(oCoWin01)
    oCoBPrd:setColumns(aCoPrdCab)
	oCoBPrd:setDataArray()
	oCoBPrd:disableReport()
	oCoBPrd:disableConfig()
    oCoBPrd:setArray(aCoPrdDad)
    oCoBPrd:setChange(bCoBPro)

    aAdd(aSeek,{"Produto"   , {{"","C",15,0, "B1_COD",}}})
    aAdd(aSeek,{"Descrição" , {{"","C",45,0, "B1_DESC",}}})
    
    oCoBPrd:setSeek({|oSeek, oBrowse| filtraProd(oSeek, oBrowse, aCoPrdCam)}, aSeek)
    
    oCoBPrd:setFieldFilter({ {"B1_COD"   ,getSx3Cache("B1_COD", "X3_TITULO") ,getSx3Cache("B1_COD", "X3_TIPO") ,getSx3Cache("B1_COD", "X3_TAMANHO") ,getSx3Cache("B1_COD", "X3_DECIMAL") ,getSx3Cache("B1_COD", "X3_PICTURE") },;
                             {"B1_DESC"  ,getSx3Cache("B1_DESC", "X3_TITULO"),getSx3Cache("B1_DESC", "X3_TIPO"),getSx3Cache("B1_DESC", "X3_TAMANHO"),getSx3Cache("B1_DESC", "X3_DECIMAL"),getSx3Cache("B1_DESC", "X3_PICTURE")};
						    })
    
    oCoBPrd:bGotFocus := {|| nBrwFocused := 1}
    oCoWin01:Refresh( .T. ) 
    oCoBPrd:Activate()
    
    //********************************************
    // Sessão de Opções
    //********************************************

    oCoCol02     := oCoLay01:GetColPanel("C02","LMAIN")
    oCoGd01     := tLinearLayout():New(oCoCol02, LAYOUT_LINEAR_T2B ,CONTROL_ALIGN_ALLCLIENT)
    oCoGd01:setCss(cLayCSS)

    oSayProd := TSay():New( 0, 0, {|| "Produtos"}   , oCoCol02,,,,,,.T.,,,25,15)
    oBtnDwEtA := TButton():New( 0, 0, "Exp Esp Tec"   , oCoCol02,{|| fPgAcao("005", 2) }, 25,15,,,.F.,.T.,.F.,,.F.,{|| iif(len(aCoPrdDad) > 0, .T., .F. )},,.F. )
    
    oBtnDwEtA:setCss(cBtnCss)

    oCoGd01:addInLayout(oSayProd)
    oCoGd01:addInLayout(oBtnDwEtA)
    oCoGd01:addSpacer(3)


    //********************************************
    // Sessão de detalhes
    //********************************************
    oCoWin02 := oCoLay01:GetWinPanel("C03","Win02","LMAIN")
    //oCoGd01   := tGridLayout():New(oCoWin02,CONTROL_ALIGN_ALLCLIENT)
    oChart := FWChartFactory():New()
    oChart:SetOwner(oCoWin02)
    //TMP
    //fGrafico()
    

    //********************************************
    // Sessão de Países Homologados
    //********************************************
    aCoPHoCab		:= getCampos(CONSULTA_PAIS)
    aCoPHoDad		:= getDadosBrw(CONSULTA_PAIS)

    oCoWin03 := oCoLay01:GetWinPanel("C03","Win03","LMAIN")

    // Grid de consulta aos Países Homologados
    oCoBPHo := FWBrowse():New(oCoWin03)
    oCoBPHo:setColumns(aCoPHoCab)
	oCoBPHo:setDataArray()
	oCoBPHo:disableReport()
	oCoBPHo:disableConfig()
    oCoBPHo:setArray(aCoPHoDad)
    
    oCoBPHo:bGotFocus := {|| nBrwFocused := CONSULTA_PAIS}
    oCoBPHo:Activate()


return nil

/**************************************************** 
Aba de Cadastro PGA.
****************************************************/
Static function fPanel2(cDescri, nRow, nCol, nHeight, nWidth)

    oPgPnl01 := TPanel():New(nRow,nCol,'',oTTabs,,,,,,nWidth,nHeight,,.T.)
    oPgPnl01:lVisibleControl  := .F.
    
    oPgLay01 := FWLayer():new()
    oPgLay01:init(oPgPnl01,.T.)

    oPgLay01:addLine("LMAIN",100, .F.)
    oPgLay01:addCollumn("C01", 30, .F., "LMAIN")
    oPgLay01:addCollumn("C02", 04, .F., "LMAIN")
    oPgLay01:addCollumn("C03", 24, .F., "LMAIN")
    oPgLay01:addCollumn("C04", 04, .F., "LMAIN")
    oPgLay01:addCollumn("C05", 34, .F., "LMAIN")
    oPgLay01:addCollumn("C06", 04, .F., "LMAIN")

    oPgLay01:addWindow("C01", "Win01", "Registro de Produtos"  , 100,.F.,.F.,{||"" },"LMAIN",{||""})
    oPgLay01:addWindow("C02", "Win02", "Op"                    , 100,.F.,.F.,{||"" },"LMAIN",{||""})
    oPgLay01:addWindow("C03", "Win03a", "Mercados"             , 050,.F.,.F.,{||"" },"LMAIN",{||""})
    oPgLay01:addWindow("C03", "Win03b", "Países"               , 050,.F.,.F.,{||"" },"LMAIN",{||""})
    oPgLay01:addWindow("C04", "Win04a", "Op"                   , 050,.F.,.F.,{||"" },"LMAIN",{||""})
    oPgLay01:addWindow("C04", "Win04b", "Op"                   , 050,.F.,.F.,{||"" },"LMAIN",{||""})
    oPgLay01:addWindow("C05", "Win05", "Produtos Cadastrados"  , 100,.F.,.F.,{||"" },"LMAIN",{||""})
    oPgLay01:addWindow("C06", "Win06", "Op"                    , 100,.F.,.F.,{||"" },"LMAIN",{||""})

    oPgLay01:GetLinePanel("LMAIN"):SetCSS("QFrame{ background-color: #FFFFFF;}")

    oPgLay01:show()
    
    //********************************************
    // Sessão de Registro de Produtos
    //********************************************

    
    oPgWin01 := oPgLay01:GetWinPanel("C01","Win01","LMAIN")
    oPgTRMe := DbTree():New(0,0,(oPgWin01:nClientHeight / 2)-1,(oPgWin01:nClientWidth / 2)-1,oPgWin01,{|| fChgTre()},,.T.)
    
    aPgRMeCab		:= getCampos(PGA_REQMER)
    aNodes		    := getDadosTre(PGA_REQMER)
    oPgTRMe:PTSendTree(aNodes)
    oPgTRMe:EndUpdate()
    oPgTRMe:Refresh()
    oPgTRMe:SetScroll(1,.T.)
    oPgTRMe:SetScroll(2,.T.)
    oPgTRMe:lShowHint:= .T.
    
    //********************************************
    // Sessão de Opções
    //********************************************

    oPgWin02    := oPgLay01:GetWinPanel("C02","Win02","LMAIN")
    
    oFoGd01     := tLinearLayout():New(oPgWin02, LAYOUT_LINEAR_T2B ,CONTROL_ALIGN_ALLCLIENT)
    //oFoGd01:setCss(cLayCSS)
    
    //oSayRePr := TSay():New( 0, 0, {|| "R. Mercado"}   , oPgWin02,,,,,,.T.,,,25,15)
    
    oBReCons := TButton():New( 0, 0, ""     , oPgWin02,{|| fPgAcao("001", 1) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| .T.},,.F. )
    oBReCons:setCss("QPushButton{ background-image: url(rpo:BMPVISUAL_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    oBReIncl := TButton():New( 0, 0, ""  , oPgWin02  ,{|| fPgAcao("001", 3) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    oBReIncl:setCss("QPushButton{ background-image: url(rpo:BMPINCLUIR_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    oBReAlte := TButton():New( 0, 0, ""        , oPgWin02  ,{|| fPgAcao("001", 4) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    oBReAlte:setCss("QPushButton{ background-image: url(rpo:ALTERA_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    oBReExcl := TButton():New( 0, 0, ""        , oPgWin02  ,{|| fPgAcao("001", 5) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    oBReExcl:setCss("QPushButton{ background-image: url(rpo:EXCLUIR_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    oBRePGA := TButton():New( 0, 0, "PGA"        , oPgWin02  ,{|| fPgAcao("007", 1) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    oBRePGA:setCss("QPushButton{ margin-top: 0px ;  }")
    //oBRePGA:setCss("QPushButton{ background-image: url(rpo:EXCLUIR_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    
    
    oFoGd01:addInLayout(oBReCons)
    oFoGd01:addInLayout(oBREIncl)
    oFoGd01:addInLayout(oBReAlte)
    oFoGd01:addInLayout(oBReExcl)
    oFoGd01:addInLayout(oBRePGA)
    oFoGd01:addSpacer(6)
    
    //********************************************
    // Sessão de Mercados
    //********************************************
    aPgMerCab		:= getCampos(PGA_MERCADO)
    aPgMerDad		:= getDadosBrw(PGA_MERCADO)
    
    oPgWin03a := oPgLay01:GetWinPanel("C03","Win03a","LMAIN")
    oPgBMer := FWBrowse():New(oPgWin03a)
    oPgBMer:setDataArray()
    oPgBMer:disableReport()
    oPgBMer:disableConfig()
    oPgBMer:setChange( bPgBMer)
    oPgBMer:setColumns(aPgMerCab)
    oPgBMer:setArray(aPgMerDad)
    oPgBMer:bGotFocus := {|| nBrwFocused := PGA_MERCADO}
    //oPgBMer:setSeek({|oSeek, oBrowse| filtraProd(oSeek, oBrowse, aPgPrdCam)}, aSeek)
    oPgBMer:enable()
    oPgBMer:Activate()

    oPgWin04a    := oPgLay01:GetWinPanel("C04","Win04a","LMAIN")
    oFoGd02     := tLinearLayout():New(oPgWin04a, LAYOUT_LINEAR_T2B ,CONTROL_ALIGN_ALLCLIENT)
    
    oBMeCons := TButton():New( 0, 0, ""     , oPgWin04a,{|| fPgAcao("002", 1) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| .T.},,.F. )
    oBMeCons:setCss("QPushButton{ background-image: url(rpo:BMPVISUAL_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    oBMeIncl := TButton():New( 0, 0, ""  , oPgWin04a  ,{|| fPgAcao("002", 3) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    oBMeIncl:setCss("QPushButton{ background-image: url(rpo:BMPINCLUIR_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    //oBMeAlte := TButton():New( 0, 0, ""        , oPgWin04a  ,{|| fPgAcao("002", 4) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    //oBMeAlte:setCss("QPushButton{ background-image: url(rpo:ALTERA_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    oBMeExcl := TButton():New( 0, 0, ""        , oPgWin04a  ,{|| fPgAcao("002", 5) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    oBMeExcl:setCss("QPushButton{ background-image: url(rpo:EXCLUIR_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    
    oFoGd02:addInLayout(oBMeCons)
    oFoGd02:addInLayout(oBMeIncl)
    //oFoGd02:addInLayout(oBMeAlte)
    oFoGd02:addInLayout(oBMeExcl)
    oFoGd02:addSpacer(5)

    oPgWin04b    := oPgLay01:GetWinPanel("C04","Win04b","LMAIN")
    oFoGd03     := tLinearLayout():New(oPgWin04b, LAYOUT_LINEAR_T2B ,CONTROL_ALIGN_ALLCLIENT)
    
    oBPaCons := TButton():New( 0, 0, ""     , oPgWin04b,{|| fPgAcao("003", 1) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| .T.},,.F. )
    oBPaCons:setCss("QPushButton{ background-image: url(rpo:BMPVISUAL_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    oBPaIncl := TButton():New( 0, 0, ""  , oPgWin04b  ,{|| fPgAcao("003", 3) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    oBPaIncl:setCss("QPushButton{ background-image: url(rpo:BMPINCLUIR_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    //oBPaAlte := TButton():New( 0, 0, ""        , oPgWin04b  ,{|| fPgAcao("003", 4) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    //oBPaAlte:setCss("QPushButton{ background-image: url(rpo:ALTERA_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    oBPaExcl := TButton():New( 0, 0, ""        , oPgWin04b  ,{|| fPgAcao("003", 5) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    oBPaExcl:setCss("QPushButton{ background-image: url(rpo:EXCLUIR_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    
    oFoGd03:addInLayout(oBPaCons)
    oFoGd03:addInLayout(oBPaIncl)
    //oFoGd03:addInLayout(oBPaAlte)
    oFoGd03:addInLayout(oBPaExcl)
    oFoGd03:addSpacer(5)

    //********************************************
    // Sessão de Países
    //********************************************
    aPgPaiCab		:= getCampos(PGA_PAIS)
    aPgPaiDad		:= getDadosBrw(PGA_PAIS)
    
    oPgWin03b := oPgLay01:GetWinPanel("C03","Win03b","LMAIN")
    oPgBPai := FWBrowse():New(oPgWin03b)
    oPgBPai:setDataArray()
    oPgBPai:disableReport()
    oPgBPai:disableConfig()
    oPgBPai:setColumns(aPgPaiCab)
    oPgBPai:setArray(aPgPaiDad)
    oPgBPai:setChange( bPgBPai)
    oPgBPai:bGotFocus := {|| nBrwFocused := PGA_PAIS}
    //oPgBPai:setSeek({|oSeek, oBrowse| filtraProd(oSeek, oBrowse, aPgPrdCam)}, aSeek)
    oPgBPai:enable()
    oPgBPai:Activate()

    oPgWin06    := oPgLay01:GetWinPanel("C06","Win06","LMAIN")
    oFoGd04     := tLinearLayout():New(oPgWin06, LAYOUT_LINEAR_T2B ,CONTROL_ALIGN_ALLCLIENT)
    
    oBPRCons := TButton():New( 0, 0, ""     , oPgWin06,{|| fPgAcao("004", 1) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| .T.},,.F. )
    oBPrCons:setCss("QPushButton{ background-image: url(rpo:BMPVISUAL_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    oBPrIncl := TButton():New( 0, 0, ""  , oPgWin06  ,{|| fPgAcao("004", 3) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    oBPrIncl:setCss("QPushButton{ background-image: url(rpo:BMPINCLUIR_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    //oBPrAlte := TButton():New( 0, 0, ""        , oPgWin06  ,{|| fPgAcao("004", 4) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    //oBPrAlte:setCss("QPushButton{ background-image: url(rpo:ALTERA_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    //oBPrExcl := TButton():New( 0, 0, ""        , oPgWin06  ,{|| fPgAcao("004", 5) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    //oBPrExcl:setCss("QPushButton{ background-image: url(rpo:EXCLUIR_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    
    oFoGd04:addInLayout(oBPrCons)
    oFoGd04:addInLayout(oBPrIncl)
    //oFoGd04:addInLayout(oBPrAlte)
    //oFoGd04:addInLayout(oBPrExcl)
    oFoGd04:addSpacer(5)
    
    //******************************************************************************************
    // Sessão de Produtos vinculados aos requisitos da PGA. Existem uma diferença com produtos
    // homologados ou autorizados para exportação. O Registro PGA é o vínculo do produto com
    // o sistema SIF e requisito para homologar a venda do produto para um determinado país.
    // Não pode existir um produto homologado para uma país sem o registro na PGA.
    //******************************************************************************************
    //aPgPrdCab		:= getCampos(PGA_PRODUTO)
    //aPgPrdDad		:= getDadosBrw(PGA_PRODUTO)

    oPgWin05 := oPgLay01:GetWinPanel("C05","Win05","LMAIN")
    // Adiciona o Browser de produtos.
    foBrwPrd(PGA_PRODUTO)
    

return nil

Static Function foBrwPrd(nType)
    //Local aSeek := {}
    if TYPE("oPgWin05") == "O"
        if Type("oPgBPrd") == "O"
            oPgBPrd:DeActivate(.T.)
        endif

        oPgBPrd := FWBrowse():New(oPgWin05)
        
        oPgBPrd:setDataArray()
        oPgBPrd:disableReport()
        oPgBPrd:disableConfig()
        
        if nType == PGA_PRODUTO

            aPgPrdCab		:= getCampos(PGA_PRODUTO)
            aPgPrdDad		:= getDadosBrw(PGA_PRODUTO)
            oPgBPrd:setColumns(aPgPrdCab)
            oPgBPrd:setArray(aPgPrdDad)
            oPgBPrd:bGotFocus := {|| nBrwFocused := PGA_PRODUTO}
            //oPgBPrd:setSeek({|oSeek, oBrowse| filtraProd(oSeek, oBrowse, aPgPrdCam)}, aSeek)
            oPgBPrd:enable()

        elseif nType == PGA_PRD_HOMOL

            aPgPrdCab		:= getCampos(PGA_PRD_HOMOL)
            aPgPrdDad		:= getDadosBrw(PGA_PRD_HOMOL)
            oPgBPrd:addMarkColumns(bMark, bDblClk, bHeaClk)

            oPgBPrd:setColumns(aPgPrdCab)
            oPgBPrd:setArray(aPgPrdDad)
            oPgBPrd:bGotFocus := {|| nBrwFocused := PGA_PRD_HOMOL}
            
            if !(nOper == 3 .OR. nOper == 4)
                oPgBPrd:Disable()
            else
                oPgBPrd:enable()
            endif
                
        endif
        
        oPgBPrd:Activate()
    endif
    
return

Static Function fMark(oPgBPrd)

return IIf(aPgPrdDad[oPgBPrd:At(), nPgPrdCam],'LBOK','LBNO')

Static Function fDblClk(oPgBPrd)
    Local lRet      := .T.
    Local nPosPrd   := aScan(aPgPrdCam, "B1_COD")
    Local nPosPai   := aScan(aPgPaiCam, "YA_CODGI")
    Local cPais     := ""
    Local cRegMer   := ""
    Local cCargo    := ""

    IF !(oPgTRMe:isEmpty()) .and. oPgBPai:at() > 0
        
        if aPgPrdDad[oPgBPrd:At(), nPgPrdCam]
            aPgPrdDad[oPgBPrd:At(), nPgPrdCam] := .F.
        else
            aPgPrdDad[oPgBPrd:At(), nPgPrdCam] := .T.
        endif
        
        cCargo := oPgTRMe:getCargo()
        if fPosiciona(cCargo)
            if oPgTRMe:nivel() == 2
                cReqMer := Alltrim(ZE1->ZE1_REGIST)
            elseif oPgTRMe:nivel() == 3
                cReqMer := Alltrim(ZED->ZED_REGZE1)
            endif
        Endif
        
        cPais   := aPgPaiDad[ oPgBPai:at(),nPosPai]

        DbSelectArea("ZE3")
        ZE3->(DbsetOrder(1))
        if ZE3->(Dbseek(xFilial("ZE3")+cReqMer+cPais,.F.))
            fGrvZE4(aPgPrdDad[oPgBPrd:At(), nPgPrdCam], Alltrim(aPgPrdDad[oPgBPrd:At(),nPosPrd]))
        endif
    endif
return lRet

static function fGrvZE4(lMarca, cProduto)
    Local aArea := GetArea()
    Local cQuery := ""

    DbSelectArea("ZE4")
    ZE4->(DbSetOrder(1))

    IF !(oPgTRMe:isEmpty())
        cQuery  := " SELECT ISNULL(R_E_C_N_O_,0) REGISTRO "
        cQuery  += " FROM "+ RetSqlName("ZE4") +" "
        cQuery  += " WHERE D_E_L_E_T_='' AND ZE4_FILIAL='"+ xFilial("ZE4") +"' AND ZE4_ZE1REG='"+ ZE3->ZE3_ZE1REG +"' AND ZE4_ZE3SYA='"+ ZE3->ZE3_CODSYA +"' AND ZE4_CODPRD='"+ cProduto +"' "

        Tcquery cQuery ALIAS "QZE4" NEW

        IF QZE4->(!eof())

            ZE4->(DbGoto(QZE4->REGISTRO))
            
            if Reclock("ZE4",.F.)
                ZE4->ZE4_ATIVO := IIF(lMarca,'1','2')
                Msunlock("ZE4")
            endif
        ELSE
            if Reclock("ZE4",.T.)
                ZE4->ZE4_FILIAL := xfilial("ZE4")
                ZE4->ZE4_ZE1REG := ZE3->ZE3_ZE1REG
                ZE4->ZE4_ZE2MER := ZE3->ZE3_ZE2MER
                ZE4->ZE4_ZE3SYA := ZE3->ZE3_CODSYA
                ZE4->ZE4_CODPRD := cProduto
                ZE4->ZE4_ATIVO  := IIF(lMarca,'1','2')
                Msunlock("ZE4")
            endif
            
        endif

        QZE4->(DbCloseArea())
    Endif
    restArea(aArea)
Return


Static Function fHeaClk(oPgBPrd)
    Local lRet := .T.
return lRet


Static function fChgTre()
    Local cCargo := oPgTRMe:getCargo()

    //if oPgTRMe:nivel() == 2
        
        aPgMerDad		:= getDadosBrw(PGA_MERCADO)
        oPgBMer:setArray(aPgMerDad)
        oPgBMer:Refresh()

        aPgPaiDad		:= getDadosBrw(PGA_PAIS)
        oPgBPai:setArray(aPgPaiDad)
        oPgBPai:refresh()

        // Adiciona o Browser de produtos classificados.
        foBrwPrd(PGA_PRODUTO)

    //elseif oPgTRMe:nivel() == 3
        //if fPosiciona(cCargo)
            // Adiciona o Browser de produtos homologados.
            //foBrwPrd(PGA_PRD_HOMOL)
        //Endif
    //endif

return

Static function fChgTrG()
    //Local cCargo := oRmTRMe:getCargo()

    if oRmTRMe:nivel() == 2
        aHoPaiDad		:= getDadosBrw(HOM_PAIS)
        oHoBPai:setArray(aHoPaiDad)         
        oHoBPai:Refresh()

        aHoCliDad		:= getDadosBrw(HOM_CLI)
        oHoBCli:setArray(aHoCliDad)         
        oHoBCli:Refresh()

        if type("oHoBCsi") == "O"
            aHoCsiDad		:= getDadosBrw(HOM_CSI)
            oHoBCsi:setArray(aHoCsiDad)
            oHoBCsi:Refresh()
        ENDIF

        if type("oHoBExi") == "O"
            aHoExiDad		:= getDadosBrw(HOM_EXI)
            oHoBExi:setArray(aHoExiDad)
            oHoBExi:Refresh()
        Endif

    endif

return

Static Function fPgAcao(nGrp,nAcao)
    Local nNivel    := 0
    Local nPosPrd   := 0
    Local nConfirma := 1
    Local cCargo    := ""
    Local cDescri   := ""
    Local cModel    := ""
    Local cAcao     := ""
    Local lValid    := .F.
    Local lAcao     := .T.
    Local cTitulo   := ""
    Local aArea     := GetArea()
    Local oEST055P  := ADEST055P():new()
    
    if nAcao == 2
        cAcao := "Consulta"
    elseif nAcao == 3
        cAcao := "Inclusão"
    elseif nAcao == 4
        cAcao := "Alteração"
    elseif nAcao == 5
        cAcao := "Exclusão"
    endif

    // Trata as ações padrões de consulta, inclusão, alteração e exclusão.
    if !(oPgTRMe:isEmpty())
            nNivel    := oPgTRMe:nivel()
            cCargo    := oPgTRMe:getCargo()
            cDescri   := oPgTRMe:GetPrompt()
        
        // Opções da paleta do registro de produtos
        if nGrp == "001"    
            
            // Estabelecimento (ZE0)
            if nNivel == 1
                if fPosiciona(cCargo)

                    if nAcao == 1 .OR. nAcao == 2 .OR. nAcao == 4
                        cTitulo := "Estabelecimento ("+ cAcao +")"
                        cModel  := "ADEST056P"
                        lValid  := .T.
                    Elseif nAcao == 3
                        cTitulo := "Requisitos de Mercado ("+ cAcao +")"
                        cModel  := "ADEST057P"
                        lValid  := .T.
                    endif

                    if lValid .and. nAcao != 5
                        // Abre a tela de manutenção do cadastro de estabelecimento.
                        
                        if nAcao == 3
                            while msgYesNo("Deseja incluir um novo registro de produto?")
                                
                                nConfirma := FWExecView(cTitulo,cModel, nAcao, , { || .T. }, , 0, )
                                
                                if nConfirma == 0
                                    // Lista Mercados
                                    U_ADEST058P(ZE1->ZE1_REGIST)
                                    
                                    // Lista Países
                                    U_ADEST060P(ZE1->ZE1_REGIST)
                                    
                                endif
                            enddo
                        else
                            nConfirma := FWExecView(cTitulo,cModel, nAcao, , { || .T. }, , 0, )
                        endif
                    else
                        MsgAlert("Ação não permitida!")
                    ENDIF
                Endif

                if nConfirma == 0 .AND. nAcao == "5"
                    fDelNode("ZE0", nil, nil, nil, nil )
                endif

            // Requisito de Mercado (ZE1)
            elseif nNivel == 2
                
                cTitulo := "Requisitos de Mercado ("+ cAcao +")"
                cModel  := "ADEST057P"
                lValid  := .T.
                nConfirma := FWExecView(cTitulo,cModel, nAcao, , { || .T. }, , 0, )

                if nConfirma == 0 .AND. nAcao == 5
                    fDelNode("ZE1", NIL, ZE1->ZE1_REGIST, nil, nil )
                endif
            else
                MsgAlert("Inclusão autorizada somente para registro de produtos!")
            Endif
            
            if nAcao != 2 .and. nConfirma == 0
                aNodes := getDadosTre(PGA_REQMER)
                oPgTRMe:PTSendTree(aNodes)
                oPgTRMe:EndUpdate()
                oPgTRMe:Refresh()
                foBrwPrd(PGA_PRODUTO)
            endif

            RestArea(aArea)
        // Mercados
        Elseif nGrp == "002"
            
            // Mercado (ZE2)
            if nNivel == 2
                if fPosiciona(cCargo)

                    if nAcao == 3
                        // Lista Paises
                        nConfirma := U_ADEST058P(ZE1->ZE1_REGIST)
                    // Alteração ou exclusão
                    elseif nAcao == 4
                        MsgInfo("Ação não permitida para esse tipo de registro!")
                    Else
                        
                        DbSelectArea("ZE2")
                        ZE2->(DbSetOrder(1))
                        
                        if ZE2->(Dbseek(xFilial("ZE2")+alltrim(ZE1->ZE1_REGIST)+aPgMerDad[oPgBMer:at(),aScan(aPgMerCam,"ZE2_MERCAD")],.F.) )
                            cTitulo := "Mercado ("+ cAcao +")"
                            cModel  := "ADEST059P"

                            nConfirma := FWExecView(cTitulo,cModel, nAcao, , { || .T. }, , 60, )
                            IF nConfirma == 0 .and. nAcao == 5
                                fDelNode("ZE2", NIL, ze1->ZE1_REGIST, ze2->ZE2_MERCAD, nil)
                            endif
                        endif    
                    endif

                endif
            else
                MsgAlert("Selecione um registro de produto válido!")
            endif

            if (nAcao == 3 .or. nAcao == 5) .and. nConfirma == 0 
                aPgMerDad		:= getDadosBrw(PGA_MERCADO)
                oPgBMer:setArray(aPgMerDad)
                oPgBMer:Refresh()
            endif
            
        // Países
        Elseif nGrp == "003"

            // Países (ZE3)
            if nNivel == 2
                if fPosiciona(cCargo)
        
                    if nAcao == 3
                        // Lista Paises
                        nConfirma := U_ADEST060P(ZE1->ZE1_REGIST)
                    // Alteração ou exclusão
                    elseif nAcao == 4
                        MsgInfo("Ação não permitida para esse tipo de registro!")
                    Else
                        
                        DbSelectArea("ZE3")
                        ZE3->(DbSetOrder(1))
                        
                        if ZE3->(Dbseek(xFilial("ZE3")+alltrim(ZE1->ZE1_REGIST)+aPgPaiDad[oPgBPai:at(),aScan(aPgPaiCam,"YA_CODGI")], .F.))

                            cTitulo := "Mercado ("+ cAcao +")"
                            cModel  := "ADEST061P"

                            nConfirma := FWExecView(cTitulo,cModel, nAcao, , { || .T. }, , 60, )
                            IF nConfirma == 0 .and. nAcao == 5 
                                fDelNode("ZE3", NIL, ZE3->ZE3_ZE1REG, ZE3->ZE3_ZE2MER, ZE3->ZE3_CODSYA )
                            endif
                            
                        endif

                    endif
                
                endif

            else
                MsgAlert("Selecione um registro de produto para o vínculo de um país!")
            endif

            if (nAcao == 3 .OR. nAcao == 5) .and. nConfirma == 0
                aPgPaiDad		:= getDadosBrw(PGA_PAIS)
                oPgBPai:setArray(aPgPaiDad)
                oPgBPai:refresh()
                
                foBrwPrd(PGA_PRD_HOMOL)
            endif            
            

        // Inclusão de Produtos
        Elseif nGrp == "004"

            if nNivel == 3
                if fPosiciona(cCargo)

                    if nAcao == 3
                        //nConfirma := U_ADEST062P(ZE1->ZE1_REGIST)
                        nConfirma := U_ADEST062P(ZED->ZED_REGZE1, ZED->ZED_CODCAT)
                        /*
                        if nConfirma == 0
                            aPgPrdDad  := getDadosBrw(PGA_PRODUTO)
                            oPgBPrd:setArray(aPgPrdDad)
                            oPgBPrd:refresh()
                        endif
                        */
                        foBrwPrd(PGA_PRODUTO)

                        nConfirma := 1
                    endif

                endif
            else
                MsgAlert("Para adição de novos produtos selecione uma categoria de produtos!")
            endif

        // Opção para upload e download dos arquivo de Especificações Técnicas.
        Elseif nGrp == "005"
            
            nPosPrd := aScan(aPgPrdCam, "B1_COD")
            
            if nPosPrd != 0
                cProduto    := Alltrim(aPgPrdDad[oPgBPrd:At()][nPosPrd])

                //Donwload do arquivo.
                if nAcao == 1
                    oEST055P:setEspTec(cProduto)

                //Upload dos arquivos.
                elseif nAcao == 2
                    oEST055P:getEspTec(cProduto)
                endif
            else
                MsgInfo("Ação não permitida!")
            endif
        // Opção para upload e download dos arquivo de Especificações Técnicas.
        Elseif nGrp == "006"
            nPosPrd := aScan(aCoPrdCam, "B1_COD")
            if nPosPrd != 0
                cProduto    := Alltrim(aCoPrdDad[oCoBPrd:At()][nPosPrd])
                oEST055P:getEspTec(cProduto)
                
            else
                MsgInfo("Ação não permitida!")
            endif
        // Integração PGA.
        Elseif nGrp == "007"
            fIntPGA()
        // Opções de países/Requisito de Mercado
        Elseif nGrp == "008"

            if nAcao == 1
                cTitulo := "Países/Requisitos de Mercado ("+ cAcao +")"
                cModel  := "ADEST067P"
                lValid  := .T.
                
                DbSelectArea("SYA")
                SYA->(DbsetOrder(1))

                if Len(aHoPaiDad) > 0
                    if (SYA->(Dbseek(xFilial("SYA")+ALLTRIM(aHoPaiDad[oHoBPai:Nat][01])) ))
                        if SYA->YA_CODGI == ALLTRIM( aHoPaiDad[oHoBPai:Nat][01])
                            nConfirma := FWExecView(cTitulo,cModel, nAcao, , { || .T. }, , 0, )
                        endif
                    ENDIF
                else
                    MSGSTOP( "Não existem registros para visualização", "Em branco" )
                endif

            // Inclusão
            Elseif nAcao == 3
                if !(oRmTRMe:isEmpty())
                    if oRmTRMe:nivel() == 2
                        U_ADEST067P(Alltrim(oRmTRMe:getCargo()))
                    else
                        MSGSTOP( "Selecione um requisito de mercado para a inclusão de um novo país." , "Requisito de Mercado" )
                    endif
                
                else
                    MSGSTOP( "Não existe requisitos de mercado cadastrado." , "Incorreto" )
                endif

            // Exclusão
            Elseif nAcao == 5
                DbSelectArea("SYA")
                SYA->(DbsetOrder(1))

                if Len(aHoPaiDad) > 0
                    If MSGYESNO("Deseja excluir o país "+ ALLTRIM(aHoPaiDad[oHoBPai:Nat][01])+"-"+ALLTRIM(aHoPaiDad[oHoBPai:Nat][02])+"?" )
                        if (SYA->(Dbseek(xFilial("SYA")+ALLTRIM(aHoPaiDad[oHoBPai:Nat][01])) ))
                            if SYA->YA_CODGI == ALLTRIM( aHoPaiDad[oHoBPai:Nat][01])
                                Reclock("SYA",.F.)
                                    SYA->YA_XGRPINS := ""
                                Msunlock("SYA")
                            ENDIF
                        endif
                    endif
                endif    
            endif

            if nAcao == 3 .or. nAcao == 5
                aHoPaiDad		:= getDadosBrw(HOM_PAIS)
                oHoBPai:setArray(aHoPaiDad)         
                oHoBPai:Refresh()
            endif

        // Opções de Clientes/Requisito de Mercado
        Elseif nGrp == "009"
            
            if nAcao == 1
                cTitulo := "Cliente/Requisitos de Mercado ("+ cAcao +")"
                cModel  := "ADEST068P"
                lValid  := .T.
                
                DbSelectArea("SA1")
                SA1->(DbsetOrder(1))

                if Len(aHoCliDad) > 0
                    if (SA1->(Dbseek(xFilial("SA1")+ALLTRIM(aHoCliDad[oHoBPai:Nat][02])+ALLTRIM(aHoCliDad[oHoBPai:Nat][03]) ) ) )
                        if SA1->A1_COD == ALLTRIM( aHoCliDad[oHoBCli:Nat][02]) .and. SA1->A1_LOJA == ALLTRIM( aHoCliDad[oHoBCli:Nat][03])
                            nConfirma := FWExecView(cTitulo,cModel, nAcao, , { || .T. }, , 0, )
                        endif
                    ENDIF
                else
                    MSGSTOP( "Não existem registros para visualização", "Em branco" )
                endif

            // Inclusão
            Elseif nAcao == 3
                if !(oRmTRMe:isEmpty())
                    if oRmTRMe:nivel() == 2
                        U_ADEST068P(Alltrim(oRmTRMe:getCargo()))
                        nConfirma := 0
                    else
                        MSGSTOP( "Selecione um requisito de mercado para a inclusão de um novo cliente." , "Requisito de Mercado" )
                    endif
                
                else
                    MSGSTOP( "Não existe requisitos de mercado cadastrado." , "Incorreto" )
                endif

            // Exclusão
            Elseif nAcao == 5
                DbSelectArea("SA1")
                SA1->(DbsetOrder(1))

                if Len(aHoCliDad) > 0
                    If MSGYESNO(" Confirma a exclusão do registro? ")
                        if (SA1->(Dbseek(xFilial("SA1")+ALLTRIM(aHoCliDad[oHoBCli:Nat][02])+ALLTRIM(aHoCliDad[oHoBCli:Nat][03]) ) ))
                            if SA1->A1_COD == ALLTRIM( aHoCliDad[oHoBCli:Nat][02]) .and. SA1->A1_LOJA == ALLTRIM( aHoCliDad[oHoBCli:Nat][03])
                                Reclock("SA1",.F.)
                                    SA1->A1_XGRPINS := ""
                                Msunlock("SA1")

                                nConfirma := 0
                            ENDIF
                        endif
                    endif
                endif    
            endif

            if (nAcao == 3 .or. nAcao == 5) .and. nConfirma == 0
                aHoCliDad		:= getDadosBrw(HOM_CLI)
                oHoBCli:setArray(aHoCliDad)
                oHoBCli:Refresh()
            endif

        // Opções de Certificados CSI
        Elseif nGrp == "010"
            
            // Visualização  ou exclusão.
            if nAcao == 1 .OR. nAcao == 5
                if !(oRmTRMe:isEmpty())
                    cTitulo := "Modelo CSI vinculados ("+ cAcao +")"
                    cModel  := "ADEST069P"
                    lValid  := .T.
                    
                    DbSelectArea("ZEA")
                    ZEA->(DbsetOrder(1))

                    if nAcao == 5
                        lAcao := MSGYESNO(" Confirma a exclusão do registro? ")
                    else
                        lAcao := .T.
                    endif

                    if Len(aHoCsiDad) > 0
                        if lAcao
                            if (ZEA->(Dbseek(xFilial("ZEA")+Alltrim(oRmTRMe:getCargo())+ALLTRIM(aHoCsiDad[oHoBCsi:Nat][01]) ) ) )
                                if ZEA->ZEA_CODZCO == Alltrim(oRmTRMe:getCargo()) .and. ZEA->ZEA_COD == ALLTRIM(aHoCsiDad[oHoBCsi:Nat][01])
                                    nConfirma := FWExecView(cTitulo,cModel, nAcao, , { || .T. }, , 0, )
                                endif
                            ENDIF
                        endif
                    else
                        MSGSTOP( "Não existem registros para visualização", "Em branco" )
                    endif
                endif
            // Inclusão
            Elseif nAcao == 3
                if !(oRmTRMe:isEmpty())
                    if oRmTRMe:nivel() == 2
                        U_ADEST069P(Alltrim(oRmTRMe:getCargo()))
                        nConfirma := 0
                    else
                        MSGSTOP( "Selecione um requisito de mercado para a inclusão de um novo Modelo CSI." , "Requisito de Mercado" )
                    endif
                
                else
                    MSGSTOP( "Não existe requisitos de mercado cadastrado." , "Incorreto" )
                endif
                    
            endif

            if (nAcao == 3 .or. nAcao == 5) .and. nConfirma == 0
                aHoCsiDad		:= getDadosBrw(HOM_CSI)
                oHoBCsi:setArray(aHoCsiDad)
                oHoBCsi:Refresh()
            endif
        // Opções de Requisitos de Mercado
        Elseif nGrp == "011"
           // Visualização  ou exclusão.
            if nAcao == 1 .OR. nAcao == 5
                if !(oRmTRMe:isEmpty())
                    cTitulo := "Exigências de Mercado vinculados ("+ cAcao +")"
                    cModel  := "ADEST070P"
                    lValid  := .T.
                    
                    DbSelectArea("ZEZ")
                    ZEZ->(DbsetOrder(1))

                    if nAcao == 5
                        lAcao := MSGYESNO(" Confirma a exclusão do registro? ")
                    else
                        lAcao := .T.
                    endif

                    if Len(aHoExiDad) > 0
                        if lAcao
                            if (ZEZ->(Dbseek(xFilial("ZEZ")+Alltrim(oRmTRMe:getCargo())+ALLTRIM(aHoExiDad[oHoBExi:Nat][01]) ) ) )
                                if ZEZ->ZEZ_CODZCO == Alltrim(oRmTRMe:getCargo()) .and. ZEZ->ZEZ_COD == ALLTRIM(aHoExiDad[oHoBExi:Nat][01])
                                    nConfirma := FWExecView(cTitulo,cModel, nAcao, , { || .T. }, , 0, )
                                endif
                            ENDIF
                        endif
                    else
                        MSGSTOP( "Não existem registros para visualização", "Em branco" )
                    endif
                endif
            // Inclusão
            Elseif nAcao == 3
                if !(oRmTRMe:isEmpty())
                    if oRmTRMe:nivel() == 2
                        U_ADEST070P(Alltrim(oRmTRMe:getCargo()))
                        nConfirma := 0
                    else
                        MSGSTOP( "Selecione um requisito de mercado para a inclusão de um novo Modelo CSI." , "Requisito de Mercado" )
                    endif
                
                else
                    MSGSTOP( "Não existe requisitos de mercado cadastrado." , "Incorreto" )
                endif
                    
            endif

            if (nAcao == 3 .or. nAcao == 5) .and. nConfirma == 0
                aHoExiDad		:= getDadosBrw(HOM_EXI)
                oHoBExi:setArray(aHoExiDad)
                oHoBExi:Refresh()
            endif
        endif
    Else
        Msginfo("Não existem registros cadastrados!")
    Endif
    
Return

Static function fIntPGA()
    Local lExePGA       := .F.
    Private cDirSer     := Alltrim(SUPERGETMV("MV_#EST055A",,"\adoro_automacao\PGA-Produto.zip"))
    Private aDirSer     := Separa(cDirSer,"\")
    Private cArqZip     := iif(Len(aDirSer) < 2, "", Alltrim(aDirSer[Len(aDirSer)]) )
    Private cDirLoc     := Alltrim(SUPERGETMV("MV_#EST055B",,"c:\adoro_automacao\"))
    Private cExcPGA     := Alltrim(SUPERGETMV("MV_#EST055C",,"c:\adoro_automacao\PGA-Produto\PGA.exe"))
    
    if !Empty(cDirLoc) .and. !Empty(cExcPGA) .and. !Empty(cDirSer)

        if file(cExcPGA)
            lExePGA := .T.
        else
            if file(cDirSer)
                MsAguarde({|| fTraZIP() },"Aguarde...","Transferindo e instalando o aplicativo! Aguarde...")
                if File(cExcPGA)
                    lExePGA := .T.
                else
                    MsgAlert("[ADEST055-04]-Não foi possível instalar o aplicativo de integração!")
                endif
            else
                MsgAlert("[ADEST055-02]-Não executáveis disponíveis para ser instalado!")
            endif
        
        endif
        
        if lExePGA
            MsAguarde({|| ShellExecute( "Open", cExcPGA, "", "c:\", 1 ) },"Aguarde...","Executando a integração PGA! Aguarde...")
        else
            MsgAlert("[ADEST055-03]-Não foi possível executar o programa de integração!")
        endif
    else
        MsgAlert("[ADEST055-01]-Programa de integração PGA configurado incorretamente!"+Chr(13)+chr(10)+"Entre em contato com o Depto. de TI!")
    endif
return

Static Function fTraZIP()
    fMakeDir(cDirLoc)
    CPYS2T(cDirSer, cDirLoc)
    FUnzip(cDirLoc+cArqZip,cDirLoc)
    
return

Static Function fPosiciona(cChave)
    Local aChave    := Separa(cChave,"_")
    Local cAlias    := aChave[01]
    Local nChave    := Val(aChave[02])

    DbselectArea(cAlias)
    
    (cAlias)->(Dbgoto(nChave))

return (nChave == (cAlias)->(Recno()))

/**************************************************** 
Aba de Cadastro Homologação de Clientes.
****************************************************/
Static function fPanel3(cDescri, nRow, nCol, nHeight, nWidth)
    oHoPnl01 := TPanel():New(nRow,nCol,'',oTTabs,,,,,,nWidth,nHeight,,.T.)
    oHoPnl01:lVisibleControl  := .F.
    
    oHoLay01 := FWLayer():new()
    oHoLay01:init(oHoPnl01,.T.)

    oHoLay01 := FWLayer():new()
    oHoLay01:init(oHoPnl01,.T.)

    oHoLay01:addLine("LMAIN",100, .F.)
    oHoLay01:addCollumn("C01", 20, .F., "LMAIN")
    //oHoLay01:addCollumn("C02", 04, .F., "LMAIN")
    oHoLay01:addCollumn("C03", 28, .F., "LMAIN")
    oHoLay01:addCollumn("C04", 04, .F., "LMAIN")
    oHoLay01:addCollumn("C05", 44, .F., "LMAIN")
    oHoLay01:addCollumn("C06", 04, .F., "LMAIN")

    // U_ADEST055P()
    oHoLay01:addWindow("C01", "Win01", "Grupos de Inspeção"     , 100,.F.,.F.,{||"" },"LMAIN",{||""})
    //oHoLay01:addWindow("C02", "Win02", "Op"                     , 100,.F.,.F.,{||"" },"LMAIN",{||""})
    oHoLay01:addWindow("C03", "Win03", "Países Vinculados"      , 050,.F.,.F.,{||"" },"LMAIN",{||""})
    oHoLay01:addWindow("C03", "Win04", "Clientes Vinculados"    , 050,.F.,.F.,{||"" },"LMAIN",{||""})
    oHoLay01:addWindow("C04", "Win05", "Op"                     , 050,.F.,.F.,{||"" },"LMAIN",{||""})
    oHoLay01:addWindow("C04", "Win06", "Op"                     , 050,.F.,.F.,{||"" },"LMAIN",{||""})
    oHoLay01:addWindow("C05", "Win07", "Modelos CSI"            , 040,.F.,.F.,{||"" },"LMAIN",{||""})
    oHoLay01:addWindow("C05", "Win08", "Exigências p/ País"     , 060,.F.,.F.,{||"" },"LMAIN",{||""})
    oHoLay01:addWindow("C06", "Win09", "Op"                     , 040,.F.,.F.,{||"" },"LMAIN",{||""})
    oHoLay01:addWindow("C06", "Win10", "Op"                     , 060,.F.,.F.,{||"" },"LMAIN",{||""})

    oHoLay01:GetLinePanel("LMAIN"):SetCSS("QFrame{ background-color: #FFFFFF;}")

    oHoLay01:show()

    //********************************************
    // Sessão dos Botões Grupos de Inspeção
    //********************************************
    /*
    oHoWin02    := oHoLay01:GetWinPanel("C02","Win02","LMAIN")
    oHoGd02     := tLinearLayout():New(oHoWin02, LAYOUT_LINEAR_T2B ,CONTROL_ALIGN_ALLCLIENT)

    oBGrpCons := TButton():New( 0, 0, ""        , oHoWin02,{|| fPgAcao("001", 1) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| .T.},,.F. )
    oBGrpCons:setCss("QPushButton{ background-image: url(rpo:BMPVISUAL_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    oBGrpIncl := TButton():New( 0, 0, ""        , oHoWin02  ,{|| fPgAcao("001", 3) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    oBGrpIncl:setCss("QPushButton{ background-image: url(rpo:BMPINCLUIR_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    oBGrpAlte := TButton():New( 0, 0, ""        , oHoWin02  ,{|| fPgAcao("001", 4) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    oBGrpAlte:setCss("QPushButton{ background-image: url(rpo:ALTERA_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    oBGrpExcl := TButton():New( 0, 0, ""        , oHoWin02  ,{|| fPgAcao("001", 5) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    oBGrpExcl:setCss("QPushButton{ background-image: url(rpo:EXCLUIR_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    
    oHoGd02:addInLayout(oBGrpCons)
    oHoGd02:addInLayout(oBGrpIncl)
    oHoGd02:addInLayout(oBGrpAlte)
    oHoGd02:addInLayout(oBGrpExcl)
    oHoGd02:addSpacer(5)
    */

    //********************************************
    // Sessão dos Botões Países
    //********************************************
    oHoWin05    := oHoLay01:GetWinPanel("C04","Win05","LMAIN")
    oHoGd05     := tLinearLayout():New(oHoWin05, LAYOUT_LINEAR_T2B ,CONTROL_ALIGN_ALLCLIENT)

    oBPaiCons := TButton():New( 0, 0, ""        , oHoWin05,{|| fPgAcao("008", 1) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| .T.},,.F. )
    oBPaiCons:setCss("QPushButton{ background-image: url(rpo:BMPVISUAL_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    oBPaiIncl := TButton():New( 0, 0, ""        , oHoWin05  ,{|| fPgAcao("008", 3) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    oBPaiIncl:setCss("QPushButton{ background-image: url(rpo:BMPINCLUIR_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    oBPaiExcl := TButton():New( 0, 0, ""        , oHoWin05  ,{|| fPgAcao("008", 5) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    oBPaiExcl:setCss("QPushButton{ background-image: url(rpo:EXCLUIR_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    
    oHoGd05:addInLayout(oBPaiCons)
    oHoGd05:addInLayout(oBPaiIncl)
    oHoGd05:addInLayout(oBPaiExcl)
    oHoGd05:addSpacer(4)

    //********************************************
    // Sessão dos Botões Clientes
    //********************************************
    oHoWin06    := oHoLay01:GetWinPanel("C04","Win06","LMAIN")
    oHoGd06     := tLinearLayout():New(oHoWin06, LAYOUT_LINEAR_T2B ,CONTROL_ALIGN_ALLCLIENT)

    oBCliCons := TButton():New( 0, 0, ""        , oHoWin06,{|| fPgAcao("009", 1) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| .T.},,.F. )
    oBCliCons:setCss("QPushButton{ background-image: url(rpo:BMPVISUAL_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    oBCliIncl := TButton():New( 0, 0, ""        , oHoWin06  ,{|| fPgAcao("009", 3) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    oBCliIncl:setCss("QPushButton{ background-image: url(rpo:BMPINCLUIR_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    oBCliExcl := TButton():New( 0, 0, ""        , oHoWin06  ,{|| fPgAcao("009", 5) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    oBCliExcl:setCss("QPushButton{ background-image: url(rpo:EXCLUIR_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    
    oHoGd06:addInLayout(oBCliCons)
    oHoGd06:addInLayout(oBCliIncl)
    oHoGd06:addInLayout(oBCliExcl)
    oHoGd06:addSpacer(4)

    //********************************************
    // Sessão dos Botões CSI
    //********************************************
    oHoWin09    := oHoLay01:GetWinPanel("C06","Win09","LMAIN")
    oHoGd09     := tLinearLayout():New(oHoWin09, LAYOUT_LINEAR_T2B ,CONTROL_ALIGN_ALLCLIENT)

    oBCsiCons := TButton():New( 0, 0, ""        , oHoWin09,{|| fPgAcao("010", 1) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| .T.},,.F. )
    oBCsiCons:setCss("QPushButton{ background-image: url(rpo:BMPVISUAL_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    oBCsiIncl := TButton():New( 0, 0, ""        , oHoWin09  ,{|| fPgAcao("010", 3) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    oBCsiIncl:setCss("QPushButton{ background-image: url(rpo:BMPINCLUIR_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    oBCsiExcl := TButton():New( 0, 0, ""        , oHoWin09  ,{|| fPgAcao("010", 5) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    oBCsiExcl:setCss("QPushButton{ background-image: url(rpo:EXCLUIR_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    
    oHoGd09:addInLayout(oBCsiCons)
    oHoGd09:addInLayout(oBCsiIncl)
    oHoGd09:addInLayout(oBCsiExcl)
    oHoGd09:addSpacer(4)

    //********************************************
    // Sessão dos Botões Exigência do Mercado
    //********************************************
    oHoWin10    := oHoLay01:GetWinPanel("C06","Win10","LMAIN")
    oHoGd10     := tLinearLayout():New(oHoWin10, LAYOUT_LINEAR_T2B ,CONTROL_ALIGN_ALLCLIENT)

    oBExiCons := TButton():New( 0, 0, ""        , oHoWin10,{|| fPgAcao("011", 1) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| .T.},,.F. )
    oBExiCons:setCss("QPushButton{ background-image: url(rpo:BMPVISUAL_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    oBExiIncl := TButton():New( 0, 0, ""        , oHoWin10  ,{|| fPgAcao("011", 3) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    oBExiIncl:setCss("QPushButton{ background-image: url(rpo:BMPINCLUIR_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    oBExiExcl := TButton():New( 0, 0, ""        , oHoWin10  ,{|| fPgAcao("011", 5) }, 10,15,,,.F.,.T.,.F.,,.F.,{|| nOper == 3 .OR. nOper == 4 },,.F. )
    oBExiExcl:setCss("QPushButton{ background-image: url(rpo:EXCLUIR_MDI.PNG); background-repeat: none; border: 0px solid ; margin: 0px ;background-position: center    }")
    
    oHoGd10:addInLayout(oBExiCons)
    oHoGd10:addInLayout(oBExiIncl)
    oHoGd10:addInLayout(oBExiExcl)
    oHoGd10:addSpacer(4)

    //********************************************
    // Sessão de Grupos de Inspeção
    //********************************************
    //aHoPaiCab		:= getCampos(HOM_PAIS)
    //aHoPaiDad		:= getDadosBrw(HOM_PAIS)

    oHoWin01 := oHoLay01:GetWinPanel("C01","Win01","LMAIN")
    oRmTRMe := DbTree():New(0,0,(oHoWin01:nClientHeight / 2)-1,(oHoWin01:nClientWidth / 2)-1,oHoWin01,{|| fChgTrG()},,.T.)
    
    //aPgRMeCab		:= getCampos(GRI_REQMER)
    aNodes		    := getDadosTre(GRI_REQMER)
    oRmTRMe:PTSendTree(aNodes)
    oRmTRMe:EndUpdate()
    oRmTRMe:Refresh()
    oRmTRMe:SetScroll(1,.T.)
    oRmTRMe:SetScroll(2,.T.)
    oRmTRMe:lShowHint:= .T.

    //********************************************
    // Sessão de Países
    //********************************************
    aHoPaiCab		:= getCampos(HOM_PAIS)
    aHoPaiDad		:= getDadosBrw(HOM_PAIS)

    oHoWin03 := oHoLay01:GetWinPanel("C03","Win03","LMAIN")

    oHoBPai := FWBrowse():New(oHoWin03)
    oHoBPai:setColumns(aHoPaiCab)
    //oHoBPai:setChange(bHoBPai)
	oHoBPai:setDataArray()
	oHoBPai:disableReport()
	oHoBPai:disableConfig()
    oHoBPai:setArray(aHoPaiDad)
    
    oHoBPai:bGotFocus := {|| nBrwFocused := 9}
    oHoBPai:Activate()

    //********************************************
    // Sessão de Clientes
    //********************************************
    oHoWin04 := oHoLay01:GetWinPanel("C03","Win04","LMAIN")

    aHoCliCab		:= getCampos(HOM_CLI)
    aHoCliDad		:= getDadosBrw(HOM_CLI)

    oHoBCli := FWBrowse():New(oHoWin04)
    oHoBCli:setColumns(aHoCliCab)
	oHoBCli:setDataArray()
	oHoBCli:disableReport()
	oHoBCli:disableConfig()
    oHoBCli:setArray(aHoCliDad)
    
    oHoBCli:bGotFocus := {|| nBrwFocused := 10}
    oHoBCli:Activate()

    //********************************************
    // Sessão Modelo CSI
    //********************************************
    oHoWin07 := oHoLay01:GetWinPanel("C05","Win07","LMAIN")
    
    aHoCsiCab		:= getCampos(HOM_CSI)
    aHoCsiDad		:= getDadosBrw(HOM_CSI)

    oHoBCsi := FWBrowse():New(oHoWin07)
    oHoBCsi:setColumns(aHoCsiCab)
	oHoBCsi:setDataArray()
	oHoBCsi:disableReport()
	oHoBCsi:disableConfig()
    oHoBCsi:setArray(aHoCsiDad)
    
    oHoBCsi:bGotFocus := {|| nBrwFocused := 11}
    oHoBCsi:Activate()

    //********************************************
    // Sessão Exigências por país
    //********************************************
    oHoWin08 := oHoLay01:GetWinPanel("C05","Win08","LMAIN")
    
    aHoExiCab		:= getCampos(HOM_EXI)
    aHoExiDad		:= getDadosBrw(HOM_EXI)

    oHoBExi := FWBrowse():New(oHoWin08)
    oHoBExi:setColumns(aHoExiCab)
	oHoBExi:setDataArray()
	oHoBExi:disableReport()
	oHoBExi:disableConfig()
    oHoBExi:setArray(aHoExiDad)
    
    oHoBExi:bGotFocus := {|| nBrwFocused := 12}
    oHoBExi:Activate()

return nil



/* Layoutdet - Carrega os componentes de botões. */
Static function layfooter()
    
    //Tela de talhada com os grids e folders.
    olayer:addLine("L03",10, .F.)
    
    oFoLin1     := oLayer:GetLinePanel("L03")
    oFoGd01     := tLinearLayout():New(oFoLin1, LAYOUT_LINEAR_L2R ,CONTROL_ALIGN_ALLCLIENT)
    oFoGd01:setCss(cLayCSS)

    oBtnCanc := TButton():New( 0, 0, "Finaliza", oFoGd01,{|| oWnd:End() }, 70,15,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnConf := TButton():New( 0, 0, "Confirma", oFoGd01,{|| oWnd:End() }, 70,15,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnCanc:setCss(cBtnCss)
    oBtnConf:setCss(cBtnCss)

    oFoGd01:addSpacer(5)
    oFoGd01:addInLayout(oBtnCanc)
    oFoGd01:addInLayout(oBtnConf)



return nil

/* Layoutcab - Carrega os componentes de tela do cabeçalho. */
Static Function layHeader()
    
    //Local aZE0 := fgetSX3(ZE0_CAMPO_VIEW)
    
    fAtualCab()
    
    //Cabeçalho com os campos do estabelecimento.
    oLayer:addLine("L01",20, .F.)
    oLayer:addCollumn("L01C01", 100, .F., "L01")

    oLayer:addWindow("L01C01", "Win01", "Estabelecimento"		, 100,.F.,.F.,{||"" },"L01",{||""})

    //oLayer:GetLinePanel("L01"):SetCSS("QFrame{ background-color: #C2C7CB;}")
    oLayer:GetLinePanel("L01"):SetCSS("QFrame{ background-color: #FFFFFF;}")

	oLayer:GetWinPanel("L01C01","Win01","L01"):SetCSS("QFrame{font-size: 12px;}")
	

    //oTop := oLayer:getLinePanel("L01")
    oTop := oLayer:getWinPanel("L01C01","Win01","L01")
    oSize := FWDefSize():New(.F.)
	
    oSize:AddObject( "OBJ01"	, 50, 50, .T., .T. )
    oSize:AddObject( "OBJ02"	, 50, 50, .T., .T. )
    oSize:AddObject( "OBJ03"	, 50, 50, .T., .T. )
    oSize:AddObject( "OBJ04"	, 50, 50, .T., .T. )
    
	oSize:lLateral	:= .T. // Elementos um do lado do outro
	oSize:lProp		:= .T. // Cálculo dos botões proporcionais
	oSize:SetWindowSize({000, 000, oTop:nHeight, oTop:nWidth})
	oSize:Process() 		// executa os calculos

    aRet := fgetSX3("ZE0_REGIST")
	oZE0REGIST  := TGet():New(002,oSize:GetDimension("OBJ01","COLINI")+2,{|u|If(PCount() == 0,cZE0REGIST,cZE0REGIST := u)},oTop,oSize:GetDimension("OBJ01","XSIZE"),010,alltrim(aRet[01][03]),,0,16777215,,.F.,,.T.,,.F.,{|| nOper == 3 },.F.,.F.,,.F.,.F. ,,"cZE0REGIST",,,,.T.,,,aRet[01][01],1) 
	if !Empty(aRet[01][09])
        oZE0REGIST:cF3 := Alltrim(aRet[01][09])
    endif
    oZE0REGIST:lVisibleControl := .T.

    aRet := fgetSX3("ZE0_CNPJ")
    oZE0CNPJ  := TGet():New(002,oSize:GetDimension("OBJ02","COLINI"),{|u|If(PCount() == 0,cZE0CNPJ,cZE0CNPJ := u)},oTop,oSize:GetDimension("OBJ02","XSIZE"), 010,alltrim(aRet[01][03]),,0,16777215,,.F.,,.T.,,.F.,{|| IIF( nOper == 3 ,.T., .F.) },.F.,.F.,,.F.,.F. ,,"cZE0CNPJ",,,,.T.,,,aRet[01][01],1) 
	if !Empty(aRet[01][09])
        oZE0CNPJ:cF3 := Alltrim(aRet[01][09])
    endif
    oZE0CNPJ:lVisibleControl := .T.
    
    aRet := fgetSX3("ZE0_RAZAO")
    oZE0RAZAO  := TGet():New(002,oSize:GetDimension("OBJ03","COLINI"),{|u|If(PCount() == 0,cZE0RAZAO,cZE0RAZAO := u)},oTop,oSize:GetDimension("OBJ03","XSIZE"), 010,alltrim(aRet[01][03]),,0,16777215,,.F.,,.T.,,.F.,{|| IIF( nOper == 3 ,.T., .F.) },.F.,.F.,,.F.,.F. ,,"cZE0RAZAO",,,,.T.,,,aRet[01][01],1) 
	if !Empty(aRet[01][09])
        oZE0RAZAO:cF3 := Alltrim(aRet[01][09])
    endif
    oZE0RAZAO:lVisibleControl := .T.

    aRet := fgetSX3("ZE0_AMBINS")
    aZE0AMBINS  := Separa(aRet[01][11],";")
    oZE0AMBINS 	:= tComboBox():New(002,oSize:GetDimension("OBJ04","COLINI"),{|u|if(PCount()>0,cZE0AMBINS:=u,cZE0AMBINS)},aZE0AMBINS,oSize:GetDimension("OBJ04","XSIZE"),013,oTop,,{|| nOper == 3 },,,,.T.,,,,{|| .F.},,,,,'nZE0AMBINS', aRet[01][01],1)
	oZE0AMBINS:lVisibleControl := .T.

return nil

/* Carrega os campos padrões do cabeçalho. */
Static Function fAtualCab()

    IF nOper == 3
        cZE0REGIST  := criavar("ZE0_REGIST")
        cZE0CNPJ    := criavar("ZE0_CNPJ")
        cZE0RAZAO   := criavar("ZE0_RAZAO")
        cZE0AMBINS  := criavar("ZE0_AMBINS")
    else
        cZE0REGIST  := ZE0->ZE0_REGIST
        cZE0CNPJ    := ZE0->ZE0_CNPJ
        cZE0RAZAO   := ZE0->ZE0_RAZAO
        cZE0AMBINS  := ZE0->ZE0_AMBINS
    endif
return nil

/* Busca as informações do cabeçalho. */
Static Function fgetSX3(cCampos)
    Local aRet      := {}
    Local cCampo    := ""
    Local nX        := 0
    Local nCampos   := 0
    Local aCampos   := Separa(cCampos,",")


    dbselectarea("SX3")
    sx3->(dbsetorder(2)) // Campo
    nCampos := len(aCampos)
    
    for nx := 1 to nCampos

        cCampo := Alltrim(aCampos[nX])
        cUsado := GetSX3Cache(cCampo, "X3_USADO")
        
        if !Empty(GetSX3Cache(cCampo, "X3_CAMPO"))
            aadd(aRet,{ alltrim(GetSX3Cache(cCampo, "X3_TITULO")),;
            GetSX3Cache(cCampo, "X3_CAMPO")	,;
            GetSX3Cache(cCampo, "X3_PICTURE"),;
            GetSX3Cache(cCampo, "X3_TAMANHO"),;
            GetSX3Cache(cCampo, "X3_DECIMAL"),;
            "" /*X3_VALID*/ ,;
            GetSX3Cache(cCampo, "X3_USADO"),;
            GetSX3Cache(cCampo, "X3_TIPO"),;
            GetSX3Cache(cCampo, "X3_F3"),;
            GetSX3Cache(cCampo, "X3_CONTEXT"),;
            GetSX3Cache(cCampo, "X3_CBOX"),;
            GetSX3Cache(cCampo, "X3_RELACAO")})
        endif
    next nx

return aRet


// Array dos campos dos pedidos prontos para Embalagem
static function getCampos(nTypeBrowse)
	local aCpoRet	:= {}
    local aCampos   := {}
	local nCampos   := 0
    local nX        := 0

	if nTypeBrowse == CONSULTA_PRODUTO
		aCampos		:= strToKarr(CONSULTA_PRODUTO_CAMPOS, ",")
		aCoPrdCab	:= {}
        aCoPrdCam   := aCampos
	Elseif nTypeBrowse == CONSULTA_PAIS
		aCampos		:= strToKarr(CONSULTA_PAIS_CAMPOS, ",")
		aCoPHoCab	:= {}
        aCoPHoCam   := aCampos
    Elseif nTypeBrowse == PGA_REQMER
        aCampos		:= strToKarr(PGA_REQMER_CAMPOS, ",")
		aPgRMeCab	:= {}
        aPgRMeCam   := aCampos
    Elseif nTypeBrowse == PGA_MERCADO
        aCampos		:= strToKarr(PGA_MERCADO_CAMPOS, ",")
		aPgMerCab	:= {}
        aPgMerCam   := aCampos
    Elseif nTypeBrowse == PGA_PAIS
        aCampos		:= strToKarr(PGA_PAIS_CAMPOS, ",")
		aPgPaiCab	:= {}
        aPgPaiCam   := aCampos
    Elseif nTypeBrowse == PGA_PRODUTO
        aCampos		:= strToKarr(PGA_PRODUTO_CAMPOS, ",")
		aPgPrdCab	:= {}
        aPgPrdCam   := aCampos
        
        nPgPrdCam   := Len(aPgPrdCam)
    Elseif nTypeBrowse == PGA_PRD_HOMOL
        aCampos		:= Separa(PGA_PRD_HOMOL_CAMPOS, ",")
		aPgPrdCab	:= {}
        aPgPrdCam   := {}
        nCampos     := Len(aCampos)

        for nX := 1 To nCampos
            aAdd(aPgPrdCam, aCampos[nX])    
        next nX

        aAdd(aPgPrdCam, "MARCA")

        nPgPrdCam   := Len(aPgPrdCam)

    Elseif nTypeBrowse == HOM_PAIS
        aCampos		:= strToKarr(HOM_PAIS_CAMPOS, ",")
		aHoPaiCab	:= {}
        aHoPaiCam   := aCampos

    Elseif nTypeBrowse == HOM_CLI
        aCampos		:= strToKarr(HOM_CLI_CAMPOS, ",")
		aHoCliCab	:= {}
        aHoCliCam   := aCampos
    Elseif nTypeBrowse == HOM_EXI
        aCampos		:= strToKarr(HOM_EXI_CAMPOS, ",")
		aHoExiCab	:= {}
        aHoExiCam   := aCampos

        //aAdd(aHoExiCam, "MARCA")

    Elseif nTypeBrowse == HOM_CSI
        aCampos		:= strToKarr(HOM_CSI_CAMPOS, ",")
		aHoCsiCab	:= {}
        aHoCsiCam   := aCampos
	endIf

    nCampos := Len(aCampos)

    nCampos := Len(aCampos)
	for nX := 1 to nCampos
		cCampo	:= Alltrim(aCampos[nX])
        
        if nTypeBrowse == CONSULTA_PRODUTO
			cValue := "{|| aCoPrdDad[oCoBPrd:At(), " + cValToChar(nX) + "]}"
			aAdd(aCoPrdCab, cCampo)
        Elseif nTypeBrowse == CONSULTA_PAIS
			cValue := "{|| aCoPHoDad[oCoBPHo:At(), " + cValToChar(nX) + "]}"
			aAdd(aCoPHoCab, cCampo)
        Elseif nTypeBrowse == PGA_REQMER
        	cValue := "{|| aPgRMeDad[oPgBrMe:At(), " + cValToChar(nX) + "]}"
			aAdd(aPgRMeCab, cCampo)
        Elseif nTypeBrowse == PGA_MERCADO
            cValue := "{|| aPgMerDad[oPgBMer:At(), " + cValToChar(nX) + "]}"
			aAdd(aPgMerCab, cCampo)
        Elseif nTypeBrowse == PGA_PAIS
            cValue := "{|| aPgPaiDad[oPgBPai:At(), " + cValToChar(nX) + "]}"
			aAdd(aPgPaiCab, cCampo)
        Elseif nTypeBrowse == PGA_PRODUTO
            cValue := "{|| aPgPrdDad[oPgBPrd:At(), " + cValToChar(nX) + "]}"
			aAdd(aPgPrdCab, cCampo)
        Elseif nTypeBrowse == PGA_PRD_HOMOL
            cValue := "{|| aPgPrdDad[oPgBPrd:At(), " + cValToChar(nX) + "]}"
			aAdd(aPgPrdCab, cCampo)
        Elseif nTypeBrowse == HOM_PAIS
            cValue := "{|| aHoPaiDad[oHoBPai:At(), " + cValToChar(nX) + "]}"
			aAdd(aHoPaiCab, cCampo)
        Elseif nTypeBrowse == HOM_CLI
            cValue := "{|| aHoCliDad[oHoBCli:At(), " + cValToChar(nX) + "]}"
			aAdd(aHoCliCab, cCampo)
        Elseif nTypeBrowse == HOM_EXI
            cValue := "{|| aHoExiDad[oHoBExi:At(), " + cValToChar(nX) + "]}"
			aAdd(aHoExiCab, cCampo)
        Elseif nTypeBrowse == HOM_CSI
            cValue := "{|| aHoCsiDad[oHoBCsi:At(), " + cValToChar(nX) + "]}"
			aAdd(aHoCsiCab, cCampo)
		endIf

		oColumn := FWBrwColumn():New()
		oColumn:SetData(&(cValue))
		if cCampo$"YA_CODGI,ZE2_MERCAD,YA_CODGI,ZAZ_COD,ZEA_COD,A1_COD,A1_LOJA"
            oColumn:SetTitle('')
		    oColumn:SetSize(05)
        ELSE
            oColumn:SetTitle(getSx3Cache(cCampo, "X3_TITULO"))
		    oColumn:SetSize(getSx3Cache(cCampo, "X3_TAMANHO"))
        ENDIF
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
	local nX		:= 1
    Local nReg      := 0
    Local cProd     := ""
	local cTipoCp	:= ""
    Local cCargo    := ""

    if nTypeBrowse == CONSULTA_PRODUTO

		aCampos := strToKarr(CONSULTA_PRODUTO_CAMPOS, ",")

		cQuery := " SELECT " + CONSULTA_PRODUTO_CAMPOS
        cQuery += " FROM "+ RetSqlName("SB1") +" (NOLOCK) B1 LEFT JOIN "+ RetSqlName("ZE1") +" ZE1 ON B1.D_E_L_E_T_='' AND ZE1.D_E_L_E_T_='' AND B1.B1_FILIAL=ZE1.ZE1_FILIAL AND B1.B1_XPGAMER=ZE1.ZE1_REGIST "
        cQuery += " WHERE B1.D_E_L_E_T_='' AND B1.B1_FILIAL='"+ xFilial("SB1") +"' AND B1.B1_TIPO='PA' AND B1.B1_MSBLQL!='1' AND B1.B1_XPGAMER !='' "
        cQuery += " ORDER BY B1_COD; "
    
    Elseif nTypeBrowse == CONSULTA_PAIS
        
        nReg    := Len(aCoPrdDad)

        if nReg == 0
            cProd   := ""
        elseif Type("oCoBPrd") != "O"
            cProd	:= Alltrim(aCoPrdDad[1, aScan(aCoPrdCam, "B1_COD")])
        else
            cProd	:= Alltrim(aCoPrdDad[oCoBPrd:At(), aScan(aCoPrdCam, "B1_COD")])
        endif

        aCampos := strToKarr(CONSULTA_PAIS_CAMPOS, ",")

        cQuery := " SELECT " + CONSULTA_PAIS_CAMPOS
        cQuery += " FROM "+ RetSqlName("ZE4") +" (NOLOCK) ZE4 INNER JOIN "+ RetSqlName("SYA") +" (NOLOCK) YA ON ZE4.ZE4_FILIAL=YA.YA_FILIAL AND ZE4.ZE4_ZE3SYA=YA.YA_CODGI "
        cQuery += " WHERE ZE4.D_E_L_E_T_='' AND YA.D_E_L_E_T_='' AND ZE4.ZE4_FILIAL='"+ xFilial("ZE4") +"' AND ZE4.ZE4_CODPRD='"+ cProd +"' "
        cQuery += " ORDER BY YA_CODGI; "
        
    Elseif nTypeBrowse == PGA_REQMER

        aCampos := strToKarr(PGA_REQMER_CAMPOS, ",")

        cQuery := " SELECT " + PGA_REQMER_CAMPOS
        cQuery += " FROM "+ RetSqlName("ZE1") +" (NOLOCK) ZE1 "
        cQuery += " WHERE ZE1.D_E_L_E_T_='' AND ZE1.ZE1_FILIAL='"+ xFilial("ZE1") +"' "
        cQuery += " ORDER BY ZE1_REGIST; "

    Elseif nTypeBrowse == PGA_MERCADO

        aCampos := strToKarr(PGA_MERCADO_CAMPOS, ",")

        cQuery := " SELECT ZE2_MERCAD,LTRIM(RTRIM(X5_DESCRI)) X5_DESCRI "
        cQuery += " FROM "+ RetSqlName("ZE2") +" (NOLOCK) ZE2 LEFT JOIN "+ RetSqlName("SX5") +" (NOLOCK) X5 ON ZE2.D_E_L_E_T_='' AND X5.D_E_L_E_T_='' AND X5.X5_TABELA = '_E' AND ZE2.ZE2_MERCAD=X5.X5_CHAVE "
        cQuery += " WHERE ZE2.D_E_L_E_T_='' AND ZE2.ZE2_FILIAL='"+ xFilial("ZE2") +"' "
        
        IF !(oPgTRMe:isEmpty())
            cCargo      := oPgTRMe:getCargo()
            
            if left(cCargo,3)$"ZE1,ZED"
                if fPosiciona(cCargo)
                    if left(cCargo,3) == "ZE1"
                        cQuery += " AND ZE2_ZE1REG = '"+ Alltrim(ZE1->ZE1_REGIST) +"' "
                    elseif left(cCargo,3) == "ZED"
                        cQuery += " AND ZE2_ZE1REG = '"+ Alltrim(ZED->ZED_REGZE1) +"' "
                    endif
                endif
            
            ELSE 
                cQuery += " AND ZE2_ZE1REG = 'ZZZZZZZ' "
            endif
        ELSE 
                cQuery += " AND ZE2_ZE1REG = 'ZZZZZZZ' "
        endif

        cQuery += " ORDER BY ZE2_MERCAD; "

    Elseif nTypeBrowse == PGA_PAIS

        aCampos := strToKarr(PGA_PAIS_CAMPOS, ",")

		cQuery := " SELECT " + PGA_PAIS_CAMPOS
        cQuery += " FROM "+ RetSqlName("ZE3") +" (NOLOCK) ZE3 INNER JOIN "+ RetSqlName("SYA") +" (NOLOCK) YA ON ZE3.D_E_L_E_T_='' AND YA.D_E_L_E_T_='' AND ZE3.ZE3_FILIAL='"+ xFilial("ZE3") +"' AND YA.YA_FILIAL='"+ xFilial("SYA") +"' AND ZE3.ZE3_CODSYA=YA.YA_CODGI "
        cQuery += " WHERE YA.D_E_L_E_T_='' AND YA.YA_FILIAL='"+ xFilial("SYA") +"' "
        
        IF !(oPgTRMe:isEmpty())
            cCargo      := oPgTRMe:getCargo()
            
            if left(cCargo,3)$"ZE1,ZED"
                if fPosiciona(cCargo)
                    if left(cCargo,3) == "ZE1"
                        cQuery += " AND ZE3_ZE1REG = '"+ ZE1->ZE1_REGIST +"' "
                    elseif left(cCargo,3) == "ZED"
                        cQuery += " AND ZE3_ZE1REG = '"+ ZED->ZED_REGZE1 +"' "
                    endif
                endif
            
            ELSE 
                cQuery += " AND ZE3_ZE1REG = 'ZZZZZZZ' "
            endif
        ELSE 
                cQuery += " AND ZE3_ZE1REG = 'ZZZZZZZ' "
        endif
        
        cQuery += " ORDER BY ZE3.ZE3_CODSYA; "

    Elseif nTypeBrowse == PGA_PRODUTO

        aCampos     := strToKarr(PGA_PRODUTO_CAMPOS, ",")
        
		cQuery := " SELECT " + PGA_PRODUTO_CAMPOS
        cQuery += " FROM "+ RetSqlName("SB1") +" (NOLOCK) B1 "
        cQuery += " WHERE B1.D_E_L_E_T_='' AND B1.B1_FILIAL='"+ xFilial("SB1") +"' AND B1.B1_MSBLQL!='1' "
        
        IF !(oPgTRMe:isEmpty())
            cCargo      := oPgTRMe:getCargo()
            
            if left(cCargo,3) == "ZE1"
                if fPosiciona(cCargo)
                    cQuery += " AND B1_XPGAMER = '"+ ALLTRIM(ZE1->ZE1_REGIST) +"' "
                endif
            Elseif left(cCargo,3) == "ZED"
                if fPosiciona(cCargo)
                    cQuery += " AND B1_XPGAMER = '"+ ZED->ZED_REGZE1 +"' AND B1_XPGACAT = '"+ ZED->ZED_CODCAT +"' "
                endif
            ELSE 
                cQuery += " AND B1_XPGAMER = 'ZZZZZZZ' "
            endif
        ELSE 
                cQuery += " AND B1_XPGAMER = 'ZZZZZZZ' "
        endif

        cQuery += " ORDER BY B1_COD; "
    Elseif nTypeBrowse == PGA_PRD_HOMOL

        aCampos     := strToKarr(PGA_PRD_HOMOL_CAMPOS, ",")
        
        IF !(oPgTRMe:isEmpty()) .AND. oPgBPai:at() > 0 .and. len(aPgPaiDad) > 0
            cCargo      := oPgTRMe:getCargo()

            cQuery := " SELECT ISNULL(ZE4.ZE4_ATIVO,2) ZE4_ATIVO, " + PGA_PRD_HOMOL_CAMPOS
            cQuery += " FROM "+ RetSqlName("SB1") +" (NOLOCK) B1 LEFT JOIN "+ RetSqlName("ZE4") +" (NOLOCK) ZE4 ON B1.D_E_L_E_T_='' AND ZE4.D_E_L_E_T_='' AND B1.B1_FILIAL=ZE4.ZE4_FILIAL AND B1.B1_COD=ZE4.ZE4_CODPRD AND B1.B1_XPGAMER=ZE4.ZE4_ZE1REG "
            if oPgBPai:at() > 0
                cQuery += "  AND ZE4_ZE3SYA = '"+ aPgPaiDad[oPgBPai:at()][aScan(aPgPaiCam,"YA_CODGI")] +"' "
            else
                cQuery += "  AND ZE4_ZE3SYA = 'ZZZ' "
            endif
            cQuery += " WHERE B1.D_E_L_E_T_='' AND B1.B1_FILIAL='"+ xFilial("SB1") +"' AND B1.B1_MSBLQL!='1' "

            if left(cCargo,3) == "ZE1"
                if fPosiciona(cCargo)
                    cQuery += " AND B1.B1_XPGAMER = '"+ ALLTRIM(ZE1->ZE1_REGIST) +"' "
                endif
            Elseif left(cCargo,3) == "ZED"
                if fPosiciona(cCargo)
                    cQuery += " AND B1.B1_XPGAMER = '"+ ZED->ZED_REGZE1 +"' AND B1.B1_XPGACAT = '"+ ZED->ZED_CODCAT +"' "
                endif
            ELSE 
                cQuery += " AND B1.B1_XPGAMER = 'ZZZZZZZ' "
            endif
            
            cQuery += " ORDER BY B1_COD; "
        ELSE 
            cQuery := " SELECT ISNULL(ZE4.ZE4_ATIVO,2) ZE4_ATIVO, " + PGA_PRD_HOMOL_CAMPOS
        endif

    Elseif nTypeBrowse == HOM_PAIS
        
        aCampos := strToKarr(HOM_PAIS_CAMPOS, ",")

		cQuery := " SELECT " + HOM_PAIS_CAMPOS
        cQuery += " FROM "+ RetSqlName("SYA") +" (NOLOCK) YA "
        cQuery += " WHERE YA.D_E_L_E_T_='' AND YA.YA_FILIAL='"+ xFilial("SYA") +"' "

        if !(oRmTRMe:isEmpty())
            if oRmTRMe:nivel() == 2
                cQuery += " AND YA.YA_XGRPINS='"+ Alltrim(oRmTRMe:getCargo()) +"' "
            else
                cQuery += " AND YA.YA_XGRPINS='ZZZZ' "
            endif
        else
            cQuery += " AND YA.YA_XGRPINS='ZZZZ' "
        endif

        cQuery += " ORDER BY YA_CODGI; "

    Elseif nTypeBrowse == HOM_CLI
        
        aCampos := strToKarr(HOM_CLI_CAMPOS, ",")

		cQuery := " SELECT " + HOM_CLI_CAMPOS
        cQuery += " FROM "+ RetSqlName("SA1") +" (NOLOCK) A1 "
        cQuery += " WHERE A1.D_E_L_E_T_='' AND A1.A1_FILIAL='"+ xFilial("SA1") +"' AND A1.A1_MSBLQL!='1' "
   
        if !(oRmTRMe:isEmpty())
            if oRmTRMe:nivel() == 2
                cQuery += " AND A1.A1_XGRPINS='"+ Alltrim(oRmTRMe:getCargo()) +"' "
            else
                cQuery += " AND A1.A1_XGRPINS='ZZZZ' "
            endif
        else
            cQuery += " AND A1.A1_XGRPINS='ZZZZ' "
        endif

        cQuery += " ORDER BY A1_COD, A1_LOJA; "

    Elseif nTypeBrowse == HOM_EXI
        DbSelectarea("ZEZ")

        aCampos := strToKarr(HOM_EXI_CAMPOS, ",")

		cQuery := " SELECT " + HOM_EXI_CAMPOS
        cQuery += " FROM "+ RetSqlName("ZEZ") +" (NOLOCK) ZEZ "
        cQuery += " WHERE ZEZ.D_E_L_E_T_='' AND ZEZ.ZEZ_FILIAL='"+ xFilial("ZEZ") +"' "
        
        if !(oRmTRMe:isEmpty())
            if oRmTRMe:nivel() == 2
                cQuery += " AND ZEZ.ZEZ_CODZCO = '"+ Alltrim(oRmTRMe:getCargo()) +"' "
            else
                cQuery += " AND ZEZ.ZEZ_CODZCO = 'ZZZZ'"
            endif
        else
            cQuery += " AND ZEZ.ZEZ_CODZCO = 'ZZZZ'"
        endif

        cQuery += " ORDER BY ZEZ_CODZCO, ZEZ_COD; "

    Elseif nTypeBrowse == HOM_CSI
        DbSelectarea("ZEA")
        
        aCampos := strToKarr(HOM_CSI_CAMPOS, ",")

		cQuery := " SELECT " + HOM_CSI_CAMPOS
        cQuery += " FROM "+ RetSqlName("ZEA") +" (NOLOCK) ZEA "
        cQuery += " WHERE ZEA.D_E_L_E_T_='' AND ZEA.ZEA_FILIAL='"+ xFilial("ZEA") +"' "
        
        if !(oRmTRMe:isEmpty())
            if oRmTRMe:nivel() == 2
                cQuery += " AND ZEA.ZEA_CODZCO = '"+ Alltrim(oRmTRMe:getCargo()) +"' "
            else
                cQuery += " AND ZEA.ZEA_CODZCO = 'ZZZZ'"
            endif
        else
            cQuery += " AND ZEA.ZEA_CODZCO = 'ZZZZ'"
        endif

        cQuery += " ORDER BY ZEA_CODZCO, ZEA_COD; "

    endif

	tcQuery cQuery new alias &cAlias

	(cAlias)->(DbGoTop())

	if (cAlias)-> (!eof())
		While (cAlias)->(!eof())
			aDado := {}
            
			for nX := 1 to Len(aCampos)
				cTipoCp	:= allTrim(getSx3Cache(aCampos[nX], "X3_TIPO"))

				if cTipoCp <> "D"
					aAdd(aDado, (cAlias)-> &(aCampos[nX]))
				else
					aAdd(aDado, sToD((cAlias)-> &(aCampos[nX])))
				endIf
			next nX
            if nTypeBrowse == PGA_PRD_HOMOL
                if (cAlias)->ZE4_ATIVO == "1"
                    aAdd(aDado,.T.)
                Else
                    aAdd(aDado,.F.)
                endif
            ENDIF

			aAdd(aDado, .F.)

			aAdd(aDados, aDado)
			(cAlias)->(DbSkip())
		EndDo
	endIf

return(aDados)

//Array de dados
static function getDadosTre(nTypeBrowse)
	local cQuery	:= ""
	local cAlias 	:= ""
    local cReqMerc  := ""
    Local cMercado  := ""
    Local cPrompt   := ""
    Local cCargoA   := ""
    Local cCargoB   := ""
    Local cCargoC   := ""
    Local cCargoD   := ""

    Local aDados    := {}

    DbselectArea("ZE0")
    cCargoA  := "ZE0_"+StrZero(ZE0->(recno()),7)
    cPrompt := Alltrim(ZE0->ZE0_REGIST)+"-"+ZE0->ZE0_RAZAO

    cAlias 	:= getNextAlias()

    if nTypeBrowse == PGA_REQMER
        IF !(oPgTRMe:isEmpty())
            oPgTRMe:BeginUpdate()
            oPgTRMe:Reset()
            oPgTRMe:EndUpdate()
        else
            oPgTRMe:BeginUpdate()
        endif
        
        oPgTRMe:AddItem(cPrompt, cCargoA, ARMAZEM, ARMAZEM,,,01)

        
        aCampos := strToKarr(PGA_REQMER_CAMPOS, ",")

        cQuery  := " SELECT ZE1.ZE1_FILIAL, ZE1.ZE1_REGIST, ZE1.ZE1_DENOMI, ZE1.R_E_C_N_O_ ZE1REG,"
        cQuery  += "    ZED.ZED_CODCAT, ZED.ZED_DESCAT, ZED.R_E_C_N_O_ ZEDREG "
        cQuery  += " FROM "+ RetSqlname("ZE1") +" (NOLOCK) ZE1 LEFT JOIN "+ RetSqlname("ZED") +" (NOLOCK) ZED ON ZED.D_E_L_E_T_='' AND ZED.ZED_FILIAL='"+ xFilial("ZED") +"' AND ZE1.ZE1_REGIST=ZED.ZED_REGZE1 "
        cQuery  += " WHERE ZE1.D_E_L_E_T_='' "
        cQuery  += " ORDER BY ZE1_REGIST, ZED.ZED_DESCAT; "

        tcQuery cQuery new alias &cAlias

        (cAlias)->(DbGoTop())

        if (cAlias)-> (!eof())
            While (cAlias)->(!eof())
                
                if cReqMerc  != (cAlias)->ZE1_REGIST
                    
                    oPgTRMe:TreeSeek(cCargoA)

                    cCargoB  := "ZE1_"+STRZERO((cAlias)->ZE1REG,7)
                    cPrompt := Alltrim((cAlias)->ZE1_REGIST)+"-"+(cAlias)->ZE1_DENOMI
                    
                    if Empty((cAlias)->ZEDREG)
                        //aadd( aDados, {'01', cCargo, "", cPrompt, IMAGE5, IMAGE6} )
                        oPgTRMe:AddItem(cPrompt, cCargoB, IMAGE5, IMAGE6,,,02)
                    else
                        //aadd( aDados, {'01', cCargo, "", cPrompt, IMAGE10, IMAGE11} )
                        oPgTRMe:AddItem(cPrompt, cCargoB, IMAGE10, IMAGE11,,,02)
                    endif

                    cCategor := ""
                endif
                //CATEGORIA
                if cCategor != (cAlias)->ZED_CODCAT .and. !Empty((cAlias)->ZED_CODCAT)
                    oPgTRMe:TreeSeek(cCargoB)

                    cCargoC  := "ZED_"+STRZERO((cAlias)->ZEDREG,7)
                    cPrompt := Alltrim((cAlias)->ZED_CODCAT)+"-"+(cAlias)->ZED_DESCAT
                    oPgTRMe:AddItem(cPrompt, cCargoC, IMAGE5, IMAGE6,,,03)
                    
                endif

                cReqMerc    := (cAlias)->ZE1_REGIST
                cCategor    := (cAlias)->ZED_CODCAT
                
                oPgTRMe:treeSeek(cCargoA)
                (cAlias)->(DbSkip())
            EndDo
        
            oPgTRMe:treeSeek(cCargoA)
            oPgTRMe:EndUpdate()
        
        endIf

        (cAlias)->(Dbclosearea())
    elseif nTypeBrowse == GRI_REQMER

        oRmTRMe:AddItem(cPrompt, cCargoA, ARMAZEM, ARMAZEM,,,01)

        cQuery  := " SELECT ZCO_FILIAL, ZCO_CODIGO, ZCO_DESCRI "
        cQuery  += " FROM "+ RetSqlName("ZCO") +" "
        cQuery  += " WHERE D_E_L_E_T_='' AND ZCO_MSBLQL!='1'; "

        tcQuery cQuery new alias &cAlias

        (cAlias)->(DbGoTop())

        if (cAlias)-> (!eof())
            While (cAlias)->(!eof())
                cPrompt := Alltrim((cAlias)->ZCO_CODIGO)+"-"+alltrim((cAlias)->ZCO_DESCRI)
                cCargoB := Alltrim((cAlias)->ZCO_CODIGO)

                oRmTRMe:AddItem(cPrompt, cCargoB, IMAGE5, IMAGE6,,,02)

                (cAlias)->(Dbskip())
            Enddo
        endif

        (cAlias)->(DbcloseArea())

    endif

return(aDados)


static function filtraProd(oSeek, oBrowse,cArray)
	local cFiltro	:= oSeek:getSeek()
	local nOrder	:= oSeek:getOrder()
	local nPosCod	:= aScan(cArray, "B1_COD")
	local nPosDesc	:= aScan(cArray, "B1_DESC")
	local nPosRet	:= 1

    if nOrder == 1
	    nPosRet := aScan(oBrowse:oData:aArray, {|x| allTrim(cFiltro) $ x[nPosCod]})
    elseif nOrder == 2
        nPosRet := aScan(oBrowse:oData:aArray, {|x| allTrim(cFiltro) $ x[nPosDesc]})
    endif

	if nPosRet == 0
        Msginfo("Não foi encontrado nenhum registro!")
		nPosRet := 1
	endIf

return(nPosRet)

// Elimina os registros do componente DbTree.
Static Function fDelNode(cAlias, cZE0Reg, cZE1Reg, cZE2Reg, cZE3Reg)

    BEGIN TRANSACTION

        if cAlias == "ZE0"
            fDelZE()
            fDelZE("ZE1", "")
            fDelZE("ZE2", "")
            fDelZE("ZE3", "")
            fDelZE("ZE4", "")
        elseif cAlias == "ZE1"
            fDelZE("ZE2", " AND ZE2_ZE1REG='"+ cZE1Reg +"' ")
            fDelZE("ZE3", " AND ZE3_ZE1REG='"+ cZE1Reg +"' ")
            fDelZE("ZE4", " AND ZE4_ZE1REG='"+ cZE1Reg +"' ")
            fUpdSB1(cZE1Reg)
        elseif cAlias == "ZE2"
            fDelZE("ZE3", "AND ZE3_ZE1REG='"+ cZE1Reg +"' AND ZE3_ZE2MER='"+ cZE2Reg +"' ")
        elseif cAlias == "ZE3"
            fDelZE("ZE4", "AND ZE4_ZE1REG='"+ cZE1Reg +"' AND ZE4_ZE2MER='"+ cZE2Reg +"' AND ZE4_ZE3SYA='"+ cZE3Reg +"'")
            //fDelZE("ZE3", cZE1Reg, cZE2Reg)
        endif

    END TRANSACTION
        

return

/* Delete ZE1 */
Static Function fDelZE(cAlias, cWhere)    
    Default cAlias  := ""

    cQuery 	:= " SELECT R_E_C_N_O_ REGISTRO "
    cQuery	+= " FROM "+ RetSqlName(cAlias)
    cQuery 	+= " WHERE D_E_L_E_T_='' AND "+cAlias+"_FILIAL='"+ xfilial(cAlias) +"' "
    cQuery  += cWhere

    Tcquery cQuery ALIAS "QZE" NEW

    While QZE->(!eof())
        
        (cAlias)->(DbgoTo(QZE->REGISTRO))
        
        if Reclock(cAlias,.F.)
            (cAlias)->(dbDelete())
            (cAlias)->(Msunlock())
        endif
        
        QZE->(DbSkip())
    enddo

    QZE->(DbCloseArea())
return


/* Delete ZE1 */
Static Function fUpdSB1(cZE1Reg)
    
    cQuery 	:= " SELECT R_E_C_N_O_ REGISTRO "
    cQuery	+= " FROM "+ RetSqlName("SB1") +" "
    cQuery 	+= " WHERE D_E_L_E_T_='' AND B1_FILIAL='"+ xfilial("SB1") +"' AND B1_XPGAMER='"+ cZE1Reg +"' "
       
    Tcquery cQuery ALIAS "QSB1" NEW

    While QSB1->(!eof())
        if SB1->(DbgoTo(QSB1->REGISTRO))
            if Reclock("SB1",.F.)
                B1_XPGAMER := ""
                Msunlock()
            endif
        endif
        QSB1->(DbSkip())
    enddo

    QSB1->(DbCloseArea())
return


Class ADEST055P

Data cEOL  			AS String            && character of line end
Data ntipBlq
Data lPrcPGA
Data cPathPGA

Method New() Constructor
Method PGAVldPrd()
Method setEspTec()
Method getEspTec()

Method Destroy()  && Inline Super:Destroy()

EndClass

&& Metodo construtor
Method New() Class ADEST055P
	::nTipBlq   := SUPERGETMV("MV_XPGABLQ",,1)
    ::lPrcPGA   := SUPERGETMV("MV_XPGAPRC",,.F.)
    ::cPathPGA  := Alltrim(SUPERGETMV("MV_XPGAPAT",,"\system\ADORO_DOC\PGA_ESP_TECNICAS\"))
	::cEOL   	:= CHR(13)+CHR(10)

    if Right(self:cPathPGA,1) != "\"
        self:cPathPGA := self:cPathPGA+"\"
    endif

Return

METHOD setEspTec(cProduto) CLASS ADEST055P
    Local aPath     := {}
    Local cPath     := ""
    Local cArq      := ""
    Local lValid    := .T.
    Local cHora     := alltrim(Time())
    Local cDatArq   := Dtos(Date())+"_"+Replace(cHora,":","")
    Local cDatUpl   := Dtoc(Date())+"-"+cHora
    Local cArqTo    := ""
    Local cPathDes  := self:cPathPGA+cProduto+"\"

    DbSelectArea("SB1")
    SB1->(DbSetOrder(1))

    if SB1->(DbSeek(xFilial("SB1")+cProduto))
        
        cArq    := Alltrim(SB1->B1_XREQTEC)
        
        if !Empty(cArq)
            If !msgYesNo("Já existe um arquivo importado, deseja atualizar?")
                lValid  := .F.
            endif
        endif
        
        if lValid
            cPath  := cGetFile('Arquivo|*.*|Arquivo *|*.*','Selecione o arquivo',0,'C:\temp\',.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.)

            if file(cPath)
                
                fMakeDir(cPathDes)

                aPath   := Separa(cPath,"\")
                cArq    := aPath[Len(aPath)]
                aArq    := Separa(cArq,".")
                
                if Len(aArq) > 1
                    cExten  := aArq[Len(aArq)]
                else
                    cExten  := ""
                endif
                
                cArqTo := cProduto+"."+cExten
                cArqCp := cProduto+"_"+cDatArq+"."+cExten

                CPYT2S(alltrim(cPath),cPathDes,.T.,.F.)
                
                if file(cPathDes+cArqTo) 
                    __CopyFile(cPathDes+cArqTo, cPathDes+cArqCp)
                endif

                __CopyFile(cPathDes+cArq, cPathDes+cArqTo)
                fErase(cPathDes+cArq)
                if Reclock("SB1",.F.)
                    SB1->B1_XREQTEC     := cArqTo
                    SB1->B1_XDTUPLD     := cDatUpl
                    SB1->(Msunlock())
                endif

                MsgInfo("Arquivo importado com sucesso!")
            else
                Msginfo("Operção cancelada pelo usuário ou arquivo inválido!")
            endif
        else
            Msginfo("Operção cancelada pelo usuário ou arquivo inválido!")
        endif
    else
        MsgInfo("Produto não encontrado!")
    endif
RETURN

METHOD getEspTec(cProduto) CLASS ADEST055P
    Local cPath     := ""
    Local cArq      := ""
    Local cPathOri  := self:cPathPGA+cProduto+"\"

    DbSelectArea("SB1")
    SB1->(DbSetOrder(1))

    if SB1->(DbSeek(xFilial("SB1")+cProduto))

        cArq := Alltrim(SB1->B1_XREQTEC)

        if !Empty(cArq)
            cPath  := cGetFile('Arquivo|*.*|Arquivo *|*.*','Selecione o arquivo',0,'C:\temp\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.)

            if lIsDir(cPath)
                CPYS2T(cPathOri+cArq, alltrim(cPath), .T., .F.)
                ShellExecute("open",cPath+cArq,"","",1)    
            else
                Msginfo("Operção cancelada pelo usuário ou arquivo inválido!")
            endif
        else
            Msginfo("Não existe arquivo importado para resse registro!")
        endif
    else
        Msginfo("Produto não encontrado!")
    endif

RETURN

METHOD PGAVldPrd(cProduto, cPaisDes, cFunname) CLASS ADEST055P

    Local cQuery    := ""
    Local lValid    := .T.
    
    if self:lPrcPGA
    
        if self:nTipBlq == 1 .or. self:nTipBlq == 2
        
            cQuery += " SELECT COUNT(*) CONTADOR "
            cQuery += " FROM " 
            cQuery += " " + RetSqlName("ZE4") + " (NOLOCK) AS ZE4 "  
            cQuery += " WHERE " 
            cQuery += " ZE4_FILIAL     = '" + FWxFilial("ZE4") + "' " 
            cQuery += " AND ZE4_ZE3SYA = '" + cPaisDes + "' " 
            cQuery += " AND ZE4_CODPRD = '" + cProduto + "' " 
            cQuery += " AND ZE4_ATIVO  = '1' "
            cQuery += " AND ZE4.D_E_L_E_T_ = ''; "

            Tcquery cQuery ALIAS "QZE4" NEW

            if QZE4->CONTADOR == 0
                cMsgInfo := cFunname+"-O produto "+Alltrim(cProduto)+" selecionado não está habilitado/cadastrado na PGA para ser exportado para o país de destino(EE7_PAISET)."
                
                if self:nTipBlq == 1
                    MsgAlert(cMsgInfo)
                    lValid := .F.
                elseif self:ntipBlq == 2
                    MsgInfo(cMsgInfo)
                endif
            Else

            endif
            QZE4->(DbcloseArea())
        endif

    endif
return lValid

Static Function fMakeDir(cPath)
	Local lret 			:= .T.
	Local aFolder		:= {}
	Local nC				:= 0
	Local cDirDoc	:= ""
	
	If  !lIsDir(cPath)
		// Quebra o caminho em Paths.
		aFolder	:= Separa(cPath,"\",.f.)
		cDirDoc	:= ""
		// Recria arquivos.		
		For nC := 1 TO Len(aFolder)
			cDirDoc += IIF(!":"$aFolder[nC],"\","") + Alltrim(aFolder[nC])	
			If  !lIsDir(cDirDoc)
				If MakeDir(cDirDoc) != 0
					lRet := .F.
				EndIf
			EndIf
		Next nC	

	EndIf

Return lRet 
