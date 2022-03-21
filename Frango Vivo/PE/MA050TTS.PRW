#INCLUDE "rwmake.ch"
#INCLUDE "Protheus.ch"
/*/{Protheus.doc} User Function MA050TTS                                                      
	Grava campo customizado para integracao entre Sistemas. 
	@type  Function
	@author Mauricio - MDS TEC
	@since 05/04/2017
	@version 01
	@history Everson, 18/10/2020, Chamado 18465. Envio de informações ao barramento.                                                  
/*/
User Function MA050TTS()
Local _aArea := GetArea()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Grava campo customizado para integracao entre Sistemas')

If INCLUI					
   Reclock("SA4",.F.)
	  SA4->A4_XINTEG := "I"  &&alteracao		
   SA4->(MsUnlock())	
Endif

grvBarr() //Everson, 18/10/2020, Chamado 18465.

RestArea(_aArea)
Return(.T.)
/*/{Protheus.doc} grvBarr
    Salva o registro para enviar ao barramento.
    @type  User Function
    @author Everson
    @since 18/03/2022
    @version 01
/*/
Static Function grvBarr()

	//Variáveis.
	Local aArea		:= GetArea()
	Local cOperacao	:= ""
	Local cNumero	:= SA4->A4_COD

	If INCLUI
		cOperacao := "I"
		
	ElseIf ALTERA
		cOperacao := "A"

	Else
		RestArea(aArea)	
		Return .T.
		
	EndIf
	
	U_ADFAT27C("SA4", 1, "cadastro_de_transportadoras_protheus", cOperacao, FWxFilial("SA4") + cNumero)

	RestArea(aArea)

Return .T.
