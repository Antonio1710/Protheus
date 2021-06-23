#Include "protheus.ch"
#Include "TopConn.ch"
#include "colors.ch"
#Include "Font.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} User Function ADEEC011R U_ADEEC011R()
    Impressão da Ordem de Carregamento Exportação.
    Chamado 8765
    @type  Function
    @author Leonardo P. Monteiro
    @since 25/05/2021
    @version 01
    @history Chamado 8465 - Leonardo P. Monteiro - 02/06/2021 - Ajuste de layout e quebras de linha.
    @history Chamado 8465 - Leonardo P. Monteiro - 02/06/2021 - Correção na impressão dos lacres de inspeção.
/*/
#Define IMP_SPOOL  2
#Define IMP_PDF    1
#Define DMPAPER_A4 9

User Function ADEEC011R()

    Local titulo   				:= "Ordem de Carregamento Exportação"
    Local cPerg					:= "ADEEC011R"
    Local cNomRel				:= "ADEEC011R"

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
    Private nLinha              := 0
    //Private nLinTemp            := 0

    Private nIniLinha           := 0
    Private aTpCond             := {}
    Private aColunas            := {}
    Private aLinhas             := {}
    Private aColTmp             := {}
    
    Aadd( aParamBox ,{1,"Ped. Exportação" ,Space(10)  ,"" ,'.T.',"",'.T.',80,.F.})
	
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

        fGetQuery()

        TRB->(dbgotop()) 

        nQuantReg   := 1
        
        If TRB->(!EOF())
        
            While TRB->(!Eof())
                
                fSqlItem()

                while QITEM->(!eof()) 

                    if nQuantReg > 9 .OR. nQuantReg == 1
                        if !oPrinter:isFirstPage
                            oPrinter:endpage()
                            nQuantReg   := 1
                        endif
                        
                        fImpCabec()
                        nLinha    := nIniLinha
                    endif
                    
                    fImpItens()
                    
                    nQuantReg += 1
                    QITEM->(Dbskip())

                enddo

                QITEM->(DbcloseArea())
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
    
    oPrinter:StartPage() 
    
    nLinha := nRow

    //oPrinter:Say( nLinha, (nRight-nCol)/2-07 , "ANEXO IV", oFOARNO09)
    //oPrinter:nPagecount
    //nLinha += 07
    oPrinter:Box(nLinha, nCol, nLinha+046, nRight)
    oPrinter:SayBitmap(nLinha+04, nCol+018,"\imagens\Logo001.png", 44,33)
    oPrinter:Say( nLinha+023, (nRight-nCol)/2 , "AD'ORO S/A", oFOARNE10)
    oPrinter:Say( nLinha+033, (nRight-nCol)/2-060 , "ORDEM DE CARREGAMENTO EXPORTAÇÃO", oFOARNO09)
    nLinha += 60
    oPrinter:Say( nLinha, nCol+002 , "Nº Invoice", oFOARNO09)
    oPrinter:Say( nLinha, nCol+002+(nRight-nCol)*0.3 , "Nº Ordem Coleta", oFOARNO09)
    oPrinter:Say( nLinha, nCol+004+(nRight-nCol)*0.6 , "Térmografo no Carregamento", oFOARNO09)
    oPrinter:Say( nLinha, nCol+005+(nRight-nCol)*0.8 , "Nº Termógrafo", oFOARNO09)
    nLinha += 04
    oPrinter:Box(nLinha, nCol, nLinha+020, nCol+(nRight-nCol)*0.20)
    oPrinter:Say(nLinha+12, nCol+032 , TRB->EE7_PEDIDO , oFOARNO09)
    oPrinter:Box(nLinha, nCol+(nRight-nCol)*0.3, nLinha+020, nCol+(nRight-nCol)*0.5)
    oPrinter:Say(nLinha+12, nCol+(nRight-nCol)*0.3+032 , IIF(EMPTY(TRB->EE7_XORDCO),"", TRB->EE7_XORDCO) , oFOARNO09)
    oPrinter:Box(nLinha, nCol+(nRight-nCol)*0.6, nLinha+020, nCol+(nRight-nCol)*0.8)
    oPrinter:Say(nLinha+12, nCol+(nRight-nCol)*0.6+042 , iif(TRB->EE7_XOPCTE=="S","Sim","Não") , oFOARNO09)
    oPrinter:Box(nLinha, nCol+(nRight-nCol)*0.8, nLinha+020, nRight)
    oPrinter:Say(nLinha+12, nCol+(nRight-nCol)*0.8+032 , IIF(EMPTY(TRB->EE7_XCODTE),"não se aplica",TRB->EE7_XCODTE) , oFOARNO09)
    nLinha += 30
    oPrinter:Say( nLinha, nCol+002 , "1.) Identificação", oFOARNO09)
    nLinha += 04
    oPrinter:Box(nLinha, nCol, nLinha+020, nRight)
    oPrinter:Say( nLinha+06, nCol+(nRight-nCol)*0.15 , "Nº OE:", oFOARNO09)
    oPrinter:Say(nLinha+14, nCol+(nRight-nCol)*0.15 , TRB->EE7_PEDIDO , oFOARNO09)
    oPrinter:Say( nLinha+06, nCol+(nRight-nCol)*0.45 , "Data Estufagem:", oFOARNO09)
    oPrinter:Say(nLinha+14, nCol+(nRight-nCol)*0.46 , DTOC(STOD(TRB->C5_DTENTR)) , oFOARNO09)
    nLinha += 30
    oPrinter:Say( nLinha, nCol+002 , "2.) Dados do Veículo", oFOARNO09)
    nLinha += 04
    aColTmp := (nRight-nCol)/3
    oPrinter:Box(nLinha, nCol, nLinha+020, nCol+aColTmp)
    oPrinter:Say( nLinha+06, nCol+002 , "Transportadora:", oFOARNO09)
    oPrinter:Say( nLinha+14, nCol+004 , iif(empty(TRB->A4_NOME),"",TRB->A4_NOME) , oFOARNO09)
    oPrinter:Box(nLinha, nCol+aColTmp, nLinha+020, nCol+aColTmp*2)
    oPrinter:Say( nLinha+06, nCol+aColTmp+002 , "Motorista:", oFOARNO09)
    oPrinter:Say( nLinha+14, nCol+aColTmp+004 , ALLTRIM(TRB->ZVC_MOTORI) , oFOARNO09)
    oPrinter:Box(nLinha, nCol+aColTmp*2, nLinha+020, nCol+aColTmp*3)
    oPrinter:Say( nLinha+06, nCol+aColTmp*2+002 , "Placa:", oFOARNO09)
    oPrinter:Say( nLinha+14, nCol+aColTmp*2+014 , iif(empty(TRB->C5_PLACA),"",TRB->C5_PLACA) , oFOARNO09)
    nLinha += 30
    oPrinter:Say( nLinha, nCol+002 , "3.) Dados do Embarque", oFOARNO09)
    nLinha += 04
    aColTmp := (nRight-nCol)
    aColTmp := {aColTmp*0.25,aColTmp*0.55,aColTmp*0.65,aColTmp*0.77,aColTmp}
    oPrinter:Box(nLinha, nCol, nLinha+020, nCol+aColTmp[01])
    oPrinter:Say( nLinha+6, nCol+002 , "Navio:", oFOARNO09)
    oPrinter:Say( nLinha+14, nCol+004 , iif(empty(TRB->EE6_NOME),ALLTRIM(TRB->EE7_XEMBAR) ,TRB->EE6_NOME) , oFOARNO09)
    oPrinter:Box(nLinha, nCol+aColTmp[01], nLinha+020, nCol+aColTmp[02])
    oPrinter:Say( nLinha+6, nCol+aColTmp[01]+002 , "Nº Container:", oFOARNO09)
    oPrinter:Say( nLinha+14, nCol+aColTmp[01]+007 , iif(empty(TRB->EE7_CONTAI),"",TRB->EE7_CONTAI) , oFOARNO09)
    oPrinter:Box(nLinha, nCol+aColTmp[02], nLinha+020, nCol+aColTmp[03])
    oPrinter:Say( nLinha+6, nCol+aColTmp[02]+002 , "Nº Lacre Oficial:", oFOARNO09)
    oPrinter:Say( nLinha+14, nCol+aColTmp[02]+003 , iif(empty(TRB->EE7_NLACR2),"",TRB->EE7_NLACR2) , oFOARNO09)
    oPrinter:Box(nLinha, nCol+aColTmp[03], nLinha+020, nCol+aColTmp[04])
    oPrinter:Say( nLinha+6, nCol+aColTmp[03]+002 , "Nº Lacre Armador:", oFOARNO09)
    oPrinter:Say( nLinha+14, nCol+aColTmp[03]+003 , iif(empty(TRB->EE7_NLACR1),"",TRB->EE7_NLACR1) , oFOARNO09)
    oPrinter:Box(nLinha, nCol+aColTmp[04], nLinha+020, nCol+aColTmp[05])
    oPrinter:Say( nLinha+6, nCol+aColTmp[04]+002 , "Tara:", oFOARNO09)
    oPrinter:Say( nLinha+14, nCol+aColTmp[04]+08 , TRANSFORM(TRB->EE7_XTARA, "@E 999999")  , oFOARNO09)
    nLinha += 30
    oPrinter:Say( nLinha, nCol+002 , "4.) Identificação de Carga", oFOARNO09)
    nLinha += 04
    aColTmp := (nRight-nCol)
    aColTmp := {aColTmp*0.15,aColTmp*0.60,aColTmp*0.70,aColTmp*0.85,aColTmp}
    oPrinter:Box(nLinha, nCol, nLinha+015, nCol+aColTmp[01])
    oPrinter:Say( nLinha+10, nCol+025     , "Código", oFOARNO09)
    oPrinter:Box(nLinha, nCol+aColTmp[01], nLinha+015, nCol+aColTmp[02])
    oPrinter:Say( nLinha+10, nCol+aColTmp[01]+085 , "Nome", oFOARNO09)
    oPrinter:Box(nLinha, nCol+aColTmp[02], nLinha+015, nCol+aColTmp[03])
    oPrinter:Say( nLinha+10, nCol+aColTmp[02]+010 , "Quantidade", oFOARNO09)
    oPrinter:Box(nLinha, nCol+aColTmp[03], nLinha+015, nCol+aColTmp[04])
    oPrinter:Say( nLinha+10, nCol+aColTmp[03]+020 , "Líquido (KG)", oFOARNO09)
    oPrinter:Box(nLinha, nCol+aColTmp[04], nLinha+015, nCol+aColTmp[05])
    oPrinter:Say( nLinha+10, nCol+aColTmp[04]+020 , "Bruto (KG)", oFOARNO09)
    nLinha += 15
    nIniLinha := nLinha
    for nA := 1 TO 4
        oPrinter:Box(nLinha, nCol, nLinha+020, nCol+aColTmp[01])
        oPrinter:Box(nLinha, nCol+aColTmp[01], nLinha+020, nCol+aColTmp[02])
        oPrinter:Box(nLinha, nCol+aColTmp[02], nLinha+020, nCol+aColTmp[03])
        oPrinter:Box(nLinha, nCol+aColTmp[03], nLinha+020, nCol+aColTmp[04])
        oPrinter:Box(nLinha, nCol+aColTmp[04], nLinha+020, nCol+aColTmp[05])
        nLinha += 15
    next nA

    oPrinter:Box(nLinha, nCol, nLinha+020, nRight)
    oPrinter:Say( nLinha+007, nCol+002 , "Temperatura:", oFOARNO09)
    oPrinter:Say( nLinha+015, (nRight-nCol)/2-05 , Alltrim(TRB->EE7_TEMPER) + "ºC" , oFOARNO09)
    //nLinTemp   := nLinha+010

    nLinha += 30
    oPrinter:Say( nLinha, nCol+002 , "5.) Dados do Embarque", oFOARNO09)
    oPrinter:Say( nLinha, (nRight-nCol)*0.30+002 , "6.) Importador", oFOARNO09)
    nLinha += 04
    oPrinter:Box(nLinha, nCol, nLinha+040, (nRight-nCol)*0.30 )
    oPrinter:Say( nLinha+7, nCol+002 , "Pais:", oFOARNO09)
    oPrinter:Say( nLinha+24, nCol+015 , TRB->YA_DESCR , oFOARNO09)
    oPrinter:Box(nLinha, (nRight-nCol)*0.30, nLinha+040, nRight)
    oPrinter:Say( nLinha+07, (nRight-nCol)*0.30+002 , "Nome:", oFOARNO09)
    oPrinter:Say( nLinha+07, (nRight-nCol)*0.30+024 , TRB->CONSIG , oFOARNO09)
    oPrinter:Say( nLinha+26, (nRight-nCol)*0.30+002 , "Endereço:", oFOARNO09)
    cEnd := Alltrim(TRB->A1_END)+" "+alltrim(TRB->A1_COMPLEM)+" "+Alltrim(TRB->YA_DESCR)
    //oPrinter:Say( nLinha+26, (nRight-nCol)*0.30+036 ,  cEnd, oFOARNO09)
    oPrinter:Say( nLinha+20, (nRight-nCol)*0.30+036 ,  alltrim(TRB->A1_END), oFOARNO09)
    oPrinter:Say( nLinha+30, (nRight-nCol)*0.30+036 ,  alltrim(TRB->A1_COMPLEM)+"-"+Alltrim(TRB->YA_DESCR), oFOARNO09)
    

    nLinha += 50
    oPrinter:Say( nLinha, nCol+002 , "7.) Dados do Cliente", oFOARNO09)
    nLinha += 04
    oPrinter:Box(nLinha, nCol, nLinha+020, (nRight-nCol)*0.30 )
    oPrinter:Say( nLinha+7, nCol+002 , "Cliente:", oFOARNO09)
    oPrinter:Say( nLinha+14, nCol+015 , TRB->A1_NOME , oFOARNO09)
    oPrinter:Box(nLinha, (nRight-nCol)*0.30, nLinha+020, (nRight-nCol)*0.60)
    oPrinter:Say( nLinha+07, (nRight-nCol)*0.30+002 , "Booking:", oFOARNO09)
    oPrinter:Say( nLinha+14, (nRight-nCol)*0.30+015 , TRB->EE7_XBOOKI , oFOARNO09)
    nLinha += 30
    oPrinter:Say( nLinha, nCol+002 , "8.) Dados do Faturamento", oFOARNO09)
    nLinha += 04
    oPrinter:Box(nLinha, nCol, nLinha+020, (nRight-nCol)*0.30 )
    oPrinter:Say( nLinha+7, nCol+002 , "Pedido:", oFOARNO09)
    oPrinter:Say( nLinha+14, nCol+015 , TRB->EE7_PEDFAT , oFOARNO09)
    oPrinter:Box(nLinha, (nRight-nCol)*0.30, nLinha+020, (nRight-nCol)*0.60)
    oPrinter:Say( nLinha+7, (nRight-nCol)*0.30+002 , "Roteiro:", oFOARNO09)
    oPrinter:Say( nLinha+14, (nRight-nCol)*0.30+015 , TRB->C5_ROTEIRO , oFOARNO09)
    nLinha += 40
    oPrinter:Say( nLinha, nCol+002 , "9.) Parecer Logística", oFOARNO09)
    nLinha += 04
    oPrinter:Box(nLinha, nCol, nLinha+040, nRight )
    oPrinter:Say( nLinha+7, nCol+002 , "Data:", oFOARNO09)
    oPrinter:Say( nLinha+7, (nRight-nCol)*0.50+002 , "Carimbo e assinatura / Responsável pela inclusao da CSI", oFOARNO09)
    
Return

Static Function fImpItens()
    Local cDescri   := ""
    Local nQuebra   := 50

    if Empty(QITEM->PGA_DESCRI)
        cDescri := ALLTRIM(QITEM->B1_DESC)
    else
        cDescri := ALLTRIM(QITEM->PGA_DESCRI)
    endif

    oPrinter:Say( nLinha+010, nCol+025              , QITEM->EE8_COD_I , oFOARNO07)
    if Len(cDescri) <= nQuebra
        oPrinter:Say( nLinha+010, nCol+aColTmp[01]+005  , cDescri , oFOARNO07)
    else
        oPrinter:Say( nLinha+005, nCol+aColTmp[01]+005  , Left(cDescri,nQuebra) , oFOARNO06)
        oPrinter:Say( nLinha+015, nCol+aColTmp[01]+005  , Substring(cDescri,nQuebra+1, Len(cDescri)) , oFOARNO06)
    endif
    
    oPrinter:Say( nLinha+010, nCol+aColTmp[02]+005  , Transform(QITEM->EE8_QTDEM1 ,"@E 99,999,999.999") , oFOARNO07)
    oPrinter:Say( nLinha+010, nCol+aColTmp[03]+035  , Transform(QITEM->EE8_PSLQTO ,"@E 99,999,999.999") , oFOARNO07)
    oPrinter:Say( nLinha+010, nCol+aColTmp[04]+035  , Transform(QITEM->EE8_PSBRTO ,"@E 99,999,999.999") , oFOARNO07)
    
    nLinha += 15
Return

Static function fSqlItem()
    Local cQuery    := ""
    Local cEOL      := Chr(13)+chr(10)

    cQuery := " SELECT EE8.EE8_COD_I, B1.B1_DESC, EE8.EE8_QTDEM1, EE8.EE8_PSLQTO, EE8.EE8_PSBRTO, LTRIM(RTRIM(ISNULL(ZE1.ZE1_DENOMI,'')))+' '+ LTRIM(RTRIM(ISNULL(ZED.ZED_DESCAT,'')))	PGA_DESCRI "+cEOL
	cQuery += " FROM "+ RetSqlName("EE7") +" (nolock) EE7 INNER JOIN "+ RetSqlName("EE8") +" (NOLOCK) EE8  ON EE7.D_E_L_E_T_='' AND EE8.D_E_L_E_T_='' AND EE7.EE7_PEDIDO=EE8.EE8_PEDIDO "+cEOL
 	cQuery += " 				 LEFT  JOIN "+ RetSqlName("SB1") +" (NOLOCK) B1  ON B1.D_E_L_E_T_='' AND B1.B1_COD=EE8.EE8_COD_I  "+cEOL
 	cQuery += " 				 LEFT  JOIN "+ RetSqlName("ZE1") +" (NOLOCK) ZE1 ON ZE1.D_E_L_E_T_='' AND B1.B1_XPGAMER=ZE1.ZE1_REGIST "+cEOL
	cQuery += " 				 LEFT  JOIN "+ RetSqlName("ZED") +" (NOLOCK) ZED ON ZED.D_E_L_E_T_='' AND B1.B1_XPGAMER=ZED.ZED_REGZE1 AND B1.B1_XPGACAT =ZED.ZED_CODCAT
    cQuery += " WHERE  EE8.D_E_L_E_T_='' AND EE8.EE8_FILIAL='' AND EE8.EE8_PEDIDO ='"+ TRB->EE7_PEDIDO +"' "+cEOL
    cQuery += " ORDER BY EE7.EE7_PEDIDO; "
	TCQUERY cQuery ALIAS "QITEM" NEW
    
    TCSETFIELD("QITEM","EE8_SLDINI"		,"N",10,03)
    TCSETFIELD("QITEM","EE8_PSLQTO"		,"N",10,03)
    TCSETFIELD("QITEM","EE8_PSBRTO"		,"N",10,03)
return

Static function fGetQuery()
    Local cQuery    := ""
    Local cEOL      := Chr(13)+chr(10)

    cQuery := " SELECT EE7_PEDIDO, EE7.EE7_XORDCO, EE7.EE7_XOPCTE, EE7.EE7_XCODTE, EE7.EE7_XEMBAR, EE7.EE7_CONTAI, EE7.EE7_NLACR1, EE7.EE7_NLACR2, EE7.EE7_TEMPER, EE7_XBOOKI, EE7_PEDFAT,"+cEOL
	cQuery += " 	   EE7.EE7_XTARA, A1.A1_COD, A1.A1_LOJA, A1.A1_NOME, A1A.A1_NOME CONSIG, A1A.A1_END, A1A.A1_BAIRRO, A1A.A1_COMPLEM, YA.YA_DESCR, " +cEOL
    cQuery += "        EE6.EE6_NOME, C5.C5_NUM, C5.C5_ROTEIRO, C5.C5_DTENTR, C5.C5_PLACA, A4.A4_NOME, ZVC.ZVC_MOTORI "+cEOL
    cQuery += " FROM "+ RetSqlName("EE7") +" (nolock) EE7 INNER JOIN "+ RetSqlName("SC5") +" (NOLOCK) C5  ON C5.D_E_L_E_T_='' AND EE7.D_E_L_E_T_='' AND EE7.EE7_PEDFAT=C5.C5_NUM "+cEOL
	cQuery += " 					 LEFT  JOIN "+ RetSqlName("SA1") +" (NOLOCK) A1  ON EE7.D_E_L_E_T_='' AND A1.D_E_L_E_T_='' AND EE7.EE7_IMPORT=A1.A1_COD AND EE7.EE7_IMLOJA=A1.A1_LOJA "+cEOL
	cQuery += " 					 LEFT  JOIN "+ RetSqlName("SA1") +" (NOLOCK) A1A ON EE7.D_E_L_E_T_='' AND A1A.D_E_L_E_T_='' AND EE7.EE7_CONSIG=A1A.A1_COD AND EE7.EE7_COLOJA=A1A.A1_LOJA "+cEOL
	cQuery += " 					 LEFT  JOIN "+ RetSqlName("SYA") +" (NOLOCK) YA  ON YA.D_E_L_E_T_='' AND YA.YA_CODGI=EE7.EE7_PAISET "+cEOL
	cQuery += " 					 LEFT  JOIN "+ RetSqlName("EE6") +" (NOLOCK) EE6 ON EE6.D_E_L_E_T_='' AND EE6.EE6_COD=EE7.EE7_XEMBAR "+cEOL
    cQuery += "                      LEFT  JOIN "+ RetSqlName("SA4") +" (NOLOCK) A4  ON EE7.D_E_L_E_T_='' AND A4.D_E_L_E_T_='' AND C5.C5_TRANSP=A4.A4_COD "+cEOL
    cQuery += "                      LEFT  JOIN "+ RetSqlName("ZV4") +" (NOLOCK) ZV4 ON ZV4.D_E_L_E_T_='' AND ZV4.ZV4_PLACA=C5.C5_PLACA "+cEOL
    cQuery += "                      LEFT  JOIN "+ RetSqlName("ZVC") +" (NOLOCK) ZVC ON ZVC.D_E_L_E_T_='' AND ( (ZV4.ZV4_CPF=ZVC.ZVC_CPF AND ZV4.ZV4_CPF!='') OR (ZV4.ZV4_PASPO=ZVC.ZVC_PASPOR AND ZV4.ZV4_PASPO!='') )  "+cEOL
    cQuery += " WHERE  EE7.D_E_L_E_T_='' AND EE7.EE7_FILIAL='' AND EE7.EE7_PEDIDO ='"+ MV_PAR01 +"' "+cEOL
    cQuery += " ORDER BY EE7.EE7_PEDIDO; "
	TCQUERY cQuery ALIAS "TRB" NEW
                
	//TCSETFIELD("TRB","ZV1_DTABAT"		,"D",08,00)
	
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
