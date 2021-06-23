#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"

/*{Protheus.doc} User Function ADGPE028R
	Relatorio para acompanhamento de refeicoes do Dimep totalizando por cafe da manha,almoco,cafe da tarde e janta Relatorio Acessos Refeitorio Dimep para Visitantes Relatorio em Excel. 
	@type  Function
	@author William Costa
	@since 04/10/2017
	@version 01
	@history TICKET  224    - William Costa - 11/11/2020 - Alteração do Fonte na parte de Funcionários, trocar a integração do Protheus para a Integração do RM
	@history ticket  14365  - Fernando Macieir- 19/05/2021 - Novo Linked Server (de VPSRV17 para DIMEP)
*/

User Function ADGPE028R()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio para acompanhamento de refeicoes do Dimep totalizando por cafe da manha,almoco,cafe da tarde e janta Relatorio Acessos Refeitorio Dimep para VisitantesRelatorio em Excel.')
	
	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:= "Relatorio Acessos Refeitorio Dimep"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	Private nOpca		:= 0
	Private cPerg		:= 'ADGPE028R'
	
	//Cria grupo de Perguntas                         

	MontaPerg()
	
	//Monta Form Batch - Interface com o Usuario    
	
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio Acessos Refeitorio Dimep" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||GPEADGPE028R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  

Static Function GPEADGPE028R()    

	Public oExcel      := FWMSEXCEL():New()
	Public cPath       := 'D:\Totvs\Protheus11_Homolog\protheus_data\system\'
	Public cArquivo    := 'REL_VISITANTE_DIMEP.XML'
	Public oMsExcel
	Public cPlanilha   := DTOC(MV_PAR03) + ' ate ' + DTOC(MV_PAR04)
    Public cTitulo     := "Relatorio Acessos Refeitorio Visitante DIMEP - " + DTOC(MV_PAR03) + ' ate ' + DTOC(MV_PAR04)
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

    Private nLinha     := 0
	Private nExcel     := 0
	Private nCred      := ''
    Private nCredold   := ''
    Private nCafeManha := 0 
    Private nAlmoco    := 0
    Private nCafeTarde := 0
    Private nJantar    := 0
    Private cCcusto    := ''   
    Private cNmCCusto  := ''
    Private cNome      := ''    
    Private cMat       := ''

    SqlGeral() 
	
	DBSELECTAREA("TRB")
		TRB->(DBGOTOP())
		
		nCredold  := TRB->NU_CREDENCIAL
		cCcusto   := TRB->NU_ESTRUTURA
		cNmCCusto := TRB->NM_ESTRUTURA
		cNome     := TRB->NM_PESSOA 
		cMat      := ALLTRIM(TRB->MATRICULA)
		
		WHILE TRB->(!EOF()) 
		
		    IF TRB->NU_CREDENCIAL ==  nCredold
			
				nCafeManha := nCafeManha + TRB->CAFE_MANHA
			    nAlmoco    := nAlmoco    + TRB->ALMOCO
			    nCafeTarde := nCafeTarde + TRB->CAFE_TARDE
			    nJantar    := nJantar    + TRB->JANTAR 
			    cCcusto    := TRB->NU_ESTRUTURA
			    cNmCCusto  := TRB->NM_ESTRUTURA
			    cNome      := TRB->NM_PESSOA
			    cMat       := TRB->MATRICULA
	            
			ELSE // GERA CABECALHO DO GRUPO DE PRODUTOS
			
			    IMPRIMELINHA()
			    
			    nCredold   := TRB->NU_CREDENCIAL
			    nCafeManha := nCafeManha + TRB->CAFE_MANHA
			    nAlmoco    := nAlmoco    + TRB->ALMOCO
			    nCafeTarde := nCafeTarde + TRB->CAFE_TARDE
			    nJantar    := nJantar    + TRB->JANTAR
			    cCcusto    := TRB->NU_ESTRUTURA 
			    cNmCCusto  := TRB->NM_ESTRUTURA
			    cNome      := TRB->NM_PESSOA
			    cMat       := TRB->MATRICULA
			    
			ENDIF	
				
			TRB->(dbSkip())    
		
		END //end do while TRB
		TRB->( DBCLOSEAREA() )
		
		IMPRIMELINHA()
		
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
	   	                	                 aLinhas[nExcel][09] ; // 09 I
                                                                  }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS				
       NEXT 
	   //============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function IMPRIMELINHA()
			
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
   	               ""  ; // 09 I  
   	                   })
	//===================== FINAL CRIA VETOR COM POSICAO VAZIA
	
	//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
	aLinhas[nLinha][01] := cValToChar(nCredold) //A
	aLinhas[nLinha][02] := cMat                 //B
	aLinhas[nLinha][03] := cNome                //C
	aLinhas[nLinha][04] := cCcusto              //D
	aLinhas[nLinha][05] := cNmCCusto            //E
	aLinhas[nLinha][06] := nCafeManha           //F
	aLinhas[nLinha][07] := nAlmoco              //G
	aLinhas[nLinha][08] := nCafeTarde           //H
	aLinhas[nLinha][09] := nJantar              //I
	
	//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
	
	nCafeManha := 0
    nAlmoco    := 0
    nCafeTarde := 0
    nJantar    := 0
    cCcusto    := ''
    cNome      := ''
    cMat       := ''

RETURN(NIL)		     	

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_VISITANTE_DIMEP.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_VISITANTE_DIMEP.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return()       

Static Function MontaPerg()                                  
	Private bValid	:= Nil 
	Private cF3		:= Nil
	Private cSXG	:= Nil
	Private cPyme	:= Nil
	
    PutSx1(cPerg,'01','Visitante de        ?','','','mv_ch1','C',10,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR01')
	PutSx1(cPerg,'02','Visitante Ate       ?','','','mv_ch2','C',10,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR02')
	PutSx1(cPerg,'03','Data Refeitorio De  ?','','','mv_ch3','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR03')
	PutSx1(cPerg,'04','Data Refeitorio Ate ?','','','mv_ch4','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR04')
	Pergunte(cPerg,.F.)
Return Nil            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)                                    
	oExcel:AddColumn(cPlanilha,cTitulo,"Num Credencial "      ,1,1) // 01 A
    oExcel:AddColumn(cPlanilha,cTitulo,"Num Matricula"        ,1,1) // 02 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Nome "                ,1,1) // 03 C    
    oExcel:AddColumn(cPlanilha,cTitulo,"Cod CC "              ,1,1) // 04 D
    oExcel:AddColumn(cPlanilha,cTitulo,"Centro de Custo "     ,1,1) // 05 E
  	oExcel:AddColumn(cPlanilha,cTitulo,"Total Cafe da Manha " ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"Total Almoco "        ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"Total Cafe da Tarde " ,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"Total Jantar "        ,1,1) // 09 I
	
RETURN(NIL)

Static Function SqlGeral()

	Local nFil     := 0                                       
	Local cVisIni  := MV_PAR01
	Local cVisFin  := MV_PAR02
	Local cDataIni := DTOS(MV_PAR03)
	Local cDataFin := DTOS(MV_PAR04)
	
	IF CEMPANT == '01' .AND. xFilial("SRA") == '02'
	
		nFil := 9 //Empresa Adoro codigo da filial de Varzea no Dimep
		
	ELSEIF CEMPANT == '02' .AND. xFilial("SRA") == '01'	
	
		nFil := 17 //Empresa Ceres codigo da filial de Varzea
	
	ENDIF	

    BeginSQL Alias "TRB"
			%NoPARSER% 
			SELECT NU_CREDENCIAL,
			       CD_VISITANTE AS MATRICULA,
			       NM_PESSOA,
				   NU_ESTRUTURA,
			       LOG_ACESSO.NM_ESTRUTURA,
			       CASE WHEN CONVERT(VARCHAR(11),DT_REQUISICAO,114) >= '03:30:00.000' AND CONVERT(VARCHAR(11),DT_REQUISICAO,114) <= '08:01:00.000' THEN 1 ELSE 0 END AS CAFE_MANHA,
			       CASE WHEN CONVERT(VARCHAR(11),DT_REQUISICAO,114) >= '09:45:00.000' AND CONVERT(VARCHAR(11),DT_REQUISICAO,114) <= '13:31:00.000' THEN 1 ELSE 0 END AS ALMOCO,
			       CASE WHEN CONVERT(VARCHAR(11),DT_REQUISICAO,114) >= '14:45:00.000' AND CONVERT(VARCHAR(11),DT_REQUISICAO,114) <= '17:01:00.000' THEN 1 ELSE 0 END AS CAFE_TARDE,
			       CASE WHEN CONVERT(VARCHAR(11),DT_REQUISICAO,114) >= '18:00:00.000' AND CONVERT(VARCHAR(11),DT_REQUISICAO,114) <= '23:46:00.000' THEN 1 ELSE 0 END AS JANTAR
			 FROM [DIMEP].[DMPACESSOII].[DBO].[LOG_ACESSO] AS LOG_ACESSO 
			 INNER JOIN  [DIMEP].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] AS ESTRUTURA_ORGANIZACIONAL
					  ON ESTRUTURA_ORGANIZACIONAL.CD_ESTRUTURA_ORGANIZACIONAL        = LOG_ACESSO.CD_ESTRUTURA
					 AND CD_ESTRUTURA_RELACIONADA                                    = %EXP:nFil% // codigo da filial no Dimep
			  WHERE CD_GRUPO            = 1 // Refeitorio 
			    AND NU_DATA_REQUISICAO >= %EXP:cDataIni%
			    AND NU_DATA_REQUISICAO <= %EXP:cDataFin%
			    AND CD_VISITANTE       >= %EXP:cVisIni%
				AND CD_VISITANTE       <= %EXP:cVisFin%
				AND CD_VISITANTE       IS NOT NULL // Traz os visitantes
			    AND CD_AREA_ORIGEM      = 2 // Externo
			    AND CD_AREA_DESTINO     = 3 // Refeitorio
			    AND (TP_EVENTO          = '27' // Acesso Master
			     OR TP_EVENTO           = '10' // Acesso Concluido
			     OR TP_EVENTO           = '12' ) // Acesso Batch
			     
			ORDER BY NU_MATRICULA
			
	EndSQl             
    
RETURN()    
