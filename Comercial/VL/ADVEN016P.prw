#INCLUDE "Protheus.ch"
#include "rwmake.ch"   
#include "topconn.ch"                                    

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³ADVEN016P ºAutor  ³WILLIAM COSTA       º Data ³  28/03/2016 º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³programa de validacao do campo when para verificar se habiliº±±
//±±º          ³ta ou nao os campos de endereco via quantidade de ceps tam 5º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³ SIGAFAT - ADOA002                                          º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

User Function ADVEN016P()

	Private cCodIBGE    := '' 
	Private cUF         := ''
	Private	nContCidade := 0
	Private lRet        := .F.
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'programa de validacao do campo when para verificar se habilita ou nao os campos de endereco via quantidade de ceps tam 5º')
	
	cCodIBGE    := Posicione("JC2",1,xFilial("JC2") + M->PB3_CEP,"JC2->JC2_CODCID")
	cUF         := Posicione("JC2",1,xFilial("JC2") + M->PB3_CEP,"JC2->JC2_ESTADO") 
	
	If SELECT("PB3") > 0
		if M->PB3_EST == "EX"
		   Return .T.
		endif
	Endif
	    
	IF ALLTRIM(cCodIBGE) <> ''  
	
		IF __CUSERID $ GETMV("MV_#PB3END") 
		
			lRet := .T.
			RETURN(lRet) 
			
		ENDIF	
		
		SqlCidade(cUF,cCodIBGE)
		While TRA->(!EOF())
		                  
		    nContCidade := nContCidade + 1             
		            
	    	TRA->(dbSkip())
		ENDDO
		TRA->(dbCloseArea()) 
		
		IF nContCidade <= GETMV("MV_#PB3CID")
		
			lRet := .T.
			
		ELSE  
		
			lRet := .F.
		
		ENDIF
	ENDIF	
					
RETURN(lRet)  

Static Function SqlCidade(cUF,cCodIBGE)

	BeginSQL Alias "TRA"
			%NoPARSER% 
			SELECT TOP(7) JC2_CIDADE, 
			              JC2_CODCID, 
			              JC2_ESTADO
					 FROM %Table:JC2% 
					WHERE JC2_ESTADO  = %EXP:cUF%
					  AND JC2_CODCID  = %EXP:cCodIBGE%
					  AND D_E_L_E_T_ <> '*' 
	
	EndSQl             
RETURN(NIL)   	