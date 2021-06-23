#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADFIN017R ºAutor  ³William COSTA       º Data ³  22/09/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório para utilizar como compensacao do contas a       º±±
±±º          ³ receber financeiro                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFAT                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADFIN017R()

	&&Mauricio - 01/03/17 - Alterado conforme chamado 033727
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="Relatorio de Compensacao Financeira"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:=TMSPrinter():New()
	Private nOpca		:=0
	Private cPerg		:= 'ADFIN017R'
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatório para utilizar como compensacao do contas a receber financeiro')
	
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio de Compensacao Financeira" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||LOGADFIN017R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         

Static Function LOGADFIN017R()    
	Public oExcel      := FWMSEXCEL():New()
	Public cPath       := 'D:\Totvs\Protheus11_Homolog\protheus_data\system\'
	Public cArquivo    := 'REL_FIN_COMPENSACAO.XML'
	Public oMsExcel
	Public cPlanilha   := "COMPENSACAO"
    Public cTitulo     := "COMPENSACAO"
    Public cCodProdSql := ''
    Public aLinhas    := {}
   
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

    Local nLinha   := 0
	Local nExcel   := 0

	SqlGeral() 
	
	WHILE TRB->(!EOF()) 
		
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
		               ""  ; // 11 K   
		               })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
				
		//===================== INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===============
		aLinhas[nLinha][01] := TRB->A1_COD           	//A
		aLinhas[nLinha][02] := TRB->A1_NOME          	//B
		aLinhas[nLinha][03] := TRB->A1_TIPO          	//C  //chamado 035215 -22/05/2017 - Fernando Sigoli 
		aLinhas[nLinha][04] := TRB->A1_VEND          	//D
		aLinhas[nLinha][05] := TRB->A1_CGC           	//E
		aLinhas[nLinha][06] := TRB->A2_COD           	//F
		aLinhas[nLinha][07] := TRB->A2_NOME          	//G
		aLinhas[nLinha][08] := FbscSLD(TRB->A1_COD,1)  	//H
		aLinhas[nLinha][09] := FbscSLD(TRB->A2_COD,2)  	//I
		aLinhas[nLinha][10] := STOD(TRB->E2_VENCREA) 	//J
		aLinhas[nLinha][11] := STOD(TRB->E2VENCREA)  	//K
			                                  
		//====================== FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===============			
		
		TRB->(dbSkip())    
	
	END //end do while TRB
	TRB->( DBCLOSEAREA() )  
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	FOR nExcel := 1 TO nLinha
   	oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],;  // 01 A  
                                     aLinhas[nExcel][02],;  // 02 B  
                                     aLinhas[nExcel][03],;  // 02 C  
                                     aLinhas[nExcel][04],;  // 03 D  
   	                                 aLinhas[nExcel][05],;  // 04 E 
   	                                 aLinhas[nExcel][06],;  // 05 F   
   	                                 aLinhas[nExcel][07],;  // 06 G  
   	                                 aLinhas[nExcel][08],;  // 07 H  
   	                                 aLinhas[nExcel][09],;  // 08 I 
   	                                 aLinhas[nExcel][10],;  // 09 J   
   	                                 aLinhas[nExcel][11] ;  // 10 K   	                                    	                                    	                                   
   	                                                     }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS				
    NEXT 
	//============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SqlGeral()
                     	  
	  BeginSQL Alias "TRB"
			%NoPARSER%   
        SELECT A1_COD, 
		       A1_NOME,
		       A1_TIPO, 
		 	   A1_VEND, 
			   A1_CGC,
			   A2_COD,
			   A2_NOME,			   			   
			   MIN(E2_VENCREA) AS E2_VENCREA,
			   MAX(E2_VENCREA) AS E2VENCREA 
		  FROM %Table:SA1%,%Table:SA2%,%Table:SE1%, %Table:SE2%
		 WHERE (%Table:SA1%.D_E_L_E_T_  <> '*'
		   AND A1_VEND             >= %EXP:MV_PAR01%
		   AND A1_VEND             <= %EXP:MV_PAR02%
		   AND A1_COD              <> '035232'
		   AND A2_CGC              <> ''
		   AND A2_CGC              = A1_CGC 
		   AND %Table:SA2%.D_E_L_E_T_  <> '*')
		   AND E1_SALDO           > 0
		   AND E1_TIPO             = 'NF'
		   AND E1_CLIENTE          = A1_COD
		   AND E1_LOJA             = A1_LOJA
		   AND %Table:SE1%.D_E_L_E_T_  <> '*'
		   AND E2_FORNECE          = A2_COD
		   AND E2_LOJA             = A2_LOJA
		   AND E2_SALDO            > 0
		   AND E2_TIPO             = 'NF'
		   AND %Table:SE2%.D_E_L_E_T_  <> '*' 
		
		   GROUP BY A1_COD, 
			        A1_NOME,
			        A1_TIPO, //chamado 035215 -22/05/2017 - Fernando Sigoli 
			        A1_VEND, 
					A1_CGC,
					A2_COD,
					A2_NOME
		
		   ORDER BY A1_NOME	    
        	
	EndSQl
RETURN(NIL)  

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_FIN_COMPENSACAO.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_FIN_COMPENSACAO.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 

Static Function MontaPerg() 
                                 
	Private bValid	:=Nil                                                                                                                    
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    PutSx1(cPerg,'01','Vendedor de  ?','','','mv_ch01','C',06,0,0,'G',bValid,'SA3',cSXG,cPyme,'MV_PAR01')
	PutSx1(cPerg,'02','Vendedor Até ?','','','mv_ch02','C',06,0,0,'G',bValid,'SA3',cSXG,cPyme,'MV_PAR02')
	Pergunte(cPerg,.F.)
	
Return (Nil)            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"Cod Cliente "        ,1,1)   // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Cliente "       ,1,1)   // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Tipo"		         ,1,1)   // 03 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Vendedor "           ,1,1)   // 04 C
	oExcel:AddColumn(cPlanilha,cTitulo,"CNPJ "               ,1,1)   // 05 D
	oExcel:AddColumn(cPlanilha,cTitulo,"Cod Fornecedor "     ,1,1)   // 06 E
	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Fornecedor "    ,1,1)   // 07 F
	oExcel:AddColumn(cPlanilha,cTitulo,"Saldo a Receber "    ,1,1)   // 08 G
	oExcel:AddColumn(cPlanilha,cTitulo,"Saldo a Pagar "      ,1,1)   // 09 H
	oExcel:AddColumn(cPlanilha,cTitulo,"Vencto a Pagar Antigo" ,1,1) // 10 I
	oExcel:AddColumn(cPlanilha,cTitulo,"Vencto a Pagar Recente" ,1,1)// 11 J
	
RETURN(NIL)

Static function FBSCSLD(_cCOD,_nTp)
_nResult := 0

IF _nTp == 1
	If Select ("TSE1") > 0
		DbSelectArea("TSE1")
		TSE1->(DbCloseArea())
	Endif
	
	_cQuery := ""
	_cQuery += "SELECT SUM(E1_SALDO) AS SALDO, E1_CLIENTE FROM "+RetSqlName("SE1")+" "
	_cQuery += " WHERE E1_CLIENTE = '"+_cCod+"' AND E1_TIPO = 'NF' "
	_cQuery += "AND E1_SALDO > 0 AND D_E_L_E_T_ <> '*' "
	_cQuery+= " GROUP BY E1_CLIENTE "
	_cQuery+= " ORDER BY E1_CLIENTE "
	
	TcQuery _cQuery NEW ALIAS "TSE1"
	
	DbSelectArea("TSE1")
	DbGotop()
	
	_nResult := TSE1->SALDO
	
Else
	If Select ("TSE2") > 0
		DbSelectArea("TSE2")
		TSE2->(DbCloseArea())
	Endif
	
	_cQuery := ""
	_cQuery += "SELECT SUM(E2_SALDO) AS SALDO, E2_FORNECE FROM "+RetSQLNAME("SE2")+" "
	_cQuery += "WHERE E2_FORNECE = '"+_cCod+"' AND E2_TIPO = 'NF' "
	_cQuery += "AND E2_SALDO > 0 AND D_E_L_E_T_ <> '*' "
	_cQuery += " GROUP BY E2_FORNECE "
	_cQuery += " ORDER BY E2_FORNECE "
	
	TcQuery _cQuery NEW ALIAS "TSE2"
	
	DbSelectArea("TSE2")
	DbGotop()
	
	_nResult := TSE2->SALDO
		
Endif

Return(_nResult)