#Include 'Totvs.ch'
#Include 'Topconn.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM521DNFS  บAutor  ณEverson             บ Data ณ  26/03/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de entrada na exclusใo do documento de saํda.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบversionamento ณ                                                        บฑฑ
ฑฑบEverson 20/11/2018 chamado 045271. Tratamento para remover flag        บฑฑ
ฑฑบno banco integra็ใo Protheus x SAG para que o SAG possa reprocessar o  บฑฑ
ฑฑบregitro.                                                               บฑฑ
ฑฑฬอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบEverson 14/05/2019 chamado 044314. Tratamento para estorno de frete.   บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function M521DNFS()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea	:= GetArea()
	
	//
	If FindFunction("U_ADVEN074P") .And. cEmpAnt = "01"
		If !Empty(Alltrim(cValToChar(SF2->F2_XSALES)))
			U_ADVEN074P(cEmpAnt,cFilAnt,Alltrim(cValToChar(SF2->F2_DOC)) + Alltrim(cValToChar(SF2->F2_SERIE)) ,.F.,"",.T.)
		
		EndIf
	
	EndIf
	
	//Everson - 20/11/2018.
	If cEmpAnt == "01"
		flagSag(Alltrim(cValToChar(SF2->F2_DOC)),Alltrim(cValToChar(SF2->F2_SERIE)))
		
		//Everson 14/05/2019 chamado 044314.
		If ! Empty(SF2->F2_PLACA)
			estFrt(SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA)
		
		EndIf
		//
		
	EndIf
	
	//
	RestArea(aArea)

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณflagSag   บAutor  ณEverson             บ Data ณ  20/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTratamento para retirar marca็ใo de integra็ใo no banco     บฑฑ
ฑฑบDesc.     ณintermediแrio Protheus x SAG.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 045271.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function flagSag(cNf,cSerie)
	
	/*
	
		************* Fun็ใo tamb้m utilizada no fonte MT100AGR ***********
	
	*/

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea	    := GetArea()
	Local nTcProth  := 0
	Local cBdTanq   := ""
	Local cSrvTanq  := ""
	Local cPortTanq := 0
	Local nTcTanq   := 0
	Local cPedido	:= ""
	Local cPedSAg	:= ""
	Local cUpdate	:= ""
	
	//
	SET DELETED OFF
		cPedido	:= Posicione("SD2",3,xFilial("SD2") + cNf + cSerie,"D2_PEDIDO")
		cPedSAg	:= Alltrim(cValToChar(Posicione("SC5",1,xFilial("SC5") + cPedido     ,"C5_PEDSAG")))
	SET DELETED ON
	
	//
	If Empty(cPedSAg)
		RestArea(aArea)		
		Return Nil
			
	EndIf

	// //
	// nTcProth  := advConnection()
	// cBdTanq   := GetPvProfString("INTSAGBD","BCO2","ERROR",GetADV97())
	// cSrvTanq  := GetPvProfString("INTSAGBD","SRV2","ERROR",GetADV97())
	// cPortTanq := Val(GetPvProfString("INTSAGBD","PRT2","ERROR",GetADV97()))

	//
	// If (nTcTanq := TcLink(cBdTanq,cSrvTanq,cPortTanq)) < 0
	// 	Aviso("Nใo foi possํvel  conectar ao banco integra็ใo, verifique com administrador","ERROR")
	// 	RestArea(aArea)		
	// 	Return Nil
		
	// EndIf
	
	//
	//TcSetConn(nTcTanq)
	
	cUpdate := "UPDATE SGPED010 SET STATUS_INT='', STATUS_PRC = '', MENSAGEM_INT = '' WHERE C5_FILIAL ='" + cFilAnt + "' AND C5_NUM='" + cPedSAg + "' "
	If TcSqlExec(cUpdate) < 0
		MsgAlert("Ocorreu erro na atualiza็ใo do registro no banco integra็ใo Protheus x SAG. " + Chr(13) + Chr(10) + TCSQLError(),"Fun็ใo flagSag (M521DNFS)")
	
	EndIf
	
	//
	//TcSetConn(nTcProth)
	
	//
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณestFrt    บAutor  ณEverson             บ Data ณ  14/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEstorna lan็amento de frete.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 044314.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function estFrt(F2DOC,F2SERIE,F2CLIENTE,F2LOJA)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea	    := GetArea()
	Local cPedido	:= ""
	
	//
	SET DELETED OFF
		cPedido	:= Posicione("SD2",3,xFilial("SD2") + F2DOC + F2SERIE,"D2_PEDIDO")
	SET DELETED ON
	
	//
	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
		Replace ZBE_FILIAL 	   	With xFilial("ZBE")
		Replace ZBE_DATA 	   	With dDataBase
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With "Estorno de frete"
		Replace ZBE_PARAME      With "Filial/Empresa/NF/Serie/Cliente/Loja/Pedido " + cValToChar(cEmpAnt) + " " + cValToChar(cFilAnt) + " " + cValToChar(F2DOC) + " " + cValToChar(F2SERIE) + " " + cValToChar(F2CLIENTE) + " " + cValToChar(F2LOJA) + " " + cValToChar(cPedido)
		Replace ZBE_MODULO	    With "LOGISTICA"
		Replace ZBE_ROTINA	    With "M521DNFS" 
	MsUnlock()
	
	//
	If ! Empty(cPedido)
		U_ADLOG042P( cEmpAnt , cFilAnt , F2DOC , F2SERIE , F2CLIENTE , F2LOJA  , cPedido , "3" )
	
	EndIf
	
	//
	RestArea(aArea)
	
Return Nil
