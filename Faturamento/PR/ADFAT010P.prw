#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  ADFAT010P � Autor � Fernando Sigoli     � Data �  08/10/18   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Grupo de inspe��o              				  ���
���          � Relacionado na tabela de clientes SA1                      ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static cTitulo := "Grupo de Inspe��o"
 
User Function ADFAT010P()  //U_ADFAT010P()
    Local aArea   := GetArea()
    Local oBrowse
    Local cFunBkp := FunName()
     
    SetFunName("ADFAT010P")

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Grupo de inspe��o Relacionado na tabela de clientes SA1')
     
    //Inst�nciando FWMBrowse - Somente com dicion�rio de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de grupo de inspe��o
    oBrowse:SetAlias("ZCO")
 
    //Setando a descri��o da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Legendas
    oBrowse:AddLegend( "ZCO->ZCO_MSBLQL = '2'", "GREEN",  "Ativo" )
    oBrowse:AddLegend( "ZCO->ZCO_MSBLQL = '1'", "RED",    "Bloqueado" )
     
     
    //Ativa a Browse
    oBrowse:Activate()
     
    SetFunName(cFunBkp)
    RestArea(aArea)
Return Nil
 


Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando op��es
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.ADFAT010P' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_FAT010Leg'       OPERATION 6                      ACCESS 0 //OPERATION X
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.ADFAT010P' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.ADFAT010P' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.ADFAT010P' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot
 


 
Static Function ModelDef()
    //Cria��o do objeto do modelo de dados
    Local oModel := Nil
     
    //Cria��o da estrutura de dados utilizada na interface
    Local oStZCO := FWFormStruct(1, "ZCO")
     
    //Editando caracter�sticas do dicion�rio
    oStZCO:SetProperty('ZCO_CODIGO',  MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edi��o
    oStZCO:SetProperty('ZCO_CODIGO',  MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZCO", "ZCO_CODIGO")'))      //Ini Padr�o
    oStZCO:SetProperty('ZCO_DESCRI',  MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'Iif(Empty(M->ZCO_DESCRI), .F., .T.)')) //Valida��o de Campo
    oStZCO:SetProperty('ZCO_DESCRI',  MODEL_FIELD_OBRIGAT, Iif(RetCodUsr()!='000000', .T., .F.) )                                         //Campo Obrigat�rio
     
    //Instanciando o modelo, n�o � recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("zModel1M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)
     
    //Atribuindo formul�rios para o modelo
    oModel:AddFields("FORMZCO",/*cOwner*/,oStZCO)
     
    //Setando a chave prim�ria da rotina
    oModel:SetPrimaryKey({'ZCO_FILIAL','ZCO_CODIGO'})
     
    //Adicionando descri��o ao modelo
    oModel:SetDescription(cTitulo)
     
    //Setando a descri��o do formul�rio
    oModel:GetModel("FORMZCO"):SetDescription(cTitulo)
Return oModel
 
 
Static Function ViewDef()
    Local aStruZCO    := ZCO->(DbStruct())
     
    //Cria��o do objeto do modelo de dados da Interface do Cadastro
    Local oModel := FWLoadModel("ADFAT010P")
     
    //Cria��o da estrutura de dados utilizada na interface do cadastro
    Local oStZCO := FWFormStruct(2, "ZCO")  //pode se usar um terceiro par�metro para filtrar os campos exibidos 
     
    //Criando oView como nulo
    Local oView := Nil
 
    //Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formul�rios para interface
    oView:AddField("VIEW_ZCO", oStZCO, "FORMZCO")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando t�tulo do formul�rio
    oView:EnableTitleView('VIEW_ZCO', 'Dados - '+cTitulo ) 
     
    //For�a o fechamento da janela na confirma��o
    oView:SetCloseOnOk({||.T.})
     
    //O formul�rio da interface ser� colocado dentro do container
    oView:SetOwnerView("VIEW_ZCO","TELA")
     

Return oView
 

User Function zMod1Leg()
    Local aLegenda := {}
     
    //Monta as cores
    AADD(aLegenda,{"BR_VERDE",       "Ativo"  })
    AADD(aLegenda,{"BR_VERMELHO",    "Bloqueado"})
     
    BrwLegenda(cTitulo, "Status", aLegenda)
Return