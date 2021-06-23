#INCLUDE "PROTHEUS.CH"        
#INCLUDE "APWEBEX.CH"

User Function F430VAR
Local cQuery := {}
Local _area  := GetArea()

// TRATA APENAS O BANCO DO BRASIL
If substr(PARAMIXB[1,16],1,3) == "001"

	cQuery	:= "SELECT * FROM "+ RetSqlName("SA2") 
	cQuery	+= " WHERE A2_FILIAL = '" + xFilial("SA2") + "' "
	cQuery	+= "   AND D_E_L_E_T_ <> '*' "  
	cQuery	+= "   AND SUBSTRING(A2_NOME,1,30) = '"+STRTRAN(SUBSTR(PARAMIXB[1,16],44,30),"'","''" )+"' "
   Open Query cQuery Alias "TRXA2"

	cQuery	:= "SELECT * FROM "+ RetSqlName("SE2") 
	cQuery	+= " WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
	cQuery	+= "   AND E2_NUM = '"+ALLTRIM(CNUMTIT)+"' "
	cQuery	+= "   AND E2_SALDO > 0 "
	cQuery	+= "   AND D_E_L_E_T_ <> '*' "  
   cQuery	+= "   AND E2_FORNECE = '"+TRXA2->A2_COD+"' "

   Open Query cQuery Alias "TRXE2"

   If !EMPTY(TRXE2->E2_IDCNAB)
      CNUMTIT        := TRXE2->E2_IDCNAB
      PARAMIXB[1][1]:= TRXE2->E2_IDCNAB
   Endif
Endif

Close Query "TRXE2"

Close Query "TRXA2"
RestArea(_Area)

Return