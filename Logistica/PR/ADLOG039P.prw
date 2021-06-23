#INCLUDE "PROTHEUS.CH"  
#INCLUDE "AP5MAIL.CH"     
#INCLUDE "rwmake.ch"  
#INCLUDE "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'  

//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������
//�������������������������������������������������������������������������ͻ��
//���Programa  �ADLOG039P �Autor  �WILLIAM COSTA       � Data �  06/07/2017 ���
//�������������������������������������������������������������������������͹��
//���Desc.     �Modelo 1 da tabela ZCM - TELA DE PEDAGIO x TIPO VEICULO     ���
//���          �                                                            ���
//�������������������������������������������������������������������������͹��
//���Uso       �                                                            ���
//�������������������������������������������������������������������������ͼ��
//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������

USER FUNCTION ADLOG039P()
         
    Local aArea   	  := GetArea()  
    Local oBrowse   
    Local cFiltro     := ''         
    Local cFunNamBkp  := FunName()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Modelo 1 da tabela ZCM - TELA DE PEDAGIO x TIPO VEICULO')
    
	SetFunName("ADLOG039P")
	
	// Instanciamento da Classe de Browse 
	oBrowse := FWMBrowse():New() 
	 
	// Defini��o da tabela do Browse 
	oBrowse:SetAlias('ZCM') 
	 
	// Defini��o da legenda 
	oBrowse:AddLegend( "ZCM_DTFIN >= DATE()", "GREEN", "PEDAGIO ATIVO"  ) 
	oBrowse:AddLegend( "ZCM_DTFIN  < DATE()", "RED"  , "PEDAGIO INATIVO"  )
	 
	// Titulo da Browse 
	oBrowse:SetDescription('PEDAGIO X TIPO VEICULO') 
	 
	// Opcionalmente pode ser desligado a exibi��o dos detalhes 
	//oBrowse:DisableDetails() 
	 
	// Ativa��o da Classe 
	oBrowse:Activate() 
	        
	SetFunName("cFunNamBkp")
	RestArea(aArea) 
Return NIL

Static Function ModelDef() 
               
	// Cria a estrutura a ser usada no Modelo de Dados 
	Local oStruZCM := FWFormStruct( 1, 'ZCM' ) 
	Local oModel // Modelo de dados que ser� constru�do 
	  
	// Cria o objeto do Modelo de Dados 
	oModel := MPFormModel():New( '_LOG039P' )           
	 
	// Adiciona ao modelo um componente de formul�rio 
	oModel:AddFields( 'ZCMMASTER', /*cOwner*/, oStruZCM )
	
	oModel:SetPrimaryKey( { "ZCM_FILIAL", "ZCM_CODIGO" } )       
	        
	// Adiciona a descri��o do Modelo de Dados 
	oModel:SetDescription( 'Modelo Pedagio X Tipo Veiculo' )
	 
	// Adiciona a descri��o do Componente do Modelo de Dados 
	oModel:GetModel( 'ZCMMASTER' ):SetDescription( 'Dados de  Pedagio X Tipo Veiculo' )  
      
// Retorna o Modelo de dados 
Return oModel     

Static Function ViewDef()                                                         

	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado 
	Local oModel := FWLoadModel( 'ADLOG039P' )        
	
	// Cria a estrutura a ser usada na View 
	Local oStruZCM := FWFormStruct( 2, 'ZCM' ) 
	 
	// Interface de visualiza��o constru�da 
	Local oView   
	
	// Cria o objeto de View 
	oView := FWFormView():New() 
	 
	// Define qual o Modelo de dados ser� utilizado na View 
	oView:SetModel( oModel ) 
    
	// Adiciona no nosso View um controle do tipo formul�rio  
	// (antiga Enchoice) 
	oView:AddField( 'VIEW_ZCM', oStruZCM, 'ZCMMASTER' ) 
	   
	// Criar um "box" horizontal para receber algum elemento da view 
	oView:CreateHorizontalBox( 'TELA' , 100 ) 
	
	// Relaciona o identificador (ID) da View com o "box" para exibi��o 
	oView:SetOwnerView( 'VIEW_ZCM', 'TELA' )  
	
	//Colocando t�tulo do formul�rio
	
	oView:EnableTitleView('VIEW_ZCM', 'Pedagio X Tipo Veiculo' )  
	
    //For�a o fechamento da janela na confirma��o
	
	oView:SetCloseOnOk({||.T.})
	
	//O formul�rio da interface ser� colocado dentro do container
	
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