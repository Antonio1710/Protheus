#include 'rwmake.ch'      

/*/{Protheus.doc} User Function MT240TOK
	(long_description)
	@type  Function
	@author Wellington Santos
	@since 17/01/2007
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history Chamado 051482 - William Costa    - 03/09/2019 - OS 052798 || ALMOXARIFADO || EDUARDO || 8429 || BAIXAR ESTOQUE - Identificado que enquanto nao fecha o estoque fica produtos e enderecos com saldo zero na tabela SBF isso estava atrapalhando a query que mostrava saldo zerado no retorno.
	@history Chamado 054816 - FWNM             - 09/01/2020 - OS 056218 || ALMOXARIFADO || CRISTIANO || 3547 || BAIXA REQUISICAO-RNX
	@history Chamado 055729 - FERNANDO SIGOLI  - 10/02/2020 - OS 057128 || CONTROLADORIA || FRED_SANTOS || 8947 || ESTOQUE NEGATIVO  
	@history Ticket 69574   - Abel Babini      - 25/04/2022 - Projeto FAI
/*/

User Function MT240TOK

	Local _lTOk         := .T.   
	Local nEst	        := 0
	Local nSomaEndereco := 0
	Local cB1_Localiz   := ''
	Local cBE_Localiz   := ''
	Local cBZ_Localiz   := '' 
	Local cBF_Localiz   := '' 
	Local nSaldoSB2     := 0
	Local nSaldoSBF     := 0  
	Local cFilSF:= GetMv("MV_#SFFIL",,"02|0B|") 	//Ticket 69574   - Abel Babini          - 25/04/2022 - Projeto FAI
	Local cEmpSF:= GetMv("MV_#SFEMP",,"01|") 		//Ticket 69574   - Abel Babini          - 25/04/2022 - Projeto FAI

	If SubStr(M->D3_CC,1,1) = '9'
		If Empty(M->D3_PROJETO)
			MsgAlert('INFORME O PROJETO !!!')
			_lTOk := .F.
		EndIf
	EndIf                                                
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³INICIO - TRATAMENTO VALIDAÇÃO SALDO MOVIMENTAÇÃO INTERNA 10/12/2015 - KF³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//If cFilAnt $ '02|03' .and. alltrim(M->D3_LOCAL) $ '02|04' // Chamado n. 054816 || OS 056218 || ALMOXARIFADO || CRISTIANO || 3547 || BAIXA REQUISICAO-RNX - FWNM - 09/01/2020
	
	If Alltrim(M->D3_LOCAL) $ '02|04|09|29'  //Chamado n. 055729 || OS 057128 || CONTROLADORIA || FRED_SANTOS || 8947 || ESTOQUE NEGATIVO - Fernando Sigoli 10/02/2020  
			
		dbSelectArea("SB2")
		dbSeek(xFilial("SB2")+M->D3_COD+M->D3_LOCAL)
		//IF ALLTRIM(M->D3_TM) == '001'
		If Left(ALLTRIM(M->D3_TM),1) <= "4"
			nEst:=SaldoMov(Nil,Nil,Nil,.T.,Nil,Nil,Nil,dDatabase) + M->D3_QUANT
		ELSE
			nEst:=SaldoMov(Nil,Nil,Nil,.T.,Nil,Nil,Nil,dDatabase) - M->D3_QUANT
		ENDIF	
			
		If nEst< 0 
			MsgInfo("Operação não permitida! Produto ficara com estoque negativo!" + " ["+ alltrim(M->D3_COD)+"/"+ Alltrim(M->D3_LOCAL) + "]" ,"[MT240TOK-01] - Estoque Negativo")
		   _lTOk := .F.
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³FIM - TRATAMENTO VALIDAÇÃO SALDO MOVIMENTAÇÃO INTERNA 10/12/2015 - KF³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	// *** INICIO CHAMADO 036032  WILLIAM COSTA*** //
	IF Alltrim(cEmpAnt) $ cEmpSF .AND. ;
	   Alltrim(cFilAnt) $ cFilSF .AND. ;
	   (IsInCallStack('MATA185')   == .T.  .OR.  ;
	    IsInCallStack('ADEST006P') == .T.)
		
	    SqlBuscaProduto(M->D3_COD,M->D3_LOCAL)
	    
	    While TRD->(!EOF())
	                  
            cB1_Localiz := TRD->B1_LOCALIZ
            cBE_Localiz := TRD->BE_LOCALIZ
            cBZ_Localiz := TRD->BZ_LOCALIZ  
           
        	TRD->(dbSkip())
		ENDDO
		TRD->(dbCloseArea())
		
		IF ALLTRIM(cB1_Localiz)   == 'S' .AND. ;
		   ALLTRIM(cBE_Localiz)  <> ''  .AND. ;
		   ALLTRIM(M->D3_LOCALIZ) == '' 
		
			MsgAlert("Olá " + Alltrim(cusername) + ", Não é Possivel fazer a baixa, informe o endereco do produto:  " + M->D3_COD, "MT240TOK - Ponto de Entrada - 1")
		
			_lTOk := .F.
			
		ENDIF
		
		IF ALLTRIM(cB1_Localiz)  == 'S'  .AND. ;
		   (ALLTRIM(cBZ_Localiz) == ''    .OR. ;
		   ALLTRIM(cBZ_Localiz)  == 'N') 
		   
		    MsgAlert("Olá " + Alltrim(cusername) + ", Não é Possivel fazer a baixa, o produto:  " + M->D3_COD + "não esta marcado com endereço igual a sim na tabela SBZ", "MT240TOK - Ponto de Entrada - 2")
		
			_lTOk := .F.
			
		ENDIF
		
		IF ALLTRIM(cB1_Localiz)   == 'S' .AND. ;
		   ALLTRIM(cBE_Localiz)   <> ''  .AND. ;
		   ALLTRIM(M->D3_LOCALIZ) <> ''  .AND. ;
		   ALLTRIM(M->D3_LOCALIZ) <> ALLTRIM(cBE_Localiz)
		
			MsgAlert("Olá " + Alltrim(cusername) + ", Não é Possivel fazer a baixa, o endereco do produto:  " + M->D3_COD + "não corresponde com o cadastro de Endereços", "MT240TOK - Ponto de Entrada - 3")
		
			_lTOk := .F.
			
		ENDIF
		
		IF ALLTRIM(cB1_Localiz)   == 'S' .AND. ;
		   ALLTRIM(cBE_Localiz)   <> ''  .AND. ;
		   ALLTRIM(M->D3_LOCALIZ) <> ''  .AND. ;
		   ALLTRIM(M->D3_LOCALIZ) == ALLTRIM(cBE_Localiz)
		   
		   SqlSaldoProduto(M->D3_COD,M->D3_LOCAL)
	    
		    While TRE->(!EOF())
		                  
		    	cBF_Localiz   := TRE->BF_LOCALIZ
		    	nSaldoSB2     := TRE->B2_QATU
		    	nSaldoSBF     := TRE->BF_QUANT 
	           
	        	TRE->(dbSkip())
			ENDDO
			TRE->(dbCloseArea())
			
			IF nSaldoSB2 <> nSaldoSBF
		
				MsgAlert("Olá " + Alltrim(cusername) + ", Não é Possivel fazer a baixa, o Saldo do Produto:  " + M->D3_COD + "está diferente entre SB2 e SBF, SB2:" + CVALTOCHAR(nSaldoSB2) + " SBF:" + CVALTOCHAR(nSaldoSBF), "MT240TOK - Ponto de Entrada - 4")
		
				_lTOk := .F.
				
			ENDIF
			
			IF ALLTRIM(cBF_Localiz) <> ALLTRIM(cBE_Localiz)
			
				MsgAlert("Olá " + Alltrim(cusername) + ", Não é Possivel fazer a baixa, o endereco do produto:  " + M->D3_COD + "não corresponde com o Saldo de Localização SBF", "MT240TOK - Ponto de Entrada - 5")
			
				_lTOk := .F.
				
			ENDIF	
		ENDIF
	ENDIF
	// *** FINAL CHAMADO 036032  WILLIAM COSTA*** //

Return( _lTOk)

/*/{Protheus.doc} Static Function SqlBuscaProduto
	(long_description)
	@type  Static Function
	@author William Costa
	@since 03/09/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function SqlBuscaProduto(cCodProd,cLocal)

	LOCAL  cFil := xFilial("SD3")

	BeginSQL Alias "TRD"
			%NoPARSER%  
			   SELECT B1_LOCALIZ,BE_CODPRO,BE_LOCALIZ,BZ_LOCALIZ
			     FROM %Table:SB1% WITH (NOLOCK)
			LEFT JOIN %Table:SBE% WITH (NOLOCK)
			       ON BE_FILIAL               = %EXP:cFil%
			      AND BE_CODPRO               = B1_COD
			      AND BE_LOCAL                = %EXP:cLocal% 
			      AND %Table:SBE%.D_E_L_E_T_ <> '*'
			LEFT JOIN %Table:SBZ% WITH (NOLOCK)
				   ON BZ_FILIAL               = '02'
				  AND BZ_COD                  = B1_COD
				  AND %Table:SBZ%.D_E_L_E_T_ <> '*'
				  AND %Table:SBE%.D_E_L_E_T_ <> '*'
			    WHERE B1_COD                  = %EXP:cCodProd% 
			      AND %Table:SB1%.D_E_L_E_T_ <> '*'
	EndSQl             

RETURN(NIL)

/*/{Protheus.doc} Static Function SqlBuscaProduto
	(long_description)
	@type  Static Function
	@author William Costa
	@since 03/09/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function SqlSaldoProduto(cCodProd,cLocal)

	LOCAL  cFil := xFilial("SD3")

	BeginSQL Alias "TRE"
			%NoPARSER%  
			    SELECT B2_COD,BF_PRODUTO,BF_LOCALIZ,B2_QATU,BF_QUANT
				  FROM %Table:SB2%
			  LEFT JOIN %Table:SBF%
				     ON BF_FILIAL                = B2_FILIAL
				    AND BF_LOCAL                 = B2_LOCAL
				    AND BF_PRODUTO               = B2_COD
				    AND BF_QUANT                 > 0 // WILLIAM COSTA 03/09/2019 - CHAMADO 051482 || OS 052798 || ALMOXARIFADO || EDUARDO || 8429 || BAIXAR ESTOQUE      
				    AND %Table:SBF%.D_E_L_E_T_  <> '*'
				  WHERE B2_FILIAL               = %EXP:cFil%
				    AND B2_LOCAL                = %EXP:cLocal%
				    AND B2_COD                  = %EXP:cCodProd%
				    AND %Table:SB2%.D_E_L_E_T_ <> '*'
	EndSQl             

RETURN(NIL)
