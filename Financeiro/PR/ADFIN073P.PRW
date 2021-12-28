#Include "RwMake.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "Totvs.ch"
#Include "Topconn.ch"    

Static cCadastro := "Reembolso" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADFIN073Pบ Autor ณ Everson - Ch:T.I.                                    บ Data ณ  01/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Rotina para lan็amento de reembolso.                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAltera็a๕ ณ Adicionado filtro por natureza financeira.                                                   บฑฑ
ฑฑบAltera็a๕ ณ Everson - 10/05/2019. Ch. TI. Adicionada quantidade no relat๓rio.                            บฑฑ
ฑฑบAltera็a๕ ณ Everson - 13/05/2019. Ch. TI. Adicionado bloqueio de altera็ใo.                              บฑฑ
ฑฑบAltera็a๕ ณ Everson - 16/05/2019. Ch. TI. Adicionado pre็o unitแrio ao reembolso e tela de valid produto.บฑฑ
ฑฑบAltera็a๕ ณ Everson - 08/08/2019. Ch. TI. Removida atualiza็ใo do campo de pedido de compra.             บฑฑ
ฑฑบAltera็a๕ ณ Everson - 09/09/2019. Ch. 051527. Adicionada a op็ใo de n๚ดmero de projeto.                  บฑฑ
ฑฑบAltera็a๕ ณ Everson - 28/12/2021. Ch. 051527. Adicionada a op็ใo de n๚ดmero de projeto.                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
User Function ADFIN073P() // U_ADFIN073P

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local oBrowse
	Local cEmpAdo	:= SuperGetMv("ZZ_FIN073A",,"01")
	
	//
	IF !cEmpAnt$cEmpAdo
		MsgInfo("Empresa nใo estแ configurada para utiliza็ใo da rotina!", "Empresa nใo Autorizada")
	else
		U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para lan็amento de reembolso.')
		
		//
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("ZFI")
		oBrowse:SetDescription(cCadastro)
		oBrowse:AddLegend("ZFI_STATUS = '1'","BR_VERDE"   ,"Aberto")
		oBrowse:AddLegend("ZFI_STATUS = '2'","BR_VERMELHO","Pedido de compra gerado")
		oBrowse:Activate()
	ENDIF

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AdMnDef  บ Autor ณ Everson - Ch:T.I.                                    บ Data ณ  01/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Menu.                                                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
STATIC Function MenuDef()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar" ACTION "ViewDef.ADFIN073P" OPERATION 2  ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "ViewDef.ADFIN073P" OPERATION 3  ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "ViewDef.ADFIN073P" OPERATION 4  ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION "ViewDef.ADFIN073P" OPERATION 5  ACCESS 0
	ADD OPTION aRotina TITLE "Legenda"    ACTION "U_ADFIN731()"      OPERATION 9  ACCESS 0
	ADD OPTION aRotina TITLE "Ger. Pedido Compra"   ACTION "MsAguarde({|| U_ADFIN732() },'Aguarde','Gerando pedido de compra...')" OPERATION 11 ACCESS 0 
	ADD OPTION aRotina TITLE "Imprimir Reembolso"   ACTION "MsAguarde({|| U_ADFIN734() },'Aguarde','Imprimindo...')" OPERATION 10 ACCESS 0
	
Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADFIN731 บ Autor ณ Everson - Ch:T.I.                                    บ Data ณ  01/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Legenda.                                                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
User Function ADFIN731()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local aLegenda := {}

	U_ADINF009P('ADFIN073P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para lan็amento de reembolso.')

	Aadd(aLegenda,{"BR_VERDE"   ,"Aberto" })
	Aadd(aLegenda,{"BR_VERMELHO","Pedido de compra gerado"})

	//
	BrwLegenda(cCadastro,"Legenda",aLegenda)

	//
	RestArea(aArea)

Return NiL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADFIN732 บ Autor ณ Everson - Ch:T.I.                                    บ Data ณ  03/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Gera pedido de compra.                                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
User Function ADFIN732()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea			 := GetArea()
	Local cQuery		 := ""
	Local cFilZFI		 := Alltrim(cValToChar( ZFI->ZFI_FILIAL ))
	Local cFornec		 := Alltrim(cValToChar( ZFI->ZFI_FORNEC ))
	Local cLoja			 := Alltrim(cValToChar( ZFI->ZFI_LOJA ))
	Local cNmFor		 := Alltrim(cValToChar( ZFI->ZFI_NMFORN ))
	Local cCodZFI		 := Alltrim(cValToChar( ZFI->ZFI_COD ))
	Local aCabec		 := {}
	Local aLinha		 := {}
	Local aItens		 := {}
	Local cNumPed		 := ""
	//Local cUpdate		 := ""
	Local aProdPC		 := {}
	Local cProdPC		 := ""
	Local nTotLiq		 := 0
	Local cCCPed		 := ""
	Local cDescri		 := ""
	Local lProd			 := .F.
	Local aProdutos		 := {}
	Local oHash			 := Nil
	Local lCanc			 := .T.
	Local cProjeto		 := "" //Everson - 09/09/2019. Ch. 051527.

	Private lMsErroAuto := .F.

	U_ADINF009P('ADFIN073P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para lan็amento de reembolso.')
	
	//
	If ZFI->ZFI_STATUS <> '1' .Or. ! Empty(Alltrim(cValToChar(ZFI->ZFI_PEDCOM)))
		MsgStop("Nใo ้ possํvel gerar pedido para o registro de reembolso selecionado.","Fun็ใo ADFIN732 (ADFIN073P)")
		RestArea(aArea)
		Return Nil	
	
	EndIf
	
	//
	If ! MsgYesNo("Deseja gerar o pedido de compra para o registro de reembolso " + cFilZFI +"-"+ cCodZFI + "?","Fun็ใo ADFIN732(AFIN073P)")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	DbSelectArea("SA2")
	SA2->(DbSetOrder(1))
	SA2->(DbGoTop())
	If ! SA2->( DbSeek(FWxFilial("SA2") + cFornec + cLoja) )
		MsgStop("Fornecedor nใo localizado. " + Chr(13) + Chr(10) + cFornec + "-" + cLoja + "/" + cNmFor,"Fun็ใo ADFIN732 (ADFIN073P)")
		RestArea(aArea)
		Return Nil

	EndIf
	
	//
	If ! Pergunte("ADFIN731",.T.)
		RestArea(aArea)
		Return Nil
			
	EndIf
	
	//
	Aadd(aCabec,{"C7_EMISSAO"	,Date() })
	Aadd(aCabec,{"C7_FORNECE"	,SA2->A2_COD  })
	Aadd(aCabec,{"C7_LOJA" 		,SA2->A2_LOJA })
	Aadd(aCabec,{"C7_COND"		,Iif(Empty(MV_PAR01),SA2->A2_COND,MV_PAR01) })
	Aadd(aCabec,{"C7_CONTATO"	,SA2->A2_CONTATO })
	Aadd(aCabec,{"C7_FILENT"	,FWxFilial("SC7")})
		
	//
	//Everson - 09/09/2019. Ch. 051527.  
	cQuery := " SELECT ZFI_PROD, ZFI_DSCPRO, ZFI_VALOR, ZFI_CC, ZFI_DESCRI, ZFI_OBS, ZFI_QUANTI, ZFI_PRC, ZFI_PROJET, ZFI_CODPRJ FROM " + RetSqlName("ZFI") + " (NOLOCK) AS ZFI WHERE ZFI_FILIAL = '" + FWxFilial("ZFI") + "' AND ZFI_COD = '" + cCodZFI + "' AND  ZFI.D_E_L_E_T_ = '' ORDER BY ZFI_SEQ "
	
	//
	If Select("D_ZFI") > 0
		D_ZFI->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "D_ZFI"
	DbSelectArea("D_ZFI")
	D_ZFI->(DbGoTop())
	
	//Everson - 16/05/2019. Chamado TI.
	lProd := .F.
	While ! D_ZFI->(Eof())
		
		cProdPC := Posicione("SED",1, FWxFilial("SED") + Alltrim(cValToChar(D_ZFI->ZFI_PROD)), "ED_XPRODRE" )
		
		If Empty(cProdPC)
			lProd := .T.
			
		EndIf
		
		//
		Aadd(aProdutos,{D_ZFI->ZFI_PROD,D_ZFI->ZFI_DSCPRO,cProdPC})
	
		D_ZFI->(DbSkip())
		
	End
	
	//Everson - 16/05/2019. Chamado TI.
	oHash := AToHM(aProdutos,1)
	
	//Everson - 16/05/2019. Chamado TI.
	If lProd
		lCanc := .F.
		prchPrd(@oHash,@lCanc)
		
		//
		If lCanc
			RestArea(aArea)
			Return Nil
			
		EndIf
		
	EndIf
	
	//
	D_ZFI->(DbGoTop())
	While ! D_ZFI->(Eof())
		
		//
		aProdPC := {}
		HMGet(oHash,D_ZFI->ZFI_PROD,aProdPC)
		cProdPC := aProdPC[1][3]
		nTotLiq	:= Val(cValToChar(D_ZFI->ZFI_VALOR))
		cCCPed	:= Alltrim(cValToChar(D_ZFI->ZFI_CC))
		cDescri	:= Alltrim(cValToChar(D_ZFI->ZFI_OBS))
		cProjeto:= Alltrim(cValToChar(D_ZFI->ZFI_PROJET))
		cCodPrj	:= Alltrim(cValToChar(D_ZFI->ZFI_CODPRJ))
		
		//
		aLinha := {}
		Aadd(aLinha,{"C7_PRODUTO" 	,cProdPC            ,Nil})
		Aadd(aLinha,{"C7_QUANT" 	,D_ZFI->ZFI_QUANTI  ,Nil}) //Everson - 16/05/2019. Chamado TI.
		Aadd(aLinha,{"C7_PRECO" 	,D_ZFI->ZFI_PRC     ,Nil}) //Everson - 16/05/2019. Chamado TI.
		Aadd(aLinha,{"C7_TOTAL" 	,nTotLiq            ,Nil})
		Aadd(aLinha,{"C7_CC" 		,cCCPed             ,Nil})

		//
		If ! Empty(cCodPrj)
			Aadd(aLinha,{"C7_CODPROJ" 	,cCodPrj ,Nil}) //Everson - 09/09/2019. Ch. 051527.

		EndIf

		//
		If ! Empty(cProjeto)
			Aadd(aLinha,{"C7_PROJETO" 	,cProjeto ,Nil}) //Everson - 09/09/2019. Ch. 051527.  

		EndIf

		Aadd(aLinha,{"C7_XRESPON" 	,AllTrim(cUserName) ,Nil}) 
		Aadd(aLinha,{"C7_OBS"	    ,cDescri            ,Nil})
		Aadd(aLinha,{"C7_XREEMBO"	,cCodZFI            ,Nil}) //Everson - 16/05/2019. Chamado TI.
		
		Aadd(aItens,aLinha)
		
		D_ZFI->(DbSkip())
		
	End

	//
	SetFunName("MATA120")
	MSExecAuto({|u,v,x,y| MATA120(u,v,x,y)},1,aCabec,aItens,3)

	//
	If !lMsErroAuto

		//
		cNumPed := Alltrim(cValToChar(SC7->C7_NUM))

		//Everson - 08/08/2019. Chamado TI.
		//cUpdate := " UPDATE " + RetSqlName("ZFI") + " SET ZFI_PEDCOM = '" + cNumPed + "', ZFI_STATUS = '2' WHERE ZFI_FILIAL = '" + FWxFilial("ZFI") + "' AND ZFI_COD = '" + Alltrim(cValToChar( ZFI->ZFI_COD )) + "' AND D_E_L_E_T_ = '' "
		//If TcSqlExec(cUpdate) < 0
			//MsgStop("Nใo foi possํvel atualizar o reembolso " + cCodZFI +  " com o n๚mero do pedido de compra " + cNumPed + "." + Chr(13) + Chr(10) + TCSQLError(),"Fun็ใo ADFIN732 (ADFIN073P)")

		//Else
			MsgInfo("Pedido de compra gerado: " + cNumPed + ".","Fun็ใo ADFIN732 (ADFIN073P)")

		//EndIf

	Else
		MostraErro()

	EndIf
	
	//
	HMClean(oHash)
	FreeObj(oHash)
	oHash := Nil

	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ prchPrd  บ Autor ณ Everson - Ch:T.I.                                    บ Data ณ  16/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Preenchimento do c๓digo do produto.                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function prchPrd(oHash,lCanc)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea			:= GetArea()
	Local aLista		:= {}
	Local aPosica		:= {}
	Local nAux			:= 1
	Local nAux2			:= 1
	Local aProdutos		:= {}
	Local oInterface	:= Nil
	Local oReg			:= Nil
	Local nAux3			:= 1
	
	Private aHPv		:= {}
	Private aColsPv		:= {}
	
	//
	HMList(oHash,aLista)
	VarInfo( "LISTA" , aLista)
	
	//
	For nAux := 1 To Len(aLista)
		aPosica := aLista[nAux][2]
		
		For nAux2 := 1 To Len(aPosica)
						
			//
			//If Empty(aPosica[nAux2][3])
				Aadd(aProdutos,{aPosica[nAux2][1],aPosica[nAux2][2],aPosica[nAux2][3]})
			
			//EndIf
		
		Next nAux2
	
	Next nAux
	
	//
	oInterface			 := MsDialog():Create()
	oInterface:cName     := "oInterface"
	oInterface:cCaption  := "Natureza x Produto"
	oInterface:nLeft     := 34
	oInterface:nTop      := 222
	oInterface:nWidth    := 592
	oInterface:nHeight   := 450
	oInterface:lShowHint := .F.
	oInterface:lCentered := .T.
	
	 	TSay():New(005,002,{||"ษ necessแrio selecionar o(s) produto(s) para a(s) natureza(s) abaixo, que nใo possuem produto associado."},oInterface,,,,,,.T.,CLR_RED,CLR_WHITE,300,20)
		
		Aadd(aHPv,{"Natureza"        ,"NATU","" ,TamSX3("ED_CODIGO")[1] , 0,"","" ,"C","",""})
		Aadd(aHPv,{"Descri"          ,"DESC","" ,TamSX3("ED_DESCRIC")[1], 0,"","" ,"C","",""})
		Aadd(aHPv,{"Produto"         ,"PROD","" ,TamSX3("B1_COD")[1]    , 0,"","" ,"C","SB1",""})
		oReg  := MsNewGetDados():New(020,002,180,290,GD_UPDATE,"Allwaystrue()","Allwaystrue()","",{"PROD"},Nil,999,Nil,Nil,Nil,oInterface,aHPv,@aColsPv)
		
		//
		TGroup():Create(oInterface,185,002,205,290,"",,,.T.)
			oCanc:= TButton():New(190,200,"Cancelar" ,oInterface,{||lCanc := .T., oInterface:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			oOk	 := TButton():New(190,245,"Ok"       ,oInterface,{||oInterface:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			
		//
		oReg:aCols := {}
		For nAux3 := 1 To Len(aProdutos)
		
			Aadd(oReg:aCols , Array(Len(aHPv) + 1) )
			oReg:aCols[Len(oReg:aCols), Len(oReg:aCols[1]) ] := .F.
			oReg:aCols[Len(oReg:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "NATU" })] 	:= aProdutos[nAux3][1]
			oReg:aCols[Len(oReg:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "DESC" })]	:= aProdutos[nAux3][2]
			oReg:aCols[Len(oReg:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "PROD" })]	:= Iif( Empty(aProdutos[nAux3][3]),Space(TamSX3("B1_COD")[1]),aProdutos[nAux3][3])
			
		Next nAux3
		
		
	oInterface:Activate(,,,.T.,{||.T.},,{||  })
	
	//
	If ! lCanc
	
		//
		aProdutos := {}
		For nAux3 := 1 To Len(oReg:aCols)
			
			Aadd(aProdutos,{oReg:aCols[nAux3,Ascan(aHPv,{|x| AllTrim(x[2]) == "NATU" })],oReg:aCols[nAux3,Ascan(aHPv,{|x| AllTrim(x[2]) == "DESC" })],oReg:aCols[nAux3,Ascan(aHPv,{|x| AllTrim(x[2]) == "PROD" })]})
			
		Next nAux3
		
		//
		oHash := AToHM(aProdutos,1)
	
	EndIf
	
	//
	aLista := {}
	HMList(oHash,aLista)
	VarInfo( "LISTA2" , aLista)
	
	//
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADFIN734 บ Autor ณ Everson - Ch:T.I.                                    บ Data ณ  07/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Impressใo do lan็amento de reembolso.                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
User Function ADFIN734()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local oReport	:= Nil
	Local oCabec	:= Nil
	Local oFornec	:= Nil
	Local oDescrica	:= Nil
	Local oSection	:= Nil
	Local oRoadP	:= Nil
	Local cCodZFI	:= Alltrim(cValToChar( ZFI->ZFI_COD ))
	Local oCodCell	:= Nil
	Private oBreak	:= Nil

	U_ADINF009P('ADFIN073P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para lan็amento de reembolso.')

	//
	oReport := TReport():New("ADFIN073P","Reembolso " +  Alltrim(cValToChar( ZFI->ZFI_FILIAL )) + "-" + cCodZFI,/*"ADFIN074R"*/,{|oReport| PrintReport(oReport,cCodZFI)},"Este relatorio imprimi a rela็ใo de lan็amentos de reembolso.")
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
	oReport:SetLeftMargin( 1 )
	
	oCabec := TRSection():New(oReport,,,,,,,.F.,,,,.F.,,.F.,,.F.)
	TRCell():New(oCabec,"ZFI_FILIAL" ,,"Filial",,1,,,,,,,, .F. )
	TRCell():New(oCabec,"ZFI_COD"    ,,"C๓digo do reembolso",,,,,,,,,, .F. )
	TRCell():New(oCabec,"ZFI_DATA"   ,,"Data lan็amento",,1,,,,,,,, .F. )
	TRCell():New(oCabec,"ZFI_HORA"   ,,"Hora do lan็amento",,1,,,,,,,, .F. )
	TRCell():New(oCabec,"ZFI_USRINC" ,,"Usuแrio Inclusใo",,1,,,,,,,, .F. )
	
	oDescrica := TRSection():New(oReport,,,,,,,.F.,,,,.F.,,.F.,,.F.)
	TRCell():New(oDescrica,"ZFI_DESCRI" ,,"Descri็ใo",,40,,,,,,,, .F. )
	TRCell():New(oDescrica,"ZFI_STATUS" ,,"Status",,40,,,,,,,, .F. )
	TRCell():New(oDescrica,"ZFI_PEDCOM" ,,"Ped Comp.",,06,,,,,,,, .F. )
	
	oFornec := TRSection():New(oReport,,,,,,,.F.,,,,.F.,,.F.,1,.F.)
	TRCell():New(oFornec,"ZFI_FORNEC" ,,"Fornec",,8,,,,,,,, .F. )
	TRCell():New(oFornec,"ZFI_LOJA"   ,,"Loja",,3,,,,,,,, .F. )
	TRCell():New(oFornec,"ZFI_NMFORN" ,,"Nome",,30,,,,,,,, .F. )
	TRCell():New(oFornec,"ZFI_CC" 	 ,,"C Custo",,7,,,,,,,, .F. )
	TRCell():New(oFornec,"ZFI_DESCC"  ,,"Desc CC",,30,,,,,,,, .F. )
	TRCell():New(oFornec,"ZFI_PERIDE" ,,"Perํodo",,20,,,,,,,, .F. )
	
	oSection  := TRSection():New(oReport,,,,,,,.F.,,,,.F.,,.F.,,.F.)
	TRCell():New(oSection,"ZFI_PROD"  ,,"Natureza",,8,,,,,,,, .F. )
	TRCell():New(oSection,"ZFI_DSCPRO",,"Desc Natureza",,30,,,,,,,, .F. )
	TRCell():New(oSection,"ZFI_VALOR" ,,"Valor" )
	TRCell():New(oSection,"ZFI_QUANTI",,"Qtd." ) //Everson - 10/05/2019. Ch. TI.
	TRCell():New(oSection,"ZFI_OBS"   ,,"Observa็ใo",,30,,,,,,,, .F. )
	oCodCell := TRCell():New(oSection,"ZFI_COD"   ,,"",,1,,,,,,,, .F. )
	oCodCell:Hide( )

	oBreak := TRBreak():New(oSection,oSection:Cell("ZFI_COD"),"S",.F.)

	TRFunction():New(oSection:Cell("ZFI_VALOR"),NIL,"SUM",oBreak,"",/*cPicture*/,/*uFormula*/,.F.,.F.)
	
	oRoadP := TRSection():New(oReport,,,,,,,.F.,,,,.F.,,.F.,1,.F.)
	TRCell():New(oRoadP,"VEMITENTE"   ,,"_________________________",,25,,,,,,,, .F. )
	TRCell():New(oRoadP,"VSUPERVISOR" ,,"_________________________",,25,,,,,,,, .F. )
	TRCell():New(oRoadP,"VCAIXA"      ,,"_________________________",,25,,,,,,,, .F. )
	TRCell():New(oRoadP,"VDIRGEREN"   ,,"_________________________",,25,,,,,,,, .F. )
	
	//
	oReport:PrintDialog()	
	
	//
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportDef บ Autor ณ Everson - Ch:T.I.                                    บ Data ณ  07/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Executa o relat๓rio.                                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function PrintReport(oReport,cCodZFI)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local oCabec	:= oReport:Section(1)
	Local oDescrica	:= oReport:Section(2)
	Local oFornec	:= oReport:Section(3)
	Local oSection	:= oReport:Section(4)
	Local oRoadP	:= oReport:Section(5)
	Local cAliasTop	:= "ZFIREL"
	
	//
	oCabec:Init()
		
		oCabec:Cell("ZFI_FILIAL"):SetValue( Alltrim(cValToChar(ZFI->ZFI_FILIAL)) )
		oCabec:Cell("ZFI_COD"):SetValue( Alltrim(cValToChar(ZFI->ZFI_COD)) )
		oCabec:Cell("ZFI_DATA"):SetValue( Alltrim(cValToChar(ZFI->ZFI_DATA)) )
		oCabec:Cell("ZFI_HORA"):SetValue( Alltrim(cValToChar(ZFI->ZFI_HORA)) )
		oCabec:Cell("ZFI_USRINC"):SetValue( Alltrim(cValToChar(ZFI->ZFI_USRINC)) )
		oCabec:PrintLine()
		
	oCabec:Finish()
	
	//
	oDescrica:Init()
	
		oDescrica:Cell("ZFI_DESCRI"):SetValue( Alltrim(cValToChar(ZFI->ZFI_DESCRI)) )
		oDescrica:Cell("ZFI_STATUS"):SetValue( Iif( ZFI->ZFI_STATUS = "1","Aberto","Pedido de compra gerado") )
		oDescrica:Cell("ZFI_PEDCOM"):SetValue( Alltrim(cValToChar(ZFI->ZFI_PEDCOM)) )
		oDescrica:PrintLine()
		
	oDescrica:Finish()
	
	//
	oFornec:Init()
		
		oFornec:Cell("ZFI_FORNEC"):SetValue( Alltrim(cValToChar(ZFI->ZFI_FORNEC)) )
		oFornec:Cell("ZFI_LOJA"):SetValue( Alltrim(cValToChar(ZFI->ZFI_LOJA)) )
		oFornec:Cell("ZFI_NMFORN"):SetValue( Alltrim(cValToChar(ZFI->ZFI_NMFORN)) )
		oFornec:Cell("ZFI_CC"):SetValue( Alltrim(cValToChar(ZFI->ZFI_CC)) )
		oFornec:Cell("ZFI_DESCC"):SetValue( Alltrim(cValToChar(ZFI->ZFI_DESCC)) )
		oFornec:Cell("ZFI_PERIDE"):SetValue( Alltrim(cValToChar(ZFI->ZFI_PERIDE)) +'-' + Alltrim(cValToChar(ZFI->ZFI_PERIAT)) )
		
		oFornec:PrintLine()
		oReport:SkipLine(2)  
		
	oFornec:Finish()

	//
	oSection:Init() 

	//
	BeginSql Alias cAliasTop

		SELECT 
		ZFI_FILIAL, ZFI_COD, ZFI_DATA, ZFI_HORA, ZFI_PERIDE, 
		ZFI_PERIAT, ZFI_FORNEC, ZFI_LOJA, ZFI_NMFORN, 
		ZFI_CC, ZFI_DESCC, ZFI_SEQ, ZFI_PROD, ZFI_DSCPRO, ZFI_VALOR, ZFI_QUANTI, ZFI_OBS //Everson - 10/05/2019. Ch. TI.
		FROM 
		%table:ZFI% ZFI
		WHERE
		ZFI_FILIAL = %EXP:FWxFilial("ZFI")%
		AND ZFI.ZFI_COD = %exp:cCodZFI%
		AND ZFI.%notDel%
		ORDER BY ZFI_FILIAL, ZFI_CC, ZFI_DESCC, ZFI_SEQ

	EndSql

	oReport:SetMeter(RecCount())
	
	//
	While !(cAliasTop)->(Eof())
		
		oSection:Cell("ZFI_COD"):SetValue( (cAliasTop)->ZFI_COD )
		oSection:Cell("ZFI_PROD"):SetValue( (cAliasTop)->ZFI_PROD )
		oSection:Cell("ZFI_DSCPRO"):SetValue( (cAliasTop)->ZFI_DSCPRO )
		oSection:Cell("ZFI_VALOR"):SetValue( (cAliasTop)->ZFI_VALOR )
		oSection:Cell("ZFI_QUANTI"):SetValue( (cAliasTop)->ZFI_QUANTI ) //Everson - 10/05/2019. Ch. TI.
		oSection:Cell("ZFI_OBS"):SetValue( (cAliasTop)->ZFI_OBS )
	
		oSection:PrintLine()  
		oBreak:SetTitle('Total')	
		oReport:IncMeter()
	
		(cAliasTop)->(DbSkip())
			
	End
	
	//
	oSection:Finish()
	
	//
	oRoadP:Init()
	
		oReport:SkipLine(10) 
	
		oRoadP:Cell("VEMITENTE"):SetValue( "Visto Emitente" )
		oRoadP:Cell("VSUPERVISOR"):SetValue( "Visto Supervisor" )
		oRoadP:Cell("VCAIXA"):SetValue( "Visto Caixa" )
		oRoadP:Cell("VDIRGEREN"):SetValue( "Visto Diretoria/Ger๊ncia" )

		oRoadP:PrintLine()
		
	oRoadP:Finish()

	(cAliasTop)->(DbCloseArea())

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ModelDef บ Autor ณ Everson - Ch:T.I.                                    บ Data ณ  01/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Modelo de dados.                                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
STATIC Function ModelDef()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea			:= GetArea()
	Local oStruZFI		:= FWFormStruct( 1, "ZFI",{|cCabCampos| AllTrim(cCabCampos)  $ "ZFI_FILIAL|ZFI_COD|ZFI_DATA|ZFI_HORA|ZFI_FORNEC|ZFI_LOJA|ZFI_NMFORN|ZFI_CC|ZFI_DESCC|ZFI_PERIDE|ZFI_PERIAT|ZFI_STATUS|ZFI_PEDCOM|ZFI_DESCRI|ZFI_USRINC|ZFI_CODUSR"} /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStru2ZFI 	:= getStrMdl()
	Local oModel		:= Nil
	Local bPosVld		:= {|oModel| ADFIN733(oModel)}

	//
	oModel := MPFormModel():New("ModelDef_MVC", /*bPreVld*/ , bPosVld, /*bCommit*/ , /*bCancel*/ )

	oModel:AddFields('ZFIMASTER', /*cOwner*/, oStruZFI )
	oModel:SetPrimaryKey( { 'ZFI_FILIAL','ZFI_COD'} )


	oModel:AddGrid("ZFIDETAIL", "ZFIMASTER", oStru2ZFI, , , , , )
	oModel:GetModel("ZFIDETAIL"):SetUniqueLine( {'ZFI_SEQ','ZFI_PROD' } )
	oModel:SetRelation("ZFIDETAIL", { { "ZFI_FILIAL",'FWxFilial("ZFI")' },{"ZFI_COD","ZFI_COD"} }, ZFI->( IndexKey( 1 ) ) )
	oModel:GetModel("ZFIDETAIL"):SetOptional( .T. )
	oModel:GetModel("ZFIMASTER"):SetDescription(cCadastro)
	oModel:GetModel("ZFIDETAIL"):SetDescription("Itens do " + cCadastro)

	//
	RestArea(aArea)

Return oModel
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADFIN733 บ Autor ณ Everson - Ch:T.I.                                    บ Data ณ  03/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Valida็ใo da opera็ใo.                                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function ADFIN733(oModel)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		 	:= GetArea()	
	Local lRet		 	:= .T.
	Local oGrid		 	:= oModel:GetModel("ZFIDETAIL")
	Local nAux		 	:= 0
	Local nTotRem		:= 0
	Local nOperation	:= oModel:GetOperation()
	Local oStru2ZFI		:= FWFormStruct( 1, "ZFI",{|cCabCampos| !AllTrim(cCabCampos)  $ "ZFI_FILIAL|ZFI_COD|ZFI_DATA|ZFI_HORA|ZFI_FORNEC|ZFI_LOJA|ZFI_NMFORN|ZFI_CC|ZFI_DESCC|ZFI_PERIDE|ZFI_PERIAT|ZFI_STATUS|ZFI_PEDCOM|ZFI_DESCRI|ZFI_USRINC|ZFI_CODUSR"} /*bAvalCampo*/, /*lViewUsado*/ )
	Local aPosFields 	:= oStru2ZFI:GetArrayPos({"ZFI_VALOR"})
	
	//
	oModel:GetModel("ZFIDETAIL"):SetNoDeleteLine(.F.)
	
	//
	If lRet .And. ( nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_DELETE )
		If oModel:GetValue( 'ZFIMASTER' , 'ZFI_STATUS' ) <> '1' 
			lRet := .F.
			If nOperation == MODEL_OPERATION_UPDATE
				Help(Nil, Nil, "Registro nใo pode ser alterado.", Nil, 'Somente registro aberto pode ser alterado.', 1, 0, Nil, Nil, Nil, Nil, Nil, {''}) 

			Else
				Help(Nil, Nil, "Registro nใo pode ser excluํdo.", Nil, 'Somente registro aberto pode ser excluํdo.', 1, 0, Nil, Nil, Nil, Nil, Nil, {''})

			EndIf

		EndIf

	EndIf
	
	//Everson - 13/05/2019. Ch. TI.
	If lRet .And. ( nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_DELETE )
		If oModel:GetValue( 'ZFIMASTER' , 'ZFI_CODUSR' ) <> __cUserId
			lRet := .F.
			If nOperation == MODEL_OPERATION_UPDATE
				Help(Nil, Nil, "Registro nใo pode ser alterado.", Nil, 'Somente o usuแrio que incluiu o registro pode alterแ-lo.', 1, 0, Nil, Nil, Nil, Nil, Nil, {''}) 

			Else
				Help(Nil, Nil, "Registro nใo pode ser excluํdo.", Nil, 'Somente o usuแrio que incluiu o registro pode excluํ-lo.', 1, 0, Nil, Nil, Nil, Nil, Nil, {''})

			EndIf

		EndIf

	EndIf
	
	//
	If lRet .And.  nOperation <> MODEL_OPERATION_DELETE
	
		For nAux := 1 To oGrid:Length(.F.)
		
			If Val(cValToChar( oModel:GetModel("ZFIDETAIL"):GetValueByPos(aPosFields[1], nAux) )) > 0
				nTotRem += Val(cValToChar( oModel:GetModel("ZFIDETAIL"):GetValueByPos(aPosFields[1], nAux) ))
				
			EndIf
		
		Next nAuxf
		
		//
		If nTotRem <= 0
			
			lRet := .F.
			Help(Nil, Nil, "Valor invแlido.", Nil, 'Nใo foram atribuํdos os valores de reembolso.', 1, 0, Nil, Nil, Nil, Nil, Nil, {''}) 
			
		Else
		
			For nAux := 1 To oGrid:Length(.F.)
			
				If Val(cValToChar( oModel:GetModel("ZFIDETAIL"):GetValueByPos(aPosFields[1], nAux) )) <= 0
					oModel:GetModel("ZFIDETAIL"):GoLine(nAux)
					oModel:GetModel("ZFIDETAIL"):DeleteLine()
					
				EndIf
			
			Next nAuxf
	
		EndIf
	
	EndIf
	
	//
	If lRet .And. (nOperation = 3 .Or. nOperation = 4)
		oModel:SetValue("ZFIMASTER","ZFI_USRINC",cUserName)
		oModel:SetValue("ZFIMASTER","ZFI_DATA",Date())
		oModel:SetValue("ZFIMASTER","ZFI_HORA",Time())
	
	EndIf
	
	//Everson - 13/05/2019. Ch. TI.
	If lRet .And. nOperation = 3
		oModel:SetValue("ZFIMASTER","ZFI_CODUSR",__cUserId)
	
	EndIf

	//
	RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ViewDef  บ Autor ณ Everson - Ch:T.I.                                    บ Data ณ  01/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ View.                                                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function ViewDef()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local oView		:= Nil
	Local oModelVd	:= FWLoadModel("ADFIN073P")
	Local oStruZFI	:= FWFormStruct( 2, "ZFI" ,{|cCabCampos| AllTrim(cCabCampos)  $ "ZFI_FILIAL|ZFI_COD|ZFI_DATA|ZFI_HORA|ZFI_FORNEC|ZFI_LOJA|ZFI_NMFORN|ZFI_CC|ZFI_DESCC|ZFI_PERIDE|ZFI_PERIAT|ZFI_STATUS|ZFI_PEDCOM|ZFI_DESCRI|ZFI_USRINC|ZFI_CODUSR"} )
	Local oStru2ZFI	:= getStrMdl(2)
	
	//
	oView := FWFormView():New()

	oView:SetModel( oModelVd )
	oView:AddField( "VIEW_ZFI", oStruZFI , "ZFIMASTER" )
	oView:AddGrid( "VIEW_ZFID", oStru2ZFI, "ZFIDETAIL" )
	oView:CreateHorizontalBox("SUPERIOR", 40 )
	oView:CreateHorizontalBox("INFERIOR", 60 )
	oView:SetOwnerView("VIEW_ZFI" , "SUPERIOR" )
	oView:SetOwnerView("VIEW_ZFID", "INFERIOR" )
	oView:AddIncrementField("VIEW_ZFID", "ZFI_SEQ")
	oView:SetCloseOnOk( { || .T. } )

	oView:SetAfterViewActivate({|oView| crgItens(oView) })
	oStruZFI:RemoveField( "ZFI_USRINC" )
	oStruZFI:RemoveField( "ZFI_CODUSR" )

	//
	RestArea(aArea)

Return oView
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ViewDef  บ Autor ณ Everson - Ch:T.I.                                    บ Data ณ  01/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ View.                                                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function crgItens(oView)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local oGrid		:= oView:GetModel("ZFIDETAIL")
	Local oStru2ZFI	:= getStrMdl()
	Local nAux		:= 0

	//
	If oView:GetOperation() == 3

		//
		aPosFields  := oStru2ZFI:GetArrayPos({"ZFI_PROD","ZFI_DSCPRO"})

		//
		cadNatuF()
		DbSelectArea("D_NATU")
		While ! D_NATU->(Eof())

			//
			nAux++

			//
			If nAux > 1
				oGrid:AddLine(.T.) 

			EndIf

			//
			oGrid:LdValueByPos(aPosFields[1], Alltrim(cValToChar(D_NATU->ED_CODIGO)) )
			oGrid:LdValueByPos(aPosFields[2], Alltrim(cValToChar(D_NATU->ED_DESCRIC)) )

			D_NATU->(DbSkip())

		End

		//
		oGrid:GoLine(1)

	EndIf

	//
	oGrid:SetNoInsertLine(.T.)
	oGrid:SetNoDeleteLine(.T.)
	oView:Refresh()

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ cadNatuF บ Autor ณ Everson - Ch:T.I.                                    บ Data ณ  01/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Itens do cadastro de natureza financeira.                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function cadNatuF()

	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	
	//
	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " ED_CODIGO, ED_DESCRIC " 
	cQuery += " FROM " + RetSqlName("SED") + " (NOLOCK) AS SED " 
	cQuery += " WHERE " 
	cQuery += " ED_FILIAL = '" + FWxFilial("SED") + "' " 
	cQuery += " AND ED_XREEMBO = '2' " //Everson - 08/05/2019. Chamado TI.
	cQuery += " AND SED.D_E_L_E_T_ = '' ORDER BY ED_CODIGO " 

	//
	If Select("D_NATU") > 0
		D_NATU->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_NATU"
	DbSelectArea("D_NATU")
	D_NATU->(DbGoTop())

	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ getStrMdlบ Autor ณ Everson - Ch:T.I.                                    บ Data ณ  03/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Retorna modelo de dados dos itens.                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function getStrMdl(nTipo)

	Default nTipo := 1
	
Return FWFormStruct( nTipo, "ZFI",{|cCabCampos| !AllTrim(cCabCampos) $ "ZFI_FILIAL|ZFI_COD|ZFI_DATA|ZFI_HORA|ZFI_FORNEC|ZFI_LOJA|ZFI_NMFORN|ZFI_CC|ZFI_DESCC|ZFI_PERIDE|ZFI_PERIAT|ZFI_STATUS|ZFI_PEDCOM|ZFI_DESCRI|ZFI_USRINC|ZFI_CODUSR"} /*bAvalCampo*/, /*lViewUsado*/ )
