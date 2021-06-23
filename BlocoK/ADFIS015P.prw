#INCLUDE "Protheus.ch"
#INCLUDE "TBICONN.ch"
#INCLUDE "PROTDEF.CH"
#INCLUDE "rwmake.ch"

/*/{Protheus.doc} User Function ADFIS015P
	Fun��o principal para integra��o de OP/Consumo/Produ��o para Ra��o e Pinto de 1 dia
	@type  Function
	@author Leonardo Rios
	@since 14/12/16
	@param aParam[1]  	:[C] _cIniFil    - C�digo da filial inicial para ser usado no processamento
	@param aParam[2]  	:[C] _cFimFil    - C�digo da filial final para ser usado no processamento
	@param aParam[3]  	:[L] lJOb    	 - Indica se ir� usar o job (.T.) ou n�o (.F.)
	@param aParam[4]  	:[A] aParamDat	 - Array com as datas de inicio e fim para serem usadas no processamento
	@param aParam[4,1] 	:[D] aParamDat[1]- Data de in�cio para ser usada no processamento
	@param aParam[4,2] 	:[D] aParamDat[2]- Data final para ser usada no processamento
	@param aParam[5]  	:[A] aParams	 - Array com as informa��es a serem processadas do item
	@param aParam[5,1] 	:[C] aParams[1]	 - Filial da OP
	@param aParam[5,2] 	:[C] aParams[2]	 - Produto da OP
	@param aParam[5,3] 	:[N] aParams[3]	 - Quantidade do produto da OP
	@param aParam[5,4] 	:[C] aParams[4]	 - Local do Produto da OP
	@param aParam[5,5] 	:[C] aParams[5]	 - Centro de custo do produto da OP
	@param aParam[5,6] 	:[D] aParams[6]	 - Data emiss�o da OP
	@param aParam[5,7] 	:[C] aParams[7]	 - N�mero da OP
	@param aParam[5,8] 	:[C] aParams[8]	 - Item da OP
	@param aParam[5,9] 	:[C] aParams[9]	 - Sequ�ncia da OP
	@param aParam[5,10]	:[C] aParams[10] - Revis�o da OP
	@param aParam[6]  	:[L] lEstorno	 - True(.T.) caso seja um estorno, ou False(.F.) caso contr�rio
	@version version
	@return [L] - Retorna o valor estatico e default True(.T.)
	@history CHAMADO T.I  - WILLIAM COSTA     - 14/11/2019 - ALTERADO O CAMPO DE C2_FILIAL ERRADO PARA D3_FILIAL CORRETO
	@history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s
	https://tdn.totvs.com/pages/viewpage.action?pageId=271843449#:~:text=A%20abertura%20de%20uma%20transa%C3%A7%C3%A3o,para%20depois%20do%20END%20TRANSACTION%20.
	https://tdn.totvs.com/pages/viewpage.action?pageId=271843449
	https://tdn.totvs.com/display/public/PROT/BEGIN+TRANSACTION
	https://centraldeatendimento.totvs.com/hc/pt-br/articles/360020775851-MP-ADVPL-BEGIN-TRANSACTION
/*/
User function ADFIS015P(cIniFil, cFimFil, lJob, aParamDat, aParams, lEstorno)

	Local aArea		:= GetArea()
	Local aErroLog 	:= ""

	Local lRet    	:= .T.

	Local cAliasOP	:= GetNextAlias()
	Local cAliasOPR	:= ""
	Local cCodiGene	:= ""
	Local cErro		:= ""
	Local cFilBack	:= cFilAnt
	Local cMsgError := ""
	Local cNumOP	:= ""
	Local cQry		:= ""

	Local nQtdeTot	:= 0
	Local nRecno	:= 0
	Local nRecno2	:= 0
	Local nRecOPR	:= 0
	Local nRecXOpr	:= 0

	Private lMsErroAuto	:= .F.

	Private _aDatas		:= {}
	Private _aParametr	:= {}
	Private _cFilIni 	:= ""
	Private _cFilFim 	:= ""
	Private _dData		:= DDATABASE
	Private _xJob		:= .T.

	/* Vari�veis para conex�o entre os banco do Protheus e o banco intermedi�rio */
	// Private _cNomBco1   := ""
	// Private _cSrvBco1   := ""
	// Private _cPortBco1  := ""
	// Private _nTcConn1	:= AdvConnection()
	// Private _cNomBco2   := ""
	// Private _cSrvBco2   := ""
	// Private _cPortBco2  := ""
	// Private _nTcConn2	:= 0

	Default cIniFil		:= ""  /*Descri��o do par�metro conforme cabe�alho*/
	Default cFimFil		:= ""  /*Descri��o do par�metro conforme cabe�alho*/
	Default lJob 		:= .T. /*Descri��o do par�metro conforme cabe�alho*/
	Default aParamDat	:= {}  /*Descri��o do par�metro conforme cabe�alho*/
	Default aParams		:= {}  /*Descri��o do par�metro conforme cabe�alho*/
	Default lEstorno	:= .F. /*Descri��o do par�metro conforme cabe�alho*/
	Default _MsgMotivo 	:= "" /*Esta vari�vel est� criada no fonte ADFIS005P como privada e por precau��o est� sendo criada caso este fonte tenha sido chamado por outro fonte que n�o seja o ADFIS005P*/


	_cFilIni	:= cIniFil
	_cFilFim	:= cFimFil
	_aDatas 	:= aParamDat
	_aParametr 	:= aParams

	_xJob := lJob

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun��o principal para integra��o de OP/Consumo/Produ��o para Ra��o e Pinto de 1 dia')

	// @history Fernando Macieira, 05/03/2021, Ticket 10248. Revis�o das rotinas de apontamento de OP�s
	// Garanto uma �nica thread sendo executada
	If !LockByName("ADFIS015P", .T., .F.)
		Aviso("Aten��o", "Existe outro processamento sendo executado! Verifique com seu colega de trabalho...", {"OK"}, 3)
		Return .F.
	EndIf
	//
	
	/*Dados e vari�veis para controle de conex�o entre o banco de dados do Protheus e o banco intermedi�rio*/
	// _cNomBco1  := GetPvProfString("INTSAGBD","BCO1","ERROR",GetADV97())
	// _cSrvBco1  := GetPvProfString("INTSAGBD","SRV1","ERROR",GetADV97())
	// _cPortBco1 := Val(GetPvProfString("INTSAGBD","PRT1","ERROR",GetADV97()) )
	// _cNomBco2  := GetPvProfString("INTSAGBD","BCO2","ERROR",GetADV97())
	// _cSrvBco2  := GetPvProfString("INTSAGBD","SRV2","ERROR",GetADV97())
	// _cPortBco2 := Val(GetPvProfString("INTSAGBD","PRT2","ERROR",GetADV97()))
	
	// If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2)) < 0
	// 	lRet     := .F.
	// 	cMsgError := "N�o foi poss�vel  conectar ao banco integra��o"
	// 	MsgInfo("N�o foi poss�vel  conectar ao banco integra��o, verifique com administrador","ERROR")
		
	// EndIf
	
	// TcSetConn(_nTcConn2)
	
	/*Esses updates sao para que a inclusao ocorra antes da exclusao porque a ordem de inclusao das OPs n�o vem certa do SAG*/	
	If !_xJob
		TcSqlExec("update SGOPR010 SET C2_ORDSEP = '1' WHERE OPERACAO_INT = 'I' AND C2_ORDSEP = ' ' AND C2_FILIAL BETWEEN '" + _cFilIni + "' AND '" + _cFilFim + "'")
		TcSqlExec("update SGOPR010 SET C2_ORDSEP = '2' WHERE OPERACAO_INT = 'E' AND C2_ORDSEP = ' ' AND C2_FILIAL BETWEEN '" + _cFilIni + "' AND '" + _cFilFim + "'")
		TcSqlExec("update SGOPR010 SET C2_ORDSEP = '3' WHERE OPERACAO_INT = 'A' AND C2_ORDSEP = ' ' AND C2_FILIAL BETWEEN '" + _cFilIni + "' AND '" + _cFilFim + "'")
		TcSqlExec("update SGREQ010 SET D3_PARCTOT = '1' WHERE OPERACAO_INT = 'I' AND D3_PARCTOT = ' ' AND D3_FILIAL BETWEEN '" + _cFilIni + "' AND '" + _cFilFim + "'") // CHAMADO T.I WILLIAM COSTA - 14/11/2019 - ALTERADO O CAMPO DE C2_FILIAL ERRADO PARA D3_FILIAL CORRETO
		TcSqlExec("update SGREQ010 SET D3_PARCTOT = '2' WHERE OPERACAO_INT = 'E' AND D3_PARCTOT = ' ' AND D3_FILIAL BETWEEN '" + _cFilIni + "' AND '" + _cFilFim + "'") // CHAMADO T.I WILLIAM COSTA - 14/11/2019 - ALTERADO O CAMPO DE C2_FILIAL ERRADO PARA D3_FILIAL CORRETO
	Else
		TcSqlExec("update SGOPR010 SET C2_ORDSEP = '1' WHERE OPERACAO_INT = 'I' AND C2_ORDSEP = ' '")
		TcSqlExec("update SGOPR010 SET C2_ORDSEP = '2' WHERE OPERACAO_INT = 'E' AND C2_ORDSEP = ' '")
		TcSqlExec("update SGOPR010 SET C2_ORDSEP = '3' WHERE OPERACAO_INT = 'A' AND C2_ORDSEP = ' '")
		TcSqlExec("update SGREQ010 SET D3_PARCTOT = '1' WHERE OPERACAO_INT = 'I' AND D3_PARCTOT = ' '")
		TcSqlExec("update SGREQ010 SET D3_PARCTOT = '2' WHERE OPERACAO_INT = 'E' AND D3_PARCTOT = ' '")
	EndIf
	
	/* seleciona OPs de ra��o e Pinto*/
	cQry := "SELECT * FROM SGOPR010 (NOLOCK) WHERE ( TABEGENE IN ('INGETRAM','INGEOVOS','POCAMVES','MPCALOTE') AND C2_MSEXP='' OR "
	cQry += " ( TABEGENE IN ('INGETRAM','INGEOVOS','POCAMVES','MPCALOTE') AND C2_MSEXP<> '' AND  STATUS_INT='E' )) "

	If  !_xJob
		cQry += " AND C2_FILIAL BETWEEN '" + _cFilIni + "' AND '" + _cFilFim + "' AND C2_EMISSAO BETWEEN '" + _aDatas[1] + "' AND '" + _aDatas[2] + "' "
		
		If Len(_aParametr) > 0
			cQry += " AND C2_NUM='" + _aParametr[7] + "' AND C2_ITEM='" + _aParametr[8] + "' AND  C2_SEQUEN='" + _aParametr[9] + "' AND C2_PRODUTO= '" + _aParametr[2] + "' "
		EndIf
	EndIf
	
	cQry += " ORDER BY C2_FILIAL,CODIGENE,C2_ORDSEP "
	
	DbUseArea(.t., "TOPCONN", TcGenQry(,, cQry), cAliasOP, .F., .T.)
	
	TcSetField( cAliasOP, "C2_DATPRI", "D", 8, 0 )
	TcSetField( cAliasOP, "C2_DATPRF", "D", 8, 0 )
	TcSetField( cAliasOP, "C2_EMISSAO", "D", 8, 0 )
	TcSetField( cAliasOP, "C2_DATRF", "D", 8, 0 )
	TcSetField( cAliasOP, "C2_DATAJI", "D", 8, 0 )
	TcSetField( cAliasOP, "C2_DATAJF", "D", 8, 0 )
	TcSetField( cAliasOP, "C2_DTUPROG", "D", 8, 0 )
	TcSetField( cAliasOP, "C2_QTUPROG", "D", 8, 0 )
	
	
	/* Vai apagar de uma vez as OPs que foram incluidas e canceladas, deixando s� os registros de inclusao*/
	dbGotop()
	cCodiGene := ""
	nRecno 	 := 0
	While !(cAliasOP)->(Eof())
		If (cAliasOP)->OPERACAO_INT == "I"
			
			cCodiGene := (cAliasOP)->CODIGENE
			nRecno    := (cAliasOP)->R_E_C_N_O_
			
			dbSkip()
			If (cAliasOP)->OPERACAO_INT == "E"
				If cCodiGene == (cAliasOP)->CODIGENE
					/*Se a OP foi incluida e Excluida cancelo os dois movimentos para nao processar no protheus*/
					nRecno2 := (cAliasOP)->R_E_C_N_O_
					
					If !_xJob
						TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='S' WHERE R_E_C_N_O_=" + ALLTRIM( STR(nRecno) ) + " AND OPERACAO_INT='I' AND C2_FILIAL = '" + (cAliasOP)->C2_FILIAL + "'")
						TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='S' WHERE R_E_C_N_O_=" + ALLTRIM( STR(nRecno2) ) + " AND OPERACAO_INT='E' AND C2_FILIAL = '" + (cAliasOP)->C2_FILIAL + "'")
					Else
						TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='S' WHERE R_E_C_N_O_=" + ALLTRIM( STR(nRecno) ) + " AND OPERACAO_INT='I' ")
						TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='S' WHERE R_E_C_N_O_=" + ALLTRIM( STR(nRecno2) ) + " AND OPERACAO_INT='E' ")
					EndIf
				EndIf
			Else
				go nRecno
			EndIf
		EndIf
		dbSkip()
	End
	(cAliasOP)->(DbCloseArea())
	
	cQry := "SELECT * FROM SGOPR010 (NOLOCK) WHERE (TABEGENE IN ('INGETRAM','INGEOVOS','POCAMVES','MPCALOTE') AND D_E_L_E_T_=' ' AND "
	
	If !lEstorno 
		cQry += " C2_MSEXP='' " 
	Else
		cQry += " C2_MSEXP<>'' " 
	EndIf
	
	cQry += " OR ( TABEGENE IN ('INGETRAM','INGEOVOS','POCAMVES','MPCALOTE') AND C2_MSEXP<> '' AND STATUS_INT='E' )) 
	

	
	If !_xJob
		cQry += " AND C2_FILIAL BETWEEN '" + _cFilIni + "' AND '" + _cFilFim + "' AND C2_EMISSAO BETWEEN '" + _aDatas[1] + "' AND '" + _aDatas[2] + "' "
		
		If Len(_aParametr) > 0
			cQry += " AND C2_NUM='" + _aParametr[7] + "' AND C2_ITEM='" + _aParametr[8] + "' AND  C2_SEQUEN='" + _aParametr[9] + "' AND C2_PRODUTO= '" + _aParametr[2] + "' "
		EndIf	
	EndIf
	
	cQry += " ORDER BY C2_FILIAL,CODIGENE,C2_ORDSEP "
	
//	cQry:="SELECT * FROM SGOPR010 WHERE C2_PRODUTO <> '300042' AND C2_MSEXP='' ORDER BY C2_FILIAL,CODIGENE,C2_ORDSEP "
	cAliasOPR := GetNextAlias()
	DbUseArea(.t., "TOPCONN", TcGenQry(,, cQry), cAliasOPR, .F., .T.)
	
	TcSetField( cAliasOPR, "C2_DATPRI", "D", 8, 0 )
	TcSetField( cAliasOPR, "C2_DATPRF", "D", 8, 0 )
	
	
	dbGotop()
	While !(cAliasOPR)->(Eof())
		
		nRecXOpr  := R_E_C_N_O_
		nQtdeTot := (cAliasOPR)->C2_QUANT
		
		If nQtdeTot <= 0 
			dbSkip()
			Loop
		EndIf
		
		If (cAliasOPR)->OPERACAO_INT == "E" .OR. lEstorno
			
			If !FwInTTSBreak() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s

				//Begin Transaction // analiseFWNM

					nRecOPR := R_E_C_N_O_
					cNumOP  := (cAliasOPR)->C2_NUM + (cAliasOPR)->C2_ITEM + (cAliasOPR)->C2_SEQUEN
			
					If ( lRet := CancOPRa(cAliasOPR) ) //, (cAliasOPR)->C2_NUM, (cAliasOPR)->C2_ITEM, nQtdeTot)
			
						If ( lRet := IncluiOP (cAliasOPR, nQtdeTot, 5) ) /*Executa a fun��o, mas mandando a condi��o 5(exclus�o no ExecAuto da OP)*/
							
							DDATABASE := _dData
							
							U_CCSGrvLog("ok", "OPR", 0, 3, (cAliasOPR)->C2_FILIAL)
							
							//TcSetConn(_nTcConn2)
							
							If lEstorno
	//							TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP=' ', STATUS_INT=' ', OPERACAO_INT='A' WHERE R_E_C_N_O_= " + ALLTRIM(STR(nRecOPR)) + " AND C2_FILIAL = '" + (cAliasOPR)->C2_FILIAL + "' ")
	//							TcSqlExec("UPDATE SGREQ010 SET D3_MSEXP=' ', STATUS_INT=' ', OPERACAO_INT='A' WHERE D3_FILIAL = '" + (cAliasOPR)->C2_FILIAL + "' AND SGREQ010.D3_OP = '" + cNumOP + "' ")
							Else
								If !_xJob
									TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='S' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecOPR)) + " AND OPERACAO_INT='E' AND C2_FILIAL = '" + (cAliasOPR)->C2_FILIAL + "' AND D_E_L_E_T_=' ' ")
								Else
									TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='S' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecOPR)) + " AND OPERACAO_INT='E' AND D_E_L_E_T_=' ' ")
								EndIf
							EndIf
						
						Else
						
							_MsgMotivo += "(Problema no estorno da Ordem de Produ��o) "

							// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s
							DisarmTransaction() 
							//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
							//

						EndIf
					
					Else

						_MsgMotivo += "(Problema no estorno das Movimenta��es de Produ��o)"

						// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s
						DisarmTransaction() 
						//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
						//

					EndIf
				
				//End Transaction // analiseFWNM

				MsUnLockAll() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s

			EndIf
			
		ElseIf (cAliasOPR)->OPERACAO_INT == "I" .AND. !lEstorno
		
			If !FwInTTSBreak() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s

				// Begin Transaction // analiseFWNM

					nRecOPR := R_E_C_N_O_
					
					If ( lRet := IncOPRa( cAliasOPR, (cAliasOPR)->C2_NUM, "01", nQtdeTot, nRecOPR, (cAliasOPR)->C2_FILIAL ) )

						If ( lRet := InReqRa( (cAliasOPR)->C2_NUM+(cAliasOPR)->C2_ITEM+(cAliasOPR)->C2_SEQUEN, (cAliasOPR)->C2_FILIAL ) )
							
							cErro := ""
							
							If !( lRet := InPrdRA( @cErro, (cAliasOPR)->C2_FILIAL, nRecOPR, (cAliasOPR)->C2_FILIAL, cAliasOPR) )
								
								_MsgMotivo += "(Problema no Apontamento da Produ��o). "

								DDATABASE := _dData
								U_CCSGrvLog(cErro, "OPR", 0, 3, (cAliasOPR)->C2_FILIAL)
								//TcSetConn(_nTcConn2)
								_MsgMotivo += cErro
								
								If !_xJob
									TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+cErro+ "' WHERE R_E_C_N_O_=" + ALLTRIM( STR(nRecOPR) ) + " AND OPERACAO_INT='I' AND C2_FILIAL = '" + (cAliasOPR)->C2_FILIAL + "' AND D_E_L_E_T_=' ' ")
								Else
									TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+cErro+ "' WHERE R_E_C_N_O_=" + ALLTRIM( Str(nRecOPR) ) + " AND OPERACAO_INT='I' AND D_E_L_E_T_=' ' ")
								EndIf

								// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s
								DisarmTransaction() 
								//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
								//

							EndIf
							
						Else
							
							cErro := "Erro na requisicao de insumos"
							_MsgMotivo += "(Erro na requisicao de insumos) "
							
							DDATABASE := _dData
							
							U_CCSGrvLog(cErro, "OPR", 0, 3, (cAliasOPR)->C2_FILIAL)
							
							//TcSetConn(_nTcConn2)
							TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='" + cErro + "' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecOPR)) + " AND OPERACAO_INT='I' AND D_E_L_E_T_=' ' ")

							// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s							
							DisarmTransaction() 
							//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
							//

						EndIf
					
					Else
					
						_MsgMotivo += "(Problema na Cria��o da Ordem de Produ��o)"
						
						// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s							
						DisarmTransaction() 
						//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
						//
					
					EndIf

				//End Transaction // analiseFWNM

				MsUnLockAll() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s

			EndIf
		
		EndIf
	
		//TcSetConn(_nTcConn2)
		
		go nRecXOpr
		
		(cAliasOPR)->(DbSkip())
		
	EndDo
	
	(cAliasOPR)->(DbCloseArea())
	
	// TcUnLink(_nTcConn2) 
	
	// ////TcSetConn(_nTcConn1) //ajuste fabricio 06/03/18
	
	MsUnlockAll() //ajuste fabricio 06/03/18
		
	cFilAnt := cFilBack//cFilBkp
	
	DDATABASE := _dData
	
	RestArea(aArea)

	//��������������������������������������?
	//�Destrava a rotina para o usu�rio	    ?
	//��������������������������������������?
	UnLockByName("ADFIS015P") // @history Fernando Macieira, 05/03/2021, Ticket 10248. Revis�o das rotinas de apontamento de OP�s

Return lRet

/*/{Protheus.doc} Static Function IncOPRa
	Fun��o para incluir as Ordens de Produ��o de Ra��o e Pinto de 1 dia
	@type  Function
	@author Leonardo Rios
	@since 14/12/16
	@param aParam[1]  	:[C] cAliasOPR 	- Alias da da query sendo exucutada com as OP
	@param aParam[2]  	:[C] cNumOP    	- C�digo da OP
	@param aParam[3]  	:[C] cItem		- C�digo do item da OP
	@param aParam[4]  	:[N] nQtdeTot	- Quantideda total da OP
	@param aParam[5]  	:[N] nRecOPR	- C�digo RECNO da OP
	@param aParam[6]  	:[C] cFili		- C�digo da filial da OP
	@version version
	@return lRet [L] - Retorna o se foi executado com sucesso a inclus�o da OP(.T.) ou n�o (.F.)
/*/
Static Function IncOPRa(cAliasOPR, cNumOP, cItem, nQtdeTot, nRecOPR, cFili)

	Local aAuto		:= {}
	Local aErroLog	:= {}

	Local cChaveOP	:= ""
	Local cCod		:= ""
	Local cErro		:= {}
	Local cFilBkp	:= ""
	Local cFilOPR	:= ""

	Local dData 	:= DDATABASE

	Local nRecB1	:= 0

	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile	:= .T.

	Default cAliasOPR	:= "" /*Descri��o do par�metro conforme cabe�alho*/
	Default cNumOP		:= "" /*Descri��o do par�metro conforme cabe�alho*/
	Default cItem		:= "" /*Descri��o do par�metro conforme cabe�alho*/
	Default nQtdeTot	:= 0  /*Descri��o do par�metro conforme cabe�alho*/
	Default nRecOPR		:= 0  /*Descri��o do par�metro conforme cabe�alho*/
	Default cFili		:= "" /*Descri��o do par�metro conforme cabe�alho*/

	cFilBkp 	:= cFilAnt
	cCod		:= (cAliasOPR)->C2_PRODUTO
	DDATABASE	:= (cAliasOPR)->C2_DATPRI
	cFilAnt		:= (cAliasOPR)->C2_FILIAL
	nRecB1		:= (cAliasOPR)->R_E_C_N_O_

	////TcSetConn(_nTcConn1)

	dbSelectArea("SB1")
	dbSetOrder(1)  // B1_FILIAL+B1_COD
	dbSeek(xFilial("SB1") + cCod)
	If Eof()

		////TcSetConn(_nTcConn2)

		cErro := "OPR - Produto nao cadastrado no Protheus "+cCod
		_MsgMotivo += cErro
		TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='" + cErro + "' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecB1)) + " AND OPERACAO_INT='I' AND C2_FILIAL = '" + cFili + "' AND D_E_L_E_T_=' ' ")

		// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s
		DisarmTransaction() 
		//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
		//

		Return .f.

	EndIf

	////TcSetConn(_nTcConn2)

	cFilAnt	:= (cAliasOPR)->C2_FILIAL
		
	If (cAliasOPR)->C2_DatPrf < dDataBase
		dData := dDataBase
	Else
		dData := (cAliasOPR)->C2_DATPRF
	EndIf

	cChaveOP := (cAliasOPR)->C2_NUM + (cAliasOPR)->C2_ITEM + (cAliasOPR)->C2_SEQUEN
	aAuto := {  {"C2_FILIAL"       , cFilAnt			 	            						, Nil},;
				{"C2_NUM"          , (cAliasOPR)->C2_NUM	            						, .F.},;
				{"C2_ITEM"         , (cAliasOPR)->C2_ITEM		           						, Nil},;
				{"C2_SEQUEN"       , (cAliasOPR)->C2_SEQUEN										, Nil},;
				{"C2_PRODUTO"      , (cAliasOPR)->C2_PRODUTO	        						, Nil},;
				{"C2_LOCAL"        , (cAliasOPR)->C2_LOCAL										, Nil},;
				{"C2_CC"           , iIf(Empty((cAliasOPR)->C2_CC),'2201',(cAliasOPR)->C2_CC)	, Nil},;      // EST� FIXO MAIS PRECISAR� SER REVISTO...
				{"C2_QUANT"        , nQtdeTot			                						, Nil},;
				{"C2_UM"           , SB1->B1_UM                         						, Nil},;
				{"C2_DATPRI"       , (cAliasOPR)->C2_DATPRI             						, Nil},;
				{"C2_DATPRF"       , dData				                						, Nil},;
				{"C2_EMISSAO"      , DDATABASE		                    						, Nil},;
				{"C2_TPOP"         , "F"                              							, Nil},;				
				{"C2_REVISAO"      , (cAliasOPR)->C2_REVISAO            						, Nil},;				
				{"AUTEXPLODE"      , "S"                                						, Nil}	}

	cFilOPR	  := (cAliasOPR)->C2_Filial
		
	////TcSetConn(_nTcConn1)

	SB1->(dbSetOrder(1))  // B1_FILIAL+B1_COD
	SB1->(dbSeek(xFilial("SB1") + cCod))

	lMsErroAuto := .F.

	/* verifica se a OP ja existe, se existir altera a quantidade da OP e dos Empenhos somando a nota quantidade da batida*/
	dbSelectArea("SC2")
	dbSetOrder(1)
	dbSeek(xFilial("SC2")+cChaveOP)
	If !Eof()

		_MsgMotivo += "(OP j� existe no Protheus). "

		// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s
		DisarmTransaction() 
		//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
		//

		Return .T.

	Else
		
		/*ABERTURA DA OP*/
		MsAguarde({|| MSExecAuto({|x,y| MATA650(x,y)}, aAuto, 3) },"Execauto MATA650","Incluindo OP... " + cChaveOP )
		//MSExecAuto({|x,y| MATA650(x,y)}, aAuto, 3)  // 3 - Inclus�o, 4 - Altera��o e 5 - Exclus�o
		
		dbSelectArea("SC2")
		dbSetOrder(1)
		dbSeek(xFilial("SC2") + cChaveOP)
		If !Eof()
			lMsErroAuto := .F.
		EndIf
		
		If lMsErroAuto
		
			aErroLog := GetAutoGrLog()
			cErro 	 := ""
			For k := 1 to Len(aErroLog)
				If "INVALIDO" $ UPPER (aErroLog[k])
					cErro += Alltrim(aErroLog[k])
				EndIf
			Next			
		
			DDATABASE := dData
			
			If EMPTY( ALLTRIM( cErro ) )
				cErro += ADFIS015PA() + ".   "
			EndIf
		
			U_CCSGrvLog(cErro, "OPR", 0, 3, cFilOPR)
			
			_MsgMotivo += cErro
		
			////TcSetConn(_nTcConn2)
		
			TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='" + cErro + "' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecOPR)) + " AND OPERACAO_INT='I' AND C2_FILIAL= '" + cFili + "' AND D_E_L_E_T_=' ' ")
	//			TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+cErro+ "' WHERE C2_NUM = '"+cNumOp+"' AND C2_ITEM = '"+cItem+"' AND OPERACAO_INT='I' ")
		
			lRet := .F.

			// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s
			DisarmTransaction() 
			//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
			//

		Else

			DDATABASE := dData
			
			////TcSetConn(_nTcConn2)
			TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='S' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecOPR)) + " AND OPERACAO_INT='I' AND C2_FILIAL = '" + cFili + "' AND D_E_L_E_T_=' ' ")

			lRet := .T.

		EndIf

	EndIf

	MsUnlockAll() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s

Return lRet

/*/{Protheus.doc} Static Function InReqRa
	Fun��o para integra��o dos movimentos da tabela REQ relacionados a OP passado via par�metro
	@type  Function
	@author Leonardo Rios
	@since 16/12/16
	@param aParam[1]  	:[C] cOP    	- C�digo da OPa ser processada
	@param aParam[2]  	:[C] cFil   	- C�digo da filial a ser feito o processamento
	@param aParam[3]  	:[C] cItem		- C�digo do item da OP
	@param aParam[4]  	:[N] nQtdeTot	- Quantideda total da OP
	@param aParam[5]  	:[N] nRecOPR	- C�digo RECNO da OP
	@param aParam[6]  	:[C] cFili		- C�digo da filial da OP
	@version version
	@return lRet [L] - Retorna o se foi executado com sucesso a inclus�o da movimenta��o(.T.) ou n�o (.F.)
/*/
Static Function InReqRa(cOP, cFil)

	Local aArea     	:= GetArea()
	Local aErroLog   	:= ""
	Local aCampos		:= {}

	Local cAliasREQ		:= GetNextAlias()
	Local cCod			:= ""
	Local cCodiGene		:= ""
	Local cErro			:= ""
	Local cFilBkp		:= ""
	Local cFilREQ		:= ""
	Local cLocal		:= ""
	Local cMov			:= ""
	Local cNumseq		:= ""
	Local cOPReq		:= ""
	Local cProd			:= ""
	Local cQry			:= ""
	Local cTM       	:= Alltrim(GetMv('MV_XTMREQ',.F., "510"))  // cTM 510 bx op atu emp  // cTM 520 bx op sem atu emp
	Local aCabec        := {}  
	Local aitens	    := {}
	Local aTotitem      := {}
			

	Local dInicio 		:= (GetMv("MV_ULMES")+1)
	Local lRet      	:= .T.
	Local nQuant		:= ""
	Local nRecREQ		:= ""

	Private lMsErroAuto 	:= .F.          
	//Private lMsHelpAuto	:= .F.
	Private lAutoErrNoFile	:= .T.

	Default cOP 	:= "" /*Descri��o do par�metro conforme cabe�alho*/
	Default cFil	:= "" /*Descri��o do par�metro conforme cabe�alho*/


	cFilBkp := cFilAnt
	cOp := lTrim(cOP)

	/*Selectiona os movimentos de requisi��o e devolu��o para a OP*/
	////TcSetConn(_nTcConn2)
	cQry:="SELECT * FROM SGREQ010 (NOLOCK) WHERE (D3_MSEXP='' AND D3_OP = '" + cOP + "' OR ( D3_MSEXP<>'' AND D3_OP = '" + cOP + "' AND  STATUS_INT='E' )) "
	
	If !_xJob
		cQry += " AND D3_FILIAL BETWEEN '" + _cFilIni + "' AND '" + _cFilFim + "' AND D3_EMISSAO BETWEEN '" + _aDatas[1] + "' AND '" + _aDatas[2] + "' "
	EndIf
	
	cQry += " AND D_E_L_E_T_ = ' ' "
	cQry += " ORDER BY D3_OP,CODIGENE,D3_PARCTOT"
	
	DbUseArea(.t., "TOPCONN", TcGenQry(,, cQry), cAliasREQ, .F., .T.)
	TcSetField( cAliasREQ, "D3_EMISSAO", "D", 8, 0 )
			
	While !(cAliasREQ)->(Eof())
		
		////TcSetConn(_nTcConn1)
	
		cProd := (cAliasREQ)->D3_COD
	
		aItens	 := {}
		aCabec   := {}  
		aTotitem := {}
		
		
		
		/*vai determinar o local pelo centro de custos 21 22 23 24 ou 05 se nao tiver CC informado 
		se a filial for 04 passa para 03 caso contrario mantem a filial*/		
//		cLocal  := iIf((AllTrim((cAliasREQ)->D3_FILIAL)) == "04",SubStr(AllTrim((cAliasREQ)->D3_CC),3,2),cLocPad)
		cLocal  := (cAliasREQ)->D3_LOCAL

		
		/*muda de filial 04 para 03 pq o matarial esta na 03*/
		cFilAnt := (cAliasREQ)->D3_FILIAL
		cFilREQ := (cAliasREQ)->D3_FILIAL
		
//		nRecREQ := (cAliasREQ)->R_E_C_N_O_
		cMov	:= (cAliasREQ)->OPERACAO_INT
		cCod	:= (cAliasREQ)->D3_COD
		If (cAliasREQ)->OPERACAO_INT == "I"
		
			cCod := (cAliasREQ)->D3_COD
	
			/*tratamento para criar armazem no SB2 - destino 25*/
			dbSelectARea("SB2")
			dbSetOrder(1)
			If !SB2->(DbSeek( xFilial("SB2") + cCod + cLocal ))
				CriaSB2(cCod, cLocal)
			EndIf
			
			

			nQuant := (cAliasREQ)->D3_QUANT			
			
			aCabec := { {"D3_TM" ,(cAliasREQ)->D3_TM , NIL},;
						{"D3_EMISSAO" ,(cAliasREQ)->D3_EMISSAO, NIL}} 

			AADD(aItens, {"D3_FILIAL"	,cFilAnt													, Nil})
			AADD(aItens, {"D3_COD"		,(cAliasREQ)->D3_COD										, Nil})
			AADD(aItens, {"D3_QUANT"	,nQuant														, Nil})
			AADD(aItens, {"D3_LOCAL"	,(cAliasREQ)->D3_LOCAL										, Nil})
			AADD(aItens, {"D3_CC"		,iIf(Empty((cAliasREQ)->D3_CC),"5121",(cAliasREQ)->D3_CC) 	, Nil})
			AADD(aItens, {"D3_OP"		,cOp														, Nil})
			AADD(aItens, {"D3_RECORI"	,StrZero((cAliasREQ)->R_E_C_N_O_,10)						, Nil})
			AADD(aItens, {"D3_CODIGEN"	,StrZero((cAliasREQ)->CODIGENE,9)							, Nil})
			
			If (cAliasREQ)->D3_TM =="700"
				AADD(aItens, {"D3_CUSTO1"		,(cAliasREQ)->D3_CUSTO1								, Nil})		
			EndIf
			
			nRecREQ   := (cAliasREQ)->R_E_C_N_O_
			
		Else
			
			cCodiGene := StrZero((cAliasREQ)->CODIGENE,9)
//			cOPReq	  := (cAliasREQ)->D3_OP
			cOPReq	  := cOp
			cCod	  := (cAliasREQ)->D3_COD
			nRecREQ   := (cAliasREQ)->R_E_C_N_O_
			If Len(cOPReq) == 11
				cOPReq := cOPReq + Space(2)
			EndIf
			
			dbSelectArea("SD3")
			dbSetNickname("CODIGENE")
			dbSetOrder(1)
			dbSeek(cFilAnt + cCodiGene + cOPReq)
//			dbSeek(cFilAnt + cOPReq)
			If !Eof() .And. SD3->D3_ESTORNO <> "S"
			
				aCabec := { {"D3_TM" ,(cAliasREQ)->D3_TM , NIL},;
							{"D3_EMISSAO" ,(cAliasREQ)->D3_EMISSAO, NIL}} 

				AADD(aItens, {"D3_FILIAL"	,D3_FILIAL		, Nil})
				AADD(aItens, {"D3_COD"		,D3_COD			, Nil})
				AADD(aItens, {"D3_QUANT"	,D3_QUANT		, Nil})
				AADD(aItens, {"D3_LOCAL"	,D3_LOCAL		, Nil})
				AADD(aItens, {"D3_CC"		,D3_CC 			, Nil})
				AADD(aItens, {"D3_OP"		,D3_OP	  		, Nil})
				AADD(aItens, {"D3_DOC"		,D3_DOC			, Nil})
				AADD(aItens, {"D3_NUMSEQ"	,D3_NUMSEQ		, Nil})				
			Else

				U_CCSGrvLog("Registro nao encontrado para estornar ", "REQ", nRecREQ, 3, cFilREQ)
			
				////TcSetConn(_nTcConn2)
				TcSqlExec("UPDATE SGREQ010 SET D3_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='Registro nao encontrado para estornar' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecREQ)) + " AND D3_FILIAL = '" + cFilAnt + "' ")
//				TcSqlExec("UPDATE SGREQ010 SET D3_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='Registro nao encontrado para estornar' WHERE SUBSTRING(D3_OP,1,6) = '" +cOP+"' AND D3_MSEXP='' AND OPERACAO_INT = 'E' AND D3_COD = '"+cCod+"'")
				
				DbSelectArea(cAliasREQ)
				(cAliasREQ)->(DbSkip())
				Loop
			EndIf
		EndIf
		
		SF5->(dbSetOrder(1))  // B1_FILIAL+B1_COD
		SF5->(dbSeek(xFilial("SF5") + cTM))
		
		/*se a data de emissao for menor que a data de fechamento, nao faz e flega log*/
		If (cAliasREQ)->D3_EMISSAO < dInicio

			U_CCSGrvLog("Data do movimento menor que a data de fechamento ", "REQ", nRecREQ, 3, cFilREQ)
			
			////TcSetConn(_nTcConn2)
			TcSqlExec("UPDATE SGREQ010 SET D3_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+"Data do movimento menor que a data de fechamento " + "' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecREQ)) + " AND D3_FILIAL = '" + cFilAnt + "' ")
//			TcSqlExec("UPDATE SGREQ010 SET D3_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='Data do movimento menor que a data de fechamento' WHERE SUBSTRING(D3_OP,1,6) = '" +cOP+"' AND D3_MSEXP='' AND OPERACAO_INT = 'E' AND D3_COD = '"+cCod+"'")
			
			DbSelectArea(cAliasREQ)
			(cAliasREQ)->(DbSkip())
			Loop
		EndIf
		
		/*se a quantidade for igual a zero nao faz a requisi��o, flega log*/
		nRecREQ := (cAliasREQ)->R_E_C_N_O_
		
		If (cAliasREQ)->D3_QUANT == 0 .AND. (cAliasREQ)->D3_TM <> "700"

			U_CCSGrvLog("Requisicao com quantidade zero", "REQ", nRecREQ, 3, cFilREQ)
			
			////TcSetConn(_nTcConn2)
			TcSqlExec("UPDATE SGREQ010 SET D3_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='Requisicao com quantidade zero' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecREQ)) + " AND D3_FILIAL = '" + cFilAnt + "' ")
//			TcSqlExec("UPDATE SGREQ010 SET D3_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='Requisicao com quantidade zero ' WHERE SUBSTRING(D3_OP,1,6) = '" +cOP+"' AND D3_MSEXP='' AND OPERACAO_INT = 'E' AND D3_COD = '"+cCod+"'")
			
			DbSelectArea(cAliasREQ)
			(cAliasREQ)->(DbSkip())
			Loop
		EndIf
		
		lMsErroAuto := .F.
		
//		Begin Transaction // inibido pois j� est� dentro de um begin - @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s
		
		aadd(aTotitem,aItens) 

		If cMov == "E"
			MsAguarde({|| MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabec,aTotitem,6) },"Execauto MATA241","Estornando requisi��o... " + cOp + " " + ALLTRIM(STR(nRecREQ)) )
			//MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabec,aTotitem,6)
			//MSExecAuto({|x,y| MATA240(x,y)}, aCampos, 5) // Estorna a Requisi��o
		Else
			MsAguarde({|| MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabec,aTotitem,3) },"Execauto MATA241","Incluindo requisi��o... " + cOp + " " + ALLTRIM(STR(nRecREQ)) )
			//MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabec,aTotitem,3)
			//MSExecAuto({|x,y| MATA240(x,y)}, aCampos, 3) // Inclui a Requisi��o
		EndIf
		
		If lMsErroAuto

			lRet := .F.
			
			aErroLog := GetAutoGrLog()
//			cErro := ""
			For k := 1 to Len(aErroLog)
				If "INVALIDO" $ UPPER (aErroLog[k]) .AND. !(aErroLog[k] $ cErro)
					cErro+= Alltrim(aErroLog[k])
				EndIf
			Next
			
			If EMPTY( ALLTRIM( cErro ) )
				cErro += ADFIS015PA() + ".   "
			EndIf
			
			U_CCSGrvLog(cErro, "REQ", 0, 3, cFilREQ)
			
			If !(cErro $ _MsgMotivo)
				_MsgMotivo += cErro
			EndIf
						
			////TcSetConn(_nTcConn2)
			TcSqlExec("UPDATE SGREQ010 SET D3_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='" + cErro + "' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecREQ)) + " AND D3_FILIAL = '" + cFilAnt + "' ")
//			TcSqlExec("UPDATE SGREQ010 SET D3_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+cErro+ "'  WHERE SUBSTRING(D3_OP,1,6) = '" +cOP+"' AND D3_MSEXP='' AND OPERACAO_INT = 'E' AND D3_COD = '"+cCod+"'")

			// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s
			DisarmTransaction() 
			//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
			//
			
		Else
			////TcSetConn(_nTcConn2)
			TcSqlExec("UPDATE SGREQ010 SET D3_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='S' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecREQ)) + " AND D3_FILIAL = '" + cFilAnt + "' ")
//			TcSqlExec("UPDATE SGREQ010 SET D3_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='S' WHERE SUBSTRING(D3_OP,1,6) = '" +cOP+"' AND D3_MSEXP='' AND OPERACAO_INT = 'E' AND D3_COD = '"+cCod+"'")
		EndIf
		
//		End Transaction // inibido pois j� est� dentro de um begin - @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s
		
		DbSelectArea(cAliasREQ)
		(cAliasREQ)->(DbSkip())
	EndDo
	
	(cAliasREQ)->(DbCloseArea())
	
	RestArea(aArea)
	
	cFilAnt := cFilBkp
	
	MsUnlockAll() //ajuste fabricio 06/03/18

Return lRet

/*/{Protheus.doc} Static Function InPrdRA
	Fun��o para integra��o da produ��o e apontamento da produ��o de ra��o e pinto de 1 dia
	@type  Function
	@author Leonardo Rios
	@since 16/12/16
	@param aParam[1]  	:[C] cErro    	- Vari�vel para capturar o erro gerado e salvar no log
	@param aParam[2]  	:[C] cFil    	- C�digo da filial para ser usado no processamento
	@param aParam[3]  	:[N] nRecOPR    - C�digo do RECNO da OP para ser usado no processamento
	@param aParam[4]  	:[C] cFilOPR    - C�digo da filial da OP para ser usado no processamento
	@param aParam[5]  	:[C] cAliasOPR  - Alias com a OP para ser usado para pegar os dados da OP no processamento
	@version version
	@return lRet [L] - Retorna o se foi executado com sucesso o apontamento da OP(.T.) ou n�o (.F.)
/*/
Static Function InPrdRA(cErro, cFil, nRecOPR, cFilOPR, cAliasOPR)

	Local aAuto     := Nil
	Local aErroLog	:= {}
	Local aSavAre   := GetArea()

	Local cCCC2		:= ""
	Local cFilBkp	:= ""
	Local cItem		:= ""
	Local cLocalC2 	:= ""
	Local cProdC2	:= ""
	Local cRefTrf	:= ""
	Local cTM       := Alltrim(GetMv('MV_XTMPRD',.F., "010"))   		//Tm para movimenta��o

	Local cNumOP	:= ""
	Local cSequen	:= ""


	Local dData		:= DDATABASE
	Local dDataC2
	Local dDtProd
	Local dMaxData

	Local lRet      := .F.

	Local nQuantC2  := 0
	Local cNumseq	:= ""

	Private lMsErroAuto 	:= .F.

	Default cErro 		:= "" /*Descri��o do par�metro conforme cabe�alho*/
	Default cFil 		:= "" /*Descri��o do par�metro conforme cabe�alho*/
	Default nRecOPR 	:= 0  /*Descri��o do par�metro conforme cabe�alho*/
	Default cFilOPR 	:= "" /*Descri��o do par�metro conforme cabe�alho*/
	Default cAliasOPR 	:= "" /*Descri��o do par�metro conforme cabe�alho*/

	
	////TcSetConn(_nTcConn1)

	cFilBkp := cFilAnt             
	
	cFilAnt := cFil
	
	nQuantC2	:= SC2->C2_QUANT - SC2->C2_QUJE
	cLocalC2	:= SC2->C2_LOCAL
	cProdC2		:= SC2->C2_PRODUTO
	cRefTrf		:= SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
	cCCC2		:= SC2->C2_CC
	dDataC2		:= SC2->C2_DATPRF
	cNumOP		:= SC2->(C2_NUM)
	cItem		:= SC2->(C2_ITEM)
	DDATABASE	:= (cAliasOPR)->C2_DATPRI
	
	aAuto := {	{"D3_OP"           , SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD), Nil}, ;
				{"D3_TM"           , cTM				                       , Nil}, ;
				{"D3_COD"          , SC2->C2_PRODUTO                           , Nil}, ;
				{"D3_QUANT"        , SC2->C2_QUANT-SC2->C2_QUJE                , Nil}, ;
				{"D3_LOCAL"        , SC2->C2_LOCAL                             , Nil}, ;
				{"D3_EMISSAO"      , SC2->C2_DATPRF	                           , Nil}, ;
				{"D3_CC"           , SC2->C2_CC                                , Nil}, ;
				{"D3_RECORI"       , StrZero(nRecOPR,10)        		  	   , Nil}}
	
	lMsErroAuto := .F.

	MsAguarde({|| MSExecAuto({|x,y| MATA250(x,y)}, aAuto, 3) },"Execauto MATA250","Incluindo apontamento de produ��o... " + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) )
	//MSExecAuto({|x,y| MATA250(x,y)}, aAuto, 3)  // 3 - Inclus�o, 4 - Altera��o e 5 - Exclus�o
					
	If lMsErroAuto
		aErroLog := GetAutoGrLog()
		cErro := ""
		For k := 1 to Len(aErroLog)
			If "INVALIDO" $ UPPER (aErroLog[k])
				cErro+= Alltrim(aErroLog[k])
			EndIf
		Next
		
		If EMPTY( ALLTRIM( cErro ) )
			cErro += ADFIS015PA() + ".   "
		EndIf
		
		cErro := "Producao " + rTrim(cErro) + cRefTrf
		
		U_CCSGrvLog(cErro, "OPR", nRecOPR, 3, cFil)
		
		_MsgMotivo += cErro

		// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s
		DisarmTransaction() 
		//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
		//
			
	Else

		lRet := .T.
	
		////TcSetConn(_nTcConn2)
		TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='S' WHERE R_E_C_N_O_=" + ALLTRIM( STR(nRecOPR) ) + " AND OPERACAO_INT='I' AND C2_FILIAL = '" + cFil + "'")

	Endif

	////TcSetConn(_nTcConn1)

	MsUnlockAll() //ajuste fabricio 06/03/18

	cFilAnt := cFilBkp
	
	RestArea(aSavAre)

	lRet := .T.                         
	
	DDATABASE := dData

Return(lRet)

/*/{Protheus.doc} Static Function CancOPRa
	Fun��o para cancelar as OP's passadas pelo Alias do arquivo e cancelar os movimentos relacionados a ela
	@type  Function
	@author Leonardo Rios
	@since 16/12/16
	@param aParam[1]  	:[C] cAliasOPR    - cAlias com a OP para ser usado para pegar os dados da OP no processamento
	@version version
	@return lRet [L] - Retorna o se foi cancelado a OP com sucesso(.T.) ou n�o (.F.)	
/*/
Static Function CancOPRa(cAliasOPR)

	Local aArea     := GetArea()
	Local aErroLog	:= ""

	Local cCod		:= ""
	Local cErro		:= ""
	Local cFilBkp	:= cFilAnt
	Local cFilOPR	:= ""
	Local cLocal	:= ""
	Local cOP		:= ""
	Local cProdC2	:= ""
	Local cRevisao	:= ""

	Local dData		:= DDATABASE

	Local lLogCanc	:= .T.
	Local lRet     	:= .T.

	Local nRecOPR	:= 0
	Local nRecSD3	:= 0

	Private lMsErroAuto := .F.

	Default cAliasOPR 	:= "" /*Descri��o do par�metro conforme cabe�alho*/


	cFilBkp := cFilAnt
	
	lMsErroAuto	:= .F.
	
	////TcSetConn(_nTcConn2)
	
	cCod 	  := (cAliasOPR)->C2_Produto
	DDATABASE := (cAliasOPR)->C2_DatPri
	cFilAnt   := (cAliasOPR)->C2_Filial
	cOp 	  := (cAliasOPR)->(C2_NUM+C2_ITEM+C2_SEQUEN)
	cFilOPR	  := (cAliasOPR)->C2_Filial
	cProdC2	  := (cAliasOPR)->C2_Produto
	nRecOPR	  := (cAliasOPR)->R_E_C_N_O_
	
	
	If ALLTRIM((cAliasOPR)->C2_LOCAL) == "04"
		cLocal := SubStr(AllTrim((cAliasOPR)->D3_CC),3,2)
	Else
		////TcSetConn(_nTcConn1)
		cLocal := RetFldProd((cAliasOPR)->C2_PRODUTO,"B1_LOCPAD")
		////TcSetConn(_nTcConn2)
	EndIf
	cLocal    := IIf(Empty(cLocal), "05", cLocal)
	
	cFilAnt	  := (cAliasOPR)->C2_FILIAL
	
	If AllTrim((cAliasOPR)->C2_FILIAL) == "04" //TODO: VERIFICAR O MOTIVO DE EXISTIR A VARIAVEL cRevisao
		cFilAnt := "03" /*muda da filial 04 para 03 para abrir a OP*/
		If cLocal == "21" .Or. cLocal == "05"
			cRevisao := "1  "
		ElseIf cLocal == "22"
			cRevisao := "2  "
		ElseIf cLocal == "23"
			cRevisao := "3  "
		ElseIf cLocal == "24"
			cRevisao := "4  "
		EndIf
	Else
		cRevisao := Space(3)
	EndIf
	
	cFilOPR := cFilAnt
	
	////TcSetConn(_nTcConn1)
	
	/*vai apagar o movimento de produ��o da OP*/
	dbSelectArea("SD3")
	dbSetOrder(1)
	dbSeek(cFilOPR + cOp) /*deve ser sempre a OP Pai*/
	If Eof()
		lRet := .F.
		cErro := "Movimento de Produ��o nao encontrada para cancelar"
		
		U_CCSGrvLog(cErro, "OPR", nRecOPR, 5, cFilOPR)
		
		_MsgMotivo += cErro
		
		////TcSetConn(_nTcConn2)
		
//		TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+cErro+ "' WHERE R_E_C_N_O_="+AllTrim(Str(nRecOPR))+" AND OPERACAO_INT='E' ")
//		TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='" + cErro + "' WHERE C2_NUM = '" + cOP + "' AND OPERACAO_INT='E' AND C2_FILIAL = '" + cFilAnt + "' ")

		// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s
		DisarmTransaction() 
		//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
		//

	Else
		
		/*Roda o SD3 procurando o movimento de Produ��o para cancelar*/
		dbSeek(cFilOPR + cOp)
		While !Eof() .And. rTrim(SD3->D3_OP) == rTrim(cOp) /*um While para estar certo de que todos os PIs que a OP tenham tido estarao apagados*/
			If SubStr(SD3->D3_CF,1,2) <> "PR"
				dbSkip()
				Loop
			EndIf
			
			dbSelectArea("SD3")
			/*Efetua cancelamento do apontamento de produ��o*/
			cErro:=""
			lLogCanc := InPrdeRA(@cErro, cFilAnt)
			
			If lLogCanc  /*Cancelou*/
				/* Tem que fazer isso porque a OP nao pode ser excluida nesse momento pois ainda tem que excluir os movimentos do SD3
				 na leitura do arquivo de integra��o SGREQ010, se escluir aqui vai dar erro na exclusao do movimento PRO do SD3*/
				dbSelectArea("SC2")
				dbSetOrder(1)
				dbSeek(cFilOPR + SD3->D3_OP)
				If !Eof()
					RecLock("SC2",.F.)
						SC2->C2_FLCANC := "S"
					MsUnLock()
					fkCommit() // 		// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s
				EndIf
							
			Else /*nao cancelou*/
//				DisarmTransaction()
				
				DDATABASE := dData
				
				U_CCSGrvLog(cErro, "OPR", nRecOPR, 5, cFilOPR)
				_MsgMotivo += cErro
				
				////TcSetConn(_nTcConn2)
//				TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='" + cErro + "' WHERE C2_NUM = '" + cOP + "' AND OPERACAO_INT='E'  AND C2_FILIAL = '" + cFilAnt + "' ")
				lRet := .F.
			EndIf
			dbSelectArea("SD3")
			go nRecSD3
			dbSkip()
		End
		
		/*Roda o SD3 cancelando todos os movimentos de requisi��o*/
		////TcSetConn(_nTcConn1)
		dbgotop()      
		dbSelectArea("SD3")
		dbSetOrder(1)
		dbSeek(cFilOPR + cOp)
		While !Eof() .And. rTrim(SD3->D3_OP) == rTrim(cOp)  /*um While para estar certo de que todos os PIs que a OP tenham tido estarao apagados*/
			If SD3->D3_ESTORNO == "S" .Or. SubStr(SD3->D3_CF,1,2) == "PR"
				dbSkip()
				Loop
			Else
				nRecSD3 := Recno()
				CancReq()
				dbSelectArea("SD3")
				go nRecSD3
			EndIf
			dbSkip()
		End
		
	EndIf
	
	cFilAnt := cFilBkp
	
	DDATABASE := dData
	
	RestArea(aArea)

	MsUnLockAll() // 		// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s

Return lRet

/*/{Protheus.doc} Static Function CancOPRa
	Fun��o para integra��o de cancelamento de produ��o. O controle de transa��o � feito pela rotina chamadora, por isso n�o tem o Begin Transaction
	@type  Function
	@author Leonardo Rios
	@since 16/12/16
	@param aParam[1]  	:[C] cErro    	- Vari�vel para capturar o erro gerado e salvar no log
	@param aParam[2]  	:[C] cFilAnt   	- C�digo da filial para ser usado no processamento
	@version version
	@return lRet [L] - Retorna o valor estatico e default True(.T.)
/*/

Static Function InPrdeRA(cErro, cFilAnt)

	Local aAuto   := Nil
	Local aErroLog:= {}
	Local aSavAre := GetArea()

	Local cFilBkp := ""
	Local cOPLog  := SD3->D3_OP
	Local cTMLog  := SD3->D3_TM
	Local cCodLog := SD3->D3_COD

	Local lRet    := .F.

	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile	:= .T.

	cFilBkp := cFilAnt
	
	////TcSetConn(_nTcConn1)
	
	aAuto := {	{"D3_FILIAL"       , SD3->D3_FILIAL         , Nil}, ;
				{"D3_TM"           , SD3->D3_TM		        , Nil}, ;
				{"D3_COD"          , SD3->D3_COD            , Nil}, ;
				{"D3_QUANT"        , SD3->D3_QUANT          , Nil}, ;
				{"D3_OP"           , SD3->D3_OP				, Nil}, ;
				{"D3_LOCAL"        , SD3->D3_LOCAL          , Nil}, ;
				{"D3_EMISSAO"      , SD3->D3_EMISSAO        , Nil}, ;
				{"D3_CC"           , SD3->D3_CC             , Nil}, ;
				{"D3_DOC"          , SD3->D3_DOC            , Nil}, ;
				{"D3_PARCTOT"      , SD3->D3_PARCTOT        , Nil}	 }
	
	lMsErroAuto := .F.
	
	MsAguarde({|| MSExecAuto({|x,y| MATA250(x,y)}, aAuto, 5) },"Execauto MATA250","Excluindo apontamento produ��o... " + SD3->D3_OP )
	//MSExecAuto({|x,y| MATA250(x,y)}, aAuto, 5)  // 3 - Inclus�o, 4 - Altera��o e 5 - Exclus�o
	
	If lMsErroAuto
		_MsgMotivo += "(Erro na movimenta��o para o TM=" + ALLTRIM(cTMLog) + "; OP=" + ALLTRIM(cOPLog) + "; COD=" + ALLTRIM(cCodLog) + "). "
		aErroLog:=GetAutoGrLog()
		cErro:=""
		For k:=1 to Len(aErroLog)
			If "INVALIDO" $ UPPER (aErroLog[k])
				cErro+= Alltrim(aErroLog[k])
			EndIf
		Next

		If EMPTY( ALLTRIM( cErro ) )
			cErro += ADFIS015PA() + ".   "
		EndIf

		_MsgMotivo += cErro

		// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s
		DisarmTransaction() 
		//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
		//

	Else
		lRet := .T.
	Endif
	
	cFilAnt := cFilBkp
	
	RestArea(aSavAre)

	MsUnLockAll() 		// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s

Return(lRet)

/*/{Protheus.doc} Static Function CancReq
	Fun��o para cancelar todas as requisi��es efetuadas para a OP independente de ter vindo pela interface ou n�o
	@type  Function
	@author Leonardo Rios
	@since 16/12/16
	@version version
/*/

Static Function CancReq()

	Local aArea     := GetArea()
	Local aCampos	:= {}
	Local aItens	 := {}
	Local aCabec   := {}  
	Local aTotitem := {}

	Private lMsErroAuto 	:= .F.

 	aCabec := { {"D3_TM" ,SD3->D3_TM , NIL},;
   			    {"D3_EMISSAO" ,SD3->D3_EMISSAO, NIL}} 

	AADD(aItens, {"D3_FILIAL"	,SD3->D3_FILIAL		, Nil})
	AADD(aItens, {"D3_COD"		,SD3->D3_COD			, Nil})
	AADD(aItens, {"D3_QUANT"	,SD3->D3_QUANT		, Nil})
	AADD(aItens, {"D3_LOCAL"	,SD3->D3_LOCAL		, Nil})
	AADD(aItens, {"D3_CC"		,SD3->D3_CC 			, Nil})
	AADD(aItens, {"D3_OP"		,SD3->D3_OP	  		, Nil})
	AADD(aItens, {"D3_DOC"		,SD3->D3_DOC			, Nil})
	AADD(aItens, {"D3_NUMSEQ"	,SD3->D3_NUMSEQ		, Nil})				

	aadd(aTotitem,aItens) 
		
	lMsErroAuto := .f.
	
	//MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabec,aTotitem,6)
	MsAguarde({|| MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabec,aTotitem,6) },"Execauto MATA241","Efetuando movimenta��es m�ltiplas... " + SD3->D3_OP + " " + SD3->D3_COD )
	
	If lMsErroAuto

		_MsgMotivo += "(Erro na requisi��o para o TM=" + ALLTRIM(D3_TM) + "; OP=" + ALLTRIM(D3_OP) + "; COD=" + ALLTRIM(D3_COD) + "). "
		
		aErroLog:=GetAutoGrLog()
		
		cErro:=""
		For k:=1 to Len(aErroLog)
			If "INVALIDO" $ UPPER (aErroLog[k])
				cErro+= Alltrim(aErroLog[k])
			EndIf
		Next

		If EMPTY( ALLTRIM( cErro ) )
			cErro += ADFIS015PA() + ".   "
		EndIf

		_MsgMotivo += cErro

		MostraErro()
	Endif
	
	RestArea(aArea)

Return()

/*/{Protheus.doc} Static Function A250VerReq
	Fun��o para ver a maior data de requisi��o para a OP
	@type  Function
	@author Leonardo Rios
	@param aParam[1]  	:[C] cOP    - C�digo da OP
	@param aParam[2]  	:[D] dData  - Data M�xima para c�lculo
	@since 16/12/16
	@version version
	@return lRet [L] - Retorna o valor estatico e default True(.T.) 
/*/
Static Function A250VerReq(cOP, dData)

	Local lRet := .F.
	Local aArea := GetArea()
	Local dMaxData := dData

	#IFDEF TOP
		Local cQuery := ""
		Local cAlias := "SD3"
	#ENDIF

	If !Empty(dData)
		/*
		#IFDEF TOP
		cAlias := GetNextAlias()         �
		cQuery := "SELECT MAX(D3_EMISSAO) AS D3_EMISSAO FROM " +RetSQLName("SD3") +" WHERE D3_OP = '" +cOP +"' AND "
		cQuery += "SUBSTRING(D3_CF,1,2) = 'RE' AND D3_ESTORNO <> 'S' AND D3_FILIAL = '" +xFilial("SD3") +"' AND "
		cQuery += "D3_EMISSAO > '" +DToS(dData) +"' AND D_E_L_E_T_ = ''"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)
		dbSelectArea(cAlias)
		dbGoTop()
		TcSetField( cAlias, "D3_EMISSAO", "D", 8, 0 )
		If !Empty((cAlias)->D3_EMISSAO)
		dMaxData := (cAlias)->D3_EMISSAO
		EndIf
		(cAlias)->(dbCloseArea())
		#ELSE
		*/
		/*
		dbSelectArea("SD3")
		dbSetOrder(1)
		dbSeek(xFilial("SD3")+cOP)
		While !EOF() .And. D3_FILIAL+D3_OP == xFilial("SD3")+cOP
		If Substr(D3_CF,1,2) # "RE" .Or. DToS(D3_EMISSAO) <= DToS(dData) .Or. D3_ESTORNO == "S"
		dbSkip()
		Loop
		Else
		dMaxData := SD3->D3_EMISSAO
		EndIf
		End
		//	#ENDIF
		*/
	EndIf
	
	dMaxData := DDATABASE
	RestArea(aArea)
	
Return dMaxData

/*/{Protheus.doc} Static Function IncluiOP 
	Fun��o para Incluir OP por MsExecAuto
	@type  Function
	@author Leonardo Rios
	@param aParam[1]  	:[C] cAliasOPR	- Alias da OP a ser usada no processamento
	@param aParam[2]  	:[N] nQuant	    - Quantidade da OP para ser usado no processamento
	@param aParam[3]  	:[N] nOpc  		- C�digo do tipo de opera��o a ser executado
	@since 16/12/16
	@version version
	@return lRet [L] - Retorna o valor True(.T.) se foi feito o processamento do Execauto correto ou False(.F.) caso contr�rio
/*/
Static Function IncluiOP (cAliasOPR, nQuant, nOpc)

	Local aAuto   := {}
	Local aSavAre := SaveArea1({"SB1"})

	Local cCod    := (cAliasOPR)->C2_PRODUTO
	Local cFilOP  := (cAliasOPR)->C2_FILIAL
	Local cFilBkp := ""
	Local cItem   := (cAliasOPR)->C2_ITEM
	Local cNum    := (cAliasOPR)->C2_NUM
	Local cSequen := (cAliasOPR)->C2_SEQUEN

	Local lRet    := .F.

	Private lAutoErrNoFile 	:= .T.
	Private	lMsErroAuto := .F.

	cFilBkp := cFilAnt
	cFilAnt := (cAliasOPR)->C2_FILIAL
	
	SB1->(dbSetOrder(1))  // B1_FILIAL+B1_COD
	SB1->(dbSeek(xFilial("SB1") + cCod))
	
	
	aAuto := {  {"C2_FILIAL"       , cFilOP		                        , Nil}, ;
				{"C2_PRODUTO"      , cCod		                        , Nil}, ;
				{"C2_NUM"          , cNum			                    , Nil}, ;
				{"C2_ITEM"         , cItem                              , Nil}, ;
				{"C2_SEQUEN"       , cSequen							, Nil}}

//				{"C2_LOCAL"        , RetFldProd(SB1->B1_COD,"B1_LOCPAD"), Nil}, ; 
//				{"C2_CC"           , SB1->B1_CC                         , Nil}, ;
//				{"C2_QUANT"        , nQuant		                        , Nil}, ; // ou trocar para ZZ_PBRUTO
//				{"C2_UM"           , SB1->B1_UM					        , Nil}, ;
//				{"C2_DATPRI"       , (cAliasOPR)->C2_DATPRI             , Nil}, ;
//				{"C2_DATPRF"       , (cAliasOPR)->C2_DATPRF             , Nil}, ;
//				{"C2_EMISSAO"      , (cAliasOPR)->C2_EMISSAO            , Nil}, ;
//				{"C2_TPOP"         , "F"                                , Nil}, ;
//				{"C2_REVISAO"      , ""				                    , Nil},;
//				{"AUTEXPLODE"      , "S"                                , Nil}}
	
	
	
	
		lMsErroAuto := .F.
		MsAguarde({|| MSExecAuto({|x,y| MATA650(x,y)}, aAuto, nOpc) },"Execauto MATA650","Efetuando OP... " + cNum + " " + cCod)
		//MSExecAuto({|x,y| MATA650(x,y)}, aAuto, nOpc)  // 3 - Inclus�o, 4 - Altera��o e 5 - Exclus�o

		If lMsErroAuto
//			MostraErro()
			aErroLog:=GetAutoGrLog()
			cErro:=""
			For k:=1 to Len(aErroLog)
				If "INVALIDO" $ UPPER (aErroLog[k])
					cErro+= Alltrim(aErroLog[k])
				EndIf
			Next
			
			If EMPTY( ALLTRIM( cErro ) )
				cErro += ADFIS015PA() + ".   "
			EndIf
			
			_MsgMotivo += cErro
			lMsErroAuto := .F.

			// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s
			DisarmTransaction() 
			//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
			//

		Else
			lRet := .T. 		
		Endif
	
	cFilAnt := cFilBkp
	
	RestArea1(aSavAre)

	MsUnLockAll() 			// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revis�o das rotinas de apontamento de OP�s

Return(lRet)

/*/{Protheus.doc} Static Function ADFIS015PA 
	Fun��o criada para pegar errorslog que n�o s�o mostrados no padr�o da totovs para capturar erros de execauto
	@type  Function
	@author Leonardo Rios
	@since 16/12/16
	@version version
	@return cMsg [C] - Retorna a mensagem capturada de um errorlog no Protheus
/*/
Static Function ADFIS015PA()

	Local cMsg 		:= ""
	Local cErroTemp := ""
	Local cBuffer 	:= ""
	Local cCampo 	:= ""

	Local nErrLin := 0
	Local nLinhas := 0

	cErroTemp 	:= Mostraerro("C:\","ERRORLOGPROTHEUSEDATA.log") 
	nLinhas		:=MLCount(cErroTemp) 

	cBuffer	:="" 
	cCampo	:="" 
	nErrLin	:=1 
	cBuffer	:=RTrim(MemoLine(cErroTemp,,nErrLin))                
	
	//Carrega o nome do campo 
	While (nErrLin <= nLinhas) 
	     nErrLin++ 
	     
	     cBuffer := RTrim(MemoLine(cErroTemp,,nErrLin)) 

	     If ( Upper( SubStr( cBuffer, Len(cBuffer)-7, Len(cBuffer))) == "INVALIDO") 
	          cMsg := cBuffer 
	     
//	          xTemp	:= AT("-", cBuffer) 
	     
//	          cCampo:= AllTrim( SubStr( cBuffer, xTemp + 1, AT(":",cBuffer) - xTemp -2 )) 
	     
	          Exit 
	     EndIf 
	     
	EndDo                

Return cMsg
