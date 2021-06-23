#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "RwMake.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"
/*/{Protheus.doc} User Function MTA010MNU
	Ponto de entrada adiciona botão cadastro de produtos. Chamado 037261.
	@type  Function
	@author Everson
	@since 19/03/2018 
	@version 01
	@history 29/11/2019, Everson, Chamado T.I. rotina para aprovação de cadastro bloqueado.
	@history 11/12/2019, Everson, Chamado 053902. Incluída validação para bloqueio e desbloqueio pela opção nas ações relacionadas.
	@history 07/05/2021, Everson, Chamado 13414. Tratamento para ocorrer liberação e desbloqueio de produto apenas pela controladoria.
	/*/
User Function MTA010MNU()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea	   := GetArea()
	Local cUsuLib  := GetMv("MV_#LBCADP",,"") //Everson - 29/11/2019. Chamado T.I.
	Local cUsuAtv  := GetMv("MV_#USUCON",,"") //Everson - 29/11/2019. Chamado T.I.
	
	//
	ADD OPTION aRotina TITLE "Env. SF."   ACTION "U_prodSFexp()" OPERATION  9 ACCESS 0

	//Everson - 07/05/2021. Chamado 13414.
	// //Everson - 29/11/2019. Chamado T.I.
	// If Alltrim(__cUserId) $cUsuLib

	// EndIf 
	// //

	//Everson - 07/05/2021. Chamado 13414.
	//Everson - 29/11/2019. Chamado T.I.
	If Alltrim(__cUserId) $cUsuAtv .Or. Alltrim(__cUserId) $cUsuLib
		ADD OPTION aRotina TITLE "Lib. Prod." ACTION "U_ADCOM033P()"  OPERATION 10 ACCESS 0
		ADD OPTION aRotina TITLE "Ativar/Desativar" ACTION "U_MTA10_05()"  OPERATION 10 ACCESS 0

	EndIf 
	//

	//
	RestArea(aArea)
	
Return( aRotina )
/*/{Protheus.doc} User Function prodSFexp
	Exporta dados para o Sales Force. Chamado 037261.
	@type  Function
	@author Everson
	@since 19/03/17
	@version 01
	/*/
User Function prodSFexp()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea	   	:= GetArea()
	Local oTelMenu	:= Nil
	Local oDe		:= Nil
	Local oAt		:= Nil
	Local oCanc  	:= Nil
	Local oOk		:= Nil
	Local oSay1		:= Nil
	
	//Private aItems	:= {'1=Cadastro','2=Contrato','3=Frete','4=Vl Min. Seg'}
	//Private cCombo1 := ""
	//Private oCombo1	:= Nil
	Private cDe		:= SB1->B1_COD//Space(TamSX3("B1_COD")[1])
	Private cAte	:= SB1->B1_COD//Space(TamSX3("B1_COD")[1])
	
	oTelMenu			:= MsDialog():Create()
	oTelMenu:cName     := "oTelMenu"
	oTelMenu:cCaption  := "Envio SalesForce"
	oTelMenu:nLeft     := 34
	oTelMenu:nTop      := 222
	oTelMenu:nWidth    := 250
	oTelMenu:nHeight   := 210
	oTelMenu:lShowHint := .F.
	oTelMenu:lCentered := .T.
	
		//
		//cCombo1:= aItems[1]
		//oCombo1 := TComboBox():New(010,010,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},;
		//aItems,100,20,oTelMenu,,{|| };
		//,,,,.T.,,,,,,,,,'cCombo1')
		
		oSay1:= TSay():New(010,010,{||'Informe os cadastros de produtos a serem enviadas ao SalesForce.'},oTelMenu,,,,,,.T.,CLR_RED,CLR_WHITE,100,15)
		
		oDe  := TGet():New(030,010,{|u|If(PCount() == 0,cDe,cDe := u)},oTelMenu,050,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cDe",,,,.T.,,,"De:",2)
		
		oAt  := TGet():New(050,010,{|u|If(PCount() == 0,cAte,cAte := u)},oTelMenu,050,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAte",,,,.T.,,,"Até:",2)
		
		oOk     := TButton():New(070,010,"Enviar"  ,oTelMenu,{|| exProdSfExp(cDe,cAte), oTelMenu:End() },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )
		oCanc   := TButton():New(070,075,"Cancelar",oTelMenu,{|| oTelMenu:End() },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )	
		
	oTelMenu:Activate(,,,.T.,{||.T.},,{||  })
	
Return Nil
/*/{Protheus.doc} exProdSfExp
	Envia tabela de preço para o SalesForce. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 19/03/2018
	@version 01
	/*/
Static Function exProdSfExp(cDe,cAte)
	
	//
	If FindFunction("U_ADVEN069P")
		U_ADVEN069P("",.F.," AND B1_COD BETWEEN '" + cDe + "' AND '" + cAte + "' ")
	
	EndIf

Return Nil
/*/{Protheus.doc} MTA10_05  
	Bloqueio/Liberação de cadastro de produto.
	@type  Function
	@author Everson
	@since 29/11/2019
	@version 01
	/*/
User Function MTA10_05()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea 	:= GetArea()
	Local cProd 	:= Alltrim(cValToChar(SB1->B1_COD))
	Local cAcao 	:= Iif(Alltrim(cValToChar(SB1->B1_MSBLQL)) = "1", "Liberação", "Bloqueio")
	Local cEmlLib	:= GetMv("MV_#EMLBP",,"") //Everson - 29/11/2019 - Chamado T.I.
	Local cQuery    := ""
	Local lProEdt	:= .T.

	//Everson - 11/12/2019 - Chamado 053902.
	cQuery := U_A10_02(Alltrim(cProd))
	If Select("D_CHKEDT2") > 0
		D_CHKEDT2->(DbCloseArea())

	EndIf
	TcQuery cQuery New Alias "D_CHKEDT2"
	DbSelectArea("D_CHKEDT2")
	D_CHKEDT2->(DbGoTop())
	If D_CHKEDT2->(Eof())
		lProEdt := .F.

	EndIf
	D_CHKEDT2->(DbCloseArea())

	//
	If Alltrim(cValToChar(SB1->B1_TIPO)) <> "PA" .Or. ! lProEdt //Everson - 11/12/2019 - Chamado 053902.
		MsgStop("Efetue o bloqueio/desbloqueio pelo cadastro do produto.","Função MTA10_05(MTA010MNU)")
		RestArea(aArea)
		Return Nil 

	EndIf

	//
	If ! MsgYesNo("Deseja enviar o cadastro do produto " + cProd + " para aprovação de " + cAcao + "?")
		RestArea(aArea)
		Return Nil 

	EndIf


	//
	RecLock("SB1",.F.)
		Replace B1_XAPROV With "S"
	SB1->(MsUnlock())

	//
	If ! Empty(cEmlLib)
		MsAguarde({||	U_enviaremail(allTrim(cEmlLib), "Bloqueio de Produto", "O produto " + cValToChar(SB1->B1_COD)+ " está pendente de aprovação.",,)},"Aguarde","Enviando Email...")

	EndIf

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} MTA10_06  
	Valida bloqueio na edição do campo B1_MSBLQL.
	@type  Function
	@author Everson
	@since 29/11/2019
	@version 01
	/*/
User Function MTA10_06() // U_MTA10_06()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea 	:= GetArea()
	Local lAtzEdt	:= GetMv("MV_#ATLEDT",,.F.) 
	Local lRet		:= .T.

	//
	Conout( DToC(Date()) + " " + Time() + " MTA010MNU - MTA10_06 - lAltera - " + cValToChar(ALTERA) )
	Conout( DToC(Date()) + " " + Time() + " MTA010MNU - MTA10_06 - lInclui - " + cValToChar(INCLUI) )

	//
	If lAtzEdt .And. Alltrim(cValToChar(M->B1_TIPO)) = "PA"

		//
		lRet := .F.

	Else
		lRet := __cuserid$GETMV("MV_#USUCON",,"")  

	EndIf

	//
	Conout( DToC(Date()) + " " + Time() + " MTA010MNU - MTA10_06 - lRet - " + cValToChar(lRet) )

	//
	RestArea(aArea)

Return lRet
