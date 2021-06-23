#Include "RwMake.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "Totvs.ch"
#Include "Topconn.ch"    
/*/{Protheus.doc} User Function ADLOG049P
	(long_description)
	@type  Function
	@author Ricardo Lima
	@since 16/11/2018
	@version 01
	@history RICARDO LIMA-22/01/2019-Ch:044314-AJUSTE NA FORMATAÇÃO DO KM RODADO                          
	@history RICARDO LIMA-04/02/2019-Ch:044314-despreza km depois da virgula                              
	@history RICARDO LIMA-07/02/2019-Ch:044314-Controle de Duplicidade na montagem da carga               
	@history Ricardo Lima-11/02/2019-Ch:044314-Grava data de entrega na montagem da carga                  
	@history Ricardo Lima-18/02/2019-Ch:044314-Grava tipo de frete do pedido na carga                     
	@history Everson-28/02/2019-Ch:044314-Incluído log, removido cálculo de frete, incluído tratamento para não excluir registro de carga que já tenha nota fiscal vinculada.                       
	@history Everson-05/03/2019-Ch:044314-Correção da sequência da carga.                                  
	@history Everson-10/04/2019-Ch:044314-Alterada validação para geração da carga mesmo sem placa do veículo.                                                                                  
	@history Everson-28/05/2019-Ch:044314-Tratamento para importaçaõ de roteiro.                          
	@history Everson-29/05/2019-Ch:044314-Tratamento de validação de placa para buscar dados da transportadora.                                                                                         
	@history Everson-31/05/2019-Ch:044314-Adicionado cálculo do valor de frete.                           
	@history Everson-04/06/2019-Ch:044314-Adicionado cálculo de frete por nota fiscal e ajustado o cálculo do frete na tabela ZFD.                                                                      
	@history Everson-07/06/2019-Ch:044314-Adicionada opção para inclusão de frete combinado na tablea ZFF.
	@history Everson-19/06/2019-Ch:044314-Adicionada validação de roteiro para inclusão de frete          
	@history combinado na tablea ZFF.                                                                     
	@history Everson-05/07/2019-Ch:044314-Tratamento para otimizar a geração da carga.                    
	@history Adicionada placa do cavalo mecânico para geração do MDF-e para veículos articulados.         
	@history Everson-08/07/2019-Ch:044314-Correção erro de array.   
	@history Everson-16/01/2020-Ch:054941-Adicionado tratamento para tipo de frete. 
	@history Everson-17/01/2020-Ch:054941-Tratamento para retorno do valor de frete.                                      
	@history Chamado 058410 - WILLIAM COSTA - 27/05/2020 - Alterado o cálculo do Km quando vier do ravex
	/*/
User Function ADLOG049P( cEmpAnt , cFilAnt , aCargaFt )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local lAutoJob := .F.
	Local cNumCrg  := ""
	Local nC       := 0
	Local cPlcFrt  := ""
	Local cCpfM    := ''
	Local NomeMoto := ''
	Local cTranspF := ''
	Local cLojaTrp := ''
	Local cNomeTrp := ''
	Local cC5Pbr   := 0
	Local cC5Vol   := 0
	Local cClieFrt := ''
	Local cLojaCli := ''
	Local cNomeCli := ''
	Local dDtEntr  := SToD('') //Ricardo Lima-05/02/2019
	Local cTpFrete := '' //RICARDO LIMA-18/02/2019-Ch:044314
	Local cPedido  := '' //Everson - 28/0/2019. Chamado 044314.
	Local cRoteiro	:= ""
	Local cDtUpd	:= ""
	Local cUPdate	:= ""
	
	//Everson - 30/05/2019. Chamado 044314.
	Local nTotKm	:= 0
	Local nVlrFrt	:= 0
	Local cQuery	:= ""
	Local nVlrTab	:= 0
	Local nVlrEnt	:= 0
	Local nVlrUnFr	:= 0
	Local nVlrMin	:= 0
	Local cCodTab	:= ""
	Local cDscTab	:= ""
	Local cTpFrt	:= ""
	Local nVlrTon	:= 0
	Local lFrtFx	:= .F.
	Local cChvCrg	:= ""
	Local nTotKgC	:= 0
	Local nKmRod	:= 0
	Local nEntTot	:= 0
	Local nNumEnt	:= 0

	//
	If Select("SX6") == 0
	    lAutoJob := .T.
	    
    EndIf
    
    //
    If lAutoJob
        RpcSetType( 3 )
	    RpcSetEnv( cEmpAnt , cFilAnt ,,, "FAT")
	    
    EndIf

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
    	
    	//
	    Conout( DToC(Date()) + " " + Time() + " ADLOG049P Início geração de carga ")
	    
		//Everson-08/07/2019-Ch:044314.
		For nC :=1 To Len(aCargaFt)
		
			//
			cRoteiro := Alltrim(cValToChar(aCargaFt[nC][5]))
			cDtUpd   := Alltrim(cValToChar(aCargaFt[nC][9]))
			cPedido  := Alltrim(cValToChar(aCargaFt[nC][3]))
			
			//
			cUPdate := " UPDATE " + RetSqlName("ZFD") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE ZFD_FILIAL = '" + FWxFilial("ZFD") + "' AND ZFD_ROTEIR = '" + cRoteiro + "' AND ZFD_DTENTR = '" + cDtUpd + "' AND ZFD_FEZNF <> 'S' AND D_E_L_E_T_ <> '*' "		
			TCSqlExec(cUPdate)
			
			//
			cUPdate := " UPDATE " + RetSqlName("ZFD") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE ZFD_FILIAL = '" + FWxFilial("ZFD") + "' AND ZFD_PEDIDO = '" + cPedido + "' AND ZFD_FEZNF <> 'S' AND D_E_L_E_T_ <> '*' "		
			TCSqlExec(cUPdate)
			
		Next nC
		
		//
		For nC :=1 To Len(aCargaFt)
			 
			//
			cPedido  := aCargaFt[nC][3]
			dDtEntr  := SToD(aCargaFt[nC][9])
			
			Conout( DToC(Date()) + " " + Time() + " ADLOG049P For/Pedido " +  cValToChar(nC) + " " + cPedido )
			
			//
			DbselectArea("SC5")
			SC5->(DbSetOrder(1))
			If SC5->(DbSeek( FWxFilial("SC5") + cPedido ))
				cC5Pbr   := SC5->C5_PBRUTO
				cC5Vol   := SC5->C5_VOLUME1
				cClieFrt := SC5->C5_CLIENTE
				cLojaCli := SC5->C5_LOJACLI
				cNomeCli := SC5->C5_NOMECLI
				cTpFrete := SC5->C5_TPFRETE
			
			Else
				//Everson - 28/02/2019. Chamado 044314.
				logZBE("3-Não localizou pedido de venda","Pedido: " + cPedido )
				Loop
							
			EndIf
			
			//Everson-31/05/2019-Ch:044314.		
			//Obtém a próxima placa de veículo.
			If ( cChvCrg <> Alltrim(cValToChar(aCargaFt[nC][5])) + Alltrim(cValToChar(aCargaFt[nC][9])) )
								
				//
				If ! Empty(cChvCrg)
					
					//Everson-04/06/2019-Ch:044314.
					cQuery := ""
					cQuery += " SELECT  " 
					cQuery += " COUNT(DISTINCT RTRIM(LTRIM(C5_CLIENTE)) + RTRIM(LTRIM(C5_LOJACLI))) AS QTD_ENTR " 
					cQuery += " FROM " 
					cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
					cQuery += " WHERE " 
					cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "' " 
					cQuery += " AND C5_ROTEIRO = '" + cRoteiro + "' " 
					cQuery += " AND C5_DTENTR  = '" + cDtUpd + "' " 
					cQuery += " AND SC5.D_E_L_E_T_ = '' " 

					//
					If Select("D_QTDENTR") > 0
						D_QTDENTR->(DbCloseArea())
						
					EndIf
					
					//
					TcQuery cQuery New Alias "D_QTDENTR"
					DbSelectArea("D_QTDENTR")
						nNumEnt := Val(cValToChar(D_QTDENTR->QTD_ENTR))
					D_QTDENTR->(DbCloseArea())
				
				
					//
					nEntTot := nVlrEnt * nNumEnt ////Everson-04/06/2019-Ch:044314.
				
					//
					nVlrFrt := nEntTot + nTotKm + nVlrTab
				
					If cTpFrt == "F" .And. ! lFrtFx
						nVlrFrt  := nVlrTab
			
					ElseIf cTpFrt == "V" .And. ! lFrtFx
						
						//
						If nVlrMin > nVlrFrt
							nVlrFrt := nVlrMin
			
						EndIf
						
					ElseIf 	cTpFrt == "T" .And. ! lFrtFx
						nVlrFrt	:= (nTotKgC/1000) * nVlrTon
						
					ElseIf lFrtFx
						nVlrFrt := nVlrTab
						
					Else
						nVlrFrt	:= 0
			
					EndIf
					
					//
					cUPdate := ""
					cUPdate += " UPDATE " + RetSqlName("ZFD") + " SET " 
					cUPdate += " ZFD_VLRFRT = "  + cValToChar(nVlrFrt)  + " "
	/*					cUPdate += " ,ZFD_UNITKM = " + cValToChar(nVlrUnFr) + " "
					cUPdate += " ,ZFD_TOTKM = "  + cValToChar(nTotKm)   + " "
					cUPdate += " ,ZFD_SAIMIN = " + cValToChar(nVlrTab)  + " "
					cUPdate += " ,ZFD_TABCOD = " + cValToChar(cCodTab)  + " "
					cUPdate += " ,ZFD_DESTAB = " + cValToChar(cDscTab)  + " "*/
					cUPdate += " WHERE ZFD_FILIAL = '" + FWxFilial("ZFD") + "' AND ZFD_ROTEIR = '" + cRoteiro + "' AND ZFD_DTENTR = '" + cDtUpd + "' AND ZFD_FEZNF <> 'S' AND D_E_L_E_T_ <> '*' "
					
					//
					TCSqlExec(cUPdate)
				
				EndIf
				
				//
				cRoteiro:= Alltrim(cValToChar(aCargaFt[nC][5]))
				cDtUpd  := Alltrim(cValToChar(aCargaFt[nC][9]))
				cPlcFrt := Alltrim(aCargaFt[nC][7])
				
				//
				If cChvCrg <> Alltrim(cValToChar(aCargaFt[nC][5])) + Alltrim(cValToChar(aCargaFt[nC][9]))
					cNumCrg := GetSXENum("ZFD","ZFD_COD") //Everson - 05/03/2019. Chamado 044314.
					ConfirmSX8() //Everson - 05/03/2019. Chamado 044314.
				
				EndIf
				
				//
				cCpfM	:= ""
				NomeMoto:= ""
				cTranspF:= ""
				cLojaTrp:= ""
				cNomeTrp:= ""
				nVlrEnt	:= 0
				nVlrUnFr:= 0
				nVlrMin	:= 0
				cCodTab	:= ""
				cDscTab	:= ""
				cTpFrt	:= ""
				nVlrTon	:= 0
				lFrtFx	:= .F.
				nVlrFrt := 0
				nTotKgC := 0
				nTotKm  := 0
				nVlrTab	:= 0
				nKmRod  := 0
				nEntTot := 0
				nNumEnt := 0
									
				//
				If ! Empty(cPlcFrt)
				
					DbselectArea("ZV4")
					ZV4->(DbSetOrder(1))
					If ZV4->(DbSeek( FWxFilial("ZV4") + cPlcFrt ))
						cCpfM    := ZV4->ZV4_CPF
						NomeMoto := ZV4->ZV4_MOTORI
						cTranspF := ZV4->ZV4_FORNEC
						cLojaTrp := ZV4->ZV4_LOJFOR
						cNomeTrp := ZV4->ZV4_NOMFOR
						
					EndIf
					
					//Obtém os dados tabela de frete.
					cQuery := ""
					cQuery := " SELECT ZF5_TABCOD, ZF5_TABDES, ZF5_VLRENT, ZF5_TABSAI, ZF5_ANOVEI, ZF5_CAPKG, ZF5_VLRMIN, ZF6_TABPRC, ZF5_TPFRPG, ZF5_TABTDE "
					cQuery += " FROM "+RetSqlName("ZF5")+" ZF5 "
					cQuery += " INNER JOIN "+RetSqlName("ZF6")+" ZF6 ON ZF6_FILIAL=ZF5_FILIAL AND ZF6_TABCOD=ZF5_TABCOD AND ZF6.D_E_L_E_T_ = ' ' "
					cQuery += " WHERE ZF5_TABCOD IN ( "
					cQuery += "     SELECT ZV4_XFRET "
					cQuery += "     FROM "+RetSqlName("ZV4")+" ZV4 "
					cQuery += "     WHERE ZV4_PLACA IN ( "
					cQuery += "         SELECT C5_PLACA "
					cQuery += "         FROM "+RetSqlName("SC5")+" C5 "
					cQuery += "         WHERE C5_FILIAL = '"+FWxFilial("SC5")+"' "
					cQuery += "         AND C5_NUM = '" + cPedido + "' "
					cQuery += "         AND C5.D_E_L_E_T_ = ' ' "
					cQuery += "         ) "
					cQuery += "     AND ZV4.D_E_L_E_T_ = ' ' "
					cQuery += "     ) "
					cQuery += " AND ZF5.D_E_L_E_T_ = ' ' "
					
					//
					If Select("ADLOG49D") > 0
						ADLOG49D->(DbCloseArea())
		
					EndIf
					
					//
					TcQuery cQuery NEW Alias "ADLOG49D"
					ADLOG49D->(DbGoTop())
					
					//
					If ! Empty(ADLOG49D->ZF5_TABCOD)
						nVlrTab	:= ADLOG49D->ZF5_TABSAI
						nVlrEnt := ADLOG49D->ZF5_VLRENT
						nVlrUnFr:= ADLOG49D->ZF6_TABPRC
						nVlrMin := ADLOG49D->ZF5_VLRMIN
						cCodTab := ADLOG49D->ZF5_TABCOD
						cDscTab := ADLOG49D->ZF5_TABDES
						cTpFrt  := ADLOG49D->ZF5_TPFRPG
						nVlrTon := Val(cValToChar(ADLOG49D->ZF5_TABTDE))
						
					Else
					
						//
						DbSelectArea("ZFF")
						ZFF->(DbSetOrder(1))
						If (ZFF->(DbSeek( FWxFilial("ZFF") + DToS(dDtEntr) + cPlcFrt )))
							If ZFF->ZFF_USANEG = 'N' .And. ZFF->ZFF_APROVA = 'S' 
								nVlrTab := ZFF->ZFF_VALOR
								cCodTab := 'XXXXXX'
								cDscTab := 'Valor do Frete Negociado, Frete Avulso'
								lFrtFx := .T.
								
							EndIf
					
						EndIf
					
					EndIf
				
				EndIf
				
				//
				cChvCrg := cRoteiro + cDtUpd
				
			EndIf
						
			//
			nKmRod  := Val(Substr( ALLTRIM(aCargaFt[nC][8]),1, Len(ALLTRIM(aCargaFt[nC][8]))-1) )
			nTotKm  := Val(Substr( ALLTRIM(aCargaFt[nC][8]),1, Len(ALLTRIM(aCargaFt[nC][8]))-1) ) * nVlrUnFr

			//
			nTotKgC += cC5Pbr
			
			//Gera o registro na tabela ZFD, caso não existe o registro para o número do pedido de venda sendo processado.
			//RICARDO LIMA-07/02/2019-Ch:044314
			DbselectArea("ZFD")
			ZFD->(DbSetOrder(5))
			If ! ZFD->(DbSeek( FWxFilial("ZFD") + cPedido ))
				
				//
				RecLock("ZFD",.T.)
				
					ZFD->ZFD_FILIAL := FWxFilial("ZFD")
					ZFD->ZFD_COD    := cNumCrg
					ZFD->ZFD_SEQCAR := Strzero(Val(aCargaFt[nC][6]),4)
					ZFD->ZFD_ROTEIR := aCargaFt[nC][5]
					ZFD->ZFD_CAMINH := cPlcFrt
					ZFD->ZFD_MOTORI := cCpfM
					ZFD->ZFD_NOMEMO := NomeMoto
					ZFD->ZFD_PESO   := cC5Pbr
					ZFD->ZFD_CAPVOL := cC5Vol
					ZFD->ZFD_FEZNF  := 'N'
					ZFD->ZFD_FLGUNI := '2'
					ZFD->ZFD_TRANSP := cTranspF
					ZFD->ZFD_LOJTRA := cLojaTrp
					ZFD->ZFD_NOMTRA := cNomeTrp
					ZFD->ZFD_PEDIDO := cPedido
					ZFD->ZFD_CLIENT := cClieFrt
					ZFD->ZFD_LOJA   := cLojaCli
					ZFD->ZFD_NOMECL := cNomeCli
					ZFD->ZFD_KMGER  := IIF(IsInCallStack('U_ADLOG056P') == .T.,Val(Substr( ALLTRIM(aCargaFt[nC][8]),1, Len(ALLTRIM(aCargaFt[nC][8]))) ),Val(Substr( ALLTRIM(aCargaFt[nC][8]),1, Len(ALLTRIM(aCargaFt[nC][8]))-1) )) //RICARDO LIMA-22/01/2019-Ch:044314-AJUSTE NA FORMATAÇÃO DO KM RODADO //RICARDO LIMA-04/02/2019-Ch:044314
					ZFD->ZFD_FECHA  := 'N'
					ZFD->ZFD_NFDEV  := 'N'
					ZFD->ZFD_DTENTR := dDtEntr
					ZFD->ZFD_TPFRT  := cTpFrete	
					ZFD->ZFD_PLCCAV	:= ""	
					ZFD->ZFD_VA		:= "1" //Everson - 16/01/2020. Chamado 054941.	
				MsUnlock()
				
				//Everson - 28/02/2019. Chamado 044314.
				logZBE("4-Gravou carga","Carga/placa/roteiro/Km: " + cNumCrg + "/" + cPlcFrt + "/" + cValToChar(aCargaFt[nC][5]) +"/"+ cValToChar(Val(Substr( ALLTRIM(aCargaFt[nC][8]),1, Len(ALLTRIM(aCargaFt[nC][8]))-1) )) +"-"+;
				       ALLTRIM(aCargaFt[nC][8]) )
				
			Else
				//Everson - 28/02/2019. Chamado 044314.
				Conout("ADLOG049P - Não gravou carga, já há pedido de venda na tabela ZFD Pedido: " + cPedido )
				logZBE("5-Não gravou carga, já pedido de venda na tabela ZFD","Pedido: " + cPedido )
						
			EndIf
			
		Next nC
		
		//Everson-04/06/2019-Ch:044314.
		cUPdate := ""
		cUPdate += " UPDATE " + RetSqlName("ZFD") + " SET " 
		cUPdate += " ZFD_VLRFRT = "  + cValToChar(nVlrFrt)  + " "
	/*					cUPdate += " ,ZFD_UNITKM = " + cValToChar(nVlrUnFr) + " "
						cUPdate += " ,ZFD_TOTKM = "  + cValToChar(nTotKm)   + " "
						cUPdate += " ,ZFD_SAIMIN = " + cValToChar(nVlrTab)  + " "
						cUPdate += " ,ZFD_TABCOD = " + cValToChar(cCodTab)  + " "
						cUPdate += " ,ZFD_DESTAB = " + cValToChar(cDscTab)  + " "*/
		cUPdate += " WHERE ZFD_FILIAL = '" + FWxFilial("ZFD") + "' AND ZFD_ROTEIR = '" + cRoteiro + "' AND ZFD_DTENTR = '" + cDtUpd + "' AND ZFD_FEZNF <> 'S' AND D_E_L_E_T_ <> '*' "
		
		//
		TCSqlExec(cUPdate)

	//Libera o ambiente.
	If lAutoJob
        RpcClearEnv()
        
    EndIf

Return Nil
/*/{Protheus.doc} recalFrt 
	Rotina para recálculo do frete na tabela ZFD. Chamado 044314
	@type  Static Function
	@author Everson
	@since 31/05/2019
	@version 01
	/*/
Static Function recalFrt(cPlaca,dDtUpd,cRoteiro,cCavMec) //Everson-05/07/2019-Ch:044314.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea			:= GetArea()
	Local cUPdate		:= ""
	Local cCpfM    		:= ""
	Local NomeMoto 		:= ""
	Local cTranspF 		:= ""
	Local cLojaTrp 		:= ""
	Local cNomeTrp 		:= ""
	Local nVlrFrt	 	:= 0
	Local nVlrUnFr		:= 0
	Local nTotKm		:= 0
	Local nVlrTab		:= 0
	Local nEntTot		:= 0
	Local nVlrMin		:= 0
	Local cCodTab		:= ""
	Local cDscTab		:= ""
	Local cQuery		:= ""
	Local lFrtFx		:= .F.
	Local lLocFrt		:= .F.
	Local nTotKgC		:= 0
	Local xPula			:= Chr(13) + Chr(10)
	Local cTpFrt		:= ""
	
	//
	cPlaca 	:= Alltrim(cValToChar(cPlaca))
	cRoteiro:= Alltrim(cValToChar(cRoteiro))
	cCavMec := Alltrim(cValToChar(cCavMec)) //Everson-05/07/2019-Ch:044314.
	
	//
	If Empty(cPlaca)
	
		//
		cUPdate := ""
		cUPdate += " UPDATE " + RetSqlName("ZFD") + " SET " 
		cUPdate += " D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
		cUPdate += " WHERE ZFD_FILIAL = '" + FWxFilial("ZFD") + "' AND ZFD_ROTEIR = '" + cRoteiro + "' AND ZFD_DTENTR = '" + DToS(dDtUpd) + "' AND ZFD_FEZNF <> 'S'  AND D_E_L_E_T_ <> '*' " //AND ZFD_FEZNF <> 'S'

		//
		Conout( DToC(Date()) + " " + Time() + " ADLOG049P - recalFrt - cUPdate 1 " + cUPdate )
				
		//
		TCSqlExec(cUPdate)
		
		RestArea(aArea)	
		Return .T.
		
	EndIf
	
	//
	DbselectArea("ZV4")
	ZV4->(DbSetOrder(1))
	If ZV4->(DbSeek( FWxFilial("ZV4") + cPlaca ))
		cCpfM    := ZV4->ZV4_CPF
		NomeMoto := ZV4->ZV4_MOTORI
		cTranspF := ZV4->ZV4_FORNEC
		cLojaTrp := ZV4->ZV4_LOJFOR
		cNomeTrp := ZV4->ZV4_NOMFOR
		
	EndIf
	
	//Obtém os dados tabela de frete.
	cQuery := ""
	cQuery := " SELECT ZF5_TABCOD, ZF5_TABDES, ZF5_VLRENT, ZF5_TABSAI, ZF5_ANOVEI, ZF5_CAPKG, ZF5_VLRMIN, ZF6_TABPRC, ZF5_TPFRPG, ZF5_TABTDE "
	cQuery += " FROM "+RetSqlName("ZF5")+" ZF5 "
	cQuery += " INNER JOIN "+RetSqlName("ZF6")+" ZF6 ON ZF6_FILIAL=ZF5_FILIAL AND ZF6_TABCOD=ZF5_TABCOD AND ZF6.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE ZF5_TABCOD IN ( "
	cQuery += "     SELECT ZV4_XFRET "
	cQuery += "     FROM "+RetSqlName("ZV4")+" ZV4 "
	cQuery += "     WHERE ZV4_PLACA = '" + cPlaca + "' "
	cQuery += "     AND ZV4.D_E_L_E_T_ = ' ' "
	cQuery += "     ) "
	cQuery += " AND ZF5.D_E_L_E_T_ = ' ' "
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG049P - recalFrt - cQuery 1 " + cQuery )
	
	//
	If Select("ADLOG49D") > 0
		ADLOG49D->(DbCloseArea())

	EndIf
	
	//
	TcQuery cQuery NEW Alias "ADLOG49D"
	ADLOG49D->(DbGoTop())
	
	//
	If ! Empty(ADLOG49D->ZF5_TABCOD)
	
		//
		nVlrTab	:= ADLOG49D->ZF5_TABSAI
		nVlrEnt := ADLOG49D->ZF5_VLRENT
		nVlrUnFr:= ADLOG49D->ZF6_TABPRC
		nVlrMin := ADLOG49D->ZF5_VLRMIN
		cCodTab := ADLOG49D->ZF5_TABCOD
		cDscTab := ADLOG49D->ZF5_TABDES
		cTpFrt  := ADLOG49D->ZF5_TPFRPG
		nVlrTon := Val(cValToChar(ADLOG49D->ZF5_TABTDE))
		
		//Everson-04/06/2019-Ch:044314.
		cQuery := ""
		cQuery += " SELECT  " 
		cQuery += " MAX(ZFD_KMGER) AS ZFD_KMGER, COUNT(DISTINCT RTRIM(LTRIM(ZFD_CLIENT)) + RTRIM(LTRIM(ZFD_LOJA)) ) AS TOT_PED, SUM(ZFD_PESO) AS ZFD_PESO " 
		cQuery += " FROM  " 
		cQuery += " " + RetSqlName("ZFD") + " (NOLOCK) AS ZFD " 
		cQuery += " WHERE " 
		cQuery += " ZFD_FILIAL = '" + FWxFilial("ZFD") + "' " 
		cQuery += " AND ZFD_ROTEIR = '" + cRoteiro + "' " 
		cQuery += " AND ZFD_DTENTR = '" + DToS(dDtUpd) + "' " 
		cQuery += " AND ZFD.D_E_L_E_T_ = '' " 
		
		//
		Conout( DToC(Date()) + " " + Time() + " ADLOG049P - recalFrt - cQuery 2 " + cQuery )
		
		//
		If Select("ADLOG49D2") > 0
			ADLOG49D2->(DbCloseArea())
	
		EndIf
		
		//
		TcQuery cQuery NEW Alias "ADLOG49D2"
		ADLOG49D2->(DbGoTop())
		
		//
		If ! ADLOG49D2->(Eof())
			
			nEntTot := Val(cValToChar(ADLOG49D2->TOT_PED))   * nVlrEnt
			nTotKm  := Val(cValToChar(ADLOG49D2->ZFD_KMGER)) * nVlrUnFr
			nTotKgC := Val(cValToChar(ADLOG49D2->ZFD_PESO))
			
			nVlrFrt := nEntTot + nTotKm + nVlrTab
			
			Conout( DToC(Date()) + " " + Time() + " ADLOG049P - recalFrt - nVlrFrt 1 " + cValToChar(nVlrFrt) )
			
		EndIf
		
		//
		lLocFrt := .T.
		
		ADLOG49D2->(DbCloseArea())
			
	Else

		//
		DbSelectArea("ZFF")
		ZFF->(DbSetOrder(1))
		If (ZFF->(DbSeek( FWxFilial("ZFF") + DToS(dDtUpd) + cPlaca )))
			If ZFF->ZFF_USANEG = 'N' .And. Alltrim(cValToChar(ZFF->ZFF_ROTFRT)) == Alltrim(cValToChar(cRoteiro)) //Everson - 19/06/2019. Chamado 044314.
				nVlrTab := ZFF->ZFF_VALOR
				cCodTab := 'XXXXXX'
				cDscTab := 'Valor do Frete Negociado, Frete Avulso'
				lFrtFx  := .T.
				lLocFrt := .T.
				
			EndIf
	
		EndIf
	
	EndIf
	
	//
	ADLOG49D->(DbCloseArea())
	
	//
	If ! lLocFrt
		
		//Everson-07/06/2019-Ch:044314.
		If MsgYesNo("Não foi localizada tabela de frete ou frete combinado para a placa abaixo.Deseja efetuar o lançamento?" + xPula +;
				"Roteiro: " + cRoteiro + xPula +;
				"Placa: "   + cPlaca + xPula +;
				"Entrega:"  + DToC(dDtUpd) ,"Função recalFrt(ADLOG049P)")
				
			MsAguarde({|| inclZFF(cRoteiro,dDtUpd,cPlaca,cTranspF,cLojaTrp,cNomeTrp) },"Aguarde","Carregando interface...")	
		
		EndIf
	
	EndIf
	
	//
	If cTpFrt == "F" .And. ! lFrtFx
		nVlrFrt  := nVlrTab

	ElseIf cTpFrt == "V" .And. ! lFrtFx
		
		//
		If nVlrMin > nVlrFrt
			nVlrFrt := nVlrMin

		EndIf
		
	ElseIf 	cTpFrt == "T" .And. ! lFrtFx
		nVlrFrt	:= (nTotKgC/1000) * nVlrTon
		
	ElseIf lFrtFx
		nVlrFrt := nVlrTab
		
	Else
		nVlrFrt	:= 0

	EndIf
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG049P - recalFrt - nVlrFrt 2 " + cValToChar(nVlrFrt) )
	
	//
	cUPdate := ""
	cUPdate += " UPDATE " + RetSqlName("ZFD") + " SET " 
	cUPdate += " ZFD_VLRFRT  = "  + cValToChar(nVlrFrt)   + " "
	cUPdate += " ,ZFD_CAMINH = '" + cValToChar(cPlaca)    + "' "
	
	cUPdate += " ,ZFD_PLCCAV = '" + cValToChar(cCavMec)    + "' " //Everson-05/07/2019-Ch:044314.
	
	cUPdate += " ,ZFD_MOTORI = '" + cValToChar(cCpfM)     + "' "
	cUPdate += " ,ZFD_NOMEMO = '" + cValToChar(NomeMoto)  + "' "
	cUPdate += " ,ZFD_TRANSP = '" + cValToChar(cTranspF)  + "' "
	cUPdate += " ,ZFD_LOJTRA = '" + cValToChar(cLojaTrp)  + "' "
	cUPdate += " ,ZFD_NOMTRA = '" + cValToChar(cNomeTrp)  + "' "
	
	/*	cUPdate += " ,ZFD_UNITKM = "  + cValToChar(nVlrUnFr)   + " "
	cUPdate += " ,ZFD_TOTKM  = "  + cValToChar(nTotKm)     + " "
	cUPdate += " ,ZFD_SAIMIN = "  + cValToChar(nVlrTab)    + " "
	cUPdate += " ,ZFD_TABCOD = "  + cValToChar(cCodTab)    + " "
	cUPdate += " ,ZFD_DESTAB = "  + cValToChar(cDscTab)    + " " */
	cUPdate += " WHERE ZFD_FILIAL = '" + FWxFilial("ZFD") + "' AND ZFD_ROTEIR = '" + cRoteiro + "' AND ZFD_DTENTR = '" + DToS(dDtUpd) + "' AND ZFD_FEZNF <> 'S'  AND D_E_L_E_T_ <> '*' " //AND ZFD_FEZNF <> 'S'
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG049P - recalFrt - cUPdate 3 " + cUPdate )
		
	//
	TCSqlExec(cUPdate)
	
	//
	RestArea(aArea)
	
Return .T.
/*/{Protheus.doc} inclZFF
	Inclui registro na tabela ZFF (frete combinado). Chamado 044314
	@type  Static Function
	@author user
	@since 07/06/2019
	@version 01
	/*/
Static Function inclZFF(cRoteiro,dDtUpd,cPlaca,cTranspF,cLojaTrp,cNomeTrp)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	      := GetArea()
	Local aButtons	  := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}	
	Local nRet		  := Nil
	
	Private AD49DATA 	:= dDtUpd
	Private AD49PLACA	:= cPlaca
	Private AD49TRAN	:= cTranspF
	Private AD49LOJA	:= cLojaTrp
	Private AD49NOME	:= cNomeTrp
	Private AD49ROTE	:= cRoteiro //Everson - 19/06/2019. Chamado 044314.
	
	//
	nRet := FWExecView("",'ADLOG053P', 3, , { || .T. }, , ,aButtons )

	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} nomeStaticFunction
	Retorna o valor do frete para preenchimento no xml da NF. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 04/06/2019
	@version 01
	/*/
Static Function getVlrFrt(cNFFrt,cSrFrt)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea	 	:= GetArea()
	Local cQuery	:= ""
	Local nVlrT		:= 0
	Local nVlr		:= 0
	Local cRoteiro	:= ""
	Local cDtEnt	:= ""
	Local cPlaca	:= ""
	Local nPorc		:= 0
	Local cTpVa		:= ""
	
	//
	cNFFrt 	:= Alltrim(cValToChar(cNFFrt))
	cSrFrt	:= Alltrim(cValToChar(cSrFrt))
	
	//
	If Empty(cNFFrt) .Or. Empty(cSrFrt)
		Conout( DToC(Date()) + " " + Time() + " ADLOG049P - getVlrFrt - frete ZFD - não recebeu nota e/ou série " + cValToChar(cNFFrt) + " " + cValToChar(cSrFrt) )
		logZBE("Não recebeu nota ou série","Dt. NF/SR " + cNFFrt + " " + cSrFrt )
		RestArea(aArea)
		Return nVlr
		
	EndIf
	
	//
	DbSelectArea("ZFD")
	ZFD->(DbSetOrder(6))
	ZFD->(DbGoTop())
	If ZFD->( DbSeek( FWxFilial("ZFD") + cNFFrt + cSrFrt ) )

		//
		cTpVa := Alltrim(cValToChar(ZFD->ZFD_VA))

		//
		Conout( DToC(Date()) + " " + Time() + " ADLOG049P - getVlrFrt - cTpVa " + cValToChar(cTpVa) )
		
		//
		If Val(cValToChar(ZFD->ZFD_VALOR)) > 0
			nVlr := ZFD->ZFD_VALOR
			Conout( DToC(Date()) + " " + Time() + " ADLOG049P - getVlrFrt - frete ZFD - nVlr " + cValToChar(nVlr) )
			logZBE("Frete tabela ZFD " + cValToChar(nVlr),"Dt. NF/SR " + cNFFrt + " " + cSrFrt )
			RestArea(aArea)
			Return nVlr
			
		EndIf
	
	EndIf

	//
	If Empty(cTpVa)
		Conout( DToC(Date()) + " " + Time() + " ADLOG049P - getVlrFrt - não carregou tipo da carga cTpVa " + cValToChar(cTpVa) )
		logZBE("Não carregou tipo da carga cTpVa " + cValToChar(cTpVa) )
		RestArea(aArea)
		Return nVlr
		
	EndIf
	
	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " C5_ROTEIRO, C5_DTENTR, C5_PLACA, ZFA_VALOR, C5_NUM " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT ZFA_FILIAL, ZFA_DTENTR, ZFA_ROTEIR, ZFA_VALOR, ZFA_NUMENT  FROM " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA WHERE ZFA_FILIAL = '" + FWxFilial("ZFA") + "' AND ZFA.D_E_L_E_T_ = '') AS ZFA ON " 
	cQuery += " C5_FILIAL = ZFA.ZFA_FILIAL " 
	cQuery += " AND C5_DTENTR = ZFA.ZFA_DTENTR " 
	cQuery += " AND C5_ROTEIRO = ZFA.ZFA_ROTEIR " 
	cQuery += " WHERE " 
	cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "' " 
	cQuery += " AND C5_NOTA  = '" + cNFFrt + "' " 
	cQuery += " AND C5_SERIE = '" + cSrFrt + "' " 
	cQuery += " AND SC5.D_E_L_E_T_ = '' " 

	//
	If Select("V_FRT") > 0
		V_FRT->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "V_FRT"
	
	//
	DbSelectArea("V_FRT")
	V_FRT->(DbGoTop())
	If V_FRT->(Eof())	
		V_FRT->(DbCloseArea())
		Conout( DToC(Date()) + " " + Time() + " ADLOG049P - getVlrFrt - frete ZFD - consulta não retornou dados " + cValToChar(cNFFrt) + " " + cValToChar(cSrFrt) )
		logZBE("Consulta não retornou dados","Dt. NF/SR " + cNFFrt + " " + cSrFrt )
		RestArea(aArea)
		Return nVlr
		
	EndIf

	//
	nPorc := StaticCall(ADLOG057P,getPorEm,cTpVa) //Everson - 17/01/2020. Chamado 054941.

	//Everson - 17/01/2020. Chamado 054941.
	If nPorc <= 0
		Conout( DToC(Date()) + " " + Time() + " ADLOG049P - getVlrFrt - não carregou percentual de frete " + cValToChar(nPorc) )
		logZBE("Não carregou percentual de frete " + cValToChar(nPorc) )
		RestArea(aArea)
		Return nVlr

	EndIf

	//
	nPorc := nPorc/100
	
	//
	cRoteiro:= cValToChar(V_FRT->C5_ROTEIRO)
	cDtEnt	:= cValToChar(V_FRT->C5_DTENTR)
	cPlaca	:= cValToChar(V_FRT->C5_PLACA)	
	nVlrT   := Val(cValToChar(V_FRT->ZFA_VALOR))
	
	V_FRT->(DbCloseArea())
	
	//
	If nVlrT > 0
	
		//
		nVlrT   := Round(nVlrT * nPorc,2)
		
		//
		nVlr	:= atuParZFD(nVlrT,cRoteiro,cDtEnt,cPlaca,cNFFrt,cSrFrt)
	
		//
		Conout( DToC(Date()) + " " + Time() + " ADLOG049P - getVlrFrt - frete ZFA - nVlr " + cValToChar(nVlr) )
		logZBE("Frete tabela ZFA " + cValToChar(nVlr),"Dt. Entr/Roteiro/Placa/NF/SR " + cDtEnt + " " + cValToChar(cRoteiro) + " " + cValToChar(cPlaca) + " " + cNFFrt + " " + cSrFrt )
					
	Else
		
		//Verifica se há valor para frete combinado.
		DbSelectArea("ZFF")
		ZFF->(DbSetOrder(1))
		If (ZFF->(DbSeek( FWxFilial("ZFF") + cDtEnt + cPlaca )))
			If ZFF->ZFF_USANEG = 'S' .And. ZFF->ZFF_APROVA = 'S' 
				
				//
				nVlrT := Round(ZFF->ZFF_VALOR * nPorc,2)
				
				//
				nVlr  := atuParZFD(nVlrT,cRoteiro,cDtEnt,cPlaca,cNFFrt,cSrFrt)
		
				//
				Conout( DToC(Date()) + " " + Time() + " ADLOG049P - getVlrFrt - frete ZFF - nVlr " + cValToChar(nVlr) )
				logZBE("Frete tabela ZFF " + cValToChar(nVlr),"Dt. Entr/Roteiro/Placa/NF/SR " + cDtEnt + " " + cValToChar(cRoteiro) + " " + cValToChar(cPlaca) + " " + cNFFrt + " " + cSrFrt )
				
			Else
				Conout( DToC(Date()) + " " + Time() + " ADLOG049P - getVlrFrt - não localizaou frete")
				logZBE("Não localizado valor de frete - 2","Dt. Entr/Roteiro/Placa/NF/SR " + cDtEnt + " " + cValToChar(cRoteiro) + " " + cValToChar(cPlaca) + " " + cNFFrt + " " + cSrFrt )
						
			EndIf
	
		EndIf
		
	EndIf

	//
	RestArea(aArea)

Return nVlr
/*/{Protheus.doc} atuParZFD
	Atualiza valores de frete por nota na tabela ZFD. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 04/06/2019
	@version 01
	/*/
Static Function atuParZFD(nVlrT,cRoteiro,cDtEnt,cPlaca,cNFFrt,cSrFrt)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local nTotReg	:= 0
	Local nParc		:= 0
	Local nValor	:= 0
	Local nAux		:= 1
	
	//
	//cNFFrt := Alltrim(cValToChar(cNFFrt))
	//cSrFrt := Alltrim(cValToChar(cSrFrt))
	
	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " ZFD_NUMNF, ZFD_SERIE, ZFD.R_E_C_N_O_ AS REC " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZFD") + " (NOLOCK) AS ZFD " 
	cQuery += " WHERE " 
	cQuery += " ZFD_FILIAL = '" + FWxFilial("ZFD") + "' " 
	cQuery += " AND ZFD_DTENTR = '" + cDtEnt + "' " 
	cQuery += " AND D_E_L_E_T_ = '' " 
	cQuery += " AND ZFD_ROTEIR = '" + cValToChar(cRoteiro) + "' " 
	cQuery += " AND ZFD_FEZNF = 'S' " 
	cQuery += " AND ZFD_VA = '1' "  //Everson - 16/01/2020. Chamado 054941.
	cQuery += " AND ZFD_CAMINH = '" + cPlaca + "' "
	cQuery += " AND ZFD.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY ZFD_NUMNF " 
	
	//
	If Select("AT_ZFD") > 0
		AT_ZFD->(DbCloseArea())
		
	EndIf
	
	//
	DbSelectArea("ZFD")
	ZFD->(DbGoTop())
	
	//
	TcQuery cQuery New Alias "AT_ZFD"
	DbSelectArea("AT_ZFD")
	AT_ZFD->(DbGoTop())
		nTotReg := Contar("AT_ZFD","!Eof()")
	AT_ZFD->(DbGoTop())
	
	//
	nParc := Round(nVlrT/nTotReg,2)
	
	//
	While ! AT_ZFD->(Eof())
	
		//
		nAux++
	
		ZFD->(DbGoTo( Val(cValToChar(AT_ZFD->REC)) ))
		
		If ! ZFD->(Eof())
		
			//
			RecLock("ZFD",.F.)
			
				//
				If nAux == nTotReg
					ZFD->ZFD_VALOR := nVlrT - (nParc * (nTotReg-1))
					
				Else
					ZFD->ZFD_VALOR := nParc
					
				EndIf
				
			ZFD->(MsUnlock())
			
			//
			logZBE("Calculo do valor de frete por nota " + cValToChar(ZFD->ZFD_VALOR), "Nf/Sr: " + cNFFrt + " " + cSrFrt)
			
			//
			If Alltrim(cValToChar(ZFD->ZFD_NUMNF)) == cNFFrt .And. Alltrim(cValToChar(ZFD->ZFD_SERIE)) == cSrFrt
				nValor := ZFD->ZFD_VALOR
			
			EndIf
		
		EndIf
		
		//
		AT_ZFD->(DbSkip())
		
	End
	
	//
	AT_ZFD->(DbGoTop())
	
	//
	RestArea(aArea)
	
Return nValor
/*/{Protheus.doc} nomeStaticFunction
	Rotina para gerar log na tabela ZBE. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 28/02/2019
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
		Replace ZBE->ZBE_PARAME With cParam
		Replace ZBE_MODULO	    With "LOGISTICA"
		Replace ZBE_ROTINA	    With "ADLOG049P" 
	MsUnlock()

	//
	RestArea(aArea)

Return Nil 