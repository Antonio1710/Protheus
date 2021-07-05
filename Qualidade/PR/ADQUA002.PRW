#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} User ADQUA002
    Job para obter dados de cargas da api appqualidade.adoro.com.br
    @type  Function
    @author Everson
    @since 31/05/2021
    @version 01
    /*/
User Function ADQUA002(dParData, nReproc) // U_ADQUA002()

    //Variáveis.
    Local cErro         := ""
    Local cToken        := ""
    Local cResponse     := ""
    //Default dParData    := Date()  
    Default dParData    := Stod("20210615")
    Default nReproc     := 2
    //
	//RPCSetType(3)
	//RpcSetEnv("01","02",,,,GetEnvServer(),{ })

        //
        If login(@cErro, @cToken) //Realiza login.
            If consulta(@cErro, cToken, @cResponse, dParData) //Executa consulta.
                procRes(@cErro, cResponse, cToken, dParData, nReproc) //Processa o resultado da consulta.

            EndIf

        EndIf

    //
    //RpcClearEnv()

Return Nil
/*/{Protheus.doc} login
    Efetua login na api.
    @type  Static Function
    @author Everson
    @since 31/05/2021
    @version 01
    /*/
Static Function login(cErro, cToken)

    //Variáveis.
    Local aArea       := GetArea()
    Local aHeader     := {}
    Local cUrl        := Alltrim(SuperGetMV("ZZ_QUA002A",,"https://appqualidade.adoro.com.br")) //Criar Mv.
    Local cUser       := Alltrim(SuperGetMV("ZZ_QUA002B",,"integr")) //Criar Mv.
    Local cPass       := Alltrim(SuperGetMV("ZZ_QUA002C",,"&@164dsaf87AA!")) //Criar Mv.
    Local cIdEmp      := Alltrim(SuperGetMV("ZZ_QUA002D",,"6037dd4e73fd4c545f88177d")) //Criar Mv.
    Local cExpoT      := Alltrim(SuperGetMV("ZZ_QUA002E",,"111111")) //Criar Mv.
    Local cCredenciais:= ""
    Local oRestClient := Nil
    Local cBody       := ""
    Local oJson       := Nil

    //
    Aadd(aHeader,"Content-Type: application/json")

    //
    cCredenciais += '{'
        cCredenciais += '"user": "' + cUser + '",'
        cCredenciais += '"password": "' + cPass + '",'
        cCredenciais += '"empresaId": "' + cIdEmp + '",'
        cCredenciais += '"expoToken": "' + cExpoT + '"'
    cCredenciais += '}'

    //
    oRestClient := FWRest():New(cUrl)
    oRestClient:setPath("/login")
    oRestClient:SetPostParams(cCredenciais)

    //
    If ! oRestClient:Post(aHeader)

        cErro := "Não foi possível efetuar login" + Chr(13) + Chr(10) + Alltrim(cValToChar(oRestClient:GetLastError()))
        Conout("ADQUA002 - login - cErro " + cErro)

        FreeObj(oRestClient)
        oRestClient := Nil
        RestArea(aArea)
        Return .F.

	EndIf

    //
    cBody := Alltrim(cValToChar(oRestClient:GetResult()))

    //Converte a string json em objeto.
	If ! FWJsonDeserialize(cBody, @oJson)

		cErro := "Ocorreu erro na desserialização do json com os dados de login"
        Conout("ADQUA002 - login - cErro " + cErro)
		FreeObj(oRestClient)
		oRestClient := Nil
		RestArea(aArea)
		Return .F.

	EndIf

    //
    cToken := Alltrim(cValToChar(oJson:token))

    //
    FreeObj(oRestClient)
    FreeObj(oJson)
	oRestClient := Nil
	oJson := Nil
    RestArea(aArea)

Return .T.
/*/{Protheus.doc} consulta
    Realiza consulta na api (GET).
    @type  Static Function
    @author Everson
    @since 31/05/2021
    @version 01
    /*/
Static Function consulta(cErro, cToken, cResponse, dParData, cUrl, cPath)

    //Variáveis.
    Local aArea       := GetArea()
    Local aHeader     := {}
    Local oRestClient := Nil

    //
    Default cUrl      := Alltrim(SuperGetMV("ZZ_QUA002F",,"https://appqualidade.adoro.com.br")) //Criar Mv.
    Default cPath     := Alltrim(SuperGetMV("ZZ_QUA002G",,"/inspections/integr?data.header.code=FORM-VP-QUA-0419&inspectionApprovedByDocumentAnalyst=true&inspectionHeaderPerformed.defaultForm=true&inspectionHeaderPerformed.dateOfInspectionFinishFormated=")) + DToS(dParData)
    
    //
    Aadd(aHeader,"Content-Type: application/json")
    Aadd(aHeader,"x-access-token: " + cToken)

    //
    oRestClient := FWRest():New(cUrl)
    oRestClient:setPath(cPath)

    //
    If ! oRestClient:Get(aHeader)

        cErro := "Não foi possível efetuar a consulta" + Chr(13) + Chr(10) + Alltrim(cValToChar(oRestClient:GetLastError()))
        Conout("ADQUA002 - consulta - cErro " + cErro)

        FreeObj(oRestClient)
        oRestClient := Nil
        RestArea(aArea)
        Return .F.

	EndIf

    //
    cResponse := Alltrim(cValToChar(oRestClient:GetResult()))
    
    //
    FreeObj(oRestClient)
	oRestClient := Nil
    RestArea(aArea)

Return .T.
/*/{Protheus.doc} procRes
    Processa resposta da api.
    @type  Static Function
    @author Everson
    @since 31/05/2021
    @version 01
    /*/
Static Function procRes(cErro, cResponse, cToken, dParData, nReproc)

    //Variáveis.
    Local aArea      := GetArea()
    Local cError     := ""
    Local oJson      := Nil
    Local nAux       := 1
    Local nAux2      := 1
    Local nAux3      := 1
    Local cInspecao  := ""
    Local cInspId    := ""
    Local aElementos := {}
    Local oElemento  := Nil
    Local cDtRot     := ""
    Local cRot       := ""
    Local cPdVend    := ""
    Local cPlaca     := ""
    Local cResul     := ""
    Local aAnexos    := {}
    Local oAnexo     := ""
    Local cUrlAnx    := ""
    Local cDescAnx   := ""
    Local cPalId     := ""
    Local nAux4      := 1
    Local aProdutos  := {}
    Local aImagens   := {}
    Local oProduto   := Nil
    Local cProd      := ""
    Local cProdEdt   := ""
    Local nTotCx     := ""
    Local nTotKg     := ""
    Local nTotKgR    := ""
    Local nTotTara   := ""
    Local cTurno     := ""
    Local cDtFab     := ""
    Local cDtVal     := ""
    Local cTemp      := ""
    Local cCarga     := ""
    Local cLacreSIF  := ""
    Local cLacreArm  := ""
    Local cDtCarreg  := ""
    Local cHrIniCar  := ""
    Local cHrTerCar  := ""

    //Converte a string json em objeto.
    oJson := JSONObject():New()
    cError := oJson:fromJSON(cResponse)

    //Converte a string json em objeto.
	If ! Empty(cError)
		cErro := "Ocorreu erro na desserialização do json com os dados de resposta"
        Conout("ADQUA002 - procRes - cErro " + cErro)
		RestArea(aArea)
		Return .F.

	EndIf

    //
    For nAux := 1 To Len(oJson)

        //
        cInspecao := oJson[nAux] //Objeto inspeção.
        cInspId   := cInspecao["_id"] // Id da Inspeção.
        aElementos:= cInspecao["data"]["content"]["elements"] //Elementos inspecionados.
        
        if fProcessa(cInspId, nReproc)
            //
            For nAux2 := 1 To Len(aElementos)
                
                //
                oElemento := aElementos[nAux2]
                
                //
                If ! oElemento:hasProperty("inspection")
                    Loop

                EndIf
                
                //
                cDesc  := Alltrim(cValToChar(oElemento["value"])) //Descrição do elemento inspecionado.
                cResul := Alltrim(cValToChar(oElemento["inspection"]["value"])) //Resultado da inspeção.

                //
                If cDesc == "Data do roteiro"
                    cDtRot := cResul
                elseIf cDesc == "Roteiro"
                    cRot   := cResul
                ElseIf cDesc == "Pedido"
                    cPdVend := cResul
                ElseIf cDesc == "Placa"
                    cPlaca := cResul
                ElseIf cDesc == "Carga"
                    cCarga := cResul
                ElseIf cDesc == "Conteiner"
                    cConte := cResul
                ElseIf cDesc == "NÂº Lacre Oficial:"
                    cLacreSIF := cResul
                ElseIf cDesc == "NÂº Lacre do Armador:"
                    cLacreArm := cResul
                ElseIf cDesc == "Data do carregamento"
                    cDtCarreg := cResul
                ElseIf cDesc == "Hora de inÃ­cio do carregamento"
                    cHrIniCar := cResul
                ElseIf cDesc == "Hora de tÃ©rmino do carregamento"
                    cHrTerCar := cResul
                EndIf

                //
                aAnexos := oElemento["inspection"]["attachements"] //Anexos.

                //Donwload de anexos.
                aImagens := {}
                For nAux3 := 1 To Len(aAnexos)
                    oAnexo := aAnexos[nAux3]
            
                    //
                    If oAnexo:hasProperty("url")
                        cUrlAnx := oAnexo["url"]
                        cDescAnx:= StrTran(StrTran(cDesc,Chr(13)," "),Chr(10)," ")
                        downImg(cUrlAnx, cToken, dParData, @aImagens, cInspId, cDescAnx)

                    EndIf

                Next nAux3
                
                //
                If ! oElemento["inspection"]:hasProperty("extraData")
                    Loop

                EndIf

                //
                If ! oElemento["inspection"]['extraData']:hasProperty("pallet")
                    Loop

                EndIf

                //
                aProdutos:= oElemento["inspection"]['extraData']['products']
                cTemp := cResul

                //
                Begin Transaction

                    For nAux4 := 1 To Len(aProdutos)
                        oProduto := aProdutos[nAux4]

                        cPalId  := oProduto["codigoPalete"]
                        cProd   := oProduto["produto"]
                        cProdEdt:= oProduto["produtoEd"]

                        nTotCx  := Val(cValToChar(oProduto["TotCx"]))
                        nTotKg  := Val(cValToChar(oProduto["TotKgS"]))
                        nTotKgR := Val(cValToChar(oProduto["TotKg"]))
                        nTotTara:= Val(cValToChar(oProduto["TotTara"]))

                        cTurno  := oProduto["turno"]
                        cDtFab  := oProduto["dataFabricacao"]
                        cDtVal  := oProduto["dataValidade"]

                        //
                        grvDados(cInspId, cDtRot, cRot, cPdVend, cPlaca, cCarga, cConte, cPalId, cProd, cProdEdt, nTotCx, nTotKg,;
                                nTotKgR, nTotTara, cTurno, cDtFab, cDtVal, cTemp, cLacreSIF, cLacreArm, cDtCarreg,;
                                cHrIniCar, cHrTerCar, aImagens)

                    Next nAux4

                End Transaction

                
            Next nAux2
        else 
            u_GrLogZBE(Date(),TIME(),cUserName,"Inspeção da Qualidade Pedido de Venda "+ cPdVend +", ID "+ cInspId +" ","SIGAEEC","ADQUA002",;
			        "procRes - Inspeção da qualidade do Pedido de Venda "+ cPdVend +", ID  "+ cInspId +;
                    ". Opção selecionada pelo usuário não permite a atualização dos registros gravados. ",ComputerName(),LogUserName())
        endif
    Next nAux

    //
    FreeObj(oJson)
	oJson := Nil
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} downImg
    Faz download de imagens.
    @type  Static Function
    @author Everson
    @since 31/05/2021
    @version 01
    /*/
Static Function downImg(cUrlAnx, cToken, dParData, aImagens, cInspId, cDescAnx)
    
    //Variáveis.
    Local aArea     := GetArea()
    Local cErro     := ""
    Local cResponse := ""
    Local cPasta    := Alltrim(SuperGetMV("ZZ_QUA002H",,"/fotos_inspecoes_qualidade/")) //Criar Mv.
    Local aUrl      := Separa(cUrlAnx,"/",.F.)
    Local cArq      := Alltrim(cValToChar(aUrl[Len(aUrl)]))

    //
    If ! consulta(@ cErro, cToken, @cResponse, dParData, cUrlAnx, "")
		cErro := "Ocorreu erro ao baixar o arquivo " + cUrlAnx
        Conout("ADQUA002 - downImg - cErro " + cErro)
		RestArea(aArea)
		Return .F.

    EndIf 

    //
    MemoWrite(cPasta + cArq, cResponse)

    //
    Aadd(aImagens,{cInspId, cPasta + cArq, cDescAnx})

    //
    RestArea(aArea)

Return .T.
/*/{Protheus.doc} grvDados
    Grava Dados.
    @type  Static Function
    @author Everson
    @since 31/05/2021
    @version 01
    /*/
Static Function grvDados(cInspId, cDtRot, cRot, cPdVend, cPlaca, cCarga, cConte, cPalId, cProd, cProdEdt, nTotCx, nTotKg,;
                         nTotKgR, nTotTara, cTurno, cDtFab, cDtVal, cTemp, cLacreSIF, cLacreArm, cDtCarreg,;
                         cHrIniCar, cHrTerCar, aImagens)
    
    conout(cInspId) //Id da inspeção.
    conout(cDtRot)  //Data do roteiro.
    conout(cRot)    //Roteiro.
    conout(cPdVend) //Pedido de venda.
    conout(cPlaca)  //Placa.
    conout(cCarga)  //Carga.
    conout(cPalId)  //Id do palete. 
    conout(cProd)   //Código produto Protheus.
    conout(cProdEdt)//Código produto Edata. 
    conout(nTotCx)  //Total em caixas.
    conout(nTotKg)  //Total em Kg.
    conout(nTotKgR) //Total em Kg real.
    conout(nTotTara)//Total tara das embalagens.
    conout(cTurno)  //Turno.
    conout(cDtFab)  //Data de fabricação.
    conout(cDtVal)  //Data de validade.
    conout(cTemp)   //Temperatura.

    //Nova tabela.
    varinfo('aImagens',aImagens)  //aImagens. //Id da inspeção, descrição da foto, caminho relativo.
    
    DbselectArea("ZEX")
    DbselectArea("ZEY")

    DbselectArea("SC5")
    SC5->(DbSetOrder(1))

    u_GrLogZBE(Date(),TIME(),cUserName,"Inspeção da Qualidade Pedido de Venda "+ cPdVend +", ID "+ cInspId +" ","SIGAEEC","ADQUA002",;
			"grvDados - Gravando os registros da inspeção da qualidade do Pedido de Venda "+ cPdVend +", ID  "+ cInspId +". ",ComputerName(),LogUserName())

    IF SC5->(Dbseek(xFilial("SC5")+cPdVend,.F.))
        IF SC5->C5_NUM == cPdVend

            
            if Reclock("ZEX",.T.)
                ZEX_FILIAL  := SC5->C5_FILIAL
                ZEX_NUMERO  := SC5->C5_NUM //cPdVend - Pedido de venda.
                ZEX_ID      := cInspId      //Id da inspeção.
                ZEX_ROTEDT  := stod(cDtRot) //Data do roteiro.
                ZEX_ROTEIR  := cRot         //Roteiro.
                ZEX_PLACA   := cPlaca       //Placa.
                ZEX_CARGA   := cCarga       //Carga.
                ZEX_CONTAI   := cConte       //Conteiner.
                ZEX_PALLET  := cPalId       //Id do palete.
                ZEX_PRODUT  := cProd        //Código produto Protheus.
                ZEX_EDTPRD  := cProdEdt     //Código produto Edata. 
                ZEX_QTDSUM  := nTotCx       //Total em caixas.
                ZEX_QUANTI  := nTotKg       //Total em Kg.
                ZEX_QTDREA  := nTotKgR      //Total em Kg real.
                ZEX_TARAEM  := nTotTara     //Total tara das embalagens.
                ZEX_TURNO   := cTurno       //Turno.
                ZEX_DTFABR  := stod(cDtFab) //Data de fabricação.
                ZEX_DTVALD  := stod(cDtVal) //Data de validade.
                ZEX_TEMPER  := Val(cTemp)   //Temperatura.
                ZEX_LACRE1  := cLacreArm    //Lacre Armador
                ZEX_LACRE2  := cLacreSIF    //Lacre SIF
                ZEX_DTCARG  := Ctod(cDtCarreg)    //Data de carregamento.
                ZEX_HRICAR  := cHrIniCar    //Hora de início de carregamento.
                ZEX_HRFCAR  := cHrTerCar    //Hora de término do carregamento.

                ZEX->(Msunlock())
            endif

            nArqTot := Len(aImagens)
            
            //Id da inspeção, descrição da foto, caminho relativo.
            for nA := 1 To nArqTot
                If Reclock("ZEY",.T.)
                    ZEY_FILIAL  := SC5->C5_FILIAL
                    ZEY_NUMERO  := SC5->C5_NUM
                    ZEY_ID      := aImagens[nA][01]
                    ZEY_PRODUT  := cProd
                    ZEY_ARQUIV  := aImagens[nA][02]
                    ZEY_DESCRI  := aImagens[nA][03]
                    ZEY->(Msunlock())
                endif
            next nA

        endif
    endif
    
Return Nil


Static Function fProcessa(cInspId, nReproc)
    Local lRet      := .T.
    Local nReg      := fRegistro(cInspId)
    
    if nReproc == 1

        if nReg > 0
            fExcluir(cInspId)
        endif

        lRet := .T.
    Elseif nReproc == 2 .and. nReg == 0
        lRet := .T.
    else
        lRet := .F.
    endif
    
return lRet

/*/{Protheus.doc} fregistro()
    (long_description)
    @type  Static Function
    @author user
    @since 02/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function fregistro(cInspId)
    Local cQuery    := ""
    Local nRet      := 0
    
    cQuery := "SELECT COUNT(*) CONTADOR FROM "+RetSqlName("ZEX")+" (NOLOCK) WHERE D_E_L_E_T_='' AND ZEX_FILIAL='"+ xFilial("ZEX") +"' AND ZEX_ID ='"+ cInspId +"'
    
    TcQuery cQuery ALIAS "QQTD" NEW

    nRet := QQTD->CONTADOR
    
    QQTD->(DbCloseArea())

Return nRet

/*/{Protheus.doc} fExcluir
    (long_description)
    @type  Static Function
    @author user
    @since 02/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function fExcluir(cInspId)
    Local lRet := .T.

    DbselectArea("ZEX")
    DbselectArea("ZEY")

    u_GrLogZBE(Date(),TIME(),cUserName,"Inspeção da Qualidade ID "+ cInspId +" ","SIGAEEC",;
        "ADQUA002","fExclui - Reprocessando os registros da inspeção da qualidade ID  "+ cInspId +". ",ComputerName(),LogUserName())
      
    cQuery := "SELECT R_E_C_N_O_ REGISTRO FROM "+RetSqlName("ZEX")+" (NOLOCK) WHERE D_E_L_E_T_='' AND ZEX_FILIAL='"+ xFilial("ZEX") +"' AND ZEX_ID ='"+ cInspId +"';"
    
    TcQuery cQuery ALIAS "QZEX" NEW

    while QZEX->(!eof())
        ZEX->(DbGoTo(QZEX->REGISTRO))

        if ZEX->(RECNO()) == QZEX->REGISTRO
            If reclock("ZEX",.F.)
                Dbdelete()
                ZEX->(Msunlock())
            endif
        endif

        QZEX->(Dbskip())
    enddo

    QZEX->(DbCloseArea())

    cQuery := "SELECT R_E_C_N_O_ REGISTRO FROM "+RetSqlName("ZEY")+" (NOLOCK) WHERE D_E_L_E_T_='' AND ZEY_FILIAL='"+ xFilial("ZEY") +"' AND ZEY_ID ='"+ cInspId +"';"
    
    TcQuery cQuery ALIAS "QZEY" NEW

    while QZEY->(!eof())
        ZEY->(DbGoTo(QZEY->REGISTRO))

        if ZEY->(RECNO()) == QZEY->REGISTRO
            If reclock("ZEY",.F.)
                Dbdelete()
                ZEY->(Msunlock())
            endif
        endif

        QZEY->(Dbskip())
    enddo

    QZEY->(DbCloseArea())

Return lRet
