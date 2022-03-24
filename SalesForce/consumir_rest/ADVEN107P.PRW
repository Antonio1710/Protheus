#include "TOTVS.CH"
#Include "Topconn.ch"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} User Function ADVEN107P
    Rotina para processamento e integração dos pedidos de venda integrados pelo SalesForce
    na tabela ZCI.
    @type  Function
    @author Leonardo P. Monteiro
    @since 08/03/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function ADVEN107P(aEmpFil)
	Local cCodEmp := ""
	Local cCodFil := ""

    // Execução por schedule.
	if valType(aEmpFil) == "A"
		if len(aEmpFil) >= 2
			cCodEmp := aEmpFil[1]
			cCodFil := aEmpFil[2]
		endIf
	
    
    endIf

	if (!Empty(cCodEmp) .and. !Empty(cCodFil)) .AND. SELECT("SX2") == 0
		Qout(" JOB ADEEC014P-Protheus - 01 - Executando em modo Schedule Empresa "+ aEmpFil[1] + " e Filial " +aEmpFil[2] +"...")
		Qout(" JOB ADEEC014P-Protheus - 02 - Início da rotina...")

		PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil
		lInJob := .F.
		RPCSetType(3) //nÃ£o consome licenÃ§a.
		Qout(DtoC(dDatabase) + "-" + Time() + " JOB ADEEC014P-Protheus - 03 - Início da rotina na Empresa "+ aEmpFil[1] + " e Filial " +aEmpFil[2] +"...")
		// Executa as rotinas de WorkFlow
		execWF(.T.)
		Qout(DtoC(dDatabase) + "-" + Time() + " JOB ADEEC014P-Protheus - 04 - Fim da rotina na Empresa "+ aEmpFil[1] + " e Filial " +aEmpFil[2] +"...")
		RESET ENVIRONMENT
		//PREPARE ENVIRONMENT EMPRESA "51" FILIAL "04"
		Qout(" JOB ADEEC014P-Protheus - 05 - Fim da execução...") 
	else
		// Executa as rotinas de WorkFlow
		MsAguarde({|| execWF(.F.)},"Aguarde...","Enviando notificação de embarques...")
	endIf

    //
    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Workflow de notificação e autorização para o faturamento')

return

Static Function execWF(lAutom)
	Local cDiaS		:= lltrim(cValToChar(SuperGetMv("MV_#SFDSEM",,"")))
	Local cHDe		:= Alltrim(cValToChar(SuperGetMv("MV_#SFHDE",,"")))
	Local cHAt		:= Alltrim(cValToChar(superGetMv("MV_#SFHATE",,"")))
	
	Local nQtMThe	:= Val(cValToChar(GetMv("MV_#SFMTHR",,100))) 		// Total de threads
	Local nTotThe	:= Val(cValToChar(GetMv("MV_#SFQTHR",,1))) 		// Total de threads
	Local nRePThe	:= Val(cValToChar(GetMv("MV_#SFRTHR",,1000)))	// Quantidade máxima por ciclo de processamento.
	
	Private cUUID   := FWUUIDV4()


	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Job para processamento de alteração de pedido de venda SalesForce. Chamado 037261.')
	
	cDiaS := Alltrim(cValToChar(SuperGetMv("MV_#SFDSEM",,"")))
	cHDe  := Alltrim(cValToChar(SuperGetMv("MV_#SFHDE",,"")))
	cHAt  := Alltrim(cValToChar(superGetMv("MV_#SFHATE",,"")))

	If (cValToChar(DOW(Date()))) $cDiaS //.And. Time() >= cHDe .And. Time() <= cHAt

		If !LockByName("ADVEN107P", .T., .F.) .AND. SuperGetMV("MV_XVEN090",,.T.)
			logZBE("execWF-Rotina sendo executada por outro usuário ou agendamento. Aguarde o término da execução.",cUUID)
			Conout(DToC(Date()) + " " + Time() + " ADVEN107P - Rotina sendo executada por outro usuário ou agendamento. Aguarde o término da execução.")
		else
			fProcOrq(cUUID, nQtMThe, nTotThe, nRePThe)
		endif
	else
		logZBE("execWF-Horário inválido para execução. Horário de bloqueio: "+Alltrim(cDiaS),cUUID)
	endif

return

Static Function fProcOrq(cUUID, nQtMThe, nTotThe, nRePThe)
	Local cQuery := ""

	cQuery := fSqlZCI(nTotThe)



return lRet

Static Function sqlTScript(nTotReg)

	//Variáveis.
	Local cQuery := ""

	//Inclusão de pedido de venda.
	cQuery += " SELECT TOP " + cValToChar(nTotReg) + " * FROM ( "

	cQuery += " SELECT " 
	cQuery += " ZCI_NUMP, MAX(R_E_C_N_O_) AS REC " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZCI") + " (NOLOCK) " 
	cQuery += " WHERE " 
	cQuery += " ZCI_TMPR = 'PENDPROC' " 
	cQuery += " AND ZCI_METD = 'POST' " 
	cQuery += " AND D_E_L_E_T_ = '' "
	cQuery += " GROUP BY ZCI_NUMP " 

	cQuery += " UNION ALL "

	//Exclusão de pedido de venda.
	cQuery += " SELECT   " 
	cQuery += " ZCI.ZCI_NUMP, MAX(R_E_C_N_O_) AS REC   " 
	cQuery += " FROM   " 
	cQuery += " " + RetSqlName("ZCI") + " (NOLOCK)  AS ZCI " 
	cQuery += " INNER JOIN " 
	cQuery += " (SELECT ZCI_NUMP FROM " + RetSqlName("ZCI") + " AS ZCI WHERE ZCI_METD = 'POST' AND ZCI_TPALT = '5' AND ZCI.D_E_L_E_T_ = ''  ) AS POST " 
	cQuery += " ON ZCI.ZCI_NUMP = POST.ZCI_NUMP " 
	cQuery += " WHERE   " 
	cQuery += " ZCI.ZCI_TMPR = 'PENDPROC'   " 
	cQuery += " AND ZCI.ZCI_METD = 'DELETE'   " 
	cQuery += " AND ZCI.D_E_L_E_T_ = ''  " 
	cQuery += " GROUP BY ZCI.ZCI_NUMP " 

	cQuery += " UNION ALL "

	//Alteração de pedido de venda.
	cQuery += " SELECT   " 
	cQuery += " ZCI.ZCI_NUMP, MAX(R_E_C_N_O_) AS REC   " 
	cQuery += " FROM   " 
	cQuery += " " + RetSqlName("ZCI") + " (NOLOCK)  AS ZCI " 
	cQuery += " INNER JOIN " 
	cQuery += " (SELECT ZCI_NUMP FROM " + RetSqlName("ZCI") + " AS ZCI WHERE ZCI_METD = 'POST' AND ZCI_TPALT = '5' AND ZCI.D_E_L_E_T_ = ''  ) AS POST " 
	cQuery += " ON ZCI.ZCI_NUMP = POST.ZCI_NUMP " 
	cQuery += " WHERE   " 
	cQuery += " ZCI.ZCI_TMPR = 'PENDPROC'   " 
	cQuery += " AND ZCI.ZCI_METD = 'PUT'   " 
	cQuery += " AND ZCI.D_E_L_E_T_ = ''  " 
	cQuery += " GROUP BY ZCI.ZCI_NUMP " 

	//
	cQuery += " ) AS FONTE "
	cQuery += " ORDER BY FONTE.ZCI_NUMP, FONTE.REC " 

Return cQuery

Static Function logZBE(cLog, cParam, cMemo)

	//
	Default cLog	:= ""
	Default cParam	:= ""
	Default cMemo	:= ""

	//
	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
		Replace ZBE_FILIAL 	   	With xFilial("ZBE")
		Replace ZBE_DATA 	   	With dDataBase
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With "JOBPROC " + cValToChar(ThreadId())
		Replace ZBE_LOG	        With cLog
		Replace ZBE_MODULO	    With "COMERCIAL"
		Replace ZBE_ROTINA	    With "ADVEN090P" 
		Replace ZBE_PARAME      With cParam
		Replace ZBE_LOGMEM      With cMemo
	ZBE->( MsUnLock())

Return Nil
