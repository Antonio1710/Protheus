#Include "protheus.ch"
#Include "TopConn.ch"
#include "colors.ch"
#Include "Font.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} User Function ADEEC013R U_ADEEC013R()
    Etiqueta de exportação.
    Chamado 18887
    @type  Function
    @author Leonardo P. Monteiro
    @since 26/08/2021
    @version 01
    
/*/
#Define IMP_SPOOL  2
#Define IMP_PDF    1
#Define DMPAPER_A4 9

User Function ADEEC013R() // U_ADEEC013R()

    Local titulo   				:= "Ordem de Carregamento Exportação"
    Local cPerg					:= "ADEEC013R"
    Local cNomRel				:= "ADEEC013R"
    Local nA                    := 0
    Local nValor                := 0

    Local lAdjustToLegacy 		:= .F. 
    Local lDisableSetup  		:= .T.

    Private cEOL				:= chr(13)+Chr(10)
    
    Private oFOARNO04	  		:= TFont():New("Arial",07,04,.T.,.F.,,,,,.F.) // Arial, Normal,  Tam. 05
    Private oFOARNO05	  		:= TFont():New("Arial",07,05,.T.,.F.,,,,,.F.) // Arial, Normal,  Tam. 05
    Private oFOARNO06	  		:= TFont():New("Arial",07,06,.T.,.F.,,,,,.F.) // Arial, Normal,  Tam. 06
    Private oFOARNO07	  		:= TFont():New("Arial",07,07,.T.,.F.,,,,,.F.) // Arial, Normal,  Tam. 07
    Private oFOARNO08	  		:= TFont():New("Arial",07,08,.T.,.F.,,,,,.F.) // Arial, Normal,  Tam. 08
    Private oFOARNO09	  		:= TFont():New("Arial",07,09,.T.,.F.,,,,,.F.) // Arial, Normal,  Tam. 08
    Private oFOARNO10	 		:= TFont():New("Arial",09,10,.T.,.F.,,,,,.F.) // Arial, Normal,  Tam. 15
    Private oFOARNO15	 		:= TFont():New("Arial",09,15,.T.,.F.,,,,,.F.) // Arial, Normal,  Tam. 15

    Private oFOARNE05	 		:= TFont():New("Arial",09,05,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 05
    Private oFOARNE06	 		:= TFont():New("Arial",09,06,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 06
    Private oFOARNE07	 		:= TFont():New("Arial",09,07,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 07
    Private oFOARNE08	 		:= TFont():New("Arial",09,08,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 08
    Private oFOARNE09	 		:= TFont():New("Arial",09,09,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 09
    Private oFOARNE10	 		:= TFont():New("Arial",09,10,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 10
    Private oFOARNE17	 		:= TFont():New("Arial",09,15,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 15
    Private oFOARNE20	 		:= TFont():New("Arial",09,20,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 20
    Private oFOARNE25	 		:= TFont():New("Arial",09,25,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 25
    Private oFOARNE30	 		:= TFont():New("Arial",09,30,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 30
    Private oFOARNE35	 		:= TFont():New("Arial",09,35,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 35
    Private oFOARNE40	 		:= TFont():New("Arial",09,40,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 40
    Private oFOARNE50	 		:= TFont():New("Arial",09,50,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 50
    Private oFOARNE70	 		:= TFont():New("Arial",09,70,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 70
    Private oFOARNE80	 		:= TFont():New("Arial",09,80,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 80

    Private oPrint
    Private aParamBox           := {}
    Private aRet                := {}
    //Private cLogo				:= AllTrim(GetMV("MV_XLOGOGV")) //Imagem dentro do SYSTEM
    
    Private cRelImp				:= ""
    default cPathPDF			:= fMakeDir("c:\relato\"+__CUSERID+"\")
    default cFileName			:= ""
    default lViewPdf			:= .T.
    default lGeraPdfServidor	:= .F.
    
    Private nRight 				:= 0
    Private nBottom	 			:= 0
    Private nRow 				:= 0
    Private nCol	 			:= 0
    Private nLinha              := 0
    //Private nLinTemp            := 0

    Private nIniLinha           := 0
    Private aTpCond             := {}
    Private aColunas            := {}
    Private aLinhas             := {}
    Private aColTmp             := {}
    
    Aadd( aParamBox ,{1,"Quantidade Cópias"     ,nValor     ,"@E 999" ,'positivo()',"",'.T.',80,.F.}) /*01*/
    Aadd( aParamBox ,{1,"Supplier Name"         ,LEFT("MARS GmbH"+SPACE(60),60)  ,"" ,'.T.',"",'.T.',80,.F.}) /*02*/
	Aadd( aParamBox ,{1,"Supplier Address (L1)" ,left("Eitzer Strasse 215"+Space(60),60)  ,"" ,'.T.',"",'.T.',80,.F.}) /*03*/
    Aadd( aParamBox ,{1,"Supplier Address (L2)" ,left("27283 Verden (Aller)/Germany"+Space(60),60)  ,"" ,'.T.',"",'.T.',80,.F.}) /*03*/
    Aadd( aParamBox ,{1,"MAT NR (241)"          ,Space(10)  ,"" ,'.T.',"",'.T.',80,.F.}) /*04*/
    Aadd( aParamBox ,{1,"VENDOR CODE (93)"      ,LEFT("15140808"+Space(10),10)  ,"" ,'.T.',"",'.T.',80,.F.}) /*05*/
    Aadd( aParamBox ,{1,"FEED MATERIAL"         ,LEFT("CATEGORY 3 UNFIT FOR HUMAN CONSUMPTION"+Space(60),60)  ,"" ,'.T.',"",'.T.',80,.F.}) /*06*/
    Aadd( aParamBox ,{1,"FEED ADDITIVES"        ,LEFT("Only for Manufacture of petfood"+Space(60),60)  ,"" ,'.T.',"",'.T.',80,.F.}) /*07*/
    Aadd( aParamBox ,{1,"PRODUCT DESCRIPTION"   ,left("Chicken liver frozen"+Space(60),60)  ,"" ,'.T.',"",'.T.',80,.F.}) /*08*/
    Aadd( aParamBox ,{1,"SSCC (00) (01)"        ,left("7897560"+Space(10),10)  ,"" ,'.T.',"",'.T.',80,.F.}) /*09*/
    Aadd( aParamBox ,{1,"SSCC (00) (02)"        ,left("9000000000"+Space(10),10)  ,"" ,'.T.',"",'.T.',80,.F.}) /*10*/
    Aadd( aParamBox ,{1,"SSCC (00) (03)"        ,"9"  ,"" ,'.T.',"",'.T.',80,.F.}) /*11*/
    Aadd( aParamBox ,{1,"BATCH/ LOT (10)"       ,Space(10)  ,"" ,'.T.',"",'.T.',80,.F.}) /*12*/
    Aadd( aParamBox ,{1,"PROD DATE (11)"        ,Space(08)  ,"99/99/99" ,'.T.',"",'.T.',80,.F.}) /*13*/
    Aadd( aParamBox ,{1,"BEST BEFORE (15)"      ,Space(08)  ,"99/99/99" ,'.T.',"",'.T.',80,.F.}) /*14*/
    Aadd( aParamBox ,{1,"ORDER NUMBER"          ,Space(10)  ,"" ,'.T.',"",'.T.',80,.F.}) /*15*/
    Aadd( aParamBox ,{1,"NET WEIGHT (KG) (3100)",nValor     ,"@E 9,999,999" ,'positivo()',"",'.T.',80,.F.}) /*16*/
    


    if ParamBox(aParamBox,"Parâmetros",@aRet)


        //cRelImp := __CUSERID+"_"+cNomRel+"_"+DtoS(dDatabase)+Replace(Time(),":","")
        cRelImp := __CUSERID+"_"+cNomRel
        
        if empty(cFileName) == .F.
            cRelImp := cFileName
        endIf

        // Instânciação do Objeto OPrint
        //oPrint := TMSPrinter():New()
        IF FErase( "c:\relato\"+__CUSERID+"\"+cRelImp+".pdf" ) == -1
        EndIf
        If FErase("\relato\"+__CUSERID+"\"+cRelImp+".pdf" ) == -1
        EndIf
        
        If lGeraPdfServidor
            oPrinter     := FWMSPrinter():New(cRelImp, 2,.F.,,.T.,.F.,,"PDF",.T., .T., .F.,.F.)
        Else
            oPrinter := FWMsPrinter():New(cRelImp,6, lAdjustToLegacy,fMakeDir("c:\relato\"+__CUSERID+"\"), lDisableSetup)
        EndIf

        //oPrinter:SetLandscape()
        oPrinter:setPortrait()
        oPrinter:setPaperSize(DMPAPER_A4)
        oPrinter:cPathPDF 	 := cPathPDF
        oPrinter:lViewPDF	 := lViewPdf

        //oPrinter:SetMargin(50,50,50,50)                                                     
        oPrinter:lServer := .T.
        //oPrinter:Setup()
        
        //nRow := 32
        nRow := 05+010
        nCol := 23

        nRight  := oPrinter:nHorzSize()-010
        nBottom := oPrinter:nVertSize()-060

        //fGetQuery()

        //TRB->(dbgotop()) 

        nQuantReg   := MV_PAR01
        
        for nA := 1 TO nQuantReg
                
                fImpCabec()

        next nA
        
        // INCLUÍDA TRATATIVA PARA GERAR VIA JOB
        if lGeraPdfServidor
            File2Printer(cPathPDF + cFileName, "PDF" )
        endIf
        
        oPrinter:EndPage()
        If !lGeraPdfServidor
            oPrinter:Preview()
        Else
            oPrinter:Print()
        EndIf
        FreeObj(oPrinter)
        oPrinter := Nil 

    else
        msginfo("Operação cancelada pelo operador!")
    endif

    IF FErase( "c:\relato\"+__CUSERID+"\"+cRelImp+".rel" ) == -1
    EndIf
    IF FErase("\relato\"+__CUSERID+"\"+cRelImp+".rel" ) == -1
    EndIf
    IF FErase( "\SPOOL\"+cRelImp+".rel" ) == -1
    EndIf

Return

Static Function fImpCabec()
    
   Local aPerc      := {}
   Local cVarImp    := ""
   Local nVarImp    := 0
   Local nN         := 0

    if !oPrinter:isFirstPage
        oPrinter:endpage()
    endif
    oPrinter:StartPage() 
    
    
    //oPrinter:Box(nRow, nCol, nBottom, nRight)

    nLinha  := nRow
    nAltura := 42
    
    //------------------------------------------
    // Sessão 00 - Supplier Name address
    //------------------------------------------
    
    aPerc   := {nCol, ROUND(nRight*0.4,0), nRight}
    oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[02])
    oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])
    oPrinter:Say( nLinha+013, aPerc[01]+008 , "Supplier Name", oFOARNE17)
    oPrinter:Say( nLinha+026, aPerc[01]+009 , "Address", oFOARNE17)
    
    cVarImp := Alltrim(MV_PAR02)
    oPrinter:Say( nLinha+015, aPerc[02]+015 , cVarImp, oFOARNE17)
    
    // fQuebra(cString, nLineLen, nTabSize, lWrap)
    cVarImp := Alltrim(MV_PAR03)
    oPrinter:Say(nLinha+28, aPerc[02]+015 , cVarImp , oFOARNO15)
    cVarImp := Alltrim(MV_PAR04)
    oPrinter:Say(nLinha+39, aPerc[02]+015 , cVarImp , oFOARNO15)
    nLinha += nAltura
    nAltura := 47
    
    aPerc   := {nCol, ROUND(nRight*0.7,0), nRight}

    oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[02])
    oPrinter:Say(nLinha+13, aPerc[01]+008 , "MAT NR (241)", oFOARNE17)
    cVarImp := Alltrim(MV_PAR05)
    oPrinter:Say(nLinha+46, aPerc[01]+130 , cVarImp, oFOARNE80)
    
    oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])
    oPrinter:Say(nLinha+13, aPerc[02]+008 , "VENDOR CODE (93)", oFOARNE17)
    cVarImp := Alltrim(MV_PAR06)
    oPrinter:Say(nLinha+38, aPerc[02]+010 , cVarImp, oFOARNE30)

    nLinha += nAltura
    nAltura := 56

    aPerc   := {nCol, ROUND(nRight*0.4,0), nRight}

    oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[02])
    oPrinter:Say(nLinha+13, aPerc[01]+010 , "FEED MATERIAL"         , oFOARNE17)
    oPrinter:Say(nLinha+26, aPerc[01]+010 , "FEED ADDITIVES"        , oFOARNE17)
    oPrinter:Say(nLinha+45, aPerc[01]+010 , "PRODUCT DESCRIPTION"   , oFOARNE17)
    
    oPrinter:Box(nLinha, aPerc[02], nLinha+30, aPerc[03])
    oPrinter:Box(nLinha+30, aPerc[02], nLinha+nAltura, aPerc[03])
    cVarImp := Alltrim(MV_PAR07)
    oPrinter:Say(nLinha+13, aPerc[02]+010 , cVarImp, oFOARNE17)
    cVarImp := Alltrim(MV_PAR08)
    oPrinter:Say(nLinha+26, aPerc[02]+010 , cVarImp, oFOARNE17)
    cVarImp := Alltrim(MV_PAR09)
    oPrinter:Say(nLinha+53, aPerc[02]+010 , cVarImp, oFOARNE35)
    
    nLinha += nAltura
    nAltura := 47

    aPerc   := {nCol, ROUND(nRight*0.25,0), ROUND(nRight*0.90,0), nRight}

    oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[04])
    oPrinter:Say(nLinha+13, aPerc[01]+010 , "SSCC (00)"         , oFOARNE17)
    
    cVarImp := Alltrim(MV_PAR10)
    oPrinter:Say(nLinha+45, aPerc[01]+010 , cVarImp, oFOARNE20)
    
    cVarImp := Alltrim(MV_PAR11)
    oPrinter:Say(nLinha+45, aPerc[02]+010 , cVarImp, oFOARNE80)
    
    cVarImp := Alltrim(MV_PAR12)
    oPrinter:Say(nLinha+45, aPerc[03]+010 , cVarImp, oFOARNE20)
    
    nLinha += nAltura
    nAltura := 42

    aPerc   := {nCol, ROUND(nRight*0.4,0),  ROUND(nRight*0.7,0), nRight}

    oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[02])
    oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])

    oPrinter:Say(nLinha+13, aPerc[01]+010 , "BEST BEFORE (15)"          , oFOARNE17)
    cVarImp := Alltrim(MV_PAR15)
    oPrinter:Say(nLinha+36, aPerc[01]+020 , cVarImp, oFOARNE30)
    
    oPrinter:Say(nLinha+16, aPerc[02]+010 , "PROD DATE (11)"            , oFOARNE17)
    cVarImp := Alltrim(MV_PAR14)
    oPrinter:Say(nLinha+36, aPerc[02]+020 , cVarImp, oFOARNE30)
    
    oPrinter:Box(nLinha, aPerc[03], nLinha+(nAltura*2), aPerc[04])
    oPrinter:Say(nLinha+13, aPerc[03]+010 , "NET WEIGHT (KG) (3100)"    , oFOARNE17)
    cVarImp := Alltrim(TRANSFORM(MV_PAR17, "@E 999999"))
    nTamFont := GetStringPixSize( cVarImp, "Arial", 80, .T., .F., .F. )[02]/2
    nPosStr  := ((aPerc[04]-aPerc[03])/2-nTamFont)+058
    oPrinter:Say(nLinha+68, aPerc[03]+nPosStr , cVarImp, oFOARNE80)
    
    nLinha += nAltura
    nAltura := 42    
    
    oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[02])
    oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])
    
    oPrinter:Say(nLinha+13, aPerc[01]+010 , "BATCH/LOT (10)"          , oFOARNE17)
    cVarImp := Alltrim(MV_PAR13)
    oPrinter:Say(nLinha+36, aPerc[01]+050 , cVarImp, oFOARNE30)
    
    oPrinter:Say(nLinha+13, aPerc[02]+010 , "ORDER NUMBBER"           , oFOARNE17)
    cVarImp := Alltrim(MV_PAR16)
    oPrinter:Say(nLinha+36, aPerc[02]+010 , cVarImp, oFOARNE30)

    nLinha += nAltura
    nAltura := 407      
    aPerc   := {nCol, nRight}

    oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, nRight)
    
    cVarImp := "(241)"+Alltrim(MV_PAR05)+"(93)"+Alltrim(MV_PAR06)+"(10)"+Alltrim(MV_PAR13)
    oPrinter:Code128(nLinha+010 , aPerc[01]+(nRight-nCol)*0.06,cVarImp/*cCode*/,(nRight-nCol)*0.88 /*nWidth*/,100 /*nHeigth*/,.F./*lSay*/,oFOARNO08 ,(nRight-nCol)*0.88)
    
    aTamFont    := GetStringPixSize( cVarImp, "Arial", 15, .F., .F., .F. )
    oPrinter:Say(nLinha+100+aTamFont[1], (nRight*0.5)-aTamFont[2]/4 , cVarImp, oFOARNO15)

    cVarImp := "(15)"+Alltrim(replace(MV_PAR15,"/",""))+"(11)"+Alltrim(replace(MV_PAR14,"/",""))+"(3100)"+Alltrim(TRANSFORM(MV_PAR17, "@E 999999"))
    oPrinter:Code128(nLinha+150 , aPerc[01]+(nRight-nCol)*0.06,cVarImp/*cCode*/,(nRight-nCol)*0.88 /*nWidth*/,100 /*nHeigth*/,.F./*lSay*/,oFOARNO08,(nRight-nCol)*0.88)
    
    aTamFont    := GetStringPixSize( cVarImp, "Arial", 15, .F., .F., .F. )
    oPrinter:Say(nLinha+240+aTamFont[1], (nRight*0.5)-aTamFont[2]/4 , cVarImp, oFOARNO15)
    
    cVarImp := "(00)"+Alltrim(MV_PAR10)+Alltrim(MV_PAR11)+Alltrim(MV_PAR12)
    oPrinter:Code128(nLinha+290 , aPerc[01]+(nRight-nCol)*0.06,cVarImp/*cCode*/,(nRight-nCol)*0.88 /*nWidth*/,100 /*nHeigth*/,.F./*lSay*/,oFOARNO08,(nRight-nCol)*0.88)
    
    aTamFont    := GetStringPixSize( cVarImp, "Arial", 15, .F., .F., .F. )
    oPrinter:Say(nLinha+380+aTamFont[1], (nRight*0.5)-aTamFont[2]/4 , cVarImp, oFOARNO15)

Return

Static Function fQuebra(cString, nLineLen, nTabSize, lWrap)
    Local aRet          := {}
    Local i             := 0
    Default cString     := ""
    Default nLineLen    := 30
    Default nTabSize    := 2
    Default lWrap       := .T.

    if !Empty(cString)
        nQtdLin := mlcount(cString,nLineLen, nTabSize, lWrap)
        aRet := Array(nQtdLin)

        For i := 1 to nQtdLin
            cLin := alltrim(memoline(cString,nLineLen,i, nTabSize, lWrap))
            aRet[i] := cLin
        Next i

    endif

Return aRet

Static Function fMakeDir(cDirServer)
	Local cFolder	:= ""
	Local nA		:= 0
	cDirServer 		:= Alltrim(cDirServer)

    If !lIsDir(cDirServer)
        If ":"$cDirServer
            MakeDir(cDirServer)
        Else
            aFolders	:= Separa(cDirServer,"\",.F.)
            For Na := 1 TO Len(aFolders)
                cFolder		+= "\"+aFolders[nA]
                MakeDir(cFolder)
            Next nA
        EndIf
    EndIf

Return cDirServer
