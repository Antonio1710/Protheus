#INCLUDE "Protheus.ch"
#INCLUDE "AP5MAIL.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADCOM004P บAutor  ณWILLIAM COSTA       บ Data ณ  11/11/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ PROGRAMA CHAMADO A PARTIR DO PONTO DE ENTRADA MTA103MNU.PRWบฑฑ
ฑฑบ          ณ ONDE SE A NOTA FOR DEVOLUCAO E  CLICAR NO BOTAO ACOES RELA บฑฑ
ฑฑบ          ณ CIONADAS VAO MARCAR O CAMPO F1_REFATUR COM 'S' E MANDAR    บฑฑ
ฑฑบ          ณ EMAIL PARA O COMERCIAL SABER QUE CHEGO UMA NOTA DE REFATUR บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAdriana    ณ24/05/2019ณTI-Devido a substituicao email para shared      บฑฑ
ฑฑบ           ณ          ณrelay, substituido MV_RELACNT p/ MV_RELFROM     บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ADCOM004P()    

	PRIVATE Area         := GetArea() 
	PRIVATE cServer      := Alltrim(GetMv("MV_RELSERV"))  
    PRIVATE cAccount     := AllTrim(GetMv("MV_RELACNT"))
    PRIVATE cPassword    := AllTrim(GetMv("MV_RELPSW"))
    PRIVATE cFrom        := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
    PRIVATE cTo          := AllTrim(GetMv("MV_EMAILRE"))
    PRIVATE lOkEmail     := .T.  
    PRIVATE lAutOk       := .F. 
    PRIVATE lSmtpAuth    := GetMv("MV_RELAUTH",,.F.) 
    PRIVATE cSubject     := ""  
    PRIVATE cBody        := ""
    PRIVATE cAtach       := ""               
    PRIVATE _cStatEml    := ""
    PRIVATE _cNota       := ""
    PRIVATE cF1_FORNECE  := ""
    PRIVATE cF1_LOJA     := ""
    PRIVATE cNOMFOR      := ""
    PRIVATE _cStatEml    := ""  
    PRIVATE n            := 0
    PRIVATE cDescCod     := ''
    PRIVATE _cChave      := SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//| Por Wiliam Costa                           |
	//|                                            |
	//ณTRATAMENTO REFATURAMENTO    - INICIO        ณ
	//|                                            |
	//| Envio de Email para informar que           |
	//|tem uma nota de devolu็ใo para refaturamento|
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู              
	IF SF1->F1_TIPO=="D"  
	
		RecLock("SF1",.F.)
				
			SF1->F1_REFATUR := 'S'
		
		SF1->( MsUnLock() ) // Confirma e finaliza a opera็ใo
	
		IF SF1->F1_REFATUR=="S"  
		
			//********************************** INICIO ENVIO DE EMAIL CONFIRMANDO A GERACAO DO PEDIDO DE VENDA **************
            _cNota       := SF1->F1_DOC
            _cSerie      := SF1->F1_SERIE
            _cStatEml    := "OK" 
            cF1_FORNECE  := SF1->F1_FORNECE
            cF1_LOJA     := SF1->F1_LOJA
            cNOMFOR      := POSICIONE("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NREDUZ") 
            cBody        := RetHTML(_cNota,cF1_FORNECE,cF1_LOJA,cNOMFOR,_cStatEml)
            Connect Smtp Server cServer Account cAccount Password cPassword Result lOkEmail
			
			IF lAutOk == .F.
			   IF ( lSmtpAuth )
			      lAutOk := MailAuth(cAccount,cPassword)
			   ELSE
			      lAutOk := .T.
			   ENDIF
			ENDIF
			
			IF lOkEmail .And. lAutOk     
			   cSubject := "NOTA DE DEVOLUวรO Nบ " + _cNota + " INCLUIDO COM SUCESSO, LIBERADO PARA REFATURAMENTO"          
			   Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOkEmail                                           
			ENDIF            
			
			IF lOkEmail
			   Disconnect Smtp Server
			ENDIF
							                        
            //********************************** FINAL ENVIO DE EMAIL CONFIRMANDO A GERACAO DO PEDIDO DE VENDA **************      
	    ENDIF //fecha if do campo de refaturamento
	ENDIF //fecha if do tipo de devolu็ใo
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTRATAMENTO REFATURAMENTO    - FIM   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู               
	
	RestArea(Area) 
Return                      

Static Function RetHTML(_cNota,cF1_FORNECE,cF1_LOJA,cNOMFOR,_cStatEml)

	PRIVATE cRet := ""
	
	cRet := "<p <span style='"
	cRet += 'font-family:"Calibri"'
	cRet += "'><b>Nota de Devolu็ใo............: </b>" + _cNota
	cRet += "<br>"                                                                                        
	
	//_cDtEntr := DTOC(dDataBase)
	
	cRet += "<b>DT EMISSAO....: </b>" + DTOC(dDataBase)
	cRet += "<br>"
	
	cRet += "<b>FORNECEDOR............: </b>" + cF1_FORNECE + " - " + cF1_LOJA + " - " + cNOMFOR 
	cRet += "<br>"
	                                        
	cRet += "<b>STATUS.............: </b>"
	
 	If _cStatEml = "OK"
	   cRet += " NOTA DE DEVOLUวรO PARA REFATURAMENTO CRIADA COM SUCESSO."
	   cRet += "<br>"
	   cRet += "<br>" 
	   
	   SD1->(dbSetOrder(1))
		SD1->(dbSeek(_cChave))
		While SD1->(!Eof()) .and. _cChave == SD1->(D1_FILIAL + D1_DOC+ D1_SERIE + D1_FORNECE + D1_LOJA)
		    n        := n + 1
		    cDescCod := Posicione("SB1",1,xFilial("SB1") + SD1->D1_COD, "B1_DESC")
			If n <> 1
	          cRet += "<br><br>"
	       Endif         
	       cRet += "<b>Item Nบ.: </b>" + SD1->D1_ITEM + "<b> , Produto.: </b>" + SD1->D1_COD + "<b> - </b>" + cDescCod + "<b> , Valor.: R$</b>" + str(SD1->D1_TOTAL)
		
		   SD1->(dbSkip())
		EndDo
	ENDIF
	
    cRet += "<br>"
	cRet += "<br><br>ATT, <br> TI <br><br> E-mail gerado por processo automatizado."
	cRet += "<br>"
	cRet += '</span>'
	cRet += '</body>'
	cRet += '</html>'

Return(cRet)