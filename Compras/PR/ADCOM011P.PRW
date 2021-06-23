#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} User Function ADCOM011P
	Aplica Bloqueio de titulo com base nos criterio de pontuacao definidos pela politica de seguranca financeira
	@type  Function
	@author Ricardo Lima
	@since 06/04/2018
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 058634 - FWNM        - 04/06/2020 - || OS 060132 || FINANCAS || ANA || 8384 || CENTRAL DE APROVACAO
	@history chamado 058634 - FWNM        - 15/06/2020 - || OS 060341 || FINANCAS || ANA || 8384 || PONTUACAO PAINEL
	@history ticket    4759 - Abel Babini - 09/11/2020 - Ajustar query referente a Bloqueio Título à Pagar - Regra "Fora da Média"
/*/
User Function ADCOM011P( F1VALBRUT , f1Filial , F1DOC , F1SERIE , F1FORNECE , F1LOJA, F1TIPO, F1ESPECIE )

	Local cQuery   := ""
	Local nQtdMes  := 0
	Local nTotGer  := 0
	Local sDataInicio := dtos(date()) // Str(Year(dDataBase),4) + "0101"
	Local sDataFim := dtos(date()-365) // Str(Year(dDataBase),4) + "1231"
	Local nPtoCrt  := 0
	Local cCrtPto1 := "N" // media de valor
	Local cCrtPto2 := "N" // Pesquisa XML da nota
	Local cCrtPto3 := "N" // Analisa NF sem Pedido
	Local cCrtPto4 := "N" // Vistoria Fisica da Entrega
	Local cCrtPto5 := "N" // Aprovação Tecnica do Serviço
	Local cCrtPto6 := "N" // integração feita por modulo ou subsistemas
	Local cCrtPto7 := "N" // Validação de Chave Primaria
	Local cCrtPto8 := "N" // Validação de Duplicidade(Fornecedor+Valor+Emissão)
	Local cCrtPto9 := "N" // Pagamento POsterior a Entrega
	Local lCrtApr  := .F.
	Local lRecVfis := .F.
	Local sCnpjF   := ""
	Local cTpDivf  := "000005"
	Local nPosEms  := ""
	Local lRecATec := .F.

	Local cAssunto	:= "Central de Aprovação"
	Local cMensagem	:= ""
	Local cmaildest := SuperGetMv( "MV_#ADCOM1" , .F. , "ricardo.lima@adoro.com.br" ,  )
	Local lVlrMedD1 := .F.
	Local sTpSerAN  := SuperGetMv( "MV_#ADCOM2" , .F. , "CTEOS|NFPS|NFS|NFS-E|NFSC|NFST|NTSC|NTST|RPS" ,  )
	Local sTpNfXML  := SuperGetMv( "MV_#ADCOM3" , .F. , "SPED" ,  )

	Local nTotReg  := 0
	
	Local lExistXML     := .f.

	//ticket    4759 - Abel Babini - 09/11/2020 - Ajustar query referente a Bloqueio Título à Pagar - Regra "Fora da Média"			
	Local cMVCFPr		:= GetMV("MV_#ADCOM4",,"1456") //CFOP´S CONSIDERADOS PARA CALCULA DO DESVIO DO VALOR MÉDIO
	Local cCFAvgPr	:= FormatIn(cMVCFPr,",")
	Local nMVPerMx	:= GetMV("MV_#ADCOM5",,10) //PERCENTUAL ACEITO COMO DESVIO MÁXIMO


	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	DbSelectArea("SE2")
    DbSetOrder(6)
    IF DbSeek( f1Filial + F1FORNECE + F1LOJA + F1SERIE + F1DOC )
		nPosEms  := SE2->E2_EMISSAO
	else
		Return(.T.)
	ENDIF

	// Media de Valor
	IF SELECT("ADCOM011P") > 0
		ADCOM011P->( DBCLOSEAREA() )
	ENDIF

	DbSelectArea("SD1")
	DbSetOrder(1) // SD1010 1 D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM, R_E_C_N_O_, D_E_L_E_T_
	if DbSeek( FWxFilial("SD1") + F1DOC + F1SERIE + F1FORNECE + F1LOJA )
		While SD1->(!eof()) .AND. FWxFilial("SD1")=SD1->D1_FILIAL .AND. F1DOC=SD1->D1_DOC .AND. F1SERIE=SD1->D1_SERIE .AND. F1FORNECE=SD1->D1_FORNECE .AND. F1LOJA=SD1->D1_LOJA
			
			IF SELECT("ADCOM011P") > 0
				ADCOM011P->( DBCLOSEAREA() )
			ENDIF
			//INICIO ticket    4759 - Abel Babini - 09/11/2020 - Ajustar query referente a Bloqueio Título à Pagar - Regra "Fora da Média"			
			/*
			cQuery := " SELECT D1_FILIAL, D1_FORNECE, D1_LOJA, LEFT(D1_EMISSAO,6) AS D1_EMISSAO, SUM(D1_VUNIT) AS D1_VUNIT, COUNT(LEFT(D1_EMISSAO,6)) QTD_NF_MES, SUM(D1_VUNIT) / COUNT(LEFT(D1_EMISSAO,6)) MEDIA_MENSAL "
			cQuery += " FROM "+RetSqlName("SD1")+" D1 "
			cQuery += " WHERE D1_EMISSAO BETWEEN '"+sDataFim+"' AND '"+sDataInicio+"' AND D1_FORNECE = '"+F1FORNECE+"' AND D1_LOJA = '"+F1LOJA+"' "
			cQuery += " AND D1_COD = '"+SD1->D1_COD+"' "
			cQuery += " AND D1_FILIAL = '"+f1Filial+"' AND D1.D_E_L_E_T_ = ' ' "
			cQuery += " GROUP BY D1_FILIAL, D1_FORNECE, D1_LOJA, LEFT(D1_EMISSAO,6) "
			cQuery += " ORDER BY LEFT(D1_EMISSAO,6) "
			
			TCQUERY cQuery new alias "ADCOM011P"

			WHILE ADCOM011P->( !EOF() )
				nTotGer += ADCOM011P->MEDIA_MENSAL
				NQtdMes++
				ADCOM011P->( DbSkip() )
			END

			If nTotGer > 0
				IF SD1->D1_VUNIT > ( (nTotGer / NQtdMes) )  // Ricardo Lima - 12/12/2018
					//lVlrMedD1 := .F.	
					lVlrMedD1 := .T.	
				ENDIF
			Endif
			*/
			cQuery := " SELECT "
			cQuery += " ABS(ISNULL((AVG(D1_VUNIT) / (SELECT AVG(D1_VUNIT) FROM "+RetSqlName("SD1")+" WHERE D1_FILIAL = '"+f1Filial+"' AND D1_DOC = '"+F1DOC+"' AND D1_FORNECE = '"+F1FORNECE+"' AND D1_LOJA =  '"+F1LOJA+"' AND D_E_L_E_T_ = '') -1) * 100,0)) AS MEDIA_MENSAL "
			cQuery += " FROM "+RetSqlName("SD1")+" D1 "
			cQuery += " WHERE D1_FORNECE = '"+F1FORNECE+"' AND D1_LOJA = '"+F1LOJA+"' "
			cQuery += " AND D1_EMISSAO >= '"+dtos(dDatabase - 90)+"' "
			cQuery += " AND D1_COD = '"+SD1->D1_COD+"' "
			cQuery += " AND D1_CF IN "+cCFAvgPr+" "
			cQuery += " AND D1_FILIAL = '"+f1Filial+"' AND D1.D_E_L_E_T_ = ' ' "
			cQuery += " GROUP BY D1_FILIAL, D1_FORNECE, D1_LOJA "

			TCQUERY cQuery new alias "ADCOM011P"
			
			If ADCOM011P->MEDIA_MENSAL > nMVPerMx
				lVlrMedD1 := .T.	
			Endif
			//FIM ticket    4759 - Abel Babini - 09/11/2020 - Ajustar query referente a Bloqueio Título à Pagar - Regra "Fora da Média"

		  SD1->( DbSkip() )
		  
		  // nTotGer := 0 	//ticket    4759 - Abel Babini - 09/11/2020 - Ajustar query referente a Bloqueio Título à Pagar - Regra "Fora da Média"
		  // NQtdMes := 0  	//ticket    4759 - Abel Babini - 09/11/2020 - Ajustar query referente a Bloqueio Título à Pagar - Regra "Fora da Média"

		END

		If lVlrMedD1
			nPtoCrt  := nPtoCrt + 1    
			//cCrtPto1 := "N"
			cCrtPto1 := "S"
		Endif

	endif

 	// Pesquisa XML da nota
	//If F1ESPECIE $ sTpNfXML 
	If AllTrim(F1ESPECIE) $ sTpNfXML // Chamado n. 058634 || OS 060341 || FINANCAS || ANA || 8384 || PONTUACAO PAINEL - FWNM - 15/06/2020

		// Chamado n. 058634 || OS 060132 || FINANCAS || ANA || 8384 || CENTRAL DE APROVACAO - FWNM - 04/06/2020
		lExistXML := .f.
		
		SF1->( dbSetOrder(1) ) // F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO, R_E_C_N_O_, D_E_L_E_T_
		If SF1->( dbSeek( FWxFilial("SF1") + F1DOC + F1SERIE + F1FORNECE + F1LOJA + F1TIPO ) )

			// Busco XML na tabela da central - RECNFXML
			If Select("Work") > 0
				Work->( dbCloseArea() )
			EndIf

			cQuery := " SELECT COUNT(1) TT 
			cQuery += " FROM RECNFXML (NOLOCK) 
			cQuery += " WHERE XML_CHAVE='"+SF1->F1_CHVNFE+"' 
			cQuery += " AND XML_CHAVE<>''
			cQuery += " AND D_E_L_E_T_=''

			tcQuery cQuery New Alias "Work"

			If Work->TT >= 1
				lExistXML := .t.
			EndIf

			// Busco XML na tabela da central - RECNFCTE
			If !lExistXML

				If Select("Work") > 0
					Work->( dbCloseArea() )
				EndIf

				cQuery := " SELECT COUNT(1) TT 
				cQuery += " FROM RECNFCTE (NOLOCK) 
				cQuery += " WHERE XML_CHAVE='"+SF1->F1_CHVNFE+"' 
				cQuery += " AND XML_CHAVE<>''
				cQuery += " AND D_E_L_E_T_='' 

				tcQuery cQuery New Alias "Work"

				If Work->TT >= 1
					lExistXML := .t.
				EndIf

			EndIf

		EndIf
		//

		If !lExistXML

			DbSelectArea("SA2")
			DbSetOrder(1)
			if DbSeek( FWxFilial("SA2") + F1FORNECE + F1LOJA )
				sCnpjF := SA2->A2_CGC
			endif
				
			IF SELECT("ADCOM011P") > 0
				ADCOM011P->( DBCLOSEAREA() )
			ENDIF
				
			cQuery := " SELECT COUNT(1) TT "
			cQuery += " FROM RECNFXML "
			cQuery += " WHERE SUBSTRING(XML_NUMNF,4,9) = '"+ F1DOC +"' AND XML_EMIT = '"+ sCnpjF +"' "
			cQuery += " AND D_E_L_E_T_ = ' ' "
			TCQUERY cQuery new alias "ADCOM011P"

			If ADCOM011P->TT >= 1
				lExistXML := .t.
			EndIf
		
		EndIf

		If !lExistXML

			IF SELECT("ADCOM011P") > 0
				ADCOM011P->( DBCLOSEAREA() )
			ENDIF
				
			cQuery := " SELECT COUNT(1) TT 
			cQuery += " FROM RECNFCTE (NOLOCK) 
			cQuery += " WHERE SUBSTRING(XML_NUMNF,4,9) = '"+ F1DOC +"' AND XML_EMIT = '"+ sCnpjF +"' "
			cQuery += " AND D_E_L_E_T_ = ' ' "
			TCQUERY cQuery new alias "ADCOM011P"

			If ADCOM011P->TT >= 1
				lExistXML := .t.
			EndIf

		EndIf

		/*
		DbSelectArea("SA2")
		DbSetOrder(1)
		if DbSeek( FWxFilial("SA2") + F1FORNECE + F1LOJA )
			sCnpjF := SA2->A2_CGC
		endif
		
		IF SELECT("ADCOM011P") > 0
			ADCOM011P->( DBCLOSEAREA() )
		ENDIF
		
		cQuery := " SELECT * "
		cQuery += " FROM RECNFXML "
		cQuery += " WHERE SUBSTRING(XML_NUMNF,4,9) = '"+ F1DOC +"' AND XML_EMIT = '"+ sCnpjF +"' "
		cQuery += " AND D_E_L_E_T_ = ' ' "
		TCQUERY cQuery new alias "ADCOM011P"
		
		IF ADCOM011P->( !EOF() )	
			IF SUBSTR(ADCOM011P->XML_NUMNF,4,9) = F1DOC 
				nPtoCrt  := nPtoCrt + 1
				cCrtPto2 := "N"
			ENDIF	
		ENDIF
		*/

		If !lExistXML .and. AllTrim(SF1->F1_FORMUL)<>"S"
			nPtoCrt  := nPtoCrt + 1
			cCrtPto2 := "S"
			//cCrtPto2 := "N"
		EndIf

		IF SELECT("ADCOM011P") > 0
			ADCOM011P->( DBCLOSEAREA() )
		ENDIF

		If Select("Work") > 0
			Work->( dbCloseArea() )
		EndIf

	Endif

	// Analisa NF sem Pedido
	SF1->( dbSetOrder(1) ) // F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO, R_E_C_N_O_, D_E_L_E_T_
	If SF1->( dbSeek( FWxFilial("SF1") + F1DOC + F1SERIE + F1FORNECE + F1LOJA + F1TIPO ) )

		If Empty(SF1->F1_NOTASAG) .or. AllTrim(SF1->F1_FORMUL)<>"S"	// Chamado n. 058634 || OS 060132 || FINANCAS || ANA || 8384 || CENTRAL DE APROVACAO - FWNM - 04/06/2020

			DbSelectArea("SD1")
			DbSetOrder(1) // SD1010 1 D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM, R_E_C_N_O_, D_E_L_E_T_
			if DbSeek( FWxFilial("SD1") + F1DOC + F1SERIE + F1FORNECE + F1LOJA )
				
				While SD1->(!eof()) .AND. FWxFilial("SD1")=SD1->D1_FILIAL .AND. F1DOC=SD1->D1_DOC .AND. F1SERIE=SD1->D1_SERIE .AND. F1FORNECE=SD1->D1_FORNECE .AND. F1LOJA=SD1->D1_LOJA
					IF EMPTY(SD1->D1_PEDIDO)
						//lCrtApr := .F.
						lCrtApr := .T.
						Exit
					ENDIF
					SD1->( DbSkip() )
				END

				IF lCrtApr
					nPtoCrt  := nPtoCrt + 1
					cCrtPto3 := "S"
					//cCrtPto3 := "N"
				ENDIF


			endif

		EndIf

	EndIf


	// Vistoria Fisica da Entrega
	DbSelectArea("SD1")
	DbSetOrder(1)
	if DbSeek( FWxFilial("SD1") + F1DOC + F1SERIE + F1FORNECE + F1LOJA )
		
		While SD1->(!eof()) .AND. FWxFilial("SD1")=SD1->D1_FILIAL .AND. F1DOC=SD1->D1_DOC .AND. F1SERIE=SD1->D1_SERIE .AND. F1FORNECE=SD1->D1_FORNECE .AND. F1LOJA=SD1->D1_LOJA
			IF SD1->D1_XRCVFIS <> '1'
				lRecVfis := .T.						
			ENDIF
			SD1->( DbSkip() )
		END
		
		IF lRecVfis
		  nPtoCrt  := nPtoCrt + 1
		  cCrtPto4 := "S"
		  //cCrtPto4 := "N"
		ENDIF
	
	endif

	// Aprovação Tecnica do Serviço
	If AllTrim(F1ESPECIE) $ sTpSerAN
		
		DbSelectArea("SD1")
		DbSetOrder(1)
		if DbSeek( FWxFilial("SD1") + F1DOC + F1SERIE + F1FORNECE + F1LOJA )
			
			While SD1->(!eof()) .AND. FWxFilial("SD1")=SD1->D1_FILIAL .AND. F1DOC=SD1->D1_DOC .AND. F1SERIE=SD1->D1_SERIE .AND. F1FORNECE=SD1->D1_FORNECE .AND. F1LOJA=SD1->D1_LOJA
				
				IF SD1->D1_XAPRTEC <> 'A'
					lRecATec := .T.
					Exit
				ENDIF
		
				SD1->( DbSkip() )
		
			END
		
			IF lRecATec
				nPtoCrt  := nPtoCrt + 1
				cCrtPto5 := "S"
				//cCrtPto5 := "N"
			ENDIF
		
		endif
	
	else
	
		nPtoCrt  := nPtoCrt + 1
		cCrtPto5 := "N"
	
	EndIf
	
	// Integração por Modulo
	//if !Empty(F1DOC)
	if Empty(AllTrim(F1DOC))
		nPtoCrt  := nPtoCrt + 1
		cCrtPto6 := "S"
		//cCrtPto6 := "N"
	Endif

	// Validação de Chave Primaria
	IF SELECT("ADCOM011P") > 0
		ADCOM011P->( DBCLOSEAREA() )
	ENDIF
	cQuery := " SELECT * FROM "+RetSqlName("SE2")+" "
	cQuery += " WHERE E2_FORNECE = '"+ F1FORNECE +"' AND E2_LOJA = '"+ F1LOJA +"'  "
	cQuery += " AND E2_NUM = '"+F1DOC+"' AND E2_PREFIXO = '"+F1SERIE+"' "
	cQuery += " AND E2_TIPO = '"+F1TIPO+"' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	TCQUERY cQuery new alias "ADCOM011P"
	nTotReg := Contar("ADCOM011P","!Eof()")  
	
	//If nTotReg = 1
	If nTotReg >= 2
		nPtoCrt  := nPtoCrt + 1
		cCrtPto7 := "S"
		//cCrtPto7 := "N"
	Endif

	// Validação de Duplicidade
	IF SELECT("ADCOM011P") > 0
		ADCOM011P->( DBCLOSEAREA() )
	ENDIF
	cQuery := " SELECT * FROM "+RetSqlName("SE2")+" "
	cQuery += " WHERE E2_FORNECE = '"+ F1FORNECE +"' AND E2_LOJA = '"+ F1LOJA +"' "
	cQuery += " AND E2_EMISSAO = '"+ dtos(nPosEms) +"' AND E2_VALOR = "+Alltrim(Str(F1VALBRUT))+" "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	TCQUERY cQuery new alias "ADCOM011P"
	nTotReg := Contar("ADCOM011P","!Eof()")  
	
	//If nTotReg = 1
	If nTotReg >= 2
		nPtoCrt  := nPtoCrt + 1
		cCrtPto8 := "S"
		//cCrtPto8 := "N"
	EndIf
	
	// Pagamento Posterior a Entrega
	nPtoCrt  := nPtoCrt + 1
	cCrtPto9 := "N"

// ATUALIZA TITULO COM DIVERGENCIA PARA CRITERIO DE PONTUACAO
//if nPtoCrt < 9
	DbSelectArea("SE2")
    DbSetOrder(6)
    IF DbSeek( f1Filial + F1FORNECE + F1LOJA + F1SERIE + F1DOC )
		RecLock("SE2",.F.)
			SE2->E2_XDIVERG := 'S'
			SE2->E2_XPTCRTA := cCrtPto1 + cCrtPto2 + cCrtPto3 + cCrtPto4 + cCrtPto5 + cCrtPto6 + cCrtPto7 + cCrtPto8 + cCrtPto9
		MsUnlock()
	Endif
	
	DbSelectArea("SX5")
	DbSetOrder(1)
	DbSeek( FwxFilial("SX5") + 'Z9' + cTpDivf )
		
	// gera registro para aprovacao		
	RecLock("ZC7",.T.)
		ZC7->ZC7_FILIAL := FwxFilial("SE2")
		ZC7->ZC7_PREFIX	:= SE2->E2_PREFIXO
		ZC7->ZC7_NUM   	:= SE2->E2_NUM
		ZC7->ZC7_PARCEL	:= SE2->E2_PARCELA
		ZC7->ZC7_TIPO   := SE2->E2_TIPO
		ZC7->ZC7_CLIFOR	:= SE2->E2_FORNECE
		ZC7->ZC7_LOJA  	:= SE2->E2_LOJA
		ZC7->ZC7_VLRBLQ	:= SE2->E2_VALOR
		ZC7->ZC7_TPBLQ 	:= cTpDivf
		ZC7->ZC7_DSCBLQ	:= SX5->X5_DESCRI
		ZC7->ZC7_RECPAG := "P"
		if nPtoCrt < 7
			ZC7->ZC7_NIVSEG := '03'
		else
			ZC7->ZC7_NIVSEG := '02'
		EndIf
		ZC7->ZC7_USRALT := __cUserID
	MSUnlock()	 

	// Envio de Pendencia Para o Aprovador não Ausente
	c2Query := " SELECT ZC3_CODUSU, ZC3_NOMUSU, ZCF_NIVEL, ZCF_CODIGO, ZC3_APRATV "
	c2Query += " FROM "+RetSqlName("ZC3")+" ZC3 "
	c2Query += " INNER JOIN "+RetSqlName("ZCF")+" ZCF ON ZC3_CODUSU=ZCF_APROVA AND ZCF.D_E_L_E_T_ = ' ' "
	c2Query += " WHERE ZCF_CODIGO = '"+cTpDivf+"' AND ZC3_APRATV <> '1' AND ZC3.D_E_L_E_T_ = ' ' "
	c2Query += " ORDER BY ZCF_NIVEL "
	If Select("TMPZC3") > 0
		TMPZC3->(DbCloseArea())		
	EndIf
	TcQuery c2Query New Alias "TMPZC3"
	IF !EMPTY(TMPZC3->ZC3_CODUSU)
		cmaildest := AllTrim(UsrRetMail( TMPZC3->ZC3_CODUSU ))
	ENDIF

	cMensagem := u_WGFA050FIN( FwxFilial("SE2") , SE2->E2_PREFIXO , SE2->E2_NUM , SE2->E2_PARCELA , SE2->E2_FORNECE , SE2->E2_LOJA , SE2->E2_VALOR , Alltrim(SX5->X5_DESCRI) , 'F' )
  	IF !EMPTY(cmaildest)
	  u_F050EnvWF( cAssunto , cMensagem , cmaildest , '' )
	Endif

//else

	/*
	DbSelectArea("SE2")
    DbSetOrder(6)
    IF DbSeek( f1Filial + F1FORNECE + F1LOJA + F1SERIE + F1DOC )
		RecLock("SE2",.F.)	
			SE2->E2_XPTCRTA := cCrtPto1 + cCrtPto2 + cCrtPto3 + cCrtPto4 + cCrtPto5 + cCrtPto6 + cCrtPto7 + cCrtPto8 + cCrtPto9
		MsUnlock()
	Endif	
	*/

//endif

Return(.T.)
