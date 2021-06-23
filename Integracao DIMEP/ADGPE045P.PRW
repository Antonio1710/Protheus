#INCLUDE "PROTHEUS.CH"  
#INCLUDE "AP5MAIL.CH"     
#INCLUDE "rwmake.ch"  
#INCLUDE "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'  

/*/{Protheus.doc} User Function ADGPE045P
	Modelo 1 da tabela ZFG Usuario Protheus X Usuario Dimep
	@type  Function
	@author WILLIAM COSTA
	@since 19/03/2019
	@version 01
	@history TICKET  224 - William Costa - 11/11/2020 - Alteração do Fonte na parte de Funcionários, trocar a integração do Protheus para a Integração do RM
	/*/
USER FUNCTION ADGPE045P()
         
    Local aArea   	  := GetArea()  
    Local oBrowse   
    Local cFiltro     := ''         
    Local cFunNamBkp  := FunName()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Modelo 1 da tabela ZFG Usuario Protheus X Usuario Dimep')
    
	SetFunName("ADGPE045P")
	
	// Instanciamento da Classe de Browse 
	oBrowse := FWMBrowse():New() 
	 
	// Definição da tabela do Browse 
	oBrowse:SetAlias('ZFG') 
	 
	// Definição da legenda 
	//oBrowse:AddLegend( "!EMPTY(ZFG_CODDE) .AND. !EMPTY(ZFG_CODPAR)", "RED", "COD EAN AJUSTADO"  ) 
	    
	// Titulo da Browse 
	oBrowse:SetDescription('Usuario Protheus X Usuario Dimep') 
	 
	// Opcionalmente pode ser desligado a exibição dos detalhes 
	//oBrowse:DisableDetails() 
	 
	// Ativação da Classe 
	oBrowse:Activate() 
	        
	SetFunName("cFunNamBkp")
	RestArea(aArea)
	 
Return NIL

Static Function ModelDef() 
               
	// Cria a estrutura a ser usada no Modelo de Dados 
	Local oStruZFG := FWFormStruct( 1, 'ZFG' ) 
	Local oModel // Modelo de dados que será construído 
	  
	// Cria o objeto do Modelo de Dados 
	oModel := MPFormModel():New( '_GPE047P' )           
	 
	// Adiciona ao modelo um componente de formulário 
	oModel:AddFields( 'ZFGMASTER', /*cOwner*/, oStruZFG )
	
	oModel:SetPrimaryKey( { "ZFG_FILIAL", "ZFG_CODUSR" } )       
	        
	// Adiciona a descrição do Modelo de Dados 
	oModel:SetDescription( 'Modelo Usuario Protheus X Usuario Dimep' )
	 
	// Adiciona a descrição do Componente do Modelo de Dados 
	oModel:GetModel( 'ZFGMASTER' ):SetDescription( 'Usuario Protheus X Usuario Dimep' )  
      
// Retorna o Modelo de dados 
Return oModel     

Static Function ViewDef()                                                         

	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado 
	Local oModel := FWLoadModel( 'ADGPE045P' )        
	
	// Cria a estrutura a ser usada na View 
	Local oStruZFG := FWFormStruct( 2, 'ZFG' ) 
	 
	// Interface de visualização construída 
	Local oView   
	
	// Cria o objeto de View 
	oView := FWFormView():New() 
	 
	// Define qual o Modelo de dados será utilizado na View 
	oView:SetModel( oModel ) 
    
	// Adiciona no nosso View um controle do tipo formulário  
	// (antiga Enchoice) 
	oView:AddField( 'VIEW_ZFG', oStruZFG, 'ZFGMASTER' ) 
	   
	// Criar um "box" horizontal para receber algum elemento da view 
	oView:CreateHorizontalBox( 'TELA' , 100 ) 
	
	// Relaciona o identificador (ID) da View com o "box" para exibição 
	oView:SetOwnerView( 'VIEW_ZFG', 'TELA' )  
	
	//Colocando título do formulário
	
	oView:EnableTitleView('VIEW_ZFG', 'Usuario Protheus X Usuario Dimep' )  
	
    //Força o fechamento da janela na confirmação
	
	oView:SetCloseOnOk({||.T.})
	
	//O formulário da interface será colocado dentro do container
	
	oView:SetOwnerView("VIEW_ZFG","TELA")

// Retorna o objeto de View criado 	
Return oView 

Static Function MenuDef() 

	Local aRotina := {}  
	
		ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.ADGPE045P' OPERATION MODEL_OPERATION_INSERT ACCESS 0
		ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.ADGPE045P' OPERATION MODEL_OPERATION_UPDATE ACCESS 0
		ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.ADGPE045P' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 
		ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.ADGPE045P' OPERATION MODEL_OPERATION_DELETE ACCESS 0 
		 
Return aRotina                           
