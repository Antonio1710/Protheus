#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"
#INCLUDE "AP5MAIL.CH"

/*/{Protheus.doc} User Function FA050FIN
	Central de Aprovação
	@type  Function
	@author Ricardo Lima
	@since 14/11/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history Chamado 038609
	@history Chamado 038609 - Ricardo Lima - 02/03/2018 - Grava tipo do título
	@history Chamado 038609 - Ricardo Lima - 12/03/2018 - Grava histórico de integração do SAG
	@history Chamado 038609 - Ricardo Lima - 24/08/2018 - Desabilitado envio de email, o envio será periódico
	@history Chamado 044314 - Ricardo Lima - 21/12/2018 - Anexo da rotina de fechamento de frete
	@history Chamado 053347 - FWNM         - 29/11/2019 - 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL
	@history Chamado 053993 - Abel Babini  - 14/02/2020 - 053993 || OS 055409 || FISCAL || VALERIA || 8389 || TITULO - ICMS ST
/*/
User Function FA050FIN

	Local lRet := .T.
	Local cForn		:= M->E2_FORNECE
	Local cLoj		:= M->E2_LOJA 
	Local cDescrSAG := IIF(!EMPTY(M->E2_XRECORI)," ,Integração SAG","") // Ricardo Lima - 12/03/18
	Local cQuery	:= ""
	Local cTpDivf	:= ""
	Local cAssunto	:= "Central de Aprovação"
	Local cMensagem	:= ""
	Local _aArea    := GetArea()        
	Local cmaildest := GetMv("MV_XFA050F")
	Local nLimForPA := 0
	Local lEnvWFCA  := SuperGetMv( "MV_#FA5ENV" , .F. , .T. ,  )
	Local cTpE2Blq	:= GetMv("MV_#TPE2BQ",, 'PA,TX' )//Chamado 053993 - Abel Babini  - 14/02/2020 - 053993 || OS 055409 || FISCAL || VALERIA || 8389 || TITULO - ICMS ST

	// if cEmpAnt = '01' .or. cEmpAnt = '02' // Chamado n. 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL - FWNM - 29/11/2019
	cAssunto := cAssunto + " - " + AllTrim(SM0->M0_NOME)
	//

	//IF M->E2_TIPO = 'PA'//Chamado 053993 - Abel Babini  - 14/02/2020 - 053993 || OS 055409 || FISCAL || VALERIA || 8389 || TITULO - ICMS ST
	IF Alltrim(M->E2_TIPO) $ cTpE2Blq

		cTpDivf	:= "000001"

		cQuery := " SELECT A2_COD, A2_LOJA, A2_XLIMCRD, SUM(E2_SALDO) E2_SALDO "
		cQuery += " FROM "+ RetSqlName("SE2") +" E2 "
		cQuery += " INNER JOIN "+ RetSqlName("SA2") +" A2 ON A2_COD = E2_FORNECE AND A2_LOJA = E2_LOJA AND A2.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE E2_FORNECE = '"+ cForn +"' AND E2_LOJA = '"+ cLoj +"' "
		cQuery += " AND E2_TIPO = 'PA' AND E2.D_E_L_E_T_ = ' ' "   // E2_FILIAL = '"+ FwxFilial("SE2") +"' AND  
		cQuery += " GROUP BY A2_COD, A2_LOJA, A2_XLIMCRD " 

		If Select("TMPSA2") > 0
			TMPSA2->(DbCloseArea())		
		EndIf
		
		TcQuery cQuery New Alias "TMPSA2"
		nLimForPA := 0 // TMPSA2->A2_XLIMCRD  // Ricardo Lima - 05/04/18
		
		
		IF ( M->E2_VALOR + TMPSA2->E2_SALDO ) > nLimForPA
			// Gera Divergencia para aprovacao.
			SE2->E2_XDIVERG := 'S'
			
			DbSelectArea("SX5")
			DbSetOrder(1)
			DbSeek( FwxFilial("SX5") + 'Z9' + cTpDivf )
		
			// gera registro para aprovacao		
			RecLock("ZC7",.T.)
				ZC7->ZC7_FILIAL := FwxFilial("SE2")
				ZC7->ZC7_PREFIX	:= SE2->E2_PREFIXO
				ZC7->ZC7_NUM   	:= SE2->E2_NUM
				ZC7->ZC7_PARCEL	:= SE2->E2_PARCELA
				ZC7->ZC7_CLIFOR	:= SE2->E2_FORNECE
				ZC7->ZC7_LOJA  	:= SE2->E2_LOJA
				ZC7->ZC7_TIPO   := SE2->E2_TIPO // RICARDO LIMA - 02/03/18
				ZC7->ZC7_VLRBLQ	:= SE2->E2_VALOR
				ZC7->ZC7_TPBLQ 	:= cTpDivf
				ZC7->ZC7_DSCBLQ	:= Alltrim(SX5->X5_DESCRI) + cDescrSAG // Ricardo Lima - 12/03/18
				ZC7->ZC7_RECPAG := "P"	 
				ZC7->ZC7_USRALT := __cUserID						 
				ZC7->ZC7_DATA   := SE2->E2_VENCREA
			MSUnlock()
		ENDIF	

		// Envio de Pendencia Para o Aprovador não Ausente
		c2Query := " SELECT ZC3_CODUSU, ZC3_NOMUSU, ZCF_NIVEL, ZCF_CODIGO, ZC3_APRATV "
		c2Query += " FROM "+RetSqlName("ZC3")+" ZC3 "
		c2Query += " INNER JOIN "+RetSqlName("ZCF")+" ZCF ON ZC3_CODUSU=ZCF_APROVA AND ZCF.D_E_L_E_T_ = ' ' "
		c2Query += " WHERE ZCF_CODIGO = '"+cTpDivf+"' AND ZC3_APRATV <> '1' AND ZC3.D_E_L_E_T_ = ' ' "
		c2Query += " ORDER BY ZCF_NIVEL "

		If Select("TMPZC3") > 0
			TMPZC3->(DbCloseArea())
		EndIf

		TcQuery c2Query New Alias "TMPZC3"

		IF !EMPTY(TMPZC3->ZC3_CODUSU)
			cmaildest := AllTrim(UsrRetMail( TMPZC3->ZC3_CODUSU ))
		ENDIF 

		cMensagem := u_WGFA050FIN( FwxFilial("SE2") , SE2->E2_PREFIXO , SE2->E2_NUM , SE2->E2_PARCELA , SE2->E2_FORNECE , SE2->E2_LOJA , SE2->E2_VALOR , Alltrim(SX5->X5_DESCRI)+cDescrSAG , 'F' )

		//u_F050EnvWF( cAssunto , cMensagem , cmaildest , '' )
		// Ricrdo Lima - 24/08/18
		If lEnvWFCA
			U_F50En2WF( cmaildest , '' , cAssunto , cMensagem , '' )
		Endif

	ENDIF	
	
	//endif
	
	RestArea(_aArea)

Return(lRet)

/*/{Protheus.doc} User Function WGFA050FIN
	Central de Aprovação
	@type  Function
	@author Ricardo Lima
	@since 14/11/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history Chamado 038609
/*/
User Function WGFA050FIN( FilialSE2 , E2PREFIXO , E2NUM , E2PARCELA , E2FORNECE , E2LOJA , E2VALOR , X5DESCRI , cTpbsc )

	Local cMsg := ""
	local cNomFor := ""

	if cTpbsc = 'F'
		cNomFor := GetAdvFVal( "SA2", "A2_NOME", xFilial("SA2") + E2FORNECE + E2LOJA , 1, "" )
	else
		cNomFor := GetAdvFVal( "SA1", "A1_NOME", xFilial("SA1") + E2FORNECE + E2LOJA , 1, "" )
	endif

	cMsg := " <head> "
	cMsg += " <meta http-equiv='Content-Language' content='pt-br' /> "
	cMsg += " <meta http-equiv='Content-Type' content='text/html; charset=utf-8' /> "
	cMsg += " <title>Central de Aprovação - "+AllTrim(SM0->M0_NOME)+"</title> "
	cMsg += " <style type='text/css'> "
	cMsg += " .style1 { "
	cMsg += " 				font-family: 'Century Gothic'; "
	cMsg += " 				text-align: center; "
	cMsg += " 				text-decoration: underline; "
	cMsg += " 				font-size: x-large; "
	cMsg += " } "
	cMsg += " .style2 { "
	cMsg += " 				text-align: left; "
	cMsg += " 				font-family: 'Century Gothic'; "
	cMsg += " } "
	cMsg += " td "
	cMsg += " 	{border-style: none; "
	cMsg += " 				border-color: inherit; "
	cMsg += " 				border-width: medium; "
	cMsg += " 				padding-top:1px; "
	cMsg += " 					padding-right:1px; "
	cMsg += " 					padding-left:1px; "
	cMsg += " 					color:gray; "
	cMsg += " 					font-size:9.0pt; "
	cMsg += " 					font-weight:400; "
	cMsg += " 					font-style:normal; "
	cMsg += " 					text-decoration:none; "
	cMsg += " 					font-family:'Century Gothic', sans-serif; "
	cMsg += " 					text-align:general; "
	cMsg += " 					vertical-align:middle; "
	cMsg += " 					white-space:nowrap; "
	cMsg += " 	} "
	cMsg += " .style3 { "
	cMsg += " 				border-collapse: collapse; "
	cMsg += " 				margin-bottom: 0px; "
	cMsg += " } "
	cMsg += " .style4 { "
	cMsg += " 				font-family: 'Century Gothic'; "
	cMsg += " } "
	cMsg += " </style> "
	cMsg += " </head> "
	cMsg += " <body> "
	cMsg += " <p><img alt='ADORO' src='http://www.adoro.com.br/images/logo-adoro.png' style='float: left' /></p> "
	cMsg += " <p class='style1'><strong>Central de Aprovação - "+AllTrim(SM0->M0_NOME)+"</strong></p> "
	cMsg += " <p class='style2'>Caro Aprovador, Segue pendências na Central de Aprovação.</p> "
	cMsg += " <table border='0' cellpadding='0' cellspacing='0' width='1305' style='width: 979pt' class='style3'> "
	cMsg += " 				<tr height='24' style='mso-height-source: userset; height: 18.0pt'> "
	cMsg += " 								<td>Prefixo</td> "
	cMsg += " 								<td>Numero Titulo</td> "
	cMsg += " 								<td>Parcela</td> "
	cMsg += " 								<td>Fornecedor</td> "
	cMsg += " 								<td>Loja</td> "
	cMsg += " 								<td>Nome</td> "
	cMsg += " 								<td>Valor - R$</td> "
	cMsg += " 								<td>Tipo do Bloqueio</td> "
	cMsg += " 				</tr> "
	cMsg += " 				<tr height='24' style='mso-height-source: userset; height: 18.0pt'> "
	cMsg += " 								<td>"+ E2PREFIXO +"</td> "
	cMsg += " 								<td>"+ E2NUM +"</td> "
	cMsg += " 								<td>"+ E2PARCELA +"</td> "
	cMsg += " 								<td>"+ E2FORNECE +"</td> "
	cMsg += " 								<td>"+ E2LOJA  +"</td> "
	cMsg += " 								<td>"+ cNomFor +"</td> "
	cMsg += " 								<td>"+ Transform( E2VALOR , X3Picture( "E2_SALDO" ) ) +"</td> " 
	cMsg += " 								<td>"+ X5DESCRI +"</td> "
	cMsg += " 				</tr> "
	cMsg += " </table> "
	cMsg += " <p>&nbsp;</p> "
//	cMsg += " <p class='style4'>Envio Automático - AD&#39;ORO ( Central de Aprovação )</p> "
	cMsg += " <p class='style4'>Envio Automático - "+AllTrim(SM0->M0_NOME)+" ( Central de Aprovação )</p> "
	cMsg += " </body> "
	cMsg += " </html> "
	
Return( cMsg )

/*/{Protheus.doc} User Function F050EnvWF
	Central de Aprovação
	@type  Function
	@author Ricardo Lima
	@since 14/11/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history Chamado 038609
/*/
User Function F050EnvWF(cAssunto,cMensagem,email,coemail)
                                                                                                                               
	 Local lOk           := .T.
	 Local cBody         := cMensagem
	 Local cErrorMsg     := ""
	 Local aFiles        := {}
	 Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	 Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
	 Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
	 Local cFrom         := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
	 Local cTo           := email
	 Local cCC           := ""
	 Local CC            := coemail
	 Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)
	 Local lAutOk        := .F.
	 Local cAtach        := ""   
	 Local cSubject      := ""
	
	//Assunto do e-mail.
	 cSubject := cAssunto
	 
	 //Conecta ao servidor SMTP.
	 Connect Smtp Server cServer Account cAccount  Password cPassword Result lOk
	 
	 If !lAutOk
	    If ( lSmtpAuth )
	       lAutOk := MailAuth(cAccount,cPassword)	       
	    Else
	       lAutOk := .T.	       
	    EndIf	    
	 EndIf	 
	 If lOk .And. lAutOk   	    
	    //Envia o e-mail.    
	    Send Mail From cFrom To cTo CC cCC Subject cSubject Body cBody ATTACHMENT cAtach Result lOk  	     
	    //Tratamento de erro no envio do e-mail.          
	    If !lOk
	       Get Mail Error cErrorMsg
	       ConOut("3 - " + cErrorMsg)	       
	    EndIf	    
	 Else
	    Get Mail Error cErrorMsg
	    ConOut("4 - " + cErrorMsg)	    
	 EndIf	 
	 If lOk
	    Disconnect Smtp Server	    
	 EndIf	

Return Nil

/*/{Protheus.doc} User Function F50EN2WF
	Central de Aprovação
	@type  Function
	@author Ricardo Lima
	@since 14/11/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history Chamado 038609
/*/
User Function F50En2WF(cPara,cCopia,cAssunto,cMensagem,cArquivo)

	Local cMsg := ""
	Local xRet
	Local oServer, oMessage
	Local lMailAuth	:= SuperGetMv("MV_RELAUTH",,.F.)
	Local nPorta := SuperGetMv("MV_PORSMTP",,"587") //Por Adriana em 24/05/2019 //587
	Local w := 0 // Ricardo Lima-21/12/2018-CH:044314|anexo da rotina de fechamento de frete
			
	Private cMailConta	:= NIL
	Private cMailServer	:= NIL
	Private cMailSenha	:= NIL

	cMailConta  := If(cMailConta  == NIL,GETMV("MV_RELACNT"),cMailConta)
	cMailServer := If(cMailServer == NIL,GETMV("MV_#RELSER"),cMailServer) //Por Adriana em 24/05/2019 substituido MV_RELSERV por MV_#RELSER pois tem que ser sem porta
	cMailSenha  := If(cMailSenha  == NIL,GETMV("MV_RELPSW") ,cMailSenha)
   	oMessage:= TMailMessage():New()
	
	oMessage:Clear()
	oMessage:cDate	  := cValToChar( Date() )
	oMessage:cFrom 	  := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM //cMailConta
	oMessage:cTo 	  := cPara
	oMessage:cCC      := cCopia
	oMessage:cSubject := cAssunto
	oMessage:cBody 	  := cMensagem
	
	// Ricardo Lima-21/12/2018-CH:044314|anexo da rotina de fechamento de frete
	If !Empty(cArquivo)
		if VALTYPE(cArquivo) = 'A'
			For w:=1 to Len(cArquivo)
				xRet := oMessage:AttachFile( cArquivo[w][1] )
				if xRet < 0
					cMsg := "O arquivo " + cArquivo[w][1] + " não foi anexado!"
					ConOut( cMsg )
				endif
			Next
		Else
			xRet := oMessage:AttachFile( cArquivo )
			if xRet != 0
				cMsg := "O arquivo " + cArquivo + " não foi anexado!"
				ConOut( cMsg )
				return
			endif
		Endif
	Endif

	oServer := tMailManager():New()
	oServer:SetUseTLS( .F. )
   
	xRet := oServer:Init( "", cMailServer, cMailConta, cMailSenha, 0, nPorta )
	if xRet != 0
		ConOut("O servidor SMTP não foi inicializado: " + oServer:GetErrorString( xRet ) )
		return
	endif

	xRet := oServer:SetSMTPTimeout( 60 ) //Indica o tempo de espera em segundos.
	if xRet != 0
		ConOut("Não foi possível definir tempo limite para 60 Segundos ")
	endif

	xRet := oServer:SMTPConnect()
	if xRet != 0
		ConOut("Não foi possível conectar ao servidor SMTP: " + oServer:GetErrorString( xRet ))
		return
	endif

	if lMailAuth
		xRet := oServer:SmtpAuth( cMailConta, cMailSenha )
		if xRet != 0
			cMsg := "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet )
			ConOut( cMsg )
			oServer:SMTPDisconnect()
			return
		endif
   	Endif
	
	xRet := oMessage:Send( oServer )
	if xRet != 0
		ConOut("Não foi possível enviar mensagem: " + oServer:GetErrorString( xRet ))
	endif

	xRet := oServer:SMTPDisconnect()
	if xRet != 0
		ConOut("Não foi possível desconectar o servidor SMTP: " + oServer:GetErrorString( xRet ))
	endif

return