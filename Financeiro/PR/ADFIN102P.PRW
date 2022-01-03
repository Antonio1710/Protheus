#Include 'Protheus.ch'
#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FILEIO.CH"

#DEFINE CGETFILE_TYPE GETF_LOCALHARD

/*/{Protheus.doc} User Function ADFIN102P
	PROGRAMA PARA GERAR UM GRUPO DE TITULOS A RECEBER PARA SE REALIZAR A BAIXA INDIVIDUALMENTE.
	Essa funÃ§Ã£o gera a interface inicial pra realizacao dos processos
	@type  Function
	@author ANDRE MENDES
	@since 04/11/2020
	@history Ticket 101   - Andre Mendes - 29/10/2020 - RequisiÃ§Ã£o - Baixa TÃ­tulos DAÃ‡Ã‚O
	@history Ticket 3810  - Andre Mendes - 10/12/2020 - ApÃ³s criar o grupo , informar a quantidade de tÃ­tulos que contÃ©m no grupo e o valor total do grupo
	@history Ticket 3810  - Andre Mendes - 10/12/2021 - Ajustes nos gatilhos e validações de campo, carga dos títulos de abatimentos.
	@history Ticket 18035 - Leonardo P. Monteiro - 27/12/2021 - Ajustes na rotina e cálculo dos abatimentos.
/*/
User Function ADFIN102P()
	Local aCoors := FWGetDialogSize( oMainWnd )
	Local oPanelUp, oFWLayer, oPanelDown, oBrowseUp, oBrowseDown, oRelacSZ4
	Private cCadastro := "Grupos de Baixa"
	//Local oBrowse


	SetKey (VK_F12,{|a,b| AcessaPerg("FIN070",.T.)})

	Define MsDialog oDlg Title 'Titulos a Receber do Grupo' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
// Instanciamento da Classe de Browse

	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlg, .F., .T. )
	

	oFWLayer:AddLine( 'L_01', 30, .F. ) // Cria uma "linha" com 50% da tela
	oFWLayer:AddCollumn( 'C_01', 100, .T., 'L_01' ) // Na "linha" criada eu crio uma coluna com 100% da tamanho dela
	
	oPanelUp := oFWLayer:GetColPanel( 'C_01', 'L_01' ) // Pego o objeto desse pedaï¿½o do container
	
	
	oFWLayer:AddLine( 'L_02', 70, .F. ) // Cria uma "linha" com 50% da tela
	oFWLayer:AddCollumn( 'C_02', 100, .T., 'L_02' )
	
	oPanelDown := oFWLayer:GetColPanel( 'C_02', 'L_02' )
	
	oBrowseUp := FWMBrowse():New()
// Definiï¿½ï¿½o da tabela do Browse
	oBrowseUp:SetOwner( oPanelUp )
	
	oBrowseUp:SetAlias('ZG6')
// Definiï¿½ï¿½o da legenda
	oBrowseUp:SetDescription('Grupos de Baixa')
	oBrowseUp:DisableDetails()
	oBrowseUp:SetMenuDef( 'ADFIN102P' )
	
	oBrowseUp:SetProfileID( '1' )
	
	
	
	oBrowseUp:Activate()
	
	oBrowseDown:= FWMBrowse():New()
	oBrowseDown:SetOwner( oPanelDown )
	oBrowseDown:SetDescription( 'Titulos a Receber do Grupo' )
	
	// exiba nenhum botï¿½o
	
	oBrowseDown:ForceQuitButton()
	oBrowseDown:SetAlias( 'ZG7' )
	oBrowseDown:SetProfileID( '2' )
    /*
	oBrowseDown:AddLegend( "SZ4->Z4_STATUS == 'P'"	, "GREEN"	, "Pendente" )
	oBrowseDown:AddLegend( "SZ4->Z4_STATUS == 'A'"	, "YELLOW" , "Em Andamento" )
	oBrowseDown:AddLegend( "SZ4->Z4_STATUS == 'E'"	, "RED"	, "Encerrada" )
	oBrowseDown:AddLegend( "SZ4->Z4_STATUS == 'C'"	, "BLUE"	, "Cancelada" )
    */
	oBrowseDown:Activate()
	
	
	oRelacSZ4:= FWBrwRelation():New()
	oRelacSZ4:AddRelation( oBrowseUp , oBrowseDown , { 	{ "ZG7_FILIAL"	, "XFILIAL('ZG6')" },;
		{ "ZG7_CODIGO", "ZG6_CODIGO"  		}} )
	oRelacSZ4:Activate()
	
// Definiï¿½ï¿½o de filtro
	//oBrowse:SetFilterDefault( "Z4_USERID == '"+__cUserID+"'" )
// Titulo da Browse
	
// Opcionalmente pode ser desligado a exibiï¿½ï¿½o dos detalhes
//oBrowse:DisableDetails()
// Ativaï¿½ï¿½o da Classe
	Activate MsDialog oDlg Center
Return

/*/{Protheus.doc} Static Function MenuDef
	DefiniÃ§Ã£o do menu de acessos.
	@type  Function
	@author ANDRE MENDES
	@since 04/11/2020
/*/

Static Function MenuDef()
	//Local aRotina := fwmvcmenu("ADFIN102P")
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "Gerar Grupo" 	ACTION "VIEWDEF.ADFIN102P"     									OPERATION 3	ACCESS 0
	ADD OPTION aRotina TITLE "Baixar" 		ACTION "Msaguarde( {|| StaticCall(ADFIN102P,FIN102Bx) } )"     	OPERATION 4	ACCESS 0
	ADD OPTION aRotina TITLE "Cancelar" 	ACTION "Msaguarde( {|| StaticCall(ADFIN102P,FIN102Can) } )"     OPERATION 4	ACCESS 0

	
Return aRotina


/*/{Protheus.doc} Static Function ModelDef
	DefiniÃ§Ã£o do modelo de dados.
	@type  Function
	@author ANDRE MENDES
	@since 04/11/2020
/*/

Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruZG6 := FWFormStruct( 1, 'ZG6' )
	Local oStruZG7 := FWFormStruct( 1, 'ZG7' )
	Local oModel // Modelo de dados que serï¿½ construï¿½do
	Local aRelation := {}
    Local aAux := {}
	Local aMotBx		:= ReadMotBx()
	Local aCombo :={}
	Local nI

	For nI := 1 to Len(aMotBx)
		If substr(aMotBx[nI],34,01) == "A" .or. substr(aMotBx[nI],34,01) =="R"
			AADD( aCombo,substr(aMotBx[nI],01,03) +"="+Alltrim(substr(aMotBx[nI],07,10)))
		EndIf
	next

	
	oStruZG6:SetProperty( 'ZG6_TPBAIX', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'ExistCpo("SX5","ZK"+FwFldGet("ZG6_TPBAIX"))' ) )
	

	oStruZG6:SetProperty('ZG6_MOTBAI', MODEL_FIELD_VALUES,aCombo)

	oStruZG7:SetProperty('ZG7_MOTBAI', MODEL_FIELD_VALUES,aCombo)
	
	oStruZG7:SetProperty( "ZG7_PARCEL"   , MODEL_FIELD_VALID, {|oModelSit, cField, xValue, nLine, xCurrentValue| fieldValidPos(oModelSit, cField, xValue, nLine, xCurrentValue) } )
	oStruZG7:SetProperty( "ZG7_DESCON"   , MODEL_FIELD_VALID, {|oModelSit, cField, xValue, nLine, xCurrentValue| fieldValidPos(oModelSit, cField, xValue, nLine, xCurrentValue) } )
	oStruZG7:SetProperty( "ZG7_MULTA"    , MODEL_FIELD_VALID, {|oModelSit, cField, xValue, nLine, xCurrentValue| fieldValidPos(oModelSit, cField, xValue, nLine, xCurrentValue) } )
	oStruZG7:SetProperty( "ZG7_TXPERM"   , MODEL_FIELD_VALID, {|oModelSit, cField, xValue, nLine, xCurrentValue| fieldValidPos(oModelSit, cField, xValue, nLine, xCurrentValue) } )
	
	/*
   	aAux := FwStruTrigger('ZG7_PARCEL', 'ZG7_CLIENT' ,'SE1->E1_CLIENTE',.f.,,0,)
	oStruZG7:AddTrigger( aAux[1], aAux[2] ,aAux[3] ,aAux[4] )	

    aAux := FwStruTrigger('ZG7_PARCEL', 'ZG7_LOJA' ,'SE1->E1_LOJA',.f.,,0,)
	oStruZG7:AddTrigger( aAux[1], aAux[2] ,aAux[3] ,aAux[4] )	

    aAux := FwStruTrigger('ZG7_PARCEL', 'ZG7_DESCRI' ,'Posicione("SA1",1,xFilial("SA1")+ZG7->(ZG7_CLIENT+ZG7_LOJA),"A1_NOME")',.f.,,0,)
	oStruZG7:AddTrigger( aAux[1], aAux[2] ,aAux[3] ,aAux[4] )	

    aAux := FwStruTrigger('ZG7_PARCEL', 'ZG7_NATURE' ,'SE1->E1_NATUREZ',.f.,,0,)
	oStruZG7:AddTrigger( aAux[1], aAux[2] ,aAux[3] ,aAux[4] )

    aAux := FwStruTrigger('ZG7_PARCEL', 'ZG7_EMISSA' ,'SE1->E1_EMISSAO',.f.,,0,)
	oStruZG7:AddTrigger( aAux[1], aAux[2] ,aAux[3] ,aAux[4] )

    aAux := FwStruTrigger('ZG7_PARCEL', 'ZG7_VENCRE' ,'SE1->E1_VENCREA',.f.,,0,)
	oStruZG7:AddTrigger( aAux[1], aAux[2] ,aAux[3] ,aAux[4] )

    aAux := FwStruTrigger('ZG7_PARCEL', 'ZG7_DTREC' ,'ddatabase',.f.,,0,)
	oStruZG7:AddTrigger( aAux[1], aAux[2] ,aAux[3] ,aAux[4] )

    aAux := FwStruTrigger('ZG7_PARCEL', 'ZG7_DTCRED' ,'ddatabase',.f.,,0,)
	oStruZG7:AddTrigger( aAux[1], aAux[2] ,aAux[3] ,aAux[4] )

    aAux := FwStruTrigger('ZG7_PARCEL', 'ZG7_HISTBA' ,'"VALOR RECEBIDO S/ TITULO"',.f.,,0,)
	oStruZG7:AddTrigger( aAux[1], aAux[2] ,aAux[3] ,aAux[4] )

    aAux := FwStruTrigger('ZG7_PARCEL', 'ZG7_VALORI' ,'SE1->E1_VALOR',.f.,,0,)
	oStruZG7:AddTrigger( aAux[1], aAux[2] ,aAux[3] ,aAux[4] )

    aAux := FwStruTrigger('ZG7_PARCEL', 'ZG7_VALLIQ' ,'FwFldGet("ZG7_VALORI")-FwFldGet("ZG7_ABATI")-FwFldGet("ZG7_IMPOST")',.f.,,0,)
	oStruZG7:AddTrigger( aAux[1], aAux[2] ,aAux[3] ,aAux[4] )

    aAux := FwStruTrigger('ZG7_PARCEL', 'ZG7_VLREC' ,'SE1->E1_SALDO',.f.,,0,)
	oStruZG7:AddTrigger( aAux[1], aAux[2] ,aAux[3] ,aAux[4] )

    aAux := FwStruTrigger('ZG7_DESCON', 'ZG7_VLREC' ,'Posicione("SE1",1,xFilial("SE1")+FwFldGet("ZG7_PREFIX")+FwFldGet("ZG7_NUMERO")+FwFldGet("ZG7_PARCEL")+FwFldGet("ZG7_TIPO"),"E1_SALDO") - FwFldGet("ZG7_DESCON")+FwFldGet("ZG7_MULTA")+FwFldGet("ZG7_TXPERM")',.f.,,0,)
	oStruZG7:AddTrigger( aAux[1], aAux[2] ,aAux[3] ,aAux[4] )

    aAux := FwStruTrigger('ZG7_MULTA', 'ZG7_VLREC' ,'Posicione("SE1",1,xFilial("SE1")+FwFldGet("ZG7_PREFIX")+FwFldGet("ZG7_NUMERO")+FwFldGet("ZG7_PARCEL")+FwFldGet("ZG7_TIPO"),"E1_SALDO") - FwFldGet("ZG7_DESCON")+FwFldGet("ZG7_MULTA")+FwFldGet("ZG7_TXPERM")',.f.,,0,)
	oStruZG7:AddTrigger( aAux[1], aAux[2] ,aAux[3] ,aAux[4] )

    aAux := FwStruTrigger('ZG7_TXPERM', 'ZG7_VLREC' ,'Posicione("SE1",1,xFilial("SE1")+FwFldGet("ZG7_PREFIX")+FwFldGet("ZG7_NUMERO")+FwFldGet("ZG7_PARCEL")+FwFldGet("ZG7_TIPO"),"E1_SALDO") - FwFldGet("ZG7_DESCON")+FwFldGet("ZG7_MULTA")+FwFldGet("ZG7_TXPERM")',.f.,,0,)
	oStruZG7:AddTrigger( aAux[1], aAux[2] ,aAux[3] ,aAux[4] )
	*/
	
// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('MOD_02' )
// Adiciona ao modelo um componente de formulï¿½rio
	oModel:AddFields( 'ENT_01_ZG6', /*cOwner*/, oStruZG6)
	// Adiciona ao modelo uma componente de grid
	oModel:AddGrid( 'ENT_02_ZG7', 'ENT_01_ZG6', oStruZG7 )
	//Definindo a chave primï¿½ria
	oModel:SetPrimaryKey( { "ZG6_FILIAL", "ZG6_CODIGO" } )
	
	oStruZG7:SetProperty( 'ZG7_CODIGO' , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"FwFldGet('ZG6_CODIGO')" ))

	oModel:GetModel( 'ENT_02_ZG7' ):SetOptional( .T. )
	
	// Faz relacionamento entre os componentes do model
	aRelation := { 	{'ZG7_FILIAL'	, 'xFilial("ZG7")'},;
		{'ZG7_CODIGO'		, 'ZG7_CODIGO'}}
	oModel:SetRelation( 'ENT_02_ZG7', aRelation, ZG7->( IndexKey( 1 ) ) )
	
	
	oModel:SetDescription( 'Modelo de dados para grupos de baixa' )
// Adiciona a descriï¿½ï¿½o do Componente do Modelo de Dados
	oModel:GetModel( 'ENT_01_ZG6' ):SetDescription( 'grupo de baixa' )
	oModel:GetModel( 'ENT_02_ZG7' ):SetDescription( 'item de grupo de baixa' )
// Retorna o Modelo de dados
Return oModel


/*/{Protheus.doc} Static Function ViewDef
	DefiniÃ§Ã£o da interface visual dos dados.
	@type  Function
	@author ANDRE MENDES
	@since 04/11/2020
/*/

Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel( 'ADFIN102P' )
// Cria a estrutura a ser usada na View
	Local oStruZG6 := FWFormStruct( 2, 'ZG6' )
	Local oStruZG7 := FWFormStruct( 2, 'ZG7' )
// Interface de visualizaï¿½ï¿½o construï¿½da
	Local oView
	Local aMotBx		:= ReadMotBx()
	Local aCombo :={}
	Local nI

	Set Key VK_F4 To fF4()
	Set Key VK_F5 To fF5()
	Set Key VK_F6 To fF6()

	For nI := 1 to Len(aMotBx)
		If substr(aMotBx[nI],34,01) == "A" .or. substr(aMotBx[nI],34,01) =="R"
			AADD( aCombo,substr(aMotBx[nI],01,03) +"="+Alltrim(substr(aMotBx[nI],07,10)))
		EndIf
	next
	
	//Local oCalend
	//Local oBrowse
	//Local oMsWorkTime


	oStruZG6:SetProperty( "ZG6_MOTBAI", MVC_VIEW_COMBOBOX, aCombo )
	oStruZG7:SetProperty( "ZG7_MOTBAI", MVC_VIEW_COMBOBOX, aCombo )

	oStruZG6:SetProperty( "ZG6_TPBAIX" , MVC_VIEW_LOOKUP    , "ZK")
	
	oStruZG7:SetProperty( 'ZG7_CODIGO' , MVC_VIEW_CANCHANGE, .F.)
	oStruZG7:SetProperty( 'ZG7_ITEM' , MVC_VIEW_CANCHANGE, .F.)
	
	
// Cria o objeto de View
	oView := FWFormView():New()
// Define qual o Modelo de dados serï¿½ utilizado na View
	oView:SetModel( oModel )
// Adiciona no nosso View um controle do tipo formulï¿½rio
// (antiga Enchoice)
	oView:AddField( 'VIEW_01_ZG6', oStruZG6, 'ENT_01_ZG6' )
//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddGrid( 'VIEW_02_ZG7', oStruZG7, 'ENT_02_ZG7' )
	oView:AddIncrementField( 'VIEW_02_ZG7', 'ZG7_ITEM' )
	oView:EnableTitleView('VIEW_01_ZG6')
	oView:EnableTitleView('VIEW_02_ZG7')
	
	oView:SetViewProperty( 'VIEW_02_ZG7', "ENABLEDGRIDDETAIL", { 60 } )
	/*
	oView:CreateFolder( 'PA_01' )
	
	oView:AddSheet( 'PA_01', 'AB_01', 'Principal' )
	oView:AddSheet( 'PA_01', 'AB_02', 'Itens' )
	*/
	
// Cria um "box" horizontal para receber cada elemento da view
	//oView:CreateHorizontalBox( 'HB_01', 100,,, 'PA_01', 'AB_01' )
	//oView:CreateHorizontalBox( 'HB_02', 100,,, 'PA_01', 'AB_02' )
	/*
	oView:CreateVerticalBox( 'VB_01', 60)
	oView:CreateVerticalBox( 'VB_02', 40)
	*/
	
	oView:CreateHorizontalBox( 'HB_01', 30)
	oView:CreateHorizontalBox( 'HB_02', 70)
	
	/*
	oView:CreateVerticalBox( 'VB_01', 65,,, 'PA_01', 'AB_01' )
	oView:CreateVerticalBox( 'VB_02', 35,,, 'PA_01', 'AB_01' )
	*/
	//oView:AddOtherObject("OO_01", {|oPanel| fPrinc(oPanel, oModel, @oCalend, @oBrowse, @oMsWorkTime)})
// Relaciona o identificador (ID) da View com o "box" para exibiï¿½ï¿½o
	//oView:SetOwnerView("OO_01",'VB_02')
	oView:SetOwnerView( 'VIEW_01_ZG6', 'HB_01' )
	oView:SetOwnerView( 'VIEW_02_ZG7', 'HB_02' )

// Retorna o objeto de View criado
Return oView

/*/{Protheus.doc} Static Function FIN102Grp
	Utilizada para que usuario possa filtrar e gerar o grupo de tÃ­tulos utilizados para baixa.
	@type  Function
	@author ANDRE MENDES
	@since 04/11/2020
/*/

Static Function FIN102Grp()
	Local aTitulos := {}
	Local cTipo := FwFldGet('ZG6_TPBAIX')
	Local lRet 

    
	aTitulos := FIN102Qry(cTipo)
	
	If Len(aTitulos) >0 

		Processa( {|lEnd| lRet := FIN102Add(aTitulos) },; 
						OemToAnsi("Grupo de titulos a receber."),; 
						OemToAnsi("Adicionando os titulos..."),; 
						.F. )
	Endif

Return .t.

Static Function FIN102Csv()
	Local aTitulos 	:= {}
	Local cTipo 	:= FwFldGet('ZG6_TPBAIX')
	Local lRet 

	aTitulos := FIN102Exc(cTipo)
	
	If Len(aTitulos) >0 

		Processa( {|lEnd| lRet := FIN102Add(aTitulos) },; 
						OemToAnsi("Grupo de titulos a receber."),; 
						OemToAnsi("Adicionando os titulos..."),; 
						.F. )
	Endif

Return .t.

/*/{Protheus.doc} Static Function FIN102Bx
	Realiza a baixa de um grupo de tÃ­tulos, individualmente
	@type  Function
	@author ANDRE MENDES
	@since 04/11/2020
/*/

Static Function FIN102Bx()

	Local aArea		:= GetArea()
	Local aAreaZG6 	:= ZG6->(GetArea())
	Local aAreaZG7 	:= ZG7->(GetArea())
	Local aAreaSE1 	:= SE1->(GetArea())
	Local cCodigo 	:= ZG6->ZG6_CODIGO
	Local cPrefixo
	Local cNum
	Local cParcela
	Local cTipo
	Local aVetor
	Local nItem
	Local cAlerta	:= ""
	Local lRet		:= .F.

	AcessaPerg("FIN070",.T.)

	nItem := 0

	dbEval( {|x| nItem++ },, {|| ZG7->(ZG7_FILIAL+ZG7_CODIGO) == (xFilial("ZG7")+cCodigo) } )
	
	If ZG7->(DbSeek(xFilial("ZG7")+cCodigo))
		
		ProcRegua(nItem)
		While !ZG7->(Eof()) .and. ZG7->(ZG7_FILIAL+ZG7_CODIGO) == (xFilial("ZG7")+cCodigo)
			cPrefixo 	:= ZG7->ZG7_PREFIX
			cNum		:= ZG7->ZG7_NUMERO
			cParcela	:= ZG7->ZG7_PARCEL
			cTipo		:= ZG7->ZG7_TIPO
			cMotivo		:= ZG7->ZG7_MOTBAI
			dRec		:= ZG7->ZG7_DTREC
			dCred		:= ZG7->ZG7_DTCRED
			cHist		:= ZG7->ZG7_HISTBA
			cBanco		:= ZG7->ZG7_BANCO
			cAgencia	:= ZG7->ZG7_AGENCI
			cConta		:= ZG7->ZG7_CONTA
			nDesconto	:= ZG7->ZG7_DESCON
			nMulta		:= ZG7->ZG7_MULTA
			nJurosMora	:= ZG7->ZG7_TXPERM
			nRecebido	:= ZG7->ZG7_VLREC

			SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			If SE1->(DbSeek(xFilial("SE1")+cPrefixo+cNum+cParcela+cTipo))

				aVetor := {	{"E1_PREFIXO"	,cPrefixo   	,Nil},;
							{"E1_NUM"		,cNum    		,Nil},;
							{"E1_PARCELA"	,cParcela    	,Nil},;
							{"E1_TIPO"	    ,cTipo      	,Nil},;
							{"AUTMOTBX"	    ,cMotivo        ,Nil},;
							{"AUTDTBAIXA"	,dRec         	,Nil},;
							{"AUTDTCREDITO" ,dCred         	,Nil},;
							{"AUTHIST"	    ,cHist 			,Nil},;  //## "Baixa Aut.Rotina Quitacao" ##
							{"AUTBANCO"		,cBanco     	,Nil},;
							{"AUTAGENCIA"	,cAgencia		,Nil},;
							{"AUTCONTA"		,cConta      	,Nil},;
							{"AUTDESCONT"	,nDesconto      ,Nil,.T.},;
							{"AUTMULTA"		,nMulta         ,Nil,.T.},;
							{"AUTJUROS"		,nJurosMora     ,Nil,.T.},;
							{"AUTVALREC"	,nRecebido      ,Nil}}

				lMsErroAuto = .F.

				MSExecAuto({|x,y| fina070(x,y)},aVetor,3)

				If lMsErroAuto  //## "Erro ao Baixar parcela no Contas a Receber! (Pref/Num/Parc: " ##
					cAlerta += +Chr(13)+Chr(10)+" - " + Alltrim(SE1->E1_PREFIXO) + "/" + Alltrim(SE1->E1_NUM) + "/" + Alltrim(SE1->E1_PARCELA)
					//Alert("Erro ao Baixar parcela no Contas a Receber! (Pref/Num/Parc: " + SE1->E1_PREFIXO + "/" + SE1->E1_NUM + "/" + SE1->E1_PARCELA + ")")
					//MostraErro()
				else
					lRet := .T.
				EndIf

			Endif
			IncProc( "Processando Baixa Titulo (Pref/Num/Parc: " + SE1->E1_PREFIXO + "/" + SE1->E1_NUM + "/" + SE1->E1_PARCELA + ")" )
			ZG7->(DbSkip())
		End

	Endif
	
	if lRet
		DbSelectarea("ZG6")
		ZG6->(Dbsetorder(1))
		ZG6->(Dbseek(xFilial("ZG6")+cCodigo))
		RecLock("ZG6", .f.)

		ZG6->ZG6_DTPROC := ddatabase
		ZG6->ZG6_HRPROC := StrTran(Left(Time(),5),":","")

		ZG6->(MSUnlock())
	endif

	RestArea(aArea)
	ZG6->(RestArea(aAreaZG6))
	ZG7->(RestArea(aAreaZG7))
	SE1->(RestArea(aAreaSE1))

	if !Empty(cAlerta)
		MsgAlert("Houve erro na baixa dos seguintes títulos:"+Chr(13)+chr(10)+cAlerta, "..:: Inconsistências ::..")
	endif

Return 

/*/{Protheus.doc} Static Function FIN102Bx
	Realiza o estorno de um grupo de baixas, individualmente
	@type  Function
	@author ANDRE MENDES
	@since 04/11/2020
/*/

Static Function FIN102Can()
	Local aArea		:= GetArea()
	Local aAreaZG6 	:= ZG6->(GetArea())
	Local aAreaZG7 	:= ZG7->(GetArea())
	Local aAreaSE1 	:= SE1->(GetArea())
	Local cCodigo 	:= ZG6->ZG6_CODIGO
	Local lRet		:= .F.
	Local cPrefixo
	Local cNum
	Local cParcela
	Local cTipo
	Local aVetor
	Local nItem

	AcessaPerg("FIN070",.T.)

	nItem := 0

	dbEval( {|x| nItem++ },, {|| ZG7->(ZG7_FILIAL+ZG7_CODIGO) == (xFilial("ZG7")+cCodigo) } )

	If ZG7->(DbSeek(xFilial("ZG7")+cCodigo))
		ProcRegua(nItem)
		While !ZG7->(Eof()) .and. ZG7->(ZG7_FILIAL+ZG7_CODIGO) == (xFilial("ZG7")+cCodigo)
			cPrefixo 	:= ZG7->ZG7_PREFIX
			cNum		:= ZG7->ZG7_NUMERO
			cParcela	:= ZG7->ZG7_PARCEL
			cTipo		:= ZG7->ZG7_TIPO
		

			SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			If SE1->(DbSeek(xFilial("SE1")+cPrefixo+cNum+cParcela+cTipo))

				aVetor := {	{"E1_PREFIXO"	,cPrefixo   	,Nil},;
							{"E1_NUM"		,cNum    		,Nil},;
							{"E1_PARCELA"	,cParcela    	,Nil},;
							{"E1_TIPO"	    ,cTipo      	,Nil}}
						

				lMsErroAuto = .F.

				MSExecAuto({|x,y| fina070(x,y)},aVetor,5)

				If lMsErroAuto  //## "Erro ao Baixar parcela no Contas a Receber! (Pref/Num/Parc: " ##
					Alert("Erro ao cancelar parcela no Contas a Receber! (Pref/Num/Parc: " + SE1->E1_PREFIXO + "/" + SE1->E1_NUM + "/" + SE1->E1_PARCELA + ")")
					MostraErro()
				else
					lRet := .T.
				EndIf

			Endif
			IncProc( "Processando Cancelamento da Baixa Titulo (Pref/Num/Parc: " + SE1->E1_PREFIXO + "/" + SE1->E1_NUM + "/" + SE1->E1_PARCELA + ")" )
			ZG7->(DbSkip())
		End

	Endif

	if lRet
		DbSelectarea("ZG6")
		ZG6->(Dbsetorder(1))
		ZG6->(Dbseek(xFilial("ZG6")+cCodigo))
		RecLock("ZG6", .f.)
	
		ZG6->ZG6_DTPROC := Criavar("ZG6_DTPROC")
		ZG6->ZG6_HRPROC := Criavar("ZG6_HRPROC")

		ZG6->(MSUnlock())
	endif

	RestArea(aArea)
	ZG6->(RestArea(aAreaZG6))
	ZG7->(RestArea(aAreaZG7))
	SE1->(RestArea(aAreaSE1))

Return 


/*/{Protheus.doc} Static Function FIN102Qry
	Executa a query de acordo com o tipo de selecao de titulos. Retorna um array com os titulos selecionados.
	@type  Function
	@author ANDRE MENDES
	@since 04/11/2020
/*/
Static Function FIN102Qry(cTipo)
	Local aRet := {}
	Local aArea := GetArea()
	Local cAlias := GetNextAlias()
	Local cQuery := ""


	pergunte("ADFIN102P",.t.)

	Do Case 
        Case cTipo == "01"

			cQuery := "SELECT " + CRLF
			cQuery += "		E1_PREFIXO, " + CRLF
			cQuery += "		E1_NUM, " + CRLF
			cQuery += "		E1_PARCELA, " + CRLF
			cQuery += "		E1_TIPO, " + CRLF
			cQuery += "		SE1.R_E_C_N_O_ AS RECNO " + CRLF
			cQuery += "FROM " + CRLF
			cQuery += "	"+RetSqlName("SE1")+"	SE1			INNER JOIN " + CRLF
			cQuery += "	"+RetSqlName("SA1")+"	SA1	ON " + CRLF
			cQuery += "			SA1.A1_COD	= SE1.E1_CLIENTE		AND " + CRLF
			cQuery += "			SA1.A1_LOJA	= SE1.E1_LOJA " + CRLF
			cQuery += "WHERE " + CRLF
			cQuery += "	SE1.D_E_L_E_T_ = '' " + CRLF
			cQuery += "AND	SE1.E1_SALDO >0 " + CRLF
			cQuery += "AND SA1.A1_PESSOA  = 'F' " + CRLF
			cQuery += "AND SE1.E1_VENCREA BETWEEN '"+DtoS(MV_PAR09)+"' AND '"+DtoS(MV_PAR10)+"' " + CRLF
			cQuery += "AND SE1.E1_FILIAL	= '"+xFilial("SE1")+"' "

		Case cTipo == "02"

			cQuery := "SELECT " + CRLF
			cQuery += "		E1_PREFIXO, " + CRLF
			cQuery += "		E1_NUM, " + CRLF
			cQuery += "		E1_PARCELA, " + CRLF
			cQuery += "		E1_TIPO, " + CRLF
			cQuery += "		SE1.R_E_C_N_O_ AS RECNO " + CRLF
			cQuery += "FROM " + CRLF
			cQuery += "	SE1010	SE1			INNER JOIN " + CRLF
			cQuery += "	SA1010	SA1	ON " + CRLF
			cQuery += "			SA1.A1_COD	= SE1.E1_CLIENTE		AND " + CRLF
			cQuery += "			SA1.A1_LOJA	= SE1.E1_LOJA " + CRLF
			cQuery += "WHERE " + CRLF
			cQuery += "	SE1.D_E_L_E_T_ = '' " + CRLF
			cQuery += "AND	SE1.E1_SALDO >0 " + CRLF
			If mv_par40 == 2
				cQuery += " AND SE1.E1_VENCTO BETWEEN '" + DTOS(mv_par09)  + "' AND '" + DTOS(mv_par10) + "' " + CRLF
			Else
				cQuery += " AND SE1.E1_VENCREA BETWEEN '" + DTOS(mv_par09)  + "' AND '" + DTOS(mv_par10) + "' " + CRLF
			EndIf
			cQuery += "AND SE1.E1_FILIAL	= '"+xFilial("SE1")+"' " + CRLF
			cQuery += "AND SE1.E1_CLIENTE + SE1.E1_LOJA BETWEEN '" + mv_par01 + mv_par24 + "' AND '" + mv_par02 + mv_par25 + "' " + CRLF
			cQuery += "AND SE1.E1_PREFIXO BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' " + CRLF
			cQuery += "AND SE1.E1_NUM BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' " + CRLF
			cQuery += "AND SE1.E1_PORTADO BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' " + CRLF
			cQuery += "AND SE1.E1_NATUREZ BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' " + CRLF
			cQuery += "AND SE1.E1_EMISSAO BETWEEN '" + DTOS(mv_par13)  + "' AND '" + DTOS(mv_par14)  + "' " + CRLF
			cQuery += "AND SE1.E1_TIPO	<> 'PR' " + CRLF
			cQuery += "AND SE1.E1_EMIS1 BETWEEN '"+ DTOS(mv_par27) + "' AND '" + DTOS(mv_par28) + "' " + CRLF
			cQuery += "AND SA1.A1_CODRED BETWEEN '"+ mv_par44 + "' AND '" + mv_par45 + "' " + CRLF
			If !Empty(mv_par31)
				cQuery += "AND SE1.E1_TIPO IN " + FormatIn( mv_par31, ";" ) +" " + CRLF
			EndIf
			If !Empty(MV_PAR32)
				cQuery += " AND SE1.E1_TIPO NOT IN " + FormatIn( MV_PAR32, ";" ) +" " + CRLF
			EndIf
			cQuery += " AND SE1.E1_TIPO NOT IN " + FormatIn(MVABATIM,"|")

			

        OtherWise

        
    EndCase

	If !Empty(cQuery)
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

		DbSelectArea(cAlias)
		While !Eof()

			aAdd(aRet, {E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,RECNO})	

			dbSkip()
		End
	Endif
	DbCloseArea()

	RestArea(aArea)

return aRet


/*/{Protheus.doc} Static Function FIN102Qry
	Executa a query de acordo com o tipo de selecao de titulos. Retorna um array com os titulos selecionados.
	@type  Function
	@author ANDRE MENDES
	@since 04/11/2020
/*/
Static Function FIN102Exc(cTipo)
	Local aArea 		:= GetArea()
	Private aRet		:= {}
	Private Arquivo 	:= Space(40)
	Private lExec		:= .T.
	Private lMsErroAuto	:= .F.
	Private lContinua	:= .T.

	@ 200, 001 To 377, 380 Dialog oLeTxt Title OemToAnsi("Conversão de Lançamentos")
	@ 002, 004 To 040, 187 Title OemToAnsi("Comentário : ")
	//
	@ 009, 020 Say "Este programa tem como objetivo fazer a importação de um  "
	@ 019, 020 Say "arquivo texto, gerado em Planilha Excel (extensão .csv),  "
	@ 029, 020 Say "contendo os títulos a receber que serão baixados."
	//
	@ 044, 004 To 060, 187
	@ 049, 010 Say "Arquivo : "
	@ 065, 004 To 085, 187 Title OemToAnsi("Opções : ")
	//
	@ 70, 065 BmpButton Type 14 Action SelecArq()
	@ 70, 105 BmpButton Type 01 Action Close(oLeTxt)
	@ 70, 145 BmpButton Type 02 Action (lExec := .F.,Close(oLeTxt))
	//
	Activate Dialog oLeTxt Centered
	//
	If !lExec
	return(.t.)
	Endif
	If MsgBox("Confirma a Importação da Planilha?", "Atenção !!!", "YESNO")
		Processa({|| Converte()}, "Conversão das Movimentações (.csv)")
	Endif
	RestArea(aArea)
Return (aRet)

//========================
Static Function SelecArq()
//========================
cDirIni	:= "C:\BX LOTE\"
cTipo 	:=         "*.CSV           | *.CSV |   "
cTipo 	:= cTipo + "Todos os Arquivos *.* | *.* "
//cArq 	:= cGetFile('Arquivo CSV|*.CSV|Arquivo *|*.CSV','Selecione arquivo',0,'C:\',.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.) 
Arquivo := cGetFile(cTipo, "Seleção de Arquivo",0,cDirIni,.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.)
Arquivo := Alltrim(Arquivo)

@ 048, 035 Get Arquivo When .F. Size 140, 10

Return (.T.)

//========================
Static Function Converte()
//========================
	aRet	:= {}
	If !Empty(Arquivo)
		cArqCSV := Alltrim(Arquivo)         // Arquivo Texto Selecionado
	EndIf

	If File(cArqCSV)

		FT_FUSE(cArqCSV)
		FT_FGOTO(1)
		ProcRegua(100)
		While lContinua .And. !FT_FEOF()
		
			cLinha		:= FT_FREADLN()
			aLinha		:= StrTokArr2(cLinha, ";", .T.)

			If !Empty(aLinha[02]) .And. aLinha[01] <> "FILIAL" .And. Val(aLinha[08]) > 0

				
				cE1_EMPRESA := aLinha[01]
				cE1_FILIAL	:= Strzero(Val(aLinha[02]), TamSX3("E1_FILIAL")[1])
				cE1_CLIENTE	:= Strzero(Val(aLinha[05]), TamSX3("E1_CLIENTE")[1])
				cE1_LOJA	:= StrZero(Val(aLinha[06]), TamSX3("E1_LOJA")[1])
				cE1_NUM		:= strzero(val(aLinha[03]),9)// StrZero(Val(aLinha[04]), TamSX3("E1_NUM")[1],9)
				cE1_PREFIXO := PadR(strzero(val(aLinha[04]),2),TamSX3("E1_PREFIXO")[1])
				cE1_PARCELA	:= CriaVar("E2_PARCELA")
				cE1_TIPO	:= "NF "
				/*
				SF2->( DbSEtORder(1))
				If SF2->( DbSeek(xFilial("SF2") + cE1_NUM + cE1_PREFIXO) )
					cE1_CLIENTE := SF2->F2_CLIENTE
					cE1_LOJA	:= SF2->F2_LOJA
				Endif
				If SE1->( dbSeek(FWxFilial("SE1")+cPrefixo+cNum+cParcela+cTipo) )
				E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				*/
				IncProc("Lendo Arquivo: "+cE1_PREFIXO+"-"+cE1_NUM)
				SE1->( DbSetOrder(2) )
				If SE1->( DbSeek(xFilial("SE1") + cE1_CLIENTE + cE1_LOJA + cE1_PREFIXO + cE1_NUM + cE1_PARCELA + cE1_TIPO) )
					aAdd(aRet, {SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->(Recno()) })
				Endif
			Endif
			FT_FSKIP()
		EndDo
	Endif
	FT_FUSE()
return aRet


/*/{Protheus.doc} Static Function FIN102Add
	Adiciona os itens na Grid para que os usuÃ¡rio possa salvar.
	@type  Function
	@author ANDRE MENDES
	@since 04/11/2020
/*/
Static Function FIN102Add(aTitulos)
	Local aArea 	:= GetArea()
	Local lRet 		:= .t.

	Local oModel 	:= FWModelActive()
	Local oView 	:= FWViewActive()
	Local oStruZG7 	:= oModel:GetModel( 'ENT_02_ZG7' )
	Local aSaveLine	:= FWSaveRows()

	Local nX
	Local nL
	Local nI := 0

	//deleta todos os registros ativos
	if !(oStruZG7:Length() == 1 .and. Empty(oStruZG7:getValue("ZG7_NUMERO")))
		For nI := 1 To oStruZG7:Length()
			oStruZG7:GoLine( nI )
			
			If !oStruZG7:IsDeleted()
				oStruZG7:DeleteLine()
			EndIf
		Next
	ENDIF

	FWRestRows( aSaveLine ) 

	For nX:= 1 To Len(aTitulos)

			if !(oStruZG7:getLine() == 1 .and. Empty(oStruZG7:getValue("ZG7_NUMERO")))
				nL := oStruZG7:AddLine()
			endif
			
			oStruZG7:SetValue('ZG7_PREFIX', aTitulos[nX][01] )
			oStruZG7:SetValue('ZG7_NUMERO', aTitulos[nX][02] )
			oStruZG7:SetValue('ZG7_PARCEL', aTitulos[nX][03] )
			oStruZG7:SetValue('ZG7_TIPO'  , aTitulos[nX][04] )
			oStruZG7:SetValue('ZG7_MOTBAI', FwFldGet("ZG6_MOTBAI") )
			oStruZG7:SetValue('ZG7_BANCO' , FwFldGet("ZG6_BANCO") )
			oStruZG7:SetValue('ZG7_AGENCI', FwFldGet("ZG6_AGENCI") )
			oStruZG7:SetValue('ZG7_CONTA' , FwFldGet("ZG6_CONTA") )

			fieldValidPos(oStruZG7, "*", nil, oStruZG7:GetLine(), nil)

			oView:Refresh()

	Next nX
	
	RestArea(aArea)
	
	fF5()
Return lRet

Static Function fF4()

	StaticCall(ADFIN102P,FIN102Grp)


Return .t.


Static Function fF6()
StaticCall(ADFIN102P,FIN102CSV)
Return .t.


Static Function fF5()
	Local oView 	:= FWViewActive()
	Local oModel 	:= FWModelActive()
	Local oModelZG7 := oModel:GetModel( 'ENT_02_ZG7' )
	Local nI 		:= 0
	Local nReg 		:= 0
	Local nTotRec 	:= 0
	Local aSaveLine	:= FWSaveRows()

	For nI := 1 To oModelZG7:Length()
		oModelZG7:GoLine( nI )
		If !oModelZG7:IsDeleted()
			nReg++

			nTotRec += oModelZG7:GetValue('ZG7_VLREC')

		EndIf
	Next
	FWRestRows( aSaveLine )

	oModel:GetModel( 'ENT_01_ZG6' ):SetValue('ZG6_QTDTIT', nReg )

	oModel:GetModel( 'ENT_01_ZG6' ):SetValue('ZG6_VALREC', nTotRec )

	oView:Refresh()
	


Return .t.

Static Function fTotal(cFilZG6, cCodigo, nTipo)
	Local nRet := 0
	Local aArea := GetArea()
	Local cAlias := GetNextAlias()
	Local cQuery := "" 
	Local aRet := {}

	cQuery := "SELECT " + CRLF
	cQuery += "		SUM(ZG7_VLREC)	 AS VALOR, " + CRLF
	cQuery += "		COUNT(ZG7_VLREC) AS REGISTRO " + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	"+RetSqlName("ZG7")+"	ZG7 " + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "	ZG7.D_E_L_E_T_ = '' " + CRLF
	cQuery += "AND ZG7.ZG7_FILIAL = '"+cFilZG6+"' " + CRLF
	cQuery += "AND ZG7.ZG7_CODIGO = '"+cCodigo+"' "



	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	DbSelectArea(cAlias)
	While !Eof()

		aAdd(aRet, {VALOR,REGISTRO})	

		dbSkip()
	End

	DbCloseArea()

	nRet := aRet[01][nTipo]

	RestArea(aArea)
Return nRet

Static Function fieldValidPos(oModelSit, cField, xValue, nLine, xCurrentValue)
    Local lRet      := .T.
	Local cQuery    := ""
	Local nVlRec	:= 0
	Local cParcela	:= iif(cField=="ZG7_PARCELA", xValue, FwFldGet("ZG7_PARCEL"))
	Local nDesconto	:= 0
	Local nMulta	:= 0
	Local nTxPerm	:= 0
	Local nAbatimen	:= 0


	if oModelSit:cID == "ENT_02_ZG7"

		if select("QSE1") == 0
			cQuery  := " SELECT E1.E1_PREFIXO, E1.E1_NUM, E1.E1_PARCELA, E1.E1_TIPO, E1.E1_PORTADO, E1.E1_NATUREZ, E1.E1_EMISSAO, E1. E1_EMIS1, "
			cQuery  += " E1.E1_CLIENTE, E1.E1_LOJA, SA1.A1_NOME, E1.E1_VENCREA, E1_SALDO, E1_VALOR, E1_DESCONT, "
			cQuery  += " EA.EA_VALOR "
			cQuery  += " FROM "+ RetSqlName("SE1") +" E1 "
			cQuery += "	INNER JOIN "+ RetSqlName("SA1") +"	SA1	ON " 
			cQuery += "	        SA1.A1_FILIAL='"+ xFilial("SA1") +"' AND "
			cQuery += "			SA1.A1_COD	= E1.E1_CLIENTE		AND "
			cQuery += "			SA1.A1_LOJA	= E1.E1_LOJA "
			cQuery += "	LEFT JOIN (SELECT E1_FILIAL, E1_TITPAI, SUM(E1_VALOR) EA_VALOR "
			cQuery  += " 					  FROM "+ RetSqlName("SE1") +" EA  "
			cQuery  += " 					  WHERE D_E_L_E_T_='' AND E1_TITPAI !='' "
			cQuery  += " 					  GROUP BY E1_FILIAL, E1_TITPAI) EA "
			cQuery  += " 		  ON E1.E1_FILIAL=EA.E1_FILIAL AND E1.E1_PREFIXO+E1.E1_NUM+E1.E1_PARCELA+E1.E1_TIPO+E1.E1_CLIENTE+E1.E1_LOJA =EA.E1_TITPAI "
			cQuery  += " WHERE E1.D_E_L_E_T_='' AND E1.E1_FILIAL='"+ xFilial("SE1") +"' AND E1.E1_PREFIXO='"+FwFldGet("ZG7_PREFIX")+"' AND E1.E1_NUM='"+FwFldGet("ZG7_NUMERO")+"' AND E1.E1_PARCELA='"+cParcela+"' AND E1.E1_TIPO='"+FwFldGet("ZG7_TIPO")+"' AND E1.E1_TITPAI=''; "
			
			TcQuery cQuery ALIAS "QSE1" NEW
		endif
		TCSETFIELD( "QSE1", "E1_EMISSAO", "D", 8, 0)
		TCSETFIELD( "QSE1", "E1_VENCREA", "D", 8, 0)
		
		//if SE1->(Dbseek(xFilial("SE1")+FwFldGet("ZG7_PREFIX")+FwFldGet("ZG7_NUMERO")+FwFldGet("ZG7_PARCEL")+FwFldGet("ZG7_TIPO")))
		IF QSE1->(!eof())

			nSaldo 		:= QSE1->E1_VALOR
			nDesconto	:= QSE1->E1_DESCONT
			nAbatimen	:= QSE1->EA_VALOR
			nMulta		:= iif(cField=="ZG7_MULTA"	, xValue, FwFldGet("ZG7_MULTA"))
			nTxPerm		:= iif(cField=="ZG7_TXPERM"	, xValue, FwFldGet("ZG7_TXPERM"))

			if cField == "*" .or. cField == "ZG7_PARCEL"
					
				oModelSit:LoadValue("ZG7_CLIENT"	, QSE1->E1_CLIENTE)
				oModelSit:LoadValue("ZG7_LOJA"		, QSE1->E1_LOJA)
				oModelSit:LoadValue("ZG7_DESCRI"	, QSE1->A1_NOME)
				oModelSit:LoadValue("ZG7_NATURE"	, QSE1->E1_NATUREZ)
				oModelSit:LoadValue("ZG7_EMISSA"	, QSE1->E1_EMISSAO)
				oModelSit:LoadValue("ZG7_VENCRE"	, QSE1->E1_VENCREA)
				oModelSit:LoadValue("ZG7_DTREC"		, ddatabase)
				oModelSit:LoadValue("ZG7_DTCRED"	, ddatabase)
				oModelSit:LoadValue("ZG7_HISTBA"	, "VALOR RECEBIDO S/ TITULO")
				
				oModelSit:LoadValue("ZG7_VALORI"	, QSE1->E1_VALOR)
				oModelSit:LoadValue("ZG7_DESCON"	, nDesconto)
				oModelSit:LoadValue("ZG7_ABATIM"	, nAbatimen)
				
				nValLiq := FwFldGet("ZG7_VALORI")-FwFldGet("ZG7_ABATI")-FwFldGet("ZG7_IMPOST")-FwFldGet("ZG7_DESCON")-FwFldGet("ZG7_ABATIM")
				oModelSit:LoadValue("ZG7_VLREC"		, nSaldo)
				oModelSit:LoadValue("ZG7_VALLIQ"	, nValLiq)

			endif
			
			if cField == "*" .or. cField == "ZG7_PARCEL" .or. cField == "ZG7_DESCON"
				
				nVlRec := nSaldo-nDesconto+nMulta+nTxPerm-nAbatimen
				oModelSit:LoadValue("ZG7_VLREC"		, nVlRec)
			
			endif

			if cField == "*" .or. cField == "ZG7_PARCEL" .or. cField == "ZG7_MULTA"

				nVlRec := nSaldo-nDesconto+nMulta+nTxPerm-nAbatimen
				oModelSit:LoadValue("ZG7_VLREC"		, nVlRec)
			
			endif
			
			if cField == "*" .or. cField == "ZG7_PARCEL" .or. cField == "ZG7_TXPERM"

				nVlRec := nSaldo-nDesconto+nMulta+nTxPerm-nAbatimen
				oModelSit:LoadValue("ZG7_VLREC"		, nVlRec)

			endif
		else
			MsgAlert("Título não encontrado, informe um registro válido.", "Erro")
		endif

		if select("QSE1") > 0
			QSE1->(dbclosearea())
		endif

	endif
    
return lRet
