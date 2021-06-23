#include "rwmake.ch"
#include "Ap5Mail.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ENVIAREMAILº Autor ³ JULIANO RODRIGUES  º Data ³ 26/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ ENVIA EMAILS ATRAVES DE UM SMTP SERVER CONFIGURADO         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5 EM DIANTE                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function ENVIAEMAIL(cFrom,cTos,cMensagem,cSubject,cAttachment)

Local nI
Local lRet := .T.
Local cError
//Local cServer 	:= "smtp.adoro.com.br" //ALLTRIM(GetMv("MV_RELSERV"))  
//Local cServer 	:= "smtp.mandic.com.br" //ALLTRIM(GetMv("MV_RELSERV"))   
//Local cServer 	:= "smtp.totalcomputadores.com.br" //ALLTRIM(GetMv("MV_RELSERV"))
Local cServer 	:= ALLTRIM(GetMv("MV_RELSERV")) // Alex Borges 02/08/2011 - servidor conforme parametro e não fixo no programa.
Local cConta 	:= ALLTRIM(GetMv("MV_RELACNT"))
Local cPassword := ALLTRIM(GetMv("MV_RELPSW"))
Local lAutentica:= GetMv("MV_RELAUTH")   // ALTERADA PARA ATENDER CHAMADO 007142

U_ADINF009P('SENDMAIL' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'ENVIA EMAILS ATRAVES DE UM SMTP SERVER CONFIGURADO')

CONNECT SMTP SERVER cServer ACCOUNT cConta PASSWORD cPassword RESULT lOk

// o comando CONNECT conecta ao servidor smtp
// atraves da conta contida em cAccount
// repare na senha, eh como se voce utilizasse o Outlook Express



If lOk    // teste se a conexao com o servidor smtp teve sucesso
	
	//INCLUIDO POR ADRIANA EM 01022008 PARA AUTENTICACAO NO SERVIDOR SMTP
	If lAutentica == .T.
	If !MAILAUTh(cConta,cPassword)  //se servidor de email requer autenticação utilizar esta função
		//	If lMensagem
		Aviso(	"Erro no envio do e-Mail",	"Nao foi possível autenticação ",{"Fechar"},2)
		//	EndIf
		lOk := .F.
			lRet := .f.
	endif
	endif
	
	If lOk    // teste se a conexao com o servidor smtp teve sucesso
		
		If cAttachment == ""
			SEND MAIL FROM cFrom TO cTos SUBJECT cSubject BODY cMensagem RESULT lEnv
		Else
			SEND MAIL FROM cFrom TO cTos SUBJECT cSubject BODY cMensagem ATTACHMENT cAttachment RESULT lEnv
		Endif
		
		If !lEnv
			GET MAIL ERROR cError
			Aviso("Erro no envio do e-Mail",cError,{"Fechar"},2)
			lRet := .f.
		Endif
		
		//CONNECT SMTP SERVER cCtaSmpt ACCOUNT cAccount PASSWORD cCtaPass
		//SEND MAIL FROM cCtaMail to  SA2->A2_EMAIL  ;
		//SUBJECT "PEDIDO DE COMPRA" ;
		//BODY ;
		
		// o comando sendmail envia a mensagem pela conta cAccount,
		// utilizando a lista de destinatarios em cTos
		// com a mensagem contida em cMensagem e mais
		// os anexos teste1.doc e teste2.doc
		// o diretorio ENVIAR deve estar abaixo da estrutura
		// declarada em rootpath no ap5srv.ini
		
		//If ! (lEnv)  // testa se a mensagem foi enviada com sucesso
		//	lRet := .F.
		//Endif
		
		DISCONNECT SMTP SERVER	RESULT lFim
		
		//If ! (lFim)   // testa desconexao do serv. smtp
		//	lRet := .F.
		//Endif
	Endif
Else
	lRet := .F.
Endif

Return lRet
