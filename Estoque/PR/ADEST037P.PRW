#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "rwmake.ch"

#DEFINE  ENTER 		Chr(13)+Chr(10)

// Variaveis estaticas
Static cRotina  := "[ ADORO ] - ADEST037P "
Static cTitulo  := "[ ADORO ] - Subprodutos - Cแlculo variแveis - Custo Ceres ADORO "

Static cProdPen := "" // Codigo produto Penas
Static cProdDej := "" // Codigo produto Dejetos
Static cProdCMS := "" // Codigo produto CMS
Static cSD3TM	:= "" // Tipo Movimentacao producao AllTrim(GetMv("MV_XTMPRD",, "010"))

Static cEmpADORO  := "02"  // permite utilizar rotinas apenas na empresa CERES

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADEST037P บAutor  ณFernando Macieira   บ Data ณ 13/11/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina p/ efetuar calculos dos subprodutos                 บฑฑ
ฑฑบ          ณ utilizados no calculo do custo medio do ADORO              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ADORO                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamado   ณ 051623 || OS 052953 || CONTROLADORIA || DANIELLE_MEIRA ||  บฑฑ
ฑฑบ          ณ || 8459 || CUSTO MEDIO - FWNM - 11/09/2019                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ADEST037P()

	Local nArea    := 0
	
	Local oProcess
	Local bProcess := { |oSelf| RunSubProdutos(oSelf, lAuto) }
	Local cDescri  := "Esta rotina calcularแ os valores que serใo utilizados no cแlculo do custo Ceres ADORO, tais como, produ็ใo, pre็o m้dio de venda, fatores e quantidades serใo armazenados nas tabelas ZCS/ZCR..."  + ENTER + ENTER +;
					   " Aten็ใo: Valores variแveis (Valores contแbeis dos CC Improdutivos e quantidades de penas/dejetos e resํduos CMS) do perํodo precisam ser inseridos previamente nas tabelas ZCS/ZCR (Variแveis - Cแlculo Custo ADORO)." + ENTER + ENTER
	
	// Pergunte
	Private cPerg  := "ADEST037P"
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
			ConOut( cRotina + " Nใo foi possํvel inicializar o ambiente, empresa " + cEmpADORO + ", filial 01" )
			Return
		EndIf
	EndIf

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina p/ efetuar calculos dos subprodutos utilizados no calculo do custo medio do ADORO')
	
	// Carrego variaveis staticas com GETMV
	cEmpADORO  := GetMV("MV_#EMPSIG",,"02")  // permite utilizar rotinas apenas na empresa CERES
	cFilADORO  := GetMV("MV_#SIGFIL",,"01")  // Filial que possui os subprodutos que receberao as transforma็๕es
	
	cProdPen := GetMV("MV_#CODPEN",,"302213") // Codigo produto Penas
	cProdDej := GetMV("MV_#CODDEJ",,"313165") // Codigo produto Dejetos
	cProdCMS := GetMV("MV_#CODCMS",,"199753") // Codigo produto CMS
	
	cSD3TM	 := AllTrim(GetMv("MV_XTMPRD",, "010")) // Tipo Movimentacao producao subprodutos
	
	// fim variaveis staticas
	       
	// Consiste se o usuแrio estแ na empresa correta para utilizar ESTA ROTINA
	If cEmpADORO <> cEmpAnt
		If lAuto
			ConOut(cRotina + "MV_#EMPSIG - Empresa nใo autorizada para utilizar esta rotina!")
			ApMsgStop( "MV_#EMPSIG - Empresa nใo autorizada para utilizar esta rotina!", "Aten็ใo" )
		Else
			Aviso("MV_#EMPSIG", "Empresa nใo autorizada para utilizar esta rotina!", {"OK"}, 3)
		EndIf
		
		Return
	EndIf
	
	// Consiste se o usuแrio estแ na filial correta para efetuar os calculos dos subprodutos
	If cFilADORO <> cFilAnt
		If lAuto
			ConOut(cRotina + "MV_#SIGFIL - Filial nใo possui subprodutos para efetuar as transforma็๕es e cแlculos!")
			ApMsgStop( "MV_#SIGFIL - Filial nใo possui subprodutos para efetuar as transforma็๕es e cแlculos!", "Aten็ใo" )
		Else
			Aviso("MV_#EMPSIG", "MV_#SIGFIL - Filial nใo possui subprodutos para efetuar as transforma็๕es e cแlculos!", {"OK"}, 3)
		EndIf
		
		Return
	EndIf
	
	// Garanto uma ๚nica thread sendo executada
	If !LockByName("ADEST037P", .T., .F.)
		If lAuto
			ConOut(cRotina + " - Existe outro processamento sendo executado! Verifique...")
			apMsgStop("Existe outro processamento sendo executado! Verifique...", "Aten็ใo")
		Else
			Aviso("Aten็ใo", "Existe outro processamento sendo executado! Verifique...", {"OK"}, 3)
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
		tNewProcess():New("ADEST037P",cTitulo,bProcess,cDescri,cPerg,, .T.,5, "RUNADEST037P", .T. )
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ?
	//ณDestrava a rotina para o usuแrio	    ?
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ?
	UnLockByName("ADEST037P")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADEST037P บAutor  ณFernando Macieira   บ Data ณ  13/11/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processa regras de acordo com parametros informados        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ADORO                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RunSubProdutos(oSelf, lAuto)

	Local cSql      := ""
	Local cQuery    := ""
	
	Local cZCSZCR  := ""
	
	Local cHrIni, cHrFim
	
	Local cDtFecha	:= DtoS(GetMV("MV_ULMES",,"20180101"))	/*Data do ๚ltimo fechamento do estoque.*/
	Local cDtBlqMov	:= DtoS(GetMV("MV_DBLQMOV",,"20180101"))	/*Data do ๚ltimo fechamento do estoque.*/
	
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
			ConOut(cRotina + " Perํodo de processamento nใo encontrado no cadastro de perํodos e valores... Verifique!")
			ApMsgStop(cRotina + " Perํodo de processamento nใo encontrado no cadastro de perํodos e valores... Verifique!", "Aten็ใo")
		Else
			Aviso(cRotina, " Perํodo de processamento nใo encontrado no cadastro de perํodos e valores... Verifique!", {"OK"}, 3)
		EndIf
		
		Return
		
	EndIf
	
	
	// Inserir travas de status!
	/*
	
	// inibido conforme diretriz usuaria Danielle em 27/11/2018
	
	ZCS->( dbSetOrder(1) ) // ZCS_ZCS_FILIAL+ZCS_DATREF
	If ZCS->( dbSeek(FWxFilial("ZCS")+cDtRef) )
	
	If AllTrim(ZCS->ZCS_STATUS) == "F" // Fechado
	
	If lAuto
	ConOut(cRotina + " Perํodo jแ transformado e fechado! Estruturas e apontamentos jแ modificados... ")
	ApMsgStop(cRotina + " Perํodo jแ transformado e fechado! Estruturas e apontamentos jแ modificados... ", "Aten็ใo")
	Else
	Aviso(cRotina, " Perํodo jแ transformado e fechado! Estruturas e apontamentos jแ modificados... ", {"OK"}, 3)
	EndIf
	
	Return
	
	EndIf
	
	EndIf
	*/
	
	/*Trava de seguran็a para nใo permitir processar algo menor que a data do parametro MV_ULMES*/
	If cDtRef <= cDtFecha
		
		If lAuto
			ConOut(cRotina + "Nใo ้ permitido selecionar uma data menor ou igual a data do ๚ltimo fechamento do estoque! Parโmetro MV_ULMES... ")
			ApMsgStop(cRotina + " Nใo ้ permitido selecionar uma data menor ou igual a data do ๚ltimo fechamento do estoque! Parโmetro MV_ULMES... ", "Aten็ใo")
		Else
			Aviso(cRotina, " Nใo ้ permitido selecionar uma data menor ou igual a data do ๚ltimo fechamento do estoque! Parโmetro MV_ULMES... ", {"OK"}, 3)
		EndIf
		
		//Alert("Nใo ้ permitido selecionar uma data menor ou igual a data do ultimo fechamento do estoque")
		
		Return
		
	EndIf
	
	/*Trava de seguran็a para nใo permitir processar algo menor que a data do parametro MV_DBLQMOV*/
	If cDtRef <= cDtBlqMov
		
		If lAuto
			ConOut(cRotina + "Nใo ้ permitido selecionar uma data menor ou igual a data do bloqueio de movimentos! Parโmetro MV_DBLQMOV... ")
			ApMsgStop(cRotina + " Nใo ้ permitido selecionar uma data menor ou igual a data do bloqueio de movimentos! Parโmetro MV_DBLQMOV... ", "Aten็ใo")
		Else
			Aviso(cRotina, " Nใo ้ permitido selecionar uma data menor ou igual a data do bloqueio de movimentos! Parโmetro MV_DBLQMOV... ", {"OK"}, 3)
		EndIf
		
		//Alert("Nใo ้ permitido selecionar uma data menor ou igual a data do ultimo fechamento do estoque")
		
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
	
	cZCSZCR  := GetNextAlias()
	
	cQuery := " SELECT ZCR_PRODUT "
	cQuery += " FROM " + RetSqlName("ZCR") + " ZCR "
	cQuery += " WHERE ZCR_FILIAL='"+FWxFilial("ZCR")+"' "
	cQuery += " AND ZCR_DATREF='"+cDtRef+"' "
	cQuery += " AND ZCR.D_E_L_E_T_='' "
	
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cZCSZCR, .T., .T. )
	
	If !lAuto
		nTotTmp := 0
		(cZCSZCR)->( dbEval( { || nTotTmp++ },,{ || !EOF() } ) )
		oSelf:SetRegua1( nTotTmp )
	EndIf
	
	// Calculo 1 - Gravo as producoes e pre็os m้dios de vendas, bases de cแlculos para os demais cแlculos
	(cZCSZCR)->( dbGoTop() )
	Do While (cZCSZCR)->( !EOF() )
		
		cProdut := (cZCSZCR)->ZCR_PRODUT
		
		If lAuto
			ConOut(cRotina + " Produto " + (cZCSZCR)->ZCR_PRODUT)
		Else
			oSelf:IncRegua1("Produto " + (cZCSZCR)->ZCR_PRODUT)
		EndIf
		PtInternal( 1, "[" + cRotina + "] - Produto [" + (cZCSZCR)->ZCR_PRODUT + "] - Calculando Produ็๕es e Pre็os M้dios de Vendas... " )
		
		If !lAuto
			oSelf:SetRegua2( nTotTmp )
		EndIf
		
		// Calculo PRODUCAO
		nQtdPrd := UpProducao(cProdut)
		
		// Calculo PRECO MษDIO VENDA
		nPrcMed := CalcPrcMed(cProdut)
		
		// Chamado n. 051623 || OS 052953 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || CUSTO MEDIO - FWNM - 11/09/2019
		If nPrcMed <= 0

			If !lAuto

				lOk := .f.
	
			    Do While .t.
				   
				   @ 200, 001 To 377, 380 Dialog oDlgPar Title "Pre็o m้dio calculado: " + Transform(nPrcMed, "@E 999,999.99")
		
				   @ 009, 005 Say "Nใo houve venda deste produto no perํodo!
				   @ 015, 005 Say "Informe pre็o m้dio de venda do produto..." //+ cProdut
									   	
				   @ 025, 004 To 065, 187
					   
				   // nPrcMed
				   @ 039, 010 Say "Novo Pre็o M้dio: (" + AllTrim(cProdut) + ")"  
				   @ 038, 090 Get nPrcMed Size 76,10 Picture "@E 999,999.99" Valid (nPrcMed > 0)
					
				   @ 70, 105 BmpButton Type 01 Action (lOk := .T., Close(oDlgPar))
				   @ 70, 145 BmpButton Type 02 Action (lOk := .F., Close(oDlgPar))
					
				   Activate Dialog oDlgPar Centered
				   
				   If lOk
				   	  msgInfo("Novo pre็o m้dio informado: " + Transform(nPrcMed, "@E 999,999.99") )
				   	  Exit
				   EndIf
					   
				EndDo

			EndIf
				
		EndIf
		//

		// Gravo os cแlculos
		ZCR->( dbSetOrder(1) ) // ZCR_FILIAL+ZCR_DATREF+ZCR_PRODUT
		If ZCR->( dbSeek(FWxFilial("ZCR")+cDtRef+cProdut) )
			
			RecLock("ZCR", .f.)
			
			ZCR->ZCR_PRODUC := nQtdPrd
			ZCR->ZCR_PRCMED := nPrcMed
			
			ZCR->( msUnLock() )
			
		EndIf
		
		(cZCSZCR)->( dbSkip() )
		
	EndDo
	
	(cZCSZCR)->( dbCloseArea() )
	
	// Calculo 2 - Achados as bases de cแlulos (PRODUวรO e PREวO MษDIO VENDA), efetuo os cแlculos dos fatores
	cZCSZCR  := GetNextAlias()
	
	cQuery := " SELECT ZCR_PRODUT "
	cQuery += " FROM " + RetSqlName("ZCR") + " ZCR "
	cQuery += " WHERE ZCR_FILIAL='"+FWxFilial("ZCR")+"' "
	cQuery += " AND ZCR_DATREF='"+cDtRef+"' "
	cQuery += " AND ZCR.D_E_L_E_T_='' "
	
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cZCSZCR, .T., .T. )
	
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
		PtInternal( 1, "[" + cRotina + "] - Produto [" + (cZCSZCR)->ZCR_PRODUT + "] - Calculando fatores... " )
		
		If !lAuto
			oSelf:SetRegua2( nTotTmp )
		EndIf
		
		// Calculo fator 1
		nFator1 := CalcFator(1, cProdut)
		
		// Calculo fator 2
		nFator2 := CalcFator(2, cProdut)
		
		// Calculo fator 3
		nFator3 := CalcFator(3, cProdut)
		
		// Gravo calculos dos fatores
		ZCR->( dbSetOrder(1) ) // ZCR_FILIAL+ZCR_DATREF+ZCR_PRODUT
		If ZCR->( dbSeek(FWxFilial("ZCR")+cDtRef+cProdut) )
			
			RecLock("ZCR", .f.)
			
			ZCR->ZCR_FATOR1 := nFator1
			ZCR->ZCR_FATOR2 := nFator2
			ZCR->ZCR_FATOR3 := nFator3
			
			ZCR->( msUnLock() )
			
		EndIf
		
		(cZCSZCR)->( dbSkip() )
		
	EndDo
	
	(cZCSZCR)->( dbCloseArea() )
	
	// Calculo 3 - Gravo as estruturas e os valore dos CC Indiretos
	cZCSZCR  := GetNextAlias()
	
	cQuery := " SELECT ZCR_PRODUT, ZCR_PRODUC, ZCR_QTDPEN, ZCR_QTDDEJ, ZCR_QTDCMS, ZCS_DATREF, ZCS_VLZMOD, ZCS_VLZFUN, ZCS_VLZDEP, ZCS_VLZINS, ZCS_VLZMAN, ZCS_VLZSER, ZCS_VLZUTI, ZCR_FATOR1, ZCR_FATOR2, ZCR_FATOR3 "
	cQuery += " FROM " + RetSqlName("ZCS") + " ZCS, " + RetSqlName("ZCR") + " ZCR "
	cQuery += " WHERE ZCS_FILIAL=ZCR_FILIAL "
	cQuery += " AND ZCS_DATREF=ZCR_DATREF "
	cQuery += " AND ZCS_FILIAL='"+FWxFilial("ZCR")+"' "
	cQuery += " AND ZCS_DATREF='"+cDtRef+"' "
	cQuery += " AND ZCS.D_E_L_E_T_='' "
	cQuery += " AND ZCR.D_E_L_E_T_='' "
	
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cZCSZCR, .T., .T. )
	
	// Compatibilizo campos numericos e data
	(cZCSZCR)->( dbGoTop() )
	aEval( ZCS->( dbStruct() ) ,{ |x| If( x[2] != "C" , tcSetField( ( cZCSZCR ) , AllTrim( x[1] ), x[2] , x[3] , x[4] ) , Nil ) } )
	
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
		PtInternal( 1, "[" + cRotina + "] - Produto [" + (cZCSZCR)->ZCR_PRODUT + "] - Calculando Estruturas e CC Indiretos... " )
		
		If !lAuto
			oSelf:SetRegua2( nTotTmp )
		EndIf
		
		// Calculo Estruturas (Penas, Dejetos e CMS)
		nPenas   := ( (cZCSZCR)->ZCR_QTDPEN * ((cZCSZCR)->ZCR_FATOR1/100) ) / (cZCSZCR)->ZCR_PRODUC
		nDejetos := ( (cZCSZCR)->ZCR_QTDDEJ * ((cZCSZCR)->ZCR_FATOR2/100) ) / (cZCSZCR)->ZCR_PRODUC
		nCMS     := ( (cZCSZCR)->ZCR_QTDCMS * ((cZCSZCR)->ZCR_FATOR2/100) ) / (cZCSZCR)->ZCR_PRODUC
		
		// Calculo CC Indiretos
		nZMOD := ( (cZCSZCR)->ZCS_VLZMOD * ((cZCSZCR)->ZCR_FATOR3/100) ) / (cZCSZCR)->ZCR_PRODUC
		nZFUN := ( (cZCSZCR)->ZCS_VLZFUN * ((cZCSZCR)->ZCR_FATOR3/100) ) / (cZCSZCR)->ZCR_PRODUC
		nZDEP := ( (cZCSZCR)->ZCS_VLZDEP * ((cZCSZCR)->ZCR_FATOR3/100) ) / (cZCSZCR)->ZCR_PRODUC
		nZINS := ( (cZCSZCR)->ZCS_VLZINS * ((cZCSZCR)->ZCR_FATOR3/100) ) / (cZCSZCR)->ZCR_PRODUC
		nZMAN := ( (cZCSZCR)->ZCS_VLZMAN * ((cZCSZCR)->ZCR_FATOR3/100) ) / (cZCSZCR)->ZCR_PRODUC
		nZSER := ( (cZCSZCR)->ZCS_VLZSER * ((cZCSZCR)->ZCR_FATOR3/100) ) / (cZCSZCR)->ZCR_PRODUC
		nZUTI := ( (cZCSZCR)->ZCS_VLZUTI * ((cZCSZCR)->ZCR_FATOR3/100) ) / (cZCSZCR)->ZCR_PRODUC
		
		// Gravo os cแlculos
		ZCR->( dbSetOrder(1) ) // ZCR_FILIAL+ZCR_DATREF+ZCR_PRODUT
		If ZCR->( dbSeek(FWxFilial("ZCR")+cDtRef+cProdut) )
			
			RecLock("ZCR", .f.)
			
			ZCR->ZCR_SG1PEN := nPenas
			ZCR->ZCR_SG1DEJ := nDejetos
			ZCR->ZCR_SG1CMS := nCMS
			
			ZCR->ZCR_CCZMOD := nZMOD
			ZCR->ZCR_CCZFUN := nZFUN
			ZCR->ZCR_CCZDEP := nZDEP
			ZCR->ZCR_CCZINS := nZINS
			ZCR->ZCR_CCZMAN := nZMAN
			ZCR->ZCR_CCZSER := nZSER
			ZCR->ZCR_CCZUTI := nZUTI
			
			ZCR->( msUnLock() )
			
		EndIf
		
		(cZCSZCR)->( dbSkip() )
		
	EndDo
	
	(cZCSZCR)->( dbCloseArea() )
	
	// Gravo Status
	ZCS->( dbSetOrder(1) ) // ZCS_ZCS_FILIAL+ZCS_DATREF
	If ZCS->( dbSeek(FWxFilial("ZCS")+cDtRef) )
		
		RecLock("ZCS", .f.)
		ZCS->ZCS_STATUS := "C"
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
		ConOut(cRotina + " Cแlculos subprodutos finalizados e gravados com sucesso!" + ENTER + ENTER + "Iniciado as: " + cHrIni + ENTER + "Finalizado as: " + cHrFim)
	Else
		Aviso("Fim", "Cแlculos subprodutos finalizados e gravados com sucesso!" + ENTER + ENTER + "Iniciado as: " + cHrIni + ENTER + "Finalizado as: " + cHrFim, {"OK"}, 3)
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMONTAPERG บAutor  ณFernando Macieira   บ Data ณ  13/11/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria grupo de perguntas                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ADORO                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MontaPerg()

	Private bValid := Nil
	Private cF3	    := Nil
	Private cSXG   := Nil
	Private cPyme  := Nil
	
	U_xPutSx1(cPerg,'01','Data Refer๊ncia     ?','','','mv_ch01','D',08,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR01')
	
	Pergunte(cPerg,.F.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOGZBN    บAutor  ณFernando Macieira   บ Data ณ  09/17/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava log quando schedulado                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function logZBN(cStatus, cTmpKey)

	Local cRotZBN := "ADEST037P"
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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณUPPRODUCAOบAutor  ณFernando Macieira   บ Data ณ  11/21/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busco producao de acordo com regras definidas por Danielle บฑฑ
ฑฑบ          ณ Controladoria                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ADORO                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function UpProducao(cProdut)

	Local nProduzido:= 0
	Local cAliasSD3 := GetNextAlias()
	Local cFilCurren:= FWxFilial("SD3")
	Local cCF       := GetMV("MV_#CFSUBP",,"PR0")
	
	BeginSql Alias cAliasSD3
		
		SELECT SUM(D3_QUANT) AS PRODUZIDO
		FROM %table:SD3% SD3 (NOLOCK)
		WHERE D3_FILIAL = %Exp:cFilCurren%
		AND D3_EMISSAO BETWEEN %Exp:DTOS(FIRSTDATE(mv_par01))% AND %Exp:DTOS(LASTDATE(mv_par01))%
		AND D3_COD = %Exp:cProdut%
		AND D3_TM = %Exp:cSD3TM%
		AND D3_CF = %Exp:cCF%
		AND D3_ESTORNO=''
		AND SD3.%notDel%
		
	EndSql
	
	dbSelectArea(cAliasSD3)
	
	If (cAliasSD3)->(! EOF())
		nProduzido:= (cAliasSD3)->PRODUZIDO
	EndIf
	
	dbCloseArea(cAliasSD3)

Return nProduzido

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCALCPRCMEDบAutor  ณFernando Macieira   บ Data ณ  11/21/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calcula preco medio de venda                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CalcPrcMed(cProdut)

	/*Processamento*/
	Local cAliasSD2 	:= GetNextAlias()
	Local cAliasSD1 	:= GetNextAlias()
	Local dDtFecha	:= SuperGetMV("MV_ULMES")	/*Data do ๚ltimo fechamento do estoque.*/
	
	Private _nMesesMed	:= GetMV("MV_#ADOROMED",, 3)	/*Quantidade meses para cแlculo da m้dio do pre็o de venda*/
	Private _nPrecoMed 	:= 0	/*Valor do Pre็o M้dio de Venda encontrado no cแlculo feito das informa็๕es retornadas da query*/
	
	_nMesesMed -= 1
	
	/*Trava de seguran็a para nใo permitir processar algo menor que a data do parametro MV_ULMES*/
	If mv_par01 <= dDtFecha
		Alert("Nใo ้ permitido selecionar uma data menor ou igual a data do ultimo fechamento do estoque")
		
		Return
	EndIf
	
	/* Query busca FATURAMENTO serแ avaliado os produtos dos ๚ltimos tr๊s meses levando em considera็ใo o m๊s vigente escolhido na pergunta.*/
	BeginSql Alias cAliasSD2
		
		SELECT D2_COD, SUM(D2_QUANT) AS D2_QUANT, SUM(D2_TOTAL) AS D2_TOTAL
		FROM %table:SD2% SD2 (NOLOCK), %table:SF4% SF4 (NOLOCK)
		WHERE D2_FILIAL = F4_FILIAL
		AND D2_TES = F4_CODIGO
		AND D2_FILIAL = %xfilial:SD2%
		AND D2_EMISSAO BETWEEN %Exp:DTOS(FIRSTDATE(MONTHSUB(MV_PAR01,_nMesesMed)))% AND %Exp:DTOS(LASTDATE(MV_PAR01))%
		AND D2_COD = %Exp:cProdut%
		AND F4_DUPLIC = 'S'
		AND SD2.%notDel% AND SF4.%notDel%
		
		GROUP BY D2_COD
		
	EndSql
	
	(cAliasSD2)->( dbGoTop() )
	
	nD2TtQtd := 0
	nD2TtVlr := 0
	
	If (cAliasSD2)->( !EOF() )
		nD2TtQtd := (cAliasSD2)->D2_QUANT
		nD2TtVlr := (cAliasSD2)->D2_TOTAL
	EndIf
	
	/* Query busca DEVOLUCOES serแ avaliado os produtos dos ๚ltimos tr๊s meses levando em considera็ใo o m๊s vigente escolhido na pergunta.*/
	// Chamado n. 051623 || OS 052953 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || CUSTO MEDIO - FWNM - 11/09/2019
	// Incluir join com TES para considerar devolucao apenas quando a TES gera financeiro igual a SIM
	//

	BeginSql Alias cAliasSD1
		

		SELECT D1_COD, SUM(D1_QUANT) AS D1_QUANT, SUM(D1_TOTAL) AS D1_TOTAL
		
		FROM %table:SD1% SD1 (NOLOCK), %table:SF4% SF4 (NOLOCK)
		
		WHERE D1_FILIAL = F4_FILIAL
		AND D1_TES = F4_CODIGO
		
		AND D1_FILIAL = %xFilial:SD1%
		AND D1_DTDIGIT BETWEEN %Exp:DTOS(FIRSTDATE(MONTHSUB(MV_PAR01,_nMesesMed)))% AND %Exp:DTOS(LASTDATE(MV_PAR01))%
		AND D1_COD = %Exp:cProdut%
		AND D1_TIPO = 'D'
		AND F4_DUPLIC = 'S'
		AND SD1.%notDel% AND SF4.%notDel%
		
		GROUP BY D1_COD
		
		// Chamado n. 051623 || OS 052953 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || CUSTO MEDIO - FWNM - 11/09/2019
		// Inibido devido Incluir do join com TES para considerar devolucao apenas quando a TES gera financeiro igual a SIM
		//
		/*
		SELECT D1_COD, SUM(D1_QUANT) AS D1_QUANT, SUM(D1_TOTAL) AS D1_TOTAL
		FROM %table:SD1% SD1 (NOLOCK)
		WHERE D1_FILIAL = %xfilial:SD1%
		AND D1_DTDIGIT BETWEEN %Exp:DTOS(FIRSTDATE(MONTHSUB(MV_PAR01,_nMesesMed)))% AND %Exp:DTOS(LASTDATE(MV_PAR01))%
		AND D1_COD = %Exp:cProdut%
		AND D1_TIPO = 'D'
		AND SD1.%notDel%
		GROUP BY D1_COD
		*/
		
	EndSql
	
	(cAliasSD1)->( dbGoTop() )
	
	nD1TtQtd := 0
	nD1TtVlr := 0
	
	If (cAliasSD1)->( !EOF() )
		nD1TtQtd := (cAliasSD1)->D1_QUANT
		nD1TtVlr := (cAliasSD1)->D1_TOTAL
	EndIf
	
	// Calcula Faturamento - Devolucoes
	nSomaQuant := ( nD2TtQtd - nD1TtQtd )
	nSomaTotal := ( nD2TtVlr - nD1TtVlr )
	
	(cAliasSD2)->( dbCloseArea() )
	(cAliasSD1)->( dbCloseArea() )
	
	/*Cแlculo do Pre็o M้dio Geral das Vendas*/
	_nPrecoMed := nSomaTotal / nSomaQuant

Return _nPrecoMed

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCALCFATOR บAutor  ณFernando Macieira   บ Data ณ  11/21/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calcula fator 1,2 e 3                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CalcFator(nFator, cProdut)

	Local nVlrFator  := 0
	Local cQuery     := ""
	Local cFator1Cod := GetMV("MV_#FATOR1",,"100097")
	Local cFator2Cod := GetMV("MV_#FATOR2",,"100096#100098")
	Local cFator3Cod := GetMV("MV_#FATOR3",,"100097#100096#100098")
	
	// Regras - Calculos dos fatores
	If nFator == 1
		
		If AllTrim(cProdut) $ AllTrim(cFator1Cod)
			
			ZCR->( dbSetOrder(1) ) // ZCR_FILIAL+ZCR_DATREF+ZCR_PRODUT
			If ZCR->( dbSeek(FWxFilial("ZCR")+cDtRef+cProdut) )
				
				nVlrFator := ((ZCR->ZCR_PRODUC * ZCR->ZCR_PRCMED) / (ZCR->ZCR_PRODUC * ZCR->ZCR_PRCMED)) * 100
				
			EndIf
			
		EndIf
		
	ElseIf nFator == 2
		
		If AllTrim(cProdut) $ AllTrim(cFator2Cod)
			
			If Select("Work") > 0
				Work->( dbCloseArea() )
			EndIf
			
			cQuery := " SELECT SUM(ZCR_PRODUC*ZCR_PRCMED) BS_CALC "
			cQuery += " FROM " + RetSqlName("ZCR")
			cQuery += " WHERE ZCR_FILIAL='"+FWxFilial("ZCR")+"' "
			cQuery += " AND ZCR_DATREF='"+cDtRef+"' "
			cQuery += " AND ZCR_PRODUT IN " + FormatIn(cFator2Cod,"#")
			cQuery += " AND D_E_L_E_T_='' "
			
			tcQuery cQuery New Alias "Work"
			
			aTamSX3 := TamSX3("ZCR_PRCMED")
			tcSetField("Work","ZCR_PRCMED", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			Work->( dbGoTop() )
			
			nTtFator := 0
			
			If Work->( !EOF() )
				nTtFator := Work->BS_CALC
			EndIf
			
			ZCR->( dbSetOrder(1) ) // ZCR_FILIAL+ZCR_DATREF+ZCR_PRODUT
			If ZCR->( dbSeek(FWxFilial("ZCR")+cDtRef+cProdut) )
				
				nVlrFator := ((ZCR->ZCR_PRODUC * ZCR->ZCR_PRCMED) / (nTtFator)) * 100
				
			EndIf
			
			Work->( dbCloseArea() )
			
		EndIf
	
	ElseIf nFator == 3
		
		If AllTrim(cProdut) $ AllTrim(cFator3Cod)
			
			If Select("Work") > 0
				Work->( dbCloseArea() )
			EndIf
			
			cQuery := " SELECT SUM(ZCR_PRODUC*ZCR_PRCMED) BS_CALC "
			cQuery += " FROM " + RetSqlName("ZCR")
			cQuery += " WHERE ZCR_FILIAL='"+FWxFilial("ZCR")+"' "
			cQuery += " AND ZCR_DATREF='"+cDtRef+"' "
			cQuery += " AND ZCR_PRODUT IN " + FormatIn(cFator3Cod,"#")
			cQuery += " AND D_E_L_E_T_='' "
			
			tcQuery cQuery New Alias "Work"
			
			aTamSX3 := TamSX3("ZCR_PRCMED")
			tcSetField("Work","ZCR_PRCMED", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			Work->( dbGoTop() )
			
			nTtFator := 0
			
			If Work->( !EOF() )
				nTtFator := Work->BS_CALC
			EndIf
			
			ZCR->( dbSetOrder(1) ) // ZCR_FILIAL+ZCR_DATREF+ZCR_PRODUT
			If ZCR->( dbSeek(FWxFilial("ZCR")+cDtRef+cProdut) )
				
				nVlrFator := ((ZCR->ZCR_PRODUC * ZCR->ZCR_PRCMED) / (nTtFator)) * 100
				
			EndIf
			
			Work->( dbCloseArea() )
			
		EndIf
		
	EndIf

Return nVlrFator