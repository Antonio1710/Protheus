#include "rwmake.ch"  
#include "topconn.ch"

#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

/*/{Protheus.doc} User Function Meta01
	Consolidade pedidos de Venda
	@type  Function
	@author Marcos Bido
	@since 26/06/2002
	@version 01
	@history Chamado TI     - Heraldo C. Hebling - 11/12/2002 - subsititido campo do cadastro de vendedores A3_SUPERVI pelo campo A3_CODSUP (codigo do supervisor).
	@history Chamado TI     - Heraldo C. Hebling - 11/12/2002 - incluido os parametros: supervisor ate, segmento de mercado de: segmento de mercado ate:
	@history Chamado TI     - Heraldo C. Hebling - 11/12/2002 - alterado o programa para tratar estes novos parametros
	@history Chamado 056399 - William Costa      - 10/03/2020 - Identificado falha no momento de carregar a variavel de codigo do Edata nos resumos de Supervisores, pois a tabela etá desposicionada no momento da impressão. Ajustado a variavel na posição correta e assim foi tudo impresso corretamente
	@history Chamado 057415	- Everson            - 17/04/2020 - Adicionada exportação do relatório para excel.
	@history ticket   10654	- Fernando Macieira  - 11/03/2021 - type mismatch on $  on U_META01(META01.PRW) 17/04/2020 13:07:57 line : 53
/*/
User Function META01() 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local nOpc		:= 1    //Chamado 057415	- Everson - 17/04/2020.
	Local oExcel	:= Nil  //Chamado 057415	- Everson - 17/04/2020.
	Local cDir		:= ""   //Chamado 057415	- Everson - 17/04/2020.
	Local cArq 		:= "META01_" + DToS(Date()) + "_" + StrTran(Time(),":","") //Chamado 057415	- Everson - 17/04/2020.

	Private _Produto   := ''
	Private _Supervis  := ''

	//
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Consolidade pedidos de Venda')

	//Mauricio 05/04/17 validacao incluida emergencialmente a pedido do Sr. Eduardo/Vagner incluindo filtro para vendedores enxergarem
	//Apenas suas vendas. Validacao apenas para vendedores...demais continuam como antes.
	_lVended := .F.
	_cCodUsua := __cUserID
	DbSelectArea("SA3")
	SA3->(DbSetOrder(7))
	If SA3->(Dbseek(xFilial("SA3")+_cCodUsua))

		If !(SA3->A3_NIVETAB $ "4/3/2")
			_lVended := .T.
			_cVended := SA3->A3_COD 
		EndIf

	Else    

		// Chamado 034566 07/04/2017 - Fernando Sigoli                                      
		//If Alltrim(_cCodUsua) $ GETMV("MV_#USREXT")
		If Alltrim(_cCodUsua) $ GETMV("MV_#USREXT",,"") // @history ticket   10654	- Fernando Macieira  - 11/03/2021 - type mismatch on $  on U_META01(META01.PRW) 17/04/2020 13:07:57 line : 53
			_lVended := .F.  // forço status falso   
		Else
			MsgInfo("Seu usuário não possui previlégios para emitir este relatório.","Atenção")
			Return Nil
		EndIf

	EndIf

	//
	SetPrvt("AORD,TAMANHO,LIMITE,NOMEPROG,MV_TABPR,NTIPO")
	SetPrvt("ARETURN,NLASTKEY,NLIN,NITEM,LCONTINUA,M_PAG")
	SetPrvt("IMPRIME,CPERG,CSTRING,cTitulo,CDESC1,CDESC2")
	SetPrvt("CDESC3,NOMEREL,CABEC1,CABEC2,CABEC3,CABEC5")
	SetPrvt("CABEC6,CABEC7,ATRASO,POSICA,CVEND,ASTRU")
	SetPrvt("_CNOMTRB,CINDEX,_TOTSAL,_TOTDEV,_CLIENTE,_NOME")
	SetPrvt("_LOJA,_REGVEND,_VENDE,_PREFIXO,CABEC4,")

	//
	cPerg := "META01"

	//
	Pergunte(cPerg,.F.)

	//
	If Empty(mv_par04)
		mv_par04 := "ZZZZZZ"

	EndIf

	//
	aOrd            := {}
	tamanho         := "G"
	limite          := 80
	nomeprog        := "META"
	mv_tabpr        := ""
	nTipo           := 18
	aReturn         := { "Zebrado", 1,"Administracao", 2, 2, 1,"",1}
	nLastKey        := 0
	nlin            := 80
	nItem           := 1
	lContinua       := .T.
	m_pag	   		:= 01
	imprime    		:= .T.

	//
	cString := "SC6"
	cTitulo  := "CONSOLIDADO PEDIDOS DE VENDA "
	cDesc1  := "Este programa tem como objetivo imprimir posicao VENDAS"
	cDesc2  := "por SUPERVISOR / Vendedor participacao de vendas e volumes"
	cDesc3  := " By Ad'Oro"
	NomeRel := cArq
	nomerel := SetPrint(cString,Nomerel,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho)

	//
	If nLastKey == 27
		Return Nil 

	EndIf

	//
	If nOpc == 1 //Chamado 057415	- Everson - 17/04/2020.

		//
		SetDefault(aReturn,cString)

		//
		If nLastKey == 27
			Return Nil 

		EndIf

	EndIf

	//
	If !Empty(mv_par08)
		nOpc := mv_par08

	EndIf

	//
	If nOpc == 2 //Chamado 057415	- Everson - 17/04/2020.

		//
		cDir := cGetFile("Arquivo XML.", "Selecione o diretório para salvar o XML",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)

		//
		If Empty(cDir)
			Return Nil 

		EndIf

		//
		oExcel := gerObjExc()

	EndIf

	//
	//Chamado 057415	- Everson - 17/04/2020.
	//Cria Arquivo Temporario para totalizacao
	oTemp := arqTemp()

	//
	DbSelectArea("TEMP")
	TEMP->(DbSetOrder(1))

	//
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	//
	DbSelectArea("SB2")
	SB2->(DbSetOrder(2))

	//
	DbSelectArea("SA3")
	SA3->(DbSetOrder(1))

	//
	DbSelectArea("SZR")
	SZR->(DbSetOrder(1))

	//Carrega arquivo temporário
	Processa({|| carArqTemp(), consVend(nOpc,@oExcel), consSuper(nOpc,@oExcel), consGeren(nOpc,@oExcel), consProduto(nOpc,@oExcel) },"CONSOLIDADO DE VENDAS" ) //Chamado 057415	- Everson - 17/04/2020.

	//
	If nOpc == 1 //Chamado 057415	- Everson - 17/04/2020.
		Set Device to Screen
		If aReturn[5]==1
			Set Printer to
			OurSpool(NomeRel)

		EndIf

	Else 
		oExcel:Activate()
		cArq += ".xml"
		oExcel:GetXMLFile(cDir + cArq)
		WinExec("Explorer.exe" + Space(1) + cDir )

	EndIf

	//Chamado 057415	- Everson - 17/04/2020.
	TEMP->(DbCloseArea())
	oTemp:Delete()

	//Chamado 057415	- Everson - 17/04/2020.
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} carArqTemp
	Carrega arquivo temporário.
	@type  Static Function
	@author Everson
	@since  17/04/2020
	@version 01
	/*/
Static Function carArqTemp()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local cProduto	:= ""
	Local cProdedata:= ""
	Local cSupervis	:= ""
	Local cVendedor	:= ""
	Local nQtd_Cxs	:= 0
	Local nVal_Tot	:= 0
	Local nQtd_Qui	:= 0

	//
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))

	//
	Set Filter To SC6->C6_ENTREG >= MV_PAR01 .And. SC6->C6_ENTREG <= MV_PAR02 .And. SC6->C6_FILIAL = cFilAnt //ALTERADO LEONARDO (HC) PARA CONTEMPLAR A FILIAL CORRENTE

	//
	ProcRegua(Contar("SC6","!Eof()"))

	//
	SC6->(DbGotop())

	While SC6->(!EOF())

		//
		IncProc()
		
		//
		cProduto   := SC6->C6_PRODUTO                                    
		cVendedor  := SC6->C6_VEND
		nQtd_Cxs   := SC6->C6_UNSVEN
		nVal_Tot   := SC6->C6_VALOR
		nQtd_Qui   := SC6->C6_QTDVEN

		//	
		If _lVended  
			If !(cVendedor == _cVended)
				SC6->(DbSkip())
				Loop

			EndIf

		EndIf    
		
		//
		SB1->(DbGotop())
		SB1->(DbSeek(FWxFilial("SB1") + cProduto))
		
		//
		SA3->(DbGotop())
		SA3->(DbSeek(FWxFilial("SA3") + cVendedor))
		cSupervis := SA3->A3_CODSUP
		
		//
		If cSupervis >= mv_par03 .And. cSupervis <= mv_par04

			//Cadastro de supervisor.
			SZR->(DbGotop())
			SZR->(DbSeek(xfilial() + SA3->A3_CODSUP))

			//
			If SZR->ZR_SEGMERC >= mv_par05 .And. SZR->ZR_SEGMERC <= mv_par06
			
				//	
				If ! TEMP->(DbSeek(cSupervis + cVendedor + cProduto))
					
					//
					cProdedata := ''
					cProdedata := SqlProdEdata(cProduto)

					//
					RecLock("TEMP",.T.)
					
						Repl TEMP->TR_FILIAL  with FWxFilial("SC6")
						Repl TEMP->TR_CODSUP  with cSupervis
						Repl TEMP->TR_VENDEDO with cVendedor
						Repl TEMP->TR_NOMVEND with SA3->A3_NREDUZ
						Repl TEMP->TR_PRODUTO with cProduto
						Repl TEMP->TR_CAIXAS  with nQtd_Cxs
						Repl TEMP->TR_KILOS   with nQtd_Qui
						Repl TEMP->TR_VALTOT  with nVal_Tot
						Repl TEMP->TR_PREMED  with TR_VALTOT/TR_KILOS
						Repl TEMP->TR_EDATA   with cProdedata
					
					MsUnLock()

				Else

					// SOMA AS QTD VENDIDAS NAS RESPECTIVOS GRUPOS
					RecLock("TEMP",.F.)
					
						Repl TR_CAIXAS   with TR_CAIXAS + nQtd_Cxs
						Repl TR_KILOS    with TR_KILOS  + nQtd_Qui
						Repl TR_VALTOT   with TR_VALTOT + nVal_Tot
						Repl TR_PREMED   with TR_VALTOT/TR_KILOS
					
					MsUnLock()

				EndIf

			EndIf

		EndIf

		SC6->(Dbskip())

	End

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} consVend
	Gera informações por vendedor.
	@type  Static Function
	@author Everson
	@since 17/04/2020.
	@version 01
	/*/
Static Function consVend(nOpc,oExcel)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea				:= GetArea()
	Local cNmAba			:= getAbas()[1]
	Local cSupervis			:= ""
	Local cNomeSupervisor	:= ""
	Local cVendedor 		:= ""
	Local nTvCaixas 		:= 0
	Local nTvkilos  		:= 0
	Local nTvValtot 		:= 0
	Local nTsCaixas 		:= 0
	Local nTskilos  		:= 0
	Local nTsValtot 		:= 0
	Local nTtCaixas 		:= 0
	Local nTtkilos  		:= 0
	Local nTtValtot 		:= 0

	//
	DbSelectArea("TEMP")
	TEMP->(DbGoTop())

	//
	ProcRegua(Contar("TEMP","!Eof()"))

	//
	TEMP->(DbGoTop())

	//
	While TEMP->(!Eof())
		
		//Incrementa a regua	
		IncProc()
		
		//Imprime cabeçalho.
		If nOpc == 1
			If nLin > 60
				ImpCabec()
				nLin := nLin + 1

			EndIf

		EndIf
		
		//Cadastro de supervisor.
		cSupervis := TEMP->TR_CODSUP
		SZR->(DbGotop())
		SZR->(DbSeek(FWxFilial("SZR") + cSupervis))
		cNomeSupervisor :=	SZR->ZR_DESCRIC
		
		//
		Do While ! TEMP->(Eof()) .And. TEMP->TR_CODSUP == cSupervis
			
			//
			cVendedor  := TEMP->TR_VENDEDO
			
			//
			Do While ! TEMP->(Eof()) .And. TEMP->TR_VENDEDO == cVendedor

				//
				If nOpc == 1

					//
					@nLin,000 PSAY "|"
					@nLin,001 PSAY  Substr(TEMP->TR_NOMVEND,1,10) + " " + Substr(TEMP->TR_VENDEDO,4,3)
					@nLin,019 PSAY  TEMP->TR_PRODUTO
					@nLin,036 PSAY  TEMP->TR_EDATA
					@nLin,048 PSAY  TEMP->TR_CAIXAS    Picture "@E 999,999,999"
					@nLin,062 PSAY  TEMP->TR_KILOS     Picture "@E 999,999.999"
					@nLin,076 PSAY  TEMP->TR_VALTOT    Picture "@E 9999,999.99"
					@nLin,091 PSAY  TEMP->TR_PREMED    Picture "@E 99,999.999"
					@nLin,113 PSAY "|"
					nLin := nLin + 1

				Else

					//
					oExcel:AddRow(cNmAba,cNmAba,{;
													Substr(TEMP->TR_NOMVEND,1,10) + " " + Substr(TEMP->TR_VENDEDO,4,3),;
													TEMP->TR_PRODUTO,;
													TEMP->TR_EDATA,;
													TEMP->TR_CAIXAS,;
													TEMP->TR_KILOS ,;
													TEMP->TR_VALTOT,;
													TEMP->TR_PREMED;
												})

				EndIf
				
				//
				nTvCaixas := nTvCaixas + TR_CAIXAS
				nTvkilos  := nTvkilos  + TR_KILOS
				nTvValtot := nTvValtot + TR_VALTOT
				
				//
				TEMP->(DBSkip())

			EndDo

			//
			If nOpc == 1

				//
				@nLin,00 PSAY "|"+Replic("-",112)+"|"
				nLin := nLin + 1
				@nLin,000 PSAY "|"
				@nLin,002 PSAY " TOTAL VENDEDOR " + cVendedor
				@nLin,048 PSAY  nTvCaixas    Picture "@E 999,999,999"
				@nLin,062 PSAY  nTvkilos     Picture "@E 999,999.999"
				@nLin,076 PSAY  nTvValtot    Picture "@E 9999,999.99"
				@nLin,113 PSAY "|"
				nLin := nLin + 1
				@nLin,00 PSAY "|"+Replic("-",112)+"|"
				nLin := nLin + 1

				//
				If nLin > 60
					ImpCabec()
					nLin := nLin + 1

				EndIf

			Else

				//
				oExcel:AddRow(cNmAba,cNmAba,{;
												" TOTAL VENDEDOR " + cVendedor,;
												"",;
												"",;
												nTvCaixas,;
												nTvkilos,;
												nTvValtot,;
												;
											})

			EndIf
			
			//
			nTsCaixas := nTsCaixas + nTvCaixas
			nTskilos  := nTskilos  + nTvkilos
			nTsValtot := nTsValtot + nTvValtot
			
			//
			nTvCaixas := 0
			nTvkilos  := 0
			nTvValtot := 0
			
		EndDo

		//
		If nOpc == 1

			//
			@nLin,00 PSAY "|"+Replic("-",112)+"|"
			nLin := nLin + 1
			@nLin,000 PSAY "|"
			@nLin,002 PSAY " TOTAL " + Left(cNomeSupervisor,12)
			@nLin,048 PSAY  nTsCaixas    Picture "@E 999,999,999"
			@nLin,062 PSAY  nTskilos     Picture "@E 999,999.999"
			@nLin,076 PSAY  nTsValtot    Picture "@E 9999,999.99"
			@nLin,113 PSAY "|"
			nLin := nLin + 1
			@nLin,00 PSAY "|"+Replic("-",112)+"|"
			Nlin := 80

		Else

			//
			oExcel:AddRow(cNmAba,cNmAba,{;
											" TOTAL " + Left(cNomeSupervisor,12),;
											"",;
											"",;
											nTsCaixas,;
											nTskilos ,;
											nTsValtot,;
											;
										})

		EndIf
		
		//
		nTtCaixas := nTtCaixas + nTsCaixas
		nTtkilos  := nTtkilos  + nTskilos
		nTtValtot := nTtValtot + nTsValtot
		
		//
		nTsCaixas := 0
		nTskilos  := 0
		nTsValtot := 0
		
	End

	//
	If nOpc == 1

		//
		@nLin,00 PSAY "|"+Replic("-",112)+"|"
		nLin := nLin + 1
		@nLin,000 PSAY "|"
		@nLin,002 PSAY " TOTAL GERAL  "
		@nLin,048 PSAY  nTtCaixas    Picture "@E 999,999,999"
		@nLin,062 PSAY  nTtkilos     Picture "@E 999,999.999"
		@nLin,076 PSAY  nTtValtot    Picture "@E 9999,999.99"
		@nLin,113 PSAY "|"
		nLin := nLin + 1
		@nLin,00 PSAY "|"+Replic("-",112)+"|"
		nLin := NLIN + 6

	Else

		//
		oExcel:AddRow(cNmAba,cNmAba,{;
										" TOTAL GERAL  ",;
										"",;
										"",;
										nTtCaixas,;
										nTtkilos ,;
										nTtValtot,;
										;
									})

	EndIf

	//
	nTtCaixas	:= 0
	nTtkilos  	:= 0
	nTtValtot 	:= 0

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} consSuper
	Gera informações por supervisor.
	@type  Static Function
	@author Everson
	@since 17/04/2020
	@version 01
	/*/
Static Function consSuper(nOPc,oExcel)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea				:= GetArea()
	Local cNmAba			:= getAbas()[2]
	Local cSupervis			:= ""
	Local cNomeSupervisor	:= ""
	Local cProduto   		:= ""
	Local cProdEdata 		:= ""  
	Local nCaixas    		:= 0
	Local nKilos     		:= 0
	Local nValtot    		:= 0	
	Local nTVCaixas			:= 0
	Local nTVKilos			:= 0	
	Local nTVValTot			:= 0
	Local nTScaixas			:= 0 
	Local nTSKilos  		:= 0
	Local nTSValTot 		:= 0

	//
	DbSelectArea("TEMP")
	TEMP->(DbSetOrder(2))
	TEMP->(DbGoTop())

	//
	ProcRegua(Contar("TEMP","!Eof()"))

	//
	TEMP->(DbGoTop())

	//
	While TEMP->(!EOF())

		//
		IncProc()
		
		//
		If nOPc == 1
			If nLin > 60
				ImpCabec()
				nLin := nLin + 1

			EndIf

		EndIf
		
		//
		cSupervis := TEMP->TR_CODSUP
		
		//CADASTRO DE SUPERVIDOR
		SZR->(DbGotop())
		SZR->(DbSeek(xfilial() + cSupervis))
		cNomeSupervisor :=	SZR->ZR_DESCRIC
		
		//	
		Do While ! TEMP->(Eof()) .And. TR_CODSUP == cSupervis
			
			//
			cProduto   := TEMP->TR_PRODUTO   
			cProdEdata := TEMP->TR_EDATA   
			nCaixas    := 0
			nKilos     := 0
			nValtot    := 0
			
			Do While ! TEMP->(Eof()) .And. TEMP->TR_PRODUTO == cProduto .And. TR_CODSUP == cSupervis
				
				//
				nCaixas := nCaixas + TR_CAIXAS
				nKilos  := nKilos  + TR_KILOS
				nValtot := nValtot + TR_VALTOT
				
				//
				TEMP->(Dbskip())

			Enddo
			
			//
			If nOPc == 1
				@nLin,000 PSAY "|"
				@nLin,001 PSAY  cSupervis
				@nLin,019 PSAY  cProduto 
				@nLin,036 PSAY  cProdEdata
				@nLin,048 PSAY  nCaixas    Picture "@E 999,999,999"
				@nLin,062 PSAY  nKilos     Picture "@E 999,999.999"
				@nLin,076 PSAY  nValtot    Picture "@E 9999,999.99"
				@nLin,091 PSAY  Iif( nKilos <> 0, (nValtot/nKilos), 0)    Picture "@E 99,999.999"

			Else 

				//
				oExcel:AddRow(cNmAba,cNmAba,{;
												cSupervis,;
												cProduto,;
												cProdEdata,;
												nCaixas,;
												nKilos,;
												nValtot,;
												Iif( nKilos <> 0, (nValtot/nKilos), 0);
											})

			EndIf
			
			//
			nTVCaixas := nTVCaixas + nCaixas
			nTVKilos  := nTVKilos  + nKilos
			nTVValTot := nTVValTot + nValtot
			
			//
			@nLin,113 PSAY "|"
			nLin := nLin + 1
			
		EndDo
		
		//
		If nOPc == 1
			@nLin,00 PSAY "|"+Replic("-",112)+"|"
			nLin := nLin + 1
			@nLin,000 PSAY "|"
			@nLin,002 PSAY " TOTAL " + left(cNomeSupervisor,12)
			@nLin,048 PSAY  nTVCaixas    Picture "@E 999,999,999"
			@nLin,062 PSAY  nTVKilos     Picture "@E 999,999.999"
			@nLin,076 PSAY  nTVValTot    Picture "@E 9999,999.99"
			@nLin,113 PSAY "|"
			nLin := nLin + 1
			@nLin,00 PSAY "|"+Replic("-",112)+"|"
			nLin := nLin + 1

		Else 

			//
			oExcel:AddRow(cNmAba,cNmAba,{;
											" TOTAL " + left(cNomeSupervisor,12),;
											"",;
											"",;
											nTVCaixas,;
											nTVKilos,;
											nTVValTot,;
											;
										})

		EndIf
		
		//
		nTScaixas := nTScaixas + nTVCaixas
		nTSKilos  := nTSKilos  + nTVKilos
		nTSValTot := nTSValTot + nTVValTot
		
		//
		nTVCaixas := 0
		nTVKilos  := 0
		nTVValTot := 0
		
		//
		If nOPc == 1
			If nLin > 60
				ImpCabec()
				nLin := nLin + 1

			EndIf

		EndIf
		
	End

	//
	If nOPc == 1
		@nLin,00 PSAY "|"+Replic("-",112)+"|"
		nLin := nLin + 1
		@nLin,000 PSAY "|"
		@nLin,002 PSAY " TOTAL GERAL "
		@nLin,048 PSAY  nTScaixas    Picture "@E 999,999,999"
		@nLin,062 PSAY  nTSKilos     Picture "@E 999,999.999"
		@nLin,076 PSAY  nTSValTot    Picture "@E 9999,999.99"
		@nLin,113 PSAY "|"
		nLin := nLin + 1
		@nLin,00 PSAY "|"+Replic("-",112)+"|"
		@nLin,113 PSAY "|"
		nLin := nLin + 1
		@nLin,00 PSAY "|"+Replic("-",112)+"|"
		nLin := nLin + 6
		nLin := 80

	Else 
			
		//
		oExcel:AddRow(cNmAba,cNmAba,{;
										" TOTAL GERAL ",;
										"",;
										"",;
										nTScaixas,;
										nTSKilos ,;
										nTSValTot,;
										;
									})

	EndIf

	//
	nTScaixas := 0
	nTSKilos  := 0
	nTSValTot := 0

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} consGeren
	Gera informações por gerente.
	@type  Static Function
	@author Everson
	@since 17/04/2020
	@version 01
	/*/
Static Function consGeren(nOPc,oExcel)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	 	 := GetArea()
	Local cNmAba 	 := getAbas()[3]
	Local cProduto   := ""  
	Local cProdedata := ""
	Local cSupervis  := ""
	Local nCaixas    := 0
	Local nKilos     := 0
	Local nValtot    := 0
	Local nTvcaixas  := 0
	Local nTvKILOS   := 0
	Local nTvVALTOT  := 0

	//
	DbSelectArea("TEMP")
	TEMP->(DbSetOrder(3))
	TEMP->(DBGOTOP())

	//
	ProcRegua(Contar("TEMP","!Eof()"))

	//
	TEMP->(DbGoTop())

	//
	While ! TEMP->(Eof())
		
		//
		IncProc()
		
		//
		If nOpc == 1
			If nLin > 60
				ImpCabec()
				nLin := nLin + 1

			EndIf

		EndIf
		
		//
		cProduto   := TEMP->TR_PRODUTO   
		cProdedata := TEMP->TR_EDATA
		nCaixas    := 0
		nKilos     := 0
		nValtot    := 0
		
		//
		Do While ! TEMP->(Eof()) .And. TEMP->TR_PRODUTO == cProduto
			nCaixas := nCaixas + TEMP->TR_CAIXAS
			nKilos  := nKilos  + TEMP->TR_KILOS
			nValtot := nValtot + TEMP->TR_VALTOT

			//
			TEMP->(Dbskip())

		Enddo

		//
		If nOpc == 1
			@nLin,000 PSAY "|"
			@nLin,019 PSAY  cProduto 
			@nLin,036 PSAY  cProdedata
			@nLin,048 PSAY  nCaixas    Picture "@E 999,999,999"
			@nLin,062 PSAY  nKilos     Picture "@E 999,999.999"
			@nLin,076 PSAY  nValtot    Picture "@E 9999,999.99"
			@nLin,091 PSAY  (nValtot/nKilos)    Picture "@E 99,999.999"
			@nLin,113 PSAY "|"
			nLin := nLin + 1

		Else 
				
			//
			oExcel:AddRow(cNmAba,cNmAba,{;
											cSupervis,;
											cProduto,;
											cProdEdata,;
											nCaixas,;
											nKilos,;
											nValtot,;
											Iif( nKilos <> 0, (nValtot/nKilos), 0);
										})

		EndIf

		//
		nTvcaixas := nTvcaixas + nCaixas
		nTvKILOS  := nTvKILOS  + nKilos
		nTvVALTOT := nTvVALTOT + nValtot
		
	End

	//
	If nOpc == 1
		@nLin,00 PSAY "|"+Replic("-",112)+"|"
		nLin := nLin + 1
		@nLin,000 PSAY "|"
		@nLin,002 PSAY " TOTAL GERAL "
		@nLin,048 PSAY  nTvcaixas    Picture "@E 999,999,999"
		@nLin,062 PSAY  nTvKILOS     Picture "@E 999,999.999"
		@nLin,076 PSAY  nTvVALTOT    Picture "@E 9999,999.99"
		@nLin,113 PSAY "|"
		nLin := nLin + 1
		@nLin,00 PSAY "|"+Replic("-",112)+"|"
		nLin := nLin + 1

	Else 

		//
		oExcel:AddRow(cNmAba,cNmAba,{;
										" TOTAL GERAL ",;
										"",;
										"",;
										nTvcaixas,;
										nTvKILOS,;
										nTvVALTOT,;
										;
									})		

	EndIf

	//
	nTvcaixas := 0
	nTvKILOS  := 0
	nTvVALTOT := 0

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} consProduto
	(long_description)
	@type  Static Function
	@author Everson
	@since 17/04/2020
	@version 01
	/*/
Static Function consProduto(nOpc,oExcel)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local cNmAba	:= getAbas()[4]
	Local nTQtdCx   := 0
	Local nTQtdKl   := 0
	Local cProduto  := ""
	Local cProdedata:= ""
	Local nQtdCx    := 0
	Local nQtdKl    := 0
	Local nEstCxs   := 0
	Local nEstKil   := 0

	//
	DbSelectArea("TEMP")
	TEMP->(DbSetOrder(3))
	TEMP->(DbGoTop())

	//
	ProcRegua(Contar("TEMP","!Eof()"))

	//
	TEMP->(DbGoTop())

	//
	nLin := 80

	//
	Do While ! TEMP->(Eof())

		//
		IncProc()
		
		//
		If nOpc == 1
			If nLin > 60
				ImpACabec()

			EndIf

		EndIf
		
		//
		cProduto   := TEMP->TR_PRODUTO
		nQtdCx     := 0
		nQtdKl     := 0
		nEstCxs    := 0
		nEstKil    := 0
		
		Do While TEMP->TR_PRODUTO == cProduto
			
			//
			nQtdCx := nQtdCx + TEMP->TR_CAIXAS
			nQtdKl := nQtdKl + TEMP->TR_KILOS

			//
			TEMP->(Dbskip())

		EndDo
		
		//
		SB1->(DbGoTop())
		SB1->(DbSeek(FWxFilial("SB1") + cProduto))

		//ALTERADO LEONARDO (HC) PARA CONTEMPLAR ARMAZEM 30 DA FILIAL 06 - ITUPEVA
		SB2->(DbGoTop())
		If cFilAnt <> '06'
			SB2->(DbSeek(FWxFilial("SB2") + Padr("10",6," ") + cProduto ) )

		Else
			SB2->(DbSeek(FWxFilial("SB2") + Padr("30",6," ") + cProduto ) )
		
		EndIf
		
		//
		nEstKil    := SB2->B2_QATU
		nEstCxs    := SB2->B2_QATU / SB1->B1_CONV
		cProdedata := ''
		cProdedata := TEMP->TR_EDATA	
		
		//
		If nOpc == 1
			@nLin,000 PSAY "|"
			@nLin,002 PSAY  cProduto   
			@nLin,019 PSAY  cProdedata
			@nLin,033 PSAY  nQtdCx              Picture "@E 99999999"
			@nLin,043 PSAY  nQtdKl              Picture "@E 999,999,999.999"
			@nLin,060 PSAY  nEstCxs             Picture "@E 99999999"
			@nLin,070 PSAY  nEstKil             Picture "@E 999,999,999.999"
			@nLin,087 PSAY  (nEstCxs - nQtdCx)  Picture "@E 99999999"
			@nLin,097 PSAY  (nEstKil - nQtdKl)  Picture "@E 999,999,999.999"
			@nLin,113 PSAY "|"
			nLin := nLin + 1

		Else 

			//
			oExcel:AddRow(cNmAba,cNmAba,{;
											cProduto,;
											cProdEdata,;
											nQtdCx,;
											nQtdKl,;
											nEstCxs,;
											nEstKil,;
											(nEstCxs - nQtdCx),;
											(nEstKil - nQtdKl);
										})

		EndIf
		
		nTQtdCx   := nTQtdCx + nQtdCx
		nTQtdKl   := nTQtdKl + nQtdKl
		
	EndDo

	//
	If nOpc == 1
		@nLin,000 PSAY "|"+Replic("-",112)+"|"
		nLin := nLin + 1
		@nLin,000 PSAY "|"
		@nLin,002 PSAY " TOTAL GERAL "
		@nLin,026 PSAY  nTQtdCx      Picture "@E 999,999,999,999"
		@nLin,043 PSAY  nTQtdKl      Picture "@E 999,999,999.999"
		@nLin,113 PSAY "|"
		nLin := nLin + 1
		@nLin,00 PSAY "|"+Replic("-",112)+"|"
		nLin := 80

	Else 

		//
		oExcel:AddRow(cNmAba,cNmAba,{;
										" TOTAL GERAL ",;
										"",;
										nTQtdCx,;
										nQtdKl,;
										nTQtdKl,;
										,;
										,;
										;
									})

	EndIf

	//
	nTQtdCx := 0
	nTQtdKl := 0

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} arqTemp
	Gera arquivo temporário.
	@type  Static Function
	@author Everson
	@since 17/04/2020
	@version 01
	/*/
Static Function arqTemp()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aStru := {}
	Local oTemp	:= Nil
	Local cAlias:= "TEMP"

	//
	Aadd(aStru,{"TR_FILIAL"   , "C",02,0})
	Aadd(aStru,{"TR_CODSUP"   , "C",06,0})
	Aadd(aStru,{"TR_NOMVEND"  , "C",12,0})
	Aadd(aStru,{"TR_VENDEDO"  , "C",06,0})
	Aadd(aStru,{"TR_PRODUTO"  , "C",06,0})
	Aadd(aStru,{"TR_DESCRI"   , "C",25,0})
	Aadd(aStru,{"TR_CAIXAS"   , "N",08,0})
	Aadd(aStru,{"TR_KILOS"    , "N",12,3})
	Aadd(aStru,{"TR_VALTOT"   , "N",12,2})
	Aadd(aStru,{"TR_PREMED"   , "N",12,2})
	Aadd(aStru,{"TR_EDATA"    , "C",04,0})

	//
	oTemp := FwTemporaryTable():New(cAlias)
	oTemp:SetFields(aStru)
	oTemp:AddIndex("indice1",{"TR_CODSUP","TR_VENDEDO","TR_PRODUTO"})
	oTemp:AddIndex("indice2",{"TR_CODSUP","TR_PRODUTO"})
	oTemp:AddIndex("indice3",{"TR_PRODUTO"})
	oTemp:Create()

Return oTemp
/*/{Protheus.doc} arqTemp
	Gera arquivo temporário.
	@type  Static Function
	@author Everson
	@since 17/04/2020
	@version 01
	/*/
Static Function ImpCabec()

	//Prepara o cabecalho padrao para o relatorio
	Cabec1 := "| META01.PRX "+SPACE(25)+"ADORO ALIMENTICIA  " +SPACE(34) + "Da  Entrega : " +DTOC(mv_par01) + '|'
	Cabec2 := "|" + SPACE(34)+ cTitulo +SPACE(27)+ "Ate Entrega : " + DTOC(MV_PAR02) + '|'
	//                   1         2         3         4         5         6         7         8         9         100       110
	//         012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
	Cabec3 := "|----------------------------------------------------------------------------------------------------------------|"
	Cabec4 := "|  VENDEDOR     | PROD. PROTHEUS | PROD. EDATA |TOTAL CAIXA | TOTAL KILOS | TOTAL VALOR|  PRECO MEDIO            |"
	Cabec5 := "|----------------------------------------------------------------------------------------------------------------|"

	nLin := 1

	@nLin,00 PSAY "|"+Replic("-",112)+"|"
	nLin := nLin + 1

	@ nlin,00 PSAY Cabec1
	nLin := nLin + 1

	@nLin,00 PSAY Cabec2
	nLin := nLin + 1

	@nLin,00 PSAY Cabec3
	nLin := nLin + 1

	@nLin,00 PSAY Cabec4
	nLin := nLin + 1

	@nLin,00 PSAY Cabec5
	//nLin := nLin + 1

Return()
/*/{Protheus.doc} ImpACabec
	Gera cabeçalho.
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static Function ImpACabec()

	Cabec10 := "| META01.PRX "+SPACE(25)+"ADORO ALIMENTICIA  " +SPACE(34) + "Da  Entrega : " +DTOC(mv_par01) + '|'
	Cabec20 := "|" + SPACE(34)+ cTitulo +SPACE(27)+ "Ate Entrega : " + DTOC(MV_PAR02) + '|'

	//                   1         2         3         4         5         6         7         8         9         100       110
	//          012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
	//                                           99999999  999,999,999.999  99999999  999,999,999.999  99999999  999,999,999.999
	Cabec30 := "|----------------------------------------------------------------------------------------------------------------|"
	Cabec40 := "|                |             | QUANTIDADE CARTEIRA       | QUANTIDADE ESTOQUE       | SALDOS                   |"
	Cabec50 := "| PROD. PROTHEUS | PROD. EDATA |---------------------------------------------------------------------------------|"
	Cabec60 := "|                |             | CAIXAS   |  QUILOS        | CAIXAS  |    QUILOS      | CAIXAS  |   QUILOS       |"
	Cabec70 := "|----------------------------------------------------------------------------------------------------------------|"

	nLin := 1

	@nLin,00 PSAY "|"+Replic("-",112)+"|"
	nLin := nLin + 1

	@ nlin,00 PSAY Cabec10
	nLin := nLin + 1

	@nLin,00 PSAY Cabec20
	nLin := nLin + 1

	@nLin,00 PSAY Cabec30
	nLin := nLin + 1

	@nLin,00 PSAY Cabec40
	nLin := nLin + 1

	@nLin,00 PSAY Cabec50
	nLin := nLin + 1

	@nLin,00 PSAY Cabec60
	nLin := nLin + 1

	@nLin,00 PSAY Cabec70
	nLin := nLin + 1

Return()
/*/{Protheus.doc} SqlProdEdata
	Obtém dados do Edata.
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static Function SqlProdEdata(cProduto)

	Local cQueryEdata := ''
	Local cProd       := ''
		
	cQueryEdata := "SELECT PROD_EDATA.ID_PRODDEFIMATEEMBA AS PRODEDATA "
    cQueryEdata += "  FROM [LNKMIMS].[SMART].[dbo].[MATERIAL_EMBALAGEM_DEFINICAO] PROD_EDATA "
    cQueryEdata += " WHERE (PROD_EDATA.IE_DEFIMATEEMBA COLLATE Latin1_General_CI_AS)  = '" + cProduto + "'"
    
	TCQUERY cQueryEdata new alias "TRC"
	
	dbSelectArea("TRC")   
	TRC->(DBGOTOP())    
	WHILE TRC->(!EOF())    
	
		cProd := TRC->PRODEDATA
	
		TRC->(dbSkip())     	
	EndDo
	TRC->(dbCloseArea())
	
RETURN(cProd)
/*/{Protheus.doc} gerObjExc
	Gera objeto excel.
	@type  Static Function
	@author Everson
	@since 16/04/2020
	@version 01
	/*/
Static Function gerObjExc()
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local oExcel	:= Nil
	Local aAbas		:= getAbas()
	Local cNmAba1	:= aAbas[1]
	Local cNmAba2	:= aAbas[2]
	Local cNmAba3	:= aAbas[3]
	Local cNmAba4	:= aAbas[4]
	Local aColunas1	:= {"VENDEDOR","PROD. PROTHEUS","PROD. EDATA","TOTAL CAIXA","TOTAL KILOS","TOTAL VALOR","TOTAL PRECO MEDIO"}
	Local aColunas2	:= {"PROD. PROTHEUS","PROD. EDATA","CART. CAIXAS"," CART. QUILOS","ESTOQUE CAIXAS","ESTOQUE QUILOS","SALDOS CAIXAS","SALDOS QUILOS"}

	//
	oExcel := FWMSExcel():New()

	//
	oExcel:AddWorkSheet(cNmAba1)
	oExcel:AddTable(cNmAba1,cNmAba1)
	oExcel:AddColumn(cNmAba1,cNmAba1,aColunas1[1],1,1)
	oExcel:AddColumn(cNmAba1,cNmAba1,aColunas1[2],1,1)
	oExcel:AddColumn(cNmAba1,cNmAba1,aColunas1[3],1,1)
	oExcel:AddColumn(cNmAba1,cNmAba1,aColunas1[4],3,2)
	oExcel:AddColumn(cNmAba1,cNmAba1,aColunas1[5],3,2)
	oExcel:AddColumn(cNmAba1,cNmAba1,aColunas1[6],3,2)
	oExcel:AddColumn(cNmAba1,cNmAba1,aColunas1[7],3,2)

	//
	oExcel:AddWorkSheet(cNmAba2)
	oExcel:AddTable(cNmAba2,cNmAba2)
	oExcel:AddColumn(cNmAba2,cNmAba2,aColunas1[1],1,1)
	oExcel:AddColumn(cNmAba2,cNmAba2,aColunas1[2],1,1)
	oExcel:AddColumn(cNmAba2,cNmAba2,aColunas1[3],1,1)
	oExcel:AddColumn(cNmAba2,cNmAba2,aColunas1[4],3,2)
	oExcel:AddColumn(cNmAba2,cNmAba2,aColunas1[5],3,2)
	oExcel:AddColumn(cNmAba2,cNmAba2,aColunas1[6],3,2)
	oExcel:AddColumn(cNmAba2,cNmAba2,aColunas1[7],3,2)

	//
	oExcel:AddWorkSheet(cNmAba3)
	oExcel:AddTable(cNmAba3,cNmAba3)
	oExcel:AddColumn(cNmAba3,cNmAba3,aColunas1[1],1,1)
	oExcel:AddColumn(cNmAba3,cNmAba3,aColunas1[2],1,1)
	oExcel:AddColumn(cNmAba3,cNmAba3,aColunas1[3],1,1)
	oExcel:AddColumn(cNmAba3,cNmAba3,aColunas1[4],3,2)
	oExcel:AddColumn(cNmAba3,cNmAba3,aColunas1[5],3,2)
	oExcel:AddColumn(cNmAba3,cNmAba3,aColunas1[6],3,2)
	oExcel:AddColumn(cNmAba3,cNmAba3,aColunas1[7],3,2)

	//
	oExcel:AddWorkSheet(cNmAba4)
	oExcel:AddTable(cNmAba4,cNmAba4)
	oExcel:AddColumn(cNmAba4,cNmAba4,aColunas2[1],1,1)
	oExcel:AddColumn(cNmAba4,cNmAba4,aColunas2[2],1,1)
	oExcel:AddColumn(cNmAba4,cNmAba4,aColunas2[3],3,2)
	oExcel:AddColumn(cNmAba4,cNmAba4,aColunas2[4],3,2)
	oExcel:AddColumn(cNmAba4,cNmAba4,aColunas2[5],3,2)
	oExcel:AddColumn(cNmAba4,cNmAba4,aColunas2[6],3,2)
	oExcel:AddColumn(cNmAba4,cNmAba4,aColunas2[7],3,2)
	oExcel:AddColumn(cNmAba4,cNmAba4,aColunas2[8],3,2)

	//
	RestArea(aArea)

Return oExcel
/*/{Protheus.doc} getAbas
	Abas para montagem do objeto excel.
	@type  Static Function
	@author user
	@since 16/04/2020
	@version 01
	/*/
Static Function getAbas()
Return {"Cons. Vend.","Cons. Supe.","Cons. Gere.","Cons. Prod."}
