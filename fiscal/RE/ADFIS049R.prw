#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} User Function ADFIS049R
  Relatório detalhado CIAP
  @type  Function
  @author Abel Babini Filho
  @since 15/02/2022
  @version version
  @history Ticket 068238 - Abel Babini - 15/02/2022 - Relatório detalhado CIAP
  @history Ticket 068238 - Abel Babini - 20/06/2022 - Adicionando novas colunas
  @history Ticket 068238 - Abel Babini - 21/06/2022 - Adicionando novas colunas
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

/*/{Protheus.doc} Static Function xExecRel()
	Gera Relatório CIAP
	@author Abel Babini Filho
	@since 01/03/2022
	@version 01
/*/
Static Function xExecRel()
	Local cQuery := GetNextAlias()
	// Local cQryNFC := GetNextAlias()
	Local cQrySFA := ''
	Local cFld01 := 'CIAP'
	Local aDados := {}
	Local nTotRegs := 0
	Local dDtIniPr := CTOD('01/05/2018')
	Local dDtProce := CTOD('01/05/2018')
	Local nNumMes := DateDiffMonth(dDtIniPr,aRet[2])+1
	Local _i	:= 0
	Local _j := 0
	Local _k := 0
	Local cAnoMesF := ''
	Local nPos := 0
	Local nPosMes := 0
	Local nTotPos := 34 /*indice 1 + numero de colunas 33*/ + (nNumMes*3) /*numero de meses*/ + 2 /*coluna de total por item*/
	Local aEmptyLn := {}
	Local aFullLin := {}

	Private oExcel     := FWMSEXCELEX():New()
	//Private cArquivo	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)	
	Private oMsExcel   := NIL

	if nNumMes < 0 
		Alert('A data final precisa ser superior a 01/05/2018!')
		(cQuery)->(dbCloseArea())
		Return
	endif

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
			end AS N1_CALCPIS//--,
			//(SELECT SUM(SFA.FA_VALOR) FROM %TABLE:SFA% SFA WHERE SFA.FA_FILIAL = SF9.F9_FILIAL AND SFA.FA_CODIGO = SF9.F9_CODIGO AND SFA.FA_TIPO = '1' AND SFA.%notDel%) AS FA_VALOR,
			//(SELECT SUM(SFA.FA_VALOR*SFA.FA_FATOR) FROM SFA010 SFA WHERE SFA.FA_FILIAL = SF9.F9_FILIAL AND SFA.FA_CODIGO = SF9.F9_CODIGO AND SFA.FA_TIPO = '1' AND SFA.D_E_L_E_T_ = '') AS FA_VALXFAT,
			//(SELECT SUM(SFA.FA_VALOR) FROM SFA010 SFA WHERE SFA.FA_FILIAL = SF9.F9_FILIAL AND SFA.FA_CODIGO = SF9.F9_CODIGO AND SFA.FA_TIPO = '1' AND SFA.D_E_L_E_T_ = '') -
			//(SELECT SUM(SFA.FA_VALOR*SFA.FA_FATOR) FROM SFA010 SFA WHERE SFA.FA_FILIAL = SF9.F9_FILIAL AND SFA.FA_CODIGO = SF9.F9_CODIGO AND SFA.FA_TIPO = '1' AND SFA.D_E_L_E_T_ = '') AS FA_DIFFAT
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

	//Verifica Total de Registros de Itens
	nTotRegs := 0
	(cQuery)->( dbEval( { || nTotRegs++ },,{ || !EOF() } ) )

	//Monta Array para adicionar as informações
	aDados := Array(nTotRegs,nTotPos)
	for _i := 1 to nTotRegs
		for _k := 1 to nNumMes
			aDados[_i][34+((_k-1)*3)+1] := 0
			aDados[_i][34+((_k-1)*3)+2] := 0
			aDados[_i][34+((_k-1)*3)+3] := 0
		next _k
		aDados[_i][34+(nNumMes*3)+1] := 0
		aDados[_i][34+(nNumMes*3)+2] := 0
	next _i

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

	dDtProce := CTOD('01/05/2018')
	For _i := 1 to nNumMes
		cMesAtu := iif(Month(dDtProce)<10,'0'+Alltrim(str(Month(dDtProce))),Alltrim(str(Month(dDtProce))))
		cAnoAtu := Alltrim(str(Year(dDtProce)))
		oExcel:AddColumn(cFld01,cFld01,"(1) Valor Credito Mês "+Alltrim(Str(_i))+" - "+cAnoAtu+"/"+cMesAtu,3,2,.T.)
		oExcel:AddColumn(cFld01,cFld01,"(2) Fator Mês "+Alltrim(Str(_i))+" - "+cAnoAtu+"/"+cMesAtu,3,2)
		oExcel:AddColumn(cFld01,cFld01,"(3) = (1) / (2) Valor Parcela Mês "+Alltrim(Str(_i))+" - "+cAnoAtu+"/"+cMesAtu,3,2,.T.)
		dDtProce := MonthSum(dDtProce,1)
	Next _i
	oExcel:AddColumn(cFld01,cFld01,"Total Credito Item",3,2,.T.)
	oExcel:AddColumn(cFld01,cFld01,"Total Parcela Item",3,2,.T.)
	//oExcel:AddColumn(cFld01,cFld01,"(A) Vlr Total Apropr.",3,2)
	//oExcel:AddColumn(cFld01,cFld01,"(B) Vlr Creditado",3,2) //Ticket 068238 - Abel Babini - 20/06/2022 - Adicionando novas colunas
	//oExcel:AddColumn(cFld01,cFld01,"(C) = (A) - (B) Valor Não Creditado",3,2) //Ticket 068238 - Abel Babini - 20/06/2022 - Adicionando novas colunas

	DbSelectArea(cQuery)
	(cQuery)->(DbGoTop())
	While !(cQuery)->(eof())
		dDtProce := CTOD('01/05/2018')
		For _i := 1 to nNumMes
			cMesAtu := iif(Month(dDtProce)<10,'0'+Alltrim(str(Month(dDtProce))),Alltrim(str(Month(dDtProce))))
			cAnoAtu := Alltrim(str(Year(dDtProce)))
			cAnoMesF := cAnoAtu+cMesAtu
			cQrySFA := GetNextAlias()
			nPosMes := (_i-1)*3

			BeginSql Alias cQrySFA
				SELECT
					ISNULL(SFA.FA_VALOR,0) AS FA_VALOR,
					ISNULL(SFA.FA_FATOR,0) AS FA_FATOR,
					CASE 
						WHEN ISNULL(SFA.FA_FATOR,0) = 0 THEN 0
						ELSE ISNULL(ISNULL(SFA.FA_VALOR,0)/ISNULL(SFA.FA_FATOR,0),0)
					END AS VLR_PARCELA
				FROM %TABLE:SFA% SFA
				WHERE 
					SFA.FA_FILIAL = %Exp:(cQuery)->F9_FILIAL% AND
					SFA.FA_CODIGO = %Exp:(cQuery)->F9_CODIGO% AND
					SUBSTRING(SFA.FA_DATA,1,6) = %Exp:cAnoMesF% AND
				  SFA.FA_TIPO = '1' AND
					SFA.%notDel%
			EndSql

			DbSelectArea(cQrySFA)
			(cQrySFA)->(DbGoTop())
			While !(cQrySFA)->(eof())
				nPos := 0
				nPos := ASCAN(aDados, {|X| X[1] == (cQuery)->F9_FILIAL + (cQuery)->F9_CODIGO })
				If nPos == 0
					for _k := 1 to Len(aDados)
						If Empty(Alltrim(aDados[_k,1]))
							nPos := _k
							exit
						Endif
					next _k
					aDados[nPos][1] := (cQuery)->F9_FILIAL+(cQuery)->F9_CODIGO
					aDados[nPos][2] := (cQuery)->F9_FILIAL
					aDados[nPos][3] := (cQuery)->F9_CODIGO
					aDados[nPos][4] := (cQuery)->F9_DESCRI
					aDados[nPos][5] := (cQuery)->F9_FORNECE
					aDados[nPos][6] := (cQuery)->F9_LOJAFOR
					aDados[nPos][7] := (cQuery)->F9_DOCNFE
					aDados[nPos][8] := (cQuery)->F9_SERNFE
					aDados[nPos][9] := (cQuery)->F9_ITEMNFE
					aDados[nPos][10] := IIF(ALLTRIM(DTOS((cQuery)->F9_DTENTNE)) == '','',DTOC((cQuery)->F9_DTENTNE))
					aDados[nPos][11] := IIF(ALLTRIM(DTOS((cQuery)->F9_DTEMINE)) == '','',DTOC((cQuery)->F9_DTEMINE))
					aDados[nPos][12] := (cQuery)->F9_CFOENT
					aDados[nPos][13] := (cQuery)->D1_CC
					aDados[nPos][14] := (cQuery)->D1_QUANT
					aDados[nPos][15] := (cQuery)->F9_CLIENTE
					aDados[nPos][16] := (cQuery)->F9_LOJACLI
					aDados[nPos][17] := (cQuery)->F9_DOCNFS
					aDados[nPos][18] := (cQuery)->F9_SERNFS
					aDados[nPos][19] := (cQuery)->F9_ITEMNFS
					aDados[nPos][20] := IIF(ALLTRIM(DTOS((cQuery)->F9_DTEMINS)) == '','',DTOC((cQuery)->F9_DTEMINS))
					aDados[nPos][21] := (cQuery)->F9_VIDUTIL
					aDados[nPos][22] := (cQuery)->F9_QTDPARC
					aDados[nPos][23] := (cQuery)->F9_SLDPARC
					aDados[nPos][24] := (cQuery)->F9_PICM
					aDados[nPos][25] := (cQuery)->F9_VALICMS
					aDados[nPos][26] := (cQuery)->F9_ICMIMOB
					aDados[nPos][27] := (cQuery)->F9_VLESTOR
					aDados[nPos][28] := (cQuery)->F9_BXICMS
					aDados[nPos][29] := (cQuery)->F9_VALICCO
					aDados[nPos][30] := (cQuery)->F9_VALICST
					aDados[nPos][31] := (cQuery)->F9_VALFRET
					aDados[nPos][32] := (cQuery)->F9_VALICMP
					aDados[nPos][33] := (cQuery)->XATFBEN
					aDados[nPos][34] := (cQuery)->N1_CALCPIS
					aDados[nPos][34+nPosMes+1] := (cQrySFA)->FA_VALOR
					aDados[nPos][34+nPosMes+2] := (cQrySFA)->FA_FATOR
					aDados[nPos][34+nPosMes+3] := (cQrySFA)->VLR_PARCELA
					// aDados[nPos][34+(nNumMes*3)+1] := (cQrySFA)->FA_VALOR
					// aDados[nPos][34+(nNumMes*3)+2] := (cQrySFA)->VLR_PARCELA

				Else
					aDados[nPos][34+nPosMes+1] 		+= (cQrySFA)->FA_VALOR
					aDados[nPos][34+nPosMes+2] 		+= (cQrySFA)->FA_FATOR
					aDados[nPos][34+nPosMes+3] 		+= (cQrySFA)->VLR_PARCELA
					// aDados[nPos][34+(nNumMes*3)+1] += (cQrySFA)->FA_VALOR
					// aDados[nPos][34+(nNumMes*3)+2] += (cQrySFA)->VLR_PARCELA
				Endif
				(cQrySFA)->(DbSkip())
			EndDo

			(cQrySFA)->(dbCloseArea())
			dDtProce := MonthSum(dDtProce,1)

		Next _i

		(cQuery)->(DbSkip())
	EndDo
	(cQuery)->(dbCloseArea())

	//TOTALIZA
	for _i := 1 to Len(aDados)
		nTotCrd := 0
		nTotPrc	:= 0
		For _j := 1 to nNumMes
			nTotCrd += aDados[_i][34+((_j-1)*3)+1]
			nTotPrc	+= aDados[_i][34+((_j-1)*3)+3]
		Next _j
			aDados[_i][34+(nNumMes*3)+1] := nTotCrd
			aDados[_i][34+(nNumMes*3)+2] := nTotPrc
	next _i

	//Imprime Array no Excel
	For _i := 1 to Len(aDados)
		aFullLin := {}
		For _j := 2 to Len(aDados[_i])
			aAdd(aFullLin,aDados[_i,_j])
		Next _j
		oExcel:AddRow(cFld01,cFld01,aFullLin)
	Next _i

	//Cria Linha em branco
	for _i :=1 To nTotPos-1
		aAdd(aEmptyLn,"")
	next _i
	oExcel:AddRow(cFld01,cFld01,aEmptyLn)

	//ADICIONA VALORES DAS NOTAS FISCAIS DE CRÉDITO
	// BeginSql Alias cQryNFC
	// 	SELECT
	// 		campos
	// 	FROM alias
	// 	WHERE D_E_L_E_T_ = ' '
	// 	demaisCondicoes
	// 	ORDER BY orderBy
	// EndSql

	// DbSelectArea(cQryNFC)
	// (cQryNFC)->(DbGoTop())
	// While !(cQryNFC)->(eof())
	// 	(cQryNFC)->(DbSkip())
	// EndDo
	// (cQryNFC)->(dbCloseArea())

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
