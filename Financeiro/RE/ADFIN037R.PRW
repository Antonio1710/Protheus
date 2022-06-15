#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include 'AP5mail.ch'
#Include "Restful.ch"

/*/{Protheus.doc} User Function ADFIN037R
	Relatório de faturamento. Chamado 035788.
	@type  Function
	@author Everson
	@since 05/07/2017
	@version 01
	@history Everson 09/01/2019 Chamdado 046278. Adicionado gráficos ao relatório.  
	@history Everson 31/01/2019 Chamdado TI. correção dos totalizadores por empresa.                                                               
	@history Adriana 24/05/2019 TI-Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM    
	@history Everson 29/05/2020 Chamado 058402. Adicionado empresa 09 Safeeg ao relatório.
	@history Everson 30/07/2020 Chamado 059705. Adicionado valor acumulado da semana.
	@history Everson 16/09/2020 Chamado 1702. Alterada a lógica da data das devoluções.
	@history Everson 29/09/2020 Chamado 2470. Adicionada a filial 01 da empresa 01.
	@history Everson 06/05/2020 Chamado 12436. Alterada a periodicidade do gráfico Ticket Médio x Prazo Médio (Ad'oro) de diários para mensal.
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
*/
User Function ADFIN037R() // U_ADFIN037R()

	//Variáveis.	
	Local cEmp 	:= "01"
	Local cFil 	:= "02"

	//Inicia o ambiente.
	If !IsInCallStack('U_ADFIN030P')

		RPCClearEnv()
		RPCSetType(3)
		RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })		

		// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 29/06/2020
		If !LockByName("ADFIN037R", .T., .F.)
			ConOut("[ADFIN037R] - Existe outro processamento sendo executado! Verifique...")
			RPCClearEnv()
			Return
		EndIf

	EndIf

	//	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	//FWMonitorMsg(ALLTRIM(PROCNAME()))

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatório de faturamento.')
	logZBN("1") //Log início.

	//
	Conout("ADFIN037R - Início da geração do relatório de faturamento grupo Adoro")
	gerRel()
	Conout("ADFIN037R - Fim da geração do relatório de faturamento grupo Adoro")

	logZBN("2") //Log fim.

	//Fecha o ambiente.
	If ! IsInCallStack('U_ADFIN030P')

		RpcClearEnv()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Destrava a rotina para o usuário	    ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		UnLockByName("ADLOG022P")

	EndIf

Return Nil
/*/{Protheus.doc} gerRel
	Template Html.
	@type  Static Function
	@author Everson
	@since 05/07/2017
	@version 01
	/*/
Static Function gerRel()

	//Variáveis.	
	Local aArea			:= GetArea()
	Local oTab1 		:= Nil
	Local oTab2 		:= Nil
	Local oTab3 		:= Nil
	Local oTab4 		:= Nil
	Local oTab5			:= Nil
	Local cHtml			:= ""		
	Local nUltAno 		:= 0
	Local nAnoAtu		:= 0
	Local aAnos			:= {}
	Local i				:= 1	
	Local aEmpresa	 	:= {"01","02","07","09"} //Everson 09/01/2019. Chamado 046278. //Everson - 29/05/2020. Chamado 058402.
	Local aNmEmpresas 	:= {"Ad'oro","Ceres","RNX2","Safegg"} //Everson - 29/05/2020. Chamado 058402.
	Local cEmail		:= GetMv("MV_#RELFAT")
	Local cMsg			:= "Segue relatório anexo Faturamento Grupo Ad'oro"
	Local cArq			:= "\rel_fin\rel_faturamento.html"
	Local cDGrf1		:= ""
	Local cDGrf2_1		:= ""
	Local cDGrf2_2		:= ""
	Local cDGrf2_3		:= ""
	Local cDGrf3_1		:= ""
	Local cDGrf3_2		:= ""
	Local cDGrf3_3		:= ""
	Local cDGrf3_4		:= ""
	Local cDGrf4_1		:= ""
	Local cDGrf4_2		:= ""
	Local cDGrf4_3		:= ""
	Local cDGrf5_1		:= ""
	Local cDGrf5_2		:= ""
	Local cDGrf5_3		:= ""
	Local cDGrf6_1		:= ""
	Local cDGrf6_2		:= ""
	Local cDGrf6_3		:= ""
	Local nDiasRet		:= GetMv("MV_#NUMDIA",,0) //Everson 09/01/2019 chamdado 046278.

	//
	Private lAnoAnt		:= Iif( ( Month(Date()) == 1 .And. Day(Date()) <=  nDiasRet) ,.T.,.F.)
	Private dDateAnt	:= Nil

	//Caso o arquivo já existir, o mesmo é pagado.
	FErase(cArq)

	//Valida se há e-mail cadastrado para envio do relatório.
	cEmail := Alltrim(cValToChar(cEmail))
	If Empty(cEmail)
		conout("Não há e-mail cadastrado no parâmetro da rotina ADFIN037R.")
		RestArea(aArea)
		Return Nil

	EndIf

	//Preenche o array com os anos base do relatório.
	If lAnoAnt
		nUltAno	 := Year(Date()) - 6
		nAnoAtu	 := Year(Date()) - 1
		dDateAnt := SToD( cValToChar(nAnoAtu) + "1231" )

	Else
		nUltAno	:= Year(Date()) - 5
		nAnoAtu	:= Year(Date())
		dDateAnt:= Date()

	EndIf

	For i := nUltAno To nAnoAtu		
		Aadd(aAnos,{i})

	Next i	

	cHtml += " <!DOCTYPE html> " 
	cHtml += " <html> "

	//Cria cabeçalho html
	cabecalho(@cHtml)

	//
	cHtml += " <body> "

	//Cria abas do relatório.
	criaAbas(@cHtml) 

	//Início d preenchimento das abas.
	cHtml += ' <div id="content"> ' 
	
	//Everson 22/01/2019 chamdado 046278
	//Cria arquivos temporários.
	oTab1 := arqTemp1(aEmpresa)
	oTab2 := arqTemp2(aAnos,aEmpresa)
	oTab3 := arqTemp3(aAnos,aEmpresa)
	oTab4 := arqTemp4(aAnos,aEmpresa)
	oTab5 := arqTemp5(aAnos,aEmpresa)

	//Aba 1 - Gráficos.
	aba1(@cHtml) // >>> Não alterar a posição da aba dos gráficos, pois, para exibi-los, ocorre o recarregamento da página  <<<

	//Aba 2 - Evolução do Faturamento Líquido do Grupo.
	aba2(@cHtml,aAnos,aEmpresa,aNmEmpresas,@cDGrf1,@cDGrf2_1,@cDGrf2_2,@cDGrf2_3)

	//Aba 3 - Faturamento Líquido por Grupo.
	aba3(@cHtml)

	//Aba 4 - Faturamento Mensal. 
	aba4(@cHtml,aAnos,@cDGrf3_1,@cDGrf3_2,@cDGrf3_3,@cDGrf3_4,@cDGrf4_1,@cDGrf4_2,@cDGrf4_3)

	//Aba 4 - Faturamento Diário.
	aba5(@cHtml,aAnos,aEmpresa,aNmEmpresas,@cDGrf4_1,@cDGrf4_2,@cDGrf4_3,@cDGrf5_1,@cDGrf5_2,@cDGrf5_3,@cDGrf6_1,@cDGrf6_2,@cDGrf6_3)

	cHtml += " </div> "

	cHtml += ' <script type="text/javascript"> '
	cHtml += ' $(document).ready(function(){ '
	cHtml += ' $("#content div:nth-child(1)").show(); '
	cHtml += ' $(".abas li:first div").addClass("selected"); '		
	cHtml += ' $(".aba").click(function(){ '
	cHtml += ' $(".aba").removeClass("selected"); '
	cHtml += ' $(this).addClass("selected"); '
	cHtml += ' var indice = $(this).parent().index(); '
	cHtml += ' indice++; '
	cHtml += ' $("#content div").hide(); '
	cHtml += ' $("#content div:nth-child("+indice+")").show(); '
	cHtml += ' if(indice === 1){ '
	cHtml += ' location.reload(); '
	cHtml += ' } '
	cHtml += ' }); '				
	cHtml += ' }); '
	cHtml += " </script> "

	//Script para criação de gráficos.
	carGrafico(@cHtml,cDGrf1,cDGrf2_1,cDGrf2_2,cDGrf2_3,cDGrf4_1,cDGrf4_2,cDGrf4_3,cDGrf5_1,cDGrf5_2,cDGrf5_3,cDGrf6_1,cDGrf6_2,cDGrf6_3,cDGrf3_1,cDGrf3_2,cDGrf3_3,cDGrf3_4)

	cHtml += " </body> " 

	cHtml += " </html> " 

	//
	cHtml := StrTran(cHtml,Chr(129),"")
	cHtml := StrTran(cHtml,Chr(141),"")
	cHtml := StrTran(cHtml,Chr(143),"")
	cHtml := StrTran(cHtml,Chr(144),"")
	cHtml := StrTran(cHtml,Chr(157),"")
	memowrite(cArq,EncodeUtf8(cHtml))
	//memowrite(cArq,cHtml)

	//Envia e-mail.
	//cEmail := "everson.silva@adoro.com.br"
	envEmail("Faturamento Grupo Ad'oro",cMsg,cEmail,cArq)

	//
	//FErase(cArq)

	//
	oTab1:Delete()
	oTab2:Delete()
	oTab3:Delete()
	oTab4:Delete()
	oTab5:Delete()

	//
	RestArea(aArea)

Return cHtml
/*/{Protheus.doc} cabecalho
	Cabeçalho html.
	@type  Static Function
	@author Everson
	@since 09/01/2019
	@version 01
	/*/
Static Function cabecalho(cHtml)

	//Variáveis.		
	Local aArea		:= GetArea()
	Local cJquery	:= "\rel_fin\jquery\jquery3.txt"
	Local cD3js		:= "\rel_fin\chart\d3.txt"
	Local cBillB	:= "\rel_fin\chart\billboard.txt"
	Local cBillBC	:= "\rel_fin\chart\billboardcss.txt"

	// 
	cHtml += " <head> " 
	cHtml += " <meta charset='UTF-8'> " 
	cHtml += " <style> " 
	cHtml += " body{font-family:Calibri, Tahoma, Arial} " 
	cHtml += " .TabControl{ width:100%; height:100%} " 
	cHtml += " .TabControl #header{ width:100%; border: 0; overflow:hidden; cursor:hand} " 
	cHtml += " .TabControl #content{ width:100%; border: solid 1px 1px 0 1px;overflow:hidden; height:100%; } " 
	cHtml += " .TabControl .abas{display:inline;} " 
	cHtml += " .TabControl .abas li{float:left} " 
	cHtml += " .aba{width:250px; height:50px; border:solid 1px; border-radius:0 10px 0 0; text-align:center;padding-top:5px;background:#ffb236; color:#fff; font-weight: bold;} " 
	cHtml += " .ativa{width:100px; height:30px; border:solid 1 px; border-radius:0 10px 0 0; text-align:center;padding-top:5px; background:#96191d;} " 
	cHtml += " .ativa span, .selected span{color:#fff} " 
	cHtml += " .TabControl #content{background:#96191d} " 
	cHtml += " .TabControl .conteudo{width:100%;  background:#ededed; display:none; height:100%;color:black;overflow:scroll;} " 
	cHtml += " .selected{width:250px; height:50px; border:solid 1 px; border-radius:0 10px 0 0;text-align:center; padding-top:5px; background:#96191d} "
	cHtml += " .tabelaTab1{ " 
	cHtml += " margin-top: 10px; " 
	cHtml += " width: 100%; " 
	cHtml += " height: 95% " 
	cHtml += " } " 
	cHtml += " .tabelaTab2{ " 
	cHtml += " margin: 0 auto; " 
	cHtml += " margin-top: 10px; " 
	cHtml += " width: 80%; " 
	cHtml += " height: 95% " 
	cHtml += " } " 
	cHtml += " .tabelaTab3{ " 
	cHtml += " margin: 0 auto; " 
	cHtml += " margin-top: 10px; " 
	cHtml += " width: 85%; " 
	cHtml += " height: 95% " 
	cHtml += " } "
	cHtml += " P{ " 
	cHtml += " margin: 0; " 
	cHtml += " } " 
	cHtml += " hr{margin: 0} "
	cHtml += " button{ margin: 5px; background-color:#28377c; color:white;} "
	cHtml += " .grid-container { "
	cHtml += " display: grid; padding:10px; background-color:white; grid-template-columns: 40% 60%; "
	cHtml += " } "
	cHtml += " </style> " 
	
	//Carrega biblioteca javascrit JQuery.
	If ! File(cJquery)
		cHtml += ' <script type="text/javascript" src="http://code.jquery.com/jquery-1.7.2.min.js"></script> ' 

	Else

		//
		nHdl := FOpen(cJquery, 32)

		//Valida abertura do arquivo.
		If nHdl < 0
			cHtml += ' <script type="text/javascript" src="http://code.jquery.com/jquery-1.7.2.min.js"></script> ' 

		Else

			cHtml += "<script type='text/javascript'>" + Chr(13) + Chr(10)
			
			carArq(@cHtml,@nHdl,cJquery)
				
			cHtml += " </script> " + Chr(13) + Chr(10)

		Endif

	Endif

	//Carrega d3js.
	If ! File(cD3js)
		cHtml += ' <script src="https://d3js.org/d3.v5.min.js"></script> '

	Else

		//
		nHdl := FOpen(cD3js, 32)

		//Valida abertura do arquivo.
		If nHdl < 0
			cHtml += ' <script src="https://d3js.org/d3.v5.min.js"></script> '

		Else

			cHtml += "<script type='text/javascript'>" + Chr(13) + Chr(10)

			carArq(@cHtml,@nHdl,cD3js)
			
			cHtml += " </script> " + Chr(13) + Chr(10)

		Endif

	EndIf

	//Carrega biblioteca javascrit para criação de gráficos.
	If ! File(cBillB)
		cHtml += ' <script src="https://naver.github.io/billboard.js/release/latest/dist/billboard.min.js"></script> '

	Else

		//
		nHdl := FOpen(cBillB, 32)

		//Valida abertura do arquivo.
		If nHdl < 0
			cHtml += ' <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.3/Chart.bundle.min.js"></script> ' 

		Else

			cHtml += "<script type='text/javascript'>" + Chr(13) + Chr(10)

			carArq(@cHtml,@nHdl,cBillB)
			
			cHtml += " </script> " + Chr(13) + Chr(10)

		Endif	

	EndIf
	
	//Carrega css da biblioteca javascrit para criação de gráficos.
	If ! File(cBillBC)
		cHtml += ' <link rel="stylesheet" href="https://naver.github.io/billboard.js/release/latest/dist/billboard.min.css"> '	

	Else

		//
		nHdl := FOpen(cBillBC, 32)

		//Valida abertura do arquivo.
		If nHdl< 0
			cHtml += ' <link rel="stylesheet" href="https://naver.github.io/billboard.js/release/latest/dist/billboard.min.css"> '

		Else

			cHtml += " <style> " + Chr(13) + Chr(10)
			
			carArq(@cHtml,@nHdl,cBillBC)
			
			cHtml += " </style> " + Chr(13) + Chr(10)

		Endif	

	EndIf

	cHtml += " </head> " 

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} criaAbas
	Cria abas do relatório. 
	@type  Static Function
	@author Everson
	@since 09/01/2019
	@version 01
	/*/	
Static Function criaAbas(cHtml)

	//Variáveis.	
	Local aArea	 := GetArea()

	//
	cHtml += " <h2 style='color:#28377c;margin:0px;'>Relatório de Faturamento</h2> "
	cHtml += " <hr> "
	cHtml += " <p>ADFIN037R</p> "  
	cHtml += " <p>Emitido em: " + DToC(Date()) + " - " + cValToChar(Time()) + "</p> " 
	cHtml += " <br/> " 
	cHtml += ' <div class="TabControl"> ' 
	cHtml += ' <div id="header"> ' 
	cHtml += ' <ul class="abas"> ' 
	cHtml += " <li> " 
	cHtml += ' <div class="aba"> ' 
	cHtml += " <span>Gráficos</span> "  
	cHtml += " </div> " 
	cHtml += " </li> " 
	cHtml += " <li> " 
	cHtml += ' <div class="aba"> ' 
	cHtml += " <span>Evolução do Faturamento Líquido do Grupo</span> "  
	cHtml += " </div> " 
	cHtml += " </li> " 
	cHtml += " <li> " 
	cHtml += ' <div class="aba"> ' 
	cHtml += " <span>Faturamento Líquido por Grupo</span> "
	cHtml += " </div> " 
	cHtml += " </li> " 
	cHtml += " <li> " 
	cHtml += ' <div class="aba"> ' 
	cHtml += " <span>Faturamento Semanal</span> " 
	cHtml += " </div> " 
	cHtml += " </li> " 
	cHtml += " <li> " 
	cHtml += ' <div class="aba"> ' 
	cHtml += " <span>Faturamento Diário</span> " 
	cHtml += " </div> " 
	cHtml += " </li> " 
	cHtml += " </ul> " 
	cHtml += " </div> " 

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} arqTemp1
	Arquivo temporário 1. 
	@type  Static Function
	@author Everson
	@since 09/01/2019
	@version 01
	/*/	
Static Function arqTemp1(aEmpresa)

	//Variáveis.		
	Local aArea		:= GetArea()
	Local oTab1		:= Nil
	Local aStru		:= {}
	Local cQuery	:= ""
	Local cQueryT	:= ""
	Local i			:= 1
	Local cHrIni	:= Time()

	//-------------------
	//Criação do objeto
	//-------------------
	oTab1 := FWTemporaryTable():New("TEMP")

	//Cria arquivo temporário.
	Aadd(aStru,{"TM_EMPRESA", "C",02,0})
	Aadd(aStru,{"TM_FILIAL" , "C",02,0})	
	Aadd(aStru,{"TM_1"		, "N",15,4})
	Aadd(aStru,{"TM_2"		, "N",15,4})
	Aadd(aStru,{"TM_3"		, "N",15,4})
	Aadd(aStru,{"TM_4"		, "N",15,4})
	Aadd(aStru,{"TM_5"		, "N",15,4})
	Aadd(aStru,{"TM_6"		, "N",15,4})
	Aadd(aStru,{"TM_7"		, "N",15,4})
	Aadd(aStru,{"TM_8"		, "N",15,4})
	Aadd(aStru,{"TM_9"		, "N",15,4})
	Aadd(aStru,{"TM_10"		, "N",15,4})
	Aadd(aStru,{"TM_11"		, "N",15,4})
	Aadd(aStru,{"TM_12"		, "N",15,4})
	Aadd(aStru,{"TM_T"		, "N",15,4})

	Aadd(aStru,{"TMD_1"		, "N",15,4})
	Aadd(aStru,{"TMD_2"		, "N",15,4})
	Aadd(aStru,{"TMD_3"		, "N",15,4})
	Aadd(aStru,{"TMD_4"		, "N",15,4})
	Aadd(aStru,{"TMD_5"		, "N",15,4})
	Aadd(aStru,{"TMD_6"		, "N",15,4})
	Aadd(aStru,{"TMD_7"		, "N",15,4})
	Aadd(aStru,{"TMD_8"		, "N",15,4})
	Aadd(aStru,{"TMD_9"		, "N",15,4})
	Aadd(aStru,{"TMD_10"	, "N",15,4})
	Aadd(aStru,{"TMD_11"	, "N",15,4})
	Aadd(aStru,{"TMD_12"	, "N",15,4})
	Aadd(aStru,{"TMD_T"		, "N",15,4})

	Aadd(aStru,{"TMI_1"		, "N",15,4})
	Aadd(aStru,{"TMI_2"		, "N",15,4})
	Aadd(aStru,{"TMI_3"		, "N",15,4})
	Aadd(aStru,{"TMI_4"		, "N",15,4})
	Aadd(aStru,{"TMI_5"		, "N",15,4})
	Aadd(aStru,{"TMI_6"		, "N",15,4})
	Aadd(aStru,{"TMI_7"		, "N",15,4})
	Aadd(aStru,{"TMI_8"		, "N",15,4})
	Aadd(aStru,{"TMI_9"		, "N",15,4})
	Aadd(aStru,{"TMI_10"	, "N",15,4})
	Aadd(aStru,{"TMI_11"	, "N",15,4})
	Aadd(aStru,{"TMI_12"	, "N",15,4})
	Aadd(aStru,{"TMI_T"		, "N",15,4})

	//Configura campos e índices.
	oTab1:SetFields(aStru)
	oTab1:AddIndex("indice1", {"TM_EMPRESA","TM_FILIAL"} )

	//------------------
	//Criação da tabela
	//------------------
	oTab1:Create()

	//Obtém dados da empresas.
	For i := 1 To Len(aEmpresa)

		//
		cQuery := ""
		cQuery += scriptFatLiq(aEmpresa[i])
		cQuery += " ORDER BY FILIAL, MES " 

		//
		carArq1_1(cQuery,aEmpresa,i)

		//
		cQueryT := ""
		cQueryT += " SELECT "
		cQueryT += " TOTALIZADOR.MES, SUM(TOTALIZADOR.VENDAS) AS VENDAS, " 
		cQueryT += " SUM(TOTALIZADOR.DEV) AS DEV, SUM(TOTALIZADOR.INTERCIA) AS INTERCIA, "
		cQueryT += " SUM(TOTALIZADOR.FAT_LIQ) AS FAT_LIQ "
		cQueryT += " FROM "
		cQueryT += " ( "
		cQueryT += scriptFatLiq(aEmpresa[i])
		cQueryT += " ) AS TOTALIZADOR "
		cQueryT += " GROUP BY TOTALIZADOR.MES "

		//
		carArq1_2(cQueryT,aEmpresa)

	Next i

	//
	cQuery := ""
	cQuery += rn_scriptFatLiq()
	cQuery += " ORDER BY FILIAL, MES " 

	//
	carArq1_1(cQuery,aEmpresa,3)

	//Dados anteriores da RNX2.
	cQueryT := ""	
	cQueryT += " SELECT "
	cQueryT += " TOTALIZADOR.MES, SUM(TOTALIZADOR.VENDAS) AS VENDAS, " 
	cQueryT += " SUM(TOTALIZADOR.DEV) AS DEV, SUM(TOTALIZADOR.INTERCIA) AS INTERCIA, "
	cQueryT += " SUM(TOTALIZADOR.FAT_LIQ) AS FAT_LIQ "
	cQueryT += " FROM "
	cQueryT += " ( "	
	cQueryT += rn_scriptFatLiq()	
	cQueryT += " ) AS TOTALIZADOR "
	cQueryT += " GROUP BY TOTALIZADOR.MES "

	//
	carArq1_2(cQueryT,aEmpresa)

	//
	Conout("ADVFIN037R - Criado arquivo temporário 1 " + ElapTime ( cHrIni , Time() ) )

	//
	RestArea(aArea)

Return oTab1
/*/{Protheus.doc} carArq1_1
	Carga de arquivo temporário. 
	@type  Static Function
	@author Everson
	@since 09/01/2019
	@version 01
	/*/
Static Function carArq1_1(cQuery,aEmpresa,i)

	//Variáveis.		
	Local aArea		:= GetArea()

	//
	If Select("D_VENDAS") > 0
		D_VENDAS->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_VENDAS"
	//MPSysOpenQuery( cQuery, 'D_VENDAS' )
	DbSelectArea('D_VENDAS')
	D_VENDAS->(DbGoTop())
	While ! D_VENDAS->(Eof())

		DbSelectArea("TEMP")
		TEMP->(DbGoTop())

		//
		If TEMP->( DbSeek( Alltrim(cValToChar(aEmpresa[i])) + Alltrim(cValToChar(D_VENDAS->FILIAL)) ) )

			RecLock("TEMP",.F.)
			&("TEMP->TM_"  + Alltrim(cValToChar(D_VENDAS->MES)) + " += " + cValToChar(D_VENDAS->VENDAS))
			&("TEMP->TMD_" + Alltrim(cValToChar(D_VENDAS->MES)) + " += " + cValToChar(D_VENDAS->DEV))
			&("TEMP->TMI_" + Alltrim(cValToChar(D_VENDAS->MES)) + " += " + cValToChar(D_VENDAS->INTERCIA))
			TEMP->TM_T  += Val(cValToChar(D_VENDAS->VENDAS))
			TEMP->TMD_T += Val(cValToChar(D_VENDAS->DEV))
			TEMP->TMI_T += Val(cValToChar(D_VENDAS->INTERCIA))
			MsUnlock()

		Else

			RecLock("TEMP",.T.)
			TEMP->TM_EMPRESA := Alltrim(cValToChar(aEmpresa[i]))
			TEMP->TM_FILIAL  := Alltrim(cValToChar(D_VENDAS->FILIAL))
			&("TEMP->TM_"  + Alltrim(cValToChar(D_VENDAS->MES)) + " := " + cValToChar(D_VENDAS->VENDAS))
			&("TEMP->TMD_" + Alltrim(cValToChar(D_VENDAS->MES)) + " := " + cValToChar(D_VENDAS->DEV))
			&("TEMP->TMI_" + Alltrim(cValToChar(D_VENDAS->MES)) + " := " + cValToChar(D_VENDAS->INTERCIA))
			TEMP->TM_T  := Val(cValToChar(D_VENDAS->VENDAS))
			TEMP->TMD_T := Val(cValToChar(D_VENDAS->DEV))
			TEMP->TMI_T := Val(cValToChar(D_VENDAS->INTERCIA))
			MsUnlock()			

		EndIf

		D_VENDAS->(DbSkip())

	EndDo

	//
	D_VENDAS->(DbCloseArea())

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} carArq1_2
	Carga de arquivo temporário. 
	@type  Static Function
	@author Everson
	@since 09/01/2019
	@version 01
	/*/
Static Function carArq1_2(cQueryT,aEmpresa)

	//Variáveis.		
	Local aArea		:= GetArea()		

	//
	If Select("D_TOTAIS") > 0
		D_TOTAIS->(DbCloseArea())

	EndIf

	//
	TcQuery cQueryT New Alias "D_TOTAIS"
	//MPSysOpenQuery( cQueryT, 'D_TOTAIS' )
	DbSelectArea('D_TOTAIS')
	D_TOTAIS->(DbGoTop())
	While ! D_TOTAIS->(Eof())

		DbSelectArea("TEMP")
		TEMP->(DbGoTop())

		//			
		If TEMP->( DbSeek(  "TT" + "TT" ) )

			RecLock("TEMP",.F.)
			&("TEMP->TM_"  + Alltrim(cValToChar(D_TOTAIS->MES))  + " += " + cValToChar(D_TOTAIS->VENDAS))
			&("TEMP->TMD_"  + Alltrim(cValToChar(D_TOTAIS->MES)) + " += " + cValToChar(D_TOTAIS->DEV))
			&("TEMP->TMI_"  + Alltrim(cValToChar(D_TOTAIS->MES)) + " += " + cValToChar(D_TOTAIS->INTERCIA))
			TEMP->TM_T  += Val(cValToChar(D_TOTAIS->VENDAS))
			TEMP->TMD_T += Val(cValToChar(D_TOTAIS->DEV))
			TEMP->TMI_T += Val(cValToChar(D_TOTAIS->INTERCIA))
			MsUnlock()

		Else

			RecLock("TEMP",.T.)
			TEMP->TM_EMPRESA := "TT"
			TEMP->TM_FILIAL  := "TT"
			&("TEMP->TM_"  + Alltrim(cValToChar(D_TOTAIS->MES))  + " := " + cValToChar(D_TOTAIS->VENDAS))
			&("TEMP->TMD_"  + Alltrim(cValToChar(D_TOTAIS->MES)) + " := " + cValToChar(D_TOTAIS->DEV))
			&("TEMP->TMI_"  + Alltrim(cValToChar(D_TOTAIS->MES)) + " := " + cValToChar(D_TOTAIS->INTERCIA))
			TEMP->TM_T  := Val(cValToChar(D_TOTAIS->VENDAS))
			TEMP->TMD_T := Val(cValToChar(D_TOTAIS->DEV))
			TEMP->TMI_T := Val(cValToChar(D_TOTAIS->INTERCIA))
			MsUnlock()			

		EndIf

		D_TOTAIS->(DbSkip())

	EndDo

	//Carrega faturamento líquido.
	D_TOTAIS->(DbGoTop())
	While ! D_TOTAIS->(Eof())

		DbSelectArea("TEMP")
		TEMP->(DbGoTop())

		//
		If TEMP->(DbSeek("FL" + "FL"))

			RecLock("TEMP",.F.)
			&("TEMP->TM_" + Alltrim(cValToChar(D_TOTAIS->MES)) +  " +=  " + cValToChar(D_TOTAIS->FAT_LIQ))
			TEMP->TM_T += Val(cValToChar(D_TOTAIS->FAT_LIQ))
			MsUnlock()

		Else

			RecLock("TEMP",.T.)
			TEMP->TM_EMPRESA := "FL"
			TEMP->TM_FILIAL  := "FL"
			&("TEMP->TM_" + Alltrim(cValToChar(D_TOTAIS->MES)) +  " :=  " + cValToChar(D_TOTAIS->FAT_LIQ))
			TEMP->TM_T := Val(cValToChar(D_TOTAIS->FAT_LIQ))
			MsUnlock()			

		EndIf

		D_TOTAIS->(DbSkip())

	EndDo

	//
	D_TOTAIS->(DbCloseArea())

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} arqTemp2
	Arquivo temporário 2. 
	@type  Static Function
	@author Everson
	@since 09/01/2019
	@version 01
	/*/
Static Function arqTemp2(aAnos,aEmpresa)

	//Variáveis.		
	Local aArea		:= GetArea()
	Local oTab2		:= Nil
	Local aStru		:= {}
	Local i			:= 1
	Local w			:= 1
	Local cQuery	:= ""
	Local cHrIni	:= Time()

	//-------------------
	//Criação do objeto
	//-------------------
	oTab2 := FWTemporaryTable():New("TEMP2")

	//
	Aadd(aStru,{"TM_MES" , "N",02,0})
	For i := 1 To Len(aAnos)		
		Aadd(aStru,{"TM_"+Alltrim(cValToChar(aAnos[i][1])) , "N",15,4})

	Next i

	//Configura campos e índices.
	oTab2:SetFields(aStru)
	oTab2:AddIndex("indice1", {"TM_MES"} )

	//------------------
	//Criação da tabela
	//------------------
	oTab2:Create()

	//
	For i := 1 To 12

		RecLock("TEMP2",.T.)

		TEMP2->TM_MES := i

		For w := 1 To Len(aAnos)

			&("TEMP2->TM_"+Alltrim(cValToChar(aAnos[w][1])) + " := 0 " )

		Next w

		MsUnlock()

	Next i

	//
	For i := 1 To Len(aEmpresa)

		//
		cQuery := ""
		cQuery += scriptEvFat(aEmpresa[i])
		cQuery += " ORDER BY  " 
		cQuery += " ANO, MES "

		// 
		carArq2(cQuery,aAnos,aEmpresa)

	Next i

	//
	cQuery := ""		
	cQuery += rn_scriptEvFat()
	cQuery += " ORDER BY  "
	cQuery += " ANO, MES "

	//
	carArq2(cQuery,aAnos,aEmpresa)

	Conout("ADVFIN037R - Criado arquivo temporário 2 " + ElapTime ( cHrIni , Time() ) )

	//
	RestArea(aArea)

Return oTab2
/*/{Protheus.doc} carArq2
	Carga do arquivo temporário. 
	@type  Static Function
	@author Everson
	@since 09/01/2019
	@version 01
	/*/
Static Function carArq2(cQuery,aAnos,aEmpresa)

	//Variáveis.		
	Local aArea		:= GetArea()

	//
	If Select("D_EVVENDAS") > 0
		D_EVVENDAS->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_EVVENDAS"
	//MPSysOpenQuery( cQuery, 'D_EVVENDAS' )
	DbSelectArea("D_EVVENDAS")
	D_EVVENDAS->(DbGoTop())

	While ! D_EVVENDAS->(Eof())

		DbSelectArea("TEMP2")
		TEMP2->(DbSetOrder(1))
		TEMP2->(DbGoTop())

		If TEMP2->(DbSeek(Val(cValToChar(D_EVVENDAS->MES))))

			RecLock("TEMP2",.F.)

			&( "TEMP2->TM_" + Alltrim(cValToChar(D_EVVENDAS->ANO)) + " += " + cValToChar(D_EVVENDAS->FAT_LIQ) )

			MsUnlock()

		EndIf

		D_EVVENDAS->(DbSkip())

	EndDo

	//
	D_EVVENDAS->(DbCloseArea())

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} arqTemp3
	Arquivo temporário 3. 
	@type  Static Function
	@author Everson
	@since 09/01/2019
	@version 01
	/*/
Static Function arqTemp3(aAnos,aEmpresa)

	//Variáveis.	
	Local aArea		:= GetArea()
	Local oTab3		:= Nil
	Local aStru		:= {}
	Local i			:= 1
	Local w			:= 1
	Local cQuery	:= ""
	Local cHrIni	:= Time()

	//-------------------
	//Criação do objeto
	//-------------------
	oTab3 := FWTemporaryTable():New("TEMP3")

	//
	aStru := {}
	Aadd(aStru,{"TM_EMPRESA" , "C",02,0})

	//
	For i := 1 To Len(aAnos)

		Aadd(aStru,{"TM_"+Alltrim(cValToChar(aAnos[i][1])) , "N",15,4})

	Next i

	//Configura campos e índices.
	oTab3:SetFields(aStru)
	oTab3:AddIndex("indice1", {"TM_EMPRESA"} )

	//------------------
	//Criação da tabela
	//------------------
	oTab3:Create()

	//
	For i := 1 To Len(aEmpresa)

		RecLock("TEMP3",.T.)

		TEMP3->TM_EMPRESA := aEmpresa[i]

		MsUnlock()

	Next i

	//Obtém faturamento líquido individual das empresas.
	For i := 1 To Len(aEmpresa)

		//
		cQuery := "" //Everson 31/01/2019 chamdado TI.
		cQuery += ""
		cQuery += " SELECT "
		cQuery += " FONTE.ANO, SUM(FONTE.FAT_LIQ) AS FAT_LIQ "
		cQuery += " FROM "
		cQuery += " ( "

		cQuery += scriptEvFat(aEmpresa[i])

		cQuery += " ) AS FONTE "
		cQuery += " GROUP BY FONTE.ANO "
		cQuery += " ORDER BY FONTE.ANO "
		carArq3(cQuery,aAnos,aEmpresa,i)

	Next i

	//
	cQuery := ""
	cQuery += " SELECT "
	cQuery += " FONTE.ANO, SUM(FONTE.FAT_LIQ) AS FAT_LIQ "
	cQuery += " FROM "
	cQuery += " ( "

	cQuery += rn_scriptEvFat()

	cQuery += " ) AS FONTE "
	cQuery += " GROUP BY FONTE.ANO "
	cQuery += " ORDER BY FONTE.ANO "
	carArq3(cQuery,aAnos,aEmpresa,3)

	Conout("ADVFIN037R - Criado arquivo temporário 3 " + ElapTime ( cHrIni , Time() ) )

	//
	RestArea(aArea)	

Return oTab3
/*/{Protheus.doc} carArq3
	Carga do arquivo temporário.  
	@type  Static Function
	@author Everson
	@since 09/01/2019
	@version 01
	/*/
Static Function carArq3(cQuery,aAnos,aEmpresa,i)

	//Variáveis.		
	Local aArea		:= GetArea()

	//
	If Select("D_CONEMP") > 0
		D_CONEMP->(DbCloseArea())

	EndIf

	TcQuery cQuery New Alias "D_CONEMP"
	//MPSysOpenQuery( cQuery, 'D_CONEMP' )"
	DbSelectArea("D_CONEMP")
	D_CONEMP->(DbGoTop())

	While ! D_CONEMP->(Eof())

		DbSelectArea("TEMP3")
		TEMP3->(DbSetOrder(1))

		If TEMP3->(DbSeek(Alltrim(cValToChar(aEmpresa[i]))))

			RecLock("TEMP3",.F.)

			&("TEMP3->TM_" + cValToChar(D_CONEMP->ANO) + " += " + cValToChar(D_CONEMP->FAT_LIQ) )

			MsUnlock()

		EndIf

		D_CONEMP->(DbSkip())

	EndDo

	//
	D_CONEMP->(DbCloseArea())

	//
	RestArea(aArea)	

Return Nil
/*/{Protheus.doc} arqTemp4
	Arquivo temporário 4.  
	@type  Static Function
	@author Everson
	@since 09/01/2019
	@version 01
	/*/
Static Function arqTemp4(aAnos,aEmpresa)

	//Variáveis.	
	Local aArea		:= GetArea()
	Local oTab4		:= Nil
	Local aStru		:= {}
	Local i			:= 1
	Local cQuery	:= ""
	Local cHrIni	:= Time()

	//-------------------
	//Criação do objeto
	//-------------------
	oTab4 := FWTemporaryTable():New("TEMP4")

	//
	Aadd(aStru,{"ANO"       , "N",04,0})
	Aadd(aStru,{"SEMESTRE"  , "C",01,0})
	Aadd(aStru,{"MES"       , "N",02,0})
	Aadd(aStru,{"SEMANA"    , "N",05,0})
	Aadd(aStru,{"DIA"       , "C",10,0})
	Aadd(aStru,{"DIA_SEMANA", "N",02,0})
	Aadd(aStru,{"VENDAS"    , "N",15,4})
	Aadd(aStru,{"DEV"       , "N",15,4})
	Aadd(aStru,{"INTERCIA"  , "N",15,4})
	Aadd(aStru,{"FAT_LIQ"   , "N",15,4})
	Aadd(aStru,{"DIA_NFO"   , "C",08,0})
	Aadd(aStru,{"QTD_NF"    , "N",15,0}) //Everson - 06/05/2021. Chamado 12436.
	Aadd(aStru,{"PM"        , "N",15,4}) //Everson - 06/05/2021. Chamado 12436.

	//Configura campos e índices.
	oTab4:SetFields(aStru)
	oTab4:AddIndex("indice1", {"DIA_NFO"} )

	//------------------
	//Criação da tabela
	//------------------
	oTab4:Create()

	//Base Protheus.
	For i := 1 To Len(aEmpresa)

		//
		cQuery := ""
		cQuery += scriptVdDi(aEmpresa[i],.F.)
		cQuery += " ORDER BY REL.ANO, REL.SEMESTRE DESC, REL.SEMANA DESC, REL.MES DESC, REL.DIA, REL.DIA_SEMANA "
		carArq4(cQuery,aAnos,aEmpresa)

	Next i

	//Base anterior do SAG.
	cQuery := ""
	cQuery += rn_scriptVdDi(.F.)
	cQuery += " ORDER BY REL.ANO, REL.SEMESTRE DESC, REL.SEMANA DESC, REL.MES DESC, REL.DIA, REL.DIA_SEMANA "
	carArq4(cQuery,aAnos,aEmpresa)

	Conout("ADVFIN037R - Criado arquivo temporário 4 " + ElapTime ( cHrIni , Time() ) )

	//
	RestArea(aArea)

Return oTab4
/*/{Protheus.doc} carArq4
	Carrega arquivo temporário. 
	@type  Static Function
	@author Everson
	@since 14/01/2019
	@version 01
	/*/
Static Function carArq4(cQuery,aAnos,aEmpresa)

	//Variáveis.	
	Local aArea		:= GetArea()

	//
	If Select("FAT_DI") > 0
		FAT_DI->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "FAT_DI"
	//MPSysOpenQuery( cQuery, 'FAT_DI' )
	DbSelectArea("FAT_DI")

	//
	While ! FAT_DI->(Eof())

		DbSelectArea("TEMP4")
		TEMP4->(DbSetOrder(1))
		TEMP4->(DbGoTop())

		If TEMP4->(DbSeek(DToS(CToD(FAT_DI->DIA))))

			RecLock("TEMP4",.F.)
				TEMP4->VENDAS	+= FAT_DI->VENDAS
				TEMP4->DEV		+= FAT_DI->DEV
				TEMP4->INTERCIA	+= FAT_DI->INTERCIA
				TEMP4->FAT_LIQ	+= FAT_DI->FAT_LIQ
				TEMP4->QTD_NF	+= FAT_DI->QTD_NF //Everson - 06/05/2021. Chamado 12436.
				TEMP4->PM	  	+= FAT_DI->PM //Everson - 06/05/2021. Chamado 12436.
			MsUnLock()

		Else

			RecLock("TEMP4",.T.)
				TEMP4->ANO		  := FAT_DI->ANO
				TEMP4->SEMESTRE	  := FAT_DI->SEMESTRE
				TEMP4->MES		  := FAT_DI->MES
				TEMP4->SEMANA	  := FAT_DI->SEMANA
				TEMP4->DIA		  := FAT_DI->DIA
				TEMP4->DIA_SEMANA := FAT_DI->DIA_SEMANA
				TEMP4->VENDAS	  := FAT_DI->VENDAS
				TEMP4->DEV  	  := FAT_DI->DEV
				TEMP4->INTERCIA	  := FAT_DI->INTERCIA
				TEMP4->FAT_LIQ	  := FAT_DI->FAT_LIQ
				TEMP4->DIA_NFO	  := DToS(CToD(FAT_DI->DIA))
				TEMP4->QTD_NF	  := FAT_DI->QTD_NF //Everson - 06/05/2021. Chamado 12436.
				TEMP4->PM	  	  := FAT_DI->PM //Everson - 06/05/2021. Chamado 12436.
			MsUnLock()

		EndIf

		FAT_DI->(DbSkip())

	EndDo

	//
	FAT_DI->(DbCloseArea())

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} arqTemp5
	Arquivo temporário 5.  
	@type  Static Function
	@author Everson
	@since 09/01/2019
	@version 01
	/*/
Static Function arqTemp5(aAnos,aEmpresa)

	//Variáveis.	
	Local aArea		:= GetArea()
	Local oTab5		:= Nil
	Local aStru		:= {}
	Local i			:= 1
	Local w			:= 1
	Local cQuery	:= ""
	Local cHrIni	:= Time()

	//-------------------
	//Criação do objeto
	//-------------------
	oTab5 := FWTemporaryTable():New("TEMP5")

	//
	Aadd(aStru,{"ANO"       , "C",04,0})
	Aadd(aStru,{"SEMANA"    , "C",05,0})
	Aadd(aStru,{"FAT_LIQ"   , "N",15,4})

	//Configura campos e índices.
	oTab5:SetFields(aStru)
	oTab5:AddIndex("indice1", {"ANO","SEMANA"} )

	//------------------
	//Criação da tabela
	//------------------
	oTab5:Create()

	//
	For i := 1 To Len(aEmpresa)

		//
		cQuery := ""		
		cQuery += " SELECT FONTE.ANO, FONTE.SEMANA, SUM(FAT_LIQ) AS FAT_LIQ "
		cQuery += " FROM ( "
		cQuery += scriptVdDi(aEmpresa[i],.F.,.T.)
		cQuery += " ) AS FONTE "
		cQuery += " GROUP BY FONTE.ANO, FONTE.SEMANA "
		cQuery += " ORDER BY FONTE.ANO, FONTE.SEMANA "

		//
		carArq5(cQuery,aAnos,aEmpresa)

	Next i

	//
	cQuery := ""
	cQuery += " SELECT FONTE.ANO, FONTE.SEMANA, SUM(FAT_LIQ) AS FAT_LIQ "
	cQuery += " FROM ( "
	cQuery += rn_scriptVdDi(.F.,.T.)
	cQuery += " ) AS FONTE "
	cQuery += " GROUP BY FONTE.ANO, FONTE.SEMANA "			
	cQuery += " ORDER BY FONTE.ANO, FONTE.SEMANA "

	//
	carArq5(cQuery,aAnos,aEmpresa)

	Conout("ADVFIN037R - Criado arquivo temporário 5 " + ElapTime ( cHrIni , Time() ) )

	//
	RestArea(aArea)

Return oTab5  
/*/{Protheus.doc} carArq5
	Carrega arquivo temporário.  
	@type  Static Function
	@author Everson
	@since 14/01/2019
	@version 01
	/*/
Static Function carArq5(cQuery,aAnos,aEmpresa)

	//Variáveis.	
	Local aArea		:= GetArea()

	//
	If Select("FAT_DI_A") > 0
		FAT_DI_A->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "FAT_DI_A"
	//MPSysOpenQuery( cQuery, 'FAT_DI_A' )
	DbSelectArea("FAT_DI_A")

	While ! FAT_DI_A->(Eof())

		DbSelectArea("TEMP5")
		TEMP5->(DbSetOrder(1))
		TEMP5->(DbGoTop())
		If TEMP5->(DbSeek( Alltrim(cValToChar(FAT_DI_A->ANO)) + Alltrim(cValToChar(FAT_DI_A->SEMANA)) ))

			RecLock("TEMP5",.F.)
			TEMP5->FAT_LIQ	+= FAT_DI_A->FAT_LIQ
			MsUnLock()

		Else

			RecLock("TEMP5",.T.)
			TEMP5->ANO		  := Alltrim(cValToChar(FAT_DI_A->ANO))
			TEMP5->SEMANA	  := Alltrim(cValToChar(FAT_DI_A->SEMANA))
			TEMP5->FAT_LIQ	  := FAT_DI_A->FAT_LIQ
			MsUnLock()

		EndIf

		FAT_DI_A->(DbSkip())

	EndDo

	//
	FAT_DI_A->(DbCloseArea())

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} aba1
	Aba 1 do relatório.
	@type  Static Function
	@author Everson
	@since 14/01/2019
	@version 01
	/*/
Static Function aba1(cHtml)

	//Variáveis.

	cHtml += ' <div class="conteudo"> '
	cHtml += " <p style='color: red;'>***Valores Expressos em Milhares de Reais</p> " 
	cHtml += " <div class='grid-container' > "

	cHtml += " <div class='grid-item'> "
	cHtml += " <h3>Evolução Faturamento - Ano</h3> "
	cHtml += " <div id='grafico1'></div> "
	cHtml += " </div> "

	cHtml += " <div class='grid-item'> "
	cHtml += " <h3>Comparativo Faturamento - Mês</h3> "
	cHtml += " <div id='grafico2'></div> "
	cHtml += " </div> "

	cHtml += " <div class='grid-item'> "
	cHtml += " <h3>Comparativo Faturamento - Semana</h3> "
	cHtml += " <div id='grafico3'></div> "
	cHtml += " </div> "

	cHtml += " <div class='grid-item'> "
	cHtml += " <h3>Ticket Médio x Prazo Médio (Ad'oro)</h3> "
	cHtml += " <div id='grafico4'></div> "
	cHtml += " </div> "

	cHtml += " </div> "
	cHtml += ' </div> '

Return Nil
/*/{Protheus.doc} carGrafico
	Cria gráficos.
	@type  Static Function
	@author Everson
	@since 14/01/2019
	@version 01
	/*/
Static Function carGrafico(cHtml,cDGrf1,cDGrf2_1,cDGrf2_2,cDGrf2_3,cDGrf4_1,cDGrf4_2,cDGrf4_3,cDGrf5_1,cDGrf5_2,cDGrf5_3,cDGrf6_1,cDGrf6_2,cDGrf6_3,cDGrf3_1,cDGrf3_2,cDGrf3_3,cDGrf3_4)

	//Variáveis.

	//Gráfico 1.
	cHtml += " <script> "
	cHtml += " var chart = bb.generate({ "

	cHtml += " size: { "
	cHtml += " height: 240, "
	cHtml += " width: 500 "
	cHtml += " }, "

	cHtml += " data: { "
	cHtml += " columns: [ "
	cHtml += ' ["data1", ' + cDGrf1 + '], '
	cHtml += " ], "
	cHtml += " colors: {
	cHtml += ' data1: "#ffb236" '
	cHtml += " }, "
	cHtml += " names: {
	cHtml += ' data1: "Evolução Faturamento Ano" '
	cHtml += " },
	cHtml += " types: {
	cHtml += ' data1: "bar" '
	cHtml += " },
	cHtml += " axes: { "
	cHtml += " data1: 'y',  "
	cHtml += " }, "
	cHtml += " labels: { "
	cHtml += " format: { "
	cHtml += " data1: function(x) { "
	cHtml += " return x.toLocaleString('pt-BR'); "
	cHtml += " } "
	cHtml += " } "
	cHtml += " } "
	cHtml += " }, "

	cHtml += " axis: { "
	cHtml += " rotated: true, "
	cHtml += " y:{ "
	cHtml += " show: false "
	cHtml += " }, "
	cHtml += " x: { "
	cHtml += ' type: "category", '
	cHtml += " categories: [ "
	cHtml += ' "' + cValToChar( Year(dDateAnt) -5) + '", '
	cHtml += ' "' + cValToChar( Year(dDateAnt) -4) + '", '
	cHtml += ' "' + cValToChar( Year(dDateAnt) -3) + '", '
	cHtml += ' "' + cValToChar( Year(dDateAnt) -2) + '", '
	cHtml += ' "' + cValToChar( Year(dDateAnt) -1) + '", '
	cHtml += ' "' + cValToChar( Year(dDateAnt)) + '"  '
	cHtml += " ] "
	cHtml += " } "
	cHtml += " }, "
	cHtml += " legend: { "
	cHtml += " show: false "
	cHtml += " }, "
	cHtml += " grid: { "
	cHtml += " x: { "
	cHtml += " show: true "
	cHtml += " }, "
	cHtml += " y: { "
	cHtml += " show: false "
	cHtml += " } "
	cHtml += " }, "

	cHtml += " tooltip: { "
	cHtml += " format: { "
	cHtml += " value: function(value, ratio, id) { "
	cHtml += " return value.toLocaleString('pt-BR'); "
	cHtml += " }, "
	cHtml += " } "
	cHtml += " }, "

	cHtml += " bindto: '#grafico1' "
	cHtml += " }); "
	cHtml += " </script> "
	//Fim Gráfico 1.

	//Gráfico 2.
	cHtml += " <script> "
	cHtml += " var chart = bb.generate({ "

	cHtml += " size: { "
	cHtml += " height: 240, "
	cHtml += " width: 750 "
	cHtml += " }, "

	cHtml += " data: { "
	cHtml += " columns: [ "
	cHtml += ' ["data1", ' + cDGrf2_1 + '], '
	cHtml += ' ["data2", ' + cDGrf2_2 + '], '
	cHtml += ' ["data3", ' + cDGrf2_3 + '] '
	cHtml += " ], "
	cHtml += " colors: { "
	cHtml += ' data1: "#ffb236", '
	cHtml += ' data2: "#96191d", '
	cHtml += ' data3: "#28377c" '
	cHtml += " }, "
	cHtml += " names: { "
	cHtml += ' data1: "' + cValToChar( Year(dDateAnt) -2) + '", '
	cHtml += ' data2: "' + cValToChar( Year(dDateAnt) -1) + '", '
	cHtml += ' data3: "' + cValToChar( Year(dDateAnt) ) + '" '
	cHtml += " }, "
	cHtml += " types: { "
	cHtml += ' data1: "bar", '
	cHtml += ' data2: "bar", '
	cHtml += ' data3: "bar"  '
	cHtml += " }, "
	cHtml += " axes: { "
	cHtml += ' data1: "y", '
	cHtml += " }, "
	cHtml += " labels: { "
	cHtml += " format: { "
	cHtml += " data1: function(x) { "
	cHtml += " return x.toLocaleString('pt-BR'); "
	cHtml += " }, "
	cHtml += " data2: function(x) { "
	cHtml += " return x.toLocaleString('pt-BR'); "
	cHtml += " }, "
	cHtml += " data3: function(x) { "
	cHtml += " return x.toLocaleString('pt-BR'); "
	cHtml += " } "
	cHtml += " } "
	cHtml += " } "
	cHtml += " }, "
	cHtml += " axis: { "
	cHtml += " y:{ "
	cHtml += " show: false "
	cHtml += " }, "
	cHtml += " x: { "
	cHtml += ' type: "category", '
	cHtml += " categories: [ "
	cHtml += ' "Janeiro", '
	cHtml += ' "Fevereiro", '
	cHtml += ' "Março", '
	cHtml += ' "Abril", '
	cHtml += ' "Maio", '
	cHtml += ' "Junho", '
	cHtml += ' "Julho", '
	cHtml += ' "Agosto", '
	cHtml += ' "Setembro", '
	cHtml += ' "Outrubro", '
	cHtml += ' "Novembro", '
	cHtml += ' "Dezembro" '
	cHtml += " ] "
	cHtml += " } "
	cHtml += " }, "
	cHtml += " legend: { "
	cHtml += " show: true "
	cHtml += " }, "
	cHtml += " grid: { "
	cHtml += " x: { "
	cHtml += " show: true "
	cHtml += " }, "
	cHtml += " y: { "
	cHtml += " show: false "
	cHtml += " } "
	cHtml += " }, "

	cHtml += " tooltip: { "
	cHtml += " format: { "
	cHtml += " value: function(value, ratio, id) { "
	cHtml += " return value.toLocaleString('pt-BR'); "
	cHtml += " }, "
	cHtml += " } "
	cHtml += " }, "

	cHtml += ' bindto: "#grafico2" '
	cHtml += " }); "
	cHtml += " </script> "	
	//Fim Gráfico 2.

	//Gráfico 3.
	cHtml += " <script> "
	cHtml += " var chart = bb.generate({ "

	cHtml += " size: { "
	cHtml += " height: 240, "
	cHtml += " width: 500 "
	cHtml += " },

	cHtml += " data: { "
	cHtml += " columns: [ "
	cHtml += ' ["data1", ' + cDGrf3_1 + ' ], '
	cHtml += ' ["data2", ' + cDGrf3_2 + ' ], '
	cHtml += ' ["data3", ' + cDGrf3_3 + ' ]  '
	cHtml += " ], "
	cHtml += ' type: "bar", '
	cHtml += " colors: { "
	cHtml += ' data1: "#ffb236", '
	cHtml += ' data2: "#96191d", '
	cHtml += ' data3: "#28377c" '
	cHtml += " }, "
	cHtml += " names: { "
	cHtml += ' data1: "' + cValToChar( Year(dDateAnt) -2) + '", '
	cHtml += ' data2: "' + cValToChar( Year(dDateAnt) -1) + '", '
	cHtml += ' data3: "' + cValToChar( Year(dDateAnt) ) + '" '
	cHtml += " }, "
	cHtml += " types: { "
	cHtml += ' data1: "bar", '
	cHtml += ' data2: "bar", '
	cHtml += ' data3: "bar"  '
	cHtml += " }, "
	cHtml += " axes: { "
	cHtml += ' data1: "y", '
	cHtml += " }, "
	cHtml += " labels: { "
	cHtml += " format: { "
	cHtml += " data1: function(x) { "
	cHtml += " return x.toLocaleString('pt-BR'); "
	cHtml += " }, "
	cHtml += " data2: function(x) { "
	cHtml += " return x.toLocaleString('pt-BR'); "
	cHtml += " }, "
	cHtml += " data3: function(x) { "
	cHtml += " return x.toLocaleString('pt-BR'); "
	cHtml += " } "
	cHtml += " } "
	cHtml += " } "
	cHtml += " }, "
	cHtml += " axis: { "
	cHtml += " y:{ "
	cHtml += " show: false "
	cHtml += " }, "
	cHtml += " x: { "
	cHtml += ' type: "category", '
	cHtml += " categories: [ "
	cHtml += ' ' + cDGrf3_4 + ' '
	cHtml += " ], "
	cHtml += " label: { "
	cHtml += ' text: "Semanas do ano", '
	cHtml += ' position: "outer-left" '
	cHtml += " } "
	cHtml += " } "
	cHtml += " }, "
	cHtml += " legend: { "
	cHtml += " show: true "
	cHtml += " }, "
	cHtml += " grid: { "
	cHtml += " x: { "
	cHtml += " show: true "
	cHtml += " }, "
	cHtml += " y: { "
	cHtml += " show: false "
	cHtml += " } "
	cHtml += " }, "
	cHtml += " tooltip: { "
	cHtml += " format: { "
	cHtml += " value: function(value, ratio, id) { "
	cHtml += " return value.toLocaleString('pt-BR'); "
	cHtml += " }, "
	cHtml += " } "
	cHtml += " }, "
	cHtml += ' bindto: "#grafico3" '
	cHtml += " }); "
	cHtml += " </script> "
	//Fim Gráfico 3.

	//Gráfico 4.
	cHtml += " <script> "
	cHtml += " var chart = bb.generate({ "

	cHtml += " size: { "
	cHtml += " height: 240, "
	cHtml += " width: 750 "
	cHtml += " }, "

	cHtml += " data: { "
	cHtml += " columns: [ "
	cHtml += ' ["data1", ' + cDGrf4_1 + '], '
	cHtml += ' ["data2", ' + cDGrf4_2 + '] '
	cHtml += "  ], "
	cHtml += ' type: "bar", '
	cHtml += " colors: { "
	cHtml += ' data1: "#ffb236", '
	cHtml += ' data2: "#28377c" '
	cHtml += " }, "
	cHtml += " names: { "
	cHtml += ' data1: "PMV", '
	cHtml += ' data2: "Ticket Médio" '
	cHtml += " }, "
	cHtml += " types: { "
	cHtml += ' data1: "bar", '
	cHtml += ' data1: "line" '
	cHtml += " }, "
	cHtml += " axes: { "
	cHtml += ' data1: "y", '
	cHtml += ' data2: "y2", '
	cHtml += " }, "
	cHtml += " labels: { "
	cHtml += " format: { "
	cHtml += " data1: function(x) { "
	cHtml += " return x.toLocaleString('pt-BR'); "
	cHtml += " }, "
	cHtml += " data2: function(x) { "
	cHtml += " return x.toLocaleString('pt-BR'); "
	cHtml += " }, "
	cHtml += " data3: function(x) { "
	cHtml += " return x.toLocaleString('pt-BR'); "
	cHtml += " } "
	cHtml += " } "
	cHtml += " } "
	cHtml += " }, "
	cHtml += " axis: { "
	cHtml += " y:{ "
	cHtml += " show: false "
	cHtml += " }, "
	cHtml += " y2:{ "
	cHtml += " show: false "
	cHtml += " }, "
	cHtml += " x: { "
	cHtml += ' type: "category", '
	cHtml += " categories: [ "
	cHtml += ' ' + cDGrf4_3 + ', '
	cHtml += " ] "
	cHtml += " } "
	cHtml += " }, "
	cHtml += " legend: { "
	cHtml += " show: true "
	cHtml += " }, "
	cHtml += " grid: { "
	cHtml += " x: { "
	cHtml += " show: true "
	cHtml += " }, "
	cHtml += " y: { "
	cHtml += " show: false "
	cHtml += " } "
	cHtml += " }, "
	cHtml += " tooltip: { "
	cHtml += " format: { "
	cHtml += " value: function(value, ratio, id) { "
	cHtml += " return value.toLocaleString('pt-BR'); "
	cHtml += " }, "
	cHtml += " } "
	cHtml += " }, "
	cHtml += ' bindto: "#grafico4" '
	cHtml += " }); "
	cHtml += " </script> "
	//Fim Gráfico 4.

Return Nil
/*/{Protheus.doc} aba2
	Aba 2 do relatório.
	@type  Static Function
	@author Everson
	@since 09/01/2019
	@version 01
	/*/
Static Function aba2(cHtml,aAnos,aEmpresa,aNmEmpresas,cDGrf1,cDGrf2_1,cDGrf2_2,cDGrf2_3)

	//Variáveis.
	Local nUltAno		:= 0
	Local nAnoAtu		:= 0 
	Local aSubT2Aba		:= {}
	Local aTotT2Aba		:= {}
	Local nVarMensal 	:= 0
	Local nVarAcuAnt 	:= 0
	Local nVarAcuAtu 	:= 0
	Local nVarPorAcu 	:= 0
	Local cQuery		:= ""
	Local nVarSAno		:= 0
	Local nTtGeVarU		:= 0
	Local nTtGeVarA		:= 0
	Local i

	//
	cHtml += ' <div class="conteudo"> ' 
	cHtml += " <p style='color: red;'>***Valores Expressos em Milhares de Reais</p> " 	
	nUltAno := Year(dDateAnt) - 5
	nAnoAtu	:= Year(dDateAnt)

	cHtml += " <table id='rep2Aba' class='tabelaTab2'> " 
	cHtml += " <tr style='background-color: #a8a8a8; text-align:center; font-weight:bold;'> " 
	cHtml += " <td style='width:150px'>Mês</td> " 

	//
	For i := 1 To Len(aAnos)
		cHtml += " <td>" + Alltrim(cValToChar(aAnos[i][1])) + "</td> " 
		Aadd(aSubT2Aba,{Alltrim(cValToChar(aAnos[i][1])),0})
		Aadd(aTotT2Aba,{Alltrim(cValToChar(aAnos[i][1])),0})

	Next i

	cHtml += " <td style='background-color: #96191d; color: white; width:100px;'><p>Var. Mês  </p> <p><small>" + cValToChar(aAnos[Len(aAnos) -1][1]) + " a " + cValToChar(aAnos[Len(aAnos)][1]) + "</small></p></td> " 
	cHtml += " <td style='background-color: #96191d; color: white; width:100px; '><p>Var. Acum.</p> <p><small>" + cValToChar(aAnos[Len(aAnos) -1][1]) + " a " + cValToChar(aAnos[Len(aAnos)][1]) + "</small></p></td> " 
	cHtml += " </tr> " 

	//
	DbSelectArea("TEMP2")
	TEMP2->(DbGoTop())
	While ! TEMP2->(Eof())

		cHtml += " <tr> " 


		cHtml += " <td style='background-color: #a8a8a8; text-align:center; font-weight:bold;'>" + Substr(MesExtenso(Val(cValToChar(TEMP2->TM_MES))),1,3)  + "</td> "

		For i := 1 To Len(aAnos)

			cHtml += " <td align='right'>" + Transform( &( "TEMP2->TM_"+Alltrim(cValToChar(aAnos[i][1])) ) ,"@E 999,999,999.99") + "</td> " 

			If aAnos[i][1] = (Year(dDateAnt)-2)
				cDGrf2_1 += cValToChar(Round(&( "TEMP2->TM_"+Alltrim(cValToChar(aAnos[i][1])) ),2)) + ","

			ElseIf aAnos[i][1] = (Year(dDateAnt)-1)
				cDGrf2_2 += cValToChar(Round(&( "TEMP2->TM_"+Alltrim(cValToChar(aAnos[i][1])) ),2)) + ","

			ElseIf aAnos[i][1] = (Year(dDateAnt))
				cDGrf2_3 += cValToChar(Round(&( "TEMP2->TM_"+Alltrim(cValToChar(aAnos[i][1])) ),2)) + ","

			EndIf

			nPosSub := 0
			Eval({||;
			nPosSub := aScan(aSubT2Aba,{|x| Alltrim(cValToChar(x[1])) == Alltrim(cValToChar(aAnos[i][1])) }),;
			Iif(nPosSub > 0, Eval({|| aSubT2Aba[nPosSub][2]  += &( "TEMP2->TM_"+Alltrim(cValToChar(aAnos[i][1])) ) ,;
			aTotT2Aba[nPosSub][2] += &( "TEMP2->TM_"+Alltrim(cValToChar(aAnos[i][1])) ) }) ,Nil);
			})

			//Variação do ano anterior.                            
			If i == (Len(aAnos) -1)

				nVarMensal := &( "TEMP2->TM_"+Alltrim(cValToChar(aAnos[i][1])) )
				nVarAcuAnt += &( "TEMP2->TM_"+Alltrim(cValToChar(aAnos[i][1])) )

				//
				If (Month(dDateAnt) > Val(cValToChar(TEMP2->TM_MES))) .Or. Month(dDateAnt) == 12 .Or. lAnoAnt

					nTtGeVarU += &( "TEMP2->TM_"+Alltrim(cValToChar(aAnos[i][1])) )

				EndIf

			ElseIf i == Len(aAnos) //Variação do ano atual.

				nVarAcuAtu += &( "TEMP2->TM_"+Alltrim(cValToChar(aAnos[i][1])) )

				//
				If Month(dDateAnt) > Val(cValToChar(TEMP2->TM_MES)) .Or. Month(dDateAnt) == 12 .Or. lAnoAnt

					nTtGeVarA += &( "TEMP2->TM_"+Alltrim(cValToChar(aAnos[i][1])) )

				EndIf

				//Variação mensal.
				If (&("TEMP2->TM_" +Alltrim(cValToChar(aAnos[i][1])) ) > 0) .Or. lAnoAnt

					nVarMensal := Round((( &( "TEMP2->TM_"+Alltrim(cValToChar(aAnos[i][1])) ) - nVarMensal)/nVarMensal)*100,2)

				ELse
					nVarMensal := 0

				EndIf

				//Variação acumulada.
				If (nVarAcuAtu > 0 .And. Val(cValToChar(TEMP2->TM_MES)) < Month(dDateAnt)) .Or. lAnoAnt

					nVarPorAcu := Round(((nVarAcuAtu - nVarAcuAnt)/nVarAcuAnt)*100,2)

				Else
					nVarPorAcu := 0

				EndIf

			EndIf

		Next i

		//Variações.
		If (Val(cValToChar(TEMP2->TM_MES)) < Month(dDateAnt)) .Or. lAnoAnt
			cHtml += " <td align='right'>" + Transform(nVarMensal,"@E 999,999,999.99") + "%</td> " 
			cHtml += " <td align='right'>" + Transform(nVarPorAcu,"@E 999,999,999.99") + "%</td> " 

		Else
			cHtml += " <td align='right'>-</td> " 
			cHtml += " <td align='right'>-</td> " 

		EndIf

		nVarMensal := 0

		cHtml += " </tr> " 

		TEMP2->(DbSkip())

		//
		If TEMP2->TM_MES == 7

			cHtml += " <tr style='background-color: #a8a8a8; text-align:center; font-weight:bold;'> " 
			cHtml += " <td style='background-color: #a8a8a8; text-align:center; font-weight:bold;'>TT 1º Sem</td> "

			//
			For i := 1 To Len(aSubT2Aba)

				cHtml += " <td align='right'>" + Transform(Val(cValToChar(aSubT2Aba[i][2])),"@E 999,999,999.99") + "</td> " 

			Next i

			//
			nVarMensal := 0
			If (aSubT2Aba[Len(aSubT2Aba)][2]) > 0

				nVarMensal := Round((((aSubT2Aba[Len(aSubT2Aba)][2]) - (aSubT2Aba[Len(aSubT2Aba) -1][2]))/(aSubT2Aba[Len(aSubT2Aba) -1][2]))*100,2)

			EndIf

			//Zera os valoers do array.
			For i := 1 To Len(aSubT2Aba)

				aSubT2Aba[i][2] := 0

			Next i

			//
			If  Month(dDateAnt) > 6
				cHtml += " <td align='right' style='background-color: #96191d; color: white'>" + Transform(nVarMensal,"@E 999,999,999.99") + "%</td> " 
				cHtml += " <td align='right' style='background-color: #96191d; color: white'>" + Transform(nVarPorAcu,"@E 999,999,999.99") + "%</td> " 

			Else
				cHtml += " <td align='right' style='background-color: #96191d; color: white'>0,00%</td> " 
				cHtml += " <td align='right' style='background-color: #96191d; color: white'>0,00%</td> " 

			EndIf

			nVarPorAcu := 0

			//
			cHtml += " </tr> "
			cHtml += " <tr><td colspan='9' style='background-color:red;'></td></tr> " 

		EndIf

	EndDo

	//Total do segundo semestre.
	cHtml += " <tr style='background-color: #a8a8a8; text-align:center; font-weight:bold;'> " 
	cHtml += " <td style='background-color: #a8a8a8; text-align:center; font-weight:bold;'>TT 2º Sem</td> "

	//Preenche os totais por ano do 2º semestre.
	For i := 1 To Len(aSubT2Aba)
		cHtml += " <td align='right'>" + Transform(Val(cValToChar(aSubT2Aba[i][2])),"@E 999,999,999.99") + "</td> " 

	Next i

	//Calcula a variação do 2º semestre.
	nVarMensal := 0
	nVarMensal := Round((((aSubT2Aba[Len(aSubT2Aba)][2]) - (aSubT2Aba[Len(aSubT2Aba) -1][2]))/(aSubT2Aba[Len(aSubT2Aba) -1][2]))*100,2)

	//	
	If lAnoAnt //Everson - 08/01/2019. Chamado 046278. 
		cHtml += " <td align='right' style='background-color: #96191d; color: white'>" + Transform(nVarMensal,"@E 999,999,999.99") + "%</td> " 
		cHtml += " <td align='right' style='background-color: #96191d; color: white'>" + Transform(nVarPorAcu,"@E 999,999,999.99") + "%</td> "

	Else
		cHtml += " <td align='right' style='background-color: #96191d; color: white'>0,00%</td> " 
		cHtml += " <td align='right' style='background-color: #96191d; color: white'>0,00%</td> "

	EndIf
	nVarPorAcu := 0

	cHtml += " </tr> "
	cHtml += " <tr><td colspan='9' style='background-color:red;'></td></tr> " 

	//Total do Ano.
	cHtml += " <tr style='background-color: #ffb236; text-align:center; font-weight:bold;'> " 
	cHtml += " <td style='background-color: #ffb236; text-align:center; font-weight:bold;'>TT Ano</td> "
	For i := 1 To Len(aTotT2Aba)

		cHtml += " <td align='right'>" + Transform(Val(cValToChar(aTotT2Aba[i][2])),"@E 999,999,999.99") + "</td> " 
		cDGrf1 += cValToChar(Round(aTotT2Aba[i][2],2)) + Iif(i < Len(aTotT2Aba),",","")

	Next i

	//
	nVarMensal := 0
	If lAnoAnt //Everson - 08/01/2019. Chamado 046278.
		cHtml += " <td style='background-color: #96191d; color: white' align='right'>" + Transform(Iif(nTtGeVarU  > 0, ((nTtGeVarA - nTtGeVarU )/nTtGeVarU)*100 ,0),"@E 999,999,999.99") + "%</td> " 
		cHtml += " <td style='background-color: #96191d; color: white' align='right'>" + Transform(Iif(nTtGeVarU  > 0, ((nTtGeVarA - nTtGeVarU )/nTtGeVarU)*100 ,0),"@E 999,999,999.99") + "%</td> "

	Else
		cHtml += " <td style='background-color: #96191d; color: white' align='right'>0,00%</td> " 
		cHtml += " <td style='background-color: #96191d; color: white' align='right'>0,00%</td> "

	EndIf

	cHtml += " </tr> "	
	cHtml += " <tr style='background-color: #96191d; color: white;text-align:center; font-weight:bold;'> " 
	cHtml += " <td style='background-color: #96191d; color: white;text-align:center; font-weight:bold;'>Var. S/" + cValToChar(aAnos[1][1]) + "</td> "

	nVarSAno   := 0
	nVlrAnoAnt := aTotT2Aba[1][2]
	For i := 1 To Len(aTotT2Aba)

		If (aTotT2Aba[i][2]) > 0

			nVarSAno := Round((((aTotT2Aba[i][2]) - nVlrAnoAnt)/nVlrAnoAnt)*100,2)

		Else
			nVarSAno := 0

		EndIf

		cHtml += " <td style='background-color: #96191d; color:white; text-align:center; font-weight:bold;'>" + Transform(nVarSAno,"@E 999,999,999.99") + "%</td> "	

	Next i

	cHtml += " </tr> " 

	cHtml += " <tr style='background-color: #96191d; color:white; text-align:center; font-weight:bold;'> " 
	cHtml += " <td style='background-color: #96191d; color:white; text-align:center; font-weight:bold;'>Var. S/Ano Ant.</td> "

	nVarSAno   := 0
	For i := 1 To Len(aTotT2Aba)

		If i > 1 .And. (aTotT2Aba[i][2]) > 0

			nVlrAnoAnt := aTotT2Aba[i - 1][2]

			nVarSAno := Round((((aTotT2Aba[i][2]) - nVlrAnoAnt)/nVlrAnoAnt)*100,2)

		Else
			nVarSAno := 0

		EndIf

		cHtml += " <td style='background-color: #96191d; color:white; text-align:center; font-weight:bold;'>" + Transform(nVarSAno,"@E 999,999,999.99") + "%</td> "	

	Next i	
	cHtml += " </tr> 
	cHtml += " </table> "

	cHtml += " <br/> "

	//Totalizador por empresa.
	cHtml += " <table id='rep2Aba' class='tabelaTab2'> " 
	cHtml += " <tr style='background-color: #a8a8a8; text-align:center; font-weight:bold;'> " 
	cHtml += " <td style='width:150px;'>Empresa</td> "

	//
	For i := 1 To Len(aAnos)
		cHtml += " <td>" + Alltrim(cValToChar(aAnos[i][1])) + "</td> " 

	Next i

	cHtml += " <td style='background-color: #a8a8a8; color: white; width:100px;'><p>  </p></td> " 
	cHtml += " <td style='background-color: #a8a8a8; color: white; width:100px;'><p>  </p></td> "  
	cHtml += " </tr> " 

	//
	DbSelectArea("TEMP3")
	TEMP3->(DbGoTop())
	i := 1
	While ! TEMP3->(Eof())	

		nVaAcEmpU := 0
		nVaAcEmpA := 0
		cHtml += " <tr> " 

		cHtml += " <td align='center' valign='top' style='background-color: #a8a8a8;font-weight: bold;font-size:20;'>" + Alltrim(cValToChar(aNmEmpresas[i])) + "</td> " 
		i++

		For w := 1 To Len(aAnos)

			cHtml += " <td align='right'>" + Transform( &("TEMP3->TM_"+Alltrim(cValToChar(aAnos[w][1])) ),"@E 999,999,999.99") + "</td> " 

			//
			If w == (Len(aAnos) -1)
				nVaAcEmpU := &("TEMP3->TM_"+Alltrim(cValToChar(aAnos[w][1])) )

			ElseIf w == Len(aAnos)
				nVaAcEmpA := &("TEMP3->TM_"+Alltrim(cValToChar(aAnos[w][1])) )

			Endif

		Next w

		cHtml += " <td align='right'></td> " 
		cHtml += " <td align='right'></td> "

		cHtml += " </tr> " 

		TEMP3->(DbSkip())

	EndDo

	cHtml += " <tr><td colspan='18' style='background-color:red;'></td></tr> " 	
	cHtml += " <tr style='background-color: #ffb236; text-align:center; font-weight:bold;'> " 
	cHtml += " <td style='background-color: #ffb236; text-align:center; font-weight:bold;'>TT Ano</td> "
	For i := 1 To Len(aTotT2Aba)

		cHtml += " <td align='right'>" + Transform(Val(cValToChar(aTotT2Aba[i][2])),"@E 999,999,999.99") + "</td> " 

	Next i

	cHtml += " <td style='background-color: #a8a8a8; color: white; width:100px;'><p>  </p></td> " 
	cHtml += " <td style='background-color: #a8a8a8; color: white; width:100px;'><p>  </p></td> " 	
	cHtml += " </tr> "	
	cHtml += " </table> "

	//
	cLabels := ""
	For i := 1 To Len(aAnos)
		cLabels += '"' + Alltrim(cValToChar(aAnos[i][1])) + '"' + Iif(i < Len(aAnos),",","")
	Next i

	cData := ""
	For i := 1 To Len(aTotT2Aba)
		cData += cValToChar( Round(aTotT2Aba[i][2],2)) + Iif(i < Len(aAnos),",","")

	Next i

	cHtml += " </div> " 

Return Nil
/*/{Protheus.doc} aba3
	Aba 3 do relatório.
	@type  Static Function
	@author Everson
	@since 09/01/2019
	@version 01
	/*/
Static Function aba3(cHtml)

	//Variáveis.
	Local aArea := GetArea()

	//
	cHtml += ' <div class="conteudo"> ' 
		cHtml += " <p style='color: red;'>***Valores Expressos em Milhares de Reais</p> " 
		cHtml += " <table id='rep1Aba' class='tabelaTab1'> " 
			cHtml += " <tr style='background-color: #a8a8a8; text-align:center; font-weight:bold;'> " 
			cHtml += " <td colspan='2'></td> " 
			cHtml += " <td>Empresa</td> " 
			cHtml += " <td>Unidade</td> " 
			cHtml += " <td>Local</td> " 
			cHtml += " <td>jan/" + Substr(cValToChar(Year(dDateAnt)),3,2) + "</td> " 
			cHtml += " <td>fev/" + Substr(cValToChar(Year(dDateAnt)),3,2) + "</td> " 
			cHtml += " <td>mar/" + Substr(cValToChar(Year(dDateAnt)),3,2) + "</td> " 
			cHtml += " <td>abr/" + Substr(cValToChar(Year(dDateAnt)),3,2) + "</td> " 
			cHtml += " <td>mai/" + Substr(cValToChar(Year(dDateAnt)),3,2) + "</td> " 
			cHtml += " <td>jun/" + Substr(cValToChar(Year(dDateAnt)),3,2) + "</td> " 
			cHtml += " <td>jul/" + Substr(cValToChar(Year(dDateAnt)),3,2) + "</td> " 
			cHtml += " <td>ago/" + Substr(cValToChar(Year(dDateAnt)),3,2) + "</td> " 
			cHtml += " <td>set/" + Substr(cValToChar(Year(dDateAnt)),3,2) + "</td> " 
			cHtml += " <td>out/" + Substr(cValToChar(Year(dDateAnt)),3,2) + "</td> " 
			cHtml += " <td>nov/" + Substr(cValToChar(Year(dDateAnt)),3,2) + "</td> " 
			cHtml += " <td>dez/" + Substr(cValToChar(Year(dDateAnt)),3,2) + "</td> " 
			cHtml += " <td>Total</td> " 
			cHtml += " </tr> " 

			//Vendas.
			cHtml += " <tr> " 
			cHtml += " <td rowspan = '9' style='text-align:center;font-weight:bold;'>1</td> " 
			cHtml += " <td rowspan = '9' style='background-color: #a8a8a8; text-align:center;font-weight:bold;'>Faturamento</td> " 

			//Filial 01. Everson - 29/09/2020. Chamado 
			cHtml += " <td>Ad'oro</td> " 
			cHtml += " <td>Matriz</td> " 
			cHtml += " <td>VP</td> "
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("01" + "01"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "01" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "01"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_T)) ,"@E 999,999,999.99")))  + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

			//Filial 02
			cHtml += " <tr> " 
			cHtml += " <td>Ad'oro</td> " 
			cHtml += " <td>Abatedouro</td> " 
			cHtml += " <td>VP</td> "
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("01" + "02"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "01" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "02"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_T)) ,"@E 999,999,999.99")))  + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

			//
			cHtml += " <tr> " 
			cHtml += " <td>Ad'oro</td> " 
			cHtml += " <td>Fábrica Ração I</td> " 
			cHtml += " <td>SC</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("01" + "03"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "01" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "03"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_T)) ,"@E 999,999,999.99")))  + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf 
			cHtml += " </tr> " 

			//
			cHtml += " <tr> " 
			cHtml += " <td>Ad'oro</td> " 
			cHtml += " <td>Fábrica Ração II</td> " 
			cHtml += " <td>SC</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("01" + "05"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "01" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "05"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_T)) ,"@E 999,999,999.99")))  + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

			//
			cHtml += " <tr> " 
			cHtml += " <td>Ad'oro</td> " 
			cHtml += " <td>Incubat Ajapi</td> " 
			cHtml += " <td>RC</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("01" + "04"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "01" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "04"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_T)) ,"@E 999,999,999.99")))  + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

			//
			cHtml += " <tr> " 
			cHtml += " <td>Ad'oro</td> " 
			cHtml += " <td>Incubat Água BCA</td> " 
			cHtml += " <td>RC</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("01" + "09"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "01" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "09"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_T)) ,"@E 999,999,999.99")))  + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

			//
			cHtml += " <tr> " 
			cHtml += " <td>Ceres</td> " 
			cHtml += " <td>Graxaria</td> " 
			cHtml += " <td>VP</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("02" + "01"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "02" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "01"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_T)) ,"@E 999,999,999.99")))  + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

			//
			cHtml += " <tr> " 
			cHtml += " <td>RNX2</td> " 
			cHtml += " <td>Matrizeiro</td> " 
			cHtml += " <td>SC</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("07" + "01"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "07" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "01"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_T)) ,"@E 999,999,999.99")))  + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf			
			cHtml += " </tr> " 

			//Everson - 29/05/2020. Chamado 058402.
			cHtml += " <tr> " 
			cHtml += " <td>Safeeg</td> " 
			cHtml += " <td>Incubat Ajapi</td> " 
			cHtml += " <td>RC</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("09" + "01"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "09" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "01"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_T)) ,"@E 999,999,999.99")))  + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf			
			cHtml += " </tr> " 
			//

			//
			cHtml += " <tr style='background-color: #a8a8a8; text-align:center; font-weight:bold;'> " 
			cHtml += " <td colspan='5' align='center'>Subtotal</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("TT" + "TT"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "TT" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "TT"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_T)) ,"@E 999,999,999.99")))  + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 
			//

			//Devoluções.
			cHtml += " <tr><td colspan='18' style='background-color:red;'></td></tr> " 
			cHtml += "  " 

			//
			cHtml += " <tr> " 
			cHtml += " <td rowspan = '9' style='text-align:center;font-weight:bold;'>2</td> " 
			cHtml += " <td rowspan = '9' style='background-color: #a8a8a8; text-align:center;font-weight:bold;'>Devoluções</td> " 

			//Filial 01 - Everson - 29/09/2020. Chamado 2470.
			cHtml += " <td>Ad'oro</td> " 
			cHtml += " <td>Matriz</td> " 
			cHtml += " <td>VP</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("01" + "01"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "01" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "01"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_T)) ,"@E 999,999,999.99")))  + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

			//
			cHtml += " <tr> " 
			cHtml += " <td>Ad'oro</td> " 
			cHtml += " <td>Abatedouro</td> " 
			cHtml += " <td>VP</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("01" + "02"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "01" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "02"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_T)) ,"@E 999,999,999.99")))  + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

			//
			cHtml += " <tr> " 
			cHtml += " <td>Ad'oro</td> " 
			cHtml += " <td>Fábrica Ração I</td> " 
			cHtml += " <td>SC</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("01" + "03"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "01" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "03"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_T)) ,"@E 999,999,999.99"))) + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf 
			cHtml += " </tr> " 

			//
			cHtml += " <tr> " 
			cHtml += " <td>Ad'oro</td> " 
			cHtml += " <td>Fábrica Ração II</td> " 
			cHtml += " <td>SC</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("01" + "05"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "01" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "05"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_T)) ,"@E 999,999,999.99"))) + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

			//
			cHtml += " <tr> " 
			cHtml += " <td>Ad'oro</td> " 
			cHtml += " <td>Incubat Ajapi</td> " 
			cHtml += " <td>RC</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("01" + "04"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "01" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "04"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_T)) ,"@E 999,999,999.99")))  + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

			//
			cHtml += " <tr> " 
			cHtml += " <td>Ad'oro</td> " 
			cHtml += " <td>Incubat Água BCA</td> " 
			cHtml += " <td>RC</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("01" + "09"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "01" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "09"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_T)) ,"@E 999,999,999.99")))  + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

			//
			cHtml += " <tr> " 
			cHtml += " <td>Ceres</td> " 
			cHtml += " <td>Graxaria</td> " 
			cHtml += " <td>VP</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("02" + "01"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "02" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "01"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_T)) ,"@E 999,999,999.99")))  + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

			//
			cHtml += " <tr> " 
			cHtml += " <td>RNX2</td> " 
			cHtml += " <td>Matrizeiro</td> " 
			cHtml += " <td>SC</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("07" + "01"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "07" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "01"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_T)) ,"@E 999,999,999.99")))  + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

			//Everson - 29/05/2020. Chamado 058402.
			cHtml += " <tr> " 
			cHtml += " <td>Safeeg</td> " 
			cHtml += " <td>Incubat Ajapi</td> " 
			cHtml += " <td>RC</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("09" + "01"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "09" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "01"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_T)) ,"@E 999,999,999.99")))  + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

			//Subtotal devolução.
			cHtml += " <tr style='background-color: #a8a8a8; text-align:center; font-weight:bold;'> " 
			cHtml += " <td colspan='5' align='center'>Subtotal</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("TT" + "TT"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "TT" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "TT"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMD_T)) ,"@E 999,999,999.99")))  + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

			//Inter-CIA	
			cHtml += " <tr><td colspan='18' style='background-color:red;'></td></tr> " 
			cHtml += " <tr> " 
			cHtml += " <td rowspan = '9' style='text-align:center;font-weight:bold;'>3</td> " 
			cHtml += " <td rowspan = '9' style='background-color: #a8a8a8; text-align:center;font-weight:bold;'>Inter-CIA</td> " 

			//Filial - 01 - Everson - 29/09/2020. Chamado 2470.
			cHtml += " <td>Ad'oro</td> " 
			cHtml += " <td>Matriz</td> " 
			cHtml += " <td>VP</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("01" + "01"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "01" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "01"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_T)) ,"@E 999,999,999.99"))) + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

			cHtml += " <tr> " 
			cHtml += " <td>Ad'oro</td> " 
			cHtml += " <td>Abatedouro</td> " 
			cHtml += " <td>VP</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("01" + "02"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "01" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "02"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_T)) ,"@E 999,999,999.99"))) + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

			// 
			cHtml += " <tr> " 
			cHtml += " <td>Ad'oro</td> " 
			cHtml += " <td>Fábrica Ração I</td> " 
			cHtml += " <td>SC</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("01" + "03"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "01" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "03"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_T)) ,"@E 999,999,999.99"))) + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> "  
			
			//
			cHtml += " <tr> " 
			cHtml += " <td>Ad'oro</td> " 
			cHtml += " <td>Fábrica Ração II</td> " 
			cHtml += " <td>SC</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("01" + "05"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "01" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "05"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_T)) ,"@E 999,999,999.99"))) + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

			//
			cHtml += " <tr> " 
			cHtml += " <td>Ad'oro</td> " 
			cHtml += " <td>Incubat Ajapi</td> " 
			cHtml += " <td>RC</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("01" + "04"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "01" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "04"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_T)) ,"@E 999,999,999.99"))) + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 
			
			//
			cHtml += " <tr> " 
			cHtml += " <td>Ad'oro</td> " 
			cHtml += " <td>Incubat Água BCA</td> " 
			cHtml += " <td>RC</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("01" + "09"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "01" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "09"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_T)) ,"@E 999,999,999.99"))) + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 
			
			//
			cHtml += " <tr> " 
			cHtml += " <td>Ceres</td> " 
			cHtml += " <td>Graxaria</td> " 
			cHtml += " <td>VP</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("02" + "01"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "02" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "01"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_T)) ,"@E 999,999,999.99"))) + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

			//
			cHtml += " <tr> " 
			cHtml += " <td>RNX2</td> " 
			cHtml += " <td>Matrizeiro</td> " 
			cHtml += " <td>SC</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("07" + "01"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "07" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "01"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_T)) ,"@E 999,999,999.99"))) + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

			//Everson - 29/05/2020. Chamado 058402.
			cHtml += " <tr> " 
			cHtml += " <td>Safeeg</td> " 
			cHtml += " <td>Incubat Ajapi</td> " 
			cHtml += " <td>RC</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("09" + "01"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "09" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "01"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_T)) ,"@E 999,999,999.99"))) + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

			//
			cHtml += " <tr style='background-color: #a8a8a8; text-align:center; font-weight:bold;'> " 
			cHtml += " <td colspan='5' align='center'>Subtotal</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("TT" + "TT"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "TT" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "TT"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TMI_T)) ,"@E 999,999,999.99")))  + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

			//
			cHtml += " <tr><td colspan='18' style='background-color:red;'></td></tr> " 
			cHtml += " <tr style='background-color: #ffb236; text-align:center; font-weight:bold;'> " 
			cHtml += " <td colspan='5' align='center'  style='background-color: #ffb236'>Total Líquido (1 - 2 - 3)</td> " 
			DbSelectArea("TEMP")
			TEMP->(DbGoTop())
			If TEMP->(DbSeek("FL" + "FL"))

				While ! TEMP->(Eof()) .And. Alltrim(cValToChar(TEMP->TM_EMPRESA)) == "FL" .And. Alltrim(cValToChar(TEMP->TM_FILIAL)) == "FL"

					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_1)) ,"@E 999,999,999.99"))) + "</td> " 
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_2)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_3)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_4)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_5)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_6)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_7)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_8)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_9)) ,"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_10)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_11)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_12)),"@E 999,999,999.99"))) + "</td> "
					cHtml += " <td align='right'>" + Alltrim(cValToChar(Transform(Val(cValToChar(TEMP->TM_T)) ,"@E 999,999,999.99")))  + "</td> "

					TEMP->(DbSkip())

				EndDo

			Else

				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 
				cHtml += " <td align='right'>0</td> " 			

			EndIf
			cHtml += " </tr> " 

		cHtml += " </table> " 

	cHtml += " </div> " 

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} aba4
	Aba 4 do relatório.
	@type  Static Function
	@author Everson
	@since 09/01/2019
	@version 01
	/*/
Static Function aba4(cHtml,aAnos,cDGrf3_1,cDGrf3_2,cDGrf3_3,cDGrf3_4, cDGrf4_1, cDGrf4_2, cDGrf4_3)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cSemana 	:= ""
	Local cAno		:= ""
	Local nTotV	   	:= 0
	Local nTotTV	:= 0
	Local nTotD		:= 0
	Local nTotTD	:= 0
	Local nTotI		:= 0
	Local nTotTI	:= 0
	Local nTotF		:= 0
	Local nTotTF	:= 0
	Local i			:= 1
	Local nCntSem	:= 0

	//Everson - 30/07/2020. Chamado 059705.
	Local cDiaFmt	:= ""
	Local nTotSA 	:= 0
	Local oHash 	:= THashMap():New()
	//

	//Everson - 06/05/2021. Chamado 12436.
	Local oHsGr4_1	:= THashMap():New() 
	Local oHsGr4_2	:= THashMap():New() 
	Local aHsGr4_3	:= {}
	Local oHsGr4_4	:= THashMap():New() 
	Local cAnoMes 	:= 0
	Local nTotPmv 	:= 0
	Local nTotVnd 	:= 0
	Local nTotNF    := 0
	Local nAux 		:= 1
	//

	//
	DbSelectArea("TEMP5")
	TEMP5->(DbGoTop())

	DbSelectArea("TEMP4")
	TEMP4->(DbGoTop())

	//Faturamento Semanal.
	cHtml += " <div class='conteudo'> " 
	cHtml += " <p style='color: red;'>***Valores Expressos em Milhares de Reais</p> " 
	cHtml += " <table id='rep3Aba' class='tabelaTab3'> " 
	cHtml += " <tr style='background-color: #a8a8a8; text-align:center; font-weight:bold;'> " 
	cHtml += " <td>Ano</td> " 
	cHtml += " <td>Semestre</td> "
	cHtml += " <td>Mês</td> " 
	cHtml += " <td>Semana</td> " 
	cHtml += " <td>Dia</td> " 
	cHtml += " <td>Dia da Semana</td> " 
	cHtml += " <td>Vlr. Venda</td> " 
	cHtml += " <td>Vlr. Devolução</td> " 
	cHtml += " <td>Inter-CIA</td> " 
	cHtml += " <td>Fat. Líquido</td> " 

	cHtml += " <td>Fat.Sem.Acum</td> " //Everson - 30/07/2020. Chamado 059705.
	
	cHtml += " <td>Fat. Líq. Ano Anterior</td> " 

	cHtml += " </tr> " 

	//
	TEMP4->(DbGoTop())
	cSemana := Alltrim(cValToChar(TEMP4->SEMANA))
	cAnoMes := Alltrim(cValToChar(TEMP4->ANO)) + "-" + Right("00" + cValToChar(TEMP4->MES),2)
	cAnoAnt := cValToChar(Year(Date()) -1) + "-" + Right("00" + cValToChar(Month(Date())),2)
	If cAnoMes >= cAnoAnt
		Aadd(aHsGr4_3,cAnoMes)

	EndIf
	While ! TEMP4->(Eof())

		//
		If cSemana <> Alltrim(cValToChar(TEMP4->SEMANA))
			nTotSA := 0
			cSemana := Alltrim(cValToChar(TEMP4->SEMANA))

		EndIf

		//Everson - 30/07/2020. Chamado 059705.
		If CToD(TEMP4->DIA) < Date()
			
			//
			nTotSA += Val(cValToChar(TEMP4->FAT_LIQ))

			//
			oHash:Set(TEMP4->DIA,nTotSA)

		EndIf

		//Everson - 06/05/2021. Chamado 12436.
		If  cAnoMes <> Alltrim(cValToChar(TEMP4->ANO)) + "-" + Right("00" + cValToChar(TEMP4->MES),2)
			nTotPmv := 0
			nTotVnd := 0
			nTotNF  := 0
			cAnoMes := Alltrim(cValToChar(TEMP4->ANO)) + "-" + Right("00" + cValToChar(TEMP4->MES),2)

			If cAnoMes >= cAnoAnt
				Aadd(aHsGr4_3,cAnoMes)

			EndIf

		EndIf
		
		If cAnoMes >= cAnoAnt
			nTotPmv += Val(cValToChar(TEMP4->PM))
			oHsGr4_1:Set(cAnoMes,nTotPmv)

			nTotVnd += Val(cValToChar(TEMP4->VENDAS))
			oHsGr4_2:Set(cAnoMes,nTotVnd)

			nTotNF  += Val(cValToChar(TEMP4->QTD_NF))
			oHsGr4_4:Set(cAnoMes,nTotNF)
			
		EndIf
		//

		//
		TEMP4->(DbSkip())

	End

	//Everson - 06/05/2021. Chamado 12436.
	nTotPmv := 0
	nTotVnd := 0
	nTotNF  := 0
	For nAux := 1 To Len(aHsGr4_3)
		oHsGr4_1:Get(aHsGr4_3[nAux],@nTotPmv)
		oHsGr4_2:Get(aHsGr4_3[nAux],@nTotVnd)
		oHsGr4_4:Get(aHsGr4_3[nAux],@nTotNF)
		
		cDGrf4_1 += cValToChar( Iif(nTotVnd = 0 , 0, Round(nTotPmv/nTotVnd,2)) ) + "," //PMV
		cDGrf4_2 += cValToChar( Iif(nTotNF = 0 , 0, Round(nTotVnd/nTotNF,2)) ) + "," //Ticket Médio
		cDGrf4_3 += '"' + cValToChar(aHsGr4_3[nAux]) + '",' //rótulo eixo x

	Next nAux
	//

	//
	TEMP4->(DbGoBottom())
	While ! TEMP4->(Bof())

		//
		cAno    := Alltrim(cValToChar(TEMP4->ANO))
		cSemana := Alltrim(cValToChar(TEMP4->SEMANA))

		//
		cHtml += " <tr> " 
		cHtml += " <td align='center' valign='top' style='background-color: #a8a8a8;font-weight: bold;font-size:20;'>" + Alltrim(cValToChar(TEMP4->ANO)) + "</td> "  //Ano.
		cHtml += " <td align='center' valign='top' style='background-color: #a8a8a8;font-weight: bold;font-size:20;'>" + Alltrim(cValToChar(TEMP4->SEMESTRE)) + "º</td> "  //Semestre.
		cHtml += " <td align='center' valign='top' style='background-color: #a8a8a8;font-weight: bold;font-size:20;'>" + Substr(MesExtenso(Val(cValToChar(TEMP4->MES))),1,3) + "</td> "  //Mês.
		cHtml += " <td align='right'>" + Alltrim(cValToChar(TEMP4->SEMANA))   + "</td> "  //Semana.
		cHtml += " <td align='right'>" + Day2Str(CToD(TEMP4->DIA))            + "</td> "  //Dia.
		cHtml += " <td align='left' >" + DiaSemana(CToD(TEMP4->DIA))          + "</td> "  //Dia da semana.
		cHtml += " <td align='right'>" + Transform(Val(cValToChar(TEMP4->VENDAS))  ,"@E 999,999,999.99") + "</td> "  //Vlr. venda.
		cHtml += " <td align='right'>" + Transform(Val(cValToChar(TEMP4->DEV))     ,"@E 999,999,999.99") + "</td> "  //Vlr. devolução.
		cHtml += " <td align='right'>" + Transform(Val(cValToChar(TEMP4->INTERCIA)),"@E 999,999,999.99") + "</td> "  //Vlr. Inter-CIA.
		cHtml += " <td align='right'>" + Transform(Val(cValToChar(TEMP4->FAT_LIQ)) ,"@E 999,999,999.99") + "</td> "  //Fat. líquido.

		//Everson - 30/07/2020. Chamado 059705.
		If CToD(TEMP4->DIA) < Date()

			//
			If Empty(cDiaFmt)
				cDiaFmt := DiaSemana(CToD(TEMP4->DIA))

			EndIf

			nTotSA := 0
			oHash:Get(TEMP4->DIA,@nTotSA)
			cHtml   += " <td align='right' " + Iif(cDiaFmt <> DiaSemana(CToD(TEMP4->DIA)),""," style='background-color: #a8a8a8;' ") + " >" + Transform(Val(cValToChar(nTotSA)) ,"@E 999,999,999.99") + "</td> "  //Fat. Semanal Acumulado.

		EndIf

		cHtml += " </tr> "

		nTotV	+= Val(cValToChar(TEMP4->VENDAS))
		nTotTV	+= Val(cValToChar(TEMP4->VENDAS))

		nTotD	+= Val(cValToChar(TEMP4->DEV)) 
		nTotTD	+= Val(cValToChar(TEMP4->DEV)) 

		nTotI	+= Val(cValToChar(TEMP4->INTERCIA))
		nTotTI	+= Val(cValToChar(TEMP4->INTERCIA))

		nTotF	+= Val(cValToChar(TEMP4->FAT_LIQ))
		nTotTF	+= Val(cValToChar(TEMP4->FAT_LIQ))

		TEMP4->(DbSkip(-1))

		//Totaliza por semana.
		If cSemana <> Alltrim(cValToChar(TEMP4->SEMANA)) .And. ! TEMP4->(Bof())

			cHtml += " <tr style='background-color: #ffb236; text-align:center; font-weight:bold;'> " 
			cHtml += " <td colspan='6' style='background-color: #ffb236; text-align:center; font-weight:bold;'>Total Semana " + cSemana + "</td> "
			cHtml += " <td align='right'>" + Transform(nTotV ,"@E 999,999,999.99") + "</td> "  //Vlr. venda.
			cHtml += " <td align='right'>" + Transform(nTotD ,"@E 999,999,999.99") + "</td> "  //Vlr. devolução.
			cHtml += " <td align='right'>" + Transform(nTotI ,"@E 999,999,999.99") + "</td> "  //Vlr. Inter-Cia.
			cHtml += " <td align='right'>" + Transform(nTotF ,"@E 999,999,999.99") + "</td> "  //Fat. líquido.
			cHtml += " <td align='right'></td> "  //Fat. Semanal Acum.//Everson - 30/07/2020. Chamado 059705.

			//Faturamento líquido semanal de anos anteriores.
			If cAno == cValToChar( Year(dDateAnt) ) .Or. cAno == cValToChar( Year(dDateAnt)-1 )

				//
				If nCntSem < 5 .And. cAno == cValToChar( Year(dDateAnt) )
					cDGrf3_3 += cValToChar(nTotF) + ","
					cDGrf3_4 +=	'"S' + cSemana + '",'

				EndIf

				//
				For i := 1 To (Len(aAnos) -1)
					If TEMP5->(DbSeek( Alltrim(cValToChar(aAnos[i][1])) + cSemana ) )

						//
						If  aAnos[i][1] == (Val(cAno)-1)
							cHtml += " <td align='right'>" + Transform(Val(cValToChar(TEMP5->FAT_LIQ)) ,"@E 999,999,999.99") + "</td> "

						EndIf

						//
						If i = 4 .And. nCntSem < 5 .And. cAno == cValToChar( Year(dDateAnt) )
							cDGrf3_1 += cValToChar( Round(TEMP5->FAT_LIQ,2) ) + ","

						ElseIf i = 5 .And. nCntSem < 5 .And. cAno == cValToChar( Year(dDateAnt) )
							cDGrf3_2 += cValToChar( Round(TEMP5->FAT_LIQ,2) ) + ","

						EndIf

					Else

						//
						If  aAnos[i][1] == (Val(cAno)-1)
							cHtml += " <td align='right'>0,00</td> "

						EndIf

						//
						If i = 4 .And. nCntSem < 5 .And. cAno == cValToChar( Year(dDateAnt) ) 
							cDGrf3_1 += "0,"

						ElseIf i = 5 .And. nCntSem < 5 .And. cAno == cValToChar( Year(dDateAnt) )	
							cDGrf3_2 += "0,"

						EndIf

					EndIf

				Next i

				nCntSem++

			EndIf

			cHtml += " </tr> " 	

			//
			nTotV	:= 0
			nTotD	:= 0
			nTotI	:= 0
			nTotF	:= 0
			nTotSA  := 0 //Everson - 30/07/2020. Chamado 059705.

		EndIf

	EndDo

	//
	cHtml += " <tr style='background-color: #ffb236; text-align:center; font-weight:bold;'> " 
	cHtml += " <td colspan='6' style='background-color: #ffb236; text-align:center; font-weight:bold;'>Total Semana " + cSemana + "</td> "
	cHtml += " <td align='right'>" + Transform(nTotV ,"@E 999,999,999.99") + "</td> "  //Vlr. venda.
	cHtml += " <td align='right'>" + Transform(nTotD ,"@E 999,999,999.99") + "</td> "  //Vlr. devolução.
	cHtml += " <td align='right'>" + Transform(nTotI ,"@E 999,999,999.99") + "</td> "  //Vlr. Inter-Cia.
	cHtml += " <td align='right'>" + Transform(nTotF ,"@E 999,999,999.99") + "</td> "  //Fat. líquido.
	cHtml += " <td align='right'></td> "  //Fat. Semanal Acum.//Everson - 30/07/2020. Chamado 059705.

	//Faturamento líquido semanal de anos anteriores.
	If cAno == cValToChar( Year(dDateAnt) ) .Or. cAno == cValToChar( Year(dDateAnt)-1 )

		//
		If cAno == cValToChar( Year(dDateAnt) )
			cDGrf3_3 +=  cValToChar(nTotF) + ","
			cDGrf3_4 +=	'"S' + cSemana + '",'

		EndIf

		For i := 1 To (Len(aAnos) -1)
			If TEMP5->(DbSeek( Alltrim(cValToChar(aAnos[i][1])) + "1" ) )

				//
				If  aAnos[i][1] == (Val(cAno)-1)
					cHtml += " <td align='right'>" + Transform(Val(cValToChar(TEMP5->FAT_LIQ)) ,"@E 999,999,999.99") + "</td> "

				EndIf)

				//
				If i = 4 .And. nCntSem < 5 .And. cAno == cValToChar( Year(dDateAnt) ) 
					cDGrf3_1 += cValToChar( Round(TEMP5->FAT_LIQ,2) ) + ","

				ElseIf i = 5 .And. nCntSem < 5 .And. cAno == cValToChar( Year(dDateAnt) )	
					cDGrf3_2 += cValToChar( Round(TEMP5->FAT_LIQ,2) ) + ","

				EndIf

			Else

				//
				If  aAnos[i][1] == (Val(cAno)-1)
					cHtml += " <td align='right'>0,00</td> "

				EndIf

				//
				If i = 4 .And. nCntSem < 5 .And. cAno == cValToChar( Year(dDateAnt) ) 
					cDGrf3_1 += "0,"

				ElseIf i = 5 .And. nCntSem < 5 .And. cAno == cValToChar( Year(dDateAnt) )	
					cDGrf3_2 += "0,"

				EndIf

			EndIf

		Next i

	EndIf

	cHtml += " </tr> " 

	//Total Geral.
	cHtml += " <tr style='background-color: #ffb236; text-align:center; font-weight:bold;'> " 
	cHtml += " <td colspan='6' style='background-color: #ffb236; text-align:center; font-weight:bold;'>Total Geral</td> "
	cHtml += " <td align='right'>" + Transform(nTotTV ,"@E 999,999,999.99") + "</td> "  //Vlr. venda.
	cHtml += " <td align='right'>" + Transform(nTotTD ,"@E 999,999,999.99") + "</td> "  //Vlr. devolução.
	cHtml += " <td align='right'>" + Transform(nTotTI ,"@E 999,999,999.99") + "</td> "  //Vlr. Inter-Cia.
	cHtml += " <td align='right'>" + Transform(nTotTF ,"@E 999,999,999.99") + "</td> "  //Fat. líquido.
	cHtml += " <td align='right'></td> "  //Fat. Semanal Acum.//Everson - 30/07/2020. Chamado 059705.

	cHtml += " </tr> " 

	cHtml += " </table> " 
	cHtml += " </div> " 

	// Limpa os dados do HashMap
	HMClean(oHash)

  	// Libera o objeto de HashMap
	FreeObj(oHash)
	oHash := Nil

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} aba5
	Aba 5 do relatório.
	@type  Static Function
	@author Everson
	@since 09/01/2019
	@version 01
	/*/
Static Function aba5(cHtml,aAnos,aEmpresa,aNmEmpresas,cDGrf4_1,cDGrf4_2,cDGrf4_3,cDGrf5_1,cDGrf5_2,cDGrf5_3,cDGrf6_1,cDGrf6_2,cDGrf6_3)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cSemana 	:= ""
	Local nTotV	   	:= 0
	Local nTotTV	:= 0
	Local nTotD		:= 0
	Local nTotTD	:= 0
	Local nTotI		:= 0
	Local nTotTI	:= 0
	Local nTotF		:= 0
	Local nTotTF	:= 0
	Local cQuery	:= ""

	//Faturamento diário do ano.
	cHtml += " <div class='conteudo'> " 
	cHtml += " <p style='color: red;'>***Valores Expressos em Milhares de Reais</p> " 
	cHtml += " <p>Faturamento referente a " + cValToChar(Month(dDateAnt)) + "/" + cValToChar(Year(dDateAnt)) + "</p> " 

	//
	For i := 1 To Len(aEmpresa)

		cQuery := ""

		//
		If	aEmpresa[i] == "07"			
			cQuery += rn_scriptVdDi(.T.)
			cQuery += " UNION ALL "

		EndIf

		cQuery += scriptVdDi(aEmpresa[i],.T.)
		cQuery += " ORDER BY REL.DIA "

		//
		If Select("D_DIARIO") > 0
			D_DIARIO->(DbCloseArea())

		EndIf

		//
		TcQuery cQuery New Alias "D_DIARIO"
		//MPSysOpenQuery( cQuery, 'D_DIARIO' )
		DbSelectArea("D_DIARIO")
		D_DIARIO->(DbGoTop())

		//Faturamento diário.
		cHtml += " <span style='float:left;margin-right:3px;width:33%;margin-bottom:25px;'> " 
		cHtml += " <table class='tabelaTab4' style='border:1px solid black'> " 
		cHtml += " <tr style='background-color: #a8a8a8; text-align:center; font-weight:bold;'> " 
		cHtml += " <tr> "
		cHtml += " <td colspan='7' align='center' style='background-color:#96191d;color:white;font-weight:bold;'>" + aNmEmpresas[i] + "</td> " //Everson 29/05/2020 Chamado 058402.
		cHtml += " </tr> "
		cHtml += " <tr style='background-color: #a8a8a8; text-align:center; font-weight:bold;'> "
		cHtml += " <td>Dia</td> " 
		cHtml += " <td>Vlr. Venda</td> "
		cHtml += " <td>Vlr. Dev.</td> " 
		cHtml += " <td>Inter-CIA</td> "
		cHtml += " <td>Fat. Líquido</td> " 
		cHtml += " <td>PMV (dias)</td> " 
		cHtml += " <td>Ticket Médio</td> "  

		//
		nTotVendas 	:= 0
		nTotDev		:= 0
		nTotInter	:= 0
		nTotFatLi	:= 0
		nTotQtdNF	:= 0
		nTotPM		:= 0

		//
		While ! D_DIARIO->(Eof())

			//
			nTotVendas 	+= D_DIARIO->VENDAS
			nTotDev		+= D_DIARIO->DEV
			nTotInter	+= D_DIARIO->INTERCIA
			nTotFatLi	+= D_DIARIO->FAT_LIQ
			nTotQtdNF	+= D_DIARIO->QTD_NF
			nTotPM		+= D_DIARIO->PM

			cHtml += " <tr> "
			cHtml += " <td align='right'>" + Day2Str(CToD(D_DIARIO->DIA)) + "</td> " 
			cHtml += " <td align='right'>" + Transform(D_DIARIO->VENDAS   ,"@E 999,999,999.99") + "</td> "  //Vlr. venda.
			cHtml += " <td align='right'>" + Transform(D_DIARIO->DEV      ,"@E 999,999,999.99") + "</td> "  //Vlr. devolução.
			cHtml += " <td align='right'>" + Transform(D_DIARIO->INTERCIA ,"@E 999,999,999.99") + "</td> "  //Vlr. Inter-Cia.
			cHtml += " <td align='right'>" + Transform(D_DIARIO->FAT_LIQ  ,"@E 999,999,999.99") + "</td> "  //Fat. líquido.
			cHtml += " <td align='right'>" + Transform(Iif(D_DIARIO->VENDAS > 0,D_DIARIO->PM/D_DIARIO->VENDAS,0) ,"@E 999,999,999.99") + "</td> "  //PMV.
			cHtml += " <td align='right'>" + Transform(Iif(D_DIARIO->QTD_NF > 0, D_DIARIO->VENDAS/D_DIARIO->QTD_NF ,0) ,"@E 999,999,999.99") + "</td> "  //Ticket médio. 
			cHtml += " </tr> "		

			//
			If aEmpresa[i] == "01"
				//cDGrf4_1 += cValToChar( Round(Iif(D_DIARIO->VENDAS > 0,D_DIARIO->PM/D_DIARIO->VENDAS,0),2) ) + ","
				//cDGrf4_2 += cValToChar( Round(Iif(D_DIARIO->QTD_NF > 0, D_DIARIO->VENDAS/D_DIARIO->QTD_NF ,0),2) ) + ","

				//cDGrf4_3 += '"' + Day2Str(CToD(D_DIARIO->DIA)) + '",'

			ElseIf aEmpresa[i] == "02"
				cDGrf5_1 += cValToChar( Round(Iif(D_DIARIO->VENDAS > 0,D_DIARIO->PM/D_DIARIO->VENDAS,0),2) ) + ","
				cDGrf5_2 += cValToChar( Round(Iif(D_DIARIO->QTD_NF > 0, D_DIARIO->VENDAS/D_DIARIO->QTD_NF ,0),2) ) + ","

				cDGrf5_3 += '"' + Day2Str(CToD(D_DIARIO->DIA)) + '",'

			Else
				cDGrf6_1 += cValToChar( Round(Iif(D_DIARIO->VENDAS > 0,D_DIARIO->PM/D_DIARIO->VENDAS,0),2) ) + ","
				cDGrf6_2 += cValToChar( Round(Iif(D_DIARIO->QTD_NF > 0, D_DIARIO->VENDAS/D_DIARIO->QTD_NF ,0),2) ) + ","

				cDGrf6_3 += '"' + Day2Str(CToD(D_DIARIO->DIA)) + '",'

			EndIf

			D_DIARIO->(DbSkip())

		EndDo

		cHtml += " <tr style='background-color: #ffb236; text-align:center; font-weight:bold;'> " 
		cHtml += " <td align='right'>Tot</td> " 
		cHtml += " <td align='right'>" + Transform(nTotVendas ,"@E 999,999,999.99") + "</td> "  //Vlr. venda.
		cHtml += " <td align='right'>" + Transform(nTotDev    ,"@E 999,999,999.99") + "</td> "  //Vlr. devolução.
		cHtml += " <td align='right'>" + Transform(nTotInter  ,"@E 999,999,999.99") + "</td> "  //Vlr. Inter-Cia.
		cHtml += " <td align='right'>" + Transform(nTotFatLi  ,"@E 999,999,999.99") + "</td> "  //Fat. líquido.
		cHtml += " <td align='right'>" + Transform(Iif(nTotVendas > 0, nTotPM/nTotVendas,0) ,"@E 999,999,999.99") + "</td> "  //PMV.
		cHtml += " <td align='right'>" + Transform(Iif(nTotQtdNF  > 0, nTotVendas/nTotQtdNF,0) ,"@E 999,999,999.99") + "</td> "  //Ticket médio. 
		cHtml += " </tr> 

		//
		nTotVendas 	:= 0
		nTotDev		:= 0
		nTotInter	:= 0
		nTotFatLi	:= 0
		nTotQtdNF	:= 0
		nTotPM		:= 0

		cHtml += " </table> " 
		cHtml += " </span> " 

	Next i

	cHtml += " </div> "
	cHtml += " </div> "  

	//
	D_DIARIO->(DbCloseArea())

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} scriptFatLiq
	Script faturamento líquido.  
	@type  Static Function
	@author Everson
	@since 05/07/2017
	@version 01
	/*/
Static Function scriptFatLiq(cEmpresa)

	//Variáveis.	
	Local aArea		:= GetArea()
	Local cCNPJs	:= getCNPJ()
	Local cBkpEmp 	:= cEmpAnt

	//
	cEmpresa := Alltrim(cValToChar(cEmpresa))

	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " ISNULL(VENDAS.E1_FILIAL,ISNULL(DEV.E1_FILIAL,INTERCIA.E1_FILIAL)) AS FILIAL, " 
	cQuery += " ISNULL(VENDAS.MES,ISNULL(DEV.MES,INTERCIA.MES)) AS MES, " 
	cQuery += " ISNULL(VENDAS.E1_VALOR,0)/1000   AS VENDAS, " 
	cQuery += " ISNULL(DEV.E1_VALOR,0)/1000      AS DEV, " 
	cQuery += " ISNULL(INTERCIA.E1_VALOR,0)/1000 AS INTERCIA, " 
	cQuery += " (ISNULL(VENDAS.E1_VALOR,0) - ISNULL(DEV.E1_VALOR,0) - ISNULL(INTERCIA.E1_VALOR,0))/1000 AS FAT_LIQ " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " FONTE.E1_FILIAL, FONTE.MES, SUM(FONTE.E1_VALOR) AS E1_VALOR " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " E1_FILIAL, MONTH(CAST(E1_EMISSAO AS DATE)) AS MES, CASE WHEN E1_MOEDA = '1' THEN E1_VALOR ELSE E1_VLCRUZ END AS E1_VALOR " 
	cQuery += " FROM " 
	cQuery += " SE1" + cEmpresa + "0 (NOLOCK) AS SE1 " 
	cQuery += " WHERE " 
	cQuery += " SE1.D_E_L_E_T_ = '' " 
	cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) = " + Iif(lAnoAnt," (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "," YEAR(CAST(GETDATE() AS DATE)) ") 
	cQuery += " AND E1_TIPO = 'NF' " 
	cQuery += " AND E1_PREFIXO <> 'EEC' "
	cQuery += " ) AS FONTE " 
	cQuery += " GROUP BY FONTE.E1_FILIAL, FONTE.MES " 
	cQuery += " ) AS VENDAS " 
	cQuery += " FULL OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " FONTE.E1_FILIAL, FONTE.MES, SUM(FONTE.E1_VALOR) AS E1_VALOR " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " E1_FILIAL, MONTH(CAST(E1_EMISSAO AS DATE)) AS MES, CASE WHEN E1_MOEDA = '1' THEN E1_VALOR ELSE E1_VLCRUZ END AS E1_VALOR " 
	cQuery += " FROM " 
	cQuery += " SE1" + cEmpresa + "0 (NOLOCK) AS SE1 " 
	cQuery += " WHERE " 
	cQuery += " SE1.D_E_L_E_T_ = '' " 
	cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) = " + Iif(lAnoAnt," (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "," YEAR(CAST(GETDATE() AS DATE)) ") 
	cQuery += " AND E1_TIPO = 'NCC' " 
	cQuery += " AND E1_PREFIXO <> 'EEC' "
	cQuery += " ) AS FONTE " 
	cQuery += " GROUP BY FONTE.E1_FILIAL, FONTE.MES " 
	cQuery += " ) AS DEV " 
	cQuery += " ON VENDAS.E1_FILIAL = DEV.E1_FILIAL " 
	cQuery += " AND VENDAS.MES = DEV.MES " 
	cQuery += " FULL OUTER JOIN " 

	cQuery += " ( " 

	cQuery += " SELECT " 
	cQuery += " FONTE.E1_FILIAL, FONTE.MES, SUM(FONTE.E1_VALOR) AS E1_VALOR " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " E1_FILIAL, MONTH(CAST(E1_EMISSAO AS DATE)) AS MES, CASE WHEN E1_TIPO = 'NF' THEN (CASE WHEN E1_MOEDA = '1' THEN E1_VALOR ELSE E1_VLCRUZ END) 
	cQuery += " ELSE (CASE WHEN E1_MOEDA = '1' THEN E1_VALOR ELSE E1_VLCRUZ END) *-1 END AS E1_VALOR, SUBSTRING(LTRIM(RTRIM(A1_CGC)),1,10) AS CGC " 
	cQuery += " FROM " 
	cQuery += " SE1" + cEmpresa + "0 (NOLOCK) AS SE1 " 
	cQuery += " INNER JOIN " 
	cQuery += " SA1" + cEmpresa + "0 (NOLOCK) AS SA1 " 
	cQuery += " ON E1_CLIENTE = A1_COD " 
	cQuery += " AND E1_LOJA = A1_LOJA " 
	cQuery += " WHERE " 
	cQuery += " SE1.D_E_L_E_T_ = '' " 
	cQuery += " AND SA1.D_E_L_E_T_ = '' " 
	cQuery += " AND SUBSTRING(RTRIM(LTRIM(A1_CGC)),1,10) IN ( " 
	cQuery += " " + cCNPJs + " " 
	cQuery += " ) " 
	cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) = " + Iif(lAnoAnt," (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "," YEAR(CAST(GETDATE() AS DATE)) ") 
	cQuery += " AND E1_TIPO IN('NF','NCC') " 
	cQuery += " AND E1_PREFIXO <> 'EEC' "
	cQuery += " ) AS FONTE " 
	cQuery += " GROUP BY FONTE.E1_FILIAL, FONTE.MES " 

	cQuery += " ) AS INTERCIA " 
	cQuery += " ON VENDAS.E1_FILIAL = INTERCIA.E1_FILIAL " 
	cQuery += " AND VENDAS.MES = INTERCIA.MES " 

	//
	RestArea(aArea)

Return cQuery
/*/{Protheus.doc} rn_scriptFatLiq
	Script faturamento líquido RNX2. Chamado 035788. 
	@type  Static Function
	@author Everson
	@since 05/07/2017
	@version 01
	/*/
Static Function rn_scriptFatLiq()

	//Variáveis.	
	Local aArea	:= GetArea()
	Local cCNPJs:= getCNPJ()

	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " ISNULL(VENDAS.FILIAL,ISNULL(DEV.FILIAL,INTERCIA.FILIAL)) AS FILIAL, " 
	cQuery += " ISNULL(VENDAS.MES,ISNULL(DEV.MES,INTERCIA.MES)) AS MES, " 
	cQuery += " ISNULL(VENDAS.E1_VALOR,0)/1000 AS VENDAS, " 
	cQuery += " ISNULL(DEV.E1_VALOR,0)/1000    AS DEV, " 
	cQuery += " ISNULL(INTERCIA.E1_VALOR,0)/1000 AS INTERCIA, " 
	cQuery += " ( ISNULL(VENDAS.E1_VALOR,0) - ISNULL(DEV.E1_VALOR,0) - ISNULL(INTERCIA.E1_VALOR,0) )/1000 AS FAT_LIQ " 
	cQuery += " FROM " 
	cQuery += " ( "
	cQuery += " SELECT "  
	cQuery += " FONTE.FILIAL, FONTE.MES, SUM(FONTE.Valor) AS E1_VALOR "  
	cQuery += " FROM "  
	cQuery += " ( " 

	cQuery += " SELECT " 
	cQuery += " DISTINCT '01' AS FILIAL, Nota, Serie, YEAR(CAST(Emissao AS DATE)) AS ANO, MONTH(CAST(Emissao AS DATE)) AS MES, [Total Nota] AS Valor " 
	cQuery += " FROM " 
	cQuery += " SCSRV03.SAG.dbo.VW_RNX_NOTAS AS VW " 
	cQuery += " WHERE " 
	cQuery += " SUBSTRING(RTRIM(LTRIM([Tipo Nota])),1,1) = 'S' " 
	cQuery += " AND CFOP IN (1101, 1102, 1201, 2201, 5101, 5118, 5201, 6101, 6107, 6118, 5102, 5122 ) " 
	cQuery += " AND ANO_Emissao = " + Iif(lAnoAnt," (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "," YEAR(CAST(GETDATE() AS DATE)) ")  
	cQuery += " AND Situação <> 'CANCELADA' " 

	cQuery += " ) AS FONTE  
	cQuery += " GROUP BY  
	cQuery += " FONTE.FILIAL, FONTE.MES  
	cQuery += " ) AS VENDAS  

	cQuery += " FULL OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " FONTE.FILIAL, FONTE.MES, SUM(FONTE.Valor) AS E1_VALOR " 
	cQuery += " FROM " 
	cQuery += " ( " 

	cQuery += " SELECT "
	cQuery += " DISTINCT 'RN' AS FILIAL, Nota, Serie, YEAR(CAST(Emissao AS DATE)) AS ANO, MONTH(CAST(Emissao AS DATE)) AS MES, [Total Nota] AS Valor "
	cQuery += " FROM "
	cQuery += " SCSRV03.SAG.dbo.VW_RNX_NOTAS AS VW "
	cQuery += " WHERE "
	cQuery += " SUBSTRING(RTRIM(LTRIM([Tipo Nota])),1,2) = 'DS' "
	cQuery += " AND CFOP IN (1101, 1102, 1201, 2201, 5101, 5118, 5201, 6101, 6107, 6118, 5102, 5122 ) "
	cQuery += " AND ANO_Emissao = " + Iif(lAnoAnt," (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "," YEAR(CAST(GETDATE() AS DATE)) ") 
	cQuery += " AND Situação <> 'CANCELADA' "

	cQuery += " ) AS FONTE " 
	cQuery += " GROUP BY " 
	cQuery += " FONTE.FILIAL, FONTE.MES " 
	cQuery += " ) AS DEV " 
	cQuery += " ON VENDAS.MES = DEV.MES " 

	cQuery += " FULL OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " FONTE.FILIAL, FONTE.MES, SUM(FONTE.Valor) AS E1_VALOR " 
	cQuery += " FROM " 
	cQuery += " ( " 

	cQuery += " SELECT "
	cQuery += " DISTINCT 'RN' AS FILIAL, Nota, Serie, YEAR(CAST(Emissao AS DATE)) AS ANO, MONTH(CAST(Emissao AS DATE)) AS MES, CASE WHEN SUBSTRING([Tipo Nota],1,1) = 'S' THEN Valor ELSE Valor*-1 END AS Valor " 
	cQuery += " FROM "
	cQuery += " SCSRV03.SAG.dbo.VW_RNX_NOTAS AS VW "
	cQuery += " WHERE "
	cQuery += " RTRIM(LTRIM(SUBSTRING([Tipo Nota],1,2))) IN ('S','DS') "
	cQuery += " AND CFOP IN (1101, 1102, 1201, 2201, 5101, 5118, 5201, 6101, 6107, 6118, 5102, 5122 ) "
	cQuery += " AND ANO_Emissao = " + Iif(lAnoAnt," (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "," YEAR(CAST(GETDATE() AS DATE)) ") 
	cQuery += " AND Situação <> 'CANCELADA' ""
	cQuery += " AND SUBSTRING(RTRIM(LTRIM(Cnpj)),1,10) IN ( "  + cCNPJs +  " ) "  

	cQuery += " ) AS FONTE " 
	cQuery += " GROUP BY " 
	cQuery += " FONTE.FILIAL, FONTE.MES " 
	cQuery += " ) AS INTERCIA " 
	cQuery += " ON VENDAS.MES = INTERCIA.MES "  

	//
	RestArea(aArea)

Return cQuery 
/*/{Protheus.doc} scriptEvFat
	Script evolução faturamento líquido. Chamado 035788. 
	@type  Static Function
	@author Everson
	@since 05/07/2017
	@version 01
	/*/
Static Function scriptEvFat(cEmpresa)

	//Variáveis.	
	Local aArea	:= GetArea()
	Local cCNPJs:= getCNPJ()

	//
	cEmpresa := Alltrim(cValToChar(cEmpresa))

	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " REL.ANO, REL.MES, " 
	cQuery += " SUM(REL.VENDAS)        AS VENDAS, " 
	cQuery += " SUM(REL.DEV)/1000      AS DEV, " 
	cQuery += " SUM(REL.INTERCIA)/1000 AS INTERCIA, " 
	cQuery += " SUM(REL.FAT_LIQ)/1000  AS FAT_LIQ " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += "  " 
	cQuery += " SELECT    " 
	cQuery += " ISNULL(VENDAS.ANO,ISNULL(DEV.ANO,INTERCIA.ANO)) AS ANO,   " 
	cQuery += " ISNULL(VENDAS.MES,ISNULL(DEV.MES,INTERCIA.MES)) AS MES,   " 
	cQuery += " ISNULL(VENDAS.E1_VALOR,0) AS VENDAS,   " 
	cQuery += " ISNULL(DEV.E1_VALOR,0) AS DEV,   " 
	cQuery += " ISNULL(INTERCIA.E1_VALOR,0) AS INTERCIA,   " 
	cQuery += " (ISNULL(VENDAS.E1_VALOR,0) - ISNULL(DEV.E1_VALOR,0) - ISNULL(INTERCIA.E1_VALOR,0)) AS FAT_LIQ   " 
	cQuery += " FROM  " 
	cQuery += "   " 
	cQuery += " (   " 
	cQuery += " SELECT   " 
	cQuery += " FONTE.E1_FILIAL, FONTE.ANO, FONTE.MES, SUM(FONTE.E1_VALOR) AS E1_VALOR   " 
	cQuery += " FROM   " 
	cQuery += " (   " 
	cQuery += " SELECT   " 
	cQuery += " E1_FILIAL, YEAR(CAST(E1_EMISSAO AS DATE)) AS ANO, MONTH(CAST(E1_EMISSAO AS DATE)) AS MES, CASE WHEN E1_MOEDA = '1' THEN E1_VALOR ELSE E1_VLCRUZ END AS E1_VALOR   " 
	cQuery += " FROM   " 
	cQuery += " SE1" + cEmpresa + "0 (NOLOCK) AS SE1   " 
	cQuery += " WHERE   " 
	cQuery += " SE1.D_E_L_E_T_ = ''   "

	//
	If lAnoAnt
		cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) >= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))-5) " 
		cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) <= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

	Else
		cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) >= (YEAR(GETDATE()) - 5) " 

	EndIf

	//
	cQuery += " AND E1_TIPO = 'NF'   " 
	cQuery += " AND E1_PREFIXO <> 'EEC' "
	cQuery += " ) AS FONTE   " 
	cQuery += " GROUP BY FONTE.E1_FILIAL, FONTE.ANO, FONTE.MES   " 
	cQuery += " ) AS VENDAS   " 
	cQuery += "  " 
	cQuery += " FULL OUTER JOIN " 
	cQuery += "    " 
	cQuery += " (   " 
	cQuery += " SELECT   " 
	cQuery += " FONTE.E1_FILIAL, FONTE.ANO, FONTE.MES, SUM(FONTE.E1_VALOR) AS E1_VALOR   " 
	cQuery += " FROM   " 
	cQuery += " (   " 
	cQuery += " SELECT   " 
	cQuery += " E1_FILIAL, YEAR(CAST(E1_EMISSAO AS DATE)) AS ANO, MONTH(CAST(E1_EMISSAO AS DATE)) AS MES, CASE WHEN E1_MOEDA = '1' THEN E1_VALOR ELSE E1_VLCRUZ END AS E1_VALOR   " 
	cQuery += " FROM   " 
	cQuery += " SE1" + cEmpresa + "0 (NOLOCK) AS SE1   " 
	cQuery += " WHERE   " 
	cQuery += " SE1.D_E_L_E_T_ = ''   " 

	//
	If lAnoAnt
		cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) >= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))-5) " 
		cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) <= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

	Else
		cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) >= (YEAR(GETDATE()) - 5) " 

	EndIf

	//
	cQuery += " AND E1_TIPO = 'NCC'   " 
	cQuery += " AND E1_PREFIXO <> 'EEC' "
	cQuery += " ) AS FONTE   " 
	cQuery += " GROUP BY FONTE.E1_FILIAL, FONTE.ANO, FONTE.MES   " 
	cQuery += " ) AS DEV  " 
	cQuery += "   " 
	cQuery += " ON VENDAS.E1_FILIAL = DEV.E1_FILIAL   " 
	cQuery += " AND VENDAS.ANO = DEV.ANO  " 
	cQuery += " AND VENDAS.MES = DEV.MES   " 
	cQuery += "  " 
	cQuery += " FULL OUTER JOIN   " 
	cQuery += " (   " 

	cQuery += " SELECT   " 
	cQuery += " FONTE.E1_FILIAL, FONTE.ANO, FONTE.MES, SUM(FONTE.E1_VALOR) AS E1_VALOR   " 
	cQuery += " FROM   " 
	cQuery += " (   " 
	cQuery += " SELECT   " 
	cQuery += " E1_FILIAL, YEAR(CAST(E1_EMISSAO AS DATE)) AS ANO, MONTH(CAST(E1_EMISSAO AS DATE)) AS MES, CASE WHEN E1_TIPO = 'NF' THEN (CASE WHEN E1_MOEDA = '1' THEN E1_VALOR ELSE E1_VLCRUZ END) 
	cQuery += " ELSE (CASE WHEN E1_MOEDA = '1' THEN E1_VALOR ELSE E1_VLCRUZ END) *-1 END AS E1_VALOR, SUBSTRING(LTRIM(RTRIM(A1_CGC)),1,10) AS CGC   " 
	cQuery += " FROM   " 
	cQuery += " SE1" + cEmpresa + "0 (NOLOCK) AS SE1   " 
	cQuery += " INNER JOIN   " 
	cQuery += " SA1" + cEmpresa + "0 (NOLOCK) AS SA1   " 
	cQuery += " ON E1_CLIENTE = A1_COD   " 
	cQuery += " AND E1_LOJA = A1_LOJA   " 
	cQuery += " WHERE   " 
	cQuery += " SE1.D_E_L_E_T_ = ''   " 
	cQuery += " AND SA1.D_E_L_E_T_ = ''   " 
	cQuery += " AND SUBSTRING(RTRIM(LTRIM(A1_CGC)),1,10) IN (" + cCNPJs + ") " 

	//
	If lAnoAnt
		cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) >= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))-5) " 
		cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) <= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

	Else
		cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) >= (YEAR(GETDATE()) - 5) " 

	EndIf

	cQuery += " AND E1_TIPO IN ('NF','NCC')   " 
	cQuery += " AND E1_PREFIXO <> 'EEC' "
	cQuery += " ) AS FONTE   " 
	cQuery += " GROUP BY FONTE.E1_FILIAL, FONTE.ANO, FONTE.MES   " 

	cQuery += " ) AS INTERCIA   " 
	cQuery += " ON VENDAS.E1_FILIAL = INTERCIA.E1_FILIAL   " 
	cQuery += " AND VENDAS.ANO = INTERCIA.ANO  " 
	cQuery += " AND VENDAS.MES = INTERCIA.MES   " 
	cQuery += " ) AS REL " 
	cQuery += " GROUP BY " 
	cQuery += " REL.ANO, REL.MES " 

	//
	RestArea(aArea)

Return cQuery
/*/{Protheus.doc} rn_scriptEvFat
	Script evolução faturamento líquido RNX2. Chamado 035788. 
	@type  Static Function
	@author Everson
	@since 10/07/2017 
	@version 01
	/*/
Static Function rn_scriptEvFat()

	//Variáveis.	
	Local aArea	:= GetArea()
	Local cCNPJs:= getCNPJ()

	//
	cQuery := ""
	cQuery += " SELECT   " 
	cQuery += " ISNULL(VENDAS.ANO,ISNULL(DEV.ANO,INTERCIA.ANO)) AS ANO,  " 
	cQuery += " ISNULL(VENDAS.MES,ISNULL(DEV.MES,INTERCIA.MES)) AS MES,   " 
	cQuery += " ISNULL(VENDAS.E1_VALOR,0)/1000 AS VENDAS,   " 
	cQuery += " ISNULL(DEV.E1_VALOR,0)/1000    AS DEV,   " 
	cQuery += " ISNULL(INTERCIA.E1_VALOR,0)/1000 AS INTERCIA,   " 
	cQuery += " ( ISNULL(VENDAS.E1_VALOR,0) - ISNULL(DEV.E1_VALOR,0) - ISNULL(INTERCIA.E1_VALOR,0) )/1000 AS FAT_LIQ   " 
	cQuery += " FROM   " 
	cQuery += " (   " 
	cQuery += " SELECT   " 
	cQuery += " FONTE.ANO, FONTE.MES, SUM(FONTE.Valor) AS E1_VALOR   " 
	cQuery += " FROM   " 
	cQuery += " (   " 

	cQuery += " SELECT "
	cQuery += " DISTINCT 'RN' AS FILIAL, Nota, Serie, YEAR(CAST(Emissao AS DATE)) AS ANO, MONTH(CAST(Emissao AS DATE)) AS MES, [Total Nota] AS Valor "
	cQuery += " FROM "
	cQuery += " SCSRV03.SAG.dbo.VW_RNX_NOTAS AS VW "
	cQuery += " WHERE "
	cQuery += " SUBSTRING(RTRIM(LTRIM([Tipo Nota])),1,1) = 'S' "
	cQuery += " AND CFOP IN (1101, 1102, 1201, 2201, 5101, 5118, 5201, 6101, 6107, 6118, 5102, 5122 ) "

	//
	If lAnoAnt
		cQuery += " AND YEAR(CAST(Emissao AS DATE)) >= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))-5) " 
		cQuery += " AND YEAR(CAST(Emissao AS DATE)) <= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

	Else
		cQuery += " AND YEAR(CAST(Emissao AS DATE)) >= (YEAR(GETDATE()) - 5) " 

	EndIf

	cQuery += " AND Situação <> 'CANCELADA' "

	cQuery += " ) AS FONTE   " 
	cQuery += " GROUP BY   " 
	cQuery += " FONTE.ANO, FONTE.MES   " 
	cQuery += " ) AS VENDAS   " 

	cQuery += " FULL OUTER JOIN   " 
	cQuery += " (   " 
	cQuery += " SELECT   " 
	cQuery += " FONTE.ANO, FONTE.MES, SUM(FONTE.Valor) AS E1_VALOR   " 
	cQuery += " FROM   " 
	cQuery += " (   " 

	cQuery += " SELECT "
	cQuery += " DISTINCT 'RN' AS FILIAL, Nota, Serie, YEAR(CAST(Emissao AS DATE)) AS ANO, MONTH(CAST(Emissao AS DATE)) AS MES, [Total Nota] AS Valor "
	cQuery += " FROM "
	cQuery += " SCSRV03.SAG.dbo.VW_RNX_NOTAS AS VW "
	cQuery += " WHERE "
	cQuery += " SUBSTRING(RTRIM(LTRIM([Tipo Nota])),1,2) = 'DS' "
	cQuery += " AND CFOP IN (1101, 1102, 1201, 2201, 5101, 5118, 5201, 6101, 6107, 6118, 5102, 5122 ) "

	//
	If lAnoAnt
		cQuery += " AND YEAR(CAST(Emissao AS DATE)) >= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))-5) " 
		cQuery += " AND YEAR(CAST(Emissao AS DATE)) <= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

	Else
		cQuery += " AND YEAR(CAST(Emissao AS DATE)) >= (YEAR(GETDATE()) - 5) " 

	EndIf

	cQuery += " AND Situação <> 'CANCELADA' "

	cQuery += " ) AS FONTE   " 
	cQuery += " GROUP BY   " 
	cQuery += " FONTE.ANO, FONTE.MES   " 
	cQuery += " ) AS DEV   " 
	cQuery += " ON VENDAS.MES = DEV.MES   " 
	cQuery += " AND VENDAS.ANO = DEV.ANO "

	cQuery += " FULL OUTER JOIN   " 
	cQuery += " (   " 
	cQuery += " SELECT   " 
	cQuery += " FONTE.ANO, FONTE.MES, SUM(FONTE.Valor) AS E1_VALOR   " 
	cQuery += " FROM   " 
	cQuery += " (   " 

	cQuery += " SELECT "
	cQuery += " DISTINCT 'RN' AS FILIAL, Nota, Serie, YEAR(CAST(Emissao AS DATE)) AS ANO, MONTH(CAST(Emissao AS DATE)) AS MES, CASE WHEN SUBSTRING([Tipo Nota],1,1) = 'S' THEN Valor ELSE Valor*-1 END AS Valor " 
	cQuery += " FROM "
	cQuery += " SCSRV03.SAG.dbo.VW_RNX_NOTAS AS VW "
	cQuery += " WHERE "
	cQuery += " RTRIM(LTRIM(SUBSTRING([Tipo Nota],1,2))) IN ('S','DS') "
	cQuery += " AND CFOP IN (1101, 1102, 1201, 2201, 5101, 5118, 5201, 6101, 6107, 6118, 5102, 5122 ) "

	//
	If lAnoAnt
		cQuery += " AND YEAR(CAST(Emissao AS DATE)) >= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))-5) " 
		cQuery += " AND YEAR(CAST(Emissao AS DATE)) <= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

	Else
		cQuery += " AND YEAR(CAST(Emissao AS DATE)) >= (YEAR(GETDATE()) - 5) " 

	EndIf

	cQuery += " AND Situação <> 'CANCELADA' ""
	cQuery += " AND SUBSTRING(RTRIM(LTRIM(Cnpj)),1,10) IN ( "  + cCNPJs +  " ) 

	cQuery += " ) AS FONTE   " 
	cQuery += " GROUP BY   " 
	cQuery += " FONTE.ANO, FONTE.MES   " 
	cQuery += " ) AS INTERCIA   " 
	cQuery += " ON VENDAS.MES = INTERCIA.MES " 
	cQuery += " AND VENDAS.ANO = INTERCIA.ANO "

	//
	RestArea(aArea)

Return cQuery
/*/{Protheus.doc} scriptVdDi
	Script faturamento líquido vendas diárias do ano. Chamado 035788. 
	@type  Static Function
	@author Everson
	@since 07/07/2017
	@version 01
	/*/
Static Function scriptVdDi(cEmpresa,lMesAtu,lBAnAnt)

	//Variáveis.	
	Local aArea		:= GetArea()
	Local cCNPJs	:= getCNPJ()
	Local cQuery	:= ""

	Default lBAnAnt := .F.

	cEmpresa := Alltrim(cValToChar(cEmpresa))	

	//
	cQuery := ""
	cQuery += " SELECT       " 
	cQuery += " REL.ANO, REL.SEMESTRE,     " 
	cQuery += " REL.MES, REL.SEMANA, REL.DIA, REL.DIA_SEMANA,     " 
	cQuery += " SUM(REL.VENDAS)/1000   AS VENDAS,       " 
	cQuery += " SUM(REL.DEV)/1000      AS DEV,       " 
	cQuery += " SUM(REL.INTERCIA)/1000 AS INTERCIA,       " 
	cQuery += " SUM(REL.FAT_LIQ)/1000  AS FAT_LIQ    " 
	cQuery += " ,SUM( QTD_NF) AS QTD_NF " 
	cQuery += " ,SUM(PM)/1000 AS PM   " 
	cQuery += " FROM       " 
	cQuery += " (       " 
	cQuery += "        " 
	cQuery += " SELECT          " 
	cQuery += " ISNULL(VENDAS.ANO,ISNULL(DEV.ANO,INTERCIA.ANO)) AS ANO,      " 
	cQuery += " ISNULL(VENDAS.SEMESTRE,ISNULL(DEV.SEMESTRE,INTERCIA.SEMESTRE)) AS SEMESTRE,        " 
	cQuery += " ISNULL(VENDAS.MES,ISNULL(DEV.MES,INTERCIA.MES)) AS MES,         " 
	cQuery += " ISNULL(VENDAS.SEMANA,ISNULL(DEV.SEMANA,INTERCIA.SEMANA)) AS SEMANA,        " 
	cQuery += " ISNULL(VENDAS.DIA,ISNULL(DEV.DIA,INTERCIA.DIA)) AS DIA,     " 
	cQuery += " ISNULL(VENDAS.DIA_SEMANA,ISNULL(DEV.DIA_SEMANA,INTERCIA.DIA_SEMANA)) AS DIA_SEMANA,     " 
	cQuery += " ISNULL(VENDAS.E1_VALOR,0) AS VENDAS,         " 
	cQuery += " ISNULL(DEV.E1_VALOR,0) AS DEV,         " 
	cQuery += " ISNULL(INTERCIA.E1_VALOR,0) AS INTERCIA,         " 
	cQuery += " (ISNULL(VENDAS.E1_VALOR,0) - ISNULL(DEV.E1_VALOR,0) - ISNULL(INTERCIA.E1_VALOR,0)) AS FAT_LIQ,   " 
	cQuery += " ISNULL(VENDAS.NR_NOTA,0) AS QTD_NF, " 
	cQuery += " ISNULL(VENDAS.PM,0) AS PM      " 
	cQuery += " FROM        " 
	cQuery += "         " 
	cQuery += " (         " 
	cQuery += " SELECT         " 
	cQuery += " FONTE.ANO, FONTE.SEMESTRE, FONTE.MES, FONTE.SEMANA, FONTE.DIA, FONTE.DIA_SEMANA, SUM(FONTE.E1_VALOR) AS E1_VALOR   " 
	cQuery += " ,COUNT(DISTINCT FONTE.E1_NUM+FONTE.E1_SERIE) AS NR_NOTA  " 
	cQuery += " ,SUM(FONTE.PM) AS PM        " 
	cQuery += " FROM         " 
	cQuery += " (         " 
	cQuery += " SELECT         " 
	cQuery += " YEAR(CAST(E1_EMISSAO AS DATE)) AS ANO,      " 
	cQuery += " CASE WHEN MONTH(CAST(E1_EMISSAO AS DATE)) <= 6 THEN '1' ELSE '2' END AS SEMESTRE,     " 
	cQuery += " DATEPART(WEEK,(CAST(E1_EMISSAO AS DATE))) AS SEMANA,      " 
	cQuery += " DATEPART(WEEKDAY,CAST(E1_EMISSAO AS DATE)) AS DIA_SEMANA,     " 
	cQuery += " MONTH(CAST(E1_EMISSAO AS DATE)) AS MES, CASE WHEN E1_MOEDA = '1' THEN E1_VALOR ELSE E1_VLCRUZ END AS E1_VALOR,     " 
	cQuery += " CONVERT(VARCHAR(10),CAST(E1_EMISSAO AS DATE),103) AS DIA,   " 
	cQuery += " E1_NUM,E1_SERIE, " 
	cQuery += " (E1_VALOR * DATEDIFF(DAY,CAST(E1_EMISSAO AS DATE),CAST(E1_VENCREA AS DATE))) AS PM " 
	cQuery += " FROM       " 
	cQuery += " SE1" + cEmpresa + "0 (NOLOCK) AS SE1       " 
	cQuery += " WHERE       " 
	cQuery += " SE1.D_E_L_E_T_ = ''       "

	//
	If lBAnAnt
		cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) >= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))-5) " 
		cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) <= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

	Else		 
		cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) >=  (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))-1) "
		cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) <=  (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

		//cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) =  (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

	EndIf

	cQuery += " AND E1_TIPO = 'NF'       " 
	cQuery += " AND E1_PREFIXO <> 'EEC' "
	cQuery += " ) AS FONTE       " 
	cQuery += " GROUP BY FONTE.ANO, FONTE.SEMESTRE, FONTE.SEMANA, FONTE.MES,  FONTE.DIA ,FONTE.DIA_SEMANA      " 
	cQuery += " ) AS VENDAS       " 
	cQuery += "      " 
	cQuery += " FULL OUTER JOIN     " 
	cQuery += "        " 
	cQuery += " (       " 
	cQuery += " SELECT       " 
	cQuery += " FONTE.ANO, FONTE.SEMESTRE, FONTE.MES, FONTE.SEMANA, FONTE.DIA, FONTE.DIA_SEMANA, SUM(FONTE.E1_VALOR) AS E1_VALOR       " 
	cQuery += " FROM       " 
	cQuery += " (       " 
	cQuery += " SELECT       " 
	cQuery += " YEAR(CAST((CASE WHEN D2_EMISSAO IS NULL THEN E1_EMISSAO ELSE D2_EMISSAO END) AS DATE)) AS ANO,    " //Everson - 16/09/2020. Chamado 1702.
	cQuery += " CASE WHEN MONTH(CAST((CASE WHEN D2_EMISSAO IS NULL THEN E1_EMISSAO ELSE D2_EMISSAO END) AS DATE)) <= 6 THEN '1' ELSE '2' END AS SEMESTRE,   " //Everson - 16/09/2020. Chamado 1702.
	cQuery += " DATEPART(WEEK,(CAST((CASE WHEN D2_EMISSAO IS NULL THEN E1_EMISSAO ELSE D2_EMISSAO END) AS DATE))) AS SEMANA,    " //Everson - 16/09/2020. Chamado 1702.
	cQuery += " DATEPART(WEEKDAY,CAST((CASE WHEN D2_EMISSAO IS NULL THEN E1_EMISSAO ELSE D2_EMISSAO END) AS DATE)) AS DIA_SEMANA,   " //Everson - 16/09/2020. Chamado 1702.
	cQuery += " MONTH(CAST((CASE WHEN D2_EMISSAO IS NULL THEN E1_EMISSAO ELSE D2_EMISSAO END) AS DATE)) AS MES, CASE WHEN E1_MOEDA = '1' THEN E1_VALOR ELSE E1_VLCRUZ END AS E1_VALOR,   " //Everson - 16/09/2020. Chamado 1702.
	cQuery += " CONVERT(VARCHAR(10),CAST((CASE WHEN D2_EMISSAO IS NULL THEN E1_EMISSAO ELSE D2_EMISSAO END) AS DATE),103) AS DIA " //Everson - 16/09/2020. Chamado 1702.
	cQuery += " FROM       " 
	cQuery += " SE1" + cEmpresa + "0 (NOLOCK) AS SE1       " 

	//Everson - 16/09/2020. Chamado 1702.
	cQuery += " INNER JOIN "
	cQuery += " ( "
	cQuery += " SELECT " 
	cQuery += " DISTINCT D1_FILIAL, D1_SERIE, D1_DOC, D1_FORNECE, D1_LOJA, D2_EMISSAO "  
	cQuery += " FROM " 
	cQuery += " SD1" + cEmpresa + "0 (NOLOCK) AS SD1 " 
	cQuery += " INNER JOIN " 
	cQuery += " SD2" + cEmpresa + "0 (NOLOCK) AS SD2 ON "
	cQuery += " D1_FILIAL = D2_FILIAL "
	cQuery += " AND D1_TIPO = 'D' "
	cQuery += " AND D1_NFORI = D2_DOC "
	cQuery += " AND D1_SERIORI = D2_SERIE "
	cQuery += " AND D1_FORNECE = D2_CLIENTE "
	cQuery += " AND D1_LOJA = D2_LOJA "
	cQuery += " WHERE " 
	cQuery += " SD1.D_E_L_E_T_ = '' "
	cQuery += " ) AS SF1 ON "
	cQuery += " E1_FILIAL = D1_FILIAL "
	cQuery += " AND E1_SERIE = D1_SERIE "
	cQuery += " AND E1_NUM = D1_DOC "
	cQuery += " AND E1_CLIENTE = D1_FORNECE "
	cQuery += " AND E1_LOJA = D1_LOJA "
	//

	cQuery += " WHERE       " 
	cQuery += " SE1.D_E_L_E_T_ = ''       " 

	//
	If lBAnAnt
		cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) >= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))-5) " 
		cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) <= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

	Else		 
		cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) >=  (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))-1) "
		cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) <=  (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

		//cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) =  (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

	EndIf

	cQuery += " AND E1_TIPO = 'NCC'       " 
	cQuery += " AND E1_PREFIXO <> 'EEC' "
	cQuery += " ) AS FONTE       " 
	cQuery += " GROUP BY FONTE.ANO, FONTE.SEMESTRE, FONTE.SEMANA, FONTE.MES,  FONTE.DIA ,FONTE.DIA_SEMANA           " 
	cQuery += " ) AS DEV      " 
	cQuery += "       " 
	cQuery += " ON    " 
	cQuery += " VENDAS.ANO = DEV.ANO    " 
	cQuery += " AND VENDAS.SEMESTRE = DEV.SEMESTRE     " 
	cQuery += " AND VENDAS.MES = DEV.MES     " 
	cQuery += " AND VENDAS.SEMANA = DEV.SEMANA   " 
	cQuery += " AND VENDAS.DIA_SEMANA = DEV.DIA_SEMANA   " 

	cQuery += " FULL OUTER JOIN       " 

	cQuery += " (      " 
	cQuery += "  " 
	cQuery += " SELECT       " 
	cQuery += " FONTE.ANO, FONTE.SEMESTRE, FONTE.MES, FONTE.SEMANA, FONTE.DIA, FONTE.DIA_SEMANA, SUM(FONTE.E1_VALOR) AS E1_VALOR     " 
	cQuery += " FROM       " 
	cQuery += " (       " 
	cQuery += " SELECT       " 
	cQuery += " YEAR(CAST(E1_EMISSAO AS DATE)) AS ANO,    " 
	cQuery += " CASE WHEN MONTH(CAST(E1_EMISSAO AS DATE)) <= 6 THEN '1' ELSE '2' END AS SEMESTRE,   " 
	cQuery += " DATEPART(WEEK,(CAST(E1_EMISSAO AS DATE))) AS SEMANA,    " 
	cQuery += " DATEPART(WEEKDAY,CAST(E1_EMISSAO AS DATE)) AS DIA_SEMANA,   " 
	cQuery += " MONTH(CAST(E1_EMISSAO AS DATE)) AS MES, CASE WHEN E1_TIPO = 'NF' THEN (CASE WHEN E1_MOEDA = '1' THEN E1_VALOR ELSE E1_VLCRUZ END)  " 
	cQuery += " ELSE (CASE WHEN E1_MOEDA = '1' THEN E1_VALOR ELSE E1_VLCRUZ END) *-1 END AS E1_VALOR,   " 
	cQuery += " CONVERT(VARCHAR(10),CAST(E1_EMISSAO AS DATE),103) AS DIA        " 
	cQuery += " FROM       " 
	cQuery += " SE1" + cEmpresa + "0 (NOLOCK) AS SE1    " 
	cQuery += " INNER JOIN   " 
	cQuery += " SA1" + cEmpresa + "0  (NOLOCK) AS SA1   " 
	cQuery += " ON E1_CLIENTE = A1_COD   " 
	cQuery += " AND E1_LOJA = A1_LOJA      " 
	cQuery += " WHERE       " 
	cQuery += " SE1.D_E_L_E_T_ = ''    " 
	cQuery += " AND SA1.D_E_L_E_T_ = ''      " 

	//
	If lBAnAnt
		cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) >= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))-5) " 
		cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) <= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

	Else		 
		cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) >=  (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))-1) "
		cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) <=  (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

		//cQuery += " AND YEAR(CAST(E1_EMISSAO AS DATE)) =  (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

	EndIf

	cQuery += " AND E1_TIPO IN ('NF','NCC')     " 
	cQuery += " AND E1_PREFIXO <> 'EEC' "
	cQuery += " AND SUBSTRING(RTRIM(LTRIM(A1_CGC)),1,10) IN ( "  + cCNPJs +  " ) " 
	cQuery += " ) AS FONTE       " 
	cQuery += " GROUP BY FONTE.ANO, FONTE.SEMESTRE, FONTE.SEMANA, FONTE.MES,  FONTE.DIA ,FONTE.DIA_SEMANA        " 
	cQuery += "  " 
	cQuery += " ) AS INTERCIA       " 

	cQuery += " ON    " 
	cQuery += " VENDAS.ANO = INTERCIA.ANO    " 
	cQuery += " AND VENDAS.SEMESTRE = INTERCIA.SEMESTRE     " 
	cQuery += " AND VENDAS.MES = INTERCIA.MES     " 
	cQuery += " AND VENDAS.SEMANA = INTERCIA.SEMANA   " 
	cQuery += " AND VENDAS.DIA_SEMANA = INTERCIA.DIA_SEMANA   " 
	cQuery += " ) AS REL     " 

	//
	If lMesAtu
		cQuery += " WHERE "
		cQuery += " REL.MES = " + cValToChar(Month(dDateAnt)) + " "
		cQuery += " AND REL.ANO = " + cValToChar(Year(dDateAnt)) + " "

	EndIf

	cQuery += " GROUP BY     " 
	cQuery += " REL.ANO, REL.SEMESTRE,   " 
	cQuery += " REL.MES, REL.SEMANA, REL.DIA, REL.DIA_SEMANA   "  

	//
	RestArea(aArea)

Return cQuery
/*/{Protheus.doc} rn_scriptVdDi
	Script faturamento líquido vendas diárias do ano RNX2. Chamado 035788. 
	@type  Static Function
	@author Everson
	@since 10/07/2017
	@version 01
	/*/
Static Function rn_scriptVdDi(lMesAtu,lBAnAnt)

	//Variáveis.	
	Local aArea		:= GetArea()
	Local cCNPJs	:= getCNPJ()
	Local cQuery	:= ""

	Default lBAnAnt	:= .F.

	//
	cQuery := ""
	cQuery += " SELECT     " 
	cQuery += " REL.ANO, REL.SEMESTRE,     " 
	cQuery += " REL.MES, REL.SEMANA, REL.DIA, REL.DIA_SEMANA,     " 
	cQuery += " SUM(REL.VENDAS)/1000   AS VENDAS,     " 
	cQuery += " SUM(REL.DEV)/1000      AS DEV,     " 
	cQuery += " SUM(REL.INTERCIA)/1000 AS INTERCIA,     " 
	cQuery += " SUM(REL.FAT_LIQ)/1000  AS FAT_LIQ     " 
	cQuery += " ,SUM( REL.QTD_NF) AS QTD_NF " 
	cQuery += " , SUM(REL.PM) AS PM      " 
	cQuery += " FROM      " 
	cQuery += " (     " 
	cQuery += " SELECT         " 
	cQuery += " ISNULL(VENDAS.ANO,ISNULL(DEV.ANO,INTERCIA.ANO)) AS ANO,     " 
	cQuery += " ISNULL(VENDAS.SEMESTRE,ISNULL(DEV.SEMESTRE,INTERCIA.SEMESTRE)) AS SEMESTRE,     " 
	cQuery += " ISNULL(VENDAS.MES,ISNULL(DEV.MES,INTERCIA.MES)) AS MES,     " 
	cQuery += " ISNULL(VENDAS.SEMANA,ISNULL(DEV.SEMANA,INTERCIA.SEMANA)) AS SEMANA,     " 
	cQuery += " ISNULL(VENDAS.DIA,ISNULL(DEV.DIA,INTERCIA.DIA)) AS DIA,     " 
	cQuery += " ISNULL(VENDAS.DIA_SEMANA,ISNULL(DEV.DIA_SEMANA,INTERCIA.DIA_SEMANA)) AS DIA_SEMANA,     " 
	cQuery += " ISNULL(VENDAS.E1_VALOR,0) AS VENDAS,     " 
	cQuery += " ISNULL(DEV.E1_VALOR,0) AS DEV,     " 
	cQuery += " ISNULL(INTERCIA.E1_VALOR,0) AS INTERCIA,     " 
	cQuery += " (ISNULL(VENDAS.E1_VALOR,0) - ISNULL(DEV.E1_VALOR,0) - ISNULL(INTERCIA.E1_VALOR,0)) AS FAT_LIQ,   " 
	cQuery += " ISNULL(VENDAS.NR_NOTA,0) AS QTD_NF, " 
	cQuery += " ISNULL(VENDAS.PM,0) AS PM    " 
	cQuery += " FROM         " 
	cQuery += " (         " 
	cQuery += " SELECT         " 
	cQuery += " FONTE.ANO, FONTE.SEMESTRE, FONTE.MES, FONTE.SEMANA, FONTE.DIA, FONTE.DIA_SEMANA, SUM(FONTE.Valor) AS E1_VALOR,    " 
	cQuery += " COUNT(DISTINCT FONTE.Nota+FONTE.Serie) AS NR_NOTA, SUM(FONTE.PM) AS PM       " 
	cQuery += " FROM         " 
	cQuery += " (     " 

	cQuery += " SELECT " 
	cQuery += " DISTINCT YEAR(CAST(Emissao AS DATE))  AS ANO,      " 
	cQuery += " MONTH(CAST(Emissao AS DATE)) AS MES,       " 
	cQuery += " CASE WHEN MONTH(CAST(Emissao AS DATE)) <= 6 THEN '1' ELSE '2' END AS SEMESTRE,       " 
	cQuery += " DATEPART(WEEK,(CAST(Emissao AS DATE))) AS SEMANA,        " 
	cQuery += " DATEPART(WEEKDAY,CAST(Emissao AS DATE)) AS DIA_SEMANA,       " 
	cQuery += " CONVERT(VARCHAR(10),CAST(Emissao AS DATE),103) AS DIA,       " 
	cQuery += " [Total Nota] AS Valor,   " 
	cQuery += " Nota, Serie, " 
	cQuery += " (DATEDIFF(DAY,Emissao,Vencimento)) AS DT_DIF, " 
	cQuery += " Valor * (DATEDIFF(DAY,Emissao,Vencimento)) AS PM      " 
	cQuery += " FROM          " 
	cQuery += " SCSRV03.SAG.dbo.VW_RNX_NOTAS AS VW          " 
	cQuery += " WHERE "
	cQuery += " SUBSTRING(RTRIM(LTRIM([Tipo Nota])),1,1) = 'S' "
	cQuery += " AND CFOP IN (1101, 1102, 1201, 2201, 5101, 5118, 5201, 6101, 6107, 6118, 5102, 5122 ) "

	//
	If lBAnAnt
		cQuery += " AND YEAR(CAST(Emissao AS DATE)) >= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))-5) " 
		cQuery += " AND YEAR(CAST(Emissao AS DATE)) <= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

	Else		 
		cQuery += " AND YEAR(CAST(Emissao AS DATE)) >=  (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))-1) "
		cQuery += " AND YEAR(CAST(Emissao AS DATE)) <=  (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

		//cQuery += " AND YEAR(CAST(Emissao AS DATE)) =  (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

	EndIf

	cQuery += " AND Situação <> 'CANCELADA' "	
	cQuery += " ) AS FONTE         " 
	cQuery += " GROUP BY         " 
	cQuery += " FONTE.ANO, FONTE.SEMESTRE, FONTE.MES, FONTE.SEMANA, FONTE.DIA, FONTE.DIA_SEMANA     " 
	cQuery += " ) AS VENDAS  " 
	cQuery += "        " 
	cQuery += " FULL OUTER JOIN       " 
	cQuery += " (       " 
	cQuery += " SELECT       " 
	cQuery += " FONTE.ANO, FONTE.SEMESTRE, FONTE.MES, FONTE.SEMANA, FONTE.DIA, FONTE.DIA_SEMANA, SUM(FONTE.Valor) AS E1_VALOR        " 
	cQuery += " FROM       " 
	cQuery += " (   " 

	cQuery += " SELECT " 
	cQuery += " DISTINCT YEAR(CAST(Emissao AS DATE))  AS ANO,      " 
	cQuery += " MONTH(CAST(Emissao AS DATE)) AS MES,       " 
	cQuery += " CASE WHEN MONTH(CAST(Emissao AS DATE)) <= 6 THEN '1' ELSE '2' END AS SEMESTRE,       " 
	cQuery += " DATEPART(WEEK,(CAST(Emissao AS DATE))) AS SEMANA,        " 
	cQuery += " DATEPART(WEEKDAY,CAST(Emissao AS DATE)) AS DIA_SEMANA,       " 
	cQuery += " CONVERT(VARCHAR(10),CAST(Emissao AS DATE),103) AS DIA,       " 
	cQuery += " [Total Nota] AS Valor,   " 
	cQuery += " Nota, Serie, " 
	cQuery += " (DATEDIFF(DAY,Emissao,Vencimento)) AS DT_DIF, " 
	cQuery += " Valor * (DATEDIFF(DAY,Emissao,Vencimento)) AS PM      " 
	cQuery += " FROM          " 
	cQuery += " SCSRV03.SAG.dbo.VW_RNX_NOTAS AS VW          " 
	cQuery += " WHERE "
	cQuery += " SUBSTRING(RTRIM(LTRIM([Tipo Nota])),1,2) = 'DS' "
	cQuery += " AND CFOP IN (1101, 1102, 1201, 2201, 5101, 5118, 5201, 6101, 6107, 6118, 5102, 5122 ) "

	//
	If lBAnAnt
		cQuery += " AND YEAR(CAST(Emissao AS DATE)) >= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))-5) " 
		cQuery += " AND YEAR(CAST(Emissao AS DATE)) <= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

	Else		 
		cQuery += " AND YEAR(CAST(Emissao AS DATE)) >=  (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))-1) "
		cQuery += " AND YEAR(CAST(Emissao AS DATE)) <=  (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

		//cQuery += " AND YEAR(CAST(Emissao AS DATE)) =  (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

	EndIf

	cQuery += " AND Situação <> 'CANCELADA' "	
	cQuery += " ) AS FONTE       " 
	cQuery += " GROUP BY       " 
	cQuery += " FONTE.ANO, FONTE.SEMESTRE, FONTE.MES, FONTE.SEMANA, FONTE.DIA, FONTE.DIA_SEMANA   " 
	cQuery += " ) AS DEV       " 
	cQuery += " ON VENDAS.ANO = DEV.ANO   " 
	cQuery += " AND VENDAS.SEMESTRE = DEV.SEMESTRE   " 
	cQuery += " AND VENDAS.MES = DEV.MES   " 
	cQuery += " AND VENDAS.SEMANA = DEV.SEMANA   " 
	cQuery += " AND VENDAS.DIA_SEMANA = DEV.DIA_SEMANA      " 
	cQuery += "         " 
	cQuery += " FULL OUTER JOIN       " 
	cQuery += " (       " 
	cQuery += " SELECT       " 
	cQuery += " FONTE.ANO, FONTE.SEMESTRE, FONTE.MES, FONTE.SEMANA, FONTE.DIA, FONTE.DIA_SEMANA, SUM(FONTE.Valor) AS E1_VALOR        " 
	cQuery += " FROM       " 
	cQuery += " (   " 

	cQuery += " SELECT " 
	cQuery += " DISTINCT YEAR(CAST(Emissao AS DATE))  AS ANO,      " 
	cQuery += " MONTH(CAST(Emissao AS DATE)) AS MES,       " 
	cQuery += " CASE WHEN MONTH(CAST(Emissao AS DATE)) <= 6 THEN '1' ELSE '2' END AS SEMESTRE,       " 
	cQuery += " DATEPART(WEEK,(CAST(Emissao AS DATE))) AS SEMANA,        " 
	cQuery += " DATEPART(WEEKDAY,CAST(Emissao AS DATE)) AS DIA_SEMANA,       " 
	cQuery += " CONVERT(VARCHAR(10),CAST(Emissao AS DATE),103) AS DIA,       " 
	cQuery += " CASE WHEN SUBSTRING([Tipo Nota],1,1) = 'S' THEN Valor ELSE Valor*-1 END AS Valor ,   " 
	cQuery += " Nota, Serie, " 
	cQuery += " (DATEDIFF(DAY,Emissao,Vencimento)) AS DT_DIF, " 
	cQuery += " Valor * (DATEDIFF(DAY,Emissao,Vencimento)) AS PM      " 
	cQuery += " FROM          " 
	cQuery += " SCSRV03.SAG.dbo.VW_RNX_NOTAS AS VW          " 
	cQuery += " WHERE "
	cQuery += " RTRIM(LTRIM(SUBSTRING(RTRIM(LTRIM([Tipo Nota])),1,2))) IN ('S','DS') "
	cQuery += " AND CFOP IN (1101, 1102, 1201, 2201, 5101, 5118, 5201, 6101, 6107, 6118, 5102, 5122 ) "

	//
	If lBAnAnt
		cQuery += " AND YEAR(CAST(Emissao AS DATE)) >= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))-5) " 
		cQuery += " AND YEAR(CAST(Emissao AS DATE)) <= (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

	Else		 
		cQuery += " AND YEAR(CAST(Emissao AS DATE)) >=  (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))-1) "
		cQuery += " AND YEAR(CAST(Emissao AS DATE)) <=  (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

		//cQuery += " AND YEAR(CAST(Emissao AS DATE)) =  (YEAR(CAST('" + DToS(dDateAnt) + "' AS DATE))) "

	EndIf

	cQuery += " AND Situação <> 'CANCELADA' "
	cQuery += " AND SUBSTRING(RTRIM(LTRIM(Cnpj)),1,10) IN (  " + cCNPJs + "  )  " 	
	cQuery += " ) AS FONTE       " 
	cQuery += " GROUP BY       " 
	cQuery += " FONTE.ANO, FONTE.SEMESTRE, FONTE.MES, FONTE.SEMANA, FONTE.DIA, FONTE.DIA_SEMANA   " 
	cQuery += " ) AS INTERCIA       " 
	cQuery += " ON VENDAS.ANO = INTERCIA.ANO   " 
	cQuery += " AND VENDAS.SEMESTRE = INTERCIA.SEMESTRE   " 
	cQuery += " AND VENDAS.MES = INTERCIA.MES   " 
	cQuery += " AND VENDAS.SEMANA = INTERCIA.SEMANA   " 
	cQuery += " AND VENDAS.DIA_SEMANA = INTERCIA.DIA_SEMANA    " 
	cQuery += " ) AS REL   " 

	//
	If lMesAtu
		cQuery += " WHERE "
		cQuery += " REL.MES = " + cValToChar(Month(dDateAnt)) + " "
		cQuery += " AND REL.ANO = " + cValToChar(Year(dDateAnt)) + " "

	EndIf

	cQuery += " GROUP BY   " 
	cQuery += " REL.ANO, REL.SEMESTRE,    " 
	cQuery += " REL.MES, REL.SEMANA, REL.DIA, REL.DIA_SEMANA " 

	//
	RestArea(aArea)

Return cQuery
/*/{Protheus.doc} getCNPJ
	Obtém CNPJ das empresas. Chamado 035788. 
	@type  Static Function
	@author Everson
	@since 06/07/2017
	@version 01
	/*/
Static Function getCNPJ()

	//Variáveis.		
	Local aArea		:= GetArea()
	Local cCNPJs 	:= Alltrim(cValToChar(GetMv("MV_#CNPJRE",,"")))

	//cCNPJs := "6003705800,0209038400,1209767200,2005254100"
	If Len(cCNPJs) > 0 .And. Substr(cCNPJs,Len(cCNPJs)-1,1) == ","
		cCNPJs := Substr(cCNPJs,Len(cCNPJs)-1)

	EndIf

	cCNPJs := "'" + StrTran(cCNPJs,",","','") + "'"

	//
	RestArea(aArea)

Return cCNPJs
/*/{Protheus.doc} envEmail
	Envia e-mail. Chamado 035788. 
	@type  Static Function
	@author Everson
	@since 23/06/2017
	@version 01
	/*/
Static Function envEmail(cAssunto,cMensagem,cEmail,cAtach)

	//Variáveis.
	Local aArea			 := GetArea()
	Local lOk           := .T.
	Local cBody         := cMensagem
	Local cErrorMsg     := ""
	Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
	Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
	Local cFrom         := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
	Local cTo           := cEmail
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

	RestArea(aArea)

Return Nil
/*/{Protheus.doc} logZBN
	Log Job. Chamado 035788.
	@type  Static Function
	@author Everson
	@since 06/07/2017
	@version 01
	/*/
Static Function logZBN(cStatus)

	//Variáveis.
	Local aArea	:= GetArea()

	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADFIN037R'))

		RecLock("ZBN",.F.)

		ZBN_FILIAL  := xFilial("ZBN")
		ZBN_ROTINA	:= 'ADFIN037R'
		ZBN_DESCRI  := 'Relatório/rotina no Protheus para substituir a planilha Faturamento'
		ZBN_DATA    := dDataBase
		ZBN_HORA    := TIME()
		ZBN_PERIOD  := '1'
		ZBN_PERDES  := 'DIA'
		ZBN_QTDVEZ  := 1
		ZBN_HORAIN  := '08:00:00'
		ZBN_DATAPR  := dDataBase + 1
		ZBN_HORAPR  := '08:00:00'
		ZBN_STATUS	:= cStatus

		MsUnlock() 

	Else

		RecLock("ZBN",.T.)

		ZBN_FILIAL  := xFilial("ZBN")
		ZBN_ROTINA	:= 'ADFIN037R'
		ZBN_DESCRI  := 'Relatório/rotina no Protheus para substituir a planilha Faturamento'
		ZBN_DATA    := dDataBase
		ZBN_HORA    := TIME()
		ZBN_PERIOD  := '1'
		ZBN_PERDES  := 'DIA'
		ZBN_QTDVEZ  := 1
		ZBN_HORAIN  := '08:00:00'
		ZBN_DATAPR  := dDataBase + 1
		ZBN_HORAPR  := '08:00:00'
		ZBN_STATUS	:= cStatus

		MsUnlock() 	

	EndIf

	ZBN->(dbCloseArea())

	RestArea(aArea)

Return Nil
/*/{Protheus.doc} carArq
	Carrega arquivos texto. Chamado 035788.
	@type  Static Function
	@author Everson
	@since 15/01/2019
	@version 01
	/*/
Static Function carArq(cHtml,nHdl,cArquivo)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local cBuffer	:= ""
	Local cHrIni	:= Time()

	Private cEOL    := Chr(13) + Chr(10)
	Private nBuffer := 1000
	Private nFilePos:= 1000
	Private nPos    := 0
	Private cLine   := ""

	//
	nFilePos := FSeek(nHdl, 0, 0)   
	cBuffer  := Space(nBuffer)                   
	nRead    := FRead(nHdl, cBuffer, nBuffer)    
	nPos     := At(cEOL, cBuffer)                 

	//
	While !(nRead == 0)

		//
		While (nPos == 0)                           
			nBuffer  += 1000                             
			cBuffer  := Space(nBuffer)                   
			nFilePos := FSeek(nHdl, nFilePos, 0)       
			nRead    := FRead(nHdl, cBuffer, nBuffer)     
			nPos     := At(cEOL, cBuffer)
			                  
		End

		cLine := Substr(cBuffer, 0, nPos)

		If ! Empty(cLine)
			cHtml += cLine

		EndIf

		//
		cBuffer  := Space(nBuffer)             
		nFilePos += nPos + 1                    
		nFilePos := FSeek(nHdl, nFilePos, 0)  
		nRead    := FRead(nHdl, cBuffer, nBuffer)
		nPos     := At(cEOL, cBuffer)   

	End

	//
	FClose(nHdl)
	
	Conout("ADVFIN037R - Carregou arquivo temporário " + cArquivo + " " + ElapTime ( cHrIni , Time() ) )
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} WsRestFul relatoriofaturamento
	Serviço Rest para resumo do relatório de faturamento. Chamado 046278.
	@type  Function
	@author Everson
	@since 15/01/2019
	@version 01
	/*/
WsRestFul relatoriofaturamento Description "Serviço REST para consulta do resumo do relatório de faturamento - ADFIN037R."

	WsMethod Get Description "Retorna resumo do relatório de faturamento - ADFIN037R"   WsSyntax "/relatoriofaturamento"

End WsRestFul
/*/{Protheus.doc} WsMethod Get
	Implementação do método Get. 
	@type  Function
	@author Everson
	@since 06/07/2017
	@version 01
	/*/
WsMethod Get WsService relatoriofaturamento

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea			:= GetArea()
	Local cFormatAceito	:= "application/json"
	Local cFormato		:= Alltrim(cValToChar(Self:GetAccept()))
	Local cResJson		:= ""
	Local cCodUsuario	:= Self:GetHeader("UsrVend")

	//
	Self:SetContentType(cFormatAceito)

	//
	If Empty(cCodUsuario)
		SetRestFault(403,EncodeUtf8("Código de usuário não informado (UsrVend)."))
		RestArea(aArea)
		Return .F.

	EndIf

	//Atribui usuário.
	__cUserId := cCodUsuario

	//
	If cFormato <> cFormatAceito
		SetRestFault(400,EncodeUtf8("Formato de dados " + cFormato + ", no Accept do cabeçalho da requisição, não suportado."))
		RestArea(aArea)
		Return .F.

	EndIf

	//
	cResJson := relJson()

	//
	Self:SetResponse(EncodeUtf8(cResJson))

	//
	RestArea(aArea)

Return .T.
/*/{Protheus.doc} relJson
	Função retorna Json do relatório. Chamado 046278.
	@type  Static Function
	@author Everson
	@since 15/01/2019
	@version 01
	/*/
Static Function relJson()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea			:= GetArea()
	Local cResJson		:= ""

	//
	cResJson := montaJson()

	//
	RestArea(aArea)

Return cResJson
