#INCLUDE "Protheus.ch"
#INCLUDE "TBICONN.ch"
#INCLUDE "PROTDEF.CH"
#INCLUDE "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function ADFIS015P
	Função principal para integração de OP/Consumo/Produção para Ração e Pinto de 1 dia
	@type  Function
	@author Leonardo Rios
	@since 14/12/16
	@param aParam[1]  	:[C] _cIniFil    - Código da filial inicial para ser usado no processamento
	@param aParam[2]  	:[C] _cFimFil    - Código da filial final para ser usado no processamento
	@param aParam[3]  	:[L] lJOb    	 - Indica se irá usar o job (.T.) ou não (.F.)
	@param aParam[4]  	:[A] aParamDat	 - Array com as datas de inicio e fim para serem usadas no processamento
	@param aParam[4,1] 	:[D] aParamDat[1]- Data de início para ser usada no processamento
	@param aParam[4,2] 	:[D] aParamDat[2]- Data final para ser usada no processamento
	@param aParam[5]  	:[A] aParams	 - Array com as informações a serem processadas do item
	@param aParam[5,1] 	:[C] aParams[1]	 - Filial da OP
	@param aParam[5,2] 	:[C] aParams[2]	 - Produto da OP
	@param aParam[5,3] 	:[N] aParams[3]	 - Quantidade do produto da OP
	@param aParam[5,4] 	:[C] aParams[4]	 - Local do Produto da OP
	@param aParam[5,5] 	:[C] aParams[5]	 - Centro de custo do produto da OP
	@param aParam[5,6] 	:[D] aParams[6]	 - Data emissão da OP
	@param aParam[5,7] 	:[C] aParams[7]	 - Número da OP
	@param aParam[5,8] 	:[C] aParams[8]	 - Item da OP
	@param aParam[5,9] 	:[C] aParams[9]	 - Sequência da OP
	@param aParam[5,10]	:[C] aParams[10] - Revisão da OP
	@param aParam[6]  	:[L] lEstorno	 - True(.T.) caso seja um estorno, ou False(.F.) caso contrário
	@version version
	@return [L] - Retorna o valor estatico e default True(.T.)
	@history CHAMADO T.I  - WILLIAM COSTA     - 14/11/2019 - ALTERADO O CAMPO DE C2_FILIAL ERRADO PARA D3_FILIAL CORRETO
	@history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
	@history ticket 30160 - Fernando Macieira - 29/09/2021 - Lentidão ao processar ordem
	https://tdn.totvs.com/pages/viewpage.action?pageId=271843449#:~:text=A%20abertura%20de%20uma%20transa%C3%A7%C3%A3o,para%20depois%20do%20END%20TRANSACTION%20.
	https://tdn.totvs.com/pages/viewpage.action?pageId=271843449
	https://tdn.totvs.com/display/public/PROT/BEGIN+TRANSACTION
	https://centraldeatendimento.totvs.com/hc/pt-br/articles/360020775851-MP-ADVPL-BEGIN-TRANSACTION
	@history ticket 72655 - Fernando Macieira - 10/05/2022 - Serviço de Integrado - OP Granja HH
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

	Default cIniFil		:= ""  /*Descrição do parâmetro conforme cabeçalho*/
	Default cFimFil		:= ""  /*Descrição do parâmetro conforme cabeçalho*/
	Default lJob 		:= .T. /*Descrição do parâmetro conforme cabeçalho*/
	Default aParamDat	:= {}  /*Descrição do parâmetro conforme cabeçalho*/
	Default aParams		:= {}  /*Descrição do parâmetro conforme cabeçalho*/
	Default lEstorno	:= .F. /*Descrição do parâmetro conforme cabeçalho*/
	Default _MsgMotivo 	:= "" /*Esta variável está criada no fonte ADFIS005P como privada e por precaução está sendo criada caso este fonte tenha sido chamado por outro fonte que não seja o ADFIS005P*/

	_cFilIni	:= cIniFil
	_cFilFim	:= cFimFil
	_aDatas 	:= aParamDat
	_aParametr 	:= aParams

	_xJob := lJob

	//U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Função principal para integração de OP/Consumo/Produção para Ração e Pinto de 1 dia') // @history ticket 30160 - Fernando Macieira - 29/09/2021 - Lentidão ao processar ordem

	// @history Fernando Macieira, 05/03/2021, Ticket 10248. Revisão das rotinas de apontamento de OP´s
	// Garanto uma única thread sendo executada
	/*
	If !LockByName("ADFIS015P", .T., .F.)
		Aviso("Atenção", "Existe outro processamento sendo executado! Verifique com seu colega de trabalho...", {"OK"}, 3)
		Return .F.
	EndIf
	*/
	//
	
	/*Esses updates sao para que a inclusao ocorra antes da exclusao porque a ordem de inclusao das OPs não vem certa do SAG*/	
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
	
	/* seleciona OPs de ração e Pinto*/
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
	
	/* Vai apagar de uma vez as OPs que foram incluidas e canceladas, deixando só os registros de inclusao*/
	cCodiGene := ""
	nRecno 	 := 0

	dbGotop()
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
			
			If !FwInTTSBreak() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s

				//Begin Transaction // analiseFWNM

					nRecOPR := R_E_C_N_O_
					cNumOP  := (cAliasOPR)->C2_NUM + (cAliasOPR)->C2_ITEM + (cAliasOPR)->C2_SEQUEN
			
					If ( lRet := CancOPRa(cAliasOPR) ) //, (cAliasOPR)->C2_NUM, (cAliasOPR)->C2_ITEM, nQtdeTot)
			
						If ( lRet := IncluiOP (cAliasOPR, nQtdeTot, 5) ) /*Executa a função, mas mandando a condição 5(exclusão no ExecAuto da OP)*/
							
							DDATABASE := _dData
							
							U_CCSGrvLog("ok", "OPR", 0, 3, (cAliasOPR)->C2_FILIAL)
							
							If !_xJob
								TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='S' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecOPR)) + " AND OPERACAO_INT='E' AND C2_FILIAL = '" + (cAliasOPR)->C2_FILIAL + "' AND D_E_L_E_T_=' ' ")
							Else
								TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='S' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecOPR)) + " AND OPERACAO_INT='E' AND D_E_L_E_T_=' ' ")
							EndIf
						
						Else
						
							_MsgMotivo += "(Problema no estorno da Ordem de Produção) "

							// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
							//DisarmTransaction() 
							//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
							//

						EndIf
					
					Else

						_MsgMotivo += "(Problema no estorno das Movimentações de Produção)"

						// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
						//DisarmTransaction() 
						//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
						//

					EndIf
				
				//End Transaction // analiseFWNM

				MsUnLockAll() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s

			EndIf
			
		ElseIf (cAliasOPR)->OPERACAO_INT == "I" .AND. !lEstorno
		
			If !FwInTTSBreak() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s

				// Begin Transaction // analiseFWNM

					nRecOPR := R_E_C_N_O_
					
					If ( lRet := IncOPRa( cAliasOPR, (cAliasOPR)->C2_NUM, "01", nQtdeTot, nRecOPR, (cAliasOPR)->C2_FILIAL ) )

						If ( lRet := InReqRa( (cAliasOPR)->C2_NUM+(cAliasOPR)->C2_ITEM+(cAliasOPR)->C2_SEQUEN, (cAliasOPR)->C2_FILIAL ) )
							
							cErro := ""
							
							If !( lRet := InPrdRA( @cErro, (cAliasOPR)->C2_FILIAL, nRecOPR, (cAliasOPR)->C2_FILIAL, cAliasOPR) )
								
								_MsgMotivo += "(Problema no Apontamento da Produção). "

								DDATABASE := _dData
								U_CCSGrvLog(cErro, "OPR", 0, 3, (cAliasOPR)->C2_FILIAL)
								_MsgMotivo += cErro
								
								If !_xJob
									TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+cErro+ "' WHERE R_E_C_N_O_=" + ALLTRIM( STR(nRecOPR) ) + " AND OPERACAO_INT='I' AND C2_FILIAL = '" + (cAliasOPR)->C2_FILIAL + "' AND D_E_L_E_T_=' ' ")
								Else
									TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+cErro+ "' WHERE R_E_C_N_O_=" + ALLTRIM( Str(nRecOPR) ) + " AND OPERACAO_INT='I' AND D_E_L_E_T_=' ' ")
								EndIf

								// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
								//DisarmTransaction() 
								//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
								//

							EndIf
							
						Else
							
							cErro := "Erro na requisicao de insumos"
							_MsgMotivo += "(Erro na requisicao de insumos) "
							
							DDATABASE := _dData
							
							U_CCSGrvLog(cErro, "OPR", 0, 3, (cAliasOPR)->C2_FILIAL)
							
							TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='" + cErro + "' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecOPR)) + " AND OPERACAO_INT='I' AND D_E_L_E_T_=' ' ")

							// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s							
							//DisarmTransaction() 
							//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
							//

						EndIf
					
					Else
					
						_MsgMotivo += "(Problema na Criação da Ordem de Produção)"
						
						// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s							
						//DisarmTransaction() 
						//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
						//
					
					EndIf

				//End Transaction // analiseFWNM

				MsUnLockAll() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s

			EndIf
		
		EndIf
	
		go nRecXOpr
		
		(cAliasOPR)->(DbSkip())
		
	EndDo
	
	(cAliasOPR)->(DbCloseArea())
	
	MsUnlockAll()
		
	cFilAnt := cFilBack
	
	DDATABASE := _dData
	
	RestArea(aArea)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//UnLockByName("ADFIS015P") // @history Fernando Macieira, 05/03/2021, Ticket 10248. Revisão das rotinas de apontamento de OP´s

Return lRet

/*/{Protheus.doc} Static Function IncOPRa
	Função para incluir as Ordens de Produção de Ração e Pinto de 1 dia
	@type  Function
	@author Leonardo Rios
	@since 14/12/16
	@param aParam[1]  	:[C] cAliasOPR 	- Alias da da query sendo exucutada com as OP
	@param aParam[2]  	:[C] cNumOP    	- Código da OP
	@param aParam[3]  	:[C] cItem		- Código do item da OP
	@param aParam[4]  	:[N] nQtdeTot	- Quantideda total da OP
	@param aParam[5]  	:[N] nRecOPR	- Código RECNO da OP
	@param aParam[6]  	:[C] cFili		- Código da filial da OP
	@version version
	@return lRet [L] - Retorna o se foi executado com sucesso a inclusão da OP(.T.) ou não (.F.)
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

	Default cAliasOPR	:= "" /*Descrição do parâmetro conforme cabeçalho*/
	Default cNumOP		:= "" /*Descrição do parâmetro conforme cabeçalho*/
	Default cItem		:= "" /*Descrição do parâmetro conforme cabeçalho*/
	Default nQtdeTot	:= 0  /*Descrição do parâmetro conforme cabeçalho*/
	Default nRecOPR		:= 0  /*Descrição do parâmetro conforme cabeçalho*/
	Default cFili		:= "" /*Descrição do parâmetro conforme cabeçalho*/

	cFilBkp 	:= cFilAnt
	cCod		:= (cAliasOPR)->C2_PRODUTO
	DDATABASE	:= (cAliasOPR)->C2_DATPRI
	cFilAnt		:= (cAliasOPR)->C2_FILIAL
	nRecB1		:= (cAliasOPR)->R_E_C_N_O_

	dbSelectArea("SB1")
	dbSetOrder(1)  // B1_FILIAL+B1_COD
	dbSeek(xFilial("SB1") + cCod)
	If Eof()

		cErro := "OPR - Produto nao cadastrado no Protheus "+cCod
		_MsgMotivo += cErro

		TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='" + cErro + "' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecB1)) + " AND OPERACAO_INT='I' AND C2_FILIAL = '" + cFili + "' AND D_E_L_E_T_=' ' ")

		// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
		//DisarmTransaction() 
		//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
		//

		Return .f.

	EndIf

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
				{"C2_CC"           , iIf(Empty((cAliasOPR)->C2_CC),'2201',(cAliasOPR)->C2_CC)	, Nil},;      // ESTÁ FIXO MAIS PRECISARÁ SER REVISTO...
				{"C2_QUANT"        , nQtdeTot			                						, Nil},;
				{"C2_UM"           , SB1->B1_UM                         						, Nil},;
				{"C2_DATPRI"       , (cAliasOPR)->C2_DATPRI             						, Nil},;
				{"C2_DATPRF"       , dData				                						, Nil},;
				{"C2_EMISSAO"      , DDATABASE		                    						, Nil},;
				{"C2_TPOP"         , "F"                              							, Nil},;				
				{"C2_REVISAO"      , (cAliasOPR)->C2_REVISAO            						, Nil},;				
				{"AUTEXPLODE"      , "S"                                						, Nil}	}

	cFilOPR	  := (cAliasOPR)->C2_Filial
		
	SB1->(dbSetOrder(1))  // B1_FILIAL+B1_COD
	SB1->(dbSeek(xFilial("SB1") + cCod))

	lMsErroAuto := .F.

	/* verifica se a OP ja existe, se existir altera a quantidade da OP e dos Empenhos somando a nota quantidade da batida*/
	dbSelectArea("SC2")
	dbSetOrder(1)
	dbSeek(xFilial("SC2")+cChaveOP)
	If !Eof()

		_MsgMotivo += "(OP já existe no Protheus). "

		// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
		//DisarmTransaction() 
		//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
		//

		Return .T.

	Else
		
		/*ABERTURA DA OP*/
		MsAguarde({|| MSExecAuto({|x,y| MATA650(x,y)}, aAuto, 3) },"Execauto MATA650","Incluindo OP... " + cChaveOP )
		//MSExecAuto({|x,y| MATA650(x,y)}, aAuto, 3)  // 3 - Inclusão, 4 - Alteração e 5 - Exclusão
		
		dbSelectArea("SC2")
		dbSetOrder(1)
		dbSeek(xFilial("SC2") + cChaveOP)
		If !Eof()
			lMsErroAuto := .F.
			FixZSERINT(cChaveOP) // @history ticket 72655 - Fernando Macieira - 10/05/2022 - Serviço de Integrado - OP Granja HH
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
		
			TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='" + cErro + "' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecOPR)) + " AND OPERACAO_INT='I' AND C2_FILIAL= '" + cFili + "' AND D_E_L_E_T_=' ' ")

			lRet := .F.

			// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
			//DisarmTransaction() 
			//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
			//

		Else

			DDATABASE := dData
			
			TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='S' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecOPR)) + " AND OPERACAO_INT='I' AND C2_FILIAL = '" + cFili + "' AND D_E_L_E_T_=' ' ")

			lRet := .T.

		EndIf

	EndIf

	MsUnlockAll() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s

Return lRet

/*/{Protheus.doc} Static Function InReqRa
	Função para integração dos movimentos da tabela REQ relacionados a OP passado via parâmetro
	@type  Function
	@author Leonardo Rios
	@since 16/12/16
	@param aParam[1]  	:[C] cOP    	- Código da OPa ser processada
	@param aParam[2]  	:[C] cFil   	- Código da filial a ser feito o processamento
	@param aParam[3]  	:[C] cItem		- Código do item da OP
	@param aParam[4]  	:[N] nQtdeTot	- Quantideda total da OP
	@param aParam[5]  	:[N] nRecOPR	- Código RECNO da OP
	@param aParam[6]  	:[C] cFili		- Código da filial da OP
	@version version
	@return lRet [L] - Retorna o se foi executado com sucesso a inclusão da movimentação(.T.) ou não (.F.)
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
	Private lAutoErrNoFile	:= .T.

	Default cOP 	:= "" /*Descrição do parâmetro conforme cabeçalho*/
	Default cFil	:= "" /*Descrição do parâmetro conforme cabeçalho*/

	cFilBkp := cFilAnt
	cOp := lTrim(cOP)

	/*Selectiona os movimentos de requisição e devolução para a OP*/
	cQry:="SELECT * FROM SGREQ010 (NOLOCK) WHERE (D3_MSEXP='' AND D3_OP = '" + cOP + "' OR ( D3_MSEXP<>'' AND D3_OP = '" + cOP + "' AND  STATUS_INT='E' )) "
	
	If !_xJob
		cQry += " AND D3_FILIAL BETWEEN '" + _cFilIni + "' AND '" + _cFilFim + "' AND D3_EMISSAO BETWEEN '" + _aDatas[1] + "' AND '" + _aDatas[2] + "' "
	EndIf
	
	cQry += " AND D_E_L_E_T_ = ' ' "
	cQry += " ORDER BY D3_OP,CODIGENE,D3_PARCTOT"
	
	DbUseArea(.t., "TOPCONN", TcGenQry(,, cQry), cAliasREQ, .F., .T.)
	TcSetField( cAliasREQ, "D3_EMISSAO", "D", 8, 0 )
			
	While !(cAliasREQ)->(Eof())
		
		cProd := (cAliasREQ)->D3_COD
	
		aItens	 := {}
		aCabec   := {}  
		aTotitem := {}
		
		/*vai determinar o local pelo centro de custos 21 22 23 24 ou 05 se nao tiver CC informado 
		se a filial for 04 passa para 03 caso contrario mantem a filial*/		
		cLocal  := (cAliasREQ)->D3_LOCAL
		
		/*muda de filial 04 para 03 pq o matarial esta na 03*/
		cFilAnt := (cAliasREQ)->D3_FILIAL
		cFilREQ := (cAliasREQ)->D3_FILIAL
		
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
			
				TcSqlExec("UPDATE SGREQ010 SET D3_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='Registro nao encontrado para estornar' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecREQ)) + " AND D3_FILIAL = '" + cFilAnt + "' ")
				
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
			
			TcSqlExec("UPDATE SGREQ010 SET D3_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+"Data do movimento menor que a data de fechamento " + "' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecREQ)) + " AND D3_FILIAL = '" + cFilAnt + "' ")
			
			DbSelectArea(cAliasREQ)
			(cAliasREQ)->(DbSkip())
			Loop

		EndIf
		
		/*se a quantidade for igual a zero nao faz a requisição, flega log*/
		nRecREQ := (cAliasREQ)->R_E_C_N_O_
		
		If (cAliasREQ)->D3_QUANT == 0 .AND. (cAliasREQ)->D3_TM <> "700"

			U_CCSGrvLog("Requisicao com quantidade zero", "REQ", nRecREQ, 3, cFilREQ)
			
			TcSqlExec("UPDATE SGREQ010 SET D3_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='Requisicao com quantidade zero' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecREQ)) + " AND D3_FILIAL = '" + cFilAnt + "' ")
			
			DbSelectArea(cAliasREQ)
			(cAliasREQ)->(DbSkip())
			Loop

		EndIf
		
		lMsErroAuto := .F.
		
//		Begin Transaction // inibido pois já está dentro de um begin - @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
		
		aadd(aTotitem,aItens) 

		If cMov == "E"
			//MsAguarde({|| MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabec,aTotitem,6) },"Execauto MATA241","Estornando requisição... " + cOp + " " + ALLTRIM(STR(nRecREQ)) ) // @history ticket 30160 - Fernando Macieira - 29/09/2021 - Lentidão ao processar ordem
			MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabec,aTotitem,6)
		Else
			//MsAguarde({|| MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabec,aTotitem,3) },"Execauto MATA241","Incluindo requisição... " + cOp + " " + ALLTRIM(STR(nRecREQ)) ) // @history ticket 30160 - Fernando Macieira - 29/09/2021 - Lentidão ao processar ordem
			MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabec,aTotitem,3) 
		EndIf
		
		If lMsErroAuto

			lRet := .F.
			
			aErroLog := GetAutoGrLog()
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
						
			TcSqlExec("UPDATE SGREQ010 SET D3_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='" + cErro + "' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecREQ)) + " AND D3_FILIAL = '" + cFilAnt + "' ")

			// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
			//DisarmTransaction() 
			//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
			//
			
		Else
			
			TcSqlExec("UPDATE SGREQ010 SET D3_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='S' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecREQ)) + " AND D3_FILIAL = '" + cFilAnt + "' ")

		EndIf
		
//		End Transaction // inibido pois já está dentro de um begin - @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
		
		DbSelectArea(cAliasREQ)
		(cAliasREQ)->(DbSkip())

	EndDo
	
	(cAliasREQ)->(DbCloseArea())
	
	RestArea(aArea)
	
	cFilAnt := cFilBkp
	
	MsUnlockAll() 

Return lRet

/*/{Protheus.doc} Static Function InPrdRA
	Função para integração da produção e apontamento da produção de ração e pinto de 1 dia
	@type  Function
	@author Leonardo Rios
	@since 16/12/16
	@param aParam[1]  	:[C] cErro    	- Variável para capturar o erro gerado e salvar no log
	@param aParam[2]  	:[C] cFil    	- Código da filial para ser usado no processamento
	@param aParam[3]  	:[N] nRecOPR    - Código do RECNO da OP para ser usado no processamento
	@param aParam[4]  	:[C] cFilOPR    - Código da filial da OP para ser usado no processamento
	@param aParam[5]  	:[C] cAliasOPR  - Alias com a OP para ser usado para pegar os dados da OP no processamento
	@version version
	@return lRet [L] - Retorna o se foi executado com sucesso o apontamento da OP(.T.) ou não (.F.)
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
	Local cTM       := Alltrim(GetMv('MV_XTMPRD',.F., "010"))   		//Tm para movimentação

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

	Default cErro 		:= "" /*Descrição do parâmetro conforme cabeçalho*/
	Default cFil 		:= "" /*Descrição do parâmetro conforme cabeçalho*/
	Default nRecOPR 	:= 0  /*Descrição do parâmetro conforme cabeçalho*/
	Default cFilOPR 	:= "" /*Descrição do parâmetro conforme cabeçalho*/
	Default cAliasOPR 	:= "" /*Descrição do parâmetro conforme cabeçalho*/

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

	//MsAguarde({|| MSExecAuto({|x,y| MATA250(x,y)}, aAuto, 3) },"Execauto MATA250","Incluindo apontamento de produção... " + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) ) // @history ticket 30160 - Fernando Macieira - 29/09/2021 - Lentidão ao processar ordem
	MSExecAuto({|x,y| MATA250(x,y)}, aAuto, 3)  // 3 - Inclusão, 4 - Alteração e 5 - Exclusão
					
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

		// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
		//DisarmTransaction() 
		//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
		//
			
	Else

		lRet := .T.
	
		TcSqlExec("UPDATE SGOPR010 SET C2_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='S' WHERE R_E_C_N_O_=" + ALLTRIM( STR(nRecOPR) ) + " AND OPERACAO_INT='I' AND C2_FILIAL = '" + cFil + "'")

	Endif

	MsUnlockAll()

	cFilAnt := cFilBkp
	
	RestArea(aSavAre)

	lRet := .T.                         
	
	DDATABASE := dData

Return(lRet)

/*/{Protheus.doc} Static Function CancOPRa
	Função para cancelar as OP's passadas pelo Alias do arquivo e cancelar os movimentos relacionados a ela
	@type  Function
	@author Leonardo Rios
	@since 16/12/16
	@param aParam[1]  	:[C] cAliasOPR    - cAlias com a OP para ser usado para pegar os dados da OP no processamento
	@version version
	@return lRet [L] - Retorna o se foi cancelado a OP com sucesso(.T.) ou não (.F.)	
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

	Default cAliasOPR 	:= "" /*Descrição do parâmetro conforme cabeçalho*/

	cFilBkp := cFilAnt
	
	lMsErroAuto	:= .F.
	
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
		cLocal := RetFldProd((cAliasOPR)->C2_PRODUTO,"B1_LOCPAD")
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
	
	/*vai apagar o movimento de produção da OP*/
	dbSelectArea("SD3")
	dbSetOrder(1)
	dbSeek(cFilOPR + cOp) /*deve ser sempre a OP Pai*/
	If Eof()

		lRet := .F.
		cErro := "Movimento de Produção nao encontrada para cancelar"
		
		U_CCSGrvLog(cErro, "OPR", nRecOPR, 5, cFilOPR)
		
		_MsgMotivo += cErro
		
		// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
		//DisarmTransaction() 
		//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
		//

	Else
		
		/*Roda o SD3 procurando o movimento de Produção para cancelar*/
		dbSeek(cFilOPR + cOp)
		While !Eof() .And. rTrim(SD3->D3_OP) == rTrim(cOp) /*um While para estar certo de que todos os PIs que a OP tenham tido estarao apagados*/

			If SubStr(SD3->D3_CF,1,2) <> "PR"
				dbSkip()
				Loop
			EndIf
			
			dbSelectArea("SD3")
			/*Efetua cancelamento do apontamento de produção*/
			cErro:=""
			lLogCanc := InPrdeRA(@cErro, cFilAnt)
			
			If lLogCanc  /*Cancelou*/
				/* Tem que fazer isso porque a OP nao pode ser excluida nesse momento pois ainda tem que excluir os movimentos do SD3
				 na leitura do arquivo de integração SGREQ010, se escluir aqui vai dar erro na exclusao do movimento PRO do SD3*/
				dbSelectArea("SC2")
				dbSetOrder(1)
				dbSeek(cFilOPR + SD3->D3_OP)
				If !Eof()
					RecLock("SC2",.F.)
						SC2->C2_FLCANC := "S"
					MsUnLock()
					//fkCommit() // 		// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
				EndIf
							
			Else /*nao cancelou*/
//				DisarmTransaction()
				
				DDATABASE := dData
				
				U_CCSGrvLog(cErro, "OPR", nRecOPR, 5, cFilOPR)
				_MsgMotivo += cErro
				
				lRet := .F.
			EndIf

			dbSelectArea("SD3")
			go nRecSD3
			dbSkip()

		End
		
		/*Roda o SD3 cancelando todos os movimentos de requisição*/
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

	MsUnLockAll() // 		// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s

Return lRet

/*/{Protheus.doc} Static Function CancOPRa
	Função para integração de cancelamento de produção. O controle de transação é feito pela rotina chamadora, por isso não tem o Begin Transaction
	@type  Function
	@author Leonardo Rios
	@since 16/12/16
	@param aParam[1]  	:[C] cErro    	- Variável para capturar o erro gerado e salvar no log
	@param aParam[2]  	:[C] cFilAnt   	- Código da filial para ser usado no processamento
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
	
	//MsAguarde({|| MSExecAuto({|x,y| MATA250(x,y)}, aAuto, 5) },"Execauto MATA250","Excluindo apontamento produção... " + SD3->D3_OP ) // @history ticket 30160 - Fernando Macieira - 29/09/2021 - Lentidão ao processar ordem
	MSExecAuto({|x,y| MATA250(x,y)}, aAuto, 5)  // 3 - Inclusão, 4 - Alteração e 5 - Exclusão
	
	If lMsErroAuto

		_MsgMotivo += "(Erro na movimentação para o TM=" + ALLTRIM(cTMLog) + "; OP=" + ALLTRIM(cOPLog) + "; COD=" + ALLTRIM(cCodLog) + "). "
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

		// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
		//DisarmTransaction() 
		//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
		//

	Else
		lRet := .T.
	Endif
	
	cFilAnt := cFilBkp
	
	RestArea(aSavAre)

	MsUnLockAll() 		// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s

Return(lRet)

/*/{Protheus.doc} Static Function CancReq
	Função para cancelar todas as requisições efetuadas para a OP independente de ter vindo pela interface ou não
	@type  Function
	@author Leonardo Rios
	@since 16/12/16
	@version version
/*/

Static Function CancReq()

	Local aArea    := GetArea()
	Local aCampos  := {}
	Local aItens   := {}
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
	
	MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabec,aTotitem,6)
	//MsAguarde({|| MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabec,aTotitem,6) },"Execauto MATA241","Efetuando movimentações múltiplas... " + SD3->D3_OP + " " + SD3->D3_COD ) // @history ticket 30160 - Fernando Macieira - 29/09/2021 - Lentidão ao processar ordem
	
	If lMsErroAuto

		_MsgMotivo += "(Erro na requisição para o TM=" + ALLTRIM(D3_TM) + "; OP=" + ALLTRIM(D3_OP) + "; COD=" + ALLTRIM(D3_COD) + "). "
		
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
	Função para ver a maior data de requisição para a OP
	@type  Function
	@author Leonardo Rios
	@param aParam[1]  	:[C] cOP    - Código da OP
	@param aParam[2]  	:[D] dData  - Data Máxima para cálculo
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

	dMaxData := DDATABASE

	RestArea(aArea)
	
Return dMaxData

/*/{Protheus.doc} Static Function IncluiOP 
	Função para Incluir OP por MsExecAuto
	@type  Function
	@author Leonardo Rios
	@param aParam[1]  	:[C] cAliasOPR	- Alias da OP a ser usada no processamento
	@param aParam[2]  	:[N] nQuant	    - Quantidade da OP para ser usado no processamento
	@param aParam[3]  	:[N] nOpc  		- Código do tipo de operação a ser executado
	@since 16/12/16
	@version version
	@return lRet [L] - Retorna o valor True(.T.) se foi feito o processamento do Execauto correto ou False(.F.) caso contrário
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
//				{"AUTEXPLODE"      , "S"                                , Nil}}

	lMsErroAuto := .F.
	//MsAguarde({|| MSExecAuto({|x,y| MATA650(x,y)}, aAuto, nOpc) },"Execauto MATA650","Efetuando OP... " + cNum + " " + cCod) // @history ticket 30160 - Fernando Macieira - 29/09/2021 - Lentidão ao processar ordem
	MSExecAuto({|x,y| MATA650(x,y)}, aAuto, nOpc)  // 3 - Inclusão, 4 - Alteração e 5 - Exclusão

	If lMsErroAuto

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

		// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
		//DisarmTransaction() 
		//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
		//

	Else
		lRet := .T. 		
	Endif
	
	cFilAnt := cFilBkp
	
	RestArea1(aSavAre)

	MsUnLockAll() 			// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s

Return(lRet)

/*/{Protheus.doc} Static Function ADFIS015PA 
	Função criada para pegar errorslog que não são mostrados no padrão da totovs para capturar erros de execauto
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
	nLinhas		:= MLCount(cErroTemp) 

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
	          Exit 
	     EndIf 
	     
	EndDo                

Return cMsg

/*/{Protheus.doc} Static Function FixZSERINT()
	Ao importar as ordens de produção do SAG para o Protheus, função (EXP Bloco K - SAG), precisa criar a seguinte condiçao quando for filial 0A.
	Ao fazer a importação do Frango Vivo, as OP's não podem gerar no Protheus o TM 700, produto ZSERINT - SERVICOS INTEGRADO.
	Ressaltando que essa condição vale apenas para as OP's da filial 0A.
	@type  Static Function
	@author FWNM
	@since 10/05/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 72655 - Fernando Macieira - 10/05/2022 - Serviço de Integrado - OP Granja HH
/*/
Static Function FixZSERINT(cChaveOP)

	Local aArea     := {}
	Local aAreaSD4  := {}
	Local aAreaSC2  := {}
	Local cQuery    := ""
	Local cOPSD4    := ""
	Local cNumOP 	:= Left(AllTrim(cChaveOP),6)
	Local cSequenOP	:= Right(AllTrim(cChaveOP),3)
	Local cZSERINT  := GetMV("MV_#SERINT",,"ZSERINT")
	Local cGranja0A := GetMV("MV_#GRANHH",,"0A")
	Local lZSERINT  := .f.
	
	If SC2->C2_FILIAL == cGranja0A

		lZSERINT := AllTrim(cZSERINT) $ AllTRim(SC2->C2_PRODUTO)

		If lZSERINT
		
			aArea     := GetArea()
			aAreaSD4  := SD4->( GetArea() )
			aAreaSC2  := SC2->( GetArea() )

			If Select("Work") > 0
				Work->( dbCloseArea() )
			EndIf

			cQuery := " SELECT C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO, C2_SEQPAI
			cQuery += " FROM " + RetSqlName("SC2") + " (NOLOCK)
			cQuery += " WHERE C2_FILIAL='"+FWxFilial("SC2")+"'
			cQuery += " AND C2_NUM='"+cNumOP+"'
			cQuery += " AND C2_SEQUEN<>'"+cSequenOP+"'
			cQuery += " AND C2_SEQPAI='"+cSequenOP+"'
			cQuery += " AND D_E_L_E_T_=''

			tcQuery cQuery New Alias "Work"

			Work->( dbGoTop() )
			Do While Work->( !EOF() )

				cOPSD4 := AllTrim(Work->(C2_NUM+C2_ITEM+C2_SEQUEN))

				SD4->( dbSetOrder(2) ) // D4_FILIAL, D4_OP, D4_COD, D4_LOCAL, R_E_C_N_O_, D_E_L_E_T_
				If SD4->( dbSeek(FWxFilial("SD4")+cOPSD4) )
				
					Do While SD4->( !EOF() ) .and. SD4->D4_FILIAL==FWxFilial("SD4") .and. AllTrim(SD4->D4_OP) == cOPSD4

						RecLock("SD4", .F.)
							SD4->( dbDelete() )
						SD4->( msUnLock() )

						SD4->( dbSkip() )
					
					EndDo
				
				EndIf

				// Limpo D4_OPORIG
				SD4->( dbSetOrder(4) ) // D4_FILIAL, D4_OPORIG, D4_LOTECTL, D4_NUMLOTE, R_E_C_N_O_, D_E_L_E_T_
				If SD4->( dbSeek(FWxFilial("SD4")+cOPSD4) )
					RecLock("SD4", .F.)
						SD4->D4_OPORIG := ""
					SD4->( msUnLock() )
				EndIf

				SC2->( dbSetOrder(1) ) // C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, R_E_C_N_O_, D_E_L_E_T_
				If SC2->( dbSeek(FWxFilial("SC2")+cOPSD4) )
					RecLock("SC2", .F.)
						SC2->( dbDelete() )
					SC2->( msUnLock() )
				EndIf

				Work->( dbSkip() )
			
			EndDo

			If Select("Work") > 0
				Work->( dbCloseArea() )
			EndIf

			RestArea( aArea )
			RestArea( aAreaSD4 )
			RestArea( aAreaSC2 )
		
		EndIf

	EndIf

Return
