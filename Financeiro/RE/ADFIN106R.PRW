#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"    
#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} User Function ADFIN106R
    (Programa Para Gerar Relatorio em EXCEL da Tabela SA1 ou PB3)
    @type  Function
    @author ADRIANO SAVOINE
    @since 11/01/2021
    @version 01
    @history ticket 3557 - 11/01/2021 - ADRIANO SAVOINE - Gerar relatorio da SA1 e PB3 filtrando pela Data de Vencimento do Limite de Credito.
    @history ticket  TI  - 21/01/2021 - ADRIANO SAVOINE - Ajustado os Campos Data para trazer o Filtro do Excel por Ano.
    /*/


User Function ADFIN106R()

	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="RELACAO DE CLIENTES"    
	Private nOpca		:=0
    Private cPerg   	:= 'ADFIN106R'


	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
                                                                   
    //Chama a Function de pergunta 
	MontaPerg()


	AADD(aSays,"Este programa tem a finalidade de gerar um arquivo Excel " )
	AADD(aSays,"Relacao dos Clientes da ADoro" )
    
    AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})

    AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), MV_PAR03  }})

    AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons ) 


    IF MV_PAR03 == 1

        Processa({||ADFIN106RSA1()},"Gerando arquivo","Aguarde...")  

    ENDIF

    IF MV_PAR03 == 2

        Processa({||ADFIN106RPB3()},"Gerando arquivo","Aguarde...")  
       
    ENDIF

	 
	
Return (Nil)  

/*/{Protheus.doc} Static Function ADFIN106RSA1
    (Gera Relatorio em EXCEL SA1)
    @type  Function
    @author ADRIANO SAVOINE
    @since 11/01/2021
    /*/

Static Function ADFIN106RSA1()    
	Public oExcel      := FWMSEXCEL():New()
	Public cArquivo    := 'REL_SA1.XML'
	Public oMsExcel
	Public cPlanilha   := "SA1"
    Public cTitulo     := "CLIENTES SA1"
    Public cCodProdSql := ''
    Public aLinhas    := {}
   
	BEGIN SEQUENCE
		
		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("NÃ£o Existe Excel Instalado")
            BREAK
        EndIF
		
		Cabecsa1()             
		GeraExcelsa1()
	          
		SalvaXmlsa1()
		CriaExcelsa1()
	
	    MsgInfo("Arquivo Excel gerado!")    
	    
	END SEQUENCE

Return(NIL) 

Static Function GeraExcelsa1()
                          
	Local nLinha      := 0
	Local nExcel      := 0


    SqlGeralsa1() 
	
	DBSELECTAREA("TRB")
		TRB->(DBGOTOP())
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
                               "", ; // 22 V    
			   	               ""  ; // 23 W 
                               })
				//===================== FINAL CRIA VETOR COM POSICAO VAZIA
				
				//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================

                                aLinhas[nLinha][01] := TRB->A1_COD      
                                aLinhas[nLinha][02] := TRB->A1_LOJA
                                aLinhas[nLinha][03] := TRB->A1_NOME
                                aLinhas[nLinha][04] := TRB->A1_CGC
                                aLinhas[nLinha][05] := TRB->A1_BCO1
                                aLinhas[nLinha][06] := TRB->A1_COND
                                aLinhas[nLinha][07] := TRB->A1_DESC
                                aLinhas[nLinha][08] := TRB->A1_RISCO
                                aLinhas[nLinha][09] := TRB->A1_LC
                                aLinhas[nLinha][10] := TRB->A1_VENCLC
                                aLinhas[nLinha][11] := TRB->A1_MCOMPRA
                                aLinhas[nLinha][12] := TRB->A1_METR
                                aLinhas[nLinha][13] := TRB->A1_MSALDO
                                aLinhas[nLinha][14] := TRB->A1_NROCOM
                                aLinhas[nLinha][15] := TRB->A1_PRICOM
                                aLinhas[nLinha][16] := TRB->A1_ULTCOM
                                aLinhas[nLinha][17] := TRB->A1_MATR
                                aLinhas[nLinha][18] := TRB->A1_MSBLQL
                                aLinhas[nLinha][19] := TRB->A1_CODRED
                                aLinhas[nLinha][20] := TRB->A1_DTACUMU
                                aLinhas[nLinha][21] := TRB->A1_VLACUMU
                                aLinhas[nLinha][22] := TRB->A1_ATR
                                aLinhas[nLinha][23] := TRB->A1_SALDUP                           
				
				//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				
			TRB->(dbSkip())    
		
		END //end do while TRB
		TRB->( DBCLOSEAREA() )   
		
		//============================== INICIO IMPRIME LINHA NO EXCEL
		FOR nExcel := 1 TO nLinha
	   	oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],;
                                        aLinhas[nExcel][02],;
                                        aLinhas[nExcel][03],;
                                        aLinhas[nExcel][04],;
                                        aLinhas[nExcel][05],;
                                        aLinhas[nExcel][06],;
                                        aLinhas[nExcel][07],;
                                        aLinhas[nExcel][08],;
                                        aLinhas[nExcel][09],;
                                        Stod(aLinhas[nExcel][10]),;
                                        aLinhas[nExcel][11],;
                                        aLinhas[nExcel][12],;
                                        aLinhas[nExcel][13],;
                                        aLinhas[nExcel][14],;
                                        Stod(aLinhas[nExcel][15]),;
                                        Stod(aLinhas[nExcel][16]),;
                                        aLinhas[nExcel][17],;
                                        aLinhas[nExcel][18],;
                                        aLinhas[nExcel][19],;
                                        Stod(aLinhas[nExcel][20]),;
                                        aLinhas[nExcel][21],;
                                        aLinhas[nExcel][22],;
                                        aLinhas[nExcel][23];
										}) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS				
	   NEXT 
	 	//============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SqlGeralsa1()
     
    BeginSQL Alias "TRB"
			%NoPARSER%
			SELECT  A1_COD,
                    A1_LOJA,
                    A1_NOME,
                    A1_CGC,
                    A1_BCO1,
                    A1_COND,
                    A1_DESC,
                    A1_RISCO,
                    A1_LC,
                    A1_VENCLC,
                    A1_MCOMPRA,
                    A1_METR,
                    A1_MSALDO,
                    A1_NROCOM,
                    A1_PRICOM,
                    A1_ULTCOM,
                    A1_MATR,
                    CASE WHEN A1_MSBLQL = '1' THEN 'SIM' ELSE 'NAO' END A1_MSBLQL,
                    A1_CODRED,
                    A1_DTACUMU,
                    A1_VLACUMU,
                    A1_ATR,
                    A1_SALDUP
			  FROM  %Table:SA1% SA1 WITH(NOLOCK)
			  WHERE  A1_VENCLC >= %exp:MV_PAR01% 
              AND A1_VENCLC <=  %exp:MV_PAR02%
              AND SA1.%notDel%		
	EndSQl
RETURN()    

Static Function SalvaXmlsa1()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_SA1.XML")

Return()

Static Function CriaExcelsa1()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_SA1.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 


                                
Static Function Cabecsa1() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"Codigo do Cliente"              ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Loja do Cliente"                ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Nome do cliente"                ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"CGC/CPF do cliente"             ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"BANCO 1"                        ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Condicao de Pagamento"          ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Desconto ao cliente"            ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Grau de Risco do cliente"       ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Limite de Cred.do cliente"      ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Vencimento do Lim. Credit"      ,1,4)     
    oExcel:AddColumn(cPlanilha,cTitulo,"Maior Compra do cliente"        ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Méd.de atrasos do cliente"      ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Maior Saldo do cliente"         ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Nro de compras do cliente"      ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Data 1a Compra do cliente"      ,1,4)
    oExcel:AddColumn(cPlanilha,cTitulo,"Data da ultima Compra"          ,1,4)
    oExcel:AddColumn(cPlanilha,cTitulo,"Maior atraso do cliente"        ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Bloqueado"                      ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Codigo Rede"                    ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Data Acumulo da CISP"           ,1,4)
    oExcel:AddColumn(cPlanilha,cTitulo,"Valor de Maior Acumulo"         ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Valor dos Atrasos"              ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Saldo Duplic. do cliente"       ,1,1)
	
RETURN(NIL)

/*/{Protheus.doc} Static Function ADFIN106RPB3
    (Relatorio em EXCEL PB3)
    @type  Function
    @author ADRIANO SAVOINE
    @since 11/01/2021
    /*/

Static Function ADFIN106RPB3()    
	Public oExcel      := FWMSEXCEL():New()
	Public cArquivo    := 'REL_PB3.XML'
	Public oMsExcel
	Public cPlanilha   := "PB3"
    Public cTitulo     := "CLIENTES PB3"
    Public cCodProdSql := ''
    Public aLinhas    := {}
   
	BEGIN SEQUENCE
		
		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("NÃ£o Existe Excel Instalado")
            BREAK
        EndIF
		
		Cabecpb3()             
		GeraExcelpb3()
	          
		SalvaXmlpb3()
		CriaExcelpb3()
	
	    MsgInfo("Arquivo Excel gerado!")    
	    
	END SEQUENCE

Return(NIL) 

Static Function GeraExcelpb3()
                          
	Local nLinha      := 0
	Local nExcel      := 0


    SqlGeralpb3() 
	
	DBSELECTAREA("TRB")
		TRB->(DBGOTOP())
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
                               "", ; // 22 V     
			   	               ""  ; // 23 W 
                               })
				//===================== FINAL CRIA VETOR COM POSICAO VAZIA
				
				//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================

                                aLinhas[nLinha][01] := TRB->PB3_CODSA1      
                                aLinhas[nLinha][02] := TRB->PB3_LOJSA1
                                aLinhas[nLinha][03] := TRB->PB3_NOME
                                aLinhas[nLinha][04] := TRB->PB3_CGC
                                aLinhas[nLinha][05] := TRB->PB3_BCO1
                                aLinhas[nLinha][06] := TRB->PB3_COND
                                aLinhas[nLinha][07] := TRB->PB3_DESC
                                aLinhas[nLinha][08] := TRB->PB3_RISCO
                                aLinhas[nLinha][09] := TRB->PB3_LC
                                aLinhas[nLinha][10] := TRB->PB3_VENCLC
                                aLinhas[nLinha][11] := TRB->PB3_MCOMPR
                                aLinhas[nLinha][12] := TRB->PB3_METR
                                aLinhas[nLinha][13] := TRB->PB3_MSALDO
                                aLinhas[nLinha][14] := TRB->PB3_NROCOM
                                aLinhas[nLinha][15] := TRB->PB3_PRICOM
                                aLinhas[nLinha][16] := TRB->PB3_ULTCOM
                                aLinhas[nLinha][17] := TRB->PB3_MATR
                                aLinhas[nLinha][18] := TRB->PB3_BLOQUE
                                aLinhas[nLinha][19] := TRB->PB3_CODRED
                                aLinhas[nLinha][20] := TRB->PB3_XDTRIS
                                aLinhas[nLinha][21] := TRB->PB3_VACUM
                                aLinhas[nLinha][22] := TRB->PB3_ATR
                                aLinhas[nLinha][23] := TRB->PB3_SALDUP                            
				
				//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				
			TRB->(dbSkip())    
		
		END //end do while TRB
		TRB->( DBCLOSEAREA() )   
		
		//============================== INICIO IMPRIME LINHA NO EXCEL
		FOR nExcel := 1 TO nLinha
	   	oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],;
                                        aLinhas[nExcel][02],;
                                        aLinhas[nExcel][03],;
                                        aLinhas[nExcel][04],;
                                        aLinhas[nExcel][05],;
                                        aLinhas[nExcel][06],;
                                        aLinhas[nExcel][07],;
                                        aLinhas[nExcel][08],;
                                        aLinhas[nExcel][09],;
                                        Stod(aLinhas[nExcel][10]),;
                                        aLinhas[nExcel][11],;
                                        aLinhas[nExcel][12],;
                                        aLinhas[nExcel][13],;
                                        aLinhas[nExcel][14],;
                                        Stod(aLinhas[nExcel][15]),;
                                        Stod(aLinhas[nExcel][16]),;
                                        aLinhas[nExcel][17],;
                                        aLinhas[nExcel][18],;
                                        aLinhas[nExcel][19],;
                                        Stod(aLinhas[nExcel][20]),;
                                        aLinhas[nExcel][21],;
                                        aLinhas[nExcel][22],;
                                        aLinhas[nExcel][23];
										}) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS				
	   NEXT 
	 	//============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SqlGeralpb3()
     
    BeginSQL Alias "TRB"
			%NoPARSER%
			SELECT  PB3_CODSA1,PB3_LOJSA1 , PB3_NOME,PB3_CGC,PB3_BCO1,PB3_COND,PB3_DESC,
                    PB3_RISCO,
                    PB3_LC,
                    PB3_VENCLC,
                    PB3_MCOMPR,
                    PB3_METR,
                    PB3_MSALDO,
                    PB3_NROCOM,
                    PB3_PRICOM,
                    PB3_ULTCOM,
                    PB3_MATR,
                    CASE WHEN PB3_BLOQUE = '1' THEN 'SIM' ELSE 'NAO' END PB3_BLOQUE,
                    PB3_CODRED,
                    PB3_XDTRIS,
                    PB3_VACUM,
                    PB3_ATR,
                    PB3_SALDUP
			  FROM  %Table:PB3% PB3 WITH(NOLOCK)
			  WHERE  PB3.PB3_VENCLC >= %exp:MV_PAR01% 
              AND PB3.PB3_VENCLC <=  %exp:MV_PAR02%
              AND PB3.%notDel%		
	EndSQl
RETURN()    

Static Function SalvaXmlpb3()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_PB3.XML")

Return()

Static Function CriaExcelpb3()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_PB3.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 


                                
Static Function Cabecpb3() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"Codigo do Cliente"              ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Loja do Cliente"                ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Nome do cliente"                ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"CGC/CPF do cliente"             ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"BANCO 1"                        ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Condicao de Pagamento"          ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Desconto ao cliente"            ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Grau de Risco do cliente"       ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Limite de Cred.do cliente"      ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Vencimento do Lim. Credit"      ,1,4)     
    oExcel:AddColumn(cPlanilha,cTitulo,"Maior Compra do cliente"        ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Méd.de atrasos do cliente"      ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Maior Saldo do cliente"         ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Nro de compras do cliente"      ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Data 1a Compra do cliente"      ,1,4)
    oExcel:AddColumn(cPlanilha,cTitulo,"Data da ultima Compra"          ,1,4)
    oExcel:AddColumn(cPlanilha,cTitulo,"Maior atraso do cliente"        ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Bloqueado"                      ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Codigo Rede"                    ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Data Acumulo da CISP"           ,1,4)
    oExcel:AddColumn(cPlanilha,cTitulo,"Valor de Maior Acumulo"         ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Valor dos Atrasos"              ,1,1)
    oExcel:AddColumn(cPlanilha,cTitulo,"Saldo Duplic. do cliente"       ,1,1)
	
RETURN(NIL)


/*/{Protheus.doc} User Function MontaPerg
	(Valida Perguntas)
	@type  Function
	@author user
	@since 11/01/2021
	@version 01
	/*/

Static Function MontaPerg()

	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil

	 u_xPutSx1(cPerg,'01','DATA          Ini                ?','','','mv_ch1','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR01')
	 u_xPutSx1(cPerg,'02','DATA          Fin                ?','','','mv_ch2','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR02')
	 u_xPutSx1(cPerg,'03','Gerar Relatorio SA1 ou PB3       ?','','','mv_ch2','N',01,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR03')

	Pergunte(cPerg,.F.)

Return Nil
