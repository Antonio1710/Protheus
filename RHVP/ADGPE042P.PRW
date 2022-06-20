#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} User Function ADGPE042P
	Envio de aviso de desligamento de funcionário para providencias da TI - chamado 047319
	@type  Function
	@author Adriana Oliveira         
	@since 20/02/2019
	@version 01
	@history 18/04/2019 - Chamado TI Adriana - Alterado intervalo de datas
	@history 18/11/2019 - Chamado TI Adriana - Alterado tabela principal query, para considerar data do cálculo e não da demissão
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
/*/

User Function ADGPE042P()
	
	Local 	_cTitulo	:= ""
	Local	_dDia		:= date()
	Local 	lAutoJob 	:= .F.
	
	Private _nDiaSemana	:= Dow(_dDia)
	Private _dDataIni	:= _dDia - 7  //Alterado intervalo de dias por Adriana em 18/04/2019
	Private _dDataFim	:= _dDia - 1
	
	If Select("SX6") == 0
	    lAutoJob := .T.
    EndIf

    if lAutoJob

		RpcClearEnv()
        RpcSetType( 3 )
	    RpcSetEnv( "01","02" ,,, "GPE")

		// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
		If !LockByName("ADGPE042P", .T., .F.)
			ConOut("[ADGPE042P] - Existe outro processamento sendo executado! Verifique...")
			RPCClearEnv()
			Return
		EndIf

    Endif

    logZBN("1")

	//@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	//FWMonitorMsg(ALLTRIM(PROCNAME()))

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Envio de aviso de desligamento de funcionário para providencias da TI - chamado 047319')
	ConOut("INICIO DO SCHEDULE ADGPE042P: " + DTOC(DATE()) + " as " + TIME())       

	if _nDiaSemana <> 1 .and. _nDiaSemana <> 7  
		TrazDados()

		DbSelectArea("TRB")
		TRB->(DBGOTOP())
		If !TRB->(EOF())
			
			_cTitulo	:= "Relação Funcionários Desligados - " + RetField('SM0',1,cEmpAnt+cFilAnt,'M0_NOME')
			EnviaEmail(_cTitulo)
		Endif
		
		TRB->( DbCloseArea() )
	Endif

	ConOut("FIM DO SCHEDULE ADGPE042P: " + DTOC(DATE()) + " as " + TIME())       

	logZBN("2")

	if lAutoJob

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Destrava a rotina para o usuário	    ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		UnLockByName("ADGPE042P")

		//Fecha o ambiente.
		RpcClearEnv()

    Endif
	
Return Nil

/*/{Protheus.doc} Static Function TrazDados
	@type  Function
	@author Adriana Oliveira         
	@since 20/02/2019
	@version 01
/*/

Static Function TrazDados()

	BeginSQL Alias "TRB"
		%NoPARSER%  
		SELECT  RG_FILIAL, 
			RG_MAT,
			RA_NOMECMP, 
			RA_CC+'- '+CTT_DESC01 RA_CCUSTO,
			RJ_DESC RA_FUNCAO,
			RA_ADMISSA, 
			RG_DATADEM,
			RG_DTGERAR
		FROM %TABLE:SRG% WITH(NOLOCK)
			INNER JOIN %TABLE:SRA% WITH(NOLOCK) ON RA_MAT = RG_MAT AND RA_FILIAL = RG_FILIAL AND %TABLE:SRA%.D_E_L_E_T_ = ''
			INNER JOIN %TABLE:CTT% WITH(NOLOCK) ON CTT_CUSTO = RA_CC AND %TABLE:CTT%.D_E_L_E_T_ = ''
			INNER JOIN %TABLE:SRJ% WITH(NOLOCK) ON RJ_FUNCAO = RA_CODFUNC AND RJ_FILIAL = RA_FILIAL AND %TABLE:SRJ%.D_E_L_E_T_ = ''
		WHERE RG_DTGERAR BETWEEN %EXP:(dTOs(_dDataIni))% AND %EXP:(dTOs(_dDataFim))% AND RG_ROTEIR = 'RES' AND %TABLE:SRG%.D_E_L_E_T_  = ' '
		ORDER BY RG_FILIAL, RA_CC, RG_MAT

	EndSQl

	BeginSQL Alias "TRB_T"
			%NoPARSER%  
			SELECT  RA_FILIAL, 
					RA_MAT,
					RA_NOMECMP, 
					RA_CC+'- '+CTT_DESC01 RA_CCUSTO,
					RJ_DESC RA_FUNCAO,
					RA_ADMISSA, 
					RA_DEMISSA
			FROM %TABLE:SRA% WITH(NOLOCK)  
				INNER JOIN %TABLE:CTT% WITH(NOLOCK) ON CTT_CUSTO = RA_CC AND %TABLE:CTT%.D_E_L_E_T_ = ''
				INNER JOIN %TABLE:SRJ% WITH(NOLOCK) ON RJ_FUNCAO = RA_CODFUNC AND RJ_FILIAL = RA_FILIAL AND %TABLE:SRJ%.D_E_L_E_T_ = ''
			WHERE RA_RESCRAI = '31' AND RA_DEMISSA BETWEEN %EXP:(dTOs(_dDataIni))% AND %EXP:(dTOs(_dDataFim))% AND %TABLE:SRA%.D_E_L_E_T_  = ' '
			ORDER BY RA_FILIAL, RA_CC, RA_MAT
	EndSQl

RETURN()    

/*/{Protheus.doc} Static Function EnviaEmail
	@type  Function
	@author Adriana Oliveira         
	@since 20/02/2019
	@version 01
/*/

STATIC FUNCTION EnviaEmail(_cTitulo)

    Local cServer      	:= Alltrim(GetMv("MV_INTSERV"))  
    Local cAccount     	:= AllTrim(GetMv("MV_INTACNT"))
    Local cPassword    	:= AllTrim(GetMv("MV_INTPSW"))
    Local cFrom        	:= AllTrim(GetMv("MV_INTACNT"))
    Local cTo          	:= AllTrim(GetMv("MV_#MAILDF"))
    Local lOk          	:= .T.  
    Local lAutOk       	:= .F. 
    Local lSmtpAuth    	:= GetMv("MV_RELAUTH",,.F.) 
    Local cSubject     	:= ""  
    Local cBody        	:= ""
    Local cAtach       	:= ""               

    cBody        := RetHTML()
    lOk          := .T.  
    lAutOk       := .F. 
	
	Conout("Autentica email ADGPE042P")
	
    Connect Smtp Server cServer Account cAccount Password cPassword Result lOk
 
    IF lAutOk == .F.
    	IF ( lSmtpAuth )
    		lAutOk := MailAuth(cAccount,cPassword)
	    ELSE
	        lAutOk := .T.
	    ENDIF
	ENDIF

	IF lOk .And. lAutOk     
	   	cSubject := _cTitulo        
	   	Conout("Envia email ADGPE042P")
		Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk                                           
	ENDIF            
	
	IF lOk
		Conout("Email enviado ADGPE042P")
		Disconnect Smtp Server
	else
		Conout("Email nao enviado ADGPE042P")
	ENDIF
				                        
 RETURN(NIL)   

/*/{Protheus.doc} Static Function RetHTML
	@type  Function
	@author Adriana Oliveira         
	@since 20/02/2019
	@version 01
/*/

Static Function RetHTML()

	Local cRet       := "" 

	cRet := "<p <span style='"
	cRet += 'font-family:"Calibri"'
	cRet += "'><b>Desligados no Periodo de " + dTOc(_dDataIni) + " a " + dTOc(_dDataFim) + ": </b>" 
	cRet += "<br>"                                                                                        
	cRet += "<b> </b>"
	cRet += "<br>"
	cRet += "<br>" 
		   
	cRet += "<table border='1'>" 
		    
	cRet += "<tr>"
	cRet += "<td>FILIAL</td>"
	cRet += "<td>CENTRO CUSTO</td>"
	cRet += "<td>MATRICULA</td>"
	cRet += "<td>NOME</td>"
	cRet += "<td>FUNCAO</td>"
	cRet += "<td>ADMISSAO</td>"
	cRet += "<td>DEMISSAO</td>"
	cRet += "<td>CALCULO</td>"
	cRet += "</tr>"
		
	While TRB->(!EOF())  
		
		cRet += "<tr>"
		cRet += "<td>" + TRB->RG_FILIAL + "</td>"
		cRet += "<td>" + TRB->RA_CCUSTO + "</td>"
		cRet += "<td>" + TRB->RG_MAT   	+ "</td>"
		cRet += "<td>" + TRB->RA_NOMECMP+ "</td>"
		cRet += "<td>" + TRB->RA_FUNCAO + "</td>"
		cRet += "<td>" + DTOC(STOD(TRB->RA_ADMISSA)) + "</td>"
		cRet += "<td>" + DTOC(STOD(TRB->RG_DATADEM)) + "</td>"
		cRet += "<td>" + DTOC(STOD(TRB->RG_DTGERAR)) + "</td>"
		cRet += "</tr>"
			
		TRB->(dbSkip())
	ENDDO

   	cRet += "</table>"   
	cRet += "<br>"

	DbSelectArea("TRB_T")
	TRB_T->(DBGOTOP())
	If !TRB_T->(EOF())

		cRet += "<b>Transferidos: </b>" 
		cRet += "<br>"                                                                                        
		cRet += "<b> </b>"
		cRet += "<br>"
		cRet += "<br>" 
		   
		cRet += "<table border='1'>" 
			    
		cRet += "<tr>"
		cRet += "<td>FILIAL</td>"
		cRet += "<td>CENTRO CUSTO</td>"
		cRet += "<td>MATRICULA</td>"
		cRet += "<td>NOME</td>"
		cRet += "<td>FUNCAO</td>"
		cRet += "<td>ADMISSAO</td>"
		cRet += "<td>TRANSFERENCIA</td>"
		cRet += "</tr>"
			
		While TRB_T->(!EOF())  
			
			cRet += "<tr>"
			cRet += "<td>" + TRB_T->RA_FILIAL + "</td>"
			cRet += "<td>" + TRB_T->RA_CCUSTO + "</td>"
			cRet += "<td>" + TRB_T->RA_MAT   	+ "</td>"
			cRet += "<td>" + TRB_T->RA_NOMECMP+ "</td>"
			cRet += "<td>" + TRB_T->RA_FUNCAO + "</td>"
			cRet += "<td>" + DTOC(STOD(TRB_T->RA_ADMISSA)) + "</td>"
			cRet += "<td>" + DTOC(STOD(TRB_T->RA_DEMISSA)) + "</td>"
			cRet += "</tr>"
				
			TRB_T->(dbSkip())
		ENDDO
	
	   	cRet += "</table>"
		cRet += "<br>"
   	
   	End   

	TRB_T->( DbCloseArea() )
	DbSelectArea("TRB")

	cRet += "<br>"
	cRet += "<br>Atenciosamente, <br><br> Tecnologia da Informação <br><br> E-mail gerado por processo automatizado."
	cRet += "<br>"
	cRet += '</span>'
	cRet += '</body>'
	cRet += '</html>'
      
Return(cRet)    	

/*/{Protheus.doc} Static Function logZBN
	@type  Function
	@author Adriana Oliveira         
	@since 20/02/2019
	@version 01
/*/

Static Function logZBN(cStatus)

	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADGPE042P'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADGPE042P'
			ZBN_DESCRI  := 'Email Lista Desligados - Semana'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'SEMANA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '11:00:00'
			ZBN_DATAPR  := dDataBase + 7
			ZBN_HORAPR  := '11:00:00'
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADGPE042P'
			ZBN_DESCRI  := 'Email Lista Desligados - Semana'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'SEMANA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '11:00:00'
			ZBN_DATAPR  := dDataBase + 7
			ZBN_HORAPR  := '11:00:00'
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return Nil
