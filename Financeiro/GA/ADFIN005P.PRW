#INCLUDE "PROTHEUS.CH" 

                                             
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADFIN005P ºAutor  ³William Costa       º Data ³  14/05/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Fonte utilizado no gatilho do campo PB3_CODRED Seq 001      º±±
±±º          ³este fonte verifica se o cliente inserido no pb3 já tem uma º±±
±±º          ³uma rede atrelado a ele se sim e informado a rede correta.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFAT                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

	
User Function ADFIN005P(cCodRede,cCgc)

	Local lVerificaCgc := .F. 
	Local cRede        := ''
	Local cNomeRed     := ''
	Local cTpRede      := ''
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	cCgc := Substring(cCgc,1,8)

	IF ALLTRIM(cCodRede) == ''
	
		M->PB3_CODRED := ''                                        
		M->PB3_NOMERE := '' 
		M->PB3_TPREDE := '' 
		ALERT("Atenção, Codigo da Rede em branco, favor verificar!")
		Return(M->PB3_CODRED)
		
	END
	
	DBSELECTAREA('SZF')
	DBGOTOP()
	DBSETORDER(1)
	IF SZF->(DBSEEK(xFilial('SZF')+ALLTRIM(cCgc), .T.))
	
		lVerificaCgc := .T. 
		cRede        := SZF->ZF_REDE
	    cNomeRed     := SZF->ZF_NOMERED      
	    cCgc         := SZF->ZF_CGCMAT
	    cTpRede      := SZF->ZF_TPREDE
        
    ENDIF    
    
    IF lVerificaCgc == .T. .AND. cCodRede <> cRede
       
  		M->PB3_CODRED := cRede
  		M->PB3_NOMERE := cNomeRed 
		M->PB3_TPREDE := cTpRede
  		
  		Alert("Já existe uma rede com esse CNPJ " + CHR(10) + CHR(13) + ;
    	      " Rede:" + cRede                    + CHR(10) + CHR(13) + ;
    	      " NOME:" + cNomeRed                 + CHR(10) + CHR(13) + ;
    	      "Favor verificar!!!")   
    	      
    ENDIF
    	
Return(M->PB3_CODRED)