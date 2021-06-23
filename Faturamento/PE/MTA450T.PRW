#include "rwmake.ch"
User Function MTA450T()      // DELMTA450T()  RENOMEADA PARA DEL PARA TESTAR 

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡„o    ³ MTA450T  ³ Autor ³ Rogerio Eduardo Nutti ³ Data ³ 01/08/02 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³ Ponto de Entrada no MATA450 (Liberacao de Credito apos     ³±±
	±±³          ³ gravar SC9, para gravar o campo C9_ROTEIRO, que sera       ³±±
	±±³          ³ filtrado na preparacao da NF                               ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Especifico Ad'oro Alimenticia                              ³±±
	±±³          ³ Usuarios FAT - MATA450 - Liberacao de Credito              ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Revis„o  ³                                          ³ Data ³          ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Guarda ambiente inicial                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cAlias := Alias()
	_nOrder := IndexOrd()
	_nRecno := Recno()

	dbSelectArea("SC9")
	RecLock("SC9",.F.)
	Replace C9_ROTEIRO With SC6->C6_ROTEIRO
	Replace C9_SEQUENC With SC6->C6_SEQUENC 
	Replace C9_DTENTR  with SC6->C6_ENTREG     // ALTERADO EM 29/10/08 POR HCCONSYS P/ TRATAR NUMERO DO LACRE NA ROTINA MENUBALA() 
	Replace C9_VEND1   with SC5->C5_VEND1      // Mauricio 28/06/11 - projeto nova tabela preço, filtro credito por carteira

	Replace C9_QTDLIB  With SC6->C6_QTDVEN     // Paulo - TDS - 11/07/2011 - Projeto nova tabela de Preço
	Replace C9_QTDLIB2 With SC6->C6_UNSVEN     // Paulo - TDS - 11/07/2011 - Projeto nova tabela de Preço
	MsUnlock()

	&&Como ja esta atualizando o SC9 com o proprio SC6 posicionado, acrescento aqui o tratamento para equalizar SC9 e SC6
	&&Mauricio 09/08/11.
	RecLock("SC6",.F.)
	SC6->C6_QTDEMP  := SC6->C6_QTDVEN
	SC6->C6_QTDEMP2 := SC6->C6_UNSVEN
	MsUnlock()

	dbSelectArea("SC5")
	_cAliasSC5 := Alias()
	_nOrderSC5 := IndexOrd()
	_nRecnoSC5 := Recno()
	dbSetOrder(1) 

	If dbSeek( xFilial("SC5")+SC9->C9_PEDIDO)
		RecLock("SC5",.F.)
		Replace C5_BLCRED With SC9->C9_BLCRED 
		MsUnlock()
	Endif   
	&&Retirado tratamento abaixo porque esta fazendo apenas para o primeiro item do SC6 - Mauricio 09/08/11.
	&&Novo tratamento incluido acima.
	/*
	// Incluído por Paulo Henrique - TDS - 11/07/2011
	// Atualiza os campos (C6_QTDLIB e C6_QTDLIB2) com o conteúdo dos campos (C6_QTDVEN e C6_UNSVEN) 

	dbSelectArea("SC6")
	_cAliasSC6 := Alias()
	_nOrderSC6 := IndexOrd()
	_nRecnoSC6 := Recno()
	dbSetOrder(1) 

	If dbSeek(xFilial("SC6")+SC9->C9_PEDIDO)
	RecLock("SC6",.F.)
	SC6->C6_QTDEMP  := SC6->C6_QTDVEN
	SC6->C6_QTDEMP2 := SC6->C6_UNSVEN
	MsUnlock()
	EndIf   
	*/
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mensagem para testar funcionamento do Ponto de Entrada                   ³
	//³ Teste OK                                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// MsgBox("Gravou C9_ROTEIRO para C9_PEDIDO/C9_ITEM: " + SC9->(C9_PEDIDO+"/"+C9_ITEM) + " e C6_NUM/C6_ITEM: "+SC6->(C6_NUM+"/"+C6_ITEM)  )

	//dbSelectArea(_cAliasSC6)
	//dbSetOrder(_nOrderSC6)
	//dbGoto(_nRecnoSC6)

	//
	If Findfunction("U_ADVEN050P") .And. cEmpAnt == "01" .And. cFilAnt = "02"
		If Upper(Alltrim(cValToChar(GetMv("MV_#SFATUF")))) == "S"
			U_ADVEN050P(,.F.,.T., " AND C5_NUM IN ('" + SC9->C9_PEDIDO + "') AND C5_XPEDSAL <> '' " ,.F.)				
		
		EndIf
		
	EndIf

	dbSelectArea(_cAliasSC5)
	dbSetOrder(_nOrderSC5)
	dbGoto(_nRecnoSC5)

	dbSelectArea(_cAlias)
	dbSetOrder(_nOrder)
	dbGoto(_nRecno)

Return