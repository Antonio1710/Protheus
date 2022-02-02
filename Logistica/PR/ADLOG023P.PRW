#include 'rwmake.ch'  
#include 'Protheus.ch'
#include 'topconn.ch'

Static cAltera := "N"  //Essa variavel é utilizada na pornto de entrada MALTCLI

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA030TOK  º Autor ³ Ana Helena         º Data ³  28/12/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³P.E. para validacao dos dados na inclusao e alteracao do    º±±
±±º          ³cadastro de clientes. Tirado obrigatoriedade do campo       º±±
±±º          ³A1_CGC, pois quando estado = "EX" nao precisa ser preenchidoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºALTERACAO ³WILLIAM COSTA 15/08/2019 - 050799 || OS 052114 || EXPORTACAOº±±
±±º          ³ || CICERO || 8360 || A1_CEPE E PB3_CEPE - Adicionado trata-º±±
±±º          ³tiva do CEP de Entrega para clientes nacionais ser obrigado º±±
±±º          ³a informar para salvar o Cliente                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
   
User Function MA030TOK()  

	Local _lRetCGC  := .F. 
	Local aArea     := GetArea() 
	Local lRetCondP := .F.
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'P.E. para validacao inclusao e alteracao cadastro de cliente')
	
	cAltera := "N"
	
	If M->A1_EST == 'EX'
	
		_lRetCGC  := .T.
		
		// chamado 035622 - 09/06/2017 - fernando sigoli
		If Empty(M->A1_CONDPAG)
			Alert("Clientes de Exportação é obrigatorio informar a condiçao de pagamento especifico de export (VENDAS)")  
			Return .F.
		EndIf	
		
	Else
		If Empty(M->A1_CGC)
			_lRetCGC := .F.
		Else
			_lRetCGC := .T.	
		Endif
	Endif
	
	If !_lRetCGC
		Alert("Campo CGC é obrigatorio. (PE MA030TOK)")   //MA030
	Endif    
	
	If FUNNAME()=="MATA030"    && Sigoli 08/03/2017 chamado 031202 - 031202
		    
		//verificação, caso ocorreu alguma alteração nos campos abaixo, altera o roteiro para o Padrão 199
		If !inclui .and. !Empty(SA1->A1_ULTCOM) .and. M->A1_ROTEIRO <> '199' .and. M->A1_ROTEIRO <> '200'
		   	
			If (M->A1_MSBLQL = '2' .and.  SA1->A1_MSBLQL = '1') .or. (alltrim(M->A1_ENDENT) <> alltrim(SA1->A1_ENDENT)) .or. ;
			   (alltrim(M->A1_BAIRROE) <> alltrim(SA1->A1_BAIRROE)) .or. (alltrim(M->A1_CEPE) <> alltrim(SA1->A1_CEPE)) .or. ;
			   (alltrim(M->A1_CODMUNE) <> alltrim(SA1->A1_CODMUNE)) .or. (alltrim(M->A1_MUNE) <> alltrim(SA1->A1_MUNE)) .or. ;
			   (alltrim(M->A1_ESTE) <> alltrim(SA1->A1_ESTE))
			   
				cAltera := 'S'	 //altera Status para tratar o roteiro padrao
			EndIf
		
		EndIF
	
	EndIF
		
	//Inicio Sigoli 28/11/2016  Chamado 029362
	//tratativa de cadastro de cliete, quando Pessoa Fisica a IE deverá estar em branco
	If Empty(M->A1_INSCR) .and. Alltrim(M->A1_PESSOA) = 'J' .and. AllTrim( M->A1_EST) != 'EX'
		Alert(ALLTRIM(cusername)+", por favor, informa a Inscrição Estadual" )
		_lRetCGC := .F.
	EndIF
	
	If !Empty(M->A1_INSCR) .and. Alltrim(M->A1_PESSOA) = 'F'
	
		//Alert(ALLTRIM(cusername)+". Cadastro de Cliente Pessoa Fisica, a Inscrição Estadual deverá ficar em branco" )
		//_lRetCGC := .F.
	
	 	// *** INICIO 29/11/2018 WILLIAM COSTA CHAMADO 045487 || OS 046658 || INCUBATORIO || VALERIA || (19)3539-1309 || CADASTRO RIO CLARO   *** //
	 	
	 	IF ALLTRIM(M->A1_TIPO) == 'L' .AND. M->A1_EST <> 'SP'
	 	
	 		Alert(ALLTRIM(cusername)+". Cadastro de Cliente Pessoa Fisica, permitido Inclusao de Produtor Rural de outros estados com Inscricao Estadual " )
	 	
	 	
	 	ELSE
	 	
			Alert(ALLTRIM(cusername)+". Cadastro de Cliente Pessoa Fisica, a Inscrição Estadual deverá ficar em branco" )
			_lRetCGC := .F.
		
		ENDIF
		
		// *** INICIO 29/11/2018 WILLIAM COSTA CHAMADO 045487 || OS 046658 || INCUBATORIO || VALERIA || (19)3539-1309 || CADASTRO RIO CLARO   *** //
		
	EndIF   
	
	If Empty(M->A1_INSCR) .and. Alltrim(M->A1_PESSOA) = 'F' .and. M->A1_CONTRIB != '2'
		Alert(ALLTRIM(cusername)+". Para Cadastro de Cliente Pessoa Fisica, O campo Contribuinte (FISCAIS) informar como: NÃO" )
		_lRetCGC := .F.
	EndIf
	//Fim Sigoli 28/11/2016  Chamado 029362
	
	&& Inicio - chamado: 034573 - Fernando Sigoli 20/04/2017 
	
	If (Empty(M->A1_INSCR) .or. Substr(M->A1_INSCR,1,5) = 'ISENT') .and. M->A1_TIPO == 'F' .and. M->A1_CONTRIB != '2' .and. Alltrim(M->A1_PESSOA) = 'J' 
		Alert(ALLTRIM(cusername)+". Para Cadastro de Cliente Pessoa Juridica e classificado como Consumidor final, O campo Contribuinte informar como: NÃO" )
		_lRetCGC := .F.
	EndIf
	
	If (!Empty(M->A1_INSCR) .and. Substr(M->A1_INSCR,1,5) <> 'ISENT') .and. !Empty(M->A1_CGC) .and.  M->A1_TIPO  == 'R' .and.  M->A1_CONTRIB == '2' .and. Alltrim(M->A1_PESSOA) = 'J' 
		Alert(ALLTRIM(cusername)+". Para Cadastro de Cliente Pessoa Juridica e classificado como Revendedor, O campo Contribuinte informar como: SIM" )
		_lRetCGC := .F.
	EndIf
	
	&& Fim - chamado: 034573 - Fernando Sigoli 20/04/2017
	
	
	// *** INICIO WILLIAM COSTA 15/08/2019 CHAMADO 050799 || OS 052114 || EXPORTACAO || CICERO || 8360 || A1_CEPE   E PB3_CEPE *** //
		
	IF M->A1_EST <> 'EX' .AND. EMPTY(M->A1_CEPE)
	
		Alert("Clientes Nacionais é necessário informar o CEP de Entrega, favor verificar (MA030TOK)")  
		_lRetCGC := .F.
		
	ENDIF	
	
	// *** FINAL WILLIAM COSTA 15/08/2019 CHAMADO 050799 || OS 052114 || EXPORTACAO || CICERO || 8360 || A1_CEPE   E PB3_CEPE *** //
	
	
	&&Mauricio - 11/04/17 - Chamado 035183
	&&Inicio
	If ALTERA .And. _lRetCGC
	   DbSelectArea("SA1")
	   DbSetOrder(1)
	   If dbseek(xFilial("SA1")+M->A1_COD+M->A1_LOJA)
	      IF SA1->A1_VEND <> M->A1_VEND
	         dbSelectArea("ZBE")
		     RecLock("ZBE",.T.)
			    Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
			    Replace ZBE_DATA 	   	WITH dDataBase
			    Replace ZBE_HORA 	   	WITH TIME()
			    Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
			    Replace ZBE_LOG	        WITH ("CAMPO A1_VEND DE " + SA1->A1_VEND + " PARA "+ M->A1_VEND)  
			    Replace ZBE_MODULO	    WITH "SA1"
			    Replace ZBE_ROTINA	    WITH "MA030TOK"
			    Replace ZBE_PARAME	    WITH "CLIENTE: " + M->A1_COD + " " +M->A1_LOJA
		     ZBE->(MsUnlock())            
	      Endif
	      IF SA1->A1_XVEND2 <> M->A1_XVEND2
	         dbSelectArea("ZBE")
		     RecLock("ZBE",.T.)
			    Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
			    Replace ZBE_DATA 	   	WITH dDataBase
			    Replace ZBE_HORA 	   	WITH TIME()
			    Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
			    Replace ZBE_LOG	        WITH ("CAMPO A1_XVEND2 DE " + SA1->A1_XVEND2 + " PARA "+ M->A1_XVEND2)  
			    Replace ZBE_MODULO	    WITH "SA1"
			    Replace ZBE_ROTINA	    WITH "MA030TOK"
			    Replace ZBE_PARAME	    WITH "CLIENTE: " + M->A1_COD + " " +M->A1_LOJA
		     ZBE->(MsUnlock())            
	      Endif
	      IF SA1->A1_SATIV1 <> M->A1_SATIV1
	         dbSelectArea("ZBE")
		     RecLock("ZBE",.T.)
			    Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
			    Replace ZBE_DATA 	   	WITH dDataBase
			    Replace ZBE_HORA 	   	WITH TIME()
			    Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
			    Replace ZBE_LOG	        WITH ("CAMPO A1_SATIV1 DE " + SA1->A1_SATIV1 + " PARA "+ M->A1_SATIV1)  
			    Replace ZBE_MODULO	    WITH "SA1"
			    Replace ZBE_ROTINA	    WITH "MA030TOK"
			    Replace ZBE_PARAME	    WITH "CLIENTE: " + M->A1_COD + " " +M->A1_LOJA
		     ZBE->(MsUnlock())            
	      Endif
	      IF SA1->A1_SATIV2 <> M->A1_SATIV2
	         dbSelectArea("ZBE")
		     RecLock("ZBE",.T.)
			    Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
			    Replace ZBE_DATA 	   	WITH dDataBase
			    Replace ZBE_HORA 	   	WITH TIME()
			    Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
			    Replace ZBE_LOG	        WITH ("CAMPO A1_SATIV2 DE " + SA1->A1_SATIV2 + " PARA "+ M->A1_SATIV2)  
			    Replace ZBE_MODULO	    WITH "SA1"
			    Replace ZBE_ROTINA	    WITH "MA030TOK"
			    Replace ZBE_PARAME	    WITH "CLIENTE: " + M->A1_COD + " " +M->A1_LOJA
		     ZBE->(MsUnlock())            
	      Endif
	   Endif      
	Endif
	&&Fim
	     
	RestArea(aArea)
      
Return(_lRetCGC)     
  
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MALTCLI   º Autor ³ Fernando Sigoli    º Data ³  12/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ P.E pertence realiza validação de usuário, após a          º±±
±±º          ³ confirmação da alteração do cliente.          			  º±±
±±º Chamado  ³030747													  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
User Function M030PALT()

	Local aArea     := GetArea() 
	 	
	DbSelectArea("SA1")
	dbSetOrder(1)
	
	If cAltera = 'S'   	//A informação desse falg venha do p.e MA030TOK
		If dbseek(xFilial("SA1")+SA1->A1_COD+SA1->A1_LOJA)
			Reclock("SA1",.F.)
		 	SA1->A1_ROTEIRO := '199'  
			MsUnlock()	
		 Else
			Alert('Cliente não Encontrado')
		Endif			
	EndIF
	
	RestArea(aArea)

Return (.T.)