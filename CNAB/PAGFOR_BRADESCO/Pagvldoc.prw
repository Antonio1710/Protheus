#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

User Function Pagvldoc()        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

SetPrvt("_VLDOC,")

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

//  CNAB BRADESCO A PAGAR (PAGFOR) - POSICOES (195-204) - VALOR DOCUMENTO

//IF Alltrim(SUBSTR(SE2->E2_CODBAR,10,10)) == ""   	// DESABILITADO POR ADRIANA EM 28/04/2016 chamado 027917
   _VLDOC := STRZERO((SE2->E2_SALDO*100),10,0) //SUBSTR(SE2->E2_BANCO,1,3)
//ELSE												// DESABILITADO POR ADRIANA EM 28/04/2016 chamado 027917
//   _VLDOC := SUBSTR(SE2->E2_CODBAR,10,10)			// DESABILITADO POR ADRIANA EM 28/04/2016 chamado 027917
//ENDIF												// DESABILITADO POR ADRIANA EM 28/04/2016 chamado 027917

Return(_VLDOC)        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00