#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "rwmake.ch"  

Static cTitulo := "Cadastro de Equipamento"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ADINF010P º Autor ³ Fernando Sigoli     º Data ³  19/06/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de Equipamento/Inventarios de TI                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADINF010P()
	Local aArea   	   := GetArea()
	Local oBrowse
	Local cFunNamBkp   := FunName()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Equipamento/Inventarios de TI')
	
	SetFunName("ADINF010P")
		
	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()
	
	//Setando a tabela de cadastro de equipamento de TI
	oBrowse:SetAlias("PAL")

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)
	
	//Legendas
	oBrowse:AddLegend( "PAL->PAL_STATUS == '1'", "GREEN",	"Ativo" )
	oBrowse:AddLegend( "PAL->PAL_STATUS == '2'", "RED",	    "Bloqueado" )
	
	
	//Ativa a BrowseD
	oBrowse:Activate()
	
	SetFunName("cFunNamBkp")
	RestArea(aArea)
Return Nil



/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
	Local aRot := {}
	
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.ADINF010P' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_zMVC01Leg'       OPERATION 6                      ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.ADINF010P' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.ADINF010P' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.ADINF010P' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	
Return aRot


/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 *---------------------------------------------------------------------*/
Static Function ModelDef()
	
	Local oModel 		:= Nil
	Local oStPai 		:= FWFormStruct(1, 'PAL')
	Local oStFilho 		:= FWFormStruct(1, 'PAM')
	Local oStNeto 		:= FWFormStruct(1, 'PAN')
	Local bVldPos 		:= {|| u_INF10POS()}       //Validação ao clicar no Confirmar
	
	Local aPAMRel		:= {}
	Local aPANRel		:= {}
	
	//Criando o modelo e os relacionamentos
	//oModel := MPFormModel():New('zMVCMdXM')
    oModel := MPFormModel():New("zMVCMdXM", , bVldPos, ,) 
	
	oModel:AddFields('PALMASTER',/*cOwner*/,oStPai)
	oModel:AddGrid('PAMDETAIL','PALMASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
	oModel:AddGrid('PANDETAIL','PALMASTER',oStNeto,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
	
	//Fazendo o relacionamento entre o Pai e Filho
	aAdd(aPAMRel, {'PAM_FILIAL',	'xFilial( "PAL" )'} )
	aAdd(aPAMRel, {'PAM_CODIGO',	'PAL_CODIGO'})
	
	//Fazendo o relacionamento entre o vô e Neto
	aAdd(aPANRel, {'PAN_FILIAL',	'xFilial( "PAL" )'} )
	aAdd(aPANRel, {'PAN_CODIGO',	'PAL_CODIGO'}) 
	
	oModel:SetRelation('PAMDETAIL', aPAMRel, PAM->(IndexKey(1))) 							//IndexKey -> quero a ordenação e depois filtrado
	oModel:GetModel('PAMDETAIL'):SetUniqueLine({"PAM_FILIAL","PAM_CODIGO","PAM_CODPER"})	//Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey({})
	
	oModel:SetRelation('PANDETAIL', aPANRel, PAN->(IndexKey(1))) 							//IndexKey -> quero a ordenação e depois filtrado
	oModel:GetModel('PANDETAIL'):SetUniqueLine({"PAN_FILIAL","PAN_CODIGO","PAN_CODAPL"})	//Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey({})
	
	//Setando as descrições
	oModel:SetDescription("Cadastro de Equipamentos")
	oModel:GetModel('PALMASTER'):SetDescription('Modelo Equipamentos')
	oModel:GetModel('PAMDETAIL'):SetDescription('Modelo Perifericos')
	oModel:GetModel('PANDETAIL'):SetDescription('Modelo Sw/Aplicativos')
	

Return oModel


/*---------------------------------------------------------------------*
 | Função:  ViewDef                                                    |
 *---------------------------------------------------------------------*/
Static Function ViewDef()
	
	Local oView			:= Nil
	Local oModel		:= FWLoadModel('ADINF010P')
	Local oStPai		:= FWFormStruct(2, 'PAL')
	Local oStFilho		:= FWFormStruct(2, 'PAM')
	Local oStNeto		:= FWFormStruct(2, 'PAN')

	//Estruturas das tabelas e campos a serem considerados
	Local aStruPAL		:= PAL->(DbStruct())
	Local aStruPAM		:= PAM->(DbStruct())
	Local aStruPAN		:= PAN->(DbStruct())
	
	Local cConsPAL		:= "PAL_CODIGO;PAL_DESCRI;PAL_TIPATV;PAL_HOSTVM;PAL_GRUPO;PAL_RACK;PAL_NSERIE;PAL_DTAQUI;PAL_PATRIM;PAL_DTGARA;PAL_FORCOD;PAL_FORLOJ;PAL_FORDES;PAL_PROPCO;PAL_USUCOD;PAL_USUNOM;PAL_OBSERV;PAL_STATUS;PAL_CCTCOD;PAL_FABCOD;PAL_PROCES;PAL_MEMORI;PAL_HARDDI"
	Local cConsPAM		:= "PAM_CODPER;PAM_DESPER;PAM_NSERIE"
	Local cConsPAN		:= "PAN_CODAPL;PAN_DESAPL;PAN_TIPO;PAN_DTAQUI;PAN_DTVCNT;PAN_NCONTA;PAN_SCONTA;PAN_CHAVE"
	Local nAtual		:= 0
	
	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//açoes relacionadas: 
	
	//oView:AddUserButton( "* Usuarios ", "" , {|oView| U_TelaUser() } )     
	
	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_PAL',oStPai,'PALMASTER')
	oView:AddGrid('VIEW_PAM',oStFilho,'PAMDETAIL')
	oView:AddGrid('VIEW_PAN',oStNeto,'PANDETAIL')
	
	
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',50)
	oView:CreateHorizontalBox('GRID',25)
	oView:CreateHorizontalBox('GRID2',25)
	
	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_PAL','CABEC')
	oView:SetOwnerView('VIEW_PAM','GRID')
	oView:SetOwnerView('VIEW_PAN','GRID2')
	
	
	//Habilitando título
	oView:EnableTitleView('VIEW_PAL','Equipamentos')
	oView:EnableTitleView('VIEW_PAM','Perifericos')
	oView:EnableTitleView('VIEW_PAN','Sw/Aplicativos')
	
	//Percorrendo a estrutura da PAL
	For nAtual := 1 To Len(aStruPAL)
		//Se o campo atual não estiver nos que forem considerados
		If ! Alltrim(aStruPAL[nAtual][01]) $ cConsPAL
			oStPai:RemoveField(aStruPAL[nAtual][01])
		EndIf
	Next
	
	//Percorrendo a estrutura da PAM
	For nAtual := 1 To Len(aStruPAM)
		//Se o campo atual não estiver nos que forem considerados
		If ! Alltrim(aStruPAM[nAtual][01]) $ cConsPAM
			oStFilho:RemoveField(aStruPAM[nAtual][01])
		EndIf
	Next
	
	//Percorrendo a estrutura da PAN
	For nAtual := 1 To Len(aStruPAN)
		//Se o campo atual não estiver nos que forem considerados
		If ! Alltrim(aStruPAN[nAtual][01]) $ cConsPAN
			oStNeto:RemoveField(aStruPAN[nAtual][01])
		EndIf
	Next
	
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})
	
Return oView

//Função chamada no clique do botão Ok do Modelo de Dados (pós-validação)
User Function INF10POS()

    Local oModelPad  := FWModelActive()
    
    Local cGrupo     := oModelPad:GetValue('PALMASTER', 'PAL_GRUPO')
    Local cTipoA     := oModelPad:GetValue('PALMASTER', 'PAL_TIPATV')
    Local cRack      := oModelPad:GetValue('PALMASTER', 'PAL_RACK')
    Local cHostP     := oModelPad:GetValue('PALMASTER', 'PAL_HOSTVM')
    Local cFisVM     := oModelPad:GetValue('PALMASTER', 'PAL_TIPATV')
    
    Local cAplic     := oModelPad:GetValue('PANDETAIL', 'PAN_CODAPL')
    Local DdtaAq     := oModelPad:GetValue('PANDETAIL', 'PAN_DTAQUI')
    Local DdtaVc     := oModelPad:GetValue('PANDETAIL', 'PAN_DTVCNT')
    Local cConta     := oModelPad:GetValue('PANDETAIL', 'PAN_NCONTA')
    Local cNsenh     := oModelPad:GetValue('PANDETAIL', 'PAN_SCONTA')
    
    Local lRet       := .T.

	U_ADINF009P('ADINF010P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Equipamento/Inventarios de TI')
  
     
    //Se for do Grupo Servidor ou Desktop é necessario informar se é Fisico ou Virtualizado
    If Empty(cTipoA) .and. (cGrupo == '1' .or. cGrupo == '2')
        lRet := .F.
        Aviso('Atenção', 'Para grupos Server ou Desktop è necessario Informar o Tipo = Fisico ou Virtualizado', {'OK'}, 03)
    EndIf
    
    //Para grupos de servidore é necessario informar qual o Rack de Alocação
    If Empty(cRack) .and.  cGrupo == '2'
        lRet := .F.
        Aviso('Atenção', 'Para grupos de servidore é necessario informar qual o Rack de Alocação', {'OK'}, 03)
    EndIf
    
    //caso for aplicativo office 365, faz obrigatorio informada dataAquisicao/dataVencimento/Conta e Senha 
    If cAplic $ "17/23" 
    	If Empty(DdtaAq) .or. Empty(DdtaVc) .or. Empty(cConta) .or. Empty(cNsenh)
    		Aviso('Atenção', 'Para Aplicativo/SW, classificado como Office 365. È obrigado Informar Dta Aquisição, Dta Vencto,Numero Conta e Senha', {'OK'}, 03)
    		lRet := .F.
    	EndIF
    EndIf
    
    If Empty(cHostP) .and. cFisVM == "1"  
        Aviso('Atenção', 'Para Equipamentos classificado como Virtualizado, é necessario informar o HOST Principal.', {'OK'}, 03)
        lRet := .F.
    EndIf
     
Return lRet