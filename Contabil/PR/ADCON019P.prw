#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "REPORT.CH"


/*/{Protheus.doc} User Function ADCON019P
    Cria estrutura de produtos a partir de um excel
    @type  Function
    @author FWNM
    @since 06/10/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function ADCON019P()

    Local lOk		:= .F.
    Local alSay		:= {}
    Local alButton	:= {}
    Local clTitulo	:= 'IMPORTAÇÃO ESTRUTURA DE PRODUTOS'
    Local clDesc1   := 'O objetivo desta rotina é criar as estruturas dos produtos de um Excel (CSV).'
    Local clDesc2   := 'Regras:'
    Local clDesc3   := '- incluirá um componente qdo existir o produto e a coluna substituição vazia;'
    Local clDesc4   := '- substituirá o componente quando a coluna substituição estiver preenchida;'
    Local clDesc5   := ''

	Private cAliasTRB := ""

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
        Processa( { || RunIMPSG1() }, "Criando estruturas dos produtos..." )
    EndIf
   
Return

/*/{Protheus.doc} Static Function RUNIMPSG1
    (long_description)
    @type  Static Function
    @author user
    @since 06/10/2021 
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history ticket  11639  - Fernando Macieira - 11/11/2021 - Permitir incluir componente quando o produto do nó estiver bloqueado.
/*/
Static Function RunImpSG1()

    Local lFile     := .f.
    Local cTxt      := ""
    Local nCount    := 0
    Local aDadSG1   := {}
    Local aCampos   := {}

    cFile := cGetFile("Arquivos CSV (Separados por Vírgula) | *.CSV",;
    ("Selecione o diretorio onde encontra-se o arquivo a ser processado"), 0, "Servidor\", .t., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE)// + GETF_RETDIRECTORY)

    If At(".CSV", upper(cFile)) > 0
        lFile := .t.
        ft_fUse(cFile)
    Else
        Aviso("IMPSG1-01", "Não foi possível abrir o arquivo...", {"&Ok"},, "Arquivo não identificado!")
    EndIf

    // Arquivo TXT
    If lFile
        
        ft_fGoTop()
        
        cVerTab := "Produto;DescProd;Componente;DescComp; Quantidade ;Data Ini;Data Fim;ComponenteSubs;DescCompSubs; QuantidadeSubs ;Obs;Nivel"
        
        cTxt := AllTrim(ft_fReadLn())
        
        If cVerTab <> cTXT
            
            Aviso("IMPSG1-02", "A importação não será realizada! As colunas do excel precisam ser " + cVerTab, {"&Ok"},, "Versão/Leiaute da planilha incorreta!")
            
        Else
                    
            ft_fSkip() // Pula linha do cabeçalho
            
            If Select("TRB") > 0
                TRB->( dbCloseArea() )
            EndIf
                
            // Crio TRB para impressão
            // https://tdn.totvs.com.br/display/framework/FWTemporaryTable
            oTempTable := FWTemporaryTable():New("TRB")
            
            // Arquivo TRB
            aAdd( aCampos, {'PRODUTO'    ,TamSX3("B1_COD")[3]     ,TamSX3("B1_COD")[1] , 0} )
            aAdd( aCampos, {'STATUS'     ,TamSX3("B1_DESC")[3]    ,TamSX3("B1_DESC")[1], 0} )
            aAdd( aCampos, {'LINHA'      ,TamSX3("B1_DESC")[3]    ,TamSX3("B1_DESC")[1], 0} )

            oTempTable:SetFields(aCampos)
            oTempTable:AddIndex("01", {"PRODUTO"} )
            oTempTable:Create()

            // Consistência
            Do While !ft_fEOF()
                
                IncProc( "Consistindo CSV... " + StrZero(nCount++, 9) )
                
                cTxt    := ft_fReadLn()
                aDadSG1 := Separa(cTxt, ";")
                
                // Produto;DescProd;Componente;DescComp; Quantidade ;Data Ini;Data Fim;ComponenteSubs;DescCompSubs; QuantidadeSubs ;Obs;Nivel
                cG1_COD    := PadR( AllTrim(aDadSG1[1]), TAMSX3("G1_COD")[1] )
                cG1_COMP   := PadR( AllTrim(aDadSG1[3]), TAMSX3("G1_COMP")[1] )
                nG1_QUANT  := Val(StrTran(aDadSG1[5],",","."))
                dG1_INI    := StoD(aDadSG1[6])
                dG1_FIM    := StoD(aDadSG1[7])
                cCOMPSubs  := PadR( AllTrim(aDadSG1[8]), TAMSX3("G1_COMP")[1] )
                nQtdeSubs  := Val(StrTran(aDadSG1[10],",","."))
                cG1_OBSERV := AllTrim(aDadSG1[11])
                cG1_NIV    := AllTrim(aDadSG1[12])

                SB1->( dbSetOrder(1) ) // B1_FILIAL, B1_COD, R_E_C_N_O_, D_E_L_E_T_
                If SB1->( !dbSeek(FWxFilial("SB1")+cG1_COD) )
                    GrvTRB(1, cG1_COD, cTXT)
                Else
                    If AllTrim(SB1->B1_MSBLQL) == "1"
                        GrvTRB(3, cG1_COD, cTXT)
                    EndIf
                EndIf

                SB1->( dbSetOrder(1) ) // B1_FILIAL, B1_COD, R_E_C_N_O_, D_E_L_E_T_
                If SB1->( !dbSeek(FWxFilial("SB1")+cG1_COMP) )
                    GrvTRB(2, cG1_COMP, cTXT)
                Else
                    If AllTrim(SB1->B1_MSBLQL) == "1"
                        GrvTRB(4, cG1_COD, cTXT)
                    EndIf
                EndIf

                SB1->( dbSetOrder(1) ) // B1_FILIAL, B1_COD, R_E_C_N_O_, D_E_L_E_T_
                If SB1->( !dbSeek(FWxFilial("SB1")+cCOMPSubs) )
                    GrvTRB(7, cG1_COMP, cTXT) // Componente Substitudo não cadastrado"
                Else
                    If AllTrim(SB1->B1_MSBLQL) == "1"
                        GrvTRB(8, cG1_COD, cTXT) // Componente Substitudo bloqueado B1_MSBLQL"
                    EndIf
                EndIf

                If nG1_QUANT <= 0
                    GrvTRB(5, cG1_COD, cTXT)
                EndIf

                SG1->( dbSetOrder(1) ) // G1_FILIAL, G1_COD, G1_COMP, G1_TRT, R_E_C_N_O_, D_E_L_E_T_
                If SG1->( dbSeek(FWxFilial("SG1")+cG1_COD) )
                    If SG1->( dbSeek(FWxFilial("SG1")+cG1_COD+cCOMPSubs) )
                        GrvTRB(6, cG1_COD, cTXT)
                    EndIf
                EndIf

                If !Empty(cCOMPSubs)
                    If nQtdeSubs <= 0
                        GrvTRB(9, cG1_COD, cTXT)
                    EndIf
                EndIf

                aDadSG1 := {}
                
                ft_fSkip()
                
            EndDo
            
            TRB->( dbGoTop() )
            If TRB->( !EOF() )

                If msgYesNo("Consistência finalizada! Existem problemas nos dados que impediram a geração da estrutura. Deseja listá-las agora?")
                    ReportSG1()
                EndIf
            
            Else

                nCount  := 0
                aDadSG1 := {}

                ft_fGoTop()         
                ft_fSkip() // Pula linha do cabeçalho       

                // Geração SG1
                Do While !ft_fEOF()
                    
                    IncProc( "Gerando estruturas... " + StrZero(nCount++, 9) )
                    
                    cTxt    := ft_fReadLn()
                    aDadSG1 := Separa(cTxt, ";")
                    
                    // Produto;DescProd;Componente;DescComp; Quantidade ;Data Ini;Data Fim;ComponenteSubs;DescCompSubs; QuantidadeSubs ;Obs;Nivel
                    cG1_COD    := PadR( AllTrim(aDadSG1[1]), TAMSX3("G1_COD")[1] )
                    cG1_COMP   := PadR( AllTrim(aDadSG1[3]), TAMSX3("G1_COMP")[1] )
                    nG1_QUANT  := Val(StrTran(aDadSG1[5],",","."))
                    dG1_INI    := StoD(aDadSG1[6])
                    dG1_FIM    := StoD(aDadSG1[7])
                    cCOMPSubs  := PadR( AllTrim(aDadSG1[8]), TAMSX3("G1_COMP")[1] )
                    nQtdeSubs  := Val(StrTran(aDadSG1[10],",","."))
                    cG1_OBSERV := AllTrim(aDadSG1[11])
                    cG1_NIV    := AllTrim(aDadSG1[12])

                    lLockSG1 := .t.
                    If !Empty(cCOMPSubs)
                        SG1->( dbSetOrder(1) ) // G1_FILIAL, G1_COD, G1_COMP, G1_TRT, R_E_C_N_O_, D_E_L_E_T_
                        If SG1->( dbSeek(FWxFilial("SG1")+cG1_COD+cG1_COMP) )
                            lLockSG1 := .f.
                        EndIf
                    EndIf

                    RecLock("SG1", lLockSG1)
                        SG1->G1_FILIAL  := FWxFilial("SG1")
                        SG1->G1_COD     := cG1_COD
                        SG1->G1_COMP    := Iif(lLockSG1,cG1_COMP,cCOMPSubs)
                        SG1->G1_QUANT   := Iif(lLockSG1,nG1_QUANT,nQtdeSubs)
                        SG1->G1_INI     := dG1_INI
                        SG1->G1_FIM     := dG1_FIM
                        SG1->G1_OBSERV  := AllTrim(cUserName) + "_" +  DtoC(msDate()) + "_" + Time() + "_" + cG1_OBSERV
                        SG1->G1_REVFIM  := "ZZZ"
                        SG1->G1_FIXVAR  := "V"
                        SG1->G1_VLCOMPE := "N"
                        //SG1->G1_NIV    := cG1_NIV
                    SG1->( msUnLock() )

                    aDadSG1 := {}
                    
                    ft_fSkip()
                    
                EndDo
            
                Alert("Importação finalizada com sucesso!")
            
            EndIf
            
        EndIf
        
    EndIf
    
Return

/*/{Protheus.doc} Static Function GrvTRB(1, G1_COD, cTXT)
    Popula TRB para listagem
    @type  Static Function
    @author user
    @since 06/10/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GrvTRB(nTipo, cG1_COD, cTXT)

    Local cStatus := ""

    If nTipo == 1
        cStatus := "Produto não cadastrado"
    
    ElseIf nTipo == 2
        cStatus := "Componente não cadastrado"

    ElseIf nTipo == 3
        cStatus := "Produto bloqueado B1_MSBLQL"

    ElseIf nTipo == 4
        cStatus := "Componente bloqueado B1_MSBLQL"

    ElseIf nTipo == 5
        cStatus := "Quantidade inválida"

    ElseIf nTipo == 6
        cStatus := "Estrutura já existente (Código + Componente)"

    ElseIf nTipo == 7
        cStatus := "Componente substitudo não cadastrado"

    ElseIf nTipo == 8
        cStatus := "Componente substitudo bloqueado B1_MSBLQL"

    ElseIf nTipo == 9
        cStatus := "Quantidade componente substitudo inválida"

    EndIf

    RecLock("TRB", .T.)

	    TRB->PRODUTO := cG1_COD
		TRB->STATUS  := cStatus
		TRB->LINHA   := cTXT

	TRB->( msUnLock() )
	
Return

/*/{Protheus.doc} Static Function ReportSG1
    Gera listagem de inconsistência
    @type  Static Function
    @author user
    @since 06/10/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ReportSG1()

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
	Local oProdutos
	Local aOrdem  := {}
	Local cTitulo := "Estruturas de Produtos - Inconsistências"

	cAliasTRB := "TRB"
	
	oReport := TReport():New("IMPSG1",OemToAnsi(cTitulo), /*cPerg*/, ;
	{|oReport| ReportPrint(cAliasTRB)},;
	OemToAnsi(" ")+CRLF+;
	OemToAnsi("")+CRLF+;
	OemToAnsi("") )

	oReport:nDevice     := 4 // XLS

	oReport:SetLandscape()
	//oReport:SetTotalInLine(.F.)
	
	oProdutos := TRSection():New(oReport, OemToAnsi(cTitulo),{"TRB"}, aOrdem /*{}*/, .F., .F.)
	//oReport:SetTotalInLine(.F.)
	
	TRCell():New(oProdutos,	"PRODUTO"     ,"","Produto"        /*Titulo*/,  /*Picture*/,TamSX3("G1_COD")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProdutos,	"STATUS"     ,"","Status"         /*Titulo*/,  /*Picture*/,TamSX3("G1_COMP")[1]+40 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProdutos,	"LINHA"      ,"","Linha"          /*Titulo*/,  /*Picture*/,100 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

Return oReport

/*/{Protheus.doc} Static Function ReportPrint
	ReportPrint
	@type  Function
	@version 01
/*/
Static Function ReportPrint(cAliasTRB)

	Local oProdutos := oReport:Section(1)
	
	dbSelectArea("TRB")
	TRB->( dbSetOrder(1) )
	
	oProdutos:SetMeter( LastRec() )
	
	TRB->( dbGoTop() )
	Do While TRB->( !EOF() )
		
		oProdutos:IncMeter()
		
		oProdutos:Init()
		
		If oReport:Cancel()
			oReport:PrintText(OemToAnsi("Cancelado"))
			Exit
		EndIf
		
		//Impressao propriamente dita....
		oProdutos:Cell("PRODUTO")    :SetBlock( {|| TRB->PRODUTO} )
		oProdutos:Cell("STATUS")    :SetBlock( {|| TRB->STATUS} )
		oProdutos:Cell("LINHA")     :SetBlock( {|| TRB->LINHA} )

		oProdutos:PrintLine()
		oReport:IncMeter()
	
		TRB->( dbSkip() )
		
	EndDo
	
	oProdutos:Finish()

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
