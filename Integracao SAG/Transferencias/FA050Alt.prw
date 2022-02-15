#Include "RwMake.ch"
#Include "Totvs.ch"
#Include 'Protheus.ch'
#Include "Topconn.ch"

/*/{Protheus.doc} User Function FA050ALT
	Ponto de Entrada para validar a alteração de um título - Projeto SAG II	
	@type  Function
	@author Leonardo Rios
	@since 13/04/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history Chamado 038604 - Ricardo Lima - 01/12/2017 - Validacao na alteracao de data de vencimento, analisa se o usuario esta cadastrado com permissao para confirmar, caso nao tenha, a alteracao e encaminhada para aprovacao, apos a aprovacao a alteracao e efetivada.
	@history Chamado 038604 - Ricardo Lima - 22/03/2018 - Implementação tolerância de alteração de alçada de títulos.
	@history Chamado 053347 - FWNM         - 29/11/2019 - 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL
	@history Chamado 055321 - FWNM         - 05/02/2020 - OS 056879 || FINANCAS || EDUARDO || 8352 || APROVADOR AUSENTE
	@history ticket   67909 - Fer Macieira - 15/02/2022 - Pagamento GTA - SC
/*/
User Function FA050Alt()

	Local lRet := .T. // Variável responsável para retornar se será liberado a exclusão(lRet:=.T.) ou não(lRet:=.F.)

	Local cMensErro := ""

	// Ricardo Lima - 01/12/17
	Local cTpDivf   := "000004"
	Local nDiaMenos := 0
	Local nDiaMais  := 0
	Local lPerAlt   := .F.
	Local ZC3PERDEC := 0
	Local ZC3PERDES := 0
	Local ZC3PERJUR := 0
	Local ZC3PERACR := 0

	Local cE2VALOR   := SE2->E2_VALOR

	Local cE2DECRESC := SE2->E2_DECRESC
	Local cE2DCRESCN := SE2->E2_DECRESC

	Local cE2ACRESC  := SE2->E2_ACRESC
	Local cE2ACRSCN  := SE2->E2_ACRESC

	Local cE2VALJUR  := SE2->E2_VALJUR
	Local cE2VLJURN  := SE2->E2_VALJUR

	Local cE2CNABDES := SE2->E2_CNABDES
	Local cE2CNBDESN := SE2->E2_CNABDES

	Local cE2CNABACR := SE2->E2_CNABACR
	Local cE2CNBACRN := SE2->E2_CNABACR

	Local dE2VENCTO  := SE2->E2_VENCTO
	Local dE2VECTON  := SE2->E2_VENCTO
	Local dE2VENCREA := SE2->E2_VENCREA
	Local dE2VECREAN := SE2->E2_VENCREA
	local sDscBlq    := ""

	// RICARDO LIMA - 13/02/18
	Local cAssunto  := "Central de Aprovação"
	Local cMensagem := ""
	Local cmaildest := GetMv("MV_XFA050F")

	// Ricardo Lima - 22/03/18
	Local nDMenosTol := Val( SuperGetMv( "MV_#TOLCA1" , .F. , "000" ,  ) )
	Local nDMaisTol  := Val( SuperGetMv( "MV_#TOLCA2" , .F. , "000" ,  ) )
	Local TOLPERDEC  := SuperGetMv( "MV_#TOLCA3" , .F. , 00.00 ,  )
	Local TOLPERDES  := SuperGetMv( "MV_#TOLCA4" , .F. , 00.00 ,  )
	Local TOLPERJUR  := SuperGetMv( "MV_#TOLCA5" , .F. , 00.00 ,  )
	Local TOLPERACR  := SuperGetMv( "MV_#TOLCA6" , .F. , 00.00 ,  )

	// Ricardo Lima - 18/04/18
	Local dDifData := 0
	Local nVlrCust := 0
	Local nPerCust := Val( SuperGetMv( "MV_#PERCUS" , .F. , '0' ,  ) )
	Local cMsgCFin := ""
	Local lEnvWFCA  := SuperGetMv( "MV_#FA5ENV" , .F. , .T. ,  )

	// @history ticket   67909 - Fer Macieira - 15/02/2022 - Pagamento GTA - SC
	If !Empty(M->E2_CODBAR)
		lRet := u_ChkCodBar(M->E2_CODBAR)
		If !lRet
			lRet := .f.
			Return lRet
		EndIf
	EndIf
	//

	If Alltrim(cEmpAnt) == "01"
		If !EMPTY(ALLTRIM(SE2->E2_XRECORI)) .and. !IsInCallStack("U_INTFIN")
			lRet := .F.
			cMensErro := "Não será possível Alterar deste título porque ele foi gerado através da integração com o SAG!"
			U_ExTelaMen("Tratamento de Alteracao do título!", cMensErro, "Arial", 12, , .F., .T.)
		EndIf
	Endif


	If Alltrim(Funname()) <> "CENTNFEXM"  //fernando sigoli 02/03/2017
		
		//if cEmpAnt = '01' .or. cEmpAnt = '02' // Chamado n. 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL - fwnm - 29/11/2019
		cAssunto := cAssunto + " - " + AllTrim(SM0->M0_NOME)
		
			// Ricardo Lima - 01/12/17
			DbSelectArea("SX5")
			DbSetOrder(1)
			DbSeek( FwxFilial("SX5") + 'Z9' + cTpDivf )
			sDscBlq := Alltrim(SX5->X5_DESCRI)
			
			DbSelectArea("ZC3")
			DbSetorder(1)
			if DbSeek( FwxFilial("ZC3") + __cUserID )
				If ZC3->ZC3_DTANTC = "1"
					nDiaMenos := ZC3->ZC3_NUMDTA
					nDiaMais  := ZC3->ZC3_NUMDTP
					lPerAlt   := .T.
					ZC3PERDEC := ZC3->ZC3_PERDEC
					ZC3PERDES := ZC3->ZC3_PERDES
					ZC3PERJUR := ZC3->ZC3_PERJUR
					ZC3PERACR := ZC3->ZC3_PERACR
					
				ENDIF
			endif
			
			// Bloqueio por Alteracao de Vencimento
			If !( Alltrim(DTOC(M->E2_VENCTO)) == Alltrim(DTOC(SE2->E2_VENCTO)) )
				
				// Ricardo Lima - 18/04/18
				IF M->E2_VENCTO < dE2VENCTO
					dDifData := dE2VENCTO - M->E2_VENCTO
					nVlrCust := ((cE2VALOR * ( nPerCust/100 )) / 30) * dDifData
					M->E2_XCUSFIN := nVlrCust
				ElseIf M->E2_VENCTO  > dE2VENCTO
					dDifData := M->E2_VENCTO - dE2VENCTO
					nVlrCust := ((cE2VALOR * ( nPerCust/100 )) / 30) * dDifData
					M->E2_XCUSFIN := nVlrCust
				EndIf
				
				if lPerAlt
					if M->E2_VENCTO < dE2VENCTO  // Antecipa Vencimento
						if M->E2_VENCTO < ( dE2VENCTO - nDiaMenos ) .OR. nVlrCust > TOLPERJUR
							IF M->E2_VENCTO > ( dE2VENCTO - nDiaMenos ) .AND. nVlrCust > TOLPERJUR
								cMsgCFin := "Custo Financeiro Maior que Tolerancia"
							Else
								cMsgCFin := ""
							EndIf
							
							MsgBox('A Alteração realizada é maior do que a sua Alçada, Titulo encaminhado para Aprovação!','Alçada de Alteração Financeira','Info')
							// guarda o novo vencimento para uso apos aprovacao
							dE2VECTON  := M->E2_VENCTO
							dE2VECREAN := M->E2_VENCREA
							
							// Bloqueia o Titulo
							M->E2_XDIVERG := 'S'
							
							// Volta o vencimento original, apos aprovacao sera alterado
							M->E2_VENCTO  := dE2VENCTO
							M->E2_VENCREA := dE2VENCREA
							
							// gera registro para aprovacao
							DbSelectArea("ZC7")
							DbSetOrder(2)
							IF DbSeek( FwxFilial("ZC7") + M->E2_FORNECE + M->E2_LOJA + M->E2_PREFIXO + M->E2_NUM + M->E2_PARCELA + M->E2_TIPO)  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
								IF EMPTY(ZC7_USRAPR)
									RecLock("ZC7",.F.)
										ZC7->ZC7_NDTVEN := dE2VECTON
										ZC7->ZC7_NDTVCR := dE2VECREAN
										ZC7->ZC7_CUSFIN := nVlrCust
										ZC7->ZC7_PERCUS := ALLTRIM(STR(nPerCust))
										ZC7->ZC7_NUMCAL := ALLTRIM(STR(dDifData))
										ZC7->ZC7_USRALT := __cUserID
									MSUnlock()
								ELSE
									RecLock("ZC7",.T.)
										ZC7->ZC7_FILIAL := FwxFilial("SE2")
										ZC7->ZC7_PREFIX := M->E2_PREFIXO
										ZC7->ZC7_NUM    := M->E2_NUM
										ZC7->ZC7_PARCEL := M->E2_PARCELA
										ZC7->ZC7_TIPO   := M->E2_TIPO
										ZC7->ZC7_CLIFOR := M->E2_FORNECE
										ZC7->ZC7_LOJA   := M->E2_LOJA
										ZC7->ZC7_NDTVEN := dE2VECTON
										ZC7->ZC7_NDTVCR := dE2VECREAN
										ZC7->ZC7_TPBLQ  := cTpDivf
										ZC7->ZC7_DSCBLQ := sDscBlq += ", Dt Vencimento, "+cMsgCFin
										ZC7->ZC7_RECPAG := "P"
										ZC7->ZC7_ODTVEN := dE2VENCTO // RICARDO LIMA - 13/02/18
										ZC7->ZC7_ODTVCR := dE2VENCREA // RICARDO LIMA - 13/02/18
										ZC7->ZC7_CUSFIN := nVlrCust // Ricardo LIma - 18/04/18
										ZC7->ZC7_VLRBLQ := cE2VALOR // Ricardo LIma - 18/04/18
										ZC7->ZC7_PERCUS := ALLTRIM(STR(nPerCust)) // Ricardo LIma - 18/04/18
										ZC7->ZC7_NUMCAL := ALLTRIM(STR(dDifData)) // Ricardo LIma - 18/04/18
										ZC7->ZC7_USRALT := __cUserID
									MSUnlock()
								ENDIF
							ELSE
								RecLock("ZC7",.T.)
									ZC7->ZC7_FILIAL := FwxFilial("SE2")
									ZC7->ZC7_PREFIX	:= M->E2_PREFIXO
									ZC7->ZC7_NUM   	:= M->E2_NUM
									ZC7->ZC7_PARCEL	:= M->E2_PARCELA
									ZC7->ZC7_TIPO   := M->E2_TIPO
									ZC7->ZC7_CLIFOR	:= M->E2_FORNECE
									ZC7->ZC7_LOJA  	:= M->E2_LOJA
									ZC7->ZC7_NDTVEN := dE2VECTON
									ZC7->ZC7_NDTVCR := dE2VECREAN
									ZC7->ZC7_TPBLQ 	:= cTpDivf
									ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Dt Vencimento, "+cMsgCFin
									ZC7->ZC7_RECPAG := "P"
									ZC7->ZC7_ODTVEN := dE2VENCTO // RICARDO LIMA - 13/02/18
									ZC7->ZC7_ODTVCR := dE2VENCREA // RICARDO LIMA - 13/02/18
									ZC7->ZC7_CUSFIN := nVlrCust // Ricardo LIma - 18/04/18
									ZC7->ZC7_VLRBLQ := cE2VALOR // Ricardo LIma - 18/04/18
									ZC7->ZC7_PERCUS := ALLTRIM(STR(nPerCust)) // Ricardo LIma - 18/04/18
									ZC7->ZC7_NUMCAL := ALLTRIM(STR(dDifData)) // Ricardo LIma - 18/04/18
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						endif
					Elseif M->E2_VENCTO > dE2VENCTO  // Posterga Vencimento
						if M->E2_VENCTO  > ( dE2VENCTO + nDiaMais ) .OR. nVlrCust > TOLPERDES
							IF M->E2_VENCTO < ( dE2VENCTO + nDiaMais ) .AND. nVlrCust > TOLPERDES
								cMsgCFin := "Custo Financeiro Maior que Tolerancia"
							Else
								cMsgCFin := ""
							EndIf
							
							MsgBox('A Alteração realizada é maior do que a sua Alçada, Titulo encaminhado para Aprovação!' ,'Alçada de Alteração Financeira','Info')
							// guarda o novo vencimento para uso apos aprovacao
							dE2VECTON  := M->E2_VENCTO
							dE2VECREAN := M->E2_VENCREA
							
							// Bloqueia o Titulo
							M->E2_XDIVERG := 'S'
							
							// Volta o vencimento original, apos aprovacao sera alterado
							M->E2_VENCTO  := dE2VENCTO
							M->E2_VENCREA := dE2VENCREA
							
							// gera registro para aprovacao
							DbSelectArea("ZC7")
							DbSetOrder(2)
							IF DbSeek( FwxFilial("ZC7") + M->E2_FORNECE + M->E2_LOJA + M->E2_PREFIXO + M->E2_NUM + M->E2_PARCELA + M->E2_TIPO)  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
								IF EMPTY(ZC7_USRAPR)
									RecLock("ZC7",.F.)
										ZC7->ZC7_NDTVEN := dE2VECTON
										ZC7->ZC7_NDTVCR := dE2VECREAN
										ZC7->ZC7_CUSFIN := nVlrCust
										ZC7->ZC7_PERCUS := ALLTRIM(STR(nPerCust))
										ZC7->ZC7_NUMCAL := ALLTRIM(STR(dDifData))
										ZC7->ZC7_USRALT := __cUserID
									MSUnlock()
								ELSE
									RecLock("ZC7",.T.)
										ZC7->ZC7_FILIAL := FwxFilial("SE2")
										ZC7->ZC7_PREFIX := M->E2_PREFIXO
										ZC7->ZC7_NUM    := M->E2_NUM
										ZC7->ZC7_PARCEL := M->E2_PARCELA
										ZC7->ZC7_TIPO   := M->E2_TIPO
										ZC7->ZC7_CLIFOR := M->E2_FORNECE
										ZC7->ZC7_LOJA   := M->E2_LOJA
										ZC7->ZC7_NDTVEN := dE2VECTON
										ZC7->ZC7_NDTVCR := dE2VECREAN
										ZC7->ZC7_TPBLQ  := cTpDivf
										ZC7->ZC7_DSCBLQ := sDscBlq += ", Dt Vencimento, "+cMsgCFin
										ZC7->ZC7_RECPAG := "P"
										ZC7->ZC7_ODTVEN := dE2VENCTO // RICARDO LIMA - 13/02/18
										ZC7->ZC7_ODTVCR := dE2VENCREA // RICARDO LIMA - 13/02/18
										ZC7->ZC7_CUSFIN := nVlrCust // Ricardo LIma - 18/04/18
										ZC7->ZC7_VLRBLQ := cE2VALOR // Ricardo LIma - 18/04/18
										ZC7->ZC7_PERCUS := ALLTRIM(STR(nPerCust)) // Ricardo LIma - 18/04/18
										ZC7->ZC7_NUMCAL := ALLTRIM(STR(dDifData)) // Ricardo LIma - 18/04/18
										ZC7->ZC7_USRALT := __cUserID
									MSUnlock()
								ENDIF
							ELSE
								RecLock("ZC7",.T.)
									ZC7->ZC7_FILIAL := FwxFilial("SE2")
									ZC7->ZC7_PREFIX	:= M->E2_PREFIXO
									ZC7->ZC7_NUM   	:= M->E2_NUM
									ZC7->ZC7_PARCEL	:= M->E2_PARCELA
									ZC7->ZC7_TIPO   := M->E2_TIPO
									ZC7->ZC7_CLIFOR	:= M->E2_FORNECE
									ZC7->ZC7_LOJA  	:= M->E2_LOJA
									ZC7->ZC7_NDTVEN := dE2VECTON
									ZC7->ZC7_NDTVCR := dE2VECREAN
									ZC7->ZC7_TPBLQ 	:= cTpDivf
									ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Dt Vencimento, "+cMsgCFin
									ZC7->ZC7_RECPAG := "P"
									ZC7->ZC7_ODTVEN := dE2VENCTO // RICARDO LIMA - 13/02/18
									ZC7->ZC7_ODTVCR := dE2VENCREA // RICARDO LIMA - 13/02/18
									ZC7->ZC7_CUSFIN := nVlrCust // Ricardo LIma - 18/04/18
									ZC7->ZC7_VLRBLQ := cE2VALOR // Ricardo LIma - 18/04/18
									ZC7->ZC7_PERCUS := ALLTRIM(STR(nPerCust)) // Ricardo LIma - 18/04/18
									ZC7->ZC7_NUMCAL := ALLTRIM(STR(dDifData)) // Ricardo LIma - 18/04/18
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						endif
					endif
				else
					// Ricardo Lima - 18/04/18
					IF M->E2_VENCTO < dE2VENCTO
						dDifData := dE2VENCTO - M->E2_VENCTO
						nVlrCust := ((cE2VALOR * ( nPerCust/100 )) / 30) * dDifData
						M->E2_XCUSFIN := nVlrCust
					ElseIf M->E2_VENCTO  > dE2VENCTO
						dDifData := M->E2_VENCTO - dE2VENCTO
						nVlrCust := ((cE2VALOR * ( nPerCust/100 )) / 30) * dDifData
						M->E2_XCUSFIN := nVlrCust
					EndIf
					
					IF ( M->E2_VENCTO < ( dE2VENCTO - nDMenosTol ) .or. nVlrCust > TOLPERJUR ) .OR. ( M->E2_VENCTO  > ( dE2VENCTO + nDMaisTol ) .or. nVlrCust > TOLPERDES ) // Ricardo Lima - 22/03/18
						
						If ( M->E2_VENCTO > ( dE2VENCTO - nDMenosTol ) .AND. nVlrCust > TOLPERJUR ) .OR. ( M->E2_VENCTO < ( dE2VENCTO + nDMaisTol ) .AND. nVlrCust > TOLPERDES )
							cMsgCFin := "Custo Financeiro Maior que Tolerancia"
						Else
							cMsgCFin := ""
						EndIf
						
						MsgBox('Você não tem Alçada para Alteração, O Titulo será encaminhado para Aprovação!' ,'Alçada de Alteração Financeira','Info')
						// guarda o novo vencimento para uso apos aprovacao
						dE2VECTON := M->E2_VENCTO
						dE2VECREAN := M->E2_VENCREA
						
						// Bloqueia o Titulo
						M->E2_XDIVERG := 'S'
						
						// Volta o vencimento original, apos aprovacao sera alterado
						M->E2_VENCTO  := dE2VENCTO
						M->E2_VENCREA := dE2VENCREA
						
						// gera registro para aprovacao
						DbSelectArea("ZC7")
						DbSetOrder(2)
						IF DbSeek( FwxFilial("ZC7") + M->E2_FORNECE + M->E2_LOJA + M->E2_PREFIXO + M->E2_NUM + M->E2_PARCELA + M->E2_TIPO )  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
							IF EMPTY(ZC7_USRAPR)
								RecLock("ZC7",.F.)
									ZC7->ZC7_NDTVEN := dE2VECTON
									ZC7->ZC7_NDTVCR := dE2VECREAN
									ZC7->ZC7_CUSFIN := nVlrCust
									ZC7->ZC7_PERCUS := ALLTRIM(STR(nPerCust))
									ZC7->ZC7_NUMCAL := ALLTRIM(STR(dDifData))
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ELSE
								RecLock("ZC7",.T.)
									ZC7->ZC7_FILIAL := FwxFilial("SE2")
									ZC7->ZC7_PREFIX := M->E2_PREFIXO
									ZC7->ZC7_NUM    := M->E2_NUM
									ZC7->ZC7_PARCEL := M->E2_PARCELA
									ZC7->ZC7_TIPO   := M->E2_TIPO
									ZC7->ZC7_CLIFOR := M->E2_FORNECE
									ZC7->ZC7_LOJA   := M->E2_LOJA
									ZC7->ZC7_NDTVEN := dE2VECTON
									ZC7->ZC7_NDTVCR := dE2VECREAN
									ZC7->ZC7_TPBLQ  := cTpDivf
									ZC7->ZC7_DSCBLQ := sDscBlq += ", Dt Vencimento, "+cMsgCFin
									ZC7->ZC7_RECPAG := "P"
									ZC7->ZC7_ODTVEN := dE2VENCTO // RICARDO LIMA - 13/02/18
									ZC7->ZC7_ODTVCR := dE2VENCREA // RICARDO LIMA - 13/02/18
									ZC7->ZC7_CUSFIN := nVlrCust // Ricardo LIma - 18/04/18
									ZC7->ZC7_VLRBLQ := cE2VALOR // Ricardo LIma - 18/04/18
									ZC7->ZC7_PERCUS := ALLTRIM(STR(nPerCust)) // Ricardo LIma - 18/04/18
									ZC7->ZC7_NUMCAL := ALLTRIM(STR(dDifData)) // Ricardo LIma - 18/04/18
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						ELSE
							RecLock("ZC7",.T.)
								ZC7->ZC7_FILIAL := FwxFilial("SE2")
								ZC7->ZC7_PREFIX	:= M->E2_PREFIXO
								ZC7->ZC7_NUM   	:= M->E2_NUM
								ZC7->ZC7_PARCEL	:= M->E2_PARCELA
								ZC7->ZC7_TIPO   := M->E2_TIPO
								ZC7->ZC7_CLIFOR	:= M->E2_FORNECE
								ZC7->ZC7_LOJA  	:= M->E2_LOJA
								ZC7->ZC7_NDTVEN := dE2VECTON
								ZC7->ZC7_NDTVCR := dE2VECREAN
								ZC7->ZC7_TPBLQ 	:= cTpDivf
								ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Dt Vencimento, "+cMsgCFin
								ZC7->ZC7_RECPAG := "P"
								ZC7->ZC7_ODTVEN := dE2VENCTO // RICARDO LIMA - 13/02/18
								ZC7->ZC7_ODTVCR := dE2VENCREA // RICARDO LIMA - 13/02/18
								ZC7->ZC7_CUSFIN := nVlrCust // Ricardo LIma - 18/04/18
								ZC7->ZC7_VLRBLQ := cE2VALOR // Ricardo LIma - 18/04/18
								ZC7->ZC7_PERCUS := ALLTRIM(STR(nPerCust)) // Ricardo LIma - 18/04/18
								ZC7->ZC7_NUMCAL := ALLTRIM(STR(dDifData)) // Ricardo LIma - 18/04/18
								ZC7->ZC7_USRALT := __cUserID
							MSUnlock()
						ENDIF
					ENDIF
				endif
			endif
			
			// Bloqueio por Juros
			if !( cE2VALJUR  == M->E2_VALJUR )
				
				if !empty(ZC3PERJUR)
					
					if (cE2VALOR+M->E2_VALJUR) > ( cE2VALOR + ( cE2VALOR * (ZC3PERJUR/100) ) )
						
						MsgBox('A Alteração realizada é maior do que a sua Alçada, Titulo encaminhado para Aprovação!' ,'Alçada de Alteração Financeira','Info')
						
						// Guarda o novo valor
						cE2VLJURN  := M->E2_VALJUR
						
						// Volta o valor original
						M->E2_VALJUR := cE2VALJUR
						
						// Bloqueia o Titulo
						IF M->E2_XDIVERG <> 'S'
							M->E2_XDIVERG := 'S'
						ENDIF
						
						DbSelectArea("ZC7")
						DbSetOrder(2)
						IF DbSeek( FwxFilial("ZC7") + M->E2_FORNECE + M->E2_LOJA + M->E2_PREFIXO + M->E2_NUM + M->E2_PARCELA + M->E2_TIPO )  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
							IF EMPTY(ZC7_USRAPR)
								RecLock("ZC7",.F.)
									ZC7->ZC7_VLRJUR    := cE2VLJURN
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ELSE
								RecLock("ZC7",.T.)
									ZC7->ZC7_FILIAL := FwxFilial("SE2")
									ZC7->ZC7_PREFIX := M->E2_PREFIXO
									ZC7->ZC7_NUM    := M->E2_NUM
									ZC7->ZC7_PARCEL := M->E2_PARCELA
									ZC7->ZC7_TIPO   := M->E2_TIPO
									ZC7->ZC7_CLIFOR := M->E2_FORNECE
									ZC7->ZC7_LOJA   := M->E2_LOJA
									ZC7->ZC7_VLRBLQ := cE2VALOR
									ZC7->ZC7_VLRJUR := cE2VLJURN
									ZC7->ZC7_TPBLQ  := cTpDivf
									ZC7->ZC7_DSCBLQ := sDscBlq += ", Juros"
									ZC7->ZC7_RECPAG := "P"
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						ELSE
							RecLock("ZC7",.T.)
								ZC7->ZC7_FILIAL := FwxFilial("SE2")
								ZC7->ZC7_PREFIX	:= M->E2_PREFIXO
								ZC7->ZC7_NUM   	:= M->E2_NUM
								ZC7->ZC7_PARCEL	:= M->E2_PARCELA
								ZC7->ZC7_TIPO   := M->E2_TIPO
								ZC7->ZC7_CLIFOR	:= M->E2_FORNECE
								ZC7->ZC7_LOJA  	:= M->E2_LOJA
								ZC7->ZC7_VLRBLQ := cE2VALOR
								ZC7->ZC7_VLRJUR := cE2VLJURN
								ZC7->ZC7_TPBLQ 	:= cTpDivf
								ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Juros"
								ZC7->ZC7_RECPAG := "P"
								ZC7->ZC7_USRALT := __cUserID
							MSUnlock()
						ENDIF
					endif
				else
					IF (cE2VALOR+M->E2_VALJUR) > ( cE2VALOR + TOLPERJUR )  // Ricardo Lima - 22/03/18
						MsgBox('A Alteração realizada é maior do que a sua Alçada, Titulo encaminhado para Aprovação!' ,'Alçada de Alteração Financeira','Info')
						
						// Guarda o novo valor
						cE2VLJURN  := M->E2_VALJUR
						
						// Volta o valor original
						M->E2_VALJUR := cE2VALJUR
						
						// Bloqueia o Titulo
						IF M->E2_XDIVERG <> 'S'
							M->E2_XDIVERG := 'S'
						ENDIF
						
						DbSelectArea("ZC7")
						DbSetOrder(2)
						IF DbSeek( FwxFilial("ZC7") + M->E2_FORNECE + M->E2_LOJA + M->E2_PREFIXO + M->E2_NUM + M->E2_PARCELA + M->E2_TIPO )  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
							IF EMPTY(ZC7_USRAPR)
								RecLock("ZC7",.F.)
									ZC7->ZC7_VLRJUR := cE2VLJURN
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ELSE
								RecLock("ZC7",.T.)
									ZC7->ZC7_FILIAL := FwxFilial("SE2")
									ZC7->ZC7_PREFIX := M->E2_PREFIXO
									ZC7->ZC7_NUM    := M->E2_NUM
									ZC7->ZC7_PARCEL := M->E2_PARCELA
									ZC7->ZC7_TIPO   := M->E2_TIPO
									ZC7->ZC7_CLIFOR := M->E2_FORNECE
									ZC7->ZC7_LOJA   := M->E2_LOJA
									ZC7->ZC7_VLRBLQ := cE2VALOR
									ZC7->ZC7_VLRJUR := cE2VLJURN
									ZC7->ZC7_TPBLQ  := cTpDivf
									ZC7->ZC7_DSCBLQ := sDscBlq += ", Juros"
									ZC7->ZC7_RECPAG := "P"
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						ELSE
							RecLock("ZC7",.T.)
								ZC7->ZC7_FILIAL := FwxFilial("SE2")
								ZC7->ZC7_PREFIX	:= M->E2_PREFIXO
								ZC7->ZC7_NUM   	:= M->E2_NUM
								ZC7->ZC7_PARCEL	:= M->E2_PARCELA
								ZC7->ZC7_TIPO   := M->E2_TIPO
								ZC7->ZC7_CLIFOR	:= M->E2_FORNECE
								ZC7->ZC7_LOJA  	:= M->E2_LOJA
								ZC7->ZC7_VLRBLQ := cE2VALOR
								ZC7->ZC7_VLRJUR := cE2VLJURN
								ZC7->ZC7_TPBLQ 	:= cTpDivf
								ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Juros"
								ZC7->ZC7_RECPAG := "P"
								ZC7->ZC7_USRALT := __cUserID
							MSUnlock()
						ENDIF
					ENDIF
				endif
			endif
			
			// Bloqueio por Descrescimo
			if !( cE2DECRESC == M->E2_DECRESC )
				
				if !empty(ZC3PERDEC)
					
					if ( cE2VALOR - M->E2_DECRESC ) < ( cE2VALOR - ( cE2VALOR * (ZC3PERDEC/100) ) )
						
						MsgBox('A Alteração realizada é maior do que a sua Alçada, Titulo encaminhado para Aprovação!' ,'Alçada de Alteração Financeira','Info')
						
						// Guarda o novo valor
						cE2DCRESCN  := M->E2_DECRESC
						
						// Volta o valor original
						M->E2_DECRESC := cE2DECRESC
						
						// Bloqueia o Titulo
						IF M->E2_XDIVERG <> 'S'
							M->E2_XDIVERG := 'S'
						ENDIF
						
						DbSelectArea("ZC7")
						DbSetOrder(2)
						IF DbSeek( FwxFilial("ZC7") + M->E2_FORNECE + M->E2_LOJA + M->E2_PREFIXO + M->E2_NUM + M->E2_PARCELA + M->E2_TIPO)  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
							IF EMPTY(ZC7_USRAPR)
								RecLock("ZC7",.F.)
									ZC7->ZC7_DECRES := cE2DCRESCN
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ELSE
								RecLock("ZC7",.T.)
									ZC7->ZC7_FILIAL := FwxFilial("SE2")
									ZC7->ZC7_PREFIX := M->E2_PREFIXO
									ZC7->ZC7_NUM    := M->E2_NUM
									ZC7->ZC7_PARCEL := M->E2_PARCELA
									ZC7->ZC7_TIPO   := M->E2_TIPO
									ZC7->ZC7_CLIFOR := M->E2_FORNECE
									ZC7->ZC7_LOJA   := M->E2_LOJA
									ZC7->ZC7_VLRBLQ := cE2VALOR
									ZC7->ZC7_DECRES := cE2DCRESCN
									ZC7->ZC7_TPBLQ  := cTpDivf
									ZC7->ZC7_DSCBLQ := sDscBlq += ", Descrescimo"
									ZC7->ZC7_RECPAG := "P"
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						ELSE
							RecLock("ZC7",.T.)
								ZC7->ZC7_FILIAL := FwxFilial("SE2")
								ZC7->ZC7_PREFIX	:= M->E2_PREFIXO
								ZC7->ZC7_NUM   	:= M->E2_NUM
								ZC7->ZC7_PARCEL	:= M->E2_PARCELA
								ZC7->ZC7_TIPO   := M->E2_TIPO
								ZC7->ZC7_CLIFOR	:= M->E2_FORNECE
								ZC7->ZC7_LOJA  	:= M->E2_LOJA
								ZC7->ZC7_VLRBLQ := cE2VALOR
								ZC7->ZC7_DECRES := cE2DCRESCN
								ZC7->ZC7_TPBLQ 	:= cTpDivf
								ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Descrescimo"
								ZC7->ZC7_RECPAG := "P"
								ZC7->ZC7_USRALT := __cUserID
							MSUnlock()
						ENDIF
					endif
				else
					IF ( cE2VALOR - M->E2_DECRESC ) < ( cE2VALOR - TOLPERDEC )  // Ricardo Lima - 22/03/18
						MsgBox('A Alteração realizada é maior do que a sua Alçada, Titulo encaminhado para Aprovação!','Alçada de Alteração Financeira','Info')
						
						// Guarda o novo valor
						cE2DCRESCN  := M->E2_DECRESC
						
						// Volta o valor original
						M->E2_DECRESC := cE2DECRESC
						
						// Bloqueia o Titulo
						IF M->E2_XDIVERG <> 'S'
							M->E2_XDIVERG := 'S'
						ENDIF
						
						DbSelectArea("ZC7")
						DbSetOrder(2)
						IF DbSeek( FwxFilial("ZC7") + M->E2_FORNECE + M->E2_LOJA + M->E2_PREFIXO + M->E2_NUM + M->E2_PARCELA + M->E2_TIPO)  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
							IF EMPTY(ZC7_USRAPR)
								RecLock("ZC7",.F.)
									ZC7->ZC7_DECRES := cE2DCRESCN
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ELSE
								RecLock("ZC7",.T.)
									ZC7->ZC7_FILIAL := FwxFilial("SE2")
									ZC7->ZC7_PREFIX := M->E2_PREFIXO
									ZC7->ZC7_NUM    := M->E2_NUM
									ZC7->ZC7_PARCEL := M->E2_PARCELA
									ZC7->ZC7_TIPO   := M->E2_TIPO
									ZC7->ZC7_CLIFOR := M->E2_FORNECE
									ZC7->ZC7_LOJA   := M->E2_LOJA
									ZC7->ZC7_VLRBLQ := cE2VALOR
									ZC7->ZC7_DECRES := cE2DCRESCN
									ZC7->ZC7_TPBLQ  := cTpDivf
									ZC7->ZC7_DSCBLQ := sDscBlq += ", Descrescimo"
									ZC7->ZC7_RECPAG := "P"
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						ELSE
							RecLock("ZC7",.T.)
								ZC7->ZC7_FILIAL := FwxFilial("SE2")
								ZC7->ZC7_PREFIX	:= M->E2_PREFIXO
								ZC7->ZC7_NUM   	:= M->E2_NUM
								ZC7->ZC7_PARCEL	:= M->E2_PARCELA
								ZC7->ZC7_TIPO   := M->E2_TIPO
								ZC7->ZC7_CLIFOR	:= M->E2_FORNECE
								ZC7->ZC7_LOJA  	:= M->E2_LOJA
								ZC7->ZC7_VLRBLQ := cE2VALOR
								ZC7->ZC7_DECRES := cE2DCRESCN
								ZC7->ZC7_TPBLQ 	:= cTpDivf
								ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Descrescimo"
								ZC7->ZC7_RECPAG := "P"
								ZC7->ZC7_USRALT := __cUserID
							MSUnlock()
						ENDIF
					ENDIF
				endif
			endif
			
			// Bloqueio por Acrescimo
			if !( cE2ACRESC == M->E2_ACRESC )
				
				if !empty(ZC3PERACR)
					
					if ( cE2VALOR + M->E2_ACRESC ) > ( cE2VALOR + ( cE2VALOR * (ZC3PERACR/100) ) )
						
						MsgBox('A Alteração realizada é maior do que a sua Alçada, Titulo encaminhado para Aprovação!' ,'Alçada de Alteração Financeira','Info')
						
						// Guarda o novo valor
						cE2ACRSCN  := M->E2_ACRESC
						
						// Volta o valor original
						M->E2_ACRESC := cE2ACRESC
						
						// Bloqueia o Titulo
						IF M->E2_XDIVERG <> 'S'
							M->E2_XDIVERG := 'S'
						ENDIF
						
						DbSelectArea("ZC7")
						DbSetOrder(2)
						IF DbSeek( FwxFilial("ZC7") + M->E2_FORNECE + M->E2_LOJA + M->E2_PREFIXO + M->E2_NUM + M->E2_PARCELA + M->E2_TIPO )  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
							IF EMPTY(ZC7_USRAPR)
								RecLock("ZC7",.F.)
									ZC7->ZC7_ACRESC := cE2ACRSCN
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ELSE
								RecLock("ZC7",.T.)
									ZC7->ZC7_FILIAL := FwxFilial("SE2")
									ZC7->ZC7_PREFIX := M->E2_PREFIXO
									ZC7->ZC7_NUM    := M->E2_NUM
									ZC7->ZC7_PARCEL := M->E2_PARCELA
									ZC7->ZC7_TIPO   := M->E2_TIPO
									ZC7->ZC7_CLIFOR := M->E2_FORNECE
									ZC7->ZC7_LOJA   := M->E2_LOJA
									ZC7->ZC7_VLRBLQ := cE2VALOR
									ZC7->ZC7_ACRESC := cE2ACRSCN
									ZC7->ZC7_TPBLQ  := cTpDivf
									ZC7->ZC7_DSCBLQ := sDscBlq += ", Acrescimo"
									ZC7->ZC7_RECPAG := "P"
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						ELSE
							RecLock("ZC7",.T.)
								ZC7->ZC7_FILIAL := FwxFilial("SE2")
								ZC7->ZC7_PREFIX	:= M->E2_PREFIXO
								ZC7->ZC7_NUM   	:= M->E2_NUM
								ZC7->ZC7_PARCEL	:= M->E2_PARCELA
								ZC7->ZC7_TIPO   := M->E2_TIPO
								ZC7->ZC7_CLIFOR	:= M->E2_FORNECE
								ZC7->ZC7_LOJA  	:= M->E2_LOJA
								ZC7->ZC7_VLRBLQ := cE2VALOR
								ZC7->ZC7_ACRESC := cE2ACRSCN
								ZC7->ZC7_TPBLQ 	:= cTpDivf
								ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Acrescimo"
								ZC7->ZC7_RECPAG := "P"
								ZC7->ZC7_USRALT := __cUserID
							MSUnlock()
						ENDIF
					endif
				else
					IF ( cE2VALOR + M->E2_ACRESC ) > ( cE2VALOR + TOLPERACR )  // Ricardo Lima - 22/03/18
						MsgBox('A Alteração realizada é maior do que a sua Alçada, Titulo encaminhado para Aprovação!' ,'Alçada de Alteração Financeira','Info')
						
						// Guarda o novo valor
						cE2ACRSCN  := M->E2_ACRESC
						
						// Volta o valor original
						M->E2_ACRESC := cE2ACRESC
						
						// Bloqueia o Titulo
						IF M->E2_XDIVERG <> 'S'
							M->E2_XDIVERG := 'S'
						ENDIF
						
						DbSelectArea("ZC7")
						DbSetOrder(2)
						IF DbSeek( FwxFilial("ZC7") + M->E2_FORNECE + M->E2_LOJA + M->E2_PREFIXO + M->E2_NUM + M->E2_PARCELA + M->E2_TIPO)  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
							IF EMPTY(ZC7_USRAPR)
								RecLock("ZC7",.F.)
									ZC7->ZC7_ACRESC := cE2ACRSCN
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ELSE
								RecLock("ZC7",.T.)
									ZC7->ZC7_FILIAL := FwxFilial("SE2")
									ZC7->ZC7_PREFIX := M->E2_PREFIXO
									ZC7->ZC7_NUM    := M->E2_NUM
									ZC7->ZC7_PARCEL := M->E2_PARCELA
									ZC7->ZC7_TIPO   := M->E2_TIPO
									ZC7->ZC7_CLIFOR := M->E2_FORNECE
									ZC7->ZC7_LOJA   := M->E2_LOJA
									ZC7->ZC7_VLRBLQ := cE2VALOR
									ZC7->ZC7_ACRESC := cE2ACRSCN
									ZC7->ZC7_TPBLQ  := cTpDivf
									ZC7->ZC7_DSCBLQ := sDscBlq += ", Acrescimo"
									ZC7->ZC7_RECPAG := "P"
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						ELSE
							RecLock("ZC7",.T.)
								ZC7->ZC7_FILIAL := FwxFilial("SE2")
								ZC7->ZC7_PREFIX	:= M->E2_PREFIXO
								ZC7->ZC7_NUM   	:= M->E2_NUM
								ZC7->ZC7_PARCEL	:= M->E2_PARCELA
								ZC7->ZC7_TIPO   := M->E2_TIPO
								ZC7->ZC7_CLIFOR	:= M->E2_FORNECE
								ZC7->ZC7_LOJA  	:= M->E2_LOJA
								ZC7->ZC7_VLRBLQ := cE2VALOR
								ZC7->ZC7_ACRESC := cE2ACRSCN
								ZC7->ZC7_TPBLQ 	:= cTpDivf
								ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Acrescimo"
								ZC7->ZC7_RECPAG := "P"
								ZC7->ZC7_USRALT := __cUserID
							MSUnlock()
						ENDIF
					ENDIF
				endif
			endif
			
			// Bloqueio por Acrescimo Cnab
			if !( cE2CNABACR == M->E2_CNABACR )
				
				if !empty(ZC3PERACR)
					
					if ( cE2VALOR + M->E2_CNABACR ) > ( cE2VALOR + ( cE2VALOR * (ZC3PERACR/100) ) )
						
						MsgBox('A Alteração realizada é maior do que a sua Alçada, Titulo encaminhado para Aprovação!' ,'Alçada de Alteração Financeira','Info')
						
						// Guarda o novo valor
						cE2CNBACRN  := M->E2_CNABACR
						
						// Volta o valor original
						M->E2_CNABACR := cE2CNABACR
						
						// Bloqueia o Titulo
						IF M->E2_XDIVERG <> 'S'
							M->E2_XDIVERG := 'S'
						ENDIF
						
						DbSelectArea("ZC7")
						DbSetOrder(2)
						IF DbSeek( FwxFilial("ZC7") + M->E2_FORNECE + M->E2_LOJA + M->E2_PREFIXO + M->E2_NUM + M->E2_PARCELA + M->E2_TIPO )  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
							IF EMPTY(ZC7_USRAPR)
								RecLock("ZC7",.F.)
									ZC7->ZC7_CNABAC := cE2CNBACRN
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ELSE
								RecLock("ZC7",.T.)
									ZC7->ZC7_FILIAL := FwxFilial("SE2")
									ZC7->ZC7_PREFIX := M->E2_PREFIXO
									ZC7->ZC7_NUM    := M->E2_NUM
									ZC7->ZC7_PARCEL := M->E2_PARCELA
									ZC7->ZC7_TIPO   := M->E2_TIPO
									ZC7->ZC7_CLIFOR := M->E2_FORNECE
									ZC7->ZC7_LOJA   := M->E2_LOJA
									ZC7->ZC7_VLRBLQ := cE2VALOR
									ZC7->ZC7_CNABAC := cE2CNBACRN
									ZC7->ZC7_TPBLQ  := cTpDivf
									ZC7->ZC7_DSCBLQ := sDscBlq += ", Acrescimo"
									ZC7->ZC7_RECPAG := "P"
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						ELSE
							RecLock("ZC7",.T.)
								ZC7->ZC7_FILIAL := FwxFilial("SE2")
								ZC7->ZC7_PREFIX	:= M->E2_PREFIXO
								ZC7->ZC7_NUM   	:= M->E2_NUM
								ZC7->ZC7_PARCEL	:= M->E2_PARCELA
								ZC7->ZC7_TIPO   := M->E2_TIPO
								ZC7->ZC7_CLIFOR	:= M->E2_FORNECE
								ZC7->ZC7_LOJA  	:= M->E2_LOJA
								ZC7->ZC7_VLRBLQ := cE2VALOR
								ZC7->ZC7_CNABAC := cE2CNBACRN
								ZC7->ZC7_TPBLQ 	:= cTpDivf
								ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Acrescimo"
								ZC7->ZC7_RECPAG := "P"
								ZC7->ZC7_USRALT := __cUserID
							MSUnlock()
						ENDIF
					endif
				else
					IF ( cE2VALOR + M->E2_CNABACR ) > ( cE2VALOR + TOLPERACR )  // Ricardo Lima - 22/03/18
						MsgBox('A Alteração realizada é maior do que a sua Alçada, Titulo encaminhado para Aprovação!' ,'Alçada de Alteração Financeira','Info')
						
						// Guarda o novo valor
						cE2CNBACRN  := M->E2_CNABACR
						
						// Volta o valor original
						M->E2_CNABACR := cE2CNABACR
						
						// Bloqueia o Titulo
						IF M->E2_XDIVERG <> 'S'
							M->E2_XDIVERG := 'S'
						ENDIF
						
						DbSelectArea("ZC7")
						DbSetOrder(2)
						IF DbSeek( FwxFilial("ZC7") + M->E2_FORNECE + M->E2_LOJA + M->E2_PREFIXO + M->E2_NUM + M->E2_PARCELA + M->E2_TIPO)  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
							IF EMPTY(ZC7_USRAPR)
								RecLock("ZC7",.F.)
									ZC7->ZC7_CNABAC := cE2CNBACRN
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ELSE
								RecLock("ZC7",.T.)
									ZC7->ZC7_FILIAL := FwxFilial("SE2")
									ZC7->ZC7_PREFIX := M->E2_PREFIXO
									ZC7->ZC7_NUM    := M->E2_NUM
									ZC7->ZC7_PARCEL := M->E2_PARCELA
									ZC7->ZC7_TIPO   := M->E2_TIPO
									ZC7->ZC7_CLIFOR := M->E2_FORNECE
									ZC7->ZC7_LOJA   := M->E2_LOJA
									ZC7->ZC7_VLRBLQ := cE2VALOR
									ZC7->ZC7_CNABAC := cE2CNBACRN
									ZC7->ZC7_TPBLQ  := cTpDivf
									ZC7->ZC7_DSCBLQ := sDscBlq += ", Acrescimo"
									ZC7->ZC7_RECPAG := "P"
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						ELSE
							RecLock("ZC7",.T.)
								ZC7->ZC7_FILIAL := FwxFilial("SE2")
								ZC7->ZC7_PREFIX	:= M->E2_PREFIXO
								ZC7->ZC7_NUM   	:= M->E2_NUM
								ZC7->ZC7_PARCEL	:= M->E2_PARCELA
								ZC7->ZC7_TIPO   := M->E2_TIPO
								ZC7->ZC7_CLIFOR	:= M->E2_FORNECE
								ZC7->ZC7_LOJA  	:= M->E2_LOJA
								ZC7->ZC7_VLRBLQ := cE2VALOR
								ZC7->ZC7_CNABAC := cE2CNBACRN
								ZC7->ZC7_TPBLQ 	:= cTpDivf
								ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Acrescimo"
								ZC7->ZC7_RECPAG := "P"
								ZC7->ZC7_USRALT := __cUserID
							MSUnlock()
						ENDIF
					ENDIF
				endif
			endif
			
			// Bloqueio por Desconto
			if !( cE2CNABDES == M->E2_CNABDES )
				
				if !empty(ZC3PERDES)
					
					if ( cE2VALOR - M->E2_CNABDES ) < ( cE2VALOR - ( cE2VALOR * (ZC3PERDES/100) ) )
						
						MsgBox('A Alteração realizada é maior do que a sua Alçada, Titulo encaminhado para Aprovação!' ,'Alçada de Alteração Financeira','Info')
						
						// Guarda o novo valor
						cE2CNBDESN  := M->E2_CNABDES
						
						// Volta o valor original
						M->E2_CNABDES := cE2CNABDES
						
						// Bloqueia o Titulo
						IF M->E2_XDIVERG <> 'S'
							M->E2_XDIVERG := 'S'
						ENDIF
						
						DbSelectArea("ZC7")
						DbSetOrder(2)
						IF DbSeek( FwxFilial("ZC7") + M->E2_FORNECE + M->E2_LOJA + M->E2_PREFIXO + M->E2_NUM + M->E2_PARCELA + M->E2_TIPO)  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
							IF EMPTY(ZC7_USRAPR)
								RecLock("ZC7",.F.)
									ZC7->ZC7_CNABDE := cE2CNBDESN
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ELSE
								RecLock("ZC7",.T.)
									ZC7->ZC7_FILIAL := FwxFilial("SE2")
									ZC7->ZC7_PREFIX := M->E2_PREFIXO
									ZC7->ZC7_NUM    := M->E2_NUM
									ZC7->ZC7_PARCEL := M->E2_PARCELA
									ZC7->ZC7_TIPO   := M->E2_TIPO
									ZC7->ZC7_CLIFOR := M->E2_FORNECE
									ZC7->ZC7_LOJA   := M->E2_LOJA
									ZC7->ZC7_VLRBLQ := cE2VALOR
									ZC7->ZC7_CNABDE := cE2CNBDESN
									ZC7->ZC7_TPBLQ  := cTpDivf
									ZC7->ZC7_DSCBLQ := sDscBlq += ", Desconto"
									ZC7->ZC7_RECPAG := "P"
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						ELSE
							RecLock("ZC7",.T.)
								ZC7->ZC7_FILIAL := FwxFilial("SE2")
								ZC7->ZC7_PREFIX	:= M->E2_PREFIXO
								ZC7->ZC7_NUM   	:= M->E2_NUM
								ZC7->ZC7_PARCEL	:= M->E2_PARCELA
								ZC7->ZC7_TIPO   := M->E2_TIPO
								ZC7->ZC7_CLIFOR	:= M->E2_FORNECE
								ZC7->ZC7_LOJA  	:= M->E2_LOJA
								ZC7->ZC7_VLRBLQ := cE2VALOR
								ZC7->ZC7_CNABDE := cE2CNBDESN
								ZC7->ZC7_TPBLQ 	:= cTpDivf
								ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Desconto"
								ZC7->ZC7_RECPAG := "P"
								ZC7->ZC7_USRALT := __cUserID
							MSUnlock()
						ENDIF
					endif
				else
					IF ( cE2VALOR - M->E2_CNABDES ) < ( cE2VALOR - TOLPERDES ) // Ricardo Lima - 22/03/18
						MsgBox('A Alteração realizada é maior do que a sua Alçada, Titulo encaminhado para Aprovação!' ,'Alçada de Alteração Financeira','Info')
						
						// Guarda o novo valor
						cE2CNBDESN  := M->E2_CNABDES
						
						// Volta o valor original
						M->E2_CNABDES := cE2CNABDES
						
						// Bloqueia o Titulo
						IF M->E2_XDIVERG <> 'S'
							M->E2_XDIVERG := 'S'
						ENDIF
						
						DbSelectArea("ZC7")
						DbSetOrder(2)
						IF DbSeek( FwxFilial("ZC7") + M->E2_FORNECE + M->E2_LOJA + M->E2_PREFIXO + M->E2_NUM + M->E2_PARCELA + M->E2_TIPO)  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
							IF EMPTY(ZC7_USRAPR)
								RecLock("ZC7",.F.)
									ZC7->ZC7_CNABDE := cE2CNBDESN
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ELSE
								RecLock("ZC7",.T.)
									ZC7->ZC7_FILIAL := FwxFilial("SE2")
									ZC7->ZC7_PREFIX := M->E2_PREFIXO
									ZC7->ZC7_NUM    := M->E2_NUM
									ZC7->ZC7_PARCEL := M->E2_PARCELA
									ZC7->ZC7_TIPO   := M->E2_TIPO
									ZC7->ZC7_CLIFOR := M->E2_FORNECE
									ZC7->ZC7_LOJA   := M->E2_LOJA
									ZC7->ZC7_VLRBLQ := cE2VALOR
									ZC7->ZC7_CNABDE := cE2CNBDESN
									ZC7->ZC7_TPBLQ  := cTpDivf
									ZC7->ZC7_DSCBLQ := sDscBlq += ", Desconto"
									ZC7->ZC7_RECPAG := "P"
									ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						ELSE
							RecLock("ZC7",.T.)
								ZC7->ZC7_FILIAL := FwxFilial("SE2")
								ZC7->ZC7_PREFIX	:= M->E2_PREFIXO
								ZC7->ZC7_NUM   	:= M->E2_NUM
								ZC7->ZC7_PARCEL	:= M->E2_PARCELA
								ZC7->ZC7_TIPO   := M->E2_TIPO
								ZC7->ZC7_CLIFOR	:= M->E2_FORNECE
								ZC7->ZC7_LOJA  	:= M->E2_LOJA
								ZC7->ZC7_VLRBLQ := cE2VALOR
								ZC7->ZC7_CNABDE := cE2CNBDESN
								ZC7->ZC7_TPBLQ 	:= cTpDivf
								ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Desconto"
								ZC7->ZC7_RECPAG := "P"
								ZC7->ZC7_USRALT := __cUserID
							MSUnlock()
						ENDIF
					ENDIF
				endif
			endif
			
			IF M->E2_XDIVERG = 'S'
			
				// Chamado n. 055321 || OS 056879 || FINANCAS || EDUARDO || 8352 || APROVADOR AUSENTE - FWNM - 05/02/2020
				If Select("Work") > 0
					Work->(DbCloseArea())
				EndIf

				// Checo se esta ausente
				cQuery := " SELECT ZC3_CODUSU, ZC3_NOMUSU, ZCF_NIVEL, ZCF_CODIGO, ZC3_APRATV, ZC3_SUPAPR, ZC3_NOMSUP
				cQuery += " FROM "+RetSqlName("ZC3")+" ZC3 (NOLOCK)
				cQuery += " INNER JOIN "+RetSqlName("ZCF")+" ZCF (NOLOCK) ON ZC3_CODUSU=ZCF_APROVA AND ZCF.D_E_L_E_T_ = ' '
				cQuery += " WHERE ZCF_CODIGO = '"+cTpDivf+"' AND ZC3_APRATV = '1' AND ZCF_NIVEL='01' AND ZC3.D_E_L_E_T_ = ' '
				cQuery += " ORDER BY ZCF_NIVEL

				tcQuery cQuery New Alias "Work"

				Work->( dbGoTop() )
				Do While Work->( !EOF() )

					cDscObs := '[Ausente] - Aprovado automaticamente '

					RecLock("ZC7",.F.)
							
						ZC7->ZC7_USRAPR := AllTrim( Work->ZC3_CODUSU )
						ZC7->ZC7_NOMAPR := AllTrim( Work->ZC3_NOMUSU )
						ZC7->ZC7_DTAPR  := Date()
						ZC7->ZC7_HRAPR  := Time()
						ZC7->ZC7_OBS    := cDscObs

					ZC7->( msUnlock() )

					// Gero proximo nivel
					aZC7Novo := {}
					Aadd(aZC7Novo,{ ZC7->ZC7_FILIAL ,;
								ZC7->ZC7_PREFIX  ,;
								ZC7->ZC7_NUM     ,;
								ZC7->ZC7_PARCEL  ,;
								ZC7->ZC7_TIPO    ,;
								ZC7->ZC7_CLIFOR  ,;
								ZC7->ZC7_LOJA    ,;
								ZC7->ZC7_VLRBLQ  ,;
								ZC7->ZC7_DECRES  ,;
								ZC7->ZC7_TPBLQ   ,;
								ZC7->ZC7_DSCBLQ  ,;
								ZC7->ZC7_RECPAG  ,;
								ZC7->ZC7_PROJET  ,;
								ZC7->ZC7_NDTVEN  ,;
								ZC7->ZC7_NDTVCR  ,;
								ZC7->ZC7_VLRJUR  ,;
								ZC7->ZC7_ACRESC  ,;
								ZC7->ZC7_CNABAC  ,;
								ZC7->ZC7_CNABDE  ,;
								ZC7->ZC7_REVPRJ  ,;
								ZC7->ZC7_OBS     ,;
								ZC7->ZC7_NIVEL   ,;
								ZC7->ZC7_CUSFIN  ,;
								ZC7->ZC7_PERCUS  ,;
								ZC7->ZC7_NUMCAL  ,;
								ZC7->ZC7_NIVSEG  ,;
								ZC7->ZC7_ODTVEN  ,; 
								ZC7->ZC7_ODTVCR})

					zc := 1
					cZC7Nivel  := Iif(EMPTY(aZC7Novo[zc,22]) , SOMA1( ALLTRIM( "01" ) ) , SOMA1( ALLTRIM( aZC7Novo[zc,22] ) ) )
					cZC7NivSeg := ALLTRIM( ZC7->ZC7_NIVSEG )

					RecLock("ZC7",.T.)

						ZC7->ZC7_FILIAL := aZC7Novo[zc,1]
						ZC7->ZC7_PREFIX := aZC7Novo[zc,2]
						ZC7->ZC7_NUM    := aZC7Novo[zc,3]
						ZC7->ZC7_PARCEL := aZC7Novo[zc,4]
						ZC7->ZC7_TIPO   := aZC7Novo[zc,5]
						ZC7->ZC7_CLIFOR := aZC7Novo[zc,6]
						ZC7->ZC7_LOJA   := aZC7Novo[zc,7]
						ZC7->ZC7_VLRBLQ := aZC7Novo[zc,8]
						ZC7->ZC7_DECRES := aZC7Novo[zc,9]
						ZC7->ZC7_TPBLQ  := aZC7Novo[zc,10]
						ZC7->ZC7_DSCBLQ := aZC7Novo[zc,11]
						ZC7->ZC7_RECPAG := aZC7Novo[zc,12]
						ZC7->ZC7_PROJET := aZC7Novo[zc,13]
						ZC7->ZC7_NDTVEN := aZC7Novo[zc,14]
						ZC7->ZC7_NDTVCR := aZC7Novo[zc,15]
						ZC7->ZC7_VLRJUR := aZC7Novo[zc,16]
						ZC7->ZC7_ACRESC := aZC7Novo[zc,17]
						ZC7->ZC7_CNABAC := aZC7Novo[zc,18]
						ZC7->ZC7_CNABDE := aZC7Novo[zc,19]
						ZC7->ZC7_REVPRJ := aZC7Novo[zc,20]
						ZC7->ZC7_NIVEL  := cZC7Nivel
						ZC7->ZC7_CUSFIN := aZC7Novo[zc,23]
						ZC7->ZC7_PERCUS := aZC7Novo[zc,24]
						ZC7->ZC7_NUMCAL := aZC7Novo[zc,25]
						ZC7->ZC7_NIVSEG := SOMA1( cZC7NivSeg )
						ZC7->ZC7_ODTVEN := aZC7Novo[zc,27]
						ZC7->ZC7_ODTVCR := aZC7Novo[zc,28]
						ZC7->ZC7_USRALT := __cUserID

					ZC7->( MSUnlock() )

					Work->( dbSkip() )

				EndDo
				//

				// Envio de Pendencia Para o Aprovador não Ausente
				c2Query := " SELECT ZC3_CODUSU, ZC3_NOMUSU, ZCF_NIVEL, ZCF_CODIGO, ZC3_APRATV "
				c2Query += " FROM "+RetSqlName("ZC3")+" ZC3 "
				c2Query += " INNER JOIN "+RetSqlName("ZCF")+" ZCF ON ZC3_CODUSU=ZCF_APROVA AND ZCF.D_E_L_E_T_ = ' ' "
				c2Query += " WHERE ZCF_CODIGO = '"+cTpDivf+"' AND ZC3_APRATV <> '1' AND ZC3.D_E_L_E_T_ = ' ' "
				c2Query += " ORDER BY ZCF_NIVEL "
				If Select("TMPZC3") > 0
					TMPZC3->(DbCloseArea())
				EndIf
				TcQuery c2Query New Alias "TMPZC3"
				IF !EMPTY(TMPZC3->ZC3_CODUSU)
					cmaildest := AllTrim(UsrRetMail( TMPZC3->ZC3_CODUSU ))
				ENDIF
				// RICARDO LIMA - 13/02/18
				cMensagem := u_WGFA050FIN( FwxFilial("SE2") , SE2->E2_PREFIXO , SE2->E2_NUM , SE2->E2_PARCELA , SE2->E2_FORNECE , SE2->E2_LOJA , SE2->E2_VALOR , sDscBlq , 'F' )
				If lEnvWFCA
					u_F050EnvWF( cAssunto , cMensagem , cmaildest , '' )
				Endif
			ENDIF
			
		//Endif
		
	EndIf

Return lRet

/*/{Protheus.doc} User Function nomeFunction
	(long_description)
	@type  Function
	@author user
	@since 14/02/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	// @history ticket   67909 - Fer Macieira - 15/02/2022 - Pagamento GTA - SC
/*/
User Function ChkCodBar(cCodBar)

	Local lOk        := .t.
	Local cX2CodEmp  := ""
	Local cStartPath := GetSrvProfString("Startpath","")
	Local cX2ARQUIVO := ""
	
	Default cCodBar  := ""

	SM0->( dbGoTop() )
	Do While SM0->( !EOF() )

		// Outra Empresa
		If FWCodEmp() <> SM0->M0_CODIGO

			If Select("SX2EMP") > 0
				SX2EMP->( dbCloseArea() )
			EndIf
					
			dbUseArea(.T., __LocalDriver, cStartPath+"SX2"+SM0->M0_CODIGO+"0"+GetDbExtension(), "SX2EMP", .T., .F.)

			SX2EMP->( dbSetOrder(1) ) // X2_CHAVE
			If SX2EMP->( dbSeek("SE2") )
				cX2ARQUIVO := AllTrim(SX2EMP->X2_ARQUIVO)
			EndIf

		Else

			SX2->( dbSetOrder(1) ) // x2_chave
			If SX2->( dbSeek("SE2") )
				cX2ARQUIVO := AllTrim(SX2->X2_ARQUIVO)
			EndIf

		EndIf

		// 
		If !(cX2ARQUIVO $ cX2CodEmp)

			cX2CodEmp := cX2ARQUIVO + "#" + cX2CodEmp

			If Select("Work") > 0
				Work->( dbCloseArea() )
			EndIf

			cQuery := " SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMFOR
			cQuery += " FROM " + cX2ARQUIVO + " (NOLOCK)
			cQuery += " WHERE E2_CODBAR='"+cCodBar+"' 
			cQuery += " AND E2_CODBAR<>''
			cQuery += " AND D_E_L_E_T_=''

			tcQuery cQuery new Alias "Work"

			Work->( dbGoTop() )
			If Work->(!EOF() )
				lOk := .f.
				Alert("Código de Barra duplicado! Já existe cadastrado na tabela " + cX2ARQUIVO + chr(13) + chr(10) +;
						" Dados do título encontrado: " + chr(13) + chr(10) +;
						" Filial: " + Work->E2_FILIAL + chr(13) + chr(10) +;
						" Prefixo: " + Work->E2_PREFIXO + chr(13) + chr(10) +;
						" Número: " + Work->E2_NUM + chr(13) + chr(10) +;
						" Parcela: " + Work->E2_PARCELA + chr(13) + chr(10) +;
						" Tipo: " + Work->E2_TIPO + chr(13) + chr(10) +;
						" Fornecedor: " + Work->E2_FORNECE + "/" + Work->E2_LOJA + " - " + Work->E2_NOMFOR)
				Exit
			EndIf

			If Select("Work") > 0
				Work->( dbCloseArea() )
			EndIf

		EndIf

		SM0->( dbSkip() )

	EndDo

	If Select("SX2EMP") > 0
		SX2EMP->( dbCloseArea() )
	EndIf

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	
Return lOk
