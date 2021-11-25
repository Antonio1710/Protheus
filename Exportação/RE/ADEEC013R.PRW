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
    @version 02
    @history Ticket: 62189 - 19/10/2021 - ADRIANO SAVOINE - Gerada a calculadora de digito GS1 apartir dos requisitos disponiveis no site da GS1 e gerado o sequencial do Palete na SX5 para não repetir mais os dados.
    @history Ticket: 63577 - 25/11/2021 - ADRIANO SAVOINE - Ajustado a etiqueta para o novo Modelo da MARS.
    
/*/
#Define IMP_SPOOL  2
#Define IMP_PDF    1
#Define DMPAPER_A5 11

User Function ADEEC013R() // U_ADEEC013R()

    Local titulo   				:= "Ordem de Carregamento Exportação"
    Local cPerg					:= "ADEEC013R"
    Local cNomRel				:= "ADEEC013R"
    Local nA                    := 0
    Local nValor                := 0
    Local nVal                  := 0
    Local cCodx5                := ALLTRIM(Posicione("SX5",1,xFilial("SX5")+ 'EX',"X5_CHAVE"))
    LOCAL aAreaAnt              := GETAREA()

    Local lAdjustToLegacy 		:= .F. 
    Local lDisableSetup  		:= .T.
    
    
    Private nPalete             := CValToChar(val('9000' + cCodx5)+1)
    Private cPrefixo            := '07897560'
    Private cCodigo             := cPrefixo + nPalete
    Private nDig                := u_Diggs1(cCodigo)

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
    Private oFOARNE17	 		:= TFont():New("Arial",09,15,.T.,.F.,,,,,.F.) // Arial, Normal,  Tam. 15
    Private oFOARNE20	 		:= TFont():New("Arial",09,20,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 20
    Private oFOARNE25	 		:= TFont():New("Arial",09,25,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 25
    Private oFOARNE30	 		:= TFont():New("Arial",09,30,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 30
    Private oFOARNE35	 		:= TFont():New("Arial",09,35,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 35
    Private oFOARNE40	 		:= TFont():New("Arial",09,40,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 40
    Private oFOARNE55	 		:= TFont():New("Arial",09,55,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 50
    Private oFOARNE58	 		:= TFont():New("Arial",09,58,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 60
    Private oFOARNE70	 		:= TFont():New("Arial",09,70,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 70
    Private oFOARNE80	 		:= TFont():New("Arial",09,80,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 80

    Private oPrint
    Private aParamBox           := {}
    Private aRet                := {}    
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
    Private nIniLinha           := 0
    Private aTpCond             := {}
    Private aColunas            := {}
    Private aLinhas             := {}
    Private aColTmp             := {}
    
    Aadd( aParamBox ,{1,"Quantidade Cópias"       ,nVal     ,"@E 999" ,'positivo()',"",'.T.',80,.F.}) /*01*/
    Aadd( aParamBox ,{1,"Material Description"    ,LEFT("MARS GmbH"+SPACE(17),17)  ,"" ,'.T.',"",'.T.',80,.F.}) /*02*/
    Aadd( aParamBox ,{1,"GRD8 (240)"              ,Space(10)  ,"" ,'.T.',"",'.T.',80,.F.}) /*03*/
    Aadd( aParamBox ,{1,"VENDOR CODE (91)"        ,LEFT("15140808"+Space(10),10)  ,"" ,'.T.',"",'.T.',80,.F.}) /*04*/
    //Aadd( aParamBox ,{1,"SSCC (00) (01)"          ,'07897560' ,"" ,'.T.',"",'.T.',80,.F.}) /*05*/
    //Aadd( aParamBox ,{1,"SSCC (00) (02)"          ,VAL(nPalete) ,"" ,'.T.',"",'.T.',80,.F.}) /*06*/
    //Aadd( aParamBox ,{1,"SSCC (00) (03)"          ,CVALTOCHAR(nDig) ,"" ,'.T.',"",'.T.',80,.F.}) /*07*/
    Aadd( aParamBox ,{1,"Mars Batch (90)"         ,Space(10)  ,"" ,'.T.',"",'.T.',80,.F.}) /*08*/
    Aadd( aParamBox ,{1,"Manuf. Date (11)"        ,Space(08)  ,"99.99.99" ,'.T.',"",'.T.',80,.F.}) /*09*/
    Aadd( aParamBox ,{1,"Expiry Date (15)"        ,Space(08)  ,"99.99.99" ,'.T.',"",'.T.',80,.F.}) /*10*/
    Aadd( aParamBox ,{1,"Vendor Batch/ Lot (10)"  ,Space(10)  ,"" ,'.T.',"",'.T.',80,.F.}) /*11*/
    Aadd( aParamBox ,{1,"Quantity (37)"           ,nValor     ,"@E 9999" ,'positivo()',"",'.T.',80,.F.}) /*12*/


    if ParamBox(aParamBox,"Parâmetros",@aRet)

        
       
        cRelImp := __CUSERID+"_"+cNomRel
        
        if empty(cFileName) == .F.
            cRelImp := cFileName
        endIf

      
        IF FErase( "c:\relato\"+__CUSERID+"\"+cRelImp+".pdf" ) == -1
        EndIf
        If FErase("\relato\"+__CUSERID+"\"+cRelImp+".pdf" ) == -1
        EndIf
        
        If lGeraPdfServidor
            oPrinter     := FWMSPrinter():New(cRelImp, 2,.F.,,.T.,.F.,,"PDF",.T., .T., .F.,.F.)
        Else
            oPrinter := FWMsPrinter():New(cRelImp,6, lAdjustToLegacy,fMakeDir("c:\relato\"+__CUSERID+"\"), lDisableSetup)
        EndIf

        
        oPrinter:setPortrait()
        oPrinter:setPaperSize(DMPAPER_A5)
        oPrinter:cPathPDF 	 := cPathPDF
        oPrinter:lViewPDF	 := lViewPdf

                                                            
        oPrinter:lServer := .T.
       
        
        //nRow := 32
        nRow := 05+010
        nCol := 23

        nRight  := oPrinter:nHorzSize()-160  /// LARGURA 148 MM nRight  := oPrinter:nHorzSize()-160
        nBottom := oPrinter:nVertSize()-200  /// ALTURA 210 MM  nBottom := oPrinter:nVertSize()-200

        //fGetQuery()

        //TRB->(dbgotop()) 

        nQuantReg   := MV_PAR01

        DbSelectArea('SX5')
        SX5->(DbSetOrder(1)) 
        
        for nA := 1 TO nQuantReg

            IF nA = 1
                fImpCabec()

                cNovo := substr(cValToChar(nPalete),5,5)
               
                dbSeek(xFilial("SX5")+"EX")
                SX5->( RecLock( "SX5" , .F. ) )		
                SX5->X5_CHAVE  := cNovo
                SX5->(MsUnlock())


            ELSE
                nPalete := nPalete + 1
                cNovo := substr(cValToChar(nPalete),5,5)
                
                dbSeek(xFilial("SX5")+"EX")
                SX5->( RecLock( "SX5" , .F. ) )		
                SX5->X5_CHAVE  := cNovo
                SX5->(MsUnlock())


                cCodigo  := '07897560' + cValToChar(MV_PAR06)
                nDig := u_Diggs1(cCodigo)                

                fImpCabec()

                MV_PAR06 := VAL(MV_PAR06)

            ENDIF
           


        next nA

        RESTAREA(aAreaAnt)
        
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
    nAltura := 50
    
    //------------------------------------------
    // Sessão 00 - Supplier Name address
    //------------------------------------------
    
     aPerc   := {nCol, ROUND(nRight*0.25,0), ROUND(nRight*0.90,0), nRight}
     oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[04])
     oPrinter:Say( nLinha+013, aPerc[01]+008  , "Material description", oFOARNE17)
  
    
    cVarImp := Alltrim(MV_PAR02)
    oPrinter:Say( nLinha+048, aPerc[01]+005 , cVarImp, oFOARNE58)
    
    
    nLinha += nAltura
    nAltura := 40
    
    aPerc   := {nCol, ROUND(nRight*0.5,0), nRight}

    oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[02])
    oPrinter:Say(nLinha+13, aPerc[01]+008 , "GRD8 (240)", oFOARNE17)
    cVarImp := Alltrim(MV_PAR03)
    oPrinter:Say(nLinha+38, aPerc[01]+070 , cVarImp, oFOARNE30)
    
    oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])
    oPrinter:Say(nLinha+13, aPerc[02]+008 , "VENDOR (91)", oFOARNE17)
    cVarImp := Alltrim(MV_PAR04)
    oPrinter:Say(nLinha+38, aPerc[02]+080 , cVarImp, oFOARNE30)

    nLinha += nAltura
    nAltura := 49

    aPerc   := {nCol, ROUND(nRight*0.4,9),  ROUND(nRight*0.6,5), nRight}

    oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[02])
    oPrinter:Say(nLinha+13, aPerc[01]+010 , "Mars batch (90)"          , oFOARNE17)
    cVarImp := Alltrim(MV_PAR05)
    oPrinter:Say(nLinha+40, aPerc[01]+010 , cVarImp, oFOARNE30)
    
    oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])
    oPrinter:Say(nLinha+13, aPerc[02]+005 , "Quantity (37)"            , oFOARNE17)
    cVarImp := Alltrim(CVALTOCHAR(MV_PAR09))
    oPrinter:Say(nLinha+48, aPerc[02] , cVarImp, oFOARNE55)
    
    oPrinter:Box(nLinha, aPerc[03], nLinha+nAltura, aPerc[04])
    oPrinter:Say(nLinha+13, aPerc[03]+010 , "Manuf. date (11) DD.MM.YY"    , oFOARNE17)
    cVarImp := Alltrim(MV_PAR06)
    oPrinter:Say(nLinha+40, aPerc[03]+020 , cVarImp, oFOARNE30)
    
    nLinha += nAltura
    nAltura := 47

    aPerc   := {nCol, ROUND(nRight*0.4,9),  ROUND(nRight*0.6,5), nRight}

    oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[02])
    oPrinter:Box(nLinha, aPerc[02], nLinha+nAltura, aPerc[03])

    oPrinter:Say(nLinha+13, aPerc[01]+010 , "Vendor Batch / Lot (10)"          , oFOARNE17)
    cVarImp := Alltrim(MV_PAR08)
    oPrinter:Say(nLinha+40, aPerc[01]+020 , cVarImp, oFOARNE30)
    
    oPrinter:Say(nLinha+13, aPerc[02]+010 , "UOM"            , oFOARNE17)
    cVarImp := Alltrim("KG")
    oPrinter:Say(nLinha+40, aPerc[02]+020 , cVarImp, oFOARNE30)
    
    oPrinter:Box(nLinha, aPerc[03], nLinha+nAltura, aPerc[04])
    oPrinter:Say(nLinha+13, aPerc[03]+010 , "Expiry date (15) DD.MM.YY"    , oFOARNE17)
    cVarImp := Alltrim(MV_PAR07)
    oPrinter:Say(nLinha+40, aPerc[03]+020 , cVarImp, oFOARNE30)
    
    nLinha += nAltura
    nAltura := 50
    aPerc   := {nCol, ROUND(nRight*0.15,0), ROUND(nRight*0.90,0), nRight}

    oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, aPerc[04])
    oPrinter:Say(nLinha+13, aPerc[01]+010 , "SSCC (00)"         , oFOARNE17)
   
    cVarImp := cValtoChar(PadL(cPrefixo,8,'0'))+cValtoChar(nPalete)+cValtoChar(nDig)
    oPrinter:Say(nLinha+48, aPerc[01] , cVarImp, oFOARNE58)
    
    nLinha += nAltura
    nAltura := 407      
    aPerc   := {nCol, nRight}

    oPrinter:Box(nLinha, aPerc[01], nLinha+nAltura, nRight)
    
    cVarImp  := "(11)"+Alltrim(MV_PAR06)+"(15)"+Alltrim(MV_PAR07)+"(37)"+Alltrim(CVALTOCHAR(MV_PAR09))
    cVarImp1 := SUBSTR(cVarImp,2,2)+SUBSTR(cVarImp,11,02)+SUBSTR(cVarImp,08,02)+SUBSTR(cVarImp,05,02)+SUBSTR(cVarImp,14,02)+SUBSTR(cVarImp,23,02)+SUBSTR(cVarImp,20,02)+SUBSTR(cVarImp,17,02)+SUBSTR(cVarImp,26,02)+SUBSTR(cVarImp,29,04)
    cVarImp2 := "(11)"+SUBSTR(cVarImp,11,02)+SUBSTR(cVarImp,08,02)+SUBSTR(cVarImp,05,02)+"(15)"+SUBSTR(cVarImp,23,02)+SUBSTR(cVarImp,20,02)+SUBSTR(cVarImp,17,02)+"(37)"+SUBSTR(cVarImp,29,04)
    oPrinter:Code128(nLinha+010 , aPerc[01]+(nRight-nCol)*0.06,cVarImp1/*cCode*/,(nRight-nCol)*0.88 /*nWidth*/,100 /*nHeigth*/,.F./*lSay*/,oFOARNO08 ,(nRight-nCol)*0.88)
    
    aTamFont    := GetStringPixSize( cVarImp2, "Arial", 15, .F., .F., .F. )
    oPrinter:Say(nLinha+100+aTamFont[1], (nRight*0.5)-aTamFont[2]/4 , cVarImp2, oFOARNO15)

    cVarImp  := "(91)"+Alltrim(MV_PAR04)+"(90)"+Alltrim(MV_PAR05)+"(10)"+Alltrim(MV_PAR08)
    cVarImp1 := strtran(cVarImp,"(")
    cVarImp2 := strtran(cVarImp1,")") 
    oPrinter:Code128(nLinha+150 , aPerc[01]+(nRight-nCol)*0.06,cVarImp2/*cCode*/,(nRight-nCol)*0.88 /*nWidth*/,100 /*nHeigth*/,.F./*lSay*/,oFOARNO08,(nRight-nCol)*0.88)
    
    aTamFont    := GetStringPixSize( cVarImp, "Arial", 15, .F., .F., .F. )
    oPrinter:Say(nLinha+240+aTamFont[1], (nRight*0.5)-aTamFont[2]/4 , cVarImp, oFOARNO15)
    
    cVarImp := "(00)"+cValtoChar(PadL(cPrefixo,8,'0'))+cValtoChar(nPalete)+cValtoChar(nDig)+"(240)"+Alltrim(MV_PAR03)
    cVarImp1 := strtran(cVarImp,"(")
    cVarImp2 := strtran(cVarImp1,")") 
    oPrinter:Code128(nLinha+290 , aPerc[01]+(nRight-nCol)*0.06,cVarImp2/*cCode*/,(nRight-nCol)*0.88 /*nWidth*/,100 /*nHeigth*/,.F./*lSay*/,oFOARNO08,(nRight-nCol)*0.88)
    
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

/*/{Protheus.doc} User Function Diggs1
    (Função para gerar calculo do digito igual ao site da GS1)
    @type  Function
    @author ADRIANO SAVOINE
    @since 19/10/2021
    @version 01
    /*/

User Function Diggs1(cCodigo)
    Local  aArea       := GetArea()
    Local  nTotal      := 0
    Local  nAtual      := 0
    Local  nt1         := 0
    Local  nPar        := 0
    Local  nt2         := 0
    Local  nImp        := 0
    Local  nSoma       := 0
    Local  nDif        := 0
    Local  nMax        := 0
    Public nDig        := 0 
     
     
    //Percorre todos os Numeros
    For nAtual := 1 To Len(cCodigo)

        If mod(nAtual,2) == 0
            nPar := Val(SubStr(cCodigo, nAtual, 1)) * 1
            nt1 := nt1 + nPar
            nTotal++
        Else 
            nImp := Val(SubStr(cCodigo, nAtual, 1)) * 3
            nt2 := nt2 + nImp
            nTotal++

        EndIf

    Next

    nSoma := nt1 + nt2
    nDif  := 10 - Val(SubStr(cValToChar(nSoma), Len(cValToChar(nSoma)), 1)) 
    nMax  := nSoma + nDif

    IF (nMax - nSoma) == 10
        nDig  := 0
        ELSE
        nDig  := nMax - nSoma
    ENDIF

    RestArea(aArea)
Return nDig
