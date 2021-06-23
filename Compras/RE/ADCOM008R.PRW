#Include "Protheus.ch"
#Include "Topconn.ch"
#Include 'AP5mail.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADCOM008R บ Autor ณ Everson 			 บ Data ณ  05/05/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Envio de relat๓rio.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 034873.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAdriana     ณ24/05/2019ณTI-Devido a substituicao email para shared     บฑฑ
ฑฑบ            ณ          ณrelay, substituido MV_RELACNT p/ MV_RELFROM    บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADCOM008R() // U_ADCOM008R()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local cEmp 		:= "01"
	Local cFil 		:= "02"
	
	//Inicia o ambiente.
	RPCSetType(3)
	RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })

		logZBN("1") //Log inํcio.
		U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

		relCompras()

		logZBN("2") //Log fim.

	//Fecha o ambiente.
	RpcClearEnv()

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณrelComprasบ Autor ณ Everson 			 บ Data ณ  05/05/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Envio de relat๓rio.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 034873.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function relCompras()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea		:= GetArea()
	Local aUsuarios	:= {}
	Local cQuery	:= ""
	Local aDados	:= {}
	Local cCodUser	:= ""
	Local aDados	:= {}
	Local cCNPJFor	:= ""
	Local cDesCPag	:= ""
	Local cComprador:= ""
	
	//
	cQuery := scripSCR()
	
	If Select("DADOS_SCR") > 0
		DADOS_SCR->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "DADOS_SCR"
	DbSelectArea("DADOS_SCR")
	DADOS_SCR->(DbGoTop())
	
	If DADOS_SCR->(Eof())
		Return Nil
		
	EndIf
	
	While ! DADOS_SCR->(Eof())
		
		cCodUser := DADOS_SCR->CR_USER
		
		cDesCPag  := Posicione("SE4",1,xFilial("SE4") + Alltrim(cValToChar(DADOS_SCR->C7_COND)),"E4_DESCRI" )
		cComprador:= Posicione("SY1",3,Alltrim(cValToChar(DADOS_SCR->CR_FILIAL)) + Alltrim(cValToChar(DADOS_SCR->C7_USER)),"Y1_NOME")
		
		Aadd(aDados,{;
				DADOS_SCR->CR_FILIAL,; 			//1 - Filial.
				DADOS_SCR->C7_EMISSAO,;			//2 - Data do pedido.
				DADOS_SCR->C7_XHORA,; 			//3 - Hora de inclusใo do pedido.
				DADOS_SCR->CR_NUM,;				//4 - N๚mero d pedido.
				DADOS_SCR->A2_CGC,; 			//5 - CNPJ do fornecedor.
				Alltrim(cValToChar(DADOS_SCR->A2_NOME)),; // 6 - Fornecedor.
				cDesCPag,;						//7 - Condi็ใo de pagamento.
				DADOS_SCR->C7_DATPRF,;			//8 - Data de entrega.
				GetMv("MV_MOEDA" + Alltrim(cValToChar(DADOS_SCR->C7_MOEDA))),;//9 - Moeda.
				DADOS_SCR->CR_TOTAL,; 			//10 - Total do pedido.
				DADOS_SCR->C7_PROJETO,; 		//11 - Investimento.
				cComprador,; 					//12 - Comprador.
				DADOS_SCR->CR_USER;				//13 - Usuแrio.
		})
		
		DADOS_SCR->(DbSkip())
		
		If cCodUser <> DADOS_SCR->CR_USER
			prepEmail(aDados)
			aDados	:= {}
			
		EndIf
		
	EndDo
	
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณprepEmail         บ Autor ณ Everson บ Data ณ  05/05/2017    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณPrepara e-mail para ser enviado.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 034873.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function prepEmail(aDados)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local i			:= 1
	Local x			:= 1
	Local cEmail	:= ""
	Local cAssunto	:= "Pedidos de Compra Pendentes de Aprova็ใo"
	Local cBuffer	:= ""
	Local cAtach	:= ""
	Local aUsuario	:= {}
	Local cNmUser	:= ""
	Local cFilNm	:= ""
	Local cPrazoPag	:= ""
	Local aCondPag	:= {}
	Local nMaxAprov	:= 0
	Local aProvadores	:= {}
	Local nNumAprov	:= 0
	Local cFxCor	:= ""
	Local cFxEnt	:= ""
	Local cCC		:= ""
	
	//Obt้m informa็๕es do usuแrio.
	//cEmail 		:= "everson.silva@adoro.com.br;eduardo.santamaria@adoro.com.br"
	cEmail      := Alltrim(cValToChar(UsrRetMail(Alltrim(cValToChar(aDados[1][13])))))
	
	//>>>>>>>>>>>>>>>>>> REMOVER IF, DEPOIS DE EFETUAR VALIDAวรO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	If Alltrim(cValToChar(aDados[1][13])) <> "001657" .And. Alltrim(cValToChar(aDados[1][13])) <> "000605"
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//cEmail 		:= "everson.silva@adoro.com.br"

	//
	nMaxAprov	:= maxNvAprv(Alltrim(cValToChar(aDados[1][13])))
	//cNmUser		:= cValToChar(UserRetname(Alltrim(cValToChar(aDados[1][13]))))
	cNmCompl	:= cValToChar(UsrFullName(Alltrim(cValToChar(aDados[1][13]))))

	//Monta html.
	cBuffer := "<!DOCTYPE hmtl>"
	cBuffer += "<html>"
	cBuffer += "<head>"
	cBuffer += "<meta charset='UTF-8'>"
	cBuffer += "<style>"
	cBuffer += "body{width:98%;background-color: #fdfdfd; color:#28377c;background-color:#fdfdfd;}"
	cBuffer += "td {border-bottom: 1px solid white;padding-left:5px;padding-right:5px;padding-top:2px;}"
	cBuffer += "hr{border: 0 0 1px 0 0 solid #28377c;}"
	cBuffer += ".cabec{border-right: 1px solid white;}"
	cBuffer += "p{margin:0px; padding:0px; border:0px;}"
	cBuffer += "</style>"
	cBuffer += "</head>"
	cBuffer += "<body>"
	cBuffer += "<p style='color:black;'><strong>Olแ, " + Capital(Lower(Substr(cNmCompl,1,At(" ",cNmCompl)))) + ". Segue relat๓rio de pedidos de compra pendentes de aprova็ใo.</strong></p>"
	cBuffer += "<br/>"

	cBuffer += "<div style='margin: 0 auto;width: 100%;padding: 10px;font-size: 8px'>"
	cBuffer += "<table style='border-collapse: collapse;background-color:#f7be62;border: 1px solid white;border-radius: 10px 0 0 0;'>"
	cBuffer += "<tr style='border: 1px solid white;border-radius: 10px 0 0 0;'><td colspan='2'style='background-color: #96191d;color: white;text-align: left;border-radius: 10px 0 0 0; border-bottom: 1px solid white'>Legenda</td></tr>"
	cBuffer += "<tr><td>Dt. entrega menor que Dt. vigente</td><td style='background-color:red;color:black;'>Vermelho</td></tr>"
	cBuffer += "<tr><td>Dt. entrega igual a Dt. vigente</td><td style='background-color:yellow;color:black;'>Amarelo</td></tr>"
	cBuffer += "<tr><td>Dt. entrega maior que Dt. vigente</td><td style='background-color:green;color:black;'>Verde</td></tr>"
	cBuffer += "</table>"
	cBuffer += "<br/>
	
	cBuffer += "<table  style='width:600px;border-collapse: collapse;padding:10px;background-color:#f7be62;border: 1px solid white;border-radius: 10px 15px 0 0;'>"
	cBuffer += "<tr><td style='background-color: #96191d;color: white;text-align: left;border-radius: 10px 0 0 0; border-bottom: 1px solid white'>Gerado em: </td><td style='text-align: left; border-bottom: 1px solid white'>" + DToC(Date()) + " - " + Substr(cValToChar(Time()),1,8) + "</td></tr>"
	cBuffer += "<tr><td style='background-color: #96191d; color: white;text-align: left; border-bottom: 1px solid white'>Aprovador: </td><td style='text-align: left; border-bottom: 1px solid white'>" + Alltrim(cValToChar(aDados[1][13])) + "-" + cNmCompl + "</td></tr>"
	cBuffer += "</table>"
	
	cBuffer += "<table style='width:100%;padding-left: 5px;background-color:#f7be62;border: 1px solid white;border-radius: 0 15px 15px 15px;padding-right: 5px;padding-bottom:10px;padding-top:5px'>"
	cBuffer += "<tr>"
	cBuffer += "<td style='border: 0px'>"
	
	cBuffer += "<table style='width:100%;border-collapse: collapse;border-bottom: 1px solid white;font-size:small;'>"
	
	cBuffer += "<tr>"
	cBuffer += "<td style='color:#28377c;background-color:#fdfdfd;text-align:center;font-size:22px;font-weight:bold;border-radius: 10px 0 0 0;' colspan='12'>Pedidos de Compra Pendentes de Aprova็ใo</td>"
	cBuffer += "<td style='text-align:center;border-collapse: collapse;background-color: #96191d; color: white;border-bottom: 1px solid white;border-right: 0px solid white;border-radius: 0 10px 0 0;' colspan='" + cValToChar(nMaxAprov) + "'>Nํveis de Aprova็ใo</td>"
	cBuffer += "</tr> "
	
	cBuffer += "<tr style='border-collapse: collapse;background-color: #96191d; color: white;'>"
	cBuffer += "<td class='cabec' style='text-align:center'>Filial</td>"
	cBuffer += "<td class='cabec' style='text-align:center'>Dt. Pedido</td>"
	cBuffer += "<td class='cabec' style='text-align:center'>Hr. Pedido</td>"
	cBuffer += "<td class='cabec' style='text-align:center'>Pedido</td>" 
	//cBuffer += "<td class='cabec' style='text-align:center'>CNPJ</td>" 
	cBuffer += "<td class='cabec' style='text-align:center'>Fornecedor</td>"
	cBuffer += "<td class='cabec' style='text-align:center'>Cond. Pag.</td>"
	cBuffer += "<td class='cabec' style='text-align:center'>Dt. Entrega</td>"
	cBuffer += "<td class='cabec' style='text-align:center'>Moeda</td>"  
	cBuffer += "<td class='cabec' style='text-align:center'>Total</td>"
	cBuffer += "<td class='cabec' style='text-align:center'>Invest.</td>"
	cBuffer += "<td class='cabec' style='text-align:center'>Comprador</td>"
	cBuffer += "<td class='cabec' style='text-align:center'>Centro de Custo</td>"
	
	//Adiciona campos de nํveis de aprova็ใo.
	For i := 1 To nMaxAprov
	
		If i == nMaxAprov
			cBuffer += "<td style='text-align:center'>Nv" + cValToChar(i) + "</td>"
		
		Else
			cBuffer += "<td class='cabec' style='text-align:center'>Nv" + cValToChar(i) + "</td>"
			
		EndIf
		
	Next i
	
	cBuffer += "</tr>"
	
	For i := 1 To Len(aDados)
		
		cFornecedor	:= Alltrim(cValToChar(aDados[i][6]))
		cTotal		:= Transform(Val(cValToChar(aDados[i][10])),"@E 999,999,999.99")
		cFilNm		:= Alltrim(cValToChar(FWFilialName(cEmpAnt,Alltrim(cValToChar(aDados[i][1])),1)))
		
		//Obt้m os prazos de pagamento da condi็ใo de pagamento.
	   aCondPag  := CondPag(cTotal,Alltrim(cValToChar(aDados[i][7])))
/*	   cPrazoPag := ""
	   For x := 1 To Len(aCondPag)
			cPrazoPag += cValToChar(aCondPag[x][1]) + " " 
			
	   Next x*/
	   
	    cFxCor := ""
	   	If (i%2) == 0
	   		cFxCor := ""
	   		
	   	Else
	   		cFxCor := " style='background-color:#f7cd8a;' "
	   		
	   	EndIf
		
		cBuffer += " <tr " + cFxCor + ">"
		
		cBuffer += " <td>" + Alltrim(cValToChar(aDados[i][1])) + "-" + cFilNm + "</td>" //Filial.
		cBuffer += " <td>" + Alltrim(cValToChar(aDados[i][2])) + "</td>"
		cBuffer += " <td>" + Alltrim(cValToChar(aDados[i][3])) + "</td>"
		cBuffer += " <td>" + Alltrim(cValToChar(aDados[i][4])) + "</td>"
		//cBuffer += " <td>" + Alltrim(cValToChar(aDados[i][5])) + "</td>"
		cBuffer += " <td>" + cFornecedor + "</td>"
		cBuffer += " <td>" + Alltrim(cValToChar(aDados[i][7])) + "</td>"
		
		If CToD(cValToChar(aDados[i][8])) < Date()
			cFxEnt := " style='background-color:red;color:black;' "
			
		ElseIf CToD(cValToChar(aDados[i][8])) == Date()
			cFxEnt := " style='background-color:yellow;color:black;' "
			
		Else
			cFxEnt:= " style='background-color:green;color:black;' "
			
		EndIf
		
		//Obt้m os centros de custo.
		cCC := obtCC(Alltrim(cValToChar(aDados[i][1])),Alltrim(cValToChar(aDados[i][4])))
		
		cBuffer += " <td " + cFxEnt + ">" + Alltrim(cValToChar(aDados[i][8])) + "</td>"
		cBuffer += " <td>" + Alltrim(cValToChar(aDados[i][9])) + "</td>"
		cBuffer += " <td style='text-align:right;'>" + Alltrim(cValToChar(cTotal)) + "</td>"
		cBuffer += " <td>" + Alltrim(cValToChar(aDados[i][11])) + "</td>"
		cBuffer += " <td>" + Alltrim(cValToChar(aDados[i][12])) + "</td>"
		cBuffer += " <td>" + cCC + "</td>"
		
		//
		aProvadores := obtAprovadores(Alltrim(cValToChar(aDados[1][13])),Alltrim(cValToChar(aDados[i][4])))
		nNumAprov	:= Len(aProvadores)
		//
		For x := 1 To Len(aProvadores)
			
			cFxCor := ""
			If Alltrim(cValToChar(aDados[1][13])) == Alltrim(cValToChar(aProvadores[x][2]))
				cFxCor := " style='background-color:#28377c;color:white;' "
				  
			Else
				cFxCor := ""
				
			Endif
			
			cBuffer += "<td " + cFxCor + " >"
			cBuffer += "<p>" + Alltrim(cValToChar(aProvadores[x][3])) + "</p>"
			
			If ! Empty(Alltrim(cValToChar(aProvadores[x][4])))
			
				cBuffer += "<p> Dt. Lib: " + DToC(SToD(Alltrim(cValToChar(aProvadores[x][4])))) + "</p>"
				cBuffer += "<p> Hr. Lib: " + Alltrim(cValToChar(aProvadores[x][5])) + "</p>"
			
			EndIf
			
			cBuffer += "</td>"
		
		Next x
		//Iif(.T.,MsgAlert(cValToChar(nNumAprov) + " " + Alltrim(cValToChar(aDados[1][13])) + " " + Alltrim(cValToChar(aDados[i][4])) + " -- " + cValToChar(nMaxAprov) ),Nil)
		//
		If  (nMaxAprov > nNumAprov)
			
			For x := 1 To (nMaxAprov - nNumAprov)
				cBuffer += "<td></td>"
				
			Next x
			
		EndIf
		
		cBuffer += " </tr>"
	
	Next i
		
	cBuffer += "</table>"
	cBuffer += "</td>"
	cBuffer += "</tr>"
	cBuffer += "</table>"
	cBuffer += "</div>"
	cBuffer += "</body>"
	cBuffer += "</html>"
	
	//Enviar e-mail.
	enviarEmail(cAssunto,cBuffer,cEmail,cAtach)
	
	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณobtCC             บ Autor ณ Everson บ Data ณ  16/05/2017    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณObt้m os centros de custo do pedido de compra.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 034873.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function obtCC(cFil,cNum)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea	 := GetArea()
	Local cQuery := ""
	Local cCC	 := ""
	Local aCC	 := {}
	//Iif(.T.,MsgAlert(cFil + " " + cNum),Nil)
	//
	cFil := Alltrim(cValToChar(cFil))
	cNum := Alltrim(cValToChar(cNum))
	
	cQuery := " SELECT C7_CC FROM " + RetSqlName("SC7") + " (NOLOCK) AS SC7 WHERE SC7.D_E_L_E_T_ = '' AND C7_FILIAL = '" + cFil + "' AND C7_NUM = '" + cNum + "' "
	
	//
	If Select("CC_SC7") >0
		CC_SC7->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "CC_SC7"
	
	DbSelectArea("CC_SC7")
	CC_SC7->(DbGoTop())
	While ! CC_SC7->(Eof())
	
		If Ascan(aCC,{|x| Alltrim(cValToChar(x[1])) == Alltrim(cValToChar(CC_SC7->C7_CC)) }) == 0
	
		Aadd(aCC,{Alltrim(cValToChar(CC_SC7->C7_CC))})
		
		EndIf
		
		CC_SC7->(DbSkip())
	EndDo
	DbCloseArea("CC_SC7")
	
	//
	For i := 1 To Len(aCC)
		cCC += Alltrim(cValToChar(aCC[i][1])) + " | "
		
	Next i
	
	cCC := Substr(cCC,1,Len(cCC) -2)

	RestArea(aArea)
	
Return cCC
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณmaxNvAprv         บ Autor ณ Everson บ Data ณ  08/05/2017    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณObt้m o n๚mero mแximo de nํvel de aprova็ใo.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 034873.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function maxNvAprv(cUsuario)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cQuery 	:= ""
	Local nNum		:= 0
	
	cUsuario := Alltrim(cValToChar(cUsuario))
	
	cQuery := ""
	cQuery := " SELECT MAX(CR_NIVEL) AS CR_NIVEL FROM " + RetSqlName("SCR") + " (NOLOCK) AS SCR WHERE SCR.D_E_L_E_T_ = '' AND CR_FILIAL+CR_NUM IN "
	cQuery += " ( "
	cQuery += " SELECT CR_FILIAL+CR_NUM AS CR_NIVEL FROM " + RetSqlName("SCR") + " (NOLOCK) AS SCR WHERE SCR.D_E_L_E_T_ = '' AND CR_USER = '" + cUsuario + "' AND CR_STATUS = '02' "
	cQuery += " ) "
	
	If Select("NR_NV") > 0
		NR_NV->(DbCloseARea())
		
	EndIf
	
	TcQuery cQuery New Alias "NR_NV"
	DbSelectArea("NR_NV")
		nNum := Val(cValToChar(NR_NV->CR_NIVEL))
	DbCloseArea("NR_NV")
	
Return nNum
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณobtAprovadores    บ Autor ณ Everson บ Data ณ  08/05/2017    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณObt้m aprovadores.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 034873.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function obtAprovadores(cUsuario,cPedido)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local aAporv	:= {}
	Local cNmCompl	:= ""
	Local aNmCompl	:= {}
	
	//
	cUsuario := Alltrim(cValToChar(cUsuario))
	cPedido	 := Alltrim(cValToChar(cPedido))
	
	//
	cQuery := ""
	cQuery := " SELECT CR_NIVEL, CR_USER, CR_DATALIB, CR_XHORA FROM " + RetSqlName("SCR") + " (NOLOCK) AS SCR WHERE SCR.D_E_L_E_T_ = '' AND CR_FILIAL+CR_NUM IN "
	cQuery += " ( "
	cQuery += " SELECT CR_FILIAL+CR_NUM AS CR_NIVEL FROM " + RetSqlName("SCR") + " (NOLOCK) AS SCR WHERE SCR.D_E_L_E_T_ = '' "
	cQuery += " AND CR_USER = '" + cUsuario + "' AND CR_STATUS = '02' AND CR_NUM = '" + cPedido + "' "
	cQuery += " ) "
	cQuery += " ORDER BY CR_NIVEL "
	
	If Select("NR_NV") > 0
		NR_NV->(DbCloseARea())
		
	EndIf
	
	TcQuery cQuery New Alias "NR_NV"
	DbSelectArea("NR_NV")
	While ! NR_NV->(Eof())
	
		cNmCompl := cValToChar(UsrFullName(Alltrim(cValToChar(NR_NV->CR_USER))))
		
		aNmCompl := StrtoKarr(cNmCompl," ")
		
		Aadd(aAporv,{NR_NV->CR_NIVEL,NR_NV->CR_USER,Iif(Len(aNmCompl) > 0,aNmCompl[1],"ERRO!!!"),CR_DATALIB,CR_XHORA})
		
		NR_NV->(DbSkip())
	EndDo
	DbCloseArea("NR_NV")
	
	//
	RestArea(aArea)
	
Return aAporv
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณenviarEmail       บ Autor ณ Everson บ Data ณ  05/05/2017    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณEnvia e-mail.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 034873.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function enviarEmail(cAssunto,cMensagem,cEmail,cAtach)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	 Local lOk           := .T.
	 Local cBody         := cMensagem
	 Local cErrorMsg     := ""
	 Local aFiles        := {}
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
	       ConOut("Nใo foi possํvel enviar o e-mail ao comprador. 3 - " + cErrorMsg)
	       
	    EndIf
	    
	 Else
	    Get Mail Error cErrorMsg
	    ConOut("Nใo foi possํvel enviar o e-mail ao comprador. 4 - " + cErrorMsg)
	    
	 EndIf
	 
	 If lOk
	    Disconnect Smtp Server
	    
	 EndIf
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณscripSCR          บ Autor ณ Everson บ Data ณ  05/05/2017    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณScript sql com os dados dos pedidos de compra.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 034873.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function scripSCR()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local cQuery	:= ""
	
	cQuery += " SELECT " 
	cQuery += " DISTINCT CR_FILIAL " 
	cQuery += " , CONVERT(VARCHAR(10),CAST(ITENS.C7_EMISSAO AS DATE),103) AS C7_EMISSAO " 
	cQuery += " , CR_NUM " 
	cQuery += " , CR_TOTAL " 
	cQuery += " , CR_APROV " 
	cQuery += " , CR_USER " 
	cQuery += " , ITENS.C7_FORNECE " 
	cQuery += " , ITENS.C7_LOJA " 
	cQuery += " , ITENS.C7_USER "
	cQuery += " , ITENS.C7_PROJETO "
	cQuery += " , ITENS.C7_XHORA "
	cQuery += " , ITENS.A2_NOME "
	cQuery += " , ITENS.A2_CGC " 
	cQuery += " , CR_USERLIB  " 
	cQuery += " , ITENS.C7_MOEDA "
	cQuery += " , CR_TIPO " 
	cQuery += " , CONVERT(VARCHAR(10),CAST(ITENS.C7_DATPRF AS DATE),103) AS C7_DATPRF, ITENS.C7_COND, CR_NIVEL "
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SCR") + " (NOLOCK) AS SCR " 
	cQuery += " INNER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT  " 
	cQuery += " DISTINCT C7_FILIAL, C7_NUM, C7_FORNECE, C7_LOJA, A2_CGC, A2_NOME, C7_MOEDA,C7_DATPRF, C7_EMISSAO, C7_COND, C7_USER, CASE WHEN C7_PROJETO <> '' THEN 'Sim' ELSE 'Nใo' END AS C7_PROJETO  ,MAX(C7_XHORA) AS C7_XHORA "
	cQuery += " FROM  " 
	cQuery += "  " + RetSqlName("SC7") + "  (NOLOCK) AS SC7  " 
	cQuery += " INNER JOIN " 
	cQuery += "  " + RetSqlName("SA2") + "  (NOLOCK) AS SA2 " 
	cQuery += " ON C7_FORNECE = A2_COD " 
	cQuery += " AND C7_LOJA = A2_LOJA " 
	cQuery += " WHERE  " 
	cQuery += " SC7.D_E_L_E_T_ = '' " 
	cQuery += " AND C7_CONAPRO = 'B' " 
	cQuery += " GROUP BY "
	cQuery += " C7_FILIAL, C7_NUM, C7_FORNECE, C7_LOJA, A2_CGC, A2_NOME, C7_MOEDA,C7_DATPRF, C7_EMISSAO, C7_COND, C7_USER, C7_PROJETO "
	cQuery += " ) AS ITENS ON " 
	cQuery += " SCR.CR_FILIAL = ITENS.C7_FILIAL " 
	cQuery += " AND SCR.CR_NUM = ITENS.C7_NUM " 
	cQuery += " WHERE " 
	cQuery += " SCR.D_E_L_E_T_ = '' " 
	cQuery += " AND CR_STATUS = '02' " 
	cQuery += " AND CR_TIPO = 'PC' " 
	cQuery += " AND CR_USER <> '' " 
	cQuery += " AND ITENS.C7_EMISSAO >= '20170101' " 
	cQuery += " ORDER BY " 
	cQuery += " CR_USER, CR_FILIAL, CR_NUM " 
	
Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCondPag   บAutor  ณEverson         บData     ณ05/05/2017    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo retornar os prazos da condi็ใo de pagamento.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 034873.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CondPag(nValor,cCondicao)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclara็ใo de variแveis.                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	Local aArea		:= GetArea()	
	Local aDatas		:= {}
	Local i			:= 1
	Local nValor		:= 1000
	Local nValIpi		:= 0
	Local dDEmissao	:= Date()
	Local nValSol		:= 0
	Local cParcela	:= ""
	Local aParcelas	:= {}
	
	aDatas 	:= Condicao(nValor,cCondicao,nValIpi,dDEmissao,nValSol)
	
	For i := 1 To Len(aDatas)
		cParcela := cValToChar(DateDiffDay(CToD(cValToChar(aDatas[i][1])),Date()))
		Aadd(aParcelas,{cParcela})

	Next i
	
	RestArea(aArea)
	
Return aParcelas
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlogZBN    บ Autor ณ Everson 			 บ Data ณ  30/05/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Log Job.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 034873.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function logZBN(cStatus)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADCOM008R'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADCOM008R'
			ZBN_DESCRI  := 'Gerar relat๓rio de pedidos pendentes de aprova็ใo'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'DIA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '12:00:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '12:00:00'
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADCOM008R'
			ZBN_DESCRI  := 'Gerar relat๓rio de pedidos pendentes de aprova็ใo'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'DIA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '12:00:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '12:00:00'
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return Nil