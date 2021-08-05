#include "rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
/*/{Protheus.doc} User Function ADEST034P
    Gera lote de producao por integração do SAG.
    @type  Function
    @author Ricado Lima
    @since 01/11/2018
    @version 01
    @history Ricardo Lima-CHAMADO:037647-03/01/2019-ajuste na query
    @history Adriana - CHAMADO TI-27/05/2019: Correçao error.log expected N->C,function STR on U_ADEST034P
    @history Leon Toledo - CHAMADO 051560 - 09/09/2019: Criada validação para Codigo e Descrição antes da 
    integração do Lote do SAG no Protheus.
    @history Everson - Chamado 058675 - 23/06/2020. Adicionado tratamento para importação de lotes para mais de uma empresa/filial no Protheus.
    @history Everson - Chamado 059658 - 30/07/2020. Tratamento para não importar lote sem data.
    @history Everson - Chamado 7989   - 13/01/2021. Incluído tratamento por filial.
	@history SIgoli	 - Tkt: 17876     - 04/08/2021. Feito tratamento na rotina para atender todas as empresa configuradas no scheduled 
    /*/
User Function ADEST034P(aParam)  // U_ADEST034P("01","04"),

    //Variáveis.
    Local lAutoJob := .F.

    Default aParam    := Array(2)
	Default aParam[1] := "07"
	Default aParam[2] := "01"

    //
    If Select("SX6") == 0
	    lAutoJob := .T.
    EndIf

    //
    If lAutoJob

        RpcClearEnv()
        RpcSetType(3)
        //RpcSetEnv("01","04",,,,GetEnvServer(),{})
        RpcSetEnv(aParam[1],aParam[2],,,,GetEnvServer(),{ }) 

        // Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
        If !LockByName("ADEST034P", .T., .F.)
            ConOut("[ADEST034P] - Existe outro processamento sendo executado! Verifique...")
            RPCClearEnv()
            Return
        EndIf

        PtInternal(1,ALLTRIM(PROCNAME()))

    EndIf

        //
        Conout( DToC(Date()) + " " + Time() + " ADEST034P - Início Job de importação de lotes de criação do SAG. Emp/Fil " + cEmpAnt + "/" + cFilAnt )

        //
        logZBN("1","ADEST034P")

        //
        U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gera lote de producao por integração do SAG')
        
            //Everson - Chamado 058675 -23/06/2020.
            procRot()

        //
        logZBN("2","ADEST034P")

        //
        Conout( DToC(Date()) + " " + Time() + " ADEST034P - Fim Job de importação de lotes de criação do SAG. Emp/Fil " + cEmpAnt + "/" + cFilAnt )

     //
    If lAutoJob 

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
        //³Destrava a rotina para o usuário	    ?
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
        UnLockByName("ADEST034P")

		RpcClearEnv()

	Endif

Return Nil  
/*/{Protheus.doc} procRot
    Processa rotina dos lotes de criação SAG. Chamado 058675.
    **** Função também executada via StaticCall no fonte ADEST048P ***
    @type  Static Function
    @author Everson.
    @since 23/06/2020
    @version 01
    /*/
Static Function procRot()

    //
    incluiLt()

    //
    alteraLt()

    //
    deleteLt()

Return Nil 
/*/{Protheus.doc} incluiLt
    Processa importações de inclusões de lotes de criação SAG.
    @type  Static Function
    @author Ricardo Lima.
    @since 01/11/2018
    @version 01
    /*/
Static Function incluiLt()

    //Variáveis.
    Local aArea     := GetArea()
    Local cQuery    := ""

    //
    ConOut( DToC(Date()) + " " + Time() + " ADEST034P - incluiLt - Início importação de inclusões.")

    //Integra lote do SAG no Protheus.
    cQuery := sqlInLot()

    //
    If Select("ADEST34I") > 0
        ADEST34I->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "ADEST34I"
    DbSelectArea("ZCN")
    ZCN->(DbSetOrder(1)) //1 ZCN_FILIAL , ZCN_LOTE 
    While ADEST34I->(!Eof())

        //
        If (!Empty(ADEST34I->CODILOTE) .OR. (!Empty(ADEST34I->NOMELOTE)))    //Leon Toledo | 09/09/2019 | Chamado: 051560
            ZCN->(dbGoTop())
            If ZCN->(DbSeek( FWxFilial("ZCN") + Alltrim(Str(ADEST34I->CODILOTE)) ))
                ConOut( DToC(Date()) + " " + Time() + " ADEST034P - incluiLt - Lote: " + cValToChar(ADEST34I->CODILOTE) + " já integrado, registro ignorado.")

            Else
                RecLock("ZCN",.T.)
                    ZCN->ZCN_FILIAL := FWxFilial("ZCN")
                    ZCN->ZCN_LOTE   := Alltrim(Str(ADEST34I->CODILOTE))
                    ZCN->ZCN_DESCLT := ADEST34I->NOMELOTE
                    ZCN->ZCN_TIPO   := IIF(ADEST34I->RECRLOTE=1,'RECRIA','PRODUCAO')
                    ZCN->ZCN_CENTRO := ''
                    ZCN->ZCN_DESCCC := ''
                    ZCN->ZCN_DATLOT := ADEST34I->DATALOTE
                    ZCN->ZCN_STATUS := IIF(Empty(ADEST34I->ENCELOTE),'A','E')
                Msunlock()
                ConOut( DToC(Date()) + " " + Time() + " ADEST034P - incluiLt - Lote: " + cValToChar(ADEST34I->CODILOTE) + " integrado com sucesso.")

            EndIf
        Else
            ConOut( DToC(Date()) + " " + Time() + " ADEST034P - incluiLt - Lote: " + cValToChar(ADEST34I->CODILOTE) + " incompleto (código ou descrição).")

        EndIf

        //
        ADEST34I->(DbSkip())

    End

    //
    ADEST34I->(DbCloseArea())

    //
    ConOut( DToC(Date()) + " " + Time() + " ADEST034P - incluiLt - Fim importação de inclusões.")

    //
    RestArea(aArea)

Return Nil 
/*/{Protheus.doc} alteraLt
    Processa importações de alterações de lotes de criação SAG.
    @type  Static Function
    @author Ricardo Lima.
    @since 01/11/2018
    @version 01
    /*/
Static Function alteraLt()

    //Variáveis.
    Local aArea     := GetArea()
    Local cQuery    := ""
    Local cDataIni  := GetMv("MV_#ADE331" , .F. , "01/01/2019")

    //
    ConOut( DToC(Date()) + " " + Time() + " ADEST034P - alteraLt - Início importação de alterações.")

    // Integracao para Atualizar Lote no Protheus que foram Alterado no SAG
    cQuery := sqlAlLot(cDataIni)

    //
    If Select("ADEST34A") > 0
        ADEST34A->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "ADEST34A"
    While ADEST34A->(!Eof())
        DbSelectArea("ZCN")
        ZCN->(DbSetOrder(1))
        IF ZCN->(DbSeek( FWxFilial("ZCN") + Alltrim(Str(ADEST34A->CODILOTE)) ))
            RecLock("ZCN",.F.)
                ZCN->ZCN_DESCLT := ADEST34A->NOMELOTE
                ZCN->ZCN_TIPO   := IIF(ADEST34A->RECRLOTE=1,'RECRIA','PRODUCAO')
                ZCN->ZCN_DATCAN := ADEST34A->ENCELOTE
                ZCN->ZCN_LOGUPD := Alltrim(Str(ADEST34A->CODILOG_))
                ZCN->ZCN_STATUS := IIF(Empty(ADEST34A->ENCELOTE),'A','E')
            Msunlock()
            ConOut( DToC(Date()) + " " + Time() + " ADEST034P - alteraLt - Lote: " + cValToChar(ADEST34A->CODILOTE) + " atualizado com sucesso.")
        EndIf

        //
        ADEST34A->(DbSkip())

    End

    //
    ADEST34A->(DbCloseArea())

    //
    ConOut( DToC(Date()) + " " + Time() + " ADEST034P - alteraLt - Fim importação de alterações.")

    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} deleteLt
    Processa importações de exclusões de lotes de criação SAG.
    @type  Static Function
    @author Ricardo Lima.
    @since 01/11/2018
    @version 01
    /*/
Static Function deleteLt()

    //Variáveis.
    Local aArea     := GetArea()
    Local cQuery    := ""

    //
    ConOut( DToC(Date()) + " " + Time() + " ADEST034P - alteraLt - Início importação de exclusões.")

    // Integracao para excluir do Protheus lotes que foram excluidos do SAG
    // RICARDO LIMA-CHAMADO:037647-03/01/2019
    cQuery := sqlDeLot()

    //
    If Select("ADEST34D") > 0
        ADEST34D->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "ADEST34D"
    While ADEST34D->(!Eof())
        DbSelectArea("ZCN")
        ZCN->(DbSetOrder(1))
        IF ZCN->(DbSeek( FWxFilial("ZCN") + Alltrim(ADEST34D->ZCN_LOTE) )) //Por Adriana em 27/05/2019 Chamado TI
            RecLock("ZCN",.F.)
                dbDelete()
            Msunlock()
            ConOut( DToC(Date()) + " " + Time() + " ADEST034P - Lote: " + cValToChar(ADEST34D->CODILOTE) + " excluído com sucesso.") //Por Adriana em 27/05/2019 Chamado TI.
        EndIf
        ADEST34D->(dbSkip())
    End

    //
    ConOut( DToC(Date()) + " " + Time() + " ADEST034P - alteraLt - Fim importação de exclusões.")

    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} sqlIntLot
    Script sql para consulta de lotes no SAG (inclusão). Chamado 058675.
    @type  Static Function
    @author Everson
    @since 23/06/2020
    @version 01
    /*/
Static Function sqlInLot()

    //Variáveis.
    Local cQuery := ""

    //
    cQuery += " SELECT CODILOTE, NOMELOTE, RECRLOTE, DATALOTE, ENCELOTE "
    cQuery += " FROM SCSRV03.SAG.dbo.MPGELOTE "
    cQuery += " WHERE CODILOTE NOT IN ( "
    cQuery += "     SELECT ZCN_LOTE "
    cQuery += "     FROM "+RetSqlName("ZCN")+" ZCN "
    cQuery += "     WHERE ZCN.D_E_L_E_T_ = ' ' AND ZCN_FILIAL = '"  + FWxFilial("ZCN") + "' ) AND DATALOTE <> '' AND DATALOTE IS NOT NULL " //Everson - 30/07/2020. Chamado 059658. //Everson - 13/01/2020. Chamado 7989.
    cQuery += " ORDER BY CODILOTE "

Return cQuery
/*/{Protheus.doc} sqlAlLot
    Script sql para consulta de lotes no SAG (alteração). Chamado 058675.
    @type  Static Function
    @author Everson
    @since 23/06/2020
    @version 01
    /*/
Static Function sqlAlLot(cDataIni)

    //Variáveis.
    Local cQuery := ""

    //
    cQuery += " SELECT CODILOTE, NOMELOTE, RECRLOTE, ENCELOTE, CODILOG_ "
    cQuery += " FROM SCSRV03.SAG.dbo.MPLOLOTE "
    cQuery += " WHERE PSITLOG_ = 'A' "
    cQuery += " AND CODILOTE IN ( "
    cQuery += "     SELECT ZCN_LOTE "
    cQuery += "     FROM "+RetSqlName("ZCN")+" ZCN "
    cQuery += "     WHERE ZCN.D_E_L_E_T_ = ' ' AND ZCN_FILIAL = '"  + FWxFilial("ZCN") + "' ) " //Everson - 13/01/2020. Chamado 7989.
    cQuery += " AND CODILOG_ NOT IN ( "
    cQuery += "     SELECT ZCN_LOGUPD "
    cQuery += "     FROM "+RetSqlName("ZCN")+" ZCN "
    cQuery += "     WHERE ZCN.D_E_L_E_T_ = ' ' ) "
    cQuery += " AND DATALOTE >= '" + cDataIni + "' "
    cQuery += " ORDER BY CODILOTE, CODILOG_ "

Return cQuery
/*/{Protheus.doc} sqlDeLot
    Script sql para consulta de lotes no SAG (exclusão). Chamado 058675.
    @type  Static Function
    @author Everson
    @since 23/06/2020
    @version 01
    /*/
Static Function sqlDeLot()

    //Variáveis.
    Local cQuery := ""

    cQuery += " SELECT ZCN_LOTE "
    cQuery += " FROM " + RetSqlName("ZCN") + " ZCN "
    cQuery += " WHERE ZCN_LOTE IN ( "
    cQuery += "     SELECT CODILOTE "
    cQuery += "     FROM SCSRV03.SAG.dbo.MPLOLOTE "
    cQuery += "     WHERE PSITLOG_ = 'D' ) "
    cQuery += " AND ZCN.D_E_L_E_T_ = ' ' AND ZCN_FILIAL = '"  + FWxFilial("ZCN") + "' " //Everson - 13/01/2020. Chamado 7989.

Return cQuery
/*/{Protheus.doc} logZBN
    Gera log na tabela ZBN. Chamado 058675.
    @type  Static Function
    @author Everson
    @since 23/06/2020
    @version 01
    /*/
Static Function logZBN(cStatus,cJob)

    //Variáveis.
	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + cJob))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= cJob 
			ZBN_DATA    := dDataBase
			ZBN_HORA    := Time()
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= cJob 
			ZBN_DATA    := dDataBase
			ZBN_HORA    := Time()
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return Nil
