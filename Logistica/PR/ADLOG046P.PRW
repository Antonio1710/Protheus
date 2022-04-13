#Include "RwMake.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "TOTVS.CH"
#Include "Topconn.ch"     
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch" 

#DEFINE IMP_SPOOL 2
#DEFINE VBOX       080
#DEFINE VSPACE     008
#DEFINE HSPACE     010
#DEFINE SAYVSPACE  008
#DEFINE SAYHSPACE  008
#DEFINE HMARGEM    030
#DEFINE VMARGEM    030
#DEFINE MAXITEM    022
#DEFINE MAXITEMP2  049
#DEFINE MAXITEMP2F 069
#DEFINE MAXITEMP3  025
#DEFINE MAXITEMC   038
#DEFINE MAXMENLIN  080
#DEFINE MAXMSG     013
#DEFINE MAXVALORC  011

/*/{Protheus.doc} User Function ADLOG046P
	Fechamento de frete
	@type  Function
	@author Ricardo Lima
	@since 30/11/2018
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 3873 - Fernando Macieira - 23/11/2020 - Projeto - Contrato e Controle de Entradas - Sใo Carlos
	@history ticket 70750 - Everson - 07/04/2022 - Adapta็ใo do fonte para nova filial.
/*/
User Function ADLOG046P

    LOCAL oBrowse

    Private aRotina := AdMnDef()
	Private lFchDvg := .F.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fechamento de frete')

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZFA")
	oBrowse:SetDescription("Fechamento de Frete")
	oBrowse:AddLegend("ZFA_FECHA = 'N'","BR_VERDE"   ,"Frete Aberto")
	oBrowse:AddLegend("ZFA_FECHA = 'C'","BR_AZUL"    ,"Frete Aprovado")
	oBrowse:AddLegend("ZFA_FECHA = 'S'","BR_VERMELHO","Frete Fechado")
    oBrowse:SetFilterDefault( " ZFA_OCORRE = '011' " )
	oBrowse:Activate()
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC Function AdMnDef()

	LOCAL aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar"            ACTION "VIEWDEF.ADLOG046P"       OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Conferencia de Frete"  ACTION "U_ADLG0461('1',NIL,NIL)" OPERATION 7 ACCESS 0
    ADD OPTION aRotina TITLE "Fechamento de Frete"   ACTION "U_ADLG0461('2','I',NIL)" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Estorno de Frete"      ACTION "U_ADLG0461('2','E',NIL)" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Conferencia para Aprova็ใo" ACTION "U_ADLG0462('1')"    OPERATION 7 ACCESS 0
	ADD OPTION aRotina TITLE "Adiantamento de Frete" ACTION "Processa({|| U_ADLG0463('I') },,'Gerando Adiantamento...')" OPERATION 7 ACCESS 0
	ADD OPTION aRotina TITLE "Estorna Adiant. Frete" ACTION "Processa({|| U_ADLG0463('E') },,'Estornando Adiantamento...')" OPERATION 7 ACCESS 0
	ADD OPTION aRotina TITLE "Legenda"               ACTION "U_ADLG046L()"            OPERATION 9 ACCESS 0

Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC Function ModelDef()

	LOCAL oModel
	LOCAL oStruZFA := FWFormStruct( 1, "ZFA", /*bAvalCampo*/, /*lViewUsado*/ )

	oModel := MPFormModel():New("ModelDef_MVC",/*bPreVld*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )
	oModel:SetDescription("Fechamento de Frete")
	oModel:AddFields("ZFAMASTER", /*cOwner*/, oStruZFA,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/ )
	oModel:SetPrimaryKey( {"ZFA_FILIAL" } )
Return oModel
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC Function ViewDef()

	Local oView
	Local oModel   := ModelDef()
	Local oStruZFA := FWFormStruct( 2, "ZFA" )

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField("VIEW_ZFA", oStruZFA, "ZFAMASTER" )
	oView:CreateHorizontalBox("TELA" , 100 )
    oView:SetCloseOnOk( { || .T. } )
Return oView
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADLG046L()

	Local aLegenda := {}

	U_ADINF009P('ADLOG046P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fechamento de frete')

	aAdd(aLegenda,{"BR_VERDE"   ,"Frete Aberto"  })
	aAdd(aLegenda,{"BR_AZUL"    ,"Frete Aprovado"})
	aAdd(aLegenda,{"BR_VERMELHO","Frete Fechado" })

	BrwLegenda("Frete","Legenda",aLegenda)

Return NiL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADLG0461( tOpfc , sTpOper , sVisFrt )

    Local oModal
    Local oContainer
    Local oFont    := TFont():New("Verdana",,014,,.T.,,,,,.F.,.F.)
    Local cCarga   := 'XXXXXX'
    Local cRoteir  := ZFA->ZFA_ROTEIR
    Local cNomTra  := ZFA->ZFA_NMTRAN
    Private cVeic    := ZFA->ZFA_VEICUL
    Private cVeicPag := ZFA->ZFA_VEICPG
	Private nNumPedC := ZFA->ZFA_PEDCOM
	Private cCodTran := ZFA->ZFA_TRANSP
    Private cLojTran := ZFA->ZFA_LOJTRA
	Private nKmT     := 0
	Private nFrtGer  := 0
	Private nTotDeb  := 0
	Private nTotCre  := 0
	Private nTotLiq  := 0 
    Private aBtcfm   := {}
    Private aCpoBro	 := {}
    Private lInverte := .F.  
    Private cMark    := GetMark()
	Private lOpc     := .T.
	Private lMovCnf  := .F.

	U_ADINF009P('ADLOG046P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fechamento de frete')

	If sVisFrt = '1'
		cRoteir  := 'XXXXXX'
		cNomTra  := ADLG146A->ZFANOMTRA
		cVeic    := ADLG146A->ZFAPLACA
		cVeicPag := ADLG146A->ZFAPLACA
		nNumPedC := ''
		cCodTran := ADLG146A->ZFATRANSP
		cLojTran := ''
	EndIf

	MontaPerg()
	if tOpfc = '1'
		If sVisFrt = '1'
			Pergunte("ADLG0462",.F.)
		Else 
			Pergunte("ADLG146P",.F.)
		Endif

		IF Empty(nNumPedC) .AND. sVisFrt <> '1'
			ApMsgInfo('Serใo considerados para Conferencia somente movimentos Aprovados.','Fechamento de frete')
			If ApMsgYesNo( 'Deseja visualizar a Conferencia somente dessa Carga? ou Todas as Cargas em Aberto desse Transportador.' )
				lOpc    := .F.
				nFrtGer := ZFA->ZFA_VALOR
				cCarga  := ZFA->ZFA_CARGA
			EndIf
		EndIf

		If lOpc .AND. sVisFrt <> '1'
			IF Empty(nNumPedC)
				ApMsgInfo('Selecione o Perํodo de Conferencia.','Fechamento de frete')
				Pergunte("ADLG146P",.T.)
			EndIf
			If Empty(nNumPedC)
				aAdd(aBtcfm, {'','Fechamento de Frete',{|| ApMsgInfo('O Fechamento irแ considerar o Perํodo da conferencia.','Fechamento de frete'),Processa({|| ADLG146F('I', cCodTran, cLojTran, nTotLiq, nNumPedC) },,"Executando o Fechamento de Frete - Aguarde..."),oModal:Deactivate()},'Rotina para confirmar o fechamento do frete',,,} )
			EndIf
			If !Empty(nNumPedC)
				aAdd(aBtcfm, {'','Estorna Fechamento' ,{|| ApMsgInfo('O Estorno irแ considerar os Frete do Pedido de Compra: '+nNumPedC+', Gerado no Fechamento.','Estorno do Fechamento de frete'),Processa({|| ADLG146F('E', cCodTran, cLojTran, nTotLiq, nNumPedC) },,"Executando o Estorno do Frete - Aguarde..."),oModal:Deactivate()},'Rotina para confirmar o fechamento do frete',,,} )
			EndIf
		EndIf
		
		If sVisFrt = '1'
			aAdd(aBtcfm, {'','Aprovar Frete',{|| Processa({|| ADLG146H('1') },,"Executando o Fechamento - Aguarde..."),oModal:Deactivate()},'',,,} )
		Endif

		If lOpc .or. sVisFrt = '1'
			Aadd( aCpoBro,{"ZFA_CARGA" ,  , "Carga"    , " " } )
		EndIf
		Aadd( aCpoBro,{"ZFA_DTENTR",  , "Data Entrega" , " " } )
		Aadd( aCpoBro,{"ZFA_DATA"  ,  , "Data Movto"   , " " } )
		Aadd( aCpoBro,{"ZFA_DC"    ,  , "Deb/Cred"     , " " } )
		Aadd( aCpoBro,{"ZFA_OCORRE",  , "Cod. Ocorren" , " " } )
		Aadd( aCpoBro,{"ZFA_DESCOC",  , "Desc Ocorren" , " " } )
		Aadd( aCpoBro,{"ZFA_VALOR" ,  , "Valor Ocorr"  , X3Picture('ZFA_VALOR') } )
		Aadd( aCpoBro,{"ZFA_VLDVEN",  ,"Vlr Entreg. Dev.", X3Picture('ZFA_VLDVEN') } )
		Aadd( aCpoBro,{"ZFA_ABAUNI",  , "R$ P/Litro"   , " " } )
		Aadd( aCpoBro,{"ZFA_ABALTR",  , "Nบ de Litros" , " " } )
		Aadd( aCpoBro,{"ZFA_KMTOT" ,  , "KM do Frete"  , " " } )
		Aadd( aCpoBro,{"ZFA_OBS"   ,  , "Obs Complem"  , " " } )
		Aadd( aCpoBro,{"ZFA_USUARI",  , "Usuario"      , " " } )
		Aadd( aCpoBro,{"ZFA_DATAIN",  , "Data Inclusa" , " " } )
		Aadd( aCpoBro,{"ZFA_HORA"  ,  , "Hora Inclusa" , " " } )
		Aadd( aCpoBro,{"ZFA_APRMOV",  , "Status"       , " " } )
		Aadd( aCpoBro,{"ZFA_USRAPR",  , "Aprovador"    , " " } )
		Aadd( aCpoBro,{"ZFA_NOMAPR",  , "Nome Aprov"   , " " } )
		Aadd( aCpoBro,{"ZFA_DTAPRO",  , "Data Aprov"   , " " } )
		Aadd( aCpoBro,{"ZFA_HRAPRO",  , "Hora Aprov"   , " " } )

		ADLG146G( cCarga , cRoteir , nNumPedC , sVisFrt )
		nTotLiq := (nFrtGer + nTotCre) - nTotDeb
		if !lMovCnf .AND. sVisFrt <> '1'
			aBtcfm := {}
			ApMsgInfo('A Conferencia de Aprova็ใo nใo foi Realizada, Nใo serแ possivel Fechar o Frete.','Fechamento de frete')
		EndIf
	
		oModal := FWDialogModal():New()        
		oModal:SetEscClose(.T.)
		oModal:setTitle("Conferencia de Frete")
		oModal:setSubTitle("Detalhes das movimenta็๕es de frete para conferencia e fechamento.")
		oModal:setSize( 250 , 600 )
		oModal:createDialog()
		oModal:addButtons( aBtcfm )
		oModal:addCloseButton(nil, "Fechar")
		
		oContainer := TPanel():New( ,,, oModal:getPanelMain() )
		oContainer:Align := CONTROL_ALIGN_ALLCLIENT
		
		TSay():New(003,002,{|| "Carga"  },oContainer,,oFont,,,,.T.,,,40,20,,,,,,.T.)
		TGet():New(015,002,{|u| if( PCount() > 0, cCarga := u, cCarga ) } ,oContainer,30,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cCarga")
		TSay():New(003,050,{|| "Roteiro"},oContainer,,oFont,,,,.T.,,,40,20,,,,,,.T.)
		TGet():New(015,050,{|u| if( PCount() > 0, cRoteir := u, cRoteir ) } ,oContainer,30,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cRoteir")
		TSay():New(003,100,{|| "Km" },oContainer,,oFont,,,,.T.,,,40,20,,,,,,.T.)    
		TGet():New(015,100,{|u| if( PCount() > 0, nKmT := u, nKmT ) } ,oContainer,30,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"nKmT")
		TSay():New(003,150,{|| "Transportador" },oContainer,,oFont,,,,.T.,,,80,20,,,,,,.T.)
		TGet():New(015,150,{|u| if( PCount() > 0, cCodTran := u, cCodTran ) } ,oContainer,30,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cCodTran")
		TSay():New(003,200,{|| "Loja" },oContainer,,oFont,,,,.T.,,,40,20,,,,,,.T.)
		TGet():New(015,200,{|u| if( PCount() > 0, cLojTran := u, cLojTran ) } ,oContainer,30,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cLojTran")
		TSay():New(003,250,{|| "Nome Transp." },oContainer,,oFont,,,,.T.,,,80,20,,,,,,.T.)
		TGet():New(015,250,{|u| if( PCount() > 0, cNomTra := u, cNomTra ) } ,oContainer,100,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cNomTra")
		TSay():New(003,350,{|| "Veiculo" },oContainer,,oFont,,,,.T.,,,40,20,,,,,,.T.)
		TGet():New(015,350,{|u| if( PCount() > 0, cVeic := u, cVeic ) } ,oContainer,35,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cVeic")
		TSay():New(003,400,{|| "Veiculo Pagamento" },oContainer,,oFont,,,,.T.,,,80,20,,,,,,.T.)
		TGet():New(015,400,{|u| if( PCount() > 0, cVeicPag := u, cVeicPag ) } ,oContainer,35,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cVeicPag")
		TSay():New(160,002,{|| "Frete Gerado"  },oContainer,,oFont,,,,.T.,,,80,20,,,,,,.T.)
		TGet():New(175,002,{|u| if( PCount() > 0, nFrtGer := u, nFrtGer ) } ,oContainer,60,009,X3Picture('ZFA_VALOR'),,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"nFrtGer")
		TSay():New(160,102,{|| "D้bitos"  },oContainer,,oFont,,,,.T.,CLR_RED,,80,20,,,,,,.T.)
		TGet():New(175,102,{|u| if( PCount() > 0, nTotDeb := u, nTotDeb ) } ,oContainer,60,009,X3Picture('ZFA_VALOR'),,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"nTotDeb")
		TSay():New(160,202,{|| "Cr้ditos"  },oContainer,,oFont,,,,.T.,CLR_BLUE,,80,20,,,,,,.T.)
		TGet():New(175,202,{|u| if( PCount() > 0, nTotCre := u, nTotCre ) } ,oContainer,60,009,X3Picture('ZFA_VALOR'),,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"nTotCre")
		TSay():New(160,302,{|| "Liquido a Receber R$"  },oContainer,,oFont,,,,.T.,CLR_BLUE,,80,20,,,,,,.T.)
		TGet():New(175,302,{|u| if( PCount() > 0, nTotLiq := u, nTotLiq ) } ,oContainer,60,009,X3Picture('ZFA_VALOR'),,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"nTotLiq")
		If !EMPTY(nNumPedC)
			TSay():New(160,402,{|| "Pedido de Compra"  },oContainer,,oFont,,,,.T.,CLR_BLUE,,80,20,,,,,,.T.)
			TGet():New(175,402,{|u| if( PCount() > 0, nNumPedC := u, nNumPedC ) } ,oContainer,60,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"nNumPedC")
		Endif
		MsSelect():New("ADLG146D","OK","",aCpoBro,@lInverte,@cMark,{030,000,150,600}, , , oContainer )
		oModal:Activate()
	Else
		ApMsgInfo('Selecione o Perํodo para Fechamento de Frete.','Fechamento de frete')
		Pergunte("ADLG146P",.T.)
		Processa({|| ADLG146L( MV_PAR01 , MV_PAR02 , sTpOper ) },,"Executando o "+ iif(sTpOper='I','Fechamento','Estorno') +" de Frete - Aguarde...")
	EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADLG0462()

	Local oModal
    Local oContainer
    Local oFont  := TFont():New("Verdana",,014,,.T.,,,,,.F.,.F.)
	Local cPerg  := 'ADLG0462'

	Private aBtcfm   := {}
    Private aCpoBro	 := {}
    Private lInverte := .F.  
    Private cMark    := GetMark()

	U_ADINF009P('ADLOG046P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fechamento de frete')

	aAdd(aBtcfm, {'','Detalhes do Fretes'  ,{|| Processa({|| U_ADLG0461('1' , NIL , '1' ) },,"Executando Aprova็ใo - Aguarde...")},'',,,} )
	aAdd(aBtcfm, {'','Aprova็ใo dos Fretes',{|| Processa({|| ADLG146H('2') , oModal:Deactivate() },,"Executando Aprova็ใo - Aguarde...")},'',,,} )

	MntPerg(cPerg)
	Pergunte(cPerg,.F.)
	ApMsgInfo('Selecione o Perํodo e o Transportador','Aprova็ใo de frete')
	Pergunte(cPerg,.T.)

	Aadd( aCpoBro,{"ZFAPLACA"  ,  , "Placa"           , " " } )
	Aadd( aCpoBro,{"ZFATRANSP" ,  , "Transportador"   , " " } )
	Aadd( aCpoBro,{"ZFANOMTRA" ,  , "Nome Transp."    , " " } )
	Aadd( aCpoBro,{"ZFAVLRFRT" ,  , "Valor Frete"     , X3Picture('ZFA_VALOR') } )
	Aadd( aCpoBro,{"ZFACREDITO",  , "Creditos"        , X3Picture('ZFA_VALOR') } )
	Aadd( aCpoBro,{"ZFADEBITO" ,  , "Debitos"         , X3Picture('ZFA_VALOR') } )
	Aadd( aCpoBro,{"ZFAVLRLIQ" ,  , "Liquido a Pagar" , X3Picture('ZFA_VALOR') } )

	oModal := FWDialogModal():New()        
	oModal:SetEscClose(.T.)
	oModal:setTitle("Conferencia para Aprova็ใo")
	oModal:setSubTitle("Detalhes das movimenta็๕es de frete do Periodo de "+dtoc(MV_PAR01)+" ate "+dtoc(MV_PAR02)+", por Placa para conferencia e Aprova็ใo.")
	oModal:setSize( 250 , 600 )
	oModal:createDialog()
	oModal:addButtons( aBtcfm )
	oModal:addCloseButton(nil, "Fechar")
	
	oContainer := TPanel():New( ,,, oModal:getPanelMain() )
	oContainer:Align := CONTROL_ALIGN_ALLCLIENT
	ADLG146B(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04)
	MsSelect():New("ADLG146A","OK","",aCpoBro,@lInverte,@cMark,{000,000,200,600}, , , oContainer )
	oModal:Activate()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ADLG146B(MVPAR01, MVPAR02, MVPAR03, MVPAR04)

	Local cArq     := CriaTrab( NIL, .F.)
	Local cNameIdx := FileNoExt(cArq)
	Local cQuery   := ""
	PRIVATE aCampos := {}

	Aadd( aCampos,{"ZFAPLACA"  ,"C", 7, 0 } )
	Aadd( aCampos,{"ZFATRANSP" ,"C", 7, 0 } )
	Aadd( aCampos,{"ZFANOMTRA" ,"C",25, 0 } )
	Aadd( aCampos,{"ZFAVLRFRT" ,"N",14, 2 } )
	Aadd( aCampos,{"ZFACREDITO","N",14, 2 } )
	Aadd( aCampos,{"ZFADEBITO" ,"N",14, 2 } )
	Aadd( aCampos,{"ZFAVLRLIQ" ,"N",14, 2 } )

	If ( SELECT("ADLG146A" ) !=  0 )
		dbSelectArea("ADLG146A")
		dbCloseArea()
	Endif

	dbCreate( cArq, aCampos )
	dbUseArea( .T., , cArq, "ADLG146A", .F., .F.)	

	cQuery := " SELECT ZFA_VEICPG, ZFA_TRANSP, ZFA_LOJTRA, ZFA_NMTRAN, SUM(ZFA_VALOR) ZFA_VALOR, ( "
	cQuery += " 	SELECT SUM(ZFA_VALOR+ZFA_VLDVEN) ZFAVALORD "
	cQuery += " 	FROM "+RetSqlName("ZFA")+" ZFA1 "
	cQuery += " 	WHERE ZFA_FILIAL = '"+FWxFilial("ZFA")+"' AND ZFA_OCORRE <> '011' AND ZFA_DC = 'D' "
	cQuery += " 	AND ZFA_PEDCOM = ' ' AND ZFA_APRMOV = 'S' "
	cQuery += " 	AND ZFA_DTENTR BETWEEN '"+DtoS(MVPAR01)+"' AND '"+DtoS(MVPAR02)+"' "
	cQuery += " 	AND ZFA_TRANSP = ZFA.ZFA_TRANSP "
	cQuery += " 	AND ZFA1.D_E_L_E_T_ = ' ' ) AS DEBITO, ( "
	cQuery += " 		SELECT SUM(ZFA_VALOR) ZFAVALORC "
	cQuery += " 		FROM "+RetSqlName("ZFA")+" ZFA1 "
	cQuery += " 		WHERE ZFA_FILIAL = '"+FWxFilial("ZFA")+"' AND ZFA_OCORRE <> '011' AND ZFA_DC = 'C' "
	cQuery += " 		AND ZFA_PEDCOM = ' ' AND ZFA_APRMOV = 'S' "
	cQuery += " 		AND ZFA_DTENTR BETWEEN '"+DtoS(MVPAR01)+"' AND '"+DtoS(MVPAR02)+"' "
	cQuery += " 		AND ZFA_TRANSP = ZFA.ZFA_TRANSP "
	cQuery += " 		AND ZFA1.D_E_L_E_T_ = ' ' ) AS CREDITO "
	cQuery += " FROM "+RetSqlName("ZFA")+" ZFA "
	cQuery += " WHERE ZFA_FILIAL = '"+FWxFilial("ZFA")+"' AND ZFA_OCORRE = '011' "
	cQuery += " AND ZFA_PEDCOM = ' ' AND ZFA_APRMOV = 'S' "
	cQuery += " AND ZFA_DTENTR BETWEEN '"+DtoS(MVPAR01)+"' AND '"+DtoS(MVPAR02)+"' "
	cQuery += " AND ZFA_TRANSP BETWEEN '"+MVPAR03+"' AND '"+MVPAR04+"' "
	cQuery += " AND ZFA_FECHA <> 'C' "
	cQuery += " AND ZFA.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY ZFA_VEICPG, ZFA_TRANSP, ZFA_LOJTRA, ZFA_NMTRAN "
	cQuery += " ORDER BY ZFA_VEICPG "

	If Select("TMPZFA") > 0
		TMPZFA->(DbCloseArea())		
	EndIf
	TcQuery cQuery New Alias "TMPZFA"

	WHILE TMPZFA->( !EOF() )
		dbSelectArea("ADLG146A")
			RecLock("ADLG146A", .T.)
			ADLG146A->ZFAPLACA   := TMPZFA->ZFA_VEICPG
			ADLG146A->ZFATRANSP  := TMPZFA->ZFA_TRANSP
			ADLG146A->ZFANOMTRA  := TMPZFA->ZFA_NMTRAN
			ADLG146A->ZFAVLRFRT  := TMPZFA->ZFA_VALOR
			ADLG146A->ZFACREDITO := TMPZFA->CREDITO
			ADLG146A->ZFADEBITO  := TMPZFA->DEBITO
			ADLG146A->ZFAVLRLIQ  := (TMPZFA->ZFA_VALOR + TMPZFA->CREDITO) - TMPZFA->DEBITO
			MSUnLock()
		dbSelectArea("TMPZFA")
		TMPZFA->( DbSkip() )	
	End
	dbSelectArea("TMPZFA")
	dbGoTop()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC Function ADLG146G( cCarga , cRoteir , nNumPedC , sVisFrt , ZTRANSP)

Local cArq     := CriaTrab( NIL, .F.)
Local cNameIdx := FileNoExt(cArq)
Local cQuery   := ""
PRIVATE aCampos := {}

	If lOpc .or. sVisFrt = '1'
		Aadd( aCampos,{"ZFA_CARGA" , "C" , TamSX3("ZFA_CARGA")[1]  , 0 } )
	EndIf
	Aadd( aCampos,{"ZFA_DTENTR", "D" , TamSX3("ZFA_DTENTR")[1] , 0 } )
	Aadd( aCampos,{"ZFA_DATA"  , "D" , TamSX3("ZFA_DATA")[1]   , 0 } )
	Aadd( aCampos,{"ZFA_DC"    , "C" , 7                       , 0 } )
	Aadd( aCampos,{"ZFA_OCORRE", "C" , TamSX3("ZFA_OCORRE")[1] , 0 } )
	Aadd( aCampos,{"ZFA_DESCOC", "C" , TamSX3("ZFA_DESCOC")[1] , 0 } )
	Aadd( aCampos,{"ZFA_VALOR" , "N" , TamSX3("ZFA_VALOR")[1]  , TamSX3("ZFA_VALOR")[2]  } )
	Aadd( aCampos,{"ZFA_VLDVEN", "N" , TamSX3("ZFA_VLDVEN")[1] , TamSX3("ZFA_VLDVEN")[2]  } )
	Aadd( aCampos,{"ZFA_ABAUNI", "N" , TamSX3("ZFA_ABAUNI")[1] , TamSX3("ZFA_ABAUNI")[2] } )
	Aadd( aCampos,{"ZFA_ABALTR", "N" , TamSX3("ZFA_ABALTR")[1] , TamSX3("ZFA_ABALTR")[2] } )
	Aadd( aCampos,{"ZFA_KMTOT" , "N" , TamSX3("ZFA_KMTOT")[1]  , TamSX3("ZFA_KMTOT")[2]  } )
	Aadd( aCampos,{"ZFA_OBS"   , "C" , TamSX3("ZFA_OBS")[1]    , 0 } )
	Aadd( aCampos,{"ZFA_USUARI", "C" , TamSX3("ZFA_USUARI")[1] , 0 } )
	Aadd( aCampos,{"ZFA_DATAIN", "D" , TamSX3("ZFA_DATAIN")[1] , 0 } )
	Aadd( aCampos,{"ZFA_HORA"  , "C" , TamSX3("ZFA_HORA")[1]   , 0 } )
	Aadd( aCampos,{"ZFA_APRMOV", "C" , 9                       , 0 } )
	Aadd( aCampos,{"ZFA_USRAPR", "C" , TamSX3("ZFA_USRAPR")[1] , 0 } )
	Aadd( aCampos,{"ZFA_NOMAPR", "C" , TamSX3("ZFA_NOMAPR")[1] , 0 } )
	Aadd( aCampos,{"ZFA_DTAPRO", "D" , TamSX3("ZFA_DTAPRO")[1] , 0 } )
	Aadd( aCampos,{"ZFA_HRAPRO", "C" , TamSX3("ZFA_HRAPRO")[1] , 0 } )
	
	If ( SELECT("ADLG146D" ) !=  0 )
		dbSelectArea("ADLG146D")
		dbCloseArea()
	Endif

	dbCreate( cArq, aCampos )
	dbUseArea( .T., , cArq, "ADLG146D", .F., .F.)
	if sVisFrt <> '1'
		If lOpc
			DBCreateIndex(cNameIdx,'ZFA_CARGA+ZFA_OCORRE')
		Else
			DBCreateIndex(cNameIdx,'ZFA_OCORRE')
		EndIf
	Endif
	// Ricardo Lima-21/01/2019-CH:044314
	ADLG0464( MV_PAR01 , MV_PAR02 , cVeicPag ) // Atualiza Combustivel
	If sVisFrt = '1'
		cQuery := " SELECT ZFA_CARGA, ZFA_DTENTR, ZFA_DATA, ZFA_DC, ZFA_OCORRE, ZFA_DESCOC, ZFA_VALOR, ZFA_VLDVEN, ZFA_ABAUNI, ZFA_ABALTR, ZFA_OBS, ZFA_USUARI, ZFA_DATAIN, ZFA_HORA, ZFA_USRAPR, ZFA_NOMAPR, ZFA_DTAPRO, ZFA_HRAPRO, ZFA_APRMOV, ZFA_KMTOT, ZFA_FECHA "
		cQuery += " FROM "+RetSqlName("ZFA")+" ZFA "
		cQuery += " WHERE ZFA_FILIAL = '"+FWxFilial("ZFA")+"' "
		cQuery += " AND ZFA_PEDCOM = ' ' AND ZFA_APRMOV = 'S' "
		cQuery += " AND ZFA_DTENTR BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "
		cQuery += " AND ZFA_TRANSP BETWEEN '"+ADLG146A->ZFATRANSP+"' AND '"+ADLG146A->ZFATRANSP+"' "
		cQuery += " AND ZFA.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY ZFA_OCORRE "
	Else 
		cQuery := " SELECT ZFA_CARGA, ZFA_DTENTR, ZFA_DATA, ZFA_DC, ZFA_OCORRE, ZFA_DESCOC, ZFA_VALOR, ZFA_VLDVEN, ZFA_ABAUNI, ZFA_ABALTR, ZFA_OBS, ZFA_USUARI, ZFA_DATAIN, ZFA_HORA, ZFA_USRAPR, ZFA_NOMAPR, ZFA_DTAPRO, ZFA_HRAPRO, ZFA_APRMOV, ZFA_KMTOT, ZFA_FECHA "
		cQuery += " FROM "+ RetSqlName("ZFA") +" ZFA "
		cQuery += " WHERE ZFA_FILIAL = '"+FWxFilial("ZFA")+"' "
		If lOpc
			cQuery += " AND ZFA_TRANSP = '"+cCodTran+"' AND ZFA_LOJTRA = '"+cLojTran+"' "
			if Empty(nNumPedC)
				cQuery += " AND ZFA_DTENTR BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "
			Else
				cQuery += "AND ZFA_PEDCOM = '"+nNumPedC+"' "
			EndIf
		Else
			cQuery += " AND ZFA_CARGA = '"+cCarga+"' AND ZFA_OCORRE <> '011' "
		EndIf
		if Empty(nNumPedC)
			cQuery += " AND ZFA_FECHA <> 'S' "
		EndIf
		cQuery += " AND ZFA.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY ZFA_CARGA, ZFA_OCORRE, ZFA_DATA "
	Endif
	If Select("tADLG146D") > 0
		tADLG146D->(DbCloseArea())		
	EndIf
	TcQuery cQuery New Alias "tADLG146D"

	WHILE tADLG146D->( !EOF() )
		dbSelectArea("ADLG146D")
			RecLock("ADLG146D", .T.)
			If lOpc
				ADLG146D->ZFA_CARGA  := tADLG146D->ZFA_CARGA
			Endif
			ADLG146D->ZFA_DTENTR := StoD(tADLG146D->ZFA_DTENTR)
			ADLG146D->ZFA_DATA   := StoD(tADLG146D->ZFA_DATA)
			ADLG146D->ZFA_DC     := IIF(tADLG146D->ZFA_DC='C','Credito','Debito')
			ADLG146D->ZFA_OCORRE := tADLG146D->ZFA_OCORRE
			ADLG146D->ZFA_DESCOC := tADLG146D->ZFA_DESCOC
			ADLG146D->ZFA_VALOR  := tADLG146D->ZFA_VALOR
			ADLG146D->ZFA_VLDVEN := tADLG146D->ZFA_VLDVEN
			ADLG146D->ZFA_ABAUNI := tADLG146D->ZFA_ABAUNI
			ADLG146D->ZFA_ABALTR := tADLG146D->ZFA_ABALTR
			ADLG146D->ZFA_OBS    := tADLG146D->ZFA_OBS
			ADLG146D->ZFA_USUARI := tADLG146D->ZFA_USUARI
			ADLG146D->ZFA_DATAIN := StoD(tADLG146D->ZFA_DATAIN)
			ADLG146D->ZFA_HORA   := tADLG146D->ZFA_HORA
			ADLG146D->ZFA_USRAPR := tADLG146D->ZFA_USRAPR
			ADLG146D->ZFA_NOMAPR := tADLG146D->ZFA_NOMAPR
			ADLG146D->ZFA_DTAPRO := StoD(tADLG146D->ZFA_DTAPRO)
			ADLG146D->ZFA_HRAPRO := tADLG146D->ZFA_HRAPRO
			If tADLG146D->ZFA_DC ='D' .AND. tADLG146D->ZFA_OCORRE <> '011' .AND. tADLG146D->ZFA_APRMOV = 'S'
				nTotDeb := nTotDeb + ( tADLG146D->ZFA_VALOR + tADLG146D->ZFA_VLDVEN )
			ElseIf tADLG146D->ZFA_DC ='C' .AND. tADLG146D->ZFA_OCORRE <> '011' .AND. tADLG146D->ZFA_APRMOV = 'S'
				nTotCre := nTotCre + tADLG146D->ZFA_VALOR
			ElseIf tADLG146D->ZFA_OCORRE = '011'  .AND. tADLG146D->ZFA_APRMOV = 'S'
				nFrtGer := nFrtGer + tADLG146D->ZFA_VALOR
			EndIf
			If tADLG146D->ZFA_APRMOV <> 'S'
				If Empty(nNumPedC)
					ApMsgInfo('Existe Movimentos de Frete NรO Aprovado, Pode Ocorrer Diverg๊ncias no Fechamento!','Fechamento de frete')
					lFchDvg := .T.
				EndIf
				ADLG146D->ZFA_APRMOV := 'Bloqueado'
			Else
				ADLG146D->ZFA_APRMOV := 'Aprovado'
			EndIf
			ADLG146D->ZFA_KMTOT := tADLG146D->ZFA_KMTOT
			nKmT += tADLG146D->ZFA_KMTOT
			MSUnLock()
			If tADLG146D->ZFA_FECHA = 'C' .OR. !Empty(nNumPedC)
				lMovCnf := .T.
			EndIf
		dbSelectArea("tADLG146D")
		tADLG146D->( DbSkip() )	
	End
	
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ADLG146H(sOpc)

	Local cQuery := ""

	IF sOpc = '1'
		cQuery := " SELECT ZFA_CARGA, ZFA_DTENTR, ZFA_DATA, ZFA_DC, ZFA_OCORRE, ZFA_DESCOC, ZFA_VALOR, ZFA_ABAUNI, ZFA_ABALTR, ZFA_OBS, ZFA_USUARI, ZFA_DATAIN, ZFA_HORA, ZFA_USRAPR, ZFA_NOMAPR, ZFA_DTAPRO, ZFA_HRAPRO, ZFA_APRMOV, ZFA_KMTOT, ZFA_FECHA, R_E_C_N_O_ cRECNO "
		cQuery += " FROM "+RetSqlName("ZFA")+" ZFA "
		cQuery += " WHERE ZFA_FILIAL = '"+FWxFilial("ZFA")+"' "
		cQuery += " AND ZFA_PEDCOM = ' ' AND ZFA_APRMOV = 'S' "
		cQuery += " AND ZFA_DTENTR BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "
		cQuery += " AND ZFA_TRANSP BETWEEN '"+ADLG146A->ZFATRANSP+"' AND '"+ADLG146A->ZFATRANSP+"' "
		cQuery += " AND ZFA.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY ZFA_OCORRE "
	Else
		cQuery := " SELECT ZFA_CARGA, ZFA_DTENTR, ZFA_DATA, ZFA_DC, ZFA_OCORRE, ZFA_DESCOC, ZFA_VALOR, ZFA_ABAUNI, ZFA_ABALTR, ZFA_OBS, ZFA_USUARI, ZFA_DATAIN, ZFA_HORA, ZFA_USRAPR, ZFA_NOMAPR, ZFA_DTAPRO, ZFA_HRAPRO, ZFA_APRMOV, ZFA_KMTOT, ZFA_FECHA, R_E_C_N_O_ cRECNO "
		cQuery += " FROM "+RetSqlName("ZFA")+" ZFA "
		cQuery += " WHERE ZFA_FILIAL = '"+FWxFilial("ZFA")+"' "
		cQuery += " AND ZFA_PEDCOM = ' ' AND ZFA_APRMOV = 'S' "
		cQuery += " AND ZFA_DTENTR BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "
		cQuery += " AND ZFA_TRANSP BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
		cQuery += " AND ZFA.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY ZFA_OCORRE "
	Endif

	If Select("ADLG146H") > 0
		ADLG146H->(DbCloseArea())		
	EndIf
	TcQuery cQuery New Alias "ADLG146H"

	WHILE ADLG146H->( !EOF() )
		dbSelectArea("ZFA")
		dbGoto(ADLG146H->cRECNO)
			RecLock("ZFA",.F.)
				ZFA->ZFA_FECHA = 'C'
			MsUnlock()
		ADLG146H->( DbSkip() )	
	End

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ADLG146F(cOpc, cCodTran, cLojTran,nTotLiq,nNumPedC)

	Local lRet := .T.
	Local aCab     := {}
	Local aItens   := {}
	Local aLinha   := {}
	Local cNumPc   := ""
	Local cCondPG  := ''
	Local sNumCta  := Alltrim(SuperGetMv( "MV_#ADL461" , .F. , '313120001' , ) )
	Local sIteCta  := Alltrim(SuperGetMv( "MV_#ADL462" , .F. , '121' , ) )
	Local sCCPed   := Alltrim(SuperGetMv( "MV_#ADL463" , .F. , '6110' , ) )
	Local sProdPC  := Alltrim(SuperGetMv( "MV_#ADL464" , .F. , '800923' , ) )
	Local sObsPC   := Alltrim(SuperGetMv( "MV_#ADL465" , .F. , 'Gerado automatico pelo novo sistema de Frete' , ) )
	Local sClvlPC  := Alltrim(SuperGetMv( "MV_#ADL466" , .F. , '210' , ) )

	Private lMsHelpAuto := .T.
	Private lMsErroAuto := .F.

	If lFchDvg
		ApMsgInfo('Existe Movimentos de Frete NรO Aprovado, Pode Ocorrer Diverg๊ncias no Fechamento!','Fechamento de frete')
		sObsPC += ', Gerado com Movimentos de Frete nใo Aprovado.'
	EndIf

	dbSelectArea("SA2")
	dbSetOrder(1)
	If DbSeek( FWxFilial("SA2") + cCodTran + cLojTran )
		cCondPG := SA2->A2_COND
	Endif
	IF cOpc = 'I'
		//cNumPc := GetSXENum("SC7","C7_NUM")
		cNumPc := u_SXESXF("SC7") // @history ticket    3873 - Fernando Macieira - 23/11/2020 - Projeto - Contrato e Controle de Entradas - Sใo Carlos
	Else
		dbSelectArea("SC7")
		dbSetOrder(1)
		if dbSeek( FWxFilial("SC7") + nNumPedC )
			cNumPc := SC7->C7_NUM
		Else
			cNumPc := nNumPedC
		EndIf
	EndIf
		
	aadd(aCab,{"C7_NUM" 	,cNumPc    })
	aadd(aCab,{"C7_EMISSAO" ,Date()    })
	aadd(aCab,{"C7_FORNECE" ,cCodTran  })
	aadd(aCab,{"C7_LOJA" 	,cLojTran  })
	aadd(aCab,{"C7_COND"	,cCondPG   })
	aadd(aCab,{"C7_CONTATO" ,""        })
	aadd(aCab,{"C7_FILENT"  ,FWxFilial("SC7") })

	aLinha := {}
	aadd(aLinha,{"C7_PRODUTO" 	,sProdPC            ,Nil})
	aadd(aLinha,{"C7_QUANT" 	,1                  ,Nil})
	aadd(aLinha,{"C7_PRECO" 	,nTotLiq            ,Nil})
	aadd(aLinha,{"C7_TOTAL" 	,nTotLiq            ,Nil})
	aadd(aLinha,{"C7_CC" 		,sCCPed             ,Nil})
	aadd(aLinha,{"C7_LOCAL" 	,'99'               ,Nil})
	aadd(aLinha,{"C7_CONTA" 	,sNumCta            ,Nil})
	aadd(aLinha,{"C7_ITEMCTA" 	,sIteCta            ,Nil})
	aadd(aLinha,{"C7_CLVL"      ,sClvlPC            ,Nil})
	aadd(aLinha,{"C7_XRESPON" 	,AllTrim(cUserName) ,Nil})
	aadd(aLinha,{"C7_XTIPCTE" 	,'CTE'              ,Nil})  
	aadd(aLinha,{"C7_OBS" 	    ,sObsPC             ,Nil})  
	if cOpc = 'E'
		aadd(aLinha,{"C7_REC_WT",SC7->(RECNO()) ,Nil})
	EndIf
	
	aadd(aItens,aLinha)

	lMsErroAuto := .F.                    
	if cOpc = 'I'
		MATA120(1,aCab,aItens,3)
	Else
		MATA120(1,aCab,aItens,5)
	EndIf

	If lMsErroAuto   
		MostraErro()
	Else 
		ConfirmSX8()
		While ADLG146D->(!Eof())
			dbSelectArea("ZFD")
			dbSetOrder(1) //ZFD_FILIAL, ZFD_COD
			if dbSeek( FWxFilial("ZFD") + ADLG146D->ZFA_CARGA )
				While ZFD->(!Eof()) .AND. ZFD->ZFD_COD = ADLG146D->ZFA_CARGA
					RecLock("ZFD",.F.)
						if cOpc = 'I'
							ZFD->ZFD_FECHA := 'S'
						Else
							ZFD->ZFD_FECHA := 'N'
						EndIf
					MsUnLock()
					ZFD->( DbSkip())
				End
			EndIf
			dbSelectArea("ZFA")
			dbSetOrder(7)
			If DbSeek( FWxFilial("ZFA") + ADLG146D->ZFA_CARGA + ADLG146D->ZFA_OCORRE )
				if cOpc = 'I'
					RecLock("ZFA",.F.)
						ZFA->ZFA_PEDCOM := cNumPc
						ZFA->ZFA_FECHA  := 'S'
					MsUnLock()
				Else
					RecLock("ZFA",.F.)
						ZFA->ZFA_PEDCOM := Space(6)
						ZFA->ZFA_FECHA  := 'N'
					MsUnLock()
				EndIf
			EndIf
			ADLG146D->( DbSkip() )
		End
	EndIf

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ADLG146L( MVPAR01 , MVPAR02 , cOpc )

	Local lRet := .T.
	Local aCab     := {}
	Local aItens   := {}
	Local aLinha   := {}
	Local cNumPc   := ""
	Local cCondPG  := ""
	Local sNumCta  := Alltrim(SuperGetMv( "MV_#ADL461" , .F. , '313120001' , ) )
	Local sIteCta  := Alltrim(SuperGetMv( "MV_#ADL462" , .F. , '121' , ) )
	Local sCCPed   := Alltrim(SuperGetMv( "MV_#ADL463" , .F. , '6110' , ) )
	Local sProdPC  := Alltrim(SuperGetMv( "MV_#ADL464" , .F. , '800923' , ) )
	Local sObsPC   := Alltrim(SuperGetMv( "MV_#ADL465" , .F. , 'Gerado automแtico pelo novo sistema de Fretes' , ) )
	Local sClvlPC  := Alltrim(SuperGetMv( "MV_#ADL466" , .F. , '210' , ) )
	Local cQuery   := ""
	Local vLiqFrt  := 0

	Private lMsHelpAuto := .T.
	Private lMsErroAuto := .F.

	// Ricardo Lima-21/01/2019-CH:044314
	ADLG0464( MVPAR01 , MVPAR02 , cVeicPag ) // Atualiza Combustivel

	IF cOpc = 'I'
		cQuery := " SELECT DISTINCT ZFA_TRANSP+ZFA_LOJTRA AS ZFA_TRANSP "
	Else
		cQuery := " SELECT DISTINCT ZFA_PEDCOM "
	EndIf
	cQuery += " FROM "+RetSqlName("ZFA")+" ZFA "
	cQuery += " WHERE ZFA_FILIAL = '"+FWxFilial("ZFA")+"' "
	cQuery += " AND ZFA_APRMOV = 'S' "
	IF cOpc = 'I'
		cQuery += " AND ZFA_FECHA = 'C' AND ZFA_PEDCOM = ' ' "
	Else
		cQuery += " AND ZFA_FECHA = 'S' AND ZFA_PEDCOM <> ' ' "
	EndIf
	cQuery += " AND ZFA_DTENTR BETWEEN '"+DtoS(MVPAR01)+"' AND '"+DtoS(MVPAR02)+"' "
	cQuery += " AND ZFA.D_E_L_E_T_ = ' ' "
	If Select("ADLG461") > 0
		ADLG461->(DbCloseArea())		
	EndIf
	TcQuery cQuery New Alias "ADLG461"
	
	If ADLG461->( Eof() )
		IF cOpc = 'I'
			ApMsgInfo('Nใo Existe Frete em Aberto para o periodo Selecionado, Verifique!','Fechamento de frete')
		Else
			ApMsgInfo('Nใo Existe Frete em para Estorno no periodo Selecionado, Verifique!','Fechamento de frete')
		Endif
	EndIf

	While ADLG461->( !Eof() )
		cQuery := " SELECT ZFA_CARGA, ZFA_TRANSP, ZFA_LOJTRA, ZFA_DTENTR, ZFA_DATA, ZFA_DC, ZFA_OCORRE, ZFA_DESCOC, ZFA_VALOR, ZFA_VLDVEN, ZFA_ABAUNI, ZFA_ABALTR, ZFA_OBS, ZFA_USUARI, ZFA_DATAIN, ZFA_HORA, ZFA_USRAPR, ZFA_NOMAPR, ZFA_DTAPRO, ZFA_HRAPRO, ZFA_PEDCOM, ZFA_FECHA, ZFA_APRMOV "
		cQuery += " FROM "+RetSqlName("ZFA")+" ZFA "
		cQuery += " WHERE ZFA_FILIAL = '"+FWxFilial("ZFA")+"' "
		cQuery += " AND ZFA_APRMOV = 'S' "
		IF cOpc = 'I'
			cQuery += " AND ZFA_FECHA = 'C' AND ZFA_PEDCOM = ' ' "
			cQuery += " AND ZFA_DTENTR BETWEEN '"+DtoS(MVPAR01)+"' AND '"+DtoS(MVPAR02)+"' "
			cQuery += " AND ZFA_TRANSP+ZFA_LOJTRA = '"+ADLG461->ZFA_TRANSP+"' "
		Else
			cQuery += " AND ZFA_PEDCOM = '"+ADLG461->ZFA_PEDCOM+"' "
		Endif
		cQuery += " AND ZFA.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY ZFA_TRANSP, ZFA_DTENTR "
		If Select("ADLG146L") > 0
			ADLG146L->(DbCloseArea())		
		EndIf
		TcQuery cQuery New Alias "ADLG146L"

		While ADLG146L->( !Eof() )
			if ADLG146L->ZFA_DC = 'C'
				vLiqFrt := vLiqFrt + ADLG146L->ZFA_VALOR
			Else
				vLiqFrt := vLiqFrt - ( ADLG146L->ZFA_VALOR + ADLG146L->ZFA_VLDVEN )
			EndIf
		ADLG146L->( DbSkip() )
		End
		dbSelectArea("ADLG146L")
		dbGoTop()
		dbSelectArea("SA2")
		dbSetOrder(1)
		If DbSeek( FWxFilial("SA2") + ADLG146L->ZFA_TRANSP + ADLG146L->ZFA_LOJTRA )
			cCondPG := SA2->A2_COND
		Endif
		IF cOpc = 'I'
			//cNumPc := GetSXENum("SC7","C7_NUM")
			cNumPc := u_SXESXF("SC7") // @history ticket    3873 - Fernando Macieira - 23/11/2020 - Projeto - Contrato e Controle de Entradas - Sใo Carlos
		Else
			dbSelectArea("SC7")
			dbSetOrder(1)
			if dbSeek( FWxFilial("SC7") + ADLG146L->ZFA_PEDCOM )
				cNumPc := SC7->C7_NUM
			Else
				cNumPc := ADLG146L->ZFA_PEDCOM
			EndIf
		EndIf
			
		aadd(aCab,{"C7_NUM" 	,cNumPc    })
		aadd(aCab,{"C7_EMISSAO" ,Date()    })
		aadd(aCab,{"C7_FORNECE" ,SA2->A2_COD })
		aadd(aCab,{"C7_LOJA" 	,SA2->A2_LOJA })
		aadd(aCab,{"C7_COND"	,cCondPG   })
		aadd(aCab,{"C7_CONTATO" ,""        })
		aadd(aCab,{"C7_FILENT"  ,FWxFilial("SC7") })

		aLinha := {}
		aadd(aLinha,{"C7_PRODUTO" 	,sProdPC            ,Nil})
		aadd(aLinha,{"C7_QUANT" 	,1                  ,Nil})
		aadd(aLinha,{"C7_PRECO" 	,vLiqFrt            ,Nil})
		aadd(aLinha,{"C7_TOTAL" 	,vLiqFrt            ,Nil})
		aadd(aLinha,{"C7_CC" 		,sCCPed             ,Nil})
		aadd(aLinha,{"C7_LOCAL" 	,'99'               ,Nil})
		aadd(aLinha,{"C7_CONTA" 	,sNumCta            ,Nil})
		aadd(aLinha,{"C7_ITEMCTA" 	,sIteCta            ,Nil})
		aadd(aLinha,{"C7_CLVL"      ,sClvlPC            ,Nil})
		aadd(aLinha,{"C7_XRESPON" 	,AllTrim(cUserName) ,Nil})
		aadd(aLinha,{"C7_XTIPCTE" 	,'CTE'              ,Nil})  
		aadd(aLinha,{"C7_OBS" 	    ,sObsPC             ,Nil})  
		if cOpc = 'E'
			aadd(aLinha,{"C7_REC_WT",SC7->(RECNO()) ,Nil})
		EndIf
		
		aadd(aItens,aLinha)

		lMsErroAuto := .F.                    
		if cOpc = 'I'
			MATA120(1,aCab,aItens,3)
		Else
			MATA120(1,aCab,aItens,5)
		EndIf

		If lMsErroAuto   
			MostraErro()
		Else 
			ConfirmSX8()
			dbSelectArea("ADLG146L")
			dbGoTop()
			While ADLG146L->(!Eof())
				dbSelectArea("ZFD")
				dbSetOrder(1)
				if dbSeek( FWxFilial("ZFD") + ADLG146L->ZFA_CARGA )
					While ZFD->(!Eof()) .AND. ZFD->ZFD_COD = ADLG146L->ZFA_CARGA
						RecLock("ZFD",.F.)
							if cOpc = 'I'
								ZFD->ZFD_FECHA := 'S'
							Else
								ZFD->ZFD_FECHA := 'N'
							EndIf
						MsUnLock()
						ZFD->( DbSkip())
					End
				EndIf
				dbSelectArea("ZFA")
				dbSetOrder(7)
				If DbSeek( FWxFilial("ZFA") + ADLG146L->ZFA_CARGA + ADLG146L->ZFA_OCORRE )
					if cOpc = 'I'
						RecLock("ZFA",.F.)
							ZFA->ZFA_PEDCOM := cNumPc
							ZFA->ZFA_FECHA  := 'S'
						MsUnLock()
					Else
						RecLock("ZFA",.F.)
							ZFA->ZFA_PEDCOM := Space(6)
							ZFA->ZFA_FECHA  := 'N'
						MsUnLock()
					EndIf
				EndIf
				ADLG146L->( DbSkip() )
			End
			aCab   := {}
			aItens := {}
			aLinha := {}
		EndIf
	ADLG461->( DbSkip() )
	End
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADLG0463(cOpc)

	Local cQuery   := ""
	Local sOcorAD  := ''
	Local sDscOcos := ''
	Local sTpOcorr := ''
	Local nVlrMin  := SuperGetMv( "MV_#ADL468" , .F. , 999.99 , )
	Local nMinCte  := SuperGetMv( "MV_#ADL469" , .F. , 9999.99 , )
	Local sNCteEm  := 0
	Local lGerouA  := .F.
	Local aCab     := {}
	Local aItens   := {}
	Local aLinha   := {}
	Local cNumPc   := ""
	Local cCondPG  := ""
	Local sNumCta  := Alltrim(SuperGetMv( "MV_#ADL461" , .F. , '313120001' , ) )
	Local sIteCta  := Alltrim(SuperGetMv( "MV_#ADL462" , .F. , '121' , ) )
	Local sCCPed   := Alltrim(SuperGetMv( "MV_#ADL463" , .F. , '6110' , ) )
	Local sProdPC  := Alltrim(SuperGetMv( "MV_#ADL464" , .F. , '800923' , ) )
	Local sObsPC   := Alltrim(SuperGetMv( "MV_#ADL465" , .F. , 'Gerado automแtico pelo novo sistema de Fretes' , ) )
	Local sClvlPC  := Alltrim(SuperGetMv( "MV_#ADL466" , .F. , '210' , ) )
	Local cRecnoZF := ''
	Local cAssunto := "Adiantamento de Frete"
	Local cMsg     := ""
	Local cDestWF  := ""
	Local cCopiaWF := ""
	Local aAnexo   := {}
	Local cCompCam := Alltrim(SuperGetMv( "MV_#ADL46B" , .F. , '\AnexoFrete' , ) )+'\'
	Local cARMLOCA := Alltrim(SuperGetMv( "MV_#ADL46C" , .F. , 'C:\temp\' , ) )+'\'
	Local wf       := 0
	Local nVlrpCte := 0
	Local cPerg    := "ADLG146Q"
	Local aNfwfTrp := {}
	Local wQuery   := ""
	
	Private oDanfe      
	Private nConsNeg := 0.4
	Private nConsTex := 0.5
	Private oFont1   := TFont():New( "Courier New", , -18, .T.)
	Private PixelX
    Private PixelY

	U_ADINF009P('ADLOG046P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fechamento de frete')

	MntAPerg(cPerg) 
	Pergunte(cPerg,.T.)

	If Select("ADLG146P") > 0
		ADLG146P->(DbCloseArea())
	EndIf
	If cOpc = 'I'
		cQuery := " SELECT ZFA_TRANSP, SUM(ZFA_VALOR) ZFA_VALOR "
		cQuery += " FROM "+RetSqlName("ZFA")+" ZFA "
		cQuery += " WHERE ZFA_FILIAL = '"+FWxFilial("ZFA")+"' "
		cQuery += " AND ZFA_DTENTR BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "
		cQuery += " AND ZFA_TRANSP BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"' "
		cQuery += " AND ZFA_OCORRE IN ('011') "
		cQuery += " AND ZFA_TRANSP NOT IN ( "
		cQuery += " 	SELECT ZFA_TRANSP "
		cQuery += " 	FROM "+RetSqlName("ZFA")+" ZFA "
		cQuery += " 	WHERE ZFA_FILIAL = '"+FWxFilial("ZFA")+"' "
		cQuery += " 	AND ZFA_DTENTR BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "
		cQuery += " 	AND ZFA_OCORRE IN ('017') "
		cQuery += "     AND ZFA_PEDADT <> ' ' "
		cQuery += " 	AND ZFA.D_E_L_E_T_ = ' ' ) "
		cQuery += " AND ZFA.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY ZFA_TRANSP "
	Else
		cQuery := " SELECT  ZFA_TRANSP, ZFA_CARGA, ZFA_PEDADT, SUM(ZFA_VALOR) ZFA_VALOR "
		cQuery += " FROM "+RetSqlName("ZFA")+" ZFA "
		cQuery += " INNER JOIN "+RetSqlName("SC7")+" C7 ON C7_FILIAL=ZFA_FILIAL AND C7_NUM=ZFA_PEDADT AND C7.D_E_L_E_T_ = ' '
		cQuery += " WHERE ZFA_FILIAL = '"+FWxFilial("ZFA")+"' "
		cQuery += " AND ZFA_DTENTR BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "
		cQuery += " AND ZFA_TRANSP BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"' "
		cQuery += " AND ZFA_OCORRE IN ('017') "
		cQuery += " AND ZFA.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY ZFA_TRANSP, ZFA_CARGA, ZFA_PEDADT "
	Endif
	TcQuery cQuery New Alias "ADLG146P"
	
	If cOpc = 'I'
		sOcorAD  := Alltrim(SuperGetMv( "MV_#ADL467" , .F. , '017' , ) )
	Else
		sOcorAD  := Alltrim(SuperGetMv( "MV_#ADL46A" , .F. , '018' , ) )
	Endif

	While ADLG146P->( !Eof() )
		if (ADLG146P->ZFA_VALOR*0.4) >= nVlrMin .OR. cOpc = 'E'
			cQuery := " SELECT TOP 1 ZFA_CARGA, ZFA_ROTEIR, ZFA_TRANSP, ZFA_LOJTRA, ZFA_NMTRAN, ZFA_VEICPG, ZFA_DTENTR "
			cQuery += " FROM ZFA010 ZFA "
			cQuery += " WHERE ZFA_FILIAL = '"+FWxFilial("ZFA")+"' "
			cQuery += " AND ZFA_DTENTR BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "
			cQuery += " AND ZFA_OCORRE IN ('011') AND ZFA_TRANSP = '"+ADLG146P->ZFA_TRANSP+"' "
			cQuery += " AND ZFA.D_E_L_E_T_ = ' ' "
			cQuery += " ORDER BY ZFA_CARGA DESC "
			If Select("ADLG146W") > 0
				ADLG146W->(DbCloseArea())		
			EndIf
			TcQuery cQuery New Alias "ADLG146W"
			dbSelectArea("ZF7")
			dbSetOrder(1)
			If dbSeek( FWxFilial("ZF7") + sOcorAD )
				sDscOcos := ZF7->ZF7_DESC
				sTpOcorr := ZF7->ZF7_DBCD
			Endif	
			If (ADLG146P->ZFA_VALOR*0.4) > nMinCte
				sNCteEm := (ADLG146P->ZFA_VALOR*0.4) / nMinCte
				sNCteEm := ROUND(sNCteEm,0)
			Else
				sNCteEm := 1
			Endif 
			RecLock("ZFA",.T.)
				ZFA->ZFA_FILIAL := FWxFilial("ZFA")
				ZFA->ZFA_CARGA  := ADLG146W->ZFA_CARGA
				ZFA->ZFA_ROTEIR := ADLG146W->ZFA_ROTEIR
				ZFA->ZFA_TRANSP := ADLG146W->ZFA_TRANSP
				ZFA->ZFA_LOJTRA := ADLG146W->ZFA_LOJTRA
				ZFA->ZFA_NMTRAN := ADLG146W->ZFA_NMTRAN
				ZFA->ZFA_DATA   := Date()
				ZFA->ZFA_OCORRE := sOcorAD
				ZFA->ZFA_DC     := sTpOcorr
				ZFA->ZFA_DESCOC := sDscOcos
				ZFA->ZFA_VALOR  := IIF( cOpc='I', (ADLG146P->ZFA_VALOR*0.4) , ADLG146P->ZFA_VALOR )
				ZFA->ZFA_DATAIN := Date()
				ZFA->ZFA_HORA   := Time()
				ZFA->ZFA_VA     := 'Varejo'
				ZFA->ZFA_TPMOV  := 'A'
				ZFA->ZFA_APRMOV := 'N'
				ZFA->ZFA_FECHA  := 'N'
				ZFA->ZFA_VEICUL := ADLG146W->ZFA_VEICPG
				ZFA->ZFA_VEICPG := ADLG146W->ZFA_VEICPG
				ZFA->ZFA_DTENTR := STOD(ADLG146W->ZFA_DTENTR)
				ZFA->ZFA_OBS    := 'Necessแrio emissใo de '+ Alltrim(Str( sNCteEm )) +', Ct-e'
				lGerouA := .T.
			MsUnlock()
			cRecnoZF := Recno()
			dbSelectArea("SA2")
			dbSetOrder(1)
			If DbSeek( FWxFilial("SA2") + ADLG146W->ZFA_TRANSP + ADLG146W->ZFA_LOJTRA )
				cCondPG  := SA2->A2_COND
				cDestWF  := Alltrim(SA2->A2_EMAIL)
				cCopiaWF := Alltrim(SA2->A2_XMAILCT)+';'+Alltrim(UsrRetMail(__cUserID))
			Endif
			IF cOpc = 'I'
				//cNumPc := GetSXENum("SC7","C7_NUM")
				cNumPc := u_SXESXF("SC7") // @history ticket    3873 - Fernando Macieira - 23/11/2020 - Projeto - Contrato e Controle de Entradas - Sใo Carlos
			Else
				dbSelectArea("SC7")
				dbSetOrder(1)
				if dbSeek( FWxFilial("SC7") + ADLG146P->ZFA_PEDADT )
					cNumPc := SC7->C7_NUM
				Else
					cNumPc := ADLG146P->ZFA_PEDADT
				EndIf
			EndIf
				
			aadd(aCab,{"C7_NUM" 	,cNumPc    })
			aadd(aCab,{"C7_EMISSAO" ,Date()    })
			aadd(aCab,{"C7_FORNECE" ,SA2->A2_COD })
			aadd(aCab,{"C7_LOJA" 	,SA2->A2_LOJA })
			aadd(aCab,{"C7_COND"	,cCondPG   })
			aadd(aCab,{"C7_CONTATO" ,""        })
			aadd(aCab,{"C7_FILENT"  ,FWxFilial("SC7") })

			aLinha := {}
			aadd(aLinha,{"C7_PRODUTO" 	,sProdPC            ,Nil})
			aadd(aLinha,{"C7_QUANT" 	,1                  ,Nil})
			aadd(aLinha,{"C7_PRECO" 	,(ADLG146P->ZFA_VALOR*0.4) ,Nil})
			aadd(aLinha,{"C7_TOTAL" 	,(ADLG146P->ZFA_VALOR*0.4) ,Nil})
			aadd(aLinha,{"C7_CC" 		,sCCPed             ,Nil})
			aadd(aLinha,{"C7_LOCAL" 	,'99'               ,Nil})
			aadd(aLinha,{"C7_CONTA" 	,sNumCta            ,Nil})
			aadd(aLinha,{"C7_ITEMCTA" 	,sIteCta            ,Nil})
			aadd(aLinha,{"C7_CLVL"      ,sClvlPC            ,Nil})
			aadd(aLinha,{"C7_XRESPON" 	,AllTrim(cUserName) ,Nil})
			aadd(aLinha,{"C7_XTIPCTE" 	,'CTE'              ,Nil})  
			if cOpc = 'E'
				aadd(aLinha,{"C7_REC_WT",SC7->(RECNO()) ,Nil})
			EndIf
			
			aadd(aItens,aLinha)

			lMsErroAuto := .F.                    
			if cOpc = 'I'
				MATA120(1,aCab,aItens,3)
			Else
				MATA120(1,aCab,aItens,5)
			EndIf

			If lMsErroAuto   
				MostraErro()
			Else 
				ConfirmSX8()
				dbSelectArea("ZFA")
				if cOpc = 'I'
					dbGoto(cRecnoZF)
					RecLock("ZFA",.F.)
						ZFA->ZFA_PEDADT := cNumPc
					MsUnlock()
				Else
					dbSetOrder(10) //ZFA_FILIAL, ZFA_CARGA, ZFA_PEDADT
					If dbSeek( FWxFilial("ZFA") + ADLG146W->ZFA_CARGA + cNumPc )
						RecLock("ZFA",.F.)
							ZFA->ZFA_PEDADT := ''
							ZFA->ZFA_APRMOV := 'N'
						MsUnlock()
					Endif
				Endif
			Endif	
			Pergunte(cPerg,.F.)
			IF !Empty(cDestWF) .AND. cOpc = 'I'
				wQuery := " SELECT F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO "
				wQuery += " FROM "+RetSqlName("SF2")+" F2 "
				wQuery += " WHERE F2_FILIAL = '"+FWxFilial("SF2")+"' "
				wQuery += " AND F2_TRANSP = '"+ADLG146P->ZFA_TRANSP+"' "
				wQuery += " AND F2_EMISSAO BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "
				wQuery += " AND F2.D_E_L_E_T_ = ' ' "
				If Select("ADLG146N") > 0
					ADLG146N->(DbCloseArea())		
				EndIf
				TcQuery wQuery New Alias "ADLG146N"
				While ADLG146N->(!Eof())
					Aadd( aNfwfTrp , { ADLG146N->F2_FILIAL,ADLG146N->F2_DOC,ADLG146N->F2_SERIE,ADLG146N->F2_CLIENTE,ADLG146N->F2_LOJA,ADLG146N->F2_EMISSAO } )
					MV_PAR01 := ADLG146N->F2_DOC
					MV_PAR02 := ADLG146N->F2_DOC
					MV_PAR03 := ADLG146N->F2_SERIE
					MV_PAR04 := 2
					MV_PAR05 := 2
					oDanfe := FWMSPrinter():New(ADLG146N->F2_DOC,6,.F.,,.T.)
					oDanfe:SetPortrait()
					oDanfe:SetPaperSize(9)
					oDanfe:SetMargin(60,60,60,60)
					oDanfe:cPathPDF := cARMLOCA
					oDanfe:SetViewPDF(.F.)
					PixelX := oDanfe:nLogPixelX()
					PixelY := oDanfe:nLogPixelY()
					DanfePro1(@oDanfe,,"000001",,,.F.)
					oDanfe:Preview()
					FreeObj(oDanfe)
					oDanfe := Nil
					ADLG146N->(DbSkip())
				End 
				Pergunte(cPerg,.F.)

				cMsg += "<html>"
				cMsg += "<body>"
				cMsg += "<div style='text-align: left;'>"
				cMsg += "<p style='font-size: 16px; font-variant-numeric: normal; font-variant-east-asian: normal;'>"
				cMsg += "<span style='font-size: 14px;'><span style='font-family: verdana,geneva,sans-serif;'>"+IIF( TIME()>'12:00:00','Boa Tarde','Bom Dia' )+",</span></span></p>"
				cMsg += "<p style='font-size: 16px; font-variant-numeric: normal; font-variant-east-asian: normal;'>"
				cMsg += "<span style='font-size: 14px;'><span style='font-family: verdana,geneva,sans-serif;'>Segue em anexo a nota de refer&ecirc;ncia para emiss&atilde;o Ct-e.</span></span></p>"
				cMsg += "<p style='font-size: 16px; font-variant-numeric: normal; font-variant-east-asian: normal;'>"
				cMsg += "<span style='font-size: 14px;'><span style='font-family: verdana,geneva,sans-serif;'>Ser&atilde;o necessario a emiss&atilde;o de <strong>"+Alltrim(Str( sNCteEm ))+"</strong> Ct-e, abaixo os numeros de Nota Fiscal para Referenciar o Ct-e e os valores de cada Ct-e,</span></span></p>"
				cMsg += "<p style='font-size: 16px; font-variant-numeric: normal; font-variant-east-asian: normal;'>"
				nVlrpCte := (ADLG146P->ZFA_VALOR*0.4) / sNCteEm
				For wf:=1 to sNCteEm
					cMsg += "<span style='font-size: 14px;'><span style='font-family: verdana,geneva,sans-serif;'><strong>"+Alltrim(Str(wf))+"</strong> - N&uacute;mero:&nbsp;<strong>"+aNfwfTrp[wf][2]+"</strong>&nbsp;Serie:&nbsp;<strong>"+aNfwfTrp[wf][3]+"</strong>, &nbsp;Valor para emissใo do Ct-e, R$ <strong>"+Transform( nVlrpCte , X3Picture( "ZFA_VALOR" ) )+"</strong> <br/>"
					cMsg += "<br/>"
					CpyT2S( cARMLOCA + aNfwfTrp[wf][2] + '.pdf' , cCompCam , .F. )
					aAdd( aAnexo , { cCompCam + aNfwfTrp[wf][2] + '.pdf'} )
				Next 
				cMsg += "Pedido de Compra gerado para esse Adiantamento:&nbsp;<strong>"+cNumPc+"</strong>, por favor, informar esse numero na emissใo do Ct-e<br />"
				cMsg += "<br />"
				cMsg += "Receberemos os Cte&#39;s at&eacute; dia "+DtoC(MV_PAR03)+" ( "+ Alltrim(DiaSemana( MV_PAR03 ))+" ) &agrave;s 16:00hrs. O pagamento ser&aacute; programado entre os dias "+DtoC(MV_PAR04)+" e "+DtoC(MV_PAR05)+" de outubro.</span></span></p>"
				cMsg += "<p style='font-size: 16px; font-variant-numeric: normal; font-variant-east-asian: normal;'>"
				cMsg += "<span style='font-size: 14px;'><span style='font-family: verdana,geneva,sans-serif;'><strong>Avisar mediante alguma diverg&ecirc;ncia ou d&uacute;vida.</strong><br />"
				cMsg += "<br />"
				cMsg += "<span style='color: rgb(255, 0, 0);'><strong><em>Obs.: Caso o Ct-e seja enviado fora do prazo haver&aacute; altera&ccedil;&atilde;o na data do pagamento.</em></strong></span></span></span></p>"
				cMsg += "<p style='font-size: 16px; font-variant-numeric: normal; font-variant-east-asian: normal;'>"
				cMsg += "&nbsp;</p>"
				cMsg += "<p style='font-size: 16px; font-variant-numeric: normal; font-variant-east-asian: normal;'>"
				cMsg += "<span style='font-size: 14px;'><span style='font-family: verdana,geneva,sans-serif;'><strong>Envio autom&aacute;tico pelo sistema de Controle de Frete &ndash; Ad&rsquo;oro</strong></span></span></p>"
				cMsg += "</div>"
				cMsg += "<p>"
				cMsg += "&nbsp;</p>"
				cMsg += "</body>"
				cMsg += "</html>"

				U_F50En2WF( cDestWF , cCopiaWF , cAssunto , cMsg , aAnexo )

				For wf:=1 to len(aNfwfTrp)
					FERASE( cARMLOCA + aNfwfTrp[wf][2] + '.pdf' )
				Next
				For wf:=1 to len(aAnexo)
					FERASE( aAnexo[wf][1] )
				Next
			Endif
		Endif
		ADLG146P->( DbSkip() )
		aCab   := {}
		aItens := {}
		aLinha := {}
	End
	If lGerouA
		If cOpc = 'I'
			ApMsgInfo('Adiantamento de frete Gerado com Sucesso!','Adiantamento de frete')
		Else
			ApMsgInfo('Adiantamento de frete Estornado com Sucesso!','Adiantamento de frete')
		Endif
	Else 
		If cOpc = 'I'
			ApMsgInfo('Jแ Existe adiantamento de frete Gerado nesse Periodo!','Adiantamento de frete')
		Else 
			ApMsgInfo('Nใo Existe adiantamento de frete Gerado nesse Periodo!','Adiantamento de frete')
		Endif
	Endif
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLG0464 บ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  21/01/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ gera consumo de combustivel                                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ADLG0464( MVPAR01 , MVPAR02 , cVeicPag )
	
	Local cQuery   := ''
	Local cOcorAB  := Alltrim(SuperGetMv( "MV_#ADL46D" , .F. , '010' , ) )
	Local cOcorFt  := Alltrim(SuperGetMv( "MV_#ADL46E" , .F. , '011' , ) )
	Local lOcorAB  := .F.
	Local cTabFrt  := ''
	Local sTpOcorr := ''
	Local sDscOcos := ''
	Local cNumCrgF := ''
	Local cNCrgAbs := ''
	Local cCodTrn  := ''
	Local cLojTrn  := ''
	Local cNomTrn  := ''

	cQuery := " SELECT ZBB_PLACA, ZBB_BOMBA, SUM(ZBB_VOLUME) ZBB_VOLUME "
	cQuery += " FROM "+RetSqlName("ZBB")+" ZBB "
	cQuery += " WHERE ZBB_FILIAL = '" + FWxFilial("ZBB") + "' AND ZBB_DTINI >= '"+DtoS(MVPAR01)+"' AND ZBB_DTFIM <= '"+DtoS(MVPAR02)+"' " //ticket 70750 - Everson - 07/04/2022.
	cQuery += " AND ZBB_PLACA = '"+cVeicPag+"' "
	cQuery += " AND ZBB.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY ZBB_PLACA, ZBB_BOMBA "
	If Select("ZBBTMP") > 0
		ZBBTMP->(DbCloseArea())		
	EndIf
	TcQuery cQuery New Alias "ZBBTMP"

	cQuery := " SELECT ZFA_CARGA, ZFA_VEICPG, ZFA_TRANSP, ZFA_LOJTRA, ZFA_NMTRAN, ZFA_TABFRT, ZFA_OCORRE, ZFA_VALOR, ZFA_ABAUNI, ZFA_ABALTR, ZFA_FECHA, R_E_C_N_O_  "
	cQuery += " FROM "+RetSqlName("ZFA")+" ZFA "
	cQuery += " WHERE ZFA_FILIAL = '"+FWxFilial("ZFA")+"' "
	cQuery += " AND ZFA_DTENTR >= '"+DtoS(MVPAR01)+"' AND ZFA_DTENTR <= '"+DtoS(MVPAR02)+"' "
	cQuery += " AND ZFA_VEICPG = '"+ZBBTMP->ZBB_PLACA+"' "
	cQuery += " AND ZFA_OCORRE IN ('"+cOcorAB+"','"+cOcorFt+"') "
	cQuery += " AND ZFA.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY ZFA_OCORRE "
	If Select("ZFATMP") > 0
		ZFATMP->(DbCloseArea())		
	EndIf
	TcQuery cQuery New Alias "ZFATMP"

	While ZFATMP->(!Eof())
		If ZFATMP->ZFA_OCORRE = '010'
			lOcorAB := .T.
			cNCrgAbs := ZFATMP->ZFA_CARGA
		Endif
		if !Empty(ZFATMP->ZFA_TABFRT)
			cTabFrt := ZFATMP->ZFA_TABFRT
		Endif
		cNumCrgF := ZFATMP->ZFA_CARGA
		cCodTrn  := ZFATMP->ZFA_TRANSP
		cLojTrn  := ZFATMP->ZFA_LOJTRA
		cNomTrn  := ZFATMP->ZFA_NMTRAN
		ZFATMP->(dbSkip())
	End

	If lOcorAB
		dbSelectArea("ZF5")
		dbSetOrder(1)
		if dbSeek( FWxFilial("ZF5") + cTabFrt )
			if !Empty(ZF5->ZF5_CBTP01) .and. !Empty(ZF5->ZF5_CBTP02)
				dbSelectArea("ZFA")
				dbSetOrder(7) // ZFA_FILIAL, ZFA_CARGA, ZFA_OCORRE
				If dbSeek( FWxFilial("ZFA") + cNCrgAbs + cOcorAB )
					RecLock("ZFA",.F.)
						ZFA->ZFA_VALOR  := IIF( ZBBTMP->ZBB_BOMBA = 'S500', ZF5->ZF5_CBTP01*ZBBTMP->ZBB_VOLUME , ZF5->ZF5_CBTP02*ZBBTMP->ZBB_VOLUME )
						ZFA->ZFA_ABAUNI := IIF( ZBBTMP->ZBB_BOMBA = 'S500', ZF5->ZF5_CBTP01 , ZF5->ZF5_CBTP02 )
						ZFA->ZFA_ABALTR := ZBBTMP->ZBB_VOLUME
					MsUnLock()
				Else
					ApMsgInfo('Nใo foi atualizado o valor do combustivel','Consumo de Combustivel')
				Endif
			Else
				ApMsgInfo('Na Tabela de Frete: '+cTabFrt+', nใo foi informado o valor do combustivel','Consumo de Combustivel')
			Endif
		Else
			ApMsgInfo('A Tabela de Frete: '+cTabFrt+', nใo foi localizada, nใo serแ possivel calcular o valor do combustivel','Consumo de Combustivel')
		EndIf
	Else
		dbSelectArea("ZF7")
		dbSetOrder(1)
		If dbSeek( FWxFilial("ZF7") + cOcorAB )
			sTpOcorr := ZF7->ZF7_DBCD
			sDscOcos := ZF7->ZF7_DESC
		Endif
		RecLock("ZFA",.T.)
			ZFA->ZFA_FILIAL := FWxFilial("ZFA")
			ZFA->ZFA_CARGA  := cNumCrgF
			ZFA->ZFA_TRANSP := cCodTrn
			ZFA->ZFA_LOJTRA := cLojTrn
			ZFA->ZFA_NMTRAN := cNomTrn
			ZFA->ZFA_DATA   := Date()
			ZFA->ZFA_OCORRE := cOcorAB
			ZFA->ZFA_DC     := sTpOcorr
			ZFA->ZFA_DESCOC := sDscOcos
			ZFA->ZFA_VALOR  := IIF( ZBBTMP->ZBB_BOMBA = 'S500', ZF5->ZF5_CBTP01*ZBBTMP->ZBB_VOLUME , ZF5->ZF5_CBTP02*ZBBTMP->ZBB_VOLUME )
			ZFA->ZFA_ABAUNI := IIF( ZBBTMP->ZBB_BOMBA = 'S500', ZF5->ZF5_CBTP01 , ZF5->ZF5_CBTP02 )
			ZFA->ZFA_ABALTR := ZBBTMP->ZBB_VOLUME
			ZFA->ZFA_DATAIN := Date()
			ZFA->ZFA_HORA   := Time()
			ZFA->ZFA_VA     := 'Varejo'
			ZFA->ZFA_TPMOV  := 'A'
			ZFA->ZFA_APRMOV := 'N'
			ZFA->ZFA_FECHA  := 'N'
			ZFA->ZFA_VEICUL := ZBBTMP->ZBB_PLACA
			ZFA->ZFA_VEICPG := ZBBTMP->ZBB_PLACA
			ZFA->ZFA_OBS    := 'Consumo de Combustivel integrado do CTAPLUS'
			lGerouA := .T.
		MsUnlock()
	Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MontaPerg() 
                                 
	Private bValid := Nil 
	Private cF3	   := Nil
	Private cSXG   := Nil
	Private cPyme  := Nil
	Private cPerg  := "ADLG146P"

    	xPutSx1(cPerg,'01','Dt Entrega De  ?','Dt Entrega De  ?','Dt Entrega De  ?','mv_ch1','D',8,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR01')
		xPutSx1(cPerg,'02','Dt Entrega Ate ?','Dt Entrega Ate ?','Dt Entrega Ate ?','mv_ch2','D',8,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR02')
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MntPerg(cPerg)
                                 
	Private bValid := Nil 
	Private cF3	   := Nil
	Private cSXG   := Nil
	Private cPyme  := Nil

		xPutSx1(cPerg,'01','Dt Entrega De  ?'   ,'Dt Entrega De  ?'   ,'Dt Entrega De  ?'   ,'mv_ch1','D',8,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR01')
		xPutSx1(cPerg,'02','Dt Entrega Ate ?'   ,'Dt Entrega Ate ?'   ,'Dt Entrega Ate ?'   ,'mv_ch2','D',8,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR02')
		xPutSx1(cPerg,'03','Transportador De  ?','Transportador De  ?','Transportador De  ?','mv_ch3','C',6,0,0,'G',bValid,"SA4",cSXG,cPyme,'MV_PAR03')
		xPutSx1(cPerg,'04','Transportador Ate ?','Transportador Ate ?','Transportador Ate ?','mv_ch4','C',6,0,0,'G',bValid,"SA4",cSXG,cPyme,'MV_PAR04')
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MntAPerg(cPerg) 
                                 
	Private bValid := Nil 
	Private cF3	   := Nil
	Private cSXG   := Nil
	Private cPyme  := Nil

    	xPutSx1(cPerg,'01','Dt Entrega De  ?'          ,'Dt Entrega De  ?'          ,'Dt Entrega De  ?'          ,'mv_ch1','D',8,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR01')
		xPutSx1(cPerg,'02','Dt Entrega Ate ?'          ,'Dt Entrega Ate ?'          ,'Dt Entrega Ate ?'          ,'mv_ch2','D',8,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR02')
		xPutSx1(cPerg,'03','Data Limite para Entrega ?','Data Limite para Entrega ?','Data Limite para Entrega ?','mv_ch3','D',8,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR03')
		xPutSx1(cPerg,'04','Data Pagamento De ?'       ,'Data Pagamento De ?'       ,'Data Pagamento De ?'       ,'mv_ch4','D',8,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR04')
		xPutSx1(cPerg,'05','Data Pagamento Ate ?'      ,'Data Pagamento Ate ?'      ,'Data Pagamento Ate ?'      ,'mv_ch5','D',8,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR05')
		xPutSx1(cPerg,'06','Transportador De  ?'       ,'Transportador De  ?'       ,'Transportador De  ?'       ,'mv_ch6','C',6,0,0,'G',bValid,"SA4",cSXG,cPyme,'MV_PAR06')
		xPutSx1(cPerg,'07','Transportador Ate ?'       ,'Transportador Ate ?'       ,'Transportador Ate ?'       ,'mv_ch7','C',6,0,0,'G',bValid,"SA4",cSXG,cPyme,'MV_PAR07')
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function xPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,; 
     cF3, cGrpSxg,cPyme,cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,; 
     cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp) 

	LOCAL aArea := GetArea() 
	Local cKey 
	Local lPort := .f. 
	Local lSpa  := .f. 
	Local lIngl := .f. 

	cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."

	cPyme   := Iif( cPyme   == Nil, "" , cPyme   ) 
	cF3     := Iif( cF3     == NIl, "" , cF3     ) 
	cGrpSxg := Iif( cGrpSxg == Nil, "" , cGrpSxg ) 
	cCnt01  := Iif( cCnt01  == Nil, "" , cCnt01  ) 
	cHelp   := Iif( cHelp   == Nil, "" , cHelp   ) 

	dbSelectArea( "SX1" ) 
	dbSetOrder( 1 ) 

	// Ajusta o tamanho do grupo. Ajuste emergencial para valida็ใo dos fontes. 
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " ) 

	If !( DbSeek( cGrupo + cOrdem )) 
		cPergunt := If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt) 
		cPerSpa := If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa) 
		cPerEng := If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng) 

		Reclock( "SX1" , .T. ) 

		Replace X1_GRUPO   With cGrupo 
		Replace X1_ORDEM   With cOrdem 
		Replace X1_PERGUNT With cPergunt 
		Replace X1_PERSPA  With cPerSpa 
		Replace X1_PERENG  With cPerEng 
		Replace X1_VARIAVL With cVar 
		Replace X1_TIPO    With cTipo 
		Replace X1_TAMANHO With nTamanho 
		Replace X1_DECIMAL With nDecimal 
		Replace X1_PRESEL  With nPresel 
		Replace X1_GSC     With cGSC 
		Replace X1_VALID   With cValid 

		Replace X1_VAR01   With cVar01 

		Replace X1_F3      With cF3 
		Replace X1_GRPSXG  With cGrpSxg 

		If Fieldpos("X1_PYME") > 0 
			If cPyme != Nil 
				Replace X1_PYME With cPyme 
			Endif 
		Endif 
		Replace X1_CNT01   With cCnt01 
		If cGSC == "C"               // Mult Escolha 
			Replace X1_DEF01   With cDef01 
			Replace X1_DEFSPA1 With cDefSpa1 
			Replace X1_DEFENG1 With cDefEng1 

			Replace X1_DEF02   With cDef02 
			Replace X1_DEFSPA2 With cDefSpa2 
			Replace X1_DEFENG2 With cDefEng2 

			Replace X1_DEF03   With cDef03 
			Replace X1_DEFSPA3 With cDefSpa3 
			Replace X1_DEFENG3 With cDefEng3 

			Replace X1_DEF04   With cDef04 
			Replace X1_DEFSPA4 With cDefSpa4 
			Replace X1_DEFENG4 With cDefEng4 

			Replace X1_DEF05   With cDef05 
			Replace X1_DEFSPA5 With cDefSpa5 
			Replace X1_DEFENG5 With cDefEng5 
		Endif 
		Replace X1_HELP With cHelp 
		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa) 
		MsUnlock() 
	Else 
	lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT) 
	lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA) 
	lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG) 
	If lPort .Or. lSpa .Or. lIngl 
			RecLock("SX1",.F.) 
			If lPort 
			SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?" 
			EndIf 
			If lSpa 
				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?" 
			EndIf 
			If lIngl 
				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?" 
			EndIf 
			SX1->(MsUnLock()) 
		EndIf 
	Endif 
	RestArea( aArea ) 
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DANFEPro1( oDanfe , lEnd , cIdEnt , cVal1 , cVal2 , lExistNfe , lIsLoja , nTipo )

	Local aArea      := GetArea()
	Local aAreaSF3   := {}
	Local aNotas     := {}
	Local aXML       := {}
	Local aAutoriza  := {}
	Local cNaoAut    := ""

	Local cAliasSF3  := "SF3"
	Local cWhere     := ""
	Local cAviso     := ""
	Local cCodRetNFE := ""
	Local cCodRetSF3 := ""
	Local cMsgSF3    := ""
	Local cErro      := ""
	Local cAutoriza  := ""
	Local cModalidade:= ""
	Local cChaveSFT  := ""
	Local cAliasSFT  := "SFT"
	Local cCondicao	 := ""
	Local cIndex	 := ""
	Local cChave	 := ""
	Local lQuery     := .F.
	Local nX         := 0
	Local nI		 := 0
	Local oNfe
	Local nLenNotas
	Local lImpDir	:=GetNewPar("MV_IMPDIR",.F.)
	Local nLenarray	:= 0
	Local nCursor	:= 0
	Local lBreak	:= .F.
	Local aGrvSF3   := {}
	Local lImpSimp  := .F.
	Local lUsaColab	:=  UsaColaboracao("1")
	Local lMVGfe	:= GetNewPar( "MV_INTGFE", .F. ) // Se tem integra็ใo com o GFE
	Local lSdoc  	:= TamSx3("F3_SERIE")[1] == 14
	Local cSerie 	:= ""
	Local cSerId 	:= ""
	Local cFrom 	:= ""
	Local cxFilial	:= ""
	Local cCampos	:= ""
	Local lFirst 	:= .T.
	local lChave	:= .F.
	Local cChavSF3	:= ""

	Default lIsLoja	:= .F.
	Default nTipo	:= 0

	MV_PAR01 := AllTrim(MV_PAR01)
	lImpSimp := ( !Empty( MV_PAR06 ) .and. MV_PAR06 == 1 )

	If !lImpDir
		dbSelectArea("SF3")
		dbSetOrder(5)
		#IFDEF TOP

			If MV_PAR04==1

				If lSdoc
					cCampos += ", SF3.F3_SDOC"
					cSerie := Padr(MV_PAR03,TamSx3("F3_SDOC")[1])
					cWhere := "%SubString(SF3.F3_CFO,1,1) < '5' AND SF3.F3_FORMUL='S' AND SF3.F3_SDOC = '"+ cSerie + "' AND SF3.F3_ESPECIE = 'SPED'"
				Else
					cSerie := Padr(MV_PAR03,TamSx3("F3_SERIE")[1])
					cWhere := "%SubString(SF3.F3_CFO,1,1) < '5' AND SF3.F3_FORMUL='S' AND SF3.F3_SERIE = '"+ cSerie + "' AND SF3.F3_ESPECIE = 'SPED'"
				Endif

			ElseIf MV_PAR04==2

				If lSdoc
					cCampos += ", SF3.F3_SDOC"
					cSerie := Padr(MV_PAR03,TamSx3("F3_SDOC")[1])
					cWhere := "%SubString(SF3.F3_CFO,1,1) >= '5' AND SF3.F3_SDOC = '"+ cSerie + "' AND SF3.F3_ESPECIE = 'SPED'"
				Else
					cSerie := Padr(MV_PAR03,TamSx3("F3_SERIE")[1])
					cWhere := "%SubString(SF3.F3_CFO,1,1) >= '5' AND SF3.F3_SERIE = '"+ cSerie + "' AND SF3.F3_ESPECIE = 'SPED'"
				Endif
			Else

				If lSdoc
					cCampos += ", SF3.F3_SDOC"
					cSerie := Padr(MV_PAR03,TamSx3("F3_SDOC")[1])
					cWhere := "%SF3.F3_SDOC = '"+ cSerie + "' AND SF3.F3_ESPECIE = 'SPED'"
				Else
					cSerie := Padr(MV_PAR03,TamSx3("F3_SERIE")[1])
					cWhere := "%SF3.F3_SERIE = '"+ cSerie + "' AND SF3.F3_ESPECIE = 'SPED'"
				Endif

			EndIf
			If lSdoc
				If !Empty(MV_PAR07) .Or. !Empty(MV_PAR08)
					cWhere += " AND (SF3.F3_EMISSAO >= '"+ SubStr(DTOS(MV_PAR07),1,4) + SubStr(DTOS(MV_PAR07),5,2) + SubStr(DTOS(MV_PAR07),7,2) + "' AND SF3.F3_EMISSAO <= '"+ SubStr(DTOS(MV_PAR08),1,4) + SubStr(DTOS(MV_PAR08),5,2) + SubStr(DTOS(MV_PAR08),7,2) + "')"
				EndIF
			EndIF

			cWhere += "%"

			cAliasSF3 := GetNextAlias()
			lQuery    := .T.

			If Empty(cCampos)
				cCampos := "%%"
			Else
				cCampos := "% " + cCampos + " %"
			Endif

			BeginSql Alias cAliasSF3

				COLUMN F3_ENTRADA AS DATE
				COLUMN F3_DTCANC AS DATE

				SELECT	F3_FILIAL,F3_ENTRADA,F3_NFELETR,F3_CFO,F3_FORMUL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC
				%Exp:cCampos%
				FROM %Table:SF3% SF3
				WHERE
				SF3.F3_FILIAL = %xFilial:SF3% AND
					SF3.F3_SERIE = %Exp:MV_PAR03% AND
				SF3.F3_NFISCAL >= %Exp:MV_PAR01% AND
				SF3.F3_NFISCAL <= %Exp:MV_PAR02% AND
				%Exp:cWhere% AND
				SF3.F3_DTCANC = %Exp:Space(8)% AND
				SF3.%notdel%
				ORDER BY F3_NFISCAL
			EndSql

		#ELSE
			cIndex    		:= CriaTrab(NIL, .F.)
			cChave			:= IndexKey(6)
			cCondicao 		:= 'F3_FILIAL == "' + xFilial("SF3") + '" .And. '
			cCondicao 		+= 'SF3->F3_SERIE =="'+ MV_PAR03+'" .And. '
			cCondicao 		+= 'SF3->F3_NFISCAL >="'+ MV_PAR01+'" .And. '
			cCondicao		+= 'SF3->F3_NFISCAL <="'+ MV_PAR02+'" .And. '
			cCondicao		+= 'SF3->F3_ESPECIE = "SPED" .And. '
			cCondicao		+= 'Empty(SF3->F3_DTCANC)'
			IndRegua(cAliasSF3, cIndex, cChave, , cCondicao)
			nIndex := RetIndex(cAliasSF3)
					DBSetIndex(cIndex + OrdBagExt())
					DBSetOrder(nIndex + 1)
			DBGoTop()
		#ENDIF
		If MV_PAR04==1
			cWhere := "SubStr(F3_CFO,1,1) < '5' .AND. F3_FORMUL=='S'"
		Elseif MV_PAR04==2
			cWhere := "SubStr(F3_CFO,1,1) >= '5'"
		Else
			cWhere := ".T."
		EndIf

		If lSdoc
			cSerId := (cAliasSF3)->F3_SDOC
		Else
			cSerId := (cAliasSF3)->F3_SERIE
		EndIf

		While !Eof() .And. xFilial("SF3") == (cAliasSF3)->F3_FILIAL .And.;
			cSerId == MV_PAR03 .And.;
			(cAliasSF3)->F3_NFISCAL >= MV_PAR01 .And.;
			(cAliasSF3)->F3_NFISCAL <= MV_PAR02

			dbSelectArea(cAliasSF3)
			If  Empty((cAliasSF3)->F3_DTCANC) .And. &cWhere //.And. AModNot((cAliasSF3)->F3_ESPECIE)=="55"

				If (SubStr((cAliasSF3)->F3_CFO,1,1)>="5" .Or. (cAliasSF3)->F3_FORMUL=="S") .And. aScan(aNotas,{|x| x[4]+x[5]+x[6]+x[7]==(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA})==0

					aadd(aNotas,{})
					aadd(Atail(aNotas),.F.)
					aadd(Atail(aNotas),IIF((cAliasSF3)->F3_CFO<"5","E","S"))
					aadd(Atail(aNotas),(cAliasSF3)->F3_ENTRADA)
					aadd(Atail(aNotas),(cAliasSF3)->F3_SERIE)
					aadd(Atail(aNotas),(cAliasSF3)->F3_NFISCAL)
					aadd(Atail(aNotas),(cAliasSF3)->F3_CLIEFOR)
					aadd(Atail(aNotas),(cAliasSF3)->F3_LOJA)

				EndIf
			EndIf

			dbSelectArea(cAliasSF3)
			dbSkip()

			If lSdoc
				cSerId := (cAliasSF3)->F3_SDOC
			Else
				cSerId := (cAliasSF3)->F3_SERIE
			EndIf

			If lEnd
				Exit
			EndIf
			If (cAliasSF3)->(Eof())
				aAreaSF3 := (cAliasSF3)->(GetArea())
				if lUsaColab
					aXml := GetXMLColab(aNotas,@cModalidade,lUsaColab)
				else
					aXml := GetXML(cIdEnt,aNotas,@cModalidade)
				endif

				nLenNotas := Len(aNotas)

				For nX := 1 To nLenNotas
					If !Empty(aXML[nX][2])
						If !Empty(aXml[nX])
							cAutoriza   := aXML[nX][1]
							cCodAutDPEC := aXML[nX][5]
							cCodRetNFE	:= aXML[nX][9]
							cCodRetSF3	:= iif ( Empty (cCodAutDPEC),cCodRetNFE,cCodAutDPEC )
							cMsgSF3		:= iif ( aXML[nX][10]<> Nil ,aXML[nX][10],"")
						Else
							cAutoriza   := ""
							cCodAutDPEC := ""
							cCodRetNFE	:= ""
							cCodRetSF3	:= ""
							cMsgSF3		:= ""
						EndIf
						If (!Empty(cAutoriza) .Or. !Empty(cCodAutDPEC) .Or. Alltrim(aXML[nX][8]) $ "2,5") .And. !cCodRetNFE $ RetCodDene()
							If aNotas[nX][02]=="E"
								DBClearFilter()
								dbSelectArea("SF1")
								dbSetOrder(1)
								If MsSeek(xFilial("SF1")+aNotas[nX][05]+aNotas[nX][04]+aNotas[nX][06]+aNotas[nX][07]) .And. SF1->(FieldPos("F1_FIMP")) <> 0 .And. Alltrim(aXML[nX][8])$"1,3,4,6,7" .or. ( Alltrim(aXML[nX][8]) $ "2,5"  .And. !Empty(cAutoriza) )
									RecLock("SF1")
									If !SF1->F1_FIMP$"D"
										SF1->F1_FIMP := "S"
									EndIf
									If SF1->(FieldPos("F1_CHVNFE")) > 0
										SF1->F1_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
									EndIf
									If SF1->(FieldPos("F1_HAUTNFE")) > 0 .and. SF1->(FieldPos("F1_DAUTNFE")) > 0 //grava a data e hora de autoriza็ใo da NFe
										SF1->F1_HAUTNFE := IIF(!Empty(aXML[nX][6]),SUBSTR(aXML[nX][6],1,5),"")
										SF1->F1_DAUTNFE	:= IIF(!Empty(aXML[nX][7]),aXML[nX][7],SToD("  /  /    "))
									EndIf
									MsUnlock()
								EndIf
							Else
								dbSelectArea("SF2")
								dbSetOrder(1)
								If MsSeek(xFilial("SF2")+aNotas[nX][05]+aNotas[nX][04]+aNotas[nX][06]+aNotas[nX][07]) .And. Alltrim(aXML[nX][8])$"1,3,4,6,7" .Or. ( Alltrim(aXML[nX][8]) $ "2,5"  .And. !Empty(cAutoriza) )
									RecLock("SF2")
									If !SF2->F2_FIMP$"D"
										SF2->F2_FIMP := "S"
									EndIf
									If SF2->(FieldPos("F2_CHVNFE")) > 0
										SF2->F2_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
									EndIf
									If SF2->(FieldPos("F2_HAUTNFE")) > 0 .and. SF2->(FieldPos("F2_DAUTNFE")) > 0 //grava a data e hota de autoriza็ใo da NFe
										SF2->F2_HAUTNFE := IIF(!Empty(aXML[nX][6]),SUBSTR(aXML[nX][6],1,5),"")
										SF2->F2_DAUTNFE	:= IIF(!Empty(aXML[nX][7]),aXML[nX][7],SToD("  /  /    "))
									EndIf
									MsUnlock()
									// Grava quando a nota for Transferencia entre filiais
									IF SF2->(FieldPos("F2_FILDEST"))> 0 .And. SF2->(FieldPos("F2_FORDES"))> 0 .And.SF2->(FieldPos("F2_LOJADES"))> 0 .And.SF2->(FieldPos("F2_FORMDES"))> 0 .And. !EMPTY (SF2->F2_FORDES)
									SF1->(dbSetOrder(1))
										If SF1->(MsSeek(SF2->F2_FILDEST+SF2->F2_DOC+SF2->f2_SERIE+SF2->F2_FORDES+SF2->F2_LOJADES+SF2->F2_FORMDES))
											If EMPTY(SF1->F1_CHVNFE)
												RecLock("SF1",.F.)
												SF1->F1_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
												MsUnlock()
											EndIf
										Endif
									EndiF
								ElseIf MsSeek(xFilial("SF2")+aNotas[nX][05]+aNotas[nX][04]+aNotas[nX][06]+aNotas[nX][07]) .And. Alltrim(aXML[nX][8])$"1,3,4,6" .Or. ( Alltrim(aXML[nX][8]) $ "2,5"  .And. cModalidade == "7" ) // Contingencia FSDA
									RecLock("SF2")
									SF2->F2_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
									MsUnlock()
								EndIf

								If ExistFunc("STFMMd5NS") //Fun็ใo do Controle de Lojas - Legisla็ใo PAF-ECF
									STFMMd5NS()
								EndIf
							EndIf
							dbSelectArea("SFT")
							dbSetOrder(1)
							If SFT->(FieldPos("FT_CHVNFE"))>0
								cChaveSFT	:=	(xFilial("SFT")+aNotas[nX][02]+aNotas[nX][04]+aNotas[nX][05]+aNotas[nX][06]+aNotas[nX][07])
								If MsSeek(cChaveSFT)
									Do While !(cAliasSFT)->(Eof ()) .And.;
										cChaveSFT==(cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA
										If (cAliasSFT)->FT_TIPOMOV $"S" .Or. ((cAliasSFT)->FT_TIPOMOV $"E" .And. (cAliasSFT)->FT_FORMUL=='S')
											RecLock("SFT")
											SFT->FT_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
											MsUnLock()
											//Array criado para gravar o SF3 no final, pois a tabela SF3 pode estah em processamento quando se trata de DBF ou AS/400.
											If aScan(aGrvSF3,{|aX|aX[1]+aX[2]+aX[3]+aX[4]+aX[5]==(cAliasSFT)->(FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_IDENTF3)})==0
												aAdd(aGrvSF3, {(cAliasSFT)->FT_SERIE,(cAliasSFT)->FT_NFISCAL,(cAliasSFT)->FT_CLIEFOR,(cAliasSFT)->FT_LOJA,(cAliasSFT)->FT_IDENTF3,(cAliasSFT)->FT_CHVNFE,cAutoriza,cCodRetSF3,cMsgSF3})
											EndIf
										EndIf
										DbSkip()
									EndDo
								EndIf
							EndIf
							// Grava quando a nota for Transferencia entre filiais
							IF SF1->(!EOF()) .And. SF2->(FieldPos("F2_FILDEST"))> 0 .And. SF2->(FieldPos("F2_FORDES"))> 0 .And.SF2->(FieldPos("F2_LOJADES"))> 0 .And.SF2->(FieldPos("F2_FORMDES"))> 0 .And. !EMPTY (SF2->F2_FORDES)
								SFT->(dbSetOrder(1))
								cChaveSFT := SF1->F1_FILIAL+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA
								If SFT->(MsSeek(cChaveSFT))
									Do While cChaveSFT == SFT->FT_FILIAL+"E"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA .And. !SFT->(Eof())
										RecLock("SFT")
										SFT->FT_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
										MsUnLock()
										//Array criado para gravar o SF3 no final, pois a tabela SF3 pode estah em processamento quando se trata de DBF ou AS/400.
										If aScan(aGrvSF3,{|aX|aX[1]+aX[2]+aX[3]+aX[4]+aX[5]==(cAliasSFT)->(FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_IDENTF3)})==0
											aAdd(aGrvSF3, {(cAliasSFT)->FT_SERIE,(cAliasSFT)->FT_NFISCAL,(cAliasSFT)->FT_CLIEFOR,(cAliasSFT)->FT_LOJA,(cAliasSFT)->FT_IDENTF3,(cAliasSFT)->FT_CHVNFE,cAutoriza,cCodRetSF3,cMsgSF3})
										EndIf
										SFT->(dbSkip())
									EndDo
								EndIf
							EndIf

							cAviso := ""
							cErro  := ""
							//-----------------------------------------------------------------------
							// Validacao para quando for TOTVS Colaboracao, pois o retorno do
							// xml sera o que vem da Neogrid, e nao o que enviamos.
							// Para que nao fosse alterado totalmente a estrutura do Objeto,
							// atribui a variavel oRetNF o retorno, e abaixo identifico se possui
							// o objeto NFEPROC, caso tenha, deixarei na mesma estrutura do legado.
							// @autor: Douglas Parreja	@since 30/10/2017
							//-----------------------------------------------------------------------
							oRetNF := XmlParser(aXML[nX][2],"_",@cAviso,@cErro)
							if type("oRetNF:_NFEPROC") <> "U"
								oNfe := WSAdvValue( oRetNF,"_NFEPROC","string",NIL,NIL,NIL,NIL,NIL)
							else
								oNfe := oRetNF
							endif
							oNfeDPEC := XmlParser(aXML[nX][4],"_",@cAviso,@cErro)
							If Empty(cAviso) .And. Empty(cErro)
								ImpDet(@oDanfe,oNFe,cAutoriza,cModalidade,oNfeDPEC,cCodAutDPEC,aXml[nX][6],aXml[nX][7],aNotas[nX],lImpSimp,nTipo)
								lExistNfe := .T.
							EndIf
							oNfe     := nil
							oNfeDPEC := nil

						ElseIf lIsLoja
							/* Se o Codigo de Retorno da SEFAZ esta preenchido e for maior que 200, entao houve rejeicao por parte da SEFAZ	*/
							If !Empty(aXML[nX][9]) .AND. Val(aXML[nX][9]) > 200

								RecLock("SF2",.F.)
								Replace SF2->F2_FIMP with "N"
								SF2->( MsUnlock() )

								cNaoAut := "A impressใo do DANFE referente ao Doc/S้rie " + SF2->F2_DOC + "/" + SF2->F2_SERIE + " NรO FOI REALIZADA pelo motivo abaixo:"
								cNaoAut += CRLF + "[" + aXML[nX][9] + ' - ' + aXML[nX][10] + "]"
								cNaoAut += CRLF + "Se possํvel, fa็a o ajuste e retransmita a NF-e."

								Aviso( "SPED", cNaoAut, {"Continuar"}, 3 )
							EndIf
						Else
							cNaoAut += SubStr(aNotas[nX][04],1,3)+aNotas[nX][05]+CRLF
						EndIf
					EndIf

				Next nX
				aNotas := {}

				RestArea(aAreaSF3)
				DelClassIntF()
			EndIf
		EndDo

		If !lQuery
			DBClearFilter()
			Ferase(cIndex+OrdBagExt())
		EndIf

		If !lIsLoja .AND. !Empty(cNaoAut)
			Aviso("SPED","As seguintes notas nใo foram autorizadas: "+CRLF+CRLF+cNaoAut,{"Ok"},3)
		EndIf

	ElseIf  lImpDir
		nLenarray := Val(Alltrim(MV_PAR02)) - Val(Alltrim(MV_PAR01))
		nCursor   := Val(MV_PAR01)

		While  !lBreak  .And. nLenarray >= 0

			If lFirst
				If MV_PAR04==1

					cxFilial := xFilial("SF1")
					cFrom	:=	"%"+RetSqlName("SF1")+" SF1 %"

					If lSdoc
						cCampos += "%SF1.F1_FILIAL FILIAL, SF1.F1_DOC DOC, SF1.F1_SERIE SERIE, SF1.F1_SDOC SDOC%"
						cSerie := Padr(MV_PAR03,TamSx3("F1_SDOC")[1])
						cWhere := "%SF1.D_E_L_E_T_= '' AND SF1.F1_FILIAL ='"+xFilial("SF1")+"' AND SF1.F1_DOC <='"+MV_PAR02+ "' AND SF1.F1_DOC >='" + MV_PAR01 + "' AND SF1.F1_SDOC ='"+ cSerie + "' AND SF1.F1_ESPECIE = 'SPED' AND SF1.F1_FORMUL = 'S' ORDER BY SF1.F1_DOC%"
					Else
						cCampos += "%SF1.F1_FILIAL FILIAL, SF1.F1_DOC DOC, SF1.F1_SERIE SERIE%"
						cSerie := Padr(MV_PAR03,TamSx3("F2_SERIE")[1])
						cWhere := "%SF1.D_E_L_E_T_= '' AND SF1.F1_FILIAL ='"+xFilial("SF1")+"' AND SF1.F1_DOC <='"+MV_PAR02+ "' AND SF1.F1_DOC >='" + MV_PAR01 + "' AND SF1.F1_SERIE ='"+ cSerie + "' AND SF1.F1_ESPECIE = 'SPED' AND SF1.F1_FORMUL = 'S' ORDER BY SF1.F1_DOC%"
					Endif

				ElseIf MV_PAR04==2

					cxFilial := xFilial("SF2")
					cFrom	:=	"%"+RetSqlName("SF2")+" SF2 %"

					If lSdoc
						cCampos += "%SF2.F2_FILIAL FILIAL, SF2.F2_DOC DOC, SF2.F2_SERIE SERIE, SF2.F2_SDOC SDOC%"
						cSerie := Padr(MV_PAR03,TamSx3("F2_SDOC")[1])
						cWhere := "%SF2.D_E_L_E_T_= '' AND SF2.F2_FILIAL ='"+xFilial("SF2")+"' AND SF2.F2_DOC <='"+MV_PAR02+ "' AND SF2.F2_DOC >='" + MV_PAR01 + "' AND SF2.F2_SDOC ='"+ cSerie + "' AND SF2.F2_ESPECIE = 'SPED' ORDER BY SF2.F2_DOC%"
					Else
						cCampos += "%SF2.F2_FILIAL FILIAL, SF2.F2_DOC DOC, SF2.F2_SERIE SERIE%"
						cSerie := Padr(MV_PAR03,TamSx3("F2_SERIE")[1])
						cWhere := "%SF2.D_E_L_E_T_= '' AND SF2.F2_FILIAL ='"+xFilial("SF2")+"' AND SF2.F2_DOC <='"+MV_PAR02+ "' AND SF2.F2_DOC >='" + MV_PAR01 + "' AND SF2.F2_SERIE ='"+ cSerie + "' AND SF2.F2_ESPECIE = 'SPED' ORDER BY SF2.F2_DOC%"
					Endif

				EndIf
			EndIf
			cAliasSFX := GetNextAlias()
			lQuery    := .T.
			lFirst    := .F.

			BeginSql Alias cAliasSFX
				SELECT
				%Exp:cCampos%
				FROM
				%Exp:cFrom%
				WHERE
				%Exp:cWhere%
			EndSql

			If lSdoc
				cSerId := (cAliasSFX)->SDOC
			Else
				cSerId := (cAliasSFX)->SERIE
			EndIf

			If Empty(cSerId) .Or. lEnd
				lBreak :=.T.
			EndIf

			While !Eof() .And. !lBreak .And. ;
				cxFilial == (cAliasSFX)->FILIAL .And.;
				cSerId == MV_PAR03 .And.;
				(cAliasSFX)->DOC >= MV_PAR01 .And.;
				(cAliasSFX)->DOC <= MV_PAR02

				aNotas := {}
				For nx:=1 To 20
					aadd(aNotas,{})
					aAdd(Atail(aNotas),.F.)
					aadd(Atail(aNotas),IIF(MV_PAR04==1,"E","S"))
					aAdd(Atail(aNotas),"")
					aadd(Atail(aNotas),(cAliasSFX)->SERIE)
					aAdd(Atail(aNotas),(cAliasSFX)->DOC)
					aadd(Atail(aNotas),"")
					aadd(Atail(aNotas),"")
					If nCursor==Val(MV_PAR02) .or. (cAliasSFX)->(Eof ())
						lBreak :=.T.
						nx:=20
					EndIF
					nCursor++
					( cAliasSFX )->( DbSkip() )
				Next nX

				dbSelectArea(cAliasSFX)

				If lSdoc
					cSerId := (cAliasSFX)->SDOC
				Else
					cSerId := (cAliasSFX)->SERIE
				EndIf
				aXml:={}
				if lUsaColab
					//Tratamento do TOTVS Colabora็ใo
					aXml := GetXMLColab(aNotas,@cModalidade,lUsaColab)
				else
					aXml := GetXML(cIdEnt,aNotas,@cModalidade)
				endif

				nLenNotas := Len(aNotas)
				For nx :=1 To nLenNotas
					dbSelectArea("SFT")
					dbSetOrder(1)
					cChaveSFT	:=	(xFilial("SFT")+aNotas[nX][02]+aNotas[nX][04]+aNotas[nX][05])
					MsSeek(cChaveSFT)
					If ( !Empty(aXML[nX][2]) .AND. (AllTrim((cAliasSFT)->FT_ESPECIE)== 'SPED') .Or. (lImpDir .And. !Empty(aXML[nX][2])) ) .And. Empty((cAliasSFT)->FT_DTCANC)
						If !Empty(aXml[nX])
							cAutoriza   := aXML[nX][1]
							cCodAutDPEC := aXML[nX][5]
							cCodRetNFE	:= aXML[nX][9]
							cCodRetSF3		:= iif ( Empty (cCodAutDPEC),cCodRetNFE,cCodAutDPEC )
							cMsgSF3		:= iif ( aXML[nX][10]<> Nil ,aXML[nX][10],"")
						Else
							cAutoriza   := ""
							cCodAutDPEC := ""
							cCodRetNFE	:= ""
							cCodRetSF3		:= ""
							cMsgSF3		:= ""
						EndIf
						cAviso := ""
						cErro  := ""
						//-----------------------------------------------------------------------
						// Validacao para quando for TOTVS Colaboracao, pois o retorno do
						// xml sera o que vem da Neogrid, e nao o que enviamos.
						// Para que nao fosse alterado totalmente a estrutura do Objeto,
						// atribui a variavel oRetNF o retorno, e abaixo identifico se possui
						// o objeto NFEPROC, caso tenha, deixarei na mesma estrutura do legado.
						// @autor: Douglas Parreja	@since 30/10/2017
						//-----------------------------------------------------------------------
						oRetNF := XmlParser(aXML[nX][2],"_",@cAviso,@cErro)
						if type("oRetNF:_NFEPROC") <> "U"
							oNfe := WSAdvValue( oRetNF,"_NFEPROC","string",NIL,NIL,NIL,NIL,NIL)
						else
							oNfe := oRetNF
						endif

						oNfeDPEC := XmlParser(aXML[nX][4],"_",@cAviso,@cErro)
						//(se possui protocolo ou protocolo dpec ou a modalidade de transmissao for 2 ou 5) E codigo retorno nao esta na lista
						If ( !Empty(cAutoriza) .Or. !Empty(cCodAutDPEC) .Or. Alltrim(aXML[nX][8]) $ "2,5" ) .And. !cCodRetNFE $ RetCodDene()
							If aNotas[nX][02]=="E" .And. MV_PAR04==1 .And. (oNfe:_NFE:_INFNFE:_IDE:_TPNF:TEXT=="0")
								dbSelectArea("SF1")
								dbSetOrder(1)
								If MsSeek(xFilial("SF1")+aNotas[nX][05]+aNotas[nX][04]) .And. SF1->(FieldPos("F1_FIMP"))<>0 .And. Alltrim(aXML[nX][8])$"1,3,4,6" .or. ( Alltrim(aXML[nX][8]) $ "2,5"  .And. !Empty(cAutoriza) )
									Do While !Eof() .And. SF1->F1_DOC==aNotas[nX][05] .And. SF1->F1_SERIE==aNotas[nX][04]
										If SF1->F1_FORMUL=='S'
											RecLock("SF1")
											If !SF1->F1_FIMP$"D"
												SF1->F1_FIMP := "S"
											EndIf
											If SF1->(FieldPos("F1_CHVNFE"))>0
												SF1->F1_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
											EndIf
											If SF1->(FieldPos("F1_HAUTNFE")) > 0 .and. SF1->(FieldPos("F1_DAUTNFE")) > 0 //grava a data e hora de autoriza็ใo da NFe
												SF1->F1_HAUTNFE := IIF(!Empty(aXML[nX][6]),SUBSTR(aXML[nX][6],1,5),"")
												SF1->F1_DAUTNFE	:= IIF(!Empty(aXML[nX][7]),aXML[nX][7],SToD("  /  /    "))
											EndIf
											MsUnlock()
										EndIf
										DbSkip()
									EndDo
								EndIf
								// Atualiza็ใo dos campos da Tabela GFE
								if FindFunction("GFECHVNFE") .and. lMVGfe  // Integra็ใo com o GFE

									dbSelectArea("SA2")
									dbSetOrder(1)
									If SA2->(MsSeek(xFilial("SA2")+ SF1->F1_FORNECE + SF1->F1_LOJA,.T.))

										GFECHVNFE(xFilial("SF1"),SF1->F1_SERIE,SF1->F1_DOC,SF1->F1_TIPO,SA2->A2_CGC,SA2->A2_COD,SA2->A2_LOJA,SF1->F1_CHVNFE,SF1->F1_FIMP)

									endif
								endif
							ElseIf aNotas[nX][02]=="S" .And. MV_PAR04==2 .And. (oNfe:_NFE:_INFNFE:_IDE:_TPNF:TEXT=="1")
								dbSelectArea("SF2")
								dbSetOrder(1)
								If MsSeek(xFilial("SF2")+PADR(aNotas[nX][05],TAMSX3("F2_DOC")[1])+aNotas[nX][04]) .And. Alltrim(aXML[nX][8])$"1,3,4,6,7" .Or. ( Alltrim(aXML[nX][8]) $ "2,5"  .And. !Empty(cAutoriza) )
									RecLock("SF2")
									If !SF2->F2_FIMP$"D"
										SF2->F2_FIMP := "S"
									EndIf
									If SF2->(FieldPos("F2_CHVNFE"))>0
										SF2->F2_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
									EndIf
									If SF2->(FieldPos("F2_HAUTNFE")) > 0 .and. SF2->(FieldPos("F2_DAUTNFE")) > 0 //grava a data e hota de autoriza็ใo da NFe
										SF2->F2_HAUTNFE := IIF(!Empty(aXML[nX][6]),SUBSTR(aXML[nX][6],1,5),"")
										SF2->F2_DAUTNFE	:= IIF(!Empty(aXML[nX][7]),aXML[nX][7],SToD("  /  /    "))
									EndIf
									MsUnlock()
									// Grava quando a nota for Transferencia entre filiais
									IF SF2->(FieldPos("F2_FILDEST"))> 0 .And. SF2->(FieldPos("F2_FORDES"))> 0 .And.SF2->(FieldPos("F2_LOJADES"))> 0 .And.SF2->(FieldPos("F2_FORMDES"))> 0 .And. !EMPTY (SF2->F2_FORDES)
									SF1->(dbSetOrder(1))
										If SF1->(MsSeek(SF2->F2_FILDEST+SF2->F2_DOC+SF2->f2_SERIE+SF2->F2_FORDES+SF2->F2_LOJADES+SF2->F2_FORMDES))
											If EMPTY(SF1->F1_CHVNFE)
												RecLock("SF1",.F.)
												SF1->F1_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
												MsUnlock()
											EndIf
										Endif
									EndiF
								EndIf

								// Atualiza็ใo dos campos da Tabela GFE
								if FindFunction("GFECHVNFE") .and. lMVGfe  // Integra็ใo com o GFE

									dbSelectArea("SA1")
									dbSetOrder(1)
									If SA1->(MsSeek(xFilial("SA1")+ SF2->F2_CLIENTE + SF2->F2_LOJA,.T.))

										GFECHVNFE(xFilial("SF2"),SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_TIPO,SA1->A1_CGC,SA1->A1_COD,SA1->A1_LOJA,SF2->F2_CHVNFE,SF2->F2_FIMP)

									endif
								endif

								If ExistFunc("STFMMd5NS") //Fun็ใo do Controle de Lojas - Legisla็ใo PAF-ECF
									STFMMd5NS()
								EndIf
							EndIf
							dbSelectArea("SFT")
							dbSetOrder(1)
							If SFT->(FieldPos("FT_CHVNFE"))>0
								cChaveSFT	:=	(xFilial("SFT")+aNotas[nX][02]+aNotas[nX][04]+padr(aNotas[nX][05],TamSx3("FT_NFISCAL")[1],""))
								If MsSeek(cChaveSFT)
									Do While !(cAliasSFT)->(Eof ()) .And.;
										cChaveSFT==(cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL
										If (cAliasSFT)->FT_TIPOMOV $"S" .Or. ((cAliasSFT)->FT_TIPOMOV $"E" .And. (cAliasSFT)->FT_FORMUL=='S')
											RecLock("SFT")
											SFT->FT_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
											MsUnLock()
											//Array criado para gravar o SF3 no final, pois a tabela SF3 pode estah em processamento quando se trata de DBF ou AS/400.
											If aScan(aGrvSF3,{|aX|aX[1]+aX[2]+aX[3]+aX[4]+aX[5]==(cAliasSFT)->(FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_IDENTF3)})==0
												aAdd(aGrvSF3, {(cAliasSFT)->FT_SERIE,(cAliasSFT)->FT_NFISCAL,(cAliasSFT)->FT_CLIEFOR,(cAliasSFT)->FT_LOJA,(cAliasSFT)->FT_IDENTF3,(cAliasSFT)->FT_CHVNFE,cAutoriza,cCodRetSF3,cMsgSF3})
											EndIf
										EndIf
										DbSkip()
									EndDo
								Endif
							EndIf
							// Grava quando a nota for Transferencia entre filiais
							IF SF1->(!EOF()) .And. SF2->(FieldPos("F2_FILDEST"))> 0 .And. SF2->(FieldPos("F2_FORDES"))> 0 .And.SF2->(FieldPos("F2_LOJADES"))> 0 .And.SF2->(FieldPos("F2_FORMDES"))> 0 .And. !EMPTY (SF2->F2_FORDES)
								SFT->(dbSetOrder(1))
								cChaveSFT := SF1->F1_FILIAL+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA
								If SFT->(MsSeek(cChaveSFT))
									Do While cChaveSFT == SFT->FT_FILIAL+"E"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA .And. !SFT->(Eof())
										RecLock("SFT")
										SFT->FT_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
										MsUnLock()
										//Array criado para gravar o SF3 no final, pois a tabela SF3 pode estah em processamento quando se trata de DBF ou AS/400.
										If aScan(aGrvSF3,{|aX|aX[1]+aX[2]+aX[3]+aX[4]+aX[5]==(cAliasSFT)->(FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_IDENTF3)})==0
											aAdd(aGrvSF3, {(cAliasSFT)->FT_SERIE,(cAliasSFT)->FT_NFISCAL,(cAliasSFT)->FT_CLIEFOR,(cAliasSFT)->FT_LOJA,(cAliasSFT)->FT_IDENTF3,(cAliasSFT)->FT_CHVNFE,cAutoriza,cCodRetSF3,cMsgSF3})
										EndIf
										SFT->(dbSkip())
									EndDo
								EndIf
							EndIf
							//-------------------------------
							If Empty(cAviso) .And. Empty(cErro) .And. MV_PAR04==1 .And. (oNfe:_NFE:_INFNFE:_IDE:_TPNF:TEXT=="0")
								ImpDet(@oDanfe,oNFe,cAutoriza,cModalidade,oNfeDPEC,cCodAutDPEC,aXml[nX][6],aXml[nX][7],aNotas[nX],lImpSimp)
								lExistNfe := .T.
							ElseIf Empty(cAviso) .And. Empty(cErro) .And. MV_PAR04==2 .And. (oNfe:_NFE:_INFNFE:_IDE:_TPNF:TEXT=="1")
								ImpDet(@oDanfe,oNFe,cAutoriza,cModalidade,oNfeDPEC,cCodAutDPEC,aXml[nX][6],aXml[nX][7],aNotas[nX],lImpSimp)
								lExistNfe := .T.
							EndIf

						ElseIf lIsLoja
							/* Se o Codigo de Retorno da SEFAZ esta preenchido e for maior que 200, entao houve rejeicao por parte da SEFAZ	*/
							If !Empty(aXML[nX][9]) .AND. Val(aXML[nX][9]) > 200

								RecLock("SF2",.F.)
								Replace SF2->F2_FIMP with "N"
								SF2->( MsUnlock() )

								cNaoAut := "A impressใo do DANFE referente ao Doc/S้rie " + SF2->F2_DOC + "/" + SF2->F2_SERIE + " NรO FOI REALIZADA pelo motivo abaixo:"
								cNaoAut += CRLF + "[" + aXML[nX][9] + ' - ' + aXML[nX][10] + "]"
								cNaoAut += CRLF + "Se possํvel, fa็a o ajuste e retransmita a NF-e."

								Aviso( "SPED", cNaoAut, {"Continuar"}, 3 )
							EndIf

						Else
							cNaoAut += aNotas[nX][04]+aNotas[nX][05]+CRLF
						EndIf
					EndIf
					oNfe     := nil
					oNfeDPEC := nil
					delClassIntF()
				Next nx
			EndDo
		EndDo

		If !lIsLoja .AND. !Empty(cNaoAut)
			Aviso("SPED","As seguintes notas nใo foram autorizadas: "+CRLF+CRLF+cNaoAut,{"Ok"},3)
		EndIf

	EndIf

	If Len(aGrvSF3)>0 .And. SF3->(FieldPos("F3_CHVNFE"))>0
		SF3->( dbSetOrder( 5 ) )
		For nI := 1 To Len(aGrvSF3)
			cChavSF3 :=  xFilial("SF3")+aGrvSF3[nI,1]+aGrvSF3[nI,2]+aGrvSF3[nI,3]+aGrvSF3[nI,4]+aGrvSF3[nI,5]
			If SF3->(MsSeek(xFilial("SF3")+aGrvSF3[nI,1]+aGrvSF3[nI,2]+aGrvSF3[nI,3]+aGrvSF3[nI,4]+aGrvSF3[nI,5]))
				Do While cChavSF3 == xFilial("SF3")+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_IDENTFT .And. !SF3->(Eof())
					lChave := iif( lUsacolab, .T., Empty(SF3->F3_CHVNFE) )
					If (Val(SF3->F3_CFO) >= 5000 .Or. SF3->F3_FORMUL=='S') .And. lChave
						RecLock("SF3",.F.)
						SF3->F3_CHVNFE := aGrvSF3[nI,6] // Chave da nota
						SF3->F3_PROTOC := aGrvSF3[nI,7] // Protocolo
						SF3->F3_CODRSEF:= aGrvSF3[nI,8] // Codigo de retorno Sefaz
						SF3->F3_DESCRET:= aGrvSF3[nI,9] // Mensagem de retorno Sefaz
						SF3->F3_CODRET := iif (SF3->(FieldPos("F3_CODRET"))>0,"M",)
						MsUnLock()
					EndIf
					SF3->(dbSkip())
				EndDo
			EndIf
		Next nI
	EndIf
	RestArea(aArea)
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetXML(cIdEnt,aIdNFe,cModalidade)  

	Local aRetorno		:= {}
	Local aDados		:= {}
	Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
	Local cModel		:= "55"
	Local nZ			:= 0
	Local nCount		:= 0
	Local oWS

	If Empty(cModalidade)    

		oWS := WsSpedCfgNFe():New()
		oWS:cUSERTOKEN := "TOTVS"
		oWS:cID_ENT    := cIdEnt
		oWS:nModalidade:= 0
		oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWS:cModelo    := cModel 
		
		If oWS:CFGModalidade()
			cModalidade    := SubStr(oWS:cCfgModalidadeResult,1,1)
		Else
			cModalidade    := ""
		EndIf  
		
	EndIf  
			
	oWs := nil

	For nZ := 1 To len(aIdNfe) 
		nCount++
		aDados := executeRetorna( aIdNfe[nZ], cIdEnt )
		if ( nCount == 10 )
			delClassIntF()
			nCount := 0
		endif
		aAdd(aRetorno,aDados)	
	Next nZ

Return(aRetorno)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function executeRetorna( aNfe, cIdEnt, lUsacolab )

	Local aExecute		:= {}
	Local aFalta		:= {}
	Local aResposta		:= {}
	Local aRetorno		:= {}
	Local aDados		:= {}
	Local aIdNfe		:= {}
	Local cAviso		:= ""
	Local cDHRecbto		:= ""
	Local cDtHrRec		:= ""
	Local cDtHrRec1		:= ""
	Local cErro			:= ""
	Local cModTrans		:= ""
	Local cProtDPEC		:= ""
	Local cProtocolo	:= ""
	Local cMsgNFE		:= ""
	Local cRetDPEC		:= ""
	Local cRetorno		:= ""
	Local cCodRetNFE	:= ""
	Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
	Local cModel		:= "55"
	Local dDtRecib		:= CToD("")
	Local lFlag			:= .T.
	Local nDtHrRec1		:= 0
	Local nL			:= 0
	Local nX			:= 0
	Local nY			:= 0
	Local nZ			:= 1
	Local nCount		:= 0
	Local nLenNFe
	Local nLenWS
	Local oWS
	Private oDHRecbto
	Private oNFeRet
	Private oDoc

	default lUsacolab	:= .F.

	aAdd(aIdNfe,aNfe)

	if !lUsacolab
		oWS:= WSNFeSBRA():New()
		oWS:cUSERTOKEN        := "TOTVS"
		oWS:cID_ENT           := cIdEnt
		oWS:nDIASPARAEXCLUSAO := 0
		oWS:_URL 			  := AllTrim(cURL)+"/NFeSBRA.apw"
		oWS:oWSNFEID          := NFESBRA_NFES2():New()
		oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()

		aadd(aRetorno,{"","",aIdNfe[nZ][4]+aIdNfe[nZ][5],"","","",CToD(""),"","",""})

		aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
		Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aIdNfe[nZ][4]+aIdNfe[nZ][5]

		If oWS:RETORNANOTASNX()
			If Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5) > 0
				For nX := 1 To Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5)
					cRetorno        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXML
					cProtocolo      := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CPROTOCOLO
					cDHRecbto  		:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXMLPROT
					oNFeRet			:= XmlParser(cRetorno,"_",@cAviso,@cErro)
					cModTrans		  := IIf(Type("oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT") <> "U",IIf (!Empty("oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT"),oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT,1),1)
					If ValType(oWs:OWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:OWSDPEC)=="O"
						cRetDPEC        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CXML
						cProtDPEC       := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CPROTOCOLO
					EndIf
					If !Empty(cProtocolo)
						oDHRecbto		:= XmlParser(cDHRecbto,"","","")
						cDtHrRec		:= IIf(Type("oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT")<>"U",oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT,"")
						nDtHrRec1		:= RAT("T",cDtHrRec)

						If nDtHrRec1 <> 0
							cDtHrRec1   :=	SubStr(cDtHrRec,nDtHrRec1+1)
							dDtRecib	:=	SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
						EndIf

						AtuSF2Hora(cDtHrRec1,aIdNFe[nZ][5]+aIdNFe[nZ][4]+aIdNFe[nZ][6]+aIdNFe[nZ][7])

					EndIf

					nY := aScan(aIdNfe,{|x| x[4]+x[5] == SubStr(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:CID,1,Len(x[4]+x[5]))})

					oWS:cIdInicial    := aIdNfe[nZ][4]+aIdNfe[nZ][5]
					oWS:cIdFinal      := aIdNfe[nZ][4]+aIdNfe[nZ][5]
					If oWS:MONITORFAIXA()
						cCodRetNFE := oWS:oWsMonitorFaixaResult:OWSMONITORNFE[1]:OWSERRO:OWSLOTENFE[len(oWS:oWsMonitorFaixaResult:OWSMONITORNFE[1]:OWSERRO:OWSLOTENFE)]:CCODRETNFE
						cMsgNFE	:= oWS:oWsMonitorFaixaResult:OWSMONITORNFE[1]:OWSERRO:OWSLOTENFE[len(oWS:oWsMonitorFaixaResult:OWSMONITORNFE[1]:OWSERRO:OWSLOTENFE)]:CMSGRETNFE
					EndIf

					If nY > 0
						aRetorno[nY][1] := cProtocolo
						aRetorno[nY][2] := cRetorno
						aRetorno[nY][4] := cRetDPEC
						aRetorno[nY][5] := cProtDPEC
						aRetorno[nY][6] := cDtHrRec1
						aRetorno[nY][7] := dDtRecib
						aRetorno[nY][8] := cModTrans
						aRetorno[nY][9] := cCodRetNFE
						aRetorno[nY][10]:= cMsgNFE

					EndIf
					cRetDPEC := ""
					cProtDPEC:= ""
				Next nX
			EndIf
		Else
			Aviso("DANFE",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
		EndIf
	else
		oDoc 			:= ColaboracaoDocumentos():new()
		oDoc:cModelo	:= "NFE"
		oDoc:cTipoMov	:= "1"
		oDoc:cIDERP	:= aIdNfe[nZ][4]+aIdNfe[nZ][5]+FwGrpCompany()+FwCodFil()

		aadd(aRetorno,{"","",aIdNfe[nZ][4]+aIdNfe[nZ][5],"","","",CToD(""),"","",""})

		if odoc:consultar()
			aDados := ColDadosNf(1)

			if !Empty(oDoc:cXMLRet)
				cRetorno	:= oDoc:cXMLRet
			else
				cRetorno	:= oDoc:cXml
			endif

			aDadosXml := ColDadosXMl(cRetorno, aDados, @cErro, @cAviso)

			if '<obsCont xCampo="nRegDPEC">' $ cRetorno
				aDadosXml[9] := SubStr(cRetorno,At('<obsCont xCampo="nRegDPEC"><xTexto>',cRetorno)+35,15)
			endif

			cProtocolo		:= aDadosXml[3]
			cModTrans		:= IIF(Empty(aDadosXml[5]),aDadosXml[7],aDadosXml[5])
			cCodRetNFE := aDadosXml[1]
			cMsgNFE := iif (aDadosXml[2]<> nil ,aDadosXml[2],"")
			//Dados do DEPEC
			If !Empty( aDadosXml[9] )
				cRetDPEC        := cRetorno
				cProtDPEC       := aDadosXml[9]
			EndIf

			//Tratamento para gravar a hora da transmissao da NFe
			If !Empty(cProtocolo)
				cDtHrRec		:= aDadosXml[4]
				nDtHrRec1		:= RAT("T",cDtHrRec)

				If nDtHrRec1 <> 0
					cDtHrRec1   :=	SubStr(cDtHrRec,nDtHrRec1+1)
					dDtRecib	:=	SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
				EndIf

				AtuSF2Hora(cDtHrRec1,aIdNFe[nZ][5]+aIdNFe[nZ][4]+aIdNFe[nZ][6]+aIdNFe[nZ][7])

			EndIf

			aRetorno[1][1] := cProtocolo
			aRetorno[1][2] := cRetorno
			aRetorno[1][4] := cRetDPEC
			aRetorno[1][5] := cProtDPEC
			aRetorno[1][6] := cDtHrRec1
			aRetorno[1][7] := dDtRecib
			aRetorno[1][8] := cModTrans
			aRetorno[1][9] := cCodRetNFE
			aRetorno[1][10]:= cMsgNFE

			cRetDPEC := ""
			cProtDPEC:= ""

		endif
	endif

	oWS       := Nil
	oDHRecbto := Nil
	oNFeRet   := Nil

return aRetorno[len(aRetorno)]
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function atuSf2Hora( cDtHrRec,cSeek )

	local aArea := GetArea()

	dbSelectArea("SF2")
	dbSetOrder(1)
	If MsSeek(xFilial("SF2")+cSeek)
		If SF2->(FieldPos("F2_HORA"))<>0 .And. Empty(SF2->F2_HORA)
			RecLock("SF2")
			SF2->F2_HORA := cDtHrRec
			MsUnlock()
		EndIf
	EndIf
	dbSelectArea("SF1")
	dbSetOrder(1)
	If MsSeek(xFilial("SF1")+cSeek)
		If SF1->(FieldPos("F1_HORA"))<>0 .And. Empty(SF1->F1_HORA)
			RecLock("SF1")
			SF1->F1_HORA := cDtHrRec
			MsUnlock()
		EndIf
	EndIf

	RestArea(aArea)

return nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpDet( oDanfe , oNfe , cCodAutSef , cModalidade , oNfeDPEC , cCodAutDPEC , cDtHrRecCab , dDtReceb , aNota , lImpSimp , nTipo )

	DEFAULT lImpSimp   := .F.
	Default nTipo	   := 0
								
	lImpSimp   := .F. //Especifico Adoro - Incluido por Adriana em 08/01/2016 para impedir impressao de DANFE Simplificado

	If ntipo <> 1
		PRIVATE oFont10N   := TFontEx():New(oDanfe,"Times New Roman",08,08,.T.,.T.,.F.)// 1
		PRIVATE oFont07N   := TFontEx():New(oDanfe,"Times New Roman",06,06,.T.,.T.,.F.)// 2
		PRIVATE oFont07    := TFontEx():New(oDanfe,"Times New Roman",06,06,.F.,.T.,.F.)// 3
		PRIVATE oFont08    := TFontEx():New(oDanfe,"Times New Roman",07,07,.F.,.T.,.F.)// 4
		PRIVATE oFont08N   := TFontEx():New(oDanfe,"Times New Roman",06,06,.T.,.T.,.F.)// 5
		PRIVATE oFont09N   := TFontEx():New(oDanfe,"Times New Roman",08,08,.T.,.T.,.F.)// 6
		PRIVATE oFont09    := TFontEx():New(oDanfe,"Times New Roman",08,08,.F.,.T.,.F.)// 7
		PRIVATE oFont10    := TFontEx():New(oDanfe,"Times New Roman",09,09,.F.,.T.,.F.)// 8
		PRIVATE oFont11    := TFontEx():New(oDanfe,"Times New Roman",10,10,.F.,.T.,.F.)// 9
		PRIVATE oFont12    := TFontEx():New(oDanfe,"Times New Roman",11,11,.F.,.T.,.F.)// 10
		PRIVATE oFont11N   := TFontEx():New(oDanfe,"Times New Roman",10,10,.T.,.T.,.F.)// 11
		PRIVATE oFont18N   := TFontEx():New(oDanfe,"Times New Roman",17,17,.T.,.T.,.F.)// 12
		PRIVATE OFONT12N   := TFontEx():New(oDanfe,"Times New Roman",11,11,.T.,.T.,.F.)// 12
		PRIVATE oFont16N   := TFontEx():New(oDanfe,"Times New Roman",15,15,.T.,.T.,.F.)// 12
		PRIVATE lUsaColab	  :=  UsaColaboracao("1")

		if lImpSimp
			SimpDanfe(@oDanfe,oNfe,cCodAutSef,cModalidade,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,dDtReceb,aNota)
		else
			PrtDanfe(@oDanfe,oNfe,cCodAutSef,cModalidade,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,dDtReceb,aNota)
		endif

	ElseIf nTipo == 1
		U_IMPDNFLJ(oNFE, cCodAutSef, dDtReceb, cDtHrRecCab)
	EndIf

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrtDanfe(oDanfe,oNFE,cCodAutSef,cModalidade,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,dDtReceb,aNota)

	Local aAuxCabec     := {} // Array que conterแ as strings de cabe็alho das colunas de produtos/servi็os.
	Local aTamanho      := {}
	Local aTamCol       := {} // Array que conterแ o tamanho das colunas dos produtos/servi็os.
	Local aSitTrib      := {}
	Local aSitSN        := {}
	Local aTransp       := {}
	Local aDest         := {}
	Local aHrEnt        := {}
	Local aFaturas      := {}
	Local aItens        := {}
	Local aISSQN        := {}
	Local aSimpNac		:= {}
	Local aTotais       := {}
	Local aAux          := {}
	Local aUF           := {}
	Local aMensagem     := {}
	Local aEspVol       := {}
	Local aResFisco     := {}
	Local aEspecie      := {}
	Local aIndImp	    := {}
	Local aIndAux	    := {}
	Local aLote         := {}
	Local nHPage        := 0
	Local nVPage        := 0
	Local nPosV         := 0
	Local nPosVOld      := 0
	Local nPosH         := 0
	Local nPosHOld      := 0
	Local nAuxH         := 0
	Local nAuxH2        := 0
	Local nAuxV         := 0
	Local nSnBaseIcm	 := 0
	Local nSnValIcm    := 0
	Local nDetImp		 := 0
	Local nS			 := 0
	Local nX            := 0
	Local nY            := 0
	Local nL            := 0
	Local nJ            := 0
	Local nW            := 0
	Local nTamanho      := 0
	Local nFolha        := 1
	Local nFolhas       := 0
	Local nItem         := 0
	Local nMensagem     := 0
	Local nBaseICM      := 0
	Local nValICM       := 0
	Local nValIPI       := 0
	Local nPICM         := 0
	Local nPIPI         := 0
	Local nFaturas      := 0
	Local nVTotal       := 0
	Local nQtd          := 0
	Local nVUnit        := 0
	Local nVolume	    := 0
	Local nLenFatura
	Local nLenVol
	Local nLenDet
	Local nLenSit
	Local nLenItens     := 0
	Local nLenMensagens := 0
	Local nLen          := 0
	Local nColuna	    := 0
	Local nLinSum	    := 0
	Local nRecSF3		:= 0
	Local nE		    := 0
	Local nPag
	Local nItensRes
	Local nSoma
	Local nZ		    := 0
	Local nMaxCod	    := 10
	Local nMaxDes	    := 43 // Padrao MAXITEMC - Especifico Adoro 43 - Alterado por Adriana em 30/07/2018 - chamado 042867
	Local nLinhavers    := 0
	Local nMaxItemP2    := MAXITEM // Variแvel utilizada para tratamento de quantos itens devem ser impressos na pแgina corrente
	Local cAux          := ""
	Local cSitTrib      := ""
	Local cUF		 	:= ""
	Local cMVCODREG		:= Alltrim( SuperGetMV("MV_CODREG", ," ") )
	Local cChaveCont 	:= ""
	Local cLogo 		:= ""
	Local cGuarda       := ""
	Local cEsp		    := ""
	Local cLogoD	    := ""
	local cEndDest      := ""
	local cLogoTotvs 	:= "Powered_by_TOTVS.bmp"
	local cStartPath 	:= GetSrvProfString("Startpath","")
	Local lPreview      := .F.
	Local lFlag         := .T.
	Local lConverte     := GetNewPar("MV_CONVERT",.F.)
	Local lImpAnfav     := GetNewPar("MV_IMPANF",.F.)
	Local lImpInfAd   	:= GetNewPar("MV_IMPADIC",.F.)
	Local lImpSimpN		:= GetNewPar("MV_IMPSIMP",.F.)
	Local lPagPar
	Local lMv_Logod     := If(GetNewPar("MV_LOGOD", "N" ) == "S", .T., .F.   )
	Local lMv_ItDesc    := Iif( GetNewPar("MV_ITDESC","N")=="S", .T., .F. )
	Local lNFori2 	    := .T.
	Local lFimpar	    := .T.
	Local lCompleECF    := .F.
	Local lEntIpiDev   	:= GetNewPar("MV_EIPIDEV",.F.) /*Apenas para nota de entrada de Devolu็ใo de ipi. .T.-S้ra destacado no cabe็alho + inf.compl/.F.-Serแ destacado apenas em inf.compl*/
	Local cDhCont		:= ""
	Local cXJust		:= ""
	Local cDescLogo		:= ""
	Local cGrpCompany	:= ""
	Local cCodEmpGrp	:= ""
	Local cUnitGrp		:= ""
	Local cFilGrp		:= ""
	Local lPontilhado 	:= .F.
	Local aAuxCom 		:= {}
	Local cUnCom		:= ""
	Local nQtdCom		:= 0
	Local nVUnitCom		:= 0
	Local lUf_MG		:= ( SuperGetMv("MV_ESTADO") $ "MG" )	// Criado esta variavel para atender o RICMS de MG para totalizar por CFOP
	Local nSequencia	:= 0
	Local nSubTotal		:= 0
	Local cCfop			:= ""
	Local cCfopAnt		:= ""
	Local aItensAux     := {}
	Local aArray		:= {}
	Default cDtHrRecCab := ""
	Default dDtReceb    := CToD("")
	Private aInfNf    := {}

	Private oDPEC     := oNfeDPEC
	Private oNF       := oNFe:_NFe
	Private oEmitente := oNF:_InfNfe:_Emit
	Private oIdent    := oNF:_InfNfe:_IDE
	Private oDestino  := oNF:_InfNfe:_Dest
	Private oTotal    := oNF:_InfNfe:_Total
	Private oTransp   := oNF:_InfNfe:_Transp
	Private oDet      := oNF:_InfNfe:_Det
	Private oFatura   := IIf(Type("oNF:_InfNfe:_Cobr")=="U",Nil,oNF:_InfNfe:_Cobr)
	Private oImposto
	Private nPrivate  := 0
	Private nPrivate2 := 0
	Private nXAux	  := 0
	Private lArt488MG := .F.
	Private lArt274SP := .F.

	nFaturas := IIf(oFatura<>Nil,IIf(ValType(oNF:_InfNfe:_Cobr:_Dup)=="A",Len(oNF:_InfNfe:_Cobr:_Dup),1),0)
	oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCarrega as variaveis de impressao                                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aadd(aSitTrib,"00")
	aadd(aSitTrib,"10")
	aadd(aSitTrib,"20")
	aadd(aSitTrib,"30")
	aadd(aSitTrib,"40")
	aadd(aSitTrib,"41")
	aadd(aSitTrib,"50")
	aadd(aSitTrib,"51")
	aadd(aSitTrib,"60")
	aadd(aSitTrib,"70")
	aadd(aSitTrib,"90")
	aadd(aSitTrib,"PART")
	aadd(aSitSN,"101")
	aadd(aSitSN,"102")
	aadd(aSitSN,"201")
	aadd(aSitSN,"202")
	aadd(aSitSN,"500")
	aadd(aSitSN,"900")

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณQuadro Destinatario                                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	cEndDest := NoChar(oDestino:_EnderDest:_Xlgr:Text,lConverte)
	If  " SN" $ (UPPER (oDestino:_EnderDest:_Xlgr:Text)) .Or. ",SN" $ (UPPER (oDestino:_EnderDest:_Xlgr:Text)) .Or. ;
		"S/N" $ (UPPER (oDestino:_EnderDest:_Xlgr:Text))

				cEndDest += IIf(Type("oDestino:_EnderDest:_xcpl")=="U","",", " + NoChar(oDestino:_EnderDest:_xcpl:Text,lConverte))
	Else
				cEndDest += +","+NoChar(oDestino:_EnderDest:_NRO:Text,lConverte) + IIf(Type("oDestino:_EnderDest:_xcpl")=="U","",", "+ NoChar(oDestino:_EnderDest:_xcpl:Text,lConverte))
	Endif

	aDest := {cEndDest,;
	NoChar(oDestino:_EnderDest:_XBairro:Text,lConverte),;
	IIF(Type("oDestino:_EnderDest:_Cep")=="U","",Transform(oDestino:_EnderDest:_Cep:Text,"@r 99999-999")),;
	IIF(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",IIF(Type("oIdent:_DHSaiEnt")=="U","",oIdent:_DHSaiEnt:Text),IIF(Type("oIdent:_DSaiEnt")=="U","",oIdent:_DSaiEnt:Text)),;
	oDestino:_EnderDest:_XMun:Text,;
	IIF(Type("oDestino:_EnderDest:_fone")=="U","",oDestino:_EnderDest:_fone:Text),;
	oDestino:_EnderDest:_UF:Text,;
	IIF(Type("oDestino:_IE")=="U","",oDestino:_IE:Text),;
	""}

	If oNF:_INFNFE:_VERSAO:TEXT >= "3.10"
		aadd(aHrEnt,IIF(Type("oIdent:_dhSaiEnt")=="U","",SubStr(oIdent:_dhSaiEnt:TEXT,12,8)))
	Else
		If Type("oIdent:_DSaiEnt")<>"U" .And. Type("oIdent:_HSaiEnt:Text")<>"U"
			aAdd(aHrEnt,oIdent:_HSaiEnt:Text)
		Else
			aAdd(aHrEnt,"")
		EndIf
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCalculo do Imposto                                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aTotais := {"","","","","","","","","","",""}
	aTotais[01] := Transform(Val(oTotal:_ICMSTOT:_vBC:TEXT),"@e 9,999,999,999,999.99")
	aTotais[02] := Transform(Val(oTotal:_ICMSTOT:_vICMS:TEXT),"@e 9,999,999,999,999.99")
	aTotais[03] := Transform(Val(oTotal:_ICMSTOT:_vBCST:TEXT),"@e 9,999,999,999,999.99")
	aTotais[04] := Transform(Val(oTotal:_ICMSTOT:_vST:TEXT),"@e 9,999,999,999,999.99")
	aTotais[05] := Transform(Val(oTotal:_ICMSTOT:_vProd:TEXT),"@e 9,999,999,999,999.99")
	aTotais[06] := Transform(Val(oTotal:_ICMSTOT:_vFrete:TEXT),"@e 9,999,999,999,999.99")
	aTotais[07] := Transform(Val(oTotal:_ICMSTOT:_vSeg:TEXT),"@e 9,999,999,999,999.99")
	aTotais[08] := Transform(Val(oTotal:_ICMSTOT:_vDesc:TEXT),"@e 9,999,999,999,999.99")
	aTotais[09] := Transform(Val(oTotal:_ICMSTOT:_vOutro:TEXT),"@e 9,999,999,999,999.99")

	If ( MV_PAR04 == 1 )
		dbSelectArea("SF1")
		dbSetOrder(1)
		If MsSeek(xFilial("SF1")+aNota[5]+aNota[4]+aNota[6]+aNota[7]) .And. SF1->(FieldPos("F1_FIMP"))<>0
			If SF1->F1_TIPO <> "D"
				aTotais[10] := 	Transform(Val(oTotal:_ICMSTOT:_vIPI:TEXT),"@e 9,999,999,999,999.99")
			ElseIf SF1->F1_TIPO == "D" .and. lEntIpiDev
				aTotais[10] := 	Transform(Val(oTotal:_ICMSTOT:_vIPI:TEXT),"@e 9,999,999,999,999.99")
			Else
				aTotais[10] := ""
			EndIf
			MsUnlock()
			DbSkip()
		EndIf
	Else
		aTotais[10] := 	Transform(Val(oTotal:_ICMSTOT:_vIPI:TEXT),"@e 9,999,999,999,999.99")
	EndIf

	aTotais[11] := 	Transform(Val(oTotal:_ICMSTOT:_vNF:TEXT),"@e 9,999,999,999,999.99")

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณImpressใo da Base de Calculo e ICMS nos campo Proprios do ICMS quando optante pelo Simples Nacional    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If lImpSimpN

		nDetImp := Len(oDet)
		nS := nDetImp
		aSimpNac := {"",""}

			if Type("oDet["+Alltrim(Str(nS))+"]:_IMPOSTO:_ICMS:_ICMSSN101:_VCREDICMSSN:TEXT") <> "U"
				SF3->(dbSetOrder(5))

				if SF3->(MsSeek(xFilial("SF3")+aNota[4]+aNota[5]))
					while SF3->(!eof()) .and. ( SF3->F3_SERIE + SF3->F3_NFISCAL  == aNota[4] + aNota[5] )
						nSnBaseIcm += (SF3->F3_BASEICM)
						nSnValIcm  += (SF3->F3_VALICM)
						SF3->(dbSkip())
					end
				endif

			elseif Type("oDet["+Alltrim(Str(nS))+"]:_IMPOSTO:_ICMS:_ICMSSN900:_VCREDICMSSN:TEXT") <> "U"
				nS:= 0
				For nS := 1 To nDetImp
					If Type("oDet["+Alltrim(Str(nS))+"]:_IMPOSTO:_ICMS:_ICMSSN900:_VBC:TEXT") <> "U"
						nSnBaseIcm += Val(oDet[nS]:_IMPOSTO:_ICMS:_ICMSSN900:_VBC:TEXT)
					EndIf
					If Type("oDet["+Alltrim(Str(nS))+"]:_IMPOSTO:_ICMS:_ICMSSN900:_VCREDICMSSN:TEXT") <> "U"
						nSnValIcm  += Val(oDet[nS]:_IMPOSTO:_ICMS:_ICMSSN900:_VCREDICMSSN:TEXT)
					EndIf
				Next nS

			endif

			aSimpNac[01] := Transform((nSnBaseIcm),"@e 9,999,999,999,999.99")
			aSimpNac[02] := Transform((nSnValIcm),"@e 9,999,999,999,999.99")

	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณQuadro Faturas                                                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nFaturas > 0
		For nX := 1 To 3
			aAux := {}
			For nY := 1 To Min(9, nFaturas)
				Do Case
					Case nX == 1
						If nFaturas > 1
							AAdd(aAux, AllTrim(oFatura:_Dup[nY]:_nDup:TEXT))
						Else
							AAdd(aAux, AllTrim(oFatura:_Dup:_nDup:TEXT))
						EndIf
					Case nX == 2
						If nFaturas > 1
							AAdd(aAux, AllTrim(ConvDate(oFatura:_Dup[nY]:_dVenc:TEXT)))
						Else
							AAdd(aAux, AllTrim(ConvDate(oFatura:_Dup:_dVenc:TEXT)))
						EndIf
					Case nX == 3
						If nFaturas > 1
							AAdd(aAux, AllTrim(TransForm(Val(oFatura:_Dup[nY]:_vDup:TEXT), "@E 9,999,999,999,999.99")))
						Else
							AAdd(aAux, AllTrim(TransForm(Val(oFatura:_Dup:_vDup:TEXT), "@E 9,999,999,999,999.99")))
						EndIf
				EndCase
			Next nY
			If nY <= 9
				For nY := 1 To 9
					AAdd(aAux, Space(20))
				Next nY
			EndIf
			AAdd(aFaturas, aAux)
		Next nX
	EndIf
	aTransp := {"","0","","","","","","","","","","","","","",""}
	If Type("oTransp:_ModFrete")<>"U"
		aTransp[02] := IIF(Type("oTransp:_ModFrete:TEXT")<>"U",oTransp:_ModFrete:TEXT,"0")
	EndIf
	If Type("oTransp:_Transporta")<>"U"
		aTransp[01] := IIf(Type("oTransp:_Transporta:_xNome:TEXT")<>"U",NoChar(oTransp:_Transporta:_xNome:TEXT,lConverte),"")
		aTransp[03] := IIf(Type("oTransp:_VeicTransp:_RNTC")=="U","",oTransp:_VeicTransp:_RNTC:TEXT)
		aTransp[04] := IIf(Type("oTransp:_VeicTransp:_Placa:TEXT")<>"U",oTransp:_VeicTransp:_Placa:TEXT,"")
		aTransp[05] := IIf(Type("oTransp:_VeicTransp:_UF:TEXT")<>"U",oTransp:_VeicTransp:_UF:TEXT,"")
		If Type("oTransp:_Transporta:_CNPJ:TEXT")<>"U"
			aTransp[06] := Transform(oTransp:_Transporta:_CNPJ:TEXT,"@r 99.999.999/9999-99")
		ElseIf Type("oTransp:_Transporta:_CPF:TEXT")<>"U"
			aTransp[06] := Transform(oTransp:_Transporta:_CPF:TEXT,"@r 999.999.999-99")
		EndIf
		aTransp[07] := IIf(Type("oTransp:_Transporta:_xEnder:TEXT")<>"U",NoChar(oTransp:_Transporta:_xEnder:TEXT,lConverte),"")
		aTransp[08] := IIf(Type("oTransp:_Transporta:_xMun:TEXT")<>"U",oTransp:_Transporta:_xMun:TEXT,"")
		aTransp[09] := IIf(Type("oTransp:_Transporta:_UF:TEXT")<>"U",oTransp:_Transporta:_UF:TEXT,"")
		aTransp[10] := IIf(Type("oTransp:_Transporta:_IE:TEXT")<>"U",oTransp:_Transporta:_IE:TEXT,"")
	ElseIf Type("oTransp:_VEICTRANSP")<>"U"
		aTransp[03] := IIf(Type("oTransp:_VeicTransp:_RNTC")=="U","",oTransp:_VeicTransp:_RNTC:TEXT)
		aTransp[04] := IIf(Type("oTransp:_VeicTransp:_Placa:TEXT")<>"U",oTransp:_VeicTransp:_Placa:TEXT,"")
		aTransp[05] := IIf(Type("oTransp:_VeicTransp:_UF:TEXT")<>"U",oTransp:_VeicTransp:_UF:TEXT,"")
	EndIf
	If Type("oTransp:_Vol")<>"U"
		If ValType(oTransp:_Vol) == "A"
			nX := nPrivate
			nLenVol := Len(oTransp:_Vol)
			For nX := 1 to nLenVol
				nXAux := nX
				nVolume += IIF(!Type("oTransp:_Vol[nXAux]:_QVOL:TEXT")=="U",Val(oTransp:_Vol[nXAux]:_QVOL:TEXT),0)
			Next nX
			aTransp[11]	:= AllTrim(str(nVolume))
			aTransp[12]	:= IIf(Type("oTransp:_Vol:_Esp")=="U","Diversos","")
			aTransp[13] := IIf(Type("oTransp:_Vol:_Marca")=="U","",NoChar(oTransp:_Vol:_Marca:TEXT,lConverte))
			aTransp[14] := IIf(Type("oTransp:_Vol:_nVol:TEXT")<>"U",oTransp:_Vol:_nVol:TEXT,"")
			If  Type("oTransp:_Vol[1]:_PesoB") <>"U"
				nPesoB := Val(oTransp:_Vol[1]:_PesoB:TEXT)
				aTransp[15] := AllTrim(str(nPesoB))
			EndIf
			If Type("oTransp:_Vol[1]:_PesoL") <>"U"
				nPesoL := Val(oTransp:_Vol[1]:_PesoL:TEXT)
				aTransp[16] := AllTrim(str(nPesoL))
			EndIf
		Else
			aTransp[11] := IIf(Type("oTransp:_Vol:_qVol:TEXT")<>"U",oTransp:_Vol:_qVol:TEXT,"")
			aTransp[12] := IIf(Type("oTransp:_Vol:_Esp")=="U","",oTransp:_Vol:_Esp:TEXT)
			aTransp[13] := IIf(Type("oTransp:_Vol:_Marca")=="U","",NoChar(oTransp:_Vol:_Marca:TEXT,lConverte))
			aTransp[14] := IIf(Type("oTransp:_Vol:_nVol:TEXT")<>"U",oTransp:_Vol:_nVol:TEXT,"")
			aTransp[15] := IIf(Type("oTransp:_Vol:_PesoB:TEXT")<>"U",oTransp:_Vol:_PesoB:TEXT,"")
			aTransp[16] := IIf(Type("oTransp:_Vol:_PesoL:TEXT")<>"U",oTransp:_Vol:_PesoL:TEXT,"")
		EndIf
		aTransp[15] := strTRan(aTransp[15],".",",")
		aTransp[16] := strTRan(aTransp[16],".",",")
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVolumes / Especie Nota de Saida                                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If(MV_PAR04==2) .And. Empty(aTransp[12])

		If (SF2->(FieldPos("F2_ESPECI1")) <>0 .And. !Empty( SF2->(FieldGet(FieldPos( "F2_ESPECI1" )))  )) .Or.;
			(SF2->(FieldPos("F2_ESPECI2")) <>0 .And. !Empty( SF2->(FieldGet(FieldPos( "F2_ESPECI2" )))  )) .Or.;
			(SF2->(FieldPos("F2_ESPECI3")) <>0 .And. !Empty( SF2->(FieldGet(FieldPos( "F2_ESPECI3" )))  )) .Or.;
			(SF2->(FieldPos("F2_ESPECI4")) <>0 .And. !Empty( SF2->(FieldGet(FieldPos( "F2_ESPECI4" )))  ))

			aEspecie := {}
			aadd(aEspecie,SF2->F2_ESPECI1)
			aadd(aEspecie,SF2->F2_ESPECI2)
			aadd(aEspecie,SF2->F2_ESPECI3)
			aadd(aEspecie,SF2->F2_ESPECI4)

			cEsp := ""
			nx 	 := 0
			For nE := 1 To Len(aEspecie)
				If !Empty(aEspecie[nE])
					nx ++
					cEsp := aEspecie[nE]
				EndIf
			Next

			cGuarda := ""
			If nx > 1
				cGuarda := "Diversos"
			Else
				cGuarda := cEsp
			EndIf

			If !Empty(cGuarda)
				aadd(aEspVol,{cGuarda,Iif(SF2->F2_PLIQUI>0,str(SF2->F2_PLIQUI),""),Iif(SF2->F2_PBRUTO>0, str(SF2->F2_PBRUTO),"")})
			Else
				aadd(aEspVol,{cGuarda,"",""})
			Endif
		Else
			aadd(aEspVol,{cGuarda,"",""})
		EndIf
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEspecie Nota de Entrada                                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If(MV_PAR04==1) .And. Empty(aTransp[12])
		dbSelectArea("SF1")
		dbSetOrder(1)
		If MsSeek(xFilial("SF1")+aNota[5]+aNota[4]+aNota[6]+aNota[7])

			If (SF1->(FieldPos("F1_ESPECI1")) <>0 .And. !Empty( SF1->(FieldGet(FieldPos( "F1_ESPECI1" )))  )) .Or.;
				(SF1->(FieldPos("F1_ESPECI2")) <>0 .And. !Empty( SF1->(FieldGet(FieldPos( "F1_ESPECI2" )))  )) .Or.;
				(SF1->(FieldPos("F1_ESPECI3")) <>0 .And. !Empty( SF1->(FieldGet(FieldPos( "F1_ESPECI3" )))  )) .Or.;
				(SF1->(FieldPos("F1_ESPECI4")) <>0 .And. !Empty( SF1->(FieldGet(FieldPos( "F1_ESPECI4" )))  ))

				aEspecie := {}
				aadd(aEspecie,SF1->F1_ESPECI1)
				aadd(aEspecie,SF1->F1_ESPECI2)
				aadd(aEspecie,SF1->F1_ESPECI3)
				aadd(aEspecie,SF1->F1_ESPECI4)

				cEsp := ""
				nx 	 := 0
				For nE := 1 To Len(aEspecie)
					If !Empty(aEspecie[nE])
						nx ++
						cEsp := aEspecie[nE]
					EndIf
				Next

				cGuarda := ""
				If nx > 1
					cGuarda := "Diversos"
				Else
					cGuarda := cEsp
				EndIf

				If  !Empty(cGuarda)
					aadd(aEspVol,{cGuarda,Iif(SF1->F1_PLIQUI>0,str(SF1->F1_PLIQUI),""),Iif(SF1->F1_PBRUTO>0, str(SF1->F1_PBRUTO),"")})
				Else
					aadd(aEspVol,{cGuarda,"",""})
				Endif
			Else
				aadd(aEspVol,{cGuarda,"",""})
			EndIf

			MsUnlock()
			DbSkip()
		EndIf
	EndIf

	dbSelectArea("SD2")
	dbSetOrder(3)
	MsSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
	dbSelectArea("SC5")
	dbSetOrder(1)
	MsSeek(xFilial("SC5")+SD2->D2_PEDIDO)
	dbSelectArea("SF4")
	dbSetOrder(1)
	MsSeek(xFilial("SF4")+SD2->D2_TES)
	dbSelectArea("SF3")
	dbSetOrder(4)
	MsSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE)

	lArt488MG := Iif(SF4->(FIELDPOS("F4_CRLEIT"))>0,Iif(SF4->F4_CRLEIT == "1",.T.,.F.),.F.)
	lArt274SP := Iif(SF4->(FIELDPOS("F4_ART274"))>0,Iif(SF4->F4_ART274 $ "1S",.T.,.F.),.F.)

	If Type("oTransp:_ModFrete") <> "U"
		cModFrete := oTransp:_ModFrete:TEXT
	Else
		cModFrete := "1"
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณQuadro Dados do Produto / Servi็o                                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nLenDet := Len(oDet)
	If lMv_ItDesc
		For nX := 1 To nLenDet
			Aadd(aIndAux, {nX, SubStr(NoChar(oDet[nX]:_Prod:_xProd:TEXT,lConverte),1,MAXITEMC)})
		Next

		aIndAux := aSort(aIndAux,,, { |x, y| x[2] < y[2] })

		For nX := 1 To nLenDet
			Aadd(aIndImp, aIndAux[nX][1] )
		Next
	EndIf

	For nZ := 1 To nLenDet
		If lMv_ItDesc
			nX := aIndImp[nZ]
		Else
			nX := nZ
		EndIf
		nPrivate := nX

		If lArt488MG .And. lUf_MG
			nVTotal  := 0
			nVUnit   := 0
		Else
			nVTotal  := Val(oDet[nX]:_Prod:_vProd:TEXT)//-Val(IIF(Type("oDet[nPrivate]:_Prod:_vDesc")=="U","",oDet[nX]:_Prod:_vDesc:TEXT))
			nVUnit   := Val(oDet[nX]:_Prod:_vUnTrib:TEXT)
		EndIf

		nQtd     	:= Val(oDet[nX]:_Prod:_qTrib:TEXT)
		nBaseICM 	:= 0
		nValICM  	:= 0
		nValIPI  	:= 0
		nPICM    	:= 0
		nPIPI    	:= 0
		oImposto 	:= oDet[nX]
		cSitTrib 	:= ""

		lPontilhado	:= .F.
		If Type("oImposto:_Imposto")<>"U"
			If Type("oImposto:_Imposto:_ICMS")<>"U"
				nLenSit := Len(aSitTrib)
				For nY := 1 To nLenSit
					nPrivate2 := nY
					If Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2])<>"U" .Or. Type("oImposto:_Imposto:_ICMS:_ICMSST")<>"U"
						If Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_VBC:TEXT")<>"U"
							nBaseICM := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_VBC:TEXT"))
							nValICM  := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_vICMS:TEXT"))
							nPICM    := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_PICMS:TEXT"))
						ElseIf Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_MOTDESICMS") <> "U" .And. Type("oImposto:_PROD:_VDESC:TEXT") <> "U"   //SINIEF 25/12, efeitos a partir de 20.12.12
							If oNF:_INFNFE:_VERSAO:TEXT >= "3.10" .and. &("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_CST:TEXT") <> "40"
								If AllTrim(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_motDesICMS:TEXT")) == "7" .And. &("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_CST:TEXT") == "30"
									nValICM  := 0
								Else
									nValICM  := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_vICMSDESON:TEXT"))
								EndIf
							Elseif &("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_CST:TEXT") <> "40"
								If AllTrim(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_motDesICMS:TEXT")) == "7" .And. &("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_CST:TEXT") == "30"
									nValICM  := 0
								Else
									nValICM  := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_vICMS:TEXT"))
								EndIf
							EndIf
						EndIf
						If Type("oImposto:_Imposto:_ICMS:_ICMSST")<>"U" // Tratamento para 4.0
							cSitTrib := &("oImposto:_Imposto:_ICMS:_ICMSST:_ORIG:TEXT")
							cSitTrib += &("oImposto:_Imposto:_ICMS:_ICMSST:_CST:TEXT")
						Else
							cSitTrib := &("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_ORIG:TEXT")
							cSitTrib += &("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_CST:TEXT")
						EndIf
					EndIf
				Next nY

				//Tratamento para o ICMS para optantes pelo Simples Nacional
				If Type("oEmitente:_CRT") <> "U" .And. oEmitente:_CRT:TEXT == "1"
					nLenSit := Len(aSitSN)
					For nY := 1 To nLenSit
						nPrivate2 := nY
						If Type("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nPrivate2])<>"U"
							If Type("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nPrivate2]+":_VBC:TEXT")<>"U"
								nBaseICM := Val(&("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nY]+":_VBC:TEXT"))
								nValICM  := Val(&("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nY]+":_vICMS:TEXT"))
								nPICM    := Val(&("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nY]+":_PICMS:TEXT"))
							EndIf
							cSitTrib := &("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nY]+":_ORIG:TEXT")
							cSitTrib += &("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nY]+":_CSOSN:TEXT")
						EndIf
					Next nY
				EndIf

			EndIf
			If Type("oImposto:_Imposto:_IPI")<>"U"
				If Type("oImposto:_Imposto:_IPI:_IPITrib:_vIPI:TEXT")<>"U"
					nValIPI := Val(oImposto:_Imposto:_IPI:_IPITrib:_vIPI:TEXT)
				EndIf
				If Type("oImposto:_Imposto:_IPI:_IPITrib:_pIPI:TEXT")<>"U"
					nPIPI   := Val(oImposto:_Imposto:_IPI:_IPITrib:_pIPI:TEXT)
				EndIf
			EndIf
		EndIf

		nMaxCod := MaxCod(oDet[nX]:_Prod:_cProd:TEXT, 50)

		// Tratamento para quebrar os digitos dos valores
		aAux := {}
		AADD(aAux, AllTrim(TransForm(nQtd,TM(nQtd,TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2]))))
		AADD(aAux, AllTrim(TransForm(nVUnit,TM(nVUnit,TamSX3("D2_PRCVEN")[1],TamSX3("D2_PRCVEN")[2]))))
		AADD(aAux, AllTrim(TransForm(nVTotal,TM(nVTotal,TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2]))))
		AADD(aAux, AllTrim(TransForm(nBaseICM,TM(nBaseICM,TamSX3("D2_BASEICM")[1],TamSX3("D2_BASEICM")[2]))))
		AADD(aAux, AllTrim(TransForm(nValICM,TM(nValICM,TamSX3("D2_VALICM")[1],TamSX3("D2_VALICM")[2]))))
		AADD(aAux, AllTrim(TransForm(nValIPI,TM(nValIPI,TamSX3("D2_VALIPI")[1],TamSX3("D2_BASEIPI")[2]))))

		//Especifico Adoro
		//Mauricio - Tratamento para quebra de linha sem cortar palavra - 25/03/11.
		_cDescri  := NoChar(oDet[nX]:_Prod:_xProd:TEXT,lConverte)
		If Alltrim(oDet[nX]:_Prod:_cEAN:TEXT) <> ""
			_cDescri  += " GTIN: " + NoChar(oDet[nX]:_Prod:_cEAN:TEXT,lConverte)	
		Endif	
		_nLinDesc := MlCount(_cDescri,43)
		//
		aadd(aItens,{;
			SubStr(oDet[nX]:_Prod:_cProd:TEXT,1,nMaxCod),;
			/*SubStr(NoChar(oDet[nX]:_Prod:_xProd:TEXT,lConverte),1,nMaxDes),*//*Desabilitado padrao incluido Especifico Adoro*/	Memoline(ALLTRIM(_cDescri),nMaxDes,1),;
			IIF(Type("oDet[nPrivate]:_Prod:_NCM")=="U","",oDet[nX]:_Prod:_NCM:TEXT),;
			cSitTrib,;
			oDet[nX]:_Prod:_CFOP:TEXT,;
			oDet[nX]:_Prod:_utrib:TEXT,;
			SubStr(aAux[1], 1, PosQuebrVal(aAux[1])),;
			SubStr(aAux[2], 1, PosQuebrVal(aAux[2])),;
			SubStr(aAux[3], 1, PosQuebrVal(aAux[3])),;
			SubStr(aAux[4], 1, PosQuebrVal(aAux[4])),;
			SubStr(aAux[5], 1, PosQuebrVal(aAux[5])),;
			SubStr(aAux[6], 1, PosQuebrVal(aAux[6])),;
			AllTrim(TransForm(nPICM,"@r 99.99%")),;
			AllTrim(TransForm(nPIPI,"@r 99.99%"));
		})

		// Tratamento somente para o estado de MG, para totalizar por CFOP conforme RICMS-MG
		If lUf_MG
			aadd(aItensAux,{;
				SubStr(oDet[nX]:_Prod:_cProd:TEXT,1,nMaxCod),;
				SubStr(NoChar(oDet[nX]:_Prod:_xProd:TEXT,lConverte),1,nMaxDes),;
				IIF(Type("oDet[nPrivate]:_Prod:_NCM")=="U","",oDet[nX]:_Prod:_NCM:TEXT),;
				cSitTrib,;
				oDet[nX]:_Prod:_CFOP:TEXT,;
				oDet[nX]:_Prod:_utrib:TEXT,;
				SubStr(aAux[1], 1, PosQuebrVal(aAux[1])),;
				SubStr(aAux[2], 1, PosQuebrVal(aAux[2])),;
				SubStr(aAux[3], 1, PosQuebrVal(aAux[3])),;
				SubStr(aAux[4], 1, PosQuebrVal(aAux[4])),;
				SubStr(aAux[5], 1, PosQuebrVal(aAux[5])),;
				SubStr(aAux[6], 1, PosQuebrVal(aAux[6])),;
				AllTrim(TransForm(nPICM,"@r 99.99%")),;
				AllTrim(TransForm(nPIPI,"@r 99.99%")),;
				StrZero( ++nSequencia, 4 ),;
				nVTotal;
			})
		Endif
		// Tramento quando houver diferen็a entre as unidades uCom e uTrib ( SEFAZ MT )
		//Especifico Adoro Incluido para imprimir segunda linha somente para notas exporta็ใo - por Adriana em 21/05/2018 chamado 041617

		cAuxItem	:= ""
		cAux 		:= ""                                                    

		If SD2->D2_EST = "EX"
			
			cUnCom		:= oDet[nX]:_Prod:_uCom:TEXT
			nQtdCom		:= Val(oDet[nX]:_Prod:_qCom:TEXT)
			nVUnitCom	:= Val(oDet[nX]:_Prod:_vUnCom:TEXT)

			aAuxCom := {}
			AADD(aAuxCom, AllTrim(TransForm(nQtdCom,TM(nQtdCom,TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2]))))
			AADD(aAuxCom, AllTrim(TransForm(nVUnitCom,TM(nVUnitCom,TamSX3("D2_PRCVEN")[1],TamSX3("D2_PRCVEN")[2]))))

			IF _nLinDesc = 2
				aadd(aItens,{;
						"",;
						Memoline(ALLTRIM(_cDescri),nMaxDes,2),;
						"",;
						"",;
						"",;
						cUnCom,;
						SubStr(aAuxCom[1], 1, PosQuebrVal(aAuxCom[1])),;
						SubStr(aAuxCom[2], 1, PosQuebrVal(aAuxCom[2])),;
						"",;
						"",;
						"",;
						"",;
						"",;
						""})
			ElseIF _nLinDesc > 2
				aadd(aItens,{;
						"",;
						Memoline(ALLTRIM(_cDescri),nMaxDes,2),;
						"",;
						"",;
						"",;
						"",;
						"",;
						"",;
						"",;
						"",;
						"",;
						"",;
						"",;
						""})
			else
				aadd(aItens,{;
					"",;
					"",;
					"",;
					"",;
					"",;
					cUnCom,;
					SubStr(aAuxCom[1], 1, PosQuebrVal(aAuxCom[1])),;
					SubStr(aAuxCom[2], 1, PosQuebrVal(aAuxCom[2])),;
					"",;
					"",;
					"",;
					"",;
					"",;
					"";
					})
			endif
		Else	
			IF _nLinDesc > 1
				aadd(aItens,{"",;
						Memoline(ALLTRIM(_cDescri),nMaxDes,2),;
						"",;
						"",;
						"",;
						"",;
						"",;
						"",;
						"",;
						"",;
						"",;
						"",;
						"",;
						""})
			Endif

		Endif

		lPontilhado := .F.	
		While !Empty(cAux) .Or. !Empty(cAuxItem)
			nMaxCod := MaxCod(cAuxItem, 50)
			
			aadd(aItens,{;
				SubStr(cAuxItem,1,nMaxCod),;
				SubStr(cAux,1,nMaxDes),;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				""})
			cAux 		:= 	SubStr(cAux,(nMaxDes+1))
			cAuxItem	:=	SubStr(cAuxItem,nMaxCod+1)
			lPontilhado := .T.	
		EndDo
		
		If (Type("oNf:_infnfe:_det[nPrivate]:_Infadprod:TEXT") <> "U" .Or. Type("oNf:_infnfe:_det:_Infadprod:TEXT") <> "U") .And. ( lImpAnfav .Or. lImpInfAd )
			cAux := stripTags(AllTrim(SubStr(oDet[nX]:_Infadprod:TEXT,1)), .T.)
			
			While !Empty(cAux)
				aadd(aItens,{;
					"",;
					SubStr(cAux,1,nMaxDes),;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"";
				})
				cAux := SubStr(cAux,(nMaxDes + 1))
				lPontilhado := .T.	
			EndDo
		EndIf
		//Fim tratamento para nota de exportacao
		
	Next nZ

	//----------------------------------------------------------------------------------
	// Tratamento somente para o estado de MG, para totalizar por CFOP conforme RICMS-MG
	//----------------------------------------------------------------------------------
	If lUf_MG
		If 	Len( aItensAux ) > 0
			aItensAux	:= aSort( aItensAux,,, { |x,y| x[5]+x[15] < y[5]+y[15] } )
			nSubTotal	:= 0
			aItens		:= {}
			cCfop		:= aItensAux[1,5]
			cCfopAnt	:= aItensAux[1,5]

			For nX := 1 To Len( aItensAux )

				aArray		:= ARRAY(14)

				aArray[01]	:= aItensAux[nX,01]
				aArray[02]	:= aItensAux[nX,02]
				aArray[03]	:= aItensAux[nX,03]
				aArray[04]	:= aItensAux[nX,04]

				If Empty( aItensAux[nX,03] ) .Or. aItensAux[nX,03] == "-"
					aArray[05] := ""
				Else
					aArray[05] := aItensAux[nX,05]
				Endif

				aArray[06]	:= aItensAux[nX,06]
				aArray[07]	:= aItensAux[nX,07]
				aArray[08]	:= aItensAux[nX,08]
				aArray[09]	:= aItensAux[nX,09]
				aArray[10]	:= aItensAux[nX,10]
				aArray[11]	:= aItensAux[nX,11]
				aArray[12]	:= aItensAux[nX,12]
				aArray[13]	:= aItensAux[nX,13]
				aArray[14]	:= aItensAux[nX,14]

				If aItensAux[nX,5] == cCfop

					aadd( aItens, {;
						aArray[01],;
						aArray[02],;
						aArray[03],;
						aArray[04],;
						aArray[05],;
						aArray[06],;
						aArray[07],;
						aArray[08],;
						aArray[09],;
						aArray[10],;
						aArray[11],;
						aArray[12],;
						aArray[13],;
						aArray[14];
					} )

					nSubTotal += aItensAux[nX,16]

				Else

					aadd(aItens,{;
						"-",;
						"-",;
						"-",;
						"-",;
						"-",;
						"-",;
						"-",;
						"-",;
						"-",;
						"-",;
						"-",;
						"-",;
						"-",;
						"-";
					})

					aadd(aItens,{;
						"",;
						"SUB-TOTAL",;
						"",;
						"",;
						"",;
						"",;
						"",;
						"",;
						AllTrim(TransForm(nSubTotal,TM(nSubTotal,TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2]))),;
						"",;
						"",;
						"",;
						"",;
						"";
					})

					aadd(aItens,{;
						"",;
						"",;
						"",;
						"",;
						"",;
						"",;
						"",;
						"",;
						"",;
						"",;
						"",;
						"",;
						"",;
						"";
					})

					cCfop 		:= aItensAux[nX,05]
					nSubTotal 	:= aItensAux[nX,16]

					aadd( aItens, {;
						aArray[01],;
						aArray[02],;
						aArray[03],;
						aArray[04],;
						aArray[05],;
						aArray[06],;
						aArray[07],;
						aArray[08],;
						aArray[09],;
						aArray[10],;
						aArray[11],;
						aArray[12],;
						aArray[13],;
						aArray[14];
					} )

				Endif

			Next nX

			If cCfopAnt <> cCfop .And. nSubTotal > 0

				aadd(aItens,{;
					"-",;
					"-",;
					"-",;
					"-",;
					"-",;
					"-",;
					"-",;
					"-",;
					"-",;
					"-",;
					"-",;
					"-",;
					"-",;
					"-";
				})

				aadd(aItens,{;
					"",;
					"SUB-TOTAL",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					AllTrim(TransForm(nSubTotal,TM(nSubTotal,TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2]))),;
					"",;
					"",;
					"",;
					"",;
					"";
				})

			Endif

		Endif

	Endif


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณQuadro ISSQN                                                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aISSQN := {"","","",""}
	If Type("oEmitente:_IM:TEXT")<>"U"
		aISSQN[1] := oEmitente:_IM:TEXT
	EndIf
	If Type("oTotal:_ISSQNtot")<>"U"
		aISSQN[2] := Transform(Val(oTotal:_ISSQNtot:_vServ:TEXT),"@e 999,999,999.99")
		aISSQN[3] := Transform(Val(oTotal:_ISSQNtot:_vBC:TEXT),"@e 999,999,999.99")
		If Type("oTotal:_ISSQNtot:_vISS:TEXT") <> "U"
			aISSQN[4] := Transform(Val(oTotal:_ISSQNtot:_vISS:TEXT),"@e 999,999,999.99")
		EndIf
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณQuadro de informacoes complementares                                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If Type("oIdent:_DHCONT:TEXT")<>"U"
		cDhCont:= oIdent:_DHCONT:TEXT
	EndIf
	If Type("oIdent:_XJUST:TEXT")<>"U"
		cXJust:=oIdent:_XJUST:TEXT
	EndIf

	aMensagem := {}
	If Type("oIdent:_tpAmb:TEXT")<>"U" .And. oIdent:_tpAmb:TEXT=="2"
		cAux := "DANFE emitida no ambiente de homologa็ใo - SEM VALOR FISCAL"
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	EndIf

	If Type("oNF:_InfNfe:_infAdic:_infAdFisco:TEXT")<>"U"
		cAux := oNF:_InfNfe:_infAdic:_infAdFisco:TEXT
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	EndIf

	If !Empty(cCodAutSef) .AND. oIdent:_tpEmis:TEXT<>"4"
		cAux := "Protocolo: "+cCodAutSef
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	ElseIf !Empty(cCodAutSef) .AND. oIdent:_tpEmis:TEXT=="4" .AND. cModalidade $ "1"
		cAux := "Protocolo: "+cCodAutSef
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
		cAux := "DANFE emitida anteriormente em conting๊ncia DPEC"
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	EndIf

	If !Empty(cCodAutDPEC) .And. oIdent:_tpEmis:TEXT=="4"
		cAux := "N๚mero de Registro DPEC: "+cCodAutDPEC
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	EndIf

	If (Type("oIdent:_tpEmis:TEXT")<>"U" .And. !oIdent:_tpEmis:TEXT$"1,4")
		cAux := "DANFE emitida em conting๊ncia"
		If !Empty(cXJust) .and. !Empty(cDhCont) .and. oIdent:_tpEmis:TEXT$"6,7"// SVC-AN e SVC-RS Deve ser impresso o xjust e dhcont
			cAux += " Motivo da ado็ใo da conting๊ncia: "+cXJust+ " Data e hora de inํcio de utiliza็ใo: "+cDhCont
		EndIf
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	ElseIf (!Empty(cModalidade) .And. !cModalidade $ "1,4,5") .And. Empty(cCodAutSef)
		cAux := "DANFE emitida em conting๊ncia devido a problemas t้cnicos - serแ necessแria a substitui็ใo."
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	ElseIf (!Empty(cModalidade) .And. cModalidade $ "5" .And. oIdent:_tpEmis:TEXT=="4")
		cAux := "DANFE impresso em conting๊ncia"
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
		cAux := "DPEC regularmento recebido pela Receita Federal do Brasil."
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	ElseIf (Type("oIdent:_tpEmis:TEXT")<>"U" .And. oIdent:_tpEmis:TEXT$"5")
		cAux := "DANFE emitida em conting๊ncia FS-DA"
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	EndIf

	If Type("oNF:_InfNfe:_infAdic:_infCpl:TEXT")<>"U"
		If at("<", oNF:_InfNfe:_infAdic:_InfCpl:TEXT) <> 0
			cAux := stripTags(oNF:_InfNfe:_infAdic:_InfCpl:TEXT, .T.) + " "
			cAux += stripTags(oNF:_InfNfe:_infAdic:_InfCpl:TEXT, .F.)
		else
			cAux := stripTags(oNF:_InfNfe:_infAdic:_InfCpl:TEXT, .T.)
		endIf
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	EndIf

	If MV_PAR04 == 2
		//impressao do valor do desconto calculdo conforme decreto 43.080/02 RICMS-MG
		nRecSF3 := SF3->(Recno())
		SF3->(dbSetOrder(4))
		SF3->(MsSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE))
		While !SF3->(Eof()) .And. SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE == SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE
			If SF3->(FieldPos("F3_DS43080"))<>0 .And. SF3->F3_DS43080 > 0
				cAux := "Base de calc.reduzida conf.Art.43, Anexo IV, Parte 1, Item 3 do RICMS-MG. Valor da deducao ICMS R$ "
				cAux += Alltrim(Transform(SF3->F3_DS43080,"@e 9,999,999,999,999.99")) + " ref.reducao de base de calculo"
				While !Empty(cAux)
					aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
					cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
				EndDo
			EndIf
			SF3->(dbSkip())
		EndDo
		SF3->(dbGoTo(nRecSF3))
	ElseIf MV_PAR04 == 1
		//impressao do valor do desconto calculdo conforme decreto 43.080/02 RICMS-MG
		dbSelectArea("SF1")
		dbSetOrder(1)
		IF MsSeek(xFilial("SF1")+aNota[5]+aNota[4]+aNota[6]+aNota[7])
			dbSelectArea("SF3")
			dbSetOrder(4)
			If MsSeek(xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE)
				If SF3->(FieldPos("F3_DS43080"))<>0 .And. SF3->F3_DS43080 > 0
					cAux := "Base de calc.reduzida conf.Art.43, Anexo IV, Parte 1, Item 3 do RICMS-MG. Valor da deducao ICMS R$ "
					cAux += Alltrim(Transform(SF3->F3_DS43080,"@ze 9,999,999,999,999.99")) + " ref.reducao de base de calculo"
					While !Empty(cAux)
						aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
						cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
					EndDo
				EndIf
			EndIf
		EndIf
	EndIF

	For Nx := 1 to Len(aMensagem)
		NoChar(aMensagem[Nx],lConverte)
	Next

	If Type("oNF:_INFNFE:_IDE:_NFREF")<>"U"
		If Type("oNF:_INFNFE:_IDE:_NFREF") == "A"
			aInfNf := oNF:_INFNFE:_IDE:_NFREF
		Else
			aInfNf := {oNF:_INFNFE:_IDE:_NFREF}
		EndIf

		For nX := 1 to Len(aMensagem)
			If "ORIGINAL"$ Upper(aMensagem[nX])
				lNFori2 := .F.
			EndIf
		Next Nx

		cAux1 := ""
		cAux2 := ""
		For Nx := 1 to Len(aInfNf)
			If Type("aInfNf["+Str(nX)+"]:_REFNFE:TEXT")<>"U" .And. !AllTrim(aInfNf[nx]:_REFNFE:TEXT)$cAux1
				If !"CHAVE"$Upper(cAux1)
					If "65" $ substr (aInfNf[nx]:_REFNFE:TEXT,21,2)
						cAux1 += "Chave de acesso da NFC-E referenciada: "
					Else
					cAux1 += "Chave de acesso da NF-E referenciada: "
					Endif
				EndIf
				cAux1 += aInfNf[nx]:_REFNFE:TEXT+","
			ElseIf Type("aInfNf["+Str(nX)+"]:_REFNF:_NNF:TEXT")<>"U" .And. !AllTrim(aInfNf[nx]:_REFNF:_NNF:TEXT)$cAux2 .And. lNFori2
				If !"ORIGINAL"$Upper(cAux2)
					cAux2 += " Numero da nota original: "
				EndIf
				cAux2 += aInfNf[nx]:_REFNF:_NNF:TEXT+","
			EndIf
		Next

		cAux	:=	""
		If !Empty(cAux1)
			cAux1	:=	Left(cAux1,Len(cAux1)-1)
			cAux 	+= cAux1
		EndIf
		If !Empty(cAux2)
			cAux2	:=	Left(cAux2,Len(cAux2)-1)
			cAux 	+= 	Iif(!Empty(cAux),CRLF,"")+cAux2
		EndIf

		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo

		For Nx := 1 to Len(aMensagem)
			NoChar(aMensagem[Nx],lConverte)
		Next

	EndIf

	aResFisco := {}
	nBaseIcm  := 0

	If GetNewPar("MV_BCREFIS",.F.) .And. SuperGetMv("MV_ESTADO")$"PR"
		If Val(&("oTotal:_ICMSTOT:_VBCST:TEXT")) <> 0
			cAux := "Substitui็ใo Tributแria: Art. 471, II e ง1บ do RICMS/PR: "
			nLenDet := Len(oDet)
			For nX := 1 To nLenDet
				oImposto := oDet[nX]
				If Type("oImposto:_Imposto")<>"U"
					If Type("oImposto:_Imposto:_ICMS")<>"U"
						nLenSit := Len(aSitTrib)
						For nY := 1 To nLenSit
							nPrivate2 := nY
							If Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2])<>"U"
								If Type("oImposto:_IMPOSTO:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_VBCST:TEXT")<>"U"
									nBaseIcm := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_VBCST:TEXT"))
									cAux += oDet[nX]:_PROD:_CPROD:TEXT + ": BCICMS-ST R$" + AllTrim(TransForm(nBaseICM,TM(nBaseICM,TamSX3("D2_BASEICM")[1],TamSX3("D2_BASEICM")[2]))) + " / "
								Endif
							Endif
						Next nY
					Endif
				Endif
			Next nX
		Endif
		While !Empty(cAux)
			aadd(aResFisco,SubStr(cAux,1,60))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, 59, MAXMENLIN) +2)
		EndDo
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCalculo do numero de folhas                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nFolhas	  := 1
	nLenItens := Len(aItens) - MAXITEM // Todos os produtos/servi็os excluindo a primeira pแgina
	nMsgCompl := Len(aMensagem) - MAXMSG // Todas as mensagens complementares excluindo a primeira pแgina
	lFlag     := .T.
	While lFlag
		// Caso existam produtos/servi็os e mensagens complementares a serem escritas
		If nLenItens > 0 .And. nMsgCompl > 0
			nFolhas++
			// Se estiver habilitado frente e verso e for uma pแgina impar
			If MV_PAR05 == 1 .And. (nFolhas % 2) == 0
				nLenItens -= MAXITEMP3
			Else
				nLenItens -= MAXITEMP2
				nMsgCompl -= MAXMSG
			EndIf
		// Caso existam apenas mensagens complementares a serem escritas
		ElseIf nLenItens <= 0 .And. nMsgCompl > 0
			nFolhas++
			nMsgCompl := 0
		// Caso existam apenas produtos/servi็os a serem escritos
		ElseIf nLenItens > 0 .And. nMsgCompl <= 0
			nFolhas++
			// Se estiver habilitado frente e verso e for uma pแgina impar
			If MV_PAR05 == 1 .And. (nFolhas % 2) == 0
				nLenItens -= MAXITEMP3
			Else
				nLenItens -= MAXITEMP2F
			EndIf
		// Se nใo tiver mais nada a ser escrito fecha a contagem
		Else
			lFlag := .F.
		EndIf
	EndDo

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicializacao do objeto grafico                                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If oDanfe == Nil
		lPreview := .T.
		oDanfe 	:= FWMSPrinter():New("DANFE", IMP_SPOOL)
		oDanfe:SetPortrait()
		oDanfe:Setup()
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicializacao da pagina do objeto grafico                               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oDanfe:StartPage()
	nHPage := oDanfe:nHorzRes()
	nHPage *= (300/PixelX)
	nHPage -= HMARGEM
	nVPage := oDanfe:nVertRes()
	nVPage *= (300/PixelY)
	nVPage -= VBOX

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDefinicao do Box - Recibo de entrega                                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	oDanfe:Box(000,000,010,501)
	oDanfe:Say(006, 002, "RECEBEMOS DE "+NoChar(oEmitente:_xNome:Text,lConverte)+" OS PRODUTOS CONSTANTES DA NOTA FISCAL INDICADA AO LADO", oFont07:oFont)
	oDanfe:Box(009,000,047,101)
	oDanfe:Say(017, 002, "DATA DE RECEBIMENTO", oFont07N:oFont)
	oDanfe:Box(009,100,047,500)
	oDanfe:Say(017, 102, "IDENTIFICAวรO E ASSINATURA DO RECEBEDOR", oFont07N:oFont)
	oDanfe:Box(000,500,047,603)
	oDanfe:Say(007, 542, "NF-e", oFont08N:oFont)
	oDanfe:Say(017, 510, "N. "+StrZero(Val(oIdent:_NNf:Text),9), oFont08:oFont)
	oDanfe:Say(027, 510, "SษRIE "+oIdent:_Serie:Text, oFont08:oFont)
	oDanfe:Say(045, 590, " ("+xFilial("SF2")+") ", oFont07:oFont)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณQuadro 1 IDENTIFICACAO DO EMITENTE                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oDanfe:Box(060,000,143,250)
	//oDanfe:Say(052,098, "Identifica็ใo do emitente",oFont12N:oFont)
	oDanfe:Say(070,098, "Identifica็ใo do emitente",oFont12N:oFont)
	//nLinCalc	:=	065
	nLinCalc	:=	081
	cStrAux		:=	AllTrim(NoChar(oEmitente:_xNome:Text,lConverte))
	nForTo		:=	Len(cStrAux)/25
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		//oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*25)+1),25), oFont12N:oFont )
		oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*33)+1),33), oFont10N:oFont )
		nLinCalc+=10
	Next nX

	cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_xLgr:Text,lConverte))+", "+AllTrim(oEmitente:_EnderEmit:_Nro:Text)
	nForTo		:=	Len(cStrAux)/32
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
		nLinCalc+=10
	Next nX

	If Type("oEmitente:_EnderEmit:_xCpl") <> "U"
		cStrAux		:=	"Complemento: "+AllTrim(NoChar(oEmitente:_EnderEmit:_xCpl:TEXT,lConverte))
		nForTo		:=	Len(cStrAux)/32
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
			nLinCalc+=10
		Next nX

		cStrAux		:=	AllTrim(oEmitente:_EnderEmit:_xBairro:Text)
		If Type("oEmitente:_EnderEmit:_Cep")<>"U"
			cStrAux		+=	" Cep:"+TransForm(oEmitente:_EnderEmit:_Cep:Text,"@r 99999-999")
		EndIf
		nForTo		:=	Len(cStrAux)/32
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
			nLinCalc+=10
		Next nX
		oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
		nLinCalc+=10
		oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
	Else
		oDanfe:Say(nLinCalc,098, NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte)+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
		nLinCalc+=10
		oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
		nLinCalc+=10
		oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณQuadro 2                                                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							
	oDanfe:Box(060,248,143,351)
	oDanfe:Say(072,275, "DANFE",oFont16N:oFont)
	oDanfe:Say(080,258, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
	oDanfe:Say(090,258, "NOTA FISCAL ELETRิNICA",oFont07:oFont)
	oDanfe:Say(100,266, "0-ENTRADA",oFont08:oFont)
	oDanfe:Say(110,266, "1-SAอDA"  ,oFont08:oFont)
	oDanfe:Box(096,315,105,325)
	oDanfe:Say(102,318, oIdent:_TpNf:Text,oFont08N:oFont)
	oDanfe:Say(121,255,"N. "+StrZero(Val(oIdent:_NNf:Text),9),oFont10N:oFont)
	oDanfe:Say(131,255,"SษRIE "+oIdent:_Serie:Text,oFont10N:oFont)
	oDanfe:Say(141,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPreenchimento do Array de UF                                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aadd(aUF,{"RO","11"})
	aadd(aUF,{"AC","12"})
	aadd(aUF,{"AM","13"})
	aadd(aUF,{"RR","14"})
	aadd(aUF,{"PA","15"})
	aadd(aUF,{"AP","16"})
	aadd(aUF,{"TO","17"})
	aadd(aUF,{"MA","21"})
	aadd(aUF,{"PI","22"})
	aadd(aUF,{"CE","23"})
	aadd(aUF,{"RN","24"})
	aadd(aUF,{"PB","25"})
	aadd(aUF,{"PE","26"})
	aadd(aUF,{"AL","27"})
	aadd(aUF,{"MG","31"})
	aadd(aUF,{"ES","32"})
	aadd(aUF,{"RJ","33"})
	aadd(aUF,{"SP","35"})
	aadd(aUF,{"PR","41"})
	aadd(aUF,{"SC","42"})
	aadd(aUF,{"RS","43"})
	aadd(aUF,{"MS","50"})
	aadd(aUF,{"MT","51"})
	aadd(aUF,{"GO","52"})
	aadd(aUF,{"DF","53"})
	aadd(aUF,{"SE","28"})
	aadd(aUF,{"BA","29"})
	aadd(aUF,{"EX","99"})

	nHPage := oDanfe:nHorzRes()
	nHPage *= (300/PixelX)
	nHPage -= HMARGEM
	nVPage := oDanfe:nVertRes()
	nVPage *= (300/PixelY)
	nVPage -= VBOX

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณLogotipo                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lMv_Logod
		cLogoD := GetSrvProfString("Startpath","") + "DANFE" + cEmpAnt + cFilAnt + ".BMP"
		If !File(cLogoD)
			cLogoD	:= GetSrvProfString("Startpath","") + "DANFE" + cEmpAnt + ".BMP"
			If !File(cLogoD)
				lMv_Logod := .F.
			EndIf
		EndIf
	EndIf

	If nfolha==1
		If lMv_Logod
			oDanfe:SayBitmap(042,000,cLogoD,095,096)
		Else
			oDanfe:SayBitmap(042,000,cLogo,095,096)
		EndIF
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCodigo de barra                                                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	oDanfe:Box(060,350,094,603)
	oDanfe:Box(094,350,119,603)
	oDanfe:Box(119,350,143,603)
	oDanfe:Say(115,355,TransForm(SubStr(oNF:_InfNfe:_ID:Text,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont12N:oFont)

	If nFolha == 1
		oDanfe:Say(105,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
		nFontSize := 28
		oDanfe:Code128C(090,370,SubStr(oNF:_InfNfe:_ID:Text,4), nFontSize )
	EndIf

	If !Empty(cCodAutDPEC) .And. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"4" .And. !lUsaColab
		cDataEmi := Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",Substr(oNFe:_NFE:_INFNFE:_IDE:_DHEMI:Text,9,2),Substr(oNFe:_NFE:_INFNFE:_IDE:_DEMI:Text,9,2))
		cTPEmis  := "4"

		If Type("oDPEC:_ENVDPEC:_INFDPEC:_RESNFE") <> "U"
			cUF      := aUF[aScan(aUF,{|x| x[1] == oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_UF:Text})][02]
			cValIcm := StrZero(Val(StrTran(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VNF:TEXT,".","")),14)
			cICMSp := iif(Val(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VICMS:TEXT)>0,"1","2")
			cICMSs := iif(Val(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VST:TEXT)>0,"1","2")
		ElseIf type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST") <> "U" //EPEC NFE
			If Type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_UF:TEXT") <> "U"
				cUF := aUF[aScan(aUF,{|x| x[1] == oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_UF:TEXT})][02]
			EndIf
			If Type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VNF:TEXT") <> "U"
				cValIcm := StrZero(Val(StrTran(oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VNF:TEXT,".","")),14)
			EndIf
			If 	Type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VICMS:TEXT") <> "U"
				cICMSp:= IIf(Val(oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VICMS:TEXT) > 0,"1","2")
			EndIf
			If 	Type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VST:TEXT") <> "U"
				cICMSs := IIf(Val(oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VST:TEXT )> 0,"1","2")
			EndIf
		EndIf

	ElseIF (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25" .Or. ( (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"4" .And. lUsaColab .And. !Empty(cCodAutDPEC) )
		cUF      := aUF[aScan(aUF,{|x| x[1] == oNFe:_NFE:_INFNFE:_DEST:_ENDERDEST:_UF:Text})][02]
		cDataEmi := Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",Substr(oNFe:_NFE:_INFNFE:_IDE:_DHEMI:Text,9,2),Substr(oNFe:_NFE:_INFNFE:_IDE:_DEMI:Text,9,2))
		cTPEmis  := oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT
		cValIcm  := StrZero(Val(StrTran(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT,".","")),14)
		cICMSp   := iif(Val(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT)>0,"1","2")
		cICMSs   :=iif(Val(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:TEXT)>0,"1","2")
	EndIf
	If !Empty(cUF) .And. !Empty(cDataEmi) .And. !Empty(cTPEmis) .And. !Empty(cValIcm) .And. !Empty(cICMSp) .And. !Empty(cICMSs)
		If Type("oNF:_InfNfe:_DEST:_CNPJ:Text")<>"U"
			cCNPJCPF := oNF:_InfNfe:_DEST:_CNPJ:Text
			If cUf == "99"
				cCNPJCPF := STRZERO(val(cCNPJCPF),14)
			EndIf
		ElseIf Type("oNF:_INFNFE:_DEST:_CPF:Text")<>"U"
			cCNPJCPF := oNF:_INFNFE:_DEST:_CPF:Text
			cCNPJCPF := STRZERO(val(cCNPJCPF),14)
		Else
			cCNPJCPF := ""
		EndIf
		cChaveCont += cUF+cTPEmis+cCNPJCPF+cValIcm+cICMSp+cICMSs+cDataEmi
		cChaveCont := cChaveCont+Modulo11(cChaveCont)
	EndIf

	If Empty(cCodAutDPEC)
		If Empty(cChaveCont)
			oDanfe:Say(129,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
			oDanfe:Say(139,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
		Endif
	Endif

	If  !Empty(cCodAutDPEC)
		oDanfe:Say(117,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
		oDanfe:Say(127,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
	Endif

	// inicio do segundo codigo de barras ref. a transmissao CONTIGENCIA OFF LINE
	If !Empty(cChaveCont) .And. Empty(cCodAutDPEC) .And. !(Val(SubStr(oNF:_INFNFE:_IDE:_SERIE:TEXT,1,3)) >= 900)
		If nFolha == 1
			If !Empty(cChaveCont)
				nFontSize := 28
				//oDanfe:Code128C(135,370,cChaveCont, nFontSize )
				oDanfe:Code128C(145,370,cChaveCont, nFontSize )
			EndIf
		Else
			If !Empty(cChaveCont)
				nFontSize := 28
				//oDanfe:Code128C(112,370,cChaveCont, nFontSize )
				oDanfe:Code128C(122,370,cChaveCont, nFontSize )
			EndIf
		EndIf
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณQuadro 4                                                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	oDanfe:Box(145,000,162,603)
	oDanfe:Box(145,000,162,350)
	oDanfe:Say(151,002,"NATUREZA DA OPERAวรO",oFont08N:oFont)
	oDanfe:Say(161,002,oIdent:_NATOP:TEXT,oFont08:oFont)

	If !Empty(cCodAutDPEC)
		oDanfe:Say(151,350,"NฺMERO DE REGISTRO DPEC",oFont08N:oFont)
	Endif

	If Empty(cCodAutDPEC) .And. (((Val(SubStr(oNF:_INFNFE:_IDE:_SERIE:TEXT,1,3)) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"23") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1|6|7")
		oDanfe:Say(151,352,"PROTOCOLO DE AUTORIZAวรO DE USO",oFont08N:oFont)
	Endif
	If((oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25")
		oDanfe:Say(151,352,"DADOS DA NF-E",oFont08N:oFont)
	Endif
	oDanfe:Say(161,354,IIF(!Empty(cCodAutDPEC),cCodAutDPEC+" "+AllTrim(IIF(!Empty(dDtReceb),ConvDate(DTOS(dDtReceb)),Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",ConvDate(oNF:_InfNfe:_IDE:_DHEMI:Text),ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text))))+" "+AllTrim(cDtHrRecCab),IIF(!Empty(cCodAutSef) .And. ((Val(SubStr(oNF:_INFNFE:_IDE:_SERIE:TEXT,1,3)) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"23") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1|6|7",cCodAutSef+" "+AllTrim(IIF(!Empty(dDtReceb),ConvDate(DTOS(dDtReceb)),Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",ConvDate(oNF:_InfNfe:_IDE:_DHEMI:Text),ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text))))+" "+AllTrim(cDtHrRecCab),TransForm(cChaveCont,"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999"))),oFont08:oFont)

	nFolha++

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณQuadro 5                                                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oDanfe:Box(164,000,187,603)
	oDanfe:Box(164,000,187,200)
	oDanfe:Box(164,200,187,400)
	oDanfe:Box(164,400,187,603)
	oDanfe:Say(172,002,"INSCRIวรO ESTADUAL",oFont08N:oFont)
	oDanfe:Say(180,002,IIf(Type("oEmitente:_IE:TEXT")<>"U",oEmitente:_IE:TEXT,""),oFont08:oFont)
	oDanfe:Say(172,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
	oDanfe:Say(180,205,IIf(Type("oEmitente:_IEST:TEXT")<>"U",oEmitente:_IEST:TEXT,""),oFont08:oFont)
	oDanfe:Say(172,405,"CNPJ",oFont08N:oFont)
	oDanfe:Say(180,405,TransForm(oEmitente:_CNPJ:TEXT,IIf(Len(oEmitente:_CNPJ:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99")),oFont08:oFont)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณQuadro destinatแrio/remetente                                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Do Case
		Case Type("oDestino:_CNPJ")=="O"
			cAux := TransForm(oDestino:_CNPJ:TEXT,"@r 99.999.999/9999-99")
		Case Type("oDestino:_CPF")=="O"
			cAux := TransForm(oDestino:_CPF:TEXT,"@r 999.999.999-99")
		OtherWise
			cAux := Space(14)
	EndCase

	oDanfe:Say(195,002,"DESTINATARIO/REMETENTE",oFont08N:oFont)
	oDanfe:Box(197,000,217,450)
	oDanfe:Say(205,002, "NOME/RAZรO SOCIAL",oFont08N:oFont)
	oDanfe:Say(215,002,NoChar(oDestino:_XNome:TEXT,lConverte),oFont08:oFont)
	oDanfe:Box(197,280,217,500)
	oDanfe:Say(205,283,"CNPJ/CPF",oFont08N:oFont)
	oDanfe:Say(215,283,cAux,oFont08:oFont)

	oDanfe:Box(217,000,237,500)
	oDanfe:Box(217,000,237,260)
	oDanfe:Say(224,002,"ENDEREวO",oFont08N:oFont)
	oDanfe:Say(234,002,aDest[01],oFont08:oFont)
	oDanfe:Box(217,230,237,380)
	oDanfe:Say(224,232,"BAIRRO/DISTRITO",oFont08N:oFont)
	oDanfe:Say(234,232,aDest[02],oFont08:oFont)
	oDanfe:Box(217,380,237,500)
	oDanfe:Say(224,382,"CEP",oFont08N:oFont)
	oDanfe:Say(234,382,aDest[03],oFont08:oFont)

	oDanfe:Box(236,000,257,500)
	oDanfe:Box(236,000,257,180)
	oDanfe:Say(245,002,"MUNICIPIO",oFont08N:oFont)
	oDanfe:Say(255,002,aDest[05],oFont08:oFont)
	oDanfe:Box(236,150,257,256)
	oDanfe:Say(245,152,"FONE/FAX",oFont08N:oFont)
	oDanfe:Say(255,152,aDest[06],oFont08:oFont)
	oDanfe:Box(236,255,257,341)
	oDanfe:Say(245,257,"UF",oFont08N:oFont)
	oDanfe:Say(255,257,aDest[07],oFont08:oFont)
	oDanfe:Box(236,340,257,500)
	oDanfe:Say(245,342,"INSCRIวรO ESTADUAL",oFont08N:oFont)
	oDanfe:Say(255,342,aDest[08],oFont08:oFont)


	oDanfe:Box(197,502,217,603)
	oDanfe:Say(205,504,"DATA DE EMISSรO",oFont08N:oFont)
	oDanfe:Say(215,504,Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",ConvDate(oIdent:_DHEmi:TEXT),ConvDate(oIdent:_DEmi:TEXT)),oFont08:oFont)
	oDanfe:Box(217,502,237,603)
	oDanfe:Say(224,504,"DATA ENTRADA/SAอDA",oFont08N:oFont)
	oDanfe:Say(233,504,Iif( Empty(aDest[4]),"",ConvDate(aDest[4]) ),oFont08:oFont)
	oDanfe:Box(236,502,257,603)
	oDanfe:Say(243,503,"HORA ENTRADA/SAอDA",oFont08N:oFont)
	oDanfe:Say(252,503,aHrEnt[01],oFont08:oFont)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณQuadro fatura                                                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aAux := {{{},{},{},{},{},{},{},{},{}}}
	nY := 0
	For nX := 1 To Len(aFaturas)
		nY++
		aadd(Atail(aAux)[nY],aFaturas[nX][1])
		nY++
		aadd(Atail(aAux)[nY],aFaturas[nX][2])
		nY++
		aadd(Atail(aAux)[nY],aFaturas[nX][3])
		nY++
		aadd(Atail(aAux)[nY],aFaturas[nX][4])
		nY++
		aadd(Atail(aAux)[nY],aFaturas[nX][5])
		nY++
		aadd(Atail(aAux)[nY],aFaturas[nX][6])
		nY++
		aadd(Atail(aAux)[nY],aFaturas[nX][7])
		nY++
		aadd(Atail(aAux)[nY],aFaturas[nX][8])
		nY++
		aadd(Atail(aAux)[nY],aFaturas[nX][9])
		If nY >= 9
			nY := 0
		EndIf
	Next nX

	oDanfe:Say(263,002,"FATURA",oFont08N:oFont)
	oDanfe:Box(265,000,296,068)
	oDanfe:Box(265,067,296,134)
	oDanfe:Box(265,134,296,202)
	oDanfe:Box(265,201,296,268)
	oDanfe:Box(265,268,296,335)
	oDanfe:Box(265,335,296,403)
	oDanfe:Box(265,402,296,469)
	oDanfe:Box(265,469,296,537)
	oDanfe:Box(265,536,296,603)

	nColuna := 002
	If Len(aFaturas) >0
		For nY := 1 To 9
			oDanfe:Say(273,nColuna,aAux[1][nY][1],oFont08:oFont)
			oDanfe:Say(281,nColuna,aAux[1][nY][2],oFont08:oFont)
			oDanfe:Say(289,nColuna,aAux[1][nY][3],oFont08:oFont)
			nColuna:= nColuna+67
		Next nY
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCalculo do imposto                                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oDanfe:Say(305,002,"CALCULO DO IMPOSTO",oFont08N:oFont)
	oDanfe:Box(307,000,330,121)
	oDanfe:Say(316,002,"BASE DE CALCULO DO ICMS",oFont08N:oFont)
	If cMVCODREG $ "2|3"
		oDanfe:Say(326,002,aTotais[01],oFont08:oFont)
	ElseIf lImpSimpN
		oDanfe:Say(326,002,aSimpNac[01],oFont08:oFont)
	Endif
	oDanfe:Box(307,120,330,200)
	oDanfe:Say(316,125,"VALOR DO ICMS",oFont08N:oFont)
	If cMVCODREG $ "2|3"
		oDanfe:Say(326,125,aTotais[02],oFont08:oFont)
	ElseIf lImpSimpN
		oDanfe:Say(326,125,aSimpNac[02],oFont08:oFont)
	Endif
	oDanfe:Box(307,199,330,360)
	oDanfe:Say(316,200,"BASE DE CALCULO DO ICMS SUBSTITUIวรO",oFont08N:oFont)
	oDanfe:Say(326,202,aTotais[03],oFont08:oFont)
	oDanfe:Box(307,360,330,490)
	oDanfe:Say(316,363,"VALOR DO ICMS SUBSTITUIวรO",oFont08N:oFont)
	oDanfe:Say(326,363,aTotais[04],oFont08:oFont)
	oDanfe:Box(307,490,330,603)
	oDanfe:Say(316,491,"VALOR TOTAL DOS PRODUTOS",oFont08N:oFont)
	oDanfe:Say(327,491,aTotais[05],oFont08:oFont)
	oDanfe:Box(330,000,353,110)
	oDanfe:Say(339,002,"VALOR DO FRETE",oFont08N:oFont)
	oDanfe:Say(349,002,aTotais[06],oFont08:oFont)
	oDanfe:Box(330,100,353,190)
	oDanfe:Say(339,102,"VALOR DO SEGURO",oFont08N:oFont)
	oDanfe:Say(349,102,aTotais[07],oFont08:oFont)
	oDanfe:Box(330,190,353,290)
	oDanfe:Say(339,194,"DESCONTO",oFont08N:oFont)
	oDanfe:Say(349,194,aTotais[08],oFont08:oFont)
	oDanfe:Box(330,290,353,415)
	oDanfe:Say(339,295,"OUTRAS DESPESAS ACESSำRIAS",oFont08N:oFont)
	oDanfe:Say(349,295,aTotais[09],oFont08:oFont)
	oDanfe:Box(330,414,353,500)
	oDanfe:Say(339,420,"VALOR DO IPI",oFont08N:oFont)
	oDanfe:Say(349,420,aTotais[10],oFont08:oFont)
	oDanfe:Box(330,500,353,603)
	oDanfe:Say(339,506,"VALOR TOTAL DA NOTA",oFont08N:oFont)
	oDanfe:Say(349,506,aTotais[11],oFont08:oFont)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTransportador/Volumes transportados                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oDanfe:Say(361,002,"TRANSPORTADOR/VOLUMES TRANSPORTADOS",oFont08N:oFont)
	oDanfe:Box(363,000,386,603)
	oDanfe:Say(372,002,"RAZรO SOCIAL",oFont08N:oFont)
	oDanfe:Say(382,002,aTransp[01],oFont08:oFont)
	oDanfe:Box(363,245,386,315)
	oDanfe:Say(372,247,"FRETE POR CONTA",oFont08N:oFont)
	If cModFrete =="0"
		oDanfe:Say(382,247,"0-EMITENTE",oFont08:oFont)
	ElseIf cModFrete =="1"
		oDanfe:Say(382,247,"1-DEST/REM",oFont08:oFont)
	ElseIf cModFrete =="2"
		oDanfe:Say(382,247,"2-TERCEIROS",oFont08:oFont)
	ElseIf cModFrete =="3"
		oDanfe:Say(382,247,"3-REMETENTE",oFont08:oFont)
	ElseIf cModFrete =="4"
		oDanfe:Say(382,247,"4-DESTINATARIO",oFont08:oFont)
	ElseIf cModFrete =="9"
		oDanfe:Say(382,247,"9-SEM FRETE",oFont08:oFont)
	Else
		oDanfe:Say(382,247,"",oFont08:oFont)
	Endif
	oDanfe:Box(363,315,386,370)
	oDanfe:Say(372,317,"CำDIGO ANTT",oFont08N:oFont)
	oDanfe:Say(382,319,aTransp[03],oFont08:oFont)
	oDanfe:Box(363,370,386,490)
	oDanfe:Say(372,375,"PLACA DO VEอCULO",oFont08N:oFont)
	oDanfe:Say(382,375,aTransp[04],oFont08:oFont)
	oDanfe:Box(363,450,386,510)
	oDanfe:Say(372,452,"UF",oFont08N:oFont)
	oDanfe:Say(382,452,aTransp[05],oFont08:oFont)
	oDanfe:Box(363,510,386,603)
	oDanfe:Say(372,512,"CNPJ/CPF",oFont08N:oFont)
	oDanfe:Say(382,512,aTransp[06],oFont08:oFont)
	oDanfe:Box(385,000,409,603)
	oDanfe:Box(385,000,409,241)
	oDanfe:Say(393,002,"ENDEREวO",oFont08N:oFont)
	oDanfe:Say(404,002,aTransp[07],oFont08:oFont)
	oDanfe:Box(385,240,409,341)
	oDanfe:Say(393,242,"MUNICIPIO",oFont08N:oFont)
	oDanfe:Say(404,242,aTransp[08],oFont08:oFont)
	oDanfe:Box(385,340,409,440)
	oDanfe:Say(393,342,"UF",oFont08N:oFont)
	oDanfe:Say(404,342,aTransp[09],oFont08:oFont)
	oDanfe:Box(385,440,409,603)
	oDanfe:Say(393,442,"INSCRIวรO ESTADUAL",oFont08N:oFont)
	oDanfe:Say(404,442,aTransp[10],oFont08:oFont)
	oDanfe:Box(408,000,432,603)
	oDanfe:Box(408,000,432,101)
	oDanfe:Say(418,002,"QUANTIDADE",oFont08N:oFont)
	oDanfe:Say(428,002,aTransp[11],oFont08:oFont)
	oDanfe:Box(408,100,432,200)
	oDanfe:Say(418,102,"ESPECIE",oFont08N:oFont)
	oDanfe:Say(428,102,Iif(!Empty(aTransp[12]),aTransp[12],Iif(Len(aEspVol)>0,aEspVol[1][1],"")),oFont08:oFont)
	//oDanfe:Say(428,102,aEspVol[1][1],oFont08:oFont)
	oDanfe:Box(408,200,432,301)
	oDanfe:Say(418,202,"MARCA",oFont08N:oFont)
	oDanfe:Say(428,202,aTransp[13],oFont08:oFont)
	oDanfe:Box(408,300,432,400)
	oDanfe:Say(418,302,"NUMERAวรO",oFont08N:oFont)
	oDanfe:Say(428,302,aTransp[14],oFont08:oFont)
	oDanfe:Box(408,400,432,501)
	oDanfe:Say(418,402,"PESO BRUTO",oFont08N:oFont)
	oDanfe:Say(428,402,Iif(!Empty(aTransp[15]),aTransp[15],Iif(Len(aEspVol)>0 .And. Val(aEspVol[1][3])>0,Transform(Val(aEspVol[1][3]),"@E 999999.9999"),"")),oFont08:oFont)
	//oDanfe:Say(428,402,Iif (!Empty(aEspVol[1][3]),Transform(val(aEspVol[1][3]),"@E 999999.9999"),""),oFont08:oFont)
	oDanfe:Box(408,500,432,603)
	oDanfe:Say(418,502,"PESO LIQUIDO",oFont08N:oFont)
	oDanfe:Say(428,502,Iif(!Empty(aTransp[16]),aTransp[16],Iif(Len(aEspVol)>0 .And. Val(aEspVol[1][2])>0,Transform(Val(aEspVol[1][2]),"@E 999999.9999"),"")),oFont08:oFont)
	//oDanfe:Say(428,502,Iif (!Empty(aEspVol[1][2]),Transform(val(aEspVol[1][2]),"@E 999999.9999"),""),oFont08:oFont)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCalculo do ISSQN                                                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	oDanfe:Say(686,000,"CALCULO DO ISSQN",oFont08N:oFont)
	oDanfe:Box(688,000,711,151)
	oDanfe:Say(696,002,"INSCRIวรO MUNICIPAL",oFont08N:oFont)
	oDanfe:Say(706,002,aISSQN[1],oFont08:oFont)
	oDanfe:Box(688,150,711,301)
	oDanfe:Say(696,152,"VALOR TOTAL DOS SERVIวOS",oFont08N:oFont)
	oDanfe:Say(706,152,aISSQN[2],oFont08:oFont)
	oDanfe:Box(688,300,711,451)
	oDanfe:Say(696,302,"BASE DE CมLCULO DO ISSQN",oFont08N:oFont)
	oDanfe:Say(706,302,aISSQN[3],oFont08:oFont)
	oDanfe:Box(688,450,711,603)
	oDanfe:Say(696,452,"VALOR DO ISSQN",oFont08N:oFont)
	oDanfe:Say(706,452,aISSQN[4],oFont08:oFont)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDados Adicionais                                                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oDanfe:Say(719,000,"DADOS ADICIONAIS",oFont08N:oFont)
	oDanfe:Box(721,000,865,351)
	oDanfe:Say(729,002,"INFORMAวีES COMPLEMENTARES",oFont08N:oFont)

	nLenMensagens:= Len(aMensagem)
	nLin:= 741
	nMensagem := 0
	For nX := 1 To Min(nLenMensagens, MAXMSG)
		oDanfe:Say(nLin,002,aMensagem[nX],oFont08:oFont)
		nLin:= nLin+10
	Next nX
	nMensagem := nX

	oDanfe:Box(721,350,865,603)
	oDanfe:Say(729,352,"RESERVADO AO FISCO",oFont08N:oFont)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณLogotipo Rodape
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	if file(cLogoTotvs) .or. Resource2File ( cLogoTotvs, cStartPath+cLogoTotvs )
		oDanfe:SayBitmap(866,484,cLogoTotvs,120,20)
	endif

	nLenMensagens:= Len(aResFisco)
	nLin:= 741
	For nX := 1 To Min(nLenMensagens, MAXMSG)
		oDanfe:Say(nLin,351,aResFisco[nX],oFont08:oFont)
		nLin:= nLin+10
	Next

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDados do produto ou servico                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aAux := {{{},{},{},{},{},{},{},{},{},{},{},{},{},{}}}
	nY := 0
	nLenItens := Len(aItens)

	For nX :=1 To nLenItens
		nY++
		aadd(Atail(aAux)[nY],aItens[nX][01])
		nY++
		aadd(Atail(aAux)[nY],NoChar(aItens[nX][02],lConverte))
		nY++
		aadd(Atail(aAux)[nY],aItens[nX][03])
		nY++
		aadd(Atail(aAux)[nY],aItens[nX][04])
		nY++
		aadd(Atail(aAux)[nY],aItens[nX][05])
		nY++
		aadd(Atail(aAux)[nY],aItens[nX][06])
		nY++
		aadd(Atail(aAux)[nY],aItens[nX][07])
		nY++
		aadd(Atail(aAux)[nY],aItens[nX][08])
		nY++
		aadd(Atail(aAux)[nY],aItens[nX][09])
		nY++
		aadd(Atail(aAux)[nY],aItens[nX][10])
		nY++
		aadd(Atail(aAux)[nY],aItens[nX][11])
		nY++
		aadd(Atail(aAux)[nY],aItens[nX][12])
		nY++
		aadd(Atail(aAux)[nY],aItens[nX][13])
		nY++
		aadd(Atail(aAux)[nY],aItens[nX][14])
		If nY >= 14
			nY := 0
		EndIf
	Next nX
	For nX := 1 To nLenItens
		nY++
		aadd(Atail(aAux)[nY],"")
		nY++
		aadd(Atail(aAux)[nY],"")
		nY++
		aadd(Atail(aAux)[nY],"")
		nY++
		aadd(Atail(aAux)[nY],"")
		nY++
		aadd(Atail(aAux)[nY],"")
		nY++
		aadd(Atail(aAux)[nY],"")
		nY++
		aadd(Atail(aAux)[nY],"")
		nY++
		aadd(Atail(aAux)[nY],"")
		nY++
		aadd(Atail(aAux)[nY],"")
		nY++
		aadd(Atail(aAux)[nY],"")
		nY++
		aadd(Atail(aAux)[nY],"")
		nY++
		aadd(Atail(aAux)[nY],"")
		nY++
		aadd(Atail(aAux)[nY],"")
		nY++
		aadd(Atail(aAux)[nY],"")
		If nY >= 14
			nY := 0
		EndIf

	Next nX

	// Popula o array de cabe็alho das colunas de produtos/servi็os.
	//Especifico Adoro
	oDanfe:Say(440,002,"DADOS DO PRODUTO / SERVIวO",oFont08N:oFont)
	oDanfe:Box(442,000,678,603)
	oDanfe:Box(442,000,678,050)
	oDanfe:Say(450,002,"COD. PROD",oFont08N:oFont)
	oDanfe:Box(442,038,678,209)
	oDanfe:Say(450,040,"DESCRIวรO DO PROD./SERV.",oFont08N:oFont)
	oDanfe:Box(442,205,678,240)
	oDanfe:Say(450,212,"NCM/SH",oFont08N:oFont)
	oDanfe:Box(442,240,678,258)
	oDanfe:Say(450,242,"CST",oFont08N:oFont)
	oDanfe:Box(442,256,678,285)
	oDanfe:Say(450,258,"CFOP",oFont08N:oFont)
	oDanfe:Box(442,275,678,300)
	oDanfe:Say(450,277,"UN",oFont08N:oFont)                         
	oDanfe:Box(442,288,678,365)
	oDanfe:Say(450,314,"QUANT.",oFont08N:oFont)
	oDanfe:Box(442,341,678,415)
	oDanfe:Say(450,350,"V.UNITARIO",oFont08N:oFont)
	oDanfe:Box(442,393,678,447)
	oDanfe:Say(450,417,"V.TOTAL",oFont08N:oFont)
	oDanfe:Box(442,447,678,447)
	oDanfe:Say(450,458,"BC.ICMS",oFont08N:oFont)
	oDanfe:Box(442,488,678,550)
	oDanfe:Say(450,495,"V.ICMS",oFont08N:oFont)
	oDanfe:Box(442,528,678,550)
	oDanfe:Say(450,535,"V.IPI",oFont08N:oFont)
	oDanfe:Box(442,550,678,578)
	oDanfe:Say(450,552,"A.ICMS",oFont08N:oFont)
	oDanfe:Box(442,578,678,603)
	oDanfe:Say(450,582,"A.IPI",oFont08N:oFont)        
	//                                                

	If MV_PAR05=1 .And. nFolhas>1
		oDanfe:Say(875,497,"CONTINUA NO VERSO")
	Endif

	// INICIANDO INFORMAวีES PARA O CABEวALHO DA PAGINA 2
	nLinha	:= 460
	nL	:= 0
	lFlag	:= .T.

	For nY := 1 To nLenItens
		nL++

		nLin:= 741
		nCont := 0

		If lflag
			If nL > nMaxItemP2
				oDanfe:EndPage()
				oDanfe:StartPage()
				If MV_PAR05 == 1
					nLinhavers := 42
				Else
					nLinhavers := 0
				EndIf
				nLinha    	:=	181 + IIF(nFolha >=3 ,0, nLinhavers)

				oDanfe:Box(000+nLinhavers,000,095+nLinhavers,250)
				oDanfe:Say(010+nLinhavers,098, "Identifica็ใo do emitente",oFont12N:oFont)

				nLinCalc	:=	023 + nLinhavers
				cStrAux		:=	AllTrim(NoChar(oEmitente:_xNome:Text,lConverte))
				nForTo		:=	Len(cStrAux)/25
				nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
				For nX := 1 To nForTo
					oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*25)+1),25), oFont12N:oFont )
					nLinCalc+=10
				Next nX

				cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_xLgr:Text,lConverte))+", "+AllTrim(oEmitente:_EnderEmit:_Nro:Text)
				nForTo		:=	Len(cStrAux)/32
				nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
				For nX := 1 To nForTo
					oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
					nLinCalc+=10
				Next nX

				If Type("oEmitente:_EnderEmit:_xCpl") <> "U"
					cStrAux		:=	"Complemento: "+AllTrim(NoChar(oEmitente:_EnderEmit:_xCpl:TEXT,lConverte))
					nForTo		:=	Len(cStrAux)/32
					nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
					For nX := 1 To nForTo
						oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
						nLinCalc+=10
					Next nX

					cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte))
					If Type("oEmitente:_EnderEmit:_Cep")<>"U"
						cStrAux		+=	" Cep:"+TransForm(oEmitente:_EnderEmit:_Cep:Text,"@r 99999-999")
					EndIf
					nForTo		:=	Len(cStrAux)/32
					nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
					For nX := 1 To nForTo
						oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
						nLinCalc+=10
					Next nX
					oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
					nLinCalc+=10
					oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
				Else
					oDanfe:Say(nLinCalc,098, NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte)+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
					nLinCalc+=10
					oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
					nLinCalc+=10
					oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
				EndIf
				oDanfe:Box(000+nLinhavers,350,095+nLinhavers,603)
				oDanfe:Box(000,248,095,351)
				oDanfe:Say(024,255, "DANFE",oFont18N:oFont)
				oDanfe:Say(032,255, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
				oDanfe:Say(042,255, "NOTA FISCAL ELETRิNICA",oFont07:oFont)
				oDanfe:Say(052,255, "0-ENTRADA",oFont08:oFont)
				oDanfe:Say(062,255, "1-SAอDA"  ,oFont08:oFont)
				oDanfe:Box(043,305,053,315)
				oDanfe:Say(052,307, oIdent:_TpNf:Text,oFont08N:oFont)
				oDanfe:Say(069,255,"N. "+StrZero(Val(oIdent:_NNf:Text),9),oFont10N:oFont)
				oDanfe:Say(077,255,"SษRIE "+oIdent:_Serie:Text,oFont10N:oFont)
				oDanfe:Say(087,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)
				oDanfe:Box(000,350,095,603)
				oDanfe:Box(000,350,040,603)
				oDanfe:Box(040,350,062,603)
				oDanfe:Box(063,350,095,603)
				oDanfe:Say(058,355,TransForm(SubStr(oNF:_InfNfe:_ID:Text,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont12N:oFont)
				
				oDanfe:Say(048,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
				nFontSize := 28
				oDanfe:Code128C(036+nLinhavers,370,SubStr(oNF:_InfNfe:_ID:Text,4), nFontSize )

				If lMv_Logod
					oDanfe:SayBitmap(000,000,cLogoD,095,096)
				Else
					oDanfe:SayBitmap(000,000,cLogo,095,096)
				EndIf

				If Empty(cChaveCont)
					oDanfe:Say(075+nLinhavers,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
					oDanfe:Say(085+nLinhavers,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
				Endif

				If  !Empty(cCodAutDPEC)
					oDanfe:Say(075+nLinhavers,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
					oDanfe:Say(085+nLinhavers,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
				Endif

				If nFolha == 1
					If !Empty(cCodAutDPEC)
						nFontSize := 28
						oDanfe:Code128C(093+nLinhavers,370,cCodAutDPEC, nFontSize )
					Endif
				Endif

				// inicio do segundo codigo de barras ref. a transmissao CONTIGENCIA OFF LINE
				If !Empty(cChaveCont) .And. Empty(cCodAutDPEC) .And. !(Val(SubStr(oNF:_INFNFE:_IDE:_SERIE:TEXT,1,3)) >= 900)
					If nFolha == 1
						If !Empty(cChaveCont)
							nFontSize := 28
							oDanfe:Code128C(093+nLinhavers,370,cChaveCont, nFontSize )
						EndIf
					Else
						If !Empty(cChaveCont)
							nFontSize := 28
							oDanfe:Code128C(093+nLinhavers,370,cChaveCont, nFontSize )
						EndIf
					EndIf
				EndIf

				oDanfe:Box(100+nLinhavers,000,123+nLinhavers,603)
				oDanfe:Box(100+nLinhavers,000,123+nLinhavers,300)
				oDanfe:Say(109+nLinhavers,002,"NATUREZA DA OPERAวรO",oFont08N:oFont)
				oDanfe:Say(119+nLinhavers,002,oIdent:_NATOP:TEXT,oFont08:oFont)
				If(!Empty(cCodAutDPEC))
					oDanfe:Say(109+nLinhavers,300,"NฺMERO DE REGISTRO DPEC",oFont08N:oFont)
				Endif
				If(((Val(SubStr(oNF:_INFNFE:_IDE:_SERIE:TEXT,1,3)) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"2") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1")
					oDanfe:Say(109+nLinhavers,302,"PROTOCOLO DE AUTORIZAวรO DE USO",oFont08N:oFont)
				Endif
				If((oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25")
					oDanfe:Say(109+nLinhavers,300,"DADOS DA NF-E",oFont08N:oFont)
				Endif
				oDanfe:Say(119+nLinhavers,302,IIF(!Empty(cCodAutDPEC),cCodAutDPEC+" "+Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DHEMI:Text)),AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text)))+" "+AllTrim(cDtHrRecCab),IIF(!Empty(cCodAutSef) .And. ((Val(SubStr(oNF:_INFNFE:_IDE:_SERIE:TEXT,1,3)) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"23") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1",cCodAutSef+" "+Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DHEMI:Text)),AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text)))+" "+AllTrim(cDtHrRecCab),TransForm(cChaveCont,"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999"))),oFont08:oFont)

				nFolha++

				oDanfe:Box(126+nLinhavers,000,153+nLinhavers,603)
				oDanfe:Box(126+nLinhavers,000,153+nLinhavers,200)
				oDanfe:Box(126+nLinhavers,200,153+nLinhavers,400)
				oDanfe:Box(126+nLinhavers,400,153+nLinhavers,603)
				oDanfe:Say(135+nLinhavers,002,"INSCRIวรO ESTADUAL",oFont08N:oFont)
				oDanfe:Say(143+nLinhavers,002,IIf(Type("oEmitente:_IE:TEXT")<>"U",oEmitente:_IE:TEXT,""),oFont08:oFont)
				oDanfe:Say(135+nLinhavers,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
				oDanfe:Say(143+nLinhavers,205,IIf(Type("oEmitente:_IEST:TEXT")<>"U",oEmitente:_IEST:TEXT,""),oFont08:oFont)
				oDanfe:Say(135+nLinhavers,405,"CNPJ",oFont08N:oFont)
				oDanfe:Say(143+nLinhavers,405,TransForm(oEmitente:_CNPJ:TEXT,IIf(Len(oEmitente:_CNPJ:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99")),oFont08:oFont)

				nLenMensagens:= Len(aMensagem)

				nColLim		:=	Iif(MV_PAR05==1,435,Iif(nMensagem <= nLenMensagens,680,865)) + nLinhavers    
				//especifico Adoro
				oDanfe:Say(161,002,"DADOS DO PRODUTO / SERVIวO",oFont08N:oFont)
				oDanfe:Box(163,000,nColLim,603)					
				oDanfe:Box(163,000,nColLim,050)
				oDanfe:Say(171,002,"COD. PROD",oFont08N:oFont)            
				oDanfe:Box(163,038,nColLim,209)
				oDanfe:Say(171,040,"DESCRIวรO DO PROD./SER.",oFont08N:oFont)		 
				oDanfe:Box(163,205,nColLim,240)
				oDanfe:Say(171,212,"NCM/SH",oFont08N:oFont)
				oDanfe:Box(163,240,nColLim,258)
				oDanfe:Say(171,242,"CST",oFont08N:oFont)
				oDanfe:Box(163,256,nColLim,285)
				oDanfe:Say(171,258,"CFOP",oFont08N:oFont)		
				oDanfe:Box(163,275,nColLim,300)
				oDanfe:Say(171,277,"UN",oFont08N:oFont)			
				oDanfe:Box(163,288,nColLim,365)
				oDanfe:Say(171,314,"QUANT.",oFont08N:oFont)			
				oDanfe:Box(163,341,nColLim,415)
				oDanfe:Say(171,350,"V.UNITARIO",oFont08N:oFont)			
				oDanfe:Box(163,393,nColLim,447)
				oDanfe:Say(171,417,"V.TOTAL",oFont08N:oFont)		
				oDanfe:Box(163,447,nColLim,447)
				oDanfe:Say(171,458,"BC.ICMS",oFont08N:oFont) 			
				oDanfe:Box(163,488,nColLim,550)
				oDanfe:Say(171,495,"V.ICMS",oFont08N:oFont)  			
				oDanfe:Box(163,528,nColLim,550)
				oDanfe:Say(171,535,"V.IPI",oFont08N:oFont)			
				oDanfe:Box(163,550,nColLim,578)
				oDanfe:Say(171,552,"A.ICMS",oFont08N:oFont)			
				oDanfe:Box(163,578,nColLim,603)
				oDanfe:Say(171,582,"A.IPI",oFont08N:oFont)
				//
				// FINALIZANDO INFORMAวีES PARA O CABEวALHO DA PAGINA 2
				nL	:= 1
				lFlag	:= .F.

				//Verifico se ainda existem Dados Adicionais a serem impressos
				IF MV_PAR05 <> 1 .And. nMensagem <= nLenMensagens
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณDados Adicionais                                                        ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					oDanfe:Say(719+nLinhavers,000,"DADOS ADICIONAIS",oFont08N:oFont)
					oDanfe:Box(721+nLinhavers,000,865+nLinhavers,351)
					oDanfe:Say(729+nLinhavers,002,"INFORMAวีES COMPLEMENTARES",oFont08N:oFont)

					nLin:= 741
					nLenMensagens:= Len(aMensagem)
					--nMensagem
					For nX := 1 To Min(nLenMensagens - nMensagem, MAXMSG)
						oDanfe:Say(nLin,002,aMensagem[nMensagem+nX],oFont08:oFont)
						nLin:= nLin+10
					Next nX
					nMensagem := nMensagem+nX

					oDanfe:Box(721+nLinhavers,350,865+nLinhavers,603)
					oDanfe:Say(729+nLinhavers,352,"RESERVADO AO FISCO",oFont08N:oFont)

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณLogotipo Rodape
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					if file(cLogoTotvs) .or. Resource2File ( cLogoTotvs, cStartPath+cLogoTotvs )
						oDanfe:SayBitmap(866,484,cLogoTotvs,120,20)
					endif

					// Seta o mแximo de itens para o MAXITEMP2
					nMaxItemP2 := MAXITEMP2
				Else
					// Seta o mแximo de itens para o MAXITEMP2F
					nMaxItemP2 := MAXITEMP2F
				EndIF
			Endif
		Endif

		// INICIANDO INFORMAวีES PARA O CABEวALHO DA PAGINA 3 E DIANTE
		If	nL > Iif( (nfolha-1)%2==0 .And. MV_PAR05==1,MAXITEMP3,nMaxItemP2)
			oDanfe:EndPage()
			oDanfe:StartPage()
			nLenMensagens:= Len(aMensagem)
			nColLim		:=	Iif(!(nfolha-1)%2==0 .And. MV_PAR05==1,435,Iif(nMensagem <= nLenMensagens,680,865))
			lFimpar		:=  ((nfolha-1)%2==0)
			nLinha    	:=	181
			If nfolha >= 3
				nLinhavers := 0
			EndIf
			oDanfe:Box(000,000,095,250)
	//		oDanfe:Say(010,098, "Identifica็ใo do emitente",oFont12N:oFont)
			oDanfe:Say(021,098, "Identifica็ใo do emitente",oFont12N:oFont)
	//		nLinCalc	:=	023
			nLinCalc	:=	034
			cStrAux		:=	AllTrim(NoChar(oEmitente:_xNome:Text,lConverte))
			nForTo		:=	Len(cStrAux)/25
			nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
			For nX := 1 To nForTo
				oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*25)+1),25), oFont12N:oFont )
				nLinCalc+=10
			Next nX

			cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_xLgr:Text,lConverte))+", "+AllTrim(oEmitente:_EnderEmit:_Nro:Text)
			nForTo		:=	Len(cStrAux)/32
			nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
			For nX := 1 To nForTo
				oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
				nLinCalc+=10
			Next nX

			If Type("oEmitente:_EnderEmit:_xCpl") <> "U"
				cStrAux		:=	"Complemento: "+AllTrim(NoChar(oEmitente:_EnderEmit:_xCpl:TEXT,lConverte))
				nForTo		:=	Len(cStrAux)/32
				nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
				For nX := 1 To nForTo
					oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
					nLinCalc+=10
				Next nX

				cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte))
				If Type("oEmitente:_EnderEmit:_Cep")<>"U"
					cStrAux		+=	" Cep:"+TransForm(oEmitente:_EnderEmit:_Cep:Text,"@r 99999-999")
				EndIf
				nForTo		:=	Len(cStrAux)/32
				nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
				For nX := 1 To nForTo
					oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
					nLinCalc+=10
				Next nX
				oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
				nLinCalc+=10
				oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
			Else
				oDanfe:Say(nLinCalc,098, NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte)+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
				nLinCalc+=10
				oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
				nLinCalc+=10
				oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
			EndIf

			oDanfe:Box(000,248,095,351)
			oDanfe:Say(024,255, "DANFE",oFont18N:oFont)
			oDanfe:Say(032,255, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
			oDanfe:Say(042,255, "NOTA FISCAL ELETRิNICA",oFont07:oFont)
			oDanfe:Say(052,255, "0-ENTRADA",oFont08:oFont)
			oDanfe:Say(062,255, "1-SAอDA"  ,oFont08:oFont)
			oDanfe:Box(043,305,053,315)
			oDanfe:Say(052,307, oIdent:_TpNf:Text,oFont08N:oFont)
			oDanfe:Say(069,255,"N. "+StrZero(Val(oIdent:_NNf:Text),9),oFont10N:oFont)
			oDanfe:Say(077,255,"SษRIE "+oIdent:_Serie:Text,oFont10N:oFont)
			oDanfe:Say(087,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)

			oDanfe:Box(000,350,095,603)
			oDanfe:Box(000,350,040,603)
			oDanfe:Box(040,350,062,603)
			oDanfe:Box(063,350,095,603)
			oDanfe:Say(058,355,TransForm(SubStr(oNF:_InfNfe:_ID:Text,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont12N:oFont)

			oDanfe:Say(048,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
			nFontSize := 28
			oDanfe:Code128C(036,370,SubStr(oNF:_InfNfe:_ID:Text,4), nFontSize )

			If lMv_Logod
				oDanfe:SayBitmap(000,000,cLogoD,095,096)
			Else
				oDanfe:SayBitmap(000,000,cLogo,095,096)
			EndIf

			If Empty(cChaveCont)
				oDanfe:Say(075,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
				oDanfe:Say(085,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
			Endif

			If  !Empty(cCodAutDPEC)
				oDanfe:Say(075,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
				oDanfe:Say(085,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
			Endif


			If nFolha == 1
				If !Empty(cCodAutDPEC)
					nFontSize := 28
					oDanfe:Code128C(093,370,cCodAutDPEC, nFontSize )
				Endif
			Endif

			// inicio do segundo codigo de barras ref. a transmissao CONTIGENCIA OFF LINE
			If !Empty(cChaveCont) .And. Empty(cCodAutDPEC) .And. !(Val(SubStr(oNF:_INFNFE:_IDE:_SERIE:TEXT,1,3)) >= 900)
				If nFolha == 1
					If !Empty(cChaveCont)
						nFontSize := 28
						oDanfe:Code128C(093,370,cChaveCont, nFontSize )
					EndIf
				Else
					If !Empty(cChaveCont)
						nFontSize := 28
						oDanfe:Code128C(093,370,cChaveCont, nFontSize )
					EndIf
				EndIf
			EndIf

			oDanfe:Box(100,000,123,603)
			oDanfe:Box(100,000,123,300)
			oDanfe:Say(109,002,"NATUREZA DA OPERAวรO",oFont08N:oFont)
			oDanfe:Say(119,002,oIdent:_NATOP:TEXT,oFont08:oFont)
			If(!Empty(cCodAutDPEC))
				oDanfe:Say(109,300,"NฺMERO DE REGISTRO DPEC",oFont08N:oFont)
			Endif
			If(((Val(SubStr(oNF:_INFNFE:_IDE:_SERIE:TEXT,1,3)) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"2") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1")
				oDanfe:Say(109,302,"PROTOCOLO DE AUTORIZAวรO DE USO",oFont08N:oFont)
			Endif
			If((oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25")
				oDanfe:Say(109,300,"DADOS DA NF-E",oFont08N:oFont)
			Endif
			oDanfe:Say(119,302,IIF(!Empty(cCodAutDPEC),cCodAutDPEC+" "+Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DHEMI:Text)),AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text)))+" "+AllTrim(cDtHrRecCab),IIF(!Empty(cCodAutSef) .And. ((Val(SubStr(oNF:_INFNFE:_IDE:_SERIE:TEXT,1,3)) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"23") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1",cCodAutSef+" "+Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DHEMI:Text)),AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text)))+" "+AllTrim(cDtHrRecCab),TransForm(cChaveCont,"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999"))),oFont08:oFont)
			nFolha++

			oDanfe:Box(126,000,153,603)
			oDanfe:Box(126,000,153,200)
			oDanfe:Box(126,200,153,400)
			oDanfe:Box(126,400,153,603)
			oDanfe:Say(135,002,"INSCRIวรO ESTADUAL",oFont08N:oFont)
			oDanfe:Say(143,002,IIf(Type("oEmitente:_IE:TEXT")<>"U",oEmitente:_IE:TEXT,""),oFont08:oFont)
			oDanfe:Say(135,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
			oDanfe:Say(143,205,IIf(Type("oEmitente:_IEST:TEXT")<>"U",oEmitente:_IEST:TEXT,""),oFont08:oFont)
			oDanfe:Say(135,405,"CNPJ",oFont08N:oFont)
			oDanfe:Say(143,405,TransForm(oEmitente:_CNPJ:TEXT,IIf(Len(oEmitente:_CNPJ:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99")),oFont08:oFont)

			oDanfe:Say(161,002,"DADOS DO PRODUTO / SERVIวO",oFont08N:oFont)
			oDanfe:Box(163,000,nColLim,603)

			nAuxH := 0                                                  
			//Especifico Adoro
			oDanfe:Say(440,002,"DADOS DO PRODUTO / SERVIวO",oFont08N:oFont)
			oDanfe:Box(442,000,678,603)
			oDanfe:Box(442,000,678,050)
			oDanfe:Say(450,002,"COD. PROD",oFont08N:oFont)
			oDanfe:Box(442,038,678,209)
			oDanfe:Say(450,040,"DESCRIวรO DO PROD./SERV.",oFont08N:oFont)
			oDanfe:Box(442,205,678,240)
			oDanfe:Say(450,212,"NCM/SH",oFont08N:oFont)
			oDanfe:Box(442,240,678,258)
			oDanfe:Say(450,242,"CST",oFont08N:oFont)
			oDanfe:Box(442,256,678,285)
			oDanfe:Say(450,258,"CFOP",oFont08N:oFont)
			oDanfe:Box(442,275,678,300)
			oDanfe:Say(450,277,"UN",oFont08N:oFont)                         
			oDanfe:Box(442,288,678,365)
			oDanfe:Say(450,314,"QUANT.",oFont08N:oFont)
			oDanfe:Box(442,341,678,415)
			oDanfe:Say(450,350,"V.UNITARIO",oFont08N:oFont)
			oDanfe:Box(442,393,678,447)
			oDanfe:Say(450,417,"V.TOTAL",oFont08N:oFont)
			oDanfe:Box(442,447,678,447)
			oDanfe:Say(450,458,"BC.ICMS",oFont08N:oFont)
			oDanfe:Box(442,488,678,550)
			oDanfe:Say(450,495,"V.ICMS",oFont08N:oFont)
			oDanfe:Box(442,528,678,550)
			oDanfe:Say(450,535,"V.IPI",oFont08N:oFont)
			oDanfe:Box(442,550,678,578)
			oDanfe:Say(450,552,"A.ICMS",oFont08N:oFont)
			oDanfe:Box(442,578,678,603)
			oDanfe:Say(450,582,"A.IPI",oFont08N:oFont)        
			//		
			//Verifico se ainda existem Dados Adicionais a serem impressos
			nLenMensagens:= Len(aMensagem)
			IF (MV_PAR05 <> 1 .Or. (MV_PAR05 == 1 .And. lFimpar )).And. nMensagem <= nLenMensagens
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณDados Adicionais                                                        ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				oDanfe:Say(719,000,"DADOS ADICIONAIS",oFont08N:oFont)
				oDanfe:Box(721,000,865,351)
				oDanfe:Say(729,002,"INFORMAวีES COMPLEMENTARES",oFont08N:oFont)

				nLin:= 741
				nLenMensagens:= Len(aMensagem)
				--nMensagem
				For nX := 1 To Min(nLenMensagens - nMensagem, MAXMSG)
					oDanfe:Say(nLin,002,aMensagem[nMensagem+nX],oFont08:oFont)
					nLin:= nLin+10
				Next nX
				nMensagem := nMensagem+nX

				oDanfe:Box(721+nLinhavers,350,865+nLinhavers,603)
				oDanfe:Say(729+nLinhavers,352,"RESERVADO AO FISCO",oFont08N:oFont)

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณLogotipo Rodape
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				if file(cLogoTotvs) .or. Resource2File ( cLogoTotvs, cStartPath+cLogoTotvs )
					oDanfe:SayBitmap(866,484,cLogoTotvs,120,20)
				endif

				// Seta o mแximo de itens para o MAXITEMP2
				nMaxItemP2 := MAXITEMP2
			Else
				// Seta o mแximo de itens para o MAXITEMP2F
				nMaxItemP2 := MAXITEMP2F
			EndIF
			If (!(nfolha-1)%2==0) .And. MV_PAR05==1
				If nY+69<nLenItens
					oDanfe:Say(875+nLinhavers,497,"CONTINUA NO VERSO")
				Endif
			End

			nL := 1
		EndIf
		oDanfe:Say(nLinha,002,aAux[1][1][nY], oFont08:oFont )
		oDanfe:Say(nLinha,040,aAux[1][2][nY],oFont07:oFont)// DESCRICAO DO PRODUTO
		oDanfe:Say(nLinha,208,aAux[1][3][nY],oFont08:oFont)//NCM
		oDanfe:Say(nLinha,242,aAux[1][4][nY],oFont08:oFont)//CST
		oDanfe:Say(nLinha,258,aAux[1][5][nY],oFont08:oFont)//CFOP
		oDanfe:Say(nLinha,277,aAux[1][6][nY],oFont08:oFont)//UN
		oDanfe:SayAlign(nLinha-5,291,aAux[1][7][nY],oFont08:oFont,45, 10, , 1,  )//QUANT
		oDanfe:SayAlign(nLinha-5,335,aAux[1][8][nY],oFont08:oFont,52, 10, , 1,  )//V UNITARIO
		oDanfe:SayAlign(nLinha-5,393,aAux[1][9][nY],oFont08:oFont,50, 10, , 1,  )//V. TOTAL
		oDanfe:SayAlign(nLinha-5,432,aAux[1][10][nY],oFont08:oFont,50, 10, , 1,  )//BC. ICMS
		oDanfe:SayAlign(nLinha-5,480,aAux[1][11][nY],oFont08:oFont,45, 10, , 1,  )//V. ICMS
		oDanfe:SayAlign(nLinha-5,504,aAux[1][12][nY],oFont08:oFont,45, 10, , 1,  )//V.IPI
		oDanfe:SayAlign(nLinha-5,546,aAux[1][13][nY],oFont08:oFont,30, 10, , 1,  )//A.ICMS
		oDanfe:SayAlign(nLinha-5,566,aAux[1][14][nY],oFont08:oFont,36, 10, , 1,  )//A.IPI
		nLinha :=nLinha + 10
	Next nY

	nLenMensagens := Len(aMensagem)
	While nMensagem <= nLenMensagens
		DanfeCpl(oDanfe,aItens,aMensagem,@nItem,@nMensagem,oNFe,oIdent,oEmitente,@nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,cLogoD,aUF)
	EndDo

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFinaliza a Impressใo                                                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lPreview
		//	oDanfe:Preview()
	EndIf

	oDanfe:EndPage()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTratamento para nao imprimir DANFEs diferentes na mesma folha, uma na FRENTE e outra no VERSO.  |
	//|   Isso quando a impressora estiver configurada para frente e verso                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If MV_PAR05==1 .And. MV_PAR01 <> MV_PAR02 .And. (--nFolha)%2<>0
		oDanfe:StartPage()
		oDanfe:EndPage()
	EndIf

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION NoChar(cString,lConverte)

	Default lConverte := .F.

	If lConverte
		cString := (StrTran(cString,"&lt;","<"))
		cString := (StrTran(cString,"&gt;",">"))
		cString := (StrTran(cString,"&amp;","&"))
		cString := (StrTran(cString,"&quot;",'"'))
		cString := (StrTran(cString,"&#39;","'"))
	EndIf

Return(cString)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ConvDate(cData)

	Local dData
	cData  := StrTran(cData,"-","")
	dData  := Stod(cData)
Return PadR(StrZero(Day(dData),2)+ "/" + StrZero(Month(dData),2)+ "/" + StrZero(Year(dData),4),15)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DanfeCpl(oDanfe,aItens,aMensagem,nItem,nMensagem,oNFe,oIdent,oEmitente,nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,cLogoD,aUF)

	Local nX            := 0
	Local nLinha        := 0
	Local nLenMensagens := Len(aMensagem)
	Local nItemOld	    := nItem
	Local nMensagemOld  := nMensagem
	Local nForMensagens := 0
	Local lMensagens    := .F.
	//Local cLogo      	:= FisxLogo("1")
	Local cLogo      	:= ""
	Local cChaveCont 	:= ""
	Local lConverte     := GetNewPar("MV_CONVERT",.F.)
	Local lMv_Logod := If(GetNewPar("MV_LOGOD", "N" ) == "S", .T., .F.   )

	Local 	cCNPJCPF :=  ""
	Local 	cUF      :=  ""
	Local 	cDataEmi :=  ""
	Local 	cTPEmis  :=  ""
	Local 	cValIcm  :=  ""
	Local 	cICMSp   :=  ""
	Local 	cICMSs   :=  ""
	local cLogoTotvs := "Powered_by_TOTVS.bmp"
	local cStartPath := GetSrvProfString("Startpath","")

	If (nLenMensagens - (nMensagemOld - 1)) > 0
		lMensagens := .T.

	EndIf

	If lMensagens
		nLenMensagens := Len(aMensagem)
		nForMensagens := Min(nLenMensagens, MAXITEMP2 + (nMensagemOld - 1) - (nItem - nItemOld))
		oDanfe:EndPage()
		oDanfe:StartPage()
		nLinha    :=180
		oDanfe:Say(160,000,"DADOS ADICIONAIS",oFont08N:oFont)
		oDanfe:Box(172,000,865,351)
		oDanfe:Say(170,002,"INFORMAวีES COMPLEMENTARES",oFont08N:oFont)
		oDanfe:Box(172,350,865,603)
		oDanfe:Say(170,352,"RESERVADO AO FISCO",oFont08N:oFont)

		if file(cLogoTotvs) .or. Resource2File ( cLogoTotvs, cStartPath+cLogoTotvs )
			oDanfe:SayBitmap(866,484,cLogoTotvs,120,20)
		endif

		oDanfe:Box(000,000,095,250)
	//	oDanfe:Say(010,098, "Identifica็ใo do emitente",oFont12N:oFont)
		oDanfe:Say(021,098, "Identifica็ใo do emitente",oFont12N:oFont)
	//	nLinCalc	:=	023
		nLinCalc	:=	034
		cStrAux		:=	AllTrim(NoChar(oEmitente:_xNome:Text,lConverte))
		nForTo		:=	Len(cStrAux)/25
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*25)+1),25), oFont12N:oFont )
			nLinCalc+=10
		Next nX

		cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_xLgr:Text,lConverte))+", "+AllTrim(oEmitente:_EnderEmit:_Nro:Text)
		nForTo		:=	Len(cStrAux)/32
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
			nLinCalc+=10
		Next nX

		If Type("oEmitente:_EnderEmit:_xCpl") <> "U"
			cStrAux		:=	"Complemento: "+AllTrim(NoChar(oEmitente:_EnderEmit:_xCpl:TEXT,lConverte))
			nForTo		:=	Len(cStrAux)/32
			nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
			For nX := 1 To nForTo
				oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
				nLinCalc+=10
			Next nX

			cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte))
			If Type("oEmitente:_EnderEmit:_Cep")<>"U"
				cStrAux		+=	" Cep:"+TransForm(oEmitente:_EnderEmit:_Cep:Text,"@r 99999-999")
			EndIf
			nForTo		:=	Len(cStrAux)/32
			nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
			For nX := 1 To nForTo
				oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
				nLinCalc+=10
			Next nX
			oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
			nLinCalc+=10
			oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
		Else
			oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xBairro:Text+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
			nLinCalc+=10
			oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
			nLinCalc+=10
			oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
		EndIf

		oDanfe:Box(000,248,095,351)
		oDanfe:Say(024,255, "DANFE",oFont18N:oFont)
		oDanfe:Say(032,255, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
		oDanfe:Say(042,255, "NOTA FISCAL ELETRิNICA",oFont07:oFont)
		oDanfe:Say(052,255, "0-ENTRADA",oFont08:oFont)
		oDanfe:Say(062,255, "1-SAอDA"  ,oFont08:oFont)
		oDanfe:Box(043,305,053,315)
		oDanfe:Say(052,307, oIdent:_TpNf:Text,oFont08N:oFont)
		oDanfe:Say(069,255,"N. "+StrZero(Val(oIdent:_NNf:Text),9),oFont10N:oFont)
		oDanfe:Say(077,255,"SษRIE "+oIdent:_Serie:Text,oFont10N:oFont)
		oDanfe:Say(087,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)

		oDanfe:Box(000,350,095,603)
		oDanfe:Box(000,350,040,603)
		oDanfe:Box(040,350,062,603)
		oDanfe:Box(063,350,095,603)
		oDanfe:Say(058,355,TransForm(SubStr(oNF:_InfNfe:_ID:Text,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont12N:oFont)

		oDanfe:Say(048,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
		nFontSize := 28
		oDanfe:Code128C(036,370,SubStr(oNF:_InfNfe:_ID:Text,4), nFontSize )

		If lMv_Logod
			oDanfe:SayBitmap(000,000,cLogoD,095,096)
		Else
			oDanfe:SayBitmap(000,000,cLogo,095,096)
		EndIf

		If Empty(cChaveCont)
			oDanfe:Say(075,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
			oDanfe:Say(085,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
		Endif

		If  !Empty(cCodAutDPEC)
			oDanfe:Say(075,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
			oDanfe:Say(085,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
		Endif

		If nFolha == 1
			If !Empty(cCodAutDPEC)
				nFontSize := 28
				oDanfe:Code128C(093,370,cCodAutDPEC, nFontSize )
			Endif
		Endif

		// inicio do segundo codigo de barras ref. a transmissao CONTIGENCIA OFF LINE
		If !Empty(cChaveCont) .And. Empty(cCodAutDPEC) .And. !(Val(SubStr(oNF:_INFNFE:_IDE:_SERIE:TEXT,1,3)) >= 900)
			If nFolha == 1
				If !Empty(cChaveCont)
					nFontSize := 28
					oDanfe:Code128C(093,370,cChaveCont, nFontSize )
				EndIf
			Else
				If !Empty(cChaveCont)
					nFontSize := 28
					oDanfe:Code128C(093,370,cChaveCont, nFontSize )
				EndIf
			EndIf
		EndIf

		oDanfe:Box(100,000,123,603)
		oDanfe:Box(100,000,123,300)
		oDanfe:Say(109,002,"NATUREZA DA OPERAวรO",oFont08N:oFont)
		oDanfe:Say(119,002,oIdent:_NATOP:TEXT,oFont08:oFont)
		If(!Empty(cCodAutDPEC))
			oDanfe:Say(109,300,"NฺMERO DE REGISTRO DPEC",oFont08N:oFont)
		Endif
		If(((Val(SubStr(oNF:_INFNFE:_IDE:_SERIE:TEXT,1,3)) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"2") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1")
			oDanfe:Say(109,302,"PROTOCOLO DE AUTORIZAวรO DE USO",oFont08N:oFont)
		Endif
		If((oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25")
			oDanfe:Say(109,300,"DADOS DA NF-E",oFont08N:oFont)
		Endif

		If !Empty(cCodAutDPEC) .And. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"4"
			cDataEmi := Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",Substr(oNFe:_NFE:_INFNFE:_IDE:_DHEMI:Text,9,2),Substr(oNFe:_NFE:_INFNFE:_IDE:_DEMI:Text,9,2))
			cTPEmis  := "4"

			If Type("oDPEC:_ENVDPEC:_INFDPEC:_RESNFE") <> "U"
				cUF      := aUF[aScan(aUF,{|x| x[1] == oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_UF:Text})][02]
				cValIcm := StrZero(Val(StrTran(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VNF:TEXT,".","")),14)
				cICMSp := iif(Val(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VICMS:TEXT)>0,"1","2")
				cICMSs := iif(Val(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VST:TEXT)>0,"1","2")
			ElseIf type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST") <> "U" //EPEC NFE
				If Type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_UF:TEXT") <> "U"
					cUF := aUF[aScan(aUF,{|x| x[1] == oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_UF:TEXT})][02]
				EndIf
				If Type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VNF:TEXT") <> "U"
					cValIcm := StrZero(Val(StrTran(oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VNF:TEXT,".","")),14)
				EndIf
				If 	Type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VICMS:TEXT") <> "U"
					cICMSp:= IIf(Val(oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VICMS:TEXT) > 0,"1","2")
				EndIf
				If 	Type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VST:TEXT") <> "U"
					cICMSs := IIf(Val(oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VST:TEXT )> 0,"1","2")
				EndIf
			EndIf

		ElseIF (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25"
			cUF      := aUF[aScan(aUF,{|x| x[1] == oNFe:_NFE:_INFNFE:_DEST:_ENDERDEST:_UF:Text})][02]
			cDataEmi := Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",Substr(oNFe:_NFE:_INFNFE:_IDE:_DHEMI:Text,9,2),Substr(oNFe:_NFE:_INFNFE:_IDE:_DEMI:Text,9,2))
			cTPEmis  := oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT
			cValIcm  := StrZero(Val(StrTran(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT,".","")),14)
			cICMSp   := iif(Val(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT)>0,"1","2")
			cICMSs   :=iif(Val(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:TEXT)>0,"1","2")
		EndIf
		If !Empty(cUF) .And. !Empty(cDataEmi) .And. !Empty(cTPEmis) .And. !Empty(cValIcm) .And. !Empty(cICMSp) .And. !Empty(cICMSs)
			If Type("oNF:_InfNfe:_DEST:_CNPJ:Text")<>"U"
				cCNPJCPF := oNF:_InfNfe:_DEST:_CNPJ:Text
				If cUf == "99"
					cCNPJCPF := STRZERO(val(cCNPJCPF),14)
				EndIf
			ElseIf Type("oNF:_INFNFE:_DEST:_CPF:Text")<>"U"
				cCNPJCPF := oNF:_INFNFE:_DEST:_CPF:Text
				cCNPJCPF := STRZERO(val(cCNPJCPF),14)
			Else
				cCNPJCPF := ""
			EndIf
			cChaveCont += cUF+cTPEmis+cCNPJCPF+cValIcm+cICMSp+cICMSs+cDataEmi
			cChaveCont := cChaveCont+Modulo11(cChaveCont)
		EndIf

		oDanfe:Say(119,302,IIF(!Empty(cCodAutDPEC),cCodAutDPEC+" "+Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DHEMI:Text)),AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text)))+" "+AllTrim(cDtHrRecCab),IIF(!Empty(cCodAutSef) .And. ((Val(SubStr(oNF:_INFNFE:_IDE:_SERIE:TEXT,1,3)) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"23") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1",cCodAutSef+" "+Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DHEMI:Text)),AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text)))+" "+AllTrim(cDtHrRecCab),TransForm(cChaveCont,"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999"))),oFont08:oFont)
		nFolha++

		oDanfe:Box(126,000,153,603)
		oDanfe:Box(126,000,153,200)
		oDanfe:Box(126,200,153,400)
		oDanfe:Box(126,400,153,603)
		oDanfe:Say(135,002,"INSCRIวรO ESTADUAL",oFont08N:oFont)
		oDanfe:Say(143,002,IIf(Type("oEmitente:_IE:TEXT")<>"U",oEmitente:_IE:TEXT,""),oFont08:oFont)
		oDanfe:Say(135,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
		oDanfe:Say(143,205,IIf(Type("oEmitente:_IEST:TEXT")<>"U",oEmitente:_IEST:TEXT,""),oFont08:oFont)
		oDanfe:Say(135,405,"CNPJ",oFont08N:oFont)
		oDanfe:Say(143,405,TransForm(oEmitente:_CNPJ:TEXT,IIf(Len(oEmitente:_CNPJ:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99")),oFont08:oFont)

		For nX := nMensagem To nForMensagens
			oDanfe:Say(nlinha,002,aMensagem[nX],oFont08:oFont)
			nMensagem++
			nLinha:= nLinha+ 10
		Next nX
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFinalizacao da pagina do objeto grafico                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oDanfe:EndPage()

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION MaxCod(cString,nTamanho)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTratamento para saber quantos caracteres irใo caber na linha ณ
//ณ visto que letras ocupam mais espa็o do que os n๚meros.      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	Local nMax	:= 0
	Local nY   	:= 0
	Default nTamanho := 45

	For nMax := 1 to Len(cString)
		If IsAlpha(SubStr(cString,nMax,1)) .And. SubStr(cString,nMax,1) $ "MOQW"  // Caracteres que ocupam mais espa็o em pixels
			nY += 7
		Else
			nY += 5
		EndIf

		If nY > nTamanho   // ้ o mแximo de espa็o para uma coluna
			nMax--
			Exit
		EndIf
	Next

Return nMax
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PosQuebrVal(cTexto)

	Local nPos := 0

	If Empty(cTexto)
		Return 0
	EndIf

	If Len(cTexto) <= MAXVALORC
		Return Len(cTexto)
	EndIf

	If SubStr(cTexto, MAXVALORC, 1) $ ",."
		nPos := MAXVALORC - 2
	Else
		nPos := MAXVALORC
	EndIf

Return nPos
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADLOG046Pบ Autor ณ Ricardo Lima - Ch:044314                             บ Data ณ  30/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Fechamento de frete                                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EspacoAt(cString, nTam)

	Local nRetorno := 0
	Local nX       := 0

	If nTam > Len(cString) .Or. nTam < 1
		nRetorno := 0
		Return nRetorno
	EndIf

	nX := nTam
	While nX > 1
		If Substr(cString, nX, 1) == " "
			nRetorno := nX
			Return nRetorno
		EndIf

		nX--
	EndDo

	nRetorno := 0

Return nRetorno
