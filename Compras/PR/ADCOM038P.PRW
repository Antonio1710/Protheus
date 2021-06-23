#Include "Protheus.ch"
#Include "Topconn.ch"
/*/{Protheus.doc} User Function ADCOM038P
    Job para envio de e-mail informativo de pedidos de compra rejeitados.
    @type  Function
    @author Everson
    @since 10/09/2020
    @version 01
    /*/
User Function ADCOM038P() // U_ADCOM038P()

	//Inicia o ambiente. 
	RPCSetType(3)
	RpcSetEnv("01","02",,,,GetEnvServer(),{ })

        //
        logZBN("1")

        //
        envEmail()

        //
        logZBN("2")

	//Fecha o ambiente.
	RpcClearEnv()

Return Nil
/*/{Protheus.doc} envEmail
    Função envia e-mail com pedidos rejeitados.
    @type  Static Function
    @author Everson
    @since 10/09/2020
    @version 01
    /*/
Static Function envEmail()

    //Variáveis.
    Local aArea     := GetArea()
    Local aEmpresas := FWLoadSM0()
    Local cQuery    := sqlScpt(aEmpresas,DToS(Date()-1))
    Local cEmailS   := ""
    Local cMsg      := ""
    Local cPedido   := ""
 
    //
    If Select("D_DADOS") > 0
        D_DADOS->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "D_DADOS"
    DbSelectArea("D_DADOS")
    D_DADOS->(DbGoTop())
    While ! D_DADOS->(Eof())

        //
        cMsg    := ""
        cEmailS := ""
        If ! Empty(Alltrim(cValToChar(D_DADOS->C1_USER)))
            cEmailS := UsrRetMail(Alltrim(cValToChar(D_DADOS->C1_USER)))

        EndIf

        //
        cEmailS := Alltrim(cValToChar(D_DADOS->Y1_EMAIL)) + Iif(Empty(cEmailS),"",";" + cEmailS)

        //
        cMsg += ' <!DOCTYPE html> '
        cMsg += ' <html lang="pt-br"> '
        cMsg += ' <head> '
        cMsg += ' <meta charset="UTF-8"> '
        cMsg += ' <meta name="viewport" content="width=device-width, initial-scale=1.0"> '
        cMsg += ' <title>Pedido de Compra Rejeitado</title> '
        cMsg += ' </head> '
        cMsg += ' <body> '
        cMsg += ' <p>O pedido de compra ' +  Alltrim(cValToChar(D_DADOS->CR_NUM)) + ' da empresa ' +  Alltrim(cValToChar(D_DADOS->EMP)) + ' e filial ' + Alltrim(cValToChar(D_DADOS->CR_FILIAL)) + ' foi rejeitado.</p> '
        cMsg += ' <hr> '
        cMsg += ' <p>Fonte: ADCOM038P</p> '
        cMsg += ' <p>Enviado em ' + DToC(Date()) + ' às ' + Time() + '</p> '
        cMsg += ' </body> '
        cMsg += ' </html> '

        //
        //cEmailS := "everson.silva@adoro.com.br"
        U_enviaremail(cEmailS, "Pedido de Compra Rejeitado - " + Alltrim(cValToChar(D_DADOS->CR_NUM)), cMsg)

        //
        cPedido := Alltrim(cValToChar(D_DADOS->CR_FILIAL)) + Alltrim(cValToChar(D_DADOS->CR_NUM)) + Alltrim(cValToChar(D_DADOS->RECSRC))
        StartJob("U_ADCOM381",getenvserver(),.T.,D_DADOS->EMP,D_DADOS->CR_FILIAL,cPedido)

        //
        D_DADOS->(DbSkip())

    End

    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} sqlScpt
    Script sql 
    @type  Static Function
    @author Everson
    @since 10/09/2020
    @version 01
    /*/
Static Function sqlScpt(aEmpresas,cData)

    //Variáveis.
    Local cQuery := ""
    Local nAux   := 1
    Local cEmp   := ""

    //
    For nAux := 1 To Len(aEmpresas)

        //
        If cEmp == Alltrim(cValToChar(aEmpresas[nAux][1]))
            Loop 

        EndIf

        //
        cEmp := Alltrim(cValToChar(aEmpresas[nAux][1]))

        //
        cQuery += " SELECT  " 
        cQuery += " DISTINCT '" + cEmp + "' AS EMP, CR_FILIAL, CR_NUM, C7_USER, Y1_USER, Y1_EMAIL, " 
        cQuery += " C7_NUMSC, ISNULL(SC1.C1_USER,'') AS C1_USER, SCR.R_E_C_N_O_ AS RECSRC " 
        cQuery += " FROM " 
        cQuery += " SCR" + cEmp + "0 (NOLOCK) AS SCR " 
        cQuery += " INNER JOIN " 
        cQuery += " SC7" + cEmp + "0 (NOLOCK) AS SC7 ON " 
        cQuery += " CR_FILIAL = C7_FILIAL " 
        cQuery += " AND CR_NUM = C7_NUM " 
        cQuery += " INNER JOIN " 
        cQuery += " SY1" + cEmp + "0 (NOLOCK) AS SY1 ON " 
        cQuery += " C7_FILIAL = Y1_FILIAL " 
        cQuery += " AND C7_USER = Y1_USER " 
        cQuery += " LEFT OUTER JOIN " 
        cQuery += " (SELECT C1_FILIAL, C1_NUM, C1_USER FROM SC1" + cEmp + "0 (NOLOCK) AS SC1 WHERE SC1.D_E_L_E_T_ = '') AS SC1 ON " 
        cQuery += " C7_FILIAL = C1_FILIAL " 
        cQuery += " AND C7_NUMSC = C1_NUM " 
        cQuery += " WHERE " 
        cQuery += " CR_DATREJ >= '" + cData + "' " 
        cQuery += " AND RTRIM(LTRIM(CR_FILIAL)) + RTRIM(LTRIM(CR_NUM)) + RTRIM(LTRIM(SCR.R_E_C_N_O_)) NOT IN ( "
        cQuery += " SELECT RTRIM(LTRIM(ZBE_PARAME)) FROM ZBE" + cEmp + "0 (NOLOCK) AS ZBE WHERE ZBE_DATA >= '" + cData + "' AND ZBE_MODULO = 'COMPRAS' AND ZBE_ROTINA = 'ADCOM038P' AND ZBE.D_E_L_E_T_ = '' "
        cQuery += " ) "        
        cQuery += " AND SCR.D_E_L_E_T_ = '' " 
        cQuery += " AND SC7.D_E_L_E_T_ = '' " 

        //
        If nAux < Len(aEmpresas)
            cQuery += " UNION ALL "

        EndIf

    Next nAux

    cQuery += " ORDER BY " 
    cQuery += " EMP, CR_FILIAL, CR_NUM " 

    conout(cQuery)

Return cQuery
/*/{Protheus.doc} ADCOM381
    Função para geração e log na tabela ZBE.
    @type  Static Function
    @author Everson
    @since 10/09/2020
    @version 01
    /*/
User Function ADCOM381(cEmpP,cFilP,cPedido)
    
    //Variáveis.

    //
    RpcSetType(3)
    RpcSetEnv( cEmpP , cFilP )

        //
        DbSelectArea("ZBE")
        RecLock("ZBE",.T.)
            Replace ZBE_FILIAL  With FWxFilial("ZBE")
            Replace ZBE_DATA 	With dDataBase
            Replace ZBE_HORA 	With Time()
            Replace ZBE_USUARI	With Upper(Alltrim(cUserName))
            Replace ZBE_LOG	    With "Envio de e-mail inf rejeito pedido de compra"
            Replace ZBE_PARAME  With cPedido
            Replace ZBE_MODULO	With "COMPRAS"
            Replace ZBE_ROTINA	With "ADCOM038P" 
        MsUnlock() 

    //
    RpcClearEnv()

Return Nil
/*/{Protheus.doc} logZBN
    Log de execução de job.
    @type  Static Function
    @author Everson
    @since 10/09/2020
    @version 01
    /*/
Static Function logZBN(cStatus)

    //Variáveis.
	Local aArea	:= GetArea()
    
    //
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(FWxFilial("ZBN") + 'ADCOM038P'))

        //
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := FWxFilial("ZBN")
			ZBN_ROTINA	:= 'ADCOM038P' 
			ZBN_DATA    := dDataBase
			ZBN_HORA    := Time()
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else

        //
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := FWxFilial("ZBN")
			ZBN_ROTINA	:= 'ADCOM038P' 
			ZBN_DATA    := dDataBase
			ZBN_HORA    := Time()
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return Nil
