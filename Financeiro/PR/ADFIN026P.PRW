#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ADFIN026Pº Autor ³WILLIAM COSTA       ºData  ³  06/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para criar a string com dados para pagamento de     º±±
±±º          ³ tributos sem código de barras                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNAB                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION ADFIN026P()

	LOCAL cString1	:= ""
	LOCAL cString2	:= ""
	LOCAL cString3	:= ""
	LOCAL cString4	:= ""
	LOCAL cString5	:= ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para criar a string com dados para pagamento de tributos sem código de barras')
	
	IF SE2->E2_XTIPOIM == '1' 
		
		cString1 :=  U_DADOSGPS()
		return(cString1)
		
	ELSEIF SE2->E2_XTIPOIM == '2' 
		
		cString2 := U_DADOSDARF()
		return(cString2)	
		
	ELSEIF SE2->E2_XTIPOIM == '4' 
		
		cString3 := U_DADOSGARE()
		return(cString3) 
			
	/*ELSEIF !Empty(cTributo4) 
		        
		cString4 := U_DADOSIPVA()
		return(cString4)
	 	
	ELSEIF !Empty(cTributo5) 	
						
		cString5 := U_DADOSFGTS()
		return(cString5)
	*/	
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

USER FUNCTION DADOSGPS()

	Local cRetGPS := ""
	Local cCgc    := ''
	Local nRecEmp := SM0->(Recno())

	U_ADINF009P('ADFIN026P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para criar a string com dados para pagamento de tributos sem código de barras')
	
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
	
	cRetGPS += SE2->E2_XCODPAG + SPACE(2)                                               //01.3 CODIGO DA RECEITA (04)
	cRetGPS += "01"					   					                                //02.3 TIPO DE INSCRICAO DO CONTRIBUINTE 1=CNPJ, 2=CPF  (01)
	cRetGPS += cCgc                  				                                    //03.3 IDENTIFICACAO DO CONTRIBUINTE (14)
	cRetGPS += '17'	                                                                    //04.3 CODIGO DE IDENTIFICACAO DO TRIBUTO (02)
	cRetGPS += STRZERO(MONTH(SE2->E2_VENCREA)- 1,2) + STRZERO(YEAR(SE2->E2_VENCREA),4)  //05.3 COMPETENCIA (6)
	cRetGPS += STRZERO((SE2->E2_VALOR - SE2->E2_VALENTI)*100,15)			            //06.3 VALOR PREVISTO DO PAGAMENTO (15)
	cRetGPS += STRZERO((SE2->E2_VALENTI)*100,15)                                        //07.3 VALOR OUTRAS ENTIDADES (15)
	cRetGPS += '000000000000000'			                                            //08.3 ATUALIZACAO MONETARIA (14)
	cRetGPS += SPACE(45)	                                                            //09.3 CNAB (45)


Return(cRetGPS)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DADOSDARFº Autor ³                    ºData  ³  06/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para criar a string com dados para pagamento de DARFº±±
±±º          ³ sem código de barras                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ KDL		                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION DADOSDARF()

	Local cRetDARF  := ""

	U_ADINF009P('ADFIN026P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para criar a string com dados para pagamento de tributos sem código de barras')
	
	cRetDARF += '5952  '	                                                         //01.3 CODIGO DA RECEITA (04)
	cRetDARF += "01"					   					                         //02.3 TIPO DE INSCRICAO DO CONTRIBUINTE 1=CNPJ, 2=CPF  (01)
	cRetDARF += SUBSTR(SM0->M0_CGC,1,14)				                             //03.3 IDENTIFICACAO DO CONTRIBUINTE (14)
	cRetDARF += '16'	                                                             //04.3 CODIGO DE IDENTIFICACAO DO TRIBUTO (02)
	cRetDARF += GRAVADATA(SE2->E2_VENCREA,.F.,5)    	                             //05.3 PERIODO (8)
	cRetDARF += '00000000000000000'                                                  //06.3 NUMERO REFERENCIA (17)
	cRetDARF += STRZERO((SE2->E2_VALOR)*100,15)			                             //07.3 VALOR PRINCIPAL (15)
	cRetDARF += STRZERO((SE2->E2_MULTA)*100,15)			                             //08.3 VALOR DA MULTA (15)
	cRetDARF += STRZERO((SE2->E2_JUROS + SE2->E2_SDACRES)*100,15)                    //09.3 VALOR DOS JUROS/ENCARGOS (15)
	cRetDARF += GRAVADATA(SE2->E2_VENCREA,.F.,5)    	                             //10.3 Data de Vencimentos (8)
	cRetDARF += SPACE(18)								                             //11.3 BRANCOS (18)

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

USER FUNCTION DADOSGARE()

	Local cRetGARE  := ""

	U_ADINF009P('ADFIN026P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para criar a string com dados para pagamento de tributos sem código de barras')
	
	cRetGARE += '1708  '	                                                         //01.3 CODIGO DA RECEITA (04)
	cRetGARE += "01"					   					                         //02.3 TIPO DE INSCRICAO DO CONTRIBUINTE 1=CNPJ, 2=CPF  (01)
	cRetGARE += SUBSTR(SM0->M0_CGC,1,14)				                             //03.3 IDENTIFICACAO DO CONTRIBUINTE (14)
	cRetGARE += '23'	                                                             //04.3 CODIGO DE IDENTIFICACAO DO TRIBUTO (02)
	cRetGARE += GRAVADATA(SE2->E2_VENCREA,.F.,5)    	                             //05.3 DATA VENCIMENTO (8)
	cRetGARE += SUBSTR(SM0->M0_INSC,1,12)				                             //06.3 INSCRICAO ESTADUAL - CNPJ OU CPF (12)
	cRetGARE += '0000000000000'								                         //07.3 DIVIDA ATIVA /N.ETIQUETA (13)
	cRetGARE += STRZERO(MONTH(SE2->E2_VENCREA),2) + STRZERO(YEAR(SE2->E2_VENCREA),4) //08.3 REFERENCIA (06)
	cRetGARE += '0000000000000'  						                             //09.3 NUMERO DA PARCELA / NOTIFICACAO (13)
	cRetGARE += STRZERO((SE2->E2_VALOR)*100,15)			                             //10.3 VALOR RECEITA (15)
	cRetGARE += STRZERO((SE2->E2_JUROS + SE2->E2_SDACRES)*100,14)                    //11.3 VALOR DOS JUROS/ENCARGOS (14)
	cRetGARE += STRZERO((SE2->E2_MULTA)*100,14)			                             //12.3 VALOR DA MULTA (14)
	cRetGARE += SPACE(01)								                             //13.3 BRANCOS (1)

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

USER FUNCTION DADOSIPVA()

	Local cRetIPVA  := ""

	U_ADINF009P('ADFIN026P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para criar a string com dados para pagamento de tributos sem código de barras')

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

USER FUNCTION DADOSFGTS()
             
	Local  cRetFGST :=""                 	

	U_ADINF009P('ADFIN026P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para criar a string com dados para pagamento de tributos sem código de barras')

	// ===> FGTS - GFIP
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
	
Return(cRetFGST)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SOMAJM   º Autor ³                    ºData  ³  22/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para criar a string com dados de juros e multa      º±±
±±º          ³  					                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ KDL		                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER FUNCTION SOMAJM()

	Local cReturn2  := "" 
	Local nValcamp  := 0

	U_ADINF009P('ADFIN026P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para criar a string com dados para pagamento de tributos sem código de barras')
	
	nValcamp := (SE2->E2_MULTA + SE2->E2_JUROS + SE2->E2_SDACRES) 
	
	cReturn2 += STRZERO(nValCamp*100,14) 

Return(cReturn2)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SOMATOTALº Autor ³                    ºData  ³  22/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para criar a string com dados de valor total        º±±
±±º          ³  					                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ KDL		                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION SOMATOTAL()

	Local cReturn1  := "" 

	U_ADINF009P('ADFIN026P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para criar a string com dados para pagamento de tributos sem código de barras')
	
	cReturn1 := STRZERO(((SE2->E2_VALOR + SE2->E2_MULTA + SE2->E2_JUROS + SE2->E2_SDACRES )-(SE2->E2_DESCONT + SE2->E2_SDDECRE))*100,14)  

Return(cReturn1)  	
