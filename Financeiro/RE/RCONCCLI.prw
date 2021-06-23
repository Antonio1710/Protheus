#INCLUDE "Protheus.ch"     
#INCLUDE "Topconn.ch"

/*/{Protheus.doc} User Function RCONCCLI
	Relatorio de conciliação de clientes
	@author Ana Helena
	@since 03/04/2014
	@version 01
	@history Chamado 049192 - Fernando Sigoli   - 16/05/2019 - Adiocnado tratamento para novos motivos de baixa BPQ , BCF
	@history Chamado 049192 - Fernando Sigoli   - 21/05/2019 - Adicionado tratamento para novos motivos de baixa DCP
	@history Chamado 054534 - William Costa     - 02/01/2020 - Adicionado tratamento para novos motivos de baixa JRDAC
	@history ticket     452 - FWNM              - 27/08/2020 - Alguns Títulos AB- não estão sendo listados
	@history ticket    3762 - FWNM              - 06/11/2020 - Conciliação automatica Safegg
	@history ticket    4665 - Fernando Macieira - 17/11/2020 - AB- Contabilização e Apontamento no Relatório de Conciliação de Clientes ocorrendo na data da baixa parcial
	@history ticket    5242 - Fernando Macieira - 19/11/2020 - Relatório De Conciliação Clientes - Coluna Financeiro Tipo REN
	@history ticket    5378 - Fernando Macieira - 19/11/2020 - Juros Bx Desconto em Folha não aparece Coluna Financeiro do Rel. de Conciliação de Clientes
	@history ticket    5212 - Fernando Macieira - 19/11/2020 - Baixa AB- Não Aparece no Relatório de Conciliação (Coluna Financeiro)
	@history ticket  8714 - Andre Mendes - Obify - 28/01/2021 - Adicionado tratamento para novos motivos
/*/
User Function RCONCCLI()

	cPerg   := PADR('RCONCLI',10," ")
	Pergunte(cPerg,.F.)
	cDesc1       := "Este programa tem como objetivo imprimir relatorio "
	cDesc2       := "de conciliacao de clientes."
	cDesc3       := "Conciliacao de Clientes
	cPict        := ""
	titulo       := "Conciliacao de Clientes
	Cabec1       := ""
	Cabec2       := ""
	imprime      := .T.
	aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 220
	Private tamanho      := "G"
	Private nomeprog     := "RCONCCLI"
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "RCONCCLI"
	Private nLin         := 80
	
	Private cString := "SE5"

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de conciliação de clientes')
	
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

/*/{Protheus.doc} Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	(long_description)
	@type  Function
	@author user
	@since 19/11/2020
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
		Cabec1  := "CLIENTE                                FILIAL PREFIXO NUMERO  PARCELA TIPO   DT EMISSAO    DT MOVIMENTO    DT CONTABIL    SLD FINANC       SLD CONTABIL         DIFERENCA     "
	Else
		Cabec1  := "CLIENTE     RAZAO SOCIAL                         SLD FINANCEIRO        SLD CONTABIL         DIFERENCA     "
	Endif	
	
	Cabec2  := " "
	
	// @history ticket 452 - FWNM - 28/08/2020 - Alguns Títulos AB- não estão sendo listados
	fE1DTDISPO()
	//

	fDados() 
	    
	//Tabela Temporaria SE1
	AADD(_aStr1,{'E1_CLIENTE'  ,"C",06})
	AADD(_aStr1,{'E1_LOJA'    ,"C",02})
	AADD(_aStr1,{'E1_VALOR'   ,"N",17,02})  // RICARDO LIMA - 27/11/17 | AJUSTE DE TAMANHO DE CAMPO
	If mv_par08 == 1 //Analitico
		AADD(_aStr1,{'E1_EMIS1'   ,"D",08,0})
	Endif
	     
	If Select("TMPSE1") > 0 
    	dbSelectArea("TMPSE1") 
     	dbCloseArea() 
	EndIf 
	 
	_cArqTmp :=CriaTrab(_aStr1,.T.)
	
	DbUseArea(.T.,,_cArqTmp,"TMPSE1",.F.,.F.)
	_cIndex:="E1_CLIENTE+E1_LOJA"
	IndRegua("TMPSE1",_cArqTmp,_cIndex,,,"Criando Indices...")          
	                   
	//Tabela Temporaria SE5
	AADD(_aStr2,{'E5_CLIFOR'  ,"C",06})
	AADD(_aStr2,{'E5_LOJA'    ,"C",02})
	AADD(_aStr2,{'E5_VALOR'   ,"N",17,02}) // RICARDO LIMA - 27/11/17 | AJUSTE DE TAMANHO DE CAMPO
	AADD(_aStr2,{'E5_RECPAG'  ,"C",01})
	AADD(_aStr2,{'E5_MOTBX'   ,"C",03})
	AADD(_aStr2,{'E5_TIPODOC' ,"C",02})
	AADD(_aStr2,{'E5_VLACRES' ,"N",17,02}) // RICARDO LIMA - 27/11/17 | AJUSTE DE TAMANHO DE CAMPO
	If mv_par08 == 1 //Analitico
		AADD(_aStr2,{'E5_DTDISPO'   ,"D",08,0})
	Endif
	
	If Select("TMPSE5") > 0 
    	dbSelectArea("TMPSE5") 
     	dbCloseArea() 
	EndIf 
	
	_cArqTmp :=CriaTrab(_aStr2,.T.)
	DbUseArea(.T.,,_cArqTmp,"TMPSE5",.F.,.F.)
	_cIndex:="E5_CLIFOR+E5_LOJA"
	IndRegua("TMPSE5",_cArqTmp,_cIndex,,,"Criando Indices...")
	         
	//Tabela Temporaria CT2                              
	AADD(_aStr3,{'CT2_CLIFOR'  ,"C",06})
	AADD(_aStr3,{'CT2_LOJACF'  ,"C",02})
	AADD(_aStr3,{'CT2_VALOR'   ,"N",16,02})     // RICARDO LIMA - 27/11/17 | AJUSTE DE TAMANHO DE CAMPO
	AADD(_aStr3,{'CT2_DEBITO'  ,"C",20})
	AADD(_aStr3,{'CT2_CREDIT'  ,"C",20})
	If mv_par08 == 1 //Analitico
		AADD(_aStr2,{'CT2_DATA'   ,"D",08,0})
	Endif
	       
	If Select("TMPCT2") > 0 
    	dbSelectArea("TMPCT2") 
     	dbCloseArea() 
	EndIf 
	
	_cArqTmp :=CriaTrab(_aStr3,.T.)
	DbUseArea(.T.,,_cArqTmp,"TMPCT2",.F.,.F.) 
	_cIndex:="CT2_CLIFOR+CT2_LOJACF"
	IndRegua("TMPCT2",_cArqTmp,_cIndex,,,"Criando Indices...")
	
	nSldFin  := 0          
	nSldCon  := 0
	nTotFSE1 := 0 //Para o relatorio analitico - total por CLIENTE
	nTotFCT2 := 0 //Para o relatorio analitico - total por CLIENTE
	nTotSE1  := 0 //Total Geral
	nTotCT2  := 0 //Total Geral
	                                             
	If mv_par08 == 1 //Analitico
		fDadosAnl(Cabec1,Cabec2,Titulo,nLin)
	Endif
	
	If mv_par08 <> 1 //Sintetico
		fDadosSin(Cabec1,Cabec2,Titulo,nLin)
	Endif
	
	dbCloseArea("CT2TMP")
	dbCloseArea("SE5TMP")
	dbCloseArea("SE1TMP")
	dbCloseArea("SA1TMP")
	dbCloseArea("TMPCT2")
	dbCloseArea("TMPSE5")
	dbCloseArea("TMPSE1")
	dbCloseArea("TMPANL")
	
	SET DEVICE TO SCREEN
	
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	
	MS_FLUSH()

Return

/*/{Protheus.doc} Static Function fDadosAnl(Cabec1,Cabec2,Titulo,nLin)
	Relatorio Analitico
	@type  Function
	@author user
	@since 19/11/2020
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
	AADD(_aStr4,{'CLIENTE'  ,"C",06})
	AADD(_aStr4,{'LOJA'     ,"C",02})
	AADD(_aStr4,{'VALORCT2' ,"N",16,02}) // RICARDO LIMA - 27/11/17 | AJUSTE DE TAMANHO DE CAMPO
	AADD(_aStr4,{'VALORSE1' ,"N",17,02}) // RICARDO LIMA - 27/11/17 | AJUSTE DE TAMANHO DE CAMPO
	AADD(_aStr4,{'FILIAL'   ,"C",02})
	AADD(_aStr4,{'PREFIXO'  ,"C",03})
	AADD(_aStr4,{'NUMERO'   ,"C",09})
	AADD(_aStr4,{'PARCELA'  ,"C",03})
	AADD(_aStr4,{'TIPO'     ,"C",03})	
	AADD(_aStr4,{'DATASE1'  ,"D",08,0})	
	AADD(_aStr4,{'DATASE5'  ,"D",08,0})
	AADD(_aStr4,{'DATACT2'  ,"D",08,0})
	AADD(_aStr4,{'DEBITO'   ,"C",20})
	AADD(_aStr4,{'CREDIT'   ,"C",20})
	AADD(_aStr4,{'TIPODOC'  ,"C",02})			
	AADD(_aStr4,{'RECPAG'   ,"C",01})
	AADD(_aStr4,{'VLACRES'  ,"C",01})			
	AADD(_aStr4,{'DATABAX'  ,"D",08,0})
	
	_cArqTmp :=CriaTrab(_aStr4,.T.)
	DbUseArea(.T.,,_cArqTmp,"TMPANL",.F.,.F.)
	
	//_cIndex:="CLIENTE+LOJA+FILIAL+PREFIXO+NUMERO+PARCELA+TIPO"
	_cIndex:="CLIENTE+LOJA+FILIAL+NUMERO+PREFIXO+PARCELA+TIPO"
	IndRegua("TMPANL",_cArqTmp,_cIndex,,,"Criando Indices...")	
	
	dbselectArea("SE1TMP")
	DbgoTop()             
	While SE1TMP->(!EOF())
	
	   	 	RecLock("TMPANL",.T.)	
				TMPANL->CLIENTE   := SE1TMP->E1_CLIENTE
				TMPANL->LOJA      := SE1TMP->E1_LOJA
				TMPANL->VALORSE1  := SE1TMP->E1_VALOR	
				TMPANL->FILIAL    := SE1TMP->E1_FILIAL	
				TMPANL->PREFIXO   := SE1TMP->E1_PREFIXO
				TMPANL->NUMERO    := SE1TMP->E1_NUM
				TMPANL->PARCELA   := SE1TMP->E1_PARCELA
				TMPANL->TIPO      := SE1TMP->E1_TIPO
				
				If SE1TMP->E1_TIPO <> 'AB-'                     //Para AB- nao mostrar data de emissao Sigoli Chamado 027642
					TMPANL->DATASE1   := STOD(SE1TMP->E1_EMIS1) //Data de emissao
				Else
					TMPANL->DATASE5   := STOD(SE1TMP->E1_XDTDISP)
				ENDIF
			MsUnLock()
		
		SE1TMP->(dbSkip())
		
	Enddo
	
	dbselectArea("SE5TMP")
	DbgoTop()             
	While SE5TMP->(!EOF())
	                          
		RecLock("TMPANL",.T.)	
		TMPANL->CLIENTE   := SE5TMP->E5_CLIFOR
		TMPANL->LOJA      := SE5TMP->E5_LOJA
			
		If Alltrim(SE5TMP->E5_TIPODOC) == "ES" .And. Alltrim(SE5TMP->E5_RECPAG) == "P"
			TMPANL->VALORSE1 += SE5TMP->E5_VALOR-SE5TMP->E5_VLACRES
		ElseIf Alltrim(SE5TMP->E5_TIPODOC) == "MT" .And. Alltrim(SE5TMP->E5_RECPAG) == "R"
			TMPANL->VALORSE1 += SE5TMP->E5_VALOR
		ElseIf (Alltrim(SE5TMP->E5_TIPODOC) == "JR" .OR. Alltrim(SE5TMP->E5_TIPODOC) == "J2") .And. Alltrim(SE5TMP->E5_RECPAG) == "R"
			TMPANL->VALORSE1 += SE5TMP->E5_VALOR		
		Else
			TMPANL->VALORSE1 -= SE5TMP->E5_VALOR-SE5TMP->E5_VLACRES
		Endif
				
		TMPANL->FILIAL     := SE5TMP->E5_FILIAL	
		TMPANL->PREFIXO    := SE5TMP->E5_PREFIXO
		TMPANL->NUMERO     := SE5TMP->E5_NUMERO
		TMPANL->PARCELA    := SE5TMP->E5_PARCELA
		TMPANL->TIPO       := SE5TMP->E5_TIPO
		TMPANL->DATASE5    := STOD(SE5TMP->E5_DTDISPO) //data diposnibilidade
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
	        
		RecLock("TMPANL",.T.)	
		TMPANL->CLIENTE   := CT2TMP->CT2_CLIFOR
		TMPANL->LOJA      := CT2TMP->CT2_LOJACF
		
		If Alltrim(CT2TMP->CT2_DEBITO) == Alltrim(mv_par09)//"211110001"
	//		TMPANL->VALORCT2  -= CT2TMP->CT2_VALOR //Alterado por Adriana em 01/10/2014 
			TMPANL->VALORCT2  += CT2TMP->CT2_VALOR
		ElseIf Alltrim(CT2TMP->CT2_CREDIT) == Alltrim(mv_par09)//"211110001"
	//		TMPANL->VALORCT2  += CT2TMP->CT2_VALOR//Alterado por Adriana em 01/10/2014	
			TMPANL->VALORCT2  -= CT2TMP->CT2_VALOR		
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
	dbSelectArea("SA1TMP")
	dbGoTop()
	While SA1TMP->(!EOF())
		If nLin > 65
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif
		
		lEntrou := .F. 	
		dbSelectArea("TMPANL")
		dbSetOrder(1)
		dbGoTop()
		dbSeek(SA1TMP->A1_COD+SA1TMP->A1_LOJA)
		While TMPANL->(!EOF()) .And. SA1TMP->A1_COD == TMPANL->CLIENTE .And. SA1TMP->A1_LOJA == TMPANL->LOJA
			
			If nLin > 65
		   		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		   		nLin := 8
		   	Endif		
			
			If !lEntrou
				lEntrou := .T.
				nTotFSE1 := 0
				nTotFCT2 := 0			
				@nLin,000 Psay SA1TMP->A1_COD
				@nLin,008 Psay SA1TMP->A1_LOJA				
				@nLin,012 Psay Substr(SA1TMP->A1_NOME,1,30)
			Endif	                                    				
			                                                                
			@nLin,045 Psay TMPANL->FILIAL
			@nLin,050 Psay TMPANL->PREFIXO
			@nLin,055 Psay TMPANL->NUMERO
			@nLin,067 Psay TMPANL->PARCELA			
			@nLin,073 Psay TMPANL->TIPO
			If ALLTRIM(DTOS(TMPANL->DATASE1)) <> ""
				@nLin,080 Psay TMPANL->DATASE1
			Endif
			
			If ALLTRIM(DTOS(TMPANL->DATASE5)) <> ""			
				@nLin,095 Psay TMPANL->DATASE5
			Endif
			 
			//Inicio - Sigoli Chamado 027642
			//If 	TMPANL->TIPO = 'AB-' .and. TMPANL->VALORSE1 <> 0     
			//	@nLin,095 Psay  STOD("") 
			//EndIF
			//Fim - Sigoli Chamado 027642
			
			If ALLTRIM(DTOS(TMPANL->DATACT2)) <> ""	
				@nLin,110 Psay TMPANL->DATACT2 		
			Endif	
			@nLin,120 Psay TMPANL->VALORSE1 PICTURE "@E 999,999,999,999.99"//15  
			@nLin,140 Psay TMPANL->VALORCT2 PICTURE "@E 999,999,999,999.99"
			nTotFSE1 += TMPANL->VALORSE1
			nTotFCT2 += TMPANL->VALORCT2
			
			nTotSE1 += TMPANL->VALORSE1
			nTotCT2 += TMPANL->VALORCT2					
			nLin += 1		
			TMPANL->(dbSkip())
		
		Enddo
			
		If lEntrou		
			If nLin > 65
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 8
			Endif		
		 
			nLin += 1		
			@nLin,000 Psay "Total CLIENTE"
			@nLin,120 Psay nTotFSE1 PICTURE "@E 999,999,999,999.99"
			@nLin,140 Psay nTotFCT2 PICTURE "@E 999,999,999,999.99"
			If nTotFSE1 > 0 .and. nTotFCT2 > 0
				@nLin,160 Psay nTotFSE1-nTotFCT2 PICTURE "@E 999,999,999,999.99"		
			Else
				@nLin,160 Psay nTotFSE1+nTotFCT2 PICTURE "@E 999,999,999,999.99"
			Endif	
			nLin += 2		
		Endif
		SA1TMP->(dbSkip())
	Enddo
	
	nLin += 1
	@nLin,000 Psay "Total Geral"
	@nLin,120 Psay nTotSE1 PICTURE "@E 999,999,999,999.99"
	@nLin,140 Psay nTotCT2 PICTURE "@E 999,999,999,999.99"
	If nTotSE1 > 0 .and. nTotCT2 > 0
		@nLin,160 Psay nTotSE1-nTotCT2 PICTURE "@E 999,999,999,999.99"	
	Else
		@nLin,160 Psay nTotSE1+nTotCT2 PICTURE "@E 999,999,999,999.99"	
	Endif	
    
    //
    dbCloseArea("TMPCT2")
	dbCloseArea("TMPSE5")
	dbCloseArea("TMPSE1")
	dbCloseArea("TMPANL")
	
Return

/*/{Protheus.doc} Static Function fDadosSin(Cabec1,Cabec2,Titulo,nLin)
	Relatorio Sintetico
	@type  Function
	@author user
	@since 19/11/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function fDadosSin(Cabec1,Cabec2,Titulo,nLin)
	
	dbselectArea("SE1TMP")
	DbgoTop()             
	While SE1TMP->(!EOF())
	        
		RecLock("TMPSE1",.T.)	
			TMPSE1->E1_CLIENTE := SE1TMP->E1_CLIENTE
			TMPSE1->E1_LOJA    := SE1TMP->E1_LOJA
			TMPSE1->E1_VALOR   := SE1TMP->E1_VALOR	
		MsUnLock()
		
		SE1TMP->(dbSkip())
	Enddo
	
	dbselectArea("SE5TMP")
	DbgoTop()             
	While SE5TMP->(!EOF())
	        
		RecLock("TMPSE5",.T.)	
			TMPSE5->E5_CLIFOR  := SE5TMP->E5_CLIFOR
			TMPSE5->E5_LOJA    := SE5TMP->E5_LOJA
			TMPSE5->E5_VALOR   := SE5TMP->E5_VALOR-SE5TMP->E5_VLACRES
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
	dbSelectArea("SA1TMP")
	dbGoTop()
	While SA1TMP->(!EOF())
	
		If nLin > 65
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif
		     
		lEntrou := .F.	
		nSldFin := 0
	
		dbselectArea("TMPSE1")
		dbSetOrder(1)
		DbgoTop()    
		dbSeek(SA1TMP->A1_COD+SA1TMP->A1_LOJA)
		While TMPSE1->(!EOF()) .And. SA1TMP->A1_COD == TMPSE1->E1_CLIENTE .And. SA1TMP->A1_LOJA == TMPSE1->E1_LOJA   
		
		 	lEntrou := .T.             
			nSldFin := TMPSE1->E1_VALOR
			nTotSE1 += TMPSE1->E1_VALOR
	
			dbselectArea("TMPSE5")
			dbSetOrder(1)
			DbgoTop()
			dbSeek(SA1TMP->A1_COD+SA1TMP->A1_LOJA)
			While TMPSE5->(!EOF()) .And. SA1TMP->A1_COD == TMPSE5->E5_CLIFOR .And. SA1TMP->A1_LOJA == TMPSE5->E5_LOJA
				If Alltrim(TMPSE5->E5_TIPODOC) == "ES" .And. Alltrim(TMPSE5->E5_RECPAG) == "P"
					nSldFin += TMPSE5->E5_VALOR
					nTotSE1 += TMPSE5->E5_VALOR
				ElseIf Alltrim(TMPSE5->E5_TIPODOC) == "MT" .And. Alltrim(TMPSE5->E5_RECPAG) == "R"
					nSldFin += TMPSE5->E5_VALOR
					nTotSE1 += TMPSE5->E5_VALOR			
				ElseIf (Alltrim(TMPSE5->E5_TIPODOC) == "JR" .OR. Alltrim(TMPSE5->E5_TIPODOC) == "J2") .And. Alltrim(TMPSE5->E5_RECPAG) == "R"
					nSldFin += TMPSE5->E5_VALOR
					nTotSE1 += TMPSE5->E5_VALOR			
				Else			
					nSldFin -= TMPSE5->E5_VALOR
					nTotSE1 -= TMPSE5->E5_VALOR
				Endif	
				TMPSE5->(dbSkip())
			Enddo	
		
			TMPSE1->(dbSkip())
	
		Enddo	
		      
		nSldCon := 0
		dbselectArea("TMPCT2")
		dbSetOrder(1)
		DbgoTop()
		dbSeek(SA1TMP->A1_COD+SA1TMP->A1_LOJA)
		While TMPCT2->(!EOF()) .And. SA1TMP->A1_COD == TMPCT2->CT2_CLIFOR .And. SA1TMP->A1_LOJA == TMPCT2->CT2_LOJACF
			If Alltrim(TMPCT2->CT2_DEBITO) == Alltrim(mv_par09)//"211110001"
				lEntrou := .T.
	  			nSldCon += TMPCT2->CT2_VALOR   // Verificar em 01/10/14
	  			nTotCT2 += TMPCT2->CT2_VALOR   // Verificar em 01/10/14
			ElseIf Alltrim(TMPCT2->CT2_CREDIT) == Alltrim(mv_par09)//"211110001"
				lEntrou := .T.		
	  			nSldCon -= TMPCT2->CT2_VALOR  // Verificar em 01/10/14
	  			nTotCT2 -= TMPCT2->CT2_VALOR  // Verificar em 01/10/14
			Endif
			TMPCT2->(dbSkip())
		Enddo	
		            
		If lEntrou
			@nLin,000 Psay SA1TMP->A1_COD
			@nLin,008 Psay SA1TMP->A1_LOJA
			@nLin,015 Psay Substr(SA1TMP->A1_NOME,1,30)
			@nLin,052 Psay nSldFin PICTURE "@E 999,999,999,999.99"		
			@nLin,072 Psay nSldCon PICTURE "@E 999,999,999,999.99" 
			If nSldFin > 0 .and. nSldCon > 0
				@nLin,090 Psay nSldFin-nSldCon PICTURE "@E 999,999,999,999.99"	
			Else
				@nLin,090 Psay nSldFin+nSldCon PICTURE "@E 999,999,999,999.99"			
			Endif			
				
			nLin += 1		
		Endif			        			
	    
		SA1TMP->(dbSkip())
	Enddo
	
	nLin += 1
	@nLin,000 Psay "Total Geral"
	@nLin,052 Psay nTotSE1 PICTURE "@E 999,999,999,999.99"
	@nLin,072 Psay nTotCT2 PICTURE "@E 999,999,999,999.99"
	If nTotSE1 > 0 .and. nTotCT2 > 0
		@nLin,090 Psay nTotSE1-nTotCT2 PICTURE "@E 999,999,999,999.99"
	Else
		@nLin,090 Psay nTotSE1+nTotCT2 PICTURE "@E 999,999,999,999.99"
	Endif	

Return

/*/{Protheus.doc} Static Function fDados()
	Relatorio Sintetico
	@type  Function
	@author user
	@since 19/11/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function fDados()

	Local cQuery:=""
	
	If Select("SE1TMP") > 0
		DbSelectArea("SE1TMP")
		DbCloseArea("SE1TMP")
	Endif 
	
	If Select("SA1TMP") > 0
		DbSelectArea("SA1TMP")
		DbCloseArea("SA1TMP")
	Endif
	
	cQuery:=" SELECT A1_COD,A1_LOJA,A1_NOME "
	cQuery+=" FROM " + RetSqlName("SA1") + " WITH(NOLOCK) "
	cQuery+=" WHERE D_E_L_E_T_ <> '*' " 
	
	TCQUERY cQuery NEW ALIAS "SA1TMP"
	
	dbselectArea("SA1TMP")
	DbgoTop() 
	
 	//Inicio - Sigoli Chamado 027642   
	If mv_par08 == 1 //Analitico
		
		cQuery:=" select "
		cQuery+=" fonte.E1_FILIAL AS E1_FILIAL ,fonte.E1_PREFIXO AS E1_PREFIXO ,fonte.E1_NUM AS E1_NUM,fonte.E1_PARCELA AS E1_PARCELA, fonte.E1_TIPO AS E1_TIPO, fonte.E1_CLIENTE AS E1_CLIENTE ,"
		cQuery+=" fonte.E1_LOJA AS E1_LOJA, fonte.E1_VALOR AS E1_VALOR, fonte.E1_EMIS1 AS E1_EMIS1,fonte.E1_XDTDISP AS E1_XDTDISP "
		cQuery+=" from "
		cQuery+=" (SELECT "
		cQuery+=" E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA,CASE WHEN E1_TIPO <> 'AB-' THEN E1_VALOR ELSE E1_VALOR * (-1) END AS E1_VALOR,  E1_EMIS1,E1_XDTDISP, "
		cQuery+=" CASE WHEN E1_TIPO = 'AB-' AND (E1_XDTDISP > '"+DTOS(mv_par07)+"' OR E1_XDTDISP = '' OR E1_SALDO <> 0) THEN 1 ELSE 2 END AS FILTRO "   // @history ticket    5212 - Fernando Macieira - 19/11/2020 - Baixa AB- Não Aparece no Relatório de Conciliação (Coluna Financeiro)
		//cQuery+=" CASE WHEN E1_TIPO = 'AB-' AND (E1_XDTDISP > '"+DTOS(mv_par07)+"' OR E1_XDTDISP = '' OR E1_BAIXA = '') THEN 1 ELSE 2 END AS FILTRO "  
		cQuery+=" FROM "
		cQuery+=" "+ RetSqlName("SE1") + " WITH(NOLOCK) " 
		cQuery+=" WHERE E1_EMIS1 BETWEEN '" + DTOS(mv_par05) + "' AND '" + DTOS(mv_par06) + "'"
	    cQuery+=" AND D_E_L_E_T_ <> '*'  
		cQuery+=" AND E1_CLIENTE BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"	
		cQuery+=" AND E1_LOJA BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"   			
		//cQuery+=" AND (E1_TIPO = 'NF' OR E1_TIPO = 'NCI' OR E1_TIPO = 'AB-')
		cQuery+=" AND (E1_TIPO = 'NF' OR E1_TIPO = 'NCI' OR E1_TIPO = 'REN' OR E1_TIPO = 'AB-') " // @history ticket    5242 - Fernando Macieira - 19/11/2020 - Relatório De Conciliação Clientes - Coluna Financeiro Tipo REN
		cQuery+=  iif(!Empty(mv_par10)," AND '"+Alltrim(mv_par10)+"' NOT LIKE '%'+E1_VEND1+'%' ","")
 	    cQuery+=" ) as fonte "
		cQuery+=" WHERE fonte.FILTRO = 2 "
		cQuery+=" ORDER BY fonte.E1_CLIENTE,fonte.E1_LOJA,fonte.E1_EMIS1 "
	    
	Else
		
		cQuery:=" SELECT FONTE.E1_CLIENTE AS E1_CLIENTE , FONTE.E1_LOJA AS E1_LOJA, SUM(FONTE.E1_VALOR) AS E1_VALOR "
		cQuery+=" FROM "
		cQuery+=" (SELECT E1_CLIENTE,E1_LOJA,SUM(CASE WHEN E1_TIPO <> 'AB-' THEN E1_VALOR ELSE E1_VALOR * (-1) END) AS E1_VALOR, "
	    cQuery+="	CASE WHEN E1_TIPO = 'AB-' AND (E1_XDTDISP > '"+DTOS(mv_par07)+"' OR E1_XDTDISP = '' OR E1_SALDO <> 0) THEN 1 ELSE 2 END AS FILTRO "   // @history ticket    5212 - Fernando Macieira - 19/11/2020 - Baixa AB- Não Aparece no Relatório de Conciliação (Coluna Financeiro)
	    //cQuery+="	CASE WHEN E1_TIPO = 'AB-' AND (E1_XDTDISP > '"+DTOS(mv_par07)+"' OR E1_XDTDISP = '' OR E1_BAIXA = '') THEN 1 ELSE 2 END AS FILTRO "   
		cQuery+=" FROM "
		cQuery+=" "+ RetSqlName("SE1") + " WITH(NOLOCK) " 
	    cQuery+=" WHERE E1_EMIS1 BETWEEN '" + DTOS(mv_par05) + "' AND '" + DTOS(mv_par06) + "'"
		cQuery+=" AND D_E_L_E_T_ <> '*' "
		cQuery+=" AND E1_CLIENTE BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"	
		cQuery+=" AND E1_LOJA BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
		//cQuery+=" AND (E1_TIPO = 'NF' OR E1_TIPO = 'NCI' OR E1_TIPO = 'AB-') " 
		cQuery+=" AND (E1_TIPO = 'NF' OR E1_TIPO = 'NCI' OR E1_TIPO = 'REN' OR E1_TIPO = 'AB-') " // @history ticket    5242 - Fernando Macieira - 19/11/2020 - Relatório De Conciliação Clientes - Coluna Financeiro Tipo REN
		cQuery+=  iif(!Empty(mv_par10)," AND '"+Alltrim(mv_par10)+"' NOT LIKE '%'+E1_VEND1+'%' ","")
 	   	cQuery+=" GROUP BY E1_CLIENTE,E1_LOJA,E1_TIPO, E1_XDTDISP,E1_SALDO) AS FONTE "
		cQuery+=" WHERE FILTRO = 2 " 
		cQuery+=" GROUP BY FONTE. E1_CLIENTE, FONTE.E1_LOJA "
		cQuery+=" ORDER BY FONTE. E1_CLIENTE, FONTE.E1_LOJA "
		
	EndIf	
	//Fim - Sigoli Chamado 027642
	
    /*                         
	If mv_par08 == 1 //Analitico                                 
		cQuery:=" SELECT E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA,CASE WHEN E1_TIPO <> 'AB-' THEN E1_VALOR ELSE E1_VALOR * (-1) END AS E1_VALOR, E1_EMIS1,E1_BAIXA"
	Else
		cQuery:=" SELECT E1_CLIENTE,E1_LOJA,SUM(CASE WHEN E1_TIPO <> 'AB-' THEN E1_VALOR ELSE E1_VALOR * (-1) END) AS E1_VALOR   "
	Endif	
		cQuery+=" FROM " + RetSqlName("SE1") + " WITH(NOLOCK) "
		cQuery+=" WHERE E1_EMIS1 BETWEEN '" + DTOS(mv_par05) + "' AND '" + DTOS(mv_par06) + "'"
		cQuery+=" AND D_E_L_E_T_ <> '*' "  
		cQuery+=" AND E1_CLIENTE BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"	
		cQuery+=" AND E1_LOJA BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"   			
		cQuery+=" AND (E1_TIPO = 'NF' "	
		cQuery+="  OR E1_TIPO = 'NCI' "
		cQuery+="  OR E1_TIPO = 'AB-') "
		cQuery+= iif(!Empty(mv_par10)," AND '"+Alltrim(mv_par10)+"' NOT LIKE '%'+E1_VEND1+'%' ","")
	If mv_par08 == 1 //Analitico	
		cQuery+=" ORDER BY E1_CLIENTE,E1_LOJA,E1_EMIS1 "
	Else				
		cQuery+=" GROUP BY E1_CLIENTE,E1_LOJA "
		cQuery+=" ORDER BY E1_CLIENTE,E1_LOJA "
	Endif	
	*/
	
	TCQUERY cQuery NEW ALIAS "SE1TMP"
	
	dbselectArea("SE1TMP")
	DbgoTop()
	
	If Select("SE5TMP") > 0
		DbSelectArea("SE5TMP")
		DbCloseArea("SE5TMP")
	Endif
	     
	If mv_par08 == 1 //Analitico
		cQuery:=" SELECT E5_FILIAL, "
		cQuery+=" 		 E5_PREFIXO, "
		cQuery+=" 		 E5_NUMERO,	 "
		cQuery+=" 		 E5_PARCELA, " 
		cQuery+=" 		 E5_TIPO,   " 
		cQuery+=" 		 E5_CLIFOR, "	
		cQuery+=" 		 E5_LOJA,   " 
		cQuery+=" 		 E5_DTDISPO,"
		cQuery+=" 		 E5_VALOR,  "
		cQuery+=" 		 E5_TIPODOC, "
		cQuery+=" 		 E5_RECPAG, "
		cQuery+=" 		 E5_MOTBX, "
		cQuery+=" 		 E5_VLACRES "
	Else //Sintetico
		cQuery:=" SELECT E5_CLIFOR,E5_LOJA,SUM(E5_VALOR) AS E5_VALOR,E5_RECPAG,E5_MOTBX,E5_TIPODOC,SUM(E5_VLACRES) AS E5_VLACRES "
	Endif	
		cQuery+=" FROM " + RetSqlName("SE5") + " SE5 WITH(NOLOCK) " 
		cQuery+=" WHERE SE5.D_E_L_E_T_ <> '*' "
        cQuery+=" AND E5_CLIFOR BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
		cQuery+=" AND E5_LOJA BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"				
		cQuery+=" AND E5_SITUACA <> 'C' "	
		cQuery+=" AND E5_DTDISPO <= '" + DTOS(mv_par07) + "' "
		cQuery+=" AND E5_DTDISPO BETWEEN '" + DTOS(mv_par05) + "' AND '" + DTOS(mv_par06) + "'"
		cQuery+=" AND (E5_TIPO = 'NF' "	
		cQuery+="  OR E5_TIPO = 'NCI' OR E5_TIPO = 'REN') "	// @history ticket    5242 - Fernando Macieira - 19/11/2020 - Relatório De Conciliação Clientes - Coluna Financeiro Tipo REN
		//cQuery+="  OR E5_TIPO = 'NCI') "	
		//cQuery+=" AND E5_TIPODOC NOT IN ('E2','JR') "	
		//cQuery+=" AND E5_MOTBX NOT IN ('BOF') "
		cQuery+=" AND (E5_TIPODOC+E5_MOTBX IN ('BABON') "
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('BADEA') "
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('BAFIN') "
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('BACEC') "
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('BACMP') "	
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('BADAC') "		
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('BANOR') "	
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('BASIN') "		
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('CPBON') "
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('ESBOF') "	
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('CPCMP') "	
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('CPNOR') "
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('DCBON') "
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('DCCMP') "	
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('DCNOR') "	
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('ESBON') "
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('ESCEC') "		
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('ESCMP') "	
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('ESNOR') " 
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('JRNOR') "	
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('MTNOR') "	
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('V2BON') "
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('V2CMP') "	
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('V2NOR') "
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('VLBOF') "	
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('VLBON') "
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('VLCMP') "	
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('VLNOR') "
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('BAEMB') "
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('BASDD') "
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('VLNOR') "
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('BABCF') " //Chamado: 16/05/2019 - Fernando Sigoli
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('BABPQ') " //Chamado: 16/05/2019 - Fernando Sigoli
		cQuery+=" OR E5_TIPODOC+E5_MOTBX IN ('BADCP') " //Chamado: 21/05/2019 - Fernando Sigoli
		cQuery+=" OR E5_TIPODOC + E5_MOTBX IN ('J2NOR') " 
		cQuery+=" OR E5_TIPODOC + E5_MOTBX IN ('BALIQ') " // @history ticket    5242 - Fernando Macieira - 19/11/2020 - Relatório De Conciliação Clientes - Coluna Financeiro Tipo REN
		cQuery+=" OR E5_TIPODOC + E5_MOTBX IN ('JRBCF') " // @history ticket    5378 - Fernando Macieira - 19/11/2020 - Juros Bx Desconto em Folha não aparece Coluna Financeiro do Rel. de Conciliação de Clientes
		cQuery+=" OR E5_TIPODOC + E5_MOTBX IN ('MTBCF') " //Chamado  8714 - 28/01/2021 - Andre Mendes - Obify
		cQuery+=" OR E5_TIPODOC + E5_MOTBX IN ('DCBCF') " //Chamado  8714 - 28/01/2021 - Andre Mendes - Obify
		cQuery+=" OR E5_TIPODOC + E5_MOTBX IN ('JRDAC') " //Chamado 054534: 02/01/2020 - William Costa
		cQuery+=" OR E5_TIPODOC + E5_MOTBX IN ('BAICM')) " // @history ticket 3762 - FWNM - 06/11/2020 - Conciliação automatica Safegg
		cQuery+=" AND E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA " /*RETIRADO A FILIAL E ADICIONADO VARIOS OR E5_TIPODOC+E5_MOTBX CHAMADO 021914*/
		cQuery+=" IN (  "
		cQuery+=" SELECT E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA FROM " +  RetSqlName("SE1") + " WITH(NOLOCK) "
		cQuery+=" WHERE E1_EMIS1 BETWEEN '" + DTOS(mv_par05) + "' AND '" + DTOS(mv_par06) + "'"
		cQuery+=" AND D_E_L_E_T_ <> '*' "
		cQuery+=" AND E1_CLIENTE BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
		cQuery+=" AND E1_LOJA BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"				
		cQuery+=" AND (E1_TIPO = 'NF' "	  
		cQuery+="  OR  E1_TIPO = 'NCI' OR E1_TIPO = 'REN') " // @history ticket    5242 - Fernando Macieira - 19/11/2020 - Relatório De Conciliação Clientes - Coluna Financeiro Tipo REN
		//cQuery+="  OR  E1_TIPO = 'NCI') "	  
        cQuery+=iif(!Empty(mv_par10)," AND '"+Alltrim(mv_par10)+"' NOT LIKE '%'+E1_VEND1+'%' ","")
		cQuery+=" ) "
				
	If mv_par08 == 1 //Analitico	
		cQuery+=" ORDER BY E5_CLIFOR,E5_LOJA,E5_DTDISPO,E5_RECPAG "		
	Else //Sintetico
		cQuery+=" GROUP BY E5_CLIFOR,E5_LOJA,E5_RECPAG,E5_MOTBX,E5_TIPODOC "
		cQuery+=" ORDER BY E5_CLIFOR,E5_LOJA "	
	Endif		
	
	TCQUERY cQuery NEW ALIAS "SE5TMP"
	
	dbselectArea("SE5TMP")
	DbgoTop()
	
	If Select("CT2TMP") > 0
		DbSelectArea("CT2TMP")
		DbCloseArea("CT2TMP")
	Endif
	      
	If mv_par08 == 1 //Analitico
		cQuery:=" SELECT CT2_FILKEY,CT2_PREFIX,CT2_NUMDOC,CT2_PARCEL,CT2_TIPODC,CT2_CLIFOR,CT2_LOJACF,CT2_VALOR,CT2_DEBITO,CT2_CREDIT,CT2_DATA "
	Else //Sintetico
		cQuery:=" SELECT CT2_CLIFOR,CT2_LOJACF,SUM(CT2_VALOR) AS CT2_VALOR,CT2_DEBITO,CT2_CREDIT "
	Endif	
		cQuery+=" FROM " + RetSqlName("CT2") + " WITH(NOLOCK) "
		cQuery+=" WHERE D_E_L_E_T_ <> '*' "
		cQuery+=" AND CT2_DATA BETWEEN '" + DTOS(mv_par05) + "' AND '" + DTOS(mv_par06) + "' "	
		cQuery+=" AND (CT2_DEBITO = '" + Alltrim(mv_par09) + "' OR CT2_CREDIT = '" + Alltrim(mv_par09) + "') "
		cQuery+=" AND CT2_CLIFOR BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
		cQuery+=" AND CT2_LOJACF BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
		cQuery+=" AND CT2_CLIFOR <> '' "                                       
		cQuery+=" AND CT2_TIPODC NOT IN ('RA','NCC') " //incluido por Adriana em 25/09/2014 para desconsiderar Titulos de adiantamento                                       
		
	If mv_par08 == 1 //Analitico						
		cQuery+=" ORDER BY CT2_CLIFOR,CT2_LOJACF,CT2_DATA "	
	Else //Sintetico				
		cQuery+=" GROUP BY CT2_CLIFOR,CT2_LOJACF,CT2_DEBITO,CT2_CREDIT "
		cQuery+=" ORDER BY CT2_CLIFOR,CT2_LOJACF "	
	Endif	
	
	TCQUERY cQuery NEW ALIAS "CT2TMP"
	
	dbselectArea("CT2TMP")
	DbgoTop()

Return

/*/{Protheus.doc} Static Function fE1DTDISPO
	Preenche campo customizado E1_XDTDISPO quando estiver vazio
	@type  Function
	@author FWNM
	@since 28/08/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 452 - FWNM - 28/08/2020 - Alguns Títulos AB- não estão sendo listados
/*/
Static Function fE1DTDISPO()

    Local cQuery  := ""
    
    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    cQuery := " SELECT DISTINCT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, MAX(E5_DTDISPO) E5_DTDISPO
    cQuery += " FROM " + RetSqlName("SE1") + " SE1 (NOLOCK) 
    cQuery += " INNER JOIN " + RetSqlName("SE5") + " SE5 (NOLOCK) ON E5_FILIAL=E1_FILIAL AND E5_PREFIXO=E1_PREFIXO AND E5_NUMERO=E1_NUM AND E5_PARCELA=E1_PARCELA AND E5_CLIFOR=E1_CLIENTE AND E5_LOJA=E1_LOJA AND E5_SITUACA='' AND E5_RECPAG='R' AND SE5.D_E_L_E_T_='' 
    cQuery += " WHERE E1_FILIAL BETWEEN '' AND 'ZZ' 
	cQuery += " AND E1_CLIENTE BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'
	cQuery += " AND E1_LOJA BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'

    //cQuery += " AND E1_XDTDISP='' // @history ticket 4665 - FWNM - 17/11/2020 - AB- Contabilização e Apontamento no Relatório de Conciliação de Clientes ocorrendo na data da baixa parcial
    //cQuery += " AND E5_DTDISPO BETWEEN '"+DtoS(MV_PAR05)+"' AND '"+DtoS(MV_PAR06)+"'

    cQuery += " AND E5_DTDISPO >= '"+DtoS(MV_PAR05)+"' " // @history ticket 4665 - FWNM - 17/11/2020 - AB- Contabilização e Apontamento no Relatório de Conciliação de Clientes ocorrendo na data da baixa parcial
    cQuery += " AND E1_TIPO='AB-' 
    cQuery += " AND E1_SALDO=0 

	// debug - inibir
	//cQuery += " AND E1_NUM='001979731'
	// debug - inibir

    cQuery += " AND SE1.D_E_L_E_T_='' 
    cQuery += " GROUP BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA

    tcQuery cQuery New Alias "Work"

	aTamSX3 := TamSX3("E5_DTDISPO")
	tcSetField("Work", "E5_DTDISPO", aTamSX3[3], aTamSX3[1], aTamSX3[2])

    Work->( dbGoTop() )

    Do While Work->( !EOF() )

		SE1->( dbSetOrder(1) ) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
        If SE1->( dbSeek(Work->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)))

			//If Empty(SE1->E1_XDTDISP) // @history ticket 4665 - FWNM - 17/11/2020 - AB- Contabilização e Apontamento no Relatório de Conciliação de Clientes ocorrendo na data da baixa parcial
				RecLock("SE1", .f.)
					SE1->E1_XDTDISP := Work->E5_DTDISPO
				SE1->( msUnLock() )
			//EndIf
		
		EndIf

		Work->( dbSkip() )

	EndDo
	
Return
