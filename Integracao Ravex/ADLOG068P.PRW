#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"   
#INCLUDE "XMLXFUN.CH" 

/*/{Protheus.doc} User Function ADLOG068P
    Envio do Cadastro de Clientes manualmente para a Ravex
    @type  Function
    @author William Costa
    @since 11/05/2020
    @version 01
	@history Chamado T.I    - WILLIAM COSTA - 16/07/2020 - alterado o Cto e alterado o titulo do email.
    /*/

User Function ADLOG068P()

    Private aSays       := {}
	Private aButtons    := {}   
	Private cCadastro   := "Exportação Ravex Clientes"    
	Private nOpca       := 0
	Private cPerg       := 'ADLOG068P' 
    Private nTotReg     := 0
    Private nId         := 0
    Private aClientes   := {}
    
    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Envio do Cadastro de Clientes manualmente para a Ravex')
	
	//+------------------------------------------------+
	//|Cria grupo de perguntas.                        |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o usuário.     |            
	//+------------------------------------------------+
	Aadd(aSays,"Este programa tem a finalidade de enviar o Cadastro de Clientes manualmente para a Ravex " )
	Aadd(aSays,"Exportar Clientes para o Ravex" )
    
	Aadd(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	Aadd(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||EXPCLIENTE()},"Consumindo WebService","Aguarde...")}})
	Aadd(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch(cCadastro, aSays, aButtons) 

RETURN(NIL)   

STATIC FUNCTION EXPCLIENTE()

    
    Local cCliente  := ''
    Local cLoja     := ''
    Local nCont     := 0

    IF MV_PAR07 == 1 

        SqlPedidos()             
        nTotReg := Contar("TRB","!Eof()")
        ProcRegua(nTotReg)
        TRB->(DbGoTop())
        While TRB->(!EOF()) 
		
            nCont := nCont + 1 //soma linha do nó
			IncProc("Cliente: " + TRB->C5_CLIENTE + ' ' + CVALTOCHAR(nCont) + '/' +  CVALTOCHAR(nTotReg))

            cCliente := TRB->C5_CLIENTE
            cLoja    := TRB->C5_LOJACLI

            Aadd(aClientes,u_ADLOG043P(cCliente,cLoja))
				
			TRB->(dbSkip())
		ENDDO //FECHA WHILE DO TRE
		
		TRB->(dbCloseArea())

    ELSE

        SqlClientes()
        nTotReg := Contar("TRC","!Eof()")
        ProcRegua(nTotReg)
        TRC->(DbGoTop())
        While TRC->(!EOF()) 
		
			nCont := nCont + 1 //soma linha do nó
			IncProc("Cliente: " + TRC->A1_COD + ' ' + CVALTOCHAR(nCont) + '/' +  CVALTOCHAR(nTotReg))

            cCliente := TRC->A1_COD
            cLoja    := TRC->A1_LOJA
        
            Aadd(aClientes,u_ADLOG043P(cCliente,cLoja))
				
			TRC->(dbSkip())
		ENDDO //FECHA WHILE DO TRE
		
		TRC->(dbCloseArea())

    ENDIF

    IF LEN(aClientes) > 0

        cMetodo := 'Cliente'
        nId     := 1
        EmailViagem(cMetodo,nId,GetWSCError())

    ENDIF
   
RETURN(NIL)

STATIC FUNCTION MontaPerg()  
                                
	Private bValid := NIL 
	Private cF3    := NIL
	Private cSXG   := NIL
	Private cPyme  := NIL
	
	U_xPutSx1(cPerg,'01','Data Entrega de        ?','','','mv_ch01','D',08,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR01')
	U_xPutSx1(cPerg,'02','Data Entrega Ate       ?','','','mv_ch02','D',08,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR02')
	U_xPutSx1(cPerg,'03','Roteiro Ini de         ?','','','mv_ch03','C',03,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR03')
	U_xPutSx1(cPerg,'04','Roteiro Fin Ate        ?','','','mv_ch04','C',03,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR04')
    U_xPutSx1(cPerg,'05','Cliente Ini de         ?','','','mv_ch05','C',06,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR05')
	U_xPutSx1(cPerg,'06','Cliente Fin Ate        ?','','','mv_ch06','C',06,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR06')
    u_xPutSx1(cPerg,'07',"Envio dos Clientes por ?",'','','mv_ch07',"N",01,0,1,"C",bValid,cF3  ,cSXG,cPyme,'MV_PAR07',"Roteiro","Roteiro","Roteiro","1","Cliente","Cliente","Cliente","","","","","","","","","")
	
    Pergunte(cPerg,.T.)
	
RETURN(NIL)

STATIC FUNCTION EmailViagem(cMetodo,nId,cmensagem)

    Local cServer      := Alltrim(GetMv("MV_INTSERV"))  
    Local cAccount     := AllTrim(GetMv("MV_INTACNT"))
    Local cPassword    := AllTrim(GetMv("MV_INTPSW"))
    Local cFrom        := AllTrim(GetMv("MV_INTACNT"))
    Local cTo          := AllTrim(GetMv("MV_EMAILRA"))
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
                            
    _cStatEml    := cMetodo 
    cBody        := RetHTML(_cStatEml,nId,cmensagem)
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
	   cSubject := "WEBSERVICE CLIENTE COMPLETO"          
	   Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk                                           
	ENDIF            
	
	IF lOk
	   Disconnect Smtp Server
	ENDIF
				                        
    //********************************** FINAL ENVIO DE EMAIL CONFIRMANDO A GERACAO DO PEDIDO DE VENDA **************

RETURN(NIL)   

Static Function RetHTML(_cStatEml,nId,cmensagem)

	Local cRet       := "" 
	Local nContEmail := 0

	cRet := "<p <span style='"
	cRet += 'font-family:"Calibri"'
	cRet += "'><b>WEBSERVICE Cliente Manual............: </b>" 
	cRet += "<br>"                                                                                        
	cRet += "<b>STATUS.............: </b>"
	
 	IF _cStatEml == 'Autenticar' .AND. nId == 2 // Autenticacao ok
 	
	   cRet += " WEBSERVICE Cliente Manual"
	   cRet += "<br>"
	   cRet += "<br>"
	   
	   cRet += cmensagem
	
		
	ENDIF	
	
	IF _cStatEml == 'Cliente' .AND. nId == 1 // viagem ok
 	
	   cRet += " WEBSERVICE Cliente com Sucesso"
	   cRet += "<br>"
	   cRet += "<br>"
	   
	   IF LEN(aClientes) > 0
	   
	   		FOR nContEmail:=1 TO LEN(aClientes)
	   
	   			cRet += aClientes[nContEmail][1] + "<br>"
		
		   	NEXT
	   
	   ENDIF
	   	
	ENDIF	
	
	IF (_cStatEml == 'Cliente' .AND. nId == -1) .OR. ;
	   (_cStatEml == 'Cliente' .AND. nId == 0 )      // Cliente com erro
 	
	   cRet += " WEBSERVICE Cliente COM ERRO ou já existe"
	   cRet += "<br>"
	   cRet += "<br>"
	   cRet += cmensagem
	   cRet += "<br>"
	   cRet += "<br>"
	   
	   IF LEN(aClientes) > 0
	   
	   		FOR nContEmail:=1 TO LEN(aClientes)
	   
	   			cRet += aClientes[nContEmail][1] + "<br>"
		
		   	NEXT
	   
	   ENDIF

	ENDIF  
	
	cRet += "<br>"
	cRet += "<br><br>ATT, <br> TI <br><br> E-mail gerado por processo automatizado."
	cRet += "<br>"
	cRet += '</span>'
	cRet += '</body>'
	cRet += '</html>'
      
Return(cRet)

STATIC FUNCTION SqlPedidos()

	Local cDtIni := DTOS(MV_PAR01)
    Local cDtFin := DTOS(MV_PAR02)	
     
    BeginSQL Alias "TRB"
			%NoPARSER% 
				SELECT SC5.C5_CLIENTE,
					   SC5.C5_LOJACLI
				  FROM %Table:SC5% SC5 /*WITH(NOLOCK) */
		         WHERE SC5.C5_FILIAL   = %EXP:FWXFILIAL('SC5')%
				   AND SC5.C5_DTENTR  >= %EXP:cDtIni%
				   AND SC5.C5_DTENTR  <= %EXP:cDtFin%
				   AND SC5.C5_ROTEIRO >= %EXP:MV_PAR03%
				   AND SC5.C5_ROTEIRO <= %EXP:MV_PAR04%
				   AND SC5.%notDel%

				ORDER BY SC5.C5_FILIAL,SC5.C5_DTENTR,SC5.C5_ROTEIRO,SC5.C5_NUM
				
    EndSQl          

RETURN(NIL)

STATIC FUNCTION SqlClientes()

	BeginSQL Alias "TRC"
			%NoPARSER% 
				SELECT A1_COD,
					   A1_LOJA
				  FROM %Table:SA1%  SA1 /*WITH(NOLOCK) */
		         WHERE A1_FILIAL  = %EXP:FWXFILIAL('SA1')%
				   AND A1_COD    >= %EXP:MV_PAR05%
				   AND A1_COD    <= %EXP:MV_PAR06%
                   AND A1_MSBLQL  = '2'
				   AND SA1.%notDel%
				
    EndSQl           

RETURN(NIL)
