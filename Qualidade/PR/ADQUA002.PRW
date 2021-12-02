#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} User ADQUA002
    Job para obter dados de cargas da api appqualidade.adoro.com.br
    @type  Function
    @author Everson
    @since 31/05/2021
    @version 01
    @history Chamado 8465  - Leonardo P. Monteiro    - 19/07/2021 - Adição de novos campos retornados do aplicativo da Qualidade.
    @history Chamado 8465  - Leonardo P. Monteiro    - 01/08/2021 - Adição do detalhamento das embalagens (ZGA/ZGB).
    @history Chamado 8465  - Leonardo P. Monteiro    - 09/08/2021 - Correção e implementação de melhorias como formatação de campos.
    @history Chamado 18431 - Leonardo P. Monteiro    - 16/08/2021 - Correção no programa para excluir os registros somente após todas as checagens e modificar a mesagem de alerta.
    @history Chamado 63954 - Leonardo P. Monteiro    - 29/11/2021 - Correções e melhorias no processo de exportação.
    /*/
User Function ADQUA002(dParData, nReproc) // U_ADQUA002()

    //Variáveis.
    Local cErro         := ""
    Local cToken        := ""
    Local cResponse     := ""
    Local cMens         := ""
    Private cEOL        := Chr(13)+chr(10)
    Private cStatCar    := SuperGetMV("MV_XSTACAR",,"FE,AP")
    Private lImpFat     := SuperGetMV("MV_XQLDFAT",,.F.)

    Default dParData    := Stod("20210615")
    Default nReproc     := 2
    
    //
	//RPCSetType(3)
	//RpcSetEnv("01","02",,,,GetEnvServer(),{ })
    //Garanto uma única thread sendo executada.
    If !LockByName("ADQUA002", .T., .F.)
	    u_GrLogZBE(Date(),TIME(),cUserName,"Início da rotina Qualidade Pedido de Venda","SIGAEEC","ADQUA002",;
			    "Rotina não inicada por estar sendo executada por outro usuário. ",ComputerName(),LogUserName())
        
        MsgInfo("Rotina sendo executada por outro usuário ou agendamento! Aguarde o término da execução.", "..:: Em execução ::.. ")
    else
        //
        If login(@cErro, @cToken) //Realiza login.
            If consulta(@cErro, cToken, @cResponse, dParData) //Executa consulta.
                procRes(@cErro, @cMens, cResponse, cToken, dParData, nReproc) //Processa o resultado da consulta.
                
                if !Empty(cMens)
                    
                    if "(Rejeitado)"$cMens .OR. "(Ignorado)"$cMens
                        MsgStop("Eventos de processamento com erros: "+ cMens, "Término da rotina")
                    else
                        MsgInfo("Eventos de processamento: "+ cMens, "Término da rotina")
                    endif
                endif
            EndIf

        EndIf

        UnLockByName("ADQUA002")
    endif
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
Static Function procRes(cErro, cMens, cResponse, cToken, dParData, nReproc)

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
    Local cCompon    := ""
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
    Local cLacData   := ""
    Local cLacHora   := ""
    Local cLimpInt   := ""
    Local cLimpExt   := ""
    Local cTempBau   := ""
    Local cBorrach   := ""
    Local cTraDobr   := ""
    Local cEquipFr   := ""
    Local dDtICar    := Stod("")
    Local dDtTCar    := Stod("")
    Local cHrICar    := ""
    Local cHrTCar    := ""
    Local cDtIQld    := ""
    Local cHrIQld    := ""
    Local cHrTQld    := ""
    Local cMonQua    := ""
    Local cTaraCo    := ""
    Local cTermog    := ""
    Local nReg       := 0

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
        cInspecao   := oJson[nAux] //Objeto inspeção.
        cInspId     := cInspecao["_id"] // Id da Inspeção.
        cMonQua     := Alltrim(cInspecao["inspectionHeaderPerformed"]["userRealName"])
        cAprQua     := Alltrim(cInspecao["inspectionApprovedBy"]["name"])
        cDtApro     := Alltrim(cInspecao["inspectionApprovedBy"]["dateOfApprovedFormated"])
        if len(cDtApro) > 0
            dDatApr := Ctod(left(cDtApro,10))
            cHorApr := Right(cDtApro,5)
        endif
        aElementos  := cInspecao["data"]["content"]["elements"] //Elementos inspecionados.

        
        cDtRot      := ""
        cRot        := ""
        cPdVend     := ""
        cPlaca      := ""
        cCarga      := ""
        cConte      := ""
        cLacreSIF   := ""
        cLacreArm   := ""
        cDtIQld     := ""
        cHrIQld     := ""
        cHrTQld     := ""
        cLacData    := ""
        cLacHora    := ""
        cLimpInt    := ""
        cLimpExt    := ""
        cDesc       := ""
        cTempBau    := ""
        cBorrach    := ""
        cEquipFr    := ""
        cTaraCo     := ""
        cTermog     := ""
        nReg        := 0

        // verifica as opções selecionadas dos usuários.
        if fProcessa(cInspId, nReproc, @nReg)

            // Valida as regras de negócio para permitir que o processo seja integrado.
            if fStEData(aElementos, @cMens, @cPdVend, @cCarga, @dDtICar, @dDtTCar, @cHrICar, @cHrTCar)
                
                // Excluir os registros na base de dados caso estejam integrados.
                if nReg > 0
                    fExcluir(cInspId)
                endif
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
                            cLacreSIF   := cResul
                        ElseIf cDesc == "NÂº Lacre do Armador:"
                            cLacreArm   := cResul
                        ElseIf cDesc == "Data do carregamento" .OR. cDesc == "Data da inspeÃ§Ã£o"
                            cDtIQld := cResul
                        ElseIf cDesc == "Hora de inÃ­cio do carregamento" .OR. cDesc == "Hora de inÃ­cio da inspeÃ§Ã£o"
                            cHrIQld   := cResul
                        ElseIf cDesc == "Hora de tÃ©rmino do carregamento" .OR. cDesc == "Hora de tÃ©rmino da inspeÃ§Ã£o"
                            cHrTQld   := cResul
                        // Data Lacre - Pendente.
                        ElseIf cDesc == "Data do lacre oficial"
                            cLacData    := cResul
                        // Hora Lacre - Pendente.
                        ElseIf cDesc == "Hora do lacre oficial"
                            cLacHora  := cResul
                        ElseIf cDesc == "Limpeza interna do baÃº"
                            cLimpInt    := iif(alltrim(cResul)=="c","S","N")
                        ElseIf cDesc == "Limpeza externa do baÃº"
                            cLimpExt  := iif(alltrim(cResul)=="c","S","N")
                        ElseIf cDesc == "Tempera 0 â„ƒ"
                            cDesc       := "Temperatura"
                            cTempBau    := iif(alltrim(cResul)=="c","S","N")
                        ElseIf cDesc == "Borracha de vedaÃ§Ã£o das portas"
                            cBorrach    := iif(alltrim(cResul)=="c","S","N")
                        ElseIf cDesc == "Equipamento de frio adequado"
                            cEquipFr  := iif(alltrim(cResul)=="c","S","N")
                        elseif cDesc == "DobradiÃ§as e trancas das portas"
                            cTraDobr  := iif(alltrim(cResul)=="c","S","N")
                        elseif cDesc == "Tara do Conteiner"
                            cTaraCo := cResul
                        elseif cDesc == "NÂº TermÃ³grafo:"
                            cTermog := cResul
                        EndIf

                        aAnexos := oElemento["inspection"]["attachements"] //Anexos.

                        //Donwload de anexos.
                        aImagens := {}
                        For nAux3 := 1 To Len(aAnexos)
                            oAnexo := aAnexos[nAux3]
                    
                            //
                            If oAnexo:hasProperty("url")
                                cUrlAnx := oAnexo["url"]
                                cCompon := oAnexo["component"]
                                cDescAnx:= StrTran(StrTran(cDesc,Chr(13)," "),Chr(10)," ")
                                downImg(cUrlAnx, cToken, dParData, @aImagens, cInspId, cDescAnx, cCompon)
                            EndIf

                        Next nAux3
                        
                        //
                        If ! oElemento["inspection"]:hasProperty("extraData")
                            //Id da inspeção, descrição da foto, caminho relativo.
                            fGrvImg(cPdVend, "", "", "", aImagens)
                                    
                            Loop

                        else

                            If !oElemento["inspection"]['extraData']:hasProperty("pallet")
                                Loop

                            endif

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
                                    
                                    grvDados(cInspId, cMonQua, cAprQua, dDatApr, cHorApr, cDtRot, cRot, cPdVend, cPlaca, cCarga, cConte, cPalId, cProd, cProdEdt, nTotCx, nTotKg,;
                                            nTotKgR, nTotTara, cTurno, cDtFab, cDtVal, cTemp, cLacreSIF, cLacreArm, dDtICar, dDtTCar, cHrICar, cHrTCar,;
                                            cLacData, cLacHora, cLimpInt, cLimpExt, cTempBau, cBorrach, cEquipFr, cTraDobr, cDtIQld,cHrIQld, cHrTQld,;
                                            cTaraCo, cTermog, aImagens)
                                    
                                Next nAux4
                                
                            End Transaction

                        endif
                    
                Next nAux2

                cMens += cEOL+" -(Importado) Ped. Venda "+cPdVend+", ID Inspeção "+cInspId +": Inspeção importada."

            else
                u_GrLogZBE(Date(),TIME(),cUserName,"Inspeção da Qualidade Pedido de Venda "+ cPdVend +", ID "+ cInspId +" ","SIGAEEC","ADQUA002",;
			        "procRes - Inspeção da qualidade do Pedido de Venda "+ cPdVend +", ID  "+ cInspId +;
                    ". Inspeção não importada por a carga estar em aberto no eData "+ cCarga +". ",ComputerName(),LogUserName())
            endif
        else 
            u_GrLogZBE(Date(),TIME(),cUserName,"Inspeção da Qualidade Pedido de Venda "+ cPdVend +", ID "+ cInspId +" ","SIGAEEC","ADQUA002",;
			        "procRes - Inspeção da qualidade do Pedido de Venda "+ cPdVend +", ID  "+ cInspId +;
                    ". Opção selecionada pelo usuário não permite a atualização dos registros gravados. ",ComputerName(),LogUserName())
            
            cPdVend := fGetPV(cInspId)

            cMens += cEOL+" -(Processado) Ped. Venda "+cPdVend+", ID Inspeção "+cInspId +": Inspeção já importada."
        endif
    Next nAux

    //
    FreeObj(oJson)
	oJson := Nil
    RestArea(aArea)

Return Nil

Static function fGetPV(cInspId)
    Local cRet := ""

    BeginSQL Alias "QPV"
        %NoPARSER%
        SELECT DISTINCT ZEX_NUMERO
        FROM %TABLE:ZEX%
        WHERE ZEX_ID = %EXP:cInspId% AND D_E_L_E_T_ = ''
    EndSQl
    
    if QPV->(!EOF())
        cRet := QPV->ZEX_NUMERO
    else
        cRet := ""
    endif

    QPV->(Dbclosearea())


return cRet

Static Function fStEData(aElementos, cMens, cPdVend, cCarga, dDtICar, dDtTCar, cHrICar, cHrTCar)
    Local lRet          := .F.
    Local nAuxZ         := 0
    Local nElementos    := Len(aElementos)

    cPdVend := ""
    cCarga  := ""
    dDtICar := Stod("")
    dDtTCar := sTod("")
    cHrICar := ""
    cHrTCar := ""

    For nAuxZ := 1 To nElementos
                
        //
        oElemento := aElementos[nAuxZ]
        
        //
        If !oElemento:hasProperty("inspection")
            Loop

        EndIf
        
        cDesc  := Alltrim(cValToChar(oElemento["value"])) //Descrição do elemento inspecionado.
        cResul := Alltrim(cValToChar(oElemento["inspection"]["value"])) //Resultado da inspeção.

        //
        If cDesc == "Pedido"
            cPdVend := cResul
        ElseIf cDesc == "Carga"
            cCarga := cResul
        endif

        if !Empty(cPdVend) .AND. !Empty(cCarga)
            nAuxZ := nElementos+1
        endif
        
    next nAuxZ

    if !Empty(cPdVend) .AND. !Empty(cCarga)

        DbSelectArea("SC5")
        SC5->(DbSetOrder(1))

        IF SC5->(Dbseek(xFilial("SC5")+cPdVend,.F.))

            if Empty(SC5->C5_NOTA) .OR. lImpFat
            //if .t.

                //Mudar para o parâmetro cStatCar para filtrar pelo status do campo FL_STATCARGEXPE.
                BeginSQL Alias "QSTED"
                    %NoPARSER%
                    SELECT TOP 1 EMPRESA, 
                                FILIAL, 
                                ID_CARGEXPE, 
                                FL_STATCARGEXPE,
                                DT_FECHCARG,
                                HR_FECHCARG,
                                DT_ABERTCARG,
                                HR_ABERTCARG 
                    FROM [LNKMIMS].[SMART].[dbo].[VW_EXPECARG_02] 
                    WHERE ID_CARGEXPE = %EXP:cCarga% AND FL_STATCARGEXPE NOT IN ('AB')
                    
                EndSQl
                
                if QSTED->(!EOF())
                    dDtICar := cTod(QSTED->DT_ABERTCARG)
                    dDtTCar := cTod(QSTED->DT_FECHCARG)
                    cHrICar := QSTED->HR_ABERTCARG
                    cHrTCar := QSTED->HR_FECHCARG

                    lRet := .T.
                endif

                QSTED->(Dbclosearea())

            else
                cMens += cEOL+" -(Rejeitado) Ped. Venda "+cPdVend+" já faturado e não é possível reprocessar."
            endif

        else
            cMens += cEOL+" -(Rejeitado) Ped. Venda "+cPdVend+"não encontrado."
        endif

    else
        cMens += cEOL+" -(Rejeitado) Ped. Venda "+cPdVend+" não encontrado."
    endif

return lRet


/*/{Protheus.doc} downImg
    Faz download de imagens.
    @type  Static Function
    @author Everson
    @since 31/05/2021
    @version 01
    /*/
Static Function downImg(cUrlAnx, cToken, dParData, aImagens, cInspId, cDescAnx, cCompon)
    
    //Variáveis.
    Local aArea         := GetArea()
    Local cErro         := ""
    Local cResponse     := ""
    Local lWait         := .T.
    Local aUrl          := Separa(cUrlAnx,"/",.F.)
    Local cArq          := Alltrim(cValToChar(aUrl[Len(aUrl)]))
    Local cComm         := ""
    Local cRotDir       := GetSrvProfString ("ROOTPATH","")
    PRivate cPasta      := Alltrim(SuperGetMV("ZZ_QUA002H",,"\fotos_inspecoes_qualidade\")) //Criar Mv.
    Private cPastaLoc   := cPasta+"temp\" //Criar Mv.

    //
    If ! consulta(@ cErro, cToken, @cResponse, dParData, cUrlAnx, "")
		cErro := "Ocorreu erro ao baixar o arquivo " + cUrlAnx
        Conout("ADQUA002 - downImg - cErro " + cErro)
		RestArea(aArea)
		Return .F.

    EndIf 

    If  !lIsDir(cPastaLoc)
        fMakeDir(cPastaLoc)
    endif
    
    // Transfere o executável do aplicativo zipado para a pasta local.
    //MsAguarde({|| fTraZip() }, "Processando", "Importando arquivos para tratamento das imagens.")
    
    //Grava o arquivo de imagem na pasta local para ser reduzido o tamanho da imagem pelo aplicativo Magick.
    MemoWrite(cPastaLoc + cArq, cResponse)
    if file("ImageMagick\magick.exe")
        cComm := cRotDir+"\ImageMagick\magick.exe mogrify -resize 25% "+cRotDir+cPastaLoc + cArq 
        WaitRunSrv(cComm, lWait,"c:\" )
    endif

    // Transfere o arquivo redimensionado para a pasta do servidor e grava na array que irá registrar na tabela do BD.
    
    //if CpyT2S(cPastaLoc+cArq, cPasta, .F., .F. )
    if __CopyFile(cPastaLoc+cArq, cPasta+cArq,,,.F.)
        Aadd(aImagens,{cInspId, cPasta + cArq, cDescAnx, cCompon})
        fErase(cPastaLoc+cArq)
    endif
    
    RestArea(aArea)

Return .T.
/*
Static function fTraZip()

    if !file(cPastaLoc+"ImageMagick\magick.exe")
        CpyS2T(cPasta+"ImageMagick\ImageMagick.zip", cPastaLoc, .F., .F. )
        FUnzip(cPastaLoc+"\ImageMagick.zip",cPastaLoc)
    endif
return
*/
Static Function fMakeDir(cPath)
	Local lret 			:= .T.
	Local aFolder		:= {}
	Local nC				:= 0
	Local cDirDoc	:= ""
	
	If  !lIsDir(cPath)
		// Quebra o caminho em Paths.
		aFolder	:= Separa(cPath,"\",.f.)
		cDirDoc	:= ""
		// Recria arquivos.		
		For nC := 1 TO Len(aFolder)
			cDirDoc += IIF(!":"$aFolder[nC],"\","") + Alltrim(aFolder[nC])	
			If  !lIsDir(cDirDoc)
				If MakeDir(cDirDoc) != 0
					lRet := .F.
				EndIf
			EndIf
		Next nC	

	EndIf

Return lRet

/*/{Protheus.doc} grvDados
    Grava Dados.
    @type  Static Function
    @author Everson
    @since 31/05/2021
    @version 01
    /*/
Static Function grvDados(cInspId, cMonQua, cAprQua, dDatApr, cHorApr, cDtRot, cRot, cPdVend, cPlaca, cCarga, cConte, cPalId, cProd, cProdEdt, nTotCx, nTotKg,;
                        nTotKgR, nTotTara, cTurno, cDtFab, cDtVal, cTemp, cLacreSIF, cLacreArm, dDtICar, dDtTCar, cHrICar, cHrTCar,;
                        cLacData, cLacHora, cLimpInt, cLimpExt, cTempBau, cBorrach, cEquipFr, cTraDobr, cDtIQld,cHrIQld, cHrTQld,;
                        cTaraCo, cTermog, aImagens)

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

            //Faz a correção na variável vinda do aplicativo.
            //Revisar depois com o Everson.
            
            if Reclock("ZEX",.T.)
                ZEX_FILIAL  := SC5->C5_FILIAL
                ZEX_NUMERO  := SC5->C5_NUM //cPdVend - Pedido de venda.
                ZEX_ID      := cInspId      //Id da inspeção.
                ZEX_ROTEDT  := Ctod(cDtRot) //Data do roteiro.
                ZEX_ROTEIR  := cRot         //Roteiro.
                ZEX_PLACA   := cPlaca       //Placa.
                ZEX_CARGA   := cCarga       //Carga.
                ZEX_CONTAI  := cConte       //Conteiner.
                ZEX_PALLET  := cPalId       //Id do palete.
                ZEX_PRODUT  := cProd        //Código produto Protheus.
                ZEX_EDTPRD  := cProdEdt     //Código produto Edata. 
                ZEX_QTDSUM  := nTotCx       //Total em caixas.
                ZEX_QUANTI  := nTotKg       //Total em Kg.
                ZEX_QTDREA  := nTotKgR      //Total em Kg real.
                ZEX_TARAEM  := nTotTara     //Total tara das embalagens.
                ZEX_TURNO   := cTurno       //Turno.
                ZEX_DTFABR  := stod(cDtFab) //Data de fabricação.
                ZEX_DTVALD  := Ctod(cDtVal) //Data de validade.
                ZEX_TEMPER  := Val(cTemp)   //Temperatura.
                ZEX_LACRE1  := cLacreArm    //Lacre Armador
                ZEX_LACRE2  := cLacreSIF    //Lacre SIF
                ZEX_DTICAR  := dDtICar      //Data de início carregamento.
                ZEX_DTTCAR  := dDtTCar      //Data de término carregamento.
                ZEX_HRICAR  := cHrICar      //Hora de início de carregamento.
                ZEX_HRTCAR  := cHrTCar      //Hora de término do carregamento.
                ZEX_DTLACR  := ctod(cLacData) //Data do lacre.
                ZEX_HRLACR  := cLacHora     //Hora do lacre.
                ZEX_LIMPIN  := cLimpInt     //Limpeza interna.
                ZEX_LIMPEX  := cLimpExt     //Limpeza Externa.
                ZEX_TEMPBA  := cTempBau     //Temperatura do baú.
                ZEX_BORRAC  := cBorrach     //Borracha de vedação.
                ZEX_EQUIPF  := cEquipFr     //Equipamento de frio conforme.
                ZEX_TRADOB  := cTraDobr     //Dobradiças e trancas das portas.
                ZEX_DTIQLD  := Ctod(cDtIQld)      //Data de início da qualidade.
                ZEX_HRIQLD  := cHrIQld      //Hora de início da qualidade.
                ZEX_HRTQLD  := cHrTQld      //Hora de término da qualidade.
                ZEX_MONQUA  := cMonQua
                ZEX_APRQUA  := cAprQua
                ZEX_APRDAT  := dDatApr
                ZEX_APRHOR  := cHorApr
                ZEX_TARCON  := Val(cTaraCo)
                ZEX_TERMOG  := cTermog
                ZEX_LOGDAT  := Date()
                ZEX_LOGHOR  := Time()
                ZEX_LOGUSR  := __CUSERID
                ZEX->(Msunlock())
            endif

            //Id da inspeção, descrição da foto, caminho relativo.
            fGrvImg(cPdVend, cPalId, cTurno, cProd, aImagens)
            //Grava os dados detalhados do Pallet.
            fGrvDet(cPdVend, cInspId, cPalId, cTurno)
        endif
    endif
    
Return Nil


Static function fGrvDet(cPdVend, cInspId, cPalId, cTurno)
    Local cQuery    := ""
    Local cEOL      := Chr(13)+chr(10)

    DbSelectArea("ZGB")
    ZGB->(DbSetOrder(1))

    cQuery := " SELECT * "+cEOL
    cQuery += " FROM "+ RetSqlName("ZGA") +" ZGA "
    cQuery += " WHERE D_E_L_E_T_='' AND ZGA_FILIAL='"+ xFilial("ZGA") +"' AND ZGA_PALLET = '"+ cPalId +"' AND ZGA_TURNO = '"+ cTurno +"' "

    TcQuery cQuery ALIAS "QZGA" NEW

    while QZGA->(!eof())
        
        if Reclock("ZGB", .T.)
            ZGB->ZGB_FILIAL := xFilial("ZGB")
            ZGB->ZGB_ID     := cInspId
            ZGB->ZGB_NUMERO := cPdVend
            ZGB->ZGB_PRODUT := QZGA->ZGA_PRODUT
            ZGB->ZGB_EDTPRD := QZGA->ZGA_EDTPRD
            ZGB->ZGB_DTFABR := Stod(QZGA->ZGA_DTFABR)
            ZGB->ZGB_DTVALD := Stod(QZGA->ZGA_DTVALD)
            ZGB->ZGB_TURNO  := QZGA->ZGA_TURNO
            ZGB->ZGB_QUANTI := QZGA->ZGA_QUANTI
            ZGB->ZGB_QTDREA := QZGA->ZGA_QTDREA
            ZGB->ZGB_TARAEM := QZGA->ZGA_TARAEM
            ZGB->ZGB_LOTE   := QZGA->ZGA_LOTE
            ZGB->ZGB_IDENTI := QZGA->ZGA_IDENTI
            ZGB->ZGB_TOTSEG := QZGA->ZGA_TOTSEG
            ZGB->ZGB_DTPALL := Stod(QZGA->ZGA_DTPALL)
            ZGB->ZGB_TOTQTD := QZGA->ZGA_TOTQTD
            ZGB->ZGB_TOTREA := QZGA->ZGA_TOTREA
            ZGB->ZGB_TOTTAR := QZGA->ZGA_TOTTAR
            ZGB->ZGB_STATUS := QZGA->ZGA_STATUS
            ZGB->ZGB_PALLET := QZGA->ZGA_PALLET
            ZGB->ZGB_QTDSUM := QZGA->ZGA_QTDSUM
            ZGB->ZGB_LOGDAT := Stod(QZGA->ZGA_LOGDAT)
            ZGB->ZGB_LOGHOR := QZGA->ZGA_LOGHOR

            ZGB->(MsUnlock())
        endif
    QZGA->(DbSkip())
    ENDDO

    QZGA->(Dbclosearea())

return

/* fGrvImg - Registra as imagens na tabela. */
Static Function fGrvImg(cPdVend, cPalId, cTurno, cProd, aImagens)
    Local nA        := 1
    Local nArqTot   := {}
    Private cDescri := ""
    Private cDesTmp := ""

    DbselectArea("SC5")
    SC5->(DbSetOrder(1))

    IF SC5->(Dbseek(xFilial("SC5")+cPdVend,.F.))
        IF SC5->C5_NUM == cPdVend
    
            nArqTot := Len(aImagens)
            
            for nA := 1 To nArqTot

                cDesTmp := DecodeUTF8(aImagens[nA][03], "cp1252")

                if Type("cDesTmp") == "C"
                    cDescri := alltrim(cDesTmp)
                else
                    cDescri := Alltrim(aImagens[nA][03])
                endif
            
                If Reclock("ZEY",.T.)
                    ZEY_FILIAL  := SC5->C5_FILIAL
                    ZEY_NUMERO  := SC5->C5_NUM
                    ZEY_ID      := aImagens[nA][01]
                    //ZEY_PALLET  := cPalId
                    //ZEY_TURNO   := cTurno
                    ZEY_PRODUT  := cProd
                    ZEY_ARQUIV  := aImagens[nA][02]
                    ZEY_DESCRI  := cDescri
                    ZEY_COMPON  := aImagens[nA][04]
                    ZEY->(Msunlock())
                endif
        
            next nA

        endif

    endif
return

Static Function fProcessa(cInspId, nReproc, nReg)
    Local lRet      := .T.
    
    nReg      := fRegistro(cInspId)
    
    DbSelectArea("ZEX")

    if nReproc == 1
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

    cQuery := "SELECT R_E_C_N_O_ REGISTRO FROM "+RetSqlName("ZGB")+" (NOLOCK) WHERE D_E_L_E_T_='' AND ZGB_FILIAL='"+ xFilial("ZGB") +"' AND ZGB_ID ='"+ cInspId +"';"
    
    TcQuery cQuery ALIAS "QZGB" NEW

    while QZGB->(!eof())
        ZGB->(DbGoTo(QZGB->REGISTRO))

        if ZGB->(RECNO()) == QZGB->REGISTRO
            If reclock("ZGB",.F.)
                Dbdelete()
                ZGB->(Msunlock())
            endif
        endif

        QZGB->(Dbskip())
    enddo

    QZGB->(DbCloseArea())
Return lRet
