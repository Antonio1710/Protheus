#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
 
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
 
/*/{Protheus.doc} User Function ADFIN096R
	Relatório de Fechamento de Perdas
	@type  Function
	@author William Costa
	@since 25/09/2020
	@version 01
    @history Ticket 425  - WILLIAM COSTA - 01/10/2020 - Adicionado pergunta de Data Base de Cálculo
    @history Ticket 2733 - WILLIAM COSTA - 14/10/2020 - Adicionado para gerar em excel
/*/

User Function ADFIN096R()

    Local aArea        := GetArea()
    Private cNomeRel   := "rel_perdas_"+dToS(Date())+StrTran(Time(), ':', '-')
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
    Private cPERG      := "ADFIN096R"
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
	Private cCadastro  := "Relatório de Fechamento de Perda"    
	Private nOpca	   := 0
    Private cDir       := ''
    Private nTotReg    := 0
    Private nCont      := 0
    Private cCnpjs     := ''
    Private nTotal     := 0
    PRIVATE oExcel     := FWMSEXCELEX():New()
	PRIVATE cArquivo    := 'REL_FECH_PERDA.XLS'
	PRIVATE oMsExcel
	PRIVATE cPlanilha   := "Fechamento de Perdas"
    PRIVATE cTitulo     := "Fechamento de Perdas"
	PRIVATE aLinhas     := {}

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatório de Fechamento de Perda')
    
    MontaPerg()

    AADD(aSays,"Este programa tem a finalidade de gerar um arquivo PDF " )
	AADD(aSays,"Relatório de Fechamento de Perda" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||GERAREL()},"Gerando arquivo PDF","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )

    RestArea(aArea)
    
RETURN(NIL)    

STATIC FUNCTION GERAREL()

    IF MV_PAR03 == 1

        GERAPDF()

    ELSE 

        RELEXCEL()

    ENDIF    

RETURN(NIL)

STATIC FUNCTION GERAPDF()

    //Criando o objeto de impressão
    cNomeRel           := "rel_perdas_"+dToS(Date())+StrTran(Time(), ':', '-')
    oPrintPvt          := FWMSPrinter():New(cNomeRel, IMP_PDF, .F., /*cStartPath*/, .T., , @oPrintPvt, , , , , .T.)
    oPrintPvt:cPathPDF := GetTempPath()
    oPrintPvt:SetResolution(72)
    oPrintPvt:SetPortrait()
    oPrintPvt:SetPaperSize(DMPAPER_A4)
    oPrintPvt:SetMargin(60, 60, 60, 60)
    oPrintPvt:StartPage()
    
    cCnpjs := '%' + BUSCAEMPRESAS() + '%'

    CABECPERDA()
    
    // ***  INICIO RELATORIO

    IF MV_PAR01 = 1

        SqlTitulo(cCnpjs)

    ELSEIF MV_PAR01 = 2

        SqlTitulo2(cCnpjs)

    ELSE

       SqlTitulo3(cCnpjs)

    ENDIF
    
    nTotReg := Contar("TRB","!Eof()")
    nCont   := 0
    ProcRegua(nTotReg)
    TRB->(DbGoTop())
    While TRB->(!EOF())   

        IF nLinAtu >= 810 // INICIA UMA NOVA PAGINA

            fImpRod()
            oPrintPvt:StartPage()
            CABECPERDA()

        ENDIF    

        nCont := nCont + 1

        IncProc("Gerando PDF Títulos: " + TRB->E1_NUM+'-'+SUBSTR(TRB->E1_NOMCLI,1,10) + ' ' + 'Total: ' + CVALTOCHAR(nCont) + '/' + CVALTOCHAR(nTotReg)) 

        oPrintPvt:SayAlign(nLinAtu, 012, TRB->E1_CLIENTE                                , oFont10, 200, 10, RGB(0,0,0), PAD_LEFT , 0)
        oPrintPvt:SayAlign(nLinAtu, 050, TRB->E1_LOJA                                   , oFont10, 200, 10, RGB(0,0,0), PAD_LEFT , 0)
        oPrintPvt:SayAlign(nLinAtu, 070, TRB->E1_NOMCLI                                 , oFont10, 200, 10, RGB(0,0,0), PAD_LEFT , 0)
        oPrintPvt:SayAlign(nLinAtu, 185, TRB->A1_CODRED                                 , oFont10, 200, 10, RGB(0,0,0), PAD_LEFT , 0)
        oPrintPvt:SayAlign(nLinAtu, 230, TRB->E1_NUM                                    , oFont10, 200, 10, RGB(0,0,0), PAD_LEFT , 0)
        oPrintPvt:SayAlign(nLinAtu, 120, TRANSFORM(TRB->E1_VALOR,"@E 9,999,999,999.99") , oFont10, 200, 10, RGB(0,0,0), PAD_RIGHT, 0)
        oPrintPvt:SayAlign(nLinAtu, 175, TRANSFORM(TRB->E1_SALDO,"@E 9,999,999,999.99") , oFont10, 200, 10, RGB(0,0,0), PAD_RIGHT, 0)
        oPrintPvt:SayAlign(nLinAtu, 390, DTOC(STOD(TRB->E1_EMISSAO))                    , oFont10, 200, 10, RGB(0,0,0), PAD_LEFT , 0)
        oPrintPvt:SayAlign(nLinAtu, 445, DTOC(STOD(TRB->E1_VENCREA))                    , oFont10, 200, 10, RGB(0,0,0), PAD_LEFT , 0)
        oPrintPvt:SayAlign(nLinAtu, 505, CVALTOCHAR(DATE() - STOD(TRB->E1_VENCREA))     , oFont10, 200, 10, RGB(0,0,0), PAD_LEFT , 0)
        oPrintPvt:SayAlign(nLinAtu, 540, TRB->E1_PORTADO                                , oFont10, 200, 10, RGB(0,0,0), PAD_LEFT , 0)

        nTotal  := nTotal  + TRB->E1_SALDO
        nLinAtu := nLinAtu + 15

        TRB->(dbSkip())
                
    ENDDO
    TRB->(dbCloseArea())

    IF nTotal > 0

        oPrintPvt:SayAlign(nLinAtu, 010, 'TOTAL GERAL:'                                    , oFontSubN, 200, 10, RGB(0,0,0), PAD_LEFT , 0)
        oPrintPvt:SayAlign(nLinAtu, 115, TRANSFORM(nTotal,"@E 9,999,999,999.99") , oFontSubN, 200, 10, RGB(0,0,0), PAD_LEFT, 0)

    ENDIF    

    // ***  FINAL RELATORIO
    
    //Impressão do Rodapé
    fImpRod()    
   
    //Gera o pdf para visualização
    oPrintPvt:Preview()
    FreeObj(oPrintPvt)
    oPrintPvt := Nil

RETURN(NIL)

STATIC FUNCTION CABECPERDA()

    Local cTitulo := ''

    // ***  INICIO CABEÇALHO

    IF MV_PAR01 = 1

        cTitulo := 'Até R$ 15 mil - Vencidos há mais de 180 dias'

    ELSEIF MV_PAR01 = 2

        cTitulo := 'Acima de R$ 15 mil, até R$ 100 mil - Vencidos há mais de um ano'

    ELSE

        cTitulo := 'Superior a R$ 100 mil - Vencidos há mais de um ano'

    ENDIF

    nLinCab  := 25

    oPrintPvt:SayAlign(nLinCab, nColMeio-300, "Relatório Fechamento de Perdas", oFontTit, 600, 20, RGB(0,0,0), PAD_CENTER, 0)

    nLinCab := nLinCab + 25

    oPrintPvt:Box(nLinCab,010,070,570, "-4")
    oPrintPvt:Say(nLinCab + 15,100,cTitulo,oFontSubN,620,,,2)  
    
    nLinCab := nLinCab + 35

    oPrintPvt:Box(nLinCab,010,070,040, "-4")
    oPrintPvt:Say(nLinCab - 3,015,'Cod',oFont10Neg,620,,,2)  

    oPrintPvt:Box(nLinCab,040,070,065, "-4")
    oPrintPvt:Say(nLinCab - 3,043,'Loja',oFont10Neg,620,,,2) 

    oPrintPvt:Box(nLinCab,065,070,180, "-4")
    oPrintPvt:Say(nLinCab - 3,105,'Nome',oFont10Neg,620,,,2) 

    oPrintPvt:Box(nLinCab,180,070,225, "-4")
    oPrintPvt:Say(nLinCab - 3,190,'Rede',oFont10Neg,620,,,2)

    oPrintPvt:Box(nLinCab,225,070,270, "-4")
    oPrintPvt:Say(nLinCab - 3,240,'Nota',oFont10Neg,620,,,2) 

    oPrintPvt:Box(nLinCab,270,070,325, "-4")
    oPrintPvt:Say(nLinCab - 3,290,'Valor',oFont10Neg,620,,,2) 

    oPrintPvt:Box(nLinCab,325,070,380, "-4")
    oPrintPvt:Say(nLinCab - 3,345,'Saldo',oFont10Neg,620,,,2)

    oPrintPvt:Box(nLinCab,380,070,435, "-4")
    oPrintPvt:Say(nLinCab - 3,390,'Emissão',oFont10Neg,620,,,2)

    oPrintPvt:Box(nLinCab,435,070,490, "-4")
    oPrintPvt:Say(nLinCab - 3,440,'Vencimento',oFont10Neg,620,,,2)

    oPrintPvt:Box(nLinCab,490,070,525, "-4")
    oPrintPvt:Say(nLinCab - 3,495,'Atraso',oFont10Neg,620,,,2)

    oPrintPvt:Box(nLinCab,525,070,570, "-4")
    oPrintPvt:Say(nLinCab - 3,530,'Portador',oFont10Neg,620,,,2)

    
    nLinCab := nLinCab + 5
    nLinAtu := nLinCab

    // ***  FINAL CABEÇALHO

RETURN(NIL)

Static Function fImpRod()

    Local nLinRod := nLinFin + 10
    Local cTexto  := ""
 
    //Linha Separatória
    oPrintPvt:Line(nLinRod, nColIni, nLinRod, nColFin, RGB(200, 200, 200))
    nLinRod += 3
     
    //Dados da Esquerda
    cTexto := "Relatório Fechamento de Perdas    |    " + DTOC(dDataBase) + "     " + cHoraEx + "     " + "ADFIN096R" + "     " + cUserName
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
	
	U_xPutSX1(cPerg,"01","Politica de Perdas   ? ","" ,"","mv_ch01","N",01,0,01,"C","","","","","MV_PAR01" ,"<15 mil 6 meses","<15 mil 6 meses","<15 mil 6 meses","","15|100 mil 1ano","15|100 mil 1ano","15|100 mil 1ano",">100 mil 1 ano",">100 mil 1 ano",">100 mil 1 ano","","","",""," ")
    U_xPutSx1(cPerg,'02','Data Base de Cálculo ?','','','mv_ch02','D',08,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR02')
    U_xPutSX1(cPerg,"03","Gerar Relatório em   ? ","" ,"","mv_ch03","N",01,0,01,"C","","","","","MV_PAR03" ,"PDF","PDF","PDF","","Excel","Excel","Excel","","","","","","",""," ")

    Pergunte(cPerg,.F.)
	
Return Nil   

STATIC FUNCTION BUSCAEMPRESAS()

    Local cCnpjsSM0 := ''
    Local aEmpresas := {}
    Local nContEmp  := 0

    aEmpresas := FWLoadSM0()

    FOR nContEmp := 1 TO LEN(aEmpresas)

        cCnpjsSM0 := cCnpjsSM0 + "'" + aEmpresas[nContEmp][18] + "',"

    NEXT    

    cCnpjsSM0 := SUBSTR(cCnpjsSM0,1,LEN(cCnpjsSM0) - 1)

RETURN(cCnpjsSM0)

STATIC FUNCTION RELEXCEL()

    BEGIN SEQUENCE
		
		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("Não Existe Excel Instalado")
            BREAK
        EndIF
		
		Cabec()             
		GeraExcel()
	          
		SalvaXml()
		CriaExcel()
	
	    MsgInfo("Arquivo Excel gerado!")    
	    
	END SEQUENCE

RETURN(NIL)

Static Function GeraExcel()

    Local cNomeRegiao := ''
	Local nLinha      := 0
	Local nExcel      := 0
	Local nTotLiq     := 0
	Local nTotPesol   := 0

    cCnpjs := '%' + BUSCAEMPRESAS() + '%'
	
	IF MV_PAR01 = 1

        SqlTitulo(cCnpjs)

    ELSEIF MV_PAR01 = 2

        SqlTitulo2(cCnpjs)

    ELSE

       SqlTitulo3(cCnpjs)

    ENDIF
    
    nTotReg := Contar("TRB","!Eof()")
    nLinha  := 0
    nTotal  := 0
    ProcRegua(nTotReg)
    TRB->(DbGoTop())
    While TRB->(!EOF())   
		
        nLinha  := nLinha + 1                                       

        IncProc("Gerando Excel Títulos: " + TRB->E1_NUM+'-'+SUBSTR(TRB->E1_NOMCLI,1,10) + ' ' + 'Total: ' + CVALTOCHAR(nLinha) + '/' + CVALTOCHAR(nTotReg)) 
    
        //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
        AADD(aLinhas,{ "", ; // 01 A  
                       "", ; // 02 B   
                       "", ; // 03 C  
                       "", ; // 04 D  
                       "", ; // 05 E  
                       "", ; // 06 F   
                       "", ; // 07 G 
                       "", ; // 08 H   
                       "", ; // 09 I  
                       "", ; // 10 J  
                       ""  ; // 11 K  
                           })
        //===================== FINAL CRIA VETOR COM POSICAO VAZIA
        
        //======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
        aLinhas[nLinha][01] := TRB->E1_CLIENTE //A
        aLinhas[nLinha][02] := TRB->E1_LOJA                                   //B
        aLinhas[nLinha][03] := TRB->E1_NOMCLI                                 //C
        aLinhas[nLinha][04] := TRB->A1_CODRED                                 //D
        aLinhas[nLinha][05] := TRB->E1_NUM                                    //E
        aLinhas[nLinha][06] := TRB->E1_VALOR //F
        aLinhas[nLinha][07] := TRB->E1_SALDO //G
        aLinhas[nLinha][08] := DTOC(STOD(TRB->E1_EMISSAO))                    //H
        aLinhas[nLinha][09] := DTOC(STOD(TRB->E1_VENCREA))                    //I
        aLinhas[nLinha][10] := DATE() - STOD(TRB->E1_VENCREA)     //J
        aLinhas[nLinha][11] := TRB->E1_PORTADO                                //K

        nTotal  := nTotal  + TRB->E1_SALDO
        
        //======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
            
        TRB->(dbSkip())    
    
    END //end do while TRB
    TRB->( DBCLOSEAREA() )   
    
    // *** INICIO MOSTRA TOTAL *** //
    
    nLinha  := nLinha + 1                                       
    
    //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
    AADD(aLinhas,{ "", ; // 01 A  
                    "", ; // 02 B   
                    "", ; // 03 C  
                    "", ; // 04 D  
                    "", ; // 05 E  
                    "", ; // 06 F   
                    "", ; // 07 G 
                    "", ; // 08 H   
                    "", ; // 09 I  
                    "", ; // 10 J  
                    ""  ; // 11 K  
                        })
    //===================== FINAL CRIA VETOR COM POSICAO VAZIA
    
    //======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
    aLinhas[nLinha][01] := 'TOTAL GERAL'                           //A
    aLinhas[nLinha][02] := nTotal //B
    aLinhas[nLinha][03] := ''                                      //C
    aLinhas[nLinha][04] := ''                                      //D
    aLinhas[nLinha][05] := ''                                      //E
    aLinhas[nLinha][06] := ''                                      //F
    aLinhas[nLinha][07] := ''                                      //G
    aLinhas[nLinha][08] := ''                                      //H
    aLinhas[nLinha][09] := ''                                      //I
    aLinhas[nLinha][10] := ''                                      //J
    aLinhas[nLinha][11] := ''                                      //K
    
    //======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================
    
    // *** FINAL MOSTRA TOTAL *** //
    
    //============================== INICIO IMPRIME LINHA NO EXCEL
    FOR nExcel := 1 TO nLinha
    oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],; // 01 A  
                                     aLinhas[nExcel][02],; // 02 B  
                                     aLinhas[nExcel][03],; // 03 C  
                                     aLinhas[nExcel][04],; // 04 D  
                                     aLinhas[nExcel][05],; // 05 E  
                                     aLinhas[nExcel][06],; // 06 F  
                                     aLinhas[nExcel][07],; // 07 G 
                                     aLinhas[nExcel][08],; // 08 H  
                                     aLinhas[nExcel][09],; // 09 I  
                                     aLinhas[nExcel][10],; // 10 J  
                                     aLinhas[nExcel][11] ; // 11 K  
                                                        }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
    NEXT 
    //============================== FINAL IMPRIME LINHA NO EXCEL
Return() 

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_FECH_PERDA.XLS")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_FECH_PERDA.XLS")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 

Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"Cod"         ,1,1) // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"Loja"        ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Nome "       ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"Rede "       ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"Nota"        ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"Valor"       ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"Saldo"       ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"Emissão"     ,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"Vencimento " ,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"Atraso "     ,1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"Portador"    ,1,1) // 11 K			

RETURN(NIL)

Static Function SqlTitulo(cCnpjs)

	BeginSQL Alias "TRB"
			%NoPARSER%  
             SELECT E1_CLIENTE,
                    E1_LOJA,
                    E1_NOMCLI,
                    A1_CODRED,
                    E1_NUM,
                    E1_VALOR,
                    E1_SALDO,
                    E1_EMISSAO,
                    E1_VENCREA,
                    E1_PORTADO
               FROM %TABLE:SE1%
               INNER JOIN %TABLE:SA1%
                      ON A1_COD                  = E1_CLIENTE
                     AND A1_LOJA                 = E1_LOJA
                     AND A1_CGC                 NOT IN (%EXP:cCnpjs%)
                     AND %TABLE:SA1%.D_E_L_E_T_ <> '*' 
                   WHERE E1_VENCREA              < %EXP:DTOS(MV_PAR02 -180)%
                     AND E1_TIPO                 = 'NF'
                     AND E1_SALDO                > 0
                     AND E1_SALDO               <= 15000
                     AND %TABLE:SE1%.D_E_L_E_T_ <> '*' 

                ORDER BY E1_CLIENTE,E1_LOJA
			
	EndSQl   
             
RETURN(NIL)

Static Function SqlTitulo2(cCnpjs)

	BeginSQL Alias "TRB"
			%NoPARSER%  
             SELECT E1_CLIENTE,
                    E1_LOJA,
                    E1_NOMCLI,
                    A1_CODRED,
                    E1_NUM,
                    E1_VALOR,
                    E1_SALDO,
                    E1_EMISSAO,
                    E1_VENCREA,
                    E1_PORTADO
               FROM %TABLE:SE1%
               INNER JOIN %TABLE:SA1%
                      ON A1_COD                  = E1_CLIENTE
                     AND A1_LOJA                 = E1_LOJA
                     AND A1_CGC                 NOT IN (%EXP:cCnpjs%)
                     AND %TABLE:SA1%.D_E_L_E_T_ <> '*' 
                   WHERE E1_VENCREA              < %EXP:DTOS(MV_PAR02 -365)%
                     AND E1_TIPO                 = 'NF'
                     AND E1_SALDO                > 15000
                     AND E1_SALDO               <= 100000
                     AND %TABLE:SE1%.D_E_L_E_T_ <> '*' 

                ORDER BY E1_CLIENTE,E1_LOJA
			
	EndSQl   
             
RETURN(NIL)

Static Function SqlTitulo3(cCnpjs)

	BeginSQL Alias "TRB"
			%NoPARSER%  
             SELECT E1_CLIENTE,
                    E1_LOJA,
                    E1_NOMCLI,
                    A1_CODRED,
                    E1_NUM,
                    E1_VALOR,
                    E1_SALDO,
                    E1_EMISSAO,
                    E1_VENCREA,
                    E1_PORTADO
               FROM %TABLE:SE1%
               INNER JOIN %TABLE:SA1%
                      ON A1_COD                  = E1_CLIENTE
                     AND A1_LOJA                 = E1_LOJA
                     AND A1_CGC                 NOT IN (%EXP:cCnpjs%)
                     AND %TABLE:SA1%.D_E_L_E_T_ <> '*' 
                   WHERE E1_VENCREA              < %EXP:DTOS(MV_PAR02 -365)% 
                     AND E1_TIPO                 = 'NF'
                     AND E1_SALDO                > 100000
                     AND %TABLE:SE1%.D_E_L_E_T_ <> '*' 

                ORDER BY E1_CLIENTE,E1_LOJA
			
	EndSQl   
             
RETURN(NIL)
