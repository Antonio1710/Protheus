#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

USER FUNCTION A260INI()

	Local lRet := .T.
	
	IF !EMPTY(CCODDEST) // se codigo destino for diferente de vazio entra no if
	
		IF CCODORIG <> CCODDEST // se codigos de produtos forem diferentes entra no if
		
			IF __cUserId $ GETMV("MV_#USUTR2",,'001428/001908')
				
				lRet := .T.
			
			ELSE
			
				lRet := .F.
				
				MsgAlert("OL� " + Alltrim(cUserName) + ", VOC� N�O TEM PERMISS�O PARA GERAR TRANSFER�NCIAS COM PRODUTOS DIFERENTES", "A260INI-01")
				
			ENDIF
		
		ENDIF
	
	ENDIF
RETURN(lRet)