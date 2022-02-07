#Include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CEXEXXML ³ Autor ³ Fernando Sigoli       ³ Data ³27/03/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ P.E. na exclusao de XML (Central XML).Valida se usuario    ³±±
±±³          ³ pode ou nao excluir                          		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Adoro                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Chamado: TI  - Na exclusao do XML, verifica e remove a nota da tabela  ³±±
±±³ZCW registros de notas recusadas										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß    
*/

User Function CEXEXXML()  
	
	Local aParXML	:= PARAMIXB
	Local lRetorno	:= .T.
    Local _aArea	:= getArea()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'CENTRALXML- P.E na na exclusao de XML (Central XML).Valida se usuario ')
	
	// NF-e
	If aParXML[ 01 ] == "RECNFXML" 
		
		If Alltrim(RECNFXML->XML_KEYF1) == ""
		
			dbSelectArea('ZCW')
			dbSetOrder(2)
			If ZCW->(dbSeek(xFilial('ZCW')+RECNFXML->XML_CHAVE))
				RecLock("ZCW",.F.)
				ZCW->(dbDelete())
				ZCW->(MsUnlock())
				
				//grava log
				u_GrLogZBE (Date(),;
				TIME(),;
				cUserName,;
				"EXCLUSAO RECUSA DE XML","FISCAL","CEXEXXML",;
				"NF: "+substr(RECNFXML->XML_NUMNF,4,9)+" Serie: " +substr(RECNFXML->XML_NUMNF,1,3)+ " User: " +__cUserId,;
				ComputerName(),;
				LogUserName())		
			
			Endif			
				
		Else
		
			Alert("Nota Fiscal ja classificada. Impossivel excluir XML!")
			lRetorno := .F.
		
		Endif
	
	ENDIF
	
	ZCW->(dbCloseArea())
	RestArea(_aArea)    

Return lRetorno