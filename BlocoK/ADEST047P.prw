#include "protheus.ch"
#include "topconn.ch"
#include "FWMVCDef.ch"
#include 'parmtype.ch'
#include 'prtopdef.ch'

#DEFINE  ENTER 		Chr(13)+Chr(10)

//Largura das colunas FWLayer
#DEFINE LRG_COL01		80
#DEFINE LRG_COL02		20

// Variaveis estaticas
Static cTitulo    := "Painel UEP"
Static cTabela    := "ZFY"
Static cHrIni     := ""
Static cHrFim     := ""
Static lOkEST017P := .t.

Static nDistPad	:= 002
Static nAltBot	:= 013
Static cHK		:= "&"

/*/{Protheus.doc} User Function ADEST047P
    Projeto UEP
    @type  Function
    @author FWNM
    @since 14/05/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado n. 057910 || OS 059411 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || PROJETO UEP
/*/
User Function ADEST047P()

    Local oBrowse
    Local aAreaAtu := GetArea()
    Local cFunBkp  := FunName()

    PRIVATE aRotina		:= MenuDef()

    SetFunName("ADEST047P")

    // Instanciando FWMBROWSE - Somente com dicionario de dados
    oBrowse := FWMBrowse():New()

    // Setando a tabela de cadastros 
    oBrowse:SetAlias(cTabela)

    // Setando a descricao da rotina
    oBrowse:SetDescription(cTitulo)

    // Ativa o browse
    oBrowse:Activate()

    SetFunName(cFunBkp)

    RestArea(aAreaAtu)

Return

/*/{Protheus.doc} Static Function MENUDEF
    Projeto UEP
    @type  Function
    @author FWNM
    @since 14/05/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado n. 057910 || OS 059411 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || PROJETO UEP
/*/
Static Function MenuDef()

    LOCAL aRotina := {}

    // Adicionando opcoes
    ADD OPTION aRotina TITLE "Visualizar"        		  ACTION "VIEWDEF.MVCUEP"  OPERATION MODEL_OPERATION_VIEW   ACCESS 0
    ADD OPTION aRotina TITLE "Agrega UPS"        		  ACTION "U_GeraUPS()"     OPERATION 2                      ACCESS 0
    ADD OPTION aRotina TITLE "Importa UEP"       		  ACTION "U_ImpUEP()"      OPERATION 3                      ACCESS 0
    ADD OPTION aRotina TITLE "Agrega UPS (Prod s/ Fat) "  ACTION "U_GeraUPS2()"    OPERATION 4                      ACCESS 0

    //ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.MVCUEP" OPERATION MODEL_OPERATION_INSERT ACCESS 0 // OPERACAO 3
    //ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.MVCUEP" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // OPERACAO 4
    //ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.MVCUEP" OPERATION MODEL_OPERATION_DELETE ACCESS 0 // OPERACAO 5

Return aRotina

/*/{Protheus.doc} Static Function MODELDEF
    Projeto UEP
    @type  Function
    @author FWNM
    @since 14/05/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado n. 057910 || OS 059411 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || PROJETO UEP
/*/
Static Function ModelDef()

    // Criacao do objeto do modelo de dados
    Local oModel

    // Criacao da estrutura de dados utilizada na interface
    Local oStDad := FWFormStruct(1, cTabela)

    // Instanciando o modelo, nao e recomendado colocar o nome da user function (por causa do u_), respeitando o limite de 10 caracteres
    //oModel := MPFormModel():New("MVCUEP", bVldPre, bVldPos, bVldCom, bVldCan)
    oModel := MPFormModel():New("MODELDEF_MVC")

    // Atribuindo formularios para o modelo 
    oModel:AddFields("FORMZFY", /*cOwner*/, oStDad)

    // Setando a chave primaria da rotina
    oModel:SetPrimaryKey({"ZFY_FILIAL","ZFY_MESANO","ZFY_PRODUT","ZFY_CODIGO","ZFY_EMPRESA"})

Return oModel

/*/{Protheus.doc} Static Function VIEWDEF
    Projeto UEP
    @type  Function
    @author FWNM
    @since 14/05/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado n. 057910 || OS 059411 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || PROJETO UEP
/*/
Static Function ViewDef()

    Local aStruZFY := ZFY->( dbStruct() )

    // Criacao do objeto do modelo de dados da interface do cadastro
    Local oModel := FWLoadModel("MVCUEP")

    // Criacao da estrutura de dados utilizada na interface do cadastro
    Local oStDad := FWFormStruct(2, cTabela) // pode se usar um terceiro parametro para filtrar os campos exibidos [ |cCampo| cCampo $ "SZZ1_NOME|SZZ1_

    // Criando oView como nulo
    Local oView := Nil

    // Criando a VIEW que sera o retorno da funcao e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
                        
    // Atribuindo formularios para interface
    oView:AddField("VIEW_ZFY", oStDad, "FORMZFY")

    // Criando container com nome tela 100%
    oView:CreateHorizontalBox("TELA", 100)

    // Colocando titulo do formulario
    oView:EnableTitleView("VIEW_ZFY", "Dados - " + cTitulo)

    // Forca o fechamento da janela na confirmacao
    oView:SetCloseOnOK( {|| .t.} )
                            
    // O formulario da interface sera colocado dentro do container
    oView:SetOwnerView("VIEW_ZFY", "TELA")

Return oView

/*/{Protheus.doc} User Function ImpUEP
    Importa dados do sistema UEP
    @type  Function
    @author FWNM
    @since 14/05/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function ImpUEP()

	Local cDescBox	:= "Informe o mês/ano que deseja importar manualmente"
	Local cMesAno	:= Space(06)
	Local aParamBox := {}   
	Local aRet 		:= {}   
	Local dDtFecha	:= SuperGetMV("MV_ULMES")	/*Data do último fechamento do estoque.*/
	Local cDtUlMes  := ""

	// Garanto uma única thread sendo executada
	If !LockByName("ADEST047P", .T., .F.)
		Aviso("Atenção", "Existe outro processamento sendo executado! Verifique...", {"OK"}, 3)
		Return
	EndIf
	//

	Aadd( aParamBox,{ 1, "MesAno:", cMesAno	,"","","","",80, .T. } )
		
	//If ParamBox( aParamBox, cDescBox, @aRet ) // com opção salvar
    If ParamBox( aParamBox, cDescBox, @aRet, , , , , , , , .F., .F. ) // Sem opção salvar 
        
		cMesAno  := aRet[1]
		cDtUlMes := Alltrim(StrZero(Month(dDtFecha),2)) + AllTrim(Str(Year(dDtFecha)))

		If cDtUlMes < cMesAno
	        MsAguarde({|| RunImpUEP(cMesAno) },"Aguarde","Importando movimentos UEP de " + cMesAno)
		Else
	        msgAlert("Importação não permitida pois o período informado é inferior ao último fechamento! Contate a contabilidade...","Parâmetro: MV_ULMES")
		EndIf

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADEST047P")
	//

Return

/*/{Protheus.doc} Static Function RunImpUEP
    Processa Importação movimentos UEP
    @type  Static Function
    @author user
    @since 14/05/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function RunImpUEP(cMesAno)

	Local cServUEP := GetMV("MV_#UEPSRV",,"VPSRV04")
	Local cSGBDUEP := GetMV("MV_#UEPSQL",,"TECNOSUL")         
    Local cQuery   := ""                                                   
    Local lLock    := .t.
    Local nCount   := 0

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    cQuery := " SELECT * 
    cQuery += " FROM " + "[" + cServUEP + "].[" + cSGBDUEP + "].[dbo].[UP_UPABERTA_EXP]
    cQuery += " WHERE MESANO = '"+cMesAno+"'

    tcQuery cQuery New Alias "Work"

	aTamSX3	:= TamSX3("ZFY_UPS")
	tcSetField("Work", "ZFY_UPS", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	aTamSX3	:= TamSX3("ZFY_VLRUP")
	tcSetField("Work", "ZFY_VLRUP", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	aTamSX3	:= TamSX3("ZFY_CUSTO")
	tcSetField("Work", "ZFY_CUSTO", aTamSX3[3], aTamSX3[1], aTamSX3[2])

    Work->( dbGoTop() )
    Do While Work->( !EOF() )

        nCount++

        lLock    := .t.
        ZFY->( dbSetOrder(3) ) //ZFY_FILIAL+ZFY_CODIGO+ZFY_EMPRES+ZFY_MESANO+ZFY_PRODUT+ZFY_UPABER                                                                                               
        If ZFY->( dbSeek( FWxFilial("ZFY") + PadR(AllTrim(Work->CODIGO),Len(ZFY->ZFY_CODIGO)) + PadR(AllTrim(Str(Work->EMPRESA)),Len(ZFY->ZFY_EMPRES)) + PadR(AllTrim(Work->MESANO),Len(ZFY->ZFY_MESANO)) + PadR(AllTrim(Work->PRODUTO),Len(ZFY->ZFY_PRODUT)) + PadR(AllTrim(Work->UPABERTA),Len(ZFY->ZFY_UPABER))) )
            lLock := .f.
        EndIf

        RecLock("ZFY", lLock)
            
            ZFY->ZFY_FILIAL := FWxFilial("ZFY")
            ZFY->ZFY_EMPRES := AllTrim(Str(Work->EMPRESA))
            ZFY->ZFY_MESANO := AllTrim(Work->MESANO)
            ZFY->ZFY_PRODUT := AllTrim(Work->PRODUTO)
            ZFY->ZFY_UPABER := AllTrim(Work->UPABERTA)
            ZFY->ZFY_UPS    := Work->UPS
            ZFY->ZFY_VLRUP  := Work->VLRUP
            ZFY->ZFY_CUSTO  := Work->CUSTO
            ZFY->ZFY_CODIGO := AllTrim(Work->CODIGO)
            ZFY->ZFY_TIPO   := AllTrim(Work->TIPO)

        ZFY->( msUnLock() )

        Work->( dbSkip() )

    EndDo

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    msgInfo("Importação do Mês/Ano " + cMesAno + " finalizada! Total de registros incluídos na tabela ZFY para transformação dos movimentos Protheus: " + AllTrim(Str(nCount)))
    
Return

/*/{Protheus.doc} User Function GeraUPS
    Transforma movimentos Protheus com dados importados do sistema UEP
    @type  Function
    @author FWNM
    @since 20/05/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function GeraUPS()

	Local lTravaOn   := GetMV("MV_#UEPKFS",,.F.)
	Local lAtivo     := GetMV("MV_#UEPLIG",,.T.)
    Local cDescBox	 := "Período dos movimentos Protheus que serão agregados com o valor UPS"
	Local cAnoMes	 := Space(06)
	Local aParamBox  := {}   
	Local aRet 		 := {}

	Private _cMens	  := "" 
    Private cMensUEP  := "" 
	Private cAliasTRB := ""
	
    // Chego se o valor UPS do sistema UEP está ativo para ser utilizado
    If lTravaOn
		If !lAtivo
			msgAlert("Função para agregar valor UPS do sistema UEP aos movimentos do Protheus não está liberada para uso! Contate a contabilidade...","Parâmetro: MV_#UEPLIG")
			Return
		EndIf
	EndIf
    
	// Garanto uma única thread sendo executada
	If !LockByName("ADEST047P", .T., .F.)
		Aviso("Atenção", "Existe outro processamento sendo executado! Verifique...", {"OK"}, 3)
		Return
	EndIf
	//

    /*
	Aadd( aParamBox,{ 1, "Período (Ano/Mês):", cAnoMes	,"","","","",80, .T. } )
		
	//If ParamBox( aParamBox, cDescBox, @aRet ) // com opção salvar
    If ParamBox( aParamBox, cDescBox, @aRet, , , , , , , , .F., .F. ) // Sem opção salvar 
        cAnoMes := aRet[1]
        MsAguarde({|| RunUPS(cAnoMes) },"Aguarde","Transformando movimentos Protheus com o valor UPS, período " + cAnoMes)
	EndIf
    */
    RunUPS()

	//LOG •	Agrega UPS
	//A rotina deve filtrar na SD3, da filial 02, todos os registros com TM 010 e verificar se existe esse produto no painel da UEP (naquele período), 
	//independente do componente, Logo após deve verificar se o produto + componente contido no painel está preenchido na SG1.
	msAguarde( { || GeraLog(1, "Agrega UPS") }, "Aguarde", "Processando conferências para geração de log " )
	//GeraLog(1, "Agrega UPS")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADEST047P")
	//

    TRB->( dbGoTop() )
	If TRB->( !EOF() )

        If msgYesNo("Processamento gerou logs. Deseja visualizá-los?")

			oReport := ReportDef(@cAliasTRB)
			oReport:PrintDialog()

			//oTempTable:Delete()

        EndIf

    Else

		msgAlert("Nenhuma inconsistência encontrada... Log não gerado!")
	
	EndIf

Return

/*/{Protheus.doc} Static Function RunUPS
    Processa transformação dos movimentos Protheus com valor UPS
    @type  Static Function
    @author user
    @since 20/05/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function RunUPS()

	Local oDlg	/*Objeto usado para o MSDIALOG*/
	Local aCampos := {}

	Private _cPerg	:= "ADEST047P"	//"ADEDA009P" 
	Private oTempTable
	Private oReport
	Private cAliasTRB := ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Função criada para apresentar uma tela para preenchimento das informações que serão utilizadas no processamento do projeto de ajuste do consumo de massa de frango')

    If Select("TRB") > 0
        TRB->( dbCloseArea() )
    EndIf
		
	// Crio TRB para impressão
	// https://tdn.totvs.com.br/display/framework/FWTemporaryTable
	oTempTable := FWTemporaryTable():New("TRB")
	
	// Arquivo TRB
	aAdd( aCampos, {'G1_COD'     ,TamSX3("G1_COD")[3]     ,TamSX3("G1_COD")[1], 0} )
	aAdd( aCampos, {'G1_COMP'    ,TamSX3("G1_COMP")[3]    ,TamSX3("G1_COMP")[1], 0} )
	aAdd( aCampos, {'PERIODO'    ,"C"                     ,6  , 0} )
	aAdd( aCampos, {'TIPOERRO'   ,"C"                     ,20 , 0} )
	aAdd( aCampos, {'TABELA'     ,"C"                     ,3  , 0} )
	aAdd( aCampos, {'DETALHE'    ,"C"                     ,254, 0} )

	oTempTable:SetFields(aCampos)
	oTempTable:AddIndex("01", {"G1_COD","G1_COMP"} )
	oTempTable:Create()

	AjustaSX1(_cPerg)
	Pergunte(_cPerg, .F.)
	
	DEFINE MSDIALOG oDlg FROM  96,9 TO 320,612 TITLE OemToAnsi("Consumo de Massa de Frango") PIXEL

		@ 16, 15 SAY OemToAnsi("Este programa efetua o ajuste do consumo de massa de frango.") SIZE 268, 8 OF oDlg PIXEL
		
		DEFINE SBUTTON FROM 93, 163 TYPE 15 ACTION ProcLogView(cFilAnt,"ADEST047P") ENABLE OF oDlg
		DEFINE SBUTTON FROM 93, 193 TYPE 5  ACTION Pergunte(_cPerg,.T.) ENABLE OF oDlg
		DEFINE SBUTTON FROM 93, 223 TYPE 1  ACTION If(.T.,(Processa({|lEnd| ADEDA009A()},OemToAnsi("Cálcula o ajuste do consumo"),OemToAnsi("Efetuando o cálculo do ajuste..."),.F.),oDlg:End()),) ENABLE OF oDlg
		DEFINE SBUTTON FROM 93, 253 TYPE 2  ACTION oDlg:End() ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED 

//	oTempTable:Delete()

	If !Empty(cHrIni) .and. !Empty(cHrFim) //.and. lOkEST017P
		Aviso("Fim", "Cálculos dos ajustes de consumo finalizados!" + ENTER + ENTER + "Iniciado as: " + cHrIni + ENTER + "Finalizado as: " + cHrFim, {"OK"}, 3)
	EndIf
	
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

	Local cAliasSG1 := GetNextAlias()
	Local dDtFecha	:= SuperGetMV("MV_ULMES")	/*Data do último fechamento do estoque.*/

	/*Processamento*/
	Private _cCodMassa	:= SuperGetMV("MV_XCODMAS", .F., "323574")	/*Código da estrutura de massa usado nas condições de busca dos produtos*/
	Private _cFrangPad	:= SuperGetMV("MV_XPRDFV", .F., "")	/*Código do Produto Frango Vivo pega pegar o Custo Médio dele na filial 03*/
	Private _nPrecoMed 	:= 0	/*Valor do Preço Médio de Venda encontrado no cálculo feito das informações retornadas da query*/		
	Private _nPrecoCus 	:= 0	/*Valor do Preço de Custo encontrado no cálculo feito dos valores da pergunta e o Preço Médio de Venda*/
	Private _nFator		:= 0	/*Valor do Fator encontrado no cálculo feito entre o Preço de Custo e o Preço Médio de Venda*/

	/*Relatório*/
	Private _aDados := {}	

	cHrIni := Time()

	ProcLogIni( {},"ADEST047P")
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
	_cMens += "Código da estrutura de massa (MV_XCODMAS): " + _cCodMassa + CRLF
	_cMens += "Código do Produto Frango Vivo para Custo Médio na filial 03 (MV_XPRDFV): " + _cFrangPad + CRLF + CRLF	
	
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
	
	DbSelectArea(cAliasSG1)
	Dbgotop()
	
	ProcRegua((cAliasSG1)->(RecCount()))
	
	_cMens += "Calculando o Preço Médio das notas de saída retornadas da busca." + CRLF
	
	(cAliasSG1)->(Dbgotop())
	
	IncProc("Buscando as informações..")

	nSomaQuant := 0
	nSomaTotal := 0
	Do While (cAliasSG1)->( !EOF() )
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
	//U_ADEST015P()
    u_new015P()

	ProcLogAtu("FIM",,_cMens)

	cHrFim := Time()

Return

/*/{Protheus.doc} User Function NEW015P
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
User Function New015P(lExterno, lRetorno)

	/*Processamento*/
	Local oDlg						/*Objeto usado para o MSDIALOG*/

	Local cLocal	 := RetFldProd(_cFrangPad, "B1_LOCPAD") /*Função padrão do Protheus para retornar o local(armazém) usado no SBZ para o Produto*/
	Local nPrcMedVen := _nPrecoMed 	/*Valor do Preço Médio de Venda calculado anteriormente*/
	Local nPrcFrango := 0			/*Valor do Custo do Frango Vivo que será calculado posteriormente pegando o B2_CM1*/
	Local nPrcQuebra := mv_par02		/*Valor do Custo de Quebra digitado nos parâmetros da pergunta feita inicialmente*/
	Local nPrcAbate	 := mv_par03		/*Valor do Custo de Abate digitado nos parâmetros da pergunta feita inicialmente*/

	Default lExterno := .F.
	Default lRetorno := .F.

	U_ADINF009P('ADEST047P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Função para mostrar o resultrado do Preço Médio de Venda calculado em uma tela e ter a opção de realizar o ajuste de consumo de massa de frango')

	nPrcFrango := ADEDA009E(_cFrangPad)
	
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

	/*Processamento*/
	Local cAntCod	:= ""
	Local nQuant	:= 0
	Local nTotal	:= 0

	/*Relatório*/
	Local oReport		/*Objeto do Report do Relatório*/

	/*Relatório*/
	Private _oSection1	/*Section Utilizada no Report do Relatório*/
	
	_cMens += "Valores ATUALIZADOS" + CRLF
	_cMens += "Custo Apurado: " + TRANSFORM(_nPrecoCus, "@E 999,999,999.9999") + CRLF
	_cMens += "Fator: " + TRANSFORM(_nFator, "@E 999,999,999.9999") + CRLF
	
	/*Se Lista Càlculo do parâmetro da pergunta for igual a 'SIM' eu crio a estrutura para gerar o relatório*/
	/*
	If mv_par04 == 1
		_cMens += "Gerando o relatório para análise do usuário." + CRLF			
		oReport := ReportDef("Atual")
		oReport:PrintDialog()
	EndIf	
	*/
	
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
		
		IF nQuant == 0
			LOOP
		ENDIF
		
		If x+1 <= Len(_aDados)

			If ALLTRIM(cAntCod) <> ALLTRIM(_aDados[x+1,01])	
				lOkEST017P := U_newEST17(nTotal, nQuant, _aDados[x,01])
				If !lOkEST017P
					Exit
				EndIf
			EndIf

		Else

			lOkEST017P := U_newEST17(nTotal, nQuant, _aDados[x,01])
			If !lOkEST017P
				Exit
			EndIf

		EndIf
		
	Next x
	
	If !lOkEST017P
		Return .f.
	EndIf

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

	Local nCusto     := 0 
	Local cAliasSD2  := GetNextAlias()   
	Local cSD3TM	 := ALLTRIM(GetMv('MV_XTMPRD',.F., "010"))
	Local cFilCurren := FWxFilial("SD3")

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

/*/{Protheus.doc} User Function ADEST016
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
Static Function ADEST016(cCod)

	Local nProduzido := 0 
	Local cAliasSD3  := GetNextAlias()   
	Local cSD3TM	 := ALLTRIM(GetMv('MV_XTMPRD',.F.,"010"))
	Local cFilCurren := FWxFilial("SD3")

	U_ADINF009P('ADEST047P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Calculo do total produzido')

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

	//Estruturas de massa dos produtos e das massas que possuem movimentações

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
	
	Do While (cAliasSD3)->(! EOF())
		nConsumido += (cAliasSD3)->QTDE
	EndDo                      
	
	DbCloseArea(cAliasSD3)
	
Return nConsumido

/*/{Protheus.doc} User Function newEST17 (ADEST017)
	Função que agrega esforço UPS oriundo do sistema UEP
	@type  Static Function
	@author Fernando Macieira
	@since 27/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
    @chamado n. 057910 || OS 059411 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || PROJETO UEP
/*/
User Function newEST17(nTotal, nQuanti, cCod, lExterno, nPreco)

	Local cAliasSD3	:= GetNextAlias()
	Local cAlias	:= ""
	Local cQuery	:= ""
	Local cSD3TM	:= ALLTRIM(GetMv('MV_XTMPRD',.F., "010"))
	Local nNovoVal 	:= _nFator
	Local lUpdOk    := .t. 
    Local nFatorUPS := 0
    Local cNotUPS   := GetMV("MV_#UPSNOT",,"323575") // Produto que não deverá considerar valor UPS
	Local lTemPRD   := .f.

	Default lExterno:= .F.
	Default nPreco 	:= 0

	U_ADINF009P('ADEST047P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	// Checo se possui produção mas não possui UPS
	lTemPRD := ChkUPS(cCod, _cCodMassa)
		
	// Busco fator UPS
	If !(AllTrim(_cCodMassa) $ AllTrim(cNotUPS))
		
		nFatorUPS := GetUPS(cCod, _cCodMassa)

		If nFatorUPS > 0
			_nFator := nFatorUPS
		Else
			/*
			If lTemPRD
				GravaTRB(cCod, _cCodMassa, "MOVIMENTO")
			Else
				GravaTRB(cCod, _cCodMassa, "SEM UPS")
			EndIf
			*/
		EndIf

	EndIf
	//

	nNovoVal := _nFator 
	//nNovoVal := _nFator * IIF( lExterno, nPreco, ( nTotal / nQuanti ) )

	Begin Transaction

		lUpdOk    := .t.
		nStatus := TCSQLExec("UPDATE SG1010 SET G1_XANTQNT=G1_QUANT, G1_QUANT=" + ALLTRIM(STR(nNovoVal)) + " WHERE D_E_L_E_T_=' ' AND G1_COD='" + cCod + "'" +;
					" AND G1_COMP='" + _cCodMassa + "'")

		If nStatus < 0
			//GravaTRB(cCod, _cCodMassa, "UPDATE", "SG1")
			lUpdOk    := .f.
			msgAlert("UPDATE na tabela SG1010 não foi realizado! Envie o erro que será mostrado na próxima tela ao TI... A rotina será abortada e não será finalizada!")
			MessageBox(tcSqlError(),"",16)
			DisarmTransaction()
			Return lUpdOk
		EndIf

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
		
        Do While !(cAliasSD3)->(EOF())
		
        	nValQntAnt := (cAliasSD3)->D3_QUANT

			nQuantReal := 0
			cAliasD32  := GetNextAlias()

			cQuery := " SELECT D3_QUANT "
			cQuery += " FROM " + RetSqlName("SD3") + " SD3 (NOLOCK) "
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

			// degug
			If AllTrim((cAliasSD3)->D3_OP) == "06690501001"
				cDebug := ""
			EndIf
			// debug

			If lUpdOk
				nStatus := TCSQLExec("UPDATE SD3010 SET D3_QUANT=" + ALLTRIM(STR(nQuantReal*(cAliasSD3)->G1_QUANT)) + ", D3_XQDEANT=" + ALLTRIM(STR(nValQntAnt)) + " WHERE D_E_L_E_T_=' ' AND D3_COD='" + (cAliasSD3)->D3_COD + "'" +;
							" AND D3_OP='" + (cAliasSD3)->D3_OP + "' AND D3_DOC='" + (cAliasSD3)->D3_DOC + "'")

				If nStatus < 0
					//GravaTRB(cCod, _cCodMassa, "UPDATE", "SD3")
					lUpdOk    := .f.
					msgAlert("UPDATE na tabela SD3010 não foi realizado! Envie o erro que será mostrado na próxima tela ao TI... A rotina será abortada e não será finalizada!")
					MessageBox(tcSqlError(),"",16)
					DisarmTransaction()
					Return lUpdOk
					Exit
				EndIf
			EndIf

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
			AND B1_COD BETWEEN %Exp:mv_par04% AND %Exp:mv_par05%
			AND G1_COMP = %Exp:_cCodMassa%
			AND G1_FILIAL = %xfilial:SG1%
			AND A1_COD = D2_CLIENTE
			AND A1_LOJA = D2_LOJA
			AND F4_CODIGO = D2_TES
			AND F4_DUPLIC = 'S'		

	EndSql
	
	DbSelectArea(cAliasSD2)
	Dbgotop()

	Do While !(cAliasSD2)->(EOF())
		
		nRet := ( (cAliasSD2)->TOT - (cAliasSD2)->TOTALDEV ) / ( (cAliasSD2)->QUANT - (cAliasSD2)->QUANTDEV )

		(cAliasSD2)->(DbSkip())

	EndDo

	DbSelectArea(cAliasSD2)
	dbCloseArea(cAliasSD2)

Return nRet

/*/{Protheus.doc} Static Function ADEDA009I
	()
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

	Local cAliasSD2  := GetNextAlias()
	Local cCodMasAux := _cCodMassa
    Local nFatorUPS  := 0
    Local cNotUPS    := GetMV("MV_#UPSNOT",,"323575") // Produto que não deverá considerar valor UPS

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
		
		Do While !(cAliasSD2)->(EOF())

			_cCodMassa := (cAliasSD2)->G1_COMP

			nQuant += (cAliasSD2)->D2_QUANT - (cAliasSD2)->D2_QTDEDEV
			nTotal += (cAliasSD2)->D2_TOTAL - (cAliasSD2)->D2_VALDEV

			cAntComp:= (cAliasSD2)->G1_COMP
			
			If nQuant == 0
			    (cAliasSD2)->(DbSkip())
				Loop
			EndIf
			
            // Busco fator UPS
            If !(AllTrim(_cCodMassa) $ AllTrim(cNotUPS))
                
                nFatorUPS := GetUPS(cCodPA, _cCodMassa)

                If nFatorUPS > 0
                    _nFator := nFatorUPS
                Else
                    //GravaTRB(cCodPA, _cCodMassa, "SEM UPS")
					//cMensUEP += "Produto/Componente: " + cCodPA + "/" + _cCodMassa + " sem valor UPS."+ CRLF
                    //MessageBox("Valor UPS não encontrado na tabela ZFY para esta empresa/filial neste período! Verifique... Produto/Componente: " + cCodPA + "/" + _cCodMassa,"",16)
                    (cAliasSD2)->( dbSkip() )
                    Loop
                EndIf

            EndIf
			//

			(cAliasSD2)->(DbSkip())

			If cAntComp <> (cAliasSD2)->G1_COMP
				
                IncProc("Atualizando o fator do componente " + cAntComp + " de massa de frango na PA " + cCodPA)

				_cMens += "Pegando o item " + cAntComp + " para processar a atualizar o seu fator na estrutura da PA " + cCodPA + CRLF
				_cMens += "Atualizando o fator" + CRLF
				
				U_newEST17(nTotal, nQuant, cCodPA)

				nQuant 	:= 0
				nTotal 	:= 0
				
			EndIf

		EndDo

	EndIf
	
	DbSelectArea(cAliasSD2)
	dbCloseArea(cAliasSD2)
				
	_cCodMassa := cCodMasAux
	
Return Nil

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
	//³04 - Produto De		 ? ³
	//³05 - Produto Até		 ? ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ENDDOC*/
	//					1					2				3					4				5						6					7				8					9					10					11						12					13				14						15					16					17					18				19						20					21					22					23				24						25					26					27					28				29						30					31					32					33				34					35					36						37						38				39
    // AADD(/* 'X1_ORDEM' */, /* 'X1_PERGUNT'*/, /* 'X1_PERSPA' */, /* 'X1_PERENG' */, /* 'X1_TIPO' 	*/, /* 'X1_TAMANHO'*/, /* 'X1_DECIMAL'*/, /* 'X1_PRESEL' */, /* 'X1_GSC' 	*/, /* 'X1_VALID' 	*/	, /* 'X1_DEF01' 	*/, /* 'X1_DEFSPA1'*/, /* 'X1_DEFENG1'*/, /* 'X1_CNT01' 	*/, /* 'X1_VAR02' 	*/, /* 'X1_DEF02' 	*/, /* 'X1_DEFSPA2'*/, /* 'X1_DEFENG2'*/, /* 'X1_CNT02' 	*/, /* 'X1_VAR03' 	*/, /* 'X1_DEF03' 	*/, /* 'X1_DEFSPA3'*/, /* 'X1_DEFENG3'*/, /* 'X1_CNT03' 	*/, /* 'X1_VAR04' 	*/, /* 'X1_DEF04' 	*/, /* 'X1_DEFSPA4'*/, /* 'X1_DEFENG4'*/, /* 'X1_CNT04' 	*/, /* 'X1_VAR05' 	*/, /* 'X1_DEF05' 	*/, /* 'X1_DEFSPA5'*/, /* 'X1_DEFENG5'*/, /* 'X1_CNT05' 	*/, /* 'X1_F3'		*/, /* 'X1_PYME' 	*/, /* 'X1_GRPSXG' */	, /* 'X1_PICTURE'*/, /* 'X1_IDFIL' 	*/)

//					  1				2						3						4				  5			6						  7	 8		  9   10	 11	 12  13	  	  14  	  15  16  17   	  18   	  19  	  20  21  22  23  24  25  26  27  28  29  30  31  32  33  34  35      36   37  38  39	
    AADD( aMensSX1, {"01", "Mês de referência?"	, "Mês de referência?"	, "Mês de referência?"		,"D"	,008						,00, 0		,"G", ""	,""	,"" ,""		, ""	, "", "", "" 	, "" 	, ""	, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""    , "S", "", "", "" }) //"Informe a data inicial de emissão do global."}
    AADD( aMensSX1, {"02", "Custo de Quebra"	, "Custo de Quebra?"	, "Custo de Quebra?"		,"N"	,006						,02, 0		,"G", ""	,""	,""	,"" 	, ""	, "", "", "" 	, "" 	, ""	, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""    , "S", "", "", "" }) //"Informe a data final de emissão do global."}
	AADD( aMensSX1, {"03", "Custo de Abate ?"	, "Custo de Abate ?"	, "Custo de Abate ?"	    ,"N"	,006						,02, 0		,"G", ""	,""	,""	,""		, ""	, "", "", "" 	, "" 	, ""	, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""    , "S", "", "", "" }) //"Informe o codigo inicial do pallet do global"}
    AADD( aMensSX1, {"04", "Produto De?"		, "Produto De?"	    	, "Produto De?"		   		,"C"	,TamSX3("B1_COD")[1]		,00, 0		,"G", ""	,""	,""	,"" 	, ""	, "", "", "" 	, "" 	, ""	, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SB1" , "S", "", "", "" }) //"Informe o codigo final do pallet do global"}
	AADD( aMensSX1, {"05", "Produto Ate?"		, "Produto Ate?"		, "Produto Ate?"			,"C"	,TamSX3("B1_COD")[1]		,00, 0		,"G", ""	,""	,""	,"" 	, ""	, "", "", "" 	, "" 	, ""	, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SB1" , "S", "", "", "" }) //"Informe a data inicial de emissão da OP."}
    
    U_newGrSX1(_cPerg, aMensSX1)

Return

/*/{Protheus.doc} Static Function GetUPS
    Busca valor do fator UPS 
    @type  Static Function
    @author FWNM
    @since 27/05/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado n. 057910 || OS 059411 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || PROJETO UEP
/*/
Static Function GetUPS(cCodPA, _cCodMassa)

    Local nVlrUPS := 0
    Local cQuery  := ""

    If Select("WorkZFY") > 0
        WorkZFY->( dbCloseArea() )
    EndIf

    cQuery := " SELECT ZFY_UPS
    cQuery += " FROM " + RetSqlName("ZFY") + " ZFY (NOLOCK)
    cQuery += " WHERE ZFY_FILIAL='"+FWxFilial("ZFY")+"'
    cQuery += " AND ZFY_CODIGO='"+AllTrim(cEmpAnt)+"' 
    cQuery += " AND ZFY_EMPRES='"+AllTrim(Str(Val(cFilAnt)))+"'
    cQuery += " AND ZFY_MESANO='"+Subs(DtoS(MV_PAR01),5,2)+Left(DtoS(MV_PAR01),4)+"' 
    cQuery += " AND ZFY_PRODUT='"+cCodPA+"' 
    cQuery += " AND ZFY_UPABER='"+_cCodMassa+"' 
    cQuery += " AND D_E_L_E_T_=''

    tcQuery cQuery New Alias "WorkZFY"

	aTamSX3	:= TamSX3("ZFY_UPS")
	tcSetField("WorkZFY", "ZFY_UPS", aTamSX3[3], aTamSX3[1], aTamSX3[2])

    If WorkZFY->( !EOF() )
        nVlrUPS := WorkZFY->ZFY_UPS
        //MessageBox("Achou ZFY_UPS: " + cCodPA + "/" + _cCodMassa,"",16)
    EndIf

    If Select("WorkZFY") > 0
        WorkZFY->( dbCloseArea() )
    EndIf

    /*
    ZFY->( dbSetOrder(3) ) // ZFY_FILIAL, ZFY_CODIGO, ZFY_EMPRES, ZFY_MESANO, ZFY_PRODUT, ZFY_UPABER, R_E_C_N_O_, D_E_L_E_T_
    If ZFY->( dbSeek( cEmpAnt + AllTrim(Str(Val(cFilAnt))) + Subs(DtoS(MV_PAR01),5,2)+Left(DtoS(MV_PAR01),4) + PadR(cCodPA,Len(ZFY->ZFY_PRODUT)) + PadR(_cCodMassa,Len(ZFY->ZFY_UPABER)) ) )
        nVlrUPS := ZFY->ZFY_UPS
        MessageBox("Achou ZFY_UPS: " + cCodPA + "/" + _cCodMassa,"",16)
    EndIf
    */

Return nVlrUPS

/*/{Protheus.doc} User Function GeraUPS2
    Transforma movimentos Protheus com dados importados do sistema UEP para produtos sem faturamento
    @type  Function
    @author FWNM
    @since 01/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function GeraUPS2()

	Local lAtivo     := GetMV("MV_#UEPLIG",,.T.)
    Local cDescBox	 := "Período dos movimentos Protheus que serão agregados com o valor UPS"
	Local cAnoMes	 := Space(06)
	Local aParamBox  := {}   
	Local aRet 		 := {}

	Private _cMens	 := "" 
    Private cMensUEP := "" 
    Private cAliasTRB := "" 

    // Chego se o valor UPS do sistema UEP está ativo para ser utilizado
    If !lAtivo
        msgAlert("Função para agregar valor UPS do sistema UEP aos movimentos do Protheus não está liberada para uso! Contate a contabilidade...","Parâmetro: MV_#UEPLIG")
        Return
    EndIf
    
	// Garanto uma única thread sendo executada
	If !LockByName("ADEST047P", .T., .F.)
		Aviso("Atenção", "Existe outro processamento sendo executado! Verifique...", {"OK"}, 3)
		Return
	EndIf
	//

    /*
	Aadd( aParamBox,{ 1, "Período (Ano/Mês):", cAnoMes	,"","","","",80, .T. } )
		
	//If ParamBox( aParamBox, cDescBox, @aRet ) // com opção salvar
    If ParamBox( aParamBox, cDescBox, @aRet, , , , , , , , .F., .F. ) // Sem opção salvar 
        cAnoMes := aRet[1]
        MsAguarde({|| RunUPS(cAnoMes) },"Aguarde","Transformando movimentos Protheus com o valor UPS, período " + cAnoMes)
	EndIf
    */

    RunUPS2()

	//LOG • Agrega UPS (Prod s/ Faturamento)
	// – O mesmo filtro utilizado hoje + verificar se existe esse produto no painel da UEP (naquele período), independente do componente, Logo após deve verificar se o produto + componente contido no painel está preenchido na SG1.
	msAguarde( { || GeraLog(2, "Agrega UPS sem FAT") }, "Aguarde", "Processando conferências para geração de log " )
	//GeraLog(2, "Agrega UPS sem FAT")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADEST047P")
	//

    TRB->( dbGoTop() )
	If TRB->( !EOF() )
    
	    If msgYesNo("Processamento gerou logs. Deseja visualizá-los?")
            //MessageBox(cMensUEP,"",16)

			oReport := ReportDef(@cAliasTRB)
			oReport:PrintDialog()

        EndIf
    
	Else

		msgAlert("Nenhuma inconsistência encontrada... Log não gerado!")

	EndIf

Return

/*/{Protheus.doc} Static Function RunUPS2
    Processa transformação dos movimentos Protheus com valor UPS para produtos sem faturamento
    @type  Static Function
    @author user
    @since 01/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function RunUPS2()

	Local oDlg	/*Objeto usado para o MSDIALOG*/
	Local aCampos := {}

	Private _cPerg := "ADEST047P"  //"ADEST018P"	/*Nome da pergunta usado nas telas*/
	Private oTempTable
	Private oReport
	Private cAliasTRB := ""

    If Select("TRB") > 0
        TRB->( dbCloseArea() )
    EndIf
		
	// Crio TRB para impressão
	// https://tdn.totvs.com.br/display/framework/FWTemporaryTable
	oTempTable := FWTemporaryTable():New("TRB")
	
	// Arquivo TRB
	aAdd( aCampos, {'G1_COD'     ,TamSX3("G1_COD")[3]     ,TamSX3("G1_COD")[1], 0} )
	aAdd( aCampos, {'G1_COMP'    ,TamSX3("G1_COMP")[3]    ,TamSX3("G1_COMP")[1], 0} )
	aAdd( aCampos, {'PERIODO'    ,"C"                     ,6  , 0} )
	aAdd( aCampos, {'TIPOERRO'   ,"C"                     ,20 , 0} )
	aAdd( aCampos, {'TABELA'     ,"C"                     ,3  , 0} )
	aAdd( aCampos, {'DETALHE'    ,"C"                     ,254, 0} )

	oTempTable:SetFields(aCampos)
	oTempTable:AddIndex("01", {"G1_COD","G1_COMP"} )
	oTempTable:Create()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Função criada para apresentar uma tela para preenchimento das informações que serão utilizadas no processamento do  ajuste de consumo de massa de frango para produtos sem faturamento')

	AjustaSX1(_cPerg)
	Pergunte(_cPerg, .F.)
	
	DEFINE MSDIALOG oDlg FROM  96,9 TO 320,612 TITLE OemToAnsi("Massa de Frango") PIXEL
	
		@ 16, 15 SAY OemToAnsi("Este programa efetua o ajuste do consumo de massa de frango para itens sem faturamento.") SIZE 268, 8 OF oDlg PIXEL
		
		DEFINE SBUTTON FROM 93, 163 TYPE 15 ACTION ProcLogView(cFilAnt, _cPerg) ENABLE OF oDlg
		DEFINE SBUTTON FROM 93, 193 TYPE 5  ACTION Pergunte(_cPerg, .T.) ENABLE OF oDlg
		DEFINE SBUTTON FROM 93, 223 TYPE 1  ACTION If(.T., ( Processa( {|lEnd| ADEST018G()}, OemToAnsi("Cálcula o ajuste do consumo"), OemToAnsi("Efetuando o cálculo do ajuste..."), .F.), oDlg:End() ), ) ENABLE OF oDlg
		DEFINE SBUTTON FROM 93, 253 TYPE 2  ACTION oDlg:End() ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED 

	If !Empty(cHrIni) .and. !Empty(cHrFim) //.and. lOkEST017P
		Aviso("Fim", "Cálculos dos ajustes de consumo para produtos sem faturamento finalizados!" + ENTER + ENTER + "Iniciado as: " + cHrIni + ENTER + "Finalizado as: " + cHrFim, {"OK"}, 3)
	EndIf
	
Return

/*/{Protheus.doc} Static Function ADEST018G
	(long_description)
	@type  Static Function
	@author user
	@since 01/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
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

	cHrIni := Time()

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
	
	Do While !(cAlias)->(EOF())
		
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
	
	Do While !(cAlias)->(EOF())
	
		IncProc("Pegando os dados para montar a tela..")
		
		If (cAlias)->D2_QUANT - (cAlias)->D1_QUANT == 0
		
			AADD( _aDados, { .F.                 			                               ,;
							 (cAlias)->D2_FILIAL		 	                               ,;
							 (cAlias)->D2_COD			 	                               ,;
							 Posicione("SB1",1,xFilial("SB1")+(cAlias)->D2_COD,"B1_DESC") ,;
							 ADEST016((cAlias)->D2_COD)	                              ,;
							 0							 	                              ,;
							 nCustoVivo / _nPrecoMed                 		              ,;
							 .F.								                         } )
						 
		EndIf
						 
		(cAlias)->(DbSkip())
	
	EndDo
	
	DbSelectArea(cAlias)
	dbCloseArea()
	
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
		//GravaTRB("", _cCodMassa, "SEM MOVIMENTO")
		_cMens += "Não foi encontrado nenhuma informação para gerar a tela e processar." + CRLF
		Return
	EndIf
	
	IncProc("Buscando as informações..")
	
	_cMens += "Montando a tela com as informação para gerar a tela e processar." + CRLF
	
	Do While !(cAlias)->(EOF())
	
		IncProc("Pegando os dados para montar a tela..")
	
		aAdd( _aDados, { .F.                 			,;
						 (cAlias)->D3_FILIAL		 	,;
						 (cAlias)->D3_COD			 	,;
						 (cAlias)->B1_DESC 			 	,;
						 ADEST016((cAlias)->D3_COD)	,;
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

	cHrFim := Time()
	
Return

/*/{Protheus.doc} Static Function ADEST018A
	(long_description)
	@type  Static Function
	@author user
	@since 01/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
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

				aAdd( aHeader, { 	AllTrim( X3Titulo() ),; // 01 - Titulo
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
			
	oTela:Activate(,,,.T.,/*valid*/,,{|| .T.})

Return

/*/{Protheus.doc} Static Function ADEST018B
	Rotina para selecionar todos os itens 
	@type  Static Function
	@author KFSystem
	@since 01/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ADEST018B(nOpc,aDados,oGDSel,nColSel,aHead)

	Local ni		:= 0
	Local cRoteiro	:= ""

	For ni := 1 to Len(aDados)

		If !aDados[ni][8]
			
			aDados[ni][1] := !aDados[ni][1]
			
			If aDados[ni][1]
				aAdd(_aSelecIte, ni)
			Else
				_aSelecIte := {}
			EndIf
			
		EndIf

	Next ni
	
	//Forcar a atualizacao do browse
	oGDSel:DrawSelect()

Return Nil

/*/{Protheus.doc} Static Function ADEST018C
	Rotina pra fazer o tratamento de selecao de dados
	@type  Static Function
	@author user
	@since 01/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
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
			aAdd(_aSelecIte, oGDSel:nAt)
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

/*/{Protheus.doc} Static Function ADEST018D
	Botão Processamento
	@type  Static Function
	@author user
	@since 01/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ADEST018D(aCols, oGDSel)

	Local aDelets := {}
	
	For x:=1 To Len(aCols)

		If aCols[x,1] .AND. !aCols[x,8]
			
			BeginTran()

				_nFator := aCols[x,7]
			
				/*Atualiza o código zmassa para itens sem faturamento*/
				U_newEST17(0,0, aCols[x,3], .T., aCols[x,6]) // U_ADEST017
	
			EndTran()

			aAdd(aDelets, x)
						
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

/*/{Protheus.doc} Static Function ADEST018E
	(long_description)
	@type  Static Function
	@author user
	@since 01/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ADEST018E(cCodPA, nPrcVend)

	Local cAlias 	 := GetNextAlias()
	Local cCodMasAux := _cCodMassa
    Local nFatorUPS  := 0
    Local cNotUPS    := GetMV("MV_#UPSNOT",,"323575") // Produto que não deverá considerar valor UPS

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
	
	Do While !(cAlias)->(EOF())
		
		_cMens += "Pegando o item " + (cAlias)->G1_COMP + " para processar a atualizar o seu fator na estrutura da PA " + cCodPA + CRLF
		
		_cCodMassa := (cAlias)->G1_COMP
		
		_cMens += "Atualizando o fator" + CRLF
		
		// Busco fator UPS
		If !(AllTrim(_cCodMassa) $ AllTrim(cNotUPS))
			
			nFatorUPS := GetUPS(cCodPA, _cCodMassa)

			If nFatorUPS > 0
				_nFator := nFatorUPS
			Else
				//GravaTRB(cCodPA, _cCodMassa, "SEM UPS")
				//cMensUEP += "Produto/Componente: " + cCodPA + "/" + _cCodMassa + " sem valor UPS."+ CRLF
				//MessageBox("Valor UPS não encontrado na tabela ZFY para esta empresa/filial neste período! Verifique... Produto/Componente: " + cCodPA + "/" + _cCodMassa,"",16)
				(cAlias)->( dbSkip() )
				Loop
			EndIf

		EndIf
		//

		U_newEST17(0,0, cCodPA, .T., nPrcVend) // U_ADEST017
		
		(cAlias)->( DbSkip() )

	EndDo
	
	DbSelectArea(cAlias)
	dbCloseArea()
				
	_cCodMassa := cCodMasAux
	
Return Nil

/*/{Protheus.doc} Static Function ADEST018F
	Botao Ajuste Fator
	@type  Static Function
	@author user
	@since 01/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
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
	
	//U_ADEST015( .T., @lRetorno )
	u_new015P(.T., @lRetorno)

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

/*/{Protheus.doc} Static Function ADEST018H
	Calculo do custo medio de produção do mes de referencia 
	@type  Static Function
	@author user
	@since 01/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
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

/*/{Protheus.doc} Static Function GravaTRB
	Popula arquivo TRB para montar excel de log no final do processamento
	@type  Static Function
	@author user
	@since 17/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function GravaTRB(cRotina, cCodPA, cComponente, cTabela, cDetalhe)

	Local cAnoMes := Left(DtoS(MV_PAR01),6)

	Default cRotina     := ""
	Default cCodPA      := ""
	Default cComponente := ""
	Default cTabela     := ""
	Default cDetalhe    := ""
	
	RecLock("TRB", .T.)

		TRB->G1_COD   := cCodPA
		TRB->G1_COMP  := cComponente
		TRB->PERIODO  := cAnoMes
		TRB->TIPOERRO := cRotina
		TRB->TABELA   := cTabela
		TRB->DETALHE  := cDetalhe

	TRB->( msUnLock() )
	
Return

/*/{Protheus.doc} Static Function ReportDef
	ReportDef
	@type  Function
	@author Fernando Macieira
	@version 01
/*/
Static Function ReportDef(cAliasTRB)
                                   
	Local oReport
	Local oProdutos
	Local aOrdem := {}
	  
	Local oBreak1
	Local oBreak2
	Local oFunc1
	Local oFunc2
	
	Local cTitulo := "UEP - Log produtos/componentes sem valor UPS "

	cAliasTRB := "TRB"
	
	oReport := TReport():New("ADEST047R",OemToAnsi(cTitulo), /*cPerg*/, ;
	{|oReport| ReportPrint(cAliasTRB)},;
	OemToAnsi(" ")+CRLF+;
	OemToAnsi("")+CRLF+;
	OemToAnsi("") )

	oReport:nDevice     := 4 // XLS

	oReport:SetLandscape()
	//oReport:SetTotalInLine(.F.)
	
	oProdutos := TRSection():New(oReport, OemToAnsi(cTitulo),{"TRB"}, aOrdem /*{}*/, .F., .F.)
	//oReport:SetTotalInLine(.F.)
	
	TRCell():New(oProdutos,	"G1_COD"     ,"","Produto"        /*Titulo*/,  /*Picture*/,TamSX3("G1_COD")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProdutos,	"G1_COMP"    ,"","Componente"     /*Titulo*/,  /*Picture*/,TamSX3("G1_COMP")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProdutos,	"PERIODO"    ,"","Período"        /*Titulo*/,  /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProdutos,	"TIPOERRO"   ,"","Rotina"         /*Titulo*/,  /*Picture*/,20 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProdutos,	"TABELA"     ,"","Tabela"         /*Titulo*/,  /*Picture*/,6 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProdutos,	"DETALHE"    ,"","Detalhe"        /*Titulo*/,  /*Picture*/,254 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

	//oBreak1 := TRBreak():New(oReport,oProdutos:Cell("NNR_CODIGO"),"S",.F.)
	
	//TRFunction():New(oProdutos:Cell("B9_QINI"),NIL,"SUM",oBreak1,"","@E 999,999,999,999,999.99",/*uFormula*/,.F.,.F.)
	
	//oBreak1:SetTitle('Totais Fornecedor')
	
	//oReport:SetLineStyle()

Return oReport

/*/{Protheus.doc} Static Function ReportPrint
	ReportPrint
	@type  Function
	@version 01
/*/
Static Function ReportPrint(cAliasTRB)

	Local oProdutos := oReport:Section(1)
	
	dbSelectArea("TRB")
	TRB->( dbSetOrder(1) )
	
	oProdutos:SetMeter( LastRec() )
	
	TRB->( dbGoTop() )
	Do While TRB->( !EOF() )
		
		oProdutos:IncMeter()
		
		oProdutos:Init()
		
		If oReport:Cancel()
			oReport:PrintText(OemToAnsi("Cancelado"))
			Exit
		EndIf
		
		//Impressao propriamente dita....
		oProdutos:Cell("G1_COD")    :SetBlock( {|| TRB->G1_COD} )
		oProdutos:Cell("G1_COMP")   :SetBlock( {|| TRB->G1_COMP} )
		oProdutos:Cell("PERIODO")   :SetBlock( {|| TRB->PERIODO} )
		oProdutos:Cell("TIPOERRO")  :SetBlock( {|| TRB->TIPOERRO} )
		oProdutos:Cell("TABELA")    :SetBlock( {|| TRB->TABELA} )
		oProdutos:Cell("DETALHE")   :SetBlock( {|| TRB->DETALHE} )

		oProdutos:PrintLine()
		oReport:IncMeter()
	
		TRB->( dbSkip() )
		
	EndDo
	
	oProdutos:Finish()

	If Select("TRB") > 0
		TRB->( dbCloseArea() )
	EndIf
	
	If Select("QRY") > 0
		QRY->( dbCloseArea() )
	EndIf
	
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	
	//oTempTable:Delete()  

Return

/*/{Protheus.doc} Static Function ChkUPS(cCod, _cCodMassa)
	Checa se possui produção mas não possui UPS
	@type  Static Function
	@author FWNM
	@since 06/07/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ChkUPS(cCod, _cCodMassa)

	Local cDebug  := ""
	Local cQuery  := ""
	Local lTemPRD := .F.

	If Select("WorkPRD") > 0
		WorkPRD->( dbCloseArea() )
	EndIf

	cQuery := " SELECT COUNT(1) TT 
	cQuery += " FROM " + RetSqlName("SD3") + " (NOLOCK)
	cQuery += " WHERE D3_FILIAL='"+FWxFilial("SD3")+"' 
	cQuery += " AND D3_EMISSAO LIKE '"+Left(DtoS(MV_PAR01),6)+"%'
	cQuery += " AND D3_COD='"+cCod+"'
	cQuery += " AND D3_TM LIKE 'PR%'
	cQuery += " AND D3_OP<>''
	cQuery += " AND D3_ESTORNO=''
	cQuery += " AND D_E_L_E_T_=''

	tcQuery cQuery New Alias "WorkPRD"

	If WorkPRD->TT >= 1
		lTemPRD := .T.
	EndIf

	If Select("WorkPRD") > 0
		WorkPRD->( dbCloseArea() )
	EndIf

Return lTemPRD

/*/{Protheus.doc} Static Function GeraLog()
	•	Agrega UPS – A rotina deve filtrar na SD3, da filial 02, todos os registros com TM 010 e verificar se existe esse produto no painel da UEP (naquele período), independente do componente, Logo após deve verificar se o produto + componente contido no painel está preenchido na SG1.
	•	Agrega UPS (Prod s/ Faturamento) – O mesmo filtro utilizado hoje + verificar se existe esse produto no painel da UEP (naquele período), independente do componente, Logo após deve verificar se o produto + componente contido no painel está preenchido na SG1.
	@type  Function
	@author FWNM
	@since 19/08/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function GeraLog(nRotina, cRotina)

	Local cQuery     := ""
	Local cSD3TM     := ALLTRIM(GetMv('MV_XTMPRD', .F., "010"))
	Local cSD3Fl     := GetMV("MV_#FILUEP",,"02")
	Local cMesAno    := Subs(DtoS(MV_PAR01),5,2) + Left(DtoS(MV_PAR01),4)
	Local _cCodMassa := SuperGetMV("MV_XCODMAS", .F., "323574")	/*Código da estrutura de massa usado nas condições de busca dos produtos*/

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf


	If nRotina == 1 // Agrega UPS
	
		cQuery := " SELECT DISTINCT D3_COD
		cQuery += " FROM " + RetSqlName("SD3") + " SD3 (NOLOCK)
		cQuery += " WHERE D3_FILIAL='"+cSD3Fl+"' 
		cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(FirstDate(MV_PAR01))+"' AND '"+DtoS(LastDate(MV_PAR01))+"'
		cQuery += " AND D3_TM='"+cSD3TM+"'
		cQuery += " AND D3_ESTORNO='' 
		cQuery += " AND SD3.D_E_L_E_T_=''

		tcQuery cQuery New Alias "Work"


	// Agrega UPS (sem faturamento)
	ElseIf nRotina == 2 

		/*Query usada para pegar todos os produtos de várzea que deverão ser feitos os ajustes de consumo de massa de frango e não possuem saídas*/
		BeginSql Alias "Work"
			
			SELECT DISTINCT D3_FILIAL, D3_COD, B1_DESC
			FROM %table:SD3% SD3A (NOLOCK), %table:SB1% SB1 (NOLOCK) 
			WHERE SD3A.%notDel% AND SB1.%notDel%
				AND SD3A.D3_EMISSAO BETWEEN %Exp:DTOS(FIRSTDATE(MONTHSUB(mv_par01, 2)))% AND %Exp:DTOS(LASTDATE(mv_par01))%
				AND SD3A.D3_FILIAL = %xFilial:SD3%
				AND SD3A.D3_COD BETWEEN %Exp:mv_par04% AND %Exp:mv_par05%
				AND SD3A.D3_COD = B1_COD
				AND B1_FILIAL = %xFilial:SB1%
				AND SD3A.D3_TM = %Exp:cSD3TM%
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

	EndIf

	// Grava Log
	Work->( dbGoTop() )
	Do While Work->( !EOF() )

		ZFY->( dbSetOrder(1) ) // ZFY_FILIAL, ZFY_MESANO, ZFY_PRODUT, R_E_C_N_O_, D_E_L_E_T_	
		If ZFY->( !msSeek(FWxFilial("ZFY")+cMesAno+Work->D3_COD) )
			GravaTRB(cRotina, Work->D3_COD, "", "SD3", "Produto não existe no Painel UEP neste período")
		Else
			Do While ZFY->( !EOF() ) .and. ZFY->ZFY_FILIAL==FWxFilial("ZFY") .and. ZFY->ZFY_MESANO==cMesAno .and. ZFY->ZFY_PRODUT==Work->D3_COD
				SG1->( dbSetOrder(1) ) // G1_FILIAL, G1_COD, G1_COMP, G1_TRT, R_E_C_N_O_, D_E_L_E_T_
				If SG1->( !msSeek(FWxFilial("SG1")+ZFY->(ZFY_PRODUT+ZFY_UPABER)) )
					GravaTRB(cRotina, ZFY->ZFY_PRODUT, ZFY->ZFY_UPABER, "SG1", "Produto/Componente não existe na estrutura de produtos")
				EndIf
				ZFY->( dbSkip() )
			EndDo
		EndIf

		Work->( dbSkip() )

	EndDo

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	
Return
