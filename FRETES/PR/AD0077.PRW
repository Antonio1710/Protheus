#include "rwmake.ch"
// Rotina desenvolvida por Gustavo em 23/09/03

User Function AD0077() 

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cidade')

_sAlias := Alias()
_nOrder := IndexOrd()
_sRec   := Recno()


//Posiciona no Registro da Cidade
_cCidade  := M->ZV8_CIDADE

dbSelectArea("ZV8")// Cidades
dbsetorder(2)
If dbSeek (xFilial("ZV8")+ _cCidade)
	Alert("CIDADE JA CADASTRADA !!! FAVOR VERIFICAR !!!")
	_xRet	:=	.F.
Else
	_xRet	:=	.T.
Endif
Return(_xRet) 
