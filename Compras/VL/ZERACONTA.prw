#include 'rwmake.ch'
#include 'protheus.ch'

User Function ZeraConta()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

//Everson - 13/12/2017. Chamado 038631.
If IsInCallStack("U_CENTNFEXM")
	Return .T.
	
EndIf

_UPCONTA := aScan( aHeader, {|x| x[2] = "D1_CONTA" } )       
_URATEIO  := aScan( aHeader, {|x| x[2] = "D1_RATEIO" } )                             
_UPCODPRO := aScan( aHeader, {|x| x[2] = "D1_COD" } ) 

_UPITCTA := aScan( aHeader, {|x| x[2] = "D1_ITEMCTA" } )
          
If !Empty(M->D1_COD) .Or. !Empty(aCols[n][_UPCODPRO])
	aCols[n][_UPConta]:=""   	   
Endif

//-- Solicitação do Sr. Mauricio (Controladoria) para Zerar O Item de Conta Contábil - em: 30-março-2007
//If !Empty(aCols[n][_UPITCTA])
	//aCols[n][_UPITCTA]:=""   	   
//Endif

Return .T.