#include 'protheus.ch'
#include 'parmtype.ch'

//Largura das colunas FWLayer
#DEFINE LRG_COL01		80
#DEFINE LRG_COL02		20

Static nDistPad	:= 002
Static nAltBot	:= 013
Static cHK		:= "&"

/*/{Protheus.doc} User function ADEST018P()
	Função criada para apresentar uma tela para preenchimento das informações que serão utilizadas no processamento do  ajuste
	de consumo de massa de frango para produtos sem faturamento
	@type  Function
	@author Leonardo Rios
	@since 26/10/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 057910 - FWNM - 18/06/2020 - || OS 059411 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || PROJETO UEP
/*/
User function ADEST018P()

	Local oDlg	/*Objeto usado para o MSDIALOG*/
	Local lAtivo     := GetMV("MV_#UEPLIG",,.T.)
	Local lTravaOn   := GetMV("MV_#UEPKFS",,.F.)

	Private _cPerg	:= "ADEST018P"	/*Nome da pergunta usado nas telas*/

    // Chamado n. 057910 || OS 059411 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || PROJETO UEP - FWNM - 18/06/2020
	// Chego se o valor UPS do sistema UEP está ativo para ser utilizado
    If lTravaOn
		If lAtivo
			msgAlert("Função para agregar valor UPS do sistema UEP aos movimentos do Protheus está ativada como rotina principal para uso! Contate a contabilidade...","Parâmetro: MV_#UEPLIG")
			Return
		EndIf
	EndIf
	//

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Função criada para apresentar uma tela para preenchimento das informações que serão utilizadas no processamento do  ajuste de consumo de massa de frango para produtos sem faturamento')

	AjustaSX1(_cPerg)
	Pergunte(_cPerg, .F.)
	
	DEFINE MSDIALOG oDlg FROM  96,9 TO 320,612 TITLE OemToAnsi("Massa de Frango") PIXEL
		@ 16, 15 SAY OemToAnsi("Este programa efetua o ajuste do consumo de massa de frango para itens sem faturamento.") SIZE 268, 8 OF oDlg PIXEL			   									
		
		DEFINE SBUTTON FROM 93, 163 TYPE 15 ACTION ProcLogView(cFilAnt, _cPerg) ENABLE OF oDlg
		DEFINE SBUTTON FROM 93, 193 TYPE 5  ACTION Pergunte(_cPerg, .T.) ENABLE OF oDlg
		DEFINE SBUTTON FROM 93, 223 TYPE 1  ACTION If(.T., ( Processa( {|lEnd| ADEST018G()}, OemToAnsi("Cálcula o ajusta do consumo"), OemToAnsi("Efetuando o cálculo do ajuste..."), .F.), oDlg:End() ), ) ENABLE OF oDlg
		DEFINE SBUTTON FROM 93, 253 TYPE 2  ACTION oDlg:End() ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED 
	
Return

/*/{Protheus.doc} User function ADEST018P()
	Função criada para apresentar uma tela para preenchimento das informações que serão utilizadas no processamento do  ajuste
	de consumo de massa de frango para produtos sem faturamento
	@type  Function
	@author Leonardo Rios
	@since 26/10/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 057910 - FWNM - 18/06/2020 - || OS 059411 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || PROJETO UEP
/*/
Static function ADEST018G()

	Local cAlias 	:= GetNextAlias()
	Local dDtFecha	:= SuperGetMV("MV_ULMES")	/*Data do último fechamento do estoque.*/
	Local oDlg	/*Objeto usado para o MSDIALOG*/
	Local nSomaTotal:= 0
	Local nSomaQuant:= 0
	Local nCustoVivo:= 0

	Private _aDados 	:= {}	/*Array usado no SetBlock do relatório para receber as informações e preencher o relatório*/
	Private _aSelecIte	:= {} 

	Private _cCodMassa	:= SuperGetMV("MV_XCODMAS", .F., "323574")	/*Código da estrutura de massa usado nas condições de busca dos produtos*/
	Private _cFrangPad	:= SuperGetMV("MV_XPRDFV", .F., "")	/*Código do Produto Frango Vivo pega pegar o Custo Médio dele na filial 03*/
	Private _cMens	:= "" /*Variável usada para gerar as mensagens do Log*/

	Private _nPrecoMed 	:= 0	/*Valor do Preço Médio de Venda encontrado no cálculo feito das informações retornadas da query*/		
	Private _nPrecoCus 	:= 0	/*Valor do Preço de Custo encontrado no cálculo feito dos valores da pergunta e o Preço Médio de Venda*/
	Private _nPrcVenda	:= 0
	Private _nFator		:= 0	/*Valor do Fator encontrado no cálculo feito entre o Preço de Custo e o Preço Médio de Venda*/

	ProcLogIni( {},"ADEDA009P")
	ProcLogAtu("INICIO")
	_cMens += "Empresa: " + cEmpAnt + CRLF
	_cMens += "Módulo: " + cModulo + CRLF
	_cMens += "Filial: " + cFilAnt + CRLF
	_cMens += "Usuário/Código: " + cUserName + "/" + __cUserId + CRLF
	_cMens += "Computer Name: " + GetComputerName() + CRLF + CRLF	
	
	_cMens += "Parâmetros das perguntas:" + CRLF
	_cMens += "Mês de referência: " + DTOC(mv_par01) + CRLF
	_cMens += "Custo de Quebra: " + STR(mv_par02) + CRLF
	_cMens += "Custo de Abate: " + STR(mv_par03) + CRLF
	_cMens += "Código da estrutura de massa(MV_XCODMAS): " + _cCodMassa + CRLF
	_cMens += "Código do Produto Frango Vivo para Custo Médio na filial 03(MV_XPRDFV): " + _cFrangPad + CRLF + CRLF
	

	/*Trava de segurança para não permitir processar algo menor que a data do parametro MV_ULMES*/
	If mv_par01 <= dDtFecha
		Alert("Não é permitido selecionar uma data menor ou igual a data do ultimo fechamento do estoque")
		_cMens += "Não é permitido selecionar uma data menor ou igual a data do ultimo fechamento do estoque" + CRLF
		_cMens += "Return" + CRLF
		Return
	EndIf

	/* Query usada para pegar todos os produtos de várzea que possuem estrutura de produtos, e também, possuem o produto ZMASSA em sua estrutura.
	   Nesta busca será avaliado os produtos dos últimos três meses levando em consideração o mês vigente escolhido na pergunta.*/
	BeginSql Alias cAlias
		
		SELECT SUM(D2_QUANT) AS D2_QUANT, SUM(D2_QTDEDEV) AS D2_QTDEDEV, SUM(D2_TOTAL) AS D2_TOTAL, SUM(D2_VALDEV) AS D2_VALDEV

		FROM %table:SB1% SB1 (NOLOCK), %table:SG1% SG1 (NOLOCK), %table:SD2% SD2 (NOLOCK), %table:SA1% SA1 (NOLOCK), %table:SF4% SF4 (NOLOCK)
		
		WHERE SB1.%notDel% AND SG1.%notDel% AND SD2.%notDel% AND SA1.%notDel% AND SF4.%notDel%
			AND D2_EMISSAO BETWEEN %Exp:DTOS(FIRSTDATE(MONTHSUB(mv_par01, 2)))% AND %Exp:DTOS(LASTDATE(mv_par01))%
			AND D2_FILIAL = %xfilial:SD2%
			AND B1_COD = D2_COD
			AND B1_COD = G1_COD
			AND B1_COD BETWEEN %Exp:mv_par04% AND %Exp:mv_par05%
			AND G1_COMP = %Exp:_cCodMassa%
			AND G1_FILIAL = %xfilial:SG1%
			AND A1_COD = D2_CLIENTE
			AND A1_LOJA = D2_LOJA
			AND F4_CODIGO = D2_TES
			AND F4_DUPLIC = 'S'
		
		GROUP BY D2_COD, B1_DESC
		
		ORDER BY D2_COD

	EndSql
	
	DbSelectArea(cAlias)
	Dbgotop()
	
	ProcRegua((cAlias)->(RecCount()))
	
	_cMens += "Calculando o Preço Médio das notas de saída retornadas da busca." + CRLF
	
	(cAlias)->(Dbgotop())
	
	IncProc("Buscando as informações..")
	nSomaQuant := 0
	nSomaTotal := 0
	While !(cAlias)->(EOF())
		IncProc("Somando quantidade e total dos produtos")		

		nSomaQuant += ((cAlias)->D2_QUANT - (cAlias)->D2_QTDEDEV)
		nSomaTotal += ((cAlias)->D2_TOTAL - (cAlias)->D2_VALDEV)

		(cAlias)->(DbSkip())
	EndDo

	DbSelectArea(cAlias)
	dbCloseArea()
	
	/*Cálculo do Preço Médio Geral das Vendas*/
	_nPrecoMed 	:= nSomaTotal / nSomaQuant
	nCustoVivo	:= ADEST018H() 
	
	// *** INICIO CHAMADO WILLIAM COSTA 22/06/2018 - 042130 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || MASSA DE FRANGO *** //
	BeginSql Alias cAlias
	
		 SELECT D2_FILIAL,
		        D2_COD, 
		        SUM(D2_QUANT) AS D2_QUANT, 
			    SUM(D1_QUANT) AS D1_QUANT
		   FROM %table:SG1% SG1 (NOLOCK),%table:SF4% SF4 (NOLOCK),%table:SD2% SD2 (NOLOCK)
		   INNER JOIN %table:SD1% SD1 (NOLOCK)
		           ON D1_FILIAL = %xFilial:SD1%
		          AND D1_EMISSAO BETWEEN %Exp:DTOS(FIRSTDATE(MONTHSUB(mv_par01, 2)))% AND %Exp:DTOS(LASTDATE(mv_par01))%
				  AND D1_TIPO   = 'D'
				  AND D1_COD    = D2_COD
				  AND SD1.D_E_L_E_T_ <> '*'
		        WHERE D2_FILIAL       = %xFilial:SD2%
			      AND D2_EMISSAO BETWEEN %Exp:DTOS(FIRSTDATE(MONTHSUB(mv_par01, 2)))% AND %Exp:DTOS(LASTDATE(mv_par01))%
			      AND SD2.D_E_L_E_T_ <> '*'
			      AND G1_FILIAL       = ''
			      AND G1_COMP         = %Exp:_cCodMassa%
			      AND SG1.D_E_L_E_T_ <> '*'
			      AND F4_CODIGO       = D2_TES
			      AND F4_DUPLIC       = 'S'
			      AND SF4.D_E_L_E_T_ <> '*'
			
		 GROUP BY D2_FILIAL,D2_COD
				
		 ORDER BY D2_COD
		
	EndSql
	
	DbSelectArea(cAlias)
	Dbgotop()
	
	ProcRegua((cAlias)->(RecCount()))
	
	(cAlias)->(Dbgotop())
	
	IncProc("Calculando Quantidades Zeradas para trazer na Tela..")
	
	While !(cAlias)->(EOF())
	
		IncProc("Pegando os dados para montar a tela..")
		
		IF (cAlias)->D2_QUANT - (cAlias)->D1_QUANT == 0
		
			AADD( _aDados, { .F.                 			                               ,;
							 (cAlias)->D2_FILIAL		 	                               ,;
							 (cAlias)->D2_COD			 	                               ,;
							 Posicione("SB1",1,xFilial("SB1")+(cAlias)->D2_COD,"B1_DESC") ,;
							 U_ADEST016((cAlias)->D2_COD)	                              ,;
							 0							 	                              ,;
							 nCustoVivo / _nPrecoMed                 		              ,;
							 .F.								                         } )
						 
		ENDIF
						 
		(cAlias)->(DbSkip())
	EndDo
	
	DbSelectArea(cAlias)
	dbCloseArea()
	
		
    // *** FINAL CHAMADO WILLIAM COSTA 22/06/2018 - 042130 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || MASSA DE FRANGO *** //

	
	/*Query usada para pegar todos os produtos de várzea que deverão ser feitos os ajustes de consumo de massa de frango e não possuem saídas*/
	BeginSql Alias cAlias
		
		SELECT D3_FILIAL, D3_COD, B1_DESC
		
		FROM %table:SD3% SD3A (NOLOCK), %table:SB1% SB1 (NOLOCK) 
		
		WHERE SD3A.%notDel% AND SB1.%notDel%
			AND SD3A.D3_EMISSAO BETWEEN %Exp:DTOS(FIRSTDATE(MONTHSUB(mv_par01, 2)))% AND %Exp:DTOS(LASTDATE(mv_par01))%
			AND SD3A.D3_FILIAL = %xFilial:SD3%
			AND SD3A.D3_COD BETWEEN %Exp:mv_par04% AND %Exp:mv_par05%
			AND SD3A.D3_COD = B1_COD
			AND B1_FILIAL = %xFilial:SB1%
			AND SD3A.D3_TM = '010'
			AND SD3A.D3_CF = 'PR0'
			AND SD3A.D3_ESTORNO = ' '
			AND EXISTS	(
							SELECT 1
							FROM %table:SD3% SD3B (NOLOCK), %table:SG1% SG1 (NOLOCK)
							WHERE SD3B.%notDel% AND SG1.%notDel%
								AND SD3B.D3_FILIAL = SD3A.D3_FILIAL
								AND SG1.G1_FILIAL =	%xfilial:SG1%								
								AND SD3B.D3_COD = SG1.G1_COMP
								AND SG1.G1_COMP = %Exp:_cCodMassa%																	
								AND SD3B.D3_EMISSAO BETWEEN %Exp:DTOS(FIRSTDATE(MONTHSUB(mv_par01, 2)))% AND %Exp:DTOS(LASTDATE(mv_par01))%
								AND SD3B.D3_OP = SD3A.D3_OP
			)
			AND NOT EXISTS	(
							SELECT 1
							FROM %table:SD2% SD2 (NOLOCK), %table:SA1% SA1 (NOLOCK), %table:SF4% SF4 (NOLOCK)
							WHERE SD2.%notDel% AND SA1.%notDel% AND SF4.%notDel%
								AND D2_EMISSAO BETWEEN %Exp:DTOS(FIRSTDATE(MONTHSUB(mv_par01, 2)))% AND %Exp:DTOS(LASTDATE(mv_par01))%
								AND D2_FILIAL = %xFilial:SD2%	
								AND D2_COD = SD3A.D3_COD
								AND A1_COD = D2_CLIENTE
								AND A1_LOJA = D2_LOJA
								AND F4_CODIGO = D2_TES
								AND F4_DUPLIC = 'S'
			)
		GROUP BY D3_COD, D3_FILIAL, B1_DESC

	EndSql
	
	DbSelectArea(cAlias)
	Dbgotop()
	
	ProcRegua((cAlias)->(RecCount()))
	
	(cAlias)->(Dbgotop())
	
	If (cAlias)->(EOF())
		_cMens += "Não foi encontrado nenhuma informação para gerar a tela e processar." + CRLF
		Return
	EndIf
	
	/*
		Chama Função externa para mostrar a informações:
			Preço Médio de Venda
			Custo de Frango Vivo
			Curto de Quebra
			Preço de Custo
			Fator
	*/
	//U_ADEST015(.T.)
	
	IncProc("Buscando as informações..")
	
	_cMens += "Montando a tela com as informação para gerar a tela e processar." + CRLF
	
	While !(cAlias)->(EOF())
		IncProc("Pegando os dados para montar a tela..")
		AADD( _aDados, { .F.                 			,;
						 (cAlias)->D3_FILIAL		 	,;
						 (cAlias)->D3_COD			 	,;
						 (cAlias)->B1_DESC 			 	,;
						 U_ADEST016((cAlias)->D3_COD)	,;
						 0							 	,;
						 nCustoVivo / _nPrecoMed 		,;
						 .F.								} )

		(cAlias)->(DbSkip())
	EndDo
	
	DbSelectArea(cAlias)
	dbCloseArea()
	
	IncProc("Montando a tela..")
	ADEST018A()	
	
	ProcLogAtu("FIM",,_cMens) 
	
Return

/*/{Protheus.doc} User function ADEST018P()
	Função criada para apresentar uma tela para preenchimento das informações que serão utilizadas no processamento do  ajuste
	de consumo de massa de frango para produtos sem faturamento
	@type  Function
	@author Leonardo Rios
	@since 26/10/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 057910 - FWNM - 18/06/2020 - || OS 059411 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || PROJETO UEP
/*/
Static Function ADEST018A

	Local aCols		:= {}
	Local aCoord	:= FWGetDialogSize(oMainWnd)
	Local aCampos 	:= {}
	Local aHeader 	:= {}
	Local aTamObj	:= Array(4)

	Local bAtGD		:= {|lAtGD,lFoco| IIf(lAtGD,(oGD01:SetArray(aCols), oGD01:bLine := &(_cLine01), oGD01:GoTop()), .T.),;
		IIf(ValType(lFoco) == "L" .AND. lFoco, (oGD01:SetFocus(), oGD01:Refresh()),.T.)}

	Local nCoefDif	:= 1

	Local oArea		:= FWLayer():New()
	Local oTela
	Local oPainel01
	Local oPainel02
	Local oPainelS01
	Local oBot01
	Local oBot02
	Local oOk 		:= LoadBitmap(GetResources(),"LBOK")
	Local oNo 		:= LoadBitmap(GetResources(),"LBNO")
	Local oGD01

	Private _cLine01 := ""

	aFill(aTamObj,0)

	AADD( aCampos, {"D3_FILIAL", "D3_COD", "B1_DESC", "D3_QUANT", "D3_CUSTO1", "D3_CUSTO1"} )
	aAdd( aHeader, { '', 'CHECKBOL', '@BMP', 20 , 0, , , 'L', , 'V' ,  ,  , 'mark'  , 'V', 'S' } )

	// Carrega aHeader
	dbSelectArea( "SX3" )
	SX3->( dbSetOrder( 2 ) ) // Campo
	For x:=1 To Len(aCampos)
		For y:= 1 To Len(aCampos[x]) //só estou usando a variavel x porque também possui o valor 3
		
			If SX3->( dbSeek( aCampos[x, y] ) )
				AADD( aHeader, { 	AllTrim( X3Titulo() ),; // 01 - Titulo
									SX3->X3_CAMPO		 ,;			// 02 - Campo
									IIF(ALLTRIM(SX3->X3_CAMPO) == "D3_CUSTO1", "@E 999,999,999.99", SX3->X3_Picture) ,;			// 03 - Picture
									IIF(ALLTRIM(SX3->X3_CAMPO) == "B1_DESC", SX3->X3_TAMANHO+10, SX3->X3_TAMANHO) 	 ,;			// 04 - Tamanho
									SX3->X3_DECIMAL		 ,;			// 05 - Decimal
									SX3->X3_Valid  		 ,;			// 06 - Valid
									SX3->X3_USADO  		 ,;			// 07 - Usado
									SX3->X3_TIPO   		 ,;			// 08 - Tipo
									SX3->X3_F3			 ,;			// 09 - F3
									SX3->X3_CONTEXT 	 ,;         // 10 - Contexto
									SX3->X3_CBOX		 ,; 		// 11 - ComboBox
									SX3->X3_RELACAO 	 ,;         // 12 - Relacao
									SX3->X3_INIBRW  	 ,;			// 13 - Inicializador Browse
									SX3->X3_Browse  	 ,;			// 14 - Mostra no Browse
									SX3->X3_VISUAL  } )
			EndIf
			
		Next y
	Next x	
	
	If Len(_aDados) < 1
		AADD( aCols, { .F., "", "", "", 0, 0, 0, .F. } )
	Else
		aCols := _aDados
	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montar o codeblock para montar as listas de dados da GD  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cLine01 := "{|| Iif( Len(aCols) < 1, {}, "
	_cLine01 += " { IIf(aCols[oGD01:nAt,1],oOk,oNo), "
	For ni := 2 to 8
		_cLine01 += "aCols[oGD01:nAt," + cValToChar(ni) + "]" + IIf(ni < 8,",","")
	Next ni
	_cLine01 += "} ) }"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÙ
	aCoord[3] := aCoord[3] * 0.95
	aCoord[4] := aCoord[4] * 0.95
	If U_ApRedFWL(.T.)
		nCoefDif := 0.95
	Endif
	
	
	DEFINE MSDIALOG oTela TITLE "Tela de Pré-Processamento" FROM aCoord[1],aCoord[2] TO aCoord[3],aCoord[4] OF oMainWnd COLOR "W+/W" PIXEL

		oArea:Init(oTela,.F.)
		
	//Mapeamento da area
		oArea:AddLine("L01",100 * nCoefDif,.T.)
		
	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Colunas  ³
	//ÀÄÄÄÄÄÄÄÄÄÙ
		oArea:AddCollumn("L01C01",LRG_COL01,.F.,"L01")
		oArea:AddCollumn("L01C02",LRG_COL02,.F.,"L01")		
		
	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Paineis  ³
	//ÀÄÄÄÄÄÄÄÄÄÙ
		oArea:AddWindow("L01C01", "L01C01P01", "Dados", 100, .F., .F., /*bAction*/, "L01", /*bGotFocus*/)
		oPainel01 := oArea:GetWinPanel("L01C01", "L01C01P01", "L01")
			
		oArea:AddWindow("L01C02", "L01C02P01", "Botões", 100, .F., .F., /*bAction*/, "L01", /*bGotFocus*/)
		oPainel02 := oArea:GetWinPanel("L01C02", "L01C02P01", "L01")
		
	
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 01 - Lista de dados  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGD01 := TCBrowse():New(000,000,000,000,/*bLine*/,{' ', 'FILIAL', 'PRODUTO', 'DESCRICAO', 'PRODUCAO', 'PRC. VENDA', 'FATOR'},,oPainel01,,,,/*bChange*/,/*bLDblClick*/,/*bRClick*/,/*oFont*/,,,,,,,.T.,/*bWhen*/,,/*bValid*/,.T.,.T.)
	oGD01:bHeaderClick	:= {|oObj,nCol| ADEST018B(2, @aCols, @oGD01, nCol, aClone(aHeader)), oGD01:Refresh()}
	oGD01:blDblClick	:= {|| ADEST018C(1, @aCols, @oGD01,, aClone(aHeader)), oGD01:Refresh()}
	oGD01:Align 		:= CONTROL_ALIGN_ALLCLIENT
	Eval(bAtGD,.T.,.F.)
		
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 02 - Funcoes  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
	//Processamento
	U_DefTamObj(@aTamObj, 000, 000, (oPainel02:nClientWidth / 2), nAltBot, .T.)
	oBot01 := tButton():New(aTamObj[1], aTamObj[2], cHK + "Processamento", oPainel02 ,;
		{|| IIf( .T.,; 
			MsAguarde({|| CursorWait(), lOk := ADEST018D( @aCols, @oGD01 ), CursorArrow(), Eval(bAtGD, .T., .T.), AllwaysTrue()},;
			"ADEST018P", "Processando", .F.), MsgAlert("Para processar é necessário que ao menos um registro seja selecionado!", "Processa"))},;
			aTamObj[3], aTamObj[4],,,, .T. ,,,, {|| .T.} )
			
	//Mesmo Banco
	U_DefTamObj(@aTamObj, aTamObj[1] + nAltBot + (nDistPad*3))
	oBot02 := tButton():New(aTamObj[1], aTamObj[2], "Ajuste Fator", oPainel02, {|| ADEST018F(@oGD01, @aCols)}, aTamObj[3], aTamObj[4],,,, .T. ,,,, {||} )
			
//		oCheck1 := TCheckBox():New(aTamObj[1], aTamObj[2], 'Ajuste Fator', {||}, oPainel02, 100, 8,,{|| U_ADEST015(.T.)},,,,,,.T.,,,)
	
	oTela:Activate(,,,.T.,/*valid*/,,{|| .T.})

Return

/*/{Protheus.doc} User function ADEST018P()
	Função criada para apresentar uma tela para preenchimento das informações que serão utilizadas no processamento do  ajuste
	de consumo de massa de frango para produtos sem faturamento
	@type  Function
	@author Leonardo Rios
	@since 26/10/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 057910 - FWNM - 18/06/2020 - || OS 059411 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || PROJETO UEP
/*/
Static Function ADEST018B(nOpc,aDados,oGDSel,nColSel,aHead)

	Local ni		:= 0
	Local cRoteiro	:= ""

	For ni := 1 to Len(aDados)
		If !aDados[ni][8]
			aDados[ni][1] := !aDados[ni][1]
			
			If aDados[ni][1]
				AADD(_aSelecIte, ni)
			Else
				_aSelecIte := {}
			EndIf
			
		EndIf
	Next ni
	
	//Forcar a atualizacao do browse
	oGDSel:DrawSelect()

Return Nil

/*/{Protheus.doc} User function ADEST018P()
	Função criada para apresentar uma tela para preenchimento das informações que serão utilizadas no processamento do  ajuste
	de consumo de massa de frango para produtos sem faturamento
	@type  Function
	@author Leonardo Rios
	@since 26/10/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 057910 - FWNM - 18/06/2020 - || OS 059411 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || PROJETO UEP
/*/
Static Function ADEST018C(nOpc, aDados, oGDSel, nColSel, aHead)

	Default nOpc	:= 0
	Default aDados	:= Array(0)
	Default oGDSel  := Nil
	Default nColSel	:= 1
	Default aHead	:= Array(0)

	If !aDados[oGDSel:nAt][8]
		aDados[oGDSel:nAt][1] := !aDados[oGDSel:nAt][1]
		
		If aDados[oGDSel:nAt][1]
			AADD(_aSelecIte, oGDSel:nAt)
		Else
			For x := 1 To Len(_aSelecIte)
				If oGDSel:nAt == _aSelecIte[x]
					ADEL( _aSelecIte, x )
					ASIZE( _aSelecIte, Len(_aSelecIte) - 1 )
					Exit
				EndIf
			Next x
		EndIf
	EndIf

	//Forcar a atualizacao do browse
	oGDSel:DrawSelect()
	
Return Nil

/*/{Protheus.doc} User function ADEST018P()
	Função criada para apresentar uma tela para preenchimento das informações que serão utilizadas no processamento do  ajuste
	de consumo de massa de frango para produtos sem faturamento
	@type  Function
	@author Leonardo Rios
	@since 26/10/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 057910 - FWNM - 18/06/2020 - || OS 059411 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || PROJETO UEP
/*/
Static Function ADEST018D(aCols, oGDSel)

	Local aDelets := {}
	
	For x:=1 To Len(aCols)

		If aCols[x,1] .AND. !aCols[x,8]
			
			BeginTran()

				_nFator := aCols[x,7]
			
				/*Atualiza o código zmassa para itens sem faturamento*/
				U_ADEST017(0,0, aCols[x,3], .T., aCols[x,6])				
	
			EndTran()
			AADD(aDelets, x)
			
			
		EndIf
						
	Next x

	lRetProc := MsgYesNo("Deseja prosseguir e efetuar o processamento dos itens do tipo Mão de Obra que estão na estrutura junto do ZMASSA?", "Tela de confirmação do processamento")


	If lRetProc

		cAntCod := ""
		For x:=1 To Len(aCols)

			If aCols[x,1] .AND. !aCols[x,8]
				
				BeginTran()

					If ALLTRIM(cAntCod) <> ALLTRIM(aCols[x, 03])
						IncProc("Atualizando o fator da massa de frango na PA " + aCols[x, 03])
					EndIf
					
					cAntCod	:= ALLTRIM(aCols[x, 03])
					
					_nFator := aCols[x,7]
					
					/*Atualiza os outros itens junto ao zmassa sem faturamento do produto acabado*/
					ADEST018E(aCols[x,3], aCols[x,6])
		
				EndTran()
				
			EndIf
							
		Next x

	EndIf

	If Len(aDelets) > 0
		For x := Len(aDelets) To 1 Step -1 
			ADEL( aCols, aDelets[x] )
		Next x
	
		ASIZE( aCols, Len(aCols) - Len(aDelets) )
	EndIf

	//Forcar a atualizacao do browse
	oGDSel:DrawSelect()
	
	U_ExTelaMen("ADEST018 - Processo concluido!!!", "Todos os itens selecionados foram processados", "Arial", 10, , .F., .T.)
	
Return Nil

/*/{Protheus.doc} User function ADEST018P()
	Função criada para apresentar uma tela para preenchimento das informações que serão utilizadas no processamento do  ajuste
	de consumo de massa de frango para produtos sem faturamento
	@type  Function
	@author Leonardo Rios
	@since 26/10/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 057910 - FWNM - 18/06/2020 - || OS 059411 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || PROJETO UEP
/*/
Static Function ADEST018E(cCodPA, nPrcVend)

	Local cAlias 	:= GetNextAlias()
	Local cCodMasAux:= _cCodMassa

	IncProc("Processandos os itens..")
	
	_cMens += "Buscando os itens que estão dentro da estrutura junto do ZMASSA são do tipo MO." + CRLF
		
	BeginSql Alias cAlias
		
		SELECT G1_COMP
		
		FROM %table:SG1% SG1A (NOLOCK), %table:SB1% SB1A (NOLOCK)
		
		WHERE SG1A.%notDel% AND SB1A.%notDel%
			AND SG1A.G1_FILIAL = %xfilial:SG1%
			AND SB1A.B1_FILIAL = %xfilial:SB1%
			AND SG1A.G1_COD = %Exp:ALLTRIM(cCodPA)%
			AND SG1A.G1_COMP <> %Exp:ALLTRIM(cCodMasAux)%
			AND SB1A.B1_COD = SG1A.G1_COMP
			AND SB1A.B1_CCCUSTO <> ' '
			AND SB1A.B1_TIPO = 'MO'
			AND EXISTS
			(
				SELECT G1_COMP, G1_COD

				FROM %table:SG1% SG1B (NOLOCK)

				WHERE SG1B.%notDel%
					AND SG1B.G1_FILIAL = SG1A.G1_FILIAL
					AND SG1B.G1_COD = SG1A.G1_COD
					AND SG1B.G1_COMP = %Exp:ALLTRIM(cCodMasAux)%
			)

	EndSql
	
	DbSelectArea(cAlias)
	Dbgotop()
	
	ProcRegua((cAlias)->(RecCount()))
	
	(cAlias)->(Dbgotop())
	
	If (cAlias)->(EOF())
		_cMens += "Não foi encontrado nenhum item dentro da estrutura junto do ZMASSA e do tipo MO" + CRLF
		Return
	EndIf
	
	While !(cAlias)->(EOF())
		_cMens += "Pegando o item " + (cAlias)->G1_COMP + " para processar a atualizar o seu fator na estrutura da PA " + cCodPA + CRLF
		_cCodMassa := (cAlias)->G1_COMP
		
		_cMens += "Atualizando o fator" + CRLF
		U_ADEST017(0,0, cCodPA, .T., nPrcVend)
		
		(cAlias)->(DbSkip())
	EndDo
	
	DbSelectArea(cAlias)
	dbCloseArea()
				
	_cCodMassa := cCodMasAux
	
Return Nil

/*/{Protheus.doc} User function ADEST018P()
	Função criada para apresentar uma tela para preenchimento das informações que serão utilizadas no processamento do  ajuste
	de consumo de massa de frango para produtos sem faturamento
	@type  Function
	@author Leonardo Rios
	@since 26/10/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 057910 - FWNM - 18/06/2020 - || OS 059411 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || PROJETO UEP
/*/
Static Function ADEST018F(oGDSel, aDados)

	Local lRetorno	:= .F.
	Local _nFator1	:= 0

	Default oGDSel  := Nil
	Default aDados	:= Array(0)

	If aDados[oGDSel:nAt][6] <> 0
		_nPrcVenda := aDados[oGDSel:nAt][6]
	EndIf
	
	If aDados[oGDSel:nAt][7] <> 0
		_nFator := aDados[oGDSel:nAt][7]
	EndIf
	        
	_nFator1	:= _nFator
	
	U_ADEST015( .T., @lRetorno )
	
	If !lRetorno
		Return .F.
	EndIf
	
	If Len(_aSelecIte) < 1
		aDados[oGDSel:nAt][6] := ROUND(_nPrcVenda, 2)
		aDados[oGDSel:nAt][7] := ROUND(_nFator1, 6)
	Else
		For x := 1 To Len(_aSelecIte)
			aDados[_aSelecIte[x]][6] := ROUND(_nPrcVenda, 2)
			aDados[_aSelecIte[x]][7] := ROUND(_nFator1, 6)
		Next x
	EndIf
	
	_nPrcVenda := 0
	_aSelecIte := {}

	//Forcar a atualizacao do browse
	oGDSel:DrawSelect()
	
Return .T.

/*/{Protheus.doc} User function ADEST018P()
	Função criada para apresentar uma tela para preenchimento das informações que serão utilizadas no processamento do  ajuste
	de consumo de massa de frango para produtos sem faturamento
	@type  Function
	@author Leonardo Rios
	@since 26/10/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 057910 - FWNM - 18/06/2020 - || OS 059411 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || PROJETO UEP
/*/
Static Function ADEST018H()

	Local nCusto    := 0 
	Local cAliasSD3 := GetNextAlias()   
	Local cSD3TM	:= ALLTRIM(GetMv('MV_XTMPRD',.F., "010"))
	Local cFilCurren:= xFilial("SD3")

	BeginSql Alias cAliasSD3
		
		SELECT SUM(D2_CUSTO1) / SUM(D2_QUANT) AS CUSTO
		
		FROM %table:SD2% SD2 (NOLOCK), %table:SF4% SF4 (NOLOCK)
		
		WHERE D2_COD = %Exp:_cFrangPad%
			AND D2_FILIAL = '03'
			AND D2_EMISSAO BETWEEN %Exp:DTOS(FIRSTDATE(mv_par01))% AND %Exp:DTOS(LASTDATE(mv_par01))%
			AND D2_LOCAL = '26'
			AND SD2.%notDel%
			AND SF4.%notDel%
			AND F4_ESTOQUE = 'S'
			AND F4_CODIGO = D2_TES
	
	EndSql                      
	
	DbSelectArea(cAliasSD3)
		
	If (cAliasSD3)->(! EOF())
		nCusto:= (cAliasSD3)->CUSTO
	EndIf                      
	
	DbCloseArea(cAliasSD3)
	
Return nCusto

/*/{Protheus.doc} User function ADEST018P()
	Função criada para apresentar uma tela para preenchimento das informações que serão utilizadas no processamento do  ajuste
	de consumo de massa de frango para produtos sem faturamento
	@type  Function
	@author Leonardo Rios
	@since 26/10/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 057910 - FWNM - 18/06/2020 - || OS 059411 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || PROJETO UEP
/*/
Static Function AjustaSX1(cPerg)

	Local aMensSX1 := {}

	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³01 - Mês de Referência? ³
	//³02 - Custo de Quebra  ? ³
	//³03 - Custo de Abate	 ? ³
	//³04 - Lista Cálculo	 ? ³
	//³05 - Produto De		 ? ³
	//³06 - Produto Até		 ? ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ENDDOC*/
	// PutSx1(cPerg, "01", "Mês de referência ?" , "Mês de referência ?", "Mês de referência ?", "mv_ch1", "D", 08					, 0, 0, "G", "", ""		, "", "", "mv_par01", ""		, ""	, ""	, "", ""	, ""	, ""	, "", "", "", "", "", "", "", "", "", {" ", " "}, {}, {})
	// PutSx1(cPerg, "02", "Custo de Quebra ?"   , "Custo de Quebra ?"	 , "Custo de Quebra ?"	, "mv_ch2", "N", 06					, 2, 0, "G", "", ""		, "", "", "mv_par02", ""		, ""	, ""	, "", ""	, ""	, ""	, "", "", "", "", "", "", "", "", "", {" ", " "}, {}, {})
	// PutSx1(cPerg, "03", "Custo de Abate ?"	  , "Custo de Abate ?"	 , "Custo de Abate ?"	, "mv_ch3", "N", 06					, 2, 0, "G", "", ""		, "", "", "mv_par03", ""		, ""	, ""	, "", ""	, ""	, ""	, "", "", "", "", "", "", "", "", "", {" ", " "}, {}, {})
	// /*PutSx1(cPerg, "04", "Lista Cálculo ?"	  , "Lista Cálculo? "	 , "Lista Cálculo ?"	, "mv_ch4", "N", 01					, 0, 0, "C", "", ""		, "", "", "mv_par04", "Sim"		, "Sim"	, "Sim"	, "", "Não"	, "Não"	, "Não" , "", "", "", "", "", "", "", "", "", {" ", " "}, {}, {})*/
	// PutSx1(cPerg, "04", "Produto De?"		  , "Produto De?"		 , "Produto De?"		, "mv_ch4", "C", TamSx3("B1_COD")[1], 0, 0, "G", "", "SB1"	, "", "", "mv_par04", ""		, ""	, ""	, "", ""	, ""	, ""	, "", "", "", "", "", "", "", "", "", {" ", " "}, {}, {})
	// PutSx1(cPerg, "05", "Produto Ate?"		  , "Produto Ate?"		 , "Produto Ate?"		, "mv_ch5", "C", TamSx3("B1_COD")[1], 0, 0, "G", "", "SB1"	, "", "", "mv_par05", ""		, ""	, ""	, "", ""	, ""	, ""	, "", "", "", "", "", "", "", "", "", {" ", " "}, {}, {})

//					1					2				3					4				5						6					7				8					9					10					11						12					13				14						15					16					17					18				19						20					21					22					23				24						25					26					27					28				29						30					31					32					33				34					35					36						37						38				39
    // AADD(/* 'X1_ORDEM' */, /* 'X1_PERGUNT'*/, /* 'X1_PERSPA' */, /* 'X1_PERENG' */, /* 'X1_TIPO' 	*/, /* 'X1_TAMANHO'*/, /* 'X1_DECIMAL'*/, /* 'X1_PRESEL' */, /* 'X1_GSC' 	*/, /* 'X1_VALID' 	*/	, /* 'X1_DEF01' 	*/, /* 'X1_DEFSPA1'*/, /* 'X1_DEFENG1'*/, /* 'X1_CNT01' 	*/, /* 'X1_VAR02' 	*/, /* 'X1_DEF02' 	*/, /* 'X1_DEFSPA2'*/, /* 'X1_DEFENG2'*/, /* 'X1_CNT02' 	*/, /* 'X1_VAR03' 	*/, /* 'X1_DEF03' 	*/, /* 'X1_DEFSPA3'*/, /* 'X1_DEFENG3'*/, /* 'X1_CNT03' 	*/, /* 'X1_VAR04' 	*/, /* 'X1_DEF04' 	*/, /* 'X1_DEFSPA4'*/, /* 'X1_DEFENG4'*/, /* 'X1_CNT04' 	*/, /* 'X1_VAR05' 	*/, /* 'X1_DEF05' 	*/, /* 'X1_DEFSPA5'*/, /* 'X1_DEFENG5'*/, /* 'X1_CNT05' 	*/, /* 'X1_F3'		*/, /* 'X1_PYME' 	*/, /* 'X1_GRPSXG' */	, /* 'X1_PICTURE'*/, /* 'X1_IDFIL' 	*/)

//					  1				2						3						4				  5			6						  7	 8		  9   10	 11	 12  13	  14  15  16  17   18   19  20  21  22  23  24  25  26  27  28  29  30  31  32  33  34  35      36   37  38  39	
    AADD( aMensSX1, {"01", "Mês de referência?"	, "Mês de referência?"	, "Mês de referência?"		,"D"	,008						,00, 0		,"G", ""	,""	,"" ,""	, "", "", "" ,"" , "" , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""    , "S", "", "", "" }) //"Informe a data inicial de emissão do global."}
    AADD( aMensSX1, {"02", "Custo de Quebra"	, "Custo de Quebra?"	, "Custo de Quebra?"		,"N"	,006						,02, 0		,"G", ""	,""	,""	,"" , "", "", "" ,"" , "" , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""    , "S", "", "", "" }) //"Informe a data final de emissão do global."}
	AADD( aMensSX1, {"03", "Custo de Abate ?"	, "Custo de Abate ?"	, "Custo de Abate ?"	    ,"N"	,006						,02, 0		,"G", ""	,""	,""	,""	, "", "", "" ,"" , "" , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""    , "S", "", "", "" }) //"Informe o codigo inicial do pallet do global"}
    AADD( aMensSX1, {"04", "Produto De?"		, "Produto De?"	    	, "Produto De?"		   		,"C"	,TamSX3("B1_COD")[1]		,00, 0		,"G", ""	,""	,""	,"" , "", "", "" ,"" , "" , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SB1" , "S", "", "", "" }) //"Informe o codigo final do pallet do global"}
	AADD( aMensSX1, {"05", "Produto Ate?"		, "Produto Ate?"		, "Produto Ate?"			,"C"	,TamSX3("B1_COD")[1]		,00, 0		,"G", ""	,""	,""	,"" , "", "", "" ,"" , "" , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SB1" , "S", "", "", "" }) //"Informe a data inicial de emissão da OP."}
    
    U_newGrSX1(_cPerg, aMensSX1)
	

Return