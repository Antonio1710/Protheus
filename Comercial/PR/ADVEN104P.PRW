#include "Protheus.ch"
#include "TopConn.ch"
#include "FWMVCDef.ch"

// Variaveis estaticas
Static cTitulo  := "Cadastro de Shelf-Life "
Static cMSBLQL  := "2"

Static lUsrAut  := GetMV("MV_#ATVUSR",,.F.) // Ativa controle de usuarios autorizados
Static cUsrAut  := GetMV("MV_#USRAUT",,"000000") // Usuarios autorizados

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADVEN104P บAutor  ณFernando Macieira   บ Data ณ 16/09/2019  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro MVC - Modelo 3 - Shelf Life                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamado   ณ 051559 || OS 053110 || TECNOLOGIA || FERNANDO_SIGOLI ||    บฑฑ
ฑฑบ          ณ || 8451 || SHELFLIFE - fwnm - 16/09/2019                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ADVEN104P()

	Local oBrowse
	Local aAreaAtu := GetArea()          
	Local cFunBkp  := FunName()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro MVC - Modelo 3 - Shelf Life')
	
	// Usuarios autorizados
	If lUsrAut
		If !(RetCodUsr() $ cUsrAut)
			Aviso("MV_#USRAUT", "Usuแrio nใo autorizado para utilizar esta rotina!", {"OK"}, 3)
			Return			
		EndIf
	EndIf

	SetFunName("ADVEN104P")

	// Reseto quando chamada ocorre dentro de outro MVC
	If AllTrim(cFunBkp) <> "ADVEN104P"
		aRotina := {}       
	EndIf
	
	// Instanciando FWMBROWSE - Somente com dicionario de dados
	oBrowse := FWMBrowse():New()
	
	// Setando a tabela de cadastros 
	oBrowse:SetAlias("ZFR")
	
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
ฑฑบPrograma  ณADVEN104P บAutor  ณFernando Macieira   บ Data ณ 21/12/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Criacao do MENU MVC                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MenuDef()

	Local aRot := {}
	
	// Adicionando opcoes
	ADD OPTION aRot TITLE "Visualizar" ACTION "VIEWDEF.ADVEN104P" OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // OPERACAO 1
	ADD OPTION aRot TITLE "Incluir"    ACTION "VIEWDEF.ADVEN104P" OPERATION MODEL_OPERATION_INSERT ACCESS 0 // OPERACAO 3
	ADD OPTION aRot TITLE "Alterar"    ACTION "VIEWDEF.ADVEN104P" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // OPERACAO 4
	ADD OPTION aRot TITLE "Excluir"    ACTION "VIEWDEF.ADVEN104P" OPERATION MODEL_OPERATION_DELETE ACCESS 0 // OPERACAO 5

Return aRot

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADVEN104P บAutor  ณFernando Macieira   บ Data ณ 21/12/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Criacao do MODELO de dados MVC                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ModelDef()

	// Criacao do objeto do modelo de dados
	Local oModel     := Nil                   
	Local aZFRZFSRel := {}
	Local bVldPos    := {|| VldTudoOk()} // Validacao ao clicar no botao confirmar
	Local bVldPre    := {|| .T.} // Antes de abrir a tela
	Local bVldCom    := {|| .T.} // Funcao chamada no commit
	Local bVldCan    := {|| .T.} // Funcao chamada no cancelar

	
	// Criacao da estrutura de dados utilizada na interface
	Local oStPai   := FWFormStruct(1, "ZFR")
	Local oStFilho := FWFormStruct(1, "ZFS")
	 
	// Editando caracteristicas do dicionario
	oStPai:SetProperty("ZFR_CODIGO", MODEL_FIELD_WHEN,  FWBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) // MODO EDICAO
	oStPai:SetProperty("ZFR_CODIGO", MODEL_FIELD_INIT,  FWBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSXENum("ZFR", "ZFR_CODIGO")')) // INI PADRAO
	oStPai:SetProperty("ZFR_MSBLQL", MODEL_FIELD_INIT,  FWBuildFeature(STRUCT_FEATURE_INIPAD, "'"+cMSBLQL+"'")) // INI PADRAO
	oStPai:SetProperty("ZFR_CLILOJ", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, 'u_ChkSA1()')) // Validacao

	
	// Criando o modelo e os relacionamentos
	oModel := MPFormModel():New("MODELDEF_MVC")
	//oModel := MPFormModel():New("ADVEN104P")
	oModel:AddFields("ZFRMASTER", /*cOwner*/, oStPai)
	//oModel:AddGrid("ZFSDETAIL", "ZFRMASTER", oStFilho, /*bLinePre*/, /*bLinePost*/, /*bPre - Grid Inteiro*/, /*bPos - Grid Inteiro*/, /*bLoad - Carga Modelo*/)
	oModel:AddGrid("ZFSDETAIL", "ZFRMASTER", oStFilho, /*bLinePre*/, /*bLinePost*/, /*bPre - Grid Inteiro*/, bVldPos, /*bLoad - Carga Modelo*/)
	
	// Fazendo relacionamento entre pai e filho
	aAdd( aZFRZFSRel, {"ZFS_FILIAL", "ZFR_FILIAL"} )
	aAdd( aZFRZFSRel, {"ZFS_CODIGO", "ZFR_CODIGO"} )
	
	oModel:SetRelation("ZFSDETAIL", aZFRZFSRel, ZFS->(IndexKey(1)) ) // IndexKey -> quero a ordenacao e depois filtrado
	oModel:GetModel("ZFSDETAIL"):SetUniqueLine({"ZFS_XCATEG","ZFS_XPREPA"}) // Nao repetir informacoes ou combinacoes {"CAMPO1", "CAMPO2", "CAMPON"}
	oModel:SetPrimaryKey( {} )
	
	// Setando as descricoes
	oModel:SetDescription(cTitulo)
	oModel:GetModel("ZFRMASTER"):SetDescription("Cliente")
	oModel:GetModel("ZFSDETAIL"):SetDescription("Percentual Shelf-Life")

Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADVEN104P บAutor  ณFernando Macieira   บ Data ณ 21/12/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Criacao da VISAO MVC                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ViewDef()

	// Criacao do objeto do modelo de dados da interface do cadastro
	//Local oModel	:= ModelDef()
	Local oModel := FWLoadModel("ADVEN104P")
	
	// Criacao da estrutura de dados utilizada na interface do cadastro
	Local oStPai   := FWFormStruct(2, "ZFR") // pode se usar um terceiro parametro para filtrar os campos exibidos [ |cCampo| cCampo $ "SZZ1_NOME|SZZ1_
	Local oStFilho := FWFormStruct(2, "ZFS") // pode se usar um terceiro parametro para filtrar os campos exibidos [ |cCampo| cCampo $ "SZZ1_NOME|SZZ1_
	
	// Criando oView como nulo
	Local oView := Nil
	
	// Criando a VIEW que sera o retorno da funcao e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	                      
	// Adicionando os campos do cabecalho e o grid dos filhos
	oView:AddField("VIEW_ZFR", oStPai, "ZFRMASTER")
	oView:AddGrid("VIEW_ZFS", oStFilho, "ZFSDETAIL")
	
	// Criando container com nome tela 100%
	oView:CreateHorizontalBox("CABEC", 30)
	oView:CreateHorizontalBox("GRID", 70)
	                                   
	// Amarrando a VIEW com as BOX
	oView:SetOwnerView("VIEW_ZFR", "CABEC")
	oView:SetOwnerView("VIEW_ZFS", "GRID")
	
	// Habilitando titulo
	oView:EnableTitleView("VIEW_ZFR", "Cabe็alho")
	oView:EnableTitleView("VIEW_ZFS", "Grid")
	
	// Forca o fechamento da janela na confirmacao
	oView:SetCloseOnOK( {|| .t.} )
	                        
	// Remove os campos de codigo do artista e CD
	oStFilho:RemoveField("ZFS_CODIGO")

Return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADVEN104P บAutor  ณMicrosiga           บ Data ณ  12/21/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para checar se cliente + loja ja esta cadastrado     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function VldTudoOk()

	Local oModelPad := FWModelActive()
	Local nOpc      := oModelPad:GetOperation()
	Local lRet      := .t.
    Local cQuery    := ""
                      
	If nOpc == 3 // Inclusao
		
		SA1->( dbSetOrder(1) ) // A1_FILIAL + A1_COD + A1_LOJA
		If SA1->( dbSeek(FWxFilial("SA1")+M->ZFR_CLICOD+M->ZFR_CLILOJ) )
		
			If Select("Work") > 0
				Work->( dbCloseArea() )
			EndIf
			
			cQuery := " SELECT COUNT(1) TT "
			cQuery += " FROM " + RetSqlName("ZFR") + " ZFR (NOLOCK) "
			cQuery += " WHERE ZFR_FILIAL='"+FWxFilial("ZFR")+"' "
			cQuery += " AND ZFR_CLICOD='"+M->ZFR_CLICOD+"' "
			cQuery += " AND ZFR_CLILOJ='"+M->ZFR_CLILOJ+"' "
			cQuery += " AND D_E_L_E_T_='' "
			
			tcquery cquery new alias "Work"
	
			If Work->TT >= 1
				lRet := .f.
				Aviso("Aten็ใo", "Cliente/Loja jแ cadastrado! Inclusใo nใo permitida...", {"OK"}, 03)
			EndIf
	
			If Select("Work") > 0
				Work->( dbCloseArea() )
			EndIf
			
		Else
			lRet := .f.
			Aviso("Aten็ใo", "Cliente/Loja informado nใo existe! Inclusใo nใo permitida...", {"OK"}, 03)
		EndIf

	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADVEN104P บAutor  ณMicrosiga           บ Data ณ  12/21/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para checar se cliente + loja ja esta cadastrado     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ChkSA1()

	Local oModelPad := FWModelActive()
	Local nOpc      := oModelPad:GetOperation()
	Local lRet      := .t.

	U_ADINF009P('ADVEN104P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Funcao para checar se cliente + loja ja esta cadastrado')
                      
	If nOpc == 3 // Inclusao
		
		SA1->( dbSetOrder(1) ) // A1_FILIAL + A1_COD + A1_LOJA
		If SA1->( dbSeek(FWxFilial("SA1")+M->ZFR_CLICOD+M->ZFR_CLILOJ) )
		
			If Select("Work") > 0
				Work->( dbCloseArea() )
			EndIf
			
			cQuery := " SELECT COUNT(1) TT "
			cQuery += " FROM " + RetSqlName("ZFR") + " ZFR (NOLOCK) "
			cQuery += " WHERE ZFR_FILIAL='"+FWxFilial("ZFR")+"' "
			cQuery += " AND ZFR_CLICOD='"+M->ZFR_CLICOD+"' "
			cQuery += " AND ZFR_CLILOJ='"+M->ZFR_CLILOJ+"' "
			cQuery += " AND D_E_L_E_T_='' "
			
			tcquery cquery new alias "Work"
	
			If Work->TT >= 1
				lRet := .f.
				Aviso("Aten็ใo", "Cliente/Loja jแ cadastrado! Inclusใo nใo permitida...", {"OK"}, 03)
			EndIf
	
			If Select("Work") > 0
				Work->( dbCloseArea() )
			EndIf
			
		Else
			lRet := .f.
			Aviso("Aten็ใo", "Cliente/Loja informado nใo existe! Inclusใo nใo permitida...", {"OK"}, 03)
		EndIf

	EndIf

Return lRet