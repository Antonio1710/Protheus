#Include "Totvs.ch"
#Include "Restful.ch"
#Include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADVEN067P      บAutor  ณEverson      บ Data ณ  26/01/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para envio de estoque ao SalesForce.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADVEN067P()  // U_ADVEN067P()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun็ใo para envio de estoque ao SalesForce.')

	Processa({||  Processar() },"Enviar estoque SalesForce...")

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcessar      บAutor  ณEverson      บ Data ณ  08/02/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para processar envio de estoque ao SalesForce.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Processar()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local i			:= 1
	Local cMsg		:= ""
	Local cParamBsc	:= ""
	Local cErros	:= ""

	Local cBuffer	:= ""
	Local aDados	:= {}
	Local cData		:= ""
	Local cProduto	:= ""
	Local cQtd		:= ""

	Local aCarga	:= {}
	Local lLogin	:= .F.
	Local nAux		:= 0
	Local cJson		:= ""
	Local nRegErro	:= 0
	Local cBusPrd	:= ""

	Private cArq	:= ""
	Private nHdl	:= 0

	Private aResponse := {}

	//Efetura login no SalesForce.
	lLogin := StaticCall(ADVEN075P,loginSF,@aResponse,@cMsg,.F.)

	//
	If ! lLogin
		Return Nil

	EndIf

	//Obt้m arquivo.
	cMsg := ""
	cArq := cGetFile('Arquivo CSV|*.*|Arquivo *|*.*','Selecione arquivo',0,'C:\',.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.)

	//Valida arquivo.  
	If Empty(cArq)
		MsgStop( "Nใo foi possํvel obter o arquivo.","Processar(ADVEN067P)")
		Return Nil

	Endif
	
	//Abre o arquivo.
	nHdl := FT_FUse(cArq)

	//Valida abertura do arquivo.
	If nHdl == -1
		MsgStop("Nใo foi possํvel abrir o arquivo " + Chr(13) + Chr(13) + cArq,"Fun็ใo lerArquivo")
		Return Nil

	Endif

	FT_FGoTop()

	//Obt้m a quantidade de linhas.
	nTotLinhas := FT_FLastRec()

	//Atribui o tamanho da r้gua.
	ProcRegua(nTotLinhas)

	FT_FGoTop()
	FT_FGoto(1)

	//Percorre arquivo.
	While ! FT_FEof()

		cBuffer  := Alltrim(cValToChar(DecodeUTF8(FT_FReadln())))

		If ! Empty(cBuffer)

			aDados	 := StrToKarr(cBuffer,";")
			
			If Len(aDados) <> 3
				MsgStop("O arquivo CSV deve ser composto de data;produto;quantidade .","Fun็ใo Processar(ADVEN067P)")
				Return Nil
				
			EndIf

			cData	 := Substr(Alltrim(cValToChar(aDados[1])),1,4) + "-" + Substr(Alltrim(cValToChar(aDados[1])),5,2) + "-" + Substr(Alltrim(cValToChar(aDados[1])),7,2)
			cProduto := Alltrim(cValToChar(aDados[2]))
			cQtd	 := Alltrim(cValToChar(aDados[3]))
			
			//
			cBusPrd := Alltrim(cValToChar(Posicione("SB1",1,xFilial("SB1") + cProduto ,"B1_XSALES")))
			If cBusPrd <> "2"
				MsgStop("Por favor, reveja o arquivo o produto " + cProduto + " nใo estแ marcado para importa็ใo no SalesForce.","Fun็ใo Processar(ADVEN067P)")
				Return Nil
							
			EndIf
			
			//Incrementa regua de processamento.
			IncProc("Pr " + cProduto + "/" + " | Dt " + cData)

			Aadd(aCarga,{cData + cProduto,cQtd,"",cProduto,cData})

		EndIf

		FT_FSkip()

	EndDo

	//Consulta se o produto jแ foi enviado ao SalesForce.
	For i := 1 To Len(aCarga)

		//cParamBsc := aCarga[i][1]
		aCarga[i][3] := "PATCH"
		//MsAguarde({|| consulEst(cParamBsc,@cErros,aResponse,@aCarga,i,@nAux,@nRegErro) },"Aguarde","Consulta SF " + cParamBsc)
		nAux++
		
	Next i

	//Verifica se hแ erros no retorno da consulta no SalesForce.
	If !Empty(cErros)

		StaticCall(ADVEN075P,TelErro,"Envio SalesForce - ADVEN067P - O produtos abaixo nใo serใo enviados ","Quantidade de registros: " + cValToChar(nRegErro) + Chr(13) + Chr(10) + cErros,"Arial",10,,.F.,.T.)

	EndIf

	//Envia dados ao SalesForce.
	cMsg   := ""
	cErros := ""
	If nAux > 0

		Processa({|| envReq(aCarga,@cMsg,@cErros,aResponse) },"Aguarde","Processando registros....",.F.)

	EndIf

	//Verifica se hแ erros no envio do estoque ao SalesForce.
	If ! Empty(cErros)
		StaticCall(ADVEN075P,TelErro,"Envio SalesForce - ADVEN067P - Retorno com erro.",cErros,"Arial",10,,.F.,.T.)

	Else
		MsgInfo("Dados enviados.","Fun็ใo ADVEN067P")

	EndIf

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณconsulEst    บAutor  ณEverson     บ Data ณ  26/01/2018      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsulta status.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function consulEst(cParamBsc,cErros,aResponse,aCarga,i,nAux,nRegErro)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cServTab	:= "/services/data/v41.0/sobjects/Estoque__c/"
	Local cChvExt	:= "Codigo__c/"
	Local cMsg		:= ""
	
	//
	If ! U_ADVEN075P(cServTab + cChvExt + cParamBsc,"GET","",@cMsg,aResponse)

		//
		cMsg :=  Alltrim(cValToChar(cMsg))
		If "NOT_FOUND" $cMsg .Or. "404 NotFound" $cMsg  //Registro nใo encontrado no SalesForce.
			aCarga[i][3] := "POST"
			nAux++

		Else

			cErros += "Ocorreu erro na consulta consulEst " + cValToChar(cParamBsc) + " no SalesForce." + Chr(13) + Chr(10) + cMsg + Chr(13) + Chr(10) + "-------------------------------" + Chr(13) + Chr(10)		
			nRegErro++

		EndIf

	Else

		aCarga[i][3] := "PATCH" // Registro encontrado no SalesForce.
		nAux++

	EndIf

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณenvReq     บAutor  ณEverson     บ Data ณ  26/01/2018      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta json.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function envReq(aCarga,cMsg,cErros,aResponse,nRegErro)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cData		:= ""
	Local i			:= 1
	Local cChave	:= ""
	Local cQtd		:= ""
	Local cMetodo	:= ""
	Local cProd		:= ""
	Local cJson		:= ""
	Local cUrl  	:= "/services/data/v41.0/composite/batch/"
	Local cChvExt	:= "Codigo__c/"
	Local nAux		:= 0
	Local nRegErro	:= 0
	Local aRetOk	:= {}

	//
	ProcRegua(Len(aCarga))
	For i := 1 To Len(aCarga)

		cChave	:= Alltrim(cValToChar(aCarga[i][1]))
		cQtd	:= Alltrim(cValToChar(aCarga[i][2]))
		cMetodo := Alltrim(cValToChar(aCarga[i][3]))
		cProd	:= Alltrim(cValToChar(aCarga[i][4]))
		cData   := Alltrim(cValToChar(aCarga[i][5]))
		
		IncProc("Chave " + cChave)
		
		Aadd(aRetOk,{cMetodo,cChave,"NP","","",""})

		//
		cJson += '{'
			cJson += '"method" : "' + cMetodo + '",'
			cJson += '"url" : ' + Iif(cMetodo == "POST",'"v41.0/sobjects/Estoque__c"', '"v41.0/sobjects/Estoque__c/' + cChvExt +  cChave + '"') + ','
			cJson += '"richInput":{'	
	
				If cMetodo == "POST"
					cJson += '"Codigo__c" : "' + cChave + '",'
					
				EndIf
				
				cJson += '"Produto__r" : {'
				cJson += '"Codigo__c" : "' + cProd + '"'
				cJson += '},'
	
				cJson += '"Data__c" : "' + cData + '",'
				cJson += '"SKU__c" : "' + cProd + '",'
		
				cJson += '"Quantidade__c" : "' + cQtd + '"'
	
			cJson += '}'

		cJson += '},'
		
		nAux++

		//A carga deve ser no mแximo 25 registros.
		If (nAux == 25) .Or.;          // Se atingiu 25 registros.
		   (nAux == Len(aCarga)) .Or.; // Se nใo atingiu 25, mas atingiu o tamanho da carga.
		   (i == Len(aCarga))          // Se o loop chegou ao tamanho da carga.

			cJson := Substr(cJson,1,Len(cJson) -1)
			cJson := '{"batchRequests":[' + cJson + ']}'
			
			//
			If ! U_ADVEN075P(cUrl,"POST",cJson,@cMsg,aResponse)

				cErros += "Ocorreu erro no envio para o SalesForce." + Chr(13) + Chr(10) + cMsg +  Chr(13) + Chr(10) + "------------------------" + Chr(13) + Chr(10)

			Else

				//Checa se o retorno do envio em lote possui erro.
				nRegErro := 0
				StaticCall(ADVEN075P,chkErro,@cMsg,@cErros,.F.,cUrl,@cJson,"POST",@aRetOk,,,,,"ADVEN067P",,,,"estoque")
				aRetOk := {}

			EndIf		
			
			//
			cJson := ""
			nAux  := 0

		EndIf

	Next i

Return Nil