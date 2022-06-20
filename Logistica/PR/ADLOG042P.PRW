#Include "RwMake.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "Totvs.ch"
#Include "Topconn.ch"
/*/{Protheus.doc} User Function ADLOG042P
	Geração de frete a partir de emissão da Nota. Chamado 044314.
	@type  Function
	@author Ricardo Lima
	@since 16/11/2018
	@version 01
	@history 23/01/2019, Ricardo Lima, Segurança para geração de frete a partir da emissão da Nota.
	@history 01/02/2019, RICARDO LIMA, CH:044314, retirado a busca automatica da tabela de frete.
	@history 01/02/2019, Ricardo Lima, Ch:029058, Montagem de carga de entrega de ração.
	@history 05/02/2019, RICARDO LIMA, CH:044314, Ajuste para troca de placa do roteiro.
	@history 07/02/2019, RICARDO LIMA, CH:044314, Ajuste na contagem de carga e envio de e-mail de erro.
	@history 11/02/2019, Ricardo Lima, CH:044314, correção do valor minimo.
	@history 14/02/2019, Ricardo Lima, CH:044314, Ajuste no numero de viagem.
	@history 15/02/2019, Ricardo Lima, CH:044314, geração de frete por cadastro de negociação de frete.
	@history 18/02/2019, Ricardo Lima, CH:044314, LEG. geração de frete por cadastro de negociação de frete.
	@history 27/02/2019, Everson, CH:044314, correção da conferência de placa no momento do faturamento.
	@history 28/02/2019, Everson, CH:044314, criada rotina de reprocessamento.
	@history 06/03/2019, Everson, CH:044314,Validação para verificar se a placa para envio de e-mail.
	@history 15/03/2019, Everson, CH:044314,Inclusão de sequencial de lançamento de frete e dados da transportadora do veículo pago.
	@history 20/03/2019, Everson, CH:044314,Inclusão de campo para cálculo do pedágio.
	@history 21/03/2019, Everson, CH:044314,Para os registros de frete automáticos a data de movimentação será igual a data de entrega.
	@history 10/04/2019, Everson, CH:044314,Tratamento para recalcular o frete apóos estorno do frete por exclusão de nota fiscal.
	@history 11/04/2019, Everson, CH:044314,Rotina para fechar o preenchimento de número de nota fiscal.
	@history 17/04/2019, Everson, CH:044314,Removido tratamento de frete combinado quando o veículo não possui carga e incluído checagem de frete quando não há frete na ZFD.
	@history 17/04/2019, Everson, CH:044314,Correçaõ da MV com o número de roteiro mínimo
	@history 18/04/2019, Everson, CH:044314,alterada mensagem de erro de geração de frete.
	@history 18/04/2019, Everson, CH:044314,corrigido variável no conout. 
	@history 22/04/2019, Everson, CH:044314,adicionado cálculo do frete por tonelada.
	@history 29/04/2019, Everson, CH:044314,adicionado tratamento para gerar outro número de carga, caso houver trocar de placa direto no Protheus.
	@history 02/05/2019, Everson, CH:044314,adicionado tratamento para atualizar todos os itens da carga.
	@history 03/05/2019, Everson, CH:044314,Exclui registro na tabela de frete ZFA se houve alteração de número de carga.
	@history 06/05/2019, Everson, CH:044314,Tratamento para check na tabela SZK.
	@history 09/05/2019, Everson, CH:044314,Tratamento para check na tabela SZK.
	@history 24/05/2019, Everson, CH:044314,Tratamento para lançamento de frete combinado.
	@history 28/05/2019, Everson, CH:044314,Tratamento para checagem de Km de carga já gerada.
	@history 30/05/2019, Everson, CH:044314,Alterada chamada da rotina de reprocessamento de frete.
	@history 31/05/2019, Everson, CH:044314,Tratamento para quando a geração de frete vier da rotina CCSP_002.
	@history 04/06/2019, Everson, CH:044314,Tratamento para atualizar o valor de frete na tabela ZFD.
	@history 05/06/2019, Everson, CH:044314,Tratamento para atualizar o valor de frete na tabela ZFD.
	@history 07/06/2019, Everson, CH:044314,Otimizada rotina para geração de frete.
	@history 18/06/2019, Everson, CH:044314,Tratamento para não haver estorno de frete com CT-e vinculado.
	@history 19/06/2019, Everson, CH:044314,Tratamento para validar roteiro do frete combinado.
	@history 21/06/2019, Everson, CH:044314,Tratamento para não remover o roteiro do frete combinado no estorno.
	@history 24/06/2019, Everson, CH:044314,Tratamento para não haver estorno de frete com CT-e vinculado.
	@history 08/07/2019, Everson, CH:044314,Adicionada placa do cavalo mecânico para geração do MDF-e para veículos 
	articulados e tratamento para checar o roteiro para frete combinado.
	@history 10/07/2019, Everson, CH:044314,Alterado o índice ao gravar o registro de frete para evitar duplicidade.
	@history 25/07/2019, Everson, CH:044314,Adicionada validação de pedido de compra no estorno no lançamento de frete.
	@history 08/08/2019, Everson, CH:044314,Adicionado cálculo de frete para tabela por região.
	@history 09/08/2019, Everson, CH:044314,Tratamento para quando o nota de saída for para fornecedor.
	@history 09/08/2019, Everson-(2),CH:044314,Tratamento para considerar o endereço de entrega na geração de frete.
	@history 13/08/2019, Everson, CH:044314,Tratamento de volume e peso bruto.
	@history 22/08/2019, Everson, CH:044314,Removida a checagem de carga na tabela SZK.
	@history 17/09/2019, Everson, CH:044314,Tratamento para quando houver tabela de frete cadastra no 
	veículo e também frete combinado para não fechar o registro de frete combinado.
	@history 14/10/2019, Everson, CH:044314,Tratamento para não gerar frete para tipo de frete diferente da MV.
	@history 21/10/2019, Everson, CH:029058,Adicionado marcação de tipo de frete.
	@history 06/11/2019, Everson, CH:029058,Adicionados origem e tipo de bloqueio de frete na geração de frete.
	@history Everson-16/01/2020-Ch:054941-Adicionado tratamento para tipo de frete. 
	@history Everson-20/01/2020-Ch:054941-Tratamento por tipo de carga. 
	@history Everson-21/01/2020-Ch:054941- Removidas as regras para geração de frete de frango abatido e colocadas no fonte ADLOG041P.
	@history Everson-13/02/2020-Ch:054941- Tratamento para geração de frete de ração.
	@history Everson-21/02/2020-Ch:054941- Adicionada a função GetArea e filtros pela opção de execução.
	@history Everson-12/08/2020-Ch:059326- Tratamento para geração de frete na empresa Ceres 02. 
	@history Everson-20/07/2020-Ch:15478- Tratamento para geração de frete de subproduto na empresa Adoro 02 Filial 03.
	@history Everson-20/07/2020-Ch:19127- Tratamento para geração de frete de subproduto na empresa Adoro 02 Filial 03 para subproduto.
	@history Everson-13/06/2022-Chr:018465 - Removida a geração de frete de ração.
	/*/    
User Function ADLOG042P( cEmpAnt , cFilAnt , F2DOC , F2SERIE , F2CLIENTE , F2LOJA  , C5NUM , cOpc , C5DTENTR, lStorFr )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea			:= GetArea() //Everson-21/02/2020-Ch:054941.
	Local aAreaZFD		:= {} //Everson-21/02/2020-Ch:054941.
	Local lAutoJob 		:= .F.
	Local cTpCrg 		:= ""
	Local cRote 		:= ""	//Everson - 20/07/2021. Chamado 15478.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Geração de frete a partir de emissão da Nota')

	//Everson-21/02/2020-Ch:054941.
	logZBE(" 1 - Geração de Frete " + cValToChar(cTpCrg) + " Emp/Filial " + cValToChar(cEmpAnt) + "/" + cValToChar(cFilAnt),"Pedido " + cValToChar(C5NUM) + " Nf " + F2DOC + " Serie " + F2SERIE)

	//Everson - 07/02/2020. Chamado 054941.
	If Alltrim(cEmpAnt) + Alltrim(cFilAnt) == "0103" .And. cOpc == "1"
		U_ADLOG052P("1",cEmpAnt , cFilAnt )

	EndIf

	//Everson-20/01/2020-Ch:054941.
	C5NUM := Posicione("SD2",3,FWxFilial("SD2") + F2DOC + F2SERIE,"D2_PEDIDO")
	DbSelectArea("ZFD")
	aAreaZFD := ZFD->(GetArea())
	ZFD->(DbSetOrder(5))
	ZFD->(DbGoTop())
	If ZFD->(DbSeek(FWxFilial("ZFD") + C5NUM ))

		//
		cTpCrg := Alltrim(cValToChar(ZFD->ZFD_VA))

	EndIf
	RestArea(aAreaZFD)
	//

	//Everson-21/02/2020-Ch:054941.
	logZBE(" 2 - Geração de Frete " + cValToChar(cTpCrg) + " Emp/Filial " + cValToChar(cEmpAnt) + "/" + cValToChar(cFilAnt) + Iif(Empty(cTpCrg)," *** SEM CARGA ***",""),"Pedido " + cValToChar(C5NUM) + " Nf " + F2DOC + " Serie " + F2SERIE)

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG042P - cTpCrg " + cTpCrg )

	//
	cRote := cValToChar(Posicione("SC5",1, FWxFilial("SC5") + C5NUM, "C5_ROTEIRO")) //Everson - 20/07/2021. Chamado 15478.
	Conout( DToC(Date()) + " " + Time() + " ADLOG042P - cRote " + cRote )

	//Everson-20/01/2020-Ch:054941.
	If cTpCrg == "1" //Everson - 07/02/2020. Chamado 0541941.
		U_ADLOG041P(cEmpAnt , cFilAnt , F2DOC , F2SERIE , F2CLIENTE , F2LOJA  , C5NUM , cOpc , C5DTENTR, @lStorFr, lAutoJob)

	ElseIf cTpCrg == "2" //Frete Frango Vivo.

	ElseIf cTpCrg == "3" .And. cOpc == "1" //Frete Ovo. //Everson-21/02/2020-Ch:054941.
		U_ADLOG067P(cEmpAnt , cFilAnt , F2DOC , F2SERIE , F2CLIENTE , F2LOJA  , C5NUM , cOpc , C5DTENTR, @lStorFr, lAutoJob,cTpCrg)

	ElseIf cTpCrg == "4" .And. cOpc == "1" //Frete Pintinho. //Everson-21/02/2020-Ch:054941.
		U_ADLOG067P(cEmpAnt , cFilAnt , F2DOC , F2SERIE , F2CLIENTE , F2LOJA  , C5NUM , cOpc , C5DTENTR, @lStorFr, lAutoJob,cTpCrg)

	ElseIf cTpCrg == "5" .And. cOpc == "1" //Frete Ração. //Everson-21/02/2020-Ch:054941.
		// U_ADLOG052P("2",cEmpAnt , cFilAnt , F2DOC , F2SERIE , F2CLIENTE , F2LOJA  , C5NUM , cOpc , C5DTENTR, @lStorFr, lAutoJob) //Everson - 07/02/2020. Chamado 054941. //Everson - 13/06/2022. Chamado 018465.

	ElseIf 	Alltrim(cEmpAnt) + Alltrim(cFilAnt) == "0102" .Or.;
			Alltrim(cEmpAnt) + Alltrim(cFilAnt) == "0201"
			
			//Everson-10/09/2021-Ch:19127.
			logZBE(" 3 - Geração de Frete " + cValToChar(cTpCrg) + " Emp/Filial " + cValToChar(cEmpAnt) + "/" + cValToChar(cFilAnt),"Pedido " + cValToChar(C5NUM) + " Nf " + F2DOC + " Serie " + F2SERIE)
			//

			U_ADLOG041P(cEmpAnt , cFilAnt , F2DOC , F2SERIE , F2CLIENTE , F2LOJA  , C5NUM , cOpc , C5DTENTR, @lStorFr, lAutoJob) //Everson - 21/01/2020. Chamado 054941.

	//Everson-10/09/2021-Ch:19127.
	ElseIf Alltrim(cEmpAnt) + Alltrim(cFilAnt) == "0103" .And.;
			!Empty(cRote) //Everson - 12/08/2020. Chamado 059326. //Everson - 20/07/2021. Chamado 15478.
			
		//
		logZBE(" 4 - Geração de Frete " + cValToChar(cTpCrg) + " Emp/Filial " + cValToChar(cEmpAnt) + "/" + cValToChar(cFilAnt),"Pedido " + cValToChar(C5NUM) + " Nf " + F2DOC + " Serie " + F2SERIE)
		
		//
		If U_ADLOG421(cFilAnt, C5NUM) //Frete de subproduto.
			U_ADLOG041P(cEmpAnt , cFilAnt , F2DOC , F2SERIE , F2CLIENTE , F2LOJA  , C5NUM , cOpc , C5DTENTR, @lStorFr, lAutoJob) //Everson - 21/01/2020. Chamado 054941.

		EndIf

	EndIf

	//Everson-21/02/2020-Ch:054941.
	logZBE(" 5 - Geração de Frete " + cValToChar(cTpCrg) + " Emp/Filial " + cValToChar(cEmpAnt) + "/" + cValToChar(cFilAnt),"Pedido " + cValToChar(C5NUM) + " Nf " + F2DOC + " Serie " + F2SERIE)

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADLOG421
	Função checa se há subproduto no pedido. 
	@type  Function
	@author Everson
	@since 10/09/21
	@version 01
	/*/
User Function ADLOG421(cFil, cPedido)

	//Declaração de variáveis. 
	Local aArea 	:= GetArea()
	Local cAliasSC6 := GetNextAlias()
	Local cQuery 	:= ""
	Local cSubPrd	:= GetMv("MV_SUBPROD")
	Local lRet 		:= .F.

	//
	cQuery += "SELECT  " 
	cQuery += "COUNT(C6_PRODUTO) AS QTD_PROD  " 
	cQuery += "FROM  " 
	cQuery += " " + RetSqlName("SC6") + " (NOLOCK) AS SC6 " 
	cQuery += "WHERE  " 
	cQuery += "C6_FILIAL = '" + cFil + "'  " 
	cQuery += "AND C6_NUM = '" + cPedido + "' " 
	cQuery += "AND C6_PRODUTO IN (" + cSubPrd + ") " 
	cQuery += "AND SC6.D_E_L_E_T_ = '' " 

	//
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasSC6, .T., .T.)
	DbSelectArea(cAliasSC6)
	(cAliasSC6)->(DbGoTop())
	If Val(cValToChar((cAliasSC6)->QTD_PROD)) > 0
		lRet := .T. 

	EndIf
	(cAliasSC6)->(DbCloseArea())

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} logZBE
	Rotina para gerar log na tabela ZBE. Chamado 044314. 
	@type  Static Function
	@author Everson
	@since 21/02/20
	@version 01
	/*/
Static Function logZBE(cLog,cParam)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	:= GetArea()

	//
	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
		Replace ZBE_FILIAL 	   	With xFilial("ZBE")
		Replace ZBE_DATA 	   	With dDataBase
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With cLog
		Replace ZBE_PARAME 		With cParam
		Replace ZBE_MODULO	    With "LOGISTICA"
		Replace ZBE_ROTINA	    With "ADLOG042P" 
	MsUnlock()

	//
	RestArea(aArea)

Return Nil
