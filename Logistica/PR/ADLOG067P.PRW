#Include "Protheus.ch"
#Include "Topconn.ch"   
#Include "FWMVCDef.ch"
/*/{Protheus.doc} User Function ADLOG067P
    Gera lançamento de ocorrência de frete na tabela ZFA.
    @type  Function
    @author Everson
    @since 20/01/2020
    @version 01
    @history Everson, 17/02/2020, Chamado 054941. Tratamento para gravar volume.
    /*/
User Function ADLOG067P(cEmpAnt , cFilAnt , F2DOC , F2SERIE , F2CLIENTE , F2LOJA  , C5NUM , cOpc , C5DTENTR, lStorFr, lAutoJob,cTpCrg)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
    Local aArea     := GetArea()

    //
    Conout( DToC(Date()) + " " + Time() + " ADLOG067P - cOpc " + cValToChar(cOpc) )

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gera lançamento de ocorrência de frete na tabela ZFA.')

    //
    If cOpc == "1"
        processa(cEmpAnt , cFilAnt , F2DOC , F2SERIE , F2CLIENTE , F2LOJA  , C5NUM , cOpc , C5DTENTR, lStorFr, lAutoJob,cTpCrg)

    ElseIf cOpc == "2"

    EndIf

    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} processa
    Processa geração de frete.
    @type  Static Function
    @author Everson
    @since 20/01/2020
    @version 01
    /*/
Static Function processa(cEmpAnt , cFilAnt , F2DOC , F2SERIE , F2CLIENTE , F2LOJA  , C5NUM , cOpc , C5DTENTR, lStorFr, lAutoJob,cTpCrgP)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
    Local aArea         := GetArea()
    Local cQuery        := ""   
    Local cNumCrg       := "" 
    Local cOcOvo        := Alltrim(GetMv("MV_#FRTOVO"))
    Local cOcPint       := Alltrim(GetMv("MV_#FRTPIN"))

    //
    Private cOcorre     := ""
    Private cDescOcor   := ""
    Private cDCOcor     := ""
    Private lInser      := .T.
    Private cCarga      := Nil
    Private dDtEntr     := Nil
    Private nNumEnt     := Nil
    Private cPlaca      := Nil
    Private cCodTran    := Nil
    Private cLjTran     := Nil
    Private cNmTran     := Nil
    Private nKm         := Nil
    Private nPesoL      := Nil
    Private nPesoB      := Nil
    Private nVolume     := Nil //Everson - 17/02/2020. Chamado 054941.
    Private cTabFrt     := Nil
    Private cDescTab    := Nil
    Private nVlr        := Nil
    Private cOrigem     := Nil
    Private cTpCrg      := cTpCrgP

    //
    Conout( DToC(Date()) + " " + Time() + " ADLOG067P C5NUM " + C5NUM )

    //
    If cTpCrg == "3"
        cOcorre := cOcOvo

    ElseIf cTpCrg == "4"
        cOcorre := cOcPint

    Else
        Conout( DToC(Date()) + " " + Time() + " ADLOG067P - Não localizou tipo de carga - cTpCrg " + cTpCrg )
        RestArea(aArea)
        Return Nil 

    EndIf

    //
    DbSelectArea("ZFD")
    ZFD->(DbSetOrder(5))
    ZFD->(DbGoTop())
    If ! ZFD->( DbSeek( FWxFilial("ZFD") + C5NUM ) )
        Conout( DToC(Date()) + " " + Time() + " ADLOG067P - Pedido de venda não encontrado " + C5NUM )
        RestArea(aArea)
        Return Nil 

    EndIf   

    //
    If Empty(F2DOC) .Or. Empty(F2SERIE)
        Conout( DToC(Date()) + " " + Time() + " ADLOG067P - Não recebeu NF ou série " + F2DOC + " / " + F2SERIE )
        RestArea(aArea)
        Return Nil 

    EndIf

    //
    If Alltrim(ZFD->ZFD_FEZNF) == "S"
        Conout( DToC(Date()) + " " + Time() + " ADLOG067P - nota fiscal já processada " + F2DOC + " / " + F2SERIE )
        RestArea(aArea)
        Return Nil 

    EndIf

    //
    Begin Transaction

        //
        RecLock("ZFD",.F.)
            ZFD->ZFD_NUMNF := F2DOC
            ZFD->ZFD_SERIE := F2SERIE
            ZFD->ZFD_FEZNF := "S"
        ZFD->(MsUnlock())

        //
        cNumCrg := Alltrim(cValToChar(ZFD->ZFD_COD))

        //
        cDescOcor   := Posicione("ZF7",1,FWxFilial("ZF7") + cOcorre, "ZF7_DESC")
        cDCOcor     := Posicione("ZF7",1,FWxFilial("ZF7") + cOcorre, "ZF7_DBCD")

        //
        DbSelectArea("ZFA")
        ZFA->(DbSetOrder(1))
        ZFA->(DbGoTop())
        If ZFA->( DbSeek( FWxFilial("ZFA") + cNumCrg ) )
            cZFACod := Alltrim(ZFA->ZFA_COD)
            lInser   := .F.     

        EndIf

        //
        cQuery := sqlZFD(cNumCrg,cTpCrg)

        //
        If Select("D_ZFD") > 0
            D_ZFD->(DbCloseArea())

        EndIf

        //
        TcQuery cQuery New Alias "D_ZFD"
        DbSelectArea("D_ZFD")
        D_ZFD->(DbGoTop())
        If D_ZFD->(Eof())
            Conout( DToC(Date()) + " " + Time() + " ADLOG067P - carga não localizada cNumCrg/cTpFrt" + cNumCrg + " / " + cTpCrg )
            D_ZFD->(DbCloseArea())
            RestArea(aArea)
            Return Nil  
            
        EndIf

        //
        cCarga  := Alltrim(D_ZFD->ZFD_COD)
        dDtEntr := SToD(D_ZFD->ZFD_DTENTR)
        nNumEnt := D_ZFD->NUMENT
        cPlaca  := Alltrim(D_ZFD->ZFD_CAMINH)
        cCodTran:= Alltrim(D_ZFD->ZFD_TRANSP)
        cLjTran := Alltrim(D_ZFD->ZFD_LOJTRA)
        cNmTran := Alltrim(D_ZFD->ZFD_NOMTRA)
        nKm     := D_ZFD->ZFD_KMGER 
        nPesoL  := D_ZFD->C5_PESOL
        nPesoB  := D_ZFD->C5_PBRUTO
        nVolume := D_ZFD->C5_VOLUME1 //Everson - 17/02/2020. Chamado 054941.
        cTabFrt := ""
        cDescTab:= ""
        nVlr    := D_ZFD->ZFD_VLRFRT
        cOrigem := "ADLOG067P"

        //
        grvZFA()

    End Transaction

    //
    D_ZFD->(DbCloseArea())

    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} nomeStaticFunction
    Grava lançamento na tabela ZFA.
    @type  Static Function
    @author Everson
    @since 20/01/2020
    @version 01
    /*/
Static Function grvZFA()
	
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
    Local aArea     := GetArea()
    Local lRet      := .T.

    //
	Private oModel 		:= Nil
	Private lMsErroAuto := .F.
	Private aRotina 	:= {}

    //
	Begin Transaction

        //
        Conout( DToC(Date()) + " " + Time() + " ADLOG067P - grvZFA - lInser " + cValToChar(lInser) )
        Conout( DToC(Date()) + " " + Time() + " ADLOG067P - grvZFA - cPlaca " + cValToChar(cPlaca) )

        //
        oModel:= FwLoadModel ("ADLOG040P")

        //
        If lInser
            oModel:SetOperation(MODEL_OPERATION_INSERT)

        Else
            oModel:SetOperation(MODEL_OPERATION_UPDATE)

        EndIf
        
        //
        oModel:Activate() 

        //
        oModel:SetValue("ZFAMASTER","ZFA_VA"		,cTpCrg)
        oModel:SetValue("ZFAMASTER","ZFA_TPMOV"  	,"A")

        //
        If ! lInser
            oModel:SetValue("ZFAMASTER","ZFA_COD"	,cZFACod)         
            
        EndIf

        //
        oModel:SetValue("ZFAMASTER","ZFA_CARGA"	  	,cCarga)
        oModel:SetValue("ZFAMASTER","ZFA_DTENTR"	,dDtEntr)
        oModel:SetValue("ZFAMASTER","ZFA_ROTEIR"	,cCarga)
        oModel:SetValue("ZFAMASTER","ZFA_NUMENT"	,nNumEnt)
        oModel:SetValue("ZFAMASTER","ZFA_VEICUL"	,cPlaca)
        oModel:SetValue("ZFAMASTER","ZFA_TRANSP"	,cCodTran)
        oModel:SetValue("ZFAMASTER","ZFA_LOJTRA"	,cLjTran)
        oModel:SetValue("ZFAMASTER","ZFA_NMTRAN"	,cNmTran)
        oModel:SetValue("ZFAMASTER","ZFA_KMTOT"		,nKm)
        oModel:SetValue("ZFAMASTER","ZFA_CARKG"		,nPesoL)
        oModel:SetValue("ZFAMASTER","ZFA_KGBT"		,nPesoB)
        oModel:SetValue("ZFAMASTER","ZFA_CARCX"		,nVolume) //Everson - 17/02/2020. Chamado 054941.
        oModel:SetValue("ZFAMASTER","ZFA_TABFRT"	,cTabFrt)
        oModel:SetValue("ZFAMASTER","ZFA_DSCFRT"	,cDescTab)
        oModel:SetValue("ZFAMASTER","ZFA_TPFRT"		,"C")
        oModel:SetValue("ZFAMASTER","ZFA_DATA"	  	,dDtEntr)
        oModel:SetValue("ZFAMASTER","ZFA_OCORRE"  	,cOcorre)
        oModel:SetValue("ZFAMASTER","ZFA_DESCOC"  	,cDescOcor)
        oModel:SetValue("ZFAMASTER","ZFA_DC"		,cDCOcor)
        oModel:SetValue("ZFAMASTER","ZFA_VEICPG"   	,cPlaca)
        oModel:SetValue("ZFAMASTER","ZFA_TRANPA"	,cCodTran)
        oModel:SetValue("ZFAMASTER","ZFA_LJPPAG"  	,cLjTran)
        oModel:SetValue("ZFAMASTER","ZFA_NMTPAG"  	,cNmTran)
        oModel:SetValue("ZFAMASTER","ZFA_VALOR"  	,nVlr)
        oModel:SetValue("ZFAMASTER","ZFA_APRMOV"  	,"S")
        oModel:SetValue("ZFAMASTER","ZFA_FECHA"  	,"N")
        oModel:SetValue("ZFAMASTER","ZFA_DATAIN"  	,Date())
        oModel:SetValue("ZFAMASTER","ZFA_HORA"  	,Time())
        oModel:SetValue("ZFAMASTER","ZFA_USUARI"  	,cUserName)
        oModel:SetValue("ZFAMASTER","ZFA_TPBLQF"  	,U_ADLG40I(Val(cTpCrg))) 
        oModel:SetValue("ZFAMASTER","ZFA_ORIGEM"	,cOrigem)		

        //
        If oModel:VldData()
            oModel:CommitData()

        Else
            lRet := .F.
            aError := oModel:GetErrorMessage()
            Conout( DToC(Date()) + " " + Time() + " ADLOG067P - ERRO - GetErrorMessage " )
            Conout( aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION] )
            Help(Nil, Nil, "Função ADLOG067P(ADLOG067P)", Nil,  aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION], 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf 
        
        //
        oModel:DeActivate()
        oModel:Destroy()
        oModel := Nil

	End Transaction

    // 
    RestArea(aArea)

Return lRet
/*/{Protheus.doc} sqlZFD
    Script sql com informações da carga/roteiro.
    @type  Static Function
    @author Everson
    @since 20/01/2020
    @version 01
    /*/
Static Function sqlZFD(cNumCrg,cTpCrg)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Local aArea  := GetArea()
    Local cQuery := ""

    //
    cQuery := ""
    cQuery += " SELECT    " 
    cQuery += " ZFD_VA, " 
    cQuery += " ZFD_COD, " 
    cQuery += " ZFD_DTENTR, " 
    cQuery += " ZFD_CAMINH, " 
    cQuery += " ZFD_TRANSP, " 
    cQuery += " ZFD_LOJTRA, " 
    cQuery += " ZFD_NOMTRA, " 
    cQuery += " SUM(ZFD_KMGER) AS ZFD_KMGER, " 
    cQuery += " COUNT(DISTINCT C5_NUM) AS NUMENT, " 
    cQuery += " SUM(C5_PESOL) AS C5_PESOL, " 
    cQuery += " SUM(C5_PBRUTO) AS C5_PBRUTO, " 
    cQuery += " SUM(C5_VOLUME1) AS C5_VOLUME1, " 
    cQuery += " SUM(ZFD_VLRFRT) AS ZFD_VLRFRT " 
    cQuery += " FROM   " 
    cQuery += " " + RetSqlName("ZFD") + "  (NOLOCK) AS ZFD " 
    cQuery += " INNER JOIN " 
    cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 ON " 
    cQuery += " ZFD_FILIAL = C5_FILIAL " 
    cQuery += " AND ZFD_PEDIDO = C5_NUM   " 
    cQuery += " WHERE   " 
    cQuery += " ZFD_FILIAL = '" + FWxFilial("ZFD") + "'   " 
    cQuery += " AND ZFD_COD = '" + cNumCrg + "'   " 
    cQuery += " AND ZFD_VA = '" + cTpCrg + "' " 
    cQuery += " AND ZFD_FEZNF = 'S' "
    cQuery += " AND ZFD.D_E_L_E_T_ = '' " 
    cQuery += " AND SC5.D_E_L_E_T_ = '' " 
    cQuery += " GROUP BY " 
    cQuery += " ZFD_VA, " 
    cQuery += " ZFD_COD, " 
    cQuery += " ZFD_DTENTR, " 
    cQuery += " ZFD_CAMINH, " 
    cQuery += " ZFD_TRANSP, " 
    cQuery += " ZFD_LOJTRA, " 
    cQuery += " ZFD_NOMTRA " 

    //
    Conout( DToC(Date()) + " " + Time() + " ADLOG067P - sqlZFD - cQuery " + cQuery )

Return cQuery