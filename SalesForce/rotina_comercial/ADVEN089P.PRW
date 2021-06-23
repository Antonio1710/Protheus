#Include "Protheus.ch"
#Include 'Topconn.ch'

/*/{Protheus.doc} User Function ADVEN089P
	Rotina para desbloqueio comercial de pedidos gerados no SalesForce
	@type  Function
	@author Everson
	@since 04/01/2018
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 037261
	@history chamado 056247 - FWNM     - 22/04/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
/*/
User Function ADVEN089P() // U_ADVEN089P()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea	   	:= GetArea()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para desbloqueio comercial de pedidos gerados no SalesForce. ')
	
	//
	If ! Pergunte("SFLIBCOMER",.T.)
		RestArea(aArea)
		Return Nil
	
	Endif
	
	//
	envSF(MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,DtoS(MV_PAR07),DtoS(MV_PAR08))

Retur Nil	
// ##########################################################################################
// Projeto: Projeto SalesForce
// Modulo : SIGAFAT
// Fonte  : envSF
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 07/05/18 | Ricardo Lima      | Ajusta alteração do pedido                 |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
Static Function envSF(cPedDe,cPedAte,cVendDe,cVendAte,cSupDe,cSupAte,cDtDe,cDtAte)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local aDados	:= {}
	Local cPedidos	:= ""
	Local i			:= 1
	
	//
	cQuery := sqlScript(cPedDe,cPedAte,cVendDe,cVendAte,cSupDe,cSupAte,cDtDe,cDtAte)
	
	//
	If Select("ADVE089P") > 0
		ADVE089P->(DbCloseArea())
		
	EndIf	
	
	//
	If Select("ADVE089P") > 0
		ADVE089P->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "ADVE089P"
	
	DbSelectArea("ADVE089P")
	ADVE089P->(DbGoTop())
	While ADVE089P->( !EOF() ) 
		Aadd(aDados,Alltrim(cValToChar(C5_NUM)))
		cPedidos += Alltrim(cValToChar(C5_NUM)) + " " 
		ADVE089P->( dbSkip() )
		
	End
	ADVE089P->(DbCloseArea())
	
	//
	If Len(aDados) <= 0
		MsgStop("Não há pedidos a serem liberados.","Função envSF (ADVEN089P)")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	If MsgYesNo("Serão liberados " + cValToChar(Len(aDados)) + ". Deseja prosseguir?" + Chr(13) + Chr(10) + cPedidos,"Função envSF (ADVEN089P)")
		For i := 1 To Len(aDados)
			MsAguarde({|| Processar( aDados[i] ) },"Aguarde","Lib " + aDados[i] + " | " + cValToChar(i) + "/" + cValToChar(Len(aDados)) )
		
		Next i
		
	Else
		RestArea(aArea)
		Return Nil		
	
	EndIf
	
	//
	MsgInfo("Liberações concluídas","Função envSF (ADVEN089P)")
	
	//
	RestArea(aArea)

Return Nil
// ##########################################################################################
// Projeto: Projeto SalesForce
// Modulo : SIGAFAT
// Fonte  : Processar
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 07/05/18 | Ricardo Lima      | Ajusta alteração do pedido                 |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
Static Function Processar(cNumPed)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea 	:= GetArea()
	Local nVlrCred	:= 0
	Local nQtdLiber	:= 0
	Local lLiber    := .F.
	Local lTrans    := .F.
	Local lCredito  := .F.
	Local lEstoque  := .F.
	Local lAvCred   := .T.
	Local lAvEst    := .F.

	Local lNvLib	:= GetMv("MV_#SFNVPR")

	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(DbGoTop())

	//
	If ! SC5->(DbSeek( xFilial("SC5") + cNumPed ))
		MsgStop("","Função Processar (ADVEN089P)")
		Return Nil

	EndIf

	If !EMPTY(SC5->C5_NOTA)
		ApMsgInfo('Pedido Faturado, não será Processado a Alteração','Liberação de Pedidos')
		Return Nil	
	EndIf

	//Força liberação do pedido.
	If  RecLock("SC5",.F.)
		SC5->C5_BLQ     := " "
		SC5->C5_LIBEROK := "S"
		MsUnlock()
	EndIf

	// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 22/04/2020
	/*
	If AllTrim(Posicione("SE4",1,FWxFilial("SE4")+SC5->C5_CONDPAG,"E4_CTRADT")) == "1" // Cond Adiantamento = SIM

		msAguarde( { || u_GeraRAPV() }, "Gerando boleto de adiantamento e amarração com PV n " + SC5->C5_NUM )
		
		// Checo amarração RA x PV
		FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
		If FIE->( dbSeek(SC5->C5_FILIAL+"R"+SC5->C5_NUM) )
			U_ADVEN050P(SC5->C5_NUM,.T.,.F.,"",.F.,.F.,.F.,.F.,.F.,.F.,0,1)
		EndIf
	
	EndIf
	*/
	//
 
	//
	DbSelectArea("SC9")
	SC9->(DbSetOrder(1))
	If SC9->( DbSeek( xfilial("SC9") + cNumPed) )
		While ! SC9->(Eof()) .And. SC9->C9_FILIAL == xFilial("SC9") .And. Alltrim(cValToChar(SC9->C9_PEDIDO)) == cNumPed
			If Reclock("SC9",.F.)
				DbDelete()
				Msunlock()

			EndIf

			SC9->(Dbskip())
		Enddo
	EndIf

	//
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(DbGoTop())

	If  SC6->( DbSeek(xFilial("SC6") + cNumPed) )

		While ! SC6->(Eof()) .And. SC6->C6_FILIAL ==  xFilial("SC6") .And. SC6->C6_NUM == cNumPed

			nQtdLiber := SC6->C6_QTDVEN
			RecLock("SC6")

			Begin transaction

				If !lNvLib //Rotina padrão.
					MaLibDoFat( SC6->( Recno() ), @nQtdLiber, @lCredito, @lEstoque, lAvCred, lAvEst, lLiber, lTrans )

				Else //Rotina customizada.
					U_ADVEN095P( SC6->( Recno() ), @nQtdLiber, @lCredito, @lEstoque, lAvCred, lAvEst, lLiber, lTrans )

				EndIf

			End transaction

			Begin Transaction
				SC6->(MaLiberOk({cNumPed},.F.))
			End Transaction

			SC6->(dbSkip())

		EndDo

	EndIf

	//
	DbSelectArea("SC9")
	SC9->(DbSetOrder(1))
	If SC9->( DbSeek( xfilial("SC9") + cNumPed) )
		While ! SC9->(Eof()) .And. SC9->C9_FILIAL == xFilial("SC9") .And. Alltrim(cValToChar(SC9->C9_PEDIDO)) == cNumPed
			If Reclock("SC9",.F.)
				SC9->C9_ROTEIRO := SC5->C5_ROTEIRO
				SC9->C9_VEND1   := SC5->C5_VEND1
				SC9->C9_DTENTR  := SC5->C5_DTENTR
				Msunlock()

			EndIf

			SC9->(Dbskip())
		Enddo
	EndIf
	
	//Gera log na tabela ZBE.
	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
		Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
		Replace ZBE_DATA 	   	WITH dDataBase
		Replace ZBE_HORA 	   	WITH Time()
		Replace ZBE_USUARI	    WITH cUserName
		Replace ZBE_LOG	        WITH "Liberação comercial de pedido de venda " + cNumPed
		Replace ZBE_MODULO	    WITH "COMERCIAL"
		Replace ZBE_ROTINA	    WITH "ADVEN089P" 
		Replace ZBE_PARAME      WITH "P.: " + cValToChar(MV_PAR01) + "-" + cValToChar(MV_PAR02) + " | " + "V.: " +  cValToChar(MV_PAR03) + "-" + cValToChar(MV_PAR04) + " | " +;
		                             "S.: " + cValToChar(MV_PAR05) + "-" + cValToChar(MV_PAR06) + " | " + "E.: " +  DToC(MV_PAR07) + "-" + DToC(MV_PAR08)
	ZBE->( MsUnLock())

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function sqlScript
	Retorna script sql
	@type  Static Function
	@author Everson
	@since 14/06/2018
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 037261
/*/
Static Function sqlScript(cPedDe,cPedAte,cVendDe,cVendAte,cSupDe,cSupAte,cDtDe,cDtAte)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea 	:= GetArea()	
	Local cQuery := ""
	
	//
	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " C5_NUM " 
	cQuery += " FROM " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SA3") + " (NOLOCK) AS SA3 " 
	cQuery += " ON C5_VEND1 = A3_COD " 
	cQuery += " INNER JOIN " 
	cQuery += " (SELECT A3_COD AS CODSUP, A3_NOME AS SUPNOME FROM " + RetSqlName("SA3") + " (NOLOCK) AS SA3 WHERE SA3.D_E_L_E_T_ = '') AS SUP " 
	cQuery += " ON A3_CODSUP = SUP.CODSUP " 
	cQuery += " WHERE  " 
	cQuery += " C5_FILIAL = '" + xFilial("SC5") + "'  " 
	cQuery += " AND C5_NUM BETWEEN '" + cValToChar(cPedDe) + "' AND '" + cValToChar(cPedAte) + "' "
	cQuery += " AND C5_VEND1 BETWEEN '" + cValToChar(cVendDe) + "' AND '" + cValToChar(cVendAte) + "' "
	cQuery += " AND SUP.CODSUP BETWEEN '" + cValToChar(cSupDe) + "' AND '" + cValToChar(cSupAte) + "' "  
	cQuery += " AND C5_DTENTR BETWEEN '"+ cDtDe +"' AND '"+ cDtAte +"' "
	cQuery += " AND C5_XGERSF = '2'  " 
	cQuery += " AND C5_BLQ = '1'  " 
	cQuery += " AND C5_XPEDSAL <> ''  " 
	cQuery += " AND SC5.D_E_L_E_T_ = ' '  " 
	cQuery += " AND SA3.D_E_L_E_T_ = '' " 
	cQuery += " ORDER BY C5_NUM " 
	
	//
	RestArea(aArea)
	
Return cQuery 
