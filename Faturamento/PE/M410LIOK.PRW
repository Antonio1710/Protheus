#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch" 
#INCLUDE "rwmake.ch"

/*/{Protheus.doc} User Function M410LIOK
	Ponto de entrada para verificacao de nf de remessa futura foi gerada anteriormente, 
	caso nao tenha sido nao podera digitar o pedido remessa de mercadoria
	@type  Function
	@author HCCONSYS
	@since 16/10/07
	@version version
	@history HEVERSON      - 14/12/2007 - T.I    - Alterado para consistir CFOP conf. UF do cliente           
	@history Ricrado Lima  - 02/02/2018 - 040649 - nao permite gerar pedido com quantidade maior que a origem  
	@history FWNM          - 17/06/2019 - 049708 - OS 051009||CONTROLADORIA||DANIELLE_MEIRA||8459||ADFAT008P   
	@history FWNM          - 03/07/2019 - 050230 - TI - ERROR LOG type mismatch on + on CHKZCN(M410LIOK.PRW) 02/07/2019 12:14:13 line : 637 - FWNM - 03/07/2019
	@history FWNM          - 16/09/2019 - 051559 - OS 053110 || TECNOLOGIA || FERNANDO_SIGOLI || 8451|| SHELFLIFE
	@history Adriana       - 19/07/2019 - 048946 - Valida C6_ITEMPC, devido ao erro na transmissao da NF: Element'{http://www.portalfiscal.inf.br/nfe}nItemPed': [facet 'pattern'] The value '5.3' is not accepted by the pattern '[0-9]{1,6}'
	@history Adriana       - 23/07/2019 - TI     - Valida C6_ITEMPC, correcao da validacao para preenchimento com zeros a esquerda
	@history Abel Babini   - 22/11/2019 - 040922 || OS 042030 || FISCAL || DEJAIME || 8921 || RE. NF EMITIDAS
	@history William Costa - 01/04/2020 - 057050 || OS 058523 || ALMOXARIFADO || FABIO || 8410 || SALDO ESTOQUE
	@history Ticket  TI    - Leonardo P. Monteiro - 26/02/2022 - Inclusão de conouts no fonte. 
/*/

User Function M410LIOK()

	Local _aAreaSC5	:=SC5->(GetArea())
	Local _aAreaSC6	:=SC6->(GetArea())
	Local _aAreaSF2	:=SF2->(GetArea())
	Local _aAreaSA1	:=SA1->(GetArea())
	Local _aAreaSA2	:=SA2->(GetArea())
	Local _aAreaSB1	:=SB1->(GetArea())

	Local _aArea		:= GetArea()
	Local _lRet			:= .T. 
	Local _nPosNFRF		:= 0  //ASCAN(aHeader,{|x| ALLTRIM(x[2])=="C6_XNFORI"})
	Local _cNFRF		:= "" //(aCols[n,_nPosNFRF])
	Local _nPosSRF		:= 0  //ASCAN(aHeader,{|x| ALLTRIM(x[2])=="C6_XSERIE"})
	Local _cSRF			:= "" //(aCols[n,_nPosSRF])
	Local _nPosCF		:= 0 
	Local _cCFOP		:= "" // cfop 
	Local _cEst			:= "" // Estado Cliente / Fornecedor  
	Local _n			:= 0 
	Local _produto		:= ""
	Local _ProVen     	:= {}
	Local _aTES       	:= {}
	Local _aTESST     	:= {}
	Local _cEst1                             
	
	//INICIO Abel Babini - 22/11/2019 - 040922 || OS 042030 || FISCAL || DEJAIME || 8921 || RE. NF EMITIDAS
	Local cTesDev   := ''
	Local cTesEnt	:= ''
	Local _aAreaSF4	:=SF4->(GetArea())
	//Fim Abel Babini - 22/11/2019 - 040922 || OS 042030 || FISCAL || DEJAIME || 8921 || RE. NF EMITIDAS

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄadminÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³INICIOTRATAMENTO INTEGGRACAO SAG X PROTHEUS KF-30/11/15  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	Local _xN       := 0
	Local cTesRem	:= SuperGetMV("FS_TESREMI" ,,"702|705|735")  // trata todas as operacoes de remessa para industrialização
	Local _nPosTes  := 0                         	                 
	Local _xOper	:= M->C5_TIPO                              
	Local _cCod		:= M->C5_CLIENTE
	Local _cLoja	:= M->C5_LOJACLI
	Local cRedeOP	:= GetMV("MV_#REDEOP") //Redes as quais é obrigatorio preencher Operador Logistico, ou Filial, e numero do pedido do cliente, em nosso Pedido de Venda (SAPORE / MASSIMA)- por Adriana chamado 031238 em novembro/2016
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄadminÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³FIM TRATAMENTO INTEGGRACAO SAG X PROTHEUS KF-30/11/15 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//Ricrado Lima - 02/02/18
	Local cQuery   := ""
	Local nQtdori  := 0
	Local cCodPrj  := ""
	Local cCC      := ""
	Local nLocal   := 0
	Local nLocaliz := 0
	Local i			:= 1
	Local nTotCol	:= 0
	
	Private lSfInt	:= (IsInCallStack('U_RESTEXECUTE') .OR. IsInCallStack('RESTEXECUTE'))

	Conout( DToC(Date()) + " " + Time() + " M410LIOK >>> INICIO PE" )

	//_lSapore	:= .f. //incluido por Adriana para validacao dados SAPORE            
	_lRedeOp	:= .f. // por Adriana chamado 031238 em novembro/2016
	_nPosNFRF	:=ASCAN(aHeader,{|x| ALLTRIM(x[2])=="C6_NFORI"})
	_cNFRF		:=(aCols[n,_nPosNFRF])
	_nPosSRF	:=ASCAN(aHeader,{|x| ALLTRIM(x[2])=="C6_SERIORI"})
	_cSRF		:=(aCols[n,_nPosSRF])
	_nPosCF		:= ASCAN(aHeader,{|x| ALLTRIM(x[2])=="C6_CF"})
	_cCFOP		:= (aCols[n,_nPosCF]) 
	_nPosPRO  	:= ASCAN(aHeader,{|x| ALLTRIM(x[2])=="C6_PRODUTO" })
	_nPosQTDF 	:= ASCAN(aHeader,{|x| ALLTRIM(x[2])=="C6_UNSVEN"  })
	_nPosQTD  	:= ASCAN(aHeader,{|x| ALLTRIM(x[2])=="C6_QTDVEN"  })
	_nPosVLR  	:= ASCAN(aHeader,{|x| ALLTRIM(x[2])=="C6_VALOR"   })
	_nPosPRC  	:= ASCAN(aHeader,{|x| ALLTRIM(x[2])=="C6_PRCVEN"  })    
	_nPosPCLI  	:= ASCAN(aHeader,{|x| ALLTRIM(x[2])=="C6_PEDCLI"  }) //incluido por Adriana
	_nPosVend  	:= ASCAN(aHeader,{|x| ALLTRIM(x[2])=="C6_VEND"    }) //incluido por Adriana
	_nPosNumPCom:= ASCAN(aHeader,{|x| ALLTRIM(x[2])=="C6_NUMPCOM" }) //incluido por Adriana em 27/04/2016 Chamado 028191 
	_nPosItemPC	:= ASCAN(aHeader,{|x| ALLTRIM(x[2])=="C6_ITEMPC"  }) //incluido por Adriana em 27/04/2016 Chamado 028191 
	nLocaliz  	:= ASCAN(aHeader,{|x| ALLTRIM(x[2])=="C6_LOCALIZ" }) //incluido por William
	nLocal  	:= ASCAN(aHeader,{|x| ALLTRIM(x[2])=="C6_LOCAL"   }) //incluido por William


	// FWNM - Projeto Investimento - 06/04/2018
	If AllTrim(cEmpAnt) == "01" .and. AllTrim(M->C5_TIPO) == "D"
		
		// busco dados da nf de origem
		aAreaSD1 := SD1->( GetArea() )
		nTotCol	:= Len(aCols)

		For i:=1 to nTotCol
		
			cNFOri  := gdFieldGet("C6_NFORI", i)
			cSerOri := gdFieldGet("C6_SERIORI", i)
			cItmOri := gdFieldGet("C6_ITEMORI", i)
			cCodPrd := gdFieldGet("C6_PRODUTO", i)

		
			SD1->( dbSetOrder(1) ) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM                                                                                                     
			If SD1->( dbSeek( xFilial("SD1")+cNFOri+cSerOri+M->C5_CLIENTE+M->C5_LOJACLI+cCodPrd+cItmOri) ) 
				cCodPrj := SD1->D1_PROJETO
				cCC     := SD1->D1_CC
			EndIf
		
			// Insiro o codigo do projeto utilizado na entrada
			gdFieldPut("C6_XPROJET", cCodPrj, i)

		Next i

		RestArea( aAreaSD1 ) 

	EndIF
	// FWNM - FIM
		
	// Chamado n. 049708 || OS 051009 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || ADFAT008P - FWNM - 17/06/2019
	If _lRet
		_lRet := ChkZCN()
		
		If !_lRet
			Conout( DToC(Date()) + " " + Time() + " M410LIOK >>> FINAL PE" )
			Return _lRet
		EndIf
	EndIf
	//

	// Chamado n. 051559 || OS 053110 || TECNOLOGIA || FERNANDO_SIGOLI || 8451 || SHELFLIFE - fwnm - 16/09/2019
	UpShelfLife()
	// 
	If Alltrim(cEmpAnt) <> "01"    //Incluido por Adriana devido ao error.log quando empresa <> 01 - chamado 032804
		RestArea(_aAreaSC5)
		RestArea(_aAreaSC6)
		RestArea(_aAreaSF2)	
		RestArea(_aAreaSA1)
		RestArea(_aAreaSA2)	
		RestArea(_aAreaSB1)
		RestArea(_aArea)                   

		Conout( DToC(Date()) + " " + Time() + " M410LIOK >>> FINAL PE" )
		Return(_lret)

	Endif
	
	aCols[N,_nPosVend] := M->C5_VEND1 //Incluido por Adriana para gravar corretamente o código do vendedor
	aCols[N,nLocaliz]  := IIF(ALLTRIM(M->C5_TIPO) == "D" .AND. ALLTRIM(aCols[N,_nPosNFRF]) <> "",Posicione("SBE",10,FWXFilial("SBE")+aCols[N,_nPosPRO]+aCols[N,nLocal],"BE_LOCALIZ"),aCols[N,nLocaliz]) //Incluido por WILLIAM COSTA para gravar corretamente o código do endereço do produto quando tiver.057050 || OS 058523 || ALMOXARIFADO || FABIO || 8410 || SALDO ESTOQUE

	SB1->(dbSetOrder(1))
	SB1->( dbSeek(xFilial("SB1")+aCols[N,_nPosPRO]))
	
	If aCols[N,_nPosQTD] <> Iif(SB1->B1_TIPCONV<>"M",SB1->B1_CONV*aCols[N,_nPosQTDF],SB1->B1_CONV/aCols[N,_nPosQTDF]) .AND.;
	!aCOLS[1][Len(aHeader)+1] .AND. SB1->B1_CONV > 0

		aCols[N,_nPosQTD] := Iif(SB1->B1_TIPCONV<>"M",SB1->B1_CONV*aCols[N,_nPosQTDF],SB1->B1_CONV/aCols[N,_nPosQTDF])
		aCols[N,_nPosVLR] := aCols[N,_nPosQTD]*aCols[N,_nPosPRC]

		M->C6_QTDLIB2 := Iif(SB1->B1_TIPCONV<>"M",SB1->B1_CONV*aCols[N,_nPosQTDF],SB1->B1_CONV/aCols[N,_nPosQTDF])
		M->C6_PRCVEN  := aCols[N,_nPosQTD]*aCols[N,_nPosPRC]   

		lRefresh := .T.
	Endif

	If !lSfInt .And. Alltrim(_cCfop) $ "5116/6116"  // Venda originada em pedido de entrega futura 

		DbSelectArea("SF2")
		DbSetOrder(1)

		If DbSeek(xFilial("SF2") + _cNFRF + _cSRF + M->C5_CLIENTE + M->C5_LOJACLI,.T.)
			_lRet:=.T.
		Else  
			IF IsInCallStack('U_ADVEN002P')  == .T.
				Aadd(aPedidos,{cchave, ;
				''    , ;
				''    , ;
				''    , ;
				'Digite NF Original e Serie Original Nota Fisal Remessa Futura nao Encontrada' , ;
				cVendedor}) 

			ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
				Aadd(aPedidos,{'Digite NF Original e Serie Original Nota Fisal Remessa Futura nao Encontrada'})

			ELSE

				MsgInfo("Digite NF Original e Serie Original","Nota Fisal Remessa Futura nao Encontrada")

			ENDIF

			_lRet:=.F.
		EndIF

	Endif

	// Validação 
	If M->C5_TIPO $ "B/D"
		_cEst:=POSICIONE("SA2",1,xFilial("SA2")+M->C5_CLIENTE + M->C5_LOJACLI,"A2_EST")                                          
	ELSE
		_cEst:=POSICIONE("SA1",1,xFilial("SA1")+M->C5_CLIENTE + M->C5_LOJACLI,"A1_EST")   
		_lRedeOp := iif(AllTrim(POSICIONE("SA1",1,xFilial("SA1")+M->C5_CLIENTE + M->C5_LOJACLI,"A1_REDE"))$cRedeOp,.T.,.F.)    	//incluido por Adriana  //Alterado por Adriana chamado 031238 em novembro/2016      
		_lPC     := iif(POSICIONE("SA1",1,xFilial("SA1")+M->C5_CLIENTE + M->C5_LOJACLI,"A1_XOBRPC")="1",.T.,.F.)    		//incluido por Adriana  

		if _lRedeOp .and. Empty(aCols[n,_nPosPCLI])
			IF IsInCallStack('U_ADVEN002P')  == .T.
				Aadd(aPedidos,{cchave, ;
				''    , ;
				''    , ;
				''    , ;
				'Esta Rede, é obrigatório preencher Número Pedido Cliente !!! Ped Cliente' , ;
				cVendedor}) 

			ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
				Aadd(aPedidos,{'Esta Rede, é obrigatório preencher Número Pedido Cliente !!! Ped Cliente'})

			ELSE

				MsgInfo("Esta Rede, é obrigatório preencher Número Pedido Cliente !!!","MV_#REDEOP")

			ENDIF

			_lRet:=.F.	                                                                           
		endif
		if _lPC .and. (Empty(aCols[n,_nPosNumPCom]) .or. Empty(aCols[n,_nPosItemPC]) )	//incluido por Adriana em 27/04/2016 Chamado 028191 
			IF IsInCallStack('U_ADVEN002P')  == .T.
				Aadd(aPedidos,{cchave, ;
				''    , ;
				''    , ;
				''    , ;
				'É obrigatório preencher NUM.PED.COMP e ITEM PED.COM no item do Pedido !!! A1_XOBRPC' , ;
				cVendedor}) 

			ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
				Aadd(aPedidos,{'É obrigatório preencher NUM.PED.COMP e ITEM PED.COM no item do Pedido !!! A1_XOBRPC'})

			ELSE

				MsgInfo("É obrigatório preencher NUM.PED.COMP e ITEM PED.COM no item do Pedido !!!","A1_XOBRPC")

			ENDIF

			_lRet:=.F.	                                                                           
		endif

		//incluido por Adriana em 19/07/19 para somente aceitar números 0-9, no campo C6_ITEMPC - Chamado 048946 
		if transform(aCols[n,_nPosItemPC],"999999") <> aCols[n,_nPosItemPC] .and. .not. Empty(aCols[n,_nPosItemPC]) //Alterado por Adriana em 23/07/19 
	  		IF IsInCallStack('U_ADVEN002P')  == .T.
				Aadd(aPedidos,{cchave, ;
				''    , ;
				''    , ;
				''    , ;
				'Campo ITEM PED.COM só pode ser preenchido com números 0-9, no item do Pedido !!! C6_ITEMPC' , ;
				cVendedor}) 
				  
			ELSEIF lSfInt 
				Aadd(aPedidos,{'Campo ITEM PED.COM só pode ser preenchido com números 0-9, no item do Pedido !!! C6_ITEMPC'})

			ELSE

				MsgInfo("Campo ITEM PED.COM só pode ser preenchido com números 0-9, no item do Pedido !!!","C6_ITEMPC")

			ENDIF

			_lRet:=.F.	                                                                           
		endif
		//Fim chamado 048946
	endif 

	if SM0->M0_CODIGO == "01"  .AND. cfilant <> "08" // se diferente de Adoro Goias - alterado em 04/10/2016 por Adriana 

		If (subs(_cCfop,1,1) $ "6/7" .and. _cEst == "SP") .or. (subs(_cCfop,1,1) $ "5" .and. _cEst <> "SP") 
			IF IsInCallStack('U_ADVEN002P')  == .T.
				Aadd(aPedidos,{cchave, ;
				''    , ;
				''    , ;
				''    , ;
				'Digite Tipo Saida Cod.Fiscal Incorreto' , ;
				cVendedor}) 

			ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
				Aadd(aPedidos,{'Tipo Saida Cod.Fiscal Incorreto'})

			ELSE

				MsgInfo("Digite Tipo Saida","Cod.Fiscal Incorreto")

			ENDIF

			_lRet:=.F.
		EndIF

	Endif

	// Alterado para verificar se existe produto igual no mesmo pedido 
	// Alteracao feita pela HCCONSYS EM 15/01/09 

	If !lSfInt .And. M->C5_TIPO  == "N" .and. SM0->M0_CODIGO == "01"  .AND. (cfilant $ "02/06/07")  // Valido somente para empresa Adoro filial Varzea    //incluida filial 07 em 13/08/14

		For _n := 1 to Len(aCols)
			If !aCols[_N,Len(aCols[_N])]
				_Produto := aCols[_n,aScan(aHeader,{|x| Alltrim(x[2]) == 'C6_PRODUTO'})]
				_Elemento := Ascan(_ProVen,_Produto)
				if _Elemento == 0
					AaDd(_ProVen,_Produto)
				Else

					IF IsInCallStack('U_ADVEN002P')  == .T.
						Aadd(aPedidos,{cchave, ;
						''    , ;
						''    , ;
						''    , ;
						'Outro item neste pedido de venda com este produto ('+_Proven[_Elemento]+') ',;
						cVendedor}) 

					ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
						Aadd(aPedidos,{'Outro item neste pedido de venda com este produto ('+_Proven[_Elemento]+') '})

					ELSE

						MsgINFO("Outro item neste pedido de venda com este produto ("+_Proven[_Elemento]+") ",;
						"Verifique e Corrija.")

					ENDIF
					_lret:= .F. 
				EndIf
			EndIF

			//Incluido Ana 30/03/11 - Igual a trava do MT410TOK, pois estava deixando passar
			IF !M->C5_TIPO $ 'IPBD'     //ALTERADO POR ADRIANA PARA PERMITIR A ALTERACAO DO VALOR PARA NOTAS DE COMPLEMENTO DE ICMS E IPI, DEVOLUCAO E BENEFICIAMENTO
				DBSELECTAREA("DA1")
				DBSETORDER(1)
				IF (!DBSEEK( XFILIAL("DA1") + M->C5_TABELA + _Produto )  .OR. EMPTY(M->C5_TABELA)) .AND. !EMPTY(_Produto)
					DBSELECTAREA("SA3")
					DBSETORDER(7)
					IF DBSEEK (XFILIAL()+__CUSERID) .AND. cfilant $ "02/06/07" //incluida filial 07 em 13/08/14
						IF IsInCallStack('U_ADVEN002P')  == .T.
							Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							'Cliente sem tabela de preço em seu cadastro.Contate Depto. Comercial.O pedido nao podera ser incluido!' , ;
							cVendedor}) 

						ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
							Aadd(aPedidos,{'Cliente sem tabela de preço em seu cadastro.Contate Depto. Comercial.O pedido nao podera ser incluido!'})

						ELSE

							MsgInfo("Cliente sem tabela de preço em seu cadastro.Contate Depto. Comercial.O pedido nao podera ser incluido!")

						ENDIF

						_lret   := .F. //Mauricio - 02/03/11 - Solicitdo por Alex bloqueio quando nao tem tabela no cadastro do Cliente.					   
						//exit
					Else  
						//				   _lret   := .T. 
					Endif     			
				Endif
			Endif				

		Next _n
	Endif 
	// FIM DA ALTERACAO FEITA PELA HCCONSYS EM 15/01/09

	// Alterado para verificar se existe somente TES de ST ou somente outros tipos de TES para cliente no estado de MG (Tes parametro MV_STTSMG).	 
	// Alteracao feita por Mauricio - HCCONSYS EM 23/07/09
	// Em 13/08/09 incluido tratamento de ST para RS, igual ao efetuado para MG, inclusive utilizando as mesmas TES do parametro(Valeria). 
	// Em 10/03/10 alterado para considerar tambem a filial 06 - Itupeva - Leonardo (HC)
	//If M->C5_TIPO  == "N" .and. SM0->M0_CODIGO == "01"  .AND. cfilant == "02"  
	If M->C5_TIPO  == "N" .and. SM0->M0_CODIGO == "01"  .AND. (cfilant $ "02/06/07")//Valido para empresa Adoro filial Varzea/Itupeva //incluida filial 07 em 13/08/14
		_cMVTESMG := GETMV("MV_STTSMG")
		_cMVTESRS := GETMV("MV_STTSRS")
		If M->C5_TIPO $ "B/D"   
			_cEst1:=POSICIONE("SA2",1,xFilial("SA2")+M->C5_CLIENTE + M->C5_LOJACLI,"A2_EST")                                          
		ELSE 
			_cEst1:=POSICIONE("SA1",1,xFilial("SA1")+M->C5_CLIENTE + M->C5_LOJACLI,"A1_EST")                                          
		endif                 
		if _cEst1 == "MG"
			For _n := 1 to Len(aCols)
				If !aCols[_N,Len(aCols[_N])]
					_cTES := aCols[_n,aScan(aHeader,{|x| Alltrim(x[2]) == 'C6_TES'})]
					if AllTRIM(_cTES) $ _cMVTESMG
						_aElemST := Ascan(_aTESST,_cTES)
						if _aElemST == 0
							AADD(_aTESST,_cTES)
						endif    
					Else
						_aElem   := Ascan(_aTES,_cTES)
						if _aElem == 0
							AADD(_aTES,_cTES)
						Endif
					Endif
					if !Empty(_aTESST) .AND. !Empty(_aTES)	

						IF IsInCallStack('U_ADVEN002P')  == .T.
							Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							'Este Pedido possui itens com TES de Substituicao Tributaria junto a itens com ' + ;
							'TES sem ocorrencia de substituicao. Neste caso devem ser gerados pedidos em separado.', ;
							cVendedor}) 

						ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
							Aadd(aPedidos,{"Este Pedido possui itens com TES de Substituicao Tributaria junto a itens com " + Chr(13) + Chr(10) +;
							"TES sem ocorrencia de substituicao. Neste caso devem ser gerados pedidos em separado."})

						ELSE

							Aviso(	"M410LIOK-01",;
							"Este Pedido possui itens com TES de Substituicao Tributaria junto a itens com " + Chr(13) + Chr(10) +;
							"TES sem ocorrencia de substituicao. Neste caso devem ser gerados pedidos em separado."+ Chr(13) + Chr(10),;
							{ "&Retorna" },,;
							"TES com Substituicao Tributaria" )						

						ENDIF

						_lret:= .F. 
					EndIf
				EndIF
			Next _n
		Endif
		if _cEst1 == "RS"  //Desmenbrado tratamento para RS conforme chamado 004777 - Mauricio HC Consys.
			For _n := 1 to Len(aCols)
				If !aCols[_N,Len(aCols[_N])]
					_cTES := aCols[_n,aScan(aHeader,{|x| Alltrim(x[2]) == 'C6_TES'})]
					if AllTRIM(_cTES) $ _cMVTESRS
						_aElemST := Ascan(_aTESST,_cTES)
						if _aElemST == 0
							AADD(_aTESST,_cTES)
						endif    
					Else
						_aElem   := Ascan(_aTES,_cTES)
						if _aElem == 0
							AADD(_aTES,_cTES)
						Endif
					Endif
					if !Empty(_aTESST) .AND. !Empty(_aTES) 
						IF IsInCallStack('U_ADVEN002P')  == .T.
							Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							'Este Pedido possui itens com TES de Substituicao Tributaria junto a itens com ' + ;
							'TES sem ocorrencia de substituicao. Neste caso devem ser gerados pedidos em separado. ',  ;
							cVendedor}) 

						ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
							Aadd(aPedidos,{'Este Pedido possui itens com TES de Substituicao Tributaria junto a itens com ' + ;
							'TES sem ocorrencia de substituicao. Neste caso devem ser gerados pedidos em separado. '})

						ELSE

							Aviso(	"M410LIOK-01",;
							"Este Pedido possui itens com TES de Substituicao Tributaria junto a itens com " + Chr(13) + Chr(10) +;
							"TES sem ocorrencia de substituicao. Neste caso devem ser gerados pedidos em separado."+ Chr(13) + Chr(10),;
							{ "&Retorna" },,;
							"TES com Substituicao Tributaria" )						

						ENDIF	  


						_lret:= .F. 
					EndIf
				EndIF
			Next _n
		Endif	
	Endif
	//fim alteracao Mauricio - HC Consys.


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄadminÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³TRATAMENTO INTEGGRACAO SAG X PROTHEUS  - KF 30/11/15      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	_nPosTes  	:= ASCAN(aHeader,{|x| ALLTRIM(x[2])=="C6_TES"  })  

	If !lSfInt .And. aCols[N][Len(aHeader)+1]==.F. 

		If _xOper == "B"

			SF4->(DbSetOrder(1))
			SF4->(DbSeek(xFilial("SF4")+ aCols[N][_nPosTes]))			

			SA2->(DbSetOrder(1))
			SA2->(DbSeek(xFilial("SA2")+ _cCod + _cLoja ))			

			//verificação quanto ao tipo de fornecedor
			If SF4->F4_CODIGO $ cTesRem .AND. !(SA2->A2_XTIPO $ "1|2")
				IF IsInCallStack('U_ADVEN002P')  == .T.
					Aadd(aPedidos,{cchave, ;
					''    , ;
					''    , ;
					''    , ;
					'Tes invalida para o processo de remessa/incubatorio/integrado. Verifique!' ,;
					cVendedor}) 

				ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
					Aadd(aPedidos,{'Tes invalida para o processo de remessa/incubatorio/integrado. Verifique!'})

				ELSE

					MsgInfo("Tes invalida para o processo de remessa/incubatorio/integrado. Verifique!","Atencao")

				ENDIF

				_lRet:=.F.
			EndIf 

		EndIf	        

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄadminÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³FIM TRATAMENTO INTEGGRACAO SAG X PROTHEUS - KF 30/11/15      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	RestArea(_aAreaSC5)
	RestArea(_aAreaSC6)
	RestArea(_aAreaSF2)
	RestArea(_aAreaSA1)
	RestArea(_aAreaSA2)
	RestArea(_aAreaSB1)
	RestArea(_aArea)                   
	
	//Everson - 14/03/2018. Chamado 037261.
	If !lSfInt
		//if INCLUI .Or. ALTERA   //Chamado 008308 - Mauricio - Na exclusão nao chamar a validação abaixo.
		_lret := (_lret .and. U_AD0078(.T.)) //chama programa de validação de alteração de preços, alterado por Adriana em 10/08/2010
		//Endif
	
	EndIf

	// Ricardo Lima - 02/02/18
	if !lSfInt .And. Alltrim( FunName() ) = "AD0163"

		IF SELECT("M410LIOK") > 0
			M410LIOK->( DBCLOSEAREA() )
		ENDIF

		cQuery := " SELECT C6_FILIAL, C6_PRODUTO, C6_QTDVEN "  
		cQuery += " FROM "+ RetSqlname("SC6") +" C6 WITH (NOLOCK) "
		cQuery += " WHERE C6_FILIAL = '"+ FwxFilial("SC6") +"' AND C6_NUM = '"+ M->C5_XPDEVOR +"' AND C6_PRODUTO = '"+ aCols[N,_nPosPRO] +"' "
		cQuery += " AND D_E_L_E_T_ = ' ' "	
		//cQuery := ChangeQuery(cQuery)
		TCQUERY cQuery new alias "M410LIOK"

		nQtdori := M410LIOK->C6_QTDVEN

		IF SELECT("M410LIOK") > 0
			M410LIOK->( DBCLOSEAREA() )
		ENDIF

		cQuery := " SELECT C6_FILIAL, C6_PRODUTO, SUM(C6_QTDVEN) C6_QTDVEN "  
		cQuery += " FROM "+ RetSqlName("SC6") +" C6 WITH (NOLOCK) "
		cQuery += " INNER JOIN "+ RetSqlName("SC5") +" C5 WITH (NOLOCK) ON C5_FILIAL=C6_FILIAL AND C5_NUM=C6_NUM AND C5.D_E_L_E_T_= ' ' "
		cQuery += " WHERE C6_FILIAL = '"+ FwxFilial("SC6") +"' AND C6_PRODUTO = '"+ aCols[N,_nPosPRO] +"' AND C5_XPDEVOR = '"+ M->C5_XPDEVOR +"' AND C6.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY C6_FILIAL, C6_PRODUTO "
		//cQuery := ChangeQuery(cQuery)
		TCQUERY cQuery new alias "M410LIOK"

		IF ( M410LIOK->C6_QTDVEN + aCols[N,_nPosQTD] ) > nQtdori
			_lret := .F.
			MsgBox('Ação não Permitida, somando com esse item, a quantidade será maior que o pedido origem.','Devolução - Ocorrencias','Info')
		ENDIF

	endif   

	//INICIO Abel Babini - 22/11/2019 - 040922 || OS 042030 || FISCAL || DEJAIME || 8921 || RE. NF EMITIDAS
	IF _lRet
		If AllTrim(M->C5_TIPO) == "D"
			aAreaSD1 := SD1->( GetArea() )
			cNFOri  := gdFieldGet("C6_NFORI")
			cSerOri := gdFieldGet("C6_SERIORI")
			cItmOri := gdFieldGet("C6_ITEMORI")
			cCodPrd := gdFieldGet("C6_PRODUTO")
			SF4->(DbSetOrder(1))
			If SF4->(DbSeek(xFilial("SF4")+ aCols[N][_nPosTes]))	
				cTesDev := SF4->F4_ESTOQUE
			Endif

			SD1->( dbSetOrder(1) ) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM                                                                                                     
			If SD1->( dbSeek( xFilial("SD1")+cNFOri+cSerOri+M->C5_CLIENTE+M->C5_LOJACLI+cCodPrd+cItmOri) ) 
				if SF4->(DbSeek(xFilial("SF4")+ SD1->D1_TES))	
					cTesEnt := SF4->F4_ESTOQUE
				endif
			ENDIF

			IF cTesEnt <> cTesDev
				_lRet := .f.
				IF lSfInt //Everson - 25/09/2017. Chamado 037261.
					Aadd(aPedidos,{'Erro na Seleção da TES','O Doc. de Entrada estava com o controle de Estoque = "'+cTesEnt+'". O Doc. de Devolução está com uma TES cujo o controle de Estoque está = "'+cTesDev+'". Entre em contato com a área Fiscal.'})
				ELSE
					AVISO('Erro na Seleção da TES','O Doc. de Entrada estava com o controle de Estoque = "'+cTesEnt+'". O Doc. de Devolução está com uma TES cujo o controle de Estoque está = "'+cTesDev+'". Entre em contato com a área Fiscal.',{"OK"})
				ENDIF
			ENDIF
			RestArea( aAreaSD1 ) 
			RestArea( _aAreaSF4 ) 
		ENDIF
	ENDIF
	//FIM Abel Babini - 22/11/2019 - 040922 || OS 042030 || FISCAL || DEJAIME || 8921 || RE. NF EMITIDAS

	Conout( DToC(Date()) + " " + Time() + " M410LIOK >>> FINAL PE" )
Return(_lret)

/*/{Protheus.doc} User Function ChkZCN
	Chamado n. 049708 || OS 051009 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || ADFAT008P
	@type  Function
	@author Fernando Macieira
	@since 17/06/2019
	@version 1
	/*/
Static Function ChkZCN()

	Local lRet     := .t.
	Local cEmpZCN  := GetMV("MV_#ZCNEMP",,"07")
	Local cZCNProd := GetMV("MV_#ZCNCOD",,"384413")
	Local aAreaZCN := ZCN->( GetArea() )
	Local cLoteZCN := ""
	Local cProd    := ""
	
	// Empresas autorizadas
	If cEmpAnt $ cEmpZCN
	
		cProd := AllTrim( gdFieldGet("C6_PRODUTO", n) )
		
		If lRet
			// Lote Recria informado
			cLoteZCN := gdFieldGet("C6_XLOTECC", n)
			If !Empty(cLoteZCN)
	
				ZCN->( dbSetOrder(1) ) // ZCN_FILIAL+ZCN_LOTE                                                                                                                                             
				If ZCN->( dbSeek( FWxFilial("ZCN")+cLoteZCN ) )
				
					If lRet
						// Consisto lote encerrado
						If AllTrim(ZCN->ZCN_STATUS) == "E" 
							lRet := .f.
							IF lSfInt //Everson - 25/09/2017. Chamado 037261.
								Aadd(aPedidos,{"[M410LIOK-ZCN1] - Lote Recria com status Encerrado! Contate a contabilidade..."})
							ELSE
								Alert("[M410LIOK-ZCN1] - Lote Recria com status Encerrado! Contate a contabilidade...")
							ENDIF
						EndIf
					EndIf
					
					// Preencho com o armazem cadastrado na ZCN
					If lRet
						If !Empty(ZCN->ZCN_ARMAZE)
							gdFieldPut("C6_LOCAL", ZCN->ZCN_ARMAZE, n)
						Else
							lRet := .f.
							IF lSfInt //Everson - 25/09/2017. Chamado 037261.
								Aadd(aPedidos,{"[M410LIOK-ZCN2] - Lote recria não possui armazém cadastrado! Contate a contabilidade..."})
							ELSE
								Alert("[M410LIOK-ZCN2] - Lote recria não possui armazém cadastrado! Contate a contabilidade...")
							ENDIF
						EndIf
					EndIf
					
				Else
				
					// Lote informado nao cadastrado na ZCN
					lRet := .f.
					IF lSfInt //Everson - 25/09/2017. Chamado 037261.
						Aadd(aPedidos,{"[M410LIOK-ZCN3] - Lote Recria não cadastrado! Contate a contabilidade..."})
					ELSE
						Alert("[M410LIOK-ZCN3] - Lote Recria não cadastrado! Contate a contabilidade...")
					ENDIF
	
				EndIf
	
			EndIf
			
		EndIf
	
		// Obrigo preenchimento do lote quando produto recria
		If lRet
			cLoteZCN := gdFieldGet("C6_XLOTECC", n)
			If cProd == AllTrim(cZCNProd) .and. Empty(cLoteZCN)
				lRet := .f.
				IF lSfInt
					Aadd(aPedidos,{"[M410LIOK-ZCN4] - Obrigatório o preenchimento do Lote Recria quando informado este produto código " + cProd})
				ELSE
					Alert("[M410LIOK-ZCN4] - Obrigatório o preenchimento do Lote Recria quando informado este produto código " + cProd)
				ENDIF
			EndIf
		EndIf

		// Obrigo preenchimento do armazem quando produto recria
		If lRet
			cArmaz := gdFieldGet("C6_LOCAL", n)
			If cProd == AllTrim(cZCNProd) .and. Empty(cArmaz)
				lRet := .f.
				IF lSfInt
					Aadd(aPedidos,{"[M410LIOK-ZCN5] - Obrigatório o preenchimento do Armazém quando informado este produto código " + cProd})
				ELSE
					Alert("[M410LIOK-ZCN5] - Obrigatório o preenchimento do Armazém quando informado este produto código " + cProd)
				ENDIF
			EndIf
		EndIf

		// Checo armazem informado com o contido no cadastro do lote recria
		If lRet
			cArmaz := gdFieldGet("C6_LOCAL", n)
			ZCN->( dbSetOrder(1) ) // ZCN_FILIAL+ZCN_LOTE                                                                                                                                             
			If ZCN->( dbSeek( FWxFilial("ZCN")+cLoteZCN ) )
				If AllTrim(cArmaz) <> AllTrim(ZCN->ZCN_ARMAZE)
					lRet := .f.
					IF lSfInt
						Aadd(aPedidos,{"[M410LIOK-ZCN6] - Armazém informado diverge do contido no cadastro de Lote Recria! Contate a contabilidade..."})
					ELSE
						Alert("[M410LIOK-ZCN6] - Armazém informado diverge do contido no cadastro de Lote Recria! Contate a contabilidade...")
					ENDIF
				EndIf
			EndIf
		EndIf
	
	EndIf
	
	RestArea( aAreaZCN )

Return lRet

/*/{Protheus.doc} User Function UpShelfLife
	Chamado n. 051559 || OS 053110 || TECNOLOGIA || FERNANDO_SIGOLI || 8451 || SHELFLIFE - fwnm - 16/09/2019
	@type  Function
	@author Fernando Macieira
	@since 16/09/2019
	@version 1
	/*/
Static Function UpShelfLife()

	Local nShelf   	:= 0
	Local cProduto 	:= ""
	Local aAreaAtu 	:= GetArea()
	Local aAreaZFR 	:= ZFR->( GetArea() )
	Local aAreaZFS 	:= ZFS->( GetArea() )
	Local aAreaSB1 	:= SB1->( GetArea() )
	Local nTotGrd	:= Len(aCols)
	Local i			:= 1

	For i:=1 to nTotGrd
		If !gdDeleted(i)
			If SC6->(FieldPos("C6_XSHELF")) > 0
				cProduto := gdFieldGet("C6_PRODUTO", i)
				SB1->( dbSetOrder(1) ) // B1_FILIAL + B1_COD
				If SB1->( dbSeek( FWxFilial("SB1")+cProduto ) )
					// Cab Shelf
					ZFR->( dbSetOrder(2) ) // ZFR_FILIAL+ZFR_CLICOD+ZFR_CLILOJ
					If ZFR->( dbSeek( FWxFilial("ZFR")+M->C5_CLIENTE+M->C5_LOJACLI))
						If ZFR->ZFR_MSBLQL<>"1" // Bloqueado
							// Item Shelf
							ZFS->( dbSetOrder(1) ) // ZFS_FILIAL+ZFS_CODIGO+ZFS_XCATEG+ZFS_XPREPA                                                                                                          
							If ZFS->( dbSeek( FWxFilial("ZFS")+ZFR->ZFR_CODIGO+SB1->B1_XCATEG+SB1->B1_XPREPAR ) )
								nShelf := ZFS->ZFS_PERCEN
							EndIf
						EndIf
					EndIf
				EndIf
				gdFieldPut("C6_XSHELF", nShelf, i)
			EndIf
		EndIf
	Next i

	RestArea( aAreaZFR )
	RestArea( aAreaZFS )
	RestArea( aAreaSB1 )
	RestArea( aAreaAtu )
	
Return
