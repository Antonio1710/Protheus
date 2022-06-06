#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"

#DEFINE STR0001 "Preenchimento Parada"

/*/{Protheus.doc} User Function ADLFV019P()
  Cadastro de paradas
  @type tkt -  13294
  @author Rodrigo Rom�o
  @since 18/05/2021
  @history Ticket 13294 - Leonardo P. Monteiro - 13/08/2021 - Melhoria para o projeto apontamento de paradas p/ o recebimento do frango vivo.
  @history Ticket 69945 - Fernando Macieira    - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
  @history Ticket 70142 - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
User Function ADLFV019P()
	
	Local oBrowse := FwLoadBrw("ADLFV019P")
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de paradas')	
	
	oBrowse:Activate()

Return

// BROWSEDEF() SER� �TIL PARA FUTURAS HERAN�AS: FWLOADBRW()
Static Function BrowseDef()

	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias("ZEI")
	oBrowse:SetDescription(STR0001)
	oBrowse:SetMenuDef("ADLFV019P")

Return (oBrowse)

// OPERA��ES DA ROTINA
Static Function MenuDef()
	Local aRotina := FWMVCMenu("ADLFV019P")
Return (aRotina)

// REGRAS DE NEG�CIO
Static Function ModelDef()
	Local nGatilhos	:= 0
	Local oModel 	:= MPFormModel():New("ADLFV19M",, {|| fVldForm()}, {|oMld| fAfterTTS(oMld)})
	Local oStruZEI 	:= FwFormStruct(1, "ZEI")
	
	// nOpc := oModel:GetOperation()
	// if nOpc <> MODEL_OPERATION_INSERT
	//oStruZEI:SetProperty( 'ZEI_NUMOC'   , MODEL_FIELD_VALID,FwBuildFeature( STRUCT_FEATURE_VALID,"Static Call(ADLFV019P, validaOdCarregamento)" ))
	//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	oStruZEI:SetProperty( 'ZEI_NUMOC'   , MODEL_FIELD_VALID,FwBuildFeature( STRUCT_FEATURE_VALID,"u_LFV019A0()" ))

	oStruZEI:SetProperty( 'ZEI_DESCRI'  , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_fillCampo('ZEE','ZEE_DESCRI')" ))
	//oStruZEI:SetProperty( 'ZEI_DEPTO'   , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_fillCampo('ZEE','ZEE_DEPTO')"  ))
	oStruZEI:SetProperty( 'ZEI_DEPDES'  , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_fillCampo('ZGC','ZGC_NOME')" ))

	oStruZEI:SetProperty( 'ZEI_GRANJA'  , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_fillCampo('ZV1','ZV1_PGRANJ')" ))
	oStruZEI:SetProperty( 'ZEI_DTABAT'  , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_fillCampo('ZV1','ZV1_DTABAT')" ))
	oStruZEI:SetProperty( 'ZEI_PLACA'   , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_fillCampo('ZV1','ZV1_RPLACA')" ))
	
	// endif
	oStruZEI:SetProperty( "ZEI_ITEM"    , MODEL_FIELD_WHEN, {|| .F. } )


	oModel:AddFields("ZEIMASTER", NIL, oStruZEI)
	oModel:SetDescription(STR0001)
	oModel:GetModel( 'ZEIMASTER' ):SetPrimaryKey( { "ZEI_ITEM","ZEI_NUMOC" } )

Return (oModel)

// INTERFACE GR�FICA
Static Function ViewDef()
	Local oView := FwFormView():New()
	Local oStruZEI := FwFormStruct(2, "ZEI")
	Local oModel := FwLoadModel("ADLFV019P")

	oView:SetModel(oModel)

	oView:AddField("VIEW_ZEI",oStruZEI ,"ZEIMASTER")

	oStruZEI:RemoveField('ZEI_FILIAL')
	oStruZEI:RemoveField('ZEI_ITEM')

	oView:CreateHorizontalBox("TELA"	,100)

	oView:SetOwnerView("VIEW_ZEI", "TELA")

	// DEFINE OS T�TULOS DAS SUBVIEWS
	// oView:EnableTitleView("VIEW_ZEI")
Return (oView)

User Function fillCampo(cTabela,cNomeCampo)
	local cRet := ""
	local xArea := getArea()
	local oModel 	:= FwModelActive()

	nOpc := oModel:GetOperation()

	if nOpc <> 3
		if Alltrim(cTabela) == "ZEE"
			cRet := POSICIONE(cTabela,1,xFilial("ZEE")+ZEI->ZEI_DEPTO+ZEI->ZEI_NUMMP,cNomeCampo)
		Elseif Alltrim(cTabela) == "ZGC"
			cRet := POSICIONE(cTabela,1,xFilial("ZGC")+ZEI->ZEI_DEPTO,cNomeCampo)
		Elseif Alltrim(cTabela) == "ZV1"
			cRet := POSICIONE(cTabela,3,xFilial(cTabela)+ZEI->ZEI_NUMOC,cNomeCampo)
		endif
	endif

	restArea(xArea)

Return cRet

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 21/03/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function fillItem()

	local cRet    := "0001"
	local cQuery  := ""
	local cAlias 	:= getNextAlias()
	local oModel 	:= FwModelActive()
	local oView		:= FwViewActive()
	local cNumOc	:= FwFldGet("ZEI_NUMOC")

	cQuery := "SELECT " + CRLF
	cQuery += "	 MAX(ZEI.ZEI_ITEM) AS ZEI_ITEM " + CRLF
	cQuery += "FROM " + RetSqlTab("ZEI") + " " + CRLF
	cQuery += "WHERE ZEI.D_E_L_E_T_ <> '*'" + CRLF
	cQuery += " AND ZEI.ZEI_NUMOC = '" + cNumOc + "'" + CRLF

	TCQUERY cQuery NEW ALIAS (cAlias)
	DbSelectArea(cAlias)

	if (cAlias)->(!Eof())
		nItem := Val((cAlias)->ZEI_ITEM)+1
		cRet := StrZero(nItem,4)
	endif

	(cAlias)->(DbCloseArea())

Return(cRet)

Static Function validaOdCarregamento()
	local lRet    := .T.
	local cQuery  := ""
	local cAlias 	:= getNextAlias()
	local oModel 	:= FwModelActive()
	local oView		:= FwViewActive()
	local cNumOc	:= FwFldGet("ZEI_NUMOC")

	cQuery := " SELECT " + CRLF
	cQuery += "	COUNT(*) REGISTRO " + CRLF
	cQuery += " FROM " + RetSqlTab("ZV1") + " (NOLOCK) " + CRLF
	cQuery += " WHERE ZV1_FILIAL='"+FWxFilial("ZV1")+"' " + CRLF // @history Ticket 69945 - Fernando Macieira    - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
	cQuery += " AND ZV1.ZV1_NUMOC = '" + cNumOc + "'" + CRLF
	cQuery += " AND ZV1.D_E_L_E_T_ <> '*'" + CRLF

	TCQUERY cQuery NEW ALIAS (cAlias)
	DbSelectArea(cAlias)

	if (cAlias)->REGISTRO == 0
		lRet := .F.
	endif

	(cAlias)->(DbCloseArea())

Return(lRet)


/*###############################################################################################*/
/* -------------------------------- Chamada do ponto de entrada -------------------------------- */
/*###############################################################################################*/
User Function ADLFV19M()

	Local aParam     := PARAMIXB
	Local lRet       := .T.
	Local oObj       := ''
	Local cIdPonto   := ''
	Local cIdModel   := ''
	Local lIsGrid    := .F.
	local nOpc       := 0

	If aParam <> NIL
		oObj       := aParam[1]
		cIdPonto   := aParam[2]
		cIdModel   := aParam[3]
		lIsGrid    := ( Len( aParam ) > 3 )
		nOpc       := oObj:GetOperation()

		If cIdPonto == 'FORMPOS' .AND. (nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE)

			nMinuto	:= FwFldGet("ZEI_MINUTO")

			if nMinuto == 0
				cMsgError := "Aten��o, o campo de minutos � obrigat�rio."
				Help( ,, 'Help',, cMsgError, 1, 0 )
				lRet := .F.
			endif
		endif

	endif

Return (lRet)


static function fVldForm()
	Local lRet 		:= .T.

	Local oView     := FWViewActive()
	Local oModel	:= FWModelActive()

	If oView:GetOperation() ==  1 
		lRet	:= .T.
	// Insert
	ElseIf oView:GetOperation() == 3
		lRet	:= .T.
	//Update or Only Update.
	ElseIf oView:GetOperation() == 4 .OR. oView:GetOperation() == 6
		lRet := .T.
		
	// Delete
	ElseIf oView:GetOperation() == 5
		lRet := .T.
	EndIf

return lRet

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 21/03/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function fAfterTTS(oModel)

	Local lRet 		:= .T.
	Local cQuery	:= ""
	
	lRet := fwformcommit(oModel)
	
	cQuery := " SELECT ISNULL(MAX(ZEI_ITEM),'0000') ITEM_MAX "
	cQuery += " FROM "+ RetSqlName("ZEI") +" (NOLOCK) "
	cQuery += " WHERE D_E_L_E_T_='' AND ZEI_FILIAL='"+ xFilial("ZEI") +"' AND ZEI_NUMOC='"+ FwFldGet("ZEI_NUMOC") +"'; "

	Tcquery cQuery ALIAS "QZEI" NEW

	if QZEI->(!EOF())
		Reclock("ZEI",.F.)
			ZEI->ZEI_ITEM	:= Soma1(QZEI->ITEM_MAX)
		ZEI->(MsUnlock())
	endif

	QZEI->(DbCloseArea())

return lRet


/*/{Protheus.doc} u_LOG057A0
Ticket 70142 - Substituicao de funcao Static Call por User Function MP 12.1.33
@type function
@version 1.0
@author Edvar   / Flek Solution
@since 16/03/2022
@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
Function u_LFV019A0()
Return( validaOdCarregamento())
