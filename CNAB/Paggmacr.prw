#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

User Function Paggmacr()        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

SetPrvt("_VLDOC,")

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

//  CNAB BRADESCO A PAGAR (PAGFOR) - POSICOES (235-249) - VALOR DO ACRESCIMO
//  ARQUIVO BRADGMSB.CPE

IF Alltrim(SUBSTR(SE2->E2_CODBAR,10,10)) == ""
   //_VLDOC := STRZERO((SE2->E2_SDACRES*100),15) //STRZERO((SE2->E2_SALDO*100),10,0) //SUBSTR(SE2->E2_BANCO,1,3)
   _VLDOC := STRZERO(SE2->E2_ACRESC*100,15) 
ELSE
	IF VAL(SUBSTR(SE2->E2_CODBAR,10,8))+VAL(SUBSTR(SE2->E2_CODBAR,18,2))/100 == SE2->E2_SALDO + SE2->E2_SDACRES
		_VLDOC := STRZERO((0),15) 	
	ELSE	
	   //_VLDOC := STRZERO((SE2->E2_SDACRES*100),15) //SUBSTR(SE2->E2_CODBAR,10,10)
	   _VLDOC := STRZERO(SE2->E2_ACRESC*100,15) 
	ENDIF   
ENDIF

Return(_VLDOC)