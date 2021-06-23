#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"  

/*{Protheus.doc} User Function ADGPE040R
	Relatorio para acompanhamento de tempo de permanencia do dimep de terceiro no refeitorio. Relatorio em Excel. 
	@type  Function
	@author William Costa
	@since 23/01/2019
	@version 01
	@history Chamado TI  - William Costa - 24/09/2019 - ajustado query para nao trazer terceiro
	@history TICKET  224 - William Costa - 11/11/2020 - Alteração do Fonte na parte de Funcionários, trocar a integração do Protheus para a Integração do RM
	@history ticket  14365  - Fernando Macieir- 19/05/2021 - Novo Linked Server (de VPSRV17 para DIMEP)
*/
 
User Function ADGPE040R()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio para acompanhamento de tempo de permanencia do dimep de terceiro no refeitorio. Relatorio em Excel. ')
	
	//Define Variaveis                                             
	
	PRIVATE aSays		:={}
	PRIVATE aButtons	:={}   
	PRIVATE cCadastro	:= "Relatorio Tempo de Permanência de Funcionários Dimep"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	PRIVATE nOpca		:= 0
	PRIVATE cPerg		:= 'ADGPE040R'
	
	//Cria grupo de Perguntas                         
	
	MontaPerg()
	 
	//Monta Form Batch - Interface com o Usuario     
	
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio Tempo de Permanência de Funcionários Dimep" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||GPE040R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  

Static Function GPE040R()    

	PRIVATE oExcel     := FWMSEXCEL():New()
	PRIVATE cPath      := ''
	PRIVATE cArquivo   := 'REL_TERC_REFEITORIO.XML'
	PRIVATE oMsExcel
	PRIVATE cPlanilha  := DTOC(MV_PAR03) + ' ate ' + DTOC(MV_PAR04)
    PRIVATE cTitulo    := "Relatorio Terceiro - " + DTOC(MV_PAR03) + ' ate ' + DTOC(MV_PAR04)
    PRIVATE aLinhas    := {}
   
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
	Private dData      := ''
	Private cData      := ''
	Private nMatricula := ''
	
	SqlGeral() 
	
	DBSELECTAREA("TRC")
	TRC->(DBGOTOP())
	WHILE TRC->(!EOF()) 
	
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
	   	               ""  ; // 10 J
	   	                   })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
		
		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
		aLinhas[nLinha][01] := TRC->CD_LOG_ACESSO                                                                    //A
		aLinhas[nLinha][02] := TRC->NU_CREDENCIAL                                                                    //B
		aLinhas[nLinha][03] := TRC->MAT                                                                              //C
		aLinhas[nLinha][04] := TRC->NM_PESSOA                                                                              //D
		aLinhas[nLinha][05] := TRC->DT_REQUISICAO                                                                    //E
		aLinhas[nLinha][06] := SUBSTR(STRZERO(VAL(TRC->HORA),4),1,2) + ':' +  SUBSTR(STRZERO(VAL(TRC->HORA),4),3,2) //F
		aLinhas[nLinha][07] := TRC->NU_ESTRUTURA                                                                     //G
		aLinhas[nLinha][08] := TRC->NM_ESTRUTURA                                                                     //H
		aLinhas[nLinha][09] := TRC->DS_EQUIPAMENTO                                                                   //I
		aLinhas[nLinha][10] := TRC->TP_SENTIDO_CONSULTA                                                              //J
		
		//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				
		TRC->(dbSkip())    
	
	ENDDO //end do while TRB
	TRC->( DBCLOSEAREA() )
			
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
   	                	                 aLinhas[nExcel][10] ; // 10 J
   	                	                                      }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS				
   NEXT 
   //============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_TERC_REFEITORIO.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_TERC_REFEITORIO.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return()       

Static Function MontaPerg() 
                                 
	Private bValid	:= Nil 
	Private cF3		:= Nil
	Private cSXG	:= Nil
	Private cPyme	:= Nil
	
    U_xPutSx1(cPerg,'01','Terceiro de  ?','','','mv_ch1','C',18,0,0,'G',bValid,"SRA",cSXG,cPyme,'MV_PAR01')
	U_xPutSx1(cPerg,'02','Terceiro Ate ?','','','mv_ch2','C',18,0,0,'G',bValid,"SRA",cSXG,cPyme,'MV_PAR02')
	U_xPutSx1(cPerg,'03','Data De      ?','','','mv_ch3','D',08,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR03')
	U_xPutSx1(cPerg,'04','Data Ate     ?','','','mv_ch4','D',08,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR04')
	Pergunte(cPerg,.F.)
	
Return Nil            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)                                    
	oExcel:AddColumn(cPlanilha,cTitulo,"Cod Acesso Entrada "    ,1,1) // 01 A
    oExcel:AddColumn(cPlanilha,cTitulo,"Num Credencial"         ,1,1) // 02 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Matricula "             ,1,1) // 03 C    
    oExcel:AddColumn(cPlanilha,cTitulo,"Nome "                  ,1,1) // 04 D
    oExcel:AddColumn(cPlanilha,cTitulo,"Data "                  ,1,1) // 05 E
    oExcel:AddColumn(cPlanilha,cTitulo,"Hora "                  ,1,1) // 06 F
  	oExcel:AddColumn(cPlanilha,cTitulo,"Codigo Estrutura "      ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Estrutura "        ,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"Descricão Equipamento " ,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"Sentido "               ,1,1) // 10 J
			
RETURN(NIL)

Static Function SqlGeral() 

	Local nFil     := 0   
	Local cDtIni   := ''
	Local cDtFin   := ''                                    
	Local cQuery   := ''
	
	IF CEMPANT == '01' .AND. xFilial("SRA") == '02'
	
		nFil := 9 //Emresa Adoro codigo da filial de Varzea no Dimep
		
	ELSEIF CEMPANT == '02' .AND. xFilial("SRA") == '01'	
	
		nFil := 17 //Empresa Ceres codigo da filial de Varzea	
	
	ENDIF	

	cDtIni   := DTOS(MV_PAR03)
	cDtFin   := DTOS(MV_PAR04)
	
	cQuery := "SELECT CONVERT(CHAR,NU_MATRICULA) AS MAT, "
	cQuery += "       CONVERT(CHAR,NU_HORA_REQUISICAO) AS HORA,  "
	cQuery += "       *  "
	cQuery += "  FROM [DIMEP].[DMPACESSOII].[DBO].[LOG_ACESSO] AS LOG_ACESSO  "
	cQuery += " INNER JOIN [DIMEP].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL]  "
	cQuery += "         ON CD_ESTRUTURA_ORGANIZACIONAL  = CD_ESTRUTURA  "
	cQuery += "        AND CD_ESTRUTURA_RELACIONADA     = 1223 " // Para trazer só os terceiros
	cQuery += "      WHERE NU_DATA_REQUISICAO          >= '" + cDtIni   + "' "
	cQuery += "        AND NU_DATA_REQUISICAO          <= '" + cDtFin   + "' "
	cQuery += "        AND NU_MATRICULA                >= '" + MV_PAR01 + "' "
	cQuery += "        AND NU_MATRICULA                <= '" + MV_PAR02 + "' "
	cQuery += "        AND CD_VISITANTE                IS NULL "   
	cQuery += "        AND TP_SENTIDO_CONSULTA          = 1 " //ENTRADA
	cQuery += "        AND (CD_EQUIPAMENTO              = 1 "   //Catraca Refeitorio 1
	cQuery += "         OR CD_EQUIPAMENTO               = 2)  " //Catraca Refeitorio 2
	cQuery += "        AND (TP_EVENTO                   = '27'  " // Acesso Master
	cQuery += "         OR TP_EVENTO                    = '10'  " // Acesso Concluido
	cQuery += "         OR TP_EVENTO                    = '12'  " // Acesso Batch
	cQuery += "         OR TP_EVENTO                    = '23') " // Autorização excepcional
	cQuery += "   ORDER BY CD_LOG_ACESSO   " 
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRC",.F.,.T.)
	
RETURN()
