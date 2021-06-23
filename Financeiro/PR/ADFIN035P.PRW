#include "AFIN410.CH"
#Include "PROTHEUS.CH"

Static lFWCodFil := FindFunction("FWCodFil")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡…o    ?ADFIN035P  ?Autor ?Mauricio - MDS TEC    ?Data ?23.06.17 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ?Refaz acumulados de Clientes/Fornecedores                    ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Sintaxe   ?Desenvolvido em cima do FINA410 padrão                       ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Parametros?                                                             ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?FINANCEIRO ADORO - CHAMADO 035830                            ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
User Function ADFIN035P(_cCliAn)

	&&Mauricio - Chamado 035830 - Rotina desenvolvida para ser chamada por cliente pelas rotinas de analise de credito
	&&ADFIN006P, ADFIN018P, ADFIN024P e ADFIN023P. ?uma customização da rotina padrão FINA410.

	Local nOpca     := 0
	Local lPanelFin := If (FindFunction("IsPanelFin"),IsPanelFin(),.F.)
	LOCAL aSays:={}, aButtons:={}
	Local nTempoIni:= 0
	Local TempoFim	:=0
	Local cTempo:=""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Refaz acumulados de Clientes/Fornecedores')

	Processa({|lEnd| fa410Processa(_cCliAn)})  // Chamada da funcao de recalculos

Return()

Static Function Fa410Processa(_cCliAn)

// Variaveis utilizadas na chamada da stored procedure - TOP

Local nValForte := 0,nSaldoTit:=0
Local nMoeda  	:= Int(Val(GetMv("MV_MCUSTO")))
Local nMoedaF 	:= 0
Local cFilBusca := "  "
Local nTaxaM	:=0
Local lRet      := .T.
Local aBaixas
Local nMCusto	:=Val(GetMV("MV_MCUSTO"))
Local lE1MsFil := SE1->(FieldPos("E1_MSFIL") > 0)	
Local cFilSF2  := xFilial("SF2")

Local nMaiorVDA		:= 0
Local nMaiorVDAaux	:= 0
Local nMSaldo		:= 0 
Local cCliente   	:= " "
Local cNumPedVen 	:= ""
Local cCliPad  		:= SuperGetMv("MV_CLIPAD",,"")		// Cliente Padrao
Local cLojaPad  	:= SuperGetMv("MV_LOJAPAD",,"")		// Loja Padrao                                                                 
Local lGestao		:= Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Local lFilExc		:= .T.
Local lRastro		:= If(FindFunction("FVerRstFin"),FVerRstFin(),.F.)
Local lFilSA1C   	:= FWModeAccess("SA1",3) == "C"
Local lFilSA2C   	:= FWModeAccess("SA2",3) == "C"
Local lFilSE5C		:= FWModeAccess("SE5",3) == "C"
Local nRiscod		:= GetMV("MV_RISCOD")
  
#IFDEF TOP
	Local cProcNam := IIF(FindFunction("GetSPName"), GetSPName("FIN003","09"), "FIN003")
	Local cFilOld := cFilAnt
	Local cCliDe, cCliAte, cForDe, cForAte
	Local cCRNEG  := "/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM+"/"+MVIRABT+"/"+MVFUABT+"/"+MVINABT+"/"+MVISABT+"/"+MVPIABT+"/"+MVCFABT
	Local cCRNEG1 := "/"+MVRECANT+"/"+MV_CRNEG
	Local cCPNEG  := "/"+MVPAGANT+"/"+MV_CPNEG+"/"+MVABATIM
	Local cTipoLC := "/"+MVPROVIS
	Local cArrayAux :=''
	Local iTamArray := 0, iTamFil := IIf( lFWCodFil, FWGETTAMFILIAL, 2 )
	Local iArray    := 0
	Local iX        := 0
	Private cArrayFil1 :=''
	Private cArrayFil2 :=''
	Private cArrayFil3 :=''
	Private cArrayFil4 :=''
	Private cArrayFil5 :=''	
	Private cArrayFil6 :=''
	Private cArrayFil7 :=''	
	Private cArrayFil8 :=''
	Private cArrayFil9 :=''
#ENDIF


// Fim das variaveis utilizadas na chamada da stored procedure

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Verifica parametros informados                               ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

#IFDEF TOP

If ExistProc( cProcNam, VerIDProc()) .and. ( TcSrvType() <> "AS/400" )
	cCRNEG     := Iif(Empty(cCRNEG),  ' ', cCRNEG)
	cCRNEG1    := Iif(Empty(cCRNEG1), ' ', cCRNEG1)
	cCPNEG     := Iif(Empty(cCPNEG),  ' ', cCPNEG)
	cTipoLC   := cTipoLC+"/"+GetSESTipos({ || ES_SALDUP == "2"},"1")
	cTipoLC   := Iif(Empty(cTipoLC)," ", cTipoLC)
	cCliDe    := Iif(Empty(_cCliAn), ' ', Rtrim(_cCliAn))
	cCliAte   := Rtrim(_cCliAn)
	cForDe    := ' '
	cForAte   := Rtrim('ZZZZZZ')
	
	cArrayFil := ""
	dbSelectArea("SM0")
	DbSeek(cEmpAnt)
	While !Eof() .and. cEmpAnt = SM0->M0_CODIGO
		cArrayFil += Iif( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
		DbSkip()
	EndDo
	cArrayFil1 := cArrayFil
	If lFWCodFil
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//?			         	  Fil 01  Fil 02   Fil 03                         ?
		//?			         	 ÚÄÄÄÄÄ? ÚÄÄÄÄÄ? ÚÄÄÄÄÄ?                       ?
		//?			         	 X  X  X  Y  Y  Y  Z  Z  Z                        ?
		//³Posicao filiais na       236 ?238 ?240 ?242 ?                          ?
		//³na String                  237   239  * 241   243                          ?
		//?--------------------------------------------------------------------------?
		//³O Tam maximo a ser enviado em cada cArrayFilXX e 240, porem uma filial nao ?
		//³nao podera estar com um pedaco em cada array                               ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		cArrayFil1 := ''
		iArray := 1
		iX := 1
		cArrayAux := cArrayFil
		While iX <= Len(cArrayAux) 
			&('cArrayFil'+Str(iArray,1)) += Substr(cArrayAux, iX, iTamFil)
			If (Len(&('cArrayFil'+Str(iArray,1)))+iTamFil ) > 240 // Tamanho maximo da variavel aceita na procedure
				iArray := iArray + 1 // Muda variavel cArrayFilX
				iX := iX + iTamFil // Proxima filial
				Loop
			EndIf
			iX := iX + iTamFil // Proxima filial
		EndDo
	EndIf
    aResult := TCSPExec( xProcedures(cProcNam), ;
                        StrZero(2,1), StrZero(2,1),;
                        GetMv("MV_MCUSTO"),  dtos(dDatabase),;
                        cCRNEG,              cCRNEG1,;
                        cCPNEG,              cTipoLC,;
                        cCliDe,              cCliAte,;
                        cForDe,              cForAte,;
                        If(empty(cArrayFil1), ' ', cArrayFil1), If(Empty(cArrayFil2), ' ', cArrayFil2),;
                        If(Empty(cArrayFil3), ' ', cArrayFil3), If(Empty(cArrayFil4), ' ', cArrayFil4),;
                        If(Empty(cArrayFil5), ' ', cArrayFil5), If(Empty(cArrayFil6), ' ', cArrayFil6),;                        
                        If(Empty(cArrayFil7), ' ', cArrayFil7), If(Empty(cArrayFil8), ' ', cArrayFil8),;                        
                        If(Empty(cArrayFil9), ' ', cArrayFil9), iTamFil,;
                        nModulo, Rtrim(cCliPad), Rtrim(cLojaPad) ) 
    /*                    
	If Empty(aResult)
		MsgAlert(OemToAnsi(STR0008))  //"Erro na chamada do processo"
	Elseif aResult[1] == "01" .or. aResult[1] == "1"
	   MsgAlert(OemToAnsi(STR0009))  //"Atualizacao OK"
	Else
	  MsgAlert(OemToAnsi(STR0010))  //"Atualizacao com Erro"
	Endif
	*/
	cFilAnt := cFilOld
Else
#ENDIF
    &&somente clientes(mv_par01)
	//ProcRegua(SA1->(RecCount())+SE1->(RecCount()))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Cadastro de Clientes                                                      ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//If mv_par01 != 3
		DbSelectArea("SA1")
		dbSetOrder(1)		
		MsSeek(xFilial("SA1")+_cCliAn,.T.)		
		
		While !Eof() .And. (SA1->A1_COD >= _cCliAn .And. SA1->A1_COD <= _cCliAn)		
			If SA1->A1_COD >= _cCliAn .And. SA1->A1_COD <= _cCliAn
		     	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			   //³Ponto de entrada para filtro dos registros                      ?
		    	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		       	
			   If ExistBlock("FIN410FT")
					lRet := ExecBlock("FIN410FT",.F.,.F.,{2,"1"})
			      If !lRet 
		     	      dbSkip()
						Loop
		     	   EndIf	
			   Endif				
				Reclock( "SA1" )
				SA1->A1_SALDUP := 0
				SA1->A1_SALDUPM:= 0
				SA1->A1_SALFIN := 0
				SA1->A1_SALFINM:= 0
		  		SA1->A1_VACUM  := 0				
				MsUnlock()
			Endif
			dbSkip()
		Enddo
	//EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Titulos a Receber - Atualiza saldos clientes                              ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//If mv_par01 != 3
		dbSelectArea( "SE1" )
		dbSetOrder(2)	                       		
		MsSeek(xFilial("SE1")+_cCliAn,.T.)
						
		nMaiorVDA := 0
		
		While !Eof() .And. (SE1->E1_CLIENTE >= _cCliAn .And. SE1->E1_CLIENTE <= _cCliAn)
			
			If SE1->E1_CLIENTE >= _cCliAn .And. SE1->E1_CLIENTE <= _cCliAn
				
		     	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de entrada para filtro dos registros                      ?
		    	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		    	
				If ExistBlock("FIN410FT")
					lRet := ExecBlock("FIN410FT",.F.,.F.,{2,"3"})
					If !lRet 
						dbSkip()
						Loop
					EndIf	
				Endif				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
				//?Atualiza Saldo do Cliente                                             ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
				dbSelectArea( "SA1" )
				
				If lGestao
					lFilExc := ( !Empty( FWFilial("SA1") ) .and. !Empty( FWFilial("SE1") ) )
				Else	
					lFilExc := !Empty( xFilial( "SA1" ) ) .and. !Empty( xFilial( "SE1" ) )
				EndIf

				If lFilExc
					cFilBusca := SE1->E1_FILIAL		// Ambos exclusivos, neste caso
																// a filial serah 1 para 1
				Else
					cFilBusca := xFilial("SA1",SE1->E1_FILORIG)		// filial do cliente (SA1)
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Monta a chave de busca para o SA1    ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 				
				cChaveSe1 := cFilBusca + SE1->E1_CLIENTE+ SE1->E1_LOJA
							
				dbSelectArea( "SA1" )
				If (dbSeek( cChaveSe1 ) )
					If !(SA1->(A1_FILIAL+A1_COD+A1_LOJA) ==  cCliente)
						cCliente     := SA1->(A1_FILIAL+A1_COD+A1_LOJA)
						nMaiorVDA    := 0
						nMaiorVDAaux := 0
						nMSaldo      := 0
					EndIf
  					nMoedaF		:= If(SA1->A1_MOEDALC > 0,SA1->A1_MOEDALC,nMoeda)
					nTaxaM:=Round(SE1->E1_VLCRUZ/SE1->E1_VALOR,3)
					If SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM+"/"+MVIRABT+"/"+MVFUABT+"/"+MVINABT+"/"+MVISABT+"/"+MVPIABT+"/"+MVCFABT
						AtuSalDup("-",SE1->E1_SALDO,SE1->E1_MOEDA,SE1->E1_TIPO,Iif(nTaxaM==1,Nil,nTaxaM),SE1->E1_EMISSAO)
					Else
						nSaldoTit := SE1->E1_SALDO
						nSaldoTit := Iif(nSaldoTit < 0, 0, nSaldoTit)
						IF !(SE1->E1_TIPO $ MVPROVIS)
							AtuSalDup("+",nSaldoTit,SE1->E1_MOEDA,SE1->E1_TIPO,Iif(nTaxaM==1,Nil,nTaxaM),SE1->E1_EMISSAO)
						Endif
		    			Reclock( "SA1" )
						SA1->A1_PRICOM  := Iif(SE1->E1_EMISSAO<A1_PRICOM.or.Empty(A1_PRICOM),SE1->E1_EMISSAO,A1_PRICOM)
											
						If Year(SE1->E1_EMISSAO) == Year(dDataBase) .And. !("FINA280" $ AllTrim(Upper(SE1->E1_ORIGEM)))
							If lRastro
								// Se for desdobramento por rastreamento (FI7/FI8), verifica se nao eh baixa por desdobramento
								FI7->( dbSetOrder( 1 ) )
								If !FI7->( MsSeek( xFilial("FI7") + SE1->( E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA ) ) )
									SA1->A1_VACUM += xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,nMoedaF,SE1->E1_EMISSAO,3,SE1->E1_TXMOEDA)
								EndIf	
							Else										
								SA1->A1_VACUM += xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,nMoedaF,SE1->E1_EMISSAO,3,SE1->E1_TXMOEDA)
							EndIf	
						Endif
	
						IF !(SE1->E1_TIPO $ MVPROVIS)					
						    						    
						    If AllTrim(Upper(SE1->E1_ORIGEM)) == "MATA460"
						       SF2->(dbSetOrder(2)) 							
							    cFilSF2 := If ( lE1Msfil .and. !Empty(xFilial("SF2")) .AND. !EMPTY(SE1->E1_MSFIL) , SE1->E1_MSFIL , xFilial("SF2"))
								If !SF2->( MsSeek(cFilSF2+SE1->(E1_CLIENTE+E1_LOJA+E1_NUM+E1_PREFIXO)))   
									// Se nao encontrou a nota, procura pela serie da nota ao inves do prefixo (MV_1DUPREF customizado)
									SF2->( MsSeek(cFilSF2+SE1->(E1_CLIENTE+E1_LOJA+E1_NUM+E1_SERIE)))
								Endif
								If SF2->(!EoF())
							      	nMaiorVDAaux := xMoeda(SF2->F2_VALFAT,SE1->E1_MOEDA,nMoedaF,SE1->E1_EMISSAO) 
								    If nMaiorVDA < nMaiorVDAaux
								        nMaiorVDA := nMaiorVDAaux
								    Endif
							   Endif
							Else
							   nMaiorVDA := xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,nMoedaF,SE1->E1_EMISSAO,3,SE1->E1_TXMOEDA)
							Endif							   						    
						    
							nValForte := xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,nMoedaF,SE1->E1_EMISSAO,3,SE1->E1_TXMOEDA)
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//?Atualiza Atrasos/Pagamentos em Atraso do Cliente  - 07/12/95     ?
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							aBaixas:=Baixas(SE1->E1_NATUREZ,SE1->E1_PREFIXO,SE1->E1_NUM,;
								SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_MOEDA,"R",SE1->E1_CLIENTE,;
								dDataBase,SE1->E1_LOJA,SE1->E1_FILIAL)																												
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Funcao para ajustar os campos do SA1 para vendas?
						//³que possuem Administradora Financeira e         ?
						//³apenas para o modulo SIGALOJA                   ?
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Endif
						F410AjusLj(nMaiorVDA,cNumPedVen,nMoedaF)
					Endif
				Endif
			Endif	
			cNumPedVen := SE1->E1_PEDIDO
			dbSelectArea( "SE1" )
			dbSkip()
		Enddo
	//EndIf
	dbSelectArea( "SE1" )
	dbSetOrder(1)
	MsUnlockAll()
	
#IFDEF TOP
Endif
#ENDIF

Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Funcao    ³VerIDProc ?Autor ?Marcelo Pimentel      ?Data ?4.07.2007³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ³Identifica a sequencia de controle do fonte ADVPL com a     ³±?
±±?         ³stored procedure, qualquer alteracao que envolva diretamente³±?
±±?         ³a stored procedure a variavel sera incrementada.            ³±?
±±?         ³Procedure FIN003                                            ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?  DATA   ?Programador   ³Manutencao Efetuada                         ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/         
Static Function VerIDProc()
Return '010'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Funcao    ³F410AjusLj    ?Autor ?Vendas e CRM		    ?Data ?2.09.2008³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ³Faz algumas alteracoes para que os campos referentes ao         ³±?
±±?         ³titulo/duplicata  que foram gravados no regostrp da             ³±?
±±?         ³administradora financeira sejam gravados no registro do         ³±?
±±?         ³cliente da venda                                                ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±³Parametros?ExpN1 - Maior Venda      					                  ³±?
±±?		 ?ExpC2 - Numero do Pedido                                       ³±?
±±?		 ?ExpN3 - Moeda Forte                                            ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Retorno   ?Nil                                                            ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?SigaLoja                                                       ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/         
Static Function F410AjusLj(nMaiorVDA,cNumPedVe,nMoedaF)

Local lE1MsFil 		:= SE1->(FieldPos("E1_MSFIL") > 0)	// Verifica se existe o campo E1_MSFIL
Local cFilSF2  		:= xFilial("SF2") 					// Filial do SF2
Local cFilBusca 	:= "  "								// Filial de busca a ser preenchida de acordo  com a condicao

DEFAULT nMaiorVDA   := 0
DEFAULT cNumPedVe   := ""
DEFAULT nMoedaF		:= Int(Val(SuperGetMv("MV_MCUSTO",,"") ))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso pertenca a um dos tipos abaixo grava algumas informacoes         ?
//³no registro do cliente que efetuou a compra.                          ?
//³Cartao Credito, Vales, Convenio,Cartao de Debito,Financiamento Proprio?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Upper(subs(SE1->E1_ORIGEM,1,3)) == "LOJ" .AND. ALLTRIM( SE1->E1_TIPO)  $ "CC;VA;CO;CD;FI"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Primeiramente busca se este titulo foi?
	//³gerado a partir de uma venda ( SF2 )  ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SF2") 
	DbSetOrder(1) 
	cFilSF2 := IIf(lE1Msfil .AND. !Empty(xFilial("SF2")),SE1->E1_MSFIL,xFilial("SF2"))
	If DbSeek(cFilSF2+SE1->E1_NUM +SE1->E1_PREFIXO)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso o cliente do titulo seja diferente da venda siginifica ?
		//³que eh uma administradora e nao eh financiamento prorpio    ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (SF2->F2_CLIENTE + SF2->F2_LOJA) <> (SE1->E1_CLIENTE + SE1->E1_LOJA)
			DbSelectArea("SA1")
			DbSetOrder(1)
			If !Empty(xFilial("SA1")) .AND. !Empty(xFilial("SE1"))
				cFilBusca := SE1->E1_FILIAL			// Ambos exclusivos, neste caso a filial serah 1 para 1
			Else
				cFilBusca := xFilial("SA1")			// filial do cliente (SA1)
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona o cliente da venda e faz a gravacao dos campos referentes a venda ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If DbSeek(cFilBusca + SF2->F2_CLIENTE+ SF2->F2_LOJA) 
				RecLock("SA1",.F.)
				If( SE1->E1_EMISSAO < SA1->A1_PRICOM .OR. Empty(SA1->A1_PRICOM) )
					REPLACE SA1->A1_PRICOM  WITH SE1->E1_EMISSAO
				EndIf	
				
				If Year(SE1->E1_EMISSAO) == Year(dDataBase) .AND. !("FINA280" $ AllTrim(Upper(SE1->E1_ORIGEM)))
					REPLACE SA1->A1_VACUM WITH SA1->A1_VACUM += xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,nMoedaF,SE1->E1_EMISSAO)
				Endif 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Numero de compras efetuadas pelo cliente na empresa.     ?
				//?O sistema soma autonáticamente um a cada pedido de venda.?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !("FINA280" $ AllTrim(Upper(SE1->E1_ORIGEM)))
			  		If !Empty(SE1->E1_PEDIDO)
			  			If cNumPedVe <> SE1->E1_PEDIDO
				   			REPLACE SA1->A1_NROCOM WITH SA1->A1_NROCOM += 1
				   		EndIf
				   	Else
			   			REPLACE SA1->A1_NROCOM WITH SA1->A1_NROCOM += 1
			   		EndIf
					MsUnlock()
				EndIf
		   	EndIf	
		EndIf	   		
	EndIf		   		
EndIf					

Return(Nil)