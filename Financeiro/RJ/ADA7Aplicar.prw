#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADA7APLICARบAutor ณMicrosiga           บ Data ณ  06/10/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamado   ณ 049746 || OS 051039 || FINANCAS || ANA || 8384 ||          บฑฑ
ฑฑบ          ณ || REL. PARCELAS RJAP - FWNM - 10/06/2019                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ADA7Aplicar()

	Private nomeprog    := "ADA7Aplicar"
	Private nTipo       := 18
	Private nLastKey    := 0
	Private cPerg       := "ADA7SIMULQ"
	Private CbTxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private cString 	:= "ZAG"
	Private nFatCor		:= 0    
	Private nFator		:= 0   
	Private cDoc        := ''
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	MV_PAR01 := SPACE(03)
	MV_PAR02 := 0
	
	If !Pergunte(cPerg,.T.)
		ValidPerg()
		If !Pergunte (cPerg, .T.)
			Return
		EndIf
	EndIf
	
	nFator := ZAG->ZAG_CORREC 
	
	If Empty(ZAG->ZAG_STATUS)
		MsgInfo("Nao e permitido utilizar esta rotina sem ter executado a rotina de simulacao!!")
		Return()
	EndIf
	
	If !Empty(ZAG->ZAG_LEGEND)
		MsgInfo("Nao e permitido utilizar para indices ja processados!!")
		Return()
	EndIf
	
	Processa({||fAtualiza() } )

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADA7APLICARบAutor ณMicrosiga           บ Data ณ  06/10/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fAtualiza()

	Local cQuery 	:= "" 
	Local _nCusto	:= 0      
	Local lOk		:= .T.                             
	Local nTot		:= 0
	Local aContab	:= {}   
	Local cChave	:= ''
	Local nSaldo
	
	nFatCor := ZAG->ZAG_CORREC
	
	cQuery := " SELECT ZAH.ZAH_NUMERO,ZAF.*  "
	cQuery += " FROM " + RetSqlName("ZAH") + " ZAH, " + RetSqlName("ZAF") + " ZAF "
	cQuery += " WHERE ZAH.ZAH_NUMERO  = ZAF.ZAF_NUMERO " 
	cQuery += " AND ZAH.D_E_L_E_T_   <> '*' "
	cQuery += " AND ZAF.D_E_L_E_T_   <> '*' "
	cQuery += " AND ZAF.ZAF_LEGEND    = '' "   
	cQuery += " AND ZAF.ZAF_SALDO     > 0  "   
	cQuery += " ORDER BY ZAF.ZAF_NUMERO,ZAF.ZAF_PREFIX,ZAF.ZAF_PARCEL "
	
	Tcquery cQuery Alias "TARQ" New
	
	Count to nTot
	If nTot > 0 
	    && inicia chave
		cChave := TARQ->ZAF_NUMERO + TARQ->ZAF_PREFIX + TARQ->ZAF_PARCEL 
		
		&& Atualizar legenda ZAG
			dbSelectARea("ZAG")
			RecLock("ZAG",.F.)
				ZAG->ZAG_LEGEND := 'B'
			MsUnlock("ZAG")
			lOK := .F.
	EndIf
	
	TARQ->(dbGoTop())
	ProcRegua(nTot)
	
	MV_PAR02 := nFator
	nDif	 := 0
	
	While TARQ->(!Eof())
	
		IncProc('Aguarde. Processamento em execucao...')
	    
		nDif	 := ( TARQ->ZAF_SALDO * nFator ) - TARQ->ZAF_SALDO
		
		IF TARQ->ZAF_SALDO+nDif > 0 
	 
			&& Atualizar SE2 com os novos valores
			cQuery := " UPDATE " + RETSQLNAME("SE2") + " SET " 
			cQuery += " E2_VALOR   = " + STR( Round( (TARQ->ZAF_SALDO+nDif) ,2) ) + ",  "
			cQuery += " E2_SALDO   = " + STR( Round( (TARQ->ZAF_SALDO+nDif) ,2) ) + ",  "	
			cQuery += " E2_VLCRUZ  = " + STR( Round( (TARQ->ZAF_SALDO+nDif) ,2) ) + ",  "	
			cQuery += " E2_BASEPIS = " + STR( Round( (TARQ->ZAF_SALDO+nDif) ,2) ) + ",  "	
			cQuery += " E2_BASECOF = " + STR( Round( (TARQ->ZAF_SALDO+nDif) ,2) ) + ",  "	
			cQuery += " E2_BASECSL = " + STR( Round( (TARQ->ZAF_SALDO+nDif) ,2) ) + ",  "	
			cQuery += " E2_BASEIRF = " + STR( Round( (TARQ->ZAF_SALDO+nDif) ,2) ) + ",  "	
			cQuery += " E2_BASEISS = " + STR( Round( (TARQ->ZAF_SALDO+nDif) ,2) ) + ",  "	
			cQuery += " E2_BASEINS = " + STR( Round( (TARQ->ZAF_SALDO+nDif) ,2) ) + "   "	
			cQuery += " WHERE D_E_L_E_T_ <> '*' "
			cQuery += " AND E2_FILIAL     = '" + XFILIAL("SE2")   + "'  " 	
			cQuery += " AND E2_NUM 		  = '" + TARQ->ZAF_NUMERO + "'  " 	
			cQuery += " AND E2_PREFIXO 	  = '" + TARQ->ZAF_PREFIX + "'  " 	
			cQuery += " AND E2_PARCELA	  = '" + TARQ->ZAF_PARCEL + "'  "
			cQuery += " AND E2_SALDO      > 0  " 	
		
			tcSqlExec(cQuery)
			tcSqlExec('commit')
		
		ELSE //Ajuste para do William Costa pois se o saldo chegar a zero precisa somente zerar o saldo do titulo
	
			&& Atualizar SE2 com os novos valores
			cQuery := " UPDATE " + RETSQLNAME("SE2") + " SET " 
			cQuery += " E2_SALDO   = " + STR( Round( (0) ,2) ) 
			cQuery += " WHERE D_E_L_E_T_ <> '*' "
			cQuery += " AND E2_FILIAL     = '" + XFILIAL("SE2")   + "'  " 	
			cQuery += " AND E2_NUM 		  = '" + TARQ->ZAF_NUMERO + "'  " 	
			cQuery += " AND E2_PREFIXO 	  = '" + TARQ->ZAF_PREFIX + "'  " 	
			cQuery += " AND E2_PARCELA	  = '" + TARQ->ZAF_PARCEL + "'  "
			cQuery += " AND E2_SALDO      > 0  " 	
		
			tcSqlExec(cQuery)
			tcSqlExec('commit')
		
		ENDIF
	
		&& Pocionar SE2 atualizado
		cQuery := " SELECT * FROM " + RETSQLNAME("SE2") + " "
		cQuery += " WHERE D_E_L_E_T_ <> '*' "
		cQuery += " AND E2_FILIAL     = '" + XFILIAL("SE2")   + "'  " 	
		cQuery += " AND E2_NUM 		  = '" + TARQ->ZAF_NUMERO + "'  " 	
		cQuery += " AND E2_PREFIXO 	  = '" + TARQ->ZAF_PREFIX + "'  " 	
		cQuery += " AND E2_PARCELA	  = '" + TARQ->ZAF_PARCEL + "'  "  
		cQuery += " AND E2_SALDO      > 0 " 	
	
		tcQuery cQuery New Alias "TQQ"		
	
		&& Atualizar ZAF com os novos valores ajusta correcao
		cQuery := " UPDATE " + RETSQLNAME("ZAF") + " SET " 
		cQuery += " ZAF_CORREC = " + STR( (TQQ->E2_VALOR - TARQ->ZAF_VALOR )) + "  "
		cQuery += " WHERE D_E_L_E_T_ <> '*' "
		cQuery += " AND ZAF_FILIAL    = '" + XFILIAL("SE2") + "'  " 	
		cQuery += " AND ZAF_NUMERO	  = '" + TARQ->ZAF_NUMERO + "'  " 	
		cQuery += " AND ZAF_PREFIX 	  = '" + TARQ->ZAF_PREFIX + "'  " 	
		cQuery += " AND ZAF_PARCEL	  = '" + TARQ->ZAF_PARCEL + "'  " 	
		cQuery += " AND ZAF_SALDO > 0  "   
	
		tcSqlExec(cQuery)
		tcSqlExec('commit')
	    
		IF TARQ->ZAF_SALDO+nDif > 0
			&& Atualizar ZAF com os novos valores ajusta saldo
			cQuery := " UPDATE " + RETSQLNAME("ZAF") + " SET " 
			cQuery += " ZAF_SALDO = ZAF_VALOR + ZAF_CORREC  "
			cQuery += " WHERE D_E_L_E_T_ <> '*'   "
			cQuery += " AND ZAF_FILIAL    = '" + XFILIAL("SE2") + "'  " 	
			cQuery += " AND ZAF_NUMERO	  = '" + TARQ->ZAF_NUMERO + "'  " 	
			cQuery += " AND ZAF_PREFIX 	  = '" + TARQ->ZAF_PREFIX + "'  " 	
			cQuery += " AND ZAF_PARCEL	  = '" + TARQ->ZAF_PARCEL + "'  " 	
		    cQuery += " AND ZAF_SALDO > 0  "   
		    
			tcSqlExec(cQuery)
			tcSqlExec('commit')
		
		ELSE                   
		
			&& Atualizar ZAF com os novos valores ajusta saldo
			cQuery := " UPDATE " + RETSQLNAME("ZAF") + " SET " 
			cQuery += " ZAF_SALDO = 0  "
			cQuery += " WHERE D_E_L_E_T_ <> '*'   "
			cQuery += " AND ZAF_FILIAL    = '" + XFILIAL("SE2") + "'  " 	
			cQuery += " AND ZAF_NUMERO	  = '" + TARQ->ZAF_NUMERO + "'  " 	
			cQuery += " AND ZAF_PREFIX 	  = '" + TARQ->ZAF_PREFIX + "'  " 	
			cQuery += " AND ZAF_PARCEL	  = '" + TARQ->ZAF_PARCEL + "'  " 	
		    cQuery += " AND ZAF_SALDO > 0  "   
		    
			tcSqlExec(cQuery)
			tcSqlExec('commit')
		
		ENDIF	
			                                                            
		&& Atualiza cabecalho das obrigacoes
		
		cQuery := " SELECT SUM(ZAF_SALDO) AS SALDO "
		cQuery += " FROM " + RetSqlName("ZAF") + "  "
		cQuery += " WHERE ZAF_NUMERO = '" + TARQ->ZAF_NUMERO + "'  "   
		cQuery += "   AND D_E_L_E_T_ <> '*' "
		
		tcQuery cQuery New Alias "TOLD"
		
		nSaldoZF := TOLD->SALDO
		
		TOLD->(dbCLoseArea())
	
		&& Atualizar ZAH com os novos valores
		cQuery := " UPDATE " + RETSQLNAME("ZAH") + " SET " 
		cQuery += " ZAH_SALDO = " + STR( nSaldoZF ) + "  "
		cQuery += " WHERE D_E_L_E_T_ <> '*' "
		cQuery += " AND ZAH_FILIAL    = '" + XFILIAL("ZAH") + "'  " 	
		cQuery += " AND ZAH_NUMERO	  = '" + TARQ->ZAF_NUMERO + "'  " 	
	    cQuery += " AND ZAH_SALDO     > 0  "
		
		tcSqlExec(cQuery)
		tcSqlExec('commit')	
	    
		&& Dados para contabilizacao
		
		nValAtu := IIF(nDif > 0,nDif,0)
		
		aAdd( aContab, {	TARQ->ZAF_NUMERO ,	nValAtu , TQQ->E2_NUM, TQQ->E2_PARCELA,TQQ->E2_FORNECE, TQQ->E2_NOMFOR,TQQ->E2_LOJA    })			
		/*
		While TQQ->(!Eof())
		
			nValAtu := nDif && Round( (TARQ->ZAF_VALOR+TARQ->ZAF_CORREC) * MV_PAR02,2) 
	
			&& Preparacao - Contabilizacao dos titulos CT2
			nI := Ascan ( aContab, {|X|X[1] == TARQ->ZAF_NUMERO })
			&&If nI == 0
				aAdd( aContab, {	TARQ->ZAF_NUMERO ,	nValAtu , TQQ->E2_NUM, TQQ->E2_PARCELA,TQQ->E2_FORNECE, TQQ->E2_NOMFOR,TQQ->E2_LOJA    })		
			&&Else
			&&	aContab[nI,02] += Round((TQQ->E2_VALOR - TARQ->ZAF_VALOR ),2)
			&&EndIf
			
			TQQ->(dbSkip())
		
		EndDo
		*/
		
	    TQQ->(dbCloseArea())
	
		TARQ->(dbSkip())
	
	EndDo
	
	If Len(aContab) > 0
		ProcRegua(Len(aContab))        
		cDoc := Criavar("CT2_DOC",.F.)
		
		&& Busca proximo numero de documento
		If !ProxDoc(MV_PAR03,"008850","001",@cDoc)
			Help(" ",1,"DOCESTOUR")
			lRet := .F.
		Endif
		
		dbSelectArea("CT2")
		CT2->(dbGoBottom())
		
		cSeq := CT2->CT2_SEQUEN
		
		cSeq := Soma1(cSeq)
		
		For n1 := 1 to Len(aContab)
			
			IncProc('Contabilizando...')
			
			nValCont := aContab[n1,02]
			If nValCont < 0
				nValCont := nValCont * (-1)
			EndIf	
			
			dbSelectArea("CT2")
			RecLock("CT2",.T.)
				
				CT2->CT2_FILIAL		:= xFilial("CT2")
				CT2->CT2_DATA		:= MV_PAR03
				CT2->CT2_DOC		:= cDoc
				CT2->CT2_LOTE		:= "008850"	
				CT2->CT2_SBLOTE		:= "001"	
				CT2->CT2_LINHA		:= "001" //StrZero(n1,3)         // alterado por Adriana em 10/10/14 - chamado 020654
				CT2->CT2_DC			:= '3'
				CT2->CT2_DEBITO		:= MV_PAR04
				CT2->CT2_CREDITO	:= MV_PAR05
				CT2->CT2_VALOR		:= nValCont
				CT2->CT2_HIST		:= "ATUAL.PARC.REC.JUD.REF.TIT." + Alltrim(aContab[n1,03])+"-"+Alltrim(aContab[n1,04])+"-"+Alltrim(aContab[n1,05])+"-"+Alltrim(aContab[n1,06])+ Alltrim(MV_PAR06)
				CT2->CT2_FILKEY		:= "01"
				CT2->CT2_PREFIX		:= 'ADR'
				CT2->CT2_NUMDOC		:= aContab[n1,03]
				CT2->CT2_PARCEL		:= aContab[n1,04]
				CT2->CT2_TIPODC		:= 'RJ'
				CT2->CT2_CLIFOR		:= aContab[n1,05]
				CT2->CT2_LOJACF		:= aContab[n1,07]     
				CT2->CT2_ITEMD		:= '121'
				CT2->CT2_ITEMC		:= '121' 
				CT2->CT2_MOEDLC		:= '01'
				CT2->CT2_EMPORI		:= '01'
				CT2->CT2_FILORI		:= '01' 
				CT2->CT2_SEQUEN		:= '0000000001' //cSeq - alterado por Adriana em 10/10/14 - chamado 020654 
				CT2->CT2_TPSALD		:= '1'
				CT2->CT2_ORIGEM		:= XFILIAL("CT2") + '-ADR-RJ-' + aContab[n1,03] + '-' + aContab[n1,04] + '-' + aContab[n1,05]
				CT2->CT2_AGLUT		:= '2'
	
			MsUnlock("CT2")
			//cSeq := Soma1(cSeq) - alterado por Adriana em 10/10/14 - chamado 020654 
		    cDoc := strzero(val(cDoc)+1,6) //Incrementa Documento - Incluido por Adriana em 10/10/14 - chamado 020654   
			
		Next n1 
		
		//Incrementa tabela de controle de numera็ใo de lote+documento - Incluido por Adriana em 10/10/14 - chamado 020654                 
		DbSelectArea("CTF")
		RecLock("CTF",.T.)
		CTF_FILIAL		:= xFilial("CTF")
		CTF_DATA		:= MV_PAR03
		CTF_LOTE		:= "008850"
		CTF_SBLOTE		:= "001"
		CTF_DOC			:= cDoc
		MsUnlock("CTF")                                
		//
	EndIf
	
	TARQ->(dbCloseArea())

Return()     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADA7APLICARบAutor  ณMicrosiga           บ Data ณ  06/10/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ValidPerg()

	Local _sAlias := Alias()
	Local aRegs := {}
	Local i,j
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	
	aAdd(aRegs,{cPerg,"01","Periodo Correcao " ,"" ,"","mv_ch1","C",03,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","ZAG" })
	aAdd(aRegs,{cPerg,"02","Fator Correcao  "  ,"" ,"","mv_ch2","N",12,8,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","" })
	aAdd(aRegs,{cPerg,"03","Data Contab.    "  ,"" ,"","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","" })
	aAdd(aRegs,{cPerg,"04","Conta Debito    "  ,"" ,"","mv_ch4","C",20,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","CT1" })
	aAdd(aRegs,{cPerg,"05","Conta Credito   "  ,"" ,"","mv_ch5","C",20,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","CT1" })
	aAdd(aRegs,{cPerg,"06","Hist๓rico       "  ,"" ,"","mv_ch6","C",50,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","" })
	
	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
	
	dbSelectArea(_sAlias)

Return()