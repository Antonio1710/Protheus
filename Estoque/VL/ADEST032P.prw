#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADEST032P ºAutor  ³William Costa       º Data ³  22/10/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Programa de validaçoes para o Mestre de Inventario onde e   º±±
±±º          ³utilizado o campo CBA->CBA_XPRODV onde tem Iniciador de     º±±
±±º          ³Browse, Padrao e Gatilho do Campo                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAEST MATA030                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION ADEST032P(cParam)
	
	Local cRet := ''

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa de validaçoes para o Mestre de Inventario onde e utilizado o campo CBA->CBA_XPRODV onde tem Iniciador de Browse, Padrao e Gatilho do Campo')
	
	IF cParam == 'BROWSE'
	
		cRet := IIF(EMPTY(CBA->CBA_PROD),Posicione("SBE",1,xFilial("SBE")+CBA->CBA_LOCAL+CBA->CBA_LOCALI,"BE_CODPRO"),CBA->CBA_PROD)
    
    ENDIF
    
    IF cParam == 'PADRAO'
	
		cRet := IIF(EMPTY(CBA->CBA_PROD),Posicione("SBE",1,xFilial("SBE")+CBA->CBA_LOCAL+CBA->CBA_LOCALI,"BE_CODPRO"),CBA->CBA_PROD)
    
    ENDIF
    
    IF cParam == 'GATILHO' 		
		
		cRet := IIF(EMPTY(M->CBA_PROD),Posicione("SBE",1,xFilial("SBE")+M->CBA_LOCAL+M->CBA_LOCALI,"BE_CODPRO"),M->CBA_PROD)
		
	ENDIF
	
RETURN(cRet)