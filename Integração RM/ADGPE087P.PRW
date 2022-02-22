#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} User Function ADGPE087P
    Tela de movimentação (Entrega/Devolução) de uniformes.
    @type  Function
    @author Leonardo P. Monteiro
    @since 06/02/2022
    @version version
    @history Ticket: TI - 06/02/2022 - LEONARDO PINHEIRO MONTEIRO - Desenvolvimento.

    U_ADGPE087P()
/*/

#DEFINE CAMPOS_UNIF_ENTREGA     "ZHH_CODIGO,ZHH_DESCRI,ZHI_UM,TMP_SALDO,ZI5_QTDUNF,ZHK_NUMKIT,ZHI_PRODUT"
#DEFINE CAMPOS_UNIF_DEVOLUCAO   "ZHO_CODZHH,ZHO_UNDESC,ZHO_TAMANH,ZHO_ENTDAT,ZHO_ENTHOR,ZHO_ENTUSU,ZHO_ENTNOM,ZHO_CODZI5,ZHO_DEDESC,ZHO_PRODUT,REGISTRO"
#DEFINE CAMPOS_ARMA_DEVOLUCAO   "ZHL_CODIGO,ZHL_DESCRI,ZHL_MSBLQL,REGISTRO"

#DEFINE CONSULTA_UNIF_ENTREGA      1
#DEFINE CONSULTA_UNIF_DEVOLUCAO    2
#DEFINE CONSULTA_ARMA_DEVOLUCAO    3

user function ADGPE087P()
    
    Local nAlt              := 0
    Local nLarg             := 0
    Local aSize             := {}
    Local aTabs             := {"Uniformes","Armários"}
    Local nBot              := 26
    Local nRight            := 1.9

    Local nRowIni           := 0
    Local nColIni           := 0
    Local nHeiIni           := 0
    Local nWidIni           := 0


    Private cColig          := FWFilial('ZI0')
    
    Private oP1Pnl01
    Private oP2Pnl02
    
    Private oWnd
    Private oLayer
    Private oPesq
    Private oL01C01
    Private oBUnEnt
    Private oBUnDev
    Private oBArDev

    Private oButPesq
    Private oButConf
    Private oButFina

    Private nUnEnCam        := 0
    Private aUnEnCab        := {}
    Private aUnEnCam        := {}
    Private aUnEnDad        := {}
    
    Private nUnDeCam        := 0
    Private aUnDeCab        := {}
    Private aUnDeCam        := {}
    Private aUnDeDad        := {}

    Private nArDeCam        := 0
    Private aArDeCab        := {}
    Private aArDeCam        := {}
    Private aArDeDad        := {}

    Private nBrwFocused     := 0

    Private oTBitmap

    Private oZI1MAT
    Private cZI1MAT         := Space(40)

    Private oZI1CRE
    Private cZI1CREDEN      := Space(40)

    Private oZI1NOM
    Private cZI1NOME        := Space(40)

    Private oZI1SECAO
    Private cZI1SECAO       := Space(100)
    
    Private oTCAMPA
    Private cZI1TCAMPA      := Space(03)

    Private oTBLUTE
    Private cZI1TBLUTE      := Space(03)
    
    Private oTCALPA
    Private cZI1TCALPA      := Space(03)

    Private oTCALTE
    Private cZI1TCALTE      := Space(03)

    Private oTCALCA
    Private cZI1TCALCA      := Space(03)

    Private oTMEIAS
    Private cZI1TMEIAS      := Space(03)

    Private oARMARIO
    Private cZI1CODZHL      := Space(06)

    Private cPesq           := Space(100)

    Private cAlerta         := ""
    Private oAlerta

    Private aTamObj         := {}
    Private bMudaAba	    := {|| fMudaaba() }

    Private bF6             := {|| fGetDados(.T.,.F.), oARMARIO:setFocus() }
    Private bF7             := {|| fConfirm(), fGetDados(.F.,.T.), oPesq:setFocus() }
    Private bF8             := {|| oWnd:End()          }
    Private bF9             := {|| oPesq:setFocus()    }
    Private bRelArm         := {|| U_ADGPE089R() }
    Private bF10            := {|| fGetArma() }
    Private bF11            := {|| fConfArm(), fGetArma() }
    
    Default cTitle   := "..:: Tela de Entrega e Devolução de Uniformes ::.."

    cLayCSS := "QFrame{ margin-top: 15px; } TButton{ margin-bottom: 7px; } TSay{ margin-bottom: 7px; margin-top: 7px; }"    
    
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
    
    oWnd            := Msdialog():Create()
    oWnd:cTitle     := cTitle
    ownd:nWidth     := nLarg
    oWnd:nHeight    := nAlt
    oWnd:lMaximized := .T.
    oWnd:SetCSS("QWidget{ font: bold 15px; } TTabs{ margin: 0px; } ")

    oLayer := FWLayer():new()
    
    oLayer:init(oWnd,.F.)
    oLayer:opanel:nHeight    := nAlt*1.01
    //oLayer:opanel:nHeight    := nAlt*1.01
    //oLayer:opanel:nHeight    := nAlt
    oLayer:addLine("LMAIN",100, .F.)
    oLayer:addCollumn("CMAIN", 100, .F., "LMAIN")
    oLMain  := oLayer:getColPanel("CMAIN","LMAIN")
    
    oSize := FWDefSize():New(.F.)
	oSize:AddObject( "FOLDER"	, 100, 100, .T., .T. )
	
	oSize:lLateral	:= .T. // Elementos um do lado do outro
	oSize:lProp		:= .T. // Cálculo dos botões proporcionais
	oSize:SetWindowSize({000, 000, oLMain:nHeight, oLMain:nWidth})
	oSize:Process() 		// executa os calculos

    oTTabs := TTabs():New(oSize:GetDimension("FOLDER","LININI"),;
                          oSize:GetDimension("FOLDER","COLINI"),;
                          aTabs,Nil,oLMain,Nil,CLR_HRED,Nil,.T.,Nil,;
                          oSize:GetDimension("FOLDER","XSIZE")+001,;
                          oSize:GetDimension("FOLDER","YSIZE")+012)
    oTTabs:SetOption(1)

    U_DefTamObj(@aTamObj,001,001,(oTTabs:nClientHeight / 2)-nBot,(oTTabs:nClientWidth / 2)-nRight)

    nRowIni     := aTamObj[1]
    nColIni     := aTamObj[2]
    nHeiIni     := aTamObj[3]
    nWidIni     := aTamObj[4]

    fPainel1(nRowIni, nColIni, nHeiIni, nWidIni)
    fPainel2(nRowIni, nColIni, nHeiIni, nWidIni)
    
    oTTabs:SetOption(1)
    oTTabs:bAction := bMudaAba
	Eval(bMudaAba)

    oPesq:setFocus()
    oWnd:Activate()

return

Static Function fPainel1(nRow, nCol, nHeight, nWidth)
    
    oP1Pnl01 := TPanel():New(nRow,nCol,'',oTTabs,,,,,,nWidth,nHeight,,.T.)
    oP1Pnl01:lVisibleControl  := .F.

    oCoLay01 := FWLayer():new()
    oCoLay01:init(oP1Pnl01,.T.)

    oCoLay01:addLine("L01",15, .F.)
    oCoLay01:addCollumn("L01C01", 100, .F., "L01")
  
    oCoLay01:addLine("L02",85, .F.)
    oCoLay01:addCollumn("L02C01", 070, .F., "L02")
    oCoLay01:addCollumn("L02C02", 030, .F., "L02")

    oCoLay01:addWindow("L02C01", "Win01", "Uniformes para Entrega"    , 050,.F.,.F.,{||"" },"L02",{||""})
    oCoLay01:addWindow("L02C01", "Win03", "Uniformes para Devolução"  , 050,.F.,.F.,{||"" },"L02",{||""})

    oCoLay01:addWindow("L02C02", "Win02", "Dados do Colaborador"		, 100,.F.,.F.,{||"" },"L02",{||""})

    oL01C01 := oCoLay01:getColPanel("L01C01", "L01")
    oSize := FWDefSize():New(.F.)
	
    oSize:AddObject( "OBJ01"	, 50, 50, .T., .T. )
    oSize:AddObject( "OBJ02"	, 30, 50, .T., .T. )
    oSize:AddObject( "OBJ03"	, 10, 50, .T., .T. )
    oSize:AddObject( "OBJ04"	, 10, 50, .T., .T. )
    oSize:AddObject( "OBJ05"	, 10, 50, .T., .T. )
	oSize:lLateral	:= .T. // Elementos um do lado do outro
	oSize:lProp		:= .T. // Cálculo dos botões proporcionais
	oSize:SetWindowSize({000, 000, oL01C01:nHeight, oL01C01:nWidth})
	oSize:Process() 		// executa os calculos

    // Layout pesquisa
    layPesq(nRow, nCol, nHeight, nWidth)
    
    // Layout listagem
    layList(nRow, nCol, nHeight, nWidth)
RETURN

Static Function fPainel2(nRow, nCol, nHeight, nWidth)

    oP2Pnl02 := TPanel():New(nRow,nCol,'',oTTabs,,,,,,nWidth,nHeight,,.T.)
    oP2Pnl02:lVisibleControl  := .F.

    oP2Lay02 := FWLayer():new()
    oP2Lay02:init(oP2Pnl02,.T.)

    oP2Lay02:addLine("L01",80, .F.)
    oP2Lay02:addCollumn("L01C01", 100, .F., "L01")
    oP2Lay02:addWindow("L01C01", "Win01", "Armários liberados para inspeção"    , 100,.F.,.F.,{||"" },"L01",{||""})

    oP2Lay02:addLine("L02",20, .F.)
    oP2Lay02:addCollumn("L02C01", 100, .F., "L02")
    oP2Lay02:addWindow("L02C01", "Win02", "Ações"		, 100,.F.,.F.,{||"" },"L02",{||""})

    //oP2Lay02:show()

    //-------------------------------------------------------------------
    // Opções, botões com ações do painél
    //-------------------------------------------------------------------

    oP2Win01    := oP2Lay02:GetWinPanel("L01C01","Win01","L01")

    oBArDev     := FWBrowse():New(oP2Win01)
    
    aArDeCab	:= getCampos(CONSULTA_ARMA_DEVOLUCAO)
    aArDeDad    := getDadoBRW(CONSULTA_ARMA_DEVOLUCAO)

    oBArDev:bGotFocus := {|| nBrwFocused := CONSULTA_ARMA_DEVOLUCAO}
    oBArDev:addMarkColumns({|oBmark| fMark(oBMark, CONSULTA_ARMA_DEVOLUCAO)},; 
                           {|oBMark| fDblClk(oBmark, CONSULTA_ARMA_DEVOLUCAO) /*Função DoubleClick*/ },; 
                           {|oBmark| /* fHeaClk(oBmark, CONSULTA_UNIF_ENTREGA) Função de HEADERCLICK*/})
    
    oBArDev:setColumns(aArDeCab)
	oBArDev:setDataArray()
	oBArDev:disableReport()
	oBArDev:disableConfig()
    
    oBArDev:setArray(aArDeDad)
    oBArDev:Activate()

    //-------------------------------------------------------------------
    // Opções, botões com ações do painél
    //-------------------------------------------------------------------

    oP2Win02    := oP2Lay02:GetWinPanel("L02C01","Win02","L02")
    oSize := FWDefSize():New(.F.)
	
    oSize:AddObject( "OBJ01"	, 55, 50, .T., .T. )
    oSize:AddObject( "OBJ02"	, 15, 50, .T., .T. )
    oSize:AddObject( "OBJ03"	, 15, 50, .T., .T. )
    oSize:AddObject( "OBJ04"	, 15, 50, .T., .T. )
	oSize:lLateral	:= .T. // Elementos um do lado do outro
	oSize:lProp		:= .T. // Cálculo dos botões proporcionais
	oSize:SetWindowSize({000, 000, oP2Win02:nHeight, oP2Win02:nWidth})
	oSize:Process() 		// executa os calculos

    oButRelArm := TButton():New( 2, oSize:GetDimension("OBJ02","COLINI"), "Rel. Armário", oP2Win02, bRelArm,;
    oSize:GetDimension("OBJ02","XSIZE"),oSize:GetDimension("OBJ02","YSIZE")-02,,,.F.,.T.,.F.,,.F.,,,.F. )
    
    oButAtual := TButton():New( 2, oSize:GetDimension("OBJ03","COLINI"), "Atualiza [F10]", oP2Win02, bF10,;
    oSize:GetDimension("OBJ03","XSIZE"),oSize:GetDimension("OBJ03","YSIZE")-02,,,.F.,.T.,.F.,,.F.,,,.F. )

    oButConAr := TButton():New( 2, oSize:GetDimension("OBJ04","COLINI"), "Confirmar [F11]", oP2Win02, bF11,;
    oSize:GetDimension("OBJ04","XSIZE"),oSize:GetDimension("OBJ04","YSIZE")-02,,,.F.,.T.,.F.,,.F.,,,.F. )
    
    SetKey( VK_F10,  bF10 )
    SetKey( VK_F11,  bF11 )

return

Static Function fGetArma()
    aArDeDad    := getDadoBRW(CONSULTA_ARMA_DEVOLUCAO)
    oBArDev:setArray(aArDeDad)

    oBArDev:refresh()
return

Static Function fConfArm()
    Local nA        := 1
    Local nRegist   := 0
    Local cQuery    := ""
    Local nPosCod := aScan(aArDeCam,"ZHL_CODIGO")
    Local nPosReg   := aScan(aArDeCam,"REGISTRO")

    nArDeCam    := len(aArDeCam)
    nArDeDad    := Len(aArDeDad)

    if nArDeDad > 0 
        
        nColuna     := Len(aArDeDad[1])-1

        for nA := 1 To nArDeDad
            if aArDeDad[nA, nColuna]
                cProd       := aArDeDad[nA, nPosCod]
                nRegist     := aArDeDad[nA, nPosReg]

                if nRegist > 0
                    DbSelectArea("ZHL")
                    ZHL->(Dbgoto(nRegist))

                    if ZHL->(Recno()) == nRegist

                        cQuery := " SELECT R_E_C_N_O_ REGISTRO "
                        cQuery += " FROM "+ RetSqlName("ZI1") +" "
                        cQuery += " WHERE D_E_L_E_T_='' AND ZI1_CODZHL='"+ ZHL->ZHL_CODIGO +"'; "

                        TcQuery cQuery ALIAS "QZI1" NEW

                        if QZI1->(!EOF())
                            DbSelectArea("ZI1")
                            ZI1->(DBGOTO(QZI1->REGISTRO))

                            if ZI1->(Recno()) == QZI1->REGISTRO

                                // Limpa o registro do armário.
                                RecLock("ZI1", .F.)
                                    ZI1_CODZHL  := ""
                                ZI1->(MsUnlock())

                                DbSelectArea("ZHP")

                                // Registra no histórico.
                                RecLock("ZHP", .T.)
                                    ZHP_FILIAL  := xFilial("ZHP")
                                    ZHP_CODZHL  := ZHL->ZHL_CODIGO
                                    ZHP_MAT     := ZI1->ZI1_MAT
                                    ZHP_NOME    := ZI1->ZI1_NOME
                                    ZHP_DATINC  := Date()
                                    ZHP_HORINC  := Time()
                                    ZHP_USUARI  := AllTrim( __cUserID )
                                    ZHP_NOMUSU  := AllTrim(UsrRetName(__cUserID))
                                ZHP->(MsUnlock())
                            endif

                            ZHP->(Dbclosearea())
                            ZI1->(Dbclosearea())
                        endif

                        QZI1->(Dbclosearea())

                    endif
                endif
            endif
        next nA
    endif
return 

Static Function layPesq(nRow, nCol, nHeight, nWidth)

    //**************************************************
    // Sessão de filtros.
    //**************************************************
    
    oPesq:= TGet():New(002,oSize:GetDimension("OBJ01","COLINI"),{|u|If(PCount() == 0, cPesq, cPesq := u)},oL01C01,oSize:GetDimension("OBJ01","XSIZE"),020,"", {|| fValida("cPesq") },0,16777215,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F. ,,"cPesq",,,,.T.,,,"Pesquisar Matrícula/Credencial/Nome ",1) 
    oPesq:SetCSS("QLineEdit{font-size: 20px; width: 90%;}")
    oPesq:lVisibleControl := .T.
   
    oAlerta := TSay():New(oSize:GetDimension("OBJ02","LININI"),;
                    oSize:GetDimension("OBJ02","COLINI"),;
                    {|| "Mensagens e Alertas:"+chr(13)+chr(10)},oL01C01,,,,,,.T.,CLR_RED,CLR_WHITE,;
                    oSize:GetDimension("OBJ02","XSIZE"),oSize:GetDimension("OBJ02","YSIZE"))
    oAlerta:CtrlRefresh()
    oAlerta:lTransparent = .T.
    oAlerta:lWordWrap = .T.

    oButPesq := TButton():New( 2, oSize:GetDimension("OBJ03","COLINI"), "Pesquisar [F6]", oL01C01, bF6,;
    oSize:GetDimension("OBJ03","XSIZE"),oSize:GetDimension("OBJ03","YSIZE")-02,,,.F.,.T.,.F.,,.F.,,,.F. )

    oButConf := TButton():New( 2, oSize:GetDimension("OBJ04","COLINI"), "Confirmar [F7]", oL01C01, bF7,;
    oSize:GetDimension("OBJ04","XSIZE"),oSize:GetDimension("OBJ04","YSIZE")-02,,,.F.,.T.,.F.,,.F.,,,.F. )
    
    oButFina := TButton():New( 2, oSize:GetDimension("OBJ05","COLINI"), "Finalizar [F8]", oL01C01, bF8,;
    oSize:GetDimension("OBJ05","XSIZE"),oSize:GetDimension("OBJ05","YSIZE")-02,,,.F.,.T.,.F.,,.F.,,,.F. )

    SetKey( VK_F6,  bF6 )
    SetKey( VK_F7,  bF7 )
    SetKey( VK_F8,  bF8 )
    SetKey( VK_F9,  bF9 )
return

Static Function fMudaAba()
    oP1Pnl01:lVisibleControl      := (oTTabs:nOption == 1)
    oP2Pnl02:lVisibleControl      := (oTTabs:nOption == 2)
return

// Ticket: 16835 - 28/10/2021 - ADRIANO SAVOINE
STATIC FUNCTION fValida(cCampo)
    Local lRet      := .T.
    Local cField    := ""

    
    if cCampo == "cPesq"
        fGetDados()
    
    elseif !Empty(cZI1MAT)

        if  (cCampo == "cZI1TCAMPA";
            .OR. cCampo == "cZI1TBLUTE";
            .OR. cCampo == "cZI1TCALPA";
            .OR. cCampo == "cZI1TCALTE";
            .OR. cCampo == "cZI1TCALCA";
            .OR. cCampo == "cZI1TMEIAS")
        
            if cCampo == "cZI1TCAMPA"
                cChave := "01"
                cField := "ZI1_TCAMPA"
            elseif cCampo == "cZI1TBLUTE"
                cChave := "02"
                cField := "ZI1_TBLUTE"
            elseif cCampo == "cZI1TCALPA"
                cChave := "03"
                cField := "ZI1_TCALPA"
            elseif cCampo == "cZI1TCALTE"
                cChave := "04"
                cField := "ZI1_TCALTE"
            elseif cCampo == "cZI1TCALCA"
                cChave := "05"
                cField := "ZI1_TCALCA"
            elseif cCampo == "cZI1TMEIAS"
                cChave := "06"
                cField := "ZI1_TMEIAS"
            endif

            cValor := &(cCampo)
                
            if (vazio() .OR. Existcpo("ZHJ",cChave+cValor,2))
                fGrvZI1(cZI1MAT, cField, cValor)
            endif
            
            fGetDados(.F.,.F.,.F.)

        elseif cCampo == "cZI1CODZHL"
        
            cField := "ZI1_CODZHL"
            cValor := &(cCampo)

            if fVldArm()
                fGrvZI1(cZI1MAT, cField, cValor)
            endif
        
        endif

    endif

    
RETURN lret

Static Function fGrvZI1(cZI1MAT, cCampo, cValor)
    Local lRet      := .T.
    Local cQuery    := ""

    if !Empty(cZI1MAT)
        cQuery := " SELECT R_E_C_N_O_ REGISTRO FROM "+ retsqlname("ZI1") +" WHERE D_E_L_E_T_='' AND ZI1_MAT!='' AND ZI1_MAT='"+ cZI1MAT +"'; "

        Tcquery cQuery ALIAS "QZI1" NEW

        if QZI1->(!EOF())
            DbSelectarea("ZI1")
            ZI1->(Dbgoto(QZI1->Registro))

            if QZI1->registro == ZI1->(Recno())
                if Alltrim(&("ZI1->"+Alltrim(cCampo)) ) != Alltrim(cValor)
                    if reclock("ZI1",.F.)
                        &("ZI1->"+Alltrim(cCampo))   := cValor
                        ZI1->(MsUnlock())
                    endif
                endif
            endif

        endif

        if select("QZI1") > 0
            QZI1->(Dbclosearea())
        endif
    endif
    
return lRet
        

Static Function fVldArm()
    Local lRet := .T.
    // Posiciona no registro do uniforme vinculado ao departamento.
    
    cZI1CODZHL  := Alltrim(cZI1CODZHL)
    cZI1MAT     := Alltrim(cZI1MAT)

    IF !Empty(cZI1CODZHL)
        cQuery := " SELECT ZI1_MAT, ZI1_NOME "
        cQuery += " FROM "+ RetSqlName("ZI1") +" (NOLOCK) "
        cQuery += " WHERE D_E_L_E_T_='' AND ZI1_MAT !='"+ cZI1MAT +"' AND ZI1_CODZHL='"+ cZI1CODZHL +"'; "
        
        Tcquery cQuery ALIAS "QZHL" NEW

        if QZHL->(!EOF())
            lRet := .F.
            //Help( ,, 'HELP',, 'Armário já vinculado ao colaborador '+ Alltrim(QZHL->ZI1_MAT) +'-'+ Alltrim(QZHL->ZI1_NOME) +'!.', 1, 0)
            fAlerta('Armário já vinculado ao colaborador '+ Alltrim(QZHL->ZI1_MAT) +'-'+ Alltrim(QZHL->ZI1_NOME) +'!.')
        ELSE
            fAlerta("")
            lRet := .T.
        endif

        QZHL->(DBCLOSEAREA())
    endif

RETURN lRet

Static Function fAlerta(cMsn)
    oAlerta:setText("Mensagens e Alertas:"+chr(13)+chr(10)+cMsn)
    oAlerta:refresh()
return

Static Function fConfirm()
    Private aZI1SECAO     := {}
    Private cUUID         := FWUUIDV4()
    
    aZI1SECAO   := Separa(cZI1SECAO,"-")

    //ZHH_CODIGO,ZHH_DESCRI,ZHI_UM,ZI5_QTDUNF,ZHK_NUMKIT
    DbSelectArea("ZI0")
    
    if !Empty(cZI1MAT) .and. !Empty(cZI1SECAO)
        if fVldEnv()
            // Processa a entrega.
            fEntrega()
        endif

        // Processa a devolução.
        fDevolucao()

    endif
    
return

Static function fVldEnv()
    Local nA            := 0
    Local nColuna       := 0
    Local lRet          := .T.
    Local nUnEnDad      := Len(aUnEnDad)
    Local nUnDeDad      := Len(aUnDeDad)
    Local nPosCodUni    := aScan(aUnEnCam,"ZHH_CODIGO")
    //Local nPosZHIUM     := aScan(aUnEnCam,"ZHI_UM")
    //Local nPosProdut    := aScan(aUnEnCam,"ZHI_PRODUT")
    Local nPosSaldo     := aScan(aUnEnCam,"TMP_SALDO")
    Local nPosCodZHH    := aScan(aUnDeCam,"ZHO_CODZHH")
    Local nPosEntDat    := aScan(aUnDeCam,"ZHO_ENTDAT")
    Local aValid        := {}
    
    if nUnEnDad > 0
        
        nColuna     := Len(aUnEnDad[1])-1

        for nA := 1 To nUnEnDad
            if aUnEnDad[nA, nColuna]
                cProd       := aUnEnDad[nA, nPosCodUni]
                nSaldo      := aUnEnDad[nA, nPosSaldo]
                
                nLin        := aScan(aValid, {|x| x[1] == cProd})

                if nLin == 0
                    AADD(aValid, {cProd,nSaldo})
                else
                    aValid[nA][02] += nSaldo
                endif
            endif
        next nA
    endif

    if nUnDeDad > 0

        nColuna     := Len(aUnDeDad[1])-1

        for nA := 1 To nUnDeDad
            if aUnDeDad[nA, nColuna]
                cProd       := aUnDeDad[nA, nPosCodZHH]
                nLin        := aScan(aValid, {|x| x[1] == cProd})
                
                if nLin > 0
                    aValid[nLin][2] += 1
                endif
            elseif aUnDeDad[nA, nPosEntDat] < Date()
                fAlerta("Existem itens pendentes de devolução em dias anteriores!")
                lRet := .F.    
            endif
        next nA
    endif

    nValid  := Len(aValid)
    for nA := 1 to nValid
        if aValid[nA][02] < 1
            fAlerta("Não existe saldo para o produto '"+ Alltrim(aValid[nA][01]) +"'.")
            lRet := .F.
        endif
    next nA

return lRet

Static Function fDevolucao()
    Local nA            := 0
    Local nColuna       := 0
    
    Local nUnDeDad      := Len(aUnDeDad)
    Local nPosReg       := aScan(aUnDeCam,"REGISTRO")
    
    
    if nUnDeDad > 0
        
        nColuna     := Len(aUnDeDad[1])-1

        DbSelectArea("ZHO")

        for nA := 1 To nUnDeDad
            if aUnDeDad[nA, nColuna]
                ZHO->(Dbgoto(aUnDeDad[nA, nPosReg]))

                if aUnDeDad[nA, nPosReg] == ZHO->(Recno())
                    RecLock("ZHO", .F.)

                    ZHO_DEVUSU  := __cUserID
                    ZHO_DEVNOM  := UsrFullName(__cUserID)
                    ZHO_DEVDAT  := Date()
                    ZHO_DEVHOR  := Time()
                    ZHO->(MsUnlock())
                endif
            endif
        next nA

    endif
return

Static Function fEntrega()
    Local nA            := 0
    Local nColuna       := 0
    
    Local nUnEnDad      := Len(aUnEnDad)
    Local nPosCodZHH    := aScan(aUnEnCam,"ZHH_CODIGO")
    Local nPosZHIUM     := aScan(aUnEnCam,"ZHI_UM")
    Local nPosProdut    := aScan(aUnEnCam,"ZHI_PRODUT")

    nColuna     := Len(aUnEnDad[1])-1
    
    if nUnEnDad > 0
    
        for nA := 1 To nUnEnDad
            if aUnEnDad[nA, nColuna]
                //nRegist := aItKiDad[nA, nPosReg]
                //cProdut := aItKiDad[nA, nPosPrd]

                RecLock("ZHO", .T.)

                ZHO_FILIAL  := xFilial("ZHO") 
                ZHO_MAT     := cZI1MAT
                ZHO_ENTDAT  := Date()
                ZHO_ENTHOR  := Time()
                ZHO_ENTUSU  := __cUserID
                ZHO_ENTNOM  := UsrFullName(__cUserID)
                //ZHO_RETDAT  := Dtoc(Date())
                //ZHO_RETHOR  := Time()

                ZHO_CODZHH  := aUnEnDad[nA, nPosCodZHH]
                ZHO_CODZI5  := IIF(Len(aZI1SECAO)>=1,aZI1SECAO[1],"")
                ZHO_TAMANH  := aUnEnDad[nA, nPosZHIUM]
                ZHO_PRODUT  := aUnEnDad[nA, nPosProdut]
                ZHO_UUID    := cUUID

                ZHO->(MsUnlock())
            endif
        next nA
    endif
return

Static Function layList(nRow, nCol, nHeight, nWidth)
    
    aUnEnCab	:= getCampos(CONSULTA_UNIF_ENTREGA)
    aUnEnDad    := getDadoBRW(CONSULTA_UNIF_ENTREGA)

    aUnDeCab	:= getCampos(CONSULTA_UNIF_DEVOLUCAO)
    aUnDeDad    := getDadoBRW(CONSULTA_UNIF_DEVOLUCAO)
    
    oItWin01    := oCoLay01:GetWinPanel("L02C01","Win01","L02")
    oItWin03    := oCoLay01:GetWinPanel("L02C01","Win03","L02")

    oBUnEnt     := FWBrowse():New(oItWin01)
    
    oBUnEnt:bGotFocus := {|| nBrwFocused := CONSULTA_UNIF_ENTREGA}
    oBUnEnt:addMarkColumns({|oBmark| fMark(oBMark, CONSULTA_UNIF_ENTREGA)},; 
                           {|oBMark| fDblClk(oBmark, CONSULTA_UNIF_ENTREGA) /*Função DoubleClick*/ },; 
                           {|oBmark| /* fHeaClk(oBmark, CONSULTA_UNIF_ENTREGA) Função de HEADERCLICK*/})
    
    oBUnEnt:setColumns(aUnEnCab)
	oBUnEnt:setDataArray()
	oBUnEnt:disableReport()
	oBUnEnt:disableConfig()
    
    oBUnEnt:setArray(aUnEnDad)
    
    oBUnEnt:Activate()
    
    oBUnDev     := FWBrowse():New(oItWin03)
    
    oBUnDev:bGotFocus := {|| nBrwFocused := CONSULTA_UNIF_DEVOLUCAO}
    oBUnDev:addMarkColumns({|oBmark| fMark(oBMark, CONSULTA_UNIF_DEVOLUCAO)},; 
                           {|oBMark| fDblClk(oBmark, CONSULTA_UNIF_DEVOLUCAO) /*Função DoubleClick*/ },; 
                           {|oBmark| fHeaClk(oBmark, CONSULTA_UNIF_DEVOLUCAO) /* Função de HEADERCLICK*/})
    oBUnDev:setColumns(aUnDeCab)
	oBUnDev:setDataArray()
	oBUnDev:disableReport()
	oBUnDev:disableConfig()
    
    oBUnDev:setArray(aUnDeDad)
    
    oBUnDev:Activate()

    oItWin02    := oCoLay01:GetWinPanel("L02C02","Win02","L02")

    oSize := FWDefSize():New(.F.)
	
    oSize:AddObject( "OBJ01"	, 100 , 12, .T., .T. )
    oSize:AddObject( "OBJ02"	, 100 , 12, .T., .T. )
    oSize:AddObject( "OBJ03"	, 100 , 12, .T., .T. )
    oSize:AddObject( "OBJ04"	, 025 , 12, .T., .T. )
    oSize:AddObject( "OBJ05"	, 025 , 10, .T., .T. )
    oSize:AddObject( "OBJ06"	, 025 , 10, .T., .T. )
    oSize:AddObject( "OBJ07"	, 025 , 12, .T., .T. )
    oSize:AddObject( "OBJ08"	, 025 , 10, .T., .T. )
    oSize:AddObject( "OBJ09"	, 025 , 10, .T., .T. )
    
	oSize:lLateral	:= .F. // Elementos um do lado do outro
	oSize:lProp		:= .T. // Cálculo dos botões proporcionais
	oSize:SetWindowSize({000, 000, oItWin02:nHeight, oItWin02:nWidth})
	oSize:Process()

    oSize2 := FWDefSize():New(.F.)
	
    oSize2:AddObject( "OBJ01"	, 100 , 10, .T., .T. )
    oSize2:AddObject( "OBJ02"	, 100 , 10, .T., .T. )
    oSize2:AddObject( "OBJ03"	, 100 , 10, .T., .T. )
    
	oSize2:lLateral	:= .T. // Elementos um do lado do outro
	oSize2:lProp	:= .T. // Cálculo dos botões proporcionais
	oSize2:SetWindowSize({000, 000, oItWin02:nHeight, oItWin02:nWidth})
	oSize2:Process()

    oSize3 := FWDefSize():New(.F.)
	
    oSize3:AddObject( "OBJ01"	, 100 , 10, .T., .T. )
    oSize3:AddObject( "OBJ02"	, 100 , 10, .T., .T. )
    
	oSize3:lLateral	:= .T. // Elementos um do lado do outro
	oSize3:lProp	:= .T. // Cálculo dos botões proporcionais
	oSize3:SetWindowSize({000, 000, oItWin02:nHeight, oItWin02:nWidth})
	oSize3:Process()
    
    aRet := fgetSX3("ZI1_MAT")
	oZI1MAT  := TGet():New(oSize:GetDimension("OBJ01","LININI"),;
                           oSize3:GetDimension("OBJ01","COLINI"),; 
                           {|u|If(PCount() == 0, cZI1MAT, cZI1MAT := u)}, oItWin02,; 
                           oSize3:GetDimension("OBJ01","XSIZE"), 012,;
                           ,aRet[01][06],0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cZI0MAT",;
                           ,,,.T.,,,aRet[01][01],1)
    oZI1MAT:SetCSS("QLineEdit{font-size: 15px;}")
	if !Empty(aRet[01][09])
        oZI1MAT:cF3 := Alltrim(aRet[01][09])
    endif
    oZI1MAT:lVisibleControl := .T.

    aRet := fgetSX3("ZI1_CREDEN")
	oZI1CRE  := TGet():New(oSize:GetDimension("OBJ01","LININI"),;
                           oSize3:GetDimension("OBJ02","COLINI"),; 
                           {|u|If(PCount() == 0, cZI1CREDEN, cZI1CREDEN := u)}, oItWin02,; 
                           oSize3:GetDimension("OBJ02","XSIZE"), 012,;
                           ,aRet[01][06],0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cZI1CREDEN",;
                           ,,,.T.,,,aRet[01][01],1)
    oZI1CRE:SetCSS("QLineEdit{font-size: 15px;}")
	if !Empty(aRet[01][09])
        oZI1CRE:cF3 := Alltrim(aRet[01][09])
    endif
    oZI1CRE:lVisibleControl := .T.

    aRet := fgetSX3("ZI1_NOME")
	oZI1NOM  := TGet():New(oSize:GetDimension("OBJ02","LININI"),;
                           oSize:GetDimension("OBJ02","COLINI"),; 
                           {|u|If(PCount() == 0, cZI1NOME, cZI1NOME := u)}, oItWin02,; 
                           oSize:GetDimension("OBJ02","XSIZE"), 014,;
                           ,aRet[01][06],0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cZI1NOME",;
                           ,,,.T.,,,aRet[01][01],1)
    oZI1NOM:SetCSS("QLineEdit{font-size: 15px;}")
	if !Empty(aRet[01][09])
        oZI1NOM:cF3 := Alltrim(aRet[01][09])
    endif
    oZI1NOM:lVisibleControl := .T.

    aRet := fgetSX3("ZI1_SECAO")
	oZI1NOM  := TGet():New(oSize:GetDimension("OBJ03","LININI"),;
                           oSize:GetDimension("OBJ03","COLINI"),; 
                           {|u|If(PCount() == 0, cZI1SECAO, cZI1SECAO := u)}, oItWin02,; 
                           oSize:GetDimension("OBJ03","XSIZE"), 014,;
                           ,aRet[01][06],0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cZI1SECAO",;
                           ,,,.T.,,,aRet[01][01],1)
    oZI1NOM:SetCSS("QLineEdit{font-size: 15px;}")
	/*
    if !Empty(aRet[01][09])
        oZI1NOM:cF3 := Alltrim(aRet[01][09])
    endif
    */
    oZI1NOM:lVisibleControl := .T.
    
    oSay1:= TSay():New(oSize:GetDimension("OBJ04","LININI"),;
                    oSize:GetDimension("OBJ04","COLINI"),;
                    {|| Chr(13)+chr(10)+'::.. Cadastro de Uniformes'},oItWin02,,,,,,.T.,CLR_RED,CLR_WHITE,;
                    oSize:GetDimension("OBJ04","XSIZE"),20)

    aRet := fgetSX3("ZI1_TCAMPA")
	oTCAMPA  := TGet():New(oSize:GetDimension("OBJ05","LININI"),;
                           oSize2:GetDimension("OBJ01","COLINI"),; 
                           {|u|If(PCount() == 0, cZI1TCAMPA, cZI1TCAMPA := u)}, oItWin02,; 
                           oSize2:GetDimension("OBJ01","XSIZE"), 010,;
                           ,{|| fValida("cZI1TCAMPA") },0,16777215,,.F.,,.T.,,.F.,{|| !Empty(cZI1MAT) .and. !Empty(cZI1CREDEN) },.F.,.F.,,.F.,.F. ,,"cZI1TCAMPA",;
                           ,,,.T.,,,aRet[01][01],1)
    oTCAMPA:SetCSS("QLineEdit{font-size: 15px;}")
	if !Empty(aRet[01][09])
        oTCAMPA:cF3 := Alltrim(aRet[01][09])
    endif
    oTCAMPA:lVisibleControl := .T.

    aRet := fgetSX3("ZI1_TBLUTE")
	oTBLUTE  := TGet():New(oSize:GetDimension("OBJ05","LININI"),;
                           oSize2:GetDimension("OBJ02","COLINI"),; 
                           {|u|If(PCount() == 0, cZI1TBLUTE, cZI1TBLUTE := u)}, oItWin02,; 
                           oSize2:GetDimension("OBJ02","XSIZE"), 010,;
                           ,{|| fValida("cZI1TBLUTE") },0,16777215,,.F.,,.T.,,.F.,{|| !Empty(cZI1MAT) .and. !Empty(cZI1CREDEN) },.F.,.F.,,.F.,.F. ,,"cZI1TBLUTE",;
                           ,,,.T.,,,aRet[01][01],1)
    oTBLUTE:SetCSS("QLineEdit{font-size: 15px;}")
	if !Empty(aRet[01][09])
        oTBLUTE:cF3 := Alltrim(aRet[01][09])
    endif
    oTBLUTE:lVisibleControl := .T.

    aRet := fgetSX3("ZI1_TCALPA")
	oTCALPA  := TGet():New(oSize:GetDimension("OBJ05","LININI"),;
                           oSize2:GetDimension("OBJ03","COLINI"),; 
                           {|u|If(PCount() == 0, cZI1TCALPA, cZI1TCALPA := u)}, oItWin02,; 
                           oSize2:GetDimension("OBJ03","XSIZE"), 010,;
                           ,{|| fValida("cZI1TCALPA") },0,16777215,,.F.,,.T.,,.F.,{|| !Empty(cZI1MAT) .and. !Empty(cZI1CREDEN) },.F.,.F.,,.F.,.F. ,,"cZI1TCALPA",;
                           ,,,.T.,,,aRet[01][01],1)
    oTCALPA:SetCSS("QLineEdit{font-size: 15px;}")
	if !Empty(aRet[01][09])
        oTCALPA:cF3 := Alltrim(aRet[01][09])
    endif
    oTCALPA:lVisibleControl := .T.

    aRet := fgetSX3("ZI1_TCALTE")
	oTCALTE  := TGet():New(oSize:GetDimension("OBJ06","LININI"),;
                           oSize2:GetDimension("OBJ01","COLINI"),; 
                           {|u|If(PCount() == 0, cZI1TCALTE, cZI1TCALTE := u)}, oItWin02,; 
                           oSize2:GetDimension("OBJ01","XSIZE"), 010,;
                           ,{|| fValida("cZI1TCALTE") },0,16777215,,.F.,,.T.,,.F.,{|| !Empty(cZI1MAT) .and. !Empty(cZI1CREDEN) },.F.,.F.,,.F.,.F. ,,"cZI1TCALTE",;
                           ,,,.T.,,,aRet[01][01],1)
    oTCALTE:SetCSS("QLineEdit{font-size: 15px;}")
	if !Empty(aRet[01][09])
        oTCALTE:cF3 := Alltrim(aRet[01][09])
    endif
    oTCALTE:lVisibleControl := .T.

    aRet := fgetSX3("ZI1_TCALCA")
	oTCALCA  := TGet():New(oSize:GetDimension("OBJ06","LININI"),;
                           oSize2:GetDimension("OBJ02","COLINI"),; 
                           {|u|If(PCount() == 0, cZI1TCALCA, cZI1TCALCA := u)}, oItWin02,; 
                           oSize2:GetDimension("OBJ02","XSIZE"), 010,;
                           ,{|| fValida("cZI1TCALCA") },0,16777215,,.F.,,.T.,,.F.,{|| !Empty(cZI1MAT) .and. !Empty(cZI1CREDEN) },.F.,.F.,,.F.,.F. ,,"cZI1TCALCA",;
                           ,,,.T.,,,aRet[01][01],1)
    oTCALCA:SetCSS("QLineEdit{font-size: 15px;}")
	if !Empty(aRet[01][09])
        oTCALCA:cF3 := Alltrim(aRet[01][09])
    endif
    oTCALCA:lVisibleControl := .T.

    aRet := fgetSX3("ZI1_TMEIAS")
	oTMEIAS  := TGet():New(oSize:GetDimension("OBJ06","LININI"),;
                           oSize2:GetDimension("OBJ03","COLINI"),; 
                           {|u|If(PCount() == 0, cZI1TMEIAS, cZI1TMEIAS := u)}, oItWin02,; 
                           oSize2:GetDimension("OBJ03","XSIZE"), 010,;
                           ,{|| fValida("cZI1TMEIAS") },0,16777215,,.F.,,.T.,,.F.,{|| !Empty(cZI1MAT) .and. !Empty(cZI1CREDEN) },.F.,.F.,,.F.,.F. ,,"cZI1TMEIAS",;
                           ,,,.T.,,,aRet[01][01],1)
    oTMEIAS:SetCSS("QLineEdit{font-size: 15px;}")
	if !Empty(aRet[01][09])
        oTMEIAS:cF3 := Alltrim(aRet[01][09])
    endif
    oTMEIAS:lVisibleControl := .T.

    oSay2:= TSay():New(oSize:GetDimension("OBJ07","LININI"),;
                    oSize:GetDimension("OBJ06","COLINI"),;
                    {||Chr(13)+chr(10)+'::.. Cadastro de Uniformes'},oItWin02,,,,,,.T.,CLR_RED,CLR_WHITE,;
                    oSize:GetDimension("OBJ06","XSIZE"),20)

    aRet := fgetSX3("ZI1_CODZHL")
	oARMARIO  := TGet():New(oSize:GetDimension("OBJ08","LININI"),;
                           oSize3:GetDimension("OBJ01","COLINI"),; 
                           {|u|If(PCount() == 0, cZI1CODZHL, cZI1CODZHL := u)}, oItWin02,; 
                           oSize3:GetDimension("OBJ01","XSIZE"), 010,;
                           ,{|| fValida("cZI1CODZHL") },0,16777215,,.F.,,.T.,,.F.,{|| !Empty(cZI1MAT) .and. !Empty(cZI1CREDEN) },.F.,.F.,,.F.,.F. ,,"cZI1CODZHL",;
                           ,,,.T.,,,aRet[01][01],1)
    oARMARIO:SetCSS("QLineEdit{font-size: 15px;}")
	if !Empty(aRet[01][09])
        oARMARIO:cF3 := Alltrim(aRet[01][09])
    endif
    oARMARIO:lVisibleControl := .T.

return

static function getCampos(nTypeBrowse)
	local aCpoRet	:= {}
    local aCampos   := {}
	local nCampos   := 0
    local nX        := 0

    
    IF nTypeBrowse == CONSULTA_UNIF_ENTREGA
        aCampos		:= strToKarr(CAMPOS_UNIF_ENTREGA, ",")
        nCampos := Len(aCampos)
        aUnEnCab    := {}
    ElseIF nTypeBrowse == CONSULTA_UNIF_DEVOLUCAO
        aCampos		:= strToKarr(CAMPOS_UNIF_DEVOLUCAO, ",")
        nCampos     := Len(aCampos)
        aUnDeCab    := {}
    ElseIF nTypeBrowse == CONSULTA_ARMA_DEVOLUCAO
        aCampos		:= strToKarr(CAMPOS_ARMA_DEVOLUCAO, ",")
        nCampos     := Len(aCampos)
        aArDeCab    := {}
    ENDIF

    for nX := 1 to nCampos
		cCampo	:= Alltrim(aCampos[nX])
        
        IF nTypeBrowse == CONSULTA_UNIF_ENTREGA
            cValue := "{|| aUnEnDad[oBUnEnt:At(), " + cValToChar(nX) + "]}"
        ElseIF nTypeBrowse == CONSULTA_UNIF_DEVOLUCAO
            cValue := "{|| aUnDeDad[oBUnDev:At(), " + cValToChar(nX) + "]}"
        ElseIF nTypeBrowse == CONSULTA_ARMA_DEVOLUCAO
            cValue := "{|| aArDeDad[oBArDev:At(), " + cValToChar(nX) + "]}"
        ENDIF

		oColumn := FWBrwColumn():New()
		oColumn:SetData(&(cValue))
        
        if Alltrim(cCampo) == "REGISTRO"
            cTitulo := "Registro"
        
            oColumn:SetTitle(cTitulo)
            oColumn:SetSize(08)
            oColumn:SetType("N")
        Elseif Alltrim(cCampo) == "TMP_SALDO"
            cTitulo := "Saldo"
        
            oColumn:SetTitle(cTitulo)
            oColumn:SetSize(08)
            oColumn:SetType("N")
        else

            cTitulo := getSx3Cache(cCampo, "X3_TITULO")
            
            oColumn:SetTitle(getSx3Cache(cCampo, "X3_TITULO"))
            
            if Alltrim(cCampo) == "B1_DESC"
                oColumn:SetSize(25)
            ELSE
                oColumn:SetSize(getSx3Cache(cCampo, "X3_TAMANHO"))
            ENDIF

            oColumn:SetType(getSx3Cache(cCampo, "X3_TIPO"))
        endif
        
        IF nTypeBrowse == CONSULTA_UNIF_ENTREGA
            AADD(aUnEnCam, cCampo)
        ElseIF nTypeBrowse == CONSULTA_UNIF_DEVOLUCAO
            AADD(aUnDeCam, cCampo)
        ElseIF nTypeBrowse == CONSULTA_ARMA_DEVOLUCAO
            AADD(aArDeCam, cCampo)
        ENDIF
        
        aAdd(aCpoRet, oColumn)

	next nX
    
    IF nTypeBrowse == CONSULTA_UNIF_ENTREGA
        aAdd(aUnEnCam, "MARCA")
        nUnEnCam    := Len(aUnEnCam)
    ElseIF nTypeBrowse == CONSULTA_UNIF_DEVOLUCAO
        aAdd(aUnDeCam, "MARCA")
        nUnDeCam    := Len(aUnDeCam)
    ElseIF nTypeBrowse == CONSULTA_ARMA_DEVOLUCAO
        aAdd(aArDeCam, "MARCA")
        nArDeCam    := Len(aArDeCam)
    ENDIF
    
return(aCpoRet)

Static Function fGetDados(lAlerta, lPesquisa, lCabec)
    Local lRet          := .T.
    Local lPesq         := .T.
    Local cQuery        := ""
    Local cCredenc      := ""
    Local cMatric       := ""
    Local cNome         := ""
    Local cWhere        := ""
    Local nPesq         := 0
    Local nA            := 0
    Default lAlerta     := .T.
    Default lPesquisa   := .T.
    Default lCabec      := .T.

    if lCabec
        //Pegando o texto atual
        cPesq   := Upper(Alltrim(cValtochar(cPesq)))
        nPesq   := Len(cPesq)

        IF nPesq == 0
            lPesq := .F.
        ELSEIF left(cPesq,1)$"0123456789" .and. len(cPesq) = 8
            cMatric := sUBSTRING(cPesq,3,6)
        ElseIF left(cPesq,1)$"0123456789" .and. len(cPesq) = 14
            cCredenc := cPesq

            //Enquanto existir zeros a esquerda
            For nA := nPesq to 1
                If SubStr(cCredenc, 1, 1) <> "0"
                    nA := 0
                else
                    cCredenc := Substr(cCredenc, 2, Len(cCredenc))
                EndIf
            next nA--

            if Empty(cCredenc) .or. cCredenc == "0"
                lPesq := .F.
            endif

        
        elseIF !left(cPesq,1)$"0123456789" .and. len(cPesq) > 5
            cNome := cPesq
        else
            lPesq := .F.
        endif

        cQuery := " SELECT ZI1_FILIAL, ZI1_MAT, ZI1_CREDEN, ZI1_NOME, ZI1_TCAMPA, ZI1_TBLUTE, ZI1_TCALPA, ZI1_TCALTE, ZI1_TCALCA, ZI1_TMEIAS, ZI1_CODZHL, LTRIM(RTRIM(ZI1.ZI1_SECAO))+'-'+ZI5.ZI5_DESCRI ZI1_SECAO, ZI1.R_E_C_N_O_ REGISTRO "
        cQuery += " FROM "+ RetSqlName("ZI1") +" (nolock) ZI1 INNER JOIN "+ retsqlname("ZI5") +" (nolock) ZI5 ON ZI1.D_E_L_E_T_='' AND ZI5.D_E_L_E_T_='' AND ZI1.ZI1_FILIAL='"+ xFilial("ZI1") +"' AND ZI5_FILIAL='"+ xfilial("ZI5") +"' AND ZI1.ZI1_SECAO=ZI5.ZI5_CODIGO "
        cQuery += " WHERE ZI1.D_E_L_E_T_='' AND ZI1_MSBLQL !='1' AND ( (ZI1_MAT ='' AND ZI1_CREDEN !='') OR (ZI1_MAT !='' AND ZI1_CREDEN ='') OR (ZI1_MAT !='' AND ZI1_CREDEN !='')) "
        
        IF !lPesq
            cWhere := "  AND ltrim(rTrim(ZI1_MAT))='ZZZZZZZZZ' "
        else
            if !Empty(cMatric)
                cWhere += " AND ltrim(rTrim(ZI1_MAT))='"+ cColig + Alltrim(cMatric) +"' "
            elseif !Empty(cCredenc)
                cWhere += " AND ltrim(rTrim(ZI1_CREDEN))='"+ Alltrim(cCredenc) +"' "
            Elseif !Empty(cNome)
                cWhere += " AND UPPER(ZI1_NOME) LIKE '%"+ Alltrim(cNome) +"%' "
            else
                cWhere := "  AND ltrim(rTrim(ZI1_MAT))='ZZZZZZZZZ' "
            endif

        endif

        cQuery += cWhere

        TcQuery cQuery ALIAS "QZI1" NEW

        if QZI1->(!eof())

            DbSelectArea("ZI1")
            ZI1->(Dbgoto(QZI1->REGISTRO))

            cZI1MAT      := QZI1->ZI1_MAT
            cZI1CREDEN   := QZI1->ZI1_CREDEN
            cZI1NOME     := QZI1->ZI1_NOME
            cZI1TCAMPA   := QZI1->ZI1_TCAMPA
            cZI1TBLUTE   := QZI1->ZI1_TBLUTE
            cZI1TCALPA   := QZI1->ZI1_TCALPA
            cZI1TCALTE   := QZI1->ZI1_TCALTE
            cZI1TCALCA   := QZI1->ZI1_TCALCA
            cZI1TMEIAS   := QZI1->ZI1_TMEIAS
            cZI1CODZHL   := QZI1->ZI1_CODZHL
            cZI1SECAO    := QZI1->ZI1_SECAO

            lRet := .T.
        else
            cZI1MAT         := Space(100)
            cZI1CREDEN      := Space(100)
            cZI1NOME        := Space(100)
            cZI1TCAMPA      := Space(003)
            cZI1TBLUTE      := Space(003)
            cZI1TCALPA      := Space(003)
            cZI1TCALTE      := Space(003)
            cZI1TCALCA      := Space(003)
            cZI1TMEIAS      := Space(003)
            cZI1CODZHL      := Space(006)
            cZI1SECAO       := Space(100)
            lRet := .F.
        endif
        
        QZI1->(DbcloseArea())
    ENDIF

    aUnEnDad    := getDadoBRW(CONSULTA_UNIF_ENTREGA)
    
    oBUnEnt:setArray(aUnEnDad)
    oBUnEnt:refresh()

    aUnDeDad    := getDadoBRW(CONSULTA_UNIF_DEVOLUCAO)
    
    oBUnDev:setArray(aUnDeDad)
    oBUnDev:refresh()
    
    if lAlerta
        if !lRet .and. nPesq != 0
            //MsgAlert("Credencial inválido ou colaborador não encontrado ou inativo!", "..:: Não encontrado ::..")
            fAlerta("Credencial inválido ou colaborador não encontrado ou inativo!")
        else
            if Len(aUnEnDad) == 0
            //    MsgAlert('<h1><font color="#FF0000">Não há itens a serem entregues. Procure o Depto. de Segurança do Trabalho!</font></h1>', "..:: Não encontrado ::..")
                fAlerta("Não há itens a serem entregues. Procure o Depto. de Segurança do Trabalho!")
            else
                fAlerta("")
            endif
        endif
    endif
    
    if lPesquisa
        cPesq := Space(100)
    endif

Return lRet

//Array de dados
Static function getDadoBRW(nTypeBrowse)
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

    DbSelectArea("ZHO")

    IF nTypeBrowse == CONSULTA_UNIF_ENTREGA
        aCampos := strToKarr(CAMPOS_UNIF_ENTREGA, ",")
        cCampos := CAMPOS_UNIF_ENTREGA
        
        cQuery := " SELECT ZHH.ZHH_CODIGO, ZHH.ZHH_DESCRI, ZHK.ZHK_NUMKIT, ZI5.ZI5_QTDUNF, ZHI.ZHI_UM, ZHI.ZHI_PRODUT, ZHK.ZHK_NUMKIT, (ZI5.ZI5_QTDUNF-ISNULL(ZHO.TMP_SALDO,0)) TMP_SALDO "+cQebra
        cQuery += " FROM "+ retsqlname("ZI1") +" ZI1 INNER JOIN "+ retsqlname("ZI5") +" ZI5 ON ZI1.D_E_L_E_T_='' AND ZI5.D_E_L_E_T_='' AND ZI1.ZI1_FILIAL='"+xFilial("ZI1")+"' AND ZI5.ZI5_FILIAL='"+xFilial("ZI5")+"' AND ZI1.ZI1_SECAO=ZI5.ZI5_CODIGO "+cQebra
        cQuery += "                 INNER JOIN "+ retsqlname("ZHK") +" ZHK ON ZHK.D_E_L_E_T_='' AND ZI5.ZI5_FILIAL='"+xFilial("ZI5")+"' AND ZHK_FILIAL='"+xFilial("ZHK")+"' AND ZI5.ZI5_CODIGO=ZHK.ZHK_CODZI5 "+cQebra
        cQuery += "                 INNER JOIN "+ retsqlname("ZHH") +" ZHH ON ZHH.D_E_L_E_T_='' AND ZHK.ZHK_FILIAL='"+xFilial("ZHK")+"' AND ZHH.ZHH_FILIAL='"+xFilial("ZHH")+"' AND ZHK.ZHK_CODZHH=ZHH.ZHH_CODIGO "+cQebra
        cQuery += "                 INNER JOIN "+ retsqlname("ZHI") +" ZHI ON ZHI.D_E_L_E_T_='' AND ZHI.ZHI_FILIAL='"+xFilial("ZHI")+"' AND ZHH.ZHH_FILIAL='"+xFilial("ZHH")+"' AND ZHI.ZHI_CODIGO=ZHH.ZHH_CODIGO "+cQebra
        cQuery += "                         AND (   (ZHH.ZHH_TIPO='01' AND ZI1.ZI1_TCAMPA=ZHI.ZHI_UM) "+cQebra
        cQuery += "                             OR (ZHH.ZHH_TIPO='02' AND ZI1.ZI1_TBLUTE=ZHI.ZHI_UM) "+cQebra
        cQuery += "                             OR (ZHH.ZHH_TIPO='03' AND ZI1.ZI1_TCALPA=ZHI.ZHI_UM) "+cQebra
        cQuery += "                             OR (ZHH.ZHH_TIPO='04' AND ZI1.ZI1_TCALTE=ZHI.ZHI_UM) "+cQebra
        cQuery += "                             OR (ZHH.ZHH_TIPO='05' AND ZI1.ZI1_TCALCA=ZHI.ZHI_UM) "+cQebra
        cQuery += "                             OR (ZHH.ZHH_TIPO='06' AND ZI1.ZI1_TMEIAS=ZHI.ZHI_UM) "+cQebra
        cQuery += "                             ) "+cQebra
        cQuery += "                 LEFT  JOIN ( SELECT ZHO.ZHO_FILIAL, ZHO.ZHO_MAT, ZHO.ZHO_CODZHH, COUNT(*) TMP_SALDO "+cQebra
        cQuery += "                              FROM "+ retsqlname("ZHO") +" ZHO "+cQebra
        cQuery += "                              WHERE ZHO.D_E_L_E_T_='' AND ZHO.ZHO_DEVDAT='' "+cQebra
        cQuery += "                              GROUP BY ZHO.ZHO_FILIAL, ZHO.ZHO_MAT, ZHO.ZHO_CODZHH) ZHO ON ZHO.ZHO_FILIAL=ZI1.ZI1_FILIAL AND ZHO.ZHO_MAT=ZI1.ZI1_MAT AND ZHK.ZHK_CODZHH=ZHO.ZHO_CODZHH    "+cQebra
        cQuery += " WHERE ZI5.D_E_L_E_T_='' AND (ZI1.ZI1_CREDEN = '"+ Alltrim(cZI1CREDEN) +"' AND ZI1.ZI1_MAT = '"+ Alltrim(cZI1MAT) +"') "+cQebra
        cQuery += "    ORDER BY ZHK.ZHK_NUMKIT, ZHH.ZHH_CODIGO; "
    
    ElseIF nTypeBrowse == CONSULTA_UNIF_DEVOLUCAO
        //"ZHO_CODZHH,ZHO_UNDESC,ZHO_TAMANH,ZHO_PRODUT,ZHO_ENTDAT,ZHO_ENTHOR,ZHO_ENTUSU,ZHO_CODZI5,ZHO_DEDESC"
        aCampos := strToKarr(CAMPOS_UNIF_DEVOLUCAO, ",")
        cCampos := CAMPOS_UNIF_DEVOLUCAO
        
        cQuery := " SELECT ZHO.*, ZI5.ZI5_DESCRI ZHO_DEDESC, ZHH.ZHH_DESCRI ZHO_UNDESC, ZHO.R_E_C_N_O_ REGISTRO"+cQebra
        cQuery += " FROM "+ retsqlname("ZHO") +" ZHO  "+cQebra
        cQuery += "   INNER JOIN "+ retsqlname("ZHH") +" ZHH ON ZHO.D_E_L_E_T_='' AND ZHH.D_E_L_E_T_='' AND ZHO.ZHO_FILIAL='"+xFilial("ZHO")+"' AND ZHH.ZHH_FILIAL='"+xFilial("ZHH")+"' AND ZHO.ZHO_CODZHH=ZHH.ZHH_CODIGO "+cQebra
        cQuery += "   INNER JOIN "+ retsqlname("ZI5") +" ZI5 ON ZI5.D_E_L_E_T_='' AND ZHO.ZHO_FILIAL='"+xFilial("ZHO")+"' AND ZI5.ZI5_FILIAL='"+xFilial("ZI5")+"' AND ZHO.ZHO_CODZI5=ZI5.ZI5_CODIGO "+cQebra 
        cQuery += " WHERE ZI5.D_E_L_E_T_='' AND ZHO.ZHO_MAT = '"+ Alltrim(cZI1MAT) +"' AND ZHO.ZHO_DEVDAT ='' "+cQebra
        cQuery += " ORDER BY ZHO.ZHO_UUID; "
    ElseIF nTypeBrowse == CONSULTA_ARMA_DEVOLUCAO
        
        aCampos := strToKarr(CAMPOS_ARMA_DEVOLUCAO, ",")
        cCampos := CAMPOS_ARMA_DEVOLUCAO
        
        cQuery := " SELECT ZHL.*, ZHL.R_E_C_N_O_ REGISTRO"+cQebra
        cQuery += " FROM "+ retsqlname("ZI1") +" ZI1  "+cQebra
        cQuery += "   INNER JOIN "+ retsqlname("ZHL") +" ZHL ON ZI1.D_E_L_E_T_='' AND ZHL.D_E_L_E_T_='' AND ZI1.ZI1_FILIAL='"+xFilial("ZI1")+"' AND ZHL.ZHL_FILIAL='"+xFilial("ZHL")+"' AND ZI1.ZI1_CODZHL=ZHL.ZHL_CODIGO "+cQebra
        cQuery += " WHERE ZI1.D_E_L_E_T_='' AND ZI1.ZI1_FILIAL = '"+ xFilial("ZI1") +"' AND ZI1.ZI1_DEMISS !='' "+cQebra
        cQuery += " ORDER BY ZHL.ZHL_CODIGO; "
    
    endif

	tcQuery cQuery new alias &cAlias

	(cAlias)->(DbGoTop())

	if (cAlias)-> (!eof())

		While (cAlias)->(!eof())
			aDado := {}
            
  
            for nX := 1 to Len(aCampos)
                
                cTipoCp	:= allTrim(getSx3Cache(aCampos[nX], "X3_TIPO"))
                cPictur	:= allTrim(getSx3Cache(aCampos[nX], "X3_PICTURE"))
                
                if cTipoCp == "N"
                    aAdd(aDado,  Transform((cAlias)-> &(aCampos[nX]), cPictur))
                elseif cTipoCp == "D"
                    aAdd(aDado, sToD((cAlias)-> &(aCampos[nX])))
                else
                    aAdd(aDado, (cAlias)-> &(aCampos[nX]))
                endif
                
            next nX
            
            IF nTypeBrowse == CONSULTA_UNIF_ENTREGA
                aAdd(aDado,.F.)
            ElseIF nTypeBrowse == CONSULTA_UNIF_DEVOLUCAO
                aAdd(aDado,.F.)
            ElseIF nTypeBrowse == CONSULTA_ARMA_DEVOLUCAO
                aAdd(aDado,.F.)
            Endif

            aAdd(aDado, .F.)
			aAdd(aDados, aDado)
			(cAlias)->(DbSkip())
		EndDo

	endIf

    (cAlias)->(DbCloseArea())

return(aDados)

// {|| aItKiDad[oBItKit:At(), " + cValToChar(nX) + "]}
Static Function fMark(oBMark, nMarkID)
    Local cRet := "LBNO"

    IF nMarkID == CONSULTA_UNIF_ENTREGA
        cRet := IIf(aUnEnDad[oBUnEnt:At(), nUnEnCam],'LBOK','LBNO')
    ElseIF nMarkID == CONSULTA_UNIF_DEVOLUCAO
        cRet := IIf(aUnDeDad[oBUnDev:At(), nUnDeCam],'LBOK','LBNO')
    ElseIF nMarkID == CONSULTA_ARMA_DEVOLUCAO
        cRet := IIf(aArDeDad[oBArDev:At(), nArDeCam],'LBOK','LBNO')
    ENDIF

return cRet

Static Function fDblClk(oBMark, nMarkID, nLin)
    Local lRet      := .T.
    Local cNumKit   := ""
    Local nA        := 0
    Local nMaxArr   := 0
    Local nPosKit   := aScan(aUnEnCam,"ZHK_NUMKIT")
    Default nLin    := 0
    
    IF nMarkID == CONSULTA_UNIF_ENTREGA
        nMaxArr := Len(aUnEnDad)
        nLin    := iif(nLin > 0, nLin, oBUnEnt:At())
        
        lRet := IIf(aUnEnDad[nLin, nUnEnCam], .F., .T.)
        aUnEnDad[nLin, nUnEnCam]    := lRet

        
        cNumKit := Alltrim(aUnEnDad[nLin, nPosKit])

        for nA := 1 to nMaxArr
            
            if nA != nLin
                if lRet
                    if aLLTRIM(aUnEnDad[nA, nPosKit]) == cNumKit
                        aUnEnDad[nA, nUnEnCam]    := lRet
                    else
                        aUnEnDad[nA, nUnEnCam]    := !lRet
                    endif
                else
                    aUnEnDad[nA, nUnEnCam]    := lRet    
                endif
            endif
        next nA
    
    ElseIF nMarkID == CONSULTA_UNIF_DEVOLUCAO
        nLin := iif(nLin > 0, nLin, oBUnDev:At())

        lRet := IIf(aUnDeDad[nLin, nUnDeCam], .F., .T.)
        aUnDeDad[nLin, nUnDeCam]    := lRet
    
    ElseIF nMarkID == CONSULTA_ARMA_DEVOLUCAO
        nLin := iif(nLin > 0, nLin, oBArDev:At())

        lRet := IIf(aArDeDad[nLin, nArDeCam], .F., .T.)
        aArDeDad[nLin, nArDeCam]    := lRet
    ENDIF

    oBUnEnt:refresh()
return lRet

Static Function fHeaClk(oBMark, nMarkID)
    Local lRet      := .T.
    Local nA        := 1
    Local nTotal    := 0
    
    IF nMarkID == CONSULTA_UNIF_ENTREGA
        
        nTotal := Len(aUnEnDad)

        For nA := 1 TO nTotal
            fDblClk(oBMark, CONSULTA_UNIF_ENTREGA, nA)
        next nA

        oBUnEnt:refresh()
        
    ElseIF nMarkID == CONSULTA_UNIF_DEVOLUCAO
        nTotal := Len(aUnDeDad)

        For nA := 1 TO nTotal
            fDblClk(oBMark, CONSULTA_UNIF_DEVOLUCAO, nA)
        next nA

        oBUnDev:refresh()
    
    ElseIF nMarkID == CONSULTA_ARMA_DEVOLUCAO
        nTotal := Len(aArDeDad)

        For nA := 1 TO nTotal
            fDblClk(oBMark, CONSULTA_ARMA_DEVOLUCAO, nA)
        next nA

        oBArDev:refresh()
    ENDIF
    
return lRet

/* Busca as informações do cabeçalho. */
Static Function fgetSX3(cCampos)
    Local aRet      := {}
    Local cCampo    := ""
    Local nX        := 0
    Local nCampos   := 0
    Local bValid
    Local aCampos   := Separa(cCampos,",")
    
    dbselectarea("SX3")
    sx3->(dbsetorder(2)) // Campo
    nCampos := len(aCampos)
    
    for nx := 1 to nCampos

        cCampo := Alltrim(aCampos[nX])
        cUsado := GetSX3Cache(cCampo, "X3_USADO")
        
        if !Empty(GetSX3Cache(cCampo, "X3_CAMPO"))

            bValid := Alltrim(GetSX3Cache(cCampo, "X3_VALID"))

            if Empty(bValid)
                bValid := {|| .T. }
            ELSE
                bValid := &("{|| "+Alltrim(GetSX3Cache(cCampo, "X3_VALID")) +" }")
            endif

            aadd(aRet,{ alltrim(GetSX3Cache(cCampo, "X3_TITULO")),;
            GetSX3Cache(cCampo, "X3_CAMPO")	,;
            GetSX3Cache(cCampo, "X3_PICTURE"),;
            GetSX3Cache(cCampo, "X3_TAMANHO"),;
            GetSX3Cache(cCampo, "X3_DECIMAL"),;
            bValid,;
            GetSX3Cache(cCampo, "X3_USADO"),;
            GetSX3Cache(cCampo, "X3_TIPO"),;
            GetSX3Cache(cCampo, "X3_F3"),;
            GetSX3Cache(cCampo, "X3_CONTEXT"),;
            GetSX3Cache(cCampo, "X3_CBOX"),;
            GetSX3Cache(cCampo, "X3_RELACAO")})
        endif
    next nx

return aRet
