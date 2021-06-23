#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.ch"
#include "rwmake.ch"

Static oTempTable 

/*/{Protheus.doc} User Function ADFIN100P
	Função para consistir geração do arquivo de cnab de pagamentos

	FINA420.PRX = (Arquivo de Pagamentos)
	//³ mv_par01		 // Do Bordero 		  		 ³
	//³ mv_par02		 // Ate Bordero   	  		 ³
	//³ mv_par03		 // Arq.Configuracao   		 ³
	//³ mv_par04		 // Arq. Saida			     ³
	//³ mv_par05		 // Banco       		  	 ³
	//³ mv_par06		 // Agencia 			  	 ³
	//³ mv_par07		 // Conta       		  	 ³
	//³ mv_par08		 // Sub-Conta			  	 ³
	//³ mv_par09 		 // Modelo 1/Modelo 2  		 ³
	//³ mv_par10		 // Cons.Filiais Abaixo		 ³
	//³ mv_par11		 // Filial de     	         ³
	//³ mv_par12		 // Filial Ate 		  		 ³
	//³ mv_par13		 // Receita Bruta Acumulada  ³

    FINA300.PRX = (SISPAG)
	// mv_par01 - Mostra lançamentos contábeis
	// mv_par02 - Aglutina lan‡amentos
	// mv_par03 - Atualiza moedas por
	// mv_par04 - Arquivo de entrada
	// mv_par05 - Arquivo de config
	// mv_par06 - C¢digo do banco
	// mv_par07 - C¢digo da agencia
	// mv_par08 - C¢digo da conta
	// mv_par09 - Sub-conta
	// mv_par10 - Abate desconto da comissão
	// mv_par11 - Contabiliza On-Line

    @type  Function
    @author FWNM
    @since 01/09/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history ticket     99 - FWNM       - 01/09/2020 - PROJETO PAGAR
    @history Ticket    429 - Abel Babini - 01/09/2020 - Rotina também utilizada na Tela de visualização de pagamentos (ADFIN0101P, F240GER, FA420CRI)
    @history Ticket    429 - Abel Babini - 30/10/2020 - Correção de error.log na execução da rotina
    @history Ticket    429 - Abel Babini - 03/11/2020 - Ajustes na gravação da solicitação de aprovação de pagamento (Central de Aprovação) e mensagem obrigatória
    @history Ticket    429 - Abel Babini - 09/11/2020 - Ajuste na verificação do Status na Central de Aprovação
    @history Ticket    429 - Abel Babini - 09/11/2020 - Ajuste na verificação DA REGRA 01 para prever vésperas de feriado
    @history Ticket    429 - Abel Babini - 10/11/2020 - Ajuste na regra 8 para não bloquear PA´s originadas no SAG.
    @history Ticket    429 - Abel Babini - 10/11/2020 - Melhoria de Performance na execução das validações das regras e ajustes na regra 04 - Risco de duplicidade
    @history Ticket    429 - Abel Babini - 13/11/2020 - Ajuste na regra 8 para não bloquear NF´s originadas no SAG.
    @history Ticket    429 - Abel Babini - 27/11/2020 - Ajuste na chamada da rotina DataValida
    @history Ticket    429 - Abel Babini - 30/11/2020 - Substituição da rotina padrão DataValida que causa error.log
    @history Ticket    429 - Abel Babini - 01/12/2020 - Ajuste no fonte para reposicionar o Alias SM0
    @history Ticket    429 - Abel Babini - 08/12/2020 - Ajuste no fonte para utilizar GetArea / ResArea
    @history Ticket   6266 - Abel Babini - 08/12/2020 - Erro na gravação do registro na Central de Aprovação
    @history Ticket   6543 - Abel Babini - 14/12/2020 - Ajuste nos campos de informações bancárias do fornecedor no título a pagar
    @history Ticket   4883 - Abel Babini - 14/12/2020 - Validar modelo de pagamento
    @history Ticket   4883 - Abel Babini - 21/12/2020 - Geração de Borderô Automático e correção de error.log
    @history Ticket   4883 - Abel Babini - 04/01/2021 - Não bloquear PA´s integradas do SAG
    @history Ticket   8093 - Abel Babini - 15/01/2021 - Erro na verificação de títulos em outras unidades
    @history Ticket  14431 - Abel Babini - 24/05/2021 - Correção na regra de Divergência na forma de pagamentos
    @history Ticket  14432 - Fer Macieira- 08/06/2021 - BLOQUEIO DE GTA - IMPOSTO (PAINEL DE PAGAMENTOS)
/*/
User Function ADFIN100P(cRotina)

	Local lGera   := .t.
	Local _nRecSM0	:= SM0->(Recno()) //Ticket    429 - Abel Babini - 01/12/2020 - Ajuste no fonte para reposicionar o Alias SM0
	
	Private cBorIni := ""
	Private cBorFim := ""

	Private aDadBor := {}
	Private aDadSE2 := {}
	Private aDadBlq := {}

	Private aEmpresas := {}
	Private cStartPath := GetSrvProfString("Startpath","")

	Default cRotina := ""

	//a chamada à função xVrfData nesse ponto garante não haver erro de execução mais tarde. Prevenção devido a problema na LIB APLIB200 e APLIB240
	xVrfData(msdate() + 1) //@history Ticket   4883 - Abel Babini - 21/12/2020 - Geração de Borderô Automático e correção de error.log

	// Define rotinas
	If Upper(AllTrim(cRotina)) == "FINA420"

		cBorIni := MV_PAR01
		cBorFim := MV_PAR02
    
	ElseIf Upper(AllTrim(cRotina)) == "FINA300"

		cBorIni := MV_PAR01
		cBorFim := MV_PAR02
	
	EndIf

	// Carrego empresas do grupo para utilizar nas regras 02 e 03
	SM0->( dbSetOrder(1) )
	SM0->( dbGoTop() )
	Do While SM0->( !EOF() )

 		If AllTrim(SM0->M0_CODIGO) <> cEmpAnt //Ticket   8093 - Abel Babini - 15/01/2021 - Erro na verificação de títulos em outras unidades

			nPos := aScan(aEmpresas, {|x| AllTrim(x) == AllTrim(SM0->M0_CODIGO)})
			If nPos <= 0
				aAdd( aEmpresas, { SM0->M0_CODIGO } )
			EndIf
		
		EndIf

		SM0->( dbSkip() )
	
	EndDo
	SM0->(DBGoTo(_nRecSM0)) //Ticket    429 - Abel Babini - 01/12/2020 - Ajuste no fonte para reposicionar o Alias SM0

	// Efetua consistências
	//lGera := u_ChkCNAB(cBorIni, cBorFim)
	msAguarde( { || lGera := u_ChkCNAB(cBorIni, cBorFim) }, "Efetuando consistências dos borderôs" )

	//Gera log
	RecLock("ZBE",.T.)
		ZBE->ZBE_FILIAL	:= FWxFilial("ZBE")
		ZBE->ZBE_DATA 	:= msDate()
		ZBE->ZBE_HORA 	:= cValToChar(Time())
		ZBE->ZBE_USUARI := cUserName
		ZBE->ZBE_LOG 	:= "Arquivo Pagamento -> lGera = " + cValToChar(lGera)
		ZBE->ZBE_MODULO := "FINANCEIRO"
		ZBE->ZBE_ROTINA := "ADFIN100P"
		ZBE->ZBE_PARAME := "Bordero inicial/final " + cBorIni + " / " + cBorFim
	ZBE->( msUnLock() )
    
Return lGera

/*/{Protheus.doc} User Function CHKCNAB
    Função que contém consistências para determinar se o arquivo será gerado ou não
    @type  Function
    @author FWNM
    @since 01/09/2020
/*/
User Function ChkCNAB(cBorIni, cBorFim)
	//Declaração de variáveis
	Local cQryCRRs		:= ""
	// Local cAlsRes			:= "TMPRES1"

	Local lRet    := .t.

	//Private oTempTable
	Private oReport
	Private cAliasTRB := ""

	Default cBorIni := ""
	Default cBorFim := ""

	If Select("TRB") > 0
		TRB->( dbCloseArea() )
	EndIf
	
	// Cria TRB para impressão
	CriaTRB()

	//Seleciona registros do borderô
	//Ticket 6543   - Abel Babini - 13/12/2020 - Ajuste nos campos de informações bancárias do fornecedor no título a pagar
	cQryCRRs := " SELECT DISTINCT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_VALOR, E2_SALDO, E2_NUMBOR, E2_VENCREA, EA_PORTADO, EA_AGEDEP, EA_NUMCON, EA_MODELO, E2_BANCO, E2_AGEN, E2_NOCTA, A2_BANCO, A2_AGENCIA, A2_NUMCON, E2_MOEDA, E2_CODBAR, SUBSTRING(A2_CGC,1,8) A2_CGC, E2_ORIGEM, E2_FATURA, E2_FATPREF, E2_XRECORI "
	cQryCRRs += " FROM " + RetSqlName("SE2") + " SE2 (NOLOCK) "
	cQryCRRs += " INNER JOIN " + RetSqlName("SEA") + " SEA (NOLOCK) ON EA_FILIAL='"+FWxFilial("SEA")+"' AND EA_NUMBOR=E2_NUMBOR AND EA_PREFIXO=E2_PREFIXO AND EA_NUM=E2_NUM AND EA_PARCELA=E2_PARCELA AND EA_TIPO=E2_TIPO AND EA_FORNECE=E2_FORNECE AND EA_LOJA=E2_LOJA AND EA_CART='P' AND SEA.D_E_L_E_T_='' "
	cQryCRRs += " INNER JOIN " + RetSqlName("SA2") + " SA2 (NOLOCK) ON A2_FILIAL='"+FWxFilial("SA2")+"' AND A2_COD=E2_FORNECE AND A2_LOJA=E2_LOJA AND SA2.D_E_L_E_T_='' "
	cQryCRRs += " WHERE E2_NUMBOR BETWEEN '"+cBorIni+"' AND '"+cBorFim+"' "
	cQryCRRs += " AND SE2.D_E_L_E_T_='' "

	tcQuery cQryCRRs New Alias "TMPRES1"

	aTamSX3	:= TAMSX3("E2_VENCREA")
	tcSetField("TMPRES1", "E2_VENCREA", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	aTamSX3	:= TAMSX3("E2_VALOR")
	tcSetField("TMPRES1", "E2_VALOR", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	aTamSX3	:= TAMSX3("E2_SALDO")
	tcSetField("TMPRES1", "E2_SALDO", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	TMPRES1->( dbGoTop() )
	Do While TMPRES1->( !EOF() )
		
		//Ticket 6543   - Abel Babini - 13/12/2020 - Ajuste nos campos de informações bancárias do fornecedor no título a pagar
		ChkRegras(	TMPRES1->E2_NUMBOR, ;
								TMPRES1->E2_FILIAL, ;
								TMPRES1->E2_PREFIXO, ;
								TMPRES1->E2_NUM, ;
								TMPRES1->E2_PARCELA, ;
								TMPRES1->E2_TIPO, ;
								TMPRES1->E2_FORNECE, ;
								TMPRES1->E2_LOJA, ;
								TMPRES1->E2_VENCREA, ;
								TMPRES1->E2_SALDO, ;
								TMPRES1->EA_PORTADO, ;
								TMPRES1->EA_AGEDEP, ;
								TMPRES1->EA_NUMCON, ;
								TMPRES1->E2_NOMFOR, ;
								TMPRES1->E2_VALOR, ;
								TMPRES1->E2_MOEDA, ;
								TMPRES1->E2_CODBAR, ;
								Alltrim(TMPRES1->A2_CGC), ;
								TMPRES1->E2_ORIGEM, ;
								TMPRES1->E2_BANCO, ; 	
								TMPRES1->E2_AGEN, ;		
								TMPRES1->E2_NOCTA, ;	
								TMPRES1->A2_BANCO, ;
								TMPRES1->A2_AGENCIA, ;
								TMPRES1->A2_NUMCON, ;
								TMPRES1->E2_FATURA, ;
								TMPRES1->E2_FATPREF, ;
								TMPRES1->E2_XRECORI, ;
								TMPRES1->EA_MODELO)

		TMPRES1->( dbSkip() )

	EndDo

	If Select("TMPRES1") > 0
		TMPRES1->( dbCloseArea() )
	EndIf

	// Mostro consistências impeditivas
	If IsInCallStack("U_ADFIN100P")
		
		If TRB->( !EOF() )

			lRet := .f.

			If msgYesNo("Arquivo não será gerado pois possui consistências impeditivas, conforme regras Adoro. Deseja visualizá-las?")

				oReport := ReportDef(@cAliasTRB)
				oReport:PrintDialog()

			EndIf

		EndIf
	
	EndIf

	oTempTable:Delete()

Return lRet

/*/{Protheus.doc} Static Function GrvTRB
    Grava TRB para listar inconsistências
    @type  Function
    @author FWNM
    @since 02/09/2020
/*/
Static Function GrvTRB(cID, cRegra, aDadBor, aDadSE2, aDadBlq, cZC7Sts)

	Default cID			:= ""
	Default cRegra	:= ""
	Default cZC7Sts	:= ""

	RecLock("TRB", .T.)

		TRB->REGRA      := cRegra

		// Dados do Borderô
		If Len(aDadBor) > 0
			TRB->EA_NUMBOR  := aDadBor[1]
			TRB->E2_VENCREA := aDadBor[2]
			TRB->EA_PORTADO := aDadBor[3]
			TRB->EA_AGEDEP  := aDadBor[4]
			TRB->EA_NUMCON  := aDadBor[5]
		EndIf
	
		// Dados dos títulos que estão no borderôs
		If Len(aDadSE2) > 0
			TRB->E2_FILIAL   := aDadSE2[1,1]
			TRB->E2_PREFIXO  := aDadSE2[1,2]
			TRB->E2_NUM      := aDadSE2[1,3]
			TRB->E2_PARCELA  := aDadSE2[1,4]
			TRB->E2_TIPO     := aDadSE2[1,5]
			TRB->E2_FORNECE  := aDadSE2[1,6]
			TRB->E2_LOJA     := aDadSE2[1,7]
			TRB->E2_NOMFOR   := aDadSE2[1,8]
			TRB->E2_VENCREA  := aDadSE2[1,9]
			TRB->E2_VALOR    := aDadSE2[1,10]
			TRB->E2_SALDO    := aDadSE2[1,11]
			TRB->E2_MOEDA    := aDadSE2[1,12]
			TRB->E2_CODBAR   := aDadSE2[1,13]
			//Título possui restrição: Carrega Status de aprovação
			//00- Aprovação de pagamento não solicitada
			//01- Aprovação de pagamento solicitada
			//02- Aprovação de pagamento realizada
			TRB->ZC7_STATUS	 := cZC7Sts
		EndIf

		// Campos para armazenar dados dos títulos que não estão no borderôs mas geraram inconsistências pelo fato deles existirem
		If Len(aDadBlq) > 0
			TRB->RECPAG      := aDadBlq[1]
			TRB->FILIAL      := aDadBlq[2]
			TRB->PREFIXO     := aDadBlq[3]
			TRB->NUM         := aDadBlq[4]
			TRB->PARCELA     := aDadBlq[5]
			TRB->TIPO        := aDadBlq[6]
			TRB->CLIFOR      := aDadBlq[7]
			TRB->LOJA        := aDadBlq[8]
			TRB->FANTASIA    := aDadBlq[9]
			TRB->VALOR       := aDadBlq[10]
			TRB->SALDO       := aDadBlq[11]
			TRB->MOEDA       := aDadBlq[12]
			TRB->CODBAR      := aDadBlq[13]
			TRB->LIVRE       := aDadBlq[14]
		EndIf

	TRB->( msUnLock() )

Return 

/*/{Protheus.doc} Static Function ReportDef
	ReportDef
	@type  Function
	@author Fernando Macieira
	@version 01
/*/
Static Function ReportDef(cAliasTRB)
                                   
	Local oReport
	Local oFinanceiro
	Local aOrdem := {}
	Local cTitulo := "CNAB - Log de inconsistências impeditivas para tomada de ações"

	cAliasTRB := "TRB"
	
	oReport := TReport():New("ADFIN100P",OemToAnsi(cTitulo), /*cPerg*/, ;
	{|oReport| ReportPrint(cAliasTRB)},;
	OemToAnsi(" ")+CRLF+;
	OemToAnsi("")+CRLF+;
	OemToAnsi("") )

	oReport:nDevice     := 4 // XLS

	oReport:SetLandscape()
	
	oFinanceiro := TRSection():New(oReport, OemToAnsi(cTitulo),{"TRB"}, aOrdem /*{}*/, .F., .F.)
	
	// Dados do Borderô
	TRCell():New(oFinanceiro,	"REGRA"        ,"","Regra"       /*Titulo*/,  /*Picture*/,90 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"EA_NUMBOR"    ,"","Borderô"     /*Titulo*/,  /*Picture*/,TamSX3("EA_NUMBOR")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"EA_PORTADO"   ,"","Portador"    /*Titulo*/,  /*Picture*/,TamSX3("EA_PORTADO")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"EA_AGEDEP"    ,"","Agência"     /*Titulo*/,  /*Picture*/,TamSX3("EA_AGEDEP")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"EA_NUMCON"    ,"","Conta"       /*Titulo*/,  /*Picture*/,TamSX3("EA_NUMCON")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	
	// Dados dos títulos que causaram os bloqueios
	TRCell():New(oFinanceiro,	"RECPAG"    ,"","Carteira"      /*Titulo*/,  /*Picture*/,TamSX3("E5_RECPAG")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"FILIAL"    ,"","Filial"        /*Titulo*/,  /*Picture*/,TamSX3("E2_FILIAL")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"PREFIXO"   ,"","Prefixo"       /*Titulo*/,  /*Picture*/,TamSX3("E2_PREFIXO")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"NUM"       ,"","Título"        /*Titulo*/,  /*Picture*/,TamSX3("E2_NUM")[1]+2 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"PARCELA"   ,"","Parcela"       /*Titulo*/,  /*Picture*/,TamSX3("E2_PARCELA")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"TIPO"      ,"","Tipo"          /*Titulo*/,  /*Picture*/,TamSX3("E2_TIPO")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"CLIFOR"    ,"","Cli/For"       /*Titulo*/,  /*Picture*/,TamSX3("E2_FORNECE")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"LOJA"      ,"","Loja"          /*Titulo*/,  /*Picture*/,TamSX3("E2_LOJA")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"FANTASIA"  ,"","Nome Fantasia" /*Titulo*/,  /*Picture*/,TamSX3("E2_NOMFOR")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"VALOR"     ,"","Valor"         /*Titulo*/,  /*Picture*/,TamSX3("E2_VALOR")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"SALDO"     ,"","Saldo"         /*Titulo*/,  /*Picture*/,TamSX3("E2_SALDO")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"LIVRE"     ,"","Informações Adicionais"  /*Titulo*/,  /*Picture*/,254 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

Return oReport

/*/{Protheus.doc} Static Function ReportPrint
	ReportPrint
	@type  Function
	@version 01
/*/
Static Function ReportPrint(cAliasTRB)

	Local oFinanceiro := oReport:Section(1)
	
	dbSelectArea("TRB")
	TRB->( dbSetOrder(1) )
	
	oFinanceiro:SetMeter( LastRec() )
	
	TRB->( dbGoTop() )
	Do While TRB->( !EOF() )
		
		oFinanceiro:IncMeter()
		
		oFinanceiro:Init()
		
		If oReport:Cancel()
			oReport:PrintText(OemToAnsi("Cancelado"))
			Exit
		EndIf
		
		//Impressao propriamente dita....

		// Dados do Borderô
		oFinanceiro:Cell("REGRA")      :SetBlock( {|| TRB->REGRA} )
		oFinanceiro:Cell("EA_NUMBOR")  :SetBlock( {|| TRB->EA_NUMBOR} )
		oFinanceiro:Cell("EA_PORTADO") :SetBlock( {|| TRB->EA_PORTADO} )
		oFinanceiro:Cell("EA_AGEDEP")  :SetBlock( {|| TRB->EA_AGEDEP} )
		oFinanceiro:Cell("EA_NUMCON")  :SetBlock( {|| TRB->EA_NUMCON} )
		//oFinanceiro:Cell("EA_DATABOR") :SetBlock( {|| TRB->EA_DATABOR} )

		// Campos para armazenar dados dos títulos que não estão no borderôs mas geraram inconsistências pelo fato deles existirem
		oFinanceiro:Cell("RECPAG")     :SetBlock( {|| TRB->RECPAG} )
		oFinanceiro:Cell("FILIAL")     :SetBlock( {|| TRB->FILIAL} )
		oFinanceiro:Cell("PREFIXO")    :SetBlock( {|| TRB->PREFIXO} )
		oFinanceiro:Cell("NUM")        :SetBlock( {|| TRB->NUM} )
		oFinanceiro:Cell("PARCELA")    :SetBlock( {|| TRB->PARCELA} )
		oFinanceiro:Cell("TIPO")       :SetBlock( {|| TRB->TIPO} )
		oFinanceiro:Cell("CLIFOR")     :SetBlock( {|| TRB->CLIFOR} )
		oFinanceiro:Cell("LOJA")       :SetBlock( {|| TRB->LOJA} )
		oFinanceiro:Cell("FANTASIA")   :SetBlock( {|| TRB->FANTASIA} )
		oFinanceiro:Cell("VALOR")      :SetBlock( {|| TRB->VALOR} )
		oFinanceiro:Cell("SALDO")      :SetBlock( {|| TRB->SALDO} )
		oFinanceiro:Cell("LIVRE")      :SetBlock( {|| TRB->LIVRE} )

		oFinanceiro:PrintLine()
		oReport:IncMeter()
	
		TRB->( dbSkip() )
		
	EndDo
	
	oFinanceiro:Finish()

	If Select("TRB") > 0
		TRB->( dbCloseArea() )
	EndIf
	
	If Select("QRY") > 0
		QRY->( dbCloseArea() )
	EndIf
	
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	
Return

/*/{Protheus.doc} Static Function CriaTRB
	Cria arquivo de trabalho
	// https://tdn.totvs.com.br/display/framework/FWTemporaryTable
	oTempTable := FWTemporaryTable():New("TRB")
	@type  Function
	@version 01
/*/
Static Function CriaTRB()

	Local aCampos := {}

	oTempTable := FWTemporaryTable():New("TRB")
	
	// Arquivo TRB
	aAdd( aCampos, {'REGRA'      ,"C"     ,254, 0} )

	// Dados do Borderô
	aAdd( aCampos, {'EA_NUMBOR'  ,TamSX3("EA_NUMBOR")[3]    ,TamSX3("EA_NUMBOR")[1], 0} )
	aAdd( aCampos, {'EA_PORTADO' ,TamSX3("EA_PORTADO")[3]   ,TamSX3("EA_PORTADO")[1], 0} )
	aAdd( aCampos, {'EA_AGEDEP'  ,TamSX3("EA_AGEDEP")[3]    ,TamSX3("EA_AGEDEP")[1], 0} )
	aAdd( aCampos, {'EA_NUMCON'  ,TamSX3("EA_NUMCON")[3]    ,TamSX3("EA_NUMCON")[1], 0} )
	aAdd( aCampos, {'EA_DATABOR' ,TamSX3("EA_DATABOR")[3]   ,TamSX3("EA_DATABOR")[1], 0} )

	// Campos para armazenar dados dos títulos que estão no borderôs
	aAdd( aCampos, {'E2_FILIAL'  ,TamSX3("E2_FILIAL")[3]    ,TamSX3("E2_FILIAL")[1], 0} )
	aAdd( aCampos, {'E2_PREFIXO' ,TamSX3("E2_PREFIXO")[3]   ,TamSX3("E2_PREFIXO")[1], 0} )
	aAdd( aCampos, {'E2_NUM'     ,TamSX3("E2_NUM")[3]       ,TamSX3("E2_NUM")[1], 0} )
	aAdd( aCampos, {'E2_PARCELA' ,TamSX3("E2_PARCELA")[3]   ,TamSX3("E2_PARCELA")[1], 0} )
	aAdd( aCampos, {'E2_TIPO'    ,TamSX3("E2_TIPO")[3]      ,TamSX3("E2_TIPO")[1], 0} )
	aAdd( aCampos, {'E2_FORNECE' ,TamSX3("E2_FORNECE")[3]   ,TamSX3("E2_FORNECE")[1], 0} )
	aAdd( aCampos, {'E2_LOJA'    ,TamSX3("E2_LOJA")[3]      ,TamSX3("E2_LOJA")[1], 0} )
	aAdd( aCampos, {'E2_NOMFOR'  ,TamSX3("E2_NOMFOR")[3]    ,TamSX3("E2_NOMFOR")[1], 0} )
	aAdd( aCampos, {'E2_VENCREA' ,TamSX3("E2_VENCREA")[3]   ,TamSX3("E2_VENCREA")[1], 0} )
	aAdd( aCampos, {'E2_VALOR'   ,TamSX3("E2_VALOR")[3]     ,TamSX3("E2_VALOR")[1], 0} )
	aAdd( aCampos, {'E2_SALDO'   ,TamSX3("E2_SALDO")[3]     ,TamSX3("E2_SALDO")[1], 0} )
	aAdd( aCampos, {'E2_MOEDA'   ,TamSX3("E2_MOEDA")[3]     ,TamSX3("E2_MOEDA")[1], 0} )
	aAdd( aCampos, {'E2_CODBAR'  ,TamSX3("E2_CODBAR")[3]    ,TamSX3("E2_CODBAR")[1], 0} )
	aAdd( aCampos, {'ZC7_STATUS' ,"C"                       ,254, 0} ) //Status do título na Central de Aprovação

	// Campos para armazenar dados dos títulos que não estão no borderôs mas geraram inconsistências pelo fato deles existirem
	aAdd( aCampos, {'RECPAG'     ,TamSX3("E5_RECPAG")[3]    ,TamSX3("E5_RECPAG")[1], 0} )
	aAdd( aCampos, {'FILIAL'     ,TamSX3("E2_FILIAL")[3]    ,TamSX3("E2_FILIAL")[1], 0} )
	aAdd( aCampos, {'PREFIXO'    ,TamSX3("E2_PREFIXO")[3]   ,TamSX3("E2_PREFIXO")[1], 0} )
	aAdd( aCampos, {'NUM'        ,TamSX3("E2_NUM")[3]       ,TamSX3("E2_NUM")[1], 0} )
	aAdd( aCampos, {'PARCELA'    ,TamSX3("E2_PARCELA")[3]   ,TamSX3("E2_PARCELA")[1], 0} )
	aAdd( aCampos, {'TIPO'       ,TamSX3("E2_TIPO")[3]      ,TamSX3("E2_TIPO")[1], 0} )
	aAdd( aCampos, {'CLIFOR'     ,TamSX3("E2_FORNECE")[3]   ,TamSX3("E2_FORNECE")[1], 0} )
	aAdd( aCampos, {'LOJA'       ,TamSX3("E2_LOJA")[3]      ,TamSX3("E2_LOJA")[1], 0} )
	aAdd( aCampos, {'FANTASIA'   ,TamSX3("E2_NOMFOR")[3]    ,TamSX3("E2_NOMFOR")[1], 0} )
	aAdd( aCampos, {'VALOR'      ,TamSX3("E2_VALOR")[3]     ,TamSX3("E2_VALOR")[1], 0} )
	aAdd( aCampos, {'SALDO'      ,TamSX3("E2_SALDO")[3]     ,TamSX3("E2_SALDO")[1], 0} )
	aAdd( aCampos, {'MOEDA'      ,TamSX3("E2_MOEDA")[3]     ,TamSX3("E2_MOEDA")[1], 0} )
	aAdd( aCampos, {'CODBAR'     ,TamSX3("E2_CODBAR")[3]    ,TamSX3("E2_CODBAR")[1], 0} )
	aAdd( aCampos, {'LIVRE'      ,"C"                       ,254, 0} )

	oTempTable:SetFields(aCampos)
	//oTempTable:AddIndex("01", {"E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA"} )
	oTempTable:AddIndex("01", {"FILIAL","PREFIXO","NUM","PARCELA","TIPO","CLIFOR","LOJA"} )
	oTempTable:AddIndex("02", {"REGRA","EA_NUMBOR","E2_FORNECE"} )
	oTempTable:Create()

Return

/*/{Protheus.doc} Static Function VerStsAp
	Verifica Status de Aprovação de um título
	Título possui restrição: Carrega Status de aprovação
	00- Aprovação de pagamento não solicitada
	01- Aprovação de pagamento solicitada
	02- Aprovação de pagamento realizada
	@type  Function
	@version 01
/*/
Static Function VerStsAp(cFILIAL, cPREFIXO, cNUM, cPARCELA, cTIPO, cFORNECE, cLOJA)
	Local cRet
	Local cQrySts := GetNextAlias()

	BeginSql Alias cQrySts
	//INICIO Ticket    429 - Abel Babini - 09/11/2020 - Ajuste na verificação do Status na Central de Aprovação
	SELECT TOP 1
		CASE WHEN ZC7_USRAPR <> '' THEN 1 ELSE 0 END AS REG_APRV,
		CASE WHEN ZC7_USRAPR = '' THEN 1 ELSE 0 END AS REG_AGUARD,
		CASE WHEN ZC7_REPROV <> '' THEN 1 ELSE 0 END AS REG_REPROV
	FROM %TABLE:ZC7% AS ZC7 (NOLOCK)
	WHERE 
				ZC7.ZC7_FILIAL = %Exp:cFILIAL%
		AND ZC7.ZC7_PREFIX = %Exp:cPREFIXO%
		AND ZC7.ZC7_NUM = %Exp:cNUM%
		AND ZC7.ZC7_PARCEL = %Exp:cPARCELA%
		AND ZC7.ZC7_TIPO = %Exp:cTIPO%
		AND ZC7.ZC7_CLIFOR = %Exp:cFORNECE%
		AND ZC7.ZC7_LOJA = %Exp:cLOJA%
		AND ZC7.ZC7_TPBLQ = '000020'
		AND ZC7.ZC7_RECPAG = 'P'
		AND ZC7.%notDel%
	ORDER BY ZC7.R_E_C_N_O_ DESC

	EndSql
	IF (cQrySts)->(EOF())
		cRet := '00 - Aprovação de pagamento não solicitada'
	ELSE
		IF (cQrySts)->REG_REPROV > 0
			cRet := '03- Solicitação rejeitada'
		ELSEIF (cQrySts)->REG_AGUARD > 0
			cRet := '01- Aprovação de pagamento solicitada'
		ELSE
			cRet := '02- Aprovação de pagamento realizada'
		END
	END
	//FIM Ticket    429 - Abel Babini - 09/11/2020 - Ajuste na verificação do Status na Central de Aprovação

	(cQrySts)->(dbCloseArea())

Return cRet

//INICIO Ticket    429 - Abel Babini - 10/11/2020 - Melhoria de Performance na execução das validações das regras e ajustes na regra 04 - Risco de duplicidade
/*/{Protheus.doc} Static Function ChkRegras(cBorIni, cBorFim)
	Valida todas as regras
	@type  Function
	@author Abel Babini
	@since 10/11/2020
/*/
Static Function ChkRegras(cBordero, cTitFil, cTitPre, cTitNum, cTitPar, cTitTip, cTitFor, cTitLoj, dTitVenc, nTitSld, cPortado, cAgeDep, cNumCon, cNomFor, nTitVal, nTitMoed, cTitCBar, cCGCRaiz, cOrigem, cE2FBco, cE2FAge, cE2FCta,  cForBco, cForAge, cForCta, cFatNum, cFatPre, cRecOri, cBorMod)

	Local i	:= 0
	//Regra 01
	Local cRegra01	:= "01 - Borderô possui vencimentos superiores a D+2"
	Local lRegra01	:= .t.
	Local dDtSrv		:= msDate() //Ticket    429 - Abel Babini - 27/11/2020 - Ajuste na chamada da rotina DataValida
	Local nDias			:= 0
	Local nMVDias		:= GetMV("MV_#CNABD2",,2)

	//Regra 02
	Local cRegra02	:= "02 - Borderô possui títulos com devoluções e/ou adiantamentos"
	Local lRegra02	:= .t.
	Local cQryCR02	:= ""
	Local cAlias02	:= ""

	//Regra 03
	Local cRegra03	:= "03 - Borderô possui títulos no receber para CEC"
	Local lRegra03	:= .t.
	Local cQryCR03	:= ""
	Local cAlias03	:= ""
    Local cPreGTA   := GetMV("MV_#PREGTA",,"GT1|GT2|GT3|GT4|GT5|GT6|GT7|GTA|GTB|GTC|GTD|GTE|GTF|GTG|GTH|GTI") // @history Ticket  14432 - Fer Macieira- 08/06/2021 - BLOQUEIO DE GTA - IMPOSTO (PAINEL DE PAGAMENTOS)

	//Regra 04
	Local cRegra04	:= "04 - Borderô possui 2 ou + títulos p/ o mesmo fornecedor/vencimento"
	Local lRegra04	:= .t.
	Local cQryCR04	:= ""
	Local cAlias04	:= ""

	//Regra 05
	Local cRegra05	:= "05 - Borderô possui título referente a ICMS"
	Local lRegra05	:= .t.

	//Regra 06
	Local cRegra06	:= "06 - Borderô possui título baixado totalmente (sem saldo)"
	Local lRegra06	:= .t.

	//Regra 07
	Local cRegra07	:= "07 - Borderô possui título com divergência entre dados bancários cadastrados no fornecedor e no título"
	Local lRegra07	:= .t.
	Local cKeyA2		:= ""
	Local cKeyE2		:= ""

	//Regra 08
	Local cRegra08	:= "08 - Borderô possui título sem NF e/ou aprovação"
	Local lRegra08	:= .t.
	Local cQryCR08	:= ""
	Local cAlias08	:= ""

	//Regra 09
	Local cRegra09	:= "09 - Borderô possui título com divergência entre título e borderô na forma de pagamento predominante"
	Local lRegra09	:= .t.
	Local cQryCR09	:= ""
	Local cAlias09	:= ""
	Local cLastPg		:= GetMV("MV_#LASTPG",,"10")
	Local cPrefExc	:= GetMV("MV_#PREEXC",,"GTA") // Utilizar pipeline se precisar adicionar outros prefixos. Exemplo: GTA|MAN|...
	Local cPgPredo	:= ""
	Local cGrpMod		:= GetMV("MV_#GRMDPG",,"{01/03/41/43},{30/31},{35},{91}") //Ticket   4883 - Abel Babini - 13/12/2020 - Validar modelo de pagamento
	Local aGrpMod		:= StrTokArr(cGrpMod,',')
	Local nGrpBor		:= 0
	Local nGrpPred	:= 0
	Local lVldMod		:= .T.

	//Declara conteúdo padrão das variáveis recebidas como parâmetro na rotina
	Default cBordero := ""
	Default cTitFil	:= ""
	Default cTitPre	:= ""
	Default cTitNum	:= ""
	Default cTitPar	:= ""
	Default cTitTip	:= ""
	Default cTitFor	:= ""
	Default cTitLoj	:= ""
	Default dTitVenc	:= MsDate() 
	Default nTitSld		:= 0 
	Default cPortado	:= "" 
	Default cAgeDep		:= "" 
	Default cNumCon		:= "" 
	Default cNomFor		:= "" 
	Default nTitVal		:= 0 
	Default nTitMoed	:= 0
	Default cTitCBar	:= "" 
	Default cCGCRaiz	:= ""
	Default cOrigem		:= ""
	Default cE2FBco		:= ""
	Default cE2FAge		:= ""
	Default cE2FCta		:= ""
	Default cForBco		:= ""
	Default cForAge		:= ""
	Default cForCta		:= ""
	Default cFatNum		:= ""
	Default cFatPre		:= ""
	Default cRecOri		:= ""
	Default cBorMod		:= ""

	// @history Ticket  14432 - Fer Macieira- 11/06/2021 - BLOQUEIO DE GTA - IMPOSTO (PAINEL DE PAGAMENTOS)
	/*
	De: deborah.ferraro@adoro.com.br <deborah.ferraro@adoro.com.br>
	Para: atendimento@adoro.com.br <atendimento@adoro.com.br> em 11/06/2021 15:51
	Cc: debora.ferraro@adoro.com.br
	Boa Tarde, correto as 9 regras de bloqueios precisam ser destravadas para pagamentos destes impostos.
	Grata
	Deborah
	*/
	If (cTitPre $ cPreGTA)
		Return {lRegra01, lRegra02, lRegra03, lRegra04, lRegra05, lRegra06, lRegra07, lRegra08, lRegra09}
	EndIf 
	//

	//REGRA "01 - Borderô possui vencimentos superiores a D+2"
	dDtSrv := xVrfData(dDtSrv + 1)

	nDias := dTitVenc - dDtSrv
	
	If nDias >= nMVDias
		
		lRegra01 := .f.
		
		aDadBor := {}
		aDadBor := {cBordero, dTitVenc, cPortado, cAgeDep, cNumCon}

		aDadSE2 := {}
		AADD(aDadSE2,{	cTitFil,;
										cTitPre,;
										cTitNum,;
										cTitPar,;
										cTitTip,;
										cTitFor,;
										cTitLoj,;
										cNomFor,;
										dTitVenc,;
										nTitVal,;
										nTitSld,;
										nTitMoed,;
										cTitCBar})

		//Título possui restrição: Carrega Status de aprovação
		//00- Aprovação de pagamento não solicitada
		//01- Aprovação de pagamento solicitada
		//02- Aprovação de pagamento realizada
		// cZC7Sts := VerStsAp(cTitFil, cTitPre, cTitNum, cTitPar, cTitTip, cTitFor, cTitLoj)

		aDadBlq := {}

		GrvTRB("01", cRegra01, aDadBor, aDadSE2, aDadBlq)
			
	Endif

	//REGRA "02 - Borderô possui títulos com devoluções e/ou adiantamentos"
	// NF x Adiantamentos
	IF ! (cTitTip $ MVPAGANT)

		// Adoro
		cQryCR02 := " SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_VENCREA, E2_VALOR, E2_SALDO, E2_MOEDA, E2_CODBAR "
		cQryCR02 += " FROM " + RetSqlName("SE2") + " SE2 (NOLOCK) "
		cQryCR02 += " INNER JOIN " + RetSqlName("SA2") + " SA2 (NOLOCK) ON A2_FILIAL='"+FWxFilial("SA2")+"' AND A2_COD=E2_FORNECE AND A2_LOJA=E2_LOJA AND SA2.D_E_L_E_T_='' "
		cQryCR02 += " WHERE A2_CGC LIKE '"+cCGCRaiz+"%' "
		cQryCR02 += " AND ( E2_TIPO IN "+FormatIn(MVPAGANT,";")+" OR E2_TIPO IN "+FormatIn(MV_CPNEG,"|")+" ) "
		cQryCR02 += " AND E2_SALDO > 0 "
		cQryCR02 += " AND A2_CGC <> '' "
		cQryCR02 += " AND '"+cCGCRaiz+"' <> '' "
		cQryCR02 += " AND SE2.D_E_L_E_T_='' "

			// Demais empresas
		For i:=1 to Len(aEmpresas)

			cQryCR02 += " UNION ALL "
			cQryCR02 += " SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_VENCREA, E2_VALOR, E2_SALDO, E2_MOEDA, E2_CODBAR "

			If Select("SX2EMP") > 0
				SX2EMP->( dbCloseArea() )
			EndIf
					
			dbUseArea(.T., __LocalDriver, cStartPath+"SX2"+AllTrim(aEmpresas[i,1])+"0"+GetDbExtension(), "SX2EMP", .T., .F.)
					
			SX2EMP->( dbSetOrder(1) ) // X2_CHAVE
			If SX2EMP->( dbSeek("SE2") )
				cQryCR02 += " FROM " + AllTrim(SX2EMP->X2_ARQUIVO) + " SE2 (NOLOCK) "
			EndIf

			If SX2EMP->( dbSeek("SA2") )
				cQryCR02 += " INNER JOIN " + AllTrim(SX2EMP->X2_ARQUIVO) + " SA2 (NOLOCK) ON A2_COD=E2_FORNECE AND A2_LOJA=E2_LOJA AND SA2.D_E_L_E_T_='' "
			EndIf

			cQryCR02 += " WHERE A2_CGC LIKE '"+cCGCRaiz+"%' "
			cQryCR02 += " AND ( E2_TIPO IN "+FormatIn(MVPAGANT,";")+" OR E2_TIPO IN "+FormatIn(MV_CPNEG,"|")+" ) "
			cQryCR02 += " AND E2_SALDO > 0 "
			cQryCR02 += " AND A2_CGC <> '' "
			cQryCR02 += " AND '"+cCGCRaiz+"' <> '' "
			cQryCR02 += " AND SE2.D_E_L_E_T_='' "

		Next i

		cAlias02	:= 'TMPTRB02' //GetNextAlias()

		tcQuery cQryCR02 Alias &cAlias02 NEW

		aTamSX3	:= TAMSX3("E2_VALOR")
		tcSetField(cAlias02, "E2_VALOR", aTamSX3[3], aTamSX3[1], aTamSX3[2])

		aTamSX3	:= TAMSX3("E2_SALDO")
		tcSetField(cAlias02, "E2_SALDO", aTamSX3[3], aTamSX3[1], aTamSX3[2])

		aTamSX3	:= TAMSX3("E2_VENCREA")
		tcSetField(cAlias02, "E2_VENCREA", aTamSX3[3], aTamSX3[1], aTamSX3[2])

		(cAlias02)->( dbGoTop() )
		Do While (cAlias02)->( !EOF() )

			lRegra02 := .f.

			aDadBor := {}
			aDadBor := {cBordero, dTitVenc, cPortado, cAgeDep, cNumCon}

			aDadSE2 := {}
			AADD(aDadSE2,{	cTitFil,;
											cTitPre,;
											cTitNum,;
											cTitPar,;
											cTitTip,;
											cTitFor,;
											cTitLoj,;
											cNomFor,;
											dTitVenc,;
											nTitVal,;
											nTitSld,;
											nTitMoed,;
											cTitCBar})


			//Título possui restrição: Carrega Status de aprovação
			//00- Aprovação de pagamento não solicitada
			//01- Aprovação de pagamento solicitada
			//02- Aprovação de pagamento realizada
			cZC7Sts := VerStsAp(cTitFil, cTitPre, cTitNum, cTitPar, cTitTip, cTitFor, cTitLoj)	

			aDadBlq := {}
			aDadBlq := {"P", (cAlias02)->E2_FILIAL, (cAlias02)->E2_PREFIXO, (cAlias02)->E2_NUM, (cAlias02)->E2_PARCELA, (cAlias02)->E2_TIPO, (cAlias02)->E2_FORNECE, (cAlias02)->E2_LOJA, (cAlias02)->E2_NOMFOR, (cAlias02)->E2_VALOR, (cAlias02)->E2_SALDO, (cAlias02)->E2_MOEDA, (cAlias02)->E2_CODBAR, "CNPJ: " + cCGCRaiz + " POSSUI ADIANTAMENTOS/DEVOLUÇÕES"}
				
			IF (Substr(cZC7Sts,1,2)!="02") //'02- Aprovação de pagamento realizada'
				GrvTRB("02", cRegra02, aDadBor, aDadSE2, aDadBlq, cZC7Sts)
			ELSE //Ticket   6266 - Abel Babini - 08/12/2020 - Erro na gravação do registro na Central de Aprovação
				lRegra02 := .T.
			ENDIF

			(cAlias02)->( dbSkip() )

		EndDo
		(cAlias02)->(dbCloseArea())
	
	//Ticket   4883 - Abel Babini - 04/01/2021 - Não bloquear PA´s integradas do SAG
	ElseIf (cTitTip $ MVPAGANT) .AND. !Empty(Alltrim(cRecOri))
		lRegra02 := .t.
		
	// Adiantamentos x NF
	Else
		// Adoro
		cQryCR02 := " SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_VENCREA, E2_VALOR, E2_SALDO, E2_MOEDA, E2_CODBAR "
		cQryCR02 += " FROM " + RetSqlName("SE2") + " SE2 (NOLOCK) "
		cQryCR02 += " INNER JOIN " + RetSqlName("SA2") + " SA2 (NOLOCK) ON A2_FILIAL='"+FWxFilial("SA2")+"' AND A2_COD=E2_FORNECE AND A2_LOJA=E2_LOJA AND SA2.D_E_L_E_T_='' "
		cQryCR02 += " WHERE A2_CGC LIKE '"+cCGCRaiz+"%'
		cQryCR02 += " AND E2_TIPO NOT IN "+FormatIn(MVPAGANT,";")
		cQryCR02 += " AND E2_SALDO > 0 "
		cQryCR02 += " AND A2_CGC <> '' "
		cQryCR02 += " AND '"+cCGCRaiz+"' <> '' "
		cQryCR02 += " AND SE2.D_E_L_E_T_='' "

		// Demais empresas
		For i:=1 to Len(aEmpresas)

			cQryCR02 += " UNION ALL "
			cQryCR02 += " SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_VENCREA, E2_VALOR, E2_SALDO, E2_MOEDA, E2_CODBAR "

			If Select("SX2EMP") > 0
				SX2EMP->( dbCloseArea() )
			EndIf
					
			dbUseArea(.T., __LocalDriver, cStartPath+"SX2"+AllTrim(aEmpresas[i,1])+"0"+GetDbExtension(), "SX2EMP", .T., .F.)
					
			SX2EMP->( dbSetOrder(1) ) // X2_CHAVE
			If SX2EMP->( dbSeek("SE2") )
				cQryCR02 += " FROM " + AllTrim(SX2EMP->X2_ARQUIVO) + " SE2 (NOLOCK) "
			EndIf

			If SX2EMP->( dbSeek("SA2") )
				cQryCR02 += " INNER JOIN " + AllTrim(SX2EMP->X2_ARQUIVO) + " SA2 (NOLOCK) ON A2_COD=E2_FORNECE AND A2_LOJA=E2_LOJA AND SA2.D_E_L_E_T_='' "
			EndIf

			cQryCR02 += " WHERE A2_CGC LIKE '"+cCGCRaiz+"%'
			cQryCR02 += " AND E2_TIPO NOT IN "+FormatIn(MVPAGANT,";")
			cQryCR02 += " AND E2_SALDO > 0 "
			cQryCR02 += " AND A2_CGC <> '' "
			cQryCR02 += " AND '"+cCGCRaiz+"' <> '' "
			cQryCR02 += " AND SE2.D_E_L_E_T_='' "

		Next i

		cAlias02	:= 'TMPTRB02' //GetNextAlias()

		tcQuery cQryCR02 Alias &cAlias02 NEW

		aTamSX3	:= TAMSX3("E2_VALOR")
		tcSetField(cAlias02, "E2_VALOR", aTamSX3[3], aTamSX3[1], aTamSX3[2])

		aTamSX3	:= TAMSX3("E2_SALDO")
		tcSetField(cAlias02, "E2_SALDO", aTamSX3[3], aTamSX3[1], aTamSX3[2])

		aTamSX3	:= TAMSX3("E2_VENCREA")
		tcSetField(cAlias02, "E2_VENCREA", aTamSX3[3], aTamSX3[1], aTamSX3[2])

		(cAlias02)->( dbGoTop() )
		Do While (cAlias02)->( !EOF() )

			lRegra02 := .f.

			aDadBor := {}
			aDadBor := {cBordero, dTitVenc, cPortado, cAgeDep, cNumCon}

			aDadSE2 := {}
			AADD(aDadSE2,{	cTitFil,;
											cTitPre,;
											cTitNum,;
											cTitPar,;
											cTitTip,;
											cTitFor,;
											cTitLoj,;
											cNomFor,;
											dTitVenc,;
											nTitVal,;
											nTitSld,;
											nTitMoed,;
											cTitCBar})


			//Título possui restrição: Carrega Status de aprovação
			//00- Aprovação de pagamento não solicitada
			//01- Aprovação de pagamento solicitada
			//02- Aprovação de pagamento realizada
			cZC7Sts := VerStsAp(cTitFil, cTitPre, cTitNum, cTitPar, cTitTip, cTitFor, cTitLoj)	

			aDadBlq := {}
			aDadBlq := {"P", (cAlias02)->E2_FILIAL, (cAlias02)->E2_PREFIXO, (cAlias02)->E2_NUM, (cAlias02)->E2_PARCELA, (cAlias02)->E2_TIPO, (cAlias02)->E2_FORNECE, (cAlias02)->E2_LOJA, (cAlias02)->E2_NOMFOR, (cAlias02)->E2_VALOR, (cAlias02)->E2_SALDO, (cAlias02)->E2_MOEDA, (cAlias02)->E2_CODBAR, "CNPJ: " + cCGCRaiz + " POSSUI ADIANTAMENTOS/DEVOLUÇÕES"}
				
			IF (Substr(cZC7Sts,1,2)!="02") //'02- Aprovação de pagamento realizada'
				GrvTRB("02", cRegra02, aDadBor, aDadSE2, aDadBlq, cZC7Sts)
			ELSE //Ticket   6266 - Abel Babini - 08/12/2020 - Erro na gravação do registro na Central de Aprovação
				lRegra02 := .T.
			ENDIF

			(cAlias02)->( dbSkip() )

		EndDo

		If Select(cAlias02) > 0
			(cAlias02)->( dbCloseArea() )
		EndIf

		If Select("SX2EMP") > 0
			SX2EMP->( dbCloseArea() )
		EndIf
		
	EndIf
	
	//REGRA "03 - Borderô possui títulos no receber para CEC"
	If !(cTitPre $ cPreGTA) // @history Ticket  14432 - Fer Macieira- 08/06/2021 - BLOQUEIO DE GTA - IMPOSTO (PAINEL DE PAGAMENTOS)
    
        // Adoro
        cQryCR03 := " SELECT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_VALOR, E1_SALDO, E1_MOEDA "
        cQryCR03 += " FROM " + RetSqlName("SE1") + " SE1 (NOLOCK) "
        cQryCR03 += " INNER JOIN " + RetSqlName("SA1") + " SA1 (NOLOCK) ON A1_FILIAL='"+FWxFilial("SA1")+"' AND A1_COD=E1_CLIENTE AND A1_LOJA=E1_LOJA AND SA1.D_E_L_E_T_='' "
        cQryCR03 += " WHERE A1_CGC LIKE '"+cCGCRaiz+"%' "
        cQryCR03 += " AND E1_SALDO > 0 "
        cQryCR03 += " AND A1_CGC <> '' "
        cQryCR03 += " AND '"+cCGCRaiz+"' <> '' "
        cQryCR03 += " AND SE1.D_E_L_E_T_='' "

        // Demais empresas
        For i:=1 to Len(aEmpresas)

            cQryCR03 += " UNION ALL "
            cQryCR03 += " SELECT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_VALOR, E1_SALDO, E1_MOEDA "

            If Select("SX2EMP") > 0
                SX2EMP->( dbCloseArea() )
            EndIf
                    
            dbUseArea(.T., __LocalDriver, cStartPath+"SX2"+AllTrim(aEmpresas[i,1])+"0"+GetDbExtension(), "SX2EMP", .T., .F.)
                    
            SX2EMP->( dbSetOrder(1) ) // X2_CHAVE
            If SX2EMP->( dbSeek("SE1") )
                cQryCR03 += " FROM " + AllTrim(SX2EMP->X2_ARQUIVO) + " SE1 (NOLOCK) "
            EndIf

            If SX2EMP->( dbSeek("SA1") )
                cQryCR03 += " INNER JOIN " + AllTrim(SX2EMP->X2_ARQUIVO) + " SA1 (NOLOCK) ON A1_COD=E1_CLIENTE AND A1_LOJA=E1_LOJA AND SA1.D_E_L_E_T_='' "
            EndIf

            cQryCR03 += " WHERE A1_CGC LIKE '"+cCGCRaiz+"%' "
            cQryCR03 += " AND E1_SALDO > 0 "
            cQryCR03 += " AND A1_CGC <> '' "
            cQryCR03 += " AND '"+cCGCRaiz+"' <> '' "
            cQryCR03 += " AND SE1.D_E_L_E_T_='' "

        Next i

        cAlias03 := 'TMPTRB03' //GetNextAlias()

        tcQuery cQryCR03 Alias &cAlias03 NEW

        aTamSX3	:= TAMSX3("E1_VALOR")
        tcSetField(cAlias03, "E1_VALOR", aTamSX3[3], aTamSX3[1], aTamSX3[2])

        aTamSX3	:= TAMSX3("E1_SALDO")
        tcSetField(cAlias03, "E1_SALDO", aTamSX3[3], aTamSX3[1], aTamSX3[2])

        aTamSX3	:= TAMSX3("E1_VENCREA")
        tcSetField(cAlias03, "E1_VENCREA", aTamSX3[3], aTamSX3[1], aTamSX3[2])

        (cAlias03)->( dbGoTop() )
        Do While (cAlias03)->( !EOF() )
            lRegra03 := .f.

            aDadBor := {}
            aDadBor := {cBordero, dTitVenc, cPortado, cAgeDep, cNumCon}

            aDadSE2 := {}
            AADD(aDadSE2,{	cTitFil,;
                                            cTitPre,;
                                            cTitNum,;
                                            cTitPar,;
                                            cTitTip,;
                                            cTitFor,;
                                            cTitLoj,;
                                            cNomFor,;
                                            dTitVenc,;
                                            nTitVal,;
                                            nTitSld,;
                                            nTitMoed,;
                                            cTitCBar})


            //Título possui restrição: Carrega Status de aprovação
            //00- Aprovação de pagamento não solicitada
            //01- Aprovação de pagamento solicitada
            //02- Aprovação de pagamento realizada
            cZC7Sts := VerStsAp(cTitFil, cTitPre, cTitNum, cTitPar, cTitTip, cTitFor, cTitLoj)	

            aDadBlq := {}
            aDadBlq := {"R", (cAlias03)->E1_FILIAL, (cAlias03)->E1_PREFIXO, (cAlias03)->E1_NUM, (cAlias03)->E1_PARCELA, (cAlias03)->E1_TIPO, (cAlias03)->E1_CLIENTE, (cAlias03)->E1_LOJA, (cAlias03)->E1_NOMCLI, (cAlias03)->E1_VALOR, (cAlias03)->E1_SALDO, (cAlias03)->E1_MOEDA, "", "CNPJ: " + cCGCRaiz + " POSSUI CONTAS A RECEBER EM ABERTO"}
            IF (Substr(cZC7Sts,1,2)!="02") //'02- Aprovação de pagamento realizada'
                GrvTRB("03", cRegra03, aDadBor, aDadSE2, aDadBlq, cZC7Sts)
            ELSE //Ticket   6266 - Abel Babini - 08/12/2020 - Erro na gravação do registro na Central de Aprovação
                lRegra03 := .T.
            ENDIF

            (cAlias03)->( dbSkip() )

        EndDo

        If Select(cAlias03) > 0
            (cAlias03)->( dbCloseArea() )
        EndIf

        If Select("SX2EMP") > 0
            SX2EMP->( dbCloseArea() )
        EndIf

    EndIf

	//REGRA "04 - Borderô possui 2 ou + títulos p/ o mesmo fornecedor/vencimento"
	cQryCR04 := " SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_VENCREA, E2_VALOR, E2_SALDO, E2_MOEDA, E2_CODBAR "
	cQryCR04 += " FROM " + RetSqlName("SE2") + " SE2 (NOLOCK) "
	cQryCR04 += " INNER JOIN " + RetSqlName("SA2") + " SA2 (NOLOCK) ON A2_FILIAL='"+FWxFilial("SA2")+"' AND A2_COD=E2_FORNECE AND A2_LOJA=E2_LOJA AND SA2.D_E_L_E_T_='' "
	cQryCR04 += " WHERE SA2.A2_CGC LIKE '"+cCGCRaiz+"%' "
	cQryCR04 += " AND SA2.A2_CGC <> '' "
	cQryCR04 += " AND '"+cCGCRaiz+"' <> '' "
	cQryCR04 += " AND SE2.E2_NUM = '"+cTitNum+"' "
	cQryCR04 += " AND SE2.E2_VALOR = "+Alltrim(Str(nTitVal))+" "
	cQryCR04 += " AND ( SE2.E2_EMISSAO BETWEEN '"+DtoS(dTitVenc-60)+"' AND '"+DtoS(dTitVenc+60)+"' "
	cQryCR04 += " OR SE2.E2_EMIS1 BETWEEN '"+DtoS(dTitVenc-60)+"' AND '"+DtoS(dTitVenc+60)+"' ) "
	cQryCR04 += " AND SE2.E2_PREFIXO <> '"+cTitPre+"' "
	cQryCR04 += " AND SE2.D_E_L_E_T_='' "

		// Demais empresas
	For i:=1 to Len(aEmpresas)

		cQryCR04 += " UNION ALL "
		cQryCR04 := " SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_VENCREA, E2_VALOR, E2_SALDO, E2_MOEDA, E2_CODBAR "

		If Select("SX2EMP") > 0
			SX2EMP->( dbCloseArea() )
		EndIf
				
		dbUseArea(.T., __LocalDriver, cStartPath+"SX2"+AllTrim(aEmpresas[i,1])+"0"+GetDbExtension(), "SX2EMP", .T., .F.)
					
		SX2EMP->( dbSetOrder(1) ) // X2_CHAVE
		If SX2EMP->( dbSeek("SE2") )
			cQryCR04 += " FROM " + AllTrim(SX2EMP->X2_ARQUIVO) + " SE2 (NOLOCK) "
		EndIf

		If SX2EMP->( dbSeek("SA2") )
			cQryCR04 += " INNER JOIN " + AllTrim(SX2EMP->X2_ARQUIVO) + " SA2 (NOLOCK) ON A2_COD=E2_FORNECE AND A2_LOJA=E2_LOJA AND SA2.D_E_L_E_T_='' "
		EndIf

		cQryCR04 += " WHERE A2_CGC LIKE '"+cCGCRaiz+"%' "
		cQryCR04 += " AND SA2.A2_CGC <> '' "
		cQryCR04 += " AND '"+cCGCRaiz+"' <> '' "
		cQryCR04 += " AND SE2.E2_NUM = '"+cTitNum+"' "
		cQryCR04 += " AND SE2.E2_VALOR = "+Alltrim(Str(nTitVal))+" "
		cQryCR04 += " AND ( SE2.E2_EMISSAO BETWEEN '"+DtoS(dTitVenc-60)+"' AND '"+DtoS(dTitVenc+60)+"' "
		cQryCR04 += " OR SE2.E2_EMIS1 BETWEEN '"+DtoS(dTitVenc-60)+"' AND '"+DtoS(dTitVenc+60)+"' ) "
		cQryCR04 += " AND SE2.E2_PREFIXO <> '"+cTitPre+"' "
		cQryCR04 += " AND SE2.D_E_L_E_T_='' "

	Next i

	cAlias04 := 'TMPTRB04' //GetNextAlias()

	tcQuery cQryCR04 Alias &cAlias04 NEW

	aTamSX3	:= TAMSX3("E2_VENCREA")
	tcSetField(cAlias04, "E2_VENCREA", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	aTamSX3	:= TAMSX3("E2_VALOR")
	tcSetField(cAlias04, "E2_VALOR", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	aTamSX3	:= TAMSX3("E2_SALDO")
	tcSetField(cAlias04, "E2_SALDO", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	(cAlias04)->( dbGoTop() )
	Do While (cAlias04)->( !EOF() )

		lRegra04 := .f.

		aDadBor := {}
		aDadBor := {cBordero, dTitVenc, cPortado, cAgeDep, cNumCon}

		aDadSE2 := {}
		AADD(aDadSE2,{	cTitFil,;
										cTitPre,;
										cTitNum,;
										cTitPar,;
										cTitTip,;
										cTitFor,;
										cTitLoj,;
										cNomFor,;
										dTitVenc,;
										nTitVal,;
										nTitSld,;
										nTitMoed,;
										cTitCBar})

		//Título possui restrição: Carrega Status de aprovação
		//00- Aprovação de pagamento não solicitada
		//01- Aprovação de pagamento solicitada
		//02- Aprovação de pagamento realizada
		cZC7Sts := VerStsAp(cTitFil, cTitPre, cTitNum, cTitPar, cTitTip, cTitFor, cTitLoj)	
					
		aDadBlq := {}
		aDadBlq := {"P", (cAlias04)->E2_FILIAL, (cAlias04)->E2_PREFIXO, (cAlias04)->E2_NUM, (cAlias04)->E2_PARCELA, (cAlias04)->E2_TIPO, (cAlias04)->E2_FORNECE, (cAlias04)->E2_LOJA, (cAlias04)->E2_NOMFOR, (cAlias04)->E2_VALOR, (cAlias04)->E2_SALDO, (cAlias04)->E2_MOEDA, (cAlias04)->E2_CODBAR, "CNPJ: " + cCGCRaiz + " POSSUI TITULOS EM DUPLICIDADE"}
		IF (Substr(cZC7Sts,1,2)!="02") //'02- Aprovação de pagamento realizada'
			GrvTRB("04", cRegra04, aDadBor, aDadSE2, aDadBlq, cZC7Sts)
		ELSE //Ticket   6266 - Abel Babini - 08/12/2020 - Erro na gravação do registro na Central de Aprovação
			lRegra04 := .T.
		ENDIF

		(cAlias04)->( dbSkip() )

	EndDo

	If Select(cAlias04) > 0
		(cAlias04)->( dbCloseArea() )
	EndIf

	If Select("SX2EMP") > 0
		SX2EMP->( dbCloseArea() )
	EndIf

	//REGRA "05 - Borderô possui título referente a ICMS"
	IF cOrigem == 'MATA953'
		lRegra05 := .f.

		aDadBor := {}
		aDadBor := {cBordero, dTitVenc, cPortado, cAgeDep, cNumCon}

		aDadSE2 := {}
		AADD(aDadSE2,{	cTitFil,;
										cTitPre,;
										cTitNum,;
										cTitPar,;
										cTitTip,;
										cTitFor,;
										cTitLoj,;
										cNomFor,;
										dTitVenc,;
										nTitVal,;
										nTitSld,;
										nTitMoed,;
										cTitCBar})

		//Título possui restrição: Carrega Status de aprovação
		//00- Aprovação de pagamento não solicitada
		//01- Aprovação de pagamento solicitada
		//02- Aprovação de pagamento realizada
		cZC7Sts := VerStsAp(cTitFil, cTitPre, cTitNum, cTitPar, cTitTip, cTitFor, cTitLoj)	
					
		aDadBlq := {}
		aDadBlq := {"P", cTitFil, cTitPre, cTitNum, cTitPar, cTitTip, cTitFor, cTitLoj, cNomFor, nTitVal, nTitSld, nTitMoed, cTitCBar, ""}
		IF (Substr(cZC7Sts,1,2)!="02") //'02- Aprovação de pagamento realizada'
			GrvTRB("05", cRegra05, aDadBor, aDadSE2, aDadBlq, cZC7Sts)
		ELSE //Ticket   6266 - Abel Babini - 08/12/2020 - Erro na gravação do registro na Central de Aprovação
			lRegra05 := .T.
		ENDIF
	ENDIF

	//REGRA "06 - Borderô possui título baixado totalmente (sem saldo)"
	IF nTitSld == 0
		lRegra06 := .f.

		aDadBor := {}
		aDadBor := {cBordero, dTitVenc, cPortado, cAgeDep, cNumCon}

		aDadSE2 := {}
		AADD(aDadSE2,{	cTitFil,;
										cTitPre,;
										cTitNum,;
										cTitPar,;
										cTitTip,;
										cTitFor,;
										cTitLoj,;
										cNomFor,;
										dTitVenc,;
										nTitVal,;
										nTitSld,;
										nTitMoed,;
										cTitCBar})

		//Título possui restrição: Carrega Status de aprovação
		//00- Aprovação de pagamento não solicitada
		//01- Aprovação de pagamento solicitada
		//02- Aprovação de pagamento realizada
		cZC7Sts := VerStsAp(cTitFil, cTitPre, cTitNum, cTitPar, cTitTip, cTitFor, cTitLoj)	
					
		aDadBlq := {}
		aDadBlq := {"P", cTitFil, cTitPre, cTitNum, cTitPar, cTitTip, cTitFor, cTitLoj, cNomFor, nTitVal, nTitSld, nTitMoed, cTitCBar, ""}
		IF (Substr(cZC7Sts,1,2)!="02") //'02- Aprovação de pagamento realizada'
			GrvTRB("06", cRegra06, aDadBor, aDadSE2, aDadBlq, cZC7Sts)
		ELSE //Ticket   6266 - Abel Babini - 08/12/2020 - Erro na gravação do registro na Central de Aprovação
			lRegra06 := .T.		
		ENDIF
	ENDIF

	//REGRA "07 - Borderô possui título com divergência entre dados bancários cadastrados no fornecedor e no título"

	cKeyA2 := Alltrim(cForBco) + Alltrim(cForAge) + Alltrim(cForCta)
	cKeyE2 := Alltrim(cE2FBco) + Alltrim(cE2FAge) + Alltrim(cE2FCta)
	IF cKeyA2 <> cKeyE2
		lRegra07 := .f.

		aDadBor := {}
		aDadBor := {cBordero, dTitVenc, cPortado, cAgeDep, cNumCon}

		aDadSE2 := {}
		AADD(aDadSE2,{	cTitFil,;
										cTitPre,;
										cTitNum,;
										cTitPar,;
										cTitTip,;
										cTitFor,;
										cTitLoj,;
										cNomFor,;
										dTitVenc,;
										nTitVal,;
										nTitSld,;
										nTitMoed,;
										cTitCBar})

		//Título possui restrição: Carrega Status de aprovação
		//00- Aprovação de pagamento não solicitada
		//01- Aprovação de pagamento solicitada
		//02- Aprovação de pagamento realizada
		cZC7Sts := VerStsAp(cTitFil, cTitPre, cTitNum, cTitPar, cTitTip, cTitFor, cTitLoj)	
					
		aDadBlq := {}
		aDadBlq := {"P", cTitFil, cTitPre, cTitNum, cTitPar, cTitTip, cTitFor, cTitLoj, cNomFor, nTitVal, nTitSld, nTitMoed, cTitCBar, "Dados Bancários - Forn: " + cKeyA2 + " x Tít: " + cKeyE2}
		IF (Substr(cZC7Sts,1,2)!="02") //'02- Aprovação de pagamento realizada'
			GrvTRB("07", cRegra07, aDadBor, aDadSE2, aDadBlq, cZC7Sts)
		ELSE //Ticket   6266 - Abel Babini - 08/12/2020 - Erro na gravação do registro na Central de Aprovação
			lRegra07 := .T.
		ENDIF
	ENDIF

	//REGRA "08 - Borderô possui título sem NF e/ou aprovação"
	If AllTrim(cTitTip) == "FT"
		cQryCR08 := ""
		cQryCR08 += " SELECT  " 
		cQryCR08 += " E2_FATURA, E2_FATFOR, E2_FATLOJ, E2_FATPREF, E2_FILIAL,  " 
		cQryCR08 += " E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE,  " 
		cQryCR08 += " E2_LOJA, E2_NOMFOR, E2_VALOR, E2_SALDO, E2_MOEDA, E2_CODBAR " 
		cQryCR08 += " FROM  " 
		cQryCR08 += " " + RetSqlName("SE2") + " (NOLOCK) SE2    " 
		cQryCR08 += " INNER JOIN " 
		cQryCR08 += " (SELECT D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_PEDIDO, D1_ITEMPC FROM " + RetSqlName("SD1") + " (NOLOCK) SD1 WHERE D1_FILIAL = '" + cTitFil + "' AND SD1.D_E_L_E_T_ = '') AS SD1 ON " 
		cQryCR08 += " E2_FILIAL = D1_FILIAL " 
		cQryCR08 += " AND E2_NUM = D1_DOC " 
		cQryCR08 += " AND E2_PREFIXO = D1_SERIE " 
		cQryCR08 += " AND E2_FORNECE = D1_FORNECE " 
		cQryCR08 += " AND E2_LOJA = D1_LOJA " 
		cQryCR08 += " INNER JOIN " 
		cQryCR08 += " (SELECT C7_FILIAL, C7_NUM, C7_ITEM FROM " + RetSqlName("SC7") + " (NOLOCK) AS SC7 WHERE C7_FILIAL = '" + cTitFil + "' AND C7_CONAPRO = 'L' AND SC7.D_E_L_E_T_ = '') AS SC7 ON " 
		cQryCR08 += " D1_FILIAL = C7_FILIAL " 
		cQryCR08 += " AND D1_PEDIDO = C7_NUM " 
		cQryCR08 += " AND D1_ITEMPC = C7_ITEM " 
		cQryCR08 += " INNER JOIN " 
		cQryCR08 += " (SELECT F1_FILIAL, F1_SERIE, F1_DOC, F1_FORNECE, F1_LOJA FROM " + RetSqlName("SF1") + " (NOLOCK) AS SF1 WHERE F1_FILIAL = '" + cTitFil + "' AND F1_DOC = '" +cTitNum + "' AND F1_SERIE = '" + cTitPre + "' AND F1_FORNECE = '" + cTitFor + "' AND F1_LOJA = '" + cTitLoj + "' AND F1_CODIGEN > 0 AND SF1.D_E_L_E_T_ = '') AS SF1 ON " 
		cQryCR08 += " F1_FILIAL = E2_FILIAL "
		cQryCR08 += " AND F1_SERIE = E2_PREFIXO "
		cQryCR08 += " AND F1_DOC = E2_NUM "
		cQryCR08 += " AND F1_FORNECE = E2_FORNECE "
		cQryCR08 += " AND F1_LOJA = E2_LOJA "
		cQryCR08 += " WHERE  " 
		cQryCR08 += " E2_FILIAL =      '" + cTitFil  + "' "
		cQryCR08 += " AND E2_FATURA =  '" + cFatNum  + "' "
		cQryCR08 += " AND E2_FORNECE = '" + cTitFor + "' "
		cQryCR08 += " AND E2_LOJA =    '" + cTitLoj    + "' "
		cQryCR08 += " AND E2_FATPREF=  '" + cFatPre + "' " 
		cQryCR08 += " AND ISNULL(C7_NUM,'') = '' "
		cQryCR08 += " AND SE2.D_E_L_E_T_= '' " 

		cAlias08 := 'TMPTRB08' //GetNextAlias()

		tcQuery cQryCR08 Alias &cAlias08 NEW

		(cAlias08)->( dbGoTop() )
		Do While (cAlias08)->( !EOF() )
			lRegra08	:= .f.

			aDadBor := {}
			aDadBor := {cBordero, dTitVenc, cPortado, cAgeDep, cNumCon}

			aDadSE2 := {}
			AADD(aDadSE2,{	cTitFil,;
											cTitPre,;
											cTitNum,;
											cTitPar,;
											cTitTip,;
											cTitFor,;
											cTitLoj,;
											cNomFor,;
											dTitVenc,;
											nTitVal,;
											nTitSld,;
											nTitMoed,;
											cTitCBar})

			//Título possui restrição: Carrega Status de aprovação
			//00- Aprovação de pagamento não solicitada
			//01- Aprovação de pagamento solicitada
			//02- Aprovação de pagamento realizada
			cZC7Sts := VerStsAp(cTitFil, cTitPre, cTitNum, cTitPar, cTitTip, cTitFor, cTitLoj)	
					
			aDadBlq := {}
			aDadBlq := {"P", cTitFil, cTitPre, cTitNum, cTitPar, cTitTip, cTitFor, cTitLoj, cNomFor, nTitVal, nTitSld, nTitMoed, cTitCBar, "Fatura: " + cFatPre + "/" + cFatNum + " , Fornecedor: " + cTitFor + "-" + cTitLoj}
			IF (Substr(cZC7Sts,1,2)!="02") //'02- Aprovação de pagamento realizada'
				GrvTRB("08", cRegra08, aDadBor, aDadSE2, aDadBlq, cZC7Sts)
			ELSE //Ticket   6266 - Abel Babini - 08/12/2020 - Erro na gravação do registro na Central de Aprovação
				lRegra08 := .T.
			ENDIF
		
			(cAlias08)->( dbSkip() )

		EndDo
		(cAlias08)->( dbCloseArea() )

	ElseIf AllTrim(cTitTip) == "PA" .AND. AllTrim(cRecOri) != ''
		// Titulos de PA integrados oriundos do SAG não necessita bloqueio
		lRegra08 := .T. //Ticket   8093 - Abel Babini - 15/01/2021 - Erro na verificação de títulos em outras unidades

	Else

		lE2Ok := .f.
			
		SD1->( dbSetOrder(1) ) // D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM, R_E_C_N_O_, D_E_L_E_T_
		If SD1->( dbSeek(cTitFil+cTitNum+cTitPre+cTitFor+cTitLoj) )

			SC7->( dbSetOrder(1) ) // C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN, R_E_C_N_O_, D_E_L_E_T_
			If SC7->( dbSeek(SD1->(D1_FILIAL+D1_PEDIDO+D1_ITEMPC)) )

				If AllTrim(SC7->C7_CONAPRO) == "L" 
					lE2Ok := .t.
				EndIf

			EndIf

			//Não bloquear NF´s originadas no SAG.
			SF1->( dbSetOrder(1) ) // F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO
			If SF1->( dbSeek(cTitFil+cTitNum+cTitPre+cTitFor+cTitLoj+SD1->D1_TIPO) ) .AND. !lE2Ok
				lE2Ok := IIF(SF1->F1_CODIGEN > 0,.T.,.F.)
			Endif
		EndIf

		If !lE2Ok

			lRegra08 := .f.


			aDadBor := {}
			aDadBor := {cBordero, dTitVenc, cPortado, cAgeDep, cNumCon}

			aDadSE2 := {}
			AADD(aDadSE2,{	cTitFil,;
											cTitPre,;
											cTitNum,;
											cTitPar,;
											cTitTip,;
											cTitFor,;
											cTitLoj,;
											cNomFor,;
											dTitVenc,;
											nTitVal,;
											nTitSld,;
											nTitMoed,;
											cTitCBar})

			//Título possui restrição: Carrega Status de aprovação
			//00- Aprovação de pagamento não solicitada
			//01- Aprovação de pagamento solicitada
			//02- Aprovação de pagamento realizada
			cZC7Sts := VerStsAp(cTitFil, cTitPre, cTitNum, cTitPar, cTitTip, cTitFor, cTitLoj)	
					
			aDadBlq := {}
			aDadBlq := {"P", cTitFil, cTitPre, cTitNum, cTitPar, cTitTip, cTitFor, cTitLoj, cNomFor, nTitVal, nTitSld, nTitMoed, cTitCBar, "NF: " + SD1->D1_DOC + "/" + SD1->D1_SERIE + " , PC: " + SD1->D1_PEDIDO + "/" + SD1->D1_ITEMPC + ", Liberação: " + SC7->C7_CONAPRO}

			IF (Substr(cZC7Sts,1,2)!="02") //'02- Aprovação de pagamento realizada'
				GrvTRB("08", cRegra08, aDadBor, aDadSE2, aDadBlq, cZC7Sts)
			ELSE //Ticket   6266 - Abel Babini - 08/12/2020 - Erro na gravação do registro na Central de Aprovação
				lRegra08 := .T.
			ENDIF
		
		EndIf
		
	ENDIF

	//REGRA "09 - Borderô possui título com divergência entre título e borderô na forma de pagamento predominante"
	IF !(cTitPre $ cPrefExc) 
		//-- PREDOMINANCIA DOS PAGAMENTOS NOS ULTIMOS PAGAMENTOS
		//Ticket  14431 - Abel Babini - 24/05/2021 - Correção na regra de Divergência na forma de pagamentos
		cQryCR09 := " SELECT RES.EA_MODELO, COUNT(1) TT FROM ("
		cQryCR09 += " SELECT TOP " + cLastPg + " EA_MODELO"
		cQryCR09 += " FROM " + RetSqlName("SE2") + " SE2 (NOLOCK) "
		cQryCR09 += " INNER JOIN " + RetSqlName("SEA") + " SEA (NOLOCK) ON EA_FILIAL='"+FWxFilial("SEA")+"' AND EA_NUMBOR=E2_NUMBOR AND EA_PREFIXO=E2_PREFIXO AND EA_NUM=E2_NUM AND EA_PARCELA=E2_PARCELA AND EA_TIPO=E2_TIPO AND EA_FORNECE=E2_FORNECE AND EA_LOJA=E2_LOJA AND EA_CART='P' AND SEA.D_E_L_E_T_='' "
		cQryCR09 += " INNER JOIN " + RetSqlName("SA2") + " SA2 (NOLOCK) ON A2_FILIAL='"+FWxFilial("SA2")+"' AND A2_COD=E2_FORNECE AND A2_LOJA=E2_LOJA AND SA2.D_E_L_E_T_='' "
		cQryCR09 += " WHERE EA_DATABOR <= '"+DtoS(msDate())+"' "
		cQryCR09 += " AND E2_FORNECE='"+cTitFor+"' "
		cQryCR09 += " AND E2_LOJA='"+cTitLoj+"'  "
		cQryCR09 += " AND SE2.D_E_L_E_T_='' "
		cQryCR09 += " ORDER BY EA_DATABOR DESC ) AS RES "
		cQryCR09 += " GROUP BY EA_MODELO "
		cQryCR09 += " ORDER BY 2 DESC "

		cAlias09	:= 'TMPTRB09' //GetNextAlias()

		tcQuery cQryCR09 Alias &cAlias09 NEW

		(cAlias09)->( dbGoTop() )
		If (cAlias09)->( !EOF() )
			cPgPredo	:= (cAlias09)->EA_MODELO
		EndIf

		(cAlias09)->( dbCloseArea() )

		//INICIO Ticket   4883 - Abel Babini - 13/12/2020 - Validar modelo de pagamento
		nGrpBor := 0
		nGrpPred:= 0

		For i := 1 to Len(aGrpMod)
			IF cPgPredo $ aGrpMod[i]
				nGrpPred := i
			ENDIF
			IF cBorMod $ aGrpMod[i]
				nGrpBor := i
			ENDIF
		Next i
		IF nGrpBor != nGrpPred .or. (nGrpBor == 0 .AND. nGrpPred == 0)
			lVldMod := .F.
		ELSE
			lVldMod := .T.
		ENDIF
		//FIM Ticket   4883 - Abel Babini - 13/12/2020 - Validar modelo de pagamento
		IF cPgPredo != cBorMod .AND. !lVldMod
			lRegra09 := .f.


			aDadBor := {}
			aDadBor := {cBordero, dTitVenc, cPortado, cAgeDep, cNumCon}

			aDadSE2 := {}
			AADD(aDadSE2,{	cTitFil,;
											cTitPre,;
											cTitNum,;
											cTitPar,;
											cTitTip,;
											cTitFor,;
											cTitLoj,;
											cNomFor,;
											dTitVenc,;
											nTitVal,;
											nTitSld,;
											nTitMoed,;
											cTitCBar})

			//Título possui restrição: Carrega Status de aprovação
			//00- Aprovação de pagamento não solicitada
			//01- Aprovação de pagamento solicitada
			//02- Aprovação de pagamento realizada
			cZC7Sts := VerStsAp(cTitFil, cTitPre, cTitNum, cTitPar, cTitTip, cTitFor, cTitLoj)	
					
			aDadBlq := {}
			aDadBlq := {"P", cTitFil, cTitPre, cTitNum, cTitPar, cTitTip, cTitFor, cTitLoj, cNomFor, nTitVal, nTitSld, nTitMoed, cTitCBar, "Forma Pgto Predominante: " + cPgPredo + " , Forma Pgto Borderô: " + cBorMod}

			IF (Substr(cZC7Sts,1,2)!="02") //'02- Aprovação de pagamento realizada'
				GrvTRB("09", cRegra09, aDadBor, aDadSE2, aDadBlq, cZC7Sts)
			ELSE //Ticket   6266 - Abel Babini - 08/12/2020 - Erro na gravação do registro na Central de Aprovação
				lRegra09 := .T.
			ENDIF
		
		ENDIF

	ENDIF

Return {lRegra01, lRegra02, lRegra03, lRegra04, lRegra05, lRegra06, lRegra07, lRegra08, lRegra09}

//FIM Ticket    429 - Abel Babini - 10/11/2020 - Melhoria de Performance na execução das validações das regras e ajustes na regra 04 - Risco de duplicidade

//INICIO Ticket    429 - Abel Babini - 30/11/2020 - Substituição da rotina DataValida que causa error.log
/*/{Protheus.doc} User Function xVrfData
    Função para substituir a rotina padrão DataValida
    @type  Function
    @author FWNM
    @since 01/09/2020
/*/
Static Function xVrfData(dDtAtu)
	Local aArea := GetArea() //Ticket    429 - Abel Babini - 08/12/2020 - Ajuste no fonte para utilizar GetArea / ResArea
	Local nDiaSem 	:= 0
	Local dRet			:= msDate()
	Local _lTerm		:= .F.
	Local _lMudou		:= .F.
	Local _aFeriad	:= {}
	Local i 				:= 1

	Default dDtAtu	:= msDate()

	//INICIO Ticket   4883 - Abel Babini - 21/12/2020 - Geração de Borderô Automático e correção de error.log (Rotina comentada em 21/12/2020 em função de error.log na LIB)
	//CHKFILE("SX5", .F.) //Ticket   6266 - Abel Babini - 08/12/2020 - Erro na gravação do registro na Central de Aprovação
	// _aFeriad	:= FWGetSX5("63")
	dbSelectArea("SX5")
	SX5->(dbGoTop())
	MsSeek( xFilial('SX5') + '63')
	While ! SX5->(eof()) .AND. SX5->X5_TABELA = '63'
		aADD(_aFeriad, {xFilial('SX5'), SX5->X5_TABELA, SX5->X5_CHAVE, SX5->X5_DESCRI})
		SX5->(dbSkip())
	EndDo
	//FIM Ticket   4883 - Abel Babini - 21/12/2020 - Geração de Borderô Automático e correção de error.log

	dRet			:= dDtAtu

	While ! _lTerm
		_lMudou := .F.
		
		While i <= Len(_aFeriad)
			cDataSX5	:= SUBSTR(_aFeriad[i,4],1,5)
			cPos1	:= SUBSTR(cDataSX5,1,1)
			cPos2	:= SUBSTR(cDataSX5,2,1)
			cPos3	:= SUBSTR(cDataSX5,3,1)
			cPos4	:= SUBSTR(cDataSX5,4,1)
			cPos5	:= SUBSTR(cDataSX5,5,1)
			IF ISDIGIT(cPos1) .AND. ISDIGIT(cPos2) .AND. ISDIGIT(cPos4) .AND. ISDIGIT(cPos5) .AND. cPos3 == '/'
				IF SUBSTR(DTOC(dRet),1,5) == cDataSX5
					dRet := dRet + 1
					i	:= 1
					Loop
				ENDIF
			ENDIF

			i += 1
		EndDo

		nDiaSem  := Dow(dRet)
		// Dia da Semana pensando nos CNABs que podem ser gerados na sexta, sabado e domingo
		// Fim de semana
		If nDiaSem == 7 // Sábado
			dRet := dRet + 2
			_lMudou := .T.
		ElseIf nDiaSem == 1 // Domingo
			dRet := dRet + 1
			_lMudou := .T.
		EndIf

		If !_lMudou 
			_lTerm := .T.
		Endif
	EndDo

	RestArea(aArea) //Ticket    429 - Abel Babini - 08/12/2020 - Ajuste no fonte para utilizar GetArea / ResArea
Return dRet
//FIM Ticket    429 - Abel Babini - 30/11/2020 - Substituição da rotina DataValida que causa error.log
