#Include "PROTHEUS.CH" 
#Include "RWMAKE.CH"
                       
/*/
{Protheus.doc} User Function ³ADVEN058P
	Rotina de validação de campo C
	@type  Function
	@author Fernando Sigoli 
	@since 18/10/17 
	@version 01
	@history  tkt 24030  - Sigoli  - 26/11/2021 - Adicionado consistencia para nao validar o tipo de frete quando vem de integração do SF
	@history Ticket  TI     - Leonardo P. Monteiro - 26/02/2022 - Inclusão de conouts no fonte. 
*/

User Function ADVEN058P()
       
	Local lRet 		:= .F.
	Local i    		:= 0
	Local nVlPrc    := Ascan(aHeader, { |x| Alltrim(x[2]) == "C6_PRCVEN" }) 
	Local nVlTot    := Ascan(aHeader, { |x| Alltrim(x[2]) == "C6_VALOR"  }) 
	Private lSfInt	:= (IsInCallStack('U_RESTEXECUTE') .OR. IsInCallStack('RESTEXECUTE'))

	//Conout( DToC(Date()) + " " + Time() + " ADVEN058P >>> INICIO PE" )

	//U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina de validação de campo C')

	IF !lSfInt

		If aCols[1,nVlPrc] > 0 
			
			For i := 1 to Len(aCols)
				acols[i][nVlPrc] := 0
				acols[i][nVlTot] := 0 
				
				lRet := .T.
					
			Next i  
			
		EndIf
			
		If lRet
			GETDREFRESH()
			A410LinOk(oGetDad)	
		EndIf

	ENDIF

	//Conout( DToC(Date()) + " " + Time() + " ADVEN058P >>> INICIO PE" )

Return .T.
