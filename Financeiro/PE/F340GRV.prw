#Include "Protheus.Ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF340GRV   บ Autor ณ Ana Helena Barreta บ Data ณ  10/06/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ PE da rotina FINA340 (Compensacao CP). Grava informa็๕es deบฑฑ
ฑฑบ          ณ rastreabilidade dos lancamentos contabeis. Mesmo processo  บฑฑ
ฑฑบ          ณ do PE CTBGRV, que nใo foi utilizado nesta rotina (FINA340) บฑฑ
ฑฑบ          ณ pois na execu็ใo do CTBGRV o titulo ja esta                บฑฑ
ฑฑบ          ณ cancelado / desposionado                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ-----------------------------------------------------------------------บฑฑ
ฑฑณREVISAO   ณSAG II    บ Autor ณ Leonardo Rios      บ Data ณ  03/04/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณDescri็ใo ณ Regra de neg๓cio criada para ap๓s a gera็ใo da compensa็ใo บฑฑ
ฑฑณ			 ณ do tํtulo do tipo PA/NDF irแ atualizar o valor do campo    บฑฑ
ฑฑณ			 ณ STATUS_PRC como 'P' da tabela SGFIN010 intermediแria entre บฑฑ
ฑฑณ			 ณ Protheus X Edata utilizando como chave o campo E2_XRECORI  บฑฑ
ฑฑณ			 ณ do SE2(Tํtulos)com o CODIGENE(SGFIN010)					  บฑฑ 	   
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ FINA340 - Tํtulo				     				      	  บฑฑ
ฑฑณ		     ณ Ponto de Entrada executado ap๓s a compensa็ใo dos tํtulos  บฑฑ
ฑฑณ		     ณ Projeto SAG II										      บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณChamado   ณ048554 || OS 049834 || CONTROLADORIA || LUIZ || 8451		  บฑฑ
ฑฑณ		     ณ || INDEXADORES - FWNM - 16/04/2019                         บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

User Function F340GRV()

	Local nOpcA := paramixb[1] // Ricardo Lima - 14/03/18
	
	/* Vแriแveis para conexใo entre a base de produ็ใo e a base intermediแria */
	//Local _cNomBco1 := GetPvProfString("INTSAGBD","BCO1","ERROR",GetADV97())
	//Local _cSrvBco1 := GetPvProfString("INTSAGBD","SRV1","ERROR",GetADV97())
	//Local _cPortBco1:= Val(GetPvProfString("INTSAGBD","PRT1","ERROR",GetADV97()) )
	// Local _cNomBco2 := GetPvProfString("INTSAGBD","BCO2","ERROR",GetADV97())
	// Local _cSrvBco2 := GetPvProfString("INTSAGBD","SRV2","ERROR",GetADV97())
	// Local _cPortBco2:= Val(GetPvProfString("INTSAGBD","PRT2","ERROR",GetADV97()))
	// Local _nTcConn1 := advConnection()
	// Local _nTcConn2 := 0
	
	//If cEmpAnt <> "01"
	If .not. cEmpAnt $ "01 02 "    //Alterado por Adriana em 21/08/2018 para atender empresa CERES - chamado 043263
		Return
	Endif
	    if nOpcA = 1 // Ricardo Lima - 14/03/18
			If !EMPTY(ALLTRIM(SE2->E2_XRECORI))  //Alterado por Adriana em 29/08/2017 chamado 036906
				// TcConType("TCPIP")
				// If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2)) < 0
				// 	MsgInfo("Nใo foi possํvel  conectar ao banco integra็ใo para ajustar a tabela SGFIN010, verifique com administrador","ERROR")
				// EndIf
				//TcSetConn(_nTcConn2)		
				// Ricardo Lima - 14/03/18
				TcSqlExec("UPDATE SGFIN010 SET STATUS_INT='S', STATUS_PRC = 'P', E2_MSEXP ='" +DTOS(DDATABASE)+ "' WHERE CODIGENE= '" + ALLTRIM(SE2->E2_XRECORI) + "' " )
				//TcUnLink(_nTcConn2)
				//TcSetConn(_nTcConn1)
			EndIf
	    Endif	
	
	// Chamado n. 048554 || OS 049834 || CONTROLADORIA || LUIZ || 8451 || INDEXADORES - FWNM - 16/04/2019
	/*
	_chaveCT2 := CT2->CT2_FILIAL+DTOS(CT2->CT2_DATA)+CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC
	  
	dbSelectArea("CT2")
	dbSetOrder(1)
	dbGoTop() 
	dbSeek(_chaveCT2)
	While !Eof() .and. _chaveCT2 == CT2->CT2_FILIAL+DTOS(CT2->CT2_DATA)+CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC
	
		Reclock("CT2",.F.)
		If Alltrim(SE2->E2_TIPO) $ "PA/NDF"
			CT2->CT2_FILKEY := SE5->E5_FILIAL
			CT2->CT2_PREFIX := SE5->E5_PREFIXO
			CT2->CT2_NUMDOC := SE5->E5_NUMERO
			CT2->CT2_PARCEL := SE5->E5_PARCELA
			CT2->CT2_TIPODC := SE5->E5_TIPO
			CT2->CT2_CLIFOR := SE5->E5_CLIFOR
			CT2->CT2_LOJACF := SE5->E5_LOJA
		Else
			CT2->CT2_FILKEY := SE2->E2_FILIAL
			CT2->CT2_PREFIX := SE2->E2_PREFIXO
			CT2->CT2_NUMDOC := SE2->E2_NUM
			CT2->CT2_PARCEL := SE2->E2_PARCELA
			CT2->CT2_TIPODC := SE2->E2_TIPO
			CT2->CT2_CLIFOR := SE2->E2_FORNECE
			CT2->CT2_LOJACF := SE2->E2_LOJA	
		Endif	
		MsUnlock()
			
		CT2->(dbSkip())
	Enddo		
	*/
	//

Return
