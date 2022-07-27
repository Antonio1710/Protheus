#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} User Function ADGPE025P
	Integracao com o sistema DIMEP de catracas Integracao da Estrutura Organizacional da Empresa Usando o linked Server para DIMEP, Integra Empresa,Filial e Centro de Custo
	@type  Function
	@author William Costa
	@since 24/05/2017
	@version 01
	@history TICKET  224    - William Costa - 11/11/2020 - Alteração do Fonte na parte de Funcionários, trocar a integração do Protheus para a Integração do RM
	@history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud 
	@history ticket  14365  - Fernando Macieir- 19/05/2021 - Novo Linked Server (de VPSRV17 para DIMEP)
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	@history Ticket 77205   - ADRIANO SAVOINE - 27/07/2022 - Alterado o Link de DIMEP para DMPACESSO.
/*/
USER FUNCTION ADGPE025P() 

	// @history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud
	Private cLinked := "" 
	Private cSGBD   := "" 
	//

	Private cEmpresaOld := ''
	Private cIntregou   := ''  
	Private cTexto      := ''  
	
	// ****************************INICIO PARA RODAR COM SCHEDULE**************************************** //	
	RPCClearEnv()
	RPCSetType(3)  //Nao consome licensas
    RpcSetEnv("01","02",,,,GetEnvServer(),{ }) //Abertura do ambiente em rotinas automáticas              
	// ****************************FINAL PARA RODAR COM SCHEDULE**************************************** //	

	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 29/06/2020
	If !LockByName("ADGPE025P", .T., .F.)
		ConOut("[ADGPE025P] - Existe outro processamento sendo executado! Verifique...")
		RPCClearEnv()
		Return
	EndIf

	// ****************************INICIO INTEGRACAO FUNCIONARIOS PROTHEUS x DIMEP**************************************** //	
	
	// @history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud
	cLinked := GetMV("MV_#RMLINK",,"RM") 
	cSGBD   := GetMV("MV_#RMSGBD",,"CCZERN_119204_RM_PD")

	// @history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	//FWMonitorMsg(ALLTRIM(PROCNAME()))
	
	ConOut("INICIO DO SCHEDULE ADGPE025P" + '||' + DTOC(DATE()) + '||' + TIME())                                      
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Integracao com o sistema DIMEP de catracas Integracao da Estrutura Organizacional da Empresa Usando o linked Server para DIMEP, Integra Empresa,Filial e Centro de Custo ')

	logZBN("1") //Log início.

	DimepEmpresa()
	DimepFilial()
	DimepCentroDeCusto()
	DimepCarregaTabUsu() 

	logZBN("2") //Log fim.

	ConOut("FINAL DO SCHEDULE ADGPE025P" + '||' + DTOC(DATE()) + '||' + TIME())
	// ***********INICIO Limpa o ambiente, liberando a licença e fechando as conexões********************* //	        
	RpcClearEnv() 
	// ***********FINAL Limpa o ambiente, liberando a licença e fechando as conexões********************** //	

	//Destrava a rotina para o usuário	    
	
	UnLockByName("ADGPE025P")

RETURN(NIL)
                    
STATIC FUNCTION DimepEmpresa()  

	cEmpresaOld := ''
	
	// ***** INICIO QUANDO NAO EXISTE EMPRESA **** //
	DBSELECTAREA("SM0")
	SM0->(DbGoTop())
	SM0->(DBSETORDER(1))
	While SM0->(!EOF()) 
	
		IF cEmpresaOld <> SM0->M0_CODIGO
	      
			SqlVEmpresaDimep(SM0->M0_CODIGO)
			
			IF TRB->(EOF())        
			    
				// Integra Estrutura Organizacional - EMPRESA
				INTESTRUTURA(SM0->M0_CODIGO,SM0->M0_NOME,SM0->M0_CGC,SM0->M0_NOMECOM,'','NULL',0)   
				cTexto := '1 Log Empresa:' + 'Cod Empresa: ' + SM0->M0_CODIGO + ' - ' + SM0->M0_NOME
				GERALOG(SM0->M0_CODFIL,cTexto, 'Integrou: ' + IIF(ALLTRIM(cIntregou)== '', 'OK',cIntregou))
				
			ENDIF
			TRB->(dbCloseArea())       
			
			cEmpresaOld := SM0->M0_CODIGO
	        
	   	ENDIF
   		
   		SM0->(dbSkip())
					
	ENDDO
	//SM0->(dbCloseArea()) nao pode fechar o SM0 da erro WiLL
	// ***** FINAL QUANDO NAO EXISTE EMPRESA **** //                                             
	
RETURN(NIL)

STATIC FUNCTION	DimepFilial()

	// ***** INICIO QUANDO NAO EXISTE FILIAL **** //
	DBSELECTAREA("SM0")
	SM0->(DbGoTop())
	SM0->(DBSETORDER(1))
	
	While SM0->(!EOF()) 
	
	    SqlVEmpresaDimep(SM0->M0_CODIGO)
		
		IF TRB->(!EOF())  
		                 
			SqlVFilialDimep(TRB->ESTRUTURA,SM0->M0_CODFIL)
			IF TRC->(EOF())  
			
				// Integra Estrutura Organizacional - EMPRESA
				INTESTRUTURA(SM0->M0_CODFIL,SM0->M0_FILIAL,'NULL','NULL','NULL',TRB->ESTRUTURA,1)   
				
				cTexto := '2 Log Filial:' + 'Cod Filial: ' + SM0->M0_CODFIL + ' - ' + SM0->M0_FILIAL
				GERALOG(SM0->M0_CODFIL,cTexto, 'Integrou: ' + IIF(ALLTRIM(cIntregou)== '', 'OK',cIntregou))
				
			ENDIF
			TRC->(dbCloseArea())       
		
		ENDIF
		TRB->(dbCloseArea())       
		SM0->(dbSkip())
					
	ENDDO
	
	// ***** FINAL QUANDO NAO EXISTE FILIAL **** //

RETURN(NIL)

STATIC FUNCTION	DimepCentroDeCusto() 

	// ***** INICIO QUANDO NAO EXISTE FILIAL **** //
	DBSELECTAREA("SM0")
	SM0->(DbGoTop())
	SM0->(DBSETORDER(1))
	
	While SM0->(!EOF()) 
	
	    SqlVEmpresaDimep(SM0->M0_CODIGO)
		
		IF TRB->(!EOF())  
		                 
			SqlVFilialDimep(TRB->ESTRUTURA,SM0->M0_CODFIL)
			IF TRC->(!EOF())  
			
				SqlVCentroCusto()
			    While TRF->(!EOF())
			    
			    	SqlVCCDimep(TRC->ESTRUTURA, TRF->CTT_CUSTO) 
			    	IF TRG->(EOF())
						
					//Integra Estrutura Organizacional - EMPRESA
					INTESTRUTURA(TRF->CTT_CUSTO,TRF->CTT_DESC01,'NULL','NULL','NULL',TRC->ESTRUTURA,1)
					cTexto := '3 Log Centro Custo:'                                    + ;
					          'Cod Filial: ' + SM0->M0_CODFIL + ' - ' + SM0->M0_FILIAL + ;
					          'Cod CC: '     + TRF->CTT_CUSTO + ' - ' + TRF->CTT_DESC01
					          
					GERALOG(SM0->M0_CODFIL,cTexto, 'Integrou: ' + IIF(ALLTRIM(cIntregou)== '', 'OK',cIntregou))
					
					ENDIF
					TRG->(dbCloseArea())       
				
					TRF->(dbSkip())
					
				ENDDO
				TRF->(dbCloseArea())       
				
			ENDIF
			TRC->(dbCloseArea())       
		
		ENDIF
		TRB->(dbCloseArea())       
		SM0->(dbSkip())
		
	ENDDO
	
	// ***** FINAL QUANDO NAO EXISTE FILIAL **** //

RETURN(NIL) 

STATIC FUNCTION DimepCarregaTabUsu()

	SqlVEstrutura()                 
	While TRD->(!EOF()) 
						
		SqlVUSUSISESTRUTURA(TRD->ESTRUTURA)
		IF TRE->(EOF())  
		
		    //Integra USUARIO SISTEMA ESTRUTURA
			INTUSUSISESTRUTURA(TRD->ESTRUTURA)
			
			cTexto := '4 Log Integra USUARIO SISTEMA ESTRUTURA:'                                    + ;
			          'Cod Estrutura: ' + CVALTOCHAR(TRD->ESTRUTURA)
			          
			GERALOG(SM0->M0_CODFIL,cTexto, 'Integrou: ' + IIF(ALLTRIM(cIntregou)== '', 'OK',cIntregou))
				      
			
		ENDIF
		TRE->(dbCloseArea())       
		TRD->(dbSkip())
	ENDDO
	TRD->(dbCloseArea())

RETURN(NIL) 

STATIC FUNCTION GERALOG(cFil,cTexto,cParam)

	DbSelectArea("ZBE")
		Reclock("ZBE",.T.)
			ZBE->ZBE_FILIAL	:= cFil
			ZBE->ZBE_DATA 	:= Date()
			ZBE->ZBE_HORA 	:= cValToChar(Time())
			ZBE->ZBE_USUARI := cUserName
			ZBE->ZBE_LOG 	:= cTexto
			ZBE->ZBE_MODULO := "SIGAGPE"
			ZBE->ZBE_ROTINA := "ADGPE025P"
			ZBE->ZBE_PARAME := cParam
		MsUnlock()
	ZBE->(DbCloseArea())
	
RETURN(NIL) 

Static Function logZBN(cStatus)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADGPE025P'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADGPE025P'
			ZBN_DESCRI  := 'Carrega empresa,filial e centro de custo para Dimep'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'DIA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '01:00:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '01:00:00'
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADGPE025P'
			ZBN_DESCRI  := 'Carrega empresa,filial e centro de custo para Dimep'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'DIA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '01:00:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '01:00:00'
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return Nil

Static Function SqlVEmpresaDimep(cEmpresa)                          

	BeginSQL Alias "TRB"
			%NoPARSER%  
			SELECT CD_ESTRUTURA_ORGANIZACIONAL AS ESTRUTURA,
			       NU_ESTRUTURA,
			       NM_ESTRUTURA,
			       NU_CNPJ,
			       DS_RAZAO_SOCIAL,
			       DS_CEI,
			       CD_ESTRUTURA_RELACIONADA,
			       TP_ESTRUTURA
			  FROM [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] WITH (NOLOCK)
			  WHERE NU_ESTRUTURA = %EXP:cEmpresa%
			    AND TP_ESTRUTURA = '0'
			    AND NU_CNPJ <> 0
     
	EndSQl             
RETURN(NIL)            

Static Function SqlVFilialDimep(nEstOrganizacional, cFil)

	BeginSQL Alias "TRC"
			%NoPARSER%  
			SELECT CD_ESTRUTURA_ORGANIZACIONAL AS ESTRUTURA,
			       NU_ESTRUTURA,
			       NM_ESTRUTURA,
			       NU_CNPJ,
			       DS_RAZAO_SOCIAL,
			       DS_CEI,
			       CD_ESTRUTURA_RELACIONADA,
			       TP_ESTRUTURA
			  FROM [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] WITH (NOLOCK)
			  WHERE CD_ESTRUTURA_RELACIONADA = %EXP:nEstOrganizacional%
			    AND NU_ESTRUTURA             = %EXP:cFil%
                AND TP_ESTRUTURA             = '1'
                
	EndSQl             
RETURN(NIL)

Static Function SqlVEstrutura()

	BeginSQL Alias "TRD"
			%NoPARSER%  
			SELECT CD_ESTRUTURA_ORGANIZACIONAL AS ESTRUTURA,
			       NU_ESTRUTURA,
			       NM_ESTRUTURA,
			       NU_CNPJ,
			       DS_RAZAO_SOCIAL,
			       DS_CEI,
			       CD_ESTRUTURA_RELACIONADA,
			       TP_ESTRUTURA
			  FROM [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] WITH (NOLOCK)
			 
                
	EndSQl             
RETURN(NIL)            

Static Function SqlVUSUSISESTRUTURA(nEstrutura)

	BeginSQL Alias "TRE"
			%NoPARSER%  
			SELECT CD_ESTRUTURA_ORGANIZACIONAL AS ESTRUTURA,
			       CD_USUARIO
			  FROM [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORG_USUARIO_SISTEMA] WITH (NOLOCK)
			  WHERE CD_ESTRUTURA_ORGANIZACIONAL = %EXP:nEstrutura%
			    
    EndSQl             
RETURN(NIL)

Static Function SqlVCentroCusto()

	// @history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud

	/*
	BeginSQL Alias "TRF"
			%NoPARSER%  
			SELECT CTT_CUSTO,
                   CTT_DESC01 
              FROM CTT010
			 WHERE CTT_BLOQ    = '2'
			   AND D_E_L_E_T_ <> '*'
			   AND (CTT_CUSTO IN(SELECT DISTINCT NROCENCUSTOCONT COLLATE Latin1_General_CI_AS
								   FROM [VPSRV16].[CORPORERM].[DBO].[PSECAO]
                                  WHERE NROCENCUSTOCONT IS NOT NULL)
	            OR CTT_CUSTO IN(SELECT ZVC_CC 
						          FROM ZVC010
						          WHERE ZVC_CC     <> ''
						            AND D_E_L_E_T_ <> '*' )
		        OR CTT_CUSTO IN(SELECT DA4_XCC 
		  			              FROM DA4010
						         WHERE DA4_XCC    <> '' 
						           AND D_E_L_E_T_ <> '*'))
			                       
			ORDER BY CTT_CUSTO                       
                
	EndSQl             
	*/
	
	TRF := GetNextAlias()

	//cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", '

	cQuery := " 		SELECT CTT_CUSTO,
    cQuery += "               CTT_DESC01 
    cQuery += "          FROM CTT010
	cQuery += "		 WHERE CTT_BLOQ    = '2'
	cQuery += "		   AND D_E_L_E_T_ <> '*'
	cQuery += "		   AND (CTT_CUSTO IN(SELECT DISTINCT PSECAO.NROCENCUSTOCONT COLLATE Latin1_General_CI_AS
	cQuery += "		 FROM [" + cLinked + "].[" + cSGBD + "].[DBO].[PSECAO] PSECAO (NOLOCK)
    cQuery += "                              WHERE PSECAO.NROCENCUSTOCONT IS NOT NULL)
	cQuery += "            OR CTT_CUSTO IN(SELECT ZVC_CC 
	cQuery += "					          FROM ZVC010
	cQuery += "					          WHERE ZVC_CC     <> ''
	cQuery += "					            AND D_E_L_E_T_ <> '*' )
	cQuery += "	        OR CTT_CUSTO IN(SELECT DA4_XCC 
	cQuery += "	  			              FROM DA4010
	cQuery += "					         WHERE DA4_XCC    <> '' 
	cQuery += "					           AND D_E_L_E_T_ <> '*'))
			                       
	cQuery += "		ORDER BY CTT_CUSTO                       

	//cQuery += " ')

	tcQuery cQuery New Alias TRF

RETURN(NIL)

Static Function SqlVCCDimep(nFil, cCc)

	BeginSQL Alias "TRG"
			%NoPARSER%  
			SELECT CD_ESTRUTURA_ORGANIZACIONAL AS ESTRUTURA,
			       NU_ESTRUTURA,
			       NM_ESTRUTURA,
			       NU_CNPJ,
			       DS_RAZAO_SOCIAL,
			       DS_CEI,
			       CD_ESTRUTURA_RELACIONADA,
			       TP_ESTRUTURA
			  FROM [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] WITH (NOLOCK)
			  WHERE CD_ESTRUTURA_RELACIONADA = %EXP:nFil%
			    AND NU_ESTRUTURA             = %EXP:cCc%
                AND TP_ESTRUTURA             = '1'
                
	EndSQl             
RETURN(NIL)            

Static Function INTESTRUTURA(cNumEstrutura,cNomeEsturtura,nCnpj,cRazaoSocial,cCei,nEstRelacional,nTpEstrutura)   

    cQuery := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[ESTRUTURA_ORGANIZACIONAL] " 
	cQuery += "(NU_ESTRUTURA, " 
	cQuery += "NM_ESTRUTURA, " 
	cQuery += "NU_CNPJ, " 
	cQuery += "DS_RAZAO_SOCIAL, " 
	cQuery += "DS_CEI, " 
	cQuery += "CD_ESTRUTURA_RELACIONADA, " 
	cQuery += "TP_ESTRUTURA " 
	cQuery += ") "
	cQuery += "VALUES ('" + cNumEstrutura                                                 + "',"  // NU_ESTRUTURA
	cQuery += "'"         + cNomeEsturtura                                                + "'," // NM_ESTRUTURA
	cQuery += ""          + CVALTOCHAR(nCnpj)                                             + ","  // NU_CNPJ
	cQuery += ""          + IIF(cRazaoSocial == 'NULL', 'NULL', "'" + cRazaoSocial + "'") + "," // DS_RAZAO_SOCIAL
	cQuery += ""          + IIF(cCei == 'NULL', 'NULL', "'" + cCei + "'")                 + ","  // DS_CEI
	cQuery += ""          + CVALTOCHAR(nEstRelacional)                                    + ","  // CD_ESTRUTURA_RELACIONADA
	cQuery += ""          + CVALTOCHAR(nTpEstrutura)                                      + " "  // TP_ESTRUTURA
    cQuery += ") " 
    
    If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() INTESTRUTURA:"
	EndIf        
	
RETURN(NIL)  

Static Function INTUSUSISESTRUTURA(nEstrutura)   	      	 	  

	cQuery := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[ESTRUTURA_ORG_USUARIO_SISTEMA] " 
	cQuery += "(CD_ESTRUTURA_ORGANIZACIONAL, " 
	cQuery += "CD_USUARIO " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + CVALTOCHAR(nEstrutura) + "'," // nEstrutura
	cQuery += ""                + '1'                    + ""   // Usuario Admin
    cQuery += ") " 

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTUSUSISESTRUTURA: " 
	EndIf        
	
RETURN(NIL) 	      	 	  
