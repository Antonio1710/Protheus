#INCLUDE "Protheus.ch"     
#INCLUDE "Topconn.ch"
            
/*/{Protheus.doc} User Function HCRFIBLT
	Relatorio de conciliação de fornecedores. Entre SE5 e CT2
	
	@type  Function
	@author Ana Helena
	@since 11/07/2013
	@version 01
	@history chamado TI - Abel Babino - 02/07/2019 - Ch.atorio de conciliação de fornecedores. Entre SE5 e CT2. Ch.Interno TI - Abel Babini - Considerar Var.Cambial no Contas à Pagar.
	@history chamado 8797 - Leonardo P. Monteiro - 02/07/2019 - Inclusão de parâmetro de exceção para exclusão de fornecedores (Governos, Prefeiuras e etc...) e criado para os tipos de títulos.
	@history chamado 63633 - Leonardo P. Monteiro - 012/11/2021 - Correção dos valores em segunda moeda.

/*/

User Function RCONCFOR()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de conciliação de fornecedores')

	cPerg   := PADR('RFORCON',10," ")
	PutSx1(cPerg,"01","Do Fornecedor          ?","Do Fornecedor          ?","Do Fornecedor          ?","mv_ch1","C",6 ,0,0,"G",""         ,"SA2","","","mv_par01",""      ,"","","","","","","","","","","","","","","")
	PutSx1(cPerg,"02","Ate Fornecedor         ?","Ate Fornecedor         ?","Ate Fornecedor         ?","mv_ch2","C",6 ,0,0,"G",""         ,"SA2","","","mv_par02",""      ,"","","","","","","","","","","","","","","")
	PutSx1(cPerg,"03","Loja de                ?","Loja de                ?","Loja de                ?","mv_ch3","C",2 ,0,0,"G",""         ,"","","","mv_par03",""      ,"","","","","","","","","","","","","","","")
	PutSx1(cPerg,"04","Loja Ate               ?","Loja Ate               ?","Loja Ate               ?","mv_ch4","C",2 ,0,0,"G",""         ,"","","","mv_par04",""      ,"","","","","","","","","","","","","","","")
	PutSX1(cPerg,"05","Data Contabil De "       ,"Data Contabil De "        ,"Data Contabil De "        ,"mv_ch5","D",08,0,0,"G","",""   ,"","","mv_par05" ,"","","","","","","","","","","","","","",""," ")
	PutSX1(cPerg,"06","Data Contabil Ate "      ,"Data Contabil Ate "       ,"Data Contabil Ate "       ,"mv_ch6","D",08,0,0,"G","",""   ,"","","mv_par06" ,"","","","","","","","","","","","","","",""," ")
	PutSX1(cPerg,"07","Data Base "      ,"Data Base "       ,"Data Base "       ,"mv_ch7","D",08,0,0,"G","",""   ,"","","mv_par07" ,"","","","","","","","","","","","","","",""," ")
	PutSX1(cPerg,"08","Tipo Relatorio","Tipo Relatorio"	,"Tipo Relatorio"            ,"mv_ch8","N",01,0,01,"C","","","","","mv_par08" ,"Analitico","Analitico","Analitico","","Sintetico","Sintetico","Sintetico","","","","","","","",""," ")
	PutSx1(cPerg,"09","Conta Contabil         ?","Conta Contabil         ?","Conta Contabil         ?","mv_ch9","C",20 ,0,0,"G",""         ,"CT1","","","mv_par09",""      ,"","","","","","","","","","","","","","","")
	
	Pergunte(cPerg,.F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cDesc1       := "Este programa tem como objetivo imprimir relatorio "
	cDesc2       := "de conciliacao de fornecedores."
	cDesc3       := "Conciliacao de Fornecedores"
	cPict        := ""
	titulo       := "Conciliacao de Fornecedores"
	Cabec1       := ""
	Cabec2       := ""
	imprime      := .T.
	aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 220
	Private tamanho      := "G"
	Private nomeprog     := "RCONCFOR"
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "RCONCFOR"
	Private nLin         := 80
	//Ticket 8797 - Leonardo P. Monteiro - 02/07/2019 - Inclusão de parâmetro de exceção para exclusão de fornecedores (Governos, Prefeiuras e etc...) e tipos de títulos.
	Private cTpExc		 := Formatin(SupergetMv("MV_XTIEXCC",,"NDF"),";")
	Private cFoExc		 := Formatin(SupergetMv("MV_XFOEXCC",,"014000"),";")
	Private cString := "SE5"
	Private oTMPSE5
	Private oTMPCT2
	Private oTMPANL
	Private oTMPSE2
	
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)
	
	
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

	oTMPSE5:DELETE()
	oTMPCT2:DELETE()
	oTMPANL:DELETE()
	oTMPSE2:DELETE()
Return


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem
	Local _aStr1   := {}
	Local _aStr2   := {}
	Local _aStr3   := {}
	
	dbSelectArea(cString)
	dbSetOrder(1)
	
	SetRegua(RecCount())
	              
	If mv_par08 == 1 //Analitico
		Cabec1  := "FORNECEDOR                                FILIAL PREFIXO NUMERO  PARCELA TIPO   DT EMISSAO    DT MOVIMENTO    DT CONTABIL    SLD FINANC       SLD CONTABIL         DIFERENCA     "
	Else
		Cabec1  := "FORNECEDOR     RAZAO SOCIAL                         SLD FINANCEIRO        SLD CONTABIL         DIFERENCA     "
	Endif	
	Cabec2  := " "
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                               	
	//³ Monta Querys                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fDados() 
	    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                               	
	//³ Tabelas Temporarias                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	
	//Tabela Temporaria SE2
	AADD(_aStr1,{'E2_FORNECE'  ,"C",06,0})
	AADD(_aStr1,{'E2_LOJA'    ,"C",02,0})
	AADD(_aStr1,{'E2_VALOR'   ,"N",15,04}) //INICIO Chamado Interno TI - Abel Babini - Considerar valor da correção monetária passiva abatendo do valor do título - 02/07/2019
	//AADD(_aStr1,{'E2_VLCRUZ'   ,"N",15,04}) //INICIO Chamado Interno TI - Abel Babini - Considerar valor da correção monetária passiva abatendo do valor do título - 02/07/2019
	If mv_par08 == 1 //Analitico
		AADD(_aStr1,{'E2_EMIS1'   ,"D",08,0})
	Endif
	/*
	_cArqTmp :=CriaTrab(_aStr1,.T.)
	DbUseArea(.T.,,_cArqTmp,"TMPSE2",.F.,.F.)
	_cIndex:="E2_FORNECE+E2_LOJA"
	IndRegua("TMPSE2",_cArqTmp,_cIndex,,,"Criando Indices...")          
	*/
	oTMPSE2 := FWTemporaryTable():New("TMPSE2")
	oTMPSE2:SetFields(_aStr1)
	oTMPSE2:AddIndex("01", {"E2_FORNECE","E2_LOJA"} )
	oTMPSE2:Create()
	

	//Tabela Temporaria SE5
	AADD(_aStr2,{'E5_CLIFOR'  ,"C",06,0})
	AADD(_aStr2,{'E5_LOJA'    ,"C",02,0})
	AADD(_aStr2,{'E5_VALOR'   ,"N",15,04})
	AADD(_aStr2,{'E5_RECPAG'  ,"C",01,0})
	AADD(_aStr2,{'E5_MOTBX'   ,"C",03,0})
	AADD(_aStr2,{'E5_TIPODOC' ,"C",02,0})
	AADD(_aStr2,{'E5_VLACRES' ,"N",15,04})
	If mv_par08 == 1 //Analitico
		AADD(_aStr2,{'E5_DATA'   ,"D",08,0})
	Endif
	                                      
	AADD(_aStr2,{'E5_VLDECRE' ,"N",15,04}) // WILL chamado 028902
	AADD(_aStr2,{'E5_VLDESCO' ,"N",15,04}) // WILL chamado 028902
	
	//_cArqTmp :=CriaTrab(_aStr2,.T.)
	//DbUseArea(.T.,,_cArqTmp,"TMPSE5",.F.,.F.)
	//_cIndex:="E5_CLIFOR+E5_LOJA"
	//IndRegua("TMPSE5",_cArqTmp,_cIndex,,,"Criando Indices...")
	oTMPSE5 := FWTemporaryTable():New("TMPSE5")
	oTMPSE5:SetFields(_aStr2)
	oTMPSE5:AddIndex("01", {"E5_CLIFOR","E5_LOJA"} )
	oTMPSE5:Create()
	

	//Tabela Temporaria CT2                              
	AADD(_aStr3,{'CT2_CLIFOR'  ,"C",06,0})
	AADD(_aStr3,{'CT2_LOJACF'  ,"C",02,0})
	AADD(_aStr3,{'CT2_VALOR'   ,"N",15,04})    
	AADD(_aStr3,{'CT2_DEBITO'  ,"C",20,0})
	AADD(_aStr3,{'CT2_CREDIT'  ,"C",20,0})
	If mv_par08 == 1 //Analitico
		AADD(_aStr2,{'CT2_DATA'   ,"D",08,0})
	Endif
	/*
	_cArqTmp :=CriaTrab(_aStr3,.T.)
	DbUseArea(.T.,,_cArqTmp,"TMPCT2",.F.,.F.)
	_cIndex:="CT2_CLIFOR+CT2_LOJACF"
	IndRegua("TMPCT2",_cArqTmp,_cIndex,,,"Criando Indices...")
	*/
	oTMPCT2 := FWTemporaryTable():New("TMPCT2")
	oTMPCT2:SetFields(_aStr3)
	oTMPCT2:AddIndex("01", {"CT2_CLIFOR","CT2_LOJACF"} )
	oTMPCT2:Create()
	

	nSldFin  := 0          
	nSldCon  := 0
	nTotFSE2 := 0 //Para o relatorio analitico - total por fornecedor
	nTotFCT2 := 0 //Para o relatorio analitico - total por fornecedor
	nTotSE2  := 0 //Total Geral
	nTotCT2  := 0 //Total Geral
	                                             
	//If mv_par08 == 1 //Analitico
		fDadosAnl(Cabec1,Cabec2,Titulo,nLin)
	//Endif
	
	//If mv_par08 <> 1 //Sintetico
	//	fDadosSin(Cabec1,Cabec2,Titulo,nLin)
	//Endif
	
	dbselectArea("CT2TMP")
	dbCloseArea()      
	dbselectArea("SE5TMP")
	dbCloseArea()  
	dbselectArea("SE2TMP")
	dbCloseArea()  
	dbselectArea("SA2TMP")
	dbCloseArea()
	dbselectArea("TMPCT2")
	dbCloseArea()
	dbselectArea("TMPSE5")
	dbCloseArea()
	dbselectArea("TMPSE2")
	dbCloseArea()
	If Select("TMPANL") > 0
		dbselectArea("TMPANL")
		dbCloseArea()
	endif
	
	SET DEVICE TO SCREEN
	
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	
	MS_FLUSH()

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                               	
//³ Relatorio Analitico                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function fDadosAnl(Cabec1,Cabec2,Titulo,nLin)
	Local nValor	:= 0
	Local _aStr4   	:= {} 
	
	//Tabela Temporaria para relatorio Analitico
	AADD(_aStr4,{'FORNECE'  ,"C",06,0})
	AADD(_aStr4,{'LOJA'     ,"C",02,0})
	AADD(_aStr4,{'VALORCT2' ,"N",15,04})
	AADD(_aStr4,{'VALORSE2' ,"N",15,04})	
	AADD(_aStr4,{'FILIAL'   ,"C",02,0})
	AADD(_aStr4,{'PREFIXO'  ,"C",03,0})
	AADD(_aStr4,{'NUMERO'   ,"C",09,0})
	AADD(_aStr4,{'PARCELA'  ,"C",03,0})
	AADD(_aStr4,{'TIPO'     ,"C",03,0})	
	AADD(_aStr4,{'DATASE2'  ,"D",08,0})	
	AADD(_aStr4,{'DATASE5'  ,"D",08,0})
	AADD(_aStr4,{'DATACT2'  ,"D",08,0})
	AADD(_aStr4,{'DEBITO'   ,"C",20,0})
	AADD(_aStr4,{'CREDIT'   ,"C",20,0})
	AADD(_aStr4,{'TIPODOC'  ,"C",02,0})			
	AADD(_aStr4,{'RECPAG'   ,"C",01,0})
	AADD(_aStr4,{'VLACRES'  ,"C",01,0})			
	/*
	_cArqTmp :=CriaTrab(_aStr4,.T.)
	DbUseArea(.T.,,_cArqTmp,"TMPANL",.F.,.F.)
	*/
	//_cIndex:="FORNECE+LOJA+FILIAL+PREFIXO+NUMERO+PARCELA+TIPO"
	/*
	_cIndex:="FORNECE+LOJA+FILIAL+NUMERO+PREFIXO+PARCELA+TIPO"
	IndRegua("TMPANL",_cArqTmp,_cIndex,,,"Criando Indices...")	
	*/
	oTMPANL := FWTemporaryTable():New("TMPANL")
	oTMPANL:SetFields(_aStr4)
	oTMPANL:AddIndex("01", {"FORNECE","LOJA","FILIAL","NUMERO","PREFIXO","PARCELA","TIPO"} )
	oTMPANL:Create()
	

	dbselectArea("SE2TMP")
	DbgoTop()             
	While SE2TMP->(!EOF())
	    /*
	    _cPf   := "MAN"
	    _cNum  := "203449   "
	    _cPa   := "A  "
	
	    IF SE2TMP->(E2_PREFIXO+E2_NUM+E2_PARCELA) <> _cPF+_cNum + _cPa
	       SE2TMP->(dbSkip())
	       loop
	    Endif   
	   	*/
	   	     
		RecLock("TMPANL",.T.)	
		TMPANL->FORNECE   := SE2TMP->E2_FORNECE
		TMPANL->LOJA      := SE2TMP->E2_LOJA
		TMPANL->VALORSE2  := SE2TMP->E2_VALOR	
		TMPANL->FILIAL    := SE2TMP->E2_FILIAL	
		TMPANL->PREFIXO   := SE2TMP->E2_PREFIXO
		TMPANL->NUMERO    := SE2TMP->E2_NUM
		TMPANL->PARCELA   := SE2TMP->E2_PARCELA
		TMPANL->TIPO      := SE2TMP->E2_TIPO
		TMPANL->DATASE2   := STOD(SE2TMP->E2_EMIS1)
		MsUnLock()
	
		SE2TMP->(dbSkip())
	Enddo
	
	dbselectArea("SE5TMP")
	DbgoTop()             
	While SE5TMP->(!EOF())
	
	    /* somente para testes e analise Mauricio - 01/06/16
	    _cPf   := "MAN"
	    _cNum  := "203449   "
	    _cPa   := "A  "
	
	    IF SE5TMP->(E5_PREFIXO+E5_NUMERO+E5_PARCELA) <> _cPF+_cNum + _cPa
	       SE5TMP->(dbSkip())
	       loop
	    Endif  
	    */
	    //@history chamado 8797 - Leonardo P. Monteiro - 02/07/2019 - Inclusão de parâmetro de exceção para exclusão de fornecedores (Governos, Prefeiuras e etc...) e criado para os tipos de títulos.
		nValor := IIF( SE5TMP->E5_TXMOEDA > 1, SE5TMP->E5_VLMOED2 , SE5TMP->E5_VALOR)

		RecLock("TMPANL",.T.)	
		TMPANL->FORNECE   := SE5TMP->E5_CLIFOR
		TMPANL->LOJA      := SE5TMP->E5_LOJA	
		If Alltrim(SE5TMP->E5_TIPODOC) == "ES" .And. Alltrim(SE5TMP->E5_RECPAG) == "R"
		    IF SE5TMP->E5_VLACRES <> 0
		       IF SE5TMP->E5_VLACRES == SE5TMP->E5_VLJUROS
 		          TMPANL->VALORSE2 += nValor-SE5TMP->E5_VLACRES
		       Else
		          TMPANL->VALORSE2 += nValor-SE5TMP->E5_VLACRES - SE5TMP->E5_VLJUROS
		       Endif
		    Else   
			   TMPANL->VALORSE2 += nValor-SE5TMP->E5_VLACRES - SE5TMP->E5_VLJUROS
			Endif   
			
			// ********* INICIO  WILL chamado 028902  ************ //
			IF nValor <> 0 .AND. (SE5TMP->E5_VLDECRE <> 0 .OR. SE5TMP->E5_VLDESCO <> 0)
		       IF SE5TMP->E5_VLDECRE == SE5TMP->E5_VLDESCO
		          TMPANL->VALORSE2 += SE5TMP->E5_VLDECRE
		       Else 
		          IF SE5TMP->E5_VLDESCO > SE5TMP->E5_VLDECRE
		          
		          	IF SE5TMP->E5_VLDESCO == SE5TMP->E5_VLJUROS
			       		  	TMPANL->VALORSE2 += SE5TMP->E5_VLDESCO + SE5TMP->E5_VLJUROS
			       	ELSE
			          		TMPANL->VALORSE2 += SE5TMP->E5_VLDESCO
			        ENDIF	
		       		
		          ELSEIF SE5TMP->E5_VLDESCO == 0 .AND. SE5TMP->E5_VLDECRE > 0	
		          
		          	TMPANL->VALORSE2 := TMPANL->VALORSE2
		          		
		          ELSE	
		          
		          	TMPANL->VALORSE2 += SE5TMP->E5_VLDECRE + SE5TMP->E5_VLDESCO
		          
		          ENDIF	
		       Endif
		    
		    ELSEIF nValor == 0 .AND. SE5TMP->E5_VLDESCO > 0
		    
		    	TMPANL->VALORSE2 += SE5TMP->E5_VLDESCO
		       
		    Endif   
			// ********* FINAL  WILL chamado 028902  ************ //
			
		ElseIf Alltrim(SE5TMP->E5_TIPODOC) == "MT" .And. Alltrim(SE5TMP->E5_RECPAG) == "P"
			TMPANL->VALORSE2 += nValor
		//INICIO Chamado Interno TI - Abel Babini - Considerar valor da correção monetária passiva abatendo do valor do título - 02/07/2019
		ElseIf Alltrim(SE5TMP->E5_TIPODOC) == "CM" .And. Alltrim(SE5TMP->E5_RECPAG) == "P"
			TMPANL->VALORSE2 -= ABS(nValor)
		ElseIf Alltrim(SE5TMP->E5_TIPODOC) == "CM" .And. Alltrim(SE5TMP->E5_RECPAG) == "R"
			TMPANL->VALORSE2 += ABS(nValor)
		//FIM Chamado Interno TI - Abel Babini - Considerar valor da correção monetária passiva abatendo do valor do título - 02/07/2019
		Else
	    	IF SE5TMP->E5_VLACRES <> 0
		       IF SE5TMP->E5_VLACRES == SE5TMP->E5_VLJUROS
		          TMPANL->VALORSE2 -= nValor-SE5TMP->E5_VLACRES
		       Else
		          TMPANL->VALORSE2 -= nValor-SE5TMP->E5_VLACRES - SE5TMP->E5_VLJUROS
		       Endif
		    Else   
			   TMPANL->VALORSE2 -= nValor-SE5TMP->E5_VLACRES - SE5TMP->E5_VLJUROS
			Endif  
			
			// ********* INICIO  WILL chamado 028902  ************ //
			IF nValor <> 0 .AND. (SE5TMP->E5_VLDECRE <> 0 .OR. SE5TMP->E5_VLDESCO <> 0)
		       IF SE5TMP->E5_VLDECRE == SE5TMP->E5_VLDESCO
		          TMPANL->VALORSE2 -= SE5TMP->E5_VLDECRE
		       Else
		       		IF SE5TMP->E5_VLDESCO > SE5TMP->E5_VLDECRE
		       		
		       			IF SE5TMP->E5_VLDESCO == SE5TMP->E5_VLJUROS
			       		  	TMPANL->VALORSE2 -= SE5TMP->E5_VLDESCO - SE5TMP->E5_VLJUROS
			       		ELSE
			          		TMPANL->VALORSE2 -= SE5TMP->E5_VLDESCO
			          	ENDIF	
		       		
		       		ELSEIF SE5TMP->E5_VLDESCO == 0 .AND. SE5TMP->E5_VLDECRE > 0	
		          
			          	TMPANL->VALORSE2 := TMPANL->VALORSE2	
		          	
		          	ELSE	
		          
		          		TMPANL->VALORSE2 -= SE5TMP->E5_VLDECRE + SE5TMP->E5_VLDESCO
		          
		          	ENDIF			
		       Endif
		       
			ELSEIF nValor == 0 .AND. SE5TMP->E5_VLDESCO > 0
		    
		    	TMPANL->VALORSE2 -= SE5TMP->E5_VLDESCO
		    			       
		    Endif   
			// ********* FINAL  WILL chamado 028902  ************ //
			
			 
		Endif		
		TMPANL->FILIAL     := SE5TMP->E5_FILIAL	
		TMPANL->PREFIXO    := SE5TMP->E5_PREFIXO
		TMPANL->NUMERO     := SE5TMP->E5_NUMERO
		TMPANL->PARCELA    := SE5TMP->E5_PARCELA
		TMPANL->TIPO       := SE5TMP->E5_TIPO
		TMPANL->DATASE5    := STOD(SE5TMP->E5_DATA)
		TMPANL->RECPAG     := SE5TMP->E5_RECPAG
		TMPANL->TIPODOC    := SE5TMP->E5_TIPODOC
		MsUnLock()
	
		SE5TMP->(dbSkip())
	Enddo	
	
	dbselectArea("CT2TMP")
	DbgoTop()             
	While CT2TMP->(!EOF())
	
		dbSelectArea("TMPANL")
		dbSetOrder(1)
		dbGoTop()
		
	    /* somente para testes e analise Mauricio - 01/06/16
	    _cPf   := "MAN"
	    _cNum  := "203449   "
	    _cPa   := "A  "
	
	    IF CT2TMP->(CT2_PREFIX+CT2_NUMDOC+CT2_PARCEL) <> _cPF+_cNum + _cPa
	       CT2TMP->(dbSkip())
	       loop
	    Endif  
	    */
	    
	        
		RecLock("TMPANL",.T.)	
		TMPANL->FORNECE   := CT2TMP->CT2_CLIFOR
		TMPANL->LOJA      := CT2TMP->CT2_LOJACF
		If Alltrim(CT2TMP->CT2_DEBITO) == Alltrim(mv_par09)//"211110001"
			TMPANL->VALORCT2  -= CT2TMP->CT2_VALOR
		ElseIf Alltrim(CT2TMP->CT2_CREDIT) == Alltrim(mv_par09)//"211110001"
			TMPANL->VALORCT2  += CT2TMP->CT2_VALOR			
		Endif				
		TMPANL->FILIAL    := CT2TMP->CT2_FILKEY	
		TMPANL->PREFIXO   := CT2TMP->CT2_PREFIX
		TMPANL->NUMERO    := CT2TMP->CT2_NUMDOC
		TMPANL->PARCELA   := CT2TMP->CT2_PARCEL
		TMPANL->TIPO      := CT2TMP->CT2_TIPODC
		TMPANL->DATACT2   := STOD(CT2TMP->CT2_DATA)						
		MsUnLock()
	
		CT2TMP->(dbSkip())
	Enddo		           
	        
	//Impressao
	dbSelectArea("SA2TMP")
	dbGoTop()
	While SA2TMP->(!EOF())
		If nLin > 65
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif
		
		lEntrou := .F. 	
		dbSelectArea("TMPANL")
		dbSetOrder(1)
		dbGoTop()
		dbSeek(SA2TMP->A2_COD+SA2TMP->A2_LOJA)
		While TMPANL->(!EOF()) .And. SA2TMP->A2_COD == TMPANL->FORNECE .And. SA2TMP->A2_LOJA == TMPANL->LOJA
			
			If nLin > 65
		   		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		   		nLin := 8
		   	Endif		
			
			If !lEntrou
				lEntrou := .T.
				nTotFSE2 := 0
				nTotFCT2 := 0			
				@nLin,000 Psay SA2TMP->A2_COD
				@nLin,008 Psay SA2TMP->A2_LOJA				
				@nLin,012 Psay Substr(SA2TMP->A2_NOME,1,30)
			Endif	                                    				
			
			IF MV_PAR08 == 1 &&Analitico                                                                
			@nLin,045 Psay TMPANL->FILIAL
			@nLin,050 Psay TMPANL->PREFIXO
			@nLin,055 Psay TMPANL->NUMERO
			@nLin,067 Psay TMPANL->PARCELA			
			@nLin,073 Psay TMPANL->TIPO
			If ALLTRIM(DTOS(TMPANL->DATASE2)) <> ""
				@nLin,080 Psay TMPANL->DATASE2
			Endif
			If ALLTRIM(DTOS(TMPANL->DATASE5)) <> ""			
				@nLin,095 Psay TMPANL->DATASE5 
			Endif
			If ALLTRIM(DTOS(TMPANL->DATACT2)) <> ""	
				@nLin,110 Psay TMPANL->DATACT2 		
			Endif	
			@nLin,120 Psay TMPANL->VALORSE2 PICTURE "@E 999,999,999.99"//15			
			@nLin,140 Psay TMPANL->VALORCT2 PICTURE "@E 999,999,999.99"
			Endif
			nTotFSE2 += TMPANL->VALORSE2
			nTotFCT2 += TMPANL->VALORCT2
			
			nTotSE2 += TMPANL->VALORSE2
			nTotCT2 += TMPANL->VALORCT2
			IF MV_PAR08 == 1					
			nLin += 1
			Endif		
			TMPANL->(dbSkip())
		Enddo
			
		If lEntrou		
			If nLin > 65
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 8
			Endif		
		    
		    IF MV_PAR08 == 1
			nLin += 1		
			@nLin,000 Psay "Total Fornecedor"
			@nLin,120 Psay nTotFSE2 PICTURE "@E 999,999,999.99"
			@nLin,140 Psay nTotFCT2 PICTURE "@E 999,999,999.99"
			If nTotFSE2 > 0 .and. nTotFCT2 > 0
				@nLin,160 Psay nTotFSE2-nTotFCT2 PICTURE "@E 999,999,999.99"		
			Else
				@nLin,160 Psay nTotFSE2+nTotFCT2 PICTURE "@E 999,999,999.99"
			Endif
			else   &&sintetico
			    @nLin,52 Psay nTotFSE2 PICTURE "@E 999,999,999.99"
			    @nLin,72 Psay nTotFCT2 PICTURE "@E 999,999,999.99"
			    If nTotFSE2 > 0 .and. nTotFCT2 > 0
				  @nLin,90 Psay nTotFSE2-nTotFCT2 PICTURE "@E 999,999,999.99"		
			    Else
				  @nLin,90 Psay nTotFSE2+nTotFCT2 PICTURE "@E 999,999,999.99"
			    Endif
			    nLin += 1
			Endif
			IF MV_PAR08 == 1	
			nLin += 2
			ENdif		
		Endif
		SA2TMP->(dbSkip())
	Enddo
	If MV_PAR08 == 1
		nLin += 1
		@nLin,000 Psay "Total Geral"
		@nLin,120 Psay nTotSE2 PICTURE "@E 999,999,999.99"
		@nLin,140 Psay nTotCT2 PICTURE "@E 999,999,999.99"
		If nTotSE2 > 0 .and. nTotCT2 > 0
			@nLin,160 Psay nTotSE2-nTotCT2 PICTURE "@E 999,999,999.99"	
		Else
			@nLin,160 Psay nTotSE2+nTotCT2 PICTURE "@E 999,999,999.99"	
		Endif
	Else
		nLin += 1
		@nLin,000 Psay "Total Geral"
		@nLin,52 Psay nTotSE2 PICTURE "@E 999,999,999.99"
		@nLin,72 Psay nTotCT2 PICTURE "@E 999,999,999.99"
		If nTotSE2 > 0 .and. nTotCT2 > 0
			@nLin,90 Psay nTotSE2-nTotCT2 PICTURE "@E 999,999,999.99"	
		Else
			@nLin,90 Psay nTotSE2+nTotCT2 PICTURE "@E 999,999,999.99"	
		Endif
	Endif
	
Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                               	
//³ Relatorio Sintetico                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function fDadosSin(Cabec1,Cabec2,Titulo,nLin)
	Local nValor := 0

	dbselectArea("SE2TMP")
	DbgoTop()             
	While SE2TMP->(!EOF())
	        
		RecLock("TMPSE2",.T.)	
		TMPSE2->E2_FORNECE := SE2TMP->E2_FORNECE
		TMPSE2->E2_LOJA    := SE2TMP->E2_LOJA
		TMPSE2->E2_VALOR   := SE2TMP->E2_VALOR	
		MsUnLock()
		
		SE2TMP->(dbSkip())
	Enddo
	
	dbselectArea("SE5TMP")
	DbgoTop()             
	While SE5TMP->(!EOF())
	    //@history chamado 8797 - Leonardo P. Monteiro - 02/07/2019 - Inclusão de parâmetro de exceção para exclusão de fornecedores (Governos, Prefeiuras e etc...) e criado para os tipos de títulos.
		nValor := IIF( SE5TMP->E5_TXMOEDA > 1, SE5TMP->E5_VLMOED2 , SE5TMP->E5_VALOR)

		RecLock("TMPSE5",.T.)	
		TMPSE5->E5_CLIFOR  := SE5TMP->E5_CLIFOR
		TMPSE5->E5_LOJA    := SE5TMP->E5_LOJA
		IF SE5TMP->E5_VLACRES <> 0
		   IF SE5TMP->E5_VLACRES == SE5TMP->E5_VLJUROS
		      TMPSE5->E5_VALOR  := nValor-SE5TMP->E5_VLACRES
		   Else
		      If SE5TMP->E5_VLACRES > SE5TMP->E5_VLJUROS
		         TMPSE5->E5_VALOR  := nValor-(SE5TMP->E5_VLACRES - SE5TMP->E5_VLJUROS)
		      Else
		         TMPSE5->E5_VALOR  := nValor-(SE5TMP->E5_VLJUROS - SE5TMP->E5_VLACRES)
		      Endif   
		   Endif
		Else            
		   TMPSE5->E5_VALOR  := nValor-SE5TMP->E5_VLACRES - SE5TMP->E5_VLJUROS
		Endif  
		
		// ********* INICIO  WILL chamado 028902  ************ //
		IF nValor <> 0 .AND. (SE5TMP->E5_VLDECRE <> 0 .OR. SE5TMP->E5_VLDESCO <> 0)
	       IF SE5TMP->E5_VLDECRE == SE5TMP->E5_VLDESCO
	          TMPANL->VALORSE2 -= SE5TMP->E5_VLDECRE
	       Else
	          	IF SE5TMP->E5_VLDESCO > SE5TMP->E5_VLDECRE
		       		
		       		IF SE5TMP->E5_VLDESCO == SE5TMP->E5_VLJUROS
			       	  	TMPANL->VALORSE2 -= SE5TMP->E5_VLDESCO - SE5TMP->E5_VLJUROS
			       	ELSE
			        	TMPANL->VALORSE2 -= SE5TMP->E5_VLDESCO
			        ENDIF	
	       			
	       		ELSEIF SE5TMP->E5_VLDESCO == 0 .AND. SE5TMP->E5_VLDECRE > 0	
		          
		          	TMPANL->VALORSE2 := TMPANL->VALORSE2	
	       			
	          	ELSE	
	          
	          		TMPANL->VALORSE2 -= SE5TMP->E5_VLDECRE + SE5TMP->E5_VLDESCO
	          
	          	ENDIF
	       Endif  
	    
	    ELSEIF nValor == 0 .AND. SE5TMP->E5_VLDESCO > 0
		    
		    	TMPANL->VALORSE2 -= SE5TMP->E5_VLDESCO   
	       
	    Endif   
		// ********* FINAL  WILL chamado 028902  ************ // 
		
		//TMPSE5->E5_VALOR   := SE5TMP->E5_VALOR-SE5TMP->E5_VLACRES
		TMPSE5->E5_RECPAG  := SE5TMP->E5_RECPAG
		TMPSE5->E5_MOTBX   := SE5TMP->E5_MOTBX
		TMPSE5->E5_TIPODOC := SE5TMP->E5_TIPODOC	
		MsUnLock()
	
		SE5TMP->(dbSkip())
	Enddo
	
	dbselectArea("CT2TMP")
	DbgoTop()             
	While CT2TMP->(!EOF())
	        
		RecLock("TMPCT2",.T.)	
		TMPCT2->CT2_CLIFOR := CT2TMP->CT2_CLIFOR
		TMPCT2->CT2_LOJACF := CT2TMP->CT2_LOJACF
		TMPCT2->CT2_VALOR  := CT2TMP->CT2_VALOR
		TMPCT2->CT2_DEBITO := CT2TMP->CT2_DEBITO
		TMPCT2->CT2_CREDIT := CT2TMP->CT2_CREDIT		
		MsUnLock()
	
		CT2TMP->(dbSkip())
	Enddo
	
	//Impressao
	dbSelectArea("SA2TMP")
	dbGoTop()
	While SA2TMP->(!EOF())
		If nLin > 65
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif
		     
		lEntrou := .F.	
		nSldFin := 0
		dbselectArea("TMPSE2")
		dbSetOrder(1)
		DbgoTop()    
		dbSeek(SA2TMP->A2_COD+SA2TMP->A2_LOJA)
		While TMPSE2->(!EOF()) .And. SA2TMP->A2_COD == TMPSE2->E2_FORNECE .And. SA2TMP->A2_LOJA == TMPSE2->E2_LOJA
			
			lEntrou := .T.
			nSldFin := TMPSE2->E2_VALOR
			nTotSE2 += TMPSE2->E2_VALOR
			dbselectArea("TMPSE5")
			dbSetOrder(1)
			DbgoTop()
			dbSeek(SA2TMP->A2_COD+SA2TMP->A2_LOJA)
			While TMPSE5->(!EOF()) .And. SA2TMP->A2_COD == TMPSE5->E5_CLIFOR .And. SA2TMP->A2_LOJA == TMPSE5->E5_LOJA
				If Alltrim(TMPSE5->E5_TIPODOC) == "ES" .And. Alltrim(TMPSE5->E5_RECPAG) == "R"
					nSldFin += TMPSE5->E5_VALOR
					nTotSE2 += TMPSE5->E5_VALOR
				ElseIf Alltrim(TMPSE5->E5_TIPODOC) == "MT" .And. Alltrim(TMPSE5->E5_RECPAG) == "P"
					nSldFin += TMPSE5->E5_VALOR
					nTotSE2 += TMPSE5->E5_VALOR
				Else
					nSldFin -= TMPSE5->E5_VALOR
					nTotSE2 -= TMPSE5->E5_VALOR
				Endif	
				TMPSE5->(dbSkip())
			Enddo	
		
			TMPSE2->(dbSkip())
		Enddo	
		      
		nSldCon := 0
		dbselectArea("TMPCT2")
		dbSetOrder(1)
		DbgoTop()
		dbSeek(SA2TMP->A2_COD+SA2TMP->A2_LOJA)
		While TMPCT2->(!EOF()) .And. SA2TMP->A2_COD == TMPCT2->CT2_CLIFOR .And. SA2TMP->A2_LOJA == TMPCT2->CT2_LOJACF
			If Alltrim(TMPCT2->CT2_DEBITO) == Alltrim(mv_par09)//"211110001"
				lEntrou := .T.
				nSldCon -= TMPCT2->CT2_VALOR
				nTotCT2 -= TMPCT2->CT2_VALOR
			ElseIf Alltrim(TMPCT2->CT2_CREDIT) == Alltrim(mv_par09)//"211110001"
				lEntrou := .T.		
				nSldCon += TMPCT2->CT2_VALOR
				nTotCT2 += TMPCT2->CT2_VALOR				
			Endif
			TMPCT2->(dbSkip())
		Enddo	
		            
		If lEntrou
			@nLin,000 Psay SA2TMP->A2_COD
			@nLin,008 Psay SA2TMP->A2_LOJA
			@nLin,015 Psay Substr(SA2TMP->A2_NOME,1,30)
			@nLin,052 Psay nSldFin PICTURE "@E 999,999,999.99"		
			@nLin,072 Psay nSldCon PICTURE "@E 999,999,999.99" 
			If nSldFin > 0 .and. nSldCon > 0
				@nLin,090 Psay nSldFin-nSldCon PICTURE "@E 999,999,999.99"	
			Else
				@nLin,090 Psay nSldFin+nSldCon PICTURE "@E 999,999,999.99"			
			Endif			
				
			nLin += 1		
		Endif			        			
	    
		SA2TMP->(dbSkip())
	Enddo
	
	nLin += 1
	@nLin,000 Psay "Total Geral"
	@nLin,052 Psay nTotSE2 PICTURE "@E 999,999,999.99"
	@nLin,072 Psay nTotCT2 PICTURE "@E 999,999,999.99"
	If nTotSE2 > 0 .and. nTotCT2 > 0
		@nLin,090 Psay nTotSE2-nTotCT2 PICTURE "@E 999,999,999.99"
	Else
		@nLin,090 Psay nTotSE2+nTotCT2 PICTURE "@E 999,999,999.99"
	Endif	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fDados    ³ Autor ³ Luana Ferrari      º Data ³  06/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±S±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fDados()

	Local cQuery:=""
	
	If Select("SA2TMP") > 0
		DbSelectArea("SA2TMP")
		DbCloseArea("SA2TMP")
	Endif
	
	cQuery:=" SELECT A2_COD,A2_LOJA,A2_NOME "
	cQuery+=" FROM " + RetSqlName("SA2") + " WITH(NOLOCK) "
	cQuery+=" WHERE D_E_L_E_T_ <> '*' " 
	
	TCQUERY cQuery NEW ALIAS "SA2TMP"
	
	dbselectArea("SA2TMP")
	DbgoTop() 
	
	If Select("SE2TMP") > 0
		DbSelectArea("SE2TMP")
		DbCloseArea("SE2TMP")
	Endif
	
	//If mv_par08 == 1 //Analitico
		//cQuery:=" SELECT E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,E2_VALOR AS E2_VALOR, E2_EMIS1 " //INICIO Chamado Interno TI - Abel Babini - Considerar valor da correção monetária passiva abatendo do valor do título - 02/07/2019
		cQuery:=" SELECT E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,IIF(E2_MOEDA<>'1',E2_VLCRUZ,E2_VALOR) AS E2_VALOR, E2_EMIS1 " //INICIO Chamado Interno TI - Abel Babini - Considerar valor da correção monetária passiva abatendo do valor do título - 02/07/2019
		cQuery+=" FROM " + RetSqlName("SE2") + " WITH(NOLOCK) "
		cQuery+=" WHERE E2_EMIS1 BETWEEN '" + DTOS(mv_par05) + "' AND '" + DTOS(mv_par06) + "'"
		cQuery+=" AND D_E_L_E_T_ <> '*' "  
		cQuery+=" AND E2_FORNECE BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"	
		cQuery+=" AND E2_LOJA BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"   			
		//Ticket 8797 - Leonardo P. Monteiro - 02/07/2019 - Inclusão de parâmetro de exceção para exclusão de fornecedores (Governos, Prefeiuras e etc...) e tipos de títulos.
		//cQuery+=" AND E2_TIPO <> 'NDF' "	
		cQuery+=" AND E2_TIPO NOT IN "+ cTpExc +" "
		cQuery+=" AND E2_FORNECE NOT IN "+ cFoExc +" "
		cQuery+=" AND E2_CREDIT = '" + Alltrim(mv_par09) + "' "	
		/*
		If !Alltrim(mv_par10) == "XXX"
			cQuery+=" AND E2_PREFIXO <> 'RJ' "	
		Endif
		*/
		cQuery+=" ORDER BY E2_FORNECE,E2_LOJA,E2_EMIS1 "
	
	TCQUERY cQuery NEW ALIAS "SE2TMP"
	
	dbselectArea("SE2TMP")
	DbgoTop()
	
	If Select("SE5TMP") > 0
		DbSelectArea("SE5TMP")
		DbCloseArea("SE5TMP")
	Endif
	     
	//If mv_par08 == 1 //Analitico
		cQuery:=" SELECT E5_FILIAL,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_MOEDA,E5_TXMOEDA,E5_VLMOED2,E5_TIPO,E5_CLIFOR,E5_LOJA,E5_DATA,E5_VALOR,E5_TIPODOC,E5_RECPAG, "
		cQuery+=" 		  E5_MOTBX,E5_VLACRES, E5_VLDECRE,	E5_VLDESCO, E5_VLJUROS "
		cQuery+=" FROM " + RetSqlName("SE5") + " WITH(NOLOCK) "
		cQuery+=" WHERE D_E_L_E_T_ <> '*' "
		cQuery+=" AND E5_CLIFOR BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
		cQuery+=" AND E5_LOJA BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"				
		cQuery+=" AND E5_SITUACA <> 'C' "	
		cQuery+=" AND E5_DATA <= '" + DTOS(mv_par07) + "' "
		cQuery+=" AND E5_DATA BETWEEN '" + DTOS(mv_par05) + "' AND '" + DTOS(mv_par06) + "'"
		cQuery+=" AND E5_TIPO+E5_TIPODOC+E5_MOTBX <> 'PA BACMP' "
		cQuery+=" AND E5_TIPO+E5_TIPODOC+E5_RECPAG <> 'PA VLR' "
		cQuery+=" AND E5_TIPO+E5_TIPODOC+E5_RECPAG <> 'PA BAR' "	
		cQuery+=" AND E5_TIPO+E5_TIPODOC+E5_MOTBX <> 'PA ESCMP' "	
		cQuery+=" AND E5_TIPODOC+E5_RECPAG <> 'JRP' "	
		//Ticket 8797 - Leonardo P. Monteiro - 02/07/2019 - Inclusão de parâmetro de exceção para exclusão de fornecedores (Governos, Prefeiuras e etc...) e tipos de títulos.
		//cQuery+=" AND E5_TIPO <> 'NDF' "
		cQuery+=" AND E5_TIPO NOT IN "+ cTpExc +" "
		cQuery+=" AND E5_CLIFOR NOT IN "+ cFoExc +" "
		cQuery+=" AND E5_TIPODOC <> 'DC' "	//Chamado 028902     
		/*
		If !Alltrim(mv_par10) == "XXX"
			cQuery+=" AND E5_PREFIXO <> 'RJ' "	
		Endif
		*/	
	//	cQuery+=" AND E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA "
	//	cQuery+=" IN (  "
	//	cQuery+=" SELECT E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA FROM " +  RetSqlName("SE2")
	//  DESABILITADO POR ADRIANA EM 13/01/14
		cQuery+=" AND E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA "  //retirada filial
		cQuery+=" IN (  "
		cQuery+=" SELECT E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA FROM " +  RetSqlName("SE2") + " WITH(NOLOCK) "   //retirada filial
		cQuery+=" WHERE E2_EMIS1 BETWEEN '" + DTOS(mv_par05) + "' AND '" + DTOS(mv_par06) + "'"
		cQuery+=" AND D_E_L_E_T_ <> '*' "
		cQuery+=" AND E2_FORNECE BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
		cQuery+=" AND E2_LOJA BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"	
		//Ticket 8797 - Leonardo P. Monteiro - 02/07/2019 - Inclusão de parâmetro de exceção para exclusão de fornecedores (Governos, Prefeiuras e etc...) e tipos de títulos.
		//cQuery+=" AND E2_TIPO <> 'NDF' "	
		cQuery+=" AND E2_TIPO NOT IN "+ cTpExc +" "
		cQuery+=" AND E2_FORNECE NOT IN "+ cFoExc +" "	
		cQuery+=" AND E2_CREDIT = '" + Alltrim(mv_par09) + "' "	 	
		/*
		If !Alltrim(mv_par10) == "XXX"
			cQuery+=" AND E2_PREFIXO <> 'RJ' "	
		Endif
		*/	
		cQuery+=" ) "
		cQuery+=" ORDER BY E5_CLIFOR,E5_LOJA,E5_DATA,E5_RECPAG "	
	
	TCQUERY cQuery NEW ALIAS "SE5TMP"
	
	dbselectArea("SE5TMP")
	DbgoTop()
	
	If Select("CT2TMP") > 0
		DbSelectArea("CT2TMP")
		DbCloseArea("CT2TMP")
	Endif
	      
	//If mv_par08 == 1 //Analitico
		cQuery:=" SELECT CT2_FILKEY,CT2_PREFIX,CT2_NUMDOC,CT2_PARCEL,CT2_TIPODC,CT2_CLIFOR,CT2_LOJACF,CT2_VALOR,CT2_DEBITO,CT2_CREDIT,CT2_DATA "
		cQuery+=" FROM " + RetSqlName("CT2") + " WITH(NOLOCK) "
		cQuery+=" WHERE D_E_L_E_T_ <> '*' "
		cQuery+=" AND CT2_DATA BETWEEN '" + DTOS(mv_par05) + "' AND '" + DTOS(mv_par06) + "' "	
		//cQuery+=" AND (CT2_DEBITO = '211110001' OR CT2_CREDIT = '211110001') "
		cQuery+=" AND (CT2_DEBITO = '" + Alltrim(mv_par09) + "' OR CT2_CREDIT = '" + Alltrim(mv_par09) + "') "
		cQuery+=" AND CT2_CLIFOR BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
		cQuery+=" AND CT2_LOJACF BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
		cQuery+=" AND CT2_CLIFOR <> '' "	
		//cQuery+=" AND CT2_CLIFOR NOT IN " + FormatIn(mv_par09,",") 
		//cQuery+=" AND CT2_CLIFOR NOT IN " + FormatIn(mv_par11,",")	
		//cQuery+=" AND CT2_CLIFOR NOT IN " + FormatIn(mv_par12,",")
		//cQuery+=" AND CT2_CLIFOR NOT IN " + FormatIn(mv_par13,",")
		//cQuery+=" AND CT2_CLIFOR NOT IN " + FormatIn(mv_par14,",")
		//cQuery+=" AND CT2_TIPODC <> 'NDF' "
		//cQuery+=" AND CT2_TIPODC NOT IN " + FormatIn(mv_par15,",")				
		cQuery+=" ORDER BY CT2_CLIFOR,CT2_LOJACF,CT2_DATA "	
	
	TCQUERY cQuery NEW ALIAS "CT2TMP"
	
	dbselectArea("CT2TMP")
	DbgoTop()

Return
