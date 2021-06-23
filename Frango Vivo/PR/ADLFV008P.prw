#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'  
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ADLFV008P º Autor ³ Fernando Sigoli     º Data ³  11/04/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Programação de Retirada/Apanha de Aves                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADLFV008P()//U_ADLFV008P()

	Local aArea   := GetArea()
	Local oBrowse
	Local cFunBkp := FunName()                                          
	
	Private cCadastro 	:= "Programação de Retirada/Apanha de Aves" 	
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves')
	
	SetFunName("ADLFV008P")
	
	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()
	
	//Setando a tabela de cadastro de programaçao
	oBrowse:SetAlias("ZFB")
	//Setando a descrição da rotina
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
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/

Static Function MenuDef()        

	Local aRot := {}
	
	//Adicionando opções
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
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
Static Function ModelDef()                                   

    //Criação do objeto do modelo de dados
	Local oModel := Nil
	//Criação da estrutura de dados utilizada na interface
	Local oStZFB := FWFormStruct(1, "ZFB")
	
	//Editando características do dicionário
	oStZFB:SetProperty('ZFB_CODIGO',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStZFB:SetProperty('ZFB_CODIGO',   MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZFB", "ZFB_CODIGO")'))         //Ini Padrão
	
	//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("DLFV008M",/*bVldPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 

	//Atribuindo formulários para o modelo
	oModel:AddFields("FORMZFB",/*cOwner*/,oStZFB)
	
	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({'ZFB_FILIAL','ZFB_CODIGO'})
	

	//Setando a descrição do formulário
	oModel:GetModel("FORMZFB"):SetDescription("Formulário do Cadastro "+cCadastro)
	
	//Pode ativar?  
	bBloco := {|oModel| fAlterar(oModel)}
    oModel:SetVldActivate(bBloco)
           
	
Return oModel                                     

      

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Fernando Sigoli                                              |
 | Data:  28/08/2017                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/
Static Function ViewDef() 

	Local aStruZFB	:= ZFB->(DbStruct())
	
	//Criação do objeto do modelo de dados da Interface
	Local oModel := FWLoadModel("ADLFV008P")
	
	//Criação da estrutura de dados utilizada na interface
	Local oStZFB := FWFormStruct(2, "ZFB")
	
	//Criando oView como nulo
	Local oView := Nil           
	
	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Atribuindo formulários para interface
	oView:AddField("VIEW_ZFB", oStZFB, "FORMZFB")
	
	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)
	
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})
	
	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_ZFB","TELA")
	

	//Tratativa para remover campos da visualização
	For nAtual := 1 To Len(aStruZFB)
		cCampoAux := Alltrim(aStruZFB[nAtual][01])
		
		//Se o campo atual não estiver nos que forem considerados
		If Alltrim(cCampoAux) $ "ZFB_DTAINC;ZFB_AMARRA;"
			oStZFB:RemoveField(cCampoAux)
		EndIf
	Next
	
	
Return oView
      


//----------========= Função para Alteracao/Exclusao de registro na tabela ZFB . =========---------           

Static Function fAlterar( oModel )

    Local lRet       := .T.
    Local nOperation := oModel:GetOperation() 
    
	If nOperation == MODEL_OPERATION_UPDATE    
 	
 		If ZFB->ZFB_STATUS <> "1" 
 			lRet := .F.
    		oModel:SetErrorMessage('ZFB_CODIGO', '' , '' , '' , "", 'Operação não permitida. Somente as programações em aberto podem ser alteradas', 'Excluir Orden(s) de Carregamento')   
   		EndIf        
    
    EndIf
    
    
    //Se for exclusão
    If nOperation == MODEL_OPERATION_DELETE
    	
    	If ZFB->ZFB_STATUS <> "1"
	   		lRet := .F.
	    	oModel:SetErrorMessage('ZFB_CODIGO', '' , '' , '' , "", 'Operação não permitida. Somente as programações em aberto podem ser excluídas', 'Excluir Orden(s) de Carregamento')   
   	
	   	//Solicita confirmação do usuário.	
		ElseIf ! MsgYesNo("Deseja prosseguir com a Exclusao dos dados da programacão?","Confirmação")
	
			lRet := .F.
 		 	oModel:SetErrorMessage('ZFB_CODIGO', '' , '' , '' , "", 'Operação cancelada', 'Confirmar a operação')   
   	
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

//----------========= Função para mostrar a legenda . =========----------
User Function FV008LEG()
	
	Local aLegenda := {}

	U_ADINF009P( 'ADLFV008P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves')
	
	//Monta as cores
	AADD(aLegenda,{'BR_VERDE'   ,	"Granja Em aberto"  }) 
	AADD(aLegenda,{'BR_AMARELO' ,	"Parcialmente Roteirizada"  }) 
	AADD(aLegenda,{'BR_VERMELHO',	"Granja Roteirizada"})
	AADD(aLegenda,{'BR_BRANCO'  ,	"Granja vazia"      }) 
	           
	
	BrwLegenda("", "Status", aLegenda)
	
Return