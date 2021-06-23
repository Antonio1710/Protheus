#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} User Function M185BAIX
	LOCALIZAÇÃO : Function A185Baixar() - Responsável pela chamada da funcao para o tipo de baixa. 
	EM QUE PONTO : Logo no inicio da rotina A185Baixar. O Ponto de Entrada M185BAIX possibilita customizar a execução da baixa da pre-requisição.
	Utilizacao: Verifica se o campo CP_XTIPO = T se tiver e realizado uma logica para esse ponto de entrada retornar falso e rodar o
	MsExecAuto({|x| MATA261(x)},aItens) transfer entre armazem ao inves de baixa de requisicao se nao continua o processo normal da solicitacao ao armazem utilizado para o bloco K 
	@type  Function
	@author William Costa
	@since 08/08/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 046886 - FWNM    - 20/02/2019 - Divergencia entre CQ_NUMREQ e D3_NUMSEQ impede estorno
	@history chamado 047891 - William - 15/03/2019 - Adicionado para verificar o Saldo Atual quando o CalcEst retorna 0 tanto para o parametro de MV_ULMES até a database ai verifica se o produto tem saldo pelo campo B2_QATU
	@history chamado 055188 - FWNM    - 18/02/2020 - || OS 056599 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || NOVA OPERACAO VENDA
	@history chamado 058822 - FWNM    - 10/06/2020 - || OS 060309 || TECNOLOGIA || ADRIANO || 8451 || CENTRO DE CUSTO SD3
/*/
User Function M185BAIX()

	Local lRet            := .F.
	Local aItens          := {}  
	Local cDoc            := ''
	Local cNumseq         := '' 
	Local cLocalizDestino := '' 
	Local cDescProd       := ''
	Local cUMProd         := ''
	Local cDescDestino    := ''
	Local cUMProdDes      := ''
	Local nQuant          := 0     
	Local cMensagem       := ''
	Local cProdEnderecado := ''
	Local cEndereco       := ''
	Local nSomaEndereco   := 0
	Local cLocalizSB1     := ''
	Local aArea	          := GetArea()
	// Chamado n. 055188 || OS 056599 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || NOVA OPERACAO VENDA - FWNM - 18/02/2020
	Local cLocManBE       := AllTrim(GetMv("MV_#MANSBE",,"MANUT")) 
	Local cLocalMan       := AllTrim(GetMV("MV_#MANLOC",,"48"))
	//

	//IF SCP->CP_XTIPO = 'T' 
	If AllTrim(SCP->CP_XTIPO) == "T" .or. AllTrim(SCP->CP_XTIPO) == "M" // Chamado n. 055188 || OS 056599 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || NOVA OPERACAO VENDA - FWNM - 18/02/2020
	
		// fwnm - chamado 038641
		If AllTrim(SCP->CP_STATUS) == "E"
			Aviso("M185BAIX-02", "Requisição encerrada! " + chr(13) + chr(10) + "Baixa não permitida..." , {"OK"}, 3, "Atenção - Requisição Encerrada")
			Return lRet
		EndIf
		//
		
		cDoc    := SCP->CP_NUM
		
		DbSelectArea("SB2") 
		SB2->(DbSetOrder(1))
		If SB2->(DbSeek( xFilial("SB2") + SCP->CP_PRODUTO + SCP->CP_LOCAL,.T.))
			nQuant  := CalcEst(SB2->B2_COD,SB2->B2_LOCAL,SuperGetMv("MV_ULMES")+1)[1] 
		EndIf
		SB2->( DBCLOSEAREA() )  
		
		IF nQuant <= 0 
			DbSelectArea("SB2") 
			SB2->(DbSetOrder(1))
			If SB2->(DbSeek( xFilial("SB2") + SCP->CP_PRODUTO + SCP->CP_LOCAL,.T.))
				nQuant  := CalcEst(SB2->B2_COD,SB2->B2_LOCAL,dDataBase)[1] 
			EndIf
			SB2->( DBCLOSEAREA() )
	    ENDIF
			
		// *** INICIO 047891 - 15/03/2019 - William Costa	*** //
		IF nQuant <= 0 
			DbSelectArea("SB2") 
			SB2->(DbSetOrder(1))
			If SB2->(DbSeek( xFilial("SB2") + SCP->CP_PRODUTO + SCP->CP_LOCAL,.T.))
				nQuant  := SB2->B2_QATU 
			EndIf
			SB2->( DBCLOSEAREA() )
		ENDIF
		// *** FINAL 047891 - 15/03/2019 - William Costa *** //
			
		IF nQuant <= 0
	
			cMensagem += "Produto Origem: " + SCP->CP_PRODUTO + " - " + Posicione("SB1",1,xFilial("SB1") + SCP->CP_PRODUTO, "B1_DESC") + CHR(13) + CHR(10) + ;
				         "Local Origem:   " + SCP->CP_LOCAL                                                                             + CHR(13) + CHR(10) + ;
				         "Produto Destino:" + SCP->CP_XPRODES + " - " + Posicione("SB1",1,xFilial("SB1") + SCP->CP_XPRODES, "B1_DESC") + CHR(13) + CHR(10) + ;
				         "Local Destino:  " + SCP->CP_XLOCDES                                                                           + CHR(13) + CHR(10) + ;
				         "Motivo: Quantidade menor ou igual a 0 no estoque, Quantidade = " + cValtochar(nQuant)                         + CHR(13) + CHR(10) + ;
				         "------------------------------------------------------------------------------------------------  "           + CHR(13) + CHR(10) + ;
				         CHR(13) + CHR(10) 
			
			U_ExTelaMen("M185BAIX - Tela de Baixa de Solicitação de Armazém!!!", cMensagem, "Arial", 10, , .F., .T.)		
		
			RETURN(lRet)
	   	
	   	ENDIF
		   
		IF Substr(ALLTRIM(cDoc),1,5) == 'INVEN'
		
			cMensagem += "Produto Origem: " + SCP->CP_PRODUTO + " - " + Posicione("SB1",1,xFilial("SB1") + SCP->CP_PRODUTO, "B1_DESC")  + CHR(13) + CHR(10) + ;
				         "Local Origem:   " + SCP->CP_LOCAL                                                                              + CHR(13) + CHR(10) + ;
				         "Produto Destino:" + SCP->CP_XPRODES + " - " + Posicione("SB1",1,xFilial("SB1") + SCP->CP_XPRODES, "B1_DESC")  + CHR(13) + CHR(10) + ;
				         "Local Destino:  " + SCP->CP_XLOCDES                                                                            + CHR(13) + CHR(10) + ;
				         "Motivo: Consta um Inventario no movimento Interno é necessario ter um outro tipo de movimentação  "            + CHR(13) + CHR(10) + ;
				         "------------------------------------------------------------------------------------------------  "            + CHR(13) + CHR(10) + ;
				         CHR(13) + CHR(10) 
			
			U_ExTelaMen("M185BAIX - Tela de Baixa de Solicitação de Armazém!!!", cMensagem, "Arial", 10, , .F., .T.)	
		
			RETURN(lRet)
		   
		ENDIF   
    
	    // Chamado n. 055188 || OS 056599 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || NOVA OPERACAO VENDA - FWNM - 18/02/2020

		//cLocalizDestino := IIF(ALLTRIM(SCP->CP_XLOCDES) == '03',GetMv("MV_X_ENPRO"),Posicione("SBE",10,xFilial("SBE")+SCP->CP_XPRODES,"BE_LOCALIZ"))
	
		If AllTrim(SCP->CP_XLOCDES) == "03"
			cLocalizDestino := GetMv("MV_X_ENPRO",,"PROD")
		
		ElseIf AllTrim(SCP->CP_XLOCDES) $ cLocalMan
			cLocalizDestino := cLocManBE
		
		Else
			cLocalizDestino := Posicione("SBE",10,xFilial("SBE")+SCP->CP_XPRODES,"BE_LOCALIZ")
		EndIf

		//

		cDescProd       := Posicione("SB1",1,xFilial("SB1")+SCP->CP_PRODUTO,"B1_DESC")
		cUMProd         := Posicione("SB1",1,xFilial("SB1")+SCP->CP_PRODUTO,"B1_UM")   
		cDescDestino    := Posicione("SB1",1,xFilial("SB1")+SCP->CP_XPRODES,"B1_DESC")
		cUMProdDes      := Posicione("SB1",1,xFilial("SB1")+SCP->CP_XPRODES,"B1_UM")   
		  
		// Chamado 046889 - 12/03/2019 - FWNM
		cDoc := SCP->CP_NUM + "/" + SCP->CP_ITEM

		// FWNM - CHAMADO 038641 - 15/05/2018
		nQtRequ := QtdDialog()
		
		aadd (aItens,{cDoc	 ,DDATABASE})
	    aadd (aItens,{})
		aItens[2] :=  {{"D3_COD" 	, SCP->CP_PRODUTO	   ,NIL}} // 01.Produto Origem
		aAdd(aItens[2],{"D3_DESCRI" , cDescProd 		   ,NIL}) // 02.Descricao
		aAdd(aItens[2],{"D3_UM"     , cUMProd   		   ,NIL}) // 03.Unidade de Medida
		aAdd(aItens[2],{"D3_LOCAL"  , SCP->CP_LOCAL 	   ,NIL}) // 04.Local Origem
		aAdd(aItens[2],{"D3_LOCALIZ", SCP->CP_LOCALMX	   ,NIL}) // 05.Endereco Origem
		aAdd(aItens[2],{"D3_COD"    , SCP->CP_XPRODES      ,NIL}) // 06.Produto Destino
		aAdd(aItens[2],{"D3_DESCRI" , cDescDestino	       ,NIL}) // 07.Descricao
		aAdd(aItens[2],{"D3_UM"     , cUMProdDes	       ,NIL}) // 08.Unidade de Medida
		aAdd(aItens[2],{"D3_LOCAL"  , SCP->CP_XLOCDES	   ,NIL}) // 09.Armazem Destino
		aAdd(aItens[2],{"D3_LOCALIZ", cLocalizDestino      ,NIL}) // 10.Endereco Destino
		aAdd(aItens[2],{"D3_NUMSERI", CriaVar("D3_NUMSERI"),NIL}) // 11.Numero de Serie
		aAdd(aItens[2],{"D3_LOTECTL", CriaVar("D3_LOTECTL"),NIL}) // 12.Lote Origem
		aAdd(aItens[2],{"D3_NUMLOTE", CriaVar("D3_NUMLOTE"),NIL}) // 13.Sub-Lote
		aAdd(aItens[2],{"D3_DTVALID", CriaVar("D3_DTVALID"),NIL}) // 14.Data de Validade
		aAdd(aItens[2],{"D3_POTENCI", CriaVar("D3_POTENCI"),NIL}) // 15.Potencia do Lote
		aAdd(aItens[2],{"D3_QUANT"  , nQtRequ /*SCP->CP_QUANT - FWNM - CHAMADO 038641*/		   ,NIL}) // 16.Quantidade
		aAdd(aItens[2],{"D3_QTSEGUM", CriaVar("D3_QTSEGUM"),NIL}) // 17.Quantidade na 2 UM
		aAdd(aItens[2],{"D3_ESTORNO", CriaVar("D3_ESTORNO"),NIL}) // 18.Estorno
		aAdd(aItens[2],{"D3_NUMSEQ" , CriaVar("D3_NUMSEQ")/*cNumseq*/			   ,NIL}) // 19.NumSeq
		aAdd(aItens[2],{"D3_LOTECTL", CriaVar("D3_LOTECTL"),NIL}) // 20.Lote Destino
		aAdd(aItens[2],{"D3_DTVALID", CriaVar("D3_DTVALID"),NIL}) // 21.Data de Validade Destino			
		
		// Chamado n. 046889 - FWNM - 20/02/2019 
		aAdd(aItens[2],{"D3_NUMSA"  , SCP->CP_NUM          ,NIL}) // 22.Numero SA
		aAdd(aItens[2],{"D3_ITEMSA" , SCP->CP_ITEM         ,NIL}) // 23.Item SA
		//

		aAdd(aItens[2],{"D3_CC" , SCP->CP_CC               ,NIL}) // 24. C.Custo // Chamado n. 058822 || OS 060309 || TECNOLOGIA || ADRIANO || 8451 || CENTRO DE CUSTO SD3 - FWNM - 10/06/2020
	    
	    Begin Transaction
		             
			lMsErroAuto := .F.
			dbSelectArea("SD3")
			MsExecAuto({|x| MATA261(x)},aItens,3)
			
			IF lMsErroAuto == .T. 
			
				DisarmTransaction()
				MOSTRAERRO()
				/*
				cMensagem := mostraerro("\SYSTEM\M185BAIX.log")
				U_ExTelaMen("M185BAIX - Tela de Baixa de Solicitação de Armazém!!!", cMensagem, "Arial", 10, , .F., .T.)	]
				*/
				
			ELSE
			
				DbSelectArea("SB2") 
				SB2->(DbSetOrder(1))
				IF SB2->(DbSeek( xFilial("SB2") + SCP->CP_PRODUTO + SCP->CP_LOCAL,.T.))
					RecLock("SB2",.F.)
						SB2->B2_QEMPSA := SB2->B2_QEMPSA - nQtRequ  //SCP->CP_QUANT -- FWNM - CHAMADO 038641
					SB2->( MsUnLock() ) // Confirma e finaliza a operação
				ENDIF
				SB2->( DBCLOSEAREA() )
			                              
			    RecLock("SCP",.F.)
					SCP->CP_STATUS := Iif((nQtRequ+SCP->CP_QUJE) >= SCP->CP_QUANT,'E',"") // 'E' -- FWNM - CHAMADO 038641
					SCP->CP_QUJE   := SCP->CP_QUJE+nQtRequ //SCP->CP_QUANT -- FWNM - CHAMADO 038641
					SCP->CP_XDOC   := cDoc
				SCP->( MsUnLock() ) // Confirma e finaliza a operação

				// Chamado n. 046889 - FWNM - 20/02/2019
				SCQ->( dbSetOrder(1) )
				If SCQ->( dbSeek( SCP->CP_FILIAL + SCP->CP_NUM + SCP->CP_ITEM ) )

					lRet := GrvCQNumReq(cDoc)
					
					If !lRet
						DisarmTransaction()
					EndIf

				Else
					msgAlert("M185BAIX - Não encontrado pré-requisição gerada (Tabela SCQ)... Baixa não será realizada!")
					DisarmTransaction()
				EndIf
				//
					
				SB2->( DBCLOSEAREA() )
				
				If AllTrim(SCP->CP_XTIPO) == "M"
					MsgINFO("Olá " + Alltrim(cusername) + ", Solicitação de Transf Manutenção para o Documento: " + cDoc + " Realizado Com Sucesso ","M185BAIX - Ponto de Entrada Baixa")
				Else
					MsgINFO("Olá " + Alltrim(cusername) + ", Solicitação de Transferência para o Documento: " + cDoc + " Realizado Com Sucesso ","M185BAIX - Ponto de Entrada Baixa")
				EndIf
				              
			ENDIF                
		
		End Transaction		

	ELSE  
	
		IF cEmpAnt == '01' .AND. cFilAnt == '02'
		
		    SqlBuscaProduto(SCP->CP_PRODUTO,SCP->CP_LOCAL)
		    
		    While TRD->(!EOF())
	            nSomaEndereco   := nSomaEndereco + 1
	        	TRD->(dbSkip())
			ENDDO
			TRD->(dbCloseArea())
			
			IF nSomaEndereco > 1
				MsgAlert("Olá " + Alltrim(cusername) + ", Não é Possivel fazer a baixa, existe mais de um Endereço para esse produto:  " + SCP->CP_PRODUTO + "Verifique a SBE.", "M185BAIX - Ponto de Entrada Baixa - 1")
				lRet := .F.
			ELSE
				lRet := .T.
			ENDIF

		ELSE 
			lRet := .T.

	    ENDIF

	ENDIF

	RestArea(aArea)
	
RETURN(lRet)

/*/{Protheus.doc} Static Function SqlBuscaSequenciaD3
	(long_description)
	@type  Static Function
	@author William Costa
	@since 19/02/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function SqlBuscaSequenciaD3(cDoc)

	LOCAL  cFil := xFilial("SD3") 

	BeginSQL Alias "TRC"
			%NoPARSER%  
			SELECT TOP(1) D3_FILIAL,D3_DOC,D3_NUMSEQ,D3_ESTORNO 
			         FROM %Table:SD3% WITH (NOLOCK)
			        WHERE D3_FILIAL   = %EXP:cFil% 
				      AND D3_DOC      = %EXP:cDoc% 
 					  AND D3_ESTORNO  = ''
 			          AND D_E_L_E_T_ <> '*'
	EndSQl             

RETURN(NIL)


/*/{Protheus.doc} Static Function SqlBuscaProduto
	(long_description)
	@type  Static Function
	@author William Costa
	@since 19/02/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function SqlBuscaProduto(cCodProd,cLocal)

	LOCAL  cFil := xFilial("SCP")

	BeginSQL Alias "TRD"
			%NoPARSER%  
			   SELECT B1_LOCALIZ,BE_CODPRO,BE_LOCALIZ
			     FROM %Table:SB1% WITH (NOLOCK)
			LEFT JOIN %Table:SBE% WITH (NOLOCK)
			       ON BE_FILIAL               = %EXP:cFil%
			      AND BE_CODPRO               = B1_COD
			      AND BE_LOCAL                = %EXP:cLocal% 
				  AND %Table:SBE%.D_E_L_E_T_ <> '*'
			    WHERE B1_COD                  = %EXP:cCodProd% 
			      AND %Table:SB1%.D_E_L_E_T_ <> '*'
	EndSQl             

RETURN(NIL)

/*/{Protheus.doc} Static Function QtdDialog
	Dialog para informar quantidade
	@type  Static Function
	@author FWNM
	@since 15/05/2018
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 038641
/*/
Static Function QtdDialog()
                                                                                                      
	Local lOKConf   := .f.
	Local oCmpQtd  := Array(01)                                                                           
	Local oBtnQtd  := Array(02)        
	
	Do While .t.
	
		nQtRequ := SCP->CP_QUANT - SCP->CP_QUJE
		
		DEFINE MSDIALOG oDlgQtd TITLE "Tipo Transferências - Informe Quantidade TOTAL/PARCIAL para baixa" FROM 0,0 TO 100,450  OF oMainWnd PIXEL
		
		@ 003, 003 TO 050,265 PIXEL OF oDlgQtd
		
		@ 010,050 Say "Quantidade:" of oDlgQtd PIXEL
		@ 005,090 MsGet oCmpQtd Var nQtRequ SIZE 70,12 of oDlgQtd PIXEL Valid Positivo() Picture "@E 999,999,999.9999"
		
		@ 030,025 BUTTON oBtnQtd[01] PROMPT "Confirma"     of oDlgQtd   SIZE 168,12 PIXEL ACTION (lOKConf := .t. , oDlgQtd:End())
		
		ACTIVATE MSDIALOG oDlgQtd CENTERED
		
		If !lOKConf
			Aviso("M185BAIX-01", "Você não clicou no botão CONFIRMA! " + chr(13) + chr(10) + "Se você confirmar a próxima tela, a requisição será baixada total..." , {"OK"}, 3, "Atenção - Baixa Total")
			If msgYesNo("Confirma a baixa total da requisição?")
				Exit
			EndIf
		Else
			Exit
		Endif
	
	EndDo

Return nQtRequ

/*/{Protheus.doc} Static Function GrvCQNumReq
	Grava na movimentação do estoque o número da SA
	@type  Static Function
	@author FWNM
	@since 15/05/2018
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 038641
/*/
Static Function GrvCQNumReq(cDoc)

	Local lRetorno := .t.
	Local cSql     := ""
	Local nStatus  := 0
	Local cData    := DtoS(dDataBase)
	Local cFil     := SCP->CP_FILIAL
	Local cDocSA   := cDoc
	Local cNumSA   := SCQ->CQ_NUM
	Local cItemSA  := SCQ->CQ_ITEM
	Local cProd    := SCQ->CQ_PRODUTO
	Local cLocal   := SCQ->CQ_LOCAL

	// Gravo D3_NUMSA e D3_ITEMSA
	cSql := " UPDATE " + RetSqlName("SD3") + " SET D3_NUMSA='"+cNumSA+"', D3_ITEMSA='"+cItemSA+"' "
	cSql += " WHERE D3_FILIAL='"+cFil+"' "
	cSql += " AND D3_EMISSAO='"+cData+"' "
	cSql += " AND D3_DOC='"+cDocSA+"' "
	cSql += " AND D3_COD='"+cProd+"' "
	cSql += " AND D3_ESTORNO='' "
	cSql += " AND D_E_L_E_T_='' "
	
	nStatus := tcSqlExec(cSql)

	If nStatus >= 0

		// Carrego dados da SD3 gerada e nao confirmada devido begin
		BeginSQL Alias "BXSD3"
	
			%NoPARSER%  
		
			SELECT D3_FILIAL, D3_DOC, D3_COD, D3_LOCAL, D3_NUMSEQ, D3_NUMSA, D3_ITEMSA
			FROM %Table:SD3% WITH (NOLOCK)
			WHERE D3_FILIAL = %EXP:cFil%
			AND D3_EMISSAO  = %EXP:cData% 
			AND D3_COD      = %EXP:cProd%
			AND D3_LOCAL    = %EXP:cLocal%
			AND D3_NUMSA    = %EXP:cNumSA%
			AND D3_ITEMSA   = %EXP:cItemSA%
		 	AND D3_CHAVE    = 'E0'
		 	AND D3_ESTORNO  = ''
		 	AND D3_NUMSEQ  <> ''
		 	AND D_E_L_E_T_  = ''
				     
		EndSQl             

		// Gravo CQ_NUMREQ com o conteudo do D3_NUMSEQ gerado
		cSql := " UPDATE " + RetSqlName("SCQ") + " SET CQ_NUMREQ='"+BXSD3->D3_NUMSEQ+"' "
		cSql += " WHERE CQ_FILIAL='"+BXSD3->D3_FILIAL+"' "
		cSql += " AND CQ_NUM='"+BXSD3->D3_NUMSA+"' "
		cSql += " AND CQ_ITEM='"+BXSD3->D3_ITEMSA+"' "
		cSql += " AND CQ_PRODUTO='"+BXSD3->D3_COD+"' "
		cSql += " AND D_E_L_E_T_='' "
	
		nStatus := tcSqlExec(cSql)
	
		If nStatus < 0
			lRetorno := .f.
			msgAlert("M185BAIX - Problema na gravação do campo CQ_NUMREQ! Envie o erro que será mostrado na próxima tela ao TI caso contrário não conseguirão fazer estornos destas movimentações...")
			MessageBox(tcSqlError(),"",16)
		EndIf
	
		BXSD3->( dbCloseArea() )

	Else
	
		lRetorno := .f.
		msgAlert("M185BAIX - Problema na gravação dos campos D3_NUMSA e D3_ITEMSA! Envie o erro que será mostrado na próxima tela ao TI caso contrário não conseguirão fazer estornos destas movimentações...")
		MessageBox(tcSqlError(),"",16)

	EndIf
	
Return lRetorno