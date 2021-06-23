#Include "RwMake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"

/*/{Protheus.doc} User Function ADFIN053P
	Projeto: Projeto Financas - Integração no Financeiro de PA Gerada pelo SAG
	@type  Function
	@author Ricardo Lima
	@since 12/03/18
	@version 01
	@history Chamado TI - gera PA com data de emissão igual a data de vencimento - Ricardo Lima - 16/04/18
	@history Chamado TI - Verificação de duplicidade de titulo na integração - Ricardo Lima - 08/06/18
	@history Chamado 046609 - Retirado o Vetor aBco para gerar os bancos titulos a titulos - William Costa - 22/01/2019
	@history Chamado 051689 - Campo E2_CREDIT gravado errado afetando LP 513 (PA) - FWNM - 12/09/19
	@history Chamado 051689 - Campo E2_CREDIT gravado errado afetando LP 513 (PA) - FWNM - 25/09/18
	@history Chamado 051689 - Campo E2_CREDIT gravado errado afetando LP 513 (PA) - FWNM - 26/09/18
	@history Chamado 046609 - Adicionado variavel de backup da database, colocado veri ficacao se o campo E2_VENCREA esta menor que o parametro MV_DATAFIN para pular o registro - William Costa - 25/01/2019
	@history Chamado 043195 - Ajuste para considerar tabela ZFQ de Pedido de Compra de Pagamento Antecipado - Abel Babini Filho - 13/09/2019
	@history Chamado 043195 - Ajuste para considerar tabela ZFQ de Pedido de Compra de Pagamento Antecipado - Abel Babini Filho - 13/09/2019
	@history Chamado n.053212 - Possibilita inclusão de PA em outras moedas - Abel Babini - 08/11/2019
	@history Chamado n.053212 - Possibilita inclusão de PA com outras datas de vencimento - Abel Babini - 19/11/2019
	@history Chamado n.054307 || 054307 || OS 055702 || SUPRIMENTOS || RACHEL || 1621063514 || WOKFLOW SOL.PA - FWNM - 18/12/2019
	@history Chamado n.054406 || OS 055799 || SUPRIMENTOS || EVANDRA || 8362 || EMAIL P.A - FWNM - 20/12/2019
	@history Chamado n.054406 || OS 055799 || SUPRIMENTOS || EVANDRA || 8362 || EMAIL P.A - FWNM - 03/01/2020
    @history chamado 057682 - FWNM        - 04/05/2020 - || OS 059176 || FINANCAS || ANA || 8384 || LP - PAS
	@history Chamado 058823 - Everson - 09/06/2020. Tratamento para envio de e-mail, quando não localizar conta contábil para conta bancária informada.
	@history ticket 10979   - Leonardo P. Monteiro - 24/03/2021 - Tratativa do error.log na linha 381 quando o campo E2_MOEDA vem com valores preenchidos informando o tipo da moeda. Anteriormente esse campo vinha como 'nil'.
/*/
User Function ADFIN053P(cOpc)

	Local _aArea
	Local cAliasF1
	Local cAliasPA
	Local cAliasEX
	Local cErro    := ""
	Local nNum     := 0
	Local lAutoJob := .F.
	Local cCta := "" // Chamado n. 051689 || OS 053035 || CONTROLADORIA || MONIK_MACEDO || 8956 || LOTES FINANCEIRO - FWNM - 12/09/2019
	Local cMail := "" // Chamado n. 054307 || OS 055702 || SUPRIMENTOS || RACHEL || 1621063514 || WOKFLOW SOL.PA - fwnm - 18/12/2019
	
	//VERIFICA SE ESTA RODANDO VIA MENU OU SCHEDULE
	If Select("SX6") == 0
		lAutoJob := .T.
	EndIf
	
	if lAutoJob

		RPCClearEnv()
		RpcSetType(3)
		RpcSetEnv( "01" , "03" ,,, "FIN" , "FINA050" )

		// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 29/06/2020
		If !LockByName("ADFIN053P", .T., .F.)
			ConOut("[ADFIN053P] - Existe outro processamento sendo executado! Verifique...")
			RPCClearEnv()
			Return
		EndIf

	Endif

	PtInternal(1,ALLTRIM(PROCNAME()))

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	_aArea   := GetArea()
	cAliasF1 := GetNextAlias()
	cAliasPA := GetNextAlias()
	cAliasEX := GetNextAlias()
	
	Private lMsErroAuto 	 := .F.
	
	Private _cNomBco2       := GetPvProfString("INTSAGBD","BCO2","ERROR",GetADV97())
	Private _cSrvBco2       := GetPvProfString("INTSAGBD","SRV2","ERROR",GetADV97())
	Private _cPortBco2      := Val(GetPvProfString("INTSAGBD","PRT2","ERROR",GetADV97()))
	//Private _nTcConn2
	//Private _nTcConn1       := advConnection()
	Private aUpdates        := {}
	Private EUpdates        := {}
	Private cFilMOV
	
	Private aDados	         := {}
	Private aBco	         := {}
	Private cDestPaSag      := SuperGetMv( "MV_#ADFI53" , .F. , "contasapagar@adoro.com.br" ,  )
	Private cMensagem       := ""
	Private aDadPA          := {}
	Private aDadEX          := {}
	Private dBackupDataBase := DDATABASE //chamado 046609 William Costa 25/01/2019
	
	ConOut( "Inicio da integração de PA do SAG com o Protheus" + time() )
	// TcConType("TCPIP")
	// If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2))<0
	// 	ConOut( "Não foi possível  conectar ao banco integração" )
	// EndIf
	
	//TcSetConn(_nTcConn2)
	
	cQry := " SELECT * FROM SGFIN010 (NOLOCK) WHERE E2_TIPO = 'PA' AND STATUS_INT = 'S' AND STATUS_LIB = '2' "

	// Chamado n. 057682 || OS 059176 || FINANCAS || ANA || 8384 || LP - PAS - FWNM - 04/05/2020
	If IsInCallStack("u_ADFIN054P") .and. !lAutoJob
		cQry += " AND E2_PREFIXO = '"+TRB->E2_PREFIXO+"'
		cQry += " AND E2_NUM = '"+TRB->E2_NUM+"'
		cQry += " AND E2_PARCELA = '"+TRB->E2_PARCELA+"'
		cQry += " AND E2_FORNECE = '"+TRB->E2_FORNECE+"'
		cQry += " AND E2_LOJA = '"+TRB->E2_LOJA+"'
	EndIf
	//

	// INICIO | ABEL BABINI | 13/09/2019 | 043195 || OS 044312 || FINANCAS || EDUARDO || 8352 || PAG. ANTECIPADO
	cQry += " UNION "
	
	cQry += " SELECT "
	cQry += " 	ZFQ_FILIAL COLLATE Latin1_General_CI_AS AS E2_FILIAL, "
	cQry += " 	ZFQ_PREFIX COLLATE Latin1_General_CI_AS AS E2_PREFIXO, "
	cQry += " 	ZFQ_NUM COLLATE Latin1_General_CI_AS AS E2_NUM, "
	cQry += " 	ZFQ_PARCEL COLLATE Latin1_General_CI_AS AS E2_PARCELA, "
	cQry += " 	ZFQ_TIPO COLLATE Latin1_General_CI_AS AS E2_TIPO, "
	cQry += " 	ZFQ_NATURE COLLATE Latin1_General_CI_AS AS E2_NATUREZ, "
	cQry += " 	ZFQ_FORNEC COLLATE Latin1_General_CI_AS AS E2_FORNECE, "
	cQry += " 	ZFQ_LOJA COLLATE Latin1_General_CI_AS AS E2_LOJA, "
	cQry += " 	ZFQ_EMISSA COLLATE Latin1_General_CI_AS AS E2_EMISSAO, "
	cQry += " 	ZFQ_VENCTO COLLATE Latin1_General_CI_AS AS E2_VENCTO, "
	cQry += " 	ZFQ_VENCRE COLLATE Latin1_General_CI_AS AS E2_VENCREA, "
	cQry += " 	ZFQ_VALOR AS E2_VALOR, "
	cQry += " 	ZFQ_HIST COLLATE Latin1_General_CI_AS AS E2_HIST, "
	cQry += " 	'' AS E2_MSEXP, "
	cQry += " 	'' AS E2_DTBAIXA, "
	cQry += " 	ZFQ_MOEDA COLLATE Latin1_General_CI_AS AS E2_MOEDA, "
	cQry += " 	ZFQ_RECORI AS RECORIGEM, "
	cQry += " 	'' AS CODIGENE, "
	cQry += " 	ZFQ_TABGEN COLLATE Latin1_General_CI_AS AS TABEGENE, "
	cQry += " 	ZFQ.R_E_C_N_O_ AS R_E_C_N_O_, "
	cQry += " 	'' AS STATUS_INT, "
	cQry += " 	ZFQ_OPEINT COLLATE Latin1_General_CI_AS AS OPERACAO_INT, "
	cQry += " 	'' AS MENSAGEM_INT, "
	cQry += " 	'' AS STATUS_PRC, "
	cQry += " 	'' AS MENSAGEM_PRC, "
	cQry += " 	ZFQ_STSLIB COLLATE Latin1_General_CI_AS AS STATUBS_LIB, "
	cQry += " 	ZFQ_PRODUT COLLATE Latin1_General_CI_AS AS E2_PRODUTO, "
	cQry += " 	ZFQ_TOTAL AS E2_TOTAL, "
	cQry += " 	ZFQ_PORTAD COLLATE Latin1_General_CI_AS AS E2_PORTADO, "
	cQry += " 	ZFQ_AGENCI COLLATE Latin1_General_CI_AS AS E2_AGENCIA, "
	cQry += " 	ZFQ_CONTA COLLATE Latin1_General_CI_AS AS E2_CONTA, "
	cQry += " 	ZFQ_ORIVEN COLLATE Latin1_General_CI_AS AS W2_ORIVENC, "
	cQry += " 	'' AS E2_CREDIT "
	cQry += " FROM "+RetSqlName("ZFQ")+" AS ZFQ (NOLOCK) "
	cQry += " WHERE ZFQ.D_E_L_E_T_ = '' "
	cQry += " AND ZFQ.ZFQ_FILIAL = '"+cFilAnt+"'"
	cQry += " AND ZFQ.ZFQ_STSLIB = '2' "
	cQry += " AND ZFQ.ZFQ_TIPO = 'PA' "
	cQry += " AND ZFQ.ZFQ_TABGEN = 'SC7' "
	// FIM | ABEL BABINI | 13/09/2019 | 043195 || OS 044312 || FINANCAS || EDUARDO || 8352 || PAG. ANTECIPADO

	// Chamado n. 057682 || OS 059176 || FINANCAS || ANA || 8384 || LP - PAS - FWNM - 04/05/2020
	If IsInCallStack("u_ADFIN054P") .and. !lAutoJob
		cQry += " AND ZFQ.ZFQ_PREFIX = '"+TRB->E2_PREFIXO+"'
		cQry += " AND ZFQ.ZFQ_NUM = '"+TRB->E2_NUM+"'
		cQry += " AND ZFQ.ZFQ_PARCEL = '"+TRB->E2_PARCELA+"'
		cQry += " AND ZFQ.ZFQ_FORNEC = '"+TRB->E2_FORNECE+"'
		cQry += " AND ZFQ.ZFQ_LOJA = '"+TRB->E2_LOJA+"'
	EndIf
	//
	
	DbUseArea(.t., "TOPCONN", TcGenQry(,, cQry), cAliasF1, .F., .T.)
	
	TcSetField( cAliasF1, "E2_EMISSAO", "D", 8, 0 )
	TcSetField( cAliasF1, "E2_VENCTO", "D" , 8, 0 )
	
	//aBco	:= { (cAliasF1)->E2_PORTADO , (cAliasF1)->E2_AGENCIA , (cAliasF1)->E2_CONTA , "" , "" } 22/01/2019 ch: 046609 William Costa
	
	While !(cAliasF1)->(Eof())
		
		cMail := "" // Chamado n. 054406 || OS 055799 || SUPRIMENTOS || EVANDRA || 8362 || EMAIL P.A - FWNM - 20/12/2019
		
		// Chamado n. 054307 || OS 055702 || SUPRIMENTOS || RACHEL || 1621063514 || WOKFLOW SOL.PA - fwnm - 18/12/2019
		//TcSetConn(_nTcConn1)
		
		ZFQ->( dbGoTop() )
		ZFQ->( dbSetOrder(1) ) // //ZFQ_FILIAL, ZFQ_PREFIX, ZFQ_NUM, ZFQ_FORNEC, ZFQ_LOJA, ZFQ_PARCEL
		If ZFQ->( dbSeek(FWxFilial("ZFQ")+(cAliasF1)->E2_PREFIXO+(cAliasF1)->E2_NUM+(cAliasF1)->E2_FORNECE+(cAliasF1)->E2_LOJA+(cAliasF1)->E2_PARCELA) )
			
			aAreaAtu := GetArea()
			
			dbSelectArea(ZFQ->ZFQ_TABGEN)
			dbGoTo(ZFQ->ZFQ_RECORI)
			
			If AllTrim(ZFQ->ZFQ_TABGEN) == "SC7"
				cMail := UsrRetMail(SC7->C7_USER)
			EndIf
			
			RestArea( aAreaAtu )
			
		EndIf
		
		// Chamado n. 054406 || OS 055799 || SUPRIMENTOS || EVANDRA || 8362 || EMAIL P.A - FWNM - 20/12/2019
		/*
		If Empty(cMail)
		
		Aviso("ADFIN053P-01", "Usuário " + SC7->C7_USER + " - " + UsrRetName( SC7->C7_USER ) + " não possui email cadastrado! Será aberta uma tela para informar manualmente neste momento, mas contate TI para cadastramento no cadastro de usuários do sistema..." , {"OK"},, "Solicitação de PA")
		
		If msgYesNo("Deseja informar agora um email para envio ao solicitante desta PA?")
		
		oCmpPrj  := Array(01)
		oBtnPrj  := Array(02)
		cMail    := Space(100)
		
		DEFINE MSDIALOG oDlgPrj TITLE "Email - Solicitação de PA" FROM 0,0 TO 100,350  OF oMainWnd PIXEL
		
		@ 003, 003 TO 050,165 PIXEL OF oDlgPrj
		
		@ 010,020 Say "eMails:" of oDlgPrj PIXEL
		@ 005,060 MsGet oCmpPrj Var cMail SIZE 70,12 of oDlgPrj PIXEL Valid !Empty(cMail)
		
		@ 030,015 BUTTON oBtnPrj[01] PROMPT "Confirma"     of oDlgPrj   SIZE 68,12 PIXEL ACTION oDlgPrj:End()
		@ 030,089 BUTTON oBtnPrj[02] PROMPT "Cancela"      of oDlgPrj   SIZE 68,12 PIXEL ACTION oDlgPrj:End()
		
		ACTIVATE MSDIALOG oDlgPrj CENTERED
		
		EndIf
		
		EndIf
		*/
		
		//TcSetConn(_nTcConn2)
		//
		
		AADD(aDados, {	Nil				  ,; // 01
		.F.                 	          ,; // 02
		(cAliasF1)->E2_FILIAL	          ,; // 03
		(cAliasF1)->E2_PREFIXO	          ,; // 04
		(cAliasF1)->E2_NUM		          ,; // 05
		(cAliasF1)->E2_TIPO		          ,; // 06
		(cAliasF1)->E2_PARCELA	          ,; // 07
		(cAliasF1)->E2_NATUREZ	          ,; // 08
		(cAliasF1)->E2_FORNECE	          ,; // 09
		(cAliasF1)->E2_EMISSAO	          ,; // 10
		(cAliasF1)->E2_VENCTO	          ,; // 11
		(cAliasF1)->E2_VALOR	          ,; // 12
		(cAliasF1)->E2_HIST		          ,; // 13
		(cAliasF1)->R_E_C_N_O_	          ,; // 14
		(cAliasF1)->E2_MOEDA	          ,; // 15
		(cAliasF1)->STATUS_INT	          ,; // 16
		(cAliasF1)->OPERACAO_INT          ,; // 17
		(cAliasF1)->STATUS_PRC 	          ,; // 18
		(cAliasF1)->E2_PORTADO	          ,; // 19 //22/01/2019 ch: 046609 William Costa - 19
		(cAliasF1)->E2_AGENCIA	          ,; // 20 //22/01/2019 ch: 046609 William Costa - 20
		(cAliasF1)->E2_CONTA	          ,; // 21 //22/01/2019 ch: 046609 William Costa - 21
		(cAliasF1)->E2_CREDIT		      ,; // 22 // Chamado n. 051689 || OS 053035 || CONTROLADORIA || MONIK_MACEDO || 8956 || LOTES FINANCEIRO - FWNM - 25/09/2019
		""					              ,; // 23
		Alltrim( (cAliasF1)->E2_ORIVENC ) ,; // 24
		(cAliasF1)->E2_LOJA     		  ,; // 25
		(cAliasF1)->TABEGENE     		  ,; // 26
		cMail } ) 						 	 // 27  // Chamado n. 054307 || OS 055702 || SUPRIMENTOS || RACHEL || 1621063514 || WOKFLOW SOL.PA - fwnm - 18/12/2019
		
		(cAliasF1)->(DbSkip())
	EndDo
	
	If EMPTY(aDados)
		ConOut( "Sem registros a serem processados! " + time() )
	Endif

	For x:=1 to Len(aDados)
		
		cFilMOV  := (aDados[x][3])
		nRecMOV  := (aDados[x][14])
		cRecMov  := StrZero((aDados[x][14]),10)
		_cFilOK  := cFilAnt  // guardo a filial logada  - Fernando Sigoli 29/06/2018
		cFilAnt	 := cFilMOV	 //altero a varivel para receber a filial do titulo - Fernando Sigoli 29/06/2018
		
		// Ricardo Lima - 11/07/18
		//if cOpc = 'M'
		//	PREPARE ENVIRONMENT EMPRESA '01' FILIAL cFilAnt
		//EndIf
		
		// Chamado n. 051689 || OS 053035 || CONTROLADORIA || MONIK_MACEDO || 8956 || LOTES FINANCEIRO - fwnm - 12/09/2019
		// ORDER 1 = A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
		cCta := aDados[x,22]
		If Empty(cCta)
			cCta := Posicione("SA6",1,FWxFilial("SA6")+PadR(aDados[x,19],TamSX3("A6_COD")[1])+PadR(aDados[x,20],TamSX3("A6_AGENCIA")[1])+PadR(aDados[x,21],TamSX3("A6_NUMCON")[1]),"A6_CONTA")
		EndIf

		// Chamado n. 051689 || OS 053035 || CONTROLADORIA || MONIK_MACEDO || 8956 || LOTES FINANCEIRO - fwnm - 26/09/2019
		If Empty(cCta) .And. IsInCallStack("u_ADFIN054P") .And. ! lAutoJob
			aDados[x,19] := cBco
			aDados[x,20] := cAgen
			aDados[x,21] := cConta
			aDados[x,22] := cCredit
			cCta := cCredit

		ElseIf Empty(cCta) .And. lAutoJob //Everson - 09/06/2020. Chamado 058823.

			//
			//TcSetConn(_nTcConn1)
			Conout( DToC(Date()) + " " + Time() + " ADFIN053P - cCta - A6_CONTA em brancom para a busca " + FWxFilial("SA6")+PadR(aDados[x,19],TamSX3("A6_COD")[1])+PadR(aDados[x,20],TamSX3("A6_AGENCIA")[1])+PadR(aDados[x,21],TamSX3("A6_NUMCON")[1]) )
			cMensagem := "<!DOCTYPE html>"
			cMensagem += "<html>"
			cMensagem += "<head>"
			cMensagem += "<meta charset='UTF-8'/>"
			cMensagem += "<title>Complemento de PA SAG</title>"
			cMensagem += "</head>"
			cMensagem += "<body>"
			cMensagem += "<h2>Erro ao processar complemento de PA SAG <strong>via Job</strong></h2>"
			cMensagem += "<p>Não foi possível localizar número de conta contábil do banco, para título abaixo.</p>"
			cMensagem += "<p>Filial: "  + FWxFilial("SA6") + "</p>"
			cMensagem += "<p>Código: "  + PadR(aDados[x,19],TamSX3("A6_COD")[1]) + "</p>"
			cMensagem += "<p>Agência: " + PadR(aDados[x,20],TamSX3("A6_AGENCIA")[1]) + "</p>"
			cMensagem += "<p>Conta: "   + PadR(aDados[x,21],TamSX3("A6_NUMCON")[1]) + "</p>"
			cMensagem += "<br>"
			cMensagem += "<p>Prefixo: "   + cValToChar(aDados[x][4]) + " </p>"
			cMensagem += "<p>Número: "    + cValToChar(aDados[x][5]) + " </p>"
			cMensagem += "<p>Tipo: "      + cValToChar(aDados[x][6]) + " </p>"
			cMensagem += "<p>Parcela: "   + cValToChar(aDados[x][7]) + " </p>"
			cMensagem += "<p>Natureza: "  + cValToChar(aDados[x][8]) + " </p>"
			cMensagem += "<p>Fornecedor: "+ cValToChar(aDados[x][9]) + " </p>"
			cMensagem += "<p>Loja: "      + cValToChar(aDados[x][25]) + " </p>"
			cMensagem += "<p>Nome: "      + Posicione("SA2",1,FWxFilial("SA2") + cValToChar(aDados[x][9]) + cValToChar(aDados[x][25]) ,"A2_NOME") + " </p>"
			cMensagem += "</body>"
			cMensagem += "</html>"
			
			//
			u_F050EnvWF( "Complemento de PA SAG - [ERRO]" , cMensagem , cDestPaSag ,"")
			cMensagem := ""
			//TcSetConn(_nTcConn2)
			Loop

		EndIf
		//
		
		// Chamado n. 057682 || OS 059176 || FINANCAS || ANA || 8384 || LP - PAS - FWNM - 04/05/2020
		If IsInCallStack("u_ADFIN054P") .and. !lAutoJob
			dEmiss  := dVencto
		Else
			dVencto := DataValida( (aDados[x][11]) ,.T.)
			dEmiss  := dVencto
		EndIf
		//
		
		aCampos:={}
		
		aAdd(aCampos,{ "E2_PREFIXO" , (aDados[x][4]	)	 			, NIL })
		aAdd(aCampos,{ "E2_NUM"     , (aDados[x][5]	)				, NIL })
		aAdd(aCampos,{ "E2_TIPO"    , (aDados[x][6]	)	   			, NIL })
		aAdd(aCampos,{ "E2_PARCELA" , (aDados[x][7]	)	 			, NIL })
		aAdd(aCampos,{ "E2_NATUREZ" , (aDados[x][8]	)  				, NIL })
		aAdd(aCampos,{ "E2_FORNECE" , (aDados[x][9] ) 				, NIL })
		aAdd(aCampos,{ "E2_LOJA"    , (aDados[x][25]) 				, NIL })
		
		/*
		//INICIO Chamado n.053212 - Possibilita inclusão de PA com outras datas de vencimento - Abel Babini - 19/11/2019
		IF Alltrim(aDados[x][26]) = "SC7"
			aAdd(aCampos,{ "E2_EMISSAO" , (aDados[x][10])				, NIL }) // Ricardo Lima - 16/04/18
		ELSE
			aAdd(aCampos,{ "E2_EMISSAO" , (aDados[x][11])				, NIL }) // Ricardo Lima - 16/04/18
		ENDIF
		//FIM Chamado n.053212 - Possibilita inclusão de PA com outras datas de vencimento - Abel Babini - 19/11/2019
		
		aAdd(aCampos,{ "E2_VENCTO"  , (aDados[x][11])				, NIL })
		aAdd(aCampos,{ "E2_VENCREA" , DataValida( (aDados[x][11]) ,.T.)				, NIL })
		*/

		// Chamado n. 057682 || OS 059176 || FINANCAS || ANA || 8384 || LP - PAS - FWNM - 04/05/2020
		aAdd(aCampos,{ "E2_EMISSAO" , dEmiss				, NIL }) 
		aAdd(aCampos,{ "E2_VENCTO"  , dVencto				, NIL })
		aAdd(aCampos,{ "E2_VENCREA" , dVencto				, NIL })
		//

		// INICIO | ABEL BABINI | 13/09/2019 | 043195 || OS 044312 || FINANCAS || EDUARDO || 8352 || PAG. ANTECIPADO
		if Alltrim(aDados[x][26]) == "SC7"
			aAdd(aCampos,{"E2_VALOR"  , (aDados[x][12])				, NIL })
			IF Val(aDados[x][15]) <> 1
				aAdd(aCampos,{"E2_MOEDA"  , Val(aDados[x][15])				, NIL })
				dbSelectArea("SC7")
				SC7->(dbSetOrder(1))
				nTxPedC7 := GetAdvFVal("SC7","C7_XTXMOED",xFilial("SC7")+Alltrim(aDados[x][5]),1,"")
				nVlr := Round(xMoeda(aDados[x][12],Val(aDados[x][15]),1,aDados[x][11],2,nTxPedC7),2)
				aAdd(aCampos,{"E2_TXMOEDA", nTxPedC7	, NIL })
				aAdd(aCampos,{"E2_VLCRUZ" , nVlr			, NIL })
			ENDIF
		else
			//Ticket 10979   - Leonardo P. Monteiro - 24/03/2021 - Tratativa do error.log na linha 381 quando o campo E2_MOEDA vem com valores preenchidos informando o tipo da moeda. Anteriormente esse campo vinha como 'nil'.
			//aAdd(aCampos,{ "E2_VALOR"   , Iif(aDados[x][15] == Nil .Or. Empty(Alltrim(aDados[x][15])) .Or. aDados[x][15] == 1, aDados[x][12], aDados[x][12]*aDados[x][15]), NIL })
			IF Type("aDados[x][15]") == "U" .Or. Empty(Alltrim(aDados[x][15])) .Or. aDados[x][15] == "1"
				aAdd(aCampos,{ "E2_VALOR"   , aDados[x][12], NIL })
			ELSE
				nTxPedC7 	:= 0
				nVlrCvt		:= Round(xMoeda(aDados[x][12],Val(aDados[x][15]),1,aDados[x][11],2,nTxPedC7),2)
				aAdd(aCampos,{"E2_TXMOEDA", nTxPedC7	, NIL })
				aAdd(aCampos,{"E2_VALOR"   , nVlrCvt	, NIL })
			endif
			
		endif
		aAdd(aCampos,{ "E2_HIST"	, (aDados[x][13])		, NIL })
		aAdd(aCampos,{ "E2_XRECORI"	, cRecMov					, NIL })
		aAdd(aCampos,{ "E2_CCSOLIC"	, "5000"			   	, NIL })
		aAdd(aCampos,{ "E2_CREDIT"  , cCta			   		, NIL }) // Chamado n. 051689 || OS 053035 || CONTROLADORIA || MONIK_MACEDO || 8956 || LOTES FINANCEIRO - fwnm - 12/09/2019
		aAdd(aCampos,{ "AUTBANCO"   , (aDados[x][19]) , NIL })
		aAdd(aCampos,{ "AUTAGENCIA" , (aDados[x][20]) , NIL })
		aAdd(aCampos,{ "E2_FILORIG" , (aDados[x][3] ) , NIL })
		aAdd(aCampos,{ "AUTCONTA"   , (aDados[x][21]) , NIL })
		
		lMsErroAuto:=.F.
		
		//TcSetConn(_nTcConn1)
		
		//Begin Transaction
		//DDATABASE := aDados[x][11]
		dDataBase := dVencto // Chamado n. 057682 || OS 059176 || FINANCAS || ANA || 8384 || LP - PAS - FWNM - 06/05/2020
		
		dbSelectArea("SE2")
		dbSetOrder(6)  // E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, R_E_C_N_O_, D_E_L_E_T_
		IF dbSeek( (aDados[x][3]) + (aDados[x][9]) + (aDados[x][25]) + (aDados[x][4]) + (aDados[x][5]) + (aDados[x][7]) + (aDados[x][6]) )
			// INICIO | ABEL BABINI | 13/09/2019 | 043195 || OS 044312 || FINANCAS || EDUARDO || 8352 || PAG. ANTECIPADO
			if Alltrim(aDados[x][26]) = "SC7"
				AADD(aUpdates, "UPDATE "+RetSqlName("ZFQ")+" SET ZFQ_MSEXP='" +DTOS(DDATABASE) + "' ,ZFQ_STSINT='E', ZFQ_MSGINT='Titulo já Existe no Protheus' WHERE R_E_C_N_O_="+AllTrim(Str(nRecMOV))+" ")
			else
				// FIM | ABEL BABINI | 13/09/2019 | 043195 || OS 044312 || FINANCAS || EDUARDO || 8352 || PAG. ANTECIPADO
				AADD(aUpdates, "UPDATE SGFIN010 SET E2_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='Titulo já Existe no Protheus' WHERE R_E_C_N_O_="+AllTrim(Str(nRecMOV))+" ")
			endif
		ELSE
			
			dbSelectArea("SE2")
			MSExecAuto({|x,y,z| FINA050(x,y,z)}, aCampos, 3 )
			
			If lMsErroAuto
				
				//DisarmTransaction()
				
				If !lAutoJob
					MostraErro()
				EndIf
				cErro := MostraErro()
				
				//TcSetConn(_nTcConn2)
				ConOut( "ERRO: " + cErro )
				
				// INICIO | ABEL BABINI | 13/09/2019 | 043195 || OS 044312 || FINANCAS || EDUARDO || 8352 || PAG. ANTECIPADO
				if Alltrim(aDados[x][26]) = "SC7"
					AADD(aUpdates, "UPDATE "+RetSqlName("ZFQ")+" SET ZFQ_MSEXP='" +DTOS(DDATABASE) + "' ,ZFQ_STSINT='E', ZFQ_MSGINT='"+cErro+ "' WHERE R_E_C_N_O_="+AllTrim(Str(nRecMOV))+" ")
				else
					// FIM | ABEL BABINI | 13/09/2019 | 043195 || OS 044312 || FINANCAS || EDUARDO || 8352 || PAG. ANTECIPADO
					AADD(aUpdates, "UPDATE SGFIN010 SET E2_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+cErro+ "' WHERE R_E_C_N_O_="+AllTrim(Str(nRecMOV))+" ")
				endif
				
			Else
				// Chamado n. 051689 || OS 053035 || CONTROLADORIA || MONIK_MACEDO || 8956 || LOTES FINANCEIRO - fwnm - 12/09/2019
				dbSelectArea("SE2")
				dbSetOrder(6)  // E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, R_E_C_N_O_, D_E_L_E_T_
				dbSeek( (aDados[x][3]) + (aDados[x][9]) + (aDados[x][25]) + (aDados[x][4]) + (aDados[x][5]) + (aDados[x][7]) + (aDados[x][6]) )
				//dbSelectArea("SE2")
				//dbOrderNickName("RECORI")
				//dbSeek(cFilMov+cRecMov)
				//
				If !Eof()
					//TcSetConn(_nTcConn2)
					
					ConOut( "Inclusão PA Numero = '" + (aDados[x][5]) + "' / '" + (aDados[x][4]) + "',  Fornecedor = '" + aDados[x][9] + "' " )
					ConOut( "e xRecOrigem = '" + cRecMov + "' " )
					ConOut( "SUCESSO!" )
					
					// 26/09/19 | FWNM              | Campo E2_CREDIT gravado errado afetando LP 513 (PA)    | 051689
					If !lAutoJob
						msgInfo("SUCESSO! Inclusão PA Numero = '" + (aDados[x][5]) + "' / '" + (aDados[x][4]) + "',  Fornecedor = '" + aDados[x][9] + "' ")
					EndIf
					//
					
					// INICIO | ABEL BABINI | 13/09/2019 | 043195 || OS 044312 || FINANCAS || EDUARDO || 8352 || PAG. ANTECIPADO
					if Alltrim(aDados[x][26]) = "SC7"
						AADD(aUpdates, "UPDATE "+RetSqlName("ZFQ")+" SET ZFQ_MSEXP='" +DTOS(DDATABASE) + "' ,ZFQ_STSINT='S', ZFQ_MSGINT='', ZFQ_STSLIB=' ' , ZFQ_OPEINT = 'A'  WHERE R_E_C_N_O_="+AllTrim(Str(nRecMOV))+" ")
					else
						// FIM | ABEL BABINI | 13/09/2019 | 043195 || OS 044312 || FINANCAS || EDUARDO || 8352 || PAG. ANTECIPADO
						AADD(aUpdates, "UPDATE SGFIN010 SET E2_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='S' ,MENSAGEM_INT='', STATUS_LIB=' ' , OPERACAO_INT = 'A' WHERE R_E_C_N_O_="+AllTrim(Str(nRecMOV))+" ")
					endif
					
					If !Empty( aDados[x][24] )
						dbSelectArea("ZC7")
						dbSetOrder(2) // ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_TIPO
						IF dbSeek( FWxFilial("ZC7") + aDados[x][9] + aDados[x][25] + aDados[x][4] + aDados[x][5] + aDados[x][7] + aDados[x][6]  )
							RecLock("ZC7",.F.)
							ZC7->ZC7_ODTVEN := STOD( aDados[x][24] )
							ZC7->(MsUnLock())
						EndIf
					Endif
				Else
					//TcSetConn(_nTcConn2)
					
					ConOut( "ERRO NÃO IDENTIFICADO!" )
					
					// INICIO | ABEL BABINI | 13/09/2019 | 043195 || OS 044312 || FINANCAS || EDUARDO || 8352 || PAG. ANTECIPADO
					if Alltrim(aDados[x][26]) = "SC7"
						AADD(aUpdates, "UPDATE "+RetSqlName("ZFQ")+" SET ZFQ_MSEXP='" +DTOS(DDATABASE) + "' ,ZFQ_STSINT='E', ZFQ_MSGINT='ERRO NAO IDENTIFICADO!', ZFQ_STSLIB='3' WHERE R_E_C_N_O_="+AllTrim(Str(nRecMOV))+" ")
					else
						// FIM | ABEL BABINI | 13/09/2019 | 043195 || OS 044312 || FINANCAS || EDUARDO || 8352 || PAG. ANTECIPADO
						AADD(aUpdates, "UPDATE SGFIN010 SET E2_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='ERRO NAO IDENTIFICADO!', STATUS_LIB='3' WHERE R_E_C_N_O_="+AllTrim(Str(nRecMOV))+" ")
					endif
				EndIf
				
				// Chamado n. 054406 || OS 055799 || SUPRIMENTOS || EVANDRA || 8362 || EMAIL P.A - FWNM - 03/01/2020
				// Envio email
				If !Empty(aDados[x,27]) 
					EnviaMail(aDados[x,27], aDados[x,4], aDados[x,5], aDados[x,7], aDados[x,6], aDados[x,9], aDados[x,25])
				EndIf
				//
				
			EndIF
		EndIf
		DDATABASE := DATE()
		//End Transaction
		
		cFilAnt	 := _cFilOK //restauro a filial corrente - Fernando Sigoli 29/06/2018
		
		if lAutoJob
			RpcClearEnv()
		Endif
		//TcSetConn(_nTcConn2)
	Next x
	
	If Len(aUpdates) > 0
		//TcSetConn(_nTcConn2)
		For nNum:=1 To Len(aUpdates)
			TcSqlExec(aUpdates[nNum])
		Next nNum
	EndIf
	
	ConOut( "Fim da integração de PA do SAG com o Protheus " + time() )
	
	// Ricardo Lima - 26/04/18
	if lAutoJob
		ConOut( "Inicio Monitor de PA do SAG com o Protheus " + time() )
		cQry := " SELECT * FROM SGFIN010 WHERE E2_TIPO = 'PA' AND STATUS_INT = 'S' AND STATUS_LIB = '1' "
		DbUseArea(.t., "TOPCONN", TcGenQry(,, cQry), cAliasPA, .F., .T.)
		
		TcSetField( cAliasPA, "E2_EMISSAO", "D", 8, 0 )
		TcSetField( cAliasPA, "E2_VENCTO", "D" , 8, 0 )
		
		While !(cAliasPA)->(Eof())
			//TcSetConn(_nTcConn1)
			cNomFor := GetAdvFVal( "SA2", "A2_NOME", xFilial("SA2") + (cAliasPA)->E2_FORNECE + (cAliasPA)->E2_LOJA , 1, "" )
			//TcSetConn(_nTcConn2)
			AADD( aDadPA , { (cAliasPA)->E2_PREFIXO , (cAliasPA)->E2_NUM , (cAliasPA)->E2_PARCELA , (cAliasPA)->E2_FORNECE , (cAliasPA)->E2_LOJA , cNomFor , (cAliasPA)->E2_VALOR , (cAliasPA)->E2_PRODUTO } )
			(cAliasPA)->(DbSkip())
		EndDo
		IF LEN(aDadPA) > 0
			cMensagem := "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'> "
			cMensagem += "<html xmlns='http://www.w3.org/1999/xhtml' xmlns:v='urn:schemas-microsoft-com:vml' xmlns:o='urn:schemas-microsoft-com:office:office'>"
			cMensagem += "<head>"
			cMensagem += "<meta http-equiv='Content-Language' content='pt-br' />"
			cMensagem += "<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />"
			cMensagem += "<title>Central de Aprovação</title>"
			cMensagem += "<style type='text/css'>"
			cMensagem += ".style1 {"
			cMensagem += "				font-family: 'Century Gothic';"
			cMensagem += "				text-align: center;"
			cMensagem += "				text-decoration: underline;"
			cMensagem += "				font-size: x-large;"
			cMensagem += "}"
			cMensagem += ".style2 {"
			cMensagem += "				text-align: left;"
			cMensagem += "				font-family: 'Century Gothic';"
			cMensagem += "}"
			cMensagem += "td"
			cMensagem += "	{border-style: none;"
			cMensagem += "					border-color: inherit;"
			cMensagem += "				border-width: medium;"
			cMensagem += "				padding-top:1px;"
			cMensagem += "					padding-right:1px;"
			cMensagem += "					padding-left:1px;"
			cMensagem += "					color:gray;"
			cMensagem += "					font-size:9.0pt;"
			cMensagem += "					font-weight:400;"
			cMensagem += "					font-style:normal;"
			cMensagem += "					text-decoration:none;"
			cMensagem += "					font-family:'Century Gothic', sans-serif;"
			cMensagem += "					text-align:general;"
			cMensagem += "					vertical-align:middle;"
			cMensagem += "					white-space:nowrap;"
			cMensagem += "	}"
			cMensagem += ".style3 {"
			cMensagem += "				border-collapse: collapse;"
			cMensagem += "				margin-bottom: 0px;"
			cMensagem += "}"
			cMensagem += ".style4 {"
			cMensagem += "				font-family: 'Century Gothic';"
			cMensagem += "}"
			cMensagem += "</style>"
			cMensagem += "</head>"
			cMensagem += "<body>"
			cMensagem += "<p><img alt='ADORO' src='http://www.adoro.com.br/images/logo-adoro.png' style='float: left' /></p>"
			cMensagem += "<p class='style1'><strong>Central de Integração</strong></p>"
			cMensagem += "<p class='style2'>Segue pendências&nbsp; de PA do SAG para Complemento.</p>"
			cMensagem += "<table border='0' cellpadding='0' cellspacing='0' width='1305' style='width: 50%' class='style3'>"
			cMensagem += "				<colgroup>"
			cMensagem += "								<col width='195' style='mso-width-source: userset; mso-width-alt: 7131; width: 146pt' />"
			cMensagem += "								<col width='139' style='mso-width-source: userset; mso-width-alt: 5083; width: 104pt' />"
			cMensagem += "								<col width='186' style='mso-width-source: userset; mso-width-alt: 6802; width: 140pt' />"
			cMensagem += "								<col width='133' style='mso-width-source: userset; mso-width-alt: 4864; width: 100pt' />"
			cMensagem += "								<col width='111' style='mso-width-source: userset; mso-width-alt: 4059; width: 83pt' />"
			cMensagem += "								<col width='236' style='mso-width-source: userset; mso-width-alt: 8630; width: 177pt' />"
			cMensagem += "								<col width='305' style='mso-width-source: userset; mso-width-alt: 11154; width: 229pt' />"
			cMensagem += "				</colgroup>"
			cMensagem += "				<tr height='24' style='mso-height-source: userset; height: 18.0pt'>"
			cMensagem += "								<td height='24' class='xl67' width='195'>Prefixo</td>"
			cMensagem += "								<td class='xl67' width='139'>Numero Titulo</td>"
			cMensagem += "								<td class='xl67' width='186'>Parcela</td>"
			cMensagem += "								<td class='xl67' width='133'>Fornecedor</td>"
			cMensagem += "								<td class='xl67' width='111'>Loja</td>"
			cMensagem += "								<td class='xl67' width='236'>Nome</td>"
			cMensagem += "								<td class='xl67' width='305'>Valor</td>"
			cMensagem += "								<td class='xl67' width='305'>Produto</td>"
			cMensagem += "				</tr>"
			FOR PA:=1 TO LEN(aDadPA)
				cMensagem += "		<tr height='24' style='mso-height-source: userset; height: 18.0pt'>"
				cMensagem += "						<td>"+aDadPA[PA][1]+"</td>"
				cMensagem += "						<td>"+aDadPA[PA][2]+"</td>"
				cMensagem += "						<td>"+aDadPA[PA][3]+"</td>"
				cMensagem += "						<td>"+aDadPA[PA][4]+"</td>"
				cMensagem += "						<td>"+aDadPA[PA][5]+"</td>"
				cMensagem += "						<td>"+aDadPA[PA][6]+"</td>"
				cMensagem += "						<td>"+Transform( aDadPA[PA][7] , "@E 9,999,999,999.99" ) +"</td>"
				cMensagem += "						<td>"+aDadPA[PA][8]+"</td>"
				cMensagem += "		</tr>"
			NEXT
			cMensagem += "</table>"
			cMensagem += "<p class='style4'>Envio Automático - AD&#39;ORO ( Central de Integração )</p>"
			cMensagem += "</body>"
			cMensagem += "</html>"
			
			u_F050EnvWF( "Complemento de PA SAG" , cMensagem , cDestPaSag , '')
		EndIF
		ConOut( "Fim Monitor de PA do SAG com o Protheus " + time() )
	Endif
	ConOut( "Inicio - Consulta Exclusão de PA do SAG com o Protheus " + time() )
	//TcSetConn(_nTcConn2)
	
	If lAutoJob

		cQry := " SELECT * FROM SGFIN010 (NOLOCK) WHERE OPERACAO_INT = 'E' "
		DbUseArea(.t., "TOPCONN", TcGenQry(,, cQry), cAliasEX, .F., .T.)
		
		TcSetField( cAliasEX, "E2_EMISSAO", "D", 8, 0 )
		
		While !(cAliasEX)->(Eof())
			
			AADD( aDadEX , { (cAliasEX)->E2_FILIAL , (cAliasEX)->E2_PREFIXO , (cAliasEX)->E2_NUM , (cAliasEX)->E2_PARCELA , (cAliasEX)->E2_FORNECE , (cAliasEX)->E2_LOJA , (cAliasEX)->E2_EMISSAO , (cAliasEX)->R_E_C_N_O_ } )
			
			(cAliasEX)->(DbSkip())
		EndDo
		
		//TcSetConn(_nTcConn1)
		For x:=1 to len(aDadEX)
			
			cFilMOV := aDadEX[x][1]
			nRecMOV := aDadEX[x][8]
			cRecMov := StrZero(aDadEX[x][8],10)
			
			dbSelectArea("SE2")
			dbOrderNickName("RECORI")
			if dbSeek(cFilMov+Padr(cRecMov,TamSX3("E2_XRECORI")[1]) )
				
				DDATABASE := SE2->E2_EMISSAO // aDadEX[x][7]
				
				IF SE2->E2_VENCREA < GETMV("MV_DATAFIN") //chamado 046609 William Costa 25/01/2019
					
					LOOP //Pula Titulos que estão tentando ser excluidos que a DataFin já foi encerrada
					
				ENDIF
				
				aCampos:={}
				
				aAdd(aCampos,{ "E2_PREFIXO" , SE2->E2_PREFIXO 	, NIL })
				aAdd(aCampos,{ "E2_NUM"     , SE2->E2_NUM		, NIL })
				aAdd(aCampos,{ "E2_PARCELA" , SE2->E2_PARCELA 	, NIL })
				aAdd(aCampos,{ "E2_FORNECE" , SE2->E2_FORNECE 	, NIL })
				aAdd(aCampos,{ "E2_LOJA"    , SE2->E2_LOJA		, NIL })
				
				//TcSetConn(_nTcConn1)
				
				lMsErroAuto:=.F.
				
				Begin Transaction
				MSExecAuto( { |x,y,z| FINA050(x,y,z)}, aCampos,, 5 )
				
				If lMsErroAuto
					cErro := MostraErro()
					ConOut( "ERRO: " + cErro )
					DisarmTransaction()
				Else
					AADD(EUpdates, "DELETE SGFIN010 WHERE R_E_C_N_O_="+AllTrim(Str(nRecMOV))+" ")
				EndIf
				End Transaction
			Endif
		Next
		
		If Len(EUpdates) > 0
			//TcSetConn(_nTcConn2)
			For nNum:=1 To Len(EUpdates)
				TcSqlExec(EUpdates[nNum])
			Next nNum
		EndIf
		ConOut( "Fim - Consulta Exclusão de PA do SAG com o Protheus " + time() )
		
		RestArea(_aArea)
		
		if lAutoJob
		
			RpcClearEnv()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//³Destrava a rotina para o usuário	    ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			UnLockByName("ADFIN053P")
		
		Endif
	
	EndIf
	
	DDATABASE := dBackupDataBase //chamado 046609 William Costa 25/01/2019

Return

/*/{Protheus.doc} Static Function EnviaMail
Envia email para solicitante do PA
@type  Static Function
@author FWNM
@since 18/12/2019
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
@Chamado 054307 || OS 055702 || SUPRIMENTOS || RACHEL || 1621063514 || WOKFLOW SOL.PA
/*/
Static Function EnviaMail(cMail, cPrefixo, cNum, cParcela, cTipo, cFor, cLoja)

	Local aArea		:= GetArea()
	Local aAreaSE2  := SE2->( GetArea() )
	Local cAssunto	:= "Solicitação PA"
	Local cMensagem	:= ""
	Local cDescri   := cAssunto
	
	Local lOk           := .T.
	Local cBody         := cMensagem
	Local cErrorMsg     := ""
	Local aFiles        := {}
	Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
	Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
	Local cFrom         := AllTrim(GetMv("MV_RELFROM"))
	Local cTo           := cMail
	Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)
	Local lAutOk        := .F.
	Local cAtach        := ""
	Local cSubject      := ""
	
	
	SE2->( dbSetOrder(1) ) // E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_N_O_, D_E_L_E_T_
	If SE2->( dbSeek(FWxFilial("SE2")+cPrefixo+cNum+cParcela+cTipo+cFor+cLoja) )
		
		cMensagem += '<html>'
		cMensagem += '<body>'
		cMensagem += '<p style="color:red">'+cValToChar(cDescri)+'</p>'
		cMensagem += '<hr>'
		cMensagem += '<table border="1">'
		cMensagem += '<tr style="background-color: black;color:white">'
		cMensagem += '<td>Filial</td>'
		cMensagem += '<td>Prefixo</td>'
		cMensagem += '<td>Numero</td>'
		cMensagem += '<td>Parcela</td>'
		cMensagem += '<td>Tipo</td>'
		cMensagem += '<td>Fornece</td>'
		cMensagem += '<td>Loja</td>'
		cMensagem += '<td>Nome</td>'
		cMensagem += '<td>Natureza</td>'
		cMensagem += '<td>Saldo</td>'
		cMensagem += '<td>Vencrea</td>'
		cMensagem += '<td>Usuário</td>'
		cMensagem += '<td>Data/Hora</td>'
		cMensagem += '</tr>'
		
		cMensagem += '<tr>'
		cMensagem += '<td>' + cValToChar(SE2->E2_FILIAL)    + '</td>'
		cMensagem += '<td>' + cValToChar(SE2->E2_PREFIXO)       + '</td>'
		cMensagem += '<td>' + cValToChar(SE2->E2_NUM)   + '</td>'
		cMensagem += '<td>' + cValToChar(SE2->E2_PARCELA)   + '</td>'
		cMensagem += '<td>' + cValToChar(SE2->E2_TIPO)   + '</td>'
		cMensagem += '<td>' + cValToChar(SE2->E2_FORNECE)   + '</td>'
		cMensagem += '<td>' + cValToChar(SE2->E2_LOJA)    + '</td>'
		cMensagem += '<td>' + cValToChar(SE2->E2_NOMFOR)    + '</td>'
		cMensagem += '<td>' + cValToChar(SE2->E2_NATUREZ)    + '</td>'
		cMensagem += '<td>' + cValToChar(Transform(SE2->E2_SALDO,"@E 999,999,999,999.99"))   + '</td>'
		cMensagem += '<td>' + cValToChar(SE2->E2_VENCREA)    + '</td>'
		cMensagem += '<td>' + cValToChar(cUserName)           + '</td>'
		cMensagem += '<td>' + cValToChar(DtoC(msDate())+ " " + Time())           + '</td>'
		cMensagem += '</tr>'
		
		cMensagem += '</table>'
		cMensagem += '</body>'
		cMensagem += '</html>'
		
	EndIf
	
	//Assunto do e-mail.
	cSubject := cAssunto
	cBody    := cMensagem
	
	//Conecta ao servidor SMTP.
	Connect Smtp Server cServer Account cAccount  Password cPassword Result lOk
	
	//
	If !lAutOk
		If ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)
		Else
			lAutOk := .T.
		EndIf
	EndIf
	//
	
	If lOk .And. lAutOk
		
		//Envia o e-mail.
		Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk
		
		//Tratamento de erro no envio do e-mail.
		If !lOk
			Get Mail Error cErrorMsg
			ConOut("3 - " + cErrorMsg)
		Else
			Aviso(	"ADFIN053P-03",;
			"Email enviado com sucesso!"  + chr(13) + chr(10)+;
			"Emails: "  + Left(cMail,66) + chr(13) + chr(10) +;
			"" + Subs(cMail,67,Len(cMail)),;
			{ "&OK" },3,;
			"Solicitação PA" )
		EndIf
		
	Else
		Get Mail Error cErrorMsg
		ConOut("4 - " + cErrorMsg)
		
	EndIf
	
	If lOk
		Disconnect Smtp Server
	EndIf
	
	RestArea( aArea )
	RestArea( aAreaSE2 )

Return
