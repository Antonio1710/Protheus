#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch" 

/*/{Protheus.doc} User Function ADGPE048R
	Relatorio de Horários de Perfil de Acesso Dimep X Protheus
	@type  Function
	@author William Costa
	@since 03/10/2017
	@version 01
	@history Chamado 050696 - ADRIANO SAVOINE - 29/07/2019 - TROCADO O LEFT JOIN POR INNER JOIN para não trazer funcionario com turno vazio.
	@history TICKET  224    - William Costa   - 11/11/2020 - Alteração do Fonte na parte de Funcionários, trocar a integração do Protheus para a Integração do RM
	@history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud
	@history ticket  14365  - Fernando Macieir- 19/05/2021 - Novo Linked Server (de VPSRV17 para DIMEP)
/*/
User Function ADGPE048R()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Horários de Perfil de Acesso Dimep X Protheus')
	
	// @history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud
	Private cLinked := "" 
	Private cSGBD   := "" 
	//

	Private aSays		:= {}
	Private aButtons	:= {}   
	Private cCadastro	:= "Relatorio de Horários de Perfil de Acesso"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	Private nOpca		:= 0
	Private cPerg		:= 'ADGPE048R'
	
	// @history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud
	cLinked := GetMV("MV_#RMLINK",,"RM") 
	cSGBD   := GetMV("MV_#RMSGBD",,"CCZERN_119204_RM_PD")
	//

	//Cria grupo de Perguntas                         
	MontaPerg()
	 
	//Monta Form Batch - Interface com o Usuario     
	
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio de Horários de Perfil de Acesso" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||GPE0481()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  

Static Function GPE0481()    

	Private oExcel      := FWMSEXCEL():New()
	Private cPath       := 'D:\Totvs\Protheus11_Homolog\protheus_data\system\'
	Private cArquivo    := 'REL_HORA_PERFIL.XML'
	Private oMsExcel
	Private cPlanilha   := "HORA PERFIL"
    Private cTitulo     := "Horário Perfil Empresa: " + CEMPANT + " FILIAL: " + CFILANT  
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

    Local nLinha     := 0
	Local nExcel     := 0 
	Local nTotReg    := 0
	Local nTotReg2   := 0
	Local nTrabalha  := 0
	Local nDemitido  := 0
	Local nAusente   := 0
	Local nDiaSemIni := ''
	Local nDiaSemFin := ''
	Local cDiaSemIni := ''
	Local cDiaSemFin := ''
	
	SqlGeral()
	
	//Conta o Total de registros.
	nTotReg := Contar("TRB","!Eof()")
	
	//Atribui a quantidade de registros à régua de processamento.
	ProcRegua(nTotReg)
    DBSELECTAREA("TRB")
	TRB->(DBGOTOP())
	WHILE TRB->(!EOF())
	
		nLinha  := nLinha + 1                                       

		IncProc("Perfil Padrão: " + TRB->NM_PERFIL_ACESSO + ' Total: ' + CVALTOCHAR(nLinha) + '/' + CVALTOCHAR(nTotReg))  
	
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
		nDiaSemIni          := AcharDiaSemana(CEMPANT,TRB->CODHORARIO,TRB->INDINICIO)
		cDiaSemIni          := EncontrardiaSemana(nDiaSemIni)
		nDiaSemFin          := AcharDiaSemana(CEMPANT,TRB->CODHORARIO,TRB->INDFIM)
		cDiaSemFin          := EncontrardiaSemana(nDiaSemFin)
		aLinhas[nLinha][01] := TRB->CODCOLIGADA      //A
		aLinhas[nLinha][02] := BUSCAEMPRM(TRB->CODCOLIGADA) //B
		aLinhas[nLinha][03] := TRB->NM_PERFIL_ACESSO //C
		aLinhas[nLinha][04] := TRB->CODHORARIO       //D
		aLinhas[nLinha][05] := TRB->DESCRICAO        //E
		aLinhas[nLinha][06] := cDiaSemFin            //F
		aLinhas[nLinha][07] := IIF(AT('.',CVALTOCHAR(TRB->HR_INI)) == 0,TRB->HR_INI,VAL(SUBSTRING(CVALTOCHAR(TRB->HR_INI),1,AT('.',CVALTOCHAR(TRB->HR_INI)) - 1) + '.' + CVALTOCHAR(VAL( '0.' + SUBSTRING(CVALTOCHAR(TRB->HR_INI),AT('.',CVALTOCHAR(TRB->HR_INI)) + 1,LEN(CVALTOCHAR(TRB->HR_INI)))) * 60)))           //G
		aLinhas[nLinha][08] := cDiaSemFin            //H
		aLinhas[nLinha][09] := IIF(AT('.',CVALTOCHAR(TRB->HR_FIN)) == 0,TRB->HR_FIN,VAL(SUBSTRING(CVALTOCHAR(TRB->HR_FIN),1,AT('.',CVALTOCHAR(TRB->HR_FIN)) - 1) + '.' + CVALTOCHAR(VAL( '0.' + SUBSTRING(CVALTOCHAR(TRB->HR_FIN),AT('.',CVALTOCHAR(TRB->HR_FIN)) + 1,LEN(CVALTOCHAR(TRB->HR_FIN)))) * 60)))           //I
		
		nTrabalha := 0
	    nDemitido := 0
	    nAusente  := 0
	    
		SqlQtdPessoa(TRB->NM_PERFIL_ACESSO)
		DBSELECTAREA("TRD")
		TRD->(DBGOTOP())
		WHILE TRD->(!EOF())
		
			nTrabalha := nTrabalha + TRD->TRABALHANDO
			nDemitido := nDemitido + TRD->DEMITIDO
			nAusente  := nAusente  + TRD->AUSENTE
		
			TRD->(dbSkip())    
		
		END //end do while TRB
		TRD->( DBCLOSEAREA() )
		
		aLinhas[nLinha][10] := nTrabalha                        // J
		aLinhas[nLinha][11] := nDemitido                        // K
		aLinhas[nLinha][12] := nAusente                         // L
		aLinhas[nLinha][13] := nTrabalha + nDemitido + nAusente // M
			                                  
		//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
			
		TRB->(dbSkip())    
	
	END //end do while TRB
	TRB->( DBCLOSEAREA() ) 
	
	nTrabalha := 0
    nDemitido := 0
    nAusente  := 0
    
    SqlPerfEsp()
	
	//Conta o Total de registros.
	nTotReg2 := Contar("TRC","!Eof()")
	
	//Atribui a quantidade de registros à régua de processamento.
	ProcRegua(nTotReg2)
    DBSELECTAREA("TRC")
	TRC->(DBGOTOP())
	WHILE TRC->(!EOF())
	
		nLinha  := nLinha + 1                                       

		IncProc("Perfil Especifico: " + TRC->NM_PERFIL_ACESSO + ' Total: ' + CVALTOCHAR(nLinha) + '/' + CVALTOCHAR(nTotReg + nTotReg2))  
	
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
		nDiaSemIni          := AcharDiaSemana(CEMPANT,TRC->CODHORARIO,TRC->INDINICIO)
		cDiaSemIni          := EncontrardiaSemana(nDiaSemIni)
		nDiaSemFin          := AcharDiaSemana(CEMPANT,TRC->CODHORARIO,TRC->INDFIM)
		cDiaSemFin          := EncontrardiaSemana(nDiaSemFin)
		aLinhas[nLinha][01] := TRC->CODCOLIGADA      //A
		aLinhas[nLinha][02] := BUSCAEMPRM(TRC->CODCOLIGADA)        //B
		aLinhas[nLinha][03] := TRC->NM_PERFIL_ACESSO //C
		aLinhas[nLinha][04] := TRC->CODHORARIO       //D
		aLinhas[nLinha][05] := TRC->DESCRICAO        //E
		aLinhas[nLinha][06] := cDiaSemFin            //F
		aLinhas[nLinha][07] := IIF(AT('.',CVALTOCHAR(TRC->HR_INI)) == 0,TRC->HR_INI,VAL(SUBSTRING(CVALTOCHAR(TRC->HR_INI),1,AT('.',CVALTOCHAR(TRC->HR_INI)) - 1) + '.' + CVALTOCHAR(VAL( '0.' + SUBSTRING(CVALTOCHAR(TRC->HR_INI),AT('.',CVALTOCHAR(TRC->HR_INI)) + 1,LEN(CVALTOCHAR(TRC->HR_INI)))) * 60)))           //G
		aLinhas[nLinha][08] := cDiaSemFin            //H
		aLinhas[nLinha][09] := IIF(AT('.',CVALTOCHAR(TRC->HR_FIN)) == 0,TRC->HR_FIN,VAL(SUBSTRING(CVALTOCHAR(TRC->HR_FIN),1,AT('.',CVALTOCHAR(TRC->HR_FIN)) - 1) + '.' + CVALTOCHAR(VAL( '0.' + SUBSTRING(CVALTOCHAR(TRC->HR_FIN),AT('.',CVALTOCHAR(TRC->HR_FIN)) + 1,LEN(CVALTOCHAR(TRC->HR_FIN)))) * 60)))           //I
		
		nTrabalha := 0
	    nDemitido := 0
	    nAusente  := 0
	    
		SqlQtdPessoa(TRC->NM_PERFIL_ACESSO)
		DBSELECTAREA("TRD")
		TRD->(DBGOTOP())
		WHILE TRD->(!EOF())
		
			nTrabalha := nTrabalha + TRD->TRABALHANDO
			nDemitido := nDemitido + TRD->DEMITIDO
			nAusente  := nAusente  + TRD->AUSENTE
		
			TRD->(dbSkip())    
		
		END //end do while TRB
		TRD->( DBCLOSEAREA() )
		
		aLinhas[nLinha][10] := nTrabalha                        // J
		aLinhas[nLinha][11] := nDemitido                        // K
		aLinhas[nLinha][12] := nAusente                         // L
		aLinhas[nLinha][13] := nTrabalha + nDemitido + nAusente // M
			                                  
		//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
			
		TRC->(dbSkip())    
	
	END //end do while TRC
	TRC->( DBCLOSEAREA() ) 
	
	nTrabalha := 0
    nDemitido := 0
    nAusente  := 0
    
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
									 aLinhas[nExcel][13] ; // 13 M   
	                                                    }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
   NEXT 
 	//============================== FINAL IMPRIME LINHA NO EXCEL
 	
Return()    

STATIC FUNCTION AcharDiaSemana(cEmpresa,cTurno,nIndiceTurno)

	Local nDia := 0

	SqlDiaSemanaRM(cEmpresa,cTurno)
	While TRE->(!EOF())    

		IF nIndiceTurno == VAL(SUBSTR(TRE->COLUNA,4,1))

			DO CASE
				CASE ALLTRIM(TRE->VALOR) == "Segunda-Feira" .OR.  ALLTRIM(TRE->VALOR) == "Monday"  
					nDia := 2
				CASE ALLTRIM(TRE->VALOR) == "Terça-Feira"   .OR.  ALLTRIM(TRE->VALOR) == "Tuesday"    
					nDia := 3
				CASE ALLTRIM(TRE->VALOR) == "Quarta-Feira"  .OR.  ALLTRIM(TRE->VALOR) == "Wednesday"  
					nDia := 4
				CASE ALLTRIM(TRE->VALOR) == "Quinta-Feira"  .OR.  ALLTRIM(TRE->VALOR) == "Thursday"  
					nDia := 5
				CASE ALLTRIM(TRE->VALOR) == "Sexta-Feira"   .OR.  ALLTRIM(TRE->VALOR) == "Friday"    
					nDia := 6
				CASE ALLTRIM(TRE->VALOR) == "Sábado"        .OR.  ALLTRIM(TRE->VALOR) == "Saturday"  
					nDia := 7
				CASE ALLTRIM(TRE->VALOR) == "Domingo"       .OR.  ALLTRIM(TRE->VALOR) == " Sunday"    
					nDia := 1				
				OTHERWISE
					nDia := 6
			ENDCASE    

	    ENDIF

		TRE->(dbSkip())
				
	ENDDO
	TRE->(dbCloseArea())	

Return(nDia)

STATIC FUNCTION EncontrardiaSemana(nDia)

	Local cDiaSemana := ''

	DO CASE
		CASE nDia == 1 
			cDiaSemana := "Domingo"
		CASE nDia == 2 
			cDiaSemana := "Segunda-Feira"
		CASE nDia == 3
			cDiaSemana := "Terça-Feira"
		CASE nDia == 4
			cDiaSemana := "Quarta-Feira"
		CASE nDia == 5
			cDiaSemana := "Quinta-Feira"
		CASE nDia == 6
			cDiaSemana := "Sexta-Feira"
		OTHERWISE
			cDiaSemana := "Sábado"
	ENDCASE    

Return(cDiaSemana)

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_HORA_PERFIL.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_HORA_PERFIL.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 

Static Function MontaPerg()    
                              
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    U_xPutSx1(cPerg,'01','Num Perfil Acesso de    ?','','','mv_ch1','C',06,0,0,'G',bValid,'',cSXG,cPyme,'MV_PAR01')
	U_xPutSx1(cPerg,'02','Num Perfil Acesso Ate   ?','','','mv_ch2','C',06,0,0,'G',bValid,'',cSXG,cPyme,'MV_PAR02')
	
	Pergunte(cPerg,.F.)

Return Nil            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"Empresa "               ,1,1) // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Empresa "          ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Perfil de Acesso " ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"Cod Horario Rm "        ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"Descrição "             ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"Ind Inicio "            ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"Hr Ini "                ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"Ind Final "             ,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"Hr Fin "                ,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"Trabalhando "           ,1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"Demitido "              ,1,1) // 11 K
	oExcel:AddColumn(cPlanilha,cTitulo,"Ausente "               ,1,1) // 12 L
	oExcel:AddColumn(cPlanilha,cTitulo,"Total "                 ,1,1) // 13 M
	
RETURN(NIL)   


STATIC FUNCTION BUSCAEMPRM(nColigada)

	Local cNome := ''

	SqlEmpresaRM(nColigada)
	While TRS->(!EOF())  

		cNome := ALLTRIM(TRS->NOMEFANTASIA)

		TRS->(dbSkip())
				
	ENDDO
	TRS->(dbCloseArea())	

Return(cNome)

Static Function SqlGeral()

	// @history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud

	/*
	
    BeginSQL Alias "TRB"
			%NoPARSER%
			 SELECT AJORHOR.CODCOLIGADA,
			        PERFIL_ACESSO.NM_PERFIL_ACESSO,
					CODHORARIO,
					DESCRICAO,
					INDINICIO,
					BATINICIO,
					CONVERT(DECIMAL(10,2),CONVERT(NUMERIC,BATINICIO) / 60) AS HR_INI,
					INDFIM,
					BATFIM,
					CONVERT(DECIMAL(10,2),CONVERT(NUMERIC,BATFIM) / 60) AS HR_FIN
				FROM [DIMEP].[DMPACESSOII].[DBO].[PERFIL_ACESSO]
				INNER JOIN [VPSRV16].[CORPORERM].[DBO].[AJORHOR] AS AJORHOR
						ON AJORHOR.CODCOLIGADA                      = SUBSTRING(NM_PERFIL_ACESSO,1,1) COLLATE Latin1_General_CI_AS
					   AND AJORHOR.CODHORARIO                       = SUBSTRING(NM_PERFIL_ACESSO,2,4) COLLATE Latin1_General_CI_AS
				INNER JOIN [VPSRV16].[CORPORERM].[DBO].[AHORARIO] AS AHORARIO
						ON AHORARIO.CODCOLIGADA                     = AJORHOR.CODCOLIGADA
					   AND AHORARIO.INATIVO                         = 0
					   AND AHORARIO.CODIGO                          = AJORHOR.CODHORARIO 
					 WHERE LEFT(PERFIL_ACESSO.NM_PERFIL_ACESSO, 2) <> '99'
					   AND PERFIL_ACESSO.NM_PERFIL_ACESSO          >= %EXP:MV_PAR01%
					   AND PERFIL_ACESSO.NM_PERFIL_ACESSO          <= %EXP:MV_PAR02%
								
				ORDER BY PERFIL_ACESSO.NM_PERFIL_ACESSO
	EndSQl

	*/

	TRB := GetNextAlias()

	//cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", '

	cQuery := "		 SELECT AJORHOR.CODCOLIGADA,
	cQuery += "		        PERFIL_ACESSO.NM_PERFIL_ACESSO,
	cQuery += "				CODHORARIO,
	cQuery += "				DESCRICAO,
	cQuery += "				INDINICIO,
	cQuery += "				BATINICIO,
	cQuery += "				CONVERT(DECIMAL(10,2),CONVERT(NUMERIC,BATINICIO) / 60) AS HR_INI,
	cQuery += "				INDFIM,
	cQuery += "				BATFIM,
	cQuery += "				CONVERT(DECIMAL(10,2),CONVERT(NUMERIC,BATFIM) / 60) AS HR_FIN
	cQuery += "			FROM [DIMEP].[DMPACESSOII].[DBO].[PERFIL_ACESSO]
	cQuery += "			INNER JOIN [" + cLinked + "].[" + cSGBD + "].[DBO].[AJORHOR] AS AJORHOR (NOLOCK)
	cQuery += "								ON AJORHOR.CODCOLIGADA                      = SUBSTRING(NM_PERFIL_ACESSO,1,1) COLLATE Latin1_General_CI_AS
	cQuery += "							   AND AJORHOR.CODHORARIO                       = SUBSTRING(NM_PERFIL_ACESSO,2,4) COLLATE Latin1_General_CI_AS
	cQuery += "						INNER JOIN [" + cLinked + "].[" + cSGBD + "].[DBO].[AHORARIO] AS AHORARIO (NOLOCK)
	cQuery += "								ON AHORARIO.CODCOLIGADA                     = AJORHOR.CODCOLIGADA
	cQuery += "							   AND AHORARIO.INATIVO                         = 0
	cQuery += "							   AND AHORARIO.CODIGO                          = AJORHOR.CODHORARIO 
	cQuery += "							 WHERE LEFT(PERFIL_ACESSO.NM_PERFIL_ACESSO, 2) <> '99'
	cQuery += "							   AND PERFIL_ACESSO.NM_PERFIL_ACESSO          >= '"+MV_PAR01+"'
	cQuery += "							   AND PERFIL_ACESSO.NM_PERFIL_ACESSO          <= '"+MV_PAR02+"'
								
	cQuery += "						ORDER BY PERFIL_ACESSO.NM_PERFIL_ACESSO

	//cQuery += " ')

	tcQuery cQuery New Alias TRB

	//

RETURN()

Static Function SqlPerfEsp()

	// @history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud

	/*
	
    BeginSQL Alias "TRC"
			%NoPARSER%
			 SELECT AJORHOR.CODCOLIGADA,
					PERFIL_ACESSO.NM_PERFIL_ACESSO,
					AJORHOR.CODHORARIO,
					DESCRICAO,
					INDINICIO,
					BATINICIO,
					CONVERT(DECIMAL(10,2),CONVERT(NUMERIC,BATINICIO) / 60) AS HR_INI,
					INDFIM,
					BATFIM,
					CONVERT(DECIMAL(10,2),CONVERT(NUMERIC,BATFIM) / 60) AS HR_FIN 
			   FROM [DIMEP].[DMPACESSOII].[DBO].[PERFIL_ACESSO] AS PERFIL_ACESSO
			   INNER JOIN [DIMEP].[DMPACESSOII].[DBO].[PESSOA] AS PESSOA
					   ON PESSOA.CD_PERFIL_ACESSO                  = PERFIL_ACESSO.CD_PERFIL_ACESSO
			   INNER JOIN [VPSRV16].[CORPORERM].[DBO].[PFUNC] 
				 	   ON PFUNC.PISPASEP = PESSOA.NU_PIS COLLATE Latin1_General_CI_AS
					  AND PFUNC.CODTIPO                           <> 'A'
					  AND PFUNC.CODSITUACAO                       <> 'D'
			   INNER JOIN [VPSRV16].[CORPORERM].[DBO].[AJORHOR]
					   ON AJORHOR.CODCOLIGADA                      = PFUNC.CODCOLIGADA
					  AND AJORHOR.CODHORARIO                       = PFUNC.CODHORARIO
			   INNER JOIN [VPSRV16].[CORPORERM].[DBO].[AHORARIO] AS AHORARIO
				   	   ON AHORARIO.CODCOLIGADA                     = AJORHOR.CODCOLIGADA
					  AND AHORARIO.INATIVO                         = 0
					  AND AHORARIO.CODIGO                          = AJORHOR.CODHORARIO 
					WHERE LEFT(PERFIL_ACESSO.NM_PERFIL_ACESSO, 2)  = '99'
					  AND PERFIL_ACESSO.NM_PERFIL_ACESSO          >= %EXP:MV_PAR01%
					  AND PERFIL_ACESSO.NM_PERFIL_ACESSO          <= %EXP:MV_PAR02%

			   GROUP BY AJORHOR.CODCOLIGADA,PERFIL_ACESSO.NM_PERFIL_ACESSO,AJORHOR.CODHORARIO,DESCRICAO,INDINICIO,BATINICIO,CONVERT(DECIMAL(10,2),CONVERT(NUMERIC,BATINICIO) / 60),INDFIM,BATFIM,CONVERT(DECIMAL(10,2),CONVERT(NUMERIC,BATFIM) / 60) 
							
			   ORDER BY PERFIL_ACESSO.NM_PERFIL_ACESSO
			 	
	EndSQl

	*/

	TRC := GetNextAlias()

	//cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", '

	cQuery := "		 SELECT AJORHOR.CODCOLIGADA,
	cQuery += "				PERFIL_ACESSO.NM_PERFIL_ACESSO,
	cQuery += "				AJORHOR.CODHORARIO,
	cQuery += "				DESCRICAO,
	cQuery += "				INDINICIO,
	cQuery += "				BATINICIO,
	cQuery += "				CONVERT(DECIMAL(10,2),CONVERT(NUMERIC,BATINICIO) / 60) AS HR_INI,
	cQuery += "				INDFIM,
	cQuery += "				BATFIM,
	cQuery += "				CONVERT(DECIMAL(10,2),CONVERT(NUMERIC,BATFIM) / 60) AS HR_FIN 
	cQuery += "		   FROM [DIMEP].[DMPACESSOII].[DBO].[PERFIL_ACESSO] AS PERFIL_ACESSO
	cQuery += "		   INNER JOIN [DIMEP].[DMPACESSOII].[DBO].[PESSOA] AS PESSOA
	cQuery += "				   ON PESSOA.CD_PERFIL_ACESSO                  = PERFIL_ACESSO.CD_PERFIL_ACESSO
	cQuery += "		   INNER JOIN [" + cLinked + "].[" + cSGBD + "].[DBO].[PFUNC] AS PFUNC (NOLOCK)
	cQuery += "			 	   ON PFUNC.PISPASEP = PESSOA.NU_PIS COLLATE Latin1_General_CI_AS
	cQuery += "				  AND PFUNC.CODTIPO                           <> 'A'
	cQuery += "				  AND PFUNC.CODSITUACAO                       <> 'D'
	cQuery += "		   INNER JOIN [" + cLinked + "].[" + cSGBD + "].[DBO].[AJORHOR] AS AJORHOR (NOLOCK)
	cQuery += "				   ON AJORHOR.CODCOLIGADA                      = PFUNC.CODCOLIGADA
	cQuery += "				  AND AJORHOR.CODHORARIO                       = PFUNC.CODHORARIO
	cQuery += "		   INNER JOIN [" + cLinked + "].[" + cSGBD + "].[DBO].[AHORARIO] AS AHORARIO (NOLOCK)
	cQuery += "			   	   ON AHORARIO.CODCOLIGADA                     = AJORHOR.CODCOLIGADA
	cQuery += "				  AND AHORARIO.INATIVO                         = 0
	cQuery += "				  AND AHORARIO.CODIGO                          = AJORHOR.CODHORARIO 
	cQuery += "				WHERE LEFT(PERFIL_ACESSO.NM_PERFIL_ACESSO, 2)  = '99'
	cQuery += "				  AND PERFIL_ACESSO.NM_PERFIL_ACESSO          >= '"+MV_PAR01+"'
	cQuery += "				  AND PERFIL_ACESSO.NM_PERFIL_ACESSO          <= '"+MV_PAR02+"'

	cQuery += "		   GROUP BY AJORHOR.CODCOLIGADA,PERFIL_ACESSO.NM_PERFIL_ACESSO,AJORHOR.CODHORARIO,DESCRICAO,INDINICIO,BATINICIO,CONVERT(DECIMAL(10,2),CONVERT(NUMERIC,BATINICIO) / 60),INDFIM,BATFIM,CONVERT(DECIMAL(10,2),CONVERT(NUMERIC,BATFIM) / 60) 
							
	cQuery += "		   ORDER BY PERFIL_ACESSO.NM_PERFIL_ACESSO

	//cQuery += " ')

	tcQuery cQuery New Alias TRC

	//

RETURN()

Static Function SqlQtdPessoa(cNomePerfil)
     
    BeginSQL Alias "TRD"
			%NoPARSER%
			SELECT NM_PERFIL_ACESSO,
			       CASE WHEN CD_SITUACAO_PESSOA = '11' THEN COUNT(*) ELSE 0 END AS 'TRABALHANDO',
			       CASE WHEN CD_SITUACAO_PESSOA = '12' THEN COUNT(*) ELSE 0 END AS 'DEMITIDO',
			       CASE WHEN CD_SITUACAO_PESSOA > '12' THEN COUNT(*) ELSE 0 END AS 'AUSENTE'
			  FROM [DIMEP].[DMPACESSOII].[DBO].[PERFIL_ACESSO]
			  INNER JOIN [DIMEP].[DMPACESSOII].[DBO].[PESSOA]
			          ON PESSOA.CD_PERFIL_ACESSO = PERFIL_ACESSO.CD_PERFIL_ACESSO
			       WHERE NM_PERFIL_ACESSO = %EXP:cNomePerfil%
			       
			GROUP BY NM_PERFIL_ACESSO, CD_SITUACAO_PESSOA  
			 	
	EndSQl
RETURN()        

Static Function SqlDiaSemanaRM(cEmpresa,cTurno)

	Local cTeste:= ''

	// @history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud
	
	/*

	cQuery:= " SELECT [COLUNA], [VALOR] "
	cQuery+= "   FROM (SELECT CODIGO, "
	cQuery+= "	   	  (SELECT DATENAME(weekday, DATABASEHOR)    FROM [VPSRV16].[CORPORERM].[DBO].[AHORARIO]  WHERE CODCOLIGADA = '" + cEmpresa + "' AND CODIGO = '" + cTurno + "') AS DIA1, "
	cQuery+= "	      (SELECT DATENAME(weekday, DATABASEHOR +1) FROM [VPSRV16].[CORPORERM].[DBO].[AHORARIO]  WHERE CODCOLIGADA = '" + cEmpresa + "' AND CODIGO = '" + cTurno + "') AS DIA2, "
	cQuery+= "	 	  (SELECT DATENAME(weekday, DATABASEHOR +2) FROM [VPSRV16].[CORPORERM].[DBO].[AHORARIO]  WHERE CODCOLIGADA = '" + cEmpresa + "' AND CODIGO = '" + cTurno + "') AS DIA3, "
	cQuery+= "		  (SELECT DATENAME(weekday, DATABASEHOR +3) FROM [VPSRV16].[CORPORERM].[DBO].[AHORARIO]  WHERE CODCOLIGADA = '" + cEmpresa + "' AND CODIGO = '" + cTurno + "') AS DIA4, "
	cQuery+= "		  (SELECT DATENAME(weekday, DATABASEHOR +4) FROM [VPSRV16].[CORPORERM].[DBO].[AHORARIO]  WHERE CODCOLIGADA = '" + cEmpresa + "' AND CODIGO = '" + cTurno + "') AS DIA5, "
	cQuery+= "		  (SELECT DATENAME(weekday, DATABASEHOR +5) FROM [VPSRV16].[CORPORERM].[DBO].[AHORARIO]  WHERE CODCOLIGADA = '" + cEmpresa + "' AND CODIGO = '" + cTurno + "') AS DIA6, "
	cQuery+= "		  (SELECT DATENAME(weekday, DATABASEHOR +6) FROM [VPSRV16].[CORPORERM].[DBO].[AHORARIO]  WHERE CODCOLIGADA = '" + cEmpresa + "' AND CODIGO = '" + cTurno + "') AS DIA7 "
	cQuery+= "   FROM [VPSRV16].[CORPORERM].[DBO].[AHORARIO] "
	cQuery+= "  WHERE CODCOLIGADA = '" + cEmpresa + "' "
	cQuery+= "	  AND CODIGO      = '" + cTurno + "' "
	cQuery+= "		  ) C "
	cQuery+= "	UNPIVOT ([VALOR] FOR [COLUNA] IN ( [DIA1], "
	cQuery+= "		                               [DIA2], "
	cQuery+= "				                       [DIA3], "
	cQuery+= "				                       [DIA4], "
	cQuery+= "				                       [DIA5], "
	cQuery+= "				                       [DIA6], "
	cQuery+= "				                       [DIA7] "
	cQuery+= "			) "
	cQuery+= " ) AS U " 

	*/

	TRE := GetNextAlias()

	cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", '

	cQuery+= " SELECT [COLUNA], [VALOR] "
	cQuery+= "   FROM (SELECT CODIGO, "
	cQuery+= "	   	  (SELECT DATENAME(weekday, DATABASEHOR)    FROM [" + cSGBD + "].[DBO].[AHORARIO] AS AHORARIO (NOLOCK) WHERE CODCOLIGADA = ''" + cEmpresa + "'' AND CODIGO = ''" + cTurno + "'') AS DIA1, "
	cQuery+= "	      (SELECT DATENAME(weekday, DATABASEHOR +1) FROM [" + cSGBD + "].[DBO].[AHORARIO] AS AHORARIO (NOLOCK) WHERE CODCOLIGADA = ''" + cEmpresa + "'' AND CODIGO = ''" + cTurno + "'') AS DIA2, "
	cQuery+= "	 	  (SELECT DATENAME(weekday, DATABASEHOR +2) FROM [" + cSGBD + "].[DBO].[AHORARIO] AS AHORARIO (NOLOCK) WHERE CODCOLIGADA = ''" + cEmpresa + "'' AND CODIGO = ''" + cTurno + "'') AS DIA3, "
	cQuery+= "		  (SELECT DATENAME(weekday, DATABASEHOR +3) FROM [" + cSGBD + "].[DBO].[AHORARIO] AS AHORARIO (NOLOCK) WHERE CODCOLIGADA = ''" + cEmpresa + "'' AND CODIGO = ''" + cTurno + "'') AS DIA4, "
	cQuery+= "		  (SELECT DATENAME(weekday, DATABASEHOR +4) FROM [" + cSGBD + "].[DBO].[AHORARIO] AS AHORARIO (NOLOCK) WHERE CODCOLIGADA = ''" + cEmpresa + "'' AND CODIGO = ''" + cTurno + "'') AS DIA5, "
	cQuery+= "		  (SELECT DATENAME(weekday, DATABASEHOR +5) FROM [" + cSGBD + "].[DBO].[AHORARIO] AS AHORARIO (NOLOCK) WHERE CODCOLIGADA = ''" + cEmpresa + "'' AND CODIGO = ''" + cTurno + "'') AS DIA6, "
	cQuery+= "		  (SELECT DATENAME(weekday, DATABASEHOR +6) FROM [" + cSGBD + "].[DBO].[AHORARIO] AS AHORARIO (NOLOCK) WHERE CODCOLIGADA = ''" + cEmpresa + "'' AND CODIGO = ''" + cTurno + "'') AS DIA7 "
	cQuery+= "   FROM [" + cSGBD + "].[DBO].[AHORARIO] AS AHORARIO (NOLOCK) "
	cQuery+= "  WHERE CODCOLIGADA = ''" + cEmpresa + "'' "
	cQuery+= "	  AND CODIGO      = ''" + cTurno + "'' "
	cQuery+= "		  ) C "
	cQuery+= "	UNPIVOT ([VALOR] FOR [COLUNA] IN ( [DIA1], "
	cQuery+= "		                               [DIA2], "
	cQuery+= "				                       [DIA3], "
	cQuery+= "				                       [DIA4], "
	cQuery+= "				                       [DIA5], "
	cQuery+= "				                       [DIA6], "
	cQuery+= "				                       [DIA7] "
	cQuery+= "			) "
	cQuery+= " ) AS U " 

	cQuery += " ')

	TCQUERY cQuery new alias TRE

RETURN(NIL) 

Static Function SqlEmpresaRM(cColigada)
     
	// @history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud
	
	/*
 
    BeginSQL Alias "TRS"
			%NoPARSER%
			SELECT NOMEFANTASIA 
			  FROM [VPSRV16].[CORPORERM].[DBO].[GCOLIGADA]
			 WHERE CODCOLIGADA = %EXP:cColigada%
			 	
	EndSQl

	*/

	TRS := GetNextAlias()

	cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", '

	cQuery += "		SELECT NOMEFANTASIA 
	cQuery += "		  FROM [" + cSGBD + "].[DBO].[GCOLIGADA] (NOLOCK)
	cQuery += "		 WHERE CODCOLIGADA = ''"+AllTrim(Str(cColigada))+"''

	cQuery += " ')

	tcQuery cQuery New Alias TRS
	//

RETURN()  
