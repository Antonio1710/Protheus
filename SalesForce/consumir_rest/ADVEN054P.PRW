#Include "Totvs.ch"
#Include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADVEN054P      ºAutor  ³Everson      º Data ³  22/01/2018   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para envio de pausas ao SalesForce.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Chamado 037261.                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ADVEN054P(cData,lAut) // U_ADVEN054P("20180219",.F.)  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea   := GetArea()

	Default cData := ""
	Default lAut  := .F.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Função para envio de pausas ao SalesForce')

	//
	If ! lAut
		MsAguarde({|| Processar(cData,lAut) },"Aguarde","Enviando pausas(SF)...")

	Else
		              Processar(cData,lAut)

	EndIf

	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Processar      ºAutor  ³Everson      º Data ³  22/01/2018   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processamento dos envios.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Chamado 037261.                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Processar(cData,lAut)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aParametros := {}
	Local aResponse	  := {}
	Local lLogin	  := .F.
	Local cQuery	  := ""
	Local cServTab	  := "/services/data/v41.0/sobjects/Pausa__c/"
	Local cCmpChv	  := "CHVSF"
	Local cObjeto	  := "cabeçalho pausa"
	Local cChvExt	  := "Codigo__c/"
	Local aRetOk	  := {}
	Local cMsg		  := ""

	//Efetura login no SalesForce.
	//lLogin := Static Call(ADVEN075P,loginSF,@aResponse,@cMsg,lAut)
	//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
    lLogin := u_VEN075A1(@aResponse,@cMsg,lAut)

	//
	If ! lLogin
		Return Nil

	EndIf

	//Obtém a query.
	cQuery := scriptSql(cData)

	//Adiciona parâmetros ao vetor.
	Aadd(aParametros,aResponse)
	Aadd(aParametros,"ADVEN054P")
	Aadd(aParametros,cQuery)
	Aadd(aParametros,lAut)
	Aadd(aParametros,cServTab)
	Aadd(aParametros,cCmpChv)
	Aadd(aParametros,cObjeto)
	Aadd(aParametros,"montJson")
	Aadd(aParametros,cChvExt)
	Aadd(aParametros,.F.)

	//Processa os registros.
	If  ! lAut
		//Processa({|| Static Call(ADVEN075P,ProcessarB,@aParametros,.F.,"PATCH",@aRetOk,.T.) },"Aguarde","Processando registro(s) ...",.T.)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		Processa({|| u_VEN075A4( @aParametros,.F.,"PATCH",@aRetOk,.T.) },"Aguarde","Processando registro(s) ...",.T.)

	Else
		//Static Call(ADVEN075P,ProcessarB,@aParametros,.F.,"PATCH",@aRetOk,.T.)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A4( @aParametros,.F.,"PATCH",@aRetOk,.T. )


	EndIf

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³montJson     ºAutor  ³Everson     º Data ³  22/01/2018      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta json.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Chamado 037261.                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function montJson(cMetodo,cChvExt,cNmAlias)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cJson	 := ""
	Local cData	 := ""

	//
	cJson += '{'

		cJson += '"method" : "' + cMetodo + '",'
		cJson += '"url" : ' + Iif(cMetodo == "POST",'"v41.0/sobjects/Pausa__c"', '"v41.0/sobjects/Pausa__c/' + cChvExt +  Alltrim(cValtoChar((cNmAlias)->CHVSF)) + '"') + ','
		cJson += '"richInput":{'	
			
			//
			If cMetodo == "POST"
				cJson += '"Codigo__c" : "' + Alltrim(cValToChar((cNmAlias)->CHVSF)) + '",'
		
			EndIf
			
			cJson += '"Data__c" : "' + Alltrim(cValToChar((cNmAlias)->DATA)) + '",'
			cJson += '"Duracao_pausa_disc_auto__c" : "' + Alltrim(cValToChar((cNmAlias)->PAUSA_TOTAL)) + '",'
			cJson += '"Tempo_ocioso__c" : "'  + Alltrim(cValToChar((cNmAlias)->OCISOTO_TOTAL_C)) + '",'
			cJson += '"Tempo_ligacao__c" : "' + Alltrim(cValToChar((cNmAlias)->LIGACAO_TOTAL)) + '",'
			cJson += '"Tempo_total__c" : "'   + Alltrim(cValToChar((cNmAlias)->LOGADO_TOTAL)) + '",'
			cJson += '"TMA__c" : "'           + Alltrim(cValToChar((cNmAlias)->TMA__CL5)) + '",'
			cJson += '"Vendedor__r" : {'
				cJson += '"Codigo_Vendedor__c" : "' + Alltrim(cValToChar((cNmAlias)->A3_COD)) + '"'
			cJson += '}'
	
		cJson += '}'

	cJson += '},'

Return cJson
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³scriptSql     ºAutor  ³Everson      º Data ³  22/01/2018    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Script sql para consulta.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Chamado 037261.                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function scriptSql(cData)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cQuery := ""
	Local cDtFor := ""
	
	//
	cData := Alltrim(cValToChar(cData))
	cDtFor:= Substr(cData,1,4) + "-" + Substr(cData,5,2) + "-" + Substr(cData,7,2)
	cData := StrTran(DToC(SToD(cData)),"/",".")
	
	//
	cQuery := ""
	cQuery += " SELECT '" + cDtFor + "' AS DATA, " 
	cQuery += " A3_COD,A3_CODUSR,LEU.*  " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT   " 
	cQuery += " '" + cData + "' + RTRIM(LTRIM(LOGINU)) AS CHVSF,   " 
	cQuery += " LOGINU,  " 
	cQuery += " ROUND(ISNULL(TEMPO_LIGACAO__CL1,0)/0.0000115740790,0) AS LIGACAO_TOTAL, " 
	cQuery += " ROUND(ISNULL(TEMPO_TOTAL__CL4,0)/0.0000115740790,0) - " 
	cQuery += " ( " 
	cQuery += " ROUND(ISNULL(TEMPO_LIGACAO__CL1,0)/0.0000115740790,0) + " 
	cQuery += " ROUND(ISNULL(TEMPO_TOTAL_PAUSA__CL3,0)/0.0000115740790,0) " 
	cQuery += " ) AS OCISOTO_TOTAL_C, " 
	cQuery += "  " 
	cQuery += " ROUND(ISNULL(TEMPO_TOTAL_PAUSA__CL3,0)/0.0000115740790,0) AS PAUSA_TOTAL,   " 
	cQuery += " ROUND(ISNULL(TEMPO_TOTAL__CL4,0)/0.0000115740790,0) AS LOGADO_TOTAL, " 
	cQuery += " ROUND(ISNULL(TMA__CL5,0)/0.0000115740790,0) AS TMA__CL5, " 
	cQuery += " ROUND(ISNULL(TMA__CL6,0)/0.0000115740790,0) AS TMA__CL6 " 
	cQuery += " FROM OPENQUERY (NDB, " 
	cQuery += " 'SELECT LOGINU,  " 
	cQuery += " TEMPO_LIGACAO__CL1,  " 
	cQuery += " TEMPO_OCIOSO__CL2,  " 
	cQuery += " TEMPO_TOTAL_PAUSA__CL3,  " 
	cQuery += " TEMPO_TOTAL__CL4, TMA__CL5,  " 
	cQuery += " TMA__CL6   " 
	cQuery += " FROM ( " 
	cQuery += " SELECT R.LOGIN AS LOGINU, L1.Tempo_ligacao__cL1, L2.Tempo_ocioso__cL2, L3.Tempo_total_pausa__cL3, L4.Tempo_total__cL4, L5.TMA__cL5, L6.TMA__cL6   " 
	cQuery += " FROM RAMAIS R   " 
	cQuery += " LEFT JOIN   " 
	cQuery += " (SELECT sum(L.INTDURACAO) AS Tempo_ligacao__cL1, L.NOMEPOSICAO AS Vendedor__c  FROM LOGEVENTOS L  WHERE  data = ''" + cData + "''  and  (tipo = 11 or tipo = 0)  GROUP BY NOMEPOSICAO) AS L1  ON (R.LOGIN = L1.Vendedor__c)     " 
	cQuery += " LEFT JOIN   " 
	cQuery += " (SELECT sum(L.INTDURACAO) AS Tempo_ocioso__cL2, L.NOMEPOSICAO AS Vendedor__c  FROM LOGEVENTOS L  WHERE  data = ''" + cData + "''  and  (tipo = 9)  GROUP BY NOMEPOSICAO) AS L2  ON (R.LOGIN = L2.Vendedor__c)     " 
	cQuery += " LEFT JOIN   " 
	cQuery += " (SELECT sum(L.INTDURACAO) AS Tempo_total_pausa__cL3, L.NOMEPOSICAO AS Vendedor__c  FROM LOGEVENTOS L  INNER JOIN MOTIVO_PARADA MP ON L.PARAMETRO = MP.DESCRICAO WHERE  data = ''" + cData + "''  and  (tipo = 5)  GROUP BY NOMEPOSICAO) AS L3  ON (R.LOGIN = L3.Vendedor__c)     " 
	cQuery += " LEFT JOIN   " 
	cQuery += " (SELECT sum(L.INTDURACAO) AS Tempo_total__cL4, L.NOMEPOSICAO AS Vendedor__c   FROM LOGEVENTOS L  WHERE  data = ''" + cData + "''  and  (tipo = 3)  GROUP BY NOMEPOSICAO) AS L4  ON (R.LOGIN = L4.Vendedor__c)     " 
	cQuery += " LEFT JOIN   " 
	cQuery += " (SELECT avg(L.INTDURACAO) AS TMA__cL5, NOMEPOSICAO AS Vendedor__c   FROM LOGEVENTOS L  WHERE  data = ''" + cData + "''  and  (tipo = 0)  GROUP BY NOMEPOSICAO) AS L5  ON (R.LOGIN = L5.Vendedor__c)     " 
	cQuery += " LEFT JOIN   " 
	cQuery += " (SELECT avg(L.INTDURACAO) AS TMA__cL6, NOMEPOSICAO AS Vendedor__c   FROM LOGEVENTOS L  WHERE  data = ''" + cData + "''  and  (tipo = 11)  GROUP BY NOMEPOSICAO) AS L6  ON (R.LOGIN = L6.Vendedor__c)  ) AS FONTE  ')   " 
	cQuery += " WHERE   " 
	cQuery += " ISNULL(TEMPO_LIGACAO__CL1,0) + ISNULL(TEMPO_OCIOSO__CL2,0) + ISNULL(TEMPO_TOTAL_PAUSA__CL3,0) + ISNULL(TEMPO_TOTAL__CL4,0) + ISNULL(TMA__CL5,0) + ISNULL(TMA__CL6,0) > 0 " 
	cQuery += " ) AS LEU " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SA3") + " AS SA3 " 
	cQuery += " ON RTRIM(LTRIM(LEU.LOGINU)) COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(SA3.A3_XCODLEU)) " 
	cQuery += " WHERE " 
	cQuery += " SA3.D_E_L_E_T_ = '' " 
	
Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³envItens      ºAutor  ³Everson      º Data ³  09/02/2018    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Envio de detalhes.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Chamado 037261.                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function envItens(cParamBsc,lAut,cChvTab,aResponse)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aParametros := {}
	Local lLogin	:= .F.
	Local cQuery	:= ""
	Local cServTab	:= "/services/data/v41.0/sobjects/Pausa_detalhe__c/"
	Local cCmpChv	:= "CHVSF"
	Local cObjeto	:= "item pausa"
	Local cChvExt	:= "Codigo__c/"
	Local aRetOk	:= {}

	//
	cQuery := iscriptsql(cParamBsc)
	
	//Adiciona parâmetros ao vetor.
	Aadd(aParametros,aResponse)
	Aadd(aParametros,"ADVEN054P")
	Aadd(aParametros,cQuery)
	Aadd(aParametros,lAut)
	Aadd(aParametros,cServTab)
	Aadd(aParametros,cCmpChv)
	Aadd(aParametros,cObjeto)
	Aadd(aParametros,"imontJson")
	Aadd(aParametros,cChvExt)
	Aadd(aParametros,.F.)
	
	//Processa os registros.
	If  ! lAut
		//Processa({|| Static Call(ADVEN075P,ProcessarB,@aParametros,.F.,"PATCH",@aRetOk) },"Aguarde","Processando registro(s) ...",.T.)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		Processa({|| u_VEN075A4( @aParametros,.F.,"PATCH",@aRetOk) },"Aguarde","Processando registro(s) ...",.T.)

	Else
		//Static Call(ADVEN075P,ProcessarB,@aParametros,.F.,"PATCH",@aRetOk)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A4( @aParametros,.F.,"PATCH",@aRetOk )
		
	EndIf
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³imontJson     ºAutor  ³Everson     º Data ³  15/01/2018     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta json.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Chamado 037261.                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function imontJson(cMetodo,cChvExt,cNmAlias)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cJson := ""
	Local cDtF	:= ""
	Local cHtF	:= ""
	
	//		
	cJson += '{'
	
		cJson += '"method" : "' + cMetodo + '",'
		cJson += '"url" : ' + Iif(cMetodo == "POST",'"v41.0/sobjects/Pausa_detalhe__c"', '"v41.0/sobjects/Pausa_detalhe__c/' + cChvExt +  Alltrim(cValtoChar((cNmAlias)->CHVSF)) + '"') + ','
		cJson += '"richInput":{'	
		
			//
			If cMetodo == "POST"
				cJson += '"Codigo__c" : "' + Alltrim(cValToChar((cNmAlias)->CHVSF)) + '",'
		
			EndIf
			
			cDtF := Substr(Alltrim(Alltrim(cValToChar((cNmAlias)->DATAP)) ),1,10)
			cHtF := Substr(Alltrim(Alltrim(cValToChar((cNmAlias)->DATAP)) ),12,8)

			cJson += '"Pausa__r" : {'
				cJson += '"Codigo__c" : "' + Alltrim(cValToChar((cNmAlias)->CHVCAB)) + '"'
			cJson += '},'
			cJson += '"Data__c" : "' + cDtF + 'T' + cHtF + '",'
			cJson += '"Tempo__c" : "' + Alltrim(cValToChar((cNmAlias)->TEMPO_TOTAL)) + '",'
			cJson += '"Tipo__c" : "' + Alltrim(cValToChar((cNmAlias)->IDPAUSA)) + '",'
			cJson += '"Vendedor__r" : {'
				cJson += '"Codigo_Vendedor__c" : "' + Alltrim(cValToChar((cNmAlias)->A3_COD)) + '"'
			cJson += '}'

		cJson += '}'

	cJson += '},'

Return cJson
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³iscriptSql     ºAutor  ³Everson      º Data ³  15/01/2018   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Script sql para consulta itens.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Chamado 037261.                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function iscriptSql(cParamBsc,cAliasTab,cCampo)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cQuery := ""	
	Local cData	 := ""
	Local cVend	 := ""

	//
	cParamBsc := Alltrim(cValToChar(cParamBsc))
	cData	  := Alltrim(cValToChar(Substr(cParamBsc,1,8)))
	cVend	  := Alltrim(cValToChar(Substr(cParamBsc,9,Len(cParamBsc))))
	
	//
	cQuery += " SELECT " 
	cQuery += " SA3.A3_COD, SA3.A3_CODUSR, LEU.* " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " select   " 
	cQuery += " ' " + cData + " ' + RTRIM(LTRIM(VENDEDOR)) + RTRIM(LTRIM(IDPAUSA)) + RTRIM(LTRIM(DATAP)) CHVSF,   " 
	cQuery += " ' " + Alltrim(cValToChar(cParamBsc)) + " ' AS CHVCAB,   " 
	cQuery += " CAST(DATAP AS VARCHAR) AS DATAP,    " 
	cQuery += " ROUND(TEMPO/0.0000115740790,0) AS TEMPO_TOTAL,    " 
	cQuery += " VENDEDOR,    " 
	cQuery += " TIPO,    " 
	cQuery += " IDPAUSA   " 
	cQuery += " FROM OPENQUERY (NDB,'   " 
	cQuery += " SELECT Data__c AS DATAP, Tempo__c AS TEMPO, Vendedor__c AS VENDEDOR, Tipo__c AS TIPO, ID AS IDPAUSA FROM (     " 
	cQuery += " select L.HORA as Data__c, L.INTDURACAO as Tempo__c, L.NOMEPOSICAO as Vendedor__c, L.PARAMETRO as Tipo__c, MP.ID AS ID   " 
	cQuery += " from LOGEVENTOS L   " 
	cQuery += " INNER JOIN   " 
	cQuery += " MOTIVO_PARADA MP   " 
	cQuery += " ON L.PARAMETRO = MP.DESCRICAO   " 
	cQuery += " where data = ''" + cData + "'' and tipo = 5 and NOMEPOSICAO = ''" + cVend + "'') AS FONTE')   " 
	cQuery += " WHERE   " 
	cQuery += " ROUND(TEMPO/0.0000115740790,0) > 0  " 
	cQuery += " ) AS LEU " 
	cQuery += " INNER JOIN " 
	cQuery += " SA3010 AS SA3 " 
	cQuery += " ON LEU.VENDEDOR COLLATE Latin1_General_CI_AS = SA3.A3_XCODLEU  " 
	cQuery += " WHERE " 
	cQuery += " SA3.D_E_L_E_T_ = '' " 

Return cQuery
