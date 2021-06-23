#Include "Protheus.ch"  
#Include "Fileio.ch"
#Include "TopConn.ch"  
#Include "Rwmake.ch"  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADFIN060R   ºAutor  ³Fernando Macieira º Data ³  12/07/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Visoes Financeiras em Excel. Chamado n. 042423             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ADFIN060R()
              
 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

	Local alSay		:= {}
	Local alButton	:= {}

	Local lOkParam  := .T.
	Local clTitulo	:= 'BI Financeiro'
	Local clDesc1   := 'O objetivo desta rotina é gerar uma tabela de dados financeiros em Excel, ' 
	Local clDesc2   := 'para geração de visões gerenciais.                                        '
	Local clDesc3   := ''
	Local clDesc4   := ''
	Local clDesc5   := ''

	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="BI Financeiro"      
	Private oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	Private oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	Private oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	Private oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	Private oPrn		:= TMSPrinter():New()
	Private nOpca		:= 0
	//Private cPerg		:= 'ADFIN060R'

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Visoes Financeiras em Excel. Chamado n. 042423')
	
	// Mensagens de Tela Inicial
	AADD(alSay, clDesc1)
	AADD(alSay, clDesc2)
	AADD(alSay, clDesc3)
	AADD(alSay, clDesc4)
	AADD(alSay, clDesc5)
	
	//+------------------------------------------------+
	//|Cria grupo de perguntas.                        |
	//+------------------------------------------------+
/*
	u_xPutSx1(cPerg,"01","Filial De           ?" , "Filial De           ?" , "Filial De           ?" , "mv_ch1","C",2 ,0,0,"G","","SM0","","","mv_par01","","","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg,"02","Filial Ate          ?" , "Filial Ate          ?" , "Filial Ate          ?" , "mv_ch2","C",2 ,0,0,"G","","SM0","","","mv_par02","","","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg,"03","NFiscal De          ?" , "NFiscal De          ?" , "NFiscal De          ?" , "mv_ch3","C",9 ,0,0,"G","","   ","","","mv_par03","","","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg,"04","NFiscal Ate         ?" , "NFiscal Ate         ?" , "NFiscal Ate         ?" , "mv_ch4","C",9 ,0,0,"G","","   ","","","mv_par04","","","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg,"05","Situacao            ?" , "Situacao            ?" , "Situacao            ?" , "mv_ch5","N",1 ,0,1,"C","","","","","mv_par05" ,"Todos","Todos","Todos","1","Pendente","Pendente","Pendente","Baixado","Baixado","Baixado","","","","","","")

	IF !Pergunte(cPerg,.T.)               
    	 Return
	Endif
*/

	// Botoes do Formatch
	aAdd(alButton, {1, .T., {|o|If(lOkParam, (Processa({|lEnd| RunADFIN060R()}),o:oWnd:End()),Aviso('Atenção!!!', 'A opção de Parâmetros desta rotina deve ser acessada antes de sua execucao!', {'Ok'})) } } )
	aAdd(alButton, {2, .T., {|| lOk := .F., FechaBatch()}})
//	aAdd(alButton, {5, .T., {|| AcessaPar(cPerg,@lOkParam) } } )
	
	FormBatch(clTitulo, alSay, alButton)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADFIN060R ºAutor  ³Microsiga           º Data ³  07/12/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RunADFIN060R() 

 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	Private oExcel      := FWMSEXCEL():New()
	Private cPath       := '\protheus_data\system\'
	Private cArquivo    := 'BI_FINANCEIRO.XML'
	Private oMsExcel
	Private cPlanilha   := "BI Financeiro"
	Private cTitulo     := "BI Financeiro"
	Private cCodProdSql := '' 
	Private cFilSql     := ''
	Private aLinhas     := {}

	Private cPlan2   := "BI Visão 01"
	Private cTit2    := "Ano"
	Private sVisM02   := {}
	Private sVisE02   := {}

	Private cPlan3   := "BI Visão 02"
	Private cTit3    := "Ano"
	Private sVisM03   := {}
	Private sVisE03   := {}

	Private cPlan4   := "BI Visão 03"
	Private cTit4    := "Ano"
	Private sVisM04   := {}
	Private sVisE04   := {}
   
	Begin Sequence
		
		//Verifica se há o excel instalado na máquina do usuário.
		If ! ( ApOleClient("MsExcel") ) 
		
			MsgStop("Não Existe Excel Instalado","Função ADFIN060R (ADFIN060R)")   
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
		
		MsgInfo("Arquivo Excel gerado!","Função ADFIN060R (ADFIN060R)")    
	    
	End Sequence

Return Nil 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADFIN060R ºAutor  ³Microsiga           º Data ³  07/12/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Cabec() 

	oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"Filial "  			,1,1) // 01 A
  	oExcel:AddColumn(cPlanilha,cTitulo,"Emissao"        	,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Titulo"             ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"Prefixo"     		,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"Parcela"      		,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"Cliente"    		,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"Valor Titulo"    	,3,2) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"Valor Baixa"      	,3,2) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"Portador"         	,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"Saldo"           	,3,2) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"Status Titulo"    	,1,1) // 11 K
	oExcel:AddColumn(cPlanilha,cTitulo,"Codigo Vendedor"    ,1,1) // 12 L
	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Vendedor"      ,1,1) // 13 M
	oExcel:AddColumn(cPlanilha,cTitulo,"Codigo Supervisor"  ,1,1) // 14 N
	oExcel:AddColumn(cPlanilha,cTitulo,"Codigo Segmento"    ,1,1) // 15 O
	oExcel:AddColumn(cPlanilha,cTitulo,"Beneficiario"       ,1,1) // 16 P
	oExcel:AddColumn(cPlanilha,cTitulo,"Vencto Real"        ,1,1) // 17 Q
	oExcel:AddColumn(cPlanilha,cTitulo,"Dias Titulo"        ,3,2) // 18 R
	oExcel:AddColumn(cPlanilha,cTitulo,"Dias Intervalo"     ,1,1) // 19 S
	oExcel:AddColumn(cPlanilha,cTitulo,"Ano"                ,1,1) // 20 T
	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Supervisor"    ,1,1) // 21 U
	oExcel:AddColumn(cPlanilha,cTitulo,"Desc Segmento"      ,1,1) // 22 V
	oExcel:AddColumn(cPlanilha,cTitulo,"Valor Condicionado" ,3,2) // 23 W

	oExcel:AddworkSheet(cPlan2)
	oExcel:AddTable (cPlan2,cTit2)
	oExcel:AddColumn(cPlan2, cTit2, "Status Titulos", 1, 1)
	oExcel:AddColumn(cPlan2, cTit2, cValToChar(Year(Date())-3), 3, 2)
	oExcel:AddColumn(cPlan2, cTit2, cValToChar(Year(Date())-2), 3, 2)
	oExcel:AddColumn(cPlan2, cTit2, cValToChar(Year(Date())-1), 3, 2)
	oExcel:AddColumn(cPlan2, cTit2, cValToChar(Year(Date()))  , 3, 2)
	oExcel:AddColumn(cPlan2, cTit2, cValToChar(Year(Date())+1), 3, 2)
	oExcel:AddColumn(cPlan2, cTit2, "Total Geral", 3, 2)

	oExcel:AddworkSheet(cPlan3)
	oExcel:AddTable (cPlan3,cTit3)
	oExcel:AddColumn(cPlan3, cTit3, "Segmento", 1, 1)
	oExcel:AddColumn(cPlan3, cTit3, cValToChar(Year(Date())-3), 3, 2)
	oExcel:AddColumn(cPlan3, cTit3, cValToChar(Year(Date())-2), 3, 2)
	oExcel:AddColumn(cPlan3, cTit3, cValToChar(Year(Date())-1), 3, 2)
	oExcel:AddColumn(cPlan3, cTit3, cValToChar(Year(Date()))  , 3, 2)
	oExcel:AddColumn(cPlan3, cTit3, cValToChar(Year(Date())+1), 3, 2)
	oExcel:AddColumn(cPlan3, cTit3, "Total Geral", 2, 2)
	
	oExcel:AddworkSheet(cPlan4)
	oExcel:AddTable (cPlan4,cTit4)
	oExcel:AddColumn(cPlan4, cTit4, "Supervisor", 1, 1)
	oExcel:AddColumn(cPlan4, cTit4, cValToChar(Year(Date())-3), 3, 2)
	oExcel:AddColumn(cPlan4, cTit4, cValToChar(Year(Date())-2), 3, 2)
	oExcel:AddColumn(cPlan4, cTit4, cValToChar(Year(Date())-1), 3, 2)
	oExcel:AddColumn(cPlan4, cTit4, cValToChar(Year(Date()))  , 3, 2)
	oExcel:AddColumn(cPlan4, cTit4, cValToChar(Year(Date())+1), 3, 2)
	oExcel:AddColumn(cPlan4, cTit4, "Total Geral", 3, 2)
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADFIN060R ºAutor  ³Microsiga           º Data ³  07/12/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraExcel()

	Local nLinha   := 0
	Local nExcel   := 0
	Local nTotReg  := 0
	Local cNum     := ''
	Local ADF6Q1TR := 0
	Local lBx      := .F.
	
	//
	cQuery := SQL()
	cQuery += " ORDER BY DADOS.E1_FILIAL,DADOS.E1_NUM,DADOS.E1_PARCELA "
	If Select("TRT") > 0
		TRT->(DbCloseArea())
	EndIf 
	TCQUERY cQuery New Alias "TRT"
	nTotReg := Contar("TRT","!Eof()")  
	
	//Atribui a quantidade de registros à régua de processamento.
	ProcRegua(nTotReg)
	TRT->(DbGoTop())
	Do While !TRT->(Eof()) 
	
		cNum := Alltrim(cValToChar(TRT->E1_FILIAL+"/"+TRT->E1_NUM+"/"+TRT->E1_PARCELA))
	
		IncProc("Gerando excel com dados financeiros " + cNum)     
					 
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
	   	               "", ; // 20 T 
	   	               "", ; // 21 U 
   	               	   "", ; // 22 U	   	               
	   	               ""  ; // 23 W 
						     })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA	
		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================   

//E1_FILIAL	E1_EMISSAO	E1_NUM	E1_PREFIXO	E1_PARCELA	E1_NOMCLI	E1_VALOR	E5_VALOR	E1_BANCO	E1_SALDO	VALIDADO	E1_VEND1	VENDEDOR	CODSUPER	SEGMENTO	
//E5_BENEF	E1_VENCREA	IDADE	STATUS	ANO
// 	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Supervisor"    ,1,1) // 21 U
//	oExcel:AddColumn(cPlanilha,cTitulo,"Desc Segmento"      ,1,1) // 22 V
		
		//Dados do pedido.
		aLinhas[nLinha][01] := TRT->E1_FILIAL       // 01 A	
		aLinhas[nLinha][02] := TRT->E1_EMISSAO      // 02 B
		aLinhas[nLinha][03] := TRT->E1_NUM          // 03 C
		aLinhas[nLinha][04] := TRT->E1_PREFIXO      // 04 D
		aLinhas[nLinha][05] := TRT->E1_PARCELA      // 05 E
		aLinhas[nLinha][06] := TRT->E1_NOMCLI       // 06 F
		aLinhas[nLinha][07] := TRT->E1_VALOR        // 07 G
		aLinhas[nLinha][08] := TRT->E5_VALOR        // 08 H
		aLinhas[nLinha][09] := TRT->E1_BANCO 		// 09 I
		aLinhas[nLinha][10] := TRT->E1_SALDO        // 10 J
		aLinhas[nLinha][11] := TRT->VALIDADO        // 11 K
		aLinhas[nLinha][12] := TRT->E1_VEND1        // 12 L
		aLinhas[nLinha][13] := TRT->VENDEDOR        // 13 M
		aLinhas[nLinha][14] := TRT->CODSUPER        // 14 N
		aLinhas[nLinha][15] := TRT->SEGMENTO        // 15 O
		aLinhas[nLinha][16] := TRT->E5_BENEF        // 16 P
		aLinhas[nLinha][17] := TRT->E1_VENCREA      // 17 Q
		aLinhas[nLinha][18] := TRT->IDADE           // 18 R
		aLinhas[nLinha][19] := TRT->STATUS          // 19 S
		aLinhas[nLinha][20] := TRT->ANO             // 20 T
		aLinhas[nLinha][21] := UpSZR(TRT->CODSUPER)              //Posicione("SZR",1,xFilial("SZR")+TRT->CODSUPER,"ZR_DESCRIC")
		aLinhas[nLinha][22] := Posicione("SX5",1,xFilial("SX5")+"_S"+TRT->SEGMENTO,"X5_DESCRI")
		aLinhas[nLinha][23] := Iif(AllTrim(TRT->VALIDADO)=="BAIXA POR P99" .Or. AllTrim(TRT->VALIDADO)=="BAIXA POR P99 C/ SALDO",TRT->E5_VALOR,TRT->E1_SALDO)
		
		TRT->(DBSKIP())    
		
	ENDDO
	
	TRT->(DbCloseArea())    
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	For nExcel := 1 To nLinha
		
		//IncProc("Aguarde. Gerando Excel...:" + nExcel + " Ate : "+nLinha)  
   		
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
								         aLinhas[nExcel][20],;  // 20 T 
								         aLinhas[nExcel][21],;  // 21 U 
								         aLinhas[nExcel][22],;  // 22 V								         
										 aLinhas[nExcel][23] ;  // 23 W  										 
				  								      	    }) 	
													      	 			
   Next nExcel 
   //============================== FINAL IMPRIME LINHA NO EXCEL

	// Gera dados para Visão 01
	cQuery := ADFN60Q1()
	If Select("ADFN60Q1") > 0
		ADFN60Q1->(DbCloseArea())
		
	EndIf 
	TCQUERY cQuery new alias "ADFN60Q1"
	ADF6Q1TR := Contar("ADFN60Q1","!Eof()") 
	ProcRegua(ADF6Q1TR)
	ADFN60Q1->(DbGoTop())
	Do While !ADFN60Q1->(Eof()) 

		AADD( sVisM02 , {ADFN60Q1->STATUS , ADFN60Q1->VALIDADO , ADFN60Q1->ANO , ADFN60Q1->E1_SALDO} )
		
		IncProc("Gerando excel Visão #01 ")
		ADFN60Q1->(DBSKIP())   
		 
	EndDo

	Aadd( sVisE02 , { '90 A 120 DIAS' ,0,0,0,0,0,0 } )
	Aadd( sVisE02 , { 'Aberto'        ,0,0,0,0,0,0 } )
	Aadd( sVisE02 , { 'Baixado'       ,0,0,0,0,0,0 } )
	Aadd( sVisE02 , { '121 A 150 DIAS',0,0,0,0,0,0 } )
	Aadd( sVisE02 , { 'Aberto'        ,0,0,0,0,0,0 } )
	Aadd( sVisE02 , { 'Baixado'       ,0,0,0,0,0,0 } )
	Aadd( sVisE02 , { '151 A 180 DIAS',0,0,0,0,0,0 } )
	Aadd( sVisE02 , { 'Aberto'        ,0,0,0,0,0,0 } )
	Aadd( sVisE02 , { 'Baixado'       ,0,0,0,0,0,0 } )
	Aadd( sVisE02 , { '181 A 360 DIAS',0,0,0,0,0,0 } )
	Aadd( sVisE02 , { 'Aberto'        ,0,0,0,0,0,0 } )
	Aadd( sVisE02 , { 'Baixado'       ,0,0,0,0,0,0 } )
	Aadd( sVisE02 , { 'ACIMA DE 361'  ,0,0,0,0,0,0 } )
	Aadd( sVisE02 , { 'Aberto'        ,0,0,0,0,0,0 } )
	Aadd( sVisE02 , { 'Baixado'       ,0,0,0,0,0,0 } )
	Aadd( sVisE02 , { 'Total Geral'   ,0,0,0,0,0,0 } )
	
	ProcRegua(LEN(sVisM02))
	For A:=1 TO LEN(sVisM02)
		
		If sVisM02[a][3]     = cValToChar(Year(Date())-3)
			nColAno := 2
		Elseif sVisM02[a][3] = cValToChar(Year(Date())-2)
			nColAno := 3
		Elseif sVisM02[a][3] = cValToChar(Year(Date())-1)
			nColAno := 4
		Elseif sVisM02[a][3] = cValToChar(Year(Date()))
			nColAno := 5	
		Elseif sVisM02[a][3] = cValToChar(Year(Date())+1)
			nColAno := 6	
		EndIf	
		
		//
		if Substr(sVisM02[a][1],1,1) = '1'
		
			if Alltrim(sVisM02[a][2])='ABERTO'
				sVisE02[1][nColAno]  += sVisM02[a][4]
				sVisE02[2][nColAno]  += sVisM02[a][4]
				sVisE02[1][7]        += sVisM02[a][4]
				sVisE02[2][7]        += sVisM02[a][4]				
				
				sVisE02[16][nColAno] += sVisM02[a][4]
				sVisE02[16][7]       += sVisM02[a][4]
				
			Endif
			if sVisM02[a][2]='BAIXADO'
				sVisE02[1][nColAno]  += sVisM02[a][4]
				sVisE02[3][nColAno]  += sVisM02[a][4]
				sVisE02[1][7]        += sVisM02[a][4]
				sVisE02[3][7]        += sVisM02[a][4]				
				
				sVisE02[16][nColAno] += sVisM02[a][4]
				sVisE02[16][7]       += sVisM02[a][4]
				
			EndIf
			
		Endif
		
		//
		if Substr(sVisM02[a][1],1,1) = '2'
		
			if sVisM02[a][2]='ABERTO'
				sVisE02[4][nColAno]  += sVisM02[a][4]
				sVisE02[5][nColAno]  += sVisM02[a][4]
				sVisE02[4][7]        += sVisM02[a][4]
				sVisE02[5][7]        += sVisM02[a][4]				
				
				sVisE02[16][nColAno] += sVisM02[a][4]
				sVisE02[16][7]       += sVisM02[a][4]
				
			Endif
			if sVisM02[a][2]='BAIXADO'
				sVisE02[4][nColAno]  += sVisM02[a][4]
				sVisE02[6][nColAno]  += sVisM02[a][4]
				sVisE02[4][7]        += sVisM02[a][4]
				sVisE02[6][7]        += sVisM02[a][4]				
				
				sVisE02[16][nColAno] += sVisM02[a][4]
				sVisE02[16][7]       += sVisM02[a][4]
				
			EndIf

		Endif
		
		//
		if Substr(sVisM02[a][1],1,1) = '3'
		
			if sVisM02[a][2]='ABERTO'
				sVisE02[7][nColAno]  += sVisM02[a][4]
				sVisE02[8][nColAno]  += sVisM02[a][4]
				sVisE02[7][7]        += sVisM02[a][4]
				sVisE02[8][7]        += sVisM02[a][4]				
				
				sVisE02[16][nColAno] += sVisM02[a][4]
				sVisE02[16][7]       += sVisM02[a][4]
				
			Endif
			
			if sVisM02[a][2]='BAIXADO'
				sVisE02[7][nColAno]  += sVisM02[a][4]
				sVisE02[9][nColAno]  += sVisM02[a][4]
				sVisE02[7][7]        += sVisM02[a][4]
				sVisE02[9][7]        += sVisM02[a][4]				
				
				sVisE02[16][nColAno] += sVisM02[a][4]
				sVisE02[16][7]       += sVisM02[a][4]
				
			EndIf
			
		Endif
		
		//
		if Substr(sVisM02[a][1],1,1) = '4'
		
			if sVisM02[a][2]='ABERTO'
				sVisE02[10][nColAno] += sVisM02[a][4]
				sVisE02[11][nColAno] += sVisM02[a][4]
				sVisE02[10][7]       += sVisM02[a][4]
				sVisE02[11][7]       += sVisM02[a][4]				
				
				sVisE02[16][nColAno] += sVisM02[a][4]
				sVisE02[16][7]       += sVisM02[a][4]
				
			Endif
			if sVisM02[a][2]='BAIXADO'
				sVisE02[10][nColAno] += sVisM02[a][4]
				sVisE02[12][nColAno] += sVisM02[a][4]
				sVisE02[10][7]       += sVisM02[a][4]
				sVisE02[12][7]       += sVisM02[a][4]				
				
				sVisE02[16][nColAno] += sVisM02[a][4]
				sVisE02[16][7]       += sVisM02[a][4]
				
			EndIf

			
		Endif
		
		//
		if Substr(sVisM02[a][1],1,1) = '5'
		
			if sVisM02[a][2]='ABERTO'
				sVisE02[13][nColAno] += sVisM02[a][4]
				sVisE02[14][nColAno] += sVisM02[a][4]
				sVisE02[13][7]       += sVisM02[a][4]
				sVisE02[14][7]       += sVisM02[a][4]				
				
				sVisE02[16][nColAno] += sVisM02[a][4]
				sVisE02[16][7]       += sVisM02[a][4]
				
			Endif
			
			if sVisM02[a][2]='BAIXADO'
				sVisE02[13][nColAno] += sVisM02[a][4]
				sVisE02[15][nColAno] += sVisM02[a][4]
				sVisE02[13][7]       += sVisM02[a][4]
				sVisE02[15][7]       += sVisM02[a][4]				
				
				sVisE02[16][nColAno] += sVisM02[a][4]
				sVisE02[16][7]       += sVisM02[a][4]
				
			EndIf
			
		Endif

		IncProc("Gerando excel Visão #01 ")
		
	Next

	ProcRegua(LEN(sVisE02))
	For e:=1 to Len(sVisE02)
	 	// Plan 02
		oExcel:AddRow(cPlan2,cTit2,{ sVisE02[e][1] , sVisE02[e][2] , sVisE02[e][3] , sVisE02[e][4] , sVisE02[e][5] , sVisE02[e][6] , sVisE02[e][7] } )
		IncProc("Gerando excel Visão #01 ")
	Next	

	//Plan 03 - Visão 02.
	aPlan3Seg := {}
	aPlan3Dad := {}
	cQuery    := ADFN60Q2()
	If Select("ADFN60Q2") > 0
		ADFN60Q2->(DbCloseArea())
		
	EndIf 
	TCQUERY cQuery new alias "ADFN60Q2"
	ADF6Q2TR := Contar("ADFN60Q2","!Eof()")  
	ProcRegua(ADF6Q2TR)
	ADFN60Q2->(DbGoTop())
	Do While ! ADFN60Q2->(Eof()) 

		If (Ascan(aPlan3Seg,{|x| x[1] == Alltrim(cValToChar(ADFN60Q2->SEGMENTO)) + '-' + Alltrim(cValToChar(ADFN60Q2->X5_DESCRI)) } )) <= 0
			Aadd(aPlan3Seg,{Alltrim(cValToChar(ADFN60Q2->SEGMENTO)) + '-' + Alltrim(cValToChar(ADFN60Q2->X5_DESCRI)),0,0,0,0,0,0})
		
		EndIf
		
		Aadd(aPlan3Dad,{Alltrim(cValToChar(ADFN60Q2->SEGMENTO)) + '-' + Alltrim(cValToChar(ADFN60Q2->X5_DESCRI)),ADFN60Q2->ANO,ADFN60Q2->E1_SALDO})
		
		IncProc("Gerando excel Visão #02 ")
		ADFN60Q2->(DBSKIP())
		    
	EndDo
	
	Aadd(aPlan3Seg,{'Total Geral',0,0,0,0,0,0})
	
	//
	nColAno := 0
	ProcRegua(Len(aPlan3Dad))
	
	For y := 1 To Len(aPlan3Seg)-1
	
		For a :=1 To Len(aPlan3Dad)

			If aPlan3Seg[y][1] == aPlan3Dad[a][1]
				
				If aPlan3Dad[a][2] = cValToChar(Year(Date())-3)
					nColAno	:= 2
					
				ElseIf aPlan3Dad[a][2] = cValToChar(Year(Date())-2)
					nColAno	:= 3
					
				ElseIf aPlan3Dad[a][2] = cValToChar(Year(Date())-1)
					nColAno	:= 4
					
				ElseIf aPlan3Dad[a][2] = cValToChar(Year(Date()))
					nColAno	:= 5
					
				ElseIf aPlan3Dad[a][2] = cValToChar(Year(Date())-1)
					nColAno	:= 6
					
				EndIf
				
				//  
				aPlan3Seg[y][nColAno]              += aPlan3Dad[a][3]
				aPlan3Seg[y][7]                    += aPlan3Dad[a][3]
				aPlan3Seg[Len(aPlan3Seg)][nColAno] += aPlan3Dad[a][3]	
				aPlan3Seg[Len(aPlan3Seg)][7]       += aPlan3Dad[a][3]	
				
			EndIf
			
			IncProc("Preenchendo excel Visão #02 ")
			
		Next a	
	
	Next y
	
	//
	For a :=1 To Len(aPlan3Seg)
		oExcel:AddRow(cPlan3,cTit3,{ aPlan3Seg[a][1],aPlan3Seg[a][2],aPlan3Seg[a][3],aPlan3Seg[a][4],aPlan3Seg[a][5],aPlan3Seg[a][6],aPlan3Seg[a][7]} )
		
	Next a	

	//Plan 04
	//Plan 04 - Visão 03.
	aPlan4Seg := {}
	aPlan4Dad := {}
	cQuery := ADFN60Q3()
	If Select("ADFN60Q3") > 0
		ADFN60Q3->(DbCloseArea())
	EndIf	
	TCQUERY cQuery new alias "ADFN60Q3"	
	ADF6Q3TR := Contar("ADFN60Q3","!Eof()")  
	ProcRegua(ADF6Q3TR)
	ADFN60Q3->(DbGoTop())
	Do While ! ADFN60Q3->(Eof()) 
		
		If (Ascan(aPlan4Seg,{|x| x[1] == Alltrim(cValToChar(ADFN60Q3->NOMESUPER)) } )) <= 0
			Aadd(aPlan4Seg,{Alltrim(cValToChar(ADFN60Q3->NOMESUPER)),0,0,0,0,0,0})
		
		EndIf
		
		Aadd(aPlan4Dad,{Alltrim(cValToChar(ADFN60Q3->NOMESUPER)),ADFN60Q3->ANO,ADFN60Q3->E1_SALDO})
		
		IncProc("Gerando excel Visão #03 ")
		ADFN60Q3->(DBSKIP())
		    
	EndDo
	
	Aadd(aPlan4Seg,{'Total Geral',0,0,0,0,0,0})
	
	//
	nColAno := 0
	ProcRegua(Len(aPlan4Dad))
	
	For y := 1 To Len(aPlan4Seg)-1
	
		For a :=1 To Len(aPlan4Dad)

			If aPlan4Seg[y][1] == aPlan4Dad[a][1]
				
				If aPlan4Dad[a][2] = cValToChar(Year(Date())-3)
					nColAno	:= 2
					
				ElseIf aPlan4Dad[a][2] = cValToChar(Year(Date())-2)
					nColAno	:= 3
					
				ElseIf aPlan4Dad[a][2] = cValToChar(Year(Date())-1)
					nColAno	:= 4
					
				ElseIf aPlan4Dad[a][2] = cValToChar(Year(Date()))
					nColAno	:= 5
					
				ElseIf aPlan4Dad[a][2] = cValToChar(Year(Date())-1)
					nColAno	:= 6
					
				EndIf
			
				//  
				aPlan4Seg[y][nColAno]              += aPlan4Dad[a][3]
				aPlan4Seg[y][7]                    += aPlan4Dad[a][3]
				aPlan4Seg[Len(aPlan4Seg)][nColAno] += aPlan4Dad[a][3]	
				aPlan4Seg[Len(aPlan4Seg)][7]       += aPlan4Dad[a][3]	
				
			EndIf
			
			IncProc("Preenchendo excel Visão #03 ")
			
		Next a	
	
	Next y
	
	//
	For a :=1 To Len(aPlan4Seg)
		oExcel:AddRow(cPlan4,cTit4,{ aPlan4Seg[a][1],aPlan4Seg[a][2],aPlan4Seg[a][3],aPlan4Seg[a][4],aPlan4Seg[a][5],aPlan4Seg[a][6],aPlan4Seg[a][7]} )
	
	Next a
 	
Return .T.                       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADFIN060R ºAutor  ³Microsiga           º Data ³  07/12/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\BI_FINANCEIRO.XML")

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADFIN060R ºAutor  ³Microsiga           º Data ³  07/12/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriaExcel()              

	oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\BI_FINANCEIRO.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return Nil          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADFIN060R ºAutor  ³Microsiga           º Data ³  07/12/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SQL(nOpc)

	Local cQuery    := ""
	Default nOpc	:= 1
	
	cQuery := " SELECT "
	cQuery += " DADOS.E1_FILIAL, "
	cQuery += " CONVERT(VARCHAR(10),CAST(DADOS.E1_EMISSAO AS DATE),103) AS 'E1_EMISSAO', "
	cQuery += " DADOS.E1_NUM, "
	cQuery += " DADOS.E1_PREFIXO, "
	cQuery += " DADOS.E1_PARCELA, "
	cQuery += " DADOS.E1_NOMCLI, "
	cQuery += " DADOS.E1_VALOR, "
	cQuery += " CASE "
	cQuery += " WHEN SUM(DADOS.E5_VALOR) IS NULL THEN 0 "
	cQuery += " ELSE SUM(DADOS.E5_VALOR) "
	cQuery += " END AS E5_VALOR, "
	cQuery += " DADOS.E1_BANCO, "
	cQuery += " DADOS.E1_SALDO, "
	cQuery += " DADOS.VALIDADO, "
	cQuery += " DADOS.E1_VEND1, "
	cQuery += " (SELECT A3_NREDUZ FROM " + RetSqlName("SA3") + " WITH (NOLOCK) WHERE D_E_L_E_T_= '' AND A3_COD = DADOS.E1_VEND1) AS VENDEDOR, "
	cQuery += " (SELECT A3_CODSUP FROM " + RetSqlName("SA3") + " WITH (NOLOCK) WHERE D_E_L_E_T_= '' AND A3_COD = DADOS.E1_VEND1) AS CODSUPER, "
	cQuery += " (SELECT A3_NOMSUP FROM " + RetSqlName("SA3") + " WITH (NOLOCK) WHERE D_E_L_E_T_= '' AND A3_COD = DADOS.E1_VEND1) AS NOMESUPER, "
	cQuery += " (SELECT A1_SATIV1 FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE D_E_L_E_T_= '' AND A1_COD = DADOS.E1_CLIENTE AND A1_LOJA = DADOS.E1_LOJA) AS SEGMENTO, "
	cQuery += " DADOS.E5_BENEF, "
	cQuery += " CONVERT(VARCHAR(10),CAST(DADOS.E1_VENCREA AS DATE),103) AS 'E1_VENCREA', IDADE, "
	cQuery += " CASE "
	
	//
	If nOpc == 1
		cQuery += " WHEN DADOS.IDADE >=90 AND  DADOS.IDADE  <= 120  THEN '90 A 120 DIAS' "
		cQuery += " WHEN DADOS.IDADE >=121 AND  DADOS.IDADE <= 150  THEN '121 A 150 DIAS' "
		cQuery += " WHEN DADOS.IDADE >=151 AND  DADOS.IDADE <= 180  THEN '151 A 180 DIAS' "
		cQuery += " WHEN DADOS.IDADE >=181 AND  DADOS.IDADE <= 360  THEN '181 A 360 DIAS' "		
		cQuery += " ELSE 'ACIMA DE 361' "
		
	Else
		cQuery += " WHEN DADOS.IDADE >=90 AND  DADOS.IDADE  <= 120  THEN '1-90 A 120 DIAS' "
		cQuery += " WHEN DADOS.IDADE >=121 AND  DADOS.IDADE <= 150  THEN '2-121 A 150 DIAS' "
		cQuery += " WHEN DADOS.IDADE >=151 AND  DADOS.IDADE <= 180  THEN '3-151 A 180 DIAS' "
		cQuery += " WHEN DADOS.IDADE >=181 AND  DADOS.IDADE <= 360  THEN '4-181 A 360 DIAS' "		
		cQuery += " ELSE '5-ACIMA DE 361' "
		
	EndIf
	
	cQuery += " END AS 'STATUS', "
	cQuery += " CAST(DATEPART(YEAR,CAST(E1_VENCREA AS DATE)) AS VARCHAR) AS ANO "
	cQuery += " FROM "
	cQuery += " ( "
	
	cQuery += " SELECT E1_FILIAL,E1_EMISSAO,E1_NUM,E1_PREFIXO,E1_PARCELA,E1_CLIENTE,E1_LOJA,E1_NOMCLI,E1_VALOR,E1_SALDO,E1_VEND1, "
	cQuery += " CASE "
	cQuery += " WHEN E5_RECPAG = 'R' THEN E5_VALOR "
	cQuery += " WHEN E5_RECPAG = 'P' THEN (E5_VALOR *(-1)) "
	cQuery += " END E5_VALOR, "
	cQuery += " E1_BANCO, E5_BENEF,E1_VENCREA, "
	cQuery += " CASE "
	
	//
	If nOpc == 1	
		cQuery += " WHEN E1_SALDO  <> 0 AND E5_BANCO <> 'P99'                          THEN 'TITULO EM ABERTO' "
		cQuery += " WHEN E1_SALDO  =  0 AND E5_BANCO <> 'P99'                          THEN 'BAIXA NORMAL' "
		cQuery += " WHEN E1_SALDO  =  0 AND E5_BANCO =  'P99'                          THEN 'BAIXA POR P99' "
		cQuery += " WHEN E1_SALDO  <> 0 AND E5_BANCO =  'P99'                          THEN 'BAIXA POR P99 C/ SALDO' "
		cQuery += " WHEN E5_BANCO IS NULL                              THEN 'TITULO EM ABERTO' "
		
	Else
		cQuery += " WHEN E1_SALDO  <> 0 AND E5_BANCO <> 'P99'                          THEN 'ABERTO' "
		cQuery += " WHEN E1_SALDO  =  0 AND E5_BANCO <> 'P99'                          THEN 'BAIXA NORMAL' " 
		cQuery += " WHEN E1_SALDO  =  0 AND E5_BANCO =  'P99'                          THEN 'BAIXADO' " 
		cQuery += " WHEN E1_SALDO  <> 0 AND E5_BANCO =  'P99'                          THEN 'BAIXADO' " 
		cQuery += " WHEN E5_BANCO IS NULL                              THEN 'ABERTO' " 
		
	EndIf
	
	cQuery += " END AS 'VALIDADO', DATEDIFF ( day ,E1_VENCREA,GETDATE())  AS IDADE "
	cQuery += " FROM " + RetSqlName("SE1") + " SE1 WITH (NOLOCK) LEFT JOIN " + RetSqlName("SE5") + " SE5 WITH (NOLOCK) "
	cQuery += " ON "
	cQuery += " SE1.E1_PREFIXO = SE5.E5_PREFIXO AND SE1.E1_NUM = SE5.E5_NUMERO AND "
	cQuery += " SE1.E1_CLIENTE = SE5.E5_CLIFOR  AND SE1.E1_LOJA = SE5.E5_LOJA AND  SE1.E1_PARCELA = SE5.E5_PARCELA  AND SE5.D_E_L_E_T_ = '' "
	cQuery += " WHERE  SE1.E1_TIPO IN ('NF','NDC','NCI') AND SE1.D_E_L_E_T_ = ''  AND  SE1.E1_VENCREA <= (getdate()-90) "
	
	
	cQuery += " ) "
	cQuery += " AS DADOS "
	cQuery += " WHERE "
	cQuery += " DADOS.VALIDADO <> 'BAIXA NORMAL' "
	cQuery += " GROUP BY DADOS.E1_FILIAL,DADOS.E1_EMISSAO,DADOS.E1_NUM,DADOS.E1_PREFIXO,DADOS.E1_PARCELA,DADOS.E1_CLIENTE,DADOS.E1_LOJA,DADOS.E1_NOMCLI,DADOS.E1_VALOR,DADOS.E1_SALDO,DADOS.E1_BANCO, DADOS.VALIDADO, "
	cQuery += " DADOS.E1_VEND1, "
	cQuery += " DADOS.E5_BENEF, "
	cQuery += " DADOS.E1_VENCREA, "
	cQuery += " DADOS.IDADE "

Return cQuery

// ##########################################################################################
// Projeto: 
// Modulo : SIGAFIN
// Fonte  : ADFN60Q1
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 31/07/18 | Ricardo Lima      | QUERY VISÃO FINANCEIRA                     | 042423
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
Static Function ADFN60Q1()

	Local cQuery     := ""
	
	//
	cQuery := " SELECT DADO2.VALIDADO, DADO2.STATUS, DADO2.ANO, SUM(CASE WHEN RTRIM(LTRIM(DADO2.VALIDADO)) = 'BAIXADO' THEN DADO2.E5_VALOR ELSE DADO2.E1_SALDO END) E1_SALDO "
	cQuery += " FROM ( "
	cQuery += SQL(2)
	cQuery += " ) AS DADO2 "
	cQuery += " WHERE DADO2.ANO >= '" + cValToChar(Year(Date())-3) + "' "
	cQuery += " GROUP BY DADO2.VALIDADO, DADO2.STATUS, DADO2.ANO "
	cQuery += " ORDER BY DADO2.ANO, DADO2.STATUS, DADO2.VALIDADO "	
	
Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADFN60Q2  ºAutor  ³Microsiga           º Data ³  15/08/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ADFN60Q2()

	Local cQuery     := ""

	//
	//Iif(AllTrim(TRT->VALIDADO)=="BAIXA POR P99",TRT->E5_VALOR,TRT->E1_SALDO)
	cQuery += " SELECT DADO2.SEGMENTO, X5_DESCRI, DADO2.ANO, SUM(CASE WHEN RTRIM(LTRIM(DADO2.VALIDADO)) = 'BAIXA POR P99' OR RTRIM(LTRIM(DADO2.VALIDADO)) = 'BAIXA POR P99 C/ SALDO' THEN DADO2.E5_VALOR ELSE DADO2.E1_SALDO END) AS E1_SALDO " 
	cQuery += " FROM ( " 
	cQuery += SQL()	
	cQuery += "  ) AS DADO2 " 
	cQuery += "  LEFT OUTER JOIN 
	cQuery += "  (SELECT X5_FILIAL, X5_CHAVE, X5_DESCRI FROM " + RetSqlName("SX5") + " X5 WHERE X5_TABELA = '_S' AND X5.D_E_L_E_T_ = ' ' ) AS X5 
	cQuery += "  ON DADO2.E1_FILIAL = X5_FILIAL 
	cQuery += "  AND DADO2.SEGMENTO = X5_CHAVE " 
	cQuery += "  WHERE DADO2.ANO >= '" + cValToChar(Year(Date())-3) + "' " 
	cQuery += "  GROUP BY  DADO2.SEGMENTO, X5_DESCRI, DADO2.ANO " 
	cQuery += "  ORDER BY DADO2.ANO, DADO2.SEGMENTO " 
	
Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADFN60Q3  ºAutor  ³Microsiga           º Data ³  15/08/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ADFN60Q3()

	Local cQuery     := "" 
	
	//
	cQuery += " SELECT DADO2.NOMESUPER, DADO2.ANO, SUM(CASE WHEN RTRIM(LTRIM(DADO2.VALIDADO)) = 'BAIXA POR P99' OR RTRIM(LTRIM(DADO2.VALIDADO)) = 'BAIXA POR P99 C/ SALDO' THEN DADO2.E5_VALOR ELSE DADO2.E1_SALDO END) AS E1_SALDO " 
	cQuery += " FROM ( " 
	cQuery += SQL()	
	cQuery += "  ) AS DADO2 " 
	cQuery += "  WHERE DADO2.ANO >= '" + cValToChar(Year(Date())-3) + "' " 
	cQuery += "  GROUP BY DADO2.NOMESUPER, DADO2.ANO " 
	cQuery += "  ORDER BY DADO2.ANO, DADO2.NOMESUPER " 
	
Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADFIN060R ºAutor  ³Microsiga           º Data ³  07/12/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function UpSZR(cCODSUPER)

	Local aArea   := GetArea()
	Local cNomSup := ""
	
	SZR->( dbSetOrder(1) ) // ZR_FILIAL+ZR_CODIGO
	If SZR->( dbSeek(xFilial("SZR")+cCodSuper) )
		cNomSup := SZR->ZR_DESCRIC
	EndIf
	
	RestArea( aArea )

Return cNomSup