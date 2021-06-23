#include 'protheus.ch'
#include 'parmtype.ch'
#include 'prtopdef.ch'

// chamado 056054 - FWNM - 02/03/2020 - || OS TI || CONTROLADORIA || DANIELLE_MEIRA || 8459 || ERRO CUSTO JAN2020 - MELHORIA MENSAGEM TEMPO
#DEFINE  ENTER 		Chr(13)+Chr(10)

Static cHrIni   := ""
Static cHrFim   := ""
Static lOkEST017P := .t.
//

/*/{Protheus.doc} User Function ADEDA009P2
	Função criada para apresentar uma tela para preenchimento das informações que serão utilizadas 
	no processamento do projeto de ajuste do consumo de massa de frango
	@type  Function
	@author Leonardo Rios
	@since 26/10/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 056054 - FWNM - 21/02/2020 - || OS 057473 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || ERRO CUSTO JAN2020 - MELHORIA TRAVA
	@history chamado 056054 - FWNM - 02/03/2020 - || OS TI || CONTROLADORIA || DANIELLE_MEIRA || 8459 || ERRO CUSTO JAN2020 - MELHORIA MENSAGEM TEMPO
	@history chamado 056054 - FWNM - 03/03/2020 - || OS 057742 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || MASSA DE FRANGO
	@history chamado 057910 - FWNM - 18/06/2020 - || OS 059411 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || PROJETO UEP
/*/
User function ADEDA009P()

	Local oDlg	/*Objeto usado para o MSDIALOG*/
	Local lAtivo     := GetMV("MV_#UEPLIG",,.T.)
	Local lTravaOn   := GetMV("MV_#UEPKFS",,.F.)

	Private _cPerg	:= "ADEDA009P"	/*Nome da pergunta usado nas telas*/
	Private _cMens	:= "" /*Variável usada para gerar as mensagens do Log*/

    // Chamado n. 057910 || OS 059411 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || PROJETO UEP - FWNM - 18/06/2020
	// Chego se o valor UPS do sistema UEP está ativo para ser utilizado
    If lTravaOn
		If lAtivo
			msgAlert("Função para agregar valor UPS do sistema UEP aos movimentos do Protheus está ativada como rotina principal para uso! Contate a contabilidade...","Parâmetro: MV_#UEPLIG")
			Return
		EndIf
	EndIf
	//

	// Chamado n. 056054 || OS 057473 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || ERRO CUSTO JAN2020 - FWNM - 21/02/2020
	// Garanto uma única thread sendo executada
	If !LockByName("ADEDA009P", .T., .F.)
		Aviso("Atenção", "Existe outro processamento sendo executado! Verifique...", {"OK"}, 3)
		Return
	EndIf
	//

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Função criada para apresentar uma tela para preenchimento das informações que serão utilizadas no processamento do projeto de ajuste do consumo de massa de frango')

	AjustaSX1(_cPerg)
	Pergunte(_cPerg, .F.)
	
	DEFINE MSDIALOG oDlg FROM  96,9 TO 320,612 TITLE OemToAnsi("Consumo de Massa de Frango") PIXEL

		@ 16, 15 SAY OemToAnsi("Este programa efetua o ajuste do consumo de massa de frango.") SIZE 268, 8 OF oDlg PIXEL			   									
		
		DEFINE SBUTTON FROM 93, 163 TYPE 15 ACTION ProcLogView(cFilAnt,"ADEDA009P") ENABLE OF oDlg
		DEFINE SBUTTON FROM 93, 193 TYPE 5  ACTION Pergunte(_cPerg,.T.) ENABLE OF oDlg
		DEFINE SBUTTON FROM 93, 223 TYPE 1  ACTION If(.T.,(Processa({|lEnd| ADEDA009A()},OemToAnsi("Cálcula o ajusta do consumo"),OemToAnsi("Efetuando o cálculo do ajuste..."),.F.),oDlg:End()),) ENABLE OF oDlg
		DEFINE SBUTTON FROM 93, 253 TYPE 2  ACTION oDlg:End() ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED 

	// Chamado n. 056054 || OS 057473 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || ERRO CUSTO JAN2020 - FWNM - 21/02/2020
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADEDA009P")
	//

	// Chamado n. 056054 || OS TI - FWNM - 02/03/2020
	If !Empty(cHrIni) .and. !Empty(cHrFim) .and. lOkEST017P
		Aviso("Fim", "Cálculos dos ajustes de consumo finalizados com sucesso!" + ENTER + ENTER + "Iniciado as: " + cHrIni + ENTER + "Finalizado as: " + cHrFim, {"OK"}, 3)
	Else
		Alert("Cálculos dos ajustes de consumo com problemas, pois não foram realizados ou estão incompletos devido erro no UPDATE SG1/SD3!" + ENTER + ENTER + "Iniciado as: " + cHrIni + ENTER + "Finalizado as: " + cHrFim )
	EndIf
	//
	
Return

/*/{Protheus.doc} Static Function ADEDA009A
	Função criada para apresentar uma tela para preenchimento das 
	informações que serão utilizadas no processamento do projeto  
	de ajuste do consumo de massa de frango						 
	@type  Static Function
	@author Leonardo Rios
	@since 26/10/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ADEDA009A()

	/*Processamento*/
	Local cAliasSG1 	:= GetNextAlias()
	Local dDtFecha	:= SuperGetMV("MV_ULMES")	/*Data do último fechamento do estoque.*/

	/*------------------------------------------------------------------------------------------*/
	/*Processamento*/
	Private _cCodMassa	:= SuperGetMV("MV_XCODMAS", .F., "323574")	/*Código da estrutura de massa usado nas condições de busca dos produtos*/
	Private _cFrangPad	:= SuperGetMV("MV_XPRDFV", .F., "")	/*Código do Produto Frango Vivo pega pegar o Custo Médio dele na filial 03*/
	Private _nPrecoMed 	:= 0	/*Valor do Preço Médio de Venda encontrado no cálculo feito das informações retornadas da query*/		
	Private _nPrecoCus 	:= 0	/*Valor do Preço de Custo encontrado no cálculo feito dos valores da pergunta e o Preço Médio de Venda*/
	Private _nFator		:= 0	/*Valor do Fator encontrado no cálculo feito entre o Preço de Custo e o Preço Médio de Venda*/

	/*------------------------------------------------------------------------------------------*/
	/*Relatório*/
	Private _aDados := {}	/*Array usado no SetBlock do relatório para receber as informações e preencher o relatório*/

	cHrIni := Time() // Chamado n. 056054 || OS TI - FWNM - 02/03/2020

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
	_cMens += "Lista Cálculo: " + IIF(mv_par04 == 1, "SIM", "NÃO") + CRLF
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
	BeginSql Alias cAliasSG1
		
		SELECT D2_COD, B1_DESC, SUM(D2_QUANT) AS D2_QUANT, SUM(D2_QTDEDEV) AS D2_QTDEDEV, SUM(D2_TOTAL) AS D2_TOTAL, SUM(D2_VALDEV) AS D2_VALDEV

		FROM %table:SB1% SB1 (NOLOCK), %table:SG1% SG1 (NOLOCK), %table:SD2% SD2 (NOLOCK), %table:SA1% SA1 (NOLOCK), %table:SF4% SF4 (NOLOCK)
		
		WHERE SB1.%notDel% AND SG1.%notDel% AND SD2.%notDel% AND SA1.%notDel% AND SF4.%notDel%
			AND D2_EMISSAO BETWEEN %Exp:DTOS(FIRSTDATE(MONTHSUB(mv_par01, 2)))% AND %Exp:DTOS(LASTDATE(mv_par01))%
			AND D2_FILIAL = %xfilial:SD2%
			AND B1_COD = D2_COD
			AND B1_COD = G1_COD
			AND B1_COD BETWEEN %Exp:mv_par05% AND %Exp:mv_par06%
			AND G1_COMP = %Exp:_cCodMassa%
			AND G1_FILIAL = %xfilial:SG1%
			AND A1_COD = D2_CLIENTE
			AND A1_LOJA = D2_LOJA
			AND F4_CODIGO = D2_TES
			AND F4_DUPLIC = 'S'
		
		GROUP BY D2_COD, B1_DESC
		
		ORDER BY D2_COD

	EndSql
	
	DbSelectArea(cAliasSG1)
	Dbgotop()
	
	ProcRegua((cAliasSG1)->(RecCount()))
	
	_cMens += "Calculando o Preço Médio das notas de saída retornadas da busca." + CRLF
	
	(cAliasSG1)->(Dbgotop())
	
	IncProc("Buscando as informações..")
	nSomaQuant := 0
	nSomaTotal := 0
	While !(cAliasSG1)->(EOF())
		IncProc("Somando quantidade e total dos produtos")
		AADD(_aDados, { (cAliasSG1)->D2_COD, (cAliasSG1)->B1_DESC, (cAliasSG1)->D2_QUANT, (cAliasSG1)->D2_QTDEDEV, (cAliasSG1)->D2_TOTAL, (cAliasSG1)->D2_VALDEV } )

		nSomaQuant += ((cAliasSG1)->D2_QUANT - (cAliasSG1)->D2_QTDEDEV)
		nSomaTotal += ((cAliasSG1)->D2_TOTAL - (cAliasSG1)->D2_VALDEV)

		(cAliasSG1)->(DbSkip())
	EndDo
	
	DbSelectArea(cAliasSG1)
	dbCloseArea(cAliasSG1)
	
	/*Cálculo do Preço Médio Geral das Vendas*/
	_nPrecoMed := nSomaTotal / nSomaQuant
	_cMens += "Preço Médio Geral: " + TRANSFORM(_nPrecoMed, "@E 999,999,999.9999") + CRLF
	
	/* Função para mostrar o resultrado do Preço Médio de Venda calculado 
	   e ter a opção de realizar o processamento(ajuste) de consumo de massa de frango */
	U_ADEST015P()

	ProcLogAtu("FIM",,_cMens)

	cHrFim := Time() // Chamado n. 056054 || OS TI - FWNM - 02/03/2020

Return

/*/{Protheus.doc} User Function ADEST015P
	Função para mostrar o resultrado do Preço Médio de Venda
	calculado em uma tela e ter a opção de realizar o ajuste de 
	consumo de massa de frango									 
	@type  Function
	@author Leonardo Rios
	@since 26/10/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function ADEST015P(lExterno, lRetorno)

	/*------------------------------------------------------------------------------------------*/
	/*Processamento*/
	Local cLocal	:= RetFldProd(_cFrangPad, "B1_LOCPAD") /*Função padrão do Protheus para retornar o local(armazém) usado no SBZ para o Produto*/
	Local nPrcMedVen:= _nPrecoMed 	/*Valor do Preço Médio de Venda calculado anteriormente*/
	Local nPrcFrango:= 0			/*Valor do Custo do Frango Vivo que será calculado posteriormente pegando o B2_CM1*/
	Local nPrcQuebra:= mv_par02		/*Valor do Custo de Quebra digitado nos parâmetros da pergunta feita inicialmente*/
	Local nPrcAbate	:= mv_par03		/*Valor do Custo de Abate digitado nos parâmetros da pergunta feita inicialmente*/
	Local oDlg						/*Objeto usado para o MSDIALOG*/

	Default lExterno := .F.
	Default lRetorno := .F.

	U_ADINF009P('ADEDA009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Função para mostrar o resultrado do Preço Médio de Venda calculado em uma tela e ter a opção de realizar o ajuste de consumo de massa de frango')

	nPrcFrango := ADEDA009E (_cFrangPad)
	
	_nPrecoCus 	:= nPrcFrango + nPrcQuebra + nPrcAbate		/*Valor do Preço de Custo calculado */
	_nFator 	:= IIf(nPrcMedVen > 0, _nPrecoCus / nPrcMedVen, 0) 	/*Valor do Fator calculado para ser usado no processamento*/
	
	_cMens += "Custo Apurado: " + TRANSFORM(_nPrecoCus, "@E 999,999,999.9999") + CRLF
	_cMens += "Fator: " + TRANSFORM(_nFator, "@E 999,999,999.9999") + CRLF + CRLF

	DEFINE MSDIALOG oDlg FROM  96,9 TO 440,612 TITLE OemToAnsi("Consumo de Massa de Frango") PIXEL

		@ 10, 15 SAY OemToAnsi("Tela de apuração dos dados para efetuar o processamento do ajuste de consumo de massa de frango") SIZE 268, 8 OF oDlg PIXEL			   									
		
		If !lExterno
			@ 28, 15 SAY OemToAnsi("Preço Médio de Venda") SIZE 100, 10 OF oDlg PIXEL
			@ 28, 110 MSGET nPrcMedVen SIZE 100,8 OF oDlg PIXEL PICTURE  "@E 999,999,999.99" VALID ADEDA009C(nPrcFrango, nPrcQuebra, nPrcAbate, IIf(lExterno, _nPrcVenda, nPrcMedVen)) WHEN .F.
		EndIf

		@ 40, 15 SAY OemToAnsi("Custo do Frango Vivo") SIZE 100, 10 OF oDlg PIXEL
		@ 40, 110 MSGET nPrcFrango SIZE 100,8 OF oDlg PIXEL PICTURE "@E 999,999,999.99" VALID ADEDA009C(nPrcFrango, nPrcQuebra, nPrcAbate, IIf(lExterno, _nPrcVenda, nPrcMedVen))
		
		@ 52, 15 SAY OemToAnsi("Custo da Quebra") SIZE 100, 10 OF oDlg PIXEL
		@ 52, 110 MSGET nPrcQuebra SIZE 100,8 OF oDlg PIXEL PICTURE "@E 999,999,999.99" VALID ADEDA009C(nPrcFrango, nPrcQuebra, nPrcAbate, IIf(lExterno, _nPrcVenda, nPrcMedVen))
		
		@ 64, 15 SAY OemToAnsi("Custo de Abate") SIZE 100, 10 OF oDlg PIXEL
		@ 64, 110 MSGET nPrcAbate SIZE 100,8 OF oDlg PIXEL PICTURE "@E 999,999,999.99" VALID ADEDA009C(nPrcFrango, nPrcQuebra, nPrcAbate, IIf(lExterno, _nPrcVenda, nPrcMedVen))
		
		@ 76, 15 SAY OemToAnsi("Preço de Custo") SIZE 100, 10 OF oDlg PIXEL
		@ 76, 110 MSGET _nPrecoCus SIZE 100,8 OF oDlg PIXEL PICTURE "@E 999,999,999.99" WHEN .F.
		
		@ 88, 15 SAY OemToAnsi("Fator") SIZE 100, 10 OF oDlg PIXEL
		@ 88, 110 MSGET _nFator SIZE 100,8 OF oDlg PIXEL PICTURE "@E 999,999,999.99" WHEN .F.
		
		If lExterno
			@ 100, 15 SAY OemToAnsi("Preço de Venda") SIZE 100, 10 OF oDlg PIXEL
			@ 100, 110 MSGET _nPrcVenda SIZE 100,8 OF oDlg PIXEL PICTURE "@E 999,999,999.99" //VALID ADEDA009C(nPrcFrango, nPrcQuebra, nPrcAbate, _nPrcVenda)
		EndIf
		
		DEFINE SBUTTON FROM 145, 223 TYPE 1  ACTION;
			If( .T.,; 
					IIF( lExterno ,;
							(oDlg:End(), lRetorno := .T.),; 
							(;
								Processa( {|lEnd| ADEDA009D() },; 
									OemToAnsi("Processamento do ajuste de consumo."),; 
									OemToAnsi("Efetuando o ajuste de consumo nos produtos..."),; 
									.F. ),;
								oDlg:End(); 
							); 
						),;
					oDlg:End();
				);
		ENABLE OF oDlg
		
		DEFINE SBUTTON FROM 145, 253 TYPE 2  ACTION oDlg:End() ENABLE OF oDlg
		
	ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} Static Function ADEDA009C
	Função criada para atualizar os valores do Preço de Custo e do
	Fator caso o usuário queira alterar alguma informação		 
	Parâmetros aParam[1]	:	nVar01 - Custo do Frango Vivo(B2_CM1) 	- [N]
			   aParam[2]	:	nVar02 - Custo de Quebra				- [N]
			   aParam[3]	:	nVar03 - Custo de Abate			 		- [N]
			   aParam[4]	:	nVar04 - Preço Médio de Venda 			- [N]
	@type  Static Function
	@author user
	@since 26/10/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ADEDA009C(nVar01, nVar02, nVar03, nVar04)

	_nPrecoCus 	:= nVar01 + nVar02 + nVar03
	_nFator		:= IIf(nVar04 > 0, _nPrecoCus / nVar04, 0)

Return .T.

/*/{Protheus.doc} Static Function ADEDA009D
	Função criada para atualizar o campo D3_QUANT do produtos nas
	movimentações que devem ser processadas o consumo de massa de
	frango e inserir a quantidade anterior no capmo D3_XQDEANT
	@type  Static Function
	@author Leonardo Rios
	@since 26/10/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ADEDA009D()

	/*------------------------------------------------------------------------------------------*/
	/*Processamento*/
	Local cAntCod	:= ""
	Local nQuant	:= 0
	Local nTotal	:= 0

	/*------------------------------------------------------------------------------------------*/
	/*Relatório*/
	Local oReport		/*Objeto do Report do Relatório*/

	/*------------------------------------------------------------------------------------------*/
	/*Relatório*/
	Private _oSection1	/*Section Utilizada no Report do Relatório*/
	
	_cMens += "Valores ATUALIZADOS" + CRLF
	_cMens += "Custo Apurado: " + TRANSFORM(_nPrecoCus, "@E 999,999,999.9999") + CRLF
	_cMens += "Fator: " + TRANSFORM(_nFator, "@E 999,999,999.9999") + CRLF
	
	/*Se Lista Càlculo do parâmetro da pergunta for igual a 'SIM' eu crio a estrutura para gerar o relatório*/
	If mv_par04 == 1
		_cMens += "Gerando o relatório para análise do usuário." + CRLF
			
		/* Mostra as perguntas na tela para escolher o filtro */
		oReport:= ReportDef("Atual")
		oReport:PrintDialog()
	EndIf	
	
	lRetProc := MsgYesNo("Deseja realmente processar os itens?", "Tela de confirmação do processamento")
	
	If !lRetProc
		Return .F.
	EndIf
	
	/*
		Inicia o Ajuste da estrutura de massa dos produtos e das massas que possuem movimentações
	*/
	ProcRegua(Len(_aDados))
	
	_cMens += "Atualizando o valor fator do campo da estrutura do produto(G1_QUANT) com os novos valores." + CRLF
	IncProc("Atualizando os fatores nas estruturas..")
	
	nQuant := 0
	nTotal := 0
	For x:=1 To Len(_aDados)
	
		If ALLTRIM(cAntCod) <> ALLTRIM(_aDados[x,01])
			IncProc("Atualizando o fator da massa de frango na PA " + _aDados[x,01])
		EndIf
		
		nQuant 	:= _aDados[x,03] - _aDados[x,04]
		nTotal	:= _aDados[x,05] - _aDados[x,06]
		
		cAntCod	:= ALLTRIM(_aDados[x,01])
		
		// *** INICIO CHAMADO WILLIAM COSTA 22/06/2018 - 042130 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || MASSA DE FRANGO *** //
		IF nQuant == 0
			LOOP
		ENDIF
		// *** FINAL CHAMADO WILLIAM COSTA 22/06/2018 - 042130 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || MASSA DE FRANGO *** //
		
		If x+1 <= Len(_aDados)
			If ALLTRIM(cAntCod) <> ALLTRIM(_aDados[x+1,01])	
				lOkEST017P := U_ADEST017P(nTotal, nQuant, _aDados[x,01])
				If !lOkEST017P
					Exit
				EndIf
			EndIf
		Else
			lOkEST017P := U_ADEST017P(nTotal, nQuant, _aDados[x,01])
			If !lOkEST017P
				Exit
			EndIf
		EndIf
		
	Next x
	
	// Chamado n. 056054 || OS 057742 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || MASSA DE FRANGO - FWNM - 03/03/2020
	If !lOkEST017P
		Return .f.
	EndIf
	//

	lRetProc := MsgYesNo("Deseja prosseguir e efetuar o processamento dos itens do tipo Mão de Obra que estão na estrutura junto do ZMASSA?", "Tela de confirmação do processamento")
	
	If lRetProc
		cAntCod := ""
		For x:=1 To Len(_aDados)
			If ALLTRIM(cAntCod) <> ALLTRIM(_aDados[x,01])
				IncProc("Atualizando o fator da massa de frango na PA " + _aDados[x,01])
			EndIf
			cAntCod	:= ALLTRIM(_aDados[x,01])
			ADEDA009I( ALLTRIM(_aDados[x,01]) )
		Next x
	EndIf
	
	// _cMens += "Gerando o relatório após atualizações para análise do usuário." + CRLF
		
	/* Mostra as perguntas na tela para escolher o filtro */
	// oReport:= ReportDef("ZMASSA")
	// oReport:PrintDialog()
	
Return .T.

/*/{Protheus.doc} Static Function ADEDA009E
	Calculo do custo medio de produção do mes de referencia
	@type  Static Function
	@author Leonardo Rios
	@since 26/10/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ADEDA009E(cCod)

	Local nCusto    := 0 
	Local cAliasSD2 := GetNextAlias()   
	Local cSD3TM	:= ALLTRIM(GetMv('MV_XTMPRD',.F., "010"))
	Local cFilCurren:= xFilial("SD3")

	BeginSql Alias cAliasSD2
		
		SELECT SUM(D2_CUSTO1) / SUM(D2_QUANT) AS CUSTO
		
		FROM %table:SD2% SD2 (NOLOCK), %table:SF4% SF4 (NOLOCK)
		
		WHERE D2_COD = %Exp:cCod%
			AND D2_FILIAL = '03'
			AND D2_EMISSAO BETWEEN %Exp:DTOS(FIRSTDATE(mv_par01))% AND %Exp:DTOS(LASTDATE(mv_par01))%
			AND D2_LOCAL = '26'
			AND SD2.%notDel%
			AND SF4.%notDel%
			AND F4_ESTOQUE = 'S'
			AND F4_CODIGO = D2_TES
	
	EndSql                      
	
	DbSelectArea(cAliasSD2)
		
	If (cAliasSD2)->(! EOF())
		nCusto:= (cAliasSD2)->CUSTO
	EndIf                      
	
	DbCloseArea(cAliasSD2)
	
Return nCusto

/*/{Protheus.doc} User Function ADEST016P
	Calculo do total produzido
	@type  Static Function
	@author Leonardo Rios
	@since 24/07/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function ADEST016P(cCod)

	Local nProduzido:= 0 
	Local cAliasSD3 := GetNextAlias()   
	Local cSD3TM	:= ALLTRIM(GetMv('MV_XTMPRD',.F., "010"))
	Local cFilCurren:= xFilial("SD3")

	U_ADINF009P('ADEDA009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Calculo do total produzido')

	BeginSql Alias cAliasSD3
	
		SELECT SUM(D3_QUANT) AS PRODUZIDO
			
		FROM %table:SD3% SD3 (NOLOCK)
		
		WHERE SD3.%notDel% 
			AND D3_EMISSAO BETWEEN %Exp:DTOS(FIRSTDATE(mv_par01))% AND %Exp:DTOS(LASTDATE(mv_par01))%
			AND D3_ESTORNO=''  
			AND D3_COD= %Exp:cCod%
			AND D3_TM = %Exp:cSD3TM%
			AND D3_CF = 'PR0'
			AND D3_FILIAL = %Exp:cFilCurren%
	
	EndSql                      
	
	DbSelectArea(cAliasSD3)
		
	If (cAliasSD3)->(! EOF())
		nProduzido:= (cAliasSD3)->PRODUZIDO
	EndIf                      
	
	DbCloseArea(cAliasSD3)
	
Return nProduzido

/*/{Protheus.doc} Static Function ADEDA009G
	Calculo do total consumido
	@type  Static Function
	@author Leonardo Rios
	@since 24/07/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ADEDA009G(cCod)

	Local nConsumido:= 0 
	Local cAliasSD3 := GetNextAlias()   

	/*
		Estruturas de massa dos produtos e das massas que possuem movimentações
	*/
	BeginSql Alias cAliasSD3
		SELECT SUM(D3_QUANT) AS QTDE
			
		FROM %table:SD3% SD3A (NOLOCK)
		
		WHERE SD3A.%notDel% 
			AND SD3A.D3_FILIAL = %xfilial:SD3A%
			AND SD3A.D3_COD = %Exp:_cCodMassa%
			AND SD3A.D3_EMISSAO BETWEEN %Exp:DTOS(FIRSTDATE(MONTHSUB(mv_par01, 2)))% AND %Exp:DTOS(LASTDATE(mv_par01))%
			AND EXISTS (
					SELECT 1 
					
					FROM %table:SD3% SD3B 
					
					WHERE SD3B.D3_COD = %Exp:cCod%
						AND SD3B.D3_FILIAL = %xfilial:SD3B%
						AND SD3A.D3_OP = SD3B.D3_OP 
						AND SD3B.D3_CF = 'PR0' 
						AND SD3B.D3_EMISSAO BETWEEN %Exp:DTOS(FIRSTDATE(MONTHSUB(mv_par01, 2)))% AND %Exp:DTOS(LASTDATE(mv_par01))%
						AND SD3B.D3_ESTORNO = ' '
						AND SD3B.%notDel%
						)
	EndSql

	DbSelectArea(cAliasSD3)
	
	ProcRegua((cAliasSD3)->(RecCount()))
	(cAliasSD3)->(Dbgotop())	
	
	While (cAliasSD3)->(! EOF())
		nConsumido += (cAliasSD3)->QTDE
	EndDo                      
	
	DbCloseArea(cAliasSD3)
	
Return nConsumido

/*/{Protheus.doc} User Function ADEST017P
	()
	@type  Static Function
	@author Leonardo Rios
	@since 24/07/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function ADEST017(nTotal, nQuanti, cCod, lExterno, nPreco)

	Local cAliasSD3	:= GetNextAlias()
	Local cAlias	:= ""
	Local cQuery	:= ""
	Local cSD3TM	:= ALLTRIM(GetMv('MV_XTMPRD',.F., "010"))
	Local nNovoVal 	:= _nFator
	Local lUpdOk    := .t. // Chamado n. 056054 || OS 057742 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || MASSA DE FRANGO - FWNM - 03/03/2020

	Default lExterno:= .F.
	Default nPreco 	:= 0

	U_ADINF009P('ADEDA009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	nNovoVal := _nFator * IIF( lExterno, nPreco, ( nTotal / nQuanti ) )

	// Chamado n. 056054 || OS 057742 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || MASSA DE FRANGO - FWNM - 03/03/2020
	Begin Transaction

		lUpdOk    := .t.
		nStatus := TCSQLExec("UPDATE SG1010 SET G1_XANTQNT=G1_QUANT, G1_QUANT=" + ALLTRIM(STR(nNovoVal)) + " WHERE D_E_L_E_T_=' ' AND G1_COD='" + cCod + "'" +;
					" AND G1_COMP='" + _cCodMassa + "'")

		If nStatus < 0
			lUpdOk    := .f.
			msgAlert("UPDATE na tabela SG1010 não foi realizado! Envie o erro que será mostrado na próxima tela ao TI... A rotina será abortada e não será finalizada!")
			MessageBox(tcSqlError(),"",16)
			DisarmTransaction()
			Return lUpdOk
		EndIf

		/*
		TCSQLExec("UPDATE SG1010 SET G1_XANTQNT=G1_QUANT, G1_QUANT=" + ALLTRIM(STR(nNovoVal)) + " WHERE D_E_L_E_T_=' ' AND G1_COD='" + cCod + "'" +;
					" AND G1_COMP='" + _cCodMassa + "'")
		*/
		//
		
		/*Query usada para pegar todos os produtos de várzea que deverão ser feitos os ajustes de consumo de massa de frango*/ 
		BeginSql Alias cAliasSD3
			
			SELECT D3_FILIAL, D3_DOC, D3_TM, D3_COD, D3_OP, D3_QUANT, D3_XQDEANT, D3_EMISSAO, G1_COMP, G1_QUANT, G1_XANTQNT
			
			FROM %table:SD3% SD3A (NOLOCK), %table:SG1% SG1 (NOLOCK)
			
			WHERE SD3A.%notDel% AND SG1.%notDel%
				AND D3_EMISSAO BETWEEN %Exp:DTOS(FIRSTDATE(mv_par01))% AND %Exp:DTOS(LASTDATE(mv_par01))%
				AND SD3A.D3_FILIAL = %xFilial:SD3%
				AND G1_COMP = %Exp:_cCodMassa%
				AND SG1.G1_FILIAL =	%xfilial:SG1%
				AND D3_COD = SG1.G1_COMP
				AND SG1.G1_COD = %Exp:cCod%
				AND EXISTS	(
								SELECT 1
								FROM %table:SD3% SD3B (NOLOCK)
								WHERE SD3B.%notDel%
									AND SD3B.D3_FILIAL = %xFilial:SD3%
									AND SD3B.D3_COD = %Exp:cCod%																	
									AND SD3B.D3_EMISSAO BETWEEN %Exp:DTOS(FIRSTDATE(mv_par01))% AND %Exp:DTOS(LASTDATE(mv_par01))%
									AND SD3B.D3_TM = %Exp:cSD3TM%
									AND SD3B.D3_OP = SD3A.D3_OP 
							)
		EndSql

		DbSelectArea(cAliasSD3)
		Dbgotop()

		_cMens += "Corrigindo as movimentações da produção do mês vigente com os novos fatores da estrutura calculados." + CRLF
		IncProc("Ajustando as movimentação da massa de frango..")
		While !(cAliasSD3)->(EOF())
			nValQntAnt := (cAliasSD3)->D3_QUANT

			nQuantReal := 0
			cAliasD32 := GetNextAlias()

			cQuery := " SELECT D3_QUANT "
			cQuery += " FROM " + RetSqlName("SD3") + " SD3 "
			cQuery += " WHERE D_E_L_E_T_=' ' "
			cQuery += " 	AND D3_ESTORNO = ' ' "		
			cQuery += "  	AND D3_FILIAL = '" + (cAliasSD3)->D3_FILIAL + "' "					
			cQuery += "  	AND D3_EMISSAO = '" +  (cAliasSD3)->D3_EMISSAO + "' "
			cQuery += "  	AND D3_TM = '" + cSD3TM + "' "
			cQuery += "  	AND D3_OP = '" + (cAliasSD3)->D3_OP + "' "
			cQuery += "  	AND D3_DOC = '" + (cAliasSD3)->D3_DOC + "' "

			cQuery := ChangeQuery(cQuery)

			DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasD32, .F., .T.)
			
			nQuantReal := (cAliasD32)->D3_QUANT

			// Chamado n. 056054 || OS 057742 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || MASSA DE FRANGO - FWNM - 03/03/2020
			If lUpdOk
				nStatus := TCSQLExec("UPDATE SD3010 SET D3_QUANT=" + ALLTRIM(STR(nQuantReal*(cAliasSD3)->G1_QUANT)) + ", D3_XQDEANT=" + ALLTRIM(STR(nValQntAnt)) + " WHERE D_E_L_E_T_=' ' AND D3_COD='" + (cAliasSD3)->D3_COD + "'" +;
							" AND D3_OP='" + (cAliasSD3)->D3_OP + "' AND D3_DOC='" + (cAliasSD3)->D3_DOC + "'")

				If nStatus < 0
					lUpdOk    := .f.
					msgAlert("UPDATE na tabela SD3010 não foi realizado! Envie o erro que será mostrado na próxima tela ao TI... A rotina será abortada e não será finalizada!")
					MessageBox(tcSqlError(),"",16)
					DisarmTransaction()
					Return lUpdOk
					Exit
				EndIf
			EndIf

			/*
			TCSQLExec("UPDATE SD3010 SET D3_QUANT=" + ALLTRIM(STR(nQuantReal*(cAliasSD3)->G1_QUANT)) + ", D3_XQDEANT=" + ALLTRIM(STR(nValQntAnt)) + " WHERE D_E_L_E_T_=' ' AND D3_COD='" + (cAliasSD3)->D3_COD + "'" +;
						" AND D3_OP='" + (cAliasSD3)->D3_OP + "' AND D3_DOC='" + (cAliasSD3)->D3_DOC + "'")
			*/
			//

			DbSelectArea(cAliasD32)
			DbCloseArea(cAliasD32)
			(cAliasSD3)->(DbSkip())
		EndDo

	End Transaction

	DbSelectArea(cAliasSD3)
	DbCloseArea(cAliasSD3)
	
Return .T.

/*/{Protheus.doc} Static Function ADEDA009H
	Calcula o Preço Médio do Produto
	@type  Static Function
	@author Leonardo Rios
	@since 09/10/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ADEDA009H(cCodItem)

	Local nRet := 0

	/*Processamento*/
	Local cAliasSD2 	:= GetNextAlias()

	If Empty(ALLTRIM(cCodItem))
		Return nRet
	EndIf

	BeginSql Alias cAliasSD2
		
		SELECT SUM(D2_QUANT) AS QUANT, SUM(D2_QTDEDEV) AS QUANTDEV, SUM(D2_TOTAL) AS TOT, SUM(D2_VALDEV) AS TOTALDEV

		FROM %table:SB1% SB1 (NOLOCK), %table:SG1% SG1 (NOLOCK), %table:SD2% SD2 (NOLOCK), %table:SA1% SA1 (NOLOCK), %table:SF4% SF4 (NOLOCK)
		
		WHERE SB1.%notDel% AND SG1.%notDel% AND SD2.%notDel% AND SA1.%notDel% AND SF4.%notDel%
			AND D2_EMISSAO BETWEEN %Exp:DTOS(FIRSTDATE(MONTHSUB(mv_par01, 2)))% AND %Exp:DTOS(LASTDATE(mv_par01))%
			AND D2_FILIAL = %xfilial:SD2%
			AND B1_COD = D2_COD
			AND D2_COD = %Exp:cCodItem%
			AND B1_COD = G1_COD
			AND B1_COD BETWEEN %Exp:mv_par05% AND %Exp:mv_par06%
			AND G1_COMP = %Exp:_cCodMassa%
			AND G1_FILIAL = %xfilial:SG1%
			AND A1_COD = D2_CLIENTE
			AND A1_LOJA = D2_LOJA
			AND F4_CODIGO = D2_TES
			AND F4_DUPLIC = 'S'		

	EndSql
	
	DbSelectArea(cAliasSD2)
	Dbgotop()

	While !(cAliasSD2)->(EOF())
		
		nRet := ( (cAliasSD2)->TOT - (cAliasSD2)->TOTALDEV ) / ( (cAliasSD2)->QUANT - (cAliasSD2)->QUANTDEV )

		(cAliasSD2)->(DbSkip())
	EndDo

	DbSelectArea(cAliasSD2)
	dbCloseArea(cAliasSD2)

Return nRet

/*/{Protheus.doc} Static Function ADEDA009I
	())
	@type  Static Function
	@author KF System
	@since 04/06/2012
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ADEDA009I(cCodPA)

	Local cAliasSD2 	:= GetNextAlias()
	Local cCodMasAux:= _cCodMassa

	IncProc("Processando os itens..")
	
	_cMens += "Buscando os itens que estão dentro da estrutura junto do ZMASSA são do tipo MO." + CRLF
		
	BeginSql Alias cAliasSD2
		
		SELECT G1_COMP, SUM(D2_QUANT) AS D2_QUANT, SUM(D2_QTDEDEV) AS D2_QTDEDEV, SUM(D2_TOTAL) AS D2_TOTAL, SUM(D2_VALDEV) AS D2_VALDEV
		
		FROM %table:SG1% SG1A (NOLOCK), %table:SB1% SB1A (NOLOCK), %table:SD2% SD2 (NOLOCK), %table:SA1% SA1 (NOLOCK), %table:SF4% SF4 (NOLOCK)
		
		WHERE SG1A.%notDel% AND SB1A.%notDel% AND SD2.%notDel% AND SA1.%notDel% AND SF4.%notDel%
			AND D2_EMISSAO BETWEEN %Exp:DTOS(FIRSTDATE(MONTHSUB(mv_par01, 2)))% AND %Exp:DTOS(LASTDATE(mv_par01))%
			AND D2_FILIAL = %xfilial:SD2%
			AND SG1A.G1_COD = D2_COD
			AND A1_COD = D2_CLIENTE
			AND A1_LOJA = D2_LOJA
			AND F4_CODIGO = D2_TES
			AND F4_DUPLIC = 'S'
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

		GROUP BY G1_COMP

	EndSql
	
	DbSelectArea(cAliasSD2)
	Dbgotop()
	
	ProcRegua((cAliasSD2)->(RecCount()))
	
	(cAliasSD2)->(Dbgotop())
	
	If (cAliasSD2)->(EOF())
		_cMens += "Não foi encontrado nenhum item dentro da estrutura junto do ZMASSA e do tipo MO" + CRLF
		Return
	EndIf
	
	If !(cAliasSD2)->(EOF())
		
		nQuant 	:= 0
		nTotal 	:= 0
		cAntComp:= (cAliasSD2)->G1_COMP
		
		While !(cAliasSD2)->(EOF())

			_cCodMassa := (cAliasSD2)->G1_COMP

			nQuant += (cAliasSD2)->D2_QUANT - (cAliasSD2)->D2_QTDEDEV
			nTotal += (cAliasSD2)->D2_TOTAL - (cAliasSD2)->D2_VALDEV

			cAntComp:= (cAliasSD2)->G1_COMP
			
			// *** INICIO CHAMADO WILLIAM COSTA 22/06/2018 - 042130 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || MASSA DE FRANGO *** //
			IF nQuant == 0
			
			    (cAliasSD2)->(DbSkip())
				LOOP
			
			ENDIF
			
			// *** FINAL CHAMADO WILLIAM COSTA 22/06/2018 - 042130 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || MASSA DE FRANGO *** //
			
			(cAliasSD2)->(DbSkip())

			If cAntComp <> (cAliasSD2)->G1_COMP
				IncProc("Atualizando o fator do componente " + cAntComp + " de massa de frango na PA " + cCodPA)

				_cMens += "Pegando o item " + cAntComp + " para processar a atualizar o seu fator na estrutura da PA " + cCodPA + CRLF
				_cMens += "Atualizando o fator" + CRLF
				
				U_ADEST017(nTotal, nQuant, cCodPA)

				nQuant 	:= 0
				nTotal 	:= 0
				
			EndIf

		EndDo

	EndIf
	
	DbSelectArea(cAliasSD2)
	dbCloseArea(cAliasSD2)
				
	_cCodMassa := cCodMasAux
	
Return Nil

/*/{Protheus.doc} Static Function ReportDef
	Função para criar as colunas do relatório e suas características
	Esta função será chamada apenas se o usuário escolher a opção de
	'SIM' no parâmetro das perguntas								   
	@type  Static Function
	@author Leonardo Rios
	@since 19/10/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ReportDef(cColTitle)

	Local cPict := "@E 999,999,999.99"
	Local oReport

	oReport:= TReport():New("ADEDA009P","Consumo de Massa de Frango","ADEDA009P", {|oReport| ReportPrint(oReport)},"Consumo de Massa de Frango")
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)

	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄs¿
	//³Criacao da secao utilizada pelo relatorio                            ³
	//³                                                                     ³
	//³TRSection():New                                                      ³
	//³ExpO1 : Objeto TReport que a secao pertence                          ³
	//³ExpC2 : Descricao da seçao                                           ³
	//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela³
	//³  sera considerada como principal para a seção.                      ³
	//³ExpA4 : Array com as Ordens do relatório                             ³
	//³ExpL5 : Carrega campos do SX3 como celulas                           ³
	//³  Default : False                                                    ³
	//³ExpL6 : Carrega ordens do Sindex                                     ³
	//³  Default : False                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄsÙ
	ENDDOC*/
	_oSection1:= TRSection():New(oReport,"Consumo de Massa de Frango","")
	_oSection1:SetHeaderPage()

	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Criacao da celulas da secao do relatorio                    ³
	//³                                                            ³
	//³TRCell():New                                                ³
	//³ExpO1 : Objeto TSection que a secao pertence                ³
	//³ExpC2 : Nome da celula do relatório. O SX3 será consultado  ³
	//³ExpC3 : Nome da tabela de referencia da celula              ³
	//³ExpC4 : Titulo da celula                                    ³
	//³  Default : X3Titulo()                                      ³
	//³ExpC5 : Picture                                             ³
	//³  Default : X3_PICTURE                                      ³
	//³ExpC6 : Tamanho                                             ³
	//³  Default : X3_TAMANHO                                      ³
	//³ExpL7 : Informe se o tamanho esta em pixel                  ³
	//³  Default : False                                           ³
	//³ExpB8 : Bloco de código para impressao.                     ³
	//³  Default : ExpC2                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	ENDDOC*/
	/*		   //oTSection// cCELL      //cTABLE // cTitle  			// cPicture // nLengh   									// lPixel 	//	bCodeBlock					   */

	TRCell():New(_oSection1,"TO_PROD"	,        ,"Produto"						,/*Picture*/,TamSx3("D2_COD")[1]							,			,/*{|| code-block de impressao }*/)
	TRCell():New(_oSection1,"TO_DESC"	,        ,"Descrição"					,/*Picture*/,TamSx3("B1_DESC")[1]							,			,/*{|| code-block de impressao }*/)
	TRCell():New(_oSection1,"TO_QTDE"  	,        ,"Qtde"						,/*Picture*/,TamSx3("D2_QUANT")[1]							,			,/*{|| code-block de impressao }*/)
	TRCell():New(_oSection1,"TO_QTDEDEV",        ,"Qtde de Devolução"			,/*Picture*/,TamSx3("D2_QUANT")[1]							,			,/*{|| code-block de impressao }*/)
	TRCell():New(_oSection1,"TO_TOTAL"	,        ,"Total" 						,cPict		,TamSx3("D2_TOTAL")[1]							,			,/*{|| code-block de impressao }*/)
	TRCell():New(_oSection1,"TO_VALDEV"	,        ,"Valor de Devolução"			,cPict		,TamSx3("D2_TOTAL")[1]							,			,/*{|| code-block de impressao }*/)
	TRCell():New(_oSection1,"TO_PRCMEDG",        ,"Preço Médio Geral"			,/*Picture*/,TamSx3("D2_PRCVEN")[1]							,			,/*{|| code-block de impressao }*/)
	TRCell():New(_oSection1,"TO_CUSTOAP",        ,"Custo Apurado"				,/*Picture*/,TamSx3("D2_PRCVEN")[1]							,			,/*{|| code-block de impressao }*/)
	TRCell():New(_oSection1,"TO_FATOR"	,        ,"Fator"						,/*Picture*/,TamSx3("D2_PRCVEN")[1]							,			,/*{|| code-block de impressao }*/)
	TRCell():New(_oSection1,"TO_FATPREC",        ,"Fator x Preço Médio"			,/*Picture*/,TamSx3("D2_PRCVEN")[1]							,			,/*{|| code-block de impressao }*/)
	TRCell():New(_oSection1,"TO_TOTPROD",        ,"Total Produzido"				,/*Picture*/,TamSx3("D2_PRCVEN")[1]							,			,/*{|| code-block de impressao }*/)
	TRCell():New(_oSection1,"TO_TOTCONS",        ,"Total Consumido" + cColTitle	,/*Picture*/,TamSx3("D2_PRCVEN")[1]							,			,/*{|| code-block de impressao }*/)

Return oReport

/*/{Protheus.doc} Static Function ReportPrint
	Função para criar as colunas do relatório e suas características
	Esta função será chamada apenas se o usuário escolher a opção de
	'SIM' no parâmetro das perguntas								   
	@type  Static Function
	@author Leonardo Rios
	@since 19/10/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ReportPrint(oReport)

	Local aDados[12]	/*Array usado no SetBlock do relatório para receber as informações e preencher o relatório*/

	_oSection1:Cell("TO_PROD"	):SetBlock( { || aDados[01]	})
	_oSection1:Cell("TO_DESC"	):SetBlock( { || aDados[02]	})
	_oSection1:Cell("TO_QTDE"	):SetBlock( { || aDados[03]	})
	_oSection1:Cell("TO_QTDEDEV"):SetBlock( { || aDados[04]	})	
	_oSection1:Cell("TO_TOTAL"	):SetBlock( { || aDados[05]	})
	_oSection1:Cell("TO_VALDEV"	):SetBlock( { || aDados[06]	})	
	_oSection1:Cell("TO_PRCMEDG"):SetBlock( { || aDados[07]	})
	_oSection1:Cell("TO_CUSTOAP"):SetBlock( { || aDados[08]	})
	_oSection1:Cell("TO_FATOR"	):SetBlock( { || aDados[09]	})
	_oSection1:Cell("TO_FATPREC"):SetBlock( { || aDados[10]	})
	_oSection1:Cell("TO_TOTPROD"):SetBlock( { || aDados[11]	})
	_oSection1:Cell("TO_TOTCONS"):SetBlock( { || aDados[12]	})

	_oSection1:Init()
	
		For x := 1 To Len(_aDados)
			aDados[01] := _aDados[x,1]
			aDados[02] := _aDados[x,2]
			aDados[03] := _aDados[x,3]
			aDados[04] := _aDados[x,4]
			aDados[05] := _aDados[x,5]
			aDados[06] := _aDados[x,6]			
			aDados[07] := _nPrecoMed
			aDados[08] := _nPrecoCus
			aDados[09] := _nFator
			aDados[10] := _nFator * ADEDA009H(_aDados[x,1])
			aDados[11] := U_ADEST016(_aDados[x,1])
			aDados[12] := ADEDA009G(_aDados[x,1])
					
			_oSection1:PrintLine()
			
		Next x

	_oSection1:Finish()

Return

/*/{Protheus.doc} Static Function AjustaSX1
	Perguntas do utilizadas no processamento
	@type  Static Function
	@author user
	@since 26/10/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function AjustaSX1(_cPerg)

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
	// PutSx1(_cPerg, "01", "Mês de referência ?", "Mês de referência ?", "Mês de referência ?", "mv_ch1", "D", 08					, 0, 0, "G", "", ""		, "", "", "mv_par01", ""		, ""	, ""	, "", ""	, ""	, ""	, "", "", "", "", "", "", "", "", "", {" ", " "}, {}, {})
	// PutSx1(_cPerg, "02", "Custo de Quebra ?"  , "Custo de Quebra ?"	 , "Custo de Quebra ?"	, "mv_ch2", "N", 06					, 2, 0, "G", "", ""		, "", "", "mv_par02", ""		, ""	, ""	, "", ""	, ""	, ""	, "", "", "", "", "", "", "", "", "", {" ", " "}, {}, {})
	// PutSx1(_cPerg, "03", "Custo de Abate ?"	  , "Custo de Abate ?"	 , "Custo de Abate ?"	, "mv_ch3", "N", 06					, 2, 0, "G", "", ""		, "", "", "mv_par03", ""		, ""	, ""	, "", ""	, ""	, ""	, "", "", "", "", "", "", "", "", "", {" ", " "}, {}, {})
	// PutSx1(_cPerg, "04", "Lista Cálculo ?"	  , "Lista Cálculo? "	 , "Lista Cálculo ?"	, "mv_ch4", "N", 01					, 0, 0, "C", "", ""		, "", "", "mv_par04", "Sim"		, "Sim"	, "Sim"	, "", "Não"	, "Não"	, "Não" , "", "", "", "", "", "", "", "", "", {" ", " "}, {}, {})
	// PutSx1(_cPerg, "05", "Produto De?"		  , "Produto De?"		 , "Produto De?"		, "mv_ch5", "C", TamSx3("B1_COD")[1], 0, 0, "G", "", "SB1"	, "", "", "mv_par05", ""		, ""	, ""	, "", ""	, ""	, ""	, "", "", "", "", "", "", "", "", "", {" ", " "}, {}, {})
	// PutSx1(_cPerg, "06", "Produto Ate?"		  , "Produto Ate?"		 , "Produto Ate?"		, "mv_ch6", "C", TamSx3("B1_COD")[1], 0, 0, "G", "", "SB1"	, "", "", "mv_par06", ""		, ""	, ""	, "", ""	, ""	, ""	, "", "", "", "", "", "", "", "", "", {" ", " "}, {}, {})
	

	//					1					2				3					4				5						6					7				8					9					10					11						12					13				14						15					16					17					18				19						20					21					22					23				24						25					26					27					28				29						30					31					32					33				34					35					36						37						38				39
    // AADD(/* 'X1_ORDEM' */, /* 'X1_PERGUNT'*/, /* 'X1_PERSPA' */, /* 'X1_PERENG' */, /* 'X1_TIPO' 	*/, /* 'X1_TAMANHO'*/, /* 'X1_DECIMAL'*/, /* 'X1_PRESEL' */, /* 'X1_GSC' 	*/, /* 'X1_VALID' 	*/	, /* 'X1_DEF01' 	*/, /* 'X1_DEFSPA1'*/, /* 'X1_DEFENG1'*/, /* 'X1_CNT01' 	*/, /* 'X1_VAR02' 	*/, /* 'X1_DEF02' 	*/, /* 'X1_DEFSPA2'*/, /* 'X1_DEFENG2'*/, /* 'X1_CNT02' 	*/, /* 'X1_VAR03' 	*/, /* 'X1_DEF03' 	*/, /* 'X1_DEFSPA3'*/, /* 'X1_DEFENG3'*/, /* 'X1_CNT03' 	*/, /* 'X1_VAR04' 	*/, /* 'X1_DEF04' 	*/, /* 'X1_DEFSPA4'*/, /* 'X1_DEFENG4'*/, /* 'X1_CNT04' 	*/, /* 'X1_VAR05' 	*/, /* 'X1_DEF05' 	*/, /* 'X1_DEFSPA5'*/, /* 'X1_DEFENG5'*/, /* 'X1_CNT05' 	*/, /* 'X1_F3'		*/, /* 'X1_PYME' 	*/, /* 'X1_GRPSXG' */	, /* 'X1_PICTURE'*/, /* 'X1_IDFIL' 	*/)

//					  1				2						3						4				  5			6						  7	 8		  9   10	 11	 12  13	  	  14  	  15  16  17   	  18   	  19  	  20  21  22  23  24  25  26  27  28  29  30  31  32  33  34  35      36   37  38  39	
    AADD( aMensSX1, {"01", "Mês de referência?"	, "Mês de referência?"	, "Mês de referência?"		,"D"	,008						,00, 0		,"G", ""	,""	,"" ,""		, ""	, "", "", "" 	, "" 	, ""	, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""    , "S", "", "", "" }) //"Informe a data inicial de emissão do global."}
    AADD( aMensSX1, {"02", "Custo de Quebra"	, "Custo de Quebra?"	, "Custo de Quebra?"		,"N"	,006						,02, 0		,"G", ""	,""	,""	,"" 	, ""	, "", "", "" 	, "" 	, ""	, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""    , "S", "", "", "" }) //"Informe a data final de emissão do global."}
	AADD( aMensSX1, {"03", "Custo de Abate ?"	, "Custo de Abate ?"	, "Custo de Abate ?"	    ,"N"	,006						,02, 0		,"G", ""	,""	,""	,""		, ""	, "", "", "" 	, "" 	, ""	, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""    , "S", "", "", "" }) //"Informe o codigo inicial do pallet do global"}
	AADD( aMensSX1, {"04", "Lista Cálculo ?"	, "Lista Cálculo ?"		, "Lista Cálculo ?"	    	,"N"	,001						,00, 0		,"C", ""	,"Sim"	,"Sim"	,"Sim"	, "", "", "Não" ,"Não" 	, "Não"	, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""    , "S", "", "", "" }) //"Informe o codigo inicial do pallet do global"}
    AADD( aMensSX1, {"05", "Produto De?"		, "Produto De?"	    	, "Produto De?"		   		,"C"	,TamSX3("B1_COD")[1]		,00, 0		,"G", ""	,""	,""	,"" 	, ""	, "", "", "" 	, "" 	, ""	, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SB1" , "S", "", "", "" }) //"Informe o codigo final do pallet do global"}
	AADD( aMensSX1, {"06", "Produto Ate?"		, "Produto Ate?"		, "Produto Ate?"			,"C"	,TamSX3("B1_COD")[1]		,00, 0		,"G", ""	,""	,""	,"" 	, ""	, "", "", "" 	, "" 	, ""	, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SB1" , "S", "", "", "" }) //"Informe a data inicial de emissão da OP."}
    
    U_newGrSX1(_cPerg, aMensSX1)

Return