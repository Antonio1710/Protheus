#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

User Function PAGGMSAG()        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

SetPrvt("_AGENCIA,_RETDIG,_DIG1,_DIG2,_DIG3,_DIG4")
SetPrvt("_MULT,_RESUL,_RESTO,_DIGITO,")

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

//     PROGRAMA PARA SEPARAR A AGENCIA DO CODIGO DE BARRA
//     CNAB BRADESCO A PAGAR (PAGFOR) - POSICOES (99-104)

_Agencia := "000000"
_cBanco := SUBSTR(SE2->E2_CODBAR,1,3)

If _cBanco $ "237/BRD"	// BRADESCO
      _Agencia  :=  "0" + SUBSTR(SE2->E2_CODBAR,20,4)

      _RETDIG := " "
      _DIG1   := SUBSTR(SE2->E2_CODBAR,20,1)
      _DIG2   := SUBSTR(SE2->E2_CODBAR,21,1)
      _DIG3   := SUBSTR(SE2->E2_CODBAR,22,1)
      _DIG4   := SUBSTR(SE2->E2_CODBAR,23,1)

      _MULT   := (VAL(_DIG1)*5) +  (VAL(_DIG2)*4) +  (VAL(_DIG3)*3) +   (VAL(_DIG4)*2)
      _RESUL  := INT(_MULT /11 )
      _RESTO  := INT(_MULT % 11)
      _DIGITO := 11 - _RESTO

      _RETDIG := IF( _RESTO == 0,"0",IF(_RESTO == 1,"0",ALLTRIM(STR(_DIGITO))))
                                 
		If _cBanco $ "237/399"
			If Alltrim(_RETDIG) == ""
				_Agencia:= _Agencia + "0"		
			Else
				_Agencia:= _Agencia + _RETDIG
			Endif	
		Endif	

Else               

	IF SEA->EA_MODELO=="31"
		_Agencia := "000000"
	Else
      _RETDIG := " "
      _RETDIG :=   IIF(EMPTY(SE2->E2_CNPJ),SUBSTR(SA2->A2_DIGAG,1,1),SUBSTR(SE2->E2_DIGAG,1,1))
      _cBcoDig:=   IIF(EMPTY(SE2->E2_CNPJ),SUBSTR(SA2->A2_BANCO,1,3),SUBSTR(SE2->E2_BANCO,1,3))
 		If _cBcoDig $ "237/399"
			If Alltrim(_RETDIG) == ""
				_RETDIG := "0"		
			Endif	
		Endif     
      _Agencia :=  IIF(EMPTY(SE2->E2_CNPJ),STRZERO(VAL(SA2->A2_AGENCIA),5),STRZERO(VAL(SE2->E2_AGEN),5)) + _RETDIG	
	Endif
Endif
	
// Substituido pelo assistente de conversao do AP5 IDE em 26/09/00 ==> __Return(_Agencia)
Return(_Agencia)        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
