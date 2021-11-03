#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function DPCTB102GR
	Ponto de entrada utilizado após a gravação dos dados da tabela de lançamento. 
	@type  Function
	@author FWNM
	@since 24/02/2010
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@ticket ti - Fernando Macieira - 04/10/2021 - Cloud Desativação SIG ANTIGO
/*/
User Function DPCTB102GR()

	Local cSql      := ""
	Local nOpc      := ParamIXB[1]
	Local dDataLanc := ParamIXB[2]
	Local cLote     := ParamIXB[3]
	Local cSubLote  := ParamIXB[4]
	Local cDoc      := ParamIXB[5]
	Local lServPR   := GetMv("MV_#SERVPR",,.f.)
	Local cProces   := Posicione("SX5",1,Space(2)+"_X","X5_CHAVE")
	Local nStatus   := 0 

	Private aArea   := GetArea()
	
	If lServPR
	
		If nOpc == 4 .or. nOpc == 5 // Alteracao ou Exclusao
		
			If cProces == "PROCES"
			
				Aviso(	"Lançamento Contábil",;
				"Lote Contabil nao podera ser alterado. Processamento SIG em andamento. Contate a Contabilidade.",;
				{"&Ok"},,;
				"Alteração Inválida" )
				
			Else
			
				// *** INICIO CHAMADO WILLIAM 11/10/2018 041210 || CONTROLADORIA || TAMIRES_OLIVEIRA || 8464 || DOC SAIDA C CONTABIL *** //
				
				IF nOpc         == 4     .AND. ;
				   (CT2->CT2_LP == '610' .OR. ;
				   CT2->CT2_LP  == '620' .OR. ;
				   CT2->CT2_LP  == '650') 
				    
				
					SqlCT2(FWFilial("CT2"),DTOS(dDataLanc),cLote,cSubLote,cDoc) 
					TRB->(DbGoTop())
					While !TRB->(Eof())
					
						IF TRB->CT2_LP = '650'
						
							//Verifica se existe
							IF AT('650-001',TRB->CT2_ORIGEM) > 0 .OR. ;  
							   AT('650-109',TRB->CT2_ORIGEM) > 0 .OR. ;
							   AT('650-116',TRB->CT2_ORIGEM) > 0 
							
								SqlNotaEntrada(TRB->CT2_FILKEY,TRB->CT2_NUMDOC,TRB->CT2_PREFIX,TRB->CT2_CLIFOR,TRB->CT2_LOJACF,TRB->CT2_VALOR)
								TRC->(DbGoTop())
								While !TRC->(Eof())
								
									//FAZ ALTERACAO SE AS CONTAS FOREM DIFERENTES
								 	IF !EMPTY(TRB->CT2_DEBITO)          .AND. ;
								 	   TRC->D1_CONTA <> TRB->CT2_DEBITO
								 	
								 		DBSELECTAREA("SD1")
										DBSETORDER(1)
										IF DBSEEK(TRC->D1_FILIAL + TRC->D1_DOC + TRC->D1_SERIE + TRC->D1_FORNECE + TRC->D1_LOJA + TRC->D1_COD + TRC->D1_ITEM, .T.)
										
											RecLock("SD1",.F.)
											
												SD1->D1_CONTA	:= TRB->CT2_DEBITO
											
											MsUnLock()
										
										ENDIF
								 	
								 	ENDIF
									
									SqlLivroEntrada(TRC->D1_FILIAL,TRC->D1_SERIE,TRC->D1_DOC,TRC->D1_FORNECE,TRC->D1_LOJA,TRC->D1_ITEM,TRC->D1_COD)
									TRD->(DbGoTop())
									While !TRD->(Eof())
									
										//FAZ ALTERACAO SE AS CONTAS FOREM DIFERENTES
									 	IF !EMPTY(TRB->CT2_DEBITO)          .AND. ;
									 	   TRD->FT_CONTA <> TRB->CT2_DEBITO
									 	
									 		DBSELECTAREA("SFT")
											DBSETORDER(1)
											IF DBSEEK(TRD->FT_FILIAL + TRD->FT_TIPOMOV + TRD->FT_SERIE + TRD->FT_NFISCAL + TRD->FT_CLIEFOR + TRD->FT_LOJA + TRD->FT_ITEM + TRD->FT_PRODUTO, .T.)
																													           
												RecLock("SFT",.F.)
												
													SFT->FT_CONTA	:= TRB->CT2_DEBITO
												
												MsUnLock()
											
											ENDIF
									 	
									 	ENDIF
																		
										TRD->(DBSKIP())    
										
									ENDDO
									TRD->(DbCloseArea())
								                                                          
									TRC->(DBSKIP())    
									
								ENDDO
								TRC->(DbCloseArea())
						
							ENDIF
							
						ELSEIF TRB->CT2_LP  = '610' .OR. ;
						        TRB->CT2_LP = '620'
						        
							//Verifica se existe
							IF AT('610-006',TRB->CT2_ORIGEM) > 0 .OR. ; 
							   AT('610-041',TRB->CT2_ORIGEM) > 0 .OR. ;
							   AT('610-050',TRB->CT2_ORIGEM) > 0 .OR. ;
							   AT('620-040',TRB->CT2_ORIGEM) > 0 
							
								SqlNotaSaida(TRB->CT2_FILKEY,TRB->CT2_NUMDOC,TRB->CT2_PREFIX,TRB->CT2_CLIFOR,TRB->CT2_LOJACF,TRB->CT2_VALOR)
								TRE->(DbGoTop())
								While !TRE->(Eof())
								
									//FAZ ALTERACAO SE AS CONTAS FOREM DIFERENTES
								 	IF !EMPTY(TRB->CT2_CREDIT)          .AND. ;
								 	   TRE->D2_CONTA <> TRB->CT2_CREDIT
								 	    
								 		DBSELECTAREA("SD2")
										DBSETORDER(3)
										IF DBSEEK(TRE->D2_FILIAL + TRE->D2_DOC + TRE->D2_SERIE + TRE->D2_CLIENTE + TRE->D2_LOJA + TRE->D2_COD + TRE->D2_ITEM, .T.)
										    
										    RecLock("SD2",.F.)
											
												SD2->D2_CONTA	:= TRB->CT2_CREDIT
											
											MsUnLock()
											
										ENDIF
								 	    
								 	ENDIF
									
									SqlLivroSaida(TRE->D2_FILIAL,TRE->D2_SERIE,TRE->D2_DOC,TRE->D2_CLIENTE,TRE->D2_LOJA,TRE->D2_ITEM,TRE->D2_COD)
									TRF->(DbGoTop())
									While !TRF->(Eof())
									
										//FAZ ALTERACAO SE AS CONTAS FOREM DIFERENTES
									 	IF !EMPTY(TRB->CT2_CREDIT)          .AND. ;
									 	   TRF->FT_CONTA <> TRB->CT2_CREDIT
									 	    
									 		DBSELECTAREA("SFT")
											DBSETORDER(1)
											IF DBSEEK(TRF->FT_FILIAL + TRF->FT_TIPOMOV + TRF->FT_SERIE + TRF->FT_NFISCAL + TRF->FT_CLIEFOR + TRF->FT_LOJA + TRF->FT_ITEM + TRF->FT_PRODUTO, .T.)
											
												RecLock("SFT",.F.)
												
													SFT->FT_CONTA	:= TRB->CT2_CREDIT
												
												MsUnLock()
											   
											ENDIF
									 	    
									 	ENDIF
																		
										TRF->(DBSKIP())    
										
									ENDDO
									TRF->(DbCloseArea())
								                                                          
									TRE->(DBSKIP())    
									
								ENDDO
								TRE->(DbCloseArea())
						
							ENDIF
							
						ENDIF
						TRB->(DBSKIP())    
						
					ENDDO
					TRB->(DbCloseArea())
					
				ENDIF
				
				// *** FINAL CHAMADO WILLIAM 11/10/2018 041210 || CONTROLADORIA || TAMIRES_OLIVEIRA || 8464 || DOC SAIDA C CONTABIL *** //
			
				//cSql := " UPDATE " +RetSqlName("CT2")+ " SET CT2_MSEXP=' ' " // Chamado n. 044316 - FWNM em 11/12/2018 (Objetivo: Execução dos SIG VELHO E NOVO juntos!)
				cSql := " UPDATE " +RetSqlName("CT2")+ " SET CT2_MSEXP=' ', CT2_DATATX=' ' " 
				cSql += " WHERE CT2_FILIAL = '"+xFilial("CT2")+"' "
				cSql += "   AND CT2_DATA   = '"+DtoS(dDataLanc)+"' "
				cSql += "   AND CT2_LOTE   = '"+cLote+"' "
				cSql += "   AND CT2_SBLOTE = '"+cSubLote+"' "
				cSql += "   AND CT2_DOC    = '"+cDoc+"' "
				// NAO INSERIR O D_E_L_E_T_ (os registros deletados também precisam ser desflegados)!!!!
								
				nStatus := tcSqlExec(cSql)
			
				If nStatus < 0
					msgAlert("Limpeza dos campos CT2_MSEXP/CT2_DATATX não foram realizados! Envie o erro que será mostrado na próxima tela ao TI... ")
					MessageBox(tcSqlError(),"",16)
				EndIf
				
			EndIf

		EndIf

	EndIf

	/*
	// Chamado n. 048269 || OS 049552 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || EXCLUIR LANC REPLICA - FWNM - 03/04/2019
	aAreaCT2 := CT2->( GetArea() )
		
	Set(_SET_DELETED, .F.)
	
	If IsInCallStack("Ct102EstLt") // Exclusao em lote - PARAMIXB esta passando o registro posicionado do browse - erro de lib

		Do While .T.

			Pergunte("CTB102",.F.)
			
			If Select("Work") > 0
				Work->( dbCloseArea() )
			EndIf
			
			cQuery := " SELECT DISTINCT CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC " 
			cQuery += " FROM " + RetSqlName("CT2")
			cQuery += " WHERE CT2_FILIAL = '"+FWxFilial("CT2")+"' "
			cQuery += " AND CT2_DATA BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "
			cQuery += " AND CT2_LOTE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
			cQuery += " AND CT2_SBLOTE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
			cQuery += " AND CT2_DOC BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
			
			tcQuery cQuery new alias "Work"
			
			aTamSX3 := TamSX3("CT2_DATA")
			tcSetField("Work","CT2_DATA", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			Work->( dbGoTop() )
			Do While Work->( !EOF() )

				// Limpos flags SIG
				CT2->( dbSetOrder(1) ) // CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC                                                     
				If CT2->( dbSeek( FWxFilial("CT2")+DtoS(Work->CT2_DATA)+Work->CT2_LOTE+Work->CT2_SBLOTE+Work->CT2_DOC ) )
					Do While CT2->( !EOF() ) .and. CT2->CT2_FILIAL == FWxFilial("CT2") .and. DtoS(CT2->CT2_DATA) == DtoS(Work->CT2_DATA) .and. CT2->CT2_LOTE == Work->CT2_LOTE .and. CT2->CT2_SBLOTE == Work->CT2_SBLOTE .and. CT2->CT2_DOC == Work->CT2_DOC
						RecLock("CT2", .f.)
							CT2->CT2_MSEXP  := ""
							CT2->CT2_DATATX := CtoD("")
						CT2->( msUnLock() )
						
						CT2->( dbSkip() )
					EndDo
				EndIf
			
				Work->( dbSkip() )
			
			EndDo

			If Select("Work") > 0
				Work->( dbCloseArea() )
			EndIf


			// Comando de Redundancia
			cSql := " UPDATE " +RetSqlName("CT2")+ " SET CT2_MSEXP='', CT2_DATATX='' " 
			cSql += " WHERE CT2_FILIAL = '"+FWxFilial("CT2")+"' "
			cSql += " AND CT2_DATA BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "
			cSql += " AND CT2_LOTE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
			cSql += " AND CT2_SBLOTE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
			cSql += " AND CT2_DOC BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
			// NAO INSERIR O D_E_L_E_T_ (os registros deletados também precisam ser desflegados)!!!!
				
			nStatus := tcSqlExec(cSql)
					
			If nStatus < 0
				msgAlert("Limpeza dos campos CT2_MSEXP/CT2_DATATX não foram realizados! Envie o erro que será mostrado na próxima tela ao TI... ")
				MessageBox(tcSqlError(),"",16)
			Else
				Exit
			EndIf
			
		EndDo
	
	Else
	
		Do While .T.
			
			// Limpos flags SIG
			CT2->( dbSetOrder(1) ) // CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC                                                     
			If CT2->( dbSeek( FWxFilial("CT2")+DtoS(dDataLanc)+cLote+cSubLote+cDoc ) )
				Do While CT2->( !EOF() ) .and. CT2->CT2_FILIAL == FWxFilial("CT2") .and. DtoS(CT2->CT2_DATA) == DtoS(dDataLanc) .and. CT2->CT2_LOTE == cLote .and. CT2->CT2_SBLOTE == cSubLote .and. CT2->CT2_DOC == cDoc
					RecLock("CT2", .f.)
						CT2->CT2_MSEXP  := ""
						CT2->CT2_DATATX := CtoD("")
					CT2->( msUnLock() )
					
					CT2->( dbSkip() )
				EndDo
			EndIf
			
			// Comando de Redundancia
			cSql := " UPDATE " +RetSqlName("CT2")+ " SET CT2_MSEXP='', CT2_DATATX='' " 
			cSql += " WHERE CT2_FILIAL = '"+xFilial("CT2")+"' "
			cSql += "   AND CT2_DATA   = '"+DtoS(dDataLanc)+"' "
			cSql += "   AND CT2_LOTE   = '"+cLote+"' "
			cSql += "   AND CT2_SBLOTE = '"+cSubLote+"' "
			cSql += "   AND CT2_DOC    = '"+cDoc+"' "
			// NAO INSERIR O D_E_L_E_T_ (os registros deletados também precisam ser desflegados)!!!!
				
			nStatus := tcSqlExec(cSql)
					
			If nStatus < 0
				msgAlert("Limpeza dos campos CT2_MSEXP/CT2_DATATX não foram realizados! Envie o erro que será mostrado na próxima tela ao TI... ")
				MessageBox(tcSqlError(),"",16)
			Else
				Exit
			EndIf
	
		EndDo
		
	EndIf

	Set(_SET_DELETED, .T.)
	
	RestArea( aAreaCT2 )
	//
	*/
	
	RestArea(aArea)

Return(NIL)

Static Function SqlCT2(cFilialAtual,cDataLanc,cLote,cSubLote,cDoc)  

	BeginSQL Alias "TRB"
		     %NoPARSER%
		        SELECT CT2_LP,
				       CT2_ORIGEM,
					   CT2_FILKEY, 
					   CT2_NUMDOC,
					   CT2_PREFIX,
					   CT2_CLIFOR,
					   CT2_LOJACF,
					   CT2_VALOR,
					   CT2_DEBITO,
					   CT2_CREDIT
				  FROM %TABLE:CT2% CT2 WITH (NOLOCK) 
				  WHERE CT2_FILIAL  = %EXP:cFilialAtual%
				    AND CT2_DATA    = %EXP:cDataLanc%
					AND CT2_LOTE    = %EXP:cLote%
					AND CT2_SBLOTE  = %EXP:cSubLote%
					AND CT2_DOC     = %EXP:cDoc%
					AND D_E_L_E_T_ <> '*'
		     		     
	EndSQl

Return (NIL)

Static Function SqlNotaEntrada(cFilialAtual,cDoc,cSerie,cFornec,cLoja,nValor)  

	BeginSQL Alias "TRC"
		     %NoPARSER%
		     SELECT D1_FILIAL,
                    D1_DOC,
		            D1_SERIE, 
		            D1_FORNECE,
		            D1_LOJA,
		            D1_ITEM,
		            D1_COD,
		            D1_CONTA
		       FROM %TABLE:SD1% SD1 WITH (NOLOCK) 
			  WHERE D1_FILIAL    = %EXP:cFilialAtual%
			    AND D1_DOC       = %EXP:cDoc%
			    AND D1_SERIE     = %EXP:cSerie%
				AND D1_FORNECE   = %EXP:cFornec%
				AND D1_LOJA      = %EXP:cLoja%
				AND D1_CUSTO     = %EXP:nValor%
				AND (D1_CF       = '1551'
				 OR D1_CF        = '2551'
				 OR D1_CF        = '3551')
			    AND D_E_L_E_T_  <> '*' 
		     		     
	EndSQl

Return (NIL)

Static Function SqlLivroEntrada(cFilialAtual,cSerie,cDoc,cFornec,cLoja,cItem,cCod)  

	BeginSQL Alias "TRD"
		     %NoPARSER%
		    SELECT FT_FILIAL,
		           FT_TIPOMOV, 
		           FT_SERIE,
		           FT_NFISCAL,
		           FT_CLIEFOR,
		           FT_LOJA, 
		           FT_ITEM, 
		           FT_PRODUTO,
		           FT_CONTA 
			  FROM %TABLE:SFT% SFT WITH (NOLOCK) 
			 WHERE FT_FILIAL   = %EXP:cFilialAtual%
			   AND FT_TIPOMOV  = 'E'
			   AND FT_SERIE    = %EXP:cSerie%
			   AND FT_NFISCAL  = %EXP:cDoc%
			   AND FT_CLIEFOR  = %EXP:cFornec%
			   AND FT_LOJA     = %EXP:cLoja%
			   AND FT_ITEM     = %EXP:cItem%
			   AND FT_PRODUTO  = %EXP:cCod%
			   AND D_E_L_E_T_ <> '*'
   
   EndSQl

Return (NIL)

Static Function SqlNotaSaida(cFilialAtual,cDoc,cSerie,cCliente,cLoja,nValor)  

	BeginSQL Alias "TRE"
		     %NoPARSER%
		     SELECT D2_FILIAL,
                    D2_DOC,
		            D2_SERIE, 
		            D2_CLIENTE,
		            D2_LOJA,
		            D2_ITEM,
		            D2_COD,
		            D2_CONTA
		       FROM %TABLE:SD2% SD2 WITH (NOLOCK) 
		       INNER JOIN %TABLE:SF4% SF4 WITH (NOLOCK) 
			        ON F4_CODIGO = D2_TES
			       AND SF4.D_E_L_E_T_ <> '*'
			  WHERE D2_FILIAL        = %EXP:cFilialAtual%
			    AND D2_DOC           = %EXP:cDoc%
			    AND D2_SERIE         = %EXP:cSerie%
				AND D2_CLIENTE       = %EXP:cCliente%
				AND D2_LOJA          = %EXP:cLoja%
				AND CASE WHEN F4_CIAP = 'S' THEN ((D2_TOTAL + D2_VALIPI + D2_ICMSCOM) - D2_VALICM - D2_ICMSCOM) ELSE D2_TOTAL + D2_VALIPI + D2_ICMSCOM END  = %EXP:nValor%
				AND (D2_CF           = '5553'
				 OR D2_CF            = '6553'
				 OR D2_CF            = '7553')
			    AND SD2.D_E_L_E_T_  <> '*' 
		     		     
	EndSQl

Return (NIL)

Static Function SqlLivroSaida(cFilialAtual,cSerie,cDoc,cCliente,cLoja,cItem,cCod)  

	BeginSQL Alias "TRF"
		     %NoPARSER%
		    SELECT FT_FILIAL,
		           FT_TIPOMOV, 
		           FT_SERIE,
		           FT_NFISCAL,
		           FT_CLIEFOR,
		           FT_LOJA, 
		           FT_ITEM, 
		           FT_PRODUTO,
		           FT_CONTA 
			  FROM %TABLE:SFT% SFT WITH (NOLOCK) 
			 WHERE FT_FILIAL   = %EXP:cFilialAtual%
			   AND FT_TIPOMOV  = 'S'
			   AND FT_SERIE    = %EXP:cSerie%
			   AND FT_NFISCAL  = %EXP:cDoc%
			   AND FT_CLIEFOR  = %EXP:cCliente%
			   AND FT_LOJA     = %EXP:cLoja%
			   AND FT_ITEM     = %EXP:cItem%
			   AND FT_PRODUTO  = %EXP:cCod%
			   AND D_E_L_E_T_ <> '*'
   
   EndSQl

Return (NIL)
