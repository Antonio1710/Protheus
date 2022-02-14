#Include "Protheus.ch"
#Include "Topconn.ch"
/*/{Protheus.doc} User Function ADCON017P
    Função para gerar histórico da tabela SF4.
    @type  Function
    @author Everson
    @since 05/10/2020
    @version 01
    /*/
User Function ADCON017P() // U_ADCON017P()

    //Variáveis.
    Local aArea     := GetArea()
    Local oTelMenu  := Nil

    //
    Private cUltDt  := getUlBack()
    Private oText   := Nil

    //
    oTelMenu		   := MsDialog():Create()
	oTelMenu:cName     := "oTelMenu"
	oTelMenu:cCaption  := "Backup SF4"
	oTelMenu:nLeft     := 34
	oTelMenu:nTop      := 222
	oTelMenu:nWidth    := 245
	oTelMenu:nHeight   := 250
	oTelMenu:lShowHint := .F.
	oTelMenu:lCentered := .T.

        //
        TButton():New(016,005,"Backup SF4 (TES)"  ,oTelMenu,{|| MsAguarde({|| gerlBckup() },"Executando backup...","Função ADCON017P") },111,018,,,.F.,.T.,.F.,,.F.,,,.F. )
        TButton():New(039,005,"Comparar Registros",oTelMenu,{|| MsAguarde({|| execComp() },"Processando...","Função ADCON017P") },111,018,,,.F.,.T.,.F.,,.F.,,,.F. )
        //TButton():New(062,005,"Gerar Relatório"   ,oTelMenu,{|| MsAguarde({|| gerlBckup() },"Gerando relatório...","Função ADCON017P") },111,018,,,.F.,.T.,.F.,,.F.,,,.F. )

        //
        oText := TSay():Create(oTelMenu,{|| "Dt. Ult. Backup: " + cUltDt},085,005,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)

    //
    oTelMenu:Activate(,,,.T.,{||.T.},,{||  })

    //
    RestArea(aArea)

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),' Função para gerar histórico da tabela SF4.')


Return Nil
/*/{Protheus.doc} gerlBckup
    Executa stored procedure que salva os dados da tabela SF4.
    @type  Static Function
    @author Everson
    @since 05/10/2020
    @version 01
    /*/
Static Function gerlBckup()

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .T.
    Local aResult   := {}
    Local cUsuario  := Alltrim(cUserName)
    Local cMsg      := ""

    //
    If ! MsgYesNo("Deseja realizar o backup da tabela SF4?","Função gerlBckup(ADCON017P)")
        lRet := .F.
        Return lRet

    EndIf

    //
    If Empty(cUsuario)
        cUsuario := "AUTOMATICO"
        
    EndIf

    //
    aResult := TcSpExec("sp_salvasf4", cUsuario, cEmpAnt, RetSqlName("SF4"))

    //
    If ValType(aResult) <> "A" .Or. Len(aResult) <= 0
        lRet := .F.
        MsgStop("Ocorreu erro na execução do backup.","Função gerlBckup(ADCON017P)")

    Else 
        cMsg := Alltrim(aResult[1])
        If cMsg == "OK"
            cUltDt:= getUlBack()
            oText:Refresh()

            MsgInfo("Backup realizado.","Função gerlBckup(ADCON017P)")
        Else
            MsgStop("Ocorreu erro ao efetuar o backup. " + Chr(13) + Chr(10) + cMsg,"Função gerlBckup(ADCON017P)")

        EndIf

    EndIf

    //
    RestArea(aArea)

Return lRet
/*/{Protheus.doc} execComp
    Processa comparação de diferenças.
    @type  Static Function
    @author Everson
    @since 05/10/2020
    @version 01
    /*/
Static Function execComp()

    //Variáveis.
    Local aArea  := GetArea()
    Local cDir   := ""
    Local cQrSF4 := getScpSF4()
    Local cQrHis := ""
    Local aStrut := {}
    Local xVlSF4 := Nil
    Local xVlHis := Nil
    Local nAux   := 1
    Local aDife  := {}

    //
    If ! MsgYesNo("Deseja verificar se houve alterações na tabela SF4?","Função gerlBckup(ADCON017P)")
        lRet := .F.
        Return lRet

    EndIf

    //
    cDir := cGetFile("Arquivo CSV.", "Selecione o diretório para salvar o arquivo CSV",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)

    //
    If Empty(cDir)
        Return Nil 

    EndIf

    //
    If Select("D_SF4")
        D_SF4->(DbCloseArea())

    EndIf

    //
    TcQuery cQrSF4 New Alias "D_SF4"
    DbSelectArea("D_SF4")
    D_SF4->(DbGoTop())
    aStrut := D_SF4->(DBStruct())

    //
    While ! D_SF4->(Eof())

        //
        cQrHis := getScpHi(D_SF4->R_E_C_N_O_)

        // 
        If Select("D_HIST")
            D_SF4->(DbCloseArea())

        EndIf

        //
        TcQuery cQrHis New Alias "D_HIST"
        DbSelectArea("D_HIST")
        D_HIST->(DbGoTop())

        //
        For nAux := 1 To Len(aStrut)

            //
            xVlHis := &("D_HIST->" + Alltrim(cValToChar(aStrut[nAux][1])))
            xVlSF4 := &("D_SF4->" +  Alltrim(cValToChar(aStrut[nAux][1])))
            
            //
            If xVlSF4 <> xVlHis
                
                //
                Aadd(aDife,{aStrut[nAux][1],xVlHis,xVlSF4,D_SF4->F4_CODIGO})

            EndIf

        Next nAux

        //
        D_HIST->(DbCloseArea())
        D_SF4->(DbSkip())

    End

    //
    MsAguarde({|| grCSVS(cDir,aDife) },"Função execComp","Gerando CSV...")

    //
    D_SF4->(DbCloseArea())

    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} grCSVS
    Gera arquivo CSV.
    @type  Static Function
    @author Everson
    @since 05/10/2020
    @version 01
    /*/
Static Function grCSVS(cDir,aDife)

    //Variáveis.
	Local aArea		:= GetArea()
	Local i			:= 1
	Local cArq  	:= "S_DIFSF4"+__cUserID+"_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV"
	Local nHdl      := 0
	Local cEof		:= Chr(13) + Chr(10)
	Local cLin		:= ""

    //
	If Empty(Alltrim(cValToChar(cDir)))
		Return Nil

	EndIf

	//
	nHdl := FCreate(cDir + cArq,0)

	//
	If nHdl == -1
		MsgAlert("O Arquivo não " + cArq + " pode ser criado:" + cEof + STR(FERROR()),"Função grCSVS")
		Return Nil

	EndIf

	//
	cLin := "Empresa;Filial;Código;Campo;Título;Valor Anterior;Valor Atual"

    //
	cLin += cEof

    //
	For i := 1 To Len(aDife)

		//
        cLin += cEmpAnt + ";"
        cLin += cFilAnt + ";"
        cLin += cValToChar(aDife[i][4]) + ";"
		cLin += cValToChar(aDife[i][1]) + ";"
        cLin += getNmCmp(aDife[i][1]) + ";"
        cLin += cValToChar(aDife[i][2]) + ";"
        cLin += cValToChar(aDife[i][3]) + ";"
		cLin += cEof

        //
		FWrite(nHdl,cLin,Len(cLin))

        //
		cLin := ""

	Next i

	//Fecha o arquivo.
	FClose(nHdl)

    //
	WinExec("Explorer.exe" + Space(1) + cDir )

    //
	MsgInfo("Arquivo gerado.","Função grCSVS")

    //
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} getScpSF4
    Script sql para obter registros com divergência.
    @type  Static Function
    @author Everson
    @since 05/10/2020
    @version 01
    /*/
Static Function getScpSF4()

    //Variáveis.
    Local cQuery := ""

    //
    cQuery += " SELECT " 
    cQuery += " * " 
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("SF4") + " (NOLOCK) AS SF4 " 
    cQuery += " WHERE " 
    cQuery += " F4_FILIAL = '" + FWxFilial("SF4") + "' " 
    cQuery += " AND SF4.R_E_C_N_O_ IN ( " 
    cQuery += scriptBase()
    cQuery += " ) ORDER BY R_E_C_N_O_ " 

Return cQuery
/*/{Protheus.doc} getScpHi
    Script sql do histórico SF4.
    @type  Static Function
    @author Everson
    @since 05/10/2020
    @version 01
    /*/
Static Function getScpHi(nRec)

    //Variáveis.
    Local cQuery := ""

    //
    cQuery += " SELECT  " 
    cQuery += " * " 
    cQuery += " FROM " 
    cQuery += " HISTSF4 (NOLOCK) AS SF4 " 
    cQuery += " WHERE " 
    cQuery += " F4_FILIAL = '" + FWxFilial("SF4") + "' " 
    cQuery += " AND EMP = '" + cEmpAnt + "' " 
    cQuery += " AND SF4.R_E_C_N_O_ = " + cValToChar(nRec) + " "

Return cQuery
/*/{Protheus.doc} sqlScript
    Script sql para obter registros com divergência.
    @type  Static Function
    @author Everson
    @since 05/10/2020
    @version 01
    /*/
Static Function scriptBase()

    //Variáveis.
    Local cQuery := ""

    //
    cQuery := ""
    cQuery += " SELECT  " 
    cQuery += " SF4.R_E_C_N_O_ AS RECSF4 "
    cQuery += " FROM " 
    cQuery += " ( " 
    cQuery += " SELECT  " 
    cQuery += " CHECKSUM(*) AS CHKSUM, * " 
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("SF4") + " (NOLOCK) AS SF4 " 
    cQuery += " WHERE " 
    cQuery += " F4_FILIAL = '" + FWxFilial("SF4") + "' "
    cQuery += " ) AS SF4 " 
    cQuery += " LEFT OUTER JOIN " 
    cQuery += " ( " 
    cQuery += " SELECT  " 
    cQuery += " *  " 
    cQuery += " FROM  " 
    cQuery += " HISTSF4 (NOLOCK)  " 
    cQuery += " WHERE  " 
    cQuery += " EMP = '" + cEmpAnt + "'  " 
    cQuery += " AND F4_FILIAL = '" + FWxFilial("SF4") + "' "
    cQuery += " AND IDPROC IN " 
    cQuery += " ( " 
    cQuery += " SELECT TOP 1 IDPROC FROM HISTSF4 ORDER BY R_E_C_N_O_ DESC " 
    cQuery += " ) " 
    cQuery += " ) AS H ON " 
    cQuery += " SF4.R_E_C_N_O_ = H.R_E_C_N_O_ " 
    cQuery += " WHERE  " 
    cQuery += " SF4.CHKSUM <> H.CHKSUM " 

Return cQuery
/*/{Protheus.doc} getNmCmp
    Retorna título do campo.
    @type  Static Function
    @author Everson
    @since 05/10/2020
    @version 01
    /*/
Static Function getNmCmp(cCampo)

    //Variáveis.
    Local aArea     := GetArea()
    Local cTitulo   := ""
    
    //
    DbSelectArea("SX3")
    SX3->(DbSetOrder(2))
    If SX3->(DbSeek( cCampo ))
        cTitulo := X3Titulo()
    
    EndIf

    //
    RestArea(aArea)

Return cTitulo
/*/{Protheus.doc} getUlBack
    Retorna a data do último backup.
    @type  Static Function
    @author Everson
    @since 05/10/2020
    @version 01
    /*/
Static Function getUlBack()

    //Variáveis.
    Local aArea := GetArea()
    Local cMsg  := ""

    //
    cQuery := "SELECT CAST(MAX(DATAPROCE) AS VARCHAR) AS ULT FROM HISTSF4 (NOLOCK) WHERE EMP = '" + cEmpAnt + "' AND F4_FILIAL = '" + FWxFilial("SF4") + "'"

    //
    If Select("D_DHORA") > 0
        D_DHORA->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "D_DHORA"
    DbSelectArea("D_DHORA")
    D_DHORA->(DbGoTop())
        cMsg := D_DHORA->ULT
    D_DHORA->(DbCloseArea())

    //
    RestArea(aArea)

Return cMsg
