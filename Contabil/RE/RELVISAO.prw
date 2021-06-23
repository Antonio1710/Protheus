#INCLUDE "rwmake.ch"   
#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "REPORT.CH"

#DEFINE ENTER CHR(13)+CHR(10)

/*/{Protheus.doc} User Function RELVISAO
	Relatorio para conferencia das visoes gerenciais (CTS)
	@type  Function
	@author Ana Helena
	@since 134/09/2012
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 050729 - FWNM - 24/06/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE
/*/
User Function RELVISAO()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	Private cPerg        := PADR('RELVISAO',10," ")
	Private cAliasTRB    := ""
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 220
	Private tamanho      := "G"
	Private nomeprog     := "RELVISAO"
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "RELVISAO"
	Private nLin         := 80
	Private cString      := "CTS"
	Private cMensagem    := ''
	
	Pergunte(cPerg,.T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDesc1       := "Este programa tem como objetivo imprimir relatorio "
	cDesc2       := "de conferencia das visoes gerenciais."
	cDesc3       := "Conferencia das Visoes Gerenciais"
	cPict        := ""
	titulo       := "Conferencia das Visoes Gerenciais"
	nLin         := 65
	Cabec1       := ""
	Cabec2       := ""
	imprime      := .T.
	aOrd         := {}
//	wnrel        := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	
	oReport := ReportDef(@cAliasTRB)
	oReport:PrintDialog()
	
Return

/*/{Protheus.doc} Static Function ReportDef
    Colunas de impressao
    @type  Static Function
    @author FWNM
    @since 13/12/2019
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ReportDef(cAliasTRB)
                                   
    Local oReport, oSection1, oBreak1, oBreak2
    Local aOrdem := {}
    Local cTitulo := "Conferência das Visões Gerenciais"

    cAliasTRB := "CTS"
    
    Pergunte(cPerg,.F.)
    
    oReport := TReport():New(cPerg,OemToAnsi(cTitulo), cPerg, ;
    {|oReport| ReportPrint(cAliasTRB)},;
    OemToAnsi(" ")+CRLF+;
    OemToAnsi("")+CRLF+;
    OemToAnsi("") )
    
    oReport:SetLandscape()
    //oReport:SetPortrait()
    
    oSection1 := TRSection():New(oReport, OemToAnsi(cTitulo),{"CTS"}, aOrdem /*{}*/, .F., .T.)
    
    oSection1:SetTotalInLine(.F.)
    oSection1:SetHeaderBreak(.T.)   
    oSection1:SetLeftMargin(3)	//Identacao da Secao

    // Quebras de Secao
    oSection1:SetPageBreak(.T.)
    oSection1:SetTotalText("")	

    TRCell():New(oSection1,	"CTS_CODPLA"  ,"","Visão"               /*Titulo*/,         /*Picture*/,TamSX3("CTS_CODPLA")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oSection1,	"CTS_ORDEM"   ,"","Ordem"               /*Titulo*/,         /*Picture*/,TamSX3("CTS_ORDEM")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oSection1,	"CTS_CONTAG"  ,"","Ent Ger"             /*Titulo*/,         /*Picture*/,TamSX3("CTS_CONTAG")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oSection1,	"CTS_CTASUP"  ,"","Ent Sup"             /*Titulo*/,         /*Picture*/,TamSX3("CTS_CTASUP")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oSection1,	"CTS_DESCCG"  ,"","Nome Entidade Ger"   /*Titulo*/,         /*Picture*/,TamSX3("CTS_DESCCG")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oSection1,	"CTS_LINHA"   ,"","Linha"               /*Titulo*/,         /*Picture*/,TamSX3("CTS_LINHA")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oSection1,	"CTS_CT1INI"  ,"","Conta Ini"           /*Titulo*/,         /*Picture*/,TamSX3("CTS_CT1INI")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oSection1,	"CTS_CT1NOI"  ,"","Nome Conta Ini"      /*Titulo*/,         /*Picture*/,TamSX3("CT1_DESC01")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oSection1,	"CTS_CT1FIM"  ,"","Conta Fim"           /*Titulo*/,         /*Picture*/,TamSX3("CTS_CT1FIM")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oSection1,	"CTS_CT1NOF"  ,"","Nome Conta Fim"      /*Titulo*/,         /*Picture*/,TamSX3("CT1_DESC01")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oSection1,	"CTS_CTTINI"  ,"","CCusto Ini"          /*Titulo*/,         /*Picture*/,TamSX3("CTS_CTTINI")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oSection1,	"CTS_CTTFIM"  ,"","CCusto Fim"          /*Titulo*/,         /*Picture*/,TamSX3("CTS_CTTFIM")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oSection1,	"CTS_CTDINI"  ,"","Item Ini"            /*Titulo*/,         /*Picture*/,TamSX3("CTS_CTDINI")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oSection1,	"CTS_CTDFIM"  ,"","Item Fim"            /*Titulo*/,         /*Picture*/,TamSX3("CTS_CTDFIM")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oSection1,	"CTS_IDENT"   ,"","Ident"               /*Titulo*/,         /*Picture*/,TamSX3("CTS_IDENT")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oSection1,	"VALOR"       ,"","Valor"               /*Titulo*/, "@E 999,999,999,999.99"        /*Picture*/,TamSX3("CT2_VALOR")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

//    oBreak1 := TRBreak():New(oReport,oSection1:Cell("D1_PROJETO"),"Total do Projeto",.F.)
//    oBreak2 := TRBreak():New(oReport,oSection1:Cell("E2_NOMFOR"),"Total Fornecedor",.F.)
    
    //TRFunction():New(oSection2:Cell("E2_NUM"),"Quantidade Títulos Modelo","COUNT",oBreak2,"Quantidade Títulos Modelo","@E 999,999,999,999,999",/*uFormula*/,.F.,.F.)
    //TRFunction():New(oSection1:Cell("E2_SALDO"),NIL,"SUM",oBreak2,"","@E 999,999,999,999,999.99",/*uFormula*/,.F.,.F.)
//    TRFunction():New(oSection1:Cell("E2_SALDO"),NIL,"SUM",oBreak1,"","@E 999,999,999,999,999.99",/*uFormula*/,.F.,.F.)
    
Return(oReport)

/*/{Protheus.doc} Static Function ReportPrint
    Impressao relatorio
    @type  Static Function
    @author FWNM
    @since 13/12/2019
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ReportPrint(cAliasTRB)

    Local aCampos   := {}
	Local cQuery    := ""
    Local nQtdItens  := 0
	Local oSection1 := oReport:Section(1)
	
    Private oTempTable
		
	MakeSqlExpr(cPerg)

	// Cria e popula TRB para impressão
	fSeleciona()

    // Impressão
	dbSelectArea("TMPCTS")

    oReport:SetMeter( LastRec() )

    TMPCTS->( dbGoTop() )
	Do While TMPCTS->( !EOF() )

		If oReport:Cancel()
			oReport:PrintText(OemToAnsi("Cancelado"))
			Exit
		EndIf
    
        //inicializo a primeira seção
        oSection1:Init()

        oReport:IncMeter()
    
        //Impressao propriamente dita....
        oSection1:Cell("CTS_CODPLA")  :SetBlock( {|| TMPCTS->CTS_CODPLA} )
        oSection1:Cell("CTS_ORDEM")   :SetBlock( {|| TMPCTS->CTS_ORDEM} )
        oSection1:Cell("CTS_CONTAG")  :SetBlock( {|| TMPCTS->CTS_CONTAG} )
        oSection1:Cell("CTS_CTASUP")  :SetBlock( {|| TMPCTS->CTS_CTASUP} )
        oSection1:Cell("CTS_DESCCG")  :SetBlock( {|| TMPCTS->CTS_DESCCG} )
        oSection1:Cell("CTS_LINHA")   :SetBlock( {|| TMPCTS->CTS_LINHA} )
        oSection1:Cell("CTS_CT1INI")  :SetBlock( {|| TMPCTS->CTS_CT1INI} )
        oSection1:Cell("CTS_CT1NOI")  :SetBlock( {|| TMPCTS->CTS_CT1NOI} )
        oSection1:Cell("CTS_CT1FIM")  :SetBlock( {|| TMPCTS->CTS_CT1FIM} )
        oSection1:Cell("CTS_CT1NOF")  :SetBlock( {|| TMPCTS->CTS_CT1NOF} )
        oSection1:Cell("CTS_CTTINI")  :SetBlock( {|| TMPCTS->CTS_CTTINI} )
        oSection1:Cell("CTS_CTTFIM")  :SetBlock( {|| TMPCTS->CTS_CTTFIM} )
        oSection1:Cell("CTS_CTDINI")  :SetBlock( {|| TMPCTS->CTS_CTDINI} )
        oSection1:Cell("CTS_CTDFIM")  :SetBlock( {|| TMPCTS->CTS_CTDFIM} )
        oSection1:Cell("CTS_IDENT")   :SetBlock( {|| TMPCTS->CTS_IDENT} )
        oSection1:Cell("VALOR")       :SetBlock( {|| TMPCTS->VALOR} )

        oSection1:Printline()	

        //imprimo uma linha para separar 
        //oReport:ThinLine()

        TMPCTS->( dbSkip() )

    EndDo
            
    // Fecho tabelas temporarias
    If Select("TMPCTS") > 0
        TMPCTS->( dbCloseArea() )
    EndIf

    // Método responsável por efetuar a exclusão da tabela, e fechar o alias
    oTempTable:Delete()

Return 

/*/{Protheus.doc} Static Function fSeleciona
	Cria arquivos de trabalho
	@type  Function
	@author Fernando Macieira
	@since 29/08/2009
	@version 01
	@history Chamado 
/*/
Static function fSeleciona()

    Local aCampos := {}

	fDados()

	// Crio TRB para impressão
	// https://tdn.totvs.com.br/display/framework/FWTemporaryTable
	oTempTable := FWTemporaryTable():New("TMPCTS")

	aAdd(aCampos,{'CTS_CODPLA',TamSX3("CTS_CODPLA")[3] ,TamSX3("CTS_CODPLA")[1] ,0})
	aAdd(aCampos,{'CTS_ORDEM'  ,TamSX3("CTS_ORDEM")[3]  ,TamSX3("CTS_ORDEM")[1]  ,0})
	aAdd(aCampos,{'CTS_CONTAG' ,TamSX3("CTS_CONTAG")[3] ,TamSX3("CTS_CONTAG")[1] ,0})
	aAdd(aCampos,{'CTS_CTASUP' ,TamSX3("CTS_CTASUP")[3] ,TamSX3("CTS_CTASUP")[1] ,0})
	aAdd(aCampos,{'CTS_DESCCG' ,TamSX3("CTS_DESCCG")[3] ,TamSX3("CTS_DESCCG")[1] ,0})
	aAdd(aCampos,{'CTS_LINHA'  ,TamSX3("CTS_LINHA")[3]  ,TamSX3("CTS_LINHA")[1]  ,0})
	aAdd(aCampos,{'CTS_CT1INI' ,TamSX3("CTS_CT1INI")[3] ,TamSX3("CTS_CT1INI")[1] ,0})
	aAdd(aCampos,{'CTS_CT1NOI' ,TamSX3("CT1_DESC01")[3] ,TamSX3("CT1_DESC01")[1] ,0})
	aAdd(aCampos,{'CTS_CT1FIM' ,TamSX3("CTS_CT1FIM")[3] ,TamSX3("CTS_CT1FIM")[1] ,0})
	aAdd(aCampos,{'CTS_CT1NOF' ,TamSX3("CT1_DESC01")[3] ,TamSX3("CT1_DESC01")[1] ,0})
	aAdd(aCampos,{'CTS_CTTINI' ,TamSX3("CTS_CTTINI")[3] ,TamSX3("CTS_CTTINI")[1] ,0})
	aAdd(aCampos,{'CTS_CTTFIM' ,TamSX3("CTS_CTTFIM")[3] ,TamSX3("CTS_CTTFIM")[1] ,0})
	aAdd(aCampos,{'CTS_CTDINI' ,TamSX3("CTS_CTDINI")[3] ,TamSX3("CTS_CTDINI")[1] ,0})
	aAdd(aCampos,{'CTS_CTDFIM' ,TamSX3("CTS_CTDFIM")[3] ,TamSX3("CTS_CTDFIM")[1] ,0})
	aAdd(aCampos,{'CTS_NORMAL' ,TamSX3("CTS_NORMAL")[3] ,TamSX3("CTS_NORMAL")[1] ,0})
	aAdd(aCampos,{'CTS_IDENT'  ,TamSX3("CTS_IDENT")[3]  ,TamSX3("CTS_IDENT")[1]  ,0})
   	aAdd(aCampos,{'VALOR'      ,TamSX3("CT2_VALOR")[3]  ,TamSX3("CT2_VALOR")[1]  ,TamSX3("CT2_VALOR")[2]})

	oTemptable:SetFields(aCampos)
	oTempTable:AddIndex("01", {"CTS_CODPLA","CTS_ORDEM","CTS_CONTAG","CTS_CTASUP","CTS_DESCCG","CTS_LINHA","CTS_CT1INI","CTS_CT1FIM","CTS_CTTINI","CTS_CTTFIM","CTS_CTDINI","CTS_CTDFIM","CTS_IDENT","CTS_NORMAL"} )
	oTempTable:Create()

    // 
	dbselectArea("CTS")
	dbSetOrder(1)
	DbgoTop()   
	dbSeek(xFilial("CTS")+mv_par01)
	
	While CTS->(!EOF()) 
	
		IF ALLTRIM(CTS->CTS_CODPLA) == Alltrim(mv_par01) .AND. ;
		   ALLTRIM(CTS->CTS_IDENT) <> '5'
		
			RecLock("TMPCTS",.T.)
				
				TMPCTS->CTS_CODPLA  :=CTS->CTS_CODPLA	             
				TMPCTS->CTS_ORDEM   :=CTS->CTS_ORDEM
				TMPCTS->CTS_CONTAG  :=CTS->CTS_CONTAG
				TMPCTS->CTS_CTASUP  :=CTS->CTS_CTASUP
				TMPCTS->CTS_DESCCG  :=CTS->CTS_DESCCG
				TMPCTS->CTS_LINHA   :=CTS->CTS_LINHA 
				TMPCTS->CTS_CT1INI  :=CTS->CTS_CT1INI
				 
				dbSelectArea("CT1")
				dbSetOrder(1)
				dbGotop()
				
				If dbSeek(xFilial("CT1")+Alltrim(CTS->CTS_CT1INI))
				
					TMPCTS->CTS_CT1NOI:= Alltrim(Substr(CT1->CT1_DESC01,1,30))
						
				Endif	
				
				TMPCTS->CTS_CT1FIM  :=CTS->CTS_CT1FIM
				
				dbSelectArea("CT1")
				dbSetOrder(1)
				dbGotop()
				
				If dbSeek(xFilial("CT1")+Alltrim(CTS->CTS_CT1FIM))
				
					TMPCTS->CTS_CT1NOF := Alltrim(Substr(CT1->CT1_DESC01,1,30))
						
				Endif	
				
				TMPCTS->CTS_CTTINI  := CTS->CTS_CTTINI
				TMPCTS->CTS_CTTFIM  := Iif(Empty(CTS->CTS_CTTFIM),"9999",CTS->CTS_CTTFIM)	
				TMPCTS->CTS_CTDINI  := CTS->CTS_CTDINI 
				TMPCTS->CTS_CTDFIM  := Iif(Empty(CTS->CTS_CTDFIM),"999",CTS->CTS_CTDFIM)	
					
				If CTS->CTS_IDENT == "1"
				
					TMPCTS->CTS_IDENT   :="+"
					
				ElseIf CTS->CTS_IDENT == "2"
				
					TMPCTS->CTS_IDENT   :="-"
					
				Endif
						
				TMPCTS->CTS_NORMAL  := CTS->CTS_NORMAL 
				TMPCTS->VALOR       := 0
					
			MsUnLock()
			
		ENDIF
		
		IF ALLTRIM(CTS->CTS_CODPLA) <> ALLTRIM(mv_par01) 
		
			EXIT //SAIR DO WHILE
			
		ENDIF	
		
		CTS->(dbSkip())
		
	Enddo	  
	                     
	//DEBITO
	dbselectArea("CTSTMPD")
	DbgoTop()
	
	While CTSTMPD->(!EOF())
	
		dbselectArea("TMPCTS")
		dbSetOrder(1)
		DbgoTop()    
		dbSeek(CTSTMPD->CTS_CODPLA+CTSTMPD->CTS_ORDEM+CTSTMPD->CTS_CONTAG+CTSTMPD->CTS_CTASUP+PadR(CTSTMPD->CTS_DESCCG,TamSX3("CTS_DESCCG")[1])+CTSTMPD->CTS_LINHA+CTSTMPD->CTS_CT1INI+CTSTMPD->CTS_CT1FIM) 
		     
		If CTSTMPD->CT2_CCD   >= TMPCTS->CTS_CTTINI .AND. ;
		   CTSTMPD->CT2_CCD   <= TMPCTS->CTS_CTTFIM .AND. ;
		   CTSTMPD->CT2_ITEMD >= TMPCTS->CTS_CTDINI .AND. ;
		   CTSTMPD->CT2_ITEMD <= TMPCTS->CTS_CTDFIM .AND. ;
		   !(TMPCTS->(eof()))
		                         
			RecLock("TMPCTS",.F.)
			
				If CTSTMPD->CTS_NORMAL == "2" //1-debito, 2-credito
						                		    
					TMPCTS->VALOR -= CTSTMPD->DEBITO
									
			    ElseIf CTSTMPD->CTS_NORMAL == "1"
			    		    		  			
		  			TMPCTS->VALOR += CTSTMPD->DEBITO
		  						
		    	Endif
	    		
			MsUnLock()                          		             
					    
			_cCtaSup := Alltrim(TMPCTS->CTS_CTASUP)
			lVerif := .F.
			
			While !lVerif
			
				dbselectArea("CTS")
				dbSetOrder(2)  //2 - CTS_FILIAL, CTS_CODPLA, CTS_CONTAG
				DbgoTop()			   
				If dbSeek(xFilial("CTS")+mv_par01+Alltrim(_cCtaSup))
				
					IF ALLTRIM(CTS->CTS_IDENT) <> '5'
					
						dbSelectArea("TMPCTS")
						dbSetOrder(1)
						dbGoTop()    
						If dbSeek(CTS->CTS_CODPLA+CTS->CTS_ORDEM+Alltrim(_cCtaSup),.T.) //"CTS_CODPLA+CTS_ORDEM+CTS_CONTAG"					
							
							RecLock("TMPCTS",.F.)
							
								If CTS->CTS_NORMAL == "2"
								
									If CTSTMPD->CTS_IDENT == "1" //1-soma, 2-subtrai
									
										TMPCTS->VALOR -= CTSTMPD->DEBITO
										 
									ElseIf CTSTMPD->CTS_IDENT == "2"
									
										TMPCTS->VALOR += CTSTMPD->DEBITO
										
									Endif
									
								ElseIf CTS->CTS_NORMAL == "1"      
								 
									If CTSTMPD->CTS_IDENT == "1" //1-soma, 2-subtrai
									
										TMPCTS->VALOR += CTSTMPD->DEBITO
										
									ElseIf CTSTMPD->CTS_IDENT == "2"
									
										TMPCTS->VALOR -= CTSTMPD->DEBITO
																												
									Endif				
								Endif		      
							
							MsUnlock("TMPCTS")
							
							If Alltrim(CTS->CTS_CTASUP) <> ""
							
								_cCtaSup := Alltrim(CTS->CTS_CTASUP)
								
							Else
							
								lVerif := .T.
									
							Endif
						
						Else
					
							lVerif := .T. //chamado 045125
							cMensagem := cMensagem + CTS->CTS_CODPLA+CTS->CTS_ORDEM+Alltrim(_cCtaSup) + CHR(13) + CHR(10) 	 
							
						Endif
						
					Else
				
						lVerif := .T.	
							
					ENDIF	
				Else
				
					lVerif := .T. 
						
				Endif		
			Enddo
		Endif	
		
		CTSTMPD->(dbSkip())
		
	Enddo         
	                     
	//CREDITO                                  
	dbselectArea("CTSTMPC")
	DbgoTop()
	While CTSTMPC->(!EOF())
	                   
		dbselectArea("TMPCTS")
		dbSetOrder(1)
		DbgoTop()    
		dbSeek(CTSTMPC->CTS_CODPLA+CTSTMPC->CTS_ORDEM+CTSTMPC->CTS_CONTAG+CTSTMPC->CTS_CTASUP+PadR(CTSTMPC->CTS_DESCCG,TamSX3("CTS_DESCCG")[1])+CTSTMPC->CTS_LINHA+CTSTMPC->CTS_CT1INI+CTSTMPC->CTS_CT1FIM) 
		                            	
		If CTSTMPC->CT2_CCC   >= TMPCTS->CTS_CTTINI .AND. ;
		   CTSTMPC->CT2_CCC   <= TMPCTS->CTS_CTTFIM .AND. ;
		   CTSTMPC->CT2_ITEMC >= TMPCTS->CTS_CTDINI .AND. ;
		   CTSTMPC->CT2_ITEMC <= TMPCTS->CTS_CTDFIM .AND. ; 
		   !(TMPCTS->(EOF()))
	        
			RecLock("TMPCTS",.F.)
	
				If CTSTMPC->CTS_NORMAL == "2" //1-debito, 2-credito	
					
					TMPCTS->VALOR += CTSTMPC->CREDITO
							   								 		
		    	ElseIf CTSTMPC->CTS_NORMAL == "1"
		    	  		                             			               
					TMPCTS->VALOR -= CTSTMPC->CREDITO
								 			
			    Endif
		    		    	    
			MsUnLock()
	
			_cCtaSup := Alltrim(TMPCTS->CTS_CTASUP)
			lVerif := .F.
			
			While !lVerif
			
				dbselectArea("CTS")
				dbSetOrder(2)  //2 - CTS_FILIAL, CTS_CODPLA, CTS_CONTAG
				DbgoTop()			   
				If dbSeek(xFilial("CTS")+mv_par01+Alltrim(_cCtaSup))
				
					IF ALLTRIM(CTS->CTS_IDENT) <> '5'
	
						dbSelectArea("TMPCTS")
						dbSetOrder(1)
						dbGoTop()    
						If dbSeek(CTS->CTS_CODPLA+CTS->CTS_ORDEM+Alltrim(_cCtaSup),.T.) //"CTS_CODPLA+CTS_ORDEM+CTS_CONTAG"						
							
							RecLock("TMPCTS",.F.)
						        	  
								If CTS->CTS_NORMAL == "2" //2-credito
								
									If CTSTMPC->CTS_IDENT == "1" //1-soma, 2-subtrai
									
										TMPCTS->VALOR += CTSTMPC->CREDITO
										
									ElseIf CTSTMPC->CTS_IDENT == "2"
									
										TMPCTS->VALOR -= CTSTMPC->CREDITO
																						
									Endif
									
								ElseIf CTS->CTS_NORMAL == "1" //1-debito
								
									If CTSTMPC->CTS_IDENT == "1" //1-soma, 2-subtrai
									
										TMPCTS->VALOR -= CTSTMPC->CREDITO
										
									ElseIf CTSTMPC->CTS_IDENT == "2"
									
										TMPCTS->VALOR += CTSTMPC->CREDITO
																						
									Endif	
								Endif	
		
							MsUnLock("TMPCTS")
						
							If Alltrim(CTS->CTS_CTASUP) <> ""
							
								_cCtaSup := Alltrim(CTS->CTS_CTASUP)
								
							Else
							
								lVerif := .T.
									
							Endif
							
						Else
							
							lVerif := .T. //chamado 045125
							cMensagem := cMensagem + CTS->CTS_CODPLA+CTS->CTS_ORDEM+Alltrim(_cCtaSup) + CHR(13) + CHR(10) 
							
						Endif
						
					Else
				
						lVerif := .T.		
						
					ENDIF	
				Else
				
					lVerif := .T.
						
				Endif		
			Enddo					    
		Endif	
	
		CTSTMPC->(dbSkip())
		
	Enddo  

Return

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 24/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function fDados()

	Local cQuery:=""
	
	If Select("CTSTMPD") > 0
	
		DbSelectArea("CTSTMPD")
		DbCloseArea("CTSTMPD")
		
	Endif       
	
	If Select("CTSTMPC") > 0
	
		DbSelectArea("CTSTMPC")
		DbCloseArea("CTSTMPC")
		
	Endif  
	
	If Select("TMPCTS") > 0
	
		DbSelectArea("TMPCTS")
		DbCloseArea("TMPCTS")
		
	Endif         
	         
	//DEBITO
	cQuery:=" SELECT CTS_CODPLA,CTS_ORDEM,CTS_CONTAG,CTS_CTASUP,CTS_DESCCG,CTS_LINHA,CTS_CT1INI,CTS_CT1FIM,CTS_CTTINI,CTS_CTTFIM,CTS_CTDINI,CTS_CTDFIM,CTS_IDENT,CTS_NORMAL,CT2_CCD,CT2_ITEMD,SUM(CT2_VALOR) AS DEBITO "
	cQuery+=" FROM "+RetSqlName("CTS") + " WITH (NOLOCK) "
	cQuery+=" INNER JOIN " + RetSqlName("CT2") + " WITH (NOLOCK) "
	cQuery+=" ON  CT2_FILIAL = '' " //chamado 045125
	cQuery+=" AND CT2_DATA BETWEEN '" + DTOS(mv_par02) + "' AND '" + DTOS(mv_par03) + "' " //chamado 045125
	cQuery+=" AND CT2_DEBITO >= CTS_CT1INI AND CT2_DEBITO <= CTS_CT1FIM "
	cQuery+=" AND CT2_CCD >= CTS_CTTINI AND CT2_CCD <= '9999' "
	cQuery+=" AND CT2_ITEMD >= CTS_CTDINI AND CT2_ITEMD <= '999' "
	cQuery+=" AND CT2_TPSALD = CTS_TPSALD "
	
	IF MV_PAR05 == 2 // NAO 
	
		cQuery+=" AND CT2_LOTE <> '988888' " // WILLIAM COSTA 12/07/2018 CHAMADO 037521 || CONTROLADORIA || ANDRESSA || RELATORIO GERENCIAL
	
	ENDIF
	
	cQuery+=" AND " + RetSqlName("CT2") + ".D_E_L_E_T_ <> '*' " //chamado 045125
	cQuery+=" WHERE CTS_FILIAL = '' " //chamado 045125
	cQuery+=" AND  CTS_CODPLA = '" + MV_PAR01 + "' "
	cQuery+=" AND  CTS_IDENT <> '5' " //chamado 045125
	cQuery+=" AND " + RetSqlName("CTS") + ".D_E_L_E_T_ <> '*' "
	
	cQuery+=" GROUP BY CTS_CODPLA,CTS_ORDEM,CTS_CONTAG,CTS_CTASUP,CTS_DESCCG,CTS_LINHA,CTS_CT1INI,CTS_CT1FIM,CTS_CTTINI,CTS_CTTFIM,CTS_CTDINI,CTS_CTDFIM,CTS_IDENT,CTS_NORMAL,CT2_CCD,CT2_ITEMD "
	cQuery+=" ORDER BY CTS_CODPLA,CTS_ORDEM,CTS_CONTAG,CTS_CTASUP,CTS_DESCCG,CTS_LINHA,CTS_CT1INI,CTS_CT1FIM,CTS_CTTINI,CTS_CTTFIM,CTS_CTDINI,CTS_CTDFIM,CTS_IDENT,CTS_NORMAL,CT2_CCD,CT2_ITEMD "
	
	TCQUERY cQuery NEW ALIAS "CTSTMPD"
	
	dbselectArea("CTSTMPD")
	DbgoTop()
	  
	//CREDITO
	cQuery:=" SELECT CTS_CODPLA,CTS_ORDEM,CTS_CONTAG,CTS_CTASUP,CTS_DESCCG,CTS_LINHA,CTS_CT1INI,CTS_CT1FIM,CTS_CTTINI,CTS_CTTFIM,CTS_CTDINI,CTS_CTDFIM,CTS_IDENT,CTS_NORMAL,CT2_CCC,CT2_ITEMC,SUM(CT2_VALOR) AS CREDITO "
	cQuery+=" FROM "+RetSqlName("CTS") + " WITH (NOLOCK) "
	cQuery+=" INNER JOIN " + RetSqlName("CT2") + " WITH (NOLOCK) "
	cQuery+=" ON CT2_FILIAL = '' " //chamado 045125
	cQuery+=" AND CT2_DATA BETWEEN '" + DTOS(mv_par02) + "' AND '" + DTOS(mv_par03) + "' " //chamado 045125
	cQuery+=" AND CT2_CREDIT >= CTS_CT1INI AND CT2_CREDIT <= CTS_CT1FIM "
	cQuery+=" AND CT2_CCC >= CTS_CTTINI AND CT2_CCC <= '9999'" 
	cQuery+=" AND CT2_ITEMC >= CTS_CTDINI AND CT2_ITEMC <= '999' "
	cQuery+=" AND CT2_TPSALD = CTS_TPSALD "
	
	IF MV_PAR05 == 2 // NAO 
	
		cQuery+=" AND CT2_LOTE <> '988888' " // WILLIAM COSTA 12/07/2018 CHAMADO 037521 || CONTROLADORIA || ANDRESSA || RELATORIO GERENCIAL
	
	ENDIF
	
	cQuery+=" AND " + RetSqlName("CT2") + ".D_E_L_E_T_ <> '*' " //chamado 045125
	cQuery+=" WHERE CTS_FILIAL = '' " //chamado 045125
	cQuery+=" AND CTS_CODPLA = '" + MV_PAR01 + "' "
	cQuery+=" AND CTS_IDENT <> '5' " //chamado 045125
	cQuery+=" AND " + RetSqlName("CTS") + ".D_E_L_E_T_ <> '*' "
	
	cQuery+=" GROUP BY CTS_CODPLA,CTS_ORDEM,CTS_CONTAG,CTS_CTASUP,CTS_DESCCG,CTS_LINHA,CTS_CT1INI,CTS_CT1FIM,CTS_CTTINI,CTS_CTTFIM,CTS_CTDINI,CTS_CTDFIM,CTS_IDENT,CTS_NORMAL,CT2_CCC,CT2_ITEMC "
	cQuery+=" ORDER BY CTS_CODPLA,CTS_ORDEM,CTS_CONTAG,CTS_CTASUP,CTS_DESCCG,CTS_LINHA,CTS_CT1INI,CTS_CT1FIM,CTS_CTTINI,CTS_CTTFIM,CTS_CTDINI,CTS_CTDFIM,CTS_IDENT,CTS_NORMAL,CT2_CCC,CT2_ITEMC "
	
	TCQUERY cQuery NEW ALIAS "CTSTMPC"
	
	dbselectArea("CTSTMPC")
	DbgoTop()

Return