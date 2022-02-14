#Include "protheus.ch"
#Include "TopConn.ch"
#include "colors.ch"
#Include "Font.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} User Function ADEST066R U_ADEST066R()
    Relatório de condenações por turno e granja.
    Chamado 8703
    @type  Function
    @author Leonardo P. Monteiro
    @since 12/05/2021
    @version 01
    @history Chamado 8703 - Leonardo P. Monteiro - 14/05/2021 - Impressão de todos valores por granja indepente da digitação ou não.
    @history Chamado 14613 - Leonardo P. Monteiro - 27/05/2021 - Implementações de melhorias no processo de apontamento de condenações como rateio por turno.
    @history Chamado 14613 - Leonardo P. Monteiro - 01/06/2021 - Correções na quantidade acumulada por granja.
/*/
#Define IMP_SPOOL  2
#Define IMP_PDF    1
#Define DMPAPER_A4 9

User Function ADEST066R()

    Local titulo   				:= "Formulário SIF/AMPM 04"
    Local cPerg					:= "ADEST066R"
    Local cNomRel				:= "ADEST066R"

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
    Private oFOARNE15	 		:= TFont():New("Arial",09,15,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 15
    Private oFOARNE20	 		:= TFont():New("Arial",09,20,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 20
    Private oFOARNE25	 		:= TFont():New("Arial",09,25,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 25
    Private oFOARNE30	 		:= TFont():New("Arial",09,30,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 30
    Private oFOARNE35	 		:= TFont():New("Arial",09,35,.T.,.T.,,,,,.F.) // Arial, Negrito, Tam. 35
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

    Private nBlocoA             := 0
    Private nBlocoB             := 0
    Private nBlocoC             := 0
    Private aTpCond             := {}
    Private aColunas            := {}
    Private aLinhas             := {}

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatório de condenações por turno e granja')


    Aadd( aParamBox ,{1,"Dt Referência" ,dDatabase  ,"" ,'.T.',"",'.T.',80,.F.})
	
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
        nRow := 05
        nCol := 23

        nRight  := oPrinter:nHorzSize()-010
        nBottom := oPrinter:nVertSize()-060

        nBlocoA := nRow+(nBottom-nRow)*0.03
        nBlocoB := nRow+(nBottom-nRow)*0.20
        nBlocoC := nRow+(nBottom-nRow)*0.90

        aTpCond := fGetCond()

        fGetQuery()

        TRB->(dbgotop()) 

        nQuantReg   := 1
        dDtAtu      := Stod("")
        nTuAtu      := 9 

        If TRB->(!EOF())
        
            While TRB->(!Eof())
                
                if nQuantReg > 9 .OR. (dDtAtu != TRB->ZV1_DTABAT .OR. nTuAtu != TRB->ZV1_TURNO)
                    if !oPrinter:isFirstPage
                        oPrinter:endpage()
                        nQuantReg   := 1
                    endif
                    
                    fImpCabec()
                endif
                
                fImpitens()
                
                dDtAtu  := TRB->ZV1_DTABAT
                nTuAtu  := TRB->ZV1_TURNO
                nQuantReg += 1

                TRB->(DbSkip())
            EndDo
            
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
        EndIF
    else
        msginfo("Operação cancelada pelo operador!")
    endif

    TRB->(DbCloseArea())

    IF FErase( "c:\relato\"+__CUSERID+"\"+cRelImp+".rel" ) == -1
    EndIf
    IF FErase("\relato\"+__CUSERID+"\"+cRelImp+".rel" ) == -1
    EndIf
    IF FErase( "\SPOOL\"+cRelImp+".rel" ) == -1
    EndIf

Return

Static Function fImpCabec()
    
    /*
    nPixelX := oPrinter:nLogPixelX()
    nPixelY := oPrinter:nLogPixelY()

    nVertSize := oPrinter:nVertSize()
    nHorzSize := oPrinter:nHorzSize()
    */

    oPrinter:StartPage() 
    
    nLinha := nRow

    //oPrinter:Say( nLinha, (nRight-nCol)/2-07 , "ANEXO IV", oFOARNO09)
    //oPrinter:nPagecount
    //nLinha += 07
    oPrinter:SayBitmap(nLinha, (nRight-nCol)/2-18,"\imagens\Logo governo.png",56,59)
    nLinha += 80
    oPrinter:Say( nLinha, (nRight-nCol)/2-100 , "MINISTÉRIO DA AGRICULTURA, PECUÁRIA E ABASTECIMENTO – MAPA", oFOARNO09)
    nLinha += 07
    oPrinter:Say( nLinha, (nRight-nCol)/2-110 , "DEPARTAMENTO DE INSPEÇÃO DE PRODUTOS DE ORIGEM ANIMAL – DIPOA", oFOARNO09)
    nLinha += 07
    oPrinter:Say( nLinha, (nRight-nCol)/2-105 , "SERVIÇO DE INSPEÇÃO DE PRODUTOS DE ORIGEM ANIMAL – 6º SIPOA", oFOARNO09)
    nLinha += 07
    oPrinter:Say( nLinha, (nRight-nCol)/2-60 , "SERVIÇO DE INSPEÇÃO FEDERAL Nº 414 ", oFOARNO09)
    nLinha += 07
    oPrinter:Say( nLinha, (nRight-nCol)/2-70 , "COMPILAÇÃO DAS CONDENAÇÕES POR LOTE", oFOARNO09)
    nLinha += 07
    oPrinter:Say( nLinha, (nRight-nCol)/2-35 , '"Formulário SIF/ AMPM 04"', oFOARNO09)
    nLinha += 25

    if trb->ZV1_TURNO == 1
        cTurno := "1º Turno"
    elseif trb->ZV1_TURNO == 2
        cTurno := "2º Turno"
    else
        cTurno := ""
    endif
    oPrinter:Say( nLinha, (nRight-nCol)/3+225 , "Data e Turno de abate: " + Dtoc(trb->ZV1_DTABAT) +" "+cTurno , oFOARNO09)

    nReducao    := (nRight-nCol)*0.05/2

    nColTab     := nCol+nReducao-010
    nRightTab   := nRight-nReducao
    
    //oPrinter:Say(nPosHorz+nLinha, nPosVert+nColuna,"Pedido de Venda.:"				,oFOARNE10)
    //oPrinter:Box(nRow, nCol, nBottom, nRight)
    oPrinter:Box(nBlocoB, nColTab, nBlocoC, nRightTab)
    
    nColCab1    := (nRightTab-nColTab)*0.30/2
    nColCab2    := (nRightTab-nColTab)*0.06
    nColCab3    := (nRightTab-nColTab)*0.64/20
    nColuna     := nColTab

    nColRef1    := 0
    nColRef2    := 0
    nColRef3    := 0
    nColGrd     := 0
    aColunas    := {}

    for nA := 1 To 23
        
        AADD(aColunas, nColuna)

        if nA == 1
            nColRef1 := nColuna
            nColuna += nColCab1
            oPrinter:Line(nBlocoB, nColuna, nBlocoC, nColuna,,"-1")
            
        Elseif nA == 3
            nColRef3 := nColuna
            nColuna += nColCab1
            oPrinter:Line(nBlocoB, nColuna, nBlocoC, nColuna,,"-1")
            
        elseif nA == 2
            nColRef2 := nColuna
            nColuna += nColCab2
            oPrinter:Line(nBlocoB, nColuna, nBlocoC, nColuna,,"-1")
        else
            if nColGrd == 0
                nColGrd := nColuna
            endif

            nColuna += nColCab3 
            oPrinter:Line(nBlocoB, nColuna, nBlocoC, nColuna,,"-1")
        endif

    next nA


    nSizCab := (nBlocoC-nBlocoB)*0.30
    nSizBod := (nBlocoC-nBlocoB-nSizCab)/9

    nLinha  := nBlocoB
    aLinhas := {}

    for na := 1 To 10
        if nA == 1
            
            
            nLinha += nSizCab
            
            oPrinter:Line(nLinha, nColTab, nLinha, nRightTab,,"-1")

            oPrinter:Say( nLinha-nSizCab/2      , nColRef1+4  , "Identificação do Núcleo", oFOARNO09)
            oPrinter:Say( nLinha-nSizCab/2+08   , nColRef1+4  , "     (lote para abate) ", oFOARNO09)
            oPrinter:Say( nLinha-50             , nColRef2+17 , "Total de aves abatidas", oFOARNO09,,,270)
            oPrinter:Say( nLinha-nSizCab/2      , nColRef3+2  , "Total por causas/destino", oFOARNO09)
            
            for nB := 1 to Len(aTpCond)
                if nB <= 20
                    cCond := Alltrim(aTpCond[nB][02])
                    nCond := Len(cCond)
                    if nCond > 30
                        oPrinter:Say( nLinha-04, nColGrd+(nColCab3*(nB-1))+07 , left(cCond,30), oFOARNO09,,, 270)
                        oPrinter:Say( nLinha-04, nColGrd+(nColCab3*(nB-1))+15 , substr(cCond,31, nCond), oFOARNO09,,, 270)
                    else
                        oPrinter:Say( nLinha-04, nColGrd+(nColCab3*(nB-1))+10 , cCond, oFOARNO09,,, 270)
                    endif
                endif
            next nB
        else
            nLinha  += nSizBod
            nSubLin := nSizBod/3

            oPrinter:Line(nLinha, nColTab, nLinha, nRightTab,,"-1")
            oPrinter:Line(nLinha-nSubLin*1, nColRef3, nLinha-nSubLin*1, nRightTab,,"-1")
            oPrinter:Line(nLinha-nSubLin*2, nColRef3, nLinha-nSubLin*2, nRightTab,,"-1")

            AADD(aLinhas,{nLinha-nSizBod, {nLinha-nSizBod, nLinha-nSubLin*2, nLinha-nSubLin*1} })

            oPrinter:Say( nLinha-nSizBod+09     , aColunas[03]+2  , "Condenação total", oFOARNO07)
            oPrinter:Say( nLinha-nSubLin*2+09    , aColunas[03]+2  , "Condenação parcial", oFOARNO07)
            oPrinter:Say( nLinha-nSubLin*1+09    , aColunas[03]+2  , "Aproveitamento condicional", oFOARNO07)

            oBrush := TBrush():New2( , CLR_BLACK )
            //Linha 01
            nLinIni := nLinha-nSizBod
            nLinFin := nLinha-nSubLin*2
            oPrinter:fillRect( { nLinIni, aColunas[06], nLinFin, aColunas[07] }, oBrush )
            oPrinter:fillRect( { nLinIni, aColunas[09], nLinFin, aColunas[10] }, oBrush )
            oPrinter:fillRect( { nLinIni, aColunas[17], nLinFin, aColunas[18] }, oBrush )
            oPrinter:fillRect( { nLinIni, aColunas[19], nLinFin, aColunas[20] }, oBrush )
            // Linha 02
            nLinIni := nLinha-nSubLin*2+0.2
            nLinFin := nLinha-nSubLin*1+0.2
            oPrinter:fillRect( { nLinIni, aColunas[05], nLinFin, aColunas[06] }, oBrush )
            oPrinter:fillRect( { nLinIni, aColunas[08], nLinFin, aColunas[09] }, oBrush )
            oPrinter:fillRect( { nLinIni, aColunas[10], nLinFin, aColunas[11] }, oBrush )
            oPrinter:fillRect( { nLinIni, aColunas[14], nLinFin, aColunas[15] }, oBrush )
            oPrinter:fillRect( { nLinIni, aColunas[19], nLinFin, aColunas[20] }, oBrush )
            oPrinter:fillRect( { nLinIni, aColunas[21], nLinFin, aColunas[22] }, oBrush )
            // Linha 03
            nLinIni := nLinha-nSubLin*1+0.2
            nLinFin := nLinha+0.2
            oPrinter:fillRect( { nLinIni, aColunas[04], nLinFin, aColunas[12] }, oBrush )
            oPrinter:fillRect( { nLinIni, aColunas[14], nLinFin, aColunas[15] }, oBrush )
            oPrinter:fillRect( { nLinIni, aColunas[16], nLinFin, aColunas[19] }, oBrush )
            oPrinter:fillRect( { nLinIni, aColunas[20], nLinFin, aColunas[23]+nColCab3 }, oBrush )
 
        endif
    next nA

    nLinha      := nBlocoC+025
    nAssin      := (nRightTab-nColTab)*0.45
    
    oPrinter:Line(nLinha, nColTab, nLinha, nColTab+nAssin,,"-1")
    oPrinter:Say( nLinha+010    ,nColTab+10   , "Identificação e assinatura do responsável pela transcrição dos registros", oFOARNO07)
    oPrinter:Line(nLinha, nRightTab-nAssin, nLinha, nRightTab,,"-1")
    oPrinter:Say( nLinha+010    ,nRightTab-(nAssin/2)-40  , "Assinatura e carimbo do AFFA/MVO", oFOARNO07)
    
    //oPrinter:SayBitmap(nPosHorz+010,nPosVert+020,cLogo,64,52)
    /*
    nColuna 	:= 300
    oPrinter:Say(nPosHorz+nLinha, nPosVert+nColuna,"Dt. Emissão:"				,oFOARNE10)
    oPrinter:Say(nPosHorz+nLinha, nPosVert+nColuna+100,DtoC(QZT3->C5_EMISSAO)		,oFOARNO10)
    */

   
Return

Static Function fImpItens()
    Local ncAves := 0
    oPrinter:Say( aLinhas[nQuantReg][02][02]+09, aColunas[01]+30  , TRB->ZV1_RGRANJ , oFOARNO09)
    /*
    IF TRB->ZV1_RATEIO == "S"
        if TRB->ZV1_TURNO == 1
            ncAves := TRB->ZV1_QTDRT1
        elseif TRB->ZV1_TURNO == 2
            ncAves := TRB->ZV1_QTDRT2
        endif
    else
        ncAves := TRB->ZV1_CAVES
    endif
    */
    
    oPrinter:Say( aLinhas[nQuantReg][02][02]+09, aColunas[02]+03  , Transform(TRB->ZV1_CAVES,"@E 999,999") , oFOARNO09)

    fSqlItem()
    nCont := 4
    TRITE->(Dbgotop())

    IF TRITE->(!EOF())
        while TRITE->(!EOF())
            if nCont <= 23
                oPrinter:Say( aLinhas[nQuantReg][02][01]+09, aColunas[nCont]+01  , Transform(TRITE->ZEF_CONTOT ,"@E 9,999") , oFOARNO07)
                oPrinter:Say( aLinhas[nQuantReg][02][02]+09, aColunas[nCont]+01  , Transform(TRITE->ZEF_CODPAR ,"@E 9,999") , oFOARNO07)
                oPrinter:Say( aLinhas[nQuantReg][02][03]+09, aColunas[nCont]+01  , Transform(TRITE->ZEF_APRCON ,"@E 9,999") , oFOARNO07)
                
            endif

            nCont += 1
            TRITE->(Dbskip())
        enddo
    else

        for nCont := 4 to 23
            oPrinter:Say( aLinhas[nQuantReg][02][01]+09, aColunas[nCont]+01  , Transform(0 ,"@E 9,999") , oFOARNO07)
            oPrinter:Say( aLinhas[nQuantReg][02][02]+09, aColunas[nCont]+01  , Transform(0 ,"@E 9,999") , oFOARNO07)
            oPrinter:Say( aLinhas[nQuantReg][02][03]+09, aColunas[nCont]+01  , Transform(0 ,"@E 9,999") , oFOARNO07)
        next nCont

    endif
    
    TRITE->(DbcloseArea())
 
Return

static function fGetCond()
    Local aRet := {}

    cQuery := " SELECT X5_CHAVE, X5_DESCRI " 
    cQuery += " FROM "+ RetSqlName("SX5") +" (NOLOCK) X5 "
    cQuery += " WHERE X5.D_E_L_E_T_='' AND X5.X5_TABELA='_G' "
    cQuery += " ORDER BY X5_CHAVE, X5_DESCRI; "
                
	TCQUERY cQuery ALIAS "QCOND" NEW

    While QCOND->(!eof())
        AADD(aRet,{alltrim(QCOND->X5_CHAVE), Alltrim(QCOND->X5_DESCRI)})
        QCOND->(Dbskip())
    enddo

    QCOND->(DbcloseArea())
return aRet

Static function fSqlItem()
    Local cQuery    := ""

    cQuery  := " SELECT ZEF.ZEF_CODITE, SUM(ZEF.ZEF_CONTOT) ZEF_CONTOT, SUM(ZEF.ZEF_CODPAR) ZEF_CODPAR, SUM(ZEF.ZEF_APRCON) ZEF_APRCON "
    cQuery  += " FROM "+ RetSqlName("ZV1") +" (nolock) ZV1 INNER JOIN "+ RetSqlName("ZEF") +" (nolock) ZEF ON ZV1.D_E_L_E_T_='' AND ZEF.D_E_L_E_T_='' AND ZV1.ZV1_FILIAL='"+ xFilial("ZV1") +"' AND ZEF.ZEF_FILIAL='"+ xFilial("ZEF") +"' AND ZV1.ZV1_NUMOC=ZEF.ZEF_NUMOC "
    cQuery  += " WHERE  ZV1.ZV1_FILIAL='"+ xFilial("ZV1") +"' AND ZV1.ZV1_RGRANJ='"+ TRB->ZV1_RGRANJ +"' AND ZEF.ZEF_TURNO='"+ cValtochar(TRB->ZV1_TURNO) +"' "
    cQuery  += " GROUP BY ZEF.ZEF_CODITE "
    cQuery  += " ORDER BY ZEF.ZEF_CODITE; "
                
	TCQUERY cQuery ALIAS "TRITE" NEW
	
return

Static function fGetQuery()

    cQuery  := " SELECT ZV1.ZV1_DTABAT, ISNULL(ZEF.ZEF_TURNO, ZV1.ZV1_TURNO) ZV1_TURNO, ZV1.ZV1_RGRANJ, "
    cQuery  += " SUM(CASE WHEN ZV1.ZV1_RATEIO = 'S' AND ISNULL(ZEF.ZEF_TURNO, ZV1.ZV1_TURNO) = 1 THEN ZV1.ZV1_QTDRT1 "
    cQuery  += "          WHEN ZV1.ZV1_RATEIO = 'S' AND ISNULL(ZEF.ZEF_TURNO, ZV1.ZV1_TURNO) = 2 THEN ZV1.ZV1_QTDRT2 "
    cQuery  += "          ELSE ZV1.ZV1_CAVES END) ZV1_CAVES "
    cQuery  += " FROM "+ RetSqlName("ZV1") +" (nolock) ZV1 LEFT JOIN "
    cQuery  += "      (SELECT ZEF_FILIAL, ZEF_NUMOC, ZEF_TURNO, COUNT(*) CONTADOR
    cQuery  += "       FROM "+ RetSqlName("ZEF") +" "
    cQuery  += "       WHERE D_E_L_E_T_=''
    cQuery  += "       GROUP BY ZEF_FILIAL, ZEF_NUMOC, ZEF_TURNO) ZEF
    cQuery  += "        ON ZV1.D_E_L_E_T_='' AND ZV1.ZV1_FILIAL=ZEF.ZEF_FILIAL AND ZV1.ZV1_NUMOC=ZEF.ZEF_NUMOC "
    cQuery  += " WHERE  ZV1.ZV1_FILIAL='"+ xFilial("ZV1") +"' AND ZV1.D_E_L_E_T_='' AND ZV1.ZV1_DTABAT ='"+ dTos(MV_PAR01) +"' "
    cQuery  += " GROUP BY ZV1.ZV1_DTABAT, ISNULL(ZEF.ZEF_TURNO, ZV1.ZV1_TURNO), ZV1.ZV1_RGRANJ "
    cQuery  += " ORDER BY ZV1.ZV1_DTABAT, ISNULL(ZEF.ZEF_TURNO, ZV1.ZV1_TURNO), ZV1.ZV1_RGRANJ; "
                
	TCQUERY cQuery ALIAS "TRB" NEW
	
	TCSETFIELD("TRB","ZV1_DTABAT"		,"D",08,00)
	
return

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
