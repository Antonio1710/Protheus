#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} User Function ADGPE076P
    Tela de retirada de kits na expedição e portaria (Frango).
    @type  Function
    @author Leonardo P. Monteiro
    @since 07/09/2021
    @version version
    @history Ticket: 16835 - 06/10/2021 - ADRIANO SAVOINE - Tratado o Metodo de entrada na inserção manual da chapa, Leitura do Codigo de barras do cracha ou leitura de aproximação.
    @history Ticket: 16835 - 28/10/2021 - ADRIANO SAVOINE - Tratado a entrada de dados sem precisar clicar em Pesquisar, apos a leitura o mesmo carrega os dados, tratado tambem a mensagem apos confirmar.
    @history Ticket: 69748 - 17/03/2022 - ADRIANO SAVOINE - Tratado para Leitura dos cracha com filial no codigo de barras.
    U_ADGPE076P()
/*/

#DEFINE CONSULTA_ITENS "ZI0_PERIOD,ZI0_PRODUT,B1_DESC,REGISTRO"

#DEFINE CONSULTA_KIT_EXPEDICAO      1
#DEFINE CONSULTA_KIT_PORTARIA       2

user function ADGPE076P(nTipo, cTitle)
    
    Local nAlt      := 0
    Local nLarg     := 0
    Local aSize     := {}
    Private cColig  := FWFilial('ZI0')
    
    Private oWnd
    Private oLayer
    Private oPesq
    Private oL01C01
    Private oBItKit

    Private oButPesq
    Private oButConf
    Private oButFina

    Private nItKiCam    := 0
    Private aItKiCab    := {}
    Private aItKiCam    := {}
    Private aItKiDad    := {}

    Private oTBitmap

    Private oZI1MAT
    Private cZI1MAT     := Space(40)

    Private oZI1CRE
    Private cZI1CRE     := Space(40)

    Private oZI1NOM
    Private cZI1NOM     := Space(40)

    //Private oZI0PER
    //Private cZI0PER     := Space(40)

    Private cPesq       := Space(100)
    
    Private bMark       := {|oBItKit| fMark(oBItKit)}
    Private bDblClk     := {|oBItKit| fDblClk(oBItKit) /*Função DoubleClick*/ }
    Private bHeaClk     := {|oBItKit| fHeaClk(oBItKit) /* Função de HEADERCLICK*/}
    
    Private nOpcao       := nTipo

    //
    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de retirada de kits na expedição e portaria (Frango)')


    Default cTitle      := "..:: Tela de Coleta Kits Frango ("+ iif(nOpcao==1,"Expedição","Portaria") +") ::.."

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
    
    oWnd            := Msdialog():Create()
    oWnd:cTitle     := cTitle
    ownd:nWidth     := nLarg
    oWnd:nHeight    := nAlt
    oWnd:lMaximized := .T.
    oWnd:SetCSS("QWidget{ font: bold 12px; } TTabs{ margin: 0px; } ")

    oLayer := FWLayer():new()
    
    oLayer:init(oWnd,.F.)
    //oLayer:opanel:nHeight    := nAlt*1.01
    //oLayer:opanel:nHeight    := nAlt

    oLayer:addLine("L01",15, .F.)
    oLayer:addCollumn("L01C01", 100, .F., "L01")
  
    oLayer:addLine("L02",85, .F.)
    oLayer:addCollumn("L02C01", 050, .F., "L02")
    oLayer:addCollumn("L02C02", 050, .F., "L02")

    oLayer:addWindow("L02C01", "Win01", "Itens p/ Entrega"		    , 100,.F.,.F.,{||"" },"L02",{||""})
    oLayer:addWindow("L02C02", "Win02", "Dados do Colaborador"		, 100,.F.,.F.,{||"" },"L02",{||""})

    layPesq()
    layList()
    //layDado()

    //oLayer:addCollumn("L01C02", 030, .F., "L01")
    oPesq:setFocus()
    oWnd:Activate()

return


Static Function layPesq()

    oL01C01 := oLayer:getColPanel("L01C01", "L01")
    oSize := FWDefSize():New(.F.)
	
    oSize:AddObject( "OBJ01"	, 70, 50, .T., .T. )
    oSize:AddObject( "OBJ02"	, 10, 50, .T., .T. )
    oSize:AddObject( "OBJ03"	, 10, 50, .T., .T. )
    oSize:AddObject( "OBJ04"	, 10, 50, .T., .T. )
	oSize:lLateral	:= .T. // Elementos um do lado do outro
	oSize:lProp		:= .T. // Cálculo dos botões proporcionais
	oSize:SetWindowSize({000, 000, oL01C01:nHeight, oL01C01:nWidth})
	oSize:Process() 		// executa os calculos

    //**************************************************
    // Sessão de filtros.
    //**************************************************
    
    oPesq:= TGet():New(002,oSize:GetDimension("OBJ01","COLINI"),{|u|If(PCount() == 0, cPesq, cPesq := u)},oL01C01,oSize:GetDimension("OBJ01","XSIZE"),020,"", {|| FVALID() },0,16777215,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F. ,,"cPesq",,,,.T.,,,"Pesquisar Matrícula/Credencial",1) 
    oPesq:SetCSS("QLineEdit{font-size: 24px; width: 90%;}")
    oPesq:lVisibleControl := .T.
   
    oButPesq := TButton():New( 2, oSize:GetDimension("OBJ02","COLINI"), "Pesquisar [F6]", oL01C01,{|| fGetDado(1), oPesq:setFocus()},;
    oSize:GetDimension("OBJ02","XSIZE"),oSize:GetDimension("OBJ02","YSIZE")-02,,,.F.,.T.,.F.,,.F.,,,.F. )

    oButConf := TButton():New( 2, oSize:GetDimension("OBJ03","COLINI"), "Confirmar [F7]", oL01C01,{|| fConfirm(), fGetDado(2), oPesq:setFocus()},;
    oSize:GetDimension("OBJ03","XSIZE"),oSize:GetDimension("OBJ03","YSIZE")-02,,,.F.,.T.,.F.,,.F.,,,.F. )
    
    oButFina := TButton():New( 2, oSize:GetDimension("OBJ04","COLINI"), "Finalizar [F8]", oL01C01,{|| ownd:End()},;
    oSize:GetDimension("OBJ04","XSIZE"),oSize:GetDimension("OBJ04","YSIZE")-02,,,.F.,.T.,.F.,,.F.,,,.F. )

    SetKey( VK_F6,  {|| fGetDado(1)     } )
    SetKey( VK_F7,  {|| fConfirm(), fGetDado(2), oPesq:setFocus() } )
    SetKey( VK_F8,  {|| oWnd:End()          } )
    SetKey( VK_F9,  {|| oPesq:setFocus()    } )
return

// Ticket: 16835 - 28/10/2021 - ADRIANO SAVOINE
STATIC FUNCTION FVALID()
    fGetDado(1)
RETURN .t.

Static Function fConfirm()
    Local nA        := 0
    Local nItKiDad  := Len(aItKiDad)
    Local nPosReg   := aScan(aItKiCam, "REGISTRO")
    Local nPosPrd   := aScan(aItKiCam, "ZI0_PRODUT")
    Local nRegist   := 0
    Local cProdut   := ""

   

    DbSelectArea("ZI0")
    
    for nA := 1 To nItKiDad
        if aItKiDad[nA, nItKiCam]
            nRegist := aItKiDad[nA, nPosReg]
            cProdut := aItKiDad[nA, nPosPrd]

            ZI0->(Dbgoto(nRegist))

            if ZI0->(Recno()) == nRegist
                RecLock("ZI0", .F.)
                
                if nOpcao == 1
                    ZI0->ZI0_STATUS := "2"
                    ZI0->ZI0_EXPDAT := Dtoc(Date())+" "+Time()
                    ZI0->ZI0_EXPUSU := __cUserID
                ELSEIF nOpcao == 2
                    ZI0->ZI0_STATUS := "3"
                    ZI0->ZI0_PORDAT := Dtoc(Date())+" "+Time()
                    ZI0->ZI0_PORUSU := __cUserID
                endif

                ZI0->(MsUnlock())
            endif

        endif
    next nA

    
    cPesq := Space(100)
    
return

Static Function fGetDado(nAlerta)
    Local lRet
    Local cQuery    := ""
    Default nAlerta := 1


      
        //Pegando o texto atual
        cRetorno  := Alltrim(cPesq)

        // Ticket: 16835 - 06/10/2021 - ADRIANO SAVOINE - INICIO
        IF len(Alltrim(cPesq)) = 8
         cPesq := SUBSTRING(cPesq,2,6)
        ENDIF 
        // Ticket: 69748 - 17/03/2022 - ADRIANO SAVOINE 
        IF len(Alltrim(cPesq)) = 10
         cPesq := SUBSTRING(cPesq,4,6)
        ENDIF 

        IF len(Alltrim(cPesq)) = 14

            lContinua := .T.

            //Enquanto existir zeros a esquerda
            While lContinua
                //Se a priemira posição for diferente de 0 ou não existir mais texto de retorno, encerra o laço
                If SubStr(cRetorno, 1, 1) <> "0" .Or. Len(cRetorno) ==0
                    lContinua := .f.
                EndIf
                
                //Se for continuar o processo, pega da próxima posição até o fim
                If lContinua
                    cRetorno := Substr(cRetorno, 2, Len(cRetorno))
                EndIf
            EndDo

         
        ENDIF
    
        // Ticket: 16835 - 06/10/2021 - ADRIANO SAVOINE - FIM


    cQuery := " SELECT ZI1_MAT, ZI1_CREDEN, ZI1_NOME "
    cQuery += " FROM "+ RetSqlName("ZI1") +" ZI1 "
    cQuery += " WHERE D_E_L_E_T_='' AND ZI1_MSBLQL !='1' AND ( (ZI1_MAT ='' AND ZI1_CREDEN !='') OR (ZI1_MAT !='' AND ZI1_CREDEN ='') OR (ZI1_MAT !='' AND ZI1_CREDEN !='')) "
    

    IF Empty(Alltrim(cPesq))
        cQuery += "  AND ltrim(rTrim(ZI1_MAT))='ZZZZZZZZZ' "
    else
        cQuery += "  AND (ltrim(rTrim(ZI1_MAT))='"+ cColig + Alltrim(cPesq) +"' OR ltrim(rTrim(ZI1_CREDEN))='"+ Alltrim(cRetorno) +"') "
    endif


    TcQuery cQuery ALIAS "QZI1" NEW

    if QZI1->(!eof())
        cZI1MAT := QZI1->ZI1_MAT
        cZI1CRE := QZI1->ZI1_CREDEN
        cZI1NOM := QZI1->ZI1_NOME

        lRet := .T.
    else
        cZI1MAT := Space(100)
        cZI1CRE := Space(100)
        cZI1NOM := Space(100)

        lRet := .F.
    endif
    
    QZI1->(DbcloseArea())

    // Lista itens de expedição.
    if nOpcao == 1
        aItKiDad    := getDadosBrw(CONSULTA_KIT_EXPEDICAO)
    // Lista itens de portaria.
    elseif nOpcao == 2
        aItKiDad    := getDadosBrw(CONSULTA_KIT_PORTARIA)
    endif

    oBItKit:setArray(aItKiDad)
    oBItKit:refresh()

    if !lRet .and. nAlerta == 1 .AND. len(Alltrim(cPesq)) > 0 //Ticket: 16835 - 28/10/2021 - ADRIANO SAVOINE
        MsgAlert("Credencial inválido ou colaborador não encontrado ou inativo!", "..:: Não encontrado ::..")
    elseif Len(aItKiDad) == 0 .AND. len(Alltrim(cPesq)) > 0  //Ticket: 16835 - 28/10/2021 - ADRIANO SAVOINE
        MsgAlert('<h1><font color="#FF0000">Não há itens a serem entregues. Procure o Recursos Humanos!</font></h1>', "..:: Não encontrado ::..")
    endif

    cPesq := Space(100)

Return lRet

Static Function layList()
    
    // Lista itens de expedição.
    if nOpcao == 1
        aItKiCab	:= getCampos(CONSULTA_KIT_EXPEDICAO)
        aItKiDad    := getDadosBrw(CONSULTA_KIT_EXPEDICAO)
    // Lista itens de portaria.
    elseif nOpcao == 2
        aItKiCab	:= getCampos(CONSULTA_KIT_PORTARIA)
        aItKiDad    := getDadosBrw(CONSULTA_KIT_PORTARIA)
    endif

    oItWin01    := oLayer:GetWinPanel("L02C01","Win01","L02")

    oBItKit     := FWBrowse():New(oItWin01)
    
    oBItKit:addMarkColumns(bMark, bDblClk, bHeaClk)

    oBItKit:setColumns(aItKiCab)
	oBItKit:setDataArray()
	oBItKit:disableReport()
	oBItKit:disableConfig()
    oBItKit:setArray(aItKiDad)
    oBItKit:Activate()
    
    oItWin02    := oLayer:GetWinPanel("L02C02","Win02","L02")

    oSize := FWDefSize():New(.F.)
	
    oSize:AddObject( "OBJ01"	, 90 , 55, .T., .T. )
    //oSize:AddObject( "OBJ02"	, 90 , 10, .T., .T. )
    oSize:AddObject( "OBJ03"	, 90 , 15, .T., .T. )
    oSize:AddObject( "OBJ04"	, 90 , 15, .T., .T. )
    oSize:AddObject( "OBJ05"	, 50 , 15, .T., .T. )
    //oSize:AddObject( "OBJ06"	, 50 , 15, .T., .T. )
    
	oSize:lLateral	:= .F. // Elementos um do lado do outro
	oSize:lProp		:= .T. // Cálculo dos botões proporcionais
	oSize:SetWindowSize({000, 000, oItWin02:nHeight, oItWin02:nWidth})
	oSize:Process() 		// executa os calculos
    /*
    aRet := fgetSX3("ZI0_PERIOD")
	oZI0PER  := TGet():New(oSize:GetDimension("OBJ03","LININI"),;
                           oSize:GetDimension("OBJ03","COLINI"),; 
                           {|u|If(PCount() == 0, cZI0PER, cZI0PER := u)}, oItWin02,; 
                           oSize:GetDimension("OBJ03","XSIZE"), 020,;
                           alltrim(aRet[01][03]),,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cZI0PER",;
                           ,,,.T.,,,aRet[01][01],1)
    oZI0PER:SetCSS("QLineEdit{font-size: 24px; }")
	if !Empty(aRet[01][09])
        oZI0PER:cF3 := Alltrim(aRet[01][09])
    endif
    oZI0PER:lVisibleControl := .T.
    */
    //unnamed.png
	oTBitmap := TBitmap():New(oSize:GetDimension("OBJ01","LININI"),; 
                              oSize:GetDimension("OBJ01","COLINI"),; 
                              100,;
                              oSize:GetDimension("OBJ01","YSIZE") , NIL, "\system\unnamed.png", .T., oItWin02,;
        {|| .F. }, NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)

    aRet := fgetSX3("ZI1_MAT")
	oZI1MAT  := TGet():New(oSize:GetDimension("OBJ03","LININI"),;
                           oSize:GetDimension("OBJ03","COLINI"),; 
                           {|u|If(PCount() == 0, cZI1MAT, cZI1MAT := u)}, oItWin02,; 
                           oSize:GetDimension("OBJ03","XSIZE"), 020,;
                           alltrim(aRet[01][03]),,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cZI0MAT",;
                           ,,,.T.,,,aRet[01][01],1)
    oZI1MAT:SetCSS("QLineEdit{font-size: 24px;}")
	if !Empty(aRet[01][09])
        oZI1MAT:cF3 := Alltrim(aRet[01][09])
    endif
    oZI1MAT:lVisibleControl := .T.

    aRet := fgetSX3("ZI1_CREDEN")
	oZI1CRE  := TGet():New(oSize:GetDimension("OBJ04","LININI"),;
                           oSize:GetDimension("OBJ04","COLINI"),; 
                           {|u|If(PCount() == 0, cZI1CRE, cZI1CRE := u)}, oItWin02,; 
                           oSize:GetDimension("OBJ04","XSIZE"), 020,;
                           alltrim(aRet[01][03]),,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cZI1CRE",;
                           ,,,.T.,,,aRet[01][01],1)
    oZI1CRE:SetCSS("QLineEdit{font-size: 24px;}")
	if !Empty(aRet[01][09])
        oZI1CRE:cF3 := Alltrim(aRet[01][09])
    endif
    oZI1CRE:lVisibleControl := .T.

    aRet := fgetSX3("ZI1_NOME")
	oZI1NOM  := TGet():New(oSize:GetDimension("OBJ05","LININI"),;
                           oSize:GetDimension("OBJ05","COLINI"),; 
                           {|u|If(PCount() == 0, cZI1NOM, cZI1NOM := u)}, oItWin02,; 
                           oSize:GetDimension("OBJ05","XSIZE"), 020,;
                           alltrim(aRet[01][03]),,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cZI1NOM",;
                           ,,,.T.,,,aRet[01][01],1)
    oZI1NOM:SetCSS("QLineEdit{font-size: 24px;}")
	if !Empty(aRet[01][09])
        oZI1NOM:cF3 := Alltrim(aRet[01][09])
    endif
    oZI1NOM:lVisibleControl := .T.

return

static function getCampos(nTypeBrowse)
	local aCpoRet	:= {}
    local aCampos   := {}
	local nCampos   := 0
    local nX        := 0

    aCampos		:= strToKarr(CONSULTA_ITENS, ",")
    aItKiCab    := {}
    //aItKiCam    := aCampos
    
    nCampos := Len(aCampos)
    

    for nX := 1 to nCampos
		cCampo	:= Alltrim(aCampos[nX])
        
        cValue := "{|| aItKiDad[oBItKit:At(), " + cValToChar(nX) + "]}"
		
		oColumn := FWBrwColumn():New()
		oColumn:SetData(&(cValue))
        
        if Alltrim(cCampo) == "REGISTRO"
            cTitulo := "Registro"
        
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
        AADD(aItKiCam, cCampo)
        aAdd(aCpoRet, oColumn)

	next nX
    
    aAdd(aItKiCam, "MARCA")

    nItKiCam    := Len(aItKiCam)

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


    aCampos := strToKarr(CONSULTA_ITENS, ",")
    cCampos := CONSULTA_ITENS
    
    cQuery := " SELECT ZI0_PERIOD,ZI0_PRODUT, B1_DESC, ZI0.R_E_C_N_O_ REGISTRO " +cQebra
    cQuery += " FROM "+ RetSqlName("ZI0") +" ZI0 INNER JOIN "+ RetSqlname("SB1") +" B1 ON ZI0.D_E_L_E_T_='' AND B1.D_E_L_E_T_='' AND ZI0.ZI0_PRODUT=B1.B1_COD " +cQebra
    cQuery += " WHERE ZI0.D_E_L_E_T_='' AND ZI0.ZI0_FECHAM='' AND ZI0.ZI0_AUTAJU = 'S' AND ( (ZI0_MAT ='' AND ZI0_CREDEN !='') OR (ZI0_MAT !='' AND ZI0_CREDEN ='') OR (ZI0_MAT !='' AND ZI0_CREDEN !='') ) "
    
    if Empty(Alltrim(cPesq))
        cQuery += " AND (ZI0.ZI0_MAT = 'ZZZZZ') "
    else
        cQuery += " AND (ZI0.ZI0_CREDEN = '"+ Alltrim(cRetorno) +"' OR ZI0.ZI0_MAT = '"+ cColig + Alltrim(cPesq) +"') "
    endif

    if nTypeBrowse == CONSULTA_KIT_EXPEDICAO
        cQuery  += " AND ZI0.ZI0_STATUS='1' AND ZI0_EXPVLD='1' "
    Elseif nTypeBrowse == CONSULTA_KIT_PORTARIA
        cQuery  += " AND ZI0.ZI0_STATUS='2' AND ZI0_PORVLD='1' "
    endif

    cQuery += "    ORDER BY ZI0.ZI0_PRODUT; "

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

            aAdd(aDado,.T.)

            aAdd(aDado, .F.)
			aAdd(aDados, aDado)
			(cAlias)->(DbSkip())
		EndDo

	endIf

    (cAlias)->(DbCloseArea())

return(aDados)

// {|| aItKiDad[oBItKit:At(), " + cValToChar(nX) + "]}
Static Function fMark(oBItKit)

return IIf(aItKiDad[oBItKit:At(), nItKiCam],'LBOK','LBNO')

Static Function fDblClk(oBItKit)
    Local lRet      := .T.
    //Local nPosPrd   := aScan(aItKiCam, "B1_COD")

    lRet    := IIf(aItKiDad[oBItKit:At(), nItKiCam], .F., .T.)
    
    aItKiDad[oBItKit:At(), nItKiCam]    := lRet

return lRet

Static Function fHeaClk(oBItKit)
    Local lRet := .T.
return lRet

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
