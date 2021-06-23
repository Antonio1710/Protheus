/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Modulo11 ³ Autor ³ Rogerio Eduardo Nutti ³ Data ³ 03/09/02 ³±±
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

User Function MODUL11()
                           
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

nMin := If( nMin == NIL, 2, nMin )
nMax := If( nMax == NIL, 9, nMax )
nFat := nMin

for _ni := nLen to 1 step -1
	
	nSum += Val( SubStr( _cNum, _ni, 1 ) ) * nFat
	
	if nFat == nMax
		
		nFat := nMin
	else
		nFat --
	end
next

_ni := (nSum % 11)

if _ni > 9
	_ni := "X"
else
	_ni := str(_ni,1)
	
endif

return(_ni)