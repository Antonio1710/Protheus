#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCBINVVAL  บAutor  ณMicrosiga           บ Data ณ  08/18/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de Entrada na leitura do produto no inventario       บฑฑ
ฑฑบ          ณ (ACDV035)                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function CBINVVAL()

	Local cRet         := .T.  
	Local cEnd         := '' 
	Local cEndCorreto  := '' 
	Local cProdCorreto := ''
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Ponto de Entrada na leitura do produto no inventario (ACDV035)')
	
	cEnd         := Posicione("SBE",10,xFilial("SBE")+SUBSTRING(cEtiqProd,1,15),"BE_LOCALIZ") //alterado esse linha parou de funcionar a variavel cProduto por causa do Protheus 12 William Costa chamado 039893 
	cEndCorreto  := Posicione("CBA",1,xFilial("CBA")+cCodInv,"CBA_LOCALI")  
	cProdCorreto := Posicione("SBE",1,xFilial("SBE")+cArmazem+cEndCorreto,"BE_CODPRO")
	BEGINSQL ALIAS "QSBE"
			%noparser%
			SELECT CBA_PROD,
			       CBA_LOCAL,
			       CBA_LOCALI,
			       BE_LOCALIZ, 
			       BE_LOCAL,
			       CBA_TIPINV
			  FROM %Table:CBA% CBA, 
			       %Table:SBE% SBE
			 WHERE CBA_FILIAL    = %xfilial:SBE%
			   AND CBA_LOCALI    = %EXP:cEnd% 
			   AND CBA_LOCAL     = %EXP:cArmazem% 
			   AND CBA_CODINV    = %EXP:cCodInv% 
			   AND CBA_STATUS   <= '3'
			   AND CBA.%notDel%  
			   AND CBA_FILIAL    = BE_FILIAL
			   AND CBA_LOCALI    = BE_LOCALIZ     
			   AND CBA_LOCAL     = BE_LOCAL
			   AND SBE.%notDel%
			   
            ENDSQL
			
			IF QSBE->(EOF())  
			
				ApMsgAlert("CBINVVAL - PONTO DE ENTRADA - Produto Invแlido, Informe o produto correto " + cProdCorreto  + " !!!")	
				cRet     := .F. 
				VtClearGet("cEtiqProd")
			ENDIF
			
	QSBE->(dbCloseArea()) 
	
Return(cRet)