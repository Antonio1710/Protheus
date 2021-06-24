#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
 
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
 
/*/{Protheus.doc} User Function ADFIN085R
	Relatório de Co-participação
	@type  Function
	@author William Costa
	@since 14/04/2020
	@version 01
    @history Chamado 056404 - WILLIAM COSTA - 20/05/2020 - Alterado o SQl do F2_TIPO
    @history Chamado 15661  - Everson - 22/06/2021 - Tratamento para desconsiderar cargas exportação e subproduto. 
/*/

User Function ADFIN085R() // U_ADFIN085R()

    Local aArea        := GetArea()
    Private cNomeRel   := "rel_co-Participacao_"+dToS(Date())+StrTran(Time(), ':', '-')
    Private cHoraEx    := Time()
    Private nPagAtu    := 1
    Private oPrintPvt
    //Fontes
    Private cNomeFont  := "Arial"
    Private oFontRod   := TFont():New(cNomeFont, , -06, , .F.)
    Private oFontTit   := TFont():New(cNomeFont, , -20, , .T.)
    Private oFontTit2  := TFont():New(cNomeFont, , -18, , .T.)
    Private oFontSubN  := TFont():New(cNomeFont, , -17, , .T.)
    Private oFont      := TFont():New(cNomeFont, , -12, , .F.)
    Private oFont12Neg := TFont():New(cNomeFont, , -12, , .T.)
    Private oFont10    := TFont():New(cNomeFont, , -10, , .F.)
    Private oFont10Neg := TFont():New(cNomeFont, , -10, , .T.)
    //Linhas e colunas
    Private nLinAtu    := 0
    Private nLinFin    := 820
    Private nColIni    := 010
    Private nColFin    := 550
    Private nColMeio   := (nColFin-nColIni)/2
    Private cPERG      := "ADFIN085R"
    Private nLinCab    := 025
    Private nTotCC6110 := 0
    Private nTotCC6210 := 0
    Private nPerCC6110 := 0
    Private nPerCC6210 := 0
    Private nPesLiq    := 0
    Private nPesBrut   := 0
    Private cNum       := ''
    Private aSays	   := {}
	Private aButtons   := {}   
	Private cCadastro  := "Relatório de Co-Participação"    
	Private nOpca	   := 0
    Private cDir       := ''

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de co-participacao')
    
    MontaPerg()

    AADD(aSays,"Este programa tem a finalidade de gerar um arquivo PDF " )
	AADD(aSays,"Relatório de Co-Participação" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||GERAPDF()},"Gerando arquivo PDF","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )

    RestArea(aArea)
    
RETURN(NIL)    

STATIC FUNCTION GERAPDF()    

    IF MV_PAR03 == 1

        GERALOGISTICA()
     
    ELSE

        GERACONTABILIDADE()
        RESUMOCONT()

    ENDIF
    
Return(NIL)
 
Static Function fImpRod()

    Local nLinRod := nLinFin + 10
    Local cTexto  := ""
 
    //Linha Separatória
    oPrintPvt:Line(nLinRod, nColIni, nLinRod, nColFin, RGB(200, 200, 200))
    nLinRod += 3
     
    //Dados da Esquerda
    cTexto := "Relatório Co-Participação    |    "+dToC(dDataBase)+"     "+cHoraEx+"     "+"ADFIN085R"+"     "+cUserName
    oPrintPvt:SayAlign(nLinRod, nColIni,    cTexto, oFontRod, 250, 07, , PAD_LEFT, )
     
    //Direita
    cTexto := "Página "+cValToChar(nPagAtu)
    oPrintPvt:SayAlign(nLinRod, nColFin-40, cTexto, oFontRod, 040, 07, , PAD_RIGHT, )
     
    //Finalizando a página e somando mais um
    oPrintPvt:EndPage()
    nPagAtu++
Return(NIL)

Static Function MontaPerg()  
                                
	Private bValid := Nil 
	Private cF3	   := Nil
	Private cSXG   := Nil
	Private cPyme  := Nil
	
	U_xPutSx1(cPerg,'01','Data Faturamento Ini ?','','','mv_ch01','D',08,0,00,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR01')
	U_xPutSx1(cPerg,'02','Data Faturamento Fin ?','','','mv_ch02','D',08,0,00,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR02')
	U_xPutSX1(cPerg,"03","Relatório vai para ? ","" ,"","mv_ch03","N",01,0,01,"C","","","","","MV_PAR03" ,"Logistica","Logistica","Logistica","","Contabilidade","Contabilidade","Contabilidade","","","","","","",""," ")
	
    Pergunte(cPerg,.F.)
	
Return Nil        

STATIC FUNCTION GERALOGISTICA()

    Local cTexto     := ""

    //Criando o objeto de impressão
    cNomeRel           := "rel_co-Participacao_"+dToS(Date())+StrTran(Time(), ':', '-')
    oPrintPvt          := FWMSPrinter():New(cNomeRel, IMP_PDF, .F., /*cStartPath*/, .T., , @oPrintPvt, , , , , .T.)
    oPrintPvt:cPathPDF := GetTempPath()
    oPrintPvt:SetResolution(72)
    oPrintPvt:SetPortrait()
    oPrintPvt:SetPaperSize(DMPAPER_A4)
    oPrintPvt:SetMargin(60, 60, 60, 60)
    oPrintPvt:StartPage()
    
    CALCCC()

    CABECLOGISTICA()

    // ***  INICIO RELATORIO

    SqlLogistica()
    While TRB->(!EOF())   

        IF nLinAtu >= 810 // INICIA UMA NOVA PAGINA

            fImpRod()
            oPrintPvt:StartPage()
            CABECLOGISTICA()

        ENDIF    

        oPrintPvt:SayAlign(nLinAtu, 030, TRB->F2_PLACA, oFont, 200, 10, RGB(0,0,0), PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu, 290, TRANSFORM(TRB->F2_XVLCOPA,"@E 9,999,999,999.99"), oFont, 200, 10, RGB(0,0,0), PAD_RIGHT, 0)
        oPrintPvt:SayAlign(nLinAtu, 520, TRB->F2_XCC, oFont, 200, 10, RGB(0,0,0), PAD_LEFT, 0)

        nLinAtu := nLinAtu + 15

        TRB->(dbSkip())
                
    ENDDO
    TRB->(dbCloseArea())

    // ***  FINAL RELATORIO
     
    //Impressão do Rodapé
    fImpRod()    

    //Gera o pdf para visualização
    oPrintPvt:Preview()
    FreeObj(oPrintPvt)
    oPrintPvt := Nil

RETURN(NIL)

STATIC FUNCTION GERACONTABILIDADE()

    Local cTexto     := ""
    Local nTotReg	 := 0
    Local nCont      := 0

    // ***  INICIO RELATORIO

    cDir := cGetFile("Arquivo PDF.", "Selecione o diretório para salvar o PDF",,'C:\TEMP\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)

    IF ALLTRIM(cDir) == ''

        MSGAlert('É necessário selecionar o caminho para salvar o arquivo do relatório (.PDF)!', 'ADFIN085R-01')
        RETURN(NIL)

    ENDIF

    SqlTransportador()
    nTotReg := Contar("TRE","!Eof()")
    nCont   := 0
    ProcRegua(nTotReg)
	TRE->(DbGoTop())
    While TRE->(!EOF()) 

        nCont := nCont + 1

        IncProc("Gerando PDF Transportadora: " + TRE->F2_TRANSP+'-'+SUBSTR(TRE->A4_NOME,1,10) + ' ' + 'Total: ' + CVALTOCHAR(nCont) + '/' + CVALTOCHAR(nTotReg)) 

        SqlCCCONT(TRE->F2_TRANSP)
        While TRF->(!EOF())

            cNum     := CVALTOCHAR(YEAR(MV_PAR01)) + STRZERO(MONTH(MV_PAR01),2) + CVALTOCHAR(VAL(TRE->F2_TRANSP)) + TRF->F2_XCC
            nPesLiq  := TRF->F2_PLIQUI
            nPesBrut := TRF->F2_PBRUTO

            //Criando o objeto de impressão
            cNomeRel           := CVALTOCHAR(YEAR(MV_PAR01)) + '-' + STRZERO(MONTH(MV_PAR01),2) + '-' + STRZERO(DAY(MV_PAR01),2) + '_NUM ' + cNum  
            oPrintPvt          := FWMSPrinter():New(cNomeRel, IMP_PDF, .F., /*cStartPath*/, .T., , @oPrintPvt, , , , , .F.)
            oPrintPvt:cPathPDF := cDir
            oPrintPvt:SetResolution(72)
            oPrintPvt:SetPortrait()
            oPrintPvt:SetPaperSize(DMPAPER_A4)
            oPrintPvt:SetMargin(60, 60, 60, 60)
            oPrintPvt:StartPage()

            CABECCONTABILIDADE()

            oPrintPvt:SayAlign(nLinAtu,010,"TRANSPORTADOR", oFont10, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinAtu,IIF(LEN(CVALTOCHAR(nPesLiq)) == 1,95,95 + (LEN(CVALTOCHAR(nPesLiq)) * 2)),TRE->F2_TRANSP+'-'+TRE->A4_NOME, oFont10Neg, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinAtu,358,"CIDADE", oFont10, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinAtu,IIF(LEN(CVALTOCHAR(nPesBrut)) == 1,415,415 + (LEN(CVALTOCHAR(nPesBrut)) * 2)),ALLTRIM(TRE->A4_MUN)+'/'+TRE->A4_EST, oFont10Neg, 200, 20, RGB(0,0,0), PAD_LEFT, 0)

            nLinAtu := nLinAtu + 15

            oPrintPvt:SayAlign(nLinAtu,010,"PESO LÍQUIDO", oFont10, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinAtu,IIF(LEN(CVALTOCHAR(nPesLiq)) == 1,95,95 + (LEN(CVALTOCHAR(nPesLiq)) * 2)),ALLTRIM(TRANSFORM(nPesLiq,"@E 9,999,999,999.99")), oFont10Neg, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinAtu,358,"PESO BRUTO", oFont10, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinAtu,IIF(LEN(CVALTOCHAR(nPesBrut)) == 1,415,415 + (LEN(CVALTOCHAR(nPesBrut)) * 2)),ALLTRIM(TRANSFORM(nPesBrut,"@E 9,999,999,999.99")), oFont10Neg, 100, 20, RGB(0,0,0), PAD_LEFT, 0)

            nLinAtu := nLinAtu + 15

            oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, RGB(0,0,0), "01")

            nLinAtu := nLinAtu + 15

            oPrintPvt:SayAlign(nLinAtu,010,"TIPO DOCTO", oFont10, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinAtu,070,"NDF", oFont10Neg, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinAtu,358,"NUMERO:", oFont10, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinAtu,400,cNum, oFont10Neg, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinAtu,500,"VALOR", oFont10, 050, 20, RGB(0,0,0), PAD_RIGHT, 0)

            nLinAtu := nLinAtu + 15

            oPrintPvt:SayAlign(nLinAtu,010,"NATUREZA", oFont10, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinAtu,070,"20.801", oFont10Neg, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinAtu,358,"DATA:", oFont10, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinAtu,400,DTOC(MV_PAR01), oFont10Neg, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinAtu,450,TRANSFORM(TRF->F2_XVLCOPA,"@E 9,999,999,999.99"), oFont10Neg, 100, 20, RGB(0,0,0), PAD_RIGHT, 0)

            nLinAtu := nLinAtu + 15

            oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, RGB(0,0,0), "01")

            nLinAtu := nLinAtu + 15

            oPrintPvt:SayAlign(nLinAtu,040,"DÉBITO:", oFont10, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinAtu,080,"111.310.001 ADIANT. FORNECEDORES", oFont10Neg, 200, 20, RGB(0,0,0), PAD_LEFT, 0)

            nLinAtu := nLinAtu + 15

            oPrintPvt:SayAlign(nLinAtu,035,"CREDITO:", oFont10, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinAtu,080,"313.140.002 SEGURO DE CARGAS", oFont10Neg, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinAtu,318,"CENTRO DE CUSTO:", oFont10, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinAtu,400,TRF->F2_XCC, oFont10Neg, 200, 20, RGB(0,0,0), PAD_LEFT, 0)

            nLinAtu := nLinAtu + 15

            oPrintPvt:SayAlign(nLinAtu,027,"HISTÓRICO:", oFont10, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinAtu,080,"VLR REF CO-PARTICIPAÇÃO EM SEGUROS DE CARGA", oFont10Neg, 250, 20, RGB(0,0,0), PAD_LEFT, 0)

            nLinAtu := nLinAtu + 15

            CABECCONT2(nLinAtu,1)

            IF ALLTRIM(TRF->F2_XCC) == '6110'
            
                SqlCONTAB1(TRE->F2_TRANSP)

            ELSE

                SqlCONTAB2(TRE->F2_TRANSP)

            ENDIF    

            nLinAtu := nLinAtu + 40

            While TRG->(!EOF())

                IF nLinAtu >= 805 // INICIA UMA NOVA PAGINA

                    fImpRod()
                    oPrintPvt:StartPage()
                    nLinAtu := 25
                    CABECCONT2(nLinAtu,1)
                    nLinAtu := nLinAtu + 40

                ENDIF    

                oPrintPvt:SayAlign(nLinAtu, 020, DTOC(STOD(TRG->F2_EMISSAO)), oFont, 200, 10, RGB(0,0,0), PAD_LEFT, 0)
                oPrintPvt:SayAlign(nLinAtu, 085, TRG->F2_DOC, oFont, 200, 10, RGB(0,0,0), PAD_LEFT, 0)
                oPrintPvt:SayAlign(nLinAtu, 160, TRG->F2_CLIENTE + '-' + TRG->A1_NOME, oFont, 200, 10, RGB(0,0,0), PAD_LEFT, 0)
                oPrintPvt:SayAlign(nLinAtu, 235, TRANSFORM(TRG->F2_VALBRUT,"@E 9,999,999,999.99"), oFont, 200, 10, RGB(0,0,0), PAD_RIGHT, 0)
                oPrintPvt:SayAlign(nLinAtu, 340, TRANSFORM(TRG->F2_XVLCOPA,"@E 9,999,999,999.99"), oFont, 200, 10, RGB(0,0,0), PAD_RIGHT, 0)
                
                nLinAtu := nLinAtu + 15

                TRG->(dbSkip())
                        
            ENDDO
            TRG->(dbCloseArea()) 

            //Impressão do Rodapé
            fImpRod() 
            //gera o pdf na pasta direto
            oPrintPvt:PRINT()
            FreeObj(oPrintPvt)
            oPrintPvt := Nil

            TRF->(dbSkip())
                    
        ENDDO
        TRF->(dbCloseArea())    

        TRE->(dbSkip())
                
    ENDDO
    TRE->(dbCloseArea())
    
    // ***  FINAL RELATORIO

RETURN(NIL)

STATIC FUNCTION RESUMOCONT()

    Local cTexto     := ""

    //Criando o objeto de impressão
    cNomeRel           := CVALTOCHAR(YEAR(MV_PAR01)) + '-' + STRZERO(MONTH(MV_PAR01),2) + '-' + STRZERO(DAY(MV_PAR01),2) + '_Resumo_CoParticipacao'
    oPrintPvt          := FWMSPrinter():New(cNomeRel, IMP_PDF, .F., , .T., , @oPrintPvt, , , , , .F.)
    oPrintPvt:cPathPDF := cDir
    oPrintPvt:SetResolution(72)
    oPrintPvt:SetPortrait()
    oPrintPvt:SetPaperSize(DMPAPER_A4)
    oPrintPvt:SetMargin(60, 60, 60, 60)
    oPrintPvt:StartPage()

    CALCCC()

    CABECRESCONT()

    // ***  INICIO RELATORIO

    SqlRESCONT()
    While TRH->(!EOF())   

        IF nLinAtu >= 810 // INICIA UMA NOVA PAGINA

            fImpRod()
            oPrintPvt:StartPage()
            CABECRESCONT()

        ENDIF    

        cNum     := CVALTOCHAR(YEAR(MV_PAR01)) + STRZERO(MONTH(MV_PAR01),2) + CVALTOCHAR(VAL(TRH->F2_TRANSP)) + TRH->F2_XCC
        oPrintPvt:SayAlign(nLinAtu, 030, TRH->F2_TRANSP, oFont, 200, 10, RGB(0,0,0), PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu, 105, TRH->A4_NOME, oFont, 200, 10, RGB(0,0,0), PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu, 200, ALLTRIM(cNum), oFont, 200, 10, RGB(0,0,0), PAD_RIGHT, 0)
        oPrintPvt:SayAlign(nLinAtu, 290, TRANSFORM(TRH->F2_XVLCOPA,"@E 9,999,999,999.99"), oFont, 200, 10, RGB(0,0,0), PAD_RIGHT, 0)
        oPrintPvt:SayAlign(nLinAtu, 520, TRH->F2_XCC, oFont, 200, 10, RGB(0,0,0), PAD_LEFT, 0)

        nLinAtu := nLinAtu + 15

        TRH->(dbSkip())
                
    ENDDO
    TRH->(dbCloseArea())

    // ***  FINAL RELATORIO
     
    //Impressão do Rodapé
    fImpRod()    

    //Gera o pdf para visualização

    oPrintPvt:PRINT()
    FreeObj(oPrintPvt)
    oPrintPvt := Nil
   
RETURN(NIL)

STATIC FUNCTION CABECCONT2(nLinAtu,nPag)

    oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, RGB(0,0,0), "01")
        
    nLinAtu := nLinAtu + 15

    oPrintPvt:Say(nLinAtu + 3,030,'DATA NF',oFont10Neg,620,,,2)  
    oPrintPvt:Say(nLinAtu + 3,100,'NUM NF',oFont10Neg,620,,,2) 
    oPrintPvt:Say(nLinAtu + 3,220,'CLIENTE',oFont10Neg,620,,,2) 
    oPrintPvt:Say(nLinAtu,390,'VALOR',oFont10Neg,620,,,2) 
    oPrintPvt:Say(nLinAtu,505,'VALOR CO-',oFont10Neg,620,,,2)

    nLinAtu := nLinAtu + 15

    oPrintPvt:Say(nLinAtu,390,'MERCADORIA',oFont10Neg,620,,,2) 
    oPrintPvt:Say(nLinAtu,515,'PARTICIP',oFont10Neg,620,,,2)

    nLinAtu := nLinAtu + 05

    oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, RGB(0,0,0), "01")
   
RETURN(NIL)        

STATIC FUNCTION CABECLOGISTICA()

    // ***  INICIO CABEÇALHO
    nLinCab  := 25
    oPrintPvt:SayAlign(nLinCab, nColMeio-300, "RESUMO CO-PARTICIPAÇÃO EM SEGUROS DE CARGAS", oFontTit, 600, 20, RGB(0,0,0), PAD_CENTER, 0)

    nLinCab := nLinCab + 25
    
    oPrintPvt:SayAlign(nLinCab, 010,"DATA LOG", oFont, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
    oPrintPvt:SayAlign(nLinCab, 350,"CC 6110", oFont, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
    oPrintPvt:SayAlign(nLinCab, 300,TRANSFORM(nTotCC6110,"@E 9,999,999,999.99"), oFont, 200, 20, RGB(0,0,0), PAD_RIGHT, 0)
    oPrintPvt:SayAlign(nLinCab, 358,TRANSFORM(nPerCC6110,"@E 999.99"), oFont, 200, 20, RGB(0,0,0), PAD_RIGHT, 0)
    oPrintPvt:SayAlign(nLinCab, 558,'%', oFont, 200, 20, RGB(0,0,0), PAD_LEFT, 0)

    nLinCab := nLinCab + 15
    oPrintPvt:SayAlign(nLinCab, 10, DTOC(MV_PAR01), oFont, 1400, 20, RGB(0,0,0), PAD_LEFT, 0)
    oPrintPvt:SayAlign(nLinCab, 350,"CC 6210", oFont, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
    oPrintPvt:SayAlign(nLinCab, 300,TRANSFORM(nTotCC6210,"@E 9,999,999,999.99"), oFont, 200, 20, RGB(0,0,0), PAD_RIGHT, 0)
    oPrintPvt:SayAlign(nLinCab, 358,TRANSFORM(nPerCC6210,"@E 999.99"), oFont, 200, 20, RGB(0,0,0), PAD_RIGHT, 0)
    oPrintPvt:SayAlign(nLinCab, 558,'%', oFont, 200, 20, RGB(0,0,0), PAD_LEFT, 0)

    nLinCab := nLinCab + 35
    
    oPrintPvt:Box(nLinCab,010,085,100, "-4")
    oPrintPvt:Say(nLinCab - 3,030,'PLACA',oFontSubN,620,,,2)  

    oPrintPvt:Box(nLinCab,100,085,325, "-2")
    oPrintPvt:Say(nLinCab - 3,220,'///////',oFontSubN,620,,,2) 

    oPrintPvt:Box(nLinCab,325,085,400, "-2")
    oPrintPvt:Say(nLinCab - 3,370,'////',oFontSubN,620,,,2) 

    oPrintPvt:Box(nLinCab,400,085,500, "-2")
    oPrintPvt:Say(nLinCab - 3,430,'VALOR',oFontSubN,620,,,2) 

    oPrintPvt:Box(nLinCab,500,085,570, "-2")
    oPrintPvt:Say(nLinCab - 3,505,'C.CUSTO',oFontSubN,620,,,2)
    
    nLinCab := nLinCab + 5
    nLinAtu := nLinCab

    // ***  FINAL CABEÇALHO

RETURN(NIL)

STATIC FUNCTION CABECRESCONT()

    // ***  INICIO CABEÇALHO
    nLinCab  := 25
    oPrintPvt:SayAlign(nLinCab, nColMeio-300, "RESUMO CO-PARTICIPAÇÃO EM SEGUROS DE CARGAS", oFontTit, 600, 20, RGB(0,0,0), PAD_CENTER, 0)

    nLinCab := nLinCab + 25
    
    oPrintPvt:SayAlign(nLinCab, 010,"DATA LOG", oFont, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
    oPrintPvt:SayAlign(nLinCab, 350,"CC 6110", oFont, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
    oPrintPvt:SayAlign(nLinCab, 300,TRANSFORM(nTotCC6110,"@E 9,999,999,999.99"), oFont, 200, 20, RGB(0,0,0), PAD_RIGHT, 0)
    oPrintPvt:SayAlign(nLinCab, 358,TRANSFORM(nPerCC6110,"@E 999.99"), oFont, 200, 20, RGB(0,0,0), PAD_RIGHT, 0)
    oPrintPvt:SayAlign(nLinCab, 558,'%', oFont, 200, 20, RGB(0,0,0), PAD_LEFT, 0)

    nLinCab := nLinCab + 15
    oPrintPvt:SayAlign(nLinCab, 10, DTOC(MV_PAR01), oFont, 1400, 20, RGB(0,0,0), PAD_LEFT, 0)
    oPrintPvt:SayAlign(nLinCab, 350,"CC 6210", oFont, 200, 20, RGB(0,0,0), PAD_LEFT, 0)
    oPrintPvt:SayAlign(nLinCab, 300,TRANSFORM(nTotCC6210,"@E 9,999,999,999.99"), oFont, 200, 20, RGB(0,0,0), PAD_RIGHT, 0)
    oPrintPvt:SayAlign(nLinCab, 358,TRANSFORM(nPerCC6210,"@E 999.99"), oFont, 200, 20, RGB(0,0,0), PAD_RIGHT, 0)
    oPrintPvt:SayAlign(nLinCab, 558,'%', oFont, 200, 20, RGB(0,0,0), PAD_LEFT, 0)

    nLinCab := nLinCab + 35
    
    oPrintPvt:Box(nLinCab,010,085,100, "-4")
    oPrintPvt:Say(nLinCab - 3,030,'COD',oFontSubN,620,,,2)  

    oPrintPvt:Box(nLinCab,100,085,325, "-2")
    oPrintPvt:Say(nLinCab - 3,150,'TRANSPORTADOR',oFontSubN,620,,,2) 

    oPrintPvt:Box(nLinCab,325,085,400, "-2")
    oPrintPvt:Say(nLinCab - 3,335,'NR ABAT',oFontSubN,620,,,2) 

    oPrintPvt:Box(nLinCab,400,085,500, "-2")
    oPrintPvt:Say(nLinCab - 3,430,'VALOR',oFontSubN,620,,,2) 

    oPrintPvt:Box(nLinCab,500,085,570, "-2")
    oPrintPvt:Say(nLinCab - 3,505,'C.CUSTO',oFontSubN,620,,,2)
    
    nLinCab := nLinCab + 5
    nLinAtu := nLinCab

    // ***  FINAL CABEÇALHO

RETURN(NIL)

STATIC FUNCTION CABECCONTABILIDADE()

    // ***  INICIO CABEÇALHO
    nLinCab  := 75
    oPrintPvt:SayAlign(nLinCab, nColMeio-280, "CO-PARTICIPAÇÃO EM CUSTOS DE SEGURO DE CARGA", oFontTit2, 600, 20, RGB(0,0,0), PAD_CENTER, 0)
    oPrintPvt:SayBitmap(nLinCab-50, 10, GetSrvProfString("Startpath","")+"adoro_2.bmp", 70, 70)

    nLinCab := nLinCab + 25
    oPrintPvt:Line(nLinCab, nColIni, nLinCab, nColFin, RGB(0,0,0), "01")
    
    nLinCab := nLinCab + 5
    nLinAtu := nLinCab

    // ***  FINAL CABEÇALHO

RETURN(NIL)


STATIC FUNCTION CALCCC()

    Local nTotal := 0

    nTotCC6110 := 0
    nPerCC6110 := 0
    nTotCC6210 := 0
    nPerCC6210 := 0
    nTotal     := 0
    
    SqlCC6110()
    While TRC->(!EOF())   

        nTotCC6110 := nTotCC6110 + TRC->F2_XVLCOPA

        TRC->(dbSkip())
                
    ENDDO
    TRC->(dbCloseArea())

    SqlCC6210()
    While TRD->(!EOF())   

        nTotCC6210 := nTotCC6210 + TRD->F2_XVLCOPA

        TRD->(dbSkip())
                
    ENDDO
    TRD->(dbCloseArea())
    
    nTotal := nTotCC6110 + nTotCC6210

    nPerCC6110 := (nTotCC6110 / nTotal) * 100
    nPerCC6210 := (nTotCC6210 / nTotal) * 100

RETURN()

Static Function SqlLogistica()

	Local cFilAtual := FWFILIAL("SF2")
    Local cDtIni    := DTOS(MV_PAR01)
    Local cDtFin    := DTOS(MV_PAR02)

	BeginSQL Alias "TRB"
			%NoPARSER%  
             SELECT F2_PLACA,
                    SUM(F2_XVLCOPA) AS F2_XVLCOPA,
                    CASE WHEN F2_EST = 'SP' THEN '6110' ELSE '6210' END AS F2_XCC
                FROM %Table:SF2%

                    //Everson - 22/06/2021. Chamado 15661.
                    INNER JOIN 
                    (
                        SELECT 
                        DISTINCT D2_FILIAL, D2_DOC, D2_SERIE 
                        FROM 
                        %Table:SD2%
                        INNER JOIN
                        %Table:SB1% ON
                        D2_COD = B1_COD
                        WHERE 
                        D2_FILIAL = %EXP:cFilAtual%
                        AND D2_TIPO <> 'D' 
                        AND D2_EMISSAO >= %EXP:cDtIni%
                        AND D2_EMISSAO <= %EXP:cDtFin%
                        AND B1_GRUPO NOT IN ('0911','0912','0913')
                        AND %Table:SD2%.D_E_L_E_T_ <> '*'
                        AND %Table:SB1%.D_E_L_E_T_ <> '*'
                    ) AS SD2 ON F2_FILIAL = SD2.D2_FILIAL AND F2_DOC = SD2.D2_DOC AND F2_SERIE = SD2.D2_SERIE
                    ////Fim - Everson - 22/06/2021. Chamado 15661.           

                WHERE F2_FILIAL   = %EXP:cFilAtual%
                  AND F2_EMISSAO >= %EXP:cDtIni%
                  AND F2_EMISSAO <= %EXP:cDtFin%
                  AND F2_PLACA   <> ''
                  AND F2_TPFRETE  = 'C'
                  AND F2_TIPO    <> 'D'
                  AND D_E_L_E_T_ <> '*'

                  AND F2_EST <> 'EX' //Everson - 22/06/2021 - Chamado 15661.

                GROUP BY F2_PLACA,CASE WHEN F2_EST = 'SP' THEN '6110' ELSE '6210' END

                ORDER BY F2_PLACA
			
	EndSQl             
RETURN(NIL)

Static Function SqlCC6110()

	Local cFilAtual := FWFILIAL("SF2")
    Local cDtIni    := DTOS(MV_PAR01)
    Local cDtFin    := DTOS(MV_PAR02)

	BeginSQL Alias "TRC"
			%NoPARSER%  
             SELECT SUM(F2_XVLCOPA) AS F2_XVLCOPA
                FROM %Table:SF2%

                    //Everson - 22/06/2021. Chamado 15661.
                    INNER JOIN 
                    (
                        SELECT 
                        DISTINCT D2_FILIAL, D2_DOC, D2_SERIE 
                        FROM 
                        %Table:SD2%
                        INNER JOIN
                        %Table:SB1% ON
                        D2_COD = B1_COD
                        WHERE 
                        D2_FILIAL = %EXP:cFilAtual%
                        AND D2_TIPO <> 'D' 
                        AND D2_EMISSAO >= %EXP:cDtIni%
                        AND D2_EMISSAO <= %EXP:cDtFin%
                        AND B1_GRUPO NOT IN ('0911','0912','0913')
                        AND %Table:SD2%.D_E_L_E_T_ <> '*'
                        AND %Table:SB1%.D_E_L_E_T_ <> '*'
                    ) AS SD2 ON F2_FILIAL = SD2.D2_FILIAL AND F2_DOC = SD2.D2_DOC AND F2_SERIE = SD2.D2_SERIE
                    ////Fim - Everson - 22/06/2021. Chamado 15661. 

                WHERE F2_FILIAL   = %EXP:cFilAtual%
                  AND F2_EMISSAO >= %EXP:cDtIni%
                  AND F2_EMISSAO <= %EXP:cDtFin%
                  AND F2_PLACA   <> ''
                  AND F2_EST      = 'SP'
                  AND F2_TPFRETE  = 'C'
                  AND F2_TIPO    <> 'D'
                  AND D_E_L_E_T_ <> '*'

                  AND F2_EST <> 'EX' //Everson - 22/06/2021 - Chamado 15661.

                GROUP BY F2_EST

                ORDER BY F2_EST
			
	EndSQl             
RETURN(NIL)

Static Function SqlCC6210()

	Local cFilAtual := FWFILIAL("SF2")
    Local cDtIni    := DTOS(MV_PAR01)
    Local cDtFin    := DTOS(MV_PAR02)

	BeginSQL Alias "TRD"
			%NoPARSER%  
             SELECT SUM(F2_XVLCOPA) AS F2_XVLCOPA
                FROM %Table:SF2%

                    //Everson - 22/06/2021. Chamado 15661.
                    INNER JOIN 
                    (
                        SELECT 
                        DISTINCT D2_FILIAL, D2_DOC, D2_SERIE 
                        FROM 
                        %Table:SD2%
                        INNER JOIN
                        %Table:SB1% ON
                        D2_COD = B1_COD
                        WHERE 
                        D2_FILIAL = %EXP:cFilAtual%
                        AND D2_TIPO <> 'D' 
                        AND D2_EMISSAO >= %EXP:cDtIni%
                        AND D2_EMISSAO <= %EXP:cDtFin%
                        AND B1_GRUPO NOT IN ('0911','0912','0913')
                        AND %Table:SD2%.D_E_L_E_T_ <> '*'
                        AND %Table:SB1%.D_E_L_E_T_ <> '*'
                    ) AS SD2 ON F2_FILIAL = SD2.D2_FILIAL AND F2_DOC = SD2.D2_DOC AND F2_SERIE = SD2.D2_SERIE
                    ////Fim - Everson - 22/06/2021. Chamado 15661. 

                WHERE F2_FILIAL   = %EXP:cFilAtual%
                  AND F2_EMISSAO >= %EXP:cDtIni%
                  AND F2_EMISSAO <= %EXP:cDtFin%
                  AND F2_PLACA   <> ''
                  AND F2_EST     <> 'SP'
                  AND F2_TPFRETE  = 'C'
                  AND F2_TIPO    <> 'D'
                  AND D_E_L_E_T_ <> '*'

                  AND F2_EST <> 'EX' //Everson - 22/06/2021 - Chamado 15661.

                GROUP BY F2_EST

                ORDER BY F2_EST
			
	EndSQl             
RETURN(NIL)

Static Function SqlTransportador()

	Local cFilAtual := FWFILIAL("SF2")
    Local cDtIni    := DTOS(MV_PAR01)
    Local cDtFin    := DTOS(MV_PAR02)

	BeginSQL Alias "TRE"
			%NoPARSER%  
            SELECT  F2_TRANSP,A4_NOME,A4_MUN,A4_EST
        FROM %Table:SF2%

            //Everson - 22/06/2021. Chamado 15661.
            INNER JOIN 
            (
                SELECT 
                DISTINCT D2_FILIAL, D2_DOC, D2_SERIE 
                FROM 
                %Table:SD2%
                INNER JOIN
                %Table:SB1% ON
                D2_COD = B1_COD
                WHERE 
                D2_FILIAL = %EXP:cFilAtual%
                AND D2_TIPO <> 'D' 
                AND D2_EMISSAO >= %EXP:cDtIni%
                AND D2_EMISSAO <= %EXP:cDtFin%
                AND B1_GRUPO NOT IN ('0911','0912','0913')
                AND %Table:SD2%.D_E_L_E_T_ <> '*'
                AND %Table:SB1%.D_E_L_E_T_ <> '*'
            ) AS SD2 ON F2_FILIAL = SD2.D2_FILIAL AND F2_DOC = SD2.D2_DOC AND F2_SERIE = SD2.D2_SERIE
            ////Fim - Everson - 22/06/2021. Chamado 15661. 

		INNER JOIN %Table:SA4%
		        ON A4_COD = F2_TRANSP
			   AND SA4010.D_E_L_E_T_ <> '*'
        WHERE F2_FILIAL     = %EXP:cFilAtual%
            AND F2_EMISSAO >= %EXP:cDtIni%
            AND F2_EMISSAO <= %EXP:cDtFin%
            AND F2_PLACA   <> ''
            AND F2_TPFRETE  = 'C'
            AND F2_TIPO    <> 'D'
            AND SF2010.D_E_L_E_T_ <> '*'

            AND F2_EST <> 'EX' //Everson - 22/06/2021 - Chamado 15661.

        GROUP BY F2_TRANSP,A4_NOME,A4_MUN,A4_EST

        ORDER BY F2_TRANSP
			
	EndSQl             
RETURN(NIL)

Static Function SqlCCCONT(cTransp)

	Local cFilAtual := FWFILIAL("SF2")
    Local cDtIni    := DTOS(MV_PAR01)
    Local cDtFin    := DTOS(MV_PAR02)

	BeginSQL Alias "TRF"
			%NoPARSER%
             SELECT DISTINCT CASE WHEN F2_EST = 'SP' THEN '6110' ELSE '6210' END AS F2_XCC,
                    F2_TRANSP,
                    SUM(F2_PLIQUI) AS F2_PLIQUI,
                    SUM(F2_PBRUTO) AS F2_PBRUTO,
                    SUM(F2_XVLCOPA) AS F2_XVLCOPA 
                FROM %Table:SF2%

                        //Everson - 22/06/2021. Chamado 15661.
                        INNER JOIN 
                        (
                            SELECT 
                            DISTINCT D2_FILIAL, D2_DOC, D2_SERIE 
                            FROM 
                            %Table:SD2%
                            INNER JOIN
                            %Table:SB1% ON
                            D2_COD = B1_COD
                            WHERE 
                            D2_FILIAL = %EXP:cFilAtual%
                            AND D2_TIPO <> 'D' 
                            AND D2_EMISSAO >= %EXP:cDtIni%
                            AND D2_EMISSAO <= %EXP:cDtFin%
                            AND B1_GRUPO NOT IN ('0911','0912','0913')
                            AND %Table:SD2%.D_E_L_E_T_ <> '*'
                            AND %Table:SB1%.D_E_L_E_T_ <> '*'
                        ) AS SD2 ON F2_FILIAL = SD2.D2_FILIAL AND F2_DOC = SD2.D2_DOC AND F2_SERIE = SD2.D2_SERIE
                        ////Fim - Everson - 22/06/2021. Chamado 15661. 

                WHERE F2_FILIAL             = %EXP:cFilAtual%
                AND F2_EMISSAO             >= %EXP:cDtIni%
                AND F2_EMISSAO             <= %EXP:cDtFin%
                AND F2_TRANSP               = %EXP:cTransp%
                AND F2_PLACA               <> ''
                AND F2_TPFRETE              = 'C'
                AND F2_TIPO                <> 'D'
                AND %Table:SF2%.D_E_L_E_T_ <> '*'

                AND F2_EST <> 'EX' //Everson - 22/06/2021 - Chamado 15661.

                GROUP BY F2_TRANSP,CASE WHEN F2_EST = 'SP' THEN '6110' ELSE '6210' END 

                ORDER BY CASE WHEN F2_EST = 'SP' THEN '6110' ELSE '6210' END 
             
	EndSQl             
RETURN(NIL)

Static Function SqlCONTAB1(cTransp)

	Local cFilAtual := FWFILIAL("SF2")
    Local cDtIni    := DTOS(MV_PAR01)
    Local cDtFin    := DTOS(MV_PAR02)
    
	BeginSQL Alias "TRG"
			%NoPARSER% 
             SELECT F2_EMISSAO,
                    F2_DOC,
                    F2_CLIENTE,
                    A1_NOME,
                    F2_VALBRUT,
                    F2_XVLCOPA
                    FROM %Table:SF2%

                        //Everson - 22/06/2021. Chamado 15661.
                        INNER JOIN 
                        (
                            SELECT 
                            DISTINCT D2_FILIAL, D2_DOC, D2_SERIE 
                            FROM 
                            %Table:SD2%
                            INNER JOIN
                            %Table:SB1% ON
                            D2_COD = B1_COD
                            WHERE 
                            D2_FILIAL = %EXP:cFilAtual%
                            AND D2_TIPO <> 'D' 
                            AND D2_EMISSAO >= %EXP:cDtIni%
                            AND D2_EMISSAO <= %EXP:cDtFin%
                            AND B1_GRUPO NOT IN ('0911','0912','0913')
                            AND %Table:SD2%.D_E_L_E_T_ <> '*'
                            AND %Table:SB1%.D_E_L_E_T_ <> '*'
                        ) AS SD2 ON F2_FILIAL = SD2.D2_FILIAL AND F2_DOC = SD2.D2_DOC AND F2_SERIE = SD2.D2_SERIE
                        ////Fim - Everson - 22/06/2021. Chamado 15661. 

                    INNER JOIN %Table:SA1%
                            ON A1_COD                  = F2_CLIENTE
                           AND A1_LOJA                 = F2_LOJA
                           AND %Table:SA1%.D_E_L_E_T_ <> '*'
                         WHERE F2_FILIAL               = %EXP:cFilAtual%
                           AND F2_EMISSAO             >= %EXP:cDtIni%
                           AND F2_EMISSAO             <= %EXP:cDtFin%
                           AND F2_TRANSP               = %EXP:cTransp%
                           AND F2_EST                  = 'SP'
                           AND F2_PLACA               <> ''
                           AND F2_TPFRETE              = 'C'
                           AND F2_TIPO                <> 'D'
                           AND %Table:SF2%.D_E_L_E_T_ <> '*'

                           AND F2_EST <> 'EX' //Everson - 22/06/2021 - Chamado 15661.

                    ORDER BY F2_DOC
	
	EndSQl             
RETURN(NIL)

Static Function SqlCONTAB2(cTransp)

	Local cFilAtual := FWFILIAL("SF2")
    Local cDtIni    := DTOS(MV_PAR01)
    Local cDtFin    := DTOS(MV_PAR02)
    
	BeginSQL Alias "TRG"
			%NoPARSER% 
             SELECT F2_EMISSAO,
                    F2_DOC,
                    F2_CLIENTE,
                    A1_NOME,
                    F2_VALBRUT,
                    F2_XVLCOPA
                    FROM %Table:SF2%

                        //Everson - 22/06/2021. Chamado 15661.
                        INNER JOIN 
                        (
                            SELECT 
                            DISTINCT D2_FILIAL, D2_DOC, D2_SERIE 
                            FROM 
                            %Table:SD2%
                            INNER JOIN
                            %Table:SB1% ON
                            D2_COD = B1_COD
                            WHERE 
                            D2_FILIAL = %EXP:cFilAtual%
                            AND D2_TIPO <> 'D' 
                            AND D2_EMISSAO >= %EXP:cDtIni%
                            AND D2_EMISSAO <= %EXP:cDtFin%
                            AND B1_GRUPO NOT IN ('0911','0912','0913')
                            AND %Table:SD2%.D_E_L_E_T_ <> '*'
                            AND %Table:SB1%.D_E_L_E_T_ <> '*'
                        ) AS SD2 ON F2_FILIAL = SD2.D2_FILIAL AND F2_DOC = SD2.D2_DOC AND F2_SERIE = SD2.D2_SERIE
                        ////Fim - Everson - 22/06/2021. Chamado 15661. 

                    INNER JOIN %Table:SA1%
                            ON A1_COD                  = F2_CLIENTE
                           AND A1_LOJA                 = F2_LOJA
                           AND %Table:SA1%.D_E_L_E_T_ <> '*'
                         WHERE F2_FILIAL               = %EXP:cFilAtual%
                           AND F2_EMISSAO             >= %EXP:cDtIni%
                           AND F2_EMISSAO             <= %EXP:cDtFin%
                           AND F2_TRANSP               = %EXP:cTransp%
                           AND F2_EST                 <> 'SP'
                           AND F2_PLACA               <> ''
                           AND F2_TPFRETE              = 'C'
                           AND F2_TIPO                <> 'D'
                           AND %Table:SF2%.D_E_L_E_T_ <> '*'

                           AND F2_EST <> 'EX' //Everson - 22/06/2021 - Chamado 15661.

                    ORDER BY F2_DOC
	
	EndSQl             
RETURN(NIL)

Static Function SqlRESCONT()

	Local cFilAtual := FWFILIAL("SF2")
    Local cDtIni    := DTOS(MV_PAR01)
    Local cDtFin    := DTOS(MV_PAR02)

	BeginSQL Alias "TRH"
			%NoPARSER%  
             SELECT F2_TRANSP,
                    A4_NOME,
                    SUM(F2_XVLCOPA) AS F2_XVLCOPA,
                    CASE WHEN F2_EST = 'SP' THEN '6110' ELSE '6210' END AS F2_XCC
            FROM %Table:SF2%

                //Everson - 22/06/2021. Chamado 15661.
                INNER JOIN 
                (
                    SELECT 
                    DISTINCT D2_FILIAL, D2_DOC, D2_SERIE 
                    FROM 
                    %Table:SD2%
                    INNER JOIN
                    %Table:SB1% ON
                    D2_COD = B1_COD
                    WHERE 
                    D2_FILIAL = %EXP:cFilAtual%
                    AND D2_TIPO <> 'D' 
                    AND D2_EMISSAO >= %EXP:cDtIni%
                    AND D2_EMISSAO <= %EXP:cDtFin%
                    AND B1_GRUPO NOT IN ('0911','0912','0913')
                    AND %Table:SD2%.D_E_L_E_T_ <> '*'
                    AND %Table:SB1%.D_E_L_E_T_ <> '*'
                ) AS SD2 ON F2_FILIAL = SD2.D2_FILIAL AND F2_DOC = SD2.D2_DOC AND F2_SERIE = SD2.D2_SERIE
                ////Fim - Everson - 22/06/2021. Chamado 15661. 

            LEFT JOIN %Table:SA4%
                    ON A4_COD = F2_TRANSP
                    AND %Table:SA4%.D_E_L_E_T_ <> '*'
                WHERE F2_FILIAL = %EXP:cFilAtual%
                AND F2_EMISSAO >= %EXP:cDtIni%
                AND F2_EMISSAO <= %EXP:cDtFin%
                AND F2_PLACA   <> ''
                AND F2_TPFRETE  = 'C'
                AND F2_TIPO    <> 'D'
                AND %Table:SF2%.D_E_L_E_T_ <> '*'

                AND F2_EST <> 'EX' //Everson - 22/06/2021 - Chamado 15661.

                GROUP BY F2_TRANSP,A4_NOME,CASE WHEN F2_EST = 'SP' THEN '6110' ELSE '6210' END

                ORDER BY F2_TRANSP
			
	EndSQl             
RETURN(NIL)
