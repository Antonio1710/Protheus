#Include "Protheus.ch"  
#Include "Fileio.ch"
#Include "TopConn.ch"  
#Include "Rwmake.ch"     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADFIN069R ºAutor  ³Fernando Sigoli     º Data ³  05/10/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de eficiência de cobrança                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIN                                                    º±±
±±ºversionamento:                                                         º±±
±±ºEverson - 20/12/2018 chamado 045776. Adicionado tratamento para RA,    º±±
±±ºcorreção monetária, arredondamento e pagpamento a maior.               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ADFIN069R() //U_ADFIN069R()

 	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="Relatorio de eficiência de cobrança"    
	Private oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	Private oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	Private oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	Private oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	Private oPrn		:=TMSPrinter():New()
	Private nOpca		:=0
	Private cPerg		:= 'ADFIN069R'

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de eficiência de cobrança')
		
	//+------------------------------------------------+
	//|Cria grupo de perguntas.                        |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o usuário.     |            
	//+------------------------------------------------+
	Aadd(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	Aadd(aSays,"Relatorio eficiência de cobrança" )
    
	Aadd(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	Aadd(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||finADFIN69R()},"Gerando arquivo","Aguarde...")}})
	Aadd(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch(cCadastro, aSays, aButtons)  
	
Return Nil

Static Function finADFIN69R() 

 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	Private oExcel      := FWMSEXCEL():New()
	Private cPath       := '\protheus_data\system\'
	Private cArquivo    := 'REL_EFIC_COB.XML'
	Private oMsExcel
	Private cPlanilha   := "Eficiencia_recebimento"
	Private cTitulo     := "Eficiencia_recebimento"
	Private cCodProdSql := '' 
	Private cFilSql     := ''
	Private aLinhas     := {}
   
	Begin Sequence
		
		//Verifica se há o excel instalado na máquina do usuário.
		If ! ( ApOleClient("MsExcel") ) 
		
			MsgStop("Não Existe Excel Instalado","Função finADFIN69R(ADFIN069P)")   
		    Break
		    
		EndIF
		
		//Gera o cabeçalho.
		Cabec()  
		          
		If ! GeraExcel()
			Break
			
		EndIf
		
		Sleep(2000)
		SalvaXml()
		
		Sleep(2000)
		CriaExcel()
		
		MsgInfo("Arquivo Excel gerado!","Função ComADCOM022R(ADFIN069R)")    
	    
	End Sequence

Return Nil 

Static Function Cabec() 

	oExcel:AddworkSheet(cPlanilha)
	
	//Pedido.
	oExcel:AddTable (cPlanilha,cTitulo)
	oExcel:AddColumn(cPlanilha,cTitulo,"Filial "		,1,1) // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"Prefixo "	    ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Titulo "		,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"Parcela "    	,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"Tipo "			,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"Cliente "	    ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"Razao Social "	,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"Vededor "		,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"Emissão"        ,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"Vcnto "	        ,1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"Vcnto Orig"     ,1,1) // 11 J
	oExcel:AddColumn(cPlanilha,cTitulo,"Vcnto Real "	,1,1) // 12 L
	oExcel:AddColumn(cPlanilha,cTitulo,"R$ Titulo "	    ,1,1) // 13 M
	oExcel:AddColumn(cPlanilha,cTitulo,"R$ Pagamento  "	,1,1) // 14 N
	oExcel:AddColumn(cPlanilha,cTitulo,"R$ Saldo      "	,1,1) // 15 O
	oExcel:AddColumn(cPlanilha,cTitulo," %            "	,1,1) // 16 O
	
Return Nil

Static Function GeraExcel()

	Local nLinha		:= 0
	Local nExcel     	:= 0
	Local nTotReg		:= 0
	Local cRetQry       := ''
	Local cNumPC        := ''
	Local nVlrTit       := 0
	Local nVlrPag       := 0 
	Local nVlrSld       := 0
	Local nPercet       := 0
	
	
	If Select("TRB") > 0
		TRB->(DbCloseArea())
	EndIf
	
		
	cRetQry := SqlTitulos()
	
	MsAguarde({|| DBUSEAREA(.T.,"TOPCONN",TcGenQry(,,cRetQry), "TRB", .F., .T.)},"Aguarde","Executando consulta no BD...") 
	//TcQuery cRetQry New Alias "TRB"
	DbSelectArea("TRB")
	TRB->(DbGoTop())
		
	
	//Conta o Total de registros.
	nTotReg := Contar("TRB","!Eof()")
	
	//Valida a quantidade de registros.
	If nTotReg <= 0
		MsgStop("Não há registros para os parâmetros informados.","Função GeraExcel(ADCOMR22R)")
		Return .F.
		
	EndIf
	
	//Atribui a quantidade de registros à régua de processamento.
	ProcRegua(nTotReg)
	TRB->(DbGoTop())
	While !TRB->(Eof()) 
	
		cNumPC := Alltrim(cValToChar(TRB->TITULO))
	
		IncProc("Processando Titulo:. " + cNumPC)     
					 
	    nLinha  := nLinha + 1                                       
	
	    //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
	   	Aadd(aLinhas,{ "", ; // 01 A  
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	               "", ; // 07 G  
	   	               "", ; // 08 H  
	   	               "", ; // 09 I  
	   	               "", ; // 10 J   
	   	               "", ; // 11 K  
	   	               "", ; // 12 L  
	   	               "", ; // 13 M  
	   	               "", ; // 14 N
	   	               "", ; // 15 O
	   	               ""  ; // 16 P
	                      })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
		
		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================   
		
		//Dados do titulos
		aLinhas[nLinha][01] := TRB->FILIAL                                                                          // 01 A	
		aLinhas[nLinha][02] := TRB->PREFIXO                                                                         // 02 B
		aLinhas[nLinha][03] := TRB->TITULO                                                                          // 03 C
		aLinhas[nLinha][04] := TRB->PARCELA                                                                         // 04 D
		aLinhas[nLinha][05] := TRB->TIPO                                                                            // 05 E
		aLinhas[nLinha][06] := TRB->CLIENTE+'-'+TRB->LOJA                                                           // 06 F
		aLinhas[nLinha][07] := TRB->NOMECLI                                                                         // 07 G
		aLinhas[nLinha][08] := TRB->VENDEDOR+'-'+Posicione("SA3",1,xFilial("SA3")+TRB->VENDEDOR,"A3_NOME" )         // 08 H
		aLinhas[nLinha][09] := TRB->EMISSAO  		                                                                // 09 I
		aLinhas[nLinha][10] := TRB->VCNTO                                                                           // 10 J
		aLinhas[nLinha][11] := TRB->VCNTOORIG                                                                       // 11 K
		aLinhas[nLinha][12] := TRB->VNCTREAL                                                                        // 12 L
		aLinhas[nLinha][13] := Transform(TRB->VALOR_TITULO,"@E 999,999,999.99")                                    // 13 M
		aLinhas[nLinha][14] := Transform(TRB->VALOR_PAGO,"@E 999,999,999.99")    									// 14 N
		aLinhas[nLinha][15] := Transform(Iif((TRB->VALOR_TITULO - TRB->VALOR_PAGO) > 0,(TRB->VALOR_TITULO - TRB->VALOR_PAGO),0) ,"@E 999,999,999.99")//Everson - 20/12/2018. Chamado 045776.
		aLinhas[nLinha][16] := ''  			   																	    // 16 P
		
		nVlrTit  := nVlrTit + TRB->VALOR_TITULO 
		nVlrPag  := nVlrPag + TRB->VALOR_PAGO 
		nVlrSld  := nVlrSld + Iif((TRB->VALOR_TITULO - TRB->VALOR_PAGO) > 0,(TRB->VALOR_TITULO - TRB->VALOR_PAGO),0) //Everson - 20/12/2018. Chamado 045776.
		
		TRB->(DBSKIP())    
		
	ENDDO
	
	TRB->(DbCloseArea())    
	
	// *** INICIO LINHA DE TOTAIS *** //
	
		    nLinha  := nLinha + 1                                       
	
	    //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
	   	Aadd(aLinhas,{ "", ; // 01 A  
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	               "", ; // 07 G  
	   	               "", ; // 08 H  
	   	               "", ; // 09 I  
	   	               "", ; // 10 J   
	   	               "", ; // 11 K  
	   	               "", ; // 12 L  
	   	               "", ; // 13 M  
	   	               "", ; // 14 N
	   	               "", ; // 15 O   
	  	               ""  ; // 16 P
	                      })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
		
		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================   
		
		//Dados do titulos
		aLinhas[nLinha][01] := 'TOTAL'                                                    // 01 A	
		aLinhas[nLinha][02] := ''                                                         // 02 B
		aLinhas[nLinha][03] := ''                                                         // 03 C
		aLinhas[nLinha][04] := ''                                                         // 04 D
		aLinhas[nLinha][05] := ''                                                         // 05 E
		aLinhas[nLinha][06] := ''                                                         // 06 F
		aLinhas[nLinha][07] := ''                                                         // 07 G
		aLinhas[nLinha][08] := ''        												  // 08 H
		aLinhas[nLinha][09] := ''  		                                                  // 09 I
		aLinhas[nLinha][10] := ''                                                         // 10 J
		aLinhas[nLinha][11] := ''                                                         // 11 K
		aLinhas[nLinha][12] := ''                                                         // 12 L
		aLinhas[nLinha][13] :=  Transform(nVlrTit,"@E 999,999,999.99")                    // 13 M
		aLinhas[nLinha][14] :=  Transform(nVlrPag,"@E 999,999,999.99")  				  // 14 N
		aLinhas[nLinha][15] :=  Transform(nVlrSld,"@E 999,999,999.99")  				  // 15 O
		aLinhas[nLinha][16] :=  round((nVlrPag/nVlrTit)*100,2)						      // 15 O                                                                                                        
	// *** FINAL LINHA DE TOTAIS *** //
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	For nExcel := 1 To nLinha
		
		IncProc("Carregando Dados para a Planilha1 de: " + cValtochar(nExcel) + ' até: ' + cValtochar(nLinha))
		
   		oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],;  // 01 A  
								         aLinhas[nExcel][02],;  // 02 B  
								         aLinhas[nExcel][03],;  // 03 C  
								         aLinhas[nExcel][04],;  // 04 D  
								         aLinhas[nExcel][05],;  // 05 E  
								         aLinhas[nExcel][06],;  // 06 F  
								         aLinhas[nExcel][07],;  // 07 G  
								         aLinhas[nExcel][08],;  // 08 H  
								         aLinhas[nExcel][09],;  // 09 I  
								         aLinhas[nExcel][10],;  // 10 J  
								         aLinhas[nExcel][11],;  // 11 K  
								         aLinhas[nExcel][12],;  // 12 L  
								         aLinhas[nExcel][13],;  // 13 M  
								         aLinhas[nExcel][14],;  // 14 N 
								         aLinhas[nExcel][15],;  // 15 N 
								         aLinhas[nExcel][16] ;  // 16 O
													      	 }) 	
													      	 			
   Next nExcel  
   
   
 	//============================== FINAL IMPRIME LINHA NO EXCEL
 	
Return .T.  
                    
Static Function SqlTitulos()   

	Local cDtIni := DTOS(MV_PAR01) 
	Local cDtFin := DTOS(MV_PAR02)
	Local cQry01 := ""

	cQry01 := " SELECT "
	cQry01 += " DADOS3.FILIAL, "
	cQry01 += " DADOS3.PREFIXO,"
	cQry01 += " DADOS3.TITULO, "
	cQry01 += " DADOS3.PARCELA,"
	cQry01 += " DADOS3.TIPO, "
	cQry01 += " DADOS3.CLIENTE,"
	cQry01 += " DADOS3.LOJA,  "
	cQry01 += " DADOS3.NOMECLI, "
	cQry01 += " DADOS3.VENDEDOR,"
	cQry01 += " DADOS3.EMISSAO, "
	cQry01 += " DADOS3.VCNTO, "
	cQry01 += " DADOS3.VCNTOORIG,"
	cQry01 += " DADOS3.VNCTREAL, "
	cQry01 += " DADOS3.VALOR AS VALOR_TITULO,"


	cQry01 += " CASE "
	cQry01 += " WHEN DADOS3.CALCULADO > 0   AND DADOS3.SALDO = DADOS3.VLRORIGINAL THEN 0 "
	cQry01 += " WHEN DADOS3.VENDEDOR <> '000800' AND ROUND(DADOS3.CALCULADO,1) > 0   THEN DADOS3.CALCULADO "
	cQry01 += " WHEN DADOS3.VENDEDOR =  '000800' AND DADOS3.CALCULADO > 0   AND ( ROUND(DADOS3.VALOR,1)   >  ROUND(DADOS3.CALCULADO,1) AND (DADOS3.VALOR - DADOS3.CALCULADO) > 0.10 )   THEN ROUND(DADOS3.VALOR,1) - ROUND(DADOS3.CALCULADO,1) " 
	cQry01 += " WHEN DADOS3.VENDEDOR =  '000800' AND DADOS3.CALCULADO > 0   AND ROUND(DADOS3.CALCULADO,1) >  ROUND(DADOS3.VALOR,1)   THEN DADOS3.VALOR " 
	cQry01 += " WHEN DADOS3.VENDEDOR =  '000800' AND DADOS3.CALCULADO > 0   AND (ROUND(DADOS3.CALCULADO,1) = ROUND(DADOS3.VALOR,1) OR (DADOS3.VALOR - DADOS3.CALCULADO) < 0.10 )   THEN DADOS3.VALOR "
	cQry01 += " ELSE 0  END AS VALOR_PAGO " 	
	
	//Everson - 20/12/2018. Chamado 045776.
	/*cQry01 += " CASE " 
	cQry01 += " WHEN DADOS3.CALCULADO > 0   AND DADOS3.SALDO = DADOS3.VLRORIGINAL THEN 0 "
	cQry01 += " WHEN DADOS3.VENDEDOR <> '000800' AND DADOS3.CALCULADO > 0   THEN DADOS3.CALCULADO "
	cQry01 += " WHEN DADOS3.VENDEDOR =  '000800' AND DADOS3.CALCULADO > 0   AND DADOS3.VALOR > DADOS3.CALCULADO   THEN DADOS3.VALOR - DADOS3.CALCULADO " 
	cQry01 += " WHEN DADOS3.VENDEDOR =  '000800' AND DADOS3.CALCULADO > 0   AND DADOS3.CALCULADO > DADOS3.VALOR   THEN DADOS3.VALOR " 
	cQry01 += " WHEN DADOS3.VENDEDOR =  '000800' AND DADOS3.CALCULADO > 0   AND DADOS3.CALCULADO = DADOS3.VALOR   THEN DADOS3.VALOR " 
	cQry01 += " ELSE 0  "
	cQry01 += " 	END AS VALOR_PAGO "*/
		
	cQry01 += " FROM "
	cQry01 += " (SELECT " 
		
	cQry01 += " DADOS2.E1_FILIAL AS FILIAL, "
	cQry01 += " DADOS2.E1_PREFIXO AS PREFIXO, "
	cQry01 += " DADOS2.E1_NUM AS TITULO, "     
	cQry01 += " DADOS2.E1_PARCELA AS PARCELA,"
	cQry01 += " DADOS2.E1_TIPO AS TIPO, "
	cQry01 += " DADOS2.E1_CLIENTE AS CLIENTE,"
	cQry01 += " DADOS2.E1_LOJA AS LOJA, "
	cQry01 += " DADOS2.E1_NOMCLI AS NOMECLI, "
	cQry01 += " DADOS2.E1_VEND1 AS VENDEDOR, "
	cQry01 += " DADOS2.EMISSAO AS EMISSAO, "
	cQry01 += " DADOS2.VENCTO AS VCNTO, "
	cQry01 += " DADOS2.VENCORI AS VCNTOORIG, "
	cQry01 += " DADOS2.VENCREA AS VNCTREAL, "
	cQry01 += " DADOS2.E1_VLCRUZ AS VALOR, " 
	cQry01 += " DADOS2.E1_SALDO AS SALDO, "
	cQry01 += " DADOS2.VLRORIGINAL, "
		
	cQry01 += " ((DADOS2.RS_REC + case when DADOS2.RS_AB IS null OR DADOS2.RS_REC <= 0 then 0 else DADOS2.RS_AB end)- DADOS2.RS_PAG- DADOS2.RS_JUR) AS CALCULADO "
		
	cQry01 += " FROM " 
		
	cQry01 += " (SELECT "
		
	cQry01 += " DADOS1.E1_FILIAL, "
	cQry01 += " DADOS1.E1_PREFIXO,"
	cQry01 += " DADOS1.E1_NUM, "
	cQry01 += " DADOS1.E1_PARCELA, "
	cQry01 += " DADOS1.E1_TIPO, "
	cQry01 += " DADOS1.E1_CLIENTE, "
	cQry01 += " DADOS1.E1_LOJA, "
	cQry01 += " DADOS1.E1_VEND1,"
	cQry01 += " DADOS1.E1_NOMCLI,"
	cQry01 += " DADOS1.E1_VALOR AS VLRORIGINAL, "
	cQry01 += " DADOS1.E1_SALDO, "
		
	cQry01 += " CONVERT(VARCHAR(10),CAST(DADOS1.E1_EMISSAO AS DATE),103) AS 'EMISSAO', "
	cQry01 += " CONVERT(VARCHAR(10),CAST(DADOS1.E1_VENCTO  AS DATE),103) AS 'VENCTO',  "
	cQry01 += " CONVERT(VARCHAR(10),CAST(DADOS1.E1_VENCORI AS DATE),103) AS 'VENCORI', "
	cQry01 += " CONVERT(VARCHAR(10),CAST(DADOS1.E1_VENCREA AS DATE),103) AS 'VENCREA', "
		
	cQry01 += " DADOS1.E1_VLCRUZ, "
		
	cQry01 += " case when DADOS1.rs_rec IS null then 0 else DADOS1.rs_rec end RS_REC, "
	cQry01 += " case when DADOS1.rs_pag IS null then 0 else DADOS1.rs_pag end RS_PAG, "
	cQry01 += " case when DADOS1.rs_jur IS null then 0 else DADOS1.rs_jur end RS_JUR, "
		
		
	cQry01 += " (SELECT SUM(E1_VALOR)  as rs_ab "
	cQry01 += " FROM " + RetSqlName( "SE1" ) + " SE1 (NOLOCK) WHERE SE1.E1_CLIENTE = DADOS1.E1_CLIENTE AND SE1.D_E_L_E_T_  = '' "
	cQry01 += " AND SE1.E1_LOJA = DADOS1.E1_LOJA "
	cQry01 += " AND SE1.E1_NUM =  DADOS1.E1_NUM  "
	cQry01 += " AND SE1.E1_PARCELA = DADOS1.E1_PARCELA "
	cQry01 += " AND SE1.E1_TIPO = 'AB-') AS RS_AB "
		
	cQry01 += " FROM "
	cQry01 += " 	( "
	cQry01 += " SELECT "
	cQry01 += " E1_FILIAL,"
	cQry01 += " E1_PREFIXO,"
	cQry01 += " E1_NUM,"
	cQry01 += " E1_PARCELA, "
	cQry01 += " E1_TIPO,"
	cQry01 += " E1_CLIENTE,"
	cQry01 += " E1_LOJA, "
	cQry01 += " E1_VEND1, "
	cQry01 += " E1_NOMCLI,"
	cQry01 += " E1_EMISSAO, "
	cQry01 += " E1_VENCTO, "
	cQry01 += " E1_VENCORI,"
	cQry01 += " E1_VENCREA," 
	cQry01 += " E1_VLCRUZ, "
	cQry01 += " E1_SALDO, "
	cQry01 += " E1_VALOR,"
	cQry01 += " ( "
	
	cQry01 += " SELECT "
	cQry01 += " SUM(DADOS.RS_REC) AS RS_REC " 
	cQry01 += " FROM " 
		
	cQry01 += " (SELECT " 
	
	//Everson - 20/12/2018. Chamado 045776.
	cQry01 += " case "
	cQry01 += " when (E5_TIPODOC IN ('CM','VM')) then E5_VALOR *-1 "
	cQry01 += " when E5_ORIGEM = 'EECAE100' AND E5_VALOR < 0 then E5_VALOR * -1 "  
	cQry01 += " when E5_PREFIXO ='EEC'	    AND E5_VALOR < 0 then E5_VALOR * -1 "  
	cQry01 += " else E5_VALOR end RS_REC " 
		
	/*cQry01 += " case "
	cQry01 += " when E5_ORIGEM = 'EECAE100' AND E5_VALOR < 0 then E5_VALOR * -1 " 
	cQry01 += " when E5_PREFIXO ='EEC'	    AND E5_VALOR < 0 then E5_VALOR * -1 " 
	cQry01 += " else E5_VALOR end RS_REC "*/
		
	cQry01 += " FROM " + RetSqlName( "SE5" ) + " SE5 (NOLOCK) WHERE SE5.E5_CLIFOR =  E1_CLIENTE AND SE5.D_E_L_E_T_  = '' "
	cQry01 += " AND SE5.E5_LOJA = E1_LOJA
	cQry01 += " AND SE5.E5_NUMERO = E1_NUM
	cQry01 += " AND SE5.E5_PARCELA = E1_PARCELA
	
	//Everson - 20/12/2018. Chamado 045776.
	cQry01 += " AND (SE5.E5_TIPO = E1_TIPO OR SE5.E5_TIPO ='RA') "
	//cQry01 += " AND SE5.E5_TIPO = E1_TIPO
	
	cQry01 += " AND SE5.E5_RECPAG = 'R'
	cQry01 += " AND SE5.E5_SITUACA NOT IN ('C')
	cQry01 += " AND SE5.E5_DATA <= '"+cDtFin+ "' "
	cQry01 += " AND SE5.E5_TIPODOC NOT IN('JR','E2','J2','TR')) AS DADOS ) AS rs_rec,"
				
	cQry01 += " (SELECT  SUM(E5_VALOR) as rs_pag "
	cQry01 += " FROM " + RetSqlName( "SE5" ) + " SE5 (NOLOCK) WHERE SE5.E5_CLIFOR = E1_CLIENTE AND SE5.D_E_L_E_T_  = '' "
	cQry01 += " AND SE5.E5_LOJA = E1_LOJA "
	cQry01 += " AND SE5.E5_NUMERO = E1_NUM "
	cQry01 += " AND SE5.E5_PARCELA = E1_PARCELA"
	cQry01 += " AND SE5.E5_TIPO = E1_TIPO"
	cQry01 += " AND SE5.E5_RECPAG = 'P' "
	cQry01 += " AND SE5.E5_SITUACA NOT IN ('C')"
	cQry01 += " AND SE5.E5_DATA <= '"+cDtFin+"'"
	
	cQry01 += " AND SE5.E5_TIPODOC NOT IN('JR','J2','E2') "
	
	cQry01 += " GROUP BY E5_CLIFOR,E5_LOJA,E5_PREFIXO,E5_NUMERO,E5_PARCELA, E5_RECPAG) AS rs_pag,"
				
	cQry01 += " (SELECT SUM(E5_VALOR) as rs_jur"
	cQry01 += " FROM " + RetSqlName( "SE5" ) + " SE5 (NOLOCK)  WHERE SE5.E5_CLIFOR = E1_CLIENTE AND SE5.D_E_L_E_T_  = ''"
	cQry01 += " AND SE5.E5_LOJA = E1_LOJA "
	cQry01 += " AND SE5.E5_NUMERO =  E1_NUM"
	cQry01 += " AND SE5.E5_PARCELA = E1_PARCELA "
	cQry01 += " AND SE5.E5_TIPO = E1_TIPO"
	cQry01 += " AND SE5.E5_RECPAG = 'R' "
	cQry01 += " AND SE5.E5_SITUACA NOT IN ('C')"
	cQry01 += " AND SE5.E5_DATA <= '"+cDtFin+"'"
	cQry01 += " AND SE5.E5_TIPODOC IN('JR','J2')"
	cQry01 += " AND SE5.E5_TIPODOC NOT IN('E2')"
	cQry01 += " GROUP BY E5_CLIFOR,E5_LOJA,E5_PREFIXO,E5_NUMERO,E5_PARCELA, E5_RECPAG) AS rs_jur "
	cQry01 += " FROM " + RetSqlName( "SE1" ) + " SE1 (NOLOCK) "
	cQry01 += " WHERE (SE1.E1_VENCREA  BETWEEN '"+cDtIni+"' AND '"+cDtFin+"') AND SE1.D_E_L_E_T_ <> '*' AND E1_TIPO IN ('NF') AND E1_CLIENTE NOT IN ('031017','016652')) AS DADOS1 "
	cQry01 += " )DADOS2 "
	cQry01 += " )DADOS3 "			
	       
Return (cQry01)  

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_EFIC_COB.XML")

Return Nil

Static Function CriaExcel()              

	oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_EFIC_COB.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return Nil

Static Function MontaPerg()  
                                
	Private bValid := Nil 
	Private cF3	   := Nil
	Private cSXG   := Nil
	Private cPyme  := Nil
	
	U_xPutSx1(cPerg,'01','Data Vcnto de     ?','','','mv_ch01','D',08,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR01')
	U_xPutSx1(cPerg,'02','Data Vcnto Ate    ?','','','mv_ch02','D',08,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR02')
	
    Pergunte(cPerg,.F.)
	
Return Nil            