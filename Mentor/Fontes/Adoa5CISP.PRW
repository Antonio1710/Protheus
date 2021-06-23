#INCLUDE "PROTHEUS.CH"  
#INCLUDE "AP5MAIL.CH"     
#INCLUDE "rwmake.ch"  
#INCLUDE "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'  

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
//ฑฑบPrograma  ณAdoa5CISP บAutor  ณWILLIAM COSTA       บ Data ณ  06/06/2017 บฑฑ
//ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
//ฑฑบDesc.     ณMostra dados do Webservice da Cisp na tela do PB3.          บฑฑ
//ฑฑบ          ณ                                                            บฑฑ
//ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
//ฑฑบUso       ณ                                                            บฑฑ
//ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

USER FUNCTION Adoa5CISP(cCnpj)
         
    Local aArea   	  := GetArea()  
    Local oBrowse   
    Local cFiltro     := ''         
    Local cFunNamBkp  := FunName()
    Private cCnpjRede := cCnpj
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Mostra dados do Webservice da Cisp na tela do PB3.')
	
	SetFunName("ADOA5CISP")
	
	// Instanciamento da Classe de Browse 
	oBrowse := FWMBrowse():New() 
	 
	// Defini็ใo da tabela do Browse 
	oBrowse:SetAlias('ZB6') 
	 
	// Defini็ใo da legenda 
	oBrowse:AddLegend( "ZB6_DTCONS <> CTOD('  /  /  ')", "RED", "Jแ Consultado"  ) 
	 
	// Defini็ใo de filtro 
	SqlBuscaData(SUBSTR(cCnpj,1,8))
	         
	IF TRB->(!EOF()) 
		
		cFiltro := "ZB6_RAICGC = '" + SUBSTR(cCnpj,1,8) + "'"  + " AND ZB6_DTCONS = '" + TRB->ZB6_DTCONS + "'"
	
	ELSE
	
		cFiltro := "ZB6_RAICGC = '" + SUBSTR(cCnpj,1,8) + "'"
	
	ENDIF
	TRB->(dbCloseArea())
	    
	oBrowse:SetFilterDefault("@"+cFiltro)
	 
	// Titulo da Browse 
	oBrowse:SetDescription('Consulta WebService Cisp') 
	 
	// Opcionalmente pode ser desligado a exibi็ใo dos detalhes 
	//oBrowse:DisableDetails() 
	 
	// Ativa็ใo da Classe 
	oBrowse:Activate() 
	        
	SetFunName("cFunNamBkp")
	RestArea(aArea) 
Return NIL

Static Function ModelDef() 
               
	// Cria a estrutura a ser usada no Modelo de Dados 
	Local oStruZB6 := FWFormStruct( 1, 'ZB6' ) 
	Local oModel // Modelo de dados que serแ construํdo 
	  
	// Cria o objeto do Modelo de Dados 
	oModel := MPFormModel():New( 'ZCISPM' )           
	 
	// Adiciona ao modelo um componente de formulแrio 
	oModel:AddFields( 'ZB6MASTER', /*cOwner*/, oStruZB6 )
	
	oModel:SetPrimaryKey( { "ZB6_FILIAL", "ZB6_DTCONS", "ZB6_RAICGC" } )       
	        
	// Adiciona a descri็ใo do Modelo de Dados 
	oModel:SetDescription( 'Modelo de Consulta WebService Cisp' )
	 
	// Adiciona a descri็ใo do Componente do Modelo de Dados 
	oModel:GetModel( 'ZB6MASTER' ):SetDescription( 'Dados de  Consulta WebService Cisp' )  
      
// Retorna o Modelo de dados 
Return oModel     

Static Function ViewDef()                                                         

	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado 
	Local oModel := FWLoadModel( 'ADOA5CISP' )        
	
	// Cria a estrutura a ser usada na View 
	Local oStruZB6 := FWFormStruct( 2, 'ZB6' ) 
	 
	// Interface de visualiza็ใo construํda 
	Local oView   
	
	// Cria o objeto de View 
	oView := FWFormView():New() 
	 
	// Define qual o Modelo de dados serแ utilizado na View 
	oView:SetModel( oModel ) 
    
	// Adiciona no nosso View um controle do tipo formulแrio  
	// (antiga Enchoice) 
	oView:AddField( 'VIEW_ZB6', oStruZB6, 'ZB6MASTER' ) 
	   
	// Criar um "box" horizontal para receber algum elemento da view 
	oView:CreateHorizontalBox( 'TELA' , 100 ) 
	
	// Relaciona o identificador (ID) da View com o "box" para exibi็ใo 
	oView:SetOwnerView( 'VIEW_ZB6', 'TELA' )  
	
	//Colocando tํtulo do formulแrio
	
	oView:EnableTitleView('VIEW_ZB6', 'Dados do Grupo de Produtos' )  
	
    //For็a o fechamento da janela na confirma็ใo
	
	oView:SetCloseOnOk({||.T.})
	
	//O formulแrio da interface serแ colocado dentro do container
	
	oView:SetOwnerView("VIEW_ZB6","TELA")

// Retorna o objeto de View criado 	
Return oView 

Static Function MenuDef() 

	Local aRotina := {} 
	 
	ADD OPTION aRotina Title 'Visualizar'             Action 'VIEWDEF.ADOA5CISP' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 
	ADD OPTION aRotina Title 'Enviar Socios para PB3' Action 'u_IMPORTSOCIOS()'    OPERATION MODEL_OPERATION_VIEW   ACCESS 0 
    //ADD OPTION aRotina Title 'Incluir'    Action 'VIEWDEF.ADOA5CISP' OPERATION MODEL_OPERATION_INSERT ACCESS 0 
	//ADD OPTION aRotina Title 'Alterar'    Action 'VIEWDEF.ADOA5CISP' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 
	//ADD OPTION aRotina Title 'Excluir'    Action 'VIEWDEF.ADOA5CISP' OPERATION MODEL_OPERATION_DELETE ACCESS 0 

 
Return aRotina 

STATIC FUNCTION SqlBuscaData(cCgc) 

	BeginSQL Alias "TRB"
			%NoPARSER% 
            SELECT MAX(ZB6_DTCONS) AS ZB6_DTCONS 
			  FROM %Table:ZB6%
			WHERE ZB6_RAICGC              = %EXP:cCgc%
			  AND %Table:ZB6%.D_E_L_E_T_ <> '*'
	EndSQl
RETURN(NIL) 

USER FUNCTION IMPORTSOCIOS() 

	Local nCont := 0 
    Local cNmSoc1     := ''
    Local cNmSoc2     := ''
    Local cNmSoc3     := ''
    Local cNmSoc4     := ''
    Local cNmSoc5     := ''
    Local cNmSoc6     := ''
    Local cNmSoc7     := ''
    Local cNmSoc8     := ''
    Local cNmSoc9     := ''
    Local cNmSoc10    := ''
    Local cNmSoc11    := ''

	U_ADINF009P('ADOA5CISP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Mostra dados do Webservice da Cisp na tela do PB3.')

	IF MSGYESNO("Olแ " + cUserName + CHR(10) + CHR(13) + " Deseja Importar os S๓cios da Ficha Cisp para a PB3  " + "? ","ADFIN009P")
	    
        DBSELECTAREA( 'PB3')
		PB3->(DBSETORDER(3))
		IF PB3->(DBSEEK(xFilial('PB3') + SUBSTR(cCnpjRede,1,8)))
		
			WHILE SUBSTR(cCnpjRede,1,8) == SUBSTR(PB3->PB3_CGC,1,8) 
			
				cNmSoc1     := ALLTRIM(Posicione("ZB6",1,xFilial("ZB6")+SUBSTR(cCnpjRede,1,8),"ZB6_NOMSO1"))
			    cNmSoc2     := ALLTRIM(Posicione("ZB6",1,xFilial("ZB6")+SUBSTR(cCnpjRede,1,8),"ZB6_NOMSO2"))
			    cNmSoc3     := ALLTRIM(Posicione("ZB6",1,xFilial("ZB6")+SUBSTR(cCnpjRede,1,8),"ZB6_NOMSO3"))
			    cNmSoc4     := ALLTRIM(Posicione("ZB6",1,xFilial("ZB6")+SUBSTR(cCnpjRede,1,8),"ZB6_NOMSO4"))
			    cNmSoc5     := ALLTRIM(Posicione("ZB6",1,xFilial("ZB6")+SUBSTR(cCnpjRede,1,8),"ZB6_NOMSO5"))
			    cNmSoc6     := ALLTRIM(Posicione("ZB6",1,xFilial("ZB6")+SUBSTR(cCnpjRede,1,8),"ZB6_NOMSO6"))
			    cNmSoc7     := ALLTRIM(Posicione("ZB6",1,xFilial("ZB6")+SUBSTR(cCnpjRede,1,8),"ZB6_NOMSO7"))
			    cNmSoc8     := ALLTRIM(Posicione("ZB6",1,xFilial("ZB6")+SUBSTR(cCnpjRede,1,8),"ZB6_NOMSO8"))
			    cNmSoc9     := ALLTRIM(Posicione("ZB6",1,xFilial("ZB6")+SUBSTR(cCnpjRede,1,8),"ZB6_NOMSO9"))
			    cNmSoc10    := ALLTRIM(Posicione("ZB6",1,xFilial("ZB6")+SUBSTR(cCnpjRede,1,8),"ZB6_NOMS10"))
			    //cNmSoc11    := ALLTRIM(Posicione("ZB6",1,xFilial("ZB6")+SUBSTR(cCnpjRede,1,8),"ZB6_NOMS11"))
			
			    
				//Grava Log
				//1
				IF ALLTRIM(cNmSoc1) <> ''
				
					U_Ado05Log( PB3->PB3_COD, PB3->PB3_LOJA, cUserName, dDataBase, Posicione('SX3', 2, 'PB3_NOMSO1', 'X3_TITULO' ), PB3->PB3_NOMSO1, ALLTRIM(cNmSoc1))
				
				ENDIF  
				
				//2
				IF ALLTRIM(cNmSoc2) <> ''
				
					U_Ado05Log( PB3->PB3_COD, PB3->PB3_LOJA, cUserName, dDataBase, Posicione('SX3', 2, 'PB3_NOMSO2', 'X3_TITULO' ), PB3->PB3_NOMSO2, ALLTRIM(cNmSoc2))
				
				ENDIF  
				
				//3
				IF ALLTRIM(cNmSoc3) <> ''
				
					U_Ado05Log( PB3->PB3_COD, PB3->PB3_LOJA, cUserName, dDataBase, Posicione('SX3', 2, 'PB3_NOMSO3', 'X3_TITULO' ), PB3->PB3_NOMSO3, ALLTRIM(cNmSoc3))
				
				ENDIF  
				
				//4
				IF ALLTRIM(cNmSoc4) <> ''
				
					U_Ado05Log( PB3->PB3_COD, PB3->PB3_LOJA, cUserName, dDataBase, Posicione('SX3', 2, 'PB3_NOMSO4', 'X3_TITULO' ), PB3->PB3_NOMSO4, ALLTRIM(cNmSoc4))
				
				ENDIF  
				
				//5
				IF ALLTRIM(cNmSoc5) <> ''
				
					U_Ado05Log( PB3->PB3_COD, PB3->PB3_LOJA, cUserName, dDataBase, Posicione('SX3', 2, 'PB3_NOMSO5', 'X3_TITULO' ), PB3->PB3_NOMSO5, ALLTRIM(cNmSoc5))
				
				ENDIF  
				
				//6
				IF ALLTRIM(cNmSoc6) <> ''
				
					U_Ado05Log( PB3->PB3_COD, PB3->PB3_LOJA, cUserName, dDataBase, Posicione('SX3', 2, 'PB3_NOMSO6', 'X3_TITULO' ), PB3->PB3_NOMSO6, ALLTRIM(cNmSoc6))
				
				ENDIF  
				
				//7
				IF ALLTRIM(cNmSoc7) <> ''
				
					U_Ado05Log( PB3->PB3_COD, PB3->PB3_LOJA, cUserName, dDataBase, Posicione('SX3', 2, 'PB3_NOMSO7', 'X3_TITULO' ), PB3->PB3_NOMSO7, ALLTRIM(cNmSoc7))
				
				ENDIF  
				
				//8
				IF ALLTRIM(cNmSoc8) <> ''
				
					U_Ado05Log( PB3->PB3_COD, PB3->PB3_LOJA, cUserName, dDataBase, Posicione('SX3', 2, 'PB3_NOMSO8', 'X3_TITULO' ), PB3->PB3_NOMSO8, ALLTRIM(cNmSoc8))
				
				ENDIF  
				
				//9
				IF ALLTRIM(cNmSoc9) <> ''
				
					U_Ado05Log( PB3->PB3_COD, PB3->PB3_LOJA, cUserName, dDataBase, Posicione('SX3', 2, 'PB3_NOMSO9', 'X3_TITULO' ), PB3->PB3_NOMSO9, ALLTRIM(cNmSoc9))
				
				ENDIF  
				
				//10
				IF ALLTRIM(cNmSoc10) <> ''
				
					U_Ado05Log( PB3->PB3_COD, PB3->PB3_LOJA, cUserName, dDataBase, Posicione('SX3', 2, 'PB3_NOMS10', 'X3_TITULO' ), PB3->PB3_NOMS10, ALLTRIM(cNmSoc10))
				
				ENDIF  
				
/*				//11 Everson - 07/03/2018. Chamado 037261.
				IF ALLTRIM(cNmSoc11) <> ''
				
					U_Ado05Log( PB3->PB3_COD, PB3->PB3_LOJA, cUserName, dDataBase, Posicione('SX3', 2, 'PB3_NOMS11', 'X3_TITULO' ), PB3->PB3_NOMS11, ALLTRIM(cNmSoc11))
				
				ENDIF */ 
				
				RECLOCK('PB3',.F.)
				
					PB3->PB3_NOMSO1 := cNmSoc1
					PB3->PB3_NOMSO2 := cNmSoc2
					PB3->PB3_NOMSO3 := cNmSoc3
					PB3->PB3_NOMSO4 := cNmSoc4
					PB3->PB3_NOMSO5 := cNmSoc5
					PB3->PB3_NOMSO6 := cNmSoc6
					PB3->PB3_NOMSO7 := cNmSoc7
					PB3->PB3_NOMSO8 := cNmSoc8
					PB3->PB3_NOMSO9 := cNmSoc9
					PB3->PB3_NOMS10 := cNmSoc10
					//PB3->PB3_NOMS11 := cNmSoc11 Everson - 07/03/2018. Chamado 037261.
					
				PB3->(MSUNLOCK())
				
				PB3->(DBSKIP()) // Avanca o ponteiro do registro no arquivo
			ENDDO	
			
		ENDIF
		
	ELSE
	
	ENDIF
    	

RETURN(NIL)