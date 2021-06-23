#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
 
User Function Pggmdtdec()        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

SetPrvt("_DTDOC")

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

//  CNAB BRADESCO A PAGAR (PAGFOR) - POSICOES (182 a 189) - DATA LIMITE PARA DESCONTO
//  ARQUIVO BRADGMSB.CPE 

IF SE2->E2_SDDECRE > 0
	IF VAL(SUBSTR(SE2->E2_CODBAR,10,8))+VAL(SUBSTR(SE2->E2_CODBAR,18,2))/100 == SE2->E2_SALDO - SE2->E2_SDDECRE
		_DTDOC := STRZERO(0,8)	
	Else
		_DTDOC := DTOS(SE2->E2_VENCREA)
	Endif	
Else
	_DTDOC := STRZERO(0,8)    
Endif	

Return(_DTDOC)