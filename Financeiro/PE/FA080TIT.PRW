#include "rwmake.ch"   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FA080TIT ³ Autor ³ Rogerio Nutti      ³Data ³ 19/12/2001   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ PONTO DE ENTRADA Baixa de Titulos a Pagar                  ³±±
±±³          ³ Mensagem de Adiantamento a Fornecedor                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Ad'oro Alimenticia                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Alteracao³ 26/05/2004 - Heraldo                                       ³±±
±±³          ³ Incluido o procedimento de atualizacao da Tabela SZ9       ³±±
±±³          ³ quando for pagamento antecipado de frete.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Chamado   ³ n. 051017 - Desenvolver tratativa no estorno e             º±±
±±º          ³ cancelamento na mesma data da baixa - TI - FWNM - 09/09/19 º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±  
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³ Alterado em 20/02/2014 por Luciano Mafra atendendo o chamado Nº18577  ³±±  
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

User Function FA080TIT()    

	Local lRet := .t.
	Local dDataFin := GetMV("MV_DATAFIN")

	SetPrvt("_SALIAS,_SINDEX,_SRECNO,_NVALBX,_SNUMF1,_SNUMD1")
	SetPrvt("_NPERC,_NVALRAT,_CFORNECE,_CNOMFOR,_SINDE2,_SNUME2")
	SetPrvt("_NCONTFOR,CTELAENTR,_cMens,")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava ambiente inicial     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_sAlias := Alias()
	_sIndex := IndexOrd()
	_sRecno := Recno()        
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamado Nº18577
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                                            
	IF DBAIXA != Ddatabase
	   ALERT("Data de Pagamento Diferente da Data Base do Sistema")
	   RETURN .F.
	endif 
	
	// Chamado n. 051017 - Desenvolver tratativa no estorno e cancelamento na mesma data da baixa - FWNM - 09/09/2019
	If dDataBase < dDataFin
		lRet := .f.
		Aviso("FA080TIT-01", "Baixa não permitida! Financeiro bloqueado nesta data. Ajuste a database ou contate o departamento financeiro...",{"OK"},, "MV_DATAFIN: " + DtoC(dDataFin))
	EndIf

	If lRet
		If dBaixa < dDataFin
			lRet := .f.
			Aviso("FA080TIT-02", "Baixa não permitida! Financeiro bloqueado nesta data. Ajuste o campo 'Data Pagto.' ou contate o departamento financeiro...",{"OK"},, "MV_DATAFIN: " + DtoC(dDataFin))
		EndIf
	EndIf

	If lRet
		If dDebito < dDataFin
			lRet := .f.
			Aviso("FA080TIT-03", "Baixa não permitida! Financeiro bloqueado nesta data. Ajuste o campo 'Data Debito' ou contate o departamento financeiro...",{"OK"},, "MV_DATAFIN: " + DtoC(dDataFin))
		EndIf
	EndIf
	
	Return lRet
	//

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Rotina de aviso de Adiantamento de Fornecedores ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cFornece := SE2->E2_FORNECE
	_cNomFor  := SE2->E2_NOMFOR
	
	If SE2->E2_TIPO = "PFA"
		dbSelectArea("SZ9")
		dbsetorder(1)
		If dbSeek( xFilial("SZ9")+SE2->E2_APAGTO)
			RecLock("SZ9",.F.)
			Z9_DTPGTO := DDATABASE
			Z9_STATUS := "3"	
			Msunlock()
		Endif
		
	Endif
	
	dbSelectArea("SE2")
	_sAliasSE2 := Alias()
	_sIndexSE2 := IndexOrd()
	_sRecnoSE2 := Recno()
	dbSetOrder(14)  // E2_FILIAL+E2_TIPO+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_FORNECE+E2_LOJA
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona o primeiro titulo do Tipo PA          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If dbSeek( xFilial("SE2")+"PA " )
	
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Faz a leitura dos titulos do Fornecedor         ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   Do While !Eof() .and. Alltrim(E2_TIPO) == "PA"
	   
	      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	      //³ Despreza titulos diferentes de PA               ³
	      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	      If _cFornece # SE2->E2_FORNECE
	         dbSkip()
	         Loop
	      Endif
	      
	      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	      //³ Se achou PA do Forneceodor e valor > 0, apresenta msg e sai do laco   ³
	      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	      If E2_SALDO >0
	         _cMens := OemToAnsi("Este titulo foi baixado,  porem existem titulos  de ")          +Chr(13)
	         _cMens := _cMens + OemToAnsi("de Adiantamento deste fornecedor ainda nao baixados.") +Chr(13)
	         _cMens := _cMens + OemToAnsi(_cFornece + " - " + _cNomFor                          ) +Chr(13)
	         _cMens := _cMens + OemToAnsi("Verifique e cancele a baixa antes de emitir cheques.")  +Chr(13)
	         _cMens := _cMens + OemToAnsi("Efetue a Baixa por compensacao dos titulos PA (Pagto Antecipado).") +Chr(13)
	         MsgBox(_cMens,"ATENCAO","ALERT")
	         Exit
	      Endif
	      dbSkip()
	   Enddo  
	   
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura ambiente inicial  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(_sAliasSE2)
	dbSetOrder(_sIndexSE2)
	dbGoto(_sRecnoSE2)
	
	dbSelectArea(_sAlias)
	dbSetOrder(_sIndex)
	dbGoto(_sRecno)

Return  .T.