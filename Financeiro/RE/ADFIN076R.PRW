#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADFIN076R ºAutor  ³Fernando Sigoli     º Data ³  01/07/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio         									      º±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function ADFIN076R()
	
	Private aSays		:= {}
	Private aButtons	:= {}   
	Private cCadastro	:= "Relatorio Titulos x Devoluçoes"    
	Private nOpca		:= 0

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio Titulos x Devoluçoes')
	 
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio Titulos x Devoluçoes" )
    AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||LogADFIN076R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         

Static Function LogADFIN076R()  
  
	Private oExcel      := FWMSEXCEL():New()
	Private oMsExcel
	Private cPlanilha   := "Relatorio Titulos x Devoluçoes"
    Private cTitulo     := "Relatorio Titulos x Devoluçoes"
	Private aLinhas     := {}
   
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
	Local nTotReg	  := 0
	Local cNumTit     := ''
	
	SqlGeral()
	
	//Conta o Total de registros.
	nTotReg := Contar("TRB","!Eof()")
	
	//Atribui a quantidade de registros à régua de processamento.
	ProcRegua(nTotReg * 2)
    DBSELECTAREA("TRB")
		TRB->(DBGOTOP())
		WHILE TRB->(!EOF())
		
			cNumTit := Alltrim(cValToChar(TRB->NUMERO ))
	        IncProc("Titulo: " + cNumTit + " || Total Processados: " + CVALTOCHAR(nLinha))  
		
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
		   	               ""  ; // 13 M  
		   	                  })
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			aLinhas[nLinha][01] := TRB->FILIAL                                                  //A
			aLinhas[nLinha][02] := TRB->PREFIXO                                                 //B
			aLinhas[nLinha][03] := TRB->CLIENTE                                                 //C
			aLinhas[nLinha][04] := TRB->TIPO                                                    //D
			aLinhas[nLinha][05] := TRB->NUMERO   												//E
			aLinhas[nLinha][06] := TRB->PARCELA                                                 //F
			aLinhas[nLinha][07] := TRB->EMISSAO                                                 //G
			aLinhas[nLinha][08] := TRB->VCNTO                                                   //H
			aLinhas[nLinha][09] := TRB->NF_ORIGEM                                               //I
			aLinhas[nLinha][10] := TRB->VALOR                                                	//J
			aLinhas[nLinha][11] := TRB->SALDO                                                   //K
			aLinhas[nLinha][12] := TRB->DIF                                                     //L
			
			SqlBuscaOcorr(TRB->FILIAL,IIF(ALLTRIM(TRB->NF_ORIGEM) <> '',TRB->NF_ORIGEM,TRB->NUMERO))
			DBSELECTAREA("TRC")
			TRC->(DBGOTOP())
			WHILE TRC->(!EOF())
			
				DO CASE
					CASE TRC->ZD_DEVTOT == "E"
						aLinhas[nLinha][13] := "ENTREGUE"
					CASE TRC->ZD_DEVTOT == "O"
						aLinhas[nLinha][13] := "AGUARDANDO ENTREGA"	
					CASE TRC->ZD_DEVTOT == "P"
						aLinhas[nLinha][13] := "DEVOLUCAO PARCIAL"
					CASE TRC->ZD_DEVTOT == "Q"
						aLinhas[nLinha][13] := "DEVOLUCAO QUEBRA"
					CASE TRC->ZD_DEVTOT == "T"
						aLinhas[nLinha][13] := "DEVOLUCAO TOTAL"
					OTHERWISE
						aLinhas[nLinha][13] := "TIPO NAO ENCONTRADO"
				ENDCASE
				
				TRC->(dbSkip())    
		
			ENDDO //end do while TRB
			TRC->( DBCLOSEAREA() ) 
			                                  
			//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				
			TRB->(dbSkip())    
		
		ENDDO //end do while TRB
	TRB->( DBCLOSEAREA() )   
		
		//============================== INICIO IMPRIME LINHA NO EXCEL
		FOR nExcel := 1 TO nLinha
		
			IncProc("Carregando Excel: " + CVALTOCHAR(nExcel) + '/' + CVALTOCHAR(nLinha))
			
			IF ALLTRIM(aLinhas[nExcel][13]) <> "ENTREGUE"           .AND. ;
			   ALLTRIM(aLinhas[nExcel][13]) <> "AGUARDANDO ENTREGA" 
			   
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
				                                 aLinhas[nExcel][13] ; // 13 M
				                                                    }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
           ENDIF
	   NEXT 
	 	//============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SqlGeral()

	BeginSQL Alias "TRB"
	
		%NoPARSER%
	    SELECT DADOS.E1_FILIAL AS FILIAL,
			   DADOS.E1_PREFIXO AS PREFIXO,
			   DADOS.E1_CLIENTE+'-'+DADOS.E1_LOJA+'  '+DADOS.E1_NOMCLI AS CLIENTE,
			   DADOS.E1_TIPO AS TIPO,
			   DADOS.E1_NUM AS NUMERO,
			   DADOS.E1_PARCELA AS PARCELA,
			   CONVERT(VARCHAR(10),CAST(DADOS.E1_EMISSAO AS DATE),103) AS EMISSAO,
			   CONVERT(VARCHAR(10),CAST(DADOS.E1_VENCREA AS DATE),103) AS VCNTO,
			   CASE WHEN DADOS.D1_NFORI IS NULL THEN '' ELSE DADOS.D1_NFORI END AS NF_ORIGEM,
			   DADOS.E1_VALOR AS VALOR,
			   DADOS.E1_SALDO AS SALDO,
			   (DADOS.E1_VALOR - DADOS.E1_SALDO) AS DIF
			   FROM (SELECT DISTINCT(SE1.R_E_C_N_O_), 
				            SE1.E1_FILIAL, 
							SE1.E1_PREFIXO, 
							SE1.E1_NUM, 
							SE1.E1_PARCELA, 
				            SE1.E1_TIPO, 
							SE1.E1_NATUREZ, 
							SE1.E1_PORTADO, 
							SE1.E1_CLIENTE, 
				            SE1.E1_LOJA, 
							SE1.E1_NOMCLI, 
							SE1.E1_EMISSAO, 
							SE1.E1_VENCREA, 
				            SE1.E1_VALOR, 
							SE1.E1_SALDO,
							SD1.D1_NFORI
		               FROM %Table:SE1% SE1 WITH(NOLOCK) 
				  LEFT JOIN %Table:SD1% SD1 WITH(NOLOCK)  
				         ON SD1.D1_FILIAL   = SE1.E1_FILIAL
				        AND SD1.D1_FORNECE  = SE1.E1_CLIENTE 
				        AND SD1.D1_LOJA     = SE1.E1_LOJA 
				        AND SD1.D1_DOC      = SE1.E1_NUM 
				        AND SE1.D_E_L_E_T_  = ''
				        AND SD1.D_E_L_E_T_  = ''
				      WHERE SE1.E1_SALDO    > 0 
					    AND SE1.E1_TIPO    IN ('NCC','NF ')
				        AND SE1.D_E_L_E_T_  = '' 
					) AS DADOS
		
				ORDER BY DADOS.E1_CLIENTE,DADOS.E1_LOJA, DADOS.E1_EMISSAO
		
	EndSQl

RETURN()    

Static Function SqlBuscaOcorr(cFilAtu,cNota)

	BeginSQL Alias "TRC"
	
		%NoPARSER%
		SELECT ZD_DEVTOT 
		  FROM %TABLE:SZD%
		 WHERE ZD_FILIAL   = %EXP:cFilAtu%
		   AND ZD_NUMNF    = %EXP:cNota%
		   AND ZD_SERIE    = '01'
		   AND D_E_L_E_T_ <> '*'
				
	EndSQl

RETURN()

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_DEV_NCC.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_DEV_NCC.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 


Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"FILIAL "              ,1,1) // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"PREFIXO "          	  ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"CLIENTE"              ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"TIPO  "               ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"NUMERO "         	  ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"PARCELA "             ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"DATA EMISSAO "        ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"DATA VCNTO "    	  ,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"NF_ORIGEM"     		  ,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"VALOR"     			  ,1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"SALDO "               ,1,1) // 11 K 			
	oExcel:AddColumn(cPlanilha,cTitulo,"DIF "        		  ,1,1) // 12 L
	oExcel:AddColumn(cPlanilha,cTitulo,"TIPO OCORRENCIA " 	  ,1,1) // 13 M

		
RETURN(NIL)