#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "RwMake.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} User Function MA410MNU
	(
		P.E. de MATA410. Ponto de entrada disparado antes da abertura do Browse, 
		caso Browse inicial da rotina esteja habilitado, ou antes da apresentação do Menu de opções, 
		caso Browse inicial esteja desabilitado. Para habilitar ou desabilitar o Browse, entre na rotina, 
		clique em Configurações/Browse Inicial e selecione a opção desejada:
			Sim - Habilitar Browse Inicial
			Não - Desabilitar Browse Inicial
			Este ponto de entrada pode ser utilizado para inserir novas opções no array aRotina.
	)
	@type  Function
	@author Vicente de Paula
	@since 26/02/2020
	@version 10
	@history chamado 056247 - FWNM     - 16/04/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history chamado TI     - FWNM     - 05/08/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history Ticket 70142   - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	@history Ticket 69574   - Abel Bab - 21/03/2022 - Projeto FAI
	@history Ticket 69574   - Sigoli   - 26/05/2022 - Projeto FAI - correção error log -variable does not exist CFILAN on U_ALTSFEXP
	
/*/
User function MA410MNU()

	local aArea     := GetArea()

	aadd( aRotina, { "Solicita Aprov. Refaturamento", "U_ADFAT007P",0,8})
	aadd( aRotina, { "Refaturamento", "U_ALTPEDREF('P',0,'')",0,4})
	aadd( aRotina, { "Rel.Status PV", "U_ADFIN029P()",0,5})
	aadd( aRotina, { "Monitora PV"  , "U_ADVEN049P()",0,8})
	aadd( aRotina, { "Env. SF"      , "U_pedSfExp()" ,0,9})		//Everson - 22/03/2018. Chamado 037261.
	aadd( aRotina, { "Altera CondPag", "U_ADVEN092P()",0,8})	// Ricardo Lima - 10/05/18
	aadd( aRotina, { "Altera SF"      , "U_AltSfExp()" ,0,10})	//Everson - 22/03/2018. Chamado 037261.
 //   aAdd( aRotina, { 'Registra Bol Bradesco WS'     , "u_BolBrad()" , 0, 5 }) // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 16/04/2020 // chamado TI     - FWNM     - 05/08/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
    aAdd( aRotina, { 'Imprime PDF Bol Bradesco WS'  , "u_RunHCRFB()", 0, 6 }) // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 16/04/2020

	RestArea(aArea)

return NIL

/*/{Protheus.doc} User Function pedSfExp
	(Chamado 037261 - Exporta dados para o Sales Force.)
	@type  Function
	@author Everson
	@since 22/03/18
	@version 1
/*/
User Function pedSfExp()

	Local aArea	   	:= GetArea()
	Local oTelMenu	:= Nil
	Local oDe		:= Nil
	Local oAt		:= Nil
	Local oCanc  	:= Nil
	Local oOk		:= Nil

	Private aItems	:= {'1=Pedido','2=NF do pedido','3=Cadastro cliente','4=NF Devolução','5=Ocorr. Logistica','6=Cond. Pag.'}
	Private cCombo1 := ""
	Private oCombo1	:= Nil
	Private cDe		:= SC5->C5_NUM
	Private cAte	:= SC5->C5_NUM

	oTelMenu			:= MsDialog():Create()
	oTelMenu:cName     := "oTelMenu"
	oTelMenu:cCaption  := "Envio SalesForce"
	oTelMenu:nLeft     := 34
	oTelMenu:nTop      := 222
	oTelMenu:nWidth    := 250
	oTelMenu:nHeight   := 320
	oTelMenu:lShowHint := .F.
	oTelMenu:lCentered := .T.

	//
	cCombo1:= aItems[1]
	oCombo1 := TComboBox():New(025,010,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},;
		aItems,100,20,oTelMenu,,{|| };
		,,,,.T.,,,,,,,,,'cCombo1')

	oDe := TGet():New(060,010,{|u|If(PCount() == 0,cDe,cDe := u)},oTelMenu,050,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cDe",,,,.T.,,,"Pedido de :",1)

	oAt := TGet():New(090,010,{|u|If(PCount() == 0,cAte,cAte := u)},oTelMenu,050,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAte",,,,.T.,,,"Pedido até:",1)

	oOk     := TButton():New(126,010,"Enviar"  ,oTelMenu,{|| exProdSfExp(cCombo1,cDe,cAte), oTelMenu:End() },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	oCanc   := TButton():New(126,075,"Cancelar",oTelMenu,{|| oTelMenu:End() },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	oTelMenu:Activate(,,,.T.,{||.T.},,{||  })

Return Nil

/*/{Protheus.doc} Static Function exProdSfExp
	(Chamado 037261. Envia tabela de preço para o SalesForce.)
	@type  Function
	@author Everson
	@since 19/03/2018
	@version 1
/*/
Static Function exProdSfExp(cCombo1,cDe,cAte)

	Local cExpSql := ""

	If FindFunction("U_ADVEN050P") .And. cCombo1 == "1"
		//Static Call(M410STTS,envSF,,," AND C5_NUM BETWEEN '" + cDe + "' AND '" + cAte + "' AND C5_NOTA <>'' AND C5_SERIE <> '' AND C5_NOTA <> 'XXXXXXXXX' ")
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_10STTSA0( ,," AND C5_NUM BETWEEN '" + cDe + "' AND '" + cAte + "' AND C5_NOTA <>'' AND C5_SERIE <> '' AND C5_NOTA <> 'XXXXXXXXX' ")
	EndIf

	If FindFunction("U_ADVEN074P") .And. cCombo1 == "2"

		cExpSql := " AND RTRIM(LTRIM(F2_DOC)) + RTRIM(LTRIM(F2_SERIE)) IN ( "
		cExpSql += " SELECT RTRIM(LTRIM(C5_NOTA)) + RTRIM(LTRIM(C5_SERIE)) AS NF FROM " + RetSqlName("SC5") + " AS SC5 "
		cExpSql += " WHERE C5_FILIAL = '" + cFilAnt + "' AND  C5_NUM BETWEEN '" + cDe + "' AND '" + cAte + "' AND C5_NOTA <>'' AND C5_SERIE <> '' AND C5_NOTA <> 'XXXXXXXXX' "
		cExpSql += " ) "

		U_ADVEN074P(cEmpAnt,cFilAnt,"",.F.,cExpSql)

	EndIf

	If FindFunction("U_ADVEN076P") .And. cCombo1 == "3"
		cExpSql := " AND RTRIM(LTRIM(A1_COD)) + RTRIM(LTRIM(A1_LOJA)) IN ( "
		cExpSql += " SELECT RTRIM(LTRIM(C5_CLIENTE)) + RTRIM(LTRIM(C5_LOJACLI)) AS CLI FROM " + RetSqlName("SC5") + " AS SC5 "
		cExpSql += " WHERE C5_FILIAL = '" + cFilAnt + "' AND  C5_NUM BETWEEN '" + cDe + "' AND '" + cAte + "' "
		cExpSql += " ) "

		U_ADVEN076P("","",.F.,cExpSql,,.T.,"")
	EndIf

	If FindFunction("U_ADVEN077P") .And. cCombo1 == "4"
		cExpSql := " AND RTRIM(F1_FILIAL) +  RTRIM(F1_DOC) + RTRIM(F1_SERIE) + RTRIM(F1_FORNECE) + RTRIM(F1_LOJA) IN ( "
		cExpSql += " SELECT  "
		cExpSql += " DISTINCT RTRIM(D1_FILIAL) +  RTRIM(D1_DOC) + RTRIM(D1_SERIE) + RTRIM(D1_FORNECE) + RTRIM(D1_LOJA)  "
		cExpSql += " FROM " + RetSqlName("SD1") + " (NOLOCK) AS SD1 "
		cExpSql += " INNER JOIN "
		cExpSql += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 ON "
		cExpSql += " D1_FILIAL = C5_FILIAL "
		cExpSql += " AND D1_NFORI = C5_NOTA "
		cExpSql += " AND D1_SERIORI = C5_SERIE "
		cExpSql += " AND D1_FORNECE = C5_CLIENTE "
		cExpSql += " AND D1_LOJA = C5_LOJACLI "
		cExpSql += " WHERE  "
		cExpSql += " D1_FILIAL = '" + cFilAnt + "'  "
		cExpSql += " AND C5_NUM BETWEEN '" + cDe + "' AND '" + cAte + "' "
		cExpSql += " AND SC5.D_E_L_E_T_ = '' "
		cExpSql += " AND SD1.D_E_L_E_T_ = '' "
		cExpSql += " ) "

		//ADVEN077P(cEmp,cFili,cParamBsc,lAut,cExpSql,lItem)
		U_ADVEN077P(cEmpAnt,cFilAnt,"",.F.,cExpSql,.F.)
	EndIf

	If FindFunction("U_ADVEN084P") .And. cCombo1 == "5"
		cExpSql := " AND RTRIM(LTRIM(F2_DOC)) + RTRIM(LTRIM(F2_SERIE)) IN ( "
		cExpSql += " SELECT RTRIM(LTRIM(C5_NOTA)) + RTRIM(LTRIM(C5_SERIE)) AS NF FROM " + RetSqlName("SC5") + " AS SC5 "
		cExpSql += " WHERE C5_FILIAL = '" + cFilAnt + "' AND  C5_NUM BETWEEN '" + cDe + "' AND '" + cAte + "' AND C5_NOTA <>'' AND C5_SERIE <> '' AND C5_NOTA <> 'XXXXXXXXX' "
		cExpSql += " ) "

		U_ADVEN084P("","",.F.,cExpSql)
	EndIf

	If FindFunction("U_ADVEN070P") .And. cCombo1 == "6"
		cExpSql := " AND E4_CODIGO IN ( "
		cExpSql += " SELECT C5_CONDPAG FROM " + RetSqlName("SC5") + " AS SC5 WHERE C5_FILIAL = '" + cFilAnt + "' AND  C5_NUM BETWEEN '" + cDe + "' AND '" + cAte + "' AND D_E_L_E_T_ = ''  "
		cExpSql += " ) "

		U_ADVEN070P("","",.F.,cExpSql)
	EndIf

Return Nil

/*/{Protheus.doc} User Function AltSfExp
	(Chamado 037261. Chama a alteração do pedido de venda.)
	@type  Function
	@author Everson
	@since 13/05/2018
	@version 1
/*/
User Function AltSfExp()

	Local aArea	:= GetArea()
	Local cUser	:= ""
	Local cFilSF:= GetMv("MV_#SFFIL",,"02|0B|") //Ticket 69574   - Abel Bab - 21/03/2022 - Projeto FAI
	Local cEmpSF:= GetMv("MV_#SFEMP",,"01|") //Ticket 69574   - Abel Bab - 21/03/2022 - Projeto FAI

	If !cEmpAnt$cEmpSF .Or. !cFilAnt$cFilSF .Or. Alltrim(cValToChar( SC5->C5_XGERSF )) <> "2" //Ticket 69574   - Abel Babini      - 21/03/2022 - Projeto FAI
		RestArea(aArea)
		Return Nil
	EndIf

	//Usuários que podem alterar o pedido de venda.
	cUser := GetMv("MV_#SFUSAL",,"")

	If ! (__cUserId $cUser)
		MsgStop("Usuário sem premissão.","Função AltSfExp (M410MNU)")
		RestArea(aArea)
		Return Nil
	EndIf
	
	/*
	If ! Empty(Alltrim(cValToChar( SC5->C5_NOTA )))
		MsgStop("Campo nota fiscal do pedido está preenchido.","Função AltSfExp (M410MNU)")
		RestArea(aArea)
		Return Nil
	EndIf
	*/
	
	If ! Empty(Alltrim(cValToChar( SC5->C5_PLACA )))
		MsgStop("Campo placa do pedido está preenchido, para alterar o pedido entrar em contato com a Logística.","Função AltSfExp (M410MNU)")
		RestArea(aArea)
		Return Nil
	EndIf

	RESTEXECUTE()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} RESTEXECUTE
	(Chamado 037261.Executa a alteração do pedido de venda.)
	@type  Static Function
	@author Everson
	@since 13/05/2018
	@version 1
/*/
Static Function RESTEXECUTE()

	Local aArea		:= GetArea()
	Local nRet 		:= 0
	local lPedBloq	:= .F.

	//Checa liberação do pedido de venda.
	lPedBloq := Iif( Alltrim(cValToChar( SC5->C5_BLQ )) == "1",.T.,.F.)

	SetFunName("RESTEXECUTE")
	nRet := A410Altera("SC5",SC5->( Recno() ), 4 )

	//Se alterou o pedido de venda, gera log.
	If nRet <> 0

		//Static Call(ADVEN086P,chkLiber,Alltrim(cValToChar( SC5->C5_NUM )),lPedBloq)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN090A0( Alltrim(cValToChar( SC5->C5_NUM )),lPedBloq ) 
		//Obs: O fonte ADVEN086P nao possuia a funcao chklib, foi utizada do fonte ADVEN090P que aparentemente tem a finalidade desejada.

		DbSelectArea("ZBE")
		RecLock("ZBE",.T.)
		Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
		Replace ZBE_DATA 	   	WITH dDataBase
		Replace ZBE_HORA 	   	WITH Time()
		Replace ZBE_USUARI	    WITH Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        WITH "ALTERACAO PEDIDO DE VENDA SF " + Alltrim(cValToChar( SC5->C5_NUM ))
		Replace ZBE_MODULO	    WITH "COMERCIAL"
		Replace ZBE_ROTINA	    WITH "AltSfExp"
		Replace ZBE_PARAME      WITH Alltrim(cValToChar( SC5->C5_NUM ))
		ZBE->( MsUnLock())

	EndIf

	RestArea(aArea)

Return Nil
