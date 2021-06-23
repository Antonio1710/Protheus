#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "REPORT.CH"

/*/{Protheus.doc} User Function GP660ROT
    Ponto de entrada p/ inclusao de novas opcoes em aRotina - Cadastro de Movimentação de Títulos.
    @type  Function
    @author Fernando Macieira
    @since 26/04/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @ticket 11556 - Processo Trabalhista - Títulos
    @history ticket 11556 - Fernando Macieira - 29/04/2021 - Processo Trabalhista - Títulos (Consistência filial origem)
    @history ticket 11556 - Fernando Macieira - 29/04/2021 - Processo Trabalhista - Títulos (Consulta Aprovação)
/*/
User Function GP660ROT()

    Local aArea   := GetArea()
    Local aRotina := ParamixB[1]
    
    aAdd( aRotina, { "* Importa XLS"        , "u_GeraRC1()", 0, 5, , .F. } )
    aAdd( aRotina, { "* Consulta Aprovação" , "u_ADFIN061P(RC1->RC1_FILTIT, RC1->RC1_FORNECE, RC1->RC1_LOJA, RC1->RC1_PREFIX, RC1->RC1_NUMTIT, RC1->RC1_PARC, RC1->RC1_TIPO)", 0, 6, , .F. } ) // @history ticket 11556 - Fernando Macieira - 05/05/2021 - Processo Trabalhista - Títulos (Consulta Aprovação)
    //aAdd( aRotina, { "* Consulta Aprovação" , "u_ADFIN061P(RC1->RC1_FILIAL, RC1->RC1_FORNECE, RC1->RC1_LOJA, RC1->RC1_PREFIX, RC1->RC1_NUMTIT, RC1->RC1_PARC, RC1->RC1_TIPO)", 0, 6, , .F. } ) // @history ticket 11556 - Fernando Macieira - 29/04/2021 - Processo Trabalhista - Títulos (Consulta Aprovação)

    RestArea(aArea)
    
Return aRotina

/*/{Protheus.doc} User Function GERARC1
    Insere títulos de acordos trabalhistas na tabela RC1 a partir de um XLS
    @type  Function
    @author Fernando Macieira
    @since 23/04/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @ticket 11556 - Processo Trabalhista - Títulos
/*/
User Function GERARC1()

    Local lOk		:= .F.
    Local alSay		:= {}
    Local alButton	:= {}
    Local clTitulo	:= 'IMPORTAÇÃO TITULOS TRABALHISTAS'
    Local clDesc1   := 'O objetivo desta rotina é gerar títulos trabalhistas'
    Local clDesc2   := 'na tabela RC1 a partir de um XLS'
    Local clDesc3   := ''
    Local clDesc4   := '( Necessário converter, previamente, esta planilha em arquivo CSV = Separado por ";" )'
    Local clDesc5   := ''

	Private cAliasTRB := ""

    // Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 29/06/2020
    If !LockByName("GERARC1", .T., .F.)
        Alert("[GERARC1] - Existe outro processamento sendo executado! Verifique...")
        Return
    EndIf

    // Mensagens de Tela Inicial
    aAdd(alSay, clDesc1)
    aAdd(alSay, clDesc2)
    aAdd(alSay, clDesc3)
    aAdd(alSay, clDesc4)
    aAdd(alSay, clDesc5)

    // Botoes do Formatch
    aAdd(alButton, {1, .T., {|| lOk := .T., FechaBatch()}})
    aAdd(alButton, {2, .T., {|| lOk := .F., FechaBatch()}})

    FormBatch(clTitulo, alSay, alButton)

    If lOk
        Processa( { || RunIMPRC1() }, "Gerando títulos acordos trabalhistas..." )
    EndIf

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
    //³Destrava a rotina para o usuário	    ?
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
    UnLockByName("GERARC1")

Return

/*/{Protheus.doc} Static Function RunIMPRC1
    (long_description)
    @type  Static Function
    @author FWNM
    @since 23/04/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function RunIMPRC1()

    Local lFile     := .f.
    Local nlCont    := 0
    Local nCount    := 0
    Local aDadRC1   := {}
    Local aCampos   := {}
    Local lYesNo    := .f.

    Private cTxt        := ""
    Private cRC1_NUMTIT := ""
    Private nLinha      := 0

    cFile := cGetFile("Arquivos CSV (Separados por Vírgula) | *.CSV",;
    ("Selecione o diretorio onde encontra-se o arquivo a ser processado"), 0, "Servidor\", .t., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE)// + GETF_RETDIRECTORY)

    If At(".CSV", upper(cFile)) > 0
        lFile := .t.
        ft_fUse(cFile)
    Else
        Aviso("GERARC1-01", "Não foi possível abrir o arquivo...", {"&Ok"},, "Arquivo não identificado!")
    EndIf

    // Arquivo TXT
    If lFile
        
        ft_fGoTop()
        
        cVerTab := "Filial;Integ Financ;Num Titulo;Cod Titulo;Descr Titulo;Prefixo Tit;Vlr Titulo;Data Emissão;Data Vencto;Dt Venc Real;Tipo Titulo;Cod Natur;Cod Fornec;Loja Fornec;Dt Busca Ini;Dt Busca Fim;Centro Custo;Matricula;Parcela;Tipo Desp;Desc Despesa;Cod Retencao;Nro Tit Exl;Banco;Agencia;Dig Agencia;C Corrente;Dig Conta;Nome Benefic;CNPJ/CPF;Ar Lin Neg;Fl Centro"
        
        cTxt := AllTrim( ft_fReadLn() )
        
        If cVerTab <> cTXT
            
            Aviso("GERARC1-02", "A importação não será realizada! As colunas do excel precisam ser " + cVerTab, {"&Ok"},, "Versão/Leiaute da planilha incorreta!")
            
        Else
                    
            ft_fSkip() // Pula linha do cabeçalho
            
            If Select("TRB") > 0
                TRB->( dbCloseArea() )
            EndIf
                
            // Crio TRB para impressão
            // https://tdn.totvs.com.br/display/framework/FWTemporaryTable
            oTempTable := FWTemporaryTable():New("TRB")
            
            // Arquivo TRB - CONSISTÊNCIAS
            aAdd( aCampos, {'NUMLINHA'   ,"C"    ,10 , 0} )
            aAdd( aCampos, {'STATUS'     ,"C"    ,100, 0} )
            aAdd( aCampos, {'LINHA'      ,"C"    ,254, 0} )
            aAdd( aCampos, {'VALOR'      ,"N"    ,14 , 2} )
            aAdd( aCampos, {'TITULO'     ,"C"    ,9  , 0} )

            oTempTable:SetFields(aCampos)
            oTempTable:AddIndex("01", {"TITULO"} )
            oTempTable:Create()

            ProcRegua(0)

            // Consistência
            Do While !ft_fEOF()
                
                IncProc( "Consistindo CSV... " + StrZero(nCount++, 9) )
                
                nLinha++
                cTxt    := ft_fReadLn()
                aDadRC1 := Separa(cTxt, ";")

                cRC1_FILTIT := AllTrim(aDadRC1[1])
                cRC1_CODTIT := AllTrim(aDadRC1[4])
                cRC1_DESCRI := AllTrim(aDadRC1[5])
                cRC1_PREFIX := AllTrim(aDadRC1[6])
                nRC1_VALOR  := Val(StrTran(aDadRC1[7],",","."))
                dRC1_EMISSA := CtoD(aDadRC1[8])
                dRC1_VENCTO := CtoD(aDadRC1[9])
                dRC1_VENREA := CtoD(aDadRC1[10])
                cRC1_TIPO   := AllTrim(aDadRC1[11])
                cRC1_NATURE := AllTrim(aDadRC1[12])
                cRC1_FORNEC := AllTrim(aDadRC1[13])
                cRC1_LOJA   := AllTrim(aDadRC1[14])
                dRC1_DTBUSI := CtoD(aDadRC1[15])
                dRC1_DTBUSF := CtoD(aDadRC1[16])
                cRC1_CC     := AllTrim(aDadRC1[17])
                cRC1_BANCO  := AllTrim(aDadRC1[24])
                cRC1_AGEN   := AllTrim(aDadRC1[25])
                cRC1_DIGAG  := AllTrim(aDadRC1[26])
                cRC1_NOCTA  := AllTrim(aDadRC1[27])
                cRC1_DIGCTA := AllTrim(aDadRC1[28])
                cRC1_NOMCTA := AllTrim(aDadRC1[29])
                cRC1_CNPJ   := AllTrim(aDadRC1[30])

                // Efetua consistências
                lRC1OK := ChkDadRC1(aDadRC1)

                aDadRC1 := {}
                
                ft_fSkip()
                
            EndDo

            TRB->( dbGoTop() )
            If TRB->( !EOF() )

                If msgYesNo("Consistência finalizada! Existem problemas nos dados que impediram a importação dos títulos de acordo. Deseja listá-las agora?")
                    ReportRC1()
                EndIf
            
            Else

                cRC1_TITEXT := UpRC1TITEXT()
                
                ProcRegua(0)

                nCount  := 0
                nLinha  := 0
                aDadRC1 := {}

                ft_fGoTop()
                ft_fSkip() // Pula linha do cabeçalho

                // Importação
                Do While !ft_fEOF()
                    
                    IncProc( "Gerando títulos de acordos, CSV... " + StrZero(nCount++, 9) )
                    
                    nLinha++
                    cTxt    := ft_fReadLn()
                    aDadRC1 := Separa(cTxt, ";")
                    
                    cRC1_FILTIT := AllTrim(aDadRC1[1])
                    cRC1_CODTIT := AllTrim(aDadRC1[4])
                    cRC1_DESCRI := AllTrim(aDadRC1[5])
                    cRC1_PREFIX := AllTrim(aDadRC1[6])
                    nRC1_VALOR  := Val(StrTran(aDadRC1[7],",","."))
                    dRC1_EMISSA := CtoD(aDadRC1[8])
                    dRC1_VENCTO := CtoD(aDadRC1[9])
                    dRC1_VENREA := CtoD(aDadRC1[10])
                    cRC1_TIPO   := AllTrim(aDadRC1[11])
                    cRC1_NATURE := AllTrim(aDadRC1[12])
                    cRC1_FORNEC := AllTrim(aDadRC1[13])
                    cRC1_LOJA   := AllTrim(aDadRC1[14])
                    dRC1_DTBUSI := CtoD(aDadRC1[15])
                    dRC1_DTBUSF := CtoD(aDadRC1[16])
                    cRC1_CC     := AllTrim(aDadRC1[17])
                    cRC1_BANCO  := AllTrim(aDadRC1[24])
                    cRC1_AGEN   := AllTrim(aDadRC1[25])
                    cRC1_DIGAG  := AllTrim(aDadRC1[26])
                    cRC1_NOCTA  := AllTrim(aDadRC1[27])
                    cRC1_DIGCTA := AllTrim(aDadRC1[28])
                    cRC1_NOMCTA := AllTrim(aDadRC1[29])
                    cRC1_CNPJ   := AllTrim(aDadRC1[30])

                    //cRC1_NUMTIT := Rc1TitIni() 
                    cRC1_NUMTIT := NextRC1() // @history ticket 11556 - Fernando Macieira - 29/04/2021 - Processo Trabalhista - Títulos (Consulta Aprovação)
                    
                    // Efetua consistências
                    //lRC1OK := ChkDadRC1(aDadRC1)
                    
                    //If lRC1OK

                        RecLock("RC1", .T.)

                            RC1->RC1_FILIAL   := FWxFilial("RC1")
                            RC1->RC1_INTEGR   := "0"
                            RC1->RC1_NUMTIT   := cRC1_NUMTIT
                            RC1->RC1_FILTIT   := cRC1_FILTIT
                            RC1->RC1_CODTIT   := cRC1_CODTIT
                            RC1->RC1_DESCRI   := cRC1_DESCRI
                            RC1->RC1_PREFIX   := cRC1_PREFIX
                            RC1->RC1_VALOR    := nRC1_VALOR
                            RC1->RC1_EMISSA   := dRC1_EMISSA
                            RC1->RC1_VENCTO   := dRC1_VENCTO
                            RC1->RC1_VENREA   := dRC1_VENREA
                            RC1->RC1_TIPO     := cRC1_TIPO
                            RC1->RC1_NATURE   := cRC1_NATURE
                            RC1->RC1_FORNEC   := cRC1_FORNEC
                            RC1->RC1_LOJA	  := cRC1_LOJA
                            RC1->RC1_DTBUSI   := dRC1_DTBUSI
                            RC1->RC1_DTBUSF   := dRC1_DTBUSF
                            RC1->RC1_CC       := cRC1_CC
                            RC1->RC1_BANCO    := cRC1_BANCO
                            RC1->RC1_AGEN     := cRC1_AGEN
                            RC1->RC1_DIGAG    := cRC1_DIGAG
                            RC1->RC1_NOCTA    := cRC1_NOCTA
                            RC1->RC1_DIGCTA   := cRC1_DIGCTA
                            RC1->RC1_NOMCTA   := cRC1_NOMCTA
                            RC1->RC1_CNPJ     := cRC1_CNPJ

                            RC1->RC1_TITEXT   := cRC1_TITEXT // Agrupador

                        RC1->( msUnLock() )

                        GrvTRB("Título incluído com sucesso no agrupador " + cRC1_TITEXT, AllTrim(Str(nLinha)), cTXT, nRC1_VALOR, cRC1_NUMTIT)
                    
                    //EndIf

                    aDadRC1 := {}
                    
                    ft_fSkip()
                    
                EndDo
            
                Aviso("GP660ROT-01", "Importação finalizada com sucesso! Será gerado um excel com os números dos títulos e valores para sua conferência..." , {"OK"},, "RC1_TITEXT n. " + cRC1_TITEXT )
                ReportRC1()

            EndIf
            
        EndIf
        
    EndIf
    
Return

/*/{Protheus.doc} Static Function GrvTRB(1, RC1_NUMTIT, cTXT)
    Popula TRB para listagem
    @type  Static Function
    @author FWNM
    @since 23/04/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GrvTRB(cDetalhe, cNumLinha, cTXT, nValor, cNumTit)

    Default nValor := 0
    Default cNumTit := ""

    RecLock("TRB", .T.)

	    TRB->NUMLINHA := cNumLinha
		TRB->STATUS   := cDetalhe
		TRB->LINHA    := cTXT
        TRB->VALOR    := nValor
        TRB->TITULO   := cNumTit

	TRB->( msUnLock() )
	
Return

/*/{Protheus.doc} Static Function ReportRC1
    Gera listagem de inconsistência
    @type  Static Function
    @author user
    @since 23/04/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ReportRC1()

	oReport := ReportDef(@cAliasTRB)
	oReport:PrintDialog()

Return

/*/{Protheus.doc} Static Function ReportDef
	ReportDef
	@type  Function
	@author Fernando Macieira
	@version 01
/*/
Static Function ReportDef(cAliasTRB)
                                   
	Local oReport
	Local oTitulos
	Local aOrdem := {}
	  
	Local cTitulo := "Títulos Acordo Trabalhista - Resultado"

	cAliasTRB := "TRB"
	
	oReport := TReport():New("IMPRC1",OemToAnsi(cTitulo), /*cPerg*/, ;
	{|oReport| ReportPrint(cAliasTRB)},;
	OemToAnsi(" ")+CRLF+;
	OemToAnsi("")+CRLF+;
	OemToAnsi("") )

	oReport:nDevice     := 4 // XLS

	oReport:SetLandscape()
	//oReport:SetTotalInLine(.F.)
	
	oTitulos := TRSection():New(oReport, OemToAnsi(cTitulo),{"TRB"}, aOrdem /*{}*/, .F., .F.)
	//oReport:SetTotalInLine(.F.)
	
    TRCell():New(oTitulos,	"NUMLINHA"   ,"","Número Linha"                /*Titulo*/,  /*Picture*/ ,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oTitulos,	"STATUS"     ,"","Detalhamento da Ocorrência"  /*Titulo*/,  /*Picture*/ ,50 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oTitulos,	"LINHA"      ,"","Conteúdo Linha"              /*Titulo*/,  /*Picture*/ ,150 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oTitulos,	"VALOR"      ,"","Valor Título"                /*Titulo*/,  "@E 999,999,999.99" ,40 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oTitulos,	"TITULO"     ,"","Numero Título"               /*Titulo*/,   ,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

Return oReport

/*/{Protheus.doc} Static Function ReportPrint
	ReportPrint
	@type  Function
	@version 01
/*/
Static Function ReportPrint(cAliasTRB)

	Local oTitulos := oReport:Section(1)
	
	dbSelectArea("TRB")
	TRB->( dbSetOrder(1) )
	
	oTitulos:SetMeter( LastRec() )
	
	TRB->( dbGoTop() )
	Do While TRB->( !EOF() )
		
		oTitulos:IncMeter()
		
		oTitulos:Init()
		
		If oReport:Cancel()
			oReport:PrintText(OemToAnsi("Cancelado"))
			Exit
		EndIf
		
		//Impressao propriamente dita....
		oTitulos:Cell("NUMLINHA")  :SetBlock( {|| TRB->NUMLINHA} )
		oTitulos:Cell("STATUS")    :SetBlock( {|| TRB->STATUS} )
		oTitulos:Cell("LINHA")     :SetBlock( {|| TRB->LINHA} )
		oTitulos:Cell("VALOR")     :SetBlock( {|| TRB->VALOR} )
    	oTitulos:Cell("TITULO")    :SetBlock( {|| TRB->TITULO} )

		oTitulos:PrintLine()
		oReport:IncMeter()
	
		TRB->( dbSkip() )
		
	EndDo
	
	oTitulos:Finish()

	If Select("TRB") > 0
		TRB->( dbCloseArea() )
	EndIf
	
	If Select("QRY") > 0
		QRY->( dbCloseArea() )
	EndIf
	
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	
	//oTempTable:Delete()  

Return

/*/{Protheus.doc} Static Function ChkDadRC1(aDadRC1)
    Checa dados da planilha em busca de inconsistências
    @type  Static Function
    @author FWNM
    @since 26/04/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ChkDadRC1(aDadRC1)

    Local lRet := .t.
    Local cCodTit := GetMV("MV_#RC1COD",,"906")
    Local cPreTit := GetMV("MV_#RC1PRE",,"GPE")
    Local cQuery  := ""
    Local aAreaSM0 := SM0->( GetArea() )

    // Filial original // @history ticket 11556 - Fernando Macieira - 29/04/2021 - Processo Trabalhista - Títulos (Consistência filial origem)
    SM0->( dbSetOrder(1) ) // M0_CODIGO+M0_CODFIL
    If SM0->( !dbSeek(cEmpAnt+AllTrim(aDadRC1[1])) )
        lRet := .f.
        GrvTRB("Filial título não existe no cadastro de empresas", AllTrim(Str(nLinha)), cTXT, Val(StrTran(aDadRC1[7],",",".")))
    EndIf

    // Codigo Titulo
    If AllTrim(aDadRC1[4]) <> cCodTit
        lRet := .f.
        GrvTRB("Codigo título não cadastrado MV_#RC1COD", AllTrim(Str(nLinha)), cTXT, Val(StrTran(aDadRC1[7],",",".")))
    EndIf

    // Prefixo Titulo
    If AllTrim(aDadRC1[6]) <> cPreTit
        lRet := .f.
        GrvTRB("Prefixo título não cadastrado MV_#RC1PRE", AllTrim(Str(nLinha)), cTXT, Val(StrTran(aDadRC1[7],",",".")))
    EndIf

    // Emissão
    If CtoD(aDadRC1[8]) < GetMV("MV_DATAFIN")
        lRet := .f.
        GrvTRB("Dt Emissão inferior MV_DATAFIN", AllTrim(Str(nLinha)), cTXT, Val(StrTran(aDadRC1[7],",",".")))
    EndIf

    // Valor
    If Val(StrTran(aDadRC1[7],",",".")) < 0
        lRet := .f.
        GrvTRB("Valor negativo", AllTrim(Str(nLinha)), cTXT, Val(StrTran(aDadRC1[7],",",".")))
    EndIf

    // Vencimento
    If CtoD(aDadRC1[9]) < CtoD(aDadRC1[8])
        lRet := .f.
        GrvTRB("Dt Vencimento inferior Emissão", AllTrim(Str(nLinha)), cTXT, Val(StrTran(aDadRC1[7],",",".")))
    EndIf

    // Vencimento Real
    If CtoD(aDadRC1[10]) < CtoD(aDadRC1[8])
        lRet := .f.
        GrvTRB("Dt Vencimento Real inferior Emissão", AllTrim(Str(nLinha)), cTXT, Val(StrTran(aDadRC1[7],",",".")))
    EndIf

    // Tipo
    SX5->( dbSetOrder(1) ) // X5_FILIAL, X5_TABELA, X5_CHAVE, R_E_C_N_O_, D_E_L_E_T_
    If SX5->( !dbSeek(FWxFilial("SX5")+"05"+AllTrim(aDadRC1[11])) )
        lRet := .f.
        GrvTRB("Tipo título não cadastrado", AllTrim(Str(nLinha)), cTXT, Val(StrTran(aDadRC1[7],",",".")))
    EndIf

    // Natureza
    SED->( dbSetOrder(1) ) // ED_FILIAL, ED_CODIGO, R_E_C_N_O_, D_E_L_E_T_
    If SED->( !dbSeek(FWxFilial("SED")+AllTrim(aDadRC1[12])) )
        lRet := .f.
        GrvTRB("Natureza não cadastrada", AllTrim(Str(nLinha)), cTXT, Val(StrTran(aDadRC1[7],",",".")))
    EndIf

    // Fornecedor
    SA2->( dbSetOrder(1) ) // A2_FILIAL, A2_COD, A2_LOJA, R_E_C_N_O_, D_E_L_E_T_
    If SA2->( !dbSeek(FWxFilial("SA2")+AllTrim(aDadRC1[13])+AllTrim(aDadRC1[14])) )
        lRet := .f.
        GrvTRB("Fornecedor não cadastrado", AllTrim(Str(nLinha)), cTXT, Val(StrTran(aDadRC1[7],",",".")))
    EndIf

    // CCusto
    CTT->( dbSetOrder(1) ) // CTT_FILIAL, CTT_CUSTO, R_E_C_N_O_, D_E_L_E_T_
    If CTT->( !dbSeek(FWxFilial("CTT")+AllTrim(aDadRC1[17])) )
        lRet := .f.
        GrvTRB("Centro Custo não cadastrado", AllTrim(Str(nLinha)), cTXT, Val(StrTran(aDadRC1[7],",",".")))
    EndIf

    // Duplicidade VENCTO
    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    cQuery := " SELECT RC1_FILTIT, RC1_CODTIT, RC1_DESCRI, RC1_PREFIX, RC1_VALOR, RC1_EMISSA, RC1_VENCTO, RC1_VENREA, RC1_TIPO, RC1_NATURE, RC1_FORNEC, RC1_LOJA, RC1_CC, RC1_BANCO, RC1_AGEN, RC1_NOCTA, RC1_NOMCTA, RC1_CNPJ
    cQuery += " FROM " + RetSqlName("RC1") + " (NOLOCK)
    cQuery += " WHERE RC1_CNPJ='"+AllTrim(aDadRC1[30])+"'
    cQuery += " AND RC1_VENCTO='"+DtoS(CtoD(aDadRC1[9]))+"'
    cQuery += " AND RC1_VALOR = " + AllTrim(Str(Val(StrTran(aDadRC1[7],",","."))))
    cQuery += " AND D_E_L_E_T_=''
    cQuery += " UNION ALL
    cQuery += " SELECT RC1_FILTIT, RC1_CODTIT, RC1_DESCRI, RC1_PREFIX, RC1_VALOR, RC1_EMISSA, RC1_VENCTO, RC1_VENREA, RC1_TIPO, RC1_NATURE, RC1_FORNEC, RC1_LOJA, RC1_CC, RC1_BANCO, RC1_AGEN, RC1_NOCTA, RC1_NOMCTA, RC1_CNPJ
    cQuery += " FROM " + RetSqlName("RC1") + " (NOLOCK)
    cQuery += " WHERE RC1_CNPJ='"+AllTrim(aDadRC1[30])+"'
    cQuery += " AND RC1_VENREA='"+DtoS(CtoD(aDadRC1[10]))+"'
    cQuery += " AND RC1_VALOR = " + AllTrim(Str(Val(StrTran(aDadRC1[7],",","."))))
    cQuery += " AND D_E_L_E_T_=''

    tcQuery cQuery New Alias "Work"

    Work->( dbGoTop() )
    If Work->( !EOF() )
        lRet := .f.
        GrvTRB("Beneficiário já possui título neste vencimento com o mesmo valor", AllTrim(Str(nLinha)), cTXT, Val(StrTran(aDadRC1[7],",",".")))
    EndIf

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    RestArea( aAreaSM0 )

Return lRet

/*/{Protheus.doc} Static Function UpRC1TITEXT()
    Agrupador para auditoria
    @type  Static Function
    @author FWNM
    @since 26/04/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function UpRC1TITEXT()

    Local cNextCod := ""
    Local cQuery   := ""

    If Select("WorkNext") > 0
        WorkNext->( dbCloseArea() )
    EndIf

    cQuery := " SELECT ISNULL(MAX(RC1_TITEXT),0) AS NEXT_COD 
    cQuery += " FROM " + RetSqlName("RC1") + " (NOLOCK) 
    cQuery += " WHERE D_E_L_E_T_='' 

    tcQuery cQuery New Alias "WorkNext"

    If Empty(AllTrim(WorkNext->NEXT_COD))
        cNextCod := "0000000000001"
    Else
        cNextCod := Soma1(AllTrim(WorkNext->NEXT_COD))
    EndIf

    If Select("WorkNext") > 0
        WorkNext->( dbCloseArea() )
    EndIf

Return cNextCod

/*/{Protheus.doc} Static Function NextRC1
    Função para substituir Rc1TitIni() 
    @type  Function
    @author FWNM
    @since 07/05/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history ticket 11556 - Fernando Macieira - 29/04/2021 - Processo Trabalhista - Títulos (Consulta Aprovação)
/*/
Static Function NextRC1()

    Local cNextCod := ""
    Local cQuery   := ""

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    cQuery := " SELECT MAX(RC1_NUMTIT) AS NEXT_COD 
    cQuery += " FROM " + RetSqlName("RC1") + " (NOLOCK) 
    cQuery += " WHERE RC1_FILIAL='"+FWxFilial("RC1")+"' 
    cQuery += " AND D_E_L_E_T_='' 

    tcQuery cQuery New Alias "Work"

    cNextCod := Soma1(AllTrim(Work->NEXT_COD))

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    dbSelectArea("RC1")
    ConfirmSX8()
    //

Return cNextCod
