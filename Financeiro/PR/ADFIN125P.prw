#INCLUDE 'totvs.ch'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} ADFIN125P
	ADFIN125P
	Tela para gestao dos registros da tabela SE1, com cobrancao via PIX e Super Link Cielo.
	Permite aos usuarios o reprocessamento e consulta de pagamento utilizando a integracao 
	via API com o Banco Bradesco (PIX) e Cielo (Link de pagamento).
	@type function
	@version 12.1.25
	@author Rodrigo Mello - Flek Solutions
	@since 11/01/2022
/*/

Function U_ADFIN125P()

Private oMark
Private aRotina := MenuDef()

U_ADINF009P('ADFIN125P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela gestao de PIX ')

oMark := FWMarkBrowse():New()
oMark:SetAlias('SE1')
oMark:SetSemaphore(.T.)
oMark:SetDescription('Cobran�a via PIX / Link Cielo / Boleto')
oMark:SetFieldMark( 'E1_OK' )
oMark:SetAllMark( { || oMark:AllMark() } )
// legendas
oMark:AddLegend( "E1_TIPO = 'PR' .AND. ( E1_XLOGPIX == '000' .OR. E1_XLOGLNK == '000' ) .AND. E1_STATUS == 'A'", "GREEN"	, "Nao processado" )
oMark:AddLegend( "E1_TIPO = 'PR' .AND. ( E1_XLOGPIX == 'GER' .OR. E1_XLOGLNK != 'GER' ) .AND. E1_STATUS == 'A'", "BLUE"  	, "Gerado" )
oMark:AddLegend( "E1_TIPO = 'PR' .AND. ( E1_XLOGPIX == 'EML' .OR. E1_XLOGLNK != 'EML' ) .AND. E1_STATUS == 'A'", "MAGENTA"  , "Email enviado" )
oMark:AddLegend( "E1_TIPO = 'PR' .AND. ( E1_XLOGPIX == 'ERR' .OR. E1_XLOGLNK == 'ERR' ) .AND. E1_STATUS == 'A'", "YELLOW"	, "Erro"   )
oMark:AddLegend( "E1_TIPO = 'PR' .AND. E1_STATUS  == 'B'"                         							   , "RED" 		, "Pago / Baixado" )
// filtro padrao
oMark:AddFilter( "Pix/Link Cielo", 'E1_TIPO = "PR" .AND. ( E1_XLOGPIX != "" .OR. E1_XLOGLNK != "") .AND. E1_EMISSAO = STOD("'+dtos(dDataBase)+'")',.t.,.t.)

oMark:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar'       ACTION 'VIEWDEF.COMP025_MVC' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Reprocessar'      ACTION 'U_ADRA001PROC()'     OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Verif.Recebto.'   ACTION 'U_ADRA001VERF()'     OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Invert.Marc.'  	ACTION 'U_ADRA001MARK()'     OPERATION 2 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel := Nil
	Local oStSE1 := FWFormStruct(1, "SE1")

	oModel := MPFormModel():New("ADRA001",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
	oModel:AddFields("FORMSE1",/*cOwner*/,oStSE1)
	oModel:SetPrimaryKey({'E1_FILIAL','E1_PREFIXO', 'E1_NUM', 'E1_PARCELA', 'E1_TIPO', 'E1_CLIENTE', 'E1_LOJA'})
	oModel:SetDescription("Modelo de Dados SE1 - Contas a receber")
	oModel:GetModel("FORMSE1"):SetDescription("T�tulos a receber - PIX/SuperLink")

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel("ADRA001")
	Local oStSE1 := FWFormStruct(2, "SE1")
	Local oView := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_SE1", oStSE1, "FORMSE1")
	
	oView:CreateHorizontalBox("TELA",100)
	oView:SetOwnerView("VIEW_ZZ1","TELA")
Return oView

//-------------------------------------------------------------------
Function U_ADRA001PROC()

Local aArea 	:= GetArea()
Local cMarca 	:= oMark:Mark()
Local nCt 		:= 0
local cTpEv  	:= ""

dbselectArea("SE1")
//SET FILTER TO SE1->E1_OK == cMarca
SET FILTER TO SE1->E1_TIPO = "PR" .AND. ( SE1->E1_XLOGPIX != "" .OR. SE1->E1_XLOGLNK != "") .AND. SE1->E1_EMISSAO == dDataBase

SE1->( dbGoTop() )
While !SE1->( EOF() )
    If oMark:IsMark(cMarca)
		nCt ++
		cTpEv := iif( !empty( SE1->E1_XLOGLNK )  , "LNK", "PIX" )
		recLock("SE1", .F.)
		if & ( "SE1->E1_XLOG" + cTpEv )  == "ERR"
			& ( "SE1->E1_XLOG" + cTpEv ) := ""
			& ( "SE1->E1_XMEM" + cTpEv ) := ""
		elseif & ( "SE1->E1_XLOG" + cTpEv ) == "EML"
			& ( "SE1->E1_XLOG" + cTpEv ) := "GER"
		endif
		SE1->(MsUnlock())			

		if cTpEv == "LNK"
			//FWMsgRun(, {|| startJob( "u_ADFIN129P", getEnvServer(), .T., , SE1->(Recno()) ) }, "Processando", "Processando a rotina...")			
		else
			//u_ADFIN130P(,SE1->(Recno()))
			//FWMsgRun(, {|| startJob( "u_ADFIN130P" , getEnvServer(), .T.,, SE1->(Recno()) ) }, "Processando", "Processando a rotina...")			
			FWMsgRun(, {|| u_ADFIN130P({cEmpAnt,cFilAnt,,},SE1->(Recno()), .F.) }, "Processando", "Processando a rotina...")			
		endif
    EndIf
    SE1->( dbSkip() )
End

SET FILTER TO

ApMsgInfo( 'Foram reprocessados ' + AllTrim( Str( nCt ) ) + ' registros.' )
RestArea( aArea )

Return NIL


//-------------------------------------------------------------------
Function U_ADRA001MARK()

Local aArea := GetArea()
Local cMarca := oMark:Mark()
Local lInverte := oMark:IsInvert()

Local nCt := 0

SE1->( dbGoTop() )
While !SE1->( EOF() )
    If oMark:IsMark(cMarca)
        nCt++
    EndIf
    SE1->( dbSkip() )
End

ApMsgInfo( 'Foram marcados ' + AllTrim( Str( nCt ) ) + ' registros.' )
RestArea( aArea )

Return NIL
