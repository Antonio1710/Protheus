#include "Protheus.ch"
User Function AXFVB

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tabela Preco Frete por periodo')

AXCADASTRO("ZVB","Tabela Preco Frete por periodo ") 

Return()
