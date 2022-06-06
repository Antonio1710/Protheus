#INCLUDE "PROTHEUS.CH"
/*
	Projeto: Projeto SALES FORCE
	Modulo : SIGAFAT
	Fonte  : MTA456L
	@history 09/03/18 | Ricardo Lima      | Atualiza SalesForce                        | 
	@history Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
*/
User Function MTA456L()

	Local nOpc	:= PARAMIXB[1]
	Local cEmpSF:= GetMv("MV_#SFEMP",,"01|") 		//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
	Local cFilSF:= GetMv("MV_#SFFIL",,"02|0B|") 	//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI

	If Findfunction("U_ADVEN050P") .And. Alltrim(cEmpAnt) $ cEmpSF .And. Alltrim(cFilAnt) $ cFilSF //Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
		If Upper(Alltrim(cValToChar(GetMv("MV_#SFATUF")))) == "S"
	    	if nOpc == 4
		    	U_ADVEN050P(,.F.,.T., " AND C5_NUM IN ('" + SC9->C9_PEDIDO + "') AND C5_XPEDSAL <> '' " ,.T.)	
		    				
	    	ElseIf nOpc == 3
	        	U_ADVEN050P(,.F.,.T., " AND C5_NUM IN ('" + SC9->C9_PEDIDO + "') AND C5_XPEDSAL <> '' " ,.F.)	
	        				
	    	Endif
    	
    	EndIf
    	
	EndIf	

Return    
