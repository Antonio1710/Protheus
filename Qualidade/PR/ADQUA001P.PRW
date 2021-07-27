#Include "Protheus.ch"
#Include "Restful.ch"
#Include "Topconn.ch"

Static cFormatRet := "application/json" 

/*/{Protheus.doc} User Function ADQUA001P
    Serviço Rest para consultas realizadas pela inspeção da qualidade
    @type  Function
    @author Everson
    @since 31/05/2021
    @version 01
    @history Everson, 15/06/2021, Chamado 4257 Descomentadas as linhas de container e tara.
    @history Everson, 20/07/2021, Chamado 4257 Tratamento para formatação da data do roteiro.
    @history Everson, 26/07/2021, Chamado 4257 Tratamento para inserir informações por lote, data de vencimento, data de produção e produto.
/*/
User Function ADQUA001P
return Nil

WsRestful inspecaoqualidade Description "Serviço Rest para consultas realizadas pela inspeção da qualidade"

    WsMethod Get Description "Obtém dados." WsSyntax "/data/{resource}/{id}"

End WsRestFul
/*/{Protheus.doc} Get
    Implementação do método Get.
    @type  Static Function
    @author Everson
    @since 31/05/2021
    @version 01
    /*/
WsMethod Get WsService inspecaoqualidade

    //Variáveis.
    Local aParametros := Self:aURLParms
    Local cRecurso    := ""
    Local cJsonResp   := ""
    Local cErro       := ""
    Local cId         := ""

    //
    Self:SetContentType(cFormatRet)

    //
    logZBE("Início consulta", "", "")

    //
    If Len(aParametros) <> 2
        //
        logZBE("Parâmetros inválidos")
        SetRestFault(400,EncodeUTF8("Parâmetros inválidos."),.T.,400)
        Return .F.

    EndIf

    //
    cRecurso:= Alltrim(aParametros[1])

    //
    cId := Alltrim(cValToChar(aParametros[2]))

    //
    logZBE("Recurso", cValToChar(cRecurso))

    //
    logZBE("Id", cValToChar(cId))

    If cRecurso == "cargas"
        cJsonResp := getCarga(@cErro, cId)

    ElseIf cRecurso == "paletes"
        cJsonResp := getPalete(@cErro, cId)

    Else 
        SetRestFault(404,EncodeUTF8("Recurso não encontrado."),.T.,404)
        Return .F.

    EndIf

    //
    If ! Empty(cErro)
        logZBE("Erro", cValToChar(cErro))
        SetRestFault(400,EncodeUTF8(cErro),.T.,400)
        Return .F.

    EndIf

    //
    logZBE("Resposta", "",cJsonResp)
    Self:SetResponse(cJsonResp)

Return .T.
/*/{Protheus.doc} getCarga
    Retorna json com informações da carga.
    @type  Static Function
    @author Everson
    @since 31/05/2021
    @version 01
    /*/
Static Function getCarga(cErro, cId)

    //Variáveis.
    Local aArea     := GetArea()
    Local cQuery    := ""
    Local cJsonResp := ""
    oStatement := FWPreparedStatement():New()

    //
    cQuery += " SELECT "

        cQuery += " C5_DTENTR, "
        cQuery += " C5_ROTEIRO, "
        cQuery += " C5_NUM, "
        cQuery += " C5_PLACA, "
        
        cQuery += " EE7_CONTAI, " //Everson, 15/06/2021, Chamado 4257.
        //cQuery += " '' AS EE7_CONTAI, "
        
        cQuery += " C5_NOMECLI, "
        
        cQuery += " EE7_XTARA, " //Everson, 15/06/2021, Chamado 4257.
        //cQuery += " '' AS EE7_XTARA, "

        cQuery += " A4_NOME, "
        cQuery += " C5_X_SQED, "
        cQuery += " YA_DESCR, "
        cQuery += " C5_VOLUME1 "

    cQuery += " FROM "
        cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 "
        cQuery += " INNER JOIN "
        cQuery += " " + RetSqlName("SA4") + " (NOLOCK) AS SA4 ON "
        cQuery += " C5_TRANSP = A4_COD "
        cQuery += " INNER JOIN "
        cQuery += " " + RetSqlName("EE7") + " (NOLOCK) AS EE7 ON "
        cQuery += " SC5.C5_NUM = EE7.EE7_PEDFAT "
        cQuery += " INNER JOIN "
        cQuery += " " + RetSqlName("SYA") + " (NOLOCK) AS SYA ON "
        cQuery += " EE7_PAISET = YA_CODGI "

    cQuery += " WHERE "
        cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "' "
        cQuery += " AND RTRIM(LTRIM(C5_DTENTR)) + RTRIM(LTRIM(C5_ROTEIRO)) = ? "
        
        cQuery += " AND C5_NOTA = '' "
        
        cQuery += " AND SC5.D_E_L_E_T_ = '' "
        cQuery += " AND SA4.D_E_L_E_T_ = '' "
        cQuery += " AND EE7.D_E_L_E_T_ = '' "
        cQuery += " AND SYA.D_E_L_E_T_ = '' "

    oStatement:SetQuery(cQuery)
    oStatement:SetString(1,cId)
    cQuery := oStatement:GetFixQuery()

    //
    If Select("D_CABEC") > 0
        D_CABEC->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "D_CABEC"
    DbSelectArea("D_CABEC")
    D_CABEC->(DbGoTop())
    If D_CABEC->(Eof())
        cErro := "Roteiro não localizado."
        D_CABEC->(DbCloseArea())
        Return .F.

    EndIf

    //
    cJsonResp += ' { '
        cJsonResp += ' "dataRoteiro": "' + DToC(SToD(D_CABEC->C5_DTENTR)) + '", ' //Everson - 20/07/2021. Chamado 4257. 
        cJsonResp += ' "roteiro": "' + Alltrim(cValToChar(D_CABEC->C5_ROTEIRO)) + '", '
        cJsonResp += ' "pedido": "' + Alltrim(cValToChar(D_CABEC->C5_NUM)) + '", '
        cJsonResp += ' "placa":"' + Alltrim(cValToChar(D_CABEC->C5_PLACA)) + '", '
        cJsonResp += ' "conteiner": "' + Alltrim(cValToChar(D_CABEC->EE7_CONTAI)) + '", '	
        cJsonResp += ' "cliente": "' + rmvAcento(Alltrim(cValToChar(D_CABEC->C5_NOMECLI))) + '",  '
        cJsonResp += ' "destino": "' + rmvAcento(Alltrim(cValToChar(D_CABEC->YA_DESCR))) + '", '
        cJsonResp += ' "carga": "' + Alltrim(cValToChar(D_CABEC->C5_X_SQED)) + '", '
        cJsonResp += ' "quantidade": "' + Alltrim(cValToChar(D_CABEC->C5_VOLUME1)) + '", '
        cJsonResp += ' "transportador": "' + rmvAcento(Alltrim(cValToChar(D_CABEC->A4_NOME))) + '", '
        cJsonResp += ' "tara": "' + Alltrim(cValToChar(D_CABEC->EE7_XTARA)) + '"  '
    cJsonResp += ' } '

    //
    RestArea(aArea)

Return EncodeUTF8(cJsonResp)
/*/{Protheus.doc} getPalete
    Retorna json com informações do palete.
    @type  Static Function
    @author Everson
    @since 31/05/2021
    @version 01
    /*/
Static Function getPalete(cErro, cPallete)

    //Variáveis.
    Local aArea     := GetArea()
    Local cJsonResp := ""
    Local cXml      := wsEdata(@cErro, cPallete)
    Local oXml      := Nil
    Local cErrXML   := ""
    Local cWarning  := ""
    Local xCaixas   := {}
    Local nTotKgS   := 0
    Local nTotKg    := 0 
    Local nTotCx    := 0
    Local nTotTara  := 0
    Local nAux      := 1
    Local cDescProd := ""
    Local cChave    := ""
    Local aDados    := {}
    Local cTotalCxP := ""
    Local cDataP    := ""
    Local cKgP      := ""
    Local cKgRP     := ""
    Local cTaraP    := ""
    Local cStatusP  := ""

    //
    If ! Empty(cErro)
        Return .F.

    EndIf

    //Gera o Objeto XML
    oXml := XmlParser(cXml, "_", @cErrXML, @cWarning)
    If (oXml == Nil )
        cErro := "Falha ao gerar Objeto XML : " + cErrXML + " / " + cWarning
        Return .F.

    EndIf
    
    //Valida o status de retorno
    If Alltrim(cValToChar(oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_GETPALLETINFORESPONSE:_NS3_WEBSERVICERETURN:_STATUS:TEXT)) == "wrsFailed"
        cErro := Alltrim(cValToChar(oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_GETPALLETINFORESPONSE:_NS3_WEBSERVICERETURN:_MESSAGE:TEXT))
        Return .F.

    EndIf

    //
    xCaixas := XmlChildEx(oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_GETPALLETINFORESPONSE,"_NS2_GETPALLETINFOCARTONITEM")

    //
    If ValType(xCaixas) == "U"
        cErro := "Palete não possui caixas associadas."
        Return .F.

    ElseIf ValType(xCaixas) == "A"

        //
        cTotalCxP := oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_GETPALLETINFORESPONSE:_NS2_PALLETINFODATA:_DispatchQty:TEXT
        cDataP    := oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_GETPALLETINFORESPONSE:_NS2_PALLETINFODATA:_PalletDate:TEXT
        cKgP      := oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_GETPALLETINFORESPONSE:_NS2_PALLETINFODATA:_NetWeight:TEXT
        cKgRP     := oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_GETPALLETINFORESPONSE:_NS2_PALLETINFODATA:_RealWeight:TEXT
        cTaraP    := oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_GETPALLETINFORESPONSE:_NS2_PALLETINFODATA:_Tare:TEXT
        cStatusP  := oXml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_GETPALLETINFORESPONSE:_NS2_PALLETINFODATA:_PalletStatus:TEXT
     
        //
        cJsonResp += '['

            If Len(xCaixas) > 0

                //
                aDados := {}
                For nAux := 1 To Len(xCaixas)
                    oItem := xCaixas[nAux]
                    Aadd(aDados,{;
                         Alltrim(cValToChar(oItem:_PRODUCTNO:TEXT)) + StrTran(Substr(Alltrim(cValToChar(oItem:_STANDARDDATE:TEXT)),1,10),"-","") + StrTran(Substr(Alltrim(cValToChar(oItem:_EXPIRATIONDATE:TEXT)),1,10),"-","") + StrTran(Alltrim(cValToChar(oItem:_LOTNO:TEXT))," ",""),; //Chave. 1. Everson - 26/07/2021. Chamado 4257.
                         Alltrim(cValToChar(oItem:_PRODUCTNO:TEXT)),; //Código do produto no Protheus. 2
                         Alltrim(cValToChar(oItem:_PRODUCTIONCODE:TEXT)),; //Código do produto no Edata. 3
                         Alltrim(cValToChar(oItem:_STANDARDDATE:TEXT)),; //Data padrão. 4
                         Alltrim(cValToChar(oItem:_EXPIRATIONDATE:TEXT)),; //Data de validade. 5
                         Alltrim(cValToChar(oItem:_LOTNO:TEXT)),; //Lote. 6
                         Alltrim(cValToChar(oItem:_StandardWeight:TEXT)),; //Peso padrão. 7
                         Alltrim(cValToChar(oItem:_NetWeight:TEXT)),; //Peso real. 8
                         Alltrim(cValToChar(oItem:_Tare:TEXT)); //Tara da embalagem. 9
                    })
                Next nAux

                Asort(aDados, , , { | x,y | x[1] < y[1] } )

                //
                nAux := 1
                While nAux <= Len(aDados)

                    //
                    cChave:= aDados[nAux][1]

                    //
                    cDescProd := Posicione("SB1",1,FWxFilial("SB1") + Alltrim(cValToChar(aDados[nAux][2])), "B1_DESC")
                    
                    //
                    cJsonResp += '{'

                    cJsonResp += '"codigoPalete": "' + cValtoChar(cPallete)  + '",'
                    cJsonResp += '"dataPalete": "'   + cValtoChar(cDataP)    + '",'
                    cJsonResp += '"TotCxPalete": "'  + cValtoChar(cTotalCxP) + '",'
                    cJsonResp += '"TotKgPalete": "'  + cValtoChar(cKgP)      + '",'
                    cJsonResp += '"TotKgRPalete": "' + cValtoChar(cKgRP)     + '",'
                    cJsonResp += '"statusPalete": "' + rmvAcento(cValtoChar(cStatusP)) + '",'

                    cJsonResp += '"dataFabricacao": "' + StrTran(Substr(Alltrim(cValToChar(aDados[nAux][4])),1,10),"-","") + '",' 
                    cJsonResp += '"dataValidade": "' + StrTran(Substr(Alltrim(cValToChar(aDados[nAux][5])),1,10),"-","") + '",' 
                    cJsonResp += '"turno": "' + rmvAcento(Alltrim(cValToChar(aDados[nAux][6]))) + '",'
                    cJsonResp += '"produtoEd": "' + Alltrim(cValToChar(aDados[nAux][3])) + '",'
                    cJsonResp += '"produto": "' + rmvAcento(rmvAcento(Alltrim(cValToChar(aDados[nAux][2])))) + '",'
                    cJsonResp += '"descricaoProduto": "' + rmvAcento(cDescProd) + '",'
                    
                    //
                    nTotKgS   := 0
                    nTotKg    := 0
                    nTotTara  := 0
                    nTotCx    := 0

                    //
                    While aDados[nAux][1] == cChave
                        nTotKgS   += Val(cValToChar(aDados[nAux][7]))
                        nTotKg    += Val(cValToChar(aDados[nAux][8]))
                        nTotTara  += Val(cValToChar(aDados[nAux][9]))
                        nTotCx++
                        nAux++

                        //
                        If nAux > Len(xCaixas)
                            Exit

                        EndIf

                    End

                    cJsonResp += '"TotKgS": "' + cValToChar(nTotKgS)  + '",'
                    cJsonResp += '"TotKg": "'  + cValToChar(nTotKg)   + '",'
                    cJsonResp += '"TotCx": "'  + cValToChar(nTotCx)   + '",'
                    cJsonResp += '"TotTara": "'+ cValToChar(nTotTara) + '"'
                    cJsonResp += '},'

                End

                //
                cJsonResp := Substr(cJsonResp,1,Len(cJsonResp)-1)

            EndIf

        cJsonResp += ']'

    EndIf

    //
    RestArea(aArea)

Return EncodeUTF8(cJsonResp)
/*/{Protheus.doc} wsEdata
    Função consome Ws Edata para obter informações do pallete.
    @type  Static Function
    @author Everson
    @since 31/05/2021
    @version 01
    /*/
Static Function wsEdata(cErro,cPallete)

    //Variáveis.
    Local aArea     := GetArea()
    Local cUrl      := Alltrim(cValToChar(GetMv("MV_#APPEDT",,"http://10.5.1.4:8080/wsdl/IWebServiceInterface")))
    Local oWsdl     := Nil
    Local xRet      := Nil
    Local cResponse := ""

    //    
    oWsdl := TWsdlManager():New()

    //
    oWsdl:nTimeout := 120

    //
    xRet := oWsdl:ParseURL(cUrl)
    If xRet == .F.
        conout( "Erro1: " + oWsdl:cError )
        cErro := "Erro1: " + oWsdl:cError
        Return xRet
    
    EndIf

    // Define a operação
    xRet := oWsdl:SetOperation("GetPalletInfo")
    If xRet == .F.
        conout( "Erro2: " + oWsdl:cError )
        cErro := "Erro2: " + oWsdl:cError
        Return xRet
    
    EndIf

    // Define o valor de cada parâmeto necessário
    xRet := oWsdl:SetValue(0,cPallete)
    If xRet == .F.
        conout( "Erro3: " + oWsdl:cError )
        cErro := "Erro3: " + oWsdl:cError
        Return xRet
    
    EndIf

    // Envia a mensagem SOAP ao servidor
    xRet := oWsdl:SendSoapMsg()

    //
    cResponse :=  oWsdl:GetSoapResponse()

    //
    RestArea(aArea)

Return cResponse
/*/{Protheus.doc} logZBE
    Função para geração de log na tabela ZBE.
    @type  Static Function
    @author Everson
    @since 31/05/2021
    @version 01
    /*/
Static Function logZBE(cLog, cParam, cMemo)
    
    //Variáveis.
	Local aArea   := GetArea()

    //
	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
        Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
        Replace ZBE_DATA 	   	WITH dDataBase
        Replace ZBE_HORA 	   	WITH Time()
        Replace ZBE_USUARI	    WITH Upper(Alltrim(cUserName))
        Replace ZBE_LOG	        WITH cLog
        Replace ZBE_MODULO	    WITH "QUALIDADE"
        Replace ZBE_ROTINA	    WITH "ADQUA001" 
        Replace ZBE_PARAME      WITH cParam
        Replace ZBE_LOGMEM      WITH cMemo
	ZBE->( MsUnLock())

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} rmvAcento
    Função remove acentos de textos.
    @type  Static Function
    @author Everson
    @since 31/05/2021
    @version 01
    /*/
Static Function rmvAcento(cTexto)
Return StaticCall(ADFIN064P, rmvAcento,cTexto)
