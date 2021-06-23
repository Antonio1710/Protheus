#Include "RwMake.ch"
#Include 'Protheus.ch'
#Include "Topconn.ch"
// ############################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : M020INC
// -----------+-------------------+--------------------------------------------+---------------
// Data       | Autor             | Descricao                                  | Chamado
// -----------+-------------------+--------------------------------------------+---------------
// 21/11/17   | Ricardo Lima      | Envia Alerta de novo cadastro de Fornecedor| 038606
//            |                   | para Aprovacao para os usuario cadastrados |              
// -----------+-------------------+--------------------------------------------+---------------
// 15/02/2019 | Ricardo Lima      | Habilita rotina por parametro para empresas| 047230
// -----------+-------------------+--------------------------------------------+---------------
// 16/10/2019 | Adriana Oliveira  | Ajuste emails Pre-Cadastro p/ SAFEGG       | 052327
// -----------+-------------------+--------------------------------------------+---------------
// ############################################################################################


User Function M020INC()

Local cMensagem := ""
Local cAssunto  := "Fornecedor Bloqueado na empresa: " +Alltrim(FWGrpName(cempant)) // Por Adriana Oliveira em 16/10/2019 - Chamado 052327
Local cQuery	 := ""
Local cDestMail := ""
Local lEnvWFCA  := SuperGetMv( "MV_#FA5ENV" , .F. , .T. ,  )
Local lFilPreC := SuperGetMv( "MV_#PRECAD" , .F. , .F. ,  ) //Ricardo Lima-15/02/2019
 
 //Ricardo Lima-15/02/2019
if lFilPreC
 IF M->A2_MSBLQL = '1'

	cMensagem := u_MntMsc( M->A2_COD , M->A2_LOJA , M->A2_NOME , M->A2_CGC , M->A2_INSCR , M->A2_END , M->A2_BAIRRO , M->A2_MUN , M->A2_USERINC , M->A2_DTINC , "I" , "" )
	
	cQuery := " SELECT * "
	cQuery += " FROM "+ RetSqlName("ZC3") +" ZC3 "
	cQuery += " WHERE ZC3_TABBLF = '000002' " 
	cQuery += " AND ZC3.D_E_L_E_T_ = ' ' "
	If Select("M020INCT") > 0
		M020INCT->(DbCloseArea())		
	EndIf	
	TcQuery cQuery New Alias "M020INCT"
	
	WHILE M020INCT->( !EOF() )
		cDestMail += AllTrim(UsrRetMail( M020INCT->ZC3_CODUSU )) + ";"
		M020INCT->( DbSkip() )
	END  
	 
	cDestMail := SUBSTR(cDestMail , 1 , LEN(cDestMail) -1 )
	IF !EMPTY(cDestMail) 
		If lEnvWFCA
			u_F050EnvWF( cAssunto , cMensagem , cDestMail , '' )
		EndIf
	ENDIF

 ENDIF
endif

Return Nil

// ##########################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : M020INC
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 21/11/17 | Ricardo Lima      | Envia Alerta de novo cadastro de Fornecedor| 038606
//          |                   | para Aprovacao para os usuario cadastrados |              
// ---------+-------------------+--------------------------------------------+---------------
//          |                   |                                            |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
User Function MntMsc( A2COD , A2LOJA , A2NOME , A2CGC , A2INSCR , A2END , A2BAIRRO , A2MUN , A2USERINC , A2DTINC , OPC , cMsgRc )

Local cMsg := ""

cMsg := " <html xmlns='http://www.w3.org/1999/xhtml'> "
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
cMsg += " .style3 { "
cMsg += " 				border-collapse: collapse; "
cMsg += " 				margin-bottom: 0px; "
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
cMsg += " .style5 { "
cMsg += " 				color: gray; "
cMsg += " 				font-size: 9.0pt; "
cMsg += " 				font-weight: 400; "
cMsg += " 				font-style: normal; "
cMsg += " 				text-decoration: none; "
cMsg += " 				font-family: 'Century Gothic', sans-serif; "
cMsg += " 				text-align: general; "
cMsg += " 				vertical-align: middle; "
cMsg += " 				white-space: nowrap; "
cMsg += " 				border-style: none; "
cMsg += " 				border-color: inherit; "
cMsg += " 				border-width: medium; "
cMsg += " 				padding-left: 1px; "
cMsg += " 				padding-right: 1px; "
cMsg += " 				padding-top: 1px; "
cMsg += " } "
cMsg += " </style> "
cMsg += " </head> " 
cMsg += " <body> " 
//cMsg += " <p><img alt='"+Alltrim(SM0->M0_NOME)+"' src='http://www.adoro.com.br/images/logo-adoro.png' style='float: left' /></p> " // Alterado por Adriana em 16/10/2019 - Chamado 052327
//cMsg += " <p><img alt='ADORO' src='http://www.adoro.com.br/images/logo-adoro.png' style='float: left' /></p> "
if OPC = "R"
 cMsg += " <p class='style1'><strong>Recusa de Cadastro de Fornecedor</strong></p> "
 cMsg += " <p class='style2'>Segue Recusa do Cadastro de Fornecedor com Pendências.</p>"
ELSEif OPC = "A"
 cMsg += " <p class='style1'><strong>Cadastro de Fornecedor</strong></p> "
 cMsg += " <p class='style2'>Segue Ativação do Cadastro de Fornecedor</p>"
ELSEif OPC = "F"
 cMsg += " <p class='style1'><strong>Cadastro de Fornecedor</strong></p> "
 cMsg += " <p class='style2'>Aviso de Alteração Fiscal do Cadastro de Fornecedor</p>" 
ELSEif OPC = "P"
 cMsg += " <p class='style1'><strong>Cadastro de Fornecedor</strong></p> "
 cMsg += " <p class='style2'>Aviso de Pendencia Fiscal do Cadastro de Fornecedor</p>" 
else
 cMsg += " <p class='style1'><strong>Aprovação Fornecedor</strong></p> "
 cMsg += " <p class='style2'>Caro Aprovador, Segue Cadastro de Fornecedor com Pendências para Aprovação.</p> "
endif 
cMsg += " <table border='0' cellpadding='0' cellspacing='0' width='1305' style='width: 979pt' class='style3'> "
cMsg += " 				<tr height='24' style='mso-height-source: userset; height: 18.0pt'> "
cMsg += " 								<td>Cod. Fornecedor</td> "
cMsg += " 								<td>Loja</td> "
cMsg += " 								<td>Nome Fornecedor</td> "
cMsg += " 								<td>CNPJ</td> "
cMsg += " 								<td>IE</td> "
cMsg += " 								<td>End.</td> "
cMsg += " 								<td>Bairro</td> "
cMsg += " 								<td>Cidade</td> "
cMsg += " 								<td>Usuário Inclusão</td> "
cMsg += " 								<td>Data Inclusão</td> "
if OPC = "R"
 cMsg += " 								<td>Obs da Recusa</td> "
endif
if OPC = "I"
 cMsg += " 								<td>Obs Pré-Cadastro</td> "
endif
cMsg += " 				</tr> "
cMsg += " 				<tr height='24' style='mso-height-source: userset; height: 18.0pt'> "
cMsg += " 								<td>"+ A2COD     +"</td> "
cMsg += " 								<td>"+ A2LOJA    +"</td> "
cMsg += " 								<td>"+ A2NOME    +"</td> "
cMsg += " 								<td>"+ A2CGC     +"</td> "
cMsg += " 								<td>"+ A2INSCR   +"</td> "
cMsg += " 								<td>"+ A2END     +"</td> "
cMsg += " 								<td>"+ A2BAIRRO  +"</td> "
cMsg += " 								<td>"+ A2MUN     +"</td> "
cMsg += " 								<td>"+ A2USERINC +"</td> "
cMsg += " 								<td>"+ DTOC(A2DTINC)   +"</td> "
if OPC = "R"
cMsg += " 								<td>"+ cMsgRc+"</td> "
endif
if OPC = "I"
cMsg += " 								<td>"+ cMsgRc+"</td> "
endif
cMsg += " 				</tr> "
cMsg += " </table> "
cMsg += " <p>&nbsp;</p> " 

//Ricardo Lima-15/02/2019
cMsg += " <p class='style4'>Envio Automático </p> " //Alterado por Adriana 16/10/2019 - Chamado 052327
cMsg += " </body> "
cMsg += " </html> "

Return(cMsg)
