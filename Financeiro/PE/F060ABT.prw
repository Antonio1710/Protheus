#INCLUDE "PROTHEUS.CH" 
#INCLUDE "rwmake.ch"

/*/{Protheus.doc} User Function F060ABT
	Permite considerar os abatimentos no borderô para serem enviados ao banco.
	Adoro S/A - Chamado: 041841
	@type  Function
	@author Fernando Sigoli
	@since 29/05/2018
	@history Ticket 69574   - Abel Bab - 19/04/2022 - Projeto FAI	
	/*/
User Function F060ABT()
	Local cEmpSF:= GetMv("MV_#SFEMP",,"01|") 		//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
	Local cFilSF:= GetMv("MV_#SFFIL",,"02|0B|") 	//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI

	Local lRet := .F.

	If Alltrim(cEmpAnt) $ cEmpSF .and. cFilant $ cFilSF 

		lRet := .T. //colocamos esse ponto de entrada na montagem do bordero, para nao mais levar o ab- na conta.

	EndIf           
     
Return lRet
