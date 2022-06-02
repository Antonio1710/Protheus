#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include 'AP5mail.ch'

/*/{Protheus.doc} User Function ADFIN074R
	(Chamado TI - Relatório de reembolso)
	@type  Function
	@author Everson
	@since 22/05/2019
	@version 1.0
	@history 21/07/2020, Leon, Comentar LockByName para contornar falta de execução de rotinas de agendamento;
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	/*/
User Function ADFIN074R() //U_ADFIN074R()
	//Declaração de variávies
	Local cEmp 	:= "01"
	Local cFil 	:= "02"

	//Inicia o ambiente.
	If ! IsInCallStack('U_ADFIN030P')
		RpcClearEnv()
		RPCSetType(3)
		RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })		
		// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
		// If !LockByName("ADFIN074R", .T., .F.)
		// 	ConOut("[ADFIN074R] - Existe outro processamento sendo executado! Verifique...")
		// 	RPCClearEnv()
		// 	Return
		// EndIf

	EndIf

	//	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	//FWMonitorMsg(ALLTRIM(PROCNAME()))
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatório de reembolso.')

	logZBN("1") //Log início.

	//
	Conout( DToS(Date()) + " " + Time() + " ADFIN074R - Início da geração do relatório de reembolso")
	gerRel()
	Conout( DToS(Date()) + " " + Time() + " ADFIN074R - Fim da geração do relatório de reembolso")

	logZBN("2") //Log fim.

	//Fecha o ambiente.
	If ! IsInCallStack('U_ADFIN030P')

		//Destrava a rotina para o usuário
		// UnLockByName("ADFIN074R")

		RpcClearEnv()
	EndIf
Return Nil

/*/{Protheus.doc} gerRel
	(Gera relatório)
	@type  Static Function
	@author Everson
	@since 06/05/2019
	@version 1.0
	/*/
Static Function gerRel()
	//Declaração de variávies
	Local aArea			:= GetArea()
	Local cHtml			:= ""		
	Local nUltAno 		:= 0
	Local nAnoAtu		:= 0	
	Local cEmail		:= Alltrim(GetMv("MV_#RELREE",,""))
	Local cMsg			:= "Segue relatório de reembolso."
	Local cArq			:= "\rel_fin\reembolso.html"

	//
	If Empty(cEmail)
		RestArea(aArea)
		Return Nil
	EndIf

	//Caso o arquivo já existir, o mesmo é pagado.
	FErase(cArq)
	//
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

	//Aba 1 - Consolidado por ano.
	aba1(@cHtml)

	//Aba 2 - Agrupado por Conta Contábil.
	//aba2(@cHtml)

	//Aba 3 - Agrupado por Centro de Custo.
	aba3(@cHtml)

	//Aba 4 - Detalhado.
	aba4(@cHtml)

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
	//cHtml += ' if(indice === 1){ '
	//cHtml += ' location.reload(); '
	//cHtml += ' } '
	cHtml += ' }); '				
	cHtml += ' }); '
	cHtml += " </script> "

	cHtml += " </body> " 

	cHtml += " </html> " 

	//
	cHtml := StrTran(cHtml,Chr(129),"")
	cHtml := StrTran(cHtml,Chr(141),"")
	cHtml := StrTran(cHtml,Chr(143),"")
	cHtml := StrTran(cHtml,Chr(144),"")
	cHtml := StrTran(cHtml,Chr(157),"")
	memowrite(cArq,EncodeUtf8(cHtml))

	//Envia e-mail.
	envEmail("Reembolso",cMsg,cEmail,cArq)

	//
	FErase(cArq)

	//
	RestArea(aArea)
Return cHtml

/*/{Protheus.doc} cabecalho
	(Chamado 046278 - Cabeçalho html)
	@type  Static Function
	@author Everson
	@since 09/01/2019
	@version 1.0
	/*/
Static Function cabecalho(cHtml)
	//Declaração de variávies
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
	cHtml += " tr:nth-child(even) { "
	cHtml += "   background-color: #dddddd "
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

/*/{Protheus.doc} carArq
	(Chamado 035788 - Carrega arquivos texto)
	@type  Static Function
	@author Everson
	@since 15/01/2019
	@version 1.0
	/*/
Static Function carArq(cHtml,nHdl,cArquivo)
	//Declaracao de Variaveis
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

	Conout( DToS(Date()) + " " + Time() + " ADFIN074R - Carregou arquivo temporário " + cArquivo + " " + ElapTime ( cHrIni , Time() ) )

	//
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} criaAbas
	(long_description)
	@type  Static Function
	@author Everson
	@since 09/01/2019
	@version 1.0
	/*/
Static Function criaAbas(cHtml)
	//Declaração de variávies
	Local aArea	 := GetArea()

	//
	cHtml += " <h2 style='color:#28377c;margin:0px;'>Relatório de Reembolso</h2> "
	cHtml += " <hr> "
	cHtml += " <p>ADFIN074R</p> "  
	cHtml += " <p>Emitido em: " + DToC(Date()) + " - " + cValToChar(Time()) + "</p> " 
	cHtml += " <br/> " 
	cHtml += ' <div class="TabControl"> ' 
	cHtml += ' <div id="header"> ' 
	cHtml += ' <ul class="abas"> ' 
	cHtml += " <li> " 
	cHtml += ' <div class="aba"> ' 
	cHtml += " <span>Consolidado</span> "  
	cHtml += " </div> " 
	cHtml += " </li> " 
	/*
	cHtml += " <li> " 
	cHtml += ' <div class="aba"> ' 
	cHtml += " <span>Agrupado por Conta Contátbil</span> "  
	cHtml += " </div> " 
	cHtml += " </li> "
	*/
	cHtml += " <li> " 
	cHtml += ' <div class="aba"> ' 
	cHtml += " <span>CC x Conta Contábil</span> "
	cHtml += " </div> " 
	cHtml += " </li> " 
	cHtml += " <li> " 
	cHtml += ' <div class="aba"> ' 
	cHtml += " <span>Conta Contábil x CC</span> " 
	cHtml += " </div> " 
	cHtml += " </ul> " 
	cHtml += " </div> " 

	//
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} aba1
	(Chamado TI - Preenche aba1)
	@type  Static Function
	@author Everson
	@since 17/05/2019
	@version 1.0
	/*/
Static Function aba1(cHtml)
	//Declaração de variávies
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local aAnos		:= {}
	Local nUltAno	:= Year(Date()) - 5
	Local nAnoAtu	:= Year(Date())
	Local nAux		:= 1
	Local nAux2		:= 1
	Local nAux3		:= 1
	Local cAno		:= ""
	Local cMes		:= ""
	Local cConta	:= ""
	Local cNmConta	:= ""
	Local aContas	:= {}
	Local aMes		:= {}
	Local aTotais	:= {}
	Local cCC	 	:= ""
	Local cNMCC		:= ""
	Local aCC		:= {}

	//
	Aadd(aTotais,{"Total",{{"1",0},{"2",0},{"3",0},{"4",0},{"5",0},{"6",0},{"7",0},{"8",0},{"9",0},{"10",0},{"11",0},{"12",0},{"T",0}}})

	//
	For nAux := nUltAno To nAnoAtu	
		Aadd(aAnos,{nAux,{{"1",0},{"2",0},{"3",0},{"4",0},{"5",0},{"6",0},{"7",0},{"8",0},{"9",0},{"10",0},{"11",0},{"12",0},{"T",0}}})
	Next nAux

	//
	Asort(aAnos,,,{ |x, y| x > y } )

	//******************Por ano.
	cHtml += ' <div class="conteudo"> ' 

	cHtml += " <table id='rep1Aba' class='tabelaTab1'> " 
	cHtml += " <tr style='background-color: #96191d; color:white; text-align:left; font-weight:bold;'><td colspan='14'>Consolidado por Anos</td></tr> "
	cHtml += " <tr style='background-color: #a8a8a8; text-align:center; font-weight:bold;'> " 
	cHtml += " <td>Ano</td> "
	cHtml += " <td>Janeiro</td> " 	
	cHtml += " <td>Fevereiro</td> " 
	cHtml += " <td>Março</td> " 
	cHtml += " <td>Abril</td> " 
	cHtml += " <td>Maio</td> " 
	cHtml += " <td>Junho</td> " 
	cHtml += " <td>Julho</td> " 
	cHtml += " <td>Agosto</td> " 
	cHtml += " <td>Setembro</td> " 
	cHtml += " <td>Outubro</td> " 
	cHtml += " <td>Novembro</td> " 
	cHtml += " <td>Dezembro</td> " 
	cHtml += " <td style='background-color: #96191d; color:white;font-weight:bold' >Total</td> "
	cHtml += " </tr> "

	//
	cQuery := scpPorMes()

	//
	If Select("D_REL") > 0
		D_REL->(DbCloseArea())
	EndIf

	//
	TcQuery cQuery New Alias "D_REL"
	DbSelectArea("D_REL")
	D_REL->(DbGoTop())			

	//
	While ! D_REL->(Eof())
		//
		cAno := Alltrim(cValToChar(D_REL->ANO))

		//
		For nAux := 1 To Len(aAnos)
			If Alltrim(cValToChar(aAnos[nAux][1])) == cAno
				//
				Conout( DToS(Date()) + " " + Time() + " ADFIN074R - aba1 - nPosAno " + cValToChar(nAux) )
				Exit
			EndIf
		Next nAux

		//
		While ! D_REL->(Eof()) .And. cAno == Alltrim(cValToChar(D_REL->ANO))
			//
			cMes := Alltrim(cValToChar(D_REL->MES))

			//
			For nAux2 := 1 To Len(aAnos[nAux][2])
				If Alltrim(cValToChar(aAnos[nAux][2][nAux2][1])) == cMes
					Exit
				EndIf
			Next nAux2

			//
			aAnos[nAux][2][nAux2][2] := Val(cValToChar(D_REL->CT2_VALOR))
			aAnos[nAux][2][13][2]    += Val(cValToChar(D_REL->CT2_VALOR))

			aTotais[1][2][nAux2][2]  += Val(cValToChar(D_REL->CT2_VALOR))
			aTotais[1][2][13][2]     += Val(cValToChar(D_REL->CT2_VALOR))

			D_REL->(DbSkip())
		End
	End	

	//
	For nAux := 1 To Len(aAnos)
		cHtml += " <tr> " 

		cHtml += " <td style='background-color: #a8a8a8; text-align:center; font-weight:bold;'>" + cValToChar(aAnos[nAux][1]) + "</td> "

		//
		For nAux2 := 1 To Len(aAnos[nAux][2])
			cHtml += " <td align='right' " + Iif(nAux2 == 13," style='font-weight:bold' ","") + ">" + Alltrim( Transform( aAnos[nAux][2][nAux2][2] ,"@E 999,999,999.99") ) + "</td> " 
		Next nAux2

		cHtml += " </tr> " 
	Next nAux

	//
	For nAux := 1 To Len(aTotais)
		cHtml += " <tr> " 

		cHtml += " <td style='background-color: #96191d; color:white; text-align:center; font-weight:bold;'>" + cValToChar(aTotais[nAux][1]) + "</td> "

		//
		For nAux2 := 1 To Len(aTotais[nAux][2])
			cHtml += " <td align='right' " + Iif(nAux2 == 13," style='font-weight:bold' ","") + ">" + Alltrim( Transform( aTotais[nAux][2][nAux2][2] ,"@E 999,999,999.99") ) + "</td> " 
		Next nAux2

		cHtml += " </tr> "		
	Next aTotais

	//
	cHtml += " </table> "	
	D_REL->(DbCloseArea())

	//******************Por centro de custo.
	cQuery := scpPorCC()

	//
	aTotais	:= {}
	Aadd(aTotais, {{"1",0},{"2",0},{"3",0},{"4",0},{"5",0},{"6",0},{"7",0},{"8",0},{"9",0},{"10",0},{"11",0},{"12",0},{"T",0}} )

	//
	If Select("D_REL1_1") > 0
		D_REL1_1->(DbCloseArea())
	EndIf

	//
	TcQuery cQuery New Alias "D_REL1_1"
	DbSelectArea("D_REL1_1")
	D_REL1_1->(DbGoTop())

	//
	aMes := {}
	While ! D_REL1_1->(Eof())
		//
		cCC	 := Alltrim(cValToChar(D_REL1_1->CT2_CCD))
		cNMCC:= Alltrim(cValToChar(D_REL1_1->CTT_DESC01))

		Aadd(aMes, {{"1",0},{"2",0},{"3",0},{"4",0},{"5",0},{"6",0},{"7",0},{"8",0},{"9",0},{"10",0},{"11",0},{"12",0},{"T",0}} )

		While Alltrim(cValToChar(D_REL1_1->CT2_CCD)) == cCC
			//
			cMes := Alltrim(cValToChar(D_REL1_1->MES))

			//
			For nAux := 1 To Len(aMes[1])
				If Alltrim(cValToChar( aMes[1][nAux][1] )) == cMes
					aMes[1][nAux][2] := Val(cValToChar(D_REL1_1->CT2_VALOR))
					aMes[1][13][2]   += Val(cValToChar(D_REL1_1->CT2_VALOR))

					aTotais[1][nAux][2] += Val(cValToChar(D_REL1_1->CT2_VALOR))
					aTotais[1][13][2]   += Val(cValToChar(D_REL1_1->CT2_VALOR))
				EndIf
			Next nAux

			D_REL1_1->(DbSkip())
		End

		//
		Aadd(aCC,{cCC,cNMCC,aMes})
		aMes := {}
	End	

	//
	cHtml += " <br/><hr><br/>  "
	cHtml += " <p style='color:red;font-weight:bold;' >***Valores referentes ao ano de " + cValToChar( Year(Date() )) + "***</p>  "  
	cHtml += " <table id='rep1Aba' class='tabelaTab1'> "
	cHtml += " <tr style='background-color: #96191d; color:white; text-align:left; font-weight:bold;'><td colspan='14'>Consolidado por Centro de Custo</td></tr> " 
	cHtml += " <tr style='background-color: #a8a8a8; text-align:center; font-weight:bold;'> " 
	cHtml += " <td>CC</td> "
	cHtml += " <td>Janeiro</td> " 	
	cHtml += " <td>Fevereiro</td> " 
	cHtml += " <td>Março</td> " 
	cHtml += " <td>Abril</td> " 
	cHtml += " <td>Maio</td> " 
	cHtml += " <td>Junho</td> " 
	cHtml += " <td>Julho</td> " 
	cHtml += " <td>Agosto</td> " 
	cHtml += " <td>Setembro</td> " 
	cHtml += " <td>Outubro</td> " 
	cHtml += " <td>Novembro</td> " 
	cHtml += " <td>Dezembro</td> " 
	cHtml += " <td style='background-color: #96191d; color:white;font-weight:bold' >Total</td> " 
	cHtml += " </tr> "	

	//
	For nAux := 1 To Len(aCC)
		//
		cHtml += " <tr> " 

		cHtml += " <td style='text-align:left;width:150px;'>" + cValToChar(aCC[nAux][1]) + "-" + cValToChar(aCC[nAux][2]) + "</td> "

		//
		For nAux2 := 1 To Len(aCC[nAux][3][1])
			cHtml += " <td align='right' " + Iif(nAux2 == 13," style='font-weight:bold' ","") + " >" + Alltrim( Transform( aCC[nAux][3][1][nAux2][2] ,"@E 999,999,999.99") ) + "</td> " 
		Next nAux2

		cHtml += " </tr> " 
	Next nAux

	//
	cHtml += " <tr> " 

	cHtml += " <td style='text-align:left;width:150px;background-color: #96191d; color:white;font-weight:bold;'>Total</td> "

	//
	For nAux2 := 1 To Len(aTotais[1])
		cHtml += " <td align='right' " + Iif(nAux2 == 13," style='font-weight:bold' ","") + " >" + Alltrim( Transform( aTotais[1][nAux2][2] ,"@E 999,999,999.99") ) + "</td> " 
	Next nAux2

	cHtml += " </tr> " 

	//
	cHtml += " </table> "	

	//
	D_REL1_1->(DbCloseArea())		

	//******************Por conta contábil.
	cQuery := scpContC()

	//
	aTotais	:= {}
	Aadd(aTotais, {{"1",0},{"2",0},{"3",0},{"4",0},{"5",0},{"6",0},{"7",0},{"8",0},{"9",0},{"10",0},{"11",0},{"12",0},{"T",0}} )

	//
	If Select("D_REL2") > 0
		D_REL2->(DbCloseArea())
	EndIf

	//
	TcQuery cQuery New Alias "D_REL2"
	DbSelectArea("D_REL2")
	D_REL2->(DbGoTop())

	//
	aMes := {}
	While ! D_REL2->(Eof())
		//
		cConta	:= Alltrim(cValToChar(D_REL2->CT2_DEBITO))
		cNmConta:= Alltrim(cValToChar(D_REL2->CT1_DESC01))

		Aadd(aMes, {{"1",0},{"2",0},{"3",0},{"4",0},{"5",0},{"6",0},{"7",0},{"8",0},{"9",0},{"10",0},{"11",0},{"12",0},{"T",0}} )

		While	Alltrim(cValToChar(D_REL2->CT2_DEBITO)) == cConta
			//
			cMes := Alltrim(cValToChar(D_REL2->MES))

			//
			For nAux := 1 To Len(aMes[1])
				If Alltrim(cValToChar( aMes[1][nAux][1] )) == cMes
					aMes[1][nAux][2] := Val(cValToChar(D_REL2->CT2_VALOR))
					aMes[1][13][2]   += Val(cValToChar(D_REL2->CT2_VALOR))

					aTotais[1][nAux][2] += Val(cValToChar(D_REL2->CT2_VALOR))
					aTotais[1][13][2]   += Val(cValToChar(D_REL2->CT2_VALOR))
				EndIf
			Next nAux

			D_REL2->(DbSkip())
		End

		//
		Aadd(aContas,{cConta,cNmConta,aMes})
		aMes := {}
	End	

	//
	cHtml += " <br/><hr><br/>  " 
	cHtml += " <table id='rep1Aba' class='tabelaTab1'> " 
	cHtml += " <tr style='background-color: #96191d; color:white; text-align:left; font-weight:bold;'><td colspan='14'>Consolidado por Conta Contábil</td></tr> "
	cHtml += " <tr style='background-color: #a8a8a8; text-align:center; font-weight:bold;'> " 
	cHtml += " <td>Conta Contábil</td> "
	cHtml += " <td>Janeiro</td> " 	
	cHtml += " <td>Fevereiro</td> " 
	cHtml += " <td>Março</td> " 
	cHtml += " <td>Abril</td> " 
	cHtml += " <td>Maio</td> " 
	cHtml += " <td>Junho</td> " 
	cHtml += " <td>Julho</td> " 
	cHtml += " <td>Agosto</td> " 
	cHtml += " <td>Setembro</td> " 
	cHtml += " <td>Outubro</td> " 
	cHtml += " <td>Novembro</td> " 
	cHtml += " <td>Dezembro</td> " 
	cHtml += " <td style='background-color: #96191d; color:white;font-weight:bold' >Total</td> " 
	cHtml += " </tr> "	

	//
	For nAux := 1 To Len(aContas)
		//
		cHtml += " <tr> " 

		cHtml += " <td style='text-align:left;width:150px;'>" + cValToChar(aContas[nAux][1]) + "-" + cValToChar(aContas[nAux][2]) + "</td> "

		//
		For nAux2 := 1 To Len(aContas[nAux][3][1])
			cHtml += " <td align='right' " + Iif(nAux2 == 13," style='font-weight:bold' ","") + " >" + Alltrim( Transform( aContas[nAux][3][1][nAux2][2] ,"@E 999,999,999.99") ) + "</td> " 
		Next nAux2


		cHtml += " </tr> " 
	Next nAux

	//
	cHtml += " <tr> " 

	cHtml += " <td style='text-align:left;width:150px;background-color: #96191d; color:white;font-weight:bold;'>Total</td> "

	//
	For nAux2 := 1 To Len(aTotais[1])
		cHtml += " <td align='right' " + Iif(nAux2 == 13," style='font-weight:bold' ","") + " >" + Alltrim( Transform( aTotais[1][nAux2][2] ,"@E 999,999,999.99") ) + "</td> " 
	Next nAux2

	cHtml += " </tr> " 

	//
	cHtml += " </table> "	

	cHtml += " </div> " 

	//
	D_REL2->(DbCloseArea())

	//
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} aba2
	(Chamado TI - Preenche aba2)
	@type  Static Function
	@author Everson
	@since 17/05/2019
	@version 1.0
	/*/
Static Function aba2(cHtml)
	//Declaração de variávies
	Local aArea		:= GetArea()

	//
	cHtml += ' <div class="conteudo"> ' 

	cHtml += " </div> " 

	//
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} aba3
	(Chamado TI - Preenche aba3)
	@type  Static Function
	@author Everson
	@since 17/05/2019
	@version 1.0
	/*/
Static Function aba3(cHtml)
	//Declaração de variávies
	Local aArea		:= GetArea()
	Local cQuery	:= scpPMesC(2)
	Local aContas	:= {}
	Local nAux		:= 1
	Local nAux2		:= 1
	Local nAux3		:= 1
	Local cConta	:= ""
	Local cNmConta	:= ""
	Local aCC		:= {}
	Local cCC		:= ""
	Local cNmCC		:= ""
	Local cMes		:= ""
	Local nAuxCot	:= 0
	Local aTot		:= {}

	//
	If Select("D_REL3") > 0
		D_REL3->(DbCloseArea())
	EndIf

	//
	TcQuery cQuery New Alias "D_REL3"
	DbSelectArea("D_REL3")
	D_REL3->(DbGoTop())

	//
	While ! D_REL3->(Eof())
		//
		cCC		:= Alltrim(cValToChar(D_REL3->CT2_CCD))
		cNmCC	:= Alltrim(cValToChar(D_REL3->CTT_DESC01))

		Aadd(aTot,{"Total","Total", {{"1",0},{"2",0},{"3",0},{"4",0},{"5",0},{"6",0},{"7",0},{"8",0},{"9",0},{"10",0},{"11",0},{"12",0},{"T",0}} })

		//
		While ! D_REL3->(Eof()) .And. cCC == Alltrim(cValToChar(D_REL3->CT2_CCD))
			//
			cConta 	:= Alltrim(cValToChar(D_REL3->CT2_DEBITO))
			cNmConta:= Alltrim(cValToChar(D_REL3->CT1_DESC01))

			//
			nAuxCot++	
			Aadd(aContas,{cConta, cNmConta, {{"1",0},{"2",0},{"3",0},{"4",0},{"5",0},{"6",0},{"7",0},{"8",0},{"9",0},{"10",0},{"11",0},{"12",0},{"T",0}} })

			//
			While ! D_REL3->(Eof()) .And. cConta == Alltrim(cValToChar(D_REL3->CT2_DEBITO))
				//
				cMes := Alltrim(cValToChar(D_REL3->MES))

				//
				For nAux := 1 To Len(aContas[nAuxCot][3])
					If Alltrim(cValToChar( aContas[nAuxCot][3][nAux][1] )) == cMes
						aContas[nAuxCot][3][nAux][2] := Val(cValToChar(D_REL3->CT2_VALOR))
						aContas[nAuxCot][3][13][2]   += Val(cValToChar(D_REL3->CT2_VALOR))

						aTot[1][3][nAux][2] += Val(cValToChar(D_REL3->CT2_VALOR))
						aTot[1][3][13][2]   += Val(cValToChar(D_REL3->CT2_VALOR))
					EndIf
				Next nAux

				D_REL3->(DbSkip())
			End
		End

		//
		Aadd(aCC,{cCC,cNmCC,aContas,aTot})
		aContas := {}
		aTot 	:= {}
		nAuxCot := 0
	End

	//
	cHtml += ' <div class="conteudo"> ' 
	cHtml += " <p style='color:red;font-weight:bold;' >***Valores referentes ao ano de " + cValToChar( Year(Date() )) + "***</p>  "
	//
	For nAux := 1 To Len(aCC)
		//
		cHtml += " <table id='rep1Aba' class='tabelaTab1'> "
		cHtml += " <tr style='background-color: #96191d; color:white; text-align:left; font-weight:bold'><td colspan='14'>CC " + Alltrim(cValToChar(aCC[nAux][1])) + "-" + Alltrim(cValToChar(aCC[nAux][2])) + "</td></tr>"  
		cHtml += " <tr style='background-color: #a8a8a8; text-align:center; font-weight:bold;width:300px;'> " 
		cHtml += " <td style='text-align:left;'>Centro de Custo</td> "
		cHtml += " <td>Janeiro</td> " 	
		cHtml += " <td>Fevereiro</td> " 
		cHtml += " <td>Março</td> " 
		cHtml += " <td>Abril</td> " 
		cHtml += " <td>Maio</td> " 
		cHtml += " <td>Junho</td> " 
		cHtml += " <td>Julho</td> " 
		cHtml += " <td>Agosto</td> " 
		cHtml += " <td>Setembro</td> " 
		cHtml += " <td>Outubro</td> " 
		cHtml += " <td>Novembro</td> " 
		cHtml += " <td>Dezembro</td> " 
		cHtml += " <td style='background-color: #96191d; color:white;font-weight:bold;'>Total</td> " 
		cHtml += " </tr> "

		//
		For nAux2 := 1 To Len(aCC[nAux][3])
			//
			cHtml += " <tr> " 

			cHtml += " <td style='text-align:left;width:150px;'>" + cValToChar(aCC[nAux][3][nAux2][1]) + "-" + cValToChar(aCC[nAux][3][nAux2][2]) + "</td> "

			//
			For nAux3 := 1 To Len(aCC[nAux][3][nAux2][3])
				cHtml += " <td align='right'>" + Alltrim( Transform( aCC[nAux][3][nAux2][3][nAux3][2] ,"@E 999,999,999.99") ) + "</td> " 
			Next nAux3

			cHtml += " </tr> " 
		Next nAux2

		//
		For nAux2 := 1 To Len(aCC[nAux][4])
			//
			cHtml += " <tr> " 

			cHtml += " <td style='text-align:left;width:150px;color:white;font-weight:bold;background-color: #96191d;'>" + cValToChar(aCC[nAux][4][nAux2][1]) + "</td> "

			//
			For nAux3 := 1 To Len(aCC[nAux][4][nAux2][3])
				cHtml += " <td align='right' style='font-weight:bold;'>" + Alltrim( Transform( aCC[nAux][4][nAux2][3][nAux3][2] ,"@E 999,999,999.99") ) + "</td> " 
			Next nAux3

			cHtml += " </tr> " 
		Next nAux2

		cHtml += " </table> "

		cHtml += " <hr> "

		cHtml += " <br/><br/> "
	Next nAux

	cHtml += " </div> " 

	//
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} aba4
	(Chamado TI - Preenche aba4)
	@type  Static Function
	@author Everson
	@since 17/05/2019
	@version 1.0
	/*/
Static Function aba4(cHtml)
	//Declaração de variávies
	Local aArea		:= GetArea()
	Local cQuery	:= scpPMesC(1)
	Local aContas	:= {}
	Local nAux		:= 1
	Local nAux2		:= 1
	Local nAux3		:= 1
	Local cConta	:= ""
	Local cNmConta	:= ""
	Local aCC		:= {}
	Local cCC		:= ""
	Local cNmCC		:= ""
	Local cMes		:= ""
	Local nAuxCC	:= 0
	Local aTot		:= {}

	//
	If Select("D_REL4") > 0
		D_REL4->(DbCloseArea())
	EndIf

	//
	TcQuery cQuery New Alias "D_REL4"
	DbSelectArea("D_REL4")
	D_REL4->(DbGoTop())

	//
	While ! D_REL4->(Eof())
		//
		cConta 	:= Alltrim(cValToChar(D_REL4->CT2_DEBITO))
		cNmConta:= Alltrim(cValToChar(D_REL4->CT1_DESC01))
		Aadd(aTot,{"Total","Total", {{"1",0},{"2",0},{"3",0},{"4",0},{"5",0},{"6",0},{"7",0},{"8",0},{"9",0},{"10",0},{"11",0},{"12",0},{"T",0}} })

		//
		While ! D_REL4->(Eof()) .And. cConta == Alltrim(cValToChar(D_REL4->CT2_DEBITO))
			//
			cCC		:= Alltrim(cValToChar(D_REL4->CT2_CCD))
			cNmCC	:= Alltrim(cValToChar(D_REL4->CTT_DESC01))

			//
			nAuxCC++	
			Aadd(aCC,{cCC, cNmCC, {{"1",0},{"2",0},{"3",0},{"4",0},{"5",0},{"6",0},{"7",0},{"8",0},{"9",0},{"10",0},{"11",0},{"12",0},{"T",0}} })

			//
			While ! D_REL4->(Eof()) .And. cCC == Alltrim(cValToChar(D_REL4->CT2_CCD))
				//
				cMes := Alltrim(cValToChar(D_REL4->MES))

				//
				For nAux := 1 To Len(aCC[nAuxCC][3])
					If Alltrim(cValToChar( aCC[nAuxCC][3][nAux][1] )) == cMes
						aCC[nAuxCC][3][nAux][2] := Val(cValToChar(D_REL4->CT2_VALOR))
						aCC[nAuxCC][3][13][2]   += Val(cValToChar(D_REL4->CT2_VALOR))

						aTot[1][3][nAux][2] += Val(cValToChar(D_REL4->CT2_VALOR))
						aTot[1][3][13][2]   += Val(cValToChar(D_REL4->CT2_VALOR))
					EndIf
				Next nAux

				D_REL4->(DbSkip())
			End
		End

		//
		Aadd(aContas,{cConta,cNmConta,aCC,aTot})
		aCC 	:= {}
		aTot 	:= {}
		nAuxCC 	:= 0
	End

	//
	Conout( DToS(Date()) + " " + Time() + " ADFIN074R - aba4 - Criou array " )

	//
	cHtml += ' <div class="conteudo"> ' 
	cHtml += " <p style='color:red;font-weight:bold;' >***Valores referentes ao ano de " + cValToChar( Year(Date() )) + "***</p>  "

	//
	For nAux := 1 To Len(aContas)
		//
		cHtml += " <table id='rep1Aba' class='tabelaTab1'> "
		cHtml += " <tr style='background-color: #96191d; color:white; text-align:left; font-weight:bold'><td colspan='14'>Conta " + Alltrim(cValToChar(aContas[nAux][1])) + "-" + Alltrim(cValToChar(aContas[nAux][2])) + "</td></tr>"  
		cHtml += " <tr style='background-color: #a8a8a8; text-align:center; font-weight:bold;width:300px;'> " 
		cHtml += " <td style='text-align:left;'>Centro de Custo</td> "
		cHtml += " <td>Janeiro</td> " 	
		cHtml += " <td>Fevereiro</td> " 
		cHtml += " <td>Março</td> " 
		cHtml += " <td>Abril</td> " 
		cHtml += " <td>Maio</td> " 
		cHtml += " <td>Junho</td> " 
		cHtml += " <td>Julho</td> " 
		cHtml += " <td>Agosto</td> " 
		cHtml += " <td>Setembro</td> " 
		cHtml += " <td>Outubro</td> " 
		cHtml += " <td>Novembro</td> " 
		cHtml += " <td>Dezembro</td> " 
		cHtml += " <td style='background-color: #96191d; color:white;font-weight:bold;'>Total</td> " 
		cHtml += " </tr> "

		//
		For nAux2 := 1 To Len(aContas[nAux][3])
			//
			cHtml += " <tr> " 

			cHtml += " <td style='text-align:left;width:150px;'>" + cValToChar(aContas[nAux][3][nAux2][1]) + "-" + cValToChar(aContas[nAux][3][nAux2][2]) + "</td> "

			//
			For nAux3 := 1 To Len(aContas[nAux][3][nAux2][3])
				cHtml += " <td align='right'>" + Alltrim( Transform( aContas[nAux][3][nAux2][3][nAux3][2] ,"@E 999,999,999.99") ) + "</td> " 
			Next nAux3

			cHtml += " </tr> " 
		Next nAux2

		//
		For nAux2 := 1 To Len(aContas[nAux][4])
			//
			cHtml += " <tr> " 

			cHtml += " <td style='text-align:left;width:150px;color:white;font-weight:bold;background-color: #96191d;'>" + cValToChar(aContas[nAux][4][nAux2][1]) + "</td> "

			//
			For nAux3 := 1 To Len(aContas[nAux][4][nAux2][3])
				cHtml += " <td align='right' style='font-weight:bold;'>" + Alltrim( Transform( aContas[nAux][4][nAux2][3][nAux3][2] ,"@E 999,999,999.99") ) + "</td> " 
			Next nAux3

			cHtml += " </tr> " 
		Next nAux2

		cHtml += " </table> "

		cHtml += " <hr> "

		cHtml += " <br/><br/> "
	Next nAux

	cHtml += " </div> " 

	//
	Conout( DToS(Date()) + " " + Time() + " ADFIN074R - aba4 - Fim " )

	//
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} scpContC
	(Chamado TI - Script sql aba 1 (por conta contábil).)
	@type  Static Function
	@author Everson
	@since 20/05/2019
	@version 1.0
	/*/
Static Function scpContC()
	//Declaração de variávies
	Local cQuery	:= "" 
	Local cQryBase	:= scpBase()

	//
	cQuery := "" 
	cQuery += " SELECT "
	cQuery += " BASE.CT2_DEBITO, BASE.CT1_DESC01, BASE.MES, SUM(BASE.CT2_VALOR) AS CT2_VALOR "
	cQuery += " FROM " 
	cQuery += " ( " 

	cQuery += cQryBase

	cQuery += " ) AS BASE "
	cQuery += " WHERE "
	cQuery += " BASE.ANO = (YEAR(GETDATE())) "
	cQuery += " GROUP BY " 
	cQuery += " BASE.CT2_DEBITO, BASE.CT1_DESC01, BASE.MES "
	cQuery += " ORDER BY "
	cQuery += " BASE.CT2_DEBITO, BASE.MES "

	//
	Conout( DToS(Date()) + " " + Time() + " ADFIN074R - scpContC - cQuery " + cQuery )
Return cQuery

/*/{Protheus.doc} scpPMesC
	(Chamado TI - Script sql aba 4 (detalhado por conta x centro de custo).)
	@type  Static Function
	@author Everson
	@since 20/05/2019
	@version 1.0
	/*/
Static Function scpPMesC(nOPc)
	//Declaração de variávies
	Local cQuery	:= "" 
	Local cQryBase	:= scpBase()

	//
	cQuery := "" 
	cQuery += " SELECT "
	cQuery += " BASE.MES, BASE.CT2_DEBITO, BASE.CT1_DESC01, BASE.CT2_CCD, BASE.CTT_DESC01, SUM(BASE.CT2_VALOR) AS CT2_VALOR "
	cQuery += " FROM " 
	cQuery += " ( " 

	cQuery += cQryBase

	cQuery += " ) AS BASE "
	cQuery += " WHERE "
	cQuery += " BASE.ANO = (YEAR(GETDATE())) "
	cQuery += " GROUP BY " 
	cQuery += " BASE.MES, BASE.CT2_DEBITO, BASE.CT1_DESC01, BASE.CT2_CCD, BASE.CTT_DESC01 "
	cQuery += " ORDER BY "

	//
	If nOPc == 1
		cQuery += " BASE.CT2_DEBITO, BASE.CT2_CCD, BASE.MES "
	Else
		cQuery += " BASE.CT2_CCD, BASE.CT2_DEBITO, BASE.MES "
	EndIf

	//
	Conout( DToS(Date()) + " " + Time() + " ADFIN074R - scpPMesC - cQuery " + cQuery )
Return cQuery

/*/{Protheus.doc} scpPorMes
	(Chamado TI - Script sql aba 1 (ano).)
	@type  Static Function
	@author Everson
	@since 20/05/2019
	@version 1.0
	/*/
Static Function scpPorMes()
	//Declaração de variávies
	Local cQuery	:= "" 
	Local cQryBase	:= scpBase()

	//
	cQuery += " SELECT " 
	cQuery += " BASE.ANO, BASE.MES, SUM(BASE.CT2_VALOR) AS CT2_VALOR " 
	cQuery += " FROM " 
	cQuery += " ( " 

	//
	cQuery += cQryBase

	cQuery += " ) AS BASE " 
	cQuery += " GROUP BY  " 
	cQuery += " BASE.ANO, BASE.MES " 
	cQuery += " ORDER BY BASE.ANO DESC, BASE.MES "

	//
	Conout( DToS(Date()) + " " + Time() + " ADFIN074R - scpPorMes - cQuery " + cQuery )
Return cQuery

/*/{Protheus.doc} scpPorCC
	(Chamado TI - Script sql aba 1 (centro de custo).)
	@type  Static Function
	@author Everson
	@since 21/05/2019
	@version 1.0
	/*/
Static Function scpPorCC()
	//Declaração de variávies
	Local cQuery	:= "" 
	Local cQryBase	:= scpBase()

	//
	cQuery += " SELECT " 
	cQuery += " BASE.CT2_CCD, BASE.CTT_DESC01, BASE.MES, SUM(BASE.CT2_VALOR) AS CT2_VALOR " 
	cQuery += " FROM " 
	cQuery += " ( " 

	//
	cQuery += cQryBase

	cQuery += " ) AS BASE " 
	cQuery += " WHERE "
	cQuery += " BASE.ANO = (YEAR(GETDATE())) "
	cQuery += " GROUP BY  " 
	cQuery += " BASE.CT2_CCD, BASE.CTT_DESC01, BASE.MES " 
	cQuery += " ORDER BY BASE.CT2_CCD, BASE.CTT_DESC01, BASE.MES "

	//
	Conout( DToS(Date()) + " " + Time() + " ADFIN074R - scpPorCC - cQuery " + cQuery )
Return cQuery

/*/{Protheus.doc} scpBase
	(Chamado TI - Script sql base)
	@type  Static Function
	@author Everson
	@since 20/05/2019
	@version 1.0
	/*/
Static Function scpBase()
	//Declaração de variáveis
	Local cQuery := ""

	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " 'CT2' AS TAB,  " 
	cQuery += " CT2_FILKEY, " 
	cQuery += " CT2_DATA,  " 
	cQuery += " YEAR(CT2_DATA) AS ANO, " 
	cQuery += " MONTH(CT2_DATA) AS MES, " 
	cQuery += " CT2_CCD, CTT_DESC01, CT2_VALOR, CT2_DEBITO, CT1_DESC01 " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("CT2") + " (NOLOCK) AS CT2 " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("CTT") + " (NOLOCK) AS CTT " 
	cQuery += " ON CT2_CCD = CTT_CUSTO " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("CT1") + " (NOLOCK) AS CT1 ON " 
	cQuery += " CT2_DEBITO = CT1_CONTA " 
	cQuery += " WHERE " 
	cQuery += " CT2.D_E_L_E_T_ = '' " 
	cQuery += " AND CTT.D_E_L_E_T_ = '' " 
	cQuery += " AND CT1.D_E_L_E_T_ = '' " 
	cQuery += " AND CT2_PREFIX = 'REE' " 
	cQuery += " AND CT2_LOTE = '008810' " 
	cQuery += " AND CT2_ROTINA = 'CTBANFE' " 
	cQuery += " AND CAST(SUBSTRING(CT2_DEBITO,1,1) AS INTEGER) >= 3 " 
	cQuery += " AND YEAR(CT2_DATA) >= (YEAR(GETDATE())-5) " 
	cQuery += " AND CT2_CREDIT = '' " 

	cQuery += " UNION ALL " 

	cQuery += " SELECT " 
	cQuery += " 'SE5' AS TAB, " 
	cQuery += " E5_FILIAL, " 
	cQuery += " E5_DATA,  " 
	cQuery += " YEAR(E5_DATA) AS ANO, " 
	cQuery += " MONTH(E5_DATA) AS MES, " 
	cQuery += " E5_CCD, CTT_DESC01, E5_VALOR, ED_CONTA, CT1.CT1_DESC01 " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SE5") + " (NOLOCK) AS SE5 " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SED") + " (NOLOCK) AS SED " 
	cQuery += " ON E5_NATUREZ = ED_CODIGO " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("CTT") + " (NOLOCK) AS CTT " 
	cQuery += " ON E5_CCD = CTT_CUSTO " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("CT1") + " (NOLOCK) AS CT1 ON " 
	cQuery += " ED_CONTA = CT1_CONTA " 
	cQuery += " WHERE " 
	cQuery += " SE5.D_E_L_E_T_ = '' " 
	cQuery += " AND SED.D_E_L_E_T_ = '' " 
	cQuery += " AND CTT.D_E_L_E_T_ = '' " 
	cQuery += " AND CT1.D_E_L_E_T_ = '' " 
	cQuery += " AND E5_BANCO = 'CX1' " 
	cQuery += " AND ED_XREEMBO = '2' " 
	cQuery += " AND E5_RECPAG = 'P' " 
	cQuery += " AND E5_SITUACA = '' " 
	cQuery += " AND YEAR(E5_DATA) >= (YEAR(GETDATE())-5) " 

	//
	Conout( DToS(Date()) + " " + Time() + " ADFIN074R - scpBase - cQuery " + cQuery )
Return cQuery

/*/{Protheus.doc} envEmail
	(Chamado 035788 - Envia e-mail)
	@type  Static Function
	@author Everson
	@since 23/06/2017
	@version 1.0
	/*/
Static Function envEmail(cAssunto,cMensagem,cEmail,cAtach)

	//Declaração de variávies
	Local aArea			 := GetArea()
	Local lOk           := .T.
	Local cBody         := cMensagem
	Local cErrorMsg     := ""
	Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
	Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
	Local cFrom         := AllTrim(GetMv("MV_RELFROM"))
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
			Conout( DToS(Date()) + " " + Time() + " ADFIN074R - Não foi possível enviar o e-mail ao comprador. 3 - " + cErrorMsg)
		EndIf
	Else
		Get Mail Error cErrorMsg
		Conout( DToS(Date()) + " " + Time() + " ADFIN074R - Não foi possível enviar o e-mail ao comprador. 4 - " + cErrorMsg)
	EndIf

	If lOk
		Disconnect Smtp Server
	EndIf

	RestArea(aArea)
Return Nil

/*/{Protheus.doc} logZBN
	(Chamado TI - Gera log na ZBN)
	@type  Static Function
	@author Everson
	@since 21/05/2019
	@version 1.0
	/*/
Static Function logZBN(cStatus)
	//Declaração de variávies
	Local aArea	:= GetArea()

	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADFIN074R'))
		RecLock("ZBN",.F.)
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADFIN074R'
			ZBN_STATUS	:= cStatus
		MsUnlock() 
	Else
		RecLock("ZBN",.T.)
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADFIN074R'
			ZBN_STATUS	:= cStatus
		MsUnlock() 	
	EndIf

	ZBN->(dbCloseArea())

	RestArea(aArea)
Return Nil
