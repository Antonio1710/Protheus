#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADLOG038R ºAutor  ³William COSTA       º Data ³  01/10/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Motoristas                                    º±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFAT                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADLOG038R()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="Relatorio de Motoristas"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:=TMSPrinter():New()
	Private nOpca		:=0
	Private cPerg		:= 'ADLOG038R'

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Motoristas')
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio de Motoristas" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||LogAdLog038R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         

Static Function LogAdLog038R()    
	Private oExcel      := FWMSEXCEL():New()
	Private cPath       := ''
	Private cArquivo    := 'REL_MOTORISTAS.XML'
	Private oMsExcel
	Private cPlanilha   := "Motoristas"
    Private cTitulo     := "Motoristas"
	Private aLinhas     := {}
	Private cPlacas     := ''
   
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

    Local nLinha      := 0
	Local nExcel      := 0
	Local nContPlaca  := 0
	
	SqlGeral() 
	
	DBSELECTAREA("TRB")
		TRB->(DBGOTOP())
		WHILE TRB->(!EOF())
		
			// *** INICIO ENCONTRAR AS PLACAS PARA A MOTORISTA *** //
			
			cPlacas     := ''
			nContPlaca  := 0
			
			SqlPlacas(TRB->ZVC_CPF) 
	
			DBSELECTAREA("TRC")
			TRC->(DBGOTOP())
			WHILE TRC->(!EOF())
			
				nContPlaca := nContPlaca + 1
				
				IF nContPlaca == 1
				
					cPlacas := TRC->ZV4_PLACA
				
				ELSE
				
					cPlacas := cPlacas + ';' + TRC->ZV4_PLACA
				
				ENDIF
			
				TRC->(dbSkip())    
			
			END //end do while TRB
			TRC->( DBCLOSEAREA() )   
			// *** FINAL ENCONTRAR AS PLACAS PARA A MOTORISTA *** //
		
			nLinha  := nLinha + 1                                       
		
            //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
		   	AADD(aLinhas,{ "", ; // 01 A  
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
		   	               ""  ; // 14 N
		   	                   })
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			aLinhas[nLinha][01] := TRB->ZVC_FILIAL                                           //A
			aLinhas[nLinha][02] := TRB->ZVC_MOTORI                                           //B
			aLinhas[nLinha][03] := TRB->ZVC_CPF                                              //C
			aLinhas[nLinha][04] := TRB->ZVC_RG                                               //D
			aLinhas[nLinha][05] := TRB->ZVC_ENDER                                            //E
			aLinhas[nLinha][06] := TRB->ZVC_BAIRRO                                           //F
			aLinhas[nLinha][07] := TRB->ZVC_CIDRES                                           //G
			aLinhas[nLinha][08] := TRB->ZVC_ESTRES                                           //H
			aLinhas[nLinha][09] := IIF(TRB->ZVC_MOTBLQ == 'T','Sim','Não')                   //I
			aLinhas[nLinha][10] := TRB->ZVC_MAT                                              //J
			aLinhas[nLinha][11] := POSICIONE("SRA",1,TRB->ZVC_FILIAL+TRB->ZVC_MAT,"RA_NOME") //K       
			aLinhas[nLinha][12] := TRB->ZVC_CC                                               //L
			aLinhas[nLinha][13] := TRB->ZVC_XCREDE                                           //M
			aLinhas[nLinha][14] := cPlacas                                                   //N
			
		    //======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				
			TRB->(dbSkip())    
		
		END //end do while TRB
		TRB->( DBCLOSEAREA() )   
		
		//============================== INICIO IMPRIME LINHA NO EXCEL
		FOR nExcel := 1 TO nLinha
	   	oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],; // 01 A  
		                                 aLinhas[nExcel][02],; // 02 B  
		                                 aLinhas[nExcel][03],; // 03 C  
		                                 aLinhas[nExcel][04],; // 04 D  
		                                 aLinhas[nExcel][05],; // 05 E  
		                                 aLinhas[nExcel][06],; // 06 F  
		                                 aLinhas[nExcel][07],; // 07 G 
		                                 aLinhas[nExcel][08],; // 08 H  
		                                 aLinhas[nExcel][09],; // 09 I  
		                                 aLinhas[nExcel][10],; // 10 J  
		                                 aLinhas[nExcel][11],; // 11 K  
		                                 aLinhas[nExcel][12],; // 12 L  
		                                 aLinhas[nExcel][13],; // 13 M
		                                 aLinhas[nExcel][14] ; // 14 N  
		                                                    }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
	   NEXT 
	 	//============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SqlGeral()

	BeginSQL Alias "TRB"
			%NoPARSER%  
		    SELECT ZVC_FILIAL,
		           ZVC_MOTORI,
			       ZVC_CPF,
				   ZVC_RG,
				   ZVC_ENDER,
				   ZVC_BAIRRO,
				   ZVC_CIDRES,
				   ZVC_ESTRES,
				   ZVC_MOTBLQ,
				   ZVC_MAT,
				   ZVC_CC,
				   ZVC_XCREDE
			  FROM %Table:ZVC% ZVC 
			  WHERE ZVC_FILIAL   = %EXP:FWFILIAL("ZVC")%
			    AND ZVC_MOTORI  >= %EXP:MV_PAR01%
			    AND ZVC_MOTORI  <= %EXP:MV_PAR02%
				AND ZVC_CPF     >= %EXP:MV_PAR03%
				AND ZVC_CPF     <= %EXP:MV_PAR04%
				AND ZVC_RG      >= %EXP:MV_PAR05%
				AND ZVC_RG      <= %EXP:MV_PAR06%
				AND D_E_L_E_T_  <> '*'
				        
			  ORDER BY ZVC_MOTORI
			
	EndSQl
RETURN()    

Static Function SqlPlacas(cCpf)

	BeginSQL Alias "TRC"
			%NoPARSER%  
			SELECT ZV4_PLACA 
			  FROM %Table:ZV4% ZV4 
			 WHERE (ZV4_CPF     = %EXP:cCpf%
				   OR ZV4_CPF1  = %EXP:cCpf%
				   OR ZV4_CPF2  = %EXP:cCpf%
			       OR ZV4_CPF3  = %EXP:cCpf%
				   OR ZV4_CPF4  = %EXP:cCpf%
				   OR ZV4_CPF5  = %EXP:cCpf%
				   OR ZV4_CPF6  = %EXP:cCpf%
				   OR ZV4_CPF7  = %EXP:cCpf%
				   OR ZV4_CPF8  = %EXP:cCpf%)
			   AND D_E_L_E_T_  <> '*'
   		
	EndSQl
RETURN()

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_MOTORISTAS.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_MOTORISTAS.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 

Static Function MontaPerg()                                  
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    U_xPutSx1(cPerg,'01','Nome De  ?','','','mv_ch1','C',40,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR01')
	U_xPutSx1(cPerg,'02','Nome Ate ?','','','mv_ch2','C',40,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR02')
	U_xPutSx1(cPerg,'03','Cpf Ini  ?','','','mv_ch3','C',11,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR03')
	U_xPutSx1(cPerg,'04','Cpf Fin  ?','','','mv_ch4','C',11,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR04')
	U_xPutSx1(cPerg,'05','Rg Ini   ?','','','mv_ch5','C',15,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR05')
	U_xPutSx1(cPerg,'06','Rg Fin   ?','','','mv_ch6','C',15,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR06')
	
	Pergunte(cPerg,.F.)
Return Nil            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
	oExcel:AddColumn(cPlanilha,cTitulo,"Filial "                 ,1,1) // 01 A
    oExcel:AddColumn(cPlanilha,cTitulo,"Motorista "              ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"CPF "                    ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"RG "                     ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"Endereço "               ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"Bairro "                 ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"Cidade "                 ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"Estado "                 ,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"Bloqueado ? "            ,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"Func. Responsavel "      ,1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Func. Responsavel " ,1,1) // 11 K 			
	oExcel:AddColumn(cPlanilha,cTitulo,"Centro de Custo "        ,1,1) // 12 L
	oExcel:AddColumn(cPlanilha,cTitulo,"Credencial "             ,1,1) // 13 M
	oExcel:AddColumn(cPlanilha,cTitulo,"Placas "                 ,1,1) // 14 N
	
RETURN(NIL)