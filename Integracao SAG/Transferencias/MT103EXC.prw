#Include 'Protheus.ch'
#Include 'TOPCONN.ch'

/*/{Protheus.doc} User Function MT103EXC
	Regra de neg๓cio criada para nใo permitir excluir um documento de entrada cujo campo F1_CODIGEN(Numerico 10) seja maior que 0
	@type  Function
	@author Leonardo Rios
	@since 13/04/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 044314 - Everson Silva     - 31/07/2019 - Remover flag da integra็ใo da tabela ZFK (CT-e)
	@history ticket 14352   - Fernando Macieira - 24/05/2021 - Saldo Negativo
/*/
User Function MT103EXC()

	Local lRet      := .T.  // Variแvel responsแvel para retornar se serแ liberado a exclusใo(lRet:=.T.) ou nใo(lRet:=.F.)
	Local cFilGFrt	:= Alltrim(SuperGetMv( "MV_#M46F5" , .F. , '' ,  )) //Everson-CH:044314-06/08/2019. 
	Local cEmpFrt	:= Alltrim(SuperGetMv( "MV_#M46F6" , .F. , '' ,  )) //Everson-CH:044314-06/08/2019.   

	If Alltrim(cEmpAnt) == "01"
		If !(SF1->F1_CODIGEN<1) .AND. !IsInCallStack("U_ADSAG001P") .and. !(SF1->F1_FORMUL=='S' .AND. "PRODUTOR RURAL" $ SF1->F1_MENNOTA)
			lRet := .F.      
			Aviso("MT103EXC","Documento gerado pelo SAG, nใo serแ permitida a exclusใo!",{"OK"},3)
		EndIf
	endif

	//06/08/2019-Everson-Ch:044314.
	If cEmpAnt $cEmpFrt .And. cFilAnt $cFilGFrt
		//31/07/2019-Everson-Ch:044314.
		If Alltrim(SF1->F1_ESPECIE) = "CTE"
			statusCTE (SF1->F1_FILIAL,SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_DOC,SF1->F1_SERIE)
		EndIf
	EndIf

	// @history ticket 14352   - Fernando Macieira - 24/05/2021 - Saldo Negativo
	If lRet
		lRet := ChkPrjNeg()
	EndIf
	//

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณstatusCTE บ Autor ณ Everson - Ch:044314                                  บ Data ณ  31/07/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณRemove o flag de integrado da tabela ZFK.                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function statusCTE (cFilZFK,cFornZFK,cLojaZFK,cNumZFK,cSerZFK)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea	 	:= GetArea()
	Local cUpdate	:= ""

	cNumZFK := Padl(Alltrim(cNumZFK),9,"0")
	cSerZFK	:= Padl(Alltrim(cSerZFK),3,"0")
	
	cUpdate := ""
	cUpdate += " UPDATE  " 
	cUpdate += " " + RetSqlName("ZFK") + " SET ZFK_ENTRAD = '1'  " 
	cUpdate += " WHERE  " 
	cUpdate += " ZFK_FILIAL = '" + Alltrim(cFilZFK) + "'  " 
	cUpdate += " AND ZFK_TRANSP = '" + Alltrim(cFornZFK) + "'  " 
	cUpdate += " AND ZFK_LOJA   = '" + Alltrim(cLojaZFK) + "' " 
	cUpdate += " AND RIGHT('000000000' + RTRIM(LTRIM(ZFK_NUMDOC)),9) = '" + Alltrim(cNumZFK)  + "' " 
	cUpdate += " AND RIGHT('000'       + RTRIM(LTRIM(ZFK_SERDOC)),3) = '" + Alltrim(cSerZFK)  + "' " 
	cUpdate += " AND ZFK_TPDOC = '1' " 
	cUpdate += " AND D_E_L_E_T_ = '' "
	
	Conout( DToC(Date()) + " " + Time() + " MT103EXC - statusCTE - cUpdate " + cUpdate )
	
	If TCSqlExec(cUpdate) < 0
		Conout( DToC(Date()) + " " + Time() + " MT103EXC - statusCTE - [Erro TCSqlExec ] " + TCSQLError() )
	EndIf

	RestArea(aArea)
	
Return Nil

/*/{Protheus.doc} Static Function ChkPrjNeg
	Fun็ใo para checar se a exclusใo da NF deixarแ o projeto negativo
	Valores inferiores de NFs deixam de ser computados no consumo do projeto e consequentemente o valor superior do PC poderแ deixar o saldo negativo 
	@type  Static Function
	@author FWNM
	@since 24/05/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 14352   - Fernando Macieira - 24/05/2021 - Saldo Negativo
/*/
Static Function ChkPrjNeg()

	Local lOk      := .t.
	Local cNFKey   := FWxFilial("SF1")+cNFiscal+cSerie+cTipo+cA100For+cLoja//+cNFCod+cNFItem
	Local cQuery   := ""
	Local nConsumo := 0
	Local aCampos  := {}
	Local nVlrPrj  := 0

	If Select("TRB") > 0
        TRB->( dbCloseArea() )
    EndIf
		
	// Crio TRB
	// https://tdn.totvs.com.br/display/framework/FWTemporaryTable
	oTempTable := FWTemporaryTable():New("TRB")
	
	// Arquivo TRB
	aAdd( aCampos, {'D1_PROJETO' ,TamSX3("D1_PROJETO")[3]   ,TamSX3("D1_PROJETO")[1]  , 0} )
	aAdd( aCampos, {'D1_PEDIDO'  ,TamSX3("D1_PEDIDO")[3]    ,TamSX3("D1_PEDIDO")[1]   , 0} )
	aAdd( aCampos, {'D1_ITEMPC'  ,TamSX3("D1_ITEMPC")[3]    ,TamSX3("D1_ITEMPC")[1]   , 0} )
	aAdd( aCampos, {'D1_QUANT'   ,TamSX3("D1_QUANT")[3]     ,TamSX3("D1_QUANT")[1]    , 0} )
	aAdd( aCampos, {'CONSUMO'    ,TamSX3("D1_TOTAL")[3]     ,TamSX3("D1_TOTAL")[1]    , TamSX3("D1_TOTAL")[2]} )
	aAdd( aCampos, {'SALDO_FUT'  ,TamSX3("D1_TOTAL")[3]     ,TamSX3("D1_TOTAL")[1]    , TamSX3("D1_TOTAL")[2]} )

	oTempTable:SetFields(aCampos)
	oTempTable:AddIndex("01", {"D1_PROJETO","D1_PEDIDO","D1_ITEMPC"} )
	oTempTable:Create()

	// Crio Work com qtd da NF em exclusใo
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT D1_PROJETO, D1_PEDIDO, D1_ITEMPC, SUM(D1_QUANT) D1_QUANT
	cQuery += " FROM " + RetSqlName("SD1") + " (NOLOCK)
	cQuery += " WHERE D1_FILIAL='"+FWxFilial("SF1")+"'
	cQuery += " AND D1_DOC='"+cNFiscal+"'
	cQuery += " AND D1_SERIE='"+cSerie+"'
	cQuery += " AND D1_TIPO='"+cTipo+"'
	cQuery += " AND D1_FORNECE='"+cA100For+"'
	cQuery += " AND D1_LOJA='"+cLoja+"'
	cQuery += " AND D1_PROJETO<>''
	cQuery += " AND D_E_L_E_T_=''
	cQuery += " GROUP BY D1_PROJETO, D1_PEDIDO, D1_ITEMPC
	cQuery += " ORDER BY 1,2,3

	tcQuery cQuery New Alias "Work"

	aTamSX3	:= TamSX3("D1_QUANT")
	tcSetField("Work", "D1_QUANT", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	Work->( dbGoTop() )
	Do While Work->( !EOF() )

		// Consumo Projeto
		nConsumo := u_ADCOM017P(Work->D1_PROJETO,"BROWSE",/*cPCItemKey*/,,cNFKey) 

		RecLock("TRB", .T.)
			TRB->D1_PROJETO := Work->D1_PROJETO
			TRB->D1_PEDIDO  := Work->D1_PEDIDO
			TRB->D1_ITEMPC  := Work->D1_ITEMPC
			TRB->D1_QUANT   := Work->D1_QUANT
			TRB->CONSUMO    := nConsumo
		TRB->( msUnLock() )

		Work->( dbSkip() )

	EndDo

	// Adiciono valor do PC que voltarแ a ser consumido no projeto ap๓s exclusใo
	TRB->( dbGoTop() )
	Do While TRB->( !EOF() )

		SC7->( dbSetOrder(1) ) // C7_FILIAL+C7_NUM+C7_ITEM
		If SC7->( dbSeek(FWxFilial("SC7")+TRB->D1_PEDIDO+TRB->D1_ITEMPC) )

			If SC7->C7_MOEDA<=1

				nC7_TOTAL   := Round((TRB->D1_QUANT*SC7->C7_PRECO),2)
				nC7_VALIPI  := Round((TRB->D1_QUANT*SC7->C7_VALIPI),2)
				nC7_VALFRE  := Round((TRB->D1_QUANT*SC7->C7_VALFRE),2)
				nC7_DESPESA := Round((TRB->D1_QUANT*SC7->C7_DESPESA),2)
				nC7_SEGURO  := Round((TRB->D1_QUANT*SC7->C7_SEGURO),2)
				nC7_ICMSRET := Round((TRB->D1_QUANT*SC7->C7_ICMSRET),2)
				nC7_VLDESC  := Round(SC7->C7_VLDESC,2)

				nConsumo := TRB->CONSUMO + nC7_TOTAL + nC7_VALIPI + nC7_VALFRE + nC7_DESPESA + nC7_SEGURO + nC7_ICMSRET - nC7_VLDESC

			Else

				nC7_TOTAL   := Round(((TRB->D1_QUANT*SC7->C7_PRECO)*SC7->C7_XTXMOED),2)
				nC7_VALIPI  := Round(((TRB->D1_QUANT*SC7->C7_VALIPI)*SC7->C7_XTXMOED),2)
				nC7_VALFRE  := Round(((TRB->D1_QUANT*SC7->C7_VALFRE)*SC7->C7_XTXMOED),2)
				nC7_DESPESA := Round(((TRB->D1_QUANT*SC7->C7_DESPESA)*SC7->C7_XTXMOED),2)
				nC7_SEGURO  := Round(((TRB->D1_QUANT*SC7->C7_SEGURO)*SC7->C7_XTXMOED),2)
				nC7_ICMSRET := Round(((TRB->D1_QUANT*SC7->C7_ICMSRET)*SC7->C7_XTXMOED),2)
				nC7_VLDESC  := Round(SC7->C7_VLDESC,2)

				nConsumo := TRB->CONSUMO + nC7_TOTAL + nC7_VALIPI + nC7_VALFRE + nC7_DESPESA + nC7_SEGURO + nC7_ICMSRET - nC7_VLDESC

			EndIf

		EndIf

		AF8->( dbSetOrder(1) ) // AF8_FILIAL, AF8_PROJET, AF8_DESCRI, R_E_C_N_O_, D_E_L_E_T_
		If AF8->( dbSeek(FWxFilial("AF8")+TRB->D1_PROJETO) )
			nVlrPrj := AF8->AF8_XVALOR
		EndIf

		// SAldo Futuro
		RecLock("TRB", .F.)
			TRB->SALDO_FUT  := nVlrPrj - nConsumo
		TRB->( msUnLock() )

		TRB->( dbSkip() )

	EndDo

	// Checo se algum projeto ficarแ negativo!
	cQuery := " SELECT D1_PROJETO, SUM(SALDO_FUT) SALDO_FUT
	cQuery += " FROM " + oTempTable:GetRealName() + " (NOLOCK)
	cQuery += " WHERE SALDO_FUT < 0
	cQuery += " GROUP BY D1_PROJETO

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"PRJ",.F.,.T.)

	PRJ->( dbGoTop() )
	Do While PRJ->( !EOF() )

		If PRJ->SALDO_FUT < 0
			lOk := .f.
			MessageBox("Exclusใo nใo permitida!" + Chr(13)+Chr(10) + "O projeto de investimento n. " + PRJ->D1_PROJETO + " ficaria com o saldo negativo de " + AllTrim(Transform(PRJ->SALDO_FUT,"@E 999,999,999,999.99")),"MT103EXC-01 (Projeto Investimento n. " + PRJ->D1_PROJETO + ")",48)
			//Exit
		EndIf

		PRJ->( dbSkip() )

	EndDo

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	If Select("TRB") > 0
		TRB->( dbCloseArea() )
	EndIf

	If Select("PRJ") > 0
		PRJ->( dbCloseArea() )
	EndIf

Return lOk
