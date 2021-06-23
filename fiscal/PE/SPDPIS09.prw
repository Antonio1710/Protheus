#INCLUDE "TOPCONN.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} User Function SPDPIS09
	Ponto de Entrada para calcular o Crédito Presumido e gerar o registro F100 no SPED Contribuições.
	@type  Function
	@author Abel Babini Filho
	@since 25/03/2019
	@history Chamado n.018830 - OS n.       - Abel Babini - 25/03/2019 - Ponto de Entrada para calcular o Crédito Presumido e gerar o registro F100 no SPED Contribuições.
	@history Chamado n.048574 - OS n.       - Abel Babini - 15/04/2019 - Ajuste arredondamento Perc
	@history Chamado n.048575 - OS n.       - Abel Babini - 15/04/2019 - Relatório Cred Presumido
	@history Chamado n.049766 - OS n.       - Abel Babini - 10/06/2019 - Ajuste Campo Valor Contábil
	@history Chamado n.058111 - OS n.       - Abel Babini - 11/05/2020 - Considerar todo tipo de documento, retirando filtro que não incluia Devoluções e Beneficiamentos nos cálculos.
	@history Ticket  5029									  - Abel Babini - 13/11/2020 - Alterar campo Natureza da Base de Calculo de Crédito de 13 para 02
	/*/
User Function SPDPIS09()
Local aArea	:= GetArea()
Local aTotSai	:= {}
Local aTotEnt	:= {}
Local aTotSEmb	:= {}
Local aTotEntI	:= {}
Local nX		:= 0

Local _cFilial	:= PARAMIXB[1]
Local _dDataIni	:= MV_PAR01  
Local _dDataFim	:= MV_PAR02  
Local cNrLivro	:= MV_PAR03

Local aRetF100 := {}
Local aCrePresu  := {}
Local cCstPresE   := GetNewPar("MV_CSTPRES","62")
Local cCstPresI   := GetNewPar("MV_#CSTCPI","61")

Local cMVCoBCC   := GetNewPar("MV_#F100CB","02") //Ticket  5029									  - Abel Babini - 13/11/2020 - Alterar campo Natureza da Base de Calculo de Crédito de 13 para 02

Local cFilialMat		:= FWGETCODFILIAL //Busca código da filial da filial logada, pois este código será gravado nas tabelas da apuração.

//Verifica a Receita de Exportação
aTotSai   := U_F1SPresu(_dDataIni,_dDataFim,cNrLivro)
//Verifica as Compras
aTotEnt   := U_F1EPresu(_dDataIni,_dDataFim,cNrLivro)

//Verifica a Receita de Embutidos
aTotSEmb   := U_F1SCPrEm(_dDataIni,_dDataFim,cNrLivro)
//Verifica as Compras no Mercado Interno
aTotEntI   := U_F1ECPrIn(_dDataIni,_dDataFim,cNrLivro)

If aTotSai[1] > 0
	For nX := 1 to Len(aTotEnt)
		If !Empty(aTotEnt[nX,3])
		
			aCrePresu := U_F100CrPr(aTotSai,aTotEnt,_dDataFim, nX)  
			
			//QUERY PARA LOCALIZAR REGISTROS NA TABELA CL2. SE LOCALIZAR NÃO GRAVA DUPLICADO, POIS O P.E. É EXECUTADO DUAS VEZES.
     		_cPeriodo	:= Alltrim(Str(Year(_dDataIni)))+Alltrim(Strzero(Month(_dDataIni),2))	
			_cAliasCL2	:=	GetNextAlias()
			BeginSql alias _cAliasCL2

				SELECT 
					CL2.CL2_FILIAL, 
					CL2.CL2_PARTI, 
					CL2.CL2_LOJA, 
					CL2.CL2_DESCR, 
					LTRIM(STR(Year(CL2.CL2_PER)))+REPLICATE('0', 2 - LEN(Month(CL2.CL2_PER))) + LTrim(Month(CL2.CL2_PER))  AS CL2_PER
				FROM
					%Table:CL2% CL2
				WHERE
					CL2.CL2_FILIAL	= %xFilial:CL2% AND
					CL2.CL2_REG		= "F100" AND
					CL2.CL2_INDOP	= "0" AND
					CL2.CL2_PARTI	= %Exp:Substr(aCrePresu[11],1,6)% AND
					CL2.CL2_LOJA	= %Exp:aCrePresu[17]% AND
					CL2.CL2_ITEM	= %Exp:aCrePresu[12]% AND
					CL2.CL2_VLOPER	= %Exp:aCrePresu[8]% AND
					SUBSTRING(CL2.CL2_DESCR,1,9)			= %Exp:aCrePresu[14]% AND
					SUBSTRING(CL2.CL2_DESCR,10,3)			= %Exp:aCrePresu[15]% AND
					LTRIM(STR(Year(CL2.CL2_PER)))+REPLICATE('0', 2 - LEN(Month(CL2.CL2_PER))) + LTrim(Month(CL2.CL2_PER))	= %Exp:_cPeriodo% AND
					CL2.%NotDel%
			EndSql
			DbSelectArea (_cAliasCL2)
			(_cAliasCL2)->(DbGoTop ())
			_nRecCL2	:= 0//(_cAliasCL2)->(RecCount())
			Do While !(_cAliasCL2)->(eof())
				_nRecCL2 += 1
				Exit
			EndDo
			(_cAliasCL2)->(dbCloseArea())
			
			If _nRecCL2 = 0
				Aadd( aRetF100, { 	'F100' ,; 	// F100 - 01 - REG
								'0' ,; 			// F100 - 02 - IND_OPER ( 0 - Entrada, >0 - Saida )
								Substr(aCrePresu[11],1,6) ,;// F100 - 03 - COD_PART (Entrada= SA2->A2_COD, Saida= SA1->A1_COD)
								aCrePresu[12] ,;// F100 - 04 - COD_ITEM
								_dDataFim ,; 	// F100 - 05 - DT_OPER
								aCrePresu[8] ,; // F100 - 06 - VL_OPER
								cCstPresE ,; 	// F100 - 07 - CST_PIS
								aCrePresu[8] ,; // F100 - 08 - VL_BC_PIS
								aCrePresu[9] ,; // F100 - 09 - ALIQ_PIS
								aCrePresu[1] ,; // F100 - 10 - VL_PIS
								cCstPresE ,; 	// F100 - 11 - CST_COFINS
								aCrePresu[8] ,; // F100 - 12 - VL_BC_COFINS
								aCrePresu[10] ,;// F100 - 13 - ALIQ_COFINS
								aCrePresu[2] ,; // F100 - 14 - VL_COFINS
								cMVCoBCC ,; 		// F100 - 15 - NAT_BC_CRED //Ticket  5029									  - Abel Babini - 13/11/2020 - Alterar campo Natureza da Base de Calculo de Crédito de 13 para 02
								aCrePresu[13] ,;// F100 - 16 - IND_ORIG_CRED
								aCrePresu[18] ,;// F100 - 17 - COD_CTA
								'' ,; 			// F100 - 18 - COD_CCUS
								aCrePresu[14]+aCrePresu[15]+aCrePresu[5] ,; // F100 - 19 - DESC_DOC_OPER
								aCrePresu[17] ,;// F100 - 20 - LOJA (Entarada = SA2->A2_LOJA, Saida = SA1->A1_LOJA)
								'' ,; 			// F100 - 21 - INDICE DE CUMULATIVIDADE( 0 - Cumulativo, 1 - Nao cumultivo )
								'' ,; 			// 0150 - 02 - COD_PART
								'' ,; 			// 0150 - 03 - NOME
								'' ,; 			// 0150 - 04 - COD_PAIS
								'' ,; 			// 0150 - 05 - CNPJ
								'' ,; 			// 0150 - 06 - CPF
								'' ,; 			// 0150 - 07 - IE
								'' ,; 			// 0150 - 08 - COD_MUN
								'' ,; 			// 0150 - 09 - SUFRAMA
								'' ,; 			// 0150 - 10 - END
								'' ,; 			// 0150 - 11 - NUM
								'' ,; 			// 0150 - 12 - COMPL
								'' ,; 			// 0150 - 13 - BAIRRO
								ctod("//"),; 	// 0500 - 02 - DT_ALT
								'' ,; 			// 0500 - 03 - COD_NAT_CC
								'' ,; 			// 0500 - 04 - IND_CTA
								'' ,; 			// 0500 - 05 - NIVEL
								'' ,; 			// 0500 - 06 - COD_CTA
								'' ,; 			// 0500 - 07 - NOME_CTA
								'' ,; 			// 0500 - 08 - COD_CTA_REF
								'' ,; 			// 0500 - 09 - CNPJ_EST
								'' ,; 			//Codigo da tabela da Natureza da Receita.
								'' ,; 			//Codigo da Natureza da Receita
								'' ,; 			//Grupo da Natureza da Receita
								ctod("//") ,; 	//Dt.Fim Natureza da Receita
								'' ,; 			// 0600 - 02 - DT_ALT
								'' ,; 			// 0600 - 03 - COD_CCUS
								'',; 			// 0600 - 04 - CCUS
								'SA2' }) 		// SA1 para considerar cadastro de cliente, ou SA2 para considerar cadastro de Fornecedor
			Endif
		EndIf
	Next nX
EndIf

//AS ROTINAS A SEGUIR SÃO PARA CALCULAR O REGISTRO F100 REFERENTE AO CREDITO PRESUMIDO DA LEI 10.925/2004 (MERCADO INTERNO) DOS INSUMOS
//APLICADOS À PRODUÇÃO DE EMBUTIDOS

If aTotSEmb[1]>0
	For nX := 1 to Len(aTotEntI)
		
		If !Empty(aTotEntI[nX,3])
		
			aCrePresu := U_F100CPrI(aTotSEmb,aTotEntI,_dDataFim, nX)  
     		
     		//QUERY PARA LOCALIZAR REGISTROS NA TABELA CL2. SE LOCALIZAR NÃO GRAVA DUPLICADO, POIS O P.E. É EXECUTADO DUAS VEZES.
     		_cPeriodo	:= Alltrim(Str(Year(_dDataIni)))+Alltrim(Strzero(Month(_dDataIni),2))	
			_cAliasCL2	:=	GetNextAlias()
			BeginSql alias _cAliasCL2

				SELECT 
					CL2.CL2_FILIAL, 
					CL2.CL2_PARTI, 
					CL2.CL2_LOJA, 
					CL2.CL2_DESCR, 
					LTRIM(STR(Year(CL2.CL2_PER)))+REPLICATE('0', 2 - LEN(Month(CL2.CL2_PER))) + LTrim(Month(CL2.CL2_PER))  AS CL2_PER
				FROM
					%Table:CL2% CL2
				WHERE
					CL2.CL2_FILIAL	= %xFilial:CL2% AND
					CL2.CL2_REG		= "F100" AND
					CL2.CL2_INDOP	= "0" AND
					CL2.CL2_PARTI	= %Exp:Substr(aCrePresu[11],1,6)% AND
					CL2.CL2_LOJA	= %Exp:aCrePresu[17]% AND
					CL2.CL2_ITEM	= %Exp:aCrePresu[12]% AND
					CL2.CL2_VLOPER	= %Exp:aCrePresu[8]% AND
					SUBSTRING(CL2.CL2_DESCR,1,9)			= %Exp:aCrePresu[14]% AND
					SUBSTRING(CL2.CL2_DESCR,10,3)			= %Exp:aCrePresu[15]% AND
					LTRIM(STR(Year(CL2.CL2_PER)))+REPLICATE('0', 2 - LEN(Month(CL2.CL2_PER))) + LTrim(Month(CL2.CL2_PER))	= %Exp:_cPeriodo% AND
					CL2.%NotDel%
			EndSql
			DbSelectArea (_cAliasCL2)
			(_cAliasCL2)->(DbGoTop ())
			_nRecCL2	:= 0//(_cAliasCL2)->(RecCount())
			Do While !(_cAliasCL2)->(eof())
				_nRecCL2 += 1
				Exit
			EndDo
			(_cAliasCL2)->(dbCloseArea())
			
			If _nRecCL2 = 0
				Aadd( aRetF100, { 	'F100' ,; 	// F100 - 01 - REG
								'0' ,; 			// F100 - 02 - IND_OPER ( 0 - Entrada, >0 - Saida )
								Substr(aCrePresu[11],1,6) ,;// F100 - 03 - COD_PART (Entrada= SA2->A2_COD, Saida= SA1->A1_COD)
								aCrePresu[12] ,;// F100 - 04 - COD_ITEM
								_dDataFim ,; 	// F100 - 05 - DT_OPER
								aCrePresu[8] ,; // F100 - 06 - VL_OPER
								cCstPresI ,; 	// F100 - 07 - CST_PIS
								aCrePresu[8] ,; // F100 - 08 - VL_BC_PIS
								aCrePresu[9] ,; // F100 - 09 - ALIQ_PIS
								aCrePresu[1] ,; // F100 - 10 - VL_PIS
								cCstPresI ,; 	// F100 - 11 - CST_COFINS
								aCrePresu[8] ,; // F100 - 12 - VL_BC_COFINS
								aCrePresu[10] ,;// F100 - 13 - ALIQ_COFINS
								aCrePresu[2] ,; // F100 - 14 - VL_COFINS
								cMVCoBCC ,; 		// F100 - 15 - NAT_BC_CRED //Ticket  5029									  - Abel Babini - 13/11/2020 - Alterar campo Natureza da Base de Calculo de Crédito de 13 para 02
								aCrePresu[13] ,;// F100 - 16 - IND_ORIG_CRED
								aCrePresu[18] ,;// F100 - 17 - COD_CTA
								'' ,; 			// F100 - 18 - COD_CCUS
								aCrePresu[14]+aCrePresu[15]+aCrePresu[5] ,; // F100 - 19 - DESC_DOC_OPER
								aCrePresu[17] ,;// F100 - 20 - LOJA (Entarada = SA2->A2_LOJA, Saida = SA1->A1_LOJA)
								'' ,; 			// F100 - 21 - INDICE DE CUMULATIVIDADE( 0 - Cumulativo, 1 - Nao cumultivo )
								'' ,; 			// 0150 - 02 - COD_PART
								'' ,; 			// 0150 - 03 - NOME
								'' ,; 			// 0150 - 04 - COD_PAIS
								'' ,; 			// 0150 - 05 - CNPJ
								'' ,; 			// 0150 - 06 - CPF
								'' ,; 			// 0150 - 07 - IE
								'' ,; 			// 0150 - 08 - COD_MUN
								'' ,; 			// 0150 - 09 - SUFRAMA
								'' ,; 			// 0150 - 10 - END
								'' ,; 			// 0150 - 11 - NUM
								'' ,; 			// 0150 - 12 - COMPL
								'' ,; 			// 0150 - 13 - BAIRRO
								ctod("//"),; 	// 0500 - 02 - DT_ALT
								'' ,; 			// 0500 - 03 - COD_NAT_CC
								'' ,; 			// 0500 - 04 - IND_CTA
								'' ,; 			// 0500 - 05 - NIVEL
								'' ,; 			// 0500 - 06 - COD_CTA
								'' ,; 			// 0500 - 07 - NOME_CTA
								'' ,; 			// 0500 - 08 - COD_CTA_REF
								'' ,; 			// 0500 - 09 - CNPJ_EST
								'' ,; 			//Codigo da tabela da Natureza da Receita.
								'' ,; 			//Codigo da Natureza da Receita
								'' ,; 			//Grupo da Natureza da Receita
								ctod("//") ,; 	//Dt.Fim Natureza da Receita
								'' ,; 			// 0600 - 02 - DT_ALT
								'' ,; 			// 0600 - 03 - COD_CCUS
								'',; 			// 0600 - 04 - CCUS
								'SA2' }) 		// SA1 para considerar cadastro de cliente, ou SA2 para considerar cadastro de Fornecedor
			Endif
		EndIf
	Next nX
Endif

RestArea(aArea)
Return aRetF100

/*/{Protheus.doc} User Function F100CPrI
	Calcula o Crédito Presumido da Lei 10.925/2004 - Mercado Interno Monta array com as Notas e valores calculados do Cred. Presumido
	@type  Function
	@author Abel Babini
	@since 25/03/2019
	/*/
User Function F100CPrI(aVlrRec,aVlrCompra,dDataAte,nX)
	Local nAlqPis		:= 0
	Local nAlqCof		:= 0
	Local nValPis		:= 0
	Local nValCof		:= 0
	Local nPerEmb	:= 0
	Local nBaseCalc	:= 0
	Local nValRec1	:= 0
	Local nValRec2	:= 0
	Local nValComp	:= 0
	Local aRetorno		:= {0,0,"","","","","",0,0,0,"","","","","","","","","","","","","",0}
	Local cCodAjust		:= GetNewPar("MV_CAJCPPC","03")
	Local cNumProc		:= GetNewPar("MV_#INCPMI","Lei 10.925/2004 art. 08")
	Local cDescr		:= cNumProc
	Local aAliquota		:= GetNewPar("MV_#ACPPCI",	{ 0.99 , 4.56 })
	//Local aAliquota		:= GetNewPar("MV_#ACPPCI",	{ { 0.99 , 4.56 } , { 0.5775 , 2.66 } , { 0,495 , 2.28 } })
	
	aAliquota   		:= Iif (Len(aAliquota) > 1,&(aAliquota),aAliquota)
	nAlqPis				:= aAliquota[1]
	nAlqCof				:= aAliquota[2]
	
	//Faz regra de 3 para descobrir o percentual de Embutidos
	nPerEmb	:= Round((aVlrRec[1] * 100) / aVlrRec[2],2) //Abel Babini-15/04/2019-Ch.048574|Ajuste arredondamento Perc
	
	//Aplica o percentual no total de compra de gado, para saber qual a base de cálculo
	nBaseCalc	:= Round((aVlrCompra[nX,1] * nPerEmb) /100,2)
	
	//Cálculo dos valores de créditos.
	nValPis		:= Round((nBaseCalc * nAlqPis ) /100,2)
	nValCof 	:= Round((nBaseCalc * nAlqCof ) /100,2)
	
	aRetorno[1]  := nValPis  		//Valor de crédito de PIS
	aRetorno[2]  := nValCof  	 	//Valor de crédito de Cofins
	aRetorno[3]  := "1" 				//Indicador de ajuste de acréscimo
	aRetorno[4]  := cCodAjust	 	//Código do Ajuste
	aRetorno[5]  := cNumProc 		//Número do processo
	aRetorno[6]  := cDescr    		//Descrição
	aRetorno[7]  := dDataAte  		//Data
	aRetorno[8]  := nBaseCalc
	aRetorno[9]  := nAlqPis
	aRetorno[10] := nAlqCof
	aRetorno[11] := aVlrCompra[nX,2] // Código do fornecedor
	aRetorno[12] := aVlrCompra[nX,3] //Código do produto  
	aRetorno[13] := aVlrCompra[nX,4] //Origem do crédito
	aRetorno[14] := aVlrCompra[nX,5] //Codigo Nota fiscal
	aRetorno[15] := aVlrCompra[nX,6] //Serie Nota Fiscal    
	aRetorno[16] := aVlrCompra[nX,7] //Código do cliente/fornecedor
	aRetorno[17] := aVlrCompra[nX,8] //Loja do cliente fornecedor
	aRetorno[18] := aVlrCompra[nX,9] //Conta Contábil do Produto - SFT

	//INICIO Abel Babini-15/04/2019-Ch.048575|Relatório Cred Presumido 
	aRetorno[19] := aVlrCompra[nX,10] //Data Entrada Doc. Fiscal
	aRetorno[20] := aVlrCompra[nX,11] //Nome Fornecedor
	aRetorno[21] := aVlrCompra[nX,12] //Descrição Produto
	aRetorno[22] := aVlrCompra[nX,13] //CFOP
	aRetorno[23] := aVlrCompra[nX,14] //NCM
	//FIM Abel Babini-15/04/2019-Ch.048575|Relatório Cred Presumido 

	//INICIO Abel Babini-10/06/2019-Ch.049766|Ajuste Campo Valor Contábil
	aRetorno[24] := aVlrCompra[nX,1] //NCM
	//FIM Abel Babini-10/06/2019-Ch.049766|Ajuste Campo Valor Contábil

Return aRetorno

/*/{Protheus.doc} User Function F1SPresu
	Calcula o valor das Receitas no Mercado Externo e Valor Total para encontrar o percentual das Receitas de Exportação (Rateio)
	@type  Function
	@author Abel Babini
	@since 25/03/2019
	/*/
User Function F1SPresu(dDataDe,dDataAte,cNrLivro)
	Local aArea		:= GetArea()
	Local cAliasSFT	:= "SFT"
	Local aRetorno	:= {0,0}
	Local cFiltro 	:= ""
	Local cCampos 	:= ""
	Local aCFOPs	:= XFUNCFRec() // Funcao que retorna array com CFOPS / [1]-Considera Receita / [2]-NAO considera como Receita
	Local aNCMS		:= GetNewPar('MV_NCMCPPC',"") // Saída - Exportação
	Local cCFRExp	:= GetNewPar('MV_#CPRCEP',"7101|7102|7105") // CFOP Receita de Exportação
	Local cNCMRTo	:= GetNewPar("MV_#NCMCPR","0207,")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta um array com os códigos NCMs que serão considerados como exportação para percentual do cálculo da base de cálculo de crédito Presumido.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aNCMS   			:= Iif (Len(aNCMS) > 1,&(aNCMS),aNCMS)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄV¿
	//³Irá trazer valores de receitas para totalizar percentual de receita de exportação, para calcular crédito presumido.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄVÙ
	
	//DbSelectArea(cAliasSFT)
	//(cAliasSFT)->(DbSetOrder (2))
	
	cAliasSFT	:=	GetNextAlias()

	cFiltro := "%"

	If (cNrLivro<>"*")
		cFiltro += " SFT.FT_NRLIVRO = '" +%Exp:cNrLivro% +"' AND "
	EndiF

	cFiltro += "%"
	cCampos := "%"

	BeginSql Alias cAliasSFT

		COLUMN FT_EMISSAO AS DATE
    	COLUMN FT_ENTRADA AS DATE
    	COLUMN FT_DTCANC AS DATE

		SELECT
			SUM(SFT.FT_VALCONT)-SUM(SFT.FT_FRETE) FT_VALCONT , SFT.FT_ESPECIE, SFT.FT_CFOP , SFT.FT_PRODUTO, SFT.FT_CSTPIS, SFT.FT_CSTCOF, SFT.FT_POSIPI
			%Exp:cCampos%
		FROM
			%Table:SFT% SFT
			LEFT JOIN %Table:SB1% SB1 ON(SB1.B1_FILIAL=%xFilial:SB1%  AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.%NotDel%)
		WHERE
			SFT.FT_TIPOMOV = 'S' AND
			SFT.FT_ENTRADA>=%Exp:dDataDe% AND
			SFT.FT_ENTRADA<=%Exp:dDataAte% AND
			SFT.FT_DTCANC = ' ' AND
			SFT.FT_TIPO NOT IN ('D') AND
			%Exp:cFiltro%
			SFT.%NotDel%

		GROUP BY SFT.FT_ESPECIE, SFT.FT_CFOP, SFT.FT_PRODUTO, SFT.FT_POSIPI, SFT.FT_CSTPIS, SFT.FT_CSTCOF

		ORDER BY SFT.FT_CFOP

	EndSql
	//@history Chamado Interno  - OS n.       - Abel Babini - 11/05/2020 - Considerar todo tipo de documento, retirando filtro que não incluia Devoluções e Beneficiamentos nos cálculos.
	//SFT.FT_TIPO NOT IN ('D','B') AND

	DbSelectArea (cAliasSFT)
	(cAliasSFT)->(DbGoTop ())
	_nRegSFT := (cAliasSFT)->(RecCount ())
	ProcRegua (_nRegSFT)
	(cAliasSFT)->(DbGoTop ())
	
	Do While !(cAliasSFT)->(Eof ())

		cEspecie	:=	AModNot ((cAliasSFT)->FT_ESPECIE)		//Modelo NF

		If cEspecie$"  " .Or. ( (AllTrim((cAliasSFT)->FT_CFOP)$aCFOPs[01])	.AND. !(AllTrim((cAliasSFT)->FT_CFOP)$aCFOPs[02]) ) .And. uNCMCPPC((cAliasSFT)->FT_POSIPI, aNCMS)// Verifica se o CFOP é gerador de receita
      
				//If Alltrim((cAliasSFT)->FT_CFOP) $ '7101|7102|7105'
				If Alltrim((cAliasSFT)->FT_CFOP) $ cCFRExp
					//Acumula valor de receita exportação
					 aRetorno[1] += (cAliasSFT)->FT_VALCONT
					 aRetorno[2] += (cAliasSFT)->FT_VALCONT	
				Endif
				//If Substr(Alltrim((cAliasSFT)->FT_POSIPI),1,4) $ '0207' .and. Alltrim((cAliasSFT)->FT_CSTPIS) == '06'
				If Substr(Alltrim((cAliasSFT)->FT_POSIPI),1,4) $ cNCMRTo .and. Alltrim((cAliasSFT)->FT_CSTPIS) == '06'
					//Acumula valor de receita total
				    aRetorno[2] += (cAliasSFT)->FT_VALCONT
			    Endif		   
			
		EndIf
   
		(cAliasSFT)->(DbSkip ())
	EndDo

	DbSelectArea (cAliasSFT)
	(cAliasSFT)->(DbCloseArea ())

	cAliasSFT	:=	"SFT"
	RestArea(aArea)
Return aRetorno

/*/{Protheus.doc} User Function F1EPresu
	Seleciona as NF de Entrada referente as Compras no Mercado	com direito a Credito Presumido sobre as Exportações
	@type  Function
	@author Abel Babini
	@since 25/03/2019
	/*/
User Function F1EPresu(dDataDe,dDataAte,cNrLivro)
	Local cAliasSFT 	:= "SFT"
	Local aRetorno 	:= {}
	Local cFiltro 	:= ""
	Local cCampos 	:= ""
	Local nPos			:= 0
	Local aNCME		:= GetNewPar('MV_NCMCREP',"{}")
	Local cCFOPs    := GetNewPar('MV_#CFCPEX',"1101,1118,1122,2101,2118,2122") 

	cCFOP		:= FormatIn(cCFOPs,",")
	//Monta um array com os códigos NCMs que serão considerados como exportação para percentual do cálculo da base de cálculo de crédito Presumido.
	aNCME   			:= Iif (Len(aNCME) > 1,&(aNCME),aNCME)

	//A querry irá trazer o valor de compra para montar a base de cálculo, para gerar valor de crédito presumido.
	//DbSelectArea (cAliasSFT)
	//(cAliasSFT)->(DbSetOrder (2))
	
	cAliasSFT	:=	GetNextAlias()

	cFiltro := "%"

	If (cNrLivro<>"*")
		cFiltro += " SFT.FT_NRLIVRO = '" +%Exp:cNrLivro% +"' AND "
	EndiF

	If Len(cCFOP) > 0
		cFiltro += " SFT.FT_CFOP IN "+%Exp:cCFOP% + " AND "
	Endif
	
	cFiltro += "%"
	cCampos := "%"

	BeginSql Alias cAliasSFT

		COLUMN FT_EMISSAO AS DATE
    	COLUMN FT_ENTRADA AS DATE
    	COLUMN FT_DTCANC AS DATE

		SELECT
			SUM(SFT.FT_VALCONT) FT_VALCONT , SFT.FT_CLIEFOR, SFT.FT_LOJA, SFT.FT_PRODUTO, SFT.FT_CONTA, SFT.FT_POSIPI, SFT.FT_CFOP, SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_ENTRADA, SA2.A2_NOME, SB1.B1_DESC // Abel Babini-15/04/2019-Ch.048575|Relatório Cred Presumido
			%Exp:cCampos%
		FROM
			%Table:SFT% SFT
		LEFT JOIN %Table:SB1% SB1 ON(SB1.B1_FILIAL=%xFilial:SB1%  AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.%NotDel%)
		LEFT JOIN %Table:SA2% SA2 ON(SA2.A2_FILIAL=%xFilial:SA2%  AND SA2.A2_COD=SFT.FT_CLIEFOR AND SA2.A2_LOJA=SFT.FT_LOJA AND SA2.%NotDel%)	// Abel Babini-15/04/2019-Ch.048575|Relatório Cred Presumido
		WHERE
			SFT.FT_FILIAL=%xFilial:SFT% AND
			SFT.FT_TIPOMOV = 'E' AND
			SFT.FT_ENTRADA>=%Exp:dDataDe% AND
			SFT.FT_ENTRADA<=%Exp:dDataAte% AND
			SFT.FT_TIPO NOT IN ('D','B','I') AND
			(SFT.FT_DTCANC = ' ' OR SFT.FT_DTCANC > %Exp:dDataAte% )  AND
			%Exp:cFiltro%
			SFT.%NotDel%

		GROUP BY SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLIEFOR,SFT.FT_LOJA, SFT.FT_PRODUTO, SFT.FT_CONTA, SFT.FT_POSIPI, FT_CFOP, SFT.FT_ENTRADA, SA2.A2_NOME, SB1.B1_DESC // Abel Babini-15/04/2019-Ch.048575|Relatório Cred Presumido

		ORDER BY SFT.FT_NFISCAL

	EndSql

	DbSelectArea (cAliasSFT)
	(cAliasSFT)->(DbGoTop ())
	nRegcSFT := (cAliasSFT)->(RecCount())

	ProcRegua (nRegcSFT)
	(cAliasSFT)->(DbGoTop ())
	
	Do While !(cAliasSFT)->(Eof()) 
		If uNCMCPPC((cAliasSFT)->FT_POSIPI, aNCME)
		
			If !ASCAN(aRetorno,{|X|X[3]== (cAliasSFT)->FT_PRODUTO .And. X[2] == (cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA .AND.;
				                            X[5] == (cAliasSFT)->FT_NFISCAL .AND. X[6] == (cAliasSFT)->FT_SERIE }) > 0

				AADD(aRetorno,{})
				nPos := Len(aRetorno)
				AADD(aRetorno[nPos], (cAliasSFT)->FT_VALCONT)  
				AADD(aRetorno[nPos], (cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA) 
				AADD(aRetorno[nPos], (cAliasSFT)->FT_PRODUTO)
				If SubStr((cAliasSFT)->FT_CFOP,1,1) > '2'
				    AADD(aRetorno[nPos], '1') // Crédito originário do Mercado externo
				Else
				    AADD(aRetorno[nPos], '0') // Crédito originário do Mercado interno
				EndIf
				AADD(aRetorno[nPos], (cAliasSFT)->FT_NFISCAL)
				AADD(aRetorno[nPos], (cAliasSFT)->FT_SERIE)					 
				AADD(aRetorno[nPos], (cAliasSFT)->FT_CLIEFOR)
				AADD(aRetorno[nPos], (cAliasSFT)->FT_LOJA)
				AADD(aRetorno[nPos], (cAliasSFT)->FT_CONTA)
				//INICIO Abel Babini-15/04/2019-Ch.048575|Relatório Cred Presumido
				AADD(aRetorno[nPos], (cAliasSFT)->FT_ENTRADA)
				AADD(aRetorno[nPos], (cAliasSFT)->A2_NOME)
				AADD(aRetorno[nPos], (cAliasSFT)->B1_DESC)
				AADD(aRetorno[nPos], (cAliasSFT)->FT_CFOP)
				AADD(aRetorno[nPos], (cAliasSFT)->FT_POSIPI)
				//FIM Abel Babini-15/04/2019-Ch.048575|Relatório Cred Presumido
			Else
			       aRetorno[LEN(aRetorno), 1] += (cAliasSFT)->FT_VALCONT					
			EndIf
		Endif
		(cAliasSFT)->(DbSkip ())
	EndDo

	DbSelectArea (cAliasSFT)
	(cAliasSFT)->(DbCloseArea ())
	
Return aRetorno

/*/{Protheus.doc} User Function F100CrPr
	Monta o array que será utilizado na montagem do registro F100 com as informações de Documento Fiscal e valores Merc. Externo
	@type  Function
	@author Abel Babini
	@since 25/03/2019
	/*/
User Function F100CrPr(aVlrRec,aVlrCompra,dDataAte,nX)
	Local nAlqPis		:= 0
	Local nAlqCof		:= 0
	Local nValPis		:= 0
	Local nValCof		:= 0
	Local nPerExport	:= 0
	Local nBaseCalc	:= 0
	Local nValRec1	:= 0
	Local nValRec2	:= 0
	Local nValComp	:= 0
	Local aRetorno		:= {0,0,"","","","","",0,0,0,"","","","","","","","","","","","","",0}
	Local cCodAjust		:= GetNewPar("MV_CAJCPPC","03")
	Local cNumProc		:= GetNewPar("MV_DAPCCPA","Instrução Normativa nº 1157/2011")
	Local cDescr		:= cNumProc
	Local aAliquota		:= GetNewPar("MV_ACPPCAG",{0.495,2.28})
	
	aAliquota   		:= Iif (Len(aAliquota) > 1,&(aAliquota),aAliquota)
	nAlqPis				:= aAliquota[1]
	nAlqCof				:= aAliquota[2]
	
	//Faz regra de 3 para descobrir o percentual de exportação
	nPerExport	:= Round((aVlrRec[1] * 100) / aVlrRec[2],2)
	
	//Aplica o percentual no total de compra de gado, para saber qual a base de cálculo
	nBaseCalc	:= Round((aVlrCompra[nX,1] * nPerExport) /100,2) //Abel Babini-15/04/2019-Ch.048574|Ajuste arredondamento Perc 

	//Cálculo dos valores de créditos.
	
	nValPis		:= Round((nBaseCalc * nAlqPis ) /100,2)
	nValCof 	:= Round((nBaseCalc * nAlqCof ) /100,2)
	
	aRetorno[1]  := nValPis  		//Valor de crédito de PIS
	aRetorno[2]  := nValCof  	 	//Valor de crédito de Cofins
	aRetorno[3]  := "1" 				//Indicador de ajuste de acréscimo
	aRetorno[4]  := cCodAjust	 	//Código do Ajuste
	aRetorno[5]  := cNumProc 		//Número do processo
	aRetorno[6]  := cDescr    		//Descrição
	aRetorno[7]  := dDataAte  		//Data
	aRetorno[8]  := nBaseCalc
	aRetorno[9]  := nAlqPis
	aRetorno[10] := nAlqCof
	aRetorno[11] := aVlrCompra[nX,2] // Código do fornecedor
	aRetorno[12] := aVlrCompra[nX,3] //Código do produto  
	aRetorno[13] := aVlrCompra[nX,4] //Origem do crédito
	aRetorno[14] := aVlrCompra[nX,5] //Codigo Nota fiscal
	aRetorno[15] := aVlrCompra[nX,6] //Serie Nota Fiscal    
	aRetorno[16] := aVlrCompra[nX,7] //Código do cliente/fornecedor
	aRetorno[17] := aVlrCompra[nX,8] //Loja do cliente fornecedor
	aRetorno[18] := aVlrCompra[nX,9] //Conta Contábil do Produto - SFT
	
	//INICIO Abel Babini-15/04/2019-Ch.048575|Relatório Cred Presumido 
	aRetorno[19] := aVlrCompra[nX,10] //Data Entrada Doc. Fiscal
	aRetorno[20] := aVlrCompra[nX,11] //Nome Fornecedor
	aRetorno[21] := aVlrCompra[nX,12] //Descrição Produto
	aRetorno[22] := aVlrCompra[nX,13] //CFOP
	aRetorno[23] := aVlrCompra[nX,14] //NCM
	//FIM Abel Babini-15/04/2019-Ch.048575|Relatório Cred Presumido 
	
	//INICIO Abel Babini-10/06/2019-Ch.049766|Ajuste Campo Valor Contábil
	aRetorno[24] := aVlrCompra[nX,1]
	//FIM Abel Babini-10/06/2019-Ch.049766|Ajuste Campo Valor Contábil
Return aRetorno

/*/{Protheus.doc} User Function uNCMCPPC
	Verifica se o NCM do item do Documento Fiscal está dentro dos parâmetros definidos e passados para a rotina.
	@type  Function
	@author Abel Babini
	@since 25/03/2019
	/*/
Static Function uNCMCPPC(cNcm, aNCM)
	Local nPos		:= 0
	Local lRet		:= .F.
	
	Default cNcm  := ""
	Default aNCM  := {}
	
	//Irá fazer for para verificar todos NCMs
	
	For nPos := 1 to len(aNCM)
		
		IF aNCM[nPos] $ Alltrim(Substr(cNcm,1,4))
			lRet := .T.
			exit
		EndIf
	Next nPos
Return(lRet)

/*/{Protheus.doc} User Function F1SCPrEm
	Calcula o valor das Receitas dos produtos Embutidos e Vl. Total para encontrar o percentual das Receitas de Embutidos (Rateio)
	@type  Function
	@author Abel Babini
	@since 25/03/2019
	/*/
User Function F1SCPrEm(dDataDe,dDataAte,cNrLivro)
	Local aArea	:= GetArea()
	Local cAliasSFT 	:= "SFT"
	Local aRetorno 	:= {0,0}
	Local cFiltro 	:= ""
	Local cCampos 	:= ""
	Local aCFOPs	:= XFUNCFRec() // Funcao que retorna array com CFOPS / [1]-Considera Receita / [2]-NAO considera como Receita
	Local cNCMEmb	:= GetNewPar("MV_#NCMEMB","1601,1602")
	Local cNCMRTo	:= GetNewPar("MV_#NCMCPR","0207,")

	//Irá trazer valores de receitas para totalizar percentual de receita de exportação, para calcular crédito presumido.
	//DbSelectArea (cAliasSFT)
	//(cAliasSFT)->(DbSetOrder (2))
	
	cAliasSFT	:=	GetNextAlias()

	cFiltro := "%"

	If (cNrLivro<>"*")
		cFiltro += " SFT.FT_NRLIVRO = '" +%Exp:cNrLivro% +"' AND "
	EndiF

	cFiltro += "%"
	cCampos := "%"

	BeginSql Alias cAliasSFT

		COLUMN FT_EMISSAO AS DATE
    	COLUMN FT_ENTRADA AS DATE
    	COLUMN FT_DTCANC AS DATE

		SELECT
			SUM(SFT.FT_VALCONT)-SUM(SFT.FT_ICMSRET) FT_VALCONT , SFT.FT_ESPECIE, SFT.FT_CFOP , SFT.FT_PRODUTO, SFT.FT_CSTPIS, SFT.FT_CSTCOF, SFT.FT_POSIPI 
			%Exp:cCampos%
		FROM
			%Table:SFT% SFT
			LEFT JOIN %Table:SB1% SB1 ON(SB1.B1_FILIAL=%xFilial:SB1%  AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.%NotDel%)
		WHERE
			SFT.FT_TIPOMOV = 'S' AND
			SFT.FT_ENTRADA>=%Exp:dDataDe% AND
			SFT.FT_ENTRADA<=%Exp:dDataAte% AND
			SFT.FT_DTCANC = ' ' AND
			SFT.FT_TIPO NOT IN ('D') AND
			%Exp:cFiltro%
			SFT.%NotDel%

		GROUP BY SFT.FT_ESPECIE, SFT.FT_CFOP, SFT.FT_PRODUTO, SFT.FT_POSIPI, SFT.FT_CSTPIS, SFT.FT_CSTCOF

		ORDER BY SFT.FT_CFOP

	EndSql
	//@history Chamado Interno  - OS n.       - Abel Babini - 11/05/2020 - Considerar todo tipo de documento, retirando filtro que não incluia Devoluções e Beneficiamentos nos cálculos.
	//SFT.FT_TIPO NOT IN ('D','B') AND
	
	DbSelectArea(cAliasSFT)
	(cAliasSFT)->(DbGoTop ())
	_nRegSFT := (cAliasSFT)->(RecCount ())
	ProcRegua(_nRegSFT)
	(cAliasSFT)->(DbGoTop ())
	
	Do While !(cAliasSFT)->(Eof ())

		cEspecie	:=	AModNot ((cAliasSFT)->FT_ESPECIE)		//Modelo NF
		If cEspecie$"  " .Or. ( (AllTrim((cAliasSFT)->FT_CFOP)$aCFOPs[01])	.AND. !(AllTrim((cAliasSFT)->FT_CFOP)$aCFOPs[02]) )// Verifica se o CFOP é gerador de receita
      
			//Verifica se o NCM do Produto está no parâmetro MV_#NCMEMB
			If Substr(Alltrim((cAliasSFT)->FT_POSIPI),1,4)$cNCMEmb 
				//Acumula valor de receita Embutidos
				 aRetorno[1] += (cAliasSFT)->FT_VALCONT
			EndIf
	
			//Verifica se o NCM do produto está no parâmetro MV_#NCMCPR e o CST é tributável à alíquota 0 (zero), ou seja 06.
			If Substr(Alltrim((cAliasSFT)->FT_POSIPI),1,4) $ cNCMRTo .and. Alltrim((cAliasSFT)->FT_CSTPIS) == '06'
				//Acumula valor de receita total
			    aRetorno[2] += (cAliasSFT)->FT_VALCONT
		    Endif		   
		EndIf
   
		(cAliasSFT)->(DbSkip ())
	EndDo

	DbSelectArea (cAliasSFT)
	(cAliasSFT)->(DbCloseArea ())

	cAliasSFT	:=	"SFT"

	RestArea(aArea)
Return aRetorno

/*/{Protheus.doc} User Function F1ECPrIn
	Seleciona as NF de Entrada referente as Compras no Mercado Interno com direito a Credito Presumido Lei 10.925/2004
	@type  Function
	@author Abel Babini
	@since 25/03/2019
	/*/
User Function F1ECPrIn(dDataDe,dDataAte,cNrLivro)
	Local cAliasSFT 	:= "SFT"
	Local aRetorno 	:= {}
	Local cFiltro 	:= ""
	Local cCampos 	:= ""
	Local nPos		:= 0
	//Local aNCME		:= GetNewPar('MV_NCMCREP',"{}")
	Local cCFOPs    := GetNewPar('MV_#CFCPMI',"1101,1118,1122,2101,2118,2122") 

	cCFOP		:= FormatIn(cCFOPs,",")

	//A querry irá trazer o valor de compra de gado para montar a base de cálculo, para gerar valor de crédito presumido.
	//DbSelectArea (cAliasSFT)
	//(cAliasSFT)->(DbSetOrder (2))
	
	cAliasSFT	:=	GetNextAlias()

	cFiltro := "%"

	If (cNrLivro<>"*")
		cFiltro += " SFT.FT_NRLIVRO = '" +%Exp:cNrLivro% +"' AND "
	EndiF
	
	If Len(cCFOP) > 0
		cFiltro += " SFT.FT_CFOP IN "+%Exp:cCFOP% + " AND "
	Endif
	
	cFiltro += "%"
	
	cCampos := "%"

	BeginSql Alias cAliasSFT

		COLUMN FT_EMISSAO AS DATE
    	COLUMN FT_ENTRADA AS DATE
    	COLUMN FT_DTCANC AS DATE

		SELECT
			SUM(SFT.FT_VALCONT) FT_VALCONT , SFT.FT_CLIEFOR, SFT.FT_LOJA, SFT.FT_PRODUTO, SFT.FT_CONTA, SFT.FT_POSIPI, SFT.FT_CFOP, SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_ENTRADA, SA2.A2_NOME, SB1.B1_DESC // Abel Babini-15/04/2019-Ch.048575|Relatório Cred Presumido
			%Exp:cCampos%
		FROM
			%Table:SFT% SFT
		LEFT JOIN %Table:SB1% SB1 ON(SB1.B1_FILIAL=%xFilial:SB1%  AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.%NotDel%)
		LEFT JOIN %Table:SA2% SA2 ON(SA2.A2_FILIAL=%xFilial:SA2%  AND SA2.A2_COD=SFT.FT_CLIEFOR AND SA2.A2_LOJA=SFT.FT_LOJA AND SA2.%NotDel%) // Abel Babini-15/04/2019-Ch.048575|Relatório Cred Presumido	
		WHERE
			SFT.FT_FILIAL=%xFilial:SFT% AND
			SFT.FT_TIPOMOV = 'E' AND
			SFT.FT_ENTRADA>=%Exp:dDataDe% AND
			SFT.FT_ENTRADA<=%Exp:dDataAte% AND
			SFT.FT_TIPO NOT IN ('D','B','I') AND
			(SFT.FT_DTCANC = ' ' OR SFT.FT_DTCANC > %Exp:dDataAte% )  AND
			SFT.FT_CSTPIS IN ('72','73') AND
			SFT.FT_CSTCOF IN ('72','73') AND
			%Exp:cFiltro%
			SFT.%NotDel%

		GROUP BY SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLIEFOR,SFT.FT_LOJA, SFT.FT_PRODUTO, SFT.FT_CONTA, SFT.FT_POSIPI,SFT.FT_CFOP, SFT.FT_ENTRADA, SA2.A2_NOME, SB1.B1_DESC // Abel Babini-15/04/2019-Ch.048575|Relatório Cred Presumido

		ORDER BY SFT.FT_NFISCAL

	EndSql

	DbSelectArea (cAliasSFT)
	(cAliasSFT)->(DbGoTop ())
	nRegcSFT := (cAliasSFT)->(RecCount())

	ProcRegua (nRegcSFT)
	(cAliasSFT)->(DbGoTop ())
	
	Do While !(cAliasSFT)->(Eof()) 
		
		If !ASCAN(aRetorno,{|X|X[3]== (cAliasSFT)->FT_PRODUTO .And. X[2] == (cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA .AND.;
			                            X[5] == (cAliasSFT)->FT_NFISCAL .AND. X[6] == (cAliasSFT)->FT_SERIE }) > 0

				AADD(aRetorno,{})
				nPos := Len(aRetorno)
				AADD(aRetorno[nPos], (cAliasSFT)->FT_VALCONT)  
				AADD(aRetorno[nPos], (cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA) 
				AADD(aRetorno[nPos], (cAliasSFT)->FT_PRODUTO)
				If SubStr((cAliasSFT)->FT_CFOP,1,1) > '2'
				    AADD(aRetorno[nPos], '1') // Crédito originário do Mercado externo
				Else
				    AADD(aRetorno[nPos], '0') // Crédito originário do Mercado interno
				EndIf
				AADD(aRetorno[nPos], (cAliasSFT)->FT_NFISCAL)
				AADD(aRetorno[nPos], (cAliasSFT)->FT_SERIE)					 
				AADD(aRetorno[nPos], (cAliasSFT)->FT_CLIEFOR)
				AADD(aRetorno[nPos], (cAliasSFT)->FT_LOJA)
				AADD(aRetorno[nPos], (cAliasSFT)->FT_CONTA)
				AADD(aRetorno[nPos], (cAliasSFT)->FT_ENTRADA)
				//INICIO Abel Babini-15/04/2019-Ch.048575|Relatório Cred Presumido
				AADD(aRetorno[nPos], (cAliasSFT)->A2_NOME)
				AADD(aRetorno[nPos], (cAliasSFT)->B1_DESC)
				AADD(aRetorno[nPos], (cAliasSFT)->FT_CFOP)
				AADD(aRetorno[nPos], (cAliasSFT)->FT_POSIPI)
				//FIM Abel Babini-15/04/2019-Ch.048575|Relatório Cred Presumido
		Else
		       aRetorno[LEN(aRetorno), 1] += (cAliasSFT)->FT_VALCONT					
		EndIf
		(cAliasSFT)->(DbSkip ())
	EndDo

	DbSelectArea (cAliasSFT)
	(cAliasSFT)->(DbCloseArea ())
	
Return aRetorno
