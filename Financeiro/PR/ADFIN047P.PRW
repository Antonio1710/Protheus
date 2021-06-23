#Include "RwMake.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "TOTVS.CH"

// ##########################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : ADFIN47P
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 14/11/17 | Ricardo Lima      | Central de Aprovacao                       | 038609
// ---------+-------------------+--------------------------------------------+---------------
//          |                   |                                            |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################

USER Function ADFIN047P

LOCAL oBrowse
PRIVATE aRotina		:= MenuDef()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Central de Aprovacao')

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZC3")
	oBrowse:SetDescription("Usuario Aprovação Alçadas")
	
	oBrowse:Activate()
	
Return NIL

STATIC Function MenuDef()

	LOCAL aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar"      ACTION "VIEWDEF.ADFIN047P" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"         ACTION "VIEWDEF.ADFIN047P" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"         ACTION "VIEWDEF.ADFIN047P" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"         ACTION "VIEWDEF.ADFIN047P" OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Cad. Tolerancia" ACTION "u_ADFINT47()"      OPERATION 4 ACCESS 0 // Ricardo Lima - 22/03/18

Return aRotina

STATIC Function ModelDef()

	LOCAL oModel
	LOCAL oStruZC3 := FWFormStruct( 1, "ZC3", /*bAvalCampo*/, /*lViewUsado*/ )

	oModel := MPFormModel():New("ModelDef_MVC", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:SetDescription("Usuario Aprovação Alçadas")

	oModel:AddFields("ZC3MASTER", /*cOwner*/, oStruZC3, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	oModel:SetPrimaryKey( {"ZC3_FILIAL" } )

Return oModel

// ##########################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : ADFIN46P
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 14/11/17 | Ricardo Lima      | Central de Aprovacao                       | 038609
// ---------+-------------------+--------------------------------------------+---------------
//          |                   |                                            |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
STATIC Function ViewDef()

	Local oView
	Local oModel	:= ModelDef()
	Local oStruZC3	:= FWFormStruct( 2, "ZC3" )

	oView := FWFormView():New()

	oView:SetModel( oModel )

	oView:AddField("VIEW_ZC3", oStruZC3, "ZC3MASTER" )

	oView:CreateHorizontalBox("TELA" , 100 )

    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk( { || .T. } )
Return oView

// ###############################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : ADBCO046
// ---------+-------------------+-------------------------------------------------+---------------
// Data     | Autor             | Descricao                                       | Chamado
// ---------+-------------------+-------------------------------------------------+---------------
// 13/03/18 | Ricardo Lima      | Configura tolerancia para alteração de titulos  |
// ---------+-------------------+-------------------------------------------------+---------------
// ###############################################################################################

User Function ADFINT47()

    Local oPanel
    Local oNewPag
    Local oStepWiz := nil
    Local oDlg     := nil
    Local oPanelBkg
    
    Private lCheck1 := Space(3-len(GetMv("MV_#TOLCA1"))) + GetMv("MV_#TOLCA1")
    Private lCheck2 := Space(3-len(GetMv("MV_#TOLCA2"))) + GetMv("MV_#TOLCA2")
    Private lCheck3 := Transform( GetMv("MV_#TOLCA3") , "@E 999.99" )
    Private lCheck4 := Transform( GetMv("MV_#TOLCA4") , "@E 999.99" )
	Private lCheck5 := Transform( GetMv("MV_#TOLCA5") , "@E 999.99" )
	Private lCheck6 := Transform( GetMv("MV_#TOLCA6") , "@E 999.99" )     
    Private nPerCust := Space(3-len(GetMv("MV_#PERCUS"))) + GetMv("MV_#PERCUS")

    U_ADINF009P('ADFIN047P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Central de Aprovacao')
 
    DEFINE DIALOG oDlg TITLE 'FWWizardControl' PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP )
    oDlg:nWidth  := 800
    oDlg:nHeight := 620
 
    oPanelBkg := tPanel():New(0,0,"",oDlg,,,,,,300,300)
    oPanelBkg:Align := CONTROL_ALIGN_ALLCLIENT
 
    oStepWiz:= FWWizardControl():New(oPanelBkg)
    oStepWiz:ActiveUISteps()
    
    //----------------------
    oNewPag := oStepWiz:AddStep("1")
    oNewPag:SetStepDescription("Cadastros de Tolerancia")
    oNewPag:SetConstruction({|Panel|cria_pg1( Panel, @lCheck1, @lCheck2, @lCheck3, @lCheck4, @lCheck5, @lCheck6, @nPerCust )})
    oNewPag:SetNextAction({||valida_pg1( @lCheck1, @lCheck2, @lCheck3, @lCheck4, @lCheck5, @lCheck6, @nPerCust )})
    oNewPag:SetCancelAction({||Alert("Cancelou na pagina"), .T., oDlg:End()})
    
	//----------------------
    oNewPag := oStepWiz:AddStep("2", {|Panel|cria_pn3(Panel)})
    oNewPag:SetStepDescription("Conclui Parametrização")
    oNewPag:SetNextAction({|| Processa({|| salva_con() },"Configurando","Aguarde...") , .T. , oDlg:End()})
    oNewPag:SetCancelAction({||Alert("Cancelou na pagina"), .T., oDlg:End()})
    oNewPag:SetCancelWhen({||.F.})
    oStepWiz:Activate()
    
    ACTIVATE DIALOG oDlg CENTER
    oStepWiz:Destroy()
Return

//--------------------------
// Construção da página 1 // Ricardo Lima - 22/03/18
//--------------------------
Static Function cria_pg1( oPanel , lCheck1 , lCheck2 , lCheck3 , lCheck4 , lCheck5 , lCheck6, nPerCust )

    Local oSay1
    Local cCheck1
    Local cCheck2
    Local nCheck3
    Local nCheck4
	Local nCheck5
	Local nCheck6
    Local nCheck7
    
    Local oFont1 := TFont():New('Courier new',,-18,.T.)
    Local oFont2 := TFont():New('Courier new',,-16,.T.)
    Local oFont3 := TFont():New('Courier new',,-12,.T.)
    
    oFont1:Bold := .T.        
    
    oSay1:= TSay():New(10,10,{||'Parametros de Tolerancia de Alçadas Financeira'},oPanel,,oFont1,,,,.T.,,,370,20)    
    oSay1:= TSay():New(30,10,{||'Configure abaixo os Parametros de Tolerancia para Alçadas Financeira.'},oPanel,,oFont2,,,,.T.,,,370,30)     

	oSay1   := TSay():New( 071,05,{||'Dias para Tolerancia de Antecipação de Titulos'},oPanel,,oFont3,,,,.T.,,,200,20) 
	cCheck1 := TGet():New( 071,185,{|u| if( PCount() > 0, lCheck1 := u, lCheck1 ) } ,oPanel,006,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,lCheck1,,,, )

    oSay1   := TSay():New( 083,05,{||'Dias de Tolerancia para Postergar Titulos'},oPanel,,oFont3,,,,.T.,,,200,20) 
	cCheck2 := TGet():New( 083,185,{|u| if( PCount() > 0, lCheck2 := u, lCheck2 ) } ,oPanel,006,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,lCheck2,,,, )

    oSay1   := TSay():New( 095,05,{||'Valor para tolerancia de alteracao de Juros'},oPanel,,oFont3,,,,.T.,,,200,20) 
	nCheck3 := TGet():New( 095,185,{|u| if( PCount() > 0, lCheck3 := u, lCheck3 ) } ,oPanel,006,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,lCheck3,,,, )

    oSay1   := TSay():New( 107,05,{||'Valor para tolerancia de alteracao de Acrescimo'},oPanel,,oFont3,,,,.T.,,,200,20) 
	nCheck4 := TGet():New( 107,185,{|u| if( PCount() > 0, lCheck4 := u, lCheck4 ) } ,oPanel,006,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,lCheck4,,,, )

    oSay1   := TSay():New( 119,05,{||'Valor para tolerancia de alteracao de Desconto'},oPanel,,oFont3,,,,.T.,,,200,20) 
	nCheck5 := TGet():New( 119,185,{|u| if( PCount() > 0, lCheck5 := u, lCheck5 ) } ,oPanel,006,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,lCheck5,,,, )

    oSay1   := TSay():New( 131,05,{||'Valor para tolerancia de alteracao de Decrescimo'},oPanel,,oFont3,,,,.T.,,,200,20) 
	nCheck6 := TGet():New( 131,185,{|u| if( PCount() > 0, lCheck6 := u, lCheck6 ) } ,oPanel,006,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,lCheck6,,,, )

    oSay1   := TSay():New( 161,05,{||'Percentual para Calculo de Custo Financeiro nas Alterações de Alçadas'},oPanel,,oFont3,,,,.T.,,,200,20) 
	nCheck7 := TGet():New( 161,185,{|u| if( PCount() > 0, nPerCust := u, nPerCust ) } ,oPanel,006,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,nPerCust,,,, )

Return

//----------------------------------------
// Validação do botão Próximo da página 1 // Ricardo Lima - 22/03/18
//----------------------------------------
Static Function valida_pg1( lCheck1 , lCheck2 , lCheck3 , lCheck4 , lCheck5 , lCheck6 )

 Local lVldChk := .T.  

 Return lVldChk

//--------------------------
// Construção da página 3 // Ricardo Lima - 22/03/18
//--------------------------
Static Function cria_pn3(oPanel)	
	   
    Local oSay1
    Local oFont1 := TFont():New('Courier new',,-18,.T.)          
    
    oSay1:= TSay():New(20,10,{||'Parametrização Efetuada com Sucesso!'},oPanel,,oFont1,,,,.T.,,,370,20)
    oSay1:= TSay():New(40,10,{||'A partir desse momento passa a valer a Tolerancia nas alterações de Titulos.'},oPanel,,oFont1,,,,.T.,,,370,20)    
 
Return


//----------------------------------------
// Grava Configuração dos parametros // Ricardo Lima - 22/03/18
//----------------------------------------
 Static Function salva_con()

 Local nVar03 := Val(StrTran( lCheck3 ,",","."))
 Local nVar04 := Val(StrTran( lCheck4 ,",","."))
 Local nVar05 := Val(StrTran( lCheck5 ,",","."))
 Local nVar06 := Val(StrTran( lCheck6 ,",","."))

    // grava configuracao
    PutMv( "MV_#TOLCA1" , lCheck1 )
    PutMv( "MV_#TOLCA2" , lCheck2 )
    PutMv( "MV_#TOLCA3" , nVar03 )
    PutMv( "MV_#TOLCA4" , nVar04 )    
    PutMv( "MV_#TOLCA5" , nVar05 )    
    PutMv( "MV_#TOLCA6" , nVar06 )    
    PutMv( "MV_#PERCUS" , nPerCust )

Return( .T. )
