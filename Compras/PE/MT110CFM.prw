#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT110CFM  º Autor ³ WILLIAM COSTA      º Data ³  25/05/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida o usuário após Aprovação, Rejeição ou Bloqueio      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Compras.                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION MT110CFM()

	Local aArea      := GetArea()
	Local ExpC1      := PARAMIXB[1]     
	Local ExpN1      := PARAMIXB[2]
	Local cAssunto   := 'Solicitação de Compra Rejeita Nº ' + ExpC1
	Local cMensagem  := ''
	Local aDadosSC1  := {}
	Local aDadoSC1   := {}
	Local cUserSC    := ''
	Local cComprador := ''
	Local cUserComp  := ''
	Local cNomeComp  := ''  
	Local cMotivo    := Space(115)
		
	IF ExpN1 == 2
	
		DEFINE MSDIALOG oDlg FROM	18,1 TO 80,550 TITLE "ADORO S/A  -  Motivo da Reijação SC: " + ExpC1 PIXEL
		  
			@  1, 3 	TO 28, 242 OF oDlg  PIXEL
			If File("adoro.bmp")
			@ 3,5 BITMAP oBmp FILE "adoro.bmp" OF oDlg NOBORDER SIZE 25,25 PIXEL 
			oBmp:lStretch:=.T.
			EndIf
			@ 05, 37	SAY "Motivo:" SIZE 24, 7 OF oDlg PIXEL 
			@ 12, 37  	MSGET cMotivo  SIZE	200, 9 OF oDlg PIXEL Valid !Empty(cMotivo)    
			DEFINE SBUTTON FROM 02,246 TYPE 1 ACTION(oDlg:End()) ENABLE OF oDlg
			
		
		ACTIVATE MSDIALOG oDlg CENTERED
	
		SqlSC1(FWFILIAL("SC1"),ExpC1)
	    	    
    	While TRC->(!EOF())
    	
    		cUserSC    := TRC->C1_USER
    		cComprador := TRC->C1_CODCOMP
	        
	        Aadd(aDadoSC1,TRC->C1_PRODUTO)
	        Aadd(aDadoSC1,TRC->C1_DESCRI)
	        Aadd(aDadoSC1,TRC->C1_QUANT)          
            Aadd(aDadosSC1,aDadoSC1) 
            TRC->(dbSkip())
		ENDDO
		TRC->(dbCloseArea())
		
		SqlSY1(FWFILIAL("SC1"),cComprador)
	    	    
    	While TRD->(!EOF())
	         
	        cUserComp  := TRD->Y1_USER
	        cNomeComp  := TRD->Y1_NOME          
           
            TRD->(dbSkip())
		ENDDO
		TRD->(dbCloseArea())
		
		cMensagem := Gerahtm(ExpC1,aDadosSC1,cNomeComp,cMotivo)
		u_F050EnvWF( cAssunto , cMensagem , UsrRetMail(cUserSC) + ';' +  UsrRetMail(cUserComp), '')
	
	ENDIF
	
	RestArea(aArea)
	
RETURN(NIL)

Static Function Gerahtm(cNumSC,aDadosSC1,cNomeComp,cMotivo)

	Local cMsg  := ""
	Local nCont := 0
	
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
	//cMsg += " <p><img alt='ADORO' src='http://www.adoro.com.br/images/logo-adoro.png' style='float: left' /></p> "
	cMsg += " <p class='style1'><strong>Solicitacao de Compra Rejeitada</strong></p> "
	cMsg += " <p class='style2'>&nbsp;<span style='font-size: 12.0pt; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; color: black; mso-ansi-language: PT-BR; mso-fareast-language: PT-BR; mso-bidi-language: AR-SA'>A " 
	cMsg += " Solicitação de Compra de número: <strong> "+ cNumSC +"</strong> , foi reijatada pelo comprador: <strong> "+ cNomeComp +"</strong>  </span>.</p> "
	cMsg += " <table style='width: 679pt'> "
		
		FOR nCont:=1 TO LEN(aDadosSC1)
			cMsg += " 	<tr> "
			cMsg += " 					<td>Produto</td> "
			cMsg += " 					<td>"+ aDadosSC1[nCont][1] + ' - ' + aDadosSC1[nCont][2]+"</td> "
			cMsg += " 					<td>Quantidade</td> "
			cMsg += " 					<td>"+ cValToChar(aDadosSC1[nCont][3]) +"</td> "
			cMsg += " 					<td>Motivo Rejeição</td> "
			cMsg += " 					<td>"+ cMotivo +"</td> "  
			cMsg += " 	</tr> "
		NEXT
		
	cMsg += " </table> "
	cMsg += " <p>&nbsp;</p> "
	cMsg += " <p class='style4'> "
	cMsg += " <span style='font-size: 12.0pt; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; color: black; mso-ansi-language: PT-BR; mso-fareast-language: PT-BR; mso-bidi-language: AR-SA'> "
	cMsg += " Consideramos que esse movimento é de seu conhecimento e autorização, em caso de " 
	cMsg += " divergência entrar em contato com Compras</span></p> "
	cMsg += " <p class='style4'>Envio Automático - AD&#39;ORO</p> "
	cMsg += " </body> "
	cMsg += " </html> "

RETURN(cMsg)

Static Function SqlSC1(cFil,cNumSc)

	BeginSQL Alias "TRC"
			%NoPARSER%  
			SELECT C1_PRODUTO,C1_DESCRI,C1_QUANT,C1_CODCOMP,C1_USER
			  FROM %TABLE:SC1%
			 WHERE C1_FILIAL   = %EXP:cFil%
			   AND C1_NUM      = %EXP:cNumSc%
			   AND D_E_L_E_T_ <> '*'
	EndSQl             
RETURN(NIL)

Static Function SqlSY1(cFil,cComprador)

	BeginSQL Alias "TRD"
			%NoPARSER%  
			SELECT Y1_FILIAL,Y1_COD,Y1_NOME,Y1_USER
			  FROM %TABLE:SY1%
			 WHERE Y1_FILIAL   = %EXP:cFil% 
			   AND Y1_COD      = %EXP:cComprador%
			   AND D_E_L_E_T_ <> '*'
	EndSQl             
RETURN(NIL)