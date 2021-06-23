#include "protheus.ch"
#include "topconn.ch"
#include "FWMVCDef.ch"

// Variaveis estaticas
Static cTitulo  := "Logística - Cadastro de Atendentes"
Static cMSBLQL  := "2"
Static cTabela  := "ZFM"
//Static cEmpSIG  := GetMV("MV_#EMPSIG",,"01")
//Static lUsrAut  := GetMV("MV_#ATVUSR",,.t.) // Ativa controle de usuarios autorizados
//Static cUsrAut  := GetMV("MV_#USRAUT",,"000000") // Usuarios autorizados

/*/{Protheus.doc} User Function ADLOG061P
	(Cadastro MVC modelo 1 para atendentes)
	@type  Function
	@author Fernando Macieira
	@since 01/08/2019
	@version 01
	@history 049495 || OS 050775 || ADM.LOG || MARCEL || 8365 || ROMANEIO ENTREGAS
	@history 049495 || OS 050775 || ADM.LOG || MARCEL || 8365 || Incluir novo campo ZFM_NUMCE2 - FWNM - 08/08/2019
	@history 058395 - ADRIANO SAVOINE - 25/05/2020 - Correção na Rotina de alteração pois ao tentar alterar registros estava gerando erro e nao deixava efetuar a alteração de forma nenhuma.
	/*/

User Function ADLOG061P()

	Local oBrowse
	Local aAreaAtu := GetArea()
	Local cFunBkp  := FunName()
	
	SetFunName("ADLOG061P")

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro MVC modelo 1 para atendentes')
	
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

/*/{Protheus.doc} User Function ADLOG061P
	(Criacao do MENU MVC)
	@type  Function
	@author Fernando Macieira
	@since 01/08/2019
	@version 01
	/*/

Static Function MenuDef()

	Local aRot := {}
	
	// Adicionando opcoes
	ADD OPTION aRot TITLE "Visualizar" 					ACTION "VIEWDEF.ADLOG061P"  OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // OPERACAO 1
	ADD OPTION aRot TITLE "Incluir"    					ACTION "VIEWDEF.ADLOG061P"  OPERATION MODEL_OPERATION_INSERT ACCESS 0 // OPERACAO 3
	ADD OPTION aRot TITLE "Alterar"    					ACTION "VIEWDEF.ADLOG061P"  OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // OPERACAO 4
	ADD OPTION aRot TITLE "Excluir"    					ACTION "VIEWDEF.ADLOG061P"  OPERATION MODEL_OPERATION_DELETE ACCESS 0 // OPERACAO 5
	ADD OPTION aRot TITLE 'Gravar Roteiro no Atendente' ACTION 'u_ADLOG062P'  		OPERATION 2 ACCESS 0
	
Return aRot

/*/{Protheus.doc} User Function ADLOG061P
	(Criacao do MODELO de dados MVC)
	@type  Function
	@author Fernando Macieira
	@since 01/08/2019
	@version 01
	/*/


Static Function ModelDef()

	// Blocos de codigos nas validacoes
	Local bVldPre := {|| u_ZFMPre()} // Antes de abrir a tela
	Local bVldPos := {|| u_ZFMPos()} // Validacao ao clicar no botao confirmar
	Local bVldCom := {|| u_ZFMCom()} // Funcao chamada no commit
	Local bVldCan := {|| u_ZFMCan()} // Funcao chamada no cancelar
	
	// Criacao do objeto do modelo de dados
	Local oModel := Nil
	
	// Criacao da estrutura de dados utilizada na interface
	Local oStDad := FWFormStruct(1, cTabela)
	
	// Editando caracteristicas do dicionario
	oStDad:SetProperty("ZFM_MSBLQL", MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) // MODO EDICAO
	oStDad:SetProperty("ZFM_MSBLQL", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "'"+cMSBLQL+"'")) // INI PADRAO
	oStDad:SetProperty("ZFM_CODIGO", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSXENum("ZFM", "ZFM_CODIGO")')) // INI PADRAO

	// Instanciando o modelo, nao e recomendado colocar o nome da user function (por causa do u_), respeitando o limite de 10 caracteres
	oModel := MPFormModel():New("U_ADLOG061P", bVldPre, bVldPos, bVldCom, bVldCan)
	
	// Atribuindo formularios para o modelo
	oModel:AddFields("FORMZFM", /*cOwner*/, oStDad)
	
	// Setando a chave primaria da rotina
	oModel:SetPrimaryKey( {"ZFM_FILIAL", "ZFM_CODIGO"} )
	
	// Adicionando descricao ao modelo
	oModel:SetDescription(cTitulo)
	
	// Setando a descricao do formulario
	oModel:GetModel("FORMZFM"):SetDescription(cTitulo)
	
	// Pode ativar?
	//oModel:SetVldActive( { | oModel | fAlterar(oModel) } )

Return oModel

/*/{Protheus.doc} User Function ADLOG061P
	(Criacao da VISAO MVC)
	@type  Function
	@author Fernando Macieira
	@since 01/08/2019
	@version 01
	/*/

Static Function ViewDef()

	Local aStruZFM := ZFM->( dbStruct() )
	
	// Criacao do objeto do modelo de dados da interface do cadastro
	Local oModel := FWLoadModel("ADLOG061P")
	
	// Criacao da estrutura de dados utilizada na interface do cadastro
	Local oStDad := FWFormStruct(2, cTabela) // pode se usar um terceiro parametro para filtrar os campos exibidos [ |cCampo| cCampo $ "SZFM_NOME|SZFM_
	
	// Criando oView como nulo
	Local oView := Nil
	
	// Criando a VIEW que sera o retorno da funcao e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	// Atribuindo formularios para interface
	oView:AddField("VIEW_ZFM", oStDad, "FORMZFM")
	
	// Criando container com nome tela 100%
	oView:CreateHorizontalBox("TELA", 100)
	
	// Colocando titulo do formulario
	oView:EnableTitleView("VIEW_ZFM", cTitulo )
	
	// Forca o fechamento da janela na confirmacao
	oView:SetCloseOnOK( {|| .t.} )
	
	// O formulario da interface sera colocado dentro do container
	oView:SetOwnerView("VIEW_ZFM", "TELA")

Return oView

/*/{Protheus.doc} User Function ADLOG061P
	(Funcao chamada na criacao do modelo de dados (PRE-VALIDACAO))
	@type  Function
	@author Fernando Macieira
	@since 01/08/2019
	@version 01
	/*/

User Function ZFMPre()

	Local oModelPad := FWModelActive()
	Local nOpc      := oModelPad:GetOperation()
	Local lRet      := .t.
	Local cWhen     := ".f."

	U_ADINF009P('ADLOG061P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro MVC modelo 1 para atendentes')
	
	// Se for inclusao, alteracao ou exclusao
	If (nOpc == MODEL_OPERATION_INSERT) .or. (nOpc == MODEL_OPERATION_UPDATE)
		
		// Se for inclusao, alteracao ou exclusao
		If nOpc == MODEL_OPERATION_INSERT
			oModelPad:GetModel("FORMZFM"):GetStruct():SetProperty("ZFM_MSBLQL", MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, ".f."))
		ElseIf nOpc == MODEL_OPERATION_UPDATE
			oModelPad:GetModel("FORMZFM"):GetStruct():SetProperty("ZFM_MSBLQL", MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, ".t."))
		EndIf
		
	EndIf

Return lRet


/*/{Protheus.doc} User Function ADLOG061P
	(Funcao chamada no clique do botao OK do modelo de dados (POS-VALIDACAO))
	@type  Function
	@author Fernando Macieira
	@since 01/08/2019
	@version 01
	/*/

User Function ZFMPos()

	Local lRet      := .t.
	Local oModelPad := FWModelActive()
	
	Local cCodigo   := oModelPad:GetValue("FORMZFM", "ZFM_CODIGO")
	Local cNome     := oModelPad:GetValue("FORMZFM", "ZFM_NOME")
	Local cNumCel   := oModelPad:GetValue("FORMZFM", "ZFM_NUMCEL")
	Local cNumFix   := oModelPad:GetValue("FORMZFM", "ZFM_NUMFIX")
	Local cHorAlm   := oModelPad:GetValue("FORMZFM", "ZFM_HORALM")
	Local cObsAlm   := oModelPad:GetValue("FORMZFM", "ZFM_OBSALM")
	Local cNumCe2   := oModelPad:GetValue("FORMZFM", "ZFM_NUMCE2") // Chamado n. 049495 || OS 050775 || ADM.LOG || MARCEL || 8365 || Incluir novo campo ZFM_NUMCE2 - FWNM - 08/08/2019

	U_ADINF009P('ADLOG061P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro MVC modelo 1 para atendentes')

	If lRet
		If Empty(cCodigo) .or. Empty(cNome) .or. Empty(cNumCel) .or. Empty(cNumFix) .or. Empty(cHorAlm) .or. Empty(cObsAlm) .or. Empty(cNumCe2)
			lRet := .f.
			Aviso("Algum campo vazio", "Código, Nome, Celular, Celular2, Fixo, Horário Almoço ou Obs Almoço podem estar vazio... campos obrigatórios!", {"OK"}, 3)
		EndIf
	EndIf
	
Return lRet

/*/{Protheus.doc} User Function ADLOG061P
	(Funcao chamada apos validar o OK da rotina para os dados serem salvos )
	@type  Function
	@author Fernando Macieira
	@since 01/08/2019
	@version 01
	/*/

User Function ZFMCom()

	Local lRet      := .t.
	Local lPermite  := .t.
	Local oModelPad := FWModelActive()
	Local nOpc      := oModelPad:GetOperation()
	
	Local cCodigo   := oModelPad:GetValue("FORMZFM", "ZFM_CODIGO")
	Local cNome     := oModelPad:GetValue("FORMZFM", "ZFM_NOME")
	Local cNumCel   := oModelPad:GetValue("FORMZFM", "ZFM_NUMCEL")
	Local cNumFix   := oModelPad:GetValue("FORMZFM", "ZFM_NUMFIX")
	Local cHorAlm   := oModelPad:GetValue("FORMZFM", "ZFM_HORALM")
	Local cObsAlm   := oModelPad:GetValue("FORMZFM", "ZFM_OBSALM")
	Local cMsblql   := oModelPad:GetValue("FORMZFM", "ZFM_MSBLQL")

	// Chamado n. 049495 || OS 050775 || ADM.LOG || MARCEL || 8365 || Incluir novo campo ZFM_NUMCE2 - FWNM - 08/08/2019
	Local cNumCe2   := oModelPad:GetValue("FORMZFM", "ZFM_NUMCE2")

	U_ADINF009P('ADLOG061P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro MVC modelo 1 para atendentes')
	
	// Se for inclusao
	If nOpc == MODEL_OPERATION_INSERT
		
		// Checagem codigo + nome
		ZFM->( dbSetOrder(1) ) // ZFM_FILIAL + ZFM_CODIGO + ZFM_NOME
		If ZFM->( dbSeek(FWxFilial("ZFM") + cCodigo + cNome) )
			lRet := .f.
			Aviso("Registro existente", "Inclusão não realizada pois já existe um registro com este mesmo código e nome informados...", {"OK"}, 3)
		EndIf
		
		// Checagem nome
		If lRet
			ZFM->( dbSetOrder(2) ) // ZFM_FILIAL+ZFM_NOME
			If ZFM->( dbSeek(FWxFilial("ZFM") + cNome) )
				lRet := .f.
				Aviso("Registro existente", "Inclusão não realizada pois já existe um registro com este mesmo nome informado...", {"OK"}, 3)
			EndIf
		EndIf
		
		// Checagem celular
		If lRet
			ZFM->( dbSetOrder(3) ) // ZFM_FILIAL+ZFM_NUMCEL
			If ZFM->( dbSeek(FWxFilial("ZFM") + cNumCel) )
				lRet := .f.
				Aviso("Registro existente", "Inclusão não realizada pois já existe um registro com este mesmo celular informado...", {"OK"}, 3)
			EndIf
		EndIf
		
		If lRet
			RecLock("ZFM", .T.)
				ZFM_FILIAL := FWxFilial("ZFM")
				ZFM_CODIGO := cCodigo
				ZFM_NOME   := cNome
				ZFM_NUMCEL := cNumCel
				ZFM_NUMFIX := cNumFix
				ZFM_HORALM := cHorAlm
				ZFM_OBSALM := cObsAlm
				ZFM_MSBLQL := cMSBLQL
				ZFM_NUMCE2 := cNumCe2 // Chamado n. 049495 || OS 050775 || ADM.LOG || MARCEL || 8365 || Incluir novo campo ZFM_NUMCE2 - FWNM - 08/08/2019
			ZFM->( msUnLock() )
			
			ConfirmSX8()
			
			Aviso("Inclusão", "Inclusão realizada com sucesso!", {"OK"}, 3)
		EndIf
		
	// Se for alteracao
	ElseIf nOpc == MODEL_OPERATION_UPDATE
		
		cCodOld := ZFM->ZFM_CODIGO
		     
		// Checagem codigo + nome
		ZFM->( dbSetOrder(1) ) // ZFM_FILIAL + ZFM_CODIGO + ZFM_NOME
		If ZFM->( dbSeek(FWxFilial("ZFM") + cCodigo + cNome) )
			If cCodOld <> ZFM->ZFM_CODIGO
				lRet := .f.
				Aviso("Registro existente", "Alteração não realizada pois já existe um registro com este mesmo código e nome informados...", {"OK"}, 3)
			EndIf
		EndIf
		
		// Checagem nome
		If lRet
			ZFM->( dbSetOrder(2) ) // ZFM_FILIAL+ZFM_NOME
			If ZFM->( dbSeek(FWxFilial("ZFM") + cNome) )
				If cCodOld <> ZFM->ZFM_CODIGO
					lRet := .f.
					Aviso("Registro existente", "Alteração não realizada pois já existe um registro com este mesmo nome informado...", {"OK"}, 3)
				EndIf
			EndIf
		EndIf
		
		// Checagem celular
		If lRet
			ZFM->( dbSetOrder(3) ) // ZFM_FILIAL+ZFM_NUMCEL
			If ZFM->( dbSeek(FWxFilial("ZFM") + cNumCel) )
				If cCodOld <> ZFM->ZFM_CODIGO
					lRet := .f.
					Aviso("Registro existente", "Alteração não realizada pois já existe um registro com este mesmo celular informado...", {"OK"}, 3)
				EndIf
			EndIf
		EndIf

				// CHAMADO: 058395 - ADRIANO SAVOINE - 22/05/2020
		If lRet
			DbSelectArea("ZFM")
			dbSetOrder(1)  
			IF dbSeek (FWxFilial("ZFM") + cCodigo) 
				// CHAMADO: 058395 - ADRIANO SAVOINE - 22/05/2020
				RecLock("ZFM", .F.)
					ZFM_NOME   := cNome
					ZFM_NUMCEL := cNumCel
					ZFM_NUMFIX := cNumFix
					ZFM_HORALM := cHorAlm
					ZFM_OBSALM := cObsAlm
					ZFM_MSBLQL := cMSBLQL
					ZFM_NUMCE2 := cNumCe2 // Chamado n. 049495 || OS 050775 || ADM.LOG || MARCEL || 8365 || Incluir novo campo ZFM_NUMCE2 - FWNM - 08/08/2019
				ZFM->( msUnLock() )
			ENDIF
			Aviso("Alteração", "Alteração realizada com sucesso!", {"OK"}, 3)
		EndIf
		
	// Se for exclusao
	ElseIf nOpc == MODEL_OPERATION_DELETE
		
		lPermite := ChkDados(cCodigo)
		
		If lPermite
			
			RecLock("ZFM", .F.)
				dbDelete()
			ZFM->( msUnLock() )
			
			Aviso("Exclusão", "Exclusão realizada com sucesso!", {"OK"}, 3)
			
		Else
			lRet := .f.
			Aviso("Exclusão não permitida", "Exclusão não realizada pois já existem roteiros atrelados...", {"OK"}, 3)
			
		EndIf
		
	EndIf

Return lRet

/*/{Protheus.doc} User Function ADLOG061P
	(Funcao chamada ao CANCELAR as informacoes do modelo dados (botao CANCELAR) )
	@type  Function
	@author Fernando Macieira
	@since 01/08/2019
	@version 01
	/*/

User Function ZFMCan()

	Local oModelPad := FWModelActive()
	Local lRet      := .t.

	U_ADINF009P('ADLOG061P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro MVC modelo 1 para atendentes')
	
	// Somente permite cancelar se o usuario confirmar
	lRet := MsgYesNo("Deseja cancelar a operação?", "Atenção")
	
Return lRet

/*/{Protheus.doc} User Function ADLOG061P
	(Define se pode abrir o Modelo de Dados)
	@type  Function
	@author Fernando Macieira
	@since 01/08/2019
	@version 01
	/*/

Static Function fAlterar( oModel )

	Local lRet       := .t.
	Local nOperation := oModel:GetOperation()
	
	// Usuarios autorizados
	If lUsrAut
		If !(RetCodUsr() $ cUsrAut)
			lRet := .f.
			Aviso("MV_#USRAUT", "Usuário não autorizado!", {"OK"}, 3)
		EndIf
	EndIf
	
Return lRet

/*/{Protheus.doc} User Function ADLOG061P
	(Função para checar se o cadastro de atendentes pode ser excluido)
	@type  Function
	@author Fernando Macieira
	@since 04/09/2018
	@version 01
	/*/

Static Function ChkDados(cCodigo)

	Local lRet := .t.
	Local cQuery := ""
	
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	
	cQuery := " SELECT COUNT(1) TT "
	cQuery += " FROM " + RetSqlName("ZFN")
	cQuery += " WHERE ZFN_FILIAL='"+FWxFilial("ZFN")+"' "
	cQuery += " AND ZFN_CODIGO='"+cCodigo+"' "
	cQuery += " AND D_E_L_E_T_='' "
	
	tcQuery cQuery new alias "Work"
	
	Work->( dbGoTop() )
	
	If Work->TT >= 1
		lRet := .f.
	EndIf
	
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

Return lRet