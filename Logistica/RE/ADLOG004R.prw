#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADLOG004R ºAutor  ³William COSTA       º Data ³  17/03/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório de entregas realizadas por placa para a logisticaº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFAT                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function ADLOG004R() // U_ADLOG004R()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatório de entregas realizadas por placa para a logistica')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="Relatorio de Entregas Realizadas Por Placa Para a Logistica"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:=TMSPrinter():New()
	Private nOpca		:=0
	Private cPerg		:= 'ADLOG004R'
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio de Entregas Realizadas Por Placa Para a Logistica" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||LogAdLog004R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         

Static Function LogAdLog004R()    
	Public oExcel      := FWMSEXCEL():New()
	Public cPath       := 'D:\Totvs\Protheus11_Homolog\protheus_data\system\'
	Public cArquivo    := 'REL_ENTREGAS_PLACA.XML'
	Public oMsExcel
	Public cPlanilha   := "ENTREGAS PLACAS"
    Public cTitulo     := "ENTREGAS REALIZADAS POR PLACA"
	Public aLinhas     := {}
   
	BEGIN SEQUENCE
		
		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("Não Existe Excel Instalado")
            BREAK
        EndIF
		
		Cabec()             
		GeraExcel()
	          
		SalvaXml()
		CriaExcel()
	
	    MsgInfo("Arquivo Excel gerado!")    
	    
	END SEQUENCE

Return(NIL) 

Static Function GeraExcel()

    Local cNomeRegiao := ''
	Local nLinha      := 0
	Local nExcel      := 0
	
	//Totalizadores gerais. //Éverson - Chamado 029359
	Local nTotalEnt	 := 0
	Local nTEntregues := 0
	Local nTAEntregar := 0
	
	//Totalizadores para roteiros pares. //Éverson - Chamado 029359
	Local nTotalPEnt	:= 0
	Local nTPEntregues:= 0
	Local nTAPEntregar:= 0
	
	//Totalizadores para roteiros ímpares. //Éverson - Chamado 029359
	Local nTotalIEnt	:= 0
	Local nTIEntregues:= 0
	Local nTAIEntregar:= 0
	
	
	SqlGeral() 
	
	DBSELECTAREA("TRB")
		TRB->(DBGOTOP())
		WHILE TRB->(!EOF())
		
		IF TRB->C5_ROTEIRO >= "200" .AND. TRB->C5_ROTEIRO <= "599"
			cNomeRegiao :=  "SAO PAULO"
		ELSEIF TRB->C5_ROTEIRO >= "600" .AND. TRB->C5_ROTEIRO <= "699"
			cNomeRegiao :=  "LITORAL"
		ELSEIF TRB->C5_ROTEIRO >= "700" .AND. TRB->C5_ROTEIRO <= "799"
			cNomeRegiao :=  "VALE DO PARAIBA"
		ELSEIF TRB->C5_ROTEIRO >= "800" .AND. TRB->C5_ROTEIRO <= "869"
			cNomeRegiao :=  "INTERIOR"
		ELSEIF TRB->C5_ROTEIRO >= "870" .AND. TRB->C5_ROTEIRO <= "899"
			cNomeRegiao :=  "MINAS GERAIS"
		ELSEIF TRB->C5_ROTEIRO >= "900" .AND. TRB->C5_ROTEIRO <= "999"
			cNomeRegiao :=  "RIO DE JANEIRO"
		ELSE
			cNomeRegiao :=  "OUTROS"
		ENDIF
   
        	nLinha  := nLinha + 1                                       
		
                //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
		   	AADD(aLinhas,{ "", ; // 01 A  
		   	               "", ; // 02 B   
		   	               "", ; // 03 C  
		   	               "", ; // 04 D  
		   	               "", ; // 05 E  
		   	               "", ; // 06 F   
		   	               "", ; // 07 G  
		   	               "",  ;// 08 H
		   	               ""  ; // 09 I  
                               })
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			aLinhas[nLinha][01] := cNomeRegiao                //A
			aLinhas[nLinha][02] := TRB->C5_ROTEIRO            //B
			aLinhas[nLinha][03] := TRB->C5_PLACA              //C
			aLinhas[nLinha][04] := STOD(TRB->C5_DTENTR)       //D
			aLinhas[nLinha][05] := TRB->QTD_DE_ENTREGA        //E
			aLinhas[nLinha][06] := TRB->A_ENTREGAR            //F
			aLinhas[nLinha][07] := TRB->ENTREGUES             //G
			aLinhas[nLinha][08] := TRB->PORCENTAGEM_REALIZADO //H
			aLinhas[nLinha][09] := TRB->PAR_OU_IMPAR 			 //I
			                                  
			//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================
			
			//Totalizadores totais.	
			nTotalEnt   += TRB->QTD_DE_ENTREGA 
			nTAEntregar += TRB->A_ENTREGAR  
			nTEntregues += TRB->ENTREGUES 
			
			//Éverson - Chamado 029359
			//Totalizadores para roteiros pares.
			If ALLTRIM(cValToChar(TRB->PAR_OU_IMPAR)) = "PAR"
				nTotalPEnt		+= TRB->QTD_DE_ENTREGA 
				nTAPEntregar	+= TRB->A_ENTREGAR 
				nTPEntregues	+= TRB->ENTREGUES
				
			EndIf
			
			//Totalizadores para roteiros ímpares.
			If Alltrim(cValToChar(TRB->PAR_OU_IMPAR)) = "IMPAR"
				nTotalIEnt		+= TRB->QTD_DE_ENTREGA 
				nTAIEntregar	+= TRB->A_ENTREGAR
				nTIEntregues	+= TRB->ENTREGUES
			
			EndIf
			//
			
			TRB->(dbSkip())    
		
		END //end do while TRB
		TRB->( DBCLOSEAREA() ) 
		
		//Éverson - Chamado 029359
		AADD(aLinhas,{ "", ; // 01 A  
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	               "", ; // 07 G  
	   	               "",  ;// 08 H
	   	               ""  ; // 09 I  
                           })
		
		//Totalizador geral.
		nLinha  := nLinha + 2
		
		AADD(aLinhas,{ "", ; // 01 A  
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	               "", ; // 07 G  
	   	               "",  ;// 08 H
	   	               ""  ; // 09 I  
                           })
		
		aLinhas[nLinha][01] := ""
	 	aLinhas[nLinha][02] := ""
    	aLinhas[nLinha][03] := ""
    	aLinhas[nLinha][04] := "Totais Gerais -->"
    	aLinhas[nLinha][05] := nTotalEnt
    	aLinhas[nLinha][06] := nTAEntregar
    	aLinhas[nLinha][07] := nTEntregues
    	aLinhas[nLinha][08] := Iif(nTotalEnt > 0, Round((nTEntregues/nTotalEnt)*100,2), 0)
    	aLinhas[nLinha][09] := ""  
    	
    	//Totalizador par.
    	nLinha  := nLinha + 1
		
		AADD(aLinhas,{ "", ; // 01 A  
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	               "", ; // 07 G  
	   	               "",  ;// 08 H
	   	               ""  ; // 09 I  
                           })
      
       aLinhas[nLinha][01] := ""
	    aLinhas[nLinha][02] := ""
		aLinhas[nLinha][03] := ""
		aLinhas[nLinha][04] := "Totais Pares -->"
		aLinhas[nLinha][05] := nTotalPEnt
		aLinhas[nLinha][06] := nTAPEntregar
		aLinhas[nLinha][07] := nTPEntregues
		aLinhas[nLinha][08] := Iif(nTotalPEnt > 0, Round((nTPEntregues/nTotalPEnt)*100,2), 0)
		aLinhas[nLinha][09] := "" 
		
		//Totalizador ímpar.
    	nLinha  := nLinha + 1
		
		AADD(aLinhas,{ "", ; // 01 A  
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	               "", ; // 07 G  
	   	               "",  ;// 08 H
	   	               ""  ; // 09 I  
                           })
      
       aLinhas[nLinha][01] := ""
	    aLinhas[nLinha][02] := ""
		aLinhas[nLinha][03] := ""
		aLinhas[nLinha][04] := "Totais Ímpares -->"
		aLinhas[nLinha][05] := nTotalIEnt
		aLinhas[nLinha][06] := nTAIEntregar
		aLinhas[nLinha][07] := nTIEntregues
		aLinhas[nLinha][08] := Iif(nTotalIEnt > 0, Round((nTIEntregues/nTotalIEnt)*100,2), 0)
		aLinhas[nLinha][09] := "" 
		//
		
		//============================== INICIO IMPRIME LINHA NO EXCEL
		FOR nExcel := 1 TO nLinha
	   	oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],; // 01 A  
                                         aLinhas[nExcel][02],;  // 02 B  
	   	                                 aLinhas[nExcel][03],;  // 03 C  
	   	                                 aLinhas[nExcel][04],;  // 04 D  
	   	                                 aLinhas[nExcel][05],;  // 05 E  
	   	                                 aLinhas[nExcel][06],;  // 06 F  
	   	                                 aLinhas[nExcel][07],;  // 07 G  
	   	                                 aLinhas[nExcel][08],;  // 08 H  
	   	                                 aLinhas[nExcel][09];  // 09 I 
															 }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS				
	   NEXT 
	 	//============================== FINAL IMPRIME LINHA NO EXCEL
														 
Return()    

Static Function SqlGeral()
	
	Local cQuery			:= ""
	Local cDataIni 		:= DTOS(MV_PAR03)
	Local cDataFin 		:= DTOS(MV_PAR04) 
	Local cTipoRoteiro	:= ""	
	
	If mv_par07 == 2
		cTipoRoteiro	:= "PAR"
		
	ElseIf mv_par07 == 3
		cTipoRoteiro	:= "IMPAR"
		
	EndIf
    
    cQuery := scriptSql( cDataIni, cDataFin, cValToChar(MV_PAR05), cValToChar(MV_PAR06), cValToChar(MV_PAR01), cValToChar(MV_PAR02), cTipoRoteiro)
	
	If Select("TRB") > 0
		TRB->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "TRB"
       
RETURN()

Static Function scriptSql( cDataIni, cDataFin, cRotIni, cRotFim, cFilDe, cFilAte, cTipoRoteiro)

	Local cQuery	:= ""
	
	cTipoRoteiro := Alltrim(cValToChar(cTipoRoteiro))

    cQuery += " SELECT * " 
	cQuery += " FROM " 
		cQuery += " ( " 
		cQuery += " SELECT SC5.C5_ROTEIRO, " 
			cQuery += " SC5.C5_PLACA, " 
			cQuery += " SC5.C5_DTENTR, " 
			cQuery += " COUNT(SC5.C5_SEQUENC) AS QTD_DE_ENTREGA, " 
			cQuery += " SUM(CASE WHEN SC5.C5_MOK <> '02' then 1  else 0  END) AS A_ENTREGAR, " 
			cQuery += " SUM(CASE WHEN SC5.C5_MOK = '02' then 1  else 0  END) AS ENTREGUES, " 
			cQuery += " (SUM(CASE WHEN SC5.C5_MOK = '02' then 1  else 0  END) * 100) / COUNT(SC5.C5_SEQUENC) AS PORCENTAGEM_REALIZADO, " 
			cQuery += " CASE CAST(C5_ROTEIRO AS numeric)%2 WHEN 0 THEN 'PAR' ELSE 'IMPAR' END AS PAR_OU_IMPAR " 
		cQuery += " FROM " + RetSqlName("SC5") + " SC5 " 
		cQuery += " WHERE SC5.C5_FILIAL  >= '" + cFilDe + "' " 
			cQuery += " AND SC5.C5_FILIAL  <= '" + cFilAte + "' " 
			cQuery += " AND SC5.C5_DTENTR  >= '" + cDataIni + "' " 
			cQuery += " AND SC5.C5_DTENTR  <= '" + cDataFin + "' " 
			cQuery += " AND SC5.C5_ROTEIRO >= '" + cRotIni + "' " 
			cQuery += " AND SC5.C5_ROTEIRO <='"  + cRotFim + "' " 
			cQuery += " AND SC5.D_E_L_E_T_ = '' " 
		cQuery += " GROUP BY SC5.C5_DTENTR,SC5.C5_ROTEIRO,SC5.C5_PLACA " 
		cQuery += " ) AS FONTE "
		
	If ! Empty(cTipoRoteiro)
	cQuery += " WHERE " 
		cQuery += " FONTE.PAR_OU_IMPAR = '" + cTipoRoteiro + "' " 
	
	EndIf
	
	cQuery += " ORDER BY FONTE.C5_DTENTR,FONTE.C5_ROTEIRO " 

Return cQuery    

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_ENTREGAS_PLACA.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_ENTREGAS_PLACA.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 

Static Function MontaPerg()                                  
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    PutSx1(cPerg,'01','Filial De        ?','','','mv_ch1','C',02,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR01')
	PutSx1(cPerg,'02','Filial Ate       ?','','','mv_ch2','C',02,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR02')
	PutSx1(cPerg,'03','Data Entrega De  ?','','','mv_ch3','D',08,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR03')
	PutSx1(cPerg,'04','Data Entrega Ate ?','','','mv_ch4','D',08,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR04')
	PutSx1(cPerg,'05','Roteiro De       ?','','','mv_ch5','C',03,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR05')
	PutSx1(cPerg,'06','Roteiro Ate      ?','','','mv_ch6','C',03,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR06')
	
	//Éverson - Chamado 029359
	PutSX1(cPerg,"07","Tipo de rota ","Tipo de rota "	,"Tipo de rota ","mv_ch7","N",01,0,01,"C","","","","","mv_par07" ,"Todas","Todas","Todas","","Par","Par","Par","Ímpar","Ímpar","Ímpar","","","",""," ")
	//
	
	Pergunte(cPerg,.F.)
	
Return Nil            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"Regiao "          ,1,1) // 01 A
  	oExcel:AddColumn(cPlanilha,cTitulo,"Roteiro "         ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Placa "           ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"Data "            ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"Qtde de Entrega " ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"A Entregar "      ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"Entregues "       ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"% Realizado "     ,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"Par/Ímpar "       ,1,1) // 09 I
	
RETURN(NIL)