#include 'rwmake.ch'  
#include 'Protheus.ch'
#include 'topconn.ch'
#INCLUDE "XMLXFUN.CH"
#DEFINE CRLF CHR(13)+CHR(10) 

Static cAltera := "N"  //Essa variavel é utilizada na pornto de entrada MALTCLI

/*{Protheus.doc} User Function MA030TOK
	P.E. para validacao dos dados na inclusao e alteracao do
	cadastro de clientes. Tirado obrigatoriedade do campo
	A1_CGC, pois quando estado = "EX" nao precisa ser preenchido
	@type  User Function 
	@author Ana Helena
	@since 28/12/2010
	@version 01
	@history WILLIAM COSTA 15/08/2019 - 050799 || OS 052114 || EXPORTACAO || CICERO || 8360 || A1_CEPE E PB3_CEPE - Adicionado tratativa do CEP de Entrega para clientes nacionais ser obrigado a informar para salvar o Cliente
	@history Ticket 76086 - 13/07/2022 - Antonio Domingos - Validação dos campos A1_XLONGIT e A1_XLATITU. 
*/
User Function MA030TOK()  

	Local _lRetCGC  	:= .F. 
	Local aArea     	:= GetArea() 
	Local _lMV_XVDLGLT  := SUPERGETMV('MV_XVDLGLT',.F.,.T.) //Desativa validação dos campos Longitude e Latitude.
	Local _lRetLongit	:= .T.
	Local _lRetLatitu	:= .T.
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'P.E. para validacao inclusao e alteracao cadastro de cliente')
	
	cAltera := "N"
	
	If M->A1_EST == 'EX'
	
		_lRetCGC  := .T.
		
		// chamado 035622 - 09/06/2017 - fernando sigoli
		If Empty(M->A1_CONDPAG)
			Alert("Clientes de Exportação é obrigatorio informar a condiçao de pagamento especifico de export (VENDAS) (PE MA030TOK-01)")  
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
		Alert("Campo CGC é obrigatorio. (PE MA030TOK-02)")   //MA030
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
		Alert(ALLTRIM(cusername)+", por favor, informa a Inscrição Estadual (PE MA030TOK-03)" )
		_lRetCGC := .F.
	EndIF
	
	If !Empty(M->A1_INSCR) .and. Alltrim(M->A1_PESSOA) = 'F'
	
		//Alert(ALLTRIM(cusername)+". Cadastro de Cliente Pessoa Fisica, a Inscrição Estadual deverá ficar em branco" )
		//_lRetCGC := .F.
	
	 	// *** INICIO 29/11/2018 WILLIAM COSTA CHAMADO 045487 || OS 046658 || INCUBATORIO || VALERIA || (19)3539-1309 || CADASTRO RIO CLARO   *** //
	 	
	 	IF ALLTRIM(M->A1_TIPO) == 'L' .AND. M->A1_EST <> 'SP'
	 	
	 		Alert(ALLTRIM(cusername)+". Cadastro de Cliente Pessoa Fisica, permitido Inclusao de Produtor Rural de outros estados com Inscricao Estadual (PE MA030TOK-04) " )
	 	
	 	
	 	ELSE
	 	
			Alert(ALLTRIM(cusername)+". Cadastro de Cliente Pessoa Fisica, a Inscrição Estadual deverá ficar em branco (PE MA030TOK-04)" )
			_lRetCGC := .F.
		
		ENDIF
		
		// *** INICIO 29/11/2018 WILLIAM COSTA CHAMADO 045487 || OS 046658 || INCUBATORIO || VALERIA || (19)3539-1309 || CADASTRO RIO CLARO   *** //
		
	EndIF   
	
	If Empty(M->A1_INSCR) .and. Alltrim(M->A1_PESSOA) = 'F' .and. M->A1_CONTRIB != '2'
		Alert(ALLTRIM(cusername)+". Para Cadastro de Cliente Pessoa Fisica, O campo Contribuinte (FISCAIS) informar como: NÃO (PE MA030TOK-05)" )
		_lRetCGC := .F.
	EndIf
	//Fim Sigoli 28/11/2016  Chamado 029362
	
	&& Inicio - chamado: 034573 - Fernando Sigoli 20/04/2017 
	
	If (Empty(M->A1_INSCR) .or. Substr(M->A1_INSCR,1,5) = 'ISENT') .and. M->A1_TIPO == 'F' .and. M->A1_CONTRIB != '2' .and. Alltrim(M->A1_PESSOA) = 'J' 
		Alert(ALLTRIM(cusername)+". Para Cadastro de Cliente Pessoa Juridica e classificado como Consumidor final, O campo Contribuinte informar como: NÃO-06" )
		_lRetCGC := .F.
	EndIf
	
	If (!Empty(M->A1_INSCR) .and. Substr(M->A1_INSCR,1,5) <> 'ISENT') .and. !Empty(M->A1_CGC) .and.  M->A1_TIPO  == 'R' .and.  M->A1_CONTRIB == '2' .and. Alltrim(M->A1_PESSOA) = 'J' 
		Alert(ALLTRIM(cusername)+". Para Cadastro de Cliente Pessoa Juridica e classificado como Revendedor, O campo Contribuinte informar como: SIM (PE MA030TOK-07)" )
		_lRetCGC := .F.
	EndIf
	
	&& Fim - chamado: 034573 - Fernando Sigoli 20/04/2017
	
	
	// *** INICIO WILLIAM COSTA 15/08/2019 CHAMADO 050799 || OS 052114 || EXPORTACAO || CICERO || 8360 || A1_CEPE   E PB3_CEPE *** //
		
	IF M->A1_EST <> 'EX' .AND. EMPTY(M->A1_CEPE)
	
		Alert("Clientes Nacionais é necessário informar o CEP de Entrega, favor verificar (MA030TOK-08)")  
		_lRetCGC := .F.
		
	ENDIF	
	
	// *** FINAL WILLIAM COSTA 15/08/2019 CHAMADO 050799 || OS 052114 || EXPORTACAO || CICERO || 8360 || A1_CEPE   E PB3_CEPE *** //

	// *** INICIO Ticket 76086 - 08/07/2022 - Antonio Domingos - Validação dos campos A1_XLATITU E A1_XLONGIT
	If _lMV_XVDLGLT //Para desativar a validação dos campos Longitude e Latitude e  - Informar .F. no parametro
		If !Empty(M->A1_XLONGIT)
			_lRetLongit :=_fVldLongLat(M->A1_XLONGIT,"Longitude")
		EndIf
		If !Empty(M->A1_XLATITU)
			_lRetLatitu :=_fVldLongLat(M->A1_XLATITU,"Latitude")
		EndIf
	    If _lRetLongit .And. _lRetLatitu
			_lRetCGC := .T.
		Else
			_lRetCGC := .F.
		EndIf
	EndIf

	// *** FIM Ticket 76086 - 08/07/2022 - Antonio Domingos - Validação dos campos A1_XLATITU E A1_XLONGIT
	
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
      IF SA1->A1_XLONGIT <> M->A1_XLONGIT
	         dbSelectArea("ZBE")
		     RecLock("ZBE",.T.)
			    Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
			    Replace ZBE_DATA 	   	WITH dDataBase
			    Replace ZBE_HORA 	   	WITH TIME()
			    Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
			    Replace ZBE_LOG	        WITH ("CAMPO M->A1_XLONGIT2 DE " + SA1->A1_XLONGIT + " PARA "+ M->A1_XLONGIT)  
			    Replace ZBE_MODULO	    WITH cModulo
			    Replace ZBE_ROTINA	    WITH "MA030TOK"
			    Replace ZBE_PARAME	    WITH "CLIENTE: " + M->A1_COD + " " +M->A1_LOJA
		     ZBE->(MsUnlock())            
	      Endif
      IF SA1->A1_XLATITU <> M->A1_XLATITU
	         dbSelectArea("ZBE")
		     RecLock("ZBE",.T.)
			    Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
			    Replace ZBE_DATA 	   	WITH dDataBase
			    Replace ZBE_HORA 	   	WITH TIME()
			    Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
			    Replace ZBE_LOG	        WITH ("CAMPO A1_XLATITU DE " + SA1->A1_XLATITU + " PARA "+ M->A1_XLATITU)  
			    Replace ZBE_MODULO	    WITH cModulo
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

/*{Protheus.doc} Static Function _fVldLatLong(_cCampo)
	Função para validar os Campos de Longitude e Latitude
	@type  Function
	@author Antonio Domingos
	@since 12/07/2022
	@version 01
	@Ticket 76086 - 13/07/2022 - Antonio Domingos - Validação dos campos A1_XLONGIT e A1_XLATITU
*/
Static Function _fVldLongLat(_cCampo,_cNome)
	Local _lRet := .T.
	Local _lCpoSinal     := AT("-",_cCampo,1) > 0 .OR. AT("+",_cCampo,1) > 0 
	Local _cCpoMsgSinal   := If(!_lCpoSinal,CRLF+"Obrigatorio informar sinal no campo de "+_cNome+"."," ")
	Local _nTamCpo        := LEN(ALLTRIM(_cCampo))
	Local _nPosCpoDec     := AT(".",_cCampo)
	Local _nTamCasaDec    := Len(Substr(Alltrim(_cCampo),_nPosCpoDec+1,_nTamCpo-(_nPosCpoDec)))
	Local _cCpoZeroMsgDec := If(_nPosCpoDec<1,CRLF+"Obrigatorio informar casas decimais no campo de "+_cNome+"."," ")
	Local _cCpoTresMsgDec := If(_nTamCasaDec<3,CRLF+"Obrigatorio informar pelo menos seis (6) casas decimais no campo de "+_cNome+"."," ")
	Local _cMsgParametro  := CRLF+"ATENÇÃO!!! O parâmetro MV_XVDLGLT desativa a validação."
	Local _lCpoTemAlfa    :=  _fVerAlpha(_cCampo) 
	Local _cMsgTemAlfa    := If(_lCpoTemAlfa,CRLF+" Proibido digitar letra(s)!!!"," ")
	If !_lCpoSinal .OR. _nPosCpoDec < 1 .OR. _nTamCasaDec < 6 .OR. _lCpoTemAlfa
		Alert(_cNome+" "+_cCampo+" inválida! "+alltrim(_cCpoMsgSinal)+alltrim(_cCpoZeroMsgDec)+alltrim(_cCpoTresMsgDec)+alltrim(_cMsgTemAlfa)+CRLF+"Favor verificar."+_cMsgParametro+CRLF+"(PE MA030TOK-09)")  
		_lRet := .F.
	EndIf
Return(_lRet)
/*{Protheus.doc} Static Function _fVerAlpha(_cCampo)
	Função para validar se foi digitado letras no campo
	@type  Function
	@author Antonio Domingos
	@since 13/07/2022
	@version 01
	@Ticket 76086 - 13/07/2022 - Antonio Domingos - Validação dos campos A1_XLONGIT e A1_XLATITU
*/
Static Function _fVerAlpha(_cCampo) 
	Local _lRetIsAlpha:=.F.
	Local _nContador := 1
	Local _nTamCampo   := Len(alltrim(_cCampo))
	For _nContador := 1 to _nTamCampo
		If IsAlpha(Substr(_cCampo,_nContador,1))
			_lRetIsAlpha:=.T.
			Exit
		EndIf
	Next
Return(_lRetIsAlpha)
