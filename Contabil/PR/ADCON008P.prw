#Include 'Protheus.ch'
#Include 'FwMvcDef.ch'
#Include 'Parmtype.ch'
#Include "Topconn.ch"
#INCLUDE 'FILEIO.CH'
#INCLUDE "rwmake.ch"
#Include "MSMGADD.CH"     
  
Static cTitulo      := "Cadastro Usuario X Centro de Custo"

/*{Protheus.doc} User Function ADCON008P
	Cadastro de Usuarios X Centro de Custo
	@type  Function
	@author WILLIAM COSTA
	@since 28/10/2017
	@version 01
	@history Chamado 056028 - William Costa - 20/02/2020 - Ajuste no numero da Sequencia das linhas, para carregar o numero correto na inclusão de um novo centro de custo
	@history Chamado 056206 - William Costa - 28/02/2020 - Ajuste Error Log array out of bounds ( 0 of 0 )  on U_INIPAEITEM(ADCON008P.PRW) 20/02/2020 11:49:07 line : 530
	@history Chamado 056490 - William Costa - 11/03/2020 - Identificado falha no quando o item vira DEZ, a função SOMA1 ao invés de virar 10 estava virando A, onde gerava erro
*/	

User Function ADCON008P()

	Local   aArea      := GetArea()
	Local   oBrowse
	Local   cFunNamBkp := FunName()
	Local   aBrowse    := {}
    Local   aSeek      := {}
    Local   aIndex     := {}
    Private cAliasTmp  := "TRC"
    Private cInd1      := ""
	Private cInd2      := ""
	Private aTrab      := NIL
	Private cArqs      := ""
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	If Select("TRC") > 0
		TRC->(DbCloseArea())
	EndIf
	
	MsgRun("Criando estrutura e carregando dados no arquivo temporário...",,{|| aTRC := FileTRC() } )
		
	//Definindo as colunas que serão usadas no browse
    aAdd(aBrowse, {"Codigo Usuario", "TMP_CODUSU", "C", 06, 0, "@!"})
    aAdd(aBrowse, {"Nome Usuario"  , "TMP_NOME", "C", 40, 0, "@!"})
    
    SetFunName("ADCON008P")
	
	aAdd(aIndex, "TMP_CODUSU" ) 
	
	aAdd(aSeek,{"Codigo Usuario",{{"","C",006,0,"TMP_CODUSU","@!"}} } )
	aAdd(aSeek,{"Nome Usuario"	,{{"","C",040,0,"TMP_NOME"	,"@!"}} } )
     
    //Criando o browse da temporária
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias(cAliasTmp)
    oBrowse:SetQueryIndex(aIndex)
    oBrowse:SetTemporary(.T.)
    oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
    oBrowse:SetFields(aBrowse)
    oBrowse:DisableDetails()
    oBrowse:SetDescription(cTitulo)
    oBrowse:Activate()
	
	SetFunName("cFunNamBkp")
	DelTabTemporaria()
	RestArea(aArea)
	
Return Nil

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 *---------------------------------------------------------------------*/
Static Function MenuDef()

	Local aRot := {}
	
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.ADCON008P' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.ADCON008P' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	
Return aRot

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 *---------------------------------------------------------------------*/
Static Function ModelDef()
	
	Local oModel    := Nil
	Local oStPai    := FWFormModelStruct():New()
	Local oStFilho  := FWFormStruct(1, 'PAE')
	Local bLinePost := {|| u_CON008LP()}
	//Local bPre      := {|| u_CON008BP()}       //Validação ao clicar no Confirmar
	Local aPAERel   := {}
	
	oStPai:AddTable(cAliasTmp, {'TMP_CODUSU', 'TMP_NOME'}, "Temporaria")
     
    //Adiciona os campos da estrutura
    oStPai:AddField(;
			        "Codigo",;                                                                                  // [01]  C   Titulo do campo
			        "Codigo",;                                                                                  // [02]  C   ToolTip do campo
			        "TMP_CODUSU",;                                                                              // [03]  C   Id do Field
			        "C",;                                                                                       // [04]  C   Tipo do campo
			        06,;                                                                                        // [05]  N   Tamanho do campo
			        0,;                                                                                         // [06]  N   Decimal do campo
			        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
			        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
			        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
			        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
			        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->TMP_CODUSU,'')" ),;  // [11]  B   Code-block de inicializacao do campo
			        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
			        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
			        .F.)                                                                                        // [14]  L   Indica se o campo é virtual                          
                                                                      
    oStPai:AddField(;
			        "Nome",;                                                                                    // [01]  C   Titulo do campo
			        "Nome",;                                                                                    // [02]  C   ToolTip do campo
			        "TMP_NOME",;                                                                                // [03]  C   Id do Field
			        "C",;                                                                                       // [04]  C   Tipo do campo
			        40,;                                                                                        // [05]  N   Tamanho do campo
			        0,;                                                                                         // [06]  N   Decimal do campo
			        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
			        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
			        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
			        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
			        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->TMP_NOME,'')" ),;        // [11]  B   Code-block de inicializacao do campo
			        .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
			        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
			        .F.)		                                                                                // [14]  L   Indica se o campo é virtual 
	
	//Editando características do dicionário		        
	oStFilho:SetProperty('PAE_CODUSR', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'TRC->TMP_CODUSU')) //Ini Padrão
	oStFilho:SetProperty('PAE_CODUSR', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN,   '.F.'))             //Modo de Edição
	oStFilho:SetProperty('PAE_ITEM'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'u_IniPaeITEM()')) //Ini Padrão
	oStFilho:SetProperty('PAE_ITEM'  , MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN,   '.F.'))             //Modo de Edição
	
	//Criando o modelo e os relacionamentos
	oModel := MPFormModel():New("zACON008", , /*bVldPos*/, ,) 
	
	oModel:AddFields('USUMASTER',/*cOwner*/,oStPai)
	oModel:AddGrid('PAEDETAIL','USUMASTER',oStFilho,/*bLinePre*/, bLinePost,/*bPre*/,/*bPos - Grid Inteiro*/,/*bLoad*/)  //cOwner é para quem pertence
	
	//Fazendo o relacionamento entre o Pai e Filho
	aAdd(aPAERel, {'PAE_FILIAL',	'xFilial( "PAE" )'} )
	aAdd(aPAERel, {'PAE_CODUSR',	'TMP_CODUSU'})
	
	oModel:SetRelation('PAEDETAIL', aPAERel, PAE->(IndexKey(1))) 							//IndexKey -> quero a ordenação e depois filtrado
	oModel:GetModel('PAEDETAIL'):SetUniqueLine({"PAE_FILIAL","PAE_CODUSR","PAE_ITEM"})	//Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey({})
	
	//Setando as descrições
	oModel:SetDescription("Cadastro de Usuarios X Centro de Custo")
	oModel:GetModel('USUMASTER'):SetDescription('Modelo Usuario')
	oModel:GetModel('PAEDETAIL'):SetDescription('Modelo Centro de Custo')

Return oModel

/*---------------------------------------------------------------------*
 | Função:  ViewDef                                                    |
 *---------------------------------------------------------------------*/
Static Function ViewDef()
	
	Local oView			:= Nil
	Local oModel		:= FWLoadModel('ADCON008P')
	Local oStPai		:= FWFormViewStruct():New()
	Local oStFilho		:= FWFormStruct(2, 'PAE')
	Local nAtual        := 0 

	//Adicionando campos da estrutura
    oStPai:AddField(;
			        "TMP_CODUSU",;                 // [01]  C   Nome do Campo
			        "01",;                      // [02]  C   Ordem
			        "Codigo",;                  // [03]  C   Titulo do campo
			        "Codigo",;                  // [04]  C   Descricao do campo
			        Nil,;                       // [05]  A   Array com Help
			        "C",;                       // [06]  C   Tipo do campo
			        "@!",;                      // [07]  C   Picture
			        Nil,;                       // [08]  B   Bloco de PictTre Var
			        Nil,;                       // [09]  C   Consulta F3
			        Iif(INCLUI, .T., .F.),;     // [10]  L   Indica se o campo é alteravel
			        Nil,;                       // [11]  C   Pasta do campo
			        Nil,;                       // [12]  C   Agrupamento do campo
			        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
			        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
			        Nil,;                       // [15]  C   Inicializador de Browse
			        Nil,;                       // [16]  L   Indica se o campo é virtual
			        Nil,;                       // [17]  C   Picture Variavel
			        Nil)                        // [18]  L   Indica pulo de linha após o campo
        
    oStPai:AddField(;
			        "TMP_NOME",;                // [01]  C   Nome do Campo
			        "02",;                      // [02]  C   Ordem
			        "Nome",;                    // [03]  C   Titulo do campo
			        "Nome",;                    // [04]  C   Descricao do campo
			        Nil,;                       // [05]  A   Array com Help
			        "C",;                       // [06]  C   Tipo do campo
			        "@!",;                      // [07]  C   Picture
			        Nil,;                       // [08]  B   Bloco de PictTre Var
			        Nil,;                       // [09]  C   Consulta F3
			        .T.,;                       // [10]  L   Indica se o campo é alteravel
			        Nil,;                       // [11]  C   Pasta do campo
			        Nil,;                       // [12]  C   Agrupamento do campo
			        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
			        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
			        Nil,;                       // [15]  C   Inicializador de Browse
			        Nil,;                       // [16]  L   Indica se o campo é virtual
			        Nil,;                       // [17]  C   Picture Variavel
			        Nil)                        // [18]  L   Indica pulo de linha após o campo
	
	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//açoes relacionadas: 
	//oView:AddUserButton( "* Usuarios ", "" , {|oView| U_TelaUser() } )     
	
	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_PAI',oStPai,'USUMASTER')
	oView:AddGrid('VIEW_PAE',oStFilho,'PAEDETAIL')
	
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',25)
	oView:CreateHorizontalBox('GRID',75)
	
	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_PAI','CABEC')
	oView:SetOwnerView('VIEW_PAE','GRID')
	
	//Habilitando título
	oView:EnableTitleView('VIEW_PAI','Usuario')
	oView:EnableTitleView('VIEW_PAE','Centro de Custo')
	
	//Removendo campo desnecessário
	oStFilho:RemoveField('PAE_NOMUSR')
	
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

Return oView

//Função chamada na linha Ok apos
User Function CON008LP()
 
	Local aArea       := GetArea()
    Local cCCIni      := StrTran(Space(TamSX3('PAE_CCINI')[1]), ' ', '0')
    Local cCCFim      := StrTran(Space(TamSX3('PAE_CCFIM')[1]), ' ', '0')
    Local cITIni      := StrTran(Space(TamSX3('PAE_ITINI')[1]), ' ', '0')
    Local cITFim      := StrTran(Space(TamSX3('PAE_ITFIM')[1]), ' ', '0')
    Local cGRPIni     := StrTran(Space(TamSX3('PAE_GRPINI')[1]), ' ', '0')
    Local cGRPFim     := StrTran(Space(TamSX3('PAE_GRPFIM')[1]), ' ', '0')
    Local oModelPad   := FWModelActive()
    Local oModelGrid  := oModelPad:GetModel('PAEDETAIL')
    Local nOperacao   := oModelPad:nOperation
    Local nLinAtu     := oModelGrid:nLine
    Local nPoscCCIni  := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("PAE_CCINI")})
    Local nPoscCCFim  := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("PAE_CCFIM")})
    Local nPoscITIni  := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("PAE_ITINI")})
    Local nPoscITFim  := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("PAE_ITFIM")})
    Local nPoscGRPIni := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("PAE_GRPINI")})
    Local nPoscGRPFim := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("PAE_GRPFIM")})
    Local lRet        := .T.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
    
    cCCIni  := oModelGrid:aDataModel[nLinAtu][1][1][nPoscCCIni]  // oModelGrid:aCols[nLinAtu][nPoscCCIni] WILLIAM COSTA 16/01/2018
    cCCFim  := oModelGrid:aDataModel[nLinAtu][1][1][nPoscCCFim]  //oModelGrid:aCols[nLinAtu][nPoscCCFim]  WILLIAM COSTA 16/01/2018
    cITIni  := oModelGrid:aDataModel[nLinAtu][1][1][nPoscITIni]  //oModelGrid:aCols[nLinAtu][nPoscITIni]  WILLIAM COSTA 16/01/2018
    cITFim  := oModelGrid:aDataModel[nLinAtu][1][1][nPoscITFim]  //oModelGrid:aCols[nLinAtu][nPoscITFim]  WILLIAM COSTA 16/01/2018
    cGRPIni := oModelGrid:aDataModel[nLinAtu][1][1][nPoscGRPIni] //oModelGrid:aCols[nLinAtu][nPoscGRPIni] WILLIAM COSTA 16/01/2018
    cGRPFim := oModelGrid:aDataModel[nLinAtu][1][1][nPoscGRPFim] //oModelGrid:aCols[nLinAtu][nPoscGRPFim] WILLIAM COSTA 16/01/2018
    
    // *** INICIO VALIDACAO CENTRO DE CUSTO INICIAL *** //
    DBSELECTAREA("CTT")
    DBSETORDER(1)
    IF !( MSSEEK(FwxFilial("CTT") + cCCIni, .F. ) ) .AND. lRet == .T.
    
    	Help( ,, 'ADCON008P-0001',, "Centro de custo não localizado no cadastro." + Chr(13) + Chr(10) +;
    	                            "Informe um centro de custo válido." + Chr(13) + Chr(10) +;
    	                            "Centro de Custo: " + cCCIni, 1, 0 )
    	                            
    	lRet := .F.                            
    
    ELSE
    
    	DO CASE
    	
			CASE CTT->CTT_CLASSE == "1" .AND. lRet == .T.
			
				Help( ,, 'ADCON008P-0002',, "Centro de Custo sintético. Não pode ser utilizado." + Chr(13) + Chr(10) +;
    	                                    "Informe um centro de custo válido." + Chr(13) + Chr(10) +;
    	                                    "Centro de Custo: " + cCCIni, 1, 0 )
    	        lRet := .F.
    	                            
			CASE cCCIni > cCCFim .AND. lRet == .T.
			
				Help( ,, 'ADCON008P-0003',, "Centro de Custo inicial não pode ser maior que o final." + Chr(13) + Chr(10) +;
    	                                    "Informe um centro de custo válido." + Chr(13) + Chr(10) +;
    	                                    "Centro de Custo: " + cCCIni, 1, 0 )
    	        lRet := .F.
    	        
    	    CASE cCCFim < cCCIni .AND. lRet == .T. 
			
				Help( ,, 'ADCON008P-0004',, "Centro de Custo final não pode ser menor que o inicial" + Chr(13) + Chr(10) +;
    	                                    "Informe um centro de custo válido." + Chr(13) + Chr(10) +;
    	                                    "Centro de Custo: " + cCCFim, 1, 0 )
    	        lRet := .F.    
    	        
			OTHERWISE
				
		ENDCASE
    
    ENDIF
    
    // *** FINAL VALIDACAO CENTRO DE CUSTO INICIAL ***//
    
    // *** INICIO VALIDACAO CENTRO DE CUSTO FINAL *** //
    DBSELECTAREA("CTT")
    DBSETORDER(1)
    IF !( MSSEEK(FwxFilial("CTT") + cCCFim, .F. ) ) .AND. lRet == .T.
    
    	Help( ,, 'ADCON008P-0005',, "Centro de custo não localizado no cadastro." + Chr(13) + Chr(10) +;
    	                            "Informe um centro de custo válido." + Chr(13) + Chr(10) +;
    	                            "Centro de Custo: " + cCCFim, 1, 0 )
    	                            
    	lRet := .F.
    	
    ELSE
    
    	IF CTT->CTT_CLASSE == "1" .AND. lRet == .T.
			
				Help( ,, 'ADCON008P-0006',, "Centro de Custo sintético. Não pode ser utilizado." + Chr(13) + Chr(10) +;
    	                                    "Informe um centro de custo válido." + Chr(13) + Chr(10) +;
    	                                    "Centro de Custo: " + cCCFim, 1, 0 )
    	        lRet := .F.
    	ENDIF
    	
    ENDIF
    
    // *** FINAL VALIDACAO CENTRO DE CUSTO FINAL ***//
    
    // *** INICIO VALIDACAO ITEM CONTABIL INICIAL *** //
    DBSELECTAREA("CTD")
    DBSETORDER(1)
    IF !( MSSEEK(FwxFilial("CTD") + cITIni, .F. ) ) .AND. lRet == .T.
    
    	Help( ,, 'ADCON008P-0007',, "Item Contábil não localizado no cadastro." + Chr(13) + Chr(10) +;
    	                            "Informe um Item Contábil válido."          + Chr(13) + Chr(10) +;
    	                            "Item Contábil: " + cITIni, 1, 0 )
    	                            
    	lRet := .F.                            
    
    ELSE
    
    	DO CASE
    	
			CASE CTD->CTD_CLASSE == "1" .AND. lRet == .T.
			
				Help( ,, 'ADCON008P-0008',, "Item Contábil sintético. Não pode ser utilizado." + Chr(13) + Chr(10) +;
    	                                    "Informe um Item Contábil válido." + Chr(13) + Chr(10) +;
    	                                    "Item Contábil: " + cITIni, 1, 0 )
    	        lRet := .F.
    	                            
			CASE cITIni > cITFim .AND. lRet == .T.
			
				Help( ,, 'ADCON008P-0009',, "Item Contábil inicial não pode ser maior que o final." + Chr(13) + Chr(10) +;
    	                                    "Informe um Item Contábil válido." + Chr(13) + Chr(10) +;
    	                                    "Item Contábil: " + cITIni, 1, 0 )
    	        lRet := .F.
    	        
    	    CASE cITFim < cITIni .AND. lRet == .T.
			
				Help( ,, 'ADCON008P-0010',, "Item Contábil final não pode ser menor que o inicial" + Chr(13) + Chr(10) +;
    	                                    "Informe um Item Contábil válido." + Chr(13) + Chr(10) +;
    	                                    "Item Contábil: " + cITFim, 1, 0 )
    	        lRet := .F.    
    	        
			OTHERWISE
				
		ENDCASE
    
    ENDIF
    
    // *** FINAL VALIDACAO ITEM CONTABIL INICIAL ***//
    
    // *** INICIO VALIDACAO ITEM CONTABIL FINAL *** //
    DBSELECTAREA("CTD")
    DBSETORDER(1)
    IF !( MSSEEK(FwxFilial("CTD") + cITFim, .F. ) ) .AND. lRet == .T.
    
    	Help( ,, 'ADCON008P-0011',, "Item Contábil não localizado no cadastro." + Chr(13) + Chr(10) +;
    	                            "Informe um Item Contábil válido." + Chr(13) + Chr(10) +;
    	                            "Item Contábil: " + cITFim, 1, 0 )
    	                            
    	lRet := .F.
    	
    ELSE
    
    	IF CTD->CTD_CLASSE == "1" .AND. lRet == .T.
			
				Help( ,, 'ADCON008P-0012',, "Item Contábil sintético. Não pode ser utilizado." + Chr(13) + Chr(10) +;
    	                                    "Informe um Item Contábil válido." + Chr(13) + Chr(10) +;
    	                                    "Item Contábil: " + cCCFim, 1, 0 )
    	        lRet := .F.
    	ENDIF
    	
    ENDIF
    
    // *** FINAL VALIDACAO ITEM CONTABIL FINAL ***//
    
    // *** INICIO VALIDACAO GRUPO DE PRODUTO INICIAL *** //
    DBSELECTAREA("SBM")
    DBSETORDER(1)
    IF !( MSSEEK(FwxFilial("SBM") + cGRPIni, .F. ) ) .AND. lRet == .T.
    
    	Help( ,, 'ADCON008P-0007',, "Grupo do Produto não localizado no cadastro." + Chr(13) + Chr(10) +;
    	                            "Informe um Grupo do Produto válido."          + Chr(13) + Chr(10) +;
    	                            "Grupo do Produto: " + cGRPIni, 1, 0 )
    	                            
    	lRet := .F.                            
    
    ELSE
    
    	DO CASE
    	
			CASE cGRPIni > cGRPFim .AND. lRet == .T.
			
				Help( ,, 'ADCON008P-0008',, "Grupo do Produto inicial não pode ser maior que o final." + Chr(13) + Chr(10) +;
    	                                    "Informe um Grupo do Produto válido." + Chr(13) + Chr(10) +;
    	                                    "Grupo do Produto: " + cGRPIni, 1, 0 )
    	        lRet := .F.
    	        
    	    CASE cGRPFim < cGRPIni .AND. lRet == .T.
			
				Help( ,, 'ADCON008P-0009',, "Grupo do Produto final não pode ser menor que o inicial" + Chr(13) + Chr(10) +;
    	                                    "Informe um Grupo do Produto válido." + Chr(13) + Chr(10) +;
    	                                    "Grupo do Produto: " + cGRPFim, 1, 0 )
    	        lRet := .F.    
    	        
			OTHERWISE
				
		ENDCASE
    
    ENDIF
    
    // *** FINAL VALIDACAO GRUPO DE PRODUTO INICIAL ***//
    
    // *** INICIO VALIDACAO GRUPO DE PRODUTO FINAL *** //
    DBSELECTAREA("SBM")
    DBSETORDER(1)
    IF !( MSSEEK(FwxFilial("SBM") + cGRPFim, .F. ) ) .AND. lRet == .T.
    
    	Help( ,, 'ADCON008P-0010',, "Grupo do Produto não localizado no cadastro." + Chr(13) + Chr(10) +;
    	                            "Informe um Grupo do Produto válido."          + Chr(13) + Chr(10) +;
    	                            "Grupo do Produto: " + cGRPFim, 1, 0 )
    	                            
    	lRet := .F.
    	
    ENDIF	
    
    // *** FINAL VALIDACAO GRUPO DE PRODUTO FINAL ***//
    
    RestArea(aArea)
     
Return(lRet)


STATIC FUNCTION DelTabTemporaria()

    DbSelectArea('TRC')
    Dbclosearea('TRC')
    FErase( GetSrvProfString("StartPath", "\undefined") + cArqs + ".DBF" )
    FErase( GetSrvProfString("StartPath", "\undefined") + cInd1 + ".IDX" )
    FErase( GetSrvProfString("StartPath", "\undefined") + cInd2 + ".IDX" )
     
Return (NIL)

Static Function FileTRC()

	Local aStrut   := {}
	Local aAllUser := FWSFALLUSERS() //AllUsers()
	Local nCont    := 0
	Local lLibBlq  := .F.
    
    //Criando a estrutura que terá na tabela
	aAdd(aStrut, {"TMP_CODUSU", "C", 06, 0} )
    aAdd(aStrut, {"TMP_NOME"  , "C", 40, 0} )
     
    // Criar fisicamente o arquivo.
	cArqs := CriaTrab( aStrut, .T. )
	cInd1   := Left( cArqs, 7 ) + "1"
	cInd2   := Left( cArqs, 7 ) + "2"
	
	// Acessar o arquivo e coloca-lo na lista de arquivos abertos.
	dbUseArea( .T., __LocalDriver, cArqs, cAliasTmp, .F., .F. )
	
	// Criar os índices.               
	IndRegua( cAliasTmp, cInd1, "TMP_CODUSU", , , "Criando índices...")
	IndRegua( cAliasTmp, cInd2, "TMP_NOME", , , "Criando índices...")
	
	// Libera os índices.
	dbClearIndex()
	
	// Agrega a lista dos índices da tabela (arquivo).
	dbSetIndex( cInd1 + OrdBagExt() )  
	dbSetIndex( cInd2 + OrdBagExt() )
	
	For nCont :=1 to Len(aAllUser)
	
		TRC->(RecLock("TRC",.T.))
		
			TRC->TMP_CODUSU := aAllUser[nCont][2]
			TRC->TMP_NOME   := aAllUser[nCont][3]
			
		TRC->(MsUnLock())
		
	NEXT nCont
	
Return({cArqs,cInd1})

User Function IniPaeITEM()

	Local aArea      := GetArea()
    Local cItem      := StrTran(Space(TamSX3('PAE_ITEM')[1]), ' ', '0')
    Local oModelPad  := FWModelActive()
    Local oModelGrid := oModelPad:GetModel('PAEDETAIL')
    Local nOperacao  := oModelPad:nOperation
    Local nLinAtu    := oModelGrid:nLine
    Local nPosItem   := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("PAE_ITEM")})

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	IF nLinAtu > 0

		nLinAtu := VAL(oModelGrid:aDataModel[nLinAtu][1][1][4]) //William Costa chamado 056028 data 20/02/2020 

	ENDIF

    //Se for a primeira linha
    IF nLinAtu < 1

        cItem := Soma1(cItem)
     
    //Senão, pega o valor da última linha
	ELSE

		nLinAtu := nLinAtu + 1
		cItem   := STRZERO(nLinAtu,3)
        
    ENDIF
     
    RestArea(aArea)
    
RETURN cItem