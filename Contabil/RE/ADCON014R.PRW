#INCLUDE "protheus.ch"     
#INCLUDE "topconn.ch"

/*/{Protheus.doc} User Function ADCON014R
	Relatorio de conciliacao para adiantamento de fornecedores.
	@type  Function
	@author Fernando Macieira
	@since 10/10/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history Chamado 053685 - FWNM          - 29/11/2019 - NÃO POSSUI UMA CAPA, QUE IGUAL AO DE FORNECEDORES, CLIENTES E NCC, VEM NA PRIMEIRA PAGINA MOSTRANDO OS PARAMETROS UTILIZADOS
	@history Chamado 053840 - WILLIAM COSTA - 06/12/2019 - Identificado que na parte do if do estorno estava verificando se o estorno vinha do receber e nesse caso de adiantamento é do pagar, alterado o if e calculou corretamente 
	@history Chamado 054117 - WILLIAM COSTA - 19/12/2019 - Identificado que na parte do if do estorno foi retirado o recebimento e colocado o a pagar mais na verdade tem que ser os dois, foi feito o ajuste,
	@history Chamado 058316 - FWNM          - 11/06/2020 - OS 059792 || CONTROLADORIA || MONIK_MACEDO || 11996108893 || ADTCON014R
    @history ticket   15042 - Fernando Maci - 07/06/2021 - esta trazendo o valor da moeda em euro
/*/
User Function ADCON014R()
    
	// Chamado n. 053685 || OS 055110 || CONTROLADORIA || MONIK_MACEDO || 8956 || RELATORIO DA MONIK - FWNM - 29/11/2019
	//Local cPerg := "ADCON014R"
	Private cPerg := "ADCON014R"
	//

	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 220
	Private tamanho      := "G"
	Private nomeprog     := cPerg
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := cPerg
	Private nLin         := 80
	
	Private cString      := "SE5"

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	cPerg   := PadR(cPerg,Len(SX1->X1_GRUPO))

	u_xPutSx1(cPerg,"01","Do Fornecedor          ?","Do Fornecedor          ?","Do Fornecedor          ?","mv_ch1","C",6 ,0,0,"G",""         ,"SA2","","","mv_par01",""      ,"","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg,"02","Ate Fornecedor         ?","Ate Fornecedor         ?","Ate Fornecedor         ?","mv_ch2","C",6 ,0,0,"G",""         ,"SA2","","","mv_par02",""      ,"","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg,"03","Loja de                ?","Loja de                ?","Loja de                ?","mv_ch3","C",2 ,0,0,"G",""         ,"","","","mv_par03",""      ,"","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg,"04","Loja Ate               ?","Loja Ate               ?","Loja Ate               ?","mv_ch4","C",2 ,0,0,"G",""         ,"","","","mv_par04",""      ,"","","","","","","","","","","","","","","")
	u_xPutSX1(cPerg,"05","Data Contabil De        ","Data Contabil De        ","Data Contabil De        ","mv_ch5","D",08,0,0,"G","",""   ,"","","mv_par05" ,"","","","","","","","","","","","","","",""," ")
	u_xPutSX1(cPerg,"06","Data Contabil Ate       ","Data Contabil Ate       ","Data Contabil Ate       ","mv_ch6","D",08,0,0,"G","",""   ,"","","mv_par06" ,"","","","","","","","","","","","","","",""," ")
	u_xPutSX1(cPerg,"07","Data Base               ","Data Base               ","Data Base               ","mv_ch7","D",08,0,0,"G","",""   ,"","","mv_par07" ,"","","","","","","","","","","","","","",""," ")
	u_xPutSX1(cPerg,"08","Tipo Relatorio          ","Tipo Relatorio          ","Tipo Relatorio          ","mv_ch8","N",01,0,01,"C","","","","","mv_par08" ,"Analitico","Analitico","Analitico","","Sintetico","Sintetico","Sintetico","","","","","","","",""," ")
	u_xPutSx1(cPerg,"09","Conta Contabil         ?","Conta Contabil          ?","Conta Contabil         ?","mv_ch9","C",20 ,0,0,"G",""         ,"CT1","","","mv_par09",""      ,"","","","","","","","","","","","","","","")
	
	Pergunte(cPerg,.F.)
	
	cDesc1       := "Este programa tem como objetivo imprimir relatorio "
	cDesc2       := "de conciliacao dos adiantamentos de fornecedores."
	cDesc3       := "Conciliacao de Adiantamento de Fornecedores"
	cPict        := ""
	titulo       := "Conciliacao de Adiantamento de Fornecedores"
	Cabec1       := ""
	Cabec2       := ""
	imprime      := .T.
	aOrd         := {}

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

Return


/*/{Protheus.doc} Static Function RunReport
	(long_description)
	@type  Static Function
	@author FWNM
	@since 10/10/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem
	Local _aStr1   := {}
	Local _aStr2   := {}
	Local _aStr3   := {}
	
	dbSelectArea(cString)
	dbSetOrder(1)
	
	SetRegua(RecCount())
	              
	If mv_par08 == 1 //Analitico
		//Cabec1  := "FORNECEDOR                                FILIAL PREFIXO NUMERO  PARCELA TIPO   DT EMISSAO    DT MOVIMENTO    DT CONTABIL    SLD FINANC       SLD CONTABIL         DIFERENCA     "
		Cabec1  := "FORNECEDOR                                FILIAL PREFIXO NUMERO  PARCELA TIPO MOTBX  DT EMISSAO    DT MOVIMENTO    DT CONTABIL             SLD FINANC       SLD CONTABIL        DIFERENCA     "
	Else
		Cabec1  := "FORNECEDOR     RAZAO SOCIAL                         SLD FINANCEIRO        SLD CONTABIL         DIFERENCA     "
	Endif	
	Cabec2  := " "
	
	//³ Monta Querys                                      ³
	fDados() 
	    
	//³ Tabelas Temporarias                               ³
	
	//Tabela Temporaria SE2
	AADD(_aStr1,{'E2_FORNECE'  ,"C",06})
	AADD(_aStr1,{'E2_LOJA'    ,"C",02})
	AADD(_aStr1,{'E2_VALOR'   ,"N",15,04})
	If mv_par08 == 1 //Analitico
		AADD(_aStr1,{'E2_EMIS1'   ,"D",08,0})
	Endif
	
	_cArqTmp :=CriaTrab(_aStr1,.T.)
	DbUseArea(.T.,,_cArqTmp,"TMPSE2",.F.,.F.)
	_cIndex:="E2_FORNECE+E2_LOJA"
	IndRegua("TMPSE2",_cArqTmp,_cIndex,,,"Criando Indices...")          
	                   
	//Tabela Temporaria SE5
	AADD(_aStr2,{'E5_CLIFOR'  ,"C",06})
	AADD(_aStr2,{'E5_LOJA'    ,"C",02})
	AADD(_aStr2,{'E5_VALOR'   ,"N",15,04})
	AADD(_aStr2,{'E5_RECPAG'  ,"C",01})
	AADD(_aStr2,{'E5_MOTBX'   ,"C",03})
	AADD(_aStr2,{'E5_TIPODOC' ,"C",02})
	AADD(_aStr2,{'E5_VLACRES' ,"N",15,04})
	If mv_par08 == 1 //Analitico
		AADD(_aStr2,{'E5_DATA'   ,"D",08,0})
	Endif
	AADD(_aStr2,{'E5_VLDECRE' ,"N",15,04}) 
	AADD(_aStr2,{'E5_VLDESCO' ,"N",15,04}) 
	
	_cArqTmp :=CriaTrab(_aStr2,.T.)
	DbUseArea(.T.,,_cArqTmp,"TMPSE5",.F.,.F.)
	_cIndex:="E5_CLIFOR+E5_LOJA"
	IndRegua("TMPSE5",_cArqTmp,_cIndex,,,"Criando Indices...")
	         
	//Tabela Temporaria CT2                              
	AADD(_aStr3,{'CT2_CLIFOR'  ,"C",06})
	AADD(_aStr3,{'CT2_LOJACF'  ,"C",02})
	AADD(_aStr3,{'CT2_VALOR'   ,"N",15,04})    
	AADD(_aStr3,{'CT2_DEBITO'  ,"C",20})
	AADD(_aStr3,{'CT2_CREDIT'  ,"C",20})
	If mv_par08 == 1 //Analitico
		AADD(_aStr2,{'CT2_DATA'   ,"D",08,0})
	Endif
	
	_cArqTmp :=CriaTrab(_aStr3,.T.)
	DbUseArea(.T.,,_cArqTmp,"TMPCT2",.F.,.F.)
	_cIndex:="CT2_CLIFOR+CT2_LOJACF"
	IndRegua("TMPCT2",_cArqTmp,_cIndex,,,"Criando Indices...")
	
	nSldFin  := 0          
	nSldCon  := 0
	nTotFSE2 := 0 //Para o relatorio analitico - total por fornecedor
	nTotFCT2 := 0 //Para o relatorio analitico - total por fornecedor
	nTotSE2  := 0 //Total Geral
	nTotCT2  := 0 //Total Geral
	                                             
	fDadosAnl(Cabec1,Cabec2,Titulo,nLin)
	
	If Select("CT2TMP") > 0
		dbselectArea("CT2TMP")
		dbCloseArea()      
	EndIf
	
	If Select("SE5TMP") > 0
		dbselectArea("SE5TMP")
		dbCloseArea()  
	EndIf
	
	If Select("SE2TMP") > 0
		dbselectArea("SE2TMP")
		dbCloseArea()  
	EndIf
	
	If Select("SA2TMP") > 0
		dbselectArea("SA2TMP")
		dbCloseArea()
	EndIf
	
	If Select("TMPCT2") > 0
		dbselectArea("TMPCT2")
		dbCloseArea()
	EndIf
	
	If Select("TMPSE5") > 0
		dbselectArea("TMPSE5")
		dbCloseArea()
	EndIf
	
	If Select("TMPSE2") > 0
		dbselectArea("TMPSE2")
		dbCloseArea()
	EndIf
	
	If Select("TMPANL") > 0
		dbselectArea("TMPANL")
		dbCloseArea()
	EndIf
	
	SET DEVICE TO SCREEN
	
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	EndIf
	
	MS_FLUSH()

Return

/*/{Protheus.doc} Static Function fDadosAnl
	(long_description)
	@type  Static Function
	@author FWNM
	@since 10/10/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function fDadosAnl(Cabec1,Cabec2,Titulo,nLin)
                   
	Local _aStr4   := {} 
	
	//Tabela Temporaria para relatorio Analitico
	AADD(_aStr4,{'FORNECE'  ,"C",06})
	AADD(_aStr4,{'LOJA'     ,"C",02})
	AADD(_aStr4,{'VALORCT2' ,"N",15,04})
	AADD(_aStr4,{'VALORSE2' ,"N",15,04})	
	AADD(_aStr4,{'FILIAL'   ,"C",02})
	AADD(_aStr4,{'PREFIXO'  ,"C",03})
	AADD(_aStr4,{'NUMERO'   ,"C",09})
	AADD(_aStr4,{'PARCELA'  ,"C",03})
	AADD(_aStr4,{'TIPO'     ,"C",03})	
	AADD(_aStr4,{'DATASE2'  ,"D",08,0})	
	AADD(_aStr4,{'DATASE5'  ,"D",08,0})
	AADD(_aStr4,{'DATACT2'  ,"D",08,0})
	AADD(_aStr4,{'DEBITO'   ,"C",20})
	AADD(_aStr4,{'CREDIT'   ,"C",20})
	AADD(_aStr4,{'TIPODOC'  ,"C",02})			
	AADD(_aStr4,{'RECPAG'   ,"C",01})
	AADD(_aStr4,{'VLACRES'  ,"C",01})			

	AADD(_aStr4,{'MOTBX' ,"C",03}) // Chamado n. 058316 || OS 059792 || CONTROLADORIA || MONIK_MACEDO || 11996108893 || ADTCON014R - FWNM - 11/06/2020
	
	_cArqTmp :=CriaTrab(_aStr4,.T.)
	DbUseArea(.T.,,_cArqTmp,"TMPANL",.F.,.F.)
	_cIndex:="FORNECE+LOJA+FILIAL+NUMERO+PREFIXO+PARCELA+TIPO"
	IndRegua("TMPANL",_cArqTmp,_cIndex,,,"Criando Indices...")	
	
	dbselectArea("SE2TMP")
	dbGoTop()             
	Do While SE2TMP->( !EOF() )
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
	EndDo
	
	dbselectArea("SE5TMP")
	dbGoTop()             
	Do While SE5TMP->( !EOF() )

		RecLock("TMPANL",.T.)	
	
			TMPANL->FORNECE   := SE5TMP->E5_CLIFOR
			TMPANL->LOJA      := SE5TMP->E5_LOJA	
	
			If Alltrim(SE5TMP->E5_TIPODOC) == "ES" .And. (ALLTRIM(SE5TMP->E5_RECPAG) == "P" .OR. ALLTRIM(SE5TMP->E5_RECPAG) == "R") //chamado 053840 William Costa 06/12/2019 //chamado 054117 William Costa 19/12/2019
			    IF SE5TMP->E5_VLACRES <> 0
			       IF SE5TMP->E5_VLACRES == SE5TMP->E5_VLJUROS
	 		          TMPANL->VALORSE2 += SE5TMP->E5_VALOR-SE5TMP->E5_VLACRES
			       Else
			          TMPANL->VALORSE2 += SE5TMP->E5_VALOR-SE5TMP->E5_VLACRES - SE5TMP->E5_VLJUROS
			       Endif
			    Else   
				   TMPANL->VALORSE2 += SE5TMP->E5_VALOR-SE5TMP->E5_VLACRES - SE5TMP->E5_VLJUROS
				Endif   
				
				IF SE5TMP->E5_VALOR <> 0 .AND. (SE5TMP->E5_VLDECRE <> 0 .OR. SE5TMP->E5_VLDESCO <> 0)
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
			    
			    ELSEIF SE5TMP->E5_VALOR == 0 .AND. SE5TMP->E5_VLDESCO > 0
			    
			    	TMPANL->VALORSE2 += SE5TMP->E5_VLDESCO
			       
			    Endif   
				
			ElseIf Alltrim(SE5TMP->E5_TIPODOC) == "MT" .And. Alltrim(SE5TMP->E5_RECPAG) == "P"
				TMPANL->VALORSE2 += SE5TMP->E5_VALOR
			
			ElseIf Alltrim(SE5TMP->E5_TIPODOC) == "CM" .And. Alltrim(SE5TMP->E5_RECPAG) == "P"
				TMPANL->VALORSE2 -= ABS(SE5TMP->E5_VALOR)
			
			Else
		    	IF SE5TMP->E5_VLACRES <> 0
			       IF SE5TMP->E5_VLACRES == SE5TMP->E5_VLJUROS
			          TMPANL->VALORSE2 -= SE5TMP->E5_VALOR-SE5TMP->E5_VLACRES
			       Else
			          TMPANL->VALORSE2 -= SE5TMP->E5_VALOR-SE5TMP->E5_VLACRES - SE5TMP->E5_VLJUROS
			       Endif
			    Else   
				   TMPANL->VALORSE2 -= SE5TMP->E5_VALOR-SE5TMP->E5_VLACRES - SE5TMP->E5_VLJUROS
				Endif  
				
				IF SE5TMP->E5_VALOR <> 0 .AND. (SE5TMP->E5_VLDECRE <> 0 .OR. SE5TMP->E5_VLDESCO <> 0)
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
			       
				ELSEIF SE5TMP->E5_VALOR == 0 .AND. SE5TMP->E5_VLDESCO > 0
			    
			    	TMPANL->VALORSE2 -= SE5TMP->E5_VLDESCO
			    			       
			    Endif   
			    
			    If AllTrim(SE5TMP->E5_TIPODOC) == "PA" .and. AllTrim(SE5TMP->E5_RECPAG) == "P"
			    	TMPANL->VALORSE2 := TMPANL->VALORSE2 * -1
			    EndIf
				 
			Endif		

			TMPANL->FILIAL     := SE5TMP->E5_FILIAL	
			TMPANL->PREFIXO    := SE5TMP->E5_PREFIXO
			TMPANL->NUMERO     := SE5TMP->E5_NUMERO
			TMPANL->PARCELA    := SE5TMP->E5_PARCELA
			TMPANL->TIPO       := SE5TMP->E5_TIPO
			TMPANL->DATASE5    := STOD(SE5TMP->E5_DATA)
			TMPANL->RECPAG     := SE5TMP->E5_RECPAG
			TMPANL->TIPODOC    := SE5TMP->E5_TIPODOC

			TMPANL->MOTBX      := SE5TMP->E5_MOTBX // Chamado n. 058316 || OS 059792 || CONTROLADORIA || MONIK_MACEDO || 11996108893 || ADTCON014R - FWNM - 11/06/2020

		MsUnLock()
	
		SE5TMP->(dbSkip())

	Enddo	
	
	dbSelectArea("CT2TMP")
	dbGoTop()             
	Do While CT2TMP->( !EOF() )
	
		dbSelectArea("TMPANL")
		dbSetOrder(1)
		dbGoTop()
		
		RecLock("TMPANL",.T.)	
			TMPANL->FORNECE   := CT2TMP->CT2_CLIFOR
			TMPANL->LOJA      := CT2TMP->CT2_LOJACF

			If Alltrim(CT2TMP->CT2_DEBITO) == Alltrim(mv_par09)
				TMPANL->VALORCT2 += CT2TMP->CT2_VALOR
			ElseIf Alltrim(CT2TMP->CT2_CREDIT) == Alltrim(mv_par09)
				TMPANL->VALORCT2 -= CT2TMP->CT2_VALOR
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
	Do While SA2TMP->( !EOF() )
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
			
			IF MV_PAR08 == 1 //Analitico                                                                

				@nLin,042 Psay TMPANL->FILIAL
				@nLin,049 Psay TMPANL->PREFIXO
				@nLin,057 Psay TMPANL->NUMERO
				@nLin,066 Psay TMPANL->PARCELA			
				@nLin,074 Psay TMPANL->TIPO

				@nLin,079 Psay TMPANL->MOTBX // Chamado n. 058316 || OS 059792 || CONTROLADORIA || MONIK_MACEDO || 11996108893 || ADTCON014R - FWNM - 12/06/2020

				If ALLTRIM(DTOS(TMPANL->DATASE2)) <> ""
					@nLin,086 Psay TMPANL->DATASE2
				Endif
				If ALLTRIM(DTOS(TMPANL->DATASE5)) <> ""			
					@nLin,100 Psay TMPANL->DATASE5 
				Endif
				If ALLTRIM(DTOS(TMPANL->DATACT2)) <> ""	
					@nLin,115 Psay TMPANL->DATACT2 		
				Endif	
				@nLin,135 Psay TMPANL->VALORSE2 PICTURE "@E 999,999,999.99"			
				@nLin,151 Psay TMPANL->VALORCT2 PICTURE "@E 999,999,999.99"
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
				@nLin,135 Psay nTotFSE2 PICTURE "@E 999,999,999.99"
				@nLin,151 Psay nTotFCT2 PICTURE "@E 999,999,999.99"
				If nTotFSE2 > 0 .and. nTotFCT2 > 0
					@nLin,169 Psay nTotFSE2-nTotFCT2 PICTURE "@E 999,999,999.99"		
				Else
					@nLin,169 Psay nTotFSE2+nTotFCT2 PICTURE "@E 999,999,999.99"
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
	
	If MV_PAR08 == 1 // ANALITICO
	
		nLin += 1
		@nLin,000 Psay "Total Geral"
		@nLin,135 Psay nTotSE2 PICTURE "@E 999,999,999.99"
		@nLin,151 Psay nTotCT2 PICTURE "@E 999,999,999.99"
		If nTotSE2 > 0 .and. nTotCT2 > 0
			@nLin,169 Psay nTotSE2-nTotCT2 PICTURE "@E 999,999,999.99"	
		Else
			@nLin,169 Psay nTotSE2+nTotCT2 PICTURE "@E 999,999,999.99"	
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

/*/{Protheus.doc} Static Function fDados
	(long_description)
	@type  Static Function
	@author FWNM
	@since 10/10/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function fDados()

	Local cQuery := ""
	
	// Carrego fornecedores
	If Select("SA2TMP") > 0
		DbSelectArea("SA2TMP")
		DbCloseArea("SA2TMP")
	Endif
	
	cQuery := " SELECT A2_COD,A2_LOJA,A2_NOME "
	cQuery += " FROM " + RetSqlName("SA2") + " WITH(NOLOCK) "
	cQuery += " WHERE D_E_L_E_T_='' " 
	cQuery += " AND A2_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"	
	cQuery += " AND A2_LOJA BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"   			
	
	TCQUERY cQuery NEW ALIAS "SA2TMP"
	
	// Carrego Adiantamentos e Debitos de fornecedores
	If Select("SE2TMP") > 0
		SE2TMP->( dbCloseArea("SE2TMP") )
	EndIf
	
	cQuery := " SELECT E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,IIF(E2_MOEDA<>'01',E2_VLCRUZ,E2_VALOR) AS E2_VALOR, E2_EMIS1 "
	cQuery += " FROM " + RetSqlName("SE2") + " SE2 WITH (NOLOCK) "
	cQuery += " WHERE E2_EMIS1 BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "' "
	cQuery += " AND E2_FORNECE BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"	
	cQuery += " AND E2_LOJA BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"   			
	cQuery += " AND E2_TIPO IN ('NDF') "	
	cQuery += " AND SE2.D_E_L_E_T_='' "  

	// DEBUG
	//CQUERY += " AND E2_FILIAL='05'
	//CQUERY += " AND E2_NUM='8063'
	// DEBUG

	cQuery += " ORDER BY E2_FORNECE,E2_LOJA,E2_EMIS1 "
	
	tcQuery cQuery New Alias "SE2TMP"
	
	// Carrego Baixas e estornos dos Adiantamentos e Debitos de fornecedores
	If Select("SE5TMP") > 0
		SE5TMP->( dbCloseArea("SE5TMP") )
	EndIf
	     
	//cQuery := " SELECT E5_FILIAL,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_TIPO,E5_CLIFOR,E5_LOJA,E5_DATA,E5_VALOR,E5_TIPODOC,E5_RECPAG,E5_MOTBX,E5_VLACRES, E5_VLDECRE,	E5_VLDESCO, E5_VLJUROS, E5_MOTBX "
	cQuery := " SELECT E5_FILIAL,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_TIPO,E5_CLIFOR,E5_LOJA,E5_DATA, IIF(E5_MOEDA<>'01',E5_VLMOED2,E5_VALOR) AS E5_VALOR,E5_TIPODOC,E5_RECPAG,E5_MOTBX,E5_VLACRES, E5_VLDECRE,	E5_VLDESCO, E5_VLJUROS, E5_MOTBX " // @history ticket   15042 - Fernando Maci - 07/06/2021 - esta trazendo o valor da moeda em euro
	cQuery += " FROM " + RetSqlName("SE5") + " SE5 WITH (NOLOCK) "
	cQuery += " WHERE SE5.D_E_L_E_T_='' "
	cQuery += " AND E5_DATA <= '" + DtoS(MV_PAR07) + "' "
	cQuery += " AND E5_DATA BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "' "
	cQuery += " AND E5_CLIFOR BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	cQuery += " AND E5_LOJA BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "				
	cQuery += " AND E5_SITUACA <> 'C' "	
	cQuery += " AND E5_TIPO IN ('PA','NDF') "		

	// DEBUG
	//CQUERY += " AND E5_FILIAL='05'
	//CQUERY += " AND E5_NUMERO='8063'
	// DEBUG

	cQuery += " AND E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA "
	cQuery += " IN (  "
	cQuery += " SELECT E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA FROM " +  RetSqlName("SE2") + " SE2 WITH (NOLOCK) "
	cQuery += " WHERE E2_EMIS1 BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "'"
	cQuery += " AND E2_FORNECE BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
	cQuery += " AND E2_LOJA BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"	
	cQuery += " AND SE2.D_E_L_E_T_='' "
	cQuery += " ) "
	cQuery += " ORDER BY E5_CLIFOR,E5_LOJA,E5_DATA,E5_RECPAG "	
	
	tcQuery cQuery New Alias "SE5TMP"
	
	
	// Carrego contabilizacoes dos movimentos contabeis pela conta contabil (poderiamos utilizar CV3 PADRAO ou Indexadores = campos customizados na CT2)
	If Select("CT2TMP") > 0
		CT2TMP->( dbCloseArea("CT2TMP") )
	EndIf
	      
	cQuery := " SELECT CT2_FILKEY,CT2_PREFIX,CT2_NUMDOC,CT2_PARCEL,CT2_TIPODC,CT2_CLIFOR,CT2_LOJACF,CT2_VALOR,CT2_DEBITO,CT2_CREDIT,CT2_DATA "
	cQuery += " FROM " + RetSqlName("CT2") + " CT2 WITH (NOLOCK) "
	cQuery += " WHERE CT2.D_E_L_E_T_='' "
	cQuery += " AND CT2_DATA BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "' "	
	cQuery += " AND (CT2_DEBITO = '" + AllTrim(MV_PAR09) + "' OR CT2_CREDIT = '" + AllTrim(MV_PAR09) + "') "
	cQuery += " AND CT2_CLIFOR BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	cQuery += " AND CT2_LOJACF BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	cQuery += " AND CT2_CLIFOR <> '' "	
	cQuery += " AND CT2_PREFIX <> '' " // Não retirar! Campo que sera utilizado pela contabilidade para data de corte sem impactar o novo sig na rotina de de/para contábil. Definicao conjunta com Danielle Meira e Monik em 15/10/2019 	

	// DEBUG
	//CQUERY += " AND CT2_NUMDOC='8063'
	// DEBUG


	cQuery += " ORDER BY CT2_CLIFOR,CT2_LOJACF,CT2_DATA "	

	tcQuery cQuery New Alias "CT2TMP"
	
Return
