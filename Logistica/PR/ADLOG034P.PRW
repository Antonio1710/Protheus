#INCLUDE "PROTHEUS.CH"  
#INCLUDE "AP5MAIL.CH"     
#INCLUDE "rwmake.ch"  
#INCLUDE "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'  

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³ADLOG034P ºAutor  ³WILLIAM COSTA       º Data ³  14/07/2017 º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³Modelo 1 da tabela ZBV Cadastro de Proprietario de Veiculo  º±±
//±±º          ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³                                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

USER FUNCTION ADLOG034P()
         
    Local aArea   	  := GetArea()  
    Local oBrowse   
    Local cFiltro     := ''         
    Local cFunNamBkp  := FunName()   
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Modelo 1 da tabela ZBV Cadastro de Proprietario de Veiculo')
	    
    SetFunName("ADLOG034P")


	// Instanciamento da Classe de Browse 
	oBrowse := FWMBrowse():New() 
	 
	// Definição da tabela do Browse 
	oBrowse:SetAlias('ZBV') 
	 
	// Definição da legenda 
	//oBrowse:AddLegend( "!EMPTY(ZB7_CODDE) .AND. !EMPTY(ZB7_CODPAR)", "RED", "COD EAN AJUSTADO"  ) 
	 
	// Titulo da Browse 
	oBrowse:SetDescription('Cadastro Proprietario Veiculo') 
	 
	// Opcionalmente pode ser desligado a exibição dos detalhes 
	//oBrowse:DisableDetails() 
	 
	// Ativação da Classe 
	oBrowse:Activate() 
	        
	SetFunName("cFunNamBkp")
	RestArea(aArea) 
Return NIL

Static Function ModelDef() 
               
	// Cria a estrutura a ser usada no Modelo de Dados 
	Local oStruZBV := FWFormStruct( 1, 'ZBV' ) 
	Local oModel // Modelo de dados que será construído 
	  
	// Cria o objeto do Modelo de Dados 
	oModel := MPFormModel():New( '_LOG034P' )           
	 
	// Adiciona ao modelo um componente de formulário 
	oModel:AddFields( 'ZBVMASTER', /*cOwner*/, oStruZBV )
	
	oModel:SetPrimaryKey( { "ZBV_FILIAL", "ZBV_COD" } )       
	        
	// Adiciona a descrição do Modelo de Dados 
	oModel:SetDescription( 'Proprietario Veiculo' )
	 
	// Adiciona a descrição do Componente do Modelo de Dados 
	oModel:GetModel( 'ZBVMASTER' ):SetDescription( 'Proprietario Veiculo' )  
      
// Retorna o Modelo de dados 
Return oModel     

Static Function ViewDef()                                                         

	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado 
	Local oModel := FWLoadModel( 'ADLOG034P' )        
	
	// Cria a estrutura a ser usada na View 
	Local oStruZBV := FWFormStruct( 2, 'ZBV' ) 
	 
	// Interface de visualização construída 
	Local oView   
	
	// Cria o objeto de View 
	oView := FWFormView():New() 
	 
	// Define qual o Modelo de dados será utilizado na View 
	oView:SetModel( oModel ) 
    
	// Adiciona no nosso View um controle do tipo formulário  
	// (antiga Enchoice) 
	oView:AddField( 'VIEW_ZBV', oStruZBV, 'ZBVMASTER' ) 
	   
	// Criar um "box" horizontal para receber algum elemento da view 
	oView:CreateHorizontalBox( 'TELA' , 100 ) 
	
	// Relaciona o identificador (ID) da View com o "box" para exibição 
	oView:SetOwnerView( 'VIEW_ZBV', 'TELA' )  
	
	//Colocando título do formulário
	
	oView:EnableTitleView('VIEW_ZBV', 'Dados do Proprietário' )  
	
    //Força o fechamento da janela na confirmação
	
	oView:SetCloseOnOk({||.T.})
	
	//O formulário da interface será colocado dentro do container
	
	oView:SetOwnerView("VIEW_ZBV","TELA")

// Retorna o objeto de View criado 	
Return oView 

Static Function MenuDef() 

	Local aRotina := {}  
	
		ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.ADLOG034P' OPERATION MODEL_OPERATION_INSERT ACCESS 0 
		ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.ADLOG034P' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 
		ADD OPTION aRotina TITLE 'Legenda'    ACTION 'u_LLOG034P'        OPERATION 6                      ACCESS 0 //OPERATION X
		ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.ADLOG034P' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 
   	    ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.ADLOG034P' OPERATION MODEL_OPERATION_DELETE ACCESS 0 
   	    ADD OPTION aRotina TITLE 'Log'        ACTION 'u_CADPROPLOG()'    OPERATION 7                      ACCESS 0 //OPERATION X
   	    
Return aRotina     

USER FUNCTION LLOG034P()

    LOCAL aLegenda := {}

	U_ADINF009P('ADLOG034P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Modelo 1 da tabela ZBV Cadastro de Proprietario de Veiculo')
     
    //Monta as cores
    AADD(aLegenda,{"BR_VERMELHO",   "COD EAN AJUSTADO"})
     
    BrwLegenda("Legenda Proprietario Veiculo", "Legenda", aLegenda) 
    
RETURN(NIL)   

User Function CADPROPLOG()

	Local aArea		:= GetArea()
	Local oDlg
	Local Query     := ""
	Local nx 		:= 0
	Local aSize    	:= MsAdvSize()
	Local aPosObj  	:= {}
	Local aObjects 	:= {}
	Local aInfo		:= {}
	Local aCpos		:= {}
	Local nOpcao	:= 0
	Local aListBox	:= {}
	Local oTik		:= LoadBitMap(GetResources(), 'LBTIK')
	Local oNo		:= LoadBitMap(GetResources(), 'LBNO' )
	Local oMarca	:= LoadBitMap(GetResources(), 's4wb018n.png')
	Local cCampos 	:= ''
	
	Private aTela	[0][0]
	Private aGets	[0]

	U_ADINF009P('ADLOG034P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Modelo 1 da tabela ZBV Cadastro de Proprietario de Veiculo')
	
	//Tamanho da tela
	aObjects := {}
	aAdd( aObjects, { 100,  20, .t., .f. } )
	aAdd( aObjects, { 100,  80, .t., .t. } )
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	
	Query := " SELECT ZBE_DATA,ZBE_HORA,ZBE_USUARI,ZBE_LOG,ZBE_PARAME FROM "+retsqlname("ZBE")+" WHERE ZBE_ROTINA = 'ADLOG034P' and ZBE_PARAME LIKE '%"+ZBV->ZBV_COD+"%' ORDER BY ZBE_DATA DESC, ZBE_HORA DESC "
	TCQUERY Query new alias "LOG1"    
	
	// Adiciona elementos ao Array da ListBox
	LOG1->(dbgotop())
	While !EOF()  
		aAdd( aListBox,{ LOG1->ZBE_USUARI, LOG1->ZBE_DATA, LOG1->ZBE_HORA, LOG1->ZBE_LOG,  })
	DbSkip()
	End  
	
	DbCloseArea("LOG1")
	   
	If Empty( aListBox )
	
		Alert( 'Nenhuma ocorrencia de Log para este Proprietario' )
	
	Else
	
		DEFINE MSDIALOG oDlg TITLE "Histórico/Log" FROM aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL
		
		@ 010,10 Say 'Proprietario: '+Alltrim(ZBV->ZBV_PROPRI) SIZE 200,15 OF oDlg PIXEL
		
		@ aPosObj[2,1],aPosObj[2,2] ListBox oListBox Fields HEADER "Usuario", "Data", "Hora", "LOG/Alteracao";
		Size aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] Of oDlg Pixel ColSizes 50,50,50,70,100
		
		oListBox:SetArray(aListBox)
		
		oListBox:bLine := {|| {	aListBox[oListBox:nAT,01], DTOC(STOD(aListBox[oListBox:nAT,02]))  ,aListBox[oListBox:nAT,03], aListBox[oListBox:nAT,04]}}
		
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcao:=1, If( Obrigatorio( aGets, aTela) ,oDlg:End(),Nil)},{||nOpcao:=0,oDlg:End()},.F.,)
	
	Endif
	
	RestArea( aArea )

RETURN(NIL)