#Include "Protheus.ch"  
#Include "Fileio.ch"
#Include "TopConn.ch"  
#Include "Rwmake.ch"     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADCOM007R ºAutor  ³William Costa       º Data ³  02/02/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio Ganho de Negociacao                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADCOM007R()

 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="Relatório Ganho de Negociacao"    
	Private oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	Private oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	Private oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	Private oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	Private oPrn		:=TMSPrinter():New()
	Private nOpca		:=0
	Private cPerg		:= 'ADCOM007R'
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	//+------------------------------------------------+
	//|Cria grupo de perguntas.                        |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o usuário.     |            
	//+------------------------------------------------+
	Aadd(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	Aadd(aSays,"Relatorio Ganho de Negociacao" )
    
	Aadd(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	Aadd(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||ComADCOM007R()},"Gerando arquivo","Aguarde...")}})
	Aadd(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch(cCadastro, aSays, aButtons)  
	
Return Nil

Static Function ComADCOM007R() 

 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	Private oExcel      := FWMSEXCEL():New()
	Private cPath       := 'D:\Totvs\Protheus11_Homolog\protheus_data\system\'
	Private cArquivo    := 'REL_GANHO_NEGOCIACAO.XML'
	Private oMsExcel
	Private cPlanilha   := "Ganho de Negociacao"
	Private cTitulo     := "Ganho de Negociacao"
	Private cCodProdSql := '' 
	Private cFilSql     := ''
	Private aLinhas     := {}
   
	Begin Sequence
		
		//Verifica se há o excel instalado na máquina do usuário.
		If ! ( ApOleClient("MsExcel") ) 
		
			MsgStop("Não Existe Excel Instalado","Função ComADCOM007R(ADCOMR007)")   
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
		
		MsgInfo("Arquivo Excel gerado!","Função ComADCOM007R(ADCOMR007)")    
	    
	End Sequence

Return Nil 

Static Function Cabec() 

	oExcel:AddworkSheet(cPlanilha)
	
	//Pedido.
	oExcel:AddTable (cPlanilha,cTitulo)
	oExcel:AddColumn(cPlanilha,cTitulo,"Data "			      ,1,1) // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"Num Solicitacao   "	  ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Num Pedido "		  ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"Produto "    		  ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"Prioridade "		  ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"Centro de Custo "	  ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"Descricao CC "		  ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"Local "		          ,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"Almoxarifado "		  ,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"Cod. Usuario "		  ,1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"Usuario "	          ,1,1) // 11 K
	oExcel:AddColumn(cPlanilha,cTitulo,"Cod Cond. Pagamento " ,1,1) // 12 L
	oExcel:AddColumn(cPlanilha,cTitulo,"Cond Pagamento "	  ,1,1) // 13 M
	oExcel:AddColumn(cPlanilha,cTitulo,"Cod. Fornece "	      ,1,1) // 14 N
	oExcel:AddColumn(cPlanilha,cTitulo,"Cod. Loja   "		  ,1,1) // 15 O
	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Fornec "		  ,1,1) // 16 P
	oExcel:AddColumn(cPlanilha,cTitulo,"Valor Inicial "	 	  ,1,1) // 17 Q
	oExcel:AddColumn(cPlanilha,cTitulo,"Valor Final "		  ,1,1) // 18 R
	oExcel:AddColumn(cPlanilha,cTitulo,"Ganho % "		      ,1,1) // 19 S
	oExcel:AddColumn(cPlanilha,cTitulo,"Desconto "		      ,1,1) // 20 T
	
Return Nil

Static Function GeraExcel()

	Local nLinha		:= 0
	Local nExcel     	:= 0
	Local nTotReg		:= 0
	Local cNumPC        := ''
		
	SqlPedidos()
	
	//Conta o Total de registros.
	nTotReg := Contar("TRB","!Eof()")
	
	//Valida a quantidade de registros.
	If nTotReg <= 0
		MsgStop("Não há registros para os parâmetros informados.","Função GeraExcel(ADCOMR002)")
		Return .F.
		
	EndIf
	
	//Atribui a quantidade de registros à régua de processamento.
	ProcRegua(nTotReg)
	TRB->(DbGoTop())
	While !TRB->(Eof()) 
	
		cNumPC := Alltrim(cValToChar(TRB->C7_NUM ))
	
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
	   	               "", ; // 15 O   
	   	               "", ; // 16 P   
	   	               "", ; // 17 Q
	   	               "", ; // 18 R   
	   	               "", ; // 19 S     
	   	               "";   // 20 T 
	                      })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
		
		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================   
		
		//Dados do pedido.
		aLinhas[nLinha][01] := STOD(TRB->C7_EMISSAO)                                     // 01 A	
		aLinhas[nLinha][02] := TRB->C8_NUM                                               // 02 B
		aLinhas[nLinha][03] := TRB->C7_NUM                                               // 03 C
		aLinhas[nLinha][04] := TRB->C7_PRODUTO                                           // 04 D
		aLinhas[nLinha][05] := TRB->PRIORIDADE                                           // 05 E
		aLinhas[nLinha][06] := TRB->C7_CC                                                // 06 F
		aLinhas[nLinha][07] := Posicione("CTT",1,xFilial("CTT")+TRB->C7_CC,"CTT_DESC01") // 07 G
		aLinhas[nLinha][08] := TRB->C7_LOCAL                                             // 08 H
		aLinhas[nLinha][09] := TRB->NNR_DESCRI   		                                 // 09 I
		aLinhas[nLinha][10] := TRB->C7_USER                                              // 10 J
		aLinhas[nLinha][11] := UsrRetName(TRB->C7_USER)                                  // 11 K
		aLinhas[nLinha][12] := TRB->C7_COND                                              // 12 L
		aLinhas[nLinha][13] := TRB->E4_DESCRI                                            // 13 M
		aLinhas[nLinha][14] := TRB->C7_FORNECE                                           // 14 N
		aLinhas[nLinha][15] := TRB->C7_LOJA                                              // 15 O
		aLinhas[nLinha][16] := TRB->A2_NOME                                              // 16 P
		aLinhas[nLinha][17] := TRB->C8_XPRCCOT                                           // 17 Q
		aLinhas[nLinha][18] := TRB->C7_PRECO                                             // 18 R
		aLinhas[nLinha][19] := TRB->GANHO   		                                     // 19 S
		aLinhas[nLinha][20] := TRB->C7_DESC                                              // 20 T
		
		TRB->(DBSKIP())    
		
	ENDDO
	
	TRB->(DbCloseArea())    
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	For nExcel := 1 To nLinha
		
		
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
								         aLinhas[nExcel][15],;  // 15 O  
								         aLinhas[nExcel][16],;  // 16 P 
								         aLinhas[nExcel][17],;  // 17 Q 
								         aLinhas[nExcel][18],;  // 18 R 
								         aLinhas[nExcel][19],;  // 19 S
								         aLinhas[nExcel][20] ;  // 20 T
													      	 }) 	
													      	 			
   Next nExcel 
 	//============================== FINAL IMPRIME LINHA NO EXCEL
 	
Return .T.                       

Static Function SqlPedidos()   

	Local cFil   := xFilial("SC7")
	Local cDtIni := DTOS(MV_PAR01) 
	Local cDtFin := DTOS(MV_PAR02)

	BeginSQL Alias "TRB"
		     %NoPARSER% 
		     SELECT SC7.C7_EMISSAO,
					ISNULL(SC8.C8_NUM,'') AS C8_NUM,
					SC7.C7_NUM,
					SC7.C7_PRODUTO,
					ISNULL(CASE SC7.C7_XGRCOMP WHEN '1' THEN 'COMPRA NORMAL' WHEN '2' THEN 'COMPRA URGENTE' END, '') PRIORIDADE,
					SC7.C7_LOCAL,
					NNR.NNR_DESCRI,
					SC7.C7_USER,
					SC7.C7_COND,
					SE4.E4_DESCRI,
					SC7.C7_FORNECE,
					SC7.C7_LOJA,
					SA2.A2_NOME,
					SC8.C8_XPRCCOT,
					SC7.C7_PRECO,
			        CASE WHEN SC8.C8_XPRCCOT > 0 THEN  (CONVERT(DECIMAL(15,2),(SC7.C7_PRECO / SC8.C8_XPRCCOT - 1)) * 100) ELSE 0 END AS 'GANHO',
				    SC7.C7_DESC,
				    SC7.C7_CC
				FROM %Table:SC7% SC7
			LEFT JOIN %Table:SC8% SC8  
					ON  SC8.C8_FILIAL   = SC7.C7_FILIAL
					AND SC8.C8_NUM      = SC7.C7_NUMCOT
					AND SC8.C8_PRODUTO  = SC7.C7_PRODUTO
					AND	SC8.C8_FORNECE  = SC7.C7_FORNECE
					AND	SC8.C8_LOJA     = SC7.C7_LOJA
					AND	SC8.C8_NUMPED   = SC7.C7_NUM
					AND	SC8.C8_ITEMPED  = SC7.C7_ITEM
					AND SC8.D_E_L_E_T_ <> '*'
			INNER JOIN %Table:SB1% SB1 
					ON SC7.C7_PRODUTO   = SB1.B1_COD 
					AND SB1.D_E_L_E_T_ <> '*'
			INNER JOIN %Table:NNR% NNR 
					ON SC7.C7_LOCAL     =  NNR.NNR_CODIGO
					AND NNR.D_E_L_E_T_ <> '*'
			INNER JOIN %Table:SA2% SA2
					ON SA2.A2_COD       = SC7.C7_FORNECE
					AND SA2.A2_LOJA     = SC7.C7_LOJA
					AND SA2.D_E_L_E_T_ <> '*'
			INNER JOIN %Table:SE4% SE4
					ON SE4.E4_CODIGO    = SC7.C7_COND
					AND SE4.D_E_L_E_T_ <> '*'
			      WHERE SC7.C7_FILIAL   = %EXP:cFil%
				    AND SC7.C7_EMISSAO >= %EXP:cDtIni%
				    AND SC7.C7_EMISSAO <= %EXP:cDtFin%
				    AND SC7.C7_NUM     >= %EXP:MV_PAR03%
				    AND SC7.C7_NUM     <= %EXP:MV_PAR04%
				    AND SC7.C7_USER    >= %EXP:MV_PAR05%
				    AND SC7.C7_USER    <= %EXP:MV_PAR06%
			        AND SC7.D_E_L_E_T_ <> '*'
			
			ORDER BY C7_NUM

	EndSQl

Return (NIL)  

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_GANHO_NEGOCIACAO.XML")

Return Nil

Static Function CriaExcel()              

	oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_GANHO_NEGOCIACAO.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return Nil

Static Function MontaPerg()  
                                
	Private bValid := Nil 
	Private cF3	   := Nil
	Private cSXG   := Nil
	Private cPyme  := Nil
	
	PutSx1(cPerg,'01','Data de 	   ?','','','mv_ch1','D',08,0,0,'G',bValid,cF3    ,cSXG,cPyme,'MV_PAR01')
	PutSx1(cPerg,'02','Data até    ?','','','mv_ch2','D',08,0,0,'G',bValid,cF3    ,cSXG,cPyme,'MV_PAR02')
	PutSx1(cPerg,'03','Num Ped de  ?','','','mv_ch3','C',06,0,0,'G',bValid,"SC7"  ,cSXG,cPyme,'MV_PAR03')
	PutSx1(cPerg,'04','Num Ped Ate ?','','','mv_ch4','C',06,0,0,'G',bValid,"SC7"  ,cSXG,cPyme,'MV_PAR04')
	PutSx1(cPerg,'05','Usuario de  ?','','','mv_ch5','C',06,0,0,'G',bValid,"USR"  ,cSXG,cPyme,'MV_PAR05')
	PutSx1(cPerg,'06','Usuario Ate ?','','','mv_ch6','C',06,0,0,'G',bValid,"USR"  ,cSXG,cPyme,'MV_PAR06')

    Pergunte(cPerg,.F.)
	
Return Nil            