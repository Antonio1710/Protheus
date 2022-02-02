//Bibliotecas
#Include "Protheus.ch"
#Include "TBIConn.ch" 
#Include "Topconn.ch"
#Include "Colors.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch" 

/*/{Protheus.doc} ADSAG002P
Job para importação automática de
remessa para integrado (SAG). Chamado 058120.
    Movimentos:
        1-Saída por devolução
        2-Saída por trans. filial
        3-Saída por trans. integrado
        4-Remessa para integrado
        5-Frango 3 transmissão propriedade
        6-Saída frango vivo apanha
        7-Saída trans. armazém
        8-Saída por venda
        9-Corte pedido de venda
        10-Venda/Remessa a ordem
        11-Revenda
@author Everson
@since 22/05/2020
@version 1.0
@history Everson - 28/05/2020. Chamado  058120. Adiconado consulta da situação da nota fiscal.
/*/
User Function ADSAG002P() // U_ADSAG002P()  

    //Variáveis.
    Local aMovSd := {4} //movimentos que serão processados. 
    Local nAux   := 1
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Job para importação automática de remessa integrado (SAG')
	

	//Inicia o ambiente.
	RPCSetType(3)
	RpcSetEnv("01","03",,,,GetEnvServer(),{ })

        //
        Conout( DToC(Date()) + " " + Time() + " ADSAG002P - Início Job " )

		//
		execBat()

		//
        For nAux := 1 To Len(aMovSd)
		    remesInt(aMovSd[nAux])

        Next nAux

        //
        Conout( DToC(Date()) + " " + Time() + " ADSAG002P - Fim Job " )

	//Fecha o ambiente.
	RpcClearEnv()

Return Nil
/*/{Protheus.doc} remesInt
    Gera pedido de compra de remessa para integrado.
    @type  Static Function
    @author Everson
    @since 22/05/2020
    @version 01
    /*/
Static Function remesInt(nOpc)

	//Variáveis.
    Local aArea         := GetArea()
	Local aNFTrans		:= {}
    Local nAux          := 1
    Local cIdent        := "" //Everson - 28/05/2020. Chamado  058120.
    
    //
    Conout( DToC(Date()) + " " + Time() + " ADSAG002P - remesInt - movimento - nOpc " + cValToChar(nOpc) )

	//
	aNFTrans := StaticCall(INTEPEDB,telProcess,nOpc,.T.)

    //
    cIdent := RetIdEnti() //Everson - 28/05/2020. Chamado  058120.

    //
    If Len(aNFTrans) > 0

        //
        For nAux := 1 To Len(aNFTrans)

            //
            Conout( DToC(Date()) + " " + Time() + " ADSAG002P - remesInt - sleep - 5000 ")
            Sleep(5000)

            //
            cNota := Alltrim(cValToChar(aNFTrans[nAux][1]))
            cSerie:= Alltrim(cValToChar(aNFTrans[nAux][2]))

            //
            Conout( DToC(Date()) + " " + Time() + " ADSAG002P - remesInt - Nota gerada " + cNota + cSerie )
            logZBE("Nota gerada " + cNota + cSerie)

            //
            geraDanfe(cNota, cSerie, cIdent) //Everson - 28/05/2020. Chamado  058120.

        Next nAux

    EndIf

    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} geraDanfe
    Gera Danfe.
    @type  Static Function
    @author Everson
    @since 22/05/2020
    @version 01
    /*/
Static Function geraDanfe(cNota, cSerie, cIdent)

    //Variáveis.
    Local aArea         := GetArea()
    Local oDanfe        := Nil
    Local lEnd          := .F.
    Local cArquivo      := Alltrim(cNota) + Alltrim(cSerie) + ".rel" 
    Local cPasta        := "\notas_integracao\"
    Local lExistNFe     := .F.
    Local nCount1       := 10
    Local nCount2       := 1
    Local cCodNF        := ""

	//
    Private PixelX      := Nil
    Private PixelY      := Nil
    Private nConsNeg    := 0
    Private nConsTex    := 0
    Private oRetNF      := Nil
    Private nColAux     := 0

    //
    Conout( DToC(Date()) + " " + Time() + " ADSAG002P - geraDanfe - Gera Danfe cIdent/cNota/cSerie " + cValToChar(cIdent) + " " + cValToChar(cNota) + cValToChar(cSerie) )
    logZBE("Gera Danfe " + cNota + cSerie)

    //
    DbSelectArea("SF2")
    SF2->(DbSetOrder(1))
    If ! SF2->(DbSeek( FWxFilial("SF2") + cNota + cSerie ))
        Conout( DToC(Date()) + " " + Time() + " ADSAG002P - geraDanfe - Gera Danfe - nota fiscal não localizada SF2 cIdent/FWxFilial('SF2')/cNota/cSerie " + cIdent + " " + FWxFilial("SF2") + " " + cNota + cSerie)

    EndIf

    //Everson - 28/05/2020. Chamado  058120.
    While ! (cCodNF $"001/007/008/018") .And. nCount2 < nCount1
        cCodNF := chkStatus(cIdEnt,SF2->F2_DOC ,SF2->F2_DOC ,SF2->F2_SERIE)
        Conout( DToC(Date()) + " " + Time() + " ADSAG002P - geraDanfe - cCodNF " + cCodNF )
        nCount2++
        Sleep(10000)

    End

    //
    If cCodNF <> "001"
        Conout( DToC(Date()) + " " + Time() + " ADSAG002P - geraDanfe - Gera Danfe - nota fiscal não autorizada SF2 cIdent/FWxFilial('SF2')/cNota/cSerie/cCodNF " +;
                cIdent + " " + FWxFilial("SF2") + " " + cNota + cSerie + " " + cCodNF)
        Return Nil 

    EndIf
        
    //Define as perguntas da DANFE
    Pergunte("NFSIGW",.F.)
    MV_PAR01 := SF2->F2_DOC      //Nota Inicial
    MV_PAR02 := SF2->F2_DOC      //Nota Final
    MV_PAR03 := SF2->F2_SERIE    //Série da Nota
    MV_PAR04 := 2                //NF de Saida
    MV_PAR05 := 2                //Frente e Verso = Nao
    MV_PAR06 := 2                //DANFE simplificado = Nao
        
    //Cria a Danfe
    oDanfe := FWMSPrinter():New( cArquivo, IMP_PDF, .F.,cPasta, .T., .F., , , .T., .T., , .F.)
    oDanfe:SetResolution(78)
    oDanfe:SetPortrait()
    oDanfe:SetPaperSize(DMPAPER_A4)
    oDanfe:SetMargin(60, 60, 60, 60)
    oDanfe:cPathPDF := cPasta           
        
    //Variáveis obrigatórias da DANFE (pode colocar outras abaixo)
    PixelX    := oDanfe:nLogPixelX()
    PixelY    := oDanfe:nLogPixelY()
    nConsNeg  := 0.4
    nConsTex  := 0.5
    oRetNF    := Nil
    nColAux   := 0
        
    //Chamando a impressão da danfe no RDMAKE
    StaticCall(DANFEII, DanfeProc, @oDanfe, @lEnd, cIdent, , , @lExistNFe)

    //
    If ! lExistNFe
        Conout( DToC(Date()) + " " + Time() + "Não há danfe a ser impressa para os parâmetros informados.")

    EndIf

    //
    oDanfe:Print()

    //
    Conout( DToC(Date()) + " " + Time() + " ADSAG002P - geraDanfe - sleep - 10000 ")
    Sleep(10000)

    //
    FreeObj(oDanfe)
    oDanfe := Nil

    //
    Conout( DToC(Date()) + " " + Time() + " ADSAG002P - geraDanfe - Executa bat " + cNota + cSerie)
    logZBE("Executa bat " + cNota + cSerie)

    //
    execBat()
    
    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} execBat
    Copia as notas fiscais para a pasta de impressão.
    @type  Static Function
    @author Everson
    @since 22/05/2020
    @version 01
    /*/
Static Function execBat()

    //Variáveis.
    Local aArea     := GetArea()
    Local cComando  := ""
    Local aFiles    := Directory("\notas_integracao\*.pdf")
    Local nAux      := 1

    //
    Conout( DToC(Date()) + " " + Time() + " ADSAG002P - execBat - Início execução do bat")
    logZBE("Início execução do bat")

    //
    For nAux := 1 To Len(aFiles)

        //
        Conout( DToC(Date()) + " " + Time() + " ADSAG002P - execBat - Copiando arquivo " + aFiles[nAux,1])
        logZBE("Copiando arquivo " + aFiles[nAux,1])

        //
        cComando := 'robocopy D:\totvs\Protheus12\protheus_data\notas_integracao\  \\10.6.3.4\ADORO\TICKET_PDF\ ' + aFiles[nAux,1] + ' /IS /IT /R:0 /W:0 /move /LOG+:D:\totvs\Protheus12\protheus_data\notas_integracao\robocopy.log '

        //
        conout(cComando)
        WaitRunSrv(cComando,.T.,"C:\WINDOWS\system32\")

    Next nAux

    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} chkStatus
    Checa status da nota fiscal de saída.
    @type  Static Function
    @author Everson 
    @since 28/05/2020
    @version 01
    /*/
Static Function chkStatus(cIdEnt,cDocMin,cDocMax,cSerie)

    //Variáveis.
    Local aArea     := GetArea()
    Local oWS       := Nil
    Local cURL      := PadR(GetMv("MV_SPEDURL"),250)
    Local lOk       := .F.
    Local oRetorno  := Nil
    Local nX        := 1
    Local cCodRet   := ""

    //
    If ! CTIsReady()
        Conout( DToC(Date()) + " " + Time() + " impNf - transNf - CTIsReady retornou .F. " )
        RestArea(aArea)
        Return cCodRet 

    EndIf

    //
    oWS:= WSNFeSBRA():New()
    oWS:cUSERTOKEN    := "TOTVS"
    oWS:cID_ENT       := cIdEnt 
    oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"
    oWS:cIdInicial    := cSerie + cDocMin
    oWS:cIdFinal      := cSerie + cDocMax

    //
    lOk := oWS:MONITORFAIXA()
    oRetorno := oWS:oWsMonitorFaixaResult

    //
    For nX := 1 To Len(oRetorno:oWSMONITORNFE)

        //
        If (!Empty(oRetorno:OWSMONITORNFE[nX]:CRECOMENDACAO))
            cCodRet := Alltrim(Substr(oRetorno:OWSMONITORNFE[nX]:CRECOMENDACAO,1,3))

        EndIf

    Next nX

    //
    FreeObj(oWS)
    oWS := Nil 

    //
    RestArea(aArea)

Return cCodRet
/*/{Protheus.doc} logZBE
    Gera log na tabela ZBE.
    @type  Static Function
    @author Everson
    @since 22/05/2020
    @version 01
    /*/
Static Function logZBE(cMensagem,cParame)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea	:= GetArea()

    //
    Default cMensagem := ""
    Default cParame   := ""

	//
	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
		Replace ZBE_FILIAL 	   	With xFilial("ZBE")
		Replace ZBE_DATA 	   	With Date()
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With cMensagem
        Replace ZBE_PARAME      With cParame
		Replace ZBE_MODULO	    With "FATURAMENTO"
		Replace ZBE_ROTINA	    With "ADSAG002P" 
	MsUnlock()

	//
	RestArea(aArea)

Return Nil