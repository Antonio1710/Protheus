#Include "Protheus.ch" 
#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function ROTLOG
	Relatorio PEDIDOS POR ROTEIRO
	@type  Function
	@author Rogerio Eduardi Nutti
	@since 06/08/2002
	@version version
	@history Alteração - Fernando Sigoli - 18/03/2019 - Chamado: 047975 - adicionado informaçoes de controle shelflife de clientes (A1_XSFLFDS)
	@history Alteração - William Costa   - 26/03/2019 - Chamado: 048118 - declarado variaveis que estavam faltando no programa
    @history Alteração - Fernando Sigoli - 01/04/2019 - Chamado: 047975 - ADICIONADO CONTROLE/AVISO DE CARREGAMENTO PALETIZADO (A1_XPALETE)
	@history Alteração - Fernando Sigoli - 08/04/2019 - Chamado: 047975 - Ajustado Query para trazer apenas produto refriado no Shelflife
	@history Alteração - Fernando Sigoli - 02/05/2019 - Chamado: 047975 - segmentado query para tratar shelflife x controle de palete
	@history Alteração - FWNM            - 02/08/2019 - Chamado: 049495 - 
	@history Alteração - FWNM            - 08/08/2019 - Chamado: 049495 - Incluir novo campo ZFM_NUMCE2
	@history Alteração - FWNM            - 12/08/2019 - Chamado: 049495 - Incluir novo pergunte MV_PAR15
	@history Alteração - William Costa   - 25/11/2019 - Chamado: 053588 - Adiciona para não trazer placas iguais a branco no relatório
	@history Alteração - William Costa   - 05/12/2019 - Chamado: 053889 - Alterado a descrição do relatório do campo do protheus para o campo do Edata 
	@history Alteração - William Costa   - 26/02/2020 - Chamado: 056129 - Foi ajustado a programação que se não encontrar a descrição no Edata irá trazer a que está no pedido de venda do Protheus.  Essa pergunta só foi feita na Adoro e não na Ceres onde estava gerando o erro. Foi ajustado as perguntas não ocasionando mais os Erros.
	@history Alteração - Everson         - 03/07/2020 - Chaamdo: 059401 - Adicionado impressão de vale palete.
	@history Alteração - Everson         - 19/10/2021 - Chaamdo: 055129 - Tratamento para melhorar o desempenho do relatório.
/*/

User Function ROTLOG() // U_ROTLOG()

	//Everson - 19/10/2021. Chamado 55129.
	Private aDados		:= {}
	Private oPrdEdt	   	:= Nil
	//

	Private _ROTEIRO 	:= ''
	Private _PLACA   	:= ''
	Private _DTENTR  	:= CTOD('  /  /  ')
	Private limite
	Private _Prodedata 	:= SPACE(06)
	Private _DESCRI    	:= SPACE(60)

	MsAguarde({|| oPrdEdt := getPrdEdt() }, "ROTLOG", "Carregando produtos do Edata...", .F.) //Everson - 19/10/2021. Chamado 55129.

	aOrd             := {}
	tamanho          := "M"
	//limite           := 132
	limite           := 132
	WNREL            := "ROTLOG"
	nomeprog         := "ROTLOG"
	mv_tabpr         := ""
	nTipo            := 18
	aReturn          := { "Zebrado", 1,"Administracao", 2, 2, 1,"",1}
	nLastKey         := 0
	nlin             := 99
	nItem            := 1
	lContinua        := .T.
	_lLib     		 := .F.
	_NTARA           := 0
	_aLinha			 :={}
	
	m_pag	   := 01
	imprime    := .T.
	
	cPerg   := "RPEDRO"
	Pergunte(cPerg,.F.)
	
	cString := "SC6"
	titulo  := "PEDIDOS POR ROTEIRO"
	cDesc1  := "Este programa tem como objetivo imprimir os Pedidos de"
	cDesc2  := "Venda por Roteiro."
	cDesc3  := ""
	_cPag	:=	0
	nomerel := "ROTLOG"
	nomerel := SetPrint(cString,Nomerel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho)

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio PEDIDOS POR ROTEIRO')
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	If nLastKey == 27
		Return
	Endif
	
	#IFDEF WINDOWS
		Processa({|| RunCont()},Titulo )
		Return
		Static Function RunCont()
		ProcRegua(RecCount())
	#ELSE
		SetRegua(RecCount())
	#ENDIF  
	
	_aStru := {}
	aAdd(_aStru,{"TP_PRODUTO"  , "C",06,0})
	aAdd(_aStru,{"TP_TES"      , "C",03,0})
	aAdd(_aStru,{"TP_DESCRI"   , "C",60,0})
	aAdd(_aStru,{"TP_CAIXAS"   , "N",06,0})
	aAdd(_aStru,{"TP_KILOS"    , "N",12,3})
	aAdd(_aStru,{"TP_TARA"     , "C",02,0})
	aAdd(_aStru,{"TP_VALTOT"   , "N",12,2})
	aAdd(_aStru,{"TP_ROTEIRO"  , "C",3,0})
	aAdd(_aStru,{"TP_REPROG"   , "C",1,0})
	aAdd(_aStru,{"TP_PLACA"    , "C",10,0})
	aAdd(_aStru,{"TP_DTENTR"   , "D",8,0})
	aAdd(_aStru,{"TP_XCATEG"   , "C",2,0})
	aAdd(_aStru,{"TP_X5_DESC"  , "C",40,0})  
	aAdd(_aStru,{"TP_PRODEDA"  , "C",6,0})
	              
	// *** INICIO ALTERACAO WILL PARA CRIAR INDICES CHAMADO 030812  *** //
	// Ambas as maneiras devem proceder estes comandos abaixo:
	// Criar fisicamente o arquivo.
	_cNomTRB := CriaTrab( _aStru, .T. )
	cInd1 := Left( _cNomTRB, 7 ) + "1"
	cInd2 := Left( _cNomTRB, 7 ) + "2"
	// Acessar o arquivo e coloca-lo na lista de arquivos abertos.
	dbUseArea( .T., __LocalDriver, _cNomTRB, "TEMP", .F., .F. )
	// Criar os índices.
	IndRegua( "TEMP", cInd1, "TP_ROTEIRO+TP_PRODUTO", , , "Criando índices (Prefixo + Ordem)...")
	IndRegua( "TEMP", cInd2, "TP_ROTEIRO+TP_XCATEG+DESCEND(STR(TP_CAIXAS,6))", , , "Criando índices (Descrição)...")
	// Libera os índices.
	dbClearIndex()
	// Agrega a lista dos índices da tabela (arquivo).
	dbSetIndex( cInd1 + OrdBagExt() )
	dbSetIndex( cInd2 + OrdBagExt() )                                     
	
	// *** FINAL ALTERACAO WILL PARA CRIAR INDICES CHAMADO 030812  *** //
	
	dbSelectArea("TEMP") ; dbSetOrder(1)
	
	dbSelectArea("SB1") ; dbSetOrder(1)
	dbSelectArea("SB2") ; dbSetOrder(1)
	dbSelectArea("SA3") ; dbSetOrder(1)
	dbSelectArea("SC6") ; dbSetOrder(1)
	dbSelectArea("SZC") ; dbSetOrder(1)
		
	// INICIO DO FILTRO POR VENDEDOR - RAFAEL H SILVEIRA 27/04/2006
	_cUserName  := Subs(cUsuario,7,15)  // Nome do Usuario
	
	_cCodVen := ''
	_cCodSup := ''
	_cSupVends := ''
	
	_cUserName  := Subs(cUsuario,7,15)   // Nome do Usuario
	
	If !(Alltrim(_cUserName) $ GetMV("MV_GERENTE") )         // Se for gerente nao tem Filtro
		
		dbSelectArea("SZR")
		dbSetOrder(2)            // ZR_FILIAL+ZR_DESCRIC
		If dbSeek( xFilial("SZR")+_cUserName )
			
			_cCodSup := SZR->ZR_CODIGO            // Busca Codigo Supervisor
			
			dbSelectArea("SA3")
			dbSetOrder(5)        // A3_FILIAL+A3_SUPER
			If dbSeek( xFilial("SA3")+_cCodSup )
				
				_cSupVends  := ""
				Do While !Eof() .and. xFilial("SA3") == SA3->A3_FILIAL	.and. ;
					_cCodSup       == SA3->A3_SUPER
					_cSupVends  :=  _cSupVends + "'"+SA3->A3_COD+"', "
					
					dbSelectArea("SA3")
					dbSkip()
				Enddo
				if !empty(_cSupVends                                                    )
					_cSupVends := left(_cSupVends,len(_cSupVends)-2)
				endif
				
			Endif
		Else

			dbSelectArea("SA3")
			dbSetOrder(2)
			If dbSeek( xFilial("SA3")+_cUserName )
				
				_cSupVends := "'"+SA3->A3_COD+"'"              // Busca Codigo Vendedor
				
			Endif
			
		Endif
		
	Endif
		
	//Everson - 03/07/2020. Chamado 059401.
	cQuery	:=	sqlRel() + " ORDER BY C5_ROTEIRO, C5_SEQUENC"
	TCQUERY cQuery new alias "XC5"
	dbSelectArea("XC5")
	dbGotop()
	
	_nTTotCaixas := 0
	_nTTotKilos  := 0
	_nTTotValTot := 0
	_nTotCaixas  := 0
	_nTotKilos   := 0
	_nTotValTot  := 0
	_Placa       := space(02)
	_DtEntre     := date()
	_cRotAnt     := ""
	
	Do While !Eof()
		
		IncProc()
		
		IF MV_PAR11=1 //SIM
			IF EMPTY(XC5->C5_NOTA)
				DBSKIP()
				LOOP
			ENDIF
		Else
			IF !EMPTY(XC5->C5_NOTA)
				DBSKIP()
				LOOP
			ENDIF
		ENDIF
		
		dbSelectArea("SA3")
		DBSETORDER(1)
		If	dbSeek( xFilial("SA3") + XC5->C5_VEND1 )
			
			_cNomVend1 := SA3->A3_NOME
			_cNomSuper := SA3->A3_SUPERVIS
		Else
			_cNomVend1 := ''
			_cNomSuper := ''
		EndIf
		
		IF !XC5->C5_TIPO $ 'BD'

			dbSelectArea("SA1")
			dbsetorder(1)
			If dbSeek( xFilial("SA1") + XC5->C5_CLIENTE + XC5->C5_LOJAENT)

				If !empty(alltrim(SA1->A1_ENDENT))   // INCLUIDO POR HERALDO 26/08/03
					_cEndEnt	:= SA1->A1_ENDENT
					_cTelEnt	:= PADR(ALLTRIM(SA1->A1_DDD)+IIF(!EMPTY(ALLTRIM(SA1->A1_DDD))," ","")+ALLTRIM(SA1->A1_TEL),15)//SA1->A1_TEL
					_cMunEnt	:= SA1->A1_MUNE
					_cBaiEnt	:= SA1->A1_BAIRROE
					_cUFEnt  := SA1->A1_ESTE
					_cCEPEnt	:= SA1->A1_CEPE
				Else
					_cEndEnt	:= SA1->A1_END
					_cTelEnt	:= PADR(ALLTRIM(SA1->A1_DDD)+IIF(!EMPTY(ALLTRIM(SA1->A1_DDD))," ","")+ALLTRIM(SA1->A1_TEL),15) //SA1->A1_TEL
					_cMunEnt	:= SA1->A1_MUN
					_cBaiEnt	:= SA1->A1_BAIRRO
					_cUFEnt	:= SA1->A1_EST
					_cCEPEnt	:= SA1->A1_CEP
				Endif
				_cCNPJ      := SA1->A1_CGC
				_cInsc      := SA1->A1_INSCR
				_cNomCli		:=SA1->A1_NOME
			Else
				_cEndEnt	:= ''
				_cTelEnt	:= ''
				_cMunEnt	:= ''
				_cBaiEnt	:= ''
				_cUFEnt	:= ''
				_cCEPEnt	:= ''
				_cCNPJ   := ''
				_cInsc   := ''
				_cNomCli	:= ''
			endif
		ELSE

			dbSelectArea("SA2")
			dbsetorder(1)
			If dbSeek( xFilial("SA2") + XC5->C5_CLIENTE + XC5->C5_LOJAENT)

				_cEndEnt	:= SA2->A2_END
				_cTelEnt	:= PADR(ALLTRIM(SA2->A2_DDD)+IIF(!EMPTY(ALLTRIM(SA2->A2_DDD))," ","")+ALLTRIM(SA2->A2_TEL),15) //SA2->A2_TEL
				_cMunEnt	:= SA2->A2_MUN
				_cBaiEnt	:= SA2->A2_BAIRRO
				_cUFEnt  	:= SA2->A2_EST
				_cCEPEnt	:= SA2->A2_CEP
				_cCNPJ   	:= SA2->A2_CGC
				_cInsc   	:= SA2->A2_INSCR
				_cNomCli	:=SA2->A2_NOME
			Else
				_cEndEnt	:= ''
				_cTelEnt	:= ''
				_cMunEnt	:= ''
				_cBaiEnt	:= ''
				_cUFEnt	:= ''
				_cCEPEnt	:= ''
				_cCNPJ   := ''
				_cInsc   := ''
				_cNomCli	:= ''
			EndIf
		EndIf                              
		
		If Alltrim(_cRotAnt) <> Alltrim(XC5->C5_ROTEIRO) .And. Alltrim(_cRotAnt) <> ""
			FResumoC(_cRotAnt)
	
			_cPag++
			nLin := 1
			@ nLin,001 PSAY "ROTLOG"
			if mv_par12 == 2
				@ nLin,025 PSAY  " R E L A T O R I O   D E   C O N F E R E N C I A    D E   P E D I D O"
			else
				@ nLin,025 PSAY  " R E L A T O R I O   D E   C A R R E G A M E N T O  D E   P E D I D O"
			endif
			@ nLin,110 PSAY str(_cPag,3)
			@ nLin,120 PSAY date()		

			// Chamado n. 049495 || OS 050775 || ADM.LOG || MARCEL || 8365 || ROMANEIO ENTREGAS - FWNM - 02/08/2019
			cRotZFN   := Alltrim(XC5->C5_ROTEIRO)
			UpRotAtend(cRotZFN, @nLin)
			//
		Endif

		_cRotAnt := Alltrim(XC5->C5_ROTEIRO)
		
		dbSelectArea("XC5")
		_Placa :=XC5->C5_PLACA             	
		
		If nLin > 55

			_cPag++
			nLin := 1
			@ nLin,001 PSAY "ROTLOG"
			if mv_par12 == 2
				@ nLin,025 PSAY  " R E L A T O R I O   D E   C O N F E R E N C I A    D E   P E D I D O"
			else
				@ nLin,025 PSAY  " R E L A T O R I O   D E   C A R R E G A M E N T O  D E   P E D I D O"
			endif
			//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
			//          1         2         3         4         5         6         7         8         9         100
			@ nLin,110 PSAY str(_cPag,3)
			@ nLin,120 PSAY date()

			// Chamado n. 049495 || OS 050775 || ADM.LOG || MARCEL || 8365 || ROMANEIO ENTREGAS - FWNM - 02/08/2019
			cRotZFN   := Alltrim(XC5->C5_ROTEIRO)
			UpRotAtend(cRotZFN, @nLin)
			//

		Endif
		nLin := nLin + 2
		
		IF MV_PAR14 == 2 // 1== NAO 2==SIM  INCLUIDO POR WESLEY CHAMADO 029389
		
			// Chamado n. 049495 || OS 050775 || ADM.LOG || MARCEL || 8365 || ROMANEIO ENTREGAS - FWNM - 02/08/2019
			//cRotZFN   := Alltrim(XC5->C5_ROTEIRO)
			//UpRotAtend(cRotZFN, @nLin)
			//

			@ nLin, 000 PSAY "PEDIDO  : "	+	XC5->C5_NUM + "  TIPO "+XC5->C5_TIPO
			@ nLin, 029 PSAY "NUM. NF : "	+	XC5->C5_NOTA
			nLin := nLin + 1
			@ nLin, 000 PSAY "ROTEIRO : "    +	XC5->C5_ROTEIRO +" Seq.: "+XC5->C5_SEQUENC
			@ nLin, 029 PSAY "CLIENTE : " 	+ 	XC5->C5_CLIENTE +"/"+ XC5->C5_LOJAENT +" "+ _cNomCli
			@ nLin, 104 PSAY "TELEFONE: "	+	_cTelEnt
			nLin := nLin + 1
			@ nLin, 000 PSAY "HORARIO ENTREGA : M: " +	UPPER(XC5->C5_HRINIM) + " - " +	UPPER(XC5->C5_HRFINM) + " | T: " + UPPER(XC5->C5_HRINIT) + " - " +	UPPER(XC5->C5_HRFINT) //Everson - 09/11/2017. Chamado 037879.
			@ nLin, 079 PSAY "PRIORIDADE : " + 	Alltrim(cValToChar(XC5->C5_PRIOR)) //Everson - 09/11/2017. Chamado 037879.
			nLin := nLin + 1
			@ nLin, 000 PSAY "C.N.P.J.: "    +	_cCNPJ
			@ nLin, 029 PSAY "INSC.CLIENTE : " 	+ 	_cInsc
			nLin := nLin + 1
			
			@ nLin, 000 PSAY "PLACA   : " 	+	XC5->C5_PLACA
			@ nLin, 029 PSAY "ENDERECO: " 	+ 	_cEndEnt
			@ nLin, 079 PSAY "CIDADE	 : "	+	_cMunEnt
			@ nLin, 104 PSAY "BAIRRO: "		+	_cBaiEnt
			nLin := nLin + 1
			@ nLin, 000 PSAY "VENDEDOR: "	+	XC5->C5_VEND1
			@ nLin, 029 PSAY "SUPERV. : "	+	_cNomSuper
			@ nLin, 079 PSAY "ESTADO : " 	+ 	_cUFEnt
			@ nLin, 104 PSAY "CEP: "    		+ 	_cCEPEnt
			
			nLin := nLin + 1                                                          
			@ nLin, 000 PSAY "OBS/SHELFLIFE : "	+ Posicione("SA1",1,xFilial("SA1")+ XC5->C5_CLIENTE + XC5->C5_LOJAENT ,"A1_XSFLFDS")  //Chamado: 047975 - Fernando Sigoli 18/03/2019  
			
			nLin := nLin + 1
			@ nLin, 000 PSAY Repl("=",limite)
			nLin := nLin + 1
			// Alteracao hcconsys - 23/10/08
			If mv_par12 == 2
				@ nLin, 000 PSAY "Produto    Descricao do Produto                                          TES Qtde Cx 2UM  Valor Unit.  Qtde  Kg   UM   Valor Total"
			ELSE
				@ nLin, 000 PSAY "Produto    Descricao do Produto                                          TES Qtde Cx 2UM  Valor Unit.  Qtde  Kg   UM       QTDE CX"
			ENDIF
			
			nLin := nLin + 1
			@ nLin, 000 PSAY Repl("-",limite)
			nLin := nLin + 2
			_nTotCaixas := 0
			_nTotKilos  := 0
			_nTotValTot := 0
			_produto    := space(06)
			_prodedata  := space(06)
			_c2Um       := space(02)
			dbSelectArea("SC6")
			dbSeek( xFilial("SC6") + XC5->C5_NUM )
			// Verifico se todos os itens foram faturados
			Do While !Eof() .and. SC6->C6_FILIAL == xFilial("SC6") .and.;
				SC6->C6_NUM    == XC5->C5_NUM
				If (SC6->C6_NOTA  <> ' ' .AND. mv_par11 == 1) .OR.( mv_par11 <> 1 ) .OR. (XC5->C5_TIPO $ 'DB')
					If nLin > 68
						nLin := 1
						If mv_par12 == 2
							@ nLin, 000 PSAY "Produto    Descricao do Produto                                          TES Qtde Cx 2UM  Valor Unit.  Qtde  Kg   UM   Valor Total"
						else
							@ nLin, 000 PSAY "Produto    Descricao do Produto                                          TES Qtde Cx 2UM  Valor Unit.  Qtde  Kg   UM       QTDE CX"
						endif
						nLin := nLin + 1
						@ nLin, 000 PSAY Repl("-",limite)
						nLin := nLin + 2
					Endif
					
						_Produto := left(SC6->C6_PRODUTO,10) //C6_PRODUTO

						// *** INICIO CHAMADO 053889 WILLIAM COSTA 05/12/2019
						// SqlProdEdata(_Produto)
						// DBSELECTAREA("TRC")   
						// TRC->(DBGOTOP())    
						
						// WHILE TRC->(!EOF())    
						
						// 	_Prodedata := TRC->PRODEDATA
						// 	_Descri    := TRC->DESCEDATA 
						// 	TRC->(DBSKIP())     	
						// ENDDO

						// IF TRC->(EOF())

						// 	_Descri    := SC6->C6_DESCRI

						// ENDIF
						// TRC->(DBCLOSEAREA())
						// *** FINAL CHAMADO 053889 WILLIAM COSTA 05/12/2019

						//Everson - 19/10/2021. Chamado 55129.
							aDados := {}
							oPrdEdt:Get(Alltrim(cValToChar(SC6->C6_PRODUTO)), aDados)

							If Len(aDados) > 0
								_Prodedata := aDados[1]
								_Descri    := aDados[2]
							
							Else
								_Descri    := SC6->C6_DESCRI
								
							EndIf
						//

						_tes     := SC6->C6_TES
						//_Descri  := SC6->C6_DESCRI //CHAMADO 053889 WILLIAM COSTA 05/12/2019
						_DtEntre := SC6->C6_ENTREG
						_c2Um    := SC6->C6_SEGUM 
						
						@ nLin, 000  PSAY _PRODUTO
		     			@ nLin, 011  PSAY _Descri //016
					
					
					dbSelectArea("SC9") // Itens de pedido liberado
					dbSetOrder(01) // Indice ( pedido )
					If dbSeek( xFilial("SC9")+ XC5->C5_NUM)
					    
						// INICIO CHAMADO 033454 - WILLIAM COSTA
						While !SC9->(Eof()) .AND. SC9->(C9_FILIAL+C9_PEDIDO) == (xFilial("SC9")+ XC5->C5_NUM)
						
							// SOMA PESO BRUTO DAS NOTAS QUE SENSIBILIZAM O ESTOQUE
							If Empty(SC9->C9_BLEST ) .AND. Empty(SC9->C9_BLCRED)
								_lLib	:= .t.
							else
								_lLib := .f.
								EXIT
							Endif
							SC9->(dbSkip())
						ENDDO	
						// FINAL CHAMADO 033454 - WILLIAM COSTA
					Else
						_lLib := .f.
					Endif
					
					dbSelectArea("SC6")
					if _lLib .And. mv_par11 == 2//.or. mv_par12 == 2 .or. C6_QTDENT>0  &&Mauricio - 26/03/10 - Solicitado por Caio trazer apenas itens liberados no relatorio.
					    //PASSAR PARA UM PARAMETRO
						If  !(SUBSTR(C6_CF,2,3) $ ALLTRIM(GETMV("MV_NOSC6C1")))     
							
							//Incluido por roteiro
							dbSelectArea("TEMP")
							dbSetOrder(1)
							If !dbSeek(XC5->C5_ROTEIRO+_Produto)
								RecLock("TEMP",.T.)
							Else
								RecLock("TEMP",.F.)
							Endif
							
							Replace TP_ROTEIRO   With XC5->C5_ROTEIRO
							Replace TP_REPROG    With XC5->C5_PRIOR    &&Mauricio -  04/08/17 - Chamado 036478
							Replace TP_PRODUTO   With _Produto
							Replace TP_TES       With _tes
							Replace TP_DESCRI    With _DESCRI
							Replace TP_CAIXAS    With TP_CAIXAS + SC6->C6_UNSVEN
							Replace TP_KILOS     With TP_KILOS  + SC6->C6_QTDVEN
							Replace TP_TARA      With _c2Um
							Replace TP_VALTOT    With TP_VALTOT + SC6->C6_VALOR
							Replace TP_PLACA     With XC5->C5_PLACA					
							Replace TP_DTENTR    With SC6->C6_ENTREG
							Replace TP_XCATEG    With Posicione("SB1",1,xFilial("SB1")+_Produto,"B1_XCATEG")
							Replace TP_X5_DESC   With alltrim(posicione("SX5",1,xFilial("SC5")+"82"+Posicione("SB1",1,xFilial("SB1")+_Produto,"B1_XCATEG"),"X5_DESCRI"))
							Replace TP_PRODEDA   With _prodedata //'WiLL' 
							MsUnlock() 					
							
							@ nLin, 073  PSAY SC6->C6_TES   //incluido por Adriana em 09/06/08
							@ nLin, 078  PSAY SC6->C6_UNSVEN  PICTURE "@Z 999,999"
							@ nLin, 087  PSAY SC6->C6_SEGUM
							@ nLin, 091  PSAY SC6->C6_PRCVEN  PICTURE "@Z 999999.9999"      // VUnit UM2
							@ nLin, 104  PSAY SC6->C6_QTDVEN  PICTURE "@Z 999999.99"        // Qtd UM1
							@ nLin, 115  PSAY SC6->C6_UM                                    // UM  1
							
							// alteracao hcconsys 23/10/08
							
							If mv_par12 == 2
								@ nLin, 118  PSAY SC6->C6_VALOR   PICTURE "@Z 999,999,999.99"   // Vlt Total
								nLin := nLin + 1
							else
								@ nLin, 118  PSAY iif(SC6->C6_QTDENT>0,"__ FATURADO  __","_______________")
								nLin := nLin + 2
								//fim alteracao hcconsys 23/10/08
							endif
						    _nTotCaixas := _nTotCaixas + SC6->C6_UNSVEN
							_nTotkilos  := _nTotKilos  + SC6->C6_QTDVEN
							_nTotValTot := _nTotValtot + SC6->C6_VALOR
						    	
						Endif
					   
					Elseif MV_PAR11 == 1
						If  !(SUBSTR(SC6->C6_CF,2,3) $ ALLTRIM(GETMV("MV_NOSC6C1")))
							@ nLin, 073  PSAY SC6->C6_TES 
							@ nLin, 078  PSAY SC6->C6_UNSVEN  PICTURE "@Z 999,999"
							@ nLin, 087  PSAY SC6->C6_SEGUM
							@ nLin, 091  PSAY SC6->C6_PRCVEN  PICTURE "@Z 999999.9999"      // VUnit UM2
							@ nLin, 104  PSAY SC6->C6_QTDVEN  PICTURE "@Z 999999.99"        // Qtd UM1
							@ nLin, 115  PSAY SC6->C6_UM
						   	If mv_par12 == 2
								@ nLin, 118  PSAY SC6->C6_VALOR   PICTURE "@Z 999,999,999.99"   // Vlt Total
								nLin := nLin + 1
							else
								@ nLin, 118  PSAY iif(SC6->C6_QTDENT>0,"__ FATURADO  __","_______________")
								nLin := nLin + 2
							endif
						    //	@ nLin, 118  PSAY iif(C6_QTDENT>0,"__ FATURADO  __","_______________")
							//nLin := nLin + 2
							_nTotCaixas := _nTotCaixas + SC6->C6_UNSVEN
							_nTotkilos  := _nTotKilos  + SC6->C6_QTDVEN
							_nTotValTot := _nTotValtot + SC6->C6_VALOR 
							
							dbSelectArea("TEMP")
							dbSetOrder(1)
							If !dbSeek(XC5->C5_ROTEIRO+_Produto)
								RecLock("TEMP",.T.)
							Else
								RecLock("TEMP",.F.)
							Endif  
							Replace TP_ROTEIRO   With XC5->C5_ROTEIRO
							Replace TP_REPROG    With XC5->C5_PRIOR    &&Mauricio -  04/08/17 - Chamado 036478					
							Replace TP_PRODUTO   With _Produto
							Replace TP_TES       With _tes
							Replace TP_DESCRI    With _DESCRI
							Replace TP_CAIXAS    With TP_CAIXAS + SC6->C6_UNSVEN
							Replace TP_KILOS     With TP_KILOS  + SC6->C6_QTDVEN
							Replace TP_TARA      With _c2Um
							Replace TP_VALTOT    With TP_VALTOT + SC6->C6_VALOR
							Replace TP_PLACA     With XC5->C5_PLACA					
							Replace TP_DTENTR    With SC6->C6_ENTREG					
							Replace TP_XCATEG    With Posicione("SB1",1,xFilial("SB1")+_Produto,"B1_XCATEG")
							Replace TP_X5_DESC   With alltrim(posicione("SX5",1,xFilial("SC5")+"82"+Posicione("SB1",1,xFilial("SB1")+_Produto,"B1_XCATEG"),"X5_DESCRI"))
							Replace TP_PRODEDA   With _prodedata //'WiLL' 'WiLL' 
							MsUnlock()					
							
						ELSE
						    @ nLin, 073  PSAY SC6->C6_TES 	
							@ nLin, 077  PSAY "------------    N A O   L I B E R A D O  POR   TES   ---"     //incluido por Adriana em 09/06/08
						    nLin := nLin + 2
						Endif 
						 
					Else
						@ nLin, 073  PSAY "--------------    N A O   L I B E R A D O    --------------"     //incluido por Adriana em 09/06/08
						nLin := nLin + 2
					Endif
				Endif
				
				dbSelectArea("SC6")
				dbSkip()
				Loop
			Enddo
			
			@ nLin, 000 PSAY Repl("-",limite)
			nLin := nLin + 1
			
			@ nLin, 003 PSAY "Cond.Pagto.: "+ XC5->C5_CONDPAG + "  Data Entrega : " +dToC(_DtEntre)
			@ nLin, 049 PSAY "TOTAL PEDIDO: "
			@ nLin, 079  PSAY Transform(_nTotCaixas ,"@Z 999999")           // Total Qtd UM2
			@ nLin, 104  PSAY Transform(_nTotKilos  ,"@Z 999999.99")        // Total Qtd UM1
			@ nLin, 118  PSAY Transform(_nTotValTot ,"@Z 999,999,999.99")   // Total Vlt Total
			nLin := nLin + 1
			@ nLin, 000 PSAY Repl("*",limite)  		
			
		ELSE 
					
			If mv_par12 == 2
				//@ nLin, 000 PSAY "Produto    Descricao do Produto                                          TES Qtde Cx 2UM  Valor Unit.  Qtde  Kg   UM   Valor Total"
			ELSE
				//@ nLin, 000 PSAY "Produto    Descricao do Produto                                          TES Qtde Cx 2UM  Valor Unit.  Qtde  Kg   UM       QTDE CX"
			ENDIF
			
			_nTotCaixas := 0
			_nTotKilos  := 0
			_nTotValTot := 0
			_produto    := space(06)
			_prodedata  := space(06)
			_c2Um       := space(02)
			dbSelectArea("SC6")
			dbSeek( xFilial("SC6") + XC5->C5_NUM )
			// Verifico se todos os itens foram faturados
			Do While !Eof() .and. SC6->C6_FILIAL == xFilial("SC6") .and.;
				SC6->C6_NUM    == XC5->C5_NUM
				If (SC6->C6_NOTA  <> ' ' .AND. mv_par11 == 1) .OR.( mv_par11 <> 1 ) .OR. (XC5->C5_TIPO $ 'DB')
					
						_Produto := left(SC6->C6_PRODUTO,10) //C6_PRODUTO

						// *** INICIO CHAMADO 053889 WILLIAM COSTA 05/12/2019
						// SqlProdEdata(_Produto)
						// DBSELECTAREA("TRC")   
						// TRC->(DBGOTOP())    
						// WHILE TRC->(!EOF())    
						
						// 	_Prodedata := TRC->PRODEDATA
						// 	_Descri    := TRC->DESCEDATA 
						// 	TRC->(DBSKIP())     	
						// ENDDO

						// IF TRC->(EOF())

						// 	_Descri    := SC6->C6_DESCRI

						// ENDIF

						// TRC->(DBCLOSEAREA())
						// *** FINAL CHAMADO 053889 WILLIAM COSTA 05/12/2019

						//Everson - 19/10/2021. Chamado 55129.
							aDados := {}
							oPrdEdt:Get(Alltrim(cValToChar(SC6->C6_PRODUTO)), aDados)

							If Len(aDados) > 0
								_Prodedata := aDados[1]
								_Descri    := aDados[2]
							
							Else
								_Descri    := SC6->C6_DESCRI
								
							EndIf
						//

						_tes     := SC6->C6_TES
						//_Descri  := SC6->C6_DESCRI //CHAMADO 053889 WILLIAM COSTA 05/12/2019
						_DtEntre := SC6->C6_ENTREG
						_c2Um    := SC6->C6_SEGUM 
					
					dbSelectArea("SC9") // Itens de pedido liberado
					dbSetOrder(01) // Indice ( pedido )
					If dbSeek( xFilial("SC9")+ XC5->C5_NUM)  
					
						// INICIO CHAMADO 033454 - WILLIAM COSTA
						While !SC9->(Eof()) .AND. SC9->(C9_FILIAL+C9_PEDIDO) == (xFilial("SC9")+ XC5->C5_NUM)
						
							// SOMA PESO BRUTO DAS NOTAS QUE SENSIBILIZAM O ESTOQUE
							If Empty(SC9->C9_BLEST ) .AND. Empty(SC9->C9_BLCRED)
								_lLib	:= .t.
							else
								_lLib := .f.
								EXIT
							Endif
							SC9->(dbSkip())
						ENDDO	
						// FINAL CHAMADO 033454 - WILLIAM COSTA
					Else
						_lLib := .f.
					Endif
					
					dbSelectArea("SC6")
					if _lLib .And. mv_par11 == 2//.or. mv_par12 == 2 .or. C6_QTDENT>0  &&Mauricio - 26/03/10 - Solicitado por Caio trazer apenas itens liberados no relatorio.
					    //PASSAR PARA UM PARAMETRO
						If  !(SUBSTR(C6_CF,2,3) $ ALLTRIM(GETMV("MV_NOSC6C1")))     
							                     
							//Incluido por roteiro
							dbSelectArea("TEMP")
							dbSetOrder(1)
							If !dbSeek(XC5->C5_ROTEIRO+_Produto)
								RecLock("TEMP",.T.)
							Else
								RecLock("TEMP",.F.)
							Endif                                              
							Replace TP_ROTEIRO   With XC5->C5_ROTEIRO
							Replace TP_REPROG    With XC5->C5_PRIOR    &&Mauricio -  04/08/17 - Chamado 036478					
							Replace TP_PRODUTO   With _Produto
							Replace TP_TES       With _tes
							Replace TP_DESCRI    With _DESCRI
							Replace TP_CAIXAS    With TP_CAIXAS + SC6->C6_UNSVEN
							Replace TP_KILOS     With TP_KILOS  + SC6->C6_QTDVEN
							Replace TP_TARA      With _c2Um
							Replace TP_VALTOT    With TP_VALTOT + SC6->C6_VALOR
							Replace TP_PLACA     With XC5->C5_PLACA					
							Replace TP_DTENTR    With SC6->C6_ENTREG
							Replace TP_XCATEG    With Posicione("SB1",1,xFilial("SB1")+_Produto,"B1_XCATEG")
							Replace TP_X5_DESC   With alltrim(posicione("SX5",1,xFilial("SC5")+"82"+Posicione("SB1",1,xFilial("SB1")+_Produto,"B1_XCATEG"),"X5_DESCRI"))
							Replace TP_PRODEDA   With _prodedata //'WiLL' 'WiLL' 
							MsUnlock() 					
							
							If mv_par12 == 2
								//@ nLin, 118  PSAY SC6->C6_VALOR   PICTURE "@Z 999,999,999.99"   // Vlt Total
								//nLin := nLin + 1
							else
								//@ nLin, 118  PSAY iif(SC6->C6_QTDENT>0,"__ FATURADO  __","_______________")
								//nLin := nLin + 2
								//fim alteracao hcconsys 23/10/08
							endif
						    _nTotCaixas := _nTotCaixas + SC6->C6_UNSVEN
							_nTotkilos  := _nTotKilos  + SC6->C6_QTDVEN
							_nTotValTot := _nTotValtot + SC6->C6_VALOR
						    	
						Endif
					   
					Elseif MV_PAR11 == 1
						If  !(SUBSTR(SC6->C6_CF,2,3) $ ALLTRIM(GETMV("MV_NOSC6C1")))
							//@ nLin, 073  PSAY SC6->C6_TES 
							//@ nLin, 078  PSAY SC6->C6_UNSVEN  PICTURE "@Z 999,999"
							//@ nLin, 087  PSAY SC6->C6_SEGUM
							//@ nLin, 091  PSAY SC6->C6_PRCVEN  PICTURE "@Z 999999.9999"      // VUnit UM2
							//@ nLin, 104  PSAY SC6->C6_QTDVEN  PICTURE "@Z 999999.99"        // Qtd UM1
							//@ nLin, 115  PSAY SC6->C6_UM
						   	If mv_par12 == 2
								//@ nLin, 118  PSAY SC6->C6_VALOR   PICTURE "@Z 999,999,999.99"   // Vlt Total
								//nLin := nLin + 1
							else
								//@ nLin, 118  PSAY iif(SC6->C6_QTDENT>0,"__ FATURADO  __","_______________")
								//nLin := nLin + 2
							endif
						    //	@ nLin, 118  PSAY iif(C6_QTDENT>0,"__ FATURADO  __","_______________")
							//nLin := nLin + 2
							_nTotCaixas := _nTotCaixas + SC6->C6_UNSVEN
							_nTotkilos  := _nTotKilos  + SC6->C6_QTDVEN
							_nTotValTot := _nTotValtot + SC6->C6_VALOR 
							
							dbSelectArea("TEMP")
							dbSetOrder(1)
							If !dbSeek(XC5->C5_ROTEIRO+_Produto)
								RecLock("TEMP",.T.)
							Else
								RecLock("TEMP",.F.)
							Endif  
							Replace TP_ROTEIRO   With XC5->C5_ROTEIRO
							Replace TP_REPROG    With XC5->C5_PRIOR    &&Mauricio -  04/08/17 - Chamado 036478					
							Replace TP_PRODUTO   With _Produto
							Replace TP_TES       With _tes
							Replace TP_DESCRI    With _DESCRI
							Replace TP_CAIXAS    With TP_CAIXAS + SC6->C6_UNSVEN
							Replace TP_KILOS     With TP_KILOS  + SC6->C6_QTDVEN
							Replace TP_TARA      With _c2Um
							Replace TP_VALTOT    With TP_VALTOT + SC6->C6_VALOR
							Replace TP_PLACA     With XC5->C5_PLACA					
							Replace TP_DTENTR    With SC6->C6_ENTREG					
							Replace TP_XCATEG    With Posicione("SB1",1,xFilial("SB1")+_Produto,"B1_XCATEG")
							Replace TP_X5_DESC   With alltrim(posicione("SX5",1,xFilial("SC5")+"82"+Posicione("SB1",1,xFilial("SB1")+_Produto,"B1_XCATEG"),"X5_DESCRI"))
							Replace TP_PRODEDA   With _prodedata //'WiLL' 'WiLL' 
							MsUnlock()					
							
						ELSE
						    //@ nLin, 073  PSAY SC6->C6_TES 	
							//@ nLin, 077  PSAY "------------    N A O   L I B E R A D O  POR   TES   ---"     //incluido por Adriana em 09/06/08
						    //nLin := nLin + 2
						Endif 
						 
					Else
						//@ nLin, 073  PSAY "--------------    N A O   L I B E R A D O    --------------"     //incluido por Adriana em 09/06/08
						//nLin := nLin + 2
					Endif
				Endif
								
				dbSelectArea("SC6")
				dbSkip()
				Loop
			Enddo
			
		ENDIF
		
		_nTTotKilos  := _nTTOTkILOS  + _nTotKILOS
		_nTTotCaixas := _nTTOTcAIXAS + _nTotCAIXAS
		
		_nTotCaixas := 0
		_nTotKilos  := 0
		_nTotValTot := 0
		
		dbSelectArea("XC5")
		dbSkip()  
		
	Enddo
	
	FResumoC(_cRotAnt)		
	
	nLin := nLin + 2         
	@ nLin, 001 PSAY Repl("#",limite)
	nLin := nLin + 1
	@ nLin, 049 PSAY "TOTAL GERAL  "
	@ nLin, 075  PSAY Transform(_ntTotCaixas ,"@Z 999999")           // Total Qtd UM2
	@ nLin, 085  PSAY Transform(_ntTotKilos  ,"@Z 999999.99")        // Total Qtd UM1
	nLin := nLin + 1
	@ nLin, 001 PSAY Repl("#",limite)

	//Everson - 03/07/2020. Chamado 059401.
	If MV_PAR16 == 1
		vlPlte()

	EndIf
	//
	
	SET DEVICE TO SCREEN
	
	If aReturn[5]==1
		SET PRINTER TO
		OurSpool(NomeRel)
	Endif
	
	MS_FLUSH()
	
	dbSelectArea("TEMP")
	TEMP->(dbclosearea()) 
	fErase(_cNomTRB+'.*')
	DBSELECTAREA("XC5")
	XC5->(dbclosearea())

Return

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                     ³
//³ LAYOUT                                                              ³
//³                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                

1         2         3         4         5         6         7         8         9        10        11        12        13
123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

------------------------------------------------------------------------------------------------------------------------------------
PEDIDO: 999999     ROTEIRO/SEQUENCIA: 999/99                             VENDEDOR: 999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
SUPERVISOR: 999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
CLIENTE: 999999/00 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
ENDERECO: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX         TELEFONE: XXXXXXXXXXXXXXX
CIDADE: XXXXXXXXXXXXXXX   BAIRRO: XXXXXXXXXXXXXXXXXXXX   ESTADO: XX   CEP: 99999-99
------------------------------------------------------------------------------------------------------------------------------------
Produto    Descricao do Produto                                            Qtde  UM       Valor         Qtde                 Valor
Cx        Unitario           Kg  UM             Total
------------------------------------------------------------------------------------------------------------------------------------
XXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999999  XX 999999.9999    999999.99  XX    999,999,999.99
XXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999999  XX 999999.9999    999999.99  XX    999,999,999.99
XXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999999  XX 999999.9999    999999.99  XX    999,999,999.99
------------------------------------------------------------------------------------------------------------------------------------
Condicao Pagamento: 999-XXXXXXXXXXXXXXX                 TOTAL PEDIDO:  999999                    999999.99  XX    999,999,999.99
------------------------------------------------------------------------------------------------------------------------------------

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                     ³
//³ LAYOUT RESUMO POR PRODUTO                                           ³
//³                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


------------------------------------------------------------------------------------------------------------------------------------
1         2         3         4         5         6         7         8         9         10        11        12        13
012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
------------------------------------------------------------------------------------------------------------------------------------
|INICIO:                   |
116   CORTES TP CG FRANGO (COXA E   SOBRECOXA) SV                    999999 999,999.99     999,999.99   |                          |
|TERMINO:                  |
117   CORTES TP CG FRANGO (ASAS) SV                                      40     720.00         732.00   |--------------------------|
|LACRES:                   |
209   RECORTES TP CG FRANGO (COXINHADA ASA) SV SACO                      15     270.00         274.50   |        |         |       |
|        |         |       |
210   RECORTES TP CG FRANGO (MEIO DAASA) SV SACO                         10     180.00         183.00   |--------------------------|
|        |         |       |
219   CORTES TP CG FRANGO (PEITO)   IND.15 KG                            30     450.00         459.00   |        |         |       |
|--------------------------|
53    FRANGO TEMP CG SV LV                                               30     540.00         549.60   |CONFERENTE:               |
|                          |
59    MIUDO CONG DE AVES  (MOELA)CP                                       5      90.00          91.50   |                          |
|--------------------------|

/*/                                

//IMPRESSAO DO RESUMO DE CARREGAMENTO
Static Function FResumoC(_cRoteiro)

	Local cTipoOld    := ''
	Local cTipo       := ''
	Local cShelife    := 'N'
 	Local cKeyCli 	  := ''	 //Chamado: 047975 - Fernando Sigoli 01/04/2019 
	Local cRecCli     := ''  //Chamado: 047975 - Fernando Sigoli 01/04/2019 
	Local nTotCx 	  := 0   //Chamado: 047975 - Fernando Sigoli 01/04/2019 
	Local nTotKG      := 0   //Chamado: 047975 - Fernando Sigoli 01/04/2019 
	Local i			  := 1
    
    _lEntrou := .F.         
    DBSELECTAREA("TEMP")                
    TEMP->(dbsetorder(2)) //*** INICIO ALTERACAO WILL PARA CRIAR INDICES CHAMADO 030812  *** //
    TEMP->(dbgotop())                       
    DBSEEK(_cRoteiro)
    cTipoOld := SUBSTR(TEMP->TP_X5_DESC,1,4)
	While TEMP->(!EOF()) .And. Alltrim(TEMP->TP_ROTEIRO) == _cRoteiro 
		
		If !_lEntrou
		
			_n2TTotCaixas := 0
			_n2TTotKilos  := 0
			_n2TTotPbr    := 0
			_n2TTotPGer   := 0
			_n2TTotVal	  := 0
			_n2Tara       := 0	                            		
			_nI           := 0
			_lEntrou      := .T.
		
			aAdd(_aLinha,{" |INICIO:                 |"}) 	//1
			aAdd(_aLinha,{" |                        |"})	//2
			aAdd(_aLinha,{" |TERMINO:                |"})	//3
			aAdd(_aLinha,{" |------------------------|"})	//4
			aAdd(_aLinha,{" |LACRES:                 |"})	//5
			aAdd(_aLinha,{" |        |         |     |"})	//6
			aAdd(_aLinha,{" |        |         |     |"})	//7
			aAdd(_aLinha,{" |------------------------|"})	//8
			aAdd(_aLinha,{" |        |         |     |"})	//9
			aAdd(_aLinha,{" |        |         |     |"})	//10
			aAdd(_aLinha,{" |------------------------|"})	//11
			aAdd(_aLinha,{" |CONFERENTE:             |"})	//12
			aAdd(_aLinha,{" |                        |"})	//13
			aAdd(_aLinha,{" |                        |"})	//14
			aAdd(_aLinha,{" |------------------------|"})	//15
		
			nLin := 1
		
			nlin := nLin + 2
			@ nLin,000 PSAY " ROTLOG"
			@ nLin,040 PSAY "R E S U M O   D E   C A R R E G A M E N T O "
			nlin := nLin + 1
			@ nLin, 000 PSAY Repl("-",limite)
			nLin := nLin + 1
			&&Mauricio - 04/08/17 - Chamado 036478 - 

			// Chamado n. 049495 || OS 050775 || ADM.LOG || MARCEL || 8365 || ROMANEIO ENTREGAS - FWNM - 02/08/2019
			cRotZFN   := Alltrim(TEMP->TP_ROTEIRO)
			UpRotAtend(cRotZFN, @nLin)
			//
			
	        IF Alltrim(TEMP->TP_REPROG) == "R"	   
	           //@ nLin,000 PSAY "ROTEIRO NUMERO " + TEMP->TP_ROTEIRO + SPACE(15)+ " DATA ENTREGA : " + DTOC(TEMP->TP_DTENTR) + SPACE(20)+ "       PLACA VEICULO : " + TEMP->TP_PLACA
	           @ nLin,000 PSAY "ROTEIRO NUMERO " + TEMP->TP_ROTEIRO + SPACE(05)+ "REPROGRAMADO"+SPACE(10)+ " DATA ENTREGA : " + DTOC(TEMP->TP_DTENTR) + SPACE(20)+ "       PLACA VEICULO : " + TEMP->TP_PLACA
	        Else
	           @ nLin,000 PSAY "ROTEIRO NUMERO " + TEMP->TP_ROTEIRO + SPACE(15)+ " DATA ENTREGA : " + DTOC(TEMP->TP_DTENTR) + SPACE(20)+ "       PLACA VEICULO : " + TEMP->TP_PLACA 
	        ENDIF
			
			cShelife := 'N'			
			nlin     := nLin + 1  
			                //0         1         2         3         4         5         6         7         8         9       100       110       120       130
	                        //0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
			@ nLin, 000 PSAY "Prod Edata Prod Protheus          Descricao                       TES TIPO QTD Caixa   Pes Liq  Pes Bruto " //"Produto    Descricao do Produto                                  TES Qtde        Peso       Peso "
			nLin := nLin + 1
			
			//
			@ nLin, 000 PSAY Repl("-",limite)
			nLin := nLin + 1
				
		Endif  
				
		nLin := nLin + 1				
		cTipo := SUBSTR(TEMP->TP_X5_DESC,1,4)
		IF cTipoOld <> cTipo
		    
		 	cTipoOld := cTipo
			@ nLin, 000 PSAY Repl("-",105)
			
		ENDIF	
		
		If MOD(_nI,2) != 0
			_nI += 1
			If _nI <= 15 
				@ nLin, 105 PSAY _aLinha[_nI][1]
			Endif
			nLin := nLin + 1
		Endif                                 
		
		@nLin,000 PSAY AllTrim(TEMP->TP_PRODEDA)
		@nLin,011 PSAY AllTrim(TEMP->TP_PRODUTO)
		@nLin,025 PSAY SUBSTR(TEMP->TP_DESCRI,1,40)
		@nLin,066 PSAY ALLTRIM(TEMP->TP_TES)
		@nLin,070 PSAY SUBSTR(TEMP->TP_X5_DESC,1,4)
		@nLin,075 PSAY TEMP->TP_CAIXAS PICTURE "@E 999999"
		@nLin,085 PSAY TEMP->TP_KILOS  PICTURE "@E 999999.99"
		
		dbSelectArea("SZC")
		dbSetOrder(1)
		If dbSeek(xFilial("SZC")+ TEMP->TP_TARA)
			_nTara := ZC_TARA
		Endif
					
		_nTTotPbr := ((TEMP->TP_CAIXAS * _nTara) + TEMP->TP_KILOS)
					
		@ nLin, 095 PSAY _nTTotPbr  PICTURE "999,999.99"
		_n2TTotCaixas 	+= TEMP->TP_CAIXAS
		_n2TTotKilos  	+= TEMP->TP_KILOS  
		
		dbSelectArea("SZC")
		dbSetOrder(1)
		If dbSeek(xFilial("SZC")+ TEMP->TP_TARA)
			_nTara := ZC_TARA
		Endif
					
		_n2TTotPbr := ((TEMP->TP_CAIXAS * _nTara) + TEMP->TP_KILOS)	
		
		_n2TTotPGer  	+= _n2TTotPbr
		_n2TTotVal		+= TEMP->TP_VALTOT
				
		//guardo os dados do roteiro
		_ROTEIRO := TEMP->TP_ROTEIRO
		_PLACA   := TEMP->TP_PLACA
		_DTENTR  := TEMP->TP_DTENTR
		
		_nI += 1
		If _nI <= 15 
			@ nLin, 105 PSAY _aLinha[_nI][1]
		Endif			
		
		dbSelectArea("TEMP")
		dbskip()
	Enddo	           
	
	If _lEntrou
		If _nI <= 15
			For i:=_nI to 15 
				@ nLin, 105 PSAY _aLinha[i][1]
				nLin += 1
			Next
		Endif
		
		nLin := nLin + 2
		@ nLin, 000 PSAY Repl("-",limite)
		nLin := nLin + 2   		
		@ nLin, 000 PSAY "TOTAL ROTEIRO "
		@ nLin, 075 PSAY _N2TTotCaixas   PICTURE "999999"
		@ nLin, 085 PSAY _N2TTotKilos    PICTURE "999,999.99"
		@ nLin, 095 PSAY _n2TTotPGer     PICTURE "999,999.99"
		@ nLin, 117 PSAY _n2TTotVal    	 PICTURE "999,999.99"
		nLin := nLin + 1
		@ nLin, 000 PSAY Repl("*",limite)
	Endif
	nLin := nLin + 1 
	nCtn := 1
	
	cShelife := Valshel(_ROTEIRO,_PLACA,DTOS(_DTENTR))
			
	If Select("QEXT") > 0
		QEXT->( dbCloseArea() )
	EndIf                      
	
	TcQuery cShelife New Alias "QEXT"
			
	DbSelectArea("QEXT")
	nTotReg := CONTAR("QEXT","!EOF()")
	DbGoTop()

		While QEXT->(!EOF())
		    
	    	cKeyCli := Alltrim(QEXT->CODIGO)+Alltrim(QEXT->LOJA)	
		    
		    If nCtn = 1
		    	@ nLin,000 PSAY "****S H E L F L I F E / P A L E T I Z A C A O **** " 
		    	nLin := nLin + 2
		    EndIf
		    
		    //Inicio Chamado: 047975 - Fernando Sigoli 01/04/2019
			If cKeyCli <> cRecCli
				
				If nCtn > 1
				
					@ nLin,000 PSAY "---------------------------------------------------------------------------------------" 
					nLin := nLin + 1
					@ nLin,040 PSAY " TOTAL    "+Transform(nTotCx ,"@Z 999999") +'          '+ Transform(nTotKG ,"@Z 999,999.99")    
					nLin := nLin + 1
					
					nTotCx := 0
					nTotKG := 0
				EndIf
				
				@ nLin,000 PSAY "CLIENTE/LOJA : " + Alltrim(QEXT->CODIGO)+'-'+Alltrim(QEXT->LOJA)+' '+Alltrim(QEXT->NOME)
				nLin := nLin + 1
				@ nLin,000 PSAY "SHELFLIFE : " +Alltrim(QEXT->SHELFLIFE) + ' **  PALETIZACAO : '+ IIF(!EMPTY(Alltrim(QEXT->PALETE)),Alltrim(QEXT->PALETE),'NAO INFOMADO')
				nLin := nLin + 1
				@ nLin,000 PSAY " Produto                                    |      CAIXAS        |     KG        | "
				nLin := nLin + 1                                                                                                                                                   
			
			EndIf
			 
			@ nLin, 000 PSAY SUBSTR(QEXT->PRODUTO,1,40)
			@ nLin, 050 PSAY QEXT->CAIXA  PICTURE "999999"
			@ nLin, 065 PSAY QEXT->KG     PICTURE "999,999.99"
			
			nCtn := nCtn + 1 
			nLin := nLin + 1 
			
			nTotCx := nTotCx + QEXT->CAIXA
			nTotKG := nTotKG + QEXT->KG 
			
			cRecCli := Alltrim(QEXT->CODIGO)+Alltrim(QEXT->LOJA)	
		    		    
		    If nLin > 60
				
				nLin := 1

				@ nLin,001 PSAY "ROTLOG"
				@ nLin,040 PSAY "R E S U M O   D E   C A R R E G A M E N T O "
				@ nLin,120 PSAY date()		

				// Chamado n. 049495 || OS 050775 || ADM.LOG || MARCEL || 8365 || ROMANEIO ENTREGAS - FWNM - 02/08/2019
				cRotZFN   := Alltrim(_ROTEIRO)
				UpRotAtend(cRotZFN, @nLin)
				//
	
				nLin := nLin + 2
		        //
				@ nLin,000 PSAY "CLIENTE/LOJA : " + Alltrim(QEXT->CODIGO)+'-'+Alltrim(QEXT->LOJA)+' '+Alltrim(QEXT->NOME)
				nLin := nLin + 1
				@ nLin,000 PSAY "SHELFLIFE : " +Alltrim(QEXT->SHELFLIFE) + ' **  PALETIZACAO : '+ IIF(!EMPTY(Alltrim(QEXT->PALETE)),Alltrim(QEXT->PALETE),'NAO INFOMADO')
				nLin := nLin + 1
				@ nLin,000 PSAY " Produto                                    |      CAIXAS        |     KG        | "
				nLin := nLin + 1                                                                                                                                                   
			
			Endif
	    
		    //Fim Chamado: 047975 - Fernando Sigoli 01/04/2019
		    	
		QEXT->(DBSKIP())
		ENDDO
			
		If nCtn > 1
			@ nLin,000 PSAY "---------------------------------------------------------------------------------------" 
			nLin := nLin + 1
			@ nLin,040 PSAY " TOTAL    "+Transform(nTotCx ,"@Z 999999") +'          '+ Transform(nTotKG ,"@Z 999,999.99")  
		EndIf
	
		//inicio Chamado: 047975 - Fernando Sigoli 02/05/2019
		cPalete := ValPalet(_ROTEIRO,_PLACA,DTOS(_DTENTR))
		nCtn 	:= 0
		
		If Select("QPLT") > 0
			QPLT->( dbCloseArea() )
		EndIf                      
	
		TcQuery cPalete New Alias "QPLT"
			
		DbSelectArea("QPLT")
		DbGoTop()
				 
		While QPLT->(!EOF())
	
			cKeyCli := Alltrim(QPLT->CODIGO)+Alltrim(QPLT->LOJA)	
		    
		    If nCtn = 0
		    	nLin := nLin + 1
		  		@ nLin,000 PSAY "****P A L E T E Z I C A O**** " 
		    	nLin := nLin + 2
		    EndIf
		    
		    //Inicio Chamado: 047975 - Fernando Sigoli 01/04/2019
			If cKeyCli <> cRecCli
				
				@ nLin,000 PSAY "CLIENTE/LOJA : " + Alltrim(QPLT->CODIGO)+'-'+Alltrim(QPLT->LOJA)+' '+Alltrim(QPLT->NOME)
				nLin := nLin + 1
				@ nLin,000 PSAY "PALETIZACAO : "+ IIF(!EMPTY(Alltrim(QPLT->PALETE)),Alltrim(QPLT->PALETE),'NAO INFOMADO')
			
			EndIf
			
			If nLin > 60
				
				nLin := 1
		
				@ nLin,001 PSAY "ROTLOG"
				@ nLin,040 PSAY "R E S U M O   D E   C A R R E G A M E N T O "
				@ nLin,120 PSAY date()		

				// Chamado n. 049495 || OS 050775 || ADM.LOG || MARCEL || 8365 || ROMANEIO ENTREGAS - FWNM - 02/08/2019
				cRotZFN   := Alltrim(_ROTEIRO)
				UpRotAtend(cRotZFN, @nLin)
				//
				nLin := nLin + 2
				@ nLin,000 PSAY "CLIENTE/LOJA : " + Alltrim(QPLT->CODIGO)+'-'+Alltrim(QPLT->LOJA)+' '+Alltrim(QPLT->NOME)
				nLin := nLin + 1
				@ nLin,000 PSAY "PALETIZACAO : "+ IIF(!EMPTY(Alltrim(QPLT->PALETE)),Alltrim(QPLT->PALETE),'NAO INFOMADO')
				nLin := nLin + 1                                                                                                                                                   
			
			Endif 
			
			nCtn := nCtn + 1 
			nLin := nLin + 1 
			
			cRecCli := Alltrim(QPLT->CODIGO)+Alltrim(QPLT->LOJA)	
		    
		QPLT->(DBSKIP())
		ENDDO
    	
    	QPLT->(DBCLOSEAREA())
	
	//Fim Chamado: 047975 - Fernando Sigoli 02/05/2019	
	
	QEXT->(DBCLOSEAREA())
					
Return
/*/{Protheus.doc} getPrdEdt
	Função retorna produtos Edata.
	@type  Static Function
	@author Everson
	@since 19/10/2021
	@version 01
/*/
Static Function getPrdEdt()

	//Variáveis.
	Local oHash := THashMap():New()

	//
	If Select("TRC") > 0
		TRC->(DbCloseArea())

	EndIf

	//
	SqlProdEdata()

	//
	DbSelectArea("TRC")
	TRC->(DbGoTop())
	While ! TRC->(Eof())

		oHash:Set(Alltrim(cValToChar(TRC->COD_PROT)), { TRC->PRODEDATA, TRC->DESCEDATA})

		TRC->(DbSkip())
	End
	TRC->(DbCloseArea())

Return oHash

STATIC FUNCTION SqlProdEdata(cProduto)

	Local cQueryEdata := ''
	//Local cProd       := ''
		
	cQueryEdata := " SELECT RTRIM(LTRIM(CAST(PROD_EDATA.IE_DEFIMATEEMBA AS VARCHAR))) AS COD_PROT, "
	cQueryEdata += " PROD_EDATA.ID_PRODDEFIMATEEMBA AS PRODEDATA,NM_PRODDEFIMATEEMBA AS DESCEDATA "
    cQueryEdata += " FROM [LNKMIMS].[SMART].[dbo].[MATERIAL_EMBALAGEM_DEFINICAO] PROD_EDATA "

	//Everson - 19/10/2021. Chamado 55129.
	If ! Empty(Alltrim(cValToChar(cProduto)))
    	cQueryEdata += " WHERE (PROD_EDATA.IE_DEFIMATEEMBA COLLATE Latin1_General_CI_AS)  = '" + cProduto + "'"

	EndIf
	//
    
	TCQUERY cQueryEdata new alias "TRC"
	
RETURN(NIL)

//verifica se existe algum cliente do roteiro que exige controle de Shelflife
//Chamado: 047975 - Fernando Sigoli 18/03/2019 
Static Function Valshel(cRoteiro,cPlaca,dDtaEnt) 

	Local cQuery  := " "    
	
	cQuery := " SELECT "  
	cQuery += " FONTES.CODIGO, "
	cQuery += " FONTES.LOJA, " 
	cQuery += " FONTES.NOME, "
	cQuery += " FONTES.PALETE, " 
	cQuery += " SUBSTRING(FONTES.SHELFLIFE,4,90) AS SHELFLIFE, "
	cQuery += " FONTES.PRODUTO, " 
	cQuery += " SUM(FONTES.CAIXA) AS CAIXA, "
	cQuery += " SUM(FONTES.KG) AS KG "
	cQuery += " FROM " 
	cQuery += " (SELECT SA1.A1_COD AS CODIGO, SA1.A1_LOJA AS LOJA, SA1.A1_NOME AS NOME, "
	cQuery += " CASE  "
	cQuery += " WHEN SA1.A1_XPALETE = '1' THEN 'PADRAO' "
	cQuery += " WHEN SA1.A1_XPALETE = '2' THEN 'REMONTADO' "
	cQuery += " WHEN SA1.A1_XPALETE = '3' THEN 'REMONTADO/MISTO' "
	cQuery += " ELSE 'NAO INFORMADO' "
	cQuery += " END AS PALETE ,SA1.A1_XSFLFDS  AS SHELFLIFE, "
	cQuery += " LTRIM(RTRIM(C6_PRODUTO))+' - '+LTRIM(RTRIM(C6_DESCRI)) AS PRODUTO,C6_UNSVEN AS CAIXA, C6_QTDVEN AS KG, B1_XCATEG " 
	cQuery += " FROM " +RetSqlName("SC5")+ " SC5 INNER JOIN " +RetSqlName("SA1")+ "  SA1 " 
	cQuery += " ON SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJAENT = SA1.A1_LOJA " 
	cQuery += " INNER JOIN " +RetSqlName("SC6")+ "  SC6 ON SC5.C5_FILIAL = SC6.C6_FILIAL AND SC5.C5_NUM = SC6.C6_NUM AND SC5.C5_CLIENTE = SC6.C6_CLI AND SC5.C5_LOJAENT = SC6.C6_LOJA  " 
	cQuery += " INNER JOIN " +RetSqlName("SB1")+ "  SB1 ON SB1.B1_COD = SC6.C6_PRODUTO " 
	cQuery += " WHERE  C5_FILIAL = '"+XFILIAL("SC5")+"'  AND C5_ROTEIRO = '"+cRoteiro+"' AND C5_DTENTR =  '"+dDtaEnt+"' AND  C5_PLACA = '"+cPlaca+"' AND  SC5.D_E_L_E_T_  = ''  AND SA1.D_E_L_E_T_ = ''  AND SC6.D_E_L_E_T_  = '' AND SB1.D_E_L_E_T_  = '' "  
	cQuery += " AND B1_XCATEG = '52' AND SA1.A1_XSFLFDS <> '' "
	cQuery += " ) AS FONTES  "
	cQuery += " GROUP BY  "
	cQuery += " FONTES.CODIGO, " 
	cQuery += " FONTES.LOJA,  "
	cQuery += " FONTES.NOME,  "
	cQuery += " FONTES.PALETE,  "
	cQuery += " FONTES.SHELFLIFE,  "
	cQuery += " FONTES.PRODUTO  " 
	cQuery += " ORDER BY FONTES.CODIGO+FONTES.LOJA "
		
Return cQuery

//verfica se temos controle de palete
//Chamado: 047975 - Fernando Sigoli 02/05/2019	

Static Function ValPalet(cRoteiro,cPlaca,dDtaEnt) 

Local cQry  := " "    

cQry := " SELECT SA1.A1_COD AS CODIGO, SA1.A1_LOJA AS LOJA, SA1.A1_NOME AS NOME, "
cQry += " CASE " 
cQry += " WHEN SA1.A1_XPALETE = '1' THEN 'PADRAO'  "
cQry += " WHEN SA1.A1_XPALETE = '2' THEN 'REMONTADO'  "
cQry += " WHEN SA1.A1_XPALETE = '3' THEN 'REMONTADO/MISTO' "
cQry += " ELSE 'NAO INFORMADO'  "
cQry += " END AS PALETE  "
cQry += " FROM " +RetSqlName("SC5")+ " SC5  INNER JOIN " +RetSqlName("SA1")+ " SA1  "
cQry += " ON SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJAENT = SA1.A1_LOJA  "
cQry += " WHERE   "
cQry += " C5_FILIAL = '"+XFILIAL("SC5")+"' "  
cQry += " AND C5_ROTEIRO = '"+cRoteiro+"' "
cQry += " AND C5_DTENTR =  '"+dDtaEnt+"' AND  C5_PLACA = '"+cPlaca+"'  "
cQry += " AND  SC5.D_E_L_E_T_  = ''  " 
cQry += " AND SA1.D_E_L_E_T_ = ''  " 
cQry += " AND SA1.A1_XPALETE <> '' AND SA1.A1_XSFLFDS = ''   "
 
Return cQry

/*/{Protheus.doc} Static Function UpRotAtend
	ROMANEIO ENTREGAS 
	@type  Function
	@author Fernando Macieira
	@since 08/02/2019
	@version version
/*/		

Static Function UpRotAtend(cRoteiro, nLin)
       
	Local aAreaAtu := GetArea() 
	
	// Chamado n. 049495 || OS 050775 || ADM.LOG || MARCEL || 8365 || ROMANEIO ENTREGAS - Incluir novo pergunte MV_PAR15 - FWNM - 12/08/2019
	Local lImp     := .T. 
	
	If MV_PAR15 == 2 // 1 = SIM, 2 = NAO
		lImp     := .F. 
	EndIf
	//
	
	If lImp
	
		nLin ++	
		@ nLin,000 PSAY Replicate("-",limite)
		nLin ++	
		@ nLin,000 PSAY 'CONTATOS ATENDENTES RESPONSAVEIS'
		nLin ++	
		@ nLin,000 PSAY Replicate("-",limite)
	
		ZFN->( dbSetOrder(1) ) // ZFN_FILIAL+ZFN_ROTEIR+ZFN_CODIGO                                                                                                                                
		If ZFN->( dbSeek( FWxFilial("ZFN")+cRoteiro ) )
		
			ZFM->( dbSetOrder(1) ) // ZFM_FILIAL+ZFM_CODIGO+ZFM_NOME                                                                                                                                  
			If ZFM->( dbSeek( FWxFilial("ZFM")+ZFN->ZFN_CODIGO ) )
				
				nLin ++	
				@ nLin,000 PSAY "Nome: " + AllTrim(ZFM->ZFM_NOME)
				nLin ++	
	//			@ nLin,000 PSAY "Celular/Fixo: " + AllTrim(ZFM->ZFM_NUMCEL) + " / " + AllTrim(ZFM->ZFM_NUMFIX) 
				@ nLin,000 PSAY "Celular/Fixo: " + AllTrim(ZFM->ZFM_NUMCEL) + " / " + AllTrim(ZFM->ZFM_NUMFIX) + " / " + AllTrim(ZFM->ZFM_NUMCE2) // Chamado n. 049495 || OS 050775 || ADM.LOG || MARCEL || 8365 || Incluir novo campo ZFM_NUMCE2 - FWNM - 08/08/2019
				nLin ++	
				@ nLin,000 PSAY "Almoco: " + AllTrim(ZFM->ZFM_HORALM)
				nLin ++	
				@ nLin,000 PSAY "Durante almoco contatar: " + AllTrim(ZFM->ZFM_OBSALM)
				nLin ++	
				@ nLin,000 PSAY Replicate("-",limite)
				nLin ++	
			
			Else
				
				nLin ++	
				@ nLin,000 PSAY "Nome: " 
				nLin ++	
				@ nLin,000 PSAY "Celular/Fixo: "
				nLin ++	
				@ nLin,000 PSAY "Almoco: "
				nLin ++	
				@ nLin,000 PSAY "Durante almoco contatar: "
				nLin ++	
				@ nLin,000 PSAY Replicate("-",limite)
				nLin ++	
			
			EndIf
		
		EndIf
		
	EndIf
		
	RestArea( aAreaAtu )

Return 
/*/{Protheus.doc} sqlPlt
	(long_description)
	@type  Static Function
	@author Everson
	@since 03/07/2020
	@version 01
	/*/
Static Function vlPlte()

	//Variáveis.
	Local cQuery := sqlVlPlt()

	//
	MsAguarde({|| StaticCall(ADROMENT,vlPalete,"","","","","","",cQuery) },"Função vlPlte(ROTLOG)","Gerando vale palete...")

Return cQuery
/*/{Protheus.doc} sqlVlPlt
	Script sql para geração do vale palete.
	@type  Static Function
	@author Everson
	@since 03/07/2020
	@version 01
	/*/
Static Function sqlVlPlt()

	//Variáveis.
	Local cQrybs := sqlRel()
	Local cQuery := ""

	//
	cQuery += " SELECT  " 
	cQuery += " EDATA.NUMERO_CARGA,  " 
	cQuery += " EDATA.DATA_FECHA_CARGA,  " 
	cQuery += " EDATA.TRANSPORTADOR,  " 
	cQuery += " EDATA.MOTORISTA, " 
	cQuery += " EDATA.VEICULO, " 
	cQuery += " EDATA.CLIENTE,  " 
	cQuery += " EDATA.EMBALAGEM, " 
	cQuery += " SUM(EDATA.QUANTIDADE) AS QUANTIDADE " 
	cQuery += " FROM [LNKMIMS].[SMART].[dbo].ADORO_VW_VALEPALETE AS EDATA " 
	cQuery += " WHERE " 
	cQuery += " EDATA.NUMERO_CARGA IN ( " 

	cQuery += " SELECT DISTINCT C5_X_SQED*1 FROM "
	cQuery += " ( "
	cQuery += cQrybs
	cQuery += " ) AS FONTE "

	cQuery += " ) " 
	cQuery += " GROUP BY " 
	cQuery += " EDATA.NUMERO_CARGA,  " 
	cQuery += " EDATA.DATA_FECHA_CARGA,  " 
	cQuery += " EDATA.TRANSPORTADOR,  " 
	cQuery += " EDATA.MOTORISTA, " 
	cQuery += " EDATA.VEICULO, " 
	cQuery += " EDATA.CLIENTE,  " 
	cQuery += " EDATA.EMBALAGEM " 

Return cQuery
/*/{Protheus.doc} sqlRel
	**** Isolado script sql para reaproveitamento. ***
	@type  Static Function
	@author Everson
	@since 03/07/2020
	@version 01
	/*/
Static Function sqlRel()

	//Variáveis.
	Local cQuery := ""
	
	//
	If MV_PAR11 == 1

		//
		cQuery	:=	"SELECT SC5.C5_FILIAL , SC5.C5_NUM , SC5.C5_TIPO, SC5.C5_CLIENTE , SC5.C5_LOJAENT , SC5.C5_DTENTR, "+;
		" SC5.C5_VEND1 , SC5.C5_NOTA , SC5.C5_ROTEIRO , SC5.C5_SEQUENC , SC5.C5_CONDPAG, SC5.C5_PRIOR, "+;
		" SC5.C5_PLACA, SA3.A3_CODSUP, SC5.C5_XHRENTR, "+;
		" SC5.C5_HRINIM, SC5.C5_HRFINM, SC5.C5_HRINIT, SC5.C5_HRFINT, SC5.C5_X_SQED "+; //Everson - 09/11/2017. Chamado 037879. //Everson - 03/07/2020. Chamado 059401.
		" FROM " + retsqlname("SC5")+" SC5, "+retsqlname("SA3")+ " SA3 " + ;
		" WHERE SC5.C5_VEND1 = SA3.A3_COD "+;
		" AND SC5.C5_NUM BETWEEN '"+MV_PAR01+"' AND '" + MV_PAR02 +"' " +;
		" AND SC5.C5_DTENTR BETWEEN '"+ dtos(mv_par05)+"' AND '" + dtos(mv_par06) +"' " +;
		" AND SC5.C5_VEND1  BETWEEN '"+ mv_par09+"' AND '" + mv_par10 +"' " +;
		iif(!empty(_cSupVends),"AND SC5.C5_VEND1  IN ("+ _cSupVends +") " ,"")+;
		" AND SA3.A3_CODSUP BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'"+;
		" AND SC5.C5_ROTEIRO BETWEEN '"+ MV_PAR03 + "' AND '" + MV_PAR04 +"' "+;
		" AND SC5.D_E_L_E_T_ <> '*' AND SA3.D_E_L_E_T_ <> '*' "+;
		" AND SC5.C5_VEND1 <> '' "+;
		" AND SC5.C5_FILIAL = '"+XFILIAL("SC5")+"'"+;
		" AND SC5.C5_PLACA <> '' "+; //William Costa - 25/11/2019 - Chamado 053588
		" UNION "+;
		" SELECT C5_FILIAL , C5_NUM , C5_TIPO, C5_CLIENTE , C5_LOJAENT , C5_DTENTR, "+;
		" C5_VEND1 , C5_NOTA , C5_ROTEIRO , C5_SEQUENC , C5_CONDPAG, C5_PRIOR, "+;
		" C5_PLACA, '', C5_XHRENTR, "+;
		" C5_HRINIM, C5_HRFINM, C5_HRINIT, C5_HRFINT, C5_X_SQED "+; //Everson - 09/11/2017. Chamado 037879.//Everson - 03/07/2020. Chamado 059401.
		" FROM " + retsqlname("SC5")+;
		" WHERE C5_NUM BETWEEN '"+MV_PAR01+"' AND '" + MV_PAR02 +"' " +;
		" AND C5_DTENTR BETWEEN '"+ dtos(mv_par05)+"' AND '" + dtos(mv_par06) +"' " +;
		" AND C5_VEND1  BETWEEN '"+ mv_par09+"' AND '" + mv_par10 +"' " +;
		iif(!empty(_cSupVends),"AND C5_VEND1  IN ("+ _cSupVends +") " ,"")+;
		" AND C5_ROTEIRO BETWEEN '"+ MV_PAR03 + "' AND '" + MV_PAR04 +"' "+;
		" AND D_E_L_E_T_ <> '*' "+;
		" AND C5_VEND1 = '' "+;
		" AND C5_TIPO <> 'N' "+;
		" AND C5_FILIAL = '"+XFILIAL("SC5")+"'"+;
		" AND C5_PLACA <> '' " //William Costa - 25/11/2019 - Chamado 053588
	
	Else

		//
		cQuery	:= " SELECT SC5.C5_FILIAL , SC5.C5_NUM , SC5.C5_TIPO, SC5.C5_CLIENTE , SC5.C5_LOJAENT , SC5.C5_DTENTR, "+;
		" SC5.C5_VEND1  , SC5.C5_NOTA , SC5.C5_ROTEIRO , SC5.C5_SEQUENC , SC5.C5_CONDPAG,SC5.C5_PRIOR, "+;
		" SC5.C5_PLACA, SA3.A3_CODSUP, SC5.C5_XHRENTR, "+;
		" SC5.C5_HRINIM, SC5.C5_HRFINM, SC5.C5_HRINIT, SC5.C5_HRFINT, SC5.C5_X_SQED "+; //Everson - 09/11/2017. Chamado 037879. //Everson - 03/07/2020. Chamado 059401.
		" FROM " + retsqlname("SC5")+" SC5, "+retsqlname("SA3")+ " SA3 " + ;
		" WHERE SC5.C5_VEND1 = SA3.A3_COD "+;
		" AND SC5.C5_NUM BETWEEN '"+MV_PAR01+"' AND '" + MV_PAR02 +"' " +;
		" AND SC5.C5_DTENTR BETWEEN '"+ dtos(mv_par05)+"' AND '" + dtos(mv_par06) +"' " +;
		" AND SC5.C5_VEND1  BETWEEN '"+ mv_par09+"' AND '" + mv_par10 +"' " +;
		iif(!empty(_cSupVends),"AND SC5.C5_VEND1  IN ("+ _cSupVends +") " ,"")+;
		" AND SA3.A3_CODSUP BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "+;
		" AND SC5.C5_ROTEIRO BETWEEN '"+ MV_PAR03 + "' AND '" + MV_PAR04 +"' "+;
		" AND SC5.D_E_L_E_T_ <> '*' AND SA3.D_E_L_E_T_ <> '*' "+;
		" AND SC5.C5_VEND1 <> '' " +;
		" AND SC5.C5_FILIAL = '"+XFILIAL("SC5")+"'"+;
		" AND SC5.C5_PLACA <> '' "+; //William Costa - 25/11/2019 - Chamado 053588
		" UNION "+;
		" SELECT C5_FILIAL , C5_NUM , C5_TIPO, C5_CLIENTE , C5_LOJAENT , C5_DTENTR, "+;
		" C5_VEND1 , C5_NOTA , C5_ROTEIRO , C5_SEQUENC , C5_CONDPAG, C5_PRIOR,"+;
		" C5_PLACA, '', C5_XHRENTR, "+;
		" C5_HRINIM, C5_HRFINM, C5_HRINIT, C5_HRFINT, C5_X_SQED "+; //Everson - 09/11/2017. Chamado 037879. //Everson - 03/07/2020. Chamado 059401.
		" FROM " + retsqlname("SC5")+;
		" WHERE C5_NUM BETWEEN '"+MV_PAR01+"' AND '" + MV_PAR02 +"' " +;
		" AND C5_DTENTR BETWEEN '"+ dtos(mv_par05)+"' AND '" + dtos(mv_par06) +"' " +;
		" AND C5_VEND1  BETWEEN '"+ mv_par09+"' AND '" + mv_par10 +"' " +;
		iif(!empty(_cSupVends),"AND C5_VEND1  IN ("+ _cSupVends +") " ,"")+;
		" AND C5_ROTEIRO BETWEEN '"+ MV_PAR03 + "' AND '" + MV_PAR04 +"' "+;
		" AND "+RetSqlName("SC5")+ ".D_E_L_E_T_ <> '*' "+;
		" AND C5_VEND1 = '' "+;
		" AND C5_TIPO <> 'N' " +;
		" AND C5_FILIAL = '"+XFILIAL("SC5")+"'"+;
		" AND C5_PLACA <> '' " //William Costa - 25/11/2019 - Chamado 053588
		
	Endif

Return cQuery
