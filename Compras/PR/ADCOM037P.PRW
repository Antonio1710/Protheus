#Include "Protheus.ch"
#Include "Topconn.ch"
/*/{Protheus.doc} User Function ADCOM037P
    Job obtém dados de alteração de revisão de embalagens 
	e atualiza o campo de revisão no cadastro do produto.
    Chamado 726.
    @type  Function
    @author Everson
    @since 04/09/2020
    @version 01
    @history, Everson, 11/11/2020, Chamado TI. Tratamento para quando o serviço AWS não retornar a propriedade results.
    /*/
User Function ADCOM037P() // U_ADCOM037P()

	//Inicia o ambiente. 
	RPCSetType(3)
	RpcSetEnv("01","02",,,,GetEnvServer(),{ })

		//
        procAtu()

	//Fecha o ambiente.
	RpcClearEnv()

    //
    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'alteração de revisão de embalagens')
    //

Return Nil
/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author Everson
    @since 04/09/2020
    @version 01
    /*/
Static Function procAtu()

    //Variáveis.
    Local aArea := GetArea()
    Local aDados:= {}

    //Obtém dados de alteração.
    aDados := obtDados()

    //Atualiza registros.
    If Len(aDados) > 0
        uptCad(aDados)

    EndIf

    //
    RestArea(aArea)
    
Return Nil
/*/{Protheus.doc} obtDados
    Obtém dados da API.
    @type  Static Function
    @author Everson
    @since 04/09/2020
    @version 01
    /*/
Static Function obtDados()

    //Variáveis.
    Local oRestClient := FWRest():New("http://controle.adoro.com.br")
    Local cJson       := ""
    Local aRet        := {}        
    Local oObjJ       := Nil  
    Local xRet        := Nil
    Local aResults    := {}
    Local nAux        := 1

    //
    oRestClient:setPath("/api/")

    //
    If ! oRestClient:Get()
        Conout( DToC(Date()) + " " + Time() + " ADCOM037P - obtDados - [ERRO] " + oRestClient:GetLastError())
        Return aRet

    Endif

    //
    cJson := oRestClient:GetResult()
    Conout( DToC(Date()) + " " + Time() + " ADCOM037P - obtDados - [JON] " + cJson)

    //
    oObjJ := JsonObject():New()
    xRet := oObjJ:FromJson(cJson)
    If ! ValType(xRet) == "U"
        Conout( DToC(Date()) + " " + Time() + " ADCOM037P - obtDados - erro conversão para objeto " + cValToChar(xRet))
        Return aRet

    EndIf
    
    //
    aResults := oObjJ:GetJsonObject("results")

    //
    If  aResults <> Nil //Everson - 11/11/2020. Chamado TI.

        //
        For nAux := 1 To Len(aResults)
            cStatus := aResults[nAux]:GetJsonText("status")
            cDesc   := Alltrim(aResults[nAux]:GetJsonText("description"))
            cVersao := Alltrim(cValToChar(aResults[nAux]:GetJsonText("version")))
            cCodPdt := Alltrim(Substr(cDesc,1,At("-",cDesc,1)-1))
            cCodPdt := Iif(At(" ",cCodPdt,1) <= 0,cCodPdt,Alltrim(Substr(cDesc,1,At(" ",cCodPdt,1)-1)))

            //
            Aadd(aRet,{cStatus,cDesc,cVersao,cCodPdt})

        Next nAux

    EndIf

    //
    Varinfo("aRet",aRet)
    
    //
    FreeObj(oObjJ)
    oObjJ := Nil
    
    //
    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
    //

Return aRet
/*/{Protheus.doc} uptCad
    Atualiza descrição do produto.
    @type  Static Function
    @author Everson
    @since 04/09/2020
    @version 01
    /*/
Static Function uptCad(aDados)

    //Variáveis.
    Local aArea := GetArea()
    Local nAux  := 1
    Local cRev  := ""

    //
    DbSelectArea("SB1")
    SB1->(DbSetOrder(1))
    SB1->(DbGoTop())

    //
    For nAux := 1 To Len(aDados)

        //
        If SB1->( DbSeek( FWxFilial("SB1") + aDados[nAux][4] ) )

            //
            cRev :=  Alltrim(cValToChar(aDados[nAux][3]))

            //
            Conout( DToC(Date()) + " " + Time() + " ADCOM037P - uptCad - produto/revisão " + Alltrim(aDados[nAux][4]) + " / " + cRev )

            //
            RecLock("SB1",.F.)
                SB1->B1_REVATU := cRev
            SB1->(MsUnlock())

        Else 
            Conout( DToC(Date()) + " " + Time() + " ADCOM037P - uptCad - produto não encontrado SB1 " + cValToChar(aDados[nAux][4])) 

        EndIf

    Next nAux

    //
    RestArea(aArea)

Return Nil
