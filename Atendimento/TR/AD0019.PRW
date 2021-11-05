#include "rwmake.ch"
#include "protheus.ch"
#include "font.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function AD0019
	Alteracao das devolucoes
	@author user
	@since 03/04/2006
	@history Chamado 044314 - Ricardo Lima    - 02/02/2018 - Controle de devolucao, nao permite gerar pedido com quantidade maior que o pedido origem
	@history Chamado 044314 - Everson         - 21/03/2019 - Lançamento de desconto de transportador no controle de frete
	@history Chamado 044314 - Everson         - 26/03/2019 - Correção da declaração de variáveis
	@history Chamado TI     - Adriana         - 24/05/2019 - Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM
	@history Chamado 1751   - William Costa   - 18/09/2020 - Identificado que uma ocorrencia de quebra que é lançado duas vezes não vai para a tela de aprovaçaõ de cliente o novo valor de desconto lançado, ajustado isso.
	@history ticket  TI     - Adriano Savoine - 29/01/2021 - Quando pedido de pagamento antecipado é reprogramado, o mesmo nasce liberado estoque, credito e pagamento realizado C5_XWSPAGO = 'M'
	@history ticket  9579   - Fernando Macieir- 17/02/2021 - type mismatch on *  on U_AD0019(AD0019.PRW) 29/01/2021 11:47:55 line : 821
	@history ticket  T.I	- Sigoli	      - 03/11/2021 -  removido o email monitor.sistemas@adoro.com.br de receber este workflow 
/*/
USER FUNCTION AD0019(nOpc)     

	Local lSalesForce 	:= .F.
	Local cNFSF		  	:= ""
	Local cSerieSF	  	:= ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Alteracao das devolucoes')

	//Posicionamento original dos arquivos envolvidos              

	_cAlias      := Alias()
	_cOrder      := IndexOrd()
	_cRecno      := Recno()
	_cAutNome	 := cusername
	_cNomeHora 	 := DTOC(Ddatabase)+" "+ Time()+" "+ cusername
	_cObs_It     := ""
	_cMot        := ""
	_nCont       := 0
	_nQtdDev     := 0
	_nQuant      := 0
	_nTotDev     := 0
	_nQuebra     := 0
	_cITEMNF     := ""
	_cMot_Ok     := space(2)

	_cCodRespons := ""
	_cMotivo     := ""

	_cRespNome   := ""
	_cDescMotiv  := ""

	_dData       :=  Ddatabase
	_cNomeHora   :=	DTOC(Ddatabase)+" "+ Time()+" "+ cusername
	_cCodRespons := ""
	_cMotivo     :=""
	_cRespNome   :=""
	_cDescMotiv  :=""
	_cResp1      := ""
	_cPedPern    := ""
	_cPern       := .F.
	_cCodPer     := ""
	_cMTVPer	 := ""
	_cCodCTRL    := Space(15)
	_cFlag       := "00"
	_cPL	     := Chr(13)+Chr(10)
	_aNfs 		 := {}
	
	//Everson - 26/03/2019-044314.
	Private _lRet := .F.
	Private nOpcE := 0
	//

	Private lAltSZX 	:= .F.
	Private cNumPedOri := "" // Ricardo Lima - 02/02/18
	Private cNotaExcluir 
	Private cSerieExcluir

	// Eduardo Nakamatu/Biale (Manutencao)- Inclusao de Devolucao
	
	do case
	
		case nOpc = 'I'

		_Perg:="DEVOL1"

		If !Pergunte(_Perg,.T.)
			Return Nil
			
		EndIf

		DbSelectArea("SC5")
		DbSetOrder(1)
		If DbSeek(xFilial("SC5") + mv_par01  )
		
			_aNfs       := 	u_traznfs(SC5->C5_FILIAL + SC5->C5_NUM)
			_cNumPedido	:= 	C5_NUM
			_cRoteiro	:= 	C5_ROTEIRO
			_cPlaca		:= 	C5_PLACA
			_cSequen	:= 	C5_SEQUENC
			_cVendedor	:= 	C5_VEND1
			_cCodCli  	:=	C5_CLIENTE
			_cLojCli	:=	C5_LOJACLI
			_cNomeCli   :=  C5_NOMECLI
			_cPlacas	:=  C5_XPLACAS
			
			//Mauricio 24/04/13 - buscar dados do motorista a partir da placa do veiculo
			_cNomMot := ""
			_cTelMot := ""
			_cEmlMot := ""
			DbSelectArea("ZV4")
			ZV4->(dbSetOrder(1))
			if dbseek(xFilial("ZV4")+Alltrim(_cPlaca))
				_cCPFM := ZV4_CPF
				If !Empty(_cCPFM)
					DbselectArea("ZVC")
					dbSetOrder(1)
					if dbseek(xfilial("ZVC")+_cCPFM)
						_cNomMot := ZVC->ZVC_MOTORI
						_cTelMot := ZVC->ZVC_TELPRI
						_cEmlMot := ZVC->ZVC_EMLMOT
					Endif
				Endif   
			endif
			
			DbSelectArea("SC5")
			for _ni := 1 to len(_aNfs)
				_cNota		:= 	_aNfs[_ni,1]
				_cSerie		:= 	_aNfs[_ni,2]

				//Mauricio - MDS TEC - 22/11/13 - numero de controle
				_cCodCTRL := Substr(cFilAnt,2,1)+Substr(_cNumPedido,6,1)+Substr(_cNumPedido,5,1)+Substr(_cNumPedido,4,1)+Substr(_cNumPedido,3,1)+;
				Substr(_cNumPedido,2,1)+Substr(_cNumPedido,2,1)+_cNota

				// Gero o Registro
				DbSelectArea("SZD")
				DbSetOrder(1)
				DbGoTop()
				If !dbSeek(xfilial("SZD") + _cNota + _cSerie)
					RecLock("SZD",.T.)
					SZD->ZD_FILIAL		:= xFilial("SZD")
					SZD->ZD_NUMNF		:= _cNota
					SZD->ZD_SERIE		:= _cSerie
					SZD->ZD_CODCLI		:= _cCodCli
					SZD->ZD_LOJA		:= _cLojCli
					SZD->ZD_NOMECLI	    := _cNomeCli
					SZD->ZD_DTDEV		:= _dData
					SZD->ZD_RESPONS	:= _cCodRespons
					SZD->ZD_MOTIVO		:= _cMotivo
					SZD->ZD_AUTNOME	:= _cAutNome
					SZD->ZD_RESPNOM	:= _cRespNome
					SZD->ZD_DESCMOT	:= _cDescMotiv
					SZD->ZD_PEDIDO		:= _cNumPedido
					SZD->ZD_ROTEIRO	:= _cRoteiro
					SZD->ZD_PLACA		:= _cPlaca
					SZD->ZD_SEQUENC	:= _cSequen
					SZD->ZD_DEVTOT		:= "T"
					SZD->ZD_OBSER		:= ""
					SZD->ZD_VEND		:= _cVendedor
					SZD->ZD_MOTORI      := _cNomMot
					SZD->ZD_TELEFON     := _cTelMot
					SZD->ZD_EMLMOT      := _cEmlMot
					SZD->ZD_RESP1       := _cResp1
					SZD->ZD_PEDPERN     := _cPedPern
					SZD->ZD_PERNOIT     := _cPern
					SZD->ZD_MTVPERN     := _cMTVPer
					SZD->ZD_CODMOTP     := _cCodPer
					SZD->ZD_XPLACAS		:= _cPlacas
					IF Empty(SZD->ZD_CONTROL)
						SZD->ZD_CONTROL := _cCodCTRL
						SZD->ZD_NRDEVOL := _cFlag
					Endif   
					MsUnLock()
				Endif
			next
		Else
			Alert("Pedido de Venda " + mv_par01 + " Nao Existe!!")
			return Nil
			
		Endif

		case nOpc = 'O'
		
		// Eduardo Nakamatu/Biale (Manutencao) - operacao chamada pela rotina AD0163
		

		// Forco criar a situacao de inclusao
		// OBS EDUARDO/BIALE
		// NAO FORCO MAIS A INCLUSAO, VERIFICO SE EH ALTERACAO POR
		// EXISTIR ITEM DE ATENDIMENTO

		DbSelectArea("SZX")
		DbSetOrder(2)
		If (dbSeek(xfilial("SZX")+SC5->(C5_NOTA+C5_SERIE)))
			nOpc := 'A'
		ELSE
			nOpc := 'I'
		ENDIF
		
		DbSelectArea("SC5")
		DbSetOrder(1)
		_aNfs       := 	u_traznfs(SC5->C5_FILIAL + SC5->C5_NUM)
		_cNumPedido	:= C5_NUM
		_cRoteiro	:= C5_ROTEIRO
		_cPlaca		:= C5_PLACA
		_cSequen	:= C5_SEQUENC
		_cVendedor	:= C5_VEND1
		_cCodCli  	:=	C5_CLIENTE
		_cLojCli	:=	C5_LOJACLI
		_cNomeCli   := C5_NOMECLI
		_cPlacas	:=  C5_XPLACAS

		//Mauricio 24/04/13 - buscar dados do motorista a partir da placa do veiculo
		_cNomMot := ""
		_cTelMot := ""
		_cEmlMot := ""         
		DbSelectArea("ZV4")
		ZV4->(dbSetOrder(1))
		if dbseek(xFilial("ZV4")+Alltrim(_cPlaca))
			_cCPFM := ZV4_CPF
			If !Empty(_cCPFM)
				DbselectArea("ZVC")
				dbSetOrder(1)
				if dbseek(xfilial("ZVC")+_cCPFM)
					_cNomMot := ZVC->ZVC_MOTORI
					_cTelMot := ZVC->ZVC_TELPRI
					_cEmlMot := ZVC->ZVC_EMLMOT
				Endif
			Endif   
		endif
		DbSelectArea("SC5")
		for _ni := 1 to len(_aNfs)
			_cNota		:= 	_aNfs[_ni,1]
			_cSerie		:= 	_aNfs[_ni,2]

			//Mauricio - MDS TEC - 22/11/13 - numero de controle
			_cCodCTRL := Substr(cFilAnt,2,1)+Substr(_cNumPedido,6,1)+Substr(_cNumPedido,5,1)+Substr(_cNumPedido,4,1)+Substr(_cNumPedido,3,1)+;
			Substr(_cNumPedido,2,1)+Substr(_cNumPedido,2,1)+_cNota

			// Gero o Registro
			DbSelectArea("SZD")
			DbSetOrder(1)
			DbGoTop()
			If !dbSeek(xfilial("SZD") + _cNota + _cSerie)
				RecLock("SZD",.T.)
				SZD->ZD_FILIAL	:= xFilial("SZD")
				SZD->ZD_NUMNF	:= _cNota
				SZD->ZD_SERIE	:= _cSerie
				SZD->ZD_CODCLI	:= _cCodCli
				SZD->ZD_LOJA   	:= _cLojCli
				SZD->ZD_NOMECLI	:= _cNomeCli
				SZD->ZD_DTDEV	:= _dData
				SZD->ZD_RESPONS	:= _cCodRespons
				SZD->ZD_MOTIVO	:= _cMotivo
				SZD->ZD_AUTNOME	:= _cAutNome
				SZD->ZD_RESPNOM	:= _cRespNome
				SZD->ZD_DESCMOT	:= _cDescMotiv
				SZD->ZD_PEDIDO	:= _cNumPedido
				SZD->ZD_ROTEIRO	:= _cRoteiro
				SZD->ZD_PLACA	:= _cPlaca
				SZD->ZD_SEQUENC	:= _cSequen
				SZD->ZD_DEVTOT  := "O"
				SZD->ZD_OBSER	:= ""
				SZD->ZD_VEND	:= _cVendedor
				SZD->ZD_MOTORI      := _cNomMot
				SZD->ZD_TELEFON     := _cTelMot
				SZD->ZD_EMLMOT      := _cEmlMot
				SZD->ZD_RESP1       := _cResp1
				SZD->ZD_PEDPERN     := _cPedPern
				SZD->ZD_PERNOIT     := _cPern
				SZD->ZD_CODMOTP     := _cCodPer
				SZD->ZD_MTVPERN     := _cMTVPer
				SZD->ZD_XPLACAS		:= _cPlacas				
				IF Empty(SZD->ZD_CONTROL)
					SZD->ZD_CONTROL := _cCodCTRL
					SZD->ZD_NRDEVOL := _cFlag
				Endif
				MsUnLock()
			Endif
		next
		
		// *** INICIO CHAMADO 041905 || FISCAL || FERNANDA || EXCLUIR NOTAS 05/06/2018
		case nOpc = 'E'
		
			If MSGYESNO(" Confirme Excluir da Nota: " + SZD->ZD_NUMNF)
			
				// Excluir
				cNotaExcluir  := SZD->ZD_NUMNF
				cSerieExcluir := SZD->ZD_SERIE
				
				dbSelectArea("SZD")
				dbSetOrder(1)
				If (dbSeek(xfilial("SZD") + cNotaExcluir + cSerieExcluir,.T.))
				
					RecLock("SZD",.F.)
						dbDelete()
					MsUnLock()
					
					dbSelectArea("SZX")
					dbSetOrder(1)
					
					If dbSeek(xFilial("SZX")+cNotaExcluir+cSerieExcluir,.T.)
					
						WHILE SZX->(!EOF()).and. SZX->ZX_NF ==cNotaExcluir .AND. SZX->ZX_SERIE == cSerieExcluir
						
							RecLock("SZX",.F.)
								dbDelete()
							MsUnLock()
							SZX->(DBSKIP())
						ENDDO	
						
						//Everson - 21/03/2019|044314. Lançamento de desconto por devolução.
						MsAguarde({|| U_ADLOG047P(cNotaExcluir,cSerieExcluir) },"Aguarde","Lançando desconto de frete...")
						//
						
					Endif
					
				Endif
					
			Endif
			Return(NIL)
			
		// *** FINAL CHAMADO 041905 || FISCAL || FERNANDA || EXCLUIR NOTAS 05/06/2018
					
		otherwise
		If _cAlias = "SZD"       
			_aNfs       := 	u_traznfs(SC5->C5_FILIAL + SC5->C5_NUM)
			//			_cNota	   		:= SZD->ZD_NUMNF
			//			_cSerie	   		:= SZD->ZD_SERIE
		Endif

	endcase

	//Obtendo Ocorrencias                                
	
	DbSelectArea("SZD")
	DbSetOrder(1)
	_cNota	    := SZD->ZD_NUMNF
	_cSerie	    := SZD->ZD_SERIE
	_cCodRespons := SZD->ZD_RESPONS
	_cMotivo     := SZD->ZD_MOTIVO
	_cRespNome   := SZD->ZD_RESPNOM
	_cDescMotiv  := SZD->ZD_DESCMOT
	_cRoteiro    := SZD->ZD_ROTEIRO
	_cPlaca      := SZD->ZD_PLACA
	_cSequen     := SZD->ZD_SEQUENC
	_cObs1       := SZD->ZD_OBSER
	_cVendedor   := SZD->ZD_VEND
	_NumPed      := SZD->ZD_PEDIDO
	_cCodCli     := SZD->ZD_CODCLI
	_cLojCli     := SZD->ZD_LOJA
	_cNomeCli    := SZD->ZD_NOMECLI
	_cResp1      := SZD->ZD_RESP1
	_cPedPern    := SZD->ZD_PEDPERN
	_cPern       := SZD->ZD_PERNOIT
	_cMTVPer     := SZD->ZD_MTVPERN
	_cCodPer     := SZD->ZD_CODMOTP
	_cPlacas  	 := SZD->ZD_XPLACAS
	If !Empty(SZD->ZD_CONTROL)
		_cCodCTRL := SZD->ZD_CONTROL
		_cFlag    := SZD->ZD_NRDEVOL
	Endif   
	
	//Everson - 26/03/2019. Chamado 044314.
	cNFSF 	 := Alltrim(cValToChar(_cNota))
	cSerieSF := Alltrim(cValToChar(_cSerie))
	//

	Do Case
		Case nOpc='I'
		//		cOpcao :="INCLUIR"
		cOpcao :="INCLUIR"
		Case nOpc='A'
		//		cOpcao :="ALTERAR"
		cOpcao :="INCLUIR"
		Case nOpc='V'
		cOpcao :="VISUALIZAR"
		//      Excluir
		Case nOpc='E'
		cOpcao :="INCLUIR"
	EndCase

	Do Case
		Case cOpcao == "INCLUIR";    nOpcE := 3; nOpcG := 3
		Case cOpcao == "ALTERAR";    nOpcE := 3; nOpcG := 3
		Case cOpcao == "VISUALIZAR"; nOpcE := 2; nOpcG := 2
	EndCase

	//Cria variaveis M->????? da Enchoice                       
	
	If nOpc = 'V'
		RegToMemory("SZD",(cOpcao=="INCLUIR"))
		
	Else
		RegToMemory("SZD",(cOpcao=="VISUALIZAR"))
		
	Endif
	
	//Cria aHeader e aCols da GetDados                          
	
	nUsado:=0
	dbSelectArea("SX3")
	DBSETORDER(1) //adicionado essa linha para solucionar o chamado n 024470 - WILLIAM COSTA
	dbSeek("SZX")
	aHeader:={}
	While !Eof().And.(x3_arquivo=="SZX")
		IF ALLTRIM(X3_CAMPO)!="ZX_FILIAL"
			If X3USO(x3_usado).And.cNivel>=x3_nivel .And. Alltrim(cValToChar(x3_campo)) <> "ZX_IDSF"
				nUsado:=nUsado+1
				Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal,"AllwaysTrue()",;
				x3_usado, x3_tipo, x3_arquivo, x3_context } )
			Endif
		Endif
		dbSkip()
	End
	
	// Nas Devolucoes os registros devem ser carregados com os dados da nota original
	If cOpcao == "ALTERAR" .or.  cOpcao == "INCLUIR" .or. cOpcao == "VISUALIZAR"
		aCols := {}
		
		// operacoes que naosao visualziacao
		
		If nOpc <> 'V'
			
			// Eduardo Nakamatu/Biale (Manutencao) GERANDO ACOLS CASO EXISTA NF
			
			for _ni := 1 to len(_aNfs)
				_cNota		:= 	_aNfs[_ni,1]
				_cSerie		:= 	_aNfs[_ni,2]
				DbSelectArea("SD2")
				DbSetOrder(3)
				If dbSeek(xFilial("SD2") +_cNota+_cSerie )
					While  alltrim(_cNota) == alltrim(D2_DOC) .And. alltrim(_cSerie) == alltrim(D2_SERIE)
						_cCodProd	:= D2_COD
						_cQtde		:= D2_QUANT
						_nQuant     := D2_QTSEGUM
						_cUm		:= D2_UM
						_cSegum		:= D2_SEGUM
						_cQtdeSegum	:= D2_QTSEGUM
						_nPrecoVenda:= D2_PRCVEN
						_nNF        := D2_DOC
						_cITEMNF    := D2_ITEM
						DbSelectArea("SB1")
						DbSetOrder(1)
						If dbSeek(xFilial("SB1") +_cCodProd)
							_cDescProd := B1_DESC
						Endif
						DbCloseArea("SB1")
						//Procuro Observação e Motivo nos Itens
						DbSelectArea("SZX")
						DbSetOrder(2)
						If (dbSeek(xfilial("SZX")+_cNota+_cSerie +_cCodProd))
							If ZX_CODPROD = _cCodProd
								_nQuant  := ZX_QTDEV2U
								_cMot    := ZX_MOTIVO
								_cObs_It := ZX_OBSER
								_nTotDev := ZX_TOTAL
								//						_nQuebr := ZX_QUEBRA
								_nQuebra := ZX_QUEBRA
								If nOpc <> 'I'
									AADD(aCols,{_nQuant ,_cCodProd,_cDescProd,_cQtde,_cUm,_nNF,_cSerie,_cQtdeSegum,_cSegum,_nQtdDev, _nPrecoVenda ,_cMot,_cObs_It ,_nQuebra,_cITEMNF,.f.})
									//          1        2         3          4      5    6    7       8           9       10       11             12      13        14         15
								Endif
								DbSkip()
							Endif
						Endif
						DbSelectArea("SD2")
						If nOpc='I'
							//                 1        2         3          4      5    6    7       8           9       10       11             12    13        14      15
							AADD(aCols,{_nQuant ,_cCodProd,_cDescProd,_cQtde,_cUm,_nNF,_cSerie,_cQtdeSegum,_cSegum,_nQtdDev, _nPrecoVenda ,_cMot,_cObs_It ,_nQuebra,_cITEMNF,.f.})
						Endif
						_nCont:=_nCont+1
						DbSkip()
					End()
				Else

					
					// Eduardo Nakamatu/Biale (Manutencao) GERANDO ACOLS POR PEDIDO
					
					_nNf:=""
					_cSerie:=""
					dbSelectArea("SC6")
					dbSetOrder(1)
					dBSEEK(xFilial("SC6")+_cNumPedido,.T.)
					While  _cNumPedido == alltrim(C6_NUM)           
						if !Empty(C6_NOTA)

							_cCodProd	:= C6_PRODUTO
							_cQtde		:= C6_QTDENT //C6_QTDVEN
							_nQuant     := C6_QTDENT2 //C6_UNSVEN
							_cUm	  		:= C6_UM
							_cSegum		:= C6_SEGUM
							_cQtdeSegum	:= C6_QTDENT2 //C6_UNSVEN
							_nPrecoVenda:= C6_PRCVEN

							DbSelectArea("SB1")
							DbSetOrder(1)
							If dbSeek(xFilial("SB1") +_cCodProd)
								_cDescProd := B1_DESC
							Endif
							DbCloseArea("SB1")
							//Procuro Observação e Motivo nos Itens
							DbSelectArea("SZX")
							DbSetOrder(2)
							If (dbSeek(xfilial("SZX")+_cNota+_cSerie +_cCodProd))
								If ZX_CODPROD = _cCodProd
									_nQuant  := ZX_QTDEV2U
									_cMot    := ZX_MOTIVO
									_cObs_It := ZX_OBSER
									_nTotDev := ZX_TOTAL
									If nOpc <> 'I'
										AADD(aCols,{_nQuant ,_cCodProd,_cDescProd,_cQtde,_cUm,_nNf,_cSerie,_cQtdeSegum,_cSegum,_nQtdDev, _nPrecoVenda ,_cMot,_cObs_It,_nQuebra,_cITEMNF,.f.})
										//            1        2         3          4      5     6    7        8           9       10       11             12     13         14     15
									Endif
									DbSkip()
								Endif
							Endif
							DbSelectArea("SC6")
							If nOpc='I'
								AADD(aCols,{_nQuant ,_cCodProd,_cDescProd,_cQtde,_cUm,_nNf,_cSerie,_cQtdeSegum,_cSegum,_nQtdDev, _nPrecoVenda ,_cMot,_cObs_It ,_nQuebra,_cITEMNF,.f.})
							Endif
							//          1        2         3          4      5    6    7       8           9       10       11             12    13
							_nCont:=_nCont+1  
						Endif
						DbSkip()
					End()
				Endif
			next	
		Else
			
			// Eduardo Nakamatu/Biale (Manutencao) apenas visualizacao
			

			DbSelectArea("SZX")
			DbSetOrder(1)
			// ZD_FILIAL + ZD_NUMNF + ZD_SERIE
			If dbSeek(xfilial("SZX")+SZD->ZD_NUMNF+SZD->ZD_SERIE)
				While !eof().and. SZX->ZX_NF ==SZD->ZD_NUMNF .and. SZX->ZX_SERIE == SZD->ZD_SERIE
					_nQuant  		:= ZX_QTDEV2U
					_cMot    		:= ZX_MOTIVO
					_cObs_It 		:= ZX_OBSER
					_nTotDev 		:= ZX_TOTAL
					_cCodProd   	:= ZX_CODPROD
					_cDescProd  	:= ZX_DESCRIC
					_cQtde			:= ZX_QTDEV2U
					_cUm        	:= ZX_UNIDADE
					_nNF        	:= ZX_NF
					_cSerie     	:= ZX_SERIE
					_cSegum     	:= ZX_SEGUM
					_cQtdeSegum 	:= ZX_QTSEGUM
					_nQtdDev    	:= 0
					_nPrecoVenda 	:= 0
					_cMot       	:= ZX_MOTIVO
					_cObs_It 		:= ZX_OBSER
					_cITEMNF       := ZX_ITEMNF
					AADD(aCols,{_nQuant ,_cCodProd,_cDescProd,_cQtde,_cUm,_nNF,_cSerie,_cQtdeSegum,_cSegum,_nQtdDev, _nPrecoVenda ,_cMot,_cObs_It ,_nQuebra,_cITEMNF,.f.})
					// 			    1        2         3          4      5    6    7       8           9       10        11            12    13        14          15
					dbSkip()
				Enddo
			Endif
		Endif

		cOpcao := "INCLUIR"

	Endif
	
	_nPosDel  := Len(aHeader) + 1
	_nAcols   := Len(aCols)
	
	If Len(aCols)>0
		
		//Executa a Modelo 3
		
		cTitulo        := " Devolucao: " + SZD->ZD_CODCLI + " " + SZD->ZD_NOMECLI + " AD0019"// + "     " + " Tipo Ocorrencia: "	 + _cVarT + "     "
		cAliasEnchoice := "SZD"
		cAliasGetD     := "SZX"
		cLinOk         := "U_Linha_ok()"
		cTudOk         := "AllwaysTrue()"
		cFieldOk       := "AllwaysTrue()"
		aCpoEnchoice   := {}

		aCpoEnchoice   := {"ZD_NUMNF","ZD_SERIE","ZD_CODCLI","ZD_LOJA","ZD_NOMECLI","ZD_DEVTOT","ZD_DTDEV","ZD_AUTNOME","ZD_RESPONS", +;
		"ZD_RESPNOM","ZD_MOTIVO","ZD_DESCMOT","ZD_PEDIDO","ZD_PLACA","ZD_XPLACAS","ZD_ROTEIRO","ZD_SEQUENC","ZD_OBSER", +;
		"ZD_VEND","ZD_PEDPERN"}

		_lRet := Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk,,,,,,,400)  //Mauricio 17/04/13 - aumentado tamanho cabecalho.

		//Executar processamento 
		
		If _lRet

			// OPERACAO EXCLUSAO - Eduardo Nakamatu/Biale (Manutencao)
			
			If nOpc = 'E'
				If MSGYESNO(" Confirme Excluir... ")
					// Excluir
					If (dbSeek(xfilial("SZD") + _cNota + _cSerie))
						RecLock("SZD",.F.)
						dbDelete()
						MsUnLock()
						dbSelectArea("SZX")
						dbSetOrder(1)
						//If dbSeek(xFilial("SZX")+alltrim(_cNota)+alltrim(_cSerie )) ALTERADO LEONARDO (HC) PARA PEGAR NOTAS COM 6 OU 9 CARACTERES
						If dbSeek(xFilial("SZX")+_cNota+alltrim(_cSerie ))
							RecLock("SZX",.F.)
							dbDelete()
							MsUnLock()
						Endif
						
						//Everson - 21/03/2019. Chamado 044314.
						cNFSF 	:= _cNota
						cSerieSF:= _cSerie
						//
					
					Endif
				Endif
			Else
				Begin Transaction
					
					//Gravacao do Cabecalho - SZ1                                         
					
					// NOME DO RESPONSAVEL E DESCRICAO DO MOTIVO
					//Buscar Nome do Responsavel
					dbSelectArea("SZU")
					dbSetOrder(1)
					If dbSeek(xfilial()+alltrim(M->ZD_RESPONS))
						_cRespNome := SZU->ZU_DESCRI
					Endif

					//Buscar Motivo
					dbSelectArea("SZS")
					dbSetOrder(1)
					If dbSeek(xfilial()+alltrim(M->ZD_MOTIVO))
						_cDescMotiv := SZS->ZS_DESCRI
					Endif

					//Controla se tem registro Deletado
					_cDelet := .f.
					dbSelectArea("SZD")
					dbSetOrder(1)
					If ( dbSeek(xfilial("SZD") + _cNota + _cSerie) )
						RecLock("SZD",.F.)
						SZD->ZD_RESPONS	:= M->ZD_RESPONS
						SZD->ZD_MOTIVO	:= M->ZD_MOTIVO
						SZD->ZD_AUTNOME	:= M->ZD_AUTNOME
						SZD->ZD_RESPNOM	:= _cRespNome
						SZD->ZD_DESCMOT := _cDescMotiv
						SZD->ZD_OBSER	:= M->ZD_OBSER + _cPL + _cNomeHora //""
						SZD->ZD_RESP1       := M->ZD_RESP1
						SZD->ZD_PEDPERN     := M->ZD_PEDPERN
						SZD->ZD_PERNOIT     := M->ZD_PERNOIT
						SZD->ZD_MTVPERN     := M->ZD_MTVPERN
						SZD->ZD_CODMOTP     := M->ZD_CODMOTP

						_cObs             := _cNomeHora + _cPL + M->ZD_MOTIVO + " " + SZS->ZS_DESCRI + _cPL + M->ZD_OBSER
						//SZD->ZD_OBSHST		:= M->ZD_OBSHST + _cPL + _cObs
						SZD->ZD_DEVTOT 	:= M->ZD_DEVTOT
						IF Empty(SZD->ZD_CONTROL)
							SZD->ZD_CONTROL := _cCodCTRL
							SZD->ZD_NRDEVOL := _cFlag
						Endif				
						MsUnLock()
					Endif

					Do Case
						Case ALLTRIM(M->ZD_DEVTOT) == 'E'   // Entrega
						_cMot_Ok :=	"02"
						//				Case ALLTRIM(M->ZD_DEVTOT) $ 'O/Q'   // Ocorrencias ou quebra
						Case ALLTRIM(M->ZD_DEVTOT) == 'O'   // Ocorrencias ou quebra
						_cMot_Ok :=	"04"
						Case ALLTRIM(M->ZD_DEVTOT) == 'Q'   // Ocorrencias ou quebra
						_cMot_Ok :=	"06"
						Case ALLTRIM(M->ZD_DEVTOT) == 'T'   // Devolucao Total
						_cMot_Ok :=	"03"
						Case ALLTRIM(M->ZD_DEVTOT) == 'P'   // Devolucao Parcial
						_cMot_Ok :=	"03"
						Case ALLTRIM(M->ZD_DEVTOT) == 'R'   // Reprogramacao
						_cMot_Ok :=	"05"
					EndCase

					dbSelectArea("SC5")
					RecLock("SC5",.F.)
					Replace SC5->C5_MOK	With _cMot_Ok
					MSUNLOCK()

					If M->ZD_DEVTOT = 'O' .OR.  M->ZD_DEVTOT = 'R' .OR.  M->ZD_DEVTOT = 'E'
						// Caso ja foi lançada Devolução e passa para outra ocorrencia tenho que excluir
						// o Detalhe da devolução
						dbSelectArea("SZX")
						dbSetOrder(1)
						//If dbSeek(xFilial("SZX")+alltrim(_cNota)+alltrim(_cSerie ))
						If dbSeek(xFilial("SZX")+_cNota+alltrim(_cSerie ))
							//While  alltrim(_cNota) == alltrim(ZX_NF) .And. alltrim(_cSerie) == alltrim(ZX_SERIE)
							While  _cNota == ZX_NF .And. alltrim(_cSerie) == alltrim(ZX_SERIE)
								RecLock("SZX",.F.)
								dbDelete()
								MsUnLock()
								DbSkip()
							Enddo
						Endif
					Endif
					
					//Gravacao dos itens - SZX Se for Devolução (ZD_DEVTOT) Total ou Parcial     
					//Parametro                                                                  
					//03.03.08 - acrescentado  gravacao de ocorencias ZD_DEVTOT = '0'            
					
					If M->ZD_DEVTOT == 'T' .OR.  M->ZD_DEVTOT == 'P' .or. M->ZD_DEVTOT == 'Q'

						For nIt := 1 To Len(aCols)
							If !aCols[nIt,Len(aCols[nIt])]     ///Len(aCols[nX])    // If !aCols[nIt,_nPosDel]  original
								dbSelectArea("SZX")
								dbSetOrder(2)
								If !dbSeek(xFilial("SZX") + _cNota + _cSerie + aCols[nIt,2])
									If aCols[nIt][1] > 0 .OR. aCols[nIt,14] > 0 //(M->ZD_DEVTOT = "Q" .AND. aCols[nIt,14] > 0)
										RecLock("SZX",.T.)
										//****
										_cPrcVen   := aCols[nIt][11]
										_nQtd1Unid := (aCols[nIt][4]/aCols[nIt][8]) * aCols[nIt][1]
										_cTotal    :=_cPrcVen*_nQtd1Unid
										//****
										SZX->ZX_FILIAL	:= xFilial("SZX")
										SZX->ZX_NF		:= _cNota  //NF
										SZX->ZX_SERIE	:= _cSerie  // Serie
										SZX->ZX_UNIDADE	:= aCols[nIt,5]  // Primeira unidade de medida
										SZX->ZX_QTSEGUM	:= aCols[nIt,8]  // Quantidade Devolvida Segunda Unidade
										SZX->ZX_SEGUM	:= aCols[nIt,9]  // Segunda Unidade de medida
										SZX->ZX_QTDE	:= _nQtd1Unid    // Quantidade Devolvida
										SZX->ZX_QTDEV2U	:= aCols[nIt,1]  // Quantidade Devolvida
										SZX->ZX_QTDEV1U	:= aCols[nIt,4]  // Quantidade Devolvida
										SZX->ZX_CODPROD	:= aCols[nIt,2]  // Codigo do Produto
										SZX->ZX_DESCRIC	:= aCols[nIt,3]  // Descricao do Produto
										SZX->ZX_MOTIVO	:= aCols[nIt,12]  // Motivo da Ocorrencia
										SZX->ZX_OBSER	:= aCols[nIt,13]  // Observacao
										SZX->ZX_TOTAL	:= _cTotal        // Valor total da devolução
										SZX->ZX_QUEBRA  := aCols[nIt,14]  // QUEBRA
										SZX->ZX_ITEMNF  := acols[nIt,15]  // ITEM NF
										MsUnLock()
									Endif
								Else
									RecLock("SZX",.F.)
									If aCols[nIt][1] > 0 .OR. aCols[nIt,14] > 0 //.OR. (M->ZD_DEVTOT = "Q" .AND. aCols[nIt,14] > 0)
										
										_cPrcVen   := aCols[nIt][11]
										_nQtd1Unid := (aCols[nIt][4]/aCols[nIt][8]) * aCols[nIt][1]
										_cTotal    :=_cPrcVen*_nQtd1Unid
										
										SZX->ZX_UNIDADE  := aCols[nIt,5]  // Primeira unidade de medida
										SZX->ZX_QTSEGUM  := aCols[nIt,8]  // Quantidade Devolvida Segunda Unidade
										SZX->ZX_SEGUM    := aCols[nIt,9]  // Segunda Unidade de medida
										SZX->ZX_QTDE     := _nQtd1Unid    // Quantidade Vendida Seg Unidade
										SZX->ZX_QTDEV2U	 := aCols[nIt,1]  // Quantidade Devolvida
										SZX->ZX_QTDEV1U	 := aCols[nIt,4]  // Quantidade Devolvida
										SZX->ZX_CODPROD	 := aCols[nIt,2]  // Codigo do Produto
										SZX->ZX_DESCRIC	 := aCols[nIt,3]  // Descricao do Produto
										SZX->ZX_MOTIVO   := aCols[nIt,12]  // Motivo da Ocorrencia
										SZX->ZX_OBSER  	 := aCols[nIt,13]  // Observacao
										SZX->ZX_TOTAL    := _cTotal        // Valor total da devolução
										SZX->ZX_QUEBRA   := aCols[nIt,14]  // QUEBRA
										SZX->ZX_ITEMNF    := acols[nIt,15]  // ITEM NF

									Endif
									MsUnLock()

								Endif
							Else
								_iTem_Del := alltrim(aCols[nIt,2])
								dbSelectArea("SZX")
								dbSetOrder(2)
								//ZX_FILIAL+ZX_NF+ZX_SERIE+ZX_CODPROD
								//						If dbSeek(xFilial("SZX") + _cNota + _cSerie + aCols[nIt,2])
								If dbSeek(xFilial("SZX") + _cNota + _cSerie + _iTem_Del)
									//							RecLock("SZX",.F.)
									//							dbDelete()
									//							MsUnLock()


									_cQueryD := "DELETE FROM " + RETSQLNAME("SZX") + " WHERE ZX_CODPROD = '" + _iTem_Del + "' AND " + "ZX_NF = '" + ALLTRIM(_cNota) + "' AND ZX_SERIE = '" + ALLTRIM(_cSerie) + "'"
									TCSQLExec(_cQueryD)

								Endif
							Endif
						Next nIt

						//Everson - 27/04/2018. Chamado 037261. Envio de Caso (ocorrência de devolução total ou parcial) ao SalesForce.
						If (M->ZD_DEVTOT == 'T' .OR.  M->ZD_DEVTOT == 'P') .And. Alltrim(cValToChar(SC5->C5_XPEDSAL)) <> ''
							lSalesForce := .T.
							cNFSF		:= Alltrim(cValToChar(M->ZD_NUMNF))
							cSerieSF	:= Alltrim(cValToChar(M->ZD_SERIE))

						EndIf
						
						//Everson - 21/03/2019. Chamado 044314.
						cNFSF		:= Alltrim(cValToChar(M->ZD_NUMNF))
						cSerieSF	:= Alltrim(cValToChar(M->ZD_SERIE))

					Endif
					//grava arquivo de log das alterações
					DbSelectArea("ZZD")
					DbSetOrder(1)
					Reclock("ZZD",.T.)
					ZZD->ZZD_Filial := xFilial("ZZD")
					ZZD->ZZD_NUMNF  := M->ZD_NUMNF
					ZZD->ZZD_SERIE  := M->ZD_SERIE
					ZZD->ZZD_PEDIDO := M->ZD_PEDIDO
					ZZD->ZZD_CODUSU := __cUserID
					ZZD->ZZD_NOME   := alltrim(cUsername)
					ZZD->ZZD_DATA   := Date()
					ZZD->ZZD_HORA   := Time()
					ZZD->(MsUnlock())
					//Mauricio 08/05/13 - parei aqui...preciso tratar aqui aprovação. Quando RESP1 ou RESP2 for transportador tenho que apurar valor de 3% sobre NF do pedido
					//de venda no caso de devolução total sem quebra. Quando quebra e responsavel for transportador o valor é 100% o da quebra.
					//Gravar os dois casos acima para aprovação....
					//QUando houver quebra(qualquer responsavel) precisa gravar dado para aprovação e quando aprovado gerar NCC para cliente....
					//caso houver reprovação apenas guardar essa informação provavelmente nesta tabela mesmo......

					//aprovação - checar se ha quebra e havendo apurar valor.
					_nValTDV := 0   //valor total da devolução...
					_nQTTot  := 0   //quantidade total pedido
					_nQBTot  := 0   //quantidade total quebra
					_lQuebra := .F. //valida se ha quebra ou não...
					For nIt := 1 To Len(aCols)
						If !aCols[nIt,Len(aCols[nIt])]   //If !aCols[nIt,_nPosDel]
							_cPrcVen   := aCols[nIt][11]

							// @history ticket  9579   - Fernando Macieir- 17/02/2021 - type mismatch on *  on U_AD0019(AD0019.PRW) 29/01/2021 11:47:55 line : 821

							nAcols4 := Iif( ValType(aCols[nIt][4]) <> "N", Val(aCols[nIt][4]), aCols[nIt][4] )
							nAcols8 := Iif( ValType(aCols[nIt][8]) <> "N", Val(aCols[nIt][8]), aCols[nIt][8] )
							nAcols1 := Iif( ValType(aCols[nIt][1]) <> "N", Val(aCols[nIt][1]), aCols[nIt][1] )

							_nQtd1Unid := (nAcols4/nAcols8) * nAcols1
							//_nQtd1Unid := (aCols[nIt][4]/aCols[nIt][8]) * aCols[nIt][1]

							//

							_cTotal    :=_cPrcVen*_nQtd1Unid
							IF aCols[nIt,14] > 0     //houve quebra!!!
								_nValTDV += _cPrcVen * aCols[nIt,14]   // !!!!!! Mauricio - preciso verificar aqui unidade de medida se esta correta !!!!!!!!
								_nQTTot  += aCols[nIt][4]
								_nQBTot  += aCols[nIt,14]
							Endif
						Endif
					next nIt

					If _nValTDV == 0 .And. M->ZD_DEVTOT == 'T' .And. (M->ZD_RESPONS == '08')  //Devolução Total sem quebra, responsavel transportadora = 3% NF
						//3% NF somente para transportador
						//Busco valor total da NF para aplicar 3%
						DbSelectArea("SF2")
						DbSetOrder(1)
						If dbSeek(xFilial("SF2")+M->ZD_NUMNF+M->ZD_SERIE+M->ZD_CODCLI+M->ZD_LOJA)
							_nValDesc := (SF2->F2_VALBRUT * 0.03)
							_nValNF   := SF2->F2_VALBRUT
						Else
							_nValDesc := 0
						Endif

						//gravo na tabela para aprovação
						//12/06/13 - em virtude de mais um processo de aprovacao e controle( do vendedor) foi quebrado controle de aprovação para
						//transportador, cliente, vendedor em um registro para cada processo. E criado indice para os campos APVTPT,APVNCC e APVVDD.
						//tambem implementado consistencia para não gerar registro de um processo ja gerado anteriormente(Alteração nas ocorrencias).
						//se ja existir registro na ZZE não grava um novo.
						IF _nValDesc > 0
							DbSelectArea("ZZE")
							DbSetOrder(3)
							dbgotop()
							If !(dbseek(xFilial("ZZE")+M->ZD_NUMNF+M->ZD_SERIE+"S"))  //transportador ordem 3
								RecLock("ZZE",.T.)
								ZZE->ZZE_Filial := xFilial("ZZE")
								ZZE->ZZE_PEDIDO := M->ZD_PEDIDO
								ZZE->ZZE_CODCLI := M->ZD_CODCLI
								ZZE->ZZE_LOJA   := M->ZD_LOJA
								ZZE->ZZE_NUMNF  := M->ZD_NUMNF
								ZZE->ZZE_SERIE  := M->ZD_SERIE
								ZZE->ZZE_NOME   := M->ZD_NOMECLI
								ZZE->ZZE_QUANT  := _nQTTot
								ZZE->ZZE_VLRNF  := _nValNF
								ZZE->ZZE_DTDEV  := M->ZD_DTDEV
								ZZE->ZZE_MOTIVO := M->ZD_DESCMOT
								//ZZE->ZZE_OCORR  :=
								ZZE->ZZE_OBS    := M->ZD_OBSER
								ZZE->ZZE_APVTPT := "S"   //flag para aprovação de desconto para transportador
								ZZE->ZZE_APVNCC := "N"   //flag para aprovação de NCC para o cliente
								ZZE->ZZE_APVVDD := "N"
								ZZE->ZZE_QTQBRA := _nQBTot
								ZZE->ZZE_VLDESC := _nValDesc
								ZZE->ZZE_DTDISP := Date()
								ZZE->ZZE_HRDISP := time()
								//ZZE->ZZE_DTAPRV
								//ZZE->ZZE_HRAPRV
								//ZZE->ZZE_UAPROV
								//ZZE->ZZE_JUSTAP
								//ZZE->ZZE_AP_REP
								ZZE->(MSunlock())
							Else
								MsgInfo("Ja existe processo de aprovação para esta NF/Serie/desconto transportador","ATenção")
							Endif
						Endif
					Elseif _nValTDV == 0 .And. M->ZD_DEVTOT == 'T' .And. (M->ZD_RESPONS == '06') //Sem quebra e com responsabilidade comercial(desconto vendedor somente R$40)
						_cRepresent := M->ZD_VEND
						_cSuperv    := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_CODSUP")        // supervisor para aprovação
						_cSupervi   := Posicione("SA3",1,xFilial("SA3")+_cSuperv,"A3_CODUSR")          //codigo de usuario do supervisor
						DbSelectArea("SF2")
						DbSetOrder(1)
						If dbSeek(xFilial("SF2")+M->ZD_NUMNF+M->ZD_SERIE+M->ZD_CODCLI+M->ZD_LOJA)				
							_nValNF := SF2->F2_VALBRUT
						Else
							_nValNF := 0
						Endif
						DbSelectArea("ZZE")
						DbSetOrder(5)
						dbgotop()
						If !(dbseek(xFilial("ZZE")+M->ZD_NUMNF+M->ZD_SERIE+"S"))  //vendedor ordem 5
							RecLock("ZZE",.T.)
							ZZE->ZZE_Filial := xFilial("ZZE")
							ZZE->ZZE_PEDIDO := M->ZD_PEDIDO
							ZZE->ZZE_CODCLI := M->ZD_CODCLI
							ZZE->ZZE_LOJA   := M->ZD_LOJA
							ZZE->ZZE_NUMNF  := M->ZD_NUMNF
							ZZE->ZZE_SERIE  := M->ZD_SERIE
							ZZE->ZZE_NOME   := M->ZD_NOMECLI
							ZZE->ZZE_QUANT  := _nQTTot
							ZZE->ZZE_VLRNF  := _nValNF
							ZZE->ZZE_DTDEV  := M->ZD_DTDEV
							ZZE->ZZE_MOTIVO := M->ZD_DESCMOT
							//ZZE->ZZE_OCORR  :=
							ZZE->ZZE_OBS    := M->ZD_OBSER
							ZZE->ZZE_APVTPT := "N"   //flag para aprovação de desconto para transportador
							ZZE->ZZE_APVNCC := "N"   //flag para aprovação de NCC para o cliente
							ZZE->ZZE_APVVDD := "S"   //Flag para desconto do vendedor...
							ZZE->ZZE_QTQBRA := _nQBTot
							ZZE->ZZE_VLDESC := 40
							ZZE->ZZE_DTDISP := Date()
							ZZE->ZZE_HRDISP := time()
							ZZE->ZZE_VEND   := M->ZD_VEND
							ZZE->ZZE_USSUPE := _cSupervi
							//ZZE->ZZE_DTAPRV
							//ZZE->ZZE_HRAPRV
							//ZZE->ZZE_UAPROV
							//ZZE->ZZE_JUSTAP
							//ZZE->ZZE_AP_REP
							ZZE->(MSunlock())
						Else
							MsgInfo("Ja existe processo de aprovação para esta NF/Serie/desconto vendedor","ATenção")
						Endif
					Elseif _nValTDV > 0 .And. (M->ZD_RESPONS == '08')  //Quebra com responsabilidade do transportador = 100 % quebra.
						//100 % da quebra para transportador e NCC 100% da quebra para cliente
						//Busco valor total da NF para aplicar 3%
						DbSelectArea("SF2")
						DbSetOrder(1)
						If dbSeek(xFilial("SF2")+M->ZD_NUMNF+M->ZD_SERIE+M->ZD_CODCLI+M->ZD_LOJA)
							_nValNF   := SF2->F2_VALBRUT
						Else
							_nValNF := 0
						Endif

						//gravo na tabela para aprovação
						DbSelectArea("ZZE")
						DbSetOrder(3)
						dbgotop()
						If !(dbseek(xFilial("ZZE")+M->ZD_NUMNF+M->ZD_SERIE+"S"))  //transportador ordem 3
							RecLock("ZZE",.T.)
							ZZE->ZZE_Filial := xFilial("ZZE")
							ZZE->ZZE_PEDIDO := M->ZD_PEDIDO
							ZZE->ZZE_CODCLI := M->ZD_CODCLI
							ZZE->ZZE_LOJA   := M->ZD_LOJA
							ZZE->ZZE_NUMNF  := M->ZD_NUMNF
							ZZE->ZZE_SERIE  := M->ZD_SERIE
							ZZE->ZZE_NOME   := M->ZD_NOMECLI
							ZZE->ZZE_QUANT  := _nQTTot
							ZZE->ZZE_VLRNF  := _nValNF
							ZZE->ZZE_DTDEV  := M->ZD_DTDEV
							ZZE->ZZE_MOTIVO := M->ZD_DESCMOT
							//ZZE->ZZE_OCORR  :=
							ZZE->ZZE_OBS    := M->ZD_OBSER
							ZZE->ZZE_APVTPT := "S"   //flag para aprovação de desconto para transportador
							ZZE->ZZE_APVNCC := "N"   //flag para aprovação de NCC para o cliente
							ZZE->ZZE_APVVDD := "N"   //flag para aprovacao desconto ao vendedor
							ZZE->ZZE_QTQBRA := _nQBTot
							ZZE->ZZE_VLDESC := _nValTDV
							ZZE->ZZE_DTDISP := Date()
							ZZE->ZZE_HRDISP := time()
							//ZZE->ZZE_DTAPRV
							//ZZE->ZZE_HRAPRV
							//ZZE->ZZE_UAPROV
							//ZZE->ZZE_JUSTAP
							//ZZE->ZZE_AP_REP
							ZZE->(MSunlock())
						Else
							MsgInfo("Ja existe processo de aprovação para esta NF/Serie/desconto transportador","ATenção")
						Endif
						DbSelectArea("ZZE")
						DbSetOrder(4)
						dbgotop()
						If !(dbseek(xFilial("ZZE")+M->ZD_NUMNF+M->ZD_SERIE+"S"))  //cliente ordem 4
							RecLock("ZZE",.T.)
							ZZE->ZZE_Filial := xFilial("ZZE")
							ZZE->ZZE_PEDIDO := M->ZD_PEDIDO
							ZZE->ZZE_CODCLI := M->ZD_CODCLI
							ZZE->ZZE_LOJA   := M->ZD_LOJA
							ZZE->ZZE_NUMNF  := M->ZD_NUMNF
							ZZE->ZZE_SERIE  := M->ZD_SERIE
							ZZE->ZZE_NOME   := M->ZD_NOMECLI
							ZZE->ZZE_QUANT  := _nQTTot
							ZZE->ZZE_VLRNF  := _nValNF
							ZZE->ZZE_DTDEV  := M->ZD_DTDEV
							ZZE->ZZE_MOTIVO := M->ZD_DESCMOT
							//ZZE->ZZE_OCORR  :=
							ZZE->ZZE_OBS    := M->ZD_OBSER
							ZZE->ZZE_APVTPT := "N"   //flag para aprovação de desconto para transportador
							ZZE->ZZE_APVNCC := "S"   //flag para aprovação de NCC para o cliente
							ZZE->ZZE_APVVDD := "N"   //flag para aprovacao desconto ao vendedor
							ZZE->ZZE_QTQBRA := _nQBTot
							ZZE->ZZE_VLDESC := _nValTDV
							ZZE->ZZE_DTDISP := Date()
							ZZE->ZZE_HRDISP := time()
							//ZZE->ZZE_DTAPRV
							//ZZE->ZZE_HRAPRV
							//ZZE->ZZE_UAPROV
							//ZZE->ZZE_JUSTAP
							//ZZE->ZZE_AP_REP
							ZZE->(MSunlock())
						Else

							IF ALLTRIM(M->ZD_DEVTOT) == 'Q'

								DBSELECTAREA("ZZE")
								DBSETORDER(4)
								DBGOTOP()
								IF (dbseek(xFilial("ZZE")+M->ZD_NUMNF+M->ZD_SERIE+"S"))  //Cliente ordem 4

									IF EMPTY(ZZE->ZZE_DTAPRC)

										RecLock("ZZE",.F.)
											ZZE->ZZE_QUANT  := _nQTTot
											ZZE->ZZE_VLRNF  := _nValNF
											ZZE->ZZE_DTDEV  := M->ZD_DTDEV
											ZZE->ZZE_MOTIVO := M->ZD_DESCMOT
											ZZE->ZZE_OBS    := M->ZD_OBSER
											ZZE->ZZE_QTQBRA := _nQBTot
											ZZE->ZZE_VLDESC := _nValTDV
											ZZE->ZZE_DTDISP := Date()
											ZZE->ZZE_HRDISP := time()
										ZZE->(MSunlock())
									ENDIF	

								ENDIF

								MSGINFO("Valores do processo de aprovação Cliente foram alterados: " + CHR(13) + CHR(10) +;
										"NF: "                + M->ZD_NUMNF                          + CHR(13) + CHR(10) +;
										"Serie: "             + M->ZD_SERIE                          + CHR(13) + CHR(10) +;
										"Valor do desconto: " + CVALTOCHAR(_nValTDV)                 + CHR(13) + CHR(10) +;
										"Cliente: "           + M->ZD_CODCLI                         + CHR(13) + CHR(10) +;
										" Loja: "             + M->ZD_LOJA, "Atenção")

							ELSE

								MSGINFO("Ja existe processo de aprovação para esta NF/Serie/desconto cliente","Atenção")

							ENDIF			
							
						Endif
					Elseif _nValTDV > 0 .And. !(M->ZD_RESPONS == '08') //Quebra sem responsabilidade do transportador
						If M->ZD_RESPONS == '06' //Responsabilidade comercial  desconto para vendedor
							//NCC 100 % da quebra para cliente.
							DbSelectArea("SF2")
							DbSetOrder(1)
							If dbSeek(xFilial("SF2")+M->ZD_NUMNF+M->ZD_SERIE+M->ZD_CODCLI+M->ZD_LOJA)
								_nValNF   := SF2->F2_VALBRUT
							Else
								_nValNF := 0
							Endif
							_cRepresent := M->ZD_VEND
							_cSuperv    := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_CODSUP")        // supervisor para aprovação
							_cSupervi   := Posicione("SA3",1,xFilial("SA3")+_cSuperv,"A3_CODUSR")          //codigo de usuario do supervisor
							//gravo na tabela para aprovação
							DbSelectArea("ZZE")
							DbSetOrder(5)
							dbgotop()
							If !(dbseek(xFilial("ZZE")+M->ZD_NUMNF+M->ZD_SERIE+"S"))  //vendedor ordem 5
								RecLock("ZZE",.T.)
								ZZE->ZZE_Filial := xFilial("ZZE")
								ZZE->ZZE_PEDIDO := M->ZD_PEDIDO
								ZZE->ZZE_CODCLI := M->ZD_CODCLI
								ZZE->ZZE_LOJA   := M->ZD_LOJA
								ZZE->ZZE_NUMNF  := M->ZD_NUMNF
								ZZE->ZZE_SERIE  := M->ZD_SERIE
								ZZE->ZZE_NOME   := M->ZD_NOMECLI
								ZZE->ZZE_QUANT  := _nQTTot
								ZZE->ZZE_VLRNF  := _nValNF
								ZZE->ZZE_DTDEV  := M->ZD_DTDEV
								ZZE->ZZE_MOTIVO := M->ZD_DESCMOT
								//ZZE->ZZE_OCORR  :=
								ZZE->ZZE_OBS    := M->ZD_OBSER
								ZZE->ZZE_APVTPT := "N"   //flag para aprovação de desconto para transportador
								ZZE->ZZE_APVNCC := "N"   //flag para aprovação de NCC para o cliente
								ZZE->ZZE_APVVDD := "S"   //flag para aprovacao desconto ao vendedor
								ZZE->ZZE_QTQBRA := _nQBTot
								ZZE->ZZE_VLDESC := _nValTDV
								ZZE->ZZE_DTDISP := Date()
								ZZE->ZZE_HRDISP := time()
								ZZE->ZZE_VEND   := M->ZD_VEND
								ZZE->ZZE_USSUPE := _cSupervi
								//ZZE->ZZE_DTAPRV
								//ZZE->ZZE_HRAPRV
								//ZZE->ZZE_UAPROV
								//ZZE->ZZE_JUSTAP
								//ZZE->ZZE_AP_REP
								ZZE->(MSunlock())
							Else
								MsgInfo("Ja existe processo de aprovação para esta NF/Serie/desconto vendedor","ATenção")
							Endif
							DbSelectArea("ZZE")
							DbSetOrder(4)
							dbgotop()
							If !(dbseek(xFilial("ZZE")+M->ZD_NUMNF+M->ZD_SERIE+"S"))  //cliente ordem 4
								RecLock("ZZE",.T.)
								ZZE->ZZE_Filial := xFilial("ZZE")
								ZZE->ZZE_PEDIDO := M->ZD_PEDIDO
								ZZE->ZZE_CODCLI := M->ZD_CODCLI
								ZZE->ZZE_LOJA   := M->ZD_LOJA
								ZZE->ZZE_NUMNF  := M->ZD_NUMNF
								ZZE->ZZE_SERIE  := M->ZD_SERIE
								ZZE->ZZE_NOME   := M->ZD_NOMECLI
								ZZE->ZZE_QUANT  := _nQTTot
								ZZE->ZZE_VLRNF  := _nValNF
								ZZE->ZZE_DTDEV  := M->ZD_DTDEV
								ZZE->ZZE_MOTIVO := M->ZD_DESCMOT
								//ZZE->ZZE_OCORR  :=
								ZZE->ZZE_OBS    := M->ZD_OBSER
								ZZE->ZZE_APVTPT := "N"   //flag para aprovação de desconto para transportador
								ZZE->ZZE_APVNCC := "S"   //flag para aprovação de NCC para o cliente
								ZZE->ZZE_APVVDD := "N"   //flag para aprovacao desconto ao vendedor
								ZZE->ZZE_QTQBRA := _nQBTot
								ZZE->ZZE_VLDESC := _nValTDV
								ZZE->ZZE_DTDISP := Date()
								ZZE->ZZE_HRDISP := time()
								ZZE->ZZE_VEND   := M->ZD_VEND
								ZZE->ZZE_USSUPE := _cSupervi
								//ZZE->ZZE_DTAPRV
								//ZZE->ZZE_HRAPRV
								//ZZE->ZZE_UAPROV
								//ZZE->ZZE_JUSTAP
								//ZZE->ZZE_AP_REP
								ZZE->(MSunlock())
							Else

								IF ALLTRIM(M->ZD_DEVTOT) == 'Q'

									DBSELECTAREA("ZZE")
									DBSETORDER(4)
									DBGOTOP()
									IF (dbseek(xFilial("ZZE")+M->ZD_NUMNF+M->ZD_SERIE+"S"))  //Cliente ordem 4

										IF EMPTY(ZZE->ZZE_DTAPRC)

											RecLock("ZZE",.F.)
												ZZE->ZZE_QUANT  := _nQTTot
												ZZE->ZZE_VLRNF  := _nValNF
												ZZE->ZZE_DTDEV  := M->ZD_DTDEV
												ZZE->ZZE_MOTIVO := M->ZD_DESCMOT
												ZZE->ZZE_OBS    := M->ZD_OBSER
												ZZE->ZZE_QTQBRA := _nQBTot
												ZZE->ZZE_VLDESC := _nValTDV
												ZZE->ZZE_DTDISP := Date()
												ZZE->ZZE_HRDISP := time()
											ZZE->(MSunlock())
										ENDIF	

									ENDIF

									MSGINFO("Valores do processo de aprovação Cliente foram alterados: " + CHR(13) + CHR(10) +;
											"NF: "                + M->ZD_NUMNF                          + CHR(13) + CHR(10) +;
											"Serie: "             + M->ZD_SERIE                          + CHR(13) + CHR(10) +;
											"Valor do desconto: " + CVALTOCHAR(_nValTDV)                 + CHR(13) + CHR(10) +;
											"Cliente: "           + M->ZD_CODCLI                         + CHR(13) + CHR(10) +;
											" Loja: "             + M->ZD_LOJA, "Atenção")

								ELSE

									MSGINFO("Ja existe processo de aprovação para esta NF/Serie/desconto cliente","Atenção")

								ENDIF			


							Endif
						Else
							//NCC 100 % da quebra para cliente.
							DbSelectArea("SF2")
							DbSetOrder(1)
							If dbSeek(xFilial("SF2")+M->ZD_NUMNF+M->ZD_SERIE+M->ZD_CODCLI+M->ZD_LOJA)
								_nValNF   := SF2->F2_VALBRUT
							Else
								_nValNF := 0
							Endif

							//gravo na tabela para aprovação
							DbSelectArea("ZZE")
							DbSetOrder(4)
							dbgotop()
							If !(dbseek(xFilial("ZZE")+M->ZD_NUMNF+M->ZD_SERIE+"S"))  //Cliente ordem 4
								RecLock("ZZE",.T.)
								ZZE->ZZE_Filial := xFilial("ZZE")
								ZZE->ZZE_PEDIDO := M->ZD_PEDIDO
								ZZE->ZZE_CODCLI := M->ZD_CODCLI
								ZZE->ZZE_LOJA   := M->ZD_LOJA
								ZZE->ZZE_NUMNF  := M->ZD_NUMNF
								ZZE->ZZE_SERIE  := M->ZD_SERIE
								ZZE->ZZE_NOME   := M->ZD_NOMECLI
								ZZE->ZZE_QUANT  := _nQTTot
								ZZE->ZZE_VLRNF  := _nValNF
								ZZE->ZZE_DTDEV  := M->ZD_DTDEV
								ZZE->ZZE_MOTIVO := M->ZD_DESCMOT
								//ZZE->ZZE_OCORR  :=
								ZZE->ZZE_OBS    := M->ZD_OBSER
								ZZE->ZZE_APVTPT := "N"   //flag para aprovação de desconto para transportador
								ZZE->ZZE_APVNCC := "S"   //flag para aprovação de NCC para o cliente
								ZZE->ZZE_APVVDD := "N"   //flag para aprovacao desconto ao vendedor
								ZZE->ZZE_QTQBRA := _nQBTot
								ZZE->ZZE_VLDESC := _nValTDV
								ZZE->ZZE_DTDISP := Date()
								ZZE->ZZE_HRDISP := time()
								//ZZE->ZZE_DTAPRV
								//ZZE->ZZE_HRAPRV
								//ZZE->ZZE_UAPROV
								//ZZE->ZZE_JUSTAP
								//ZZE->ZZE_AP_REP
								ZZE->(MSunlock())
							Else

								IF ALLTRIM(M->ZD_DEVTOT) == 'Q'

									DBSELECTAREA("ZZE")
									DBSETORDER(4)
									DBGOTOP()
									IF (dbseek(xFilial("ZZE")+M->ZD_NUMNF+M->ZD_SERIE+"S"))  //Cliente ordem 4

										IF EMPTY(ZZE->ZZE_DTAPRC)

											RecLock("ZZE",.F.)
												ZZE->ZZE_QUANT  := _nQTTot
												ZZE->ZZE_VLRNF  := _nValNF
												ZZE->ZZE_DTDEV  := M->ZD_DTDEV
												ZZE->ZZE_MOTIVO := M->ZD_DESCMOT
												ZZE->ZZE_OBS    := M->ZD_OBSER
												ZZE->ZZE_QTQBRA := _nQBTot
												ZZE->ZZE_VLDESC := _nValTDV
												ZZE->ZZE_DTDISP := Date()
												ZZE->ZZE_HRDISP := time()
											ZZE->(MSunlock())
										ENDIF	

									ENDIF

									MSGINFO("Valores do processo de aprovação Cliente foram alterados: " + CHR(13) + CHR(10) +;
											"NF: "                + M->ZD_NUMNF                          + CHR(13) + CHR(10) +;
											"Serie: "             + M->ZD_SERIE                          + CHR(13) + CHR(10) +;
											"Valor do desconto: " + CVALTOCHAR(_nValTDV)                 + CHR(13) + CHR(10) +;
											"Cliente: "           + M->ZD_CODCLI                         + CHR(13) + CHR(10) +;
											" Loja: "             + M->ZD_LOJA, "Atenção")

								ELSE

									MSGINFO("Ja existe processo de aprovação para esta NF/Serie/desconto cliente","Atenção")

								ENDIF			

							Endif
						Endif
					Endif
				End Transaction
				//Mauricio 24/04/13 tratamento para incluir pedido de venda por copia ou para gerar justificativa.
				DbSelectArea("SC5")
				lRetorno := .F.
				_nOp := 3

				//Falta criar motivos EXPEDICAO E TRANSPORTE na tabela SZS para incluir aqui embaixo os codigos corretos,
				//pois segundo James apenas quando Devolução for T e motivo Expedicao ou transporte sera aberto tela para incluir PV por copia
				IF alltrim(M->ZD_DEVTOT) == 'T' //.AND. (Alltrim(M->ZD_MOTIVO) == '99' .OR. Alltrim(M->ZD_MOTIVO) == '99')
					DbSelectArea("SZU")
					dbSetOrder(1)
					if dbseek(xFilial("SZU")+Alltrim(M->ZD_RESPONS))
						_cNomResp := SZU->ZU_DESCRI

						If SZU->ZU_GERPED	  //reprogramou
							If ApMsgYesNo(OemToAnsi("Inclui Pedido de venda por copia " + Chr(13) + Chr(13) + "para esta ocorrencia ?"),OemToAnsi("A T E N Ç Ã O"))							

								cNumPedOri := SC5->C5_NUM // RICARDO LIMA - 02/02/18

								// *** INICIO CHAMADO 040114 || FINANCAS || ANDREA || PV. REPROGRAMADO WILLIAM COSTA 02/03/2018 *** //

								SqlBuscaPedCopiado(FWFILIAL("SC5"),cNumPedOri)

								IF TRC->(EOF()) .OR. ALLTRIM(SC5->C5_EST) <> 'EX' //SE EXISTIR NAO DEIXA ENTRAR

									// *** FINAL CHAMADO 040114 || FINANCAS || ANDREA || PV. REPROGRAMADO WILLIAM COSTA 02/03/2018 *** //    														

									lRetorno := A410Copia("SC5",SC5->(Recno()),_nOp)

									// *** INICIO CHAMADO 040114 || FINANCAS || ANDREA || PV. REPROGRAMADO WILLIAM COSTA 02/03/2018 *** //
									IF lRetorno == 1 //SIGNIFICA QUE COPIOU CORRETAMENTE

										TRC->(dbCloseArea())
										LiberaPVAutomatico(cNumPedOri)

									ENDIF
									// *** FINAL CHAMADO 040114 || FINANCAS || ANDREA || PV. REPROGRAMADO WILLIAM COSTA 02/03/2018 *** //													

									MandaEmail(alltrim(M->ZD_DEVTOT),M->ZD_CODCLI,M->ZD_LOJA,M->ZD_NOMECLI,M->ZD_DESCMOT,M->ZD_OBSER,_cNomResp,1)

									//gera log de reprogramacao
									u_GrLogZBE (Date(),TIME(),cUserName," REPROGRAMACAO","LOGISTICA","AD0019",;
									"PEDIDO REPROGRAMADO "+M->ZD_PEDIDO+" CLIENTE "+M->ZD_CODCLI+" LOJA "+M->ZD_LOJA,ComputerName(),LogUserName())

									// *** INICIO CHAMADO 040114 || FINANCAS || ANDREA || PV. REPROGRAMADO WILLIAM COSTA 02/03/2018 *** //	
								ELSE

									IF ALLTRIM(SC5->C5_EST) == 'EX'

										MsgStop("OLÁ " + Alltrim(cUserName) + ", Pedido de Exportação não pode ser Reprogramado, contate a Equipe de Exportação, por favor, verifique.", "AD0019-1 - Ocorrências / Devolução")

									ELSE

										MsgStop("OLÁ " + Alltrim(cUserName) + ", Pedido já reprogramado,Num Ped: " + TRC->C5_NUM + " por favor, verifique.", "AD0019-2 - Ocorrências / Devolução")

									ENDIF

								ENDIF	 
								TRC->(dbCloseArea())
								// *** FINAL CHAMADO 040114 || FINANCAS || ANDREA || PV. REPROGRAMADO WILLIAM COSTA 02/03/2018 *** //

							Else   // nao reprogramou
								MandaEmail(alltrim(M->ZD_DEVTOT),M->ZD_CODCLI,M->ZD_LOJA,M->ZD_NOMECLI,M->ZD_DESCMOT,M->ZD_OBSER,_cNomResp,2) //Mauricio 24/04/13 - função em desenvolvimento para justificativa de nao geraçao de novo pedido de venda.
							Endif

						Else //tambem não reprogramou
							MandaEmail(alltrim(M->ZD_DEVTOT),M->ZD_CODCLI,M->ZD_LOJA,M->ZD_NOMECLI,M->ZD_DESCMOT,M->ZD_OBSER,_cNomResp,1)
						Endif
					Endif
				Else
					DbSelectArea("SZU")
					dbSetOrder(1)
					if dbseek(xFilial("SZU")+M->ZD_RESPONS)
						_cNomResp := SZU->ZU_DESCRI
						MandaEmail(alltrim(M->ZD_DEVTOT),M->ZD_CODCLI,M->ZD_LOJA,M->ZD_NOMECLI,M->ZD_DESCMOT,M->ZD_OBSER,_cNomResp,1)
					Endif
				Endif
			Endif
		Endif
		
	ElseIf Len(aCols) <= 0 .And. nOpcE <> 2 .And. ! Empty(cNFSF) .And. ! Empty(cSerieSF) //Everson - 26/03/2019-044314.

		MsAguarde({|| U_ADLOG047P(cNFSF,cSerieSF) },"Aguarde","Lançando ocorrência de frete...")
		
	Endif
	
	//Everson - 21/03/2019|044314. Lançamento de desconto por devolução.
	If _lRet .And. nOpcE <> 2
		MsAguarde({|| U_ADLOG047P(cNFSF,cSerieSF) },"Aguarde","Lançando ocorrência de frete...")
	
	EndIf

	//Everson - 27/04/2018. Chamado 037261. Envio de Caso (ocorrência de devolução total ou parcial) ao SalesForce.
	If FindFunction("U_ADVEN084P") .And. lSalesForce
		U_ADVEN084P(cNFSF,cSerieSF,.F.,"")

	EndIf

	//Volto a posição de chamada
	dbSelectArea(_cAlias)
	dbSetOrder(_cOrder)
	dbGoto(_cRecno)

Return()

User Function Linha_ok()

	U_ADINF009P('AD0019' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Alteracao das devolucoes')

	If Len(aCols) >	_nAcols
		_lRet := .F.
	Else
		_nQtd_Ven := aCols[n][8]
		_nQtd_Dev := aCols[n][1]
		If _nQtd_Dev > _nQtd_Ven
			MSGBOX(" Quantidade Maior que Vendida !!! ")
			_lRet := .F.
		Else
			_lRet := .T.
		Endif
	Endif

RETURN _lRet

User function traznfs(_cPedido)

	Local _aNotasF := {}
	Local _aArea:=GetArea()

	U_ADINF009P('AD0019' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Alteracao das devolucoes')

	dbSelectArea("SC6")
	dbSetOrder(1)
	if dbseek(_cPedido,.T.)
		while SC6->C6_FILIAL+SC6->C6_NUM = _cPedido
			if ascan(_aNotasF, {|x| x[1] = SC6->C6_NOTA}) = 0 .and. !Empty(SC6->C6_NOTA)
				aadd(_aNotasF,{SC6->C6_NOTA,SC6->C6_SERIE})
			endif 
			dbskip()
		end
	endif

	Restarea(_aArea)
return _aNotasF

Static Function MandaEmail(_cDev,_cC,_cL,_cN,_cM,_cO,_cRsp,_nT)

	Local cMotivo 	:= Space(115)
	Local nOpt 		:= 0
	Local lRet		:= .f.
	Local _lMail	:= .f.
	Local _nTotSC6	:= 0
	Local _cMens	:= " "
	Local _cMens1	:= " "
	Local _cMens2	:= " "
	Local _cMens3	:= " "
	Local _cDev
	Local _cC
	Local _cL
	Local _cN
	Local _cM
	Local _cO
	Local _cAlias := ''
	Local _cIndex := ''
	Local _cRecno := ''


	If _nT <> 1    
		DEFINE MSDIALOG oDlg FROM	18,1 TO 80,550 TITLE "ADORO S/A  -  DEVOLUCAO NAO REPROGRAMADA" PIXEL  
		@  1, 3 	TO 28, 242 OF oDlg  PIXEL
		If File("adoro.bmp")
			@ 3,5 BITMAP oBmp FILE "adoro.bmp" OF oDlg NOBORDER SIZE 25,25 PIXEL 
			oBmp:lStretch:=.T.
		EndIf
		@ 05, 37	SAY "Motivo:" SIZE 24, 7 OF oDlg PIXEL 
		@ 12, 37  	MSGET cMotivo  SIZE	200, 9 OF oDlg PIXEL Valid !Empty(cMotivo)    
		DEFINE SBUTTON FROM 02,246 TYPE 1 ACTION (nOpt := 1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM 16,246 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		nOpt := 1
	Endif   

	If nOpt == 1
		_lMail	:= .T.
		lRet 		:= .T.
	Else
		return(lRet)
	Endif

	If _lMail	

		// *** INICIO Chamado 040890 || ADM.LOG || MARCEL || WOKFLOW - DEVOLUCAO // WILLIAM COSTA 12/04/2018 *** //

		IF ALLTRIM(SC5->C5_NUM) == ''

			_cAlias := Alias()
			_cIndex := IndexOrd()
			_cRecno := Recno()

			DBSELECTAREA("SC5")
			DBSETORDER(1)
			DBSEEK(xFilial("SC5")+cNumPedOri)

		ENDIF
		// *** FINAL Chamado 040890 || ADM.LOG || MARCEL || WOKFLOW - DEVOLUCAO // WILLIAM COSTA 12/04/2018 *** //		    

		_cMens1 := '<html>'
		_cMens1 += '<head>'
		_cMens1 += '<meta http-equiv="content-type" content="text/html;charset=iso-8859-1">'
		_cMens1 += '<meta name="generator" content="Microsoft FrontPage 4.0">'
		_cMens1 += '<title>Devolucao NF</title>'
		_cMens1 += '<meta name="ProgId" content="FrontPage.Editor.Document">'
		_cMens1 += '</head>'
		_cMens1 += '<body bgcolor="#C0C0C0">'
		_cMens1 += '<center>'
		_cMens1 += '<table border="0" width="982" cellspacing="0" cellpadding="0">'
		_cMens1 += '<tr height="80">'
		_cMens1 += '<td width="100%" height="80" background="">&nbsp;</td>'
		_cMens1 += '</tr>'
		_cMens1 += '</center>'
		_cMens1 += '<tr>'
		_cMens1 += '<td width="100%" bgcolor="#386079">'
		_cMens1 += '<div align="left">'
		_cMens1 += '<table border="1" width="100%">'
		_cMens1 += '<tr>'
		_cMens1 += '<td width="982" bordercolorlight="#FAA21B" bordercolordark="#FAA21B">'
		_cMens1 += '<b><font face="Arial" color="#FFFFFF" size="4">Pedido: '+SC5->C5_NUM+'</font></b>'
		_cMens1 += '</td></tr>'
		_cMens1 += '</table>'
		_cMens1 += '</div>'
		_cMens1 += '</td>'
		_cMens1 += '</tr>' 
		_cMens1 += '<center>'
		_cMens1 += '<tr>'
		_cMens1 += '<td width="100%">'
		_cMens1 += '<table border="1" width="982">'
		_cMens1 += '<tr>'
		_cMens1 += '<td width="87" bgcolor="#FAA21B"><font face="Arial" size="1">Cod.Cliente:</font></td>'
		_cMens1 += '<td width="38" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_CLIENTE+'</font></td>'
		_cMens1 += '</center>'
		_cMens1 += '<td width="25" bgcolor="#FAA21B">'
		_cMens1 += '<p align="right"><font face="Arial" size="1">Loja:</font></td>'
		_cMens1 += '<center>'
		_cMens1 += '<td width="17" bgcolor="#FFFFFF">'
		_cMens1 += '<p align="center"><font face="Arial" size="1">'+SC5->C5_LOJACLI+'</font></td>'
		_cMens1 += '</center>'
		_cMens1 += '<td width="36" bgcolor="#FAA21B">'
		_cMens1 += '<p align="right"><font face="Arial" size="1">Nome:</font></td>'
		_cMens1 += '<center>'
		_cMens1 += '<td width="751" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_NOMECLI+'</font></td>'
		_cMens1 += '</tr>'
		_cMens1 += '</table>'
		_cMens1 += '<table border="1" width="982">'

		_cMens1 += '</table>'
		_cMens1 += '</tr>'
		_cMens1 += '</table>'
		_cMens1 += '<center><table border="1" width="982">'			
		_cMens1 += '</table>'
		_cMens1 += '<table border="1" width="982">'		
		_cMens1 += '</table>'
		_cMens1 += '<table border="1" width="982">'
		_cMens1 += '<tr>'
		_cMens1 += '<td width="7%" bgcolor="#FAA21B">'
		_cMens1 += '<p align="center"><font size="1" face="Arial">Responsavel: '+_cRsp+'</font></p>'			
		//_cMens1 += '<td width="15%" bgcolor="#FAA21B" align="center"><font face="Arial" size="1">Carteira:</font></td>'
		_cMens1 += '</center>'
		_cMens1 += '<td width="66%" bgcolor="#FFFFFF">'
		DBSelectArea("SA3")
		DBSetOrder(1)
		DBSeek(XFilial("SA3")+SC5->C5_VEND1)
		//_cMens1 += '<p align="left"><font face="Arial" size="1">'+UPPER(ALLTRIM(SA3->A3_NOME))+'</font></p>'
		_cMens1 += '</td></tr></table><center>'
		_cMens1 += '<table border="1" width="982">'
		_cMens1 += '<tr>'
		_cMens1 += '<td width="982%" bgcolor="#FAA21B">'
		_cMens1 += '<p align="center"><font face="Arial" size="1">Motivo</font></td>'
		_cMens1 += '</tr><tr>'
		_cMens1 += '<td width="982" bgcolor="#FFFFFF">'
		_cMens1 += '<p align="center"><b><font color="#FF0000" face="Verdana" size="3">'+"Motivos devolução:  "+Alltrim(cMotivo)+" / "+Alltrim(_cO)+" / "+Alltrim(_cM)+'</font></b></p>
		_cMens1 += '</tr>'			
		_cMens3	+= '</td>'
		_cMens3	+= '</tr>'
		_cMens3	+= '</table>'
		_cMens3	+= '</center>'
		_cMens3	+= '</body>'
		_cMens3	+= '</html>'

		DbSelectArea("SA3")
		DbSetOrder(1)
		DbSeek(Xfilial("SA3")+SC5->C5_VEND1)
		_eMailVend := SA3->A3_EMAIL

		DbSelectArea("SZR")
		DbSetOrder(1)
		DbSeek(Xfilial("SZR")+SA3->A3_CODSUP)
		_eMailSup := alltrim(UsrRetMail(SZR->ZR_USER))
		cEmail := _eMailVend+';'+_eMailSup+';'+"cal@adoro.com.br"	// Em 23/02/2016 incluido o parâmetro MV_EMAILS2 - CHAMADO 026668

		_cMens := _cMens1+_cMens3
		_cData := transform(MsDate(),"@!")
		_cHora := transform(Time(),"@!")  

		If _nT == 2

			lRet := U_ENVIAEMAIL(GetMv("MV_RELFROM"),cEmail,_cMens,"PEDIDO No."+cNumPedOri+" FOI DEVOLVIDO EM - "+_cData+" - "+_cHora,"") //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM 

		Else

			// *** INICIO Chamado 040890 || ADM.LOG || MARCEL || WOKFLOW - DEVOLUCAO // WILLIAM COSTA 12/04/2018 *** //
			IF ALLTRIM(SC5->C5_PRIOR)   == 'R'

				lRet := U_ENVIAEMAIL(GetMv("MV_RELFROM"),cEmail,_cMens,"PEDIDO No."+cNumPedOri+" FOI REPROGRAMADO" + " PARA: " +SC5->C5_NUM +  " EM - "+_cData+" - "+_cHora,"") //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM

			ELSE

				lRet := U_ENVIAEMAIL(GetMv("MV_RELFROM"),cEmail,_cMens,"PEDIDO No."+cNumPedOri+" FOI DEVOLVIDO" +  " EM - "+_cData+" - "+_cHora,"") //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM

			ENDIF

			IF !EMPTY(_cAlias)

				//Volto a posição de chamada
				dbSelectArea(_cAlias)
				dbSetOrder(_cIndex)
				dbGoto(_cRecno)

			ENDIF

			// *** FINAL Chamado 040890 || ADM.LOG || MARCEL || WOKFLOW - DEVOLUCAO // WILLIAM COSTA 12/04/2018 *** //

		Endif   			
	Endif

	//+-----------------------------------------+
	//|Nao consegui enviar o e-mail vou exibir  |
	//|o resultado em tela                      |
	//+-----------------------------------------+                                                                                                          
	/*
	If !lRet 
	ApMsgInfo("Nao foi possível o Envio do E-mail.O E-mail será impresso em "+;
	"Tela e o registro será processado. "+;
	"Possíveis causas podem ser:  Problemas com E-mail do destinatário "+;
	"ou  no serviço interno de E-mail da empresa.","Erro de Envio")
	//+---------------------------------+
	//|Montando arquivo de Trabalho     |
	//+---------------------------------+	
	_aFile:={}
	AADD(_aFile,{"LINHA","C",1000,0})    
	_cNom := CriaTrab(_aFile)
	dbUseArea(.T.,,_cNom,"TRB",.F.,.F.)		
	DbSelectArea("TRB")

	//+----------------------------------+
	//|Montando o Texto em TRB           |
	//+----------------------------------+	

	TxtNew:=ALLTRIM(STRTRAN(_cMens,CHR(13),"ª"))+"ª"  
	TEXTO :=''
	For I:=0 to LEN(TxtNew)
	// Pego o proximo bloco
	TEXTO+=SUBSTR(TxtNew,1,1)	
	// Exclui o caracter posicionado
	TxtNew:=STUFF(TxtNew,1,1,"")	
	If 	LEN(TEXTO)>=200 	//txt=="ª" .or. _nTamLin > limite			
	TEXTO:=SUBSTR(TEXTO,1,LEN(TEXTO)-1)
	RecLock("TRB",.t.)
	Replace TRB->LINHA With TEXTO 
	MsUnlock()
	TEXTO:=""							
	Endif
	Next

	//+-------------------------+
	//|Copiando para Arquivo    |
	//+-------------------------+

	DbSelectArea("TRB")    	
	//COPY to &"c:\"+_cNom+".html" SDF  
	cPath := GetSrvProfString("StartPath","")+"PED_EXC\"
	COPY to &cPath+_cNom+".html" SDF	

	DbCloseArea("TRB")

	//ShellExecute('open',"c:\"+_cNom+".html",'','',1)
	ShellExecute('open',cPath+_cNom+".html",'','',1)

	Endif
	*/
Return()

STATIC FUNCTION LiberaPVAutomatico(cNumPedOri)

	LOCAL   _NVLRITEM := 0
	LOCAL   _nLimCred := 0
	LOCAL   _lCondRA  := .F. //29/01/2021 : Adriano Savoine
	Local   lLiber    := .F.
	Local   lTrans    := .F.
	Local   lCredito  := .F.
	Local   lEstoque  := .F.
	Local   lAvCred   := .T.
	Local   lAvEst    := .F.
	Local   nQtdVen   := 0  
	PRIVATE _CNUMPED  := ''
	PRIVATE _CCLIENTE := ''
	PRIVATE _CLOJA    := ''
	
	

	SqlBuscaPedCopiado(FWFILIAL("SC5"),cNumPedOri)

	While TRC->(!EOF())

		_cNumPed  := TRC->C5_NUM
		_cCliente := TRC->C5_CLIENTE
		_cLoja    := TRC->C5_LOJACLI
		_Tipo     := TRC->C5_TIPO
		_Estado   := TRC->C5_EST
		_nLimCred := Posicione("SA1",1,xFilial("SA1")+_cCliente+_cLoja,"A1_LC")
		_lBloq    := .F. 
		_lCondRA  := AllTrim(Posicione("SE4",1,FWxFilial("SE4")+TRC->C5_CONDPAG,"E4_CTRADT")) == "1" // Cond Adiantamento = SIM 29/01/2021 : Adriano Savoine

		DBSELECTAREA("SC5")
		DBSETORDER(1)
		IF DBSEEK(xFilial("SC5")+_cNumPed)

			IF !EMPTY(SC5->C5_LIBEROK)

				RECLOCK("SC5",.F.)

				SC5->C5_LIBEROK := "" 
				
				
				//29/01/2021 : Adriano Savoine
				IF _lCondRA
					SC5->C5_XWSPAGO := "M" 
				EndIF

				MSUNLOCK()

			ENDIF
			
			//Everson - 17/05/2018. Chamado 037261. SalesForce.
			RECLOCK("SC5",.F.)

				SC5->C5_XGERSF  := "1"
				SC5->C5_XPEDSAL := "" 

			MSUNLOCK()			
			
		ENDIF

		DBSELECTAREA("SC6")
		DBSETORDER(1)
		IF DBSEEK(xFilial("SC6")+_cNumPed)

			WHILE !EOF() .And. SC6->C6_NUM == _cNumPed

				nQtdVen := SC6->C6_QTDVEN

				RECLOCK("SC6")

				// Efetua a liberação item a item de cada pedido
				Begin transaction

					MaLibDoFat( SC6->( Recno() ), @nQtdVen, @lCredito, @lEstoque, lAvCred, lAvEst, lLiber, lTrans )

				End transaction

				SC6->(MsUnLock())

				Begin Transaction

					SC6->(MaLiberOk({TRC->C5_NUM},.F.))

				End Transaction

				SC6->(dbSkip())

			ENDDO

			DBSELECTAREA("SC9")
			DBSETORDER(1)
			IF DBSEEK(xFilial("SC9")+TRC->C5_NUM)
				WHILE !EOF() .And. TRC->C5_NUM == SC9->C9_PEDIDO

					RECLOCK("SC9",.F.)

					SC9->C9_DTENTR := STOD(TRC->C5_DTENTR)
					SC9->C9_VEND1  := TRC->C5_VEND1
					SC9->C9_BLEST  := ""            //Libera Estoque
					SC9->C9_BLCRED := ""            //Libera Credito

					MSUNLOCK()

					SC9->(dbSkip())
				ENDDO
			ENDIF
		ENDIF

		TRC->(dbSkip())            
	ENDDO
	TRC->(dbCloseArea())

RETURN(NIL)

STATIC FUNCTION SqlBuscaPedCopiado(cFilSc5,cNumOri)

	BeginSQL Alias "TRC"
		%NoPARSER%  
		SELECT C5_NUM,C5_CLIENTE,C5_LOJACLI,C5_TIPO,C5_EST,C5_VEND1,C5_DTENTR,C5_CONDPAG
		FROM SC5010 WITH (NOLOCK)
		WHERE C5_FILIAL  = %EXP:cFilSc5%
		AND C5_XPDEVOR = %EXP:cNumOri%
		AND D_E_L_E_T_ <> '*' 

	EndSQl             

RETURN(NIL)
