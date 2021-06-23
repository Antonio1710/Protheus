#Include "Protheus.ch"  
#Include "Fileio.ch"
#Include "TopConn.ch"  
#Include "Rwmake.ch"     

/*/{Protheus.doc} User Function ADCOM022R
	(Relatorio de pedidos de compra em excel)
	@type  Function
	@author William Costa
	@since 27/06/2018
	@version 01
	@history Chamado: 048666 - FWNM            - 23/04/2019 - REL. PEDIDO COMPRA.
	@history Chamado: 049563 - William Costa   - 10/06/2019 - REL. PEDIDO COMPRA.
	@history Chamado: 046026 - William Costa   - 26/07/2019 - Adicionado tres colunas Data de Emissão da Solicitação, Dias em Aberto da Solicitação e Dias em aberto do Pedido de Compra.
	@history Chamado: 055178 - Adriano Savoine - 24/01/2020 - Adicionado uma coluna Tipo Compra para visualizar se a Solicitação Foi do tipo Urgente ou Normal.
	@history Chamado: 055511 - William Costa   - 12/02/2020 - Adicionado a coluna de Nome de Fornecedor
	@history Chamado: 055513 - William Costa   - 12/02/2020 - Adicionado um novo relatório somente Somando o Pedido.
	@history Chamado: 909    - William Costa   - 11/09/2020 - Adicionado dois campos no relatório de item, data da aprovação e hora da aprovação.
	@history Ticket : 11495  - ADRIANO SAVOINE - 30/03/2021 - Adicionado no Relatorio a pergunta Projeto de até parametro MV_PAR21 e MV_PAR22.
	/*/

User Function ADCOM022R()

	// Declaração de variáveis.                                     
	
	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="Relatório Pedidos de Compra"    
	Private nOpca		:=0
	Private cPerg		:= 'ADCOM022R'
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	//+------------------------------------------------+
	//|Cria grupo de perguntas.                        |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o usuário.     |            
	//+------------------------------------------------+
	Aadd(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	Aadd(aSays,"Relatorio Pedidos de Compra" )
    
	Aadd(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	Aadd(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||ComADCOM022R()},"Gerando arquivo","Aguarde...")}})
	Aadd(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch(cCadastro, aSays, aButtons)  
	
Return Nil

Static Function ComADCOM022R() 

 	Private oExcel      := FWMSEXCEL():New()
	Private oMsExcel
	Private cPlanilha   := "Pedido Compra"
	Private cTitulo     := "Pedido Compra"
	Private aLinhas     := {}
   
	Begin Sequence
		
		//Verifica se há o excel instalado na máquina do usuário.
		If ! ( ApOleClient("MsExcel") ) 
		
			MsgStop("Não Existe Excel Instalado","Função ComADCOM022R(ADCOMR22R)")   
		    Break
		    
		EndIF
		
		//Gera o cabeçalho.
		Cabec()  
		          
		If ! GeraExcel()
			Break
			
		EndIf
		
		Sleep(2000)
		SalvaXml()
		
		Sleep(2000)
		CriaExcel()
		
		MsgInfo("Arquivo Excel gerado!","Função ComADCOM022R(ADCOMR22R)")    
	    
	End Sequence

Return Nil 

Static Function Cabec() 

	oExcel:AddworkSheet(cPlanilha)

	IF MV_PAR20 == 1 // POR ITEM
	
		//Itens do Pedido.
		oExcel:AddTable (cPlanilha,cTitulo)
		oExcel:AddColumn(cPlanilha,cTitulo,"Filial "			,1,1) // 01 A
		oExcel:AddColumn(cPlanilha,cTitulo,"Num Pedido   "	    ,1,1) // 02 B
		oExcel:AddColumn(cPlanilha,cTitulo,"Item Pedido  "	    ,1,1) // 03 C // Chamado 048666 || OS 049948 || SUPRIMENTOS || EVANDRA || 8362 || REL. PEDIDO COMPRA - FWNM - 23/04/2019
		oExcel:AddColumn(cPlanilha,cTitulo,"Data Emissao "		,1,1) // 04 D
		oExcel:AddColumn(cPlanilha,cTitulo,"Dias Aberto PC "    ,1,1) // 05 E // Chamado 046026
		oExcel:AddColumn(cPlanilha,cTitulo,"Numero SC "    		,1,1) // 06 F
		oExcel:AddColumn(cPlanilha,cTitulo,"Data Emissao SC " 	,1,1) // 07 G // Chamado 046026
		oExcel:AddColumn(cPlanilha,cTitulo,"Dias Aberto SC "    ,1,1) // 08 H // Chamado 046026
		oExcel:AddColumn(cPlanilha,cTitulo,"Tipo Compra SC " 	,1,1) // 09 I // Chamado 055178 ADRIANO SAVOINE
		oExcel:AddColumn(cPlanilha,cTitulo,"Nota Fiscal "		,1,1) // 10 J
		oExcel:AddColumn(cPlanilha,cTitulo,"Serie Nota "	    ,1,1) // 11 K
		oExcel:AddColumn(cPlanilha,cTitulo,"Aprovação "		    ,1,1) // 12 L
		oExcel:AddColumn(cPlanilha,cTitulo,"Produto "		    ,1,1) // 13 M
		oExcel:AddColumn(cPlanilha,cTitulo,"Desc Produto "		,1,1) // 14 N 
		oExcel:AddColumn(cPlanilha,cTitulo,"Desc Complementar " ,1,1) // 15 O
		oExcel:AddColumn(cPlanilha,cTitulo,"Quantidade "	    ,1,1) // 16 P
		oExcel:AddColumn(cPlanilha,cTitulo,"Quant Entregue "	,1,1) // 17 Q // chamado 049563 || OS 050846 || ALMOXARIFADO || FABIO || 8410 || REL. ESTOQUE
		oExcel:AddColumn(cPlanilha,cTitulo,"Preço Unitário "    ,1,1) // 18 R
		oExcel:AddColumn(cPlanilha,cTitulo,"Total "	            ,1,1) // 19 S
		oExcel:AddColumn(cPlanilha,cTitulo,"Data Entrega "	    ,1,1) // 20 T
		oExcel:AddColumn(cPlanilha,cTitulo,"Local   "		    ,1,1) // 21 U
		oExcel:AddColumn(cPlanilha,cTitulo,"Observação "		,1,1) // 22 V
		oExcel:AddColumn(cPlanilha,cTitulo,"Fornecedor "	 	,1,1) // 23 W
		oExcel:AddColumn(cPlanilha,cTitulo,"Loja "		        ,1,1) // 24 X
		oExcel:AddColumn(cPlanilha,cTitulo,"Nome Fornecedor "	,1,1) // 25 Y
		oExcel:AddColumn(cPlanilha,cTitulo,"Centro de Custo "	,1,1) // 26 Z
		oExcel:AddColumn(cPlanilha,cTitulo,"Usuario "		    ,1,1) // 27 AA
		oExcel:AddColumn(cPlanilha,cTitulo,"Projeto "		    ,1,1) // 28 AB
		oExcel:AddColumn(cPlanilha,cTitulo,"Conta Contabil "	,1,1) // 29 AC
		oExcel:AddColumn(cPlanilha,cTitulo,"Responsável "		,1,1) // 30 AD
		oExcel:AddColumn(cPlanilha,cTitulo,"Cond. de Pagamento ",1,1) // 31 AE
		oExcel:AddColumn(cPlanilha,cTitulo,"Desc Cond. Pagto "	,1,1) // 32 AF
		oExcel:AddColumn(cPlanilha,cTitulo,"Data Vencimento "	,1,1) // 33 AG
		oExcel:AddColumn(cPlanilha,cTitulo,"Grupo Produto  "	,1,1) // 34 AH // Chamado 048666 || OS 049948 || SUPRIMENTOS || EVANDRA || 8362 || REL. PEDIDO COMPRA - FWNM - 23/04/2019
		oExcel:AddColumn(cPlanilha,cTitulo,"Desc Grupo Prod  "	,1,1) // 35 AY // Chamado 048666 || OS 049948 || SUPRIMENTOS || EVANDRA || 8362 || REL. PEDIDO COMPRA - FWNM - 23/04/2019
		oExcel:AddColumn(cPlanilha,cTitulo,"Elimina Residuo  "	,1,1) // 36 AJ // chamado 049563 || OS 050846 || ALMOXARIFADO || FABIO || 8410 || REL. ESTOQUE
		oExcel:AddColumn(cPlanilha,cTitulo,"Status Pedido  "	,1,1) // 37 AK // chamado 049563 || OS 050846 || ALMOXARIFADO || FABIO || 8410 || REL. ESTOQUE
		oExcel:AddColumn(cPlanilha,cTitulo,"Data Aprovação  "	,1,1) // 38 AL 
		oExcel:AddColumn(cPlanilha,cTitulo,"Hora Aprovação  "	,1,1) // 39 AM 

	ENDIF

	IF MV_PAR20 == 2 // POR PEDIDO
	
		//Itens do Pedido.
		oExcel:AddTable (cPlanilha,cTitulo)
		oExcel:AddColumn(cPlanilha,cTitulo,"Filial "			,1,1) // 01 A
		oExcel:AddColumn(cPlanilha,cTitulo,"Num Pedido   "	    ,1,1) // 02 B
		oExcel:AddColumn(cPlanilha,cTitulo,"Data Emissao "		,1,1) // 03 C
		oExcel:AddColumn(cPlanilha,cTitulo,"Tipo Compra SC " 	,1,1) // 04 D 
		oExcel:AddColumn(cPlanilha,cTitulo,"Total "	            ,1,1) // 05 E
		oExcel:AddColumn(cPlanilha,cTitulo,"Fornecedor "	 	,1,1) // 06 F
		oExcel:AddColumn(cPlanilha,cTitulo,"Loja "		        ,1,1) // 07 G
		oExcel:AddColumn(cPlanilha,cTitulo,"Nome Fornecedor "	,1,1) // 08 H
		oExcel:AddColumn(cPlanilha,cTitulo,"Cond. de Pagamento ",1,1) // 09 I
		oExcel:AddColumn(cPlanilha,cTitulo,"Desc Cond. Pagto "	,1,1) // 10 J
		
	ENDIF
	
Return Nil

Static Function GeraExcel()

	Local nLinha		:= 0
	Local nExcel     	:= 0
	Local nTotReg		:= 0
	Local cNumPC        := ''
	Local cStatusPed    := ''
	Local cStatusSC     := '' // CHAMADO: 055178 - ADRIANO SAVOINE

	IF MV_PAR20 == 1 //POR ITEM
		
		SqlPed()
		DBSELECTAREA("TRB")
		DBGOTOP()
		//Conta o Total de registros.
		nTotReg := Contar("TRB","!Eof()")
		
		//Valida a quantidade de registros.
		If nTotReg <= 0
			MsgStop("Não há registros para os parâmetros informados.","Função GeraExcel(ADCOMR002)")
			Return .F.
			
		EndIf
		
		//Atribui a quantidade de registros à régua de processamento.
		DBSELECTAREA("TRB")
		DBGOTOP()
		ProcRegua(nTotReg)
		TRB->(DbGoTop())
		While !TRB->(Eof()) 
		
			cNumPC := Alltrim(cValToChar(TRB->C7_NUM ))
		
			IncProc("Processando Ped. Comp. " + cNumPC)     
						
			nLinha  := nLinha + 1                                       
		
			//===================== INICIO CRIA VETOR COM POSICAO VAZIA 
			Aadd(aLinhas,{ "", ; // 01 A  
						"", ; // 02 B   
						"", ; // 03 C  // Chamado 048666 || OS 049948 || SUPRIMENTOS || EVANDRA || 8362 || REL. PEDIDO COMPRA - FWNM - 23/04/2019
						"", ; // 04 D  
						"", ; // 05 E // Chamado 046026 
						"", ; // 06 F   
						"", ; // 07 G // Chamado 046026 
						"", ; // 08 H // Chamado 046026 
						"", ; // 09 I // CHAMADO 055178 ADRIANO SAVOINE 
						"", ; // 10 J   
						"", ; // 11 K  
						"", ; // 12 L  
						"", ; // 13 M  
						"", ; // 14 N   
						"", ; // 15 O   
						"", ; // 16 P   
						"", ; // 17 Q
						"", ; // 18 R   
						"", ; // 19 S     
						"", ; // 20 T 
						"", ; // 21 U
						"", ; // 22 V
						"", ; // 23 W
						"", ; // 24 X
						"", ; // 25 Y
						"", ; // 26 Z
						"", ; // 27 AA 
						"", ; // 28 AB // Chamado 048666 || OS 049948 || SUPRIMENTOS || EVANDRA || 8362 || REL. PEDIDO COMPRA - FWNM - 23/04/2019
						"", ; // 29 AC // Chamado 048666 || OS 049948 || SUPRIMENTOS || EVANDRA || 8362 || REL. PEDIDO COMPRA - FWNM - 23/04/2019
						"", ; // 30 AD // Chamado 048666 || OS 049948 || SUPRIMENTOS || EVANDRA || 8362 || REL. PEDIDO COMPRA - FWNM - 23/04/2019
						"", ; // 31 AE // chamado 049563 || OS 050846 || ALMOXARIFADO || FABIO || 8410 || REL. ESTOQUE
						"", ; // 32 AF // chamado 049563 || OS 050846 || ALMOXARIFADO || FABIO || 8410 || REL. ESTOQUE
						"", ; // 33 AG 
						"", ; // 34 AH 
						"", ; // 35 AI
						"", ; // 36 AJ 
						"", ; // 37 AK 
						"", ; // 38 AL 
						""  ; // 39 AM 
							})
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================   
			
			//Dados do pedido.
			
			// *** INICIO chamado 049563 || OS 050846 || ALMOXARIFADO || FABIO || 8410 || REL. ESTOQUE
			cStatusPed := ''
			
			DO CASE
			
				CASE !EMPTY(TRB->C7_RESIDUO) 
					cStatusPed := 'Eliminado por Residuo'
					
				CASE TRB->C7_CONAPRO == "BLOQUEADO" .AND. TRB->C7_QUJE < TRB->C7_QUANT  
					cStatusPed := 'Em Aprovação'
					
				CASE TRB->C7_CONAPRO == "REJEITADO" .AND. TRB->C7_QUJE < TRB->C7_QUANT 
					cStatusPed := 'Rejeitado pelo Aprovador'
					
				CASE TRB->C7_QUJE == 0 .AND. TRB->C7_QTDACLA == 0 
					cStatusPed := 'Pendente'
					
				CASE TRB->C7_QUJE <> 0 .AND. TRB->C7_QUJE < TRB->C7_QUANT
					cStatusPed := 'Recebido Parcialmente'
					
				CASE TRB->C7_QUJE >= TRB->C7_QUANT
					cStatusPed := 'Recebido'
					
				CASE TRB->C7_QTDACLA > 0
					cStatusPed := 'Em recebimento Pré - NOta'	
					
			ENDCASE

			cStatusSC := ''
			
			// CHAMADO: 055178 - ADRIANO SAVOINE INICIO CASE
			DO CASE 

				CASE IIF(ALLTRIM(TRB->C7_NUMSC) <> '',(Posicione("SC1",1,TRB->C7_FILIAL+TRB->C7_NUMSC+TRB->C7_ITEMSC,"C1_XGRCOMP")), '') == '1'
					cStatusSC := 'COMPRA NORMAL'

				CASE IIF(ALLTRIM(TRB->C7_NUMSC) <> '',(Posicione("SC1",1,TRB->C7_FILIAL+TRB->C7_NUMSC+TRB->C7_ITEMSC,"C1_XGRCOMP")), '') == '2'	
					cStatusSC := 'COMPRA URGENTE'

			ENDCASE	
			// CHAMADO: 055178 - ADRIANO SAVOINE FIM CASE
			// *** FINAL chamado 049563 || OS 050846 || ALMOXARIFADO || FABIO || 8410 || REL. ESTOQUE
			
			aLinhas[nLinha][01] := TRB->C7_FILIAL                                                                                                                 // 01 A	
			aLinhas[nLinha][02] := TRB->C7_NUM                                                                                                                    // 02 B
			aLinhas[nLinha][03] := TRB->C7_ITEM                                                                                                                   // 03 C // Chamado 048666 || OS 049948 || SUPRIMENTOS || EVANDRA || 8362 || REL. PEDIDO COMPRA - FWNM - 23/04/2019
			aLinhas[nLinha][04] := STOD(TRB->C7_EMISSAO)                                                                                                          // 04 D
			aLinhas[nLinha][05] := DATE() - STOD(TRB->C7_EMISSAO)                                                                                                 // 05 E // Chamado 046026
			aLinhas[nLinha][06] := TRB->C7_NUMSC                                                                                                                  // 06 F
			aLinhas[nLinha][07] := IIF(ALLTRIM(TRB->C7_NUMSC) <> '',DTOC(Posicione("SC1",1,TRB->C7_FILIAL+TRB->C7_NUMSC+TRB->C7_ITEMSC,"C1_EMISSAO")), '')       // 07 G // Chamado 046026
			aLinhas[nLinha][08] := IIF(ALLTRIM(TRB->C7_NUMSC) <> '',DATE() - Posicione("SC1",1,TRB->C7_FILIAL+TRB->C7_NUMSC+TRB->C7_ITEMSC,"C1_EMISSAO"), '')    // 08 H // Chamado 046026
			aLinhas[nLinha][09] := cStatusSC                                                                                                                      // 09 I// CHAMADO: 055178 - ADRIANO SAVOINE
			aLinhas[nLinha][10] := TRB->D1_DOC                                                                                                                    // 10 J
			aLinhas[nLinha][11] := TRB->D1_SERIE   		                                                                                                          // 11 K
			aLinhas[nLinha][12] := TRB->C7_CONAPRO                                                                                                                // 12 L
			aLinhas[nLinha][13] := TRB->C7_PRODUTO                                                                                                                // 13 M
			aLinhas[nLinha][14] := TRB->B1_DESC                                                                                                                   // 14 N // chamado 049563 || OS 050846 || ALMOXARIFADO || FABIO || 8410 || REL. ESTOQUE
			aLinhas[nLinha][15] := TRB->B1_DESCOMP                                                                                                                // 15 O
			aLinhas[nLinha][16] := TRB->C7_QUANT                                                                                                                  // 16 P
			aLinhas[nLinha][17] := TRB->C7_QUJE                                                                                                                   // 17 Q
			aLinhas[nLinha][18] := TRB->C7_PRECO                                                                                                                  // 18 R
			aLinhas[nLinha][19] := TRB->C7_TOTAL                                                                                                                  // 19 S
			aLinhas[nLinha][20] := STOD(TRB->C7_DATPRF)                                                                                                           // 20 T
			aLinhas[nLinha][21] := TRB->C7_LOCAL                                                                                                                  // 21 U
			aLinhas[nLinha][22] := TRB->C7_OBS   		                                                                                                          // 22 V
			aLinhas[nLinha][23] := TRB->C7_FORNECE                                                                                                                // 23 W
			aLinhas[nLinha][24] := TRB->C7_LOJA                                                                                                                   // 24 X
			aLinhas[nLinha][25] := Posicione("SA2",1,FWxFilial("SA2")+TRB->C7_FORNECE+TRB->C7_LOJA,"A2_NOME")                                                     // 25 Y
			aLinhas[nLinha][26] := TRB->C7_CC                                                                                                                     // 26 Z
			aLinhas[nLinha][27] := UsrRetName(TRB->C7_USER)                                                                                                       // 27 AA
			aLinhas[nLinha][28] := TRB->C7_PROJETO                                                                                                                // 28 AB
			aLinhas[nLinha][29] := TRB->C7_CONTA                                                                                                                  // 29 AC
			aLinhas[nLinha][30] := TRB->C7_XRESPON                                                                                                                // 30 AD
			aLinhas[nLinha][31] := TRB->C7_COND                                                                                                                   // 31 AR
			aLinhas[nLinha][32] := Posicione("SE4",1,xFilial("SE4")+Alltrim(cValToChar(TRB->C7_COND)),"E4_DESCRI" )                                               // 32 AF
			aLinhas[nLinha][33] := IIF(ALLTRIM(TRB->D1_DOC) == '','', DESCOBRIRVENCIMENTO(TRB->C7_FILIAL,TRB->D1_SERIE,TRB->D1_DOC,TRB->C7_FORNECE,TRB->C7_LOJA)) // 33 AG // chamado 049563 || OS 050846 || ALMOXARIFADO || FABIO || 8410 || REL. ESTOQUE
			aLinhas[nLinha][34] := TRB->BM_GRUPO                                                                                                                  // 34 AH
			aLinhas[nLinha][35] := TRB->BM_DESC                                                                                                                   // 35 AI
			aLinhas[nLinha][36] := TRB->C7_RESIDUO                                                                                                                // 36 AJ
			aLinhas[nLinha][37] := cStatusPed                                                                                                                     // 37 AK
			aLinhas[nLinha][38] := BUSCADTAPROV(TRB->C7_FILIAL,TRB->C7_NUM)                                                                                       // 38 AL
			aLinhas[nLinha][39] := BUSCAHRAPROV(TRB->C7_FILIAL,TRB->C7_NUM)                                                                                       // 39 AM
			
			TRB->(DBSKIP())    
			
		ENDDO
		
		TRB->(DbCloseArea())    
		
		//============================== INICIO IMPRIME LINHA NO EXCEL
		FOR nExcel := 1 TO nLinha
			
			IncProc("Carregando Dados para a Planilha1 de: " + cValtochar(nExcel) + ' até: ' + cValtochar(nLinha))
			
			oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],;  // 01 A  
											aLinhas[nExcel][02],;  // 02 B  
											aLinhas[nExcel][03],;  // 03 C  // Chamado 048666 || OS 049948 || SUPRIMENTOS || EVANDRA || 8362 || REL. PEDIDO COMPRA - FWNM - 23/04/2019
											aLinhas[nExcel][04],;  // 04 D  
											aLinhas[nExcel][05],;  // 05 E  
											aLinhas[nExcel][06],;  // 06 F  
											aLinhas[nExcel][07],;  // 07 G  
											aLinhas[nExcel][08],;  // 08 H  
											aLinhas[nExcel][09],;  // 09 I  // CHAMADO 055178 ADRIANO SAVOINE
											aLinhas[nExcel][10],;  // 10 J  
											aLinhas[nExcel][11],;  // 11 K  
											aLinhas[nExcel][12],;  // 12 L  
											aLinhas[nExcel][13],;  // 13 M  
											aLinhas[nExcel][14],;  // 14 N 
											aLinhas[nExcel][15],;  // 15 O  
											aLinhas[nExcel][16],;  // 16 P 
											aLinhas[nExcel][17],;  // 17 Q 
											aLinhas[nExcel][18],;  // 18 R 
											aLinhas[nExcel][19],;  // 19 S
											aLinhas[nExcel][20],;  // 20 T
											aLinhas[nExcel][21],;  // 21 U
											aLinhas[nExcel][22],;  // 22 V
											aLinhas[nExcel][23],;  // 23 W
											aLinhas[nExcel][24],;  // 24 X
											aLinhas[nExcel][25],;  // 25 Y
											aLinhas[nExcel][26],;  // 26 Z
											aLinhas[nExcel][27],;  // 27 AA // Chamado 048666 || OS 049948 || SUPRIMENTOS || EVANDRA || 8362 || REL. PEDIDO COMPRA - FWNM - 23/04/2019
											aLinhas[nExcel][28],;  // 28 AB // Chamado 048666 || OS 049948 || SUPRIMENTOS || EVANDRA || 8362 || REL. PEDIDO COMPRA - FWNM - 23/04/2019
											aLinhas[nExcel][29],;  // 29 AC // Chamado 048666 || OS 049948 || SUPRIMENTOS || EVANDRA || 8362 || REL. PEDIDO COMPRA - FWNM - 23/04/2019
											aLinhas[nExcel][30],;  // 30 AD // Chamado 048666 || OS 049948 || SUPRIMENTOS || EVANDRA || 8362 || REL. PEDIDO COMPRA - FWNM - 23/04/2019
											aLinhas[nExcel][31],;  // 31 AE // chamado 049563 || OS 050846 || ALMOXARIFADO || FABIO || 8410 || REL. ESTOQUE
											aLinhas[nExcel][32],;  // 32 AF // chamado 049563 || OS 050846 || ALMOXARIFADO || FABIO || 8410 || REL. ESTOQUE
											aLinhas[nExcel][33],;  // 33 AG
											aLinhas[nExcel][34],;  // 34 AH
											aLinhas[nExcel][35],;  // 35 AI
											aLinhas[nExcel][36],;  // 36 AJ
											aLinhas[nExcel][37],;  // 37 AK
											aLinhas[nExcel][38],;  // 38 AL
											aLinhas[nExcel][39] ;  // 39 AM
																}) 	
																			
		Next nExcel 
		//============================== FINAL IMPRIME LINHA NO EXCEL 	

	ENDIF

	IF MV_PAR20 == 2 //POR PEDIDO
		
		SqlPed2()
		DBSELECTAREA("TRC")
		DBGOTOP()
		//Conta o Total de registros.
		nTotReg := Contar("TRC","!Eof()")
		
		//Valida a quantidade de registros.
		If nTotReg <= 0
			MsgStop("Não há registros para os parâmetros informados.","Função GeraExcel(ADCOMR002)")
			Return .F.
			
		EndIf
		
		//Atribui a quantidade de registros à régua de processamento.
		DBSELECTAREA("TRC")
		DBGOTOP()
		ProcRegua(nTotReg)
		TRC->(DbGoTop())
		While !TRC->(Eof()) 
		
			cNumPC := Alltrim(cValToChar(TRC->C7_NUM ))
		
			IncProc("Processando Ped. Comp. " + cNumPC)     
						
			nLinha  := nLinha + 1                                       
		
			//===================== INICIO CRIA VETOR COM POSICAO VAZIA 
			Aadd(aLinhas,{ "", ; // 01 A  
						   "", ; // 02 B   
						   "", ; // 03 C  
						   "", ; // 04 D  
						   "", ; // 05 E 
						   "", ; // 06 F   
						   "", ; // 07 G 
						   "", ; // 08 H 
						   "", ; // 09 I 
						   ""  ; // 10 J  
								})
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================   
			
			//Dados do pedido.
			
			// *** INICIO chamado 049563 || OS 050846 || ALMOXARIFADO || FABIO || 8410 || REL. ESTOQUE
			
			cStatusSC := ''
			
			SqlBuscaSC(TRC->C7_FILIAL,TRC->C7_NUM)
			DBSELECTAREA("TRD")
			DBGOTOP()
			TRD->(DbGoTop())
			While !TRD->(Eof()) 

				IF ALLTRIM(TRD->C7_NUMSC) <> ''

					DO CASE 

						CASE Posicione("SC1",1,TRC->C7_FILIAL+TRD->C7_NUMSC+TRD->C7_ITEMSC,"C1_XGRCOMP") == '1'
							cStatusSC := 'COMPRA NORMAL'

						CASE Posicione("SC1",1,TRC->C7_FILIAL+TRD->C7_NUMSC+TRD->C7_ITEMSC,"C1_XGRCOMP") == '2'	
							cStatusSC := 'COMPRA URGENTE'

					ENDCASE	

				ENDIF
				TRD->(DBSKIP())    
				
			ENDDO
			
			TRD->(DbCloseArea()) 	
			
			aLinhas[nLinha][01] := TRC->C7_FILIAL                                                                   // 01 A	
			aLinhas[nLinha][02] := TRC->C7_NUM                                                                      // 02 B
			aLinhas[nLinha][03] := STOD(TRC->C7_EMISSAO)                                                            // 03 C 
			aLinhas[nLinha][04] := cStatusSC                                                                        // 04 D
			aLinhas[nLinha][05] := TRC->C7_TOTAL                                                                    // 05 E 
			aLinhas[nLinha][06] := TRC->C7_FORNECE                                                                  // 06 F
			aLinhas[nLinha][07] := TRC->C7_LOJA                                                                     // 07 G 
			aLinhas[nLinha][08] := Posicione("SA2",1,FWxFilial("SA2")+TRC->C7_FORNECE+TRC->C7_LOJA,"A2_NOME")       // 08 H 
			aLinhas[nLinha][09] := TRC->C7_COND                                                                     // 09 I
			aLinhas[nLinha][10] := Posicione("SE4",1,xFilial("SE4")+Alltrim(cValToChar(TRC->C7_COND)),"E4_DESCRI" ) // 10 J
			
			TRC->(DBSKIP())    
			
		ENDDO
		
		TRC->(DbCloseArea())    
		
		//============================== INICIO IMPRIME LINHA NO EXCEL
		FOR nExcel := 1 TO nLinha
			
			IncProc("Carregando Dados para a Planilha1 de: " + cValtochar(nExcel) + ' até: ' + cValtochar(nLinha))
			
			oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],;  // 01 A  
											 aLinhas[nExcel][02],;  // 02 B  
											 aLinhas[nExcel][03],;  // 03 C 
											 aLinhas[nExcel][04],;  // 04 D  
											 aLinhas[nExcel][05],;  // 05 E  
											 aLinhas[nExcel][06],;  // 06 F  
											 aLinhas[nExcel][07],;  // 07 G  
											 aLinhas[nExcel][08],;  // 08 H  
											 aLinhas[nExcel][09],;  // 09 I 
											 aLinhas[nExcel][10] ;  // 10 J  
																}) 	
																			
		Next nExcel 
		//============================== FINAL IMPRIME LINHA NO EXCEL 	

	ENDIF

Return .T.  

STATIC FUNCTION DESCOBRIRVENCIMENTO(cFilAtual,cSerie,cDoc,cFornece,cLoja)

	Local cDtVencto := ''
	Local nCont     := 0
	
	SqlVencimento(cFilAtual,cSerie,cDoc,cFornece,cLoja)
	TRC->(DbGoTop())
	While !TRC->(Eof())
	
		nCont := nCont + 1
		
		IF nCont > 1
		
			cDtVencto := cDtVencto + ','
			
		ENDIF
		
		cDtVencto := cDtVencto + DTOC(STOD(TRC->E2_VENCREA))
	
		TRC->(DBSKIP())    
		
	ENDDO
	
	TRC->(DbCloseArea())   
	
RETURN(cDtVencto)

STATIC FUNCTION BUSCADTAPROV(cFilAtual,cNumPed)

	Local cDtAprov := ''
	
	SqlAprov(cFilAtual,cNumPed)
	TRE->(DbGoTop())
	While !TRE->(Eof())
	
		cDtAprov := DTOC(STOD(TRE->CR_DATALIB))
	
		TRE->(DBSKIP())    
		
	ENDDO
	
	TRE->(DbCloseArea())   
	
RETURN(cDtAprov)

STATIC FUNCTION BUSCAHRAPROV(cFilAtual,cNumPed)

	Local cHrAprov := ''
	
	SqlAprov(cFilAtual,cNumPed)
	TRE->(DbGoTop())
	While !TRE->(Eof())
	
		cHrAprov := TRE->CR_XHORA
	
		TRE->(DBSKIP())    
		
	ENDDO
	
	TRE->(DbCloseArea())   
	
RETURN(cHrAprov)

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_PEDIDO_COMPRA.XML")

Return Nil

Static Function CriaExcel()              

	oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_PEDIDO_COMPRA.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return Nil

Static Function MontaPerg()  
                                
	Private bValid := Nil 
	Private cF3	   := Nil
	Private cSXG   := Nil
	Private cPyme  := Nil
	
	U_xPutSx1(cPerg,'01','Filial de 	           ?','','','mv_ch01','C',02,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR01')
	U_xPutSx1(cPerg,'02','Filial até               ?','','','mv_ch02','C',02,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR02')
	U_xPutSx1(cPerg,'03','Num Ped de               ?','','','mv_ch03','C',06,0,0,'G',bValid,"SC7",cSXG,cPyme,'MV_PAR03')
	U_xPutSx1(cPerg,'04','Num Ped Ate              ?','','','mv_ch04','C',06,0,0,'G',bValid,"SC7",cSXG,cPyme,'MV_PAR04')
	U_xPutSx1(cPerg,'05','Data Emissão de          ?','','','mv_ch05','D',08,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR05')
	U_xPutSx1(cPerg,'06','Data Emissão Ate         ?','','','mv_ch06','D',08,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR06')
	U_xPutSx1(cPerg,'07','Produto de 	           ?','','','mv_ch07','C',15,0,0,'G',bValid,"SB1",cSXG,cPyme,'MV_PAR07')
	U_xPutSx1(cPerg,'08','Produto até              ?','','','mv_ch08','C',15,0,0,'G',bValid,"SB1",cSXG,cPyme,'MV_PAR08')
	U_xPutSx1(cPerg,'09','Centro de Custo de       ?','','','mv_ch09','C',09,0,0,'G',bValid,"CTT",cSXG,cPyme,'MV_PAR09')
	U_xPutSx1(cPerg,'10','Centro de Custo Ate      ?','','','mv_ch10','C',09,0,0,'G',bValid,"CTT",cSXG,cPyme,'MV_PAR10')
	U_xPutSx1(cPerg,'11','Fornecedor de            ?','','','mv_ch11','C',06,0,0,'G',bValid,"SA2",cSXG,cPyme,'MV_PAR11')
	U_xPutSx1(cPerg,'12','Fornecedor Ate           ?','','','mv_ch12','C',06,0,0,'G',bValid,"SA2",cSXG,cPyme,'MV_PAR12')
	U_xPutSx1(cPerg,'13','Loja de                  ?','','','mv_ch13','C',02,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR13')
	U_xPutSx1(cPerg,'14','Loja Ate                 ?','','','mv_ch14','C',02,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR14')
	U_xPutSx1(cPerg,'15','Usuario de               ?','','','mv_ch15','C',06,0,0,'G',bValid,"USR",cSXG,cPyme,'MV_PAR15')
	U_xPutSx1(cPerg,'16','Usuario Ate              ?','','','mv_ch16','C',06,0,0,'G',bValid,"USR",cSXG,cPyme,'MV_PAR16')
	U_xPutSx1(cPerg,'17','Grupo Produto De         ?','','','mv_ch17','C',04,0,0,'G',bValid,"SBM",cSXG,cPyme,'MV_PAR17')
	U_xPutSx1(cPerg,'18','Grupo Produto Ate        ?','','','mv_ch18','C',04,0,0,'G',bValid,"SBM",cSXG,cPyme,'MV_PAR18')
	u_xPutSx1(cPerg,"19","Status Pedidos           ?",'','','mv_ch19',"N",1 ,0,1,"C",bValid,cF3  ,cSXG,cPyme,'MV_PAR19',"Todos","Todos","Todos","1","Pendente","Pendente","Pendente","Recebidos","Recebidos","Recebidos","Em Aprovacao","Em Aprovacao","Em Aprovacao","Rejeitado","Rejeitado","Rejeitado")
	u_xPutSx1(cPerg,"20","Impressão do Pedidos por ?",'','','mv_ch20',"N",1 ,0,1,"C",bValid,cF3  ,cSXG,cPyme,'MV_PAR20',"Item","Item","Item","1","Pedido","Pedido","Pedido","","","","","","","","","")

    Pergunte(cPerg,.F.)
	
Return Nil    

STATIC FUNCTION SqlVencimento(cFilAtual,cSerie,cDoc,cFornece,cLoja)

	BeginSQL Alias "TRC"
		     %NoPARSER% 
		     SELECT E2_VENCREA 
			   FROM %Table:SE2%
			  WHERE E2_FILIAL   = %EXP:cFilAtual%
			    AND E2_PREFIXO  = %EXP:cSerie%
			    AND E2_NUM      = %EXP:cDoc%
				AND E2_TIPO     = 'NF'
				AND E2_FORNECE  = %EXP:cFornece%
				AND E2_LOJA     = %EXP:cLoja%
				AND D_E_L_E_T_ <> '*'
		     
	EndSQl
		        
RETURN(NIL)	
                     
Static Function SqlPed()   

	Local cFil   := xFilial("SC7")
	Local cDtIni := DTOS(MV_PAR05) 
	Local cDtFin := DTOS(MV_PAR06)
	Local cWhere := ''
	
	IF MV_PAR19 == 1 //Todos
	
		cWhere := '%%'
		
	ELSEIF MV_PAR19 == 2 //Pendente
	
		cWhere := '% AND (C7_QUJE = 0 AND C7_QTDACLA = 0 OR C7_QUJE <> 0 AND C7_QUJE <> C7_QUANT)%'	
		
	ELSEIF MV_PAR19 == 3 //Recebidos
	
		cWhere := '% AND C7_QUJE >= C7_QUANT%'	
		
	ELSEIF MV_PAR19 == 4 //Em Aprovacao
	
		cWhere := "% AND  C7_CONAPRO = 'B' AND C7_QUJE < C7_QUANT %"	
		
	ELSEIF MV_PAR19 == 5 //Rejeitado
	
		cWhere := "% AND C7_CONAPRO = 'R' AND C7_QUJE < C7_QUANT%"	
	
	ENDIF
	
	BeginSQL Alias "TRB"
		     %NoPARSER% 
		        SELECT C7_FILIAL,
				       C7_NUM,
					   C7_EMISSAO,
					   C7_NUMSC,
					   C7_ITEMSC,
					   D1_DOC,
					   D1_SERIE,
					   CASE WHEN C7_CONAPRO = 'L' THEN 'LIBERADO' ELSE CASE WHEN C7_CONAPRO = 'R' THEN 'REJEITADO' ELSE 'BLOQUEADO' END END AS C7_CONAPRO,
					   C7_PRODUTO,
					   B1_DESC,
					   B1_DESCOMP,
					   C7_QUANT,
					   C7_QUJE,
					   C7_QTDACLA,
					   C7_PRECO,
					   C7_TOTAL,
					   C7_DATPRF,
					   C7_LOCAL,
					   C7_OBS,
					   C7_FORNECE,
					   C7_LOJA,
					   C7_CC,
					   C7_USER,
					   C7_PROJETO,
					   C7_CONTA,
					   C7_XRESPON,
					   C7_COND,
					   BM_GRUPO,
					   BM_DESC,
					   C7_ITEM,
					   C7_RESIDUO,
					   C7_ACCPROC					   
				  FROM %Table:SC7% WITH(NOLOCK)

				  LEFT JOIN %Table:SB1% WITH(NOLOCK)
					     ON B1_FILIAL               = ''
					    AND B1_COD                  = C7_PRODUTO
					    AND %Table:SB1%.D_E_L_E_T_ <> '*' 

				  INNER JOIN %Table:SBM% WITH(NOLOCK)
					     ON BM_FILIAL               = %EXP:FWxFilial("SBM")%
					    AND BM_GRUPO                = B1_GRUPO
					    AND BM_GRUPO                >= %EXP:MV_PAR17%
					    AND BM_GRUPO                <= %EXP:MV_PAR18%
					    AND %Table:SBM%.D_E_L_E_T_  = '' 

				  LEFT JOIN %Table:SD1% WITH(NOLOCK)
				         ON D1_FILIAL               = C7_FILIAL
						AND D1_PEDIDO               = C7_NUM
						AND D1_ITEMPC               = C7_ITEM
						AND D1_FORNECE              = C7_FORNECE
						AND D1_LOJA                 = C7_LOJA
					    AND %Table:SD1%.D_E_L_E_T_ <> '*' 
					    
				      WHERE C7_FILIAL              >= %EXP:MV_PAR01%
				        AND C7_FILIAL              <= %EXP:MV_PAR02%
					    AND C7_NUM                 >= %EXP:MV_PAR03%
					    AND C7_NUM                 <= %EXP:MV_PAR04%
					    AND C7_EMISSAO             >= %EXP:cDtIni%
					    AND C7_EMISSAO             <= %EXP:cDtFin%
					    AND C7_PRODUTO             >= %EXP:MV_PAR07%
					    AND C7_PRODUTO             <= %EXP:MV_PAR08%
					    AND C7_CC                  >= %EXP:MV_PAR09%
					    AND C7_CC                  <= %EXP:MV_PAR10%
					    AND C7_FORNECE             >= %EXP:MV_PAR11%
					    AND C7_FORNECE             <= %EXP:MV_PAR12%
					    AND C7_LOJA                >= %EXP:MV_PAR13%
					    AND C7_LOJA                <= %EXP:MV_PAR14%
					    AND C7_USER                >= %EXP:MV_PAR15%
					    AND C7_USER                <= %EXP:MV_PAR16%
						AND C7_PROJETO			   >= %EXP:MV_PAR21%
						AND C7_PROJETO			   <= %EXP:MV_PAR22%
					    AND %Table:SC7%.D_E_L_E_T_ <> '*'
					    %EXP:cWhere%
		    
			ORDER BY C7_FILIAL,C7_NUM

	EndSQl

Return (NIL)  	

Static Function SqlPed2()   

	Local cFil   := xFilial("SC7")
	Local cDtIni := DTOS(MV_PAR05) 
	Local cDtFin := DTOS(MV_PAR06)
	Local cWhere := ''
	
	IF MV_PAR19 == 1 //Todos
	
		cWhere := '%%'
		
	ELSEIF MV_PAR19 == 2 //Pendente
	
		cWhere := '% AND (C7_QUJE = 0 AND C7_QTDACLA = 0 OR C7_QUJE <> 0 AND C7_QUJE <> C7_QUANT)%'	
		
	ELSEIF MV_PAR19 == 3 //Recebidos
	
		cWhere := '% AND C7_QUJE >= C7_QUANT%'	
		
	ELSEIF MV_PAR19 == 4 //Em Aprovacao
	
		cWhere := "% AND  C7_CONAPRO = 'B' AND C7_QUJE < C7_QUANT %"	
		
	ELSEIF MV_PAR19 == 5 //Rejeitado
	
		cWhere := "% AND C7_CONAPRO = 'R' AND C7_QUJE < C7_QUANT%"	
	
	ENDIF

	BeginSQL Alias "TRC"
		     %NoPARSER% 
		        SELECT  C7_FILIAL,
						C7_NUM,
						C7_EMISSAO,
						C7_FORNECE,
						C7_LOJA,
						C7_COND,
						SUM(C7_TOTAL) AS C7_TOTAL
				  FROM %Table:SC7% WITH(NOLOCK)

				  LEFT JOIN %Table:SB1% WITH(NOLOCK)
					     ON B1_FILIAL               = ''
					    AND B1_COD                  = C7_PRODUTO
					    AND %Table:SB1%.D_E_L_E_T_ <> '*' 

				  INNER JOIN %Table:SBM% WITH(NOLOCK)
					     ON BM_FILIAL               = %EXP:FWxFilial("SBM")%
					    AND BM_GRUPO                = B1_GRUPO
					    AND BM_GRUPO                >= %EXP:MV_PAR17%
					    AND BM_GRUPO                <= %EXP:MV_PAR18%
					    AND %Table:SBM%.D_E_L_E_T_  = '' 

				  LEFT JOIN %Table:SD1% WITH(NOLOCK)
				         ON D1_FILIAL               = C7_FILIAL
						AND D1_PEDIDO               = C7_NUM
						AND D1_ITEMPC               = C7_ITEM
						AND D1_FORNECE              = C7_FORNECE
						AND D1_LOJA                 = C7_LOJA
					    AND %Table:SD1%.D_E_L_E_T_ <> '*' 
					    
				      WHERE C7_FILIAL              >= %EXP:MV_PAR01%
				        AND C7_FILIAL              <= %EXP:MV_PAR02%
					    AND C7_NUM                 >= %EXP:MV_PAR03%
					    AND C7_NUM                 <= %EXP:MV_PAR04%
					    AND C7_EMISSAO             >= %EXP:cDtIni%
					    AND C7_EMISSAO             <= %EXP:cDtFin%
					    AND C7_PRODUTO             >= %EXP:MV_PAR07%
					    AND C7_PRODUTO             <= %EXP:MV_PAR08%
					    AND C7_CC                  >= %EXP:MV_PAR09%
					    AND C7_CC                  <= %EXP:MV_PAR10%
					    AND C7_FORNECE             >= %EXP:MV_PAR11%
					    AND C7_FORNECE             <= %EXP:MV_PAR12%
					    AND C7_LOJA                >= %EXP:MV_PAR13%
					    AND C7_LOJA                <= %EXP:MV_PAR14%
					    AND C7_USER                >= %EXP:MV_PAR15%
					    AND C7_USER                <= %EXP:MV_PAR16%
						AND C7_PROJETO			   >= %EXP:MV_PAR21%
						AND C7_PROJETO			   <= %EXP:MV_PAR22%
					    AND %Table:SC7%.D_E_L_E_T_ <> '*'
					    %EXP:cWhere%

		    GROUP BY C7_FILIAL,C7_NUM,C7_EMISSAO,C7_FORNECE,C7_LOJA,C7_COND
			ORDER BY C7_FILIAL,C7_NUM

	EndSQl	

Return (NIL)  

Static Function SqlBuscaSC(cFilAtu,cNumPc)   

	BeginSQL Alias "TRD"
		     %NoPARSER% 
		        SELECT  C7_NUMSC,
					    C7_ITEMSC
				  FROM %Table:SC7% WITH(NOLOCK)
				      WHERE C7_FILIAL               = %EXP:cFilAtu%
				        AND C7_NUM                  = %EXP:cNumPc%
					    AND %Table:SC7%.D_E_L_E_T_ <> '*'
				GROUP BY C7_NUMSC,C7_ITEMSC		
			
	EndSQl	

Return (NIL)  

Static Function SqlAprov(cFilAtual,cNumPed)

	BeginSQL Alias "TRE"
		     %NoPARSER% 
			 	SELECT CR_DATALIB,CR_XHORA 
				  FROM SCR010
				 WHERE CR_FILIAL   = %EXP:cFilAtual%
				   AND CR_NUM      = %EXP:cNumPed%
				   AND CR_XTPLIB   = 'A'
				   AND D_E_L_E_T_ <> '*'
		
	EndSQl	

Return (NIL)          
