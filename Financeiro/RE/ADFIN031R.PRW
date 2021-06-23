#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include 'AP5mail.ch'
/*/{Protheus.doc} User Function nomeFunction
	Relatório Posição de Carteira. Chamado 035024.
	@type  Function
	@author Everson
	@since 16/05/2017
	@version 01
	@history Adriana 24/05/2019 TI-Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM
	@history Adriana 27/05/2019 TI-Voltamos a versao de 14/11/2018 antes da inclusao da funcao Sleep 
	@history Adriana 30/05/2019 TI-Ajuste para execucao via ADFIN030P
	@history Everson 10/03/2020 Chamado 054162. Envio de relatório Faturamento x Kg.
	/*/
User Function ADFIN031R() // U_ADFIN031R()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local cEmp 		:= "01"
	Local cFil 		:= "02"
	Local cQuery 	:= ""
	Local cVend		:= ""
	Local cEmailVd	:= ""
	Local cEmailSp	:= ""
	Local cUser		:= ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatório Posição de Carteira.')
	
	//Inicia o ambiente. //	Desabilitado por Adriana em 30/05/2019
  	//RPCSetType(3)
  	//RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })
		
	//	logZBN("1") //Log início. //	Desabilitado por Adriana em 30/05/2019
		
		If dow(date()) <> 1 .and. dow(date()) <> 7 //sabado e domingo nao executa o schedule  - incluido por Adriana em 21/08/2017

			cQuery := ""
			cQuery += " SELECT   " 
			cQuery += " DISTINCT A1_VEND, A3_EMAIL, A3_CODUSR, SUPER.EMAILSUPER " 
			cQuery += " FROM   " 
			cQuery += " " + RetSqlName("SA1") + "  (NOLOCK) AS SA1   " 
			cQuery += " INNER JOIN   " 
			cQuery += " " + RetSqlName("SA3") + "  (NOLOCK) AS SA3   " 
			cQuery += " ON A1_VEND = A3_COD   " 
			cQuery += " INNER JOIN " 
			cQuery += " (SELECT A3_COD AS CODSUPER, A3_NOME AS NOMESUPER, A3_EMAIL AS EMAILSUPER FROM " + RetSqlName("SA3") + " AS SUPER WHERE SUPER.D_E_L_E_T_ = '') AS SUPER ON " 
			cQuery += " A3_SUPER = SUPER.CODSUPER " 
			cQuery += " WHERE   " 
			cQuery += " SA1.D_E_L_E_T_ = ''   " 
			cQuery += " AND SA3.D_E_L_E_T_ = ''   " 
			cQuery += " AND A1_VEND <> ''   " 
			//cQuery += " AND A1_VEND = '000132'   "
			cQuery += " ORDER BY A1_VEND " 

			//
			If Select("L_VEND") > 0
				L_VEND->(DbCloseArea())
			
			EndIf
		

			TcQuery cQuery New Alias "L_VEND"
			DbSelectArea("L_VEND")
			L_VEND->(DbGoTop())
		
			//
			While ! L_VEND->(Eof())
		
				cVend 		:= Alltrim(cValToChar(L_VEND->A1_VEND))
				cEmailVd	:= Alltrim(cValToChar(L_VEND->A3_EMAIL))
				cUser 		:= Alltrim(cValToChar(L_VEND->A3_CODUSR))
				cEmailSp	:= Alltrim(cValToChar(L_VEND->EMAILSUPER))
			
				//
				gerarRelatorio(cVend,cEmailVd,cUser,cEmailSp)
		
				L_VEND->(DbSkip())
			
			EndDo
		
			L_VEND->(DbCloseArea())

			//Everson - 10/03/2020. Chamado 054162.
			MsAguarde({|| U_ADFIN084R() },"Aguarde","Gerando relatório faturamento x Kg")
			//
		
		Endif
	//	logZBN("2") //Log fim. //	Desabilitado por Adriana em 30/05/2019
	
	//Fecha o ambiente.
	//RpcClearEnv() //	Desabilitado por Adriana em 30/05/2019

Return Nil
/*/{Protheus.doc} gerarRelatorio
	Adiciona jquery. 
	@type  Static Function
	@author Everson
	@since 16/05/2017
	@version 01
	/*/
/*
************* Função também utilizada no fonte ADVEN065P (web service de relatórios Protheus x SalesForce).
*/
Static Function gerarRelatorio(cVendedor,cEmailVd,cUser,cEmailSp,cNmRelRest)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea		:= GetArea()
	Local nHdl	 	:= 0
	Local cAtach	:= "\rel_fin\relposcart" + cVendedor + Iif(!IsInCallStack("U_ADVEN065P"),"",StrTran(FWUUID( cValToChar(Randomize(-2000,2000)) + cEmailVd+ DToS(Date()) + StrTran(cValToChar( Time()),":","") ),"-","")) + ".html"
	Local nHandle 	:= 0
	Local cHtml		:= ""
	Local cCredito  := Alltrim(GetMv("MV_#LISTPD")) //credito@adoro.com.br  - acrescentado conforme solicitação alberto/ reginaldo parametro utilizado em outras customizacoes
	
	Local cAssunto	:= "Relatório - Posição de Carteira " + Alltrim(cValToChar(cVendedor))
	Local cFullName	:= ""//Alltrim(cValToChar(UsrFullName(cUser)))
	Local cMensagem := "Segue relatório Posição de Carteira anexo."
	
	Private cCorLn	:= "#f2f2f2"
	Private nIdBtn	:= 1 
	
	//
	If File(cAtach)
		FErase(cAtach)
	
	Endif
	
  	//
	nHandle := FCreate(cAtach)
    If nHandle == -1
		RestArea(aArea)
        Return Nil

    EndIf
	
	//Primeira parte do Html.
	cHtml := html1()
	FWrite(nHandle, cHtml)
	cHtml := ""
	
	//
	If ! addDtTbCss(nHandle)
		FClose(nHandle)
		FErase(cAtach)
		RestArea(aArea)
		Return Nil
			
	EndIf
	
	//
	If ! addJQuery(nHandle)
		FClose(nHandle)
		FErase(cAtach)
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	If ! addDtTbJs(nHandle)
		FClose(nHandle)
		FErase(cAtach)
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//Segunda parte do Html.
	cHtml := html2(cVendedor,cEmailVd,cFullName)
	FWrite(nHandle, cHtml)
	
	//Gera aba Resumo.
	grResumo(nHandle,cVendedor)
	
	//Gera aba Lim. Redes.
	grLimRedes(nHandle,cVendedor)
	
	//Gera aba Lim. Clientes.
	grLimClientes(nHandle,cVendedor)
	
	//Gera aba Vlr. Aberto.
	grVlrAberto(nHandle,cVendedor)
	
	//Gera aba Últ. Compra.
	grUltComp(nHandle,cVendedor)
	
	//Gera aba Lim  + 70%.
	grLim70(nHandle,cVendedor)
	
	//Gera aba sem vendas + 5 dias.
	grSV5(nHandle,cVendedor)
	
	cHtml := html3()
	FWrite(nHandle, cHtml)
	FClose(nHandle)
	
	If ! IsInCallStack("U_ADVEN065P")
	
		//E-mail vendedor.
		If ! Empty(cEmailVd)
			enviarEmail(cAssunto,cMensagem,cEmailVd,cAtach)
		
		EndIf
		
		//E-mail supervisor.
		If ! Empty(cEmailSp)
	//		enviarEmail(cAssunto,cMensagem,cEmailVd,cAtach)     
			enviarEmail(cAssunto,cMensagem,cEmailSp,cAtach)   //Alterado por Adriana para envio do email ao supervisor
		
		EndIf
		
		//E-mail credito. //incluido por Adriana conforme solicitacao do Alberto
		If ! Empty(cCredito)
			enviarEmail(cAssunto,cMensagem,cCredito,cAtach)
		
		EndIf

		FErase(cAtach)
	
	Else
		cNmRelRest := cAtach
	
	EndIf
	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} addJQuery
	Adiciona jquery. 
	@type  Static Function
	@author Everson
	@since 31/05/2017
	@version 01
	/*/
Static Function addJQuery(nHandle)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea		:= GetArea()
	Local cJquery	:= "\rel_fin\jquery\jquery.txt.txt"
	Local cBuffer	:= ""
	
	//
	If ! File(cJquery)
		RestArea(aArea)
		Return .F.
		
	Endif
	
	//
	nHdl := FT_FUse(cJquery)
	
	//Valida abertura do arquivo.
	If nHdl == -1
		RestArea(aArea)
		Return .F.
		
	Endif
	
	//
	FT_FGoTop()
	
	cBuffer := "<script type='text/javascript'>" 
	FWrite(nHandle,cBuffer) 
	cBuffer := ""
	//Percorre arquivo.
	While !FT_FEof()
		
		cBuffer := FT_FReadln()
		
		FWrite(nHandle,cBuffer)
		
		FT_FSkip()
		
	EndDo
	cBuffer := ""
	cBuffer += " </script> "
	FWrite(nHandle,cBuffer) 
	cBuffer := ""
	
	//
	RestArea(aArea)	

Return .T.
/*/{Protheus.doc} addDtTbJs
	Adiciona Js DataTable.
	@type  Static Function
	@author Everson
	@since 01/06/2017
	@version 01
	/*/
Static Function addDtTbJs(nHandle)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea		:= GetArea()
	Local cJS		:= "\rel_fin\datatable\datatablejs.txt"
	Local cBuffer	:= ""
	
	//
	If ! File(cJS)
		RestArea(aArea)
		Return .F.
		
	Endif
	
	//
	nHdl := FT_FUse(cJS)
	
	//Valida abertura do arquivo.
	If nHdl == -1
		RestArea(aArea)
		Return .F.
		
	Endif
	
	//
	FT_FGoTop()
	
	cBuffer := "<script type='text/javascript'>" 
	FWrite(nHandle,cBuffer) 
	cBuffer := ""
	//Percorre arquivo.
	While !FT_FEof()
		
		cBuffer := FT_FReadln()
		
		FWrite(nHandle,cBuffer)
		
		FT_FSkip()
		
	EndDo
	cBuffer := ""
	cBuffer += " </script> "
	FWrite(nHandle,cBuffer) 
	cBuffer := ""
	
	//
	RestArea(aArea)	

Return .T.
/*/{Protheus.doc} addDtTbCss
	Adiciona jquery. 
	@type  Static Function
	@author Everson
	@since 01/06/2017
	@version 01
	/*/
Static Function addDtTbCss(nHandle)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea		:= GetArea()
	Local cCss		:= "\rel_fin\datatable\datatablecss.txt"
	Local cBuffer	:= ""
	
	//
	If ! File(cCss)
		RestArea(aArea)
		Return .F.
		
	Endif
	
	//
	nHdl := FT_FUse(cCss)
	
	//Valida abertura do arquivo.
	If nHdl == -1
		RestArea(aArea)
		Return .F.
		
	Endif
	
	//
	FT_FGoTop()
	
	cBuffer := ""
	cBuffer += " <style> " 
	cBuffer += " html{} " 
	cBuffer += " body{width:95%; height:80%; padding-left: 10px; padding-top: 10px; font-family:Calibri, Tahoma, Arial; margin:0 auto;} " 
	cBuffer += " .TabControl{ width:100%; overflow:hidden; height:100%;} " 
	cBuffer += " .TabControl #header { width:100%; border: solid 1px; border-top: 0px; border-left: 0px; border-bottom: 0px;overflow:hidden; cursor:hand; color: " + cCorLn + "} " 
	cBuffer += " .TabControl #content{ width:100%; overflow:scroll; border-bottom: 1px solid " + cCorLn + "; border-top:1px solid " + cCorLn + "; height:450px;} " 
	cBuffer += " .TabControl #content{background:white;} " 
	cBuffer += " .TabControl .abas{display:inline;} " 
	cBuffer += " .TabControl .abas li{float:left;} " 
	cBuffer += " .TabControl .conteudo{width:100%;background:white;display:none;height:100%;color:black;} " 
	cBuffer += " .aba  {width:150px; height:30px; border:solid 1px; border-radius:0px 10px 0 0;text-align:center; padding-top:5px; background:#ffb236} " 
	cBuffer += " .aba span {color: white; font-weight: bold;} " 
	cBuffer += " .ativa{width:150px; height:30px; border:solid 1 px; border-radius:0px 10px 0 0; text-align:center; padding-top:5px; background:#96191d;} " 
	cBuffer += " .ativa span{color:#ffb236;} " 
	cBuffer += " .selected span{color:#ffb236;} " 
	cBuffer += " .selected{width:150px; height:30px; border:solid 1 px; border-radius:0px 10px 0 0; text-align:center; padding-top:5px; background:#96191d} " 
	cBuffer += " .tituloAba{ color: #28377c;} " 
	cBuffer += " .tabConteudo{width: 100%;} " 
	cBuffer += " .tabConteudo tr th{ background-color: #96191d; color: white;} " 
	cBuffer += " .cabResumo{background-color:black; color: white; padding-left: 7px; font-weight: bold;} " 
	cBuffer += " .vlrResumo{background-color:" + cCorLn + ";text-align:right;} " 
	FWrite(nHandle,cBuffer)
	cBuffer := ""
	
	//Percorre arquivo.
	While !FT_FEof()
		
		cBuffer := FT_FReadln()
		
		FWrite(nHandle,cBuffer)
		
		FT_FSkip()
		
	EndDo
	
	cBuffer := ""
	cBuffer += " </style> "
	FWrite(nHandle,cBuffer) 
	cBuffer := ""
	
	//
	RestArea(aArea)	

Return .T.
/*/{Protheus.doc} grResumo
	Gera aba Resumo.
	@type  Static Function
	@author Everson
	@since 30/05/2017
	@version 01
	/*/
Static Function grResumo(nHandle,cVendedor)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea		:= GetArea()	
	Local cHtml		:= ""
	Local cQuery	:= ""
	
	//
	cQuery := scriptResumo(cVendedor)
	
	//
	If Select("D_RESUMO") > 0
		D_RESUMO->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "D_RESUMO"
	DbSelectArea("D_RESUMO")
	D_RESUMO->(DbGoTop())
	
	cHtml := ""
	cHtml += " <div id='content'> " 
	cHtml += " <div class='conteudo'> " 
	cHtml += " <h2 class='tituloAba'>Resumo da carteira de clientes</h2> " 
	cHtml += " <table style='width:700px' class='tabConteudo'> " 
	cHtml += " <tr> " 
	cHtml += " <td class='cabResumo'>Clientes<td> " 
	cHtml += " <td colspan='3'></td> " 
	cHtml += " </tr> "
	
	//
	cHtml += " <tr style='font-weight: bold;'> " 
	cHtml += " <td>Carteira Total<td> " 
	cHtml += " <td>Liberados</td> " 
	cHtml += " <td>Bloqueados</td> " 
	cHtml += " <td>S/ Vda +30 Dias</td> " 
	cHtml += " </tr> " 
	cHtml += " <tr class='vlrResumo'> " 
	cHtml += " <td>" + Transform(Val(cValToChar(D_RESUMO->CLI_TOT)),"@E 999,999") + "<td> " 
	cHtml += " <td>" + Transform(Val(cValToChar(D_RESUMO->CLI_LIB)),"@E 999,999") + "-<small>(" + Transform(Iif(Val(cValToChar(D_RESUMO->CLI_TOT)) > 0,(Val(cValToChar(D_RESUMO->CLI_LIB))/Val(cValToChar(D_RESUMO->CLI_TOT)))*100,0),"@E 999,999.99") + "%)</small></td> " 
	cHtml += " <td>" + Transform(Val(cValToChar(D_RESUMO->CLI_BLQ)),"@E 999,999") + "-<small>(" + Transform(Iif(Val(cValToChar(D_RESUMO->CLI_TOT)) > 0,(Val(cValToChar(D_RESUMO->CLI_BLQ))/Val(cValToChar(D_RESUMO->CLI_TOT)))*100,0),"@E 999,999.99") + "%)</small></td> " 
	cHtml += " <td>" + Transform(Val(cValToChar(D_RESUMO->NCOMP_30DIAS)),"@E 999,999") + "-<small>(" + Transform(Iif(Val(cValToChar(D_RESUMO->CLI_TOT)) > 0,(Val(cValToChar(D_RESUMO->NCOMP_30DIAS))/Val(cValToChar(D_RESUMO->CLI_TOT)))*100,0),"@E 999,999.99") + "%)</small></td> " 
	cHtml += " </tr> "
	
	//
	cHtml += " <tr> " 
	cHtml += " <td class='cabResumo'>Limite de Crédito<td> " 
	cHtml += " <td colspan='3'></td> " 
	cHtml += " </tr> " 
	cHtml += " <tr style='font-weight: bold;'> " 
	cHtml += " <td>Vlr. Aprovado<td> " 
	cHtml += " <td>Vlr. Utilizado</td> " 
	cHtml += " <td>Vlr. Disponível</td> " 
	cHtml += " <td>%Ociosidade</td> " 
	cHtml += " </tr> " 
	cHtml += " <tr class='vlrResumo'> " 
	cHtml += " <td>" + Transform(Val(cValToChar(D_RESUMO->LM_T)),"@E 999,999,999.99") + "<td> " 
	cHtml += " <td>" + Transform(Val(cValToChar(D_RESUMO->VLR_TOMADO)),"@E 999,999,999.99") + "</td> " 
	cHtml += " <td>" + Transform(Val(cValToChar(D_RESUMO->VLR_DISP)),"@E 999,999,999.99") + "</td> " 
	cHtml += " <td>" + Transform(Iif(Val(cValToChar(D_RESUMO->LM_T)) >0,(Val(cValToChar(D_RESUMO->VLR_DISP))/Val(cValToChar(D_RESUMO->LM_T)))*100,0),"@E 999,999.99") + "</td> " 
	cHtml += " </tr> " 
	
	//
	cHtml += " <tr> " 
	cHtml += " <td class='cabResumo'>Faturamento<td> " 
	cHtml += " <td colspan='3'></td> " 
	cHtml += " </tr> " 
	cHtml += " <tr style='font-weight: bold;'> " 
	cHtml += " <td>Mês<td> " 
	cHtml += " <td>Vendas</td> " 
	cHtml += " <td>Devoluções</td> " 
	cHtml += " <td>Total Líquido</td> " 
	cHtml += " </tr> " 
	cHtml += " <tr class='vlrResumo'> " 
	cHtml += " <td>" + cValToChar(Month(Date())) + "/" + cValToChar(Year(Date())) + "<td> " 
	cHtml += " <td>" + Transform(Val(cValToChar(D_RESUMO->FATURAMENTO)),"@E 999,999,999.99") + "</td> " 
	cHtml += " <td>" + Transform(Val(cValToChar(D_RESUMO->DEVOLUCAO)),"@E 999,999,999.99") + "</td> " 
	cHtml += " <td>" + Transform(Val(cValToChar(D_RESUMO->LIQUIDO)),"@E 999,999,999.99") + "</td> " 
	cHtml += " </tr> "
	
	//
	cHtml += " <tr> " 
	cHtml += " <td class='cabResumo'>Eficiência Recebimento<td> " 
	cHtml += " <td colspan='3'></td> " 
	cHtml += " </tr> " 
	cHtml += " <tr style='font-weight: bold;'> " 
	cHtml += " <td>Mês<td> " 
	cHtml += " <td>Vencimento/Mês</td> " 
	cHtml += " <td>Atraso/Mês</td> " 
	cHtml += " <td>% Efic. Receb.</td> " 
	cHtml += " </tr> " 
	cHtml += " <tr class='vlrResumo'> " 
	cHtml += " <td>" + cValToChar(Month(Date())) + "/" + cValToChar(Year(Date())) + "<td> " 
	cHtml += " <td>" + Transform(Val(cValToChar(EF_VALOR)),"@E 999,999,999.99") + "</td> " 
	cHtml += " <td>" + Transform(Val(cValToChar(EF_ATRASO)),"@E 999,999,999.99") + "</td> " 
	cHtml += " <td>" + Transform(Iif(Val(cValToChar(EF_VALOR))> 0, (1-(Val(cValToChar(EF_ATRASO))/Val(cValToChar(EF_VALOR)))) *100,0),"@E 999,999.99") + "</td> " // Everson - 05/09/2017. Chamado 037015.
	cHtml += " </tr> " 
	
	//
	cHtml += " <tr> " 
	cHtml += " <td class='cabResumo'>Inadimplência Geral<td> " 
	cHtml += " <td colspan='3'></td> " 
	cHtml += " </tr> " 
	cHtml += " <tr style='font-weight: bold;'> " 
	cHtml += " <td>Mês<td> " 
	cHtml += " <td>Saldo a Receber</td> " 
	cHtml += " <td>Vencidos</td> " 
	cHtml += " <td>% Inadimplência</td> " 
	cHtml += " </tr> " 
	cHtml += " <tr class='vlrResumo'> " 
	cHtml += " <td>" + cValToChar(Month(Date())) + "/" + cValToChar(Year(Date())) + "<td> " 
	cHtml += " <td>" + Transform(Val(cValToChar(D_RESUMO->TOTABERTO)),"@E 999,999,999.99") + "</td> " 
	cHtml += " <td>" + Transform(Val(cValToChar(D_RESUMO->VENCIDO)),"@E 999,999,999.99") + "</td> " 
	cHtml += " <td>" + Transform(Iif(Val(cValToChar(D_RESUMO->TOTABERTO)) > 0,(Val(cValToChar(D_RESUMO->VENCIDO))/Val(cValToChar(D_RESUMO->TOTABERTO)))*100,0),"@E 999,999.99") + "</td> " 
	cHtml += " </tr> " 
	
	//
	cHtml += " <tr> " 
	cHtml += " <td class='cabResumo' style='background-color: red'>Clientes sem vendas + 5 Dias<td> " 
	cHtml += " <td colspan='3'></td> " 
	cHtml += " </tr> " 
	cHtml += " <tr style='font-weight: bold;'> " 
	cHtml += " <td><td> " 
	cHtml += " <td>Qtd. Total</td> " 
	cHtml += " <td>% S/ Liberados</td> " 
	cHtml += " <td></td> " 
	cHtml += " </tr> " 
	cHtml += " <tr class='vlrResumo'> " 
	cHtml += " <td><td> " 
	cHtml += " <td>" + Transform(Val(cValToChar(D_RESUMO->DIASSV)),"@E 999,999") + "</td> " 
	cHtml += " <td>" + Transform(Iif(Val(cValToChar(D_RESUMO->CLI_LIB)) > 0,(Val(cValToChar(D_RESUMO->DIASSV))/Val(cValToChar(D_RESUMO->CLI_LIB)))*100,0),"@E 999,999.99") + "</td> " 
	cHtml += " <td></td> " 
	cHtml += " </tr> "
	 
	cHtml += " </table> " 
	cHtml += " <br/> " 
	cHtml += " </div> " 
	
	//
	FWrite(nHandle, cHtml)
	cHtml := ""
	
	DbCloseArea("D_RESUMO")
	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} scriptResumo
	Script sql aba Resumo. 
	@type  Static Function
	@author Everson
	@since 01/06/2017
	@version 01
	/*/
Static Function scriptResumo(cVendedor)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea 	:= GetArea()
	Local cQuery	:= ""
	
	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " COUNT(DISTINCT B_CLIENTE.A1_COD+B_CLIENTE.A1_LOJA) AS CLI_TOT, " 
	cQuery += " SUM(CASE WHEN B_CLIENTE.A1_MSBLQL = '2' THEN 1 ELSE 0 END) AS CLI_LIB, " 
	cQuery += " SUM(CASE WHEN B_CLIENTE.A1_MSBLQL = '1' THEN 1 ELSE 0 END) AS CLI_BLQ, " 
	cQuery += " SUM(CASE WHEN  " 
	cQuery += " (CASE WHEN  B_CLIENTE.A1_MSBLQL = '2' THEN " 
	cQuery += " (CASE WHEN B_TITULOULTC.E1_EMISSAO IS NOT NULL THEN " 
	cQuery += " DATEDIFF(DAY,CAST(B_TITULOULTC.E1_EMISSAO AS DATE),CAST(GETDATE() AS DATE)) " 
	cQuery += " ELSE " 
	cQuery += " CASE WHEN ISNULL(B_CLIENTE.A1_DTREAT,'') <> '' THEN  " 
	cQuery += " DATEDIFF(DAY,CAST(B_CLIENTE.A1_DTREAT AS DATE),CAST(GETDATE() AS DATE)) " 
	cQuery += " ELSE  " 
	cQuery += " DATEDIFF(DAY,CAST(B_CLIENTE.A1_DTCAD AS DATE),CAST(GETDATE() AS DATE)) " 
	cQuery += " END " 
	cQuery += " END) ELSE 0 END) > 30 THEN 1 ELSE 0 END) AS NCOMP_30DIAS, " 
	cQuery += " SUM(CASE WHEN B_CLIENTE.A1_MSBLQL = '2' THEN B_REDE.ZF_LCREDE ELSE 0 END) + " 
	cQuery += " SUM(CASE WHEN B_CLIENTE.A1_MSBLQL = '2' AND ISNULL(B_REDE.ZF_REDE,'') = '' THEN B_CLIENTE.A1_LC ELSE 0 END) AS LM_T, " 
	cQuery += " SUM(CASE WHEN B_CLIENTE.A1_MSBLQL = '2' THEN B_TITULO.E1_SALDO ELSE 0 END) AS VLR_TOMADO, " 
	cQuery += " ( " 
	cQuery += " SUM(CASE WHEN B_CLIENTE.A1_MSBLQL = '2' THEN B_REDE.ZF_LCREDE ELSE 0 END) + " 
	cQuery += " SUM(CASE WHEN B_CLIENTE.A1_MSBLQL = '2' AND ISNULL(B_REDE.ZF_REDE,'') = '' THEN B_CLIENTE.A1_LC ELSE 0 END) " 
	cQuery += " ) - SUM(CASE WHEN B_CLIENTE.A1_MSBLQL = '2' THEN B_TITULO.E1_SALDO ELSE 0 END) AS VLR_DISP, " 
	cQuery += " SUM(B_FATURAMENTO.E1_SALDO) AS FATURAMENTO, " 
	cQuery += " ISNULL(SUM(B_DEVOLUCAO.E1_SALDO),0) AS DEVOLUCAO, " 
	cQuery += " SUM(B_FATURAMENTO.E1_SALDO) -ISNULL(SUM(B_DEVOLUCAO.E1_SALDO),0) AS LIQUIDO, " 
	cQuery += " SUM(B_TABERTO.E1_SALDO) AS TOTABERTO, " 
	cQuery += " SUM(B_TABERTO.ATRASO) AS VENCIDO, " 
	cQuery += " SUM(B_EFICIENCIA.E1_VALOR) AS EF_VALOR, SUM(B_EFICIENCIA.VENCIDO) EF_ATRASO, " 
	cQuery += " COUNT(DISTINCT B_5DIASSV.A1_COD + B_5DIASSV.A1_LOJA) AS DIASSV " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " A1_FILIAL, A1_COD, A1_LOJA, A1_NOME, A1_NREDUZ, A1_VEND, A1_CGC, LEFT(A1_CGC,8) AS RAIZ_CGC, A1_LC, A1_MSBLQL, A1_DTCAD, A1_DTREAT, A1_COND, A1_REDE, A1_SATIV1 " 
	cQuery += " FROM " 
	cQuery += " SA1010 (NOLOCK) SA1 " 
	cQuery += " WHERE  " 
	cQuery += " SA1.D_E_L_E_T_='' " 
	cQuery += " AND A1_VEND = '" + Alltrim(cValToChar(cVendedor)) + "' " 
	cQuery += " ) AS B_CLIENTE " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT    " 
	cQuery += " E1_CLIENTE, E1_LOJA, SUM(E1_SALDO) AS E1_SALDO   " 
	cQuery += " FROM    " 
	cQuery += " SE1010 (NOLOCK) AS SE1   " 
	cQuery += " WHERE    " 
	cQuery += " SE1.D_E_L_E_T_ = ''   " 
	cQuery += " AND E1_SALDO > 0 " 
	cQuery += " AND E1_PORTADO <>'P13' " 
	cQuery += " AND E1_TIPO IN ('NF ', 'NCI', 'NDC') " 
	cQuery += " GROUP BY    " 
	cQuery += " E1_CLIENTE, E1_LOJA " 
	cQuery += " ) AS B_TITULO " 
	cQuery += " ON B_CLIENTE.A1_COD = B_TITULO.E1_CLIENTE " 
	cQuery += " AND B_CLIENTE.A1_LOJA = B_TITULO.E1_LOJA " 
	cQuery += " LEFT OUTER JOIN    " 
	cQuery += " (     " 
	cQuery += " SELECT      " 
	cQuery += " ZF_CGCMAT, ZF_REDE, SUM(ZF_LCREDE) AS ZF_LCREDE     " 
	cQuery += " FROM      " 
	cQuery += " DADOSADV.dbo.SZF010 (NOLOCK) SZF     " 
	cQuery += " WHERE      " 
	cQuery += " SZF.D_E_L_E_T_=''     " 
	cQuery += " GROUP BY     " 
	cQuery += " ZF_CGCMAT, ZF_REDE     " 
	cQuery += " ) AS B_REDE   " 
	cQuery += " ON B_CLIENTE.RAIZ_CGC =  B_REDE.ZF_CGCMAT " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT    " 
	cQuery += " E1_CLIENTE, E1_LOJA, MAX(E1_EMISSAO) AS E1_EMISSAO   " 
	cQuery += " FROM    " 
	cQuery += " SE1010 (NOLOCK) AS SE1   " 
	cQuery += " WHERE    " 
	cQuery += " SE1.D_E_L_E_T_ = ''   " 
	cQuery += " GROUP BY    " 
	cQuery += " E1_CLIENTE, E1_LOJA " 
	cQuery += " ) AS B_TITULOULTC " 
	cQuery += " ON B_CLIENTE.A1_COD = B_TITULOULTC.E1_CLIENTE " 
	cQuery += " AND B_CLIENTE.A1_LOJA = B_TITULOULTC.E1_LOJA " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT  " 
	cQuery += " E1_CLIENTE,E1_LOJA,SUM(E1_VALOR) AS E1_SALDO " 
	cQuery += " FROM  " 
	cQuery += " SE1010 (NOLOCK) AS SE1 " 
	cQuery += " WHERE  " 
	cQuery += " SE1.D_E_L_E_T_ = '' " 
	cQuery += " AND E1_TIPO IN ('NF ','NCI','NDC') " 
	cQuery += " AND YEAR(E1_EMISSAO) = YEAR(GETDATE()) " 
	cQuery += " AND MONTH(E1_EMISSAO) = MONTH(GETDATE()) " 
	cQuery += " GROUP BY " 
	cQuery += " E1_CLIENTE,E1_LOJA " 
	cQuery += " ) AS B_FATURAMENTO " 
	cQuery += " ON B_CLIENTE.A1_COD = B_FATURAMENTO.E1_CLIENTE " 
	cQuery += " AND B_CLIENTE.A1_LOJA = B_FATURAMENTO.E1_LOJA " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT  " 
	cQuery += " E1_CLIENTE,E1_LOJA,SUM(E1_SALDO) AS E1_SALDO " 
	cQuery += " FROM  " 
	cQuery += " SE1010 (NOLOCK) AS SE1 " 
	cQuery += " WHERE  " 
	cQuery += " SE1.D_E_L_E_T_ = '' " 
	cQuery += " AND E1_TIPO IN ('NCC') " 
	cQuery += " AND YEAR(E1_EMISSAO) = YEAR(GETDATE()) " 
	cQuery += " AND MONTH(E1_EMISSAO) = MONTH(GETDATE()) " 
	cQuery += " GROUP BY " 
	cQuery += " E1_CLIENTE,E1_LOJA " 
	cQuery += " ) AS B_DEVOLUCAO " 
	cQuery += " ON B_CLIENTE.A1_COD = B_DEVOLUCAO.E1_CLIENTE " 
	cQuery += " AND B_CLIENTE.A1_LOJA = B_DEVOLUCAO.E1_LOJA " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " FONTE.A1_COD, FONTE.A1_LOJA " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " B_CLIENTE.A1_COD, " 
	cQuery += " B_CLIENTE.A1_LOJA, " 
	cQuery += " B_CLIENTE.A1_NOME, " 
	cQuery += " B_CLIENTE.RAIZ_CGC, " 
	cQuery += " B_CLIENTE.A1_DTCAD, " 
	cQuery += " B_CLIENTE.A1_DTREAT, " 
	cQuery += " CASE WHEN B_TITULO.E1_EMISSAO IS NULL THEN '' ELSE CONVERT(VARCHAR(10),CAST(B_TITULO.E1_EMISSAO AS DATE),103) END AS E1_EMISSAO, " 
	cQuery += " CASE WHEN B_TITULO.E1_EMISSAO IS NULL THEN   " 
	cQuery += " CASE WHEN A1_DTREAT <> '' THEN DATEDIFF(DAY,CAST(A1_DTREAT AS DATE),CAST(GETDATE() AS DATE)) ELSE DATEDIFF(DAY,CAST(A1_DTCAD AS DATE),CAST(GETDATE() AS DATE)) END " 
	cQuery += " ELSE " 
	cQuery += " DATEDIFF(DAY,CAST(B_TITULO.E1_EMISSAO AS DATE),CAST(GETDATE() AS DATE)) " 
	cQuery += " END AS DIAS, " 
	cQuery += " B_CLIENTE.A1_MSBLQL, " 
	cQuery += " B_CLIENTE.A1_VEND, " 
	cQuery += " B_REDE.ZF_REDE, " 
	cQuery += " B_CLIENTE.A3_SUPER " 
	cQuery += " FROM " 
	cQuery += " (     " 
	cQuery += " SELECT      " 
	cQuery += " A1_COD,      " 
	cQuery += " A1_LOJA,      " 
	cQuery += " A1_NOME,       " 
	cQuery += " LEFT(A1_CGC,8) AS RAIZ_CGC,      " 
	cQuery += " CASE WHEN A1_MSBLQL = '1' THEN 'Sim' ELSE 'Não' END AS A1_MSBLQL,     " 
	cQuery += " A1_DTCAD, " 
	cQuery += " A1_DTREAT, " 
	cQuery += " A1_VEND, " 
	cQuery += " A3_SUPER " 
	cQuery += " FROM      " 
	cQuery += " SA1010 (NOLOCK) AS SA1   " 
	cQuery += " INNER JOIN " 
	cQuery += " SA3010 (NOLOCK) AS SA3 " 
	cQuery += " ON A1_VEND = A3_COD   " 
	cQuery += " WHERE      " 
	cQuery += " SA1.D_E_L_E_T_='' " 
	cQuery += " AND SA3.D_E_L_E_T_=''    " 
	cQuery += " AND A1_VEND <> '' " 
	cQuery += " AND A1_DTCAD > '20130508' " 
	cQuery += " AND A1_MSBLQL = '2'  " 
	cQuery += " ) AS B_CLIENTE  " 
	cQuery += " LEFT OUTER JOIN     " 
	cQuery += " (     " 
	cQuery += " SELECT      " 
	cQuery += " E1_CLIENTE, E1_LOJA, MAX(E1_EMISSAO) AS E1_EMISSAO " 
	cQuery += " FROM      " 
	cQuery += " SE1010 (NOLOCK) AS SE1     " 
	cQuery += " WHERE      " 
	cQuery += " SE1.D_E_L_E_T_= ''      " 
	cQuery += " AND E1_EMISSAO > '20130508'      " 
	cQuery += " GROUP BY " 
	cQuery += " E1_CLIENTE,      " 
	cQuery += " E1_LOJA       " 
	cQuery += " ) AS B_TITULO " 
	cQuery += " ON B_CLIENTE.A1_COD = B_TITULO.E1_CLIENTE     " 
	cQuery += " AND B_CLIENTE.A1_LOJA = B_TITULO.E1_LOJA " 
	cQuery += " LEFT OUTER JOIN    " 
	cQuery += " (     " 
	cQuery += " SELECT      " 
	cQuery += " ZF_CGCMAT, ZF_REDE, SUM(ZF_LCREDE) AS ZF_LCREDE     " 
	cQuery += " FROM      " 
	cQuery += " DADOSADV.dbo.SZF010 (NOLOCK) SZF     " 
	cQuery += " WHERE      " 
	cQuery += " SZF.D_E_L_E_T_=''     " 
	cQuery += " GROUP BY     " 
	cQuery += " ZF_CGCMAT, ZF_REDE     " 
	cQuery += " ) AS B_REDE   " 
	cQuery += " ON B_CLIENTE.RAIZ_CGC =  B_REDE.ZF_CGCMAT " 
	cQuery += " ) AS FONTE " 
	cQuery += " WHERE FONTE.DIAS > 5    " 
	cQuery += " ) AS B_5DIASSV " 
	cQuery += " ON B_CLIENTE.A1_COD = B_5DIASSV.A1_COD " 
	cQuery += " AND B_CLIENTE.A1_LOJA = B_5DIASSV.A1_LOJA " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT  " 
	cQuery += " E1_CLIENTE,E1_LOJA, SUM(E1_SALDO) AS E1_SALDO, " 
	cQuery += " SUM(CASE WHEN CAST(E1_VENCREA AS DATE) < CAST(GETDATE() AS DATE) THEN E1_SALDO ELSE 0 END) AS ATRASO " 
	cQuery += " FROM  " 
	cQuery += " SE1010 (NOLOCK) SE1 " 
	cQuery += " WHERE  " 
	cQuery += " (SE1.D_E_L_E_T_=' ')  " 
	cQuery += " AND E1_SALDO>0 " 
	cQuery += " AND E1_PORTADO <> 'P13' " 
	cQuery += " AND E1_TIPO IN ('NF ', 'NCI','NDC') " 
	cQuery += " GROUP BY E1_CLIENTE,E1_LOJA " 
	cQuery += " ) AS B_TABERTO " 
	cQuery += " ON B_CLIENTE.A1_COD = B_TABERTO.E1_CLIENTE " 
	cQuery += " AND B_CLIENTE.A1_LOJA = B_TABERTO.E1_LOJA " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT  " 
	cQuery += " E1_CLIENTE,E1_LOJA,SUM(E1_VALOR) AS E1_VALOR, " 
	cQuery += " SUM(CASE WHEN E1_PORTADO <> 'P13' AND CAST(E1_VENCREA AS DATE) < CAST(GETDATE() AS DATE)THEN E1_SALDO ELSE 0 END) AS VENCIDO " 
	cQuery += " FROM  " 
	cQuery += " SE1010 (NOLOCK) SE1 " 
	cQuery += " WHERE  " 
	cQuery += " SE1.D_E_L_E_T_ = ''  " 
	cQuery += " AND E1_TIPO IN ('NF ','NCI','NDC') " 
	cQuery += " AND YEAR(E1_VENCREA) = YEAR(GETDATE()) " 
	cQuery += " AND MONTH(E1_VENCREA) = MONTH(GETDATE()) " 
	cQuery += " GROUP BY E1_CLIENTE, E1_LOJA " 
	cQuery += " ) AS B_EFICIENCIA " 
	cQuery += " ON B_CLIENTE.A1_COD = B_EFICIENCIA.E1_CLIENTE " 
	cQuery += " AND B_CLIENTE.A1_LOJA = B_EFICIENCIA.E1_LOJA " 

	//
	RestArea(aArea)
	
Return cQuery
/*/{Protheus.doc} grLimRedes
	Gera aba Lim.Redes. 
	@type  Static Function
	@author Everson
	@since 30/05/2017
	@version 01
	/*/
Static Function grLimRedes(nHandle,cVendedor)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea 	:= GetArea()
	Local cQuery	:= ""
	Local cRede		:= ""
	Local nTCons	:= 0
	Local nAux		:= 0
	Local nLimite	:= 0
	Local nTCons	:= 0
	
	cHtml := ""
	cHtml += " <div class='conteudo'> " 
	cHtml += " <h2 class='tituloAba'>Posição geral de redes e grupos econômicos</h2> " 

	//
	FWrite(nHandle, cHtml)
	cHtml := ""
	
	//
	cQuery := scriptlimRedes(cVendedor)
	
	//
	If Select("D_LREDES") > 0
		D_LREDES->(DbCloseArea())
		
	EndIf
	
	//Executa consulta no BD.
	TcQuery cQuery New Alias "D_LREDES"
	DbSelectArea("D_LREDES")
	
	//
	cHtml := ""
	cHtml += "#INFOREDE" 
	cHtml += " <table  id='tabLR" + Alltrim(cValToChar(nIdBtn)) + "' class='tabConteudo tabLiRede' style='display: none'> " 
	cHtml += " <tr> " 
	cHtml += " <th>Lojas</th> " 
	cHtml += " <th>Vlr. Aberto</th> " 
	cHtml += " <th>Vlr. Vencido</th> " 
	cHtml += " <th>Bloqueado</th> " 
	cHtml += " <th>Vendedor</th> " 
	cHtml += " </tr> " 
	
	//
	While ! D_LREDES->(Eof())
	
		cRede  := Alltrim(cValToChar(D_LREDES->ZF_REDE))
		nTCons += Val(cValToChar(D_LREDES->VLR_ABERTO)) + Val(cValToChar(D_LREDES->VLR_VENCIDO))
		nLimite:= Iif(Val(cValToChar(D_LREDES->ZF_LCREDE)) > nLimite,Val(cValToChar(D_LREDES->ZF_LCREDE)),nLimite)
		
		nAux++
		If (nAux%2) = 0
			cHtml += " <tr style='background-color: " + cCorLn + "'> "
		
		Else
			cHtml += " <tr> "
			
		EndIf
		
		cHtml += " <td>" + Alltrim(cValToChar(D_LREDES->A1_COD)) + "-" + Alltrim(cValToChar(D_LREDES->A1_LOJA)) + "-" + Alltrim(cValToChar(D_LREDES->A1_NOME)) + "</td> "
		cHtml += " <td align='right'>" + Transform(Val(cValToChar(D_LREDES->VLR_ABERTO)),"@E 999,999,999.99") + "</td> "
		cHtml += " <td align='right'>" + Transform(Val(cValToChar(D_LREDES->VLR_VENCIDO)),"@E 999,999,999.99") + "</td> "
		cHtml += " <td>" + Alltrim(cValToChar(D_LREDES->A1_MSBLQL)) + "</td> "
		cHtml += " <td align='right'>" + Alltrim(cValToChar(D_LREDES->A1_VEND)) + "</td> "
		cHtml += " </tr> "
		
		D_LREDES->(DbSkip())
		
		//
		If cRede <> Alltrim(cValToChar(D_LREDES->ZF_REDE)) .And. ! Empty(Alltrim(cValToChar(D_LREDES->ZF_REDE)))
			
			cHtml += " </table> " 
			cHtml += " <hr> " 
			cHtml := StrTran(cHtml,"#INFOREDE","<p><button style='float: left;margin-right: 5px' id='btn" + Alltrim(cValToChar(nIdBtn)) + "'>Exib./Ocult. Lojas</button><h3><span style='color:red;'>Rede: " + cRede + " - </span>Limite Aprovado: " + Transform(Val(cValToChar(nLimite)),"@E 999,999,999.99") + " - Limite Disponível: " + Transform(nLimite - nTCons,"@E 999,999,999.99") + "</h3></p>")
			
			//
			FWrite(nHandle, cHtml)
			cHtml := ""
			nTCons:= 0
			nLimite:= 0
			
			nIdBtn++
				
			cHtml += "#INFOREDE" 
			cHtml += " <table  id='tabLR" + Alltrim(cValToChar(nIdBtn)) + "' class='tabConteudo tabLiRede' style='display: none'> " 
			cHtml += " <tr> " 
			cHtml += " <th>Lojas</th> " 
			cHtml += " <th>Vlr. Aberto</th> " 
			cHtml += " <th>Vlr. Vencido</th> " 
			cHtml += " <th>Bloqueado</th> " 
			cHtml += " <th>Vendedor</th> " 
			cHtml += " </tr> " 
		
		EndIf
		
	EndDo
	
	//
	cHtml += " </table> "
	cHtml += " <hr> " 
	cHtml += " </div> " 
	
	cHtml := StrTran(cHtml,"#INFOREDE","<p><button style='float: left;margin-right: 5px' id='btn" + Alltrim(cValToChar(nIdBtn)) + "'>Exib./Ocult. Lojas</button><h3><span style='color:red;'>Rede: " + cRede + " - </span>Limite Aprovado: " + Transform(Val(cValToChar(nLimite)),"@E 999,999,999.99") + " - Limite Disponível: " + Transform(nLimite - nTCons,"@E 999,999,999.99") + "</h3></p>")
			
	//
	FWrite(nHandle, cHtml)
	cHtml := ""
	nTCons:= 0
	nLimite:= 0
	
	DbCloseArea("D_LREDES")
	
	//
	RestArea(aArea)		
	
Return Nil
/*/{Protheus.doc} scriptlimRedes
	Script sql aba Lim.Redes.
	@type  Static Function
	@author Everson
	@since 30/05/2017
	@version 01
	/*/
Static Function scriptlimRedes(cVendedor)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea := GetArea()
	Local cQuery:= ""
		
	cQuery := ""
	cQuery += " SELECT     " 
	cQuery += " B_CLIENTE.A1_COD, B_CLIENTE.A1_LOJA, B_CLIENTE.A1_NOME, B_CLIENTE.A1_MSBLQL,     " 
	cQuery += " ISNULL(B_TITULO.VRL_VENCER,0) AS VLR_ABERTO, ISNULL(B_TITULO.VRL_VENCIDO,0) AS VLR_VENCIDO,      " 
	cQuery += " B_CLIENTE.A1_VEND, B_REDE.ZF_REDE, B_REDE.ZF_LCREDE     " 
	cQuery += " FROM     " 
	cQuery += " (     " 
	cQuery += " SELECT      " 
	cQuery += " A1_COD,      " 
	cQuery += " A1_LOJA,      " 
	cQuery += " A1_NOME,       " 
	cQuery += " LEFT(A1_CGC,8) AS RAIZ_CGC,      " 
	cQuery += " CASE WHEN A1_MSBLQL = '1' THEN 'Sim' ELSE 'Não' END AS A1_MSBLQL,     " 
	cQuery += " A1_VEND     " 
	cQuery += " FROM      " 
	cQuery += " " + RetSqlName("SA1") + "  (NOLOCK) AS SA1     " 
	cQuery += " WHERE      " 
	cQuery += " SA1.D_E_L_E_T_=''     " 
	cQuery += " AND A1_VEND <> ''     " 
	cQuery += " ) AS B_CLIENTE     " 
	cQuery += " INNER JOIN     " 
	cQuery += " (     " 
	cQuery += " SELECT      " 
	cQuery += " ZF_CGCMAT, ZF_REDE,  MAX(ZF_LCREDE) AS ZF_LCREDE     " 
	cQuery += " FROM      " 
	cQuery += " " + RetSqlName("SZF") + " (NOLOCK) SZF   " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SA1") + " (NOLOCK) SA1 " 
	cQuery += " ON ZF_CGCMAT = LEFT(A1_CGC,8)  " 
	cQuery += " WHERE      " 
	cQuery += " SZF.D_E_L_E_T_=''   " 
	cQuery += " GROUP BY     " 
	cQuery += " ZF_CGCMAT, ZF_REDE     " 
	cQuery += " ) AS B_REDE     " 
	cQuery += " ON B_CLIENTE.RAIZ_CGC =  B_REDE.ZF_CGCMAT     " 
	cQuery += " LEFT OUTER JOIN     " 
	cQuery += " (     " 
	cQuery += " SELECT      " 
	cQuery += " E1_CLIENTE,      " 
	cQuery += " E1_LOJA,      " 
	cQuery += " SUM(CASE WHEN  CAST(E1_VENCREA AS DATE)  < CAST(GETDATE() AS DATE) THEN E1_SALDO ELSE 0 END) AS VRL_VENCIDO,   " 
	cQuery += " SUM(CASE WHEN  CAST(E1_VENCREA AS DATE) >= CAST(GETDATE() AS DATE) THEN E1_SALDO ELSE 0 END) AS VRL_VENCER   " 
	cQuery += " FROM      " 
	cQuery += " " + RetSqlName("SE1") + " (NOLOCK) AS SE1     " 
	cQuery += " WHERE      " 
	cQuery += " SE1.D_E_L_E_T_= ''      " 
	cQuery += " AND E1_SALDO > 0      " 
	cQuery += " AND E1_PORTADO <> 'P13'     " 
	cQuery += " AND E1_TIPO IN ('NF ','NCI','NDC')     " 
	cQuery += " GROUP BY   " 
	cQuery += " E1_CLIENTE,      " 
	cQuery += " E1_LOJA      " 
	cQuery += " ) AS B_TITULO     " 
	cQuery += " ON B_CLIENTE.A1_COD = B_TITULO.E1_CLIENTE     " 
	cQuery += " AND B_CLIENTE.A1_LOJA = B_TITULO.E1_LOJA       " 
	cQuery += " WHERE "
	cQuery += " B_REDE.ZF_REDE IN  "
	cQuery += " ( "
	cQuery += " SELECT      "
	cQuery += " DISTINCT ZF_REDE  "  
	cQuery += " FROM      "
	cQuery += " " + RetSqlName("SZF") + " (NOLOCK) SZF   "
	cQuery += " INNER JOIN "
	cQuery += " " + RetSqlName("SA1") + " (NOLOCK) SA1 "
	cQuery += " ON ZF_CGCMAT = LEFT(A1_CGC,8)  "
	cQuery += " WHERE      "
	cQuery += " SZF.D_E_L_E_T_=''  " 
	cQuery += " AND A1_VEND = '" + Alltrim(cValToChar(cVendedor)) + "'  "
	cQuery += " )  "
	cQuery += " ORDER BY     " 
	cQuery += " B_REDE.ZF_REDE, B_CLIENTE.A1_COD, B_CLIENTE.A1_LOJA " 
	
	//
	RestArea(aArea)
	
Return cQuery
/*/{Protheus.doc} grLimClientes
	Gera aba Lim.Clientes. 
	@type  Static Function
	@author Everson
	@since 31/05/2017
	@version 01
	/*/
Static Function grLimClientes(nHandle,cVendedor)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local nAux		:= 0
	
	//		
	cHtml := ""
	cHtml += " <div class='conteudo'> " 
	cHtml += " <h2 class='tituloAba'>Posição geral de clientes</h2> " 
	cHtml += " <table id='tabLimCli' class='tabConteudo'> " 
	cHtml += " <tr> " 
	cHtml += " <th>Cliente</th> " 
	cHtml += " <th>Valor a Vencer</th> " 
	cHtml += " <th>Valor Vencido</th> " 
	cHtml += " <th>Limite Aprovado</th> " 
	cHtml += " <th>Limite Disponível</th> " 
	cHtml += " <th>Bloqueado</th> " 
	cHtml += " </tr> "  
	
	//
	FWrite(nHandle, cHtml)
	cHtml := ""
	
	//
	cQuery := scriptLimClientes(cVendedor)
	
	//
	If Select("D_LCLIENTES") > 0
		D_LCLIENTES->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "D_LCLIENTES"
	
	DbSelectArea("D_LCLIENTES")
	
	While ! D_LCLIENTES->(Eof())

		nAux++
		If (nAux%2) = 0
			cHtml += " <tr style='background-color: " + cCorLn + "'> "
		
		Else
			cHtml += " <tr> "
			
		EndIf
		
		cHtml += " <td>" + Alltrim(cValToChar(D_LCLIENTES->CLIENTE)) + "</td> " 
		cHtml += " <td align='right'>" + Transform(Val(cValToChar(D_LCLIENTES->VLR_ABERTO)),"@E 999,999,999.99")  + "</td> " 
		cHtml += " <td align='right'>" + Transform(Val(cValToChar(D_LCLIENTES->VLR_VENCIDO)),"@E 999,999,999.99") + "</td> " 
		cHtml += " <td align='right'>" + Transform(Val(cValToChar(D_LCLIENTES->A1_LC)),"@E 999,999,999.99")       + "</td> " 
		cHtml += " <td align='right'>" + Transform(Val(cValToChar(D_LCLIENTES->LDISP)),"@E 999,999,999.99")       + "</td> " 
		cHtml += " <td>" + Alltrim(cValToChar(D_LCLIENTES->A1_MSBLQL)) + "</td> " 
		cHtml += " </tr> "	
	
		D_LCLIENTES->(DbSkip())
		
		//
		FWrite(nHandle, cHtml)
		cHtml := ""
		
	EndDo
	
	DbCloseArea("D_LCLIENTES")
	
	//
	cHtml += " </table> " 
	cHtml += " </div> "
	
	//
	FWrite(nHandle, cHtml)
	cHtml := ""
			
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} scriptLimClientes
	Script sql Lim.Clientes.  
	@type  Static Function
	@author Everson
	@since 31/05/2017
	@version 01
	/*/
Static Function scriptLimClientes(cVendedor)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	
	cQuery := ""
	cQuery += " SELECT     " 
	cQuery += " LTRIM(RTRIM(B_CLIENTE.A1_COD)) +'-'+ LTRIM(RTRIM(B_CLIENTE.A1_LOJA)) +'-'+ RTRIM(LTRIM(B_CLIENTE.A1_NOME)) AS CLIENTE, B_CLIENTE.A1_MSBLQL, " 
	cQuery += " ISNULL(B_TITULO.VRL_VENCER,0) AS VLR_ABERTO, ISNULL(B_TITULO.VRL_VENCIDO,0) AS VLR_VENCIDO,      " 
	cQuery += " B_CLIENTE.A1_VEND, B_CLIENTE.A1_LC,  B_CLIENTE.A1_LC - (ISNULL(B_TITULO.VRL_VENCER,0)+ISNULL(B_TITULO.VRL_VENCIDO,0)) AS LDISP " 
	cQuery += " FROM     " 
	cQuery += " (     " 
	cQuery += " SELECT      " 
	cQuery += " A1_COD,      " 
	cQuery += " A1_LOJA,      " 
	cQuery += " A1_NOME,       " 
	cQuery += " LEFT(A1_CGC,8) AS RAIZ_CGC,      " 
	cQuery += " CASE WHEN A1_MSBLQL = '1' THEN 'Sim' ELSE 'Não' END AS A1_MSBLQL,     " 
	cQuery += " A1_VEND, " 
	cQuery += " A1_LC   " 
	cQuery += " FROM      " 
	cQuery += " " + RetSqlName("SA1") + " (NOLOCK) AS SA1     " 
	cQuery += " WHERE      " 
	cQuery += " SA1.D_E_L_E_T_=''     " 
	cQuery += " AND A1_VEND <> ''    " 
	cQuery += " ) AS B_CLIENTE     " 
	cQuery += " LEFT OUTER JOIN    " 
	cQuery += " (     " 
	cQuery += " SELECT      " 
	cQuery += " ZF_CGCMAT, ZF_REDE, SUM(ZF_LCREDE) AS ZF_LCREDE     " 
	cQuery += " FROM      " 
	cQuery += " " + RetSqlName("SZF") + " (NOLOCK) SZF     " 
	cQuery += " WHERE      " 
	cQuery += " SZF.D_E_L_E_T_=''     " 
	cQuery += " GROUP BY     " 
	cQuery += " ZF_CGCMAT, ZF_REDE     " 
	cQuery += " ) AS B_REDE     " 
	cQuery += " ON B_CLIENTE.RAIZ_CGC =  B_REDE.ZF_CGCMAT     " 
	cQuery += " LEFT OUTER JOIN     " 
	cQuery += " (     " 
	cQuery += " SELECT      " 
	cQuery += " E1_CLIENTE,      " 
	cQuery += " E1_LOJA,      " 
	cQuery += " SUM(CASE WHEN  CAST(E1_VENCREA AS DATE)  < CAST(GETDATE() AS DATE) THEN E1_SALDO ELSE 0 END) AS VRL_VENCIDO,   " 
	cQuery += " SUM(CASE WHEN  CAST(E1_VENCREA AS DATE) >= CAST(GETDATE() AS DATE) THEN E1_SALDO ELSE 0 END) AS VRL_VENCER   " 
	cQuery += " FROM      " 
	cQuery += " " + RetSqlName("SE1") + " (NOLOCK) AS SE1     " 
	cQuery += " WHERE      " 
	cQuery += " SE1.D_E_L_E_T_= ''      " 
	cQuery += " AND E1_SALDO > 0      " 
	cQuery += " AND E1_PORTADO <> 'P13'     " 
	cQuery += " AND E1_TIPO IN ('NF ','NCI','NDC')     " 
	cQuery += " GROUP BY   " 
	cQuery += " E1_CLIENTE,      " 
	cQuery += " E1_LOJA      " 
	cQuery += " ) AS B_TITULO     " 
	cQuery += " ON B_CLIENTE.A1_COD = B_TITULO.E1_CLIENTE     " 
	cQuery += " AND B_CLIENTE.A1_LOJA = B_TITULO.E1_LOJA     " 
	cQuery += " WHERE     " 
	cQuery += " B_CLIENTE.A1_VEND = '" + Alltrim(cValToChar(cVendedor)) + "'   " 
	cQuery += " AND ZF_REDE IS NULL   " 
	cQuery += " ORDER BY     " 
	cQuery += " B_CLIENTE.A1_MSBLQL, B_CLIENTE.A1_COD, B_CLIENTE.A1_LOJA " 
	
	//
	RestArea(aArea)
	
Return cQuery
/*/{Protheus.doc} grVlrAberto
	Gera aba Vlr.Aberto.  
	@type  Static Function
	@author Everson
	@since 31/05/2017
	@version 01
	/*/
Static Function grVlrAberto(nHandle,cVendedor)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea	:= GetArea()
	Local cHtml	:= ""
	Local cQuery:= ""
	Local nAux	:= 0
	
	cHtml := ""
	cHtml += " <div class='conteudo'> " 
	cHtml += " <h2 class='tituloAba'>Valores vencidos - Por cliente</h2> " 
	cHtml += " <table class='tabConteudo'> " 
	cHtml += " <tr> " 
	cHtml += " <th>Cliente</th> " 
	cHtml += " <th>Bloqueado</th> " 
	cHtml += " <th>Rede</th> " 
	cHtml += " <th>Vencimento</th> " 
	cHtml += " <th>Portador</th> " 
	cHtml += " <th>Número/Parcela</th> " 
	cHtml += " <th>Valor</th> " 
	cHtml += " <th>Histórico</th> " 
	cHtml += " </tr> " 
	
	//
	FWrite(nHandle, cHtml)
	cHtml := ""
	
	//
	cQuery := scriptVlrAbt(cVendedor,1)
	
	If Select("D_VLRABT") > 0
		D_VLRABT->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "D_VLRABT"
	DbSelectArea("D_VLRABT")
	
	nAux := 0
	While ! D_VLRABT->(Eof())
		
		nAux++
		If (nAux%2) = 0
			cHtml += " <tr style='background-color: " + cCorLn + "'> "
		
		Else
			cHtml += " <tr> "
			
		EndIf
		
		cHtml += " <td>" + Alltrim(cValToChar(D_VLRABT->CLIENTE))    + "</td> " 
		cHtml += " <td>" + Alltrim(cValToChar(D_VLRABT->A1_MSBLQL))  + "</td> " 
		cHtml += " <td>" + Alltrim(cValToChar(D_VLRABT->ZF_REDE))    + "</td> " 
		cHtml += " <td>" + Alltrim(cValToChar(D_VLRABT->E1_VENCREA)) + "</td> " 
		cHtml += " <td>" + Alltrim(cValToChar(D_VLRABT->E1_PORTADO)) + "</td> " 
		cHtml += " <td>" + Alltrim(cValToChar(D_VLRABT->TITULO))     + "</td> " 
		cHtml += " <td align='right'>" + Transform(Val(cValToChar(D_VLRABT->VLR_VENCIDO)),"@E 999,999,999.99") + "</td> " 
		cHtml += " <td>" + Alltrim(cValToChar(D_VLRABT->E1_HIST))    + "</td> " 
		cHtml += " </tr> " 
		
		D_VLRABT->(DbSkip())
		
		//
		FWrite(nHandle, cHtml)
		cHtml := ""
		
	EndDo
	
	DbCloseArea("D_VLRABT")
	
	//
	cHtml += " </table> " 
	FWrite(nHandle, cHtml)
	cHtml := ""
	
	cHtml += " <h2 class='tituloAba'>Valores pendentes - Por cliente</h2> " 
	cHtml += " <table class='tabConteudo'> " 
	cHtml += " <tr> " 
	cHtml += " <th>Cliente</th> " 
	cHtml += " <th>Bloqueado</th> " 
	cHtml += " <th>Rede</th> " 
	cHtml += " <th>Vencimento</th> " 
	cHtml += " <th>Portador</th> " 
	cHtml += " <th>Número/Parcela</th> " 
	cHtml += " <th>Valor</th> " 
	cHtml += " <th>Histórico</th> " 
	cHtml += " </tr> "
	FWrite(nHandle, cHtml)
	cHtml := ""
	
	//
	cQuery := scriptVlrAbt(cVendedor,2)
	
	If Select("D_VLRABTP") > 0
		D_VLRABTP->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "D_VLRABTP"
	DbSelectArea("D_VLRABTP")
	
	nAux := 0
	While ! D_VLRABTP->(Eof())
		
		nAux++
		If (nAux%2) = 0
			cHtml += " <tr style='background-color: " + cCorLn + "'> "
		
		Else
			cHtml += " <tr> "
			
		EndIf
		
		cHtml += " <td>" + Alltrim(cValToChar(D_VLRABTP->CLIENTE))    + "</td> " 
		cHtml += " <td>" + Alltrim(cValToChar(D_VLRABTP->A1_MSBLQL))  + "</td> " 
		cHtml += " <td>" + Alltrim(cValToChar(D_VLRABTP->ZF_REDE))    + "</td> " 
		cHtml += " <td>" + Alltrim(cValToChar(D_VLRABTP->E1_VENCREA)) + "</td> " 
		cHtml += " <td>" + Alltrim(cValToChar(D_VLRABTP->E1_PORTADO)) + "</td> " 
		cHtml += " <td>" + Alltrim(cValToChar(D_VLRABTP->TITULO))     + "</td> " 
		cHtml += " <td align='right'>" + Transform(Val(cValToChar(D_VLRABTP->VLR_VENCIDO)),"@E 999,999,999.99") + "</td> " 
		cHtml += " <td>" + Alltrim(cValToChar(D_VLRABTP->E1_HIST))    + "</td> " 
		cHtml += " </tr> " 
		
		D_VLRABTP->(DbSkip())
		
		//
		FWrite(nHandle, cHtml)
		cHtml := ""
		
	EndDo
	
	DbCloseArea("D_VLRABTP")
	 
	cHtml += " </table> "
	
	cHtml += " </div> " 
	FWrite(nHandle, cHtml)
	cHtml := ""
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} scriptVlrAbt
	Script sql aba Vlr.Aberto. 
	@type  Static Function
	@author Everson
	@since 31/05/2017
	@version 01
	/*/
Static Function scriptVlrAbt(cVendedor,Opc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea	:= GetArea()
	Local cHtml	:= ""
	Local cQuery:= ""
	
	cQuery := ""
	cQuery += " SELECT     " 
	cQuery += " LTRIM(RTRIM(B_CLIENTE.A1_COD)) +'-'+ LTRIM(RTRIM(B_CLIENTE.A1_LOJA)) +'-'+ RTRIM(LTRIM(B_CLIENTE.A1_NOME)) AS CLIENTE, B_CLIENTE.A1_MSBLQL, " 
	cQuery += " ISNULL(B_REDE.ZF_REDE,'') AS ZF_REDE,   " 
	cQuery += " CONVERT(VARCHAR(10),CAST(B_TITULO.E1_VENCREA AS DATE),103) AS E1_VENCREA,  " 
	cQuery += " B_TITULO.E1_PORTADO,  " 
	cQuery += " B_TITULO.TITULO, " 
	cQuery += " ISNULL(B_TITULO.VRL_VENCIDO,0) AS VLR_VENCIDO, B_TITULO.E1_HIST " 
	cQuery += " FROM     " 
	cQuery += " (     " 
	cQuery += " SELECT      " 
	cQuery += " A1_COD,      " 
	cQuery += " A1_LOJA,      " 
	cQuery += " A1_NOME,       " 
	cQuery += " LEFT(A1_CGC,8) AS RAIZ_CGC,      " 
	cQuery += " CASE WHEN A1_MSBLQL = '1' THEN 'Sim' ELSE 'Não' END AS A1_MSBLQL,     " 
	cQuery += " A1_VEND, " 
	cQuery += " A1_LC   " 
	cQuery += " FROM      " 
	cQuery += " " + RetSqlName("SA1") + " (NOLOCK) AS SA1     " 
	cQuery += " WHERE      " 
	cQuery += " SA1.D_E_L_E_T_=''     " 
	cQuery += " AND A1_VEND <> ''     " 
	cQuery += " ) AS B_CLIENTE     " 
	cQuery += " LEFT OUTER JOIN    " 
	cQuery += " (     " 
	cQuery += " SELECT      " 
	cQuery += " ZF_CGCMAT, ZF_REDE, SUM(ZF_LCREDE) AS ZF_LCREDE     " 
	cQuery += " FROM      " 
	cQuery += " " + RetSqlName("SZF") + " (NOLOCK) SZF     " 
	cQuery += " WHERE      " 
	cQuery += " SZF.D_E_L_E_T_=''     " 
	cQuery += " GROUP BY     " 
	cQuery += " ZF_CGCMAT, ZF_REDE     " 
	cQuery += " ) AS B_REDE     " 
	cQuery += " ON B_CLIENTE.RAIZ_CGC =  B_REDE.ZF_CGCMAT     " 
	cQuery += " LEFT OUTER JOIN     " 
	cQuery += " (     " 
	cQuery += " SELECT      " 
	cQuery += " E1_CLIENTE,      " 
	cQuery += " E1_LOJA,  " 
	cQuery += " E1_PORTADO, " 
	cQuery += " E1_VENCREA,    " 
	cQuery += " E1_HIST,  " 
	cQuery += " E1_TIPO + '-' + E1_NUM + CASE WHEN E1_PARCELA <> '' THEN '-' + E1_PARCELA ELSE '' END AS TITULO, " 
	cQuery += " CASE WHEN  CAST(E1_VENCREA AS DATE)  < CAST(GETDATE() AS DATE) THEN E1_SALDO ELSE 0 END AS VRL_VENCIDO,   " 
	cQuery += " CASE WHEN  CAST(E1_VENCREA AS DATE) >= CAST(GETDATE() AS DATE) THEN E1_SALDO ELSE 0 END AS VRL_VENCER   " 
	cQuery += " FROM      " 
	cQuery += " " + RetSqlName("SE1") + " (NOLOCK) AS SE1     " 
	cQuery += " WHERE      " 
	cQuery += " SE1.D_E_L_E_T_= ''      " 
	cQuery += " AND E1_SALDO > 0      " 
	cQuery += " AND E1_PORTADO <> 'P13'     " 
	cQuery += " AND E1_TIPO IN ('NF ','NCI','CH ','NDC')         " 
	cQuery += " ) AS B_TITULO     " 
	cQuery += " ON B_CLIENTE.A1_COD = B_TITULO.E1_CLIENTE     " 
	cQuery += " AND B_CLIENTE.A1_LOJA = B_TITULO.E1_LOJA     " 
	cQuery += " WHERE     " 
	cQuery += " B_CLIENTE.A1_VEND = '" + Alltrim(cValToChar(cVendedor)) + "'   " 
	cQuery += " AND B_TITULO.VRL_VENCIDO > 0   " 
	
	//
	If Opc == 1
		cQuery += " AND B_TITULO.E1_PORTADO NOT IN ('P00', 'P01', 'P02', 'P03', 'P14') "
	
	ElseIf Opc == 2
		cQuery += " AND B_TITULO.E1_PORTADO IN ('P00', 'P01', 'P02', 'P03', 'P14') "
	
	EndIf
	
	cQuery += " ORDER BY     " 
	cQuery += " B_CLIENTE.A1_COD, B_CLIENTE.A1_LOJA " 

	//
	RestArea(aArea)
	
Return cQuery
/*/{Protheus.doc} grUltComp
	Gera aba Últ.Compra
	@type  Static Function
	@author Everson
	@since 31/05/2017
	@version 01
	/*/
Static Function grUltComp(nHandle,cVendedor)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea	:= GetArea()
	Local cHtml	:= ""	
	Local cQuery:= ""
	Local nAux	:= 0
	
	cHtml := ""
	cHtml += " <div class='conteudo'> " 
	cHtml += " <h2 class='tituloAba'>Clientes sem venda</h2> " 
	cHtml += " <table class='tabConteudo'> " 
	cHtml += " <tr> " 
	cHtml += " <th>Cliente</th> " 
	cHtml += " <th>Rede</th> " 
	cHtml += " <th>Data Cadastro</th> " 
	cHtml += " <th>Data Últ. Alteração</th> " 
	cHtml += " <th>Últ. Compra</th> " 
	cHtml += " <th>Dias</th> " 
	cHtml += " <th>Bloqueado</th> " 
	cHtml += " </tr> " 

	//
	FWrite(nHandle, cHtml)
	cHtml := ""
	
	//
	cQuery := scriptUltCompr(cVendedor)
	
	//
	If Select("D_ULTCOMP") > 0
		D_ULTCOMP->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "D_ULTCOMP"
	DbSelectArea("D_ULTCOMP")
	D_ULTCOMP->(DbGoTop())

	While ! D_ULTCOMP->(Eof())

		nAux++
		If (nAux%2) = 0
			cHtml += " <tr style='background-color: " + cCorLn + "'> "
		
		Else
			cHtml += " <tr> "
			
		EndIf
		 
		cHtml += " <td>" + Alltrim(cValToChar(D_ULTCOMP->CLIENTE))           + "</td> " 
		cHtml += " <td>" + Alltrim(cValToChar(D_ULTCOMP->ZF_REDE))           + "</td> " 
		cHtml += " <td align='right'>" + Alltrim(cValToChar(D_ULTCOMP->A1_DTCAD))          + "</td> " 
		cHtml += " <td align='right'>" + Alltrim(cValToChar(D_ULTCOMP->A1_DTREAT))         + "</td> " 
		cHtml += " <td align='right'>" + Alltrim(cValToChar(D_ULTCOMP->E1_EMISSAO))        + "</td> " 
		cHtml += " <td align='right'>" + Alltrim(cValToChar(D_ULTCOMP->DIAS))+ "</td> " 
		cHtml += " <td>" + Alltrim(cValToChar(D_ULTCOMP->A1_MSBLQL))         + "</td> " 
		cHtml += " </tr> " 		
	
		D_ULTCOMP->(DbSkip())
		
		FWrite(nHandle, cHtml)
		cHtml := ""
		
	EndDo
	
	DbCloseArea("D_ULTCOMP")
	
	//
	cHtml += " </table> " 
	cHtml += " </div> " 	
	FWrite(nHandle, cHtml)
	cHtml := ""
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} scriptUltCompr
	Script sql aba Últ.Compra.
	@type  Static Function
	@author Everson
	@since 31/05/2017
	@version 01
	/*/
Static Function scriptUltCompr(cVendedor)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea	:= GetArea()
	Local cQuery:= ""
	
	cQuery := " SELECT * FROM ("
	cQuery += " SELECT     " 
	cQuery += " LTRIM(RTRIM(B_CLIENTE.A1_COD)) +'-'+ LTRIM(RTRIM(B_CLIENTE.A1_LOJA)) +'-'+ RTRIM(LTRIM(B_CLIENTE.A1_NOME)) AS CLIENTE, " 
	cQuery += " ISNULL(B_REDE.ZF_REDE,'') AS ZF_REDE, " 
	cQuery += " CONVERT(VARCHAR(10),CAST(B_CLIENTE.A1_DTCAD AS DATE),103) AS A1_DTCAD, " 
	cQuery += " CASE WHEN B_CLIENTE.A1_DTREAT = '' THEN '' ELSE CONVERT(VARCHAR(10),CAST(B_CLIENTE.A1_DTREAT AS DATE),103) END AS A1_DTREAT, " 
	cQuery += " CASE WHEN B_FATURAMENTO.E1_EMISSAO IS NULL THEN '' ELSE CONVERT(VARCHAR(10),CAST(B_FATURAMENTO.E1_EMISSAO AS DATE),103) END AS E1_EMISSAO, " 
	cQuery += " CASE WHEN  " 
	cQuery += " B_FATURAMENTO.E1_EMISSAO <> ''  " 
	cQuery += " THEN  " 
	cQuery += " DATEDIFF(DAY,CAST( B_FATURAMENTO.E1_EMISSAO AS DATE),GETDATE())  " 
	cQuery += " ELSE  " 
	cQuery += " CASE WHEN  ISNULL(B_CLIENTE.A1_DTREAT,'') <> '' THEN DATEDIFF(DAY,CAST( B_CLIENTE.A1_DTREAT AS DATE),GETDATE()) ELSE DATEDIFF(DAY,CAST( B_CLIENTE.A1_DTCAD AS DATE),GETDATE()) END  " 
	cQuery += " END AS DIAS, " 
	cQuery += " B_CLIENTE.A1_MSBLQL " 
	cQuery += " FROM     " 
	cQuery += " (     " 
	cQuery += " SELECT      " 
	cQuery += " A1_COD,      " 
	cQuery += " A1_LOJA,      " 
	cQuery += " A1_NOME,       " 
	cQuery += " LEFT(A1_CGC,8) AS RAIZ_CGC,      " 
	cQuery += " CASE WHEN A1_MSBLQL = '1' THEN 'Sim' ELSE 'Não' END AS A1_MSBLQL, " 
	cQuery += " A1_DTCAD, " 
	cQuery += " A1_VEND, " 
	cQuery += " A1_DTREAT " 
	cQuery += " FROM      " 
	cQuery += " " + RetSqlName("SA1") + " (NOLOCK) AS SA1     " 
	cQuery += " WHERE      " 
	cQuery += " SA1.D_E_L_E_T_=''     " 
	cQuery += " AND A1_VEND <> ''     " 
	cQuery += " ) AS B_CLIENTE     " 
	cQuery += " LEFT OUTER JOIN    " 
	cQuery += " (     " 
	cQuery += " SELECT      " 
	cQuery += " ZF_CGCMAT, ZF_REDE, SUM(ZF_LCREDE) AS ZF_LCREDE     " 
	cQuery += " FROM      " 
	cQuery += " " + RetSqlName("SZF") + " (NOLOCK) SZF     " 
	cQuery += " WHERE      " 
	cQuery += " SZF.D_E_L_E_T_=''     " 
	cQuery += " GROUP BY     " 
	cQuery += " ZF_CGCMAT, ZF_REDE     " 
	cQuery += " ) AS B_REDE " 
	cQuery += " ON B_CLIENTE.RAIZ_CGC =  B_REDE.ZF_CGCMAT  " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT  " 
	cQuery += " E1_CLIENTE, E1_LOJA, MAX(E1_EMISSAO) AS E1_EMISSAO " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("SE1") + " (NOLOCK) AS SE1 " 
	cQuery += " WHERE  " 
	cQuery += " SE1.D_E_L_E_T_ = '' " 
	cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) = YEAR(CAST(GETDATE() AS DATE))  " 
	cQuery += " GROUP BY  " 
	cQuery += " E1_CLIENTE, E1_LOJA " 
	cQuery += " ) AS B_FATURAMENTO " 
	cQuery += " ON B_CLIENTE.A1_COD = B_FATURAMENTO.E1_CLIENTE " 
	cQuery += " AND B_CLIENTE.A1_LOJA = B_FATURAMENTO.E1_LOJA       " 
	cQuery += " WHERE     " 
	cQuery += " B_CLIENTE.A1_VEND = '" + Alltrim(cValToChar(cVendedor)) + "'   " 
	cQuery += " ) AS FONTE "
	cQuery += " ORDER BY     " 
	cQuery += " FONTE.DIAS DESC " 
	
	//
	RestArea(aArea)

Return cQuery
/*/{Protheus.doc} grLim70 
	Gera aba Lim. +70%. 
	@type  Static Function
	@author Everson
	@since 31/05/2017
	@version 01
	/*/
Static Function grLim70(nHandle,cVendedor)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea	:= GetArea()
	Local cHtml	:= ""	
	Local cQuery:= ""
	Local nAux	:= 0
	
	cHtml := ""
	cHtml += " <div class='conteudo'> " 
	cHtml += " <h2 class='tituloAba'>Clientes/Redes - Utilizando mais de 70% do limite aprovado</h2> " 
	cHtml += " <table class='tabConteudo'> " 
	cHtml += " <tr> " 
	cHtml += " <th>Rede</th> " 
	cHtml += " <th>Cliente</th> " 
	cHtml += " <th>Vendedor</th> " 
	cHtml += " <th>Bloqueado</th> " 
	cHtml += " <th>Vlr Aberto Loja</th> " 
	cHtml += " <th>Vlr Aberto Demais Lojas</th> " 
	cHtml += " <th>Limite Utilizado</th> " 
	cHtml += " <th>Limite Aprovado</th> " 
	cHtml += " <th>% Limite Utilizado</th> " 
	cHtml += " </tr> " 
 
	//
	FWrite(nHandle, cHtml)
	cHtml := ""
	
	//
	cQuery := scriptLim70(cVendedor)
	
	//
	If Select("D_LIM70") > 0
		D_LIM70->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "D_LIM70"
	DbSelectArea("D_LIM70")
	D_LIM70->(DbGoTop())
	
	While ! D_LIM70->(Eof())

		nAux++
		If (nAux%2) = 0
			cHtml += " <tr style='background-color:" + cCorLn + "'> "
		
		Else
			cHtml += " <tr> "
			
		EndIf
		 
		cHtml += " <td>" + Alltrim(cValToChar(D_LIM70->ZF_REDE))   + "</td> " 
		cHtml += " <td>" + Alltrim(cValToChar(D_LIM70->CLIENTE))   + "</td> " 
		cHtml += " <td>" + Alltrim(cValToChar(D_LIM70->A1_VEND))   + "</td> " 
		cHtml += " <td>" + Alltrim(cValToChar(D_LIM70->A1_MSBLQL)) + "</td> " 
		cHtml += " <td align='right'>" + Transform(Val(cValToChar(D_LIM70->VRL_ABERTO)),"@E 999,999,999.99") + "</td> " 
		cHtml += " <td align='right'>" + Transform(Val(cValToChar(D_LIM70->VLRABRDLJ)),"@E 999,999,999.99")  + "</td> " 
		cHtml += " <td align='right'>" + Transform(Val(cValToChar(D_LIM70->LMUTL)),"@E 999,999,999.99")      + "</td> " 
		cHtml += " <td align='right'>" + Transform(Val(cValToChar(D_LIM70->LCRED)),"@E 999,999,999.99")      + "</td> " 
		cHtml += " <td align='right'>" + Transform(Val(cValToChar(D_LIM70->PERCUT)),"@E 999,999,999.99")     + "</td> " 
		cHtml += " </tr> " 	
		
		D_LIM70->(DbSkip())
		
		//
		FWrite(nHandle, cHtml)
		cHtml := ""
		
	EndDo
	
	//
	cHtml += " </table> " 
	cHtml += " </div> "
	FWrite(nHandle, cHtml)
	cHtml := ""
		
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} scriptLim70 
	Script sql aba Lim. +70%.
	@type  Static Function
	@author Everson
	@since 31/05/2017
	@version 01
	/*/
Static Function scriptLim70(cVendedor)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	 := GetArea()
	Local cQuery := ""
	
	//
	cQuery := ""
	cQuery += " SELECT * " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " FONTE.ZF_REDE, " 
	cQuery += " FONTE.CLIENTE, " 
	cQuery += " FONTE.A1_VEND, " 
	cQuery += " FONTE.A1_MSBLQL, " 
	cQuery += " FONTE.VRL_ABERTO, " 
	cQuery += " CASE WHEN FONTE.ZF_REDE = '' THEN FONTE.VLRABRDLJ ELSE ISNULL(B_FATREDE.VRL_ABERTO,0) - FONTE.VRL_ABERTO END AS VLRABRDLJ , " 
	cQuery += " CASE WHEN FONTE.ZF_REDE = '' THEN FONTE.LMUTL ELSE ISNULL(B_FATREDE.VRL_ABERTO,0) END AS LMUTL, " 
	cQuery += " FONTE.LCRED, " 
	cQuery += " ROUND(ISNULL(CASE WHEN FONTE.ZF_REDE = '' THEN FONTE.PERCUT ELSE " 
	cQuery += " CASE WHEN FONTE.LCRED > 0 THEN (B_FATREDE.VRL_ABERTO/FONTE.LCRED)*100 END " 
	cQuery += " END,0),2) AS PERCUT " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT    " 
	cQuery += " ISNULL(B_REDE.ZF_REDE,'') AS ZF_REDE,  " 
	cQuery += " B_CLIENTE.RAIZ_CGC,  " 
	cQuery += " LTRIM(RTRIM(B_CLIENTE.A1_COD)) +'-'+ LTRIM(RTRIM(B_CLIENTE.A1_LOJA)) +'-'+ RTRIM(LTRIM(B_CLIENTE.A1_NOME)) AS CLIENTE,  " 
	cQuery += " B_CLIENTE.A1_VEND, " 
	cQuery += " B_CLIENTE.A1_MSBLQL, " 
	cQuery += " ISNULL(B_TITULO.VRL_ABERTO,0) AS VRL_ABERTO, " 
	cQuery += "  " 
	cQuery += " CASE WHEN ISNULL(B_REDE.ZF_REDE,'') = '' THEN 0 ELSE  " 
	cQuery += " 0.01 " 
	cQuery += " END  AS VLRABRDLJ, " 
	cQuery += "  " 
	cQuery += " CASE WHEN ISNULL(B_REDE.ZF_REDE,'') = '' THEN ISNULL(B_TITULO.VRL_ABERTO,0) ELSE " 
	cQuery += " 0.01 " 
	cQuery += " END AS LMUTL, " 
	cQuery += "  " 
	cQuery += "  " 
	cQuery += " CASE WHEN B_REDE.ZF_LCREDE IS NULL THEN B_CLIENTE.A1_LC ELSE ZF_LCREDE END AS LCRED, " 
	cQuery += "  " 
	cQuery += " CASE WHEN ISNULL(B_REDE.ZF_REDE,'') = '' THEN  " 
	cQuery += " CASE WHEN B_CLIENTE.A1_LC > 0 THEN (ISNULL(B_TITULO.VRL_ABERTO,0)/B_CLIENTE.A1_LC) * 100 " 
	cQuery += " ELSE  " 
	cQuery += " 0 " 
	cQuery += " END " 
	cQuery += " ELSE  " 
	cQuery += " 0 " 
	cQuery += " END AS PERCUT " 
	cQuery += "  " 
	cQuery += " FROM     " 
	cQuery += " (     " 
	cQuery += " SELECT      " 
	cQuery += " A1_COD,      " 
	cQuery += " A1_LOJA,      " 
	cQuery += " A1_NOME,       " 
	cQuery += " LEFT(A1_CGC,8) AS RAIZ_CGC,      " 
	cQuery += " CASE WHEN A1_MSBLQL = '1' THEN 'Sim' ELSE 'Não' END AS A1_MSBLQL,     " 
	cQuery += " A1_VEND, " 
	cQuery += " A1_LC   " 
	cQuery += " FROM      " 
	cQuery += " " + RetSqlName("SA1") + " (NOLOCK) AS SA1     " 
	cQuery += " WHERE      " 
	cQuery += " SA1.D_E_L_E_T_=''     " 
	cQuery += " AND A1_VEND <> ''     " 
	cQuery += " ) AS B_CLIENTE     " 
	cQuery += " LEFT OUTER JOIN    " 
	cQuery += " (     " 
	cQuery += " SELECT      " 
	cQuery += " ZF_CGCMAT, ZF_REDE, SUM(ZF_LCREDE) AS ZF_LCREDE     " 
	cQuery += " FROM      " 
	cQuery += " " + RetSqlName("SZF") + " (NOLOCK) SZF     " 
	cQuery += " WHERE      " 
	cQuery += " SZF.D_E_L_E_T_=''     " 
	cQuery += " GROUP BY     " 
	cQuery += " ZF_CGCMAT, ZF_REDE     " 
	cQuery += " ) AS B_REDE     " 
	cQuery += " ON B_CLIENTE.RAIZ_CGC =  B_REDE.ZF_CGCMAT     " 
	cQuery += " LEFT OUTER JOIN     " 
	cQuery += " (     " 
	cQuery += " SELECT      " 
	cQuery += " E1_CLIENTE,      " 
	cQuery += " E1_LOJA, " 
	cQuery += " SUM(CASE WHEN  CAST(E1_VENCREA AS DATE)  < CAST(GETDATE() AS DATE) THEN E1_SALDO ELSE 0 END) +   " 
	cQuery += " SUM(CASE WHEN  CAST(E1_VENCREA AS DATE) >= CAST(GETDATE() AS DATE) THEN E1_SALDO ELSE 0 END) AS VRL_ABERTO " 
	cQuery += " FROM      " 
	cQuery += " " + RetSqlName("SE1") + " (NOLOCK) AS SE1     " 
	cQuery += " WHERE      " 
	cQuery += " SE1.D_E_L_E_T_= ''      " 
	cQuery += " AND E1_SALDO > 0      " 
	cQuery += " AND E1_PORTADO <> 'P13'     " 
	cQuery += " AND E1_TIPO IN ('NF ','NCI','NDC')  " 
	cQuery += " GROUP BY " 
	cQuery += " E1_CLIENTE,      " 
	cQuery += " E1_LOJA       " 
	cQuery += " ) AS B_TITULO     " 
	cQuery += " ON B_CLIENTE.A1_COD = B_TITULO.E1_CLIENTE     " 
	cQuery += " AND B_CLIENTE.A1_LOJA = B_TITULO.E1_LOJA   " 
	cQuery += "  " 
	cQuery += " WHERE     " 
	cQuery += " B_CLIENTE.A1_VEND = '" + Alltrim(cValToChar(cVendedor)) + "'  " 
	cQuery += "  " 
	cQuery += " ) AS FONTE " 
	cQuery += "  " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT      " 
	cQuery += " ZF_CGCMAT, " 
	cQuery += " SUM(CASE WHEN  CAST(E1_VENCREA AS DATE)  < CAST(GETDATE() AS DATE) THEN E1_SALDO ELSE 0 END) +   " 
	cQuery += " SUM(CASE WHEN  CAST(E1_VENCREA AS DATE) >= CAST(GETDATE() AS DATE) THEN E1_SALDO ELSE 0 END) AS VRL_ABERTO " 
	cQuery += " FROM      " 
	cQuery += " " + RetSqlName("SE1") + " (NOLOCK) AS SE1   " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SA1") + " (NOLOCK) AS SA1 " 
	cQuery += " ON E1_CLIENTE = A1_COD " 
	cQuery += " AND E1_LOJA = A1_LOJA   " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SZF") + " (NOLOCK) AS SZF " 
	cQuery += " ON SUBSTRING(A1_CGC,1,8) = ZF_CGCMAT " 
	cQuery += " WHERE      " 
	cQuery += " SE1.D_E_L_E_T_= ''   " 
	cQuery += " AND SA1.D_E_L_E_T_ = ''  " 
	cQuery += " AND SZF.D_E_L_E_T_ = ''   " 
	cQuery += " AND E1_SALDO > 0      " 
	cQuery += " AND E1_PORTADO <> 'P13'     " 
	cQuery += " AND E1_TIPO IN ('NF ','NCI','NDC')  " 
	cQuery += " GROUP BY " 
	cQuery += " ZF_CGCMAT     " 
	cQuery += " ) AS B_FATREDE " 
	cQuery += " ON FONTE.RAIZ_CGC = B_FATREDE.ZF_CGCMAT " 
	cQuery += " ) AS FONTE2 " 
	cQuery += " WHERE FONTE2.PERCUT > 70 " 
	cQuery += " ORDER BY " 
	cQuery += " FONTE2.PERCUT DESC " 
	
	//
	RestArea(aArea)	
	
Return cQuery
/*/{Protheus.doc} grSV5 
	Gera aba sem venda + 5 dias.
	@type  Static Function
	@author Everson
	@since 31/05/2017
	@version 01
	/*/
Static Function grSV5(nHandle,cVendedor)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	:= GetArea()
	Local cHtml	:= ""
	Local cQuery:= ""
	Local nAux	:= 0
	
	cHtml := ""
	cHtml += " <div class='conteudo'> " 
	cHtml += " <h2 class='tituloAba'>Lista de clientes cadastrados - <span style='color: red;'>Sem vendas há mais de 5 dias</span></h2> " 
	cHtml += " <table class='tabConteudo'> " 
	cHtml += " <tr> " 
	cHtml += " <th>Cliente</th> " 
	cHtml += " <th>Rede</th> " 
	cHtml += " <th>Data de Cadastro</th> " 
	cHtml += " <th>Data Últ. Alteração</th> " 
	cHtml += " <th>Data Última Compra</th> " 
	cHtml += " <th>Dias</th> " 
	cHtml += " <th>Bloqueio</th> " 
	cHtml += " <th>Vendedor</th> " 
	cHtml += " <th>Supervisor</th> " 
	cHtml += " </tr> " 
	
	//
	FWrite(nHandle, cHtml)
	cHtml := ""
	
	//
	cQuery := scriptSV5(cVendedor)
	
	//
	If Select("D_VLR5") > 0
		D_VLR5->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "D_VLR5"
	DbSelectArea("D_VLR5")
	D_VLR5->(DbGoTop())
	
	While ! D_VLR5->(Eof())

		nAux++
		If (nAux%2) = 0
			cHtml += " <tr style='background-color: " + cCorLn + "'> "
		
		Else
			cHtml += " <tr> "
			
		EndIf
		 
		cHtml += " <td>" + Alltrim(cValToChar(D_VLR5->CLIENTE)) + "</td> " 
		cHtml += " <td>" + Alltrim(cValToChar(D_VLR5->ZF_REDE)) + "</td> " 
		cHtml += " <td align='right'>" + Alltrim(cValToChar(D_VLR5->A1_DTCAD)) + "</td> " 
		cHtml += " <td align='right'>" + Alltrim(cValToChar(D_VLR5->A1_DTREAT)) + "</td> " 
		cHtml += " <td align='right'>" + Alltrim(cValToChar(D_VLR5->E1_EMISSAO)) + "</td> " 
		cHtml += " <td align='right'>" + Alltrim(cValToChar(D_VLR5->DIAS)) + "</td> " 
		cHtml += " <td>" + Alltrim(cValToChar(D_VLR5->A1_MSBLQL)) + "</td> " 
		cHtml += " <td align='right'>" + Alltrim(cValToChar(D_VLR5->A1_VEND)) + "</td> " 
		cHtml += " <td align='right'>" + Alltrim(cValToChar(D_VLR5->A3_SUPER)) + "</td> " 
		cHtml += " </tr> " 	
		
		D_VLR5->(DbSkip())
		
		//
		FWrite(nHandle, cHtml)
		cHtml := ""	
		
	EndDo
	
	DbCloseArea("D_VLR5")
	
	//
	cHtml += " </table> " 
	cHtml += " </div> " 
	FWrite(nHandle, cHtml)
	cHtml := ""
		
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} scriptSV5 
	Script sql aba sem venda + 5 dias.
	@type  Static Function
	@author Everson
	@since 31/05/2017
	@version 01
	/*/
Static Function scriptSV5(cVendedor)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	:= GetArea()
	Local cQuery:= ""
	
	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " RTRIM(LTRIM(FONTE.A1_COD)) +'-'+ RTRIM(LTRIM(FONTE.A1_LOJA)) +'-'+ RTRIM(LTRIM(FONTE.A1_NOME)) AS CLIENTE, " 
	cQuery += " ISNULL(FONTE.ZF_REDE,'') AS ZF_REDE, " 
	cQuery += " CONVERT(VARCHAR(10),CAST(FONTE.A1_DTCAD AS DATE),103) AS A1_DTCAD, " 
	cQuery += " CASE WHEN A1_DTREAT = '' THEN '' ELSE CONVERT(VARCHAR(10),CAST(FONTE.A1_DTREAT AS DATE),103) END AS A1_DTREAT, " 
	cQuery += " FONTE.E1_EMISSAO, " 
	cQuery += " FONTE.DIAS, " 
	cQuery += " FONTE.A1_MSBLQL, " 
	cQuery += " FONTE.A1_VEND, " 
	cQuery += " FONTE.A3_SUPER " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " B_CLIENTE.A1_COD, " 
	cQuery += " B_CLIENTE.A1_LOJA, " 
	cQuery += " B_CLIENTE.A1_NOME, " 
	cQuery += " B_CLIENTE.RAIZ_CGC, " 
	cQuery += " B_CLIENTE.A1_DTCAD, " 
	cQuery += " B_CLIENTE.A1_DTREAT, " 
	cQuery += " CASE WHEN B_FATURAMENTO.E1_EMISSAO IS NULL THEN '' ELSE CONVERT(VARCHAR(10),CAST(B_FATURAMENTO.E1_EMISSAO AS DATE),103) END AS E1_EMISSAO, " 
	cQuery += " CASE WHEN B_FATURAMENTO.E1_EMISSAO IS NULL THEN   " 
	cQuery += " CASE WHEN A1_DTREAT <> '' THEN DATEDIFF(DAY,CAST(A1_DTREAT AS DATE),CAST(GETDATE() AS DATE)) ELSE DATEDIFF(DAY,CAST(A1_DTCAD AS DATE),CAST(GETDATE() AS DATE)) END " 
	cQuery += " ELSE " 
	cQuery += " DATEDIFF(DAY,CAST(B_FATURAMENTO.E1_EMISSAO AS DATE),CAST(GETDATE() AS DATE)) " 
	cQuery += " END AS DIAS, " 
	cQuery += " B_CLIENTE.A1_MSBLQL, " 
	cQuery += " B_CLIENTE.A1_VEND, " 
	cQuery += " B_REDE.ZF_REDE, " 
	cQuery += " B_CLIENTE.A3_SUPER " 
	cQuery += " FROM " 
	cQuery += " (     " 
	cQuery += " SELECT      " 
	cQuery += " A1_COD,      " 
	cQuery += " A1_LOJA,      " 
	cQuery += " A1_NOME,       " 
	cQuery += " LEFT(A1_CGC,8) AS RAIZ_CGC,      " 
	cQuery += " CASE WHEN A1_MSBLQL = '1' THEN 'Sim' ELSE 'Não' END AS A1_MSBLQL,     " 
	cQuery += " A1_DTCAD, " 
	cQuery += " A1_DTREAT, " 
	cQuery += " A1_VEND, " 
	cQuery += " A3_SUPER " 
	cQuery += " FROM      " 
	cQuery += " " + RetSqlName("SA1") + " (NOLOCK) AS SA1   " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SA3") + " (NOLOCK) AS SA3 " 
	cQuery += " ON A1_VEND = A3_COD   " 
	cQuery += " WHERE      " 
	cQuery += " SA1.D_E_L_E_T_='' " 
	cQuery += " AND SA3.D_E_L_E_T_=''    " 
	cQuery += " AND A1_DTCAD > '20130508'   " 
	cQuery += " AND A1_VEND = '" + Alltrim(cValToChar(cVendedor)) + "'  " 
	cQuery += " AND A1_MSBLQL = '2'  " 
	cQuery += " ) AS B_CLIENTE  " 
	cQuery += " LEFT OUTER JOIN     " 
	cQuery += " (     " 
	cQuery += " SELECT      " 
	cQuery += " E1_CLIENTE, E1_LOJA, MAX(E1_EMISSAO) AS E1_EMISSAO " 
	cQuery += " FROM      " 
	cQuery += " " + RetSqlName("SE1") + " (NOLOCK) AS SE1     " 
	cQuery += " WHERE      " 
	cQuery += " SE1.D_E_L_E_T_= ''      "  
	cQuery += " AND E1_EMISSAO > '20130508'      " 
	//cQuery += " AND YEAR(CAST (E1_EMISSAO AS DATE)) = YEAR(CAST(GETDATE() AS DATE)) "
	cQuery += " GROUP BY " 
	cQuery += " E1_CLIENTE,      " 
	cQuery += " E1_LOJA       " 
	cQuery += " ) AS B_FATURAMENTO " 
	cQuery += " ON B_CLIENTE.A1_COD = B_FATURAMENTO.E1_CLIENTE     " 
	cQuery += " AND B_CLIENTE.A1_LOJA = B_FATURAMENTO.E1_LOJA " 
	cQuery += " LEFT OUTER JOIN    " 
	cQuery += " (     " 
	cQuery += " SELECT      " 
	cQuery += " ZF_CGCMAT, ZF_REDE, SUM(ZF_LCREDE) AS ZF_LCREDE     " 
	cQuery += " FROM      " 
	cQuery += " " + RetSqlName("SZF") + " (NOLOCK) SZF     " 
	cQuery += " WHERE      " 
	cQuery += " SZF.D_E_L_E_T_=''     " 
	cQuery += " GROUP BY     " 
	cQuery += " ZF_CGCMAT, ZF_REDE     " 
	cQuery += " ) AS B_REDE   " 
	cQuery += " ON B_CLIENTE.RAIZ_CGC =  B_REDE.ZF_CGCMAT " 
	cQuery += " ) AS FONTE " 
	cQuery += " WHERE FONTE.DIAS > 5     " 
	cQuery += " ORDER BY FONTE.DIAS DESC  " 
	
	//
	RestArea(aArea)
	
Return cQuery
/*/{Protheus.doc} html1 
	Template do relatório. 
	@type  Static Function
	@author Everson
	@since 31/05/2017
	@version 01
	/*/
Static Function html1()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea := GetArea()
	Local cHtml	:= ""
	
	cHtml := ""
	cHtml += " <html> " 
	cHtml += " <head> " 
	cHtml += " </head> " 
	//
	RestArea(aArea)
	
Return cHtml
/*/{Protheus.doc} html2 
	Template do relatório. 
	@type  Static Function
	@author Everson
	@since 31/05/2017
	@version 01
	/*/
Static Function html2(cVendedor,cEmailVd,cFullName)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea := GetArea()
	Local cHtml	:= ""
	
	cHtml := ""
	cHtml += " <body> " 
	cHtml += " <h2 style='margin-bottom: 5px; color:#28377c'>Relatório - Posição de Carteira</h2> " 
	cHtml += " <hr> "
	cHtml += " <p style='margin: 0'>Gerado em: " + DToC(Date()) + "-" + cValToChar(Time()) + "</p> " 
	cHtml += " <p style='margin: 0'>Vendedor: "  + Alltrim(cValToChar(cVendedor)) + "-" + Alltrim(cValToChar(Posicione("SA3",1,xFilial("SA3") + Alltrim(cValToChar(cVendedor)),"A3_NOME"))) + "</p> " //Everson - 30/08/2017. Chamado 036933.
	cHtml += " <p style='margin: 0'>E-mail: "    + Alltrim(cValToChar(cEmailVd))    + "</p> " 
	cHtml += " <div class='TabControl'> " 
	cHtml += " <div id='header'> " 
	cHtml += " <ul class='abas'> " 
	cHtml += " <li> " 
	cHtml += " <div class='aba'> " 
	cHtml += " <span>Resumo</span> " 
	cHtml += " </div> " 
	cHtml += " </li> " 
	cHtml += " <li> " 
	cHtml += " <div class='aba'> " 
	cHtml += " <span>Lim. Redes</span> " 
	cHtml += " </div> " 
	cHtml += " </li> " 
	cHtml += " <li> " 
	cHtml += " <div class='aba'> " 
	cHtml += " <span>Lim. Clientes</span> " 
	cHtml += " </div> " 
	cHtml += " </li> " 
	cHtml += " <li> " 
	cHtml += " <div class='aba'> " 
	cHtml += " <span>Vlr.  Aberto</span> " 
	cHtml += " </div> " 
	cHtml += " </li> " 
	cHtml += " <li> " 
	cHtml += " <div class='aba'> " 
	cHtml += " <span>Últ. Compra</span> " 
	cHtml += " </div> " 
	cHtml += " </li> " 
	cHtml += " <li> " 
	cHtml += " <div class='aba'> " 
	cHtml += " <span>Lim. + 70%</span> " 
	cHtml += " </div> " 
	cHtml += " </li> " 
	cHtml += " <li> " 
	cHtml += " <div class='aba'> " 
	cHtml += " <span>Sem Vendas + 5 Dias</span> " 
	cHtml += " </div> " 
	cHtml += " </li> " 
	cHtml += " </ul> " 
	cHtml += " </div> " 
	
	//
	RestArea(aArea)
	
Return cHtml
/*/{Protheus.doc} html3 
	Template do relatório. 
	@type  Static Function
	@author Everson
	@since 31/05/2017
	@version 01
	/*/
Static Function html3()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	:= GetArea()
	Local cHtml	:= ""
	Local i		:= 1
		
	cHtml := ""
	cHtml += " </div> " 
	cHtml += " </div> " 
	cHtml += ' <script type="text/javascript"> '
	cHtml += " $(document).ready(function(){ " 
	
	//
	For i := 1 To nIdBtn
	
		cHtml += " $('#btn" + Alltrim(cValToChar(i)) +"').click(function() { "
		
		cHtml += " $('#tabLR" + Alltrim(cValToChar(i)) +"').toggle()"
			
	    cHtml += " }); "
	
	Next i
	
	cHtml += ' $("#content div:nth-child(1)").show(); ' 
	cHtml += ' $(".abas li:first div").addClass("selected"); '
	cHtml += ' $(".aba").click(function(){ '
	cHtml += ' $(".aba").removeClass("selected"); '
	cHtml += ' $(this).addClass("selected"); '
	cHtml += " var indice = $(this).parent().index(); " 
	cHtml += " indice++; " 
	cHtml += ' $("#content div").hide(); ' 
	cHtml += ' $("#content div:nth-child("+indice+")").show(); '
	cHtml += " }); " 
	cHtml += " }); " 
	cHtml += " </script> " 
	cHtml += " </body> " 
	cHtml += " </html> " 
	
	//
	RestArea(aArea)
	
Return cHtml
/*/{Protheus.doc} enviarEmail 
	Envia e-mail. 
	@type  Static Function
	@author Everson
	@since 31/05/2017
	@version 01
	/*/
Static Function enviarEmail(cAssunto,cMensagem,cEmailVd,cAtach)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea			:= GetArea()
	Local lOk           := .T.
	Local cBody         := cMensagem
	Local cErrorMsg     := ""
	Local aFiles        := {}
	Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
	Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
	Local cFrom         := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
	Local cTo           := cEmailVd
	Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)
	Local lAutOk        := .F.  
	Local cSubject      := ""
	
	//Assunto do e-mail.
	 cSubject := cAssunto
	 
	 //Conecta ao servidor SMTP.
	 Connect Smtp Server cServer Account cAccount  Password cPassword Result lOk
	 
	 If !lAutOk
	    If ( lSmtpAuth )
	       lAutOk := MailAuth(cAccount,cPassword)
	       
	    Else
	       lAutOk := .T.
	       
	    EndIf
	    
	 EndIf
	 
	 If lOk .And. lAutOk   
	    
	    //Envia o e-mail.     
	    Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk  
	     
	    //Tratamento de erro no envio do e-mail.          
	    If !lOk
	       Get Mail Error cErrorMsg
	       ConOut("Não foi possível enviar o e-mail ao comprador. 3 - " + cErrorMsg)
	       
	    EndIf
	    
	 Else
	    Get Mail Error cErrorMsg
	    ConOut("Não foi possível enviar o e-mail ao comprador. 4 - " + cErrorMsg)
	    
	 EndIf
	 
	 If lOk
	    Disconnect Smtp Server
	    
	 EndIf
	 
	 //
	 RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} logZBN 
	Gera log na ZBN.
	@type  Static Function
	@author Everson
	@since 31/05/2017
	@version 01
	/*/
Static Function logZBN(cStatus)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADFIN031R'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADFIN031R'
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADFIN031R'
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return Nil