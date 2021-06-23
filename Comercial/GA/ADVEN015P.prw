#INCLUDE "Protheus.ch"
#include "rwmake.ch"   
#include "topconn.ch"                                                                 
/*/{Protheus.doc} User Function ADVEN015P
	PROGRAMA DE GATILHO PARA O PB3_CEP GATILHO 001 CARREGA TODOS
	OS CAMPOS NECESSARIOS APOS UMA PERGUNTA DE YES NO  
	SIGAFAT - ADOA002         
	@type  Function
	@author WILLIAM COSTA  
	@since  17/03/2016
	@version 01
	@history Chamado:050799 Feito para tratar o campo PB3_CEPENT no pre cadastro de clientes dia 15/08/2019.
	@history Chamado:060094 Tratamento para não alterar os dados do endereço de entrega quando o campo "Imprime Endereço Entrega" estiver como sim.
	/*/
User Function ADVEN015P()

	Private cLogradouro := ''
	Private cEstado     := ''
	Private cCodIbge    := ''
	Private cCidade     := ''  

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'PROGRAMA DE GATILHO PARA O PB3_CEP GATILHO 001 CARREGA TODOS OS CAMPOS NECESSARIOS APOS UMA PERGUNTA DE YES NO')
	
	
	IF M->PB3_EST == 'EX'
		M->PB3_CEP    := '99999999'
		M->PB3_CEPENT := M->PB3_CEP // CHAMADO 050799 ADRIANO SAVOINE 15/08/2019.
		RETURN(Space(TAMSX3("PB3_NUMERO" )[1]))  
		
	ENDIF	
	
	cLogradouro := UPPER(Posicione("JC2",1,xFilial("JC2") + M->PB3_CEP,"JC2->JC2_LOGRAD"))
	cEstado     := UPPER(Posicione("JC2",1,xFilial("JC2") + M->PB3_CEP,"JC2->JC2_ESTADO"))
	cCodIbge    := UPPER(Posicione("JC2",1,xFilial("JC2") + M->PB3_CEP,"JC2->JC2_CODCID"))
	cCidade     := UPPER(Posicione("JC2",1,xFilial("JC2") + M->PB3_CEP,"JC2->JC2_CIDADE"))
	
	IF M->PB3_EST == cEstado .AND. M->PB3_COD_MU == cCodIbge 

	    IF MSGNOYES("Deseja Carregar os seguintes dados ?"                                                            + chr(13) + chr(10) + ;
		            "ESTADO:             " + UPPER(Posicione("JC2",1,xFilial("JC2") + M->PB3_CEP,"JC2->JC2_ESTADO")) + chr(13) + chr(10) + ;
		            "CIDADE:             " + UPPER(Posicione("JC2",1,xFilial("JC2") + M->PB3_CEP,"JC2->JC2_CIDADE"))        + chr(13) + chr(10) + ;
		            "BAIRRO:            "  + UPPER(Posicione("JC2",1,xFilial("JC2") + M->PB3_CEP,"JC2->JC2_BAIRRO"))        + chr(13) + chr(10) + ;
		            "LOGRADOURO: "         + UPPER(Posicione("JC2",1,xFilial("JC2") + M->PB3_CEP,"JC2->JC2_LOGRAD"))        + chr(13) + chr(10)   ) 
		             
		    M->PB3_END    := UPPER(Posicione("JC2",1,xFilial("JC2") + M->PB3_CEP,"JC2->JC2_LOGRAD"))   
		    M->PB3_CIDACO := UPPER(Posicione("JC2",1,xFilial("JC2") + M->PB3_CEP,"JC2->JC2_CIDADE"))
		    M->PB3_BAIRRO := UPPER(Posicione("JC2",1,xFilial("JC2") + M->PB3_CEP,"JC2->JC2_BAIRRO"))
		    M->PB3_CEPCOB := M->PB3_CEP
			M->PB3_BAIRCB := UPPER(Posicione("JC2",1,xFilial("JC2") + M->PB3_CEP,"JC2->JC2_BAIRRO"))
		    M->PB3_ENDCOB := UPPER(Posicione("JC2",1,xFilial("JC2") + M->PB3_CEP,"JC2->JC2_LOGRAD"))
		    M->PB3_UFCOB  := UPPER(Posicione("JC2",1,xFilial("JC2") + M->PB3_CEP,"JC2->JC2_ESTADO"))
            M->PB3_CODMUC := Posicione("CC2",4,XFILIAL("CC2")+UPPER(ALLTRIM(M->PB3_EST))+ALLTRIM(UPPER(M->PB3_MUN)),"CC2->CC2_CODMUN")
		    M->PB3_PAIS   := IIF(M->PB3_EST <> 'EX','105','')
			
			//Everson - 30/07/2020. Chamado 060094.
			If Alltrim(cValToChar(M->PB3_IMPEND)) <> "1"
				M->PB3_CEPENT := M->PB3_CEP
				M->PB3_CODMUE := Posicione("CC2",4,XFILIAL("CC2")+UPPER(ALLTRIM(M->PB3_EST))+ALLTRIM(UPPER(M->PB3_MUN)),"CC2->CC2_CODMUN")
				M->PB3_UFENT  := UPPER(Posicione("JC2",1,xFilial("JC2") + M->PB3_CEP,"JC2->JC2_ESTADO"))
		    	M->PB3_CIDENT := UPPER(Posicione("JC2",1,xFilial("JC2") + M->PB3_CEP,"JC2->JC2_CIDADE"))
				M->PB3_ENDENT := UPPER(Posicione("JC2",1,xFilial("JC2") + M->PB3_CEP,"JC2->JC2_LOGRAD"))
		    	M->PB3_BAIREN := UPPER(Posicione("JC2",1,xFilial("JC2") + M->PB3_CEP,"JC2->JC2_BAIRRO"))

			EndIf
			//
		    
		ELSE
		
			M->PB3_CEP    := Space( TAMSX3( "PB3_CEP" )[1] )
			M->PB3_END    := Space( TAMSX3( "PB3_END" )[1] )
		    M->PB3_CIDACO := Space( TAMSX3( "PB3_CIDACO" )[1] )
		    M->PB3_BAIRRO := Space( TAMSX3( "PB3_BAIRRO" )[1] )
		    M->PB3_CEPCOB := Space( TAMSX3( "PB3_CEPCOB" )[1] )
		    M->PB3_BAIRCB := Space( TAMSX3( "PB3_BAIRCB" )[1] )
		    M->PB3_ENDCOB := Space( TAMSX3( "PB3_ENDCOB" )[1] )
		    M->PB3_PAIS   := Space( TAMSX3( "PB3_PAIS" )[1] )

			//Everson - 30/07/2020. Chamado 060094.
			If Alltrim(cValToChar(M->PB3_IMPEND)) <> "1"
		    	M->PB3_CIDENT := Space( TAMSX3( "PB3_CIDENT" )[1] )
				M->PB3_BAIREN := Space( TAMSX3( "PB3_BAIREN" )[1] )
				M->PB3_CEPENT := Space( TAMSX3( "PB3_CEPENT" )[1] )
				M->PB3_ENDENT := Space( TAMSX3( "PB3_ENDENT" )[1] )

			EndIf
			//
		    
		ENDIF	
	ELSE  
	
		IF M->PB3_EST <> cEstado 
		
			MSGSTOP("CEP fora do Estado, favor verificar!!!")
        
		ELSEIF M->PB3_COD_MU <> cCodIbge 
	
			MSGSTOP("CEP fora da cidade, favor verificar!!!")
			
		ELSE
		
			MSGSTOP("CEP não encontrado, favor abrir chamado na T.I para cadastro dos correios!!!")
			
		ENDIF				
		
			M->PB3_CEP    := Space( TAMSX3( "PB3_CEP" )[1] )
			M->PB3_END    := Space( TAMSX3( "PB3_END" )[1] )
		    M->PB3_CIDACO := Space( TAMSX3( "PB3_CIDACO" )[1] )
		    M->PB3_BAIRRO := Space( TAMSX3( "PB3_BAIRRO" )[1] )
		    M->PB3_CEPCOB := Space( TAMSX3( "PB3_CEPCOB" )[1] )
		    M->PB3_BAIRCB := Space( TAMSX3( "PB3_BAIRCB" )[1] )
		    M->PB3_ENDCOB := Space( TAMSX3( "PB3_ENDCOB" )[1] )
		    M->PB3_PAIS   := Space( TAMSX3( "PB3_PAIS" )[1] )

			//Everson - 30/07/2020. Chamado 060094.
			If Alltrim(cValToChar(M->PB3_IMPEND)) <> "1"
		    	M->PB3_CIDENT := Space( TAMSX3( "PB3_CIDENT" )[1] )
				M->PB3_BAIREN := Space( TAMSX3( "PB3_BAIREN" )[1] )
				M->PB3_CEPENT := Space( TAMSX3( "PB3_CEPENT" )[1] )
				M->PB3_ENDENT := Space( TAMSX3( "PB3_ENDENT" )[1] )

			EndIf
			//
	
	ENDIF  
	
RETURN(Space(TAMSX3("PB3_NUMERO" )[1]))  
