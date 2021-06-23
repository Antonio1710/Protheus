#INCLUDE "PROTHEUS.CH" 
#INCLUDE "XMLXFUN.CH" 
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} User Function ADFIN010P
	WebService Cisp, Analisar CNPJ's que foi feita a consulta no webservice da CISP
	@type  Function
	@author William Costa
	@since 08/04/2020
	@version 01
/*/

USER FUNCTION ADFIN010P() 

	Private aRotina      := { { OemToAnsi("Pesquisar")                     ,"AxPesqui"             , 0 , 1},; 
						      { OemToAnsi("Visualizar")                    ,"AxVisual"             , 0 , 2},; 
						      { OemToAnsi("Incluir")                       ,"AxInclui"             , 0 , 3},; 
						      { OemToAnsi("Alterar")                       ,"AxAltera"             , 0 , 4},; 
						      { OemToAnsi("Excluir")                       ,"AxDeleta"             , 0 , 5}} 
						     

	Private cCadastro    := OemToAnsi("CNPJ WEBSERVICE")  //"Criterios de Rateio					 
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	mBrowse( 6,1,22,75,"ZB6",,,,,2,)
	
RETURN (NIL)