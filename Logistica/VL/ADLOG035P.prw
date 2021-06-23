#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE "TOPCONN.CH"

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³ADLOG035P ºAutor  ³WILLIAM COSTA       º Data ³  08/03/2018 º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³Validacao de campo ZVC_XCREDE para identificar se já existe º±±
//±±º          ³uma credencial para outro caminhoneiro                      º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³ SIGAEST                                                    º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

USER FUNCTION ADLOG035P()

	Local lRet        := .T.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Validacao de campo ZVC_XCREDE para identificar se já existe uma credencial para outro caminhoneiro')
	
	IF M->ZVC_XCREDE > 0 //SO VERIFICA SE A CREDENCIAL FOR MAIOR QUE ZERO PORQUE TEM VARIAS QUE O CAMPO ESTA ZERO. 
	
		SqlBuscaCredencial(M->ZVC_XCREDE)
	        
		While TRC->(!EOF())
		
			// *** SE ENTRAR AQUI EXISTE UMA CREDENCIAL IGUAL PARA O OUTRO CAMINHONEIRO   ***//
		
			MsgStop("OLÁ " + Alltrim(cUserName) + ", Existe uma credencial igual para outro caminhoneiro Verifique." + CHR(13) + CHR(10) + ;
			        "Nome Caminhoneiro: " + TRC->ZVC_MOTORI, "ADLOG035P-1 - Validação de Campo ZVC_XCREDE")
			        
			lRet := .F.
	           
	        TRC->(dbSkip())
		ENDDO
		TRC->(dbCloseArea())
	
	ENDIF
			
RETURN(lRet)

Static Function SqlBuscaCredencial(cXcrede)

	Local cFilZVC := FwXfilial("ZVC")

	BeginSQL Alias "TRC"
			%NoPARSER%  
			SELECT TOP(1) ZVC_MOTORI,
			               ZVC_CPF,
			               ZVC_XCREDE 
			  FROM %Table:ZVC% WITH(NOLOCK)
			  WHERE ZVC_FILIAL = %EXP:cFilZVC%
			    AND ZVC_XCREDE = %EXP:cXcrede%
			    AND D_E_L_E_T_ <> '*'
    
	EndSQl            
	
RETURN(NIL)
