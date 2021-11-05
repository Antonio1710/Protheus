#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch" 

/*{Protheus.doc} User Function ADGPE080R
	Relatorio para acompanhamento de tempo de permanencia do Dimep de Funcionarios. Relatorio em Excel.
	@type  Function
	@author ADRIANO SAVOINE
	@since 02/11/2021
	@version 01
	@history Ticket: 62820 - 02/11/2021 - Adriano Savoine 
*/

User Function ADGPE080R()
	

	PRIVATE aSays		:={}
	PRIVATE aButtons	:={}   
	PRIVATE cCadastro	:= "Relatorio Tempo de Permanência de Funcionario Dimep"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	PRIVATE nOpca		:= 0
	PRIVATE cPerg		:= 'ADGPE080R'
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio Tempo de Permanência de Funcionario Dimep" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||GPEADGPE080R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  

Static Function GPEADGPE080R()    

	PRIVATE oExcel     := FWMSEXCEL():New()
	PRIVATE cPath      := ''
	PRIVATE cArquivo   := 'REL_TEMPO_FUNC_DIMEP' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	PRIVATE oMsExcel
	PRIVATE cPlanilha  := 'FUNCIONARIO' 
    PRIVATE cTitulo    := "Relatorio Tempo de Permanência de FUNCIONARIO - " + DTOC(MV_PAR03) + ' ate ' + DTOC(MV_PAR04)
    PRIVATE aLinhas    := {}
    PRIVATE aLin2      := {}
    PRIVATE aLin3      := {}
    PRIVATE aLin4      := {}
    PRIVATE aLin5      := {}
      
	BEGIN SEQUENCE
		
		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("Não Existe Excel Instalado")
            BREAK
        EndIF
        
        
        // *** INICIO VERIFICACAO DAS PERGUNTAS NAO PODEM VIR COM EM BRANCO E NEM LETRAS *** //
        
        DO CASE 
        	CASE ISALPHA(MV_PAR01) == .T. .OR. ALLTRIM(MV_PAR01) == ''
        	 	ALERT("Olá " + Alltrim(cUserName) + ", parâmetro CPF de não pode ser branco ou ter letras, favor usar somente números!!!")
        	 	BREAK
        	CASE ISALPHA(MV_PAR02) == .T. .OR. ALLTRIM(MV_PAR02) == ''
        	 	ALERT("Olá " + Alltrim(cUserName) + ", parâmetro CPF até não pode ser branco ou ter letras, favor usar somente números!!!")
        	 	BREAK
        	CASE ISALPHA(MV_PAR03) == .T. .OR. DTOS(MV_PAR03) == ''
        	 	ALERT("Olá " + Alltrim(cUserName) + ", parâmetro DATA de não pode ser branco, favor usar somente números!!!")
        	 	BREAK
        	CASE ISALPHA(MV_PAR04) == .T. .OR. DTOS(MV_PAR04) == ''
        	 	ALERT("Olá " + Alltrim(cUserName) + ", parâmetro DATA até não pode ser branco, favor usar somente números!!!")
        	 	BREAK 	 	 	
        ENDCASE
                
        // *** FINAL VERIFICACAO DAS PERGUNTAS NAO PODEM VIR COM EM BRANCO E NEM LETRAS *** //
        
		u_GrLogZBE (Date(),TIME(),cUserName," Relatorio de Funcionario","PORTARIA/DIMEP","ADGPE080R",;
					"Gerou o Relatorio",ComputerName(),LogUserName())
		Cabec()             
		GeraExcel()
	          
		SalvaXml()
		CriaExcel()
	
	    MsgInfo("Arquivo Excel gerado!")    
	    
	END SEQUENCE

Return(NIL) 

Static Function GeraExcel()

    Local nLinha         := 0
	Local nExcel         := 0
	
	SqlAcesso()
	
	// *** INCIO PLANILHA *** //
	DBSELECTAREA("TRC")
	DBGOTOP()
	ProcRegua(LASTREC())
	TRC->(DBGOTOP())
	WHILE !TRC->(EOF()) 
			
		nLinha     := nLinha + 1

		IncProc("Processando!!!" + nLinha)

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
		aLinhas[nLinha][01] := TRC->CREDENCIAL                 //A
		aLinhas[nLinha][02] := TRC->CPF                          //B
		aLinhas[nLinha][03] := TRC->NOME_COMPLETO                        //C
		aLinhas[nLinha][04] := TRC->ESTRUTURA                           //D
		aLinhas[nLinha][05] := TRC->GRUPO_EQUIPAMENTO                            //E
		aLinhas[nLinha][06] := TRC->EQUIPAMENTO                         //F
		aLinhas[nLinha][07] := TRC->SENTIDO_CONSULTA                              //G
		aLinhas[nLinha][08] := TRC->DT_REQUISICAO                        //H
		aLinhas[nLinha][09] := TRC->DS_TIPO_CREDENCIAL                  //I
		
		TRC->(DBSKIP()) 
		//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
	ENDDO
		TRC->(DbCloseArea()) 
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


Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\" + cArquivo)

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\" + cArquivo)
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return()       

Static Function MontaPerg() 
                                 
	Private bValid	:= Nil 
	Private cF3		:= Nil
	Private cSXG	:= Nil
	Private cPyme	:= Nil
	
    U_xPutSx1(cPerg,'01','CPF de                ?','','','mv_ch1','C',11,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR01')
	U_xPutSx1(cPerg,'02','CPF Ate               ?','','','mv_ch2','C',11,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR02')
	U_xPutSx1(cPerg,'03','Data De                    ?','','','mv_ch3','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR03')
	U_xPutSx1(cPerg,'04','Data Ate                   ?','','','mv_ch4','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR04')
	Pergunte(cPerg,.F.)
	
Return Nil            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)                                    
	oExcel:AddColumn(cPlanilha,cTitulo,"Credencial"                ,1,1) // 01 A
    oExcel:AddColumn(cPlanilha,cTitulo,"CPF"               	       ,1,1) // 02 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Nome Completo"             ,1,1) // 03 C    
    oExcel:AddColumn(cPlanilha,cTitulo,"Estrutura "                ,1,1) // 04 D
    oExcel:AddColumn(cPlanilha,cTitulo,"Grupo Equipamento "        ,1,1) // 05 E
  	oExcel:AddColumn(cPlanilha,cTitulo,"Equipamento "              ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"Sentido da Consulta "      ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"Data Requisição "          ,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"DS Tipo Credencial "       ,1,1) // 09 I
	
  	
  
RETURN(NIL)



Static Function SqlAcesso()

    BeginSQL Alias "TRC"
			%NoPARSER%
			 SELECT NU_CREDENCIAL AS CREDENCIAL,
						NU_MATRICULA AS CPF,
						NM_PESSOA AS NOME_COMPLETO,
						LOG_ACESSO.NM_ESTRUTURA AS ESTRUTURA,
						DS_GRUPO AS GRUPO_EQUIPAMENTO,
						DS_EQUIPAMENTO AS EQUIPAMENTO,
						CASE WHEN TP_SENTIDO_CONSULTA = '1' THEN 'ENTRADA' ELSE 'SAIDA' END AS SENTIDO_CONSULTA,
						CONCAT (CONVERT(VARCHAR,DT_REQUISICAO, 103),' ',
        				CONVERT(VARCHAR,DT_REQUISICAO, 108)) AS DT_REQUISICAO,
						DS_TIPO_CREDENCIAL
				FROM [DIMEP].[DMPACESSOII].[DBO].[LOG_ACESSO] AS LOG_ACESSO
				INNER JOIN [DIMEP].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL]
					ON CD_ESTRUTURA_ORGANIZACIONAL = LOG_ACESSO.CD_ESTRUTURA
					AND CD_ESTRUTURA_RELACIONADA    NOT IN ('1223','8') 
				LEFT JOIN [DIMEP].[DMPACESSOII].[DBO].[TIPO_CREDENCIAL] AS TIPO_CREDENCIAL
						ON TIPO_CREDENCIAL.CD_TIPO_CREDENCIAL = LOG_ACESSO.CD_TIPO_CREDENCIAL
				WHERE NU_DATA_REQUISICAO                                          >= %EXP:DTOS(MV_PAR03)%
					AND NU_DATA_REQUISICAO                                        <= %EXP:DTOS(MV_PAR04)%
				AND NU_MATRICULA                                                  >= %EXP:MV_PAR01%
				AND NU_MATRICULA                                                  <= %EXP:MV_PAR02%
				AND CD_VISITANTE                                                 IS NULL
				AND (CD_EQUIPAMENTO                                               = '4'   //Catraca Portaria
				OR CD_EQUIPAMENTO                                                 = '5'   //Cancela Entrada Portaria
				OR CD_EQUIPAMENTO                                                 = '6'   //Cancela Saida Portaria
				OR CD_EQUIPAMENTO                                                 = '1'   //RESTAURANTE 01
				OR CD_EQUIPAMENTO                                                 = '2'   //RESTAURANTE 02
				OR CD_EQUIPAMENTO                                                 = '3' )  //SALA MOTORISTAS
				AND (TP_EVENTO                                                    = '27'   // Acesso Master
				OR TP_EVENTO                                                      = '10'   // Acesso Concluido
				OR TP_EVENTO                                                      = '12'   // Acesso Batch
				OR TP_EVENTO                                                      = '23')  // Acesso por autorização
				
				ORDER BY DT_REQUISICAO
						
	EndSQl             
    
RETURN()

