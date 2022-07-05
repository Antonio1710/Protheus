#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "RWMAKE.CH"   

/*/{Protheus.doc} User Function MT260TOK
	Ponto de Entrada localizado na confirmação da Dialog na função A260TudoOK.EM QUE PONTO : executada ao pressionar o botão da EnchoiceBar.FINALIDADE : Validar as informações inseridas pelo Usuário.
	@ PE da rotina MATA260 - Transferência Simples
	@type  Function
	@author William Costa
	@since 03/04/2019
	@version version
	@history Chamado 053805 - WILLIAM COSTA         - 03/12/2019 - TRATATIVA PARA O ARMAZEM 03  
	@history ticket 75276   - Antonio Domingos - 30/06/2022 - Transferencia - Desvincular produto do endereço	
/*/

USER FUNCTION MT260TOK()

	Local aArea      := GetArea() 
	Local lRetProOri := .T.
	Local lRetProDes := .T.
	Local lRetSalOri := .T.
	Local lRetSalDes := .T.
	Local lRet       := .T.
	Private cErro    := ''
	
	IF IsInCallStack('MATA185')  == .T.
	
		RETURN(lREt)
	
	ENDIF
	
	// so entra no ponto de entrada se comecar com 3 4 5 e tiver endereco, caso contrario passa direto
	
	IF SUBSTR(cCodOrig,1,1) $ '3/4/5' .AND. ;
	   SUBSTR(cCodDest,1,1) $ '3/4/5'
	
		IF ALLTRIM(cLocLzOrig) <> '' .AND. ;
		   ALLTRIM(cLoclzDest) <> ''
		   
		   cErro:= "Origem: " + CHR(13) + CHR(10) + CHR(13) + CHR(10) 
		   
		   lRetProOri := ValidCad(cCodOrig,cLocOrig)
		   lRetSalOri := VERIFSALDO(cCodOrig,cLocOrig)
		   
		   cErro+= CHR(13) + CHR(10) + CHR(13) + CHR(10) + "Destino: " + CHR(13) + CHR(10) + CHR(13) + CHR(10)
		   
		   lRetProDes := ValidCad(cCodDest,cLocDest)
		   lRetSalDes := VERIFSALDO(cCodDest,cLocDest)
		   
		ENDIF
		
		IF lRetProOri == .F. .OR. ;
		   lRetProDes == .F. .OR. ;
		   lRetSalOri == .F. .OR. ;
		   lRetSalDes == .F. 
		
			lRet := .F.
			U_ExTelaMen("MT260TOK - Tela de Transferência!!!", cErro, "Arial", 16, , .F., .T.)
			
		ENDIF
	ENDIF
	
	RestArea(aArea)
	
RETURN(lRet)

Static Function ValidCad(cCod,cLoc,cLocaliz)

	Local lRet     := .T.
	Local nContEnd := 0
	
	// *** INICIO VERIFICACAO CADASTRO DE PRODUTO *** //
	SqlProduto(cCod)
	While TRB->(!EOF())
	
	    // *** INICIO AJUSTA CODIGO BAR DO PRODUTO  *** //
		IF ALLTRIM(TRB->B1_CODBAR) <> ALLTRIM(cCod)
		
			DBSELECTAREA("SB1")
			DBSETORDER(1)
			IF DBSEEK(FWXFILIAL("SB1") +cCod, .T.)
			
				RECLOCK("SB1",.F.)
				
					SB1->B1_CODBAR := TRB->B1_COD
				
				MSUNLOCK()
			
	        ENDIF          
        ENDIF    
        // *** FINAL AJUSTA CODIGO BAR DO PRODUTO *** //
        
        // *** INICIO AJUSTA CAMPO CONTROLE DE LOCALIZACAO PRODUTO *** //
        IF ALLTRIM(TRB->B1_LOCALIZ) <> 'S'
		
			DBSELECTAREA("SB1")
			DBSETORDER(1)
			IF DBSEEK(FWXFILIAL("SB1") +cCod, .T.)
			
				RECLOCK("SB1",.F.)
				
					SB1->B1_LOCALIZ := 'S'
				
				MSUNLOCK()
			
	        ENDIF          
	                  
        ENDIF
        // *** FINAL AJUSTA CAMPO CONTROLE DE LOCALIZACAO PRODUTO *** //
        
        // *** INICIO VERIFICA SE O PRODUTO TEM SBZ INDICADOR DE PRODUTO DO PRODUTO *** //
        SqlIndicador(cCod)
        
        IF TRC->(EOF())
        
        	cErro := cErro + ' Produto: ' + ALLTRIM(cCod) + ' sem Indicador de Produtos, favor verificar!!!' + CHR(13) + CHR(10)
			lRet  := .F. 
			
            
        ENDIF
        
        While TRC->(!EOF())
        
        	// *** INICIO AJUSTA CAMPO CONTROLE DE LOCALIZACAO PRODUTO *** //
	        IF ALLTRIM(TRC->BZ_LOCALIZ) <> 'S'
			
				DBSELECTAREA("SBZ")
				DBSETORDER(1)
				IF DBSEEK(FWXFILIAL("SBZ") +cCod, .T.)
				
					RECLOCK("SBZ",.F.)
					
						SBZ->BZ_LOCALIZ := 'S'
					
					MSUNLOCK()
				
		        ENDIF          
		                  
	        ENDIF
	        // *** FINAL AJUSTA CAMPO CONTROLE DE LOCALIZACAO PRODUTO *** //
        
        	TRC->(dbSkip())
		ENDDO
		TRC->(dbCloseArea())
        // *** FINAL VERIFICA SE O PRODUTO TEM SBZ INDICADOR DE PRODUTO DO PRODUTO *** //
        
		// *** INICIO VERIFICA ENDERECO DO PRODUTO DE *** //
		IF ALLTRIM(cLoc) <> '03' // chamado 053805 WILLIAM COSTA 03/12/2019 - TRATATIVA PARA O ARMAZEM 03

			SqlEndereco(cCod,cLoc,cLocaliz)
			IF TRD->(EOF())
			
				cErro := cErro + ' Produto: ' + ALLTRIM(cCod) + ' sem Endereço, favor verificar!!!' + CHR(13) + CHR(10)
				lRet  := .F.
				
			ENDIF
			
			nContEnd := 0
			While TRD->(!EOF())
			
				// *** INICIO CONTA A QUANTIDADE DE ENDERECOS PARA ESSE PRODUTO E LOCAL *** //
				
				nContEnd := nContEnd + 1
				// *** FINAL CONTA A QUANTIDADE DE ENDERECOS PARA ESSE PRODUTO E LOCAL *** //
			
				TRD->(dbSkip())
			ENDDO
			TRD->(dbCloseArea())
			
			IF nContEnd > 1
			
				cErro := cErro + ' Produto : ' + ALLTRIM(cCod) + ' tem mais de um Endereço, ' + ' para o Local: ' + ALLTRIM(cLoc) + ' favor verificar!!!' + CHR(13) + CHR(10)
				lRet  := .F.
			
			ENDIF 
		ENDIF
        // *** FINAL VERIFICA ENDERECO DO PRODUTO DE *** //
	    
        TRB->(dbSkip())
	ENDDO
	TRB->(dbCloseArea())
	// *** FINAL VERIFICACAO CADASTRO DE PRODUTO *** //
		
Return(lRet)

STATIC FUNCTION VERIFSALDO(cCod,cLoc)

	Local lRet     := .T.
	Local nSalProd := 0
	Local nSalEnd  := 0
	
	// *** INICIO BUSCA QUANTIDADE DO PRODUTO *** //
	SqlSB2(cCod,cLoc)
	While TRE->(!EOF())
	        
		nSalProd := TRE->B2_QATU
		
		TRE->(dbSkip())
	ENDDO
	TRE->(dbCloseArea())
	
	// *** FINAL BUSCA QUANTIDADE DO PRODUTO *** //
	
	// *** INICIO BUSCA QUANTIDADE DO PRODUTO *** //
	IF ALLTRIM(cLoc) <> '03'  // chamado 053805 WILLIAM COSTA 03/12/2019 - TRATATIVA PARA O ARMAZEM 03

		SqlSBF(cCod,cLoc)
		While TRF->(!EOF())
				
			nSalEnd := TRF->BF_QUANT
			
			TRF->(dbSkip())
		ENDDO
		TRF->(dbCloseArea())

	ELSE
	
		SqlSBF2(cCod,cLoc)
		While TRF->(!EOF())
				
			nSalEnd := TRF->BF_QUANT
			
			TRF->(dbSkip())
		ENDDO
		TRF->(dbCloseArea())
		
	ENDIF
	// *** FINAL BUSCA QUANTIDADE DO PRODUTO *** //
	
	IF nSalProd <> nSalEnd
	
		cErro := cErro + ' Produto : ' + ALLTRIM(cCod) + ' está com Saldo divergênte, ' + ' para o Local: ' + ALLTRIM(cLoc) + ' Saldo Prod: ' + CVALTOCHAR(nSalProd) + ' Saldo Ender: ' + CVALTOCHAR(nSalEnd) + ' favor verificar!!!' + CHR(13) + CHR(10)
		lRet := .F.
	
	ENDIF
	
Return(lRet)

Static Function SqlProduto(cProd)

	Local cFilAtu := FWXFILIAL('SB1')

	BeginSQL Alias "TRB"
			%NoPARSER%
			SELECT B1_COD,
			       B1_DESC,
				   B1_CODBAR,
				   B1_LOCALIZ 
			  FROM %TABLE:SB1% 
			 WHERE B1_FILIAL   = %EXP:cFilAtu%
			   AND B1_COD      = %EXP:cProd%
			   AND D_E_L_E_T_ <> '*'
			
	EndSQl          
	
RETURN(NIL)

Static Function SqlIndicador(cProd)

	Local cFilAtu := FWXFILIAL('SBZ')

	BeginSQL Alias "TRC"
			%NoPARSER%
			SELECT BZ_FILIAL,
			       BZ_COD,
			       BZ_LOCALIZ 
			  FROM %TABLE:SBZ%
			   WHERE BZ_FILIAL   = %EXP:cFilAtu%
			     AND BZ_COD      = %EXP:cProd%
				 AND D_E_L_E_T_ <> '*'
			
	EndSQl          
	
RETURN(NIL)

Static Function SqlEndereco(cProd,cLocal,cLocaliz)

	Local cFilAtu := FWXFILIAL('SBE')

	BeginSQL Alias "TRD"
			%NoPARSER%
			SELECT BE_FILIAL,
			       BE_LOCAL,
				   BE_CODPRO,
				   BE_LOCALIZ 
			  FROM %Table:SBE% SBE WITH (NOLOCK)
			  WHERE BE_FILIAL   = %EXP:cFilAtu%
			    AND BE_LOCAL    = %EXP:cLocal%
				AND BE_CODPRO   = %EXP:cProd%
				AND D_E_L_E_T_ <> '*'
			
	EndSQl          
	If TRD->(!Eof())
		BeginSQL Alias "TRD"
				%NoPARSER%
				SELECT BE_FILIAL,
					BE_LOCAL,
					BE_CODPRO,
					BE_LOCALIZ 
				FROM %Table:SBE% SBE WITH (NOLOCK)
				WHERE BE_FILIAL   = %EXP:cFilAtu%
					AND BE_LOCAL    = %EXP:cLocal%
					AND BE_LOCALIZ  = %EXP:cLocaliz%
					AND D_E_L_E_T_ <> '*'
				
		EndSQl          
	EndIf
RETURN(NIL)

Static Function SqlSB2(cProd,cLocal)

	Local cFilAtu := FWXFILIAL('SB2')

	BeginSQL Alias "TRE"
			%NoPARSER%
			SELECT B2_QATU 
			  FROM %Table:SB2% SB2 WITH (NOLOCK)
			 WHERE B2_FILIAL   = %EXP:cFilAtu%
			   AND B2_COD      = %EXP:cProd%
			   AND B2_LOCAL    = %EXP:cLocal%
			   AND D_E_L_E_T_ <> '*'
			
	EndSQl          
	
RETURN(NIL)

STATIC FUNCTION SqlSBF(cProd,cLocal)

	Local cFilAtu := FWXFILIAL('SBF')

	BeginSQL Alias "TRF"
			%NoPARSER% 
			   SELECT BF_QUANT
				 FROM %Table:SBE% SBE WITH (NOLOCK)
				 INNER JOIN %Table:SBF% SBF WITH (NOLOCK)
				         ON BF_FILIAL       = BE_FILIAL
						AND BF_PRODUTO      = BE_CODPRO
						AND BF_LOCAL        = BE_LOCAL
						AND BF_LOCALIZ      = BE_LOCALIZ
						AND SBF.D_E_L_E_T_ <> '*'
				      WHERE BE_FILIAL       = %EXP:cFilAtu%
				        AND BE_CODPRO       = %EXP:cProd%
				        AND BE_LOCAL        = %EXP:cLocal%
				        AND SBE.D_E_L_E_T_ <> '*'
			   
	EndSQl  
	           
RETURN(NIL)

STATIC FUNCTION SqlSBF2(cProd,cLocal)

	Local cFilAtu := FWXFILIAL('SBF')

	BeginSQL Alias "TRF"
			%NoPARSER% 
			SELECT BF_QUANT 
			FROM  SBF010 SBF WITH (NOLOCK) 
			   WHERE BF_FILIAL     = %EXP:cFilAtu%
			   AND BF_PRODUTO      = %EXP:cProd%
			   AND BF_LOCAL        = %EXP:cLocal%
			   AND BF_LOCALIZ      = 'PROD'
			   AND SBF.D_E_L_E_T_ <> '*' 
			   
	EndSQl  
	           
RETURN(NIL)
