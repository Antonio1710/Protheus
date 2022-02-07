#include "rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} User Function nomeFunction
    CHAMADO:037647 - Gera ordem de produção e aponta a mesma por integração do SAG         
    Quando a OP for excluida no SAG e gravado um log, a partir                             
    desse log, o protheus estorna o apontamento e faz a exclusao                            
    @type  Function
    @author Ricardo Lima
    @since 01/11/2018
    @version 01
    @history Chamado 048153 || OS 049415 || CONTROLADORIA || ANDRESSA || 45968437 OP DE OVOS - FWNM - 03/04/2019
    @history Chamado 049347 || OS 050685 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || SAG VS PROTHEUS || FWNM - 24/05/2019
    @history Chamado 058675 || OS 060648 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || SAG X SAFEEG - Everson 23/06/2020
    @history Ticket T.I.    - Leonardo P. Monteiro - 28/12/2021 - Correção na falha de conexão com o linkedserver. Session Provider: Physical connection is not usable [xFFFFFFFF].
    @history Ticket 65674   - ADRIANO SAVOINE      - 28/12/2021 - Gerado no sistema o novo campo para trazer a descrição do Tipo Ovo.
    @history Ticket T.I.    - Leonardo P. Monteiro - 04/01/2022 - Ajuste da empresa '07' para '01' e filial '01' para '03'.
    @history Ticket 66335   - Jonathan.Carvalho - 06/01/2022 - Criado o STATUSOP do lado do SAG para não importar novamente os registros.
    @history Ticket TI      - Leonardo P. Monteiro - Fontes compilados emergencialmente 13/01/2022 11:44.
    @history Ticket TI      - Leonardo P. Monteiro - 17/01/2022 - Correção de error.log.
    @hystory Ticket 67537   - Fer Macieira    - 02/02/2022 - Importação de Ovos - Ordem de Produção
/*/
User Function ADEST033P()  // U_ADEST033P()

    //Variáveis.
    Local lAutoJob      := .F.
    Private cDataIni    := ""

    //
    If Select("SX6") == 0
	    lAutoJob := .T.
    EndIf

    //
    If lAutoJob

        RpcClearEnv()
        RpcSetType(3)
        //@Ticket T.I.  - Leonardo P. Monteiro - 04/01/2022 - Ajuste da empresa '07' para '01' e filial '01' para '03'.
        RpcSetEnv("01","03")

        // Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
        If !LockByName("ADEST033P", .T., .F.)
            ConOut("[ADEST033P] - Existe outro processamento sendo executado! Verifique...")
            RPCClearEnv()
            Return
        EndIf

        //ConOut( "[ADEST033P] - "+DToC(Date())+" "+Time()+" - Início Job importação de Ops.")
        PtInternal(1,ALLTRIM(PROCNAME()))

    EndIf

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gera ordem de produção e aponta a mesmo por integração do SAG Quando a OP for excluida no SAG e gravado um log, a partir desse log, o protheus estorna o apontamento e faz a exclusao')
    
    cDataIni    := Dtos(Date()-60)

    u_GrLogZBE( Date(),;
                TIME(),;
                cUserName,;
                "00 - Início da integração com o SAG",;
                "ESTOQUE E CUSTOS",;
                "ADEST033P",;
                "[ADEST033P] - cEmpAnt/cFilAnt: "+cEmpAnt+cFilAnt+" -  "+DToC(Date())+" "+Time()+" - Início Job importação de Ops.",;
                ComputerName(),;
                LogUserName())

    //Leonardo - 27/12/2021 - Checa a conexão com a database do SAG.
    if fChkSAG()
        //Everson - 23/06/2020 - Chamado 058675.
        procRot(lAutoJob)
    else
        u_GrLogZBE( Date(),;
                    TIME(),;
                    cUserName,;
                    "01-Erro na abertura do LinkedServer c\ o SAG",;
                    "ESTOQUE E CUSTOS",;
                    "ADEST033P",;
                    "[ADEST033P] - cEmpAnt/cFilAnt: "+cEmpAnt+cFilAnt+" -  "+DToC(Date())+" "+Time()+" - Erro na abertura do LinkedServer para integração com o Protheus.",;
                    ComputerName(),;
                    LogUserName())
    endif
    
    If lAutoJob 

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
        //³Destrava a rotina para o usuário	    ?
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
        UnLockByName("ADEST033P")

        //ConOut( DToC(Date()) + " " + Time() + " ADEST033P - Fim Job importação de Ops.")
        u_GrLogZBE( Date(),;
                TIME(),;
                cUserName,;
                "99 - Término da integração com o SAG",;
                "ESTOQUE E CUSTOS",;
                "ADEST033P",;
                "[ADEST033P] - cEmpAnt/cFilAnt: "+cEmpAnt+cFilAnt+" -  "+DToC(Date()) + " " + Time() + " ADEST033P - Fim Job importação de Ops.",;
                ComputerName(),;
                LogUserName())

		RpcClearEnv()

	EndIf

Return Nil

Static Function fChkSAG()
    Local lRet      := .F.
	Local cQuery    := ""
    Local cDataIni := Dtos(Date()-60)

	//Verifica se o linkedServer esta ativo
	cQuery := " SELECT TOP(1) 1 AS CONEXAO FROM  OPENQUERY(SCSRV03, ' SELECT * FROM SAG.dbo.INGEOVOS WHERE DATAOVOS >= ''" + cDataIni + "'' AND TIPOOVOS=''PROD'' ');"
    //cQuery += " OPENQUERY(SCSRV03, 'SELECT TOP(1) 1 AS CONEXAO FROM SAG.dbo.INGEOVOS WHERE DATAOVOS >= ''" + cDataIni + "'' AND TIPOOVOS=''PROD'' ') "
	
	If TcSqlExec(cQuery) < 0
		lRet := .F.
	else
        lRet := .T.
    Endif

return lRet


/*/{Protheus.doc} procRot
    Processa rotina.
    @type  Static Function
    @author Ricardo Lima.
    @since 01/11/2018
    @version 01
    /*/
Static Function procRot(lAutoJob)

    //Variáveis.
    Local NReg := 0

    //
    incluiOp(lAutoJob,@NReg)

    //
    deleteOp(lAutoJob)

    //
    If !lAutoJob

        //
        If NReg > 0
            ApMsgInfo("Protheus Atualizado com OP do SAG.","Função procRot(ADEST033P)") 
            ConOut( DToC(Date()) + " " + Time() + " ADEST033P - procRot - Protheus Atualizado com OP do SAG.")

        Else
            ApMsgInfo("Não Existe DADOS para atualizar o Protheus.","Função procRot(ADEST033P)") 
            ConOut( DToC(Date()) + " " + Time() + " ADEST033P - procRot - Não Existe DADOS para atualizar o Protheus.")

        EndIf

    Endif

Return Nil 
/*/{Protheus.doc} incluiOp
    Inclui Ops.
    @type  Static Function
    @author user
    @since 23/06/2020
    @version 01
    /*/
Static Function incluiOp(lAutoJob,NReg)

    //Variáveis.
    Local aArea    := GetArea()
    Local cQuery   := ""
    Local cDescLt := ""
    Local lLoteOk := .t.
    Local lLockZCV := .T.

    //
    ConOut( DToC(Date()) + " " + Time() + " ADEST033P - incluiOp - Início importação de Ops.")
    
    // Chamado n. 049347 || OS 050685 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || SAG VS PROTHEUS || FWNM - 24/05/2019
    cDescLt  := GetMV("MV_#LOTSAG",,"COBB")
    //
    
    //
    cQuery += sqlInOp()

    If Select("ADEST33I") > 0
		ADEST33I->(DbCloseArea())

	EndIf

    //
	TcQuery cQuery New Alias "ADEST33I"

    If !lAutoJob
        Count To NReg
        ProcRegua( NReg )

    EndIf

    //
    dbSelectArea("ADEST33I")
    dbGoTop()

    While ADEST33I->(!Eof())

        //
        ConOut( DToC(Date()) + " " + Time() + " ADEST033P - incluiOp - importando OP " + Alltrim(Str(ADEST33I->CODIOVOS)))
        
        // Chamado n. 049347 || OS 050685 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || SAG VS PROTHEUS || FWNM - 24/05/2019
        lLoteOk := ChkLote( Alltrim(Str(ADEST33I->CODILOTE)), cDescLt)
        
        If lLoteOk 

            // @hystory Ticket 67537   - Fer Macieira    - 02/02/2022 - Importação de Ovos - Ordem de Produção
            ZCV->( dbSetOrder(1) ) // ZCV_FILIAL, ZCV_CODOP, R_E_C_N_O_, D_E_L_E_T_
            If ZCV->( dbSeek(FWxFilial("ZCV")+Alltrim(Str(ADEST33I->CODIOVOS))) )
                lLockZCV := .F.
            Else
                lLockZCV := .T.
            EndIf
        
            RecLock("ZCV", lLockZCV)
                ZCV->ZCV_FILIAL := FWxFilial("ZCV")
                ZCV->ZCV_CODOP  := Alltrim(Str(ADEST33I->CODIOVOS))
                ZCV->ZCV_CODTIP := Alltrim(Str(ADEST33I->CODITPOV))
                ZCV->ZCV_CDLOTE := Alltrim(Str(ADEST33I->CODILOTE))
                ZCV->ZCV_DATA   := ADEST33I->DATAOVOS
                ZCV->ZCV_IDADEO := ADEST33I->IDADOVOS
                ZCV->ZCV_QTDOVO := ADEST33I->QTDEOVOS
                ZCV->ZCV_CODAOJ := Alltrim(Str(ADEST33I->CODIALOJ))
                // Chamado 048153 || OS 049415 || CONTROLADORIA || ANDRESSA || 45968437 || OP DE OVOS - FWNM - 01/04/2019
                ZCV->ZCV_DESCLT := Posicione("ZCN",1,FWxFilial("ZCN")+PadR(Alltrim(Str(ADEST33I->CODILOTE)),TamSX3("ZCN_LOTE")[1]),"ZCN_DESCLT")
                ZCV->ZCV_DESCTP := Alltrim(ADEST33I->NOMETPOV)//Adriano Savoine - 28/12/2021 - Ticket : 65674
    
            MsUnlock()
            
            ConOut( DToC(Date()) + " " + Time() + " ADEST033P - incluiOp - Incluido a OP SAG Numero: " + Alltrim(Str(ADEST33I->CODIOVOS)))
        
        EndIf

        //
        ADEST33I->(DbSkip())

        //
        If !lAutoJob
            IncProc() 

        Endif

    End 

    //
    ADEST33I->(DbCloseArea())

    //
    ConOut( DToC(Date()) + " " + Time() + " ADEST033P - incluiOp - Fim importação de Ops.")

    //
    RestArea(aArea)

Return Nil 
/*/{Protheus.doc} deleteOp
    Exclui Ops.
    @type  Static Function
    @author user
    @since 23/06/2020
    @version 01
    /*/
Static Function deleteOp(lAutoJob)

    //Variáveis.
    Local aArea    := GetArea()
    Local cQuery   := ""
 

    //
    ConOut( DToC(Date()) + " " + Time() + " ADEST033P - deleteOp - Início exclusão de Ops.")

    // Exclusão de OP
    cQuery := sqlDeOp()
    
    //
    If Select("ADEST33D") > 0
		ADEST33D->(DbCloseArea())

	EndIf

    //
	TcQuery cQuery New Alias "ADEST33D"
    DbSelectArea("ADEST33D")
    ADEST33D->(DbGoTop())
    
    //
    While ADEST33D->(!Eof())

        //
        DbSelectArea("ZCV")
        ZCV->(DbSetOrder(1))

        //
        If ZCV->(DbSeek( FWxFilial("ZCV") + Alltrim(Str(ADEST33D->CODIOVOS))))
            RecLock("ZCV",.F.)
                ZCV->(DbDelete())
            MsUnlock()
            ConOut( DToC(Date()) + " " + Time() + " ADEST033P - deleteOp - Excluido a OP SAG Numero: " + Alltrim(Str(ADEST33D->CODIOVOS)))

        Endif  

        //      
        ADEST33D->(DbSkip())

    End

    //
    ConOut( DToC(Date()) + " " + Time() + " ADEST033P - deleteOp - Fim exclusão de Ops.")

    //
    RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} ChkLote
    Checa se lote pode ser importado. Chamado 049347.
    @type  Static Function
    @author Microsiga 
    @since 05/24/2019
    @version 01
    /*/
Static Function ChkLote(cCodLt, cDescLt)

    //Variáveis.
    Local aArea  := GetArea()
	Local lOk    := .t.
	Local cQuery := ""
	
    //
	If Select("Work") > 0
		Work->( dbCloseArea() )

	EndIf

    //
	cQuery += " SELECT COUNT(1) TT "
	cQuery += " FROM " + RetSqlName("ZCN") + " (NOLOCK) "
	cQuery += " WHERE ZCN_LOTE='"+cCodLt+"' "
	cQuery += " AND ZCN_DESCLT LIKE '%"+cDescLt+"%' "
	cQuery += " AND D_E_L_E_T_='' "
	
	TcQuery cQuery New alias "Work"
	DbSelectArea("Work")
	Work->(DbGoTop())
	
    //
	If Work->TT >= 1
		lOk := .F. // Lote nao autorizado a importar

	EndIf

    //
	If Select("Work") > 0
		Work->(DbCloseArea())

	EndIf

    //
    ConOut( DToC(Date()) + " " + Time() + " ADEST033P - ChkLote - checa lote " + cValToChar(cCodLt) + " lOk " + cValToChar(lOk))

    //
    RestArea(aArea)

Return lOk
/*/{Protheus.doc} sqlInOp
    Script sql para importação de ordens de produção.
    @type  Static Function
    @author Everson
    @since 23/06/2020
    @version 01
    /*/
Static Function sqlInOp()

    //Variáveis.
    Local cQuery   := ""
    Local cDataIni := Dtos(Date()-60)
   
    /*
    cQuery += " SELECT CODIOVOS, INGEOVOS.CODITPOV, INCATPOV.NOMETPOV, CODILOTE, DATAOVOS, IDADOVOS, QTDEOVOS, CODIALOJ "
    cQuery += " FROM SCSRV03.SAG.dbo.INGEOVOS AS INGEOVOS "
    cQuery += " LEFT JOIN SCSRV03.SAG.dbo.POCaEmpr AS POCAEMPR "
    cQuery += " ON POCAEMPR.PCODEMPR=INGEOVOS.PEMPOVOS " //Everson - 23/06/2020. Chamado 058675.
    cQuery += " LEFT JOIN SCSRV03.SAG.dbo.INCATPOV AS INCATPOV " //Adriano Savoine - 28/12/2021 - Ticket : 65674
    cQuery += " ON INCATPOV.CODITPOV = INGEOVOS.CODITPOV " //Adriano Savoine - 28/12/2021 - Ticket : 65674
    cQuery += " WHERE DATAOVOS >= '" + cDataIni + "' "
    cQuery += " AND TIPOOVOS='PROD' "
    cQuery += " AND POCAEMPR.Te07Empr = '" + cEmpAnt + "' " //Everson - 23/06/2020. Chamado 058675.
    cQuery += " AND CODIOVOS NOT IN ( "
	cQuery += "     SELECT ZCV_CODOP FROM " + RetSqlName("ZCV") + " ZCV "
	cQuery += "     WHERE D_E_L_E_T_ = ' ' ) "
    cQuery += " ORDER BY CODIOVOS "
    */
    
    //@Ticket T.I.  - Leonardo P. Monteiro - 04/01/2022 - Ajuste da empresa '07' para '01' e filial '01' para '03'.
    //@Ticket 66335 - Jonathan.Carvalho - 06/01/2022 - Criado o STATUSOP
    cQuery += " SELECT CODIOVOS, CODITPOV, NOMETPOV, CODILOTE, DATAOVOS, IDADOVOS, QTDEOVOS, CODIALOJ "
    cQuery += " FROM "
    cQuery += " OPENQUERY(SCSRV03,"
    cQuery += "  'SELECT CODIOVOS, INGEOVOS.CODITPOV, INCATPOV.NOMETPOV, CODILOTE, DATAOVOS, IDADOVOS, QTDEOVOS, CODIALOJ "
    cQuery += "   FROM SAG.dbo.INGEOVOS AS INGEOVOS  "
    cQuery += "         LEFT JOIN SAG.dbo.POCaEmpr AS POCAEMPR  ON POCAEMPR.PCODEMPR=INGEOVOS.PEMPOVOS  "
    cQuery += "         LEFT JOIN SAG.dbo.INCATPOV AS INCATPOV ON INCATPOV.CODITPOV = INGEOVOS.CODITPOV " //Adriano Savoine - 28/12/2021 - Ticket : 65674
    //cQuery += "   WHERE DATAOVOS >= ''" + cDataIni + "'' AND STATUSOP <> ''I''  AND TIPOOVOS=''PROD''  AND POCAEMPR.Te07Empr = ''" + cEmpAnt + "'' ') A "
    cQuery += "   WHERE DATAOVOS >= ''" + cDataIni + "'' AND TIPOOVOS=''PROD''  AND INGEOVOS.CODITPOV IN (''5'',''6'') AND POCAEMPR.Te07Empr = ''" + cEmpAnt + "'' ') A "// @hystory Ticket 67537   - Fer Macieira    - 02/02/2022 - Importação de Ovos - Ordem de Produção
    cQuery += " WHERE   "
    cQuery += "     CODIOVOS NOT IN ( "
	cQuery += "     SELECT ZCV_CODOP FROM " + RetSqlName("ZCV") + " ZCV "
	cQuery += "     WHERE D_E_L_E_T_ = ' ' ) "
    cQuery += " ORDER BY CODIOVOS "

Return cQuery 

/*/{Protheus.doc} sqlDeOp
    Script sql para exclusão de ordens de produção.
    @type  Static Function
    @author Everson
    @since 23/06/2020
    @version 01
    /*/
Static Function sqlDeOp()

    //Variáveis.
    Local cQuery := ""
    Local cDataIni := Dtos(Date()-60)

    cQuery := " SELECT * FROM "
    cQuery += " OPENQUERY(SCSRV03, "
    cQuery += " 'SELECT CODIOVOS "
    cQuery += "  FROM SAG.dbo.INLOOVOS "
    cQuery += "  WHERE DATAOVOS >= ''" + cDataIni + "'' AND PSITLOG_=''D'' ') SAG "
    cQuery += " WHERE CODIOVOS IN ( SELECT ZCV_CODOP FROM "+RetSqlName("ZCV")+" ZCV WHERE D_E_L_E_T_ = ' ' ) "

Return cQuery
