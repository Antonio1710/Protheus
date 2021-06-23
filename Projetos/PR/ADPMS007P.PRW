#include "Protheus.ch"
#include "FWMVCDef.ch"

// Variaveis estaticas
Static cTitulo  := "Projetos Investimentos - Aprovador x Vistadores"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADPMS007P บAutor  ณFernando Macieira   บ Data ณ 17/04/2019  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Projetos Investimentos - Cadastro Aprovador x Vistadores   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamado   ณ 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451     บฑฑ
ฑฑบ          ณ || APROVACAO PROJETOS - FWNM - 17/04/2019                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADPMS007P()

	Local oBrowse
	Local aAreaAtu := GetArea()          
	Local cFunBkp  := FunName()
	
	SetFunName("ADPMS007P")

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Projetos Investimentos - Cadastro Aprovador x Vistadores')
	
	// Reseto quando chamada ocorre dentro de outro MVC
	If AllTrim(cFunBkp) <> "ADPMS007P"
		aRotina := {}       
	EndIf
	
	// Instanciando FWMBROWSE - Somente com dicionario de dados
	oBrowse := FWMBrowse():New()
	
	// Setando a tabela de cadastros 
	oBrowse:SetAlias("ZCX")
	
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
ฑฑบPrograma  ณADPMS007P บAutor  ณFernando Macieira   บ Data ณ 17/04/2019  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Criacao do MENU MVC                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()

	Local aRot := {}
	
	// Adicionando opcoes
	ADD OPTION aRot TITLE "Visualizar" ACTION "VIEWDEF.ADPMS007P" OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // OPERACAO 1
	ADD OPTION aRot TITLE "Incluir"    ACTION "VIEWDEF.ADPMS007P" OPERATION MODEL_OPERATION_INSERT ACCESS 0 // OPERACAO 3
	ADD OPTION aRot TITLE "Alterar"    ACTION "VIEWDEF.ADPMS007P" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // OPERACAO 4
	ADD OPTION aRot TITLE "Excluir"    ACTION "VIEWDEF.ADPMS007P" OPERATION MODEL_OPERATION_DELETE ACCESS 0 // OPERACAO 5

Return aRot

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADPMS007P บAutor  ณFernando Macieira   บ Data ณ 17/04/2019  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Criacao do MODELO de dados MVC                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModelDef()

	// Criacao do objeto do modelo de dados
	Local oModel     := Nil                   
	Local aZCXZCYRel := {}
	
	// Criacao da estrutura de dados utilizada na interface
	Local oStPai   := FWFormStruct(1, "ZCX")
	Local oStFilho := FWFormStruct(1, "ZCY")
	
	// Editando caracteristicas do dicionario
	oStPai:SetProperty("ZCX_USER"  , MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID , 'UsrExist(FwFldGet("ZCX_USER")) .and. u_ChkZCX()')) // Validacao

	oStPai:SetProperty("ZCX_CODIGO", MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GETSX8NUM("ZCX","ZCX_CODIGO")')) //Ini Padrใo
	oStPai:SetProperty("ZCX_CODIGO", MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN  , '.F.'))             //Modo de Edi็ใo
	 
	// Criando o modelo e os relacionamentos
	oModel := MPFormModel():New("MODELDEF_MVC")
	oModel:AddFields("ZCXMASTER", /*cOwner*/, oStPai)
	oModel:AddGrid("ZCYDETAIL", "ZCXMASTER", oStFilho, /*bLinePre*/, /*bLinePost*/, /*bPre - Grid Inteiro*/, /*bVldPos*/, /*bLoad - Carga Modelo*/)
	
	// Fazendo relacionamento entre pai e filho
	aAdd( aZCXZCYRel, {"ZCY_FILIAL", "ZCX_FILIAL"} )
	aAdd( aZCXZCYRel, {"ZCY_CODIGO", "ZCX_CODIGO"} )
	
	oModel:SetRelation("ZCYDETAIL", aZCXZCYRel, ZCY->(IndexKey(1)) ) // IndexKey -> quero a ordenacao e depois filtrado
	oModel:GetModel("ZCYDETAIL"):SetUniqueLine({"ZCY_USER"}) // Nao repetir informacoes ou combinacoes {"CAMPO1", "CAMPO2", "CAMPON"}
	oModel:SetPrimaryKey( {} )
	
	// Setando as descricoes
	oModel:SetDescription(cTitulo)
	oModel:GetModel("ZCXMASTER"):SetDescription("Aprovador")
	oModel:GetModel("ZCYDETAIL"):SetDescription("Vistadores")

Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADPMS007P บAutor  ณFernando Macieira   บ Data ณ 17/04/2019  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Criacao da VISAO MVC                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewDef()

	// Criacao do objeto do modelo de dados da interface do cadastro
	Local oModel := FWLoadModel("ADPMS007P")
	
	// Criacao da estrutura de dados utilizada na interface do cadastro
	Local oStPai   := FWFormStruct(2, "ZCX") // pode se usar um terceiro parametro para filtrar os campos exibidos [ |cCampo| cCampo $ "SZZ1_NOME|SZZ1_
	Local oStFilho := FWFormStruct(2, "ZCY") // pode se usar um terceiro parametro para filtrar os campos exibidos [ |cCampo| cCampo $ "SZZ1_NOME|SZZ1_
	
	// Criando oView como nulo
	Local oView := Nil
	
	// Criando a VIEW que sera o retorno da funcao e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	                      
	// Adicionando os campos do cabecalho e o grid dos filhos
	oView:AddField("VIEW_ZCX", oStPai, "ZCXMASTER")
	oView:AddGrid("VIEW_ZCY", oStFilho, "ZCYDETAIL")
	
	// Criando container com nome tela 100%
	oView:CreateHorizontalBox("CABEC", 20)
	oView:CreateHorizontalBox("GRID", 80)
	                                   
	// Amarrando a VIEW com as BOX
	oView:SetOwnerView("VIEW_ZCX", "CABEC")
	oView:SetOwnerView("VIEW_ZCY", "GRID")
	
	// Habilitando titulo
	oView:EnableTitleView("VIEW_ZCX", "Aprovador")
	oView:EnableTitleView("VIEW_ZCY", "Vistadores")
	
	// Forca o fechamento da janela na confirmacao
	oView:SetCloseOnOK( {|| .t.} )
	                        
	// Remove os campos de codigo do artista e CD
	oStFilho:RemoveField("ZCY_CODIGO")

Return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADPMS007P บAutor  ณMicrosiga           บ Data ณ  12/21/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para checar se aprovador ja existe                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ChkZCX()

	Local lRet := .t.
	Local aAreaZCX := ZCX->( GetArea() )

	U_ADINF009P('ADPMS007P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Projetos Investimentos - Cadastro Aprovador x Vistadores')
	
	If Empty(M->ZCX_USER)
		lRet := .f.
		Aviso("ADPMS007P-03", "Informe um aprovador!" , {"OK"}, 3, cTitulo)	
	EndIf
	
	If lRet
		ZCX->( dbSetOrder(1) ) // ZCX_FILIAL+ZCX_USER+ZCX_CODIGO                                                                                                                                  
		If ZCX->( dbSeek( FWxFilial("ZCX") + M->ZCX_USER ) )
			lRet := .f.
			Aviso("ADPMS007P-01", "Usuแrio jแ cadastrado como aprovador!" , {"OK"}, 3, cTitulo)	
		EndIf
	EndIf
	
	RestArea( aAreaZCX )

Return lRet