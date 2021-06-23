#Include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 
 
/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F430BXA   ºAutor  ³  Ana Helena  º       Data ³  23/01/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PE para atualizar os titulos do contas a pagar quando      º±±
±±º          ³ o tipo = "PA"                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
 
User Function F430BXA()    

	Local aArea    	:= GetArea() 
	Local lRet     	:= .T.    
	Local nSaldoZF 	:= 0 
	Local nSaldo   	:= 0
	
	If Alltrim(SE5->E5_TIPO) == "PA"
	 
		RecLock("SE5",.F.)
	 
		SE5->E5_BENEF := Posicione("SA2",1,xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA,"A2_NREDUZ")
		SE5->E5_HISTOR := "PAGAMENTO ANTECIPADO"
	 
		SE5->(msUnlock())
	 
	Endif
	
	// REALIZADO O IF PELO WILLIAM COSTA PARA AJUSTE DE BAIXA DE TITULOS RJ PELO CNAB CHAMADO 022641
	&&Mauricio - 18/05/16 - Alterado tratamento do IF pela questão de baixar titulos do SE2 e não atualizar ZAF, por conta da filial em uso
	&&Nos testes funcionou com o BRADES.CPR e não funcionou com o BRAD_AD.CPR, arquivo retorno BRA280416.RET
	//IF cEmpAnt                  == "01"  .AND. ;
	//   xFilial("SE2")           == '01'  .AND. ;
	 //  Alltrim(SE2->E2_PREFIXO) == "ADR" .AND. ;
	//   Alltrim(SE2->E2_TIPO)    == "RJ"
	   
	IF cEmpAnt                  == "01"  .AND. ;	 
	   Alltrim(SE2->E2_PREFIXO) == "ADR" .AND. ;
	   Alltrim(SE2->E2_TIPO)    == "RJ"   
	   
	   nSaldo := (SE2->E2_VALOR - SE5->E5_VALOR)
	
		&& Atualizacao Itens Obrigacoes Pagar
		cQuery := " UPDATE " + RETSQLNAME("ZAF") + "" 
		cQuery += " SET   ZAF_BAIXA  = '" + Dtos(dBaixa) + "'," 
		cQuery += "       ZAF_LEGEND = 'B' "             + "," 
		cQuery += "       ZAF_SALDO  = " + STR(nSaldo) + " " 
		cQuery += " WHERE D_E_L_E_T_ <> '*' " 
	   //	cQuery += "   AND ZAF_FILIAL  = '" + XFILIAL("ZAF")  + "'" 
	    cQuery += "   AND ZAF_FILIAL  = '" + SE2->E2_FILIAL  + "'"   
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
		//cQuery += " AND ZAH_FILIAL    = '" + XFILIAL("ZAH") + "'  "
		cQuery += " AND ZAH_FILIAL    = '" + SE2->E2_FILIAL + "'  " 	
		cQuery += " AND ZAH_NUMERO	  = '" + SE2->E2_NUM + "'  " 	
	    cQuery += " AND ZAH_SALDO     > 0  "
    	
		tcSqlExec(cQuery)
		tcSqlExec('commit')	
	
	ENDIF  	
	
	RestArea(aArea)
  
Return(lRet)
