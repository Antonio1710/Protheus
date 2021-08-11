#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"

#DEFINE STR0001 "Manutenção Frango Vivo"
#DEFINE STR0002 "Manutenção Frango Vivo"
#DEFINE STR0003 "Manutenção Frango Vivo" 

/*/{Protheus.doc} User Function U_ADLFV017P()
  Tela de gestão de ordens de carregamento  - PCP 
  @type tkt -  13294
  @author Rodrigo Romão
  @since 18/05/2021
  @history Chamado T.I - Leonardo P. Monteiro    - 16/07/2021 - Correção na função de upload dos registros no grid ZEH.
/*/

User Function ADLFV017P()
	local cPerg   := PadR("ADLFV017P",10)
	Local oBrowse := nil
	local cFiltro := ""

	lPer := montaPer(cPerg)
	if lPer

		cDataDe     := MV_PAR01
		cDataAte    := MV_PAR02
		cPlacaDe    := MV_PAR03
		cPlacaAte   := MV_PAR04
		cOrdCarDe   := MV_PAR05
		cOrdCarAte  := MV_PAR06

		cFiltro += " ZV1->ZV1_NUMOC  >= '" + cOrdCarDe     + "' .AND. ZV1->ZV1_NUMOC  <= '" + cOrdCarAte     + "' .and."
		cFiltro += " ZV1->ZV1_DTABAT >= '" + DTOS(cDataDe) + "' .AND. ZV1->ZV1_DTABAT <= '" + DTOS(cDataAte) + "' .and."
		cFiltro += " ZV1->ZV1_RPLACA >= '" + cPlacaDe      + "' .AND. ZV1->ZV1_RPLACA <= '" + cPlacaAte      + "' "

		oBrowse := FwLoadBrw("ADLFV017P")
		oBrowse:SetFilterDefault(cFiltro)
		oBrowse:Activate()
	endif

Return

Static Function BrowseDef()
	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias("ZV1")
	oBrowse:SetDescription(STR0001)

	oBrowse:AddLegend("ZV1_STATUS='I'"					, "BR_AZUL"			, "PRIMEIRA PESAGEM")
	oBrowse:AddLegend("ZV1_STATUS='R'"					, "BR_LARANJA" 	, "SEGUNDA PESAGEM")
	oBrowse:AddLegend("ZV1_STATUS='M'"					, "BR_MARRON" 	, "PESAGEM MANUAL")
	oBrowse:AddLegend("ZV1_STATUS='G'"					, "BR_VERDE" 		, "GERADO FRETE")
	oBrowse:AddLegend("ALLTRIM(ZV1_STATUS)=''"	, "BR_PRETO" 		, "ORDEM NAO UTILIZADA")

	// DEFINE DE ONDE SERÁ RETIRADO O MENUDEF
	oBrowse:SetMenuDef("ADLFV017P")

Return (oBrowse)

// OPERAÇÕES DA ROTINA
Static Function MenuDef()
	local aRotina := {}

	//Local aRotina := FWMVCMenu("ADLFV017P")
	ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.ADLFV017P'  OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Editar'     Action 'VIEWDEF.ADLFV017P'	OPERATION 4 ACCESS 0

Return (aRotina)

// REGRAS DE NEGÓCIO
Static Function ModelDef()
	local nAtual := 0
	local oModel 		:= MPFormModel():New("ADLFV17M")
	// local oModel 		:= MPFormModel():New("ADLFV17M",,,{|oModel| commitRot(oModel)},)
	local aGatilhos := {}

	// INSTANCIA O SUBMODELO
	Local oStruZV1 := FwFormStruct(1, "ZV1")
	//Local oStruZEI := FwFormStruct(1, "ZEI")
	Local oStruZEH := FwFormStruct(1, "ZEH")

	//oStruZEI:SetProperty( 'ZEI_DESCRI'  , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_preencheCampo('ZEE','ZEE_DESCRI')" ))
	//oStruZEI:SetProperty( 'ZEI_DEPTO'   , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_preencheCampo('ZEE','ZEE_DEPTO')"  ))
	//oStruZEI:SetProperty( 'ZEI_DEPDES'  , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_preencheCampo('ZEE','ZEE_DESDEP')" ))

	oStruZEH:SetProperty( 'ZEH_DESCRI'  , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_preencheCampo('ZEG','ZEG_DESCRI')" ))
	oStruZEH:SetProperty( 'ZEH_DEPTO'   , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_preencheCampo('ZEG','ZEG_DEPTO')"  ))
	oStruZEH:SetProperty( 'ZEH_DESDEP'  , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_preencheCampo('ZEG','ZEG_DESDEP')" ))

	bLoad := {|oModel, oGridModel, lCopy| loadGrid(oModel, oGridModel, lCopy)}

	// DEFINE O SUBMODELO COMO FIELD
	oModel:AddFields("ZV1MASTER", NIL, oStruZV1)
	//oModel:AddGrid("ZEIDETAIL", "ZV1MASTER", oStruZEI)
	//oModel:AddGrid("ZEHDETAIL", "ZV1MASTER", oStruZEH)
	oModel:AddGrid("ZEHDETAIL", "ZV1MASTER", oStruZEH, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, bLoad)

	//oModel:GetModel("ZEHDETAIL"):SetUseOldGrid(.t.)
	//oModel:GetModel( 'ZEHDETAIL' ):SetNoInsertLine(.F.)

	//oModel:SetRelation("ZEIDETAIL", {{"ZEI_FILIAL", "xFilial('ZEI')"},{"ZEI_NUMOC","ZV1_NUMOC"}}, ZEI->(IndexKey(1)))
	oModel:SetRelation("ZEHDETAIL", {{"ZEH_FILIAL", "xFilial('ZEH')"},{"ZEH_NUMOC","ZV1_NUMOC"}}, ZEH->(IndexKey(1)))

	//oModel:GetModel('ZEIDETAIL'):SetOptional(.T.)
	oModel:GetModel('ZEHDETAIL'):SetOptional(.T.)

	oModel:GetModel( 'ZEHDETAIL' ):SetNoInsertLine( .F. )
	oModel:GetModel( 'ZEHDETAIL' ):SetNoDeleteLine( .F. )

	// DESCRICAO DO MODELO
	oModel:SetDescription(STR0001)

	// DESCRICAO DO SUBMODELO
	oModel:GetModel("ZV1MASTER"):SetDescription("Dados de " + STR0001)

	oModel:GetModel( 'ZV1MASTER' ):SetPrimaryKey( { "ZV1_NUMOC" } )

	oModel:setActivate({ |oModel| onActivate(oModel)})

Return (oModel)

/* ----------------------------- */
static function onActivate(oModel)

	//Só efetua a alteração do campo para inserção
	if oModel:GetOperation() == MODEL_OPERATION_UPDATE
		FwFldPut("ZV1_OBS", "" , /*nLinha*/, oModel)
	endif

return

// INTERFACE GRAFICA
Static Function ViewDef()
	// INSTANCIA A VIEW
	Local oView := FwFormView():New()

	// INSTANCIA AS SUBVIEWS
	Local oStruZV1 := FwFormStruct(2, "ZV1")
	//Local oStruZEI := FwFormStruct(2, "ZEI")
	Local oStruZEH := FwFormStruct(2, "ZEH")

	// RECEBE O MODELO DE DADOS
	Local oModel := FwLoadModel("ADLFV017P")

	// INDICA O MODELO DA VIEW
	oView:SetModel(oModel)
	//oView:SetContinuousForm(.T.)

	// CRIA ESTRUTURA VISUAL DE CAMPOS
	oView:AddField("VIEW_ZV1",oStruZV1 ,"ZV1MASTER")
	//oView:AddGrid("VIEW_ZEI" ,oStruZEI ,"ZEIDETAIL")
	oView:AddGrid("VIEW_ZEH" ,oStruZEH ,"ZEHDETAIL")

	oStruZV1:RemoveField('ZV1_MORTAL')

	//oStruZEI:RemoveField('ZEI_FILIAL')
	//oStruZEI:RemoveField('ZEI_NUMOC')

	oStruZEH:RemoveField('ZEH_FILIAL')
	oStruZEH:RemoveField('ZEH_NUMOC')

	//oView:AddIncrementField( "VIEW_ZEI", "ZEI_ITEM" )
	oView:AddIncrementField( "VIEW_ZEH", "ZEH_ITEM" )

	oView:CreateHorizontalBox("TELA_SUPERIOR",60)
	oView:CreateHorizontalBox("GRID_MOTIVO_MORTALIDADE",35, nil, .F.)
	//oView:CreateHorizontalBox("GRID_MOTIVO_PARADA",25)

	oView:SetOwnerView("VIEW_ZV1", "TELA_SUPERIOR")
	oView:SetOwnerView("VIEW_ZEH", "GRID_MOTIVO_MORTALIDADE")
	//oView:SetOwnerView("VIEW_ZEI", "GRID_MOTIVO_PARADA")

	//oView:EnableTitleView("VIEW_ZEI", STR0002, RGB(224, 30, 43))
	oView:EnableTitleView("VIEW_ZEH", STR0003, RGB(224, 30, 43))

	// DEFINE OS TITULOS DAS SUBVIEWS
	oView:EnableTitleView("VIEW_ZV1")
	//oView:EnableTitleView("VIEW_ZEI")
	oView:EnableTitleView("VIEW_ZEH")

Return (oView)

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
	aAdd(aRet, FWStruTriggger("ZEH_NUMMM",;  //Campo Origem
	"ZEH_DESCRI",;                      			  //Campo Destino
	"StaticCall(ADLFV017P, fillDescricao)",;	  //Regra de Preenchimento
	.F.,;                              			  //Irï¿½ Posicionar?
	"",;                               			  //Alias de Posicionamento
	0,;                                			  //indice de Posicionamento
	'',;                               			  //Chave de Posicionamento
	NIL,;                              			  //Condicao para execucao do gatilho
	"01");                             			  //Sequencia do gatilho
	)

Return aRet 

/*/{Protheus.doc} fillDescricao
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
Static Function fillDescricao()
	local cAlias 	:= getNextAlias()
	local aArea 	:= getArea()
	local cRet		:= ""
	local oModel 	:= FwModelActive()
	local oView		:= FwViewActive()
	local cCodMM	:= FwFldGet("ZEH_NUMMM")


	cQuery := "SELECT " + CRLF
	cQuery += "	 ZEG.ZEG_DESCRI " + CRLF
	cQuery += "FROM " + RetSqlTab("ZEG") + " " + CRLF
	cQuery += "WHERE ZEG.D_E_L_E_T_ <> '*'" + CRLF
	cQuery += " AND ZEG.ZEG_CODIGO = '" + cCodMM + "'" + CRLF

	TCQUERY cQuery NEW ALIAS (cAlias)
	DbSelectArea(cAlias)

	if (cAlias)->(!Eof())
		cRet := (cAlias)->ZEG_DESCRI
	endif

	(cAlias)->(DbCloseArea())

	restArea(aArea)
Return cRet

/*/{Protheus.doc} User Function preencheCampo
  (long_description)
  @type  Function
  @author user
  @since 13/05/2021
  @version version
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
User Function preencheCampo(cTabela,cNomeCampo)
	local cRet := ""
	local xArea := getArea()

	if Alltrim(cTabela) == "ZEE"
		cRet := POSICIONE(cTabela,1,xFilial(cTabela)+ZEI->ZEI_NUMMP,cNomeCampo)
	Elseif Alltrim(cTabela) == "ZEG"
		cRet := POSICIONE(cTabela,1,xFilial(cTabela)+ZEH->ZEH_NUMMM,cNomeCampo)
	endif

	restArea(xArea)
Return cRet

Static Function commitRot(oModel)

	lResult := oModel:VldData()

	IF lResult

		lRet := fwformcommit(oModel)
		if !lRet
			aErro := oModel:GetErrorMessage()//Obtem a mensagem de erro
		endif

	else
		aErro := oModel:GetErrorMessage()//Obtem a mensagem de erro
	endif

Return lRet

/*/{Protheus.doc} User Function fillOrdMort
	(long_description)
	@type  Function
	@author user
	@since 03/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
/*
User Function fillOrdMort()
	local oModel 	:= FwModelActive()
	local oView		:= FwViewActive()
	local cQuery	:= ""
	local cAlias	:= ""
	Local oGrid   := oModel:GetModel('ZEHDETAIL')
	local aData		:= oGrid:getOldData()
	local aHeader	:= aData[1]
	local aCols		:= aData[2]

	// ZEE => CADASTRO DE MOTIVOS DE PARADA
	// ZEI => ORDERM DE CARREGAMENTO X MOTIVO DE PARADA
	// ZEG => CADASTO DE MOTIVOS DE MORTALIDADE
	// ZEH => ORDERM DE CARREGAMENTO X MOTIVO DE MORTALIDADE


	cNumOc	:= FwFldGet("ZV1_NUMOC")
	nMortal	:= FwFldGet("ZV1_MORTAL")

	if nMortal > 0
		nPosNumMM := AsCan(aHeader,{|x|x[2] == "ZEH_NUMMM"})
		cAlias := getNextAlias()

		cQuery := "SELECT ZEG.ZEG_CODIGO,ZEG.ZEG_DESCRI,ZEG.ZEG_DEPTO, ZEG.ZEG_DESDEP "
		cQuery += " FROM " + RetSqlTab("ZEG") + " "
		cQuery += " WHERE ZEG.D_E_L_E_T_ = ''"
		cQuery += " AND ZEG.ZEG_FILIAL = '" + xFilial("ZEG") + "'"
		cQuery += " AND ZEG.ZEG_AUTO = 'S'"
		cQuery += " AND ZEG.ZEG_STATUS = '1'"

		TCQUERY cQuery NEW ALIAS (cAlias)
		(cAlias)->(dbgotop())

		DbSelectArea(cAlias)
		While (cAlias)->(!Eof())

			cCodigo := (cAlias)->ZEG_CODIGO

			nPos := AsCan(aCols,{|x| alltrim(x[nPosNumMM]) == Alltrim(cCodigo)})

			if nPos == 0
				oGrid:AddLine()
				oGrid:SetValue("ZEH_NUMOC"	, cNumOc)
				oGrid:SetValue("ZEH_NUMMM"	, (cAlias)->ZEG_CODIGO)
				oGrid:SetValue("ZEH_DESCRI"	, (cAlias)->ZEG_DESCRI)
				oGrid:SetValue("ZEH_DEPTO"	, (cAlias)->ZEG_DEPTO)
				oGrid:SetValue("ZEH_DESDEP"	, (cAlias)->ZEG_DESDEP)
				oGrid:SetValue("ZEH_QUANT"	, 0)
			endif

			(cAlias)->(DbSkip())
		endDo

		(cAlias)->(DbCloseArea())

	endif

	oView:Refresh('ZEHDETAIL')
Return .t.
*/

/*/{Protheus.doc} loadGrid
  (long_description)
  @type  Static Function
  @author user
  @since 14/05/2021
  @version version
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
Static Function loadGrid(oModel, oGridModel, lCopy)
	local oModelA 	:= FwModelActive()
	local oViewA	:= FwViewActive()
	local cQuery	:= ""
	local cAlias	:= ""
	local aData 	:= {}
	Local nLin		:= 0
	Local oGrid     := oModelA:GetModel('ZEHDETAIL')
	//local aData		:= oGrid:getOldData()
	//local cQuery	:= ""
	//local cAlias 	:= ""
	//local aTemp		:= {}
	local nItem		:= 0

	cNumOc	:= ZV1->ZV1_NUMOC
	nMortal	:= ZV1->ZV1_MORTAL

	//aData := verificaInfo(cNumOc)

	//if Len(aData) == 0
	cAlias := getNextAlias()

	cQuery := "SELECT ZEG.ZEG_CODIGO,ZEG.ZEG_DESCRI,ZEG.ZEG_DEPTO, ZEG.ZEG_DESDEP, ZEG_DESCRI  "
	cQuery += " FROM " + RetSqlTab("ZEG") + " LEFT JOIN "
	cQuery += "  	(SELECT DISTINCT ZEH_FILIAL, ZEH_NUMMM "
	cQuery += "		 FROM " + RetSqlTab("ZEH") + "	"
	cQuery += "		 WHERE D_E_L_E_T_='' AND ZEH_FILIAL = '" + xFilial("ZEH") + "' AND ZEH_NUMOC = '" + cNumOc + "') ZEH "
	cQuery += "  ON  ZEG.ZEG_CODIGO = ZEH.ZEH_NUMMM "
	cQuery += "  AND ZEG.D_E_L_E_T_ = ''"
	cQuery += "  AND ZEG.ZEG_FILIAL = '" + xFilial("ZEG") + "'"
	cQuery += "  AND ZEH.ZEH_FILIAL = '" + xFilial("ZEH") + "'"
	cQuery += " WHERE ZEG.D_E_L_E_T_ = ''"
	cQuery += " AND ZEG.ZEG_FILIAL = '" + xFilial("ZEG") + "'"
	cQuery += " AND ZEG.ZEG_AUTO = 'S'"
	cQuery += " AND ISNULL(ZEH.ZEH_NUMMM,'') = '' "
	cQuery += " AND ZEG.ZEG_STATUS = '1'"

	TCQUERY cQuery NEW ALIAS (cAlias)
	DbSelectArea(cAlias)
	
	oGrid:setNoInsertLine(.F.)

	While (cAlias)->(!Eof())
		nItem++
		nQuantidade := 0

		IF Alltrim((cAlias)->ZEG_DESCRI) == "MORTALIDADE"
			nQuantidade := nMortal
		endif
		
		//if !Empty(oGrid:GetValue("ZEH_NUMMM"))
		if oGrid:Length() == 0
			oGrid:AddLine()
		else
			oGrid:GoLine(oGrid:Length())
			
			if !Empty(oGrid:GetValue("ZEH_NUMMM"))
				oGrid:AddLine()
			endif
			
		endif

		oGrid:GoLine(oGrid:Length())
		
		//oGrid:loadValue("ZEH_FILIAL"	,xFilial("ZEH"))
		oGrid:loadValue("ZEH_ITEM"		,StrZero(nItem,4))
		oGrid:loadValue("ZEH_NUMOC"		,cNumOc)
		oGrid:loadValue("ZEH_NUMMM"		,(cAlias)->ZEG_CODIGO)
		oGrid:loadValue("ZEH_DESCRI"	,(cAlias)->ZEG_DESCRI)
		oGrid:loadValue("ZEH_DEPTO"		,(cAlias)->ZEG_DEPTO)
		oGrid:loadValue("ZEH_DESDEP"	,(cAlias)->ZEG_DESDEP)
		oGrid:loadValue("ZEH_QUANT"		,nQuantidade)
		oGrid:loadValue("ZEH_OBS"		,SPACE(250))

		/*
		RecLock("ZEH",.T.)
		ZEH->ZEH_FILIAL	:= xFilial("ZEH")
		ZEH->ZEH_ITEM  	:= StrZero(nItem,4)
		ZEH->ZEH_NUMOC 	:= cNumOc
		ZEH->ZEH_NUMMM 	:= (cAlias)->ZEG_CODIGO
		ZEH->ZEH_QUANT 	:= nQuantidade
		ZEH->ZEH_OBS 		:= SPACE(250)
		ZEH->(MsUnLock())
		*/

		(cAlias)->(DbSkip())
	endDo

	oGrid:setNoInsertLine(.T.)

	(cAlias)->(DbCloseArea())
	//endif

	//aData := verificaInfo(cNumOc)

Return aData

/*/{Protheus.doc} verificaInfo(cNumOc)
	(long_description)
	@type  Static Function
	@author user
	@since 03/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function verificaInfo(cNumOc)
	local aData 	:= {}
	local cQuery	:= ""
	local cAlias 	:= ""
	local aTemp		:= {}

	cAlias := getNextAlias()

	cQuery := "SELECT "
	cQuery += " 	ZEG.*, "
	cQuery += " 	ZEH.*, "
	cQuery += " 	ZEH.R_E_C_N_O_ AS RECNO "
	cQuery += " FROM " + RetSqlTab("ZEH") + " "
	cQuery += " INNER JOIN " + RetSqlTab("ZEG") + " "
	cQuery += "  ON  ZEG.ZEG_CODIGO = ZEH.ZEH_NUMMM "
	cQuery += "  AND ZEG.D_E_L_E_T_ = ''"
	cQuery += "  AND ZEG.ZEG_FILIAL = '" + xFilial("ZEG") + "'"
	cQuery += " WHERE ZEH.D_E_L_E_T_ = ''"
	cQuery += " AND ZEH.ZEH_FILIAL = '" + xFilial("ZEH") + "'"
	cQuery += " AND ZEH.ZEH_NUMOC = '" + cNumOc + "'"

	TCQUERY cQuery NEW ALIAS (cAlias)
	DbSelectArea(cAlias)

	While (cAlias)->(!Eof())

		aTemp := {}

		aAdd(aTemp, xFilial("ZEH"))		  		//01-ZEH_FILIAL
		aAdd(aTemp, (cAlias)->ZEH_ITEM)		  //02-ZEH_ITEM
		aAdd(aTemp, (cAlias)->ZEH_NUMOC)		//03-ZEH_NUMOC
		aAdd(aTemp, (cAlias)->ZEH_NUMMM)		//04-ZEH_NUMMM
		aAdd(aTemp, (cAlias)->ZEG_DESCRI)		//05-ZEH_DESCRI
		aAdd(aTemp, (cAlias)->ZEG_DEPTO)		//06-ZEH_DEPTO
		aAdd(aTemp, (cAlias)->ZEG_DESDEP)	  //07-ZEH_DESDEP
		aAdd(aTemp, (cAlias)->ZEH_QUANT)		//08-ZEH_QUANT
		aAdd(aTemp, (cAlias)->ZEH_OBS)			//09-ZEH_OBS
		aAdd(aData,{(cAlias)->RECNO,aTemp})

		(cAlias)->(DbSkip())
	endDo

	(cAlias)->(DbCloseArea())

Return aData

/*/{Protheus.doc} nomeStaticFunction
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
Static Function montaPer(cPerg)

//DATA AV=BATE DE / AATE
//PLACA DO VEICULO DE / ATE
//ORDEM DE CARREGAMENTO DE / ATE
	local lRet      := .t.
	Private bValid  := Nil
	Private cF3	    := ""
	Private cSXG    := Nil
	Private cPyme   := Nil

	U_xPutSx1(cPerg,'01','Data Abatimento de?'    ,'','','mv_ch1','D',08,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR01')
	U_xPutSx1(cPerg,'02','Data Abatimento Ate?'   ,'','','mv_ch2','D',08,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR02')
	U_xPutSx1(cPerg,'03','Placa De?'              ,'','','mv_ch3','C',08,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR03')
	U_xPutSx1(cPerg,'04','Placa Ate?'             ,'','','mv_ch4','C',08,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR04')
	U_xPutSx1(cPerg,'05','Ord. Carregamento De?'  ,'','','mv_ch5','C',08,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR05')
	U_xPutSx1(cPerg,'06','Ord. Carregamento Ate?' ,'','','mv_ch6','C',08,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR06')

	lRet := Pergunte(cPerg,.T.)

Return lRet


/*###############################################################################################*/
/* -------------------------------- Chamada do ponto de entrada -------------------------------- */
/*###############################################################################################*/
User Function ADLFV17M()

	Local aParam     := PARAMIXB
	Local lRet       := .T.
	Local oObj       := ''
	Local cIdPonto   := ''
	Local cIdModel   := ''
	Local lIsGrid    := .F.
	local nOpc       := 0
	local aData			:= {}
	local i					:= 0

	Local nLinha     := 0
	Local nQtdLinhas := 0
	Local cMsg       := ''
	local cID        := ""

	If aParam <> NIL
		oObj       := aParam[1]
		cIdPonto   := aParam[2]
		cIdModel   := aParam[3]
		lIsGrid    := ( Len( aParam ) > 3 )
		nOpc       := oObj:GetOperation()

		If cIdPonto == 'MODELVLDACTIVE' .AND. nOpc == MODEL_OPERATION_UPDATE //FORMPRE ou MODELPRE

			cIntegracao	:= ZV1->ZV1_INTEGR
			cNumOc			:= ZV1->ZV1_NUMOC

			if Alltrim(Upper(cIntegracao)) == "I"
				cMsgError := "Atenção, Ordem ja integrada no SAG. Alteração nao permitida! " + cvaltochar(cNumOC)
				Help( ,, 'Help',, cMsgError, 1, 0 )
				lRet := .F.
			endif

		endif

	endif

Return (lRet)

/*/{Protheus.doc} verificaMortalidade
  (long_description)
  @type  Static Function
  @author user
  @since 20/05/2021
  @version version
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
Static Function verificaMortalidade()
	local lRet          := .F.
	local nX            := 0
	local nMortalidade  := FwFldGet("ZV1_MORTAL")
	local nValor        := 0

	oModel  := FwModelActivate()
	oObjZEH := oModel:GetModel("ZEHDETAIL")

	For nX := 1 to oObjZEH:length()
		oObjZEH:GoLine(nX)

		if !oObjZEH:IsDeleted()
			nValor += oObjZEH:GetValue("ZEH_QUANT")
		endif

	next nX

	if nMortalidade != nValor
		lRet := .T.
	endif

Return lRet
