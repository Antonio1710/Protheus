/*  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADCOM005R ºAutor  ³LUCIANO MAFRA       º Data ³  30/10/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³                                                            º±±
±±ºDesc.     ³ Relação e fornecedores críticos em excel                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"    
#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"

User Function ADCOM005R()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="RELACAO DE FORNECEDORES CRITICOS"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:=TMSPrinter():New()
	Private nOpca		:=0
//	Private cPerg		:= 'ADCOM001R'
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
//	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
                                                                   

	AADD(aSays,"Este programa tem a finalidade de gerar um arquivo Excel " )
	AADD(aSays,"Relacao dos Fornecedores Criticos da ADoro" )
    
//	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||ComADCOM005R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         

Static Function ComADCOM005R()    
	Public oExcel      := FWMSEXCEL():New()
	Public cPath       := 'D:\Totvs\Protheus11_Homolog\protheus_data\system\'
	Public cArquivo    := 'REL_FORNECEDORES_CRITICOS.XML'
	Public oMsExcel
	Public cPlanilha   := "Criticos"
    Public cTitulo     := "Fornecedores Criticos"
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
                          
	Local nLinha      := 0
	Local nExcel      := 0
/*
    Local aVencto     := {} 
    Local aDados      := {}
	Local cNomeRegiao := ''
	Local nCont       := 0 
	Local ntotDiaParc := 0
	Local nMedia      := 0
	Local nLinha      := 0
	Local nExcel      := 0
	Local cParcela    := ''
	Local cTipo       := ''
	Local cTpFrete    := ''
	Local cDDD        := ''
*/
    SqlGeral() 
	
	DBSELECTAREA("TRB")
		TRB->(DBGOTOP())
		WHILE TRB->(!EOF()) 
		        
	            nLinha  := nLinha + 1                                       
			
                //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
			   	AADD(aLinhas,{ "", ; // 01 A  
			   	               "", ; // 02 B   
			   	               ""  ; // 08 C  
                               })
				//===================== FINAL CRIA VETOR COM POSICAO VAZIA
				
				//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================

				aLinhas[nLinha][01] := TRB->A2_COD                                   //A
				aLinhas[nLinha][02] := TRB->A2_LOJA                                  //B
				aLinhas[nLinha][03] := TRB->A2_NOME                                  //C

				//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				
			TRB->(dbSkip())    
		
		END //end do while TRB
		TRB->( DBCLOSEAREA() )   
		
		//============================== INICIO IMPRIME LINHA NO EXCEL
		FOR nExcel := 1 TO nLinha
	   	oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],;  // 01 A  
                                         aLinhas[nExcel][02],;  // 02 B  
	   	                                 aLinhas[nExcel][03];   // 03 C  
															 }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS				
	   NEXT 
	 	//============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SqlGeral()
     
    BeginSQL Alias "TRB"
			%NoPARSER%
			SELECT  A2_COD,     
	                A2_LOJA,     
	                A2_NOME 
			  FROM  %Table:SA2% SA2
			  WHERE SA2.A2_CRITICO = "S" 
			    AND SA2.%notDel%

			    ORDER BY SA2.A2_NOME			
	EndSQl
RETURN()    

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_FORNECEDORES_CRITICOS.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_FORNECEDORES_CRITICOS.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 

/*
Static Function MontaPerg()                                  
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    PutSx1(cPerg,'01','Filial De               ?','','','mv_ch1','C',02,0,0,'G',bValid,cF3    ,cSXG,cPyme,'MV_PAR01')
	PutSx1(cPerg,'02','Filial Ate              ?','','','mv_ch2','C',02,0,0,'G',bValid,cF3    ,cSXG,cPyme,'MV_PAR02')
	PutSx1(cPerg,'03','Pedido Compra De        ?','','','mv_ch3','C',06,0,0,'G',bValid,"SC7"  ,cSXG,cPyme,'MV_PAR03')
	PutSx1(cPerg,'04','Pedido Compra Ate       ?','','','mv_ch4','C',06,0,0,'G',bValid,"SC7"  ,cSXG,cPyme,'MV_PAR04')
	PutSx1(cPerg,'05','Nota de Entrada De      ?','','','mv_ch5','C',09,0,0,'G',bValid,"SF102",cSXG,cPyme,'MV_PAR05')
	PutSx1(cPerg,'06','Nota de Entrada Ate     ?','','','mv_ch6','C',09,0,0,'G',bValid,"SF102",cSXG,cPyme,'MV_PAR06')
	PutSx1(cPerg,'07','Data Emissao Pedido De  ?','','','mv_ch7','D',08,0,0,'G',bValid,cF3    ,cSXG,cPyme,'MV_PAR07')
	PutSx1(cPerg,'08','Data Emissao Pedido Ate ?','','','mv_ch8','D',08,0,0,'G',bValid,cF3    ,cSXG,cPyme,'MV_PAR08')
	Pergunte(cPerg,.F.)
Return Nil            
*/
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"Codigo "              ,1,1) // 01 A
  	oExcel:AddColumn(cPlanilha,cTitulo,"Loja "                ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Fornecedor "     ,1,1) // 03 C
	
RETURN(NIL)
