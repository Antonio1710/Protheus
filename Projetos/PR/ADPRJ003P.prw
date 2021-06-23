#include "PROTHEUS.CH"
#include "Ap5Mail.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEnviaMail บAutor  ณFernando Macieira   บ Data ณ  01/05/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para enviar email na recusa do projeto              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamado   ณ 046284 - fwnm - 08/01/2019 - Novas regras alteracao valor  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamado   ณ 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451     บฑฑ
ฑฑบ          ณ || APROVACAO PROJETOS - FWNM - 30/04/2019                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบChamado   ณ TI - Por Adriana em 29/05/2019 devido a alteracao para o   บฑฑ
ฑฑบ          ณ email SharedRelay                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ADPRJ003P(cAssunto, cTexto, cMail, cUsrMail)

	Local lNoShow   := .t.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Funcao para enviar email na recusa do projeto')
	
	lConexao       := .F.
	lEnvio         := .F.
	lDesconexao    := .F.
	lAutOk         := .F.
	cErro_Conexao  := ""
	cErro_Envio    := ""
	cErro_Desconex := ""
	//Por Adriana em 29/05/2019 devido alteracao email sharedRelay - Inicio
	cMailServer     := Alltrim(GetMv("MV_RELSERV")) 
	cMailConta      := AllTrim(GetMv("MV_RELACNT")) 
	cMailSenha      := AllTrim(GetMv("MV_RELPSW"))  
	cMailFrom       := AllTrim(GetMv("MV_RELFROM")) 
	
	lSmtpAuth       := GetMv("MV_RELAUTH",,.t.)
	cMailCtaAut     := AllTrim(GetMv("MV_RELACNT")) 
	cMailAutSenha   := AllTrim(GetMv("MV_RELPSW"))  
	//Por Adriana em 29/05/2019 devido alteracao email sharedRelay - Fim
	
	If !IsInCallStack("ADFIN064P") // Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 30/04/2019 
	
		If Empty(cMail)
		
			Aviso("ADPRJ003P-01", "Usuแrio " + cUsrMail + " - " + UsrRetName( cUsrMail ) + " nใo possui email cadastrado! Serแ aberta uma tela para informar manualmente neste momento, mas contate TI para cadastramento no cadastro de usuแrios do sistema..." , {"OK"},, "Projetos Investimentos")		
			
			If msgYesNo("Deseja informar agora um email para envio?")
			
				oCmpPrj  := Array(01)
				oBtnPrj  := Array(02)
				cMail    := Space(100)
		
				DEFINE MSDIALOG oDlgPrj TITLE "Email - Projetos Investimentos" FROM 0,0 TO 100,350  OF oMainWnd PIXEL
		
				@ 003, 003 TO 050,165 PIXEL OF oDlgPrj
		
				@ 010,020 Say "eMails:" of oDlgPrj PIXEL
				@ 005,060 MsGet oCmpPrj Var cMail SIZE 70,12 of oDlgPrj PIXEL Valid !Empty(cMail)
		
				@ 030,015 BUTTON oBtnPrj[01] PROMPT "Confirma"     of oDlgPrj   SIZE 68,12 PIXEL ACTION oDlgPrj:End()
				@ 030,089 BUTTON oBtnPrj[02] PROMPT "Cancela"      of oDlgPrj   SIZE 68,12 PIXEL ACTION oDlgPrj:End()
		
				ACTIVATE MSDIALOG oDlgPrj CENTERED
		
			EndIf
			
		EndIf
		
	EndIf
	
	cMailDestino    := cMail
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEXECUTA conexใo ao servidor mencionado no parametroณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู       
	CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lConexao     
	
	If !lConexao
	   Get MAIL ERROR cErro_Conexao
	   Return (.f.)
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//| Se configurado, efetua a autenticacao                                            |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !lAutOk 
	   If ( lSmtpAuth ) 
	      lAutOk := MailAuth(cMailCtaAut,cMailAutSenha) 
	   Else
	      lAutOk := .T.
	   EndIf 
	EndIf         
	 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEXECUTA envio da mensagemณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//If !Empty( cANEXOS )
	//   Send Mail From cMAILCONTA to cMAILDESTINO SubJect cASSUNTO BODY cTEXTO FORMAT TEXT ATTACHMENT cANEXOS RESULT lEnvio
	//Else
	   Send Mail From cMAILFrom to cMAILDESTINO SubJect cASSUNTO BODY cTEXTO FORMAT TEXT RESULT lEnvio //Por Adriana em 29/05/2019 devido alteracao email sharedRelay
	//EndIf
	
	If !lEnvio
	   Get Mail Error cErro_Envio
	   Return (.f.)
	
	Else
		If !IsInCallStack("ADFIN064P") // Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 30/04/2019
			Aviso("ADPRJ003P-02", "Email enviado com sucesso! Para: " + AllTrim(cMAILDESTINO), {"OK"},, "Projetos Investimentos") // Chamado n. 046284
		EndIf 	
		
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEXECUTA disconexao ao servidor SMTPณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DisConnect Smtp Server Result lDesconexao   
	
	If !lDesconexao
	   Get Mail Error cErro_Desconex
	   Return (.f.)
	EndIf

Return .t.