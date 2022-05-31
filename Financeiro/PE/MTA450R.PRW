#include "Rwmake.ch"
#include "Protheus.ch"    
#include "Topconn.ch" 
/*
±±ºPrograma  ³MTA450R        ºAutor  ³Everson      º Data ³  21/03/2018   º±±
±±ºDesc.     ³Ponto de entrada para rejeição de pedido de venda.          º±±
±±ºUso       ³Chamado 037261.                                             º±±
history Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
*/
User Function MTA450R()
									
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ	
	Local aArea:= GetArea()
	Local cEmpSF:= GetMv("MV_#SFEMP",,"01|") 		//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
	Local cFilSF:= GetMv("MV_#SFFIL",,"02|0B|") 	//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI

	//
	If !(Alltrim(cEmpAnt) == "01")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	If Findfunction("U_ADVEN050P") .And. Alltrim(cEmpAnt) $ cEmpSF .And. Alltrim(cFilAnt) $ cFilSF
		If Upper(Alltrim(cValToChar(GetMv("MV_#SFATUF"))) ) == "S"
			U_ADVEN050P(,.F.,.T., " AND C5_NUM IN ('" + SC9->C9_PEDIDO + "') AND C5_XPEDSAL <> '' " ,.F.)
		
		EndIf				

	EndIf
	
	//
	RestArea(aArea)
	
Return Nil
