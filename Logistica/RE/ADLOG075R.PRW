#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

/*/{Protheus.doc} User Function ADLOG074R
    Relatório derivado do ADLOG005R para adição de custo na devolução.
    Chamado 11355
    @type  Function
    @author Leonardo P. Monteiro
    @since 01/04/2021
    @version 01
    @history Chamado 11355 - Leonardo P. Monteiro - 01/04/2021 - Desenvolvimento e adição do campo de custo.
	@history Chamado 13429 - Leonardo P. Monteiro - 05/05/2021 - Adicionado campo transportadora.
	@history Chamado 13949 - Denis Guedes Adicionado o campo tipo de frete (ZK_TPFRETE)
/*/

User Function ADLOG075R() 
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'RELATORIO LOGISTICA - Controle de Devolucoes')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:= {}
	Private aButtons	:= {}   
	Private cCadastro	:= "Relatorio de PVs x CFe x PCs"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	Private nOpca		:= 0
	Private cPerg		:= 'ADLOG075R'
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 Pergunte(cPerg,.F.)
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este Relatorio de controle de PVs x CFe x PCs " )
	
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||GERA_ADLOG075R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         

Static Function GERA_ADLOG075R()    
	Public oExcel      := FWMSEXCEL():New()
	Public cPath       := 'D:\Totvs\Protheus11\protheus_data\system\'
	Public cArquivo    := 'ADLOG075R.XML'
	Public oMsExcel    := NIL
	Public cPlanilha   := 'Controle PVsxCFexPCs'
    Public cTitulo     := 'Controle PVsxCFexPCs'
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
	
	//@history Chamado 13429 - Leonardo P. Monteiro - 05/05/2021 - Adicionado campo transportadora.
	DBSELECTAREA("TRB")
		TRB->(DBGOTOP())
		
		WHILE TRB->(!EOF()) 
		
			nLinha  := nLinha + 1                                       
			
			AADD(aLinhas, {;
				TRB->C5_FILIAL,;
				TRB->C5_NUM,;
				TRB->C7_XNFECTE,;
				TRB->C7_NUM,;
				TRB->C5_TIPO,;
				TRB->C5_LOJAENT,;
				TRB->C5_CLIENTE,;
				TRB->C5_LOJACLI,;
				TRB->C5_PRIOR,;
				TRB->C5_NOMECLI,;
				TRB->C5_EST,;
				TRB->C5_ENDERE,;
				TRB->C5_BAIRRO,;
				TRB->C5_CIDADE,;
				TRB->C5_ROTEIRO,;
				TRB->C5_SEQUENC,;
				TRB->C5_PBRUTO,;
				TRB->C5_CONDPAG,;
				stod(TRB->C5_DTENTR),;
				stod(TRB->C5_DATA1),;
				TRB->C5_TRANSP,;
				TRB->A4_NOME,;
				TRB->C5_PLACA,;
				TRB->C5_UFPLACA,;
				TRB->C5_PESOL,;
				TRB->C5_TIPLIB,;
				TRB->C5_VEND1,;
				TRB->C5_TABELA,;
				TRB->C5_TIPOCLI,;
				TRB->C5_TPFRETE,;
				TRB->C5_VOLUME1,;
				TRB->C5_MENNOTA,;
				TRB->C5_NOTA,;
				TRB->C5_SERIE,;
				TRB->C5_SHELFLF,;
				TRB->C5_PALLETZ,;
				TRB->C5_X_SQED,;
				TRB->C5_X_DATA,;
				TRB->C5_XRAVEX,;
				TRB->C5_XHRENTR,;
				TRB->C5_HRINIT,;
				TRB->C5_HRFINT,;
				TRB->C5_HRINIM,;
				TRB->C5_HRFINM,;
				TRB->C5_MSBLQL,;
				TRB->C5_XNIDROT,;
				TRB->C5_XLATITU,;
				TRB->C5_XLONGIT,;
				TRB->ZK_TPFRETE;
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

	Local cFilDe	:= MV_PAR01
	Local cFilAte	:= MV_PAR02
	Local cNumDe	:= MV_PAR03
	Local cNumAte	:= MV_PAR04
	Local cEntDe  	:= DTOS(MV_PAR05)
    Local cEntAte  	:= DTOS(MV_PAR06)
	Local cEOL		:= Chr(13)+Chr(10)
    
	cQuery := " SELECT "+cEOL
	cQuery += " C5.C5_FILIAL, "+cEOL
	cQuery += " C5.C5_NUM, "+cEOL
	cQuery += " C7.C7_XNFECTE, "+cEOL
	cQuery += " C7.C7_NUM, "+cEOL
	cQuery += " C5.C5_TIPO, "+cEOL
	cQuery += " C5.C5_LOJAENT, "+cEOL
	cQuery += " C5.C5_CLIENTE, "+cEOL
	cQuery += " C5.C5_LOJACLI, "+cEOL
	cQuery += " C5.C5_PRIOR, "+cEOL
	cQuery += " C5.C5_NOMECLI, "+cEOL
	cQuery += " C5.C5_EST, "+cEOL
	cQuery += " C5.C5_ENDERE, "+cEOL
	cQuery += " C5.C5_BAIRRO, "+cEOL
	cQuery += " C5.C5_CIDADE, "+cEOL
	cQuery += " C5.C5_ROTEIRO, "+cEOL
	cQuery += " C5.C5_SEQUENC, "+cEOL
	cQuery += " C5.C5_PBRUTO, "+cEOL
	cQuery += " C5.C5_CONDPAG, "+cEOL
	cQuery += " C5.C5_DTENTR, "+cEOL
	cQuery += " C5.C5_DATA1, "+cEOL
	cQuery += " C5.C5_TRANSP, "+cEOL
	//@history Chamado 13429 - Leonardo P. Monteiro - 05/05/2021 - Adicionado campo transportadora.
	cQuery += " A4.A4_NOME, "+cEOL
	cQuery += " C5.C5_PLACA, "+cEOL
	cQuery += " C5.C5_UFPLACA, "+cEOL
	cQuery += " C5.C5_PESOL, "+cEOL
	cQuery += " C5.C5_TIPLIB, "+cEOL
	cQuery += " C5.C5_VEND1, "+cEOL
	cQuery += " C5.C5_TABELA, "+cEOL
	cQuery += " C5.C5_TIPOCLI, "+cEOL
	cQuery += " C5.C5_TPFRETE, "+cEOL
	cQuery += " C5.C5_VOLUME1, "+cEOL
	cQuery += " C5.C5_MENNOTA, "+cEOL
	cQuery += " C5.C5_NOTA, "+cEOL
	cQuery += " C5.C5_SERIE, "+cEOL
	cQuery += " C5.C5_SHELFLF, "+cEOL
	cQuery += " C5.C5_PALLETZ, "+cEOL
	cQuery += " C5.C5_X_SQED, "+cEOL
	cQuery += " C5.C5_X_DATA, "+cEOL
	cQuery += " C5.C5_XHRENTR, "+cEOL
	cQuery += " C5.C5_HRINIT, "+cEOL
	cQuery += " C5.C5_HRFINT, "+cEOL
	cQuery += " C5.C5_HRINIM, "+cEOL
	cQuery += " C5.C5_HRFINM, "+cEOL
	cQuery += " C5.C5_MSBLQL, "+cEOL
	cQuery += " C5.C5_XNIDROT, "+cEOL
	cQuery += " ZK.ZK_TPFRETE, "+cEOL
	

	if cEmpAnt == "02"
		cQuery += " '' C5_XRAVEX, "+cEOL
		cQuery += " '' C5_XLATITU, "+cEOL
		cQuery += " '' C5_XLONGIT  "+cEOL
	else
		cQuery += " C5.C5_XRAVEX, "+cEOL
		cQuery += " CASE WHEN C5.C5_TIPO IN ('D','B') THEN '0' ELSE A1.A1_XLATITU END C5_XLATITU, "+cEOL
		cQuery += " CASE WHEN C5.C5_TIPO IN ('D','B') THEN '0' ELSE A1.A1_XLONGIT END C5_XLONGIT  "+cEOL
	endif

	
	cQuery += "			  FROM "+ RetSqlName("SC5") +" (NOLOCK) C5 "+cEOL
	cQuery += "			  LEFT JOIN "+ RetSqlName("SC7") +" (NOLOCK) C7 ON C7.D_E_L_E_T_='' AND C5.D_E_L_E_T_='' AND C7.C7_FILIAL=C5.C5_FILIAL AND C7.C7_XDOCFAT=C5.C5_NOTA AND C7.C7_XDOCFAT !='' "+cEOL
	cQuery += "			  LEFT JOIN "+ RetSqlName("SA1") +" (NOLOCK) A1 ON A1.D_E_L_E_T_='' AND C5.D_E_L_E_T_='' AND C5.C5_TIPO NOT IN ('D','B') AND A1.A1_COD=C5.C5_CLIENTE AND A1.A1_LOJA=C5.C5_LOJACLI "+cEOL
	cQuery += "			  LEFT JOIN "+ RetSqlName("SA2") +" (NOLOCK) A2 ON A2.D_E_L_E_T_='' AND C5.D_E_L_E_T_='' AND C5.C5_TIPO IN ('D','B') AND A2.A2_COD=C5.C5_CLIENTE AND A2.A2_LOJA=C5.C5_LOJACLI "+cEOL
	cQuery += "			  LEFT JOIN "+ RetSqlName("SA4") +" (NOLOCK) A4 ON A4.D_E_L_E_T_='' AND C5.C5_TRANSP=A4.A4_COD "+cEOL
	cQuery += "			  LEFT JOIN "+ RetSqlName("SZK") +" (NOLOCK) ZK ON ZK.D_E_L_E_T_='' AND C5.C5_ROTEIRO=ZK.ZK_ROTEIRO AND C5.C5_PLACA=ZK.ZK_PLACA AND C5_DTENTR = ZK.ZK_DTENTR"+cEOL 
	cQuery += "			 WHERE C5.D_E_L_E_T_='' "+cEOL
	cQuery += "			 	AND C5.C5_FILIAL BETWEEN '"+cFilDe+"' AND '"+ cFilAte +"' "+cEOL
	cQuery += "			 	AND C5.C5_NUM BETWEEN '"+cNumDe+"' AND '"+ cNumAte +"' "+cEOL
	cQuery += "			 	AND C5.C5_DTENTR BETWEEN '"+cEntDe+"' AND '"+ cEntAte +"' "+cEOL
	cQuery += "			ORDER BY C5.C5_FILIAL, C5.C5_NUM;		   "
    
    TcQuery cQuery ALIAS "TRB" NEW

RETURN()    

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\ADLOG075R.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\ADLOG075R.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return()       
         
                                
Static Function Cabec() 
	
    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    	
	oExcel:AddColumn(cPlanilha,cTitulo,"Filial"   					,1,1) // 01 A
    oExcel:AddColumn(cPlanilha,cTitulo,"Numero"        				,1,1) // 02 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Num CTe"        			,1,1) // 03 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Pedido Compra"    			,1,1) // 03 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Tipo Pedido"        		,1,1) // 04 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Loja Entrega"        		,1,1) // 05 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Cliente"        			,1,1) // 06 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Loja"        				,1,1) // 07 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Prioridade"        			,1,1) // 08 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Nome Cliente"        		,1,1) // 09 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Estado"        				,1,1) // 10 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Endereco"        			,1,1) // 11 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Bairro"        				,1,1) // 12 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Cidade"        				,1,1) // 13 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Roteiro"        			,1,1) // 14 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Sequencia"        			,1,1) // 15 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Peso Bruto"        			,1,1) // 16 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Cond. Pagto"        		,1,1) // 17 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Data Entrega"        		,1,1) // 18 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Vencimento 1"        		,1,1) // 19 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Cod Transp."       			,1,1) // 20 B
	//@history Chamado 13429 - Leonardo P. Monteiro - 05/05/2021 - Adicionado campo transportadora.
	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Transp."      			,1,1) // 21 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Placa"        				,1,1) // 22 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Estado Placa"        		,1,1) // 23 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Peso Liquido"        		,1,1) // 24 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Tp Liberção"        		,1,1) // 25 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Vendedor 1"        			,1,1) // 26 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Tabela"        				,1,1) // 27 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Tipo Cliente"        		,1,1) // 28 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Tipo Frete"        			,1,1) // 29 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Volume 1"        			,1,1) // 30 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Mens.p/ Nota"        		,1,1) // 31 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Nota Fiscal"        		,1,1) // 32 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Serie"        				,1,1) // 33 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Shelflife?"        			,1,1) // 34 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Palletizado?"        		,1,1) // 35 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Carga Edata"        		,1,1) // 36 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Dt.Edata"        			,1,1) // 37 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Intreg Ravex"        		,1,1) // 38 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Hr Logistica"        		,1,1) // 39 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Hora Ini Tar"        		,1,1) // 40 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Hora Fin Tar"        		,1,1) // 41 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Hora Ini Man"        		,1,1) // 42 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Hora Fin Man"        		,1,1) // 43 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Status"        				,1,1) // 44 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Id Rot Ravex"        		,1,1) // 45 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Latitude Ent"        		,1,1) // 46 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Longitude En"        		,1,1) // 47 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Tipo de frete"        		,1,1) // 47 B
    
					
RETURN(NIL)
