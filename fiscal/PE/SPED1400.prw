#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} SPED1400
	@type  Function
	@author Abel Babini
	@since 18/05/2021
	@version 1
	@history Ticket TI      - Abel Babini - Ajuste na query causava error.log
	@history Ticket 18552   - Abel babini - 27/08/2021 - Ajuste para geração do DIPAM no SPED Fiscal filtrando notas de formulário próprio
	/*/
User Function SPED1400()

Local dDataDe       := ParamIXB[1] // Parametro data De
Local dDataAte      := ParamIXB[2] // Parametro data até
Local cFilDe        := ParamIXB[3] // Parametro Filial De
Local cFilAte       := ParamIXB[4] // Parametro Filial Até
Local aLisFil       := ParamIXB[5] // Lista de filiais selecionadas (Pergunta: Seleciona Filial = SIM)
Local aMyReg1400	:= {}               //  DADOS DO REGISTRO 1400
Local nPos			:= 1
Local _i			:= 0
Local cAliasQry		:= ""
Local cWhere		:= ""
Local cListaFl		:= ""
Local cCodMun		:= ""


//COMPRAS ***********
If Len(aLisFil) > 0
	For _i = 1 to Len(aLisFil)
		If cListaFl = ""
			cListaFl := "'"+aLisFil[_i][2]+"'"
		Else
			cListaFl := cListaFl+",'"+aLisFil[_i][2]+"'"
		Endif
	Next _i
	cWhere := "%D2_FILIAL IN ("+cListaFl+")%"
Else
	cWhere := "%D2_FILIAL BETWEEN '"+cFilDe+"' AND '"+cFilAte+"'%" //@history Ticket TI      - Abel Babini - Ajuste na query causava error.log
Endif

cAliasQry:=GetNextAlias()
		
BeginSql Alias cAliasQry
	SELECT	
			A1_EST		AS ESTADO,
			A1_COD_MUN  AS CODMUN,
			SUM(D2_TOTAL)	AS TOTAL,
			F09_CODIPM	AS CDIPAM
	FROM %table:SD2% SD2
	LEFT JOIN %table:SA1% SA1 ON
			SA1.A1_COD = SD2.D2_CLIENTE
		AND SA1.A1_LOJA = SD2.D2_LOJA
		AND SA1.%notDel%
	LEFT JOIN %table:F09% F09 ON
			F09.%notDel%
		AND F09_FILIAL = %xFilial:F09%
		AND F09_TES = D2_TES
		AND F09_UF = D2_EST
	WHERE %Exp:cWhere%  
		AND D2_FILIAL BETWEEN %Exp:cFilDe% AND %Exp:cFilAte%
		AND SD2.%notDel%
		AND D2_EMISSAO BETWEEN %Exp:dDataDe% AND %Exp:dDataAte%
		AND F09_CODIPM <> ''
	GROUP BY A1_EST, A1_COD_MUN, F09_CODIPM
	ORDER BY A1_EST, A1_COD_MUN, F09_CODIPM

EndSql

dbSelectArea(cAliasQry)

		
While !(cAliasQry)->(Eof())
	
	cCodMun := UfCodIBGE((cAliasQry)->ESTADO,.T.)+(cAliasQry)->CODMUN

		aAdd(aMyReg1400, {})
		aAdd (aMyReg1400[nPos], "1400")                           //01 - REG
		aAdd (aMyReg1400[nPos], (cAliasQry)->CDIPAM)              //02 - COD_ITEM_IPM  
		aAdd (aMyReg1400[nPos], cCodMun)                          //03 - MUN
		If  (cAliasQry)->CDIPAM = "SPDIPAM25"
			aAdd (aMyReg1400[nPos], 1)                            //04 - VALOR
		Else 
			aAdd (aMyReg1400[nPos], (cAliasQry)->TOTAL)           //04 - VALOR		
		Endif

		nPos := nPos + 1

	(cAliasQry)->(dbSkip())
END
(cAliasQry)->(dbCloseArea())


//VENDAS*****************
If Len(aLisFil) > 0
	cWhere := "%D1_FILIAL IN ("+cListaFl+")%"
Else
	cWhere := "%D1_FILIAL BETWEEN '"+cFilDe+"' AND '"+cFilAte+"'%" //@history Ticket TI      - Abel Babini - Ajuste na query causava error.log
Endif

cAliasQry:=GetNextAlias()

//Ticket 18552   - Abel babini - 27/08/2021 - Ajuste para geração do DIPAM no SPED Fiscal filtrando notas de formulário próprio
BeginSql Alias cAliasQry
 	SELECT	
			A2_EST		AS ESTADO,
			A2_COD_MUN  AS CODMUN,
			SUM(D1_TOTAL-D1_VALDESC)	AS TOTAL,
			F09_CODIPM	AS CDIPAM
	FROM %table:SD1% SD1
	LEFT JOIN %table:SA2% SA2 ON
			SA2.A2_COD = SD1.D1_FORNECE
		AND SA2.A2_LOJA = SD1.D1_LOJA
		AND SA2.%notDel%
	LEFT JOIN %table:F09% F09 ON
			F09.%notDel%
		AND F09_FILIAL = %xFilial:F09%
		AND F09_TES = D1_TES
		AND F09_UF = A2_EST
	WHERE %Exp:cWhere%  
		AND D1_FILIAL BETWEEN %Exp:cFilDe% AND %Exp:cFilAte%
		AND SD1.%notDel%
		AND D1_DTDIGIT BETWEEN %Exp:dDataDe% AND %Exp:dDataAte%
		AND D1_CF IN ('1101','1456')
		AND D1_FORMUL = 'S'
		AND F09_CODIPM <> ''
	GROUP BY A2_EST, A2_COD_MUN, F09_CODIPM
	ORDER BY A2_EST, A2_COD_MUN, F09_CODIPM

EndSql

dbSelectArea(cAliasQry)

		
While !(cAliasQry)->(Eof())
	
	cCodMun := UfCodIBGE((cAliasQry)->ESTADO,.T.)+(cAliasQry)->CODMUN

		aAdd(aMyReg1400, {})
		aAdd (aMyReg1400[nPos], "1400")                           //01 - REG
		aAdd (aMyReg1400[nPos], (cAliasQry)->CDIPAM)              //02 - COD_ITEM_IPM  
		aAdd (aMyReg1400[nPos], cCodMun)                          //03 - MUN
		If  (cAliasQry)->CDIPAM = "SPDIPAM25"
			aAdd (aMyReg1400[nPos], 1)                            //04 - VALOR
		Else 
			aAdd (aMyReg1400[nPos], (cAliasQry)->TOTAL)           //04 - VALOR		
		Endif

		nPos := nPos + 1

	(cAliasQry)->(dbSkip())
END
(cAliasQry)->(dbCloseArea())


Return aMyReg1400
