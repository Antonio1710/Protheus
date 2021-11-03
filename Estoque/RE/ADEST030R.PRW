#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "Fileio.ch"
#Include "Tbiconn.ch"
  
Static cTitulo      := "Custos de OP por Produto"

/*/{Protheus.doc} User Function ADEST030R()
    Relatorio de custos por produto
    @type  Function
    @author FWNM
    @since 28/05/2018
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history chamado 050729 - FWNM - 24/06/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE
    @history chamado 059683 - FWNM - 14/07/2020 - || OS 061157 || CONTROLADORIA || ANDRESSA || 998875717 || ADEST030R
    @hisotry chamado 44600  - Everson - 14/10/2021 - Removidos os includes não utilizados.
/*/
User Function ADEST030R()

    Local lOk		:= .F.
    Local alSay		:= {}
    Local alButton	:= {}
    Local clTitulo	:= 'Custos de OP por PRODUTO'
    Local clDesc1   := 'O objetivo desta rotina é gerar uma planilha em excel'
    Local clDesc2   := 'com a mesma lógica do relatório padrão MATR860, porém, '
    Local clDesc3   := 'aglutinando por produto acabado.'
    Local clDesc4   := ''
    Local clDesc5   := ''

    Private cPerg 		:= "ADMTR860"
    Private cArquivo

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de custos por produto')

    // Mensagens de Tela Inicial
    AADD(alSay, clDesc1)
    AADD(alSay, clDesc2)
    AADD(alSay, clDesc3)
    AADD(alSay, clDesc4)
    AADD(alSay, clDesc5)

    // Botoes do Formatch
    AADD(alButton, {1, .T., {|| lOk := .T., FechaBatch()}})
    AADD(alButton, {2, .T., {|| lOk := .F., FechaBatch()}})
    aAdd(alButton, {5, .T., {|| AcessaPar(cPerg, .t.) } } )

    FormBatch(clTitulo, alSay, alButton)

    If lOk
        Processa( { || RunMatr860() }, "Processando ..." )
    EndIf

Return

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 24/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function RunMatr860()

    Local cQuery  := ""
    Local cQuery2 := ""
    Local nOrdem  := 0 // chamado 059683 - FWNM - 14/07/2020 - || OS 061157 || CONTROLADORIA || ANDRESSA || 998875717 || ADEST030R

    Private nQtdeProd    := 0
    Private nTotQuantMod := 0
    Private nTotQuant    := 0
    Private nTotCusto    := 0
    Private nTotCustoMod := 0
    Private nCusto       := 0
    Private nQuant       := 0

    Pergunte(cPerg,.F.)

    // Executa Query para buscar dados que serão processados
    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    cQuery := " SELECT DISTINCT D3_COD "
    cQuery += " FROM " + RetSqlName("SD3") + " (NOLOCK) "
    cQuery += " WHERE D3_FILIAL='"+xFilial("SD3")+"' "
    cQuery += " AND D3_COD BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
    cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par03)+"' AND '"+DtoS(mv_par04)+"' "
    cQuery += " AND D3_CF = 'PR0' "
    cQuery += " AND D3_OP <> '' "
    cQuery += " AND D3_ESTORNO <> 'S' "
    cQuery += " AND D_E_L_E_T_='' "

    tcQuery cQuery New Alias "Work"

    // Cria arquivo temporario
    CriaTMP()

    ProcRegua( Work->( RecCount() ) )

    Work->( dbGoTop() )
    Do While Work->( !EOF() )
        
        //IncProc(AllTrim(Work->D3_COD))
        
        // OPs das producoes
        If Select("Work2") > 0
            Work2->( dbCloseArea() )
        EndIf
        
        cQuery2 := " SELECT D3_OP "
        cQuery2 += " FROM " + RetSqlName("SD3") + " (NOLOCK) "
        cQuery2 += " WHERE D3_FILIAL='"+xFilial("SD3")+"' "
        cQuery2 += " AND D3_COD = '"+Work->D3_COD+"' "
        cQuery2 += " AND D3_EMISSAO BETWEEN '"+DtoS(mv_par03)+"' AND '"+DtoS(mv_par04)+"' "
        cQuery2 += " AND D3_CF = 'PR0' "
        cQuery2 += " AND D3_OP <> '' "
        cQuery2 += " AND D3_ESTORNO <> 'S' "
        cQuery2 += " AND D_E_L_E_T_='' "
        
        tcQuery cQuery2 New Alias "Work2"
        
        Work2->( dbGoTop() )
        Do While Work2->( !EOF() )
        
            //IncProc(AllTrim(Work2->D3_OP) + "/" + AllTrim(Work->D3_COD))

            // Insumos
            SD3->( dbSetOrder(1) ) // D3_FILIAL+D3_OP+D3_COD+D3_LOCAL
            If SD3->( dbSeek(xFilial("SD3")+Work2->D3_OP) )
            
                Do While SD3->( !EOF() ) .and. SD3->D3_FILIAL == xFilial("SD3") .and. SD3->D3_OP == Work2->D3_OP
                    
                    IncProc(AllTrim(Work->D3_COD) + "/" + AllTrim(SD3->D3_OP) + "/" + AllTrim(SD3->D3_COD))

                    // Início dos cálculos e gravações
                
                    nCusto := SD3->D3_CUSTO1
                    nQuant := SD3->D3_QUANT
                    
                    If !IsProdMod(SD3->D3_COD)
                        nTotQuant += IIf( SubStr(SD3->D3_CF,1,2) == "RE", nQuant, 0 )
                        nTotQuant += IIf( SubStr(SD3->D3_CF,1,2) == "DE", ( -nQuant ), 0 )
                        
                        If SubStr(SD3->D3_CF,3,1) # "9"
                            nTotCusto += IIf( SubStr(SD3->D3_CF,1,2) == "RE", nCusto, 0 )
                            nTotCusto += IIf( SubStr(SD3->D3_CF,1,2) == "DE", ( -nCusto ), 0 )
                        EndIf
                        
                    Else
                        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                        //³ Totaliza‡„o separada para a m„o-de-obra                  ³
                        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                        nTotQuantMod += IIf( SubStr(SD3->D3_CF,1,2) == "RE", nQuant, 0 )
                        nTotQuantMod += IIf( SubStr(SD3->D3_CF,1,2) == "DE", ( -nQuant ), 0 )
                        
                        If SubStr(SD3->D3_CF,3,1) # "9"
                            nTotCustoMod += IIf( SubStr(SD3->D3_CF,1,2) == "RE", nCusto, 0 )
                            nTotCustoMod += IIf( SubStr(SD3->D3_CF,1,2) == "DE", ( -nCusto ), 0 )
                        EndIf
                        
                    EndIf
                    
                    nQtdeProd += IIf( SubStr(SD3->D3_CF,1,2) == "PR", nQuant , 0 )
                    nQtdeProd += IIf( SubStr(SD3->D3_CF,1,2) == "ER", ( -nQuant ) , 0 )
                    
                    
                    // Popula arquivo temporário
                    nOrdem++
                    GrvTMP(nOrdem)

                
                    SD3->( dbSkip() )
                    
                EndDo
            
                Work2->( dbSkip() )
            
            EndIf
        
        EndDo
                            
        // Insere uma linha em branco
        nOrdem++
        RecLock(cArquivo, .t.)
            (cArquivo)->ORDEM := AllTrim(StrZero(nOrdem,6)) // chamado 059683 - FWNM - 14/07/2020 - || OS 061157 || CONTROLADORIA || ANDRESSA || 998875717 || ADEST030R
        (cArquivo)->( msUnLock() )
        
        Work->( dbSkip() )
        
    EndDo

    // Fecha arquivos temporarios
    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    If Select("Work2") > 0
        Work2->( dbCloseArea() )
    EndIf

    // Sintetico
    If MV_PAR06 == 2 // Sintetico
        AjustaTRB()
    EndIf

    // Gero XLS
    GeraXLS()

Return

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 24/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GeraXLS()

    Local oExcel    := FWMsExcelEx():New()
    Local cPath		:= AllTrim(MV_PAR05)
    Local aAreaAtu  := GetArea()
    Local nLinha    := 0
    Local nExcel    := 1

    Private cArqXLS   := "CMP.XLS"
    Private aLinhas   := {}

    cIniFile   := GetAdv97()
    cRootPath  := GetPvProfString(GetEnvServer(),"RootPath","ERROR", cIniFile )
    cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )

    cPathData := cRootPath+"\CMP\"

    dbSelectArea(cArquivo)
    //(cArquivo)->( dbCloseArea() )

    If !ExistDir(cPathData)
        MakeDir(cPathData)
    EndIf

    If !ExistDir(cPath)
        MakeDir(cPath)
    EndIf

    If Right(AllTrim(cPath),1) <> "\"
        cPath := cPath + "\"
    EndIf

    fErase( cPath+"CMP\CMP.XLS" )
    fErase( cRootPath+"\CMP\CMP.XLS" )
    fErase("\CMP\CMP.XLS")
    fErase( cPath+cArqXLS )

    // Copio arquivo tmp para pasta LFV abaixo do rootpath já renomeando
    //__CopyFile(cStartPath+cArquivo+GetDBExtension(), "\CMP\CMP.XLS" )

    lExcel := .f.

    // Cabecalho Excel
    oExcel:AddworkSheet(cArqXLS)
	oExcel:AddTable (cArqXLS,cTitulo)
    oExcel:AddColumn(cArqXLS,cTitulo,"PRODPAI"         ,1,1) // 01 A
	oExcel:AddColumn(cArqXLS,cTitulo,"PRODUTO"         ,1,1) // 02 B
	oExcel:AddColumn(cArqXLS,cTitulo,"DESCRICAO"       ,1,1) // 03 C
	oExcel:AddColumn(cArqXLS,cTitulo,"MOV"             ,1,1) // 04 D
	oExcel:AddColumn(cArqXLS,cTitulo,"QUANTIDADE"      ,1,1) // 05 E
	oExcel:AddColumn(cArqXLS,cTitulo,"UM"              ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"CUSTO_UNIT"      ,1,1) // 07 G
	oExcel:AddColumn(cArqXLS,cTitulo,"CUSTO_TOT"       ,1,1) // 08 H
	oExcel:AddColumn(cArqXLS,cTitulo,"OPS"             ,1,1) // 09 I

    // Gera Excel
    (cArquivo)->( dbSetOrder(2) )
    (cArquivo)->( dbGoTop() )
    Do While (cArquivo)->( !EOF() )

    	nLinha++

	   	aAdd(aLinhas,{ "", ; // 01 A  
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	               "", ; // 07 G 
	   	               "", ; // 08 H   
	   	               ""  ; // 09 I  
	   	                   })

		aLinhas[nLinha][01] := (cArquivo)->PRODPAI     //A
		aLinhas[nLinha][02] := (cArquivo)->PRODUTO     //B
		aLinhas[nLinha][03] := (cArquivo)->DESCRICAO   //C
		aLinhas[nLinha][04] := (cArquivo)->MOV         //D
		aLinhas[nLinha][05] := (cArquivo)->QUANTIDADE  //E
		aLinhas[nLinha][06] := (cArquivo)->UM          //F
		aLinhas[nLinha][07] := (cArquivo)->CUSTO_UNIT  //G
		aLinhas[nLinha][08] := (cArquivo)->CUSTO_TOT   //H
		aLinhas[nLinha][09] := (cArquivo)->OPS         //I

        (cArquivo)->( dbSkip() )

    EndDo

	// IMPRIME LINHA NO EXCEL
	For nExcel := 1 to nLinha
       	oExcel:AddRow(cArqXLS,cTitulo,{aLinhas[nExcel][01],; // 01 A  
	                                     aLinhas[nExcel][02],; // 02 B  
	                                     aLinhas[nExcel][03],; // 03 C  
	                                     aLinhas[nExcel][04],; // 04 D  
	                                     aLinhas[nExcel][05],; // 05 E  
	                                     aLinhas[nExcel][06],; // 06 F  
	                                     aLinhas[nExcel][07],; // 07 G 
	                                     aLinhas[nExcel][08],; // 08 H  
	                                     aLinhas[nExcel][09] ; // 09 I  
	                                                        }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
    Next nExcel 

    oExcel:Activate()
	oExcel:GetXMLFile(cPath + cArqXLS) // chamado 059683 - FWNM - 14/07/2020 - || OS 061157 || CONTROLADORIA || ANDRESSA || 998875717 || ADEST030R
	//oExcel:GetXMLFile(cPath + cArquivo)
    lExcel := .t.

    /*
    If CpyS2T( cStartPath+cArquivo+GetDBExtension(), cPath, .T. )
        
        lExcel := .t.
        fRename( cPath+cArquivo+GetDBExtension(), cPath+cArqXLS )
        
    Else
        
        // Aviso ao usuario
        Aviso(	"ADMATR860-01",;
        "Cópia do arquivo falhou! O arquivo XLS será enviado por email..." + chr(13) + chr(10)+;
        ""  + chr(13) + chr(10) +;
        "" ,;
        { "&OK" },,;
        "Projetos - Investimentos" )
        
        fRename( cStartPath+(_cArqTMP)+".DBF", cStartPath+cArqXLS )
        
        // Enviar email
        EmailFVL()
        
    EndIf
    */

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Deleta arquivo de Trabalho                                   ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    fErase( cArquivo+GetDBExtension() )
    fErase( cArquivo+OrdBagExt() )

    If lExcel

        msgInfo("Arquivo " + cArqXLS + " gerado com sucesso no path: " + MV_PAR05)
        
        If msgYesNo("Deseja abrí-lo agora?")
            
            // Abre Excel
            If ! ApOleClient( 'MsExcel' )
                MsgStop( 'Excel não instalado! Abra o arquivo manualmente no diretório:' + cPath )
                Return
            EndIf
            
            oExcelApp := MsExcel():New()
            oExcelApp:WorkBooks:Open( cPath+cArqXLS ) // Abre uma planilha
            oExcelApp:SetVisible(.T.)
            
        EndIf
        
    EndIf

Return

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 24/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function AcessaPar(cPerg,lOk)

    If Pergunte(cPerg)
        lOk := .T.
    Endif

Return(lOk)

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 24/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function EmailFVL()

    Private cDescri := "Custo Médio - por Produto"

    LogZBN("1")

    ProcRel()

    LogZBN("2")


Return

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 24/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function procRel()

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Declaração de variávies.
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Local aArea		:= GetArea()
    Local cAssunto	:= cDescri
    Local cMensagem	:= ""
    Local cQuery	:= ""

    //Private cMails  := GetMV("MV_#PRJMAI",,"fwnmacieira@gmail.com") // -------- APENAS DEBUG
    Private cMails  := GetMV("MV_#CMPMAI",,"danielle.meira@adoro.com.br") // -------- VOLTAR ESTA LINHA ANTES DE PUBLICAR EM PRD

    //
    cMensagem += '<html>'
    cMensagem += '<body>'
    cMensagem += '<p style="color:red">'+cValToChar(cDescri)+'</p>'
    cMensagem += '<hr>'
    cMensagem += '<table border="1">'
    cMensagem += '<tr style="background-color: black;color:white">'
    cMensagem += '</tr>'

    cMensagem += '</table>'
    cMensagem += '</body>'
    cMensagem += '</html>'

    //
    ProcessarEmail(cAssunto,cMensagem,cMails)

    //
    RestArea(aArea)

Return Nil

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 24/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ProcessarEmail(cAssunto,cMensagem,email)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Declaração de variávies.
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Local aArea			:= GetArea()
    Local lOk           := .T.
    Local cBody         := cMensagem
    Local cErrorMsg     := ""
    Local aFiles        := {}
    Local cServer       := Alltrim(GetMv("MV_RELSERV"))
    Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
    Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
    Local cFrom         := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
    Local cTo           := email
    Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)
    Local lAutOk        := .F.
    Local cAtach        := cStartPath+cArqXLS //"system\EXPPROJ.XLS"
    Local cSubject      := ""

    //Assunto do e-mail.
    cSubject := cAssunto

    //Conecta ao servidor SMTP.
    Connect Smtp Server cServer Account cAccount  Password cPassword Result lOk

    //
    If !lAutOk
        If ( lSmtpAuth )
            lAutOk := MailAuth(cAccount,cPassword)
        Else
            lAutOk := .T.
        EndIf
    EndIf

    //
    If lOk .And. lAutOk
        
        //Envia o e-mail.
        Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk
        
        //Tratamento de erro no envio do e-mail.
        If !lOk
            Get Mail Error cErrorMsg
            ConOut("3 - " + cErrorMsg)
        Else
            // Aviso ao usuario
            Aviso(	"ADMATR860-02",;
            "Email enviado com sucesso!"  + chr(13) + chr(10)+;
            "Emails: "  + Left(cMails,66) + chr(13) + chr(10) +;
            "" + Subs(cMails,67,Len(cMails)),;
            { "&OK" },3,;
            "Projetos - Investimentos" )
        EndIf
        
    Else
        Get Mail Error cErrorMsg
        ConOut("4 - " + cErrorMsg)
    EndIf

    If lOk
        Disconnect Smtp Server
    EndIf

    //
    RestArea(aArea)

Return Nil

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 24/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function logZBN(cStatus)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Declaração de variávies.
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Local aArea	:= GetArea()
    Local cNomeRotina := "ADMATR860"

    DbSelectArea("ZBN")
    ZBN->(DbSetOrder(1))
    ZBN->(DbGoTop())
    If ZBN->(DbSeek(xFilial("ZBN") + cNomeRotina))
        
        RecLock("ZBN",.F.)
            ZBN_FILIAL  := xFilial("ZBN")
            ZBN_DATA    := Date()
            ZBN_HORA    := cValToChar(Time())
            ZBN_ROTINA	:= cNomeRotina
            ZBN_DESCRI  := cDescri
            ZBN_STATUS	:= cStatus
        ZBN->( msUnlock() )
        
    Else
        
        RecLock("ZBN",.T.)
            ZBN_FILIAL  := xFilial("ZBN")
            ZBN_DATA    := Date()
            ZBN_HORA    := cValToChar(Time())
            ZBN_ROTINA	:= cNomeRotina
            ZBN_DESCRI  := cDescri
            ZBN_STATUS	:= cStatus
        ZBN->( msUnlock() )
        
    EndIf

    If Select("ZBN") > 0
        ZBN->(dbCloseArea())
    EndIf

    //
    RestArea(aArea)

Return Nil

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 24/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function AjustaTRB()

    (cArquivo)->( dbGoTop() )

    Do While (cArquivo)->( !EOF() )

        If Left(AllTrim((cArquivo)->MOV),2) <> "PR"
            RecLock((cArquivo), .f.)  
                (cArquivo)->( dbDelete() )
            (cArquivo)->( msUnLock() )
        EndIf
        
        (cArquivo)->( dbSkip() )

    EndDo

Return

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 24/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function CriaTMP()

    Local cDirDocs  := MsDocPath()
    Local aStru		:= {}

    cArquivo  := CriaTrab(,.F.)

    // chamado 059683 - FWNM - 14/07/2020 - || OS 061157 || CONTROLADORIA || ANDRESSA || 998875717 || ADEST030R
    //Definir indices da tabela	
	cIndice1 := Alltrim(CriaTrab(,.F.))
	cIndice2 := Alltrim(CriaTrab(,.F.))

	cIndice1 := Left(cIndice1,5)+Right(cIndice1,2)+"A"
	cIndice2 := Left(cIndice2,5)+Right(cIndice2,2)+"B"

	If File(cIndice1+OrdBagExt())
		FErase(cIndice1+OrdBagExt())
	EndIf

	If File(cIndice2+OrdBagExt())
		FErase(cIndice2+OrdBagExt())
	EndIf
    //

    aStru := {	{"ORDEM"       , "C", 6,      0},;
                {"PRODPAI"     , "C", TamSX3("B1_COD")[1],      0},;
                {"PRODUTO"     , "C", TamSX3("B1_COD")[1],      0},;
                {"DESCRICAO"   , "C", TamSX3("B1_DESC")[1],   0},;
                {"MOV"         , "C", TamSX3("D3_CF")[1],   0},;
                {"QUANTIDADE"  , "N", TamSX3("D3_QUANT")[1],  TamSX3("D3_QUANT")[2]},;
                {"UM"          , "C", TamSX3("D3_CF")[1],  0},;
                {"CUSTO_UNIT"  , "N", TamSX3("D3_CUSTO1")[1],    TamSX3("D3_CUSTO1")[2]},;
                {"CUSTO_TOT"   , "N", TamSX3("D3_CUSTO1")[1],    TamSX3("D3_CUSTO1")[2]},;
                {"OPS"         , "C", 254,    0} }

    dbCreate(cArquivo,aStru)
    dbUseArea(.T.,,cArquivo,cArquivo,.F.,.F.)

	/*Criar indice*/
    IndRegua(cArquivo,cIndice1,"PRODPAI+PRODUTO+MOV",,"","")     //"Selecionando Registros..."  // FWNM - CUSTOM ADORO
    // chamado 059683 - FWNM - 14/07/2020 - || OS 061157 || CONTROLADORIA || ANDRESSA || 998875717 || ADEST030R
    IndRegua(cArquivo,cIndice2,"ORDEM",,"","")                   //"Selecionando Registros..."  // FWNM - CUSTOM ADORO // 

    dbClearIndex()
	
    dbSetIndex(cIndice1+OrdBagExt())
	dbSetIndex(cIndice2+OrdBagExt())
    //

Return

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 24/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GrvTMP(nOrdem)

    Local lLock     := .t.

    (cArquivo)->( dbSetOrder(1)) // chamado 059683 - FWNM - 14/07/2020 - || OS 061157 || CONTROLADORIA || ANDRESSA || 998875717 || ADEST030R
    (cArquivo)->( dbGoTop() )
    If (cArquivo)->( dbSeek(Work->D3_COD+SD3->D3_COD+SD3->D3_CF) ) // PROD+MOV
        lLock := .f.
    EndIf

    RecLock(cArquivo, lLock)

        (cArquivo)->PRODPAI   := Work->D3_COD
        (cArquivo)->PRODUTO   := SD3->D3_COD
        (cArquivo)->DESCRICAO := AllTrim(Posicione("SB1",1,xFilial("SB1")+SD3->D3_COD,"B1_DESC"))
        (cArquivo)->MOV       := SD3->D3_CF
        (cArquivo)->UM        := SD3->D3_UM

        If lLock

            (cArquivo)->ORDEM := AllTrim(StrZero(nOrdem,6)) // chamado 059683 - FWNM - 14/07/2020 - || OS 061157 || CONTROLADORIA || ANDRESSA || 998875717 || ADEST030R

            // INCLUSAO
            If SubStr(SD3->D3_CF,1,2) == "DE"
                (cArquivo)->QUANTIDADE := ( -SD3->D3_QUANT )
                (cArquivo)->CUSTO_UNIT := ( nCusto/SD3->D3_QUANT )
                (cArquivo)->CUSTO_TOT  := ( -nCusto )
            Else
                (cArquivo)->QUANTIDADE := SD3->D3_QUANT
                (cArquivo)->CUSTO_UNIT := ( nCusto/SD3->D3_QUANT )
                (cArquivo)->CUSTO_TOT  := nCusto
            EndIf

            (cArquivo)->OPS            := Left(AllTrim(SD3->D3_OP),6)	

        Else

            // ALTERACAO
            If SubStr(SD3->D3_CF,1,2) == "DE"
                (cArquivo)->QUANTIDADE += ( -SD3->D3_QUANT )
                (cArquivo)->CUSTO_UNIT += ( nCusto/SD3->D3_QUANT )
                (cArquivo)->CUSTO_TOT  += ( -nCusto )
            Else
                (cArquivo)->QUANTIDADE += SD3->D3_QUANT
                (cArquivo)->CUSTO_UNIT += ( nCusto/SD3->D3_QUANT )
                (cArquivo)->CUSTO_TOT  += nCusto
            EndIf

            (cArquivo)->OPS        += "/" + Left(AllTrim(SD3->D3_OP),6)	

        EndIf

    (cArquivo)->( msUnLock() )

Return
