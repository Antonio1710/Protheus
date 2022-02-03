#INCLUDE "Totvs.ch"
#include "topconn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#Include 'FWMVCDef.ch'

/*/
	{Protheus.doc} User Function ADMNT013R
	Relatorio de Ordem de Serviço @type  Function
    @author Andre Vinagre
    @since 17/05/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history Ticket 15804  - Rodrigo Romão  - 27/08/2021 - preparado rotina para enviar email por scheduled
    @history Ticket 64562  - Everson  - 05/01/2022 - Tratamento error log.
/*/

User Function ADMNT013R(aParam) // U_ADMNT013R()
	local cTitulo     := "Relatorio de Ordem de Serviço"
	local nX					:= 0
	local aFiles			:= {}
	local aSizes			:= {}

	Private oProcess
	private cPerg     := "ADMNT013R"
	private cTipo     := ""
	private dDataDe   := ctod("")
	private dDataAte  := ctod("")
	Private cAlias    := ""
	Private cTipoReg  := "M"
	Private lJob      := .F. //IsBlind()
	Private cFile			:= ""

	//Parametros para o envio do email
	Private cPara      := ""
	Private cAssunto   := ""
	Private cCorpo     := ""
	Private aAnexos    := {}
	Private lMostraLog := .F.
	Private lUsaTLS    := .T.

	// default aParam := {'99','01'}

	lJob :=  iif(valtype(aParam) <> "U",.T.,.F.)

	if !lJob
		lPerguntas := Perguntas()
	else
		lPerguntas := .F.
	endif

	if lPerguntas

		cAlias := GetNextAlias()

		oReport := TReport():New(cPerg,cTitulo,{|| Perguntas() },{|oReport| PrintReport(oReport) })
		oReport:SetTitle(cTitulo)

		//Define as seções do relatório
		ReportDef(oReport)

		//Dialogo do TReport
		oReport:PrintDialog()

	ElseIf !lPerguntas .And. lJob //Everson - 05/01/2022. Chamado 64562.
		// EXECUCAO VIA JOB
		RpcSetType(3)
		lSetEnv  := RpcSetEnv(aParam[1],aParam[2],,,"")
		czEMP    := aParam[1]
		czFIL    := aParam[2]

		cTipo    	:= "LA"
		dDataDe  	:= CTOD('01/07/20')
		dDataAte	:= dDataBase

		if !ExistDir('\arquivos_xls')
			MakeDir('\arquivos_xls')
		endif

		ADir("\arquivos_xls\*.xls", aFiles, aSizes)
		if len(aFiles) > 0
			for nX := 1 to len(aFiles)
				FERASE("\arquivos_xls\"+aFiles[nX])
			next nX
		endif

		cFile    	:= '\arquivos_xls\arquivo_' + dToS(dDataBase) + StrTran(Time(), ":", "-") + ".xls"
		cPara   	:=  SuperGetMv('ZZ_MNT013R', .f. ,"ana.keli@adoro.com.br;debora.silva@adoro.com.br;hercules.moreira@adoro.com.br;sonia.silva@adoro.com.br" )
		cAssunto   := "Relação de Ordens de Serviço por Funcionario"
		cCorpo     := "Relação de Ordens de Serviço por Funcionario"
		aAnexos    := {}
		lMostraLog := .F.
		lUsaTLS    := .T.

		oProcess 	:= Executa()
	endif

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Ordem de Serviço')
	

Return

/* --------- ReportDef ---------*/
Static Function ReportDef(oReport)

	oSection := TRSection():New(oReport,"Titulos")

	TRCell():New(oSection,"TJ_ORDEM"    ,cAlias,"Ordem"      	        ,,TamSX3("TJ_ORDEM")[1]   ,,)
	TRCell():New(oSection,"TJ_PLANO"    ,cAlias,"Plano" 			        ,,TamSX3("TJ_PLANO")[1]   ,,)
	TRCell():New(oSection,"TJ_CODBEM"   ,cAlias,"Cod.Bem"			        ,,TamSX3("TJ_CODBEM")[1]  ,,)
	TRCell():New(oSection,"TJ_NOMBEM"   ,cAlias,"Nome"  			        ,,30										  ,,)
	TRCell():New(oSection,"TJ_SERVICO"  ,cAlias,"Servico"			        ,,TamSX3("TJ_SERVICO")[1] ,,)
	TRCell():New(oSection,"TJ_NOMSERV"  ,cAlias,"Nome Serviço"      	,,30 											,,)
	TRCell():New(oSection,"TJ_SEQRELA"  ,cAlias,"Sequencia"		        ,,TamSX3("TJ_SEQRELA")[1] ,,)
	TRCell():New(oSection,"TJ_DTPPINI"  ,cAlias,"Dt.P.Ini"  	        ,,TamSX3("TJ_DTPPINI")[1] ,,)
	TRCell():New(oSection,"TJ_DTMPINI"  ,cAlias,"Dt.M.P.Ini"	        ,,TamSX3("TJ_DTMPINI")[1] ,,)
	TRCell():New(oSection,"TJ_TIPOOS"   ,cAlias,"Tipo O.S."	          ,,TamSX3("TJ_TIPOOS")[1]  ,,)
	TRCell():New(oSection,"USUARIO"     ,cAlias,"Usuariio"   	        ,,30 ,,)

	//oSection:Cell("E1_PREFIXO"):SetAlign("CENTER")
Return


/**************************************************************************
Impressão da informacoes
***************************************************************************/
Static Function PrintReport(oReport)
	Local oSection1 := oReport:Section(1)
	Local nRegs			:= 0		
	
	//Busca os dados para exibição no relatorio.
	getDadosTitulos()
	
	//Contagem dos Registros a serem Impressos
	Count to nRegs
	oReport:SetMeter(nRegs)
	
	//Impressao dos Registros
	(cAlias)->(DbGoTop())
	While !(cAlias)->(Eof())
		
		oReport:IncMeter()
		oSection1:Init()
		
    //cOrdem  := (cAlias)->TJ_ORDEM
    //cPlano  := (cAlias)->TJ_PLANO
    //cNomeFunc := getFuncionarioOS(cOrdem,cPlano)

		//If !Empty(cNomeFunc)
      oSection1:Cell("TJ_ORDEM")    :SetValue((cAlias)->TJ_ORDEM)
      oSection1:Cell("TJ_PLANO")		:SetValue((cAlias)->TJ_PLANO)
      oSection1:Cell("TJ_CODBEM")		:SetValue((cAlias)->TJ_CODBEM)
      oSection1:Cell("TJ_NOMBEM")		:SetValue((cAlias)->NOMBEM)
      oSection1:Cell("TJ_SERVICO")  :SetValue((cAlias)->TJ_SERVICO)
      oSection1:Cell("TJ_NOMSERV")	:SetValue((cAlias)->NOMSER)
      oSection1:Cell("TJ_SEQRELA")	:SetValue((cAlias)->TJ_SEQRELA)
      oSection1:Cell("TJ_DTPPINI")	:SetValue((cAlias)->TJ_DTPPINI)
      oSection1:Cell("TJ_DTMPINI")	:SetValue((cAlias)->TJ_DTMPINI)
      oSection1:Cell("TJ_TIPOOS")		:SetValue((cAlias)->TJ_TIPOOS)
      oSection1:Cell("USUARIO")		  :SetValue((cAlias)->NOMFUNC)  
  		oSection1:PrintLine()
		//Endif
    
		(cAlias)->(DbSkip())
	End
	oSection1:Finish()
	
	(cAlias)->(DbCloseArea())
	
Return

/* ----- Execucao via JOB ------*/
Static Function Executa()
	Local oExcel 	:= FwMsExcel():New()

	cAlias 	:= GetNextAlias()

	cTablePlan := "OrdemServicoFuncionario"
	cTableTit	 := "Ordem de Serviços por Funcionario"

	oExcel:AddworkSheet(cTablePlan) 		// Planilha
	oExcel:AddTable(cTablePlan,cTableTit) // Titulo da Planilha (Cabecalho)
	oExcel:AddColumn(cTablePlan,cTableTit,"Funcionario"						,1,1)
	oExcel:AddColumn(cTablePlan,cTableTit,"Ordens de Serviços"	  ,2,1)

	getDadosTitulos()

	Count to nRegs
	nTotGeral := 0	
	
	// inseri no excell a os dados agrupados por funcionario
	(cAlias)->(DbGoTop())
	While !(cAlias)->(Eof())

		nTotGeral += (cAlias)->TOT_ORDENS
		oExcel:AddRow(cTablePlan,cTableTit,{(cAlias)->NOMFUNC,(cAlias)->TOT_ORDENS})

		(cAlias)->(DbSkip())
	End
	
	(cAlias)->(DbCloseArea())

	if (nTotGeral > 0)
		oExcel:AddRow(cTablePlan,cTableTit,{"Total Geral",nTotGeral})
	endif

	// inseri no excell a listagem dos dados
	cTablePlan := "ListagemOrdemServico"
	cTableTit	 := "Listagem completa das Ordens de Serviço"
	oExcel:AddworkSheet(cTablePlan) 		// Planilha
	oExcel:AddTable(cTablePlan,cTableTit) // Titulo da Planilha (Cabecalho)
	oExcel:AddColumn(cTablePlan,cTableTit, "Ordem"				,1,1)
	oExcel:AddColumn(cTablePlan,cTableTit, "Plano"		  	,2,1)
	oExcel:AddColumn(cTablePlan,cTableTit, "Cod.Bem"			,2,1)
	oExcel:AddColumn(cTablePlan,cTableTit, "Nome"					,2,1)
	oExcel:AddColumn(cTablePlan,cTableTit, "Servico"			,2,1)
	oExcel:AddColumn(cTablePlan,cTableTit, "Nome Serviço"	,2,1)
	oExcel:AddColumn(cTablePlan,cTableTit, "Sequencia"		,2,1)
	oExcel:AddColumn(cTablePlan,cTableTit, "Dt.P.Ini"			,2,1)
	oExcel:AddColumn(cTablePlan,cTableTit, "Dt.M.P.Ini"		,2,1)
	oExcel:AddColumn(cTablePlan,cTableTit, "Tipo O.S."		,2,1)
	oExcel:AddColumn(cTablePlan,cTableTit, "Usuariio"	  	,2,1)

	lJob 		:= .F.
	cAlias 	:= GetNextAlias()

	getDadosTitulos()

	Count to nRegs
	aItens := {}
	//Impressao dos Registros
	(cAlias)->(DbGoTop())
	While !(cAlias)->(Eof())
		
		aItens := {}
		aAdd(aItens,(cAlias)->TJ_ORDEM		)
		aAdd(aItens,(cAlias)->TJ_PLANO	  )
		aAdd(aItens,(cAlias)->TJ_CODBEM		)
		aAdd(aItens,(cAlias)->NOMBEM		)
		aAdd(aItens,(cAlias)->TJ_SERVICO	)
		aAdd(aItens,(cAlias)->NOMSER	)
		aAdd(aItens,(cAlias)->TJ_SEQRELA	)
		aAdd(aItens,(cAlias)->TJ_DTPPINI	)
		aAdd(aItens,(cAlias)->TJ_DTMPINI	)
		aAdd(aItens,(cAlias)->TJ_TIPOOS		)
		aAdd(aItens,(cAlias)->NOMFUNC			)

		oExcel:AddRow(cTablePlan,cTableTit,aItens)

		(cAlias)->(DbSkip())
	End
	
	(cAlias)->(DbCloseArea())
	
	lJob 		:= .T.

 	oExcel:Activate()
 	oExcel:GetXMLFile(cFile)

 	aAdd(aAnexos, cFile)

	StaticCall(ADMNT014R, fEnvMail, cPara, cAssunto, cCorpo, aAnexos, lMostraLog, lUsaTLS)
Return

/* ----- getDadosTitulos ------*/
Static Function getDadosTitulos()
	local cQuery  	:= ""

	cQuery := " SELECT " + CRLF

	if lJob
		cQuery += " DISTINCT ST1.T1_NOME AS NOMFUNC, count(STJ.TJ_ORDEM) AS TOT_ORDENS " + CRLF
	else
		cQuery += " 	DISTINCT 	" + CRLF
		cQuery += " 	STJ.TJ_ORDEM, 	" + CRLF
		cQuery += " 	STJ.TJ_PLANO, 	" + CRLF
		cQuery += " 	STJ.TJ_CODBEM, 	" + CRLF
		cQuery += " 	STJ.TJ_SERVICO, " + CRLF
		cQuery += " 	STJ.TJ_SEQRELA, " + CRLF
		cQuery += " 	STJ.TJ_DTPPINI, " + CRLF
		cQuery += " 	STJ.TJ_DTMPINI, " + CRLF
		cQuery += " 	STJ.TJ_TIPOOS, 	" + CRLF
		cQuery += " 	ST1.T1_NOME AS NOMFUNC, 		" + CRLF
		cQuery += " 	ST4.T4_NOME AS NOMSER,		" + CRLF
		cQuery += " 	ST9.T9_NOME AS NOMBEM 		" + CRLF
	endif

	cQuery += " FROM  " + RetSqlTab("STJ") + " " + CRLF
 	cQuery += "   INNER JOIN " + RetSqlTab("STL") + " " + CRLF
	cQuery += "     ON STL.TL_ORDEM = STJ.TJ_ORDEM " + CRLF
	cQuery += "     AND STL.TL_PLANO = STJ.TJ_PLANO " + CRLF
	cQuery += "     AND STL.TL_TIPOREG = '" + cTipoReg + "' " + CRLF
	cQuery += "     AND STL.TL_FILIAL = '" + xFilial("STL") + "' " + CRLF	
	cQuery += "     AND STL.D_E_L_E_T_ <> '*' "+ CRLF

 	cQuery += "   INNER JOIN " + RetSqlTab("ST1") + " " + CRLF
	cQuery += "     ON ST1.T1_CODFUNC = STL.TL_CODIGO " + CRLF
	cQuery += "     AND ST1.D_E_L_E_T_ <> '*' "+ CRLF
	cQuery += "     AND ST1.T1_FILIAL = '" + xFilial("ST1") + "' " + CRLF

 	cQuery += "   INNER JOIN " + RetSqlTab("ST9") + " " + CRLF
	cQuery += "     ON ST9.T9_CODBEM = STJ.TJ_CODBEM " + CRLF
	cQuery += "     AND ST9.D_E_L_E_T_ <> '*' "+ CRLF
	cQuery += "     AND ST9.T9_FILIAL = '" + xFilial("ST9") + "' " + CRLF

 	cQuery += "   INNER JOIN " + RetSqlTab("ST4") + " " + CRLF
	cQuery += "     ON ST4.T4_SERVICO = STJ.TJ_SERVICO " + CRLF
	cQuery += "     AND ST4.D_E_L_E_T_ <> '*' "+ CRLF
	cQuery += "     AND ST4.T4_FILIAL = '" + xFilial("ST4") + "' " + CRLF

	cQuery += "  WHERE STJ.D_E_L_E_T_ <> '*'" + CRLF
	cQuery += "   AND STJ.TJ_FILIAL = '" + xFilial("STJ") + "'" + CRLF

	if cTipo == "TO" //todos
    cQuery += "   AND STJ.TJ_TIPOOS  = 'B' " + CRLF
    cQuery += "   AND " + CRLF
    cQuery += "     (" + CRLF
    cQuery += "       (STJ.TJ_DTMPINI >= '" + dtos(dDataDe) + "' AND STJ.TJ_DTMPFIM <= '" + dtos(dDataAte) + "')" + CRLF
    cQuery += "       OR " + CRLF
    cQuery += "       (STJ.TJ_TERMINO = 'S' AND STJ.TJ_DTMRINI >= '" + dtos(dDataDe) + "' AND STJ.TJ_DTMRFIM <= '" + dtos(dDataAte) + "')" + CRLF
    cQuery += "     )"
	ElseIf cTipo == "LA" //Liberados/Abertos
    cQuery += "   AND STJ.TJ_TIPOOS  = 'B'" + CRLF
    cQuery += "   AND STJ.TJ_SITUACA = 'L'" + CRLF
    cQuery += "   AND STJ.TJ_TERMINO != 'S'" + CRLF
    cQuery += "   AND STJ.TJ_DTMPINI >= '" + dtos(dDataDe) + "'" + CRLF
    cQuery += "   AND STJ.TJ_DTMPFIM <= '" + dtos(dDataAte) + "'" + CRLF
	Else //Fechados
    cQuery += "   AND STJ.TJ_TIPOOS  = 'B'" + CRLF
    cQuery += "   AND STJ.TJ_TERMINO = 'S'" + CRLF
    cQuery += "   AND STJ.TJ_DTMRINI >= '" + dtos(dDataDe) + "'" + CRLF
    cQuery += "   AND STJ.TJ_DTMRFIM <= '" + dtos(dDataAte) + "'" + CRLF
	Endif

	if lJob
		cQuery += " GROUP BY ST1.T1_NOME"
		cQuery += " ORDER BY ST1.T1_NOME"
	else
		cQuery += "ORDER BY STJ.TJ_ORDEM, STJ.TJ_PLANO"
	endif

	TCQUERY cQuery NEW ALIAS (cAlias)
	DbSelectArea(cAlias)

  TcSetField(cAlias, "TJ_DTPPINI"	, "D", 8, 0)
  TcSetField(cAlias, "TJ_DTMPINI"	, "D", 8, 0)

Return

/*/{Protheus.doc} getFuncionarioOS
  (long_description)
  @type  Static Function
  @author user
  @since 17/05/2021
  @version version
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
Static Function getFuncionarioOS(cNumOrdem, cNumPlano)
	local cRet      := ""
	local cAlias    := GetNextAlias()
	local cQuery    := ""

	cQuery := " SELECT ST1.T1_NOME " + CRLF
	cQuery += " FROM " + RetSqlTab("STL") + " " + CRLF
	cQuery += "   INNER JOIN " + RetSqlTab("ST1") + " " + CRLF
	cQuery += "     ON ST1.T1_CODFUNC = STL.TL_CODIGO " + CRLF
	cQuery += "     AND ST1.D_E_L_E_T_ <> '*' "+ CRLF
	cQuery += "     AND ST1.T1_FILIAL = '" + xFilial("ST1") + "' " + CRLF
	cQuery += " WHERE STL.D_E_L_E_T_ <> '*' " + CRLF
	cQuery += "  AND STL.TL_FILIAL = '" + xFilial("STL") + "' " + CRLF
	cQuery += "  AND STL.TL_ORDEM = '" + cNumOrdem + "' " + CRLF
	cQuery += "  AND STL.TL_PLANO = '" + cNumPlano + "' " + CRLF
	cQuery += "  AND STL.TL_TIPOREG = '" + cTipoReg + "' " + CRLF

	TCQUERY cQuery NEW ALIAS (cAlias)
	DbSelectArea(cAlias)

	if (cAlias)->(!Eof())
		cRet := (cAlias)->T1_NOME
	endif

	(cAlias)->(DbCloseArea())

Return cRet

/* ----- Perguntas ------*/
Static Function Perguntas()
	local lPergunta     := .F.
	local aParBox		    := {}
	local dData         := ctod("")
	local aTipos        := {"TO=Todas","LA=Liberadas/Aberta","TE=Terminadas"}

	AADD(aParBox, {2, "Tipo","TO",aTipos ,80,"",.T.})							                  // MV_PAR01
	aAdd(aParBox, {1, "Data De "    , dData	    , "", "", ""		,    "", 60, .F.})  // MV_PAR02
	aAdd(aParBox, {1, "Data Ate"		, dData	    , "", "", ""		,    "", 60, .F.})  // MV_PAR03

	lPergunta := ParamBox(aParBox,cPerg,,,,,,,,cPerg,.T.,.T.)

	if lPergunta
		cTipo         := MV_PAR01
		dDataDe       := MV_PAR02
		dDataAte      := MV_PAR03
	endif

Return(lPergunta)
