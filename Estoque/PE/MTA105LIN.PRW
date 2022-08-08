#INCLUDE "protheus.ch"

/*/{Protheus.doc} User Function MTA105LIN
    LOCALIZACAO: Function A105LinOk() - Validar a linha da Solicitação ao Almoxarifado digitada.
    DESCRICAO : Pode ser utilizado para validar os dados na linha da solicitação ao almoxarifado digitada.             
    UTILIZACAO: Se tiver marcado o campo CP_XTIPO == T verifica Saldo em estoque cria armazem na SB2 e obriga a digitacao 
    dos campos CP_XLOCDES e CP_XPRODES Local e Produto Destino
    @author Heverson Gomes
    @since 22/04/2008
    @history chamado 046284 - FWNM     		- 08/01/2019 - Novas regras alteracao valor
    @history chamado 047931 - FWNM     		- 20/03/2019 - OS 049195 || CONTROLADORIA || ANDRESSA || 45968437 || C.CUSTO X LOTE -RNX2
    @history chamado 048414 - FWNM     		- 10/04/2019 - OS 049698 || CONTROLADORIA || ANDRESSA || 45968437 || NOTAS -LOTE RNX2
    @history chamado 051136 - William  		- 16/08/2019 - OS 052452 || CONTROLADORIA || REINALDO || 8947 || REQUISICAO X C.CUSTO - INCLUSAO DE TRAVA PARA LANCAMENTO DE SOLICITACAO DE ARMAZEM SE O USUARIO NAO ESTIVER COM LIBERACAO DE CENTOR DE CUSTO 
    @history chamado 050722 - William  		- 26/08/2019 - OS 052025 || MANUTENCAO || DEBORA || 8935 || DEBORA MANUTENCAO - SOLICITADO PELA MANUTENCAO A CRIACAO DE UM CAMPO NA SOLICITACAO AO ARMAZEM DE CODIGO DO BEM QUANDO FOR O CENTRO DE CUSTO 5304 OBRIGAR A DIGITAR O CODIGO DO BEM. 
    @history chamado 055188 - FWNM     		- 18/02/2020 - OS 056599 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || NOVA OPERACAO VENDA
	@history chamado 053926 - Everson    	- 28/02/2020 - Tratamento para lançamento automático de solicitação ao armazém.
	@history chamado T.I    - Tiago Sttoco	- 13/05/2020 - Tratamento para validar somente na inclusao da s.a
	@history chamado 058732 - Everson     	- 16/06/2020 - Tratamento para lançamento automático de solicitação ao armazém VP.
	@history chamado 059784 - Abel Babini 	- 21/07/2020 - Retirar obrigatoriedade do campo CP_XCODBEM
	@history chamado 999    - William Costa	- 10/09/2020 - Ajustado a mensagem de erro que mostra na tela do usuario de codigo do bem para numero da ordem de produção.
	@history chamado 3113   - William Costa	- 08/10/2020 - Adicionado validação para pedir a ordem de produção, somente para a empresa Adoro, filial de várzea, as outras empresas e filiais não obrigar a informar ordem de produção evitando erros de saida de estoque errada
	@history ticket  6467   - Fernando Maci - 14/12/2020 - Erro Rotina Solicitação ao Armazem - MATA105
	@history ticket  T.I.   - Tiago Stoco	- 26/02/2021 - Correção de fontes.
    @history ticket   15402 - Fernando Maci	- 10/06/2021 - REQUISIÇÕES ALMOXARIFADO - CC 5131 FILIAL 03
	@history ticket   19122 - Sigoli	    - 21/09/2021 - REQUISIÇÕES ALMOXARIFADO - CC 5318 - item contabil 111 - FILIAL 03
	@history ticket 71057 - Fernando Macieira - 08/04/2022 - Item contábil Lançamentos da Filial 0B - Itapira
	@history ticket 77603 - Fernando Macieira - 04/08/2022 - Ceres - Solicitação Almoxarifado - Requisições - Vinculação item contábil 124
/*/
User Function MTA105LIN()

	Local _aArea 	  := GetArea()
	Local _AreaSCP	  := SCP->(GetArea())
	Local lRet   	  := .T.
	Local _nPositem	  := ASCAN(aHeader, {|x| Alltrim(x[2]) == "CP_ITEMCTA" })
	Local _nPosGrp	  := ASCAN(aHeader, {|x| Alltrim(x[2]) == "CP_GRUPO"   }) //Everaldo Casaroli 11/11/2008
	Local nPosCC	  := ASCAN(aHeader, {|x| Alltrim(x[2]) == "CP_CC"      }) //Everaldo Casaroli 11/11/2008
	Local _NPOSPROJ   := ASCAN(aHeader, {|x| ALLTRIM(x[2]) == "CP_CONPRJ"  })
	Local _NPOSCProj  := ASCAN(aHeader, {|x| ALLTRIM(x[2]) == "CP_CODPROJ" })
	Local nLocal      := ASCAN(aHeader, {|x| ALLTRIM(x[2]) == "CP_LOCAL"   })
	Local nProduto    := ASCAN(aHeader, {|x| ALLTRIM(x[2]) == "CP_PRODUTO" })
	Local nXLocDes    := ASCAN(aHeader, {|x| ALLTRIM(x[2]) == "CP_XLOCDES" })
	Local nXProDes    := ASCAN(aHeader, {|x| ALLTRIM(x[2]) == "CP_XPRODES" })
	Local nPosQuant   := ASCAN(aHeader, {|x| ALLTRIM(x[2]) == "CP_QUANT"   })
	Local nPosXtipo   := ASCAN(aHeader, {|x| ALLTRIM(x[2]) == "CP_XTIPO"   })
	Local nPosOP  	  := ASCAN(aHeader, {|x| ALLTRIM(x[2]) == "CP_OP" })
	Local _ItemCta	  := SuperGetMV("MV_AD_ITEM") // ITEM CONTABIL PERMITIDO NA FILIAL
	Local nQtdEstoque := 0
	
	// FWNM - 02/03/2018 - Projetos Investimentos
	Local lSldAtv  := GetMV("MV_#PRJSLD",,".T.")
	//Local cFasePrj := GetMV("MV_PRJINIC",,"05")
	
	// Chamado n. 046284
	//Local cFaseRej := GetMV("MV_#FASREJ",,"01")
	Local cFaseApr := GetMV("MV_#FASEOK",,"03")
	// 
	Local lValidUser := .F.

	// Chamado n. 055188 || OS 056599 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || NOVA OPERACAO VENDA - FWNM - 17/02/2020
	Local lManut    := AllTrim(gdFieldGet("CP_XTIPO",n))=="M" 
	Local cCCusto   := GetMV("MV_#MANUCC",,"5304")
	Local cLocMan   := GetMV("MV_#MANLO2",,"02")
	Local cUsrManut := GetMV("MV_#MANUSU",,"001428") 
    Local cLocalMan := GetMV("MV_#MANLOC",,"48")
	Local i         := 0 
	Local y			:= 0
	//@history ticket 6467   - Fernando Maci - 14/12/2020 - Erro Rotina Solicitação ao Armazem - MATA105
	If lCopia
		gdFieldPut("CP_EMISSAO", dDatabase, n)		
	EndIf
	//
	
	// VERIFICA se item contabil é permitido na filial
	if  !alltrim(aCols[n,_nPosItem]) $ _ItemCta
		MsgAlert("Item Contabil " + acols[n,_nPosItem] + " nao permitido nesta filial !")
		lRet:= .F.
	endif

	//&&Chamado 006786 - Mauricio 14/05/10.
	// Valida caso seja digitado projeto se o centro de custo inicia por 9.Chamado
	if  !(Empty(aCols[n,_NPOSPROJ])) .AND. Substr(aCols[n,nPosCC],1,1) <> "9"
		MsgAlert("O centro de custo " + alltrim(aCols[n,nPosCC]) + " nao permite utilizar codigo de projeto.")
		lRet:= .F.
	endif
	
	//Valida a Conta Contabil - Everaldo Casaroli 11/11/2008 em substituicao ao AD0205.PRW
	dbSelectArea("SZ0")
	dbSetOrder(1)
	If !SZ0->(dbSeek( xFilial("SZ0") + aCols[n,nPosCC] + aCols[n,_nPosGrp]))
		Alert("Centro de Custo "+alltrim(aCols[n,nPosCC])+" x Grupo "+alltrim(aCols[n,_nPosGrp])+" Nao autorizado")
		lRet:= .F. 
	endif
	//Everaldo Casaroli 11/11/2008 - fim
	
	// *** INICIO WILLIAM COSTA 16/08/2019 CHAMADO 051136 || OS 052452 || CONTROLADORIA || REINALDO_FRANCISCHINELLI || 8947 || REQUISICAO X C.CUSTO *** // 
	
	//Pesquisa no PAE se existe a amarração usuário x centro de custo                         
	DBSELECTAREA("PAE")
	DBSETORDER(1)
	IF DBSEEK(FWxFilial("PAE")+__cUserId, .T.)
	
        WHILE PAE->(!EOF()) .AND. PAE->PAE_FILIAL == FWxFilial("PAE") .AND. PAE->PAE_CODUSR == __cUserId
            
            IF aCols[n,nPosCC]   >= PAE->PAE_CCINI  .AND.; 
                aCols[n,nPosCC]   <= PAE->PAE_CCFIM  .AND.;
                aCols[n,_nPosGrp] >= PAE->PAE_GRPINI .AND.; 
                aCols[n,_nPosGrp] <= PAE->PAE_GRPFIM
                
                lValidUser	:= .T.
                
            ENDIF
            
            PAE->(DBSKIP())
            
        ENDDO
	
	ELSE
	
		lValidUser	:= .F.
	
	ENDIF
	
	IF lValidUser == .F. .And. ! isInCallStack("U_ADEST043P") .And. ! isInCallStack("U_ADLOG022P")//Everson - 28/02/2020. Chamado 053926. //Everson - 16/06/2020. Chamado 058732 .
	
		Aviso("MT105LIN",;
		      "O centro de custo informado não esta autorizado para o usuário." + Chr(13) + Chr(10) +;
		      "Selecione um centro de custo válido para o usuário. Case Necessário ligue para a Controladoria Liberar o Centro de Custo",;
		      {"&Retorna"}, 2,;
		      "Centro de Custo: " + ALLTRIM(aCols[n,nPosCC]) + ' e Grupo de Produto: ' + ALLTRIM(aCols[n,_nPosGrp]))
		lRet:= .F.
		
	ENDIF
	
	// *** FINAL WILLIAM COSTA 16/08/2019 CHAMADO 051136 || OS 052452 || CONTROLADORIA || REINALDO_FRANCISCHINELLI || 8947 || REQUISICAO X C.CUSTO *** //
	
	//&&Valida se o projeto esta encerrado ou nao
	DbSelectArea("AF8")
	DbSetOrder(1)
	if dbseek(xFilial("AF8")+ACOLS[N,_NPOSPROJ])
		if AF8->AF8_ENCPRJ == "1"
			MsgAlert("O Projeto "+ACOLS[N,_NPOSPROJ]+" se encontra ENCERRADO e nao aceita mais lancamentos.")
			lRet:= .F.
		endif
	endif
	
	//Obriga informar o codigo do projeto se o campo Projeto estiver preenchido               
	If cEmpAnt == "01"
		//If !Empty( ACOLS[N,_NPOSPROJ] ) .And. Empty(ACOLS[N,_NPOSCProj])
		If SubStr(ACOLS[N,nPosCC], 1, 1) == "9" .And. Empty(ACOLS[N,_NPOSCProj])
			Aviso(	"MTA105LIN",;
			"Projeto: " + ACOLS[N,_NPOSCProj] + "." + Chr(13) + Chr(10) +;
			"É obrigatório o preenchimento do Codigo do Projeto.",;
			{ "&Retorna" },,;
			"Conteúdo em Branco" )
			lRet	:= .F.
		ElseIf Empty(ACOLS[N,_NPOSPROJ]) .And. !Empty(ACOLS[N,_NPOSCProj])
			aCols[n,aScan(aHeader,{|x| AllTrim(x[2]) == "CP_CODPROJ"})] := "   "
		EndIf
	Endif
	
    // Chamado n. 055188 || OS 056599 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || NOVA OPERACAO VENDA - FWNM - 18/02/2020
	If lManut 

	    // consisto logins permitidos
        If !(__cUserID $ cUsrManut)
            lRet := .f.
            MsgStop("Solicitação de Armazém de Transferência de Manutenção não está autorizado, parâmetro MV_#MANUSU", "[MTA105LIN-01] - Transferência de Manutenção - Login")
        EndIf

	    // consisto almoxarifado origem
		If lRet
			If !(AllTrim(gdFieldGet("CP_LOCAL",n)) $ cLocMan)
			    lRet := .f.
				MsgStop("Solicitação de Armazém de Transferência de Manutenção precisa estar contido no almoxarifado " + cLocMan, "[MTA105LIN-02] - Transferência de Manutenção - Almoxarifado origem")
			EndIf
		EndIf

        // consisto CCusto permitido
        If lRet
            If !(AllTrim(gdFieldGet("CP_CC",n)) $ cCCusto)
                lRet := .f.
                MsgStop("Solicitação de Armazém de Transferência de Manutenção precisa estar contido no CCusto " + cCCusto, "[MTA105LIN-03] - Transferência de Manutenção - Centro Custo")
            EndIf
        EndIf

        // Consisto local destino
        If Empty(AllTrim(aCols[n,nXLocDes])) .or. !(AllTrim(aCols[n,nXLocDes]) $ cLocalMan)
            lRet := .f.
            MsgStop("Solicitação de Armazém de Transferência de Manutenção precisa ter algum destes locais de destino informado " + cLocalMan, "[MTA105LIN-04] - Transferência de Manutenção - Local Destino")
        EndIf
                
        // Consisto locais origem x destino
        If AllTrim(aCols[n,nXLocDes]) == AllTrim(aCols[n,nLocal])
            lRet := .f.
            MsgStop("Solicitação de Armazém de Transferência de Manutenção precisa ter local origem diferente do destino", "[MTA105LIN-05] - Transferência de Manutenção - Local Origem x Destino")
        EndIf
                
        // Consisto produto destino
        If Empty(AllTrim(aCols[n,nXProDes]))
            lRet := .f.
            MsgStop("Solicitação de Armazém de Transferência de Manutenção precisa ter produto destino informado", "[MTA105LIN-06] - Transferência de Manutenção - Produto Destino")
        EndIf

    Else

        // *** INICIO BLOCO K CHAMADOS 029892 E 037716 - WILLIAM COSTA 17/11/2017 *** //
        IF __cUserID $ GETMV("MV_#USUTRA")
            
            IF ALLTRIM(ACOLS[n,nPosXtipo]) == 'T'
                
                IF ALLTRIM(ACOLS[n,nXLocDes]) == ''
                    
                    ALERT("MTA105LIN - Devido a Ser uma Transferência, necessário informar o campo Local Destino, favor verificar!!!")
                    
                    lRet := .F.
                    
                ENDIF
                
                IF ALLTRIM(ACOLS[n,nXLocDes]) == ALLTRIM(ACOLS[n,nLocal])
                    
                    ALERT("MTA105LIN - Devido a Ser uma Transferência, necessário informar o campo Local Destino diferente de Local Origem, favor verificar!!!")
                    
                    lRet := .F.
                    
                ENDIF
                
                IF ALLTRIM(ACOLS[n,nXProDes]) == ''
                    
                    ALERT("MTA105LIN - Devido a Ser uma Transferência, necessário informar o campo Produto Destino, favor verificar!!!")
                    
                    lRet := .F.
                    
                ENDIF
                
                IF !(ALLTRIM(ACOLS[n,nPosCC]) $ GETMV("MV_#CCTRAN"))
                    
                    ALERT("MTA105LIN - Devido a Ser uma Transferência, liberado somente esses centro de Custos: " + GETMV("MV_#CCTRAN") + ", favor verificar!!!")
                    
                    lRet := .F.
                    
                ENDIF
                
                // *** INICIO CHAMADO 038430 WILLIAM COSTA *** //

                // travar para aceitar produtos somente que pertence aos grupo 9006/9007/9037.
                IF !(Posicione("SB1",1,xFilial("SB1")+ALLTRIM(ACOLS[n,nProduto]),"B1_GRUPO")  $ GETMV("MV_#GPTRAN"))
                    
                    ALERT("MTA105LIN - Devido a Ser uma Transferência, liberado somente esses Grupos de Produtos: " + GETMV("MV_#GPTRAN") + ", favor verificar!!!")
                    
                    lRet := .F.
                    
                ENDIF
                
                // Resolver caso do local destino estar indo em branco
                IF ACOLS[n,nXLocDes] == ''
                    ACOLS[n,nXLocDes] := '03    '
                ENDIF
                
                // Resolver caso do produto destino estar indo em branco
                IF ACOLS[n,nXProDes] == ''
                    ACOLS[n,nXProDes] := ACOLS[n,nProduto]
                ENDIF

                // *** FINAL CHAMADO 038430 WILLIAM COSTA *** //

            EndIf

        EndIf

    EndIf

    // Consistências para destino
    If lManut .or. AllTrim(gdFieldGet("CP_XTIPO",n))=="T"

        IF lRet == .T.
                    
            DbSelectArea("SB2")
            SB2->(DbSetOrder(1))
            If !SB2->(DbSeek( xFilial("SB2") + ACOLS[n,nXProDes] + ACOLS[n,nXLocDes],.T.))
                IF MsgNoYes( "Deseja Criar o Produto no armazem de destino?")
                    CriaSB2(ACOLS[n,nXProDes],ACOLS[n,nXLocDes])
                ELSE
                    SB2->( DBCLOSEAREA() )
                    lRet := .F.
                    RETURN(lRet)
                ENDIF
            ENDIF
                    
            SB2->( DBCLOSEAREA() )
        
        ENDIF
        
        IF lRet == .T.
                    
            DbSelectArea("SB2")
            SB2->(DbSetOrder(1))
            IF SB2->(DbSeek( xFilial("SB2") + ACOLS[n,nProduto] + ACOLS[n,nLocal],.T.))
                nQtdEstoque := SaldoMov(Nil,Nil,Nil,.T.,Nil,Nil,Nil,dDatabase) - ACOLS[n,nPosQuant]
            ENDIF
                    
            IF nQtdEstoque < 0
                Alert("MTA105LIN - Operação não permitida! Produto ficara com estoque negativo! " + "["+ alltrim(ACOLS[n,nProduto])+"/"+ Alltrim(ACOLS[n,nLocal]) + "]" ,"Atencao")
                SB2->( DBCLOSEAREA() )
                lRet := .F.
            ENDIF
                    
            SB2->( DBCLOSEAREA() )
                    
        ENDIF

    	// *** FINAL BLOCO K CHAMADOS 029892 E 037716 - WILLIAM COSTA 17/11/2017 *** //
	
    EndIf
	
	// Projetos - FWNM - 06/04/2018
	If lRet
		
		If !gdDeleted(n)
			
			dDtDig  := msDate()
			
			cPrj    := gdFieldGet("CP_CONPRJ", n)
			cCC     := gdFieldGet("CP_CC", n)
			
			lPrjInv := Left(AllTrim(cCC),1) == "9"
			
			// Qdo for prj investimento
			If lPrjInv .and. ( !Alltrim(cCC) $ GetMV("MV_#CCPADR") )
				
				If Empty(cPrj)
					lRet := .f.
					
					Aviso(	"MTA105LIN-06",;
					"Centro de Custo: " + cCC + "." + Chr(13) + Chr(10) +;
					"É obrigatório o preenchimento do Projeto.",;
					{ "&Retorna" },,;
					"Conteúdo em Branco" )
				EndIf
				
				// Consiste CC permitidos para aquele projeto (ZC1)
				If lRet
					
					ZC1->( dbSetOrder(1) ) // ZC1_FILIAL+ZC1_PROJET+ZC1_CC
					If ZC1->( !dbSeek(xFilial("ZC1")+cPrj+cCC) )
						
						lRet := .f.
						
						Aviso(	"MTA105LIN-03",;
						"Centro Custo não permitido para este projeto! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
						"CC: " + cCC + " - " + Posicione("CTT",1,xFilial("CTT")+cCC,"CTT_DESC01") + chr(13) + chr(10) +;
						"Projeto: " + cPrj + " - " + AF8->AF8_DESCRI,;
						{ "&Retorna" },,;
						"Projeto x CC permitidos" )
						
					EndIf
					
				EndIf
				
				// Consiste filial/planta permitida para aquele CC
				If lRet
					
					If Left(AllTrim(cPrj),2) <> cFilAnt
						
						lRet := .f.
						
						Aviso(	"MTA105LIN-04",;
						"Este projeto n. " + AllTrim(cPrj) + " não pertence a esta filial! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
						"Filial/Planta: " + cFilAnt + chr(13) + chr(10) +;
						"Projeto/Planta: " + Left(AllTrim(cPrj),2),;
						{ "&Retorna" },,;
						"Projeto x Filial/Planta" )
						
					EndIf
					
				EndIf
				
				// Consistencia valores/saldos, fase e vigencia
				If lRet
					
					If !Empty(cPrj)
						
						AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
						If AF8->( dbSeek(xFilial("AF8")+cPrj) )
							
							// Consistencia do projeto
							If lSldAtv
								
								// Consiste apenas projetos que possuem valor
								If AF8->AF8_XVALOR > 0
									
									// Consiste fase do projeto para checar se esta na central de aprovacao
									//If AllTrim(cFasePrj) == AllTrim(AF8->AF8_FASE) // Chamado n. 046284
									If AllTrim(AF8->AF8_FASE) <> AllTrim(cFaseApr) // Se fase diferente de aprovada // Chamado n. 046284

										lRet := .f.
										
										Aviso(	"MTA105LIN-01",;
										"Projeto n. " + AllTrim(cPrj) + " não foi aprovado na Central de Aprovação! " + chr(13) + chr(10) + "Uso ainda não permitido..." + chr(13) + chr(10) + ;
										"",;
										{ "&Retorna" },,;
										"Projeto não aprovado" )
										
									EndIf
									
									If lRet
							
										// Consiste datas previstas do projeto (AF8) x data de digitação oriunda do servidor do documento
										If dDtDig < AF8->AF8_START .or. dDtDig > AF8->AF8_FINISH
											
											lRet := .f.
											
											Aviso(	"MTA105LIN-02",;
											"Vigência do projeto n. " + AllTrim(cPrj) + " está fora! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
											"Data Digitação: " + DtoC(dDtDig) + chr(13) + chr(10) +;
											"Início-Fim Projeto: " + DtoC(AF8->AF8_START) + " - " + DtoC(AF8->AF8_FINISH),;
											{ "&Retorna" },,;
											"Vigência do Projeto" )
											
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					
					// Grava valor do projeto
					nQtd   := gdFieldGet("CP_QUANT", n)
					cProd  := gdFieldGet("CP_PRODUTO", n)
					cAlm   := gdFieldGet("CP_LOCAL", n)
					
					nPrjVlr := UpSB2(cProd, cAlm, nQtd)
					
					If nPrjVlr > 0
						gdFieldPut("CP_XPRJVLR", nPrjVlr, n)
						
					Else
						lRet := .f.
						Aviso(	"MTA105LIN-05",;
						"Projeto n. " + AllTrim(cPrj) + " não foi valorizado... Custo médio no SB2 zerado!" + chr(13) + chr(10) + ;
						"",;
						{ "&Retorna" },,;
						"Projeto sem valor" )
						
					EndIf
					
					// Consistencia do projeto
					If lSldAtv
						
						AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
						AF8->( dbSeek(xFilial("AF8")+cPrj) )
						
						// Consiste apenas projetos que possuem valor
						If AF8->AF8_XVALOR > 0
							
							If lRet
								
								// Consiste saldo projeto
								nSldPrj := u_ADCOM017P(cPrj)
								
								If nPrjVlr > nSldPrj
									
									lRet := .f.
									
									Aviso(	"MTA105LIN-08",;
									"Saldo do projeto n. " + AllTrim(cPrj) + " insuficiente! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
									"[SA] Líquido: " + Transform(nPrjVlr, PesqPict("SCP","CP_XPRJVLR")) + chr(13) + chr(10) +;
									"[PRJ] Saldo: " + Transform(nSldPrj, PesqPict("SCP","CP_XPRJVLR")),;
									{ "&Retorna" },,;
									"Projeto sem saldo" )
									
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
				
			Else
				
				If !Empty(cPrj)
					lRet := .f.
					
					Aviso(	"MTA105LIN-07",;
					"Centro de Custo: " + cCC + "." + Chr(13) + Chr(10) +;
					"Não permitido o preenchimento do Projeto.",;
					{ "&Retorna" },,;
					"Não permitido informar projeto para CC que não é investimento" )
				EndIf
			EndIf
		EndIf
	EndIf
	
	// FWNM - 23/03/2018 - Totaliza projetos informados nos itens para confrontar com o saldo do mesmo
	If lRet
		
		// Controle Saldo Projeto ativo
		If lSldAtv
			
			aTtPrj := {} // armazenará os dados do projeto para totalizar e consistir
			
			For i:=1 to Len(aCols)
				
				If !gdDeleted(i)
					
					cPrj    := gdFieldGet("CP_CONPRJ", i)

                    // @history ticket   15402 - Fernando Maci	- 10/06/2021 - REQUISIÇÕES ALMOXARIFADO - CC 5131 FILIAL 03
                    If AllTrim(cEmpAnt) == "01" .and. AllTrim(cFilAnt) == "03" 
					
						If AllTrim(gdFieldGet("CP_CC", i)) $ GetMV("MV_#SCPCC",,"5131")
						
							gdFieldPut("CP_ITEMCTA", GetMV("MV_#CPITCT",,"113"), i)
						
						ElseIf AllTrim(gdFieldGet("CP_CC", i)) $ GetMV("MV_#SCPC2",,"5318") //ticket   19122 - Sigoli -  21/09/2021	
						
							gdFieldPut("CP_ITEMCTA", GetMV("MV_#CPITCT",,"111"), i)
						
						EndIf
					
					EndIf
                    //

					// @history ticket 71057 - Fernando Macieira - 08/04/2022 - Item contábil Lançamentos da Filial 0B - Itapira
					If AllTrim(cEmpAnt) == "01" .and. AllTrim(cFilAnt) == "0B"
						gdFieldPut("CP_ITEMCTA", AllTrim(GetMV("MV_#ITACTD",,"125")), i)
					EndIf
					//

					If !Empty(cPrj)
						
						// Projeto Investimento
						cCC     := gdFieldGet("CP_CC", i)
						lPrjInv := Left(AllTrim(cCC),1) == "9"
						
						If lPrjInv .and. !Alltrim(cCC) $ GetMV("MV_#CCPADR")
							
							nTt     := gdFieldGet("CP_XPRJVLR", i)
							
							// Valor do projeto do item
							nTtPrj := nTt
							
							aAdd( aTtPrj, {	cPrj,;
							nTtPrj } )
							
						EndIf
					EndIf
				EndIf
			Next i
			
			// Consiste total projeto
			aSort( aTtPrj,,, { |x,y| x[1] < y[1] } )
			
			cColsPrj := ""
			nColsTot := 0
			
			For y:=1 to Len(aTtPrj)
				
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
								
								// Consiste saldo informado no documento de entrada x saldo do projeto (AF8)
								nSldPrj := u_ADCOM017P(cColsPrj)
								
								If nColsTot > nSldPrj
									
									lRet := .f.
									
									Aviso(	"MTA105LIN-09",;
									"Saldo do projeto n. " + AllTrim(cColsPrj) + " insuficiente! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
									"[SA] Tt Líquido itens: " + Transform(nColsTot, PesqPict("SCP","CP_XPRJVLR")) + chr(13) + chr(10) +;
									"[PRJ] Saldo: " + Transform(nSldPrj, PesqPict("SCP","CP_XPRJVLR")),;
									{ "&Retorna" },,;
									"Projeto sem saldo" )
									
								Else
									// zero variaveis para proximo projeto
									cColsPrj := aTtPrj[y,1]
									nColsTot := aTtPrj[y,2]
									
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Next y
			
			// Consisto o último projeto do acols - NÃO RETIRAR !!!
			If lRet
				
				AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
				If AF8->( dbSeek(xFilial("AF8")+cColsPrj) )
					
					// Consistencia do projeto
					If lSldAtv
						
						// Consiste apenas projetos que possuem valor
						If AF8->AF8_XVALOR > 0
							
							// Consiste saldo informado no documento de entrada x saldo do projeto (AF8)
							nSldPrj := u_ADCOM017P(cColsPrj)
							
							If nColsTot > nSldPrj
								
								lRet := .f.
								
								Aviso(	"MTA105LIN-10",;
								"Saldo do projeto n. " + AllTrim(cColsPrj) + " insuficiente! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
								"[SA] Tt Líquido itens: " + Transform(nColsTot, PesqPict("SCP","CP_XPRJVLR")) + chr(13) + chr(10) +;
								"[PRJ] Saldo: " + Transform(nSldPrj, PesqPict("SCP","CP_XPRJVLR")),;
								{ "&Retorna" },,;
								"Projeto sem saldo" )
								
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
	// Chamado n. 047931 || OS 049195 || CONTROLADORIA || ANDRESSA || 45968437 || C.CUSTO X LOTE -RNX2 - FWNM - 20/03/2019
	If lRet
		lRet := ChkZCN()
	EndIf
	// 
	
	// *** INICIO WILLIAM COSTA 26/08/2019 CHAMADO 050722 || OS 052025 || MANUTENCAO || DEBORA || 8935 || DEBORA MANUTENCAO *** // 
	
	IF lRet == .T. .AND. Alltrim(FunName())== "MATA105" // Tiago Sttoco - 13/05/2020 - Trtamento para validar somente na inclusao da s.a
	
		// *** INICIO Chamado 059784 - Abel Babini 	- 21/07/2020 - Retirar obrigatoriedade do campo CP_XCODBEM, e acrescentada Obrigatoriedade do campo CP_OP
		// *** INICIO Chamado 8580 - Tiago Stocco - 26/02/21 - Adicionado a Empresa 02 Ceres para não zerar o campo OP e obrigar a OP quando for da manutenção.
		IF (cEmpAnt == '01' .AND. cFilAnt == '02') .or. cEmpAnt == '02'
		
			IF ALLTRIM(aCols[n,nPosOP]) == ''

				IF ALLTRIM(aCols[n,nPosCC]) $ GetMV("MV_#CCSOAR",,'5304')
				
					IF ALLTRIM(aCols[n,_nPosGrp]) $ GetMV("MV_#GPSOAR",,'9023/9024/9052/9053')
					
						lRet := .T.
					
					ELSE
					
						Aviso("MTA105LIN-11",;
							"Obrigatorio Informar a Ordem de Produção, para o centro de custo 5304"+ chr(13) + chr(10) +  chr(13) + chr(10),;
							{ "&Retorna" },,;
							"Ordem de Produção sem informação" )
					
						lRet := .F.
					
					ENDIF
				ENDIF
			ENDIF

		ELSE

			aCols[n,nPosOP] := '' // Limpa o campo de Op enquanto não está instalado em outras empresas

		ENDIF
	ENDIF
	
	// *** FINAL WILLIAM COSTA 26/08/2019 CHAMADO 050722 || OS 052025 || MANUTENCAO || DEBORA || 8935 || DEBORA MANUTENCAO *** //

	// @history ticket 77603 - Fernando Macieira - 04/08/2022 - Ceres - Solicitação Almoxarifado - Requisições - Vinculação item contábil 124
	If AllTrim(FWCodEmp()) == "02"
		gdFieldPut("CP_ITEMCTA", GetMV("MV_#CPIT02",,"124"), n)
	EndIf

	RestArea(_AreaSCP)
	RestArea(_aArea)

Return(lRet)

/*/{Protheus.doc} Static Function UPSB2
    Forma valor do projeto pelo custo medio
    @type  Static Function
    @author FWNM
    @since 03/02/2018  
/*/
Static Function UpSB2(cProd, cAlm, nQtd)

	Local nValor := 0
	
	SB2->( dbSetOrder(1) ) // B2_FILIAL+B2_COD+B2_LOCAL
	If SB2->( dbSeek(xFilial("SB2")+cProd+cAlm) )
		nValor := nQtd * SB2->B2_CM1
	EndIf

Return nValor

/*/{Protheus.doc} Static Function ChkZCN
    Consiste lote recria RNX2
    @type  Static Function
    @author FWNM
    @since 20/03/2019
/*/
Static Function ChkZCN()

	Local lRet     := .t.
	Local cEmpZCN  := GetMV("MV_#ZCNEMP",,"07")
	Local aAreaZCN := ZCN->( GetArea() )
	Local cLoteZCN := ""
	Local cCC      := ""

	// Empresas autorizadas
	If cEmpAnt $ cEmpZCN
	
		cCC      := gdFieldGet("CP_CC", n)
		cLoteZCN := gdFieldGet("CP_XLOTECC", n)

		// Lote Recria informado
		If !Empty(cLoteZCN)

			ZCN->( dbSetOrder(1) ) // ZCN_FILIAL+ZCN_LOTE                                                                                                                                             
			If ZCN->( dbSeek( FWxFilial("ZCN")+cLoteZCN ) )
			
				// Consisto lote encerrado
				If AllTrim(ZCN->ZCN_STATUS) == "E" 
					lRet := .f.
					Alert("[MTA105LIN-ZCN1] - Lote Recria com status Encerrado! Contate a contabilidade...")
				EndIf
				
				// Consisto CC informado
				If lRet
					If AllTrim(cCC) <> AllTrim(ZCN->ZCN_CENTRO)
					  lRet := .f.
					  Alert("[MTA105LIN-ZCN2] - Lote Recria não amarrado com o Centro de Custo informado! Contate a contabilidade...")
					EndIf
				EndIf
				
			Else
			
				// Lote informado nao cadastrado na ZCN
				lRet := .f.
				Alert("[MTA105LIN-ZCN3] - Lote Recria não cadastrado! Contate a contabilidade...")

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
						Alert("[MTA105LIN-ZCN4] - Centro de Custo informado possui Lote Recria amarrado! Informe o Lote Recria ou contate a contabilidade...")
					EndIf
		
				EndIf
	
			EndIf
		EndIf
		//
	
	EndIf
	
	RestArea( aAreaZCN )

Return lRet
