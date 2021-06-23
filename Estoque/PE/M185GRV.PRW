#Include "RwMake.ch"
#Include 'Protheus.ch'
#Include "Topconn.ch"

/*/{Protheus.doc} User Function M185GRV
	Envia Workflow da baixa da requisicao ao solicitante
	@type  Function
	@author Ricardo Lima
	@since 28/11/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 035222
	@history chamado 055188 - FWNM    - 18/02/2020 - || OS 056599 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || NOVA OPERACAO VENDA
/*/
User Function M185GRV

	Local cMsg   := ""
	Local cAssunto := "Baixa de Requisição"
	Local aDadSCP  := {}
	Local cNumReq := SCP->CP_NUM
	Local citReq  := SCP->CP_ITEM
	Local cTpReq  := AllTrim(SCP->CP_XTIPO)
	local cCodUser:= ""
	Local lEnvia  := .T.

	//if cTpReq = 'T'
	If cTpReq == "T" .or. cTpReq == "M" // Chamado n. 055188 || OS 056599 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || NOVA OPERACAO VENDA - FWNM - 18/02/2020

		DbSelectArea("SCP")
		DbSetOrder(1)
		if DbSeek( xFilial("SCP") + cNumReq )
			cCodUser := RetCodUsr( FWLeUserlg("CP_USERLGI") )
			WHILE SCP->( !EOF() ) .AND. xFilial("SCP")= SCP->CP_FILIAL .AND. cNumReq = SCP->CP_NUM
				aadd( aDadSCP , { SCP->CP_PRODUTO , SCP->CP_QUANT , SCP->CP_LOCAL , SCP->CP_XLOCDES } )
				IF SCP->CP_QUANT > SCP->CP_QUJE
					lEnvia := .F.
				ENDIF
			SCP->( DbSkip() )
			END
		endif
		
		IF lEnvia
			cMsg := Gerahtm( cNumReq , aDadSCP )
			u_F050EnvWF( cAssunto , cMsg , UsrRetMail(cCodUser) , '' )
		ENDIF
 
 	endif

Return( .T. )

/*/{Protheus.doc} Static Function Gerahtm
	Gera HTML
	@type  Static Function
	@author Ricardo Lima
	@since 28/11/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function Gerahtm( cNumReq , aDadSCP )

	Local cMsg := ""

	cMsg := " <html xmlns='http://www.w3.org/1999/xhtml' xmlns:m='http://schemas.microsoft.com/office/2004/12/omml' xmlns:v='urn:schemas-microsoft-com:vml' xmlns:o='urn:schemas-microsoft-com:office:office'> "
	cMsg += " <head> "
	cMsg += " <meta http-equiv='Content-Language' content='pt-br' /> "
	cMsg += " <meta http-equiv='Content-Type' content='text/html; charset=utf-8' /> "
	cMsg += " <title>Aprovação Fornecedor</title> "
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
	cMsg += " .style4 { "
	cMsg += " 				font-family: 'Century Gothic'; "
	cMsg += " } "
	cMsg += " </style> "
	cMsg += " </head> "
	cMsg += " <body> "
	cMsg += " <p><img alt='ADORO' src='http://www.adoro.com.br/images/logo-adoro.png' style='float: left' /></p> "
	cMsg += " <p class='style1'><strong>Baixa de Requisição</strong></p> "
	cMsg += " <p class='style2'>&nbsp;<span style='font-size: 12.0pt; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; color: black; mso-ansi-language: PT-BR; mso-fareast-language: PT-BR; mso-bidi-language: AR-SA'>A " 
	cMsg += " transferência entre armazéns foi efetuada conforme requisição de número: <strong> "+ cNumReq +"</strong></span>.</p> "
	cMsg += " <table style='width: 679pt'> "
		
		FOR A:=1 TO LEN(aDadSCP)
			cMsg += " 	<tr> "
			cMsg += " 					<td>Produto</td> "
			cMsg += " 					<td>"+ aDadSCP[A][1] +"</td> "
			cMsg += " 					<td>Quantidade</td> "
			cMsg += " 					<td>"+ Transform( aDadSCP[A][2] , X3Picture( "CP_QUANT" ) ) +"</td> "
			cMsg += " 					<td>Armazém Origem</td> "
			cMsg += " 					<td>"+ aDadSCP[A][3] +"</td> "
			cMsg += " 					<td>Armazém Destino</td> "
			cMsg += " 					<td>"+ aDadSCP[A][4] +"</td> "
			cMsg += " 	</tr> "
		NEXT
	cMsg += " </table> "
	cMsg += " <p>&nbsp;</p> "
	cMsg += " <p class='style4'> "
	cMsg += " <span style='font-size: 12.0pt; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; color: black; mso-ansi-language: PT-BR; mso-fareast-language: PT-BR; mso-bidi-language: AR-SA'> "
	cMsg += " Consideramos que esse movimento é de seu conhecimento e autorização, em caso de " 
	cMsg += " divergência entrar em contato com o Almoxarifado</span></p> "
	cMsg += " <p class='style4'>Envio Automático - AD&#39;ORO</p> "
	cMsg += " </body> "
	cMsg += " </html> "

return( cMsg )