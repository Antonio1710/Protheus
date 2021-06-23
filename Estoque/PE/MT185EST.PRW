#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} User Function MT185EST
    LOCALIZAÇÃO: Ponto de entrada localizado na função A185MovSD3, responsável por atualizar os dados do estorno das pré-requisições.
    EM QUE PONTO: Antes da execução do estorno, permitindo validar sua realização. 
    Utilizacao: Nao deixa estornar se for CP_XTIPO == 'T'
    @type  Function
    @author William Costa
    @since 17/08/2016
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history chamado 046889 - FWNM    - 12/03/2019 - Permitir estorno parcial
    @history chamado 055188 - FWNM    - 18/02/2020 - || OS 056599 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || NOVA OPERACAO VENDA
	@history Chamado 053926 - Everson - 12/08/2020 - Bloquear estorno de baixa de solicitação automática de óleo.
/*/
User Function MT185EST()

	Local lRet         := .T.
	Local cDoc         := ''
	Local cNumseq      := '' 
	Local aTransf      := {} 
	Local cCodigoO     := ''
	Local cCodigoD     := ''
	Local dEmissao     := NIL
	Local cNumLoteO    := ''
	Local clotectlO    := ''
	Local cDescriO     := ''
	Local cUnidadeO    := ''
	Local cArmazemO    := ''
	Local cLocalizO    := ''
	Local cNumLoteD    := ''
	Local cDescriD     := ''
	Local cUnidadeD    := ''
	Local cArmazemD    := ''
	Local cLocalizD    := ''
	Local cPotenciD    := ''
	Local nQuantD      := 0
	Local nQtsegumD    := 0
	Local cLoteCTLD    := '' 
	Local cPath        := ''
	Local cFileLog     := ''
	Local lTudoEstorno := .T.//.F.
	Local cDocEst      := ''
	Local nRecAnt      := SCP->(RECNO())
	Local nOrdem       := SCP->(IndexOrd())
	Local cNumReq      := ''
	Local aArea	       := GetArea()
	Local lMsgOk       := .f.
	
	//memowrite("\LOGRDM\"+ALLTRIM(PROCNAME())+".LOG",Dtoc(date()) + " - " + time() + " - " +alltrim(cusername))

	//Everson - 12/03/2020. Chamado 053926.
	DbSelectArea("SCP")
    If lRet .And. FieldPos("CP_XCOMBUS") > 0
        If ! Empty(Alltrim(SCP->CP_XCOMBUS))
            lRet := .F.
            Help(Nil, Nil, "Função MT185EST(MT185EST)", Nil, "Baixa de solicitação automática não pode ser estornada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

    EndIf
       
	//IF SCP->CP_XTIPO == 'T' //Transferencia
	If lRet .And. AllTrim(SCP->CP_XTIPO) == "T" .or. AllTrim(SCP->CP_XTIPO) == "M" // Chamado n. 055188 || OS 056599 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || NOVA OPERACAO VENDA - FWNM - 18/02/2020
		
		Begin Transaction
		
			DbSelectArea("SCQ") 
			SCQ->(DbSetOrder(1))
			IF SCQ->(DbSeek( xFilial("SCQ") + SCP->CP_NUM + SCP->CP_ITEM,.T.))
			    cNumseq := SCQ->CQ_NUMREQ                
			ENDIF
			
			cDoc    := SPACE(6)
			aTransf := {}

			Dbselectarea("SD3")
			SD3->(DbSetOrder(8)) // D3_FILIAL+D3_DOC+D3_NUMSEQ                                                                                                                                      

			//Localiza registro de transferencia do codigo origem
			If SD3->( dbSeek( xFilial("SD3") + PadR(SCP->CP_XDOC, TamSX3("D3_DOC")[1]) + SCQ->CQ_NUMREQ ) )
			
				cCodigoO := " "
				cCodigoD := " "
			
				Do While SD3->( !EOF() ) .and. SD3->D3_FILIAL == FWxFilial("SD3") .and. AllTrim(SD3->D3_DOC) == AllTrim(SCP->CP_XDOC) .and. SD3->D3_NUMSEQ == SCQ->CQ_NUMREQ
				
						IF EMPTY(SD3->D3_ESTORNO) .AND. SD3->D3_CF $"RE4/DE4"
						
							IF EMPTY(cDoc)
							
								cDoc     := SD3->D3_DOC
								cNumSeq  := SD3->D3_NUMSEQ
								dEmissao := SD3->D3_EMISSAO
								AADD(aTransf ,  {cDoc,SD3->D3_EMISSAO})
								
							ENDIF
							
							IF  SD3->D3_CF ="RE4"
							
								IF SD3->D3_NUMSEQ == cNumSeq
								
									cNumLoteO := SD3->D3_NUMLOTE
									clotectlO := SD3->D3_LOTECTL
									cCodigoO  := SD3->D3_COD
									cDescriO  := POSICIONE("SB1",1,xFilial("SB1")+SD3->D3_COD,"B1_DESC")
									cUnidadeO := SD3->D3_UM
									cArmazemO := SD3->D3_LOCAL
									cLocalizO := SD3->D3_LOCALIZ
									
								ENDIF
								
							ELSEIF SD3->D3_CF ="DE4"
							
								IF SD3->D3_NUMSEQ == cNumSeq
								
									cNumLoteD := SD3->D3_NUMLOTE
									clotectlD := SD3->D3_LOTECTL
									cCodigoD  := SD3->D3_COD
									cDescriD  := POSICIONE("SB1",1,xFilial("SB1")+SD3->D3_COD,"B1_DESC")
									cUnidadeD := SD3->D3_UM
									cArmazemD := SD3->D3_LOCAL
									cLocalizD := SD3->D3_LOCALIZ
									cPotenciD := SD3->D3_POTENCI //potencia do lote
									nQuantD   := SD3->D3_QUANT
									nQtsegumD := SD3->D3_QTSEGUM //Qtde2.Un.Medida
									cLoteCTLD := SD3->D3_LOTECTL //lote
									
								ENDIF
								
							ENDIF
							
							IF !EMPTY(cCodigoO) .and. !EMPTY(cCodigoD)
							
								AADD(aTransf ,{    ;
												"S",; //Estorno?
												cCodigoO,;
												cDescriO ,;
												cUnidadeO,;
												cArmazemO,;
												cLocalizO,;
												cCodigoD,;
												cDescriD ,;
												cUnidadeD,;
												cArmazemD,;
												cLocalizD,;
												" ",; //d3_numseri
												clotectlO,; //lote
												cNumLoteO,; //sublote
												dEmissao,;
												cPotenciD,; //potencia do lote
												nQuantD,;
												nQtsegumD,; //Qtde2.Un.Medida
												cNumSeq,;
												cLoteCtlD }) //lote
								
								//Efetua estorno da transferencia
								lMSHelpAuto := .T.
								lMSErroAuto := .F.
								MSExecAuto({|x,y| MATA261(x,y)},aTransf,6)
								
								IF lMsErroAuto
									cFileLog := ""
									cPath := ""
									
									AutoGrLog("INICIANDO O LOG")
									AutoGrLog("---------------")
									AutoGrLog("DATABASE...........: "+Dtoc(dDataBase))
									AutoGrLog("DATA...............: "+Dtoc(MsDate()))
									AutoGrLog("HORA...............: "+Time())
									AutoGrLog("PRODUTO............: "+SD1->D1_COD)
									AutoGrLog("ENVIRONMENT........: "+GetEnvServer())
									AutoGrLog("PATCH..............: "+GetSrvProfString("Startpath",""))
									AutoGrLog("ROOT...............: "+GetSrvProfString("SourcePath",""))
									AutoGrLog("VERSÃO.............: "+GetVersao())
									AutoGrLog("MÓDULO.............: "+"SIGA"+cModulo)
									AutoGrLog("EMPRESA / FILIAL...: "+SM0->M0_CODIGO+"/"+SM0->M0_CODFIL)
									AutoGrLog("NOME EMPRESA.......: "+Capital(Trim(SM0->M0_NOME)))
									AutoGrLog("NOME FILIAL........: "+Capital(Trim(SM0->M0_FILIAL)))
									AutoGrLog("USUÁRIO............: "+SubStr(cUsuario,7,15))
									
									cFileLog := NomeAutoLog()
									
									IF cFileLog <> ""
									
										MostraErro(cPath,cFileLog)
										
									ENDIF
								
								Else
								
									// Chamado n. 046889 - 12/03/2019 - FWNM - Permitir estorno parcial	
									lMsgOk       := .t.
									
									// Ajusta SB2 
									SB2->( DbSetOrder(1) )
									If SB2->( dbSeek( xFilial("SB2") + SCP->CP_PRODUTO + SCP->CP_LOCAL,.T.) )
										RecLock("SB2", .F.)
											SB2->B2_QEMPSA := SB2->B2_QEMPSA + SCP->CP_QUJE
										SB2->( MsUnLock() )
									EndIf

									// Modifica legenda
									RecLock("SCP",.F.)
										SCP->CP_QUJE   := 0
										SCP->CP_STATUS := ""                                        
									SCP->( msUnLock() )
									
								EndIf
								
								aTransf   := {}
								cDoc:=space(6)
								
							ENDIF
					
						ENDIF
					
					SD3->(DBSKIP())
					
				ENDDO
				
			ENDIF
		
		END Transaction

		If lMsgOk
			MsgInfo("Olá " + Alltrim(cusername) + ", Estorno de Transferência para o Documento: " + SCP->CP_XDOC + " Realizado Com Sucesso ", "MT185EST - Ponto de Entrada Estorno")
				
			u_GrLogZBE (Date(),TIME(),cUserName,"Solicitação de Armazem: "+SCP->CP_XDOC + " DOCUMENTO DE: "+SCP->CP_XDOC+" PARA: "+SCP->CP_XDOC,"Estoque","MT185EST",;
			        							" Estorno Transferencia OK",;
			        							ComputerName(),LogUserName())
		EndIf
		
	ENDIF

	//
	RestArea(aArea)
	
Return(lRet)