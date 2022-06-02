#include "protheus.ch"
#include "topconn.ch"
#Include "TbiConn.ch"
#Include "AP5MAIL.CH"      
#Include "Rwmake.ch" 

// BIBLIOTECAS NECESSÁRIAS
#Include "TOTVS.ch"
#INCLUDE "XMLXFUN.CH"

// BARRA DE SEPARAÇÃO DE DIRETÓRIOS
#Define BAR IIf(IsSrvUnix(), "/", "\")
#DEFINE ENTER Chr(13)+Chr(10)

// Variaveis estaticas
Static cRotina  := "ADFIN087P"
Static cTitulo  := "Gera boleto de adiantamento do PV"
Static lAuto    := .t.

/*/{Protheus.doc} User Function ADFIN087P
	Job para gerar adiantamento/boleto cobrança de pedidos de vendas de adiantamento
	@type  Function
	@author FWNM
	@since 24/04/2020
	@version version
	@chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history chamado 056247 - FWNM 					- 21/05/2020 - Error log apenas via execauto na criação do arquivo e inclusao de ZBE em diversos pontos
	@history chamado 056247 - FWNM 					- 22/05/2020 - Geração do RA com D+1
	@history chamado 056247 - FWNM 					- 25/05/2020 - Geração do RA com valor total do PV com impostos (pré-nota)
	@history chamado 056247 - FWNM 					- 26/05/2020 - Registrar boleto no banco com data do servidor
	@history chamado 056247 - FWNM 					- 05/06/2020 - Geração do RA considerando finais de semana e feriados
	@history chamado 056247 - FWNM 					- 17/06/2020 - Criação de recurso para controle dos testes em produção
	@history chamado 056247 - FWNM 					- 17/06/2020 - Registrar boleto sempre com vencimento pela emissao do servidor
	@history chamado 059655 - FWNM 					- 21/07/2020 - || OS 061193 || FINANCAS || MARILIA || 8353 || CANCELAMENTO RA
	@history chamado 059712 - FWNM 					- 22/07/2020 - || OS 061191 || CONTROLADORIA || CRISTIANE_MELO || 11986587658 || RA- PEDIDO ANTECIPAD
	@history chamado 059415 - FWNM 					- 05/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Ajuste na geração do E1_IDCNAB devido desativação das customizações antigas 
	@history ticket 102     - FWNM 					- 18/08/2020 - WS BRADESCO - Gerar boleto mesmo com bloqueio comercial
	@history ticket 102     - FWNM 					- 27/08/2020 - WS BRADESCO
	@history ticket 1429    - FWNM 					- 11/09/2020 - Bloquear registro de boleto para pedido de exportação
	@history ticket 745     - FWNM 					- 17/09/2020 - Implementação título PR
	@history ticket TI      - FWNM                  - 24/02/2021 - Gerar boleto apenas para PV tipo N
	@history ticket TI      - FWNM                  - 10/09/2021 - Melhoria IDCNAB após golive CLOUD
	@history ticket 515     - Rodrigo Mello         - 17/01/2022 - Implementação PIX
	@history ticket 68450   - Fernando Macieira     - 18/02/2022 - Email em duplicidade para o cliente/vendedor
	@history ticket TI      - Rodrigo Mello         - 01/03/2022 - Ajuste valor default e tipo do MV_#CTAPIX / MV_#CTALINK
	@history ticket TI      - Leonardo P. Monteiro  - 16/03/2022 - Retirada da função unlockbyname.
	@history Ticket 70142   - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	@history ticket 70142 	- Rodrigo Mello 		- 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
/*/
User Function ADFIN087P()

    Local cEmpPC     := "01"
    Local cEmpRun    := ""
    Local cFilRun    := ""
    Local cQuery     := ""
    Local aEmpresas  := {}
    Local aParamJob  := {}
    Local lGeraBol   := .f.
	Local cNumPVsTST := ""
	Local cCodRetOk  := ""
	Local cCodRet69  := ""
	local i
	locaL cCondPixLnk := ""

	// Inicializo ambiente
	rpcClearEnv()
	rpcSetType(3)
		
	If !rpcSetEnv(cEmpPC, "02",,,,,{"SM0"})
		ConOut( cRotina + " Não foi possível inicializar o ambiente, empresa " + cEmpPC + ", filial 02" )
		Return
	EndIf

	// Garanto uma única thread sendo executada
	/*
	If !LockByName("ADFIN087P", .T., .F.)
		ConOut(cRotina + " - Existe outro processamento sendo executado! Verifique...")
		apMsgStop("Existe outro processamento sendo executado! Verifique...", "Atenção")
		Return
	EndIf
	*/
	
	//	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	FWMonitorMsg(ALLTRIM(PROCNAME()))

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina job para geracao boleto de adiantamento do PV')

    cEmpRun := GetMV("MV_#WSBEMP",,"01")
    cFilRun := GetMV("MV_#WSBFIL",,"02")

	// Carrega Empresas para processamentos
	dbSelectArea("SM0")
	dbSetOrder(1)
	SM0->(dbGoTop())
	Do While SM0->(!EOF())
		If (SM0->M0_CODIGO $ cEmpRun) .and. (SM0->M0_CODFIL $ cFilRun)
			aAdd(aEmpresas, { SM0->M0_CODIGO, SM0->M0_CODFIL } )
		EndIf
		SM0->( dbSkip() )
	EndDo

    // Processa empresas
    For i:=1 to Len(aEmpresas)
	
    	RpcClearEnv()
		RpcSetType(3)
		RpcSetEnv( aEmpresas[ i,1 ] , aEmpresas[ i,2 ] )

        If Select("Work") > 0
            Work->( dbCloseArea() )
        EndIf

        cQuery := " SELECT C5_FILIAL, C5_NUM, C5_XWSPAGO
        cQuery += " FROM " + RetSqlName("SC5") + " SC5 (NOLOCK)
        cQuery += " INNER JOIN " + RetSqlName("SE4") + " SE4 (NOLOCK) ON E4_FILIAL='"+FWxFilial("SE4")+"' AND E4_CODIGO=C5_CONDPAG AND E4_CTRADT='1' AND SE4.D_E_L_E_T_=''
        cQuery += " WHERE C5_FILIAL='"+FWxFilial("SC5")+"' 
        cQuery += " AND C5_EMISSAO='"+DtoS(msDate())+"'
        //cQuery += " AND C5_BLQ='' // @history ticket 102 - FWNM - 18/08/2020 - WS BRADESCO - Gerar boleto mesmo com bloqueio comercial
        cQuery += " AND C5_XWSPAGO=''
		cQuery += " AND C5_XWSBOLG=''
		cQuery += " AND C5_EST<>'EX' " //@history ticket 1429 - FWNM - 11/09/2020 - Bloquear registro de boleto para pedido de exportação
		cQuery += " AND C5_TIPO='N' " // @history ticket TI  - FWNM - 24/02/2021 - Gerar boleto apenas para PV tipo N
		cQuery += " AND SC5.D_E_L_E_T_=''

		// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 17/06/2020
		cNumPVsTST := GetMV("MV_#WSPVNU",,"")

		If !Empty(AllTrim(cNumPVsTST))
			cQuery := " SELECT C5_FILIAL, C5_NUM, C5_XWSPAGO
			cQuery += " FROM " + RetSqlName("SC5") + " SC5 (NOLOCK)
			cQuery += " WHERE C5_FILIAL='"+FWxFilial("SC5")+"' 
			cQuery += " AND SC5.C5_NUM IN " + FormatIn(cNumPVsTST,"|")
			cQuery += " AND SC5.D_E_L_E_T_=''
		EndIf
		//

		// DEBUG - INI
		/*
        cQuery := " SELECT C5_FILIAL, C5_NUM, C5_XWSPAGO
        cQuery += " FROM " + RetSqlName("SC5") + " SC5 (NOLOCK)
        cQuery += " WHERE C5_FILIAL='"+FWxFilial("SC5")+"' 
		cQuery += " AND SC5.C5_NUM IN ('9AXKV3')
		cQuery += " AND SC5.D_E_L_E_T_=''
		*/
		// DEBUG - FIM

        tcQuery cQuery New Alias "Work"

		// chamado 059655 - FWNM - 21/07/2020 - || OS 061193 || FINANCAS || MARILIA || 8353 || CANCELAMENTO RA
		cCodRetOk := GetMV("MV_#WSOCOK",,"00")
		cCodRet69 := GetMV("MV_#WSOC69",,"69")
		//

		// condicoes de pagamento para PIX e Link de Pagamento - 11/01/2022 - Rodrigo Mello | Flek Solutions
		cCondPixLnk := alltrim(GetNewPar("MV_#CONPIX", "PIX")) + "|"
		cCondPixLnk += alltrim(GetNewPar("MV_#CONLNK", "LNK"))

        Work->( dbGoTop() )
        Do While Work->( !EOF() )

			// chamado 059655 - FWNM - 21/07/2020 - || OS 061193 || FINANCAS || MARILIA || 8353 || CANCELAMENTO RA
			FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
			If FIE->( dbSeek(FWxFilial("FIE")+"R"+Work->C5_NUM) )

				SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
				If SE1->( dbSeek(FIE->(FIE_FILIAL+FIE_PREFIX+FIE_NUM+FIE_PARCEL+FIE_TIPO)) )

					If ( Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRetOk)) ) .or. ( Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRet69)) ) 

						// Gera Boleto PDF
						SC5->( dbSetOrder(1) ) // C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_
						If SC5->( dbSeek(Work->(C5_FILIAL+C5_NUM)) )
						//If SC5->( dbSeek(Work->(C5_FILIAL+C5_NUM)) ) .and. !SC5->C5_CONDPAG $ cCondPixLnk // @history ticket 68450   - Fernando Macieira     - 18/02/2022 - Email em duplicidade para o cliente/vendedor

							If !(SC5->C5_CONDPAG $ cCondPixLnk) // @history ticket 68450   - Fernando Macieira     - 18/02/2022 - Email em duplicidade para o cliente/vendedor
								logZBE(SE1->E1_NUM + " esta acessando funcao GERABLPV para gerar o boleto em PDF e enviar o email")
								u_GeraBlPV(cEmpAnt, cFilAnt, SC5->C5_NUM)
								logZBE(SE1->E1_NUM + " saiu da funcao GERABLPV e se o email foi enviado com sucesso o campo C5_XWSBOLG foi flegado")
							EndIf

							Work->( dbSkip() )
							Loop

						//else
						/*	Work->( dbSkip() )
							Loop*/
						EndIf
	
					EndIf
				
				EndIf
				
			EndIf
			//

			// Checo status integracao SF
            lGeraBol := .f.
            lGeraBol := ChkZCI(Work->C5_NUM)

            logZBE(Work->C5_NUM + " entrou na query C5_BLQ='' C5_XWSPAGO='' C5_XWSBOLG='' E4_CTRADT='1'")

            If lGeraBol

	            logZBE(Work->C5_NUM + " autorizado pelo status integracao do sales force")

                SC5->( dbSetOrder(1) ) // C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_
                If SC5->( dbSeek(Work->(C5_FILIAL+C5_NUM)) )
     
                    //Gera boleto de adiantamento e amarração com PV n " + SC5->C5_NUM )
                    u_GeraRAPV()

                    // Checo amarração RA x PV para enviar trava de alteração no Sales Force
				    FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
				    If FIE->( dbSeek(SC5->C5_FILIAL+"R"+SC5->C5_NUM) )
					    U_ADVEN050P(SC5->C5_NUM,.T.,.F.,"",.F.,.F.,.F.,.F.,.F.,.F.,0,1)
				    EndIf

                EndIf

            Else
				
				logZBE(Work->C5_NUM + " nao foi autorizado pelo status integracao sales force")

			EndIf

		    Work->( dbSkip() )

        EndDo

        If Select("Work") > 0
            Work->( dbCloseArea() )
        EndIf

		// @history ticket 102 - FWNM - 27/08/2020 - WS BRADESCO
		ChkFIE() // Forço a geração do FIE para os casos em que existe RA e PV
		//

    Next i

	//UnLockByName("ADFIN087P")

	//Fecha o ambiente.
	RpcClearEnv()

Return

/*/{Protheus.doc} Static Function ChkZCI
    Checa status integração Sales Force
    @type  Static Function
    @author FWM
    @since 24/04/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
/*/
Static Function ChkZCI(cNumPV)

    Local lRet   := .f.
    Local cQuery := ""

    If Select("WorkZCI") > 0
        WorkZCI->( dbCloseArea() )
    EndIf

    cQuery := " SELECT ISNULL(COUNT(ZCI_NUMP),0) AS NUM_P
    cQuery += " FROM " + RetSqlName("ZCI") + " (NOLOCK)
    cQuery += " WHERE ZCI_FILIAL='"+FWxFilial("ZCI")+"'
    cQuery += " AND ZCI_NUMP='"+cNumPV+"'
    cQuery += " AND ZCI_TMPR='PENDPROC'
    cQuery += " AND ZCI_METD IN ('POST','PUT','DELETE')
    cQuery += " AND D_E_L_E_T_=''

    tcQuery cQuery New Alias "WorkZCI"

    If WorkZCI->NUM_P == 0
        lRet := .t.
    EndIf

    If Select("WorkZCI") > 0
        WorkZCI->( dbCloseArea() )
    EndIf

Return lRet

/*/{Protheus.doc} User Function GeraRAPV
	Função para gerar RA = Adiantamento ao cliente vinculando com PV
	@type  Static Function
	@author FWNM
	@since 04/03/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 056247 
/*/
User Function GeraRAPV()

	Local cQuery   := ""
	Local aDadRA   := {}
	Local aArea    := GetArea() 
	Local aAreaSE4 := SE4->( GetArea() )

	Local cCondRA  := SC5->C5_CONDPAG
	Local cNaturez := SC5->C5_NATUREZ
	Local cCliCod  := SC5->C5_CLIENTE
	Local cCliLoj  := SC5->C5_LOJAENT
	Local nVlrRA   := PreNota() //SC5->C5_XTOTPED // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 25/05/2020

	Local cBcoRA := cAgeRA := cCtaRA := ""
	Local cHistRA   := "" // "RA vinculado ao PV n " + SC5->C5_NUM

	Local nDiasBol  := GetMV("MV_#BOLDIA",,1) // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 22/05/2020

    Local cCodRetOk := GetMV("MV_#WSOCOK",,"00")
    Local cCodRet69 := GetMV("MV_#WSOC69",,"69")
	local cCondBlt  := GetNewPar("MV_#CONBLT", "001/00 ")
	local cCondLnk  := GetNewPar("MV_#CONLNK", "LNK")
	local cCondPIX  := GetNewPar("MV_#CONPIX", "PIX")

	local aCtaLnk	:= & (GetNewPar("MV_#CTALNK", '{"237", "33677", "126500_8"}'))
	local aCtaPix	:= & (GetNewPar("MV_#CTAPIX", '{"237", "33677", "126500_8"}'))

	Local cBcoMVSA1 := GetMV("MV_#WSBCO1",,"237") // TI - Conforme diretriz Reginaldo/Sigoli - FWNM - 06/05/2020

	Local cBcoSA1  := Posicione("SA1",1,FWxFilial("SA1")+cCliCod+cCliLoj,"A1_BCO1") // SA1->A1_XBCOO
	Local lCondRA  := AllTrim(Posicione("SE4",1,FWxFilial("SE4")+cCondRA,"E4_CTRADT")) == "1" // Cond Adiantamento = SIM
	Local cNumPVsTST := ""
	Local dDtBaseBkp := dDataBase

	// ticket 745 - FWNM - Implementação título PR
	Local cTipoE1 := GetMV("MV_#WSTIPO",,"PR") 

	cHistRA   := cTipoE1 + " gerado pelo PV n " + SC5->C5_NUM
	//

	// TI - Conforme diretriz Reginaldo/Sigoli - FWNM - 05/05/2020
	//If Empty(cBcoSA1)
		cBcoSA1 := cBcoMVSA1
	//EndIf

	cNumPVsTST := GetMV("MV_#WSPVNU",,"")

	If !Empty(AllTrim(cNumPVsTST))
		lCondRA := .T.
	EndIf

	If lCondRA .and. !Empty(cBcoSA1)

		Conout( " ADFIN087P - Cliente - " + cCliCod + "/" + cCliLoj )
		Conout( " ADFIN087P - A1_BCO1 - " + cBcoSA1 )
	
		// Gerar apenas se liberado por regra
		// @history ticket 102 - FWNM - 18/08/2020 - WS BRADESCO - Gerar boleto mesmo com bloqueio comercial
		/*
		If !Empty(SC5->C5_BLQ) // Pedido Bloquedo por regra
	        logZBE(SC5->C5_NUM + " esta bloqueado por regra C5_BLQ='1'")
			Conout(" ADFIN087P - C5_BLQ - PV BLOQUEADO POR REGRA - BOLETO WS NAO GERADO ")
			Return
		EndIf
		*/

		// Não processa se tiver uma única TES que não gere financeiro
		lAllTESFin := ChkTESPV(SC5->C5_FILIAL, SC5->C5_NUM)
		If !lAllTESFin
            logZBE(SC5->C5_NUM + " possui item com TES F4_DUPLIC='N'" )
			Conout(" ADFIN087P - TES - PV N. " + SC5->C5_NUM + " POSSUI F4_DUPLIC=N - BOLETO WS NAO GERADO ")
			Return
		EndIf
		//

		// Checo se já existe RA e amarração
		FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
		If FIE->( dbSeek(SC5->C5_FILIAL+"R"+SC5->C5_NUM) ) .AND. alltrim(SC5->C5_CONDPAG) $ cCondBlt  // @history 07/12/2021 - verifica se meio de pagamento é Boleto | Rodrigo Mello - Flek Solutions

			SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
			If SE1->( dbSeek(FIE->(FIE_FILIAL+FIE_PREFIX+FIE_NUM+FIE_PARCEL+FIE_TIPO)) ) 

				// Gera nosso número
				If Empty(SE1->E1_NUMBCO)

					If Select("WorkSA6") > 0
						WorkSA6->( dbCloseArea() )
					EndIf

					cQuery := " SELECT DISTINCT A6_COD, A6_AGENCIA, A6_NUMCON
					cQuery += " FROM " + RetSqlName("SA6") + " (NOLOCK)
					cQuery += " WHERE A6_FILIAL='"+FWxFilial("SA6")+"'
					cQuery += " AND A6_COD='"+cBcoSA1+"' 
					cQuery += " AND A6_ZZBLT='S'
					cQuery += " AND D_E_L_E_T_=''

					tcQuery cQuery new Alias "WorkSA6"

					WorkSA6->( dbGoTop() )

					If WorkSA6->( !EOF() )
						cBcoRA := WorkSA6->A6_COD
						cAgeRA := WorkSA6->A6_AGENCIA
						cCtaRA := WorkSA6->A6_NUMCON
					EndIf

					If Select("WorkSA6") > 0
						WorkSA6->( dbCloseArea() )
					EndIf

					Conout(" ADFIN087P - Banco-Agencia-Conta - " + cBcoRA + ", " + cAgeRA + ", " + cCtaRA)
					Conout("---- ADFIN087P - GeraRAPV - Inicio da Rotina Automatica! ------")

					cE1PORTADO := cBcoRA
					cE1AGEDEP  := cAgeRA
					cE1CONTA   := cCtaRA
					//Static Call(SF2460I, fCalcBlt, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, cE1PORTADO, cE1AGEDEP, cE1CONTA)
					//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
					u_2460IA0( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO )

		            logZBE(SE1->E1_NUM + " gerou E1_NUMBCO pela rotina SF2460I via ROTINA")

				EndIf

				If Empty(SE1->E1_XWSBRAC) .or. ( Val(AllTrim(SE1->E1_XWSBRAC)) <> Val(AllTrim(cCodRetOk)) .or. Val(AllTrim(SE1->E1_XWSBRAC)) <> Val(AllTrim(cCodRet69)) )

					// Registra boleto bradesco WS
					logZBE(SE1->E1_NUM + " esta acessando funcao T288BPCK7 para fazer registro do E1_NUMBCO")				
					u_T288BPCK7(SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
					logZBE(SE1->E1_NUM + " saiu da funcao T288BPCK7 que faz o registro do E1_NUMBCO")				
					
					// Gera Boleto PDF
					logZBE(SE1->E1_NUM + " esta acessando funcao GERABLPV para gerar o boleto em PDF e enviar o email")
					u_GeraBlPV(cEmpAnt, cFilAnt, SC5->C5_NUM)
					logZBE(SE1->E1_NUM + " saiu da funcao GERABLPV e se o email foi enviado com sucesso o campo C5_XWSBOLG foi flegado")

				EndIf

				If Empty(SC5->C5_XWSBOLG)

					// Gera Boleto PDF
					logZBE(SE1->E1_NUM + " esta acessando funcao GERABLPV para gerar o boleto em PDF e enviar o email")
					u_GeraBlPV(cEmpAnt, cFilAnt, SC5->C5_NUM)
					logZBE(SE1->E1_NUM + " saiu da funcao GERABLPV e se o email foi enviado com sucesso o campo C5_XWSBOLG foi flegado")

				EndIf

				Return

			EndIf

		EndIf

		// Processo novos PVs
		If Select("WorkSA6") > 0
			WorkSA6->( dbCloseArea() )
		EndIf

		cQuery := " SELECT DISTINCT A6_COD, A6_AGENCIA, A6_NUMCON
		cQuery += " FROM " + RetSqlName("SA6") + " (NOLOCK)
		cQuery += " WHERE A6_FILIAL='"+FWxFilial("SA6")+"'
		cQuery += " AND A6_COD='"+cBcoSA1+"' 
		cQuery += " AND A6_ZZBLT='S'
		cQuery += " AND D_E_L_E_T_=''

		tcQuery cQuery new Alias "WorkSA6"

		WorkSA6->( dbGoTop() )

		If WorkSA6->( !EOF() )
			cBcoRA := WorkSA6->A6_COD
			cAgeRA := WorkSA6->A6_AGENCIA
			cCtaRA := WorkSA6->A6_NUMCON
		EndIf

		If Select("WorkSA6") > 0
			WorkSA6->( dbCloseArea() )
		EndIf
		
		// @history 27/12/2021 - verifica se meio de pagamento é Pix / Lnk | Rodrigo Mello - Flek Solutions
		if SC5->C5_CONDPAG == cCondLnk
			cBcoRA := aCtaLnk[1]
			cAgeRA := aCtaLnk[2]
			cCtaRA := aCtaLnk[3]
		endif
		if SC5->C5_CONDPAG == cCondPix
			cBcoRA := aCtaPix[1]
			cAgeRA := aCtaPix[2]
			cCtaRA := aCtaPix[3]
		endif

		nDiasBol := DiaUtil(nDiasBol) // Chamado 056247 - FWNM - 05/06/2020 - Geração do RA considerando finais de semana e feriados

		// chamado 059712 - FWNM - 22/07/2020 - || OS 061191 || CONTROLADORIA || CRISTIANE_MELO || 11986587658 || RA- PEDIDO ANTECIPAD
		dDtBaseBkp := dDataBase
		dDataBase  := msDate()+nDiasBol
		
		cPerg := PadR("FIN040",Len(SX1->X1_GRUPO))
		Pergunte(cPerg, .f.)
		MV_PAR03 := 2 // Contabiliza on line ? = 2 = Não
		//

		Conout(" ADFIN087P - Banco-Agencia-Conta - " + cBcoRA + ", " + cAgeRA + ", " + cCtaRA)
		Conout("---- ADFIN087P - GeraRAPV - Inicio da Rotina Automatica!------")

		/*
		aDadRA := { { "E1_PREFIXO", cTipoE1    		 , NIL },;
		            { "E1_NUM"    , SC5->C5_NUM		 , NIL },;
		            { "E1_TIPO"   , cTipoE1 		 , NIL },;
		            { "E1_NATUREZ", cNaturez		 , NIL },;
		            { "E1_CLIENTE", cCliCod 		 , NIL },;
		            { "E1_LOJA"   , cCliLoj 		 , NIL },;
		            { "E1_EMISSAO", msDate()         , NIL },;
		            { "E1_VENCTO" , msDate()+nDiasBol, NIL },;
		            { "E1_VENCREA", msDate()+nDiasBol, NIL },;
		            { "CBCOAUTO"  , cBcoRA           , NIL },;
		            { "CAGEAUTO"  , cAgeRA           , NIL },;
		            { "CCTAAUTO"  , cCtaRA           , NIL },;
		            { "E1_VALOR"  , nVlrRA           , NIL },;
		            { "E1_HIST"   , cHistRA          , NIL }}
		*/

		aDadRA := { { "E1_PREFIXO", cTipoE1    		 , NIL },;
		            { "E1_NUM"    , SC5->C5_NUM		 , NIL },;
		            { "E1_TIPO"   , cTipoE1 		 , NIL },;
		            { "E1_NATUREZ", cNaturez		 , NIL },;
		            { "E1_CLIENTE", cCliCod 		 , NIL },;
		            { "E1_LOJA"   , cCliLoj 		 , NIL },;
		            { "E1_EMISSAO", msDate()         , NIL },;
		            { "E1_VENCTO" , msDate()+nDiasBol, NIL },;
		            { "E1_VENCREA", msDate()+nDiasBol, NIL },;
		            { "E1_VALOR"  , nVlrRA           , NIL },;
		            { "E1_HIST"   , cHistRA          , NIL }}

		lMsErroAuto := .f.
		dbSelectArea("SE1")
		msExecAuto( { |x,y| FINA040(x,y) }, aDadRA, 3 )  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

		logZBE(SC5->C5_NUM + " EXECAUTO FINA040 foi executado")

		// Restauro database
		dDataBase := dDtBaseBkp // chamado 059712 - FWNM - 22/07/2020 - || OS 061191 || CONTROLADORIA || CRISTIANE_MELO || 11986587658 || RA- PEDIDO ANTECIPAD

		If lMsErroAuto
			logZBE(SC5->C5_NUM + " EXECAUTO FINA040 foi executado com erro e o boleto (tipo " + cTipoE1 + ") nao foi gerado")
		    MostraErro()
			DisarmTransaction()
		Else
		    logZBE(SE1->E1_NUM + " EXECAUTO FINA040 foi executado com sucesso e o boleto (tipo " + cTipoE1 + ") foi gerado")
			Conout("ADFIN087P - " + cTipoE1 + " incluído com sucesso!")

			// ticket 745 - FWNM - Implementação título PR
			RecLock("SE1", .F.)
				SE1->E1_PORTADO := cBcoRA
				SE1->E1_AGEDEP  := cAgeRA
				SE1->E1_CONTA   := cCtaRA

				// @history 27/12/2021 - atualiza log Pix / Lnk | Rodrigo Mello - Flek Solutions
				if SC5->C5_CONDPAG == cCondLnk
					SE1->E1_XLOGLNK := '000'
				endif
				if SC5->C5_CONDPAG == cCondPix
					SE1->E1_XLOGPIX := '000'
				endif

			SE1->( msUnLock() )

			// Gero vinculo do boleto com o Pedido de Vendas
			RecLock("FIE", .t.)
				FIE->FIE_FILIAL := FWxFilial("FIE")
				FIE->FIE_CART   := "R"
				FIE->FIE_PEDIDO := SC5->C5_NUM
				FIE->FIE_PREFIX := SE1->E1_PREFIXO
				FIE->FIE_NUM    := SE1->E1_NUM
				FIE->FIE_PARCEL := SE1->E1_PARCELA
				FIE->FIE_TIPO   := SE1->E1_TIPO
				FIE->FIE_CLIENT := SE1->E1_CLIENTE
				FIE->FIE_LOJA   := SE1->E1_LOJA
				FIE->FIE_VALOR  := SE1->E1_SALDO
				FIE->FIE_SALDO  := SE1->E1_SALDO
			FIE->( msUnLock() )
			FIE->( fkCommit() )

			logZBE(FIE->FIE_PEDIDO + " tabela FIE (Amarracao PV x " + cTipoE1 + ") foi gerado com sucesso")

			if alltrim(SC5->C5_CONDPAG) $ cCondBlt  // @history 07/12/2021 - verifica se meio de pagamento é Boleto | Rodrigo Mello - Flek Solutions
				// Gera nosso número
				cE1PORTADO := cBcoRA
				cE1AGEDEP  := cAgeRA
				cE1CONTA   := cCtaRA
				//Static Call(SF2460I, fCalcBlt, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, cBcoRA, cAgeRA, cCtaRA)
				//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
				u_2460IA0( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO )

				logZBE(SE1->E1_NUM + " gerou E1_NUMBCO pela rotina SF2460I via ROTINA")

				// Registra boleto bradesco WS
				logZBE(SE1->E1_NUM + " esta acessando funcao T288BPCK7 para fazer registro do E1_NUMBCO")				
				u_T288BPCK7(SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
				logZBE(SE1->E1_NUM + " saiu da funcao T288BPCK7 que faz o registro do E1_NUMBCO")				

				// Gera Boleto PDF
				logZBE(SE1->E1_NUM + " esta acessando funcao GERABLPV para gerar o boleto em PDF e enviar o email")
				u_GeraBlPV(cEmpAnt, cFilAnt, SC5->C5_NUM)
				logZBE(SE1->E1_NUM + " saiu da funcao GERABLPV e se o email foi enviado com sucesso o campo C5_XWSBOLG foi flegado")
			endif

			// Bloqueia por regra
			/*
			RecLock("SC5", .f.)
                SC5->C5_LIBEROK := ""
                SC5->C5_BLQ     := "1" // Pedido Bloquedo por regra
            SC5->( msUnLock() )
			*/

			// Bloqueia Crédito independentemente dos campos padroes como A1_RISCO e/ou A1_LC
			cSql := " UPDATE " + RetSqlName("SC9") + " SET C9_BLCRED='01'
			cSql += " WHERE C9_FILIAL='"+FWxFilial("SC9")+"'
			cSql += " AND C9_PEDIDO='"+SC5->C5_NUM+"'
			cSql += " AND D_E_L_E_T_='' 

			tcSQLExec(cSql)

			// Gera Boleto PDF
			logZBE(SE1->E1_NUM + " esta acessando funcao GERABLPV para gerar o boleto em PDF e enviar o email")
			u_GeraBlPV(cEmpAnt, cFilAnt, SC5->C5_NUM)
			logZBE(SE1->E1_NUM + " saiu da funcao GERABLPV e se o email foi enviado com sucesso o campo C5_XWSBOLG foi flegado")
			
		EndIf

	EndIf

	RestArea( aAreaSE4 )
	RestArea( aArea )

Return

/*/{Protheus.doc} User Function T288BPCK7
	ENVIA JSON CRIPTOGRAFADO PARA O BANCO BRADESCO
	@type  Function
	@author FWNM
	@since 09/03/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
/*/
User Function T288BPCK7(_cFilial, _cPrefixo, _cNum, _cParcela, _cTipo)

    Local aCert    As Array     // CERTIFICADOS
    Local aHeadOut As Array     // CABEÇALHO DE ENVIO
    Local cSign    As Character // JSON ASSINADO
    Local cURL     As Character // URL DA REQUISIÇÃO
    Local cResp    As Character // RESPOSTA DA REQUISIÇÃO
    Local cHeadRet As Character // CABEÇALHO DE RETORNO
    Local cPasswd  As Character // SENHA DO CERTIFICADO
    Local nTimeOut As Numeric   // TEMPO DE REQUISIÇÃO

	Local cAmbWS     := GetMV("MV_#WSAMB",,"P") // P = PRODUCAO, H = HOMOLOGACAO
	Local cPathCerts := GetMV("MV_#WSCERT",,"certs_ws") // Pasta onde encontra-se o certificado digital
	Local cNomeCerts := "Adoro"

	Local cCodRetOk  := GetMV("MV_#WSOCOK",,"00")
	Local cCodRet69  := GetMV("MV_#WSOC69",,"69")

	// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 21/05/2020
	/*
	If !IsInCallStack("U_ADFIN087P")
		oFile := FWFileWriter():New("C:\PROTHEUS\BradWSXM.xml", .T.)
	EndIf
	*/
	//

	logZBE(SC5->C5_NUM + " entrou na funcao T288BPCK7 para registrar nosso numero no bradesco via JSON" )

	/*
	If AllTrim(SE1->E1_PORTADO) <> "237"
		CONOUT( " T288BPCK7 - Cliente com portador diferente de 237 - Bradesco " )
		Return
	EndIf
	*/

	// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 21/05/2020
	/*
	If !IsInCallStack("U_ADFIN087P")
		If oFile:Exists()
			oFile:Erase()
		EndIf
	EndIf
	*/
	//

	Default _cFilial  := SE1->E1_FILIAL
	Default _cPrefixo := SE1->E1_PREFIXO
	Default _cNum     := SE1->E1_NUM
	Default _cParcela := SE1->E1_PARCELA
	Default _cTipo    := SE1->E1_TIPO

	If IsInCallStack("U_BOLBRAD") .or. AllTrim(FunName()) == "FINA740" .or. IsInCallStack("u_GeraRAPV")
		SE1->( dbSetOrder(1) )
		If SE1->( dbSeek(_cFilial+_cPrefixo+_cNum+_cParcela+_cTipo) )
			If !Empty(SE1->E1_XWSBRAC) .and. ( Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRetOk)) .or. Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRet69)) ) // Boleto já registrado
				MsgStop("Boleto já foi registrado: " + AllTrim(SE1->E1_XWSBRAD), "04 - Função BolBrad - ADFIN087P - FA740BRW")
				Return
			Else
				// Variaveis utilizadas na montagem do JSON
				cE1PORTADO := SE1->E1_PORTADO
				cE1AGEDEP  := SE1->E1_AGEDEP
				cE1CONTA   := SE1->E1_CONTA
			EndIf
		EndIf
	EndIf

    // INICIALIZAÇÃO DE VARIÁVEIS
    aHeadOut := {}
    cPasswd  := GetMV("MV_#WSPASS",,"60037059")
    cHeadRet := Space(0)
    nTimeOut := 180

	If AllTrim(Upper(cAmbWS)) == "H"
	    cURL     := GetMV("MV_#WSHTTH",,"https://cobranca.bradesconetempresa.b.br/ibpjregistrotitulows/registrotitulohomologacao")
	Else
		cURL     := GetMV("MV_#WSHTTP",,"https://cobranca.bradesconetempresa.b.br/ibpjregistrotitulows/registrotitulo")
	EndIf

	logZBE(SE1->E1_NUM + " utilizara endpoint para registro " + cURL )

    aCert    := GetCertificate(BAR + cPathCerts, cNomeCerts, cPasswd)
    cSign    := SignJson(aCert, cPasswd)

	logZBE(SE1->E1_NUM + " passou pela funcao GETCERTIFICATE utilizando senha " + cPasswd + " e pela funcao SIGNJSON retornando " + cSign )

    // ENVIO DA REQUISIÇÃO
    cResp := HTTPSPost(cURL,;
                       aCert[AScan(aCert, {|aCert|aCert[1] == "CERT"})][2],;
                       aCert[AScan(aCert, {|aCert|aCert[1] == "KEY"})][2],;
                       cPasswd,;
                       Space(0),;
                       cSign,;
                       nTimeOut,;
                       aHeadOut,;
                       @cHeadRet)

	logZBE(SE1->E1_NUM + " enviou requisicao " + cResp )

    // VALIDAÇÃO DE ERROS
	// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 21/05/2020
	/*
	If !IsInCallStack("U_ADFIN087P")
		If (oFile:Create())
			oFile:Write(cResp)
			oFile:Close()
		Endif
	EndIf
	*/
	//
	
    UpSoap(cResp)
	Conout(" ADFIN087P - SOAP - " + cResp)

	// ticket 745 - FWNM - Implementação título PR
	RecLock("SE1", .F.)
		SE1->E1_XWSBRAD := StrTran( AllTrim(SE1->E1_XWSBRAD), "msgErro", "msgRetBco" )
	SE1->( msUnLock() )


	logZBE(SE1->E1_NUM + " retornou requisicao com motivos " + SE1->E1_XWSBRAC + " - " + AllTrim(SE1->E1_XWSBRAD) + " - " + cResp )
	
	If IsInCallStack("U_BOLBRAD") .or. AllTrim(FunName()) == "FINA740"

		If !Empty(SE1->E1_XWSBRAC) .and. ( Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRetOk)) .or. Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRet69)) ) // Boleto já registrado
			Aviso("ADFIN087P-01", "Boleto registrado com sucesso!", {"&Ok"},, "Retorno: " + SE1->E1_XWSBRAC + " - " + AllTrim(SE1->E1_XWSBRAD))
		Else
			MsgStop("Boleto não foi registrado. Motivo: " + SE1->E1_XWSBRAC + " - " + AllTrim(SE1->E1_XWSBRAD) + " - Arquivo completo com log gerado no C:\PROTHEUS\bradwsxm.xml ", "05 - Função BolBrad - ADFIN087P - FA740BRW")
		EndIf

		Return

	EndIf
	
	/*
	If (Empty(cResp))
        ConOut("[ADFIN087P] - @SP.ADVPL: Error! - Boleto Bradesco não registrado...")
		Alert("[ADFIN087P] - Boleto Bradesco não registrado!")
    Else
        ConOut("@SP.ADVPL: Success!")
        ConOut(cResp)
    EndIf
	*/

Return (NIL)

/*/{Protheus.doc} Static Function SignJson
	ASSINA O JSON COM OS CERTIFICADOS
	@type  Function
	@author FWNM
	@since 09/03/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
/*/
Static Function SignJson(aCert As Array, cPass As Character)

    Local cError As Character // VALIDAÇÃO DE ERROS
    Local cSign  As Character // JSON ASSINADO
    Local cJson  As Character // JSON A SER ASSINADO
	
	// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 21/05/2020
	/*
	If !IsInCallStack("U_ADFIN087P")
		oFile := FWFileWriter():New("C:\PROTHEUS\BradWSJS.txt", .T.)

		If oFile:Exists()
			oFile:Erase()
		EndIf
	EndIf
	*/
	//

    // INICIALIZAÇÃO DE VARIÁVEIS
    cError := Space(0)
    cSign  := Space(0)
    cJson  := GetJsonStruct()

	Conout(" ADFIN087P - JSON - " + cJson)

	// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 21/05/2020
	/*
	If !IsInCallStack("U_ADFIN087P")
		If (oFile:Create())
			oFile:Write(cJson)
			oFile:Close()
		Endif
	EndIf
	*/
    
	// ASSINA O JSON
    cSign := SMIMESign(aCert[AScan(aCert, {|aCert|aCert[1] == "CERT"})][2],; // CHAVE PÚBLICA
                    aCert[AScan(aCert, {|aCert|aCert[1] == "KEY"})][2],;     // CHAVE PRIVADA
                    GetJsonStruct(),;                                        // JSON PARA SER ASSINADO
                    "-nodetach",;                                            // ENVIO S/ ANEXO
                    @cError,;                                                // VALIDAÇÃO DE ERROS
                    cPass)

    // SERIALIZA O JSON ASSINADO
    cSign := FwCutOff(cSign, .T.)

    // REMOVE O CABEÇALHO E RODAPÉ
    cSign := SubStr(cSign, 22, Len(cSign) - 40)

Return (cSign)

/*/{Protheus.doc} Static Function GetJsonStruct
	MONTAGEM DO JSON DE ENVIO
	@type  Function
	@author FWNM
	@since 09/03/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
/*/
Static Function GetJsonStruct()

    Local oJson As Object // OBJETO JSON

	Local aAreaSM0 := SM0->( GetArea() )
	Local aAreaSA1 := SA1->( GetArea() )

	Local nuCPFCNPJ  := "0"
	Local filCPFCNPJ := "0"
	Local nuSeqContr := GetMV("MV_#WSNCTR",,"3462737")
	Local cCNPJContr := GetMV("MV_#WSCNPJ",,"60037058000131")
	Local nuNegociac := Left(AllTrim(cE1AGEDEP),4) + Repl("0",7) + StrZero(Val(Left(AllTrim(cE1CONTA),6)),7) // Número da Negociação Formato: Agencia: 4 posições (Sem digito) Zeros: 7 posições Conta: 7 posições (Sem digito)
	Local trlCPFCNPJ := "0"
	Local nuTitulo   := UpNumSE1("E1_NUMBCO")
	Local nuCliente  := UpE1IDCNAB() //UpNumSE1("E1_IDCNAB") // chamado 059415 - FWNM - 05/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Ajuste na geração do E1_IDCNAB devido desativação das customizações antigas 
	Local dtEmissTit := GravaData(msDate(), .F., 5) //GravaData(SE1->E1_EMISSAO, .F., 5) // Chamado n. 056247 - FWNM - 26/05/2020 - Registrar boleto no banco com data do servidor
	Local dtVenctTit := GravaData(msDate(), .F., 5) // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 17/06/2020
//	Local dtVenctTit := GravaData(SE1->E1_VENCREA, .F., 5)

	// Pagador
	Local nomePagado := ""
	Local lograPagad := ""
	Local nuLogrPaga := "" 
	Local compLogrPa := ""
	Local cepPagador := "0"
	Local complCepPa := "0"
	Local bairroPaga := ""
	Local munPagador := ""
	Local ufPagador  := ""
	Local cdIndPagad := "0"
	Local nuPagador  := "0"
	Local endEletPag := ""

	// Avalista
    Local nomeSacado := ""
    Local lograSacad := ""
    Local nuLogrSaca := "0"
    Local compLogrSa := ""
    Local cepSacador := "0"
    Local complCepSa := "0"
    Local bairroSaca := ""
    Local munSacador := ""
    Local ufSacador  := ""
    Local cdIndSacad := "0"
    Local nuSacador  := "0"
    Local endEletSac := ""
	Local cEndCobEnt := ""

	dtEmissTit := Left(dtEmissTit,2) + "." + Subs(dtEmissTit,3,2) + "." + Right(dtEmissTit,4)
	dtVenctTit := Left(dtVenctTit,2) + "." + Subs(dtVenctTit,3,2) + "." + Right(dtVenctTit,4)

	SM0->( dbSetOrder(1) ) // M0_CODIGO+M0_CODFIL
	If SM0->( dbSeek(cEmpAnt + cFilAnt) )
		nuCPFCNPJ  := "0" + Left(AllTrim(cCNPJContr),8)
		filCPFCNPJ := Subs(AllTrim(cCNPJContr),9,4)     // 60037058000301
		trlCPFCNPJ := Right(AllTrim(cCNPJContr),2)
		/*
		nuCPFCNPJ  := "0" + Left(AllTrim(SM0->M0_CGC),8)
		filCPFCNPJ := Subs(AllTrim(SM0->M0_CGC),9,4)     // 60037058000301
		trlCPFCNPJ := Right(AllTrim(SM0->M0_CGC),2)
		*/

		nomeSacado := AllTrim(SM0->M0_NOMECOM)

		cEndCobEnt := AllTrim(Iif(!Empty(SM0->M0_ENDCOB),SM0->M0_ENDCOB,SM0->M0_ENDENT))

		lograSacad := cEndCobEnt
		If At(",",cEndCobEnt) > 0
			lograSacad := Left(cEndCobEnt, At(",",cEndCobEnt)-1)
		EndIf

		nuLogrSaca := cEndCobEnt
		If At(",",cEndCobEnt) > 0
			nuLogrSaca := AllTrim(Subs(nuLogrSaca,At(",",nuLogrSaca)+1,10))
		Else
			nuLogrSaca := "SN"
		EndIf

		compLogrSa := AllTrim(SM0->M0_COMPCOB)
		cepSacador := Left(AllTrim(IIF(!EMPTY(SM0->M0_CEPCOB),SM0->M0_CEPCOB,SM0->M0_CEPENT)),5)
		complCepSa := Right(AllTrim(IIF(!EMPTY(SM0->M0_CEPCOB),SM0->M0_CEPCOB,SM0->M0_CEPENT)),3)
		bairroSaca := AllTrim(IIF(!EMPTY(SM0->M0_BAIRCOB),SM0->M0_BAIRCOB,SM0->M0_BAIRENT))
		munSacador := AllTrim(SM0->M0_CIDENT)
		ufSacador  := AllTrim(IIF(!EMPTY(SM0->M0_ESTCOB),SM0->M0_ESTCOB,SM0->M0_ESTENT))
		cdIndSacad := "2"
		nuSacador  := StrZero(Val(cCNPJContr),14) //StrZero(Val(SM0->M0_CGC),14)
		endEletSac := "www.adoro.com.br - cobranca@adoro.com.br"
	EndIf

	SA1->( dbSetOrder(1) ) // A1_FILIAL+A1_COD+A1_LOJA
	If SA1->( dbSeek(FWxFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)) )
		nomePagado := AllTrim(SA1->A1_NOME)

		/*
		lograPagad := Left(AllTrim(IIF(!EMPTY(SA1->A1_END),SA1->A1_END,SA1->A1_ENDCOB)), AT(",",AllTrim(IIF(!EMPTY(SA1->A1_END),SA1->A1_END,SA1->A1_ENDCOB)))) 
		nuLogrPaga := AllTrim(Subs(AllTrim(IIF(!EMPTY(SA1->A1_END),SA1->A1_END,SA1->A1_ENDCOB)), AT(",",AllTrim(IIF(!EMPTY(SA1->A1_END),SA1->A1_END,SA1->A1_ENDCOB)))+1,10))
		*/

		cSA1EndCob := AllTrim(Iif(!Empty(SA1->A1_END),SA1->A1_END,SA1->A1_ENDCOB))

		lograPagad := cSA1EndCob
		If At(",",cSA1EndCob) > 0
			lograPagad := Left(cSA1EndCob, At(",",cSA1EndCob)-1)
		EndIf

		nuLogrPaga := cSA1EndCob
		If At(",",cSA1EndCob) > 0
			nuLogrPaga := AllTrim(Subs(nuLogrPaga,At(",",nuLogrPaga)+1,10))
		Else
			nuLogrPaga := "SN"
		EndIf

		compLogrPa := AllTrim(SA1->A1_COMPLEM)
		cepPagador := Left(AllTrim(IIF(!EMPTY(SA1->A1_CEP),SA1->A1_CEP,SA1->A1_CEPC)),5)
		complCepPa := Right(AllTrim(IIF(!EMPTY(SA1->A1_CEP),SA1->A1_CEP,SA1->A1_CEPC)),3)
		bairroPaga := AllTrim(IIF(!EMPTY(SA1->A1_BAIRRO),SA1->A1_BAIRRO,SA1->A1_BAIRROC))
		munPagador := AllTrim(IIF(!EMPTY(SA1->A1_MUN),SA1->A1_MUN,SA1->A1_MUNC))
		ufPagador  := AllTrim(IIF(!EMPTY(SA1->A1_EST),SA1->A1_EST,SA1->A1_ESTC))
		cdIndPagad := IIF(AllTrim(SA1->A1_PESSOA)=="F","1","2")
		nuPagador  := StrZero(Val(SA1->A1_CGC),14)
		endEletPag := AllTrim(IIF(!EMPTY(SA1->A1_EMAIL),SA1->A1_EMAIL,SA1->A1_EMAICO))
	EndIf

    // INICIALIZAÇÃO DE VARIÁVEL
    oJson := JsonObject():New()

    // MONTAGEM DO JSON (de acordo com manual Nº 4008.524.0883 Versão 2.2 - Atualizado em: 10/10/2019)
    oJson["nuCPFCNPJ"]                            := nuCPFCNPJ		// Raiz CPF/CNPJ Beneficiário
    oJson["filialCPFCNPJ"]                        := filCPFCNPJ 	// Se CPF, filial = 0 - C - 4
    oJson["ctrlCPFCNPJ"]                          := trlCPFCNPJ		// Dígito de Controle CPF/CNPJ Beneficiário
    oJson["cdTipoAcesso"]                         := "2" 			// Tipo de Acesso - Fixo “2” – Negociação
    oJson["clubBanco"]                            := "2372269651" 	// Club Banco – 237 - (Bradesco) Fixo - “2269651”
    oJson["cdTipoContrato"]                       := "048" 			// Tipo de Contrato – Fixo “48”
    oJson["nuSequenciaContrato"]                  := nuSeqContr		// Número de Sequência do Contrato
    oJson["idProduto"]                            := "04" 			// Conf. email SUZANA LOPES DOS SANTOS <suzanalopes.santos@bradesco.com.br>
    oJson["nuNegociacao"]                         := nuNegociac		// Número da Negociação Formato: Agencia: 4 posições (Sem digito) Zeros: 7 posições Conta: 7 posições (Sem digito)
    oJson["cdBanco"]                              := "237"          // Código do Banco – Fixo “237”
    oJson["eNuSequenciaContrato"]                 := nuSeqContr		// Número de Sequência do Contrato
    oJson["tpRegistro"]                           := "001"			// Tipo de Registro – Fixo “1” (à vencer/vencido)
    oJson["cdProduto"]                            := Repl("0",8)	// Código do Produto
    oJson["nuTitulo"]                             := nuTitulo		// Número do Título (Nosso Número sem o dígito)
    oJson["nuCliente"]                            := nuCliente		// Número do Cliente (Seu Número)
    oJson["dtEmissaoTitulo"]                      := dtEmissTit // Data de Emissão do Título (Formato: DD.MM.AAAA) // https://tdn.totvs.com.br/display/public/PROT/GravaData
    oJson["dtVencimentoTitulo"]                   := dtVenctTit // Data de Emissão do Título (Formato: DD.MM.AAAA) // https://tdn.totvs.com.br/display/public/PROT/GravaData
    oJson["tpVencimento"]                         := "0"			// Tipo de Vencimento – Fixo “0”
    oJson["vlNominalTitulo"]                      := StrZero((SE1->E1_SALDO*100),17) // Valor Nominal do Título Se moeda Real, preencher no formato: 10000 (título no valor de R$100,00). Se moeda indexada, preencher no formato: 10000000 (título no valor de U$100,00). Caso o contrato de Cobrança não seja específico para moeda indexada, o registro será realizado em moeda Real.
    oJson["cdEspecieTitulo"]                      := "02"			// Código da Espécie do Título Códigos possíveis de acordo com item 9.1
    oJson["tpProtestoAutomaticoNegativacao"]      := "00"			// Tipo de Protesto Automático ou Negativação 01 – DIAS CORRIDOS PARA PROTESTO 02- DIAS ÚTEIS PARA PROTESTO 03 – DIAS CORRIDOS PARA NEGATIVAÇÃO
    oJson["prazoProtestoAutomaticoNegativacao"]   := "00"			// Prazo para Protesto Automático ou Negativação Para Protesto na condição de dias úteis: 3 dias após o vencimento. Dias corridos 5 dias após vencimento. Para Negativação considerar 5 dias corridos após o vencimento.
    oJson["controleParticipante"]                 := PadR(AllTrim(SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)),25)		// Controle Participante
    oJson["cdPagamentoParcial"]                   := "N"			// Indicador de Pagamento Parcial– domínio ‘S’ ou ‘N’
    oJson["qtdePagamentoParcial"]                 := "000"			// Quantidade de Pagamentos Parciais
    oJson["percentualJuros"]                      := Repl("0",8)	// Percentual de Juros Formato do Campo: Conforme item 9.2 desse manual
    oJson["vlJuros"]                              := Repl("0",17)   // Percentual de Juros Formato do Campo: Conforme item 9.2 desse manual => regra contida no BRADES.REM = StrZero(Int(SE1->E1_SALDO*0.08*100/30),8) 
    oJson["qtdeDiasJuros"]                        := "00" 			// Quantidade de dias para cálculo Juros
    oJson["percentualMulta"]                      := Repl("0",8)	// Percentual de Multa Formato do Campo: Conforme item 9.2 desse manual
    oJson["vlMulta"]                              := Repl("0",17)	// Valor da Multa
    oJson["qtdeDiasMulta"]                        := "000"			// Quantidade de dias para cálculo Multa
    oJson["percentualDesconto1"]                  := Repl("0",8)	// Percentual do Desconto 1 Formato do Campo: Conforme item 9.2 desse manual
    oJson["vlDesconto1"]                          := Repl("0",17)	// Valor do Desconto 1
    oJson["dataLimiteDesconto1"]                  := Space(10)		// Data Limite para Desconto 1
    oJson["percentualDesconto2"]                  := Repl("0",8)	// Percentual do Desconto 2 Formato do Campo: Conforme item 9.2 desse manual
    oJson["vlDesconto2"]                          := Repl("0",17)	// Valor do Desconto 2
    oJson["dataLimiteDesconto2"]                  := Space(10)		// Data Limite para Desconto 2
    oJson["percentualDesconto3"]                  := Repl("0",8)	// Percentual do Desconto 3 Formato do Campo: Conforme item 9.2 desse manual
    oJson["vlDesconto3"]                          := Repl("0",17)	// Valor do Desconto 3
    oJson["dataLimiteDesconto3"]                  := Space(10)		// Data Limite para Desconto 3
    oJson["prazoBonificacao"]                     := "00"			// Prazo para Bonificação: 1 – dias corridos, 2 – dias úteis
    oJson["percentualBonificacao"]                := Repl("0",8)	// Percentual de Bonificação Formato do Campo: Conforme item 9.2 desse manual
    oJson["vlBonificacao"]                        := Repl("0",17)	// Valor de Bonificação
    oJson["dtLimiteBonificacao"]                  := Space(10)		// Data Limite para Bonificação
    oJson["vlAbatimento"]                         := Repl("0",17)	// Valor do Abatimento
    oJson["vlIOF"]                                := Repl("0",17)	// Valor do IOF
    oJson["nomePagador"]                          := PadR(nomePagado,70)		// Nome do Pagador
    oJson["logradouroPagador"]                    := PadR(lograPagad,40)		// Endereço Pagador
    oJson["nuLogradouroPagador"]                  := PadR(nuLogrPaga,10)		// Número Endereço Pagador
    oJson["complementoLogradouroPagador"]         := PadR(compLogrPa,15)		// Complemento do Endereço Pagador
    oJson["cepPagador"]                           := PadR(cepPagador,5)		// CEP do Pagador
    oJson["complementoCepPagador"]                := PadR(complCepPa,3)		// Complemento do CEP do Pagador
    oJson["bairroPagador"]                        := PadR(bairroPaga,40)		// Bairro Pagador
    oJson["municipioPagador"]                     := PadR(munPagador,30)		// Município Pagador
    oJson["ufPagador"]                            := PadR(ufPagador,2)		// UF Pagador
    oJson["cdIndCpfcnpjPagador"]                  := cdIndPagad		// Indicador CPF/CNPJ Pagador, 1 – CPF, 2 – CNPJ
    oJson["nuCpfcnpjPagador"]                     := nuPagador		// Número do CPF/CNPJ Pagador Se CPF = 00099999999999 com controle Se CNPJ = 99999999999999 com filial e controle
    oJson["endEletronicoPagador"]                 := PadR(endEletPag,70)		// Endereço Eletrônico Pagador
   
    oJson["nomeSacadorAvalista"]                  := PadR(nomeSacado,40)		// Nome do Sacador Avalista
    oJson["logradouroSacadorAvalista"]            := PadR(lograSacad,40)		// Endereço do Sacador Avalista
    oJson["nuLogradouroSacadorAvalista"]          := PadR(nuLogrSaca,10)		// Número do Endereço do Sacador Avalista
    oJson["complementoLogradouroSacadorAvalista"] := PadR(compLogrSa,15)		// Complemento do Endereço Sacador Avalista
    oJson["cepSacadorAvalista"]                   := cepSacador		// CEP do Sacador Avalista
    oJson["complementoCepSacadorAvalista"]        := complCepSa		// Complemento do CEP do Sacador Avalista
    oJson["bairroSacadorAvalista"]                := PadR(bairroSaca,40)		// Bairro Sacador Avalista
    oJson["municipioSacadorAvalista"]             := PadR(munSacador,40)		// Município Sacador Avalista
    oJson["ufSacadorAvalista"]                    := PadR(ufSacador,2)		// UF Sacador Avalista
    oJson["cdIndCpfcnpjSacadorAvalista"]          := cdIndSacad		// Indicador CPF/CNPJ Sacador Avalista, 1 – CPF, 2 – CNPJ
    oJson["nuCpfcnpjSacadorAvalista"]             := nuSacador		// Número do CPF/CNPJ Sacador Avalista
    oJson["endEletronicoSacadorAvalista"]         := PadR(endEletSac,70)		// Endereço Eletrônico Sacador Avalista

	RestArea(aAreaSM0)
	RestArea(aAreaSA1)

Return (oJson:ToJson())

/*/{Protheus.doc} Static Function GetCertificate
	RETORNA O CAMINHO PARA OS CERTIFICADOS
	@type  Function
	@author FWNM
	@since 09/03/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
/*/
Static Function GetCertificate(cCertPath As Character, cFileName As Character, cPassword As Character)

    Local aCert     As Array      // VETOR DE CERTIFICADOS
    Local cFullPath As Character  // CAMINHO RELATIVO COMPLETO
    Local cError    As Character  // ERROS DE GERAÇÃO DE CERTIFICADO
    Local lFind     As Logical    // VALIDADOR DE EXTRAÇÃO DE CERTIFICADO

    // INICIALIZAÇÃO DE VARIÁVEIS
    lFind     := .F.
    aCert     := {}
    cCertPath := cCertPath + BAR
    cFullPath := Space(0)
    cError    := Space(0)

    // PROPRIEDADES PARA ARQUIVO *.CA
    cError    := Space(0)
    cFullPath := cCertPath + cFileName + "_ca.pem"
    lFind     := File(cFullPath)

	logZBE(SE1->E1_NUM + " esta na rotina GETCERTIFICATE e o certificado _ca.pem eh " + cFullPath )

    // VERIFICA SE O ARQUIVO JÁ EXISTE,
    // CASO NÃO EFETUA A CRIAÇÃO
    If (!lFind)
        If (!PFXCA2PEM(cCertPath + cFileName + ".pfx", cFullPath, @cError, cPassword))
			logZBE(SE1->E1_NUM + " erro na extração do certificado *_CA" )
            ConOut(PadC("ERROR: Couldn't extract *_CA certificate", 80))
        EndIf
    EndIf

    // ADICIONA O CAMINHO NO RETORNO
    AAdd(aCert, {"CA", cFullPath, lFind})

    // PROPRIEDADES PARA ARQUIVO *.KEY
    cError    := Space(0)
    cFullPath := cCertPath + cFileName + "_key.pem"
    lFind     := File(cFullPath)

	logZBE(SE1->E1_NUM + " esta na rotina GETCERTIFICATE e o certificado .KEY eh " + cFullPath )

    // VERIFICA SE O ARQUIVO JÁ EXISTE,
    // CASO NÃO EFETUA A CRIAÇÃO
    If (!lFind)
        If (!PFXKey2PEM(cCertPath + cFileName + ".pfx", cFullPath, @cError, cPassword))
			logZBE(SE1->E1_NUM + " erro na extração do certificado *_KEY" )
            ConOut(PadC("ERROR: Couldn't extract *_KEY certificate", 80))
        EndIf
    EndIf

    // ADICIONA O CAMINHO NO RETORNO
    AAdd(aCert, {"KEY", cFullPath, lFind})

    // PROPRIEDADES PARA ARQUIVO *.CERT
    cError    := Space(0)
    cFullPath := cCertPath + cFileName + "_cert.pem"
    lFind     := File(cFullPath)

	logZBE(SE1->E1_NUM + " esta na rotina GETCERTIFICATE e o certificado _cert.pem eh " + cFullPath )

    // VERIFICA SE O ARQUIVO *.CERT JÁ EXISTE,
    // CASO NÃO EFETUA A CRIAÇÃO
    If (!lFind)
        If (!PFXCert2PEM(cCertPath + cFileName + ".pfx", cFullPath, @cError, cPassword))
			logZBE(SE1->E1_NUM + " erro na extração do certificado *_CERT" )
            ConOut(PadC("ERROR: Couldn't extract *_CERT certificate", 80))
        EndIf
    EndIf

    // ADICIONA O CAMINHO NO RETORNO
    AAdd(aCert, {"CERT", cFullPath, lFind})

    // VERIFICA SE OS CERTIFICADOS BÁSICOS FORAM EXTRAÍDOS
    If (!aCert[2][3] .And. !aCert[3][3])
        Final("ERROR: Couldn't extract any certificate")
    EndIf

Return (aCert)

/*/{Protheus.doc} Static Function UpNumSE1(cCampo)
	(long_description)
	@type  Static Function
	@author user
	@since 10/03/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function UpNumSE1(cCampo)

	Local cRet   := ""
	Local cQuery := ""

	If Select("WorkWS") > 0
		WorkWS->( dbCloseArea() )
	EndIf

	cQuery := " SELECT E1_NUMBCO, E1_IDCNAB
	cQuery += " FROM " + RetSqlName("SE1") + " (NOLOCK) 
	cQuery += " WHERE E1_FILIAL='"+SE1->E1_FILIAL+"'
	cQuery += " AND E1_PREFIXO='"+SE1->E1_PREFIXO+"'
	cQuery += " AND E1_NUM='"+SE1->E1_NUM+"'
	cQuery += " AND E1_PARCELA='"+SE1->E1_PARCELA+"'
	cQuery += " AND E1_TIPO='"+SE1->E1_TIPO+"'
	cQuery += " AND E1_CLIENTE='"+SE1->E1_CLIENTE+"'
	cQuery += " AND E1_LOJA='"+SE1->E1_LOJA+"'
	cQuery += " AND D_E_L_E_T_=''

	tcQuery cQuery New Alias "WorkWS"

	WorkWS->( dbGoTop() )

	If AllTrim(cCampo) == "E1_NUMBCO"
		cRet := PadR(AllTrim(WorkWS->E1_NUMBCO),11)
	
	ElseIf AllTrim(cCampo) == "E1_IDCNAB"
		cRet := WorkWS->E1_IDCNAB
	
	EndIf

	If Select("WorkWS") > 0
		WorkWS->( dbCloseArea() )
	EndIf

Return cRet

/*/{Protheus.doc} Static Function UpSoap
	Trata retorno Soap - WS Bradesco boleto cobrança
	@type  Static Function
	@author FWNM
	@since 11/03/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
/*/
Static Function UpSoap(cXML)

	Local lRet := .t.
	Local aRet := {}
	Local aDadRet := {}
	Local aDadWS := {}

	Local oXML := Nil
	Local cError := ""
	Local cWarning := ""

	Local cCodRetWS := ""
	Local cDscRetWS := ""

	local ii, i

	logZBE(SE1->E1_NUM + " entrou na funcao UPSOAP para gravar retorno bradesco ")

	//Removo espaços em branco
	cXML := Alltrim(cValToChar(cXML))

	//Verifico o argumento da função.
	If Empty(cXML)
		lRet := .f.
		MsgStop("Função UpSoap não recebeu o argumento cXML.", "01 - Função UpSoap - ADFIN087P")
		aAdd(aRet, {.F.,oXml})
		logZBE("FUNCAO UpSoap: NAO RECEBEU ARGUMENTO cXML" )
		Return lRet
	EndIf

	// Retiro caracteres especiais 
	cXML := FwNoAccent(cXML)

	// Funcao de apoio para retirar CR/LF/TAB de strings e eventualmente acentos
	cXML := FwCutOff(cXML, .T.)

	//Cria um objeto XML.
	oXML := XMLParser( cXML, "_", @cError, @cWarning )

	If (oXML == NIL )
		lRet := .f.
		MsgStop("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
		logZBE("FUNCAO UpSoap: FALHA NA GERACAO DO XML (ERRO) " +cError+" / "+cWarning )
		Return lRet
	Endif

	//Verifica se a geração do objeto xml apresentou erro.
	If cError # ""
		lRet := .f.
		MsgStop("A conversão da string xml para o objeto xml apresentou ERRO! Erro: " + cError,"02 - UpSoap - ADFIN087P")
		aAdd(aRet, {.F.,oXml})
		logZBE("FUNCAO UpSoap: FALHA NA GERACAO DO XML (ERRO) " + cError )
		Return lRet
	EndIf

	//Verifica se a geração do objeto xml apresentou alerta.
	If cWarning # ""
		lRet := .f.
		MsgStop("A conversão da string xml para o objeto xml apontou ALERTA! Alerta: " + cWarning,"03 - UpSoap - ADFIN087P")
		aAdd(aRet, {.F.,oXml})
		logZBE("FUNCAO UpSoap: FALHA NA GERACAO DO XML (ALERTA) " + cWarning)
		Return lRet
	EndIf
	
	//Populo array com xml
	aAdd(aRet, {.T., oXML:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_NS2_REGISTRARTITULORESPONSE:_RETURN:TEXT})

	aDadRet := Separa(aRet[1,2], ",")
	For i:=1 to Len(aDadRet)

		aDadWS := Separa(aDadRet[i], ":")
		For ii:=1 to Len(aDadWS)

			If Subs(aDadWS[ii],3,6) == "cdErro"
				cCodRetWS := AllTrim(Str(Val(Subs(AllTrim(aDadWS[2]),2,2))))
			EndIf

			If Subs(aDadWS[ii],3,7) == "msgErro" .or. Subs(aDadWS[ii],3,7) == "msgRetBco"
				cDscRetWS := AllTrim(aDadRet[2]) //AllTrim(aDadWS[2])
			EndIf
			
			If !Empty(cCodRetWS) .and. !Empty(cDscRetWS)
				Exit
			EndIf

		Next ii

		If !Empty(cCodRetWS) .and. !Empty(cDscRetWS)
			Exit
		EndIf

	Next i

	// Gravo tabelas SE1 + ZBE
	RecLock("SE1", .f.)
		SE1->E1_XWSBRAC := cCodRetWS
		SE1->E1_XWSBRAD := cDscRetWS + " - " + DtoC(msDate()) + " - " + time()
	SE1->( msUnLock() )
	SE1->( FKCOMMIT() )

	logZBE(SE1->E1_NUM + "Retorno SOAP " + SE1->E1_XWSBRAC + " : " + SE1->E1_XWSBRAD )
	
Return lRet

/*/{Protheus.doc} Static Function LOGZBE
	Gera log ZBE
	@type  Static Function
	@author Everson
	@since 24/05/2019
	@version 01
/*/
Static Function logZBE(cMensagem)

	RecLock("ZBE", .T.)
		Replace ZBE_FILIAL 	   	With FWxFilial("ZBE")
		Replace ZBE_DATA 	   	With msDate()
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With cMensagem
		Replace ZBE_MODULO	    With "SIGAFIN"
		Replace ZBE_ROTINA	    With "ADFIN087P" 
	ZBE->( msUnlock() )

Return

/*/{Protheus.doc} Static Function ChkTESPV(SC5->C5_FILIAL, SC5->C5_NUM)
	Checa se todas as TES geram financeiro
	@type  Static Function
	@author FWNM
	@since 08/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
/*/
Static Function ChkTESPV(cC5_FILIAL, cC5_NUM)

	Local lRet   := .t.
	Local cQuery := ""

	If Select("WorkTES") > 0
		WorkTES->( dbCloseArea() )
	EndIf

	cQuery := " SELECT ISNULL(COUNT(DISTINCT C6_TES),0) TT_TES
	cQuery += " FROM " + RetSqlName("SC6") + " SC6 (NOLOCK)
	cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 (NOLOCK) ON F4_FILIAL='"+FWxFilial("SF4")+"' AND F4_CODIGO=C6_TES AND F4_DUPLIC='N' AND SF4.D_E_L_E_T_=''
	cQuery += " WHERE C6_FILIAL='"+cC5_FILIAL+"'
	cQuery += " AND C6_NUM='"+cC5_NUM+"'
	cQuery += " AND SC6.D_E_L_E_T_=''

	tcQuery cQuery New Alias WorkTES

	// Se tiver TES que não gera financeiro 
	If WorkTES->TT_TES >= 1
		lRet := .f.
	EndIf

	If Select("WorkTES") > 0
		WorkTES->( dbCloseArea() )
	EndIf

Return lRet

/*/{Protheus.doc} Static Function PreNota
	Função que retorna o valor total do pedido com os impostos
	@type  Static Function
	@author FWNM
	@since 25/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
/*/
Static Function PreNota()

	Local nValPed   := 0
	Local aArea     := GetArea()
    Local aAreaC5   := SC5->(GetArea())
    Local aAreaB1   := SC6->(GetArea())
    Local aAreaC6   := SB1->(GetArea())
    Local cQryIte   := ""
    Local nNritem   := 0
	Local cNumPed   := SC5->C5_NUM

	If Select("QRY_ITE") > 0
		QRY_ITE->( dbCloseArea() )
	EndIf

	//Seleciona agora os itens do pedido
	cQryIte := " SELECT 
	cQryIte += "    C6_ITEM, 
	cQryIte += "    C6_PRODUTO 
	cQryIte += " FROM 
	cQryIte += "    "+RetSQLName('SC6')+" SC6 (NOLOCK) 
	cQryIte += "    LEFT JOIN "+RetSQLName('SB1')+" SB1 (NOLOCK) ON ( 
	cQryIte += "        B1_FILIAL = '"+FWxFilial('SB1')+"'
	cQryIte += "        AND B1_COD = SC6.C6_PRODUTO
	cQryIte += "        AND SB1.D_E_L_E_T_ = ' '
	cQryIte += "    ) 
	cQryIte += " WHERE 
	cQryIte += "    C6_FILIAL = '"+FWxFilial('SC6')+"' 
	cQryIte += "    AND C6_NUM = '"+cNumPed+"' 
	cQryIte += "    AND SC6.D_E_L_E_T_ = ' ' 
	cQryIte += " ORDER BY "
	cQryIte += "    C6_ITEM "

	cQryIte := ChangeQuery(cQryIte)

	TCQuery cQryIte New Alias "QRY_ITE"
         
	DbSelectArea('SC5')
	//SC5->(DbSetOrder(1))
	//SC5->(DbSeek(FWxFilial('SC5') + cNumPed))

	MaFisIni(SC5->C5_CLIENTE,;                   // 1-Codigo Cliente/Fornecedor
			SC5->C5_LOJACLI,;                    // 2-Loja do Cliente/Fornecedor
			If(SC5->C5_TIPO$'DB',"F","C"),;      // 3-C:Cliente , F:Fornecedor
			SC5->C5_TIPO,;                       // 4-Tipo da NF
			SC5->C5_TIPOCLI,;                    // 5-Tipo do Cliente/Fornecedor
			MaFisRelImp("MT100",{"SF2","SD2"}),; // 6-Relacao de Impostos que suportados no arquivo
			,;                                   // 7-Tipo de complemento
			,;                                   // 8-Permite Incluir Impostos no Rodape .T./.F.
			"SB1",;                              // 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
			"MATA461")                           // 10-Nome da rotina que esta utilizando a funcao
         
	//Pega o total de itens
	QRY_ITE->(DbGoTop())
	While ! QRY_ITE->(EoF())
		nNritem++
		QRY_ITE->(DbSkip())
	EndDo
		
	//Preenchendo o valor total
	QRY_ITE->(DbGoTop())
	nTotIPI := 0

	While ! QRY_ITE->(EoF())

		//Pega os tratamentos de impostos
		SB1->(DbSeek(FWxFilial("SB1")+QRY_ITE->C6_PRODUTO))
		SC6->(DbSeek(FWxFilial("SC6")+cNumPed+QRY_ITE->C6_ITEM))
			
		MaFisAdd(   SC6->C6_PRODUTO,;                     // 1-Codigo do Produto                 ( Obrigatorio )
					SC6->C6_TES,;                         // 2-Codigo do TES                     ( Opcional )
					SC6->C6_QTDVEN,;                      // 3-Quantidade                     ( Obrigatorio )
					SC6->C6_PRCVEN,;                      // 4-Preco Unitario                 ( Obrigatorio )
					SC6->C6_VALDESC,;                     // 5 desconto
					SC6->C6_NFORI,;                       // 6-Numero da NF Original             ( Devolucao/Benef )
					SC6->C6_SERIORI,;                     // 7-Serie da NF Original             ( Devolucao/Benef )
					0,;                                   // 8-RecNo da NF Original no arq SD1/SD2
					SC5->C5_FRETE/nNritem,;               // 9-Valor do Frete do Item         ( Opcional )
					SC5->C5_DESPESA/nNritem,;             // 10-Valor da Despesa do item         ( Opcional )
					SC5->C5_SEGURO/nNritem,;              // 11-Valor do Seguro do item         ( Opcional )
					0,;                                   // 12-Valor do Frete Autonomo         ( Opcional )
					SC6->C6_VALOR,;                       // 13-Valor da Mercadoria             ( Obrigatorio )
					0,;                                   // 14-Valor da Embalagem             ( Opcional )
					0,;                                   // 15-RecNo do SB1
					0)                                    // 16-RecNo do SF4
			
		//nItem++
		QRY_ITE->(DbSkip())

	EndDo
		
	//Pegando totais
	nTotIPI   := MaFisRet(,'NF_VALIPI')
	nTotICM   := MaFisRet(,'NF_VALICM')
	nTotNF    := MaFisRet(,'NF_TOTAL')
	nTotFrete := MaFisRet(,'NF_FRETE')
	nTotISS   := MaFisRet(,'NF_VALISS')
		
	QRY_ITE->(DbCloseArea())
	
	MaFisEnd()

	//Atualiza o retorno
    nValPed := nTotNF + nTotIPI + nTotFrete + nTotISS
     
    RestArea(aAreaC6)
    RestArea(aAreaB1)
    RestArea(aAreaC5)
    RestArea(aArea)

Return nValPed

/*/{Protheus.doc} Static Function DiasUteis
	Função que retorna a quantidade de dias que serão adicionados na geração do RA 
	Dow = Retorna o número (entre 0 e 7) do dia da semana. Sendo, Domingo=1 e Sábado=7. No entanto, se o parâmetro dData estiver vazio, a função retornará zero (0).
	@type  Static Function
	@author FWNM
	@since 05/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function DiaUtil(nDiasBol)
    
  	Local nDiasAdd := 0
    Local dDtRA    := msDate()+nDiasBol
    Local dDtVldRA := DataValida(dDtRA) 

    Do While dDtRA <= dDtVldRA
        nDiasAdd++
        dDtRA := DaySum(dDtRA, 1)
    EndDo

Return nDiasAdd

/*/{Protheus.doc} Static Function UpE1IDCNAB()
	
	@type  Static Function
	@author FWNM
	@since 05/08/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 059415 - FWNM - 05/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Ajuste na geração do E1_IDCNAB devido desativação das customizações antigas 	
/*/
Static Function UpE1IDCNAB()

    Local cQuery   := ""
    Local cNextCod := ""
	Local nOrdCNAB := 19
	Local cIdCnab  := SE1->E1_IDCNAB
	Local aArea    := GetArea() 
	
	If Empty(SE1->E1_IDCNAB)

		Do While .t. // @history ticket TI  - FWNM - 10/09/2021 - Melhoria IDCNAB após golive CLOUD
		
			cIdCnab  := GetSxENum("SE1", "E1_IDCNAB","E1_IDCNAB"+cEmpAnt, nOrdCNAB)
			ConfirmSX8()

			// Checo duplicidade de E1_IDCNAB
			If Select("WorkIDCNAB") > 0
				WorkIDCNAB->( dbCloseArea() )
			EndIf

			cQuery := " SELECT E1_IDCNAB, COUNT(1) TT_IDCNAB
			cQuery += " FROM " + RetSqlName("SE1") + " (NOLOCK)
			cQuery += " WHERE D_E_L_E_T_=''
			cQuery += " AND E1_IDCNAB='"+cIdCnab+"'
			cQuery += " AND E1_IDCNAB<>''
			cQuery += " GROUP BY E1_IDCNAB
			cQuery += " HAVING COUNT(1) >= 2

			tcQuery cQuery New Alias "WorkIDCNAB"

			WorkIDCNAB->( dbGoTop() )
			If WorkIDCNAB->( !EOF() )

				// Encontrou título com o IDCNAB que será gravado no título atual
				logZBE("E1_IDCNAB n. " + cIdCnab + " já existe na base! Será alterado por este PE antes de gravar no E1_NUM = " + SE1->E1_NUM)

				If Select("WorkLAST") > 0
					WorkLAST->( dbCloseArea() )
				EndIf

				cQuery := " SELECT MAX(E1_IDCNAB) LAST_IDCNAB
				cQuery += " FROM " + RetSqlName("SE1") + " (NOLOCK)
				cQuery += " WHERE E1_IDCNAB<>''
				cQuery += " AND D_E_L_E_T_=''

				tcQuery cQuery New Alias "WorkLAST"

				cNextCod := Soma1(AllTrim(WorkLAST->LAST_IDCNAB))

				cIdCnab := cNextCod // Recebe o próximo caso tenha encontrado algum idcnab em outro título

				logZBE("Novo E1_IDCNAB n. " + cNextCod + " foi gravado no título n. " + SE1->E1_NUM + " para evitar duplicidade")

				If Select("WorkLAST") > 0
					WorkLAST->( dbCloseArea() )
				EndIf

			EndIf

			If Select("WorkIDCNAB") > 0
				WorkIDCNAB->( dbCloseArea() )
			EndIf

			// @history ticket TI  - FWNM - 10/09/2021 - Melhoria IDCNAB após golive CLOUD
			aAreaSE1 := SE1->( GetArea() )
			SE1->( dbSetOrder(19) ) // E1_IDCNAB, R_E_C_N_O_, D_E_L_E_T_
			If SE1->( dbSeek(cIdCnab) )
				RestArea(aAreaSE1)
				Loop
			Else
				// Grava E1_IDCNAB
				RestArea(aAreaSE1)
				dbSelectArea("SE1")
				RecLock("SE1", .f.)
					SE1->E1_IDCNAB := cIdCnab
				SE1->( MsUnlock() )
				ConfirmSx8()
				Exit
			EndIf

		EndDo

	EndIf

	RestArea(aArea)

Return cIdCnab

/*/{Protheus.doc} Static Function ChkFIE
	Garante que o registro FIE exista quando existir PV e PR
	@type  Static Function
	@author Everson
	@since 27/08/2020
	@version 01
	@history ticket 102 - FWNM - 27/08/2020 - WS BRADESCO 
/*/
Static Function ChkFIE()

	Local aArea	    := GetArea()
	Local cQuery    := ""
	Local cTipoE1 := GetMV("MV_#WSTIPO",,"PR") // ticket 745 - FWNM - Implementação título PR

	If Select("WorkFIE") > 0
		WorkFIE->( dbCloseArea() )
	EndIf
	
	cQuery := " SELECT C5_FILIAL, C5_NUM, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_SALDO
	cQuery += " FROM " + RetSqlName("SC5") + " SC5 (NOLOCK)
	cQuery += " INNER JOIN " + RetSqlName("SE4") + " SE4 (NOLOCK) ON E4_FILIAL='"+FWxFilial("SE4")+"' AND E4_CODIGO=C5_CONDPAG AND E4_CTRADT='1' AND SE4.D_E_L_E_T_=''
	cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 (NOLOCK) ON E1_FILIAL=C5_FILIAL AND E1_NUM=C5_NUM AND E1_TIPO='"+cTipoE1+"' AND SE1.D_E_L_E_T_=''
	cQuery += " WHERE C5_FILIAL='"+FWxFilial("SC5")+"' 
	cQuery += " AND C5_EMISSAO='"+DtoS(msDate())+"'
	cQuery += " AND SC5.D_E_L_E_T_=''
	cQuery += " AND NOT EXISTS (
	cQuery += " SELECT 'X'
	cQuery += " FROM " + RetSqlName("FIE") + " FIE (NOLOCK)
	cQuery += " WHERE FIE_FILIAL=C5_FILIAL
	cQuery += " AND FIE_PEDIDO=C5_NUM
	cQuery += " AND D_E_L_E_T_=''
	cQuery += " )

	tcQuery cQuery New Alias "WorkFIE"

	aTamSX3 := TamSX3("E1_SALDO")
	tcSetField("WorkFIE", "E1_SALDO", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	WorkFIE->( dbGoTop() )
	Do While WorkFIE->( !EOF() )

		// Gero vinculo da boleto com o Pedido de Vendas
		RecLock("FIE", .t.)
			FIE->FIE_FILIAL := FWxFilial("FIE")
			FIE->FIE_CART   := "R"
			FIE->FIE_PEDIDO := WorkFIE->C5_NUM
			FIE->FIE_PREFIX := WorkFIE->E1_PREFIXO
			FIE->FIE_NUM    := WorkFIE->E1_NUM
			FIE->FIE_PARCEL := WorkFIE->E1_PARCELA
			FIE->FIE_TIPO   := WorkFIE->E1_TIPO
			FIE->FIE_CLIENT := WorkFIE->E1_CLIENTE
			FIE->FIE_LOJA   := WorkFIE->E1_LOJA
			FIE->FIE_VALOR  := WorkFIE->E1_SALDO
			FIE->FIE_SALDO  := WorkFIE->E1_SALDO
		FIE->( msUnLock() )

		logZBE(WorkFIE->C5_NUM + " FIE GERADO POIS IDENTIFICOU QUE EXISTE BOLETO E PV - CHKFIE - ADFIN087P")

		WorkFIE->( dbSkip() )

	EndDo

	If Select("WorkFIE") > 0
		WorkFIE->( dbCloseArea() )
	EndIf

	RestArea( aArea )

Return

/*/{Protheus.doc} User Function u_BxWSPR(SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA)
	Função para substituir PR pelo RA
	@type  Function
	@author FWNM
	@since 17/09/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 745 - FWNM - 17/09/2020 - Implementação título PR
/*/
User Function BxWSPR(lTela, cE1_FILIAL, cE1_PREFIXO, cE1_NUM, cE1_PARCELA, cE1_TIPO, cE1_CLIENTE, cE1_LOJA)

	Local lOk        := .f.
    Local aVetor     := {}
    Local aBaixa     := {}
	Local aDadRA     := {}
	Local cTipoE1    := GetMV("MV_#WSTIPO",,"PR") 
	Local nOpc       := 0
	Local dDtCreRA   := CtoD("//")
	Local lOKDtCre   := .F.
	Local oCmpDt     := Array(01)
	Local oBtnDt     := Array(02)
	Local aAreaSE1   := SE1->( GetArea() )
	Local aAreaSC5   := SC5->( GetArea() )
	Local dDtBaseBkp := dDataBase
	Local cHistRA    := "RA vinculado ao PV n " + cE1_NUM
	Local nRecnoE1PR := 0
	Local nRecnoE1RA := 0
	Local cFunBkp    := FunName()
	Local cFIEPEDIDO := ""

 	//Substituicao automatica
	Local cFIHSeq	 	:= ""   // Armazena Sequencial gerado na baixa (SE5)
	Local cPrefOri   	:= ""   // Armazena prefixo do titulo PR
	Local cNumOri    	:= ""   // Armazena numero do titulo PR
	Local cParcOri   	:= ""   // Armazena parcela do titulo PR
	Local cTipoOri   	:= ""   // Armazena tipo do titulo PR
	Local cCfOri     	:= ""   // Armazena cliente/fornecedor do titulo PR
	Local cLojaOri   	:= ""   // Armazena loja do titulo PR
	Local cPrefDest  	:= ""   // Armazena prefixo do titulo NF
	Local cNumDest   	:= ""   // Armazena numero do titulo NF
	Local cParcDest  	:= ""   // Armazena parcela do titulo NF
	Local cTipoDest  	:= ""   // Armazena tipo do titulo NF
	Local cCfDest    	:= ""   // Armazena cliente/fornecedor do titulo NF
	Local cLojaDest 	:= ""   // Armazena loja do titulo NF
	Local cFilDest	 	:= ""   // Armazena filial de destino do titulo NF
	
	Default lTela       := .f.
	Default cE1_PREFIXO := ""
	Default cE1_NUM     := ""
	Default cE1_PARCELA := ""
    Default cE1_TIPO    := ""
    Default cE1_CLIENTE := ""
	Default cE1_LOJA    := ""

	SetFunName("FINA040")
	
	// Posiciono no título tipo PR/BOL
	SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
	If SE1->( dbSeek(cE1_FILIAL+cE1_PREFIXO+cE1_NUM+cE1_PARCELA+cE1_TIPO+cE1_CLIENTE+cE1_LOJA) )

		nRecnoE1PR := SE1->( RecNo() )
		dDtCreRA := SE1->E1_VENCREA

		// Consisto tipo do título
		If AllTrim(cE1_TIPO) <> AllTrim(cTipoE1)
			lOk := .f.
			msgAlert("[ADFIN087P - BXWSPR-01] - Substituição não permitida! Título n. " + AllTrim(cE1_NUM) + " não é tipo " + cTipoE1 + " ...")
			Return lOk
		EndIf

		// Tela para o usuário informar a data do crédito
		If lTela

			If msgNoYes("O adiantamento (RA) será gerado na data/crédito (E5_DTDISPO): " + DtoC(dDtCreRA) + " ! Deseja modificar?")

				Do While .t.

					DEFINE MSDIALOG oDlgDtCre TITLE "Data do Crédito do RA (Adiantamento PV)" FROM 0,0 TO 100,350  OF oMainWnd PIXEL
					
						@ 003, 003 TO 050,165 PIXEL OF oDlgDtCre
						
						@ 010,020 Say "Dt Crédito:" of oDlgDtCre PIXEL
						@ 005,060 MsGet oCmpDt Var dDtCreRA SIZE 70,12 of oDlgDtCre PIXEL //Valid ( VldDtCreRA(dDtCreRA) )
						
						@ 030,055 BUTTON oBtnDt[01] PROMPT "Confirma"     of oDlgDtCre   SIZE 68,12 PIXEL ACTION ( nOpc := 1, lOKDtCre := VldDtCreRA(dDtCreRA), oDlgDtCre:End() )
						//@ 030,089 BUTTON oBtnDt[02] PROMPT "Cancela"      of oDlgDtCre   SIZE 68,12 PIXEL ACTION ( nOpc := 2, lOKDtCre := VldDtCreRA(dDtCreRA), oDlgDtCre:End() ) 
						
					ACTIVATE MSDIALOG oDlgDtCre CENTERED

					If nOpc == 0
						Alert("Você não clicou nos botões Confirma/Cancela! Clique na opção correta...")
					Else
						If lOKDtCre
							Exit
						Else
							Alert("Data Crédito inválida! Informe uma data correta...")
						EndIf
					EndIf

				EndDo
			
			EndIf
		
		Else

			dDtCreRA := dDataCred // Ticket 745 - Substituição PR x RA - PV adiantamento - Data crédito via RETORNO CNAB
		
		EndIf
		//

		// Efetuo a substituição
		Begin Transaction

			dDtBaseBkp := dDataBase
			dDataBase  := dDtCreRA
		
			///////////////////////////////////////////
			// Titulo PR será baixado por substituicao
			///////////////////////////////////////////
			cFIEPEDIDO := PadR(AllTrim(SE1->E1_NUM),TamSX3("E1_NUM")[1])

			SC5->( dbSetOrder(1) ) // C5_FILIAL+C5_NUM
			If SC5->( dbSeek(SE1->E1_FILIAL+cFIEPEDIDO) )

            	If AllTrim(Posicione("SE4",1,FWxFilial("SE4")+SC5->C5_CONDPAG,"E4_CTRADT")) == "1" // Cond Adiantamento = SIM 
			
					FIE->( dbSetOrder(2) ) // FIE_FILIAL, FIE_CART, FIE_CLIENT, FIE_LOJA, FIE_PREFIX, FIE_NUM, FIE_PARCEL, FIE_TIPO, FIE_PEDIDO, R_E_C_N_O_, D_E_L_E_T_
					If FIE->( dbSeek(FWxFilial("FIE")+"R"+cE1_CLIENTE+cE1_LOJA+cE1_PREFIXO+cE1_NUM+cE1_PARCELA+cE1_TIPO) )
								
						// Apago amarração do PR/BOL (custom)
						RecLock("FIE", .F.)
							FIE->( dbDelete() )
						FIE->( msUnLock() )
						FIE->( fkCommit() )

						logZBE( cE1_NUM + " FIE DELETADO - TITULO TIPO " + cTipoE1 + Iif(lTela," MANUALMENTE", " RETORNO CNAB") )

					EndIf

					//Baixa Boleto
					lMsErroAuto := .F.
					dbSelectArea("SE1")

					nRecnoE1PR := SE1->( RecNo() )
					RecLock("SE1", .F.)
						SE1->E1_TIPO := "BOL"
					SE1->( msUnLock() )
					SE1->( fkCommit() )
				
					aBaixa := { {"E1_PREFIXO"  ,SE1->E1_PREFIXO ,Nil },;
								{"E1_NUM"      ,SE1->E1_NUM     ,Nil },;
								{"E1_TIPO"     ,SE1->E1_TIPO    ,Nil },;
								{"E1_CLIENTE"  ,SE1->E1_CLIENTE ,Nil },;
								{"E1_LOJA"     ,SE1->E1_LOJA    ,Nil },;
								{"E1_NATUREZ"  ,SE1->E1_NATUREZ ,Nil },;
								{"E1_PARCELA"  ,SE1->E1_PARCELA ,Nil },;
								{"AUTMOTBX"    ,"STP"           ,Nil },;
								{"CBANCO"      ,""              ,Nil },;
								{"CAGENCIA"    ,""              ,Nil },;
								{"CCONTA"      ,""              ,Nil },;
								{"AUTDTBAIXA"  ,msDate()        ,Nil },;
								{"AUTDTCREDITO",dDtCreRA        ,Nil },;
								{"AUTHIST"     ,"Bx PR n. " + AllTrim(cE1_NUM) + " - Gerou RA n. " + SE1->E1_NUM, Nil },;
								{"AUTJUROS"    ,0               ,Nil,.T.}}
								//{"NVALREC" ,SE1->E1_VALOR,Nil }}

					MSExecAuto({|x,y,b,a| Fina070(x,y,b,a)},aBaixa,3,.F.,3) //3 - Baixa de Título, 5 - Cancelamento de baixa, 6 - Exclusão de Baixa.

					//Em caso de erro na baixa
					If lMsErroAuto
					
						DisarmTransaction()
						MostraErro()
					
					Else

						logZBE( cE1_NUM + " BAIXADO POR SUBSTITUICAO - TITULO TIPO " + cTipoE1 + Iif(lTela," MANUALMENTE", " RETORNO CNAB") )

						RecLock("SE5", .F.)
							SE5->E5_TIPO := cTipoE1
						SE5->( msUnLock() )
						SE5->( fkCommit() )

						SE1->( dbGoTo(nRecnoE1PR) )
						RecLock("SE1", .F.)
							SE1->E1_TIPO := cTipoE1
						SE1->( msUnLock() )
						SE1->( fkCommit() )
						
						//Grava amarração dos títulos substituídos
						cFIHSeq	 := SE5->E5_SEQ

						cPrefOri  := cTipoE1
						cNumOri   := SE1->E1_NUM
						cParcOri  := SE1->E1_PARCELA
						cTipoOri  := cTipoE1
						cCfOri    := SE1->E1_CLIENTE
						cLojaOri  := SE1->E1_LOJA

						cPrefDest := "RA"
						cNumDest  := SE1->E1_NUM
						cParcDest := SE1->E1_PARCELA
						cTipoDest := "RA"
						cCfDest   := SE1->E1_CLIENTE
						cLojaDest := SE1->E1_LOJA

						dbselectarea("FIH")
						FCriaFIH("SE1", cPrefOri, cNumOri, cParcOri, cTipoOri, cCfOri, cLojaOri,;
						"SE1", cPrefDest, cNumDest, cParcDest, cTipoDest, cCfDest, cLojaDest,;
						cFilDest, cFIHSeq )

						logZBE( cE1_NUM + " GEROU FIH (AMARRACAO TITULOS SUBSTITUIDOS) - ORIGEM X DESTINO " )

						///////////////////////////////////////////
						// Incluo o adiantamento (RA)
						///////////////////////////////////////////
						cPerg := PadR("FIN040",Len(SX1->X1_GRUPO))
						Pergunte(cPerg, .f.)
						MV_PAR03 := 2 // Contabiliza on line ? = 2 = Não

						aDadRA := { { "E1_PREFIXO", PadR("RA",TamSX3("E1_PREFIXO")[1])    		 , NIL },;
									{ "E1_NUM"    , cE1_NUM		     , NIL },;
									{ "E1_TIPO"   , PadR("RA",TamSX3("E1_TIPO")[1])     		 , NIL },;
									{ "E1_NATUREZ", SE1->E1_NATUREZ	 , NIL },;
									{ "E1_CLIENTE", SE1->E1_CLIENTE  , NIL },;
									{ "E1_LOJA"   , SE1->E1_LOJA     , NIL },;
									{ "E1_EMISSAO", dDtCreRA         , NIL },;
									{ "E1_VENCTO" , dDtCreRA         , NIL },;
									{ "E1_VENCREA", dDtCreRA         , NIL },;
									{ "CBCOAUTO"  , SE1->E1_PORTADO  , NIL },;
									{ "CAGEAUTO"  , SE1->E1_AGEDEP   , NIL },;
									{ "CCTAAUTO"  , SE1->E1_CONTA    , NIL },;
									{ "E1_VALOR"  , SE1->E1_VALOR    , NIL },;
									{ "E1_HIST"   , cHistRA          , NIL }}
			
						lMsErroAuto := .f.
						dbSelectArea("SE1")
						msExecAuto( { |x,y| FINA040(x,y) }, aDadRA, 3 )  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

						// Restauro database
						dDataBase := dDtBaseBkp 

						If lMsErroAuto

							DisarmTransaction()
							MostraErro()

						Else
							
							// Retorno OK para substituições 
							lOk := .t.

							// Gero vinculo do RA com o Pedido de Vendas
							RecLock("FIE", .t.)
								FIE->FIE_FILIAL := FWxFilial("FIE")
								FIE->FIE_CART   := "R"
								FIE->FIE_PEDIDO := cE1_NUM
								FIE->FIE_PREFIX := SE1->E1_PREFIXO
								FIE->FIE_NUM    := cE1_NUM
								FIE->FIE_PARCEL := SE1->E1_PARCELA
								FIE->FIE_TIPO   := "RA"
								FIE->FIE_CLIENT := SE1->E1_CLIENTE
								FIE->FIE_LOJA   := SE1->E1_LOJA
								FIE->FIE_VALOR  := SE1->E1_SALDO
								FIE->FIE_SALDO  := SE1->E1_SALDO
							FIE->( msUnLock() )

							logZBE( cE1_NUM + " GEROU RA E FIE (AMARRACAO PV E ADIANTAMENTO) COM SUCESSO " )

						EndIf				
					
					EndIf
				
				EndIf
					
			EndIf

		End Transaction

	EndIf
	//

	// Envia email 
	If lOk
		SendMailRA() // -- ticket 745 - FWNM - 28/09/2020 - Implementação título PR
	EndIf

	SetFunName(cFunBkp)
	
	RestArea( aAreaSE1 )
	RestArea( aAreaSC5 )

Return lOk

/*/{Protheus.doc} Static Function VldDtCreRA
	Valida data do crédito informada pelo usuário
	@type  Function
	@author FWNM
	@since 17/09/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function VldDtCreRA(dDtCreRA)

	Local lRet := .t.

	// data não informada
	If Empty(dDtCreRA)
		lRet := .f.
	EndIf

	// Data inferior
	If dDtCreRA < msDate()
		lRet := .f.
	EndIf

	// Data válida
	If dDtCreRA <> DataValida(dDtCreRA)
		lRet := .f.
	EndIf

Return lRet

/*/{Protheus.doc} User Function X7CONDIC
	Gatilho contido no campo E1_NUM
	@type  Function
	@author FWNM
	@since 18/09/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
/*
User Function X7CONDIC(cCmp)

	Local lRet := .t.

	Default cCmp := ""

	If AllTrim(cCmp) == "E1_NUM"
		If !IsInCallStack("u_GeraRAPV") .and. !IsInCallStack("u_BxWSPR")
			lRet := .f.
		EndIf
	EndIf
	
Return lRet
*/

/*/{Protheus.doc} Static Function SendMailRA
	Envia email da geração do RA
	@type  Static Function
	@author Fernando Macieira
	@since 28/09/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function SendMailRA()

	Local cMensagem	:= ""
	Local cQuery	:= ""
	Local cAssunto	:= "[ RA ] - Adiantamento gerado para o PV n. " + SE1->E1_NUM
	Local cMails    := GetMV("MV_#WSRACX",,"cobranca@adoro.com.br;wagner.ferreira@adoro.com.br")

	// Cabeçalho
	cMensagem += '<html>'
	cMensagem += '<body>'
	cMensagem += '<p style="color:red">'+cValToChar(cAssunto)+'</p>'
	cMensagem += '<hr>'
	cMensagem += '<table border="1">'
	cMensagem += '<tr style="background-color: black;color:white">'
	cMensagem += '<td>Pedido Venda</td>'
	cMensagem += '<td>Cliente</td>'
	cMensagem += '<td>Valor Total</td>'
	cMensagem += '<td>Banco|Agência|Conta</td>'
	cMensagem += '<td>Data Crédito</td>'
	cMensagem += '</tr>'

	// Detalhes
	cMensagem += '<tr>'
	cMensagem += '<td>' + cValToChar(SE1->E1_NUM)     + '</td>'
	cMensagem += '<td>' + cValToChar(SE1->E1_NOMCLI)  + '</td>'
	cMensagem += '<td>' + cValToChar(Transform(SE1->E1_VALOR,"@E 999,999,999.99")) + '</td>'
	cMensagem += '<td>' + cValToChar(SE1->E1_PORTADO) + " | "+ cValToChar(SE1->E1_AGEDEP) + " | " + cValToChar(SE1->E1_CONTA) + '</td>'
	cMensagem += '<td>' + cValToChar(SE5->E5_DTDISPO) + '</td>'

	cMensagem += '</tr>'

	cMensagem += '</table>'
	cMensagem += '</body>'
	cMensagem += '</html>'

	ProcessarEmail(cAssunto,cMensagem,cMails)

Return

/*/{Protheus.doc} Static Function PROCESSAREMAIL
	Configurações EMAIL
	@type  Static Function
	@author Fernando Macieira
	@since 18/04/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ProcessarEmail(cAssunto,cMensagem,email)

	Local lOk           := .T.
	Local cBody         := cMensagem
	Local cErrorMsg     := ""
	Local aFiles        := {}
	Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
	Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
	Local cFrom         := AllTrim(GetMv("MV_RELFROM")) 
	Local cTo           := email
	Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)
	Local lAutOk        := .F.
	Local cAtach        := ""
	Local cSubject      := ""
	Local cCopia        := ""
	Local cCpOcul       := GetMV("MV_#WSMATI",,"fernando.sigoli@adoro.com.br")

	//Assunto do e-mail.
	cSubject := cAssunto

	//Conecta ao servidor SMTP.
	Connect Smtp Server cServer Account cAccount  Password cPassword Result lOk

	If !lAutOk
		If ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)
		Else
			lAutOk := .T.
		EndIf
	EndIf

	If lOk .And. lAutOk

		//Envia o e-mail.
		Send Mail From cFrom To cTo CC cCopia BCC cCpOcul Subject cSubject Body cBody ATTACHMENT cAtach Result lOk
		//Send Mail From cDe To cPara CC cCopia Subject cAssunto Body cMensag Attachment cAnexo Result lOk
		//Send Mail From cDe To cPara CC cCopia BCC cCpOcul Subject cAssunto Body cMensag Attachment cAnexo Result lOk

		//Tratamento de erro no envio do e-mail.
		If !lOk
			Get Mail Error cErrorMsg
			ConOut("3 - " + cErrorMsg)
		Else
			ConOut(	"[ADFIN087P] - Email enviado com sucesso sobre RA gerado para: " + email )
		EndIf

	Else
	
		Get Mail Error cErrorMsg
		ConOut("4 - " + cErrorMsg)

	EndIf

	If lOk
		Disconnect Smtp Server
	EndIf

Return
