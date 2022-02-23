#Include "Rwmake.ch"
#Include 'AP5mail.ch'
#Include "Protheus.ch"
#include "Fileio.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"

Static cEmp := "01"
Static cFil := "02"

/*/{Protheus.doc} User Function ADVEN090P 
	Job para processamento de alteração de pedido de venda SalesForce. Chamado 037261.
	@type  Function
	@author Everson
	@since 09/05/2018
	@version 01
	@history 06/02/2019, Fernando, ERRO LOG - ALIAS NÃO EXISTE "CI" alterado para ZCI - Chamado TI.
	@history 25/09/2019, Everson,  Chamado T.I. Tratamento para error log.
	@history 25/09/2019, Everson,  Chamado T.I. Tratamento para error log.
	@history 30/10/2019, Everson, Chamado 052760. Validação Sintegra.
	@history 27/12/2019, Everson, Chamado TI. Tratamento para data incorreta enviada pelo Salesforce.
	@history chamado 056247 - FWNM     - 22/04/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history chamado 050729 - FWNM     - 30/06/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE
	@history 21/07/2020, Leon, Comentar LockByName para contornar falta de execução de rotinas de agendamento;
	@history 21/07/2020, Leon, Comentar LockByName para contornar falta de execução de rotinas de agendamento;
	@Ticket 11762, Data 05/04/2021, Leonardo P. Monteiro, Adição do tipo do cliente na inclusão ou alteração;
	@Ticket 63090, Data 29/10/2021, Everson, Tratamento para processamento com mais de uma thread.
	@Ticket 63090, Data 01/11/2021, Everson, Tratamento para processamento com mais de uma thread.
	@Ticket 63090, Data 03/11/2021, Everson, Tratamento para processamento com mais de uma thread.
	@Ticket 63090, Data 11/11/2021, Everson, Tratamento para processamento com mais de uma thread.
	@Ticket 63090, Data 18/11/2021, Everson, Tratamento para processamento com mais de uma thread.
	@Ticket TI   , Data 28/12/2021, Everson, Tratamento para data incorreta enviada pelo Salesforce.
	@history Chamado 66524 - Leonardo P. Monteiro  - 11/01/2022 - Correção na função comparaCab responsável pela comparação do cabeçalho dos PVs. Tratamento dos campos de mensagens C5_MENNOTA para a correta decodificação.
	@history Chamado T.I   - Leonardo P. Monteiro   - 15/01/2022 - Inclusão data, hora e quantidade de processamentos.
	@history Chamado 68737 - Leonardo P. Monteiro   - 23/02/2022 - Restore do fonte 17/01/2022 para processamento em threads.
	/*/
User Function ADVEN090P() // U_ADVEN090P()

	//Declaração de variávies
	Local cDiaS		:= ""
	Local cHDe		:= ""
	Local cHAt		:= ""

	//Inicia o ambiente.
	RPCClearEnv()
	RPCSetType(3)
	RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{})

		//
		U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Job para processamento de alteração de pedido de venda SalesForce. Chamado 037261.')

		//
		Conout(DToC(Date()) + " " + Time() + " ADVEN090P - Início inclusão/atualização/exclusão de pedido de venda SalesForce")
		
		//
		cDiaS := Alltrim(cValToChar(GetMv("MV_#SFDSEM")))
		cHDe  := Alltrim(cValToChar(GetMv("MV_#SFHDE")))
		cHAt  := Alltrim(cValToChar(GetMv("MV_#SFHATE")))
		
		//
		If (cValToChar(DOW(Date()))) $cDiaS .And. Time() >= cHDe .And. Time() <= cHAt

			logZBN("1") //Log início.
				obterReg()
			logZBN("2") //Log início.

		EndIf
		
		//
		Conout(DToC(Date()) + " " + Time() + " ADVEN090P - Fim inclusão/atualização/exclusão de pedido de venda SalesForce")

	//Fecha o ambiente.
	RpcClearEnv()

Return Nil
/*/{Protheus.doc} obterReg
	Obtém registros de pedidos de venda pendentes de alteração. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 09/05/2018
	@version 01
/*/
Static Function obterReg()

	//Declaracao de Variaveis
	Local cQuery 	:= ""
	Local cRecnos	:= ""
	Local cJobAux	:= ""
	Local aJobs	    := {}
	Local i		 	:= 0
	Local nRePThe	:= Val(cValToChar(GetMv("MV_#SFRTHR",,1000))) //Total de registros buscados no select (TOP nRePThe)
	Local nTotThe	:= Val(cValToChar(GetMv("MV_#SFQTHR",,1))) //Total de threads.
	Local nTotal 	:= 0 //Total de registros a serem processados.
	Local nTotG	 	:= 0 //Total de registros distribuídos.
	Local nAux	 	:= 0 //Contagem de registros por Thread.
	Local nTotPT	:= 0 //Total de registros por Thread.
	Local lCont		:= .T.
	Local nCheck 	:= 0
	Local nTmpMed	:= tmpMed()
	Local nSecInit  := Seconds()
	Local nSecLmt	:= 0
	Local cThread   := ""
	Local lChkTmp   := GetMv("MV_#SFKILL",,.T.)

	//
	If Select("A_REG") > 0
		A_REG->(DbCloseArea())

	EndIf

	//
	cQuery := sqlTScript(nRePThe, nTotThe)

	//
	TcQuery cQuery New Alias "A_REG"
	DbSelectArea("A_REG")
	A_REG->(DbGoTop())
	nTotal := Contar("A_REG","!Eof()")
	Conout( DToC(Date()) + " " + Time() + " ADVEN090P - obterReg - TOTAL DE REGISTROS " + cValToChar(nTotal) )
	A_REG->(DbGoTop())

	//
	If nTotal <= 0
		A_REG->(DbCloseArea())
		Return Nil

	EndIf

	//
	If nTotThe > 1 .And. nTotal > nTotThe
		nTotPT := Round(nTotal/nTotThe,0)

	Else
		nTotPT  := nTotal
		nTotThe := 1

	EndIf

	nSecLmt := ((nTotal * (nTmpMed * 1.5)) + (nTotThe * 10)) + nSecInit

	//
	Conout("ADVEN090P - obterReg - nTotal/nTotPT >>>>>>>>>> " + cValToChar(nTotal) + " / " + cValToChar(nTotPT)) 

	//
	While ! A_REG->(Eof()) .And. lCont

		//
		nAux++
		nTotG++
		cRecnos += Alltrim(cValToChar( A_REG->REC )) + ","

		//
		If nAux == nTotPT .Or. nTotG == nTotal

			//Remove última vírgula da string.
			cRecnos := Substr(cRecnos, 1, Len(cRecnos) -1)
			i++
			
			//
			Conout("ADVEN090P - obterReg - JOB >>>>>>>>>>>> " + cValToChar(i) + " Qtd " + cValToChar(nAux) + " nTotPT " + cValToChar(nTotPT))

			//SF + Número do Job + Qtd de registros + Qtd total do job principal.
			cJobAux	:= "SF_" + cValToChar(i) + "_" + cValToChar(nAux) + "_" + cValToChar(nTotal)
			Aadd(aJobs,{cJobAux,""})

			//Inicia thread.
			StartJob("U_ADVEN900", GetEnvServer(), .F., cRecnos, cJobAux, nAux)
			
			//Cria variável global.
			PutGlbValue(cJobAux,"S")
			GlbUnlock()

			//
			cRecnos := ""
			nAux := 0
			cJobAux := ""

		EndIf

		//
		A_REG->(DbSkip())

	End

	logZBE("Início Processamento de validação de tempo")
	
	//Valida status do processamento.
	While Len(aJobs) > nCheck

		For i := 1 To Len(aJobs)

			//
			If cValToChar(GetGlbValue(aJobs[i][1])) == "F"
				nCheck++
				ClearGlbValue(aJobs[i][1])

			ElseIf Left(cValToChar(GetGlbValue(aJobs[i][1])),2) == "T-"

				If Empty(Alltrim(cValToChar(aJobs[i][2])))
					aJobs[i][2] := Substr(cValToChar(GetGlbValue(aJobs[i][1])),3,Len(cValToChar(GetGlbValue(aJobs[i][1]))))

				EndIf

			EndIf

		Next i

		//Valida o limite de tempo.
		If Seconds() > nSecLmt .And. lChkTmp
			For i := 1 To Len(aJobs)

				cThread := Alltrim(cValToChar(aJobs[i][2]))
				If ! Empty(cThread)
					U_ADVEN902(cThread)
					PutGlbValue(aJobs[i][1],"F")
					GlbUnlock()
					nCheck++

				EndIf

			Next i

			A_REG->(DbCloseArea()) //Everson - 18/11/2021. Chamado 63090.
			Return Nil

		EndIf

	End

	//Checa duplicidade na SC9
	//checkSC9()

	//
	A_REG->(DbCloseArea())

Return Nil
/*/{Protheus.doc} tmpMed
	Função retorna tempo médio de inclusão de pedido de venda.
	@type  Static Function
	@author Everson
	@since 11/11/2021
	@version 01
/*/
Static Function tmpMed()

	//Variáveis.
	Local nTmp   := 0
	Local cQuery := ""

	//
	cQuery := ""
	cQuery += " SELECT " 
		cQuery += " ISNULL(DATEDIFF(SECOND, '1/1/1900',  " 
		cQuery += " CAST(CAST(CAST(AVG(CAST(CAST(ZCI_TMPR AS DATETIME) AS FLOAT)) AS DATETIME) AS TIME) AS TIME) " 
		cQuery += " ),8)AS MEDIA_POST " 
	cQuery += " FROM  " 
		cQuery += " " + RetSqlName("ZCI") + " AS ZCI (NOLOCK)  " 
	cQuery += " WHERE  " 
		cQuery += " ZCI_FILIAL = '" + FWxFilial("ZCI") + "'  " 
		cQuery += " AND ZCI_DATA = '" + DToS(Date()) + "' " 
		cQuery += " AND ZCI_METD IN ('POST') " 
		cQuery += " AND ZCI_URL = '/pedidosdevenda' " 
		cQuery += " AND ZCI_TMPR NOT IN('','PENDPROC') " 
		cQuery += " AND ZCI_TMPR > '00:00:00' " 
		cQuery += " AND ZCI_ERRO IS NULL " 
		cQuery += " AND ZCI.D_E_L_E_T_ = '' " 

	//
	If Select("D_TMPM") > 0
		D_TMPM->(DbCloseArea())

	EndIf

	TcQuery cQuery New Alias "D_TMPM"
	DbSelectArea("D_TMPM")

		nTmp := Val(cValToChar(D_TMPM->MEDIA_POST))

	D_TMPM->(DbCloseArea())

Return nTmp
/*/{Protheus.doc} sqlTScript
	Script sql para processamento de registros.
	@type  Static Function
	@author user
	@since 28/10/2021
	@version 01
/*/
Static Function sqlTScript(nRePThe, nTotThe)

	//Variáveis.
	Local cQuery := ""
	Local nTotReg:= nRePThe * nTotThe

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
/*/{Protheus.doc} User Function ADVEN900
	Job para processar os registros. Chamado 037261.
	@type  Function
	@author Everson
	@since 13/05/2018
	@version 01
	@history 21/07/2020, Leon, Comentar LockByName para contornar falta de execução de rotinas de agendamento;
/*/
User Function ADVEN900(cRecnos,cJobAux, nAux)

	//Declaração de variávies
	Local nRecErro 	:= 0
	Local cGrvErro	:= ""

	Default cRecnos	:= ""
	Default cJobAux := ""

	//Inicia o ambiente.
	RPCClearEnv()
	RPCSetType(3)
	RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })	

		//
		Conout("ADVEN090P - Início ADVEN900 - Job " +  cValToChar(cJobAux) + " ThreadId " + cValToChar(ThreadId()) )

		//
		PutGlbValue(cJobAux,"T-" + Alltrim(cValToChar(ThreadId())))
		GlbUnlock()

		//Gera log na tabela ZBE
		logZBE("Início Processamento JOB " + cValToChar(cJobAux) + " ThreadId " + cValToChar(ThreadId()), "Total Reg " + cValToChar(nAux))

		//Executa a alteração dos pedidos.
		If ! Empty(cRecnos) .And. ! Empty(cJobAux)
			
			//
			nRecErro := 0
			cGrvErro := ""
			execProc(cRecnos, @nRecErro, @cGrvErro)
			If nRecErro > 0 .And. ! Empty(cGrvErro)
				U_ADVEN901(nRecErro, cGrvErro)

			EndIf

		EndIf

		//Gera log na tabela ZBE.
		logZBE("Fim processamento JOB " + cValToChar(cJobAux) + " ThreadId " + cValToChar(ThreadId()), "Total Reg " + cValToChar(nAux))

		//
		PutGlbValue(cJobAux,"F")
		GlbUnlock()

		//
		Conout("ADVEN090P - Fim ADVEN900 - Job " +  cValToChar(cJobAux) + " ThreadId " + cValToChar(ThreadId()) )

	//Fecha o ambiente.
	RpcClearEnv()

Return Nil
/*/{Protheus.doc} User Function ADVEN901
	Job para processar os registros de erro. Chamado T.I.
	@type  Function
	@author Everson
	@since 25/05/2018
	@version 01
	@history 21/07/2020, Leon, Comentar LockByName para contornar falta de execução de rotinas de agendamento;
/*/
User Function ADVEN901(nRecErro, cGrvErro)

	//Variáveis.
	Local aArea := GetArea()

	Conout( DToC(Date()) + " " + Time() +  " ADVEN090P - ADVEN901 - nRecErro/cGrvErro " + cValToChar(nRecErro) + cValToChar(cGrvErro) )
	
	//
	DbSelectArea("ZCI")
	ZCI->(DbGoTop())
	ZCI->(DbGoTo(nRecErro))
	RecLock("ZCI",.F.)
		ZCI->ZCI_ERRO := cGrvErro
		ZCI->ZCI_TMPR := "00:00:00"
	ZCI->(MsUnlock())

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} execProc
	Executa processamento de alteração de pedidos. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 09/05/2018
	@version 01
/*/
Static Function execProc(cRecnos, nRecGetErr, cGrvErro) //Everson - 25/09/20219. Chamado T.I.
	
	//Declaracao de Variaveis
	Local aArea	 	 := GetArea()
	Local cQuery 	 := ""
	Local oParseJSON := Nil
	Local cErro		 := ""
	Local cFlagApr	 := ""
	Local cErroPE	 := ""
	Local cHoraExec	 := Time()
	Local cPed		 := ""
	Local nTpOp		 := 0
	Local lPedBloq	 := .F.
	Local lProcess	 := .F.
	Local lRetCheck	 := .F.
	Local cHoraAnt	 := ""
	Local lErro		 := .T.
	Local nAux		 := 0
	Local i 		 := 1	
	Local cCliente   := ""
	Local cLoja	     := ""
	//Local cError	 := ""
	Local lContinua	 := .T. //Everson - 25/09/20219. Chamado T.I.
	Local nRecErro	 := ""  //Everson - 25/09/20219. Chamado T.I.
	Local nTotal     := 0

	Default cRecnos	 := ""

	Private aPedidos := {}

	//
	If Empty(cRecnos)
		RestArea(aArea)
		Return Nil

	EndIf

	//Everson - 25/09/20219. Chamado T.I.
	bError := ErrorBlock( {|e| cError := e:Description ,cGrvErro := cError, nRecGetErr := nRecErro, lContinua := .F., Conout( DToC(Date()) + " " + Time() + " ADVEN090P - RESTEXECUTE - lContinua/nRecErro/ERRO - " +; 
	cValToChar(lContinua) + " " + cValToChar(nRecErro) + " " + cError), MsUnlockAll() } )
	
	//	
	Begin Sequence

		cQuery := csqlTScript(cRecnos)

		If Select("A_PROC") > 0
			A_PROC->(DbCloseArea())

		EndIf

		TcQuery cQuery New Alias "A_PROC"
		DbSelectArea("A_PROC")
		A_PROC->(DbGoTop())
		nTotal := Contar("A_PROC","!Eof()")
		A_PROC->(DbGoTop())

		While ! A_PROC->(Eof()) .And. lContinua

			//
			cHoraAnt := Time()
			aPedidos := {}
			cErro    := ""
			nAux++
			
			Conout(DToC(Date()) + " " + Time() + " ADVEN090P - execProc - PROCESSANDO ZCI " + cValToChar(A_PROC->REC) + " METODO " + Alltrim(cValToChar(A_PROC->ZCI_METD)) + " - " + cValToChar(nAux) + " de " + cValToChar(nTotal) + " ThreadId " + cValToChar(ThreadId()) )
			nRecErro := Val(cValToChar(A_PROC->REC) )

			DbSelectArea("ZCI")
			ZCI->(DbGoTo( Val(cValToChar(A_PROC->REC)) ))

			If ! FWJsonDeserialize(ZCI->ZCI_JSON, @oParseJSON) .And. Alltrim(cValToChar(A_PROC->ZCI_METD)) <> "DELETE"
				cHoraExec := ELAPTIME(cHoraAnt, Time())
				RecLock("ZCI",.F.)
					ZCI->ZCI_TMPR := cHoraExec
					ZCI->ZCI_ERRO := "Json não pode ser desserializado."
					ZCI->(MsUnlock())
				RestArea(aArea)

				Return Nil

			EndIf

			If Alltrim(cValToChar(A_PROC->ZCI_METD)) <> "DELETE"
				cFlagApr := Alltrim(cValToChar(oParseJSON:CABECALHO:C5_BLQ))
				cPed     := Alltrim(cValToChar(oParseJSON:CABECALHO:C5_NUM))

			EndIf

			//Executa a inclusão do pedido de venda.
			If Alltrim(cValToChar(A_PROC->ZCI_METD)) == "POST"
				cPed := Alltrim(cValToChar(ZCI->ZCI_NUMP))
				Conout(DToC(Date()) + " " + Time() + " ADVEN090P - execProc - ENTROU POST ADVEN090P " + Alltrim(cValToChar(A_PROC->ZCI_NUMP)))

				DbSelectArea("SC5")
				SC5->(DbSetOrder(1))
				If SC5->( DbSeek( FWxFilial("SC5") + cPed ) )
					cHoraExec := ELAPTIME(cHoraAnt, Time())
					DbSelectArea("ZCI")
					//CI->(DbGoTo(Val(cValToChar(A_PROC->REC)))) //chamado: TI - Fernado Sigoli 06/02/2019
					ZCI->(DbGoTo(Val(cValToChar(A_PROC->REC))))
					RecLock("ZCI",.F.)
						ZCI->ZCI_TMPR := cHoraExec
						ZCI->ZCI_ERRO := "Pedido já processado." 
						ZCI->ZCI_TPALT := "5"
					ZCI->(MsUnlock())

					A_PROC->(DbSkip())
					Loop

				EndIf

				lErro    := .T.

				//
				Begin transaction
					lPedBloq := Iif(Upper(Alltrim(cValToChar(oParseJSON:CABECALHO:C5_BLQ))) == "S",.T.,.F.)

					If RESTEXECUTE(oParseJSON,@cErro,Alltrim(cValToChar(ZCI->ZCI_NUMP)),cFlagApr,Val(cValToChar(A_PROC->REC)),3,Alltrim(cValToChar(A_PROC->ZCI_CONSIN)))
						Conout( DToC(Date()) + " " + Time() + " ADVEN090P - execProc - OK - POST " + Alltrim(cValToChar(ZCI->ZCI_NUMP)))
						//
						lRetCheck := .F.
						lProcess  := .F.
						cErro := ""
						Conout( DToC(Date()) + " " + Time() + " ADVEN090P - execProc - INICIO LIBERACAO " + cPed + " lPedBloq " + cValToChar(lPedBloq) )
						lRetCheck := chkLiber(cPed,lPedBloq,,@lProcess,@cErro)
						Conout( DToC(Date()) + " " + Time() + " ADVEN090P - execProc - FIM LIBERACAO " + cPed)

						//Desarma transação se houve erro na liberação/bloqueio do pedido de venda.
						If !lRetCheck .Or. !lProcess
							DisarmTransaction()
							Break
						EndIf
						//
						DbSelectArea("ZCI")
						ZCI->(DbGoTo(Val(cValToChar(A_PROC->REC))))
						RecLock("ZCI",.F.)
							ZCI->ZCI_TMPR  := ELAPTIME(cHoraAnt, Time())
							ZCI->ZCI_TPALT := "5"
							ZCI->ZCI_ERRO   := ""
						ZCI->(MsUnlock())
					Else
						cErroPE := ""
						For i := 1 To Len(aPedidos)
							cErroPE += aPedidos[i][1] + " / "
						Next i
						
						DbSelectArea("ZCI")
						ZCI->(DbGoTo(Val(cValToChar(A_PROC->REC))))
						RecLock("ZCI",.F.)
							ZCI->ZCI_ERRO := Iif(Empty(cErroPE),cErro,cErroPE)
						ZCI->(MsUnlock())
						//
						Conout( DToC(Date()) + " " + Time() + " ADVEN090P - execProc - POST - ERRO " + Alltrim(cValToChar(ZCI->ZCI_NUMP)) + " " + Iif(Empty(cErroPE),cErro,cErroPE) )
					EndIf

					//Valida transação.
					lErro := .F.
				End Transaction
				
				//
				If lErro
					RecLock("ZCI",.F.)
						ZCI->ZCI_ERRO := "Erro transação inclusão de pedido de venda Tipo 5"
					ZCI->(MsUnlock())				
				EndIf

				//Executa a inclusão do pedido de venda.
			ElseIf Alltrim(cValToChar(A_PROC->ZCI_METD)) == "DELETE"
				Conout( DToC(Date()) + " " + Time() + " ADVEN090P - execProc - DELETE - " + Alltrim(cValToChar(A_PROC->ZCI_NUMP)))
				lErro := .T.
				cPed  := Alltrim(cValToChar(A_PROC->ZCI_NUMP))
				//
				DbSelectArea("SC5")
				SC5->(DbSetOrder(1))
				If ! SC5->( DbSeek( FWxFilial("SC5") + cPed ) )
					DbSelectArea("ZCI")
					ZCI->(DbGoTo(Val(cValToChar(A_PROC->REC))))
					RecLock("ZCI",.F.)
						ZCI->ZCI_TMPR := ELAPTIME(cHoraAnt, Time())
						ZCI->ZCI_ERRO := "Exclusão já processada."
						ZCI->ZCI_TPALT:= "6"
					ZCI->(MsUnlock())
					//Executa update nos registros pendentes.
					updStPut(cPed,cValToChar(A_PROC->REC))

					A_PROC->(DbSkip())
					Loop
				EndIf
				
				Begin transaction
					If RESTEXECUTE(oParseJSON,@cErro,Alltrim(cValToChar(ZCI->ZCI_NUMP)),cFlagApr,Val(cValToChar(A_PROC->REC)),5)
						Conout( DToC(Date()) + " " + Time() + " ADVEN090P - execProc - OK - DELETE " + Alltrim(cValToChar(ZCI->ZCI_NUMP)))
						//
						DbSelectArea("ZCI")
						ZCI->(DbGoTo(Val(cValToChar(A_PROC->REC))))
						RecLock("ZCI",.F.)
							ZCI->ZCI_TMPR  := ELAPTIME(cHoraAnt, Time())
							ZCI->ZCI_TPALT := "6"
							ZCI->ZCI_ERRO   := ""
						ZCI->(MsUnlock())

					Else
						cErroPE := ""
						For i := 1 To Len(aPedidos)
							cErroPE += aPedidos[i][1] + " / "
						Next i
						//
						Conout( DToC(Date()) + " " + Time() + " ADVEN090P - execProc - DELETE - ERRO " + Alltrim(cValToChar(ZCI->ZCI_NUMP)) + " " + Iif(Empty(cErroPE),cErro,cErroPE))
		
						RecLock("ZCI",.F.)
							ZCI->ZCI_ERRO := Iif(Empty(cErroPE),cErro,cErroPE)
						ZCI->(MsUnlock())

					EndIf
		
					//Valida transação.
					lErro := .F.
				End Transaction
				//
				If lErro
					DbSelectArea("ZCI")
					ZCI->(DbGoTo(Val(cValToChar(A_PROC->REC))))
					RecLock("ZCI",.F.)
						ZCI->ZCI_ERRO := "Erro transação exclusão de pedido de venda Tipo 6"
					ZCI->(MsUnlock())	

				EndIf

			//Alteração pedido de venda.
			ElseIf Alltrim(cValToChar(A_PROC->ZCI_METD)) == "PUT"
				Conout( DToC(Date()) + " " + Time() + " ADVEN090P - execProc - PUT - " + Alltrim(cValToChar(A_PROC->ZCI_NUMP)))
				
				DbSelectArea("SC5")
				SC5->(DbSetOrder(1))
				If ! SC5->( DbSeek( FWxFilial("SC5") + cPed ) )
					DbSelectArea("ZCI")
					ZCI->(DbGoTo(Val(cValToChar(A_PROC->REC))))
					RecLock("ZCI",.F.)
						ZCI->ZCI_TMPR := ELAPTIME(cHoraAnt, Time())
						ZCI->ZCI_ERRO := "Pedido não encontrado no Protheus."
					ZCI->(MsUnlock())

					//Executa update nos registros pendentes.
					updStPut(cPed,cValToChar(A_PROC->REC))

					A_PROC->(DbSkip())
					Loop

				EndIf

				//
				If Alltrim(cValToChar(A_PROC->ZCI_TPALT)) == "R"
					nTpOp := 1

				Else
					nTpOp := checkProc(oParseJSON,cPed)

				EndIf

				//
				If nTpOp == 1 //Executa MsExecauto.

					lErro    := .T.

					//
					Begin transaction
						lPedBloq := Iif(Upper(Alltrim(cValToChar(oParseJSON:CABECALHO:C5_BLQ))) == "S",.T.,.F.)

						If RESTEXECUTE(oParseJSON,@cErro,cPed,cFlagApr,Val(cValToChar(A_PROC->REC)),4)
							Conout( DToC(Date()) + " " + Time() + " ADVEN090P - execProc - OK - PUT - nTpOp 1 " + Alltrim(cValToChar(cPed)))
							//
							lRetCheck := .F.
							lProcess  := .F.
							cErro := ""
							lRetCheck := chkLiber(cPed,lPedBloq,,@lProcess,@cErro)
							//Desarma transação se houve erro na liberação/bloqueio do pedido de venda.
							If !lRetCheck .Or. !lProcess
								Conout("ADVEN090P - DisarmTransaction alteração 1 " + cPed)
								DisarmTransaction()
								Break
							EndIf
							//
							DbSelectArea("ZCI")
							ZCI->(DbGoTo(Val(cValToChar(A_PROC->REC))))
							Conout("ADVEN090P - Atualiza alteração 1 sucesso " + cPed + " RECNO " + cValToChar(ZCI->( Recno())) )
							RecLock("ZCI",.F.)
								ZCI->ZCI_TMPR  := ELAPTIME(cHoraAnt, Time())
								ZCI->ZCI_TPALT := cValToChar(nTpOp) 
							ZCI->(MsUnlock())

							//Executa update nos registros pendentes.
							updStPut(cPed,cValToChar(A_PROC->REC))
						Else
							cErroPE := ""
							For i := 1 To Len(aPedidos)
								cErroPE += aPedidos[i][1] + " / "
							Next i
							//
							Conout( DToC(Date()) + " " + Time() + " ADVEN090P - execProc - PUT - ERRO - nTpOp 1 " + Alltrim(cValToChar(cPed)) + " " + Iif(Empty(cErroPE),cErro,cErroPE))

							RecLock("ZCI",.F.)
								ZCI->ZCI_ERRO := Iif(Empty(cErroPE),cErro,cErroPE)
							ZCI->(MsUnlock())
						EndIf

						//Valida transação.
						lErro := .F.
					End Transaction

					//
					If lErro
						DbSelectArea("ZCI")
						ZCI->(DbGoTo(Val(cValToChar(A_PROC->REC))))
						RecLock("ZCI",.F.)
							ZCI->ZCI_ERRO := "Erro transação possível SC6 x SC9 Tipo 1"
						ZCI->(MsUnlock())				
					EndIf

				ElseIf nTpOp == 2 //Executa liberação do pedido.
					
					//
					lErro    := .T.

					//Everson - 01/11/2021. Chamado 63090.
					cErro := ""
					If ! chkBloTb(4, .T., @cErro, SC5->C5_NUM)
						MsUnlockAll()
						RestArea(aArea)
						Return .F.

					EndIf

					//
					Begin transaction

						//
						lPedBloq := Iif(Upper(Alltrim(cValToChar(oParseJSON:CABECALHO:C5_BLQ))) == "S",.T.,.F.)

						//Verifica se há mudança de status no pedido.
						If (lPedBloq .And. Alltrim(cValToChar( SC5->C5_BLQ )) == "1") .Or. (! lPedBloq .And. Empty(Alltrim(cValToChar( SC5->C5_BLQ ))) )
							//cHoraExec := ELAPTIME(cHoraAnt, Time())
							DbSelectArea("ZCI")
							ZCI->(DbGoTo(Val(cValToChar(A_PROC->REC))))
							RecLock("ZCI",.F.)
								ZCI->ZCI_TMPR  := ELAPTIME(cHoraAnt, Time())
								ZCI->ZCI_TPALT := cValToChar(nTpOp) 
							ZCI->(MsUnlock())

							//Executa update nos registros pendentes.
							updStPut(cPed,cValToChar(A_PROC->REC))			
						Else
							//
							lRetCheck := .F.
							lProcess  := .F.
							cErro     := ""
							lRetCheck := chkLiber(cPed,lPedBloq,,@lProcess,@cErro)
		
							//Desarma transação se houve erro na liberação/bloqueio do pedido de venda.
							If !lRetCheck .Or. !lProcess
								DisarmTransaction()
								Break
							EndIf
		
							cHoraExec := ELAPTIME(cHoraAnt, Time())
							DbSelectArea("ZCI")					
							ZCI->(DbGoTo(Val(cValToChar(A_PROC->REC))))
							RecLock("ZCI",.F.)
								ZCI->ZCI_TMPR  := cHoraExec
								ZCI->ZCI_TPALT := cValToChar(nTpOp) 
							ZCI->(MsUnlock())
		
							//Executa update nos registros pendentes.	
							updStPut(cPed,cValToChar(A_PROC->REC))
						EndIf

						//Valida transação
						lErro := .F.
					End Transaction
					//
					
					//
					If lErro
						DbSelectArea("ZCI")
						ZCI->(DbGoTo(Val(cValToChar(A_PROC->REC))))
						RecLock("ZCI",.F.)
						ZCI->ZCI_ERRO := "Erro transação possível SC6 x SC9 Tipo 2"
						ZCI->(MsUnlock())				
					EndIf

				ElseIf nTpOp == 3 //Altera quantidades do pedido de venda.
					//
					lErro    := .T.

					Begin transaction
						//
						lPedBloq := Iif(Upper(Alltrim(cValToChar(oParseJSON:CABECALHO:C5_BLQ))) == "S",.T.,.F.)

						//			
						If procCorte(oParseJSON,cPedido,lPedBloq)
							//
							lRetCheck := .F.
							lProcess  := .F.
							cErro     := ""
							lRetCheck := chkLiber(cPed,lPedBloq,,@lProcess,@cErro)

							//Desarma transação se houve erro na liberação/bloqueio do pedido de venda.
							If !lRetCheck .Or. !lProcess
								DisarmTransaction()
								Break

							EndIf

							//
							DbSelectArea("ZCI")
							ZCI->(DbGoTo(Val(cValToChar(A_PROC->REC))))
							RecLock("ZCI",.F.)
								ZCI->ZCI_TMPR  := ELAPTIME(cHoraAnt, Time())
								ZCI->ZCI_TPALT := cValToChar(nTpOp) 
							ZCI->(MsUnlock())

							//Executa update nos registros pendentes.
							updStPut(cPed,cValToChar(A_PROC->REC))
						EndIf

						//
						lErro := .F.
					End Transaction

					//
					If lErro
						DbSelectArea("ZCI")
						ZCI->(DbGoTo(Val(cValToChar(A_PROC->REC))))
						RecLock("ZCI",.F.)
							ZCI->ZCI_ERRO := "Erro transação possível SC6 x SC9 Tipo 3"
						ZCI->(MsUnlock())				
					EndIf
				EndIf
			
			EndIf
			
			//
			If Alltrim(cValToChar(A_PROC->ZCI_METD)) <> "DELETE"
				//
				DbSelectArea("ZCI")
				ZCI->(DbGoTo(Val(cValToChar(A_PROC->REC))))
				
				//
				If ! ZCI->(Eof())
					Conout( DToC(Date()) + " " + Time() + " ADVEN090P - execProc - Início check financeiro.")
					//Função chkBlCred disponível no fonte LIBPED1.
					cCliente := Alltrim(cValToChar(oParseJSON:CABECALHO:C5_CLIENTE))
					cLoja	 := Alltrim(cValToChar(oParseJSON:CABECALHO:C5_LOJACLI))
					StaticCall(LIBPED1,chkBlCred, cCliente, cLoja, Alltrim(cValToChar(ZCI->ZCI_NUMP)) )
				EndIf
			EndIf

			// Grava a data, hora e a quantidade de processamentos do registro.
			RecLock("ZCI",.F.)
				if Empty(ZCI->ZCI_DTPROC)
					ZCI->ZCI_DTPROC	:= Date()
					ZCI->ZCI_HRPROC	:= Time()
				endif

				ZCI->ZCI_QTPROC := ZCI->ZCI_QTPROC+1
			ZCI->(MsUnlock())
			//
			MsUnlockAll()
			
			//
			A_PROC->(DbSkip())

		EndDo

	Recover //Everson - 25/09/20219. Chamado T.I.
		ErrorBlock( bError )

	End Sequence

	//
	A_PROC->(DbCloseArea())

	//
	RestArea(aArea)

Return .T.
/*/{Protheus.doc} RESTEXECUTE
	Altera pedido de venda. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 09/05/2018
	@version 01
/*/
Static Function RESTEXECUTE(oParseJSON,cErro,cNumPed,cFlagApr,nRecno,nOpc,cSintegra) //Everson - 30/10/2019. Chamado 052760.
	
	//Declaracao de Variaveis
	Local aArea			:= GetArea()
	Local lRet			:= .F.	
	Local aCabec		:= {}
	Local aItens		:= {}
	Local aItem			:= {}
	Local aErroLog		:= {}
	Local k				:= 1
	Local i				:= 1
	Local nAuxInvalido	:= 0
	Local cProduto		:= ""
	Local nVlTot		:= 0
	Local lPedBloq		:= .F.
	//Local cTes			:= ""
	Local cItemPed		:= ""
	Local nItemPed 		:= obtSeqSC6(cNumPed)
	Local cVendCdCli	:= ""
	Local nVlrCred		:= 0
	Local cContaC		:= ""
	Local cItemContaC	:= ""
	Local cUsrVend		:= ""
	Local cBckUsr	    := __CUSERID
	Local cObrPdCp		:= ""
	Local cPedidoPC		:= ""
	Local cRedeOP		:= GetMV("MV_#REDEOP")
	Local lRedeOp		:= .F.
	Local cPedVendOrd	:= ""
	Local cTesCod		:= ""
	Local cTipCli		:= ""

	//Everson - 29/10/2021. Chamado 63090.
	Local aSB2			:= {}
	Local cNmBlq		:= ""
	//

	Private lMsErroAuto	:= .F.

	Default cErro		:= ""
	Default nOpc		:= 4
	Default cSintegra	:= "" //Everson - 30/10/2019. Chamado 052760.

	//Exclusão do pedido de venda.
	If nOpc == 5
		Conout( DToC(Date()) + " " + Time() + " ADVEN090P - RESTEXECUTE >>>> " + cNumPed + " OPCAO " + cValToChar(nOpc) )
		SetFunName("U_RESTEXECUTE")
		lRet := exclPedVend(@cErro,cNumPed)
		Conout( DToC(Date()) + " " + Time() + " ADVEN090P - RESTEXECUTE >>>> " + cNumPed )
		RestArea(aArea)
		Return lRet

	EndIf

	//Verifica se o pedido está bloqueado.
	lPedBloq := Iif(Upper(Alltrim(cValToChar(oParseJSON:CABECALHO:C5_BLQ))) == "S",.T.,.F.)

	cVendCdCli 	:= Posicione("SA1",1,FWxFilial("SA1") + Alltrim(cValToChar(oParseJSON:CABECALHO:C5_CLIENTE)) + Alltrim(cValToChar(oParseJSON:CABECALHO:C5_LOJACLI)),"A1_VEND")

	cUsrVend   	:= Posicione("SA3",1, FWxFilial("SA3") + cVendCdCli , "A3_CODUSR" )

	cObrPdCp   	:= Posicione("SA1",1,FWxFilial("SA1") + Alltrim(cValToChar(oParseJSON:CABECALHO:C5_CLIENTE)) + Alltrim(cValToChar(oParseJSON:CABECALHO:C5_LOJACLI)),"A1_XOBRPC")

	lRedeOp    	:= Iif( Posicione("SA1",1, FWxFilial("SA1") + Alltrim(cValToChar(oParseJSON:CABECALHO:C5_CLIENTE)) + Alltrim(cValToChar(oParseJSON:CABECALHO:C5_LOJACLI)),"A1_REDE") $cRedeOp,.T.,.F.)
	//Tkt 11762 - Adição do tipo do cliente na inclusão ou alteração.
	cTipCli		:= Posicione("SA1",1,FWxFilial("SA1") + Alltrim(cValToChar(oParseJSON:CABECALHO:C5_CLIENTE)) + Alltrim(cValToChar(oParseJSON:CABECALHO:C5_LOJACLI)),"A1_TIPO")

	Aadd(aCabec,{"C5_FILIAL" , FWxFilial("SC5")                           ,Nil}) 

	If nOpc == 4
		Aadd(aCabec,{"C5_NUM"    ,oParseJSON:CABECALHO:C5_NUM          ,Nil})
		cNmBlq := oParseJSON:CABECALHO:C5_NUM
	Else
		Aadd(aCabec,{"C5_NUM"    ,cNumPed                               ,Nil})
		cNmBlq := cNumPed
	EndIf

	Aadd(aCabec,{"C5_TIPO"   ,oParseJSON:CABECALHO:C5_TIPO          ,Nil}) 
	Aadd(aCabec,{"C5_CLIENTE",oParseJSON:CABECALHO:C5_CLIENTE       ,Nil})
	Aadd(aCabec,{"C5_LOJACLI",oParseJSON:CABECALHO:C5_LOJACLI       ,Nil})
	Aadd(aCabec,{"C5_XPEDSAL",oParseJSON:CABECALHO:C5_XPEDSAL       ,Nil})
	Aadd(aCabec,{"C5_XPEDSAL",oParseJSON:CABECALHO:C5_XPEDSAL       ,Nil})
	Aadd(aCabec,{"C5_CONDPAG",oParseJSON:CABECALHO:C5_CONDPAG       ,Nil})
	
	//Everson - 27/12/2019 - Chamado T.I.
	If (SToD(oParseJSON:CABECALHO:C5_DTENTR) - dDataBase) > 20
		cData := Substr(DToS(dDataBase),1,4)+Substr(oParseJSON:CABECALHO:C5_DTENTR,5,10)
	Else
		cData := oParseJSON:CABECALHO:C5_DTENTR
	EndIf

	Aadd(aCabec,{"C5_VEND1"  ,cVendCdCli                            ,Nil}) 
	Aadd(aCabec,{"C5_DTENTR" ,SToD( cData )  						,Nil})
	Aadd(aCabec,{"C5_MOEDA"  ,oParseJSON:CABECALHO:C5_MOEDA         ,Nil})
	//Tkt 11762 - Adição do tipo do cliente na inclusão ou alteração.
	Aadd(aCabec,{"C5_TIPOCLI",cTipCli						        ,Nil})
	
	//Valida a remessa de venda a ordem na ZCI.
	If ! Empty(Alltrim(cValToChar(oParseJSON:cabecalho:C5_XPEDORD)))
		If Len(Alltrim(cValToChar(oParseJSON:cabecalho:C5_XPEDORD))) == 18
			cPedVendOrd := Alltrim(cValToChar(Posicione("ZCI",1,FWxFilial("ZCI") + Alltrim(cValToChar(oParseJSON:cabecalho:C5_XPEDORD)), "ZCI_NUMP")))
		Else
			cPedVendOrd := Alltrim(cValToChar(Posicione("ZCI",2,FWxFilial("ZCI") + Alltrim(cValToChar(oParseJSON:cabecalho:C5_XPEDORD)), "ZCI_NUMP")))
		EndIf
	Else
		cPedVendOrd := ""
	EndIf
			
	Aadd(aCabec,{"C5_XPEDORD",cPedVendOrd                          ,Nil})

	Aadd(aCabec,{"C5_OPLOG"  ,oParseJSON:CABECALHO:C5_OPLOG         ,Nil})
	Aadd(aCabec,{"C5_TABELA" ,oParseJSON:CABECALHO:C5_TABELA        ,Nil})
	Aadd(aCabec,{"C5_TPFRETE",oParseJSON:CABECALHO:C5_TPFRETE       ,Nil})

	Aadd(aCabec,{"C5_FRETAPV",oParseJSON:CABECALHO:C5_FRETAPV ,0 , Nil })
	Aadd(aCabec,{"C5_XIPTAB" ,oParseJSON:CABECALHO:C5_XIPTAB  ,0 , Nil })
	Aadd(aCabec,{"C5_TOTDIG" ,oParseJSON:CABECALHO:C5_TOTDIG  ,0 , Nil })
	Aadd(aCabec,{"C5_TOTTAB" ,oParseJSON:CABECALHO:C5_TOTTAB  ,0 , Nil })
	Aadd(aCabec,{"C5_DESCTBP",oParseJSON:CABECALHO:C5_DESCTBP ,0 , Nil })
	Aadd(aCabec,{"C5_VALORNF",oParseJSON:CABECALHO:C5_VALORNF ,0 , Nil })

	Aadd(aCabec,{"C5_MENNOTA",DecodeUTF8(Alltrim(cValToChar(oParseJSON:CABECALHO:C5_MENNOTA)))       ,Nil})
	Aadd(aCabec,{"C5_MENNOT2",DecodeUTF8(Alltrim(cValToChar(oParseJSON:CABECALHO:C5_MENNOT2)))       ,Nil})
	Aadd(aCabec,{"C5_MENNOT3",DecodeUTF8(Alltrim(cValToChar(oParseJSON:CABECALHO:C5_MENNOT3)))       ,Nil})
	Aadd(aCabec,{"C5_MENNOT4",DecodeUTF8(Alltrim(cValToChar(oParseJSON:CABECALHO:C5_MENNOT4)))       ,Nil})
	Aadd(aCabec,{"C5_MENNOT5",DecodeUTF8(Alltrim(cValToChar(oParseJSON:CABECALHO:C5_MENNOT5)))       ,Nil})
	//
	Aadd(aCabec,{"C5_XREDE" , oParseJSON:CABECALHO:C5_XREDE  ,Nil})
	Aadd(aCabec,{"C5_CODRED", oParseJSON:CABECALHO:C5_CODRED ,Nil})

	cRoteiro := ""
	Aadd(aCabec,{"C5_ROTEIRO ",  cRoteiro ,Nil})
	//
	Aadd(aCabec,{"C5_XEMSF", Val(cValToChar(oParseJSON:CABECALHO:C5_XEMSF))    ,0 , Nil })
	Aadd(aCabec,{"C5_XITSF", Val(cValToChar(oParseJSON:CABECALHO:C5_XITSF))    ,0 , Nil })

	Aadd(aCabec,{"C5_PBRUTO"  , Val(cValToChar(oParseJSON:CABECALHO:C5_PBRUTO))   ,0 , Nil })
	Aadd(aCabec,{"C5_PESOL"   , Val(cValToChar(oParseJSON:CABECALHO:C5_PESOL))    ,0 , Nil })
	Aadd(aCabec,{"C5_VOLUME1" , Val(cValToChar(oParseJSON:CABECALHO:C5_VOLUME1))  ,0 , Nil })

	Aadd(aCabec,{"C5_XTOTPED" , Val(cValToChar(oParseJSON:CABECALHO:C5_VALORNF))  ,0 , Nil })
	Aadd(aCabec,{"C5_XGERSF"  , "2"                              ,Nil})
	Aadd(aCabec,{"C5_XSFPED"  , oParseJSON:CABECALHO:C5_XSFPED 	 ,Nil})
	Aadd(aCabec,{"C5_XSFTP "  , Alltrim(cValToChar(oParseJSON:CABECALHO:tpSaida ))  ,Nil})

	//Everson - 30/10/2019. Chamado 052760.
	If nOpc == 3
		Aadd(aCabec,{"C5_XCONSIN "  ,cSintegra  ,Nil})

	EndIf 

	//
	For i := 1 To Len(oParseJSON:ITENS)
		
		//
		aItem    := {}         
		cProduto := Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_PRODUTO ))             	      
		nVlTot	 := (oParseJSON:ITENS[i]:C6_QTDVEN * oParseJSON:ITENS[i]:C6_PRCVEN)

		Aadd(aSB2, FWxFilial("SB2") + cProduto) //Everson - 29/10/2021. Chamado 63090.

		//Exclusão de item do pedido.
		If Upper(Alltrim(cValToChar(oParseJSON:ITENS[i]:excluir))) == "S" .Or. Val(cValToChar(oParseJSON:ITENS[i]:C6_UNSVEN)) <= 0 .Or. Val(cValToChar(oParseJSON:ITENS[i]:C6_QTDVEN)) <= 0 .And.!Empty(cValToChar(oParseJSON:ITENS[i]:C6_ITEM))			
			Loop
		Else
			//
			If     Alltrim(cValToChar(oParseJSON:CABECALHO:tpSaida )) $("VE|EF") //Venda e venda com data de entrega futura.
				//Aadd(aItem,{"C6_XOPSF", ""   , Nil })
			ElseIf Alltrim(cValToChar(oParseJSON:CABECALHO:tpSaida )) == "BO" //Bonificação.
				Aadd(aItem,{"C6_XOPSF", "04"   , Nil })
			ElseIf Alltrim(cValToChar(oParseJSON:CABECALHO:tpSaida )) == "VO" //Venda ordem.
				Aadd(aItem,{"C6_XOPSF", "X" , Nil }) 
			ElseIf Alltrim(cValToChar(oParseJSON:CABECALHO:tpSaida )) == "RO" //Remessa de venda ordem.
				Aadd(aItem,{"C6_XOPSF", "Y" , Nil })
			EndIf
			//
			cItemPed := StrZero(nItemPed,2)

			//
			If nOpc == 4
				Aadd(aItem,{"AUTDELETA","N", Nil}) 
			EndIf

			Aadd(aItem,{"C6_FILIAL" , FWxFilial("SC6")                           , Nil}) 
			//
			If nOpc == 4
				Aadd(aItem,{"C6_NUM"    , oParseJSON:CABECALHO:C5_NUM          , Nil }) 
			Else
				Aadd(aCabec,{"C5_NUM"    ,cNumPed                               ,Nil})
			EndIf

			Aadd(aItem,{"C6_ITEM"   , Padr(cItemPed,TamSX3("C6_ITEM")[1]," ") , Nil })
			Aadd(aItem,{"C6_PRODUTO", Padr(cProduto,TamSX3("C6_PRODUTO")[1]," ") , Nil })
			Aadd(aItem,{"C6_UNSVEN" , oParseJSON:ITENS[i]:C6_UNSVEN  ,0       , Nil })
			Aadd(aItem,{"C6_PRCVEN" , oParseJSON:ITENS[i]:C6_PRCVEN  ,0       , Nil })
			Aadd(aItem,{"C6_VALOR"  , nVlTot                         ,0       , Nil }) 
			
			//
			cTesCod := Alltrim(cValToChar(Posicione("SB1",1,FWxFilial("SB1") +  Padr(cProduto,TamSX3("C6_PRODUTO")[1]," "), "B1_TS" )))
			Conout( DToC(Date()) + " " + Time() + " ADVEN090P - RESTEXECUTE - cTesCod >>>>>>>>>>>> " + cTesCod)
			If ! Empty(cTesCod)
				Aadd(aItem,{"C6_TES",  cTesCod , Nil })
			EndIf
			
			Aadd(aItem,{"C6_QTDLIB"  , 0                         ,0       , Nil })			
			Aadd(aItem,{"C6_QTDEMP"  , 0                         ,0       , Nil })			
			Aadd(aItem,{"C6_QTDLIB2" , 0                         ,0       , Nil })
			Aadd(aItem,{"C6_QTDEMP2" , 0                         ,0       , Nil })

			Aadd(aItem,{"C6_QTDVEN" , oParseJSON:ITENS[i]:C6_QTDVEN  ,0       , Nil })		
			Aadd(aItem,{"C6_NFORI"  , oParseJSON:ITENS[i]:C6_NFORI   ,  , Nil })
			Aadd(aItem,{"C6_SERIORI", oParseJSON:ITENS[i]:C6_SERIORI ,  , Nil })			

			cPedidoPC := Iif( Empty(Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_PEDCLI ))), Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_NUMPCOM )) ,Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_PEDCLI )) )
			//
			If lRedeOp .And. cObrPdCp <> "1"
				Aadd(aItem,{"C6_PEDCLI" , cPedidoPC  ,  , Nil })
				Aadd(aItem,{"C6_NUMPCOM", "",  , Nil })
				Aadd(aItem,{"C6_ITEMPC" , ""  ,  , Nil })
			ElseIf cObrPdCp == "1" .And. ! lRedeOp
				Aadd(aItem,{"C6_NUMPCOM", cPedidoPC ,  , Nil })
				Aadd(aItem,{"C6_ITEMPC" , Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_ITEMPC))  ,  , Nil })			
				Aadd(aItem,{"C6_PEDCLI" , "" ,  , Nil })
			ElseIf cObrPdCp == "1" .And. lRedeOp
				Aadd(aItem,{"C6_NUMPCOM", cPedidoPC ,  , Nil })
				Aadd(aItem,{"C6_ITEMPC" , Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_ITEMPC))  ,  , Nil })			
				Aadd(aItem,{"C6_PEDCLI" , cPedidoPC ,  , Nil })
			Else
				Aadd(aItem,{"C6_PEDCLI" , oParseJSON:ITENS[i]:C6_PEDCLI  ,  , Nil })
				Aadd(aItem,{"C6_NUMPCOM", oParseJSON:ITENS[i]:C6_NUMPCOM ,  , Nil })
				Aadd(aItem,{"C6_ITEMPC" , oParseJSON:ITENS[i]:C6_ITEMPC  ,  , Nil })
			EndIf

			Aadd(aItem,{"C6_VEND"   , cVendCdCli                     ,  , Nil })	

			//Everson - 24/09/2019. Chamado T.I.
			Aadd(aItem,{"C6_XIPTAB" , Val( Substr(cValToChar(oParseJSON:ITENS[i]:C6_XIPTAB),1,TamSX3("C6_XIPTAB")[1] )) ,0 , Nil })
			Aadd(aItem,{"C6_TOTDIG" , Val( Substr(cValToChar(oParseJSON:ITENS[i]:C6_TOTDIG),1,TamSX3("C6_TOTDIG")[1] )) ,0 , Nil })
			Aadd(aItem,{"C6_TOTTAB" , Val( Substr(cValToChar(oParseJSON:ITENS[i]:C6_TOTTAB),1,TamSX3("C6_TOTTAB")[1] )) ,0 , Nil })

			Aadd(aItem,{"C6_PRTABV" , Val( Substr(cValToChar(oParseJSON:ITENS[i]:C6_PRTABV),1,5 ))  ,0 , Nil })
			Aadd(aItem,{"C6_PBTTV"  , Val( Substr(cValToChar(oParseJSON:ITENS[i]:C6_PBTTV) ,1,5 ))  ,0 , Nil })
			Aadd(aItem,{"C6_PLTTV"  , Val( Substr(cValToChar(oParseJSON:ITENS[i]:C6_PLTTV) ,1,5 ))  ,0 , Nil })
			Aadd(aItem,{"C6_PLTVD"  , Val( Substr(cValToChar(oParseJSON:ITENS[i]:C6_PLTVD) ,1,5 ))  ,0 , Nil })
			Aadd(aItem,{"C6_PLTSP"  , Val( Substr(cValToChar(oParseJSON:ITENS[i]:C6_PLTSP) ,1,5 ))  ,0 , Nil }) 
			Aadd(aItem,{"C6_PLTAB"  , Val( Substr(cValToChar(oParseJSON:ITENS[i]:C6_PLTAB) ,1,5 ))  ,0 , Nil })

			cContaC     := Posicione("SB1",1,FWxFilial("SB1") + Alltrim(cValToChar(cProduto)),"B1_CONTA" )		
			cItemContaC := Posicione("SB1",1,FWxFilial("SB1") + Alltrim(cValToChar(cProduto)),"B1_ITEMCC" )

			Aadd(aItem,{"C6_CONTA"   , cContaC     ,0 , Nil })
			Aadd(aItem,{"C6_ITEMCTA" , cItemContaC ,0 , Nil })

			//
			nItemPed++
		EndIf

		//Adiciona item ao vetor de itens.
		aAdd(aItens,aItem)
	Next i

	//Everson - 29/10/2021. Chamado 63090.
	If ! chkBloTb(nOpc, .F., @cErro, cNmBlq, aSB2) //Tenta bloquear os registros para alteração.
		MsUnlockAll()
		RestArea(aArea)
		Return .F.

	EndIf
	//

	//
	If nOpc == 4
		//Localiza o pedido na tabela SC9 e faz o estorno dos itens.
		DbSelectArea("SC9")
		SC9->(DbSetOrder(1))
		SC9->(DbGoTop())
		If SC9->(DbSeek(FWxFilial("SC9") + cNumPed))

			//Faz o estorno dos itens liberados.
			While Alltrim(cValToChar(SC9->C9_FILIAL)) == Alltrim(cValToChar(SC5->C5_FILIAL)) .And.;
			Alltrim(cValToChar(SC9->C9_PEDIDO)) == Alltrim(cValToChar(SC5->C5_NUM))

				nVlrCred := 0
				SC9->(A460Estorna(/*lMata410*/,/*lAtuEmp*/,@nVlrCred))

				SC9->(DbSkip())

			EndDo

		EndIf

		//Marca todos os itens existentes para excluir.
		DbSelectArea("SC6")
		SC6->(DbSetOrder(1))
		SC6->(DbGoTop())
		If SC6->(DbSeek( FWxFilial("SC6") + cNumPed ))

			//
			While ! SC6->(Eof()) .And. SC6->C6_FILIAL == FWxFilial("SC6") .And. SC6->C6_NUM == cNumPed

				aItem := {} 
				Aadd(aItem,{"LINPOS","C6_ITEM",SC6->C6_ITEM})
				Aadd(aItem,{"AUTDELETA","S", Nil})        
				Aadd(aItem,{"C6_FILIAL" , FWxFilial("SC6") , Nil})  
				Aadd(aItem,{"C6_NUM"    , cNumPed        , Nil})          	      
				Aadd(aItem,{"C6_ITEM"   , SC6->C6_ITEM   , Nil})
				Aadd(aItem,{"C6_PRODUTO", SC6->C6_PRODUTO, Nil})
				Aadd(aItem,{"C6_QTDVEN" , SC6->C6_QTDVEN ,0 , Nil})
				Aadd(aItem,{"C6_PRCVEN" , SC6->C6_PRCVEN ,0 , Nil})
				Aadd(aItem,{"C6_VALOR"  , SC6->C6_VALOR  ,0 , Nil}) 
				Aadd(aItem,{"C6_UNSVEN" , SC6->C6_UNSVEN ,0 , Nil})

				aAdd(aItens,aItem)

				SC6->(DbSkip())

			EndDo

		EndIf
	EndIf
	//

	//Ordena os campos conforme dicionário de dados.
	aCabec := FWVetByDic(aCabec,"SC5",.F.,1)

	//
	If nOpc == 3
		aItens := FWVetByDic(aItens,"SC6",.T.,1)

	EndIf

	//
	cErro := ""
	lMsErroAuto := .F.

	//
	Begin Transaction

		__CUSERID := cUsrVend
		Conout( DToC(Date()) + " " + Time() + " ADVEN090P - RESTEXECUTE - INICIO EXECAUTO >>>> " + cNumPed + " OPCAO " + cValToChar(nOpc) )
		SetFunName("U_RESTEXECUTE")
		MsExecAuto({|x, y, z| MATA410(x, y, z)}, aCabec, aItens, nOpc) 
		Conout( DToC(Date()) + " " + Time() + " ADVEN090P - RESTEXECUTE - FIM EXECAUTO >>>> " + cNumPed)
		__CUSERID := cBckUsr

		If lMsErroAuto                              
			DisarmTransaction()
			Break

		Else

			//
			If nOpc == 4

				//Altera a numeração do item.
				DbSelectArea("SC6")
				SC6->(DbSetOrder(1))
				SC6->(DbGoTop())
				If SC6->(DbSeek( FWxFilial("SC6") + cNumPed ))

					//
					i := 1
					While ! SC6->(Eof()) .And. SC6->C6_FILIAL == FWxFilial("SC6") .And. SC6->C6_NUM == cNumPed

						RecLock("SC6",.F.)
						SC6->C6_ITEM := StrZero(i,2)
						MsUnlock()

						SC6->(DbSkip())

						i++

					EndDo

				EndIf

			ElseIf nOpc == 3

				//Valida o número gerado.
				If cNumPed <> Alltrim(cValToChar(SC5->C5_NUM))

					cErro += "Numeração divergente ZCI: " + cNumPed + " SC5: " + Alltrim(cValToChar(SC5->C5_NUM)) + "."
					DisarmTransaction()
					Break
					lRet := .F.
					RestArea(aArea)
					Return lRet

				EndIf


			EndIf

			lRet := .T.

		EndIf

	End Transaction 

	//
	If lMsErroAuto

		lRet := .F.
		aErroLog := GetAutoGrLog()

		//
		If Len(aErroLog) > 0
			cErro += EncodeUtf8(StrTran(StrTran(Alltrim(cValToChar(aErroLog[1])),Chr(13),""),Chr(10),""))

		EndIf

		//
		nAuxInvalido := 0			
		For k := 1 to Len(aErroLog)

			If "INVALIDO" $ UPPER (aErroLog[k])
				cErro += EncodeUtf8(StrTran(StrTran(Alltrim(cValToChar(aErroLog[k])),Chr(13),""),Chr(10),""))
				nAuxInvalido++

			EndIf

		Next

		//
		If nAuxInvalido == 0
			For k := 2 to Len(aErroLog)
				cErro += EncodeUtf8(StrTran(StrTran(Alltrim(cValToChar(aErroLog[k])),Chr(13),""),Chr(10),""))

			Next			

		EndIf

	EndIf

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} obtSeqSC6
	(long_description)
	@type  Static Function
	@author Everson
	@since 27/02/2018
	@version 01
/*/
Static Function obtSeqSC6(cPedido)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local cQuery := ""
	Local nSeq   := ""

	cQuery += " SELECT"
	cQuery += " MAX(C6_ITEM) AS C6_ITEM"
	cQuery += " FROM"
	cQuery += " " + RetSqlName("SC6") + " AS SC6 (NOLOCK)"
	cQuery += " WHERE"
	cQuery += " C6_FILIAL = '" + FWxFilial("SC6") + "'"
	cQuery += " AND C6_NUM = '" + cPedido + "'"

	If Select("SEQ_SC6") > 0
		SEQ_SC6->(DbCloseArea())

	EndIf

	TcQuery cQuery New Alias "SEQ_SC6"
	DbSelectArea("SEQ_SC6")
	nSeq := Val(cValToChar(SEQ_SC6->C6_ITEM)) + 1
	SEQ_SC6->(DbCloseArea())

Return nSeq
/*/{Protheus.doc} ³chkLiber
	Efetua a liberação/bloqueio do pedido de venda. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 09/05/2018
	@version 01
/*/
Static Function chkLiber(cNumPed,lPedBloq,lBlq,lProcessa,cErro)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea 	:= GetArea()
	Local lRet		:= .F.
	Local nVlrCred	:= 0
	Local nQtdLiber	:= 0
	Local lLiber    := .F.
	Local lTrans    := .F.
	Local lCredito  := .F.
	Local lEstoque  := .F.
	Local lAvCred   := .T.
	Local lAvEst    := .F.
	Local nQtdSC6	:= 0
	Local nQtdSC9	:= 0

	Private lNvLib	 := GetMv("MV_#SFNVPR",,.F.)

	Default lBlq	 := .T.
	Default lProcessa:= .F.
	Default cErro	 := ""

	//Localiza pedido na tabela SC5.
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(DbGoTop())
	If ! SC5->(DbSeek(FWxFilial("SC5") + cNumPed))
		cErro := "Liberação Não localizou o pedido " + cNumPed
		lProcessa := .F.
		lRet := .F.
		DisarmTransaction()
		Break

	EndIf
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADVEN090P - chkLiber - LIBERACAO " + cNumPed)

	//
	If lPedBloq

		//
		Begin transaction

			//Localiza pedido na tabela SC6.
			DbSelectArea("SC6")
			SC6->(DbSetOrder(1))
			SC6->(DbGoTop())
			SC6->(DbSeek(FWxFilial("SC6") + cNumPed))

			//Localiza o pedido na tabela SC9 e faz o estorno dos itens.
			DbSelectArea("SC9")
			SC9->(DbSetOrder(1))
			SC9->(DbGoTop())

			If SC9->(DbSeek(FWxFilial("SC9") + cNumPed))

				//Faz o estorno dos itens liberados.
				While Alltrim(cValToChar(SC9->C9_FILIAL)) == Alltrim(cValToChar(SC5->C5_FILIAL)) .And.;
				Alltrim(cValToChar(SC9->C9_PEDIDO)) == Alltrim(cValToChar(SC5->C5_NUM))

					nVlrCred := 0
					SC9->(A460Estorna(/*lMata410*/,/*lAtuEmp*/,@nVlrCred))

					//Gera log na tabela ZBE.
					logZBE("Estorno SC9 " + cValToChar(SC9->C9_PEDIDO), "Pedido " + cValToChar(SC9->C9_PEDIDO) + " Recno " + cValToChar(SC6->( Recno())))

					SC9->(DbSkip())

				EndDo

			EndIf

			//
			TCSqlExec(" UPDATE " + RetSqlName("SC9") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE C9_FILIAL = '" + FWxFilial("SC9") + "' AND C9_PEDIDO = '" + cNumPed + "' AND D_E_L_E_T_ = '' ")

			//Força bloqueio do pedido.
			RecLock("SC5",.F.)
				SC5->C5_BLQ     := "1"
				SC5->C5_LIBEROK := " "
			SC5->(MsUnlock())

			//Conta os itens na tabela SC9.
			nQtdSC9 := 0
			DbSelectArea("SC9")
			SC9->(DbSetOrder(1))
			SC9->(DbGoTop())

			//
			If SC9->(DbSeek(FWxFilial("SC9") + cNumPed))

				//Faz o estorno dos itens liberados.
				While Alltrim(cValToChar(SC9->C9_FILIAL)) == Alltrim(cValToChar(SC5->C5_FILIAL)) .And.;
				Alltrim(cValToChar(SC9->C9_PEDIDO)) == Alltrim(cValToChar(SC5->C5_NUM))
					nQtdSC9++

					SC9->(DbSkip())

				EndDo

			EndIf			

			//Não pode haver SC9.
			If nQtdSC9 > 0
				cErro := "SC9 divergente de SC6"
				lProcessa := .F.
				lRet := .F.
				DisarmTransaction()
				Break
				//RestArea(aArea)
				//Return lRet

			EndIf

			//
			lProcessa := .T.
			lRet := .T.

		End transaction

	Else

		//
		Begin transaction

			//Força liberação do pedido.
			RecLock("SC5",.F.)
				SC5->C5_BLQ     := " "
				SC5->C5_LIBEROK := "S"
			SC5->(MsUnlock())

			// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 22/04/2020
			/*
			If AllTrim(Posicione("SE4",1,FWxFilial("SE4")+SC5->C5_CONDPAG,"E4_CTRADT")) == "1" // Cond Adiantamento = SIM

				msAguarde( { || u_GeraRAPV() }, "Gerando boleto de adiantamento e amarração com PV n " + SC5->C5_NUM )
				
				// Checo amarração RA x PV
				FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
				If FIE->( dbSeek(SC5->C5_FILIAL+"R"+SC5->C5_NUM) )
					U_ADVEN050P(SC5->C5_NUM,.T.,.F.,"",.F.,.F.,.F.,.F.,.F.,.F.,0,1)
				EndIf

			EndIf
			*/
			//

			//
			DbSelectArea("SC9")
			SC9->(DbSetOrder(1))
			If SC9->( DbSeek( xfilial("SC9") + cNumPed) )
				While ! SC9->(Eof()) .And. SC9->C9_FILIAL == FWxFilial("SC9") .And. Alltrim(cValToChar(SC9->C9_PEDIDO)) == cNumPed

					Reclock("SC9",.F.)
					DbDelete()
					SC9->(Msunlock())

					SC9->(Dbskip())
				Enddo
			EndIf

			//
			TCSqlExec(" UPDATE " + RetSqlName("SC9") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE C9_FILIAL = '" + FWxFilial("SC9") + "' AND C9_PEDIDO = '" + cNumPed + "' AND D_E_L_E_T_ = '' ")

			//
			nQtdSC6 := 0
			DbSelectArea("SC6")
			SC6->(DbSetOrder(1))
			SC6->(DbGoTop())

			If  SC6->( DbSeek(FWxFilial("SC6") + cNumPed) )

				While ! SC6->(Eof()) .And. SC6->C6_FILIAL ==  FWxFilial("SC6") .And. SC6->C6_NUM == cNumPed

					nQtdLiber := SC6->C6_QTDVEN
					RecLock("SC6")

					//Begin transaction

					//If  !lNvLib 
						MaLibDoFat( SC6->( Recno() ), @nQtdLiber, @lCredito, @lEstoque, lAvCred, lAvEst, lLiber, lTrans )

					//Else
						//U_ADVEN095P( SC6->( Recno() ), @nQtdLiber, @lCredito, @lEstoque, lAvCred, lAvEst, lLiber, lTrans )

					//EndIf

					//End transaction

					//Begin Transaction
					SC6->(MaLiberOk({cNumPed},.F.))
					//End Transaction

					//Gera log na tabela ZBE.
					logZBE("Liberação SC6 pedido " + cValToChar(SC6->C6_NUM), "Pedido " + cValToChar(SC6->C6_NUM) + " Recno " + cValToChar(SC6->( Recno())))

					nQtdSC6++
					SC6->(DbSkip())

				EndDo

			EndIf

			//
			nQtdSC9 := 0
			DbSelectArea("SC9")
			SC9->(DbSetOrder(1))
			If SC9->( DbSeek( xfilial("SC9") + cNumPed) )
				While ! SC9->(Eof()) .And. SC9->C9_FILIAL == FWxFilial("SC9") .And. Alltrim(cValToChar(SC9->C9_PEDIDO)) == cNumPed

					Reclock("SC9",.F.)
					SC9->C9_ROTEIRO := SC5->C5_ROTEIRO
					SC9->C9_VEND1   := SC5->C5_VEND1
					SC9->C9_DTENTR  := SC5->C5_DTENTR
					SC9->(Msunlock())

					//Gera log na tabela ZBE.
					logZBE("Roteiro SC9 pedido " + cValToChar(SC9->C9_PEDIDO) , "Pedido " + cValToChar(SC9->C9_PEDIDO) + " Recno " + cValToChar(SC9->(Recno())))

					nQtdSC9++
					SC9->(Dbskip())

				Enddo
			EndIf

			//Gera log na tabela ZBE.
			logZBE("Quantidade SC6 ("+ cValToChar(nQtdSC6) +") x SC9 (" + cValToChar(nQtdSC9) + ") - SC5 pedido " + cNumPed, "Pedido " + cNumPed)

			//Valida quantidade SC6 e SC9.
			If nQtdSC9 <> nQtdSC6 
				cErro := "SC9 divergente de SC6"
				lProcessa := .F.
				lRet := .F.
				DisarmTransaction()
				Break
				//RestArea(aArea)
				//Return lRet

			EndIf

			//
			lProcessa := .T.
			lRet := .T.

		End Transaction

	EndIf

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} ³logZBN
	Gera log na ZBN. Chamado 037261;
	@type  Static Function
	@author Everson
	@since 09/05/2018
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
	If ZBN->(DbSeek(FWxFilial("ZBN") + 'ADVEN090P'))

		RecLock("ZBN",.F.)

		ZBN_FILIAL  := FWxFilial("ZBN")
		ZBN_DATA    := Date()
		ZBN_HORA    := cValToChar(Time())
		ZBN_ROTINA	:= 'ADVEN090P'
		ZBN_STATUS	:= cStatus

		MsUnlock() 

	Else

		RecLock("ZBN",.T.)

		ZBN_FILIAL  := FWxFilial("ZBN")
		ZBN_DATA    := Date()
		ZBN_HORA    := cValToChar(Time())
		ZBN_ROTINA	:= 'ADVEN090P'
		ZBN_STATUS	:= cStatus

		MsUnlock() 	

	EndIf

	ZBN->(dbCloseArea())

	RestArea(aArea)

Return Nil
/*/{Protheus.doc} ³procCorte
	Efetua corte no pedido de venda. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 11/05/2018
	@version 01
/*/
Static Function procCorte(oParseJSON,cPedido,lPedBloq)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea	:= GetArea()
	Local lRet	:= .T.
	Local i 	:= 1

	//
	Begin transaction

		For i := 1 To Len(oParseJSON:ITENS)

			//
			If Upper(Alltrim(cValToChar(oParseJSON:ITENS[i]:excluir))) == "S" .Or. Val(cValToChar(oParseJSON:ITENS[i]:C6_UNSVEN)) <= 0 .Or. Val(cValToChar(oParseJSON:ITENS[i]:C6_QTDVEN)) <= 0 .And.!Empty(cValToChar(oParseJSON:ITENS[i]:C6_ITEM))			
				Loop

			Else

				If ! SC6->( DbSeek( FWxFilial("SC6") + Alltrim(cValToChar( oParseJSON:ITENS[i]:C6_ITEM )) ) )
					lRet := .F.
					DisarmTransaction()
					Break
					RestArea(aArea)
					Return lRet

				EndIf

				//Altera os dados.
				Reclock("SC6",.F.)
				SC6->C6_QTDVEN  := Val(cValToChar(oParseJSON:ITENS[i]:C6_QTDVEN))
				SC6->C6_UNSVEN  := Val(cValToChar(oParseJSON:ITENS[i]:C6_UNSVEN))
				SC6->C6_PRCVEN	:= Val(cValToChar(oParseJSON:ITENS[i]:C6_PRCVEN))
				SC6->C6_VALOR   := Val(cValToChar(oParseJSON:ITENS[i]:C6_QTDVEN)) * Val(cValToChar(oParseJSON:ITENS[i]:C6_PRCVEN))
				SC6->C6_QTDLIB  := 0
				SC6->C6_QTDLIB2 := 0
				SC6->C6_QTDEMP  := 0
				SC6->C6_QTDEMP2 := 0
				SC6->C6_PEDCLI  := Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_PEDCLI))
				SC6->C6_NFORI   := Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_NFORI))
				SC6->C6_SERIORI	:= Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_SERIORI))	
				SC6->C6_NUMPCOM := Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_NUMPCOM))	
				SC6->C6_ITEMPC  := Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_ITEMPC))	

				SC6->C6_XIPTAB  := Val( Substr(cValToChar(oParseJSON:ITENS[i]:C6_XIPTAB),1,TamSX3("C6_XIPTAB ")[1]))
				SC6->C6_TOTDIG  := Val( Substr(cValToChar(oParseJSON:ITENS[i]:C6_TOTDIG),1,TamSX3("C6_TOTDIG")[1] ))
				SC6->C6_TOTTAB  := Val( Substr(cValToChar(oParseJSON:ITENS[i]:C6_TOTTAB),1,TamSX3("C6_TOTTAB")[1]))

				SC6->C6_PRTABV  := Val( Substr(cValToChar(oParseJSON:ITENS[i]:C6_PRTABV),1,5))
				SC6->C6_PBTTV   := Val( Substr(cValToChar(oParseJSON:ITENS[i]:C6_PBTTV) ,1,5))
				SC6->C6_PLTTV   := Val( Substr(cValToChar(oParseJSON:ITENS[i]:C6_PLTTV) ,1,5))
				SC6->C6_PLTVD   := Val( Substr(cValToChar(oParseJSON:ITENS[i]:C6_PLTVD) ,1,5))
				SC6->C6_PLTSP   := Val( Substr(cValToChar(oParseJSON:ITENS[i]:C6_PLTSP) ,1,5))
				SC6->C6_PLTAB   := Val( Substr(cValToChar(oParseJSON:ITENS[i]:C6_PLTAB) ,1,5))

				SC6->(Msunlock())

			EndIf

		Next i

	End Transaction

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} checkProc
	Checa qual processamento deve ser executado para o pedido.
	1- Execauto de alteração, 2-Liberação comercial 3-Corte
	@type  Static Function
	@author Everson
	@since 11/05/2018
	@version 01
/*/
Static Function checkProc(oParseJSON,cPedido)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea	:= GetArea()
	Local nRet	:= 0
	Local lCab	:= .F.
	Local nItens:= 0

	//Verifica se o cabeçalho recebido é igual ao que consta no Protheus.	
	lCab := comparaCab(oParseJSON,cPedido)
	If ! lCab
		nRet := 1
		RestArea(aArea)
		Return nRet

	EndIf

	//Verifica se os itens recebidos são iguais aos que constam no Protheus.	
	nItens := comparaItens(oParseJSON,cPedido)

	//Valida se é liberação de pedido de venda.
	If lCab .And. nItens == 1
		nRet := 2

	EndIf

	//Valida se é ajuste na quantidade do pedido de venda.
	If lCab .And. nItens == 2
		nRet := 3

	EndIf	

	//
	If nRet == 0
		nRet := 1

	EndIf

	//
	RestArea(aArea)

Return nRet
/*/{Protheus.doc} comparaCab
	Compara json do cabeçalho do pedido de venda. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 10/05/2018
	@version 01
/*/
Static Function comparaCab(oParseJSON,cPedido)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea	  := GetArea()
	Local cJsonSF := ""
	Local cJsonPr := ""
	Local lRet    := .F.
	Local cData	  := "" //Everson - 28/12/2019 - Chamado T.I.

	//Monta string do SalesForce.
	cJsonSF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_TIPO)) +"_"

	cJsonSF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_CLIENTE)) +"_"

	cJsonSF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_LOJACLI)) +"_"

	//Everson - 28/12/2019 - Chamado T.I.
	If (SToD(oParseJSON:CABECALHO:C5_DTENTR) - dDataBase) > 20
		cData := Substr(DToS(dDataBase),1,4)+Substr(oParseJSON:CABECALHO:C5_DTENTR,5,10)

	Else
		cData := oParseJSON:CABECALHO:C5_DTENTR

	EndIf
	//

	cJsonSF += DToS(SToD(Alltrim(cValToChar(cData)))) +"_"

	cJsonSF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_MOEDA)) +"_"

	cJsonSF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_XPEDORD)) +"_"

	cJsonSF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_OPLOG)) +"_"

	//cJsonSF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_TABELA)) +"_"

	cJsonSF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_TPFRETE)) +"_"

	cJsonSF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_FRETAPV)) +"_"

	//cJsonSF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_XIPTAB)) +"_"

	//cJsonSF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_TOTDIG)) +"_"

	//cJsonSF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_TOTTAB)) +"_"

	//cJsonSF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_DESCTBP)) +"_"

	cJsonSF += Alltrim(cValToChar( Round(oParseJSON:CABECALHO:C5_VALORNF,2) )) +"_"
	/* @history Chamado 66524 - Leonardo P. Monteiro  - 11/01/2022 - Correção na função comparaCab responsável pela comparação do cabeçalho dos PVs. Tratamento dos campos de mensagens C5_MENNOTA para a correta decodificação.
	cJsonSF += FwNoAccent( Substr( Alltrim(cValToChar(oParseJSON:CABECALHO:C5_MENNOTA)) ,1, TamSX3("C5_MENNOTA")[1] ) ) +"_"

	cJsonSF += FwNoAccent( Substr(Alltrim(cValToChar(oParseJSON:CABECALHO:C5_MENNOT2))  ,1, TamSX3("C5_MENNOT2")[1] ) )  +"_"

	cJsonSF += FwNoAccent( Substr(Alltrim(cValToChar(oParseJSON:CABECALHO:C5_MENNOT3))  ,1, TamSX3("C5_MENNOT3")[1] ) )  +"_"

	cJsonSF += FwNoAccent( Substr(Alltrim(cValToChar(oParseJSON:CABECALHO:C5_MENNOT4))  ,1, TamSX3("C5_MENNOT4")[1] ) )  +"_"

	cJsonSF += FwNoAccent( Substr(Alltrim(cValToChar(oParseJSON:CABECALHO:C5_MENNOT5))  ,1, TamSX3("C5_MENNOT5")[1] ) )  +"_"
	*/
	
	cJsonSF += FwNoAccent( Substr( DecodeUTF8(Alltrim(cValToChar(oParseJSON:CABECALHO:C5_MENNOTA))) ,1, TamSX3("C5_MENNOTA")[1] ) ) +"_"

	cJsonSF += FwNoAccent( Substr( DecodeUTF8(Alltrim(cValToChar(oParseJSON:CABECALHO:C5_MENNOT2)))  ,1, TamSX3("C5_MENNOT2")[1] ) )  +"_"

	cJsonSF += FwNoAccent( Substr( DecodeUTF8(Alltrim(cValToChar(oParseJSON:CABECALHO:C5_MENNOT3)))  ,1, TamSX3("C5_MENNOT3")[1] ) )  +"_"

	cJsonSF += FwNoAccent( Substr( DecodeUTF8(Alltrim(cValToChar(oParseJSON:CABECALHO:C5_MENNOT4)))  ,1, TamSX3("C5_MENNOT4")[1] ) )  +"_"

	cJsonSF += FwNoAccent( Substr( DecodeUTF8(Alltrim(cValToChar(oParseJSON:CABECALHO:C5_MENNOT5)))  ,1, TamSX3("C5_MENNOT5")[1] ) )  +"_"
	cJsonSF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_XREDE)) +"_"

	cJsonSF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_CODRED)) +"_"

	//cJsonSF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_XEMSF)) +"_"

	//cJsonSF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_XITSF)) +"_"

	//cJsonSF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_PBRUTO)) +"_"

	//cJsonSF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_PESOL)) +"_"

	//cJsonSF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_VOLUME1)) +"_"

	cJsonSF += Alltrim(cValToChar( Round(oParseJSON:CABECALHO:C5_VALORNF,2) )) +"_"

	cJsonSF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_CONDPAG)) +"_"

	//cJsonSF += Alltrim(cValToChar(oParseJSON:CABECALHO:tpSaida)) +"_"


	//Monta string do Protheus

	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	If SC5->(DbSeek( FWxFilial("SC5") + cPedido))
		cJsonPr += Alltrim(cValToChar(SC5->C5_TIPO)) +"_"

		cJsonPr += Alltrim(cValToChar(SC5->C5_CLIENTE)) +"_"

		cJsonPr += Alltrim(cValToChar(SC5->C5_LOJACLI)) +"_"

		cJsonPr += Alltrim(cValToChar(DToS(SC5->C5_DTENTR))) +"_"

		cJsonPr += Alltrim(cValToChar(SC5->C5_MOEDA)) +"_"

		cJsonPr += Alltrim(cValToChar(SC5->C5_XPEDORD)) +"_"

		cJsonPr += Alltrim(cValToChar(SC5->C5_OPLOG)) +"_"

		//cJsonPr += Alltrim(cValToChar(SC5->C5_TABELA)) +"_"

		cJsonPr += Alltrim(cValToChar(SC5->C5_TPFRETE)) +"_"

		cJsonPr += Alltrim(cValToChar(SC5->C5_FRETAPV)) +"_"

		//cJsonPr += Alltrim(cValToChar(SC5->C5_XIPTAB)) +"_"

		//cJsonPr += Alltrim(cValToChar(SC5->C5_TOTDIG)) +"_"

		//cJsonPr += Alltrim(cValToChar(SC5->C5_TOTTAB)) +"_"

		//cJsonPr += Alltrim(cValToChar(SC5->C5_DESCTBP)) +"_"

		cJsonPr += Alltrim(cValToChar(SC5->C5_VALORNF)) +"_"

		cJsonPr += FwNoAccent( Substr( Alltrim(cValToChar(SC5->C5_MENNOTA)) ,1, TamSX3("C5_MENNOTA")[1] ) ) +"_"

		cJsonPr += FwNoAccent( Substr( Alltrim(cValToChar(SC5->C5_MENNOT2)) ,1, TamSX3("C5_MENNOT2")[1] ) ) +"_"

		cJsonPr += FwNoAccent( Substr( Alltrim(cValToChar(SC5->C5_MENNOT3)) ,1, TamSX3("C5_MENNOT3")[1] ) ) +"_"

		cJsonPr += FwNoAccent( Substr( Alltrim(cValToChar(SC5->C5_MENNOT4)) ,1, TamSX3("C5_MENNOT4")[1] ) ) +"_"

		cJsonPr += FwNoAccent( Substr( Alltrim(cValToChar(SC5->C5_MENNOT5)) ,1, TamSX3("C5_MENNOT5")[1] ) ) +"_"

		cJsonPr += Alltrim(cValToChar(SC5->C5_XREDE)) +"_"

		cJsonPr += Alltrim(cValToChar(SC5->C5_CODRED)) +"_"

		//cJsonPr += Alltrim(cValToChar(SC5->C5_XEMSF)) +"_"

		//cJsonPr += Alltrim(cValToChar(SC5->C5_XITSF)) +"_"

		//cJsonPr += Alltrim(cValToChar(SC5->C5_PBRUTO)) +"_"

		//cJsonPr += Alltrim(cValToChar(SC5->C5_PESOL)) +"_"

		//cJsonPr += Alltrim(cValToChar(SC5->C5_VOLUME1)) +"_"

		cJsonPr += Alltrim(cValToChar(SC5->C5_VALORNF)) +"_"

		cJsonPr += Alltrim(cValToChar(SC5->C5_CONDPAG)) +"_"

		//cJsonPr += Alltrim(cValToChar(SC5->C5_XSFTP)) +"_"

	EndIf

	//Verifica se o cabeçalho recebido é igual ao que consta no Protheus.	
	If cJsonPr == cJsonSF
		lRet := .T.

	Else

		logZBE("CABECALHO DIVERGE " + cPedido, "PRO: " + cJsonPr)
		logZBE("CABECALHO DIVERGE " + cPedido, "SFC: " + cJsonSF)

	EndIf

	//
	cJsonPr := ""
	cJsonSF := ""

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} comparaItens
	Compara json dos itens do pedido de venda. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 11/05/2018 
	@version 01
/*/
Static Function comparaItens(oParseJSON,cPedido)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea		:= GetArea()
	Local nRet		:= 0
	Local i			:= 1
	Local cJsonSF	:= ""
	Local cJsonPr	:= ""

	//
	DbSelectArea("SC6")
	SC6->(DbSetOrder(12))
	SC6->(DbGoTop())

	//
	For i := 1 To Len(oParseJSON:ITENS)

		//
		If Upper(Alltrim(cValToChar(oParseJSON:ITENS[i]:excluir))) == "S" .Or. Val(cValToChar(oParseJSON:ITENS[i]:C6_UNSVEN)) <= 0 .Or. Val(cValToChar(oParseJSON:ITENS[i]:C6_QTDVEN)) <= 0 .And.!Empty(cValToChar(oParseJSON:ITENS[i]:C6_ITEM))			
			Loop

		Else

			If ! SC6->( DbSeek( FWxFilial("SC6") + Alltrim(cValToChar( oParseJSON:ITENS[i]:C6_ITEM )) ) )

				logZBE("ITEM NAO ENCONTRADO " + cPedido, "ITEM SF: " + Alltrim(cValToChar( oParseJSON:ITENS[i]:C6_ITEM )))
				RestArea(aArea)
				nRet := 0
				Return nRet

			EndIf

			//Monta string SalesForce.
			cJsonSF += Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_PRODUTO)) +"_"
			cJsonSF += Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_UNSVEN))  +"_"
			cJsonSF += Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_PRCVEN))  +"_"
			//cJsonSF += Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_QTDVEN))  +"_"		
			cJsonSF += FwNoAccent( Substr( Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_PEDCLI)), 1, TamSX3("C6_PEDCLI")[1]) )   +"_"
			//cJsonSF += Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_PEDCLI))  +"_"
			cJsonSF += Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_NFORI))   +"_"
			cJsonSF += Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_SERIORI)) +"_"			
			cJsonSF += FwNoAccent( Substr( Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_NUMPCOM)), 1, TamSX3("C6_NUMPCOM")[1]) ) +"_"
			//cJsonSF += Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_NUMPCOM)) +"_"
			cJsonSF += FwNoAccent( Substr( Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_ITEMPC)), 1, TamSX3("C6_ITEMPC")[1]) )   +"_"
			//cJsonSF += Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_ITEMPC))  +"_"

			//Monta string Protheus.
			cJsonPr += Alltrim(cValToChar(SC6->C6_PRODUTO)) +"_"
			cJsonPr += Alltrim(cValToChar(SC6->C6_UNSVEN))  +"_"
			cJsonPr += Alltrim(cValToChar(SC6->C6_PRCVEN))  +"_"
			//cJsonPr += Alltrim(cValToChar(SC6->C6_QTDVEN))	+"_"	
			cJsonPr += FwNoAccent( Substr( Alltrim(cValToChar(SC6->C6_PEDCLI)), 1, TamSX3("C6_PEDCLI")[1]) )    +"_"
			cJsonPr += Alltrim(cValToChar(SC6->C6_NFORI))   +"_"
			cJsonPr += Alltrim(cValToChar(SC6->C6_SERIORI)) +"_"			
			cJsonPr += FwNoAccent( Substr( Alltrim(cValToChar(SC6->C6_NUMPCOM)), 1, TamSX3("C6_NUMPCOM")[1]) )  +"_"
			cJsonPr += FwNoAccent( Substr( Alltrim(cValToChar(SC6->C6_ITEMPC)), 1, TamSX3("C6_ITEMPC")[1]) )	+"_"

			//
			If cJsonSF <> cJsonPr

				logZBE("ITEM DIFERENTE " + cPedido, "PR: " + cJsonPr + " SF: " + cJsonSF)

				RestArea(aArea)
				nRet := 0
				Return nRet

			EndIf

			//
			cJsonSF := ""
			cJsonPr := ""

		EndIf

	Next i

	//
	nRet := 1
	RestArea(aArea)

Return nRet
/*/{Protheus.doc} ³updStPut
	Executa update nos registros PUT pendentes. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 11/05/2018 
	@version 01
/*/
Static Function updStPut(cPedido,cRecno)

	TCSqlExec("UPDATE " + RetSqlName("ZCI") + " SET ZCI_TMPR = 'DESCARTA' WHERE ZCI_FILIAL = '" + cFilAnt + "' AND ZCI_TMPR = 'PENDPROC' AND ZCI_NUMP = '" + cPedido + "' AND ZCI_TMPR = 'PENDPROC' AND ZCI_METD = 'PUT' AND D_E_L_E_T_ = '' AND R_E_C_N_O_ < '" + cRecno + "'")			

Return Nil
/*/{Protheus.doc} csqlTScript
	Script sql processamento ZCI. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 13/05/2018
	@version 01
/*/
Static Function csqlTScript(cRecnos)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local cQuery := ""

	//
	cQuery += " SELECT ZCI_NUMP, R_E_C_N_O_ AS REC, ZCI_METD, ZCI_TPALT, ZCI_CONSIN "
	cQuery += " FROM "
	cQuery += " " + RetSqlName("ZCI") + " AS ZCI "
	cQuery += " WHERE "
	cQuery += " R_E_C_N_O_ IN (" + cRecnos + ") "

Return cQuery
/*/{Protheus.doc} exclPedVend
	MsExecauto pedido de venda (exclusão). Chamado 037261.
	@type  Static Function
	@author Everson
	@since 06/06/2018
	@version 01
/*/
Static Function exclPedVend(cErro,cNumPed)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea			:= GetArea()
	Local lRet			:= .F.	
	Local cDoc			:= ""
	Local aCabec		:= {}
	Local aItens		:= {}
	Local aItem			:= {}
	Local aErroLog		:= {}
	Local k				:= 1
	Local nAuxInvalido	:= 0

	Private lMsErroAuto		:= .F.
	Private lAutoErrNoFile 	:= .T.

	Default cErro		:= ""

	//
	cErro := ""
	chkLiber(cNumPed,.T.,.F.)

	//
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(DbGoTop())
	If ! SC5->(DbSeek(FWxFilial("SC5") + cNumPed))
		SC5->(DbCloseArea())
		RestArea(aArea)
		lRet := .T.
		Return lRet

	EndIf

	// Monta cabeçalho do pedido de venda.
	aCabec := {}
	Aadd(aCabec,{"C5_FILIAL" , FWxFilial("SC5")      ,Nil})           
	Aadd(aCabec,{"C5_NUM"    , SC5->C5_NUM         ,Nil})
	Aadd(aCabec,{"C5_TIPO"   , SC5->C5_TIPO        ,Nil}) 
	Aadd(aCabec,{"C5_CLIENTE", SC5->C5_CLIENTE     ,Nil})
	Aadd(aCabec,{"C5_LOJACLI", SC5->C5_LOJACLI     ,Nil}) 
	Aadd(aCabec,{"C5_DTENTR" , SToD(cValToChar(SC5->C5_DTENTR)) ,Nil})
	SC5->(DbCloseArea())

	//
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(DbGoTop())
	If ! SC6->(DbSeek(FWxFilial("SC6") + cNumPed))
		cErro := "Pedido de venda número " + cNumPed + " não encontrado(montagem dos itens)."
		SC6->(DbCloseArea())
		RestArea(aArea)
		Return lRet

	EndIf

	//
	While ! SC6->(Eof()) .And. SC6->C6_FILIAL == FWxFilial("SC6") .And. SC6->C6_NUM == cNumPed

		aItem := {} 
		Aadd(aItem,{"LINPOS","C6_ITEM",SC6->C6_ITEM})
		Aadd(aItem,{"AUTDELETA","S", Nil})        
		Aadd(aItem,{"C6_FILIAL" , FWxFilial("SC6") , Nil})  
		Aadd(aItem,{"C6_NUM"    , cNumPed        , Nil})          	      
		Aadd(aItem,{"C6_ITEM"   , SC6->C6_ITEM   , Nil})
		Aadd(aItem,{"C6_PRODUTO", SC6->C6_PRODUTO, Nil})
		Aadd(aItem,{"C6_QTDVEN" , SC6->C6_QTDVEN ,0 , Nil})
		Aadd(aItem,{"C6_PRCVEN" , SC6->C6_PRCVEN ,0 , Nil})
		Aadd(aItem,{"C6_VALOR"  , SC6->C6_VALOR  ,0 , Nil}) 
		Aadd(aItem,{"C6_UNSVEN" , SC6->C6_UNSVEN ,0 , Nil})

		aAdd(aItens,aItem)

		SC6->(DbSkip())

	EndDo
	SC6->(DbCloseArea())

	//
	cErro := ""
	lMsErroAuto := .F.

	//Localiza o pedido na tabela SC9 e faz o estorno dos itens.
	DbSelectArea("SC9")
	SC9->(DbSetOrder(1))
	SC9->(DbGoTop())
	If SC9->(DbSeek(FWxFilial("SC9") + cNumPed))

		//Faz o estorno dos itens liberados.
		While Alltrim(cValToChar(SC9->C9_FILIAL)) == FWxFilial("SC9") .And.;
		Alltrim(cValToChar(SC9->C9_PEDIDO)) == cNumPed

			nVlrCred := 0
			SC9->(A460Estorna(/*lMata410*/,/*lAtuEmp*/,@nVlrCred))

			SC9->(DbSkip())

		EndDo

	EndIf	

	//
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(DbGoTop())
	If SC6->(DbSeek(FWxFilial("SC6") + cNumPed ))

		//Zera quantidade liberada.
		While Alltrim(cValToChar(SC6->C6_FILIAL)) == FWxFilial("SC6") .And.;
		Alltrim(cValToChar(SC6->C6_NUM)) == cNumPed

			RecLock("SC6",.F.)
			SC6->C6_QTDLIB	:= 0			
			SC6->C6_QTDEMP	:= 0	
			SC6->C6_QTDLIB2	:= 0
			SC6->C6_QTDEMP2	:= 0     
			SC6->(MsUnlock())

			SC6->(DbSkip())

		EndDo

	EndIf

	//
	Begin Transaction

		MsExecAuto({|x, y, z| MATA410(x, y, z)}, aCabec, aItens, 5) 

		If lMsErroAuto                              
			DisarmTransaction()
			Break

		EndIf

	End Transaction 

	//
	If lMsErroAuto

		lRet := .F.
		DisarmTransaction()
		aErroLog := GetAutoGrLog()

		//
		If Len(aErroLog) > 0
			cErro += EncodeUtf8(StrTran(StrTran(Alltrim(cValToChar(aErroLog[1])),Chr(13),""),Chr(10),""))

		EndIf

		//
		nAuxInvalido := 0			
		For k := 1 to Len(aErroLog)

			If "INVALIDO" $ UPPER (aErroLog[k])
				cErro += EncodeUtf8(StrTran(StrTran(Alltrim(cValToChar(aErroLog[k])),Chr(13),""),Chr(10),""))
				nAuxInvalido++

			EndIf

		Next

		//
		If nAuxInvalido == 0
			For k := 2 to Len(aErroLog)
				cErro += EncodeUtf8(StrTran(StrTran(Alltrim(cValToChar(aErroLog[k])),Chr(13),""),Chr(10),""))

			Next			

		EndIf

	Else
		cNumPed := cDoc
		lRet := .T.

	EndIf

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} checkSC9
	Checa duplicidade na SC9. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 15/06/2018
	@version 01
/*/
Static Function checkSC9()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local cUpdt 	:= ""
	Local cMsg		:= ""
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADVEN090P - checkSC9")
	
	cQuery := ""
	cQuery += " SELECT FONTE.REC FROM  " 
	cQuery += " ( " 
	cQuery += " SELECT ZCI_NUMP, MAX(R_E_C_N_O_) AS REC FROM " + RetSqlName("ZCI") + " (NOLOCK) WHERE ZCI_METD = 'PUT' AND ZCI_NUMP <> '' AND ZCI_NUMP IN ( " 
	cQuery += " ( " 
	cQuery += " SELECT  " 
	cQuery += " RTRIM(LTRIM(FONTE.C5_NUM)) AS PED " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " C5_NUM, SC6.C6_PRODUTO AS PRODSC6, SC9.C9_PRODUTO AS PRODSC9, " 
	cQuery += " CASE WHEN SC6.C6_PRODUTO <> SC9.C9_PRODUTO  THEN 'ERRO' ELSE 'OK' END LOG, " 
	cQuery += " 'DIVERGÊNCIA Nº SC6 e SC9' AS 'Divergência - Qtd produtos SC6 e SC9' " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT C6_FILIAL, C6_NUM, COUNT(C6_PRODUTO) AS C6_PRODUTO FROM " + RetSqlName("SC6") + " (NOLOCK) AS SC6 WHERE SC6.D_E_L_E_T_ = ''  " 
	cQuery += " AND CAST(C6_ENTREG AS DATE) >= CAST(GETDATE()+1 AS DATE) " 
	cQuery += " AND CAST(C6_ENTREG AS DATE) <= CAST(GETDATE()+30 AS DATE) " 
	cQuery += " GROUP BY C6_FILIAL, C6_NUM) AS SC6 " 
	cQuery += " ON C5_FILIAL = C6_FILIAL " 
	cQuery += " AND C5_NUM = C6_NUM  " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT C9_FILIAL, C9_PEDIDO, COUNT(C9_PRODUTO) AS C9_PRODUTO FROM " + RetSqlName("SC9") + " (NOLOCK) AS SC9 WHERE SC9.D_E_L_E_T_ = ''  " 
	cQuery += " AND CAST(C9_DTENTR AS DATE) > = CAST(GETDATE()+1 AS DATE) " 
	cQuery += " AND CAST(C9_DTENTR AS DATE) <= CAST(GETDATE()+30 AS DATE) " 
	cQuery += " GROUP BY C9_FILIAL, C9_PEDIDO) AS SC9 " 
	cQuery += " ON SC6.C6_FILIAL = SC9.C9_FILIAL " 
	cQuery += " AND SC6.C6_NUM = SC9.C9_PEDIDO " 
	cQuery += " WHERE " 
	cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "' " 
	cQuery += " AND CAST(C5_DTENTR AS DATE) >= CAST(GETDATE()+1 AS DATE) " 
	cQuery += " AND CAST(C5_DTENTR AS DATE) <= CAST(GETDATE()+30 AS DATE) " 
	cQuery += " AND C5_XGERSF = '2' " 
	cQuery += " AND SC5.D_E_L_E_T_ = '' " 
	
	cQuery += " AND SC5.C5_PLACA = '' AND SC5.C5_NOTA = '' AND SC5.C5_XINT <> '3' " 
	
	cQuery += " ) AS FONTE " 
	cQuery += " WHERE FONTE.LOG = 'ERRO' " 
	cQuery += " ) " 
	cQuery += " ) " 
	cQuery += " GROUP BY ZCI_NUMP " 
	cQuery += " ) AS FONTE " 
	
	//
	If Select("CHK_UPD") > 0
		CHK_UPD->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "CHK_UPD"
	DbSelectArea("CHK_UPD")
	CHK_UPD->(DbGoTop())
	
	//
	If CHK_UPD->(Eof())
	Conout( DToC(Date()) + " " + Time() + " ADVEN090P - checkSC9: Não há regitros a serem reprocessados.")
		CHK_UPD->(DbCloseArea())
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	CHK_UPD->(DbCloseArea())
	
	Conout( DToC(Date()) + " " + Time() + " ADVEN090P - checkSC9: Início reprocessamento de pedidos.")
	
	//
	cUpdt := ""
	cUpdt += " UPDATE " + RetSqlName("ZCI") + " SET ZCI_TMPR = 'PENDPROC', ZCI_TPALT = 'R'  WHERE ZCI_FILIAL = '" + FWxFilial("ZCI") + "' AND R_E_C_N_O_ > 0 AND R_E_C_N_O_ IN " 
	cUpdt += " ( " 
	cUpdt += " SELECT FONTE.REC FROM  " 
	cUpdt += " ( " 
	cUpdt += " SELECT ZCI_NUMP, MAX(R_E_C_N_O_) AS REC FROM " + RetSqlName("ZCI") + " (NOLOCK) WHERE ZCI_METD = 'PUT' AND ZCI_NUMP <> '' AND ZCI_NUMP IN ( " 
	cUpdt += " ( " 
	cUpdt += " SELECT  " 
	cUpdt += " RTRIM(LTRIM(FONTE.C5_NUM)) AS PED " 
	cUpdt += " FROM " 
	cUpdt += " ( " 
	cUpdt += " SELECT " 
	cUpdt += " C5_NUM, SC6.C6_PRODUTO AS PRODSC6, SC9.C9_PRODUTO AS PRODSC9, " 
	cUpdt += " CASE WHEN SC6.C6_PRODUTO <> SC9.C9_PRODUTO  THEN 'ERRO' ELSE 'OK' END LOG, " 
	cUpdt += " 'DIVERGÊNCIA Nº SC6 e SC9' AS 'Divergência - Qtd produtos SC6 e SC9' " 
	cUpdt += " FROM " 
	cUpdt += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
	cUpdt += " LEFT OUTER JOIN " 
	cUpdt += " (SELECT C6_FILIAL, C6_NUM, COUNT(C6_PRODUTO) AS C6_PRODUTO FROM " + RetSqlName("SC6") + " (NOLOCK) AS SC6 WHERE SC6.D_E_L_E_T_ = ''  " 
	cUpdt += " AND CAST(C6_ENTREG AS DATE) >= CAST(GETDATE()+1 AS DATE) " 
	cUpdt += " AND CAST(C6_ENTREG AS DATE) <= CAST(GETDATE()+30 AS DATE) " 
	cUpdt += " GROUP BY C6_FILIAL, C6_NUM) AS SC6 " 
	cUpdt += " ON C5_FILIAL = C6_FILIAL " 
	cUpdt += " AND C5_NUM = C6_NUM  " 
	cUpdt += " LEFT OUTER JOIN " 
	cUpdt += " (SELECT C9_FILIAL, C9_PEDIDO, COUNT(C9_PRODUTO) AS C9_PRODUTO FROM " + RetSqlName("SC9") + " (NOLOCK) AS SC9 WHERE SC9.D_E_L_E_T_ = ''  " 
	cUpdt += " AND CAST(C9_DTENTR AS DATE) > = CAST(GETDATE()+1 AS DATE) " 
	cUpdt += " AND CAST(C9_DTENTR AS DATE) <= CAST(GETDATE()+30 AS DATE) " 
	cUpdt += " GROUP BY C9_FILIAL, C9_PEDIDO) AS SC9 " 
	cUpdt += " ON SC6.C6_FILIAL = SC9.C9_FILIAL " 
	cUpdt += " AND SC6.C6_NUM = SC9.C9_PEDIDO " 
	cUpdt += " WHERE " 
	cUpdt += " C5_FILIAL = '" + FWxFilial("SC5") + "' " 
	cUpdt += " AND CAST(C5_DTENTR AS DATE) >= CAST(GETDATE()+1 AS DATE) " 
	cUpdt += " AND CAST(C5_DTENTR AS DATE) <= CAST(GETDATE()+30 AS DATE) " 
	cUpdt += " AND C5_XGERSF = '2' " 
	cUpdt += " AND SC5.D_E_L_E_T_ = '' " 
	
	cUpdt += " AND SC5.C5_PLACA = '' AND SC5.C5_NOTA = '' AND SC5.C5_XINT <> '3' " 
	
	cUpdt += " ) AS FONTE " 
	cUpdt += " WHERE FONTE.LOG = 'ERRO' " 
	cUpdt += " ) " 
	cUpdt += " ) " 
	cUpdt += " GROUP BY ZCI_NUMP " 
	cUpdt += " ) AS FONTE " 
	cUpdt += " ) " 
	
	//
	If TCSqlExec(cUpdt) < 0
		cMsg := "Erro update registros duplicados SC9 " + Chr(13) + Chr(10) + "TCSQLError() " + TCSQLError()
		Conout( DToC(Date()) + " " + Time() + " ADVEN090P - checkSC9 [ERRO] - TCSqlExec " + Chr(13) + Chr(10) + cMsg )
	EndIf
	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} chkBloTb
	Checa se é possível bloquear os registros. 
	Chamado 63090.
	@type  Static Function
	@author Everson
	@since 01/11/2021
	@version 01
/*/
Static Function chkBloTb(nOpc, lLodData, cErro, cPed, aSB2)

	//Variáveis.
	Local aArea		:= GetArea()
	Local lRet     	:= .T.
	// Local aSC5		:= {}
	// Local cCliLoj	:= ""
	// Local aSA1		:= {}

	Default cErro	:= ""
	Default aSB2	:= {}

	//
	If lLodData

		//
		DbSelectArea("SC5")
		SC5->(DbSetOrder(1))
		If ! SC5->(DbSeek(FWxFilial("SC5") + cPed))
			RestArea(aArea)
			Return lRet

		EndIf

		//
		DbSelectArea("SC6")
		SC6->(DbSetOrder(1))
		SC6->(DbGoTop())
		If ! SC6->(DbSeek(FWxFilial("SC6") + cPed))
			RestArea(aArea)
			Return lRet

		EndIf

		//
		While ! SC6->(Eof()) .And. SC6->C6_FILIAL == FWxFilial("SC6") .And. SC6->C6_NUM == cPed
			Aadd(aSB2, FWxFilial("SB2") + SC6->C6_PRODUTO)

			SC6->(DbSkip())

		EndDo

	EndIf

	//Everson - 03/11/2021. Chamado 63090.
	If lRet //Bloqueia SB2.
		//Conout("ADVEN090P - chkBloTb - bloqueio SB2 " + cValToChar(cPed))
		//logZBE("Início MultLock SB2 " + cValToChar(cPed), "")
		lRet := MultLock("SB2", aSB2, 1)
		If ! lRet
			cErro := "MultLock Falhou SB2"
			logZBE(cErro, "Pedido " + cValToChar(cPed))
			Conout("ADVEN090P - RESTEXECUTE - " + cErro + " " + cValToChar(cPed))

		EndIf

	EndIf

	//Everson - 03/11/2021. Chamado 63090.
	// If lRet .And. nOpc == 4 //Bloqueia SC5.
	// 	//Conout("ADVEN090P - chkBloTb - bloqueio SC5 " + cValToChar(cPed))
	// 	//logZBE("Início MultLock SC5 " + cValToChar(cPed), "")
	// 	Aadd(aSC5, FWxFilial("SC5") + cPed)
	// 	lRet := MultLock("SC5", aSC5, 1)
	// 	If ! lRet
	// 		cErro := "MultLock Falhou SC5"
	// 		logZBE(cErro, "Pedido " + cValToChar(cPed))
	// 		Conout("ADVEN090P - RESTEXECUTE - " + cErro + " " + cValToChar(cPed))

	// 	EndIf

	// EndIf

	// //Everson - 03/11/2021. Chamado 63090.
	// If lRet //Bloqueia SA1.
	// 	//Conout("ADVEN090P - chkBloTb - bloqueio SA1 " + cValToChar(cPed))
	// 	//logZBE("Início MultLock SA1 " + cValToChar(cPed), "")
	// 	cCliLoj := Posicione("SC5", 1, FWxFilial("SC5") + cPed, "C5_CLIENTE") + Posicione("SC5", 1, FWxFilial("SC5") + cPed, "C5_LOJACLI")
	// 	Aadd(aSA1, FWxFilial("SA1") + cCliLoj)
	// 	lRet := MultLock("SA1", aSA1, 1)
	// 	If ! lRet
	// 		cErro := "MultLock Falhou SA1"
	// 		logZBE(cErro, "Pedido " + cValToChar(cPed))
	// 		Conout("ADVEN090P - RESTEXECUTE - " + cErro + " " + cValToChar(cPed))

	// 	EndIf

	// EndIf

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} logZBE
	Gera log na ZBE. 
	Chamado 63090.
	@type  Static Function
	@author Everson
	@since 01/11/2021
	@version 01
/*/
Static Function logZBE(cLog, cParam, cMemo)

	//
	Default cLog	:= ""
	Default cParam	:= ""
	Default cMemo	:= ""

	//
	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
		Replace ZBE_FILIAL 	   	With FWxFilial("ZBE")
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
/*/{Protheus.doc} killConn
	Função termina conexões.
	@type  Static Function
	@author Everson
	@since 10/11/2021
	@version 01
/*/
User Function ADVEN902(cThreads)

	//Variáveis.
	Local lRet 		 := .F.
    Local nConexAtu  := 1
	Local aThreads   := GetUserInfoArray()
	Local lProcess   := .F.

	//
	While ! lProcess

		//
		For nConexAtu := 1 To Len(aThreads)
				
			//
			If Alltrim(cValToChar(aThreads[nConexAtu][3])) $cThreads
				
				logZBE("KillUser " + Alltrim(cValToChar(aThreads[nConexAtu][3])), "", "")

				KillUser( aThreads[nConexAtu][1],; //UserName
							aThreads[nConexAtu][2],; //ComputerName
							aThreads[nConexAtu][3],; //ThreadId
							aThreads[nConexAtu][4])  //ServerName

				lRet := .T.
					
			EndIf
		
		Next nConexAtu

		lProcess := .T.

		aThreads := GetUserInfoArray()
		For nConexAtu := 1 To Len(aThreads)
			If Alltrim(cValToChar(aThreads[nConexAtu][3])) $cThreads
				lProcess := .F.
				Exit

			EndIf

		Next nConexAtu

	End

Return lRet
