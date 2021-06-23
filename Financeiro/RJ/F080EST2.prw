#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
/* Ponto de Entrada no Cancelamento da Baixa de Titulos a Pagar */
User Function F080EST2
	Local lRet := .T.
	Local aArea:= GetArea()
	Local nSaldo := 0
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	// REALIZADO O IF PELO WILLIAM COSTA PARA AJUSTE DE BAIXA DE TITULOS RJ PELO CNAB CHAMADO 022641
	IF cEmpAnt                  == "01"  .AND. ;
	   xFilial("SE2")           == '01'  .AND. ;
	   Alltrim(SE5->E5_PREFIXO) == "ADR" .AND. ;
	   Alltrim(SE5->E5_TIPO)    == "RJ"   
	   
	    nSaldo := SE2->E2_SALDO
	
		cQuery := " UPDATE " + RETSQLNAME("ZAF") 
		cQuery += " SET ZAF_BAIXA  = ''"             + "," 
		cQuery += "     ZAF_LEGEND = ''  "           + ","    
		cQuery += "     ZAF_SALDO  = " + STR(nSaldo) + " "
		cQuery += " WHERE D_E_L_E_T_ <> '*' " 
		cQuery += "   AND ZAF_FILIAL  = '" + XFILIAL("ZAF") + "' 
		cQuery += "   AND ZAF_NUMERO  = '" + SE2->E2_NUM + "'  "
		cQuery += "   AND ZAF_PARCEL  = '" + SE2->E2_PARCELA + "' 
		cQuery += "   AND ZAF_PREFIX  = 'ADR' " 
	
		
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
	    
    	
		tcSqlExec(cQuery)
		tcSqlExec('commit')	
	
	ENDIF
	
	RestArea(aArea)
Return(lRet)