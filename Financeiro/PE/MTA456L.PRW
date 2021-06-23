#INCLUDE "PROTHEUS.CH"

// ##########################################################################################
// Projeto: Projeto SALES FORCE
// Modulo : SIGAFAT
// Fonte  : MTA456L
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 09/03/18 | Ricardo Lima      | Atualiza SalesForce                        | 
// ---------+-------------------+--------------------------------------------+---------------
//          |                   |                                            |
// ---------+-------------------+--------------------------------------------+---------------
// #########################################################################################

User Function MTA456L()

	Local nOpc	:= PARAMIXB[1]

	If Findfunction("U_ADVEN050P") .And. cEmpAnt == "01" .And. cFilAnt == "02"
		If Upper(Alltrim(cValToChar(GetMv("MV_#SFATUF")))) == "S"
	    	if nOpc == 4
		    	U_ADVEN050P(,.F.,.T., " AND C5_NUM IN ('" + SC9->C9_PEDIDO + "') AND C5_XPEDSAL <> '' " ,.T.)	
		    				
	    	ElseIf nOpc == 3
	        	U_ADVEN050P(,.F.,.T., " AND C5_NUM IN ('" + SC9->C9_PEDIDO + "') AND C5_XPEDSAL <> '' " ,.F.)	
	        				
	    	Endif
    	
    	EndIf
    	
	EndIf	

Return    