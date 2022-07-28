#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch" 

/*/{Protheus.doc} User Function ADGPE052R
	Relatorio de Datas de Aso, Integracao e Contratos de terceiros
	@type  Function
	@author William COSTA
	@since 17/06/2019
	@version version
	@history TICKET  224    - William Costa - 11/11/2020 - Alteração do Fonte na parte de Funcionários, trocar a integração do Protheus para a Integração do RM
	@history ticket  14365  - Fernando Macieir- 19/05/2021 - Novo Linked Server (de VPSRV17 para DIMEP)
	@history Ticket  77205 - Adriano Savoine  - 28/07/2022- Alterado o Link de dados de DIMEP para DMPACESSO
/*/

User Function ADGPE052R()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Datas de Aso, Integracao e Contratos de terceiros')
	
	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="Relatorio de Datas Asos Integraca e Contratos de Terceiros"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	Private nOpca		:= 0
	Private cPerg		:= 'ADGPE052R'
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio de Datas Asos Integraca e Contratos de Terceiros" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||RelADGPE052R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         

Static Function RelADGPE052R()    

	Private oExcel      := FWMSEXCEL():New()
	Private cPath       := 'D:\Totvs\Protheus11_Homolog\protheus_data\system\'
	Private cArquivo    := 'REL_DATAS_TERCEIROS.XML'
	Private oMsExcel
	Private cPlanilha   := "Datas Terceiros"
    Private cTitulo     := "Datas Terceiros"
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

    Local cNomeRegiao := ''
	Local nLinha      := 0
	Local nExcel      := 0 
	Local nTotReg	  := 0
	Local cNumPV      := ''
	
	SqlGeral()
	
	//Conta o Total de registros.
	nTotReg := Contar("TRB","!Eof()")
	
	//Atribui a quantidade de registros à régua de processamento.
	ProcRegua(nTotReg)
    DBSELECTAREA("TRB")
		TRB->(DBGOTOP())
		WHILE TRB->(!EOF())
		
			IncProc("Processando Terceiros: " + TRB->NM_PESSOA)  
		
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
			aLinhas[nLinha][01] := TRB->NM_PESSOA                                                                                 //A
			aLinhas[nLinha][02] := TRB->NU_MATRICULA                                                                              //B
			aLinhas[nLinha][03] := TRB->VENC_ASO                                                                                  //C
			aLinhas[nLinha][04] := TRB->VENC_INTEGRACAO                                                                           //D
			aLinhas[nLinha][05] := TRB->VENC_CONTRATO                                                                             //E
			aLinhas[nLinha][06] := IIF(TRB->DATA_ULTIMA_PASSAGEM_DIMEP <> 0,STOD(CVALTOCHAR(TRB->DATA_ULTIMA_PASSAGEM_DIMEP)),'') //F
			aLinhas[nLinha][07] := TRB->NM_ESTRUTURA                                                                              //G
			aLinhas[nLinha][08] := TRB->DS_RAZAO_SOCIAL                                                                           //H
			aLinhas[nLinha][09] := CVALTOCHAR(TRB->NU_CNPJ)                                                                       //I
			                                  
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
		                                 aLinhas[nExcel][09] ; // 09 I  
		                                                    }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
	   NEXT 
	 	//============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SqlGeral()
	 
    BeginSQL Alias "TRB"
			%NoPARSER%
		    SELECT NM_PESSOA,
			       NU_MATRICULA,
			       SUBSTRING(TX_CAMPO01,9,2) + '/' + SUBSTRING(TX_CAMPO01,6,2) + '/' + SUBSTRING(TX_CAMPO01,1,4) AS VENC_ASO,
				   SUBSTRING(TX_CAMPO02,9,2) + '/' + SUBSTRING(TX_CAMPO02,6,2) + '/' + SUBSTRING(TX_CAMPO02,1,4) AS VENC_INTEGRACAO,
				   SUBSTRING(TX_CAMPO03,9,2) + '/' + SUBSTRING(TX_CAMPO03,6,2) + '/' + SUBSTRING(TX_CAMPO03,1,4) AS VENC_CONTRATO,
			       ISNULL((SELECT TOP(1) NU_DATA_REQUISICAO FROM [DMPACESSO].[DMPACESSOII].[DBO].[LOG_ACESSO] WHERE LOG_ACESSO.NU_MATRICULA = PESSOA.NU_MATRICULA ORDER BY LOG_ACESSO.NU_DATA_REQUISICAO DESC),0) AS DATA_ULTIMA_PASSAGEM_DIMEP,
			       NM_ESTRUTURA,
			       DS_RAZAO_SOCIAL,
			       NU_CNPJ
			  FROM [DMPACESSO].[DMPACESSOII].[DBO].[PESSOA]
			  INNER JOIN [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL]
			          ON PESSOA.CD_ESTRUTURA_ORGANIZACIONAL = ESTRUTURA_ORGANIZACIONAL.CD_ESTRUTURA_ORGANIZACIONAL
			  WHERE NU_MATRICULA >= %EXP:MV_PAR01%
			    AND NU_MATRICULA <= %EXP:MV_PAR02%
			    AND (TX_CAMPO01 <> ''
			     OR TX_CAMPO02 <> ''
			     OR TX_CAMPO03 <> '') 
			     
			ORDER BY NM_PESSOA
			 
	EndSQl
RETURN()    

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_HORA_ALCADAS.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_HORA_ALCADAS.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 

Static Function MontaPerg()
                                  
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    U_xPutSx1(cPerg,'01','Matricula Ini ?','','','mv_ch1','N',13,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR01')
	U_xPutSx1(cPerg,'02','Matricula Fin ?','','','mv_ch2','N',13,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR02')
	
	Pergunte(cPerg,.F.)
Return Nil            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"NOME TERCEIRO "               ,1,1) // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"MATRICULA "                   ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"DATA VENCIMENTO ASO "         ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"DATA VENCIMENTO INTEGRACAO "  ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"DATA VENCIMENTO CONTRATO "    ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"DATA ULTIMA PASSSAGEM DIMEP " ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"NOME ESTRUTURA "              ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"RAZAO SOCIAL "                ,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"CNPJ "                        ,1,1) // 09 I
		
RETURN(NIL)
