#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"

#DEFINE STR0001 "Preenchimento Parada"


/*/{Protheus.doc} User Function ADLFV019P()
  Cadastro de paradas
  @type tkt -  13294
  @author Rodrigo Romão
  @since 18/05/2021
/*/

User Function ADLFV019P()
	
	Local oBrowse := FwLoadBrw("ADLFV019P")
	oBrowse:Activate()

Return

// BROWSEDEF() SERÝ ÚTIL PARA FUTURAS HERANÇAS: FWLOADBRW()
Static Function BrowseDef()
	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias("ZEI")
	oBrowse:SetDescription(STR0001)
	oBrowse:SetMenuDef("ADLFV019P")

Return (oBrowse)

// OPERAÇÕES DA ROTINA
Static Function MenuDef()
	Local aRotina := FWMVCMenu("ADLFV019P")
Return (aRotina)

// REGRAS DE NEGÓCIO
Static Function ModelDef()
	Local oModel := MPFormModel():New("ADLFV19M")
	Local oStruZEI := FwFormStruct(1, "ZEI")

	// nOpc := oModel:GetOperation()
	// if nOpc <> MODEL_OPERATION_INSERT
	oStruZEI:SetProperty( 'ZEI_NUMOC'   , MODEL_FIELD_VALID,FwBuildFeature( STRUCT_FEATURE_VALID,"StaticCall(ADLFV019P, validaOdCarregamento)" ))

	oStruZEI:SetProperty( 'ZEI_DESCRI'  , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_fillCampo('ZEE','ZEE_DESCRI')" ))
	oStruZEI:SetProperty( 'ZEI_DEPTO'   , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_fillCampo('ZEE','ZEE_DEPTO')"  ))
	oStruZEI:SetProperty( 'ZEI_DEPDES'  , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_fillCampo('ZEE','ZEE_DESDEP')" ))

	oStruZEI:SetProperty( 'ZEI_GRANJA'  , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_fillCampo('ZV1','ZV1_PGRANJ')" ))
	oStruZEI:SetProperty( 'ZEI_DTABAT'  , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_fillCampo('ZV1','ZV1_DTABAT')" ))
	oStruZEI:SetProperty( 'ZEI_PLACA'   , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_fillCampo('ZV1','ZV1_RPLACA')" ))
	// endif

	aGatilhos := getGatilhos()

	//Percorrendo os gatilhos e adicionando na Struct
	For nAtual := 1 To Len(aGatilhos)
		oStruZEI:AddTrigger(  aGatilhos[nAtual][01],; //Campo Origem
		aGatilhos[nAtual][02],; //Campo Destino
		aGatilhos[nAtual][03],; //Bloco de cï¿½digo na validaï¿½ï¿½o da execuï¿½ï¿½o do gatilho
		aGatilhos[nAtual][04])  //Bloco de cï¿½digo de execuï¿½ï¿½o do gatilho
	Next

	oModel:AddFields("ZEIMASTER", NIL, oStruZEI)
	oModel:SetDescription(STR0001)
	oModel:GetModel( 'ZEIMASTER' ):SetPrimaryKey( { "ZEI_ITEM","ZEI_NUMOC" } )

Return (oModel)

// INTERFACE GRÝFICA
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

	// DEFINE OS TíTULOS DAS SUBVIEWS
	// oView:EnableTitleView("VIEW_ZEI")
Return (oView)

User Function fillCampo(cTabela,cNomeCampo)
	local cRet := ""
	local xArea := getArea()
	local oModel 	:= FwModelActive()

	nOpc := oModel:GetOperation()

	if nOpc <> 3
		if Alltrim(cTabela) == "ZEE"
			cRet := POSICIONE(cTabela,1,xFilial(cTabela)+ZEI->ZEI_NUMMP,cNomeCampo)
		Elseif Alltrim(cTabela) == "ZEG"
			cRet := POSICIONE(cTabela,1,xFilial(cTabela)+ZEH->ZEH_NUMMM,cNomeCampo)
		Elseif Alltrim(cTabela) == "ZV1"
			cRet := POSICIONE(cTabela,3,xFilial(cTabela)+ZEI->ZEI_NUMOC,cNomeCampo)
		endif
	endif

	restArea(xArea)
Return cRet

/*/{Protheus.doc} getGatilhos
	(long_description)
	@type  Static Function
	@author user
	@since 13/05/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
    /*/
Static Function getGatilhos()
	local aRet    := {}

	//GATILHOS
	//Adicionando um gatilho, do ZZ1_CODIGO para o ZZ1_DESCR
	aAdd(aRet, FWStruTriggger("ZEI_NUMOC",;   //Campo Origem
	"ZEI_ITEM",;                      			  //Campo Destino
	"StaticCall(ADLFV019P, fillitem)",;	      //Regra de Preenchimento
	.F.,;                              			  //Irï¿½ Posicionar?
	"",;                               			  //Alias de Posicionamento
	0,;                                			  //indice de Posicionamento
	'',;                               			  //Chave de Posicionamento
	NIL,;                              			  //Condicao para execucao do gatilho
	"01");                             			  //Sequencia do gatilho
	)

Return aRet



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

	cQuery := "SELECT " + CRLF
	cQuery += "	 COUNT(*) REGISTRO " + CRLF
	cQuery += "FROM " + RetSqlTab("ZV1") + " " + CRLF
	cQuery += "WHERE ZV1.D_E_L_E_T_ <> '*'" + CRLF
	cQuery += " AND ZV1.ZV1_NUMOC = '" + cNumOc + "'" + CRLF

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
				cMsgError := "Atenção, o campo de minutos é obrigatório."
				Help( ,, 'Help',, cMsgError, 1, 0 )
				lRet := .F.
			endif
		endif

	endif

Return (lRet)
