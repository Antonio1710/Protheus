#include "rwmake.ch"
User Function IMPSC5() 

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ IMPSC5   ³ Autor ³ Marcos Bido           ³ Data ³ 30/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importa Roteiro e Sequencia do RS                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


cPerg := "IMPSC5"
If !Pergunte(cPerg,.T.)
  Return()
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declara variaveis                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

_cPath   := ALLTRIM(GETMV("MV_ROADSHO"))
_cArq    := alltrim(mv_par01)+".TXT"         // "ROTA.TXT / Arquivo texto a importar

If !MsgYesNo(OemToAnsi("Inicia a Importacao do Pedidos ? "))
	Return()
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guarda Area do Siga                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cAli := Alias()
_nOrd := IndexOrd()
_nRec := Recno()

dbSelectArea("SC5")
dbSetorder(1)

dbSelectArea("SC6")
dbSetorder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo Temporario para apendar arquivo temporario             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aStru := {}
AADD (aStru,{"LINHA"  , "C",60,0})
_cNomTrb := CriaTrab(aStru)
dbUseArea(.T.,,_cNomTrb,"TEMP",.F.,.F.)

dbSelectArea("TEMP")           // Inc RNUTTI 29/08/02
Append From &(_cPath+_cArq) SDF //ROTEIRO\PEDIDO.TXT SDF
dbGoTop()

Do While !eof()
	
	_Pedido := Substr(LINHA,13,6)
	_Roteiro:= Substr(LINHA,4,3)
	_Sequenc:= Substr(LINHA,30,2)
	
	dbSelectArea("SC5")
	dbSetOrder(1)        // Inc RNUTTI 29/08/02
	
	If dbSeek(xfilial("SC5") + _Pedido)
		
		RecLock("SC5",.F.)
		Replace C5_ROTEIRO With _Roteiro
		Replace C5_SEQUENC With StrZero(VAL(_Sequenc),2)
		MsUnlock()
		
		dbSelectArea("SC6")
                dbSetOrder(1)        // Inc RNUTTI 29/08/02
		
		If dbSeek( xFilial("SC6")+_Pedido )
			Do While !Eof() .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM =_Pedido
				RecLock("SC6",.F.)
				Replace C6_ROTEIRO With _Roteiro
				Replace C6_Sequenc With StrZero(VAL(_Sequenc),2)  // Alt RNUTTI 29/08/2002
				MsUnlock()
				dbSkip()
			Enddo
		Endif


	Endif
	DbSelectArea("temp")
	dbSkip()
	
EndDo

MsgStop("Fim do Processamento")

Return