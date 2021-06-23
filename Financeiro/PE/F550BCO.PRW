#include "rwmake.ch"

User Function F550BCO()  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ F550BCO  ³ Autor ³ R Nutti/R Baldoni     ³ Data ³ 28/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ponto de Entrada p/ gravacao cheque no Caixinha (Reposicao)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Ad'oro Alimenticia                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//  Exemplo do bloco da chamada do Ponto de Entrada P550BCO na rotina FINA550
// ...
// 		Replace E5_LA		With "S"
//		Replace E5_MOVCX    With "S"
//		If ExistBlock("F550BCO")
//			ExecBlock("F550BCO",.F.,.F.)
//		Endif
//		MsUnlock()
// ...
//      ou seja, o MsUnlock() e' utilizado para o SE5 apos o Ponto de Entrada

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guarda Ambiente (Pocionado no SE5)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cAlias := Alias()  ;  _nOrder := IndexOrd()  ;  _nRecno := Recno()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Public _cCheque  := Space(15)

_cBanco   := SET->ET_BANCO
_cAgencia := SET->ET_AGEBCO
_cConta   := SET->ET_CTABCO

_lNaoGravCheq := .T.

Do While _lNaoGravCheq
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva a Integridade dos dados de Entrada                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 000,000 TO 250,385 DIALOG _oDlg1 TITLE "Gera Cheque - Caixinha"
	@ 003,008 To 080,184
	@ 011,017 Say OemToAnsi("Esta rotina gera cheque na Reposicao do ")
	@ 022,017 Say OemToAnsi("Caixinha.")
	
	@ 040,017 Say OemToAnsi("Informe o numero do Cheque:  ")
	@ 050,080 Get _cCheque PICTURE "@!" Valid !Empty(_cCheque)
	
	@ 093,117 BMPBUTTON TYPE 01 ACTION GeraCheq()
	ACTIVATE DIALOG _oDlg1 CENTERED
	
Enddo
dbSelectArea(_cAlias) ; dbSetOrder(_nOrder) ; dbGoto(_nRecno)

RecLock(_cAlias,.F.)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ GERACHEQ ³ Autor ³ R Nutti/R Baldoni     ³ Data ³ 28/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ponto de Entrada p/ gravacao cheque no Caixinho (Reposicao)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Ad'oro Alimenticia                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function GeraCheq()


dbSelectArea("SEF")
_cAliasSEF := Alias()  ;  _nOrderSEF := IndexOrd()  ;  _nRecnoSEF := Recno()
dbSetOrder(1)    // EF_FILIAL+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM
If dbSeek( xFilial("SEF") + _cBanco + _cAgencia + _cConta + _cCheque )
	MsgBox("Cheque ja existe no Cadastro")
	_lNaoGravCheq := .T.
Else
	// Inclusoes RNUTTI 20/08/2003 - Gravar no SEU Cheque, Bco, Agencia e Conta (campos especificos)dbSelectArea("SEU")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava cheque no SEU - Movimentos do Caixinha                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("SEU",.F.)
	Replace EU_BANCO   With _cBanco
	Replace EU_AGENCIA With _cAgencia
	Replace EU_CONTABC With _cConta
	Replace EU_CHEQUE  With _cCheque
	MsUnlock()
	// Fim das Inclusoes

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava cheque no SE5 - Movimentacao Bancaria                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE5")
	RecLock("SE5",.F.)
	Replace E5_NUMCHEQ With _cCheque
	MsUnlock()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava cheque no SEF - Cadastr de Cheques                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("SEF",.T.)
	Replace EF_FILIAL		With xFilial("SEF")
	Replace EF_NUM			With _cCheque
	Replace EF_BANCO		With _cBanco
	Replace EF_AGENCIA		With _cAgencia
	Replace EF_BENEF		With SM0->M0_NOMECOM
	Replace EF_VALOR		With SEU->EU_VALOR
	Replace EF_DATA			With dDataBase    // SEU->EU_EMISSAO, Alt RNUTTI 27/08/2003
	Replace EF_CONTA		WITH _cConta
	Replace EF_HIST			With "Reposicao Bco/Ag/CC "+Alltrim(_cBanco)+"/"+Alltrim(_cAgencia)+"/"+Alltrim(_cConta)+" para o Caixinha "+SEU->EU_CAIXA
	Replace EF_FORNECE		With SEU->EU_FORNECE
	Replace EF_LOJA			With SEU->EU_LOJA
	Replace EF_SEQUENC		With "01"
	Replace EF_ORIGEM       With "FINA390" // FINA390-Chs Titulos / FINA190-Geracao Chs
	Replace EF_TERCEIR		With .F.
	Replace EF_PREFIXO		With Iif(SM0->M0_CODFIL="02","VP","SC")
	Replace EF_TITULO		With Iif(SM0->M0_CODFIL="02","CX_VP","CX_SC")
	//	Replace EF_PARCELA
	//	Replace EF_TIPO
	//	Replace EF_IMPRESS		With
	//	Replace EF_OK
	//	Replace EF_CART
	//	Replace EF_DEPOSIT
	//	Replace EF_NUMNOTA
	//	Replace EF_RG
	//	Replace EF_SERIE
	//	Replace EF_TEL
	//	Replace EF_VENCTO
	//	Replace EF_LIBER
	//	Replace EF_GARANT
	//	Replace EF_LA
	//	Replace EF_PORTADO
	//	Replace EF_FLSERV
	//	Replace EF_HISTD
	//	Replace EF_ALINEA1
	//	Replace EF_ALINEA2
	//	Replace EF_DATLIN1
	//	Replace EF_DATLIN2
	//	Replace EF_DTREPRE
	//	Replace EF_CHDEVOL
	//	Replace EF_COMP
	MsUnlock()
	_lNaoGravCheq := .F.
Endif

dbSelectArea(_cAliasSEF) ; dbSetOrder(_nOrderSEF) ; dbGoto(_nRecnoSEF )
Close(_oDlg1)
Return
