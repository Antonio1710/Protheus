#include 'protheus.ch'
#include 'parmtype.ch'

/*Largura das colunas FWLayer*/
#DEFINE LRG_COL01		19
#DEFINE LRG_COL02		71
#DEFINE LRG_COL03		10

/*Posicoes do pergunte do SX1*/
#DEFINE POS_X1DES		1
#DEFINE POS_X1TIP		2
#DEFINE POS_X1TAM		3
#DEFINE POS_X1OBJ		6
#DEFINE POS_X1VLD		7
#DEFINE POS_X1VAL		8
#DEFINE POS_X1CB1		9
#DEFINE POS_X1CB2		10
#DEFINE POS_X1CB3		11
#DEFINE POS_X1CB4		12
#DEFINE POS_X1CB5		13
#DEFINE POS_X1VAR		14

Static nDistPad	:= 002
Static nAltBot	:= 013
Static nQtdePerg:= 7
Static cHK		:= "&"

/*/{Protheus.doc} User Function ADFIS005P
	Função principal para criar a tela com as informações	das tabelas SGOPR010, SGREQ010, SGMOV010, SGINV010 para serem seleciona
	das e processadas chamando as funções em outros fontes.
	ADFIS005P - Tela para processamento das OP's, Movimentações e Inventários
	Módulo Ativo Fixo (01)			                          															
	Projeto Bloco K
	Adoro 
	@type  Function
	@author Leonardo Rios
	@since 12/12/2016
	@version 01
	@history Everson,           24/06/2020, Chamado 058675 - Adicionada condição por empresa.
	@history Fernando Macieira, 05/03/2021, Ticket 10248   - Revisão das rotinas de apontamento de OP´s
	@history Fernando Macieira, 27/09/2021, Ticket 29741   - Divergencia ao limpar dados de ordens integradas do SAG
	@history Fernando Macieira, 29/09/2021, Ticket 30160   - Lentidão ao processar ordem
/*/
User Function ADFIS005P() // U_ADFIS005P()

	Local aCols 	:= {} 	/* Valores da tela das informações da SGOPR010 */
	Local aCols2 	:= {} 	/* Valores da tela das informações da SGMOV010 */
	Local aCols3 	:= {} 	/* Valores da tela das informações da SGINV010 */
	Local aCoord	:= FWGetDialogSize(oMainWnd)
	Local aPergunte	:= {}
	Local aPergunte2:= {}
	Local aPergunte3:= {}
	Local aPages	:= {"Plan01","Plan02", "Plan03"}
	Local aReqs		:= {} 	/* Array que receberá o array da tabela SGREQ010 referente a informação da SGOPR010 */
	Local aTamObj	:= {0,0,0,0}
	Local aTitulo	:= { "Produção", "Movimentos", "Inventário"}

	Local bAtGD		:= {|lAtGD,lFoco| IIf(lAtGD,(oGD01:SetArray(aCols ),oGD01:bLine := &(cLine01),oGD01:GoTop(),oGD01:SetFocus(), oGD01:Refresh()),.T.),IIf(ValType(lFoco) == "L" .AND. lFoco,(oGD01:SetFocus(), oGD01:DrawSelect()),.T.)}
	Local bAtGD2	:= {|lAtGD,lFoco| IIf(lAtGD,(oGD02:SetArray(aCols2),oGD02:bLine := &(cLine02),oGD02:GoTop(),oGD02:SetFocus(), oGD02:Refresh()),.T.),IIf(ValType(lFoco) == "L" .AND. lFoco,(oGD02:SetFocus(), oGD02:DrawSelect()),.T.)}
	Local bAtGD3	:= {|lAtGD,lFoco| IIf(lAtGD,(oGD03:SetArray(aCols3),oGD03:bLine := &(cLine03),oGD03:GoTop(),oGD03:SetFocus(), oGD03:Refresh()),.T.),IIf(ValType(lFoco) == "L" .AND. lFoco,(oGD03:SetFocus(), oGD03:DrawSelect()),.T.)}
	Local bAtFim	:= {|| oTela:End() }

	Local cLine01	:= ""
	Local cLine02	:= ""
	Local cLine03	:= ""
	Local cMens		:= ""
	Local cPerg		:="ADFIS005P"

	Local lMDI		:= oAPP:lMDI
	Local lEntrou	:= .F. 	/* Variável para controle para pular de linha nas informações retornadas da query SGOPR010 e SGREQ010 */

	Local nCoefDif	:= 1

	Local oArea		:= FWLayer():New()
	Local oArea2	:= FWLayer():New()
	Local oArea3	:= FWLayer():New()
	Local oDlg
	Local oGD01
	Local oGetDados
	Local oNo 		:= LoadBitmap(GetResources(),"LBNO")
	Local oOk 		:= LoadBitmap(GetResources(),"LBOK")
	Local oTPanel

	/*Objetos graficos*/
	Local oPainelS01
	Local oPainelS02
	Local oPainelS03
	Local oPainel01
	Local oPainel02
	Local oPainel03
	Local oPainel201
	Local oPainel202
	Local oPainel203
	Local oPainel301
	Local oPainel302
	Local oPainel303
	Local oTela

	Private _ItensSlec 	:= {{}, {}, {}} 	/*Variável para otimização no processamento dos itens selecionador*/
	Private _aPosicoes	:= {}	/*Variáveis para criação dos botões do painel 3 após o processamento do botão de pesquisa do painel1*/
			
	/*Botões para controle da visibilidade deles na tela*/
	Private _oBtn1Pnl1	:= Nil	/*Botão de processamento das OPRs da tela de processamentos*/
	Private _oBtn2Pnl1	:= Nil	/*Botão de estorno das OPRs da tela de processamentos*/
	Private _oBtn3Pnl1	:= Nil	/*Botão de visualizar OPRs da tela de processamentos*/
	Private _oBtn4Pnl1	:= Nil	/*Botão de limpar dados das OPRs da tela de processamentos*/
	Private _oBtn1Pnl2	:= Nil	/*Botão de processamento das MOVs da tela de processamentos*/
	Private _oBtn2Pnl2	:= Nil	/*Botão de estorno das MOVs da tela de processamentos*/
	Private _oBtn3Pnl2	:= Nil	/*Botão de limpar dados das MOVs da tela de processamentos*/
	Private _oBtn1Pnl3	:= Nil	/*Botão de processamento das INVs da tela de processamentos*/
	Private _oBtn2Pnl3	:= Nil	/*Botão de estorno das INVs da tela de processamentos*/
	Private _oBtn3Pnl3	:= Nil	/*Botão de limpar dados das INVs da tela de processamentos*/

	/* Variáveis para controle das perguntas*/
	Private _nPerg1Tip := Nil /* Tabela */
	Private _dPerg2Dta := Nil /* Período De */
	Private _dPerg3Dta := Nil /* Período Ate */
	Private _cPerg4Pdt := Nil /* Produto De */
	Private _cPerg5Pdt := Nil /* Produto Ate */
	Private _cPerg6Sta := Nil /* Status */
	Private _cPerg7Ope := Nil /* Tipo de Operação */

	/* Variáveis para conexão entre os banco do Protheus e o banco intermediário */
	Private _cNomBco1  := GetPvProfString("INTSAGBD","BCO1","ERROR",GetADV97())
	Private _cSrvBco1  := GetPvProfString("INTSAGBD","SRV1","ERROR",GetADV97())
	Private _cPortBco1 := Val(GetPvProfString("INTSAGBD","PRT1","ERROR",GetADV97()) )
	Private _nTcConn1  := AdvConnection()
	Private _cNomBco2  := GetPvProfString("INTSAGBD","BCO2","ERROR",GetADV97())
	Private _cSrvBco2  := GetPvProfString("INTSAGBD","SRV2","ERROR",GetADV97())
	Private _cPortBco2 := Val(GetPvProfString("INTSAGBD","PRT2","ERROR",GetADV97()))
	Private _nTcConn2  := 0

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Função principal para criar a tela com as informações	das tabelas SGOPR010, SGREQ010, SGMOV010, SGINV010 para serem seleciona  das e processadas chamando as funções em outros fontes')

	// @history Fernando Macieira, 05/03/2021, Ticket 10248. Revisão das rotinas de apontamento de OP´s
	// Garanto uma única thread sendo executada
	If !LockByName("ADFIS005P", .T., .F.)
		Aviso("Atenção", "Existe outro processamento sendo executado! Verifique com seu colega de trabalho...", {"OK"}, 3)
		Return
	EndIf

	/*Cria as perguntas no SX1*/
	AjustaSX1(cPerg)         
	
	If !Pergunte(cPerg,.T.)
		Return Nil
	EndIf
		
	/*Seta Variáveis das perguntas*/
	_nPerg1Tip := mv_par01 /* Tabela */
	_dPerg2Dta := mv_par02 /* Período De */
	_dPerg3Dta := mv_par03 /* Período Ate */
	_cPerg4Pdt := mv_par04 /* Produto De */
	_cPerg5Pdt := mv_par05 /* Produto Ate */
	_cPerg6Sta := mv_par06 /* Status */
	_cPerg7Ope := mv_par07 /* Tipo de Operação */
	
	/* Executa a função para buscar as informações e carregar os arrays para serem usados nos grids */
	ADFIS005PC(@aCols, @aCols2, @aCols3, @aReqs)	
		
	/*
		Montar o codeblock para montar as listas de dados da GD  
	*/
	cLine01 := "{|| Iif( Len(aCols) < 1, {}, "
	cLine01 += " { aCols[oGD01:nAt,1], "
	cLine01 += "IIf(aCols[oGD01:nAt,2],oOk,oNo),"
	For ni := 3 to 15
		cLine01 += "aCols[oGD01:nAt," + cValToChar(ni) + "]" + IIf(ni < 15,",","")
	Next ni
	cLine01 += "} ) }"
	
	cLine02 := "{|| Iif( Len(aCols2) < 1, {}, "
	cLine02 += " { aCols2[oGD02:nAt,1], "
	cLine02 += "IIf(aCols2[oGD02:nAt,2],oOk,oNo),"
	For ni := 3 to 16
		cLine02 += "aCols2[oGD02:nAt," + cValToChar(ni) + "]" + IIf(ni < 16,",","")
	Next ni
	cLine02 += "} ) }"
	
	cLine03 := "{|| Iif( Len(aCols3) < 1, {}, "
	cLine03 += " { aCols3[oGD03:nAt,1], "
	cLine03 += "IIf(aCols3[oGD03:nAt,2],oOk,oNo),"
	For ni := 3 to 11
		cLine03 += "aCols3[oGD03:nAt," + cValToChar(ni) + "]" + IIf(ni < 11,",","")
	Next n3
	cLine03 += "} ) }"
	
	DEFINE MSDIALOG oTela TITLE "Tela de Pré-Processamento" FROM aCoord[1],aCoord[2] TO aCoord[3],aCoord[4] OF oMainWnd COLOR "W+/W" PIXEL

		oFolder:= TFolder():New(00, 01, aTitulo, aPages, oDlg,,,, .F., .F., 640, 260)
		oFolder:Refresh()
		
		oArea:Init(oFolder:aDialogs[1] ,.F.)
		oArea2:Init(oFolder:aDialogs[2] ,.F.)
		oArea3:Init(oFolder:aDialogs[3] ,.F.)
		
		/*
			Colunas
		*/
		/*Painel 1*/
		oArea:AddLine("L01",100 * nCoefDif,.T.)
		oArea:AddCollumn("L01C01", LRG_COL01, .F., "L01")
		oArea:AddCollumn("L01C02", LRG_COL02, .F., "L01")
		oArea:AddCollumn("L01C03", LRG_COL03, .F., "L01")
		
		/*Painel 2*/
		oArea2:AddLine("L02",100 * nCoefDif,.T.)
		oArea2:AddCollumn("L02C01", LRG_COL01, .F., "L02")
		oArea2:AddCollumn("L02C02", LRG_COL02, .F., "L02")
		oArea2:AddCollumn("L02C03", LRG_COL03, .F., "L02")
		
		/*Painel 3*/
		oArea3:AddLine("L03",100 * nCoefDif,.T.)
		oArea3:AddCollumn("L03C01", LRG_COL01, .F., "L03")
		oArea3:AddCollumn("L03C02", LRG_COL02, .F., "L03")
		oArea3:AddCollumn("L03C03", LRG_COL03, .F., "L03")
		
		/*/////////////////////////////
		Paineis
		*//////////////////////////////
		
		/*Painel 1*/
		oArea:AddWindow("L01C01", "L01C01P01", "Parâmetros", 100, .F., .F.,/*bAction*/, "L01",/*bGotFocus*/)
		oPainel01 := oArea:GetWinPanel("L01C01","L01C01P01","L01")
			
		oArea:AddWindow("L01C02", "L01C02P01", "Dados adicionais", 100, .F., .F.,/*bAction*/, "L01",/*bGotFocus*/)
		oPainel02 := oArea:GetWinPanel("L01C02","L01C02P01","L01")
			
		oArea:AddWindow("L01C03", "L01C03P01","Funções", 100, .F., .F.,/*bAction*/, "L01",/*bGotFocus*/)
		oPainel03 := oArea:GetWinPanel("L01C03", "L01C03P01", "L01")
		
		/*Painel 2*/
		oArea2:AddWindow("L02C01", "L02C01P01", "Parâmetros", 100, .F., .F.,/*bAction*/, "L02",/*bGotFocus*/)
		oPainel201 := oArea2:GetWinPanel("L02C01","L02C01P01","L02")
		
		oArea2:AddWindow("L02C02", "L02C02P01", "Dados adicionais", 100, .F., .F.,/*bAction*/, "L02",/*bGotFocus*/)
		oPainel202 := oArea2:GetWinPanel("L02C02","L02C02P01","L02")
			
		oArea2:AddWindow("L02C03", "L02C03P01","Funções", 100, .F., .F.,/*bAction*/, "L02",/*bGotFocus*/)
		oPainel203 := oArea2:GetWinPanel("L02C03", "L02C03P01", "L02")
		
		/*Painel 3*/
		oArea3:AddWindow("L03C01", "L03C01P01", "Parâmetros", 100, .F., .F.,/*bAction*/, "L03",/*bGotFocus*/)
		oPainel301 := oArea3:GetWinPanel("L03C01","L03C01P01","L03")
			
		oArea3:AddWindow("L03C02", "L03C02P01", "Dados adicionais", 100, .F., .F.,/*bAction*/, "L03",/*bGotFocus*/)
		oPainel302 := oArea3:GetWinPanel("L03C02","L03C02P01","L03")
			
		oArea3:AddWindow("L03C03", "L03C03P01","Funções", 100, .F., .F.,/*bAction*/, "L03",/*bGotFocus*/)
		oPainel303 := oArea3:GetWinPanel("L03C03", "L03C03P01", "L03")
	
		/*/////////////////////////////////
			Painel 01 - Filtros
		*/////////////////////////////////

		/*PERGUNTAS*/
		U_DefTamObj(@aTamObj, 000, 000,(oPainel01:nClientHeight / 2) * 0.9, oPainel01:nClientWidth / 2)
		oPainelS01 := tPanel():New(aTamObj[1], aTamObj[2], "", oPainel01,, .F., .F.,, CLR_WHITE, aTamObj[4], aTamObj[3], .T., .F.)			
		Pergunte(cPerg, .T.,, .F., oPainel01,, @aPergunte, .T., .F.)
			
		/*BOTAO PESQUISA*/
		U_DefTamObj(@aTamObj, (oPainel01:nClientHeight / 2) - nAltBot, 000, (oPainel01:nClientWidth / 2), nAltBot, .T.)
		tButton():New(aTamObj[1], aTamObj[2], cHK + "Pesquisar", oPainel01,; 
						{|| IIf(ADFIS005PB(cPerg, @aPergunte),;
							MsAguarde({|| CursorWait(), ADFIS005PG(Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, oPainel03, oPainel203, oPainel303), ADFIS005PC(@aCols, @aCols2, @aCols3, @aReqs), Eval(bAtGD,.T.,.T.), Eval(bAtGD2,.T.,.T.),;
							Eval(bAtGD3,.T.,.T.), CursorArrow()}, "Pre-Processamento","Pesquisando",.F.),.F.)},;
						aTamObj[3], aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.},/*When*/)
		
		/*////////////////////////////////////
			Painel2 01 - Filtros
		*////////////////////////////////////

		/*PERGUNTAS*/
		U_DefTamObj(@aTamObj, 000, 000,(oPainel201:nClientHeight / 2) * 0.9, oPainel201:nClientWidth / 2)
		oPainelS02 := tPanel():New(aTamObj[1], aTamObj[2], "", oPainel201,, .F., .F.,, CLR_WHITE, aTamObj[4], aTamObj[3], .T., .F.)			
		Pergunte(cPerg, .T.,, .F., oPainel201,, @aPergunte, .T., .F.)
			
		/*BOTAO PESQUISA*/
		U_DefTamObj(@aTamObj, (oPainel201:nClientHeight / 2) - nAltBot, 000, (oPainel201:nClientWidth / 2), nAltBot, .T.)
		tButton():New(aTamObj[1], aTamObj[2], cHK + "Pesquisar", oPainel201,; 
						{|| IIf(ADFIS005PB(cPerg, @aPergunte),;
							MsAguarde({|| CursorWait(), ADFIS005PC(@aCols, @aCols2, @aCols3, @aReqs), Eval(bAtGD,.T.,.T.), Eval(bAtGD2,.T.,.T.),;
							Eval(bAtGD3,.T.,.T.), ADFIS005PG(Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, oPainel03, oPainel203, oPainel303), CursorArrow()}, "Pre-Processamento","Pesquisando",.F.),.F.)},;
						aTamObj[3], aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.},/*When*/)
		
		/*////////////////////////////////////
			Painel3 01 - Filtros
		*//////////////////////////////////////

		/*PERGUNTAS*/
		U_DefTamObj(@aTamObj, 000, 000,(oPainel301:nClientHeight / 2) * 0.9, oPainel301:nClientWidth / 2)
		oPainelS03 := tPanel():New(aTamObj[1], aTamObj[2], "", oPainel301,, .F., .F.,, CLR_WHITE, aTamObj[4], aTamObj[3], .T., .F.)			
		Pergunte(cPerg, .T.,, .F., oPainel301,, @aPergunte, .T., .F.)
			
		/*BOTAO PESQUISA*/
		U_DefTamObj(@aTamObj, (oPainel301:nClientHeight / 2) - nAltBot, 000, (oPainel301:nClientWidth / 2), nAltBot, .T.)
		tButton():New(aTamObj[1], aTamObj[2], cHK + "Pesquisar", oPainel301,;
						{|| IIf(ADFIS005PB(cPerg, @aPergunte),;
							MsAguarde({|| CursorWait(), ADFIS005PC(@aCols, @aCols2, @aCols3, @aReqs), Eval(bAtGD,.T.,.T.), Eval(bAtGD2,.T.,.T.),;
							Eval(bAtGD3,.T.,.T.), ADFIS005PG(Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, oPainel03, oPainel203, oPainel303), CursorArrow()}, "Pre-Processamento","Pesquisando",.F.),.F.)},;
						aTamObj[3], aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.},/*When*/)	
			
		/*/////////////////////////////////////
			Painel 02 - Lista de dados
		*/////////////////////////////////////
		oGD01:= TCBrowse():New(000, 000, 000, 000,/*bLine*/, {' ', ' ', 'C2_FILIAL', 'C2_PRODUTO', 'C2_QUANT', 'C2_LOCAL', 'C2_CC', 'C2_EMISSAO', 'C2_NUM', 'C2_ITEM', 'C2_SEQUEN', 'C2_REVISAO', 'STATUS_INT', 'OPERACAO_INT', 'R_E_C_N_O_'},, oPainel02,,,,/*bChange*/,/*bLDblClick*/,/*bRClick*/,/*oFont*/,,,,,,,.T.,/*bWhen*/,,/*bValid*/,.T.,.T.)
		oGD01:bHeaderClick	:= { |oObj,nCol| ADFIS005PD(16, @aCols, @oGD01, 1, Len(aCols), 1), oGD01:Refresh() }
		oGD01:blDblClick	:= { || ADFIS005PD(16, @aCols, @oGD01, oGD01:nAt, oGD01:nAt, 1), oGD01:Refresh() }
		oGD01:Align 		:= CONTROL_ALIGN_ALLCLIENT
		Eval(bAtGD,.T.,.F.)
		
		/*///////////////////////////////////////
			Painel2 02 - Lista de dados
		*///////////////////////////////////////
		oGD02:= TCBrowse():New(000, 000, 000, 000,/*bLine*/, {' ', ' ', 'D3_FILIAL', 'D3_TM', 'D3_COD', 'D3_QUANT', 'D3_LOCAL', 'D3_CC', 'D3_EMISSAO', 'D3_OP', 'D3_NUMSEQ', 'D3_CUSTO1', 'D3_PARCTOT', 'STATUS_INT', 'OPERACAO_INT', 'R_E_C_N_O_'},, oPainel202,,,,/*bChange*/,/*bLDblClick*/,/*bRClick*/,/*oFont*/,,,,,,,.T.,/*bWhen*/,,/*bValid*/,.T.,.T.)
		oGD02:bHeaderClick	:= { |oObj,nCol| ADFIS005PD(17, @aCols2, @oGD02, 1, Len(aCols2), 2), oGD02:Refresh() }
		oGD02:blDblClick	:= { || ADFIS005PD(17, @aCols2, @oGD02, oGD02:nAt, oGD02:nAt, 2), oGD02:Refresh() }
		oGD02:Align 		:= CONTROL_ALIGN_ALLCLIENT
		Eval(bAtGD2,.T.,.F.)
					
		/*////////////////////////////////////////
			Painel3 02 - Lista de dados
		*///////////////////////////////////////
		oGD03:= TCBrowse():New(000, 000, 000, 000,/*bLine*/, {' ', ' ', 'B7_FILIAL', 'B7_COD', 'B7_QUANT', 'B7_LOCAL', 'B7_DATA', 'B7_DOC', 'STATUS_INT', 'OPERACAO_INT', 'R_E_C_N_O_'},, oPainel302,,,,/*bChange*/,/*bLDblClick*/,/*bRClick*/,/*oFont*/,,,,,,,.T.,/*bWhen*/,,/*bValid*/,.T.,.T.)
		oGD03:bHeaderClick	:= { |oObj,nCol| ADFIS005PD(12, @aCols3, @oGD03, 1, Len(aCols3), 3), oGD03:Refresh() }
		oGD03:blDblClick	:= { || ADFIS005PD(12, @aCols3, @oGD03, oGD03:nAt, oGD03:nAt, 3), oGD01:Refresh() }
		oGD03:Align 		:= CONTROL_ALIGN_ALLCLIENT
		Eval(bAtGD3,.T.,.F.)
			
		/*//////////////////////////////////
			Painel1 03 - Funcoes
		*///////////////////////////////////
		U_DefTamObj(@aTamObj, 000, 000, (oPainel03:nClientWidth / 2), nAltBot, .T.)
		
		/*Guarda as posições iniciais do painel 3 para ser usado quando for ter que criar os botões novamente após uma pesquisa ter sido efetuada no painel 1*/
		_aPosicoes := aTamObj 
		
		/*Processamento*/			
		U_DefTamObj(@aTamObj, 000, 000, (oPainel03:nClientWidth / 2), nAltBot, .T.)
		_oBtn1Pnl1 := tButton():New(aTamObj[1], aTamObj[2], cHK + "Processamento", oPainel03,;
									{|| IIf(ADFIS005PF(@aCols, @aCols2, @aCols3, 1, .F.),;
										MsAguarde({|| CursorWait(),ADFIS005PC(@aCols, @aCols2, @aCols3, @aReqs), Eval(bAtGD,.T.,.T.), Eval(bAtGD2,.T.,.T.),;
										Eval(bAtGD3,.T.,.T.),CursorArrow()}, "Pre-Processamento","Processando",.F.),.F.)},;
									aTamObj[3], aTamObj[4],,/*Font*/,, .T.,,,,{|| .T.}/*When*/)
		
		/*Soma no array de posicionamento o espacamento do botão Estorno*/
		U_DefTamObj(@aTamObj, aTamObj[1] + nAltBot + (nDistPad*3))
		
		/*Estorno*/
		_oBtn2Pnl1 := tButton():New(aTamObj[1], aTamObj[2], cHK + "Estorno", oPainel03,;
										{|| IIf(ADFIS005PF(@aCols, @aCols2, @aCols3, 1, .T.),;
											MsAguarde({|| CursorWait(),ADFIS005PC(@aCols, @aCols2, @aCols3, @aReqs), Eval(bAtGD,.T.,.T.), Eval(bAtGD2,.T.,.T.),;
											Eval(bAtGD3,.T.,.T.),CursorArrow()}, "Pre-Processamento","Estornando",.F.),.F.)},;
											aTamObj[3], aTamObj[4] ,,/*Font*/,, .T.,,,,{|| .T.}/*When*/)
		
		/*Soma no array de posicionamento o espacamento do botão Visualizar*/
		U_DefTamObj(@aTamObj, aTamObj[1] + nAltBot + (nDistPad*3))
		
		/*Visualizar*/
		_oBtn3Pnl1 := tButton():New(aTamObj[1], aTamObj[2], cHK + "Visualização", oPainel03,{|| ADFIS005PE(aReqs, oGD01:nAt) }, aTamObj[3], aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
		
		/*Soma no array de posicionamento o espacamento do botão LimparDados*/
		U_DefTamObj(@aTamObj, aTamObj[1] + nAltBot + (nDistPad*3))
		
		/*Limpa Dados*/
		_oBtn4Pnl1 := tButton():New(aTamObj[1], aTamObj[2], cHK + "Limpar Dados", oPainel03, ;
										{|| IIf(ADFIS005PH(1, @aCols, @aCols2, @aCols3),;
											MsAguarde({|| CursorWait(),ADFIS005PC(@aCols, @aCols2, @aCols3, @aReqs), Eval(bAtGD,.T.,.T.), Eval(bAtGD2,.T.,.T.),;
											Eval(bAtGD3,.T.,.T.),CursorArrow()}, "Excluindo dados","Limpando",.F.),.F.)},;
											aTamObj[3], aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
		
		/*///////////////////////////////////////
			Painel2 03 - Funcoes
		*///////////////////////////////////////
		
		/*Soma no array de posicionamento o espacamento do botão Processamento*/
		U_DefTamObj(@aTamObj, 000, 000, (oPainel203:nClientWidth / 2), nAltBot, .T.)

		/*Processamento*/			
		_oBtn1Pnl2 := tButton():New(aTamObj[1], aTamObj[2], cHK + "Processamento", oPainel203,;
										{|| IIf(ADFIS005PF(@aCols, @aCols2, @aCols3, 2, .F.),;
											MsAguarde({|| CursorWait(),ADFIS005PC(@aCols, @aCols2, @aCols3, @aReqs), Eval(bAtGD,.T.,.T.), Eval(bAtGD2,.T.,.T.),;
											Eval(bAtGD3,.T.,.T.),CursorArrow()}, "Pre-Processamento","Processando",.F.),.F.)},;
										aTamObj[3], aTamObj[4],,/*Font*/,, .T.,,,,{|| .T.}/*When*/)
		
		/*Soma no array de posicionamento o espacamento do botão Estorno*/
		U_DefTamObj(@aTamObj, aTamObj[1] + nAltBot + (nDistPad*3))
		
		/*Estorno*/
		_oBtn2Pnl2 := tButton():New(aTamObj[1], aTamObj[2], cHK + "Estorno", oPainel203,;
										{|| IIf(ADFIS005PF(@aCols, @aCols2, @aCols3, 2, .T.),;
											MsAguarde({|| CursorWait(),ADFIS005PC(@aCols, @aCols2, @aCols3, @aReqs), Eval(bAtGD,.T.,.T.), Eval(bAtGD2,.T.,.T.),;
											Eval(bAtGD3,.T.,.T.),CursorArrow()}, "Pre-Processamento","Estornando",.F.),.F.)},;
										aTamObj[3], aTamObj[4] ,,/*Font*/,, .T.,,,,{|| .T.}/*When*/)

		/*Soma no array de posicionamento o espacamento do botão LimparDados*/
		U_DefTamObj(@aTamObj, aTamObj[1] + nAltBot + (nDistPad*3))
		
		/*Limpa Dados*/
		_oBtn3Pnl2 := tButton():New(aTamObj[1], aTamObj[2], cHK + "Limpar Dados", oPainel203, ;
										{|| IIf(ADFIS005PH(2, @aCols, @aCols2, @aCols3),;
											MsAguarde({|| CursorWait(),ADFIS005PC(@aCols, @aCols2, @aCols3, @aReqs), Eval(bAtGD,.T.,.T.), Eval(bAtGD2,.T.,.T.),;
											Eval(bAtGD3,.T.,.T.),CursorArrow()}, "Excluindo dados","Limpando",.F.),.F.)},;
										aTamObj[3], aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)

		/*/////////////////////////////////
			Painel3 03 - Funcoes
		*/////////////////////////////////

		/*Soma no array de posicionamento o espacamento do botão Processamento*/
		U_DefTamObj(@aTamObj, 000, 000, (oPainel303:nClientWidth / 2), nAltBot, .T.)
		
		/*Processamento*/			
		_oBtn1Pnl3 := tButton():New(aTamObj[1], aTamObj[2], cHK + "Processamento", oPainel303,;
										{|| IIf(ADFIS005PF(@aCols, @aCols2, @aCols3, 3, .F.),;
											MsAguarde({|| CursorWait(),ADFIS005PC(@aCols, @aCols2, @aCols3, @aReqs), Eval(bAtGD,.T.,.T.), Eval(bAtGD2,.T.,.T.),;
											Eval(bAtGD3,.T.,.T.),CursorArrow()}, "Pre-Processamento","Processando",.F.),.F.)},;
										aTamObj[3], aTamObj[4],,/*Font*/,, .T.,,,,{|| .T.}/*When*/)

		/*Soma no array de posicionamento o espacamento do botão Estorno*/	
		U_DefTamObj(@aTamObj, aTamObj[1] + nAltBot + (nDistPad*3))
		
		/*Estorno*/
		_oBtn2Pnl3 := tButton():New(aTamObj[1], aTamObj[2], cHK + "Estorno", oPainel303,;
										{|| IIf(ADFIS005PF(@aCols, @aCols2, @aCols3, 3, .T.),;
											MsAguarde({|| CursorWait(),ADFIS005PC(@aCols, @aCols2, @aCols3, @aReqs), Eval(bAtGD,.T.,.T.), Eval(bAtGD2,.T.,.T.),;
											Eval(bAtGD3,.T.,.T.),CursorArrow()}, "Pre-Processamento","Estornando",.F.),.F.)},;
										aTamObj[3], aTamObj[4] ,,/*Font*/,, .T.,,,,{|| .T.}/*When*/)

		/*Soma no array de posicionamento o espacamento do botão LimparDados*/
		U_DefTamObj(@aTamObj, aTamObj[1] + nAltBot + (nDistPad*3))
		
		/*Limpa Dados*/
		_oBtn3Pnl3 := tButton():New(aTamObj[1], aTamObj[2], cHK + "Limpar Dados", oPainel303, ;
										{|| IIf(ADFIS005PH(3, @aCols, @aCols2, @aCols3),;
											MsAguarde({|| CursorWait(),ADFIS005PC(@aCols, @aCols2, @aCols3, @aReqs), Eval(bAtGD,.T.,.T.), Eval(bAtGD2,.T.,.T.),;
											Eval(bAtGD3,.T.,.T.),CursorArrow()}, "Excluindo dados","Limpando",.F.),.F.)},;
										aTamObj[3], aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
		
		/*Ajusta a visibilidade dos botões de processamento/estorno/visualização do painel 3 para todas as opções(OPR, MOV, INV)*/
		/*
			Parâmetros
					³ aParam[1]  	:[A] aCols   	- Array com as informações da tabela SGOPR010 no do grid 1 (Produção)						
					³ aParam[2]  	:[A] aCols2  	- Array com as informações da tabela SGMOV010 no do grid 2 (Movimentos)					
					³ aParam[3]  	:[A] aCols3  	- Array com as informações da tabela SGINV010 no do grid 3 (Inventário)					
					³ aParam[4]  	:[A] aReqs   	- Array com as informações da tabela SGREQ010 no do grid 3 (Requisições)					
					³ aParam[5]  	:[B] bAtGD   	- Bloco de código executado para atualizar o grid das OPRs no painel 2					
					³ aParam[6]  	:[B] bAtGD2  	- Bloco de código executado para atualizar o grid das MOVs no painel 2					
					³ aParam[7]  	:[B] bAtGD3  	- Bloco de código executado para atualizar o grid das INVs no painel 2					
					³ aParam[8]  	:[O] oArea  	- Objeto utilizado para a Area 1 do painel 3 dos botões de processamento das OPRs		
					³ aParam[9]  	:[O] oArea2 	- Objeto utilizado para a Area 2 do painel 3 dos botões de processamento das MOVs		
					³ aParam[10]  	:[O] oArea3 	- Objeto utilizado para a Area 3 do painel 3 dos botões de processamento das INVs		
					³ aParam[11]  	:[O] oPainel03 	- Objeto utilizado para o painel 3 dos itens OPRs e REQs da tela de Processamento		
					³ aParam[12]  	:[O] oPainel203	- Objeto utilizado para o painel 3 dos itens MOVs da tela de Processamento				
					³ aParam[13]  	:[O] oPainel303	- Objeto utilizado para o painel 3 dos itens INVs da tela de Processamento
		*/				
		ADFIS005PG(Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, oPainel03, oPainel203, oPainel303)

		/*///////////////////////////////
			Botões Gerais
		*////////////////////////////////
		@ 261,510 TO 280,650 LABEL "Botões Gerais" OF oDlg PIXEL

		/*Sair*/
		tButton():New(268, 550, cHK + "Sair", oTela, {|| oTela:End() }, 40, 10,,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
		
		/*Legenda*/			
		tButton():New(268, 600, cHK + "Legenda", oTela,{|| Legenda()}, 40, 10,,/*Font*/,, .T.,,,,{|| .T.}/*When*/)

	oTela:Activate(,,,.T.,/*valid*/,,{|| .T.})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADFIS005P") // @history Fernando Macieira, 05/03/2021, Ticket 10248. Revisão das rotinas de apontamento de OP´s

Return Nil

/*/{Protheus.doc} ADFIS005PA 
	Função usada para executar a query referente a opção passado como parâmetro da função.
	Parâmetros aParam[1]  	:[C] cAliasT    - Variável com o Alias passado como referência para ser utilizado na query			
			   aParam[2]  	:[C] nOpc       - Variável com o número da opção da query a ser executada(1-OPR/REQ; 2=MOV; 3=INV)	
	Retorno	   aCampos[A] - Array contendo os nomes dos campos da query que serão utilizados no preenchimento do grid			
	Uso        EPCP007 - Tela para processamento das OP's, Movimentações e Inventários											
			   Módulo Ativo Fixo (01)			                          														
			   Projeto Bloco K					                          														
			   Adoro 					                          		  														
	@type  Static Function
	@author Leonardo Rios
	@since 13/12/2016
	@version 01
/*/
Static Function ADFIS005PA(cAliasT, nOpc)

	Local aCampos 	:= {}
	Local cSTATUS 	:= ""
	Local cOPERACAO	:= ""

	Default cAliasT := ""	/*Descrição do parâmetro conforme cabeçalho*/
	Default nOpc 	:= 0	/*Descrição do parâmetro conforme cabeçalho*/

	DO CASE
		CASE _cPerg7Ope == 1
			cOPERACAO := "I"
		CASE _cPerg7Ope == 2
			cOPERACAO := "A"
		OTHERWISE
			cOPERACAO := "E"
	ENDCASE
	
	If nOpc == 1
	
		DO CASE
			CASE _cPerg6Sta == 1
				cSTATUS := "% C2_MSEXP = ' ' AND D3_MSEXP = ' ' %"
			CASE _cPerg6Sta == 2
				cSTATUS := "% SGOPR010.STATUS_INT = 'S' AND SGOPR010.C2_MSEXP <> ' ' AND SGREQ010.STATUS_INT = 'S' AND SGREQ010.D3_MSEXP <> ' ' %"
			OTHERWISE
				cSTATUS := "% (SGOPR010.STATUS_INT = 'E' OR SGREQ010.STATUS_INT = 'E') %"
		ENDCASE
		
		BeginSQL Alias cAliasT
			SELECT 	(SUBSTRING(C2_EMISSAO,7,2) + '/' + SUBSTRING(C2_EMISSAO,5,2) + '/' + SUBSTRING(C2_EMISSAO,1,4)) AS EMISSAO, 
					(SUBSTRING(D3_EMISSAO,7,2) + '/' + SUBSTRING(D3_EMISSAO,5,2) + '/' + SUBSTRING(D3_EMISSAO,1,4)) AS DATA,
					C2_MSEXP AS MSEXP, * 
					
			FROM SGOPR010 (NOLOCK), SGREQ010 (NOLOCK)
			
			WHERE C2_EMISSAO BETWEEN %Exp:_dPerg2Dta% AND %Exp:_dPerg3Dta%
				AND C2_PRODUTO BETWEEN %Exp:_cPerg4Pdt% AND %Exp:_cPerg5Pdt%				
				AND SGOPR010.OPERACAO_INT = %Exp:cOPERACAO%
				AND SGOPR010.OPERACAO_INT = SGREQ010.OPERACAO_INT
				AND SGREQ010.D3_OP = SGOPR010.C2_NUM + SGOPR010.C2_ITEM + SGOPR010.C2_SEQUEN
				AND %Exp:cSTATUS%

				//Everson - 24/06/2020. Chamado 058765.
				AND SGOPR010.EMPRESA = %Exp:cEmpAnt%
				AND SGREQ010.EMPRESA = %Exp:cEmpAnt%
				//

				AND SGOPR010.D_E_L_E_T_ = ' '
				AND SGREQ010.D_E_L_E_T_ = ' '
			ORDER BY C2_NUM
		EndSQL
		
		AADD(aCampos, {"C2_FILIAL", "C2_PRODUTO", "C2_QUANT", "C2_LOCAL", "C2_CC", "EMISSAO", "C2_NUM", "C2_ITEM", "C2_SEQUEN", "C2_REVISAO", "STATUS_INT", "OPERACAO_INT", "R_E_C_N_O_"})
		AADD(aCampos, {"D3_FILIAL", "D3_TM", "D3_COD", "D3_QUANT", "D3_LOCAL", "D3_CC", "D3_OP", "D3_NUMSEQ", "CODIGENE", "D3_CUSTO1", "D3_PARCTOT", "DATA", "STATUS_INT", "OPERACAO_INT", "R_E_C_N_O_"})

		
	ElseIf nOpc == 2
	
		DO CASE
			CASE _cPerg6Sta == 1
				cSTATUS := "% D3_MSEXP = ' ' %"
			CASE _cPerg6Sta == 2
				cSTATUS := "% SGMOV010.STATUS_INT = 'S' AND D3_MSEXP <> ' ' %"
			OTHERWISE
				cSTATUS := "% SGMOV010.STATUS_INT = 'E' AND D3_MSEXP <> ' ' %"
		ENDCASE
		
		BeginSQL Alias cAliasT
			SELECT (SUBSTRING(D3_EMISSAO,7,2) + '/' + SUBSTRING(D3_EMISSAO,5,2) + '/' + SUBSTRING(D3_EMISSAO,1,4)) AS EMISSAO,
			D3_MSEXP AS MSEXP, *
					
			FROM SGMOV010 (NOLOCK)
	
			WHERE D3_EMISSAO BETWEEN %Exp:_dPerg2Dta% AND %Exp:_dPerg3Dta%
				AND D3_COD BETWEEN %Exp:_cPerg4Pdt% AND %Exp:_cPerg5Pdt%
				AND SGMOV010.OPERACAO_INT = %Exp:cOPERACAO%
				AND %Exp:cSTATUS%

				//Everson - 24/06/2020. Chamado 058765.
				AND SGMOV010.EMPRESA = %Exp:cEmpAnt%
				//

				AND SGMOV010.D_E_L_E_T_ = ' '
		EndSQL
		
		AADD(aCampos, { "D3_FILIAL", "D3_TM", "D3_COD", "D3_QUANT", "D3_LOCAL", "D3_CC", "EMISSAO", "D3_OP", "D3_NUMSEQ", "D3_CUSTO1", "D3_PARCTOT", "STATUS_INT", "OPERACAO_INT", "R_E_C_N_O_" })
		

	ElseIf nOpc == 3

		DO CASE
			CASE _cPerg6Sta == 1
				cSTATUS := "% B7_MSEXP = ' ' %"
			CASE _cPerg6Sta == 2
				cSTATUS := "% SGINV010.STATUS_INT = 'S' AND B7_MSEXP <> ' ' %"
			OTHERWISE
				cSTATUS := "% SGINV010.STATUS_INT = 'E' AND B7_MSEXP <> ' ' %"
		ENDCASE
		
		BeginSQL Alias cAliasT
			SELECT (SUBSTRING(B7_DATA,7,2) + '/' + SUBSTRING(B7_DATA,5,2) + '/' + SUBSTRING(B7_DATA,1,4)) AS DATA,
			B7_MSEXP AS MSEXP, *
					
			FROM SGINV010 (NOLOCK)
			
			WHERE B7_DATA BETWEEN %Exp:_dPerg2Dta% AND %Exp:_dPerg3Dta%
				AND B7_COD BETWEEN %Exp:_cPerg4Pdt% AND %Exp:_cPerg5Pdt%
				AND SGINV010.OPERACAO_INT = %Exp:cOPERACAO%
				AND %Exp:cSTATUS%

				//Everson - 24/06/2020. Chamado 058765.
				AND SGINV010.EMPRESA = %Exp:cEmpAnt%
				//

				AND SGINV010.D_E_L_E_T_ = ' '
		EndSQL
		
		AADD(aCampos, {"B7_FILIAL", "B7_COD", "B7_QUANT", "B7_LOCAL", "DATA", "B7_DOC", "STATUS_INT", "OPERACAO_INT", "R_E_C_N_O_"})
	EndIf

Return aCampos

/*/{Protheus.doc} ADFIS005PB 
	Funcao para ajustar/atualizar as perguntas no SX1	e as variáveis privates que controlam os valores das perguntas
	 aParam[1]  	:[C] cPerg      - Nome da pergunta relacionada ao fonte no SX1									
	 aParam[2]  	:[A] aPergunte  - Array com as informações do SX1 relacionados as perguntas						
	 lRet[L] - TRUE se não houve nenhum erro e FALSE se não conseguir atualizar no SX1 as perguntas					
	ADFIS005P - Tela para processamento das OP's, Movimentações e Inventários										
	Módulo Ativo Fixo (01)			                          														
	Projeto Bloco K					                          														
	Adoro 					                          		  														
	@type  Static Function
	@author Leonardo Rios
	@since 13/12/2016
	@version 01
/*/
Static Function ADFIS005PB(cPerg,aPergunte)

	Local lRet 	:= .T.
	Local ni	:= 0
		
	Default cPerg		:= {}	/*Descrição do parâmetro conforme cabeçalho*/
	Default aPergunte	:= {}	/*Descrição do parâmetro conforme cabeçalho*/

	/*Gravar variaveis no grupo de perguntas do SX1*/
	__SaveParam(cPerg,@aPergunte)	
	
	/*Reinicializar as perguntas*/
	ResetMVRange()
	
	For ni := 1 to Len(aPergunte)

		/*Inicializar as perguntas c/ array caso existam diferencas, para as validacoes*/
		Do Case
			Case AllTrim(aPergunte[ni][POS_X1OBJ]) == "C"
				aPergunte[ni][POS_X1VAL] := &(aPergunte[ni][POS_X1VAR])
			Otherwise
				&(aPergunte[ni][POS_X1VAR]) := aPergunte[ni][POS_X1VAL]
		EndCase
		
		/*Definir a variavel corrente como sendo o parametro a validar, para aquelas validacoes que utilizar a variavel de campo posicionado*/
		__ReadVar := aPergunte[ni][POS_X1VAR]
		
		/*Executar validacao*/
		If !Eval(&("{|| " + aPergunte[ni][POS_X1VLD] + "}"))
			MsgAlert(cNomeUs + ", inconsistência na pergunta " + StrZero(ni,2) + " (" + StrTran(AllTrim(Capital(aPergunte[ni][POS_X1DES])),"?","") + ")")
			Return !lRet
		Endif

	Next ni
	
	_nPerg1Tip := mv_par01 /* Tabela */
	_dPerg2Dta := mv_par02 /* Período De */ 
	_dPerg3Dta := mv_par03 /* Período Ate */
	_cPerg4Pdt := mv_par04 /* Produto De */
	_cPerg5Pdt := mv_par05 /* Produto Ate */
	_cPerg6Sta := mv_par06 /* Status */
	_cPerg7Ope := mv_par07 /* Tipo de Operação */

Return lRet

/*/{Protheus.doc} ADFIS005PC 
	Funcao para ajustar/atualizar as perguntas no SX1	e as variáveis privates que controlam os valores das perguntas
	aParam[1]  	:[A] aCols   - Array com as informações da tabela SGOPR010 no do grid 1 (Produção)				
	aParam[2]  	:[A] aCols2  - Array com as informações da tabela SGMOV010 no do grid 2 (Movimentos)				
	aParam[3]  	:[A] aCols3  - Array com as informações da tabela SGINV010 no do grid 3 (Inventário)				
	aParam[4]  	:[A] aReqs4  - Array com as informações da tabela SGREQ010 no do grid 1 (Produção)				
	ADFIS005P - Tela para processamento das OP's, Movimentações e Inventários										
	Módulo Ativo Fixo (01)			                          														
	Projeto Bloco K					                          														
	Adoro 					                          		  																		                          		  														
	@type  Static Function
	@author Leonardo Rios
	@since 13/12/2016
	@version 01
/*/
Static Function ADFIS005PC(aCols, aCols2, aCols3, aReqs) /* Os parâmetros desta função devem ser passados por referência */

	Local oWhite	:= LoadBitmap( GetResources(), "BR_BRANCO")	/*Cor para ser usada em valores default dos arrays quando estiverem vazios*/

	/*Array com valores Defaults para criação do cabeçalho da tela de itens OPR devido ao problema do REFRESH da tela não atualizar os itens*/
	Local aDefOPR	:= { { oWhite, .F., "", "", "", "", "", "", "", "", "", "", "", "", "", .T.}	}

	/*Array com valores Defaults para criação do cabeçalho da tela de itens MOV devido ao problema do REFRESH da tela não atualizar os itens*/
	Local aDefMOV	:= { { oWhite, .F., "", "", "", "", "", "", "", "", "", "", "", "", "", "", .T.}	}

	/*Array com valores Defaults para criação do cabeçalho da tela de itens INV devido ao problema do REFRESH da tela não atualizar os itens*/
	Local aDefINV	:= { { oWhite, .F., "", "", "", "", "", "", "", "", "", .T.}	}
		
	Local aINVs		:= {}	/* Valores da tela das informações da SGINV010 */
	Local aMOVs		:= {}	/* Valores da tela das informações da SGMOV010 */
	Local aOPRs		:= {}	/* Valores da tela das informações da SGOPR010 */
	Local aRet 		:= {} 	/* Variável para receber o retorno da função ADFIS005PA() */
	Local aReq		:= {} 	/* Array que receberá os valores das colunas tabela SGREQ010 referente a informação da SGOPR010 */
	Local aReqAux	:= {} 	/* Array que receberá os arrays de valores da tabela SGREQ010 referente a informação da SGOPR010 */
	Local aSGREQ010	:= {}	/* Array que receberá o array da tabela SGREQ010 referente a informação da SGOPR010 */
	Local aValores	:= {} 	/* Variável para receber os valores da query e depois replicar nos arrays de cada tela */

	Local cAliasT

	Local nFORIni	:= 1	/* Variável usada no FOR como valor inicial para dizer qual tabela deverá ser buscado no query */
	Local nFORFim	:= 1	/* Variável usada no FOR como valor final para dizer qual tabela deverá ser buscado no query */

	/*Cores*/
	Local oBlue		:= LoadBitmap( GetResources(), "BR_AZUL")
	Local oGray		:= LoadBitmap( GetResources(), "BR_CINZA")
	Local oGreen   	:= LoadBitmap( GetResources(), "BR_VERDE")
	Local oRed    	:= LoadBitmap( GetResources(), "BR_VERMELHO")

	/*Verifica a condição das perguntas para efetuar a busca na base de dados e preencher na tela*/
	If(_nPerg1Tip == 4)
		nFORIni := 1 
		nFORFim := 3
	Else
		nFORIni := _nPerg1Tip
		nFORFim := _nPerg1Tip
	EndIf

	For nPos:=nFORIni To nFORFim
		
		cAliasT	:= GetNextAlias()
	
		aRet := ADFIS005PA(@cAliasT, nPos) /*Função retornará as colunas que foram pegas na query*/
		
		(cAliasT)->( dbGoTop() )
		
		aValores := {}
		Do While !(cAliasT)->( EOF() )
			
			DO CASE
				CASE EMPTY(ALLTRIM((cAliasT)->MSEXP))
					xCor := oGreen
				CASE (cAliasT)->STATUS_INT == 'S' .AND. !EMPTY(ALLTRIM((cAliasT)->MSEXP))
					xCor := oBlue
				CASE (cAliasT)->STATUS_INT == 'E' .AND. !EMPTY(ALLTRIM((cAliasT)->MSEXP))
					xCor := oRed
				OTHERWISE
					xCor := oGray
			ENDCASE
			
			AADD( aValores, { xCor, .F. } )
			
			For x:=1 To Len(aRet[1])

				If aRet[1,x] == "STATUS_INT"

					DO CASE

						CASE EMPTY(ALLTRIM((cAliasT)->MSEXP))
							AADD( aValores[Len(aValores)], "Integrado" )                 
							
						CASE (cAliasT)->STATUS_INT == 'S' .AND. !EMPTY(ALLTRIM((cAliasT)->MSEXP))
							AADD( aValores[Len(aValores)], "Processado" )
							
						CASE (cAliasT)->STATUS_INT == 'E' .AND. !EMPTY(ALLTRIM((cAliasT)->MSEXP))
							AADD( aValores[Len(aValores)], "Erro" )
							
						OTHERWISE
							AADD( aValores[Len(aValores)], "" )

					ENDCASE
					
				ElseIf aRet[1,x] == "OPERACAO_INT"

					DO CASE

						CASE (cAliasT)->OPERACAO_INT == "I"
							AADD( aValores[Len(aValores)], "Inclusão" )
							
						CASE (cAliasT)->OPERACAO_INT == "A"
							AADD( aValores[Len(aValores)], "Alteração" )
							
						CASE (cAliasT)->OPERACAO_INT == "E"
							AADD( aValores[Len(aValores)], "Exclusão" )
							
						OTHERWISE
							AADD( aValores[Len(aValores)], "" )

					ENDCASE

				Else
					AADD( aValores[Len(aValores)], (cAliasT)->&(aRet[1,x]) )
				EndIf

			Next x
			
			DO CASE

				CASE nPos == 1		/* nPos é será igual ao _nPerg1Tip escolhido na pergunta 1 */
					AADD( aValores[Len(aValores)], .F. )
					
					AADD(aOPRs, aValores[Len(aValores)] )
					
					aReqAux 	:= {}
					lEntrou 	:= .F.
					cAnterior	:= ALLTRIM((cAliasT)->C2_NUM) /* Código da OP anterior */
					While cAnterior == ALLTRIM( SUBSTR((cAliasT)->D3_OP, 1, 6) )
						lEntrou := .T.
						aReq	:= {}
						For x:=1 To Len(aRet[2])
							AADD( aReq, (cAliasT)->&(aRet[2,x]) )
						Next x
						
						AADD(aReqAux, aReq)
						
						cAnterior	:= ALLTRIM((cAliasT)->C2_NUM)
						(cAliasT)->(dbSkip())
					EndDo
					
					AADD(aSGREQ010, aReqAux)
					
					If !lEntrou
						(cAliasT)->(dbSkip())
					EndIf

				CASE nPos == 2
					AADD( aValores[Len(aValores)], .F. )
					
					AADD(aMOVs, aValores[Len(aValores)] )
					
					(cAliasT)->(dbSkip())
					
				CASE nPos == 3
					AADD( aValores[Len(aValores)], .F. )
					
					AADD(aINVs, aValores[Len(aValores)] )
					
					(cAliasT)->(dbSkip())					
			ENDCASE
	
		EndDo
		
		U_FecArTMP(cAliasT)

	Next nPos
		
	/*Caso não retorne nenhum item da query, será preenchido com valores vazios, senão receberá os arrays com os valores*/	
	aCols 	:= IIF(Len(aOPRs) < 1, aDefOPR, aOPRs)
	aCols2	:= IIF(Len(aMOVs) < 1, aDefMOV, aMOVs)
	aCols3	:= IIF(Len(aINVs) < 1, aDefINV, aINVs)
	aReqs	:= IIF(Len(aSGREQ010) < 1, {}, aSGREQ010)
	
	mv_par01 := _nPerg1Tip /* Tabela */
	mv_par02 := _dPerg2Dta /* Período De */ 
	mv_par03 := _dPerg3Dta /* Período Ate */
	mv_par04 := _cPerg4Pdt /* Produto De */
	mv_par05 := _cPerg5Pdt /* Produto Ate */
	mv_par06 := _cPerg6Sta /* Status */
	mv_par07 := _cPerg7Ope /* Tipo de Operação */
	
	_ItensSlec := {{}, {}, {}}

Return Nil

/*/{Protheus.doc} ADFIS005PD 
	Funcao para selecionar todos os itens do grid passado como parâmetro							
	aParam[1]  	:[N] nDelete 	- Posição da coluna para verificar se o item do grid está deletado	
	aParam[2]  	:[A] aDados  	- Array das informações do grid que será processado na função		
	aParam[3]  	:[O] oGrid  	- Objeto do grid que será processado na função						
	aParam[4]  	:[N] nPosIni 	- Número da linha inicial do grid que será processada na função		
	aParam[5]  	:[N] nPosFim 	- Número da linha final do grid que será processada na função		
	aParam[6]  	:[N] nTipo	 	- Número do tipo do Grid sendo processado, sendo 1=OPR; 2=MOV; 3=INV
	ADFIS005P - Tela para processamento das OP's, Movimentações e Inventários						
	Módulo Ativo Fixo (01)			                          										
	Projeto Bloco K					                          										
	Adoro 					                          		  										                          		  																		                          		  														
	@type  Static Function
	@author Leonardo Rios
	@since 14/12/2016
	@version 01
/*/
Static Function ADFIS005PD(nDelete, aDados, oGrid, nPosIni, nPosFim, nTipo) /* Os parâmetros 2 e 3 devem ser passados po referência */

	Local cFirstCond:= ""
	Local cSeconCond:= ""
	Local nLocal	:= 1	/* Variável para controle de inserção na variável _ItensSlec */

	Local oWhite	:= LoadBitmap( GetResources(), "BR_BRANCO")	/*Cor para ser usada em valores default dos arrays quando estiverem vazios*/

	Default nDelete	:= 0 	/*Descrição do parâmetro conforme cabeçalho*/
	Default nPosIni	:= 0 	/*Descrição do parâmetro conforme cabeçalho*/
	Default nPosFim	:= 0 	/*Descrição do parâmetro conforme cabeçalho*/
	Default nTipo	:= 0 	/*Descrição do parâmetro conforme cabeçalho*/


	For nLin := nPosIni To nPosFim

		If !aDados[nLin][nDelete] .AND. aDados[nLin][1] <> oWhite
			aDados[nLin][2] := !aDados[nLin][2]
		EndIf
		
		/*
			Variável _ItensSlec para controle dos itens selecionados pegando suas linhas para facilitar no processamento
		*/
		If Len(_ItensSlec[nTipo]) > 0	/*Se a variável _ItensSlec já tiver sido preenchida eu verifico onde eu devo inserir o novo item selecionado*/
			
			If aDados[nLin][2]	/*Se foi um item selecionado*/
				/*
					Eu insiro na variavél _ItensSlec a posição da linha do item selecionado e deixo tudo de forma crescente no array, então eu verifico
					se o item for maior que o posterior e menor que o interior para poder inserir o item
				*/
				If _ItensSlec[nTipo][Len(_ItensSlec[nTipo])] < nLin  /*Se o último item já for menor do que o selecionado já insiro na última posição */
					AADD(_ItensSlec[nTipo], nLin)
				Else		
                    nLocal := 1
					For x:=1 To Len(_ItensSlec[nTipo])
						If _ItensSlec[nTipo][x] > nLin
							nLocal := x
							Exit
						EndIf
					Next x
					
					AADD(_ItensSlec[nTipo], 0)
					AIns(_ItensSlec[nTipo], nLocal)
					_ItensSlec[nTipo][nLocal] := nLin
				EndIf
				
			Else 	/*Se foi um item deselecionado*/
				
				If _ItensSlec[nTipo][Len(_ItensSlec[nTipo])] == nLin
					ADel(_ItensSlec[nTipo], Len(_ItensSlec[nTipo]))
					ASize(_ItensSlec[nTipo], Len(_ItensSlec[nTipo])-1)				
				Else
					For x:=1 To Len(_ItensSlec[nTipo])
						If _ItensSlec[nTipo][x] == nLin
							ADel(_ItensSlec[nTipo], x)
							ASize(_ItensSlec[nTipo], Len(_ItensSlec[nTipo])-1)
							Exit
						EndIf			
					Next x
				EndIf				
			EndIf
		Else
			AADD(_ItensSlec[nTipo], nLin)
		EndIf
	
	Next x

	/* Forcar a atualizacao do browse */
	oGrid:DrawSelect()

Return Nil

/*/{Protheus.doc} ADFIS005PE 
	Funcao criada para gerar a tela e apresentar as informações da tabela SGREQ010 referente ao item selecionado da tabela 
	SGOPR010(Produções)																				       				 
	aParam[1]  	:[A] aDados     - Array com as informações da tabela SGREQ010 											 
	ADFIS005P - Tela para processamento das OP's, Movimentações e Inventários											
	Módulo Ativo Fixo (01)			                          															 
	Projeto Bloco K					                          															 
	Adoro 					                          		  															 				                          		  										                          		  																		                          		  														
	@type  Static Function
	@author Leonardo Rios
	@since 14/12/2016
	@version 01
/*/
Static Function ADFIS005PE(aDados, nPos)

	Local aValues 	:= {}
	Local oDlg
	Local oTcBrowse

	Default aDados 	:= {}	/*Descrição do parâmetro conforme cabeçalho*/
	Default nPos	:= 0	/*Descrição do parâmetro conforme cabeçalho*/

	If nPos == 0 .OR. nPos > Len(aDados)
		Return
	EndIf
	
	For x:=1 To Len(aDados[nPos])
		AADD(aValues, aDados[nPos, x])
	Next x
	
	DEFINE MSDIALOG oDlg FROM 150,100 TO 550,1300 OF oMainWnd COLOR "W+/W" TITLE OemToAnsi("Tela de Movimentos da OP selecionada") PIXEL
	
		oTcBrowse := TCBrowse():New(000,000,640,260,/*bLine*/,{"D3_FILIAL", "D3_TM", "D3_COD", "D3_QUANT", "D3_LOCAL", "D3_CC", "D3_OP", "D3_NUMSEQ", "CODIGENE", "D3_CUSTO1", "D3_PARCTOT", "D3_EMISSAO", 'R_E_C_N_O_'},/*aColsSpace*/,oDlg,,,,/*bChange*/,/*bLDblClick*/,/*bRClick*/,/*oFont*/,,,,,,,.T.,/*bWhen*/,,/*bValid*/,.T.,.T.)
		oTcBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oTcBrowse:SetArray(aValues)
		oTcBrowse:bLine := {|| {aValues[oTcBrowse:nAt,1], aValues[oTcBrowse:nAt,2], aValues[oTcBrowse:nAt,3], aValues[oTcBrowse:nAt,4], aValues[oTcBrowse:nAt,5], aValues[oTcBrowse:nAt,6], aValues[oTcBrowse:nAt,7], aValues[oTcBrowse:nAt,8], aValues[oTcBrowse:nAt,9], aValues[oTcBrowse:nAt,10], aValues[oTcBrowse:nAt,11], aValues[oTcBrowse:nAt,12], aValues[oTcBrowse:nAt,15] } }
		oTcBrowse:GoTop()
		oTcBrowse:SetFocus()
		
	ACTIVATE MSDIALOG oDlg CENTERED

Return Nil

/*/{Protheus.doc} ADFIS005PF 
	Função criada para o processamento(Inserção, alteração, exclusão) dos itens selecionados	
	aParam[1]  	:[A] aCols   - Array com as informações da tabela SGOPR010 no do grid 1 (Produção)
	aParam[2]  	:[A] aCols2  - Array com as informações da tabela SGMOV010 no do grid 2 (Movimentos)
	aParam[3]  	:[A] aCols3  - Array com as informações da tabela SGINV010 no do grid 3 (Inventário)
	aParam[4]  	:[N] nTipo   - Tipo de Processamento, sendo 1=OPR; 2=MOV; 3=INV; 4=TODOS		
	aParam[5]  	:[L] lEstorno- Indica se o processamento é de estorno(.T.) ou não(.F.)			
	aParam[6]  	:[A] aReqs   - Array com as informações das requisições de uma determinada OP	
	ADFIS005P - Tela para processamento das OP's, Movimentações e Inventários					
	Módulo Ativo Fixo (01)			                          									
	Projeto Bloco K					                          									
	Adoro 					                          		  														                          		  															 				                          		  										                          		  																		                          		  														
	@type  Static Function
	@author Leonardo Rios
	@since 19/12/2016
	@version 01
/*/
Static Function ADFIS005PF(aCols, aCols2, aCols3, nTipo, lEstorno) /* Os parâmetros desta função devem ser passados por referência */

	Local nIni		:= IIF(nTipo == 4, 1, nTipo)
	Local nFim		:= IIF(nTipo == 4, 3, nTipo)
	Local lRet		:= .F.
	Local cMsg		:= ""
	Local cMsgLog	:= ""
	Local cTabela 	:= ""
	Local nRecDelet	:= 0

	Default nTipo 	:= 4	/*Descrição do parâmetro conforme cabeçalho*/
	Default lEstorno:= .F.	/*Descrição do parâmetro conforme cabeçalho*/

	Private _MsgMotivo := ""
	
		For y:=nIni To nFim

			For x:=1 To Len(_ItensSlec[y])
			
				DO CASE				

					CASE nTipo == 1
					
					 	cMsg := "FILIAL=" + ALLTRIM(aCols[_ItensSlec[y][x]][03]) + "; PRODUTO=" + ALLTRIM(aCols[_ItensSlec[y][x]][04]) +; 
					 			"; NUM=" + ALLTRIM(aCols[_ItensSlec[y][x]][09]) + "; QUANTIDADE=" + ALLTRIM( STR(aCols[_ItensSlec[y][x]][05]) ) +;
					 			"; EMISSAO=" + ALLTRIM( DTOC(CTOD(aCols[_ItensSlec[y][x]][08])) ) + "; " + "MOTIVO="
						
						cTabela := "SGOPR010"
						nRecDelet	:= aCols[_ItensSlec[y][x]][15]

						/* 
										3			  4		 		5			6		  7		  	8		 9			 10		    11			12				13				14			  15
							aCols = "C2_FILIAL", "C2_PRODUTO", "C2_QUANT", "C2_LOCAL", "C2_CC", "EMISSAO", "C2_NUM", "C2_ITEM", "C2_SEQUEN", "C2_REVISAO", "STATUS_INT", "OPERACAO_INT", "R_E_C_N_O_" 
						*/
						
						lRet := U_ADFIS015P( 	aCols[_ItensSlec[y][x]][03] 					,; 
												aCols[_ItensSlec[y][x]][03]    					,;
												.F.												,; 
												{;
													DTOS(CTOD(aCols[_ItensSlec[y][x]][08])),; 
													DTOS(CTOD(aCols[_ItensSlec[y][x]][08]));
												}												,; 
												{;
												 	aCols[_ItensSlec[y][x]][03],;
													aCols[_ItensSlec[y][x]][04],;
													aCols[_ItensSlec[y][x]][05],;
													aCols[_ItensSlec[y][x]][06],;
													aCols[_ItensSlec[y][x]][07],;
													aCols[_ItensSlec[y][x]][08],;
													aCols[_ItensSlec[y][x]][09],;
													aCols[_ItensSlec[y][x]][10],;
													aCols[_ItensSlec[y][x]][11],;
													aCols[_ItensSlec[y][x]][12],;
													aCols[_ItensSlec[y][x]][13],;
													aCols[_ItensSlec[y][x]][14];
												}												,;
												 lEstorno				 		   			    	)
					
					CASE nTipo == 2
												
						cMsg := "FILIAL=" + ALLTRIM(aCols2[_ItensSlec[y][x]][03]) + "; PRODUTO=" + ALLTRIM(aCols2[_ItensSlec[y][x]][05]) +; 
					 			"; QUANTIDADE=" + ALLTRIM( STR(aCols2[_ItensSlec[y][x]][06]) ) +;
					 			"; EMISSAO=" + ALLTRIM( DTOC(CTOD(aCols2[_ItensSlec[y][x]][09])) ) + "; " + "MOTIVO="

						cTabela := "SGMOV010"
						nRecDelet	:= aCols2[_ItensSlec[y][x]][16]

						/*
										3			4		 5			6			7		   8		 9		  10	     11			  12			13			14			 	15			  16	
							aCols = "D3_FILIAL", "D3_TM", "D3_COD", "D3_QUANT", "D3_LOCAL", "D3_CC", "EMISSAO", "D3_OP", "D3_NUMSEQ", "D3_CUSTO1", "D3_PARCTOT", "STATUS_INT", "OPERACAO_INT", "R_E_C_N_O_"  
						*/
						If lEstorno .OR. aCols2[_ItensSlec[y][x]][15] == "E"

							lRet := U_ADFIS008P(	aCols2[_ItensSlec[y][x]][03] 	,; 
													aCols2[_ItensSlec[y][x]][03]	,;										
													{aCols2[_ItensSlec[y][x]][03]	,;
													 aCols2[_ItensSlec[y][x]][04]	,;
													 aCols2[_ItensSlec[y][x]][05]	,;
													 aCols2[_ItensSlec[y][x]][06]	,;
													 aCols2[_ItensSlec[y][x]][07]	,;
													 aCols2[_ItensSlec[y][x]][08]	,;
													 aCols2[_ItensSlec[y][x]][09]	,;
													 ""							 	,;	//ANTIGO CAMPO USADO D3_RECORI DA BASE INTERMEDIÁRIA
													 aCols2[_ItensSlec[y][x]][10]	,;
													 aCols2[_ItensSlec[y][x]][11]	,;
													 ""							 	,;	//ANTIGO CAMPO USADO D3_RECORI DA BASE INTERMEDIÁRIA
													 aCols2[_ItensSlec[y][x]][13]	,;
 													 aCols2[_ItensSlec[y][x]][14]	,;
													 aCols2[_ItensSlec[y][x]][16]}	,;
													 lEstorno							)
						Else

							lRet := U_ADFIS007P( 	aCols2[_ItensSlec[y][x]][03] 	,; 
													aCols2[_ItensSlec[y][x]][03]	,;										
													{aCols2[_ItensSlec[y][x]][03],;
													 aCols2[_ItensSlec[y][x]][04],;
													 aCols2[_ItensSlec[y][x]][05],;
													 aCols2[_ItensSlec[y][x]][06],;
													 aCols2[_ItensSlec[y][x]][07],;
													 aCols2[_ItensSlec[y][x]][08],;
													 aCols2[_ItensSlec[y][x]][09],;
													 ""							 ,;	//ANTIGO CAMPO USADO D3_RECORI DA BASE INTERMEDIÁRIA
													 aCols2[_ItensSlec[y][x]][10],;
													 aCols2[_ItensSlec[y][x]][11],;
													 ""							 ,; //ANTIGO CAMPO USADO D3_RECORI DA BASE INTERMEDIÁRIA
													 aCols2[_ItensSlec[y][x]][13],;
													 aCols2[_ItensSlec[y][x]][14]}		)
						EndIf
					
					CASE nTipo == 3
						
						cMsg := "FILIAL=" + ALLTRIM(aCols3[_ItensSlec[y][x]][03]) + "; PRODUTO=" + ALLTRIM(aCols3[_ItensSlec[y][x]][04]) +; 
					 			"; LOCAL=" + ALLTRIM(aCols3[_ItensSlec[y][x]][06]) + "; QUANTIDADE=" + ALLTRIM( STR(aCols3[_ItensSlec[y][x]][05]) ) +;
					 			"; DATA=" + ALLTRIM( DTOC(CTOD(aCols3[_ItensSlec[y][x]][07])) ) + "; " + "MOTIVO="						
						
						cTabela 	:= "SGINV010"
						nRecDelet	:= aCols3[_ItensSlec[y][x]][11]

						/*
										3			 4			5			6		 7		  8 		   9			 10				11
							aCols = "B7_FILIAL", "B7_COD", "B7_QUANT", "B7_LOCAL", "DATA", "B7_DOC", "STATUS_INT", "OPERACAO_INT", "R_E_C_N_O_"  
						*/
						If lEstorno .OR. aCols3[_ItensSlec[y][x]][10] == "E"
						
							lRet := U_ADFIS009P( 	aCols3[_ItensSlec[y][x]][03]	,; 
													aCols3[_ItensSlec[y][x]][03]	,;
													{aCols3[_ItensSlec[y][x]][03],;
													 aCols3[_ItensSlec[y][x]][04],;
													 aCols3[_ItensSlec[y][x]][05],;
													 aCols3[_ItensSlec[y][x]][06],;
													 aCols3[_ItensSlec[y][x]][07],;									 
													 aCols3[_ItensSlec[y][x]][08]}	,;
													 5								,;
													 lEstorno							)
						Else

							lRet := U_ADFIS009P( 	aCols3[_ItensSlec[y][x]][03]	,; 
													aCols3[_ItensSlec[y][x]][03]	,;
													{aCols3[_ItensSlec[y][x]][03],;
													 aCols3[_ItensSlec[y][x]][04],;
													 aCols3[_ItensSlec[y][x]][05],;
													 aCols3[_ItensSlec[y][x]][06],;
													 aCols3[_ItensSlec[y][x]][07],;									 
													 aCols3[_ItensSlec[y][x]][08]}		)
						EndIf
						
				ENDCASE
				
				If !lRet
					cMsgLog += " - Problema no " + IIF(lEstorno, "estorno", "processamento") + " do item: " + cMsg + _MsgMotivo + CHR(13) + CHR(10)
				Else
					If lEstorno
						TcSqlExec("UPDATE " + cTabela + " SET STATUS_INT=' ', OPERACAO_INT='A', D_E_L_E_T_='*' WHERE EMPRESA = '" + cValToChar(cEmpAnt) + "' AND R_E_C_N_O_ = " + ALLTRIM( STR(nRecDelet) ) ) //Everson - 24/06/2020. Chamado 058765.

						If ALLTRIM(cTabela) == "SGOPR010"
							TcSqlExec("UPDATE SGREQ010 SET STATUS_INT=' ', OPERACAO_INT='A', D_E_L_E_T_='*' WHERE EMPRESA = '" + cValToChar(cEmpAnt) + "' AND D3_OP = '" + aCols[_ItensSlec[y][x]][09] + aCols[_ItensSlec[y][x]][10] + aCols[_ItensSlec[y][x]][11] + "' AND D_E_L_E_T_=' ' " ) //Everson - 24/06/2020. Chamado 058765.
						EndIf
					EndIf
				EndIf
				
			Next x

		Next y
		
		If !EMPTY( ALLTRIM(cMsgLog) )			
			U_ExTelaMen( IIF(lEstorno, "Estorno dos itens", "Processamento dos itens"), cMsgLog, "Arial", 10,, .F., .T. )
		EndIf
		
Return .T.

/*/{Protheus.doc} ADFIS005PG 
	Função criada para atualizar o painel de botões após ter feito uma nova pesquisa no primeiro painel				
	aParam[1]  	:[A] aCols   	- Array com as informações da tabela SGOPR010 no do grid 1 (Produção)					
	aParam[2]  	:[A] aCols2  	- Array com as informações da tabela SGMOV010 no do grid 2 (Movimentos)				
	aParam[3]  	:[A] aCols3  	- Array com as informações da tabela SGINV010 no do grid 3 (Inventário)				
	aParam[4]  	:[A] aReqs   	- Array com as informações da tabela SGREQ010 no do grid 3 (Requisições)				
	aParam[5]  	:[B] bAtGD   	- Bloco de código executado para atualizar o grid das OPRs no painel 2				
	aParam[6]  	:[B] bAtGD2  	- Bloco de código executado para atualizar o grid das MOVs no painel 2				
	aParam[7]  	:[B] bAtGD3  	- Bloco de código executado para atualizar o grid das INVs no painel 2				
	aParam[8]  	:[O] oArea  	- Objeto utilizado para a Area 1 do painel 3 dos botões de processamento das OPRs	
	aParam[9]  	:[O] oArea2 	- Objeto utilizado para a Area 2 do painel 3 dos botões de processamento das MOVs	
	aParam[10]  	:[O] oArea3 	- Objeto utilizado para a Area 3 do painel 3 dos botões de processamento das INVs
	aParam[11]  	:[O] oPainel03 	- Objeto utilizado para o painel 3 dos itens OPRs e REQs da tela de Processamento
	aParam[12]  	:[O] oPainel203	- Objeto utilizado para o painel 3 dos itens MOVs da tela de Processamento		
	aParam[13]  	:[O] oPainel303	- Objeto utilizado para o painel 3 dos itens INVs da tela de Processamento		
	ADFIS005P - Tela para processamento das OP's, Movimentações e Inventários										
	Módulo Ativo Fixo (01)			                          														
	Projeto Bloco K					                          														
	Adoro 					                          		  																			                          		  														                          		  															 				                          		  										                          		  																		                          		  														
	@type  Static Function
	@author Leonardo Rios
	@since 04/04/2017
	@version 01
/*/
Static Function ADFIS005PG(aCols, aCols2, aCols3, aReqs, bAtGd, bAtGd2, bAtGd3, oArea, oArea2, oArea3, oPainel03, oPainel203, oPainel303)

	Default oPainel03		:= Nil	/*Descrição do parâmetro conforme cabeçalho*/
	Default oPainel203		:= Nil	/*Descrição do parâmetro conforme cabeçalho*/
	Default oPainel303		:= Nil	/*Descrição do parâmetro conforme cabeçalho*/
		
	//	/*Pega a área para criar o panel dos botões de processamento*/
	oPainel03:Refresh()
	oPainel203:Refresh()
	oPainel303:Refresh()
	
	_oBtn3Pnl1:Show()
	
	If _cPerg6Sta == 1

		_oBtn1Pnl1:Show()
		_oBtn1Pnl2:Show()
		_oBtn1Pnl3:Show()
		
		_oBtn2Pnl1:Hide()
		_oBtn2Pnl2:Hide()
		_oBtn2Pnl3:Hide()

		_oBtn4Pnl1:Show()
		_oBtn3Pnl2:Show()
		_oBtn3Pnl3:Show()

		
	ElseIf _cPerg6Sta == 2 

		_oBtn4Pnl1:Hide()
		_oBtn3Pnl2:Hide()
		_oBtn3Pnl3:Hide()

		If _cPerg7Ope <> 3
			_oBtn1Pnl1:Hide()
			_oBtn1Pnl2:Hide()
			_oBtn1Pnl3:Hide()
		
			_oBtn2Pnl1:Show()
			_oBtn2Pnl2:Show()
			_oBtn2Pnl3:Show()
		Else
			_oBtn1Pnl1:Hide()
			_oBtn1Pnl2:Hide()
			_oBtn1Pnl3:Hide()
			
			_oBtn2Pnl1:Hide()
			_oBtn2Pnl2:Hide()
			_oBtn2Pnl3:Hide()
		EndIf
		
	ElseIf _cPerg6Sta == 3
		
		If _cPerg7Ope <> 3
			_oBtn1Pnl1:Show()
			_oBtn1Pnl2:Show()
			_oBtn1Pnl3:Show()
			
			_oBtn2Pnl1:Show()
			_oBtn2Pnl2:Show()
			_oBtn2Pnl3:Show()
		EndIf
		
	EndIf
	
	oPainel03:Refresh()
	oPainel203:Refresh()
	oPainel303:Refresh()

Return Nil

/*/{Protheus.doc} ADFIS005PH 
	Função criada para limpar a base de dados excluindo todos os campos que estejam com status igual 
	ADFIS005P - Tela para processamento das OP's, Movimentações e Inventários										
	Módulo Ativo Fixo (01)			                          														
	Projeto Bloco K					                          														
	Adoro 					                          		  																			                          		  																			                          		  														                          		  															 				                          		  										                          		  																		                          		  														
	@type  Static Function
	@author Leonardo Rios
	@since 04/04/2017
	@version 01
/*/
Static Function ADFIS005PH(nTipo, aCols, aCols2, aCols3)

	Local nIni		:= IIF(nTipo == 4, 1, nTipo)
	Local nFim		:= IIF(nTipo == 4, 3, nTipo)

	Default nTipo 	:= 4	/*Descrição do parâmetro conforme cabeçalho*/

	For y:=nIni To nFim

		For x:=1 To Len(_ItensSlec[y])

			If nTipo == 1
				
				//tcSqlExec("UPDATE SGOPR010 SET D_E_L_E_T_='*', OPERACAO_INT='A', STATUS_INT=' ' WHERE  EMPRESA = '" + cValToChar(cEmpAnt) + "' AND C2_MSEXP = ' ' OR STATUS_INT = 'E' AND R_E_C_N_O_= '" + ALLTRIM( STR(aCols[_ItensSlec[y][x]][15])) + "' ") //Everson - 24/06/2020. Chamado 058765.
				tcSqlExec("UPDATE SGOPR010 SET D_E_L_E_T_='*', OPERACAO_INT='A', STATUS_INT=' ' WHERE  R_E_C_N_O_= '" + ALLTRIM( STR(aCols[_ItensSlec[y][x]][15])) + "' ") // @history Fernando Macieira, 27/09/2021, Ticket 29741   - Divergencia ao limpar dados de ordens integradas do SAG
				tcSqlExec("UPDATE SGREQ010 SET D_E_L_E_T_='*', OPERACAO_INT='A', STATUS_INT=' ' WHERE  EMPRESA = '" + cValToChar(cEmpAnt) + "' AND D3_OP = '" + aCols[_ItensSlec[y][x]][09] + aCols[_ItensSlec[y][x]][10] + aCols[_ItensSlec[y][x]][11] + "' AND D_E_L_E_T_=' ' " )
							
			ElseIf nTipo == 2				

				//tcSqlExec("UPDATE SGMOV010 SET D_E_L_E_T_='*', OPERACAO_INT='A', STATUS_INT=' ' WHERE  EMPRESA = '" + cValToChar(cEmpAnt) + "' AND D3_MSEXP = ' ' OR STATUS_INT = 'E' AND R_E_C_N_O_= '" + ALLTRIM( STR(aCols2[_ItensSlec[y][x]][16])) + "' ") //Everson - 24/06/2020. Chamado 058765.
				tcSqlExec("UPDATE SGMOV010 SET D_E_L_E_T_='*', OPERACAO_INT='A', STATUS_INT=' ' WHERE R_E_C_N_O_= '" + ALLTRIM( STR(aCols2[_ItensSlec[y][x]][16])) + "' ") // @history Fernando Macieira, 27/09/2021, Ticket 29741   - Divergencia ao limpar dados de ordens integradas do SAG
			
			ElseIf nTipo == 3				

				//tcSqlExec("UPDATE SGINV010 SET D_E_L_E_T_='*', OPERACAO_INT='A', STATUS_INT=' ' WHERE  EMPRESA = '" + cValToChar(cEmpAnt) + "' AND B7_MSEXP = ' ' OR STATUS_INT = 'E' AND R_E_C_N_O_= '" + ALLTRIM( STR(aCols3[_ItensSlec[y][x]][11])) + "' ") //Everson - 24/06/2020. Chamado 058765.
				tcSqlExec("UPDATE SGINV010 SET D_E_L_E_T_='*', OPERACAO_INT='A', STATUS_INT=' ' WHERE  R_E_C_N_O_= '" + ALLTRIM( STR(aCols3[_ItensSlec[y][x]][11])) + "' ") // @history Fernando Macieira, 27/09/2021, Ticket 29741   - Divergencia ao limpar dados de ordens integradas do SAG
			
			EndIf

		Next x

	Next y
	
Return .T.

/*/{Protheus.doc} Legenda 
	Legenda das cores															
	ADFIS005P - Tela para processamento das OP's, Movimentações e Inventários
	Módulo Ativo Fixo (01)			                          				
	Projeto Bloco K					                          				
	Adoro 					                          		  							                          		  																			                          		  																			                          		  														                          		  															 				                          		  										                          		  																		                          		  														
	@type  Static Function
	@author Leonardo Rios
	@since 19/12/2016
	@version 01
	/*/
Static Function Legenda()

	Local aLegenda := {}
    
    AADD(aLegenda,{"BR_VERDE"   	,"Integrado" 		}) 
    AADD(aLegenda,{"BR_AZUL"    	,"Processado" 		})
    AADD(aLegenda,{"BR_VERMELHO"	,"Erro" 			})
    AADD(aLegenda,{"BR_CINZA"   	,"Status Indefinido"})
    
    BrwLegenda("Legenda", "Legenda", aLegenda)

Return Nil

/*/{Protheus.doc} Legenda 
	Funcao genérica criada para gerar as perguntas no Protheus que serão apresentadas na tela	
	aParam[1]  	:[C] cPerg     - String contendo o título chave da pergunta que será criada	
	ADFIS005P - Tela para processamento das OP's, Movimentações e Inventários				
	Módulo Ativo Fixo (01)			                          								
	Projeto Bloco K					                          								
	Adoro 					                          		  													                          		  							                          		  																			                          		  																			                          		  														                          		  															 				                          		  										                          		  																		                          		  														
	@type  Static Function
	@author Leonardo Rios
	@since 19/12/2016
	@version 01
	/*/
Static Function AjustaSX1(cPerg)

	Local aMensSX1 := {}

	Default cPerg := ""	/*Descrição do parâmetro conforme cabeçalho*/

	//					  1				2						3						4				  5			6						  7	 8		  9   10	 11	   		12  		13	  	  	  14  	  15  	 16  	 		17   	  		18   	  	  19  	  20  21  	  	  22  	  	 23  	  	  24  25  26  		27  	28  	  29  30  31  32  33  34  35      36   37  38  39	
    AADD( aMensSX1, {"01", "Tipo?"				, "Tipo?"				, "Tipo?"					,"N"	,001						,00, 0		,"C", ""	,"OPR"		,"OPR" 		,"OPR"		, ""	, ""	, "MOV"			, "MOV" 	 , "MOV"		, ""	, "", "INV"		, "INV"		, "INV" 	, "", "", "Todos", "Todos", "Todos"	, "", "", "", "", "", "", ""    , "S", "", "", "" })
    AADD( aMensSX1, {"02", "Período De?"		, "Período De?"			, "Período De?"				,"D"	,008						,00, 0		,"G", ""	,""			,""			,"" 		, ""	, ""	, ""			, "" 		 , "" 			, ""	, "", ""		, ""		, ""		, "", "", ""	 , ""	  , ""		, "", "", "", "", "", "", ""    , "S", "", "", "" })
	AADD( aMensSX1, {"03", "Período Ate?"		, "Período Ate?"		, "Período Ate?"	    	,"D"	,008						,00, 0		,"G", ""	,""			,""			,""			, ""	, ""	, ""			, "" 		 , "" 			, ""	, "", ""		, ""		, ""		, "", "", ""	 , ""	  , ""		, "", "", "", "", "", "", ""    , "S", "", "", "" })
	AADD( aMensSX1, {"04", "Produto De?"		, "Produto De?"	    	, "Produto De?"		   		,"C"	,TamSX3("B1_COD")[1]		,00, 0		,"G", ""	,""			,""			,"" 		, ""	, ""	, ""			, "" 		 , "" 			, ""	, "", ""		, ""		, ""		, "", "", ""	 , ""	  , ""		, "", "", "", "", "", "", "SB1" , "S", "", "", "" })
	AADD( aMensSX1, {"05", "Produto Ate?"		, "Produto Ate?"		, "Produto Ate?"			,"C"	,TamSX3("B1_COD")[1]		,00, 0		,"G", ""	,""			,""			,"" 		, ""	, ""	, ""			, "" 	 	 , "" 			, ""	, "", ""		, ""		, ""		, "", "", ""	 , ""	  , ""		, "", "", "", "", "", "", "SB1" , "S", "", "", "" })
	AADD( aMensSX1, {"06", "Status?"			, "Status?"				, "Status?"	    			,"C"	,001						,00, 0		,"C", ""	,"Integrado","Integrado","Integrado", ""	, ""	, "Processado" 	,"Processado", "Processado"	, ""	, "", "Erro"	, "Erro"	, "Erro"	, "", "", ""	 , ""	  , ""		, "", "", "", "", "", "", ""    , "S", "", "", "" })
	AADD( aMensSX1, {"07", "Operação?"			, "Operação?"			, "Lista Cálculo ?"	    	,"C"	,001						,00, 0		,"C", ""	,"Inclusão"	,"Inclusão"	,"Inclusão"	, ""	, ""	, "Alteração" 	,"Alteração" , "Alteração"	, ""	, "", "Exclusão", "Exclusão", "Exclusão", "", "", ""	 , ""	  , ""		, "", "", "", "", "", "", ""    , "S", "", "", "" })
	
    U_newGrSX1(cPerg, aMensSX1)	

Return Nil
