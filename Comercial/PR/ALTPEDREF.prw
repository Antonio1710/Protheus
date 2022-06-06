#include "TOTVS.CH"
#include "TOPCONN.CH" 
#include "RWMAKE.CH"

/*/{Protheus.doc} User Function ALTPEDREF
	Alterar o campo C5_REFATUR para pedidos de Refaturamento
	@type  Function
	@author TOTVS
	@since 
	@version 01
	@history Chamado 050332 - Fernando Sigoli  - 09/07/2019 - Validar somente itens do pedido de origem que nao sofreram corte total C6_UNSVEN > 0  
	@history Chamado 050332 - Fernando Sigoli  - 09/07/2019 - Libera refaturamento do pedido, somente se o mesmo nao estiver enviado para o Edata. Necessario Estorno Colocamos validação de estado, por motivo de cargas interestudual que fatura antes do carregamento, devido a recolhimento de guias
	@history Chamado 054471 - Adriano Savoine  - 26/12/2019 - Liberar o Refaturamento para pedidos diferentes do Tipo N na C5_TIPO.
	@history Chamado T.I    - William Costa    - 20/01/2020 - Retirado trava de quando o caminhão não tiver sido enviado para o Edata de acordo a Rosangela.
	@history Ticket  T.I    - Fernando Sigoli  - 22/11/2021 -  Correção do ErrorLog variable does not exist LRET on OOKREFT(ALTPEDREF.PRW) 31/01/2020 15:58:03 line : 359
	@history @history Ticket 69574   - Abel Bab - 21/03/2022 - Projeto FAI	
/*/

User Function ALTPEDREF(cOp,nRopc,sObs) 
        
	Local aItens 	:= {}
	Local lRet   	:= .T.
	Private cPedido := SC5->C5_NUM
	Private cRefatu := SC5->C5_REFATUR
	Private cOpc    := cOp
	Private sObsApr := sObs
	Private cEstCli := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE + SC5->C5_LOJACLI,"A1_EST") //Chamado: 050332 - Fernando Sigoli 09/07/2019 

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Alterar o campo C5_REFATUR para pedidos de Refaturamento')

	//Inicio chamado : 036627 - Fernando Sigoli  10/08/2017
	//If Alltrim(SC5->C5_NOTA) = "" .and. Alltrim(__cUserId) $ GETMV("MV_IDREFAT") //Chamado: 050332 - Fernando Sigoli 09/07/2019 
		
	If (Empty(Alltrim(SC5->C5_X_SQED)) .or. Alltrim(cEstCli) <> 'SP')  .and. Alltrim(SC5->C5_NOTA) = "" .and. Alltrim(__cUserId) $ GETMV("MV_IDREFAT")
		
		//Inicio: Chamado: 050332 - Fernando Sigoli 09/07/2019 
		If Empty(Alltrim(SC5->C5_X_SQED)) .and. Alltrim(cEstCli) <> 'SP' .and. (SC5->C5_TIPO) == 'N' // CHAMADO: 054471 POR ADRIANO SAVOINE
		
			ApMsgInfo(OemToAnsi('Pedido fora do Estado de SP. Por favor, verificar se necessário enviar a carga para o Edata antes do refaturamento, * recolhimento de guia *, Atenção!!'))

		EndIf
		//Fim: Chamado: 050332 - Fernando Sigoli 09/07/2019 
		
		if cOpc = 'P'
			
			DEFINE DIALOG oDlg TITLE "Refaturamento" FROM 150,150 TO 300,370 PIXEL    
				nRadio := 1
				aItems := {'Cliente','Transportador','Ceres','Outros'}    
				oRadio := TRadMenu():New (10,10,aItems,,oDlg,,,,,,,,100,12,,,,.T.)     
				oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)} 
				
				@ 60,10 BUTTON "&OK" SIZE 33,14   PIXEL ACTION EVAL({|| oOKREFT(),oDlg:End()})
				@ 60,50 BUTTON "&Sair" SIZE 33,14 PIXEL ACTION oDlg:End() 
			ACTIVATE DIALOG oDlg CENTERED 
		
		Else
		
			nRadio := nRopc
			lRet := oOKREFT()
		
		Endif
		
	Else
		
		//inicio: Chamado: 050332 - Fernando Sigoli 09/07/2019 
		If !Empty(Alltrim(SC5->C5_X_SQED)) 
		
			if cOpc = 'P'
				ApMsgInfo(OemToAnsi('Carga '+ Alltrim(cValToChar(SC5->C5_X_SQED))  +' encontra-se no Edata. Necessário estorno para refaturamento, Verifique!!'))
			Else
				sMsgpRet := 'Carga '+Alltrim(cValToChar(SC5->C5_X_SQED))+' encontra-se no Edata. Necessário estorno para refaturamento, Verifique!!'
			Endif
		
			lRet := .F.
		
		Else
		//Fim: Chamado: 050332 - Fernando Sigoli 09/07/2019 	
			if cOpc = 'P'
				ApMsgInfo(OemToAnsi('Pedido já faturado, Verifique!!'))
			Else
				sMsgpRet := 'Pedido já faturado, Verifique!!'
			Endif
		
			lRet := .F.
		
		EndIf
		
	Endif                  
	//Fim chamado : 036627 - Fernando Sigoli  10/08/2017

Return(lRet)

//chamado : 036627 - Fernando Sigoli  10/08/2017
Static Function oOKREFT()

	Local cLocPad := ""
	Local cLocOri := ""
	Local cTitulo := ""
	Local cProdut := ""
	Local lAltera := .F. 
	Local cNfDevo := ""
	Local lCont   := .F.
	Local lRet    := .F. // Ticket  T.I    - Fernando Sigoli  - 22/11/2021 - Declaração da variavel
	Local cEmpRN:= GetMv("MV_#RNEMP",,"01|02|") //Ticket 69574   - Abel Bab - 21/03/2022 - Projeto FAI

	If nRadio = 1
		cLocPad := GetMv("MV_#LCPCLI")  //Cliente 46
		cTitulo := "CLIENTE"
	ElseIf nRadio = 2					//transportador 45
		cLocPad := GetMv("MV_#LPTRAN")
		cTitulo := "TRANPORTADOR"
	ElseIf nRadio = 3              		//ceres - Indicador de produto ou sb1
		cTitulo := "CERES"
	ElseIf nRadio = 4              		//outros - Indicador de produto ou sb1
		cTitulo := "Outros"
	EndIf

	if cOpc = 'P'

		If MSGYESNO("Deseja alterar o pedido para refaturamento do Tipo "+cTitulo)
			lCont := .T.
		Endif

	Else

		lCont := .T.

	Endif

	if lCont
		
		//Mauricio - 20/10/2017 - Chamado 037330
		lRet := .T.
		if Alltrim(cEmpAnt) $ cEmpRN
			
			_cPedAt   := SC5->C5_NUM
			_lquatro  := .F.
			_lrfat    := .T.
			_lTresPed := .F.
			
			If Empty(SC5->C5_XREFATD) .and. (nRadio = 1)
				if cOpc = 'P'
					ApMsgInfo(OemToAnsi('Atencão!! Refaturamento para '+ iif(nRadio = 1,'Cliente','transportador')+ ' é necessario viculo com o pedido Original. Verifique!!'))
				Else
					sMsgpRet := 'Atencão!! Refaturamento para '+ iif(nRadio = 1,'Cliente','transportador')+ ' é necessario viculo com o pedido Original. Verifique!!'
				Endif
				Return .F.
			EndIf
			
			If !Empty(SC5->C5_XREFATD)  //pedido original que foi refaturado
				
				cNfDevo := ValDevPed(SC5->C5_XREFATD)
				
				If Empty(cNfDevo) .and. (nRadio = 1)
					if cOpc = 'P'
						ApMsgInfo(OemToAnsi('Atencão!! Pedido Original do refaturamento '+Alltrim(SC5->C5_XREFATD)+' nao encontrado entrada de devolução. Verifique!!'))
					Else
						sMsgpRet := 'Atencão!! Pedido Original do refaturamento '+Alltrim(SC5->C5_XREFATD)+' nao encontrado entrada de devolução. Verifique!!'
					EndIF
					lRet := .F.
				EndIf
		
				_cPedExist := fverped(SC5->C5_XREFATD) //verificar se o pedido ja foi usado
				
				If Empty(_cPedExist) .Or. _cPedExist == SC5->C5_NUM
					if cOpc = 'P'
						ApMsgInfo(OemToAnsi('Atencão!! Pedido Original do refaturamento '+Alltrim(SC5->C5_XREFATD)+' não encontrado ou incorreto. Verifique!!'))
					Else
						sMsgpRet := 'Atencão!! Pedido Original do refaturamento '+Alltrim(SC5->C5_XREFATD)+' não encontrado ou incorreto. Verifique!!'
					Endif
					lRet := .F.
				EndIf
				
				If Select("TSC5") > 0
					DbSelectArea("TSC5")
					DbCloseArea("TSC5")
				Endif
				
				_nTVLPDATU := 0
				_nTQTPDATU := 0
				_nTQTPDAC := 0
				_nTQTPDOR := 0
				_nTVLPDAC := 0
				_nTVLPDOR := 0
				_aProdOR  := {}
				_aProdFRT := {}
				_cPDFATS  := ""
				_aCompOr  := {}
				_aCompRF  := {}
				
				fbscPed(SC5->C5_XREFATD,_lrfat)
				
				//Valido a quantidade...
				If (_nTQTPDAC + _nTQTPDATU) > _nTQTPDOR
					if cOpc = 'P'
						ApMsgInfo(OemToAnsi('Refaturamento!! A quantidade no(s) pedido(s) '+Alltrim(_cPDFATS) +' é maior do que no pedido original '+Alltrim(SC5->C5_XREFATD)+' . Verifique!!'))
					Else
						sMsgpRet := 'Refaturamento!! A quantidade no(s) pedido(s) '+Alltrim(_cPDFATS) +' é maior do que no pedido original '+Alltrim(SC5->C5_XREFATD)+' . Verifique!!'
					Endif				
					lRet := .F.
				Endif
				
				If (_nTQTPDAC + _nTQTPDATU) < _nTQTPDOR
					if cOpc = 'P'
						ApMsgInfo(OemToAnsi('Refaturamento!! A quantidade no(s) pedido(s) '+Alltrim(_cPDFATS) +' é menor do que no pedido original '+Alltrim(SC5->C5_XREFATD)+'. Verifique!!'))
					Else
						sMsgpRet := 'Refaturamento!! A quantidade no(s) pedido(s) '+Alltrim(_cPDFATS) +' é menor do que no pedido original '+Alltrim(SC5->C5_XREFATD)+'. Verifique!!'
					Endif
					lRet := .F.
				Endif
				
				//Valido o valor....maximo de percentual permitido abaixo do valor original vindo de parametro.
				_nValP := GETMV("MV_XPERCRF")
				If (_nTVLPDAC + _nTVLPDATU) < (_nTVLPDOR * ((100 - _nValP)/100))
					if cOpc = 'P'
						If !ApMsgNoYes(OemToAnsi('Refaturamento!! O valor total no(s) pedido(s) '+Alltrim(_cPDFATS) +' é menor do que o permitido no refaturamento do '+Alltrim(SC5->C5_XREFATD)+'. Verifique!!'))
							lRet := .F.
						Else
							lRet := .T.
						EndIf
					Else
						
						//Everson - 28/11/2018. Chamado 044815.
						If ! lDecisao
							lRet := .F.
							sMsgpRet := '[COD001] Refaturamento!! O valor total no(s) pedido(s) '+Alltrim(_cPDFATS) +' é menor do que o permitido no refaturamento do '+Alltrim(SC5->C5_XREFATD)+'. Verifique!!'
						
						Else
							lRet := .T.
							
						EndIf
						
					Endif			
				Endif
				
				//validação de produto e quantidade
				//Quando muda o refaturamento o numero maximo de pedidos(3)ja  foram colocados, validacao completa
				//valido produtos e quantidades
				For _nz := 1 to len(_aCompRF)  //refaturados
					_nAscan := Ascan( _aCompOR, { |x|x[ 01 ] == _aCompRF[_nz][1] } )
					If _nAscan <= 00    //produto não existe no pedido original
						if cOpc = 'P'
							ApMsgInfo(OemToAnsi('Refaturamento!! O produto '+Alltrim(_aCompRF[_nz][1]) +' não existe no pedido original '+Alltrim(SC5->C5_XREFATD)+'. Verifique!!'))
						Else
							sMsgpRet := 'Refaturamento!! O produto '+Alltrim(_aCompRF[_nz][1]) +' não existe no pedido original '+Alltrim(SC5->C5_XREFATD)+'. Verifique!!'
						Endif
						lRet := .F.
					Else
						IF _aCompOR[_nAscan][2] <> _aCompRF[_nz][2]  //como é terceiro pedido a quantidade precisa bater
							if cOpc = 'P'
								ApMsgInfo(OemToAnsi('Refaturamento!! A quantidade do produto '+Alltrim(_aCompRF[_nz][1]) +' não bate com a quantidade no pedido original '+Alltrim(SC5->C5_XREFATD)+'. Verifique!!'))
							Else
								sMsgpRet := 'Refaturamento!! A quantidade do produto '+Alltrim(_aCompRF[_nz][1]) +' não bate com a quantidade no pedido original '+Alltrim(SC5->C5_XREFATD)+'. Verifique!!'
							Endif
							lRet := .F.
						Endif
					Endif
				Next _nZ
				For _nz := 1 to len(_aCompOR)  //refaturados
					_nAscan := Ascan( _aCompRF, { |x|x[ 01 ] == _aCompOR[_nz][1] } )
					If _nAscan <= 00    //produto não existe no pedido original
						if cOpc = 'P'
							ApMsgInfo(OemToAnsi('Refaturamento!! O produto '+Alltrim(_aCompOR[_nz][1])+' esta faltando nos pedidos de refaturamento. Verifique!!'))
						Else
							sMsgpRet := 'Refaturamento!! O produto '+Alltrim(_aCompOR[_nz][1])+' esta faltando nos pedidos de refaturamento. Verifique!!'
						Endif
						lRet := .F.				
					Endif
				Next _nZ			
			Endif
		Endif
		
		If lRet
			//Fim 037330
			//atualiza sc5
			Reclock("SC5",.F.)
			SC5->C5_REFATUR := 'S'
			SC5->C5_XTIPREF := nRadio
			SC5->C5_XOBSRFA := Alltrim(SC5->C5_XOBSRFA) + Alltrim(sObsApr) + ', '
			SC5->C5_XAPREFA := 'N'
			MsUnlock()
			memowrite("\LOGREFAT\"+SC5->C5_NUM+STRTRAN(Dtoc(date()),"/","")+SUBSTR(STRTRAN(time(),":",""),1,4)+".LOG",alltrim(cusername)+" - "+SC5->C5_NUM)
			
			//grava log
			u_GrLogZBE (Date(),TIME(),cUserName," LIBERAÇÃO PEDIDO PARA REFATURAMENTO MANUAL ","FISCAL","ALTPEDREF",;
			"PEDIDO: "+SC5->C5_NUM+" REFATURAMENTO DE: " +cRefatu+ " PARA: "  +SC5->C5_REFATUR,;
			ComputerName(),LogUserName()+iif(cOpc='M',', Aprovação Mobile','') )
			
			DbSelectArea("SC9")
			DbSetOrder(1)
			
			DbSelectArea("SC6")
			DbSetOrder(1)
			If dbSeek( xFilial("SC6")+cPedido )
				Do While !Eof() .and. SC6->C6_FILIAL==xFilial("SC6") .and. SC6->C6_NUM =cPedido
					cLocOri := SC6->C6_LOCAL    //guarda o local do pedido
					If nRadio == 1 .or. nRadio == 2
						//tratamento para criar armazem no SB2 - destino
						SB2->(DbSetOrder(1))
						If !SB2->(DbSeek( xFilial("SB2") + SC6->(C6_PRODUTO) + cLocPad ))
							CriaSB2(SC6->(C6_PRODUTO),cLocPad)
						EndIf
						lAltera := .T.
					ElseIf nRadio == 3 .or. nRadio == 4	
						If Alltrim(SC6->C6_LOCAL) $ GetMv("MV_#LCPCLI") .or. Alltrim(cLocOri) $ GetMv("MV_#LPTRAN")
							If !RetArqProd(SC6->C6_PRODUTO)
								cLocPad := POSICIONE("SBZ",1,xFilial("SBZ")+SC6->C6_PRODUTO,"BZ_LOCPAD")
							Else
								cLocPad := POSICIONE("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_LOCPAD")
							EndIF
							//tratamento para criar armazem no SB2 - destino
							SB2->(DbSetOrder(1))
							If !SB2->(DbSeek( xFilial("SB2") + SC6->(C6_PRODUTO) + cLocPad ))
								CriaSB2(SC6->(C6_PRODUTO),cLocPad)
							EndIf
							lAltera := .T.
						EndIf	
					EndIf
					
					If lAltera	
						RecLock("SC6",.F.)
						SC6->C6_LOCAL := cLocPad
						MsUnlock()
						
						DbSelectArea("SC6")
						nOrden = IndexOrd() //guardar a orden
						nRecno := Recno()
						
						DbSelectArea("SC9")  //altera a SC9
						DbSetOrder(1)
						DbGoTop()
						If dbSeek(xFilial("SC9")+cPedido)
							While !Eof() .And. SC9->C9_PEDIDO == cPedido
								If SC9->C9_PRODUTO == SC6->C6_PRODUTO
									Reclock("SC9",.F.)
									SC9->C9_LOCAL := SC6->C6_LOCAL
									MsUnlock()
								EndIf
								DbSkip()
							EndDo
						EndIf
						
						DbSelectArea("SC6")
						DbSetOrder(nOrden)  //retorno a ordem
						DbGoto(nRecno)
						
						//grava log sobre a alteraçao
						u_GrLogZBE (Date(),TIME(),cUserName," LIBERAÇÃO PEDIDO PARA REFATURAMENTO MANUAL/ALTERA LOCAL ","FISCAL","ALTPEDREF",;
						"PEDIDO: "+cPedido+ " PRODUTO "+ SC6->C6_PRODUTO +" LOCAL DE :" +cLocOri+ " PARA : "+cLocPad,;
						ComputerName(),LogUserName())
						
					EndIf
					
					DbSkip()
				Enddo
				
			Endif
		Endif
		
	EndIf

Return(lRet)

//Mauricio - Chamado 037330 - verifica se o numero do pedido informado existe.
Static Function fVerPed(cPedido)

	Local cNumPed := ""                  
	Local cQry 	  := "SELECT C5_NUM AS NUMPEDIDO FROM "+retSqlName("SC5")+" WITH (NOLOCK) WHERE D_E_L_E_T_ =' ' AND C5_FILIAL = '" + xFilial("SC5") + "' AND C5_NUM = '"+cPedido+"'"
	TcQuery cQry new alias "C5QRY" 

	dbSelectArea( "C5QRY" )
	dbGoTop()
	cNumPed:= C5QRY->NUMPEDIDO

	dbclosearea("C5QRY")
	
	Return(cNumPed)  

	Static function fbscPed(cPedido,_lrfat)
				
	Local cQry 	  := "SELECT C5_XPEDGER FROM "+retSqlName("SC5")+" WITH (NOLOCK) WHERE D_E_L_E_T_ =' ' AND C5_FILIAL = '" + xFilial("SC5") + "' AND C5_NUM = '"+cPedido+"'"
	TcQuery cQry new alias "TSC5" 

	dbSelectArea( "TSC5" )
	dbGoTop()
	If TSC5->(!Eof())
	_cPDFATS := TSC5->C5_XPEDGER    //pedidos refaturados vinculados ao pedido original
	Endif

	//Mauricio - tratamento para considerar o numero do pedido atual, retirado acima...
	IF _lrfat
		DbCloseArea("TSC5")
			
		_cPed1 := ""
		_cPed2 := ""
		_cPed3 := ""
			
		IF Len(Alltrim(_cPDFATS)) > 6  //tem mais de um pedido
			for _nx := 1 to len(Alltrim(_cPDFATS))   // maximo são 3 pedidos
				If _nx == 1
					_cPed1 := Substr(Alltrim(_cPDFATS),1,6)
					_nx := 7
				Elseif _nx == 8
					_cPed2 := Substr(Alltrim(_cPDFATS),8,6)
					_nx := 14
				elseif _nx == 15
					_cPed3 := Substr(Alltrim(_cPDFATS),15,6)
					_nx := 28
				Endif
			next _nx
		Else
			_cPed1 := Alltrim(_cPDFATS)
		Endif
	Endif		

	If !Empty(_cPed3)
	_lTresPed := .T.     //Ja existem 3 pedidos do comercial colocados
	endif   
	

	//apuro todos os produtos e quantidades dos pedidos refaturados
	_aProdRFT := {}

	//Busco o valor total e quantidade total do pedido atual posicionado
	_nTVLPDATU := 0
	_nTQTPDATU := 0
	DbSelectArea("SC6")
	DbSetOrder(1)
	If dbSeek( xFilial("SC6")+SC5->C5_NUM )

		While SC6->(!Eof()) .and. SC6->C6_FILIAL==xFilial("SC6") .and. SC6->C6_NUM = SC5->C5_NUM .and. SC6->C6_UNSVEN > 0 //Chamado: 050332 - Fernando Sigoli 09/07/2019  
				_nTVLPDATU += SC6->C6_VALOR
				_nTQTPDATU += SC6->C6_QTDVEN
				AADD(_aProdRFT,{SC6->C6_PRODUTO,SC6->C6_QTDVEN})	                              		    
				SC6->(dbSkip())
		Enddo
		
		//Verifico a quantidade e valor do pedido original que esta sendo refaturado
		_nTVLPDOR := 0
		_nTQTPDOR := 0

		If Select("TSC6") > 0
			DbSelectArea("TSC6")
			DbCloseArea("TSC6")
		Endif
			
		//Soma quantidade e valor do pedido original
		_cQuery  := "SELECT SUM(C6_QTDVEN) AS TOTQTD, SUM(C6_VALOR) AS TOTVLR  "
		_cQuery  += "FROM "+RetSqlName("SC6")+" C6 "
		_cQuery  += "WHERE C6.D_E_L_E_T_ <> '*' AND C6.C6_NUM = '"+cPedido+"'"   
		_cQuery  += "AND C6.C6_UNSVEN > 0 AND C6.C6_FILIAL = '"+cfilAnt+"' "  //Chamado: 050332 - Fernando Sigoli 09/07/2019 
		TCQUERY _cQuery NEW ALIAS "TSC6"
			
		DbSelectArea("TSC6")
		TSC6->(dbgotop())
		_nTQTPDOR := TSC6->TOTQTD
		_nTVLPDOR := TSC6->TOTVLR
			
		DbCloseArea("TSC6")

		//Verifico agora o valor total e quantidade de todos os pedidos refaturados vinculados ao pedido original
		_nTVLPDAC := 0
		_nTQTPDAC := 0

		If SC5->C5_NUM == _cPed1
			_cIN := "'"+_cPed2+"','"+_cPed3+"'"
		Elseif SC5->C5_NUM == _cPed2
			_cIN := "'"+_cPed1+"','"+_cPed3+"'"
		Else
			_cIN := "'"+_cPed1+"','"+_cPed2+"'"
		Endif

		If Select("TSC6") > 0
			DbSelectArea("TSC6")
			DbCloseArea("TSC6")
		Endif
			
		//Soma quantidade do pedido
		_cQuery  := "SELECT SUM(C6_QTDVEN) AS TOTQTD, SUM(C6_VALOR) AS TOTVLR  "
		_cQuery  += "FROM "+RetSqlName("SC6")+" C6 "
		_cQuery  += "WHERE C6.D_E_L_E_T_ <> '*' AND C6.C6_NUM IN("+_cIN+") "   
		_cQuery  += "AND C6.C6_UNSVEN > 0 AND C6.C6_FILIAL = '"+cfilAnt+"' "    //Chamado: 050332 - Fernando Sigoli 09/07/2019 
		TCQUERY _cQuery NEW ALIAS "TSC6"
			
		DbSelectArea("TSC6")
		TSC6->(dbgotop())
		_nTQTPDAC := TSC6->TOTQTD
		_nTVLPDAC := TSC6->TOTVLR
			
		DbCloseArea("TSC6")

		If _lrfat
			//apuro todos os produtos e suas quantidades do pedido original
			_aProdOr := {}
			
			If Select("TSC6") > 0
				DbSelectArea("TSC6")
				DbCloseArea("TSC6")
			Endif
			
			_cQuery  := "SELECT C6_PRODUTO, C6_QTDVEN "
			_cQuery  += "FROM "+RetSqlName("SC6")+" C6 "
			_cQuery  += "WHERE C6.D_E_L_E_T_ <> '*' AND C6.C6_NUM = '"+cPedido+"'"
			_cQuery  += "AND C6.C6_UNSVEN > 0 AND C6.C6_FILIAL = '"+cfilAnt+"' " //Chamado: 050332 - Fernando Sigoli 09/07/2019
			TCQUERY _cQuery NEW ALIAS "TSC6"
			
			DbSelectArea("TSC6")
			TSC6->(dbgotop())
			While TSC6->(!Eof())
					AADD(_aProdOR,{TSC6->C6_PRODUTO,TSC6->C6_QTDVEN})
					TSC6->(dbSkip())
			Enddo
			
			DbCloseArea("TSC6")
							
			If SC5->C5_NUM == _cPed1
				_cIN := "'"+_cPed2+"','"+_cPed3+"'"
			Elseif SC5->C5_NUM == _cPed2
				_cIN := "'"+_cPed1+"','"+_cPed3+"'"
			Else
				_cIN := "'"+_cPed1+"','"+_cPed2+"'"
			Endif
				
			If Select("TSC6") > 0
				DbSelectArea("TSC6")
				DbCloseArea("TSC6")
			Endif
			
			_cQuery  := "SELECT C6_PRODUTO, C6_QTDVEN "
			_cQuery  += "FROM "+RetSqlName("SC6")+" C6 "
			_cQuery  += "WHERE C6.D_E_L_E_T_ <> '*' AND C6.C6_NUM IN("+_cIN+") "
			_cQuery  += "AND C6.C6_UNSVEN > 0 AND C6.C6_FILIAL = '"+cfilAnt+"' "    //Chamado: 050332 - Fernando Sigoli 09/07/2019
			TCQUERY _cQuery NEW ALIAS "TSC6"
			
			DbSelectArea("TSC6")
			TSC6->(dbgotop())
			While TSC6->(!Eof())
					AADD(_aProdRFT,{TSC6->C6_PRODUTO,TSC6->C6_QTDVEN})
					TSC6->(dbSkip())
			Enddo
			
			DbCloseArea("TSC6")
			
			_aCompOr  := {}
			_aCompRF  := {}
			
			//equalizo os arrays acima em um novo array para resolver problema de possiveis produtos repetidos em itens diferentes
			//aonde no caso preciso validar a quantidade por produto...
			For _nz := 1 to len(_aProdOr)
				_nAscan := Ascan( _aCompOR, { |x|x[ 01 ] == _aProdOR[_nz][1] } )
				If _nAscan <= 00
					Aadd( _aCompOR, { _aProdOR[_nz][1],_aProdOR[_nz][2] } )     //incluo registro inexistente
				Else
					_aCompOr[_nAscan][2] += _aProdOR[_nz][2]                    //soma quantidade para produto ja existente
				Endif				    
			Next _nz
			
			For _nz := 1 to len(_aProdRFT)
				_nAscan := Ascan( _aCompRF, { |x|x[ 01 ] == _aProdRFT[_nz][1] } )
				If _nAscan <= 00
					Aadd( _aCompRF, { _aProdRFT[_nz][1],_aProdRFT[_nz][2] } )     //incluo registro inexistente
				Else
					_aCompRF[_nAscan][2] += _aProdRFT[_nz][2]                    //soma quantidade para produto ja existente
				Endif				    
			Next _nz
		endif				
	endif
   
Return() 

//verifica se o pedido que esta sendo liberado para refaturamento, o pedido de origem ja foi feito documento de entrada
//fernando sigoli 24/10/2017
Static Function ValDevPed(cPedido)

	Local cQury 	:= ""
	Local cNfori	:= ""

	cQury += " SELECT D1_NFORI "
	cQury += " FROM "+RetSqlName("SC5")+" SC5 INNER JOIN "+RetSqlName("SD1")+" SD1 "
	cQury += " ON SC5.C5_FILIAL = SD1.D1_FILIAL AND SC5.C5_CLIENTE = SD1.D1_FORNECE AND "
	cQury += " SC5.C5_LOJACLI = D1_LOJA AND SC5.C5_NOTA = SD1.D1_NFORI "
	cQury += " AND SC5.D_E_L_E_T_ = '' AND SD1.D_E_L_E_T_ = '' "
	cQury += " WHERE "
	cQury += " C5_FILIAL = '"+cfilAnt+"' "
	cQury += " AND C5_NUM = '"+cPedido+"' "
	cQury += " GROUP BY D1_NFORI "       
	
	TCQUERY cQury NEW ALIAS "SD1SC5"
	
	DbSelectArea("SD1SC5")
	SD1SC5->(dbgotop())
	cNfori := SD1SC5->D1_NFORI
		
	DbCloseArea("SD1SC5")

Return cNfori
