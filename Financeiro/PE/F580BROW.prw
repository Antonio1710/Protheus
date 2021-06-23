#include "rwmake.ch"

User Function F580BROW
 

//Local _Conta := GetMV("MV_CONTBLQ") 

Local _UsrRJ :=   GetMV("MV_LIBRJ") 

dbSelectArea("SE2")
dbSetOrder(19) 
//Verifica se o usuario libera titulos com recuperacao judicial ou nao
If __cUserID  $ _UsrRJ 
	// Mostra na tela somente titulos com recuperacao judicial que estao pendentes.
	Set Filter to EMPTY(E2_DATALIB) .AND. E2_SALDO > 0 .AND. !EMPTY(E2_RJ)
Else
	Set Filter to EMPTY(E2_DATALIB) .AND. E2_SALDO > 0 .AND. ALLTRIM(E2_DEBITO) $ GetMV("MV_CONTBLQ") .AND. EMPTY(E2_RJ)
End IF

RETURN