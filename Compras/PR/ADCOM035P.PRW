#Include "Topconn.ch"       
#Include "TbiConn.ch"
#Include "TbiCode.ch"
#Include "Fileio.ch"
#Include "WFHttp.ch" 
#Include "Protheus.ch"
/*/{Protheus.doc} User Function ADCOM035P
	Envio de workflow de cotação. Chamado 054714.
	@type  Function
	@author Everson
	@since 11/05/2020
	@version 01
	@history Everson, 12/05/2020, Chamado 054714. Tratamento para envio de solicitação pelo e-mail informado na interface.
	@history Everson, 13/05/2020, Chamado 054714. Adicionado campo de observação do fornecedor e alterado o cálculo do desconto e ipi adicionado tratamento para despesas.
	@history Everson, 18/05/2020. Chamado 058244. Quando houver timeout, informar o comprador via e-mail.
	@history Everson, 31/08/2020. Chamado 060873. Tratamento para informar a moeda da cotação.
	@history Everson, 16/09/2020. Chamado 1633. Conversão da variável moeda para tipo numérico.
	/*/
User Function ADCOM035P(cCod,cLoja,cNumCT,cEmail,cArq,lEnd) //Everson - 12/05/2020. Chamado 054714.

	//Variáveis.
	Local aArea			:= GetArea() 
	Local cQuery		:= ""
    Local cC8_NUM 		:= ""
	Local cC8_NPRO		:= "" //Everson - 12/05/2020. Chamado 054714.
    Local cC8_FORNECE 	:= ""
    Local cC8_LOJA 		:= ""
    Local cEmlFor		:= ""
    Local oProcess		:= Nil                     
	Local cMailId  		:= ""                          	
	Local cHostWF  		:= Alltrim(GetMv("MV_#URLCOT"))
	Local aCondPag		:= {}
	Local cNmEnd		:= ""
	Local cNmEndCo		:= ""
	Local nHorasEx		:= GetMv("MV_#LMTCOT",,24)
	Local cDrive 		:= ""
	Local cDir   		:= ""
	Local cNome  		:= ""
	Local cExt   		:= ""
	Local cBody			:= ""
	Local cAtach 		:= Nil
	Local cFornece		:= ""

	Local cComprador	:= "" //Everson - 13/05/2020. Chamado 054714.

	Local aMoeda		:= {"1-Real (R$)","2-Dólar (US$)","4-Euro (€)"} //Everson - 31/08/2020. Chamado 060873.

	//
	Default cNumCT		:= ""
	Default cEmail		:= ""
	Default cArq		:= ""
	Default lEnd		:= .F.
    
    //Recupera as condições de pagamento.
    aCondPag := cond_Pag()
    
	//
    cQuery := BD_SC8(cCod,cLoja,cNumCT) //Monta script SQL. //Everson - 12/05/2020. Chamado 054714.
    
	//
    If Select("TRSC8") > 0
    	TRSC8->(DbCloseArea())

    EndIf
    
	//
    TcQuery cQuery New Alias "TRSC8"
    
	//	
    DbSelectArea("TRSC8")
    TRSC8->(DbGoTop())
    ProcRegua(Contar("TRSC8","!Eof()"))  
	TRSC8->(DbGoTop())                        
    While ! TRSC8->(Eof()) 

		//
		cFornece := Alltrim(TRSC8->A2_NOME) + " (" + Alltrim(TRSC8->A2_COD) + "/" + Alltrim(TRSC8->A2_LOJA)

		//
    	IncProc("Enviando solicitação de cotação para " + cFornece )

		//
    	If lEnd
			RestArea(aArea)
    		Return Nil
			
    	EndIf

		//
    	cC8_NUM     := TRSC8->C8_NUM   
		cC8_NPRO	:= TRSC8->C8_NUMPRO   
        cC8_FORNECE := TRSC8->C8_FORNECE
        cC8_LOJA    := TRSC8->C8_LOJA

		//
		If Empty(cEmail)
			cEmlFor 	:= Alltrim(TRSC8->A2_EMAIL)

		Else
			cEmlFor := cEmail

		EndIf

		// Instanciamos a classe TWFProcess informando o código e nome do processo.
		oProcess := TWFProcess():New("COTCAO", "Cotação de Preços")

		// Criamos a tafefa principal que será respondida pelo usuário.
		oProcess:NewTask("COTFOR", "/workflow/workflowcompras/cotacao/html/cotacaov2.html") //Everson - 31/08/2020. Chamado 060873.
		
		//Cabeçalho fornecedor.
		oProcess:oHtml:ValByName( "A2_NOME"		, Alltrim(TRSC8->A2_NOME) )
		oProcess:oHtml:ValByName( "C8_FORNECE"  , Alltrim(TRSC8->A2_COD)  )
		oProcess:oHtml:ValByName( "C8_LOJA"   	, Alltrim(TRSC8->A2_LOJA) )
		oProcess:oHtml:ValByName( "A2_END"    	, Alltrim(TRSC8->A2_END) )
		oProcess:oHtml:ValByName( "A2_NR_END"   , Alltrim(TRSC8->A2_NR_END) )
		oProcess:oHtml:ValByName( "A2_BAIRRO" 	, Alltrim(TRSC8->A2_BAIRRO) )
		oProcess:oHtml:ValByName( "A2_MUN" 		, Alltrim(TRSC8->A2_MUN) )
		oProcess:oHtml:ValByName( "A2_TEL"    	, Alltrim(TRSC8->A2_TEL) )
		oProcess:oHtml:ValByName( "A2_FAX"    	, Alltrim(TRSC8->A2_FAX) )

		oProcess:oHtml:ValByName( "C8_VALIDA"	, "" )
		oProcess:oHtml:ValByName( "C8_CONTATO"	, "" )

		oProcess:oHtml:ValByName( "C8_NUM"		, cC8_NUM )
		oProcess:oHtml:ValByName( "C8_NUMPRO"	, cC8_NPRO )

		//Comprador.//Everson - 13/05/2020. Chamado 054714.
		cComprador:= Alltrim(UsrFullName(__cUserId)) + "<br>" + ;
					 Alltrim(UsrRetMail(__cUserId))

		//Endereço de entrega.
		cNmEnd	 := Alltrim(SM0->M0_NOMECOM) + "<br>"  +;
					Alltrim(SM0->M0_ENDENT)	 + "<br>"  +;
					Alltrim(SM0->M0_CIDENT)	 +"-"+ Alltrim(SM0->M0_ESTENT) + "<br>" +;
					"CEP: "+ Alltrim(SM0->M0_CEPENT)   + "<br>"		

		oProcess:oHtml:ValByName( "C8_NOME"		, cNmEnd )

		//Endereço de cobrança.
		cNmEndCo := Alltrim(SM0->M0_NOMECOM) + "<br>" +;		
					Alltrim(SM0->M0_ENDCOB)  + "<br>" +;
					Alltrim(SM0->M0_CIDCOB)  +"-"+ Alltrim(SM0->M0_ESTCOB) + "<br>" +;
					"CEP: "+ Alltrim(SM0->M0_CEPCOB)  + "<br>"

		oProcess:oHtml:ValByName( "COMPRADOR"	, cComprador )

		oProcess:oHtml:ValByName( "C8_NOMECOB"	, cNmEndCo )	

		oProcess:oHtml:ValByName( "DATA_ENV"	, DToC(Date()) )
		
		//Dados do produto.
		While !TRSC8->(Eof()) .And. cC8_FORNECE == TRSC8->C8_FORNECE .And. cC8_LOJA == TRSC8->C8_LOJA .And. cC8_NUM == TRSC8->C8_NUM .And. cC8_NPRO	== TRSC8->C8_NUMPRO  //Everson - 12/05/2020. Chamado 054714.

			//
			Aadd( oProcess:oHtml:ValByName( "IT.ITEM" )		, TRSC8->C8_ITEM )
			Aadd( oProcess:oHtml:ValByName( "IT.PRODUTO") 	, TRSC8->C8_PRODUTO )
			Aadd( oProcess:oHtml:ValByName( "IT.DESCRI") 	, Iif(Empty(Alltrim(TRSC8->B1_DESCOMP)),TRSC8->B1_DESC,TRSC8->B1_DESCOMP) )
			Aadd( oProcess:oHtml:ValByName( "IT.OBSITEM" )	, Alltrim(TRSC8->OBS) )
			Aadd( oProcess:oHtml:ValByName( "IT.UM")     	, TRSC8->C8_UM )
			Aadd( oProcess:oHtml:ValByName( "IT.QUANT")  	, TRSC8->C8_QUANT )				
			Aadd( oProcess:oHtml:ValByName( "IT.PRECO")  	, "0.00")
			Aadd( oProcess:oHtml:ValByName( "IT.DESC" )   	, "0.00")		
			Aadd( oProcess:oHtml:ValByName( "IT.IPI" )   	, "0.00")
			Aadd( oProcess:oHtml:ValByName( "IT.VALOR")  	, "0.00")
			Aadd( oProcess:oHtml:ValByName( "IT.ENTREGA" )  , "" )
			
			//Marcar SC8 como registro enviado.
			If	Empty(Alltrim(cValToChar(TRSC8->C8_XEMWF)))
				cStatus := "A"

			Else
				cStatus := "C"

			EndIf
			
			//
			upt_SC8(cStatus,TRSC8->C8_NUM,cC8_FORNECE,cC8_LOJA,TRSC8->C8_PRODUTO)
			
			//
			TRSC8->(DbSkip())
			
		EndDo

		//Everson - 13/05/2020. Chamado 054714.
		oProcess:oHtml:ValByName( "C8_XOBSFOR"	, "" )

		//Totalizadores.
		oProcess:oHtml:ValByName( "PAGAMENTO"	, aCondPag )
		oProcess:oHtml:ValByName( "IPITOT"		, "0.00" )
		oProcess:oHtml:ValByName( "DESCTOT"		, "0.00" ) 
		oProcess:oHtml:ValByName( "SUBTOT"		, "0.00" )
		oProcess:oHtml:ValByName( "FRETOT"		, "0.00" )
		oProcess:oHtml:ValByName( "SEGTOT"		, "0.00" )
		oProcess:oHtml:ValByName( "DESTOT"		, "0.00" )
		oProcess:oHtml:ValByName( "TOTAL"		, "0.00" )

		oProcess:oHtml:ValByName( "MOEDA"		, aMoeda ) //Everson - 31/08/2020. Chamado 060873.
		
		// Informamos qual função será executada no evento de timeout.
		oProcess:bTimeOut := {{"u_ADC035B()", 0, nHorasEx, 0}}
		
		// Informamos qual função será executada no evento de retorno.
		oProcess:bReturn := "U_ADC035A()"
		
		// Iniciamos a tarefa e recuperamos o nome do arquivo gerado.
		cMailId := oProcess:Start("\workflow\workflowcompras\cotacao\messenger\") 

		// Verificamos se o arquivo foi gerado.
		If ! file("\workflow\workflowcompras\cotacao\messenger\" + Alltrim(cMailId) + ".htm" )
			MsgStop("Não foi possível gerar o solicitação de contação para o fornecedor " +;
			        cFornece,"Função ADCOM035P")
			Loop

		EndIf

		//
		WaitRunSrv('xcopy "D:\TOTVS\Protheus12\protheus_data\workflow\workflowcompras\cotacao\messenger\' + Alltrim(cMailId) + '.htm"  "D:\nginx\html\workflowcompras\processos\cotacao\" /c /q /y ',.T.,"C:\WINDOWS\system32\")

		// Montamos HTML com o link do arquivo gerado.
        cBody := MemoRead("\workflow\workflowcompras\cotacao\corpo_email\temp_email.html")
		cBody := StrTran(cBody,"'.$name_company.'",Alltrim(SM0->M0_NOMECOM))
		cBody := StrTran(cBody,"'.$name_system.'" ,"Controle compras")
		cBody := StrTran(cBody,"'.$version.'"     ,"1.0")
		cBody := StrTran(cBody,"'.$title.'"       ,"Solicitação de cotação para compra")
		cBody := StrTran(cBody,"'.$msg_1.'"       ,"Olá, " + cFornece + ")")
		cBody := StrTran(cBody,"'.$msg_2.'"       ,"Por favor, clique <a href='" + cHostWF + cMailId + "'>aqui</a> para responder a solicitação de cotação de compra.")
		cBody := StrTran(cBody,"'.$year.'"    	  ,cValToChar(Year(Date())))
		cBody := StrTran(cBody,"'.$address.'"     ,cNmEnd)

		//
		cDrive := ""
		cDir   := ""
		cNome  := ""
		cExt   := ""
		cAtach := Nil

		//
		If ! Empty(cArq)

			//
			SplitPath(cArq, @cDrive, @cDir, @cNome, @cExt )
			CpyT2S(cArq, "\workflow\workflowcompras\cotacao\anexos\" )
			cAtach := "\workflow\workflowcompras\cotacao\anexos\" + cNome + cExt

		EndIf
	
		//
		U_EnviarEmail(cEmlFor,"Solicitação de Cotação Ad'oro", cBody,cAtach)

		//
		If ! Empty(Alltrim(cValToChar(cAtach)))
			FErase(cAtach)

		EndIf

   EndDo
   
   	//
	TRSC8->(DbCloseArea())
	   
	//
	RestArea(aArea)      
         
Return Nil
/*/{Protheus.doc} BD_SC8
	Obtém dados da cotação.
	@type  Static Function
	@author Everson
	@since 08/01/2020
	@version 01
	/*/
Static Function BD_SC8(cCod,cLoja,cNumSC8)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	
	//
	cQuery := ""
	cQuery += " SELECT " 
		cQuery += " C8_NUM, " 
		cQuery += " C8_FORNECE, "  
		cQuery += " C8_LOJA, "  
		cQuery += " A2_EMAIL, "  
		cQuery += " A2_NOME, " 
		cQuery += " A2_COD, " 
		cQuery += " A2_LOJA, " 
		cQuery += " A2_END, " 
		cQuery += " A2_NR_END, " 
		cQuery += " A2_BAIRRO, " 
		cQuery += " A2_MUN, " 
		cQuery += " A2_TEL, " 
		cQuery += " A2_FAX, " 
		cQuery += " C8_NUMPRO, " 
		cQuery += " C8_VALIDA, " 
		cQuery += " C8_ITEM, " 
		cQuery += " C8_PRODUTO, " 
		cQuery += " B1_DESC, " 
		cQuery += " B1_DESCOMP, " 
		cQuery += " C8_UM, " 
		cQuery += " C1_OBS AS OBS, "
		cQuery += " C8_QUANT, " 

		cQuery += " C8_XEMWF " 

	cQuery += " FROM " 
		cQuery += " " + RetSqlName("SC8") + " SC8 " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("SC1") + " SC1 ON " 
		cQuery += " C8_FILIAL = C1_FILIAL "
		cQuery += " AND C8_NUMSC = C1_NUM "
		cQuery += " AND C8_ITEMSC = C1_ITEM "
		cQuery += " AND C8_PRODUTO = C1_PRODUTO "
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("SA2") + " SA2 ON " 
		cQuery += " C8_FORNECE = A2_COD " 
		cQuery += " AND C8_LOJA = A2_LOJA " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("SB1") + " SB1 ON " 
		cQuery += " C8_PRODUTO = B1_COD " 

	cQuery += " WHERE " 
		cQuery += " C8_FILIAL = '" + FWxFilial("SC8") + "' "
		cQuery += " AND C8_NUM = '" + Alltrim(cValToChar(cNumSC8)) + "' " 

		//Everson - 12/05/2020. Chamado 054714.
		cQuery += " AND C8_FORNECE = '" + cCod + "' "
		cQuery += " AND C8_LOJA = '" + cLoja + "' "
		cQuery += " AND C8_NUMPED = '' "
		//cQuery += " AND A2_EMAIL <> '' " //Everson - 12/05/2020. Chamado 054714.
		//

		cQuery += " AND SC8.D_E_L_E_T_ = '' " 
		cQuery += " AND SC1.D_E_L_E_T_ = '' "
		cQuery += " AND SA2.D_E_L_E_T_ = '' " 	
		cQuery += " AND SB1.D_E_L_E_T_ = '' " 

	cQuery += " ORDER BY C8_FORNECE, C8_LOJA, C8_NUM " 

	//
	RestArea(aArea)
	
Return cQuery
/*/{Protheus.doc} cond_Pag
	Obtém condições de pagamento que irão compor as opções do workflow.
	@type  Static Function
	@author Everson
	@since 11/05/2020
	@version 01
	/*/
Static Function cond_Pag()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local cQuery	:= ""
	Local aDados	:= {}
	
	//
	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " CAST(E4_CODIGO AS VARCHAR) +'-'+ LTRIM(RTRIM(CAST(E4_DESCRI AS VARCHAR))) AS CONDICOES  " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("SE4") + " AS SE4 " 
	cQuery += " WHERE " 
	cQuery += " E4_FILIAL = '" + FWxFilial("SE4") + "' "
	cQuery += " AND SE4.D_E_L_E_T_ = '' " 
	cQuery += " AND E4_XEMWF = '2' "
	cQuery += " ORDER BY E4_CODIGO "
	
	//
	If Select("CONPAG") > 0
		CONPAG->(DbCloseArea())

	EndIf
	
	//
	TcQuery cQuery New Alias "CONPAG"
	DbSelectArea("CONPAG")
	While ! CONPAG->(Eof())

		//
		Aadd(aDados, Alltrim(cValToChar(CONPAG->CONDICOES)))

		//
		CONPAG->(DbSkip())

	EndDo

	//
	CONPAG->(DbCloseArea())
	
Return aDados
/*/{Protheus.doc} User Function ADC035A
	Trata o retorno do workflow.
	@type  Function
	@author Everson
	@since 11/05/2020
	@version 01
	/*/
User Function ADC035A(oWF)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	:= GetArea()
	
	//
	Local nInd		:= 1
	Local nQtdItem	:= 0
	Local cNumero	:= ""
	Local cProps	:= ""
	Local dValidade := Nil
	Local cFornece	:= ""
	Local cLoja		:= ""
	Local cContato	:= ""
	Local cPgto		:= ""
	Local nSeguro	:= 0
	Local nTotFrete := 0

	//
	Local cItem		:= ""
	Local nPreco	:= 0
	Local nVlDesc	:= 0
	Local nVlIpi	:= 0
	Local dDatprf	:= Nil

	//
	Local nFrtLanc 	:= 0
	Local nVlFrt	:= 0
	Local nSegLanc  := 0
	Local nVlSeg	:= 0

	//Everson - 13/05/2020. Chamado 054714.
	Local cObsFor	:= "" 
	Local nTotDesp	:= 0
	Local nDesLanc	:= 0
	Local nVlDes	:= 0
	//

	Local cMoeda	:= "" //Everson - 31/08/2020. Chamado 060873.

	//
	Local aDados	:= {}

	//
	Conout( DToC(Date()) + " " + Time() + " ADCOM035P - ADC035A - 1" )

	//
	cNumero    	:= oWF:oHtml:RetByName("C8_NUM")
	cProps     	:= oWF:oHtml:RetByName("C8_NUMPRO") 
	dValidade   := SToD(StrTran(oWF:oHtml:RetByName("C8_VALIDA"),"-",""))
	cFornece   	:= oWF:oHtml:RetByName("C8_FORNECE")
	cLoja      	:= oWF:oHtml:RetByName("C8_LOJA")
	cContato   	:= oWF:oHtml:RetByName("C8_CONTATO")
	cPgto      	:= Substr(Alltrim(oWF:oHtml:RetByName("PAGAMENTO")),1,3)
	nSeguro		:= Val(cValToChar(oWF:oHtml:RetByName("SEGTOT")))
	nTotFrete  	:= Val(cValToChar(oWF:oHtml:RetByName("FRETOT")))
	nTotDesp	:= Val(cValToChar(oWF:oHtml:RetByName("DESTOT")))
	cObsFor		:= oWF:oHtml:RetByName("C8_XOBSFOR") //Everson - 13/05/2020. Chamado 054714.
	
	//Everson - 31/08/2020. Chamado 060873.
	cMoeda      := Alltrim(cValToChar(Substr(Alltrim(oWF:oHtml:RetByName("MOEDA")),1,1)))
	If ! cMoeda $("1|2|4")
		RestArea(aArea)
		Return Nil

	EndIf
	//

	//
	Conout( DToC(Date()) + " " + Time() + " ADCOM035P - ADC035A - 2" )
	Conout( DToC(Date()) + " " + Time() + " ADCOM035P - ADC035A - cMoeda " + cMoeda )
	
	//
	nQtdItem := Len(oWF:oHtml:RetByName("IT.PRECO"))
	For nInd := 1 To nQtdItem

		//
		cItem  := oWF:oHtml:RetByName("IT.ITEM")[nInd]

		//Busca produto na tabela SC8						
		DbSelectArea("SC8")
		SC8->(DbSetOrder(1))
		If ! SC8->(DbSeek( xFilial("SC8") +;
		           Padr(cNumero,TamSX3("C8_NUM")[1]," ") +;
				   Padr(cFornece,TamSX3("C8_FORNECE")[1]," ") +;
				   Padr(cLoja ,TamSX3("C8_LOJA")[1]," ") +;
				   Padr(cItem ,TamSX3("C8_ITEM")[1]," ") +;
				   Padr(cProps,TamSX3("C8_NUMPRO")[1]," ") ) )
			Loop 

		EndIf

		//
		Conout( DToC(Date()) + " " + Time() + " ADCOM035P - ADC035A - 3" )

		//
		If ! Empty(SC8->C8_NUMPED)
			Loop

		EndIf	

		//Carrega variáveis.
		nPreco := Val(cValToChar(oWF:oHtml:RetByName("IT.PRECO")[nInd]))
		nVlDesc:= Val(cValToChar(oWF:oHtml:RetByName("IT.DESC")[nInd]))
		nVlIpi := Val(cValToChar(oWF:oHtml:RetByName("IT.IPI")[nInd]))
		dDatprf:= SToD(StrTran(oWF:oHtml:RetByName("IT.ENTREGA")[nInd],"-",""))
		Conout("dDatprf >>>>>>>>> " + cValToChar(dDatprf))
		//
		If nPreco > 0 .And. ! Empty(Alltrim(DToS(dDatprf)))
			Aadd(aDados,{nPreco,nPreco*SC8->C8_QUANT,nVlDesc,nVlIpi,dDatprf,DateDiffDay(SC8->C8_EMISSAO,dDatprf),SC8->(Recno())})

		EndIf

	Next nInd

	//
	DbSelectArea("SC8")
	nQtdItem := Len(aDados)
	For nInd := 1 To nQtdItem

		//
		Conout( DToC(Date()) + " " + Time() + " ADCOM035P - ADC035A - 4 " + cValToChar(nInd) )

		//Rateio do seguro.
		If nSeguro <= 0
			nVlSeg := 0
			
		Else

			//
			If nInd < nQtdItem .And. nPreco > 0
				nVlSeg := Round(nSeguro / nQtdItem, 2)
				nSegLanc += nVlSeg

			ElseIf nInd = nQtdItem .And. nPreco > 0 					
				nVlSeg := nSeguro - nSegLanc

			Else
				nVlSeg := 0

			EndIF

		EndIf
		
		//Rateio do frete.
		If nTotFrete <= 0
			nVlFrt := 0

		Else

			//
			If nInd < nQtdItem .And. nPreco > 0
				nVlFrt	:= Round(nTotFrete / nQtdItem, 2)
				nFrtLanc +=nVlFrt

			ElseIf nInd = nQtdItem .And. nPreco > 0
				nVlFrt	:= nTotFrete - nFrtLanc

			Else
				nVlFrt := 0

			EndIF
			
		EndIf

		//Rateio do despesa.
		If nTotDesp <= 0
			nVlDes := 0

		Else

			//
			If nInd < nQtdItem .And. nPreco > 0
				nVlDes	:= Round(nTotDesp / nQtdItem, 2)
				nDesLanc +=nVlDes

			ElseIf nInd = nQtdItem .And. nPreco > 0
				nVlDes	:= nTotDesp - nDesLanc

			Else
				nVlDes := 0

			EndIF
			
		EndIf

		Conout( DToC(Date()) + " " + Time() + " ADCOM035P - ADC035A - Dados da reposta." )	
		Conout("xFilial('SC8') + cNumero + cFornece + cLoja + cItem + cProps" + xFilial("SC8") + " " + cNumero + " " + cFornece + " " + cLoja + " " + cItem + " " + cProps)
		Conout("cContato " + cValToChar(cContato))
		Conout("dValidade " + cValToChar(dValidade))
		Conout("dDatprf" + cValToChar(aDados[nInd][5])) 
		Conout("DateDiffDay(SC8->C8_EMISSAO,dDatprf) " + cValToChar(aDados[nInd][6])) 
		Conout("cPgto " + cValToChar(cPgto)) 
		Conout("nPreco " + cValToChar(aDados[nInd][1]))
		Conout("nVlDesc " + cValToChar(aDados[nInd][3]))
		Conout("SC8->C8_QUANT * nPreco " + cValToChar(aDados[nInd][2]))	
		Conout("nVlIpi " + cValToChar(aDados[nInd][4]))
		Conout("Iif(nPreco <= 0 .Or. nVlIpi <= 0,0,nVlIpi/nPreco) " + cValToChar(Iif(aDados[nInd][1] <= 0 .Or. aDados[nInd][4] <= 0,0,aDados[nInd][4]/aDados[nInd][1])))
		Conout("Iif(Val(cValToChar(nTotFrete)) <= 0,'F','C') " + cValToChar(Iif(Val(cValToChar(nTotFrete)) <= 0,"F","C")))
		Conout("dDatprf " + cValToChar(aDados[nInd][5]))
		Conout("nVlSeg " + cValToChar(nVlSeg))
		Conout("nVlFrt " + cValToChar(nVlFrt))
		Conout("nVlDes " + cValToChar(nVlDes))
		Conout("cObsFor "+ cValToChar(cObsFor))

		//Grava dados na tabela de cotações.
		SC8->(DbGoTo(aDados[nInd][7]))
		Begin Transaction

			//
			RecLock("SC8",.F.)
				SC8->C8_CONTATO	:= cContato
				SC8->C8_VALIDA  := dValidade
				SC8->C8_COND	:= cPgto 
				SC8->C8_PRECO	:= aDados[nInd][1]
				SC8->C8_TOTAL  	:= aDados[nInd][2]
				SC8->C8_DESC    := aDados[nInd][3]
				SC8->C8_VLDESC  := Round( (SC8->C8_QUANT * aDados[nInd][1]) * (aDados[nInd][3]/100),2) //Everson - 13/05/2020. Chamado 054714.
				SC8->C8_VALIPI 	:= Round( (SC8->C8_QUANT * aDados[nInd][1]) * (aDados[nInd][4]/100),2) //Everson - 13/05/2020. Chamado 054714.
				SC8->C8_ALIIPI 	:= aDados[nInd][4] //Everson - 13/05/2020. Chamado 054714.
				SC8->C8_DATPRF 	:= aDados[nInd][5] //Everson - 13/05/2020. Chamado 054714.
				SC8->C8_PRAZO  	:= aDados[nInd][6]
				SC8->C8_TPFRETE	:= Iif(Val(cValToChar(nTotFrete)) <= 0,"F","C")
				SC8->C8_SEGURO  := nVlSeg
				SC8->C8_VALFRE 	:= nVlFrt
				SC8->C8_DESPESA	:= nVlDes
				SC8->C8_XEMWF	:= "B"
				SC8->C8_XOBSFOR	:= cObsFor //Everson - 13/05/2020. Chamado 054714.
				SC8->C8_MOEDA   := Val(cMoeda)  //Everson - 31/08/2020. Chamado 060873. //Everson - 16/09/2020. Chamado 1633.
			SC8->(MsUnlock())

			//
			//DisarmTransaction()

		End Transaction

	Next nInd
	
	//
	oWF:Finish()

	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} User Function ADC035B
	Rotina executada após timeout.
	@type  Function
	@author Everson
	@since 11/05/2020
	@version 01
	/*/
User Function ADC035B(oWF)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea 		:= GetArea()
	Local cHtml 		:= MemoRead("\workflow\workflowcompras\cotacao\final\timeout.html")
	Local pcProcessID	:= Substr(Alltrim(oWF:oHtml:ALISTVALUES[1][28][2]),3,Len(Alltrim(oWF:oHtml:ALISTVALUES[1][28][2])))

	//
	Conout( DToC(Date()) + " " + Time() + " ADCOM035P - ADC035B - Processo " + pcProcessID + " finalizado " )
	oWF:Finish()

    //
    MemoWrite("\workflow\workflowcompras\cotacao\final\" + pcProcessID +".htm",cHtml)

    //
    WaitRunSrv('xcopy "D:\TOTVS\Protheus12\protheus_data\workflow\workflowcompras\cotacao\final\' + pcProcessID + '.htm"  "D:\nginx\html\workflowcompras\processos\cotacao\" /c /q /y ',.T.,"C:\WINDOWS\system32\")

    //
    Ferase("\workflow\workflowcompras\cotacao\final\" + pcProcessID +".htm")

	//
    StartJob("U_WFPEAD01",getenvserver(),.F.,FwCodEmp(),FWxFilial(),pcProcessID,.F.) //Everson, 18/05/2020. Chamado 058244.

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} upt_SC8
	Atualiza registro na tabela SC8.
	@type  Static Function
	@author Everson
	@since 11/05/2020
	@version 01
	/*/
Static Function upt_SC8(cStatus,cNumCot,cCodFor,cLoja,cProduto)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local cUpdate	:= ""
	
	//
	cUpdate := 	"UPDATE SC8010 SET C8_XEMWF = '" + Alltrim(cValToChar(cStatus)) + "' WHERE C8_NUM = '" + Alltrim(cValToChar(cNumCot)) +;
	 			"' AND C8_FORNECE = '" + Alltrim(cValToChar(cCodFor)) + "' AND C8_LOJA = '" + Alltrim(cValToChar(cLoja)) + "' AND C8_PRODUTO = '" + Alltrim(cValToChar(cProduto)) + "'"
	
	//
	If TcSqlExec(cUpdate) < 0
		MsgAlert("Não foi possível atualizar o status do registro de cotação. Avise o departamento de T.I. com urgência.","Função upt_SC8(ADCOM035P)")

	EndIf
	
Return Nil
