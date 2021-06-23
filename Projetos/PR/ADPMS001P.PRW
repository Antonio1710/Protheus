
#include "Protheus.ch"
#include "FWMVCDef.ch"

// Variaveis estaticas
Static cTitulo  := "Cronograma Financeiro - Projetos Investimentos"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADPMS001P บAutor  ณFernando Macieira   บ Data ณ 21/12/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cad Cronograma Financeiro dos Projetos de Investimentos    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ADPMS001P()

Local oBrowse
Local aAreaAtu := GetArea()          
Local cFunBkp  := FunName()

SetFunName("ADPMS001P")

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cad Cronograma Financeiro dos Projetos de Investimentos')

// Reseto quando chamada ocorre dentro de outro MVC
If AllTrim(cFunBkp) <> "ADPMS001P"
	aRotina := {}       
EndIf

// Instanciando FWMBROWSE - Somente com dicionario de dados
oBrowse := FWMBrowse():New()

// Setando a tabela de cadastros 
oBrowse:SetAlias("ZCD")

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
ฑฑบPrograma  ณADPMS001P บAutor  ณFernando Macieira   บ Data ณ 21/12/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Criacao do MENU MVC                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MenuDef()

Local aRot := {}

// Adicionando opcoes
ADD OPTION aRot TITLE "Visualizar" ACTION "VIEWDEF.ADPMS001P" OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // OPERACAO 1
ADD OPTION aRot TITLE "Incluir"    ACTION "VIEWDEF.ADPMS001P" OPERATION MODEL_OPERATION_INSERT ACCESS 0 // OPERACAO 3
ADD OPTION aRot TITLE "Alterar"    ACTION "VIEWDEF.ADPMS001P" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // OPERACAO 4
ADD OPTION aRot TITLE "Excluir"    ACTION "VIEWDEF.ADPMS001P" OPERATION MODEL_OPERATION_DELETE ACCESS 0 // OPERACAO 5

Return aRot



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADPMS001P บAutor  ณFernando Macieira   บ Data ณ 21/12/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Criacao do MODELO de dados MVC                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ModelDef()

// Criacao do objeto do modelo de dados
Local oModel  := Nil                   
Local aZCDZCERel := {}
Local bVldPos := {|| RatPos()} // Validacao ao clicar no botao confirmar

// Criacao da estrutura de dados utilizada na interface
Local oStPai   := FWFormStruct(1, "ZCD")
Local oStFilho := FWFormStruct(1, "ZCE")
 
// Editando caracteristicas do dicionario
oStPai:SetProperty("ZCD_PROJET", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, 'ExistCpo("AF8", M->ZCD_PROJET)')) // Validacao
oStPai:SetProperty("ZCD_REVISA", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, 'u_ChkZCD()')) // Validacao

// Criando o modelo e os relacionamentos
oModel := MPFormModel():New("MODELDEF_MVC")
//oModel := MPFormModel():New("ADPMS001P")
oModel:AddFields("ZCDMASTER", /*cOwner*/, oStPai)
//oModel:AddGrid("ZCEDETAIL", "ZCDMASTER", oStFilho, /*bLinePre*/, /*bLinePost*/, /*bPre - Grid Inteiro*/, /*bPos - Grid Inteiro*/, /*bLoad - Carga Modelo*/)
oModel:AddGrid("ZCEDETAIL", "ZCDMASTER", oStFilho, /*bLinePre*/, /*bLinePost*/, /*bPre - Grid Inteiro*/, bVldPos, /*bLoad - Carga Modelo*/)

// Fazendo relacionamento entre pai e filho
aAdd( aZCDZCERel, {"ZCE_FILIAL", "ZCD_FILIAL"} )
aAdd( aZCDZCERel, {"ZCE_PROJET", "ZCD_PROJET"} )
aAdd( aZCDZCERel, {"ZCE_REVISA", "ZCD_REVISA"} )

oModel:SetRelation("ZCEDETAIL", aZCDZCERel, ZCE->(IndexKey(1)) ) // IndexKey -> quero a ordenacao e depois filtrado
oModel:GetModel("ZCEDETAIL"):SetUniqueLine({"ZCE_PERIOD"}) // Nao repetir informacoes ou combinacoes {"CAMPO1", "CAMPO2", "CAMPON"}
oModel:SetPrimaryKey( {} )

// Setando as descricoes
oModel:SetDescription("Cronograma Financeiro - Projetos Investimentos")
oModel:GetModel("ZCDMASTER"):SetDescription("Projeto")
oModel:GetModel("ZCEDETAIL"):SetDescription("Rateio")

Return oModel




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADPMS001P บAutor  ณFernando Macieira   บ Data ณ 21/12/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Criacao da VISAO MVC                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ViewDef()

// Criacao do objeto do modelo de dados da interface do cadastro
//Local oModel	:= ModelDef()
Local oModel := FWLoadModel("ADPMS001P")

// Criacao da estrutura de dados utilizada na interface do cadastro
Local oStPai   := FWFormStruct(2, "ZCD") // pode se usar um terceiro parametro para filtrar os campos exibidos [ |cCampo| cCampo $ "SZZ1_NOME|SZZ1_
Local oStFilho := FWFormStruct(2, "ZCE") // pode se usar um terceiro parametro para filtrar os campos exibidos [ |cCampo| cCampo $ "SZZ1_NOME|SZZ1_

// Criando oView como nulo
Local oView := Nil

// Criando a VIEW que sera o retorno da funcao e setando o modelo da rotina
oView := FWFormView():New()
oView:SetModel(oModel)
                      
// Adicionando os campos do cabecalho e o grid dos filhos
oView:AddField("VIEW_ZCD", oStPai, "ZCDMASTER")
oView:AddGrid("VIEW_ZCE", oStFilho, "ZCEDETAIL")

// Criando container com nome tela 100%
oView:CreateHorizontalBox("CABEC", 20)
oView:CreateHorizontalBox("GRID", 80)
                                   
// Amarrando a VIEW com as BOX
oView:SetOwnerView("VIEW_ZCD", "CABEC")
oView:SetOwnerView("VIEW_ZCE", "GRID")

// Habilitando titulo
oView:EnableTitleView("VIEW_ZCD", "Cabe็alho - Projetos")
oView:EnableTitleView("VIEW_ZCE", "Grid - Rateio")

// Forca o fechamento da janela na confirmacao
oView:SetCloseOnOK( {|| .t.} )
                        
// Remove os campos de codigo do artista e CD
oStFilho:RemoveField("ZCE_PROJET")
oStFilho:RemoveField("ZCE_REVISA")

Return oView
            



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADPMS001P บAutor  ณMicrosiga           บ Data ณ  12/21/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para checar se codigo de projeto + revisao ja existe บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ChkZCD()

Local lRet := .t.
Local aAreaZCD := ZCD->( GetArea() )

U_ADINF009P('ADPMS001P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cad Cronograma Financeiro dos Projetos de Investimentos')


ZCD->( dbSetOrder(1) ) // ZCD_FILIAL + ZCD_PROJET + ZCD_REVISA
If ZCD->( dbSeek(xFilial("ZCD") + M->ZCD_PROJET + M->ZCD_REVISA) )
	lRet := .f.
	Aviso("ADPMS001P-01", "Projeto/Revisใo jแ distribuํdo!" , {"OK"}, 3, "Cronograma Financeiro - Projeto Investimento")	
EndIf

RestArea( aAreaZCD )

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRatPos    บAutor  ณFernando Macieira   บ Data ณ  12/26/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para consistir valor rateado                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RatPos()
           
Local nVlrPrj    := M->ZCD_VALOR
Local lRet       := .t.
Local nTotRat    := 0
Local oModelPad  := FWModelActive()
Local oModelGrid := oModelPad:GetModel("ZCEDETAIL")
Local nLinAtu    := oModelGrid:nLine
Local nPosCod    := aScan( oModelGrid:aHeader, { |x| AllTrim(x[2]) == AllTrim("ZCE_VALOR") } )
Local aGrid      := OMODELGRID:ADATAMODEL

                      
For i:=1 to Len(aGrid)

	If aGrid[i,2] // Deletado
		nTotRat += aGrid[i,1,1,3]
	EndIf
	
Next i

If nTotRat <> nVlrPrj
	lRet := .f.
	Aviso( "ADPMS001P-02", "Distribui็ใo nใo bate com valor do projeto! Ajuste..." , {"OK"}, 3, "Total distribuํdo: " + Transform(nTotRat,PesqPict("ZCE","ZCE_VALOR")) )	
EndIf

Return lRet
