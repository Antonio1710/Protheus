#INCLUDE "rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "ParmType.ch"
/*/{Protheus.doc} User Function nomeFunction
	Validação na classifica de uma pre-nota.
	@type  Function
	@author Microsiga
	@since 11/21/2013
	@version 01
	@history Chamado:047834 Fernando sigoli 13/03/2019 - Tratamento para nao validar notas do TIpo CTE, pois integra classificada.
	@history Chamado: T.I.  Everson 17/07/2020 - Substituída função TcLink por LinkedServer.
	/*/
User Function MT103INC()

	Local Area 			:= GetArea() 
	Local _cChave 		:= SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
	Local cMens	  		:= ""
	Local lRet	  		:= .T.   
	Local cUsr	   	    := RetCodUsr()
	Local cUsrMaster	:= GetMV('MV_X_USSEG',,"000000")   // usuário master

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³TRATAMENTO INTEGRAÇÃO EDATA - INICIO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Alltrim(cEmpAnt) == "01"  

		If SF1->F1_TIPO=="D" .AND. SF1->F1_XFLAGE == "1"
			
			
			If IsInCallStack('U_CENTNFEXM')  == .T. //fernando sigoli 02/03/2017
				
				If !Empty(SF1->F1_X_SQED)    
				
					MsgAlert("MT103INC","Leitura pendente no edata!",{"OK"},3)
					lRet:=.F.  
				
				EndIF
					
			Else
				
				MsgAlert("MT103INC","Leitura pendente no edata!",{"OK"},3)
				lRet:=.F.  
				
			EndIF
			
		
		ElseIf SF1->F1_TIPO=="D" .AND. SF1->F1_XFLAGE == "3"
		
			If !(cUsr $ cUsrMaster)
				MsgAlert("MT103INC","Leitura rejeitada pelo edata. Nota não poderá ser classificada!",{"OK"},3)
				lRet:=.F.	
			Else
				If !ApMsgYesNo("Leitura rejeitada pelo edata por divergência física!" + CRLF + "Deseja continuar?")
					lRet:=.F.	
				EndIf
			EndIf
		Endif		

		// tratamento formulário proprio
		/*If SF1->F1_FORMUL=="S" .AND. SF1->F1_TIPO=="D" .AND. lRet

			If !NfeNextDoc()
				lRet	:= .F.
			EndIf
		Endif*/	

	//Endif          //Transferido apos if SAG por Adriana em 28/08/2017

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³TRATAMENTO INTEGRAÇÃO SAG - INICIO  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SF1->F1_CODIGEN > 0 .And. SF1->F1_FORMUL <> "S" //Everson - 09/11/2018.
			lRet	:= ValidaSAG()	
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³TRATAMENTO INTEGRAÇÃO SAG - FIM     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	EndIf

	RestArea(Area) 

Return lRet
/*/{Protheus.doc} NfeNextDoc
	Numera nota de devolução formulário proprio.
	@type  Static Function
	@author Microsiga 
	@since 02/11/2014
	@version 01
	/*/
/*
Static Function NfeNextDoc()

	Local aArea	   := GetArea()
	Local aAreaSF1 := SF1->(GetArea())
	Local lRetorno := .T.
	Local nItensNf := 0
	Local cTipoNf  := SuperGetMv("MV_TPNRNFS")
	Local cNum103  := ""  
	Local cMT103SRI:= ""

	If SF1->F1_FORMUL == "S"
		Private cNumero:= ""
		Private cSerie1:= ""
		lRetorno:= Sx5NumNota(@cSerie1,cTipoNf)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Validacao da NF informada pelo usuario                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRetorno .And. cTipoNF <> "3"
			SF1->(dbSetOrder(1))
			If SF1->(MsSeek(xFilial("SF1")+PADR(cNumero,TamSx3("F1_DOC")[1])+cSerie1+cA100For+cLoja,.F.))
				Help(" ",1,"EXISTNF")
				lRetorno := .F.
				cNumero := ""
				cSerie1 := ""
			EndIf
		EndIf
		If lRetorno
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o numero de maximo de itens da serie.               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aEval(aCols,{|x| nItensNf += IIF(x[Len(x)],0,1)})
			If nItensNf > 0 	.And. nItensNf > a460NumIt(cSerie1,.T.)
				Help(" ",1,"A100NITENS")
				lRetorno := .F.
			Else
				If cTipoNf <> "3"
					// Se numeracao for SXE/SXF e usuario alterou numero, respeita numero do usuarop
					If cTipoNf <> "2" .OR. !lMudouNum
						cNumero := NxtSX5Nota(cSerie1, NIL, cTipoNf)
					EndIf	
				Else 
					If !lMudouNum	// Verifica se usuario alterou numero da nota fiscal
						cNumero := Space(TamSx3("F1_DOC")[1])
					EndIf	
				EndIf
			EndIf
		EndIf

		If lRetorno
			cNFiscal	:= cNumero
			cSerie	    := cSerie1
		EndIf
	EndIf

	RestArea(aAreaSF1)
	RestArea(aArea)
Return(lRetorno)*/
/*/{Protheus.doc} ValidaSAG
	Adoro - SAGII
	@type  Static Function
	@author Microsiga
	@since 08/25/2016
	@version 01
	/*/
Static Function ValidaSAG()//cProd,cTM,nQuant,cLocal,nRec)

	Local aArea	    := GetArea()
	Local aAreaSF1  := SF1->(GetArea())
	Local cAliasNFE := CriaTrab(NIL,.F.)	
	Local cChv1SF1	:= SF1->F1_FILIAL
	Local cChv2SF1	:= SF1->F1_DOC
	Local cChv3SF1	:= SF1->F1_SERIE
	Local cChv4SF1	:= SF1->F1_FORNECE
	Local cChv5SF1	:= SF1->F1_LOJA
	Local cChv6SF1	:= SF1->F1_CODIGEN
	Local cQuery  	:= ""
	// Local _nTcConn1 := advConnection()
	// Local _cNomBco2 := GetPvProfString("INTSAGBD","BCO2","ERROR",GetADV97())
	// Local _cSrvBco2 := GetPvProfString("INTSAGBD","SRV2","ERROR",GetADV97())
	// Local _cPortBco2:= Val(GetPvProfString("INTSAGBD","PRT2","ERROR",GetADV97()))
	// Local _nTcConn2 := 0
	Local lRet		:=.T.

		//Inicio: fernando Sigoli  17/04/2018
		If IsInCallStack('U_INTNFEB') == .T.
		
			If nRadio == 11
				lRet := .T.
				Return lRet
			EndIf
			
		EndIf
		//Fim: fernando Sigoli  17/04/2018
		
		// If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2)) < 0
		// 	_lRet     := .F.
		// 	cMsgError := "Não foi possível  conectar ao banco integração"
		// 	MsgInfo("Não foi possível  conectar ao banco integração, verifique com administrador","ERROR")		
		// 	Return lRet
		// EndIf
		
		//TcSetConn(_nTcConn2)
		
		/*
			PRIMEIRA VALIDAÇÃO
		*/
		/* Query principal para buscar as notas na tabela intermediaria SGNFE010 se estão pendentes de pesagem */
		cQuery := " SELECT COUNT(*) AS QTDE "
		cQuery += " FROM SGNFE010 "	
		cQuery += " WHERE F1_FILIAL = '" +cChv1SF1+ "' "
		cQuery += 	"	AND F1_DOC = '" +ALLTRIM(cChv2SF1)+ "' "
	//	cQuery += 	"	AND F1_SERIE = '" +ALLTRIM(cChv3SF1)+ "' "
		cQuery += 	"	AND F1_FORNECE = '" +ALLTRIM(cChv4SF1)+ "' "
		cQuery += 	"	AND F1_LOJA = '" +ALLTRIM(cChv5SF1)+ "' "
		cQuery += 	"	AND OPERACAO_INT='B' "
		//cQuery += 	"	AND F1_LOJA = '" +ALLTRIM(cChv5SF1)+ "' " // fernando sigoli 18/01/2018 (duplicidade)
		cQuery += 	"	AND CODIGENE = '" +ALLTRIM(STR(cChv6SF1))+ "' "  
		cQuery += 	"   AND F1_ESPECIE <> 'CTE' " //Chamado:047834 Fernando sigoli 13/03/2019  adicionado essa regra para nao olhar pesagens de notas de CTE 
		//cQuery += 	"   AND TABEGENE <> 'POCAMVNE' "              //adicionado essa regra para nao olhar pesagens de notas de CTE    
		
		cQuery := ChangeQuery(cQuery)		
		
		If Select(cAliasNFE) <> 0
			(cAliasNFE)->(DbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNFE,.T.,.F.)
		
		If (cAliasNFE)->QTDE >0
			lRet:=.F.  
			MsgAlert("MT103INC","Nota pendente de Pesagem no SAG! Não poderá ser classificada!",{"OK"},3)
		EndIf
		
		
		/*
		SEGUNDA VALIDAÇÃO
		*/
		
		/* Query principal para verificar se houve alteração da nota na tabela intermediária NFE antes de permitir a classificação */
		cQuery := " SELECT D1_MSEXP "
		cQuery += " FROM SGNFE010 "	
		cQuery += " WHERE F1_FILIAL = '" +cChv1SF1+ "' "
	//	cQuery += 	"	AND F1_DOC = '" +ALLTRIM(cChv2SF1)+ "' "
	//	cQuery += 	"	AND F1_SERIE = '" +ALLTRIM(cChv3SF1)+ "' "
	//	cQuery += 	"	AND F1_FORNECE = '" +ALLTRIM(cChv4SF1)+ "' "
	//	cQuery += 	"	AND F1_LOJA = '" +ALLTRIM(cChv5SF1)+ "' "
		cQuery += 	"	AND CODIGENE = '" +ALLTRIM(STR(cChv6SF1))+ "' "
		cQuery += 	"   AND F1_ESPECIE <> 'CTE' "  // Chamado:047834 Fernando sigoli 13/03/2019 adicionado essa regra para nao cte, devido o mesmo entrar classifica  e o campo.
		//cQuery += 	"   AND TABEGENE <> 'POCAMVNE' "    //adicionado essa regra para nao cte, devido o mesmo entrar classifica  e o campo.
			
		cQuery := ChangeQuery(cQuery)		
		
		If Select(cAliasNFE) <> 0
			(cAliasNFE)->(DbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNFE,.T.,.F.)
				
		If Empty( ALLTRIM( (cAliasNFE)->D1_MSEXP ) )
		
			MsgAlert("MT103INC","A nota sofreu alterações no SAG e precisa ser processada novamente para o Protheus! Não poderá ser classificada!",{"OK"},3)
			
			//TcSetConn(_nTcConn1)

			RestArea(aAreaSF1)
			RestArea(aArea)
			
			Return .F.
			
		Else
		
			While !(cAliasNFE)->(Eof())
				If Empty( ALLTRIM( (cAliasNFE)->D1_MSEXP ) )
					MsgAlert("MT103INC","A nota sofreu alterações no SAG e precisa ser processada novamente para o Protheus! Não poderá ser classificada!",{"OK"},3)
					
					//TcSetConn(_nTcConn1)
			
					RestArea(aAreaSF1)
					RestArea(aArea)
					
					Return .F.
				EndIf
				
				(cAliasNFE)->(DbSkip())
			EndDo
			
		EndIf
		
		// TcSetConn(_nTcConn1)
		
		RestArea(aAreaSF1)
		RestArea(aArea)

Return lRet
