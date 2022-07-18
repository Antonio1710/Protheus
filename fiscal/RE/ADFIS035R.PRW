#Include "Totvs.ch"

/*/{Protheus.doc} CENTRCIM
	@description 	Relatorio de conferencia de impostos (Geral com Parametros)
	@author 		Amedeo D. Paoli Filho
	@version		1.0
	@param			Nil
	@return			Nil
	@type 			Function
	@history Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
	@history Ticket    1867 - Abel Babini - 07/12/2020 - Acrescentar Filtro de Data de Entrada e Docs Digitados
	@history Ticket    1867 - Abel Babini - 28/12/2020 - Acrescentar Ajuste nos filtros / parâmetros do relatório que não estavam sendo utilizados e considerar o cadastro de cliente/fornecedor quand o campo XIT_CODPRD estiver em branco
	@history Ticket   10427 - Abel Babini - 05/03/2021 - Acrescentado condição para procurar a NF de entrada na tabela SFT e SD1 com a série com 1, 2 ou 3 caracteres
	@history Ticket   76599 - Abel Babini - 18/07/2022 - Ajuste na chamada das perguntas para utilizar ParamBox
/*/

User Function ADFIS035R()
	Local aArea		:= GetArea()
	Local oReport	:= Nil

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de conferencia de impostos (Geral com Parametros)')

	oReport	:= ReportDef()
	oReport:PrintDialog()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} ReprtDef
@description 	Definicoes do Relatorio
@author 		Amedeo D. Paoli Filho
@type 			Function
/*/
Static Function ReportDef()
	// Local oCabec	 	:= Nil
	Local cDescr	 	:= "Este programa irá imprimir o Relatório de Conferência de Impostos"
	Local cTitulo	 	:= "Relatório de Conferência de Impostos"
	Local cAliasRep	 	:= GetNextAlias()
	Local cPerg			:= "CENTRCIM"
	Local oNota			:= Nil
	// Local oItens		:= Nil

	//Ajusta as Perguntas
	//INICIO Ticket   76599 - Abel Babini - 18/07/2022 - Ajuste na chamada das perguntas para utilizar ParamBox
	Aadd(aPerg ,{1,"Nota Fiscal De" ,Space(FWTAMSX3("D1_DOC")[1])		,"" ,'.T.',,'.T.',60,.F.})
	Aadd(aPerg ,{1,"Série De" 			,Space(FWTAMSX3("D1_SERIE")[1])	,"" ,'.T.',,'.T.',20,.F.})
	Aadd(aPerg ,{1,"Nota Fiscal Até",Space(FWTAMSX3("D1_DOC")[1])		,"" ,'.T.',,'.T.',60,.T.})
	Aadd(aPerg ,{1,"Série Até" 			,Space(FWTAMSX3("D1_SERIE")[1])	,"" ,'.T.',,'.T.',20,.T.})
	aAdd(aPerg ,{1,"Emissão NF De" ,Ctod(space(8)),"" ,'.T.',,'.T.',80,.F.})
	aAdd(aPerg ,{1,"Emissão NF Até",Ctod(space(8)),"" ,'.T.',,'.T.',80,.F.})
	Aadd(aPerg ,{1,"Filial De" ,Space(FWTAMSX3("D1_FILIAL")[1])	,"" ,'.T.',,'.T.',20,.F.})
	Aadd(aPerg ,{1,"Filial Ate",Space(FWTAMSX3("D1_FILIAL")[1])	,"" ,'.T.',,'.T.',20,.T.})
	aAdd(aPerg ,{1,"Dt Entrada De" ,Ctod(space(8)),"" ,'.T.',,'.T.',80,.F.})
	aAdd(aPerg ,{1,"Dt Entrada Até",Ctod(space(8)),"" ,'.T.',,'.T.',80,.T.})
	aAdd(aPerg ,{3,"Mostrar Todos ?"		,1,{'Todos','Apenas lançados','Não lançados'},120,"",.F.})
	//
	// CriaPerg(@cPerg)
	// Pergunte(cPerg,.F.)
	If ParamBox(aPerg ,"Parâmetros ",aRet,,,,,,,,.T.,.T.)

		MV_PAR01	:= aRet[1]
		MV_PAR02	:= aRet[2]
		MV_PAR03	:= aRet[3]
		MV_PAR04	:= aRet[4]
		MV_PAR05	:= aRet[5]
		MV_PAR06	:= aRet[6]
		MV_PAR07	:= aRet[7]
		MV_PAR08	:= aRet[8]
		MV_PAR09	:= aRet[9]
		MV_PAR10	:= aRet[10]
		MV_PAR11	:= aRet[11]
		//FIM Ticket   76599 - Abel Babini - 18/07/2022 - Ajuste na chamada das perguntas para utilizar ParamBox
		
		oReport := TReport():New("ADORO_CENTRCIM",cTitulo,cPerg,{|oReport| ReportPrint(oReport,@cAliasRep)},cDescr)
		oReport:SetLandscape()
		oReport:HideParamPage()

		oNota := TRSection():New(oReport,"Nota Fiscal",{(cAliasRep)},,/*Campos do SX3*/,/*Campos do SIX*/)
		oNota:SetTotalInLine(.F.)
		TRCell():New(oNota,"F1_DOC"		,"SF1"		,/*Titulo*/		,/*Mascara*/	,/*Tamanho*/	,/*lPixel*/	,		)
		TRCell():New(oNota,"F1_SERIE"	,"SF1"		,/*Titulo*/		,/*Mascara*/	,/*Tamanho*/	,/*lPixel*/	,		)
		TRCell():New(oNota,"F1_FORNECE"	,"SF1"		,/*Titulo*/		,/*Mascara*/	,/*Tamanho*/	,/*lPixel*/	,		)
		TRCell():New(oNota,"F1_LOJA"	,"SF1"		,/*Titulo*/		,/*Mascara*/	,/*Tamanho*/	,/*lPixel*/	,		)
		TRCell():New(oNota,"A2_NOME"	,"SA2"		,/*Titulo*/		,/*Mascara*/	,/*Tamanho*/	,/*lPixel*/	,		)
		TRCell():New(oNota,"F1_EMISSAO"	,"SF1"		,/*Titulo*/		,/*Mascara*/	,/*Tamanho*/	,/*lPixel*/	,		)
		TRCell():New(oNota,"F1_DTDIGIT"	,"SF1"		,/*Titulo*/		,/*Mascara*/	,/*Tamanho*/	,/*lPixel*/	,		)

		TRCell():New(oNota,"D1_ITEM"		,"SD1"		,/*Titulo*/			,/*Mascara*/			,/*Tamanho*/			,/*lPixel*/	,		)
		TRCell():New(oNota,"REFFORN"		,""			,"Ref. Fornecedor",/*Mascara*/			,TamSx3("D1_COD")[1]	,/*lPixel*/	,		)
		TRCell():New(oNota,"D1_COD"			,"SD1"	,/*Titulo*/				,/*Mascara*/			,/*Tamanho*/			,/*lPixel*/	,		)
		TRCell():New(oNota,"B1_DESC"		,"SB1"	,/*Titulo*/				,/*Mascara*/			,/*Tamanho*/			,/*lPixel*/	,		)
		TRCell():New(oNota,"F4_CODIGO"	,"SF4"	,"TES"						,/*Mascara*/			,/*Tamanho*/			,/*lPixel*/	,		)
		TRCell():New(oNota,"ICMSXML"		,""			,"ICMS XML"				,"@E 999,999,999.99"	,14						,/*lPixel*/	,		)
		TRCell():New(oNota,"ICMSNFE"		,""			,"ICMS NF-e"			,"@E 999,999,999.99"	,14						,/*lPixel*/	,		)	
		TRCell():New(oNota,"CONFICMS"		,""			,"CONF. ICMS"			,"@!"	,20						,/*lPixel*/	,		) //Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
		TRCell():New(oNota,"ICMSSTXML"	,""			,"ICMS ST XML"		,"@E 999,999,999.99"	,14						,/*lPixel*/	,		)
		TRCell():New(oNota,"ICMSSTNFE"	,""			,"ICMS ST NF-e"		,"@E 999,999,999.99"	,14						,/*lPixel*/	,		)
		TRCell():New(oNota,"IPIXML"			,""			,"IPI XML"				,"@E 999,999,999.99"	,14						,/*lPixel*/	,		)
		TRCell():New(oNota,"IPINFE"			,""			,"IPI NF-e"				,"@E 999,999,999.99"	,14						,/*lPixel*/	,		)
		TRCell():New(oNota,"CONFIPI"		,""			,"CONF. IPI"			,"@!"	,20						,/*lPixel*/	,		) //Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
		TRCell():New(oNota,"PISXML"			,""			,"PIS XML"				,"@E 999,999,999.99"	,14						,/*lPixel*/	,		)
		TRCell():New(oNota,"PISNFE"			,""			,"PIS NF-e"				,"@E 999,999,999.99"	,14						,/*lPixel*/	,		)
		TRCell():New(oNota,"CONFPIS"		,""			,"CONF. PIS"			,"@!"	,20						,/*lPixel*/	,		) //Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
		TRCell():New(oNota,"COFXML"			,""			,"COFINS XML"			,"@E 999,999,999.99"	,14						,/*lPixel*/	,		)
		TRCell():New(oNota,"COFNFE"			,""			,"COFINS NF-e"		,"@E 999,999,999.99"	,14						,/*lPixel*/	,		)
		TRCell():New(oNota,"CONFCOF"		,""			,"CONF. COFINS"		,"@!"	,20						,/*lPixel*/	,		) //Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF

		TRCell():New(oNota,"CSTPISXML"		,""			,"CST PIS XML"		,"@!"					,05						,/*lPixel*/	,		)
		TRCell():New(oNota,"CSTPISNFE"		,""			,"CST PIS NF-e"		,"@!"					,05						,/*lPixel*/	,		)
		TRCell():New(oNota,"CSTCOFXML"		,""			,"CST COFINS XML"	,"@!"					,05						,/*lPixel*/	,		)
		TRCell():New(oNota,"CSTCOFNFE"		,""			,"CST COFINS NF-e"	,"@!"					,05						,/*lPixel*/	,		)
		TRCell():New(oNota,"CSTICMXML"		,""			,"CST ICMS XML"		,"@!"					,05						,/*lPixel*/	,		)
		TRCell():New(oNota,"CSTICMNFE"		,""			,"CST ICMS NF-e"	,"@!"					,05						,/*lPixel*/	,		)
		TRCell():New(oNota,"NCMXML"		,""			,"NCM XML"			,"@!"					,10						,/*lPixel*/	,		)
		TRCell():New(oNota,"NCMNFE"		,""			,"NCM NF-e"			,"@!"					,10						,/*lPixel*/	,		)
		TRCell():New(oNota,"CONFNCM"		,""			,"CONF. NCM"		,"@!"	,20						,/*lPixel*/	,		) //Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
		TRCell():New(oNota,"CFOPXML"		,""			,"CFOP XML"			,"@!"					,06						,/*lPixel*/	,		)
		TRCell():New(oNota,"CFOPNFE"		,""			,"CFOP NF-e"		,"@!"					,06						,/*lPixel*/	,		)

		TRCell():New(oNota,"OBSERVA"		,""			,"Observações"		,"@!"					,30						,/*lPixel*/	,		)
	Endif
Return oReport

// Function ReportPrint
Static Function ReportPrint(oReport, cAliasRep)
	Local oSection1		:= oReport:Section(1)

	Local nTamNF		:= TamSx3("F1_DOC")[1]
	Local nTamSR		:= TamSx3("F1_SERIE")[1]
	Local lImpDet		:= .T.
	Local cObserv		:= ""
	Local cNFiscal	:= ""
	Local cSerie		:= ""
	// Local cQuery		:= ""
	
	Local cCsPisXM		:= ""
	Local cCsPisNF		:= ""
	Local cCsCofXM		:= ""
	Local cCsCofNF		:= ""
	Local cCsIcmXM		:= ""
	Local cCsIcmNF		:= ""
	Local cNcmXM		:= ""
	Local cNcmNF		:= ""
	Local cCfopXM		:= ""
	Local cCfopNF		:= ""

	Local nItem			:= 0
	Local nValICXM		:= 0
	Local nValICNF		:= 0
	Local nValSTXM		:= 0
	Local nValSTNF		:= 0
	Local nValIPXM		:= 0
	Local nValIPNF		:= 0
	Local nValPSXM		:= 0
	Local nValPSNF		:= 0
	Local nValCFXM		:= 0
	Local nValCFNF		:= 0

	// Local nTxPis   		:= 0
	// Local nTxCof  		:= 0
	// Local nRedPis			:= 1
	// Local nRedCOF			:= 1

	Local cInFil			:= xFilSel()

	Local cA5PRD			:= "" //Ticket    1867 - Abel Babini - 28/12/2020 - Acrescentar Ajuste nos filtros / parâmetros do relatório que não estavam sendo utilizados e considerar o cadastro de cliente/fornecedor quand o campo XIT_CODPRD estiver em branco

	//Ticket    1867 - Abel Babini - 07/12/2020 - Acrescentar Filtro de Data de Entrada e Docs Digitados
	Local cFilAdt			:= '%'+IIF(MV_PAR11 == 1," XML_LANCAD BETWEEN " + DtoS( MV_PAR09 ) + " AND " + DtoS( MV_PAR10 ) + " OR XML_LANCAD = '' ",IIF(MV_PAR11 == 2," XML_LANCAD BETWEEN " + DtoS( MV_PAR09 ) + " AND " + DtoS( MV_PAR10 ), " XML_LANCAD = '' " ) ) + '%'
	
	//INICIO Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
	//INICIO Ticket    1867 - Abel Babini - 07/12/2020 - Acrescentar Filtro de Data de Entrada e Docs Digitados
	//INICIO 
	BeginSql alias cAliasRep
		SELECT	R_E_C_N_O_ RECXML,
		ISNULL(CONVERT(VARCHAR(MAX), CONVERT(VARBINARY(MAX), XML_ARQ)),'') AS XMLARQ , *
		FROM	RECNFXML 
		WHERE	D_E_L_E_T_ <> '*' "
		AND		XML_EMISSA BETWEEN %Exp:DtoS( MV_PAR05 )% AND %Exp:DtoS( MV_PAR06 )%
		AND		SUBSTRING(XML_NUMNF,4,9) BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR03%
		AND		SUBSTRING(XML_NUMNF,1,3) BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR04%
		AND		( %Exp:cFilAdt% )
		AND 	XML_DEST IN %Exp:cInFil%
		AND		XML_CLIFOR = 'F'
	EndSql
	//FIM Ticket    1867 - Abel Babini - 28/12/2020 - Acrescentar Ajuste nos filtros / parâmetros do relatório que não estavam sendo utilizados e considerar o cadastro de cliente/fornecedor quand o campo XIT_CODPRD estiver em branco
	//FIM Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF

	oReport:SetMeter( ( cAliasRep )->(RecCount()) )
	oSection1:Init()

	While !( cAliasRep )->( Eof() )

		cNFiscal	:= SubStr( ( cAliasRep )->XML_NUMNF, nTamSR + 1, nTamNF )
		cSerie		:= SubStr( ( cAliasRep )->XML_NUMNF, 1, nTamSR )
		nItem		:= 0

		//Posiciona Fornecedor
		DbSelectarea("SA2")
		//INICIO Ticket    1867 - Abel Babini - 28/12/2020 - Acrescentar Ajuste nos filtros / parâmetros do relatório que não estavam sendo utilizados e considerar o cadastro de cliente/fornecedor quand o campo XIT_CODPRD estiver em branco
		IF Empty(Alltrim((cAliasRep)->XML_KEYF1))
			SA2->( DbSetorder(3) )
			lForn	:= SA2->( DbSeek( xFilial("SA2") + ( cAliasRep )->XML_EMIT ) )
		Else
			SA2->( DbSetorder(1) )
			lForn	:= SA2->( DbSeek( xFilial("SA2") + Substr(Alltrim((cAliasRep)->XML_KEYF1),15,8) ) )
		Endif
		//FIM Ticket    1867 - Abel Babini - 28/12/2020 - Acrescentar Ajuste nos filtros / parâmetros do relatório que não estavam sendo utilizados e considerar o cadastro de cliente/fornecedor quand o campo XIT_CODPRD estiver em branco

		If lForn

			U_DbSelArea( "RECNFXMLITENS", .F., 1 )
			Set Filter To Alltrim( RECNFXMLITENS->XIT_CHAVE ) == Alltrim( ( cAliasRep )->XML_CHAVE )

			U_DbSelArea( "RECNFXMLITENS", .F., 2 )
			DbGotop()
			While !Eof() .And. Alltrim( RECNFXMLITENS->XIT_CHAVE ) == Alltrim( ( cAliasRep )->XML_CHAVE )

				//Valores do XML
				nValICXM	:= RECNFXMLITENS->XIT_VALICM
				nValSTXM	:= RECNFXMLITENS->XIT_VALRET
				nValIPXM	:= RECNFXMLITENS->XIT_VALIPI
				nValPSXM	:= RECNFXMLITENS->XIT_VALPIS
				nValCFXM	:= RECNFXMLITENS->XIT_VALCOF

				//Valores que serao pegados do Item (Caso o produto esteja preenchido)
				nValICNF	:= 0
				nValSTNF	:= 0
				nValIPNF	:= 0
				nValPSNF	:= 0
				nValCFNF	:= 0
				cCsPisXM	:= RECNFXMLITENS->XIT_CSTPIS //RECNFXMLITENS->XIT_CSTXML //Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
				cCsPisNF	:= ""
				cCsCofXM	:= RECNFXMLITENS->XIT_CSTCOF //RECNFXMLITENS->XIT_CSTXML //Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
				cCsCofNF	:= ""
				cCsIcmXM	:= RECNFXMLITENS->XIT_CSTXML //Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
				cCsIcmNF	:= ""
				cNcmXM		:= RECNFXMLITENS->XIT_NCM //Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
				cNcmNF		:= ""
				cCfopXM		:= RECNFXMLITENS->XIT_CFNFE //Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
				cCfopNF		:= ""

				lImpDet		:= .T.
				cObserv		:= ""

				cTESNF		:= "" //Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
				lFndSFT		:= .F. //Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF

				//INICIO Ticket   10427 - Abel Babini - 05/03/2021 - Acrescentado condição para procurar a NF de entrada na tabela SFT e SD1 com a série com 1, 2 ou 3 caracteres
				IF Empty(Alltrim(cCsIcmXM))
					cCsIcmXM := fFindCST(Alltrim(RECNFXMLITENS->XIT_CHAVE), Alltrim(RECNFXMLITENS->XIT_ITEM))
				ENDIF
				//FIM Ticket   10427 - Abel Babini - 05/03/2021 - Acrescentado condição para procurar a NF de entrada na tabela SFT e SD1 com a série com 1, 2 ou 3 caracteres

				//INICIO Ticket    1867 - Abel Babini - 28/12/2020 - Acrescentar Ajuste nos filtros / parâmetros do relatório que não estavam sendo utilizados e considerar o cadastro de cliente/fornecedor quand o campo XIT_CODPRD estiver em branco
				DbSelectarea("SA5")
				SA5->( DbSetorder(14) )
				IF SA5->( DbSeek( xFilXML(( cAliasRep )->XML_DEST) + SA2->A2_COD + SA2->A2_LOJA + Alltrim(RECNFXMLITENS->XIT_CODNFE) ) )
					cA5PRD	:= Alltrim(SA5->A5_PRODUTO)
				ELSE
					cA5PRD	:= ""
				ENDIF
				SA5->( DbSetorder(1) )
				//FIM Ticket    1867 - Abel Babini - 28/12/2020 - Acrescentar Ajuste nos filtros / parâmetros do relatório que não estavam sendo utilizados e considerar o cadastro de cliente/fornecedor quand o campo XIT_CODPRD estiver em branco

				// If !Empty( Alltrim(RECNFXMLITENS->XIT_CODPRD) ) .OR. !Empty(cA5PRD)
					//INICIO Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
					DbSelectarea("SB1")
					SB1->( DbSetorder(1) )
					SB1->( DbSeek(xFilial("SB1") + IIF(!Empty(Alltrim(RECNFXMLITENS->XIT_CODPRD)),Alltrim(RECNFXMLITENS->XIT_CODPRD),Alltrim(cA5PRD) ) ) ) //Ticket    1867 - Abel Babini - 28/12/2020 - Acrescentar Ajuste nos filtros / parâmetros do relatório que não estavam sendo utilizados e considerar o cadastro de cliente/fornecedor quand o campo XIT_CODPRD estiver em branco

					DbSelectarea("SFT")
					SFT->( DbSetorder(1) ) //FT_FILIAL, FT_TIPOMOV, FT_SERIE, FT_NFISCAL, FT_CLIEFOR, FT_LOJA, FT_ITEM, FT_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
					lFndSFT	:= SFT->( DbSeek( xFilXML(( cAliasRep )->XML_DEST) + "E" + cSerie + cNFiscal + SA2->A2_COD + SA2->A2_LOJA + RECNFXMLITENS->XIT_ITEM /* + SB1->B1_COD */ ) )
					
					//Ticket   10427 - Abel Babini - 05/03/2021 - Acrescentado condição para procurar a NF de entrada na tabela SFT e SD1 com a série com 1, 2 ou 3 caracteres
					IF ! lFndSFT
						If Len(Alltrim(cSerie)) ==  1
							lFndSFT	:= SFT->( DbSeek( xFilXML(( cAliasRep )->XML_DEST) + "E" + "0"+Alltrim(cSerie)+" " + cNFiscal + SA2->A2_COD + SA2->A2_LOJA + RECNFXMLITENS->XIT_ITEM /* + SB1->B1_COD */ ) )
						Endif

						IF ! lFndSFT
							lFndSFT	:= SFT->( DbSeek( xFilXML(( cAliasRep )->XML_DEST) + "E" + "00"+Alltrim(cSerie) + cNFiscal + SA2->A2_COD + SA2->A2_LOJA + RECNFXMLITENS->XIT_ITEM /* + SB1->B1_COD */ ) )
						ENDIF
					ENDIF

					DbSelectarea("SD1")
					SD1->( DbSetorder(1) ) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
					lFndSD1	:= SD1->( DbSeek( xFilXML(( cAliasRep )->XML_DEST) + cNFiscal + cSerie +  SA2->A2_COD + SA2->A2_LOJA + IIF(lFndSFT,SFT->FT_PRODUTO,SB1->B1_COD) + RECNFXMLITENS->XIT_ITEM ) )
					//FIM Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF

					//Ticket   10427 - Abel Babini - 05/03/2021 - Acrescentado condição para procurar a NF de entrada na tabela SFT e SD1 com a série com 1, 2 ou 3 caracteres
					IF ! lFndSD1
						If Len(Alltrim(cSerie)) ==  1
							lFndSD1	:= SD1->( DbSeek( xFilXML(( cAliasRep )->XML_DEST) + cNFiscal + "0"+Alltrim(cSerie)+" " +  SA2->A2_COD + SA2->A2_LOJA + IIF(lFndSFT,SFT->FT_PRODUTO,SB1->B1_COD) + RECNFXMLITENS->XIT_ITEM ) )
						Endif

						IF ! lFndSFT
							lFndSD1	:= SD1->( DbSeek( xFilXML(( cAliasRep )->XML_DEST) + cNFiscal + "00"+Alltrim(cSerie) + SA2->A2_COD + SA2->A2_LOJA + IIF(lFndSFT,SFT->FT_PRODUTO,SB1->B1_COD) + RECNFXMLITENS->XIT_ITEM ) )
						ENDIF
					ENDIF


					If !Empty( RECNFXMLITENS->XIT_TES) .or. lFndSD1 //lFndSFT 
						//Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
						DbSelectarea("SF4")
						SF4->( DbSetorder(1) )
						SF4->( DbSeek( xFilial("SF4") + RECNFXMLITENS->XIT_TES ) )

						IF lFndSFT //Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
							cCsPisNF	:= SFT->FT_CSTPIS
							cCsCofNF	:= SFT->FT_CSTCOF
							cCsIcmNF	:= SFT->FT_CLASFIS //Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
							cNcmNF		:= SFT->FT_POSIPI
							cCfopNF		:= SFT->FT_CFOP
							cTESNF		:= SFT->FT_TES
						EndIf
						
						nItem		++

						//Valores da NF
						//Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
						nValICNF	:= SD1->D1_VALICM		//MaFisRet( nItem, "IT_VALICM"	)
						nValSTNF	:= SD1->D1_ICMSRET	//MaFisRet( nItem, "IT_VALSOL"	)
						nValIPNF	:= SD1->D1_VALIPI		//MaFisRet( nItem, "IT_VALIPI"	)

						nValPSNF	:= SD1->D1_VALIMP6 //Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
						nValCFNF	:= SD1->D1_VALIMP5 //Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
						//Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF

					Else
						lImpDet	:= .F.
					EndIf
				// Else
				// 	lImpDet	:= .F.
				// EndIf

				If !lImpDet
					cObserv	:= "INF. FALT. (PRODUTO OU TES)"
				EndIf

				oSection1:Cell("F1_DOC"		):SetValue( cNFiscal							)
				oSection1:Cell("F1_SERIE"	):SetValue( cSerie	   							)
				oSection1:Cell("F1_FORNECE"	):SetValue( SA2->A2_COD							)
				oSection1:Cell("F1_LOJA"	):SetValue( SA2->A2_LOJA						)
				oSection1:Cell("A2_NOME"	):SetValue( SA2->A2_NOME						)
				oSection1:Cell("F1_EMISSAO"	):SetValue( StoD( ( cAliasRep )->XML_EMISSA )	)
				oSection1:Cell("F1_DTDIGIT"	):SetValue( StoD( ( cAliasRep )->XML_LANCAD )	)
			
				oSection1:Cell("D1_ITEM"	):SetValue( RECNFXMLITENS->XIT_ITEM		)
				oSection1:Cell("REFFORN"	):SetValue( RECNFXMLITENS->XIT_CODNFE	)
				oSection1:Cell("D1_COD"		):SetValue( IIF(!Empty(Alltrim(RECNFXMLITENS->XIT_CODPRD)),Alltrim(RECNFXMLITENS->XIT_CODPRD),Alltrim(cA5PRD) ) /*RECNFXMLITENS->XIT_CODPRD*/	) //Ticket    1867 - Abel Babini - 28/12/2020 - Acrescentar Ajuste nos filtros / parâmetros do relatório que não estavam sendo utilizados e considerar o cadastro de cliente/fornecedor quand o campo XIT_CODPRD estiver em branco
				oSection1:Cell("B1_DESC"	):SetValue( RECNFXMLITENS->XIT_DESCRI	)
				oSection1:Cell("F4_CODIGO"	):SetValue( IIF(Alltrim(cTESNF)<>"",cTESNF,RECNFXMLITENS->XIT_TES)		) //RECNFXMLITENS->XIT_TES //Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
				oSection1:Cell("ICMSXML"	):SetValue( nValICXM					)
				oSection1:Cell("ICMSNFE"	):SetValue( nValICNF					)
				oSection1:Cell("CONFICMS"	):SetValue( IIF(nValICXM<>nValICNF,'Diferença','')					) //Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
				oSection1:Cell("ICMSSTXML"	):SetValue( nValSTXM					)
				oSection1:Cell("ICMSSTNFE"	):SetValue( nValSTNF					)
				oSection1:Cell("IPIXML"		):SetValue( nValIPXM					)
				oSection1:Cell("IPINFE"		):SetValue( nValIPNF					)
				oSection1:Cell("CONFIPI"	):SetValue( IIF(nValIPXM<>nValIPNF,'Diferença','')					) //Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
				oSection1:Cell("PISXML"		):SetValue( nValPSXM					)
				oSection1:Cell("PISNFE"		):SetValue( nValPSNF					)
				oSection1:Cell("CONFPIS"	):SetValue( IIF(nValPSXM<>nValPSNF,'Diferença','')					) //Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
				oSection1:Cell("COFXML"		):SetValue( nValCFXM					)
				oSection1:Cell("COFNFE"		):SetValue( nValCFNF					)
				oSection1:Cell("CONFCOF"	):SetValue( IIF(nValCFXM<>nValCFNF,'Diferença','')					) //Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF

				oSection1:Cell("CSTPISXML"	):SetValue( cCsPisXM					)
				oSection1:Cell("CSTPISNFE"	):SetValue( cCsPisNF					)
				oSection1:Cell("CSTCOFXML"	):SetValue( cCsCofXM					)
				oSection1:Cell("CSTCOFNFE"	):SetValue( cCsCofNF					)
				oSection1:Cell("CSTICMXML"	):SetValue( cCsIcmXM					)
				oSection1:Cell("CSTICMNFE"	):SetValue( cCsIcmNF					)
				oSection1:Cell("NCMXML"		):SetValue( cNcmXM						)
				oSection1:Cell("NCMNFE"		):SetValue( cNcmNF						)
				oSection1:Cell("CONFNCM"	):SetValue( IIF(cNcmXM<>cNcmNF,'Diferença','')					) //Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
				oSection1:Cell("CFOPXML"	):SetValue( cCfopXM						)
				oSection1:Cell("CFOPNFE"	):SetValue( cCfopNF						)


				oSection1:Cell("OBSERVA"	):SetValue( cObserv						)
				oSection1:PrintLine()	
				
				DbSelectArea( "RECNFXMLITENS" )
				DbSkip()
			End

			//oSection2:Finish()

		EndIf

		( cAliasRep )->( DbSkip() )

	End

	// oSection1:Print() 
	oSection1:Finish()
	
	( cAliasRep )->( DbCloseArea() )

Return Nil

/*/{Protheus.doc} CriaPerg
@description 	Cria perguntas do relatorio
@author 		Amedeo D. Paoli Filho
@version		1.0
@return			Nil
@type 			Function
/*/
Static Function CriaPerg( cPerg )
	Local cPerg	:= PadR( cPerg, 10 )
	Local aPerg	:= {}
	Local lLock	:= .F.
	Local nX	:= 0

	DbSelectArea("SX1")
	DbSetOrder(1)

	Aadd( aPerg, {"Nota Fiscal De"			, "C", 09, 00, "G", ""				, ""		, "", "", "", ""	} )
	Aadd( aPerg, {"Série De"						, "C", 03, 00, "G", ""				, ""		, "", "", "", ""	} )
	Aadd( aPerg, {"Nota Fiscal Até"			, "C", 09, 00, "G", ""				, ""		, "", "", "", ""	} )
	Aadd( aPerg, {"Série Até"						, "C", 03, 00, "G", ""				, ""		, "", "", "", ""	} )
	Aadd( aPerg, {"Emissão NF De"				, "D", 08, 00, "G", ""				, ""		, "", "", "", ""	} )
	Aadd( aPerg, {"Emissão NF Até"			, "D", 08, 00, "G", ""				, ""		, "", "", "", ""	} )

	//INICIO Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
	Aadd( aPerg, {"Filial De"						, "C", 02, 00, "G", ""				, ""		, "", "", "", ""	} )
	Aadd( aPerg, {"Filial Até"					, "C", 02, 00, "G", ""				, ""		, "", "", "", ""	} )
	//FIM Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF

	//INICIO Ticket    1867 - Abel Babini - 07/12/2020 - Acrescentar Filtro de Data de Entrada e Docs Digitados
	Aadd( aPerg, {"Dt. Entrada De"			, "D", 08, 00, "G", ""				, ""		, "", "", "", ""	} )
	Aadd( aPerg, {"Dt. Entrada Até"			, "D", 08, 00, "G", ""				, ""		, "", "", "", ""	} )
	Aadd( aPerg, {"Mostrar Todos ?"			, "N", 01, 00, "C", "Todos"		, "Apenas lançados"	,	"Não lançados",	"",	"",	""	}	)
	//FIM Ticket    1867 - Abel Babini - 07/12/2020 - Acrescentar Filtro de Data de Entrada e Docs Digitados

	For nX := 1 To Len(aPerg)

		lLock := !SX1->(Dbseek(cPerg + StrZero(nX, 2)))

		Reclock("SX1", lLock)
		SX1->X1_GRUPO 	:= cPerg
		SX1->X1_ORDEM		:= StrZero(nX, 2)
		SX1->X1_VARIAVL	:= "mv_ch" + Chr( nX + 96 )
		SX1->X1_VAR01		:= "mv_par" + StrZero(nX,2)
		SX1->X1_PRESEL	:= 1
		SX1->X1_PERGUNT	:= aPerg[ nX , 01 ]
		SX1->X1_TIPO 		:= aPerg[ nX , 02 ]
		SX1->X1_TAMANHO	:= aPerg[ nX , 03 ]
		SX1->X1_DECIMAL	:= aPerg[ nX , 04 ]
		SX1->X1_GSC  		:= aPerg[ nX , 05 ]
		SX1->X1_DEF01		:= aPerg[ nX , 06 ]
		SX1->X1_DEF02		:= aPerg[ nX , 07 ]
		SX1->X1_DEF03		:= aPerg[ nX , 08 ]
		SX1->X1_DEF04		:= aPerg[ nX , 09 ]
		SX1->X1_DEF05		:= aPerg[ nX , 10 ]
		SX1->X1_F3   		:= aPerg[ nX , 11 ]
		MsUnlock()
	Next nX

Return Nil

//INICIO Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF
/*/{Protheus.doc} xFilSel
	@description 	Retorna CNPJ´s das filiais selecionadas para filtrar XML´s
	@author 		Abel Babini
	@version		1.0
	@return			Nil
	@type 			Function
	/*/
Static Function xFilSel()
	Local aAllEmp		:= FWLoadSM0()
	Local _i				:= 0
	Local cFilCnpj	:= ''
	Local cInCNPJ		:= ''

	For _i := 1 to Len(aAllEmp)
		If	Alltrim(aAllEmp[_i,1]) = cEmpAnt .AND.;
				Alltrim(aAllEmp[_i,2]) >= MV_PAR07 .AND.;
				Alltrim(aAllEmp[_i,2]) <= MV_PAR08
			cFilCnpj += Alltrim(aAllEmp[_i,18])+','
		ENDIF
	Next _i

	cInCNPJ	:= '%'+FormatIn(cFilCnpj,",")+'%'
Return cInCNPJ
//FIM Ticket    1867 - Abel Babini - 18/09/2020 - Acrescentar Filtro de Filial e verificar inconsistências na NF


//INICIO Ticket    1867 - Abel Babini - 28/12/2020 - Acrescentar Ajuste nos filtros / parâmetros do relatório que não estavam sendo utilizados e considerar o cadastro de cliente/fornecedor quand o campo XIT_CODPRD estiver em branco
/*/{Protheus.doc} xFilXML
	@description 	Retorna a FIlial do CMPJ relacionado ao XML
	@author 		Abel Babini
	@version		1.0
	@return			Nil
	@type 			Function
	/*/
Static Function xFilXML(cFilCNPJ)
	Local cFilXml := xFilial('SA5')
	Local aAllEmp		:= FWLoadSM0()
	Local _i			:= 0

	For _i := 1 to Len(aAllEmp)
		If	cFilCnpj == Alltrim(aAllEmp[_i,18]) .AND. cEmpAnt == Alltrim(aAllEmp[_i,01])
			cFilXml	:= aAllEmp[_i,2]
			EXIT
		ENDIF
	Next _i

Return cFilXml
//FIM Ticket    1867 - Abel Babini - 28/12/2020 - Acrescentar Ajuste nos filtros / parâmetros do relatório que não estavam sendo utilizados e considerar o cadastro de cliente/fornecedor quand o campo XIT_CODPRD estiver em branco


//INICIO Ticket   10427 - Abel Babini - 05/03/2021 - Acrescentado condição para procurar a NF de entrada na tabela SFT e SD1 com a série com 1, 2 ou 3 caracteres
/*/{Protheus.doc} fFindCST
	@description 	Retorna o CST ICMS do XML
	@author 		Abel Babini
	@version		1.0
	@return			Nil
	@type 			Function
	/*/
Static Function fFindCST(cChaveXML, cItemXML)
	Local cCSTICMS := ''
	Local cQryXML := GetNextAlias()
	Local cItem := Alltrim(Str(Val(cItemXML)))

	IF !Empty(Alltrim(cChaveXML))
		BeginSQL ALIAS cQryXML
			SELECT 
				SUBSTRING(SUBSTRING(ISNULL(CONVERT(VARCHAR(MAX),REPLACE(CONVERT(VARBINARY(MAX),XML_ARQ),char(13)+char(10),' ')),' '),CHARINDEX('det nItem="'+%Exp:cItem%+'"',ISNULL(CONVERT(VARCHAR(MAX),REPLACE(CONVERT(VARBINARY(MAX),XML_ARQ),char(13)+char(10),' ')),' ')),8000),
					CHARINDEX('CSOSN',SUBSTRING(ISNULL(CONVERT(VARCHAR(MAX),REPLACE(CONVERT(VARBINARY(MAX),XML_ARQ),char(13)+char(10),' ')),' '),CHARINDEX('det nItem="'+%Exp:cItem%+'"',ISNULL(CONVERT(VARCHAR(MAX),REPLACE(CONVERT(VARBINARY(MAX),XML_ARQ),char(13)+char(10),' ')),' ')),8000))+6,3) AS CSOSN
			FROM RECNFXML CAB 
			WHERE CAB.%notDel% AND
				XML_CHAVE = %Exp:cChaveXML% 
		ENDSQL

		IF !(cQryXML)->(eof())
			cCSTICMS := (cQryXML)->CSOSN
		ENDIF
		(cQryXML)->(dbCloseArea())
		
	ENDIF
Return cCSTICMS
//FIM Ticket   10427 - Abel Babini - 05/03/2021 - Acrescentado condição para procurar a NF de entrada na tabela SFT e SD1 com a série com 1, 2 ou 3 caracteres
