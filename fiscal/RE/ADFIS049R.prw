#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} User Function ADFIS049R
  Relatório detalhado CIAP
  @type  Function
  @author Abel Babini Filho
  @since 15/02/2022
  @version version
  @history Ticket 068238 - Abel Babini - 15/02/2022 - Relatório detalhado CIAP
  @history Ticket 068238 - Abel Babini - 20/06/2022 - Adicionando novas colunas
  /*/
User Function ADFIS049R
	Local aArea		:= GetArea()
	Local aPergs	:= {}

	Private cPathRel := ''
	Private cArquivo := ''
	Private aRet	:= {}	
	
  U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatório Detalhado CIAP')
  	//Adiciona Perguntas / Parâmetros ao relatório
	aAdd( aPergs ,{1,"Data De "     ,Ctod(space(8)),"" ,'.T.',     ,'.T.',80,.T.})
	aAdd( aPergs ,{1,"Data Até"     ,Ctod(space(8)),"" ,'.T.',     ,'.T.',80,.T.})
	Aadd( aPergs ,{1,"Código De"  	,Space(10)     ,"" ,'.T.',"SF9",'.T.',80,.F.})
	Aadd( aPergs ,{1,"Código Até"  	,Space(10)     ,"" ,'.T.',"SF9",'.T.',80,.F.})
	aAdd( aPergs ,{6,"Local de Gravação",Space(50),"","","",50,.T.,"Todos os arquivos (*.*) |*.*","C:\TEMP\",GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE})

	// Aadd( aPergs ,{1,"Tipo De"  							,Space(2) ,"" ,'.T.',"SZE",'.T.',80,.F.})
	// Aadd( aPergs ,{1,"Tipo Até"  						,Space(2) ,"" ,'.T.',"SZE",'.T.',80,.F.})
	// aAdd( aPergs	,{ 3,"Considera prod bloqueados"		,1,{'Todos','Sim','Não'},100,"",.F.})

	//Executa as perguntas ao usuário e só executa o relatório caso o usuário confirme a tela de parâmetros;
	If ParamBox(aPergs ,"Parâmetros ",aRet,,,,,,,,.T.,.T.)
		
		cPathRel:= alltrim(aRet[5])
		cArquivo := cPathRel +  'RCIAP_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
		Processa({||xExecRel()},"Gerando relatório","Aguarde...")
  Endif
  RestArea(aArea)
Return

/*/{Protheus.doc} Static Function xExecRel
	Gera Relatório CIAP
	@author Abel Babini Filho
	@since 01/03/2022
	@version 01
	/*/
Static Function xExecRel()
	Local cQuery := GetNextAlias()
	Local cFld01 := 'CIAP'
	Private oExcel     := FWMSEXCELEX():New()
	//Private cArquivo	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)	
	Private oMsExcel   := NIL

	//Ticket 068238 - Abel Babini - 20/06/2022 - Adicionando novas colunas
	BEGINSQL Alias cQuery
		COLUMN F9_DTENTNE AS DATE
		COLUMN F9_DTEMINE AS DATE
		COLUMN F9_DTEMINS AS DATE
		SELECT
			SF9.F9_FILIAL,
			SF9.F9_CODIGO,
			SF9.F9_DESCRI,
			SF9.F9_FORNECE,
			SF9.F9_LOJAFOR,
			SF9.F9_DOCNFE,
			SF9.F9_SERNFE,
			SF9.F9_ITEMNFE,
			SF9.F9_DTENTNE,
			SF9.F9_DTEMINE,
			SF9.F9_CFOENT,
			SF9.F9_CLIENTE,
			SF9.F9_LOJACLI,
			SF9.F9_DOCNFS,
			SF9.F9_SERNFS,
			SF9.F9_ITEMNFS,
			SF9.F9_DTEMINS,
			SF9.F9_MOTIVO,
			SF9.F9_ROTINA,
			SF9.F9_VIDUTIL,
			SF9.F9_PICM,
			SF9.F9_FCA,
			SF9.F9_QTDPARC,
			SF9.F9_SLDPARC,
			SF9.F9_CODBAIX,
			SF9.F9_DTINIUT,
			SF9.F9_STATUS,
			SF9.F9_VALICMS,
			SF9.F9_ICMIMOB,
			SF9.F9_VLESTOR,
			SF9.F9_BXICMS,
			SF9.F9_VALICCO,
			SF9.F9_VALICST,
			SF9.F9_VALFRET,
			SF9.F9_VALICMP,
			SF9.F9_VLDBATV,
			SD1.D1_CC,
			SD1.D1_QUANT,
			CASE WHEN N1_XATFBEN = '1' THEN 'Benfeitoria Bens' ELSE CASE WHEN N1_XATFBEN = '2' THEN 'Benfeitoria Servicos' ELSE CASE WHEN N1_XATFBEN = '3' THEN 'Ativo Imobilizado' ELSE '' END END END AS XATFBEN,
			CASE 
				WHEN SN1.N1_CALCPIS = '1' THEN 'Sim'
				WHEN SN1.N1_CALCPIS = '2' THEN 'Não'
				WHEN SN1.N1_CALCPIS = '3' THEN 'Fração'
				ELSE ''
			end AS N1_CALCPIS,
			(SELECT SUM(SFA.FA_VALOR) FROM %TABLE:SFA% SFA WHERE SFA.FA_FILIAL = SF9.F9_FILIAL AND SFA.FA_CODIGO = SF9.F9_CODIGO AND SFA.FA_TIPO = '1' AND SFA.%notDel%) AS FA_VALOR,
			(SELECT SUM(SFA.FA_VALOR*SFA.FA_FATOR) FROM SFA010 SFA WHERE SFA.FA_FILIAL = SF9.F9_FILIAL AND SFA.FA_CODIGO = SF9.F9_CODIGO AND SFA.FA_TIPO = '1' AND SFA.D_E_L_E_T_ = '') AS FA_VALXFAT,
			(SELECT SUM(SFA.FA_VALOR) FROM SFA010 SFA WHERE SFA.FA_FILIAL = SF9.F9_FILIAL AND SFA.FA_CODIGO = SF9.F9_CODIGO AND SFA.FA_TIPO = '1' AND SFA.D_E_L_E_T_ = '') -
			(SELECT SUM(SFA.FA_VALOR*SFA.FA_FATOR) FROM SFA010 SFA WHERE SFA.FA_FILIAL = SF9.F9_FILIAL AND SFA.FA_CODIGO = SF9.F9_CODIGO AND SFA.FA_TIPO = '1' AND SFA.D_E_L_E_T_ = '') AS FA_DIFFAT
		FROM %TABLE:SF9% SF9
		LEFT JOIN %TABLE:SN1% SN1 ON
			SN1.N1_FILIAL = SF9.F9_FILIAL
			AND SN1.N1_CODCIAP = SF9.F9_CODIGO
			AND SN1.%notDel%
		LEFT JOIN %TABLE:SD1% SD1 ON
			SD1.D1_FILIAL = SN1.N1_FILIAL AND
			SD1.D1_DOC = SN1.N1_NFISCAL AND
			SD1.D1_SERIE = SN1.N1_NSERIE AND
			SD1.D1_ITEM = SN1.N1_NFITEM AND
			SD1.D1_FORNECE = SN1.N1_FORNEC AND
			SD1.D1_LOJA = SN1.N1_LOJA AND
			SD1.%notDel%
		WHERE
			SF9.F9_FILIAL = %xFilial:SF9%
			AND SF9.F9_CODIGO BETWEEN %Exp:aRet[3]% AND %Exp:aRet[4]%
			AND SF9.F9_DTENTNE BETWEEN %Exp:DToS(aRet[1])% AND %Exp:DToS(aRet[2])%
			AND SF9.%notDel%
		ORDER BY F9_CODIGO
	ENDSQL

	//CABEÇALHO
	oExcel:AddworkSheet(cFld01)
	oExcel:AddTable(cFld01,cFld01)
	oExcel:AddColumn(cFld01,cFld01,"Filial",1,1)
	oExcel:AddColumn(cFld01,cFld01,"Código",1,1)
	oExcel:AddColumn(cFld01,cFld01,"Descrição",1,1)
	oExcel:AddColumn(cFld01,cFld01,"Cod.Fornec.",1,1)
	oExcel:AddColumn(cFld01,cFld01,"Lj. Fornec.",1,1)
	oExcel:AddColumn(cFld01,cFld01,"Doc NFE",1,1)
	oExcel:AddColumn(cFld01,cFld01,"Serie NFE",1,1)
	oExcel:AddColumn(cFld01,cFld01,"Item NFE",1,1)
	oExcel:AddColumn(cFld01,cFld01,"Dt Ent NFE",1,1)
	oExcel:AddColumn(cFld01,cFld01,"Dt Emis NFE",1,1)
	oExcel:AddColumn(cFld01,cFld01,"CFOP NFE",1,1)
	oExcel:AddColumn(cFld01,cFld01,"CC NFE",1,1) //Ticket 068238 - Abel Babini - 20/06/2022 - Adicionando novas colunas
	oExcel:AddColumn(cFld01,cFld01,"Quant NFE",1,1) //Ticket 068238 - Abel Babini - 20/06/2022 - Adicionando novas colunas
	oExcel:AddColumn(cFld01,cFld01,"Cod.Cliente",1,1)
	oExcel:AddColumn(cFld01,cFld01,"Lj. Cliente",1,1)
	oExcel:AddColumn(cFld01,cFld01,"Doc NFS",1,1)
	oExcel:AddColumn(cFld01,cFld01,"Serie NFS",1,1)
	oExcel:AddColumn(cFld01,cFld01,"Item NFS",1,1)
	oExcel:AddColumn(cFld01,cFld01,"Dt Emis NFS",1,1)
	oExcel:AddColumn(cFld01,cFld01,"Vida Util",1,1)
	oExcel:AddColumn(cFld01,cFld01,"Qtd Parcelas",1,1)
	oExcel:AddColumn(cFld01,cFld01,"Saldo Parcelas",1,1)
	oExcel:AddColumn(cFld01,cFld01,"ICMS Aliq",2,2)
	oExcel:AddColumn(cFld01,cFld01,"Vlr ICMS",2,2)
	oExcel:AddColumn(cFld01,cFld01,"Vlr ICMS Imob",2,2)
	oExcel:AddColumn(cFld01,cFld01,"Vlr ICMS Estorn",2,2)
	oExcel:AddColumn(cFld01,cFld01,"Vlr ICMS Baixa ",2,2)
	oExcel:AddColumn(cFld01,cFld01,"Vlr ICMS Compl",2,2)
	oExcel:AddColumn(cFld01,cFld01,"Vlr ICMS ST",2,2)
	oExcel:AddColumn(cFld01,cFld01,"Vlr ICMS Frete",2,2)
	oExcel:AddColumn(cFld01,cFld01,"Vlr ICMS Próprio",2,2)
	oExcel:AddColumn(cFld01,cFld01,"Tipo Ativo",1,1)
	oExcel:AddColumn(cFld01,cFld01,"Cálculo Pis/Cofins",1,1)
	oExcel:AddColumn(cFld01,cFld01,"(A) Vlr Total Apropr.",3,2)
	oExcel:AddColumn(cFld01,cFld01,"(B) Vlr Creditado",3,2) //Ticket 068238 - Abel Babini - 20/06/2022 - Adicionando novas colunas
	oExcel:AddColumn(cFld01,cFld01,"(C) = (A) - (B) Valor Não Creditado",3,2) //Ticket 068238 - Abel Babini - 20/06/2022 - Adicionando novas colunas

	DbSelectArea(cQuery)
	(cQuery)->(DbGoTop())
	While !(cQuery)->(eof())
		oExcel:AddRow(cFld01,cFld01,{	(cQuery)->F9_FILIAL,;
																	(cQuery)->F9_CODIGO,;
																	(cQuery)->F9_DESCRI,;
																	(cQuery)->F9_FORNECE,;
																	(cQuery)->F9_LOJAFOR,;
																	(cQuery)->F9_DOCNFE,;
																	(cQuery)->F9_SERNFE,;
																	(cQuery)->F9_ITEMNFE,;
																	IIF(ALLTRIM(DTOS((cQuery)->F9_DTENTNE)) == '','',DTOC((cQuery)->F9_DTENTNE)),;
																	IIF(ALLTRIM(DTOS((cQuery)->F9_DTEMINE)) == '','',DTOC((cQuery)->F9_DTEMINE)),;
																	(cQuery)->F9_CFOENT,;
																	(cQuery)->D1_CC,;
																	(cQuery)->D1_QUANT,;
																	(cQuery)->F9_CLIENTE,;
																	(cQuery)->F9_LOJACLI,;
																	(cQuery)->F9_DOCNFS,;
																	(cQuery)->F9_SERNFS,;
																	(cQuery)->F9_ITEMNFS,;
																	IIF(ALLTRIM(DTOS((cQuery)->F9_DTEMINS)) == '','',DTOC((cQuery)->F9_DTEMINS)),;
																	(cQuery)->F9_VIDUTIL,;
																	(cQuery)->F9_QTDPARC,;
																	(cQuery)->F9_SLDPARC,;
																	(cQuery)->F9_PICM,;
																	(cQuery)->F9_VALICMS,;
																	(cQuery)->F9_ICMIMOB,;
																	(cQuery)->F9_VLESTOR,;
																	(cQuery)->F9_BXICMS,;
																	(cQuery)->F9_VALICCO,;
																	(cQuery)->F9_VALICST,;
																	(cQuery)->F9_VALFRET,;
																	(cQuery)->F9_VALICMP,;
																	(cQuery)->XATFBEN,;
																	(cQuery)->N1_CALCPIS,;
																	(cQuery)->FA_VALOR,;
																	(cQuery)->FA_VALXFAT,;
																	(cQuery)->FA_DIFFAT})
		(cQuery)->(DbSkip())
	EndDo
	(cQuery)->(dbCloseArea())
	
	oExcel:AddRow(cFld01,cFld01,{'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''})


	oExcel:Activate()
	oExcel:GetXMLFile(cArquivo)
	IF ( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		oMsExcel := MsExcel():New()
		oMsExcel:WorkBooks:Open(cArquivo)
		oMsExcel:SetVisible( .T. )
		oMsExcel:Destroy()
	ELSE
		Alert("Nao Existe Excel Instalado ou não foi possível localizá-lo. Tente novamente!")
	ENDIF
Return
//TODO Considerar Bens baixados e a partir da baixa não considerar mais
//TODO Considerar saldo de parcelas.

/*
*/
