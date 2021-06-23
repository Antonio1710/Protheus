#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00



User Function Pagide()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Realiza consula ao Pedido de venda')

_cCgc := "0"+Left(SE2->E2_CNPJ,8)+Substr(SE2->E2_CNPJ,9,4)+Right(SE2->E2_CNPJ,2)
 
If LEN(ALLTRIM(SE2->E2_CNPJ))<14
   _cCgc := Left(SE2->E2_CNPJ,9)+"0000"+Substr(SE2->E2_CNPJ,10,2)
Endif

Return(_cCgc)

