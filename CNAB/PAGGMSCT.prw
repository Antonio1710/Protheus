#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

User Function PAGGMSCT()        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

SetPrvt("_CTACED,_RETDIG,_DIG1,_DIG2,_DIG3,_DIG4,_NPOSDV")
SetPrvt("_DIG5,_DIG6,_DIG7,_MULT,_RESUL,_RESTO")
SetPrvt("_DIGITO,")

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

/////  PROGRAMA PARA SEPARAR A C/C DO CODIGO DE BARRA
/////  CNAB BRADESCO A PAGAR (PAGFOR) - POSICOES (105-119)

_CtaCed := "000000000000000"
_cBanco := SUBSTR(SE2->E2_CODBAR,1,3)
If _cBanco $ "237/BRD"	// BRADESCO

    _CtaCed  :=  STRZERO(VAL(SUBSTR(SE2->E2_CODBAR,37,7)),13,0)
    
    _RETDIG := " "
    _DIG1   := SUBSTR(SE2->E2_CODBAR,37,1)
    _DIG2   := SUBSTR(SE2->E2_CODBAR,38,1)
    _DIG3   := SUBSTR(SE2->E2_CODBAR,39,1)
    _DIG4   := SUBSTR(SE2->E2_CODBAR,40,1)
    _DIG5   := SUBSTR(SE2->E2_CODBAR,41,1)
    _DIG6   := SUBSTR(SE2->E2_CODBAR,42,1)
    _DIG7   := SUBSTR(SE2->E2_CODBAR,43,1)
    
    _MULT   := (VAL(_DIG1)*2) +  (VAL(_DIG2)*7) +  (VAL(_DIG3)*6) +   (VAL(_DIG4)*5) +  (VAL(_DIG5)*4) +  (VAL(_DIG6)*3)  + (VAL(_DIG7)*2)
    _RESUL  := INT(_MULT /11 )
    _RESTO  := INT(_MULT % 11)
    _DIGITO := STRZERO((11 - _RESTO),1,0)

    _RETDIG := IF( _resto == 0,"0",IF(_resto == 1,"P",_DIGITO))

    _CtaCed := _CtaCed + _RETDIG
   
Else
	IF SEA->EA_MODELO=="31"
		_CtaCed := "000000000000000"
	Else
	    _RETDIG := ""       
		_cBcoDig:=   IIF(EMPTY(SE2->E2_CNPJ),SUBSTR(SA2->A2_BANCO,1,3),SUBSTR(SE2->E2_BANCO,1,3))
 		If _cBcoDig $ "399"	    
	    	_RETDIG := IIF(EMPTY(SE2->E2_CNPJ),SUBSTR(SA2->A2_DIGCTA,1,2),SUBSTR(SE2->E2_DIGCTA,1,2)) 
	    Else
	    	_RETDIG := IIF(EMPTY(SE2->E2_CNPJ),SUBSTR(SA2->A2_DIGCTA,1,1),SUBSTR(SE2->E2_DIGCTA,1,1)) 	    
	    Endif	
		_RETDIG := IIF(EMPTY(_RETDIG),"0",_RETDIG)
		_CtaCed:= IIF(EMPTY(SE2->E2_CNPJ),STRZERO(VAL(SA2->A2_NUMCON),13),STRZERO(VAL(SE2->E2_NOCTA),13))                                         
		_CtaCed := _CtaCed   + _RETDIG 
	Endif	
Endif

// Substituido pelo assistente de conversao do AP5 IDE em 26/09/00 ==> __return(_Ctaced)
Return(_CtaCed)        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00