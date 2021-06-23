/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Modulo11 ³ Autor ³ GUSTAVO GONELA        ³ Data ³ 06/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo do modulo 11, retornando digito de controle        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := Modulo11(ExpC1,ExpN1,ExpN2)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = String para calcular o digito                      ³±±
±±³          ³ ExpN1 = Primeiro numero de multiplicacao do modulo 11      ³±±
±±³          ³ ExpN2 = Ultimo numero de multiplicacao do modulo 11)       ³±±
±±³          ³                                                            ³±±
±±³          ³ ExpC2 = Digito de verificacao (Retornado pela funcao)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Ad'oro Alimenticia                              ³±±
±±³          ³ Banco do Brasil                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Modulo 11 - Padrao Microsiga                                   ³
//³             1 7 7 4 0 0  0 0 0 2 1  ?                          ³
//³             x x x x x x  x x x x x  ?                          ³
//³             4 3 2 9 8 7  6 5 4 3 2  ?                          ³
//³                                                                ³
//³ Modulo 11 - Padrao Banco do Brasil                             ³
//³             1 7 7 4 0 0  0 0 0 2 1  ?                          ³
//³             x x x x x x  x x x x x  ?                          ³
//³             7 8 9 2 3 4  5 6 7 8 9  ?                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/

User Function MOD11SAF()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Calculo do modulo 11, retornando digito de controle')

_cNum := PARAMIXB

nMin := 9
nMax := 2



// Alterado RNUTTI 03/02/2003 - Ajuste
//
//     nLen := Len( _cNum ) ;
//          , nSum := 0;
//          , nFat;
//          , i

nLen := Len( _cNum )
nSum := 0

// Fim alteracoes

nMin := If( nMin == NIL, 9, nMin )
nMax := If( nMax == NIL, 2, nMax )
nFat := nMin
_ret  := 0
for _ni := 1 to nLen  step 1
	
	nSum += Val( SubStr( _cNum, _ni, 1 ) ) * nFat
	
	if nFat == nMax
		
		nFat := nMin
	else
		nFat --
	end
next

_ni := (nSum % 11) 

if _ni == 0
		_ret := "1"

elseif  _ni == 1
		_ret := "0"  
	
else
	_ret := Strzero(11 - _ni,1)   
//	 	_ret := substr(_ret,1) 
		
endif  

return(_ret)






/*/ programa original alterado em 12/09/02 - Marcos Bido

Local _i, _nModulo := 0, _cChar, _nMult
_nMultIni := 9     // 2   - Banco do Brasil e' invertido
_nMultFim := 2     // 9   - Banco do Brasil e' invertido

_nMult := _nMultIni
_cStr := AllTrim(_cStr)
_cRet := " "

For _i := Len(_cStr) to 1 Step -1
	_cChar := Substr(_cStr,_i,1)
	If isAlpha( _cChar )
		Help(" ", 1, "ONLYNUM")
		Return .F.
	End
	_nModulo += Val(_cChar)*_nMult
	//_nMult:= IIf(_nMult==_nMultfim,2,_nMult+1) - Banco do Brasil e' invertido
	_nMult:= IIf(_nMult==_nMultfim,9,_nMult-1)
	
	
Next

_nRest := _nModulo % 11

// Alteracao RNUTTI 03/09/2002 - Banco Itau, para resto 10, digito e' "X"
// nRest := IIf(nRest==0 .or. nRest==1,0,11-nRest)


If _nRest==0 .or. _nRest==1
	_cRet := "0"
ElseIf _nRest==10
	_cRet := "X"
Else
	_cRet := StrZero(11-_nRest,1)
Endif

// Fim Alteracoes

Return( _cRet )
/*/

