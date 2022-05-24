#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#include "protheus.ch"

/*/{Protheus.doc} User Function MT410TOK
	P.E. na confirmacao dos PVs para validar os parametros ZZ_LIMITPV e ZZ_AUTORPV
	@type  Function
	@author Vogas Junior
	@since 21/05/09
	@version 01
	@history Chamado TI 	  - MauricioHC		   -   		      - Alterado para tratar TES de Subst. Trib. para MG e RS 
	@history Ticket 047354 	- Ricardo Lima 		   - 19/02/2019 - NAO PERMITE MAIS DE 1 PEDIDO COM MESMO ROTEIRO E DATA DE ENTREGA
	@history Ticket 047506 	- Ricardo Lima 		   - 27/02/2019 - Informa novo Roteiro
	@history Ticket 048015 	- Fernando Sigoli  	   - 21/03/2019 - Informa novo Roteiro nao validar,pedidos integrador pelo sag 
	@history Ticket 047506 	- William Costa 	   - 21/06/2019 - Validaï¿½ï¿½o Adicionado regra para nï¿½o deixar salvar o pedido se nï¿½o tiver a segunda unidade de medida preenchida se for P.A e o Local igual 10     	@history Ticket 051864 	- Abel Babini 	- 20/09/2019 - Cria parametros de produtos CMS e validaï¿½ï¿½o de quantidade 
	@history Ticket 692 	  - Adriana Oliveira   - 03/09/2020 - gravar TES especifico quando cliente estiver enquadrado no regime especial 57608/11 (ZG4_NUMERO<>ï¿½ï¿½)
	@history Ticket 8190 	  - Abel Babini        - 18/01/2021 - Alterar TES para cliente Simples Nacional para produtos carne 
	@history Ticket 8190 	  - Abel Babini        - 19/01/2021 - Ajuste na regra para atualizar o produto dentro do Laï¿½o FOR
	@history Ticket 8569 	  - Abel Babini        - 25/01/2021 - Acrescentado tratamento para somente Operï¿½ï¿½es 01 e 02 Venda tratarem a mudanï¿½a de TES para Clientes Simples Nacional
	@history Ticket 9231 	  - Abel Babini        - 08/02/2021 - Alterado o tratamento de Bonificaï¿½ï¿½o para clientes Simples Nacional, considerando os parï¿½metros MV_XTESBON, MV_XTESBOQ, MV_XTESDOA
	@history Ticket 9765 	  - Abel Babini        - 19/02/2021 - Adicionada regra para que a alteraï¿½ï¿½o de TES nï¿½o seja executada quando o tipo do cliente for consumidor final
	@history Ticket 11223   - Abel Babini      	   - 23/03/2021 - Nï¿½o mais alterar a TES para clientes Simples Nacional a partir de 01/04/2021
	@history Ticket  63537  - Leonardo P. Monteiro - 10/11/2021 - Correï¿½ï¿½o na gravaï¿½ï¿½o dos roteiros na SC5, SC6 e SC9.
	@history Ticket  63807  - Leonardo P. Monteiro - 17/11/2021 - Inï¿½cio da estruturaï¿½ï¿½o das validaï¿½ï¿½es em funï¿½ï¿½es.
	@history Ticket  63807  - Leonardo P. Monteiro - 17/11/2021 - Validaï¿½ï¿½o do item que controla endereï¿½o para tornar obrigatï¿½rio o preenchimento do campo 'Localizaï¿½ï¿½o'.
	@history Ticket  63807  - Leonardo P. Monteiro - 17/11/2021 - Preenchimento do endereï¿½amento dos produtos que controlam localizaï¿½ï¿½o.
	@history Ticket  63807  - Leonardo P. Monteiro - 18/11/2021 - Aguardo verificaï¿½ï¿½o se o ponto de entrada interferiu na integraï¿½ï¿½o com SalesForce.
	@history Ticket  64569  - Leonardo P. Monteiro - 03/12/2021 - Preenchimento automï¿½tico da localizaï¿½ï¿½o.
	@history Ticket  67573  - Everson 			   - 03/02/2022 - Validaï¿½ï¿½o de quantidade liberada para cï¿½pia de pedido.
	@history Ticket  67573  - Everson 			   - 07/02/2022 - Validaï¿½ï¿½o de quantidade liberada para cï¿½pia de pedido. 
	@history Ticket  TI     - Leonardo P. Monteiro - 26/02/2022 - Inclusï¿½o de conouts no fonte. 
	@history Ticket 69574   - Abel Babini      - 21/03/2022 - Projeto FAI
	@history Ticket  18465  - Everson 			   - 24/03/2022 - Validação de pedido com pesagem já iniciada.. 
	@history Ticket  TI     - Everson 			   - 20/04/2022 - Tratamento para pedidos gerados pela integração com o módulo de exportação.
/*/

User Function MT410TOK()

	Local nLimite       := GetMV("ZZ_LIMITPV")
	Local cUsuVal	    := GetMV("ZZ_AUTORPV")
	Local nTotPV	    := fTotPV()
	Local aArea		    := Getarea()
	Local nProd	        := aScan(aHeader, {|x| ALLTRIM(x[2]) == "C6_PRODUTO" })
	Local nSegUM        := aScan(aHeader, {|x| ALLTRIM(x[2]) == "C6_SEGUM" })
	Local nTES	        := aScan(aHeader, {|x| ALLTRIM(x[2]) == "C6_TES" })
	Local cUF	        := ""
	Local _LCOPIA       := If(valtype(VAR_IXB)="A",If(VAR_IXB[1]="COPIA_PV",.T.,.F.),.F.) //VERIFICA SE E COPIA, VARIAVEL PUBLICA VAR_IXB, ALIMENTADA NO PONTO DE ENTRADA MT410CPY
	Local _cUSUCOPIA	:= GetMv( "MV_#USUCOP" , .F. , "000000" )  //Usuarios da Logistica - somente neste caso valida a data
	Local _lUSUCOPIA	:= (Alltrim(__CUSERID) $ _cUSUCOPIA) //Usuario pertence a logistica e pode utilizar copia.
	Local _nDIACOPIA    := GetMv( "MV_#DIACOP" , .F. , 0 )  //LIMITE DE DIAS (QUANTIDADE) PARA COPIA DOS PEDIDOS COM PRECO ABAIXO DA TABELA DE PRECOS
	Local _dDATAANT     := If(valtype(VAR_IXB)="A",If(VAR_IXB[1]="COPIA_PV",VAR_IXB[2],ddatabase),ddatabase)  //DATA DE ENTREGA DO PEDIDO ORIGINAL PASSADO NO PONTO DE ENTRADA MT410CPY
	Local _dData		:= If(dow(_dDataAnt+_nDiaCopia)=1,_dDataAnt+_nDiaCopia+1,If(dow(_dDataAnt+_nDiaCopia)=7,_dDataAnt+_nDiaCopia+2,_dDataAnt+_nDiaCopia))
	Local _NPOSPRCVEN   := ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_PRCVEN" } )
	Local _NPOSDTENTR   := ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_ENTREG" } )
	Local _CTABELA      := M->C5_TABELA
	Local _dDTENTR      := M->C5_DTENTR
	Local _cEstCli      := M->C5_EST
	Local _cPermAlt     := ""
	Local _cNumPed      := M->C5_NUM         //Mauricio 05/02/14 - Solicitado por Ana Barreta para nï¿½o permitir alterar data de entrega de PV com C5_XINT = "3"
	Local _lRetUsuC     := .F.
	//Local _nDiasDtE     := IF(IsInCallStack('U_ADVEN002P') == .T.,5,GetMV("MV_XDIASEN")) //Chamado se vier do Edi vira 5 - William Costa //GetMV("MV_XDIASEN") //Mauricio 14/06/11 - Solicitado por vagner email de 13/06/11 - Nova Tabela de Preï¿½o.

	Local _nDiasDtE     := IF(IsInCallStack('U_ADVEN002P') == .T.,5, diasEntrega() ) //Everson - 19/12/2017. Chamado 037426.
	
	Local _T1			:= 0
	//Local _nPosItem     := ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_ITEM" } )
	Local _PRECO		:= ""
	
	Local nUNSVEN       := aScan(aHeader, {|x| ALLTRIM(x[2]) == "C6_UNSVEN" })
	Local _nPCLAS       := aScan(aHeader, {|x| ALLTRIM(x[2]) == "C6_CLASFIS" } )
	Local _nPCF         := aScan(aHeader, {|x| ALLTRIM(x[2]) == "C6_CF" } )
	Local nQTDVEN       := aScan(aHeader, {|x| ALLTRIM(x[2]) == "C6_QTDVEN" })
	Local _nPosVend  	:= ASCAN(aHeader, {|x| ALLTRIM(x[2]) =="C6_VEND"  })   	//incluido por Adriana
	Local _nPosRote  	:= ASCAN(aHeader, {|x| ALLTRIM(x[2]) =="C6_ROTEIRO"  })   	//incluido por Adriana
	
	Local nX
	Local nPDel 		:= Len(aCols[1])
	//Local lRet  		:= .T.
	Local cLendo		:= ""
	Local cTipo 		:= ""
	
	Local n2,_x2
	Local _lConsFinal	:= .F.
	Local _nOpc 		:= paramixb[1]
	Local cRedeOP		:= GetMV("MV_#REDEOP") //Redes as quais ï¿½ obrigatorio preencher Operador Logistico, ou Filial, e numero do pedido do cliente, em nosso Pedido de Venda (SAPORE / MASSIMA)- por Adriana chamado 031238 em novembro/2016
	Local _CFST 		:= GetMV("MV_XCFST") //CFOP Venda de embutidos com ICMS ST    5401/5910/5118   - incluido por Adriana em 12/04/2017 - chamado 034546
	Local cCodTes       := "" // sigoli 09/03/2017
	Local cCodProd      := "" // sigoli 09/03/2017
	Local cRetPedi      := "" // sigoli 09/03/2017
	Local cFlag         := "" // sigoli 09/03/2017
	Local _nTotIt 	  	:= Ascan( aHeader,{ |x| AllTrim(x[2]) == "C6_VALOR"})
	Local _nTotValor	:= 0
	Local _PedRefDe     := M->C5_XREFATD   //Mauricio - Chamado 037330
	Local lPedVali      := .T.
	
	Local nTpOpC6	    := aScan(aHeader, {|x| ALLTRIM(x[2]) == "C6_XOPSF" })	
	Local cTpCliSF		:= ""	
	//Ricardo Lima-19/02/2019-047354
	Local cQueryP       := ""
	
	//051864 - Abel Babini-20/09/2019, Cria parametros de produtos CMS e validaï¿½ï¿½o de quantidade
	Local nQtdPlt		:= 0
	Local cGrpPCMS		:= GETMV("MV_#GRPCMS",,"0341,0342,0343,0344,0345,0346,0347,0361,0362,0363,0371") //Grupo dos produtos CMS

	//Ticket 692 por Adriana Oliveira em 03/09/2020
	Local _cN57608		:= U_TrazN57608(M->C5_CLIENTE, M->C5_LOJACLI, M->C5_DTENTR) 
	Local _cTES57608	:= GETMV("MV_#T57608",,"998")
	//

	//Ticket 8190 	  - Abel Babini      - 18/01/2021 - Alterar TES para cliente Simples Nacional para produtos carne 
	//Local _cT65255	:= GETMV("MV_#T65255",,"985") //Qual TES deve ser utilizada para clientes Optantes pelo Simples nacional de SP
	//Local _cCliTrb := ''
	//Local _cDPr65255	:= 'N'

	//Ticket 8569 	  - Abel Babini      - 25/01/2021 - Acrescentado tratamento para somente Operï¿½ï¿½es 01 e 02 Venda tratarem a mudanï¿½a de TES para Clientes Simples Nacional
	//Local _cMT410A		:= GETMV("MV_#MT410A",,"01,") //Quais operacoes devem trocar a TES quando o cliente for de SP e Optante pelo Simples nacional. Ver MV_#T65255
	
	Local nT			:= 0
	Local nTotIt2		:= 0

	Local _nz			:= 0
	Local _nCompRF		:= 0

	//Everson - 07/02/2022. Chamado 67573.
	Local nTemQt		:= 0
	Local nNTemQt		:= 0
	//
	Local cFilSF:= GetMv("MV_#SFFIL",,"02|0B|") //Ticket 69574   - Abel Bab - 21/03/2022 - Projeto FAI
	Local cEmpSF:= GetMv("MV_#SFEMP",,"01|") //Ticket 69574   - Abel Bab - 21/03/2022 - Projeto FAI
  Local cEmpRN:= GetMv("MV_#RNEMP",,"01|02|") //Ticket 69574   - Abel Bab - 21/03/2022 - Projeto FAI
	Local cFilRN:= GetMv("MV_#RNFIL",,"02|06|07|0B") //Ticket 69574   - Abel Bab - 21/03/2022 - Projeto FAI

	Private cLido 		:= ""
	Private nCount 		:= 0
	Private lRet		:= .T.
	Private _cPedAnt    := ""
	Private _cPedold    := ""
	Private nTotItem	:= 0
	Private _x1			:= 0
	Private nCols		:= 0
	Private _cProduto	:= ""
	Private _cLocPad	:= ""
	Private _cLocaliz	:= ""
	Private _cTes		:= ""
	Private _cUM		:= ""
	Private _cSEGUM		:= ""
	Private nUM	        := aScan(aHeader, {|x| ALLTRIM(x[2]) == "C6_UM" })
	Private _nLocaliz	:= ASCAN(aHeader, {|x| ALLTRIM(x[2]) =="C6_LOCALIZ"  })
	Private _nLocal		:= ASCAN(aHeader, {|x| ALLTRIM(x[2]) =="C6_LOCAL"  })
	
	Private lSfInt	:= (IsInCallStack('U_RESTEXECUTE') .OR. IsInCallStack('RESTEXECUTE'))

	//Conout( DToC(Date()) + " " + Time() + " MT410TOK >>> INICIO PE" )
	
	//Everson - 24/03/2022. Chamado 018465. Pesagem.
	If !IsInCallStack('U_RESTEXECUTE') .And. ! IsInCallStack('RESTEXECUTE') .And. ALTERA .And. ! StaticCall(A410EXC, vldOrdSa, SC5->C5_NUM)
		RestArea(aArea)
		Return .F.

	EndIf 
	//

	_cTipoOper 			:= "02" // por Adriana em 24/03/17
	_cTipoCli 			:= M->C5_TIPOCLI //" "  // por Adriana em 05/04/17
	cTpCliSF			:= M->C5_TIPOCLI // Everson - 02/04/2018.

	// Consulta tipo cliente do cadastro de clientes       //quando venda - acrescentado por Adriana em 07/04/2017
	if M->C5_TIPO = "N"
		cQuery :="SELECT A1_TIPO, A1_SIMPNAC "
		cQuery +="FROM  "+RetSqlName("SA1")+ " WITH (NOLOCK)  "
		cQuery +="WHERE "
		cQuery +=" A1_COD = '"+M->C5_CLIENTE+"' AND A1_LOJA = '"+M->C5_LOJACLI+"' "
		cQuery +=" AND D_E_L_E_T_ = '' "
		TCQUERY cQuery new alias "REGI"
		dbSelectArea ("REGI")
		DbGoTop()
		_cTipoCli 			:= REGI->A1_TIPO
		cTpCliSF			:= REGI->A1_TIPO

		//_cCliTrb	:= REGI->A1_SIMPNAC //Ticket 8190 	  - Abel Babini      - 18/01/2021 - Alterar TES para cliente Simples Nacional para produtos carne 

		dbCloseArea("REGI")
	Endif
	//

	if _nOpc = 1 // Exclusï¿½o
		//Conout( DToC(Date()) + " " + Time() + " MT410TOK >>> FINAL PE" )
		return .t.
	endif

	//****************INICIO PARA CARREGAR VALOR NO CAMPO C5_XTOTPED DE ACORDO O CHAMADO N. 021608**************/
	//M->C5_XTOTPED := nTotPV    //Desabilitado pois estava gravando valor incorreto no campo - por Adriana em 12/04/2017 - chamado 034578
	//****************FINAL PARA CARREGAR VALOR NO CAMPO C5_XTOTPED DE ACORDO O CHAMADO N. 021608**************/

	//Soma Valor Total dos Itens - incluido por Adriana em 12/04/2017 - chamado 034578
	nTotIt2	:= Len(aCols)

	For nT := 1 to nTotIt2

		If aCols[nT,Len(aHeader)+1] == .F.
			_nTotValor += aCols[nT,_nTotIt]
		EndIf

	Next nT
	M->C5_XTOTPED := _nTotValor
	//

	If Alltrim(cEmpAnt) $ cEmpSF
		_cPermAlt     := M->C5_XINT        //Mauricio 05/02/14 - Solicitado por Ana Barreta para não permitir alterar data de entrega de PV com C5_XINT = "3"
	Else
		_cPermAlt     := ""
	Endif
	
	//Mauricio - 06/10/2017 - Chamado 037330
	//Inicio
	if !lSfInt .And. Alltrim(cEmpAnt) $ cEmpRN .AND. (INCLUI .OR. ALTERA)
		_cPedAt   := _cNumPed
		_lrfat    := .F.
		_lTresPed := .F.
		_lquatro  := .F.
		IF M->C5_REFATUR <> "S"  //Inclusao do pedido pelo comercial pois nunca ï¿½ o comercial que preenche esse campo
			IF INCLUI
				_lTresPed := .F.
				_lrfat := .F.
				_lquatro := .F.
				If !Empty(_PedRefDe)     //campo de pedido original do refaturamento

					//verifico se o pedido pode ser refatura, seguindo as regras do parametrO de minimo de caixas e estado
					lPedVali := ValQtdEst(_PedRefDe)

					If !lPedVali

						IF IsInCallStack('U_ADVEN002P')  == .T.
							Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							'Atencï¿½o!! Pedido Original do refaturamento '+_PedRefDe+' nao esta liberado para refaturamento devido a quantidade de caixas menor que '+cvaltochar(GetMV("MV_#QTDREF"))+' caixas. Verifique!!' ,;
							cVendedor})
						ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
							Aadd(aPedidos,{'Atencï¿½o!! Pedido Original do refaturamento '+_PedRefDe+' nao esta liberado para refaturamento devido a quantidade de caixas menor que '+cvaltochar(GetMV("MV_#QTDREF"))+' caixas. Verifique!!'})

						ELSE
							ApMsgInfo(OemToAnsi('Atencï¿½o!! Pedido Original do refaturamento '+_PedRefDe+' nao esta liberado para refaturamento devido a quantidade de caixas menor que '+cvaltochar(GetMV("MV_#QTDREF"))+' caixas. Verifique!!'))
						Endif
						lRet := .F.
					EndIf

					_cPedExist := fverped(_PedRefDe) //verificar se o pedido ja foi usado

					If Empty(_cPedExist) .Or. _cPedExist == M->C5_NUM
						IF IsInCallStack('U_ADVEN002P')  == .T.
							Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							'Atencï¿½o!! Pedido Original do refaturamento '+_PedRefDe+' nï¿½o encontrado ou incorreto. Verifique!!' ,;
							cVendedor})
						ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
							Aadd(aPedidos,{'Atencï¿½o!! Pedido Original do refaturamento '+_PedRefDe+' nï¿½o encontrado ou incorreto. Verifique!!'})
						ELSE
							ApMsgInfo(OemToAnsi('Atencï¿½o!! Pedido Original do refaturamento '+_PedRefDe+' nï¿½o encontrado ou incorreto. Verifique!!'))
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

					fbscPed(_PedRefDe,.F.)

					//Valido a quantidade... valor nao posso validar aqui pois este somente sera validado na alteracao do campo
					//C5_REFATUR quando todos os pedidos de venda a serem refaturados foram incluidos pelo comercial.
					If (_nTQTPDAC + _nTQTPDATU)  > _nTQTPDOR   //quantidade do pedido atual ja eh maior que a qt
						//If (_nTQTPDAC )  > _nTQTPDOR   //quantidade do pedido atual ja eh maior que a qt			
						IF IsInCallStack('U_ADVEN002P')  == .T.
							Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							'Refaturamento!! A quantidade no(s) pedido(s)'+_cPDFATS +'ï¿½ maior do que no pedido original '+_PedRefDe+'. Verifique!!' ,;
							cVendedor})
						ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
							Aadd(aPedidos,{'Refaturamento!! A quantidade no(s) pedido(s)'+_cPDFATS +'ï¿½ maior do que no pedido original '+_PedRefDe+'. Verifique!!'})
						ELSE
							ApMsgInfo(OemToAnsi('Refaturamento!! A quantidade no(s) pedido(s)'+_cPDFATS +'ï¿½ maior do que no pedido original '+_PedRefDe+'. Verifique!!'))
						Endif
						lRet := .F.
					Endif

					If _lQuatro   //ja existem 3 pedidos vinculados					
						IF IsInCallStack('U_ADVEN002P')  == .T.
							Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							'Refaturamento!! Ja existem o maximo de 3 pedidos vinculados ao pedido original '+_PedRefDe+'. Verifique!!' ,;
							cVendedor})
						ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
							Aadd(aPedidos,{'Refaturamento!! Ja existem o maximo de 3 pedidos vinculados ao pedido original '+_PedRefDe+'. Verifique!!'})
						ELSE
							ApMsgInfo(OemToAnsi('Refaturamento!! Ja existem o maximo de 3 pedidos vinculados ao pedido original '+_PedRefDe+'. Verifique!!'))
						Endif
						lRet := .F.
					Endif

					//20/10/2017 - incluindo validaï¿½ï¿½o de produto e quantidade
					If _lTresPed   //Ja foram colocados os 3 pedidos do comercial, validacao completa
						//valido produtos e quantidades

						_nCompRF := Len(_aCompRF)

						For _nz := 1 to _nCompRF  //refaturados
							_nAscan := Ascan( _aCompOR, { |x|x[ 01 ] == _aCompRF[_nz][1] } )
							If _nAscan <= 00    //produto nï¿½o existe no pedido original
								IF IsInCallStack('U_ADVEN002P')  == .T.
									Aadd(aPedidos,{cchave, ;
									''    , ;
									''    , ;
									''    , ;
									'Refaturamento!! O produto'+_aCompRF[_nz][1] +'nï¿½o existe no pedido original '+_PedRefDe+'. Verifique!!' ,;
									cVendedor})
								ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
									Aadd(aPedidos,{'Refaturamento!! O produto'+_aCompRF[_nz][1] +'nï¿½o existe no pedido original '+_PedRefDe+'. Verifique!!'})
								ELSE
									ApMsgInfo(OemToAnsi('Refaturamento!! O produto'+_aCompRF[_nz][1] +'nï¿½o existe no pedido original '+_PedRefDe+'. Verifique!!'))
								Endif
								lRet := .F.
							Else
								IF _aCompOR[_nAscan][2] <> _aCompRF[_nz][2]  //como ï¿½ terceiro pedido a quantidade precisa bater
									IF IsInCallStack('U_ADVEN002P')  == .T.
										Aadd(aPedidos,{cchave, ;
										''    , ;
										''    , ;
										''    , ;
										'Refaturamento!! A quantidade do produto'+_aCompRF[_nz][1] +'nï¿½o bate com a quantidade no pedido original '+_PedRefDe+'. Verifique!!' ,;
										cVendedor})
									ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
										Aadd(aPedidos,{'Refaturamento!! A quantidade do produto'+_aCompRF[_nz][1] +'nï¿½o bate com a quantidade no pedido original '+_PedRefDe+'. Verifique!!'})
									ELSE
										ApMsgInfo(OemToAnsi('Refaturamento!! A quantidade do produto'+_aCompRF[_nz][1] +'nï¿½o bate com a quantidade no pedido original '+_PedRefDe+'. Verifique!!'))
									Endif
									lRet := .F.				       
								Endif
							Endif
						Next _nZ

					else  //naï¿½ foram colocados 3 pedidos do comercial, validaï¿½ï¿½o parcial.
						//valido produtos e quantidades a maior
						For _nz := 1 to len(_aCompRF)  //refaturados
							_nAscan := Ascan( _aCompOR, { |x|x[ 01 ] == _aCompRF[_nz][1] } )
							If _nAscan <= 00    //produto nï¿½o existe no pedido original
								IF IsInCallStack('U_ADVEN002P')  == .T.
									Aadd(aPedidos,{cchave, ;
									''    , ;
									''    , ;
									''    , ;
									'Refaturamento!! O produto'+_aCompRF[_nz][1] +'nï¿½o existe no pedido original '+_PedRefDe+'. Verifique!!' ,;
									cVendedor})
								ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
									Aadd(aPedidos,{'Refaturamento!! O produto'+_aCompRF[_nz][1] +'nï¿½o existe no pedido original '+_PedRefDe+'. Verifique!!'})
								ELSE
									ApMsgInfo(OemToAnsi('Refaturamento!! O produto'+_aCompRF[_nz][1] +'nï¿½o existe no pedido original '+_PedRefDe+'. Verifique!!'))
								Endif
								lRet := .F.
							Else
								IF _aCompOR[_nAscan][2] < _aCompRF[_nz][2]  //como nï¿½o eh o terceiro pedido valido quantida a maior somente
									IF IsInCallStack('U_ADVEN002P')  == .T.
										Aadd(aPedidos,{cchave, ;
										''    , ;
										''    , ;
										''    , ;
										'Refaturamento!! A quantidade do produto'+_aCompRF[_nz][1] +'nï¿½o bate com a quantidade no pedido original '+_PedRefDe+'. Verifique!!' ,;
										cVendedor})
									ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
										Aadd(aPedidos,{'Refaturamento!! A quantidade do produto'+_aCompRF[_nz][1] +'nï¿½o bate com a quantidade no pedido original '+_PedRefDe+'. Verifique!!'})
									ELSE
										ApMsgInfo(OemToAnsi('Refaturamento!! A quantidade do produto'+_aCompRF[_nz][1] +'nï¿½o bate com a quantidade no pedido original '+_PedRefDe+'. Verifique!!'))
									Endif
									lRet := .F.				       
								Endif
							Endif
						Next _nZ

					Endif
				Endif
			Else
				//Tratamento alteraï¿½ï¿½o comercial..
				_lrfat := .F.
				_lTresPed := .F.
				//checo se na alteraï¿½ao do pedido, anteriormente havia o campo C5_XREFATD estava preenchido, se estava e o conteudo pode ser diferente do atual, preciso limpar este do campo C5_XPEDGER
				//_lmudou := .F.
				_cPedAnt := bscPedAlt(_cNumPed)

				//If _cPedAnt <> _PedRefDe
				//   _lmudou := .T.
				//Endif

				//If _lmudou  //preciso ir no pedido original e alterar o campo C5_XPEDGER limpando o conteudo original que foi alterado(ou limpo...)
				_cPedold := ""
				DbSelectArea("SC5")
				AltPedOr(_cPedAnt,_cNumPed)
				//Endif

				If !Empty(_PedRefDe)     //campo de pedido original do refaturament

					//verifico se o pedido pode ser refatura, seguindo as regras do parametrO de minimo de caixas e estado
					lPedVali := ValQtdEst(_PedRefDe)

					If !lPedVali

						IF IsInCallStack('U_ADVEN002P')  == .T.
							Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							'Atencï¿½o!! Pedido Original do refaturamento '+_PedRefDe+' nao esta liberado para refaturamento devido a quantidade de caixas menor que '+cvaltochar(GetMV("MV_#QTDREF"))+' caixas. Verifique!!' ,;
							cVendedor})
						ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
							Aadd(aPedidos,{'Atencï¿½o!! Pedido Original do refaturamento '+_PedRefDe+' nao esta liberado para refaturamento devido a quantidade de caixas menor que '+cvaltochar(GetMV("MV_#QTDREF"))+' caixas. Verifique!!'})

						ELSE
							ApMsgInfo(OemToAnsi('Atencï¿½o!! Pedido Original do refaturamento '+_PedRefDe+' nao esta liberado para refaturamento devido a quantidade de caixas menor que '+cvaltochar(GetMV("MV_#QTDREF"))+' caixas. Verifique!!'))
						Endif
						lRet := .F.
					EndIf

					_cPedExist := fverped(_PedRefDe) //verificar se o pedido ja foi usado

					If Empty(_cPedExist) .Or. _cPedExist == M->C5_NUM
						IF IsInCallStack('U_ADVEN002P')  == .T.
							Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							'Atencï¿½o!! Pedido Original do refaturamento '+_PedRefDe+' nï¿½o encontrado ou incorreto. Verifique!!' ,;
							cVendedor})
						ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
							Aadd(aPedidos,{'Atencï¿½o!! Pedido Original do refaturamento '+_PedRefDe+' nï¿½o encontrado ou incorreto. Verifique!!'})
						ELSE
							ApMsgInfo(OemToAnsi('Atencï¿½o!! Pedido Original do refaturamento '+_PedRefDe+' nï¿½o encontrado ou incorreto. Verifique!!'))
						Endif
						lRet := .F.
						//AjsAlt(_cPedAnt,_cPedold)
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

					fbscPed(_PedRefDe,.F.)

					//Valido a quantidade... valor nao posso validar aqui pois este somente sera validado na alteracao do campo
					//C5_REFATUR pelo faturamento, quando todos os pedidos de venda a serem refaturados ja foram incluidos pelo comercial.
					If (_nTQTPDAC + _nTQTPDATU)  > _nTQTPDOR   //quantidade do pedido atual ja eh maior que a qt
						//If (_nTQTPDAC)  > _nTQTPDOR   //quantidade do pedido atual ja eh maior que a qt
						IF IsInCallStack('U_ADVEN002P')  == .T.
							Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							'Refaturamento!! A quantidade no(s) pedido(s)'+_cPDFATS +'ï¿½ maior do que no pedido original '+_PedRefDe+'. Verifique!!' ,;
							cVendedor})
						ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
							Aadd(aPedidos,{'Refaturamento!! A quantidade no(s) pedido(s)'+_cPDFATS +'ï¿½ maior do que no pedido original '+_PedRefDe+'. Verifique!!'})
						ELSE
							ApMsgInfo(OemToAnsi('Refaturamento!! A quantidade no(s) pedido(s)'+_cPDFATS +'ï¿½ maior do que no pedido original '+_PedRefDe+'. Verifique!!'))
						Endif
						lRet := .F.					
					Endif

					//20/10/2017 - incluindo validaï¿½ï¿½o de produto e quantidade
					If _lTresPed   //Ja foram colocados os 3 pedidos do comercial, validacao completa
						//valido produtos e quantidades
						For _nz := 1 to len(_aCompRF)  //refaturados
							_nAscan := Ascan( _aCompOR, { |x|x[ 01 ] == _aCompRF[_nz][1] } )
							If _nAscan <= 00    //produto nï¿½o existe no pedido original
								IF IsInCallStack('U_ADVEN002P')  == .T.
									Aadd(aPedidos,{cchave, ;
									''    , ;
									''    , ;
									''    , ;
									'Refaturamento!! O produto'+_aCompRF[_nz][1] +'nï¿½o existe no pedido original '+_PedRefDe+'. Verifique!!' ,;
									cVendedor})
								ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
									Aadd(aPedidos,{'Refaturamento!! O produto'+_aCompRF[_nz][1] +'nï¿½o existe no pedido original '+_PedRefDe+'. Verifique!!'})
								ELSE
									ApMsgInfo(OemToAnsi('Refaturamento!! O produto'+_aCompRF[_nz][1] +'nï¿½o existe no pedido original '+_PedRefDe+'. Verifique!!'))
								Endif
								lRet := .F.
							Else
								IF _aCompOR[_nAscan][2] <> _aCompRF[_nz][2]  //como ï¿½ terceiro pedido a quantidade precisa bater
									IF IsInCallStack('U_ADVEN002P')  == .T.
										Aadd(aPedidos,{cchave, ;
										''    , ;
										''    , ;
										''    , ;
										'Refaturamento!! A quantidade do produto'+_aCompRF[_nz][1] +'nï¿½o bate com a quantidade no pedido original '+_PedRefDe+'. Verifique!!' ,;
										cVendedor})
									ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
										Aadd(aPedidos,{'Refaturamento!! A quantidade do produto'+_aCompRF[_nz][1] +'nï¿½o bate com a quantidade no pedido original '+_PedRefDe+'. Verifique!!'})
									ELSE
										ApMsgInfo(OemToAnsi('Refaturamento!! A quantidade do produto'+_aCompRF[_nz][1] +'nï¿½o bate com a quantidade no pedido original '+_PedRefDe+'. Verifique!!'))
									Endif
									lRet := .F.				       
								Endif
							Endif
						Next _nZ

					else  //naï¿½ foram colocados 3 pedidos do comercial, validaï¿½ï¿½o parcial.
						//valido produtos e quantidades a maior
						For _nz := 1 to len(_aCompRF)  //refaturados
							_nAscan := Ascan( _aCompOR, { |x|x[ 01 ] == _aCompRF[_nz][1] } )
							If _nAscan <= 00    //produto nï¿½o existe no pedido original
								IF IsInCallStack('U_ADVEN002P')  == .T.
									Aadd(aPedidos,{cchave, ;
									''    , ;
									''    , ;
									''    , ;
									'Refaturamento!! O produto'+_aCompRF[_nz][1] +'nï¿½o existe no pedido original '+_PedRefDe+'. Verifique!!' ,;
									cVendedor})
								ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
									Aadd(aPedidos,{'Refaturamento!! O produto'+_aCompRF[_nz][1] +'nï¿½o existe no pedido original '+_PedRefDe+'. Verifique!!'})
								ELSE
									ApMsgInfo(OemToAnsi('Refaturamento!! O produto'+_aCompRF[_nz][1] +'nï¿½o existe no pedido original '+_PedRefDe+'. Verifique!!'))
								Endif
								lRet := .F.
							Else
								IF _aCompOR[_nAscan][2] < _aCompRF[_nz][2]  //como nï¿½o eh o terceiro pedido valido quantida a maior somente
									IF IsInCallStack('U_ADVEN002P')  == .T.
										Aadd(aPedidos,{cchave, ;
										''    , ;
										''    , ;
										''    , ;
										'Refaturamento!! A quantidade do produto'+_aCompRF[_nz][1] +'nï¿½o bate com a quantidade no pedido original '+_PedRefDe+'. Verifique!!' ,;
										cVendedor})
									ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
										Aadd(aPedidos,{'Refaturamento!! A quantidade do produto'+_aCompRF[_nz][1] +'nï¿½o bate com a quantidade no pedido original '+_PedRefDe+'. Verifique!!'})
									ELSE
										ApMsgInfo(OemToAnsi('Refaturamento!! A quantidade do produto'+_aCompRF[_nz][1] +'nï¿½o bate com a quantidade no pedido original '+_PedRefDe+'. Verifique!!'))
									Endif
									lRet := .F.				       
								Endif
							Endif
						Next _nZ

					Endif

				Endif

			ENDIF
		Else  //eh refaturamento
			_lrfat := .T.
			_lTresPed := .F.
			If !Empty(_PedRefDe)  //pedido original que foi refaturado

				_cPedExist := fverped(_PedRefDe) //verificar se o pedido ja foi usado

				If Empty(_cPedExist) .Or. _cPedExist == M->C5_NUM
					IF IsInCallStack('U_ADVEN002P')  == .T.
						Aadd(aPedidos,{cchave, ;
						''    , ;
						''    , ;
						''    , ;
						'Atencï¿½o!! Pedido Original do refaturamento '+_PedRefDe+' nï¿½o encontrado ou incorreto. Verifique!!' ,;
						cVendedor})
					ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
						Aadd(aPedidos,{'Atencï¿½o!! Pedido Original do refaturamento '+_PedRefDe+' nï¿½o encontrado ou incorreto. Verifique!!'})
					ELSE
						ApMsgInfo(OemToAnsi('Atencï¿½o!! Pedido Original do refaturamento '+_PedRefDe+' nï¿½o encontrado ou incorreto. Verifique!!'))
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

				fbscPed(_PedRefDe,_lrfat)

				//Valido a quantidade...			
				//If _nTQTPDAC > _nTQTPDOR
				If (_nTQTPDAC + _nTQTPDATU) > _nTQTPDOR
					IF IsInCallStack('U_ADVEN002P')  == .T.
						Aadd(aPedidos,{cchave, ;
						''    , ;
						''    , ;
						''    , ;
						'Refaturamento!! A quantidade no(s) pedido(s)'+_cPDFATS +'ï¿½ maior do que no pedido original '+_PedRefDe+'. Verifique!!' ,;
						cVendedor})
					ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
						Aadd(aPedidos,{'Refaturamento!! A quantidade no(s) pedido(s)'+_cPDFATS +'ï¿½ maior do que no pedido original '+_PedRefDe+'. Verifique!!'})
					ELSE
						ApMsgInfo(OemToAnsi('Refaturamento!! A quantidade no(s) pedido(s)'+_cPDFATS +'ï¿½ maior do que no pedido original '+_PedRefDe+'. Verifique!!'))
					Endif
					lRet := .F.
				Endif

				//If _nTQTPDAC < _nTQTPDOR
				If (_nTQTPDAC + _nTQTPDATU) < _nTQTPDOR
					IF IsInCallStack('U_ADVEN002P')  == .T.
						Aadd(aPedidos,{cchave, ;
						''    , ;
						''    , ;
						''    , ;
						'Refaturamento!! A quantidade no(s) pedido(s)'+_cPDFATS +'ï¿½ menor do que no pedido original '+_PedRefDe+'. Verifique!!' ,;
						cVendedor})
					ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
						Aadd(aPedidos,{'Refaturamento!! A quantidade no(s) pedido(s)'+_cPDFATS +'ï¿½ menor do que no pedido original '+_PedRefDe+'. Verifique!!'})
					ELSE
						ApMsgInfo(OemToAnsi('Refaturamento!! A quantidade no(s) pedido(s)'+_cPDFATS +'ï¿½ menor do que no pedido original '+_PedRefDe+'. Verifique!!'))
					Endif
					lRet := .F.
				Endif

				//Valido o valor....maximo de percentual permitido abaixo do valor original vindo de parametro.
				_nValP := GETMV("MV_XPERCRF")			
				//If _nTVLPDAC < (_nTVLPDOR * ((100 - _nValP)/100))
				If (_nTVLPDAC + _nTVLPDATU) < (_nTVLPDOR * ((100 - _nValP)/100))
					IF IsInCallStack('U_ADVEN002P')  == .T.
						Aadd(aPedidos,{cchave, ;
						''    , ;
						''    , ;
						''    , ;
						'Refaturamento!! O valor total no(s) pedido(s)'+_cPDFATS +'ï¿½ menor do que o permitido no refaturamento do '+_PedRefDe+'. Verifique!!' ,;
						cVendedor})
					ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
						Aadd(aPedidos,{'Refaturamento!! O valor total no(s) pedido(s)'+_cPDFATS +'ï¿½ menor do que o permitido no refaturamento do '+_PedRefDe+'. Verifique!!'})
					ELSE
						ApMsgInfo(OemToAnsi('Refaturamento!! O valor total no(s) pedido(s)'+_cPDFATS +'ï¿½ menor do que o permitido no refaturamento do '+_PedRefDe+'. Verifique!!'))
					Endif
					lRet := .F.
				Endif

				/*
				//valido se todos os produtos do pedido original estï¿½o nos pedidos de refaturamento(maximo 3)
				_lErrPrd := .F.
				For _xx := 1 to len(_aProdOR)
				_nAscan := Ascan( _aProdRFT, { |x| x[ 01 ] == _aProdOR[_xx][1] } )

				If _nAscan <= 00
				_lErrPrd := .T.
				EndIf
				next _xx

				If _lErrPrd
				IF IsInCallStack('U_ADVEN002P')  == .T.
				Aadd(aPedidos,{cchave, ;
				''    , ;
				''    , ;
				''    , ;
				'Refaturamento!! Ha produtos do pedido original que nï¿½o constam nos pedidos de refaturamento. Verifique!!' ,;
				cVendedor})
				ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
				Aadd(aPedidos,{'Refaturamento!! Ha produtos do pedido original que nï¿½o constam nos pedidos de refaturamento. Verifique!!'})
				ELSE
				ApMsgInfo(OemToAnsi('Refaturamento!! Ha produtos do pedido original que nï¿½o constam nos pedidos de refaturamento. Verifique!!'))
				Endif
				lRet := .F.
				Endif
				*/
				//20/10/2017 - incluindo validaï¿½ï¿½o de produto e quantidade
				//Quando muda o refaturamento o numero maximo de pedidos(3)ja  foram colocados, validacao completa
				//valido produtos e quantidades
				For _nz := 1 to len(_aCompRF)  //refaturados
					_nAscan := Ascan( _aCompOR, { |x|x[ 01 ] == _aCompRF[_nz][1] } )
					If _nAscan <= 00    //produto nï¿½o existe no pedido original
						IF IsInCallStack('U_ADVEN002P')  == .T.
							Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							'Refaturamento!! O produto'+_aCompRF[_nz][1] +'nï¿½o existe no pedido original '+_PedRefDe+'. Verifique!!' ,;
							cVendedor})
						ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
							Aadd(aPedidos,{'Refaturamento!! O produto'+_aCompRF[_nz][1] +'nï¿½o existe no pedido original '+_PedRefDe+'. Verifique!!'})
						ELSE
							ApMsgInfo(OemToAnsi('Refaturamento!! O produto'+_aCompRF[_nz][1] +'nï¿½o existe no pedido original '+_PedRefDe+'. Verifique!!'))
						Endif
						lRet := .F.
					Else
						IF _aCompOR[_nAscan][2] <> _aCompRF[_nz][2]  //como ï¿½ terceiro pedido a quantidade precisa bater
							IF IsInCallStack('U_ADVEN002P')  == .T.
								Aadd(aPedidos,{cchave, ;
								''    , ;
								''    , ;
								''    , ;
								'Refaturamento!! A quantidade do produto'+_aCompRF[_nz][1] +'nï¿½o bate com a quantidade no pedido original '+_PedRefDe+'. Verifique!!' ,;
								cVendedor})
							ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
								Aadd(aPedidos,{'Refaturamento!! A quantidade do produto'+_aCompRF[_nz][1] +'nï¿½o bate com a quantidade no pedido original '+_PedRefDe+'. Verifique!!'})
							ELSE
								ApMsgInfo(OemToAnsi('Refaturamento!! A quantidade do produto'+_aCompRF[_nz][1] +'nï¿½o bate com a quantidade no pedido original '+_PedRefDe+'. Verifique!!'))
							Endif
							lRet := .F.				       
						Endif
					Endif
				Next _nZ																			
			Endif		
		Endif
	Endif
	//Fim 037330
	
	nTotItem	:= Len(aCols)

	//Inicio - Sigoli 10/03/2017 Chamado: 034029
	If !lSfInt .And. Alltrim(cEmpAnt) $ cEmpSF .And. Alltrim(cFilAnt) $ cFilSF
		If nTotItem > 0
			For _T1 := 1 to nTotItem

				If aCols[_T1,Len(aHeader)+1] == .F. .and. lRet == .T.
				
					cCodTes  := ACOLS[_T1,nTES]
					cCodProd := ACOLS[_T1,nProd]

					If Empty(M->C5_XPEDORD) .and. Alltrim(cCodProd) $ GETMV("MV_PRDREAL") .and. Alltrim(cCodTes) $ GETMV("MV_TESREM")

						ApMsgInfo(OemToAnsi("Atencï¿½o!! Para pedidos de remessa com as TES de venda ï¿½ ordem, ï¿½ obrigatï¿½rio informar o nï¿½mero do pedido. Verifique!!"))
						lRet := .F.

					ElseIf Empty(M->C5_XPEDORD) .and. Alltrim(cCodTes) $ GETMV("MV_TESREM") .and. Empty(cFlag)

						If ApMsgYesNo(OemToAnsi("Para pedidos de remessa com as TES de venda ï¿½ ordem, o sistema disponibiliza a amarraï¿½ï¿½o entre eles atraves do campo 'Pedido Venda ï¿½ ordem." + Chr(13) + Chr(13) + "Deseja Informar ?"),OemToAnsi("A T E N ï¿½ ï¿½ O"))
							lRet := .F.
						Else
							lRet := .T.
						EndIF
						cFlag := lRet
					Else

						//If !Empty(M->C5_XPEDORD) .and. (!Alltrim(cCodProd) $ GETMV("MV_PRDREAL") .or. !Alltrim(cCodTes) $ GETMV("MV_TESREM"))
						If !Empty(M->C5_XPEDORD) .and. !Alltrim(cCodTes) $ GETMV("MV_TESREM")

							ApMsgInfo(OemToAnsi("Atencï¿½o!! Para pedidos de remessa com as TES sem vinculo de venda ï¿½ ordem, ï¿½ obrigatï¿½rio deixar em branco nï¿½mero do pedido de venda. Verifique!!"))
							lRet := .F.

						Elseif !Empty(M->C5_XPEDORD)

							DbSelectArea("SC5")
							nOrden = IndexOrd()  //GUARDO A ORDEM DO INDICE - Chamado: 036307 - 17/07/2017 - fernando sigoli
							nRecno := Recno()

							If dbseek(xFilial("SC5")+M->C5_XPEDORD)

								If !Empty(SC5->C5_NOTA)
									ApMsgInfo(OemToAnsi("Atencï¿½o!! Pedido "+M->C5_XPEDORD+" informado, encontra-se faturado. Verifique!!"))
									lRet := .F.
								EndIf

								cRetPedi := verificarpedido(M->C5_XPEDORD) //verificar se o pedido ja foi usado

								If !Empty(cRetPedi) .and. cRetPedi <> M->C5_NUM
									ApMsgInfo(OemToAnsi("Atencï¿½o!! Pedido "+M->C5_XPEDORD+" ja utilizado no Pedido de Remessa '"+cRetPedi+"'. Verifique!!"))
									lRet := .F.
								EndIf

								DbSelectArea("SC6")
								If dbSeek( xFilial("SC6")+M->C5_XPEDORD)
									Do While !Eof() .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM =M->C5_XPEDORD	.and. lRet == .T.
										If Alltrim(SC6->C6_TES) $ GETMV("MV_TESVORD")
											lRet := .T.
										Else
											ApMsgInfo(OemToAnsi("Atencï¿½o!! Pedido "+M->C5_XPEDORD+" informado, nï¿½o refere-se a pedido de venda ï¿½ ordem. Verifique!!"))
											lRet := .F.
										EndIf
										SC6->(DBSKIP())
									Enddo
								Endif

							Else
								MsgAlert("Pedido "+M->C5_XPEDORD+" de de venda ï¿½ ordem informado, nï¿½o localizado!","Atenï¿½ï¿½o")
								lRet := .F.
							EndIf

							DbSelectArea("SC5")
							DbSetOrder(nOrden)  //RETORNO A ORDEM // chamado: 036307 - 17/07/2017 - fernando sigoli
							DbGoto(nRecno)

						EndIf
					EndIf
				EndIf

			Next _T1
		EndIf
	EndIF
	//Fim - Sigoli 10/03/2017 Chamado: 034029

	// Incluido por Adriana em 11/10/2016 para nao permitir cliente de entrega diferente, pois gera divergencia na DANFE - chamado 030844
	// If M->C5_CLIENTE <> M->C5_CLIENT .and. .not. Empty(M->C5_CLIENT)
	If M->C5_CLIENTE <> M->C5_CLIENT //.and. .not. Empty(M->C5_CLIENT) //retirado por Adriana chamado 035864 - em 26/06/2017
		IF IsInCallStack('U_ADVEN002P')  == .T.
			Aadd(aPedidos,{cchave, ;
			''    , ;
			''    , ;
			''    , ;
			'Atencao !! Cliente de entrega divergente ' + M->C5_CLIENT + '. Verifique!!' ,;
			cVendedor})

		ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
			Aadd(aPedidos,{'Atencao !! Cliente de entrega divergente ' + M->C5_CLIENT + '. Verifique!!'})

		ELSE

			ApMsgInfo(OemToAnsi("Atencao !! Cliente de entrega divergente " + M->C5_CLIENT + ". Confirme o codigo do Cliente!!"))

		ENDIF
		lRet := .F.
	EndIf
	//

	If !lSfInt .And. Alltrim(cEmpAnt) $ cEmpSF .AND. Alltrim(cFilAnt) $ cFilRN  // executar somente para empresa Adoro filial Varzea Paulista.  //incluida filial 07 em 13/08/14
		// Mauricio 14/08/15 - tratamento para que pedidos de venda FOB
		// nao entrem na validaï¿½ï¿½o de pedido minimo.
		If M->C5_TIPO == 'N' .AND. M->C5_TPFRETE <> "F"  // somente para pedido de venda

			If !Alltrim(Upper(__cUserID)) $ cUsuVal //Alterado por Wesley 07/07/16, de nome de usuario para ID usuario para caber mais usuarios autorizados no parametro ZZ_AUTORPV.

				If nTotPV < nLimite .And. ! IsInCallStack('U_ADVEN002P') //Everson - 19/10/2017. Chamado 037287.
					IF IsInCallStack('U_ADVEN002P')  == .T.
						Aadd(aPedidos,{cchave, ;
						''    , ;
						''    , ;
						''    , ;
						'Atencao !! O Valor Minimo para os Pedidos de Vendas ï¿½ de R$ ' + Alltrim(Transform(nLimite,"@E 999,999,999.99") ) + '. Verifique!!' ,;
						cVendedor})

					ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
						Aadd(aPedidos,{'Atencao !! O Valor Minimo para os Pedidos de Vendas ï¿½ de R$ ' + Alltrim(Transform(nLimite,"@E 999,999,999.99") ) + '. Verifique!!'})

					ELSE

						ApMsgInfo(OemToAnsi("Atencao !! O Valor Minimo para os Pedidos de Vendas ï¿½ de R$ " + Alltrim(Transform(nLimite,"@E 999,999,999.99") ) + ". Verifique!!"))

					ENDIF
					lRet := .F.
				EndIf

				//Mauricio - 22/04/15 - novo tratamento relativo ao valor minimo do pedido por faixa/vendedor. O tratamento acima nï¿½o ira mais funcionar(mas foi mantido) pois no parametro foi colocado ZERO como valor minimo.
				_cVDPED := M->C5_VEND1

				DbSelectArea("SA3")
				DbSetOrder(1)
				if dbseek(xFilial("SA3")+_cVDPED)
					//Mauricio - 05/04/17 - a validacao por faixa/vendedor sera substituida pelo validaï¿½ï¿½o por segmento
					//Assim sendo nao faz sentido manter o bloqueio especifico abaixo em caso de falta de cadastro da faixa
					_cFaixa := SA3->A3_FXPDMIN
					/*
					IF empty(_cFaixa)
					IF IsInCallStack('U_ADVEN002P')  == .T.
					Aadd(aPedidos,{cchave, ;
					''    , ;
					''    , ;
					''    , ;
					'Atencao !! Vendedor no pedido sem faixa alocada em seu cadastro. O pedido nï¿½o pode ser validado! Verifique!!',;
					cVendedor})

					ELSE

					ApMsgInfo(OemToAnsi("Atencao !! Vendedor no pedido sem faixa alocada em seu cadastro. O pedido nï¿½o pode ser validado! Verifique!!"))

					ENDIF

					lRet := .F.
					Else
					*/
					IF !Empty(_cFaixa)  //Mauricio 05/04/17
						//Mauricio - 05/04/17 - para efeito da nova forma de validacao por segmento eh necessario que no cadastro
						//abaixo as faixas estejam todas com ZERO!!!!!! conforme combinado com Sr. Eduardo para manter o que ja existe.
						_nValmin := VAL(Posicione("SX5",1,"02"+"A#"+_cFaixa,"X5_DESCRI"))
						If nTotPV < _nValmin .And. ! IsInCallStack('U_ADVEN002P') //Everson - 19/10/2017. Chamado 037287.
							IF IsInCallStack('U_ADVEN002P')  == .T.
								Aadd(aPedidos,{cchave, ;
								''    , ;
								''    , ;
								''    , ;
								'Atencao !! O Valor Minimo para os Pedidos de Vendas ï¿½ de R$ ' + Alltrim(Transform(_nValmin,"@E 999,999,999.99") ) + '. Verifique!!' ,;
								cVendedor})

							ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
								Aadd(aPedidos,{'Atencao !! O Valor Minimo para os Pedidos de Vendas ï¿½ de R$ ' + Alltrim(Transform(_nValmin,"@E 999,999,999.99") ) + '. Verifique!!'})

							ELSE

								ApMsgInfo(OemToAnsi("Atencao !! O Valor Minimo para os Pedidos de Vendas ï¿½ de R$ " + Alltrim(Transform(_nValmin,"@E 999,999,999.99") ) + ". Verifique!!"))

							ENDIF
							lRet := .F.
						EndIf
					Endif
				endif
				//Mauricio - 05/04/17 - validaï¿½ï¿½o do valor minimo do pedido de venda por segmento
				_cCLIe := M->C5_CLIENTE
				_cLoje := M->C5_LOJACLI

				DbSelectArea("SA1")
				DbSetOrder(1)
				if dbseek(xFilial("SA1")+_cCLIe+_cLoje)
					_cSegto := SA1->A1_SATIV1
					IF empty(_cSegto)
						IF IsInCallStack('U_ADVEN002P')  == .T.
							Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							'Atencao !! Cliente do pedido sem segmento alocado em seu cadastro. O pedido minimo nï¿½o pode ser validado! Verifique!!',;
							cVendedor})

						ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
							Aadd(aPedidos,{'Atencao !! Cliente do pedido sem segmento alocado em seu cadastro. O pedido minimo nï¿½o pode ser validado! Verifique!!'})

						ELSE

							ApMsgInfo(OemToAnsi("Atencao !! Cliente do pedido sem segmento alocado em seu cadastro. O pedido minimo nï¿½o pode ser validado! Verifique!!"))

						ENDIF

						lRet := .F.

					Else
						DbSelectArea("ZBP")
						DbSetOrder(1)
						If dbseek("02"+_cSegto)  //O cadastro dessa forma sï¿½ eh feito em VArzea e vale para todas(definicao Sr. Vagner).
							_nValmin := ZBP->ZBP_VALMIN
						Else
							_nValmin := 0
						Endif
						If nTotPV < _nValmin .And. ! IsInCallStack('U_ADVEN002P') //Everson - 19/10/2017. Chamado 037287.
							IF IsInCallStack('U_ADVEN002P')  == .T.
								Aadd(aPedidos,{cchave, ;
								''    , ;
								''    , ;
								''    , ;
								'Atencao !! O Valor Minimo para os Pedidos de Vendas ï¿½ de R$ ' + Alltrim(Transform(_nValmin,"@E 999,999,999.99") ) + '. Verifique!!' ,;
								cVendedor})

							ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
								Aadd(aPedidos,{'Atencao !! O Valor Minimo para os Pedidos de Vendas ï¿½ de R$ ' + Alltrim(Transform(_nValmin,"@E 999,999,999.99") ) + '. Verifique!!'})

							ELSE

								ApMsgInfo(OemToAnsi("Atencao !! O Valor Minimo para os Pedidos de Vendas ï¿½ de R$ " + Alltrim(Transform(_nValmin,"@E 999,999,999.99") ) + ". Verifique!!"))

							ENDIF
							lRet := .F.
						EndIf
					Endif
				endif

			EndIf

		EndIf

	EndIf

	//

	//Mauricio - 15/02/11 - Incluido por necessidade para que rotina de copia de pedidos funcione corretamente.
	//Usuarios do parametro nao podem copiar pedido com data fora do limite do parametro.
	//Mauricio - 16/02/11 - Conforme informado pela Ana, deve-se tambem validar a data de entrega atual no pedido que nao pode ultrapassar o parametro.

	If !lSfInt .And. _lCOPIA   //Rotina ï¿½ chamada por copia
		If _lUSUCOPIA  //Se o usuario esta no parametro
			_lRetUsuC := .T.
			If     _dData < dDataBase  //Se a data ï¿½ permitida para efetuar a copia
				lRet := .F.
				IF IsInCallStack('U_ADVEN002P')  == .T.
					Aadd(aPedidos,{cchave, ;
					''    , ;
					''    , ;
					''    , ;
					'Data entrega limite para copia do pedido ultrapassada. Copia nï¿½o permitida!' ,;
					cVendedor})

				ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
					Aadd(aPedidos,{'Data entrega limite para copia do pedido ultrapassada. Copia nï¿½o permitida!'})

				ELSE

					ApMsgInfo("Data entrega limite para copia do pedido ultrapassada. Copia nï¿½o permitida!")

				ENDIF

			ElseIf M->C5_DTENTR > _dData
				lRet := .F.
				IF IsInCallStack('U_ADVEN002P')  == .T.
					Aadd(aPedidos,{cchave, ;
					''    , ;
					''    , ;
					''    , ;
					'Data entrega do pedido ï¿½ maior que a data limite permitida. Copia nï¿½o permitida!' ,;
					cVendedor})

				ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
					Aadd(aPedidos,{'Data entrega do pedido ï¿½ maior que a data limite permitida. Copia nï¿½o permitida!'})

				ELSE

					ApMsgInfo("Data entrega do pedido ï¿½ maior que a data limite permitida. Copia nï¿½o permitida!")

				ENDIF
			EndIf
		EndIf
	EndIf

	//Mauricio - 01/10/15 - verificacao para nao Alterar pedido de venda ja excluido...
	IF !lSfInt .And. ALTERA
		DbSelectArea("SC5")
		If Deleted()
			lRet := .F.
			IF IsInCallStack('U_ADVEN002P')  == .T.
				Aadd(aPedidos,{cchave, ;
				''    , ;
				''    , ;
				''    , ;
				'Pedido de venda ja excluido nao pode ser alterado' ,;
				cVendedor})

			ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
				Aadd(aPedidos,{'Pedido de venda ja excluido nao pode ser alterado'})

			ELSE

				ApMsgInfo("Pedido de venda ja excluido nao pode ser alterado!")

			ENDIF
		Endif
	Endif

	//Mauricio 14/06/11 - solicitado por Vagner email de 13/06/11 - Nova tabela de preï¿½o.
	//incluida primeira parte para permitir vendedores interestaduais incluirme pedido depois da hora limite com D+2 dias ou ate parametro limite maximo de dias futuro.
	//esta primeira parte complementa tratamento no fonte MBRWBTN.prw.
	//segunda parte valida qualquer pedido com maximo data entrega futura até limite contido em parametro.
	//Em 20/07/2011 conforme reunião com Srs. Alex e Vagner ficou definido que Interestadual e Supervisores não terão horario limite para inclusao de PV.
	//porem os PV´s incluidos após o horario limite terão data de entrega D + 2.
	IF !lSfInt .And.  Alltrim(cEmpAnt) $ cEmpSF .AND. Alltrim(cFilAnt) $ cFilRN  // executar somente para empresa Adoro filial Varzea Paulista. //motivo erro no Grupo 06 William Costa chamado 021253
		IF M->C5_REFATUR <> 'S' //ajuste william costa pois o refaturamento não entra nessa regra
			dbSelectArea("SA3")
			dbSetOrder(7)
			If dbSeek(xFilial("SA3")+__cUserID)
				// Ricardo Lima - 13/06/18
				If SUBSTR(SA3->A3_XVLDPER,1,1) = '1' .AND. Alltrim(cEmpAnt) $ cEmpSF .and. !lSfInt
					ApMsgInfo('Vendedor sem PERMISSÃO para Incluir Pedido, verifique com a Supervisão!','Permissões de Vendedores')
					//Conout( DToC(Date()) + " " + Time() + " MT410TOK >>> FINAL PE" )
					Return(.F.)
				Endif

				if (TIME()>GETMV("MV_TEMPED1") .AND. SA3->A3_NIVETAB == "1"  .And. SA3->A3_SEGMERC == "001"); //Estadual
				.Or. (TIME()>GETMV("MV_TEMPED2") .AND. SA3->A3_NIVETAB == "1"  .And. SA3->A3_SEGMERC == "002" .AND. !(ALLTRIM(SA3->A3_REGIAO) $ "RS_12/SC_12")); //Interestadual
				.Or. (TIME()>GETMV("MV_TEMPED4") .AND. SA3->A3_NIVETAB == "1"  .And. SA3->A3_SEGMERC == "002" .AND. ALLTRIM(SA3->A3_REGIAO) $ "RS_12/SC_12") //Interestadual Especifico Regiao Sul
					if _dDTENTR > (_nDiasDte+ddatabase) .Or. _dDTENTR < (ddatabase+2)
						IF IsInCallStack('U_ADVEN002P')  == .T.
							Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							'Data de entrega do pedido de venda ï¿½ maior que o permitido ou passado do horario limite somente D+2 permitido',;
							cVendedor})

						ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
							Aadd(aPedidos,{'Data de entrega do pedido de venda ï¿½ maior que o permitido ou passado do horario limite somente D+2 permitido'})

						ELSE

							MSgInfo("Data de entrega do pedido de venda ï¿½ maior que o permitido ou passado do horario limite somente D+2 permitido","Atenï¿½ï¿½o")

						ENDIF

						lRet := .F.
					Endif
				Elseif ( Empty(Alltrim(cValToChar(M->C5_PEDEXP))) .And. TIME()>GETMV("MV_TEMPED3") .AND. SA3->A3_NIVETAB == "2")  //Mauricio - 15/04/15 - tratamento diferenciado para supervisores solicitados pelo Vagner. //Everson - 20/04/2022 - Chamado TI.
					if _dDTENTR > (_nDiasDte+ddatabase) .Or. _dDTENTR < (ddatabase+2)
						IF IsInCallStack('U_ADVEN002P')  == .T.
							Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							'Data de entrega do pedido de venda ï¿½ maior que o permitido ou passado do horario limite somente D+2 permitido' ,;
							cVendedor})

						ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
							Aadd(aPedidos,{'Data de entrega do pedido de venda ï¿½ maior que o permitido ou passado do horario limite somente D+2 permitido'})

						ELSE

							MSgInfo("Data de entrega do pedido de venda ï¿½ maior que o permitido ou passado do horario limite somente D+2 permitido","Atenï¿½ï¿½o")

						ENDIF

						lRet := .F.
					Endif
				Elseif _dDTENTR > (_nDiasDte+ddatabase)
					IF IsInCallStack('U_ADVEN002P')  == .T.
						Aadd(aPedidos,{cchave, ;
						''    , ;
						''    , ;
						''    , ;
						'Data de entrega no cabecalho do pedido de venda ï¿½ maior que o permitido!' ,;
						cVendedor}) 

					ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
						Aadd(aPedidos,{'Data de entrega no cabecalho do pedido de venda ï¿½ maior que o permitido!'})

					ELSE

						MSgInfo("Data de entrega no cabecalho do pedido de venda ï¿½ maior que o permitido!","Atenï¿½ï¿½o")

					ENDIF

					lRet := .F.
				Endif
				/*
				For _y1 := 1 to Len(aCols) 
				If aCols[_y1,Len(aHeader)+1] == .F.
				IF ACOLS[_y1,_NPOSDTENTR] > (_nDiasDte+ddatabase)
				MSgInfo("Item "+ACOLS[_y1,_NPOSITEM]+" do pedido com data de entrega maior que o permitido!","Atenï¿½ï¿½o")
				lRet := .F.
				endif   
				EndIf   
				Next _y1
				*/
			Endif
		ENDIF //fecha if do refaturamento william costa
	ENDIF //FECHA IF DO GRUPO DA EMPRESA
	//Alterado para novo procedimento para Sï¿½o Paulo. Mauricio 10/12/09.

	If !(M->C5_TIPO $ "D")    //Retirada condicao de restricao para TIPO B(Utiliza fornecedor). Chamado 005396 - Mauricio HC
		If M->C5_TIPO $ "B"
			dbSelectArea("SA2")
			SA2->(dbSeek(xFilial("SA2")+M->C5_CLIENTE+M->C5_LOJACLI))
			cUF	:= SA2->A2_EST
		Else
			dbSelectArea("SA1")
			SA1->(dbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
			cUF	:= SA1->A1_EST

			if SA1->A1_TIPO = "F" //Consumidor Final
				_lConsFinal	:= .T.
			endif
			if Alltrim(SA1->A1_REDE) $ cRedeOP .and. Empty(M->C5_OPLOG) //incluido por Adriana //Alterado por Adriana chamado 031238 em novembro/2016
				IF IsInCallStack('U_ADVEN002P')  == .T.
					Aadd(aPedidos,{cchave, ;
					''    , ;
					''    , ;
					''    , ;
					'Para esta Rede, ï¿½ obrigatï¿½rio preencher Cï¿½digo do Operador Logï¿½stico !!!' ,;
					cVendedor})

				ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
					Aadd(aPedidos,{'Para esta Rede, ï¿½ obrigatï¿½rio preencher Cï¿½digo do Operador Logï¿½stico !!!'})

				ELSE

					MsgInfo("Para esta Rede, ï¿½ obrigatï¿½rio preencher Cï¿½digo do Operador Logï¿½stico !!!","MV_#REDEOP")

				ENDIF

				lRet:=.F.
			endif
		EndIf

		For n2 := 1 to Len(aCols)

			If aCols[n2,Len(aHeader)+1] == .F.
				dbSelectArea("SF4")
				SF4->(dbSeek(xFilial("SF4")+aCols[n2,nTes]))
				If cUF == "SP"
					If Alltrim(SF4->F4_CF) $ _CFST     //CFOP Venda de embutidos com ICMS ST    5401/5910/5118   - incluido por Adriana em 12/04/2017 - chamado 034546
						dbSelectArea("SB1")
						SB1->(dbSeek(xFilial("SB1")+aCols[n2,nProd]))
						//					If SB1->B1_PICMRET > 0 .and. (!_lConsFinal .or. (_lConsFinal .and. !SF4->F4_CODIGO$GETMV("MV_XTESDOA")))
						If SB1->B1_PICMRET > 0 .and. (!_lConsFinal .or. (_lConsFinal .and. !SF4->F4_CODIGO$(Alltrim(GETMV("MV_XTESDOA"))+Alltrim(GETMV("MV_XTESBOQ")))))
							//Incluido parametro MV_XTESBOQ, para nï¿½o calcular ST para consumidor final de bonificacao qualidade por Adriana em 02/12/2016 chamado 031656
							//Incluida verificacao de Consumidor final com TES Doacao nao calcula - por Adriana conforme chamado 020192 de 02/09/2014
							M->C5_TIPOCLI	:= "S"
						EndIf
					EndIf
				EndIf
			EndIf

		Next n2

	EndIf
	// Paulo - TDS - 20/05/2011 - EM TESTE = Inibindo a condiï¿½ï¿½o abaixo, para os testes com as tabelas de preï¿½os

	//Mauricio - 01/03/11 - Incluida validaï¿½ï¿½o de preco minimo do produto para todos os itens (trazido do fonte AD0078 aonde ï¿½ feito apenas por linha).
	If Len(aCols) > 0
	
		If !lSfInt

			For _x1 := 1 to Len(aCols)
	
				If aCols[_x1,Len(aHeader)+1] == .F.
					_CPRODUTO := ACOLS[_x1,nProd]
					_NPRCVEN  := ACOLS[_x1,_NPOSPRCVEN]


					if ACOLS[_x1,_nPosRote] <> M->C5_ROTEIRO
						ACOLS[_x1,_nPosRote] := M->C5_ROTEIRO
					endif

					//ALTERADO POR ADRIANA PARA PERMITIR A ALTERACAO DO VALOR PARA NOTAS DE COMPLEMENTO DE ICMS E IPI, DEVOLUCAO E BENEFICIAMENTO
					If !M->C5_TIPO $ 'IPBD' .AND. Alltrim(cFilAnt) $ cFilRN     //Incluido filial 07 em 13/08/14
						dbSelectArea("DA1")
						dbSetOrder(1)
						//Incluido 30/03/11 - ANA, pois estava dando a mensagem quando inserido mais uma linha sem produto
						//If !dbSeek( xFilial("DA1") + _CTABELA + _CPRODUTO )  .OR. EMPTY(_CTABELA)
	
						If (!dbSeek( xFilial("DA1") + _CTABELA + _CPRODUTO )  .OR. EMPTY(_CTABELA)) .AND. !EMPTY(_CPRODUTO)
							dbSelectArea("SA3")
							dbSetOrder(7)
	
							If dbSeek (xFilial()+__CUSERID)
								_lRet   := .F. //Mauricio - 02/03/11 - Solicitdo por Alex bloqueio quando nao tem tabela no cadastro do Cliente.
								IF IsInCallStack('U_ADVEN002P')  == .T.
									Aadd(aPedidos,{cchave, ;
									''    , ;
									''    , ;
									''    , ;
									'Cliente sem tabela de preï¿½o em seu cadastro.Contate Depto. Comercial.O pedido nao podera ser incluido!' ,;
									cVendedor})
	
								ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
									Aadd(aPedidos,{'Cliente sem tabela de preï¿½o em seu cadastro.Contate Depto. Comercial.O pedido nao podera ser incluido!'})
	
								ELSE
	
									ApMsgInfo(OemToAnsi("Cliente sem tabela de preï¿½o em seu cadastro.Contate Depto. Comercial.O pedido nao podera ser incluido!"))
	
								ENDIF
	
								Exit
							Else
								_lRet   := .T.
							EndIf
						Else
							dbSelectArea("SA3")
							dbSetOrder(7)
							If dbSeek (xFilial()+__CUSERID)
								If     A3_NIVETAB = '3' .OR. A3_NIVETAB = '4'
									_PRECO  := "DA1_PRCGER"
									_TABELA := "GERï¿½NCIA"
								ElseIf A3_NIVETAB = '2'
									_PRECO  := "DA1_PRCSUP"
									_TABELA := "SUPERVISï¿½O"
								ElseIf A3_NIVETAB = '1'
									_PRECO  := "DA1_PRCVEN"
									_TABELA := "VENDEDOR"
								EndIf
							Else
								_PRECO  := "DA1_PRCVEN"
								_TABELA := "USUï¿½RIO NAO CADASTRADO"
							EndIf
	
							_NPRECOUNIT := DA1->&(_PRECO)
	
							If !_lRetUsuC
								If _NPRCVEN < _NPRECOUNIT
									IF IsInCallStack('U_ADVEN002P')  == .T.
										Aadd(aPedidos,{cchave, ;
										''    , ;
										''    , ;
										''    , ;
										'PRECO Mï¿½NIMO DO PRODUTO '+ALLTRIM(_CPRODUTO)+' PARA '+_TABELA+' ï¿½ DE R$ '+ALLTRIM(STR(_NPRECOUNIT)) ,;
										cVendedor})
	
									ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
										Aadd(aPedidos,{'PRECO Mï¿½NIMO DO PRODUTO '+ALLTRIM(_CPRODUTO)+' PARA '+_TABELA+' ï¿½ DE R$ '+ALLTRIM(STR(_NPRECOUNIT))})
	
									ELSE
	
										ApMsgBox(OemToAnsi("PRECO Mï¿½NIMO DO PRODUTO ")+ALLTRIM(_CPRODUTO)+" PARA "+_TABELA+" ï¿½ DE R$ "+ALLTRIM(STR(_NPRECOUNIT)),OemToAnsi("ATENCAO","INFO"))
	
									ENDIF
	
									lRet := .F.
								EndIf
	
							EndIf
	
						EndIf
	
					EndIf
	
				EndIf
	
			Next _x1
		
		EndIf

		For _x2 := 1 to Len(aCols) //Mauricio - 02/03/11 - Correï¿½ï¿½o problema copia pedido apontado por Renato Santos.
			If aCols[_x2,Len(aHeader)+1] == .F.
				ACOLS[_x2,_NPOSDTENTR] 	:= _dDTENTR
				aCols[_x2,_nPosVend] 	:= M->C5_VEND1 //Incluido por Adriana para gravar corretamente o cï¿½digo do vendedor
			EndIf
		Next _x2

	EndIf

	//Mauricio - MDS TECNOLOGIA - 14/10/13 - Validaï¿½ï¿½es para TES de DOACOES e BONIFICACOES

	IF !lSfInt .And. (INCLUI .OR. ALTERA) .and. Alltrim(cEmpAnt) $ cEmpSF //Alterado por Adriana devido ao error.log quando empresa <> 01 - chamado 032804
		_lUsuDoa  := .F.
		_lUsuADMV := .F.
		_lUsuBON  := .F.
		_lTesDoa  := .F.
		_lTesBon  := .F.
		_lTesBoQ  := .F.      //Incluido por Adriana em 20/07/16 para TES diferenciado para Qualidade - chamado 029611
		lLodoOsso := .F.
		If __cUserID $ GETMV("MV_#USUDOA")   //usuario doacao
			_lUsuDoa := .T.
		Endif
		If __cUserID $ GETMV("MV_#USUTPR")   //usuario bonificacao ADM VENDAS
			_lUsuADMV := .T.
		Endif

		If __cUserID $ GETMV("MV_#USUBON")   // Incluido por Adriana para tratar usuario bonificacao QUALIDADE em 20/05/15
			_lUsuBON := .T.
		Endif
		If Len(aCols) > 0
			For _x1 := 1 to Len(aCols)

				If aCols[_x1,Len(aHeader)+1] == .F.
					_CTES := ACOLS[_x1,nTES]
					If Alltrim(_cTES) $ GETMV("MV_XTESDOA")
						_lTesDoa := .T.
					Endif
					If Alltrim(_cTES) $ GETMV("MV_XTESBON")
						_lTesBon := .T.
					Endif
					If Alltrim(_cTES) $ GETMV("MV_XTESBOQ") //Incluido por Adriana em 20/07/16 - chamado 029611
						_lTesBoQ := .T.
					Endif
					If Alltrim(aCols[_x1,nProd]) $ "302229/297878/302212"
						lLodoOsso := .T.
					Endif
				EndIf

			Next _x1

			If __cUserID == "001255"
				If _lTESDOA .and. !lLodoOsso
					IF IsInCallStack('U_ADVEN002P')  == .T.
						Aadd(aPedidos,{cchave, ;
						''    , ;
						''    , ;
						''    , ;
						'Seu usuario nï¿½o pode incluir pedido com esta TES de doaï¿½ï¿½o para este produto!' ,;
						cVendedor})

					ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
						Aadd(aPedidos,{'Seu usuario nï¿½o pode incluir pedido com esta TES de doaï¿½ï¿½o para este produto!'})

					ELSE

						MsgInfo("Seu usuario nï¿½o pode incluir pedido com esta TES de doaï¿½ï¿½o para este produto!","Atenï¿½ï¿½o")

					ENDIF

					lRet := .F.
				Endif
			Else
				If _lTESDOA .AND. !_lUsuDoa
					IF IsInCallStack('U_ADVEN002P')  == .T.
						Aadd(aPedidos,{cchave, ;
						''    , ;
						''    , ;
						''    , ;
						'Seu usuario nï¿½o pode incluir pedido com esta TES de doaï¿½ï¿½o!' ,;
						cVendedor})

					ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
						Aadd(aPedidos,{'Seu usuario nï¿½o pode incluir pedido com esta TES de doaï¿½ï¿½o!'})

					ELSE

						MsgInfo("Seu usuario nï¿½o pode incluir pedido com esta TES de doaï¿½ï¿½o!","Atenï¿½ï¿½o")

					ENDIF

					lRet := .F.
				Endif
			Endif

			If _lTESBON .And. !_lUsuADMV .And. !_lUsuBON //Alterado por Adriana para tratar bonificaï¿½ï¿½o da qualidade em 20/05/15
				IF IsInCallStack('U_ADVEN002P')  == .T.
					Aadd(aPedidos,{cchave, ;
					''    , ;
					''    , ;
					''    , ;
					'Seu usuario nï¿½o pode incluir pedido com esta TES de bonificacao/doacao' ,;
					cVendedor})

				ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
					Aadd(aPedidos,{'Seu usuario nï¿½o pode incluir pedido com esta TES de bonificacao/doacao'})

				ELSE

					MsgInfo("Seu usuario nï¿½o pode incluir pedido com esta TES de bonificacao/doacao!","Atenï¿½ï¿½o")

				ENDIF

				lRet := .F.
			Endif

			//		  If !_lTESBON .And. _lUsuBON //Alterado por Adriana para tratar bonificaï¿½ï¿½o da qualidade em 20/05/15
			If !_lTESBOQ .And. _lUsuBON //Alterado por Adriana para tratar bonificaï¿½ï¿½o da qualidade em 20/05/15 //modificado por Adriana em 20/07/16 - chamado 029611
				IF IsInCallStack('U_ADVEN002P')  == .T.
					Aadd(aPedidos,{cchave, ;
					''    , ;
					''    , ;
					''    , ;
					'Seu usuario sï¿½ pode incluir pedido com TES de bonificacao: '+Alltrim(GETMV("MV_XTESBOQ")) ,;
					cVendedor})

				ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
					Aadd(aPedidos,{'Seu usuario sï¿½ pode incluir pedido com TES de bonificacao: '+Alltrim(GETMV("MV_XTESBOQ"))})

				ELSE

					MsgInfo("Seu usuario sï¿½ pode incluir pedido com TES de bonificacao: "+Alltrim(GETMV("MV_XTESBOQ")),"Atenï¿½ï¿½o")

				ENDIF

				lRet := .F.
			Endif

		EndIf
	Endif

	//Tratamento para CMS - sï¿½ permite multiplos de 50 caixas
	dbSelectArea("SA1")
	SA1->(dbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
	cUF	:= SA1->A1_EST
	If !lSfInt .And. !((M->C5_TIPO $ "N" .and. Alltrim(cUF) == "EX") .OR. M->C5_TIPO $ "D") // por William Costa em 30/10/14 - chamado 20854
		If Len(aCols) > 0
			For _x1 := 1 to Len(aCols)

				If aCols[_x1,Len(aHeader)+1] == .F.
					_nqtdUnsV := ACOLS[_x1,nUNSVEN]
					_nqtdQtdV := ACOLS[_x1,nQTDVEN]
					_CPRODUTO := ACOLS[_x1,nProd]
					dbSelectArea("SB1")
					SB1->(dbSeek(xFilial("SB1")+aCols[_x1,nProd]))
					//If  SUBSTR(Alltrim(SB1->B1_DESC),1,16) $ "CARNE MEC SEPARADA/CARNE MEC. SEPARADA/CARNE MECANICAMENTE";
					//.OR. SUBSTR(Alltrim(SB1->B1_DESC),1,3) $ "CMS" .OR. SUBSTR(Alltrim(SB1->B1_DESC),1,5) $ "C M S"
					If Alltrim(SB1->B1_GRUPO) $ cGrpPCMS //051864 - Abel Babini-20/09/2019, Cria parametros de produtos CMS e validaï¿½ï¿½o de quantidade
						If Alltrim(_cPRODUTO) == "198294" //Produto utilizado para pedidos de remessa laboratorial, liberar para faturamento 1 bloco - chamado 019120
							lRet := .T.
							If _nqtdQtdV <> 1
								IF IsInCallStack('U_ADVEN002P')  == .T.
									Aadd(aPedidos,{cchave, ;
									''    , ;
									''    , ;
									''    , ;
									'Quantidade dos produtos CMS sï¿½ podem ser incluidos com 1 KG' ,;
									cVendedor})

								ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
									Aadd(aPedidos,{'Quantidade dos produtos CMS sï¿½ podem ser incluidos com 1 KG'})

								ELSE

									Alert("Quantidade dos produtos CMS sï¿½ podem ser incluidos com 1 KG")

								ENDIF

								lRet := .F.
							Endif
						Else
							nQtdPlt	:= SB1->B1_XALTUR * SB1->B1_XALTLAS 
							//If MOD(_nqtdUnsV,GETMV("MV_#QTDCMS")) <> 0
							If MOD(_nqtdUnsV,nQtdPlt) <> 0 //051864 - Abel Babini-20/09/2019, Cria parametros de produtos CMS e validaï¿½ï¿½o de quantidade
								IF IsInCallStack('U_ADVEN002P')  == .T.
									Aadd(aPedidos,{cchave, ;
									''    , ;
									''    , ;
									''    , ;
									'Quantidade dos produtos CMS devem ser multiplos de ' +  CVALTOCHAR(nQtdPlt) +  ' CX' ,;
									cVendedor})
									//'Quantidade dos produtos CMS devem ser multiplos de ' +  CVALTOCHAR(GETMV("MV_#QTDCMS")) +  ' CX' ,;

								ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
									//Aadd(aPedidos,{'Quantidade dos produtos CMS devem ser multiplos de ' +  CVALTOCHAR(GETMV("MV_#QTDCMS")) +  ' CX'})
									Aadd(aPedidos,{'Quantidade dos produtos CMS devem ser multiplos de ' +  CVALTOCHAR(nQtdPlt) +  ' CX'})

								ELSE

									//Alert("Quantidade dos produtos CMS devem ser multiplos de " +  CVALTOCHAR(GETMV("MV_#QTDCMS")) +  " CX")
									Alert("Quantidade dos produtos CMS devem ser multiplos de " +  CVALTOCHAR(nQtdPlt) +  " CX")

								ENDIF

								lRet := .F.
							Endif
						Endif
					Endif
				Endif
			Next _x1
		EndIf
	Endif


	//Mauricio - MDS Tecnologia - 05/02/14 - tratamento para nï¿½o permitir alterar data de entrega para PV com C5_XINT == "3"
	//Solicitado por Ana TI.
	//inicio
	If !lSfInt .And. ALTERA
		_aAreaSC5 := SC5->(GetArea())
		_aAreaSC6 := SC6->(GetArea())
		IF Alltrim(cEmpAnt) $ cEmpSF .And. _cPermAlt == "3" .And. Alltrim(cFilAnt) $ cFilSF     //Empresa 01, filial 02 e xint == 3
			DbSelectArea("SC5")
			DbSetOrder(1)
			Dbgotop()
			If dbseek(xFilial("SC5")+_cNumPed)
				IF _dDTENTR <> SC5->C5_DTENTR
					lRet := .F.
					IF IsInCallStack('U_ADVEN002P')  == .T.
						Aadd(aPedidos,{cchave, ;
						''    , ;
						''    , ;
						''    , ;
						'Este pedido de venda ja foi integrado ao EDATA e nï¿½o pode ter a Data de Entrega alterada!' ,;
						cVendedor})

					ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
						Aadd(aPedidos,{'Este pedido de venda ja foi integrado ao EDATA e nï¿½o pode ter a Data de Entrega alterada!'})

					ELSE

						MsgInfo("Este pedido de venda ja foi integrado ao EDATA e nï¿½o pode ter a Data de Entrega alterada!","Atenï¿½ï¿½o")

					ENDIF
				Endif
			Endif
		Endif
		RestArea(_aAreaSC5)
		RestArea(_aAreaSC6)
	Endif
	//Fim


	// ---------------------------------------------------
	// Execuï¿½ï¿½o das validaï¿½ï¿½es da aCols unificadas.
	// ---------------------------------------------------

	nCols	:= Len(aCols)
	If nCols > 0

		nCount 		:= 0
		
		For _nX := 1 to nCols

			If aCols[_nX,Len(aHeader)+1] == .F.
				_cUM 			:= Alltrim(ACOLS[_nX,nUM])
				_cSEGUM			:= ALLTRIM(ACOLS[_nX,nSegUM])
				_cProduto 		:= ACOLS[_nX,nProd]
				_cTes 			:= ACOLS[_nX,nTES]
				
				dbselectArea("SBZ")
				SBZ->(dbSetOrder(1))
				SBZ->(dbGoTop())
				SBZ->(dbSeek(xFilial("SBZ")+_cProduto))

				dbselectArea("SB1")
				SB1->(dbSetOrder(1))
				SB1->(dbGoTop())
				SB1->(dbSeek(xFilial("SB1")+_cProduto))

				IF !RetArqProd(_cProduto)
					_cLocPad	:= SBZ->BZ_LOCPAD
					_cLocaliz	:= SBZ->BZ_LOCALIZ
				ELSE
					_cLocPad	:= SB1->B1_LOCPAD
					_cLocaliz	:= SB1->B1_LOCALIZ
				ENDIF

				dbselectArea("SF4")
				SF4->(dbSetOrder(1))
				SF4->(dbGoTop())
				SF4->(dbSeek(xFilial("SF4")+ aCols[_nX,nTES]))

				// Nï¿½o executa as validaï¿½ï¿½es nos casos em que a rotina for executada atravï¿½s de execauto, rest.
				
					// 1. Valida o cadastro de produtos.
					fVldProd()
					
					// 2. Valida unidade de medida dos itens.
					fVldUM()

					// 3. Valida se o item controla localizaï¿½ï¿½o.
					fVldLocaliz()

					// 4. Tratamento integraï¿½ï¿½o eData
					fVldDat()

					If FWIsInCallStack("A410COPIA") //Everson - 03/02/2022. Chamado 67573.
						If gdFieldGet("C6_QTDLIB", _nX) <= 0
							nTemQt++ //Everson - 07/02/2022. Chamado 67573.

						Else
							nNTemQt++ //Everson - 07/02/2022. Chamado 67573.

						EndIf

					EndIf

			Endif

		Next _nX

	EndIf

	If nTemQt > 0 .And. nNTemQt > 0 //Everson - 07/02/2022. Chamado 67573.

		lRet := .F.
		Aviso("Atenï¿½ï¿½o","Hï¿½ itens com e sem liberaï¿½ï¿½o de quantidade.",{"OK"})
			
	EndIf

	// Trecho do cï¿½digo descontinuado.
	//Mauricio - Chamado 0035716 - 04/08/17 - Nao permitir produto sem local com tes que atualiza estoque
	/*
	If Alltrim(cEmpAnt) == "01" .or. Alltrim(cEmpAnt) == "02"
		For nX:=1 To Len(aCols)
			_cProd  := ACOLS[nX,nProd]
			_cLoc1 := Posicione("SB1",1,xFilial("SB1")+_cProd,"B1_LOCPAD")  //Mauricio - Chamado 035716 - 04/08/17
			_cLoc2 := Posicione("SBZ",1,xFilial("SBZ")+_cProd,"BZ_LOCPAD")  //Mauricio - Chamado 035716 - 04/08/17
			If !aCols[nX,nPDel] .and. !Empty(_cProd)  // Se nï¿½o tiver deletado e nao for branco
				dbSelectArea("SF4")
				SF4->(dbSetOrder(1))
				SF4->(dbSeek(xFilial("SF4")+ aCols[nX,nTES]))
				If SF4->F4_ESTOQUE == "S"
					If Empty(_cLoc1) .And. Empty(_cLoc2)
						IF IsInCallStack('U_ADVEN002P')  == .T.
							Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							'"Produto '+Alltrim(_cProd)+' sem LOCAL no cadastro de produtos. Produto nï¿½o pode ser utilizado!' ,;
							cVendedor})

						ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
							Aadd(aPedidos,{'"Produto '+Alltrim(_cProd)+' sem LOCAL no cadastro de produtos. Produto nï¿½o pode ser utilizado!'})

						ELSE
							MsgInfo("Produto "+Alltrim(_cProd)+" sem LOCAL no cadastro de produtos."+chr(13)+chr(13)+" Produto nï¿½o pode ser utilizado!")
						Endif
						lRet := .F.
					Endif
				Endif
				
				// INICIO WILLIAM COSTA 21/06/2019 CHAMADO 049973 || OS 051277 || FISCAL || VALERIA || 8389 || PEDIDO X FATURAMENTO
				IF  Posicione("SB1",1,xFilial("SB1")+_cProd,"B1_CONV")             > 1   .AND. ;
				    (ALLTRIM(Posicione("SB1",1,xFilial("SB1")+_cProd,"B1_SEGUM")) == ''  .OR. ;
				    ALLTRIM(ACOLS[nX,nSegUM])                                     == '')
				    
				    IF IsInCallStack('U_ADVEN002P')  == .T.
				    
						Aadd(aPedidos,{cchave, ;
						''    , ;
						''    , ;
						''    , ;
						'"Produto '+Alltrim(_cProd)+' Obrigatï¿½rio informar [Segunda Unidade de Medida] ' ,;
						cVendedor})

					ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
					
						Aadd(aPedidos,{'"Produto '+Alltrim(_cProd)+' Obrigatï¿½rio informar [Segunda Unidade de Medida] '})

					ELSE
					
						MsgInfo("Produto "+Alltrim(_cProd)+" Obrigatï¿½rio informar [Segunda Unidade de Medida] "+chr(13)+chr(13)+" Produto nï¿½o pode ser utilizado!")
						
					Endif                      
				    
					lRet := .F.
				    
				ENDIF
				
				IF  Posicione("SB1",1,xFilial("SB1")+_cProd,"B1_CONV")             = 0   .AND. ;
				    (ALLTRIM(Posicione("SB1",1,xFilial("SB1")+_cProd,"B1_SEGUM")) <> ''  .OR. ;
				    ALLTRIM(ACOLS[nX,nSegUM])                                     <> '')
				    
				    IF IsInCallStack('U_ADVEN002P')  == .T.
				    
						Aadd(aPedidos,{cchave, ;
						''    , ;
						''    , ;
						''    , ;
						'"Produto '+Alltrim(_cProd)+' Obrigatï¿½rio informar [Fator de Conversao] ' ,;
						cVendedor})

					ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
					
						Aadd(aPedidos,{'"Produto '+Alltrim(_cProd)+' Obrigatï¿½rio informar [Fator de Conversao] '})

					ELSE
					
						MsgInfo("Produto "+Alltrim(_cProd)+" Obrigatï¿½rio informar [Fator de Conversao] "+chr(13)+chr(13)+" Produto nï¿½o pode ser utilizado!")
						
					Endif                      
				    
					lRet := .F.
				    
				ENDIF
				
				// FINAL WILLIAM COSTA 21/06/2019 CHAMADO 049973 || OS 051277 || FISCAL || VALERIA || 8389 || PEDIDO X FATURAMENTO 
				
			Endif
		Next nX
	Endif
	*/

	//ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ä¿
	//ï¿½TRATAMENTO INTEGRAï¿½ï¿½O EDATA - INICIOï¿½
	//ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
	/*
	If Alltrim(cEmpAnt) == "01" .or. Alltrim(cEmpAnt) == "02"   // Integraï¿½ï¿½o CERES
		If lRet
			For nX:=1 To Len(aCols)
				If !aCols[nX,nPDel]  // Se nï¿½o tiver deletado

					dbSelectArea("SF4")
					SF4->(dbSetOrder(1))

					SF4->(dbSeek(xFilial("SF4")+ PADR(aCols[nX, nTES], TAMSX3("C6_TES")[1])))
					cTipo := SF4->F4_XTIPO

					If(!Empty(cTipo))
						cLendo := cTipo // cLendo = variï¿½vel que recebera o valor do campo F4_XTIPO atual que esta lendo

						// Caso o tipo anterior lido seja diferente da que estiver lendo
						If ((nCount > 0) .AND. (cLendo <> cLido))// verifica se a variï¿½vel cLido que contem o valor do item anterior ï¿½ igual ao atual cLendo
							IF IsInCallStack('U_ADVEN002P')  == .T.
								Aadd(aPedidos,{cchave, ;
								''    , ;
								''    , ;
								''    , ;
								'Erro no processo de cadastro do Item, Existem valores no campo F4_XTIPO diferentes entre os itens.' ,;
								cVendedor})

							ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
								Aadd(aPedidos,{'Erro no processo de cadastro do Item, Existem valores no campo F4_XTIPO diferentes entre os itens.'})

							ELSE

								Aviso("Erro no processo de cadastro do Item","Existem valores no campo F4_XTIPO diferentes entre os itens.",{"OK"})

							ENDIF

							lRet = .F.
							exit
						Endif
						cLido = cLendo
						nCount = nCount + 1
					EndIf
				Endif
			Next

			If(lRet)
				M->C5_XTIPO := cLido
			EndIf
		Endif
	EndIf
	*/

	//ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ä¿
	//ï¿½TRATAMENTO INTEGRAï¿½ï¿½O EDATA - FIM   ï¿½
	//ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½

	//Verifica pelo cadastro da Tes Inteligente (SFM) qual a tes de venda deve ser utilizada
	If Alltrim(cEmpAnt) $ cEmpSF .And. Alltrim(cFilAnt) $ cFilRN
		dbSelectArea("SA3")
		dbSetOrder(7)
		If dbSeek (xFilial()+__CUSERID) .and. !__CUSERID $ GETMV("MV_EXTESIN")

			If Len(aCols) > 0
				_aAreaSC5 := SC5->(GetArea())
				_aAreaSC6 := SC6->(GetArea())
				_aAreaSF4 := SF4->(GetArea())
				_aAreaSB1 := SB1->(GetArea())
				//Posicione("SX5",1,"02"+"A#"+_cFaixa,"X5_DESCRI")

				_cTipoCli := iif(_cTipoCli="F".and. Alltrim(_cEstCli)="SP" ,"F"," ") //Para tratar excecao de Consumidor Final SP, incluido por Adriana em 06/04/17
				cTpCliSF := _cTipoCli
				
				For _x1 := 1 to Len(aCols)

					If aCols[_x1,Len(aHeader)+1] == .F.
						_cProduto := ACOLS[_x1,nProd]
						
						//Everson - 08/03/2018. Chamado 037261. SalesForce.
						If !lSfInt
							_cTipoOper := iif(_dDTENTR >= ctod("01/04/2017"),"02","01") // por Adriana em 24/03/17  //FM_TIPO = 01 (antes de 01/04/2017) // FM_TIPO = 02 (depois de 01/04/2017)
						
						Else
								
							_cTipoOper := Alltrim(cValToChar(ACOLS[_x1,nTpOpC6]))
							
							If Empty(_cTipoOper)
								_cTipoOper := iif(_dDTENTR >= ctod("01/04/2017"),"02","01")
							
							EndIf
							
						EndIf
						
						//
						dbselectArea("SFM")
						SFM->(dbSetOrder(1))
						SFM->(dbGoTop())
						If _cTipoOper $("02|01")
						
							SFM->(dbSeek(xFilial("SFM")+_cTipoOper + Alltrim(_cProduto))) //Apenas para Venda (FM_TIPO = "01") // colocada variavel _ctipooper por Adriana em 24/03/17
							While !Eof() .and. Alltrim(SFM->FM_TIPO) == _cTipoOper .and. Alltrim(_cProduto) == Alltrim(SFM->FM_PRODUTO)// colocada variavel _ctipooper por Adriana em 24/03/17
								If Alltrim(_cEstCli) == Alltrim(SFM->FM_EST) .and. Alltrim(_cTipoCli) = Alltrim(SFM->FM_TIPOCLI)   //por Adriana incluido tratamento para consumidor final
									ACOLS[_x1,nTES] := SFM->FM_TS
									dbSelectAreA("SB1")
									dbSetOrder(1)
									_cOrigProd := ""
									If dbSeek(xFilial("SB1")+_cProduto)
										_cOrigProd := SB1->B1_ORIGEM
									Endif
									dbSelectAreA("SF4")
									dbSetOrder(1)
									If dbSeek( xFilial("SF4") + ACOLS[_x1,nTES])
										aCols[_x1][_nPCLAS]:= Alltrim(_cOrigProd)+SF4->F4_SITTRIB
										If Alltrim(_cEstCli) == "SP"
											aCols[_x1][_nPCF]:= SF4->F4_CF
										Else
											aCols[_x1][_nPCF]:= "6"+Substr(SF4->F4_CF,2,3)
										Endif
									Endif
								Endif
	
								SFM->(dbSkip())
							Enddo
							
						ElseIf _cTipoOper $("04|X|Y") //Bonificaï¿½ï¿½o, venda ï¿½ ordem e remessa de venda ï¿½ ordem, respectivamente.
							//Conout("ENTROU EM 04|X|Y ")
							//
							lItemSF := Nil
							If ! SFM->(dbSeek(xFilial("SFM") + Padr(_cTipoOper,2," ") + Alltrim(_cProduto)))
								 
								 If ! SFM->(dbSeek(xFilial("SFM") + Padr(_cTipoOper,2," ") + Space(15) ))
								 	Aadd(aPedidos,{"Erro de TES produto " + Alltrim(_cProduto) + ". Nï¿½o foi possï¿½vel localizar a operaï¿½ï¿½o " + Padr(_cTipoOper,2," ") + " (SFM)."})
								 	RestArea(_aAreaSC5)
									RestArea(_aAreaSC6)
									RestArea(_aAreaSF4)
									RestArea(_aAreaSB1)
								 	RestArea(aArea)
									//Conout( DToC(Date()) + " " + Time() + " MT410TOK >>> FINAL PE" )
								 	Return .F.
								 	
								 Else
								 	lItemSF := .F.
								 	
								 EndIf
								 
							Else
								lItemSF := .T.
								
							EndIf
							
							//
							While ! SFM->(Eof()) .and. Alltrim(cValToChar(SFM->FM_TIPO)) == Alltrim(cValToChar(_cTipoOper))
								
								
								
								If Alltrim(_cEstCli) == Alltrim(SFM->FM_EST) .and. Alltrim(_cTipoCli) = Alltrim(SFM->FM_TIPOCLI) .And. Alltrim(SFM->FM_PRODUTO) == Iif(lItemSF,Alltrim(_cProduto),"")
							
									ACOLS[_x1,nTES] := SFM->FM_TS
									dbSelectAreA("SB1")
									dbSetOrder(1)
									_cOrigProd := ""
									If dbSeek(xFilial("SB1")+_cProduto)
										_cOrigProd := SB1->B1_ORIGEM
									Endif
									dbSelectAreA("SF4")
									SF4->(dbSetOrder(1))
									If SF4->(dbSeek( xFilial("SF4") + ACOLS[_x1,nTES]))
										aCols[_x1][_nPCLAS]:= Alltrim(_cOrigProd)+SF4->F4_SITTRIB
										If Alltrim(_cEstCli) == "SP"
											aCols[_x1][_nPCF]:= SF4->F4_CF
										Else
											aCols[_x1][_nPCF]:= "6"+Substr(SF4->F4_CF,2,3)
										Endif
									Endif
								Endif
	
								SFM->(dbSkip())

							Enddo							

						EndIF						

						//Inicio Ticket 692 por Adriana Oliveira em 03/09/2020
						if !Empty(_cN57608) .and. Embutido()

							ACOLS[_x1,nTES] := _cTES57608
							dbSelectAreA("SF4")
							dbSetOrder(1)
							If dbSeek( xFilial("SF4") + _cTES57608)
								aCols[_x1][_nPCLAS]:= "0"+SF4->F4_SITTRIB
								If Alltrim(_cEstCli) == "SP"
									aCols[_x1][_nPCF]:= SF4->F4_CF
								Else
									aCols[_x1][_nPCF]:= "6"+Substr(SF4->F4_CF,2,3)
								Endif
							Endif
						//Fim Ticket 692 por Adriana Oliveira em 03/09/2020
						EndIf
 
					Endif

				Next _x1
				RestArea(_aAreaSC5)
				RestArea(_aAreaSC6)
				RestArea(_aAreaSF4)
				RestArea(_aAreaSB1)
			Endif
		EndIf
	Endif

	//INICIO Ticket 11223   - Abel Babini      - 23/03/2021 - Nï¿½o mais alterar a TES para clientes Simples Nacional a partir de 01/04/2021
	//INICIO Ticket 8190 	  - Abel Babini      - 18/01/2021 - Alterar TES para cliente Simples Nacional para produtos carne 
	//Clientes de SP
	//Clientes Optante pelo Simples Nacional
	//Parï¿½metro MV_#T65255 Preenchido com a TES da legislaï¿½ï¿½o 65.255
	//Produtos cujo campo SB1->B1_XD65255 = 'S'

	// _aAreaSF4 := SF4->(GetArea())
	// _aAreaSB1 := SB1->(GetArea())
	// For _x1 := 1 to Len(aCols)
	// 	_cProduto := ACOLS[_x1,nProd] //Ticket 8190 	  - Abel Babini      - 19/01/2021 - Ajuste na regra para atualizar o produto dentro do Laï¿½o FOR

	// 	//INICIO Ticket 8569 	  - Abel Babini      - 25/01/2021 - Acrescentado tratamento para somente Operï¿½ï¿½es 01 e 02 Venda tratarem a mudanï¿½a de TES para Clientes Simples Nacional
	// 	If !lSfInt
	// 		_cTipoOper := iif(_dDTENTR >= ctod("01/04/2017"),"02","01") 
	// 	Else
	// 		_cTipoOper := Alltrim(cValToChar(ACOLS[_x1,nTpOpC6]))
	// 		If Empty(_cTipoOper)
	// 			_cTipoOper := iif(_dDTENTR >= ctod("01/04/2017"),"02","01")
	// 		EndIf
	// 	EndIf
		//FIM Ticket 8569 	  - Abel Babini      - 25/01/2021 - Acrescentado tratamento para somente Operï¿½ï¿½es 01 e 02 Venda tratarem a mudanï¿½a de TES para Clientes Simples Nacional
		//Ver parï¿½metro _cMT410A	=> MV_#MT410A
		//If _cTipoOper $ _cMT410A //Ticket 8569 	  - Abel Babini      - 25/01/2021 - Acrescentado tratamento para somente Operï¿½ï¿½es 01 e 02 Venda tratarem a mudanï¿½a de TES para Clientes Simples Nacional
		//Ticket 9231 	  - Abel Babini      - 08/02/2021 - Alterado o tratamento de Bonificaï¿½ï¿½o para clientes Simples Nacional, considerando os parï¿½metros MV_XTESBON, MV_XTESBOQ, MV_XTESDOA
	// 	IF !aCols[_x1,nTES]$(Alltrim(GETMV("MV_XTESDOA"))+'/'+Alltrim(GETMV("MV_XTESBOQ")))+'/'+Alltrim(GETMV("MV_XTESBON")) 
	// 		dbSelectArea("SB1")
	// 		dbSetOrder(1)
	// 		If dbSeek(xFilial("SB1")+_cProduto)
	// 			_cOrigProd := SB1->B1_ORIGEM
	// 			_cDPr65255 := SB1->B1_XD65255
	// 		Endif

	// 		//Ticket 9765 	  - Abel Babini      - 19/02/2021 - Adicionada regra para que a alteraï¿½ï¿½o de TES nï¿½o seja executada quando o tipo do cliente for consumidor final
	// 		If Alltrim(_cEstCli) == "SP" .AND. Alltrim(_cCliTrb) == '1' .AND. !Empty(Alltrim(_cT65255)) .AND. Alltrim(_cDPr65255) == 'S' .AND. !_lConsFinal
	// 			dbSelectAreA("SF4")
	// 			dbSetOrder(1)
	// 			If dbSeek( xFilial("SF4") + Alltrim(_cT65255))
	// 				aCols[_x1,nTES] := Alltrim(_cT65255)
	// 				aCols[_x1][_nPCLAS]:= Alltrim(_cOrigProd)+SF4->F4_SITTRIB
	// 				aCols[_x1][_nPCF]:= SF4->F4_CF
	// 			Endif
	// 		Endif
	// 	Endif
	
	// Next _x1

	// RestArea(_aAreaSF4)
	// RestArea(_aAreaSB1)

	//FIM Ticket 8190 	  - Abel Babini      - 18/01/2021 - Alterar TES para cliente Simples Nacional para produtos carne 

	If !empty(_cPedAnt) .And. !lRet
		DbSelectArea("SC5")
		AjsAlt(_cPedAnt,_cPedold)
	Endif

	M->C5_FLAGFIN := ""
	
	// Ricardo Lima-19/02/2019-047354
	// Ricardo Lima-27/02/2019-047506
	IF Alltrim(cEmpAnt) $ cEmpSF .and. !IsInCallStack('u_PED001B')  //Chamado:048015 -Fernando Sigoli 21/03/2019
		IF M->C5_XTIPO = '2'
			if !Empty(M->C5_ROTEIRO)
				cQueryP := " SELECT C5_FILIAL, C5_NUM, C5_DTENTR, C5_ROTEIRO "
				cQueryP += " FROM "+RetSqlName("SC5")+" WITH (NOLOCK) "
				cQueryP += " WHERE C5_FILIAL = '"+FWxFilial("SC5")+"' AND C5_XTIPO = '2' "
				cQueryP += " AND C5_NOTA = '' AND C5_NUM <> '"+M->C5_NUM+"' "
				cQueryP += " AND C5_ROTEIRO = '"+M->C5_ROTEIRO+"' AND C5_DTENTR = '"+DtoS(M->C5_DTENTR)+"' "
				cQueryP += " AND D_E_L_E_T_ = ' ' "
				If Select("tSC5p") > 0
					DbSelectArea("tSC5p")
					tSC5p->(DbCloseArea())
				Endif
				TCQUERY cQueryP NEW ALIAS "tSC5p"
				
				If !Empty(tSC5p->C5_NUM)
					ApMsgInfo('Para Pedido do Tipo Diversos nï¿½o Pode Existir mais de um Pedido com o mesmo Roteiro e Data de Entrega, Altere a data de entrega ou o Roteiro','Pedido de Venda Diversos')
					lRet := .F.
				EndIf
			Endif
		ENDIF
	ENDIF

	RestArea(aArea)
	//Conout( DToC(Date()) + " " + Time() + " MT410TOK >>> FINAL PE" )
Return(lRet)

//--------------------------------------------------
// 1. Valida o cadastro de produtos.
//--------------------------------------------------
Static Function fVldProd()
  Local cEmpRN:= GetMv("MV_#RNEMP",,"01|02|") //Ticket 69574   - Abel Bab - 21/03/2022 - Projeto FAI

	// Validações feitas somente para a empresa 01 e 02.
	If Alltrim(cEmpAnt) $ cEmpRN
		
		If SF4->F4_ESTOQUE == "S"
			If Empty(SB1->B1_LOCPAD) .And. Empty(SBZ->BZ_LOCPAD)
				IF IsInCallStack('U_ADVEN002P')  == .T.
					Aadd(aPedidos,{cchave, ;
					''    , ;
					''    , ;
					''    , ;
					'"Produto '+Alltrim(_cProduto)+' sem LOCAL no cadastro de produtos. Produto nï¿½o pode ser utilizado!' ,;
					cVendedor})

				ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
					Aadd(aPedidos,{'"Produto '+Alltrim(_cProduto)+' sem LOCAL no cadastro de produtos. Produto nï¿½o pode ser utilizado!'})

				ELSE
					MsgInfo("Produto "+Alltrim(_cProduto)+" sem LOCAL no cadastro de produtos."+chr(13)+chr(13)+" Produto nï¿½o pode ser utilizado!")
				Endif

				lRet := .F.
			Endif
		Endif
	

		// INICIO WILLIAM COSTA 21/06/2019 CHAMADO 049973 || OS 051277 || FISCAL || VALERIA || 8389 || PEDIDO X FATURAMENTO
		IF  SB1->B1_CONV > 1 .AND. (ALLTRIM(SB1->B1_SEGUM) == '' .OR. ALLTRIM(_cSEGUM) == '')
			
			IF IsInCallStack('U_ADVEN002P')  == .T.
			
				Aadd(aPedidos,{cchave, ;
				''    , ;
				''    , ;
				''    , ;
				'"Produto '+Alltrim(_cProduto)+' Obrigatï¿½rio informar [Segunda Unidade de Medida] ' ,;
				cVendedor})

			ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
			
				Aadd(aPedidos,{'"Produto '+Alltrim(_cProduto)+' Obrigatï¿½rio informar [Segunda Unidade de Medida] '})

			ELSE
			
				MsgInfo("Produto "+Alltrim(_cProduto)+" Obrigatï¿½rio informar [Segunda Unidade de Medida] "+chr(13)+chr(13)+" Produto nï¿½o pode ser utilizado!")
				
			Endif                      
			
			lRet := .F.
			
		ENDIF
		
		IF SB1->B1_CONV = 0 .AND. (ALLTRIM(SB1->B1_SEGUM) <> '' .OR. !Empty(_cSEGUM))
			
			IF IsInCallStack('U_ADVEN002P')  == .T.
			
				Aadd(aPedidos,{cchave, ;
				''    , ;
				''    , ;
				''    , ;
				'"Produto '+Alltrim(_cProduto)+' Obrigatï¿½rio informar [Fator de Conversao] ' ,;
				cVendedor})

			ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
			
				Aadd(aPedidos,{'"Produto '+Alltrim(_cProduto)+' Obrigatï¿½rio informar [Fator de Conversao] '})

			ELSE
			
				MsgInfo("Produto "+Alltrim(_cProduto)+" Obrigatï¿½rio informar [Fator de Conversao] "+chr(13)+chr(13)+" Produto nï¿½o pode ser utilizado!")
				
			Endif                      
			
			lRet := .F.
			
		ENDIF
	
	Endif

return

//--------------------------------------------------
// 2. Valida o cadastro da UM.
//--------------------------------------------------
Static function fVldUM()

	dbselectArea("SAH")
	SAH->(dbSetOrder(1))
	SAH->(dbGoTop())
	
	If !SAH->(dbSeek(xFilial("SAH")+_cUM))
		IF IsInCallStack('U_ADVEN002P')  == .T.
			Aadd(aPedidos,{cchave, ;
			''    , ;
			''    , ;
			''    , ;
			"Unidade de medida do produto "+ALLTRIM(_CPRODUTO)+" nao existe. Favor verificar" ,;
			cVendedor})

		ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
			Aadd(aPedidos,{"Unidade de medida do produto "+ALLTRIM(_CPRODUTO)+" nao existe. Favor verificar"})

		ELSE

			ApMsgInfo(OemToAnsi("Unidade de medida do produto ")+ALLTRIM(_CPRODUTO)+" nao existe. Favor verificar")

		ENDIF

		lRet := .F.
	Endif
return

//--------------------------------------------------
// 3. Valida se o item controla localizaï¿½ï¿½o.
// @history Ticket  63807  - Leonardo P. Monteiro - 17/11/2021 - Validaï¿½ï¿½o do item que controla endereï¿½o para tornar obrigatï¿½rio o preenchimento do campo 'Localizaï¿½ï¿½o'.
//--------------------------------------------------
Static Function fVldLocaliz()
	IF SF4->F4_ESTOQUE == "S" .AND. _cLocaliz == "S"
		if Empty(ACOLS[_nX, _nLocaliz])

			cQuery := " SELECT BF_LOCALIZ FROM "+ RetSqlName("SBF") +" WITH (NOLOCK) WHERE D_E_L_E_T_='' AND BF_FILIAL='"+ xFilial("SBF") +"' AND BF_PRODUTO='"+ _cProduto +"' AND BF_LOCAL='"+ ACOLS[_nX, _nLocal] +"' AND BF_QUANT > 0; "
		
			TcQuery cQuery ALIAS "QBF" NEW

			if qbf->(!eof())
				ACOLS[_nX, _nLocaliz] := qbf->BF_LOCALIZ
			else

				IF IsInCallStack('U_ADVEN002P')  == .T.
					Aadd(aPedidos,{cchave, ;
					''    , ;
					''    , ;
					''    , ;
					'Produto '+Alltrim(_cProduto)+' nï¿½o tem a localizaï¿½ï¿½o informada na linha do item. Produto nï¿½o pode ser utilizado!' ,;
					cVendedor})

				ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
					Aadd(aPedidos,{'Produto '+Alltrim(_cProduto)+' nï¿½o tem a localizaï¿½ï¿½o informada na linha do item. Produto nï¿½o pode ser utilizado!'})
				else
					ApMsgInfo('Produto '+Alltrim(_cProduto)+' nï¿½o tem a localizaï¿½ï¿½o informada na linha do item. Produto nï¿½o pode ser utilizado!')
				endif

				lRet := .F.
			endif

			qbf->(dbclosearea())
			
			
		endif
	endif

return

//--------------------------------------------------
// 4. Tratamento integraï¿½ï¿½o eData
//--------------------------------------------------
Static Function fVldDat()
  Local cEmpRN:= GetMv("MV_#RNEMP",,"01|02|") //Ticket 69574   - Abel Bab - 21/03/2022 - Projeto FAI

	If Alltrim(cEmpAnt) $ cEmpRN   // Integração CERES
		
		If lRet
			
			//cTipo := SF4->F4_XTIPO

			If(!Empty(SF4->F4_XTIPO))
				//cLendo := cTipo // cLendo = variï¿½vel que recebera o valor do campo F4_XTIPO atual que esta lendo

				// Caso o tipo anterior lido seja diferente da que estiver lendo
				If ((nCount > 0) .AND. (SF4->F4_XTIPO <> cLido))// verifica se a variï¿½vel cLido que contem o valor do item anterior ï¿½ igual ao atual cLendo
					IF IsInCallStack('U_ADVEN002P')  == .T.
						Aadd(aPedidos,{cchave, ;
						''    , ;
						''    , ;
						''    , ;
						'Erro no processo de cadastro do Item, Existem valores no campo F4_XTIPO diferentes entre os itens.' ,;
						cVendedor})

					ELSEIF lSfInt //Everson - 25/09/2017. Chamado 037261.
						Aadd(aPedidos,{'Erro no processo de cadastro do Item, Existem valores no campo F4_XTIPO diferentes entre os itens.'})

					ELSE

						Aviso("Erro no processo de cadastro do Item","Existem valores no campo F4_XTIPO diferentes entre os itens.",{"OK"})

					ENDIF

					lRet := .F.
					
				Endif
				cLido  	:= SF4->F4_XTIPO
				nCount 	:= nCount + 1
			EndIf


			If(lRet)
				M->C5_XTIPO := cLido
			EndIf
		Endif
	EndIf
	

return

/*
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Í»ï¿½ï¿½
ï¿½ï¿½ï¿½Funï¿½ï¿½o    ï¿½ FTOTPV   ï¿½ Autor ï¿½ HCCONSYS           ï¿½ Data ï¿½  21/05/09   ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Í¹ï¿½ï¿½
ï¿½ï¿½ï¿½Desc.     ï¿½ Funï¿½ï¿½o para calculo de total de pedido de vendas e valida- ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½          ï¿½ ï¿½ï¿½es posteriores                                           ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Í¹ï¿½ï¿½
ï¿½ï¿½ï¿½Uso       ï¿½ Especï¿½fico A'DORO                                          ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Í¼ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
*/

Static Function fTotPV()

	Local cQuery 	  := ""
	Local nRet 	 	  := 0
	Local nTotIt 	  := Ascan( aHeader,{ |x| AllTrim(x[2]) == "C6_VALOR"})
	Local ccodprod    := Ascan( aHeader,{ |x| AllTrim(x[2]) == "C6_PRODUTO"})
	Local _cTESSTMG   := Ascan( aHeader,{ |x| AllTrim(x[2]) == "C6_TES"})

	Local _cParMG     := GETMV("MV_STTSMG")
	Local _cParRS     := GETMV("MV_STTSRS")
	Local _cParBonIf  := GETMV("MV_VMINTES")
	Local _cEst1     
	Local n1

	Local cEmpSF:= GetMv("MV_#SFEMP",,"01|") //Ticket 69574   - Abel Bab - 21/03/2022 - Projeto FAI

	If Alltrim(cEmpAnt) $ cEmpSF    //Incluido por Adriana devido ao error.log quando empresa <> 01 - chamado 032804

		If Len(aCols) > 0

			For n1 := 1 to Len(aCols)

				If aCols[n1,Len(aHeader)+1] == .F.

					nRet += aCols[n1,nTotIt]

					IF !__CUSERID $ GETMV("MV_#USULPE") //NECESSARIO PARA SANAR O ERRO DE ELEVAR O VALOR TOTAL DO PEDIDO CHAMADO 031535 - WILLIAM COSTA

						dbSelectArea("SB1")
						dbSetOrder(1)

						If dbSeek(xFilial("SB1")+aCols[n1,ccodprod],.t.)
							If SB1->B1_TIPO != "PA"
								nRet += 99999.99  // forca o valor do pedido em 99999.99
							EndIf
						EndIf

					ENDIF	 

					If M->C5_TIPO $ "B/D"
						_cEst1 := POSICIONE("SA2",1,xFilial("SA2")+M->C5_CLIENTE + M->C5_LOJACLI,"A2_EST")
					Else
						_cEst1 := POSICIONE("SA1",1,xFilial("SA1")+M->C5_CLIENTE + M->C5_LOJACLI,"A1_EST")
					EndIf

					If _cEst1 == "MG"
						If aCols[n1,_cTESSTMG] $ _cParMG
							nRet += 99999.99  //forca ultrapassar o valor minimo para TES de Substituicao contidas no parametro MV_STTSMG para os Estados de MG/RS.
						EndIf
					EndIf

					If _cEst1 == "RS"
						If aCols[n1,_cTESSTMG] $ _cParRS
							nRet += 99999.99  //forca ultrapassar o valor minimo para TES de Substituicao contidas no parametro MV_STTSMG para os Estados de MG/RS.
						EndIf
					EndIf

					If aCols[n1,_cTESSTMG] $ _cParBonif
						nRet += 99999.99  //forca ultrapassar o valor minimo para TES de Bonificacao contidas no parametro MV_VMINTES.
					EndIf

				EndIf

			Next n1

		EndIf

	Endif

Return(nRet)

//-----------------------------------------------------------|
//Verifica se o pedido de venda ï¿½ ordem , ja foi utilizado   | 
//Sigoli 10/03/2017 Chamado: 034029                          |
//-----------------------------------------------------------|
Static Function verificarpedido(cPedido)
	// Ricrado Lima - 15/01/18
	Local cNumPed := ""                  
	Local cQry 	  := "SELECT C5_NUM AS NUMPEDIDO FROM "+retSqlName("SC5")+" WITH (NOLOCK) WHERE C5_FILIAL = '" + xFilial("SC5") + "' AND C5_XPEDORD = '"+cPedido+"' AND D_E_L_E_T_ =' '"
	TcQuery cQry new alias "C5QRY" 

	dbSelectArea( "C5QRY" )
	dbGoTop()
	cNumPed:= C5QRY->NUMPEDIDO

	dbclosearea("C5QRY")

Return(cNumPed)

//Mauricio - Chamado 037330 - verifica se o numero do pedido informado existe.
Static Function fVerPed(cPedido)

	Local cNumPed := ""                  
	Local cQry    := "" 
	// Ricrado Lima - 15/01/18
	cQry := "SELECT C5_NUM AS NUMPEDIDO FROM "+retSqlName("SC5")+" WITH (NOLOCK) WHERE C5_FILIAL = '" + xFilial("SC5") + "' AND C5_NUM = '"+cPedido+"' AND D_E_L_E_T_ = ' ' "
	TcQuery cQry new alias "C5QRY" 

	dbSelectArea( "C5QRY" )
	dbGoTop()
	cNumPed:= C5QRY->NUMPEDIDO

	dbclosearea("C5QRY")

Return(cNumPed)

Static function fbscPed(cPedido,_lrfat)

	Local _nPVal := Ascan( aHeader,{ |x| AllTrim(x[2]) == "C6_VALOR"})
	Local _nPQtd := Ascan( aHeader,{ |x| AllTrim(x[2]) == "C6_QTDVEN"})
	Local _nProd := Ascan( aHeader,{ |x| AllTrim(x[2]) == "C6_PRODUTO"})             
	Local cQry   := ""
	Local _nx	 := 0
	Local _nT	 := 0
	Local _nz	 := 0

	// Ricrado Lima - 15/01/18
	cQry := "SELECT C5_XPEDGER FROM "+retSqlName("SC5")+" WITH (NOLOCK) WHERE C5_FILIAL = '" + xFilial("SC5") + "' AND C5_NUM = '"+cPedido+"' AND D_E_L_E_T_ = ' ' "
	TcQuery cQry new alias "TSC5" 

	dbSelectArea( "TSC5" )
	dbGoTop()
	If TSC5->(!Eof())
		_cPDFATS := TSC5->C5_XPEDGER    //pedidos refaturados vinculados ao pedido original
	Endif

	//Mauricio - tratamento para considerar o numero do pedido atual, retirado acima...
	IF inclui
		DbCloseArea("TSC5")

		_cPed1 := ""
		_cPed2 := ""
		_cPed3 := ""

		IF Len(Alltrim(_cPDFATS)) > 6  //tem mais de um pedido
			for _nx := 1 to len(Alltrim(_cPDFATS))   // maximo sï¿½o 3 pedidos
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

		if len(Alltrim(_cPDFATS)) > 14
			_lQuatro := .T.
		else
			If Empty(_cPed2)
				_cPed2 := _cPedAt
			Elseif Empty(_cPed3)
				_cPed3 := _cPedAt
			Endif
		Endif

	Elseif ALTERA
		IF _lrfat
			DbCloseArea("TSC5")

			_cPed1 := ""
			_cPed2 := ""
			_cPed3 := ""

			IF Len(Alltrim(_cPDFATS)) > 6  //tem mais de um pedido
				for _nx := 1 to len(Alltrim(_cPDFATS))   // maximo sï¿½o 3 pedidos
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

		Else
			DbCloseArea("TSC5")

			_cPed1 := ""
			_cPed2 := ""
			_cPed3 := ""

			IF Len(Alltrim(_cPedold)) > 6  //tem mais de um pedido
				for _nx := 1 to len(Alltrim(_cPedold))   // maximo sï¿½o 3 pedidos
					If _nx == 1
						_cPed1 := Substr(Alltrim(_cPedold),1,6)
						_nx := 7
					Elseif _nx == 8
						_cPed2 := Substr(Alltrim(_cPedold),8,6)
						_nx := 14
					elseif _nx == 15
						_cPed3 := Substr(Alltrim(_cPedold),15,6)
						_nx := 28
					Endif
				next _nx
			Else
				_cPed1 := Alltrim(_cPedold)
			Endif
		Endif
	Endif

	//Mauricio 20/10/2017
	If !Empty(_cPed3)
		_lTresPed := .T.     //Ja existem 3 pedidos do comercial colocados
	endif   

	//Busco o valor total e quantidade total do pedido atual posicionado
	_nTVLPDATU := 0
	_nTQTPDATU := 0
	For _nT := 1 to Len(aCols)
		If aCols[_nT,Len(aHeader)+1] == .F.                            
			_nTVLPDATU += aCols[_nT,_nPVal]
			_nTQTPDATU += aCols[_nT,_nPQtd]
		EndIf		
	Next _nT

	//Verifico a quantidade e valor do pedido original que esta sendo refaturado
	_nTVLPDOR := 0
	_nTQTPDOR := 0

	If Select("TSC6") > 0
		DbSelectArea("TSC6")
		DbCloseArea("TSC6")
	Endif

	//Soma quantidade e valor do pedido original
	//_cQuery  := "SELECT SUM(C6_QTDVEN) AS TOTQTD, SUM(C6_VALOR) AS TOTVLR  "
	//_cQuery  += "FROM "+RetSqlName("SC6")+" C6 "
	//_cQuery  += "WHERE C6.D_E_L_E_T_ <> '*' AND C6.C6_NUM = '"+cPedido+"'"   
	//_cQuery  += "AND C6.C6_FILIAL = '"+cfilAnt+"' "
	// Ricrado Lima - 15/01/18
	_cQuery  := "SELECT SUM(C6_QTDVEN) AS TOTQTD, SUM(C6_VALOR) AS TOTVLR "  
	_cQuery  += "FROM "+RetSqlName("SC6")+" C6 WITH (NOLOCK) " 
	_cQuery  += "WHERE C6.C6_FILIAL = '"+cfilAnt+"' AND C6.C6_NUM = '"+cPedido+"' "   
	_cQuery  += "AND C6.D_E_L_E_T_ = ' ' "

	TCQUERY _cQuery NEW ALIAS "TSC6"

	DbSelectArea("TSC6")
	TSC6->(dbgotop())
	_nTQTPDOR := TSC6->TOTQTD
	_nTVLPDOR := TSC6->TOTVLR

	DbCloseArea("TSC6")

	//Verifico agora o valor total e quantidade de todos os pedidos refaturados vinculados ao pedido original
	_nTVLPDAC := 0
	_nTQTPDAC := 0

	If _cPedAt == _cPed1
		_cIN := "'"+_cPed2+"','"+_cPed3+"'"
	Elseif _cPedAt == _cPed2
		_cIN := "'"+_cPed1+"','"+_cPed3+"'"
	Else
		_cIN := "'"+_cPed1+"','"+_cPed2+"'"
	Endif

	If Select("TSC6") > 0
		DbSelectArea("TSC6")
		DbCloseArea("TSC6")
	Endif
	// Ricrado Lima - 15/01/18	
	//Soma quantidade do pedido
	_cQuery  := "SELECT SUM(C6_QTDVEN) AS TOTQTD, SUM(C6_VALOR) AS TOTVLR  "
	_cQuery  += "FROM "+RetSqlName("SC6")+" C6 WITH (NOLOCK) "
	_cQuery  += "WHERE C6.C6_FILIAL = '"+cfilAnt+"' AND C6.C6_NUM IN("+_cIN+") "   
	_cQuery  += "AND C6.D_E_L_E_T_ <> '*' "
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
		// RICARDO LIMA - 15/01/18
		_cQuery  := "SELECT C6_PRODUTO, C6_QTDVEN "
		_cQuery  += "FROM "+RetSqlName("SC6")+" C6 WITH (NOLOCK) "
		_cQuery  += "WHERE C6.C6_FILIAL = '"+cfilAnt+"' AND C6.C6_NUM = '"+cPedido+"'"
		_cQuery  += "AND C6.D_E_L_E_T_ <> '*' "
		TCQUERY _cQuery NEW ALIAS "TSC6"

		DbSelectArea("TSC6")
		TSC6->(dbgotop())
		While TSC6->(!Eof())
			AADD(_aProdOR,{TSC6->C6_PRODUTO,TSC6->C6_QTDVEN})
			TSC6->(dbSkip())
		Enddo

		DbCloseArea("TSC6")

		//apuro todos os produtos e quantidades dos pedidos refaturados
		_aProdRFT := {}

		//pedido atual sendo alterado...	
		For _nT := 1 to Len(aCols) 		
			If aCols[_nT,Len(aHeader)+1] == .F.
				AADD(_aProdRFT,{aCols[_nT,_nProd],aCols[_nT,_nPQtd]})	                              		 
			EndIf		
		Next _nT

		If _cPedAt == _cPed1
			_cIN := "'"+_cPed2+"','"+_cPed3+"'"
		Elseif _cPedAt == _cPed2
			_cIN := "'"+_cPed1+"','"+_cPed3+"'"
		Else
			_cIN := "'"+_cPed1+"','"+_cPed2+"'"
		Endif

		If Select("TSC6") > 0
			DbSelectArea("TSC6")
			DbCloseArea("TSC6")
		Endif
		// RICRDO LIMA - 15/01/18
		_cQuery  := "SELECT C6_PRODUTO, C6_QTDVEN "
		_cQuery  += "FROM "+RetSqlName("SC6")+" C6 WITH (NOLOCK) "
		_cQuery  += "WHERE C6.C6_FILIAL = '"+cfilAnt+"' AND C6.C6_NUM IN("+_cIN+") "
		_cQuery  += "AND C6.D_E_L_E_T_ <> '*' "
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

	Else //nao eh faturamento

		//apuro todos os produtos e suas quantidades do pedido original
		_aProdOr := {}

		If Select("TSC6") > 0
			DbSelectArea("TSC6")
			DbCloseArea("TSC6")
		Endif
		// RICARDO LIMA - 15/01/18
		_cQuery  := "SELECT C6_PRODUTO, C6_QTDVEN "
		_cQuery  += "FROM "+RetSqlName("SC6")+" C6 WITH (NOLOCK) "
		_cQuery  += "WHERE C6.C6_FILIAL = '"+cfilAnt+"' AND C6.C6_NUM = '"+cPedido+"'"
		_cQuery  += "AND C6.D_E_L_E_T_ <> '*' "
		TCQUERY _cQuery NEW ALIAS "TSC6"

		DbSelectArea("TSC6")
		TSC6->(dbgotop())
		While TSC6->(!Eof())
			AADD(_aProdOR,{TSC6->C6_PRODUTO,TSC6->C6_QTDVEN})
			TSC6->(dbSkip())
		Enddo

		DbCloseArea("TSC6")

		//apuro todos os produtos e quantidades dos pedidos refaturados
		_aProdRFT := {}

		//pedido atual sendo alterado...	
		For _nT := 1 to Len(aCols)
			If aCols[_nT,Len(aHeader)+1] == .F.
				AADD(_aProdRFT,{aCols[_nT,_nProd],aCols[_nT,_nPQtd]})	                              		 
			EndIf		
		Next _nT

		If _cPedAt == _cPed1
			_cIN := "'"+_cPed2+"','"+_cPed3+"'"
		Elseif _cPedAt == _cPed2
			_cIN := "'"+_cPed1+"','"+_cPed3+"'"
		Else
			_cIN := "'"+_cPed1+"','"+_cPed2+"'"
		Endif   

		If Select("TSC6") > 0
			DbSelectArea("TSC6")
			DbCloseArea("TSC6")
		Endif		
		// RICARDO LIMA - 15/01/18
		_cQuery  := "SELECT C6_PRODUTO, C6_QTDVEN "
		_cQuery  += "FROM "+RetSqlName("SC6")+" C6 WITH (NOLOCK) "
		_cQuery  += "WHERE C6.C6_FILIAL = '"+cfilAnt+"' AND C6.C6_NUM IN("+_cIn+") "
		_cQuery  += "AND C6.D_E_L_E_T_ <> '*' "
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

Return()


Static Function bscPedAlt(cPedido)

	Local cNPed := ""                  
	Local cQry 	  := "SELECT C5_XREFATD FROM "+retSqlName("SC5")+" WITH (NOLOCK) WHERE C5_FILIAL = '" + xFilial("SC5") + "' AND C5_NUM = '"+cPedido+"' AND D_E_L_E_T_ =' '"
	TcQuery cQry new alias "C5QRY" 

	dbSelectArea( "C5QRY" )
	dbGoTop()
	cNPed:= C5QRY->C5_XREFATD

	dbclosearea("C5QRY")

Return(cNPed)

Static function AltPedOr(_cPedAnt,_cNumPed)
	Local _SC5cAlias := Alias()
	local _SC5cOrder := IndexOrd()
	Local _SC5cRecno := Recno()


	DbSetOrder(1)
	if dbseek(xFilial("SC5")+_cPedAnt)
		_cPedold := SC5->C5_XPEDGER
		If _cNumPed $ _cPedold
			_nPSUBS   := AT(_cNumPed,_cPedold)
			IF _nPSUBS == 1
				_cPedNew  := Substr(_cPedold,_nPSUBS + 7,Len(_cPedold))
			else   
				_cPedNew  := Substr(_cPedold,1,_nPSUBS - 2)+Substr(_cPedold,_nPSUBS + 6,Len(_cPedold))
			endif   
			RecLock("SC5",.F.)
			SC5->C5_XPEDGER := _cPedNew  //somente limpo, nao gravo atual. Gravacao eh por outro ponto de entrada
			SC5->(MsUnlock())
		Endif
	endif

	dbSelectArea(_SC5cAlias)
	dbSetOrder(_SC5cOrder)
	dbGoto(_SC5cRecno)

Return()

Static function AjsAlt(_cPedAnt,_cPedold)
	_SC5cAlias := Alias()
	_SC5cOrder := IndexOrd()
	_SC5cRecno := Recno()

	DbSetOrder(1)
	if dbseek(xFilial("SC5")+_cPedAnt)   
		RecLock("SC5",.F.)
		SC5->C5_XPEDGER := _cPedold  //como nï¿½o confirmou alteraï¿½ï¿½o volto condiï¿½ï¿½o anterior
		SC5->(MsUnlock())   
	endif

	dbSelectArea(_SC5cAlias)
	dbSetOrder(_SC5cOrder)
	dbGoto(_SC5cRecno)

Return()


//valida quantidade de pedido
Static Function ValQtdEst (cPedido)

	Local cQrty 	:= "" 
	Local lRet      := .T.

	/* cQrty := " SELECT  SUM(C6_UNSVEN) AS CXTOTAL, A1_EST AS ESTADO "
	cQrty += " FROM "+RetSqlName("SC6")+" SC6 INNER JOIN "+RetSqlName("SA1")+" SA1 " 
	cQrty += " ON SC6.C6_CLI = SA1.A1_COD AND SC6.C6_LOJA  = SA1.A1_LOJA "
	cQrty += " WHERE SC6.D_E_L_E_T_ <> '*' " 
	cQrty += " AND SA1.D_E_L_E_T_ <> '*' "
	cQrty += " AND  SC6.C6_NUM = '"+cPedido+"'"   
	cQrty += " AND SC6.C6_FILIAL = '"+cfilAnt+"'"
	cQrty += " GROUP BY A1_EST " */

	cQrty := " SELECT SUM(C6_UNSVEN) AS CXTOTAL, A1_EST AS ESTADO " 
	cQrty += " FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
	cQrty += " INNER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON A1_FILIAL = ' ' AND SC6.C6_CLI = SA1.A1_COD AND SC6.C6_LOJA  = SA1.A1_LOJA "
	cQrty += " WHERE SC6.C6_FILIAL = '"+cfilAnt+"' "
	cQrty += " AND  SC6.C6_NUM = '"+cPedido+"' "
	cQrty += " AND SC6.D_E_L_E_T_ = ' ' "
	cQrty += " AND SA1.D_E_L_E_T_ = ' ' "
	cQrty += " GROUP BY A1_EST "

	TCQUERY cQrty NEW ALIAS "TEMPEST"

	DbSelectArea("TEMPEST")
	TEMPEST->(dbgotop())

	If TEMPEST->CXTOTAL < GetMV("MV_#QTDREF") .and. TEMPEST->ESTADO = 'SP'
		lRet := .F.
	EndIf

	DbCloseArea("TEMPEST")

Return lRet

/*{Protheus.doc} User Function diasEntrega
	Funï¿½ï¿½o para retornar o dias de entrega - Chamado 037426
	@type  Static Function
	@author Everson
	@since 19/12/2017 
	@version 01
*/

Static Function diasEntrega() // U_diasEntrega()

	//ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ä¿
	//ï¿½ Declaracao de Variaveis                                             ï¿½
	//ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½	
	Local aArea	:= GetArea()
	Local nDias := 0
	Local nDSem := DoW(dDataBase)
	Local nDiasP:= GetMV("MV_XDIASEN")
	Local cDias := Alltrim(cValToChar(GetMv("MV_#DIASEN",,"")))
	Local aDias := {}

	//
	If Empty(cDias)
		RestArea(aArea)
		nDias := nDiasP
		Return nDias

	EndIf

	//
	aDias := StrToKarr(cDias,"/")
	nDias := Val(cValToChar(aDias[nDSem]))

	//
	RestArea(aArea)

Return nDias

/*{Protheus.doc} User Function TrazN57608
	Consulta se cliente se enquadra no Regime especial 57608/2011 - Ticket 692
	@type  Static Function
	@author Adriana Oliveira
	@since 03/09/2020
	@version 01
*/

User Function TrazN57608(_cCliente, _cLoja, _dData)

	Local _cAliasZG4 	:= GetNextAlias() 
	Local _cN57608		:= ""


	BeginSql Alias _cAliasZG4
		
		SELECT ZG4_NUMERO
		
		FROM %table:ZG4% ZG4 (NOLOCK)
		
		WHERE ZG4_CODIGO = %Exp:_cCliente%
			AND ZG4_LOJA = %Exp:_cLoja%
			AND ZG4_DTINI <= %Exp:DTOS(_dData)% 
			AND ZG4.%notDel%
	
	EndSql                      
	
	DbSelectArea(_cAliasZG4)
		
	If (_cAliasZG4)->(! EOF())
		_cN57608:= (_cAliasZG4)->ZG4_NUMERO
	EndIf                      
	
	(_cAliasZG4)->(DbCloseArea())

	Return _cN57608

/*{Protheus.doc} Static Function Embutido
	Consulta se cliente se enquadra no Regime especial 57608/2011 - Ticket 692
	@type  Static Function
	@author Adriana Oliveira
	@since 03/09/2020
	@version 01
*/

Static Function Embutido								

	Local _cAliasSB1 	:= GetNextAlias() 
	Local _lEmbutido	:= .f.

	BeginSql Alias _cAliasSB1
		
		SELECT B1_PICMRET
		
		FROM %table:SB1% SB1 (NOLOCK)
		
		WHERE B1_COD = %Exp:_cProduto%
			AND SB1.%notDel%
	
	EndSql                      
	
	DbSelectArea(_cAliasSB1)
		
	If (_cAliasSB1)->(! EOF()) .and. (_cAliasSB1)->B1_PICMRET > 0
		_lEmbutido:= .t.
	EndIf                      
	
	(_cAliasSB1)->(DbCloseArea())

	Return _lEmbutido
