#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*{Protheus.doc} User Function MT015TOK
	Ponto de entrada na validacao do cadastro de enderecos MATA015 - validar se o produto cadastro nao tem saldo de
	@type  Function
	@author Vogas Junior
	@since 11/09/2009
	@version 01
	@history Chamado 046452 - Luciano         - 14/01/2019 - Retirado msg na Alteracao msg de espaço em brancos na Localizacao 
	@history Chamado 049738 - William Costa   - 07/06/2019 - Verificado que as vezes nao carrega os campos em memoria gerando error log foi adicionado regra para tratar e verificar se existe nao campo de memoria.
	@history Chamado TI     - Ricardo Lima    - 14/01/2018 - Ajuste de leiaute de tela
	@history Chamado 055345 - William Costa   - 29/01/2019 - Identificado para verificar também o produto que está salvo no banco de dados da tabela SBE, para verificar se esse produto também tem saldo na hora da alteração para não deixar.
	@history Chamado 057610 - William Costa   - 23/04/2020 - Identificado que não funcionava mais o M-> para pegar a variavel de memoria, devido a tela ser em MVC, foi necessário trocar para o comando FWFLDGET("BE_LOCALIZ"), após testes o error log foi solucionado.
	@history ticket 75276   - Antonio Domingos - 30/06/2022 - Transferencia - Desvincular produto do endereço
*/	
                                 
USER FUNCTION MT015TOK()

	Local lRet  := .T.
	Local _cMV_XMT015B :=  SuperGetMV("MV_XMT015B",.F.,"001357/001337")
	//Local _lMV_XMT015A :=  SuperGetMv('MV_XMT015A', .f. ,.F. ) //Libera .T. ou Não Libera .F. o Cadastro de Endereço para Diversos produtos

	IF VALTYPE(PARAMIXB[1]) == 'N' .AND. ; //trava para o ParamIXB não ser Nulo
	   PARAMIXB[1]           == 3          //Se for igual a 3 INCLUSAO
	   
	    SqlVSBF(FWFLDGET("BE_FILIAL"),FWFLDGET("BE_LOCAL"),FWFLDGET("BE_CODPRO"),FWFLDGET("BE_LOCALIZ"))
	    IF TRB->(!EOF())       
			//@history ticket 75276   - Antonio Domingos - 30/06/2022 - Transferencia - Desvincular produto do endereço
			//Somente fará a validação se o endereço for cadastrado com o codigo do produto M->BE_CODPRO.
			If !__cUserID $ _cMV_XMT015B //!Empty(M->BE_CODPRO)
				MSGSTOP('Olá ' + ALLTRIM(cUserName) + ', não é possivel efetivar o endereço!!!'  + CHR(13) + CHR(10) + ;
						'Esse produto já está com saldo localizado em outro lugar.'               + CHR(13) + CHR(10) + ; 
						'Localização:' + TRB->BF_LOCALIZ + ' Saldo:' + CVALTOCHAR(TRB->BF_QUANT) + CHR(13) + CHR(10) + ; 
						' Verifique o Saldo de Localização.', 'MT015TOK-01' )						
				lRet := .F.
			EndIf
		ENDIF
   	    TRB->(dbCloseArea()) 
   	    
   	    IF AT(" ",RTRIM(FWFLDGET("BE_LOCALIZ"))) > 0 // A localização tem espaço não pode
   	        
	   	    MSGSTOP('Olá ' + ALLTRIM(cUserName) + ', não é possivel salvar o Endereço com espaço!!!'  + CHR(13) + CHR(10) + ;
					' Verifique por favor!!!.', 'MT015TOK-02' )						
				    
	   		lRet := .F.
   	    	
   	    ENDIF
	   
	ENDIF   
	
	IF VALTYPE(PARAMIXB[1]) == 'N' .AND. ; //trava para o ParamIXB não ser Nulo
	   PARAMIXB[1]           == 4          //Se for igual a 4 ALTERACAO
	   
	    // ***  INICIO CHAMADO 049738 || OS 051024 || ALMOXARIFADO || EDUARDO || 8429 ||  POR WILLIAM COSTA 07/06/2019 *** //
	   	IF VALTYPE(FWFLDGET("BE_CODPRO")) <> 'U'
	   	
	   		SqlVSBF(FWFLDGET("BE_FILIAL"),FWFLDGET("BE_LOCAL"),FWFLDGET("BE_CODPRO"),FWFLDGET("BE_LOCALIZ"))

	   	ENDIF
	   		
	    IF TRB->(!EOF())       
			//@history ticket 75276   - Antonio Domingos - 30/06/2022 - Transferencia - Desvincular produto do endereço
			//Somente fará a validação se o endereço for cadastrado com o codigo do produto M->BE_CODPRO.
	    	If !__cUserID $ _cMV_XMT015B //!Empty(M->BE_CODPRO)
				MSGSTOP('Olá ' + ALLTRIM(cUserName) + ', não é possivel efetivar o endereço!!!'  + CHR(13) + CHR(10) + ;
						'Esse produto já está com saldo localizado em outro lugar.'               + CHR(13) + CHR(10) + ; 
						'Localização:' + TRB->BF_LOCALIZ + ' Saldo:' + CVALTOCHAR(TRB->BF_QUANT) + CHR(13) + CHR(10) + ; 
						' Verifique o Saldo de Localização.', 'MT015TOK-03' )						
						
				lRet := .F.
			EndIf			    	   			
		ENDIF
   	    TRB->(dbCloseArea()) 

		// ***  FINAL CHAMADO 049738 || OS 051024 || ALMOXARIFADO || EDUARDO || 8429 ||  POR WILLIAM COSTA 07/06/2019 *** //

		// ***  INICIO 055345 || OS 056758 || CONTROLADORIA || FRED_SANTOS || 8947 || B2 X BF  POR WILLIAM COSTA 29/01/2020 *** //
	   	SqlVSBF2(SBE->BE_FILIAL,SBE->BE_LOCAL,SBE->BE_CODPRO,SBE->BE_LOCALIZ)
	   		
	    IF TRC->(!EOF())       
	       	//@history ticket 75276   - Antonio Domingos - 30/06/2022 - Transferencia - Desvincular produto do endereço
			//Somente fará a validação se o endereço for cadastrado com o codigo do produto M->BE_CODPRO.
		    If !__cUserID $ _cMV_XMT015B //!Empty(M->BE_CODPRO)
				MSGSTOP('Olá ' + ALLTRIM(cUserName) + ', não é possivel efetivar o endereço!!!'  + CHR(13) + CHR(10) + ;
						'o produto que estava salvo ainda tem saldo localizado nesse lugar.'     + CHR(13) + CHR(10) + ; 
						'Localização:' + TRC->BF_LOCALIZ + ' Saldo:' + CVALTOCHAR(TRC->BF_QUANT) + CHR(13) + CHR(10) + ; 
						'Transfira todo o Saldo desse produto para outro endereço, depois volte e altere o cadastro de Endereço.', 'MT015TOK-03' )						
						
				lRet := .F.
			EndIf			    	   			
		ENDIF
   	    TRC->(dbCloseArea()) 

		// ***  FINAL 055345 || OS 056758 || CONTROLADORIA || FRED_SANTOS || 8947 || B2 X BF  POR WILLIAM COSTA 29/01/2020 *** //   
   	    
	ENDIF
	   
RETURN(lRet)  

STATIC FUNCTION SqlVSBF(cFil,cLocal,cCod,cLocaliz)

	BeginSQL Alias "TRB"
			%NoPARSER%        
			SELECT BF_PRODUTO,
			       BF_LOCALIZ,
			       BF_QUANT
			  FROM %Table:SBF% WITH (NOLOCK)
			WHERE  BF_FILIAL   = %EXP:cFil%
			   AND BF_LOCAL    = %EXP:cLocal%
			   AND BF_PRODUTO  = %EXP:cCod%
			   AND BF_LOCALIZ <> %EXP:cLocaliz%
			   AND D_E_L_E_T_ <> '*'             
			   
	EndSQl
	
RETURN(NIL)

STATIC FUNCTION SqlVSBF2(cFil,cLocal,cCod,cLocaliz)

	
	BeginSQL Alias "TRC"
			%NoPARSER%        
			SELECT BF_PRODUTO,
			       BF_LOCALIZ,
			       BF_QUANT
			  FROM %Table:SBF% WITH (NOLOCK)
			WHERE  BF_FILIAL   = %EXP:cFil%
			   AND BF_LOCAL    = %EXP:cLocal%
			   AND BF_PRODUTO  = %EXP:cCod%
			   AND BF_LOCALIZ  = %EXP:cLocaliz%
			   AND D_E_L_E_T_ <> '*'             
			   
	EndSQl
	
RETURN(NIL)
