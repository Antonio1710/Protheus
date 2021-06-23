/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADCOM002R ºAutor  ³William Costa       º Data ³  15/10/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio Comparativo de Precos de Compra                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#Include "Protheus.ch"  
#Include "Fileio.ch"
#Include "TopConn.ch"  
#Include "Rwmake.ch"     

User Function ADCOM002R() // U_ADCOM002R()

 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="Relatório Comparativo de Preços de Compra"    
	Private oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	Private oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	Private oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	Private oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	Private oPrn		:=TMSPrinter():New()
	Private nOpca		:=0
	Private cPerg		:= 'ADCOM002R'
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	//+------------------------------------------------+
	//|Cria grupo de perguntas.                        |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o usuário.     |            
	//+------------------------------------------------+
	Aadd(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	Aadd(aSays,"Relatorio Comparativo de Preços de Compra" )
    
	Aadd(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	Aadd(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||ComADCOM002R()},"Gerando arquivo","Aguarde...")}})
	Aadd(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch(cCadastro, aSays, aButtons)  
	
Return Nil

Static Function ComADCOM002R() 

 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	Private oExcel      := FWMSEXCEL():New()
	Private cPath       := 'D:\Totvs\Protheus11_Homolog\protheus_data\system\'
	Private cArquivo    := 'REL_COMPARATIVO_PRECOS_COMPRAS.XML'
	Private oMsExcel
	Private cPlanilha   := "Comparativo de Precos de Compra"
	Private cTitulo     := "Comparativo de Precos de Compra"
	Private cCodProdSql := '' 
	Private cFilSql     := ''
	Private aLinhas     := {}
   
	Begin Sequence
		
		//Verifica se há o excel instalado na máquina do usuário.
		If ! ( ApOleClient("MsExcel") ) 
		
			MsgStop("Não Existe Excel Instalado","Função ComADCOM002R(ADCOMR002)")   
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
		
		MsgInfo("Arquivo Excel gerado!","Função ComADCOM002R(ADCOMR002)")    
	    
	End Sequence

Return Nil 

Static Function Cabec() 

	oExcel:AddworkSheet(cPlanilha)
	
	//Pedido.
	oExcel:AddTable (cPlanilha,cTitulo)
	oExcel:AddColumn(cPlanilha,cTitulo,"Data "			,1,1) // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"Pedido   "		,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Item "			,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"Grupo "			,1,1) // 04 D && sigoli Chamado 032556 e 032561 Chamado 17/01/2016
	oExcel:AddColumn(cPlanilha,cTitulo,"Produto "		,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"Descricao "		,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"UN "			,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"Quantidade "	,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"Vl Unit Ped "	,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"Total Pedido "	,1,1) // 10 J
	
	//Pedido anterior.
	oExcel:AddColumn(cPlanilha,cTitulo,"Data Ped. Ant. "	,1,1) // 11 K
	oExcel:AddColumn(cPlanilha,cTitulo,"Pedido Ant.   "		,1,1) // 12 L
	oExcel:AddColumn(cPlanilha,cTitulo,"Vl Unit Ant. "		,1,1) // 13 M
	oExcel:AddColumn(cPlanilha,cTitulo,"Total Pedido "		,1,1) // 14 N
	oExcel:AddColumn(cPlanilha,cTitulo,"Variação % "		,1,1) // 15 O
	
Return Nil

Static Function GeraExcel()

 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	Local nLinha		:= 0
	Local nExcel     	:= 0
	Local nTotReg		:= 0
	Local cQuery		:= ""
	Local aDadosPcAnt	:= {}
	Local nValTotal		:= 0
	Local nVariacao		:= 0
	Local cNumPC		:= ""
	Local i				:= 0
	Local nTotPedido	:= 0
	Local nTotPedAnt	:= 0
	Local nItensPed		:= 0
	Local nItensAnt		:= 0
	
	//Obtém script sql.
	cQuery := SqlPedidos(cValToChar(MV_PAR01), cValToChar(MV_PAR02), DToS(MV_PAR03), DToS(MV_PAR04),;
	 						Alltrim(cValToChar(MV_PAR05)), Alltrim(cValToChar(MV_PAR06)), Alltrim(cValToChar(MV_PAR07)),Alltrim(cValToChar(MV_PAR08)),;
	 						Alltrim(cValToChar(MV_PAR09)), Alltrim(cValToChar(MV_PAR10)))
	
	//Verifica se o alias já existe.
	If Select("TRA") > 0
		TRA->(DbCloseArea())
		
	EndIf
	
	//Excuta consulta no BD.
	TcQuery cQuery New Alias "TRA"
	DbSelectArea("TRA")
	
	//Conta o Total de registros.
	nTotReg := Contar("TRA","!Eof()")
	
	//Valida a quantidade de registros.
	If nTotReg <= 0
		MsgStop("Não há registros para os parâmetros informados.","Função GeraExcel(ADCOMR002)")
		Return .F.
		
	EndIf
	
	//Solicita a confirmação do usuário.
	If ! MsgYesNo("O relatório será gerado com " + cValToChar(nTotReg) + " registros . Deseja prosseguir?","Função GeraExcel(ADCOMR002)")
		Return .F.
		
	EndIf
	
	//Atribui a quantidade de registros à régua de processamento.
	ProcRegua(nTotReg)
	
	TRA->(DbGoTop())
	While ! TRA->(Eof()) 
	
		cNumPC := Alltrim(cValToChar(TRA->C7_NUM ))
	
		IncProc("Processando Ped. Comp. " + cNumPC)     
					 
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
	                   "";   // 15 0 
	                      })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
		
		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================   
		
		//Dados do pedido.
		aLinhas[nLinha][01] := STOD(TRA->C7_EMISSAO)	
		aLinhas[nLinha][02] := TRA->C7_NUM           
		aLinhas[nLinha][03] := TRA->C7_ITEM          
		aLinhas[nLinha][04] := TRA->B1_GRUPO   && sigoli Chamado 032556 e 032561 Chamado 17/01/2016        
		aLinhas[nLinha][05] := TRA->C7_PRODUTO        
		aLinhas[nLinha][06] := TRA->C7_DESCRI   		
		aLinhas[nLinha][07] := TRA->C7_UM             
		aLinhas[nLinha][08] := TRA->C7_QUANT          
		aLinhas[nLinha][09] := TRA->C7_PRECO 
		aLinhas[nLinha][10] := TRA->C7_TOTAL     
		
		//Totalizador do pedido.
		nTotPedido += TRA->C7_TOTAL   
		nItensPed++
		
		
		//Obtém dados do pedido anterior.
		aDadosPcAnt := dadosPcAnt(cValToChar(MV_PAR01),cValToChar(MV_PAR02),cValToChar(TRA->C7_NUM ),;
												  cValToChar(TRA->C7_PRODUTO ),cValToChar(TRA->C7_EMISSAO))
		
		//Valida retorno da função dadosPcAnt.
		If Len(aDadosPcAnt) > 0 .And. ! Empty(Alltrim(cValToChar(aDadosPcAnt[1][1])))
			
			nValTotal := Val(cValToChar(aDadosPcAnt[1][7])) * TRA->C7_QUANT
			nVariacao := ((Val(cValToChar(TRA->C7_TOTAL)) - nValTotal) / Iif(nValTotal > 0,nValTotal,1)) * 100
			
			aLinhas[nLinha][11] := STOD(aDadosPcAnt[1][1])
			aLinhas[nLinha][12] := aDadosPcAnt[1][2]
			aLinhas[nLinha][13] := aDadosPcAnt[1][7]
			aLinhas[nLinha][14] := nValTotal
			aLinhas[nLinha][15] := nVariacao
			
			//Totalizador do pedido anterior.
			nTotPedAnt += nValTotal
			nItensAnt++
			
		EndIf
			
		TRA->(dbSkip())    
		
		If	cNumPC <> Alltrim(cValToChar(TRA->C7_NUM ))
			
			nLinha  := nLinha + 1
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
	   	               "", ; // 14 M 
	   	               "", ; // 15 0   
	                      })
		
			
			//Adiciona totalizadores.
			aLinhas[nLinha][01] := ""
			aLinhas[nLinha][02] := ""       
			aLinhas[nLinha][03] := ""      
			aLinhas[nLinha][04] := ""      
			aLinhas[nLinha][05] := ""		
			aLinhas[nLinha][06] := "Total comparativo do pedido " + cNumPC + " ------>"         
			aLinhas[nLinha][07] := ""
			aLinhas[nLinha][08] := ""
			aLinhas[nLinha][09] := ""
			aLinhas[nLinha][10] := nTotPedido
			aLinhas[nLinha][11] := Iif(nItensPed <> nItensAnt,"***Não foi possível","")
			aLinhas[nLinha][12] := Iif(nItensPed <> nItensAnt,"obter os dados","") 
			aLinhas[nLinha][13] := Iif(nItensPed <> nItensAnt,"de todos os itens***","") 
			aLinhas[nLinha][14] := nTotPedAnt        
			aLinhas[nLinha][15] := Iif(nTotPedAnt > 0,Round(((nTotPedido - nTotPedAnt)/nTotPedAnt) * 100,2),0)
			aLinhas[nLinha][16] := ""
			
			//Zera totalizadores.
			nTotPedido	:= 0
			nTotPedAnt	:= 0
			nItensPed	:= 0
			nItensAnt	:= 0
			
			nLinha  := nLinha + 1
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
	   	               "", ; // 14 M
	   	               ""  ; // 15 N   
	                      })
	  	
	  	//Adiciona linha em branco.
		aLinhas[nLinha][01] := ""
		aLinhas[nLinha][02] := ""       
		aLinhas[nLinha][03] := ""      
		aLinhas[nLinha][04] := ""      
		aLinhas[nLinha][05] := ""  		
		aLinhas[nLinha][06] := ""        
		aLinhas[nLinha][07] := ""
		aLinhas[nLinha][10] := ""
		aLinhas[nLinha][11] := ""
		aLinhas[nLinha][12] := ""
		aLinhas[nLinha][09] := ""    
		aLinhas[nLinha][13] := ""
		aLinhas[nLinha][14] := ""
		aLinhas[nLinha][15] := ""
			
		EndIf 
		
	EndDo
	
	TRA->(DbCloseArea())    
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	For nExcel := 1 To nLinha
		
		
   		oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],;    // 01 A  
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
								              aLinhas[nExcel][15] ;  // 15 O  && sigoli Chamado 032556 e 032561 Chamado 17/01/2016 
													      	 }) 	
													      	 			
   Next nExcel 
 	//============================== FINAL IMPRIME LINHA NO EXCEL
 	
Return .T.                       

Static Function SqlPedidos(cFilDe, cFilAte, cDtDe, cDtAte, cProdDe, cProdAte, cGrupoDe, cGrupoAte, cCCDe, cCCAte)

 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 	
	Local cQuery	:= ""

	cQuery := ""
	cQuery += " SELECT "
	cQuery += " C7_EMISSAO, C7_NUM, C7_ITEM, B1_GRUPO ,C7_PRODUTO, C7_UM, C7_DESCRI, C7_QUANT, C7_PRECO, C7_TOTAL "&& sigoli Chamado 032556 e 032561 Chamado 17/01/2016
		
	cQuery += " FROM "
	cQuery += " " + RetSqlName("SC7") + " AS SC7 "
	cQuery += " INNER JOIN "
	cQuery += " " + RetSqlName("SB1") + " AS SB1 ON "
	cQuery += " C7_PRODUTO = B1_COD "
		
	cQuery += " WHERE "
	cQuery += " SC7.D_E_L_E_T_ = '' "
	cQuery += " AND SB1.D_E_L_E_T_ = '' "
	cQuery += " AND C7_FILIAL  >= '" + cFilDe + "' "
	cQuery += " AND C7_FILIAL  <= '" + cFilAte + "' "
	cQuery += " AND C7_EMISSAO >= '" + cDtDe + "' "
	cQuery += " AND C7_EMISSAO <= '" + cDtAte + "' "
	cQuery += " AND C7_PRODUTO >= '" + cProdDe + "' "
	cQuery += " AND C7_PRODUTO <= '" + cProdAte + "' "
	cQuery += " AND C7_RESIDUO  = '' " && sigoli Chamado 032556 e 032561 Chamado 17/01/2016
	If mv_par11 = 1
		cQuery += " AND C7_ENCER = 'E' " && sigoli Chamado 032556 e 032561 Chamado 17/01/2016
	EndIF
	//cQuery += " AND C7_QUJE > 0 "
	
		
	cQuery += " AND C7_CC >= '" + cCCDe + "' "
	cQuery += " AND C7_CC <= '" + cCCAte + "' "
		
	cQuery += " AND B1_GRUPO >= '" + cGrupoDe + "' "
	cQuery += " AND B1_GRUPO <= '" + cGrupoAte +"' "
		
	cQuery += " ORDER BY C7_EMISSAO, C7_NUM, C7_ITEM "

Return cQuery   

Static Function dadosPcAnt(cFilDe,cFilAte,cNumPed,cProduto,cData)

 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 	
	Local cQuery		:= ""
	Local aRetorno	:= {}

	cQuery := ""
	cQuery += " SELECT " 
		cQuery += " TOP 1 C7_EMISSAO, C7_NUM, C7_PRODUTO, C7_DESCRI, C7_ITEM, C7_QUANT, C7_PRECO, C7_TOTAL " 
		
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SC7") + " AS SC7 " 
	
	cQuery += " WHERE " 
		cQuery += " SC7.D_E_L_E_T_ = '' " 
		cQuery += " AND C7_FILIAL >= '" + cFilDe +  "' " 
		cQuery += " AND C7_FILIAL <= '" + cFilAte + "' " 
		cQuery += " AND C7_NUM < '" + cNumPed + "' " 
		cQuery += " AND C7_PRODUTO = '" + cProduto + "' " 
		cQuery += " AND C7_EMISSAO <= '" + cData + "' "
		cQuery += " AND C7_RESIDUO  = '' " && sigoli Chamado 032556 e 032561 Chamado 17/01/2016
		If mv_par11 = 1
			cQuery += " AND C7_ENCER = 'E' " && sigoli Chamado 032556 e 032561 Chamado 17/01/2016
		EndIF
		//cQuery += " AND C7_QUJE > 0 "
		
	cQuery += " ORDER BY C7_NUM DESC " 
	
	If Select("DADOS_ANT") > 0
		DADOS_ANT->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "DADOS_ANT"
	
	DbSelectArea("DADOS_ANT")
	
		Aadd(aRetorno,{;
							DADOS_ANT->C7_EMISSAO,;
							DADOS_ANT->C7_NUM,;
							DADOS_ANT->C7_PRODUTO,;
							DADOS_ANT->C7_DESCRI,;
							DADOS_ANT->C7_ITEM,;
							DADOS_ANT->C7_QUANT,;
							DADOS_ANT->C7_PRECO,;
							DADOS_ANT->C7_TOTAL;
						})
						
	DbCloseArea("DADOS_ANT")

Return aRetorno                                 

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_COMPARATIVO_PRECOS_COMPRAS.XML")

Return Nil

Static Function CriaExcel()              

	oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_COMPARATIVO_PRECOS_COMPRAS.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return Nil

Static Function MontaPerg()  
                                
	Private bValid:= Nil 
	Private cF3	:= Nil
	Private cSXG	:= Nil
	Private cPyme	:= Nil
	
	PutSx1(cPerg,'01','Filial De   ','','','mv_ch1','C',02,0,0,'G',bValid,cF3    ,cSXG,cPyme,'MV_PAR01')
	PutSx1(cPerg,'02','Filial Ate  ','','','mv_ch2','C',02,0,0,'G',bValid,cF3    ,cSXG,cPyme,'MV_PAR02')
	
	PutSx1(cPerg,'03','Data de 	   ','','','mv_ch3','D',08,0,0,'G',bValid,cF3    ,cSXG,cPyme,'MV_PAR03')
	PutSx1(cPerg,'04','Data até    ','','','mv_ch4','D',08,0,0,'G',bValid,cF3    ,cSXG,cPyme,'MV_PAR04')
	
	PutSx1(cPerg,'05','Produto de  ','','','mv_ch5','C',06,0,0,'G',bValid,"SB1"  ,cSXG,cPyme,'MV_PAR05')
	PutSx1(cPerg,'06','Produto Ate ','','','mv_ch6','C',06,0,0,'G',bValid,"SB1"  ,cSXG,cPyme,'MV_PAR06')
	
	PutSx1(cPerg,'07','Grupo de    ','','','mv_ch7','C',04,0,0,'G',bValid,"SBM"  ,cSXG,cPyme,'MV_PAR07')
	PutSx1(cPerg,'08','Grupo Ate   ','','','mv_ch8','C',04,0,0,'G',bValid,"SBM"  ,cSXG,cPyme,'MV_PAR08')
	
	PutSx1(cPerg,'09','Centro Custo de    ','','','mv_ch9' ,'C',04,0,0,'G',bValid,"CTT"  ,cSXG,cPyme,'MV_PAR09')
	PutSx1(cPerg,'10','Centro Custo Ate   ','','','mv_ch10','C',04,0,0,'G',bValid,"CTT"  ,cSXG,cPyme,'MV_PAR10')  
	
	&& sigoli Chamado 032556 e 032561 Chamado 17/01/2016
	PutSX1(cPerg,"11","Tipo relatório ","Tipo relatório " ,"Tipo relatório","mv_ch11"  ,"N",01,0,01,"C","","","","","mv_par11" ,"Encerrados","Encerrados","Encerrados","","Todos","Todos","Todos","","","","","","",""," ")

	
	Pergunte(cPerg,.F.)
	
Return Nil            