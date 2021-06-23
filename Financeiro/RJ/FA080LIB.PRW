#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
/* Ponto de Entrada na Baixa de Titulos a Pagar */
User Function FA080LIB()
	Local lRet   := .T.
	Local aArea  := GetArea()
	Local nSaldo := 0 
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	// REALIZADO O IF PELO WILLIAM COSTA PARA AJUSTE DE BAIXA DE TITULOS RJ PELO CNAB CHAMADO 022641
	IF cEmpAnt                  == "01"  .AND. ;
	   xFilial("SE2")           == '01'  .AND. ;
	   Alltrim(SE2->E2_PREFIXO) == "ADR" .AND. ;
	   Alltrim(SE2->E2_TIPO)    == "RJ"
	   
	   nSaldo := (SE2->E2_VALOR - SE2->E2_SALDO)
	
		&& Atualizacao Itens Obrigacoes Pagar
		cQuery := " UPDATE " + RETSQLNAME("ZAF") + "" 
		cQuery += " SET   ZAF_BAIXA  = '" + Dtos(dBaixa) + "'," 
		cQuery += "       ZAF_LEGEND = 'B' "             + "," 
		cQuery += "       ZAF_SALDO  = " + STR(nSaldo) + " " 
		cQuery += " WHERE D_E_L_E_T_ <> '*' " 
		cQuery += "   AND ZAF_FILIAL  = '" + XFILIAL("ZAF")  + "'"   
		cQuery += "   AND ZAF_NUMERO  = '" + SE2->E2_NUM     + "'"
		cQuery += "   AND ZAF_PARCEL  = '" + SE2->E2_PARCELA + "'"
		cQuery += "   AND ZAF_PREFIX  = 'ADR' "
		cQuery += "   AND ZAF_SALDO   > 0 "
		
		tcSqlExec(cQuery)
		tcSqlExec('commit')
		
		&& Atualiza cabecalho das obrigacoes
			
		cQuery := " SELECT SUM(ZAF_SALDO) AS SALDO "
		cQuery += " FROM " + RetSqlName("ZAF") + "  "
		cQuery += " WHERE ZAF_NUMERO  = '" + SE2->E2_NUM + "'  " 
		cQuery += "   AND D_E_L_E_T_ <> '*' "
			
		tcQuery cQuery New Alias "TOLD"
			
		nSaldoZF := TOLD->SALDO
			
		TOLD->(dbCLoseArea())
		
		
		&& Atualizar ZAH com os novos valores
		cQuery := " UPDATE " + RETSQLNAME("ZAH") + " SET " 
		cQuery += " ZAH_SALDO = " + STR( nSaldoZF ) + "  "
		cQuery += " WHERE D_E_L_E_T_ <> '*' "
		cQuery += " AND ZAH_FILIAL    = '" + XFILIAL("ZAH") + "'  " 	
		cQuery += " AND ZAH_NUMERO	  = '" + SE2->E2_NUM + "'  " 	
	    cQuery += " AND ZAH_SALDO     > 0  "
    	
		tcSqlExec(cQuery)
		tcSqlExec('commit')	
	
	ENDIF  	
	
	RestArea(aArea)
Return(lRet)