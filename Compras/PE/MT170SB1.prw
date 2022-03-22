#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'

/*/{Protheus.doc} User Function MT170SB1
	E executado dentro do laco efetuado na tabela de produtos e utilizado para validar o produto, se ele será considerado para análise no relatório.Este Ponto de Entrada tambem e executados no programa MATA170 (Gera solicitações de compra baseado no ponto de pedido )Ponto de entrada executado na rotina Solicitação de compra.
    @author William
    @since 21/03/2018
	@version 01
	@history chamado 048038 - William Costa - 26/03/2019 - Adicionado Num da SC na na busca de saldos dos pedidos de compra
	@history chamado TI     - William Costa - 15/07/2020 - Alterado alias para criação da variavel do produto
	@history chamado TI     - Leonardo P. Monteiro - 08/03/2022 - Correção do msunlock para prevenir lock na tabela SB2.
/*/

Static lMensagem := .F.

USER FUNCTION MT170SB1( )

	LOCAL CALIAS        := ParamIXB[1]   //-- Alias atribuído à query.
	LOCAL lRet          := .T.
	Local cLocalde      := mv_par07
	Local cLocalAte     := mv_par08
	Local nSaldoPcAbert := 0
	Local cCodProd      := SB1->B1_COD
	
	IF cLocalde == cLocalAte //Locais iguais continua
	
		// *** INICIO CARREGA SALDO SOLICITACAO DE COMPRA *** //       
	    SqlSC1(FWFILIAL('SB2'),cCodProd,cLocalde)
		While TRD->(!EOF())
				           
			nSaldoPcAbert := nSaldoPcAbert + TRD->TOTAL_SOLICITACAO       
				            
			TRD->(dbSkip())
		ENDDO
		TRD->(dbCloseArea())
		// *** FINAL CARREGA SALDO SOLICITACAO DE COMPRA *** // 
	    
		// *** INICIO CARREGA SALDO PEDIDO DE COMPRA *** //
		SqlSC7(FWFILIAL('SB2'),cCodProd,cLocalde)
		While TRE->(!EOF())
				           
			nSaldoPcAbert := nSaldoPcAbert + TRE->TOTAL_PEDIDO    
				            
			TRE->(dbSkip())
		ENDDO
		TRE->(dbCloseArea())   
		// *** FINAL CARREGA SALDO PEDIDO DE COMPRA *** //
		
		// *** INICIO CARREGA SALDO SOLICITACAO DE COMPRA x PEDIDO DE COMPRA *** //
		SqlSC1xSC7(FWFILIAL('SB2'),cCodProd,cLocalde)
		While TRF->(!EOF())
				           
			nSaldoPcAbert := nSaldoPcAbert + TRF->TOTAL_PEDIDO    
				            
			TRF->(dbSkip())
		ENDDO
		TRF->(dbCloseArea())   
		// *** INICIO CARREGA SALDO SOLICITACAO DE COMPRA x PEDIDO DE COMPRA *** //
		
		// *** INICIO LEVA SALDO SB2 *** //
		IF nSaldoPcAbert > 0 .OR. nSaldoPcAbert == 0
		
			DbSelectArea("SB2") 
							
				SB2->(DbSetOrder(1))
			
				IF SB2->(DbSeek(FWFILIAL('SB2')+cCodProd+cLocalde,.T.))
				
					RecLock("SB2",.F.)
					
						SB2->B2_SALPEDI := nSaldoPcAbert
						
		            SB2->(MsUnLock())
		        ENDIF
		        
		    SB2->( DBCLOSEAREA() )
		   
	    ENDIF
	    // *** FINAL LEVA SALDO SB2 *** //
		
	ELSE //Locais diferentes trava	
	
		IF lMensagem == .F.
		
			MsgAlert("OLÁ " + Alltrim(cUserName) + ", NÃO é PERMITIDO GERAR PONTO DE PEDIDO PARA MAIS DE UM ARMAZÉM AO MESMO TEMPO, REVISE OS PARAMETROS LOCAL DE, LOCAL ATÉ", "MT170SB1 - VALIDA PRODUTO PARA PONTO DE PEDIDO")
		
			lMensagem := .T.
			
		ENDIF
	     
		lRet := .F.
	
	ENDIF 

Return(lRet)

Static Function SqlSC1(cFilSc1,cCod,cLocal)

	BeginSQL Alias "TRD"
			%NoPARSER%  
			
			SELECT C1_FILIAL,C1_PRODUTO,C1_LOCAL,SUM(C1_QUANT-C1_QUJE) AS TOTAL_SOLICITACAO
			  FROM SC1010 WITH(NOLOCK)
			 WHERE C1_FILIAL   = %EXP:cFilSc1%
			   AND C1_PRODUTO  = %EXP:cCod%
			   AND C1_LOCAL    = %EXP:cLocal%
			   AND C1_RESIDUO <> 'S'
			   AND C1_QUANT   <> C1_QUJE
			   AND C1_CC       = '8001'
			   AND D_E_L_E_T_ <> '*'
			
			  GROUP BY C1_FILIAL,C1_PRODUTO,C1_LOCAL
			
	EndSQl             
RETURN(NIL)

Static Function SqlSC7(cFilSc7,cCod,cLocal)

	BeginSQL Alias "TRE"
			%NoPARSER%  
			
			SELECT C7_FILIAL,C7_PRODUTO,C7_LOCAL,SUM(C7_QUANT-C7_QUJE) AS TOTAL_PEDIDO
			  FROM SC7010 WITH(NOLOCK)
			 WHERE C7_FILIAL   = %EXP:cFilSc7%
			   AND C7_PRODUTO  = %EXP:cCod%
			   AND C7_LOCAL    = %EXP:cLocal%
			   AND C7_QUANT   <> C7_QUJE
			   AND C7_RESIDUO <> 'S'
			   AND C7_NUMSC    = ''
			   AND C7_CC       = '8001'
			   AND D_E_L_E_T_ <> '*'
			
			  GROUP BY C7_FILIAL,C7_PRODUTO,C7_LOCAL
			
	EndSQl             
RETURN(NIL)

Static Function SqlSC1xSC7(cFilSc7,cCod,cLocal)

	BeginSQL Alias "TRF"
			%NoPARSER% 
			
			  SELECT C1_FILIAL,C1_PRODUTO,C1_LOCAL,SUM(C7_QUANT-C7_QUJE) AS TOTAL_PEDIDO
				FROM SC1010 WITH(NOLOCK)
				 INNER JOIN  SC7010 
				         ON C7_FILIAL   = C1_FILIAL
						AND C7_PRODUTO  = C1_PRODUTO
						AND C7_LOCAL    = C1_LOCAL
						AND C7_QUANT   <> C7_QUJE
						AND C7_NUMSC    = C1_NUM //048038 WILLIAM COSTA 26/03/2019 
						AND C7_ITEMSC   = C1_ITEM
				        AND C7_RESIDUO <> 'S'
						AND C7_CC       = C1_CC
						AND C7_QUANT   <> C7_QUJE
						AND SC7010.D_E_L_E_T_ <> '*'
				      WHERE C1_FILIAL   = %EXP:cFilSc7%
						AND C1_PRODUTO  = %EXP:cCod%
						AND C1_LOCAL    = %EXP:cLocal%
						AND C1_RESIDUO <> 'S'
						AND C1_CC       = '8001'
						AND SC1010.D_E_L_E_T_ <> '*'
							
					GROUP BY C1_FILIAL,C1_PRODUTO,C1_LOCAL 
			
	EndSQl             
RETURN(NIL)
