#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"
#INCLUDE "AP5MAIL.CH"

/*/{Protheus.doc} User Function FA040ALT
Alcada de Alteracao para titulos
@type  Function
@author Ricardo Lima
@since 18/11/2017
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
@history Chamado 038609
@history Chamado 038609 - Ricardo Lima - 22/03/2018 - Considera tolerância para alterações de títulos
@history Chamado 053347 - FWNM         - 29/11/2019 - 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL
/*/
User Function FA040ALT

	Local lRet := .T.
	Local cTpDivf   := "000004"
	Local nDiaMenos := 0
	Local nDiaMais  := 0
	Local lPerAlt   := .F.
	Local ZC3PERDEC := 0
	Local ZC3PERDES := 0
	Local ZC3PERJUR := 0
	Local ZC3PERACR := 0

	Local cE1VALOR   := SE1->E1_VALOR

	Local cE1DECRESC := SE1->E1_DECRESC
	Local cE1DCRESCN := SE1->E1_DECRESC

	Local cE1ACRESC  := SE1->E1_ACRESC
	Local cE1ACRSCN  := SE1->E1_ACRESC

	Local cE1VALJUR  := SE1->E1_VALJUR
	Local cE1VLJURN  := SE1->E1_VALJUR

	Local cE1DESCFIN := SE1->E1_DESCFIN
	Local cE1DSCFINN := SE1->E1_DESCFIN

	Local dE1VENCTO  := SE1->E1_VENCTO
	Local dE1VECTON  := SE1->E1_VENCTO
	Local dE1VENCREA := SE1->E1_VENCREA
	Local dE1VECREAN := SE1->E1_VENCREA
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


	If Alltrim(Funname()) <> "CENTNFEXM" //fernando sigoli 02/03/2018
		
		//if cEmpAnt = '01' .or. cEmpAnt = '02' // Chamado n. 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL - FWNM - 29/11/2019
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
			If !( Alltrim(DTOC(M->E1_VENCTO)) == Alltrim(DTOC(SE1->E1_VENCTO)) )
				
				// Ricardo Lima - 18/04/18
				IF M->E1_VENCTO < dE1VENCTO
					dDifData := dE1VENCTO - M->E1_VENCTO
					nVlrCust := ((cE1VALOR * ( nPerCust/100 )) / 30) * dDifData
					M->E1_XCUSFIN := nVlrCust
				ElseIf M->E1_VENCTO  > dE1VENCTO
					dDifData := M->E1_VENCTO - dE1VENCTO
					nVlrCust := ((cE1VALOR * ( nPerCust/100 )) / 30) * dDifData
					M->E1_XCUSFIN := nVlrCust
				EndIf
				
				if lPerAlt
					if M->E1_VENCTO < dE1VENCTO  // Antecipa Vencimento
						if M->E1_VENCTO < ( dE1VENCTO - nDiaMenos ) .OR. nVlrCust > TOLPERJUR
							IF M->E1_VENCTO > ( dE1VENCTO - nDiaMenos ) .AND. nVlrCust > TOLPERJUR
								cMsgCFin := "Custo Financeiro Maior que Tolerancia"
							Else
								cMsgCFin := ""
							EndIf
							
							MsgBox('A Alteração realizada é maior do que a sua Alçada, Titulo encaminhado para Aprovação!','Alçada de Alteração Financeira','Info')
							// guarda o novo vencimento para uso apos aprovacao
							dE1VECTON  := M->E1_VENCTO
							dE1VECREAN := M->E1_VENCREA
							
							// Bloqueia o Titulo
							M->E1_XDIVERG := 'S'
							
							// Volta o vencimento original, apos aprovacao sera alterado
							M->E1_VENCTO  := dE1VENCTO
							M->E1_VENCREA := dE1VENCREA
							
							// gera registro para aprovacao
							DbSelectArea("ZC7")
							DbSetOrder(2)
							IF DbSeek( FwxFilial("ZC7") + M->E1_CLIENTE + M->E1_LOJA + M->E1_PREFIXO + M->E1_NUM + M->E1_PARCELA + M->E1_TIPO )  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
								IF EMPTY(ZC7_USRAPR)
									RecLock("ZC7",.F.)
									ZC7->ZC7_NDTVEN := dE1VECTON
									ZC7->ZC7_NDTVCR := dE1VECREAN
									ZC7->ZC7_CUSFIN := nVlrCust
									ZC7->ZC7_PERCUS := ALLTRIM(STR(nPerCust))
									ZC7->ZC7_NUMCAL := ALLTRIM(STR(dDifData))
									ZC7->ZC7_USRALT := __cUserID
									MSUnlock()
								ELSE
									RecLock("ZC7",.T.)
									ZC7->ZC7_FILIAL := FwxFilial("SE1")
									ZC7->ZC7_PREFIX := M->E1_PREFIXO
									ZC7->ZC7_NUM    := M->E1_NUM
									ZC7->ZC7_PARCEL := M->E1_PARCELA
									ZC7->ZC7_TIPO   := M->E1_TIPO
									ZC7->ZC7_CLIFOR := M->E1_CLIENTE
									ZC7->ZC7_LOJA   := M->E1_LOJA
									ZC7->ZC7_NDTVEN := dE1VECTON
									ZC7->ZC7_NDTVCR := dE1VECREAN
									ZC7->ZC7_TPBLQ  := cTpDivf
									ZC7->ZC7_DSCBLQ := sDscBlq += ", Dt Vencimento, "+cMsgCFin
									ZC7->ZC7_RECPAG := "R"
									ZC7->ZC7_ODTVEN := dE1VENCTO // RICARDO LIMA - 13/02/18
									ZC7->ZC7_ODTVCR := dE1VENCREA // RICARDO LIMA - 13/02/18
									ZC7->ZC7_CUSFIN := nVlrCust // Ricardo LIma - 18/04/18
									ZC7->ZC7_VLRBLQ := cE1VALOR // Ricardo LIma - 18/04/18
									ZC7->ZC7_PERCUS := ALLTRIM(STR(nPerCust)) // Ricardo LIma - 18/04/18
									ZC7->ZC7_NUMCAL := ALLTRIM(STR(dDifData)) // Ricardo LIma - 18/04/18
									ZC7->ZC7_USRALT := __cUserID
									MSUnlock()
								ENDIF
							ELSE
								RecLock("ZC7",.T.)
								ZC7->ZC7_FILIAL := FwxFilial("SE1")
								ZC7->ZC7_PREFIX	:= M->E1_PREFIXO
								ZC7->ZC7_NUM   	:= M->E1_NUM
								ZC7->ZC7_PARCEL	:= M->E1_PARCELA
								ZC7->ZC7_TIPO   := M->E1_TIPO
								ZC7->ZC7_CLIFOR	:= M->E1_CLIENTE
								ZC7->ZC7_LOJA  	:= M->E1_LOJA
								ZC7->ZC7_NDTVEN := dE1VECTON
								ZC7->ZC7_NDTVCR := dE1VECREAN
								ZC7->ZC7_TPBLQ 	:= cTpDivf
								ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Dt Vencimento, "+cMsgCFin
								ZC7->ZC7_RECPAG := "R"
								ZC7->ZC7_ODTVEN := dE1VENCTO // RICARDO LIMA - 13/02/18
								ZC7->ZC7_ODTVCR := dE1VENCREA // RICARDO LIMA - 13/02/18
								ZC7->ZC7_CUSFIN := nVlrCust // Ricardo LIma - 18/04/18
								ZC7->ZC7_VLRBLQ := cE1VALOR // Ricardo LIma - 18/04/18
								ZC7->ZC7_PERCUS := ALLTRIM(STR(nPerCust)) // Ricardo LIma - 18/04/18
								ZC7->ZC7_NUMCAL := ALLTRIM(STR(dDifData)) // Ricardo LIma - 18/04/18
								ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						endif
					Elseif M->E1_VENCTO > dE1VENCTO  // Posterga Vencimento
						if M->E1_VENCTO  > ( dE1VENCTO + nDiaMais ) .OR. nVlrCust > TOLPERDES
							IF M->E1_VENCTO < ( dE1VENCTO + nDiaMais ) .AND. nVlrCust > TOLPERDES
								cMsgCFin := "Custo Financeiro Maior que Tolerancia"
							Else
								cMsgCFin := ""
							EndIf
							
							MsgBox('A Alteração realizada é maior do que a sua Alçada, Titulo encaminhado para Aprovação!' ,'Alçada de Alteração Financeira','Info')
							// guarda o novo vencimento para uso apos aprovacao
							dE1VECTON  := M->E1_VENCTO
							dE1VECREAN := M->E1_VENCREA
							
							// Bloqueia o Titulo
							M->E1_XDIVERG := 'S'
							
							// Volta o vencimento original, apos aprovacao sera alterado
							M->E1_VENCTO  := dE1VENCTO
							M->E1_VENCREA := dE1VENCREA
							
							// gera registro para aprovacao
							DbSelectArea("ZC7")
							DbSetOrder(2)
							IF DbSeek( FwxFilial("ZC7") + M->E1_CLIENTE + M->E1_LOJA + M->E1_PREFIXO + M->E1_NUM + M->E1_PARCELA + M->E1_TIPO)  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
								IF EMPTY(ZC7_USRAPR)
									RecLock("ZC7",.F.)
									ZC7->ZC7_NDTVEN := dE1VECTON
									ZC7->ZC7_NDTVCR := dE1VECREAN
									ZC7->ZC7_CUSFIN := nVlrCust
									ZC7->ZC7_PERCUS := ALLTRIM(STR(nPerCust))
									ZC7->ZC7_NUMCAL := ALLTRIM(STR(dDifData))
									ZC7->ZC7_USRALT := __cUserID
									MSUnlock()
								ELSE
									RecLock("ZC7",.T.)
									ZC7->ZC7_FILIAL := FwxFilial("SE1")
									ZC7->ZC7_PREFIX := M->E1_PREFIXO
									ZC7->ZC7_NUM    := M->E1_NUM
									ZC7->ZC7_PARCEL := M->E1_PARCELA
									ZC7->ZC7_TIPO   := M->E1_TIPO
									ZC7->ZC7_CLIFOR := M->E1_CLIENTE
									ZC7->ZC7_LOJA   := M->E1_LOJA
									ZC7->ZC7_NDTVEN := dE1VECTON
									ZC7->ZC7_NDTVCR := dE1VECREAN
									ZC7->ZC7_TPBLQ  := cTpDivf
									ZC7->ZC7_DSCBLQ := sDscBlq += ", Dt Vencimento, "+cMsgCFin
									ZC7->ZC7_RECPAG := "R"
									ZC7->ZC7_ODTVEN := dE1VENCTO // RICARDO LIMA - 13/02/18
									ZC7->ZC7_ODTVCR := dE1VENCREA // RICARDO LIMA - 13/02/18
									ZC7->ZC7_CUSFIN := nVlrCust // Ricardo LIma - 18/04/18
									ZC7->ZC7_VLRBLQ := cE1VALOR // Ricardo LIma - 18/04/18
									ZC7->ZC7_PERCUS := ALLTRIM(STR(nPerCust)) // Ricardo LIma - 18/04/18
									ZC7->ZC7_NUMCAL := ALLTRIM(STR(dDifData)) // Ricardo LIma - 18/04/18
									ZC7->ZC7_USRALT := __cUserID
									MSUnlock()
								ENDIF
							ELSE
								RecLock("ZC7",.T.)
								ZC7->ZC7_FILIAL := FwxFilial("SE1")
								ZC7->ZC7_PREFIX	:= M->E1_PREFIXO
								ZC7->ZC7_NUM   	:= M->E1_NUM
								ZC7->ZC7_PARCEL	:= M->E1_PARCELA
								ZC7->ZC7_TIPO   := M->E1_TIPO
								ZC7->ZC7_CLIFOR	:= M->E1_CLIENTE
								ZC7->ZC7_LOJA  	:= M->E1_LOJA
								ZC7->ZC7_NDTVEN := dE1VECTON
								ZC7->ZC7_NDTVCR := dE1VECREAN
								ZC7->ZC7_TPBLQ 	:= cTpDivf
								ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Dt Vencimento, "+cMsgCFin
								ZC7->ZC7_RECPAG := "R"
								ZC7->ZC7_ODTVEN := dE1VENCTO // RICARDO LIMA - 13/02/18
								ZC7->ZC7_ODTVCR := dE1VENCREA // RICARDO LIMA - 13/02/18
								ZC7->ZC7_CUSFIN := nVlrCust // Ricardo LIma - 18/04/18
								ZC7->ZC7_VLRBLQ := cE1VALOR // Ricardo LIma - 18/04/18
								ZC7->ZC7_PERCUS := ALLTRIM(STR(nPerCust)) // Ricardo LIma - 18/04/18
								ZC7->ZC7_NUMCAL := ALLTRIM(STR(dDifData)) // Ricardo LIma - 18/04/18
								ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						endif
					endif
				else
					// Ricardo Lima - 18/04/18
					IF M->E1_VENCTO < dE1VENCTO
						dDifData := dE1VENCTO - M->E1_VENCTO
						nVlrCust := ((cE1VALOR * ( nPerCust/100 )) / 30) * dDifData
						M->E1_XCUSFIN := nVlrCust
					ElseIf M->E1_VENCTO  > dE1VENCTO
						dDifData := M->E1_VENCTO - dE1VENCTO
						nVlrCust := ((cE1VALOR * ( nPerCust/100 )) / 30) * dDifData
						M->E1_XCUSFIN := nVlrCust
					EndIf
					
					IF ( M->E1_VENCTO < ( dE1VENCTO - nDMenosTol ) .or. nVlrCust > TOLPERJUR ) .OR. ( M->E1_VENCTO  > ( dE1VENCTO + nDMaisTol ) .or. nVlrCust > TOLPERDES ) // Ricardo Lima - 22/03/18
						If ( M->E1_VENCTO > ( dE1VENCTO - nDMenosTol ) .AND. nVlrCust > TOLPERJUR ) .OR. ( M->E1_VENCTO < ( dE1VENCTO + nDMaisTol ) .AND. nVlrCust > TOLPERDES )
							cMsgCFin := "Custo Financeiro Maior que Tolerancia"
						Else
							cMsgCFin := ""
						EndIf
						
						MsgBox('Você não tem Alçada para Alteração, O Titulo será encaminhado para Aprovação!' ,'Alçada de Alteração Financeira','Info')
						// guarda o novo vencimento para uso apos aprovacao
						dE1VECTON := M->E1_VENCTO
						dE1VECREAN := M->E1_VENCREA
						
						// Bloqueia o Titulo
						M->E1_XDIVERG := 'S'
						
						// Volta o vencimento original, apos aprovacao sera alterado
						M->E1_VENCTO  := dE1VENCTO
						M->E1_VENCREA := dE1VENCREA
						
						// gera registro para aprovacao
						DbSelectArea("ZC7")
						DbSetOrder(2)
						IF DbSeek( FwxFilial("ZC7") + M->E1_CLIENTE + M->E1_LOJA + M->E1_PREFIXO + M->E1_NUM + M->E1_PARCELA + M->E1_TIPO)  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
							IF EMPTY(ZC7_USRAPR)
								RecLock("ZC7",.F.)
								ZC7->ZC7_NDTVEN := dE1VECTON
								ZC7->ZC7_NDTVCR := dE1VECREAN
								ZC7->ZC7_CUSFIN := nVlrCust
								ZC7->ZC7_PERCUS := ALLTRIM(STR(nPerCust))
								ZC7->ZC7_NUMCAL := ALLTRIM(STR(dDifData))
								ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ELSE
								RecLock("ZC7",.T.)
								ZC7->ZC7_FILIAL := FwxFilial("SE1")
								ZC7->ZC7_PREFIX := M->E1_PREFIXO
								ZC7->ZC7_NUM    := M->E1_NUM
								ZC7->ZC7_PARCEL := M->E1_PARCELA
								ZC7->ZC7_TIPO   := M->E1_TIPO
								ZC7->ZC7_CLIFOR := M->E1_CLIENTE
								ZC7->ZC7_LOJA   := M->E1_LOJA
								ZC7->ZC7_NDTVEN := dE1VECTON
								ZC7->ZC7_NDTVCR := dE1VECREAN
								ZC7->ZC7_TPBLQ  := cTpDivf
								ZC7->ZC7_DSCBLQ := sDscBlq += ", Dt Vencimento, "+cMsgCFin
								ZC7->ZC7_RECPAG := "R"
								ZC7->ZC7_ODTVEN := dE1VENCTO // RICARDO LIMA - 13/02/18
								ZC7->ZC7_ODTVCR := dE1VENCREA // RICARDO LIMA - 13/02/18
								ZC7->ZC7_CUSFIN := nVlrCust // Ricardo LIma - 18/04/18
								ZC7->ZC7_VLRBLQ := cE1VALOR // Ricardo LIma - 18/04/18
								ZC7->ZC7_PERCUS := ALLTRIM(STR(nPerCust)) // Ricardo LIma - 18/04/18
								ZC7->ZC7_NUMCAL := ALLTRIM(STR(dDifData)) // Ricardo LIma - 18/04/18
								ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						ELSE
							RecLock("ZC7",.T.)
							ZC7->ZC7_FILIAL := FwxFilial("SE1")
							ZC7->ZC7_PREFIX	:= M->E1_PREFIXO
							ZC7->ZC7_NUM   	:= M->E1_NUM
							ZC7->ZC7_PARCEL	:= M->E1_PARCELA
							ZC7->ZC7_TIPO   := M->E1_TIPO
							ZC7->ZC7_CLIFOR	:= M->E1_CLIENTE
							ZC7->ZC7_LOJA  	:= M->E1_LOJA
							ZC7->ZC7_NDTVEN := dE1VECTON
							ZC7->ZC7_NDTVCR := dE1VECREAN
							ZC7->ZC7_TPBLQ 	:= cTpDivf
							ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Dt Vencimento, "+cMsgCFin
							ZC7->ZC7_RECPAG := "R"
							ZC7->ZC7_ODTVEN := dE1VENCTO // RICARDO LIMA - 13/02/18
							ZC7->ZC7_ODTVCR := dE1VENCREA // RICARDO LIMA - 13/02/18
							ZC7->ZC7_CUSFIN := nVlrCust // Ricardo LIma - 18/04/18
							ZC7->ZC7_VLRBLQ := cE1VALOR // Ricardo LIma - 18/04/18
							ZC7->ZC7_PERCUS := ALLTRIM(STR(nPerCust)) // Ricardo LIma - 18/04/18
							ZC7->ZC7_NUMCAL := ALLTRIM(STR(dDifData)) // Ricardo LIma - 18/04/18
							ZC7->ZC7_USRALT := __cUserID
							MSUnlock()
						ENDIF
					ENDIF
				endif
			endif
			
			// Bloqueio por Juros
			if !( cE1VALJUR  == M->E1_VALJUR )
				
				if !empty(ZC3PERJUR)
					
					if (cE1VALOR+M->E1_VALJUR) > ( cE1VALOR + ( cE1VALOR * (ZC3PERJUR/100) ) )
						
						MsgBox('A Alteração realizada é maior do que a sua Alçada, Titulo encaminhado para Aprovação!' ,'Alçada de Alteração Financeira','Info')
						
						// Guarda o novo valor
						cE1VLJURN  := M->E1_VALJUR
						cE1VALOR   := M->E1_VALOR
						
						// Volta o valor original
						M->E1_VALJUR := cE1VALJUR
						
						// Bloqueia o Titulo
						IF M->E1_XDIVERG <> 'S'
							M->E1_XDIVERG := 'S'
						ENDIF
						
						DbSelectArea("ZC7")
						DbSetOrder(2)
						IF DbSeek( FwxFilial("ZC7") + M->E1_CLIENTE + M->E1_LOJA + M->E1_PREFIXO + M->E1_NUM + M->E1_PARCELA + M->E1_TIPO)  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
							IF EMPTY(ZC7_USRAPR)
								RecLock("ZC7",.F.)
								ZC7->ZC7_VLRJUR := cE1VLJURN
								ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ELSE
								RecLock("ZC7",.T.)
								ZC7->ZC7_FILIAL := FwxFilial("SE1")
								ZC7->ZC7_PREFIX	:= M->E1_PREFIXO
								ZC7->ZC7_NUM   	:= M->E1_NUM
								ZC7->ZC7_PARCEL	:= M->E1_PARCELA
								ZC7->ZC7_TIPO      := M->E1_TIPO
								ZC7->ZC7_CLIFOR	:= M->E1_CLIENTE
								ZC7->ZC7_LOJA  	:= M->E1_LOJA
								ZC7->ZC7_VLRBLQ    := cE1VALOR
								ZC7->ZC7_VLRJUR    := cE1VLJURN
								ZC7->ZC7_TPBLQ 	:= cTpDivf
								ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Juros"
								ZC7->ZC7_RECPAG := "R"
								ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						ELSE
							RecLock("ZC7",.T.)
							ZC7->ZC7_FILIAL := FwxFilial("SE1")
							ZC7->ZC7_PREFIX	:= M->E1_PREFIXO
							ZC7->ZC7_NUM   	:= M->E1_NUM
							ZC7->ZC7_PARCEL	:= M->E1_PARCELA
							ZC7->ZC7_TIPO   := M->E1_TIPO
							ZC7->ZC7_CLIFOR	:= M->E1_CLIENTE
							ZC7->ZC7_LOJA  	:= M->E1_LOJA
							ZC7->ZC7_VLRBLQ := cE1VALOR
							ZC7->ZC7_VLRJUR := cE1VLJURN
							ZC7->ZC7_TPBLQ 	:= cTpDivf
							ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Juros"
							ZC7->ZC7_RECPAG := "R"
							ZC7->ZC7_USRALT := __cUserID
							MSUnlock()
						ENDIF
					endif
				else
					
					IF (cE1VALOR+M->E1_VALJUR) > ( cE1VALOR + TOLPERJUR )  // Ricardo Lima - 22/03/18
						MsgBox('A Alteração realizada é maior do que a sua Alçada, Titulo encaminhado para Aprovação!' ,'Alçada de Alteração Financeira','Info')
						
						// Guarda o novo valor
						cE1VLJURN  := M->E1_VALJUR
						cE1VALOR   := M->E1_VALOR
						
						// Volta o valor original
						M->E1_VALJUR := cE1VALJUR
						
						// Bloqueia o Titulo
						IF M->E1_XDIVERG <> 'S'
							M->E1_XDIVERG := 'S'
						ENDIF
						
						DbSelectArea("ZC7")
						DbSetOrder(2)
						IF DbSeek( FwxFilial("ZC7") + M->E1_CLIENTE + M->E1_LOJA + M->E1_PREFIXO + M->E1_NUM + M->E1_PARCELA + M->E1_TIPO)  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
							IF EMPTY(ZC7_USRAPR)
								RecLock("ZC7",.F.)
								ZC7->ZC7_VLRJUR := cE1VLJURN
								ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ELSE
								RecLock("ZC7",.T.)
								ZC7->ZC7_FILIAL := FwxFilial("SE1")
								ZC7->ZC7_PREFIX	:= M->E1_PREFIXO
								ZC7->ZC7_NUM   	:= M->E1_NUM
								ZC7->ZC7_PARCEL	:= M->E1_PARCELA
								ZC7->ZC7_TIPO      := M->E1_TIPO
								ZC7->ZC7_CLIFOR	:= M->E1_CLIENTE
								ZC7->ZC7_LOJA  	:= M->E1_LOJA
								ZC7->ZC7_VLRBLQ    := cE1VALOR
								ZC7->ZC7_VLRJUR    := cE1VLJURN
								ZC7->ZC7_TPBLQ 	:= cTpDivf
								ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Juros"
								ZC7->ZC7_RECPAG := "R"
								ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						ELSE
							RecLock("ZC7",.T.)
							ZC7->ZC7_FILIAL := FwxFilial("SE1")
							ZC7->ZC7_PREFIX	:= M->E1_PREFIXO
							ZC7->ZC7_NUM   	:= M->E1_NUM
							ZC7->ZC7_PARCEL	:= M->E1_PARCELA
							ZC7->ZC7_TIPO   := M->E1_TIPO
							ZC7->ZC7_CLIFOR	:= M->E1_CLIENTE
							ZC7->ZC7_LOJA  	:= M->E1_LOJA
							ZC7->ZC7_VLRBLQ := cE1VALOR
							ZC7->ZC7_VLRJUR := cE1VLJURN
							ZC7->ZC7_TPBLQ 	:= cTpDivf
							ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Juros"
							ZC7->ZC7_RECPAG := "R"
							ZC7->ZC7_USRALT := __cUserID
							MSUnlock()
						ENDIF
					ENDIF
				endif
			endif
			
			// Bloqueio por Descrescimo
			if !( cE1DECRESC == M->E1_DECRESC )
				
				if !empty(ZC3PERDEC)
					
					if ( cE1VALOR - M->E1_DECRESC ) < ( cE1VALOR - ( cE1VALOR * (ZC3PERDEC/100) ) )
						
						MsgBox('A Alteração realizada é maior do que a sua Alçada, Titulo encaminhado para Aprovação!' ,'Alçada de Alteração Financeira','Info')
						
						// Guarda o novo valor
						cE1DCRESCN  := M->E1_DECRESC
						cE1VALOR    := M->E1_VALOR
						
						// Volta o valor original
						M->E1_DECRESC := cE1DECRESC
						
						// Bloqueia o Titulo
						IF M->E1_XDIVERG <> 'S'
							M->E1_XDIVERG := 'S'
						ENDIF
						
						DbSelectArea("ZC7")
						DbSetOrder(2)
						IF DbSeek( FwxFilial("ZC7") + M->E1_CLIENTE + M->E1_LOJA + M->E1_PREFIXO + M->E1_NUM + M->E1_PARCELA + M->E1_TIPO)  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
							IF EMPTY(ZC7_USRAPR)
								RecLock("ZC7",.F.)
								ZC7->ZC7_DECRES := cE1DCRESCN
								ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ELSE
								RecLock("ZC7",.T.)
								ZC7->ZC7_FILIAL := FwxFilial("SE1")
								ZC7->ZC7_PREFIX := M->E1_PREFIXO
								ZC7->ZC7_NUM    := M->E1_NUM
								ZC7->ZC7_PARCEL := M->E1_PARCELA
								ZC7->ZC7_TIPO   := M->E1_TIPO
								ZC7->ZC7_CLIFOR := M->E1_CLIENTE
								ZC7->ZC7_LOJA   := M->E1_LOJA
								ZC7->ZC7_VLRBLQ := cE1VALOR
								ZC7->ZC7_DECRES := cE1DCRESCN
								ZC7->ZC7_TPBLQ  := cTpDivf
								ZC7->ZC7_DSCBLQ := sDscBlq += ", Descrescimo"
								ZC7->ZC7_RECPAG := "R"
								ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						ELSE
							RecLock("ZC7",.T.)
							ZC7->ZC7_FILIAL := FwxFilial("SE1")
							ZC7->ZC7_PREFIX	:= M->E1_PREFIXO
							ZC7->ZC7_NUM   	:= M->E1_NUM
							ZC7->ZC7_PARCEL	:= M->E1_PARCELA
							ZC7->ZC7_TIPO   := M->E1_TIPO
							ZC7->ZC7_CLIFOR	:= M->E1_CLIENTE
							ZC7->ZC7_LOJA  	:= M->E1_LOJA
							ZC7->ZC7_VLRBLQ := cE1VALOR
							ZC7->ZC7_DECRES := cE1DCRESCN
							ZC7->ZC7_TPBLQ 	:= cTpDivf
							ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Descrescimo"
							ZC7->ZC7_RECPAG := "R"
							ZC7->ZC7_USRALT := __cUserID
							MSUnlock()
						ENDIF
					endif
				else
					IF( cE1VALOR - M->E1_DECRESC ) < ( cE1VALOR - TOLPERDEC ) // Ricardo Lima - 22/03/18
						MsgBox('A Alteração realizada é maior do que a sua Alçada, Titulo encaminhado para Aprovação!' ,'Alçada de Alteração Financeira','Info')
						
						// Guarda o novo valor
						cE1DCRESCN  := M->E1_DECRESC
						cE1VALOR    := M->E1_VALOR
						
						// Volta o valor original
						M->E1_DECRESC := cE1DECRESC
						
						// Bloqueia o Titulo
						IF M->E1_XDIVERG <> 'S'
							M->E1_XDIVERG := 'S'
						ENDIF
						
						DbSelectArea("ZC7")
						DbSetOrder(2)
						IF DbSeek( FwxFilial("ZC7") + M->E1_CLIENTE + M->E1_LOJA + M->E1_PREFIXO + M->E1_NUM + M->E1_PARCELA + M->E1_TIPO)  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
							IF EMPTY(ZC7_USRAPR)
								RecLock("ZC7",.F.)
								ZC7->ZC7_DECRES := cE1DCRESCN
								ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ELSE
								RecLock("ZC7",.T.)
								ZC7->ZC7_FILIAL := FwxFilial("SE1")
								ZC7->ZC7_PREFIX := M->E1_PREFIXO
								ZC7->ZC7_NUM    := M->E1_NUM
								ZC7->ZC7_PARCEL := M->E1_PARCELA
								ZC7->ZC7_TIPO   := M->E1_TIPO
								ZC7->ZC7_CLIFOR := M->E1_CLIENTE
								ZC7->ZC7_LOJA   := M->E1_LOJA
								ZC7->ZC7_VLRBLQ := cE1VALOR
								ZC7->ZC7_DECRES := cE1DCRESCN
								ZC7->ZC7_TPBLQ  := cTpDivf
								ZC7->ZC7_DSCBLQ := sDscBlq += ", Descrescimo"
								ZC7->ZC7_RECPAG := "R"
								ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						ELSE
							RecLock("ZC7",.T.)
							ZC7->ZC7_FILIAL := FwxFilial("SE1")
							ZC7->ZC7_PREFIX	:= M->E1_PREFIXO
							ZC7->ZC7_NUM   	:= M->E1_NUM
							ZC7->ZC7_PARCEL	:= M->E1_PARCELA
							ZC7->ZC7_TIPO   := M->E1_TIPO
							ZC7->ZC7_CLIFOR	:= M->E1_CLIENTE
							ZC7->ZC7_LOJA  	:= M->E1_LOJA
							ZC7->ZC7_VLRBLQ := cE1VALOR
							ZC7->ZC7_DECRES := cE1DCRESCN
							ZC7->ZC7_TPBLQ 	:= cTpDivf
							ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Descrescimo"
							ZC7->ZC7_RECPAG := "R"
							ZC7->ZC7_USRALT := __cUserID
							MSUnlock()
						ENDIF
					ENDIF
				endif
			endif
			
			// Bloqueio por Acrescimo
			if !( cE1ACRESC == M->E1_ACRESC )
				
				if !empty(ZC3PERACR)
					
					if ( cE1VALOR + M->E1_ACRESC ) > ( cE1VALOR + ( cE1VALOR * (ZC3PERACR/100) ) )
						
						MsgBox('A Alteração realizada é maior do que a sua Alçada, Titulo encaminhado para Aprovação!' ,'Alçada de Alteração Financeira','Info')
						
						// Guarda o novo valor
						cE1ACRSCN  := M->E1_ACRESC
						cE1VALOR   := M->E1_VALOR
						
						// Volta o valor original
						M->E1_ACRESC := cE1ACRESC
						
						// Bloqueia o Titulo
						IF M->E1_XDIVERG <> 'S'
							M->E1_XDIVERG := 'S'
						ENDIF
						
						DbSelectArea("ZC7")
						DbSetOrder(2)
						IF DbSeek( FwxFilial("ZC7") + M->E1_CLIENTE + M->E1_LOJA + M->E1_PREFIXO + M->E1_NUM + M->E1_PARCELA + M->E1_TIPO)  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
							IF EMPTY(ZC7_USRAPR)
								RecLock("ZC7",.F.)
								ZC7->ZC7_ACRESC := cE1ACRSCN
								ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ELSE
								RecLock("ZC7",.T.)
								ZC7->ZC7_FILIAL := FwxFilial("SE1")
								ZC7->ZC7_PREFIX	:= M->E1_PREFIXO
								ZC7->ZC7_NUM   	:= M->E1_NUM
								ZC7->ZC7_PARCEL	:= M->E1_PARCELA
								ZC7->ZC7_TIPO      := M->E1_TIPO
								ZC7->ZC7_CLIFOR	:= M->E1_CLIENTE
								ZC7->ZC7_LOJA  	:= M->E1_LOJA
								ZC7->ZC7_VLRBLQ    := cE1VALOR
								ZC7->ZC7_ACRESC    := cE1ACRSCN
								ZC7->ZC7_TPBLQ 	:= cTpDivf
								ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Acrescimo"
								ZC7->ZC7_RECPAG := "R"
								ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						ELSE
							RecLock("ZC7",.T.)
							ZC7->ZC7_FILIAL := FwxFilial("SE1")
							ZC7->ZC7_PREFIX	:= M->E1_PREFIXO
							ZC7->ZC7_NUM   	:= M->E1_NUM
							ZC7->ZC7_PARCEL	:= M->E1_PARCELA
							ZC7->ZC7_TIPO   := M->E1_TIPO
							ZC7->ZC7_CLIFOR	:= M->E1_CLIENTE
							ZC7->ZC7_LOJA  	:= M->E1_LOJA
							ZC7->ZC7_VLRBLQ := cE1VALOR
							ZC7->ZC7_ACRESC := cE1ACRSCN
							ZC7->ZC7_TPBLQ 	:= cTpDivf
							ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Acrescimo"
							ZC7->ZC7_RECPAG := "R"
							ZC7->ZC7_USRALT := __cUserID
							MSUnlock()
						ENDIF
					endif
				else
					IF ( cE1VALOR + M->E1_ACRESC ) > ( cE1VALOR + TOLPERACR ) // Ricardo Lima - 22/03/18
						MsgBox('A Alteração realizada é maior do que a sua Alçada, Titulo encaminhado para Aprovação!' ,'Alçada de Alteração Financeira','Info')
						
						// Guarda o novo valor
						cE1ACRSCN  := M->E1_ACRESC
						cE1VALOR   := M->E1_VALOR
						
						// Volta o valor original
						M->E1_ACRESC := cE1ACRESC
						
						// Bloqueia o Titulo
						IF M->E1_XDIVERG <> 'S'
							M->E1_XDIVERG := 'S'
						ENDIF
						
						DbSelectArea("ZC7")
						DbSetOrder(2)
						IF DbSeek( FwxFilial("ZC7") + M->E1_CLIENTE + M->E1_LOJA + M->E1_PREFIXO + M->E1_NUM + M->E1_PARCELA + M->E1_TIPO)  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
							IF EMPTY(ZC7_USRAPR)
								RecLock("ZC7",.F.)
								ZC7->ZC7_ACRESC := cE1ACRSCN
								ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ELSE
								RecLock("ZC7",.T.)
								ZC7->ZC7_FILIAL := FwxFilial("SE1")
								ZC7->ZC7_PREFIX	:= M->E1_PREFIXO
								ZC7->ZC7_NUM   	:= M->E1_NUM
								ZC7->ZC7_PARCEL	:= M->E1_PARCELA
								ZC7->ZC7_TIPO      := M->E1_TIPO
								ZC7->ZC7_CLIFOR	:= M->E1_CLIENTE
								ZC7->ZC7_LOJA  	:= M->E1_LOJA
								ZC7->ZC7_VLRBLQ    := cE1VALOR
								ZC7->ZC7_ACRESC    := cE1ACRSCN
								ZC7->ZC7_TPBLQ 	:= cTpDivf
								ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Acrescimo"
								ZC7->ZC7_RECPAG := "R"
								ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						ELSE
							RecLock("ZC7",.T.)
							ZC7->ZC7_FILIAL := FwxFilial("SE1")
							ZC7->ZC7_PREFIX	:= M->E1_PREFIXO
							ZC7->ZC7_NUM   	:= M->E1_NUM
							ZC7->ZC7_PARCEL	:= M->E1_PARCELA
							ZC7->ZC7_TIPO   := M->E1_TIPO
							ZC7->ZC7_CLIFOR	:= M->E1_CLIENTE
							ZC7->ZC7_LOJA  	:= M->E1_LOJA
							ZC7->ZC7_VLRBLQ := cE1VALOR
							ZC7->ZC7_ACRESC := cE1ACRSCN
							ZC7->ZC7_TPBLQ 	:= cTpDivf
							ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Acrescimo"
							ZC7->ZC7_RECPAG := "R"
							ZC7->ZC7_USRALT := __cUserID
							MSUnlock()
						ENDIF
					ENDIF
				endif
			endif
			
			// Bloqueio por Desconto
			if !( cE1DESCFIN == M->E1_DESCFIN )
				
				if !empty(ZC3PERDES)
					
					if M->E1_DESCFIN > ZC3PERDES
						
						MsgBox('A Alteração realizada é maior do que a sua Alçada, Titulo encaminhado para Aprovação!' ,'Alçada de Alteração Financeira','Info')
						
						// Guarda o novo valor
						cE1DSCFINN  := M->E1_DESCFIN
						cE1VALOR    := M->E1_VALOR
						
						// Volta o valor original
						M->E1_DESCFIN := cE1DESCFIN
						
						// Bloqueia o Titulo
						IF M->E1_XDIVERG <> 'S'
							M->E1_XDIVERG := 'S'
						ENDIF
						
						DbSelectArea("ZC7")
						DbSetOrder(2)
						IF DbSeek( FwxFilial("ZC7") + M->E1_CLIENTE + M->E1_LOJA + M->E1_PREFIXO + M->E1_NUM + M->E1_PARCELA + M->E1_TIPO)  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
							IF EMPTY(ZC7_USRAPR)
								RecLock("ZC7",.F.)
								ZC7->ZC7_CNABDE := cE1DSCFINN
								ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ELSE
								RecLock("ZC7",.T.)
								ZC7->ZC7_FILIAL := FwxFilial("SE1")
								ZC7->ZC7_PREFIX	:= M->E1_PREFIXO
								ZC7->ZC7_NUM   	:= M->E1_NUM
								ZC7->ZC7_PARCEL	:= M->E1_PARCELA
								ZC7->ZC7_TIPO      := M->E1_TIPO
								ZC7->ZC7_CLIFOR	:= M->E1_CLIENTE
								ZC7->ZC7_LOJA  	:= M->E1_LOJA
								ZC7->ZC7_VLRBLQ    := cE1VALOR
								ZC7->ZC7_CNABDE    := cE1DSCFINN
								ZC7->ZC7_TPBLQ 	:= cTpDivf
								ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Desconto"
								ZC7->ZC7_RECPAG := "R"
								ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						ELSE
							RecLock("ZC7",.T.)
							ZC7->ZC7_FILIAL := FwxFilial("SE1")
							ZC7->ZC7_PREFIX	:= M->E1_PREFIXO
							ZC7->ZC7_NUM   	:= M->E1_NUM
							ZC7->ZC7_PARCEL	:= M->E1_PARCELA
							ZC7->ZC7_TIPO   := M->E1_TIPO
							ZC7->ZC7_CLIFOR	:= M->E1_CLIENTE
							ZC7->ZC7_LOJA  	:= M->E1_LOJA
							ZC7->ZC7_VLRBLQ := cE1VALOR
							ZC7->ZC7_CNABDE := cE1DSCFINN
							ZC7->ZC7_TPBLQ 	:= cTpDivf
							ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Desconto"
							ZC7->ZC7_RECPAG := "R"
							ZC7->ZC7_USRALT := __cUserID
							MSUnlock()
						ENDIF
					endif
				else
					IF M->E1_DESCFIN > TOLPERDES // Ricardo Lima - 22/03/18
						MsgBox('A Alteração realizada é maior do que a sua Alçada, Titulo encaminhado para Aprovação!' ,'Alçada de Alteração Financeira','Info')
						
						// Guarda o novo valor
						cE1DSCFINN  := M->E1_DESCFIN
						cE1VALOR    := M->E1_VALOR
						
						// Volta o valor original
						M->E1_DESCFIN := cE1DESCFIN
						
						// Bloqueia o Titulo
						IF M->E1_XDIVERG <> 'S'
							M->E1_XDIVERG := 'S'
						ENDIF
						
						DbSelectArea("ZC7")
						DbSetOrder(2)
						IF DbSeek( FwxFilial("ZC7") + M->E1_CLIENTE + M->E1_LOJA + M->E1_PREFIXO + M->E1_NUM + M->E1_PARCELA + M->E1_TIPO )  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
							IF EMPTY(ZC7_USRAPR)
								RecLock("ZC7",.F.)
								ZC7->ZC7_CNABDE := cE1DSCFINN
								ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ELSE
								RecLock("ZC7",.T.)
								ZC7->ZC7_FILIAL := FwxFilial("SE1")
								ZC7->ZC7_PREFIX	:= M->E1_PREFIXO
								ZC7->ZC7_NUM   	:= M->E1_NUM
								ZC7->ZC7_PARCEL	:= M->E1_PARCELA
								ZC7->ZC7_TIPO      := M->E1_TIPO
								ZC7->ZC7_CLIFOR	:= M->E1_CLIENTE
								ZC7->ZC7_LOJA  	:= M->E1_LOJA
								ZC7->ZC7_VLRBLQ    := cE1VALOR
								ZC7->ZC7_CNABDE    := cE1DSCFINN
								ZC7->ZC7_TPBLQ 	:= cTpDivf
								ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Desconto"
								ZC7->ZC7_RECPAG := "R"
								ZC7->ZC7_USRALT := __cUserID
								MSUnlock()
							ENDIF
						ELSE
							RecLock("ZC7",.T.)
							ZC7->ZC7_FILIAL := FwxFilial("SE1")
							ZC7->ZC7_PREFIX	:= M->E1_PREFIXO
							ZC7->ZC7_NUM   	:= M->E1_NUM
							ZC7->ZC7_PARCEL	:= M->E1_PARCELA
							ZC7->ZC7_TIPO   := M->E1_TIPO
							ZC7->ZC7_CLIFOR	:= M->E1_CLIENTE
							ZC7->ZC7_LOJA  	:= M->E1_LOJA
							ZC7->ZC7_VLRBLQ := cE1VALOR
							ZC7->ZC7_CNABDE := cE1DSCFINN
							ZC7->ZC7_TPBLQ 	:= cTpDivf
							ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Desconto"
							ZC7->ZC7_RECPAG := "R"
							ZC7->ZC7_USRALT := __cUserID
							MSUnlock()
						ENDIF
					ENDIF
				endif
			endif
			
			IF M->E1_XDIVERG = 'S'
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
				cMensagem := u_WGFA050FIN( FwxFilial("SE1") , SE1->E1_PREFIXO , SE1->E1_NUM , SE1->E1_PARCELA , SE1->E1_CLIENTE , SE1->E1_LOJA , SE1->E1_VALOR , sDscBlq , 'C' )
				If lEnvWFCA
					u_F050EnvWF( cAssunto , cMensagem , cmaildest , '' )
				EndIf
			ENDIF
		//endif
	EndIf

Return(lRet)
