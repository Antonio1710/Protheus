#Include "Protheus.ch"
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
#DEFINE CONS_BROWSER        1
#DEFINE CONS_CAUSA_DEST     2
#DEFINE CONS_CAUSA_RATE     3

// Defines dos campos.
#DEFINE CAMPOS_BROWSER_ARQ   "ZV1_DTABAT,ZV1_RHABAT,ZV1_TURNO,ZV1_RGRANJ,A2_NOME,ZV1_RPLACA,ZV1_NUMGTA,ZV1_CAVES,ZV1_STATCO,ZV1_NUMOC,ZV1_RATEIO,ZV1_QTDRT1,ZV1_QTDRT2"
#DEFINE CAMPOS_BROWSER       "ZV1_DTABAT,ZV1_RHABAT,ZV1_TURNO,ZV1_RGRANJ,A2_NOME,ZV1_RPLACA,ZV1_NUMGTA,ZV1_CAVES,ZV1_RATEIO,ZV1_QTDRT1,ZV1_QTDRT2"
#DEFINE CAMPOS_CAUSA_DESTINO "ZEF_CODITE,ZEF_DESCRI,ZEF_TURNO,ZEF_CONTOT,ZEF_CODPAR,ZEF_APRCON"

/*/{Protheus.doc} User Function ADEST064P U_ADEST064P()
    Rotina de cadastro de condenações por lote.
    Chamado 8703
    @type  Function
    @author Leonardo P. Monteiro
    @since 12/05/2021
    @version 01
    @history Chamado 14613 - Leonardo P. Monteiro - 27/05/2021 - Implementações de melhorias no processo de apontamento de condenações como rateio por turno.
    @history Chamado 14613 - Leonardo P. Monteiro - 04/06/2021 - Correção da consulta para inibir registros de granjas em duplicidade.
    @history Chamado 14613 - Leonardo P. Monteiro - 08/06/2021 - Correção de error.log na linha 514.
    @history Chamado 14613 - Leonardo P. Monteiro - 23/06/2021 - Busca o cadastro da granja em casos em que não o fornecedor não estiver cadastrado corretamente.
    @history Chamado 00000 - Leonardo P. Monteiro - 12/09/2021 - Ajuste na query do browser para eliminar a duplicidade de fornecedores.
/*/

User Function ADEST064P()
	Local oBrowser 
	private cAliEmb     := "WorkZV1"
	Private aRotina 	:= MenuDef()
    Private aBrowser    := {}
    Private aParamBox   := {}
    Private aRet        := {}
    Private oTempTable

    Aadd( aParamBox ,{1,"Dt Abate De"  						,dDatabase-15,"" ,'.T.',"",'.T.',80,.F.})
	Aadd( aParamBox ,{1,"Dt Abate Até" 						,dDatabase+15,"" ,'.T.',"",'.T.',80,.F.})
	Aadd( aParamBox ,{1,"Granja De"  						,Space(6) ,"" ,'.T.',"ZF3",'.T.',80,.F.})
	Aadd( aParamBox ,{1,"Granja Até"  						,Space(6) ,"" ,'.T.',"ZF3",'.T.',80,.F.})
	aAdd( aParamBox	,{3,"Status Preenchimento"		        ,1,{'Todos','Com Laudo','Sem Laudo'},100,"",.F.})
	//aAdd( aParamBox	,{ 3,"Considera prod c/ req. mercado"	,1,{'Todos','Sim','Não'},100,"",.F.})

    if ParamBox(aParamBox,"Parâmetros",@aRet)

        if type("cFilAnt") == "U"
            RpcsetType(3)
            //Rpcsetenv("01","02","LEONARDO_MONTEIRO","Lodale0!")
            nAlt    := GetScreenRes()[02]*0.965
            nLarg   := GetScreenRes()[01]
        else
            aSize   := MsAdvSize(.T.)
            nAlt    := aSize[06]
            nLarg   := aSize[05]
        endif
        
        DbSelectArea("ZEF")

        CriaTRB()
        aBrowser     := getCampos(CONS_BROWSER)
        fGetDados(CONS_BROWSER)

        DbSelectArea(cAliEmb)
        (cAliEmb)->(DbGoTop())

        // Declara o objeto Browse.
        oBrowser := FWMBrowse():New()
        // Declara o Alias.
        oBrowser:AddLegend("(cAliEmb)->ZV1_STATCO != 'S' ", "RED"		, "Aguardando preenchimento do formulário.")
        oBrowser:AddLegend("(cAliEmb)->ZV1_STATCO == 'S' ", "GREEN"		, "Formulário preenchido.")
        
        oBrowser:SetAlias(cAliEmb)
        oBrowser:setColumns(aBrowser)
        
        // Declara o tÃ­tulo da tela.
        oBrowser:SetDescription("..:: Condenações por Lote ::..")
        //oBrowser:DisableDetails()

        // Ativa o objeto Browse.
        oBrowser:Activate()
        
        oBrowser:Destroy()
        oTempTable:Delete()
    else
        msginfo("Ação cancelada pelo operador!")
    endif

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina de cadastro de condenações por lote.')


Return nil

Static Function fGetDados()
    Local cQuery    := ""

    if Select("QZV1") > 0
        QZV1->(dbCloseArea())
    endif

    cQuery  := " SELECT ZV1_DTABAT,ZV1_RHABAT,ZV1_TURNO,ZV1_RGRANJ,ISNULL(A2_NOME, ZF3_GRADES)  A2_NOME, ZV1_RPLACA,ZV1_NUMGTA,ZV1_CAVES,ZV1_STATCO,ZV1_NUMOC,ZV1_RATEIO,ZV1_QTDRT1,ZV1_QTDRT2 "
    //@history Chamado TI    - Leonardo P. Monteiro - 12/09/2021 - Ajuste na query do browser para eliminar a duplicidade de fornecedores.
    //cQuery  += " FROM "+ RetSqlName("ZV1") +" ZV1 LEFT JOIN "+ RetSqlName("SA2") +" SA2 ON ZV1.D_E_L_E_T_='' AND SA2.D_E_L_E_T_='' AND ZV1.ZV1_FILIAL='"+ xFilial("ZV1") +"' AND SA2.D_E_L_E_T_='' AND ZV1.ZV1_RGRANJ=SA2.A2_INTCOD "
    cQuery  += " FROM "+ RetSqlName("ZV1") +" ZV1 LEFT JOIN "+ RetSqlName("SA2") +" SA2 ON ZV1.D_E_L_E_T_='' AND SA2.D_E_L_E_T_='' AND ZV1.ZV1_FILIAL='"+ xFilial("ZV1") +"' AND SA2.D_E_L_E_T_='' AND ZV1.ZV1_CODFOR =SA2.A2_COD AND ZV1.ZV1_LOJFOR=SA2.A2_LOJA "
    cQuery  += "                                  LEFT JOIN "+ RetSqlName("ZF3") +" ZF3 ON ZV1.D_E_L_E_T_='' AND ZF3.D_E_L_E_T_='' AND ZV1.ZV1_FILIAL='  ' AND ZF3.D_E_L_E_T_='' AND ZV1.ZV1_RGRANJ=ZF3.ZF3_GRACOD   "
    cQuery  += " WHERE ZV1.D_E_L_E_T_='' "
    cQuery  += "    AND ZV1.ZV1_DTABAT BETWEEN '"+ Dtos(MV_PAR01) +"' AND '"+ Dtos(MV_PAR02) +"' "
    cQuery  += "    AND ZV1.ZV1_RGRANJ BETWEEN '"+ MV_PAR03 +"' AND '"+ IIF(EMPTY(MV_PAR04),"ZZZZZZ",MV_PAR04) +"' "
    
    if MV_PAR05 == 2
        cQuery  += "    AND ZV1.ZV1_STATCO = '' "
    elseif MV_PAR05 == 3
        cQuery  += "    AND ZV1.ZV1_STATCO != 'S' "
    endif

    cQuery  += " ORDER BY ZV1.ZV1_DTABAT, ZV1.ZV1_RHABAT, ZV1.ZV1_NUMGTA, ZV1.ZV1_RPLACA; "

    TcQuery cQuery ALIAS "QZV1" NEW

    //TCSetField("QZV1","ZV1_TURNO"	,"N",1,0	)

    while QZV1->(!Eof())
        Reclock(cAliEmb,.T.)
        //ZV1_DTABAT,ZV1_RHABAT,ZV1_NUMGTA,ZV1_RPLACA,ZV1_RGRANJ,A2_NOME,ZV1_TURNO,ZV1_CAVES,ZV1_STATCO,ZV1_NUMOC
        (cAliEmb)->ZV1_NUMOC    := Alltrim(QZV1->ZV1_NUMOC)
        (cAliEmb)->ZV1_NUMGTA   := Alltrim(QZV1->ZV1_NUMGTA)
        (cAliEmb)->ZV1_DTABAT   := Stod(QZV1->ZV1_DTABAT)
        (cAliEmb)->ZV1_RHABAT   := Alltrim(QZV1->ZV1_RHABAT)
        (cAliEmb)->ZV1_RPLACA   := Alltrim(QZV1->ZV1_RPLACA)
        (cAliEmb)->ZV1_RGRANJ   := Alltrim(QZV1->ZV1_RGRANJ)
        (cAliEmb)->A2_NOME      := Alltrim(QZV1->A2_NOME)

        IF QZV1->ZV1_TURNO == 1
            (cAliEmb)->ZV1_TURNO    := "1-1º Turno"
        elseIF QZV1->ZV1_TURNO == 2
            (cAliEmb)->ZV1_TURNO    := "2-2º Turno"
        else
            (cAliEmb)->ZV1_TURNO    := Alltrim(QZV1->ZV1_TURNO)+"-N/A"
        ENDIF

        (cAliEmb)->ZV1_CAVES    := QZV1->ZV1_CAVES
        (cAliEmb)->ZV1_QTDRT1   := QZV1->ZV1_QTDRT1
        (cAliEmb)->ZV1_QTDRT2   := QZV1->ZV1_QTDRT2
        //(cAliEmb)->ZV1_CAVES    := QZV1->ZV1_CAVES
        (cAliEmb)->ZV1_STATCO   := QZV1->ZV1_STATCO
        (cAliEmb)->ZV1_RATEIO   := QZV1->ZV1_RATEIO
        
        (cAliEmb)->(Msunlock())
        QZV1->(Dbskip())
    enddo    

    QZV1->(DbCloseArea())
Return

Static Function CriaTRB()
    Local aCampos	:= strToKarr(CAMPOS_BROWSER_ARQ, ",")
	Local aCamTmp   := {}
    Local cCampo    := ""
    Local nA        := 1
    Local nCampos   := Len(aCampos)

	oTempTable := FWTemporaryTable():New(cAliEmb)
	
    for nA := 1 to nCampos
        cCampo  := aCampos[nA]
        if cCampo == "ZV1_TURNO"
            aAdd( aCamTmp, {cCampo ,"C"   ,14, 0} )
        else
            aAdd( aCamTmp, {cCampo ,TamSX3(cCampo)[3]   ,TamSX3(cCampo)[1], 0} )
        endif
    next nA

	oTempTable:SetFields(aCamTmp)
	//ZV1_DTABAT,ZV1_RHABAT,ZV1_NUMGTA,ZV1_RPLACA,ZV1_RGRANJ,A2_NOME,ZV1_TURNO,ZV1_CAVES,ZV1_STATCO,ZV1_NUMOC
    //oTempTable:AddIndex("01", {"E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA"} )
	oTempTable:AddIndex("01", {"ZV1_DTABAT","ZV1_RHABAT","ZV1_NUMGTA","ZV1_RPLACA"} )
	oTempTable:AddIndex("02", {"ZV1_RGRANJ","ZV1_DTABAT","ZV1_TURNO"} )
	oTempTable:AddIndex("03", {"ZV1_DTABAT","ZV1_TURNO","ZV1_RGRANJ"} )
    oTempTable:Create()
    cAliEmb 	:= oTempTable:GetAlias()
    //cTableName 	:= cArqTrab:GetRealName()

Return

Static Function MenuDef()
	Local aRotina 	:= {}
	
	ADD OPTION aRotina Title 'Visualizar' 	    Action 'U_DEST064A(2)' 	OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Incluir/Alterar'	Action 'U_DEST064A(3)' 	OPERATION 3 ACCESS 0
	//ADD OPTION aRotina Title 'Alterar' 		Action 'U_DEST064A(4)' 	OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir' 		    Action 'U_DEST064A(5)' 	OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title 'Form SIF/AMPM 04' Action 'U_ADEST066R()' 	OPERATION 7 ACCESS 0
	//ADD OPTION aRotina Title 'Form SIF/AMPM 04' Action 'U_ADEST067R()' 	OPERATION 7 ACCESS 0

Return( aRotina )

User Function DEST064A(nOper)
    Local cTitle    := ""
    
    Private oWnd
    Private olayer
    Private oFoGd01
    Private oBtnCanc
    Private oBtnConf
    Private oBrTip
    
    Private oNUMGTA
    Private oGRACOD
    Private oRAZAOS
    Private oDTABAT
    Private oRHABAT
    Private oTURNO
    Private oQTDABA
    Private oRPLACA

    Private oWin01
    Private oWin02
    Private oWin03

    //Private oZEFCODITE
    Private oBtnDtAt
    Private oSayDesc
    Private oZEFCONTOT
    Private oZEFCODPAR
    Private oZEFAPRCON
    
    Private oZV1QTDRT1 
    Private oZV1QTDRT2
    
    Private nQTDRT1     := 0
    Private nQTDRT2     := 0
    Private cRATEIO     := "N"

    Private nZEFCONTOT  := 0
    Private nZEFCODPAR  := 0
    Private nZEFAPRCON  := 0

    Private cZEFCODITE  := ""
    Private cZEFDESCRI  := ""
    
    

    //Private oFCabec     := TFont():New( "Times New Roman",,24,,.t.,,,,,.f. )

    Private cNUMGTA
    Private cGRACOD
    Private cRAZAOS
    Private dDTABAT
    Private cRHABAT
    Private nQTDABA
    Private cTURNO
    Private cTurRat
    Private cRPLACA
    
    Private cBlqFld1    := "000003,000006,000014,000016"
    Private cBlqFld2    := "000002,000005,000007,000011,000016,000018"
    Private cBlqFld3    := "000001,000002,000003,000004,000005,000006,000007,000008,000011,000013,000014,000015,000017,000018,000019,000020"

    Private cBtnCss     := ""
    Private cLayCSS     := ""

    Private aBrTipCab   := {}
    Private aBrTipDad   := {}
    Private aBrTipCam   := {}
    Private nOperation  := nOper
    Private bBrTip      := {|| fBrTip() }

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

    if !((cAliEmb)->ZV1_STATCO == "N" .AND. nOperation == 5)
    
        DbselectArea("ZEF")
        DbselectArea("ZV1")
        ZV1->(dbsetorder(3))

        if ZV1->(Dbseek(xFilial("ZV1")+(cAliEmb)->ZV1_NUMOC))
            

            if nOperation == 3
                cTitle  := "Inclusão"
            elseif nOperation == 4
                cTitle  := "Alteração"
            elseif nOperation == 5
                cTitle  := "Exclusão"
            else
                cTitle  := "Visualizar"
            endif

            oWnd            := Msdialog():Create()
            oWnd:cTitle     := "..:: Condenações por Lote ::.."
            ownd:nWidth     := nLarg
            oWnd:nHeight    := nAlt
            oWnd:lMaximized := .T.
            oWnd:SetCSS("QWidget{ font: bold 14px; }")

            oLayer := FWLayer():new()
            
            oLayer:init(oWnd,.T.)
            oLayer:opanel:nHeight    := nAlt*1.01

            layHeader()
            layDetail()
            layFooter()

            oWnd:Activate()
        else
            MsgAlert("Registro não encontrado!")
        endIf
    else
        msginfo("Essa item não possui registros cadastrados!")
    endif
return

/* Layoutdet - Carrega os componentes da sessão de detalhes. */
Static function layDetail()
        
    //olayer:addLine("L02",70, .F.)
    olayer:addLine("L02",65, .F.)
    oLayer:addCollumn("L02C01", 080, .F., "L02")
    oLayer:addCollumn("L02C02", 020, .F., "L02")

    oLayer:addWindow("L02C01", "Win02", "Total por Causa/Destino"	, 100,.F.,.F.,{||"" },"L02",{||""})
    oLayer:addWindow("L02C02", "Win03", "Formulário"		        , 100,.F.,.F.,{||"" },"L02",{||""})

    oLayer:GetLinePanel("L02"):SetCSS("QFrame{ background-color: #FFFFFF;}")

	oLayer:GetWinPanel("L02C01","Win02","L02"):SetCSS("QFrame{font-size: 14px;}")

    //********************************************
    // Total por Causa e Destino
    //********************************************
    
    aBrTipCab		:= getCampos(CONS_CAUSA_DEST)
    aBrTipDad		:= getDadosBrw(CONS_CAUSA_DEST)

    oWin02 := oLayer:GetWinPanel("L02C01","Win02","L02")

    oBrTip := FWBrowse():New(oWin02)
    oBrTip:setColumns(aBrTipCab)
	oBrTip:setDataArray()
	oBrTip:disableReport()
	oBrTip:disableConfig()
    oBrTip:setArray(aBrTipDad)
    oBrTip:setChange(bBrTip)
    oBrTip:setEditCell(.T., {|| .T.})
    oBrTip:bGotFocus := {|| nBrwFocused := 1}
    oBrTip:Activate()

    //********************************************
    // Sessão de Detalhes
    //********************************************

    //oCoCol02     := olayer:GetColPanel("L02C02","L02")
    oWin03  := oLayer:GetWinPanel("L02C02","Win03","L02")
    
    oSize := FWDefSize():New(.F.)
	
    oSize:AddObject( "OBJ01"	, 90 , 25, .T., .T. )
    oSize:AddObject( "OBJ02"	, 90 , 35, .T., .T. )
    oSize:AddObject( "OBJ03"	, 90 , 35, .T., .T. )
    oSize:AddObject( "OBJ04"	, 90 , 35, .T., .T. )
    oSize:AddObject( "OBJ05"	, 50 , 35, .T., .T. )
    
	oSize:lLateral	:= .F. // Elementos um do lado do outro
	oSize:lProp		:= .T. // Cálculo dos botões proporcionais
	oSize:SetWindowSize({000, 000, oWin03:nHeight, oWin03:nWidth})
	oSize:Process() 		// executa os calculos

    //oCoGd01:setCss(cLayCSS)
    //ZEF_CODITE, ZEF_DESCRI, ZEF_CONTOT, ZEF_CODPAR, ZEF_APRCON
    fAtuForm()
    
    oSayDesc := TSay():New(oSize:GetDimension("OBJ01","LININI"), oSize:GetDimension("OBJ01","COLINI"), {|| cZEFCODITE +"-"+cZEFDESCRI}   , oWin03,,,,,,.T.,,, oSize:GetDimension("OBJ01","XSIZE"),25)
    oSayDesc:SetCSS("QLineEdit{font-size: 24px; width: 90%;}")
    //ZEF_CODITE, ZEF_DESCRI, ZEF_CONTOT, ZEF_CODPAR, ZEF_APRCON"
    aRet := fgetSX3("ZEF_CONTOT")
	
    oZEFCONTOT  := TGet():New(oSize:GetDimension("OBJ02","LININI"), oSize:GetDimension("OBJ02","COLINI"),{|u|If(PCount() == 0, nZEFCONTOT, nZEFCONTOT := u)},oWin03, oSize:GetDimension("OBJ02","XSIZE"),020,alltrim(aRet[01][03]),,0,16777215,,.F.,,.T.,,.F.,{|| (INCLUI .OR. ALTERA) .AND. !cZEFCODITE$cBlqFld1 },.F.,.F.,,.F.,.F. ,,"nZEFCONTOT",,,,.T.,,,aRet[01][01],1)
    oZEFCONTOT:SetCSS("QLineEdit{font-size: 24px; width: 90%;}")
    oZEFCONTOT:lVisibleControl := .T.

    aRet := fgetSX3("ZEF_CODPAR")
	oZEFCODPAR  := TGet():New(oSize:GetDimension("OBJ03","LININI"), oSize:GetDimension("OBJ03","COLINI"),{|u|If(PCount() == 0, nZEFCODPAR, nZEFCODPAR := u)},oWin03, oSize:GetDimension("OBJ03","XSIZE"),020,alltrim(aRet[01][03]),,0,16777215,,.F.,,.T.,,.F.,{|| (INCLUI .OR. ALTERA) .AND. !cZEFCODITE$cBlqFld2 },.F.,.F.,,.F.,.F. ,,"nZEFCODPAR",,,,.T.,,,aRet[01][01],1)
    oZEFCODPAR:SetCSS("QLineEdit{font-size: 24px; width: 90%;}")
    oZEFCODPAR:lVisibleControl := .T.
    
    aRet := fgetSX3("ZEF_APRCON")
	oZEFAPRCON  := TGet():New(oSize:GetDimension("OBJ04","LININI"), oSize:GetDimension("OBJ04","COLINI"),{|u|If(PCount() == 0, nZEFAPRCON, nZEFAPRCON := u)},oWin03, oSize:GetDimension("OBJ04","XSIZE"),020,alltrim(aRet[01][03]),,0,16777215,,.F.,,.T.,,.F.,{|| (INCLUI .OR. ALTERA) .AND. !cZEFCODITE$cBlqFld3 },.F.,.F.,,.F.,.F. ,,"nZEFAPRCON",,,,.T.,,,aRet[01][01],1)
    oZEFAPRCON:SetCSS("QLineEdit{font-size: 24px; width: 90%;}")
    oZEFAPRCON:lVisibleControl := .T.

    //oBtnDtAt := TButton():New(oSize:GetDimension("OBJ05","LININI"), oSize:GetDimension("OBJ05","COLINI"), "Atualiza"   , oWin03,{|| fUpdLine() }, oSize:GetDimension("OBJ05","XSIZE"),20,,,.F.,.T.,.F.,,.F.,{|| iif(len(aBrTipDad) > 0, .T., .F. )},,.F. )
    oBtnDtAt := TButton():New(oSize:GetDimension("OBJ05","LININI"), oSize:GetDimension("OBJ05","COLINI"), "Próximo >"   , oWin03,{|| fUpdLine() }, oSize:GetDimension("OBJ05","XSIZE"),20,,,.F.,.T.,.F.,,.F.,{|| iif(len(aBrTipDad) > 0, .T., .F. )},,.F. )
    
    oBtnDtAt:setCss(cBtnCss)

return nil

Static Function fBrTip()
    fAtuForm()
    if type("oZEFCONTOT")  == "O" .and. type("oZEFCODPAR")  == "O" .and. type("oZEFAPRCON")  == "O"
        IF cZEFCODITE$"000001"
            oZEFCONTOT:Disable()
        else
            oZEFCONTOT:Enable()
        endif

        IF cZEFCODITE$"000002"
            oZEFCODPAR:Disable()
        else
            oZEFCODPAR:Enable()
        endif

        IF cZEFCODITE$"000002,000003"
            oZEFAPRCON:Disable()
        else
            oZEFAPRCON:Enable()
        endif

        oSayDesc:refresh()
        oZEFCONTOT:refresh()
        oZEFCODPAR:refresh()
        oZEFAPRCON:refresh()
        oSayDesc:refresh()
        oBrTip:Refresh()
    endif
return .T.

/*
Static Function fUpdLine()
    //cZEFCODITE   := aBrTipDad[oBrTip:At(), aScan(aBrTipCam,"ZEF_CODITE")]
    //cZEFDESCRI   := Alltrim(aBrTipDad[oBrTip:At(), aScan(aBrTipCam,"ZEF_DESCRI")])
    aBrTipDad[oBrTip:At(), aScan(aBrTipCam,"ZEF_CONTOT")] := nZEFCONTOT
    aBrTipDad[oBrTip:At(), aScan(aBrTipCam,"ZEF_CODPAR")] := nZEFCODPAR
    aBrTipDad[oBrTip:At(), aScan(aBrTipCam,"ZEF_APRCON")] := nZEFAPRCON

    oBrTip:refresh()
return
*/
Static Function fUpdLine()
    //cZEFCODITE   := aBrTipDad[oBrTip:At(), aScan(aBrTipCam,"ZEF_CODITE")]
    //cZEFDESCRI   := Alltrim(aBrTipDad[oBrTip:At(), aScan(aBrTipCam,"ZEF_DESCRI")])
    aBrTipDad[oBrTip:At(), aScan(aBrTipCam,"ZEF_CONTOT")] := nZEFCONTOT
    aBrTipDad[oBrTip:At(), aScan(aBrTipCam,"ZEF_CODPAR")] := nZEFCODPAR
    aBrTipDad[oBrTip:At(), aScan(aBrTipCam,"ZEF_APRCON")] := nZEFAPRCON

    oBrTip:goDown()

    fBrTip()
    oBrTip:refresh()

    IF cZEFCODITE$"000001"
        oZEFCONTOT:setFocus()
    elseIF cZEFCODITE$"000002"
        oZEFCONTOT:setFocus()
    elseIF cZEFCODITE$"000003"
        oZEFCODPAR:setFocus()
    else
        oZEFCONTOT:setFocus()
    endif

return

Static Function fAtuForm()

    cZEFCODITE   := aBrTipDad[oBrTip:At(), aScan(aBrTipCam,"ZEF_CODITE")]
    cZEFDESCRI   := Alltrim(aBrTipDad[oBrTip:At(), aScan(aBrTipCam,"ZEF_DESCRI")])
    nZEFCONTOT   := aBrTipDad[oBrTip:At(), aScan(aBrTipCam,"ZEF_CONTOT")]
    nZEFCODPAR   := aBrTipDad[oBrTip:At(), aScan(aBrTipCam,"ZEF_CODPAR")]
    nZEFAPRCON   := aBrTipDad[oBrTip:At(), aScan(aBrTipCam,"ZEF_APRCON")]
return

/* Layoutdet - Carrega os componentes de botões. */
Static function layfooter()
    
    //Tela de talhada com os grids e folders.
    olayer:addLine("L03",10, .F.)
    
    oFoLin1     := oLayer:GetLinePanel("L03")
    
    oSize := FWDefSize():New(.F.)
	
    oSize:AddObject( "OBJ01"	, 70 , 25, .T., .T. )
    oSize:AddObject( "OBJ02"	, 90 , 35, .T., .T. )
    oSize:AddObject( "OBJ03"	, 90 , 35, .T., .T. )
    oSize:AddObject( "OBJ04"	, 90 , 35, .T., .T. )
    oSize:AddObject( "OBJ05"	, 200, 35, .T., .T. )
    oSize:AddObject( "OBJ06"	, 70 , 35, .T., .T. )
    oSize:AddObject( "OBJ07"	, 70 , 35, .T., .T. )
    
    
	oSize:lLateral	:= .T. // Elementos um do lado do outro
	oSize:lProp		:= .T. // Cálculo dos botões proporcionais
	oSize:SetWindowSize({000, 000, oFoLin1:nHeight, oFoLin1:nWidth})
	oSize:Process() 		// executa os calculos

    oBtnRate    := TButton():New( oSize:GetDimension("OBJ01","LININI"), oSize:GetDimension("OBJ01","COLINI"), "+Dividir Turno"   , oFoLin1,{|| fAddTur() }, oSize:GetDimension("OBJ01","XSIZE"),25,,,.F.,.T.,.F.,,.F.,,,.F. )
    //oBtnRate:setCss(cBtnCss)

    aRet := fgetSX3("ZV1_QTDRT1")
	oZV1QTDRT1  := TGet():New(oSize:GetDimension("OBJ02","LININI"), oSize:GetDimension("OBJ02","COLINI"),{|u|If(PCount() == 0, nQTDRT1, nQTDRT1 := u)},oFoLin1, oSize:GetDimension("OBJ02","XSIZE"),016,alltrim(aRet[01][03]),,0,16777215,,.F.,,.T.,,.F.,{|| (INCLUI .OR. ALTERA) .AND. LEFT(cTURNO,1) !='1' .AND. cRATEIO=="S" },.F.,.F.,{|| IIF(nQTDABA-nQTDRT1 < 1, .F., nQTDRT2 := nQTDABA-nQTDRT1)  },.F.,.F. ,,"nQTDRT1",,,,.T.,,,aRet[01][01],1)
    oZV1QTDRT1:SetCSS("QLineEdit{font-size: 24px; width: 90%; margin: 5px; }")
    oZV1QTDRT1:lVisibleControl := .T.
    
    aRet := fgetSX3("ZV1_QTDRT2")
	oZV1QTDRT2  := TGet():New(oSize:GetDimension("OBJ03","LININI"), oSize:GetDimension("OBJ03","COLINI"),{|u|If(PCount() == 0, nQTDRT2, nQTDRT2 := u)},oFoLin1, oSize:GetDimension("OBJ03","XSIZE"),016,alltrim(aRet[01][03]),,0,16777215,,.F.,,.T.,,.F.,{|| (INCLUI .OR. ALTERA) .AND. LEFT(cTURNO,1) !='2' .AND. cRATEIO=="S" },.F.,.F.,{|| IIF(nQTDABA-nQTDRT2 < 1, .F., nQTDRT1 := nQTDABA-nQTDRT2) },.F.,.F. ,,"nQTDRT2",,,,.T.,,,aRet[01][01],1)
    oZV1QTDRT2:SetCSS("QLineEdit{font-size: 24px; width: 90%; margin: 5px; }")
    oZV1QTDRT2:lVisibleControl := .T.

    aRet := fgetSX3("ZV1_CAVES")
    oQTDABA     := TGet():New(oSize:GetDimension("OBJ04","LININI"),oSize:GetDimension("OBJ04","COLINI"),{|u|If(PCount() == 0, nQTDABA, nQTDABA := u)},oFoLin1,oSize:GetDimension("OBJ04","XSIZE"), 016,alltrim(aRet[01][03]),,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nQTDABA",,,,.T.,,,aRet[01][01],1) 
	oQTDABA:SetCSS("QLineEdit{font-size: 24px; width: 90%; margin: 5px; }")
    if !Empty(aRet[01][09])
        oQTDABA:cF3 := Alltrim(aRet[01][09])
    endif
    oQTDABA:lVisibleControl := .T.

    oBtnCanc    := TButton():New( oSize:GetDimension("OBJ06","LININI"), oSize:GetDimension("OBJ06","COLINI"), "Cancelar"   , oFoLin1,{|| oWnd:End() }, oSize:GetDimension("OBJ06","XSIZE"),25,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnConf    := TButton():New( oSize:GetDimension("OBJ07","LININI"), oSize:GetDimension("OBJ07","COLINI"), "Confirmar"  , oFoLin1,{|| iif(fConfirma(), oWnd:End(), .F.) }, oSize:GetDimension("OBJ07","XSIZE"),25,,,.F.,.T.,.F.,,.F.,,,.F. )
    
    oBtnCanc:setCss(cBtnCss)
    oBtnConf:setCss(cBtnCss)
    /*
    oFoGd01:addSpacer(5)
    oFoGd01:addInLayout(oBtnCanc)
    oFoGd01:addInLayout(oBtnConf)
    */
return nil

Static Function fAddtur()
    Local cTurRat   := iif(left(cTURNO,1)=="1","2-2º Turno","1-1º Turno")
    Local aDadRat   := {}

    if cRATEIO == "N"
        if !fExTurn(cTurRat)
            aDadRat     := getDadosBrw(CONS_CAUSA_RATE )
            nDadRat     := Len(aDadRat)
            For nZ := 1 To nDadRat
                AADD(aBrTipDad, aDadRat[nZ])
            next nZ

            cRATEIO := "S"
        else
            cRATEIO := "S"
        endif
    ENDIF

    oBrTip:Refresh()
return nil

Static function fExTurn(cTurRat)
    Local lRet      := .F.
    Local nA        := 0
    Local nPosTur   := aScan(aBrTipCam,"ZEF_TURNO")
    Local nTamGrd   := Len(aBrTipDad)

    for nA := 1 TO nTamGrd
        if Alltrim(aBrTipDad[nA, nPosTur]) == cTurRat
            lRet := .T.
        endif
    next nA

return lRet

Static Function fConfirma()
    Local lRet      := .T.
    Local nA        := 0
    Local cQuery    := ""
    Local nTotal    := Len(aBrTipDad)
    Local lPosic    := .F.
    
    DbSelectArea("ZEF")
    ZEF->(DbSetOrder(1))

    DbSelectArea("ZV1")
    ZV1->(DbSetOrder(3))

    if INCLUI .OR. ALTERA
        
        if ZV1->(Dbseek(xFilial("ZV1")+(cAliEmb)->ZV1_NUMOC))
            if fValid()
                if Reclock("ZV1",.F.)
                    ZV1->ZV1_STATCO := "S"
                    ZV1->ZV1_RATEIO := cRATEIO
                    ZV1->ZV1_QTDRT1 := nQTDRT1
                    ZV1->ZV1_QTDRT2 := nQTDRT2
                    Msunlock("ZV1")
                endif

                if Reclock( cAliEmb, .F.)
                    (cAliEmb)->ZV1_STATCO := "S"
                    (cAliEmb)->ZV1_RATEIO := cRATEIO
                    (cAliEmb)->ZV1_QTDRT1 := nQTDRT1
                    (cAliEmb)->ZV1_QTDRT2 := nQTDRT2
                    Msunlock(cAliEmb)
                endif
                
                for nA := 1 To nTotal
                    DbSelectArea("ZEF")
                    ZEF->(DbSetOrder(1))
                    lPosic  := ZEF->(Dbseek(xFilial("ZEF")+(cAliEmb)->ZV1_NUMOC+left(aBrTipDad[nA, aScan(aBrTipCam,"ZEF_TURNO")],1)+aBrTipDad[nA, aScan(aBrTipCam,"ZEF_CODITE")]))

                    if Reclock("ZEF",iif(lPosic, .F., .T.))
                        ZEF->ZEF_FILIAL := xFilial("ZEF")
                        ZEF->ZEF_NUMOC  := (cAliEmb)->ZV1_NUMOC
                        ZEF->ZEF_CODITE := aBrTipDad[nA, aScan(aBrTipCam,"ZEF_CODITE")]
                        ZEF->ZEF_DESCRI := aBrTipDad[nA, aScan(aBrTipCam,"ZEF_DESCRI")]
                        ZEF->ZEF_TURNO  := val(aBrTipDad[nA, aScan(aBrTipCam,"ZEF_TURNO")])
                        ZEF->ZEF_CONTOT := aBrTipDad[nA, aScan(aBrTipCam,"ZEF_CONTOT")]
                        ZEF->ZEF_CODPAR := aBrTipDad[nA, aScan(aBrTipCam,"ZEF_CODPAR")]
                        ZEF->ZEF_APRCON := aBrTipDad[nA, aScan(aBrTipCam,"ZEF_APRCON")]
                        ZEF->(Msunlock())
                    endif

                next nA

            else
                lRet := .F.
            endif
        else
            MsgAlert("Registro não encontrado!")
        endif

    Elseif nOperation == 5
        
        if ZV1->(Dbseek(xFilial("ZV1")+(cAliEmb)->ZV1_NUMOC))
            if Reclock("ZV1",.F.)
                ZV1->ZV1_STATCO := "N"
                ZV1->ZV1_RATEIO := "N"
                ZV1->ZV1_QTDRT1 := 0
                ZV1->ZV1_QTDRT2 := 0
                Msunlock("ZV1")
            endif

            if Reclock( cAliEmb, .F.)
                (cAliEmb)->ZV1_STATCO := "N"
                (cAliEmb)->ZV1_RATEIO := "N"
                (cAliEmb)->ZV1_QTDRT1 := 0
                (cAliEmb)->ZV1_QTDRT2 := 0
                Msunlock(cAliEmb)
            endif 

            cQuery := " SELECT R_E_C_N_O_ REGISTRO "
            cQuery += " FROM "+ RetSqlName("ZEF") +" ZEF "
            cQuery += " WHERE D_E_L_E_T_='' AND ZEF_FILIAL='"+ xFilial("ZEF") +"' AND ZEF_NUMOC = '"+ (cAliEmb)->ZV1_NUMOC +"'; "

            TcQuery cQuery ALIAS "QZEF" New

            While QZEF->(!EOF())
                ZEF->(Dbgoto(QZEF->REGISTRO))
                if Reclock("ZEF",.F.)
                    ZEF->(DbDelete())
                    ZEF->(Msunlock())
                endif

                QZEF->(Dbskip())
            enddo
            
            QZEF->(DbcloseArea())
        
        else
            MsgAlert("Registro não encontrado!")
        endif

    Endif

    
return lRet

Static Function fValid()
    lRet := .F.

    
    if Empty(cNUMGTA)
        MsgAlert("Código de registro inválido!")
    elseif Empty(cGRACOD)
        MsgAlert("Código da granja em branco!")
    elseif Empty(dDTABAT)
        MsgAlert("Data de emissão em branco!")
    elseif nQTDABA == 0
        MsgAlert("Informe um valor válido!")
    else
        lRet := .T.
    endif

    if cRATEIO == "S" .and. (nQTDRT1 == 0 .or. nQTDRT2 == 0)
        lRet := .F.
        MsgAlert("informe um valor válido nos campos de rateio!")
    Endif

return lRet

Static Function layHeader()
    
    //Carrega o cabeçalho.
    fAtualCab()

    //Cabeçalho com os campos do estabelecimento.
    oLayer:addLine("L01",25, .F.)
    oLayer:addCollumn("L01C01", 100, .F., "L01")

    oLayer:addWindow("L01C01", "Win01", "Dados da Granja"		, 100,.F.,.F.,{||"" },"L01",{||""})

    //oLayer:GetLinePanel("L01"):SetCSS("QFrame{ background-color: #C2C7CB;}")
    oLayer:GetLinePanel("L01"):SetCSS("QFrame{ background-color: #FFFFFF;}")

	oLayer:GetWinPanel("L01C01","Win01","L01"):SetCSS("QFrame{font-size: 14px;}")
	
    //oTop := oLayer:getLinePanel("L01")
    oTop := oLayer:getWinPanel("L01C01","Win01","L01")
    oSize := FWDefSize():New(.F.)
	
    oSize:AddObject( "OBJ01"	, 15 , 50, .T., .T. )
    oSize:AddObject( "OBJ02"	, 20 , 50, .T., .T. )
    oSize:AddObject( "OBJ03"	, 12 , 50, .T., .T. )
    oSize:AddObject( "OBJ04"	, 17 , 50, .T., .T. )
    oSize:AddObject( "OBJ05"	, 45 , 50, .T., .T. )
    oSize:AddObject( "OBJ06"	, 20 , 50, .T., .T. )
    oSize:AddObject( "OBJ07"	, 18 , 50, .T., .T. )
    
	oSize:lLateral	:= .T. // Elementos um do lado do outro
	oSize:lProp		:= .T. // Cálculo dos botões proporcionais
	oSize:SetWindowSize({000, 000, oTop:nHeight, oTop:nWidth})
	oSize:Process() 		// executa os calculos
    
    aRet := fgetSX3("ZV1_NUMGTA")
	oNUMGTA  := TGet():New(002,oSize:GetDimension("OBJ01","COLINI")+2,{|u|If(PCount() == 0, CNUMGTA, CNUMGTA := u)},oTop,oSize:GetDimension("OBJ01","XSIZE"),020,alltrim(aRet[01][03]),,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"CNUMGTA",,,,.T.,,,aRet[01][01],1) 
	if !Empty(aRet[01][09])
        oNUMGTA:cF3 := Alltrim(aRet[01][09])
    endif
    oNUMGTA:SetCSS("QLineEdit{font-size: 24px;}")
    oNUMGTA:lVisibleControl := .T.

    aRet := fgetSX3("ZV1_DTABAT")
    oDTABAT  := TGet():New(002,oSize:GetDimension("OBJ02","COLINI"),{|u|If(PCount() == 0, dDTABAT, dDTABAT := u)},oTop,oSize:GetDimension("OBJ02","XSIZE"), 020,alltrim(aRet[01][03]),,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"dDTABAT",,,,.T.,,,aRet[01][01],1) 
	oDTABAT:SetCSS("QLineEdit{font-size: 24px;}")
    if !Empty(aRet[01][09])
        oDTABAT:cF3 := Alltrim(aRet[01][09])
    endif
    oDTABAT:lVisibleControl := .T.

    aRet := fgetSX3("ZV1_RHABAT")
    oRHABAT  := TGet():New(002,oSize:GetDimension("OBJ03","COLINI"),{|u|If(PCount() == 0, cRHABAT, cRHABAT := u)},oTop,oSize:GetDimension("OBJ03","XSIZE"), 020,alltrim(aRet[01][03]),,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cRHABAT",,,,.T.,,,aRet[01][01],1) 
	oRHABAT:SetCSS("QLineEdit{font-size: 24px;}")
    if !Empty(aRet[01][09])
        oRHABAT:cF3 := Alltrim(aRet[01][09])
    endif
    oRHABAT:lVisibleControl := .T.

    aRet := fgetSX3("ZV1_RGRANJ")
	oGRACOD  := TGet():New(002,oSize:GetDimension("OBJ04","COLINI")+2,{|u|If(PCount() == 0,cGRACOD,cGRACOD := u)},oTop,oSize:GetDimension("OBJ04","XSIZE"),020,alltrim(aRet[01][03]),,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F., {|| fgetFor()},.F.,.F. ,,"cGRACOD",,,,.T.,,,aRet[01][01],1) 
	if !Empty(aRet[01][09])
        oGRACOD:cF3 := Alltrim(aRet[01][09])
    endif
    oGRACOD:SetCSS("QLineEdit{font-size: 24px;}")
    oGRACOD:lVisibleControl := .T.

    aRet := fgetSX3("A2_NOME")
    oRAZAOS  := TGet():New(002,oSize:GetDimension("OBJ05","COLINI"),{|u|If(PCount() == 0, cRAZAOS, cRAZAOS := u)},oTop,oSize:GetDimension("OBJ05","XSIZE"), 020,alltrim(aRet[01][03]),,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cRAZAOS",,,,.T.,,,aRet[01][01],1) 
	oRAZAOS:SetCSS("QLineEdit{font-size: 24px;}")
    if !Empty(aRet[01][09])
        oRAZAOS:cF3 := Alltrim(aRet[01][09])
    endif
    oRAZAOS:lVisibleControl := .T.

    aRet := fgetSX3("ZV1_RPLACA")
    oRPLACA  := TGet():New(002,oSize:GetDimension("OBJ06","COLINI"),{|u|If(PCount() == 0, cRPLACA, cRPLACA := u)},oTop,oSize:GetDimension("OBJ06","XSIZE"), 020,alltrim(aRet[01][03]),,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cRPLACA",,,,.T.,,,aRet[01][01],1) 
	oRPLACA:SetCSS("QLineEdit{font-size: 24px;}")
    if !Empty(aRet[01][09])
        oRPLACA:cF3 := Alltrim(aRet[01][09])
    endif
    oRPLACA:lVisibleControl := .T.
    
    aRet := fgetSX3("ZV1_TURNO")
    oTURNO  := TGet():New(002,oSize:GetDimension("OBJ07","COLINI"),{|u|If(PCount() == 0, cTURNO, cTURNO := u)},oTop,oSize:GetDimension("OBJ07","XSIZE"), 020,alltrim(aRet[01][03]),,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cTURNO",,,,.T.,,,aRet[01][01],1) 
	oTURNO:SetCSS("QLineEdit{font-size: 24px;}")
    if !Empty(aRet[01][09])
        oTURNO:cF3 := Alltrim(aRet[01][09])
    endif
    oTURNO:lVisibleControl := .T.

return

Static function fgetFor()
    Local lRet := .T.

    if !Empty(cGRACOD)
        DbSelectArea("SA2")
        SA2->(DbSetorder(10))
        if SA2->(Dbseek(xFilial("SA2")+cGRACOD))
            cRAZAOS := SA2->A2_GRADES
        else
            lRet := .F.
            MsgAlert("Código da granja não encontrado!")
        endif
    else
        lRet := .T.
    endif

return

/* Carrega os campos padrões do cabeçalho. */
// ZV1_NUMOC,ZV1_DTABAT,ZV1_RGRANJ,A2_NOME,ZV1_TURNO,ZV1_CAVES
Static Function fAtualCab()
    
    cNUMGTA     := (cAliEmb)->ZV1_NUMGTA
    dDTABAT     := (cAliEmb)->ZV1_DTABAT
    dRHABAT     := (cAliEmb)->ZV1_RHABAT
    cGRACOD     := (cAliEmb)->ZV1_RGRANJ
    cRAZAOS     := (cAliEmb)->A2_NOME
    cRPLACA     := (cAliEmb)->ZV1_RPLACA
    cTURNO      := (cAliEmb)->ZV1_TURNO
    nQTDRT1     := (cAliEmb)->ZV1_QTDRT1
    nQTDRT2     := (cAliEmb)->ZV1_QTDRT2
    cRATEIO     := IIF( Empty((cAliEmb)->ZV1_RATEIO), "N", (cAliEmb)->ZV1_RATEIO)
    nQTDABA     := (cAliEmb)->ZV1_CAVES

    if cRATEIO == "N"
        if Left((cAliEmb)->ZV1_TURNO,1) == "1"
            nQTDRT1     := (cAliEmb)->ZV1_CAVES
        elseif Left((cAliEmb)->ZV1_TURNO,1) == "2"
            nQTDRT2     := (cAliEmb)->ZV1_CAVES
        endif
    endif

    cTurRat := iif(left(cTURNO,1) == "1","2-2º Turno","1-1º Turno"  )
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
    local cValue    := ""
    local cReadVar  := ""
	local nCampos   := 0
    local nX        := 0

	if nTypeBrowse == CONS_CAUSA_DEST
		aCampos		:= strToKarr(CAMPOS_CAUSA_DESTINO, ",")
		aBrTipCab	:= {}
    
    elseif nTypeBrowse == CONS_BROWSER
        aCampos		:= strToKarr(CAMPOS_BROWSER , ",")
		aBrowser	:= {}
	endIf

    nCampos := Len(aCampos)

    nCampos := Len(aCampos)
	for nX := 1 to nCampos
		cCampo	:= Alltrim(aCampos[nX])
        

        if nTypeBrowse == CONS_CAUSA_DEST
			cValue      := "{|| aBrTipDad[oBrTip:At(), " + cValToChar(nX) + "]}"
            cReadVar    := "aBrTipDad[oBrTip:At(), " + cValToChar(nX) + "]"
            AADD(aBrTipCam, cCampo)
			AADD(aBrTipCab, cCampo)
        elseif nTypeBrowse == CONS_BROWSER
        	cValue      := "{|| (cAliEmb)->" + cCampo + "}"
            aAdd(aBrowser, cCampo)
		endIf

		oColumn := FWBrwColumn():New()
		oColumn:SetData(&(cValue))
		oColumn:SetTitle(Alltrim(getSx3Cache(cCampo, "X3_TITULO")))
        oColumn:SetType(getSx3Cache(cCampo, "X3_TIPO"))
        oColumn:SetPicture(getSx3Cache(cCampo, "X3_PICTURE"))
        
        //ZV1_DTABAT,ZV1_RHABAT,ZV1_TURNO,ZV1_RGRANJ,A2_NOME,ZV1_RPLACA,ZV1_NUMGTA,ZV1_CAVES
		if cCampo$"ZV1_DTABAT,ZV1_RHABAT,ZV1_TURNO,ZV1_RGRANJ,ZV1_RPLACA,ZV1_NUMGTA"
            oColumn:SetSize(05)
        elseif cCampo$"ZEF_TURNO"
            oColumn:SetSize(10)
            oColumn:SetType("C")
            elseif cCampo$"ZV1_CAVES"
            oColumn:SetSize(15)
        Elseif cCampo$"X5_DESCRI,A2_NOME"
            oColumn:SetSize(40)
        else
            oColumn:SetSize(getSx3Cache(cCampo, "X3_TAMANHO"))
        endif

        /*
        if cCampo$"ZEF_CONTOT, ZEF_CODPAR, ZEF_APRCON"
            oColumn:lEdit := .T.
            oColumn:cReadVar := cReadVar
        endif
        */

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
    Local nTurTmp   := 0
    Local cProd     := ""
	local cTipoCp	:= ""
    Local cCargo    := ""

    aCampos := strToKarr(CAMPOS_CAUSA_DESTINO, ",")

    IF nTypeBrowse == CONS_CAUSA_DEST
        cQuery := " SELECT " + CAMPOS_CAUSA_DESTINO
        cQuery += " FROM "+ RetSqlName("ZEF") +" (NOLOCK) ZEF "
        cQuery += " WHERE ZEF.D_E_L_E_T_='' AND ZEF.ZEF_FILIAL='"+ xFilial("ZEF") +"' AND ZEF.ZEF_NUMOC='"+ (cAliEmb)->ZV1_NUMOC +"' "
        cQuery += " ORDER BY R_E_C_N_O_; "

        tcQuery cQuery alias &cAlias new

        (cAlias)->(DbGoTop())

        if (cAlias)->(!eof())
        
        else
            
            if Select(cAlias) > 0
                (cAlias)->(DbCloseArea())
            endif
            
            cQuery := " SELECT X5_CHAVE ZEF_CODITE, X5_DESCRI ZEF_DESCRI, "+ left((cAliEmb)->ZV1_TURNO,1) +" ZEF_TURNO,0 ZEF_CONTOT,0 ZEF_CODPAR,0 ZEF_APRCON " 
            cQuery += " FROM "+ RetSqlName("SX5") +" (NOLOCK) X5 "
            cQuery += " WHERE X5.D_E_L_E_T_='' AND X5.X5_TABELA='_G' "
            cQuery += " ORDER BY ZEF_TURNO, ZEF_CODITE; "

            tcQuery cQuery alias &cAlias new

            (cAlias)->(DbGoTop())

        endif
    else
        if Select(cAlias) > 0
                (cAlias)->(DbCloseArea())
            endif
            
            cQuery := " SELECT X5_CHAVE ZEF_CODITE, X5_DESCRI ZEF_DESCRI, "+ left(cTurRat,1) +" ZEF_TURNO,0 ZEF_CONTOT,0 ZEF_CODPAR,0 ZEF_APRCON " 
            cQuery += " FROM "+ RetSqlName("SX5") +" (NOLOCK) X5 "
            cQuery += " WHERE X5.D_E_L_E_T_='' AND X5.X5_TABELA='_G' "
            cQuery += " ORDER BY ZEF_TURNO, ZEF_CODITE; "

            tcQuery cQuery alias &cAlias new

            (cAlias)->(DbGoTop())
    endif

    if (cAlias)->(!eof())
        While (cAlias)->(!eof())
            aDado := {}
            
            for nX := 1 to Len(aCampos)
                cTipoCp	:= allTrim(getSx3Cache(aCampos[nX], "X3_TIPO"))

                if cTipoCp <> "D"
                    if Alltrim(aCampos[nX]) == "ZEF_TURNO"
                        cTurTmp := cValtochar((cAlias)-> &(aCampos[nX]))
                        aAdd(aDado,  cTurTmp+"-"+cTurTmp+"º Turno")
                    else
                        aAdd(aDado, (cAlias)-> &(aCampos[nX]))
                    endif
                else
                    aAdd(aDado, sToD((cAlias)-> &(aCampos[nX])))
                endIf
            next nX
            
            aAdd(aDado, .F.)

            aAdd(aDados, aDado)
            (cAlias)->(DbSkip())
        EndDo
    Else
        MsgAlert("Não foi possível preencher os dados do formulário.")
    endIf

    (cAlias)->(DbcloseArea())
return(aDados)
