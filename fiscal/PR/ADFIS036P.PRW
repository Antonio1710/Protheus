#Include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Apwizard.ch" 
#Include "Fileio.ch"  
#Include "Tbiconn.ch"
/*/{Protheus.doc} User Function ADFIS036P
    Job para consulta Sintegra. Chamado 052760.
    @type  Function
    @author Everson
    @since 16/12/2019
    @version 01
    /*/
User Function ADFIS036P() // U_ADFIS036P()
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local cEmp	:= "01"
	Local cFil	:= "02"
	
	//Inicia o ambiente.
    RPCClearEnv()
	RPCSetType(3)
	RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })

	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
	If !LockByName("ADFIS036P", .T., .F.)
		ConOut("[ADFIS036P] - Existe outro processamento sendo executado! Verifique...")
		RPCClearEnv()
		Return
	EndIf

    PtInternal(1,ALLTRIM(PROCNAME()))

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Job para consulta Sintegra. Chamado 052760.')

    logZBN("1") //Log início.
        
    Conout( DToC(Date()) + " " + Time() + " ADFIS036P - Início " )
    processa()
    Conout( DToC(Date()) + " " + Time() + " ADFIS036P - Fim " )
        
    logZBN("2") //Log fim.
	
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADFIS036P")

	//Fecha o ambiente.
	RpcClearEnv()

Return Nil

/*/{Protheus.doc} processa
	Gera log na ZBN. Chamado 052760.
	@type  Static Function
	@author Everson
	@since 16/12/2019
	@version 01
	/*/
Static Function processa()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Local aArea	 := GetArea()
    Local cQuery := scriptSql()
    Local cIE    := ""
    Local cUF    := ""
    Local cRetC  := ""
    Local cPedido:= "" 
    Local cFilPed:= "" 
    Local cUpdate:= "" 
    Local nTotal := 0
    Local nAux   := 0

    //
    If Select("D_PEDIDO") > 0
        D_PEDIDO->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "D_PEDIDO"
    DbSelectArea("D_PEDIDO")
    D_PEDIDO->(DbGoTop())
    nTotal := Contar("D_PEDIDO","!Eof()")
    D_PEDIDO->(DbGoTop())

    //
    While ! D_PEDIDO->(Eof())

        //
        nAux++
        cIE     := StrTran(StrTran(StrTran(Alltrim(D_PEDIDO->A1_INSCR),".",""),"/",""),"-","")
        cUF     := Alltrim(D_PEDIDO->A1_EST)
        cPedido := Alltrim(D_PEDIDO->C5_NUM)
        cFilPed := Alltrim(D_PEDIDO->C5_FILIAL)

        //
        Conout( DToC(Date()) + " " + Time() + " ADFIS036P - processa - consulta Sintegra pedido/UF/IE " + cValToChar(cPedido) + " / " + cValToChar(cUF) + " / " + cValToChar(cIE) + " " + cValToChar(nAux) + "/" + cValToChar(nTotal) )
        
        //
        cRetC := StaticCall(ADVEN086P,ConsIE,cIE,cUF)
        VarInfo("cRetC",cRetC)

        //
        If cRetC = "1" .Or. cRetC = "0" .Or.  cRetC = "Y"
            cUpdate := " UPDATE " + RetSqlName("SC5") + " SET C5_XCONSIN = '" + cValToChar(cRetC) + "'  WHERE C5_FILIAL = '" + cFilPed + "' AND C5_NUM = '" + cPedido + "' AND D_E_L_E_T_ = '' "

            //
            If TcSqlExec(cUpdate) < 0 
                Conout( DToC(Date()) + " " + Time() + " ADFIS036P - processa - Erro - TcSqlError " + TcSqlError() )

            EndIf

        EndIf

        //
        D_PEDIDO->(DbSkip())

        //
        Sleep(1000)

    End

    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} scriptSql
	Script sql com dados dos pedidos. Chamado 052760.
	@type  Static Function
	@author Everson
	@since 16/12/2019
	@version 01
	/*/
Static Function scriptSql()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Local aArea	:= GetArea()
    Local cQuery:= ""
    Local cDias := GetMv("MV_#DTSIN",,"0")

    //
    cQuery := ""
    cQuery += " SELECT " 
    cQuery += " C5_FILIAL,C5_NUM,A1_EST, A1_INSCR" 
    cQuery += " FROM" 
    cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5" 
    cQuery += " INNER JOIN" 
    cQuery += " " + RetSqlName("SA1") + " (NOLOCK) AS SA1 ON" 
    cQuery += " C5_CLIENTE = A1_COD" 
    cQuery += " AND C5_LOJACLI =  A1_LOJA" 
    cQuery += " WHERE" 
    cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "'" 
    cQuery += " AND C5_NOTA = ''" 
    cQuery += " AND C5_SERIE = ''" 
    cQuery += " AND DATEDIFF(DAY,C5_EMISSAO,GETDATE()) <= '" + cValToChar(cDias) + "'" 
    cQuery += " AND A1_EST <> ''" 
    cQuery += " AND A1_INSCR <> ''" 
    cQuery += " AND C5_XCONSIN = ''" 
    cQuery += " AND SC5.D_E_L_E_T_ = ''" 
    cQuery += " AND SA1.D_E_L_E_T_ = ''" 
    cQuery += " ORDER BY C5_FILIAL, C5_NUM" 

    Conout( DToC(Date()) + " " + Time() +  " ADFIS036P -  scriptSql - cQuery " + cQuery )

    //
    RestArea(aArea)
    
Return cQuery
/*/{Protheus.doc} logZBN
	Gera log na ZBN. Chamado 052760.
	@type  Static Function
	@author Everson
	@since 16/12/2019
	@version 01
	/*/
Static Function logZBN(cStatus)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADFIS036P'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADFIS036P'
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADFIS036P'
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
    
    //
	RestArea(aArea)

Return Nil