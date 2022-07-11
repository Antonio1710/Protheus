#include 'rwmake.ch'
#include 'protheus.ch'
#Include "Topconn.ch"
#Define STR_LF Chr(13)+ Chr(10)

/*{Protheus.doc} User Function MT100LOK
	Validacaoo da conta contabil e centro de custo atraves da TES. Se movimentar estoque (F4_ESTOQUE), pegar conta contabil (B1_CONTA) e obrigatorio centro de custo (D1_CC)
	@type  Function
	@author Wellington Santos
	@since 23/01/2007
	@version 01
	@history Chamado 020480 - Luciano Mafra   - 26/09/2014 - Sem detalhamento
	@history Chamado 045702 - Everson         - 11/12/2018 - Adicionada condicao para que o produto nao seja validado com saldo do projeto quando nao gerar financeiro
	@history Chamado 045889 - Everson         - 18/12/2018 - Adicionado parametro para conter os grupos de produtos que passam por validacao de quantidade (PC x NF)
	@history Chamado 045963 - William Costa   - 19/12/2018 - Adicionado a funcao IsInCallStack("U_CENTNFEXM") para poder entrar na regra quando vier tambem da central XML, erro encontrado pelo Dejaime.
	@history Chamado 045963 - FWNM            - 20/12/2018 - Valida saldo projeto investimentos somente se no item da NF nao existir PC
	@history Chamado 046284 - FWNM            - 08/01/2019 - Novas regras alteracao valor
	@history Chamado 046145 - William Costa   - 09/01/2019 - Adicionado tolerancia quantidade produtos do grupo 9028 (cozinha)
	@history Chamado 047371 - Ricardo Lima    - 20/02/2019 - Valida codigo de projeto do PC com o informado na NF e nao permite que seja diferente
	@history Chamado TI     - Ricardo Lima    - 25/02/2019 - Nao permite projeto e PC sem projeto informado
	@history Chamado 047433 - Ricardo Lima    - 22/02/2019 - Valida valores na entrada de NF, verifica valor total de nota com PC
	@history Chamado 047555 - Ricardo Lima    - 27/02/2019 - Valida excecao a regra de entrada de NF, verifica valor total de nota com PC
	@history Chamado 047563 - Ricardo Lima    - 27/02/2019 - Ajusta na busca do projeto
	@history Chamado TI     - Fernando Sigoli - 01/03/2019 - Tratamento para nao validar deletado
	@history Chamado TI     - Everson         - 01/03/2019 - Nao validar integracao SAG quanto a PC e apenas validar NF entrada normal
	@history Chamado 047632 - William         - 04/03/2019 - Alteracao na regra de vigencia de data para o projeto na entrada de NF   
	@history Chamado 047734 - William         - 11/03/2019 - Alteracao na hora de deixar entrar nota com valor a maior quando for grupo 9028 (Cozinha)
	@history Chamado 047734 - Fernando Sigoli - 12/03/2019 - Adicionado regra para tratar 10% no valor, grupo de produtos embalagens
	@history Chamado 047620 - Everson         - 13/03/2019 - Validacao de nota de complemento
	@history Chamado 047820 - Fernando Sigoli - 14/03/2019 - Adicionado mensagem para bloquear para tratamento e validacao dos demais grupos
	@history Chamado 047936 - Fernando Sigoli - 18/03/2019 - Adicionado mensagem para bloquear confirmacao da nota, quando a mesma existe pedido de compra e o item do pedido de compra esta vazio
	@history Chamado 047931 - FWNM            - 19/03/2019 - Centro de Custo x Lote Recria - RNX2
	@history Chamado 048414 - FWNM            - 10/04/2019 - Notas x Lote Recria - RNX2
	@history Chamado 048477 - FWNM            - 10/04/2019 - Complemento de Preco
	@history Chamado 047918 - William Costa   - 22/07/2019 - Ajuste no calculo para descobrir os valores e quantidades corretas para notas com complementos identificando se o pedido tem saldo para poder gerar a nota
	@history Chamado TI     - Abel Babini     - 27/08/2019 - Incluido condicao para excluir CTE sem precisar validar PC
	@history Chamado 051728 - William Costa   - 13/09/2019 - Nao deixar continuar se o campo D1_OP estiver preenchido e a TES nao controla estoque
	@history Chamado 051888 - FWNM            - 09/10/2019 - Relatorio Investimentos
	@history Chamado 052816 - FWNM            - 22/10/2019 - Controle Projetos
	@history Chamado 053636 - Abel Babini     - 10/01/2020 - Validação Entrada
	@history Chamado 053636 - Everson         - 16/01/2020 - Tratamento para rotina de entrada automática de CT-e (ADFIS032P)
	@history Chamado 055243 - Abel Babini     - 24/01/2020 - Ajuste na validação dos valores de saldo do Projeto MT100LOK-09 
	@history Chamado 056271 - Abel Babini	   - 02/03/2020 - Ajuste na regra de comparação de valores entre NF e Pedido. Estava comparando o valor unitario do pedido com o total da nota
	@history Chamado 057002 - FWNM	          - 31/03/2020 - || OS 058479 || CONTROLADORIA || MONIK_MACEDO || 996108893 || CONTABILIZACAO
	@history Chamado 057598 - Adriana Oliveira- 03/06/2020 - Correcao na validacao de valor entre PC X NF - em outras moedas e revisao trecho 
	@history Chamado TI     - Adriana Oliveira- 03/06/2020 - Retirar a validacao de TES por que a pre-nota ja esta trazendo TES preenchida (Solicitacao Fernando Sigoli)
	@history CHAMADO 058766 - 15/06/2020      - ADRIANO SAVOINE - Retirado o If que havia nesse ponto para nao validar na empresa Ceres
	@history Chamado T.I    - FERNANDO SIGOLI - 03/07/2020 - Projeto manutenção de ativo, ajustado regra para validar Ops somente de controle de estoque/custos
	@history Ticket 358     - FWNM            - 21/08/2020 - Implementação para diferenciar complemento de ICMS Próprio e ST nos projetos de investimentos
	@history Chamdo T.I.    - Everson         - 31/03/2021 - Alterada trava de complemento de preço e quantidade.
	@history Ticket 65109   - Abel Babini			- 13/12/2021 - Ajuste na query, na clausula INNER JOIN, de F1_LOJA para D1_LOJA e acrescentando o campo FILIAL.
	@history Ticket 68971   - Fer Macieira	  - 02/03/2022 - Integração Notas Centro de Custo 5134 - Item 113
	@history ticket 71057   - Fer Macieira    - 08/04/2022 - Item contábil Lançamentos da Filial 0B - Itapira
	@history ticket 74027   - TI              - 22/06/2022 - Pedido de Compra e Documento de Entrada CC 5318 - Item 111
	@history ticket 76269   - TI              - 11/07/2022 - Erro Doc de Entrada DEVOLUCAO
/*/ 
User Function MT100LOK

	Local _lOk 		:= .T.
	Local _aArea	:=GetArea()
	Local _nPosCta := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_CONTA"		})
	Local _nPosCC  := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_CC"	 		})
	Local _nPosCLVL:= aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_CLVL" 		})
	Local _nPosTes := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_TES" 		})
	Local _nPCOD   := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_COD" 		})
	Local _nPTES   := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_TES" 		})
	Local _nPCONTA := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_CONTA" 	    })
	Local _nPCC    := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_CC" 	    	})
	Local _nNFORI  := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_NFORI" 	    })
	Local _nSERIE  := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_SERIE" 	    })
	Local _nFORNE  := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_FORNECE" 	})
	Local _nLOJA   := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_LOJA" 		})
	Local _nCOD    := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_COD" 		})
	Local _nPITCTA := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_ITEMCTA" 	})
	Local _nRateio := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_RATEIO" 	    })
	Local _nPosLoc := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_LOCAL"	    })
	
	Local _nCQUANT := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_QUANT"		})
	Local _nCVLUNI := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_VUNIT" 		})
	Local _nCTOTAL := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_TOTAL"		})
	Local _nCPEDID := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_PEDIDO"		})
	Local _nCITEMP := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_ITEMPC"		})
	
	// Luciano 26/09/2014
	Local _nNFPR  := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_NFRURAL"      })  // NF DO PRODUTOR RURAL
	Local _nSRPR  := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_SRRURAL"	    })  // SÉRIE DA NF DO PRDUTOR RURAL
	//
	
	// William Costa 13/09/2017 chamado
	Local _nCf      := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_CF"      })
	Local _nNfFilOr := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_FILNFOR" })
	Local _nNfOrdem := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_NFORDEM" })
	Local _nSeriOrd := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_SERIORD" })
	Local _nItemOrd := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_ITEMORD" })
	Local _nForOrde := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_FORORDE" })
	Local _nLojaOrd := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_LOJAORD" })
	Local _nUM      := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_UM" })
	
	Local cTipoNF   := cTipo 	//Everson - 01/03/2019. Chamado T.I.
	Local cMsgErro  := "" 		//Everson - 13/03/2019. Chamado 047620.
	Local nSerOri   := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_SERIORI"})
	
	Local cCCBloq	:= Alltrim(GetMV("ZZ_CCTES"))

	//Chamado 053636 - Abel Babini     - 10/01/2020 - Validação Entrada
	Local cCCProd	:= '' //Centros de Custo Produtivos

	// FWNM - 29/12/2017 - Projetos Investimentos
	Local nTt      := 0
	Local nDesc    := 0
	Local nTtPrj   := 0

	Local lSldAtv  := GetMV("MV_#PRJSLD",,".T.")
	Local cFasePrj := GetMV("MV_PRJINIC",,"05")

	// Chamado n. 046284
	Local cFaseRej := GetMV("MV_#FASREJ",,"01")
	Local cFaseApr := GetMV("MV_#FASEOK",,"03")
	//  
	
	Local lGeraFin := .T. //Everson - 11/12/2018. Chamado 045702.
	Local lICMSPro := .F. //@history Ticket 358     - FWNM            - 21/08/2020 - Implementação para diferenciar complemento de ICMS Próprio e ST nos projetos de investimentos

	Local cGrupos  := Alltrim(cValToChar(GetMv("MV_#TOLQTD",,""))) //Everson - 18/12/2018. Chamado 045889.

	// por Adriana em 03/06/2020 - chamado 057598
	Local cErroVUn := ""
	Local cErroQtd := ""
	Local cErroTot := ""
	Local nVlrDlr  := 0 
	Local cSimbMoe := "R$"
	//
	
	// Ricardo Lima-20/02/2019-047371
	Local nPOSPROJ := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_PROJETO" })
	// Ricardo Lima-22/02/2019-047433
	Local nPc1     := 0
	Local nPc2     := 0
	Local cCodpcnf := ''
	Local cItepcnf := ''
	Local nVlrttnf := 0
	Local nVlrnflc := 0
	Local nPrcPed  := 0
	Local nTotPed  := 0
	Local nPOSOP   := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_OP" })
 
 	//Para Central XML (Conhecimento de Transporte) - Nao validar nesse momento  //fernando sigoli 15/03/2017
	//If IsInCallStack( "U_CEXMCONTR" ) //Ch.051294 - 27/08/2019 - Abel Babini Filho - Incluido condição para excluir CTE sem precisar validar Pedido de Compra
	If IsInCallStack( "U_CEXMCONTR" ) .OR. IsInCallStack( "U_RECNFECTE" ) //Ch.051294 - 27/08/2019 - Abel Babini Filho - Incluido condição para excluir CTE sem precisar validar Pedido de Compra
		Return .T.
	EndIf
	
	_nCota := 0 //incluido por Adriana em 07/07/2016
	_Rotina := IsInCallStack("U_IntNFEB")
	
	If Alltrim(ProcName(13)) == "MAWNDBROWSE" // NAO EXECUTA O PONTO PARA RETORNO DE NF
		Return(_lOk)
	Endif
	
	
	//fernando Sigoli 27/02/2019
	//Ricardo Lima-27/02/2019
	If M->F1_TIPO == 'D' .OR. SF1->F1_TIPO == 'D' .OR. ( !Empty(SF1->F1_CODIGEN) .AND. !Empty(SF1->F1_NOTASAG) ) .OR. ( !Empty(M->F1_CODIGEN) .AND. !Empty(M->F1_NOTASAG) )
		RestArea(_aArea)
		Return( _lOk )
	EndIf
	
	dbSelectArea('SB1')
	dbSetOrder(1)
	dbSeek( xFilial() + aCols[n][_nPCOD] )
	
	dbSelectAreA('SF4')
	dbSetOrder(1)
	dbSeek( XFilial() + aCols[n][_nPTES] )
	
	// Condicao acrescentada por HCCONSYS em 02/02/09 para nao permitir que sejam utilizadas TES que NAO controlem Estoque para os
	// Centro de Custos Informados em ZZ_CCTES
	If Alltrim(aCols[n,_nPosCC]) $ cCCBloq .AND. SF4->F4_ESTOQUE == 'N'
		MsgInfo("Centro de Custos nao permitido para TES informada. Verifique!!")
		_lOk := .F.
	Endif

	//Chamado 053636 - Abel Babini     - 10/01/2020 - Validação Entrada
	/*
	053636 || OS 055009 || FISCAL || DEJAIME || 8921 || VALIDACAO ENTRADA
	TUDO QUE FOR CENTRO DE CUSTO PRODUTIVO DEVERA COMPARAR COM A TES OS CAMPOS NAS CONFIGURAÇÕES 
	F4_PISCOF = AMBOS E F4_PISCRED = CREDITA E F4_DUPLIC = SIM.
	SE O CENTRO DE CUSTO FOR PRODUTIVO E A TES NO LANCAMENTO ESTIVER COM A CONFIGURAÇAO DIFERENTE 
	CITADO ACIMA GERAR UMA MENSAGEM DE INCONSISTENCIA NA TELA DO USUARIO.
	A VALIDAÇÃO TAMBEM DEVE OCORRER OPOSTAMENTE, SENDO QUE SE O C.C NÃO FOR PRODUTIVO E AS 
	CONFIGURAÇÕES DA TES ESTIVER IGUAIS ACIMA A MENSAGEM TAMBEM OCORRERÁ COM TES INVALIDA.
	VERIFICAR COM DANIELE CONTROLADORIA OS C.C PRODUTIVOS AS QUAIS ELA CRIOU UM PARAMETRO ESPECIFICO.
	*/
	
	IF CEMPANT = '01' //regra valida apenas para a empresa 01- Adoro
	
		If _lOk .AND. Alltrim(aCols[n][_nPosTes]) <> ''
			cCCProd	:= VerCCPrd() //Carrega Centro de Custos Produtivos
			IF	Alltrim(aCols[n,_nPosCC]) $ cCCProd //É CENTRO DE CUSTO PRODUTIVO
				IF (SF4->F4_DUPLIC != 'S' .AND.; //DIF SIM
					SF4->F4_PISCOF != '3' .AND.; //DIF AMBOS
					SF4->F4_PISCRED !='1') .And. ; //DIF CREDITA
					! isInCallStack("U_ADFIS032P") //Everson - 16/01/2020. Chamado 053636.
					//EXIBE MENSAGEM DE ERRO
					//Conforme chamado 053636 OS.056374, APENAS exibir mensagem, mas não bloquear.
					//_lOK := .f. 					
					Aviso(	"MT100LOK-10",;
							"Centro de Custo: " + Alltrim(aCols[n,_nPosCC]) + "." + Chr(13) + Chr(10) +;
							"TES: " + Alltrim(aCols[n][_nPosTes]) + ". Produto: " + Alltrim(aCols[n][_nPCOD]) + "." + Chr(13) + Chr(10) +;
							"Centro de Custo Produtivo obriga TES que " + Chr(13) + Chr(10) +;
							"Gera Duplicata e Credita Pis e Cofins!",;
							{ "&Retorna" },,;
							"Conteúdo em Branco" )
				ENDIF
			ELSEIF !Alltrim(aCols[n,_nPosCC]) $ cCCProd //NÃO É CENTRO DE CUSTO PRODUTIVO
				IF (SF4->F4_DUPLIC == 'S' .AND.; //SIM
					SF4->F4_PISCOF == '3' .AND.; //AMBOS
					SF4->F4_PISCRED =='1').And.; //CREDITA
					! isInCallStack("U_ADFIS032P") //Everson - 16/01/2020. Chamado 053636.
					//EXIBE MENSAGEM DE ERRO
					Aviso(	"MT100LOK-11",;
							"Centro de Custo: " + Alltrim(aCols[n,_nPosCC]) + "." + Chr(13) + Chr(10) +;
							"TES: " + Alltrim(aCols[n][_nPosTes]) + ". Produto: " + Alltrim(aCols[n][_nPCOD]) + "." + Chr(13) + Chr(10) +;
							"Centro de Custo NÃO Produtivo não pode utilizar" + Chr(13) + Chr(10) +;
							"TES que Gera Duplicata e Credita Pis e Cofins!",;
							{ "&Retorna" },,;
							"Conteúdo em Branco" )
				ENDIF
			ENDIF
		Endif
	
	ENDIF	
	//Fim Chamado 053636 - Abel Babini     - 10/01/2020 - Validação Entrada

	// *** INICIO WILLIAM COSTA 13/09/2019 - CHAMADO 051728 || OS 053055 || CONTROLADORIA || ANDRESSA || 45978437 || OPS - NAO DEIXAR CONTINUAR SE O CAMPO D1_OP ESTA PREENCHIDO E A TES NÃO CONTROLA ESTOQUE   	
	If Alltrim(Posicione("SC2",1,xFilial("SC2")+ALLTRIM(aCols[n,nPOSOP]),"C2_BATROT")) $ 'MATA650|ADFIS005P|ADEDA007R' //Chamado T.I - 03/07/2020 - Controle de OP por rotinas do estoque 
	
		If ALLTRIM(aCols[n,nPOSOP]) <> '' .AND. SF4->F4_ESTOQUE == 'N' 
	
			MSGINFO("Nota Fiscal com Ordem de Producao e a TES nao controla estoque. Não é permitido, verifique!!", 'MT100LOK-01')
			_lOk := .F.
	
		Endif
				
	EndIf
	// *** FINAL WILLIAM COSTA 13/09/2019 - CHAMADO 051728 || OS 053055 || CONTROLADORIA || ANDRESSA || 45978437 || OPS - NAO DEIXAR CONTINUAR SE O CAMPO D1_OP ESTA PREENCHIDO E A TES NÃO CONTROLA ESTOQUE   	
	
	//Everson - 13/03/2019. Chamado 047620. Validação de nota de complemento.
	If _lOK .And. cTipoNF == "C" .And. Alltrim(cValToChar(cTpCompl)) $("1|2") .And. aCols[n] [Len(aHeader) + 1] == .F. .And. ! IsInCallStack( "U_IntNFEB" )
		   //ChkCompl(cTpCompl, cMsgErro,cDocO,cSerieO,cFornece,cLoja,cProduto,nQtd,nVlrTot)		   
		If ! ChkCompl(cTpCompl,@cMsgErro,aCols[n][_nNFORI],aCols[n][nSerOri],cA100For,cLoja,aCols[n][_nPCOD],aCols[n][_nCQUANT],aCols[n][_nCTOTAL],aCols[n][_nCPEDID],aCols[n][_nCITEMP])
		
			ApMsgInfo(cMsgErro,'Função MT100LOK')
			_lOk := .F.	
				
		EndIf
		
	EndIf
	
	If !aCols[n][Len(aHeader)+1]	.AND. _lOK		// Verifica se Item nao foi apagado
		
		//------------------------- Resumo de Validacao Processo de Rateio por Centro de Custo - em: 27-março-2007 ----------------------//
		// Conforme Validação do Sr. Eduardo (TI) e Sr. "G"(Controladoria)
		// Sempre será OBRIGATARIO O CENTRO DE CUSTO PARA CONTA CONTABIL COMECANDO COM "3"
		//-------------------------------------------------------------------------------------------------------------------------------//
		
		
		If (SubStr(aCols[n][_nPConta],1,1) = '3' ) .and.;
			( Empty(Alltrim(aCols[n][_nPCC])) .Or. aCols[n][_nPCC]="" .Or. Len(Alltrim(aCols[n][_nPCC]))=0 .Or. aCols[n][_nPCC]=Space(09) ) .And. ;
			aCols[n][_nRateio]<>"1"  .AND. !('LEXML' $ ALLTRIM(FUNNAME()))
			//aCols[n][_nRateio]<>"1"  .AND. ALLTRIM(FUNNAME()) <> "U_LEXML" .AND. ALLTRIM(FUNNAME()) <> "U_LEXMLSC"
			
			_lOk := .F.
			_cProd := Trim(SB1->B1_COD) + '-' + Trim(SB1->B1_DESC)
			MsgBox( 'Informe o Centro de Custo - Campo Obrigatório para Conta Ctbil começando com 3 # Verifique!', _cProd )
			
		Endif
		
		xItemFil  := GetMV("MV_ITEMFIL")
		
		If !Empty(Alltrim(xItemFil)) .And. aCols[n][_nRateio]<>"1"       //-- (  aCols[n][_nRateio]=="2" .Or. aCols[n][_nRateio]="" .Or. Empty(Alltrim(aCols[n][_nRateio]))  )
			If .Not. Alltrim(aCols[n][_nPITCTA]) $ xItemFil .AND. !('LEXML' $ ALLTRIM(FUNNAME()))
				//	If .Not. Alltrim(aCols[n][_nPITCTA]) $ xItemFil .AND. ALLTRIM(FUNNAME()) <> "U_LEXML" .AND. ALLTRIM(FUNNAME()) <> "U_LEXMLSC"
				_lOk := .F.
				Msgbox("Favor acertar o Item de Conta Contábil, pois este não corresponde a Filial usada = " + Alltrim(SM0->M0_FILIAL) + " - " + Alltrim(SM0->M0_CODFIL), "Atenção")
			Endif
		Endif
		
		If aCols[n][_nRateio]<>"1"
			If  (Empty(aCols[n][_nPConta])  .Or. Empty(aCols[n][_nPITCTA])) .AND. !('LEXML' $ ALLTRIM(FUNNAME()))
				//If  (Empty(aCols[n][_nPConta])  .Or. Empty(aCols[n][_nPITCTA])) .AND. ALLTRIM(FUNNAME()) <> "U_LEXML" .AND. ALLTRIM(FUNNAME()) <> "U_LEXMLSC"
				_cProd := Trim(SB1->B1_COD) + '-' + Trim(SB1->B1_DESC)
				MsgBox( 'Informe a Conta Contábil e Item Contábil - Campos Obrigatório se o Item da NFE não foi Rateado - Verifique!', _cProd )
				_lOk := .F.
			EndIf
			
		Elseif  aCols[n][_nRateio]=="1"  // Rateio igual a SIM; Emite MSG e Limpa Campos
			
			If .Not. Empty(aCols[n][_nPConta] )   .Or.  .Not. Empty(aCols[n][_nPITCTA] )  .Or.  .Not.   Empty(aCols[n][_nPCC] );
				.AND. !('LEXML' $ ALLTRIM(FUNNAME()))
				//.AND. ALLTRIM(FUNNAME()) <> "U_LEXML" .AND. ALLTRIM(FUNNAME()) <> "U_LEXMLSC"
				
				_cProd := Trim(SB1->B1_COD) + '-' + Trim(SB1->B1_DESC)
				
				MsgBox( 'Favor NÃO lançar a Cta Ctbil, Item Ctbil ou Centro de Custo, pois esses Campos não podem estar preenchidos se o Item da NFE foi Rateado - Verifique!', _cProd )
				_lOk := .F.
				
			EndIf
			aCols[n][_nPCONTA]:=""
			aCols[n][_nPITCTA]:=""
			aCols[n][_nPCC]:=""
			
		Endif
		
		dbSelectArea('SB1')
		dbSetOrder(1)
		dbSeek( xFilial() + aCols[n][_nPCOD] )
		
		If AllTrim(cTipo) <> "D" // @history ticket 76269   - TI              - 11/07/2022 - Erro Doc de Entrada
			If Alltrim(aCols[n, _nPosCta])!= Alltrim(SB1->B1_CONTA) .AND.;		// Validacao da conta contabil - Everaldo Casaroli
				Alltrim(aCols[n, _nPosCta])!= Alltrim(SB1->B1_CONTAR).AND.;
				Alltrim(aCols[n, _nPosCta])!= Alltrim(SB1->B1_CONTAA) .And. !('LEXML' $ ALLTRIM(FUNNAME()))
				//Alltrim(aCols[n, _nPosCta])!= Alltrim(SB1->B1_CONTAA) .And. ALLTRIM(FUNNAME()) <> "U_LEXML" .AND. ALLTRIM(FUNNAME()) <> "U_LEXMLSC"
				MSGSTOP( "A Conta Contábil: " + Alltrim(aCols[n, _nPosCta]) + " informada, não existe no cadastro do Produto, digite novamente o TES para que a conta seja atualizada.", "ATENÇÃO !", "ALERT")
				_lOK := .F.
			Endif
		EndIf

		//Faz a validacao do almoxarifado - Everaldo Casaroli em 30/10/2008
		dbSelectAreA('SF4')
		dbSetOrder(1)
		dbSeek( XFilial('SF4') + aCols[n][_nPosTes] )
		
		
		//Everaldo Casaroli 02/07/2008
		dbSelectAreA('SF4')
		dbSetOrder(1)
		dbSeek( XFilial('SF4') + aCols[n][_nPTES] )

		//Everson - 11/12/2018. Chamado 045702.
		lGeraFin := .T.
		If Alltrim(SF4->F4_DUPLIC) == "N"
			lGeraFin := .F.
		EndIf
		//

		//@history Ticket 358     - FWNM            - 21/08/2020 - Implementação para diferenciar complemento de ICMS Próprio e ST nos projetos de investimentos

		/*
		{'F1_TIPO=="N"'		,'DISABLE'   		},;	// NF Normal
		{'F1_TIPO=="P"'		,'BR_AZUL'   		},;	// NF de Compl. IPI
		{'F1_TIPO=="I"'		,'BR_MARROM' 	},;	// NF de Compl. ICMS
		{'F1_TIPO=="C"'		,'BR_PINK'   		},;	// NF de Compl. Preco/Frete
		{'F1_TIPO=="B"'		,'BR_CINZA'  		},;	// NF de Beneficiamento
		{'F1_TIPO=="D"'		,'BR_AMARELO'	} }	// NF de Devolucao
		*/

		lICMSPro := .F. 
		If Alltrim(SF4->F4_INCSOL) == "N" .and. AllTrim(cTipo) == "I"
			lICMSPro := .T. 
		EndIf

		//
		
		//Verifica se o valor do pedido está menor ou igual ao valor da entrada - Josias - 07/06/2013 - Chamado ( sem chamado )
		If ALLTRIM(FUNNAME()) = "MATA103"  .OR. IsInCallStack( "U_CENTNFEXM" ) == .T. // Documento de Entrada // 19/12/2018 - WILLIAM COSTA CHAMADO 045914 || OS 047114 || FISCAL || DEJAIME || 8921 || AMARRACAO P.C 

			//Inicio trecho revisado - por Adriana em 03/06/2020 - chamado 057598 

			dbSelectAreA('SC7')
			dbSetOrder(1)
			
			If SC7->(dbSeek( XFilial('SC7') + aCols[n][_nCPEDID] + aCols[n][_nCITEMP] ))
				dbSelectAreA('SB1')
				dbSetOrder(1)
				dbSeek(xFilial("SB1")+Alltrim(SC7->C7_PRODUTO))
				
				//VALIDA QUANTIDADE COM TOLERANCIAS CONFORME GRUPO DE PRODUTOS
				
				cErroQtd := "Quantidade da NF está maior que a quantidade do item do Pedido " + Alltrim(aCols[n][_nCPEDID]) + "/ " + aCols[n][_nCITEMP]  + STR_LF + ;
							"Quantidade NF: " + TRANSFORM(aCols[n][_nCQUANT], "@E 999,999.99") + STR_LF + "Quantidade PC: "

				//Everson - 18/12/2018. Chamado 045889.
				If SB1->B1_GRUPO $ cGrupos  //MV_#TOLQTD
				
					_qdtPed := SC7->C7_QUANT - SC7->C7_QUJE
					
					If _qdtPed + (_qdtPed * (GETMV("MV_PERCEMB")/100) ) < aCols[n][_nCQUANT]
						Aviso("MT100LOK-12", (cErroQtd + TRANSFORM(_qdtPed, "@E 999,999.99")+ STR_LF), { "&Retorna" },,"Grupos Produto: " + Alltrim(cGrupos) + STR_LF + ;
								"% Tolerancia: " + STR(GETMV("MV_PERCEMB"),3))
						_lOK := .F.
					Endif
					
				// *** INICIO CHAMADO WILLIAM 038344 TOLERANCIA ACO,PEDRA,AREIA 21/02/2018 *** //
				ElseIf FWFilial("SF1") == '03'                                        .AND. ;
					   SB1->B1_GRUPO     $ GETMV("MV_#GRPEDR",,"9013/9015/9016/9017") .AND. ; //William Costa 11/03/2019 chamado 047734
					   aCols[n][_nUM]   <> 'UN'                                       .AND. ;
					   aCols[n][_nUM]   <> 'PC'
					
					_qdtPed := SC7->C7_QUANT - SC7->C7_QUJE
					
					If _qdtPed + (_qdtPed * (IIF(ALLTRIM(aCols[n][_nCOD]) $ GETMV("MV_PEDAREI"), GETMV("MV_PERARE") /*10%*/, GETMV("MV_PERCACO") /*3%*/) / 100) ) < aCols[n][_nCQUANT]
						Aviso("MT100LOK-13", (cErroQtd + TRANSFORM(_qdtPed, "@E 999,999.99")+ STR_LF), { "&Retorna" },,"Grupos Produto: " + Alltrim(GETMV("MV_#GRPEDR",,"9013/9015/9016/9017"))+ STR_LF + ;
								"% Tolerancia: " + STR((IIF(ALLTRIM(aCols[n][_nCOD]) $ GETMV("MV_PEDAREI"), GETMV("MV_PERARE") /*10%*/, GETMV("MV_PERCACO") /*3%*/)),3))
						_lOK := .F.
					Endif

				// *** INICIO CHAMADO WILLIAM 046145 TOLERANCIA COZINHA 09/01/2019 *** //
				ElseIf SB1->B1_GRUPO $ GETMV("MV_#GRUPOS",,"9028/") 
					
					_qdtPed := SC7->C7_QUANT - SC7->C7_QUJE
					
					If _qdtPed + (_qdtPed * (GETMV("MV_PERARE") / 100) ) < aCols[n][_nCQUANT]
						Aviso("MT100LOK-14", (cErroQtd + TRANSFORM(_qdtPed, "@E 999,999.99")+ STR_LF), { "&Retorna" },,"Grupos Produto: " + Alltrim(GETMV("MV_#GRUPOS",,"9028/"))+ STR_LF + ;
								"% Tolerancia: " + STR(GETMV("MV_PERARE"),3))
						_lOK := .F.
					Endif
					
				Endif
			
				//VALIDA VALOR UNITARIO COM TOLERANCIAS CONFORME GRUPO DE PRODUTOS - PEDIDOS EM REAIS
				
				IF SC7->C7_MOEDA = 1 
				
					If SC7->C7_PRECO < aCols[n][_nCVLUNI]
					
						cErroVunit := 	"Valor unitario da NF está maior que o Valor Unitario "+ STR_LF +"do item do Pedido " + Alltrim(aCols[n][_nCPEDID]) + "/ " + ;
										aCols[n][_nCITEMP] + STR_LF +;
										"Valor Unitario NF: R$" + TRANSFORM(aCols[n][_nCVLUNI], "@E 999,999.99") + STR_LF + ;
										"Valor Unitario PC: R$" + TRANSFORM(SC7->C7_PRECO, "@E 999,999.99")

										
						If SB1->B1_GRUPO $ cGrupos  //MV_#TOLQTD 
						
							Aviso("MT100LOK-15", cErroVunit , { "&Retorna" },,"Grupos Produto: " + Alltrim(cGrupos) )
							_lOK := .F.
											
						ElseIf FWFilial("SF1") == '03'                                     .AND. ;
							SB1->B1_GRUPO     $ GETMV("MV_#GRPEDR",,"9013/9015/9016/9017") .AND. ; //William Costa 11/03/2019 chamado 047734
							aCols[n][_nUM]   <> 'UN'                                       .AND. ;
							aCols[n][_nUM]   <> 'PC'
							
							Aviso("MT100LOK-16", cErroVunit , { "&Retorna" },,"Atenção Grupos Produto: " + Alltrim(GETMV("MV_#GRPEDR",,"9013/9015/9016/9017")))
							_lOK := .F.

						ElseIf SB1->B1_GRUPO $ GETMV("MV_#GRUPOS",,"9028/") 
			
							Aviso("MT100LOK-16", cErroVunit , { "&Retorna" },,"Atenção Grupos Produto: " + Alltrim(cGrupos))
							_lOK := .F.
							
						Endif
					
					Endif

				Endif
				
			Endif
			
			//VALIDA TOTAL DO ITEM, CONSIDERANDO TOLERANCIAS CONFORME GRUPO DE PRODUTOS, CONSIDERANDO NF JA ENTREGUES - VALIDA TODOS OS ITENS

			// Trecho Original: Ricardo Lima-22/02/2019
					
			For nPc1:=1 To Len(aCols)		
				If aCols[nPc1] [LEN(aHeader) + 1] == .F.
							
					cCodpcnf := gdFieldGet( "D1_PEDIDO" , nPc1 )
					cItepcnf := gdFieldGet( "D1_ITEMPC" , nPc1 )
					nVlrttnf := 0
					nVlrnflc := 0
					nVlrDlr  := 0
					cSimbMoe := "R$"
				
					dbSelectAreA("SC7")
					dbSetOrder(1)
					If dbSeek( FWxFilial("SC7") + cCodpcnf + cItepcnf )			
						IF SC7->C7_MOEDA > 1
							cSimbMoe := Alltrim(GETMV("MV_SIMB"+STR(SC7->C7_MOEDA,1),,""))
							IF SC7->C7_TXMOEDA == 0
								DbSelectArea("SM2")
								DbSetOrder(1)
								if DbSeek(Dtos(ddEmissao))
									nVlrDlr := &("M2_MOEDA"+STR(SC7->C7_MOEDA,1))
									If nVlrDlr == 0
										Aviso("MT100LOK-17","Pedido de compra na moeda "+STR(SC7->C7_MOEDA,1)+" sem cotacao, verifique cadastro de moedas dia: "+DTOC(ddEmissao), { "&Retorna" },,"Taxa zero")
										_lOK := .F.
									Endif
								Else
									Aviso("MT100LOK-18","Pedido de compra na moeda "+STR(SC7->C7_MOEDA,1)+" sem cotacao cadastrada na data: "+DTOC(ddEmissao), { "&Retorna" },,"Taxa não encontrada")
									_lOK := .F.
								Endif
							Else
								nVlrDlr := SC7->C7_TXMOEDA
							ENDIF
							cQuery := " SELECT F1_STATUS, D1_FILIAL, D1_PEDIDO, D1_ITEMPC, ISNULL(SUM(TOTAL/TAXA),0) D1_TOTAL "
							cQuery += " FROM ( "
							cQuery += " SELECT F1_STATUS, D1_FILIAL, D1_PEDIDO, D1_ITEMPC, D1_EMISSAO, D1_TOTAL-D1_VALDEV TOTAL,
							cQuery += " (SELECT C7_MOEDA FROM "+RetSqlName("SC7")+" C7 WHERE C7_FILIAL = '"+FWxFilial("SC7")+"' AND C7_NUM = '"+cCodpcnf+"' AND C7.D_E_L_E_T_ = ' ' ) MOEDA,"
							cQuery += " (SELECT M2_MOEDA"+STR(SC7->C7_MOEDA,1)+" FROM "+RetSqlName("SM2")+" M2 WHERE M2_DATA = D1_EMISSAO AND M2.D_E_L_E_T_='' ) TAXA "
							cQuery += " FROM "+RetSqlName("SD1")+" SD1 "
							cQuery += " INNER JOIN "+RetSqlName("SF1")+" SF1 ON SF1.F1_FILIAL = SD1.D1_FILIAL AND  SD1.D1_DOC = SF1.F1_DOC AND SD1.D1_SERIE = SF1.F1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA AND SF1.D_E_L_E_T_ = '' " // por Adriana em 03/06/2020 - solicitacao do Fernando Sigoli //Ticket 65109   - Abel Babini			- 13/12/2021 - Ajuste na query, na clausula INNER JOIN, de F1_LOJA para D1_LOJA e acrescentando o campo FILIAL
							cQuery += " WHERE D1_FILIAL = '"+FWxFilial("SD1")+"' "
							cQuery += " AND D1_PEDIDO = '"+cCodpcnf+"' AND D1_ITEMPC = '"+cItepcnf+"' "
							//cQuery += " AND D1_TES <> ' ' " // por Adriana em 03/06/2020 - solicitacao do Fernando Sigoli 
							cQuery += " AND SF1.F1_STATUS <> '' " // por Adriana em 03/06/2020 - solicitacao do Fernando Sigoli
							//cQuery += " AND SF1.D_E_L_E_T_ = '' " // por Adriana em 03/06/2020 - solicitacao do Fernando Sigoli //Ticket 65109   - Abel Babini			- 13/12/2021 - Ajuste na query, na clausula INNER JOIN, de F1_LOJA para D1_LOJA e acrescentando o campo FILIAL
							cQuery += " AND SD1.D_E_L_E_T_ = '') NOTA "
							cQuery += " GROUP BY F1_STATUS, D1_FILIAL, D1_PEDIDO, D1_ITEMPC " // por Adriana em 03/06/2020 - solicitacao do Fernando Sigoli
			
							If Select("ADMT100") > 0
								ADMT100->(DbCloseArea())
							EndIf
							TcQuery cQuery NEW Alias "ADMT100"
			
							nVlrnflc := ADMT100->D1_TOTAL //Valor convertido taxa da data de emissao de cada nota encontrada
					
							For nPc2:=1 To Len(aCols)				
								If aCols[nPc2] [LEN(aHeader) + 1] == .F.					
									If cCodpcnf = gdFieldGet( "D1_PEDIDO" , nPc2 ) .AND. cItepcnf = gdFieldGet( "D1_ITEMPC" , nPc2 )
										nVlrttnf += gdFieldGet( "D1_TOTAL" , nPc2 )
									EndIf				
								EndIF  			
							Next
							
							nVlrttnf := iif(nVlrDlr=0,0,nVlrttnf / nVlrDlr) // Valor convertido taxa da data de emissao da nota atual
						Else
							cQuery := " SELECT D1_FILIAL, D1_PEDIDO, D1_ITEMPC, ISNULL(SUM(D1_TOTAL-D1_VALDEV),0) D1_TOTAL "
							cQuery += " FROM "+RetSqlName("SD1")+" SD1 "
							cQuery += " INNER JOIN "+RetSqlName("SF1")+" SF1 ON SF1.F1_FILIAL = SD1.D1_FILIAL AND SD1.D1_DOC = SF1.F1_DOC AND SD1.D1_SERIE = SF1.F1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA AND SF1.D_E_L_E_T_ = '' " // por Adriana em 03/06/2020 - solicitacao do Fernando Sigoli //Ticket 65109   - Abel Babini			- 13/12/2021 - Ajuste na query, na clausula INNER JOIN, de F1_LOJA para D1_LOJA e acrescentando o campo FILIAL
							cQuery += " WHERE D1_FILIAL = '"+FWxFilial("SD1")+"' "
							cQuery += " AND D1_PEDIDO = '"+cCodpcnf+"' AND D1_ITEMPC = '"+cItepcnf+"' "
							//cQuery += " AND D1_TES <> ' ' " // por Adriana em 03/06/2020 - solicitacao do Fernando Sigoli
							cQuery += " AND SF1.F1_STATUS <> '' " // por Adriana em 03/06/2020 - solicitacao do Fernando Sigoli
							//cQuery += " AND SF1.D_E_L_E_T_ = '' " // por Adriana em 03/06/2020 - solicitacao do Fernando Sigoli //Ticket 65109   - Abel Babini			- 13/12/2021 - Ajuste na query, na clausula INNER JOIN, de F1_LOJA para D1_LOJA e acrescentando o campo FILIAL
							cQuery += " AND SD1.D_E_L_E_T_ = '' "
							cQuery += " GROUP BY F1_STATUS,D1_FILIAL, D1_PEDIDO, D1_ITEMPC " // por Adriana em 03/06/2020 - solicitacao do Fernando Sigoli
				
							If Select("ADMT100") > 0
								ADMT100->(DbCloseArea())
							EndIf
							TcQuery cQuery NEW Alias "ADMT100"
			
							nVlrnflc := ADMT100->D1_TOTAL
					
							For nPc2:=1 To Len(aCols)				
								If aCols[nPc2] [LEN(aHeader) + 1] == .F.					
									If cCodpcnf = gdFieldGet( "D1_PEDIDO" , nPc2 ) .AND. cItepcnf = gdFieldGet( "D1_ITEMPC" , nPc2 )
										nVlrttnf += gdFieldGet( "D1_TOTAL" , nPc2 )
									EndIf				
								EndIF  			
							Next
								
						Endif
						nTotPed := SC7->C7_TOTAL
							
						//Inicio 1- Fernando Sigoli 12/03/2019- Chamado: 047820
						
						cErroTot := "Incluindo esse Lançamento, o valor das entradas, será maior que o valor do item do Pedido "+Alltrim(cCodpcnf)+"-"+Alltrim(cItepcnf)+STR_LF+STR_LF+;
									"Documentos já Lançados"+chr(9)+cSimbMoe+Transform(nVlrnflc, PesqPict("SC7","C7_TOTAL"))+STR_LF+;
									"Documento Atual"+chr(9)+cSimbMoe+Transform(nVlrttnf, PesqPict("SC7","C7_TOTAL"))+STR_LF+;
									"Total Documentos"+chr(9)+cSimbMoe+Transform(nVlrnflc+nVlrttnf, PesqPict("SC7","C7_TOTAL"))+STR_LF+STR_LF+;
									"Total Item Pedido"+chr(9)+chr(9)+cSimbMoe+Transform(nTotPed, PesqPict("SC7","C7_TOTAL"))
							
						If Posicione("SB1",1,xFilial("SB1")+aCols[nPc1][_nPCOD],"B1_GRUPO") $ GETMV("MV_#GRUPOS",,"9028/") //Grupo 9028 cozinha  
								
							If Round( (nVlrttnf + nVlrnflc) ,2) > ROUND(nTotPed + (nTotPed * (GETMV("MV_PERARE") / 100) ),2) 
								Aviso("MT100LOK-19", cErroTot, { "&Retorna" },,"Valor Entradas > Valor Pedido "+STR_LF+"% Tolerancia: "+STR(GETMV("MV_PERARE"),3) )
								nVlrttnf := 0
								RestArea(_aArea)
								Return .F.
							EndIf
							
						ElseIf Posicione("SB1",1,xFilial("SB1")+aCols[nPc1][_nPCOD],"B1_GRUPO") $ GETMV("MV_#TOLQTD",,"9006/9007/9044/9045") //Grupo de embalagens	
						
							If Round( (nVlrttnf + nVlrnflc) ,2) > ROUND(nTotPed + (nTotPed * (GETMV("MV_PERCEMB") / 100) ),2) 
								Aviso("MT100LOK-20", cErroTot, { "&Retorna" },,"Valor Entradas > Valor Pedido "+STR_LF+"% Tolerancia: "+STR(GETMV("MV_PERCEMB"),3))
								nVlrttnf := 0
								RestArea(_aArea)
								Return .F.
							EndIf
		
						ElseIf FWFilial("SF1") == '03'                                     .AND. ;
							SB1->B1_GRUPO     $ GETMV("MV_#GRPEDR",,"9013/9015/9016/9017") .AND. ; //William Costa 11/03/2019 chamado 047734
							aCols[n][_nUM]   <> 'UN'                                       .AND. ;
							aCols[n][_nUM]   <> 'PC'
							If Round( (nVlrttnf + nVlrnflc) ,2) > ROUND(nTotPed + (nTotPed * (IIF(ALLTRIM(aCols[nPc1][_nCOD]) $ GETMV("MV_PEDAREI"), GETMV("MV_PERARE") /*10%*/, GETMV("MV_PERCACO") /*3%*/) / 100) ),2) 
								Aviso("MT100LOK-21", cErroTot, { "&Retorna" },,"Valor Entradas > Valor Pedido "+STR_LF+"% Tolerancia: "+STR((IIF(ALLTRIM(aCols[n][_nCOD]) $ GETMV("MV_PEDAREI"), ;
									GETMV("MV_PERARE") /*10%*/, GETMV("MV_PERCACO") /*3%*/)),3) )
								nVlrttnf := 0
								RestArea(_aArea)
								Return .F.
							EndIf

						Else //todos os demais grupos
						
							If Round( (nVlrttnf + nVlrnflc) ,2) > Round( (nTotPed + GETMV("MV_#VLTOTN")) ,2)
								Aviso("MT100LOK-22", cErroTot, { "&Retorna" },,"Valor Entradas > Valor Pedido "+STR_LF+"Tolerancia: "+STR(GETMV("MV_#VLTOTN"),5,2) )
								nVlrttnf := 0
								RestArea(_aArea)
								Return .F.
							EndIf
						
						EndIf
							
					    //Fim 1- Fernando Sigoli 12/03/2019- Chamado: 047820
					Endif		
				EndIf	
			Next
			//Fim trecho revisado - por Adriana em 03/06/2020 - chamado 057598 
			
			// *** INICIO CHAMADO 035867 WILLIAM COSTA - REMESSA ORDEM *** //
			
			IF ! _Rotina
				
				IF ALLTRIM(aCols[n][_nCf]) $ GETMV("MV_#CFRORD")
					
					// Verifica se os campos estão em brancos
					IF ALLTRIM(aCols[n][_nNfFilOr]) == '' .OR. ;
						ALLTRIM(aCols[n][_nNfOrdem]) == '' .OR. ;
						ALLTRIM(aCols[n][_nSeriOrd]) == '' .OR. ;
						ALLTRIM(aCols[n][_nItemOrd]) == '' .OR. ;
						ALLTRIM(aCols[n][_nForOrde]) == '' .OR. ;
						ALLTRIM(aCols[n][_nLojaOrd]) == ''
						
						IF (MsgNOYES("OLÁ " + Alltrim(cUserName) + ", Quando é uma nota de remessa ordem é necessário informar a nota de compra ordem, Deseja Informar?", "MT120OK - Digitação da Nota Compra Ordem campo D1_NFORDEM"))
							
							_lOk = .F.
							
						ELSE
							
							_lOk = .T.
							
						ENDIF
						
					ENDIF
					
					// Verifica se os campos foram prenchidos
					IF ALLTRIM(aCols[n][_nNfFilOr]) <> '' .OR. ;
						ALLTRIM(aCols[n][_nNfOrdem]) <> '' .OR. ;
						ALLTRIM(aCols[n][_nSeriOrd]) <> '' .OR. ;
						ALLTRIM(aCols[n][_nItemOrd]) <> '' .OR. ;
						ALLTRIM(aCols[n][_nForOrde]) <> '' .OR. ;
						ALLTRIM(aCols[n][_nLojaOrd]) <> ''
						
						//busca nota compra ordem
						SQLVerNotaCompraOrdem(ALLTRIM(aCols[n][_nNfFilOr]),ALLTRIM(aCols[n][_nNfOrdem]),ALLTRIM(aCols[n][_nSeriOrd]),ALLTRIM(aCols[n][_nItemOrd]),ALLTRIM(aCols[n][_nForOrde]),ALLTRIM(aCols[n][_nLojaOrd]))
						
						//nota não encontrada
						IF TRB->(EOF())
							
							MsgStop("OLÁ " + Alltrim(cUserName) + ", nota de compra ordem não encontrada, favor verificar!!!", "MT120OK - Digitação da Nota Compra Ordem campo D1_NFORDEM")
							_lOk = .F.
							
						ENDIF
						
						//nota encontrada
						While TRB->(!EOF())
							
							// Verifica se a CFOP'S e de Compra Ordem
							IF !(ALLTRIM(TRB->D1_CF) $ GETMV("MV_#CFCORD"))
								
								MsgStop("OLÁ " + Alltrim(cUserName) + ", nota de compra ordem não esta com a CFOP correta, favor verificar!!!", "MT120OK - Digitação da Nota Compra Ordem campo D1_NFORDEM")
								_lOk = .F.
								
							ENDIF
							TRB->(dbSkip())
							
						ENDDO
						TRB->(dbCloseArea())
						
						//Verifica se a Nota de Compra Ordem já esta cadastrada em outra nota de compra ordem
						SQLVerOutraCompraOrdem(ALLTRIM(aCols[n][_nNfFilOr]),ALLTRIM(aCols[n][_nNfOrdem]),ALLTRIM(aCols[n][_nSeriOrd]),ALLTRIM(aCols[n][_nItemOrd]),ALLTRIM(aCols[n][_nForOrde]),ALLTRIM(aCols[n][_nLojaOrd]))
						
						//nota encontrada
						IF TRC->(!EOF())
							
							// Verifica se a CFOP'S e de Compra Ordem
							
							MsgStop("OLÁ " + Alltrim(cUserName) + ", nota de compra ordem já cadastra para outra nota fiscal, favor verificar!!!", "MT120OK - Digitação da Nota Compra Ordem campo D1_NFORDEM")
							_lOk = .F.
							
							TRC->(dbSkip())
							
						ENDIF
						TRC->(dbCloseArea())
					ENDIF
				ENDIF
			ENDIF
			
			// *** FINAL CHAMADO 035867 WILLIAM COSTA - REMESSA ORDEM *** //
			
		Endif
			//CHAMADO 058766 - 15/06/2020 - ADRIANO SAVOINE - Retirado o If que havia nesse ponto para nao validar na empresa Ceres
			// LUCIANO 26/09/2014 CHAMADO Nº 020480 - OBRIGA PREENCHER OS CAMPOS D1_NFRURAL E D1_SRRURAL QUANDO FORNECEDOR TIPO PRODUTOR RURAL FOR PESSOA FÍSICA
			IF ! _Rotina
				dbSelectAreA('SA2')
				dbSetOrder(1)
				dbSeek( XFilial('SA2') + CA100FOR + CLOJA )
				IF (SA2->A2_TIPORUR = 'F' .AND. EMPTY(aCols[n][_nNFPR])) .OR. (SA2->A2_TIPORUR = 'F' .AND. EMPTY(aCols[n][_nSRPR]))
					ALERT("ATENÇÃO: QUANDO FOR NF DE PRODUTOR RURAL E ESTE FOR UMA PESSOA FÍSICA, OS CAMPOS NF_RURAL E SERIE_RURAL NÃO PODEM ESTAR EM BRANCO !")
					_lOk = .F.
				ENDIF
			ENDIF
			// FIM DA LÓGICA CHAMADO 020480	
			//CHAMADO 058766 - 15/06/2020 - ADRIANO SAVOINE - Retirado o If que havia nesse ponto para nao validar na empresa Ceres
	EndIf
	
	// 23/03/2018 - FWNM - Consiste Projeto Encerrado
	
	If _lOK
		
		If !gdDeleted(n)
			
			cPrj    := gdFieldGet("D1_PROJETO", n)
			cPC     := gdFieldGet("D1_PEDIDO", n)
			
			If Empty(cPC)
				dbSelectArea("AF8")
				dbSetOrder(1)
				If dbseek(xFilial("AF8")+cPrj)
					If AllTrim(AF8->AF8_ENCPRJ) == "1"
						MsgAlert("O Projeto "+cPrj+" se encontra ENCERRADO e nao aceita mais lancamentos.")
						_lOK := .f.
					EndIf
				EndIf
			EndIf
			
		EndIf
		
	EndIf
	
	// Consiste saldo do projeto de investimento - FWNM em 29/12/2017
	If _lOK
		
		If !gdDeleted(n)
			
			dDtDig := msDate()
			
			cPrj    := gdFieldGet("D1_PROJETO", n)
			cCC     := gdFieldGet("D1_CC", n)
			cPC     := gdFieldGet("D1_PEDIDO", n)
			cPCItem := gdFieldGet("D1_ITEMPC", n)

			cNFCod  := gdFieldGet("D1_COD", n)
			cNFItem := gdFieldGet("D1_ITEM", n)

			nTt     := gdFieldGet("D1_TOTAL", n)
			nDesc   := gdFieldGet("D1_VALDESC", n)

			// Chamado n. RO || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 22/10/2019
			// Moeda Estrangeira = D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA+D1_SEGURO+D1_VALICM+D1_VALIMP5+D1_VALIMP6+D1_ICMSRET-D1_VALDESC
			// Moeda Nacional    = D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA+D1_SEGURO+D1_ICMSRET-D1_VALDESC

			cCFOP    := gdFieldGet("D1_CF", n)

			nValIpi  := gdFieldGet("D1_VALIPI", n)
			nValFre  := gdFieldGet("D1_VALFRE", n)
			nDespesa := gdFieldGet("D1_DESPESA", n)
			nSeguro  := gdFieldGet("D1_SEGURO", n)
			nICMSRet := gdFieldGet("D1_ICMSRET", n)
			nValDesc := gdFieldGet("D1_VALDESC", n)

			nValICM  := gdFieldGet("D1_VALICM", n)
			nValIMP5 := gdFieldGet("D1_VALIMP5", n)
			nValIMP6 := gdFieldGet("D1_VALIMP6", n)
			
			If Left(AllTrim(cCFOP),1) == "3" // Moeda Estrangeira
				nTtPrj := nTt + nValIPI + nValFre + nDespesa + nSeguro + nValICM + nValImp5 + nValImp6 + nICMSRet - nDesc
			Else
				nTtPrj := nTt + nValIPI + nValFre + nDespesa + nSeguro + nICMSRet - nDesc
			EndIf
			
			//nTtPrj := (nTt - nDesc)
			//
			
			// Insere número do projeto do PC desde que esteja em branco, ou seja, não informado pelo usuario
			If Empty(cPrj)

				If !lICMSPro // @history Ticket 358     - FWNM            - 21/08/2020 - Implementação para diferenciar complemento de ICMS Próprio e ST nos projetos de investimentos

					aAreaSC7 := SC7->( GetArea() )
					
					SC7->( dbSetOrder(1) ) // C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
					SC7->( dbSeek(xFilial("SC7")+cPC+cPCItem) )
					
					cPrj := SC7->C7_PROJETO
					
					gdFieldPut("D1_PROJETO", cPrj, n)
					
					RestArea( aAreaSC7 )
				
				EndIf

			EndIf
			
			
			// Consiste exigência ou não do projeto - FWNM 16/03/2018
			lPrjInv := Left(AllTrim(cCC),1) == "9"
			
			If lPrjInv .and. !Alltrim(cCC) $ GetMV("MV_#CCPADR")
				
				If Empty(cPrj)
				
					If !lICMSPro // @history Ticket 358     - FWNM            - 21/08/2020 - Implementação para diferenciar complemento de ICMS Próprio e ST nos projetos de investimentos
				
						_lOK := .f.
						
						Aviso(	"MT100LOK-06",;
						"Centro de Custo: " + cCC + "." + Chr(13) + Chr(10) +;
						"É obrigatório o preenchimento do Projeto.",;
						{ "&Retorna" },,;
						"Conteúdo em Branco" )

					EndIf
				
				EndIf
				
				If !lICMSPro // @history Ticket 358     - FWNM            - 21/08/2020 - Implementação para diferenciar complemento de ICMS Próprio e ST nos projetos de investimentos
				
					// Consiste CC permitidos para aquele projeto (ZC1)
					If _lOK
						
						ZC1->( dbSetOrder(1) ) // ZC1_FILIAL+ZC1_PROJET+ZC1_CC
						If ZC1->( !dbSeek(xFilial("ZC1")+cPrj+cCC) )
							
							_lOK := .f.
							
							Aviso(	"MT100LOK-04",;
							"Centro Custo não permitido para este projeto! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
							"CC: " + cCC + " - " + Posicione("CTT",1,xFilial("CTT")+cCC,"CTT_DESC01") + chr(13) + chr(10) +;
							"Projeto: " + cPrj + " - " + AF8->AF8_DESCRI,;
							{ "&Retorna" },,;
							"Projeto x CC permitidos" )
							
						EndIf
						
					EndIf
					
					// Consiste filial/planta permitida para aquele CC
					If _lOK
						
						If Left(AllTrim(cPrj),2) <> cFilAnt
							
							_lOK := .f.
							
							Aviso(	"MT100LOK-05",;
							"Este projeto n. " + AllTrim(cPrj) + " não pertence a esta filial! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
							"Filial/Planta: " + cFilAnt + chr(13) + chr(10) +;
							"Projeto/Planta: " + Left(AllTrim(cPrj),2),;
							{ "&Retorna" },,;
							"Projeto x Filial/Planta" )
							
						EndIf
						
					EndIf
				
				EndIf //
				
				// consiste valor/saldo, fase e vigencia
				If _lOK
					
					If !Empty(cPrj)
						
						// Controle Saldo Projeto ativo
						If lSldAtv
							
							AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
							If AF8->( dbSeek(xFilial("AF8")+cPrj) )
								
								// Consiste apenas projetos que possuem valor
								If AF8->AF8_XVALOR > 0
									
									// Consiste fase do projeto para checar se esta na central de aprovacao
									//If AllTrim(cFasePrj) == AllTrim(AF8->AF8_FASE) // Chamado n. 046284
									If AllTrim(AF8->AF8_FASE) <> AllTrim(cFaseApr) // Se fase diferente de aprovada // Chamado n. 046284

										_lOK := .f.
										
										Aviso(	"MT100LOK-01",;
										"Projeto n. " + AllTrim(cPrj) + " não foi aprovado na Central de Aprovação! " + chr(13) + chr(10) + "Uso ainda não permitido..." + chr(13) + chr(10) + ;
										"",;
										{ "&Retorna" },,;
										"Projeto não aprovado" )
										
									EndIf
									
									
									// Consiste saldo informado no documento de entrada x saldo do projeto (AF8)
									If _lOK 
	
										// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 22/10/2019
										//If Empty(cPC) // FWNM - 20/12/2018 - Chamado n. 045963
										//

											cPCItemKey := ""
											cPCItemKey := cPC+cPCItem

											// @history Ticket 358     - FWNM            - 21/08/2020 - Implementação para diferenciar complemento de ICMS Próprio e ST nos projetos de investimentos
											cNFKey := ""
											cNFKey := FWxFilial("SF1")+cNFiscal+cSerie+cTipo+cA100For+cLoja//+cNFCod+cNFItem
											//
											
											//nSldPrj := u_ADCOM017P(cPrj,,cPC,cPCItem)
											//nSldPrj := u_ADCOM017P(cPrj,,cPCItemKey)
											nSldPrj := u_ADCOM017P(cPrj,,cPCItemKey,,cNFKey) // @history Ticket 358     - FWNM            - 21/08/2020 - Implementação para diferenciar complemento de ICMS Próprio e ST nos projetos de investimentos
											
											If (nTtPrj > nSldPrj) .And. lGeraFin 
												
												_lOK := .f.
												
												Aviso(	"MT100LOK-02",;
												"Saldo do projeto n. " + AllTrim(cPrj) + " insuficiente! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
												"[NF] Líquido: " + Transform(nTtPrj, PesqPict("SD1","D1_TOTAL")) + chr(13) + chr(10) +;
												"[PRJ] Saldo: " + Transform(nSldPrj, PesqPict("SD1","D1_TOTAL")),;
												{ "&Retorna" },,;
												"Projeto sem saldo" )
												
											EndIf
										
										//EndIf
						
									EndIf
									
									
									// Consiste datas previstas do projeto (AF8) x data de digitação oriunda do servidor do documento
									If _lOK
									
										// Inicio chamado William 04/03/2019 nova regra 047536 || OS 048806 || ALMOXARIFADO || FABIO || 8410 || BAIXA REQUISICAO    
										//Regra:Validar vigência do Projeto, somente se o documento de entrada não estiver com pedido de compra  amarrado e estiver número do projeto 
										//Analise se esse tratativa, seja no ponto de entrada LOK ou no TudoOK
										
										IF ALLTRIM(ACOLS[N][nPOSPROJ]) <> '' .AND.;
										   ALLTRIM(ACOLS[N][_nCPEDID]) == '' 
									
											If dDtDig < AF8->AF8_START .or. dDtDig > AF8->AF8_FINISH
												
												_lOK := .f.
												
												Aviso(	"MT100LOK-03",;
												"Vigência do projeto n. " + AllTrim(cPrj) + " está fora! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
												"Data Digitação: " + DtoC(dDtDig) + chr(13) + chr(10) +;
												"Início-Fim Projeto: " + DtoC(AF8->AF8_START) + " - " + DtoC(AF8->AF8_FINISH),;
												{ "&Retorna" },,;
												"Vigência do Projeto" )
												
											EndIf
										ENDIF
									EndIf
																	
								EndIf
								
							EndIf
							
						EndIf
						
					EndIf
					
				EndIf
				
				
				
			Else
				
				//If !Empty(cPrj)
				If !Empty(cPrj) .and. lICMSPro // @history Ticket 358     - FWNM            - 21/08/2020 - Implementação para diferenciar complemento de ICMS Próprio e ST nos projetos de investimentos
					
					_lOK := .f.
					
					If lICMSPro // @history Ticket 358     - FWNM            - 21/08/2020 - Implementação para diferenciar complemento de ICMS Próprio e ST nos projetos de investimentos
						Aviso(	"MT100LOK-07",;
						"Centro de Custo: " + cCC + "." + Chr(13) + Chr(10) +;
						"Não permitido o preenchimento do Projeto.",;
						{ "&Retorna" },,;
						"Não permitido informar projeto para nota de complemento de ICMS Próprio" )
					Else
						Aviso(	"MT100LOK-07",;
						"Centro de Custo: " + cCC + "." + Chr(13) + Chr(10) +;
						"Não permitido o preenchimento do Projeto.",;
						{ "&Retorna" },,;
						"Não permitido informar projeto para CC que não é investimento" )
					EndIf
					
				EndIf
				
			EndIf
					
		EndIf
		
	EndIf
	
	
	// FWNM - 23/03/2018 - Totaliza projetos informados nos itens para confrontar com o saldo do mesmo
	If _lOK
		
		// Controle Saldo Projeto ativo
		If lSldAtv
			
		
			aTtPrj := {} // armazenará os dados do projeto para totalizar e consistir
			
			For i:=1 to Len(aCols)
				
				If !gdDeleted(i)
					
					cPrj    := gdFieldGet("D1_PROJETO", i)
					cPC     := gdFieldGet("D1_PEDIDO", i) 
					
					If !Empty(cPrj)
						
						// Projeto Investimento
						cCC     := gdFieldGet("D1_CC", i)
						lPrjInv := Left(AllTrim(cCC),1) == "9"
						
						If lPrjInv .and. !Alltrim(cCC) $ GetMV("MV_#CCPADR")
							
							// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 22/10/2019
							//If Empty(cPC) // FWNM - 20/12/2018 - Chamado n. 045963
							//
							
								nTt     := gdFieldGet("D1_TOTAL", i)
								nDesc   := gdFieldGet("D1_VALDESC", i)
								cCC     := gdFieldGet("D1_CC", i)
								cPC     := gdFieldGet("D1_PEDIDO", i)
								cPCItem := gdFieldGet("D1_ITEMPC", i)
								
								// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 22/10/2019
								// Moeda Estrangeira = D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA+D1_SEGURO+D1_VALICM+D1_VALIMP5+D1_VALIMP6+D1_ICMSRET-D1_VALDESC
								// Moeda Nacional    = D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA+D1_SEGURO+D1_ICMSRET-D1_VALDESC

								//INICIO Chamado 055243 - Abel Babini     - 24/01/2020 - Ajuste na validação dos valores de saldo do Projeto MT100LOK-09 
								//alterado a posição 'n' para 'i'
								cCFOP    := gdFieldGet("D1_CF", i)
					
								nValIpi  := gdFieldGet("D1_VALIPI", i)
								nValFre  := gdFieldGet("D1_VALFRE", i)
								nDespesa := gdFieldGet("D1_DESPESA", i)
								nSeguro  := gdFieldGet("D1_SEGURO", i)
								nICMSRet := gdFieldGet("D1_ICMSRET", i)
								nValDesc := gdFieldGet("D1_VALDESC", i)
					
								nValICM  := gdFieldGet("D1_VALICM", i)
								nValIMP5 := gdFieldGet("D1_VALIMP5", i)
								nValIMP6 := gdFieldGet("D1_VALIMP6", i)
								//FIM Chamado 055243 - Abel Babini     - 24/01/2020 - Ajuste na validação dos valores de saldo do Projeto MT100LOK-09 
								
								If Left(AllTrim(cCFOP),1) == "3" // Moeda Estrangeira
									nTtPrj := nTt + nValIPI + nValFre + nDespesa + nSeguro + nValICM + nValImp5 + nValImp6 + nICMSRet - nDesc
								Else
									nTtPrj := nTt + nValIPI + nValFre + nDespesa + nSeguro + nICMSRet - nDesc
								EndIf

								// Valor do projeto do item
								//nTtPrj := (nTt - nDesc)
								//

								aAdd( aTtPrj, {	cPrj,;
								nTtPrj ,;
								cPC ,;
								cPCItem } )
								
							//EndIf
							
						EndIf
						
					EndIf
					
				EndIf
				
			Next i
			
			// Consisto total projeto
			
			// Ordena por Projeto + PC + Item PC
			aSort( aTtPrj,,, { |x,y| x[1]+x[3]+x[4] < y[1]+y[3]+y[4] } )
			
			cColsPrj    := ""
			nColsTot    := 0
			cColsPC     := ""
			cColsPCItem := ""
	
			cPCItemKey  := ""
			
			For y:=1 to Len(aTtPrj)
				
				cColsPC      := aTtPrj[y,3]
				cColsPCItem  := aTtPrj[y,4]
				
				// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 22/10/2019
				//If Empty(cColsPC) // FWNM - 20/12/2018 - Chamado n. 045963
				//
				
					cPCItemKey    += cColsPC + cColsPCItem + "|"
					
					If y == 1 // primeira linha
						cColsPrj := aTtPrj[y,1]
						nColsTot := aTtPrj[y,2]
						
					Else
						// Se for o mesmo projeto
						If cColsPrj == aTtPrj[y,1]
							nColsTot += aTtPrj[y,2] // totalizo os valores
							
						// Consisto saldo x total dos itens
						Else
							
							AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
							If AF8->( dbSeek(xFilial("AF8")+cColsPrj) )
								
								// Consiste apenas projetos que possuem valor
								If AF8->AF8_XVALOR > 0
									
									// @history Ticket 358     - FWNM            - 21/08/2020 - Implementação para diferenciar complemento de ICMS Próprio e ST nos projetos de investimentos
									cNFKey := ""
									cNFKey := FWxFilial("SF1")+cNFiscal+cSerie+cTipo+cA100For+cLoja//+cNFCod+cNFItem
									//
									
									// Consiste saldo informado no documento de entrada x saldo do projeto (AF8)
									//nSldPrj := u_ADCOM017P(cColsPrj,,cColsPC,cColsPCItem)
									//nSldPrj := u_ADCOM017P(cColsPrj,,cPCItemKey)
									nSldPrj := u_ADCOM017P(cColsPrj,,cPCItemKey,,cNFKey) // @history Ticket 358     - FWNM            - 21/08/2020 - Implementação para diferenciar complemento de ICMS Próprio e ST nos projetos de investimentos

									If nColsTot > nSldPrj .And. lGeraFin //Everson - 11/12/2018. Chamado 045702
										
										_lOK := .f.
										
										Aviso(	"MT100LOK-08",;
										"Saldo do projeto n. " + AllTrim(cColsPrj) + " insuficiente! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
										"[NF] Tt Líquido itens: " + Transform(nColsTot, PesqPict("SD1","D1_TOTAL")) + chr(13) + chr(10) +;
										"[PRJ] Saldo: " + Transform(nSldPrj, PesqPict("SD1","D1_TOTAL")),;
										{ "&Retorna" },,;
										"Projeto sem saldo" )
										
									Else
										// zero variaveis para proximo projeto
										cColsPrj     := aTtPrj[y,1]
										nColsTot     := aTtPrj[y,2]
										cColsPC      := aTtPrj[y,3]
										cColsPCItem  := aTtPrj[y,4]
										
									EndIf
									
								EndIf
								
							EndIf
							
						EndIf
						
					EndIf

				//EndIf
				
			Next y
			
			
			// Consisto o último projeto do acols - NÃO RETIRAR !!!
			If _lOk
				
				AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
				If AF8->( dbSeek(xFilial("AF8")+cColsPrj) )
					
					// Controle Saldo Projeto ativo
					If lSldAtv
						
						// Consiste apenas projetos que possuem valor
						If AF8->AF8_XVALOR > 0
							
							// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 22/10/2019
							//If Empty(cPCItemKey) // FWNM - 20/12/2018 - Chamado n. 045963
							//

								// @history Ticket 358     - FWNM            - 21/08/2020 - Implementação para diferenciar complemento de ICMS Próprio e ST nos projetos de investimentos
								cNFKey := ""
								cNFKey := FWxFilial("SF1")+cNFiscal+cSerie+cTipo+cA100For+cLoja//+cNFCod+cNFItem
								//

								// Consiste saldo informado no documento de entrada x saldo do projeto (AF8)
								//nSldPrj := u_ADCOM017P(cColsPrj,,cColsPC,cColsPCItem)
								//nSldPrj := u_ADCOM017P(cColsPrj,,cPCItemKey)
								nSldPrj := u_ADCOM017P(cColsPrj,,cPCItemKey,,cNFKey) // @history Ticket 358     - FWNM            - 21/08/2020 - Implementação para diferenciar complemento de ICMS Próprio e ST nos projetos de investimentos

								If (nColsTot > nSldPrj) .And. lGeraFin //Everson - 11/12/2018. Chamado 045702
									
									_lOK := .f.
									
									Aviso(	"MT100LOK-09",;
									"Saldo do projeto n. " + AllTrim(cColsPrj) + " insuficiente! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
									"[NF] Tt Líquido itens: " + Transform(nColsTot, PesqPict("SD1","D1_TOTAL")) + chr(13) + chr(10) +;
									"[PRJ] Saldo: " + Transform(nSldPrj, PesqPict("SD1","D1_TOTAL")),;
									{ "&Retorna" },,;
									"Projeto sem saldo" )
									
								EndIf

							//EndIf
							
						EndIf
						
					EndIf
					
				EndIf
				
			EndIf

			// prenota x classificação	

			
			//
		
		
		
		
		EndIf
		
	EndIf

	// Ricardo Lima-20/02/2019-047371
	If !Empty( aCols[n][_nCPEDID] ) .and. !Empty( aCols[n][nPOSPROJ])
		dbSelectAreA("SC7")
		dbSetOrder(1)
		if dbSeek( FWxFilial("SC7") + aCols[n][_nCPEDID] + aCols[n][_nCITEMP] ) // Ricardo Lima-27/02/2019-047563
			if !Empty(SC7->C7_PROJETO)
				if aCols[n][nPOSPROJ] <> SC7->C7_PROJETO
					ApMsgInfo('O Codigo do Projeto informado no lançamento da Nota e Diferente do Codigo do Projeto do Pedido de Compra, Corrija o numero do Projeto da Nota.','Documento de Entrada de Projetos')
					_lOk := .F.
				EndIf
			Else // Ricardo Lima-25/02/2019
				ApMsgInfo('O Pedido usado não pertence ao Projeto Informado, informe o pedido correto.','Documento de Entrada de Projetos')
				_lOk := .F.
			Endif
		Endif
	EndIf

	// Ricardo Lima-22/02/2019-047433 
	/*
	If !Empty( aCols[n][_nCPEDID] )
		dbSelectAreA("SC7")
		dbSetOrder(1)
		if dbSeek( FWxFilial("SC7") + aCols[n][_nCPEDID] )
			if aCols[n][_nCVLUNI] > (SC7->C7_PRECO + GETMV("MV_#VLTOTN"))
				ApMsgInfo('O Valor Unitário informado e Diferente do Valor Unitário do Pedido,'+chr(13)+chr(10)+'Valor unitário do Pedido R$ '+Transform(SC7->C7_PRECO, PesqPict("SC7","C7_PRECO"))+chr(13)+chr(10)+'Valor Unitario Informado R$ '+Transform(aCols[n][_nCVLUNI], PesqPict("SD1","D1_VUNIT"))+chr(13)+chr(10)+' Corrija o valor do Lançamento.','Documento de Entrada com Pedido Vinculado')
				_lOk := .F.
			EndIf
		Endif
	EndIf
	*/
	
	//047433 - validação, de notas que geram financeiro, deve estar vinculado a um pedido de compra
	dbSelectAreA("SF4")
	dbSetOrder(1)
	
	If dbSeek( FWxFilial("SF4") + aCols[n][_nPosTes] )
		
		If cTipoNF == "N" .And. aCols[n] [LEN(aHeader) + 1] == .F. .And. ! IsInCallStack( "U_IntNFEB" ) //Fernando-01/03/2019 - T.I //Everson-01/03/2019 - T.I. Não validar integração SAG e validar apenas tipo normal.
			
			If SF4->F4_DUPLIC = 'S'
				If Empty( aCols[n][_nCPEDID] )
					ApMsgInfo('Notas que geram Financeiro precisam de pedido de compra vinculado;'+chr(13)+chr(10)+'Informe o Pedido de Compras.','Documento de Entrada sem Pedido')
					_lOk := .F.
				EndIf
			EndIf
			
		EndIf
		
	Endif
	
	//Inicio Chamado: 047936  Fernando Sigoli 18/03/2019
	If aCols[n] [LEN(aHeader) + 1] == .F. .And. ! IsInCallStack( "U_IntNFEB" )
		
		If !Empty( aCols[n][_nCPEDID] ) .and. Empty( aCols[n][_nCITEMP] ) 
			ApMsgAlert('Atenção, item do Pedido nao preenchido'+chr(13)+chr(10)+'Informe o Item do Pedido de Compra.','Documento de Entrada')
			_lOk := .F.
		EndIf
	
	EndIf
	//Fim Chamado: 047936  Fernando Sigoli 18/03/2019
	
	// Chamado n. 047931 || OS 049195 || CONTROLADORIA || ANDRESSA || 45968437 || C.CUSTO X LOTE -RNX2 - FWNM - 19/03/2019
	If _lOk
		_lOk := ChkZCN()
	EndIf
	// 

	//MSGSTOP( "Trocou a conta contábil !!!" + CHR(13) + ALLTRIM(FUNNAME()) + "  aCols[n][_nPCONTA] " + aCols[n][_nPCONTA] + "  SB1->B1_CONTAR: " + SB1->B1_CONTAR + "  ZZB->ZZB_CONTA: " + ZZB->ZZB_CONTA, "ATENÇÃO !!", "ALERT")
	
	// Chamado n. 051888 || OS 053228 || CONTROLADORIA || MONIK_MACEDO || 8956 || REL. INVESTIMENTO - FWNM - 09/10/2019
	UpItemCta()

	RestArea(_aArea)

Return(_lOk)

/*{Protheus.doc} Static Function SQLVERNOTACOMPRAORDEM
	Sem detalhamento
	@type  Function
	@author Sem autor
	@since 29/12/2017
	@version 01
	@history 
*/

Static Function SQLVerNotaCompraOrdem(cFil,cDocOrdem,cSerieOrdem,cItemOrdem,cFornece,cLoja)

	BeginSQL Alias "TRB"
		%NoPARSER%
		SELECT D1_DOC,
		D1_CF,
		D1_TES,
		D1_LOJA
		FROM SD1010
		WHERE D1_FILIAL               = %EXP:cFil%
		AND D1_DOC                  = %EXP:cDocOrdem%
		AND D1_SERIE                = %EXP:cSerieOrdem%
		AND D1_FORNECE              = %EXP:cFornece%
		AND D1_LOJA                 = %EXP:cLoja%
		AND D1_ITEM                 = %EXP:cItemOrdem%
		AND %Table:SD1%.D_E_L_E_T_ <> '*'
		
	EndSQl

RETURN(NIL)

/*{Protheus.doc} Static Function SQLVEROUTRACOMPRAORDEM
	Sem detalhamento
	@type  Function
	@author Sem autor
	@since 29/12/2017
	@version 01
	@history 
*/

Static Function SQLVerOutraCompraOrdem(cFil,cDocOrdem,cSerieOrdem,cItemOrdem,cFornece,cLoja)

	BeginSQL Alias "TRC"
		%NoPARSER%
		SELECT D1_DOC,
		D1_SERIE,
		D1_FORNECE,
		D1_LOJA,
		D1_CF,
		D1_TES,
		D1_LOJA
		FROM SD1010
		WHERE D1_FILIAL               = %EXP:cFil%
		AND D1_NFORDEM              = %EXP:cDocOrdem%
		AND D1_SERIORD              = %EXP:cSerieOrdem%
		AND D1_FORORDE              = %EXP:cFornece%
		AND D1_LOJAORD              = %EXP:cLoja%
		AND D1_ITEMORD              = %EXP:cItemOrdem%
		AND %Table:SD1%.D_E_L_E_T_ <> '*'
		
	EndSQl
	
RETURN(NIL)

/*{Protheus.doc} Static Function CHKCOMPL
	Valida NF de complemento
	@type  Function
	@author Everson
	@since 13/03/2019
	@version 01
	@history Chamado 047620 - Everson - 13/03/2019 - NF Complemento 
*/
"
Static Function ChkCompl(cTpCompl,cMsgErro,cDocO,cSerieO,cFornece,cLoja,cProduto,nQtd,nVlrTot,cPedCom,cItemPed)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local lRet		:= .T.
	Local cQuery	:= ""
	Local xPula		:= Chr(13) +  Chr(10)
	
	// *** INICIO CHAMADO 047918 || OS 049181 || FISCAL || ALLAN || 8394 || CENTRAL XML - COMPLE - WILLIAM COSTA 22/07/2019
	
	//Everson - Chamado TI - 31/03/2021.
	cQuery := ""
	cQuery += " SELECT SUM(D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA+D1_SEGURO+D1_ICMSRET-D1_VALDESC) AS TOTAL_NOTA, SUM(D1_QUANT) AS QUANT_NOTA, C7_TOTAL, C7_QUANT  " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SD1") + " AS SD1 " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SC7") + " AS SC7 ON " 
	cQuery += " D1_FILIAL = C7_FILIAL " 
	cQuery += " AND D1_PEDIDO = C7_NUM " 
	cQuery += " AND D1_FORNECE = C7_FORNECE " 
	cQuery += " AND D1_LOJA = C7_LOJA " 
	cQuery += " AND D1_ITEMPC = C7_ITEM " 
	cQuery += " AND D1_COD = C7_PRODUTO " 
	cQuery += " WHERE " 
	cQuery += " D1_FILIAL = '" + FwFilial("SD1") + "' " 
	cQuery += " AND D1_DOC = '" + Alltrim(cValToChar(cDocO)) + "' " 
	cQuery += " AND D1_SERIE = '" + Alltrim(cValToChar(cSerieO)) + "' " 
	cQuery += " AND D1_FORNECE = '" + Alltrim(cValToChar(cFornece)) + "' " 
	cQuery += " AND D1_LOJA = '" + Alltrim(cValToChar(cLoja)) + "' " 
	cQuery += " AND D1_COD = '" + Alltrim(cValToChar(cProduto)) + "' " 
	cQuery += " AND SD1.D_E_L_E_T_ = '' " 
	cQuery += " GROUP BY C7_TOTAL,C7_QUANT "
	Conout("MT100OLK - ChkCompl - cQuery " +  cQuery)
	
	//Everson - Chamado TI - 31/03/2021.
	/*
	cQuery := ""
	cQuery += " SELECT SUM(D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA+D1_SEGURO+D1_ICMSRET-D1_VALDESC) AS TOTAL_NOTA, SUM(D1_QUANT) AS QUANT_NOTA, C7_TOTAL, C7_QUANT " 
	cQuery += " FROM " + RetSqlName("SD1") + " AS SD1 " 
	cQuery += " INNER JOIN " + RetSqlName("SC7") + " AS SC7  " 
	cQuery += "         ON C7_FILIAL      = D1_FILIAL " 
	cQuery += "        AND C7_NUM         = D1_PEDIDO "
	cQuery += "        AND D1_ITEMPC      = C7_ITEM " 
	cQuery += "        AND SC7.D_E_L_E_T_ = '' "	
	cQuery += "      WHERE D1_FILIAL      = '" + FwFilial("SD1") + "' " 
	cQuery += "        AND D1_PEDIDO      = '" + Alltrim(cPedCom) + "' " 
	cQuery += "        AND D1_ITEM        = '" + Alltrim(cItemPed) + "' " 
	cQuery += "        AND SD1.D_E_L_E_T_ = '' "
	cQuery += "        GROUP BY C7_TOTAL,C7_QUANT "
	*/
	
	//
	If Select("V_QTD") > 0
		V_QTD->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "V_QTD"
	DbSelectArea("V_QTD")
		
		//
		If ! V_QTD->(Eof())

				// Chamado n. 048477 || OS 049755 || C. || TEREZA || (16)2106-3501 || COMPLEMENTO DE PRECO
				//If ( Val(cValToChar(nVlrTot)) + Val(cValToChar(V_QTD->VLRJE)) ) <> Val(cValToChar(V_QTD->C7_TOTAL))
				//Everson - Chamado TI - 31/03/2021.
				If (Val(cValToChar(Round(V_QTD->TOTAL_NOTA,2))) + Val(cValToChar(nVlrTot))) > Val(cValToChar(V_QTD->C7_TOTAL))
					lRet := .F.
					cMsgErro += "Valor de complemento inválido." + xPula + "Total pedido: " + cValToChar(V_QTD->C7_TOTAL) + xPula + "Valor já entregue: " + cValToChar(Round(V_QTD->TOTAL_NOTA,2)) + xPula + xPula
				
				EndIf

				//Everson - Chamado TI - 31/03/2021.
				If ( Val(cValToChar(V_QTD->QUANT_NOTA)) + Val(cValToChar(nQtd))) > Val(cValToChar(V_QTD->C7_QUANT))
					lRet := .F.
					cMsgErro += "Quantidade de complemento inválida." + xPula + "Qtd. pedido: " + cValToChar(V_QTD->C7_QUANT) + xPula + "Qtd. já entregue: " + cValToChar(V_QTD->QUANT_NOTA) + xPula
				
				EndIf
			
		EndIf
		
	V_QTD->(DbCloseArea())
	
	//
	RestArea(aArea)
	
	// *** FINAL CHAMADO 047918 || OS 049181 || FISCAL || ALLAN || 8394 || CENTRAL XML - COMPLE - WILLIAM COSTA 22/07/2019
	
Return lRet

/*{Protheus.doc} Static Function CHKZCN
	Checa Lote Recria - RNX2
	@type  Function
	@author Fernando Macieira
	@since 19/03/2019
	@version 01
	@history 
*/

Static Function ChkZCN()

	Local lRet     := .t.
	Local cEmpZCN  := GetMV("MV_#ZCNEMP",,"07")
	Local aAreaZCN := ZCN->( GetArea() )
	Local cLoteZCN := ""
	Local cCC      := ""

	Local aAreaSC7 := SC7->( GetArea() )
	Local cNumPC   := ""
	Local cItemPC  := ""

	// Empresas autorizadas
	If cEmpAnt $ cEmpZCN

		cCC := gdFieldGet("D1_CC", n)
	
		// Busca Lote recria do PC se nao foi informado
		cLoteZCN := gdFieldGet("D1_XLOTECC", n)
		If Empty(cLoteZCN)
			cNumPC  := gdFieldGet("D1_PEDIDO", n)
			cItemPC := gdFieldGet("D1_ITEMPC", n)
	
			SC7->( dbSetOrder(1) ) // C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
			If SC7->( dbSeek( FWxFilial("SC7")+cNumPC+cItemPC ) )
				gdFieldPut("D1_XLOTECC", SC7->C7_XLOTECC, n)
				gdFieldPut("D1_XDLOTCC", SC7->C7_XDLOTCC, n)
			EndIf
	    EndIf
		
		// Lote Recria informado
		cLoteZCN := gdFieldGet("D1_XLOTECC", n)
		If !Empty(cLoteZCN)

			ZCN->( dbSetOrder(1) ) // ZCN_FILIAL+ZCN_LOTE                                                                                                                                             
			If ZCN->( dbSeek( FWxFilial("ZCN")+cLoteZCN ) )
			
				// Consisto lote encerrado
				If AllTrim(ZCN->ZCN_STATUS) == "E" 
					lRet := .f.
					Alert("[MT100LOK-ZCN1] - Lote Recria com status Encerrado! Contate a contabilidade...")
				EndIf
				
				// Consisto CC informado
				If lRet
					If AllTrim(cCC) <> AllTrim(ZCN->ZCN_CENTRO)
					  lRet := .f.
					  Alert("[MT100LOK-ZCN2] - Lote Recria não amarrado com o Centro de Custo informado! Contate a contabilidade...")
					EndIf
				EndIf
				
			Else
			
				// Lote informado nao cadastrado na ZCN
				lRet := .f.
				Alert("[MT100LOK-ZCN3] - Lote Recria não cadastrado! Contate a contabilidade...")

			EndIf

		EndIf
		
		// Chamado n. 048414 || OS 049698 || CONTROLADORIA || ANDRESSA || 45968437 || NOTAS -LOTE RNX2 - FWNM - 10/04/2019
		// CC informado
		If lRet
			If !Empty(cCC)

				ZCN->( dbSetOrder(2) ) // ZCN_FILIAL+ZCN_DESCLT
				If ZCN->( dbSeek( FWxFilial("ZCN")+cCC ) )
				
					If Empty(cLoteZCN)
						lRet := .f.  
						Alert("[MT100LOK-ZCN4] - Centro de Custo informado possui Lote Recria amarrado! Informe o Lote Recria ou contate a contabilidade...")
					EndIf
		
				EndIf
	
			EndIf
		EndIf
		//
	
	EndIf
	
	RestArea( aAreaZCN )
	RestArea( aAreaSC7 )

Return lRet

/*{Protheus.doc} Static Function UPITEMCTA
	RNX2  Item 111
	Ceres  Item 121
	EGG item 112
	Adoro
	Filial 01 item 121
	Filial 02 item 121
	Filial 03 item 114, se for C. de Custo 5131 = item 113
	Filial 04 item 112
	Filial 05 item 114
	Filial 08 item 115
	Att,
	Luiz Guilherme Roncoletta de Oliveira 
	Adoro S/A - Controladoria 
	55 (11) 4596-8465 
	@type  Function
	@author Fernando Macieira
	@since 19/03/2019
	@version 01
	@history Chamado 051888 - FWNM - 09/10/2019 - REL. INVESTIMENTO
*/
Static Function UpItemCta()
	
	// Criar parametro por filial na empresa Adoro e compartilhado nas demais empresas
	Local cItemCta   := GetMV("MV_#ITEMCT",,"")
	Local cCusto     := gdFieldGet("D1_CC", n)
	Local cMVItemCta := ""

	// Excecao
	If cFilAnt == "03" .and. AllTrim(cCusto) == "5131"
		cItemCta := GetMV("MV_#ITEM03",,"113")
	EndIf

	// @history ticket   68971 - Fer Macieira - 02/03/2022 - Integração Notas Centro de Custo 5134 - Item 113
	cMVItemCta := GetMV("MV_#ITM113",,"113")
	If AllTrim(cCusto) $ GetMV("MV_#CC5134",,"5134")
		cItemCta := cMVItemCta
	EndIf
	//

	// @history ticket 71057 - Fernando Macieira - 08/04/2022 - Item contábil Lançamentos da Filial 0B - Itapira
	If AllTrim(cEmpAnt) == "01" .and. AllTrim(cFilAnt) == "0B"
		cItemCta := AllTrim(GetMV("MV_#ITACTD",,"125"))
	EndIf
	//

	// @history ticket 74027 - TI                - 22/06/2022 - Pedido de Compra e Documento de Entrada CC 5318 - Item 111
	If AllTrim(cCusto) == "5318" .or. Left(AllTrim(cCusto),1) == "7"
		cItemCta := "111"
	EndIf
	//

	If !Empty(cItemCta)
		gdFieldPut("D1_ITEMCTA", cItemCta, n)
	Else
		msgAlert("Parâmetro MV_#ITEMCT não existe ou não possui item contábil definido para esta filial... O item contábil ficará errado! Contate a contabilidade...")
	EndIf

Return

//Inicio Chamado 053636 - Abel Babini     - 10/01/2020 - Validação Entrada
/*{Protheus.doc} Static Function VerCCPrd
	Retorna relação de Centros de Custos Produtivos
	@type  Function
	@author Abel Babini
	@since 10/01/2020
	@version 01
*/
Static Function VerCCPrd()
	Local cCCPrd	:= ''
	Local cAlB00Es

	If Select(cAlB00Es) > 0
		(cAlB00Es)->(dbCloseArea())
	Endif
	cAlB00Es:=GetNextAlias()

	BeginSQL  Alias cAlB00Es
		SELECT 
			CTT_CUSTO
		FROM %TABLE:CTT% CTT
		WHERE
			CTT.%notDel%
		AND CTT_XPRODU = '1'
		AND CTT_CLASSE = '2'
	EndSQL
	
	//Monta Arrays Auxiliares
	DbSelectArea(cAlB00Es)
	(cAlB00Es)->(DbGoTop())
	While !(cAlB00Es)->(eof())
		cCCPrd := cCCPrd+ALLTRIM((cAlB00Es)->CTT_CUSTO)+","
		(cAlB00Es)->(DbSkip())
	EndDo
	(cAlB00Es)->(dbCloseArea())

Return cCCPrd

//Fim Chamado 053636 - Abel Babini     - 10/01/2020 - Validação Entrada
