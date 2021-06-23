#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

/*/{Protheus.doc} User Function ADEST065R
    Relatório comparativo entre Saldo em Estoque (SB2) e saldo por endereço (SBF).
    Chamado 13552
    @type  Function
    @author Leonardo P. Monteiro
    @since 07/05/2021
    @version 01
    @history Chamado 13552 - Leonardo P. Monteiro - 07/05/2021 - Comparativo entre o saldo em estoque (SB2) e saldos por endereço (SBF).
/*/

User Function ADEST065R()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'RELATORIO LOGISTICA - Controle de Devolucoes')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:= {}
	Private aButtons	:= {}   
	Private cCadastro	:= "Relatório Saldo Estoque x Saldo Localização"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	Private nOpca		:= 0
	Private cPerg		:= 'ADEST065R'
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 Pergunte(cPerg,.F.)
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Relação de produtos por saldo em estoque x saldo endereçado..." )
	
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||GERA_ADEST065R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         

Static Function GERA_ADEST065R()    
	Public oExcel      := FWMSEXCEL():New()
	Public cPath       := 'D:\Totvs\Protheus11\protheus_data\system\'
	Public cArquivo    := 'ADEST065R.XML'
	Public oMsExcel    := NIL
	Public cPlanilha   := 'Relação Saldo Estoque x Saldo Localização'
    Public cTitulo     := 'Relação Saldo Estoque x Saldo Localização'
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
            // B2.B2_FILIAL, B2.B2_COD, B1.B1_DESC, B1.B1_TIPO, B2.B2_LOCAL, B2.B2_QATU, SBF_SALDO	
			AADD(aLinhas, {;
				TRB->B2_FILIAL,;
				TRB->B2_COD,;
				TRB->B1_DESC,;
				TRB->B1_TIPO,;
				TRB->B2_LOCAL,;
				TRANSFORM(TRB->B2_QATU, "@E 999,999,999.9999"),;
				TRANSFORM(TRB->SBF_SALDO, "@E 999,999,999.9999");
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
	Local cPrdDe	:= MV_PAR03
	Local cPrdAte	:= MV_PAR04
	Local cArmDe	:= MV_PAR05
	Local cArmAte	:= MV_PAR06
    Local nSomDif	:= MV_PAR07
    Local nSldEst	:= MV_PAR08
    Local cEOL		:= Chr(13)+Chr(10)
    
    cQuery := " SELECT B2.B2_FILIAL, B2.B2_COD, B1.B1_DESC, B1.B1_TIPO, B1.B1_LOCALIZ, B2.B2_LOCAL, B2.B2_QATU, isnull(BF.BF_QUANT, 0) SBF_SALDO "
    cQuery += " FROM SB2010 (NOLOCK) B2	INNER JOIN SB1010 (NOLOCK) B1 ON B1.D_E_L_E_T_='' AND B1.B1_COD=B2.B2_COD "
	cQuery += " 					LEFT  JOIN (SELECT BF_FILIAL, BF_PRODUTO, BF_LOCAL, SUM(BF_QUANT) BF_QUANT "
	cQuery += " 								FROM SBF010 (NOLOCK) "
	cQuery += " 								WHERE D_E_L_E_T_='' "
	cQuery += " 								GROUP BY BF_FILIAL, BF_PRODUTO, BF_LOCAL) BF ON B2.D_E_L_E_T_='' AND BF.BF_FILIAL=B2.B2_FILIAL AND BF.BF_PRODUTO=B2.B2_COD AND BF.BF_LOCAL=B2.B2_LOCAL "
    cQuery += " WHERE B2.D_E_L_E_T_='' AND B1.B1_TIPO NOT IN ('MP','PA') AND B1.B1_LOCALIZ='S' AND B2.B2_QATU !=0 "
    cQuery += "     AND B2.B2_FILIAL BETWEEN '"+ cFilDe +"' AND '"+ cFilAte +"' "
    cQuery += "     AND B2.B2_COD    BETWEEN '"+ cPrdDe +"' AND '"+ cPrdAte +"' "
    cQuery += "     AND B2.B2_LOCAL  BETWEEN '"+ cArmDe +"' AND '"+ cArmAte +"' "
    
    if nSomDif == 1
        cQuery += "     AND ABS(B2.B2_QATU-ISNULL(BF.BF_QUANT,0)) > 0.01 "
    endif

    if nSldEst == 1
        cQuery += "     AND (B2.B2_QATU != 0 OR BF.BF_QUANT != 0 ) "
    endif

    cQuery += " ORDER BY B2.B2_FILIAL, B2.B2_COD; "
    
    TcQuery cQuery ALIAS "TRB" NEW

RETURN()    

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\ADEST065R.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\ADEST065R.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return()       
         
                                
Static Function Cabec() 
	
    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    // B2.B2_FILIAL, B2.B2_COD, B1.B1_DESC, B1.B1_TIPO, B2.B2_LOCAL, B2.B2_QATU, SBF_SALDO	
	oExcel:AddColumn(cPlanilha,cTitulo,"Filial"			    ,1,1) // 01 A
    oExcel:AddColumn(cPlanilha,cTitulo,"Produto"        	,1,1) // 02 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Descrição"        	,1,1) // 03 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Tipo"    		    ,1,1) // 03 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Arm."  				,1,1) // 04 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Quant Est. (SB2)"   ,3,2) // 05 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Quant End. (SBF)"   ,3,2) // 06 B
    
RETURN(NIL)
