#Include "Rwmake.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} User Function RelEntrg
	(Relatorio de Entrega realizadas.Chamado 006200.)
	@type  Function
	@author Mauricio da Silva 
	@since 24/05/2010
	@version 01
	@history TICKET: 70540 - 30/03/2022 - ADRIANO SAVOINE - Tratado o parametro filial para gerar o relatorio de forma correta.
	/*/

User Function RelEntreg() // U_RelEntreg()

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de entregues realizadas por periodo."
	Local cDesc3         := ""
	Local titulo         := "Relatorio de Entregas Realizadas"
	Local nLin           := 80
	Local Cabec1         := ""
	Local Cabec2         := ""
	Local aOrd           := {}
	
	Private cPerg 		:= "RELENT"
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "P"
	Private nomeprog     := "RelEntreg"
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "RelEntreg"
	Private cString 		:= "SZD"
	
	//Éverson - Chamado 029359
	Private cTipoRoteiro	:= ""
	Private cNomeCompl	:= " Todas Rotas"
	Private cTipoRel		:= "Analítico"
	//
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Entrega realizadas.Chamado 006200.')
	
	CriaSx1(cPerg)

	Pergunte(cPerg,.F.)
	
	dbSelectArea("SZD")
	dbSetOrder(1)

//TICKET: 70540 - 30/03/2022 - ADRIANO SAVOINE
IF TYPE(mv_par05) == "N" .OR. mv_par05 == "                                                  "

    MsgAlert("SELECIONE NOS PARAMETROS AS FILIAIS, PARA GERAR ESTE RELATORIO.", "ATENCAO!!!")

  	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

  	U_RelEntreg()

   ELSE

   wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

ENDIF
	
	
	
	If nLastKey == 27
		Return
		
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return
		
	Endif
	
	//Éverson - Chamado 029359
	If mv_par07 == 2
		cTipoRel := "Sintético"
		
	EndIf
	//
	
	//Éverson - Chamado 029359
	If mv_par08 == 2
		cTipoRoteiro	:= "PAR"
		cNomeCompl		:= " Pares "
		
	ElseIf mv_par08 == 3
		cTipoRoteiro	:= "IMPAR"
		cNomeCompl    := " Ímpares" 
		
	EndIf
	//
	
	DadosRel()
	
	nTipo := If(aReturn[4]==1,15,18)
	
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	
	dBcLOSEaREA("TRB")

Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem
	Local cRotIni := ""
	Local cRotFim := ""
	Local lInverte:= .F.
	
	dbSelectArea("TRB")
	dbGoTop()
	
	SetRegua(RecCount())
	
	_nFEntr := 0
	_nEntr  := 0
	_nFA1   := 0
	_nA1    := 0
	_cRegiao := " "
	_cOrd    := " "
	
	While !EOF()
	
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
			
		Endif
		
		If nLin > 55
		
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 7
			@nLin, 001 PSAY "Periodo de : "+DTOC(mv_par01)+ " ate "+DTOC(mv_par02) + " | Roteiros:" + cNomeCompl //Éverson - Chamado 029359
			nLin += 2
			@nLin, 001 PSAY "Relatório: " + cTipoRel
			nLin += 2
			//@nLin,001 PSAY REPLICATE("-",75)
			nLin += 1
			@nLin,025 PSAY "ROTEIROS"
			@nLin,048 PSAY "PEDIDOS"
			nLin += 1
			@nLin,025 PSAY "---------"
			@nLin,038 PSAY REPLICATE("-",38)
			nLin += 2
			@nLin,001 PSAY "REGIAO" 
			@nLin,025 PSAY "DE"
			@nLin,030 PSAY "ATE"
			@nLin,038 PSAY "A ENTREGAR"
			@nLin,050 PSAY "ENTREGUES"
			@nLin,062 PSAY "% REALIZADAS"
			nLin += 1
			@nLin,001 PSAY REPLICATE("-",75)
			nLin += 1
			
		Endif
		
		_cOrdem  := TRB->ORDEM 
		_cRegiao := TRB->DESCRICAO
		_cOrd    := TRB->ORDEM
	
		WHILE _cOrdem == TRB->ORDEM
		
			_nFEntr += 1
			
			if TRB->SAOPAULO == "A1"
				_nFA1   += 1
				
			endif
			
			TRB->(Dbskip())
			
		Enddo
	
		@nLin, 001 PSAY _cRegiao
		
		IF _cOrd == "01"
			@nLin,025 PSAY "200"
			@nLin,030 PSAY "599"
			_nEntr := Entregue("200","599")
			_nA1 += _nentr
			cRotIni := "200" //Éverson - Chamado 029359
			cRotFim := "599" //Éverson - Chamado 029359
			lInverte:= .F.   //Éverson - Chamado 029359
			
		elseif _cOrd == "02"
			@nLin,025 PSAY "600"
			@nLin,030 PSAY "699"
			_nEntr := Entregue("600","699")
			_nA1 += _nentr
			cRotIni := "600" //Éverson - Chamado 029359
			cRotFim := "699" //Éverson - Chamado 029359
			lInverte:= .F.   //Éverson - Chamado 029359
			
		elseif _cOrd == "03"
			@nLin,025 PSAY "700"
			@nLin,030 PSAY "799"
			_nEntr := Entregue("700","799")
			_nA1 += _nentr
			cRotIni := "700" //Éverson - Chamado 029359
			cRotFim := "799" //Éverson - Chamado 029359
			lInverte:= .F.   //Éverson - Chamado 029359
			
		elseif _cOrd == "04"
			@nLin,025 PSAY "800"
			@nLin,030 PSAY "869"
			_nEntr := Entregue("800","869")
			_nA1 += _nentr
			cRotIni := "800" //Éverson - Chamado 029359
			cRotFim := "869" //Éverson - Chamado 029359
			lInverte:= .F.   //Éverson - Chamado 029359
			
		elseif _cOrd == "05"
			@nLin,025 PSAY "870"
			@nLin,030 PSAY "899"
			_nEntr := Entregue("870","899")
			_nA1 += _nentr     //Incluido por Wesley para atender o chamado 028784
			cRotIni := "870" //Éverson - Chamado 029359
			cRotFim := "899" //Éverson - Chamado 029359
			lInverte:= .F.   //Éverson - Chamado 029359
			
		elseif _cOrd == "06"
			@nLin,025 PSAY "900"
			@nLin,030 PSAY "999"
			_nEntr := Entregue("900","999")
			_nA1 += _nentr    //Incluido por Wesley para atender o chamado 028784
			cRotIni := "900" //Éverson - Chamado 029359
			cRotFim := "999" //Éverson - Chamado 029359
			lInverte:= .F. //Éverson - Chamado 029359
			
		else
			@nLin,025 PSAY "   "
			@nLin,030 PSAY "   "
			_nEntr := Entregue2("200","999")
			_nA1 += _nentr
			cRotIni := "200"
			cRotFim := "999"
			lInverte:= .T.
			
		endif
		
		@nLin, 038 PSAY (_nFEntr) Picture "@E 99999"
		@nLin, 050 PSAY _nEntr  Picture "@E 99999"
		@nLin, 062 PSAY (_nEntr/(_nFEntr))*100 Picture "@E 9999.99%"
		
		DbSelectArea("TRB")
		
		nLin += 1
		_nFEntr := 0
		_nEntr  := 0
		
		//Éverson - Chamado 029359
		//Se o relatório for analítico, imprime detalhes das rotas.
		If MV_PAR07 == 1
			
			obtemDetalhe(cRotIni, cRotFim, lInverte)
			nLin += 1
			@nLin,001 PSAY "DATA"
			@nLin,015 PSAY "PLACA"
			//@nLin,025 PSAY "ROTEIRO"
			//@nLin,038 PSAY "A ENTREGAR"
			//@nLin,050 PSAY "ENTREGUES"
			//@nLin,062 PSAY "% REALIZADAS"
			
			DbSelectArea("DETALHES")
			DETALHES->(DbGoTop())
			While ! DETALHES->(Eof())
				nLin += 1
				
				If nLin > 55
		
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 7
					@nLin, 001 PSAY "Periodo de : "+DTOC(mv_par01)+ " ate "+DTOC(mv_par02) + " | Roteiros:" + cNomeCompl
					nLin += 2
					@nLin, 001 PSAY "Relatório: " + cTipoRel
					nLin += 2
					//@nLin,001 PSAY REPLICATE("-",75)
					nLin += 1
					@nLin,025 PSAY "ROTEIROS"
					@nLin,048 PSAY "PEDIDOS"
					nLin += 1
					@nLin,025 PSAY "---------"
					@nLin,038 PSAY REPLICATE("-",38)
					nLin += 2
					@nLin,001 PSAY "REGIAO" 
					@nLin,025 PSAY "DE"
					@nLin,030 PSAY "ATE"
					@nLin,038 PSAY "A ENTREGAR"
					@nLin,050 PSAY "ENTREGUES"
					@nLin,062 PSAY "% REALIZADAS"
					nLin += 1
					@nLin,001 PSAY REPLICATE("-",75)
					nLin += 1
			
				Endif
		
				@nLin,001 PSAY STOD(DETALHES->C5_DTENTR)
				@nLin,015 PSAY DETALHES->C5_PLACA 
				@nLin,025 PSAY DETALHES->C5_ROTEIRO
				
				@nLin,038 PSAY DETALHES->QTD_DE_ENTREGA Picture "@E 99999"
				@nLin,050 PSAY DETALHES->ENTREGUES Picture "@E 99999"
				@nLin,062 PSAY DETALHES->PORCENTAGEM_REALIZADO Picture "@E 9999.99%"
			
				DETALHES->(DbSkip())
			EndDo
			DbCloseArea("DETALHES")
			
			nLin += 1
			
			@nLin,001 PSAY REPLICATE("-",75)
			
			nLin += 2
			
			DbSelectArea("TRB")
			
		EndIf
	  
	EndDo
	
	@nLin,001 PSAY REPLICATE("-",75)      
	nLin += 2
	@nLin,001 PSAY "Total Geral Regioes"
	@nLin, 038 PSAY (_nFA1) Picture "@E 99999"
	@nLin, 050 PSAY _nA1  Picture "@E 99999"
	@nLin, 062 PSAY (_nA1/(_nFA1))*100 Picture "@E 9999.99%"  
	DbSelectArea("TRB")
	nLin += 1
	_nFA1 := 0
	_nA1  := 0

	SET DEVICE TO SCREEN
	
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	
	MS_FLUSH()

Return


Static function DadosRel()

	aStru := {}
	AADD (aStru,{"ROTEIRO" 	    , "C",03,0})
	AADD (aStru,{"DESCRICAO"   	, "C",20,0})
	AADD (aStru,{"ORDEM"   	    , "C",02,0})
	AADD (aStru,{"SAOPAULO"     , "C",02,0})
	AADD (aStru,{"DATAD"     	, "D",08,0})
	_cNomTrb := CriaTrab(aStru)
	
	dbUseArea(.T.,,_cNomTrb,"TRB",.F.,.F.)
	cIndex   	:=	 "ORDEM"
	IndRegua( "TRB", _cNomTrb, cIndex,,,"Criando Indice TRB..." )
	
	cQuery := " SELECT C5_FILIAL, C5_DTENTR, C5_ROTEIRO, " 
	cQuery += " CAST(CASE CAST(C5_ROTEIRO AS NUMERIC)%2 WHEN 0 THEN 'PAR' ELSE 'IMPAR' END AS VARCHAR) AS PAR_OU_IMPAR" //Éverson - Chamado 029359
	cQuery += " FROM "+retsqlname("SC5")+ ""
	cQuery += " WHERE C5_DTENTR between '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"' "
	cQuery += " AND C5_ROTEIRO between '"+mv_par03+"' AND '"+mv_par04+"' AND "
	cQuery += " C5_FILIAL IN ("+Alltrim(mv_par05)+") AND "
	cQuery += Iif(MV_PAR06 = 1, "(C5_NOTA <> '' OR C5_LIBEROK = 'E' AND C5_BLQ = '' ) AND ","")
	cQuery += retsqlname("SC5")+".D_E_L_E_T_= '' "
	
	TCQUERY cQuery new alias "XSC5"
	
	DbSelectArea("TRB")
	DbSelectArea("XSC5")
	DbGoTop()
	While !EOF()
	
		If Empty(cTipoRoteiro) .Or. Alltrim(cValToChar(XSC5->PAR_OU_IMPAR)) == cTipoRoteiro //Éverson - Chamado 029359
	
			Reclock("TRB",.T.)
			TRB->ROTEIRO := XSC5->C5_ROTEIRO
			IF XSC5->C5_ROTEIRO >= "200" .AND. XSC5->C5_ROTEIRO <= "599"
				TRB->DESCRICAO :=  "SAO PAULO" 
				TRB->ORDEM     := "01"
				TRB->SAOPAULO  := "A1"
			ELSEIF XSC5->C5_ROTEIRO >= "600" .AND. XSC5->C5_ROTEIRO <= "699"
				TRB->DESCRICAO :=  "LITORAL" 
				TRB->ORDEM     := "02"
				TRB->SAOPAULO  := "A1"
			ELSEIF XSC5->C5_ROTEIRO >= "700" .AND. XSC5->C5_ROTEIRO <= "799"
				TRB->DESCRICAO :=  "VALE DO PARAIBA"
				TRB->ORDEM     := "03"
				TRB->SAOPAULO  := "A1"
			ELSEIF XSC5->C5_ROTEIRO >= "800" .AND. XSC5->C5_ROTEIRO <= "869"
				TRB->DESCRICAO :=  "INTERIOR" 
				TRB->ORDEM     := "04"
				TRB->SAOPAULO  := "A1"
			ELSEIF XSC5->C5_ROTEIRO >= "870" .AND. XSC5->C5_ROTEIRO <= "899"
				TRB->DESCRICAO :=  "MINAS GERAIS" 
				TRB->ORDEM     := "05" 
				TRB->SAOPAULO  := "A1"			//Incluido por Wesley para atender o chamado 028784
			ELSEIF XSC5->C5_ROTEIRO >= "900" .AND. XSC5->C5_ROTEIRO <= "999"
				TRB->DESCRICAO :=  "RIO DE JANEIRO" 
				TRB->ORDEM     := "06"
				TRB->SAOPAULO  := "A1"			//Incluido por Wesley para atender o chamado 028784
			ELSE
				TRB->DESCRICAO :=  "OUTROS" 
				TRB->ORDEM     := "07"
				TRB->SAOPAULO  := "A1"			//Incluido por Wesley para atender o chamado 028784
			ENDIF
			TRB->DATAD := STOD(XSC5->C5_DTENTR)
			MsUnlock()
		
		EndIf
		
		DBSELECTAREA("XSC5")
		DBSKIP()
		
	ENDDO
	
	DBCLOSEAREA()

RETURN()

Static function CriaSx1(cPerg)
	
	aHelpPor :={}
	aHelpEng :={}
	aHelpSpa :={}
	Aadd(aHelpPor, 'Selecione as filiais a serem')
	Aadd(aHelpPor, 'utilizadas.')
	Aadd( aHelpSpa, '')
	Aadd( aHelpEng, '')
	
	PutSX1(cPerg,"01","Data De "          ,"Data De "      ,"Data De "      ,"mv_ch1","D",08,0,0,"G",""         ,"","","","mv_par01" ,"","","","","","","","","","","","","","",""," ")
	PutSX1(cPerg,"02","Data Ate "         ,"Data Ate "     ,"Data Ate "     ,"mv_ch2","D",08,0,0,"G",""         ,"","","","mv_par02" ,"","","","","","","","","","","","","","",""," ")
	PutSX1(cPerg,"03","Do Roteiro "       ,"Do Roteiro "   ,"Do Roteiro "   ,"mv_ch3","C",03,0,0,"G",""         ,"","","","mv_par03" ,"","","","","","","","","","","","","","",""," ")
	PutSX1(cPerg,"04","Ate o Roteiro "    ,"Ate o Roteiro "	,"Ate o Roteiro ","mv_ch4","C",03,0,0,"G",""         ,"","","","mv_par04" ,"","","","","","","","","","","","","","",""," ")
	PutSx1(cPerg,"05","Seleciona filiais ",""              ,""              ,"mv_ch5","C",50,0,0,"G","U_FXFIL()","","","",;
	"mv_par05","","","","","","","","",;
	"","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	
	//incluida pergunta 6 para atender chamado 006200 por Adriana - HC
	PutSX1(cPerg,"06","Somente Faturados ","Somente Faturados "	,"Somente Faturados ","mv_ch6","N",01,0,01,"C","","","","","mv_par06" ,"Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","",""," ")
	
	////Éverson - Chamado 029359
	PutSX1(cPerg,"07","Tipo relatório ","Tipo relatório " ,"Tipo relatório","mv_ch7"  ,"N",01,0,01,"C","","","","","mv_par07" ,"Analítico","Analítico","Analítico","","Sintético","Sintético","Sintético","","","","","","",""," ")
	PutSX1(cPerg,"08","Tipo de rota "  ,"Tipo de rota "	 ,"Tipo de rota "  ,"mv_ch8"  ,"N",01,0,01,"C","","","","","mv_par08" ,"Todos","Todos","Todos","","Par","Par","Par","Ímpar","Ímpar","Ímpar","","","",""," ")

Return Nil

Static function Entregue(_cRotIni,_cRotFim)

	Local _nTotal := 0
	Local cQuery	:= ""
	                        
	cQuery := " SELECT CAST(CASE CAST(C5_ROTEIRO AS NUMERIC)%2 WHEN 0 THEN 'PAR' ELSE 'IMPAR' END AS VARCHAR) AS PAR_OU_IMPAR "
	cQuery += " FROM "+retsqlname("SZD")+", "+retsqlname("SC5")+" "
	cQuery += " WHERE C5_FILIAL IN ("+ALLTRIM(MV_PAR05)+") AND "
	cQuery += " ZD_FILIAL = C5_FILIAL AND "
	cQuery += " C5_DTENTR BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"' AND "
	cQuery += " C5_ROTEIRO BETWEEN '"+_cRotIni+"' AND '"+_cRotFim+"' AND "
	cQuery += " C5_NUM = ZD_PEDIDO AND "
	cQuery += Iif(MV_PAR06 = 1, "(C5_NOTA <> '' OR C5_LIBEROK = 'E' AND C5_BLQ = '' ) AND ","")
	cQuery += " C5_MOK = '02' AND " //Éverson - Chamado 029359
	cQuery += " "+RetSqlName("SZD")+ ".D_E_L_E_T_= '' AND "+RetSqlName("SC5")+ ".D_E_L_E_T_= ''"
	
	If Select("XSZD") > 0
		XSZD->(DbCloseArea())
		
	EndIf
	
	TCQUERY cQuery new alias "XSZD"
	               
	XSZD->(dbgotop())
	//Éverson - Chamado 029359
	While ! XSZD->(Eof())
	
		If Empty(cTipoRoteiro) .Or. Alltrim(cValToChar(XSZD->PAR_OU_IMPAR)) == cTipoRoteiro
			_nTotal ++
		
		EndIf		
		
		XSZD->(DbSkip())
	EndDo
	
	DbCloseArea("XSZD")

RETURN(_nTotal)

Static function Entregue2(_cRotIni1,_cRotFim1)

	Local _nTotal := 0
	Local cQuery	:= ""
	
	cQuery	:=	" SELECT CAST(CASE CAST(C5_ROTEIRO AS NUMERIC)%2 WHEN 0 THEN 'PAR' ELSE 'IMPAR' END AS VARCHAR) AS PAR_OU_IMPAR "
	cQuery	+=	" FROM "+retsqlname("SZD")+", "+retsqlname("SC5")+" "
	cQuery	+=	" WHERE C5_FILIAL IN ("+ALLTRIM(MV_PAR05)+") AND "
	cQuery	+=	" ZD_FILIAL = C5_FILIAL AND "
	cQuery	+=	" C5_DTENTR BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"' AND "
	cQuery	+=	" (C5_ROTEIRO <= '"+_cRotIni1+"' OR C5_ROTEIRO >= '"+_cRotFim1+"') AND " //Éverson - Chamado 029359
	cQuery	+=	" C5_NUM = ZD_PEDIDO AND "
	cQuery	+=	Iif(MV_PAR06 = 1, "(C5_NOTA <> '' OR C5_LIBEROK = 'E' AND C5_BLQ = '' ) AND ","")
	cQuery	+=	" C5_MOK = '02' AND " //Éverson - Chamado 029359
	cQuery	+=	" "+RetSqlName("SZD")+ ".D_E_L_E_T_= '' AND "+RetSqlName("SC5")+ ".D_E_L_E_T_= '' "
	
	If Select("XSZD") > 0
		XSZD->(DbCloseArea())
		
	EndIf
	
	TCQUERY cQuery new alias "XSZD"
	               
	XSZD->(dbgotop())
	
	//Éverson - Chamado 029359
	While ! XSZD->(Eof())
	
		If Empty(cTipoRoteiro) .Or. Alltrim(cValToChar(XSZD->PAR_OU_IMPAR)) == cTipoRoteiro
			_nTotal ++
		
		EndIf		
		
		XSZD->(DbSkip())
	EndDo
	
	DbCloseArea("XSZD")

RETURN(_nTotal)

Static Function obtemDetalhe(cRotIni, cRotFim, lInverte) //Éverson - Chamado 029359

	Local cQuery	:= ""

    cQuery += " SELECT * " 
	cQuery += " FROM " 
		cQuery += " ( " 
		cQuery += " SELECT SC5.C5_ROTEIRO, " 
			cQuery += " SC5.C5_PLACA, " 
			cQuery += " SC5.C5_DTENTR, " 
			cQuery += " COUNT(SC5.C5_SEQUENC) AS QTD_DE_ENTREGA, " 
			cQuery += " SUM(CASE WHEN SC5.C5_MOK <> '02' then 1  else 0  END) AS A_ENTREGAR, " 
			cQuery += " SUM(CASE WHEN SC5.C5_MOK = '02' then 1  else 0  END) AS ENTREGUES, " 
			cQuery += " (SUM(CASE WHEN SC5.C5_MOK = '02' then 1  else 0  END) * 100) / COUNT(SC5.C5_SEQUENC) AS PORCENTAGEM_REALIZADO, " 
			cQuery += " CASE CAST(C5_ROTEIRO AS numeric)%2 WHEN 0 THEN 'PAR' ELSE 'IMPAR' END AS PAR_OU_IMPAR " 
		cQuery += " FROM " + RetSqlName("SC5") + " SC5 " 
		cQuery += " WHERE SC5.C5_FILIAL  IN ("+ALLTRIM(MV_PAR05)+") "
			cQuery += " AND SC5.C5_DTENTR  >= '" +dtos(mv_par01)+ "' " 
			cQuery += " AND SC5.C5_DTENTR  <= '" +dtos(mv_par02)+ "' " 
			
			If ! lInverte
				cQuery += " AND SC5.C5_ROTEIRO >= '" + cRotIni + "' " 
				cQuery += " AND SC5.C5_ROTEIRO <='"  + cRotFim + "' " 
			
			Else
				cQuery += " AND (SC5.C5_ROTEIRO <= '" + cRotIni + "' OR SC5.C5_ROTEIRO >= '"  + cRotFim + "') " 

			EndIf
			
			cQuery += " AND SC5.D_E_L_E_T_ = '' " 
			cQuery += Iif(MV_PAR06 = 1, " AND (SC5.C5_NOTA <> '' OR SC5.C5_LIBEROK = 'E' AND SC5.C5_BLQ = '' ) ","")
		cQuery += " GROUP BY SC5.C5_DTENTR,SC5.C5_ROTEIRO,SC5.C5_PLACA " 
		cQuery += " ) AS FONTE "
		
	If ! Empty(cTipoRoteiro)
	cQuery += " WHERE " 
		cQuery += " FONTE.PAR_OU_IMPAR = '" + cTipoRoteiro + "' " 
	
	EndIf
	
	cQuery += " ORDER BY FONTE.PORCENTAGEM_REALIZADO  " 
	
	If Select("DETALHES") > 0
		DETALHES->(DbCloseArea())
	EndIf
	
	TcQuery cQuery New Alias "DETALHES"

Return cQuery  
