#Include "Protheus.ch"  
#Include "Fileio.ch"
#Include "TopConn.ch"  
#Include "Rwmake.ch"  

/*/{Protheus.doc} User Function ADFAT006R
	(Relatorio Controle de Canhotos em excel)
	@type  Function
	@author Fernando Sigoli
	@since 05/07/2018
	@version 01
	@history Ticket: 15368 - 09/06/2021 - Adriano Savoine - Inserido o Parametro de data para busca dos canhotos.
/*/


User Function ADFAT006R()   //U_ADFAT006R()
              

	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="Controle de Canhotos"    
	Private oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	Private oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	Private oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	Private oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	Private oPrn		:=TMSPrinter():New()
	Private nOpca		:=0
	Private cPerg		:= 'ADFAT006R'

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio Controle de Canhotos em excel')
		
	//+------------------------------------------------+
	//|Cria grupo de perguntas.                        |
	//+------------------------------------------------+
	u_xPutSx1(cPerg,"01","Filial De           ?" , "Filial De           ?" , "Filial De           ?" , "mv_ch1","C",2 ,0,0,"G","","SM0","","","mv_par01","","","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg,"02","Filial Ate          ?" , "Filial Ate          ?" , "Filial Ate          ?" , "mv_ch2","C",2 ,0,0,"G","","SM0","","","mv_par02","","","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg,"03","NFiscal De          ?" , "NFiscal De          ?" , "NFiscal De          ?" , "mv_ch3","C",9 ,0,0,"G","","   ","","","mv_par03","","","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg,"04","NFiscal Ate         ?" , "NFiscal Ate         ?" , "NFiscal Ate         ?" , "mv_ch4","C",9 ,0,0,"G","","   ","","","mv_par04","","","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg,"05","Situacao            ?" , "Situacao            ?" , "Situacao            ?" , "mv_ch5","N",1 ,0,1,"C","","","","","mv_par05" ,"Todos","Todos","Todos","1","Pendente","Pendente","Pendente","Baixado","Baixado","Baixado","","","","","","")
	u_xPutSx1(cPerg,"06","Data Canhoto De     ?" , "Data Canhoto De     ?" , "Data Canhoto De     ?" , "mv_ch6","D",8 ,0,0,"G","","   ","","","mv_par06","","","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg,"07","Data Canhoto Ate    ?" , "Data Canhoto Ate    ?" , "Data Canhoto Ate    ?" , "mv_ch7","D",8 ,0,0,"G","","   ","","","mv_par07","","","","","","","","","","","","","","","","")

	IF !Pergunte(cPerg,.T.)               
    	 Return
	Endif
	
	Processa({||ComADFAT006R ()},"Gerando arquivo","Aguarde...")
Return Nil

Static Function ComADFAT006R () 

 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	Private oExcel      := FWMSEXCEL():New()
	Private cPath       := '\protheus_data\system\'
	Private cArquivo    := 'REL_FATURA_CANHOTOS.XML'
	Private oMsExcel
	Private cPlanilha   := "Controle Canhotos"
	Private cTitulo     := "Controle Canhotos"
	Private cCodProdSql := '' 
	Private cFilSql     := ''
	Private aLinhas     := {}
   
	Begin Sequence
		
		//Verifica se há o excel instalado na máquina do usuário.
		If ! ( ApOleClient("MsExcel") ) 
		
			MsgStop("Não Existe Excel Instalado","Função ComADFAT006R (ADFAT006R)")   
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
		
		MsgInfo("Arquivo Excel gerado!","Função ComADFAT006R (ADFAT006R)")    
	    
	End Sequence

Return Nil 

Static Function Cabec() 

	//canhotos.
	oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"Filial "  			,1,1) // 01 A
  	oExcel:AddColumn(cPlanilha,cTitulo,"Nota Fiscal "   	,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Dta Entrega"        ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"Placa "      		,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"Cliente "     		,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"Municipio " 		,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"Estado"          	,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"Roteiro"          	,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"Canhoto"          	,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"Motivo"          	,1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"Usuario"          	,1,1) // 11 K
	oExcel:AddColumn(cPlanilha,cTitulo,"Dta Canhoto"        ,1,1) // 12 L
	oExcel:AddColumn(cPlanilha,cTitulo,"Hora Canhoto"       ,1,1) // 13 M
	
Return Nil

Static Function GeraExcel()

	Local nLinha		:= 0
	Local nExcel     	:= 0
	Local nTotReg		:= 0
	Local cNumPC        := ''
		
	sqlCanhos()
	
	//Conta o Total de registros.
	nTotReg := Contar("TRT","!Eof()")  

	
	//Valida a quantidade de registros.
	If nTotReg <= 0
		MsgStop("Não há registros para os parâmetros informados.","Função GeraExcel(ADCOMR002)")
		Return .F.
		
	EndIf
	
	//Atribui a quantidade de registros à régua de processamento.
	ProcRegua(nTotReg)
	TRT->(DbGoTop())
	While !TRT->(Eof()) 
	
		cNumPC := Alltrim(cValToChar(TRT->NOTA  ))
	
		IncProc("Processando Canhotos. " + cNumPC)     
					 
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
	   	               ""  ; // 13 M 
						     })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
		
		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================   
		
		//Dados do pedido.
		aLinhas[nLinha][01] := TRT->FILIAL          // 01 A	
		aLinhas[nLinha][02] := TRT->NOTA            // 02 B
		aLinhas[nLinha][03] := TRT->DATENTREGA      // 03 C
		aLinhas[nLinha][04] := TRT->PLACA           // 04 D
		aLinhas[nLinha][05] := TRT->CLIENTE         // 05 E
		aLinhas[nLinha][06] := TRT->MUNICIPIO       // 06 F
		aLinhas[nLinha][07] := TRT->UF              // 07 G
		aLinhas[nLinha][08] := TRT->ROTEIRO         // 08 H
		aLinhas[nLinha][09] := TRT->CANHOTO  		 // 09 I
		aLinhas[nLinha][10] := TRT->MOTIVO          // 10 J
		aLinhas[nLinha][11] := TRT->USUARIO         // 11 K
		aLinhas[nLinha][12] := TRT->DATACANHOTO     // 12 L
		aLinhas[nLinha][13] := TRT->HORACANHOTO     // 13 M

		
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
										 aLinhas[nExcel][13] ;  // 13 M  										 
				  								      	    }) 	
													      	 			
   Next nExcel 
 	//============================== FINAL IMPRIME LINHA NO EXCEL
 	
Return .T.                       

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_FATURA_CANHOTOS.XML")

Return Nil


Static Function CriaExcel()              

	oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_FATURA_CANHOTOS.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return Nil          

Static Function sqlCanhos()

	Local cRetStatus := ""
	Local cQuery     := ""

	If MV_PAR05 = 2 // pendentes
		cRetStatus := ''	
	ElseIf MV_PAR05 = 3 //baixados
		cRetStatus := 'X'
	EndIf 
	
	If Select("TRT") > 0
		TRT->(DbCloseArea())
	EndIf 
	
	cQuery := " SELECT "
	cQuery += " SC5010.C5_FILIAL AS 'FILIAL'," 
	cQuery += "	SC5010.C5_NOTA AS 'NOTA', "
	cQuery += "	CONVERT(VARCHAR(10),CAST(SC5010.C5_DTENTR AS DATE),103) AS 'DATENTREGA',"
	cQuery += " SC5010.C5_PLACA AS 'PLACA', "
	cQuery += " SC5010.C5_CLIENT+' '+SC5010.C5_LOJACLI+' - '+ SC5010.C5_NOMECLI 'CLIENTE'," 
	cQuery += " SC5010.C5_CIDADE AS 'MUNICIPIO', SC5010.C5_EST AS 'UF', "
	cQuery += " SC5010.C5_ROTEIRO AS 'ROTEIRO', SC5010.C5_CANHOTO AS 'CANHOTO'," 
	cQuery += " SC5010.C5_CANHMOT AS 'MOTIVO', SC5010.C5_CANHUSU AS 'USUARIO',CONVERT(VARCHAR(10),"
	cQuery += " CAST(SC5010.C5_CANHDAT AS DATE),103) AS 'DATACANHOTO', "
	cQuery += " SC5010.C5_CANHHOR AS 'HORACANHOTO' "
	cQuery += " FROM " + Retsqlname("SC5")+" SC5010 WITH(NOLOCK) "
	cQuery += " WHERE "
	cQuery += " SC5010.C5_FILIAL  	  	 >= '"+MV_PAR01+"'"
	cQuery += " AND SC5010.C5_FILIAL   	 <= '"+MV_PAR02+"'"
	cQuery += " AND SC5010.C5_NOTA    	 >= '"+MV_PAR03+"'"
	cQuery += " AND SC5010.C5_NOTA    	 <= '"+MV_PAR04+"'"
	cQuery += " AND SC5010.C5_CANHDAT    >= '"+Dtos(MV_PAR06)+"'"    //Ticket: 15368 - 09/06/2021 - Adriano Savoine
	cQuery += " AND SC5010.C5_CANHDAT    <= '"+Dtos(MV_PAR07)+"'"
	
	If MV_PAR05 <> 1
		cQuery += " AND SC5010.C5_CANHOTO =  '"+cRetStatus+"'"
    EndIf 
    
	TCQUERY cQuery new alias "TRT"

Return (NIL) 
