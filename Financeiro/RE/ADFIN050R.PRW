#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.ch"

// Chamado n. 051865 || OS 053202 || FINANCAS || DRIELE || 8376 || RELATORIO DE FLUXO - fwnm - 20/09/2019
Static cServBI := ""
Static cSGBDBI := ""
Static lErroBI := .f.
//

/*/{Protheus.doc} User Function ADFIN050R
	Relatorio de Fluxo de Caixa com balizador
	@type  Function
	@author Ricardo Lima
	@since 19/12/2017
	@version 01
	@history Chamado 039396 - Ricardo Lima    - 19/12/2017 - Relatorio de Fluxo Caixa
	@history Chamado 048344 - William Costa   - 08/04/2019 - Campo Produto quando vazio carregar natureza
	@history Chamado 048344 - William Costa   - 08/04/2019 - Campo Valor multiplicar por -1 ficando negativo
	@history Chamado 048577 - Everson         - 29/04/2019 - Adicionado grupo do produto
	@history Chamado 049691 - FWNM            - 01/08/2019 - Listar tambem os pagamentos em aberto
	@history Chamado 051865 - FWNM            - 17/09/2019 - Melhorias diversas de acordo detalhes chamado
	@history Chamado 051865 - FWNM            - 20/09/2019 - Integracao Power BI
	@history Chamado 051865 - FWNM            - 25/09/2019 - Power BI - Novas regras
	@history Chamado 051865 - FWNM            - 27/09/2019 - Power BI - Coluna RECPAG vazia
	@history Chamado TI     - FWNM            - 09/10/2019 - Power BI - Retirar acentuacoes
	@history Chamado TI     - FWNM            - 16/10/2019 - Power BI - Faturas nao estao puxando o produto predominante e se classificado pela natureza, tambem nao esta trazendo agrupador
	@history Chamado 052807 - FWNM            - 04/11/2019 - Power BI - Melhorias no relatorio fluxo caixa conforme email enviado para Fernando Sigoli
	@history Chamado 055114 - FWNM            - 27/01/2020 - OS 056520 || FINANCAS || DRIELE || 8376 || FLUXO DE CAIXA
	@history Chamado 055114 - FWNM            - 30/01/2020 - OS 056520 || FINANCAS || DRIELE || 8376 || FLUXO DE CAIXA
	@history Chamado 055337 - FWNM            - 03/02/2020 - OS 056759 || FINANCAS || DRIELE || 8376 || FLUXO DE CAIXAS
	@history Chamado 055337 - FWNM            - 10/02/2020 - OS 056759 || FINANCAS || DRIELE || 8376 || FLUXO DE CAIXAS
	@history Chamado 055337 - FWNM            - 13/02/2020 - OS 056759 || FINANCAS || DRIELE || 8376 || FLUXO DE CAIXAS
	@history Chamado 055337 - FWNM            - 02/03/2020 - OS 056759 || FINANCAS || DRIELE || 8376 || FLUXO DE CAIXAS
	@history Chamado 056357 - FWNM            - 17/03/2020 - || OS 057787 || FINANCAS || DRIELE || 8376 || FLUXO DE CAIXA  
	@history Chamado T.I    - SIGOLI          - 25/03/2020 - Power BI - Ajuste no insert, faltado virgula , error log
	@history Chamado 059892 - Everson		  - 23/07/2020 - Tratamento para no retorno do número da semana.
	@history ticket   10451 - Fernando Macieira    - 05/03/2021 - Retirar restrição para E5_BANCO do código CX1, manter apenas para P98 e Vazio
	@history ticket   10451 - Fernando Macieira    - 11/03/2021 - TIPODOC = TE entrar no relatório
	@history ticket   11397 - Fernando Macieira    - 23/03/2021 - Inclusão de Informações no relatório fluxo de caixa
	@history ticket   10451 - Fernando Macieira    - 25/03/2021 - Visão Previsão, mudar para saldo > 0, tirar inner join se5, vencimento real (mudar!), checar com atenção aquele Where com E2_BANCO (qual o impacto), data do borderô (se branco, buscar a última na tabela SEA)
	@history ticket   11767 - Fernando Macieira    - 31/03/2021 - Classificação Agrupador - O relatório está com erro quando o tipo de título (E2_TIPO = FT) - A fatura 242320 está agrupando como Milho, porém deveria agrupar como FARELO DE SOJA, visto que o agrupador do produto predominante é FARELO
	@history ticket   10451 - Fernando Macieira    - 05/04/2021 - Agrupador Investimentos (código = 025) para fatura, Abrir Coluna com nome da Empresa (ADORO, CERES, RNX2, etc) e Acrescentar pergunta Finalidade do Relatório: (opções Previsão, Realizado, Análises), Incluir esta informação no relatório
	@history ticket   10451 - Fernando Macieira    - 22/04/2021 - Relatório, Visão = Previsto - Trazer títulos tipo = PA somente quando NÃO tiver SE5 para o registro.
	@history ticket   10451 - Fernando Macieira    - 03/05/2021 - Adaptar FIN010 para SGFIN010 dentro do banco DADOSADV
	@history ticket   14822 - Fernando Macieira    - 10/06/2021 - Despesa classificada errada
	@history ticket   62700 - Leonardo P. Monteiro - 03/11/2021 - Correção da condição de classificação dos títulos como Intercompany. Adicionada a exceção quando os títulos forem do tipo "FOL".
	@history ticket   64920 - Leonardo P. Monteiro - 07/11/2021 - Melhoria na classificação do tipo de despesas.
	@history ticket   68289 - Fernando Macieira    - 16/02/2022 - Criação de critério Relatório Fluxo de Caixa
	@history ticket   68310 - Fernando Macieira    - 16/02/2022 - Manutenção no relatório de Fluxo de Caixa
	@history ticket   68310 - Leonardo P. Monteiro - 21/02/2022 - Restore do fonte atualizado.
	@history ticket   68310 - Fernando Macieira    - 23/02/2022 - Publicação autorizada
	@history Ticket 69574   - Abel Babini          - 25/04/2022 - Projeto FAI
/*/
User Function ADFIN050R() // U_ADFIN050R()

	Local oReport
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Fluxo de Caixa com balizador')

	MontaPerg()
	Pergunte("ADFIN050R",.T.)
	
	/*
	xPutSx1(cPerg,'01','Dt Dispo De ?'    , 'Dt Dispo De ?'    , 'Dt Dispo De ?'    , 'mv_ch1','D',8,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR01')
	xPutSx1(cPerg,'02','Dt Dispo Ate?'    , 'Dt Dispo Ate?'    , 'Dt Dispo Ate?'    , 'mv_ch2','D',8,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR02')
	xPutSx1(cPerg,'12','Vencimento De ?'  , 'Vencimento De ?', 'Vencimento De ?'    , 'mv_chc','D',8,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR12')
	xPutSx1(cPerg,'13','Vencimento Ate?'  , 'Vencimento Ate?', 'Vencimento Ate?'    , 'mv_chd','D',8,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR13')
	*/
	
	// Chamado n. 056357 || OS 057787 || FINANCAS || DRIELE || 8376 || FLUXO DE CAIXA - FWNM - 17/03/2020
	If MV_PAR15 == 1
		If !Empty(MV_PAR01) .or. !Empty(MV_PAR02)
			Alert("Você escolheu a visão de Previsão! Preencher apenas a data de vencimento...")
			Return
		EndIf
	EndIf
	//

	// Chamado n. 051865 || OS 053202 || FINANCAS || DRIELE || 8376 || RELATORIO DE FLUXO - fwnm - 20/09/2019
	cServBI := GetMV("MV_#BISERV",,"VPSRV14")
	cSGBDBI := GetMV("MV_#BISGBD",,"DWDADOSADV")                                                            
	//

	oReport := ReportDef()
	oReport:PrintDialog()
	
Return

/*/{Protheus.doc} Static Function REPORTDEF
	Relatorio de Fluxo de Caixa com balizador
	@type  Function
	@author Ricardo Lima
	@since 19/12/2017
	@version 01
	@history Chamado 
/*/
Static Function ReportDef()

	Local oReport
	Local oSection
	public oBreak
	
	oReport := TReport():New("ADFIN050R","Fluxo de Caixa",/*"ADFIN050R"*/,{|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a relacao des Titulo para o Fluxo de Caixa conforme os parametros solicitados.")
	oReport:SetDevice(4) // ABRE COM A SELECAO DE GERAR EM PLANILHA
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
	
	oSection := TRSection():New(oReport,OemToAnsi("Fluxo de Caixa"),{"SE5"},{"Movimentação-SE5"} )
	oSection2 := TRSection():New(oReport,OemToAnsi("Totalizador"),{""},{""} )
	
	If MV_PAR11 = 2  // Sintetico
		TRCell():New(oSection,"E5_FILIAL"  ,,"Fil")
		TRCell():New(oSection,"E5_NATUREZ" ,,"Natureza" )
		TRCell():New(oSection,"DESCNAT"    ,,"Descr Natureza" )
		TRCell():New(oSection,"E5_VENCTO"  ,,"Vencimento" )
		TRCell():New(oSection,"E5_VALOR"   ,,"Valor" )
	Else
		TRCell():New(oSection,"E5_FILIAL"  ,,"Fil")
		TRCell():New(oSection,"E5_PREFIXO" ,"SE5")
		TRCell():New(oSection,"E5_NUMERO"  ,"SE5")
		TRCell():New(oSection,"E5_PARCELA" ,"SE5")
		TRCell():New(oSection,"E5_TIPO"    ,"SE5")
		TRCell():New(oSection,"E5_CLIFOR"  ,"SE5")
		TRCell():New(oSection,"E5_LOJA"    ,"SE5")
		TRCell():New(oSection,"E5_BENEF"   ,"SE5")
		TRCell():New(oSection,"E5_BANCO"   ,"SE5")
		TRCell():New(oSection,"E5_AGENCIA" ,"SE5")
		TRCell():New(oSection,"E5_CONTA"   ,"SE5")
		TRCell():New(oSection,"E5_NATUREZ" ,,"Natureza" )
		TRCell():New(oSection,"DESCNAT"    ,,"Descr Natureza" )
		TRCell():New(oSection,"DTEMISSAO"  ,,"Data Emissão" )
		TRCell():New(oSection,"E5_DATA"    ,"SE5", "Data Baixa")
		TRCell():New(oSection,"E5_VENCTO"  ,,"Vencimento" )
		TRCell():New(oSection,"E2_VENCREA" ,,"Vencto Real" )
		TRCell():New(oSection,"E5_VALOR"   ,,"Valor" )
		TRCell():New(oSection,"E5_DTDISPO" ,"SE5")
		TRCell():New(oSection,"E5_DTDIGIT" ,"SE5", "Dt Entrada")
		TRCell():New(oSection,"E5_SEQ"     ,"SE5")
		TRCell():New(oSection,"CODPROD"    ,,"Codigo Produto", , 15 , )
		TRCell():New(oSection,"PRODUTO"    ,,"Produto", , 15 , )
		TRCell():New(oSection,"GRP_PRD"    ,,"Grp Produto", , 11 , ) //Everson - 29/04/2019. Chamado 048577.
		TRCell():New(oSection,"DSC_GRP"    ,,"Desc Grp", , 15 , )    //Everson - 29/04/2019. Chamado 048577.
		TRCell():New(oSection,"TIP_DES"    ,,"Tipo Despesa", , 15 , )    // Chamado n. 051865 || OS 053202 || FINANCAS || DRIELE || 8376 || RELATORIO DE FLUXO - fwnm - 17/09/2019
		TRCell():New(oSection,"STATUS"     ,,"Status" , , 10 , )
		
		// Chamado n. 051865 || OS 053202 || FINANCAS || DRIELE || 8376 || RELATORIO DE FLUXO - fwnm - 17/09/2019
		TRCell():New(oSection,"SEMANA"     ,,"SEMANA" , , 05 , )
		TRCell():New(oSection,"MES"        ,,"MES"    , , 05 , )
		TRCell():New(oSection,"EMPFIL"     ,,"CLASSFIL"    , , 05 , )
		TRCell():New(oSection,"E5_RECPAG"  ,,"REC/PAG"    , , 05 , )
		TRCell():New(oSection,"ENTSAI"     ,,"ENT/SAI"    , , 15 , )
		TRCell():New(oSection,"CNPJ"       ,,"CNPJ"       , , 15 , )
		TRCell():New(oSection,"RAZAO"      ,,"RAZAO"      , , 50 , )
		TRCell():New(oSection,"SEMANAFAT"  ,,"Semana Faturamento" , , 05 , )
		//

		TRCell():New(oSection,"FLUXOSTATUS"  ,,"Fluxo Caixa Status" , , 15 , ) // Chamado n. 056357 || OS 057787 || FINANCAS || DRIELE || 8376 || FLUXO DE CAIXA - FWNM - 17/03/2020

		// @history ticket   11397 - Fernando Maciei - 23/03/2021 - Inclusão de Informações no relatório fluxo de caixa
		TRCell():New(oSection,"PORTADOR" ,,"Portador" )
		TRCell():New(oSection,"BORDERO"  ,,"Bordero" )
		TRCell():New(oSection,"DTBORDERO",,"Dt Bordero" )
		//

		TRCell():New(oSection,"EMPRESA",,"Nome Empresa" ) // @history ticket   11767 - Fernando Maciei - 31/03/2021 - Classificação Agrupador - O relatório está com erro quando o tipo de título (E2_TIPO = FT) - A fatura 242320 está agrupando como Milho, porém deveria agrupar como FARELO DE SOJA, visto que o agrupador do produto predominante é FARELO
		TRCell():New(oSection,"FINALIDADE",,"Finalidade" ) // //@history ticket   10451 - Fernando Maciei - 05/04/2021 - Agrupador Investimentos (código = 025) para fatura, Abrir Coluna com nome da Empresa (ADORO, CERES, RNX2, etc) e Acrescentar pergunta Finalidade do Relatório: (opções Previsão, Realizado, Análises), Incluir esta informação no relatório
		TRCell():New(oSection,"A6_CONTA",,"Conta Contábil" ) // @history ticket   10451 - Fernando Maciei - 26/04/2021 - Relatório, Visão = Previsto - Trazer títulos tipo = PA somente quando NÃO tiver SE5 para o registro.

	Endif
	
	// QUEBRA DE PAGINA E TOTALIZADORES
	If MV_PAR11 = 2  // Sintetico
		oBreak := TRBreak():New(oSection,oSection:Cell("E5_VENCTO"),"S",.F.)
	Else
		oBreak := TRBreak():New(oSection,oSection:Cell("E5_NATUREZ"),"S",.F.)
	Endif
	TRFunction():New(oSection:Cell("E5_VALOR"),NIL,"SUM",oBreak,"",/*cPicture*/,/*uFormula*/,.F.,.F.)
	
	TRCell():New(oSection2,"TOTALPRD1"  ,,"Codigo Produto" )
	TRCell():New(oSection2,"TOTALPRD2"  ,,"Descrição Produto" )
	TRCell():New(oSection2,"TOTALPRD3"  ,,"Total Produto" )
	
Return oReport

/*/{Protheus.doc} Static Function PRINTREPORT
	Relatorio de Fluxo de Caixa com balizador
	@type  Function
	@author Ricardo Lima
	@since 19/12/2017
	@version 01
	@history Chamado 
/*/
Static Function PrintReport(oReport)

	Local oSection	:= oReport:Section(1)
	Local nOrdem   	:= oReport:Section(1):GetOrder()
	Local cAliasTop	:= "E2"
	Local cAliaTop2	:= "B1"
	Local nDWeek   	:= 0
	Local cStatus  	:= ""
	Local CodPrdMv 	:= ""
	Local cPrdMvlr	:= ""
	Local nVlrMrnf	:= 0
	Local aDadFCVP	:= {}
	Local cNatFCVP	:= ""
	Local dDatFCVP	:= ""
	Local nVlrFCVP	:= 0
	Local dDtEmiss  := ""
	
	Local aDadFCSC	:= {}
	Local cNatFCSC	:= ""
	Local dDatFCSC	:= ""
	Local nVlrFCSC	:= 0
	Local dDatBaixa	:= ""
	Local dDataEmis	:= ""
	Local oSection2	:= oReport:Section(2)
	Local aTotalPr	:= {}
	Local lAtuArr	:= .T.

	Local nDadFCVP	:= 0
	Local A			:= 0
	Local p			:= 0
	Local i			:= 0
	
	//Everson - 29/04/2019. Chamado 048577.
	Local cGrpPrd	:= ""
	Local cDscGrp	:= ""
	//
	
	// Chamado n. 051865 || OS 053202 || FINANCAS || DRIELE || 8376 || RELATORIO DE FLUXO - fwnm - 17/09/2019
	Local aTipDes   := ""
	Local cTipDes   := ""
	//                   
	
	// Chamado n. 052807 || OS 054158 || FINANCAS || DRIELE || 8376 || REL. FLUXO - FWNM - 04/11/2019
	Local dVencto  := ""
	Local dVencrea := ""
	//

	Local dDtDispo := CtoD("//") // Chamado n. 055337 || OS 056759 || FINANCAS || DRIELE || 8376 || FLUXO DE CAIXAS - FWNM - 03/02/2020
	Local cNomEmp  := "" // @history ticket   11767 - Fernando Maciei - 31/03/2021 - Classificação Agrupador - O relatório está com erro quando o tipo de título (E2_TIPO = FT) - A fatura 242320 está agrupando como Milho, porém deveria agrupar como FARELO DE SOJA, visto que o agrupador do produto predominante é FARELO
	
	Local cQuery   := ""
	Local cEOL	   := Chr(13)+chr(10)

	// Chamado n. 051865 || OS 053202 || FINANCAS || DRIELE || 8376 || RELATORIO DE FLUXO - fwnm - 20/09/2019
	If MV_PAR14 == 1 // Integra Power BI
		lErroBI := .f.
		DelPowerBI( @lErroBI )
		If lErroBI
			If msgYesNo("Deseja abortar processamento para mudar parâmetro de integração Power BI = 'Não' devido ao erro de integração e continuar sem integrar? ")
				Return
			EndIf
		EndIf
	EndIf
	//

	oSection:Init()
	
	// Chamado n. 056357 || OS 057787 || FINANCAS || DRIELE || 8376 || FLUXO DE CAIXA - FWNM - 17/03/2020 
	If MV_PAR15 == 1 // Visão Previsao (CAMPO FLUXOCAIXA_STATUS) - tudo que tinha vencimento num range de datas e que foi baixado na data, antecipado ou em atraso
		/*
		BeginSql Alias cAliasTop
				
			Column E5_DATA    as Date
			Column E5_VENCTO  as Date
			Column E5_DTDISPO as Date
			Column E5_DTDIGIT as Date
		*/
		cQuery := "	SELECT 	'SE1' TABELA, " +cEOL
		cQuery += "			E1_FILIAL E5FILIAL, " +cEOL
		cQuery += "			IIF(E1_FILIAL='01' OR E1_FILIAL='02','VP','SC') E5_FILIAL,  " +cEOL
		cQuery += "			E1_PREFIXO E5_PREFIXO,  " +cEOL
		cQuery += "			E1_NUM E5_NUMERO,  " +cEOL
		cQuery += "			E1_PARCELA  " +cEOL
		cQuery += "			E5_PARCELA,  " +cEOL
		cQuery += "			E1_TIPO E5_TIPO,  " +cEOL
		cQuery += "			E1_CLIENTE E5_CLIFOR,  " +cEOL
		cQuery += "			E1_LOJA E5_LOJA,  " +cEOL
		cQuery += "			E1_NOMCLI E5_BENEF,  " +cEOL
		cQuery += "			SUBSTRING(E1_NATUREZ,1,3) E5_NATUREZ,  " +cEOL
		cQuery += "			E1_EMISSAO E5_DATA,  " +cEOL
		cQuery += "			E1_VENCREA E5_VENCTO,  " +cEOL
		cQuery += "			E1_EMIS1 E5_DTDISPO,  " +cEOL
		cQuery += "			E1_EMISSAO E5_DTDIGIT,  " +cEOL
		cQuery += "			E1_SALDO E5_VALOR,  " +cEOL
		cQuery += "			'' E5_SEQ,  " +cEOL
		cQuery += "			E1_BANCO E5_BANCO,  " +cEOL
		cQuery += "			E1_AGEDEP E5_AGENCIA,  " +cEOL
		cQuery += "			E1_CONTA E5_CONTA, " +cEOL
		cQuery += "			SE1.R_E_C_N_O_ RECNO,  " +cEOL
		cQuery += "			'R' E5_RECPAG,  " +cEOL
		cQuery += "			E1_NATUREZ NATUREZA_FIN, " +cEOL 
		cQuery += "			'' E5_NUMCHEQ,  " +cEOL
		cQuery += "			E1_PORTADO PORTADOR,  " +cEOL
		cQuery += "			E1_NUMBOR BORDERO,  " +cEOL
		cQuery += "			E1_DATABOR DTBORDERO, " +cEOL
		cQuery += "			ISNULL(ED_CODIGO,'') NAT_COD, " +cEOL
		cQuery += "			ISNULL(ED_DESCRIC,'') NAT_DESC, " +cEOL
		cQuery += "			ISNULL(ZFH.ZFH_COD,'') GRPFIN_COD, " +cEOL
		cQuery += "			ISNULL(ZFH.ZFH_DESCRI,'') GRPFIN_DESC, " +cEOL
		cQuery += "			ISNULL(ZFH.ZFH_TIPO,'') GRPFIN_TIPO, " +cEOL
		cQuery += "			ISNULL(CASE ZFH.ZFH_TIPO WHEN 1 THEN '1=CAIXA OPERACIONAL' WHEN 2 THEN '2=CAIXA NAO OPERACIONAL' ELSE ZFH.ZFH_TIPO END,'') GRPFIN_DESC, " +cEOL
		cQuery += "			'' E5_TIPODOC " +cEOL
		cQuery += "	FROM "+ retsqlname("SE1") +" SE1 (NOLOCK)  " +cEOL
		cQuery += "		LEFT JOIN "+ retsqlname("SED") +" SED (NOLOCK) ON SE1.D_E_L_E_T_='' AND SED.D_E_L_E_T_='' AND SE1.E1_NATUREZ=SED.ED_CODIGO " +cEOL
		cQuery += "		LEFT JOIN "+ retsqlname("ZFH") +" ZFH (NOLOCK) ON ZFH.D_E_L_E_T_='' AND ZFH.ZFH_COD=SED.ED_XGRPFIN " +cEOL
		cQuery += "	WHERE " +cEOL
		cQuery += "	E1_FILIAL BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' " +cEOL
		cQuery += "	AND E1_VENCREA BETWEEN '"+dtos(MV_PAR12)+"' AND '"+dtos(MV_PAR13)+"'  " +cEOL
		cQuery += "	AND E1_BANCO between '' AND '"+'ZZZ'+"' " +cEOL
		cQuery += "	AND E1_NATUREZ BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " +cEOL
		cQuery += "	AND E1_CLIENTE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"' " +cEOL
		cQuery += "	AND E1_LOJA BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"' " +cEOL
		cQuery += "	AND E1_SALDO>0  " +cEOL
		cQuery += "	AND SE1.D_E_L_E_T_='' " +cEOL

		cQuery += "	UNION ALL " +cEOL

			//SELECT 'SE2' TABELA, E2_FILIAL E5FILIAL, IIF(E2_FILIAL='01' OR E2_FILIAL='02','VP','SC') E5_FILIAL, E2_PREFIXO E5_PREFIXO, E2_NUM E5_NUMERO, E2_PARCELA E5_PARCELA, E2_TIPO E5_TIPO, E2_FORNECE E5_CLIFOR, E2_LOJA E5_LOJA, E2_NOMFOR E5_BENEF, SUBSTRING(E2_NATUREZ,1,3) E5_NATUREZ, E2_EMISSAO E5_DATA, E2_VENCREA E5_VENCTO, E2_EMIS1 E5_DTDISPO, E2_EMISSAO E5_DTDIGIT, E2_SALDO E5_VALOR, '' E5_SEQ, E2_BANCO E5_BANCO, E2_AGEN E5_AGENCIA, E2_NOCTA E5_CONTA, 'P' E5_RECPAG, E2_NATUREZ NATUREZA_FIN, '' E5_NUMCHEQ, E2_PORTADO PORTADOR, E2_NUMBOR BORDERO, E2_DTBORDE DTBORDERO // @history ticket   10451 - Fernando Maciei - 22/04/2021 - Relatório, Visão = Previsto - Trazer títulos tipo = PA somente quando NÃO tiver SE5 para o registro.
		cQuery += "	SELECT 	'SE2' TABELA,  " +cEOL
		cQuery += "			E2_FILIAL E5FILIAL,  " +cEOL
		cQuery += "			IIF(E2_FILIAL='01' OR E2_FILIAL='02','VP','SC') E5_FILIAL,  " +cEOL
		cQuery += "			E2_PREFIXO E5_PREFIXO,  " +cEOL
		cQuery += "			E2_NUM E5_NUMERO,  " +cEOL
		cQuery += "			E2_PARCELA E5_PARCELA,  " +cEOL
		cQuery += "			E2_TIPO E5_TIPO,  " +cEOL
		cQuery += "			E2_FORNECE E5_CLIFOR,  " +cEOL
		cQuery += "			E2_LOJA E5_LOJA,  " +cEOL
		cQuery += "			E2_NOMFOR E5_BENEF,  " +cEOL
		cQuery += "			SUBSTRING(E2_NATUREZ,1,3) E5_NATUREZ,  " +cEOL
		cQuery += "			E2_EMISSAO E5_DATA,  " +cEOL
		cQuery += "			E2_VENCREA E5_VENCTO,  " +cEOL
		cQuery += "			E2_VENCREA E5_DTDISPO,  " +cEOL
		cQuery += "			E2_EMISSAO E5_DTDIGIT,  " +cEOL
		cQuery += "			E2_SALDO E5_VALOR,  " +cEOL
		cQuery += "			'' E5_SEQ,  " +cEOL
		cQuery += "			E2_BANCO E5_BANCO,  " +cEOL
		cQuery += "			E2_AGEN E5_AGENCIA,  " +cEOL
		cQuery += "			E2_NOCTA E5_CONTA, " +cEOL
		cQuery += "			SE2.R_E_C_N_O_ RECNO, " +cEOL
		cQuery += "			'P' E5_RECPAG,  " +cEOL
		cQuery += "			E2_NATUREZ NATUREZA_FIN,  " +cEOL
		cQuery += "			'' E5_NUMCHEQ,  " +cEOL
		cQuery += "			E2_PORTADO PORTADOR,  " +cEOL
		cQuery += "			E2_NUMBOR BORDERO,  " +cEOL
		cQuery += "			E2_DTBORDE DTBORDERO,  " +cEOL
		cQuery += "			ISNULL(ED_CODIGO,'') NAT_COD, " +cEOL
		cQuery += "			ISNULL(ED_DESCRIC,'') NAT_DESC, " +cEOL
		cQuery += "			ISNULL(ZFH.ZFH_COD,'') GRPFIN_COD, " +cEOL
		cQuery += "			ISNULL(ZFH.ZFH_DESCRI,'') GRPFIN_DESC, " +cEOL
		cQuery += "			ISNULL(ZFH.ZFH_TIPO,'') GRPFIN_TIPO, " +cEOL
		cQuery += "			ISNULL(CASE ZFH.ZFH_TIPO WHEN 1 THEN '1=CAIXA OPERACIONAL' WHEN 2 THEN '2=CAIXA NAO OPERACIONAL' ELSE ZFH.ZFH_TIPO END,'') GRPFIN_DESC, " +cEOL
		cQuery += "			'' E5_TIPODOC " +cEOL
		cQuery += "	FROM "+ retsqlname("SE2") +" SE2 (NOLOCK)  " +cEOL
		cQuery += "		LEFT JOIN "+ retsqlname("SED") +" SED (NOLOCK) ON SE2.D_E_L_E_T_='' AND SED.D_E_L_E_T_='' AND SE2.E2_NATUREZ=SED.ED_CODIGO " +cEOL
		cQuery += "		LEFT JOIN "+ retsqlname("ZFH") +" ZFH (NOLOCK) ON ZFH.D_E_L_E_T_='' AND ZFH.ZFH_COD=SED.ED_XGRPFIN " +cEOL
		cQuery += "	WHERE " +cEOL
		cQuery += "	E2_FILIAL BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' " +cEOL
		cQuery += "	AND E2_VENCREA BETWEEN '"+dtos(MV_PAR12)+"' AND '"+dtos(MV_PAR13)+"'  " +cEOL
		cQuery += "	AND E2_BANCO between '' AND '"+'ZZZ'+"' " +cEOL
		cQuery += "	AND E2_NATUREZ BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " +cEOL
		cQuery += "	AND E2_FORNECE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"' " +cEOL
		cQuery += "	AND E2_LOJA BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"' " +cEOL
		cQuery += "	AND E2_SALDO>0  " +cEOL
		cQuery += "	AND SE2.D_E_L_E_T_='' " +cEOL

		cQuery += "	ORDER BY E5_DATA, E5_NATUREZ, E5_FILIAL " +cEOL
			
		//EndSql

	//
	Else
		/*
		BeginSql Alias cAliasTop
				
			Column E5_DATA    as Date
			Column E5_VENCTO  as Date
			Column E5_DTDISPO as Date
			Column E5_DTDIGIT as Date
		*/
	 		// Chamado n. 051865 || OS 053202 || FINANCAS || DRIELE || 8376 || RELATORIO DE FLUXO - fwnm - 25/09/2019
		cQuery := "	SELECT 	'SE5' TABELA,  " +cEOL
		cQuery += "			E5_FILIAL E5FILIAL,  " +cEOL
		cQuery += "			IIF(E5_FILIAL='01' OR E5_FILIAL='02','VP','SC') E5_FILIAL,  " +cEOL
		cQuery += "			E5_PREFIXO,  " +cEOL
		cQuery += "			E5_NUMERO,  " +cEOL
		cQuery += "			E5_PARCELA,  " +cEOL
		cQuery += "			E5_TIPO,  " +cEOL
		cQuery += "			E5_CLIFOR,  " +cEOL
		cQuery += "			E5_LOJA,  " +cEOL
		cQuery += "			E5_BENEF,  " +cEOL
		cQuery += "			E5_NATUREZ,  " +cEOL
		cQuery += "			E5_DATA,  " +cEOL
		cQuery += "			E5_VENCTO,  " +cEOL
		cQuery += "			E5_DTDISPO,  " +cEOL
		cQuery += "			E5_DTDIGIT,  " +cEOL
		cQuery += "			E5_VALOR,  " +cEOL
		cQuery += "			E5_SEQ,  " +cEOL
		cQuery += "			E5_BANCO,  " +cEOL
		cQuery += "			E5_AGENCIA,  " +cEOL
		cQuery += "			E5_CONTA, " +cEOL
		cQuery += "			SE5.R_E_C_N_O_ RECNO, " +cEOL
		cQuery += "			E5_RECPAG,  " +cEOL
		cQuery += "			E5_NATUREZ NATUREZA_FIN,  " +cEOL
		cQuery += "			E5_NUMCHEQ,  " +cEOL
		cQuery += "			E5_BANCO PORTADOR,  " +cEOL
		cQuery += "			'' BORDERO,  " +cEOL
		cQuery += "			'' DTBORDERO, " +cEOL
		cQuery += "			ISNULL(ED_CODIGO,'') NAT_COD, " +cEOL
		cQuery += "			ISNULL(ED_DESCRIC,'') NAT_DESC, " +cEOL
		cQuery += "			ISNULL(ZFH.ZFH_COD,'') GRPFIN_COD, " +cEOL
		cQuery += "			ISNULL(ZFH.ZFH_DESCRI,'') GRPFIN_DESC, " +cEOL
		cQuery += "			ISNULL(ZFH.ZFH_TIPO,'') GRPFIN_TIPO, " +cEOL
		cQuery += "			ISNULL(CASE ZFH.ZFH_TIPO WHEN 1 THEN '"+'1=CAIXA OPERACIONAL'+"' WHEN 2 THEN '"+'2=CAIXA NAO OPERACIONAL'+"' ELSE ZFH.ZFH_TIPO END,'') GRPFIN_DESC, " +cEOL
		cQuery += "			E5_TIPODOC " +cEOL

		cQuery += "	FROM "+ retsqlname("SE5") +" SE5 (NOLOCK) " +cEOL
		cQuery += "		LEFT JOIN "+ retsqlname("SED") +" SED (NOLOCK) ON SE5.D_E_L_E_T_='' AND SED.D_E_L_E_T_='' AND SE5.E5_NATUREZ=SED.ED_CODIGO " +cEOL
		cQuery += "		LEFT JOIN "+ retsqlname("ZFH") +" ZFH (NOLOCK) ON ZFH.D_E_L_E_T_='' AND ZFH.ZFH_COD=SED.ED_XGRPFIN " +cEOL
		cQuery += "	WHERE " +cEOL
		cQuery += "	E5_FILIAL BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' " +cEOL
			
		cQuery += "	AND E5_DTDISPO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " +cEOL
			
		cQuery += "	AND E5_BANCO between '' AND '"+'ZZZ'+"' " +cEOL
		cQuery += "	AND E5_BANCO NOT IN ('P98','','P99') " +cEOL
		
		cQuery += "	AND E5_NATUREZ BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " +cEOL

		cQuery += "	AND E5_NATUREZ NOT IN ('NATMOVP','NATMOVR') " +cEOL
		cQuery += "	AND E5_CLIFOR BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"' " +cEOL
		cQuery += "	AND E5_LOJA BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"' " +cEOL
		cQuery += "	AND SE5.D_E_L_E_T_='' " +cEOL
		cQuery += "	AND E5_TIPODOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2')  " +cEOL

		cQuery += "	AND E5_SITUACA NOT IN ('C')  " +cEOL
			
		cQuery += "	AND ((E5_TIPODOC = 'CD' AND E5_VENCTO <= E5_DATA) OR (E5_TIPODOC <> 'CD')) " +cEOL
		cQuery += "	AND E5_TIPODOC <> '"+'E2'+"' " +cEOL
		cQuery += "	AND E5_MOTBX IN ('   ','NOR','DEB') " +cEOL
		cQuery += "	UNION ALL " +cEOL
			
		cQuery += "	SELECT 'SE2' TABELA, " +cEOL
		cQuery += "	 E2_FILIAL E5FILIAL,  " +cEOL
		cQuery += "	IIF(E2_FILIAL='01' OR E2_FILIAL='02','VP','SC') E5_FILIAL,  " +cEOL
		cQuery += "	E2_PREFIXO E5_PREFIXO,  " +cEOL
		cQuery += "	E2_NUM E5_NUMERO,  " +cEOL
		cQuery += "	E2_PARCELA E5_PARCELA,  " +cEOL
		cQuery += "	E2_TIPO E5_TIPO,  " +cEOL
		cQuery += "	E2_FORNECE E5_CLIFOR,  " +cEOL
		cQuery += "	E2_LOJA E5_LOJA,  " +cEOL
		cQuery += "	E2_NOMFOR E5_BENEF,  " +cEOL
		cQuery += "	SUBSTRING(E2_NATUREZ,1,3) E5_NATUREZ,  " +cEOL
		cQuery += "	'' E5_DATA,  " +cEOL
		cQuery += "	E2_VENCTO E5_VENCTO,  " +cEOL
		cQuery += "	E2_EMIS1 E5_DTDISPO,  " +cEOL
		cQuery += "	E2_EMISSAO E5_DTDIGIT,  " +cEOL
		cQuery += "	E2_SALDO E5_VALOR,  " +cEOL
		cQuery += "	'' E5_SEQ,  " +cEOL
		cQuery += "	E2_BANCO E5_BANCO,  " +cEOL
		cQuery += "	E2_AGEN E5_AGENCIA,  " +cEOL
		cQuery += "	E2_NOCTA E5_CONTA, " +cEOL
		cQuery += "	SE2.R_E_C_N_O_ RECNO, " +cEOL
		cQuery += "	'P' E5_RECPAG,  " +cEOL
		cQuery += "	E2_NATUREZ NATUREZA_FIN, " +cEOL 
		cQuery += "	'' E5_NUMCHEQ,  " +cEOL
		cQuery += "	E2_PORTADO PORTADOR,  " +cEOL
		cQuery += "	E2_NUMBOR BORDERO,  " +cEOL
		cQuery += "	E2_DTBORDE DTBORDERO, " +cEOL
		cQuery += "	ISNULL(ED_CODIGO,'') NAT_COD, " +cEOL
		cQuery += "	ISNULL(ED_DESCRIC,'') NAT_DESC, " +cEOL
		cQuery += "	ISNULL(ZFH.ZFH_COD,'') GRPFIN_COD, " +cEOL
		cQuery += "	ISNULL(ZFH.ZFH_DESCRI,'') GRPFIN_DESC, " +cEOL
		cQuery += "	ISNULL(ZFH.ZFH_TIPO,'') GRPFIN_TIPO, " +cEOL
		cQuery += "	ISNULL(CASE ZFH.ZFH_TIPO WHEN 1 THEN '"+'1=CAIXA OPERACIONAL'+"' WHEN 2 THEN '"+'2=CAIXA NAO OPERACIONAL'+"' ELSE ZFH.ZFH_TIPO END,'') GRPFIN_DESC, " +cEOL
		cQuery += "	'' E5_TIPODOC " +cEOL

		cQuery += "	FROM "+ retsqlname("SE2") +" SE2 (NOLOCK) " +cEOL
		cQuery += "		LEFT JOIN "+ retsqlname("SED") +" SED (NOLOCK) ON SE2.D_E_L_E_T_='' AND SED.D_E_L_E_T_='' AND SE2.E2_NATUREZ=SED.ED_CODIGO " +cEOL
		cQuery += "		LEFT JOIN "+ retsqlname("ZFH") +" ZFH (NOLOCK) ON ZFH.D_E_L_E_T_='' AND ZFH.ZFH_COD=SED.ED_XGRPFIN " +cEOL
		cQuery += "	WHERE " +cEOL
		cQuery += "	E2_FILIAL BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' " +cEOL
		cQuery += "	AND E2_VENCTO BETWEEN '"+dtos(MV_PAR12)+"' AND '"+dtos(MV_PAR13)+"' " +cEOL
		cQuery += "	AND E2_BANCO between '' AND '"+'ZZZ'+"' " +cEOL
		
		cQuery += "	AND E2_NATUREZ BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " +cEOL
		cQuery += "	AND E2_FORNECE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"' " +cEOL
		cQuery += "	AND E2_LOJA BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"' " +cEOL
		cQuery += "	AND E2_SALDO>0 " +cEOL
		cQuery += "	AND SE2.D_E_L_E_T_='' " +cEOL
			
		cQuery += "	UNION ALL " +cEOL
		
		cQuery += "	SELECT 'SE1' TABELA,  " +cEOL
		cQuery += "	E1_FILIAL E5FILIAL,  " +cEOL
		cQuery += "	IIF(E1_FILIAL='01' OR E1_FILIAL='02','VP','SC') E5_FILIAL,  " +cEOL
		cQuery += "	E1_PREFIXO E5_PREFIXO,  " +cEOL
		cQuery += "	E1_NUM E5_NUMERO,  " +cEOL
		cQuery += "	E1_PARCELA E5_PARCELA,  " +cEOL
		cQuery += "	E1_TIPO E5_TIPO,  " +cEOL
		cQuery += "	E1_CLIENTE E5_CLIFOR,  " +cEOL
		cQuery += "	E1_LOJA E5_LOJA,  " +cEOL
		cQuery += "	E1_NOMCLI E5_BENEF,  " +cEOL
		cQuery += "	SUBSTRING(E1_NATUREZ,1,3) E5_NATUREZ, '' E5_DATA, E1_VENCTO E5_VENCTO,  " +cEOL
		cQuery += "	E1_EMIS1 E5_DTDISPO,  " +cEOL
		cQuery += "	E1_EMISSAO E5_DTDIGIT,  " +cEOL
		cQuery += "	E1_SALDO E5_VALOR,  " +cEOL
		cQuery += "	'' E5_SEQ,  " +cEOL
		cQuery += "	E1_BANCO E5_BANCO,  " +cEOL
		cQuery += "	E1_AGEDEP E5_AGENCIA,  " +cEOL
		cQuery += "	E1_CONTA E5_CONTA, " +cEOL
		cQuery += "	SE1.R_E_C_N_O_ RECNO, " +cEOL
		cQuery += "	'R' E5_RECPAG,  " +cEOL
		cQuery += "	E1_NATUREZ NATUREZA_FIN, " +cEOL 
		cQuery += "	'' E5_NUMCHEQ,  " +cEOL
		cQuery += "	E1_PORTADO PORTADOR,  " +cEOL
		cQuery += "	E1_NUMBOR BORDERO,  " +cEOL
		cQuery += "	E1_DATABOR DTBORDERO, " +cEOL
		cQuery += "	ISNULL(ED_CODIGO,'') NAT_COD, " +cEOL
		cQuery += "	ISNULL(ED_DESCRIC,'') NAT_DESC, " +cEOL
		cQuery += "	ISNULL(ZFH.ZFH_COD,'') GRPFIN_COD, " +cEOL
		cQuery += "	ISNULL(ZFH.ZFH_DESCRI,'') GRPFIN_DESC, " +cEOL
		cQuery += "	ISNULL(ZFH.ZFH_TIPO,'') GRPFIN_TIPO, " +cEOL
		cQuery += "	ISNULL(CASE ZFH.ZFH_TIPO WHEN 1 THEN '"+'1=CAIXA OPERACIONAL'+"' WHEN 2 THEN '"+'2=CAIXA NAO OPERACIONAL'+"' ELSE ZFH.ZFH_TIPO END,'') GRPFIN_DESC, " +cEOL
		cQuery += "			'' E5_TIPODOC " +cEOL

		cQuery += "	FROM "+ retsqlname("SE1") +" SE1 (NOLOCK)  " +cEOL
		cQuery += "		LEFT JOIN "+ retsqlname("SED") +" SED (NOLOCK) ON SE1.D_E_L_E_T_='' AND SED.D_E_L_E_T_='' AND SE1.E1_NATUREZ=SED.ED_CODIGO " +cEOL
		cQuery += "		LEFT JOIN "+ retsqlname("ZFH") +" ZFH (NOLOCK) ON ZFH.D_E_L_E_T_='' AND ZFH.ZFH_COD=SED.ED_XGRPFIN " +cEOL
		cQuery += "	WHERE " +cEOL
		cQuery += "	E1_FILIAL BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' " +cEOL
		cQuery += "	AND E1_VENCTO BETWEEN '"+dtos(MV_PAR12)+"' AND '"+dtos(MV_PAR13)+"' " +cEOL
		cQuery += "	AND E1_BANCO between '' AND '"+'ZZZ'+"' " +cEOL
		cQuery += "	AND E1_NATUREZ BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " +cEOL
		cQuery += "	AND E1_CLIENTE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"' " +cEOL
		cQuery += "	AND E1_LOJA BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"' " +cEOL
		cQuery += "	AND E1_SALDO>0 " +cEOL
		cQuery += "	AND SE1.D_E_L_E_T_='' " +cEOL
		
		cQuery += "	ORDER BY E5_DATA, E5_NATUREZ, E5_FILIAL " +cEOL

	EndIf

	TcQuery cQuery ALIAS (cAliasTop) NEW

	TCSETFIELD( cAliasTop, "E5_DATA"	, "D", 8, 0 )
	TCSETFIELD( cAliasTop, "E5_VENCTO"	, "D", 8, 0 )
	TCSETFIELD( cAliasTop, "E5_DTDISPO"	, "D", 8, 0 )
	TCSETFIELD( cAliasTop, "E5_DTDIGIT"	, "D", 8, 0 )

	oReport:SetMeter(RecCount())
	
	If MV_PAR11 = 2  // Sintetico
		
		dDatFC := (cAliasTop)->E5_DATA
		cNatFC := (cAliasTop)->E5_NATUREZ
		
		While !(cAliasTop)->(Eof())
			
			IF (cAliasTop)->E5_FILIAL='VP'
				
				IF ALLTRIM((cAliasTop)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)) <> '' //CHAMADO WILLIAM 06/11/2018 044779 || OS 045954 || FINANCAS || DRIELE || 8376 || REL. FLUXO CAIXA
					
					IF TemBxCanc( (cAliasTop)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ) )
						DbSelectArea(cAliasTop)
						(cAliasTop)->(dbSkip())
						Loop
					ENDIF
				ENDIF
				
				If cNatFCVP = (cAliasTop)->E5_NATUREZ
					nVlrFCVP += (cAliasTop)->E5_VALOR
				Else
					IF nVlrFCVP > 0
						AADD( aDadFCVP , { dDatFCVP , cNatFCVP , nVlrFCVP , (cAliasTop)->E5_FILIAL } )
					EndIf
					nVlrFCVP := 0
				EndIf
				
				dDatFCVP := (cAliasTop)->E5_DATA
				cNatFCVP := (cAliasTop)->E5_NATUREZ
				
				DbSelectArea(cAliasTop)
				DbSkip()
				oReport:IncMeter()
				
			Else // SC
				
				IF ALLTRIM((cAliasTop)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)) <> '' //CHAMADO WILLIAM 06/11/2018 044779 || OS 045954 || FINANCAS || DRIELE || 8376 || REL. FLUXO CAIXA
					
					If TemBxCanc( (cAliasTop)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ) )
						DbSelectArea(cAliasTop)
						(cAliasTop)->(dbSkip())
						Loop
					Endif
				ENDIF
				
				If cNatFCSC = (cAliasTop)->E5_NATUREZ
					nVlrFCSC += (cAliasTop)->E5_VALOR
				Else
					IF nVlrFCSC > 0
						AADD( aDadFCSC , { dDatFCSC , cNatFCSC , nVlrFCSC , (cAliasTop)->E5_FILIAL } )
					EndIf
					nVlrFCSC := 0
				EndIf
				
				dDatFCSC := (cAliasTop)->E5_DATA
				cNatFCSC := (cAliasTop)->E5_NATUREZ
				DbSelectArea(cAliasTop)
				DbSkip()
				oReport:IncMeter()
			EndIf
			
		EndDO
		
		IF LEN(aDadFCVP) > 0
			
			nDadFCVP := Len(aDadFCVP)

			//FOR A:=1 TO LEN(aDadFCVP)
			FOR A:=1 TO nDadFCVP
			
				If oReport:Cancel()
					Exit
				EndIf
				
				oSection:Cell("E5_FILIAL") :SetValue( aDadFCVP[A][4] )
				oSection:Cell("E5_NATUREZ"):SetValue( aDadFCVP[A][2] )
				oSection:Cell("E5_VENCTO") :SetValue( aDadFCVP[A][1] )
				oSection:Cell("E5_VALOR")  :SetValue( aDadFCVP[A][3] )
				oSection:Cell("DESCNAT")   :SetValue( Posicione( "SED" , 1 , xFilial("SED") + aDadFCVP[A][2] , "ED_DESCRIC") )
				
				oSection:PrintLine()
				oBreak:SetTitle('Total')
				oReport:IncMeter()
				
			NEXT
			
		EndIf
		
		IF LEN(aDadFCSC) > 0
			
			FOR A:=1 TO LEN(aDadFCSC)
				
				If oReport:Cancel()
					Exit
				EndIf
				
				oSection:Cell("E5_FILIAL") :SetValue( aDadFCSC[A][4] )
				oSection:Cell("E5_NATUREZ"):SetValue( aDadFCSC[A][2] )
				oSection:Cell("E5_VENCTO") :SetValue( aDadFCSC[A][1] )
				oSection:Cell("E5_VALOR")  :SetValue( aDadFCSC[A][3] )
				oSection:Cell("DESCNAT")   :SetValue( Posicione( "SED" , 1 , xFilial("SED") + aDadFCSC[A][2] , "ED_DESCRIC") )
				
				oSection:PrintLine()
				oBreak:SetTitle('Total')
				oReport:IncMeter()
				
			NEXT
			
		EndIf
		
	Else  // Analitico
		
		While !(cAliasTop)->(Eof())
			
			IF ALLTRIM((cAliasTop)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)) <> '' //CHAMADO WILLIAM 06/11/2018 044779 || OS 045954 || FINANCAS || DRIELE || 8376 || REL. FLUXO CAIXA
				
				If TemBxCanc( (cAliasTop)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ) )
					DbSelectArea(cAliasTop)
					(cAliasTop)->(dbSkip())
					Loop
				Endif
				
			ENDIF

			// @history ticket   10451 - Fernando Maciei - 22/04/2021 - Relatório, Visão = Previsto - Trazer títulos tipo = PA somente quando NÃO tiver SE5 para o registro.
			If MV_PAR15 == 1 // Visão Previsao

				If AllTrim((cAliasTop)->E5_TIPO) == "PA"

					SE5->( dbSetOrder(7) ) // E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_SEQ, R_E_C_N_O_, D_E_L_E_T_
					If SE5->( dbSeek( (cAliasTop)->E5FILIAL + (cAliasTop)->E5_PREFIXO + (cAliasTop)->E5_NUMERO + (cAliasTop)->E5_PARCELA + (cAliasTop)->E5_TIPO + (cAliasTop)->E5_CLIFOR + (cAliasTop)->E5_LOJA ) )
						(cAliasTop)->( dbSkip() )
						Loop
					EndIf

				EndIf

			EndIf
			//
			
			dbSelectArea("SE2")
			dbSetOrder(6) // SE20106 E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO
			IF DbSeek( (cAliasTop)->E5FILIAL + (cAliasTop)->E5_CLIFOR + (cAliasTop)->E5_LOJA + (cAliasTop)->E5_PREFIXO + (cAliasTop)->E5_NUMERO + (cAliasTop)->E5_PARCELA + (cAliasTop)->E5_TIPO )

				dDatBaixa := SE2->E2_BAIXA
				dDataEmis := SE2->E2_EMIS1
				
				// Chamado n. 052807 || OS 054158 || FINANCAS || DRIELE || 8376 || REL. FLUXO - FWNM - 04/11/2019
				dVencto  := SE2->E2_VENCTO
				dVencrea := SE2->E2_VENCREA
				//

			Else
				// Chamado n. 051865 || OS 053202 || FINANCAS || DRIELE || 8376 || RELATORIO DE FLUXO - fwnm - 17/09/2019
				SE1->( dbSetOrder(1) ) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				If SE1->( dbSeek( (cAliasTop)->(E5FILIAL + E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO) ) )

					dDatBaixa := SE1->E1_BAIXA
					dDataEmis := SE1->E1_EMIS1

					// Chamado n. 052807 || OS 054158 || FINANCAS || DRIELE || 8376 || REL. FLUXO - FWNM - 04/11/2019
					dVencto  := SE1->E1_VENCTO
					dVencrea := SE1->E1_VENCREA
					//

				EndIf

			EndIf
			
			// Chamado n. 052807 || OS 054158 || FINANCAS || DRIELE || 8376 || REL. FLUXO - FWNM - 04/11/2019
			// Movimentos bancarios
			If Empty(dVencto)
				dVencto := (cAliasTop)->E5_DTDISPO
			EndIf
			
			If Empty(dVencrea)
				dVencrea := (cAliasTop)->E5_DTDISPO
			EndIf
			//
			
			// Chamado n. TI | faturas não estão puxando o produto predominante, e se eu classifico pela natureza, também não esta puxando o agrupador - FWNM - 16/10/2019
			IF AllTrim((cAliasTop)->E5_TIPO) = 'FT'
				
				BeginSql Alias 'TMPFAT'
					
					Column E2_VENCREA as Date
					Column E2_EMIS1   as Date
					
					SELECT COUNT(E2_VENCREA) NUM_TITULO, E2_VENCREA, E2_EMIS1
					FROM %table:SE2% E2 (NOLOCK)
					WHERE E2_FATURA = %EXP:(cAliasTop)->E5_NUMERO% AND E2_FILIAL = %EXP:(cAliasTop)->E5FILIAL%
					// @history ticket   11767 - Fernando Maciei - 31/03/2021 - Classificação Agrupador - O relatório está com erro quando o tipo de título (E2_TIPO = FT) - A fatura 242320 está agrupando como Milho, porém deveria agrupar como FARELO DE SOJA, visto que o agrupador do produto predominante é FARELO
					AND E2_FORNECE=%EXP:(cAliasTop)->E5_CLIFOR%
					AND E2_LOJA=%EXP:(cAliasTop)->E5_LOJA%
					//
					AND E2.%NotDel%
					GROUP BY E2_VENCREA, E2_EMIS1
					ORDER BY COUNT(E2_VENCREA) DESC
					
				EndSql
				
				IF !Empty(TMPFAT->E2_VENCREA)
					dDatBaixa := TMPFAT->E2_VENCREA
					dDataEmis := TMPFAT->E2_EMIS1
				Else
					dDatBaixa := ""
					dDataEmis := ""
				EndIf
				
				DbSelectArea('TMPFAT')
				DbCloseArea()
				
			Endif
			
			dDatBaixa := IIF( !EMPTY(dDatBaixa) , dDatBaixa , (cAliasTop)->E5_DATA )
			dDataEmis := IIF( !EMPTY(dDataEmis) , dDataEmis , (cAliasTop)->E5_DTDIGIT )
			
			oSection:Cell("E5_FILIAL") :SetValue( (cAliasTop)->E5FILIAL )
			oSection:Cell("E5_PREFIXO"):SetValue( (cAliasTop)->E5_PREFIXO )
			oSection:Cell("E5_NUMERO") :SetValue( (cAliasTop)->E5_NUMERO )
			oSection:Cell("E5_PARCELA"):SetValue( (cAliasTop)->E5_PARCELA )
			oSection:Cell("E5_TIPO")   :SetValue( (cAliasTop)->E5_TIPO )
			oSection:Cell("E5_CLIFOR") :SetValue( (cAliasTop)->E5_CLIFOR )
			oSection:Cell("E5_LOJA")   :SetValue( (cAliasTop)->E5_LOJA )
			oSection:Cell("E5_BENEF")  :SetValue( (cAliasTop)->E5_BENEF )
			oSection:Cell("E5_NATUREZ"):SetValue( (cAliasTop)->E5_NATUREZ )
			oSection:Cell("E5_DATA")   :SetValue( dDatBaixa )
			oSection:Cell("E5_VENCTO") :SetValue( dVencto )
			oSection:Cell("E2_VENCREA"):SetValue( dVencrea )

			// Chamado n. 055337 || OS 056759 || FINANCAS || DRIELE || 8376 || FLUXO DE CAIXAS - FWNM - 03/02/2020 - Somente contas receber em aberto
			dDtDispo := (cAliasTop)->E5_DTDISPO
			If (cAliasTop)->TABELA == "SE1" 
				If !Empty((cAliasTop)->E5_BANCO)
					dDtDispo := ChkDtFloat(dVencrea)
				Else
					dDtDispo := dVencrea
				EndIf
			EndIf
			//

			oSection:Cell("E5_DTDISPO"):SetValue( dDtDispo )
			
			//oSection:Cell("E5_VALOR")  :SetValue( (cAliasTop)->E5_VALOR * (-1)) //08/04/2019 - William Costa - 048344 || OS 049616 || FINANCAS || DRIELE || 8376 || REL. FLUXO CAIXA
			// Chamado n. 051865 || OS 053202 || FINANCAS || DRIELE || 8376 || RELATORIO DE FLUXO - fwnm - 17/09/2019
			nValor := (cAliasTop)->E5_VALOR    
			If (cAliasTop)->E5_RECPAG == "P"       
				nValor := (cAliasTop)->E5_VALOR * (-1)
			EndIf
			oSection:Cell("E5_VALOR")  :SetValue( nValor ) 
			//
			
			oSection:Cell("E5_DTDIGIT"):SetValue( dDataEmis )
			oSection:Cell("E5_SEQ")    :SetValue( (cAliasTop)->E5_SEQ )

			cDescNat := Posicione( "SED" , 1 , xFilial("SED") + (cAliasTop)->E5_NATUREZ , "ED_DESCRIC")
			oSection:Cell("DESCNAT")   :SetValue( cDescNat )

			oSection:Cell("E5_BANCO")  :SetValue( (cAliasTop)->E5_BANCO )
			oSection:Cell("E5_AGENCIA"):SetValue( (cAliasTop)->E5_AGENCIA )
			oSection:Cell("E5_CONTA")  :SetValue( (cAliasTop)->E5_CONTA )
			
			nDWeek := DOW( dDatBaixa )
			
			if nDWeek = 2 // Segunda-Feira
				
				if dDataEmis <= ( dDatBaixa - 4 )
					
					cStatus   := "Previsto"
					
				Else
					
					cStatus   := "Imprevisto"
					
				Endif
				
			Elseif nDWeek = 3 // Terca-Feira
				
				if dDataEmis <= ( dDatBaixa - 5 )
					
					cStatus   := "Previsto"
					
				Else
					
					cStatus   := "Imprevisto"
					
				Endif
				
			Elseif nDWeek = 4 // Quarta-Feira
				
				if dDataEmis <= ( dDatBaixa - 6 )
					
					cStatus   := "Previsto"
					
				Else
					
					cStatus   := "Imprevisto"
					
				Endif
				
			Elseif nDWeek = 5  // Quinta-Feira
				
				if dDataEmis <= ( dDatBaixa - 7 )
					
					cStatus   := "Previsto"
					
				Else
					
					cStatus   := "Imprevisto"
					
				Endif
				
			Elseif nDWeek = 6  // Sexta-Feira
				
				if dDataEmis <= ( dDatBaixa - 8 )
					
					cStatus   := "Previsto"
					
				Else
					
					cStatus   := "Imprevisto"
					
				Endif
				
			Endif
			
			oSection:Cell("STATUS"):SetValue( cStatus )
			
			// Chamado n. TI | faturas não estão puxando o produto predominante, e se eu classifico pela natureza, também não esta puxando o agrupador - FWNM - 16/10/2019
			IF AllTrim((cAliasTop)->E5_TIPO) = 'FT'
				
				BeginSql Alias 'TMPFAT'
					
					SELECT *
					FROM %table:SE2% E2 (NOLOCK)
					WHERE E2_FATURA = %EXP:(cAliasTop)->E5_NUMERO% AND E2_FILIAL = %EXP:(cAliasTop)->E5FILIAL%
					// @history ticket   11767 - Fernando Maciei - 31/03/2021 - Classificação Agrupador - O relatório está com erro quando o tipo de título (E2_TIPO = FT) - A fatura 242320 está agrupando como Milho, porém deveria agrupar como FARELO DE SOJA, visto que o agrupador do produto predominante é FARELO
					AND E2_FORNECE=%EXP:(cAliasTop)->E5_CLIFOR%
					AND E2_LOJA=%EXP:(cAliasTop)->E5_LOJA%
					//
					AND E2.%NotDel%
					
				EndSql
				
				While !TMPFAT->(Eof())
					
					BeginSql Alias 'TMPB1'
						
						SELECT B1_COD, B1_DESC, D1_EMISSAO, D1_TOTAL
						FROM %table:SD1% D1 (NOLOCK)
						INNER JOIN %table:SB1% TB1 ON B1_COD=D1_COD AND TB1.%NotDel%
						WHERE D1_DOC = %EXP:TMPFAT->E2_NUM% AND D1_SERIE = %EXP:TMPFAT->E2_PREFIXO%
						AND D1_FORNECE = %EXP:TMPFAT->E2_FORNECE% AND D1_LOJA = %EXP:TMPFAT->E2_LOJA%
						AND D1_FILIAL = %EXP:TMPFAT->E2_FILIAL% AND D1.%NotDel%
						ORDER BY D1_TOTAL DESC
						
					EndSql
					
					if TMPB1->D1_TOTAL > nVlrMrnf
						CodPrdMv := TMPB1->B1_COD
						cPrdMvlr := TMPB1->B1_DESC
						dDtEmiss := TMPB1->D1_EMISSAO
					Endif
					
					DbSelectArea('TMPB1')
					DbCloseArea()
					
					DbSelectArea('TMPFAT')
					DbSkip()
					
				EndDO
				
				DbSelectArea('TMPFAT')
				DbCloseArea()
				
				// Chamado n. TI | faturas não estão puxando o produto predominante, e se eu classifico pela natureza, também não esta puxando o agrupador - FWNM - 16/10/2019 
				/*
				If Empty(CodPrdMv)
					SED->( dbSetOrder(1) ) //ED_FILIAL+ED_CODIGO
					If SED->( dbSeek( FWxFilial("SED")+(cAliasTop)->E5_NATUREZ ) )
						CodPrdMv := SED->ED_XGRPFIN
						cPrdMvlr := Posicione("ZFH",1, FWxFilial("ZFH") + CodPrdMv, "ZFH_DESCRI")
					EndIf
				EndIf
			
				If Empty(CodPrdMv)
					CodPrdMv := AllTrim(SED->ED_CODIGO)
					cPrdMvlr := "[ED_XGRPFIN] VAZIO - " + AllTrim(SED->ED_DESCRIC)
				EndIf
				*/
				
			Else
				
				BeginSql Alias cAliaTop2
					
					SELECT B1_COD, B1_DESC, D1_EMISSAO, D1_TOTAL
					FROM %table:SD1% D1 (NOLOCK)
					INNER JOIN %table:SB1% B1 ON B1_COD=D1_COD AND B1.%NotDel%
					WHERE D1_DOC = %EXP:(cAliasTop)->E5_NUMERO% AND D1_SERIE = %EXP:(cAliasTop)->E5_PREFIXO%
					AND D1_FORNECE = %EXP:(cAliasTop)->E5_CLIFOR% AND D1_LOJA = %EXP:(cAliasTop)->E5_LOJA%
					AND D1_FILIAL = %EXP:(cAliasTop)->E5FILIAL% AND D1.%NotDel%
					ORDER BY D1_TOTAL DESC
					
				EndSql
				
				CodPrdMv := IIF(ALLTRIM((cAliaTop2)->B1_COD) <> '',(cAliaTop2)->B1_COD,Posicione( "SED" , 1 , xFilial("SED") + (cAliasTop)->E5_NATUREZ , "ED_DESCRIC")) //08/04/2019 - William Costa - 048344 || OS 049616 || FINANCAS || DRIELE || 8376 || REL. FLUXO CAIXA
				cPrdMvlr := IIF(ALLTRIM((cAliaTop2)->B1_DESC) <> '',(cAliaTop2)->B1_DESC,Posicione( "SED" , 1 , xFilial("SED") + (cAliasTop)->E5_NATUREZ , "ED_DESCRIC")) //08/04/2019 - William Costa - 048344 || OS 049616 || FINANCAS || DRIELE || 8376 || REL. FLUXO CAIXA
				dDtEmiss := (cAliaTop2)->D1_EMISSAO
				
				DbSelectArea(cAliaTop2)
				DbCloseArea()
				
			EndIf
			
			If Len(aTotalPr) > 0
				
				For a:=1 to len(aTotalPr)
					if aTotalPr[a][1] = CodPrdMv
						aTotalPr[a][3] += (cAliasTop)->E5_VALOR
						lAtuArr := .F.
					Endif
				Next
				
				If lAtuArr
					IF !EMPTY(Alltrim(CodPrdMv))
						aAdd( aTotalPr , { CodPrdMv , cPrdMvlr , (cAliasTop)->E5_VALOR } )
					Endif
				Endif
				
			Else
				
				IF !EMPTY(Alltrim(CodPrdMv))
					aAdd( aTotalPr , { CodPrdMv , cPrdMvlr , (cAliasTop)->E5_VALOR } )
				Endif
				
			Endif
			
			// Chamado n. TI | faturas não estão puxando o produto predominante, e se eu classifico pela natureza, também não esta puxando o agrupador - FWNM - 16/10/2019 
			//If Empty(CodPrdMv)
			If Empty(CodPrdMv) .or. AllTrim((cAliasTop)->E5_TIPO) == "TX" .or. AllTrim((cAliasTop)->E5_PREFIXO) == "ST" // Chamado n. 055114 || OS 056520 || FINANCAS || DRIELE || 8376 || FLUXO DE CAIXA - FWNM - 30/01/2020
				SED->( dbSetOrder(1) ) //ED_FILIAL+ED_CODIGO
				If SED->( dbSeek( FWxFilial("SED")+(cAliasTop)->E5_NATUREZ ) )
					CodPrdMv := SED->ED_XGRPFIN
					cPrdMvlr := Posicione("ZFH",1, FWxFilial("ZFH") + CodPrdMv, "ZFH_DESCRI")
				EndIf
			EndIf
			//
			
			If Empty(CodPrdMv)
				CodPrdMv := AllTrim(SED->ED_CODIGO)
				cPrdMvlr := "[ED_XGRPFIN] VAZIO - " + AllTrim(SED->ED_DESCRIC)
			EndIf
			
			// Chamado n. 052807 || OS 054158 || FINANCAS || DRIELE || 8376 || REL. FLUXO - FWNM - 04/11/2019
			If Empty(CodPrdMv)
				CodPrdMv := AllTrim((cAliasTop)->E5_NATUREZ)
				cPrdMvlr := "[ED_XGRPFIN] VAZIO - " + AllTrim(Posicione("SED",1,FWxFilial("SED")+(cAliasTop)->E5_NATUREZ,"ED_DESCRIC"))
			EndIf
			//
			
			//oSection:Cell("PRODUTO"):SetValue( cPrdMvlr )
			//oSection:Cell("CODPROD"):SetValue( CodPrdMv )
			
			//Everson - 29/04/2019. Chamado 048577.
			cGrpPrd := Posicione("SB1",1, FWxFilial("SB1") + CodPrdMv, "B1_XGRPFIN" )
			cDscGrp := Posicione("ZFH",1, FWxFilial("ZFH") + cGrpPrd, "ZFH_DESCRI")
			
			// Chamado n. 051865 || OS 053202 || FINANCAS || DRIELE || 8376 || RELATORIO DE FLUXO - fwnm - 17/09/2019
			If Empty(cGrpPrd)
				cGrpPrd := AllTrim(SB1->B1_COD)
				cDscGrp := "[B1_XGRPFIN] VAZIO - " + AllTrim(SB1->B1_DESC)
			EndIf

			cCNPJ    := ""
			cRazao   := ""
			lSE1     := .t.
			lSE2     := .t.
            
			// Contas a Receber
			SE1->( dbSetOrder(1) ) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			If SE1->( dbSeek( (cAliasTop)->E5FILIAL+PadR((cAliasTop)->E5_PREFIXO,TamSX3("E1_PREFIXO")[1])+PadR((cAliasTop)->E5_NUMERO,TamSX3("E1_NUM")[1])+PadR((cAliasTop)->E5_PARCELA,TamSX3("E1_PARCELA")[1])+(cAliasTop)->E5_TIPO) )
				SA1->( dbSetOrder(1) ) // A1_FILIAL+A1_COD+A1_LOJA                                                                                                                                        
				If SA1->( dbSeek( FWxFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA ) )
					
					If Empty(cGrpPrd) // @history ticket   14822 - Fernando Maciei - 10/06/2021 - Despesa classificada errada
						cGrpPrd := AllTrim(SA1->A1_TIPO)
						If AllTrim(SA1->A1_TIPO) == "X"
							cDscGrp := "MERCADO EXTERNO"
						Else
							cDscGrp := "MERCADO INTERNO"
						EndIf               
					EndIf

					cTipDes := "OPERACIONAL"
				
					cCNPJ  := Left(AllTrim(SA1->A1_CGC),8)
					cRazao := Posicione("SA1",3,FWxFilial("SA1")+cCNPJ,"A1_NOME") // Chamado n. 052807 || OS 054158 || FINANCAS || DRIELE || 8376 || REL. FLUXO - FWNM - 04/11/2019
					
				EndIf               
				
				// Chamado n. 052807 || OS 054158 || FINANCAS || DRIELE || 8376 || REL. FLUXO - FWNM - 04/11/2019
				// Código de Projeto - (Regra se conter a informação de código de projeto alocar como Investimentos/ preenchendo produto.)
				If Select("WorkPRJ") > 0
					WorkPRJ->( dbCloseArea() )
				EndIf 
				
				cQuery := " SELECT TOP 1 D2_COD, D2_XPROJET, D2_TOTAL"
				cQuery += " FROM " + RetSqlName("SD2") + " SD2 (NOLOCK) "
				cQuery += " WHERE D2_FILIAL='"+(cAliasTop)->E5FILIAL+"' "
				cQuery += " AND D2_DOC='"+(cAliasTop)->E5_NUMERO+"' "
				cQuery += " AND D2_SERIE='"+(cAliasTop)->E5_PREFIXO+"' "
				cQuery += " AND D2_CLIENTE='"+(cAliasTop)->E5_CLIFOR+"' "
				cQuery += " AND D2_LOJA='"+(cAliasTop)->E5_LOJA+"' "
				cQuery += " AND D2_XPROJET<>'' "
				cQuery += " AND D_E_L_E_T_='' "
				cQuery += " ORDER BY 3 DESC "
				
				tcQuery cQuery New Alias "WorkPRJ"
				
				WorkPRJ->( dbGoTop() )
				
				If WorkPRJ->( !EOF() )
					cGrpPrd := GetMV("MV_#BIGRFP",,"025") // Investimentos
					cDscGrp := Posicione("ZFH",1, FWxFilial("ZFH") + cGrpPrd, "ZFH_DESCRI")

					CodPrdMv := AllTrim(WorkPRJ->D2_COD)
					cPrdMvlr := Left(AllTrim(Posicione("AF8",1,FWxFilial("AF8")+WorkPRJ->D2_XPROJET,"AF8_DESCRI")),30) // Chamado n. 055114 || OS 056520 || FINANCAS || DRIELE || 8376 || FLUXO DE CAIXA - FWNM - 27/01/2020
					//cPrdMvlr := WorkPRJ->D2_XPROJET + " - " + AllTrim(Posicione("SB1",1,FWxFilial("SB1")+WorkPRJ->D2_COD,"B1_DESC"))
				EndIf
				
				If Select("WorkPRJ") > 0
					WorkPRJ->( dbCloseArea() )
				EndIf 
				//
				
			Else
				lSE1 := .f.
			EndIf               
				
			// Contas a Pagar
			SE2->( dbSetOrder(1) ) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
			If SE2->( dbSeek( (cAliasTop)->E5FILIAL+PadR((cAliasTop)->E5_PREFIXO,TamSX3("E2_PREFIXO")[1])+PadR((cAliasTop)->E5_NUMERO,TamSX3("E2_NUM")[1])+PadR((cAliasTop)->E5_PARCELA,TamSX3("E2_PARCELA")[1])+PadR((cAliasTop)->E5_TIPO,TamSX3("E2_TIPO")[1])+PadR((cAliasTop)->E5_CLIFOR,TamSX3("E2_FORNECE")[1])+PadR((cAliasTop)->E5_LOJA,TamSX3("E2_LOJA")[1]) ) )
				SA2->( dbSetOrder(1) ) // A2_FILIAL+A2_COD+A2_LOJA                                                                                                                                        
				If SA2->( dbSeek( FWxFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA ) )
					cCNPJ  := Left(AllTrim(SA2->A2_CGC),8)
					cRazao := Posicione("SA2",3,FWxFilial("SA2")+cCNPJ,"A2_NOME") // Chamado n. 052807 || OS 054158 || FINANCAS || DRIELE || 8376 || REL. FLUXO - FWNM - 04/11/2019
					//cRazao := AllTrim(SA2->A2_NOME)
				EndIf
				
				// Chamado n. 052807 || OS 054158 || FINANCAS || DRIELE || 8376 || REL. FLUXO - FWNM - 04/11/2019
				// Código de Projeto - (Regra se conter a informação de código de projeto alocar como Investimentos/ preenchendo produto.)
				If Select("WorkPRJ") > 0
					WorkPRJ->( dbCloseArea() )
				EndIf 
				
				cQuery := " SELECT TOP 1 D1_COD, D1_PROJETO, D1_TOTAL"
				cQuery += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) "
				cQuery += " WHERE D1_FILIAL='"+(cAliasTop)->E5FILIAL+"' "
				cQuery += " AND D1_DOC='"+(cAliasTop)->E5_NUMERO+"' "
				cQuery += " AND D1_SERIE='"+(cAliasTop)->E5_PREFIXO+"' "
				cQuery += " AND D1_FORNECE='"+(cAliasTop)->E5_CLIFOR+"' "
				cQuery += " AND D1_LOJA='"+(cAliasTop)->E5_LOJA+"' "
				cQuery += " AND D1_PROJETO<>'' "
				cQuery += " AND D_E_L_E_T_='' "
				cQuery += " ORDER BY 3 DESC"
				
				tcQuery cQuery New Alias "WorkPRJ"
				
				WorkPRJ->( dbGoTop() )
				
				If WorkPRJ->( !EOF() )
					cGrpPrd := GetMV("MV_#BIGRFP",,"025") // Investimentos
					cDscGrp := Posicione("ZFH",1, FWxFilial("ZFH") + cGrpPrd, "ZFH_DESCRI")

					CodPrdMv := AllTrim(WorkPRJ->D1_COD)
					cPrdMvlr := Left(AllTrim(Posicione("AF8",1,FWxFilial("AF8")+WorkPRJ->D1_PROJETO,"AF8_DESCRI")),30) // Chamado n. 055114 || OS 056520 || FINANCAS || DRIELE || 8376 || FLUXO DE CAIXA - FWNM - 27/01/2020
					//cPrdMvlr := WorkPRJ->D1_PROJETO + " - " + AllTrim(Posicione("SB1",1,FWxFilial("SB1")+WorkPRJ->D1_COD,"B1_DESC"))
				EndIf
				
				If Select("WorkPRJ") > 0
					WorkPRJ->( dbCloseArea() )
				EndIf 
				//

			Else
				lSE2 := .f.
			EndIf                                                 
			//
			
			// Natureza financeira do movimento bancario
			If !lSE1 .and. !lSE2
				SED->( dbSetOrder(1) ) //ED_FILIAL+ED_CODIGO
				If SED->( dbSeek( FWxFilial("SED")+(cAliasTop)->NATUREZA_FIN ) )
					cGrpPrd := SED->ED_XGRPFIN
					cDscGrp := Posicione("ZFH",1, FWxFilial("ZFH") + cGrpPrd, "ZFH_DESCRI")
				EndIf
			EndIf
			
			// Tratativa para títulos manuais sem nota fiscal para olhar o produto 
			If Empty(cGrpPrd)
				SED->( dbSetOrder(1) ) //ED_FILIAL+ED_CODIGO
				If SED->( dbSeek( FWxFilial("SED")+(cAliasTop)->E5_NATUREZ ) )
					cGrpPrd := SED->ED_XGRPFIN
					cDscGrp := Posicione("ZFH",1, FWxFilial("ZFH") + cGrpPrd, "ZFH_DESCRI")
				EndIf
			EndIf
			
			// Chamado n. 051865 || OS 053202 || FINANCAS || DRIELE || 8376 || RELATORIO DE FLUXO - fwnm - 25/09/2019
			//If Empty(cDscGrp)
			If Empty(cGrpPrd)
				cGrpPrd := AllTrim(SED->ED_CODIGO)
				cDscGrp := "[ED_XGRPFIN] VAZIO - " + AllTrim(SED->ED_DESCRIC)
			EndIf           
			
			// Adiantamentos - Trazer o produto do pedido na PA. (NOVOS)
			If AllTrim((cAliasTop)->E5_TIPO) == "PA"

				lAchou := .f.
				If Select("WorkPA") > 0
					WorkPA->( dbCloseArea() )
				EndIf 
				                                    
				cQuery := " SELECT TOP 1 ZFQ_PRODUT, ZFQ_TOTAL "
				cQuery += " FROM " + RetSqlName("ZFQ") + " ZFQ (NOLOCK) "
				cQuery += " INNER JOIN " + RetSqlName("SE2") + " SE2 (NOLOCK) ON E2_FILIAL=ZFQ_FILIAL AND E2_PREFIXO=ZFQ_PREFIX AND E2_NUM=ZFQ_NUM AND E2_PARCELA=ZFQ_PARCEL AND E2_TIPO=ZFQ_TIPO AND E2_FORNECE=ZFQ_FORNEC AND E2_LOJA=ZFQ_LOJA AND SE2.D_E_L_E_T_='' "
				cQuery += " WHERE ZFQ_FILIAL='"+(cAliasTop)->E5FILIAL+"' " 
				cQuery += " AND ZFQ_PREFIX='"+(cAliasTop)->E5_PREFIXO+"' " 
				cQuery += " AND ZFQ_NUM='"+(cAliasTop)->E5_NUMERO+"' " 
				cQuery += " AND ZFQ_PARCEL='"+(cAliasTop)->E5_PARCELA+"' " 
				cQuery += " AND ZFQ_TIPO='"+(cAliasTop)->E5_TIPO+"' " 
				cQuery += " AND ZFQ_FORNEC='"+(cAliasTop)->E5_CLIFOR+"' " 
				cQuery += " AND ZFQ_LOJA='"+(cAliasTop)->E5_LOJA+"' " 
				cQuery += " AND ZFQ.D_E_L_E_T_='' "
				cQuery += " ORDER BY 2 DESC"
				
				tcQuery cQuery New Alias "WorkPA"
				
				WorkPA->( dbGoTop() )
				
				If WorkPA->( !EOF() )
				
					lAchou := .t.

					CodPrdMv := AllTrim(WorkPA->ZFQ_PRODUT)
					cPrdMvlr := AllTrim(Posicione("SB1",1,FWxFilial("SB1")+WorkPA->ZFQ_PRODUT,"B1_DESC"))

					cGrpPrd := Posicione("SB1",1, FWxFilial("SB1") + CodPrdMv, "B1_XGRPFIN" )
					cDscGrp := Posicione("ZFH",1, FWxFilial("ZFH") + cGrpPrd, "ZFH_DESCRI")
					
					If Empty(cGrpPrd)
						cGrpPrd := AllTrim(SB1->B1_COD)
						cDscGrp := "[B1_XGRPFIN] VAZIO - " + AllTrim(SB1->B1_DESC)
					EndIf

				EndIf
				
				// Se nao achou na ZFQ procuro no SAG
				If !lAchou

					If Select("WorkPA") > 0
						WorkPA->( dbCloseArea() )
					EndIf 
				                                    
					// @history ticket   10451 - Fernando Maciei - 03/05/2021 - Adaptar FIN010 para SGFIN010 dentro do banco DADOSADV
					/*
					cQuery := " SELECT TOP 1 FIN010.E2_PRODUTO, FIN010.E2_TOTAL "
					cQuery += " FROM DBINTERFACE.DBO.FIN010 FIN010 (NOLOCK) "
					cQuery += " INNER JOIN " + RetSqlName("SE2") + " SE2 (NOLOCK) ON SE2.E2_FILIAL=FIN010.E2_FILIAL COLLATE Latin1_General_CI_AS AND SE2.E2_PREFIXO=FIN010.E2_PREFIXO COLLATE Latin1_General_CI_AS AND SE2.E2_NUM=FIN010.E2_NUM COLLATE Latin1_General_CI_AS AND SE2.E2_PARCELA=FIN010.E2_PARCELA COLLATE Latin1_General_CI_AS AND SE2.E2_TIPO=FIN010.E2_TIPO COLLATE Latin1_General_CI_AS AND SE2.E2_FORNECE=FIN010.E2_FORNECE COLLATE Latin1_General_CI_AS AND SE2.E2_LOJA=FIN010.E2_LOJA COLLATE Latin1_General_CI_AS AND SE2.D_E_L_E_T_='' COLLATE Latin1_General_CI_AS "
					cQuery += " WHERE FIN010.E2_FILIAL='"+(cAliasTop)->E5FILIAL+"' " 
					cQuery += " AND FIN010.E2_PREFIXO='"+(cAliasTop)->E5_PREFIXO+"' " 
					cQuery += " AND FIN010.E2_NUM='"+(cAliasTop)->E5_NUMERO+"' " 
					cQuery += " AND FIN010.E2_PARCELA='"+(cAliasTop)->E5_PARCELA+"' " 
					cQuery += " AND FIN010.E2_TIPO='"+(cAliasTop)->E5_TIPO+"' " 
					cQuery += " AND FIN010.E2_FORNECE='"+(cAliasTop)->E5_CLIFOR+"' " 
					cQuery += " AND FIN010.E2_LOJA='"+(cAliasTop)->E5_LOJA+"' " 
					cQuery += " ORDER BY 2 DESC "
					*/

					cQuery := " SELECT TOP 1 SGFIN010.E2_PRODUTO, SGFIN010.E2_TOTAL "
					cQuery += " FROM SGFIN010 SGFIN010 (NOLOCK) "
					cQuery += " INNER JOIN " + RetSqlName("SE2") + " SE2 (NOLOCK) ON SE2.E2_FILIAL=SGFIN010.E2_FILIAL COLLATE Latin1_General_CI_AS AND SE2.E2_PREFIXO=SGFIN010.E2_PREFIXO COLLATE Latin1_General_CI_AS AND SE2.E2_NUM=SGFIN010.E2_NUM COLLATE Latin1_General_CI_AS AND SE2.E2_PARCELA=SGFIN010.E2_PARCELA COLLATE Latin1_General_CI_AS AND SE2.E2_TIPO=SGFIN010.E2_TIPO COLLATE Latin1_General_CI_AS AND SE2.E2_FORNECE=SGFIN010.E2_FORNECE COLLATE Latin1_General_CI_AS AND SE2.E2_LOJA=SGFIN010.E2_LOJA COLLATE Latin1_General_CI_AS AND SE2.D_E_L_E_T_='' COLLATE Latin1_General_CI_AS "
					cQuery += " WHERE SGFIN010.E2_FILIAL='"+(cAliasTop)->E5FILIAL+"' " 
					cQuery += " AND SGFIN010.E2_PREFIXO='"+(cAliasTop)->E5_PREFIXO+"' " 
					cQuery += " AND SGFIN010.E2_NUM='"+(cAliasTop)->E5_NUMERO+"' " 
					cQuery += " AND SGFIN010.E2_PARCELA='"+(cAliasTop)->E5_PARCELA+"' " 
					cQuery += " AND SGFIN010.E2_TIPO='"+(cAliasTop)->E5_TIPO+"' " 
					cQuery += " AND SGFIN010.E2_FORNECE='"+(cAliasTop)->E5_CLIFOR+"' " 
					cQuery += " AND SGFIN010.E2_LOJA='"+(cAliasTop)->E5_LOJA+"' " 
					cQuery += " ORDER BY 2 DESC "

					tcQuery cQuery New Alias "WorkPA"

					WorkPA->( dbGoTop() )
					
					If WorkPA->( !EOF() )

						lAchou := .t.

						CodPrdMv := AllTrim(WorkPA->E2_PRODUTO)
						CodPrdMv := Left(CodPrdMV,At("-",CodPrdMV)-1)
						cPrdMvlr := AllTrim(Posicione("SB1",1,FWxFilial("SB1")+CodPrdMv,"B1_DESC"))
					
						cGrpPrd := Posicione("SB1",1, FWxFilial("SB1") + CodPrdMv, "B1_XGRPFIN" )
						cDscGrp := Posicione("ZFH",1, FWxFilial("ZFH") + cGrpPrd, "ZFH_DESCRI")
						
						If Empty(cGrpPrd)
							cGrpPrd := AllTrim(SB1->B1_COD)
							cDscGrp := "[B1_XGRPFIN] VAZIO - " + AllTrim(SB1->B1_DESC)
						EndIf
				
					EndIf
				
				EndIf
				
				// Se nao achou na ZFQ nem no SAG, busco as baixas
				If !lAchou

					If Select("WorkPA") > 0
						WorkPA->( dbCloseArea() )
					EndIf 
				                                    
					cQuery := " SELECT TOP 1 E5_DOCUMEN, E5_VALOR "
					cQuery += " FROM " + RetSqlName("SE5") + " SE5 (NOLOCK) "
					cQuery += " WHERE E5_FILIAL='"+(cAliasTop)->E5FILIAL+"' " 
					cQuery += " AND E5_PREFIXO='"+(cAliasTop)->E5_PREFIXO+"' " 
					cQuery += " AND E5_NUMERO='"+(cAliasTop)->E5_NUMERO+"' " 
					cQuery += " AND E5_PARCELA='"+(cAliasTop)->E5_PARCELA+"' " 
					cQuery += " AND E5_TIPO='"+(cAliasTop)->E5_TIPO+"' " 
					cQuery += " AND E5_CLIFOR='"+(cAliasTop)->E5_CLIFOR+"' " 
					cQuery += " AND E5_LOJA='"+(cAliasTop)->E5_LOJA+"' " 
					cQuery += " AND E5_TIPODOC<>'"+(cAliasTop)->E5_TIPO+"' " 
					cQuery += " AND SE5.D_E_L_E_T_='' "
					cQuery += " ORDER BY 2 DESC "
					
					tcQuery cQuery New Alias "WorkPA"

					WorkPA->( dbGoTop() )
					
					If WorkPA->( !EOF() )
					
						cDocument := AllTrim(WorkPA->E5_DOCUMENT)
						cSerie    := Left(cDocument,3) 
						cDoc      := Subs(cDocument,4,9)
						cFornece  := Subs(cDocument,19,6)
						cLoja     := Right(cDocument,2)

						If Select("WorkSD1") > 0
							WorkSD1->( dbCloseArea() )
						EndIf
						
						cQuery := " SELECT TOP 1 D1_COD, D1_TOTAL "
						cQuery += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) "
						cQuery += " WHERE D1_FILIAL='"+(cAliasTop)->E5FILIAL+"' "
						cQuery += " AND D1_SERIE='"+cSerie+"' "
						cQuery += " AND D1_DOC='"+cDoc+"' "
						cQuery += " AND D1_FORNECE='"+cFornece+"' "
						cQuery += " AND D1_LOJA='"+cLoja+"' "
						cQuery += " AND D_E_L_E_T_='' "
						cQuery += " ORDER BY 2 DESC "

						tcQuery cQuery New Alias "WorkSD1"
						
						WorkSD1->( dbGoTop() )
						
						If WorkSD1->( !EOF() )
							CodPrdMv := AllTrim(WorkSD1->D1_COD)
							cPrdMvlr := AllTrim(Posicione("SB1",1,FWxFilial("SB1")+WorkSD1->D1_COD,"B1_DESC"))

							cGrpPrd := Posicione("SB1",1, FWxFilial("SB1") + CodPrdMv, "B1_XGRPFIN" )
							cDscGrp := Posicione("ZFH",1, FWxFilial("ZFH") + cGrpPrd, "ZFH_DESCRI")
							
							If Empty(cGrpPrd)
								cGrpPrd := AllTrim(SB1->B1_COD)
								cDscGrp := "[B1_XGRPFIN] VAZIO - " + AllTrim(SB1->B1_DESC)
							EndIf

						EndIf
						
					EndIf
				
				EndIf
				
				If Select("WorkPA") > 0
					WorkPA->( dbCloseArea() )
				EndIf 

				If Select("WorkSD1") > 0
					WorkSD1->( dbCloseArea() )
				EndIf
				//
				
			EndIf
			//

			// Chamado n. 052807 || OS 054158 || FINANCAS || DRIELE || 8376 || REL. FLUXO - FWNM - 04/11/2019
			// Intercompany - Criar uma regra onde a classificação do agrupador puxe pelo beneficiário tudo o que for (ADORO S/A - CERES - RNX2 - SAFEGG)
			cInter := GetMV("MV_#BINTER",,"60037058#02090384#12097672#20052541") // Adoro#Ceres#RNX2#SafEgg
			If cCNPJ $ cInter
				
				cTipo   := ""
				cOrigem := ""
				
				// Contas a Receber
				SE1->( dbSetOrder(1) ) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				If SE1->( dbSeek( (cAliasTop)->E5FILIAL+PadR((cAliasTop)->E5_PREFIXO,TamSX3("E1_PREFIXO")[1])+PadR((cAliasTop)->E5_NUMERO,TamSX3("E1_NUM")[1])+PadR((cAliasTop)->E5_PARCELA,TamSX3("E1_PARCELA")[1])+(cAliasTop)->E5_TIPO) )
					cOrigem := AllTrim(SE1->E1_ORIGEM)
					cTipo   := AllTrim(SE1->E1_TIPO)
				EndIf
				
				// Contas a Pagar
				SE2->( dbSetOrder(1) ) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
				If SE2->( dbSeek( (cAliasTop)->E5FILIAL+PadR((cAliasTop)->E5_PREFIXO,TamSX3("E2_PREFIXO")[1])+PadR((cAliasTop)->E5_NUMERO,TamSX3("E2_NUM")[1])+PadR((cAliasTop)->E5_PARCELA,TamSX3("E2_PARCELA")[1])+PadR((cAliasTop)->E5_TIPO,TamSX3("E2_TIPO")[1])+PadR((cAliasTop)->E5_CLIFOR,TamSX3("E2_FORNECE")[1])+PadR((cAliasTop)->E5_LOJA,TamSX3("E2_LOJA")[1]) ) )
					cOrigem := AllTrim(SE2->E2_ORIGEM)
					cTipo   := AllTrim(SE2->E2_TIPO)
				EndIf
				
				//@history ticket   62700 - Leonardo P. Monteiro - 03/11/2021 - Correção da condição de classificação dos títulos como Intercompany. Adicionada a exceção quando os títulos forem do tipo "FOL".
				If Left(cOrigem,3) <> "GPE" .AND. cTipo != "FOL"
				 	If cTipo <> "NDI"
						cGrpPrd := GetMV("MV_#BIGRFI",,"022") // Intercompany
						cDscGrp := Posicione("ZFH",1, FWxFilial("ZFH") + cGrpPrd, "ZFH_DESCRI")
					EndIf
				EndIf

				// Chamado n. 055114 || OS 056520 || FINANCAS || DRIELE || 8376 || FLUXO DE CAIXA - FWNM - 27/01/2020
				If !Empty((cAliasTop)->E5_NUMCHEQ)
					cGrpPrd := GetMV("MV_#BIGRFC",,"019") // CH
					cDscGrp := Posicione("ZFH",1, FWxFilial("ZFH") + cGrpPrd, "ZFH_DESCRI")
				EndIf
				//

				// Chamado n. 055114 || OS 056520 || FINANCAS || DRIELE || 8376 || FLUXO DE CAIXA - FWNM - 30/01/2020
				If AllTrim((cAliasTop)->E5_TIPO) == "TX" .or. AllTrim((cAliasTop)->E5_PREFIXO) == "ST"
					cGrpPrd := GetMV("MV_#BIGRFT",,"014") // Intercompany
					cDscGrp := Posicione("ZFH",1, FWxFilial("ZFH") + cGrpPrd, "ZFH_DESCRI")
				EndIf
				//
				
			EndIf

			// @history ticket   10451 - Fernando Maciei - 05/04/2021 - Agrupador Investimentos (código = 025) para fatura, Abrir Coluna com nome da Empresa (ADORO, CERES, RNX2, etc) e Acrescentar pergunta Finalidade do Relatório: (opções Previsão, Realizado, Análises), Incluir esta informação no relatório
			// Faturas - Aplicar a mesma regra existente para títulos individuais qdo possuir projeto de investimento (código = 025)
			If AllTrim((cAliasTop)->E5_TIPO) == "FT"

				If Select("WorkFTPRJ") > 0
					WorkFTPRJ->( dbCloseArea() )
				EndIf

				cQuery := " SELECT TOP 1 E2_FILIAL, E2_NUM, E2_PREFIXO, E2_FORNECE, E2_LOJA, D1_COD, D1_TOTAL, D1_PROJETO
				cQuery += " FROM " + RetSqlName("SE2") + " E2 (NOLOCK)
				cQuery += " INNER JOIN " + RetSqlName("SD1") + " D1 (NOLOCK) ON D1_FILIAL=E2_FILIAL AND D1_DOC=E2_NUM AND D1_SERIE=E2_PREFIXO AND D1_FORNECE=E2_FORNECE AND D1_LOJA=E2_LOJA AND D1_PROJETO<>'' AND D1.D_E_L_E_T_=''
				cQuery += " WHERE E2_FILIAL='"+(cAliasTop)->E5FILIAL+"' 
				cQuery += " AND E2_FATURA = '"+(cAliasTop)->E5_NUMERO+"' 
				cQuery += " AND E2_FORNECE='"+(cAliasTop)->E5_CLIFOR+"' 
				cQuery += " AND E2_LOJA='"+(cAliasTop)->E5_LOJA+"' 
				cQuery += " AND E2.D_E_L_E_T_=''
				cQuery += " ORDER BY 7 DESC

				tcQuery cQuery new Alias "WorkFTPRJ"

				WorkFTPRJ->( dbGoTop() )
				
				If WorkFTPRJ->( !EOF() )

					cGrpPrd := GetMV("MV_#BIGRFP",,"025") // Investimentos
					cDscGrp := Posicione("ZFH",1, FWxFilial("ZFH") + cGrpPrd, "ZFH_DESCRI")

					CodPrdMv := AllTrim(WorkFTPRJ->D1_COD)
					cPrdMvlr := Left(AllTrim(Posicione("AF8",1,FWxFilial("AF8")+WorkFTPRJ->D1_PROJETO,"AF8_DESCRI")),30)

				EndIf

				If Select("WorkFTPRJ") > 0
					WorkFTPRJ->( dbCloseArea() )
				EndIf

			EndIf
			//

			oSection:Cell("PRODUTO"):SetValue( cPrdMvlr )
			oSection:Cell("CODPROD"):SetValue( CodPrdMv )

			oSection:Cell("GRP_PRD"):SetValue( cGrpPrd )
			oSection:Cell("DSC_GRP"):SetValue( cDscGrp )
			//
			
			// Chamado n. 051865 || OS 053202 || FINANCAS || DRIELE || 8376 || RELATORIO DE FLUXO - fwnm - 17/09/2019
			/* LPM
			If AllTrim(cTipDes) <> "OPERACIONAL"
				aTipDes := RetSX3Box( Posicione('SX3', 2, 'ZFH_TIPO', 'X3CBox()' ),,, Len(ZFH->ZFH_TIPO) )
				For i:=1 to Len(aTipDes)
					If AllTrim(aTipDes[i,2]) == AllTrim(ZFH->ZFH_TIPO)
						cTipDes := Upper(aTipDes[i,3])
						cTipDes := AllTrim(StrTran(cTipDes,"CAIXA",""))
						Exit
					EndIf
				Next i
			EndIf
			oSection:Cell("TIP_DES"):SetValue( cTipDes )
			
			*/
			
			oSection:Cell("TIP_DES"):SetValue( alltrim((cAliasTop)->GRPFIN_DESC) )
			                                              
			// Chamado n. 051865 || OS 053202 || FINANCAS || DRIELE || 8376 || RELATORIO DE FLUXO - Power BI - Novas Regras - fwnm - 25/09/2019
			//cSemana := Subs(AllTrim(RetSem(dDatBaixa)),8,2)
			cSemana := Alltrim(cValToChar(RetSem((cAliasTop)->E5_DTDISPO))) //Everson - 23/07/2020. Chamado 059892.
			oSection:Cell("SEMANA"):SetValue( cSemana )
			
			//cMes := StrZero(Month(dDatBaixa),2)
			cMes := StrZero(Month((cAliasTop)->E5_DTDISPO),2)
			oSection:Cell("MES"):SetValue( cMes )
			//
			
			cEmpFil := UpEmpFil((cAliasTop)->E5FILIAL)
			oSection:Cell("EMPFIL"):SetValue( cEmpFil )
			
			oSection:Cell("E5_RECPAG"):SetValue( (cAliasTop)->E5_RECPAG )
			
			//cEntSai := UpEntSai( (cAliasTop)->E5FILIAL, (cAliasTop)->E5_PREFIXO, (cAliasTop)->E5_NUMERO, (cAliasTop)->E5_PARCELA, (cAliasTop)->E5_TIPO, (cAliasTop)->E5_CLIFOR, (cAliasTop)->E5_LOJA)
			//cEntSai := UpEntSai( (cAliasTop)->E5FILIAL, (cAliasTop)->E5_PREFIXO, (cAliasTop)->E5_NUMERO, (cAliasTop)->E5_PARCELA, (cAliasTop)->E5_TIPO, (cAliasTop)->E5_CLIFOR, (cAliasTop)->E5_LOJA, (cAliasTop)->GRPFIN_TIPO, nValor) // Chamado n. 055337 || OS 056759 || FINANCAS || DRIELE || 8376 || FLUXO DE CAIXAS - FWNM - 10/02/2020
			cEntSai := UpEntSai( (cAliasTop)->E5FILIAL, (cAliasTop)->E5_PREFIXO, (cAliasTop)->E5_NUMERO, (cAliasTop)->E5_PARCELA, (cAliasTop)->E5_TIPO, (cAliasTop)->E5_CLIFOR, (cAliasTop)->E5_LOJA, (cAliasTop)->GRPFIN_TIPO, nValor, (cAliasTop)->E5_TIPODOC, (cAliasTop)->E5_RECPAG, cGrpPrd) // @history ticket   68289 - Fernando Macieira    - 16/02/2022 - Criação de critério Relatório Fluxo de Caixa 
			oSection:Cell("ENTSAI"):SetValue( cEntSai )
			
			oSection:Cell("CNPJ"):SetValue( cCNPJ )
			oSection:Cell("RAZAO"):SetValue( cRazao )
			//

			If Empty(dDtEmiss)
				dDtEmiss := dDataEmis
				oSection:Cell("DTEMISSAO"):SetValue( DTOC(dDtEmiss) )
			Else
				oSection:Cell("DTEMISSAO"):SetValue( DTOC(STOD(dDtEmiss)) )
			EndIf

			//oSection:Cell("DTEMISSAO"):SetValue( DTOC(STOD(dDtEmiss)) )

			// Chamado n. 055337 || OS 056759 || FINANCAS || DRIELE || 8376 || FLUXO DE CAIXAS - FWNM - 02/03/2020
			cSemanaFat := Alltrim(cValToChar(RetSem(dDataEmis))) //Everson - 23/07/2020. Chamado 059892.
			oSection:Cell("SEMANAFAT"):SetValue( cSemanaFat )
			//

			// Chamado n. 056357 || OS 057787 || FINANCAS || DRIELE || 8376 || FLUXO DE CAIXA - FWNM - 17/03/2020
			
			/*
			•	Baixado – Vencto Real = a Data Dispo.
			•	Antecipado – Data Dispo. < Vencto Real 
			•	Atraso – Data Dispo. > Vencto Real
			*/
			
			cFluxoStatus := "XXXXXXXXXX"

			If MV_PAR15 == 1 //Visao Previsão (CAMPO FLUXOCAIXA_STATUS) - tudo que tinha vencimento num range de datas e que foi baixado na data, antecipado ou em atraso
			
				If (cAliasTop)->E5_VENCTO == (cAliasTop)->E5_DATA
					cFluxoStatus := "Baixado"

				ElseIf (cAliasTop)->E5_DATA < (cAliasTop)->E5_VENCTO
					cFluxoStatus := "Antecipado"

				ElseIf (cAliasTop)->E5_DATA > (cAliasTop)->E5_VENCTO
					cFluxoStatus := "Atraso"

				EndIf

			EndIf

			oSection:Cell("FLUXOSTATUS"):SetValue(cFluxoStatus)

			// @history ticket   11397 - Fernando Maciei - 23/03/2021 - Inclusão de Informações no relatório fluxo de caixa
			cPortado := (cAliasTop)->PORTADOR
			cNumBor  := (cAliasTop)->BORDERO
			dDtBor   := StoD((cAliasTop)->DTBORDERO)

			If Empty(cNumBor) .or. Empty(cPortado)

				SE2->( dbSetOrder(6) )// SE20106 E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO
				If SE2->( dbSeek( (cAliasTop)->E5FILIAL + (cAliasTop)->E5_CLIFOR + (cAliasTop)->E5_LOJA + (cAliasTop)->E5_PREFIXO + (cAliasTop)->E5_NUMERO + (cAliasTop)->E5_PARCELA + (cAliasTop)->E5_TIPO ) )
	
					If Empty(cNumBor)
						cNumBor := SE2->E2_NUMBOR
					EndIf

					If Empty(dDtBor)
						dDtBor := SE2->E2_DTBORDE
					EndIf

					If Empty(cPortado)
						cPortado := SE2->E2_PORTADO
					EndIf

				Else

					SE1->( dbSetOrder(1) ) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
					If SE1->( dbSeek( (cAliasTop)->(E5FILIAL + E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO) ) )

						If Empty(cNumBor)
							cNumBor := SE1->E1_NUMBOR
						EndIf

						If Empty(dDtBor)
							dDtBor := SE1->E1_DATABOR
						EndIf

						If Empty(cPortado)
							cPortado := SE1->E1_PORTADO
						EndIf
		
					EndIf

				EndIf

			EndIf

			// @history ticket   10451 - Fernando Maciei - 25/03/2021 - Visão Previsão, mudar para saldo > 0, tirar inner join se5, vencimento real (mudar!), checar com atenção aquele Where com E2_BANCO (qual o impacto), data do borderô (se branco, buscar a última na tabela SEA)
			If Empty(dDtBor)
				dDtBor := UpDtBor( (cAliasTop)->E5FILIAL, (cAliasTop)->E5_CLIFOR, (cAliasTop)->E5_LOJA, (cAliasTop)->E5_PREFIXO, (cAliasTop)->E5_NUMERO, (cAliasTop)->E5_PARCELA, (cAliasTop)->E5_TIPO, (cAliasTop)->E5_RECPAG )
			EndIf

			oSection:Cell("PORTADOR"):SetValue(cPortado)
			oSection:Cell("BORDERO"):SetValue(cNumBor)
			oSection:Cell("DTBORDERO"):SetValue(DtoC(dDtBor))
			//

			//@history ticket   11767 - Fernando Maciei - 31/03/2021 - Classificação Agrupador - O relatório está com erro quando o tipo de título (E2_TIPO = FT) - A fatura 242320 está agrupando como Milho, porém deveria agrupar como FARELO DE SOJA, visto que o agrupador do produto predominante é FARELO
			cNomEmp := ""
			SM0->( dbSetOrder(1) ) // M0_CODIGO + M0_CODFIL
			If SM0->( dbSeek(cEmpAnt) )
				cNomEmp := FwNoAccent(Upper(SM0->M0_NOME))
				cNomEmp := StrTran(cNomEmp,"'","")
			EndIf

			oSection:Cell("EMPRESA"):SetValue(cNomEmp)
			//

			//@history ticket 10451 - Fernando Maciei - 05/04/2021 - Agrupador Investimentos (código = 025) para fatura, Abrir Coluna com nome da Empresa (ADORO, CERES, RNX2, etc) e Acrescentar pergunta Finalidade do Relatório: (opções Previsão, Realizado, Análises), Incluir esta informação no relatório
			cFinalidade := ""
			
			If MV_PAR16 == 1
			
				cFinalidade := "PREVISAO"
			
			ElseIf MV_PAR16 == 2
			
				cFinalidade := "REALIZADO"

			ElseIf MV_PAR16 == 3
			
				cFinalidade := "ANALISES"

			EndIf
			
			oSection:Cell("FINALIDADE"):SetValue(cFinalidade)
			//

			// @history ticket   10451 - Fernando Maciei - 26/04/2021 - Relatório, Visão = Previsto - Trazer títulos tipo = PA somente quando NÃO tiver SE5 para o registro.
			// A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON, R_E_C_N_O_, D_E_L_E_T_
			cA6_CONTA := ""
			cA6_CONTA := Posicione("SA6",1,FWxFilial("SA6")+(cAliasTop)->E5_BANCO+(cAliasTop)->E5_AGENCIA+(cAliasTop)->E5_CONTA,"A6_CONTA")
			oSection:Cell("A6_CONTA"):SetValue(cA6_CONTA)
			//

			oSection:PrintLine()
			oBreak:SetTitle('Total')
			
			// Chamado n. 051865 || Power BI - Coluna RECPAG vazia - fwnm - 27/09/2019
			If MV_PAR14 == 1 // Integra Power BI
				lErroBI := .f.
				UpPowerBI( (cAliasTop)->E5FILIAL, (cAliasTop)->E5_NUMERO, (cAliasTop)->E5_PARCELA, (cAliasTop)->E5_TIPO, (cAliasTop)->E5_CLIFOR, (cAliasTop)->E5_LOJA, (cAliasTop)->E5_BENEF, (cAliasTop)->E5_NATUREZ, dDatBaixa, dVencto, dDtDispo /*(cAliasTop)->E5_DTDISPO*/, nValor, dDataEmis, (cAliasTop)->E5_SEQ, cDescNat, (cAliasTop)->E5_BANCO, (cAliasTop)->E5_AGENCIA, (cAliasTop)->E5_CONTA, cStatus, cPrdMvlr, CodPrdMv, cGrpPrd, cDscGrp, cTipDes, cSemana, cMes, cEmpFil, (cAliasTop)->E5_RECPAG, cEntSai, cCNPJ, cRazao, @lErroBI, dVencrea, cSemanaFat, cFluxoStatus )
				If lErroBI
					If msgYesNo("Deseja abortar processamento para mudar parâmetro de integração Power BI = 'Não' devido ao erro de integração e continuar sem integrar? ")
						Return
					EndIf
				EndIf
			EndIf
			//

			DbSelectArea(cAliasTop)
			DbSkip()

			oReport:IncMeter()

			cPrdMvlr := ""
			CodPrdMv := ""
			dDtEmiss := ""
			lAtuArr  := .T.

			// Chamado n. 051865 || Power BI - Coluna RECPAG vazia - fwnm - 27/09/2019
			/*
			If MV_PAR14 == 1 // Integra Power BI
				lErroBI := .f.
				UpPowerBI( (cAliasTop)->E5FILIAL, (cAliasTop)->E5_NUMERO, (cAliasTop)->E5_PARCELA, (cAliasTop)->E5_TIPO, (cAliasTop)->E5_CLIFOR, (cAliasTop)->E5_LOJA, (cAliasTop)->E5_BENEF, (cAliasTop)->E5_NATUREZ, dDatBaixa, (cAliasTop)->E5_VENCTO, (cAliasTop)->E5_DTDISPO, nValor, dDataEmis, (cAliasTop)->E5_SEQ, cDescNat, (cAliasTop)->E5_BANCO, (cAliasTop)->E5_AGENCIA, (cAliasTop)->E5_CONTA, cStatus, cPrdMvlr, CodPrdMv, cGrpPrd, cDscGrp, cTipDes, cSemana, cMes, cEmpFil, (cAliasTop)->E5_RECPAG, cEntSai, cCNPJ, cRazao, @lErroBI )
				If lErroBI
					If msgYesNo("Deseja abortar processamento para mudar parâmetro de integração Power BI = 'Não' devido ao erro de integração e continuar sem integrar? ")
						Return
					EndIf
				EndIf
			EndIf
			*/
			//

		EndDO
		
	Endif
	
	oSection:Finish()
	
	oSection2:Init()
	
	For p:=1 to Len(aTotalPr)
		
		oSection2:Cell("TOTALPRD1"):SetValue( aTotalPr[p][1] )
		oSection2:Cell("TOTALPRD2"):SetValue( aTotalPr[p][2] )
		oSection2:Cell("TOTALPRD3"):SetValue( Transform(aTotalPr[p][3] , PesqPict("SE5","E5_VALOR")) )
		oSection2:PrintLine()
		
	Next
	
	oSection2:Finish()
	
	DbSelectArea(cAliasTop)
	DbCloseArea()

Return

/*/{Protheus.doc} Static Function GETDSCGRP
	Retorna a descricao do grupo do produto
	@type  Function
	@author Everson
	@since 24/04/2019
	@version 01
	@history Chamado 048577 
/*/
Static Function getDscGrp(cChave)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local cDsc		:= ""
	Local cTab		:= "D_DESC"
	
	//
	BeginSql Alias cTab
		
		SELECT TOP 1 X5_DESCRI
		FROM %table:SX55% SX5
		WHERE
		X5_TABELA = %EXP:'_1'%
		AND X5_CHAVE = %EXP:cChave%
		AND SX5.%NotDel%
		
	EndSql
	
	//
	cDsc := Alltrim(cValToChar((cTab)->X5_DESCRI))
	(cTab)->(DbCloseArea())
	
	//
	RestArea(aArea)

Return cDsc

/*/{Protheus.doc} Static Function MONTAPERG
	Monta pergunta do relatorio
	@type  Function
	@author Ricardo Lima
	@since 19/12/2017
	@version 01
	@history Chamado  
/*/
Static Function MontaPerg()

	Private bValid := Nil
	Private cF3	   := Nil
	Private cSXG	 := Nil
	Private cPyme	 := Nil
	Private cPerg  := "ADFIN050R"
	
	xPutSx1(cPerg,'01','Dt Dispo De ?'    , 'Dt Dispo De ?'    , 'Dt Dispo De ?'    , 'mv_ch1','D',8,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR01')
	xPutSx1(cPerg,'02','Dt Dispo Ate?'    , 'Dt Dispo Ate?'    , 'Dt Dispo Ate?'    , 'mv_ch2','D',8,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR02')
	xPutSx1(cPerg,'03','Cli/For De  ?'    , 'Fornecedor De  ?' , 'Fornecedor De  ?' , 'mv_ch3','C',6,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR03')
	xPutSx1(cPerg,'04','Loja De  ?'       , 'Loja De  ?'       , 'Loja De  ?'       , 'mv_ch4','C',2,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR04')
	xPutSx1(cPerg,'05','Cli/For Ate ?'    , 'Fornecedor Ate ?' , 'Fornecedor Ate ?' , 'mv_ch5','C',6,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR05')
	xPutSx1(cPerg,'06','Loja Ate ?'       , 'Loja Ate ?'       , 'Loja Ate ?'       , 'mv_ch6','C',2,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR06')
	xPutSx1(cPerg,'07','Natureza De  ?'   , 'Natureza De  ?'   , 'Natureza De  ?'   , 'mv_ch7','C',9,0,0,'G',bValid,"SED",cSXG,cPyme,'MV_PAR07')
	xPutSx1(cPerg,'08','Natureza Ate ?'   , 'Natureza Ate ?'   , 'Natureza Ate ?'   , 'mv_ch8','C',9,0,0,'G',bValid,"SED",cSXG,cPyme,'MV_PAR08')
	xPutSx1(cPerg,'09','Filial De  ?'     , 'Filial De  ?'     , 'Filial De  ?'     , 'mv_ch9','C',2,0,0,'G',bValid,"SM0",cSXG,cPyme,'MV_PAR09')
	xPutSx1(cPerg,'10','Filial Ate ?'     , 'Filial Ate ?'     , 'Filial Ate ?'     , 'mv_cha','C',2,0,0,'G',bValid,"SM0",cSXG,cPyme,'MV_PAR10')
	xPutSx1(cPerg,'11','Tipo ?'           , 'Tipo ?'           , 'Tipo ?'           , 'mv_chb','C',1,0,0,'C',bValid,cF3  ,cSXG,cPyme,'MV_PAR11','Analitico','','','1','Sintetico','','')
	
	// Chamado n. 049691 - FWNM - 01/08/2019 |Listar tambem os pagamentos em abertos
	xPutSx1(cPerg,'12','Vencimento De ?'  , 'Vencimento De ?', 'Vencimento De ?'    , 'mv_chc','D',8,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR12')
	xPutSx1(cPerg,'13','Vencimento Ate?'  , 'Vencimento Ate?', 'Vencimento Ate?'    , 'mv_chd','D',8,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR13')

	// Chamado n. 051865 || OS 053202 || FINANCAS || DRIELE || 8376 || RELATORIO DE FLUXO - fwnm - 20/09/2019
	xPutSx1(cPerg,'14','Integra Power BI?', 'Integra Power BI?', 'Integra Power BI?', 'mv_che','C',1,0,0,'C',bValid,cF3  ,cSXG,cPyme,'MV_PAR14','Sim','','','','Não','','')

	// Chamado n. 051865 || OS 053202 || FINANCAS || DRIELE || 8376 || RELATORIO DE FLUXO - fwnm - 20/09/2019
	xPutSx1(cPerg,'15','Visão?'           , ''                 , ''                 , 'mv_chf','C',1,0,0,'C',bValid,cF3  ,cSXG,cPyme,'MV_PAR15','Previsao','','','','Realizado','','')

	//@history ticket   10451 - Fernando Maciei - 05/04/2021 - Agrupador Investimentos (código = 025) para fatura, Abrir Coluna com nome da Empresa (ADORO, CERES, RNX2, etc) e Acrescentar pergunta Finalidade do Relatório: (opções Previsão, Realizado, Análises), Incluir esta informação no relatório
	xPutSx1(cPerg,'16','Finalidade?'           , ''                 , ''                 , 'mv_chg','C',1,0,0,'C',bValid,cF3  ,cSXG,cPyme,'MV_PAR16','Previsao','','','','Realizado','','', 'Analises','','','')

Return

/*/{Protheus.doc} Static Function XPUTSX1
	Monta pergunta do relatorio
	@type  Function
	@author Ricardo Lima
	@since 19/12/2017
	@version 01
	@history Chamado  
/*/
Static Function xPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
cF3, cGrpSxg,cPyme,cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,;
cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)

	LOCAL aArea := GetArea()
	Local cKey
	Local lPort := .f.
	Local lSpa  := .f.
	Local lIngl := .f.
	
	cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."
	
	cPyme   := Iif( cPyme   == Nil, "" , cPyme   )
	cF3     := Iif( cF3     == NIl, "" , cF3     )
	cGrpSxg := Iif( cGrpSxg == Nil, "" , cGrpSxg )
	cCnt01  := Iif( cCnt01  == Nil, "" , cCnt01  )
	cHelp   := Iif( cHelp   == Nil, "" , cHelp   )
	
	dbSelectArea( "SX1" )
	dbSetOrder( 1 )
	
	// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes.
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )
	
	If !( DbSeek( cGrupo + cOrdem ))
		
		cPergunt := If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa := If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng := If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)
		
		Reclock( "SX1" , .T. )
		
		Replace X1_GRUPO   With cGrupo
		Replace X1_ORDEM   With cOrdem
		Replace X1_PERGUNT With cPergunt
		Replace X1_PERSPA  With cPerSpa
		Replace X1_PERENG  With cPerEng
		Replace X1_VARIAVL With cVar
		Replace X1_TIPO    With cTipo
		Replace X1_TAMANHO With nTamanho
		Replace X1_DECIMAL With nDecimal
		Replace X1_PRESEL  With nPresel
		Replace X1_GSC     With cGSC
		Replace X1_VALID   With cValid
		
		Replace X1_VAR01   With cVar01
		
		Replace X1_F3      With cF3
		Replace X1_GRPSXG  With cGrpSxg
		
		If Fieldpos("X1_PYME") > 0
			If cPyme != Nil
				Replace X1_PYME With cPyme
			Endif
		Endif
		
		Replace X1_CNT01   With cCnt01
		If cGSC == "C"               // Mult Escolha
			Replace X1_DEF01   With cDef01
			Replace X1_DEFSPA1 With cDefSpa1
			Replace X1_DEFENG1 With cDefEng1
			
			Replace X1_DEF02   With cDef02
			Replace X1_DEFSPA2 With cDefSpa2
			Replace X1_DEFENG2 With cDefEng2
			
			Replace X1_DEF03   With cDef03
			Replace X1_DEFSPA3 With cDefSpa3
			Replace X1_DEFENG3 With cDefEng3
			
			Replace X1_DEF04   With cDef04
			Replace X1_DEFSPA4 With cDefSpa4
			Replace X1_DEFENG4 With cDefEng4
			
			Replace X1_DEF05   With cDef05
			Replace X1_DEFSPA5 With cDefSpa5
			Replace X1_DEFENG5 With cDefEng5
		Endif
		
		Replace X1_HELP With cHelp
		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
		MsUnlock()
	Else
		
		lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
		lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA)
		lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG)
		
		If lPort .Or. lSpa .Or. lIngl
			RecLock("SX1",.F.)
			If lPort
				SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
			EndIf
			If lSpa
				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
			EndIf
			If lIngl
				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
			EndIf
			SX1->(MsUnLock())
		EndIf
	Endif
	
	RestArea( aArea )

Return

/*/{Protheus.doc} Static Function UPEMPFIL
	Classifica empresa e filial com siglas para Power BI
	@type  Function
	@author Fernando Macieira
	@since 17/09/2019
	@version 01
	@history Chamado 051865
/*/
Static Function UpEmpFil(cE5FILIAL)

	Local cClassFil := cE5FILIAL

	If AllTrim(cEmpAnt) == "01" // Adoro
		
		If AllTrim(cE5FILIAL) $ "01|02"   // Matriz | Varzea
			cClassFil := "VP"
		//Ticket 69574   - Abel Babini          - 25/04/2022 - Projeto FAI
		elseIf AllTrim(cE5FILIAL) $ "0B"   // Itapira
			cClassFil := "IT"
		Else
			cClassFil := "SC"
		EndIf
		
	ElseIf AllTrim(cEmpAnt) $ "02|03"
		cClassFil := "VP"
		
	ElseIf AllTrim(cEmpAnt) $ "07|09"
		cClassFil := "SC"
		
	EndIf

Return cClassFil

/*/{Protheus.doc} Static Function UPENTSAI
	Classifica tipo movimentacao financeira para Power BI
	@type  Function
	@author Fernando Macieira
	@since 17/09/2019
	@version 01
	@history Chamado 051865
/*/
//   cEntSai := UpEntSai( (cAliasTop)->E5FILIAL, (cAliasTop)->E5_PREFIXO, (cAliasTop)->E5_NUMERO, (cAliasTop)->E5_PARCELA, (cAliasTop)->E5_TIPO, (cAliasTop)->E5_CLIFOR, (cAliasTop)->E5_LOJA, (cAliasTop)->GRPFIN_TIPO, nValor, (cAliasTop)->E5_TIPODOC, (cAliasTop)->E5_RECPAG, cGrpPrd) // @history ticket   68289 - Fernando Macieira    - 16/02/2022 - Criação de critério Relatório Fluxo de Caixa 
Static Function UpEntSai( cE5_FILIAL, cE5_PREFIXO, cE5_NUMERO, cE5_PARCELA, cE5_TIPO, cE5_CLIFOR, cE5_LOJA, cGRPFIN_TIPO, nValor, cE5_TIPODOC, cE5_RECPAG, cGrpPrd )

	Local cEntSai    := "MOVIMENTO BANCARIO"
	Local aAreaSE1   := SE1->( GetArea() )
	Local aAreaSE2   := SE2->( GetArea() )

	// @history ticket   68310 - Fernando Macieira    - 16/02/2022 - Manutenção no relatório de Fluxo de Caixa
	Local cCodGrpPrd := GetMV("MV_#GRPPRD",,"019|022|026")
	Local cCodGrpSAI := GetMV("MV_#GRPSAI",,"008|009|016")

	if cGRPFIN_TIPO == "2"
		cEntSai := "NAO OPERACIONAL"
	ELSE
		// Contas a Receber - Entrada
		SE1->( dbSetOrder(1) ) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		If SE1->( dbSeek(cE5_FILIAL+cE5_PREFIXO+cE5_NUMERO+cE5_PARCELA+cE5_TIPO+cE5_CLIFOR+cE5_LOJA) )
			cEntSai := "ENTRADA"
		EndIf
		
		// Contas a Pagar - Saida
		SE2->( dbSetOrder(1) ) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		If SE2->( dbSeek(cE5_FILIAL+cE5_PREFIXO+cE5_NUMERO+cE5_PARCELA+cE5_TIPO+cE5_CLIFOR+cE5_LOJA) )
			cEntSai := "SAIDA"
		EndIf

		// Chamado n. 055337 || OS 056759 || FINANCAS || DRIELE || 8376 || FLUXO DE CAIXAS - FWNM - 10/02/2020
		If cEntSai == "MOVIMENTO BANCARIO"
			If nValor > 0
				cEntSai := "ENTRADA"
			Else
				cEntSai := "SAIDA"
			EndIf
		EndIf
	
	Endif

	// @history ticket   68310 - Fernando Macieira    - 16/02/2022 - Manutenção no relatório de Fluxo de Caixa
	If AllTrim(cGrpPrd) == "X"
		cEntSai := "ENTRADA"
	EndIf

	If AllTrim(cGrpPrd) $ AllTrim(cCodGrpPrd)
		cEntSai := "NAO OPERACIONAL"
	EndIf

	If AllTrim(cGrpPrd) $ AllTrim(cCodGrpSAI)
		cEntSai := "SAIDA"
	EndIf

	//

	// @history ticket   68289 - Fernando Macieira    - 16/02/2022 - Criação de critério Relatório Fluxo de Caixa
	If AllTrim(cE5_TIPODOC) == "ES" .and. AllTrim(cE5_RECPAG) == "R"
		cEntSai := "SAIDA"
	ElseIf AllTrim(cE5_TIPODOC) == "ES" .and. AllTrim(cE5_RECPAG) == "P"
		cEntSai := "ENTRADA"
	EndIf
	//
	
	RestArea( aAreaSE1 )
	RestArea( aAreaSE2 )

Return cEntSai

/*/{Protheus.doc} Static Function UPPOWERBI
	Popula tabela FLUXOCAIXA para consumo dos dashboards do Power BI
	@type  Function
	@author Fernando Macieira
	@since 20/09/2019
	@version 01
	@history Chamado 051865

	USE [DWDADOSADV]
	GO
	
	CREATE TABLE [dbo].[FLUXOCAIXA]
		(
		[EMPRESA] [varchar](2) NOT NULL,
		[FILIAL] [varchar](2) NOT NULL,
		[NUMERO] [varchar](9) NOT NULL,
		[PARCELA] [varchar](3) NOT NULL,
		[TIPO] [varchar](3) NOT NULL,
		[CLIFOR] [varchar](6) NOT NULL,
		[LOJA] [varchar](2) NOT NULL,
		[BENEF] [varchar](30) NOT NULL,
		[NATUREZA] [varchar](10) NOT NULL,
		[BAIXA] [varchar](8) NOT NULL,
		[VENCTO] [varchar](8) NOT NULL,
		[DTDISPO] [varchar](8) NOT NULL,
		[VALOR] [float] NOT NULL,
		[EMISSAO] [varchar](8) NOT NULL,
		[SEQ] [varchar](2) NOT NULL,
		[DESCNATURE] [varchar](60) NOT NULL,
		[BANCO] [varchar](3) NOT NULL,
		[AGENCIA] [varchar](5) NOT NULL,
		[CONTA] [varchar](10) NOT NULL,
		[STATUS] [varchar](30) NOT NULL,
		[DESCPROD] [varchar](60) NOT NULL,
		[CODPROD] [varchar](50) NOT NULL,
		[GRPFIN] [varchar](30) NOT NULL,
		[DESCGRPFIN] [varchar](60) NOT NULL,
		[TIPDESPESA] [varchar](30) NOT NULL,
		[SEMANA] [varchar](02) NOT NULL,
		[MES] [varchar](02) NOT NULL,
		[EMPFIL] [varchar](02) NOT NULL,
		[RECPAG] [varchar](1) NOT NULL,
		[ENTSAI] [varchar](30) NOT NULL,
		[CNPJ] [varchar](8) NOT NULL,
		[RAZAO] [varchar](60) NOT NULL,
		[NOME_EMPRESA] [varchar](60) NOT NULL,
		[NOME_FILIAL] [varchar](60) NOT NULL
		)
	
	GO
/*/
Static Function UpPowerBI( cE5FILIAL, cE5_NUMERO, cE5_PARCELA, cE5_TIPO, cE5_CLIFOR, cE5_LOJA, cE5_BENEF, cE5_NATUREZ, dDatBaixa, cE5_VENCTO, cE5_DTDISPO, nValor, dDataEmis, cE5_SEQ, cDescNat, cE5_BANCO, cE5_AGENCIA, cE5_CONTA, cStatus, cPrdMvlr, CodPrdMv, cGrpPrd, cDscGrp, cTipDes, cSemana, cMes, cEmpFil, cE5_RECPAG, cEntSai, cCNPJ, cRazao, lErroBI, dVencrea, cSemanaFat, cFluxoStatus )

	Local cSql     := ""
	Local cNomEmp  := ""
	Local cNomFil  := ""
	Local aAreaSM0 := SM0->( GetArea() )
	
	// Retiro acentuacao e apostrofes
	cE5_BENEF := FwNoAccent(cE5_BENEF)
	cE5_BENEF := StrTran(cE5_BENEF,"'","")

	cRazao := FwNoAccent(cRazao)
	cRazao := StrTran(cRazao,"'","")                    

	// Chamado TI - Power BI - Retirar acentuacoes - 09/10/2019 - FWNM    
	cDscGrp := FwNoAccent(cDscGrp)
	cDscGrp := StrTran(cDscGrp,"'","")                    
	
	cPrdMVlr := FwNoAccent(cPrdMVlr)
	cPrdMVlr := StrTran(cPrdMVlr,"'","")                    

	cDescNat := FwNoAccent(cDescNat)
	cDescNat := StrTran(cDescNat,"'","")                    
	//
	
	// Chamado - 051865 - Power BI - Nomes Empresa e Filial - fwnm - 25/09/2019
	// Empresas e Filiais
	If Empty(cE5FILIAL)
		cE5FILIAL := cFilAnt
	EndIf
	
	SM0->( dbSetOrder(1) ) // M0_CODIGO + M0_CODFIL
	If SM0->( dbSeek(cEmpAnt+cE5FILIAL) )
		cNomEmp := FwNoAccent(Upper(SM0->M0_NOME))
		cNomEmp := StrTran(cNomEmp,"'","")
	
		cNomFil := FwNoAccent(Upper(SM0->M0_FILIAL))
		cNomFil := StrTran(cNomFil,"'","")
	EndIf
	//

	If !lErroBI
		// Populo tabela Power BI
		cSql := " INSERT INTO [" + cServBI + "].[" + cSGBDBI + "].[dbo].[FLUXOCAIXA] " 
	
		cSql += " ( " 
		cSql += " EMPRESA, " 
		cSql += " FILIAL, " 
		cSql += " NUMERO, " 
		cSql += " PARCELA, " 
		cSql += " TIPO, " 
		cSql += " CLIFOR, " 
		cSql += " LOJA, " 
		cSql += " BENEF, " 
		cSql += " NATUREZA, "
		cSql += " BAIXA, "
		cSql += " VENCTO, " 
		cSql += " DTDISPO, " 
		cSql += " VALOR, " 
		cSql += " EMISSAO, " 
		cSql += " SEQ, " 
		cSql += " DESCNATURE, " 
		cSql += " BANCO, " 
		cSql += " AGENCIA, " 
		cSql += " CONTA, " 
		cSql += " STATUS, " 
		cSql += " DESCPROD, " 
		cSql += " CODPROD, " 
		cSql += " GRPFIN, " 
		cSql += " DESCGRPFIN, " 
		cSql += " TIPDESPESA, " 
		cSql += " SEMANA, " 
		cSql += " MES, " 
		cSql += " EMPFIL, " 
		cSql += " RECPAG, " 
		cSql += " ENTSAI, " 
		cSql += " CNPJ, " 
		cSql += " RAZAO, " 
		cSql += " NOME_EMPRESA, " 
		cSql += " NOME_FILIAL, " 
		cSql += " VENCREA, "
		cSql += " SEMANAFAT, "      //- Chamado : T.I - 25/03/2020 - Sigoli
		cSql += " FLUXOCAIXA_STATUS "
		cSql += " ) "
	      
		cSql += "VALUES ("
		cSql += "'"         + AllTrim(cEmpAnt)         + "',"  		
		cSql += "'"         + AllTrim(cE5FILIAL)         + "',"  
		cSql += "'"         + AllTrim(cE5_NUMERO)        + "'," 
		cSql += "'"         + AllTrim(cE5_PARCELA)       + "',"  
		cSql += "'"         + AllTrim(cE5_TIPO)          + "'," 
		cSql += "'"         + AllTrim(cE5_CLIFOR)        + "'," 
		cSql += "'"         + AllTrim(cE5_LOJA)          + "'," 
		cSql += "'"         + AllTrim(cE5_BENEF)         + "'," 
		cSql += "'"         + AllTrim(cE5_NATUREZ)       + "'," 
		cSql += "'"         + DtoS(dDatBaixa)    		 + "'," 
		cSql += "'"         + DtoS(cE5_VENCTO)   		 + "',"  
		cSql += "'"         + DtoS(cE5_DTDISPO)  		 + "',"  
		cSql += ""          + cValToChar(nValor) 		 + ","  
		cSql += "'"         + DtoS(dDataEmis)    		 + "',"  
		cSql += "'"         + AllTrim(cE5_SEQ)           + "',"  
		cSql += "'"         + AllTrim(cDescNat)          + "',"  
		cSql += "'"         + AllTrim(cE5_BANCO)         + "',"  
		cSql += "'"         + AllTrim(cE5_AGENCIA)       + "',"  
		cSql += "'"         + AllTrim(cE5_CONTA)         + "',"  
		cSql += "'"         + AllTrim(cStatus)           + "',"  
		cSql += "'"         + AllTrim(cPrdMvlr)          + "',"  
		cSql += "'"         + AllTrim(CodPrdMv)          + "',"  
		cSql += "'"         + AllTrim(cGrpPrd)           + "',"  
		cSql += "'"         + AllTrim(cDscGrp)           + "',"  
		cSql += "'"         + AllTrim(cTipDes)           + "',"  
		cSql += "'"         + AllTrim(cSemana)           + "',"  
		cSql += "'"         + AllTrim(cMes)              + "',"  
		cSql += "'"         + AllTrim(cEmpFil)           + "',"  
		cSql += "'"         + AllTrim(cE5_RECPAG)        + "',"  
		cSql += "'"         + AllTrim(cEntSai)           + "',"  
		cSql += "'"         + AllTrim(cCNPJ)             + "',"  
		cSql += "'"         + AllTrim(cRazao)            + "',"  
		cSql += "'"         + AllTrim(cNomEmp)           + "',"  
		cSql += "'"         + AllTrim(cNomFil)           + "',"  
		cSql += "'"         + DtoS(dVencrea)             + "',"  
		cSql += "'"         + AllTrim(cSemanaFat)        + "',"  
		cSql += "'"         + AllTrim(cFluxoStatus)      + "'"  
		cSql += ") " 
	
		If tcSQLExec(cSql) < 0                            
			lErroBI := .t.		
			MsgAlert( "Movimento não integrado com Power BI... Erro! "  + chr(13) + chr(10) + chr(13) + chr(10) + tcSqlError() )
		EndIf        
	
	EndIf          
	
	RestArea( aAreaSM0 )

Return

/*/{Protheus.doc} Static Function DELPOWERBI
	Deleta registros antes da gravacao - tabela FLUXOCAIXA para consumo dos dashboards do Power BI
	@type  Function
	@author Fernando Macieira
	@since 20/09/2019
	@version 01
	@history Chamado 051865
/*/
Static Function DelPowerBI( lErroBI )

	Local cSql  := ""
      
    // Deleto registro antes da inclusao
    cSql := " DELETE [" + cServBI + "].[" + cSGBDBI + "].[dbo].[FLUXOCAIXA] " 
    cSql += " WHERE "
	cSql += " EMPRESA = '"+cEmpAnt+"' "
	cSql += " AND FILIAL BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' "
	cSql += " AND CLIFOR BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"' "    
	cSql += " AND LOJA BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"' "    
	cSql += " AND NATUREZA BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "

	If !Empty(MV_PAR01) .and. !Empty(MV_PAR02)
		cSql += " AND DTDISPO BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "
	EndIf

	If !Empty(MV_PAR12) .and. !Empty(MV_PAR13)
		cSql += " AND VENCTO BETWEEN '"+DtoS(MV_PAR12)+"' AND '"+DtoS(MV_PAR13)+"' "
	EndIf
	
	If tcSQLExec(cSql) < 0                            
		lErroBI := .t.
		MsgAlert( "Movimento não integrado com Power BI... Erro! " + chr(13) + chr(10) + chr(13) + chr(10) + tcSqlError() )
	EndIf        

Return

/*/{Protheus.doc} Static Function ChkDtFloat(dVencrea)
	Função para calcular data float do contas a receber
	@type  Static Function
	@author FWNM
	@since 03/02/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 055337
/*/
Static Function ChkDtFloat(dVencrea)

	Local nDiaSemana := Dow(dVencrea)

	If nDiaSemana == 6 // Sexta-Feira
		dVencrea += 3
	Else
		dVencrea += 1
	EndIf
	
Return dVencrea

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 25/03/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function UpDtBor( cE5FILIAL, cE5_CLIFOR, cE5_LOJA, cE5_PREFIXO, cE5_NUMERO, cE5_PARCELA, cE5_TIPO, cE5_RECPAG )

	Local dRet := CtoD("//")
	Local cQuery := ""

	If Select("WorkDtBor") > 0 
		WorkDtBor->( dbCloseArea() )
	EndIf

	cQuery := " SELECT TOP 1 EA_DATABOR
	cQuery += " FROM " + RetSqlName("SEA") + " (NOLOCK)
	cQuery += " WHERE EA_FILIAL='"+cE5FILIAL+"' 
	cQuery += " AND EA_PREFIXO='"+cE5_PREFIXO+"' 
	cQuery += " AND EA_NUM='"+cE5_NUMERO+"' 
	cQuery += " AND EA_PARCELA='"+cE5_PARCELA+"' 
	cQuery += " AND EA_TIPO='"+cE5_TIPO+"' 
	cQuery += " AND EA_CART='"+cE5_RECPAG+"' 
	If AllTrim(cE5_RECPAG) == "P"
		cQuery += " AND EA_FORNECE='"+cE5_CLIFOR+"' 
		cQuery += " AND EA_LOJA='"+cE5_LOJA+"' 
	EndIf
	cQuery += " AND D_E_L_E_T_='*'
	cQuery += " ORDER BY 1 DESC

	tcQuery cQuery new Alias "WorkDtBor"

	aTamSX3	:= TamSX3("EA_DATABOR")
	tcSetField("WorkDtBor", "EA_DATABOR", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	WorkDtBor->( dbGoTop() )

	If WorkDtBor->( !EOF() )

		dRet := WorkDtBor->EA_DATABOR

	EndIf

	If Select("WorkDtBor") > 0 
		WorkDtBor->( dbCloseArea() )
	EndIf
	
Return dRet
