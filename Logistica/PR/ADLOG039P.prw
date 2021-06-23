#INCLUDE "PROTHEUS.CH"  
#INCLUDE "AP5MAIL.CH"     
#INCLUDE "rwmake.ch"  
#INCLUDE "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'  

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³ADLOG039P ºAutor  ³WILLIAM COSTA       º Data ³  06/07/2017 º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³Modelo 1 da tabela ZCM - TELA DE PEDAGIO x TIPO VEICULO     º±±
//±±º          ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³                                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

USER FUNCTION ADLOG039P()
         
    Local aArea   	  := GetArea()  
    Local oBrowse   
    Local cFiltro     := ''         
    Local cFunNamBkp  := FunName()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Modelo 1 da tabela ZCM - TELA DE PEDAGIO x TIPO VEICULO')
    
	SetFunName("ADLOG039P")
	
	// Instanciamento da Classe de Browse 
	oBrowse := FWMBrowse():New() 
	 
	// Definição da tabela do Browse 
	oBrowse:SetAlias('ZCM') 
	 
	// Definição da legenda 
	oBrowse:AddLegend( "ZCM_DTFIN >= DATE()", "GREEN", "PEDAGIO ATIVO"  ) 
	oBrowse:AddLegend( "ZCM_DTFIN  < DATE()", "RED"  , "PEDAGIO INATIVO"  )
	 
	// Titulo da Browse 
	oBrowse:SetDescription('PEDAGIO X TIPO VEICULO') 
	 
	// Opcionalmente pode ser desligado a exibição dos detalhes 
	//oBrowse:DisableDetails() 
	 
	// Ativação da Classe 
	oBrowse:Activate() 
	        
	SetFunName("cFunNamBkp")
	RestArea(aArea) 
Return NIL

Static Function ModelDef() 
               
	// Cria a estrutura a ser usada no Modelo de Dados 
	Local oStruZCM := FWFormStruct( 1, 'ZCM' ) 
	Local oModel // Modelo de dados que será construído 
	  
	// Cria o objeto do Modelo de Dados 
	oModel := MPFormModel():New( '_LOG039P' )           
	 
	// Adiciona ao modelo um componente de formulário 
	oModel:AddFields( 'ZCMMASTER', /*cOwner*/, oStruZCM )
	
	oModel:SetPrimaryKey( { "ZCM_FILIAL", "ZCM_CODIGO" } )       
	        
	// Adiciona a descrição do Modelo de Dados 
	oModel:SetDescription( 'Modelo Pedagio X Tipo Veiculo' )
	 
	// Adiciona a descrição do Componente do Modelo de Dados 
	oModel:GetModel( 'ZCMMASTER' ):SetDescription( 'Dados de  Pedagio X Tipo Veiculo' )  
      
// Retorna o Modelo de dados 
Return oModel     

Static Function ViewDef()                                                         

	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado 
	Local oModel := FWLoadModel( 'ADLOG039P' )        
	
	// Cria a estrutura a ser usada na View 
	Local oStruZCM := FWFormStruct( 2, 'ZCM' ) 
	 
	// Interface de visualização construída 
	Local oView   
	
	// Cria o objeto de View 
	oView := FWFormView():New() 
	 
	// Define qual o Modelo de dados será utilizado na View 
	oView:SetModel( oModel ) 
    
	// Adiciona no nosso View um controle do tipo formulário  
	// (antiga Enchoice) 
	oView:AddField( 'VIEW_ZCM', oStruZCM, 'ZCMMASTER' ) 
	   
	// Criar um "box" horizontal para receber algum elemento da view 
	oView:CreateHorizontalBox( 'TELA' , 100 ) 
	
	// Relaciona o identificador (ID) da View com o "box" para exibição 
	oView:SetOwnerView( 'VIEW_ZCM', 'TELA' )  
	
	//Colocando título do formulário
	
	oView:EnableTitleView('VIEW_ZCM', 'Pedagio X Tipo Veiculo' )  
	
    //Força o fechamento da janela na confirmação
	
	oView:SetCloseOnOk({||.T.})
	
	//O formulário da interface será colocado dentro do container
	
	oView:SetOwnerView("VIEW_ZCM","TELA")

// Retorna o objeto de View criado 	
Return oView 

Static Function MenuDef() 

	Local aRotina := {}  
	
		ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.ADLOG039P' OPERATION MODEL_OPERATION_INSERT ACCESS 0
		ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.ADLOG039P' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 
		ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.ADLOG039P' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 
		ADD OPTION aRotina TITLE 'Legenda'    ACTION 'u_LOG039P'         OPERATION 6                      ACCESS 0 //OPERATION X
	
Return aRotina     

USER FUNCTION LOG039P()

    LOCAL aLegenda := {}

	U_ADINF009P('ADLOG039P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Modelo 1 da tabela ZCM - TELA DE PEDAGIO x TIPO VEICULO')
     
    //Monta as cores
    AADD(aLegenda,{"BR_VERDE",   "PEDAGIO ATIVO"})
    AADD(aLegenda,{"BR_VERMELHO","PEDAGIO INATIVO"})
     
    BrwLegenda("Legenda de Pedagio X Tipo Veiculo", "Legenda", aLegenda) 
    
RETURN(NIL)                           