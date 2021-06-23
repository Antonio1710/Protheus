#INCLUDE "PROTHEUS.CH"
               
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT116GRV  บAutor  ณWilliam Costa       บ Data ณ  22/01/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEste ponto de entrada pertence a rotina de digita็ใo de     บฑฑ
ฑฑบ          ณconhecimento de frete, MATA116(). ษ executado na rotina de  บฑฑ
ฑฑบ          ณinclusใo do conhecimento de frete, A116INCLUI(), quando a   บฑฑ
ฑฑบ          ณtela com o conhecimento e os itens sใo montados.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ WORKFLOW CHAMADOS -SCHEDULE                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAltera็ใo ณ Ch.Interno TI - Abel Babini - Preenche Tipo CTe - 17/06/19 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function MT116GRV() 

	Local nPosLocal  := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_LOCAL"})     
	Local nPosProd   := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_COD"})     
	Local nCont      := 0  
	
	IF cEmpAnt <> "01"   &&somente executa para empresa Adoro.
    	RETURN(NIL)
	ENDIF
	

	FOR nCont := 1 TO LEN(aCols)                  
	    
	    //TROCA QUANDO FOR FILIAL 03                 
		IF XFILIAL() == '03' .AND. ALLTRIM(FUNNAME())=="INTNFEB"
		
	    	aCols[nCont][nPosLocal] := IIF(!RetArqProd(aCols[nCont][nPosProd]),POSICIONE("SBZ",1,xFilial("SBZ")+aCols[nCont][nPosProd],"BZ_LOCPAD"),POSICIONE("SB1",1,xFilial("SB1")+aCols[nCont][nPosProd],"B1_LOCPAD")) //LTERACAO REFERENTE A TABELA SBZ INDICADORES DE PRODUTOS CHAMADO 030317 - WILLIAM COSTA     
	    	
	    ENDIF	
	
	NEXT  

	//INICIO CHAMADO INTERNO TI - Abel Babini - 17/06/19 - Preenche Tipo CTe Automaticamente
	If IsInCallStack("MATA116") 
	
		If Type("aNFeDANFE") == "A" .And. Alltrim(cValToChar(CESPECIE)) == "CTE"
		
			aNFeDANFE[18] := "N - Normal"
		
		ElseIf Type("aNFeDANFE") == "A" .And. Alltrim(cValToChar(CESPECIE)) <> "CTE"
		
			aNFeDANFE[18] := ""
			
		EndIf

	Endif
	//FIM CHAMADO INTERNO TI - Abel Babini - 17/06/19 - Preenche Tipo CTe Automaticamente
Return 
