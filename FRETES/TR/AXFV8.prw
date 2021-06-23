#INCLUDE "rwmake.ch"

User Function AXFV8


//����������������������������������������������������������������������?
//?Declaracao de Variaveis                                             ?
//����������������������������������������������������������������������?

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "ZV8"

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tabela de Frete por Cidade')

dbSelectArea("ZV8")
dbSetOrder(1)

AxCadastro(cString,"Tabela de Frete por Cidade",cVldAlt,cVldExc)

Return
