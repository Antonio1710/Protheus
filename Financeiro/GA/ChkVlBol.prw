#include "protheus.ch"   
#include "rwmake.ch"

User Function ChkVlBol() 
        barra := ""
        valor := ""
        barra := LTRIM(RTRIM(M->E2_CODBAR))
        valor := val(SubStr(barra,10,8)+"."+SubStr(barra,18,2))
        sld := E2_SALDO +E2_ACRESC - E2_DECRESC
		
		U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
		
        IF valor > 0
	        IF  sld <> valor
	               IF !MsgBox('Existe diferença entre o valor do boleto e o saldo à pagar do título. Deseja continuar ?', " ALERTA " , "YESNO")
	                  M->E2_CODBAR := ""
	               END IF
	        END IF
	    END IF    
Return M->E2_CODBAR