#include "rwmake.ch"
#include "Topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AROTE    ³ Autor ³ Marcos Bido           ³ Data ³ 20/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Alteracao do Roteiro de Entrega. O Advanced Protheus nao   ³±±
±±³          ³ permite alteracao neste campo                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ARote, Sub-Funcao de ALTROTE                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Ad'oro Alimenticia                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Manutencao³ Heraldo 09/03/04 - Comentado todas as gravacoes de data nas³±±
±±³          ³ tabelas SC5/SC6/SC9, pois as datas dos pedidos devem ser   ³±±
±±³          ³ mantidas.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºALTERAÇÃO ³ Ricardo Lima-19/02/2019-047354, NAO PERMITE MAIS DE 1      º±±
±±º          ³ PEDIDO COM MESMO ROTEIRO E DATA DE ENTREGA                 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºALTERAÇÃO ³ Ricardo Lima-27/02/2019-047506|CORREÇÃO TROCA DE ROTEIRO   º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function AROTE()

	SetPrvt("_CALIAS,_NINDEX,_NRECNO")
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Alteracao do Roteiro de Entrega.')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Guarda ambiente inicial                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	
	dbSelectArea("SC6")
	_nIndexSC6 := IndexOrd()
	_nRecnoSC6 := Recno()
	DbSetOrder(1)
	
	dbSelectArea("SC5")
	_nIndexSC5 := IndexOrd()
	_nRecnoSC5 := Recno()
	_RotPeso  :=  0
	_cRote    := SC5->C5_ROTEIRO
	_cSequ    := SC5->C5_SEQUENC
	_cPlac    := SC5->C5_PLACA
	_cRot_Atu := SC5->C5_ROTEIRO
	_cSeq_Atu := SC5->C5_SEQUENC &&Mauricio - Chamado 036566  
	_dtEntr   := SC5->C5_DTENTR // Ricardo Lima-27/02/2019-047506
	_RotEntr  := SPACE(3)
	_PLiqTot  := SC5->C5_PESOL
	_cPdido   := SC5->C5_NUM      &&Chamado 032812
	_dDTE     := SC5->C5_DTENTR
	
	If Alltrim(SC5->C5_XINT) == "3"
		Alert("Roteiro já enviado para o Edata, para altera-lo é necessario o Estorno")
	Else
		@ 00,000 TO 300,450 DIALOG oDlg1 TITLE "Alteracao de Roteiro/Sequencia"
	
		@ 010,010 SAY "Num. Pedido :   " ;  @ 010,060 SAY SC5->C5_NUM
		@ 020,010 SAY "Cod. Cliente:   " ;  @ 020,060 SAY SC5->C5_CLIENTE
		@ 030,010 SAY "Loja Cliente:   " ;  @ 030,060 SAY SC5->C5_LOJACLI
		@ 040,010 SAY "Loja Entrega:   " ;  @ 040,060 SAY SC5->C5_LOJAENT
		@ 050,010 SAY "Data Emissao:   " ;  @ 050,060 SAY DtoC(SC5->C5_EMISSAO)
		@ 060,010 SAY "Data Entrega :  " ;  @ 060,060 SAY DtoC(SC5->C5_DTENTR)
		@ 070,010 SAY "Cod. Vendedor:  " ;  @ 070,060 SAY SC5->C5_VEND1
		@ 080,010 SAY "Placa Veiculo:  " ;  @ 080,060 SAY SC5->C5_PLACA
		@ 090,010 SAY "Peso Bruto   :  " ;  @ 090,060 SAY Transform(SC5->C5_PBRUTO, "@R 999,999.999")
		@ 100,010 SAY "Total Caixas :  " ;  @ 100,060 SAY Transform(SC5->C5_VOLUME1,"@R 999,999,999")
		@ 110,010 SAY "Peso Roteiro :  "
		@ 120,010 SAY "Num. Entregas:  "
	
		@ 10,100 TO 87,230 TITLE "Dados do Roteiro "
		@ 25,125 SAY "ROTEIRO      SEQUENCIA"
		@ 40,105 SAY "Atual:"
		@ 40,125 SAY SC5->C5_ROTEIRO+"           " + SC5->C5_SEQUENC
		@ 55,105 SAY "Novo: "
	
		@ 55,125 GET _cRote Valid RotePeso() .and. !Empty(_cRote)
		@ 55,165 GET _cSequ Valid !Empty(_cSequ)
	                     
		@ 70,105 SAY "Entrega : " 
		@ 70,135 SAY dtoc(_dtEntr)
	
		@ 100,150 BMPBUTTON TYPE 01 ACTION GravaRote()
		@ 100,180 BMPBUTTON TYPE 02 ACTION Close(oDlg1)
	
		ACTIVATE DIALOG oDlg1 CENTER
	Endif	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura ambiente inicial                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	dbSelectArea("SC5")
	dbSetOrder(_nIndexSC5)
	dbGoto(_nRecnoSC5)
	
	dbSelectArea("SC6")
	dbSetOrder(_nIndexSC6)
	dbGoto(_nRecnoSC6)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ GravaRote    ³ Alteracao Roteiro/Sequencia        Advanced Protheus nao³±±
±±³              ³ permite alteracao neste campo                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Rogerio Nutti³ 22/06/01 ³ Funcao de Gravacao                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GravaRote()

	dbSelectArea("SC5")
	
	dbSelectArea("SC9")     &&Mauricio - 26/03/10 - Incluido verificacao de pedidos com bloqueio de credito/estoque. Sol. Caio.
	dbSetOrder (1)
	If dbSeek(xFilial("SC9")+SC5->C5_NUM)
		Do While !Eof() .and. SC9->C9_FILIAL==xFilial("SC9") .and. SC9->C9_PEDIDO == SC5->C5_NUM
		   If !(Empty(SC9->C9_BLEST ) .AND. Empty(SC9->C9_BLCRED))
				MsgAlert("Processo interrompido, o pedido "+SC9->C9_PEDIDO+" possui itens com bloqueio de estoque ou credito!Verifique.")
				Close(Odlg1)
				Return(.T.)
		   endif
		   DbSelectArea("SC9")
		   DbSkip()
		enddo   
	endif
	
	dbSelectArea("SC5")
	//dbSetOrder(9)
	SC5->(DBORDERNICKNAME("SC5_9")) //atualização protheus 12 WILLIAM COSTA 28/12/2017 CHAMADO 036032
	dbSeek(xFilial("SC5")+DTOS(_dtEntr)+Alltrim(_cRote))
	Do While !Eof() .and. _dtEntr == SC5->C5_DTENTR .and. Alltrim(_cRote) == Alltrim(SC5->C5_ROTEIRO)
		If Alltrim(SC5->C5_XINT) == "3"
			MsgAlert("Processo interrompido, este roteiro / data de entrega já foi enviado ao Edata!Verifique.")
			Close(Odlg1)
			Return(.T.)
		Endif
		DbSelectArea("SC5")
		DbSkip()	
	Enddo
	
	dbSelectArea("SC5")
	dbSetOrder(_nIndexSC5)
	dbGoto(_nRecnoSC5)
	
	dbSelectArea("SC5")
	RecLock("SC5",.F.)
	Replace C5_ROTEIRO With _cRote
	Replace C5_SEQUENC With _cSequ
	// Altera data para data de entrega do roteiro
	//Replace C5_DTENTR  With _dtEntr 		// COMENTADO POR HERALDO 09/03/04
	
	MsUnlock()
	
	_cPedido := C5_NUM
	_cCliente:= C5_CLIENTE
	_cLoja   := C5_LOJACLI
	// _DtEntr  := SC5->C5_DTENTR
	_cPlac   := SC5->C5_PLACA
	_cGuia   := SPACE(6)
	// Altera roteiro e  data dos Itens do Pedido
	dbSelectArea("SC6")
	If dbSeek( xFilial("SC6")+_cPedido )
		Do While !Eof() .and. SC6->C6_FILIAL==xFilial("SC6") .and. SC6->C6_NUM =_cPedido
			RecLock("SC6",.F.)
			Replace C6_ROTEIRO With _cRote 
			// Gravo a Data da Entrega para a mesma data do Roteiro Destino
	//		Replace C6_ENTREG  With _dtEntr  // COMENTADO POR HERALDO 09/03/04
			MsUnlock()
			dbSkip()
		Enddo
	Endif 
	
	dbSelectArea("SC9")
	dbSetOrder (1)
	If dbSeek(xFilial("SC9")+_cPedido)
		Do While !Eof() .and. SC9->C9_FILIAL==xFilial("SC9") .and. SC9->C9_PEDIDO =_cPedido
			RecLock("SC9",.F.)
			Replace C9_ROTEIRO With _cRote 
			// Gravo a Data da Entrega para a mesma data do Roteiro Destino
	//		Replace C9_DTENTR  With _dtEntr  // COMENTADO POR HERALDO 09/03/04
			MsUnlock()
			dbSkip()
		Enddo
	Endif
	//********************
	//SOMA O PESO BRUTO
	//********************
	
	// Atualizo SZK controle de frete e Guia de Pesagem
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Fretes                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	&&Mauricio - 08/02/17 - Chamado 032812 - Alterado a gravação na SZK abaixo com o roteiro atual digitado,
	&&porque quando ha varios pedidos roteirizados para uma mesma placa x roteiro x data entrega, alterando o
	&&registro na SZK, faz perder o vinculo para os demais pedidos roteirizados que não precisam ser alterados,
	&&causando problema no controle de fretes.
	&&assim eh mantido o registro na SZK sem alterar qdo houver mais pedidos de venda envolvidos na condição acima.
	
	//Altero a ordem para roteiro
	&&Anterior inicio Chamado 032812
	/*
	dbSelectArea("SZK")
	dbSetOrder(4)     // ZK_FILIAL + ZK_DTENTR  + ZK_PLACA + ZK_ROTEIRO )
	If dbSeek(xFilial("SZK")+ DTOS(_DtEntr) + _cPlac + _cRot_Atu)
		RecLock("SZK",.F.)
		Replace ZK_FILIAL   With xFilial("SZK")
		Replace ZK_ENTREGA  With _RotEntr
		Replace ZK_PESOL    With _PLiqTot
		Replace ZK_PBRUTO   With _RotPeso
		Replace ZK_PESFATL  With _PLiqTot
		Replace ZK_PESFATB  With _RotPeso    
		Replace ZK_ROTEIRO  With _cRote    
		_cGuia	:= 	SZK->ZK_GUIA
		MsUnlock()	
	Endif
	
	// Vou na Guia Registar a Data de Entrega
	dbSelectArea("ZV2")
	dbSetOrder(1)     // ZV2_GUIA]
	If dbSeek(xFilial("ZV2")+_cGuia)
		RecLock("ZV2",.F.)
		Replace ZV2_ROTEIRO With _cRote
		Replace ZV2_PFATU   With _RotPeso
		// Altero para nao permitir a primeira pesagem novamente
		Replace ZV2_STATUS  With "2"
		MsUnlock()
	Endif
	*/  &&Anterior fim
	
	&&Chamado 032812 vou verificar a existencia de mais pedidos de venda ja vinculados ao Roteiro/Placa/Data entrega
	cQuery:= " SELECT C5_ROTEIRO, C5_NUM FROM " + RetSqlName("SC5") + " WITH(NOLOCK) "
	cQuery+= " WHERE C5_ROTEIRO = '" + _cRot_Atu + "' "
	cQuery+= " AND C5_PLACA = '" + _cPlac + "' "
	cQuery+= " AND C5_DTENTR = '" + DTOS(_dDTE) + "' "
	cQuery+= " AND C5_NUM <> '" + _cPdido + "' "
	cQuery+= " AND D_E_L_E_T_ <> '*' AND C5_NOTA = ' ' "
	cQuery+= " ORDER BY C5_ROTEIRO"
		
	TCQUERY cQuery new alias "TROT"
	TROT->(dbgotop())
		              
	_nQt := 0	
	DbSelectArea ("TROT")
	While TROT->(!EOF())
	      _ccc := TROT->C5_NUM
	      _nQt ++
	      TROT->(dbSkip())
	Enddo
	
	DbCloseArea("TROT")
	
	If _nQt == 0   &&só houve mesmo um unico pedido/roteiro/placa alterado, ai eu posso alterar o roteiro na SZK
	   dbSelectArea("SZK")
	   dbSetOrder(4)     // ZK_FILIAL + ZK_DTENTR  + ZK_PLACA + ZK_ROTEIRO )
	   If dbSeek(xFilial("SZK")+ DTOS(_dDTE) + _cPlac + _cRot_Atu)
	   
	    //grava log chamado 041202 - WILLIAM COSTA 23/04/2018
		u_GrLogZBE (Date(),TIME(),cUserName," RecLock(SZK,.F.)","LOGISTICA","AROTE",;
		"Filial: "+xFilial("SZK")+" Data: "+DTOS(_dDTE)+" Placa: "+_cPlac+" Roteiro: "+_cRot_Atu+" ZK_ENTREGA: "+CVALTOCHAR(_RotEntr),ComputerName(),LogUserName())
	   
		RecLock("SZK",.F.)
		Replace ZK_FILIAL   With xFilial("SZK")
		Replace ZK_ENTREGA  With _RotEntr
		Replace ZK_PESOL    With _PLiqTot
		Replace ZK_PBRUTO   With _RotPeso
		Replace ZK_PESFATL  With _PLiqTot
		Replace ZK_PESFATB  With _RotPeso    
		Replace ZK_ROTEIRO  With _cRote    
		_cGuia	:= 	SZK->ZK_GUIA
		MsUnlock()
	   
	   ELSE
	   
	    //grava log chamado 041202 - WILLIAM COSTA 23/04/2018
		u_GrLogZBE (Date(),TIME(),cUserName,"ELSE RecLock(SZK,.F.)","LOGISTICA","AROTE",;
		"Filial: "+xFilial("SZK")+" Data: "+DTOS(_dDTE)+" Placa: "+_cPlac+" Roteiro: "+_cRot_Atu+" ZK_ENTREGA: "+CVALTOCHAR(_RotEntr),ComputerName(),LogUserName())
	    		
	   Endif
	   
	   // Vou na Guia Registar a Data de Entrega
	   dbSelectArea("ZV2")
	   dbSetOrder(1)     // ZV2_GUIA]
	   If dbSeek(xFilial("ZV2")+_cGuia)
		RecLock("ZV2",.F.)
		Replace ZV2_ROTEIRO With _cRote
		Replace ZV2_PFATU   With _RotPeso
		// Altero para nao permitir a primeira pesagem novamente
		Replace ZV2_STATUS  With "2"
		MsUnlock()
	   Endif
	
	Endif
	
	//grava log/alteracao de bairro	    &&Mauricio - Chamado 036566 - corrigido nome rotina e campos gravados no log.
	u_GrLogZBE (Date(),TIME(),cUserName," ALTERAR ROTEIRO","LOGISTICA","GravaRote",;
	         	"PEDIDO: "+SC5->C5_NUM+" ROTEIRO/SEQ DE: "+_cRot_Atu+" "+_cSeq_Atu+" PARA: "+_cRote+" "+_cSequ + " Qtd: " + cvaltochar(_nQt),;
	           	ComputerName(),LogUserName()) 
		 
	Close(Odlg1)

Return(.T.)
          
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Peso Roteiro ³ Peso e Entregas do Roteiro         Advanced Protheus nao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Marcos Bido  ³ 17/05/02 ³ Totalizacao de Peso e entregas               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RotePeso()

	//Ricardo Lima-19/02/2019-047354
	Local cQueryP       := ""

	dbSelectArea("SC5")
	_Registro := Recno()
	_RotPeso  := 0              // C5_PBRUTO
	_PLiqTot  := 0				// C5_PESOL
	_RotEntr  := 0
	//dbSetOrder(6)  && ALterado indice de somente filial+roteiro para filial+data entrega+roteiro (indice 9) Mauricio HC Consys - 22/02/10.
	//dbSetOrder(9)
	SC5->(DBORDERNICKNAME("SC5_9")) //atualização protheus 12 WILLIAM COSTA 28/12/2017 CHAMADO 036032
	
	// Ricardo Lima-19/02/2019-047354
	// Ricardo Lima-27/02/2019-047506
	IF SC5->C5_XTIPO = '2'
		cQueryP := " SELECT C5_FILIAL, C5_NUM, C5_DTENTR, C5_ROTEIRO "
		cQueryP += " FROM "+RetSqlName("SC5")+" "
		cQueryP += " WHERE C5_FILIAL = '"+FWxFilial("SC5")+"' AND C5_XTIPO = '2' "
		cQueryP += " AND C5_NOTA = '' AND C5_NUM <> '"+SC5->C5_NUM+"' "
		cQueryP += " AND C5_ROTEIRO = '"+_cRote+"' AND C5_DTENTR = '"+DtoS(_dtEntr)+"' "
		cQueryP += " AND D_E_L_E_T_ = ' ' "
		If Select("tSC5p") > 0
			DbSelectArea("tSC5p")
			tSC5p->(DbCloseArea())
		Endif
		TCQUERY cQueryP NEW ALIAS "tSC5p"
		
		If !Empty(tSC5p->C5_NUM)
			ApMsgInfo('Para Pedido do Tipo Diversos não Pode Existir mais de um Pedido com o mesmo Roteiro e Data de Entrega, Altere a data de entrega ou o Roteiro','Pedido de Venda Diversos')
			
			dbSelectArea("SC5")
			dbGoto(_Registro)
			DlgRefresh(oDlg1)
			Return(.F.)
		EndIf	
	ENDIF
	// Ricardo Lima-19/02/2019-047354
	dbSelectArea("SC5")
	SC5->(DBORDERNICKNAME("SC5_9"))
	
	//If dbSeek( xFilial("SC5")+_cRote ,.T. ) 
	If dbSeek( xFilial("SC5")+Dtos(_dtEntr)+_cRote ,.T. )     && Incluido data de entrega Mauricio HC Consys - 22/02/10.
		Do While !Eof() .and. SC5->C5_FILIAL==xFilial("SC5") .and. SC5->C5_ROTEIRO == _cRote .and. SC5->C5_DTENTR == _dtEntr  && Incluido data de entrega Mauricio HC Consys - 22/02/10.
			_RotPeso := _RotPeso + C5_PBRUTO
			_PLiqTot := _PLiqTot + C5_PESOL
			_RotEntr := _RotEntr + 1
			dbSelectArea("SC5")
			dbSkip()
		Enddo
		@ 110,010 SAY "Peso Roteiro :  " ;  @ 110,060 SAY Transform(_RotPeso, "@R 999,999.999")
		@ 120,010 SAY "Num. Entregas:  " ;  @ 120,060 SAY Transform(_RotEntr, "@R 999,999,999")
		@ 130,105 SAY "Entrega : " 
		@ 130,135 SAY dtoc(_dtEntr)  
	
	Endif
	
	dbSelectArea("SC5")
	dbGoto(_Registro)
	DlgRefresh(oDlg1)
	
Return(.T.)
