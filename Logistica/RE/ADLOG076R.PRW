#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

/*/{Protheus.doc} User Function ADLOG076R
    Relatório de CTe averbadas.
    Chamado 11607
    @type  Function
    @author Leonardo P. Monteiro
    @since 30/04/2021
    @version 01
    @history Chamado 11607 - Leonardo P. Monteiro - 30/04/2021 - Extração das CTe averbadas.
/*/

User Function ADLOG076R()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'RELATORIO LOGISTICA - Controle de Devolucoes')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:= {}
	Private aButtons	:= {}   
	Private cCadastro	:= "Relatório de CTe Averbadas"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	Private nOpca		:= 0
	Private cPerg		:= 'ADLOG076R'
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 Pergunte(cPerg,.F.)
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Relação de Cte Averbadas..." )
	
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||GERA_ADLOG076R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         

Static Function GERA_ADLOG076R()    
	Public oExcel      := FWMSEXCEL():New()
	Public cPath       := 'D:\Totvs\Protheus11\protheus_data\system\'
	Public cArquivo    := 'ADLOG076R.XML'
	Public oMsExcel    := NIL
	Public cPlanilha   := 'Relação de CTe Averbadas'
    Public cTitulo     := 'Relação de CTe Averbadas'
    Public cCodProdSql := ''
    Public aLinhas     := {}
   
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

    Private nLinha 	:= 0
	Private nExcel 	:= 0
	
    SqlGeral() 
	
	DBSELECTAREA("TRB")
		TRB->(DBGOTOP())
		
		WHILE TRB->(!EOF()) 
		
			nLinha  := nLinha + 1                                       

			AADD(aLinhas, {;
				STOD(TRB->ZFK_DTENTR),;
				TRB->ZFK_ROTEIR,;
				TRB->ZFK_TPDOC,;
				TRB->ZFK_NOTA,;
				TRB->ZFK_SERIE,;
				TRB->ZFK_MSGAVE,;
				TRB->ZFK_TPAVER ,;
				TRB->ZFK_PRTAVE,;
				TRB->ZFK_HASH;
			})
            	
			
			TRB->(dbSkip())    
		
		ENDDO //end do while TRB
		TRB->( DBCLOSEAREA() )
		
		//============================== INICIO IMPRIME LINHA NO EXCEL
		FOR nExcel := 1 TO nLinha
	   		oExcel:AddRow(cPlanilha,cTitulo, aLinhas[nExcel]) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS				
        NEXT nExcel
	    //============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SqlGeral()

	Local cDtDe		:= Dtos(MV_PAR01)
	Local cDtAte	:= Dtos(MV_PAR02)
	Local cRotDe	:= MV_PAR03
	Local cRotAte	:= MV_PAR04
	Local cEOL		:= Chr(13)+Chr(10)
    
	cQuery	:= " SELECT ZFK_TRANSP, ZFK_LOJA, ZFK_NMTRAN, ZFK_CARGA, ZFK_DTENTR, " +cEOL
	cQuery	+= " 	    ZFK_ROTEIR, ZFK_SEQENV, ZFK_TPDOC, ZFK_NUMDOC, ZFK_SERDOC, "+cEOL
	cQuery	+= "		ZFK_STATUS, ZFK_HASH, ZFK_DATA, ZFK_PLACA, ZFK_OPHOS, ZFK_CHAVE,"+cEOL 
	cQuery	+= "		ZFK_PROTEM, ZFK_PROTCA, ZFK_REBOQU, ZFK_PROENC, ZFK_PEDCOM, ZFK_NOTA,"+cEOL 
	cQuery	+= "		ZFK_SERIE,  ZFK_PRTAVE, ZFK_MSGAVE, ZFK_STAAVE, ZFK_TPDAVE,ZFK_TPAVER"+cEOL 
	cQuery	+= " FROM  "+ RetSqlName("ZFK") +" (NOLOCK) AS ZFK  "+cEOL 
	cQuery	+= " WHERE  ZFK_FILIAL = '02'  AND ZFK_TPCARG = '1'  AND ZFK_STAAVE <> ''  AND ZFK_TPDOC = '1'  AND ZFK.D_E_L_E_T_ = '' "+cEOL
	cQuery	+= "		AND ZFK_DTENTR BETWEEN '"+ cDtDe +"' AND '"+ cDtAte +"' AND ZFK_ROTEIR BETWEEN '"+ cRotDe +"' AND '"+ cRotAte +"' "+cEOL   
	cQuery	+= " ORDER BY ZFK_DTENTR, ZFK_TRANSP, ZFK_LOJA, ZFK_PLACA, ZFK_NOTA, ZFK_SERIE; "
    
    TcQuery cQuery ALIAS "TRB" NEW

RETURN()    

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\ADLOG076R.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\ADLOG076R.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return()       
         
                                
Static Function Cabec() 
	
    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    	
	oExcel:AddColumn(cPlanilha,cTitulo,"Dt. Entrega"			,1,4) // 01 A
    oExcel:AddColumn(cPlanilha,cTitulo,"Roteiro"        		,1,1) // 02 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Tipo Doc"        		,1,1) // 03 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Nota Fiscal"    		,1,1) // 03 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Serie"    				,1,1) // 04 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Mensagem"        		,1,1) // 05 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Num Averbação"        	,1,1) // 06 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Prot Averbação"        	,1,1) // 07 B
    oExcel:AddColumn(cPlanilha,cTitulo,"hash CT-e"        		,1,1) // 08 B
    
RETURN(NIL)
