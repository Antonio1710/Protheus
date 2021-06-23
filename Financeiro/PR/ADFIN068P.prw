#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ADFIN068Pº Autor ³WILLIAM COSTA       ºData  ³  19/09/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para criar as string    dados para pagamento de     º±±
±±º          ³ tributos sem código de barras - SISPAG ITAU                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNAB                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION ADFIN068P()

	LOCAL cString1	:= ""
	LOCAL cString2	:= ""
	LOCAL cString3	:= ""
	LOCAL cString4	:= ""
	LOCAL cString5	:= ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para criar as string dados para pagamento de tributos sem código de barras - SISPAG ITAU')
	
	IF SE2->E2_XTIPOIM == '1' 
		
		cString1 := GPSITAU()
		RETURN(cString1)
		
	ELSEIF SE2->E2_XTIPOIM == '2' 
		
		cString2 := DARFITAU()
		RETURN(cString2)		
		
	ELSEIF SE2->E2_XTIPOIM == '4' 
		
		cString4 := GAREITAU()
		RETURN(cString4) 	
	
	ELSEIF SE2->E2_XTIPOIM == '5' 
		
		IF ALLTRIM(SE2->E2_CODBAR) <> ''
		
			cString5 := FGTSCOMCODIGO()
			RETURN(cString5)
			
		ELSE
		
			MSGSTOP("CNAB para o Itau de FGTS sem codigo de Barras não configurado","ADFIN068P")
			
		ENDIF
	
	ELSE
	
		MSGSTOP("Rotina de Impostos IPVA sem codigo de barras nao configurada para o Itau, favor verificar com a T.I","ADFIN068P")
		
	ENDIF
	
Return("")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DADOSGPS º Autor ³                    ºData  ³  06/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para criar a string com dados para pagamento de GPS º±±
±±º          ³ sem código de barras                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ KDL		                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

STATIC FUNCTION GPSITAU()

	Local cRetGPS := ""
	Local cCgc    := ''
	Local nRecEmp := SM0->(Recno())
	
	DBSELECTAREA("SM0")
	DBGOTOP()
	
	While SM0->(!Eof())
	
		IF SM0->M0_CODIGO == CEMPANT .AND. SM0->M0_CODFIL == SE2->E2_FILIAL
		
			cCgc := SM0->M0_CGC
			
		ENDIF	
		
		SM0->(DbSkip())	
		
	Enddo
	
	DBSELECTAREA("SM0")
	DBGOTOP()
	SM0->(dbgoto(nRecEmp))
	
	cRetGPS += "01"					   					                                																			   // IDENTIFICACAO DO TRIBUTO
	cRetGPS += SE2->E2_XCODPAG		   					                                																			   // CODIGO DE PAGAMENTO
	cRetGPS += STRZERO(MONTH(SE2->E2_VENCREA) - 1,2) +  IIF((MONTH(SE2->E2_VENCREA) - 1) <> 12,STRZERO(YEAR(SE2->E2_VENCREA),4),STRZERO(YEAR(SE2->E2_VENCREA) - 1,4)) // MES E ANO DA COMPETENCIA
	cRetGPS += cCgc                                                                                                                                                    // IDENTIFICACAO CNPJ/CEI/NIT/PIS DO CONTRIBUINTE
	cRetGPS += STRZERO((SE2->E2_VALOR - SE2->E2_VALENTI)*100,14)                                                                                                       // VALOR PREVISTO DO PAGAMENTO DO INSS
	cRetGPS += STRZERO((SE2->E2_VALENTI)*100,14)                                                                                                                       // VALOR DE OUTRAS ENTIDADES
	cRetGPS += '00000000000000'                                                                                                                                        // ATUALIZACAO MONETARIA
	cRetGPS += STRZERO((SE2->E2_VALOR)*100,14)                                                                                                                         // VALOR ARRECADADO
	cRetGPS += GRAVADATA(DDATABASE,.F.,5)                                                                                                                              // DATA DA ARRECADACAO/ EFETIVACAO DO PAGAMENTO
	cRetGPS += SPACE(08)                                                                                                                                               // COMPLEMENTO DO REGISTRO
	cRetGPS += SPACE(50)                                                                                                                                               // INFORMACOES COMPLEMENTARES
	cRetGPS += SUBSTR(SM0->M0_NOMECOM,1,30)                                                                                                                            // NOME DO CONTRIBUINTE
	
Return(cRetGPS)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DARFITAU º Autor ³                    ºData  ³  06/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para criar a string com dados para pagamento de DARFº±±
±±º          ³ sem código de barras                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ KDL		                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

STATIC FUNCTION DARFITAU()

	Local cRetDARF := ""
	Local cCgc     := '' 
	Local nRecEmp  := SM0->(Recno())
	
	DBSELECTAREA("SM0")
	DBGOTOP()
	
	While SM0->(!Eof())
	
		IF SM0->M0_CODIGO == CEMPANT .AND. SM0->M0_CODFIL == SE2->E2_FILIAL
		
			cCgc := SM0->M0_CGC
			
		ENDIF	
		
		SM0->(DbSkip())	
		
	Enddo
	
	DBSELECTAREA("SM0")
	DBGOTOP()
	SM0->(dbgoto(nRecEmp))
	
	cRetDARF += "02"                                                                                                                                                                                                                                                                   // CODIGO DE IDENTIFICACAO DO TRIBUTO 
	cRetDARF += SE2->E2_XCODPAG 					   					                                                                                                                                                                                                               // CODIGO DA RECEITA (04) 
	cRetDARF += '1' 				                                                                                                                                                                                                                                                   // TIPO DE INSCRICAO DO CONTRIBUINTE 1=CNPJ, 2=CPF  (01)  
	cRetDARF += cCgc	                                                                                                                                                                                                                                                               // IDENTIFICACAO DO CONTRIBUINTE (14)
	cRetDARF += CVALTOCHAR(DAY(LASTDAY(STOD(STRZERO(YEAR(SE2->E2_VENCREA),4) + STRZERO(MONTH(SE2->E2_VENCREA)- 1,2) + "01")))) +  STRZERO(MONTH(SE2->E2_VENCREA)- 1,2) + IIF((MONTH(SE2->E2_VENCREA) - 1) <> 12,STRZERO(YEAR(SE2->E2_VENCREA),4),STRZERO(YEAR(SE2->E2_VENCREA) - 1,4)) // PERIODO APURACAO(8)
	cRetDARF += '00000000000000000'                                                  																								                                                                                                   // NUMERO REFERENCIA (17)
	cRetDARF += STRZERO((SE2->E2_VALOR)*100,14)			                             																								                                                                                                   // VALOR PRINCIPAL (14)
	cRetDARF += STRZERO((SE2->E2_MULTA)*100,14)			                             																								                                                                                                   // VALOR DA MULTA (14)
	cRetDARF += STRZERO((SE2->E2_JUROS + SE2->E2_SDACRES)*100,14)                    																								                                                                                                   // VALOR DOS JUROS/ENCARGOS (14)
	cRetDARF += STRZERO((SE2->E2_VALOR + SE2->E2_MULTA +SE2->E2_JUROS + SE2->E2_SDACRES)*100,14)                    																                                                                                                   // VALOR TOTAL (14)
	cRetDARF += GRAVADATA(SE2->E2_VENCREA,.F.,5)    	                                                                                                                                                                                                                               // Data de Vencimentos (8)
	cRetDARF += GRAVADATA(DDATABASE,.F.,5)    	                                                                                                                                                                                                                                       // Data do Pagamento (8)
	cRetDARF += SPACE(30)								                                                                                                                                                                                                                               // BRANCOS (30)
	cRetDARF += SUBSTR(SM0->M0_NOMECOM,1,30)								                                                                                                                                                                                                           // NOME DO CONTRIBUINTE (30)
    
Return(cRetDARF)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DADOSGAREº Autor ³                    ºData  ³  06/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para criar a string com dados para pagamento de GAREº±±
±±º          ³ sem código de barras                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ KDL		                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

STATIC FUNCTION GAREITAU()

	Local cRetGARE := ""
	Local cCgc     := ''
	Local cInscEst := ''
	Local nRecEmp  := SM0->(Recno())
	
	DBSELECTAREA("SM0")
	DBGOTOP()
	
	While SM0->(!Eof())
	
		IF SM0->M0_CODIGO == CEMPANT .AND. SM0->M0_CODFIL == SE2->E2_FILIAL
		
			cCgc     := SM0->M0_CGC
			cInscEst := SM0->M0_INSC
			
		ENDIF	
		
		SM0->(DbSkip())	
		
	Enddo
	
	DBSELECTAREA("SM0")
	DBGOTOP()
	SM0->(dbgoto(nRecEmp))
	
	cRetGARE += '05'	                                                                                                                                                //IDENTIFICACAO DO TRIBUTO (02) 
	cRetGARE += SE2->E2_XCODPAG					   					                                                                                                    //CODIGO DA RECEITA (04) 
	cRetGARE += "1" 				                                                                                                                                    //TIPO DE INSCRICAO DO CONTRIBUINTE 1=CNPJ, 2=CPF  (01) 
	cRetGARE += cCgc	                                                                                                                                                //CPF OU CNPJ DO CONTRIBUINTE (14)
	cRetGARE += SUBSTR(cInscEst,1,12)     	                                                                                                                            //INSCRICAO ESTADUAL (12) DATA VENCIMENTO (8)
	cRetGARE += '0000000000000'					                                                                                                                        //DIVIDA ATIVA /N.ETIQUETA (13)
	cRetGARE += STRZERO(MONTH(SE2->E2_VENCREA) - 1,2) +  IIF((MONTH(SE2->E2_VENCREA) - 1) <> 12,STRZERO(YEAR(SE2->E2_VENCREA),4),STRZERO(YEAR(SE2->E2_VENCREA) - 1,4)) //REFERENCIA (06)
	cRetGARE += '0000000000000'  						                                                                                                                //NUMERO DA PARCELA / NOTIFICACAO (13)
	cRetGARE += STRZERO((SE2->E2_VALOR)*100,14)			                                                                                                                //VALOR RECEITA (14)
	cRetGARE += STRZERO((SE2->E2_JUROS + SE2->E2_SDACRES)*100,14)                                                                                                       //VALOR DOS JUROS/ENCARGOS (14)
	cRetGARE += STRZERO((SE2->E2_MULTA)*100,14)			                                                                                                                //VALOR DA MULTA (14)
	cRetGARE += STRZERO((SE2->E2_VALOR + SE2->E2_MULTA +SE2->E2_JUROS + SE2->E2_SDACRES)*100,14)                                                                        //VALOR PAGAMENTO (14)
	cRetGARE += GRAVADATA(SE2->E2_VENCREA,.F.,5)    	                                                                                                                //Data de Vencimentos (8)
	cRetGARE += GRAVADATA(DDATABASE,.F.,5)    	                                                                                                                        //Data do Pagamento (8)
	cRetGARE += SPACE(11)								                                                                                                                //BRANCOS (11)
	cRetGARE += SUBSTR(SM0->M0_NOMECOM,1,30)								                                                                                            //NOME DO CONTRIBUINTE (30)
    
Return(cRetGARE)      

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DADOSIPVAº Autor ³                    ºData  ³  22/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para criar a string com dados para pagamento de IPVAº±±
±±º          ³ sem código de barras                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ KDL		                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

STATIC FUNCTION DADOSIPVA()

	Local cRetIPVA  := ""
    /*
	//POSICIONA NO FORNECEDOR
	//=======================
	SA2->(DBSETORDER(01))
	SA2->(DBSEEK(xFILIAL("SA2")+SE2->(E2_FORNECE+E2_LOJA)))
		
	cRetIPVA := SUBSTR(Alltrim(SE2->E2_XIPVA01),1,2)											//IDENTIFICACAO DO TRIBUTO (02)
	cRetIPVA += SPACE(04)																		// BRANCOS
	cRetIPVA += IIF(SA2->A2_TIPO == "J", "2", "1")         										// TIPO DE INSCRIÇÃO DO CONTRIBUINTE (1-CPF / 2-CNPJ) 
	cRetIPVA += STRZERO(VAL(SA2->A2_CGC),14)                									// CPF OU CNPJ DO CONTRIBUINTE
	cRetIPVA += SUBSTR(DTOS(dDATABASE),1,4)	            										// ANO BASE
	cRetIPVA += PADR(SE2->E2_XIPVA02,09)//E2_XRENAVA                    						// CODIGO RENEVAN
	cRetIPVA += SE2->E2_XIPVA03 //E2_XUFRENA													// UF RENEVAN
	cRetIPVA += IIF(EMPTY(SE2->E2_XIPVA04),PADR(SA2->A2_COD_MUN,05),PADR(SE2->E2_XIPVA04,05))	// COD.MUNICIPIO RENEVAN  -SE2->E2_XMUNREN
	cRetIPVA += PADR(SE2->E2_XIPVA05,07)//SE2->E2_XPLACA				     					// PLACA DO VEICULO
	cRetIPVA += SE2->E2_XIPVA06	//E2_XOPCPAG													// OPCAO DE PAGAMENTO
	cRetIPVA += STRZERO(INT((SE2->E2_SALDO+SE2->E2_ACRESC)*100),14)     						// VALOR DO IPVA + MULTA + JUROS
	cRetIPVA += STRZERO(INT(SE2->E2_DECRESC*100),14)											// VALOR DO DESCONTO
	cRetIPVA += STRZERO(INT(((SE2->E2_SALDO+SE2->E2_ACRESC)-SE2->E2_DECRESC)*100),14)			// VALOR DO PAGAMENTO
	cRetIPVA += GRAVADATA(SE2->E2_VENCREA,.F.,5) 												// DATA DE VENCIMENTO
	cRetIPVA += GRAVADATA(SE2->E2_VENCREA,.F.,5) 												// DATA DE PAGAMENTO 
	cRetIPVA += SPACE(41) 								                       					// COMPLEMENTO DE REGISTRO                           
	cRetIPVA += SUBSTR(SA2->A2_NOME,1,30)								            			// NOME DO CONTRIBUINTE 	
    */
 Return(cRetIPVA)                    	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DADOSFGTSº Autor ³                    ºData  ³  22/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para criar a string com dados para pagamento de FGTSº±±
±±º          ³ sem código de barras                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ KDL		                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

STATIC FUNCTION FGTSCOMCODIGO()
             
	Local  cRetFGST :=""                 	
			    				 							                      // ===> FGTS - GFIP
	cRetFGST := '11'		                                                      // IDENTIFICACAO DO TRIBUTO (02)"11"            	                            
	cRetFGST += STRZERO(VAL(SE2->E2_XCODPAG),04)        	                      // Código da Receita
	cRetFGST += "1"											                      // TIPO DE INSCRIÇÃO DO CONTRIBUINTE (1-CPF / 2-CNPJ) 
	cRetFGST += STRZERO(VAL(SM0->M0_CGC),14)                                      // CPF OU CNPJ DO CONTRIBUINTE 
	cRetFGST += SUBSTR(SE2->E2_CODBAR,1,48)                                       // CODIGO DE BARRAS (LINHA DIGITAVEL)	(*criar campo*) 
	cRetFGST += STRZERO(VAL(SM0->M0_CGC),16)    	                              // Identificador FGTS 
	cRetFGST += '000000000'   			                                          // Lacre de Conectividade Social 
	cRetFGST += '00'  		     	                                              // Digito do Lacre  
	cRetFGST += SubStr(SM0->M0_NOMECOM,1,30)                                      // NOME DO CONTRIBUINTE
	cRetFGST += GravaData(SE2->E2_VENCREA,.F.,5)           	                      // DATA DO PAGAMENTO 
	cRetFGST += StrZero(SE2->E2_SALDO*100,14)             	                      // VALOR DO PAGAMENTO 
	cRetFGST += Space(30)                                  	                      // COMPLEMENTO DE REGISTRO 
	
Return(cRetFGST)

STATIC FUNCTION FGTSSEMCODIGO()
             
	Local  cRetFGST :=""                 	
	/*		    				 							// ===> FGTS - GFIP
	cRetFGST := SUBSTR(Alltrim(SE2->E2_XFGTS01),1,2)		// IDENTIFICACAO DO TRIBUTO (02)"11"            	                            
	cRetFGST += SubStr(SE2->E2_XFGTS02,1,4)					// Código da Receita
	cRetFGST += "2"											// TIPO DE INSCRIÇÃO DO CONTRIBUINTE (1-CPF / 2-CNPJ) 
	cRetFGST += StrZero(Val(SM0->M0_CGC),14)            	// CPF OU CNPJ DO CONTRIBUINTE 
	cRetFGST += AllTrim(SE2->E2_XFGTS03)                   	// CODIGO DE BARRAS (LINHA DIGITAVEL)	(*criar campo*) 
	cRetFGST += StrZero(Val(SE2->E2_XFGTS04),16) 			// Identificador FGTS 
	cRetFGST += StrZero(Val(SE2->E2_XFGTS05),9)   			// Lacre de Conectividade Social 
	cRetFGST += StrZero(Val(SE2->E2_XFGTS06),2)  			// Digito do Lacre  
	cRetFGST += SubStr(SM0->M0_NOMECOM,1,30)                // NOME DO CONTRIBUINTE
	cRetFGST += GravaData(SE2->E2_VENCREA,.F.,5)           	// DATA DO PAGAMENTO 
	cRetFGST += StrZero(SE2->E2_SALDO*100,14)             	// VALOR DO PAGAMENTO 
	cRetFGST += Space(30)                                  	// COMPLEMENTO DE REGISTRO 
	*/
Return(cRetFGST)