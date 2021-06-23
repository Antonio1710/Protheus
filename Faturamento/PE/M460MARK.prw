#INCLUDE "Rwmake.Ch"
#INCLUDE "Protheus.Ch"
#INCLUDE "TOPCONN.CH" 

/*/{Protheus.doc} User Function M410PVNF
	Ponto de entrada Apos a selecao dos itens a serem faturados e antes da geracao da nota fiscal. PE criado para que não seja possivel desmarcar algum dos itens na preparação da nf de
	@type  Function
	@author Ana Helena
	@since 30/01/2014
	@version 01
	@history Chamado TI     - Ana Helena    - 23/07/2014 - A utilização do PARAMIXB[2] não foi possivel pois sempre trazia o conteudo .T. mesmo sem inverter a marcação dos pedidos 
	@history Chamado 056380 - William Costa - 09/03/2020 - Ajustado regra para não faturar pedido que data de entrega seja menor que a data de hoje
	@history Chamado T.I    - William Costa - 11/03/2020 - Retirado codigo do chamado anterior para trocar a data de entrega conforme solicitação do fernando.
	@history Chamado 056247 - FWNM          - 28/05/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history ticket 745 - FWNM - 30/09/2020 - C5_XWSPAGO com identificação para liberação manual
/*/	
USER FUNCTION M460MARK()
                
	LOCAL _cMark   := PARAMIXB[1]
	LOCAL lRet     := .T.
	LOCAL cQuery   := ""
	LOCAL dDtEntr  := SC9->C9_DTENTR
	LOCAL cRoteiro := SC9->C9_ROTEIRO
	Local aArea    := GetArea()
	Local aAreaSC5 := SC5->(GetArea())
	Local aAreaSC6 := SC6->(GetArea())
	Local aAreaSC9 := SC9->(GetArea())

	// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 28/05/2020
	FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
	If FIE->( dbSeek(FWxFilial("FIE")+"R"+SC9->C9_PEDIDO) )

		SC5->( dbSetOrder(1) ) // C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_
		If SC5->( dbSeek(FWxFilial("SC5")+SC9->C9_PEDIDO) )
			
			//If AllTrim(SC5->C5_XWSPAGO) <> "S"
			If Empty(AllTrim(SC5->C5_XWSPAGO)) // ticket 745 - FWNM - 30/09/2020 - C5_XWSPAGO com identificação para liberação manual
				lRet := .f.
				msgAlert("Pedido de Adiantamento " + SC5->C5_NUM + " não foi pago! Faturamento não permitido...","[M460MARK-01] - Bradesco WS")
				Return lRet
			EndIf

		EndIf
	
	Else

		SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
		If SE1->( dbSeek(FWxFilial("SE1")+PadR("RA",Len(SE1->E1_PREFIXO))+PadR(SC9->C9_PEDIDO,Len(SE1->E1_NUM))+PadR("",Len(SE1->E1_PARCELA))+PadR("RA",Len(SE1->E1_TIPO)) ) )

			If !Empty(SE1->E1_XWSBRAC)

				SC5->( dbSetOrder(1) ) // C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_
				If SC5->( dbSeek(FWxFilial("SC5")+SC9->C9_PEDIDO) )
			
					//If AllTrim(SC5->C5_XWSPAGO) <> "S"
					If Empty(AllTrim(SC5->C5_XWSPAGO)) // ticket 745 - FWNM - 30/09/2020 - C5_XWSPAGO com identificação para liberação manual
						lRet := .f.
						msgAlert("Pedido de Adiantamento " + SC5->C5_NUM + " não foi pago! Faturamento não permitido...","[M460MARK-02] - Bradesco WS")
						Return lRet
					EndIf

				EndIf

			EndIf

		EndIf

	EndIf
	//

	IF SELECT("TMP1") > 0

		DBSELECTAREA("TMP1")
		TMP1->(dbCloseArea())

	ENDIF

	cQuery := " SELECT C9_PEDIDO FROM " + RETSQLNAME("SC9")
	cQuery += " WHERE C9_DTENTR = '"    + DTOS(dDtEntr)     + "' " 
	cQuery += " AND C9_ROTEIRO  = '"    + ALLTRIM(cRoteiro) + "' "
	cQuery += " AND C9_OK       = '"    + ALLTRIM(_cMark)   + "' "
	cQuery += " AND C9_FILIAL   = '"    + ALLTRIM(cFilAnt)  + "' "
	cQuery += " AND D_E_L_E_T_ <> '*' "

	TCQUERY cQuery NEW ALIAS "TMP1"
	TMP1->(DBGOTOP()) 

	cPedOK := TMP1->C9_PEDIDO

	IF SELECT("TMP2") > 0

		DBSELECTAREA("TMP2")
		TMP2->(dbCloseArea())

	ENDIF

	cQuery := " SELECT C9_PEDIDO FROM " + RETSQLNAME("SC9")
	cQuery += " WHERE C9_DTENTR  = '"   + DTOS(dDtEntr)     + "' " 
	cQuery += " AND C9_ROTEIRO   = '"   + ALLTRIM(cRoteiro) + "' "
	cQuery += " AND C9_OK       <> '"   + ALLTRIM(_cMark)   + "' "
	cQuery += " AND C9_FILIAL    = '"   + ALLTRIM(cFilAnt)  + "' "
	cQuery += " AND D_E_L_E_T_  <> '*' "

	TCQUERY cQuery new alias "TMP2"
	TMP2->(DBGOTOP()) 

	cPedNOK := TMP2->C9_PEDIDO

	IF ALLTRIM(cPedOK) <> "" .AND. ALLTRIM(cPedNOK) <> ""

		ALERT("Todos os itens do roteiro devem ser marcados. Verifique!")
		lRet := .F.

	ENDIF

	// *** INICIO WILLIAM COSTA 09/03/2020 DO CHAMADO 056380 || OS 057817 || PCP || VERUSCA || 3543 || VALIDACAO DATA *** //
	IF cEmpAnt $ SuperGetMv("MV_#DNF001" , .F. ,'',)

		SqlPedidos(SC5->C5_FILIAL,DTOS(SC5->C5_DTENTR),SC5->C5_ROTEIRO)

		While TMP3->(!EOF()) 

			IF STOD(TMP3->C5_DTENTR) < DATE()

				u_GrLogZBE (Date(),TIME(),cUserName,"ALTERACAO DE DATA DE ENTREGA","FATURAMENTO","M460MARK","PEDIDO: "+TMP3->C5_NUM + " Data de Entrega de: " + DTOC(STOD(TMP3->C5_DTENTR)) + " Data de Entrega para: " + DTOC(DATE()),ComputerName(),LogUserName())

				//SC5
				DBSELECTAREA("SC5")
				DBSETORDER(1)
				IF DBSEEK(FWXFILIAL("SC5") + TMP3->C5_NUM)

					RECLOCK("SC5", .F.)

						SC5->C5_DTENTR := DATE()

					MSUNLOCK()

				ENDIF

				//SC6
				DBSELECTAREA("SC6")
				DBSETORDER(1) 
				IF DBSEEK(FWXFILIAL("SC6") + TMP3->C5_NUM)

					WHILE SC6->(!EOF()) .AND. SC6->C6_NUM == TMP3->C5_NUM

						RECLOCK("SC6", .F.)

							SC6->C6_ENTREG := DATE()

						MSUNLOCK()

						SC6->(DBSKIP())
					ENDDO
				ENDIF

				//SC9
				DBSELECTAREA("SC9")
				DBSETORDER(1) 
				IF DBSEEK(FWXFILIAL("SC9") + TMP3->C5_NUM)

					WHILE SC9->(!EOF()) .AND. SC9->C9_PEDIDO == TMP3->C5_NUM

						RECLOCK("SC9", .F.)

							SC9->C9_DTENTR := DATE()

						MSUNLOCK()

						SC9->(DBSKIP())
					ENDDO
				ENDIF
			ENDIF

			TMP3->(dbSkip())
		
		ENDDO
		TMP3->(dbCloseArea())
	ENDIF
	
	// *** FINAL WILLIAM COSTA 09/03/2020 DO CHAMADO 056380 || OS 057817 || PCP || VERUSCA || 3543 || VALIDACAO DATA *** //

	TMP1->(dbCloseArea())
	TMP2->(dbCloseArea())

	RestArea(aArea)
	RestArea(aAreaSC5)
	RestArea(aAreaSC6)
	RestArea(aAreaSC9)

RETURN lRet

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 08/04/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
STATIC FUNCTION SqlPedidos(cFilAtu,cDtEntr,cRoteiro)

BeginSQL Alias "TMP3"

	%NoPARSER% 
	SELECT C5_FILIAL,C5_NUM,C5_DTENTR 
		FROM SC5010
		WHERE C5_FILIAL   = %EXP:cFilAtu%
		AND C5_DTENTR   = %EXP:cDtEntr%
		AND C5_ROTEIRO  = %EXP:cRoteiro%
		AND D_E_L_E_T_ <> '*'
			
	EndSQl      

RETURN(NIL)
