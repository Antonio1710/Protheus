#INCLUDE  "PROTHEUS.CH"
#INCLUDE  "FILEIO.CH"
#INCLUDE "AP5MAIL.CH"  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQDOVMAIL  บAutor  ณWILLIAM COSTA       บ Data ณ  02/02/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConfigura็ใo do Layout de E-Mail para documento com a  data บฑฑ
ฑฑบ          ณde validade 'Vencida/ภ Vencer', podendo ser elaborado em    บฑฑ
ฑฑบ          ณtexto comum ou em formato HTML.                             บฑฑ
ฑฑบ          ณDesenvolvimento de Workflow do vencimento do documento      บฑฑ
ฑฑบ          ณtamb้m para o aprovador.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAQDO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAdriana     ณ24/05/2019ณTI-Devido a substituicao email para shared     บฑฑ
ฑฑบ            ณ          ณrelay, substituido MV_RELACNT p/ MV_RELFROM    บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
//
*/

USER FUNCTION QDOVMAIL()  

	Local aArea       := {}
	Local aMsg        := PARAMIXB[1]
	Local cMsg        := ''
	Local nCnt        := 0
	Local nLenDoc     := 0
	Private cDoc      := ''
	Private cMsgOri   := '' 
	Private cEmailApr := ''
	Private cTitulo   := ''
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Configura็ใo do Layout de E-Mail para documento com a  data de validade Vencida/ภ Vencer, podendo ser elaborado em texto comum ou em formato HTML. Desenvolvimento de Workflow do vencimento do documento tamb้m para o aprovador.')
	
	aArea   := Getarea() 
	cTitulo := aMsg[1][1] 
	cMsg    := aMsg[1][2] 
	cMsgOri := aMsg[1][2]   
	
	FOR nCnt := 600 TO LEN(cMsg)
	
		IF SUBSTR(cMsg,nCnt,17)  == 'Documento</b><br>'
		
			nLenDoc := nCnt
			EXIT
		
		ENDIF
	NEXT nCnt
     
	cMsg    := SUBSTR(cMsg,nLenDoc + 17,100)   
	nLenDoc := AT(' ' ,cMsg) 
	cDoc    := SUBSTR(cMsg,1,nLenDoc)
	
	SqlGeral()
	
	DBSELECTAREA("TRB")
		TRB->(DBGOTOP())
			WHILE TRB->(!EOF())    
			    
			    cEmailApr := TRB->QAA_EMAIL
				
			    TRB->(dbSkip())    
			ENDDO //end do while TRB
	TRB->( DBCLOSEAREA() ) 
	
	EnviaEmail()
		
	Restarea(aArea) 

RETURN(aMsg)       

Static Function SqlGeral()     

	BeginSQL Alias "TRB"
			%NoPARSER% 
			SELECT QAA.QAA_EMAIL 
			  FROM %Table:QDH% QDH, %Table:QD0% QD0, %Table:QAA% QAA
			 WHERE QDH.QDH_DOCTO = %exp:cDoc%
			   AND QDH.QDH_DOCTO = QD0.QD0_DOCTO
			   AND QD0.QD0_AUT   = 'A'
			   AND QD0.QD0_MAT   = QAA.QAA_MAT 
			   AND QDH.%notDel%
			   AND QD0.%notDel%
			   AND QAA.%notDel%
			   
	EndSQl          

Return(nil) 



Static Function EnviaEmail()

	Local cServer      := Alltrim(GetMv("MV_RELSERV"))  
    Local cAccount     := AllTrim(GetMv("MV_RELACNT"))
    Local cPassword    := AllTrim(GetMv("MV_RELPSW"))
    Local cFrom        := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
    Local cTo          := cEmailApr
    Local lOk          := .T.  
    Local lAutOk       := .F. 
    Local lSmtpAuth    := GetMv("MV_RELAUTH",,.F.) 
    Local cSubject     := ""  
    Local cBody        := ""
    Local cAtach       := ""               
    Local _cStatEml    := ""
    Local _cPedido     := ""
    Local _cStatEml    := ""
    
    
    //********************************** INICIO ENVIO DE EMAIL CONFIRMANDO A GERACAO DO PEDIDO DE VENDA **************
                            
    
    _cStatEml    := "OK" 
    cBody        := cMsgOri
    lOk          := .T.  
    lAutOk       := .F. 
    
    Connect Smtp Server cServer Account cAccount Password cPassword Result lOk
                        
    IF lAutOk == .F.
		IF ( lSmtpAuth )
	    	lAutOk := MailAuth(cAccount,cPassword)
	   	ELSE
	    	lAutOk := .T.
	   	ENDIF
	ENDIF
	
	IF lOk .And. lAutOk     
	   cSubject := "Protheus SIGAQDO " + cTitulo
	   Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk                                           
	ENDIF            
	
	IF lOk
	   Disconnect Smtp Server
	ENDIF
				                        
    //********************************** FINAL ENVIO DE EMAIL CONFIRMANDO A GERACAO DO PEDIDO DE VENDA **************
Return()
