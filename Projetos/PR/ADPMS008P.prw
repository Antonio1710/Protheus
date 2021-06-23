#include "protheus.ch"
#include "topconn.ch"
#include "FWMVCDef.ch"

// Variaveis estaticas
Static cTitulo  := "Cadastro Grupo Projetos Investimentos"
Static cMSBLQL  := "2"
Static cTabela  := "ZFL"
Static lUsrAut  := GetMV("MV_#ATVUSR",,.t.) // Ativa controle de usuarios autorizados
Static cUsrAut  := GetMV("MV_#USRAUT",,"000000#002027#001657#001719") // Usuarios autorizados 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADPMS008P �Autor  �Fernando Macieira   � Data �  12/06/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro MVC modelo 1 - Grupo Projetos Investimentos       ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������͹��
���Chamado   � 049835 || OS 051126 || TECNOLOGIA || LUIZ || 8451 ||       ���
���          � || GRUPO DE PROJETOS - FWNM - 12/06/2019                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function ADPMS008P()

	Local oBrowse
	Local aAreaAtu := GetArea()
	Local cFunBkp  := FunName()
	
	SetFunName("ADPMS008P")

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro MVC modelo 1 - Grupo Projetos Investimentos')
	
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

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADPMS008P �Autor  �Fernando Macieira   � Data �  12/06/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Criacao do MENU MVC                                        ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

	Local aRot := {}
	
	// Adicionando opcoes
	ADD OPTION aRot TITLE "Visualizar" ACTION "VIEWDEF.ADPMS008P" OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // OPERACAO 1
	ADD OPTION aRot TITLE "Incluir"    ACTION "VIEWDEF.ADPMS008P" OPERATION MODEL_OPERATION_INSERT ACCESS 0 // OPERACAO 3
	ADD OPTION aRot TITLE "Alterar"    ACTION "VIEWDEF.ADPMS008P" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // OPERACAO 4
	ADD OPTION aRot TITLE "Excluir"    ACTION "VIEWDEF.ADPMS008P" OPERATION MODEL_OPERATION_DELETE ACCESS 0 // OPERACAO 5

Return aRot

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADPMS008P �Autor  �Fernando Macieira   � Data �  12/06/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Criacao do MODELO de dados MVC                             ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

	// Blocos de codigos nas validacoes
	Local bVldPre := {|| u_ZFLPre()} // Antes de abrir a tela
	Local bVldPos := {|| u_ZFLPos()} // Validacao ao clicar no botao confirmar
	Local bVldCom := {|| u_ZFLCom()} // Funcao chamada no commit
	Local bVldCan := {|| u_ZFLCan()} // Funcao chamada no cancelar
	
	// Criacao do objeto do modelo de dados
	Local oModel := Nil
	
	// Criacao da estrutura de dados utilizada na interface
	Local oStDad := FWFormStruct(1, cTabela)
	
	// Editando caracteristicas do dicionario
	oStDad:SetProperty("ZFL_CODIGO",  MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) // MODO EDICAO
	oStDad:SetProperty("ZFL_DESCRI",  MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) // MODO EDICAO
	oStDad:SetProperty("ZFL_MSBLQL",  MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) // MODO EDICAO
	
	oStDad:SetProperty("ZFL_CODIGO", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, 'GETSXENUM("ZFL","ZFL_CODIGO")')) // INI PADRAO
	oStDad:SetProperty("ZFL_MSBLQL", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "'"+cMSBLQL+"'")) // INI PADRAO
	
	// Instanciando o modelo, nao e recomendado colocar o nome da user function (por causa do u_), respeitando o limite de 10 caracteres
	oModel := MPFormModel():New("U_ADPMS008P", bVldPre, bVldPos, bVldCom, bVldCan)
	
	// Atribuindo formularios para o modelo
	oModel:AddFields("FORMZFL", /*cOwner*/, oStDad)
	
	// Setando a chave primaria da rotina
	oModel:SetPrimaryKey( {"ZFL_FILIAL", "ZFL_CODIGO"} )
	
	// Adicionando descricao ao modelo
	oModel:SetDescription(cTitulo)
	
	// Setando a descricao do formulario
	oModel:GetModel("FORMZFL"):SetDescription(cTitulo)
	
	// Pode ativar?
	oModel:SetVldActive( { | oModel | fAlterar(oModel) } )

Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADPMS008P �Autor  �Fernando Macieira   � Data �  12/06/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Criacao da VISAO MVC                                       ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()

	Local aStruZFL := ZFL->( dbStruct() )
	
	// Criacao do objeto do modelo de dados da interface do cadastro
	Local oModel := FWLoadModel("ADPMS008P")
	
	// Criacao da estrutura de dados utilizada na interface do cadastro
	Local oStDad := FWFormStruct(2, cTabela) // pode se usar um terceiro parametro para filtrar os campos exibidos [ |cCampo| cCampo $ "SZFL_NOME|SZFL_
	
	// Criando oView como nulo
	Local oView := Nil
	
	// Criando a VIEW que sera o retorno da funcao e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	// Atribuindo formularios para interface
	oView:AddField("VIEW_ZFL", oStDad, "FORMZFL")
	
	// Criando container com nome tela 100%
	oView:CreateHorizontalBox("TELA", 100)
	
	// Colocando titulo do formulario
	oView:EnableTitleView("VIEW_ZFL", cTitulo )
	
	// Forca o fechamento da janela na confirmacao
	oView:SetCloseOnOK( {|| .t.} )
	
	// O formulario da interface sera colocado dentro do container
	oView:SetOwnerView("VIEW_ZFL", "TELA")

Return oView

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADPMS008P �Autor  �Fernando Macieira   � Data �  12/06/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao chamada na criacao do modelo de dados               ���
���          � (PRE-VALIDACAO)                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function ZFLPre()

	Local oModelPad := FWModelActive()
	Local nOpc      := oModelPad:GetOperation()
	Local lRet      := .t.
	Local cWhen     := ".f."

	U_ADINF009P('ADPMS008P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro MVC modelo 1 - Grupo Projetos Investimentos')
	
	// Se for inclusao, alteracao ou exclusao
	If (nOpc == MODEL_OPERATION_INSERT) .or. (nOpc == MODEL_OPERATION_UPDATE)
		
		// Usuarios autorizados
		If lUsrAut
			If RetCodUsr() $ cUsrAut
				cWhen := ".t."
			EndIf
			
		Else
			cWhen := ".t."
			
		EndIf
		
		// Se for inclusao, alteracao ou exclusao
		If nOpc == MODEL_OPERATION_INSERT
			oModelPad:GetModel("FORMZFL"):GetStruct():SetProperty("ZFL_CODIGO", MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, cWhen))
			oModelPad:GetModel("FORMZFL"):GetStruct():SetProperty("ZFL_DESCRI", MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, cWhen))
			oModelPad:GetModel("FORMZFL"):GetStruct():SetProperty("ZFL_MSBLQL", MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, ".f."))
			
		ElseIf nOpc == MODEL_OPERATION_UPDATE
			oModelPad:GetModel("FORMZFL"):GetStruct():SetProperty("ZFL_CODIGO", MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, ".f."))
			oModelPad:GetModel("FORMZFL"):GetStruct():SetProperty("ZFL_DESCRI", MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, ".t."))
			oModelPad:GetModel("FORMZFL"):GetStruct():SetProperty("ZFL_MSBLQL", MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, ".t."))
			
		EndIf
		
	EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADPMS008P �Autor  �Fernando Macieira   � Data �  12/06/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao chamada no clique do botao OK do modelo de dados    ���
���          � (POS-VALIDACAO)                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function ZFLPos()

	Local oModelPad := FWModelActive()
	
	Local cCodigo   := oModelPad:GetValue("FORMZFL", "ZFL_CODIGO")
	Local cDescri   := oModelPad:GetValue("FORMZFL", "ZFL_DESCRI")
	
	Local lRet      := .t.

	U_ADINF009P('ADPMS008P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro MVC modelo 1 - Grupo Projetos Investimentos')
	
	If lRet
		If Empty(cCodigo) .or. Empty(cDescri)
			lRet := .f.
			Aviso("Campos vazios", "C�digo ou Descri��o est�o vazios... campos obrigat�rios!", {"OK"}, 3)
		EndIf
	EndIf
	
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADPMS008P �Autor  �Fernando Macieira   � Data �  12/06/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao chamada apos validar o OK da rotina para os dados   ���
���          � serem salvos                                               ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function ZFLCom()

	Local oModelPad := FWModelActive()
	Local nOpc      := oModelPad:GetOperation()
	Local lRet      := .t.
	Local lPermite  := .t.
	
	Local cCodigo   := oModelPad:GetValue("FORMZFL", "ZFL_CODIGO")
	Local cDescri   := oModelPad:GetValue("FORMZFL", "ZFL_DESCRI")
	Local cMSBLQL   := oModelPad:GetValue("FORMZFL", "ZFL_MSBLQL")

	U_ADINF009P('ADPMS008P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro MVC modelo 1 - Grupo Projetos Investimentos')
	
	// Se for inclusao
	If nOpc == MODEL_OPERATION_INSERT
		
		// Checagem codigo
		ZFL->( dbSetOrder(1) ) // ZFL_FILIAL + ZFL_CODIGO
		If ZFL->( dbSeek(FWxFilial("ZFL") + cCodigo) )
			lRet := .f.
			Aviso("C�digo existente", "Inclus�o n�o realizada pois j� existe um registro com o c�digo informado...", {"OK"}, 3)
		EndIf
		
		// Checagem Descri��o
		If lRet
			ZFL->( dbSetOrder(2) ) // ZFL_FILIAL+ZFL_DESCRI
			If ZFL->( dbSeek(FWxFilial("ZFL") + cDescri) )
				lRet := .f.
				Aviso("Descri��o existente", "Inclus�o n�o realizada pois j� existe um registro com a descri��o informada...", {"OK"}, 3)
			EndIf
		EndIf
		
		If lRet

			RecLock("ZFL", .T.)
				ZFL_FILIAL := FWxFilial("ZFL")
				ZFL_CODIGO := cCodigo
				ZFL_DESCRI := cDescri
				ZFL_MSBLQL := cMSBLQL
			ZFL->( msUnLock() )
			
			ConfirmSX8()
			
			Aviso("Inclus�o", "Inclus�o realizada com sucesso!", {"OK"}, 3)

		EndIf
		
	// Se for alteracao
	ElseIf nOpc == MODEL_OPERATION_UPDATE
		
		// Checagem Descri��o
		ZFL->( dbSetOrder(2) ) // ZFL_FILIAL+ZFL_DESCRI
		If ZFL->( dbSeek(FWxFilial("ZFL") + cDescri) )
			If cCodigo <> ZFL->ZFL_CODIGO
				lRet := .f.
				Aviso("Descri��o existente", "Altera��o n�o realizada pois j� existe um registro com a descri��o informada...", {"OK"}, 3)
			EndIf
		EndIf
		
		If lRet
			RecLock("ZFL", .F.)
				ZFL_DESCRI := cDescri
				ZFL_MSBLQL := cMSBLQL
			ZFL->( msUnLock() )

			Aviso("Altera��o", "Altera��o realizada com sucesso!", {"OK"}, 3)
		EndIf
		
	// Se for exclusao
	ElseIf nOpc == MODEL_OPERATION_DELETE
		
		lPermite := ChkDados(cCodigo)
		
		If lPermite
			
			RecLock("ZFL", .F.)
				dbDelete()
			ZFL->( msUnLock() )
			
			Aviso("Exclus�o", "Exclus�o realizada com sucesso!", {"OK"}, 3)
			
		Else
			lRet := .f.
			Aviso("Exclus�o n�o permitida", "Exclus�o n�o realizada pois este grupo possui projetos amarrados...", {"OK"}, 3)
			
		EndIf
		
	EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADPMS008P �Autor  �Fernando Macieira   � Data �  12/06/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao chamada ao CANCELAR as informacoes do modelo dados  ���
���          � (botao CANCELAR)                                           ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function ZFLCan()

	Local oModelPad := FWModelActive()
	Local lRet      := .t.

	U_ADINF009P('ADPMS008P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro MVC modelo 1 - Grupo Projetos Investimentos')
	
	// Somente permite cancelar se o usuario confirmar
	lRet := MsgYesNo("Deseja cancelar a opera��o?", "Aten��o")

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADPMS008P �Autor  �Fernando Macieira   � Data �  12/06/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Define se pode abrir o Modelo de Dados                     ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fAlterar( oModel )

	Local lRet       := .t.
	Local nOperation := oModel:GetOperation()
	
	// Usuarios autorizados
	If lUsrAut
		If !(RetCodUsr() $ cUsrAut)
			lRet := .f.
			Aviso("MV_#USRAUT", "Usu�rio n�o autorizado!", {"OK"}, 3)
		EndIf
	EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADPMS008P �Autor  �Fernando Macieira   � Data �  12/06/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o para checar se o grupo de projetos pode ou nao ser  ���
���          � ser alterado ou excluido                                   ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ChkDados(cCodigo)

	Local lRet := .t.
	Local cQuery := ""
	
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	
	cQuery := " SELECT COUNT(1) TT "
	cQuery += " FROM " + RetSqlName("AF8")
	cQuery += " WHERE AF8_XGRUPO='"+cCodigo+"' "
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