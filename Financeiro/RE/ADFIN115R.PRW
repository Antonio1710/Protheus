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
#DEFINE CONSULTA_REDES          1
#DEFINE CONSULTA_CLIENTES       2
#DEFINE CONSULTA_PORTADOR       3

#DEFINE PANEL01_VIEW            11
#DEFINE PANEL02_VIEW            12

// Defines dos campos.
#DEFINE CONSULTA_REDES_CAMPOS       "ZF_REDE,ZF_NOMERED"
#DEFINE CONSULTA_CLIENTES_CAMPOS    "A1_COD,A1_LOJA,A1_NOME,A1_CGC"
#DEFINE CONSULTA_PORTADOR_CAMPOS    "A6_COD,A6_NOME"


/*/{Protheus.doc} User Function U_ADFIN115R()
    Tela de gestão dos processos de exportação.
    Chamado 8465
    @type  Function
    @author Leonardo P. Monteiro
    @since 15/03/2021
    @version 01
    @history Chamado 63394 - Leonardo P. Monteiro - 08/11/2021 - Reformulação da rotina ADFIN071R para melhoramento de performance e atualização das funções.
/*/
user function ADFIN115R()
    Local cTitle    := "..:: Rede e Segmentos ::.."
    Local nAlt      := 0
    Local nLarg     := 0
    Local aSize     := {}
    Private oWnd

    Private oLayer
    Private oLayp01
    
    Private oBClie
    Private oBRede
    Private oBPort
    
    // Grid de seleção dos clientes.
    Private aClieCab    := {}
    Private aClieCam    := {}
    Private aClieDad    := {}
    // Grid de seleção das redes.
    Private aRedeCab    := {}
    Private aRedeCam    := {}
    Private aRedeDad    := {}
    // Grid de seleção das portador.
    Private aPortCab    := {}
    Private aPortCam    := {}
    Private aPortDad    := {}
    
    Private oDTFATDE
    Private oDTFATATE
    Private oDtFINDE
    Private oDTFINATE
    Private onPLANFAT
    Private onPLANFIN
    Private onTPRELAT
    Private oRETZERO
    Private oRETNCC

    Private oGetRede
    Private oGetClie

    //Private oWnd        := nil
    Private oPanel01
    Private oPanel02
    
    Private dDTFATDE    := Stod(cValtochar(YEAR(Date())-1)+"0101" )
    Private dDTFATATE   := Stod(cValtochar(YEAR(Date()))+"1231" )
    Private dDtFINDE    := Stod(cValtochar(YEAR(Date())-1)+"0101" )
    Private dDTFINATE   := Stod(cValtochar(YEAR(Date()))+"1231" )
    Private aPLANFAT    := {"Ano","Mês","Dia"}
    Private cPLANFAT    := "Mês"
    Private nPLANFAT    := 2
    Private aPLANFIN    := {"Ano","Mês","Dia"}
    Private cPLANFIN    := "Mês"
    Private nPLANFIN    := 2
    Private aTPRELAT    := {"Rede","Cliente"}
    Private cTPRELAT    := "Rede"
    Private nTPRELAT    := 1
    Private aRETZERO    := {"Sim","Não"}
    Private cRETZERO    := "Sim"
    Private nRETZERO    := 1
    Private aRETNCC     := {"Sim","Não"}
    Private cRETNCC     := "Sim"
    Private nRETNCC     := 1

    Private cGetRede    := Space(10)
    Private cGetClie    := Space(70)

    Private oDblClick   := {|| fDblClick(PANEL01_VIEW)}
    Private oChgItEx    := {|| fChgItEx() }
    Private bMark       := {|oBrowser| fMark(oBrowser)}
    Private bDblClk     := {|oBrowser| fDblClk(oBrowser)}
    Private bHeaClk     := {|oBrowser| fHeaClk(oBrowser)}

    Private nRedeCam    := 0
    Private nClieCam    := 0
    Private nPortCam    := 0

    Private nRedeReg    := 0
    Private nClieReg    := 0
    Private nPortReg    := 0

    Private nBrwFocused := 0

    Private cFiltRede := ""
	Private cFiltRedeR:= ""
	Private aHistRede := {}

    Private cRedeNome   := ""
    Private cClieNome   := ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Titulos Faturados de Rede e Clientes')

	//Log de acesso.
	logAcesso("ADFIN115R")

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

    aSize   := MsAdvSize(.T.)
    nAlt    := aSize[06]
    nLarg   := aSize[05]
    
    oWnd            := Msdialog():Create()
    oWnd:cTitle     := cTitle
    ownd:nWidth     := nLarg
    oWnd:nHeight    := nAlt
    oWnd:lMaximized := .T.
    oWnd:SetCSS("QWidget{ font: bold 12px; } TTabs{ margin: 0px; } ")

    oLayer := FWLayer():new()
    
    oLayer:init(oWnd,.F.)
    oLayer:opanel:nHeight   := nAlt*1.055
	oLayer:opanel:nWidth   	:= nLarg*1.004

    layGrid()
    //layPanel()

    oWnd:Activate()
return

Static Function layGrid()
    
    oLayer:addLine("L01",100, .F.)
    oLayer:addCollumn("L01C01", 100, .F., "L01")
    oL01C01 := oLayer:getColPanel("L01C01", "L01")
    
    //Painél de visualização dos parâmetros
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
    oLayp01:addCollumn("L01C01", 030, .F., "L01")
    oLayp01:addCollumn("L01C02", 030, .F., "L01")
    oLayp01:addCollumn("L01C03", 025, .F., "L01")
    oLayp01:addCollumn("L01C04", 015, .F., "L01")

    oLayp01:addWindow("L01C01", "Win01", "Redes"		        ,100,.F.,.F.,{||"" },"L01",{||""})
    oLayp01:addWindow("L01C02", "Win02", "Clientes"		        ,100,.F.,.F.,{||"" },"L01",{||""})
    oLayp01:addWindow("L01C03", "Win03", "Portador"		        ,100,.F.,.F.,{||"" },"L01",{||""})
    oLayp01:addWindow("L01C04", "Win04", "Parâmetros/Filtros"	,085,.F.,.F.,{||"" },"L01",{||""})
    oLayp01:addWindow("L01C04", "Win05", "Opções"               ,015,.F.,.F.,{||"" },"L01",{||""})
    
    oLayp01:GetLinePanel("L01"):SetCSS("QFrame{ background-color: #FFFFFF;}")

    //**************************************************
    // Sessão do grid de Redes.
    //**************************************************
    aRedeCab		:= getCampos(CONSULTA_REDES)
    MsAguarde({|| aRedeDad		:= getDadosBrw(CONSULTA_REDES) },"Aguarde","Consultando redes...")
    
    oCoWin01 := oLayp01:GetWinPanel("L01C01","Win01","L01")
    
    oBRede := FWBrowse():New(oCoWin01)
    oBRede:SetProfileID("0001")
    oBRede:addMarkColumns(bMark, bDblClk, bHeaClk)
    oBRede:setColumns(aRedeCab)
	oBRede:setDataArray()
	oBRede:disableReport()
	oBRede:disableConfig()
    oBRede:setArray(aRedeDad)
    
    
    aAdd(aSeek,{"Rede"      , {{"","C",15,0, "ZF_REDE"      ,}}})
    aAdd(aSeek,{"Nome"      , {{"","C",45,0, "ZF_NOMERED"   ,}}})
    
    oBRede:setSeek({|oSeek, oBrowse| fFiltra(oSeek, oBrowse)}, aSeek)
    
    oBRede:setFieldFilter({ {"ZF_REDE"      ,getSx3Cache("ZF_REDE", "X3_TITULO")    ,getSx3Cache("ZF_REDE", "X3_TIPO") ,getSx3Cache("ZF_REDE", "X3_TAMANHO") ,getSx3Cache("ZF_REDE", "X3_DECIMAL") ,getSx3Cache("ZF_REDE", "X3_PICTURE") },;
                            {"ZF_NOMERED"   ,getSx3Cache("ZF_NOMERED", "X3_TITULO")  ,getSx3Cache("ZF_NOMERED", "X3_TIPO")  ,getSx3Cache("ZF_NOMERED", "X3_TAMANHO")  ,getSx3Cache("ZF_NOMERED", "X3_DECIMAL")  ,getSx3Cache("ZF_NOMERED", "X3_PICTURE")  };
						  })
    //oBRede:SetUseFilter(.T.)
    oBRede:bGotFocus := {|| nBrwFocused := CONSULTA_REDES}
    oCoWin01:Refresh( .T. ) 
    oBRede:Activate()

    //**************************************************
    // Sessão do grid de Clientes.
    //**************************************************
    aClieCab		:= getCampos(CONSULTA_CLIENTES)
    MsAguarde({|| aClieDad		:= getDadosBrw(CONSULTA_CLIENTES) },"Aguarde","Consultando clientes...")

    oCoWin02 := oLayp01:GetWinPanel("L01C02","Win02","L01")
    
    oBClie := FWBrowse():New(oCoWin02)
    oBClie:SetProfileID("0002")
    oBClie:addMarkColumns(bMark, bDblClk, bHeaClk)
    oBClie:setColumns(aClieCab)
	oBClie:setDataArray()
	oBClie:disableReport()
	oBClie:disableConfig()
    oBClie:setArray(aClieDad)
    
    aAdd(aSeek,{"Código"    , {{"","C",15,0, "A1_COD"    ,}}})
    aAdd(aSeek,{"Nome"      , {{"","C",45,0, "A1_NOME"   ,}}})
    aAdd(aSeek,{"CNPJ"      , {{"","C",45,0, "A1_CGC"    ,}}})
    
    oBClie:setSeek({|oSeek, oBrowse| fFiltra(oSeek, oBrowse)}, aSeek)
    
    oBClie:setFieldFilter({ {"A1_COD"    ,getSx3Cache("A1_COD", "X3_TITULO") ,getSx3Cache("A1_COD", "X3_TIPO") ,getSx3Cache("A1_COD", "X3_TAMANHO") ,getSx3Cache("A1_COD", "X3_DECIMAL") ,getSx3Cache("A1_COD", "X3_PICTURE") },;
                            {"A1_NOME"   ,getSx3Cache("A1_NOME", "X3_TITULO")  ,getSx3Cache("A1_NOME", "X3_TIPO")  ,getSx3Cache("A1_NOME", "X3_TAMANHO")  ,getSx3Cache("A1_NOME", "X3_DECIMAL")  ,getSx3Cache("A1_NOME", "X3_PICTURE")  },;
                            {"A1_CGC"    ,getSx3Cache("A1_CGC", "X3_TITULO")  ,getSx3Cache("A1_CGC", "X3_TIPO")  ,getSx3Cache("A1_CGC", "X3_TAMANHO")  ,getSx3Cache("A1_CGC", "X3_DECIMAL")  ,getSx3Cache("A1_CGC", "X3_PICTURE")  };
						    })
                            
    //oBClie:SetUseFilter(.T.)
    oBClie:bGotFocus := {|| nBrwFocused := CONSULTA_CLIENTES}
    oCoWin02:Refresh( .T. ) 
    oBClie:Activate()

    //**************************************************
    // Sessão do grid de Portador.
    //**************************************************
    aPortCab		:= getCampos(CONSULTA_PORTADOR)
    MsAguarde({|| aPortDad		:= getDadosBrw(CONSULTA_PORTADOR) },"Aguarde","Consultando portadores...")
    
    oCoWin03 := oLayp01:GetWinPanel("L01C03","Win03","L01")
    
    oBPort := FWBrowse():New(oCoWin03)
    oBPort:SetProfileID("0003")
    oBPort:addMarkColumns(bMark, bDblClk, bHeaClk)
    oBPort:setColumns(aPortCab)
	oBPort:setDataArray()
	oBPort:disableReport()
	oBPort:disableConfig()
    oBPort:setArray(aPortDad)
    
    aAdd(aSeek,{"Código"    , {{"","C",15,0, "A6_COD"    ,}}})
    aAdd(aSeek,{"Nome"      , {{"","C",45,0, "A6_NOME"   ,}}})
    
    oBPort:setSeek({|oSeek, oBrowse| fFiltra(oSeek, oBrowse)}, aSeek)
    
    oBPort:setFieldFilter({ {"A6_COD"    ,getSx3Cache("A6_COD", "X3_TITULO")        ,getSx3Cache("A6_COD", "X3_TIPO")      ,getSx3Cache("A6_COD", "X3_TAMANHO")       ,getSx3Cache("A6_COD", "X3_DECIMAL")       ,getSx3Cache("A6_COD", "X3_PICTURE") },;
                            {"A6_NOME"   ,getSx3Cache("A6_NOME", "X3_TITULO")     ,getSx3Cache("A6_NOME", "X3_TIPO")   ,getSx3Cache("A6_NOME", "X3_TAMANHO")    ,getSx3Cache("A6_NOME", "X3_DECIMAL")    ,getSx3Cache("A6_NOME", "X3_PICTURE")  };
						    })
    
    oBPort:bGotFocus := {|| nBrwFocused := CONSULTA_PORTADOR}
    oCoWin03:Refresh( .T. ) 
    oBPort:Activate()

    //**************************************************
    // Sessão de filtros.
    //**************************************************

    oCoWin04 := oLayp01:GetWinPanel("L01C04","Win04","L01")

    oSize := FWDefSize():New(.F.)
	
    oSize:AddObject( "OBJ01"	, 50, 50, .T., .T. )
    oSize:AddObject( "OBJ02"	, 50, 50, .T., .T. )
    oSize:AddObject( "OBJ03"	, 50, 50, .T., .T. )
    oSize:AddObject( "OBJ04"	, 40, 50, .T., .T. )
    oSize:AddObject( "OBJ05"	, 40, 50, .T., .T. )
    oSize:AddObject( "OBJ06"	, 80, 50, .T., .T. )
    oSize:AddObject( "OBJ07"	, 80, 50, .T., .T. )
    oSize:AddObject( "OBJ08"	, 80, 50, .T., .T. )
    oSize:AddObject( "OBJ09"	, 80, 50, .T., .T. )
    
	//oSize:lLateral	:= .F. // Elementos um do lado do outro
	oSize:lProp		:= .T. // Cálculo dos botões proporcionais
    oSize:aMargins 	:= { 3, 3, 3, 3 }
	oSize:SetWindowSize({000, 000, oCoWin04:nHeight, oCoWin04:nWidth})
	oSize:Process() 		// executa os calculos
    

	oDTFATDE  := TGet():New(oSize:GetDimension("OBJ01","LININI"), oSize:GetDimension("OBJ01","COLINI")+2,{|u|If(PCount() == 0, dDTFATDE, dDTFATDE := u)},oCoWin04,oSize:GetDimension("OBJ01","XSIZE"),010,"",,0,16777215,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F. ,,"dDTFATDE",,,,.T.,,,"Data Inicial Faturamento",1) 
    oDTFATDE:lVisibleControl := .T.

    oDTFATATE  := TGet():New(oSize:GetDimension("OBJ02","LININI"), oSize:GetDimension("OBJ02","COLINI"),{|u|If(PCount() == 0, dDTFATATE, dDTFATATE := u)},oCoWin04,oSize:GetDimension("OBJ02","XSIZE"), 010,"",,0,16777215,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F. ,,"dDTFATATE",,,,.T.,,,"Data Final Faturamento",1)
    oDTFATATE:lVisibleControl := .T.
    
    oDtFINDE  := TGet():New(oSize:GetDimension("OBJ03","LININI"), oSize:GetDimension("OBJ03","COLINI"),{|u|If(PCount() == 0, dDtFINDE, dDtFINDE := u)},oCoWin04,oSize:GetDimension("OBJ03","XSIZE"), 010,"",,0,16777215,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F. ,,"dDtFINDE",,,,.T.,,,"Data Inicial Financeiro",1)
    oDtFINDE:lVisibleControl := .T.
    
    oDTFINATE   := TGet():New(oSize:GetDimension("OBJ04","LININI"), oSize:GetDimension("OBJ04","COLINI"),{|u|If(PCount() == 0, dDTFINATE, dDTFINATE := u)},oCoWin04,oSize:GetDimension("OBJ04","XSIZE"), 010,"",,0,16777215,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F. ,"","dDTFINATE",,,,.T.,,,"Data Final Financeiro",1)
    oDTFINATE:lVisibleControl := .T.

    aPLANFAT  := {"Ano","Mês","Dia"}
    oPLANFAT 	:= tComboBox():New(oSize:GetDimension("OBJ05","LININI"), oSize:GetDimension("OBJ05","COLINI"),{|u|if(PCount()>0,cPLANFAT:=u, cPLANFAT)},aPLANFAT,oSize:GetDimension("OBJ05","XSIZE"),010,oCoWin04,,{|| .T. },,,,.T.,,,,{|| .T.},,,,,'nPLANFAT', "Planilha Faturamento",1)
    oPLANFAT:lVisibleControl := .T.

    aPLANFIN := {"Ano","Mês","Dia"}
    oPLANFIN 	:= tComboBox():New(oSize:GetDimension("OBJ06","LININI"), oSize:GetDimension("OBJ06","COLINI"),{|u|if(PCount()>0, cPLANFIN:=u, cPLANFIN)},aPLANFIN,oSize:GetDimension("OBJ06","XSIZE"),010,oCoWin04,,{|| .T. },,,,.T.,,,,{|| .T.},,,,,'nPLANFIN', "Planilha Financeiro",1)
    oPLANFIN:lVisibleControl := .T.
    
    aTPRELAT := {"Rede","Cliente"}
    oTPRELAT 	:= tComboBox():New(oSize:GetDimension("OBJ07","LININI"), oSize:GetDimension("OBJ07","COLINI"),{|u|if(PCount()>0, cTPRELAT:=u, cTPRELAT)},aTPRELAT,oSize:GetDimension("OBJ07","XSIZE"),010,oCoWin04,,{|| .T. },,,,.T.,,,,{|| .T.},,,,,'nTPRELAT', "Tipo Relatório",1)
    oTPRELAT:lVisibleControl := .T.

    aRETZERO := {"Sim","Não"}
    oRETZERO 	:= tComboBox():New(oSize:GetDimension("OBJ08","LININI"), oSize:GetDimension("OBJ08","COLINI"),{|u|if(PCount()>0, cRETZERO:=u, cRETZERO)},aRETZERO,oSize:GetDimension("OBJ08","XSIZE"),010,oCoWin04,,{|| .T. },,,,.T.,,,,{|| .T.},,,,,'nRETZERO', "Retirar Zero",1)
    oRETZERO:lVisibleControl := .T.

    aRETNCC := {"Sim","Não"}
    oRETNCC 	:= tComboBox():New(oSize:GetDimension("OBJ09","LININI"), oSize:GetDimension("OBJ09","COLINI"),{|u|if(PCount()>0, cRETNCC:=u, cRETNCC)},aRETNCC,oSize:GetDimension("OBJ09","XSIZE"),010,oCoWin04,,{|| .T. },,,,.T.,,,,{|| .T.},,,,,'nRETNCC', "Retirar Col NCC Financeiro",1)
    oRETNCC:lVisibleControl := .T.
    
    //**************************************************
    // Opções.
    //**************************************************

    oCoWin05 := oLayp01:getWinPanel("L01C04","Win05","L01")
    oSize := FWDefSize():New(.F.)
	
    oSize:AddObject( "OBJ01"	, 100, 100, .T., .T. )
    //oSize:AddObject( "OBJ02"	, 50, 50, .T., .T. )
    
	oSize:lLateral	:= .T. // Elementos um do lado do outro
	oSize:lProp		:= .T. // Cálculo dos botões proporcionais
	oSize:SetWindowSize({000, 000, oCoWin05:nHeight, oCoWin05:nWidth})
	oSize:Process() 		// executa os calculos

	oButGera := TButton():New( 0, oSize:GetDimension("OBJ01","COLINI"), "Gera Relatório", oCoWin05,{|| filtros()}, oSize:GetDimension("OBJ01","XSIZE"),oSize:GetDimension("OBJ01","YSIZE"),,,.F.,.T.,.F.,,.F.,,,.F. )

return

Static Function fsetPanel2()
    
    oPanel02                    := TPanel():New(0,0,'',oL01C01,,,,,,0,0,,.T.)
    oPanel02:Align              := CONTROL_ALIGN_ALLCLIENT
    oPanel02:lVisibleControl    := .F.

    oLayp02 := FWLayer():new()
    oLayp02:init(oPanel02,.F.)
    oLayp02:addLine("L01",020, .F.)
    oLayp02:addLine("L02",080, .F.)
    oLayp02:addCollumn("L02C01", 100, .F., "L02")
    //oLayp02:addCollumn("L02C02", 040, .F., "L02")
    
    oLayp02:addWindow("L02C01", "Win01", "Painél Faturamento"   , 060,.F.,.F.,{||"" },"L02",{||""})
    oLayp02:addWindow("L02C01", "Win02", "Painél Financeiro"    , 040,.F.,.F.,{||"" },"L02",{||""})
    
    oLineTop     := oLayp02:GetLinePanel("L01")
    oGrid01     := tLinearLayout():New(oLineTop, LAYOUT_LINEAR_R2L ,CONTROL_ALIGN_ALLCLIENT)
    oGrid01:setCss(cLayCSS)

    //**************************************************
    // Cabeçalho Panel 01.
    //**************************************************

    oSayRede    := TSay():New( 0, 0, {|| "Rede"}   , oLineTop,,,,,,.T.,,,70,15)
    oGetRede    := TGet():New(000,000,{|u|If(PCount() == 0, cGetRede, cGetRede := u)},oLineTop,070,010, "",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cGetRede",,,,.T.,,,,1) 
    oGetRede:lVisibleControl := .T.

    oSayClie    := TSay():New( 0, 0, {|| "Cliente"}   , oLineTop,,,,,,.T.,,,70,15)
    oGetClie    := TGet():New(000,000,{|u|If(PCount() == 0, cGetClie, cGetClie := u)},oLineTop,070,010, "",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cGetClie",,,,.T.,,,,1) 
    oGetClie:lVisibleControl := .T.

    oBtnRet := TButton():New( 0, 0, "< Voltar"   , oLineTop,{|| fDblClick(PANEL02_VIEW) }, 25,15,,,.F.,.T.,.F.,,.F.,{|| .T.},,.F. )
    oSayEsp := TSay():New( 0, 0, {|| " "}   , oLineTop,,,,,,.T.,,,5,15)
    oBtnRet:setCss(cBtnCss)

    oGrid01:addInLayout(oSayEsp)
    oGrid01:addInLayout(oBtnRet)
    oGrid01:addInLayout(oGetClie)
    oGrid01:addInLayout(oSayClie)
    oGrid01:addInLayout(oGetRede)
    oGrid01:addInLayout(oSayRede)
    
    oGrid01:addSpacer(3)

    //**************************************************
    // Cabeçalho Panel 02 - Relatório Faturamento.
    //**************************************************

    /*
    aFatuCab		:= getCampos(CONSULTA_FATURAMENTO)
    aFatuDad		:= getDadosBrw(CONSULTA_FATURAMENTO)
    
    oItWin01 := oLayp02:GetWinPanel("L02C01","Win01","L02")

    oBFatu := FWBrowse():New(oItWin01)
    
    oBFatu:setColumns(aFatuCab)
	oBFatu:setDataArray()
	oBFatu:disableReport()
	oBFatu:disableConfig()
    oBFatu:setArray(aFatuDad)

    oBFatu:Activate()
    */
    //**************************************************
    // Cabeçalho Panel 02 - Relatório Financeiro.
    //**************************************************

    /*
    aFinaCab		:= getCampos(CONSULTA_FINANCEIRO)
    aFinaDad		:= getDadosBrw(CONSULTA_FINANCEIRO)
    
    oItWin02 := oLayp02:GetWinPanel("L02C01","Win02","L02")

    oBFina := FWBrowse():New(oItWin02)
    
    oBFina:setColumns(aPaHoCab)
	oBFina:setDataArray()
	oBFina:disableReport()
	oBFina:disableConfig()
    oBFina:setArray(aPaHoDad)
    
    oBFina:Activate()
    */
return


static function getCampos(nTypeBrowse)
	local aCpoRet	:= {}
    local aCampos   := {}
	local nCampos   := 0
    local nX        := 0

	if nTypeBrowse == CONSULTA_REDES
		aCampos		:= strToKarr(CONSULTA_REDES_CAMPOS , ",")
        aRedeCab    := {}
        aRedeCam    := aClone(aCampos)

        aAdd(aRedeCam, "MARCA")

        nRedeCam   := Len(aRedeCam)
        
    Elseif nTypeBrowse == CONSULTA_CLIENTES
        aCampos		:= strToKarr(CONSULTA_CLIENTES_CAMPOS, ",")
        aClieCab    := {}
        aClieCam    := aClone(aCampos)

        aAdd(aClieCam, "MARCA")

        nClieCam   := Len(aClieCam)

    Elseif nTypeBrowse == CONSULTA_PORTADOR
        aCampos		:= strToKarr(CONSULTA_PORTADOR_CAMPOS, ",")
        aPortCab    := {}
        aPortCam    := aClone(aCampos)

        aAdd(aPortCam, "MARCA")

        nPortCam   := Len(aPortCam)
    endIf

    nCampos := Len(aCampos)

    nCampos := Len(aCampos)
	for nX := 1 to nCampos
		cCampo	:= Alltrim(aCampos[nX])
        
        if nTypeBrowse == CONSULTA_REDES
            cValue := "{|| aRedeDad[oBRede:At(), " + cValToChar(nX) + "]}"
		    //aAdd(aExpoCab, cCampo)
        Elseif nTypeBrowse == CONSULTA_CLIENTES
            cValue := "{|| aClieDad[oBClie:At(), " + cValToChar(nX) + "]}"
		    //aAdd(aItExCab, cCampo)
        Elseif nTypeBrowse == CONSULTA_PORTADOR
            cValue := "{|| aPortDad[oBPort:At(), " + cValToChar(nX) + "]}"
		    //aAdd(aPaHoCab, cCampo)
        endif

		oColumn := FWBrwColumn():New()
		oColumn:SetData(&(cValue))
        cTitulo := getSx3Cache(cCampo, "X3_TITULO")
        
        if Alltrim(cCampo) == "A1_COD"
		    oColumn:SetTitle("Cód")
		    oColumn:SetSize(05)
            oColumn:SetType("C")
        elseif Alltrim(cCampo) == "A1_LOJA"
		    oColumn:SetTitle("Lj.")
		    oColumn:SetSize(03)
            oColumn:SetType("C")
        elseif Alltrim(cCampo) == "A6_COD"
		    oColumn:SetTitle("Código")
		    oColumn:SetSize(06)
            oColumn:SetType("C")
        elseif Alltrim(cCampo) == "ZF_REDE"
		    oColumn:SetTitle("Rede")
		    oColumn:SetSize(06)
            oColumn:SetType("C")
        elseif Alltrim(cCampo)$"A6_NOME,A1_NOME"
		    oColumn:SetTitle(getSx3Cache(cCampo, "X3_TITULO"))
            oColumn:SetSize(18)
            oColumn:SetType("C")
        elseif Alltrim(cCampo)$"ZF_NOMERED"
		    oColumn:SetTitle(getSx3Cache(cCampo, "X3_TITULO"))
            oColumn:SetSize(23)
            oColumn:SetType("C")
        else
            oColumn:SetTitle(getSx3Cache(cCampo,"X3_TITULO"))
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


    if nTypeBrowse == CONSULTA_REDES
        aCampos := strToKarr(CONSULTA_REDES_CAMPOS, ",")
        cCampos := CONSULTA_REDES_CAMPOS

        cQuery := " SELECT  ZF.ZF_REDE, ZF.ZF_NOMERED " +cQebra
        cQuery += " FROM " +cQebra
        cQuery += "   (SELECT ZF_FILIAL, ZF_REDE, MIN(R_E_C_N_O_) REGISTRO " +cQebra
        cQuery += "    FROM "+ RetSqlName("SZF") +" WITH (NOLOCK) " +cQebra
        cQuery += "    WHERE D_E_L_E_T_ <> '*' " +cQebra
        cQuery += "    GROUP BY ZF_FILIAL, ZF_REDE) A INNER JOIN "+ RetSqlName("SZF") +" ZF WITH (NOLOCK) ON ZF.D_E_L_E_T_='' AND A.ZF_FILIAL=ZF.ZF_FILIAL AND A.REGISTRO=ZF.R_E_C_N_O_ " +cQebra
        cQuery += "    ORDER BY ZF_REDE "
        
        nRedeReg  := 0
    elseif nTypeBrowse == CONSULTA_CLIENTES
        aCampos := strToKarr(CONSULTA_CLIENTES_CAMPOS, ",")
        cCampos := CONSULTA_CLIENTES_CAMPOS

        cQuery := " SELECT  "+ CONSULTA_CLIENTES_CAMPOS +" " +cQebra
        cQuery += " FROM "+ RetSqlName("SA1") +" (NOLOCK) A1 " +cQebra
        cQuery += " WHERE A1.D_E_L_E_T_='' AND A1.A1_FILIAL='"+ xFilial("SA1") +"' AND A1.A1_MSBLQL != '1' " +cQebra 
        cQuery += " ORDER BY A1.A1_COD, A1.A1_LOJA; "

        nClieReg  := 0
    elseif nTypeBrowse == CONSULTA_PORTADOR
        aCampos := strToKarr(CONSULTA_PORTADOR_CAMPOS, ",")
        cCampos := CONSULTA_PORTADOR_CAMPOS

        cQuery := " SELECT  A6.A6_COD, A6.A6_NOME " +cQebra
        cQuery += " FROM " +cQebra
        cQuery += "   (SELECT A6_FILIAL, A6_COD, MAX(R_E_C_N_O_) REGISTRO " +cQebra
        cQuery += "    FROM "+ RetSqlName("SA6") +" WITH (NOLOCK) " +cQebra
        cQuery += "    WHERE D_E_L_E_T_ <> '*' AND LEFT(A6_NOME,1)!='.' " +cQebra
        cQuery += "    GROUP BY A6_FILIAL, A6_COD) A INNER JOIN "+ RetSqlName("SA6") +" A6 WITH (NOLOCK) ON A6.D_E_L_E_T_='' AND A.A6_FILIAL=A6.A6_FILIAL AND A.REGISTRO=A6.R_E_C_N_O_ " +cQebra
        cQuery += " UNION ALL " +cQebra
        cQuery += " SELECT  '' A6_COD, 'SEM PORTADOR' A6_NOME " +cQebra
        cQuery += "    ORDER BY A6_COD "

        nPortReg  := 0
    endif

	tcQuery cQuery new alias &cAlias

	(cAlias)->(DbGoTop())

	if (cAlias)-> (!eof())

		While (cAlias)->(!eof())
			aDado := {}

            for nX := 1 to Len(aCampos)
                if Alltrim(aCampos[nX]) == "EE8FRUNIT"
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
                    if Alltrim(aCampos[nX]) == "A6_NOME"
                        cValor := (cAlias)-> &(aCampos[nX])

                        if Empty(cValor)
                            aAdd(aDado, "SEM PORTADOR")
                        else
                            aAdd(aDado, (cAlias)-> &(aCampos[nX]))
                        endif        
                    else
                        aAdd(aDado, (cAlias)-> &(aCampos[nX]))
                    endif
                endif
                
            next nX

            if nTypeBrowse == CONSULTA_PORTADOR
                aAdd(aDado, .T.)
            else
                aAdd(aDado, .F.)
            endif

			aAdd(aDados, aDado)

            if nTypeBrowse == CONSULTA_REDES
                nRedeReg += 1
            elseif nTypeBrowse == CONSULTA_CLIENTES
                nClieReg += 1
            elseif nTypeBrowse == CONSULTA_PORTADOR
                nPortReg += 1
            endif

			(cAlias)->(DbSkip())
		EndDo
	endIf

return(aDados)

static function fFiltra(oSeek, oBrowse)
	Local cFiltro	:= oSeek:getSeek()
	Local nPosRet	:= 1
    Private nOrder	:= oSeek:getOrder()

    nPosRet := aScan(oBrowse:oData:aArray, {|x| Upper(allTrim(cFiltro)) $ Upper(x[nOrder])})
    
	if nPosRet == 0
        Msginfo("Não foi encontrado nenhum registro!")
		nPosRet := 1
	endIf

return(nPosRet)


Static Function fMark(oBrowse)
    Local cRet := "LBNO"

    if Val(oBrowse:getProfileID()) == CONSULTA_REDES
        cRet := IIf(aRedeDad[oBRede:At(), nRedeCam],'LBOK','LBNO')
    elseif Val(oBrowse:getProfileID()) == CONSULTA_CLIENTES
        cRet := IIf(aClieDad[oBClie:At(), nClieCam],'LBOK','LBNO')
    Elseif Val(oBrowse:getProfileID()) == CONSULTA_PORTADOR
        cRet := IIf(aPortDad[oBPort:At(), nPortCam],'LBOK','LBNO')
    endif

return cRet

Static Function fDblClk(oBrowse)
    Local lRet      := .T.
    
    //IF !(oBrowse:isEmpty()) .and. oBrowse:at() > 0
        if nBrwFocused == CONSULTA_REDES
            if oBRede:At() > 0
                aRedeDad[oBRede:At(), nRedeCam] := IIf(aRedeDad[oBRede:At(), nRedeCam],.F.,.T.)
            endif
        elseif nBrwFocused == CONSULTA_CLIENTES
            if oBClie:At() > 0
                aClieDad[oBClie:At(), nClieCam] := IIf(aClieDad[oBClie:At(), nClieCam],.F.,.T.)
            endif
        Elseif nBrwFocused == CONSULTA_PORTADOR
            if oBPort:At() > 0
                aPortDad[oBPort:At(), nPortCam] := IIf(aPortDad[oBPort:At(), nPortCam],.F.,.T.)
            endif
        endif          
    //endif
return lRet


Static Function fHeaClk(oBrowse)
    Local lRet 	:= .T.
	Local nA	:= 0

	 if nBrwFocused == CONSULTA_REDES
		for nA := 1 to nRedeReg
			aRedeDad[nA, nRedeCam] := IIf(aRedeDad[nA, nRedeCam],.F.,.T.)
		next nA
    
    elseif nBrwFocused == CONSULTA_CLIENTES
    	for nA := 1 to nClieReg
			aClieDad[nA, nClieCam] := IIf(aClieDad[nA, nClieCam],.F.,.T.)
		next nA
    Elseif nBrwFocused == CONSULTA_PORTADOR
    	for nA := 1 to nPortReg
			aPortDad[nA, nPortCam] := IIf(aPortDad[nA, nPortCam],.F.,.T.)
		next nA
    endif 
	
	oBrowse:refresh()
return lRet


/*/{Protheus.doc} Static Function filtros
	Aplica filtros. 
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function filtros()

	Local aArea		:= GetArea()
    Local nA        := 1
    Local nPRedOk   := aScan(aRedeCam, "MARCA")
    Local nPRedRe   := aScan(aRedeCam, "ZF_REDE")
    Local nPRedNo   := aScan(aRedeCam, "ZF_NOMERED")
    Local nPCliOk   := aScan(aClieCam, "MARCA")
    Local nPCliCo   := aScan(aClieCam, "A1_COD")
    Local nPCliNo   := aScan(aClieCam, "A1_NOME")
    Local nPPorOk   := aScan(aPortCam, "MARCA")
    Local nPPorCo   := aScan(aPortCam, "A6_COD")

    Private oCobranca
    Private oPnlFilt1
    Private oMkRede
    Private oMkFxPort

	//lHistFilt1  := .F.

	//Filtro de rede.
    cFiltRede := ""
	cFiltRedeR:= ""
	aHistRede := {}

	If nRedeReg > 0

        for nA := 1 TO nRedeReg

            lRedeOk     := aRedeDad[nA, nPRedOk]
            cRedCod     := Alltrim(cValtochar(aRedeDad[nA, nPRedRe]))
            

            If !lRedeOk .And. ! Empty(cRedCod)
                cFiltRede += "'" + cRedCod + "',"

            ElseIf lRedeOk .And. ! Empty(cRedCod)
                cFiltRedeR += "'" + cRedCod + "',"
                cRedeNome := Alltrim(aRedeDad[nA, nPRedNo])
                Aadd(aHistRede,{ cRedCod })

            EndIf
		Next nA
        
			If Empty(cFiltRede)
				cFiltRede := "''"
            else
                cFiltRede := Substr(cFiltRede,1,Len(cFiltRede) - 1)
			EndIf

			If Empty(cFiltRedeR)
				cFiltRedeR:= "''"
            else
                cFiltRedeR:= Substr(cFiltRedeR,1,Len(cFiltRedeR) - 1)
			EndIf
    else
        cFiltRede   := "''"
		cFiltRedeR  := "''"
	EndIf

	//Filtro de Cliente.
    cFiltCli := ""
    cFiltCliR:= ""
    aHisTCli := {}
	
    If nClieReg > 0

		for nA := 1 TO nClieReg
            lClieOk     := aClieDad[nA, nPCliOk]
            cCliCod     := Alltrim(cValtochar(aClieDad[nA, nPCliCo]))

				If !lClieOk .And. ! Empty(cCliCod)
					cFiltCli += "'" + cCliCod + "',"

				ElseIf lClieOk .And. ! Empty(cCliCod)

					cFiltCliR += "'" + cCliCod + "',"
                    cClieNome := Alltrim(aRedeDad[nA, nPCliNo])
					Aadd(aHisTCli,{ cCliCod })

				EndIf

		next nA

        If Empty(cFiltCli)
            cFiltCli := "''"
        else
            cFiltCli := Substr(cFiltCli,1,Len(cFiltCli) - 1)
        EndIf

        If Empty(cFiltCliR)
            cFiltCliR:= "''"
        else
            cFiltCliR:= Substr(cFiltCliR,1,Len(cFiltCliR) - 1)
        EndIf

    else
        cFiltCli    := "''"
		cFiltCliR   := "''"
	EndIf

	//Filtro de Portador.
	cFiltPortad := ""
	aHistPortad := {}

	If nPortReg > 0
		
		for nA := 1 to nPortReg
            lPortOk     := aPortDad[nA, nPPorOk]
            cPorCod     := Alltrim(cValtochar(aPortDad[nA, nPPorCo]))

				If lPortOk 
					cFiltPortad += "'" + cPorCod + "',"
					Aadd(aHistPortad,{ cPorCod })

				EndIf

		Next nA

        If Empty(cFiltPortad)
            cFiltPortad := "''"
        else
            cFiltPortad := Substr(cFiltPortad,1,Len(cFiltPortad) - 1)
        EndIf

    else
        cFiltPortad := "''"
	EndIf


	//Carrega Relatorio.
	MsAguarde({|| geraRelatorio() },"Aguarde","Carregando dados...")

	RestArea(aArea)

Return Nil

Static Function geraRelatorio()

	LOCAL aArea	      := GetArea()
	LOCAL oRelatorio  := NIL
	LOCAL oFecharRel  := NIL
	LOCAL oBrowseFat  := NIL
	LOCAL oBrowseFin  := NIL
	LOCAL oPanelFat   := NIL
	LOCAL oPanelFin   := NIL
	LOCAL nTotfatNf   := 0
	LOCAL nTotfatNcc  := 0
	LOCAL nTotfat     := 0
	LOCAL nTotfinNf   := 0
	LOCAL nTotfinNcc  := 0
	LOCAL nTotfin     := 0
	Local oFontRel    := TFont():New('Courier new',,-18,.T.)
	Local oSayplanfat := NIL
	Local oSayplanfin := NIL
	Local oSayNome    := NIL
	Local cCnpjs      := ''
	Local cAno        := ''
	Local cAnoOld     := ''
	Local cMes        := ''
	Local cMesOld     := ''

    Private dDtIniFat   := dDTFATDE
    Private dDtFinFat   := dDTFATATE
    Private dDtIniFin   := dDTFINDE
    Private dDtFinFin   := dDTFINATE

    Private lFiltroZero := iif(nRETZERO==2,.T., .F.)
    Private lRetirarNCC := iif(nRETNCC ==2,.T., .F.)
    Private nTipoRel    := nTPRELAT
	// *** INICIO VALIDACAO *** //

	IF nTipoRel == 1 .AND. ALLTRIM(cFiltRedeR) == "''"

		MSGALERT("Não foi escolhida nenhuma rede, impossivel continuar", "geraRelatorio")
		Return .F.

	ENDIF	

	IF nTipoRel == 2 .AND. ALLTRIM(cFiltCliR) == "''"

		MSGALERT("Não foi escolhida nenhum Cliente, impossivel continuar", "geraRelatorio")
		Return .F.

	ENDIF	

	// *** FINAL VALIDACAO *** //
	
	// INICIO FATURAMENTO

	oTempFat := FWTemporaryTable():New("TEMPFAT")

	// INICIO Monta os campos da tabela
	aCampos := {}
	AADD(aCampos,{"TM_DATA" ,"C",11,0})	
	AADD(aCampos,{"TM_ANO"  ,"C",04,0})
	AADD(aCampos,{"TM_NF"	,"N",17,2})
	AADD(aCampos,{"TM_NCC"  ,"N",17,2})
	AADD(aCampos,{"TM_TOTAL","N",17,2})
	AADD(aCampos,{"TM_MEDIA","N",17,2})
	AADD(aCampos,{"TM_PMV"  ,"N",08,2})
	AADD(aCampos,{"TM_PMVP" ,"N",08,2})
	AADD(aCampos,{"TM_KG"   ,"N",17,2})

	// FINAL Monta os campos da tabela
    
	oTempFat:SetFields(aCampos)
	//oTempFat:AddIndex("01", {"TM_DATA"} )
	
	//------------------
	//Criação da tabela
	//------------------
	oTempFat:Create()
	
	//Obtém o script sql para os CNPJS.
	cQuery := sqlCNPJ(nTipoRel,IIF(nTipoRel == 1,cFiltRedeR,cFiltCliR))
	
	IF EMPTY(cQuery)

		RESTAREA(aArea)
		RETURN .F.

	ENDIF

	IF SELECT("D_CNPJREDE") > 0

		D_CNPJREDE->(DBCLOSEAREA())

	ENDIF

	TCQUERY cQuery NEW ALIAS "D_CNPJREDE"

	DBSELECTAREA("D_CNPJREDE")
	D_CNPJREDE->(DBGOTOP())
	WHILE !D_CNPJREDE->(EOF())
		
		cCnpjs := cCnpjs + "'" + ALLTRIM(D_CNPJREDE->A1_CGC) + "',"

		D_CNPJREDE->(DBSKIP())

	ENDDO

	cCnpjs := Substr(cCnpjs,1,Len(cCnpjs) - 1)

	//Obtém o script sql.
	cQuery := sqlFat(cCnpjs)
	
	IF EMPTY(cQuery)

		RESTAREA(aArea)
		RETURN .F.

	ENDIF

	IF SELECT("D_FATURAMENTO") > 0

		D_FATURAMENTO->(DBCLOSEAREA())

	ENDIF

	TCQUERY cQuery NEW ALIAS "D_FATURAMENTO"
	
	nTotfatNf  := 0
	nTotfatNcc := 0
	nTotfat    := 0
	cAno       := ''
	cAnoOld    := ''
	cMes       := ''
	cMesOld    := ''

	DBSELECTAREA("D_FATURAMENTO")
	D_FATURAMENTO->(DBGOTOP())

	IF nplanfat == 2 // mês

		cAno    := CVALTOCHAR(D_FATURAMENTO->ANO)
		cAnoOld := CVALTOCHAR(D_FATURAMENTO->ANO)

	ENDIF
	
	IF nplanfat == 3 // dia	

		cAno    := SUBSTR(D_FATURAMENTO->E1_EMISSAO,1,4)
		cAnoOld := SUBSTR(D_FATURAMENTO->E1_EMISSAO,1,4)
		cMes    := SUBSTR(D_FATURAMENTO->E1_EMISSAO,5,2)
		cMesOld := SUBSTR(D_FATURAMENTO->E1_EMISSAO,5,2)

	ENDIF

	WHILE !D_FATURAMENTO->(EOF())

		IF lFiltroZero == .T. .AND. D_FATURAMENTO->TOTAL == 0

			D_FATURAMENTO->(DBSKIP())
			LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

		ENDIF

		IF nplanfat == 2 // mês

			cAno        := CVALTOCHAR(D_FATURAMENTO->ANO)

			IF  cAnoOld <> cAno

				cQuery:= SqlAnoFat(cCnpjs,cAnoOld)

				TCQUERY cQuery NEW ALIAS "D_ANOFAT"

				WHILE !D_ANOFAT->(EOF())

					IF lFiltroZero == .T. .AND. D_ANOFAT->TOTAL == 0

						D_ANOFAT->(DBSKIP())
						LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

					ENDIF

					RECLOCK("TEMPFAT",.T.)

						TEMPFAT->TM_DATA  := "ANO " + cAnoOld
						TEMPFAT->TM_ANO   := cAnoOld
						TEMPFAT->TM_NF    := D_ANOFAT->NF
						TEMPFAT->TM_NCC   := D_ANOFAT->NCC
						TEMPFAT->TM_MEDIA := 0
						TEMPFAT->TM_PMV   := PrazoMedia(cAnoOld,'FAT','ANO','VENDA',cCnpjs)
						TEMPFAT->TM_PMVP  := PrazoMedia(cAnoOld,'FAT','ANO','PONDERADA',cCnpjs)
						TEMPFAT->TM_TOTAL := D_ANOFAT->TOTAL
						TEMPFAT->TM_KG    := 0
						
					MSUNLOCK()

					D_ANOFAT->(DBSKIP())

				ENDDO	
				D_ANOFAT->(DBCLOSEAREA())

				cAnoOld     := cAno

			ENDIF
		ENDIF

		IF nplanfat == 3 // dia	

			cMes :=  SUBSTR(D_FATURAMENTO->E1_EMISSAO,5,2)

			IF  cMesOld <> cMes

				cQuery:= SqlMesFat(cCnpjs,cAnoOld,cMesOld)

				TCQUERY cQuery NEW ALIAS "D_MESFAT"

				WHILE !D_MESFAT->(EOF())

					IF lFiltroZero == .T. .AND. D_MESFAT->TOTAL == 0

						D_MESFAT->(DBSKIP())
						LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

					ENDIF

					RECLOCK("TEMPFAT",.T.)

						TEMPFAT->TM_DATA  := "MÊS " + cMesOld
						TEMPFAT->TM_ANO   := cAnoOld
						TEMPFAT->TM_NF    := D_MESFAT->NF
						TEMPFAT->TM_NCC   := D_MESFAT->NCC
						TEMPFAT->TM_MEDIA := 0
						TEMPFAT->TM_PMV   := PrazoMedia(cAnoOld + '/' + cMesOld,'FAT','MES','VENDA',cCnpjs)
						TEMPFAT->TM_PMVP  := PrazoMedia(cAnoOld + '/' + cMesOld,'FAT','MES','PONDERADA',cCnpjs)
						TEMPFAT->TM_TOTAL := D_MESFAT->TOTAL
						TEMPFAT->TM_KG    := 0

					MSUNLOCK()

					D_MESFAT->(DBSKIP())

				ENDDO	
				D_MESFAT->(DBCLOSEAREA())

				cMesOld := cMes

			ENDIF

			cAno :=  SUBSTR(D_FATURAMENTO->E1_EMISSAO,1,4)

			IF  cAnoOld <> cAno

				cQuery:= SqlAnoFat(cCnpjs,cAnoOld)

				TCQUERY cQuery NEW ALIAS "D_ANOFAT"

				WHILE !D_ANOFAT->(EOF())

					IF lFiltroZero == .T. .AND. D_ANOFAT->TOTAL == 0

						D_ANOFAT->(DBSKIP())
						LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

					ENDIF

					RECLOCK("TEMPFAT",.T.)

						TEMPFAT->TM_DATA  := "ANO " + cAnoOld
						TEMPFAT->TM_ANO   := cAnoOld
						TEMPFAT->TM_NF    := D_ANOFAT->NF
						TEMPFAT->TM_NCC   := D_ANOFAT->NCC
						TEMPFAT->TM_MEDIA := 0
						TEMPFAT->TM_PMV   := PrazoMedia(cAnoOld,'FAT','ANO','VENDA',cCnpjs)
						TEMPFAT->TM_PMVP  := PrazoMedia(cAnoOld,'FAT','ANO','PONDERADA',cCnpjs)
						TEMPFAT->TM_TOTAL := D_ANOFAT->TOTAL
						TEMPFAT->TM_KG    := 0

					MSUNLOCK()

					D_ANOFAT->(DBSKIP())

				ENDDO	
				D_ANOFAT->(DBCLOSEAREA())

				cAnoOld     := cAno

			ENDIF

		ENDIF
		
		RECLOCK("TEMPFAT",.T.)

			IF nplanfat == 1 // ano

				TEMPFAT->TM_DATA  := CVALTOCHAR(D_FATURAMENTO->ANO)
				TEMPFAT->TM_ANO   := CVALTOCHAR(D_FATURAMENTO->ANO)

			ELSEIF nplanfat == 2 // mês

				TEMPFAT->TM_DATA  := CVALTOCHAR(D_FATURAMENTO->ANO) + '/' + STRZERO(D_FATURAMENTO->MES,2)
				TEMPFAT->TM_ANO   := CVALTOCHAR(D_FATURAMENTO->ANO)

			ELSE // dia	

				TEMPFAT->TM_DATA  := DTOC(STOD(D_FATURAMENTO->E1_EMISSAO))
				TEMPFAT->TM_ANO   := CVALTOCHAR(YEAR(STOD(D_FATURAMENTO->E1_EMISSAO)))

			ENDIF

			TEMPFAT->TM_NF    := D_FATURAMENTO->NF
			nTotfatNf         := nTotfatNf + D_FATURAMENTO->NF
			TEMPFAT->TM_NCC   := D_FATURAMENTO->NCC
			nTotfatNcc        := nTotfatNcc + D_FATURAMENTO->NCC
			TEMPFAT->TM_MEDIA := 0
			TEMPFAT->TM_PMV   := PrazoMedia(TEMPFAT->TM_DATA,'FAT','NORMAL','VENDA',cCnpjs)
			TEMPFAT->TM_PMVP  := PrazoMedia(TEMPFAT->TM_DATA,'FAT','NORMAL','PONDERADA',cCnpjs)
			TEMPFAT->TM_TOTAL := D_FATURAMENTO->TOTAL
			nTotfat           := nTotfat + D_FATURAMENTO->TOTAL
			TEMPFAT->TM_KG    := 0
		
		MSUNLOCK()

		D_FATURAMENTO->(DBSKIP())

	ENDDO
    
	// *** INICIO TOTAIS FATURAMENTO 
	IF nplanfat == 2 // mês

		cQuery:= SqlAnoFat(cCnpjs,cAnoOld)

		TCQUERY cQuery NEW ALIAS "D_ANOFAT"

		WHILE !D_ANOFAT->(EOF())

			IF lFiltroZero == .T. .AND. D_ANOFAT->TOTAL == 0

				D_ANOFAT->(DBSKIP())
				LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

			ENDIF

			RECLOCK("TEMPFAT",.T.)

				TEMPFAT->TM_DATA  := "ANO " + cAnoOld
				TEMPFAT->TM_ANO   := cAnoOld
				TEMPFAT->TM_NF    := D_ANOFAT->NF
				TEMPFAT->TM_NCC   := D_ANOFAT->NCC
				TEMPFAT->TM_MEDIA := 0
				TEMPFAT->TM_PMV   := PrazoMedia(cAnoOld,'FAT','ANO','VENDA',cCnpjs)
				TEMPFAT->TM_PMVP  := PrazoMedia(cAnoOld,'FAT','ANO','PONDERADA',cCnpjs)
				TEMPFAT->TM_TOTAL := D_ANOFAT->TOTAL
				TEMPFAT->TM_KG    := 0

			MSUNLOCK()

			D_ANOFAT->(DBSKIP())

		ENDDO	
		D_ANOFAT->(DBCLOSEAREA())
	
	ENDIF

	IF nplanfat == 3 // dia	

		cMes :=  SUBSTR(D_FATURAMENTO->E1_EMISSAO,5,2)

		IF  cMesOld <> cMes

			cQuery:= SqlMesFat(cCnpjs,cAnoOld,cMesOld)

			TCQUERY cQuery NEW ALIAS "D_MESFAT"

			WHILE !D_MESFAT->(EOF())

				IF lFiltroZero == .T. .AND. D_MESFAT->TOTAL == 0

					D_MESFAT->(DBSKIP())
					LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

				ENDIF

				RECLOCK("TEMPFAT",.T.)

					TEMPFAT->TM_DATA  := "MÊS " + cMesOld
					TEMPFAT->TM_ANO   := cAnoOld
					TEMPFAT->TM_NF    := D_MESFAT->NF
					TEMPFAT->TM_NCC   := D_MESFAT->NCC
					TEMPFAT->TM_MEDIA := 0
					TEMPFAT->TM_PMV   := PrazoMedia(cAnoOld + '/' + cMesOld,'FAT','MES','VENDA',cCnpjs)
					TEMPFAT->TM_PMVP  := PrazoMedia(cAnoOld + '/' + cMesOld,'FAT','MES','PONDERADA',cCnpjs)
					TEMPFAT->TM_TOTAL := D_MESFAT->TOTAL
					TEMPFAT->TM_KG    := 0

				MSUNLOCK()
				
				D_MESFAT->(DBSKIP())

			ENDDO	
			D_MESFAT->(DBCLOSEAREA())

			cMesOld := cMes

		ENDIF

		cAno :=  SUBSTR(D_FATURAMENTO->E1_EMISSAO,1,4)

		IF  cAnoOld <> cAno

			cQuery:= SqlAnoFat(cCnpjs,cAnoOld)

			TCQUERY cQuery NEW ALIAS "D_ANOFAT"

			WHILE !D_ANOFAT->(EOF())

				IF lFiltroZero == .T. .AND. D_ANOFAT->TOTAL == 0

					D_ANOFAT->(DBSKIP())
					LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

				ENDIF

					RECLOCK("TEMPFAT",.T.)

						TEMPFAT->TM_DATA  := "ANO " + cAnoOld
						TEMPFAT->TM_ANO   := cAnoOld
						TEMPFAT->TM_NF    := D_ANOFAT->NF
						TEMPFAT->TM_NCC   := D_ANOFAT->NCC
						TEMPFAT->TM_MEDIA := 0
						TEMPFAT->TM_PMV   := PrazoMedia(cAnoOld,'FAT','ANO','VENDA',cCnpjs)
						TEMPFAT->TM_PMVP  := PrazoMedia(cAnoOld,'FAT','ANO','PONDERADA',cCnpjs)
						TEMPFAT->TM_TOTAL := D_ANOFAT->TOTAL
						TEMPFAT->TM_KG    := 0

					MSUNLOCK()

				D_ANOFAT->(DBSKIP())

			ENDDO	
			D_ANOFAT->(DBCLOSEAREA())

			cAnoOld     := cAno

		ENDIF

	ENDIF

	RECLOCK("TEMPFAT",.T.)

		TEMPFAT->TM_DATA  := 'TOTAL GERAL'
		TEMPFAT->TM_ANO   := ''
		TEMPFAT->TM_NF    := nTotfatNf
		TEMPFAT->TM_NCC   := nTotfatNcc
		TEMPFAT->TM_MEDIA := 0
		TEMPFAT->TM_PMV   := PrazoMedia(DTOC(dDtIniFat),'FAT','TOTAL','VENDA',cCnpjs)
		TEMPFAT->TM_PMVP  := PrazoMedia(DTOC(dDtIniFat),'FAT','TOTAL','PONDERADA',cCnpjs)
		TEMPFAT->TM_TOTAL := nTotfat
		TEMPFAT->TM_KG    := 0
	
	MSUNLOCK()

	// *** FINAL TOTAIS FATURAMENTO 

	// FINAL FATURAMENTO
	
	//INICIO FINANCEIRO
	//Cria Arquivos Temporários

	oTempFin := FWTemporaryTable():New("TEMPFIN")

	// INICIO Monta os campos da tabela
	aCampos := {}
	AADD(aCampos,{"TM_DATA" ,"C",11,0})	
	AADD(aCampos,{"TM_NF"	,"N",17,2})
	AADD(aCampos,{"TM_NCC"  ,"N",17,2})
	AADD(aCampos,{"TM_TOTAL","N",17,2})

	// FINAL Monta os campos da tabela
    
	oTempFin:SetFields(aCampos)
	//oTempFin:AddIndex("01", {"TM_DATA"} )
	
	//------------------
	//Criação da tabela
	//------------------
	oTempFin:Create()

	//Obtém o script sql.
	cQuery := sqlFin(cCnpjs)
	
	IF EMPTY(cQuery)

		RESTAREA(aArea)
		RETURN .F.

	ENDIF

	IF SELECT("D_FINANCEIRO") > 0

		D_FINANCEIRO->(DBCLOSEAREA())

	ENDIF

	TCQUERY cQuery NEW ALIAS "D_FINANCEIRO"
	
	nTotfinNf  := 0
	nTotfinNcc := 0
	nTotfin    := 0
	cAno       := ''
	cAnoOld    := ''
	cMes       := ''
	cMesOld    := ''

	DBSELECTAREA("D_FINANCEIRO")
	D_FINANCEIRO->(DBGOTOP())

	IF nplanfin == 2 // mês

		cAno    := CVALTOCHAR(D_FINANCEIRO->ANO)
		cAnoOld := CVALTOCHAR(D_FINANCEIRO->ANO)

	ENDIF
	
	IF nplanfin == 3 // dia	

		cAno    := SUBSTR(D_FINANCEIRO->E1_VENCREA,1,4)
		cAnoOld := SUBSTR(D_FINANCEIRO->E1_VENCREA,1,4)
		cMes    := SUBSTR(D_FINANCEIRO->E1_VENCREA,5,2)
		cMesOld := SUBSTR(D_FINANCEIRO->E1_VENCREA,5,2)

	ENDIF

	WHILE !D_FINANCEIRO->(EOF())

		IF lFiltroZero == .T. .AND. D_FINANCEIRO->TOTAL == 0

			D_FINANCEIRO->(DBSKIP())
			LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

		ENDIF

		IF nplanfin == 2 // mês

			cAno := CVALTOCHAR(D_FINANCEIRO->ANO)

			IF  cAnoOld <> cAno

				cQuery:= SqlAnoFin(cCnpjs,cAnoOld)

				TCQUERY cQuery NEW ALIAS "D_ANOFIN"

				WHILE !D_ANOFIN->(EOF())

					IF lFiltroZero == .T. .AND. D_ANOFIN->TOTAL == 0

						D_ANOFIN->(DBSKIP())
						LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

					ENDIF

					RECLOCK("TEMPFIN",.T.)

						TEMPFIN->TM_DATA  := "ANO " + cAnoOld
						TEMPFIN->TM_NF    := D_ANOFIN->NF
						TEMPFIN->TM_NCC   := D_ANOFIN->NCC
						TEMPFIN->TM_TOTAL := D_ANOFIN->TOTAL

					MSUNLOCK()

					D_ANOFIN->(DBSKIP())

				ENDDO	
				D_ANOFIN->(DBCLOSEAREA())

				cAnoOld := cAno

			ENDIF
		ENDIF

		IF nplanfin == 3 // dia	

			cMes :=  SUBSTR(D_FINANCEIRO->E1_VENCREA,5,2)

			IF  cMesOld <> cMes

				cQuery:= SqlMesFin(cCnpjs,cAnoOld,cMesOld)

				TCQUERY cQuery NEW ALIAS "D_MESFIN"

				WHILE !D_MESFIN->(EOF())

					IF lFiltroZero == .T. .AND. D_MESFIN->TOTAL == 0

						D_MESFIN->(DBSKIP())
						LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

					ENDIF

					RECLOCK("TEMPFIN",.T.)

						TEMPFIN->TM_DATA  := "MÊS " + cMesOld
						TEMPFIN->TM_NF    := D_MESFIN->NF
						TEMPFIN->TM_NCC   := D_MESFIN->NCC
						TEMPFIN->TM_TOTAL := D_MESFIN->TOTAL

					MSUNLOCK()

					D_MESFIN->(DBSKIP())

				ENDDO	
				D_MESFIN->(DBCLOSEAREA())

				cMesOld := cMes

			ENDIF

			cAno := SUBSTR(D_FINANCEIRO->E1_VENCREA,1,4)

			IF  cAnoOld <> cAno

				cQuery:= SqlAnoFin(cCnpjs,cAnoOld)

				TCQUERY cQuery NEW ALIAS "D_ANOFIN"

				WHILE !D_ANOFIN->(EOF())

					IF lFiltroZero == .T. .AND. D_ANOFIN->TOTAL == 0

						D_ANOFIN->(DBSKIP())
						LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

					ENDIF

					RECLOCK("TEMPFIN",.T.)

						TEMPFIN->TM_DATA  := "ANO " + cAnoOld
						TEMPFIN->TM_NF    := D_ANOFIN->NF
						TEMPFIN->TM_NCC   := D_ANOFIN->NCC
						TEMPFIN->TM_TOTAL := D_ANOFIN->TOTAL

					MSUNLOCK()

					D_ANOFIN->(DBSKIP())

				ENDDO	
				D_ANOFIN->(DBCLOSEAREA())

				cAnoOld     := cAno

			ENDIF

		ENDIF
		
		RECLOCK("TEMPFIN",.T.)

			IF nplanfin == 1 // ano

				TEMPFIN->TM_DATA  := CVALTOCHAR(D_FINANCEIRO->ANO)

			ELSEIF nplanfin == 2 // mês

				TEMPFIN->TM_DATA  := CVALTOCHAR(D_FINANCEIRO->ANO) + '/' + STRZERO(D_FINANCEIRO->MES,2)

			ELSE // dia	

				TEMPFIN->TM_DATA  := DTOC(STOD(D_FINANCEIRO->E1_VENCREA))

			ENDIF

			TEMPFIN->TM_NF    := D_FINANCEIRO->NF
			nTotfinNf         := nTotfinNf + D_FINANCEIRO->NF
			TEMPFIN->TM_NCC   := D_FINANCEIRO->NCC
			nTotfinNcc        := nTotfinNcc + D_FINANCEIRO->NCC
			TEMPFIN->TM_TOTAL := D_FINANCEIRO->TOTAL
			nTotfin           := nTotfin + D_FINANCEIRO->TOTAL
		
		MSUNLOCK()

		D_FINANCEIRO->(DBSKIP())

	ENDDO

	// *** INICIO TOTAIS FINANCEIRO 
	IF nplanfin == 2 // mês

		cQuery:= SqlAnoFin(cCnpjs,cAnoOld)

		TCQUERY cQuery NEW ALIAS "D_ANOFIN"

		WHILE !D_ANOFIN->(EOF())

			IF lFiltroZero == .T. .AND. D_ANOFIN->TOTAL == 0

				D_ANOFIN->(DBSKIP())
				LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

			ENDIF

				RECLOCK("TEMPFIN",.T.)

					TEMPFIN->TM_DATA  := "ANO " + cAnoOld
					TEMPFIN->TM_NF    := D_ANOFIN->NF
					TEMPFIN->TM_NCC   := D_ANOFIN->NCC
					TEMPFIN->TM_TOTAL := D_ANOFIN->TOTAL

				MSUNLOCK()

			D_ANOFIN->(DBSKIP())

		ENDDO	
		D_ANOFIN->(DBCLOSEAREA())
	
	ENDIF

	IF nplanfin == 3 // dia	

		cMes :=  SUBSTR(D_FINANCEIRO->E1_VENCREA,5,2)

		IF  cMesOld <> cMes

			cQuery:= SqlMesFin(cCnpjs,cAnoOld,cMesOld)

			TCQUERY cQuery NEW ALIAS "D_MESFIN"

			WHILE !D_MESFIN->(EOF())

				IF lFiltroZero == .T. .AND. D_MESFIN->TOTAL == 0

					D_MESFIN->(DBSKIP())
					LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

				ENDIF

				RECLOCK("TEMPFIN",.T.)

					TEMPFIN->TM_DATA  := "MÊS " + cMesOld
					TEMPFIN->TM_NF    := D_MESFIN->NF
					TEMPFIN->TM_NCC   := D_MESFIN->NCC
					TEMPFIN->TM_TOTAL := D_MESFIN->TOTAL

				MSUNLOCK()

				D_MESFIN->(DBSKIP())

			ENDDO	
			D_MESFIN->(DBCLOSEAREA())

			cMesOld := cMes

		ENDIF

		cAno := SUBSTR(D_FINANCEIRO->E1_VENCREA,1,4)

		IF  cAnoOld <> cAno

			cQuery:= SqlAnoFin(cCnpjs,cAnoOld)

			TCQUERY cQuery NEW ALIAS "D_ANOFIN"

			WHILE !D_ANOFIN->(EOF())

				IF lFiltroZero == .T. .AND. D_ANOFIN->TOTAL == 0

					D_ANOFIN->(DBSKIP())
					LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

				ENDIF

				RECLOCK("TEMPFIN",.T.)

					TEMPFIN->TM_DATA  := "ANO " + cAnoOld
					TEMPFIN->TM_NF    := D_ANOFIN->NF
					TEMPFIN->TM_NCC   := D_ANOFIN->NCC
					TEMPFIN->TM_TOTAL := D_ANOFIN->TOTAL

				MSUNLOCK()

				D_ANOFIN->(DBSKIP())

			ENDDO	
			D_ANOFIN->(DBCLOSEAREA())

			cAnoOld     := cAno

		ENDIF

	ENDIF

	RECLOCK("TEMPFIN",.T.)

		TEMPFIN->TM_DATA  := 'TOTAL GERAL'
		TEMPFIN->TM_NF    := nTotfinNf
		TEMPFIN->TM_NCC   := nTotfinNcc
		TEMPFIN->TM_TOTAL := nTotfin
	
	MSUNLOCK()

	// *** FINAL TOTAIS FINANCEIRO

	//FINAL FINANCEIRO

	MediaEKgFat(cCnpjs)
	D_FATURAMENTO->(DBGOTOP())
	TEMPFAT->(DBGOTOP())
	D_FINANCEIRO->(DBGOTOP())
	TEMPFIN->(DBGOTOP())

	oRelatorio			 := MsDialog():Create()
	oRelatorio:cName     := "oRelatorio"
	oRelatorio:cCaption  := "Relatorio Gerado em: " + DTOC(DATE()) + " às " + TIME()
	oRelatorio:nLeft     := 0 
	oRelatorio:nTop      := 0 
	oRelatorio:nWidth    := 1340
	oRelatorio:nHeight   := 630
	oRelatorio:lShowHint := .F.
	oRelatorio:lCentered := .T.

	oPanelFat := TPanel():New(000,000,,oRelatorio,,.T.,,CLR_BLACK,CLR_WHITE,420,280,,.T.)
    
	oBrowseFat:= TCBrowse():New(01,01,418,270,,,,oPanelFat,,,,,,,,,,,,,"TEMPFAT",.T.,,,,.T.,)
    oBrowseFat:bLDblClick := {|| MsAguarde({|| DBCLICKFAT(cCnpjs) },"Aguarde","Carregando Dados dos Títulos...") }
	oBrowseFat:AddColumn(TCColumn():New("Data"  ,{|| TEMPFAT->TM_DATA}                                      ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowseFat:AddColumn(TCColumn():New("Vl.NF" ,{|| TRANSFORM(TEMPFAT->TM_NF   ,"@E 999,999,999,999.99")},,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowseFat:AddColumn(TCColumn():New("Vl NCC",{|| TRANSFORM(TEMPFAT->TM_NCC  ,"@E 999,999,999,999.99")},,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowseFat:AddColumn(TCColumn():New("Total" ,{|| TRANSFORM(TEMPFAT->TM_TOTAL,"@E 999,999,999,999.99")},,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowseFat:AddColumn(TCColumn():New("Média" ,{|| TRANSFORM(TEMPFAT->TM_MEDIA,"@E 999,999,999,999.99")},,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowseFat:AddColumn(TCColumn():New("PMV"   ,{|| TRANSFORM(TEMPFAT->TM_PMV  ,"@E 9,999.99"          )},,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowseFat:AddColumn(TCColumn():New("PMVP"  ,{|| TRANSFORM(TEMPFAT->TM_PMVP ,"@E 9,999.99"          )},,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowseFat:AddColumn(TCColumn():New("Kg   " ,{|| TRANSFORM(TEMPFAT->TM_KG   ,"@E 99,999,999,999,999")},,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowseFat:SetBlkColor({|| IIF("T" $ SUBSTR(TEMPFAT->TM_DATA,1,1) .OR. "A" $ SUBSTR(TEMPFAT->TM_DATA,1,1) .OR. "M" $ SUBSTR(TEMPFAT->TM_DATA,1,1), CLR_WHITE, CLR_BLACK)})
	oBrowseFat:SetBlkBackColor({|| IIF("T" $ SUBSTR(TEMPFAT->TM_DATA,1,1), CLR_BLACK , IIF("A" $ SUBSTR(TEMPFAT->TM_DATA,1,1), CLR_BLUE, IIF("M" $ SUBSTR(TEMPFAT->TM_DATA,1,1), CLR_BLUE, Nil)))})

	oPanelFin := TPanel():New(000,420,,oRelatorio,,.T.,,CLR_BLACK,CLR_WHITE,340,280,,.T.)

	oBrowseFin:= TCBrowse():New(01,01,247,270,,,,oPanelFin,,,,,,,,,,,,,"TEMPFIN",.T.,,,,.T.,)
	oBrowseFin:bLDblClick := {|| MsAguarde({|| DBCLICKFIN(cCnpjs) },"Aguarde","Carregando Dados dos Títulos...") }
	oBrowseFin:AddColumn(TCColumn():New("Data"  ,{|| TEMPFIN->TM_DATA}                                    ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowseFin:AddColumn(TCColumn():New("Vl.NF" ,{|| TRANSFORM(TEMPFIN->TM_NF   ,"@E 999,999,999,999.99")},,,,"LEFT",,.F.,.F.,,,,.F.,))

	IF lRetirarNCC == .F.

		oBrowseFin:AddColumn(TCColumn():New("Vl NCC",{|| TRANSFORM(TEMPFIN->TM_NCC  ,"@E 999,999,999,999.99")},,,,"LEFT",,.F.,.F.,,,,.F.,))

	ENDIF

	oBrowseFin:AddColumn(TCColumn():New("Total" ,{|| TRANSFORM(TEMPFIN->TM_TOTAL,"@E 999,999,999,999.99")},,,,"LEFT",,.F.,.F.,,,,.F.,))
    oBrowseFin:SetBlkColor({|| IIF("T" $ SUBSTR(TEMPFIN->TM_DATA,1,1) .OR. "A" $ SUBSTR(TEMPFIN->TM_DATA,1,1) .OR. "M" $ SUBSTR(TEMPFIN->TM_DATA,1,1), CLR_WHITE, CLR_BLACK)})
	oBrowseFin:SetBlkBackColor({|| IIF("T" $ SUBSTR(TEMPFIN->TM_DATA,1,1), CLR_BLACK , IIF("A" $ SUBSTR(TEMPFIN->TM_DATA,1,1), CLR_BLUE, IIF("M" $ SUBSTR(TEMPFIN->TM_DATA,1,1), CLR_BLUE, Nil)))})

	oSayplanfat  := TSay():New(290,010,{||'Planilha 1 - Faturamento'},oRelatorio,,oFontRel,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oSayNome     := TSay():New(290,150,{||IIF(nTipoRel == 1,'Rede: ' + cRedeNome,'Cliente: ' + cRedeNome) },oRelatorio,,oFontRel,,,,.T.,CLR_RED,CLR_WHITE,300,50)
	oSayplanfin  := TSay():New(290,480,{||'Planilha 2 - Financeiro' },oRelatorio,,oFontRel,,,,.T.,CLR_RED,CLR_WHITE,200,20)
    
    oFecharRel   := TButton():New(290,620,"Fechar",oRelatorio,{||oRelatorio:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oFecharRel:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")	

	oRelatorio:Activate(,,,.T.,{||.T.},,{||.T.})

	//Fecha arquivo temporário.
	DBSELECTAREA("TEMPFAT")
	TEMPFAT->(DBCLOSEAREA())
	DBSELECTAREA("TEMPFIN")
	TEMPFIN->(DBCLOSEAREA())
    
	// Inicio Limpando os campos de OK das redes e clientes
	/*
    DBSELECTAREA("TREDE")
	TREDE->(DBGOTOP())
	WHILE !TREDE->(EOF())

		RecLock("TREDE",.F.)		

			TREDE->OK := ""

		MSUNLOCK()

		TREDE->(DBSKIP())

	ENDDO
    */
    /*
	DBSELECTAREA("TCLI")
	TCLI->(DBGOTOP())
	WHILE !TCLI->(EOF())

		RecLock("TCLI",.F.)		

			TCLI->OK := ""

		MSUNLOCK()

		TCLI->(DBSKIP())

	ENDDO
    
	TREDE->(DBGOTOP())
	TCLI->(DBGOTOP())
	*/
    // Final Limpando os campos de OK das redes e clientes
	//oMkRede:oBrowse:Refresh()

	//oPnlFilt1:Refresh()

	RESTAREA(aArea)

Return .T.

/*/{Protheus.doc} Static Function sqlFat
	Script sql base.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function sqlFat(cCnpjs)

	Local cQuery:= ""

	IF nplanfat == 1 // ano

		cQuery := " SELECT YEAR(CAST(E1_EMISSAO AS DATETIME)) AS 'ANO', "

	ELSEIF nplanfat == 2 // mês

		cQuery := " SELECT YEAR(CAST(E1_EMISSAO AS DATETIME)) AS 'ANO', "
		cQuery += " MONTH(CAST(E1_EMISSAO AS DATETIME)) AS 'MES', "  

	ELSE // dia	

		cQuery := " SELECT E1_EMISSAO, "

	ENDIF
	
	cQuery += " SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_VALOR ELSE 0 END) AS 'NF', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_VALOR * (-1) ELSE 0 END),2) AS 'NCC', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_VALOR ELSE 0 END),2) - ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_VALOR ELSE 0 END),2) AS 'TOTAL' "
	cQuery+= "  FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
	cQuery+= " INNER JOIN " + RETSQLNAME("SA1") + " SA1 WITH (NOLOCK) "
	cQuery += "         ON A1_COD          = E1_CLIENTE "
	cQuery += "        AND A1_LOJA         = E1_LOJA "
	cQuery += "        AND A1_CGC         IN (" + cCnpjs + ") "
	cQuery += "        AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += "      WHERE E1_EMISSAO     >= '" + DTOS(dDtIniFat) + "' "
	cQuery += " 	   AND E1_EMISSAO     <= '" + DTOS(dDtFinFat) + "' "
	cQuery += "        AND E1_PORTADO     IN (" + cFiltPortad + ") "
	cQuery += "    	   AND E1_TIPO        IN ('NF','NCC') "
	cQuery += "        AND SE1.D_E_L_E_T_ <> '*' "
		
	IF nplanfat == 1 // ano

		cQuery += " GROUP BY YEAR(CAST(E1_EMISSAO AS DATETIME)) "
		cQuery += " ORDER BY YEAR(CAST(E1_EMISSAO AS DATETIME)) " 

		
	ELSEIF nplanfat == 2 // mês

		cQuery += " GROUP BY MONTH(CAST(E1_EMISSAO AS DATETIME)),YEAR(CAST(E1_EMISSAO AS DATETIME)) "
		cQuery += " ORDER BY YEAR(CAST(E1_EMISSAO AS DATETIME)),MONTH(CAST(E1_EMISSAO AS DATETIME)) " 
		

	ELSE // dia	

		cQuery += " GROUP BY E1_EMISSAO "
		cQuery += " ORDER BY E1_EMISSAO " 
		
	ENDIF

	IIF(Len(cQuery) > 15980,Eval({|| cQuery := "", MsgStop("Não será possível executar a consulta pois o script sql excede o tamanho máximo (15.980).","Função sqlFat")}),Nil)	

Return cQuery

/*/{Protheus.doc} Static Function sqlFin
	Script sql base.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function sqlFin(cCnpjs)

	Local aArea	:= GetArea()
	Local cQuery:= ""

	IF nplanfin == 1 // ano

		cQuery := " SELECT YEAR(CAST(E1_VENCREA AS DATETIME)) AS 'ANO', "

	ELSEIF nplanfin == 2 // mês

		cQuery := " SELECT YEAR(CAST(E1_VENCREA AS DATETIME)) AS 'ANO', "
		cQuery += " MONTH(CAST(E1_VENCREA AS DATETIME)) AS 'MES', "  

	ELSE // dia	

		cQuery := " SELECT E1_VENCREA, "

	ENDIF
	
	cQuery += " SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_SALDO ELSE 0 END) AS 'NF', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_SALDO * (-1) ELSE 0 END),2) AS 'NCC', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_SALDO ELSE 0 END),2) - ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_SALDO ELSE 0 END),2) AS 'TOTAL' "
	cQuery+= "  FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
	cQuery+= " INNER JOIN " + RETSQLNAME("SA1") + " SA1 WITH (NOLOCK) "
	cQuery += "         ON A1_COD          = E1_CLIENTE "
	cQuery += "        AND A1_LOJA         = E1_LOJA "
	cQuery += "        AND A1_CGC         IN (" + cCnpjs + ") "
	cQuery += "        AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += "      WHERE E1_VENCREA     >= '" + DTOS(dDtIniFin) + "' "
	cQuery += " 	   AND E1_VENCREA     <= '" + DTOS(dDtFinFin) + "' "
	cQuery += "        AND E1_PORTADO     IN (" + cFiltPortad + ") "
	cQuery += "    	   AND E1_TIPO        IN ('NF','NCC') "
	cQuery += "        AND SE1.D_E_L_E_T_ <> '*' "
		
	IF nplanfin == 1 // ano

		cQuery += " GROUP BY YEAR(CAST(E1_VENCREA AS DATETIME)) "
		cQuery += " ORDER BY YEAR(CAST(E1_VENCREA AS DATETIME)) " 

		
	ELSEIF nplanfin == 2 // mês

		cQuery += " GROUP BY MONTH(CAST(E1_VENCREA AS DATETIME)),YEAR(CAST(E1_VENCREA AS DATETIME)) "
		cQuery += " ORDER BY YEAR(CAST(E1_VENCREA AS DATETIME)),MONTH(CAST(E1_VENCREA AS DATETIME)) " 
		
	ELSE // dia	

		cQuery += " GROUP BY E1_VENCREA "
		cQuery += " ORDER BY E1_VENCREA " 
		
	ENDIF

	IIF(Len(cQuery) > 15980,Eval({|| cQuery := "", MsgStop("Não será possível executar a consulta pois o script sql excede o tamanho máximo (15.980).","Função sqlFat")}),Nil)

	RestArea(aArea)

Return cQuery

/*/{Protheus.doc} Static Function bscRede
	Busca rede na MsSelect.
	@type  Function
	@author Everson
	@since 27/06/2017
	@version version
/*/

Static Function bscRede(oMkRede,cCodigo)

	Local nAux	:= 1
	Local nPos	:= 1
	
	cCodigo := Alltrim(cValToChar(cCodigo))

	If Empty(cCodigo)
		RestArea(aArea)
		Return Nil

	EndIf

	If Select("TREDE") <= 0
		RestArea(aArea)
		Return Nil

	EndIf

	DbSelectArea("TREDE")
	TREDE->(DbGoTop())

	While ! TREDE->(Eof())

		If cCodigo $(Alltrim(cValToChar(TREDE->TMP_RED))) .OR. ;
		   cCodigo $(Alltrim(cValToChar(TREDE->TMP_DESC)))

			nPos := nAux

			Exit

		EndIf

		TREDE->(DbSkip())

		nAux:= nAux + 1

	EndDo

	If nPos <= 0

		MsgStop("Registro não encontrado","Função bscRede")
		Return Nil

	EndIf

	//oMkRede:oBrowse:nPos
	//oMkRede:oBrowse:REFRESH()
    	
Return Nil


STATIC FUNCTION sqlCNPJ(nTipoRel,cFiltro)	
	
	Local cQuery:= ""
	
	cQuery += " SELECT A1_CGC "
	cQuery+= "  FROM " + RETSQLNAME("SA1") + " WITH (NOLOCK) "

	IF nTipoRel == 1 // REDE

		cQuery += " WHERE A1_CODRED IN (" + cFiltro + ") "

	ELSE	

		cQuery += " WHERE A1_COD IN (" + cFiltro + ") "

	ENDIF

	cQuery += "   AND D_E_L_E_T_ <> '*' "
	cQuery += "   ORDER BY A1_CGC "
	
Return cQuery

STATIC FUNCTION PrazoMedia(cData,cRel,cfuncao,cTipoMedia,cCnpjs)

	Local nValor      := 0
	Local cDataIniAux := ''
	Local cDataFinAux := ''
	Local nCont       := 0
	Local nSomaValor  := 0
	Local nSomaMedia  := 0 
	Local nPMPonLinha := 0
	   
	IF cfuncao == 'NORMAL'

		IF nplanfat == 1 .OR. nplanfin == 1 // Ano

			cDataIniAux := ALLTRIM(cData) + '01' + '01'
			cDataFinAux := ALLTRIM(cData) + '12' + '31'

		ELSEIF nplanfat == 2 .OR. nplanfin == 2 // mês

			cDataIniAux := STRTRAN(ALLTRIM(cData),'/','') + '01'
			cDataFinAux := DTOS(LASTDAY(STOD(STRTRAN(ALLTRIM(cData),'/','') + '01')))

		ELSE //dia

			cDataIniAux := DTOS(CTOD(cData))
			cDataFinAux := DTOS(CTOD(cData))

		ENDIF

	ENDIF	

	IF cfuncao == 'MES'

		cDataIniAux := STRTRAN(ALLTRIM(cData),'/','') + '01'
		cDataFinAux := DTOS(LASTDAY(STOD(STRTRAN(ALLTRIM(cData),'/','') + '01')))

	
	ENDIF

	IF cfuncao == 'ANO'

		cDataIniAux := ALLTRIM(cData) + '01' + '01'
		cDataFinAux := ALLTRIM(cData) + '12' + '31'

	
	ENDIF

	IF cfuncao == 'TOTAL'

		IF cRel == 'FAT'

			cDataIniAux := DTOS(dDtIniFat)
			cDataFinAux := DTOS(dDtFinFat)

		ELSE

			cDataIniAux := DTOS(dDtIniFin)
			cDataFinAux := DTOS(dDtFinFin)

		ENDIF	

	
	ENDIF

	IF cRel == 'FAT'

		cQuery:= sqlMVFat(cDataIniAux,cDataFinAux,cCnpjs)

	ELSE

		cQuery:= sqlMVFin(cDataIniAux,cDataFinAux,cCnpjs)

	ENDIF

	IF SELECT("D_MEDVENDA") > 0

		D_MEDVENDA->(DBCLOSEAREA())

	ENDIF

	TCQUERY cQuery NEW ALIAS "D_MEDVENDA"

	nCont       := 0
	nSomaValor  := 0
	nSomaMedia  := 0 
	nPMPonLinha := 0

	DBSELECTAREA("D_MEDVENDA")
	D_MEDVENDA->(DBGOTOP())
	WHILE !D_MEDVENDA->(EOF())

		nCont       := nCont + 1
		nSomaValor  := nSomaValor + D_MEDVENDA->E1_VALOR
		nSomaMedia  := nSomaMedia + D_MEDVENDA->DIF_VENC_EMIS
		nPMPonLinha := nPMPonLinha + (D_MEDVENDA->E1_VALOR * D_MEDVENDA->DIF_VENC_EMIS)
		
		D_MEDVENDA->(DBSKIP())

	ENDDO
	D_MEDVENDA->(DBCLOSEAREA())
		
	IF cTipoMedia == 'VENDA'

		nValor := nSomaMedia / nCont

	ELSE

		nValor := nPMPonLinha / nSomaValor

	ENDIF	

Return(nValor)

STATIC FUNCTION sqlMVFat(cDataIniFat,cDataFinFat,cCnpjs)
	
	Local cQuery:= ""
	
	cQuery += " SELECT CONVERT(NUMERIC,CONVERT(DATETIME, E1_VENCREA) - CONVERT(DATETIME, E1_EMISSAO)) AS DIF_VENC_EMIS,E1_VALOR "
	cQuery += "  FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
	cQuery += " INNER JOIN " + RETSQLNAME("SA1") + " SA1 WITH (NOLOCK) "
	cQuery += "         ON A1_COD          = E1_CLIENTE "
	cQuery += "        AND A1_LOJA         = E1_LOJA "
	cQuery += "        AND A1_CGC         IN (" + cCnpjs + ") "
	cQuery += "        AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE E1_EMISSAO          >= '" + cDataIniFat + "' " 
	cQuery += "   AND E1_EMISSAO          <= '" + cDataFinFat + "' " 
	cQuery += "   AND SE1.E1_TIPO          = 'NF' "
	cQuery += "   AND SE1.D_E_L_E_T_      <> '*' "
	cQuery += "   ORDER BY E1_NUM "
	
Return cQuery

STATIC FUNCTION sqlMVFin(cDataIniFat,cDataFinFat,cCnpjs)
	
	Local cQuery:= ""
	
	cQuery += " SELECT CONVERT(NUMERIC,CONVERT(DATETIME, E1_VENCREA) - CONVERT(DATETIME, E1_EMISSAO)) AS DIF_VENC_EMIS,E1_VALOR "
	cQuery += "  FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
	cQuery += " INNER JOIN " + RETSQLNAME("SA1") + " SA1 WITH (NOLOCK) "
	cQuery += "         ON A1_COD          = E1_CLIENTE "
	cQuery += "        AND A1_LOJA         = E1_LOJA "
	cQuery += "        AND A1_CGC         IN (" + cCnpjs + ") "
	cQuery += "        AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE E1_VENCREA          >= '" + cDataIniFat + "' " 
	cQuery += "   AND E1_VENCREA          <= '" + cDataFinFat + "' " 
	cQuery += "   AND SE1.E1_TIPO          = 'NF' "
	cQuery += "   AND SE1.D_E_L_E_T_      <> '*' "
	cQuery += "   ORDER BY E1_NUM "
	
Return cQuery

STATIC FUNCTION MediaEKgFat(cCnpjs)

	Local cDataMedIni := ''
	Local cDataMedFin := ''
	Local cDataKgIni  := ''
	Local cDataKgFin  := ''
	Local nContMedia  := 0
	
	IF nplanfat == 1  // Ano

		cDataMedIni := ''
		cDataMedFin := ''
		cDataKgIni  := ''
	    cDataKgFin  := ''
		nContMedia   := 0

		DbSelectArea("TEMPFAT")
		TEMPFAT->(DBGOTOP())

		WHILE !TEMPFAT->(EOF())

			IF SUBSTR(TEMPFAT->TM_DATA,1,4) $ 'TOTAL'
			   
			    cDataMedIni := DTOS(ddtIniFat)
				cDataMedFin := DTOS(ddtFinFat)
				cDataKgIni  := DTOS(ddtIniFat)
	    		cDataKgFin  := DTOS(ddtFinFat)

				RECLOCK("TEMPFAT",.F.)

					TEMPFAT->TM_MEDIA := CALCULAMEDIA(DateDiffMonth(ddtIniFat,ddtFinFat),cDataMedIni,cDataMedFin,cCnpjs)
					TEMPFAT->TM_KG    := CALCULAKG(cDataKgIni,cDataKgFin,cCnpjs)
					
				MSUNLOCK()

				TEMPFAT->(DBSKIP())
			    LOOP

			ENDIF

			cDataMedIni := SUBSTR(TEMPFAT->TM_DATA,1,4) + '0101'
			cDataMedFin := SUBSTR(TEMPFAT->TM_DATA,1,4) + '1231'
			cDataKgIni  := SUBSTR(TEMPFAT->TM_DATA,1,4) + '0101'
			cDataKgFin  := SUBSTR(TEMPFAT->TM_DATA,1,4) + '1231'

			RECLOCK("TEMPFAT",.F.)

				TEMPFAT->TM_MEDIA := CALCULAMEDIA(DateDiffMonth(STOD(cDataMedIni),IIF(STOD(cDataMedFin) > DATE(),DATE(),STOD(cDataMedFin))) + 1,cDataMedIni,cDataMedFin,cCnpjs)
				TEMPFAT->TM_KG    := CALCULAKG(cDataKgIni,cDataKgFin,cCnpjs)
				
			MSUNLOCK()
			
			TEMPFAT->(DBSKIP())

		ENDDO
			
	ELSEIF nplanfat == 2  // mês

		cDataMedIni := ''
		cDataMedFin := ''
		cDataKgIni  := ''
	    cDataKgFin  := ''
		nContMedia  := 0

		DbSelectArea("TEMPFAT")
		TEMPFAT->(DBGOTOP())

		cDataMedIni := DTOS(FIRSTDATE(CTOD("01/" + SUBSTR(TEMPFAT->TM_DATA,6,2) + "/" + SUBSTR(TEMPFAT->TM_DATA,1,4))))
		cDataMedFin := ''
		cDataKgIni  := DTOS(FIRSTDATE(CTOD("01/" + SUBSTR(TEMPFAT->TM_DATA,6,2) + "/" + SUBSTR(TEMPFAT->TM_DATA,1,4))))
	    cDataKgFin  := DTOS(LASTDATE(CTOD("01/" + SUBSTR(TEMPFAT->TM_DATA,6,2) + "/" + SUBSTR(TEMPFAT->TM_DATA,1,4))))

		WHILE !TEMPFAT->(EOF())

			IF SUBSTR(TEMPFAT->TM_DATA,1,3) $ 'ANO'

				cDataMedIni := SUBSTR(TEMPFAT->TM_DATA,5,4) + '0101'
				cDataMedFin := SUBSTR(TEMPFAT->TM_DATA,5,4) + '1231'
				cDataKgIni  := SUBSTR(TEMPFAT->TM_DATA,5,4) + '0101'
	    		cDataKgFin  := SUBSTR(TEMPFAT->TM_DATA,5,4) + '1231'

				RECLOCK("TEMPFAT",.F.)

					TEMPFAT->TM_MEDIA := CALCULAMEDIA(DateDiffMonth(STOD(cDataMedIni),IIF(STOD(cDataMedFin) > DATE(),DATE(),STOD(cDataMedFin))) + 1,cDataMedIni,cDataMedFin,cCnpjs)
					TEMPFAT->TM_KG    := CALCULAKG(cDataKgIni,cDataKgFin,cCnpjs)
					
				MSUNLOCK()

				cDataMedIni := CVALTOCHAR(VAL(SUBSTR(TEMPFAT->TM_DATA,5,4)) + 1) + '0101'

				TEMPFAT->(DBSKIP())
			    LOOP

			ENDIF

			IF SUBSTR(TEMPFAT->TM_DATA,1,4) $ 'TOTAL'
			   
			    cDataMedIni := DTOS(ddtIniFat)
				cDataMedFin := DTOS(ddtFinFat)
				cDataKgIni  := DTOS(ddtIniFat)
	    		cDataKgFin  := DTOS(ddtFinFat)

				RECLOCK("TEMPFAT",.F.)

					TEMPFAT->TM_MEDIA := CALCULAMEDIA(DateDiffMonth(ddtIniFat,IIF(ddtFinFat > DATE(),DATE(),ddtFinFat)) + 1,cDataMedIni,cDataMedFin,cCnpjs)
					TEMPFAT->TM_KG    := CALCULAKG(cDataKgIni,cDataKgFin,cCnpjs)
					
				MSUNLOCK()

				TEMPFAT->(DBSKIP())
			    LOOP

			ENDIF

			cDataKgIni  := DTOS(FIRSTDATE(CTOD("01/" + SUBSTR(TEMPFAT->TM_DATA,6,2) + "/" + SUBSTR(TEMPFAT->TM_DATA,1,4))))
	    	cDataKgFin  := DTOS(LASTDATE(CTOD("01/" + SUBSTR(TEMPFAT->TM_DATA,6,2) + "/" + SUBSTR(TEMPFAT->TM_DATA,1,4))))
			RECLOCK("TEMPFAT",.F.)

				TEMPFAT->TM_KG := CALCULAKG(cDataKgIni,cDataKgFin,cCnpjs)
				
			MSUNLOCK()
			
			nContMedia := nContMedia + 1

			IF nContMedia > 3

				nContMedia := 1

			ENDIF

			IF nContMedia == 3

				cDataMedFin := DTOS(LASTDATE(CTOD( "01/" + SUBSTR(TEMPFAT->TM_DATA,6,2) + "/" + SUBSTR(TEMPFAT->TM_DATA,1,4))))

				RECLOCK("TEMPFAT",.F.)

					TEMPFAT->TM_MEDIA := CALCULAMEDIA(nContMedia,cDataMedIni,cDataMedFin,cCnpjs)
					
				MSUNLOCK()

				cDataMedIni := DTOS(STOD(cDataMedFin) + 1)
				
			ENDIF
			
			TEMPFAT->(DBSKIP())
		ENDDO

	ELSE //dia

		cDataMedIni := ''
		cDataMedFin := ''
		cDataKgIni  := ''
	    cDataKgFin  := ''
		nContMedia  := 0

		DbSelectArea("TEMPFAT")
		TEMPFAT->(DBGOTOP())

		WHILE !TEMPFAT->(EOF())

			IF SUBSTR(TEMPFAT->TM_DATA,1,1) $ 'M'
				
				cDataMedIni := DTOS(FIRSTDAY(STOD(TEMPFAT->TM_ANO + SUBSTR(TEMPFAT->TM_DATA,5,2) + '01')))
				cDataMedFin := DTOS(LASTDAY(STOD(TEMPFAT->TM_ANO + SUBSTR(TEMPFAT->TM_DATA,5,2) + '01')))
				cDataKgIni  := DTOS(FIRSTDAY(STOD(TEMPFAT->TM_ANO + SUBSTR(TEMPFAT->TM_DATA,5,2) + '01')))
	    		cDataKgFin  := DTOS(LASTDAY(STOD(TEMPFAT->TM_ANO + SUBSTR(TEMPFAT->TM_DATA,5,2) + '01')))

				RECLOCK("TEMPFAT",.F.)

					TEMPFAT->TM_MEDIA := CALCULAMEDIA(DateDiffDay(STOD(cDataMedIni),STOD(cDataMedFin)),cDataMedIni,cDataMedFin,cCnpjs)
					TEMPFAT->TM_KG    := CALCULAKG(cDataKgIni,cDataKgFin,cCnpjs)
					
				MSUNLOCK()

				cDataMedIni := CVALTOCHAR(VAL(SUBSTR(TEMPFAT->TM_DATA,5,4)) + 1) + '0101'

				TEMPFAT->(DBSKIP())
			    LOOP
                
			ENDIF

			IF SUBSTR(TEMPFAT->TM_DATA,1,3) $ 'ANO'
                
				cDataMedIni := SUBSTR(TEMPFAT->TM_DATA,5,4) + '0101'
				cDataMedFin := SUBSTR(TEMPFAT->TM_DATA,5,4) + '1231'
				cDataKgIni  := SUBSTR(TEMPFAT->TM_DATA,5,4) + '0101'
	    		cDataKgFin  := SUBSTR(TEMPFAT->TM_DATA,5,4) + '1231'

				RECLOCK("TEMPFAT",.F.)

					TEMPFAT->TM_MEDIA := CALCULAMEDIA(DateDiffMonth(STOD(cDataMedIni),IIF(STOD(cDataMedFin) > DATE(),DATE(),STOD(cDataMedFin))) + 1,cDataMedIni,cDataMedFin,cCnpjs)
					TEMPFAT->TM_KG    := CALCULAKG(cDataKgIni,cDataKgFin,cCnpjs)
					
				MSUNLOCK()

				cDataMedIni := CVALTOCHAR(VAL(SUBSTR(TEMPFAT->TM_DATA,5,4)) + 1) + '0101'

				TEMPFAT->(DBSKIP())
			    LOOP
               
			ENDIF

			IF SUBSTR(TEMPFAT->TM_DATA,1,4) $ 'TOTAL'
			   
			    cDataMedIni := DTOS(ddtIniFat)
				cDataMedFin := DTOS(ddtFinFat)
				cDataKgIni  := DTOS(ddtIniFat)
	    		cDataKgFin  := DTOS(ddtFinFat)

				RECLOCK("TEMPFAT",.F.)

					TEMPFAT->TM_MEDIA := CALCULAMEDIA(DateDiffMonth(ddtIniFat,ddtFinFat),cDataMedIni,cDataMedFin,cCnpjs)
					TEMPFAT->TM_KG    := CALCULAKG(cDataKgIni,cDataKgFin,cCnpjs)
					
				MSUNLOCK()

				TEMPFAT->(DBSKIP())
			    LOOP
                
			ENDIF

			cDataKgIni  := DTOS(CTOD(TEMPFAT->TM_DATA))
	    	cDataKgFin  := DTOS(CTOD(TEMPFAT->TM_DATA))
			RECLOCK("TEMPFAT",.F.)

				TEMPFAT->TM_KG := CALCULAKG(cDataKgIni,cDataKgFin,cCnpjs)
				
			MSUNLOCK()
			
			TEMPFAT->(DBSKIP())

		ENDDO

	ENDIF

RETURN(NIL)

STATIC FUNCTION CALCULAMEDIA(nContMedia,cDataIni,cDataFin,cCnpjs)

	Local nValor     := 0
	Local nSomaValor := 0

	cQuery:= sqlMVFat(cDataIni,cDataFin,cCnpjs)

	IF SELECT("D_MEDIA") > 0

		D_MEDIA->(DBCLOSEAREA())

	ENDIF

	TCQUERY cQuery NEW ALIAS "D_MEDIA"

	DBSELECTAREA("D_MEDIA")
	D_MEDIA->(DBGOTOP())
	WHILE !D_MEDIA->(EOF())

		nSomaValor  := nSomaValor + D_MEDIA->E1_VALOR
		
		D_MEDIA->(DBSKIP())

	ENDDO
	D_MEDIA->(DBCLOSEAREA())

	nValor := nSomaValor / nContMedia

RETURN(nValor)	

STATIC FUNCTION CALCULAKG(cDataIni,cDataFin,cCnpjs)

	Local nValor := 0
	
	cQuery := sqlKgFat(cDataIni,cDataFin,cCnpjs)

	IF SELECT("D_KG") > 0

		D_KG->(DBCLOSEAREA())

	ENDIF

	TCQUERY cQuery NEW ALIAS "D_KG"

	DBSELECTAREA("D_KG")
	D_KG->(DBGOTOP())
	WHILE !D_KG->(EOF())

		nValor  := D_KG->TOT_KG
		
		D_KG->(DBSKIP())

	ENDDO
	D_KG->(DBCLOSEAREA())

RETURN(nValor)	

STATIC FUNCTION sqlKgFat(cDataIniFat,cDataFinFat,cCnpjs)
	
	Local cQuery:= ""

	cQuery += " SELECT  ISNULL(SUM(B_FATURAMENTO.F2_PLIQUI),0) - ISNULL(SUM(B_DEVOLUCAO.D1_QUANT),0) AS TOT_KG "
	cQuery += "   FROM (SELECT A1_FILIAL, A1_COD, A1_LOJA, A1_NOME, A1_VEND, LEFT(A1_CGC,8) AS RAIZ_CGC,A1_MSBLQL "
	cQuery += "           FROM " + RETSQLNAME("SA1") + " SA1 WITH (NOLOCK) "
	cQuery += "			 WHERE SA1.D_E_L_E_T_='' "
	cQuery += "			   AND A1_CGC       IN (" + cCnpjs + ") ""
	cQuery += "		   ) AS B_CLIENTE "
	cQuery += "	  LEFT OUTER JOIN (SELECT BSE1F.E1_FILIAL,BSE1F.E1_CLIENTE,BSE1F.E1_LOJA,BSE1F.PER,SUM(BSE1F.E1_SALDO) AS E1_SALDO,SUM(BSF2.F2_PLIQUI) AS F2_PLIQUI  "
	cQuery += "						 FROM (SELECT E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_NUM,E1_PREFIXO, CAST(YEAR(E1_EMISSAO) AS VARCHAR)+RIGHT('00'+CAST(MONTH(E1_EMISSAO) AS VARCHAR),2) AS PER, E1_VALOR AS E1_SALDO "
	cQuery += "                              FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
	cQuery += "								WHERE SE1.D_E_L_E_T_  = '' "   
	cQuery += "								  AND E1_TIPO        IN ('NF ','NCI','NDC') "
	cQuery += "								  AND E1_EMISSAO     >= '" + cDataIniFat + "' " 
	cQuery += "								  AND E1_EMISSAO     <= '" + cDataFinFat + "' "
	cQuery += "							  ) AS BSE1F "  
	cQuery += "							  LEFT OUTER JOIN (SELECT F2_FILIAL,F2_DUPL, F2_SERIE, SUM(F2_PLIQUI) AS F2_PLIQUI "
    cQuery += "                                              FROM " + RETSQLNAME("SF2") + " SF2 WITH (NOLOCK) "
	cQuery += "												WHERE F2_DUPL        <> '' "
	cQuery += "												  AND SF2.D_E_L_E_T_  = '' "
	cQuery += "										  	 GROUP BY F2_FILIAL,F2_DUPL, F2_SERIE "
	cQuery += "											  ) BSF2 "
	cQuery += "											ON BSE1F.E1_FILIAL  = BSF2.F2_FILIAL " 
	cQuery += "										   AND BSE1F.E1_NUM     = BSF2.F2_DUPL "
	cQuery += "										   AND BSE1F.E1_PREFIXO = BSF2.F2_SERIE "
	cQuery += "									  GROUP BY BSE1F.E1_FILIAL, BSE1F.E1_CLIENTE, BSE1F.E1_LOJA, BSE1F.PER "
	cQuery += "         ) AS B_FATURAMENTO "
	cQuery += "		   ON B_CLIENTE.A1_COD  = B_FATURAMENTO.E1_CLIENTE "   
	cQuery += "		  AND B_CLIENTE.A1_LOJA = B_FATURAMENTO.E1_LOJA "   
	cQuery += "	  LEFT OUTER JOIN (SELECT BSE1D.E1_FILIAL,BSE1D.E1_CLIENTE,BSE1D.E1_LOJA,BSE1D.E1_NUM,BSE1D.PER, SUM(BSE1D.E1_SALDO) AS E1_SALDO, SUM(BSD1.D1_QUANT) AS D1_QUANT  " 
	cQuery += "	 			 FROM (SELECT E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_NUM,E1_PREFIXO,CAST(YEAR(E1_EMISSAO) AS VARCHAR)+RIGHT('00'+CAST(MONTH(E1_EMISSAO) AS VARCHAR),2) AS PER,E1_VALOR AS E1_SALDO "  
	cQuery += "                      FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
	cQuery += "						WHERE SE1.D_E_L_E_T_  = '' "
	cQuery += "						  AND E1_TIPO        IN ('NCC') "
	cQuery += "						  AND E1_EMISSAO     >= '" + cDataIniFat + "' "
	cQuery += "						  AND E1_EMISSAO     <= '" + cDataFinFat + "' " 
	cQuery += "					  ) AS BSE1D "
	cQuery += "					  LEFT OUTER JOIN ( SELECT D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, SUM(D1_QUANT) AS D1_QUANT "  
	cQuery += "                                       FROM " + RETSQLNAME("SD1") + " SD1 WITH (NOLOCK) "
	cQuery += "												WHERE SD1.D_E_L_E_T_ = '' " 
	cQuery += "										  GROUP BY D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA " 
	cQuery += "									  ) BSD1 "
	cQuery += "									  ON BSE1D.E1_FILIAL  = BSD1.D1_FILIAL "
	cQuery += "									 AND BSE1D.E1_NUM     = BSD1.D1_DOC "
	cQuery += "									 AND BSE1D.E1_PREFIXO = BSD1.D1_SERIE "
	cQuery += "									 AND BSE1D.E1_CLIENTE = BSD1.D1_FORNECE "
	cQuery += "									 AND BSE1D.E1_LOJA    = BSD1.D1_LOJA "
	cQuery += "					 GROUP BY BSE1D.E1_FILIAL,BSE1D.E1_CLIENTE,BSE1D.E1_LOJA,BSE1D.E1_NUM,BSE1D.PER " 
	cQuery += "					 ) AS B_DEVOLUCAO "   
	cQuery += "	                ON B_FATURAMENTO.E1_FILIAL  = B_DEVOLUCAO.E1_FILIAL "
	cQuery += "				   AND B_FATURAMENTO.E1_CLIENTE = B_DEVOLUCAO.E1_CLIENTE "
	cQuery += "				   AND B_FATURAMENTO.E1_LOJA    = B_DEVOLUCAO.E1_LOJA "
	cQuery += "				   AND B_FATURAMENTO.PER        = B_DEVOLUCAO.PER "

Return cQuery


Static Function SqlAnoFat(cCnpjs,cAnoAux)

	Local cQuery:= ""

	cQuery := "SELECT "
	cQuery += " SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_VALOR ELSE 0 END) AS 'NF', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_VALOR * (-1) ELSE 0 END),2) AS 'NCC', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_VALOR ELSE 0 END),2) - ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_VALOR ELSE 0 END),2) AS 'TOTAL' "
	cQuery += "  FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
    cQuery += " INNER JOIN " + RETSQLNAME("SA1") + " SA1 WITH (NOLOCK) "
	cQuery += "         ON A1_COD          = E1_CLIENTE "
	cQuery += "        AND A1_LOJA         = E1_LOJA "
	cQuery += "        AND A1_CGC         IN (" + cCnpjs + ") "
	cQuery += "        AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += "      WHERE E1_EMISSAO     >= '" + cAnoAux + '0101' + "' "
	cQuery += " 	   AND E1_EMISSAO     <= '" + cAnoAux + '1231' + "' "
	cQuery += "        AND E1_PORTADO     IN (" + cFiltPortad + ") "
	cQuery += "    	   AND E1_TIPO        IN ('NF','NCC') "
	cQuery += "        AND SE1.D_E_L_E_T_ <> '*' "
		
Return cQuery

Static Function SqlAnoFin(cCnpjs,cAnoAux)

	Local cQuery:= ""

	cQuery := "SELECT "
	cQuery += " SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_SALDO ELSE 0 END) AS 'NF', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_SALDO * (-1) ELSE 0 END),2) AS 'NCC', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_SALDO ELSE 0 END),2) - ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_SALDO ELSE 0 END),2) AS 'TOTAL' "
	cQuery += "  FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
	cQuery += " INNER JOIN " + RETSQLNAME("SA1") + " SA1 WITH (NOLOCK) "
	cQuery += "         ON A1_COD          = E1_CLIENTE "
	cQuery += "        AND A1_LOJA         = E1_LOJA "
	cQuery += "        AND A1_CGC         IN (" + cCnpjs + ") "
	cQuery += "        AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += "      WHERE E1_VENCREA     >= '" + cAnoAux + '0101' + "' "
	cQuery += " 	   AND E1_VENCREA     <= '" + cAnoAux + '1231' + "' "
	cQuery += "        AND E1_PORTADO     IN (" + cFiltPortad + ") "
	cQuery += "    	   AND E1_TIPO        IN ('NF','NCC') "
	cQuery += "        AND SE1.D_E_L_E_T_ <> '*' "

Return cQuery

STATIC FUNCTION SqlMesFat(cCnpjs,cAnoAux,cMesAux)
	
	Local cQuery:= ""

	cQuery := "SELECT "
	cQuery += " SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_VALOR ELSE 0 END) AS 'NF', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_VALOR * (-1) ELSE 0 END),2) AS 'NCC', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_VALOR ELSE 0 END),2) - ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_VALOR ELSE 0 END),2) AS 'TOTAL' "
	cQuery += "  FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
    cQuery += " INNER JOIN " + RETSQLNAME("SA1") + " SA1 WITH (NOLOCK) "
	cQuery += "         ON A1_COD          = E1_CLIENTE "
	cQuery += "        AND A1_LOJA         = E1_LOJA "
	cQuery += "        AND A1_CGC         IN (" + cCnpjs + ") "
	cQuery += "        AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += "      WHERE E1_EMISSAO     >= '" + cAnoAux + cMesAux + '01' + "' "
	cQuery += " 	   AND E1_EMISSAO     <= '" + cAnoAux + cMesAux + '31' + "' "
	cQuery += "        AND E1_PORTADO     IN (" + cFiltPortad + ") "
	cQuery += "    	   AND E1_TIPO        IN ('NF','NCC') "
	cQuery += "        AND SE1.D_E_L_E_T_ <> '*' "
	
Return cQuery

STATIC FUNCTION SqlMesFin(cCnpjs,cAnoAux,cMesAux)
	
	Local cQuery:= ""

	cQuery := "SELECT "
	cQuery += " SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_SALDO ELSE 0 END) AS 'NF', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_SALDO * (-1) ELSE 0 END),2) AS 'NCC', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_SALDO ELSE 0 END),2) - ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_SALDO ELSE 0 END),2) AS 'TOTAL' "
	cQuery += "  FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
	cQuery += " INNER JOIN " + RETSQLNAME("SA1") + " SA1 WITH (NOLOCK) "
	cQuery += "         ON A1_COD          = E1_CLIENTE "
	cQuery += "        AND A1_LOJA         = E1_LOJA "
	cQuery += "        AND A1_CGC         IN (" + cCnpjs + ") "
	cQuery += "        AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += "      WHERE E1_VENCREA     >= '" + cAnoAux + cMesAux + '01' + "' "
	cQuery += " 	   AND E1_VENCREA     <= '" + cAnoAux + cMesAux + '31' + "' "
	cQuery += "        AND E1_PORTADO     IN (" + cFiltPortad + ") "
	cQuery += "    	   AND E1_TIPO        IN ('NF','NCC') "
	cQuery += "        AND SE1.D_E_L_E_T_ <> '*' "
	
Return cQuery

STATIC FUNCTION NOMEREDE()

	Local cNome := ''
	Local aArea	:= TREDE->(GetArea())

	DBSELECTAREA("TREDE")
	TREDE->(DBGOTOP())
	WHILE !TREDE->(EOF())

		IF ALLTRIM(TREDE->OK) <> ''

			cNome := TREDE->TMP_RED + ' '+ TREDE->TMP_DESC
			RestArea(aArea)
			EXIT

		ENDIF

		TREDE->(DBSKIP())

	ENDDO

	RestArea(aArea)

RETURN(cNome)

STATIC FUNCTION NOMECLIENTE()

	Local cNome := ''
	Local aArea	:= TCLI->(GetArea())

	DBSELECTAREA("TCLI")
	TCLI->(DBGOTOP())
	WHILE !TCLI->(EOF())

		IF ALLTRIM(TCLI->OK) <> ''

			cNome := TCLI->TMP_COD + ' '+ TCLI->TMP_LOJA + ' '+ TCLI->TMP_NOME
			RestArea(aArea)
			EXIT

		ENDIF

		TCLI->(DBSKIP())

	ENDDO

	RestArea(aArea)

RETURN(cNome)


STATIC FUNCTION DBCLICKFAT(cCnpjs) 

	LOCAL oTelaTitFat  := NIL
	Local oBrowTitFat  := NIL
	Local cDataIniFat  := ''
	Local cDataFinFat  := ''

	// *** INICIO VALIDACAO

	IF SUBSTR(TEMPFAT->TM_DATA,1,1) $ "M/A/T"  // COMPARACAO COM MÊS/ANO/TOTAL

		MSGALERT("Não é possivel ver detalhes de Titulos de Linhas de Mês Ano e Total eles são somente demonstrativos","DBCLICKFAT")

		RETURN(NIL)

	ENDIF

	// *** FINAL VALIDACAO

	//Cria Arquivos Temporários
	oTempFat1 := FWTemporaryTable():New("TITFAT")

	// INICIO Monta os campos da tabela
	aCampos := {}
	AADD(aCampos,{"TM_FILIAL" ,FWTamSX3("E1_FILIAL")[3]  ,FWTamSX3("E1_FILIAL")[1]  ,FWTamSX3("E1_FILIAL")[2]  })	
	AADD(aCampos,{"TM_PREFIXO",FWTamSX3("E1_PREFIXO")[3] ,FWTamSX3("E1_PREFIXO")[1] ,FWTamSX3("E1_PREFIXO")[2] })
	AADD(aCampos,{"TM_NUM"    ,FWTamSX3("E1_NUM")[3]     ,FWTamSX3("E1_NUM")[1]     ,FWTamSX3("E1_NUM")[2]     })
	AADD(aCampos,{"TM_PARCELA",FWTamSX3("E1_PARCELA")[3] ,FWTamSX3("E1_PARCELA")[1] ,FWTamSX3("E1_PARCELA")[2] })
	AADD(aCampos,{"TM_TIPO"   ,FWTamSX3("E1_TIPO")[3]    ,FWTamSX3("E1_TIPO")[1]    ,FWTamSX3("E1_TIPO")[2]    })
	AADD(aCampos,{"TM_PORTADO",FWTamSX3("E1_PORTADO")[3] ,FWTamSX3("E1_PORTADO")[1] ,FWTamSX3("E1_PORTADO")[2] })
	AADD(aCampos,{"TM_CLIENTE",FWTamSX3("E1_CLIENTE")[3] ,FWTamSX3("E1_CLIENTE")[1] ,FWTamSX3("E1_CLIENTE")[2] })
	AADD(aCampos,{"TM_LOJA"   ,FWTamSX3("E1_LOJA")[3]    ,FWTamSX3("E1_LOJA")[1]    ,FWTamSX3("E1_LOJA")[2]    })
	AADD(aCampos,{"TM_NOMCLI" ,FWTamSX3("E1_NOMCLI")[3]  ,FWTamSX3("E1_NOMCLI")[1]  ,FWTamSX3("E1_NOMCLI")[2]  })
	AADD(aCampos,{"TM_EMISSAO","C"                       ,10                        ,0                         })
	AADD(aCampos,{"TM_VENCREA","C"                       ,10                        ,0                         })
	AADD(aCampos,{"TM_BAIXA"  ,"C"                       ,10                        ,0                         })
	AADD(aCampos,{"TM_DIFPAG" ,"N"                       ,17                        ,0                         })
	AADD(aCampos,{"TM_VALOR"  ,FWTamSX3("E1_VALOR")[3]   ,FWTamSX3("E1_VALOR")[1]   ,FWTamSX3("E1_VALOR")[2]   })
	AADD(aCampos,{"TM_SALDO"  ,FWTamSX3("E1_SALDO")[3]   ,FWTamSX3("E1_SALDO")[1]   ,FWTamSX3("E1_SALDO")[2]   })
	AADD(aCampos,{"TM_VEND1"  ,FWTamSX3("E1_VEND1")[3]   ,FWTamSX3("E1_VEND1")[1]   ,FWTamSX3("E1_VEND1")[2]   })
	AADD(aCampos,{"TM_CGC"    ,FWTamSX3("A1_CGC")[3]     ,FWTamSX3("A1_CGC")[1]     ,FWTamSX3("A1_CGC")[2]     })
	AADD(aCampos,{"TM_SATIV1" ,FWTamSX3("A1_SATIV1")[3]  ,FWTamSX3("A1_SATIV1")[1]  ,FWTamSX3("A1_SATIV1")[2]  })
	AADD(aCampos,{"TM_REDE"   ,FWTamSX3("A1_REDE")[3]    ,FWTamSX3("A1_REDE")[1]    ,FWTamSX3("A1_REDE")[2]    })
	AADD(aCampos,{"TM_NOMREDE",FWTamSX3("ZF_NOMEREDE")[3],FWTamSX3("ZF_NOMEREDE")[1],FWTamSX3("ZF_NOMEREDE")[2]})

	// FINAL Monta os campos da tabela
    
	oTempFat1:SetFields(aCampos)
	//oTempFat1:AddIndex("01", {"TM_FILIAL+TM_PREFIXO+TM_NUM+TM_PARCELA+TM_TIPO"} )
	
	//------------------
	//Criação da tabela
	//------------------
	oTempFat1:Create()

	IF nplanfat == 1 //Ano

		cDataIniFat  := DTOS(FIRSTYDATE(CTOD("01/01/" + SUBSTR(TEMPFAT->TM_DATA,1,4))))
		cDataFinFat  := DTOS(LASTYDATE(CTOD("01/01/" + SUBSTR(TEMPFAT->TM_DATA,1,4))))

	ELSEIF nplanfat == 2 //MES

		cDataIniFat  := DTOS(FIRSTDATE(CTOD("01/" + SUBSTR(TEMPFAT->TM_DATA,6,2) + "/" + SUBSTR(TEMPFAT->TM_DATA,1,4))))
		cDataFinFat  := DTOS(LASTDATE(CTOD( "01/" + SUBSTR(TEMPFAT->TM_DATA,6,2) + "/" + SUBSTR(TEMPFAT->TM_DATA,1,4))))

	ELSE // DIA

		cDataIniFat  := DTOS(CTOD(TEMPFAT->TM_DATA))
		cDataFinFat  := DTOS(CTOD(TEMPFAT->TM_DATA))

	ENDIF
	
	//Obtém o script sql para os CNPJS.
	cQuery := sqlTitFat(cDataIniFat,cDataFinFat,cCnpjs)
	
	IF EMPTY(cQuery)

		RESTAREA(aArea)
		RETURN .F.

	ENDIF

	IF SELECT("D_TITULOS") > 0

		D_TITULOS->(DBCLOSEAREA())

	ENDIF

	TCQUERY cQuery NEW ALIAS "D_TITULOS"

	DBSELECTAREA("D_TITULOS")
	D_TITULOS->(DBGOTOP())
	WHILE !D_TITULOS->(EOF())

		RECLOCK("TITFAT",.T.)

			TITFAT->TM_FILIAL  := D_TITULOS->E1_FILIAL
			TITFAT->TM_PREFIXO := D_TITULOS->E1_PREFIXO
			TITFAT->TM_NUM     := D_TITULOS->E1_NUM 
			TITFAT->TM_PARCELA := D_TITULOS->E1_PARCELA
			TITFAT->TM_TIPO    := D_TITULOS->E1_TIPO
			TITFAT->TM_PORTADO := D_TITULOS->E1_PORTADO
			TITFAT->TM_CLIENTE := D_TITULOS->E1_CLIENTE
			TITFAT->TM_LOJA    := D_TITULOS->E1_LOJA
			TITFAT->TM_NOMCLI  := D_TITULOS->E1_NOMCLI
			TITFAT->TM_EMISSAO := DTOC(STOD(D_TITULOS->E1_EMISSAO))
			TITFAT->TM_VENCREA := DTOC(STOD(D_TITULOS->E1_VENCREA))
			TITFAT->TM_BAIXA   := DTOC(STOD(D_TITULOS->E1_BAIXA))
			TITFAT->TM_DIFPAG  := IIF(ALLTRIM(D_TITULOS->E1_BAIXA) <> '',STOD(D_TITULOS->E1_BAIXA) - STOD(D_TITULOS->E1_VENCREA),0)
			TITFAT->TM_VALOR   := D_TITULOS->E1_VALOR
			TITFAT->TM_SALDO   := D_TITULOS->E1_SALDO
			TITFAT->TM_VEND1   := D_TITULOS->E1_VEND1
			TITFAT->TM_CGC     := D_TITULOS->A1_CGC
			TITFAT->TM_SATIV1  := D_TITULOS->A1_SATIV1
			TITFAT->TM_REDE    := D_TITULOS->A1_CODRED
			TITFAT->TM_NOMREDE := Posicione("SZF",3,xFilial("SZF")+D_TITULOS->A1_CODRED,"ZF_NOMERED")
	
		MSUNLOCK()
		
		D_TITULOS->(DBSKIP())

	ENDDO

	D_TITULOS->(DBGOTOP())
	TITFAT->(DBGOTOP())

	oTelaTitFat			  := MsDialog():Create()
	oTelaTitFat:cName     := "oTelaTit"
	oTelaTitFat:cCaption  := "Detalhe dos Titulos: " + DTOC(DATE()) + " às " + TIME()
	oTelaTitFat:nLeft     := 0 
	oTelaTitFat:nTop      := 0 
	oTelaTitFat:nWidth    := 1340
	oTelaTitFat:nHeight   := 630
	oTelaTitFat:lShowHint := .F.
	oTelaTitFat:lCentered := .T.

	oBrowTitFat:= TCBrowse():New(01,01,665,300,,,,oTelaTitFat,,,,,,,,,,,,,"TITFAT",.T.,,,,.T.,)
    
	oBrowTitFat:AddColumn(TCColumn():New("Filial"      ,{|| TITFAT->TM_FILIAL}                                  ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Prefixo"     ,{|| TITFAT->TM_PREFIXO}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Num"         ,{|| TITFAT->TM_NUM}                                     ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Parcela"     ,{|| TITFAT->TM_PARCELA}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Tipo"        ,{|| TITFAT->TM_TIPO}                                    ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Portador"    ,{|| TITFAT->TM_PORTADO}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Cliente"     ,{|| TITFAT->TM_CLIENTE}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Loja"        ,{|| TITFAT->TM_LOJA}                                    ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Nome Cliente",{|| TITFAT->TM_NOMCLI}                                  ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Emissão"     ,{|| TITFAT->TM_EMISSAO}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Vencimento"  ,{|| TITFAT->TM_VENCREA}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Baixa"       ,{|| TITFAT->TM_BAIXA}                                   ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Dif Pag"     ,{|| TITFAT->TM_DIFPAG}                                  ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Valor"       ,{|| TRANSFORM(TITFAT->TM_VALOR,"@E 999,999,999,999.99")},,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Saldo"       ,{|| TRANSFORM(TITFAT->TM_SALDO,"@E 999,999,999,999.99")},,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Vendedor"    ,{|| TITFAT->TM_VEND1}                                   ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("CGC"         ,{|| TITFAT->TM_CGC}                                     ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("SATIV1"      ,{|| TITFAT->TM_SATIV1}                                  ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Rede"        ,{|| TITFAT->TM_REDE}                                    ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Nome Rede"   ,{|| TITFAT->TM_NOMREDE}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
    
	oTelaTitFat:Activate(,,,.T.,{||.T.},,{||.T.})

	D_TITULOS->(DBCLOSEAREA())
	TITFAT->(DBCLOSEAREA())

RETURN(NIL)

STATIC FUNCTION sqlTitFat(cDataIniFat,cDataFinFat,cCnpjs)
	
	Local cQuery:= ""
	
	cQuery += " SELECT E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_VALOR,E1_SALDO,E1_EMISSAO,E1_VENCREA,E1_PORTADO,E1_CLIENTE,E1_LOJA,E1_NOMCLI,E1_BAIXA,E1_VEND1,A1_CGC,A1_SATIV1,A1_CODRED "
	cQuery+= "  FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
	cQuery+= " INNER JOIN " + RETSQLNAME("SA1") + " SA1 WITH (NOLOCK) "
	cQuery += "         ON A1_COD          = E1_CLIENTE "
	cQuery += "        AND A1_LOJA         = E1_LOJA "
	cQuery += "        AND A1_CGC         IN (" + cCnpjs + ") "
	cQuery += "        AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE E1_EMISSAO          >= '" + cDataIniFat + "' " 
	cQuery += "   AND E1_EMISSAO          <= '" + cDataFinFat + "' "
	cQuery += "   AND E1_TIPO              = 'NF' " 
	cQuery += "   AND SE1.D_E_L_E_T_      <> '*' "
	cQuery += "   ORDER BY E1_NUM "
	
Return cQuery

STATIC FUNCTION DBCLICKFIN(cCnpjs) 

	LOCAL oTelaTitFin  := NIL
	Local oBrowTitFin  := NIL
	Local cDataIniFin  := ''
	Local cDataFinFin  := ''

	// *** INICIO VALIDACAO

	IF SUBSTR(TEMPFIN->TM_DATA,1,1) $ "M/A/T" // COMPARACAO COM MÊS/ANO/TOTAL

		MSGALERT("Não é possivel ver detalhes de Titulos de Linhas de Mês Ano e Total eles são somente demonstrativos","DBCLICKFAT")

		RETURN(NIL)

	ENDIF

	// *** FINAL VALIDACAO

	//Cria Arquivos Temporários
	oTempFin1 := FWTemporaryTable():New("TITFIN")

	// INICIO Monta os campos da tabela
	aCampos := {}
	AADD(aCampos,{"TM_FILIAL" ,FWTamSX3("E1_FILIAL")[3]  ,FWTamSX3("E1_FILIAL")[1]  ,FWTamSX3("E1_FILIAL")[2]  })	
	AADD(aCampos,{"TM_PREFIXO",FWTamSX3("E1_PREFIXO")[3] ,FWTamSX3("E1_PREFIXO")[1] ,FWTamSX3("E1_PREFIXO")[2] })
	AADD(aCampos,{"TM_NUM"    ,FWTamSX3("E1_NUM")[3]     ,FWTamSX3("E1_NUM")[1]     ,FWTamSX3("E1_NUM")[2]     })
	AADD(aCampos,{"TM_PARCELA",FWTamSX3("E1_PARCELA")[3] ,FWTamSX3("E1_PARCELA")[1] ,FWTamSX3("E1_PARCELA")[2] })
	AADD(aCampos,{"TM_TIPO"   ,FWTamSX3("E1_TIPO")[3]    ,FWTamSX3("E1_TIPO")[1]    ,FWTamSX3("E1_TIPO")[2]    })
	AADD(aCampos,{"TM_PORTADO",FWTamSX3("E1_PORTADO")[3] ,FWTamSX3("E1_PORTADO")[1] ,FWTamSX3("E1_PORTADO")[2] })
	AADD(aCampos,{"TM_CLIENTE",FWTamSX3("E1_CLIENTE")[3] ,FWTamSX3("E1_CLIENTE")[1] ,FWTamSX3("E1_CLIENTE")[2] })
	AADD(aCampos,{"TM_LOJA"   ,FWTamSX3("E1_LOJA")[3]    ,FWTamSX3("E1_LOJA")[1]    ,FWTamSX3("E1_LOJA")[2]    })
	AADD(aCampos,{"TM_NOMCLI" ,FWTamSX3("E1_NOMCLI")[3]  ,FWTamSX3("E1_NOMCLI")[1]  ,FWTamSX3("E1_NOMCLI")[2]  })
	AADD(aCampos,{"TM_EMISSAO","C"                       ,10                        ,0                         })
	AADD(aCampos,{"TM_VENCREA","C"                       ,10                        ,0                         })
	AADD(aCampos,{"TM_BAIXA"  ,"C"                       ,10                        ,0                         })
	AADD(aCampos,{"TM_DIFPAG" ,"N"                       ,17                        ,0                         })
	AADD(aCampos,{"TM_VALOR"  ,FWTamSX3("E1_VALOR")[3]   ,FWTamSX3("E1_VALOR")[1]   ,FWTamSX3("E1_VALOR")[2]   })
	AADD(aCampos,{"TM_SALDO"  ,FWTamSX3("E1_SALDO")[3]   ,FWTamSX3("E1_SALDO")[1]   ,FWTamSX3("E1_SALDO")[2]   })
	AADD(aCampos,{"TM_VEND1"  ,FWTamSX3("E1_VEND1")[3]   ,FWTamSX3("E1_VEND1")[1]   ,FWTamSX3("E1_VEND1")[2]   })
	AADD(aCampos,{"TM_CGC"    ,FWTamSX3("A1_CGC")[3]     ,FWTamSX3("A1_CGC")[1]     ,FWTamSX3("A1_CGC")[2]     })
	AADD(aCampos,{"TM_SATIV1" ,FWTamSX3("A1_SATIV1")[3]  ,FWTamSX3("A1_SATIV1")[1]  ,FWTamSX3("A1_SATIV1")[2]  })
	AADD(aCampos,{"TM_REDE"   ,FWTamSX3("A1_REDE")[3]    ,FWTamSX3("A1_REDE")[1]    ,FWTamSX3("A1_REDE")[2]    })
	AADD(aCampos,{"TM_NOMREDE",FWTamSX3("ZF_NOMEREDE")[3],FWTamSX3("ZF_NOMEREDE")[1],FWTamSX3("ZF_NOMEREDE")[2]})

	// FINAL Monta os campos da tabela
    
	oTempFin1:SetFields(aCampos)
	//oTempFin1:AddIndex("01", {"TM_FILIAL+TM_PREFIXO+TM_NUM+TM_PARCELA+TM_TIPO"} )
	
	//------------------
	//Criação da tabela
	//------------------
	oTempFin1:Create()

	IF nplanfin == 1 //Ano

		cDataIniFin  := DTOS(FIRSTYDATE(CTOD("01/01/" + SUBSTR(TEMPFIN->TM_DATA,1,4))))
		cDataFinFin  := DTOS(LASTYDATE(CTOD("01/01/" + SUBSTR(TEMPFIN->TM_DATA,1,4))))

	ELSEIF nplanfin == 2 //MES

		cDataIniFin  := DTOS(FIRSTDATE(CTOD("01/" + SUBSTR(TEMPFIN->TM_DATA,6,2) + "/" + SUBSTR(TEMPFIN->TM_DATA,1,4))))
		cDataFinFin  := DTOS(LASTDATE(CTOD( "01/" + SUBSTR(TEMPFIN->TM_DATA,6,2) + "/" + SUBSTR(TEMPFIN->TM_DATA,1,4))))

	ELSE // DIA

		cDataIniFin  := DTOS(CTOD(TEMPFIN->TM_DATA))
		cDataFinFin  := DTOS(CTOD(TEMPFIN->TM_DATA))

	ENDIF
	
	//Obtém o script sql para os CNPJS.
	cQuery := sqlTitFin(cDataIniFin,cDataFinFin,cCnpjs)
	
	IF EMPTY(cQuery)

		RESTAREA(aArea)
		RETURN .F.

	ENDIF

	IF SELECT("D_TITULOS") > 0

		D_TITULOS->(DBCLOSEAREA())

	ENDIF

	TCQUERY cQuery NEW ALIAS "D_TITULOS"

	DBSELECTAREA("D_TITULOS")
	D_TITULOS->(DBGOTOP())
	WHILE !D_TITULOS->(EOF())

		RECLOCK("TITFIN",.T.)

			TITFIN->TM_FILIAL  := D_TITULOS->E1_FILIAL
			TITFIN->TM_PREFIXO := D_TITULOS->E1_PREFIXO
			TITFIN->TM_NUM     := D_TITULOS->E1_NUM 
			TITFIN->TM_PARCELA := D_TITULOS->E1_PARCELA
			TITFIN->TM_TIPO    := D_TITULOS->E1_TIPO
			TITFIN->TM_PORTADO := D_TITULOS->E1_PORTADO
			TITFIN->TM_CLIENTE := D_TITULOS->E1_CLIENTE
			TITFIN->TM_LOJA    := D_TITULOS->E1_LOJA
			TITFIN->TM_NOMCLI  := D_TITULOS->E1_NOMCLI
			TITFIN->TM_EMISSAO := DTOC(STOD(D_TITULOS->E1_EMISSAO))
			TITFIN->TM_VENCREA := DTOC(STOD(D_TITULOS->E1_VENCREA))
			TITFIN->TM_BAIXA   := DTOC(STOD(D_TITULOS->E1_BAIXA))
			TITFIN->TM_DIFPAG  := IIF(ALLTRIM(D_TITULOS->E1_BAIXA) <> '',STOD(D_TITULOS->E1_BAIXA) - STOD(D_TITULOS->E1_VENCREA),0)
			TITFIN->TM_VALOR   := D_TITULOS->E1_VALOR
			TITFIN->TM_SALDO   := D_TITULOS->E1_SALDO
			TITFIN->TM_VEND1   := D_TITULOS->E1_VEND1
			TITFIN->TM_CGC     := D_TITULOS->A1_CGC
			TITFIN->TM_SATIV1  := D_TITULOS->A1_SATIV1
			TITFIN->TM_REDE    := D_TITULOS->A1_CODRED
			TITFIN->TM_NOMREDE := Posicione("SZF",3,xFilial("SZF")+D_TITULOS->A1_CODRED,"ZF_NOMERED")
	
		MSUNLOCK()
		
		D_TITULOS->(DBSKIP())

	ENDDO

	D_TITULOS->(DBGOTOP())
	TITFIN->(DBGOTOP())

	oTelaTitFin			  := MsDialog():Create()
	oTelaTitFin:cName     := "oTelaTit"
	oTelaTitFin:cCaption  := "Detalhe dos Titulos: " + DTOC(DATE()) + " às " + TIME()
	oTelaTitFin:nLeft     := 0 
	oTelaTitFin:nTop      := 0 
	oTelaTitFin:nWidth    := 1340
	oTelaTitFin:nHeight   := 630
	oTelaTitFin:lShowHint := .F.
	oTelaTitFin:lCentered := .T.

	oBrowTitFin:= TCBrowse():New(01,01,665,300,,,,oTelaTitFin,,,,,,,,,,,,,"TITFIN",.T.,,,,.T.,)
    
	oBrowTitFin:AddColumn(TCColumn():New("Filial"      ,{|| TITFIN->TM_FILIAL}                                  ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Prefixo"     ,{|| TITFIN->TM_PREFIXO}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Num"         ,{|| TITFIN->TM_NUM}                                     ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Parcela"     ,{|| TITFIN->TM_PARCELA}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Tipo"        ,{|| TITFIN->TM_TIPO}                                    ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Portador"    ,{|| TITFIN->TM_PORTADO}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Cliente"     ,{|| TITFIN->TM_CLIENTE}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Loja"        ,{|| TITFIN->TM_LOJA}                                    ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Nome Cliente",{|| TITFIN->TM_NOMCLI}                                  ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Emissão"     ,{|| TITFIN->TM_EMISSAO}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Vencimento"  ,{|| TITFIN->TM_VENCREA}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Baixa"       ,{|| TITFIN->TM_BAIXA}                                   ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Dif Pag"     ,{|| TITFIN->TM_DIFPAG}                                  ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Valor"       ,{|| TRANSFORM(TITFIN->TM_VALOR,"@E 999,999,999,999.99")},,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Saldo"       ,{|| TRANSFORM(TITFIN->TM_SALDO,"@E 999,999,999,999.99")},,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Vendedor"    ,{|| TITFIN->TM_VEND1}                                   ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("CGC"         ,{|| TITFIN->TM_CGC}                                     ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("SATIV1"      ,{|| TITFIN->TM_SATIV1}                                  ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Rede"        ,{|| TITFIN->TM_REDE}                                    ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Nome Rede"   ,{|| TITFIN->TM_NOMREDE}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
    
	oTelaTitFin:Activate(,,,.T.,{||.T.},,{||.T.})

	D_TITULOS->(DBCLOSEAREA())
	TITFIN->(DBCLOSEAREA())

RETURN(NIL)

STATIC FUNCTION sqlTitFin(cDataIniFin,cDataFinFin,cCnpjs)
	
	Local cQuery:= ""
	
	cQuery += " SELECT E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_VALOR,E1_SALDO,E1_EMISSAO,E1_VENCREA,E1_PORTADO,E1_CLIENTE,E1_LOJA,E1_NOMCLI,E1_BAIXA,E1_VEND1,A1_CGC,A1_SATIV1,A1_CODRED "
	cQuery += "  FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
	cQuery += " INNER JOIN " + RETSQLNAME("SA1") + " SA1 WITH (NOLOCK) "
	cQuery += "         ON A1_COD          = E1_CLIENTE "
	cQuery += "        AND A1_LOJA         = E1_LOJA "
	cQuery += "        AND A1_CGC         IN (" + cCnpjs + ") "
	cQuery += "        AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE E1_VENCREA          >= '" + cDataIniFin + "' " 
	cQuery += "   AND E1_VENCREA          <= '" + cDataFinFin + "' " 
	cQuery += "   AND E1_SALDO             > 0 "
	cQuery += "   AND E1_TIPO              = 'NF' "
	cQuery += "   AND SE1.D_E_L_E_T_      <> '*' "
	cQuery += "   ORDER BY E1_NUM "
	
Return cQuery

Static Function logAcesso(cRotina)

	Local aArea		:= GetArea()

	cRotina := Alltrim(cValToChar(cRotina))

	//Log.
	RecLock("ZBE",.T.)
	ZBE->ZBE_FILIAL := xFilial("SE1")
	ZBE->ZBE_DATA	:= Date()
	ZBE->ZBE_HORA	:= cValToChar(Time())
	ZBE->ZBE_USUARI	:= cUserName
	ZBE->ZBE_LOG	:= "ACESSO A ROTINA " + cRotina
	ZBE->ZBE_MODULO	:= "FINANCEIRO"
	ZBE->ZBE_ROTINA	:= "ADFIN030P"
	MsUnlock()

	RestArea(aArea)

Return Nil
