#include "Protheus.ch"
#include "FWMVCDef.ch"

// Variaveis estaticas
Static cRotina  := "[ ADORO ] - ADEST036P "
Static cTitulo  := "[ ADORO ] - Subprodutos - Variแveis - Custo Ceres ADORO "
          
Static cEmpSIG  := GetMV("MV_#EMPSIG",,"02")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADEST036P บAutor  ณFernando Macieira   บ Data ณ 13/11/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calculo custo CERES                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ADORO                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ADEST036P()

	Local oBrowse
	Local aAreaAtu := GetArea()          
	Local cFunBkp  := FunName()

	SetFunName("ADEST036P")

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Calculo custo CERES')
	
	// Consiste se o usuแrio estแ na empresa correta para utilizar esta ROTINA
	If cEmpSIG <> cEmpAnt
		Aviso("MV_#EMPSIG", "Empresa nใo autorizada para utilizar esta rotina!", {"OK"}, 3)
		Return
	EndIf
	
	// Reseto quando chamada ocorre dentro de outro MVC
	If AllTrim(cFunBkp) <> "ADEST036P"
		aRotina := {}       
	EndIf
	
	// Instanciando FWMBROWSE - Somente com dicionario de dados
	oBrowse := FWMBrowse():New()
	
	// Setando a tabela de cadastros 
	oBrowse:SetAlias("ZCS")
	
	// Setando a descricao da rotina
	oBrowse:SetDescription(cTitulo)
	
	// Ativa o browse
	oBrowse:Activate()
	
	SetFunName(cFunBkp)
	RestArea(aAreaAtu)   

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADEST036P บAutor  ณFernando Macieira   บ Data ณ 13/11/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Criacao do MENU MVC                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ADORO                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MenuDef()

	Local aRot := {}
	
	// Adicionando opcoes
	ADD OPTION aRot TITLE "Visualizar"    ACTION "VIEWDEF.ADEST036P" OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // OPERACAO 1
	ADD OPTION aRot TITLE "Incluir"       ACTION "VIEWDEF.ADEST036P" OPERATION MODEL_OPERATION_INSERT ACCESS 0 // OPERACAO 3
	ADD OPTION aRot TITLE "Alterar"       ACTION "VIEWDEF.ADEST036P" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // OPERACAO 4
	ADD OPTION aRot TITLE "Excluir"       ACTION "u_zTOkExc" 		 OPERATION MODEL_OPERATION_DELETE ACCESS 0 // OPERACAO 5
	ADD OPTION aRot TITLE "Calcular"      ACTION "u_ADEST037P" 	 	 OPERATION MODEL_OPERATION_DELETE ACCESS 0 // OPERACAO 5
	ADD OPTION aRot TITLE "Transformar"   ACTION "u_ADEST038P" 	  	 OPERATION MODEL_OPERATION_DELETE ACCESS 0 // OPERACAO 5

Return aRot

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADEST036P บAutor  ณFernando Macieira   บ Data ณ 13/11/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Criacao do MODELO de dados MVC                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ADORO                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ModelDef()

	// Criacao do objeto do modelo de dados
	Local oModel  := Nil                   
	Local aZCRZCS := {}
	
	Local bVldPre := {|| .T.} // Antes de abrir a tela
	Local bVldPos := {|| u_zTOkPos() } // Validacao ao clicar no botao confirmar
	Local bVldCom := {|| .T.} // Funcao chamada no commit
	Local bVldCan := {|| .T.} // Funcao chamada no cancelar
	
	// Criacao da estrutura de dados utilizada na interface
	Local oStPai   := FWFormStruct(1, "ZCS")
	Local oStFilho := FWFormStruct(1, "ZCR")
	 
	// Editando caracteristicas do dicionario
	oStPai:SetProperty("ZCS_DATREF", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, 'u_ChkZCS()')) // Validacao
	
	// Criando o modelo e os relacionamentos
	oModel := MPFormModel():New("MODELDEF_MVC")
	
	oModel:AddFields("ZCSMASTER", /*cOwner*/, oStPai)
	oModel:AddGrid("ZCRDETAIL", "ZCSMASTER", oStFilho, /*bLinePre*/, /*bLinePost*/, /*bPre - Grid Inteiro*/, bVldPos, /*bLoad - Carga Modelo*/)
	
	// Fazendo relacionamento entre pai e filho
	aAdd( aZCRZCS, {"ZCR_FILIAL", "ZCS_FILIAL"} )
	aAdd( aZCRZCS, {"ZCR_DATREF", "ZCS_DATREF"} )
	
	oModel:SetRelation("ZCRDETAIL", aZCRZCS, ZCR->(IndexKey(1)) ) // IndexKey -> quero a ordenacao e depois filtrado
	oModel:GetModel("ZCRDETAIL"):SetUniqueLine({"ZCR_PRODUT"}) // Nao repetir informacoes ou combinacoes {"CAMPO1", "CAMPO2", "CAMPON"}
	oModel:SetPrimaryKey( {} )
	
	// Setando as descricoes
	oModel:SetDescription(cTitulo)
	oModel:GetModel("ZCSMASTER"):SetDescription("Perํodo e Valores Contแbeis")
	oModel:GetModel("ZCRDETAIL"):SetDescription("Produtos")

Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADEST036P บAutor  ณFernando Macieira   บ Data ณ 13/11/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Criacao da VISAO MVC                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ADORO                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ViewDef()

	// Criacao do objeto do modelo de dados da interface do cadastro
	Local oModel := FWLoadModel("ADEST036P")
	
	// Criacao da estrutura de dados utilizada na interface do cadastro
	Local oStPai   := FWFormStruct(2, "ZCS") // pode se usar um terceiro parametro para filtrar os campos exibidos [ |cCampo| cCampo $ "SZZ1_NOME|SZZ1_
	Local oStFilho := FWFormStruct(2, "ZCR") // pode se usar um terceiro parametro para filtrar os campos exibidos [ |cCampo| cCampo $ "SZZ1_NOME|SZZ1_
	
	// Criando oView como nulo
	Local oView := Nil
	
	// Criando a VIEW que sera o retorno da funcao e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	                      
	// Adicionando os campos do cabecalho e o grid dos filhos
	oView:AddField("VIEW_ZCS", oStPai, "ZCSMASTER")
	oView:AddGrid("VIEW_ZCR", oStFilho, "ZCRDETAIL")
	
	// Criando container com nome tela 100%
	oView:CreateHorizontalBox("CABEC", 30)
	oView:CreateHorizontalBox("GRID", 70)
	                                   
	// Amarrando a VIEW com as BOX
	oView:SetOwnerView("VIEW_ZCS", "CABEC")
	oView:SetOwnerView("VIEW_ZCR", "GRID")
	
	// Habilitando titulo
	oView:EnableTitleView("VIEW_ZCS", "Cabe็alho - Perํodo e Valores Contแbeis")
	oView:EnableTitleView("VIEW_ZCR", "Grid - Produtos e Quantidades")
	
	// Forca o fechamento da janela na confirmacao
	oView:SetCloseOnOK( {|| .t.} )
	                        
	// Remove os campos da grid
	oStFilho:RemoveField("ZCR_DATREF")

Return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADEST036P บAutor  ณFernando Macieira   บ Data ณ  13/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para checar se a data de referencia ja existe        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ADORO                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ChkZCS()

	Local lRet := .t.
	Local aAreaZCS := ZCS->( GetArea() )

	U_ADINF009P('ADEST036P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Calculo custo CERES')
	
	// consisto se ja existe registro com a data de calculo
	ZCS->( dbSetOrder(1) ) // ZCS_FILIAL + ZCS_DATREF
	If ZCS->( dbSeek(FWxFilial("ZCS") + DtoS(M->ZCS_DATREF)) )
		lRet := .f.
		Aviso("ADEST036P-01", "Perํodo jแ existente!" , {"OK"}, 3, cTitulo)	
	EndIf
	
	// consisto ultimo dia do mes
	If lRet
		
		cLastDay := AllTrim(Str(Last_Day(M->ZCS_DATREF)))
		cDayUser := AllTrim(Right(DtoS(M->ZCS_DATREF),2))
		
		If cLastDay <> cDayUser
			lRet := .f.
			Aviso(cRotina, "Informe o ๚ltimo dia do m๊s!" , {"OK"}, 3, cTitulo)	
		EndIf
		 
	EndIf
	
	RestArea( aAreaZCS )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณzTOkPos   บAutor  ณFernando Macieira   บ Data ณ  28/11/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao chamada no clique do botao OK do modelo de dados    บฑฑ
ฑฑบ          ณ (POS-VALIDACAO)                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function zTOkPos()

	Local oModelPad := FWModelActive()
	Local nOpc      := oModelPad:GetOperation()
	Local lRet      := .t.

	U_ADINF009P('ADEST036P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Calculo custo CERES')
	                      
	// Se a descricao estiver em branco
	// Inibido conforme diretriz da KU Danielle
	/*
	If nOpc == 4 // Alteracao
		If AllTrim(ZCS->ZCS_STATUS) == "F"
			lRet := .f.
			Aviso("Aten็ใo", "Perํodo jแ fechado! Altera็ใo nใo permitda...", {"OK"}, 03)
		EndIf
	EndIf
	*/

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณzTOkExc   บAutor  ณFernando Macieira   บ Data ณ  28/11/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao chamada no clique do botao OK do modelo de dados    บฑฑ
ฑฑบ          ณ (POS-VALIDACAO)                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function zTOkExc()

	Local oModelPad := FWModelActive()
	Local lRet      := .t.

	U_ADINF009P('ADEST036P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Calculo custo CERES')
	                      
	// Se a descricao estiver em branco
	If AllTrim(ZCS->ZCS_STATUS) == "F"
		lRet := .f.
		Aviso("Aten็ใo", "Perํodo jแ fechado! Exclusใo nใo permitda...", {"OK"}, 03)
	EndIf

Return lRet