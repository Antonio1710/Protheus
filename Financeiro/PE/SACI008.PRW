#include "rwmake.ch"
#include "protheus.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SACI008  ³ Autor ³ Rogerio Nutti      ³Data ³ 12/04/2006   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ PONTO DE ENTRADA Baixa de Titulos a Receber Manual FINA070 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Ad'oro Alimenticia                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Alteracao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava ambiente inicial     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


User Function SACI008()        

_sAlias := Alias()
_sIndex := IndexOrd()
_sRecno := Recno()

dbSelectArea("SA1")
_sAliasSA1 := Alias()
_sIndexSA1 := IndexOrd()
_sRecnoSA1 := Recno()

dbSelectArea("SE1")
_sAliasSE1 := Alias()
_sIndexSE1 := IndexOrd()
_sRecnoSE1 := Recno()


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

//Inicio Sigoli Chamado:027642 19/12/2016
DbSelectArea("SE1")	
DbSetOrder(1)
If dbSeek(xFilial("SE1")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA)
	While !Eof() .and. E1_PREFIXO = SE5->E5_PREFIXO .and. E1_NUM = SE5->E5_NUMERO .and. E1_PARCELA = SE5->E5_PARCELA .and. SE5->E5_BANCO <> ''
		If !EMPTY(E1_BAIXA).and. EMPTY(E1_XDTDISP) 
			RecLock("SE1",.F.)
			Replace E1_XDTDISP With SE5->E5_DTDISPO
			MsUnlock()
		EndIF	
   	DbSkip() 
   	Enddo
Endif
//Fim Sigoli Chamado: 027642 19/12/2016

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura ambiente inicial  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea(_sAliasSE1)
dbSetOrder(_sIndexSE1)
dbGoto(_sRecnoSE1)

dbSelectArea(_sAliasSA1)
dbSetOrder(_sIndexSA1)
dbGoto(_sRecnoSA1)

dbSelectArea(_sAlias)
dbSetOrder(_sIndex)
dbGoto(_sRecno)

Return  


 