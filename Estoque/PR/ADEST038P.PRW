#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE  ENTER 		Chr(13)+Chr(10)

// Variaveis estaticas
Static cRotina  := "[ ADORO ] - ADEST038P "
Static cTitulo  := "[ ADORO ] - Subprodutos - Transforma estruturas e apontamentos - Custo Ceres ADORO "

Static cProdPen := "" // Codigo produto Penas
Static cProdDej := "" // Codigo produto Dejetos
Static cProdCMS := "" // Codigo produto CMS
Static cCCProdZ := "" // Centro Custo produto MOD
Static cSD3TM	 := "" // Tipo Movimentacao producao AllTrim(GetMv("MV_XTMPRD",, "010"))

Static cEmpADORO  := "02"  // permite utilizar rotinas apenas na empresa ceres

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADEST038P ºAutor  ³Fernando Macieira   º Data ³ 26/11/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina p/ efetuar transformacoes dos subprodutos           º±±
±±ºDesc.     ³ utilizados no calculo do custo medio do ADORO              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ADORO                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADEST038P()

	Local nArea    := 0
	Local oProcess
	Local bProcess := { |oSelf| RunSubProdutos(oSelf, lAuto) }
	Local cDescri  := "Esta rotina modificará as estruturas e os apontamentos dos subprodutos da Ceres ADORO, utilizando os valores calculados e armazenados no cadastro de períodos e produtos, tabelas ZCS/ZCR..."  + ENTER + ENTER +;
					   " Atenção: O status do cadastro precisa estar como C = Calculado!" + ENTER + ENTER
	
	// Pergunte
	Private cPerg  := "ADEST038P"
	Private cDtRef := ""
	
	Private cFilADORO := ""

	// Define lAuto
	nArea := Select()
	If nArea > 0
		lAuto := .f.
	Else
		lAuto := .t.
	EndIf
	
	// Inicializo ambiente
	If lAuto
		rpcClearEnv()
		rpcSetType(3)
		
		If !rpcSetEnv(cEmpADORO, "01",,,,,{"SM0"})
			ConOut( cRotina + " Não foi possível inicializar o ambiente, empresa " + cEmpADORO + ", filial 01" )
			Return
		EndIf
	EndIf

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina p/ efetuar transformacoes dos subprodutos utilizados no calculo do custo medio do ADORO')
	
	// Carrego variaveis staticas com GETMV
	
	cEmpADORO  := GetMV("MV_#EMPSIG",,"02")  // permite utilizar rotinas apenas na empresa ceres
	cFilADORO  := GetMV("MV_#SIGFIL",,"01")  // Filial que possui os subprodutos que receberao as transformações
	
	cProdPen := GetMV("MV_#CODPEN",,"302213") // Codigo produto Penas
	cProdDej := GetMV("MV_#CODDEJ",,"313165") // Codigo produto Dejetos
	cProdCMS := GetMV("MV_#CODCMS",,"199753") // Codigo produto CMS
	cCCProdZ := GetMV("MV_#CCPRDZ",,"5215") // Centro Custo produto MOD
	
	cSD3TM	 := AllTrim(GetMv("MV_XTMPRD",, "010")) // Tipo Movimentacao producao subprodutos
	
	// fim variaveis staticas
	
	// Consiste se o usuário está na empresa correta para utilizar esta rotina
	If cEmpADORO <> cEmpAnt
		If lAuto
			ConOut(cRotina + "MV_#EMPSIG - Empresa não autorizada para utilizar esta rotina!")
			ApMsgStop( "MV_#EMPSIG - Empresa não autorizada para utilizar esta rotina!", "Atenção" )
		Else
			Aviso("MV_#EMPSIG", "Empresa não autorizada para utilizar esta rotina!", {"OK"}, 3)
		EndIf
		
		Return
	EndIf
	
	// Consiste se o usuário está na filial correta para efetuar os calculos dos subprodutos
	If cFilADORO <> cFilAnt
		If lAuto
			ConOut(cRotina + "MV_#SIGFIL - Filial não possui subprodutos para efetuar as transformações e cálculos!")
			ApMsgStop( "MV_#SIGFIL - Filial não possui subprodutos para efetuar as transformações e cálculos!", "Atenção" )
		Else
			Aviso("MV_#EMPSIG", "MV_#SIGFIL - Filial não possui subprodutos para efetuar as transformações e cálculos!", {"OK"}, 3)
		EndIf
		
		Return
	EndIf
	
	// Garanto uma única thread sendo executada
	If !LockByName("ADEST038P", .T., .F.)
		If lAuto
			ConOut(cRotina + " - Existe outro processamento sendo executado! Verifique...")
			apMsgStop("Existe outro processamento sendo executado! Verifique...", "Atenção")
		Else
			Aviso("Atenção", "Existe outro processamento sendo executado! Verifique...", {"OK"}, 3)
		EndIf
		
		Return
	EndIf
	
	//+------------------------------------------------+
	//|Cria grupo de perguntas.                        |
	//+------------------------------------------------+
	MontaPerg()
	
	If lAuto
		RunSubProdutos(oProcess, lAuto)
	Else
		tNewProcess():New("ADEST038P",cTitulo,bProcess,cDescri,cPerg,, .T.,5, "RUNADEST038P", .T. )
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADEST038P")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RUNSUBPRODºAutor  ³Fernando Macieira   º Data ³  13/11/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executa regras definidas pelo usuario                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ADORO                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RunSubProdutos(oSelf, lAuto)

	Local cSql      := ""
	Local cQuery    := ""
	Local cZCSZCR   := ""
	Local cDtFecha	:= DtoS(GetMV("MV_ULMES",,"20180101"))	/*Data do último fechamento do estoque.*/
	Local cDtBlqMov	:= DtoS(GetMV("MV_DBLQMOV",,"20180101"))	/*Data do último fechamento do estoque.*/
	Local cHrIni, cHrFim
	
	cHrIni := Time()
	
	// Pergunte
	cDtRef := DtoS(MV_PAR01)
	
	// Data via JOB
	If lAuto
		cDtServer := Left( AllTrim( DtoS( msDate() ) ), 6 )
		cDtRef := cDtServer + AllTrim( Str( Last_Day( msDate() ) ) )
	EndIf
	
	// Inserir travas de datas!
	ZCS->( dbSetOrder(1) ) // ZCS_ZCS_FILIAL+ZCS_DATREF
	If ZCS->( !dbSeek(FWxFilial("ZCS")+cDtRef) )
		
		If lAuto
			ConOut(cRotina + " Período de processamento não encontrado no cadastro de períodos e valores... Verifique!")
			ApMsgStop(cRotina + " Período de processamento não encontrado no cadastro de períodos e valores... Verifique!", "Atenção")
		Else
			Aviso(cRotina, " Período de processamento não encontrado no cadastro de períodos e valores... Verifique!", {"OK"}, 3)
		EndIf
		
		Return
		
	EndIf
	
	// Inserir travas de status!
	ZCS->( dbSetOrder(1) ) // ZCS_ZCS_FILIAL+ZCS_DATREF
	If ZCS->( dbSeek(FWxFilial("ZCS")+cDtRef) )
		
		If AllTrim(ZCS->ZCS_STATUS) == "A"  // Aberto
			
			If lAuto
				ConOut(cRotina + " Período não foi calculado! Calcule o período para geração dos valores que serão utilizados na alteração das estruturas e apontamentos... ")
				ApMsgStop(cRotina + " Período não foi calculado! Calcule o período para geração dos valores que serão utilizados na alteração das estruturas e apontamentos... ", "Atenção")
			Else
				Aviso(cRotina, " Período não foi calculado! Calcule o período para geração dos valores que serão utilizados na alteração das estruturas e apontamentos... ", {"OK"}, 3)
			EndIf
			
			Return
			
		EndIf
		
		/*
		
		// inibido conforme diretriz usuaria Danielle em 27/11/2018
		
		ElseIf AllTrim(ZCS->ZCS_STATUS) == "F" // Fechado
		
		If lAuto
		ConOut(cRotina + " Período está fechado! As alterações nas estruturas e apontamentos já foram realizados... ")
		ApMsgStop(cRotina + " Período está fechado! As alterações nas estruturas e apontamentos já foram realizados... ", "Atenção")
		Else
		Aviso(cRotina, " Período está fechado! As alterações nas estruturas e apontamentos já foram realizados... ", {"OK"}, 3)
		EndIf
		
		Return
		
		EndIf
		*/
		
	EndIf
	
	/*Trava de segurança para não permitir processar algo menor que a data do parametro MV_ULMES*/
	If cDtRef <= cDtFecha
		
		If lAuto
			ConOut(cRotina + "Não é permitido selecionar uma data menor ou igual a data do último fechamento do estoque! Parâmetro MV_ULMES... ")
			ApMsgStop(cRotina + " Não é permitido selecionar uma data menor ou igual a data do último fechamento do estoque! Parâmetro MV_ULMES... ", "Atenção")
		Else
			Aviso(cRotina, " Não é permitido selecionar uma data menor ou igual a data do último fechamento do estoque! Parâmetro MV_ULMES... ", {"OK"}, 3)
		EndIf
		
		//Alert("Não é permitido selecionar uma data menor ou igual a data do ultimo fechamento do estoque")
		
		Return
		
	EndIf
	
	/*Trava de segurança para não permitir processar algo menor que a data do parametro MV_DBLQMOV*/
	If cDtRef <= cDtBlqMov
		
		If lAuto
			ConOut(cRotina + "Não é permitido selecionar uma data menor ou igual a data do bloqueio de movimentos! Parâmetro MV_DBLQMOV... ")
			ApMsgStop(cRotina + " Não é permitido selecionar uma data menor ou igual a data do bloqueio de movimentos! Parâmetro MV_DBLQMOV... ", "Atenção")
		Else
			Aviso(cRotina, " Não é permitido selecionar uma data menor ou igual a data do bloqueio de movimentos! Parâmetro MV_DBLQMOV... ", {"OK"}, 3)
		EndIf
		
		//Alert("Não é permitido selecionar uma data menor ou igual a data do ultimo fechamento do estoque")
		
		Return
		
	EndIf
	
		If lAuto
			ConOut( " Inicializando ambiente... " )
		Else
			oSelf:SetRegua1( 2 )
			oSelf:IncRegua1( " Inicializando ambiente... " )
			
			oSelf:SetRegua2( 2 )
			oSelf:IncRegua2( " Inicializando ambiente... " )
			
			oSelf:SaveLog("")
		EndIf
		
		PtInternal( 1, "[" + cRotina + "] - Inicializando ambiente... " )
		
		// Inicio do processamento
		
		// ZBN
		If lAuto
			logZBN("1") // Inicio
		EndIf
	
		// Calculo 4 - Efetuo as transformações das estruturas e apontamentos
		cZCSZCR  := GetNextAlias()
		
		cQuery := " SELECT ZCR_PRODUT, ZCR_QTDPEN, ZCR_SG1PEN, ZCR_SG1DEJ, ZCR_SG1CMS, ZCR_CCZMOD, ZCR_CCZFUN, ZCR_CCZDEP, ZCR_CCZINS, ZCR_CCZMAN, ZCR_CCZSER, ZCR_CCZUTI "
		cQuery += " FROM " + RetSqlName("ZCR") + " ZCR "
		cQuery += " WHERE ZCR_FILIAL='"+FWxFilial("ZCR")+"' "
		cQuery += " AND ZCR_DATREF='"+cDtRef+"' "
		cQuery += " AND ZCR.D_E_L_E_T_='' "
		
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cZCSZCR, .T., .T. )
		
		// Compatibilizo campos numericos e data
		(cZCSZCR)->( dbGoTop() )
		aEval( ZCR->( dbStruct() ) ,{ |x| If( x[2] != "C" , tcSetField( ( cZCSZCR ) , AllTrim( x[1] ), x[2] , x[3] , x[4] ) , Nil ) } )
		
		If !lAuto
			nTotTmp := 0
			(cZCSZCR)->( dbEval( { || nTotTmp++ },,{ || !EOF() } ) )
			oSelf:SetRegua1( nTotTmp )
		EndIf
		
		(cZCSZCR)->( dbGoTop() )
		Do While (cZCSZCR)->( !EOF() )
			
			cProdut := (cZCSZCR)->ZCR_PRODUT
			
			If lAuto
				ConOut(cRotina + " Produto " + (cZCSZCR)->ZCR_PRODUT)
			Else
				oSelf:IncRegua1("Produto " + (cZCSZCR)->ZCR_PRODUT)
			EndIf
			PtInternal( 1, "[" + cRotina + "] - Produto [" + (cZCSZCR)->ZCR_PRODUT + "] - Modificando estruturas e apontamentos... " )
			
			If !lAuto
				oSelf:SetRegua2( nTotTmp )
			EndIf
			
			// Altero as estruturas e apontamentos
			
			// Penas
			cIDADORO := "ZCR/ZCS - Dt Ref " + cDtRef + " Produto/Componente " + AllTrim(cProdut) + "/" + AllTrim(cProdPen) + " - Data " + DtoC(msDate()) + " - Hora " + Time() + " - " + cRotina + " - " + cUserName
			
			// Optado por utilizar UPDATE no lugar do reclock apos testes de performance
			cSql := " UPDATE " + RetSqlName("SG1")
			cSql += " SET G1_QUANT="+AllTrim(Str((cZCSZCR)->ZCR_SG1PEN))+" "
			cSql += " WHERE G1_FILIAL='"+FWxFilial("SG1")+"' "
			cSql += " AND G1_COD='"+cProdut+"' "
			cSql += " AND G1_COMP='"+cProdPen+"' "
			cSql += " AND D_E_L_E_T_='' "
			
			nStatus := tcSqlExec(cSql)
			
			If nStatus < 0
				If lAuto
					ConOut(cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Verifique... " + tcSQLError() )
					ApMsgStop( cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Verifique... " + tcSQLError(), "Atenção" )
				Else
					msgAlert(cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Envie o erro que será mostrado na próxima tela ao TI... ")
					MessageBox(tcSqlError(),"",16)
				EndIf
				
			Else
				AjustaSD3(cProdut, cProdPen, oSelf)
				
			EndIf
			
			// Dejetos
			cIDADORO := "ZCR/ZCS - Dt Ref " + cDtRef + " Produto/Componente " + AllTrim(cProdut) + "/" + AllTrim(cProdDej) + " - Data " + DtoC(msDate()) + " - Hora " + Time() + " - " + cRotina + " - " + cUserName
			
			// Optado por utilizar UPDATE no lugar do reclock apos testes de performance
			cSql := " UPDATE " + RetSqlName("SG1")
			cSql += " SET G1_QUANT="+AllTrim(Str((cZCSZCR)->ZCR_SG1DEJ))+" "
			cSql += " WHERE G1_FILIAL='"+FWxFilial("SG1")+"' "
			cSql += " AND G1_COD='"+cProdut+"' "
			cSql += " AND G1_COMP='"+cProdDej+"' "
			cSql += " AND D_E_L_E_T_='' "
			
			nStatus := tcSqlExec(cSql)
			
			If nStatus < 0
				If lAuto
					ConOut(cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Verifique... " + tcSQLError() )
					ApMsgStop( cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Verifique... " + tcSQLError(), "Atenção" )
				Else
					msgAlert(cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Envie o erro que será mostrado na próxima tela ao TI... ")
					MessageBox(tcSqlError(),"",16)
				EndIf
				
			Else
				AjustaSD3(cProdut, cProdDej, oSelf)
				
			EndIf
			
			// CMS
			cIDADORO := "ZCR/ZCS - Dt Ref " + cDtRef + " Produto/Componente " + AllTrim(cProdut) + "/" + AllTrim(cProdCMS) + " - Data " + DtoC(msDate()) + " - Hora " + Time() + " - " + cRotina + " - " + cUserName

			// Optado por utilizar UPDATE no lugar do reclock apos testes de performance
			cSql := " UPDATE " + RetSqlName("SG1")
			cSql += " SET G1_QUANT="+AllTrim(Str((cZCSZCR)->ZCR_SG1CMS))+" "
			cSql += " WHERE G1_FILIAL='"+FWxFilial("SG1")+"' "
			cSql += " AND G1_COD='"+cProdut+"' "
			cSql += " AND G1_COMP='"+cProdCMS+"' "
			cSql += " AND D_E_L_E_T_='' "
			
			nStatus := tcSqlExec(cSql)
			
			If nStatus < 0
				If lAuto
					ConOut(cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Verifique... " + tcSQLError() )
					ApMsgStop( cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Verifique... " + tcSQLError(), "Atenção" )
				Else
					msgAlert(cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Envie o erro que será mostrado na próxima tela ao TI... ")
					MessageBox(tcSqlError(),"",16)
				EndIf
				
			Else
				AjustaSD3(cProdut, cProdCMS, oSelf)
				
			EndIf
			
			// ZMOD
			cComp := "ZMOD-"+AllTrim(cCCProdZ)
			cIDADORO := "ZCR/ZCS - Dt Ref " + cDtRef + " Produto/Componente " + AllTrim(cProdut) + cComp + " - Data " + DtoC(msDate()) + " - Hora " + Time() + " - " + cRotina + " - " + cUserName
			
			// Optado por utilizar UPDATE no lugar do reclock apos testes de performance
			cSql := " UPDATE " + RetSqlName("SG1")
			cSql += " SET G1_QUANT="+AllTrim(Str((cZCSZCR)->ZCR_CCZMOD))+" "
			cSql += " WHERE G1_FILIAL='"+FWxFilial("SG1")+"' "
			cSql += " AND G1_COD='"+cProdut+"' "
			cSql += " AND G1_COMP='"+cComp+"' "
			cSql += " AND D_E_L_E_T_='' "
			
			nStatus := tcSqlExec(cSql)
			
			If nStatus < 0
				If lAuto
					ConOut(cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Verifique... " + tcSQLError() )
					ApMsgStop( cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Verifique... " + tcSQLError(), "Atenção" )
				Else
					msgAlert(cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Envie o erro que será mostrado na próxima tela ao TI... ")
					MessageBox(tcSqlError(),"",16)
				EndIf
				
			Else
				AjustaSD3(cProdut, cComp, oSelf)
				
			EndIf
			
			// ZFUN
			cComp := "ZFUN-"+AllTrim(cCCProdZ)
			cIDADORO := "ZCR/ZCS - Dt Ref " + cDtRef + " Produto/Componente " + AllTrim(cProdut) + cComp + " - Data " + DtoC(msDate()) + " - Hora " + Time() + " - " + cRotina + " - " + cUserName
			
			// Optado por utilizar UPDATE no lugar do reclock apos testes de performance
			cSql := " UPDATE " + RetSqlName("SG1")
			cSql += " SET G1_QUANT="+AllTrim(Str((cZCSZCR)->ZCR_CCZFUN))+" "
			cSql += " WHERE G1_FILIAL='"+FWxFilial("SG1")+"' "
			cSql += " AND G1_COD='"+cProdut+"' "
			cSql += " AND G1_COMP='"+cComp+"' "
			cSql += " AND D_E_L_E_T_='' "
			
			nStatus := tcSqlExec(cSql)
			
			If nStatus < 0
				If lAuto
					ConOut(cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Verifique... " + tcSQLError() )
					ApMsgStop( cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Verifique... " + tcSQLError(), "Atenção" )
				Else
					msgAlert(cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Envie o erro que será mostrado na próxima tela ao TI... ")
					MessageBox(tcSqlError(),"",16)
				EndIf
				
			Else
				AjustaSD3(cProdut, cComp, oSelf)
				
			EndIf
			
			// ZDEP
			cComp := "ZDEP-"+AllTrim(cCCProdZ)
			cIDADORO := "ZCR/ZCS - Dt Ref " + cDtRef + " Produto/Componente " + AllTrim(cProdut) + cComp + " - Data " + DtoC(msDate()) + " - Hora " + Time() + " - " + cRotina + " - " + cUserName
			
			// Optado por utilizar UPDATE no lugar do reclock apos testes de performance
			cSql := " UPDATE " + RetSqlName("SG1")
			cSql += " SET G1_QUANT="+AllTrim(Str((cZCSZCR)->ZCR_CCZDEP))+" "
			cSql += " WHERE G1_FILIAL='"+FWxFilial("SG1")+"' "
			cSql += " AND G1_COD='"+cProdut+"' "
			cSql += " AND G1_COMP='"+cComp+"' "
			cSql += " AND D_E_L_E_T_='' "
			
			nStatus := tcSqlExec(cSql)
			
			If nStatus < 0
				If lAuto
					ConOut(cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Verifique... " + tcSQLError() )
					ApMsgStop( cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Verifique... " + tcSQLError(), "Atenção" )
				Else
					msgAlert(cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Envie o erro que será mostrado na próxima tela ao TI... ")
					MessageBox(tcSqlError(),"",16)
				EndIf
				
			Else
				AjustaSD3(cProdut, cComp, oSelf)
				
			EndIf
			
			// ZINS
			cComp := "ZINS-"+AllTrim(cCCProdZ)
			cIDADORO := "ZCR/ZCS - Dt Ref " + cDtRef + " Produto/Componente " + AllTrim(cProdut) + cComp + " - Data " + DtoC(msDate()) + " - Hora " + Time() + " - " + cRotina + " - " + cUserName
			
			// Optado por utilizar UPDATE no lugar do reclock apos testes de performance
			cSql := " UPDATE " + RetSqlName("SG1")
			cSql += " SET G1_QUANT="+AllTrim(Str((cZCSZCR)->ZCR_CCZINS))+" "
			cSql += " WHERE G1_FILIAL='"+FWxFilial("SG1")+"' "
			cSql += " AND G1_COD='"+cProdut+"' "
			cSql += " AND G1_COMP='"+cComp+"' "
			cSql += " AND D_E_L_E_T_='' "
			
			nStatus := tcSqlExec(cSql)
			
			If nStatus < 0
				If lAuto
					ConOut(cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Verifique... " + tcSQLError() )
					ApMsgStop( cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Verifique... " + tcSQLError(), "Atenção" )
				Else
					msgAlert(cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Envie o erro que será mostrado na próxima tela ao TI... ")
					MessageBox(tcSqlError(),"",16)
				EndIf
				
			Else
				AjustaSD3(cProdut, cComp, oSelf)
				
			EndIf
	
			// ZMAN
			cComp := "ZMAN-"+AllTrim(cCCProdZ)
			cIDADORO := "ZCR/ZCS - Dt Ref " + cDtRef + " Produto/Componente " + AllTrim(cProdut) + cComp + " - Data " + DtoC(msDate()) + " - Hora " + Time() + " - " + cRotina + " - " + cUserName
			
			// Optado por utilizar UPDATE no lugar do reclock apos testes de performance
			cSql := " UPDATE " + RetSqlName("SG1")
			cSql += " SET G1_QUANT="+AllTrim(Str((cZCSZCR)->ZCR_CCZMAN))+" "
			cSql += " WHERE G1_FILIAL='"+FWxFilial("SG1")+"' "
			cSql += " AND G1_COD='"+cProdut+"' "
			cSql += " AND G1_COMP='"+cComp+"' "
			cSql += " AND D_E_L_E_T_='' "
			
			nStatus := tcSqlExec(cSql)
			
			If nStatus < 0
				If lAuto
					ConOut(cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Verifique... " + tcSQLError() )
					ApMsgStop( cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Verifique... " + tcSQLError(), "Atenção" )
				Else
					msgAlert(cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Envie o erro que será mostrado na próxima tela ao TI... ")
					MessageBox(tcSqlError(),"",16)
				EndIf
				
			Else
				AjustaSD3(cProdut, cComp, oSelf)
				
			EndIf
			
			// ZSER
			cComp := "ZSER-"+AllTrim(cCCProdZ)
			cIDADORO := "ZCR/ZCS - Dt Ref " + cDtRef + " Produto/Componente " + AllTrim(cProdut) + cComp + " - Data " + DtoC(msDate()) + " - Hora " + Time() + " - " + cRotina + " - " + cUserName
			
			// Optado por utilizar UPDATE no lugar do reclock apos testes de performance
			cSql := " UPDATE " + RetSqlName("SG1")
			cSql += " SET G1_QUANT="+AllTrim(Str((cZCSZCR)->ZCR_CCZSER))+" "
			cSql += " WHERE G1_FILIAL='"+FWxFilial("SG1")+"' "
			cSql += " AND G1_COD='"+cProdut+"' "
			cSql += " AND G1_COMP='"+cComp+"' "
			cSql += " AND D_E_L_E_T_='' "
			
			nStatus := tcSqlExec(cSql)
			
			If nStatus < 0
				If lAuto
					ConOut(cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Verifique... " + tcSQLError() )
					ApMsgStop( cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Verifique... " + tcSQLError(), "Atenção" )
				Else
					msgAlert(cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Envie o erro que será mostrado na próxima tela ao TI... ")
					MessageBox(tcSqlError(),"",16)
				EndIf
				
			Else
				AjustaSD3(cProdut, cComp, oSelf)
				
			EndIf
			
			// ZUTI
			cComp := "ZUTI-"+AllTrim(cCCProdZ)
			cIDADORO := "ZCR/ZCS - Dt Ref " + cDtRef + " Produto/Componente " + AllTrim(cProdut) + cComp + " - Data " + DtoC(msDate()) + " - Hora " + Time() + " - " + cRotina + " - " + cUserName
			
			// Optado por utilizar UPDATE no lugar do reclock apos testes de performance
			cSql := " UPDATE " + RetSqlName("SG1")
			cSql += " SET G1_QUANT="+AllTrim(Str((cZCSZCR)->ZCR_CCZUTI))+" "
			cSql += " WHERE G1_FILIAL='"+FWxFilial("SG1")+"' "
			cSql += " AND G1_COD='"+cProdut+"' "
			cSql += " AND G1_COMP='"+cComp+"' "
			cSql += " AND D_E_L_E_T_='' "
			
			nStatus := tcSqlExec(cSql)
			
			If nStatus < 0
				If lAuto
					ConOut(cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Verifique... " + tcSQLError() )
					ApMsgStop( cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Verifique... " + tcSQLError(), "Atenção" )
				Else
					msgAlert(cRotina + "- UPDATE na tabela SG1 (Estruturas) não foi realizado! Envie o erro que será mostrado na próxima tela ao TI... ")
					MessageBox(tcSqlError(),"",16)
				EndIf
				
			Else
				AjustaSD3(cProdut, cComp, oSelf)
				
			EndIf
			
			(cZCSZCR)->( dbSkip() )
			
		EndDo
		
		(cZCSZCR)->( dbCloseArea() )
		
		// Gravo Status
		ZCS->( dbSetOrder(1) ) // ZCS_ZCS_FILIAL+ZCS_DATREF
		If ZCS->( dbSeek(FWxFilial("ZCS")+cDtRef) )
			
			RecLock("ZCS", .f.)
			ZCS->ZCS_STATUS := "F"
			ZCS->( msUnLock() )
			
		EndIf
		
		// FIM - Processamento calculos subprodutos
		
		If lAuto
			// ZBN
			logZBN("2") // Fim
			
			ConOut(cRotina + " - "  + cUserName + " - "  + DtoC(msDate()) + " - "  + time() + " - Filial ADORO " + cFilADORO)
		Else
			oSelf:SaveLog(cRotina, cUserName, msDate(), time(), "Filial ADORO " + cFilADORO)
		EndIf
		
		// Finalizando processamento
		cHrFim := Time()
		
		PtInternal( 1, "[" + cRotina + "] - Filial ADORO [" + cFilADORO + "] - Finalizando..." )
		If lAuto
			ConOut(cRotina + " Transformações das estruturas e apontamentos dos subprodutos gravados com sucesso!" + ENTER + ENTER + "Iniciado as: " + cHrIni + ENTER + "Finalizado as: " + cHrFim)
		Else
			Aviso("Fim", "Transformações das estruturas e apontamentos dos subprodutos gravados com sucesso!" + ENTER + ENTER + "Iniciado as: " + cHrIni + ENTER + "Finalizado as: " + cHrFim, {"OK"}, 3)
		EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³montaperg ºAutor  ³Fernando Macieira   º Data ³  13/11/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria grupo de perguntas                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ADORO                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MontaPerg()

	Private bValid := Nil
	Private cF3	    := Nil
	Private cSXG   := Nil
	Private cPyme  := Nil
	
	U_xPutSx1(cPerg,'01','Data Referência     ?','','','mv_ch01','D',08,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR01')
	
	Pergunte(cPerg,.F.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³logzbn    ºAutor  ³Fernando Macieira   º Data ³  09/17/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava log quando schedulado                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function logZBN(cStatus, cTmpKey)

	Local cRotZBN := "ADEST038P"
	Local aArea	   := GetArea()
	Local lGrvZBN := .t.
	
	Default cStatus := "1"
	Default cTmpKey := ""
	
	If cStatus == "1"
		cDescri := "- Ini"
	Else
		cDescri := "- Fim"
	EndIf
	
	dbSelectArea("ZBN")
	
	RecLock("ZBN", lGrvZBN)
	
	ZBN_FILIAL  := FWxFilial("ZBN")
	ZBN_ROTINA	:= cRotZBN
	ZBN_DESCRI  := cTitulo + cDescri + " - Fil_ADORO " + cFilADORO + " Reg " + cTmpKey
	ZBN_DATA    := msDate()
	ZBN_HORA    := Time()
	ZBN_STATUS	:= cStatus
	
	ZBN->( msUnlock() )
	
	RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSD3 ºAutor  ³Fernando Macieira   º Data ³  11/21/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua transformacoes nos apontamentos                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AjustaSD3(cCod, cComp, oSelf)

	Local cAliasSD3	:= GetNextAlias()
	Local cQuery	:= ""
	
	/*Query usada para pegar todos os produtos de várzea que deverão ser feitos os ajustes de consumo de massa de frango*/
	BeginSql Alias cAliasSD3
		
		SELECT D3_FILIAL, D3_DOC, D3_TM, D3_COD, D3_OP, D3_QUANT, D3_EMISSAO, G1_COMP, G1_QUANT
		FROM %table:SD3% SD3A (NOLOCK), %table:SG1% SG1 (NOLOCK)
		WHERE D3_COD = SG1.G1_COMP
		AND SD3A.D3_FILIAL = %xFilial:SD3%
		AND D3_EMISSAO BETWEEN %Exp:DTOS(FIRSTDATE(mv_par01))% AND %Exp:DTOS(LASTDATE(mv_par01))%
		AND SG1.G1_FILIAL =	%xfilial:SG1%
		AND SG1.G1_COD = %Exp:cCod%
		AND G1_COMP = %Exp:cComp%
		AND SD3A.%notDel% AND SG1.%notDel%
		AND EXISTS
		(
		SELECT 1
		FROM %table:SD3% SD3B (NOLOCK)
		WHERE SD3B.D3_FILIAL = %xFilial:SD3%
		AND SD3B.D3_EMISSAO BETWEEN %Exp:DTOS(FIRSTDATE(mv_par01))% AND %Exp:DTOS(LASTDATE(mv_par01))%
		AND SD3B.D3_COD = %Exp:cCod%
		AND SD3B.D3_TM = %Exp:cSD3TM%
		AND SD3B.D3_OP = SD3A.D3_OP
		AND SD3B.%notDel%
		)
	
	EndSql
	
	(cAliasSD3)->( dbGoTop() )
	
	oSelf:IncRegua1( " Produto... " + (cAliasSD3)->D3_COD )
	
	Do While (cAliasSD3)->( !EOF() )
		
		oSelf:IncRegua2( " Apontamento... " + (cAliasSD3)->D3_OP )
		
		nQuantReal := 0
		nValQntAnt := (cAliasSD3)->D3_QUANT
		
		cAliasD32 := GetNextAlias()
		
		cQuery := " SELECT D3_QUANT "
		cQuery += " FROM " + RetSqlName("SD3") + " SD3 "
		cQuery += " WHERE D3_FILIAL = '" + (cAliasSD3)->D3_FILIAL + "' "
		cQuery += "  	AND D3_EMISSAO = '" +  (cAliasSD3)->D3_EMISSAO + "' "
		cQuery += "  	AND D3_DOC = '" + (cAliasSD3)->D3_DOC + "' "
		cQuery += "  	AND D3_TM = '" + cSD3TM + "' "
		cQuery += "  	AND D3_OP = '" + (cAliasSD3)->D3_OP + "' "
		cQuery += " 	AND D3_ESTORNO = ' ' "
		cQuery += " 	AND D_E_L_E_T_=' ' "
		
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasD32, .F., .T.)
		
		nQuantReal := (cAliasD32)->D3_QUANT
		
		cIDADORO := "ZCR/ZCS - Dt Ref " + cDtRef + " Produto/Componente " + AllTrim(cCod) + "/" + AllTrim(cComp) + " - Data " + DtoC(msDate()) + " - Hora " + Time() + " - " + cRotina + " - " + cUserName
		
		// Optado por utilizar UPDATE no lugar do reclock apos testes de performance
		cSql := " UPDATE " + RetSqlName("SD3")
		cSql += " SET D3_QUANT="+AllTrim(Str(nQuantReal*(cAliasSD3)->G1_QUANT))+" "
		cSql += " WHERE D3_FILIAL='"+FWxFilial("SD3")+"' "
		cSql += " AND D3_COD='"+(cAliasSD3)->D3_COD+"' "
		cSql += " AND D3_OP='"+(cAliasSD3)->D3_OP+"' "
		cSql += " AND D3_DOC='"+(cAliasSD3)->D3_DOC+"' "
		cSql += " AND D_E_L_E_T_='' "
		
		nStatus := tcSqlExec(cSql)
		
		If nStatus < 0
			If lAuto
				ConOut(cRotina + "- UPDATE na tabela SD3 (Apontamentos) não foi realizado! Verifique... " + tcSQLError() )
				ApMsgStop( cRotina + "- UPDATE na tabela SD3 (Apontamentos) não foi realizado! Verifique... " + tcSQLError(), "Atenção" )
			Else
				msgAlert(cRotina + "- UPDATE na tabela SD3 (Apontamentos) não foi realizado! Envie o erro que será mostrado na próxima tela ao TI... ")
				MessageBox(tcSqlError(),"",16)
			EndIf
		EndIf
		
		(cAliasD32)->( dbCloseArea() )
		
		(cAliasSD3)->( dbSkip() )
		
	EndDo
	
	(cAliasSD3)->( dbCloseArea() )

Return