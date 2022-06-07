#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"

#DEFINE STR0001 "Manutenção Frango Vivo"
#DEFINE STR0002 "Manutenção Frango Vivo"
#DEFINE STR0003 "Manutenção Frango Vivo"

#define ZEIVISUAL '|ZEI_ITEM|ZEI_DEPTO|ZEI_DEPDES|ZEI_NUMMP|ZEI_DESCRI|ZEI_MINUTO|ZEI_OBS|' 

/*/{Protheus.doc} User Function U_ADLFV017P()
  Tela de gestão de ordens de carregamento  - PCP 
  @type tkt -  13294
  @author Rodrigo Romão
  @since 18/05/2021
  @history Chamado T.I - Leonardo P. Monteiro  - 16/07/2021 - Correção na função de upload dos registros no grid ZEH.
  @history Ticket 13294 - Leonardo P. Monteiro - 13/08/2021 - Melhoria para o projeto apontamento de paradas p/ o recebimento do frango vivo. 
  @history Ticket 41586 - Everson              - 05/10/2021 - Tratamento para validação de inclusão de nf.
  @history Ticket 69945 - Fernando Macieira    - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
  @history Ticket 73466 - Everson              - 25/05/2022 - Adicionada melhoria de para fechamento de registro.
/*/
User Function ADLFV017P() // U_ADLFV017P()

	local cPerg   := PadR("ADLFV017P",10)
	Local oBrowse := nil
	local cFiltro := ""
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de gestão de ordens de carregamento  - PCP ')	

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

	oBrowse:AddLegend("ZV1_STATUS='I'"					, "BR_AZUL"	    , "PRIMEIRA PESAGEM", "1")
	oBrowse:AddLegend("ZV1_STATUS='R'"					, "BR_LARANJA" 	, "SEGUNDA PESAGEM", "1")
	oBrowse:AddLegend("ZV1_STATUS='M'"					, "BR_MARRON" 	, "PESAGEM MANUAL", "1")
	oBrowse:AddLegend("ZV1_STATUS='G'"					, "BR_VERDE" 	, "GERADO FRETE", "1")
	oBrowse:AddLegend("ALLTRIM(ZV1_STATUS)=''"	        , "BR_PRETO" 	, "ORDEM NAO UTILIZADA", "1")

	oBrowse:AddLegend("(ZV1_FECHA='' .OR ZV1_FECHA = '1')"	, "BR_BRANCO"	 , "ABERTO", "2")
	oBrowse:AddLegend("ZV1_FECHA ='3'"					    , "YELLOW" 	     , "FECHADO MANUAL",  "2")
	oBrowse:AddLegend("ZV1_FECHA ='2'"					    , "BR_VIOLETA"	 , "FECHADO AUTOMÁTICO", "2")

	// DEFINE DE ONDE SERÁ RETIRADO O MENUDEF
	oBrowse:SetMenuDef("ADLFV017P")

Return (oBrowse)

// OPERAÇÕES DA ROTINA
Static Function MenuDef()
	local aRotina := {}

	//Local aRotina := FWMVCMenu("ADLFV017P")
	ADD OPTION aRotina Title 'Visualizar'   Action 'VIEWDEF.ADLFV017P'  OPERATION 2  ACCESS 0
	ADD OPTION aRotina Title 'Editar'       Action 'VIEWDEF.ADLFV017P'  OPERATION 4  ACCESS 0
	ADD OPTION aRotina Title 'Fechar Ordem' Action 'U_ADLFV171()'  OPERATION 10 ACCESS 0 //Everson - 24/05/2022. Chamado 73466.

Return (aRotina)
/*/{Protheus.doc} User Function ADLFV171
	Fecha ordem de carregamento.
	Chamado 73466.
	@type  Function
	@author Everson
	@since 24/05/2022
	@version 02
	/*/
User Function ADLFV171()

	//Variáveis.
	Local aArea := GetArea()

	If ZV1->ZV1_2PESO <= 0
		MsgInfo("Registro não possui peso final. Operação não permitida.", "Função ADLFV171(ADLFV017P)")
		RestArea(aArea)
		Return Nil

	EndIf

	//1 - Aberto
	//2 - Fechado Automático
	//3 - Fechado Manual
	If ZV1->ZV1_FECHA <> "1" .And. Alltrim(cValToChar(ZV1->ZV1_FECHA)) <> ""
		MsgInfo("Registro já está fechado.", "Função ADLFV171(ADLFV017P)")
		RestArea(aArea)
		Return Nil

	EndIf

	If ! MsgYesNo("Deseja fechar o registro?", "Função ADLFV171(ADLFV017P)")
		RestArea(aArea)
		Return Nil

	EndIf

	Begin Transaction

		RecLock("ZV1", .F.)
			ZV1->ZV1_FECHA := "3"
		ZV1->(MsUnLock())

		//GrLogZBE(dDate,cTime,cUser,cLog,cModulo,cRotina,cParamer,cEquipam,cUserRed)
		u_GrLogZBE(msDate(),TIME(),cUserName, "FECHAMENTO DE REGISTRO","FRANGO VIVO","ADLFV017P",;
				   "Número OC " + cValToChar(ZV1->ZV1_NUMOC),ComputerName(),LogUserName())


	End Transaction

	RestArea(aArea)

Return Nil
// REGRAS DE NEGÓCIO
Static Function ModelDef()
	//local nAtual := 0
	local oModel 		:= MPFormModel():New("ADLFV17M")
	//local oModel 		:= MPFormModel():New("ADLFV17M",,,{|oModel| commitRot(oModel)},)
	//local aGatilhos := {}

	// INSTANCIA O SUBMODELO
	Local oStruZV1 := FwFormStruct(1, "ZV1")
	//Local oStruZEH := FwFormStruct(1, "ZEH")
	Local oStruZEI := FwFormStruct(1, "ZEI")

	//oStruZEH:SetProperty( 'ZEH_DESCRI'  , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_preencheCampo('ZEG','ZEG_DESCRI')" ))
	//oStruZEH:SetProperty( 'ZEH_DEPTO'   , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_preencheCampo('ZEG','ZEG_DEPTO')"  ))
	//oStruZEH:SetProperty( 'ZEH_DESDEP'  , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_preencheCampo('ZEG','ZEG_DESDEP')" ))

	oStruZEI:SetProperty( 'ZEI_DESCRI'  , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_preencheCampo('ZEE','ZEE_DESCRI')" ))
	//oStruZEI:SetProperty( 'ZEI_DEPTO'   , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_preencheCampo('ZEG','ZEG_DEPTO')"  ))
	oStruZEI:SetProperty( 'ZEI_DEPDES'  , MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,"U_preencheCampo('ZGC','ZGC_NOME')" ))

	oStruZEI:SetProperty( 'ZEI_NUMOC'   , MODEL_FIELD_OBRIGAT, .F.)
	oStruZEI:SetProperty( 'ZEI_MINUTO'  , MODEL_FIELD_OBRIGAT, .T.)

	
	bLoad := {|oModel, oGridModel, lCopy| loadGrid(oModel, oGridModel, lCopy)}

	// DEFINE O SUBMODELO COMO FIELD
	oModel:AddFields("ZV1MASTER", NIL, oStruZV1)
	//oModel:AddGrid("ZEHDETAIL", "ZV1MASTER", oStruZEH)
	//oModel:AddGrid("ZEHDETAIL", "ZV1MASTER", oStruZEH, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, bLoad)
	oModel:AddGrid("ZEIDETAIL", "ZV1MASTER", oStruZEI)

	//oModel:GetModel("ZEHDETAIL"):SetUseOldGrid(.t.)
	//oModel:GetModel( 'ZEHDETAIL' ):SetNoInsertLine(.F.)

	//oModel:SetRelation("ZEHDETAIL", {{"ZEH_FILIAL", "xFilial('ZEH')"},{"ZEH_NUMOC","ZV1_NUMOC"}}, ZEH->(IndexKey(1)))
	// |ZEI_ITEM|ZEI_DEPTO|ZEI_DEPDES|ZEI_NUMMP|ZEI_DESCRI|ZEI_MINUTO|ZEI_OBS|
	oModel:GetModel("ZEIDETAIL"):SetUniqueLine( {'ZEI_DEPTO','ZEI_NUMMP' } )
	oModel:SetRelation("ZEIDETAIL", {{"ZEI_FILIAL", "xFilial('ZEI')"},{"ZEI_NUMOC","ZV1_NUMOC"}}, ZEI->(IndexKey(1)))


	
	//oModel:GetModel('ZEHDETAIL'):SetOptional(.T.)
	oModel:GetModel('ZEIDETAIL'):SetOptional(.T.)

	//oModel:GetModel( 'ZEHDETAIL' ):SetNoInsertLine( .F. )
	//oModel:GetModel( 'ZEHDETAIL' ):SetNoDeleteLine( .F. )

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
	//Local oStruZEH := FwFormStruct(2, "ZEH")
	Local oStruZEI := FwFormStruct(2, "ZEI", {| cCampo |   "|" + AllTrim( cCampo ) + '|' $ ZEIVISUAL	})

	// RECEBE O MODELO DE DADOS
	Local oModel := FwLoadModel("ADLFV017P")

	// INDICA O MODELO DA VIEW
	oView:SetModel(oModel)
	//oView:SetContinuousForm(.T.)

	// CRIA ESTRUTURA VISUAL DE CAMPOS
	oView:AddField("VIEW_ZV1",oStruZV1 ,"ZV1MASTER")
	//oView:AddGrid("VIEW_ZEH" ,oStruZEH ,"ZEHDETAIL")
	oView:AddGrid("VIEW_ZEI" ,oStruZEI ,"ZEIDETAIL")

	//oStruZV1:RemoveField('ZV1_MORTAL')

	//oStruZEH:RemoveField('ZEH_FILIAL')
	//oStruZEH:RemoveField('ZEH_NUMOC')
	/*
	oStruZEI:RemoveField('ZEI_FILIAL')
	oStruZEI:RemoveField('ZEI_NUMOC')
	oStruZEI:RemoveField('ZEI_GRANJA')
	oStruZEI:RemoveField('ZEI_DTABAT')
	oStruZEI:RemoveField('ZEI_PLACA')
	*/
	
	//oView:AddIncrementField( "VIEW_ZEH", "ZEH_ITEM" )
	oView:AddIncrementField( "VIEW_ZEI", "ZEI_ITEM" )

	oView:CreateHorizontalBox("TELA_SUPERIOR",60)
	//oView:CreateHorizontalBox("GRID_MOTIVO_MORTALIDADE",35, nil, .F.)
	oView:CreateHorizontalBox("GRID_MOTIVO_PARADA",40)

	oView:SetOwnerView("VIEW_ZV1", "TELA_SUPERIOR")
	//oView:SetOwnerView("VIEW_ZEH", "GRID_MOTIVO_MORTALIDADE")
	oView:SetOwnerView("VIEW_ZEI", "GRID_MOTIVO_PARADA")

	//oView:EnableTitleView("VIEW_ZEH", STR0003, RGB(224, 30, 43))
	oView:EnableTitleView("VIEW_ZEI", STR0002, RGB(224, 30, 43))
	// DEFINE OS TITULOS DAS SUBVIEWS

	oView:EnableTitleView("VIEW_ZV1")
	//oView:EnableTitleView("VIEW_ZEH")
	oView:EnableTitleView("VIEW_ZEI")

Return (oView)


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
	/*
	local cRet := ""
	local xArea := getArea()

	if Alltrim(cTabela) == "ZEE"
		cRet := POSICIONE(cTabela,1,xFilial(cTabela)+ZEI->ZEI_NUMMP,cNomeCampo)
	Elseif Alltrim(cTabela) == "ZEG"
		cRet := POSICIONE(cTabela,1,xFilial(cTabela)+ZEH->ZEH_NUMMM,cNomeCampo)
	endif
	*/
	restArea(xArea)
Return cRet

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
	//local oViewA	:= FwViewActive()
	local cQuery	:= ""
	local cAlias	:= ""
	local aData 	:= {}
	//Local nLin		:= 0
	Local oGrid     := oModelA:GetModel('ZEHDETAIL')
	//local aData		:= oGrid:getOldData()
	//local cQuery	:= ""
	//local cAlias 	:= ""
	//local aTemp		:= {}
	local nItem		:= 0

	cNumOc	:= ZV1->ZV1_NUMOC
	nMortal	:= ZV1->ZV1_MORTAL

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


	If aParam <> NIL
		oObj       := aParam[1]
		cIdPonto   := aParam[2]
		cIdModel   := aParam[3]
		lIsGrid    := ( Len( aParam ) > 3 )
		nOpc       := oObj:GetOperation()

		If cIdPonto == 'MODELVLDACTIVE' .AND. nOpc == MODEL_OPERATION_UPDATE //FORMPRE ou MODELPRE

			cIntegracao	:= ZV1->ZV1_INTEGR
			cNumOc		:= ZV1->ZV1_NUMOC

			if Alltrim(Upper(cIntegracao)) == "I"
				cMsgError := "Atenção, Ordem ja integrada no SAG. Alteração nao permitida! " + cvaltochar(cNumOC)
				Help( ,, 'Help',, cMsgError, 1, 0 )
				lRet := .F.
			endif

		endif

		//Everson - 05/10/2021. Chamado 41586.
		If cIdPonto == 'MODELPOS' .And. ( nOpc == MODEL_OPERATION_UPDATE .Or. nOpc == MODEL_OPERATION_INSERT) //FORMPRE ou MODELPRE

			lRet := checkOp(M->ZV1_NUMOC, M->ZV1_NUMNFS, M->ZV1_SERIE, M->ZV1_FORREC, M->ZV1_LOJREC)

		EndIf
		//

	endif

Return (lRet)
/*/{Protheus.doc} checkOp
	Função valida se a nota fiscal já foi
	utilizada. Chamado 41586.
	@type  Static Function
	@author Everson
	@since 05/10/2021
	@version 01
/*/
Static Function checkOp(cOrdem, cNF, cSerie, cCliNF, cCliSr)

	//Variáveis.
	Local aArea	:= GetArea()
	Local lRet 	:= .T.
	Local cQuery:= ""

	//
	If Select("VZV1") > 0
		VZV1->(DbCloseArea())

	EndIf  

	//
	TcQuery cQuery New Alias "VZV1" 

	//
	cQuery := ""
	cQuery += " SELECT "
		cQuery += " ZV1_NUMOC, ZV1_NUMNFS, ZV1_SERIE, ZV1_CODFOR, ZV1_LOJFOR "
	cQuery += " FROM " 
		cQuery += " " + RetSqlName("ZV1") + " (NOLOCK) AS ZV1 " 
	cQuery += " WHERE "
		cQuery += " ZV1_FILIAL='"+FWxFilial("ZV1")+"' AND " // @history Ticket 69945 - Fernando Macieira    - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
		cQuery += " RTRIM(LTRIM(ZV1_NUMNFS)) = '" + Alltrim(cNF) + "' AND "
		cQuery += " RTRIM(LTRIM(ZV1_SERIE)) = '" + Alltrim(cSerie) + "' AND "
		cQuery += " ZV1_FORREC = '" + cCliNF + "' AND "
		cQuery += " ZV1_LOJREC = '" + cCliSr + "' AND "
		cQuery += " ZV1.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY ZV1_NUMOC "

	//
	TcQuery cQuery New Alias "VZV1"
	
	//
	DbSelectArea("VZV1")
	VZV1->(DbGoTop())
	If ! VZV1->(Eof())

		//
		If Alltrim(cValToChar(VZV1->ZV1_NUMOC)) <> Alltrim(cValToChar(cOrdem))
			lRet := .F.
			Help( ,, 'Help',, "A NF/Série " + cNF + " / " + cSerie +; 
			        " informada já foi utilizada na OC: " + VZV1->ZV1_NUMOC + ". A Pesagem não foi gravada.", 1, 0 )
			
		EndIf     
	
	EndIf

	//
	VZV1->(DbCloseArea())

	//
	RestArea(aArea)

Return lRet
