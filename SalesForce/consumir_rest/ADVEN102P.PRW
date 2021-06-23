#Include "Totvs.ch"
#Include "Restful.ch"
#Include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADVEN102P     บAutor  ณEverson         บ Data ณ  20/03/2019 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPopula os indicadores comerciais do Salesforce.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado TI.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAltera็๕esณEverson - 29/03/2019.Chamado TI. Envio dos registros por    บฑฑ
ฑฑบ          ณLote.                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAltera็๕esณEverson - 09/04/2019.Chamado TI. Adicionada consulta sql.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAltera็๕esณEverson - 12/04/2019.Chamado TI. Corrigido m้todo de envio  บฑฑ
ฑฑบ          ณde registros.                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADVEN102P(cObjeto,cCmpProth,aChaves,cQuery)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea		:= GetArea()
	Local lLogin	:= .F.
	Local cMsg		:= ""
	Local aResponse	:= {}
	Local nTotReg	:= 0
	Local nAux		:= 0
	Local i			:= 1
	
	Local cDados	:= ""
	Local aLote		:= {}
	Local aJGet		:= {}
	Local cJGet		:= ""
	Local aResGet	:= {}
	Local nLoc		:= 0
	Local cMSelect	:= "" //Everson - 12/04/2019.Chamado TI
	
	Private aChvP	:= {}
	Private nLimitE	:= 25
	
	Default cObjeto		:= ""
	Default cCmpProth	:= ""
	Default aChaves		:= {}
	Default cQuery		:= ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Popula os indicadores comerciais do Salesforce.')
	
	//Everson - 09/04/2019.
	If Empty(cObjeto)
		Conout( DToC(Date()) + " " + Time() + " ADVEN102P [ERRO] variแvel cObjeto vazia." )
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	If Empty(cCmpProth)
		Conout( DToC(Date()) + " " + Time() + " ADVEN102P [ERRO] variแvel cCmpProth vazia." )
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	If Len(aChaves) <= 0
		Conout( DToC(Date()) + " " + Time() + " ADVEN102P [ERRO] variแvel aChaves vazia." )
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	If Empty(cQuery)
		Conout( DToC(Date()) + " " + Time() + " ADVEN102P [ERRO] variแvel cQuery vazia." )
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//Efetura login no SalesForce.
	lLogin := StaticCall(ADVEN075P,loginSF,@aResponse,@cMsg,.F.)
	
	//
	If ! lLogin
		Conout( DToC(Date()) + " " + Time() + " ADVEN102P - Falha de login."  )
		RestArea(aArea)
		Return Nil

	EndIf
	
	//
	If Select("D_DADOS") > 0
		D_DADOS->(DbCloseArea())
		
	EndIf
	
	//
	aChvP := aChaves
	
	//
	TcQuery cQuery New Alias "D_DADOS"
	DbSelectArea("D_DADOS")
	D_DADOS->(DbGoTop())
	nTotReg := Contar("D_DADOS","!Eof()")
	D_DADOS->(DbGoTop())
	
	//
	While ! D_DADOS->(Eof())
		
		//mntJson(cMetodo,cObjeto,cChvExt,cParamBsc,cJsonObj)
		cJGet := mntJson("GET",cObjeto,cCmpProth,D_DADOS->CHV)
		Aadd(aJGet, {cJGet, D_DADOS->CHV} )
		
		D_DADOS->(DbSkip())
	
	End
	
	//Everson - 12/04/2019. Chamado TI.
	If Len(aJGet) > 0
		aResGet := chkRetGet(aJGet,aResponse)

	Else
		Conout( DToC(Date()) + " " + Time() + " ADVEN102P - Nใo hแ retorno para a consulta de status." )
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//	
	D_DADOS->(DbGoTop())
    While ! D_DADOS->(Eof())
	
		//
		nAux++
		
		//
		For i := 1 To Len(aChvP)
		
			//
			If Empty(Alltrim(cValToChar(aChvP[i][1]))) .Or. Empty(Alltrim(cValToChar(aChvP[i][2])))
				Conout( DToC(Date()) + " " + Time() + " ADVEN102P [ERRO] - verifique a posi็ใo " + cValToChar(i) + " da variแvel aChaves " )
				Loop
				
			EndIf
		
			cDados += '"' + Alltrim(cValToChar(aChvP[i][2])) + '": ' + '"' + Alltrim(cValToChar(D_DADOS->&(Alltrim(cValToChar(aChvP[i][1])))))  + '",'
		
		Next i
		
		//
		Conout( DToC(Date()) + " " + Time() + " ADVEN102P - ADVEN102P - " + cValToChar(cDados) )
		If ! Empty(cDados)
		
			//
			cDados := Substr(cDados,1,Len(cDados)-1)
			
			//Everson - 12/04/2019.Chamado TI
			nLoc := Ascan(aResGet,D_DADOS->CHV)
			
			cMSelect := Iif( nLoc > 0,"PATCH",Nil)
			
			Conout( DToC(Date()) + " " + Time() + " ADVEN102P - cMSelect " + cValToChar(cMSelect) )
			//
			
			//
			envLote(cDados,cObjeto,cCmpProth,D_DADOS->CHV,@aLote,nAux = nTotReg,@aResponse, cMSelect )
		
		EndIf

		cDados := ""
		
		D_DADOS->(DbSkip())
	
	End
	
	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณchkRetGet บAutor  ณEverson             บ Data ณ  12/04/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta as requisi็๕es de consulta.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado TI.                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function chkRetGet(aJGet,aResponse)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea			:= GetArea()
	Local nI			:= 1
	Local nX			:= 1
	Local nAux			:= 0
	Local cJson			:= ""
	Local aResult		:= {}
	Local oParseJSON	:= Nil
	
	//
	For nI := 1 To Len(aJGet)
		
		nAux++
		cJson += aJGet[nI][1] + ","
		
		//
		If nAux == nLimitE .Or. nI == Len(aJGet) .Or. nAux == Len(aJGet)
			
			cJson := Substr(cJson,1,Len(cJson)-1)
			cJson := '{"batchRequests":[ ' + cJson + ']}'
			
			oParseJSON := envReq(cJson,aResponse)
			
			//
			If ValType(oParseJSON) == "O"
				
				//
				For nX := 1 To Len(oParseJSON:RESULTS)
				
					If Alltrim(cValToChar(oParseJSON:RESULTS[nX]:STATUSCODE)) == "200"
						Aadd(aResult,cValToChar(oParseJSON:RESULTS[nX]:RESULT:CHAVE_PROTHEUS__C))
						
						Conout( DToC(Date()) + " " + Time() + " ADVEN102P - chkRetGet - oParseJSON " + cValToChar(oParseJSON:RESULTS[nX]:RESULT:CHAVE_PROTHEUS__C)  )
						
					EndIf
				
				Next nX
			
			EndIf
			
			//
			cJson      := ""
			nAux       := 0
			oParseJSON := Nil
			
		EndIf
	
	Next nI
	
	//
	RestArea(aArea)
	
Return aResult
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณenvLote   บAutor  ณEverson             บ Data ณ  29/03/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo envia registros em lote.                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado TI.                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function envLote(cJson,cObjeto,cChvExt,cParamBsc,aLote,lEnvLote,aResponse,cMetodo)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local cMsg		:= ""
	Local lLogin	:= .F.
	Local cServTab	:= "/services/data/v41.0/sobjects/" + cObjeto + "/"
	Local cErros	:= ""
	Local nAuxE		:= 1
	Local cJsonE	:= "" 
	Local nCount	:= 0
	
	Default cMetodo	:= ""

	//
	If Len(aResponse) <= 0

		//Efetura login no SalesForce.
		lLogin := StaticCall(ADVEN075P,loginSF,@aResponse,@cMsg,.F.)
		
		//
		If ! lLogin
			Conout( DToC(Date()) + " " + Time() + " ADVEN102P - Falha de login."  )
			RestArea(aArea)
			Return Nil
	
		EndIf
	
	EndIf
	
	//
	If Empty(cMetodo)
		If ! consulEst(cServTab,cChvExt,cParamBsc,aResponse,@cMetodo,@cErros)
			Conout( DToC(Date()) + " " + Time() + " ADVEN102P - consulEst (ERRO) - " + cErros )
			RestArea(aArea)
			Return Nil
		
		Else
			Aadd(aLote, mntJson(cMetodo,cObjeto,cChvExt,cParamBsc,cJson) ) //
				
		EndIf
	
	Else
		Aadd(aLote, mntJson(cMetodo,cObjeto,cChvExt,cParamBsc,cJson) ) //Everson - 12/04/2019.Chamado TI.
	
	EndIf
	
	//
	If lEnvLote
		
		For nAuxE := 1 To Len(aLote)
			
			nCount++
			cJsonE += aLote[nAuxE] + ","
			
			If (nCount = nLimitE .Or. nCount = Len(aLote)) .Or. ( nAuxE == Len(aLote) )
			 	nCount = Len(aLote) .Or. nCount = nLimitE
				cJsonE := Substr(cJsonE,1,Len(cJsonE)-1)
				cJsonE := '{"batchRequests":[' + cJsonE + ']}'
				Conout( DToC(Date()) + " " + Time() + " ADVEN102P - envLote - tamanho - cJsonE - " + cValToChar(nCount) + " " + cJsonE   )			
				envReq(cJsonE,aResponse)
				cJsonE := ""
				nCount := 0
				
			EndIf
		
		Next nAuxE	
	
	EndIf
	
	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณconsulEst บAutor  ณEverson             บ Data ณ  22/03/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsulta status.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado TI.                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function consulEst(cServTab,cChvExt,cParamBsc,aResponse,cMetodo)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea	:= GetArea()
	Local lRet	:= .T.
	Local cMsg	:= ""
	
	Conout( DToC(Date()) + " " + Time() + " ADVEN102P - chamada " + cServTab + cChvExt + "/" + cParamBsc )
	
	//
	If ! U_ADVEN075P(cServTab + cChvExt + "/" + cParamBsc,"GET","",@cMsg,aResponse)

		//
		cMsg :=  Alltrim(cValToChar(cMsg))
		If "NOT_FOUND" $cMsg .Or. "404 NotFound" $cMsg  //Registro nใo encontrado no SalesForce.
			cMetodo := "POST"

		Else
			Conout( DToC(Date()) + " " + Time() + " ADVEN102P - consulEst (ERRO)" + cMsg )	
			lRet := .F.

		EndIf

	Else
		cMetodo := "PATCH"

	EndIf
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADVEN102P - consulEst - metodo " + cMetodo )	
	Conout( DToC(Date()) + " " + Time() + " ADVEN102P - consulEst - cMsg " + cMsg )
	
	//
	RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณenvReq    บAutor  ณEverson             บ Data ณ  22/03/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEnvia requisi็ใo.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado TI.                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function envReq(cJsonObj,aResponse)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea			:= GetArea()
	Local cJson			:= cJsonObj
	Local cUrl  		:= "/services/data/v41.0/composite/batch/"
	Local cMsg			:= ""
	Local oParseJSON	:= Nil
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADVEN102P - envReq - cJson " + cJson )
	
	//A carga deve ser no mแximo 25 registros.
	If ! U_ADVEN075P(cUrl,"POST",cJson,@cMsg,aResponse)
		Conout( DToC(Date()) + " " + Time() + " ADVEN102P - envReq (ERRO) " + cMsg )
		Return Nil
		
	EndIf
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADVEN102P - envReq - cMsg " + cMsg )
	
	//
	If ! FWJsonDeserialize(cMsg, @oParseJSON)
		Conout( DToC(Date()) + " " + Time() + " ADVEN102P - envReq - Ocorreu erro na desserializa็ใo do json (ERRO) " + cMsg )
		lRet := .F.

	Else
		
		//
		If ! oParseJSON:HASERRORS
			Conout( DToC(Date()) + " " + Time() + " ADVEN102P - envReq (SUCESSO)" + cMsg )
			
		Else
			Conout( DToC(Date()) + " " + Time() + " ADVEN102P - envReq (ERRO)" + cMsg )
			lRet := .F.
			
		EndIf
				

	EndIf
	
		
	//
	RestArea(aArea)		
	
Return oParseJSON
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณmntJson   บAutor  ณEverson             บ Data ณ  22/03/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta string json.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado TI.                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function mntJson(cMetodo,cObjeto,cChvExt,cParamBsc,cJsonObj)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea	 := GetArea()
	Local cJson	 := ""
	
	//Monta Json.
	If cMetodo == "GET"
	
		cJson += '{'
			cJson += '"method" : "GET",'
			cJson += '"url" : "v41.0/sobjects/' + cObjeto + '/' + cChvExt + '/' + cParamBsc + '?fields=Chave_Protheus__c"'
		cJson += '}'
	
	Else
		cJson += '{'
			cJson += '"method" : "' + cMetodo + '",'
			cJson += '"url" : ' + Iif(cMetodo == "POST",'"v41.0/sobjects/' + cObjeto + '"', '"v41.0/sobjects/' + cObjeto + '/' + cChvExt + "/" +  cParamBsc + '"') + ','
			cJson += '"richInput":{'	
	
				If cMetodo == "POST"
					cJson += '"' + cChvExt + '" : "' + cParamBsc + '",'
					
				EndIf
				
				cJson += cJsonObj
	
			cJson += '}'
	
		cJson += '}'
	
	EndIf

Return cJson
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlogZBN    บ Autor ณ Everson            บ Data ณ  30/05/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณGera log na ZBN.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado TI.                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function logZBN(cStatus)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADVEN102P'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADVEN102P'
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADVEN102P'
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return Nil