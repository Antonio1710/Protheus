#include "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FA110SE5 ³ Autor ³ Rogerio Nutti      ³Data ³ 12/04/2006   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ PONTO DE ENTRADA Baixa de Titulos a Receber Automat FINA110³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Ad'oro Alimenticia                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Alteracao³fwnm - 10/12/2018 - chamado n. 045499                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FA110SE5()   

	// CHAMADO N. 045499 - FWNM EM 10/12/2018
	Local cPerg    := "F110FIL"
	Local cHistSE5 := ""
	// 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava ambiente inicial     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_sAlias := Alias()
	_sIndex := IndexOrd()
	_sRecno := Recno()
	
	dbSelectArea("SA1")
	_sAliasSA1 := Alias()
	_sIndexSA1 := IndexOrd()
	_sRecnoSA1 := Recno()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se é baixa por Perda/PDD (MV_MOTBXRE), altera risco para "E"  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SE5->E5_MOTBX $ Alltrim( GETMV("MV_MOTBXRE") ) 
	
		dbSelectArea("SA1")	
		dbSetOrder(1)
		If dbSeek( xFilial("SA1")+SE5->(E5_CLIFOR+E5_LOJA ) ) 
			RecLock("SA1",.F.)
			Replace A1_RISCO With "E"
			MsUnlock()
		Endif
	
	Endif
	
	// CHAMADO N. 045499 - FWNM EM 10/12/2018
	Pergunte(cPerg, .F.)
	cHistSE5 := Upper(MV_PAR07) // Criado no PE F110FIL
	
	// Restauro pergunte padrao
	Pergunte( "FIN110", .F. )
	
	// Gravo historico informado pelo user no pergunte contido no PE F110FIL
	If !Empty(cHistSE5)
		RecLock("SE5", .F.)
			SE5->E5_HISTOR := cHistSE5
		SE5->( msUnLock() )
	EndIf
	//
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura ambiente inicial  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(_sAliasSA1)
	dbSetOrder(_sIndexSA1)
	dbGoto(_sRecnoSA1)
	
	dbSelectArea(_sAlias)
	dbSetOrder(_sIndex)
	dbGoto(_sRecno)

Return