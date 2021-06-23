#Include "RwMake.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "Totvs.ch" 
#Include "Topconn.ch" 
/*/{Protheus.doc} User Function ADLOG041P
    Rotina para geração de registros de frete de frango abatido.
    @type  Function
    @author Everson
    @since 21/01/2020
    @version 01
	@history Everson, 07/02/2020. Chamado 054941. Removido o nome da Ad'oro dos e-mails.
	@history Everson, 19/03/2020. Chamado 054941. Tratamento para gravar a distância percorrida de frete combinado e tabelas de região e região x produto.
    @history Everson, 01/07/2020. Chamado 059326. Alterado cálculo do frete por peso bruto para cálculo pelo peso líquido.
	@history Everson, 11/08/2020. Chamado 059326. Tratamento para geração de registros de frete na Ceres.
	@history Everson, 08/10/2020. Chamado TI. Tratamento para cálculo de frete por região.
	/*/
User Function ADLOG041P(cEmpAnt , cFilAnt , F2DOC , F2SERIE , F2CLIENTE , F2LOJA  , C5NUM , cOpc , C5DTENTR, lStorFr, lAutoJob)
	
	//Variáveis.
    Local aArea := GetArea()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para geração de registros de frete de frango abatido.')

    //
    processa(cEmpAnt , cFilAnt , F2DOC , F2SERIE , F2CLIENTE , F2LOJA  , C5NUM , cOpc , C5DTENTR, @lStorFr, lAutoJob)

    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} processa
	Processa lançamento de valor de frete abatido.
	@type  Static Function
	@author Everson
	@since 20/01/2020
	@version 01
	/*/
Static Function processa(cEmpAnt , cFilAnt , F2DOC , F2SERIE , F2CLIENTE , F2LOJA  , C5NUM , cOpc , C5DTENTR, lStorFr, lAutoJob)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea 		:= GetArea()
	Local lChkSZK		:= GetMv("MV_#ADL463",,.F.) //Everson-17/04/2019|CH:044314.
	Local lGerZFD		:= .F. //Everson-17/04/2019|CH:044314.

	//Everson-22/04/2019|CH:044314.
	Private cOcorrV		:= Alltrim(GetMv("MV_#ADL461"))
	Default lStorFr		:= .T. //Everson-18/06/2019|CH:044314.

	//
	logZBE( "ADLOG041P - processa - cOpc " + cValToChar(cOpc), "Filial/Pedido " + cValToChar(cFilAnt) +"/"+ cValToChar(C5NUM) )

	//
	If cOpc == "1" //Gera frete.
		geraFrete( cEmpAnt, cFilAnt, F2DOC, F2SERIE, F2CLIENTE, F2LOJA, C5NUM, C5DTENTR, lAutoJob, @lGerZFD )
		
		Conout( DToC(Date()) + " " + Time() + " ADLOG041P - processa - lChkSZK lGerZFD " + cValToChar(lChkSZK) + " " + cValToChar(lGerZFD) )
		
		//Everson-17/04/2019|CH:044314.
		If lChkSZK .And. lGerZFD
			
			//
			If chkSZK(C5NUM)
				geraFrete( cEmpAnt, cFilAnt, F2DOC, F2SERIE, F2CLIENTE, F2LOJA, C5NUM, C5DTENTR, lAutoJob, @lGerZFD )
				
			EndIf
			
		EndIf

	ElseIf cOpc == "2" //Estorna o Frete.
		lStorFr := estorFrete( cEmpAnt , cFilAnt , F2DOC , F2SERIE , F2CLIENTE , F2LOJA  , C5NUM , C5DTENTR )
		
	ElseIf cOpc == "3" //Everson-10/04/2019 - Estorna o Frete e recalcula o mesmo.
		
		//
		If estorFrete( cEmpAnt , cFilAnt , F2DOC , F2SERIE , F2CLIENTE , F2LOJA  , C5NUM , C5DTENTR )
			geraFrete( cEmpAnt, cFilAnt, F2DOC, F2SERIE, F2CLIENTE, F2LOJA, C5NUM, C5DTENTR, lAutoJob, @lGerZFD )

			//Everson - 17/04/2019. Chamado 044314.
			If lChkSZK .And. lGerZFD
				
				//
				If chkSZK(C5NUM)
					geraFrete( cEmpAnt, cFilAnt, F2DOC, F2SERIE, F2CLIENTE, F2LOJA, C5NUM, C5DTENTR, lAutoJob, @lGerZFD )
					
				EndIf
				
			EndIf
									
		EndIf
		
	EndIf

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} geraFrete
	Gera o lançamento de frete.. Chamado 044314. 
	@type  Static Function
	@author Everson
	@since 21/02/19
	@version 01
/*/
Static Function geraFrete( cEmpAnt, cFilAnt, F2DOC, F2SERIE, F2CLIENTE, F2LOJA, C5NUM, C5DTENTR, lAutoJob, lGerZFD )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local lGerFrt 	:= .T.
	Local sNumCarg 	:= ''
	Local sNumRot  	:= ''
	Local sCodTrns 	:= ''
	Local sCodPlc  	:= ''
	Local nKmTot   	:= 0
	Local nTotKgC  	:= 0
	Local nTotCxC  	:= 0
	Local nPesLiq	:= 0
	Local nVlrFrt  	:= 0
	Local nSeqCar  	:= 0
	Local sCodOcor 	:= ''
	Local nItsNf   	:= 0
	Local nVlrTab  	:= 0
	Local nVlrEnt  	:= 0
	Local nVlrUnFr 	:= 0
	
	// Ricardo Lima-05/02/2019-044314
	Local cPlcPed  	:= ''
	Local cCodRot  	:= ''
	Local cCpfM    	:= ''
	Local NomeMoto 	:= ''
	Local cTranspF 	:= ''
	Local cLojaTrp 	:= ''
	Local cNomeTrp 	:= ''
	Local nVlrMin  	:= 0
	
	//Ricardo Lima-07/02/2019-044314
	Local aNumCrg	:= {}
	Local lAtNumCg	:= .T.
	Local CG		:= 0
	Local cPlcFrt	:= ''

	//Ricardo Lima-15/02/2019-044314
	Local dDtEntr  
	Local cCodTab	:= ''
	Local cDscTab 	:= ''

	//Ricardo Lima-18/02/2019-044314
	Local cTpFrete 	:= ''
	Local cNCarg	:= "" //Everson - 27/02/2019.
	Local cSeqCrg	:= "" //Everson - 27/02/2019.
	Local cTpFrt	:= "" //Everson - 27/02/2019.	
	Local nVlrTon	:= 0  //Everson - 22/04/2019. Chamado 044314.
	Local cPlcCavM	:= "" //Everson - 08/07/2019. Chamado 044314.
	Local cObsFrR	:= "" //Everson - 08/08/2019. Chamado 044314.
	
	Local cTpNF		:= ""

	Local cTpFrtGr	:= Alltrim(cValToChar(GetMV("MV_#TPGFRT",,"C"))) //Everson - 14/10/2019 - Chamado 044314.

	dDtEntr   := STod("") // Ricardo Lima-14/02/2019-044314
	//Ricardo Lima-01/02/2019-Ch:029058
	//Código da ocorrência.
	sCodOcor := cOcorrV
	
	//Everson - 21/09/2019. Chamado 044314. 
	logZBE("1G-Entrou rotina de geração de frete","Empresa/Filial/Pedido: " + cValToChar(cEmpAnt) +"/"+ cValToChar(cFilAnt) +"/"+ cValToChar(C5NUM))

	//Ricardo Lima-05/02/2019-044314
	//Obtém os dados do pedido de venda.
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	If SC5->(DbSeek( FWxFilial("SC5") + C5NUM ))
		cPlcPed := SC5->C5_PLACA
		cCodRot := Alltrim(cValToChar(SC5->C5_ROTEIRO))
		cCodRot := Padr(cCodRot,TamSX3("ZFD_ROTEIR")[01],' ')//Everson-27/02/2019. Chamado 044314.
		dDtEntr := SC5->C5_DTENTR
		cTpFrete:= SC5->C5_TPFRETE //Ricardo Lima-18/02/2019-044314
		cSeqCrg	:= Padl(SC5->C5_SEQUENC,TamSX3("ZFD_SEQCAR")[01],'0') //Everson-27/02/2019. Chamado 044314.
		cTpNF   := SC5->C5_TIPO

		//Everson - 14/10/2019 - Chamado 044314.
		If ! ( Alltrim(cValToChar(SC5->C5_TPFRETE)) $cTpFrtGr )
			Conout( DToC(Date()) + " " + Time() + " ADLOG041P - geraFrete - Tipo de frete - cTpFrtGr " + cValToChar(cTpFrtGr) ) 
			RestArea(aArea)
			Return Nil

		EndIf
		
	EndIf

	//
	DbSelectArea("ZFD")
	ZFD->(DbSetOrder(5))
	If ZFD->(DbSeek(FWxFilial("ZFD") + C5NUM ))

		//Obtém os dados da transportadora e motorista.
		DbselectArea("ZV4")
		ZV4->(DbSetOrder(1))
		If ZV4->(DbSeek( FWxFilial("ZV4") + cPlcPed ))
			cCpfM    := ZV4->ZV4_CPF
			NomeMoto := ZV4->ZV4_MOTORI
			cTranspF := ZV4->ZV4_FORNEC
			cLojaTrp := ZV4->ZV4_LOJFOR
			cNomeTrp := ZV4->ZV4_NOMFOR

		EndIf

		//Preenche os novos dados na tabela ZFD (cargas).
		RecLock("ZFD",.F.)
			ZFD->ZFD_TPFRT  := cTpFrete
			ZFD->ZFD_SEQCAR := cSeqCrg
			ZFD->ZFD_ROTEIR := cCodRot
			ZFD->ZFD_DTENTR := dDtEntr
			ZFD->ZFD_CAMINH	:= cPlcPed
			ZFD->ZFD_MOTORI := cCpfM
			ZFD->ZFD_NOMEMO := NomeMoto
			ZFD->ZFD_TRANSP := cTranspF
			ZFD->ZFD_LOJTRA := cLojaTrp
			ZFD->ZFD_NOMTRA := cNomeTrp
			ZFD->ZFD_PESO   := SC5->C5_PBRUTO  //Everson - 13/08/2019. Chamado 044314.
			ZFD->ZFD_CAPVOL	:= SC5->C5_VOLUME1 //Everson - 13/08/2019. Chamado 044314.
		MsUnlock()
		
		//Everson-29/04/2019|CH:044314.
		//Verifica se houver a transferência do pedido para outra carga.
		cNCarg := ""
		chkCarga(cFilAnt,DToS(dDtEntr),cCodRot,cPlcPed,C5NUM,@cNCarg,ZFD->ZFD_COD)

		//Everson - 27/02/2019. Chamado 044314.	
		//Preenche os dados da nota fiscal na tabela ZFD (cargas).
		RecLock("ZFD",.F.)
			ZFD->ZFD_NUMNF := F2DOC
			ZFD->ZFD_SERIE := F2SERIE
			ZFD->ZFD_FEZNF := 'S'
		MsUnlock()
		
		//Everson-11/04/2019|CH:044314
		//Checa o preenchimento de nota fiscal nas demais entregas.
		chkNF(cPlcPed,ZFD->ZFD_ROTEIR,dDtEntr)
		
		//
		sNumCarg := ZFD->ZFD_COD
        sNumRot  := ZFD->ZFD_ROTEIR
        sCodTrns := ZFD->ZFD_TRANSP
        sCodPlc  := ZFD->ZFD_CAMINH
        cPlcCavM := ZFD->ZFD_PLCCAV
        nKmTot   := ZFD->ZFD_KMGER

		//Carrega os totalizadores.
		//Ricardo Lima-07/02/2019-044314
		//Ricardo Lima-14/02/2019-044314
		cQuery := " SELECT ZFD_PEDIDO, ZFD_NUMNF, ZFD_CLIENT+ZFD_LOJA ZFD_CLIENT, C5_PBRUTO AS ZFD_PESO, C5_VOLUME1 AS ZFD_CAPVOL, ZFD_CAMINH, C5_PESOL " //Everson - 13/08/2019. Chamado 044314.
		cQuery += " FROM "+RetSqlName("ZFD")+" ZFD "
		cQuery += " INNER JOIN "+REtSqlName("SC5")+" C5 ON C5_FILIAL=ZFD_FILIAL AND C5_NUM=ZFD_PEDIDO AND C5.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE ZFD_FILIAL+ZFD_COD IN ( "
		cQuery += "     SELECT ZFD_FILIAL+ZFD_COD "
		cQuery += "     FROM "+RetSqlName("ZFD")+" ZFD "
		cQuery += "     WHERE ZFD_PEDIDO = '"+C5NUM+"' "
		cQuery += "     AND ZFD.D_E_L_E_T_ = ' ' ) AND ZFD_ROTEIR = '" + sNumRot + "' "
		cQuery += " AND C5_BLQ = ' ' "
		
		//Everson - 27/02/2019. Chamado 044314.
		cQuery += " AND C5_PLACA <> '' " 
		cQuery += " AND C5_NOTA <> '' " 
		cQuery += " AND C5_SERIE <> '' " 
		cQuery += " AND C5_ROTEIRO <> '' "
	
		cQuery += " AND ZFD.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY ZFD_CLIENT "
	
		If Select("ADLOG42D") > 0
			ADLOG42D->(DbCloseArea())
	
		EndIf
	
		TcQuery cQuery NEW Alias "ADLOG42D"
	
		//
		While ! ADLOG42D->( Eof() )
	
			nSeqCar++
	
			//Totaliza a quantidade de pontos de entrega.
			// Ricardo Lima-07/02/2019-044314
			If Len(aNumCrg) >= 1 // Ricardo Lima-18/02/2019-044314~
	
				//Verifica se a chave código e loja do cliente já está no array.
				For CG:=1 to Len(aNumCrg)
					If aNumCrg[CG][1] = ADLOG42D->ZFD_CLIENT
						lAtNumCg := .F.
					EndIf
				Next
	
				//Se a chave código loja do cliente não estiver no array, esta é adiconada.
				If lAtNumCg
					Aadd( aNumCrg , { ADLOG42D->ZFD_CLIENT } )
					lAtNumCg := .T.
				EndIf
	
			Else
				Aadd( aNumCrg , { ADLOG42D->ZFD_CLIENT } )
	
			EndIf
	
			//Valida se o pedido possui nota fiscal emitida.
			If Empty(ADLOG42D->ZFD_NUMNF)
				lGerFrt := .F.
				nItsNf++
	
			EndIf
	
			//Totaliza a quantidade em Kg e caixas, obtém a placa do veículo.
			nTotKgC += ADLOG42D->ZFD_PESO
			nTotCxC += ADLOG42D->ZFD_CAPVOL
			cPlcFrt := ADLOG42D->ZFD_CAMINH
			nPesLiq += ADLOG42D->C5_PESOL
	
			ADLOG42D->(dbSkip())
	
			//Ricardo Lima-14/02/2019-044314
			lAtNumCg := .T.
	
		End 

		//Gera o registro de frete na tabela ZFA.
		If lGerFrt
				
			//Obtém os dados tabela de frete.
			cQuery := " SELECT ZF5_TABCOD, ZF5_TABDES, ZF5_VLRENT, ZF5_TABSAI, ZF5_ANOVEI, ZF5_CAPKG, ZF5_VLRMIN, ZF6_TABPRC, ZF5_TPFRPG, ZF5_TABTDE, ZF6_TABKMI, ZF6_TABKMF "
			cQuery += " FROM "+RetSqlName("ZF5")+" ZF5 "
			cQuery += " INNER JOIN "+RetSqlName("ZF6")+" ZF6 ON ZF6_FILIAL=ZF5_FILIAL AND ZF6_TABCOD=ZF5_TABCOD AND ZF6.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE ZF5_TABCOD IN ( "
			cQuery += "     SELECT ZV4_XFRET "
			cQuery += "     FROM "+RetSqlName("ZV4")+" ZV4 "
			cQuery += "     WHERE ZV4_PLACA IN ( "
			cQuery += "         SELECT C5_PLACA "
			cQuery += "         FROM "+RetSqlName("SC5")+" C5 "
			cQuery += "         WHERE C5_FILIAL = '"+FWxFilial("SC5")+"' "
			cQuery += "         AND C5_NUM = '"+C5NUM+"' "
			cQuery += "         AND C5.D_E_L_E_T_ = ' ' "
			cQuery += "         ) "
			cQuery += "     AND ZV4.D_E_L_E_T_ = ' ' "
			cQuery += "     ) "
			cQuery += " AND ZF5.D_E_L_E_T_ = ' ' "
	
			If Select("ADLOG42D") > 0
				ADLOG42D->(DbCloseArea())
	
			EndIf
	
			TcQuery cQuery NEW Alias "ADLOG42D"
			ADLOG42D->(DbGoTop())
	
			nVlrTab  := ADLOG42D->ZF5_TABSAI //Valor pago por saída mínima.
			nVlrEnt  := ADLOG42D->ZF5_VLRENT //Valor pago por entrega.
			nVlrUnFr := ADLOG42D->ZF6_TABPRC //Valor pago por Km rodado.
			nVlrMin  := ADLOG42D->ZF5_VLRMIN //Valor mínimo a ser pago.
	
			// RICARDO LIMA-15/02/2019|044314
			cCodTab := Alltrim(ADLOG42D->ZF5_TABCOD) //Código da tabela de frete.
			cDscTab := ADLOG42D->ZF5_TABDES //Descrição da tabela de frete.
	
			//Everson-27/02/2019. Chamado 044314.
			cTpFrt  := ADLOG42D->ZF5_TPFRPG //Tipo de frete.
			
			//Everson-22/04/2019. Chamado 044314.
			nVlrTon := Val(cValToChar(ADLOG42D->ZF5_TABTDE))
			
			//
			While ADLOG42D->(!Eof())
	
				If nKmTot >= ADLOG42D->ZF6_TABKMI .And. nKmTot <= ADLOG42D->ZF6_TABKMF
					nVlrUnFr := ADLOG42D->ZF6_TABPRC
	
				EndIf
	
				ADLOG42D->(DbSkip())
	
			End
			
			//
			ADLOG42D->(DbGoTop())
			
			//Valida se a tabela de frete está preenchida.
			If Empty(cCodTab)
				logZBE( "4G-Veículo sem tabela de frete cadastrada", "placa " + sCodPlc )
				frtCombina(sCodOcor,sCodTrns,sNumCarg,sNumRot,nVlrTab,nVlrMin,nVlrFrt,nTotKgC,nTotCxC,nKmTot,sCodPlc,cCodTab,cDscTab,dDtEntr,aNumCrg,cTpFrete,cTpFrt,C5NUM,nVlrTon,cPlcCavM,nPesLiq)
				RestArea(aArea)
				Return Nil
				
			EndIf

			//
			nVlrFrt += nVlrTab //Soma-se ao valor de frete, o valor de saída mínima.
			nVlrFrt += nVlrEnt * Len(aNumCrg) // Ricardo Lima-07/02/2019-044314 //Soma-se ao valor de frete, o valor por entrega vezes a quantidade de entregas.
			
			//Everson - 08/08/2019. Chamado 044314.
			If cTpFrt = "R"
				cObsFrR := ""
				nVlrFrt += vlrReg(sNumRot,dDtEntr,cCodTab,@cObsFrR,cTpNF,@nKmTot) //Everson - 19/03/2020. Chamado 054941.
				
			ElseIf cTpFrt = "P"
				cObsFrR := ""
				//nVlrFrt += (nTotKgC/1000) * vlrRegProd(sNumRot,dDtEntr,cCodTab,@cObsFrR,cTpNF,@nKmTot) //Everson - 19/03/2020. Chamado 054941.
				nVlrFrt += (nPesLiq/1000) * vlrRegProd(sNumRot,dDtEntr,cCodTab,@cObsFrR,cTpNF,@nKmTot)	//Everson - 01/07/2020. Chamado 059326.				
			Else
				nVlrFrt += nKmTot * nVlrUnFr
			
			EndIf
			
			//Everson - 27/02/2019. Chamado 044314.
			grvFrt(sCodOcor,sCodTrns,sNumCarg,sNumRot,nVlrTab,nVlrMin,nVlrFrt,nTotKgC,nTotCxC,nKmTot,sCodPlc,cCodTab,cDscTab,dDtEntr,aNumCrg,cTpFrete,cTpFrt,.F.,nVlrTon,cPlcCavM,cObsFrR,nPesLiq) //Everson - 08/08/2019. Chamado 044314.
	
		EndIf

	Else
		//Everson-17/04/2019|CH:044314.
		lGerZFD := .T.
		
	EndIf
	
	//Everson - 21/09/2019. Chamado 044314. 
	logZBE("6-Fim rotina de geração de frete","Empresa/Filial/Pedido/Data de entrega: " + cValToChar(cEmpAnt) +"/"+ cValToChar(cFilAnt) +"/"+ cValToChar(C5NUM) + "/" + DToS(dDtEntr))
	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} vlrRegProd
	Valor por tabela de região x produto. Chamado 044314. 
	@type  Static Function
	@author Everson
	@since 08/08/2019
	@version 01
	/*/
Static Function vlrRegProd(sNumRot,dDtEntr,cCodTab,cObs,cTpNF,nKmTot) //Everson - 19/03/2020. Chamado 054941.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local nVlr		:= 0
	
	Default cObs	:= ""

	//
	If cTpNF = "B" //Everson - 09/08/2019. Chamado 044314.
	
		//
		cQuery := ""
		cQuery += " SELECT " 
		cQuery += " TOP 1 RTRIM(LTRIM(A2_EST)) + '-' + RTRIM(LTRIM(A2_COD_MUN)) + '-' + RTRIM(LTRIM(TABREGCID.ZF6_NUMCID)) + '-' + RTRIM(LTRIM(C6_PRODUTO)) AS NM_FRM_PG, " 
		cQuery += " TABREGCID.VLR_CID AS VLR_FRT, TABREGCID.KM_ROD " //Everson - 19/03/2020. Chamado 054941.
		cQuery += " FROM " 
		cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("SC6") + " (NOLOCK) AS SC6 ON " 
		cQuery += " C5_FILIAL = C6_FILIAL " 
		cQuery += " AND C5_NUM = C6_NUM " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("SA2") + " (NOLOCK) AS SA2 ON " 
		cQuery += " C5_CLIENTE = A2_COD " 
		cQuery += " AND C5_LOJACLI = A2_LOJA " 
		cQuery += " INNER JOIN " 
		cQuery += " ( " 
		cQuery += " SELECT  " 
		cQuery += " ZF6_UF, ZF6_CIDADE, ZF6_NUMCID, ZF6_PRODUT, ZF6_VLRREG AS VLR_CID, ZF6_TABKMF AS KM_ROD " //Everson - 19/03/2020. Chamado 054941.
		cQuery += " FROM  " 
		cQuery += " " + RetSqlName("ZF5") + " (NOLOCK) AS ZF5  " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("ZF6") + " (NOLOCK) AS ZF6 ON " 
		cQuery += " ZF5_FILIAL = ZF6_FILIAL " 
		cQuery += " AND ZF5_TABCOD = ZF6_TABCOD " 
		cQuery += " WHERE  " 
		cQuery += " ZF5_FILIAL = ''  " 
		cQuery += " AND ZF6_CIDADE <> '' " 
		cQuery += " AND ZF5_TABCOD = '" + cValToChar(cCodTab) + "'  " 
		cQuery += " AND ZF5.D_E_L_E_T_ = '' " 
		cQuery += " AND ZF6.D_E_L_E_T_ = '' " 
		cQuery += " ) AS TABREGCID ON " 
		cQuery += " A2_EST = TABREGCID.ZF6_UF " 
		cQuery += " AND A2_COD_MUN = TABREGCID.ZF6_CIDADE " 
		cQuery += " AND C6_PRODUTO = TABREGCID.ZF6_PRODUT " 
		cQuery += " WHERE " 
		cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "' " 
		cQuery += " AND C5_DTENTR = '" + DToS(dDtEntr) + "' " 
		cQuery += " AND C5_ROTEIRO = '" + cValToChar(sNumRot) + "' " 
		cQuery += " AND C5_NOTA <> '' " 
		cQuery += " AND C5_SERIE <> '' " 
		cQuery += " AND SC5.D_E_L_E_T_ = '' " 
		cQuery += " AND SC6.D_E_L_E_T_ = '' " 	
		cQuery += " AND SA2.D_E_L_E_T_ = '' "
		cQuery += " ORDER BY VLR_FRT DESC "
			
	Else
	
		//
		cQuery := ""
		cQuery += " SELECT " 
		cQuery += " TOP 1 RTRIM(LTRIM(A1_EST)) + '-' + RTRIM(LTRIM(A1_COD_MUN)) + '-' + RTRIM(LTRIM(TABREGCID.ZF6_NUMCID)) + '-' + RTRIM(LTRIM(C6_PRODUTO)) AS NM_FRM_PG, " 
		cQuery += " TABREGCID.VLR_CID AS VLR_FRT, TABREGCID.KM_ROD " //Everson - 19/03/2020. Chamado 054941.
		cQuery += " FROM " 
		cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("SC6") + " (NOLOCK) AS SC6 ON " 
		cQuery += " C5_FILIAL = C6_FILIAL " 
		cQuery += " AND C5_NUM = C6_NUM " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("SA1") + " (NOLOCK) AS SA1 ON " 
		cQuery += " C5_CLIENTE = A1_COD " 
		cQuery += " AND C5_LOJACLI = A1_LOJA " 
		cQuery += " INNER JOIN " 
		cQuery += " ( " 
		cQuery += " SELECT  " 
		cQuery += " ZF6_UF, ZF6_CIDADE, ZF6_NUMCID, ZF6_PRODUT, ZF6_VLRREG AS VLR_CID, ZF6_TABKMF AS KM_ROD " //Everson - 19/03/2020. Chamado 054941.
		cQuery += " FROM  " 
		cQuery += " " + RetSqlName("ZF5") + " (NOLOCK) AS ZF5  " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("ZF6") + " (NOLOCK) AS ZF6 ON " 
		cQuery += " ZF5_FILIAL = ZF6_FILIAL " 
		cQuery += " AND ZF5_TABCOD = ZF6_TABCOD " 
		cQuery += " WHERE  " 
		cQuery += " ZF5_FILIAL = ''  " 
		cQuery += " AND ZF6_CIDADE <> '' " 
		cQuery += " AND ZF5_TABCOD = '" + cValToChar(cCodTab) + "'  " 
		cQuery += " AND ZF5.D_E_L_E_T_ = '' " 
		cQuery += " AND ZF6.D_E_L_E_T_ = '' " 
		cQuery += " ) AS TABREGCID ON " 
		cQuery += " A1_ESTE = TABREGCID.ZF6_UF " //Everson-09/08/2019(2)|CH:044314.
		cQuery += " AND A1_CODMUNE = TABREGCID.ZF6_CIDADE " 
		cQuery += " AND C6_PRODUTO = TABREGCID.ZF6_PRODUT " 
		cQuery += " WHERE " 
		cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "' " 
		cQuery += " AND C5_DTENTR = '" + DToS(dDtEntr) + "' " 
		cQuery += " AND C5_ROTEIRO = '" + cValToChar(sNumRot) + "' " 
		cQuery += " AND C5_NOTA <> '' " 
		cQuery += " AND C5_SERIE <> '' " 
		cQuery += " AND SC5.D_E_L_E_T_ = '' " 
		cQuery += " AND SC6.D_E_L_E_T_ = '' " 
		cQuery += " AND SA1.D_E_L_E_T_ = '' "	
		cQuery += " ORDER BY VLR_FRT DESC "
	
	EndIf
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG041P - vlrRegProd - cQuery " + cQuery )
	
	//
	If Select("VLR_REGP") > 0
		VLR_REGP->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "VLR_REGP"
	DbSelectArea("VLR_REGP")
		nVlr 	:= Val(cValToChar(VLR_REGP->VLR_FRT))
		cObs 	:= Alltrim(VLR_REGP->NM_FRM_PG)

		//Everson - 19/03/2020. Chamado 054941.
		If nKmTot <= 0
			nKmTot	:= Val(cValToChar(VLR_REGP->KM_ROD))
		EndIf 
		//

	VLR_REGP->(DbCloseArea())

	//
	RestArea(aArea)
	
Return nVlr
/*/{Protheus.doc} vlrReg
	Valor por tabela de região. Chamado 044314. 
	@type  Static Function
	@author Everson
	@since 08/08/2019
	@version 01
	/*/
Static Function vlrReg(sNumRot,dDtEntr,cCodTab,cObs,cTpNF,nKmTot) //Everson - 19/03/2020. Chamado 054941.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local nVlr		:= 0
	
	Default cObs	:= ""

	//
	If cTpNF = "B" //Everson - 09/08/2019. Chamado 044314.
	
		//
		cQuery := ""
		cQuery += " SELECT TOP 1   " 
		cQuery += " CASE WHEN ISNULL(TABREGCID.VLR_CID,0) <= 0 THEN    " 
		cQuery += " ' 2- PAGO POR ESTADO '  ELSE    " 
		cQuery += " ' 1- PAGO POR CIDADE '  END AS FRM_PG,   " 
		cQuery += " CASE WHEN ISNULL(TABREGCID.VLR_CID,0) <= 0 THEN    " 
		cQuery += " TABREGEST.ZF6_UF     ELSE    " 
		cQuery += " TABREGCID.ZF6_CIDADE + '-' + TABREGCID.ZF6_NUMCID  END AS NM_FRM_PG,   " 
		cQuery += " CASE WHEN ISNULL(TABREGCID.VLR_CID,0) <= 0 THEN    " 
		cQuery += " ISNULL(TABREGEST.VLR_EST,0) ELSE ISNULL(TABREGCID.VLR_CID,0) END AS VLR_EST, " 
		cQuery += " CASE WHEN ISNULL(TABREGCID.VLR_CID,0) <= 0 THEN TABREGEST.KM_ROD ELSE TABREGCID.KM_ROD END AS KM_ROD  " //Everson, 19/03/2020. Chamado 054941.
		cQuery += " FROM   " 
		cQuery += " " + RetSqlName("SC5") + "  (NOLOCK) AS SC5   " 
		cQuery += " INNER JOIN   " 
		cQuery += " " + RetSqlName("ZFD") + "  (NOLOCK) AS ZFD ON   " 
		cQuery += " C5_FILIAL = ZFD_FILIAL   " 
		cQuery += " AND C5_NUM = ZFD_PEDIDO   " 
		cQuery += " INNER JOIN   " 
		cQuery += " ( SELECT * FROM " + RetSqlName("SA2") + " (NOLOCK) AS SA2 WHERE SA2.D_E_L_E_T_ = '') AS SA2 ON " //Everson, 19/03/2020. Chamado 054941.
		cQuery += " C5_CLIENTE = A2_COD   " 
		cQuery += " AND C5_LOJACLI = A2_LOJA   " 
		cQuery += " LEFT OUTER JOIN   " 
		cQuery += " (   " 
		cQuery += " SELECT    " 
		cQuery += " ZF6_UF, ZF6_VLRREG AS VLR_EST, ZF6_TABKMF AS KM_ROD  " //Everson, 19/03/2020. Chamado 054941.
		cQuery += " FROM    " 
		cQuery += " " + RetSqlName("ZF5") + "  (NOLOCK) AS ZF5    " 
		cQuery += " INNER JOIN   " 
		cQuery += " " + RetSqlName("ZF6") + "  (NOLOCK) AS ZF6 ON   " 
		cQuery += " ZF5_FILIAL = ZF6_FILIAL   " 
		cQuery += " AND ZF5_TABCOD = ZF6_TABCOD   " 
		cQuery += " WHERE    " 
		cQuery += " ZF5_FILIAL = '" + FWxFilial("ZF5") + "'  " 
		cQuery += " AND ZF6_CIDADE = ''   " 
		cQuery += " AND ZF5_TABCOD = '" + cValToChar(cCodTab) + "' " 
		cQuery += " AND ZF5_TPFRPG = 'R'  " 
		cQuery += " AND ZF5.D_E_L_E_T_ = ''   " 
		cQuery += " AND ZF6.D_E_L_E_T_ = ''  " 

		//cQuery += " ORDER BY VLR_EST DESC " //Everson, 19/03/2020. Chamado 054941. //Everson - 08/10/2020. Chamado TI.

		cQuery += " ) AS TABREGEST ON   " 
		cQuery += " A2_EST = TABREGEST.ZF6_UF   " 
		cQuery += " LEFT OUTER JOIN   " 
		cQuery += " (   " 
		cQuery += " SELECT    " 
		cQuery += " ZF6_UF, ZF6_CIDADE, ZF6_NUMCID, ZF6_VLRREG AS VLR_CID, ZF6_TABKMF AS KM_ROD    " //Everson, 19/03/2020. Chamado 054941.
		cQuery += " FROM    " 
		cQuery += " " + RetSqlName("ZF5") + "  (NOLOCK) AS ZF5    " 
		cQuery += " INNER JOIN   " 
		cQuery += " " + RetSqlName("ZF6") + "  (NOLOCK) AS ZF6 ON   " 
		cQuery += " ZF5_FILIAL = ZF6_FILIAL   " 
		cQuery += " AND ZF5_TABCOD = ZF6_TABCOD   " 
		cQuery += " WHERE    " 
		cQuery += " ZF5_FILIAL = '" + FWxFilial("ZF5") + "'  " 
		cQuery += " AND ZF6_CIDADE <> ''   " 
		cQuery += " AND ZF5_TABCOD = '" + cValToChar(cCodTab) + "' " 
		cQuery += " AND ZF5_TPFRPG = 'R'  " 
		cQuery += " AND ZF5.D_E_L_E_T_ = ''   " 
		cQuery += " AND ZF6.D_E_L_E_T_ = ''   " 

		//cQuery += " ORDER BY VLR_CID DESC " //Everson, 19/03/2020. Chamado 054941. //Everson - 08/10/2020. Chamado TI.

		cQuery += " ) AS TABREGCID ON   " 
		cQuery += " A2_EST = TABREGCID.ZF6_UF  " 
		cQuery += " AND A2_COD_MUN = TABREGCID.ZF6_CIDADE   " 
		cQuery += " WHERE   " 
		cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "' " 
		cQuery += " AND C5_DTENTR = '" + DToS(dDtEntr) + "' " 
		cQuery += " AND C5_ROTEIRO = '" + cValToChar(sNumRot) + "' " 
		cQuery += " AND C5_NOTA <> ''   " 
		cQuery += " AND C5_SERIE <> ''   " 
		cQuery += " AND SC5.D_E_L_E_T_ = ''   " 
		cQuery += " AND ZFD.D_E_L_E_T_ = ''   " 
		cQuery += " ORDER BY FRM_PG, VLR_EST DESC " 	
	
	Else
		
		//
		cQuery := ""
		cQuery += " SELECT TOP 1   " 
		cQuery += " CASE WHEN ISNULL(TABREGCID.VLR_CID,0) <= 0 THEN    " 
		cQuery += " ' 2- PAGO POR ESTADO '  ELSE    " 
		cQuery += " ' 1- PAGO POR CIDADE '  END AS FRM_PG,   " 
		cQuery += " CASE WHEN ISNULL(TABREGCID.VLR_CID,0) <= 0 THEN    " 
		cQuery += " TABREGEST.ZF6_UF     ELSE    " 
		cQuery += " TABREGCID.ZF6_CIDADE + '-' + TABREGCID.ZF6_NUMCID  END AS NM_FRM_PG,   " 
		cQuery += " CASE WHEN ISNULL(TABREGCID.VLR_CID,0) <= 0 THEN    " 
		cQuery += " ISNULL(TABREGEST.VLR_EST,0) ELSE ISNULL(TABREGCID.VLR_CID,0) END AS VLR_EST, " 
		cQuery += " CASE WHEN ISNULL(TABREGCID.VLR_CID,0) <= 0 THEN TABREGEST.KM_ROD ELSE TABREGCID.KM_ROD END AS KM_ROD  " //Everson, 19/03/2020. Chamado 054941.
		cQuery += " FROM   " 
		cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5   " 
		cQuery += " INNER JOIN   " 
		cQuery += " " + RetSqlName("ZFD") + "  (NOLOCK) AS ZFD ON   " 
		cQuery += " C5_FILIAL = ZFD_FILIAL   " 
		cQuery += " AND C5_NUM = ZFD_PEDIDO   " 
		cQuery += " INNER JOIN   " 
		cQuery += " ( SELECT * FROM " + RetSqlName("SA1") + " (NOLOCK) AS SA1 WHERE SA1.D_E_L_E_T_ = '') AS SA1 ON " //Everson, 19/03/2020. Chamado 054941.
		cQuery += " C5_CLIENTE = A1_COD   " 
		cQuery += " AND C5_LOJACLI = A1_LOJA   " 
		cQuery += " LEFT OUTER JOIN   " 
		cQuery += " (   " 
		cQuery += " SELECT    " 
		cQuery += " ZF6_UF, ZF6_VLRREG AS VLR_EST, ZF6_TABKMF AS KM_ROD  " 
		cQuery += " FROM    " 
		cQuery += " " + RetSqlName("ZF5") + " (NOLOCK) AS ZF5    " 
		cQuery += " INNER JOIN   " 
		cQuery += " " + RetSqlName("ZF6") + " (NOLOCK) AS ZF6 ON   " 
		cQuery += " ZF5_FILIAL = ZF6_FILIAL   " 
		cQuery += " AND ZF5_TABCOD = ZF6_TABCOD   " 
		cQuery += " WHERE    " 
		cQuery += " ZF5_FILIAL = '" + FWxFilial("ZF5") + "'  " 
		cQuery += " AND ZF6_CIDADE = ''   " 
		cQuery += " AND ZF5_TABCOD = '" + cValToChar(cCodTab) + "' " 
		cQuery += " AND ZF5_TPFRPG = 'R'  " 
		cQuery += " AND ZF5.D_E_L_E_T_ = ''   " 
		cQuery += " AND ZF6.D_E_L_E_T_ = ''  " 

		//cQuery += " ORDER BY VLR_EST DESC " 

		cQuery += " ) AS TABREGEST ON   " 
		cQuery += " A1_ESTE = TABREGEST.ZF6_UF   " 
		cQuery += " LEFT OUTER JOIN   " 
		cQuery += " (   " 
		cQuery += " SELECT    " 
		cQuery += " ZF6_UF, ZF6_CIDADE, ZF6_NUMCID, ZF6_VLRREG AS VLR_CID, ZF6_TABKMF AS KM_ROD    " //Everson, 19/03/2020. Chamado 054941.
		cQuery += " FROM    " 
		cQuery += " " + RetSqlName("ZF5") + " (NOLOCK) AS ZF5    " 
		cQuery += " INNER JOIN   " 
		cQuery += " " + RetSqlName("ZF6") + " (NOLOCK) AS ZF6 ON   " 
		cQuery += " ZF5_FILIAL = ZF6_FILIAL   " 
		cQuery += " AND ZF5_TABCOD = ZF6_TABCOD   " 
		cQuery += " WHERE    " 
		cQuery += " ZF5_FILIAL = '" + FWxFilial("ZF5") + "'  " 
		cQuery += " AND ZF6_CIDADE <> ''   " 
		cQuery += " AND ZF5_TABCOD = '" + cValToChar(cCodTab) + "' " 
		cQuery += " AND ZF5_TPFRPG = 'R'  " 
		cQuery += " AND ZF5.D_E_L_E_T_ = ''   " 
		cQuery += " AND ZF6.D_E_L_E_T_ = ''   " 
		
		//cQuery += " ORDER BY VLR_CID DESC " //Everson, 19/03/2020. Chamado 054941. //

		cQuery += " ) AS TABREGCID ON   " 
		cQuery += " A1_ESTE = TABREGCID.ZF6_UF  " 
		cQuery += " AND A1_CODMUNE = TABREGCID.ZF6_CIDADE   " 
		cQuery += " WHERE   " 
		cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "' " 
		cQuery += " AND C5_DTENTR = '" + DToS(dDtEntr) + "' " 
		cQuery += " AND C5_ROTEIRO = '" + cValToChar(sNumRot) + "' " 
		cQuery += " AND C5_NOTA <> ''   " 
		cQuery += " AND C5_SERIE <> ''   " 
		cQuery += " AND SC5.D_E_L_E_T_ = ''   " 
		cQuery += " AND ZFD.D_E_L_E_T_ = ''   " 
		cQuery += " ORDER BY FRM_PG, VLR_EST DESC " 
	
	EndIf
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG041P - vlrReg - cQuery " + cQuery )
	
	//
	If Select("VLR_REG") > 0
		VLR_REG->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "VLR_REG"
	DbSelectArea("VLR_REG")
		nVlr 	:= Val(cValToChar(VLR_REG->VLR_EST))
		cObs 	:= Alltrim(VLR_REG->FRM_PG) + " " + Alltrim(VLR_REG->NM_FRM_PG)

		//Everson - 19/03/2020. Chamado 054941.
		If nKmTot <= 0
			nKmTot	:= Val(cValToChar(VLR_REG->KM_ROD))
		EndIf 
		//

	VLR_REG->(DbCloseArea())

	//
	RestArea(aArea)
	
Return nVlr
/*/{Protheus.doc} chkSZK
	Checa se há carga na tabela SZK. Chamado 044314. 
	@type  Static Function
	@author Everson
	@since 17/04/2019
	@version 01
	/*/
Static Function chkSZK(C5NUM)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local cNumCrg	:= ""	
	Local dDtEntr	:= ""
	Local cPlaca	:= ""
	Local cRot		:= ""	
	Local cCpfM    	:= ""
	Local cNomeMoto	:= ""
	Local cTranspF	:= ""
	Local cLojaTrp 	:= ""
	Local cNomeTrp 	:= ""
	Local lGerZFD	:= .T. //Everson-09/05/2019|CH:044314.
	Local nTotKm	:= 0   //Everson-28/05/2019|CH:044314.
	Local cPlcCavM	:= ""
	
	//
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(DbGoTop())
	If ! SC5->( DbSeek( FWxFilial("SC5") + C5NUM ) )
		Conout( DToC(Date()) + " " + Time() + " ADLOG041P - chkSZK - não encontrou pedido de venda " + cValToChar(C5NUM) )
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	//
	DbselectArea("ZV4")
	ZV4->(DbSetOrder(1))
	If ! ZV4->(DbSeek( FWxFilial("ZV4") + cValToChar(SC5->C5_PLACA) ))
		Conout( DToC(Date()) + " " + Time() + " ADLOG041P - chkSZK - não encontrou placa ZV4 " + cValToChar(SC5->C5_PLACA) ) 
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	//
	cCpfM     := ZV4->ZV4_CPF
	cNomeMoto := ZV4->ZV4_MOTORI
	cTranspF  := ZV4->ZV4_FORNEC
	cLojaTrp  := ZV4->ZV4_LOJFOR
	cNomeTrp  := ZV4->ZV4_NOMFOR
	
	//
	dDtEntr	 := SC5->C5_DTENTR
	cRot	 := cValToChar(SC5->C5_ROTEIRO)
	cPlaca	 := cValToChar(SC5->C5_PLACA)
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG041P - chkSZK - Encontrou carga SZK " + FWxFilial("SZK") + DToS(SC5->C5_DTENTR) + cValToChar(SC5->C5_PLACA) + cValToChar(SC5->C5_ROTEIRO) ) 
	
	//
	DbselectArea("ZFD")
	ZFD->(DbSetOrder(5))
	
	//Cria registro na tabela SZD.
	DbSelectArea("SC5")
	SC5->(DbSetOrder(Iif(cEmpAnt == "02",16,25))) //Everson - 11/08/2020. Chamado 059326.
	SC5->(DbGoTop())	
	If SC5->( DbSeek( FWxFilial("SC5") + DToS(dDtEntr) +  cRot + cPlaca ) )
		
		While ! SC5->(Eof()) .And. SC5->C5_FILIAL == FWxFilial("SC5") .And. SC5->C5_DTENTR == dDtEntr .And. SC5->C5_ROTEIRO == cRot .And. SC5->C5_PLACA == cPlaca
			
			ZFD->(DbGoTop())
			If ! ZFD->(DbSeek( FWxFilial("ZFD") + Alltrim(cValToChar(SC5->C5_NUM)) ))
				
				//
				If Empty(cNumCrg)
					chkCarga(cFilAnt,DToS(dDtEntr),cRot,cPlaca,Alltrim(cValToChar(SC5->C5_NUM)),@cNumCrg,"",@nTotKm) //Everson-28/05/2019|CH:044314.
	
					//
					If Empty(cNumCrg)
						cNumCrg := GetSXENum("ZFD","ZFD_COD")
						ConfirmSX8()
	
					EndIf
	
				EndIf
				
				//Everson-09/05/2019|CH:044314
				DbSelectArea("SC5")
				SC5->(DbSetOrder(Iif(cEmpAnt == "02",16,25))) //Everson - 11/08/2020. Chamado 059326.
				If SC5->( DbSeek( FWxFilial("SC5") + DToS(dDtEntr) + cRot + cPlaca ) )
					
					While ! SC5->(Eof()) .And. SC5->C5_FILIAL = FWxFilial("SC5") .And. SC5->C5_DTENTR = dDtEntr .And. SC5->C5_ROTEIRO = cRot
					
						//
						lGerZFD	:= .T.
						DbSelectArea("ZFD")
						ZFD->(DbSetOrder(5))
						If ZFD->(DbSeek(FWxFilial("ZFD") + SC5->C5_NUM ))
							lGerZFD	:= .F.
							
						EndIf
						
						//
						RecLock("ZFD",lGerZFD)
							ZFD->ZFD_FILIAL := FWxFilial("ZFD")
							ZFD->ZFD_COD    := cNumCrg
							ZFD->ZFD_SEQCAR := Padl(Alltrim(cValToChar(SC5->C5_SEQUENC)),4,"0")
							ZFD->ZFD_ROTEIR := cRot
							ZFD->ZFD_CAMINH := cPlaca
							ZFD->ZFD_MOTORI := cCpfM
							ZFD->ZFD_NOMEMO := cNomeMoto
							ZFD->ZFD_PESO   := SC5->C5_PBRUTO
							ZFD->ZFD_CAPVOL := SC5->C5_VOLUME1
							ZFD->ZFD_FEZNF  := 'N'
							ZFD->ZFD_FLGUNI := '2'
							ZFD->ZFD_TRANSP := cTranspF
							ZFD->ZFD_LOJTRA := cLojaTrp
							ZFD->ZFD_NOMTRA := cNomeTrp
							ZFD->ZFD_PEDIDO := Alltrim(cValToChar(SC5->C5_NUM))
							ZFD->ZFD_CLIENT := Alltrim(cValToChar(SC5->C5_CLIENTE))
							ZFD->ZFD_LOJA   := Alltrim(cValToChar(SC5->C5_LOJACLI))
							ZFD->ZFD_NOMECL := Alltrim(cValToChar(SC5->C5_NOMECLI))
							ZFD->ZFD_KMGER  := nTotKm //Everson-28/05/2019|CH:044314.
							ZFD->ZFD_FECHA  := 'N'
							ZFD->ZFD_NFDEV  := 'N'
							ZFD->ZFD_DTENTR := dDtEntr
							ZFD->ZFD_TPFRT  := SC5->C5_TPFRETE
							ZFD->ZFD_PLCCAV := cPlcCavM //Everson-08/07/2019|CH:044314.
							ZFD->ZFD_VA 	:= "1" //Everson - 16/01/2020. Chamado 054941.
						MsUnlock()
						
						SC5->(DbSkip())
						
					End
				
				EndIf
				//

			EndIf
			
			SC5->(DbSkip())
			
		End
		
	EndIf
				
	//
	RestArea(aArea)
	
Return .T.
/*/{Protheus.doc} chkNF
	Checa notas fiscais. Chamado 044314. 
	@type  Static Function
	@author Everson
	@since 11/04/2019
	@version 01
	/*/
Static Function chkNF(cPlcPed,sNumRot,dDtEntr)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local cUpdt		:= ""

	cUpdt += " UPDATE " + RetSqlName("ZFD") + " SET ZFD_NUMNF = C5_NOTA, ZFD_SERIE = C5_SERIE, ZFD_FEZNF = (CASE WHEN C5_NOTA <> '' THEN 'S' ELSE 'N' END), ZFD_PESO = C5_PBRUTO, ZFD_CAPVOL = C5_VOLUME1 " 
	cUpdt += " FROM  " 
	cUpdt += " " + RetSqlName("SC5") + " AS SC5 " 
	cUpdt += " INNER JOIN " 
	cUpdt += " " + RetSqlName("ZFD") + " AS ZFD ON " 
	cUpdt += " C5_FILIAL = ZFD_FILIAL " 
	cUpdt += " AND C5_ROTEIRO = ZFD_ROTEIR " 
	cUpdt += " AND C5_DTENTR = ZFD_DTENTR " 
	cUpdt += " AND C5_PLACA = ZFD_CAMINH " 
	cUpdt += " AND C5_NUM = ZFD_PEDIDO " 
	cUpdt += " WHERE  " 
	cUpdt += " C5_FILIAL = '" + FWxFilial("SC5") + "'  " 
	cUpdt += " AND C5_DTENTR = '" + DToS(dDtEntr) + "' " 
	cUpdt += " AND C5_ROTEIRO = '" + Alltrim(cValToChar(sNumRot)) + "' " 
	cUpdt += " AND C5_PLACA = '" + Alltrim(cValToChar(cPlcPed)) + "' " 
	cUpdt += " AND SC5.D_E_L_E_T_ = ''  " 
	
	ConOut( DToC(Date()) + " " + Time() +  " ADLOG041P - chkNF - cUpdt " + cValToChar(cUpdt) )
	
	//
	If TCSqlExec(cUpdt ) < 0
		ConOut( DToC(Date()) + " " + Time() +  " ADLOG041P - chkNF - TCSqlExec (ERRO) " + TCSQLError() )
		logZBE("Erro update chkNF " , "Placa/Roteiro/Entrega " + cValToChar(cPlcPed) + " " + cValToChar(sNumRot) + " " + DToC(dDtEntr) )
		
	EndIf

	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} grvFrt
	Checa frete combinado. Chamado 044314. 
	@type  Static Function
	@author Everson
	@since 21/02/19
	@version 01
	/*/
Static Function frtCombina(sCodOcor,sCodTrns,sNumCarg,sNumRot,nVlrTab,nVlrMin,nVlrFrt,nTotKgC,nTotCxC,nKmTot,sCodPlc,cCodTab,cDscTab,dDtEntr,aNumCrg,cTpFrete,cTpFrt,C5NUM,nVlrTon,cPlcCavM,nPesLiq)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local lFrtNgc	:= .T.
	Local cPara		:= ""
	Local cCopia	:= ""
	Local cAssunto	:= ""
	Local cMensagem	:= ""
	Local cArquivo	:= ""
	Local cUpdt		:= "" //Everson - 04/06/2019. Chamado 044314.
	
	//
	If Empty( Alltrim(cValToChar(sCodPlc)) )
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	//Não havendo tabela de frete vinculada ao veículo, verifica-se se há frete avulso.
	// RICARDO LIMA-15/02/2019|044314
	DbSelectArea("ZFF")
	ZFF->(DbSetOrder(4)) //ZFF_FILIAL, ZFF_DTENTR, ZFF_PLACA
	ZFF->(DbGoTop())
	If ZFF->(DbSeek( FWxFilial("ZFF") + DtoS(dDtEntr) + Alltrim(sCodPlc) + sNumRot ) ) //Everson-08/07/2019|CH:044314.
		If Alltrim(cValToChar(ZFF->ZFF_USANEG)) = 'N' .And. Alltrim(cValToChar(ZFF->ZFF_APROVA)) = 'S' //Everson-19/06/2019|CH:044314.
			nVlrTab := ZFF->ZFF_VALOR
			cCodTab := 'XXXXXX'
			cDscTab := 'Valor do Frete Negociado, Frete Avulso'
			lFrtNgc := .F.
			sCodOcor:= ZFF->ZFF_OCORR  //Everson - 24/05/2019. Chamado 044314.

			//Everson - 19/03/2020. Chamado 054941.
			If nKmTot <= 0
				nKmTot  := ZFF->ZFF_DISTAN

			EndIf
			//
			
			//Everson - 04/06/2019. Chamado 044314.
			cUpdt := " UPDATE " + RetSqlName("ZFD") + " SET ZFD_VLRFRT = " + cValToChar(nVlrTab) + " "
			cUpdt += " WHERE ZFD_FILIAL = '" + FWxFilial("ZFD") + "' AND ZFD_DTENTR = '" + DToS(dDtEntr) + "' " 
			cUpdt += " AND ZFD_ROTEIR = '" + cValToChar(sNumRot) + "' AND ZFD_CAMINH = '" + cValToChar(sCodPlc) + "' AND D_E_L_E_T_ = ''  "
			
			//Everson - 04/06/2019. Chamado 044314.
			TCSqlExec(cUpdt)
			
		Else 
			//Everson-08/07/2019|CH:044314.
			logZBE("2-Frete combinado não localizado","Data de entrega/placa/uso/aprovado/roteiro " + DtoS(dDtEntr) + " " + sCodPlc + " " + cValToChar(ZFF->ZFF_USANEG) + " " + cValToChar(ZFF->ZFF_APROVA) + " " + Alltrim(cValToChar(sNumRot)) )
			Conout( DToC(Date()) + " " + Time() + " ADLOG041P - 2-Frete combinado não localizado - Data de entrega/placa/uso/aprovado/roteiro " + DtoS(dDtEntr) + " " + sCodPlc + " " + cValToChar(ZFF->ZFF_USANEG) + " " + cValToChar(ZFF->ZFF_APROVA) + " " + Alltrim(cValToChar(sNumRot)) )
			
		EndIf
		
	Else
		//Everson-08/07/2019|CH:044314.
		logZBE("1-Frete combinado não localizado","Data de entrega/placa/roteiro " + DtoS(dDtEntr) + " " + sCodPlc + " " + Alltrim(cValToChar(sNumRot)) )
		Conout( DToC(Date()) + " " + Time() + " ADLOG041P - 1-Frete combinado não localizado - Data de entrega/placa/roteiro " + DtoS(dDtEntr) + " " + sCodPlc + " " + Alltrim(cValToChar(sNumRot))  )
		
	EndIf

	//Não havendo frete avulso, é enviado e-mail de alerta.
	If lFrtNgc 
		
		//Everson 06/03/2019. Chamado 044314. Valida se há placa para envio do e-mail.
		If ! Empty(cValToChar(sCodPlc)) .And. ! Empty(sNumRot)
			
			// RICARDO LIMA-01/02/2019|044314
			ConOut( DToC(Date()) + " " + Time() + " ADLOG041P - frtCombina - Problema na Geração do Frete, não localizado tabela de frete pela placa ou frete combinado. ")
			
			// Ricardo Lima-07/02/2019-044314
			cPara     := SuperGetMv( "MV_#LG0421" , .F. , '' ,  )
			
			//Everson-18/04/2019|CH:044314.
			cAssunto  := 'Problema na Geração do Frete'
			cMensagem := "<html> "
			cMensagem += "    <body> "
			cMensagem += "        <div style='text-align: left;'>&nbsp;</div> "
			cMensagem += "        <div style='text-align: left;'> "
			cMensagem += "            <span style='font-size:14px;'><span style='font-family:verdana,geneva,sans-serif;'>Erro na gera&ccedil;&atilde;o dos valores de frete.</span></span></div> "
			cMensagem += "        <div style='text-align: left;'>&nbsp;</div> "
			cMensagem += "        <div style='text-align: left;'> "
			cMensagem += "            <span style='font-size:14px;'><span style='font-family:verdana,geneva,sans-serif;'>Não localizado frete combinado ou tabela de frete.</span></span></div> "

			cMensagem += "        <div style='text-align: left;'>&nbsp;</div> "
			cMensagem += "        <div style='text-align: left;'> 
						
			cMensagem += "        <div style='text-align: left;'> "
			cMensagem += "            <span style='font-size:14px;'><span style='font-family:verdana,geneva,sans-serif;'>Data de entrega: "   + DToC(dDtEntr)  + "</span></span></div> "
			cMensagem += "        <div style='text-align: left;'> "
			cMensagem += "            <span style='font-size:14px;'><span style='font-family:verdana,geneva,sans-serif;'>Placa: "   + cValToChar(sCodPlc)  + "</span></span></div> "
			cMensagem += "        <div style='text-align: left;'> "
			cMensagem += "            <span style='font-size:14px;'><span style='font-family:verdana,geneva,sans-serif;'>Carga: "   + cValToChar(sNumCarg)  + "</span></span></div> "
			cMensagem += "        <div style='text-align: left;'> "
			cMensagem += "            <span style='font-size:14px;'><span style='font-family:verdana,geneva,sans-serif;'>Roteiro: " + cValToChar(sNumRot)   + "</span></span></div> "
			cMensagem += "        <div style='text-align: left;'> "
			cMensagem += "            <span style='font-size:14px;'><span style='font-family:verdana,geneva,sans-serif;'>Pedido: " + cValToChar(C5NUM)   + "</span></span></div> "


			cMensagem += "        <div style='text-align: left;'>&nbsp;</div> "
			cMensagem += "        <div style='text-align: left;'> 

			cMensagem += "        <div style='text-align: left;'> "
			cMensagem += "            <span style='font-size:14px;'><span style='font-family:verdana,geneva,sans-serif;'>Enviado em " + DToC(Date()) + " " + Time() + "</span></span></div> "
									
			cMensagem += "        <div style='text-align: left;'> "
			cMensagem += "            <span style='font-size:14px;'><span style='font-family:verdana,geneva,sans-serif;'>E-mail enviado automaticamente. Por favor, não responda.</span></span></div> " //Everson - 07/02/2020. Chamado 0541941.
			cMensagem += "    </body> "
			cMensagem += "</html> "
			
			U_F50En2WF(cPara,cCopia,cAssunto,cMensagem,cArquivo)
		
		EndIf
		
		//
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	//
	grvFrt(sCodOcor,sCodTrns,sNumCarg,sNumRot,nVlrTab,nVlrMin,nVlrFrt,nTotKgC,nTotCxC,nKmTot,sCodPlc,cCodTab,cDscTab,dDtEntr,aNumCrg,cTpFrete,cTpFrt,.T.,nVlrTon,cPlcCavM,"",nPesLiq)
	
	//
	RestArea(aArea)

Return .T.
/*/{Protheus.doc} grvFrt
	Efetua a gravação do frete na tabela ZFA. Chamado 044314. 
	@type  Static Function
	@author Everson
	@since 21/02/19
	@version 01
	/*/
Static Function grvFrt(sCodOcor,sCodTrns,sNumCarg,sNumRot,nVlrTab,nVlrMin,nVlrFrt,nTotKgC,nTotCxC,nKmTot,sCodPlc,cCodTab,cDscTab,dDtEntr,aNumCrg,cTpFrete,cTpFrt,lFrtFx,nVlrTon,cPlcCavM,cObsFrR,nPesLiq) //Everson - 08/08/2019. Chamado 044314.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local sDscOcos	:= ""
	Local sTpOcorr	:= ""
	Local lIclusão	:= .T.
	Local cUpdt		:= ""
	
	Default cObsFrR:= ""
	
	//
	logZBE( "5G-gravação de frete ZFA", "carga " + sNumCarg )
	Conout("ADLOG041P - roteiro " + sNumRot)
	
	//Everson - 10/07/2019. Chamado 044314.
	DbSelectArea("ZFA")
	ZFA->(DbSetOrder(15))
	If DbSeek( FWxFilial("ZFA") + DToS(dDtEntr) + Alltrim(sNumRot) )
		ConOut('Gerou Frete - Alteração')
		lIclusão := .F.

	Else
		ConOut('Gerou Frete - Inclusão')

	EndIf

	//Localiza o código da ocorrência no cadastro de ocorrências.
	DbSelectArea("ZF7")
	ZF7->(DbSetOrder(1))
	If ZF7->(DbSeek( FWxFilial("ZF7") + sCodOcor ))
		sCodOcor := ZF7->ZF7_CODIGO //Código da ocorrência.
		sDscOcos := ZF7->ZF7_DESC   //Descrição da ocorrência.
		sTpOcorr := ZF7->ZF7_DBCD   //Tipo de lançamento (crédito ou débito).

	EndIf

	//Localiza o cadastro da transportadora.
	DbSelectArea("SA4")
	SA4->(DbSetOrder(1))
	SA4->(DbSeek( FWxFilial("SA4") + sCodTrns ))

	//Grava o lançamento da ocorrência de frete.
	RecLock("ZFA",lIclusão)
		
		//Everson-15/03/2019|CH:044314.
		If lIclusão
			ZFA->ZFA_COD := GetSXEnum("ZFA","ZFA_COD")
			ConfirmSX8()
			
		EndIf
		
		//
		ZFA->ZFA_FILIAL := FWxFilial("ZFA")
		ZFA->ZFA_CARGA  := sNumCarg
		ZFA->ZFA_ROTEIR := sNumRot
		ZFA->ZFA_TRANSP := SA4->A4_COD
		ZFA->ZFA_LOJTRA := SA4->A4_LOJTRA
		ZFA->ZFA_NMTRAN := SA4->A4_NOME
		ZFA->ZFA_DATA   := dDtEntr //Everson - 21/03/2019. Chamado 044314.
		ZFA->ZFA_OCORRE := sCodOcor
		ZFA->ZFA_DC     := sTpOcorr
		ZFA->ZFA_DESCOC := sDscOcos

		//Valida o valor mínimo de frete.
		//Ricardo Lima-11/02/2019-044314
		//Everson-27/02/2019. Chamado 044314. Valida se o frete é fixo ou variável.
		If cTpFrt == "F" .Or. lFrtFx //Frete valor fixo.
			ZFA->ZFA_VALOR  := Iif( nVlrTab < nVlrMin, nVlrMin, nVlrTab )

		ElseIf ( cTpFrt == "V" .Or. cTpFrt == "R" .Or. 	cTpFrt == "P" )
			ZFA->ZFA_VALOR  := Iif( nVlrFrt < nVlrMin, nVlrMin, nVlrFrt )
			ZFA->ZFA_OBSERV	:= cObsFrR
			
		ElseIf 	cTpFrt == "T" //Everson-22/04/2019|CH:044314.
			ZFA->ZFA_VALOR	:= Iif( ((nTotKgC/1000) * nVlrTon) < nVlrMin, nVlrMin, ((nTotKgC/1000) * nVlrTon) )
			
		Else
			ZFA->ZFA_VALOR	:= 0
			ZFA->ZFA_OBSERV	:= "VLR N/D. VERIFIQUE O TIPO DE FRETE NO CADASTRO DA TABELA DE FRETE."

		EndIf

		//
		ZFA->ZFA_DATAIN := Date()
		ZFA->ZFA_HORA   := Time()
		ZFA->ZFA_CARKG  := nPesLiq
		ZFA->ZFA_CARCX  := nTotCxC
		ZFA->ZFA_KGBT   := nTotKgC
		ZFA->ZFA_KMTOT  := nKmTot
		ZFA->ZFA_TPMOV  := 'A'
		ZFA->ZFA_APRMOV := 'S'
		ZFA->ZFA_FECHA  := 'N'
		ZFA->ZFA_VEICUL := sCodPlc
		ZFA->ZFA_VEICPG := sCodPlc
		ZFA->ZFA_TABFRT := cCodTab
		ZFA->ZFA_DSCFRT := cDscTab
		ZFA->ZFA_DTENTR := dDtEntr
		ZFA->ZFA_NUMENT := Len(aNumCrg) // Ricardo Lima-07/02/2019-044314 // Ricardo Lima-05/02/2019-044314
		ZFA->ZFA_TPFRT  := cTpFrete 	// Ricardo Lima-18/02/2019-044314
		
		//Everson-15/03/2019|CH:044314
		ZFA->ZFA_TRANPA := SA4->A4_COD
		ZFA->ZFA_LJPPAG := SA4->A4_LOJTRA
		ZFA->ZFA_NMTPAG := SA4->A4_NOME
		//
		
		ZFA->ZFA_ENVPDG := 'N' //Everson-20/03/2019|CH:044314.
		ZFA->ZFA_PLCCAV := cPlcCavM //Everson-08/07/2019|CH:044314.
		ZFA->ZFA_VA		:= "1" //Everson - 21/10/2019. Chamado 029058. //Frete abatido.
		ZFA->ZFA_ORIGEM	:= "ADLOG041P" //Everson - 21/10/2019. Chamado 029058.
		ZFA->ZFA_TPBLQF := U_ADLG40I(1) //Everson - 21/10/2019. Chamado 029058.
		
	MsUnlock()

	//Efetua a marcação na tabela de frete avulso.
	//RICARDO LIMA-15/02/2019|044314
	//Everson-08/07/2019|CH:044314.
	If lFrtFx //Everson-17/09/2019 |CH:044314.
		DbSelectArea("ZFF")
		DbSetOrder(4) //ZFF_FILIAL, ZFF_DTENTR, ZFF_PLACA
		ZFF->(DbGoTop())
		If DbSeek( FWxFilial("ZFF") + Dtos(dDtEntr) + Alltrim(sCodPlc) + Alltrim(cValToChar(sNumRot)) )
			RecLock("ZFF",.F.)
				ZFF->ZFF_USANEG := 'S'
				//ZFF->ZFF_ROTFRT := sNumRot //Everson-21/06/2019|CH:044314.
				ZFF->ZFF_CARGA  := sNumCarg
			MsUnlock()

		EndIf

	EndIf
	
	//Everson - 05/06/2019. Chamado 044314.
	cUpdt := " UPDATE " + RetSqlName("ZFD") + " SET ZFD_VLRFRT = " + cValToChar(ZFA->ZFA_VALOR) + " "
	cUpdt += " WHERE ZFD_FILIAL = '" + FWxFilial("ZFD") + "' AND ZFD_DTENTR = '" + DToS(dDtEntr) + "' " 
	cUpdt += " AND ZFD_ROTEIR = '" + cValToChar(sNumRot) + "' AND ZFD_CAMINH = '" + cValToChar(sCodPlc) + "' AND ZFD_VLRFRT = 0 AND D_E_L_E_T_ = ''  "
	
	//Everson - 05/06/2019. Chamado 044314.
	TCSqlExec(cUpdt)

Return Nil
/*/{Protheus.doc} chkCarga
	Checa o número da carga. Chamado 044314. 
	@type  Static Function
	@author Everson
	@since 21/02/19
	@version 01
	/*/
Static Function chkCarga(cFil,cDtEnt,cRoteiro,cPlaca,cPed,cNCarg,cCargaSet,nTotKm)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local cUpdate	:= "" 
	Local cQuery	:= ""
	Local cCpfM    	:= ""
	Local NomeMoto 	:= ""
	Local cTranspF 	:= ""
	Local cLojaTrp 	:= ""
	Local cNomeTrp 	:= ""
	
	Default cCargaSet	:= ""
	Default nTotKm		:= 0 //Everson-28/05/2019|CH:044314.
	
	//
	Conout( DToS(Date()) + " " + Time() + " ADLOG041P - chkCarga - cCargaSet " + cValToChar(cCargaSet) )
	
	//Everson-29/04/2019|CH:044314.
	//Verifica se há alguma outra placa vinculada ao mesmo número de carga. Se houver gera um novo número de carga.
	If ! Empty(cCargaSet)
		DbSelectArea("ZFD")
		ZFD->(DbSetOrder(1))
		ZFD->(DbGoTop())
		If ZFD->(DbSeek( FWxFilial("ZFD") + cCargaSet ))
		
			While ! ZFD->(Eof()) .And. ZFD->ZFD_COD = cCargaSet
				
				//
				Conout( DToS(Date()) + " " + Time() + " ADLOG041P - chkCarga - cPlaca - ZFD->ZFD_CAMINH " + cValToChar(cPlaca) + " " + Alltrim(cValToChar(ZFD->ZFD_CAMINH)) )
				
				//
				nTotKm := ZFD->ZFD_KMGER //Everson-28/05/2019|CH:044314.
				
				//
				If cPlaca <> Alltrim(cValToChar(ZFD->ZFD_CAMINH))
					cNCarg := GetSXENum("ZFD","ZFD_COD")
					ConfirmSX8()
					Conout( DToS(Date()) + " " + Time() + " ADLOG041P - chkCarga - gerou - cNCarg " + cValToChar(cPlaca) + " " + Alltrim(cValToChar(cNCarg)) )
					Exit
					
				EndIf
				
				ZFD->(DbSkip())
				
			EndDo
								
		EndIf
		
	Else //Everson-09/05/2019|CH:044314.
		
		//
		cQuery := " SELECT TOP 1 ZFD_COD FROM " + RetSqlName("ZFD") + " WHERE ZFD_FILIAL = '" + FWxFilial("ZFA") + "' AND ZFD_DTENTR = '" + cValToChar(cDtEnt) + "' AND ZFD_ROTEIR = '" + cValToChar(cRoteiro) + "' AND D_E_L_E_T_ = '' "
		If Select("CHK_CRG") > 0
			CHK_CRG->(DbCloseArea())
			
		EndIf
		
		//
		TcQuery cQuery New Alias "CHK_CRG"
		DbSelectArea("CHK_CRG")
		If ! CHK_CRG->(Eof())
			cNCarg := CHK_CRG->ZFD_COD
		EndIf
		CHK_CRG->(DbCloseArea())
		
		//
		Conout( DToC(Date()) + " " + Time() +  " ADLOG041P - chkCarga - TcQuery - cNCarg " + cNCarg)
		
	EndIf
			
	//Obtém os dados da transportadora e motorista.
	DbselectArea("ZV4")
	ZV4->(DbSetOrder(1))
	If ZV4->(DbSeek( FWxFilial("ZV4") + cPlaca ))
		cCpfM    := ZV4->ZV4_CPF
		NomeMoto := ZV4->ZV4_MOTORI
		cTranspF := ZV4->ZV4_FORNEC
		cLojaTrp := ZV4->ZV4_LOJFOR
		cNomeTrp := ZV4->ZV4_NOMFOR

	EndIf
	
	//
	cCpfM    := ZV4->ZV4_CPF
	NomeMoto := ZV4->ZV4_MOTORI
	cTranspF := ZV4->ZV4_FORNEC
	cLojaTrp := ZV4->ZV4_LOJFOR
	cNomeTrp := ZV4->ZV4_NOMFOR
	
	//Everson-02/05/2019|CH:04431.
	If ! Empty(cNCarg) //Se for gerado um novo número de carga, todos os registros do roteiro são atualizados e, se houver frete gerado, este é apagado.
		
		//
		Conout( DToS(Date()) + " " + Time() + " ADLOG041P - chkCarga - 1 - UPDATE carga - cNCarg " + cNCarg )
		
		//
		cUpdate := " UPDATE " + RetSqlName("ZFD") + " SET " 
		cUpdate += " ZFD_COD = '" + cNCarg + "' "
		cUpdate += " WHERE ZFD_FILIAL = '" + FWxFilial("ZFD") + "' " 
		cUpdate += " AND ZFD_ROTEIR   = '" + cRoteiro + "' " 
		cUpdate += " AND ZFD_DTENTR   = '" + cDtEnt + "' " 
		cUpdate += " AND D_E_L_E_T_   = '' "
		
		//
		If TCSqlExec(cUpdate) < 0
			Conout( DToS(Date()) + " " + Time() + " ADLOG041P - chkCarga - [ERRO] - 1 - UPDATE carga - cNCarg " + cNCarg + " " + TCSQLError() )

		Else
		
			//
			DbSelectArea("ZFD")
			ZFD->(DbSetOrder(1))
			ZFD->(DbGoTop())
			If ZFD->( DbSeek( FWxFilial("ZFD") + cNCarg ) )
				
				//
				While ! ZFD->(Eof()) .And. ZFD->ZFD_FILIAL == FWxFilial("ZFD") .And. ZFD->ZFD_COD == cNCarg
					
					//Preenche os novos dados na tabela ZFD (cargas).
					RecLock("ZFD",.F.)
						ZFD->ZFD_TPFRT  := SC5->C5_TPFRETE
						ZFD->ZFD_SEQCAR := Padl(SC5->C5_SEQUENC,TamSX3("ZFD_SEQCAR")[01],'0') 
						ZFD->ZFD_ROTEIR := Padr(Alltrim(cValToChar(SC5->C5_ROTEIRO)),TamSX3("ZFD_ROTEIR")[01],' ')
						ZFD->ZFD_DTENTR := SC5->C5_DTENTR
						ZFD->ZFD_CAMINH	:= cPlaca
						ZFD->ZFD_MOTORI := cCpfM
						ZFD->ZFD_NOMEMO := NomeMoto
						ZFD->ZFD_TRANSP := cTranspF
						ZFD->ZFD_LOJTRA := cLojaTrp
						ZFD->ZFD_NOMTRA := cNomeTrp
					MsUnlock()
					
					ZFD->(DbSkip())
					
				End
			
			EndIf
			
		EndIf
		
		//Everson-03/05/2019|CH:044314.
		Conout( DToS(Date()) + " " + Time() + " ADLOG041P - chkCarga - 1 - UPDATE ZFA carga - cNCarg " + cNCarg )
		cUpdate := " UPDATE " + RetSqlName("ZFA") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE ZFA_FILIAL = '" + FWxFilial("ZFA") + "' AND ZFA_ROTEIR = '" + cRoteiro + "' AND ZFA_DTENTR = '" + cDtEnt + "' AND D_E_L_E_T_ = ''  "
		
		//
		If TCSqlExec(cUpdate) < 0
			Conout( DToS(Date()) + " " + Time() + " ADLOG041P - chkCarga - [ERRO] - 1 - UPDATE ZFA carga - cNCarg " + cNCarg + " " + TCSQLError() )
			
		EndIf

	ElseIf ! Empty(cCargaSet) //Se não houver gerado novo número de carga, todos os itens do roteiro são atualizados.
	
		Conout( DToS(Date()) + " " + Time() + " ADLOG041P - chkCarga - 2 - UPDATE carga - cCargaSet " + cCargaSet )
		cUpdate := " UPDATE " + RetSqlName("ZFD") + " SET ZFD_COD = '" + cCargaSet + "', ZFD_CAMINH = '" + cPlaca + "' WHERE ZFD_FILIAL = '" + FWxFilial("ZFD") + "' AND ZFD_ROTEIR = '" + cRoteiro + "' AND ZFD_DTENTR = '" + cDtEnt + "'  AND D_E_L_E_T_ = '' "
		
		//
		If TCSqlExec(cUpdate) < 0
			Conout( DToS(Date()) + " " + Time() + " ADLOG041P - chkCarga - [ERRO] - 2 - UPDATE carga - cCargaSet " + cCargaSet + " " + TCSQLError() )
			
		Else
		
			//
			DbSelectArea("ZFD")
			ZFD->(DbSetOrder(1))
			ZFD->(DbGoTop())
			If ZFD->( DbSeek( FWxFilial("ZFD") + cCargaSet ) )
				
				//
				While ! ZFD->(Eof()) .And. ZFD->ZFD_FILIAL == FWxFilial("ZFD") .And. ZFD->ZFD_COD == cNCarg
					
					//Preenche os novos dados na tabela ZFD (cargas).
					RecLock("ZFD",.F.)
						ZFD->ZFD_TPFRT  := SC5->C5_TPFRETE
						ZFD->ZFD_SEQCAR := Padl(SC5->C5_SEQUENC,TamSX3("ZFD_SEQCAR")[01],'0') 
						ZFD->ZFD_ROTEIR := Padr(Alltrim(cValToChar(SC5->C5_ROTEIRO)),TamSX3("ZFD_ROTEIR")[01],' ')
						ZFD->ZFD_DTENTR := SC5->C5_DTENTR
						ZFD->ZFD_CAMINH	:= cPlcPed
						ZFD->ZFD_MOTORI := cCpfM
						ZFD->ZFD_NOMEMO := NomeMoto
						ZFD->ZFD_TRANSP := cTranspF
						ZFD->ZFD_LOJTRA := cLojaTrp
						ZFD->ZFD_NOMTRA := cNomeTrp
					MsUnlock()
					
					ZFD->(DbSkip())
					
				End
			
			EndIf
			
		EndIf
		
		//Everson - 06/05/2019.
		cNCarg := cCargaSet
		
	EndIf
	
	//
	Conout( DToS(Date()) + " " + Time() + " ADLOG041P - chkCarga - cNCarg " + cValToChar(cNCarg) )
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} estorFrete
	Estorna o frete da carga informada. Chamado 044314. 
	@type  Static Function
	@author Everson
	@since 21/02/19
	@version 01
	/*/
Static Function estorFrete( cEmpAnt , cFilAnt , F2DOC , F2SERIE , F2CLIENTE , F2LOJA  , C5NUM , C5DTENTR )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local sNumCarg	:= ""
	Local lRet		:= .F.
	Local cDocEmit		:= "" //Everson-24/06/2019|CH:044314.
	Local cRoteiro	:= ""
	
	//Volta status do registro na tabela ZFD (cargas).
	DbSelectArea("ZFD")
	ZFD->(DbSetOrder(5))
	ZFD->(DbGoTop())
	If ZFD->(DbSeek(FWxFilial("ZFD") + C5NUM ))
		Conout( DToC(Date()) + " " + Time() +   " ADLOG041P - estorFrete pedido: " + cValToChar(C5NUM) )
		sNumCarg := ZFD->ZFD_COD
		cRoteiro := ZFD->ZFD_ROTEIR
		logZBE("Estorno ZFD (cargas)","pedido " + cValToChar(C5NUM) )
		lRet := .T.
		
	Else
		Conout( DToC(Date()) + " " + Time() +   " ADLOG041P - estorFrete - não localizou pedido: " + cValToChar(C5NUM) )
		DbSelectArea("ZFD")
		ZFD->(DbSetOrder(6))
		If ZFD->(DbSeek(FWxFilial("ZFD") + F2DOC + F2SERIE + F2CLIENTE + F2LOJA ))
			Conout( DToC(Date()) + " " + Time() +   " ADLOG041P - estorFrete doc/serie/cliente/loja: " + cValToChar(F2DOC) + cValToChar(F2SERIE) + cValToChar(F2CLIENTE) + cValToChar(F2LOJA) )
			sNumCarg := ZFD->ZFD_COD
			logZBE("Estorno ZFD (cargas)","nf/serie/cliente/loja " + F2DOC +"/"+ F2SERIE +"/"+ F2CLIENTE +"/"+ F2LOJA ) 
			lRet := .T.
			
		EndIf

	EndIf
	
	//
	If ! Empty(sNumCarg)
	
		DbSelectArea("ZFA")
		ZFA->(DbSetOrder(1))
		If ZFA->(DbSeek( FWxFilial("ZFA") + sNumCarg ))
			Conout( DToC(Date()) + " " + Time() +   " ADLOG041P - estorFrete ZFA carga: " + cValToChar(sNumCarg) )
			While ! ZFA->(Eof()) .and. ZFA->ZFA_CARGA == sNumCarg
				
				//
				Conout( DToC(Date()) + " " + Time() + " ADLOG041P - estorFrete + Alltrim(cValToChar(ZFA->ZFA_COD)) " + Alltrim(cValToChar(ZFA->ZFA_COD)) )
				
				//Everson-24/06/2019|CH:044314.
				cDocEmit := Alltrim(cValToChar(Posicione("ZFK",6,FWxFilial("ZFK") + Alltrim(cValToChar(ZFA->ZFA_COD)) + "1" + "1" ,"ZFK_STATUS" )))
				
				//
				Conout( DToC(Date()) + " " + Time() + " ADLOG041P - estorFrete + cDocEmit " + cDocEmit)
				
				//Everson - 25/07/2019. Chamado 044314.
				If ZFA->ZFA_FECHA <> 'S' .And. Empty(ZFA->ZFA_PEDCOM) .And. Empty(ZFA->ZFA_PEDADT) .And. cDocEmit <> "1" //Empty(ZFA->ZFA_CTE) // Everson-18/06/2019|CH:044314. //Everson-24/06/2019|CH:044314.
					dDtEntr := ZFA->ZFA_DTENTR
					cPlcPed := ZFA->ZFA_VEICUL
					RecLock("ZFA",.F.)
						ZFA->(dbDelete())
						ConOut('Frete Excluido')
					MsUnlock()
					logZBE("Estorno ZFA (frete)","Dt entrega/placa/carga " + DToC(dDtEntr) + "/" + cValToChar(cPlcPed) + cValToChar(sNumCarg) )
					lRet := .T.
				Else //Everson-10/04/2019.
					lRet   := .F.
					
				EndIf
				
				//
				ZFA->(dbSkip())
				
			End 
			
			// RICARDO LIMA-15/02/2019|044314
			If lRet
				
				//Everson-08/07/2019|CH:044314.
				DbSelectArea("ZFF")
				ZFF->(DbSetOrder(4))
				ZFF->(DbGoTop())
				If ZFF->(DbSeek( FWxFilial("ZFF") + DToS(dDtEntr) + Alltrim(cPlcPed) + Alltrim(cValToChar(cRoteiro)) ))
					
					RecLock("ZFF",.F.)
						ZFF->ZFF_USANEG := 'N'
						//ZFF->ZFF_ROTFRT := '' //Everson-21/06/2019|CH:044314.
						ZFF->ZFF_CARGA  := ''
					MsUnlock()
					logZBE("Estorno ZFF (frete combinado)","Dt entrega/placa/carga " + DToC(dDtEntr) + "/" + cValToChar(cPlcPed) + cValToChar(sNumCarg) )
				Else
					Conout( DToC(Date()) + " " + Time() + " ADLOG041P - [ERRO] estorFrete - Dt entrega/placa/roteiro " + DToC(dDtEntr) + "/" + cValToChar(cPlcPed) + " " + cValToChar(cRoteiro)  )
				
				EndIf
			
			EndIf
			
		EndIf
		
		// Everson-10/04/2019.
		If lRet
		
			RecLock("ZFD",.F.)
				ZFD->ZFD_NUMNF := ''
				ZFD->ZFD_SERIE := ''
				ZFD->ZFD_FEZNF := 'N'
			MsUnlock()
		
		EndIf
	
	Else
		Conout( DToC(Date()) + " " + Time() +   " ADLOG041P - estorFrete ZFA NÃO ***HÁ LANÇAMENTO PARA*** carga: " + cValToChar(sNumCarg) )
		lRet := .T.
		
	EndIf
	
	//
	Conout( DToC(Date()) + " " + Time() +   " ADLOG041P - estorFrete retorno " + cValToChar(lRet) )

	//
	RestArea(aArea)
	
Return lRet
/*/{Protheus.doc} ADLOG412
	Processa o recálculo de frete. Chamado 044314. 
	@type  Static Function
	@author Everson
	@since 28/02/19
	@version 01
	/*/
User Function ADLOG412(lPos) // U_ADLOG412()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea	  := GetArea()

	Default lPos := .F.

	U_ADINF009P('ADLOG041P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para geração de registros de frete de frango abatido.')
	
	//
	If ! lPos
		If ! Pergunte("RFZFRT",.T.)
			RestArea(aArea)
			Return Nil
			
		EndIf
		
		//
		sptEst(MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,.T.) //Everson-07/06/2019|CH:044314.
	
	Else
		//sptEst(dDtIni,dDtFim,cRotIni,cRotFim,lRefaz)
		If ZFA->ZFA_FECHA <> 'S' .And. Empty(ZFA->ZFA_PEDCOM) .And. Empty(ZFA->ZFA_PEDADT)
			sptEst(ZFA->ZFA_DTENTR,ZFA->ZFA_DTENTR,ZFA->ZFA_ROTEIR,ZFA->ZFA_ROTEIR,.T.)
		
		EndIf
	
	EndIf

	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} processrfz
	Processa o recálculo de frete. Chamado 044314. 
	@type  Static Function
	@author Everson
	@since 28/02/19
	@version 01
	/*/
Static Function sptEst(dDtIni,dDtFim,cRotIni,cRotFim,lRefaz) //Everson-30/05/2019|CH:044314. //Everson-07/06/2019|CH:044314.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local aPedidos	:= {}
	Local lFat		:= ISINCALLSTACK("U_CCSP_002") //Everson-07/06/2019|CH:044314.
	
	Default lRefaz	:= .F. //Everson-07/06/2019|CH:044314.
	
	//
	Conout( DToC(Date()) + " " + Time() +   " ADLOG041P - sptEst " )

	//
	cQuery := ""
	cQuery += " SELECT  "
	cQuery += " C5_FILIAL, C5_NOTA, C5_SERIE, C5_CLIENTE, C5_LOJACLI, C5_NUM, C5_DTENTR, C5_ROTEIRO " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("SC5") + " AS SC5 " 
	cQuery += " WHERE  " 
	cQuery += " C5_FILIAL = '" + FwxFilial("SC5") + "'  " 
	cQuery += " AND C5_DTENTR >= '" + DToS(dDtIni) + "'  " 
	cQuery += " AND C5_DTENTR <= '" + DToS(dDtFim) + "'  " 
	cQuery += " AND C5_PLACA <> '' "
	cQuery += " AND C5_ROTEIRO >= '" + cValToChar(cRotIni) + "' " 
	cQuery += " AND C5_ROTEIRO <= '" + cValToChar(cRotFim) + "' " 
	cQuery += " AND C5_NOTA <> '' " 
	cQuery += " AND C5_SERIE <> '' " 
	cQuery += " AND C5_ROTEIRO <> '' " 
	
	cQuery += " AND SC5.D_E_L_E_T_ = '' " 
	cQuery += " ORDER BY C5_FILIAL, C5_ROTEIRO, C5_SEQUENC, C5_NUM "
	
	Conout( DToC(Date()) + " " + Time() + " ADLOG041P - sptEst - cQuery " + cQuery )
	
	If Select("D_RFFRT") > 0
		D_RFFRT->(DbCloseArea())
		
	EndIf 
	
	TcQuery cQuery New Alias "D_RFFRT"
	DbSelectArea("D_RFFRT")
	While ! D_RFFRT->(Eof())
		
		//Everson-07/06/2019|CH:044314.
		If lFat .Or. lRefaz
			
			//Everson-07/06/2019|CH:044314.
			If Ascan(aPedidos,{|x| x[9] == D_RFFRT->C5_ROTEIRO }) == 0
				
				Aadd(aPedidos,{ cEmpAnt , D_RFFRT->C5_FILIAL , D_RFFRT->C5_NOTA , D_RFFRT->C5_SERIE , D_RFFRT->C5_CLIENTE , D_RFFRT->C5_LOJACLI  , D_RFFRT->C5_NUM , D_RFFRT->C5_DTENTR, D_RFFRT->C5_ROTEIRO } )
			
			EndIf
			
		Else
			Aadd(aPedidos,{ cEmpAnt , D_RFFRT->C5_FILIAL , D_RFFRT->C5_NOTA , D_RFFRT->C5_SERIE , D_RFFRT->C5_CLIENTE , D_RFFRT->C5_LOJACLI  , D_RFFRT->C5_NUM , D_RFFRT->C5_DTENTR, D_RFFRT->C5_ROTEIRO } )
		
		EndIf
		
		D_RFFRT->(DbSkip())
		
	End
	
	D_RFFRT->(DbCloseArea())

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG041P - sptEst - aPedidos " + cValToChar(Len(aPedidos)) )
	
	//
	If Len(aPedidos) > 0
		//Processa({|| 
		processrfz(aPedidos) 
		//},"Aguarde","Processando fretes...",.F.)
	
	EndIf

	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} processrfz
	Processa o recálculo de frete. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 28/02/19
	@version 01
	/*/
Static Function processrfz(aPedidos)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local nI		:= 1
	Local lStorFr	:= .T. //Everson-18/06/2019|CH:044314.
	
	//
	Conout("Quantidade de pedidos " + cValToChar(Len(aPedidos)) )
	
	ProcRegua(Len(aPedidos))
	
	//Realiza estorno do lançamento de frete.
	For nI := 1 To Len(aPedidos)
	
		IncProc(DToC(SToD(aPedidos[nI][8])) + " - " + cValToChar(aPedidos[nI][9]) )
		
		Conout("Estorno pedido " + cValToChar(aPedidos[nI][7]) )
		//StartJob( "U_ADLOG041P" , GetEnvServer() , .F. , aPedidos[nI][1] , aPedidos[nI][2] , aPedidos[nI][3] , aPedidos[nI][4] , aPedidos[nI][5]  , aPedidos[nI][6] , aPedidos[nI][7], '2', aPedidos[nI][8] )
		U_ADLOG041P( aPedidos[nI][1] , aPedidos[nI][2] , aPedidos[nI][3] , aPedidos[nI][4] , aPedidos[nI][5]  , aPedidos[nI][6] , aPedidos[nI][7], '2', aPedidos[nI][8],@lStorFr )
		
		//
		If lStorFr //Everson-18/06/2019|CH:044314.
			Conout("Geração de frete pedido " + cValToChar(aPedidos[nI][7]) )
			//StartJob( "U_ADLOG041P" , GetEnvServer() , .F. , aPedidos[nI][1] , aPedidos[nI][2] , aPedidos[nI][3] , aPedidos[nI][4] , aPedidos[nI][5]  , aPedidos[nI][6] , aPedidos[nI][7], '1', aPedidos[nI][8] )
			U_ADLOG041P( aPedidos[nI][1] , aPedidos[nI][2] , aPedidos[nI][3] , aPedidos[nI][4] , aPedidos[nI][5]  , aPedidos[nI][6] , aPedidos[nI][7], '1', aPedidos[nI][8] )
		
		EndIf
		
	Next nI
	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} logZBE
	Rotina para gerar log na tabela ZBE. Chamado 044314. 
	@type  Static Function
	@author Everson
	@since 21/02/19
	@version 01
	/*/
Static Function logZBE(cLog,cParam)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
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
		Replace ZBE_ROTINA	    With "ADLOG041P" 
	MsUnlock()

	//
	RestArea(aArea)

Return Nil
