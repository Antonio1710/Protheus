#INCLUDE "Protheus.ch"
#INCLUDE "ParmType.ch"

/*/{Protheus.doc} User Function PesqBD
	Funcao para execucao de query de pesquisa, devolvendo os dados formatados. Para busca de tab. unica c/ campos fora de indices.
	@type  Function
	@author Pablo Gollan Carreras
	@since 04/02/2012
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 059415 - FWNM      - 05/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Ajuste na geração do E1_IDCNAB devido desativação das customizações antigas 
/*/
User Function PesqBD(cTabela,aLstCmp,cRestricao,nIndice,lFormata,lAgrupar,lNUsaFil,lUsaDel,cOrder,lNRetArr)

	Local aRet				:= {}
	Local cQry				:= ""
	Local cAliasT			:= GetNextAlias()
	Local lTop				:= .T.
	Local ni				:= 0
	Local nPos				:= 0
	Local aArea				:= {}
	Local aEstru			:= {}
	Local aTMP				:= {}
	Local aFuncAgl			:= {"SUM","COUNT","AVG","MIN","MAX"}						//Funcoes de aglutinacao
	Local lExCmpNAgl		:= .F.														//Existem campos de retorno que nao sao de aglutinacao?
	Local cCriterio			:= ""
	Local lTabSX2			:= .T.	

	//U_ADINF009P('ADFATXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Funcao para execucao de query de pesquisa, devolvendo os dados formatados. Para busca de tab. unica c/ campos fora de indices.')

	PARAMTYPE 0	VAR cTabela		AS Character				DEFAULT ""
	PARAMTYPE 1	VAR aLstCmp		AS Array					DEFAULT {}
	PARAMTYPE 2	VAR cRestricao	AS Character	OPTIONAL	DEFAULT ""
	PARAMTYPE 3	VAR nIndice		AS Numeric		OPTIONAL	DEFAULT 1
	PARAMTYPE 4	VAR lFormata	AS Logical		OPTIONAL	DEFAULT .T.
	PARAMTYPE 5 VAR lAgrupar	AS Logical		OPTIONAL	DEFAULT .F.
	PARAMTYPE 6	VAR lNUsaFil	AS Logical		OPTIONAL	DEFAULT .F.
	PARAMTYPE 7	VAR lUsaDel		AS Logical		OPTIONAL	DEFAULT .F.
	PARAMTYPE 8	VAR	cOrder		AS Character	OPTIONAL	DEFAULT "" 
	PARAMTYPE 9	VAR lNRetArr	AS Logical		OPTIONAL	DEFAULT .F.

	#IFNDEF TOP
		If TcIsConnected()
			lTop := !lTop
		Endif
	#ENDIF
	lTabSX2 := AliasInDic(cTabela)
	If !lTop .OR. Empty(cTabela) .OR. (lTabSX2 .AND. Len(cTabela) # 3) .OR. Len(aLstCmp) == 0
		Return aRet
	Endif
	If lNRetArr .AND. Len(aLstCmp) # 1
		lNRetArr := !lNRetArr
	Endif
	If lTabSX2
		aArea 	:= SaveArea1({cTabela})
		aEstru	:= (cTabela)->(dbStruct())
		dbSelectArea(cTabela)
		(cTabela)->(dbSetOrder(nIndice))
	Endif
	cQry := "SELECT "
	For ni := 1 to Len(aLstCmp)
		cQry += aLstCmp[ni] + IIf(ni < Len(aLstCmp),", "," ")
		//Caso entre os campos a listar exista alguma funcao de aglutinacao, acionar a condicao de agrupamento
		If aScan(aFuncAgl,{|x| At(x + "(",Upper(aLstCmp[ni])) > 0 .OR. At(x + " (",Upper(aLstCmp[ni])) > 0}) > 0
			lAgrupar := .T.
		Else
			lExCmpNAgl := .T.
		Endif
	Next ni
	If lTabSX2
		cQry += "FROM " + RetSQLName(cTabela) + " "
	Else
		cQry += "FROM " + AllTrim(cTabela) + " " 
	Endif
	If !lUsaDel
		cCriterio += "D_E_L_E_T_ = ' ' "
	Endif
	If !lNUsaFil
		cCriterio += "AND " + IIf(Substr(cTabela,1,1) == "S",Substr(cTabela,2,2),cTabela) + "_FILIAL = '" + xFilial(cTabela) + "' "
	Endif
	cCriterio += IIf(!Empty(cRestricao),IIf(!Empty(cCriterio),"AND ","") + cRestricao,"")
	If !Empty(cCriterio)
		cQry += "WHERE " + cCriterio + " "
	Endif
	//Tratamento de agrupamento
	If lAgrupar .AND. lExCmpNAgl
		cQry += "GROUP BY " 
		//Considerar apenas os campos que nao se utilizam de formulas de aglutinacao
		For ni := 1 to Len(aLstCmp)
			If aScan(aFuncAgl,{|x| At(x,Upper(aLstCmp[ni])) > 0}) == 0
				cQry += aLstCmp[ni] + IIf(ni < Len(aLstCmp),","," ")
			Endif
		Next ni	
		If Right(cQry,1) == ","
			cQry := Substr(cQry,1,Len(cQry) - 1) + " "
		Endif
	Endif
	If Empty(cOrder)
		If lTabSX2
			If !lAgrupar	
				cQry += "ORDER BY " + StrTran((cTabela)->(IndexKey()),"+"," ASC, ") + " ASC"
			Endif
		Endif
	Else
		cQry += "ORDER BY " + cOrder
	Endif
	dbUseArea(.T.,__cRDD,TcGenQry(,,cQry),cAliasT,.T.,.F.)
	If lFormata .AND. lTabSX2
		For ni := 1 to (cAliasT)->(FCount())
			If (nPos := aScan(aEstru,{|x| Upper(AllTrim(x[1])) == Upper(AllTrim((cAliasT)->(FieldName(ni))))})) > 0
				TcSetField(cAliasT,(cAliasT)->(FieldName(ni)),aEstru[nPos][2],aEstru[nPos][3],aEstru[nPos][4])
			Endif
		Next ni
	Endif
	(cAliasT)->(dbGoTop())
	If !(cAliasT)->(Eof())
		Do While !(cAliasT)->(Eof())
			If !lNRetArr
				aTMP := Array((cAliasT)->(FCount()))
				For ni := 1 to Len(aTMP)
					aTMP[ni] := (cAliasT)->(FieldGet(ni))
				Next ni
				aAdd(aRet,aTMP)
			Else
				aRet := (cAliasT)->(FieldGet(1))
				Exit
			Endif
			(cAliasT)->(dbSkip())
		EndDo
	Else
		If lNRetArr
			If lTabSX2 .AND. !Empty(Posicione("SX3",2,PadR((cAliasT)->(FieldName(1)),10),"X3_CAMPO"))
				aRet := CriaVar((cAliasT)->(FieldName(1)),.F.)
			Endif
		Endif
	Endif
	U_FecArTMP(cAliasT)
	If lTabSX2
		RestArea1(aArea)
	Endif

Return aRet

/*/{Protheus.doc} User Function FecArTMP
	Rotina para encerrar alias e arquivos temporarios criados a partir de uma query.
	@type  Function
	@author Pablo Gollan Carreras
	@since 04/02/2012
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function FecArTMP(cAlias)

	PARAMTYPE 0	VAR cAlias		AS Character	DEFAULT ""

	//U_ADINF009P('ADFATXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Funcao para execucao de query de pesquisa, devolvendo os dados formatados. Para busca de tab. unica c/ campos fora de indices.')

	If Empty(cAlias)
		Return Nil
	Endif
	If Select(cAlias) > 0
		dbSelectArea(cAlias)
		dbCloseArea()
		If File(cAlias + OrdBagExt())
			fErase(cAlias + OrdBagExt())
		Endif
		If File(cAlias + GetDbExtension())
			fErase(cAlias + GetDbExtension())
		Endif
	Endif

Return Nil

/*/{Protheus.doc} User Function RtPrxIDC
	Funcao para retornar o proximo numero de ID CNAB disponivel 
	@type  Function
	@author Pablo Gollan Carreras
	@since 04/02/2012
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/

// chamado 059415 - FWNM      - 05/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Ajuste na geração do E1_IDCNAB devido desativação das customizações antigas 
/*
User Function __RtPrxIDC(cPrefixo,cNum,cParcela,cTipTit,lInfo)

	Local cIDCNAB		    := CriaVar("E1_IDCNAB",.F.) 
	Local cIDCNABEx		    := ""
	Local aArea				:= SaveArea1({"SE1"})
	Local cChvRes			:= ""
	Local aTMP				:= {}
	Local cChave			:= ""
	Local cSGBD				:= Upper(AllTrim(TcGetDB()))
	Local ni				:= 0
	Local cLstC				:= ""
	Local cProcN			:= "[" + Upper(AllTrim(StrTran(ProcName(0),"U_",""))) + "] "
	Local lCompSE1			:= .T.
	Local lContinua			:= .T.
	Local nMaxTenta			:= 1000
	Local nTamID			:= TamSX3("E1_IDCNAB")[1]
	Local nSituaSX8  		:= GetSx8Len()

	PARAMTYPE 0	VAR cPrefixo	AS Character	OPTIONAL	DEFAULT Space(TamSX3("E1_PREFIXO")[1])
	PARAMTYPE 1	VAR cNum		AS Character	OPTIONAL	DEFAULT Space(TamSX3("E1_NUM")[1])
	PARAMTYPE 2	VAR cParcela	AS Character	OPTIONAL	DEFAULT Space(TamSX3("E1_PARCELA")[1])
	PARAMTYPE 3	VAR cTipTit		AS Character	OPTIONAL	DEFAULT Space(TamSX3("E1_TIPO")[1])
	PARAMTYPE 4	VAR lInfo		AS Logical		OPTIONAL	DEFAULT .F.

	//U_ADINF009P('ADFATXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Funcao para execucao de query de pesquisa, devolvendo os dados formatados. Para busca de tab. unica c/ campos fora de indices.')

	If PCount() # 5 .OR. Empty(cNum) .OR. Empty(cTipTit)
		ConOut(cProcN + "Erro de validação, sair.")
		Return cIDCNAB
	Endif
	cPrefixo	:= PadR(cPrefixo,TamSX3("E1_PREFIXO")[1])
	cNum		:= PadR(cNum,TamSX3("E1_NUM")[1])
	cParcela	:= PadR(cParcela,TamSX3("E1_PARCELA")[1])
	cTipTit		:= PadR(cTipTit,TamSX3("E1_TIPO")[1])
	cChave		:= xFilial("SE1") + cPrefixo + cNum + cParcela + cTipTit
	dbSelectArea("SE1")
	SE1->(dbSetOrder(1))	//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SE1->(dbSeek(cChave))
	If !SE1->(Found())
		ConOut(cProcN + "Titulo [" + cChave + "] nao encontrado")
		lCompSE1 := .F.
	Else
		//Verificar se o registro jah possui ID, caso possua retornar o ID consolidado, desde que nao haja duplicidade
		If !Empty(cIDCNABEx := SE1->E1_IDCNAB)
			If AllTrim(AllToChar(U_PesqBD("SE1",{"COUNT(DISTINCT E1_NUM)"},"E1_IDCNAB = '" + cIDCNABEx + "'",,,,.T.,,,.T.))) == "1"
				ConOut(cProcN + "Titulo [" + cChave + "] ja possui ID CNAB valido")
				RestArea1(aArea)
				Return cIDCNABEx
			Endif		
		Endif
	Endif
	//Determinar campo de retorno de acordo com o SGBD
	Do Case
		Case cSGBD $ "MSSQL|INFORMIX"
			cLstC := "E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO"
		Case cSGBD $ "ORACLE|POSTGRES"
			cLstC := "E1_FILIAL || E1_PREFIXO || E1_NUM || E1_PARCELA || E1_TIPO"
	EndCase
	SetMaxCode(20)
	ni := 0
	Do While lContinua
		If !lInfo .OR. ni == 0
			cIDCNAB	:= GetSXENum("SE1","E1_IDCNAB","E1_IDCNAB" + cEmpAnt,19)
			//Caso seja informativo, voltar o numero reservado
			If lInfo
				RollBackSX8()
			Endif
		Else
			cIDCNAB := Soma1(cIDCNAB,nTamID)
		Endif
		ConOut(cProcN + "Tentativa de uso do ID CNAB numero : " + cIDCNAB)
		//Verificar se o ID nao esta sendo utilizado por algum outro registro no SGBD
		If !Empty(aTMP := U_PesqBD("SE1",{cLstC},"E1_IDCNAB = '" + cIDCNAB + "'",19,,,.T.))
			ConOut(cProcN + "O ID CNAB [" + cIDCNAB + "] ja esta em uso no BD")
			//Verificar se o ID encontrado nao esta associado ao titulo em questao
			If lCompSE1 .AND. aScan(aTMP,{|x| x[1] == cChave}) == 0
				ConOut(cProcN + "O ID encontrado [" + cIDCNAB + "] esta associado ao titulo [" + cChave + "] e sera utilizado")
				lContinua := .F.
			Endif
			//Confirmar o numero sequencial
			If !lInfo
				ConfirmSX8()
			Endif
		Else
			//Caso nao exista o ID no BD, verificar se o ID jah nao foi reservado por outro processo concomitante		
			ConOut(cProcN + "O ID CNAB [" + cIDCNAB + "] nao foi encontrado do BD, reservar ID")
			cChvRes := cProcN + cIDCNAB
			If MayIUseCode(cChvRes)
				ConOut(cProcN + "O ID CNAB [" + cIDCNAB + "] foi reservado com sucesso")
				lContinua := .F.
				//Confirmar o numero sequencial
				If !lInfo
					ConfirmSX8()
				Endif
				//Liberar palavra reservada
				Leave1Code(cChvRes)
			Else
				ConOut(cProcN + "O ID CNAB [" + cIDCNAB + "] nao pode ser reservado, tentar outro ID")
				//Confirmar o numero sequencial
				If !lInfo
					ConfirmSX8()
				Endif
			Endif		
		Endif
		//Tratamento para o numero maximo de tentativas de obtencao do ID CNAB
		If ++ni >= nMaxTenta
			ConOut(cProcN + "O numero maximo de tentativas [" + cValToChar(nMaxTenta) + "] para se obter um novo ID CNAB foi excedida")
			If !IsBlind()
				If !ApMsgYesNo(Capital(AllTrim(UsrRetName(__cUserID))) + ", o número máximo de tentativas para obtenção de um novo ID CNAB foi excedido." + CRLF + ;
					"Deseja tentar novamente?")
					lContinua := .F.
					cIDCNAB := CriaVar("E1_IDCNAB",.F.)
				Else
					ni := 0
				Endif
			Endif
		Endif
	EndDo		
	//Caso esteja em modo informativo, voltar o sequencial a posicao original
	If lInfo
		Do While GetSx8Len() > nSituaSX8
			RollBackSX8()
		EndDo
	Endif
	RestArea1(aArea)

Return cIDCNAB
*/
//

/*/{Protheus.doc} User Function nomeFunction
	Alterar o tipo de dados de campos criados por querys de acordo com o seu tipo de dados declarado no dicionario.
	@type  Function
	@author Pablo Gollan Carreras
	@since 03/04/2012
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function AjustaTC(cAlias,aEstru)

	Local ni		:= 0
	Local nPos		:= 0

	//U_ADINF009P('ADFATXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Funcao para execucao de query de pesquisa, devolvendo os dados formatados. Para busca de tab. unica c/ campos fora de indices.')

	If Empty(cAlias) .OR. ValType(aEstru) # "A" .OR. Len(aEstru) == 0
		Return Nil
	Endif
	For ni := 1 to (cAlias)->(FCount())
		If (nPos := aScan(aEstru,{|x| AllTrim(x[1]) == AllTrim((cAlias)->(FieldName(ni)))})) # 0
			If aEstru[nPos][2] # "C"
				TcSetField(cAlias,aEstru[nPos][1],aEstru[nPos][2],aEstru[nPos][3],aEstru[nPos][4])
			Endif
		Endif
	Next ni

Return Nil
