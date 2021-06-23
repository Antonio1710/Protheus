#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'  
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TOPCONN.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  ADLFV008P � Autor � Fernando Sigoli     � Data �  11/04/17   ���
�������������������������������������������������������������������������͹��
���Descricao � Programa��o de Retirada/Apanha de Aves                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function ADLFV008P()//U_ADLFV008P()

	Local aArea   := GetArea()
	Local oBrowse
	Local cFunBkp := FunName()                                          
	
	Private cCadastro 	:= "Programa��o de Retirada/Apanha de Aves" 	
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa��o de Retirada/Apanha de Aves')
	
	SetFunName("ADLFV008P")
	
	//Inst�nciando FWMBrowse - Somente com dicion�rio de dados
	oBrowse := FWMBrowse():New()
	
	//Setando a tabela de cadastro de programa�ao
	oBrowse:SetAlias("ZFB")
	//Setando a descri��o da rotina
	oBrowse:SetDescription(cCadastro)
	
	//Legendas
	oBrowse:AddLegend( "ZFB->ZFB_STATUS == '1'" , "GREEN",	"Granja Em aberto" )
	oBrowse:AddLegend( "ZFB->ZFB_STATUS == '2'" , "YELLOW",	"Parcialmente Roteirizada"  )
	oBrowse:AddLegend( "ZFB->ZFB_STATUS == '3'" , "RED",	"Granja Roteirizada" )
	oBrowse:AddLegend( "ZFB->ZFB_STATUS == '4'" , "WHITE",	"Granja vazia" )
	
  
	//Ativa a Browse
	oBrowse:Activate()
	
	SetFunName(cFunBkp)
	RestArea(aArea) 
	
Return Nil

                             

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Fernando Sigoli                                              |
 | Data:  28/08/2017                                                   |
 | Desc:  Cria��o do menu MVC                                          |
 *---------------------------------------------------------------------*/

Static Function MenuDef()        

	Local aRot := {}
	
	//Adicionando op��es
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.ADLFV008P' OPERATION MODEL_OPERATION_VIEW      ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Legenda'    ACTION 'U_FV008LEG()'      OPERATION 6                         ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.ADLFV008P' OPERATION MODEL_OPERATION_INSERT    ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.ADLFV008P' OPERATION MODEL_OPERATION_UPDATE	  ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.ADLFV008P' OPERATION MODEL_OPERATION_DELETE    ACCESS 0 //OPERATION 5

Return aRot          

    

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Fernando Sigoli                                              |
 | Data:  28/08/2017                                                   |
 | Desc:  Cria��o do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
Static Function ModelDef()                                   

    //Cria��o do objeto do modelo de dados
	Local oModel := Nil
	//Cria��o da estrutura de dados utilizada na interface
	Local oStZFB := FWFormStruct(1, "ZFB")
	
	//Editando caracter�sticas do dicion�rio
	oStZFB:SetProperty('ZFB_CODIGO',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edi��o
	oStZFB:SetProperty('ZFB_CODIGO',   MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZFB", "ZFB_CODIGO")'))         //Ini Padr�o
	
	//Instanciando o modelo, n�o � recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("DLFV008M",/*bVldPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 

	//Atribuindo formul�rios para o modelo
	oModel:AddFields("FORMZFB",/*cOwner*/,oStZFB)
	
	//Setando a chave prim�ria da rotina
	oModel:SetPrimaryKey({'ZFB_FILIAL','ZFB_CODIGO'})
	

	//Setando a descri��o do formul�rio
	oModel:GetModel("FORMZFB"):SetDescription("Formul�rio do Cadastro "+cCadastro)
	
	//Pode ativar?  
	bBloco := {|oModel| fAlterar(oModel)}
    oModel:SetVldActivate(bBloco)
           
	
Return oModel                                     

      

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Fernando Sigoli                                              |
 | Data:  28/08/2017                                                   |
 | Desc:  Cria��o da vis�o MVC                                         |
 *---------------------------------------------------------------------*/
Static Function ViewDef() 

	Local aStruZFB	:= ZFB->(DbStruct())
	
	//Cria��o do objeto do modelo de dados da Interface
	Local oModel := FWLoadModel("ADLFV008P")
	
	//Cria��o da estrutura de dados utilizada na interface
	Local oStZFB := FWFormStruct(2, "ZFB")
	
	//Criando oView como nulo
	Local oView := Nil           
	
	//Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Atribuindo formul�rios para interface
	oView:AddField("VIEW_ZFB", oStZFB, "FORMZFB")
	
	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)
	
	//For�a o fechamento da janela na confirma��o
	oView:SetCloseOnOk({||.T.})
	
	//O formul�rio da interface ser� colocado dentro do container
	oView:SetOwnerView("VIEW_ZFB","TELA")
	

	//Tratativa para remover campos da visualiza��o
	For nAtual := 1 To Len(aStruZFB)
		cCampoAux := Alltrim(aStruZFB[nAtual][01])
		
		//Se o campo atual n�o estiver nos que forem considerados
		If Alltrim(cCampoAux) $ "ZFB_DTAINC;ZFB_AMARRA;"
			oStZFB:RemoveField(cCampoAux)
		EndIf
	Next
	
	
Return oView
      


//----------========= Fun��o para Alteracao/Exclusao de registro na tabela ZFB . =========---------           

Static Function fAlterar( oModel )

    Local lRet       := .T.
    Local nOperation := oModel:GetOperation() 
    
	If nOperation == MODEL_OPERATION_UPDATE    
 	
 		If ZFB->ZFB_STATUS <> "1" 
 			lRet := .F.
    		oModel:SetErrorMessage('ZFB_CODIGO', '' , '' , '' , "", 'Opera��o n�o permitida. Somente as programa��es em aberto podem ser alteradas', 'Excluir Orden(s) de Carregamento')   
   		EndIf        
    
    EndIf
    
    
    //Se for exclus�o
    If nOperation == MODEL_OPERATION_DELETE
    	
    	If ZFB->ZFB_STATUS <> "1"
	   		lRet := .F.
	    	oModel:SetErrorMessage('ZFB_CODIGO', '' , '' , '' , "", 'Opera��o n�o permitida. Somente as programa��es em aberto podem ser exclu�das', 'Excluir Orden(s) de Carregamento')   
   	
	   	//Solicita confirma��o do usu�rio.	
		ElseIf ! MsgYesNo("Deseja prosseguir com a Exclusao dos dados da programac�o?","Confirma��o")
	
			lRet := .F.
 		 	oModel:SetErrorMessage('ZFB_CODIGO', '' , '' , '' , "", 'Opera��o cancelada', 'Confirmar a opera��o')   
   	
    	Else
	
			DbSelectArea("ZFB")
			DbSetOrder(1)
			RecLock("ZFB",.F.)
			Dbdelete()
			MSUNLOCK()
			
		EndIf
	
		Set filter to  

    EndIf
    
       
Return lRet

//----------========= Fun��o para mostrar a legenda . =========----------
User Function FV008LEG()
	
	Local aLegenda := {}

	U_ADINF009P( 'ADLFV008P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa��o de Retirada/Apanha de Aves')
	
	//Monta as cores
	AADD(aLegenda,{'BR_VERDE'   ,	"Granja Em aberto"  }) 
	AADD(aLegenda,{'BR_AMARELO' ,	"Parcialmente Roteirizada"  }) 
	AADD(aLegenda,{'BR_VERMELHO',	"Granja Roteirizada"})
	AADD(aLegenda,{'BR_BRANCO'  ,	"Granja vazia"      }) 
	           
	
	BrwLegenda("", "Status", aLegenda)
	
Return