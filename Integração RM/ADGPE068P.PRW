#INCLUDE "totvs.ch"
#INCLUDE "FWMVCDef.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} User Function ADGPE068P
    Cadastro de elegíveis para o Kit Adoro (Frango).
    @type  Function
    @author Leonardo P. Monteiro
    @since 21/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)

    U_ADGPE068P()
/*/

// Grids
#DEFINE CONS_BROWSER        1

Static cTitle := "..:: Períodos do Ponto Eletrônico (RM) ::.."

User Function ADGPE068P()
    Local aArea     := GetArea()
    Local nAlt      := 0
    Local nLarg     := 0
    
    Private aRet        := {}

    Private cColRM      := fGetColRM()
    
    Private oOrdena
    Private nOrdena     := 0
    Private cOrdena     := ""
    Private aOrdena     := {}

    Private oPesquisa   
    Private cPesquisa   := Space(40)
    Private nPesquisa   := 0

    Private oWnd
    Private oLayer
    Private oBrPer
    Private bConfirma   := {|| iif(fConfirma(), oWnd:End(), .F.) }
    
    Private aBrPerCab   := {}
    Private aBrPerDad   := {}
    Private aBrPerCam   := {}

    Private aSeek       := {}

    Private cBtnCss     := ""

    //Private oRMxPRO     := RMxPRO():New()
    if Empty(cColRM)
        MsgInfo("Não foi encontrado o cadastro de coligadas!", "..:: Cadastro Coligadas ::..")
    else
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


        AADD(aBrPerCam,{"ANOCOMP"     ,"Ano"         ,"C",8,""})
        AADD(aBrPerCam,{"MESCOMP"     ,"Mês"         ,"C",8,""})
        AADD(aBrPerCam,{"INICIOMENSAL","Per. Inicial","D",25,""})
        AADD(aBrPerCam,{"FIMMENSAL"   ,"Per. Final"  ,"D",8,""})

        if type("cFilAnt") == "U"
            //RpcsetType(3)
            //Rpcsetenv("01","02","LEONARDO_MONTEIRO","")
            nAlt    := GetScreenRes()[02]*0.50
            nLarg   := GetScreenRes()[01]*0.50
        else
            aSize   := MsAdvSize(.T.)
            nAlt    := aSize[06]*0.90
            nLarg   := aSize[05]*0.50
        endif

        oWnd            := Msdialog():Create()
        oWnd:cTitle     := cTitle
        ownd:nWidth     := nLarg
        oWnd:nHeight    := nAlt
        oWnd:lMaximized := .F.
        oWnd:SetCSS("QWidget{ font: normal 12px; } TTabs{ margin: 0px; } ")

        oLayer := FWLayer():new()
        
        oLayer:init(oWnd,.T.)
        //oLayer:opanel:nHeight    := nAlt*1.01

        layHeader()
        layDetail()
        layFooter()

        oWnd:Activate()
    endif
    
    RestArea(aArea)
return aRet

Static Function fGetColRM()
    Local cQuery    := ""
    Local cRet      := ""

    cQuery  := " SELECT ZI2_COLRM "
    cQuery  += " FROM "+ RetSqlName("ZI2") +" "
    cQuery  += " WHERE D_E_L_E_T_='' AND ZI2_FILIAL='"+ xFilial("ZI2") +"' "

    Tcquery cQuery ALIAS "QCOL" NEW

    if QCOL->(!EOF())
        cRet := cValTochar(QCOL->ZI2_COLRM)
    endif

    QCOL->(DbcloseArea())

return cRet


Static function layHeader()
    oLayer:addLine("L01",13, .F.)
    //oLayer:addCollumn("L01C01", 100, .F., "L01")

    //oLayer:addWindow("L01C01", "Win01", "Pesquisa"		, 100,.F.,.F.,{||"" },"L01",{||""})

    //oLayer:GetLinePanel("L01"):SetCSS("QFrame{ background-color: #C2C7CB;}")
    oLayer:GetLinePanel("L01"):SetCSS("QFrame{ background-color: #FFFFFF;}")

	//oLayer:GetWinPanel("L01C01","Win01","L01"):SetCSS("QFrame{font-size: 12px;}")
	
    oTop := oLayer:getLinePanel("L01")
    //oTop := oLayer:getWinPanel("L01C01","Win01","L01")
    oSize := FWDefSize():New(.F.)
	
    oSize:AddObject( "OBJ01"	, 30, 50, .T., .T. )
    oSize:AddObject( "OBJ02"	, 50, 50, .T., .T. )
    oSize:AddObject( "OBJ03"	, 20, 50, .T., .T. )
    
    
	oSize:lLateral	:= .T. // Elementos um do lado do outro
	oSize:lProp		:= .T. // Cálculo dos botões proporcionais
	oSize:SetWindowSize({000, 000, oTop:nHeight, oTop:nWidth})
	oSize:Process() 		// executa os calculos

    
    aOrdena  := {"Ano+Mês"}
    oOrdena 	:= tComboBox():New(002,oSize:GetDimension("OBJ01","COLINI"),{|u|if(PCount()>0,cOrdena:=u,cOrdena)},aOrdena,oSize:GetDimension("OBJ01","XSIZE"),013,oTop,,{|| .T. },,,,.T.,,,,{|| .F.},,,,,'nOrderna', "Ordenação",1)
	oOrdena:lVisibleControl := .T.
    
    oPesquisa  := TGet():New(002,oSize:GetDimension("OBJ02","COLINI"),{|u|If(PCount() == 0,cPesquisa,cPesquisa := u)},oTop,oSize:GetDimension("OBJ02","XSIZE"), 010,alltrim(""),,0,16777215,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F. ,,"cPesquisa",,,,.T.,,,"Pesquisa",1) 
    oPesquisa:lVisibleControl := .T.

    oBtnPesq := TButton():New(oSize:GetDimension("OBJ03","LININI"), oSize:GetDimension("OBJ03","COLINI"), "Pesquisar >"   , oTop,{|| fPesquisa() }, oSize:GetDimension("OBJ03","XSIZE"),20,,,.F.,.T.,.F.,,.F.,{|| iif(len(aBrPerDad) > 0, .T., .F. )},,.F. )

return


Static function layDetail()

    olayer:addLine("L02",75, .F.)
    oLayer:addCollumn("L02C01", 100, .F., "L02")
    oLayer:addWindow("L02C01", "Win02", "Períodos"	, 100,.F.,.F.,{||"" },"L02",{||""})
    oLayer:GetLinePanel("L02"):SetCSS("QFrame{ background-color: #FFFFFF;}")
	oLayer:GetWinPanel("L02C01","Win02","L02"):SetCSS("QFrame{font-size: 14px;}")

    aBrPerCab		:= getCampos(CONS_BROWSER)
    aBrPerDad		:= getDadosBrw(CONS_BROWSER)
    
    oWin02 := oLayer:GetWinPanel("L02C01","Win02","L02")

    oBrPer := FWBrowse():New(oWin02)
    oBrPer:setColumns(aBrPerCab)
	oBrPer:setDataArray()
	oBrPer:disableReport()
	oBrPer:disableConfig()
    oBrPer:setArray(aBrPerDad)
    oBrPer:SetDoubleClick(bConfirma)
    oBrPer:bGotFocus := {|| nBrwFocused := 1}

    aAdd(aSeek,{"Ano+Mês"   , {{"","C",15,0, "ANOCOM+MESCOMP",}}})
    
    oBrPer:Activate()
RETURN

static function fConfirma()
    Local lRet := .T.
    aRet := Array(04)

    aRet[01] := aBrPerDad[oBrPer:At(), 01]
    aRet[02] := aBrPerDad[oBrPer:At(), 02]
    aRet[03] := aBrPerDad[oBrPer:At(), 03]
    aRet[04] := aBrPerDad[oBrPer:At(), 04]

return lRet

static function fPesquisa()
	local nPosAno	:= 1
	local nPosMes	:= 2
	local nPosRet	:= 0

    if nOrder == 1
	    nPosRet := aScan(oBrPer:oData:aArray, {|x| allTrim(cPesquisa) $ cValtochar(x[nPosAno])+cValtochar(x[nPosMes])})
    endif

    if nPosRet > 0
    
    endif

	if nPosRet == 0
        Msginfo("Não foi encontrado nenhum registro!")
		nPosRet := 1
	endIf

    oBrPer:goto(nPosRet)

return(nPosRet)

Static Function layFooter()
//Tela de talhada com os grids e folders.
    olayer:addLine("L03",12, .F.)
    
    oFoLin1     := oLayer:GetLinePanel("L03")
    
    oSize := FWDefSize():New(.F.)
	
    oSize:AddObject( "OBJ01"	, 70 , 25, .T., .T. )
    oSize:AddObject( "OBJ02"	, 15 , 35, .T., .T. )
    oSize:AddObject( "OBJ03"	, 15 , 35, .T., .T. )
      
    
	oSize:lLateral	:= .T. // Elementos um do lado do outro
	oSize:lProp		:= .T. // Cálculo dos botões proporcionais
	oSize:SetWindowSize({000, 000, oFoLin1:nHeight, oFoLin1:nWidth})
	oSize:Process() 		// executa os calculos

    oBtnCanc    := TButton():New( oSize:GetDimension("OBJ02","LININI"), oSize:GetDimension("OBJ02","COLINI"), "Cancelar"   , oFoLin1,{|| aRet :={}, oWnd:End() }, oSize:GetDimension("OBJ02","XSIZE"),25,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnConf    := TButton():New( oSize:GetDimension("OBJ03","LININI"), oSize:GetDimension("OBJ03","COLINI"), "Confirmar"  , oFoLin1, bConfirma, oSize:GetDimension("OBJ03","XSIZE"),25,,,.F.,.T.,.F.,,.F.,,,.F. )
    
    oBtnCanc:setCss(cBtnCss)
    oBtnConf:setCss(cBtnCss)
return


// Array dos campos dos pedidos prontos para Embalagem
static function getCampos(nTypeBrowse)
	local aCpoRet	:= {}
    local aCampos   := {}
    local cValue    := ""
    local cReadVar  := ""
	local nCampos   := 0
    local nX        := 0

    if nTypeBrowse == CONS_BROWSER
        
        aCampos := aBrPerCam
       
        nCampos := Len(aCampos)
	endIf

	for nX := 1 to nCampos
		cCampo	:= Alltrim(aCampos[nX][01])
        
        if nTypeBrowse == CONS_BROWSER
        	cValue      := "{|| aBrPerDad[oBrPer:At(), " + cValToChar(nX) + "]}"
            cReadVar    := "aBrPerDad[oBrPer:At(), " + cValToChar(nX) + "]"
            
		endIf

		oColumn := FWBrwColumn():New()
		oColumn:SetData(&(cValue))
		oColumn:SetTitle(Alltrim(aCampos[nX][02]))
        oColumn:SetType(aCampos[nX][03])
        oColumn:SetSize(aCampos[nX][04])
        oColumn:SetPicture(aCampos[nX][05])
        
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
    local nCampos   := 0
	local nX		:= 1
    
    if nTypeBrowse == CONS_BROWSER
        
        cQuery := " EXEC SP_RM_PERIODOS_PONTO "+ cColRM +" "
        
        tcQuery cQuery alias &cAlias new

        (cAlias)->(DbGoTop())

        aCampos := aBrPerCam
        nCampos := Len(aCampos)
        
    endif

    if (cAlias)->(!eof())
        While (cAlias)->(!eof())
            aDado := {}
            
            for nX := 1 to nCampos
                cTipoCp	:= allTrim(aCampos[nX][03])

                if cTipoCp <> "D"
                    aAdd(aDado, (cAlias)-> &(aCampos[nX][01]))
                elseif cTipoCp == "D"
                    aAdd(aDado, sToD((cAlias)-> &(aCampos[nX][01])))
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
