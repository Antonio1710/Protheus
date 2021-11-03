#include "rwmake.ch"
#include "TOPCONN.CH" 

/*/{Protheus.doc} User Function M410PVNF
	Ponto de entrada para validação. Executado antes da rotina de geração de NF's (MA410PVNFS()). Validação no botao Prep.Doc.Saida do Pedido de Vendas. Pois a geração de nfs deve ser feita pela rotina CCSP_002 (Retorno Edata) Apenas as exceções abaixo podem ser faturadas pelo botao Prep.Doc.Saida
	@type  Function
	@author Ana Helena
	@since 30/01/2014
	@version 01
	@history Chamado 056380 - William Costa - 09/03/2020 - Ajustado regra para não faturar pedido que data de entrega seja menor que a data de hoje
	@history Chamado T.I    - William Costa - 11/03/2020 - Retirado codigo do chamado anterior para trocar a data de entrega conforme solicitação do fernando.
	@history Chamado 056247 - FWNM          - 09/04/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history Tkt -   T.I    - SIGOLI        - 24/09/2021 - Alterado para validar se o pedido antecipadp foi liberado manualmente C5_XWSPAGO  "S|M" 
/*/	
User Function M410PVNF()
                                  
	Local lRet 		:= .T.
	Local cCliente 	:= SC5->C5_CLIENTE
	Local cLoja 	:= SC5->C5_LOJACLI
	Local cTipoPed 	:= SC5->C5_TIPO                 
	Local cTipoProd := ''
	Local _aAreaSC5	:=SC5->(GetArea())
	Local _aAreaSC6	:=SC6->(GetArea())
	Local _aAreaSA1	:=SA1->(GetArea())

	// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 09/04/2020
	FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
    If FIE->( dbSeek(SC5->C5_FILIAL+"R"+SC5->C5_NUM) )
		If !AllTrim(SC5->C5_XWSPAGO) $ "S|M" 
			lRet := .f.
			msgAlert("Pedido de Adiantamento " + SC5->C5_NUM + " não foi pago! Faturamento não permitido...","[M410PVNF-01] - Bradesco WS")
			Return lRet
		EndIf
	EndIf
	//

	dbSelectArea("SC6")
	dbSetOrder(1)
	dbGoTop()
	dbSeek(xFilial("SC6")+SC5->C5_NUM)
	While !Eof() .and. SC5->C5_FILIAL == SC6->C6_FILIAL .and. SC5->C5_NUM == SC6->C6_NUM      
		cTipoProd := posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_TIPO")  //Incluido por Adriana chamado 030968 em 21/10/2016
		If (Substr(SC6->C6_CF,1,2) $ GETMV("MV_CFFATPE") .or. cTipoProd = "PA") .and. Alltrim(cTipoPed) $ "NB" //Incluida condicao de tipo PA por Adriana chamado 030968 em 21/10/2016
			lRet := .F.	
		Endif
		SC6->(dbSkip())
	Enddo

	//Exceções

	dbSelectArea("SC6")
	dbSetOrder(1)
	dbGoTop()
	dbSeek(xFilial("SC6")+SC5->C5_NUM)
	While !Eof() .and. SC5->C5_FILIAL == SC6->C6_FILIAL .and. SC5->C5_NUM == SC6->C6_NUM
		If Alltrim(SC6->C6_CF) $ GETMV("MV_CFFATEX")
			lRet := .T.	
		Endif
		SC6->(dbSkip())
	Enddo

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbGoTop()
	If dbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
		If Alltrim(SA1->A1_EST) $ "BA/RS"
			lRet := .T.
		Endif	
	Endif

	If !(cEmpAnt == "01" .And. cFilAnt = "02")
		lRet := .T.
	Endif
	
	//Projeto Refaturamento - INICIO Altera informação na Tela de Refaturamento informando que o pedido foi faturado William Costa³
	
	If Alltrim(cEmpAnt) == "01"

		If Alltrim(SC5->C5_REFATUR) == "S"

			//lRet := .T.  //chamado 034407 - Sigoli 30/03/2017  
			//chamada da função para garantir que sera faturado primeiro a remessa, depois a venda a ordem.
			lRet := ValPedRem(SC5->C5_NUM) //chamado 034407 - Sigoli 30/03/2017

			DBSELECTAREA("ZB1")
			DBSETORDER(2)
			DBGOTOP()	
				IF DBSEEK(xFilial("ZB1")+SC5->C5_NUM)
				
					RecLock("ZB1",.F.) 
						ZB1->ZB1_STATUS := 'F'  //muda o status do refaturamento
					ZB1->( MsUnLock() ) 		// Confirma e finaliza a operação
				
				ENDIF  
			
			ZB1->(dbCloseArea())    	
		
		Endif  
	
		//Projeto Refaturamento - FIM Altera informação na Tela de Refaturamento informando que o pedido foi faturado William Costa
		
		/*If Alltrim(SC5->C5_XFATANT) == "1"
			lRet := .T. 
		Endif*/

		if lRet   //incluido por Adriana para validar data - chamado 036749

			if ddatabase <> date()
				Aviso("M410PVNF","Data base incorreta !!!",{"OK"},3)
				lRet := .f.
			endif

		endif
	
		//Everson - 27/07/2017 - Chamado 033511.
		If ! Empty(Alltrim(cValtoChar(SC5->C5_PEDSAG))) .And. Alltrim(cValtoChar(SC5->C5_XLIBSAG)) == "1"
			MsgStop("O pedido " + Alltrim(cValtoChar(SC5->C5_NUM)) + " não está liberado pela rotina de corte do SAG.","Função M410PVNF")
			lRet := .F.
			
		EndIf
		
	Endif	

	// *** INICIO WILLIAM COSTA 09/03/2020 DO CHAMADO 056380 || OS 057817 || PCP || VERUSCA || 3543 || VALIDACAO DATA *** //
	// Solicitado retirada por Fernando Sigoli data 11/03/2020

    IF cEmpAnt $ SuperGetMv("MV_#DNF001" , .F. ,'',)
	
		IF SC5->C5_DTENTR < DATE()

			u_GrLogZBE (Date(),TIME(),cUserName,"ALTERACAO DE DATA DE ENTREGA","FATURAMENTO","M410PVNF","PEDIDO: "+SC5->C5_NUM + " Data de Entrega de: " + DTOC(SC5->C5_DTENTR) + " Data de Entrega para: " + DTOC(DATE()),ComputerName(),LogUserName())

			//SC5
			DBSELECTAREA("SC5")
			DBSETORDER(1)
			IF DBSEEK(FWXFILIAL("SC5") + SC5->C5_NUM)

				RECLOCK("SC5", .F.)

					SC5->C5_DTENTR := DATE()

				MSUNLOCK()

			ENDIF

			//SC6
			DBSELECTAREA("SC6")
			DBSETORDER(1) 
			IF DBSEEK(FWXFILIAL("SC6") + SC5->C5_NUM)

				WHILE SC6->(!EOF()) .AND. SC6->C6_NUM == SC5->C5_NUM

					RECLOCK("SC6", .F.)

						SC6->C6_ENTREG := DATE()

					MSUNLOCK()

					SC6->(DBSKIP())
				ENDDO
			ENDIF

			//SC9
			DBSELECTAREA("SC9")
			DBSETORDER(1) 
			IF DBSEEK(FWXFILIAL("SC9") + SC5->C5_NUM)

				WHILE SC9->(!EOF()) .AND. SC9->C9_PEDIDO == SC5->C5_NUM

					RECLOCK("SC9", .F.)

						SC9->C9_DTENTR := DATE()

					MSUNLOCK()

					SC9->(DBSKIP())
				ENDDO
			ENDIF
		ENDIF
    ENDIF
	// *** FINAL WILLIAM COSTA 09/03/2020 DO CHAMADO 056380 || OS 057817 || PCP || VERUSCA || 3543 || VALIDACAO DATA *** //

	RestArea(_aAreaSC5)
	RestArea(_aAreaSC6)
	RestArea(_aAreaSA1) 

Return(lRet)  

/*{Protheus.doc} Static Function ValPedRem
	Rotina para validar se o pedido que esta sendo faturado esta atrelada a algum outro pedido utiliza nesse caso para venda conta a ordem
	@type  Function
	@author Fernando Sigoli
	@since SEM DATA 
	@version 01
	@history Chamado 034407 - Fernando Sigoli - SEM DATA  - pedido venda conta a ordem
*/

Static Function ValPedRem(cNumPed)

	Local lLibfat := .T.   
	Local cQry    := ""          

	cQry := " SELECT C5_NUM,C5_NLACRE1,C5_NOTA,C5_REFATUR,COUNT(C5_NUM) AS CONTA FROM "+RetSqlName("SC5")+" SC5 "
	cQry += " WHERE SC5.D_E_L_E_T_ = '' AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQry += " AND SC5.C5_XPEDORD = '"+cNumPed+"'"
	cQry += " GROUP BY  C5_NUM,C5_NLACRE1,C5_NOTA,C5_REFATUR"

	TCQUERY cQry NEW ALIAS "DADOSC5"

	dbSelectArea("DADOSC5")
	dbGoTop()
	
	If Empty(DADOSC5->C5_NLACRE1) .and. Empty(DADOSC5->C5_NOTA) .and. DADOSC5->CONTA > 0 .and. DADOSC5->C5_REFATUR <> 'S'  &&Caso tenha lacre, a remessa ja foi processada pela rotina de retorno do Edata ccsp_002
		
		MsgAlert("Pedido "+cNumPed+" não poderá ser faturado, pois esta viculado a um pedido de remessa "+DADOSC5->C5_NUM+" que ainda nao foi processado/retorno Edata")	
		lLibfat := .F. 

	EndIF
		
	DbCLoseArea("DADOSC5")

Return lLibfat
