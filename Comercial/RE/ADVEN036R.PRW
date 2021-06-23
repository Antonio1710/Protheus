#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"
#Include "Tbiconn.ch"
#Include "Fileio.ch"

/*{Protheus.doc} User Function ADVEN036R
	Relatório análise de cliente sem compra por período
	@type  Function
	@author Everson
	@since 10/11/2016
	@version 01
	@history Chamado 057769 - William Costa - 05/05/2020 - 1-) Repetindo muito os clientes - ok 2-)Vc ta perguntando, consegue trazer também as coisas do supervisor. hoje aparece só o vendedor. - ok 3-) Coluna F segmento do cliente, esta vindo vazia, ver pq está vazio sendo que SA1 tem valor. - ok 4-) Adicionar o campo Categoria do cliente - ok 5-) Onde traz a descrição do motivo trazer o numero + descrição. = ok
*/

User Function ADVEN036R() // U_ADVEN036R()

	Local cPerg	:= "ADVEN036R"
	
	Private lDiret := .F.
	Private lGerent:= .F.
	Private lSuperv:= .F.
	Private lVended:= .F.
	Private cCodigo:= ""
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatório análise de cliente sem compra por período.')
	
	logAcesso("ADVEN036R")
	
	DbSelectArea("SA3")
	SA3->(DbSetOrder(7))
	SA3->(DbGoTop())
	
	If Dbseek(xFilial("SA3") + Alltrim(cValToChar(__cUserID)))
	
	   If SA3->A3_NIVETAB == "4"
	      lDiret := .T.
	      
	   Elseif SA3->A3_NIVETAB == "3"
	      lGerent := .T.
	      cCodigo := SA3->A3_COD
	      
	   Elseif SA3->A3_NIVETAB == "2"
	      lSuperv := .T.
	      cCodigo := SA3->A3_CODSUP
	      
	   Else
	      lVended := .T.
	      cCodigo := SA3->A3_COD  
	            
	   Endif
	   
	Else
	   MsgStop("Seu usuário não possui cadastro na tabela de vendedores e não poderá emitir este relatório.","Função ADVEN036R")
	   Return Nil
	   
	Endif

	//Cria pergunta no SX1.
	criarPergunta(cPerg)

	//Executa a pergunta.
	If ! Pergunte(cPerg,.T.)
		Return Nil

	EndIf

	//Gera o relatório.
	MsAguarde({||relatorio()},"Aguarde","Gerando relatório...")	

Return Nil

/*{Protheus.doc} Static Function relatorio
	Processa o relatório
	@type  Function
	@author Everson
	@since 10/11/2016
	@version 01
*/

Static Function relatorio()	

	Local folder		:= "C:\temp\"
	Local arq			:= "Analise_Cliente_Sem_Compra.html"
	Local nHandle		
	Local cPulaLin	:= Chr(13) + Chr(10)
	Local aDados		:= {}

	Private cPerDe		:= ""
	Private cPerAte		:= ""
	Private cPerEntre	:= ""

	//
	cPerAte	:= Alltrim(cValToChar(MV_PAR01))
	cPerAte	:= Substr(cPerAte,3,4) + Substr(cPerAte,1,2)

	cPerDe 	:= DToS(MonthSub(SToD(cPerAte+"01"),2))
	cPerDe		:= Substr(cPerDe,1,4) + Substr(cPerDe,5,2)

	cPerEntre	:= DToS(MonthSub(SToD(cPerAte+"01"),1))
	cPerEntre	:= Substr(cPerEntre,1,4) + Substr(cPerEntre,5,2)

	//Obtém dados do relatório.
	MsAguarde({||aDados := dadosRel(cPerDe,cPerAte)},"Aguarde","Obtendo dados...")

	//Valida retorno da função dadosRel().
	If Len(aDados) <= 0
		MsgStop("Não há dados para os parâmetros informados.","Função relatorio")
		Return NIl

	EndIf

	//Cria arquivo.
	nHandle		:= FCreate(Alltrim(folder)+arq, FC_NORMAL)

	//Valida se foi possível criar o arquivo.
	If nHandle == -1      
		MsgStop('Erro de abertura de arquivo : ' + cPulaLin + 'FERROR ' + cValToChar(ferror(),4),"Função relatorio")	
		Return Nil

	Endif 

	//String HTML.
	MsAguarde({||gerarHtml(nHandle,aDados,cPerDe,cPerEntre,cPerAte)},"Aguarde","Gerando HTML...")

	//Fecha arquivo. 
	FClose(nHandle)

	//Executa programa padrão para abertura de arquivo HTML.
	MsAguarde({||shellExecute("Open", "C:\temp\Analise_Cliente_Sem_Compra.html", "NULL", "C:\",3)},"Aguarde","Abrindo relatório...")

	//
	MsgInfo("Relatório gerado.","Função relatorio")

Return Nil

/*{Protheus.doc} Static Function montarHtml
	Monta HTML
	@type  Function
	@author Everson
	@since 10/11/2016
	@version 01
*/

Static Function gerarHtml(nHandle,aDados,cPerDe,cPerEntre,cPerAte)

	Local cHtml		:= ""
	Local i			:= 1
	Local cDesc1	:= ""
	Local cDesc2	:= ""
	Local cDesc3	:= ""
	Local nPos		:= 0
	Local aOrdenado	:= {}
	Local cObserva	:= ""
	Local cUltComp	:= ""
	Default aDados	:= {}

	cDesc1 := Substr(cPerDe,5,2) + "/" + Substr(cPerDe,1,4)
	cDesc2 := Substr(cPerEntre,5,2) + "/" + Substr(cPerEntre,1,4)
	cDesc3 := Substr(cPerAte,5,2) + "/" + Substr(cPerAte,1,4)

	//
	/*	For i := 1 To Len(aDados)

	nPos := Ascan(aOrdenado,{|x| Alltrim(cValToChar(x[1])) == Alltrim(cValToChar(aDados[i][9]))})

	If nPos == 0
	aOrdenado


	Else

	EndIf

	Next i*/

	cHtml += ' <!DOCTYPE html> '
	cHtml += ' <html> '
	cHtml += ' <head> '
	cHtml += ' <meta charset="UTF-8"> '
	cHtml += ' <link rel="stylesheet" type="text/css" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"> '
	cHtml += ' <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/colreorder/1.3.2/css/colReorder.bootstrap.css"> '
	cHtml += ' <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/colreorder/1.3.2/css/colReorder.bootstrap.min.css"> '
	cHtml += ' <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/colreorder/1.3.2/css/colReorder.bootstrap4.css"> '
	cHtml += ' <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/colreorder/1.3.2/css/colReorder.bootstrap4.min.css"> '
	cHtml += ' <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/colreorder/1.3.2/css/colReorder.dataTables.css"> '
	cHtml += ' <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/colreorder/1.3.2/css/colReorder.dataTables.min.css"> '
	cHtml += ' <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/colreorder/1.3.2/css/colReorder.foundation.css"> '
	cHtml += ' <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/colreorder/1.3.2/css/colReorder.foundation.min.css"> '
	cHtml += ' <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/colreorder/1.3.2/css/colReorder.jqueryui.css"> '
	cHtml += ' <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/colreorder/1.3.2/css/colReorder.jqueryui.min.css"> '
	cHtml += ' <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/colreorder/1.3.2/css/colReorder.semanticui.css"> '
	cHtml += ' <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/colreorder/1.3.2/css/colReorder.semanticui.min.css"> '
	cHtml += ' <style> '
	cHtml += ' html{width:95%; '
	cHtml += ' margin-left: auto; '
	cHtml += ' margin-right: auto;} '
	cHtml += ' </style> '
	cHtml += ' </head> '
	cHtml += ' <body> '
	cHtml += ' <div class="container-fluid"> '
	cHtml += ' <h3>Analise de Cliente sem Compra</h3> '

	cHtml += ' <table> '
	cHtml += ' <thead> '
	cHtml += ' </thead> '
	cHtml += ' <tbody> '

	cHtml += ' <tr> '
	cHtml += ' <td>Usuario:</td> '
	cHtml += ' <td>' + cUserName + '</td> '
	cHtml += ' </tr> '

	cHtml += ' <tr> '
	cHtml += ' <td>Data: ' + DToC(Date()) + ' </td> '
	cHtml += ' <td> | Hora: ' + cValToChar(Time()) + '</td> '
	cHtml += ' </tr> '

	cHtml += ' <tr> '
	cHtml += ' <td><input type="button" value="Exportar" id="btnExportar"></td>'
	cHtml += ' </tr> '

	cHtml += ' </tbody> '
	cHtml += ' </table> '

	cHtml += ' <table id="dadosTabela" class="table table-responsive table-striped table-bordered"> '
	cHtml += ' <thead> '
	cHtml += ' <tr> '
	cHtml += ' <td>Vend.</td> '
	cHtml += ' <td>Superv</td> '
	cHtml += ' <td>Cod.</td> '
	cHtml += ' <td>Loja</td> '
	cHtml += ' <td>Rede</td> '
	cHtml += ' <td>Razao Social</td> '
	cHtml += ' <td>Segmento1</td> '
	cHtml += ' <td>Segmento2</td> '
	cHtml += ' <td>Dat. Ult. Comp.</td> '
	cHtml += ' <td>' + cDesc1 + '</td> '
	cHtml += ' <td>' + cDesc2 + '</td> '
	cHtml += ' <td>' + cDesc3 + '</td> '
	cHtml += ' <td>Obs</td> '
	cHtml += ' </tr> '
	cHtml += ' </thead> '
	cHtml += ' <tbody> '

	//Salva relatório e limpa variável.
	FWrite(nHandle,cHtml)
	cHtml := ""

	//
	i := 1
	lAux := .T.

	//
	While i <= Len(aDados)

		If lAux

			cPer1 := ""
			cPer2 := ""
			cPer3 := ""

			//Obtém o código do cliente.
			cCliente :=  Alltrim(cValToChar(aDados[i][3])) + Alltrim(cValToChar(aDados[i][4]))

			cUltComp := Alltrim(cValToChar(Posicione("SA1",1,xFilial("SA1") + Alltrim(cValToChar(aDados[i][3])) + Alltrim(cValToChar(aDados[i][4])),"A1_ULTCOM")))

			If ! Empty(cUltComp)
				cUltComp := DToC(CToD(cUltComp))

			EndIf

			cHtml += ' <tr> '
			cHtml += ' <td>' + cValToChar(aDados[i][1]) + '</td> '
			cHtml += ' <td>' + cValToChar(aDados[i][2]) + '</td> '
			cHtml += ' <td>' + cValToChar(aDados[i][3]) + '</td> '
			cHtml += ' <td>' + cValToChar(aDados[i][4]) + '</td> '
			cHtml += ' <td>' + cValToChar(aDados[i][10]) + '</td> '
			cHtml += ' <td>' + cValToChar(aDados[i][5]) + '</td> '
			cHtml += ' <td>' + cValToChar(aDados[i][11]) +'</td> '
			cHtml += ' <td>' + cValToChar(aDados[i][12]) +'</td> '
			cHtml += ' <td>' + cUltComp +'</td> '

			lAux := .F.

		EndIf 

		//
		If Alltrim(cValToChar(aDados[i][9])) == cPerDe
			cPer1 := cValToChar(aDados[i][8])

		ElseIf Alltrim(cValToChar(aDados[i][9])) == cPerEntre
			cPer2 := cValToChar(aDados[i][8])

		ElseIf Alltrim(cValToChar(aDados[i][9])) == cPerAte
			cPer3    := cValToChar(aDados[i][8])
			cObserva := cValToChar(aDados[i][13])		

		EndIf

		//
		i++

		//
		If i >  Len(aDados) .Or. cCliente <>  Alltrim(cValToChar(aDados[i][3])) + Alltrim(cValToChar(aDados[i][4]))

			cHtml += ' <td>' + cPer1 + '</td> '
			cHtml += ' <td>' + cPer2 + '</td> '
			cHtml += ' <td>' + cPer3 + '</td> '
			cHtml += ' <td>' + cObserva + '</td> '

			cHtml += ' </tr> '

			lAux := .T.

			//Salva relatório e limpa variável.
			FWrite(nHandle,cHtml)
			cHtml := ""

		EndIf

		//
		if i > Len(aDados)
			Exit

		EndIf

	EndDo

	cHtml += ' </tbody> ' 
	cHtml += ' </table> '
	cHtml += ' </div> '
	cHtml += ' <script src="https://code.jquery.com/jquery-3.1.1.min.js"></script> '
	cHtml += ' <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script> '
	cHtml += ' <script src="https://cdn.datatables.net/1.10.12/js/jquery.dataTables.min.js"></script> '
	cHtml += ' <script src="https://cdn.datatables.net/1.10.12/js/dataTables.bootstrap.min.js"></script> '
	cHtml += ' <script src="https://cdn.datatables.net/colreorder/1.3.2/js/dataTables.colReorder.js"></script> '
	cHtml += ' <script src="https://cdn.datatables.net/colreorder/1.3.2/js/dataTables.colReorder.min.js"></script> '
	cHtml += scriptCSV()
	cHtml += ' </body> '
	cHtml += ' <html> '

	//Salva relatório e limpa variável.
	FWrite(nHandle,cHtml)
	cHtml := ""

Return Nil

/*{Protheus.doc} Static Function dadosRel
	Obtém dados dos relatório.
	@type  Function
	@author Everson
	@since 10/11/2016
	@version 01
*/

Static function dadosRel(cPerDe,cPerAte)

	Local cQuery	:= ""
	Local aRetorno	:= {}
	Local cObsevacao:= ""

	//Monta script sql.
	cQuery += " SELECT DISTINCT * " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " ZBI_VEND,ZBI_CODCLI, ZBI_LOJA, A1_NOME, ZBI_PERIOD, ZBI_MOTIVO, RTRIM(MOTIVO.X5_CHAVE) + '-' + MOTIVO.X5_DESCRI AS MOTIVO, ZBI.R_E_C_N_O_ AS REC, " 
	cQuery += " SUBSTRING(ZBI_PERIOD,3,4)+SUBSTRING(ZBI_PERIOD,1,2) AS PERIODO, ZBI_CODSUP AS SUPER, A1_REDE AS REDE, LTRIM(RTRIM(SEGMENTO1.SEG)) AS SEGMENTO1,LTRIM(RTRIM(SEGMENTO2.SEG)) AS SEGMENTO2, A1_CGC, ISNULL(CONVERT(VARCHAR(MAX),SUBSTRING(ZBI_OBS,1,8000)),'') AS OBS  " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZBI") + " AS ZBI INNER JOIN " 
	cQuery += " " + RetSqlName("SA1") + "  AS SA1 ON " 
	cQuery += " ZBI_CODCLI   = A1_COD "
	cQuery += " AND ZBI_LOJA = A1_LOJA " //chamado 057769
	cQuery += " LEFT OUTER JOIN  " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " X5_CHAVE, X5_DESCRI " 
	cQuery += " FROM " 
	cQuery += "  " + RetSqlName("SX5") + "  AS SX5 " 
	cQuery += " WHERE " 
	cQuery += " SX5.D_E_L_E_T_ = '' " 
	cQuery += " AND X5_TABELA = 'ZY' " 
	cQuery += " ) AS MOTIVO ON " 
	cQuery += " ZBI_MOTIVO = MOTIVO.X5_CHAVE " 

	cQuery += " LEFT OUTER JOIN "
	cQuery += " ( "
	cQuery += " SELECT "
	cQuery += " X5_CHAVE AS COD, X5_DESCRI AS SEG "
	cQuery += " FROM  "
	cQuery += " " + RetSqlName("SX5") + " AS SX5  "
	cQuery += " WHERE  "
	cQuery += " SX5.D_E_L_E_T_ = '' "
	cQuery += " AND X5_TABELA = '_S' "
	cQuery += " ) AS SEGMENTO1 ON "
	cQuery += " A1_SATIV1 = SEGMENTO1.COD "

	cQuery += " LEFT OUTER JOIN "
	cQuery += " ( "
	cQuery += " SELECT "
	cQuery += " X5_CHAVE AS COD, X5_DESCRI AS SEG "
	cQuery += " FROM  "
	cQuery += " " + RetSqlName("SX5") + " AS SX5  "
	cQuery += " WHERE  "
	cQuery += " SX5.D_E_L_E_T_ = '' "
	cQuery += " AND X5_TABELA = '_T' "
	cQuery += " ) AS SEGMENTO2 ON "
	cQuery += " A1_SATIV2 = SEGMENTO2.COD "

	cQuery += " WHERE " 
	cQuery += " ZBI.D_E_L_E_T_ = '' " 
	cQuery += " AND SA1.D_E_L_E_T_ = '' " 
	//cQuery += " AND ZBI_MOTIVO <> '' " 
	cQuery += " ) AS REGISTROS " 

	cQuery += " WHERE " 
	cQuery += " REGISTROS.PERIODO >= '" + cPerDe + "' " 
	cQuery += " AND REGISTROS.PERIODO <= '" + cPerAte + "' " 
	
	If lDiret .Or. lGerent
		cQuery += " AND REGISTROS.SUPER    >= '" + Alltrim(cValToChar(MV_PAR02)) + "' " 
		cQuery += " AND REGISTROS.SUPER    <= '" + Alltrim(cValToChar(MV_PAR03)) + "' " 
		cQuery += " AND REGISTROS.ZBI_VEND >= '" + Alltrim(cValToChar(MV_PAR04)) + "' " 
		cQuery += " AND REGISTROS.ZBI_VEND <= '" + Alltrim(cValToChar(MV_PAR05)) + "' " 
	
	ElseIf lSuperv
		cQuery += " AND REGISTROS.SUPER     = '" + Alltrim(cValToChar(cCodigo)) + "' " 
		cQuery += " AND REGISTROS.ZBI_VEND >= '" + Alltrim(cValToChar(MV_PAR04)) + "' " 
		cQuery += " AND REGISTROS.ZBI_VEND <= '" + Alltrim(cValToChar(MV_PAR05)) + "' " 
	
	ElseIf lVended
		cQuery += " AND REGISTROS.ZBI_VEND  = '" + cValtoChar(cCodigo) + "' "
	
	EndIf

	cQuery += " AND REGISTROS.ZBI_CODCLI >= '" + Alltrim(cValToChar(MV_PAR06)) + "' "
	cQuery += " AND REGISTROS.ZBI_CODCLI <= '" + Alltrim(cValToChar(MV_PAR07)) + "' "

	cQuery += " AND REGISTROS.ZBI_CODCLI + REGISTROS.ZBI_LOJA IN "
	cQuery += " ( "
	cQuery += " SELECT ZBI_CODCLI+ZBI_LOJA FROM " + RetSqlName("ZBI") + " AS ZBI WHERE ZBI.D_E_L_E_T_ = '' AND SUBSTRING(ZBI_PERIOD,3,4)+SUBSTRING(ZBI_PERIOD,1,2) = '" + cPerAte + "' "
	cQuery += " ) "

	cQuery += " ORDER BY REGISTROS.ZBI_CODCLI,REGISTROS.ZBI_LOJA,REGISTROS.PERIODO " 

	//Verifica se o alias já existe.
	If Select("REGISTROS") > 0
		REGISTROS->(DbCloseArea())

	EndIf

	//
	cQuery := ChangeQuery(cQuery) 

	//Executa consulta no BD.
	TcQuery cQuery New Alias "REGISTROS"

	DbSelectArea("REGISTROS")
	REGISTROS->(DbGoTop())
	While ! REGISTROS->(Eof())

		cObsevacao := ""
		If Alltrim(cValToChar(REGISTROS->PERIODO)) == cPerAte
			cObsevacao := getMemo(Val(cValToChar(REGISTROS->REC)))

		EndIf

		Aadd(aRetorno,{;
		REGISTROS->ZBI_VEND,;
		REGISTROS->SUPER,;
		REGISTROS->ZBI_CODCLI,;
		REGISTROS->ZBI_LOJA,;
		REGISTROS->A1_NOME,;
		REGISTROS->ZBI_PERIOD,;
		REGISTROS->ZBI_MOTIVO,;
		Alltrim(cValToChar(REGISTROS->MOTIVO)),;
		REGISTROS->PERIODO,;
		REGISTROS->REDE,;
		REGISTROS->SEGMENTO1,;
		REGISTROS->SEGMENTO2,;
		cObsevacao;
		})

		REGISTROS->(DbSkip())
	EndDo

	DbCloseArea("REGISTROS")

Return aRetorno

/*{Protheus.doc} Static Function getMemo
	Obtém observação feita pelo vendedor.
	@type  Function
	@author Everson
	@since 13/16/2017
	@version 01
*/

Static Function getMemo(nRec)

	Local aArea	:= GetArea()
	Local cMemo := ""

	DbSelectArea("ZBI")
	ZBI->(DbGoTop())
	ZBI->(DbGoTo(nRec))

	cMemo := cValToChar(ZBI->ZBI_OBS)

	RestArea(aArea)

Return cMemo

/*{Protheus.doc} Static Function scriptCSV
	JavaScript a ser adicionado na página do relatório.
	@type  Function
	@author Everson
	@since 25/10/2016
	@version 01
*/

Static Function scriptCSV()

	Local cScript := ""

	cScript := "<script>"
	cScript += " $(document).ready(function() { "
	cScript += " $('#dadosTabela').DataTable({'bPaginate': false, 'sScrollY': '380px', colReorder: true}); "
	cScript += " } ); "
	cScript += " function download(strData, strFileName, strMimeType) {var D = document, a = D.createElement('a');strMimeType= strMimeType || 'application/octet-stream'; "
	cScript += " if (navigator.msSaveBlob) {return navigator.msSaveBlob(new Blob([strData], {type: strMimeType}), strFileName);} "
	cScript += " if ('download' in a) { a.href = 'data:' + strMimeType + ',' + encodeURIComponent(strData); a.setAttribute('download', "
	cScript += " strFileName); a.innerHTML = 'downloading...';D.body.appendChild(a); setTimeout(function() {a.click(); D.body.removeChild(a);}, 66);return true;} "
	cScript += " var f = D.createElement('iframe'); "
	cScript += " D.body.appendChild(f); f.src = 'data:' +  strMimeType   + ',' + encodeURIComponent(strData);setTimeout(function() { D.body.removeChild(f);}, 333);return true;} "	
	cScript += " jQuery.fn.table2CSV = function(options){var options = jQuery.extend({separator: ';',header: [],headerSelector: 'th',columnSelector: 'td', "
	cScript += " delivery: 'popup',filename: 'poweredd_by_sinri.csv',transform_gt_lt: true},	options); "
	cScript += " var csvData = [];var headerArr = [];var el = this; "
	cScript += " var numCols = options.header.length;var tmpRow = []; "
	cScript += " if (numCols > 0){for (var i = 0; i < numCols; i++) {tmpRow[tmpRow.length] = formatData(options.header[i]);}"
	cScript += " } else {$(el).filter(':visible').find(options.headerSelector).each(function() {if ($(this).css('display') != 'none') tmpRow[tmpRow.length] = formatData($(this).html());});} "
	cScript += " row2CSV(tmpRow); "
	cScript += " $(el).find('tr').each(function() {var tmpRow = [];$(this).filter(':visible').find(options.columnSelector).each(function() { "
	cScript += " if ($(this).css('display') != 'none') tmpRow[tmpRow.length] = formatData($(this).html());});row2CSV(tmpRow);}); "
	cScript += " if (options.delivery == 'popup') {var mydata = csvData.join('\n');if(options.transform_gt_lt){mydata=sinri_recover_gt_and_lt(mydata);} "
	cScript += " return popup(mydata);}"
	cScript += " else if(options.delivery == 'download') {var mydata = csvData.join('\n');if(options.transform_gt_lt){mydata=sinri_recover_gt_and_lt(mydata);} "
	cScript += " var url='data:text/csv;charset=utf8,' + encodeURIComponent(mydata);	window.open(url);	return true;} "
	cScript += " else {var mydata = csvData.join('\n');if(options.transform_gt_lt){mydata=sinri_recover_gt_and_lt(mydata);}return mydata;} "
	cScript += " function sinri_recover_gt_and_lt(input){var regexp=new RegExp(/&gt;/g);var input=input.replace(regexp,'>'); "
	cScript += " var regexp=new RegExp(/&lt;/g);var input=input.replace(regexp,'<');	return input;} "
	cScript += " function row2CSV(tmpRow) {var tmp = tmpRow.join(''); if (tmpRow.length > 0 && tmp != '') {	var mystr = tmpRow.join(options.separator); "
	cScript += " csvData[csvData.length] = mystr;	}} "
	cScript += " function formatData(input) {
	cScript += " var regexp = new RegExp(/[']/g); "
	cScript += " var output = input.replace(regexp, '“'); "
	cScript += " var regexp = new RegExp(/\<[^\<]+\>/g); "
	cScript += " var output = output.replace(regexp, ''); "
	cScript += " output = output.replace(/&nbsp;/gi,' '); "
	cScript += " if (output == '') return ''; "
	cScript += " return '"
	cScript += '"'
	cScript += " ' "
	cScript += " + output.trim() + '"
	cScript += '"'
	cScript += " '; } "

	cScript += " function popup(data) { "
	cScript += " var generator = window.open('', 'csv', 'height=400,width=600'); "
	cScript += " generator.document.write('<html><head><title>CSV</title>'); "
	cScript += " generator.document.write('</head><body >'); "
	cScript += " generator.document.write('<textArea cols=70 "
	cScript += ' rows=15 wrap="off" '
	cScript += " >'); "
	cScript += " generator.document.write(data); "
	cScript += " generator.document.write('</textArea>'); "
	cScript += " generator.document.write('</body></html>'); "
	cScript += " generator.document.close(); "
	cScript += " return true; "
	cScript += " } "
	cScript += " }; "

	cScript += " $(document).ready(function () { "

	cScript += " $('#dadosTabela').each(function () { "
	cScript += " var $table = $(this); "
	cScript += " var $button = $('#btnExportar'); "
	cScript += ' $button.text("Exportar"); '
	cScript += " $button.click(function () { "
	cScript += " var csv = $table.table2CSV({ "
	cScript += " delivery: 'value' "
	cScript += " }); "
	cScript += ' download(csv, "processado.csv", "text/csv");'
	cScript += " }); "
	cScript += " }); "

	cScript += " }) "

	cScript += "</script>"

Return cScript

/*{Protheus.doc} Static Function criarPergunta
	Cria pergunta na SX1
	@type  Function
	@author Everson
	@since 10/11/2016
	@version 01
*/

Static Function criarPergunta(cPerg)

	Local aArea := GetArea()

	PutSx1(cPerg,"01","Período(mmaaaa)  ?"," "," ","mv_ch1","C",6,0,0,	"G","","","","","mv_par01"," "," "," ","",	" "," "," "," "," "," ", " "," "," "," ",	" "," ",{"Informe o período de apuração"} ,{"Informe o período de apuração"}, {"Informe o período de apuração"})
	PutSx1(cPerg,"02","Supervisor de    ?"," "," ","mv_ch2","C",6,0,0,	"G","","","","","mv_par02"," "," "," ","",	" "," "," "," "," "," ", " "," "," "," ",	" "," ",{"Informe o código do supervisor"},{"Informe o código do supervisor"},{"Informe o código do supervisor"})
	PutSx1(cPerg,"03","Supervisor Até   ?"," "," ","mv_ch3","C",6,0,0,	"G","","","","","mv_par03"," "," "," ","",	" "," "," "," "," "," ", " "," "," "," ",	" "," ",{"Informe o código do supervisor"},{"Informe o código do supervisor"},{"Informe o código do supervisor"})
	PutSx1(cPerg,"04","Vendedor de      ?"," "," ","mv_ch4","C",6,0,0,	"G","","SA3","","","mv_par04"," "," "," ","",	" "," "," "," "," "," ", " "," "," "," ",	" "," ",{"Informe o código do vendedor"},{"Informe o código do vendedor"},{"Informe o código do vendedor"})
	PutSx1(cPerg,"05","Vendedor Até     ?"," "," ","mv_ch5","C",6,0,0,	"G","","SA3","","","mv_par05"," "," "," ","",	" "," "," "," "," "," ", " "," "," "," ",	" "," ",{"Informe o código do vendedor"},{"Informe o código do vendedor"},{"Informe o código do vendedor"})
	PutSx1(cPerg,"06","Cliente de       ?"," "," ","mv_ch6","C",6,0,0,	"G","","SA1","","","mv_par06"," "," "," ","",	" "," "," "," "," "," ", " "," "," "," ",	" "," ",{"Informe o código do cliente"},{"Informe o código do cliente"},{"Informe o código do cliente"})
	PutSx1(cPerg,"07","Cliente Até      ?"," "," ","mv_ch7","C",6,0,0,	"G","","SA1","","","mv_par07"," "," "," ","",	" "," "," "," "," "," ", " "," "," "," ",	" "," ",{"Informe o código do cliente"},{"Informe o código do cliente"},{"Informe o código do cliente"})

	RestArea(aArea)

Return Nil

/*{Protheus.doc} Static Function logAcesso 
	Log de acesso de rotina.
	@type  Function
	@author Everson
	@since 16/06/2017
	@version 01
*/

Static Function logAcesso(cRotina)

	Local aArea		:= GetArea()
	
	cRotina := Alltrim(cValToChar(cRotina))

	//Log.
	RecLock("ZBE",.T.)
		ZBE->ZBE_FILIAL := xFilial("SE1")
		ZBE->ZBE_DATA	:= Date()
		ZBE->ZBE_HORA	:= cValToChar(Time())
		ZBE->ZBE_USUARI	:= cUserName
		ZBE->ZBE_LOG	:= "ACESSO A ROTINA " + cRotina
		ZBE->ZBE_MODULO	:= "COMERCIAL"
		ZBE->ZBE_ROTINA	:= "ADVEN036R"
	MsUnlock()
	
	RestArea(aArea)
	
Return Nil