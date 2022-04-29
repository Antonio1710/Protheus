#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} User Function nomeFunction
	Ponto de entrada de exclusão de nota fiscal de saída. 
	Chamado 038133.
	@type  Function
	@author Everson
	@since 11/12/17
	@version 01
	@history Ricardo Lima-17/10/18|CH:037647, exclui integração RNX2
	@history Ricardo Lima-19/11/18|CH:044314|Controle de Frete, exclui frete na exclusão da nota.
	@history Everson-09/04/2019|CH:044314| Alterada a opção para excluir frete na exclusão da nota.
	@history Everson-14/05/2019|CH:044314| Removido estorno do frete.
	@history Everson, 22/03/2022, Chamado 18465. Envio de informações ao barramento. 
	@history ticket 71972 - Fernando Macieira - 28/04/2022 - Complemento Frango Vivo - Granja HH - Filial 0A
/*/
User Function SF2520E()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea	    := GetArea()
	                                                                         
	// Filial Frango Vivo
	Local cFilPV  := GetMV("MV_#LFVNEW",,"03|0A") // GetMV("MV_#LFVFIL",,"03") // @history ticket 71972 - Fernando Macieira - 28/04/2022 - Complemento Frango Vivo - Granja HH - Filial 0A

	// Dados do PV
	Local cCliCod := GetMV("MV_#LFVCLI",,"027601")
	Local cCliLoj := GetMV("MV_#LFVLOJ",,"00")
//	Local cProdPV := GetMV("MV_#LFVPRD",,"100253")   // APENAS DEBUG
	Local cProdPV := GetMV("MV_#LFVPRD",,"300042")  //  publicar este em producao
	Local cTESPV  := GetMV("MV_#LFVTES",,"701")   

	Local sFilRc    := SuperGetMv( "MV_#M46F1" , .F. , '' ,  ) // Ricardo Lima - 17/10/18
	Local sCliRc    := SuperGetMv( "MV_#M46F2" , .F. , '' ,  ) // Ricardo Lima - 17/10/18
	Local cFilGFrt  := Alltrim(SuperGetMv( "MV_#M46F5" , .F. , '' ,  )) // Ricardo Lima-19/11/18|CH:044314
	
	//
	If cEmpAnt == "01"

		grvBarr("D", SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA, SF2->F2_DOC, SF2->F2_SERIE) //Everson, 22/03/2022, Chamado 18465.
	
		updSAG()


		// Chamado: 037757
		// - FWNM - 24/04/2018
		// - Excluir pre-nota de entrada automaticamente na filial 02 a partir da exclusão da NF de Complemento FRANGO VIVO da filial 03
		
			// Posiciono no item (sempre 1)
			SD2->( dbSetOrder(3) ) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			If SD2->( dbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA) )
			
				SC5->( dbSetOrder(1) ) // C5_FILIAL+C5_NUM                                                                                                                                                
				If SC5->( dbSeek(SD2->D2_FILIAL+SD2->D2_PEDIDO) )
				//If SC5->( dbSeek(cFilPV+SD2->D2_PEDIDO) ) // @history ticket 71972 - Fernando Macieira - 28/04/2022 - Complemento Frango Vivo - Granja HH - Filial 0A
			
					If SC5->(FieldPos("C5_XLFVCMP")) > 0

						//If AllTrim(SF2->F2_FILIAL) == cFilPV .and. AllTrim(SF2->F2_CLIENTE) == cCliCod .and. AllTrim(SF2->F2_LOJA) == cCliLoj .and. AllTrim(SD2->D2_COD) == cProdPV .and. AllTrim(SD2->D2_TES) == cTESPV  .and. AllTrim(SC5->C5_XLFVCMP) == "S"  // @history ticket 71972 - Fernando Macieira - 28/04/2022 - Complemento Frango Vivo - Granja HH - Filial 0A
						If AllTrim(SF2->F2_FILIAL) $ cFilPV .and. AllTrim(SF2->F2_CLIENTE) == cCliCod .and. AllTrim(SF2->F2_LOJA) == cCliLoj .and. AllTrim(SD2->D2_COD) == cProdPV .and. AllTrim(SD2->D2_TES) == cTESPV  .and. AllTrim(SC5->C5_XLFVCMP) == "S"
							msAguarde( { || ExcPreNFE() }, "Excluindo Pré-Nota Entrada Complemento Frango Vivo (SF2520E)" )
						EndIf
						
					Else 

						//If AllTrim(SF2->F2_FILIAL) == cFilPV .and. AllTrim(SF2->F2_CLIENTE) == cCliCod .and. AllTrim(SF2->F2_LOJA) == cCliLoj .and. AllTrim(SD2->D2_COD) == cProdPV .and. AllTrim(SD2->D2_TES) == cTESPV // @history ticket 71972 - Fernando Macieira - 28/04/2022 - Complemento Frango Vivo - Granja HH - Filial 0A
						If AllTrim(SF2->F2_FILIAL) $ cFilPV .and. AllTrim(SF2->F2_CLIENTE) == cCliCod .and. AllTrim(SF2->F2_LOJA) == cCliLoj .and. AllTrim(SD2->D2_COD) == cProdPV .and. AllTrim(SD2->D2_TES) == cTESPV
							msAguarde( { || ExcPreNFE() }, "Excluindo Pré-Nota Entrada Complemento Frango Vivo (SF2520E)" )
						EndIf
					
					EndIf
					
				EndIf
	
			EndIf
	
		// 
        


		// Chamado: 036729 - Estoque em trânsito - sempre 1 item
		// - FWNM - 22/05/2018

		cFilOrig  := GetMV("MV_#TRAFIL",,"08")
		If SF2->F2_FILIAL == cFilOrig
		
			// - Gerar entrada no almoxarifado 95 (Estoque em Trânsito) 
			cCliTran  := GetMV("MV_#TRACLI",,"014999")        
			cLojTran  := GetMV("MV_#TRALO1",,"00")        
			cProdTra  := GetMV("MV_#TRAPRD",,"383369")        
	
			// Posiciono no item (sempre 1)
			SD2->( dbSetOrder(3) ) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			SD2->( dbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA) )

			If AllTrim(SF2->F2_CLIENTE) == AllTrim(cCliTran) .and. AllTrim(SF2->F2_LOJA) == AllTrim(cLojTran) .and. AllTrim(SD2->D2_COD) == AllTrim(cProdTra)
			
				aAreaSF4 := SF4->( GetArea() )
				
				SF4->( dbSetOrder(1) ) 
				If SF4->( dbSeek(xFilial("SF4")+AllTrim(SD2->D2_TES)) )
					If AllTrim(SF4->F4_TRANSIT) == "S" .and. AllTrim(SF4->F4_ESTOQUE) == "S" 
						msAguarde( { || GeraExcTran() }, "Gerando estorno do estoque em trânsito (SF2520E)" )
					EndIf
				EndIf
			
				RestArea( aAreaSF4 )
		
			EndIf
		EndIf
		// Ricardo Lima - 17/10/18 | CH:037647
		If cFilAnt = sFilRc
			If sCliRc = SF2->F2_CLIENTE+SF2->F2_LOJA
				Processa({|| INTNFEXL(SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA) },,"Integração de Pré-Nota de entrada - Exclusão")
			Endif
		Endif
		
		//Everson-14/05/2019|CH:044314
/*		//Ricardo Lima-19/11/18|CH:044314
		If cFilAnt $ cFilGFrt
			ConOut('Inicio StartJob para Estorno de Frete')
				StartJob( "U_ADLOG042P" , GetEnvServer() , .F. , cEmpAnt , cFilAnt , SF2->F2_DOC , SF2->F2_SERIE , SF2->F2_CLIENTE , SF2->F2_LOJA , SC5->C5_NUM , '3' ) //Everson - 09/04/2019. Alterada opção de 2 para 3.
			ConOut('Fim StartJob para Estorno de Frete')
		Endif*/

	EndIf

	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³updSAG    º Autor ³ Everson            º Data ³  11/12/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Realiza update no banco integração SAG.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Chamado 038133.                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function updSAG()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea	    := GetArea()
	// Local nTcConn1	:= advConnection()
	// Local nTcConn2  := 0
	// Local cNomBco2  := GetPvProfString("INTSAGBD","BCO2","ERROR",GetADV97())
	// Local cSrvBco2  := GetPvProfString("INTSAGBD","SRV2","ERROR",GetADV97())
	// Local cPortBco2 := Val(GetPvProfString("INTSAGBD","PRT2","ERROR",GetADV97()))
	Local cPedSAG	:= ""
	Local cTabegene	:= ""
	
	//
	cPedSAG	  := Alltrim(cValToChar(Posicione("SC5",15,xFilial("SC5") + Alltrim(cValToChar(SF2->F2_DOC)) + Alltrim(cValToChar(SF2->F2_SERIE)),"C5_PEDSAG")))
	cTabegene := Alltrim(cValToChar(Posicione("SC5",15,xFilial("SC5") + Alltrim(cValToChar(SF2->F2_DOC)) + Alltrim(cValToChar(SF2->F2_SERIE)),"C5_TABEGEN")))
	
	//
	If Empty(cPedSAG)
		RestArea(aArea)
		Return Nil
			
	EndIf
	
	//
	// TcConType("TCPIP")
	// If (nTcConn2 := TcLink(cNomBco2,cSrvBco2,cPortBco2)) < 0
	// 	MsgInfo("Não foi possível  conectar ao banco integração para ajustar a tabela SGPED010, verifique com o administrador.","updSAG (SF2520E)")
	// 	RestArea(aArea)
	// 	Return Nil
		
	// EndIf
	
	//
	//TcSetConn(nTcConn2)
	If 0 > TcSqlExec("UPDATE SGPED010 SET C5_NOTA = NULL , C5_SERIE = NULL, STATUS_INT = '', OPERACAO_INT = 'A' WHERE C5_FILIAL = '" + cFilAnt + "' AND C5_NUM='" + cPedSAG + "' AND TABEGENE = '" + cTabegene + "' ")
		MsgInfo("Não foi possível atualizar o registro no banco interface: " + Chr(13) + Chr(10) + TCSQLError(),"updSAG (SF2520E)")
		
	EndIf

	//
	//TcSetConn(nTcConn1)
	RestArea(aArea)
	
Return Nil



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SF2520E   ºAutor  ³Fernando Macieira   º Data ³ 24/04/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exclui Pre Nota - Complemento Frango Vivo                  º±±
±±º          ³ Chamado 037757                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ExcPreNFE()


Local _aCabec := {}
Local _aItens := {}

Local cCliCNPJ := ""
Local cFornCod := ""
Local cLojaCod := ""
Local cF1DOC   := ""     
Local lClass   := .t.

Local aAreaAtu := GetArea()

Local aAreaSA1 := SA1->( GetArea() )
Local aAreaSF1 := SF1->( GetArea() )
Local aAreaSD1 := SD1->( GetArea() )

Local aAreaSA2 := SA2->( GetArea() )
Local aAreaSF2 := SF2->( GetArea() )
Local aAreaSD2 := SD2->( GetArea() )

Local cQuery   := ""
Local aStruSD1 := {}

Local cFilBkp := cFilAnt

// Dados da Pre-Nota
Local cFilPre   := GetMV("MV_#LFVPRE",,"02")
Local cFornCod  := GetMV("MV_#LFVFOR",,"000217")
Local cLojaCod  := GetMV("MV_#LFVLOJ",,"01")
Local cCC       := GetMV("MV_#LFVCC" ,,"9999")
Local cCtaCtb   := GetMV("MV_#LFVCTA",,"111520005")
Local cItemCtb  := GetMV("MV_#LFVITC",,"121")
Local cLocal    := GetMV("MV_#LFVALM",,"16")
Local cEspLFV   := GetMV("MV_#LFVESP",,"SPED")
Local nX		:= 1


// Posiciona CLIENTE
SA1->( dbSetOrder(1) ) // A1_FILIAL+A1_COD+A1_LOJA
SA1->( dbSeek(xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA)) )

// Posiciona FORNECEDOR
//SA2->( dbSetOrder(3) ) // A2_FILIAL+A2_CGC
//If SA2->( dbSeek(xFilial("SA2")+SA1->A1_CGC) ) // // Inibido e tratado via parametros devido CNPJs em duplicidade ou incorretos

SA2->( dbSetOrder(1) ) // A2_FILIAL+A2_COD+A2_LOJA
If SA2->( dbSeek(xFilial("SA2")+cFornCod+cLojaCod) )
	cNReduz  := SA2->A2_NREDUZ
EndIf


// Num DOC entrada
cF1DOC := StrZero(Val(SF2->F2_DOC),TamSx3("F1_DOC")[1])

cFilAvs := cFilPre
cSerAvs := SF2->F2_SERIE

SF1->( dbSetOrder(1) ) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
If SF1->( dbSeek(cFilPre+cF1DOC+SF2->F2_SERIE+cFornCod+cLojaCod+"N") )

	// Verifico se esta classificada
	SD1->( dbSetOrder(1) ) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM                                                                                                     
	If SD1->( dbSeek(cFilPre+cF1DOC+SF2->F2_SERIE+cFornCod+cLojaCod) )
		If Empty(SD1->D1_TES)      
			lClass  := .f.
			cTxtAvs := "Pré-Nota "
		EndIf
	EndIf

	// Cabecalho NF Entrada
	_aCabec := 	{ {'F1_FILIAL'	, cFilPre	, NIL},;
	{'F1_TIPO'		, 'N'			 , NIL},;
	{'F1_FORMUL'	, 'N'			 , NIL},;
	{'F1_DOC'		, cF1DOC         ,NIL},;
	{'F1_SERIE' 	, SF2->F2_SERIE	 , NIL},;
	{'F1_EMISSAO'	, SF2->F2_EMISSAO, NIL},;
	{'F1_FORNECE'	, cFornCod		 , NIL},;
	{'F1_LOJA'		, cLojaCod		 , NIL},;
	{'F1_ESPECIE'	, cEspLFV 		 , NIL} }
	
	
	// Itens NF Entrada
	_aItens  := {}
	
	aStruSD1 := SD1->(dbStruct())
	
	// Carrega Itens NF
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	
	cQuery := " SELECT D1_FILIAL, D1_COD, D1_UM, D1_QUANT, D1_VUNIT, D1_TOTAL, D1_VALIPI, D1_VALICM, D1_TES, D1_IPI, D1_PICM, D1_PESO, D1_CONTA, D1_CC, D1_LOCAL "
	cQuery += " FROM " + RetSqlName("SD1")
	cQuery += " WHERE D1_FILIAL='"+cFilPre+"' "
	cQuery += " AND D1_DOC='"+cF1DOC+"' "
	cQuery += " AND D1_SERIE='"+SF2->F2_SERIE+"' "
	cQuery += " AND D1_FORNECE='"+SF2->F2_CLIENTE+"' "
	cQuery += " AND D1_LOJA='"+SF2->F2_LOJA+"' "
	cQuery += " AND D_E_L_E_T_='' "
	tcQuery cQuery New Alias "Work"
	
	// Compatibiliza campos tipo DATA e VALOR
	For nX := 1 To Len(aStruSD1)
		If aStruSD1[nX][2] <> "C" .And. FieldPos(aStruSD1[nX][1])<>0
			TcSetField("Work",aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
		EndIf
	Next nX
	
	Work->( dbGoTop() )
	Do While Work->( !EOF() )
		
		aAdd( _aItens,{ {'D1_FILIAL'		,cFilPre		,NIL},;
		{'D1_COD'	, Work->D1_COD		,NIL},;
		{'D1_UM'	, Work->D1_UM		,NIL},;
		{'D1_QUANT'	, Work->D1_QUANT	,NIL},;
		{'D1_VUNIT'	, Work->D1_VUNIT	,NIL},;
		{'D1_TOTAL'	, Work->D1_TOTAL 	,NIL},;
		{'D1_VALIPI', Work->D1_VALIPI	,NIL},;
		{'D1_VALICM', Work->D1_VALICM	,NIL},;
		{'D1_TES'	, Work->D1_TES		,NIL},;
		{'D1_IPI'	, Work->D1_IPI		,NIL},;
		{'D1_PICM'	, Work->D1_PICM		,NIL},;
		{'D1_PESO'	, Work->D1_PESO		,NIL},;
		{'D1_CONTA'	, Work->D1_CONTA	,NIL},;
		{'D1_CC'	, Work->D1_CC   	,NIL},;
		{'D1_LOCAL'	, Work->D1_LOCAL	,NIL} } )
		
		Work->( dbSkip() )
		
	EndDo
	
	Work->( dbCloseArea() )
	
	// Exclui DOCUMENTO ENTRADA
	Begin Transaction
	
	// Mudo filial para codigo onde NF de entrada se encontra
	cFilAnt  := cFilPre
	
	lMsErroAuto := .F.
	dbSelectArea("SF1")
	If lClass
		msExecAuto({|x,y,z| MATA103(x,y,z)}, _aCabec, _aItens, 5) // Documento Entrada

	Else 
		msExecAuto({|x,y,z| MATA140(x,y,z)}, _aCabec, _aItens, 5) // Pre-Nota

	EndIf
	
	If lMsErroAuto
		MostraErro()
		
	Else
		Aviso("SF2520E-01", Iif(!lClass,cTxtAvs,"Nota Fiscal ")+"de Complemento de Frango Vivo" + chr(10) + chr(13) + chr(10) + chr(13) +;
		"Abaixo, dados da NF Excluída: " + chr(10) + chr(13) +;
		"Filial: " + cFilAvs + chr(10) + chr(13) +;
		"Número: " + cF1DOC  + chr(10) + chr(13) +;
		"Série: " + cSerAvs + chr(10) + chr(13) +;
		"Fornecedor: " + cFornCod + "/" + cLojaCod + chr(10) + chr(13) +;
		"Fantasia: " + cNReduz, {"&Ok"}, 3, "Nota Fiscal de Entrada Excluída com Sucesso!")
		
	EndIf
	
	// Restauro filial corrente
	cFilAnt := cFilBkp
	
	End Transaction
	
Else
	Aviso("SF2520E-01", "Conferir no destino a Nota Fiscal de Complemento de Frango Vivo..." + chr(10) + chr(13) + chr(10) + chr(13) +;
	"Abaixo, dados da NF que NÃO foi encontrada: " + chr(10) + chr(13) +;
	"Filial: " + cFilAvs + chr(10) + chr(13) +;
	"Número: " + cF1DOC  + chr(10) + chr(13) +;
	"Série: " + cSerAvs + chr(10) + chr(13) +;
	"Fornecedor: " + cFornCod + "/" + cLojaCod + chr(10) + chr(13) +;
	"Fantasia: " + cNReduz, {"&Ok"}, 3, "Atenção!!! Nota Fiscal de Entrada não encontrada para ser excluída...")
	
EndIf


RestArea( aAreaSA1 )
RestArea( aAreaSF1 )
RestArea( aAreaSD1 )

RestArea( aAreaSA2 )
RestArea( aAreaSF2 )
RestArea( aAreaSD2 )

RestArea( aAreaAtu )


Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M460FIM   ºAutor  ³Fernando Macieira   º Data ³  05/22/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera estorno do estoque em transito na filial de origem    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GeraExcTran()


Local aItens       := {}

Local cLocTran     := GetMV("MV_LOCTRAN",,"95") 
Local cTMPadrao    := GetMV("MV_#TRATME",,"201")    

Local cDescProd    := ""
Local cUMProd      := ""
Local cDescDestino := ""
Local cUMProdDes   := ""
Local aAreaSD2     := SD2->( GetArea() )


// Posiciono no Produto
SB1->( dbSetOrder(1) ) 
If SB1->( dbSeek(xFilial("SB1")+SD2->D2_COD) )
	cDescProd       := SB1->B1_DESC
	cUMProd         := SB1->B1_UM
	cDescDestino    := SB1->B1_DESC
	cUMProdDes      := SB1->B1_UM
EndIf

// Itens 
dbSelectArea("SD2")
dbSetOrder(3)
dbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)

Do While SD2->( !EOF() ) .and. SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) == SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)

	/*
	// Transferencias
	aAdd (aItens,{SD2->D2_DOC	 ,dDataBase})
	aAdd (aItens,{})
			
	aItens[2] :=  {{"D3_COD" 	, SD2->D2_COD	       ,NIL}} // 01.Produto Origem
	aAdd(aItens[2],{"D3_DESCRI" , cDescProd	 		   ,NIL}) // 02.Descricao
	aAdd(aItens[2],{"D3_UM"     , cUMProd   		   ,NIL}) // 03.Unidade de Medida
	aAdd(aItens[2],{"D3_LOCAL"  , SD2->D2_LOCAL 	   ,NIL}) // 04.Local Origem
	aAdd(aItens[2],{"D3_LOCALIZ", CriaVar("D3_LOCALIZ"),NIL}) // 05.Endereco Origem
	aAdd(aItens[2],{"D3_COD"    , SD2->D2_COD          ,NIL}) // 06.Produto Destino
	aAdd(aItens[2],{"D3_DESCRI" , cDescDestino	       ,NIL}) // 07.Descricao
	aAdd(aItens[2],{"D3_UM"     , cUMProdDes	       ,NIL}) // 08.Unidade de Medida
	aAdd(aItens[2],{"D3_LOCAL"  , cLocTran	           ,NIL}) // 09.Armazem Destino
	aAdd(aItens[2],{"D3_LOCALIZ", CriaVar("D3_LOCALIZ"),NIL}) // 10.Endereco Destino
	aAdd(aItens[2],{"D3_NUMSERI", CriaVar("D3_NUMSERI"),NIL}) // 11.Numero de Serie
	aAdd(aItens[2],{"D3_LOTECTL", CriaVar("D3_LOTECTL"),NIL}) // 12.Lote Origem
	aAdd(aItens[2],{"D3_NUMLOTE", CriaVar("D3_NUMLOTE"),NIL}) // 13.Sub-Lote
	aAdd(aItens[2],{"D3_DTVALID", CriaVar("D3_DTVALID"),NIL}) // 14.Data de Validade
	aAdd(aItens[2],{"D3_POTENCI", CriaVar("D3_POTENCI"),NIL}) // 15.Potencia do Lote
	aAdd(aItens[2],{"D3_QUANT"  , SD2->D2_QUANT		   ,NIL}) // 16.Quantidade
	aAdd(aItens[2],{"D3_QTSEGUM", CriaVar("D3_QTSEGUM"),NIL}) // 17.Quantidade na 2 UM
	aAdd(aItens[2],{"D3_ESTORNO", CriaVar("D3_ESTORNO"),NIL}) // 18.Estorno
	aAdd(aItens[2],{"D3_NUMSEQ" , CriaVar("D3_NUMSEQ") ,NIL}) // 19.NumSeq
	aAdd(aItens[2],{"D3_LOTECTL", CriaVar("D3_LOTECTL"),NIL}) // 20.Lote Destino
	aAdd(aItens[2],{"D3_DTVALID", CriaVar("D3_DTVALID"),NIL}) // 21.Data de Validade Destino			
	*/                                                   

	// Movimento Interno - Entrada Almoxarifado em Transito
	cNumSeqD3 := ""
	cNumSeqD3 := BscD3Seq(cLocTran, cTMPadrao)
	
	AADD(aItens, {"D3_TM"		,cTMPadrao   	 , Nil})
	AADD(aItens, {"D3_COD"		,SD2->D2_COD     , Nil})
	AADD(aItens, {"D3_UM"       ,SD2->D2_UM      , Nil})
	AADD(aItens, {"D3_QUANT"	,SD2->D2_QUANT   , Nil}) 
	AADD(aItens, {"D3_OP"   	,CriaVar("D3_OP"), Nil}) 
	AADD(aItens, {"D3_LOCAL"	,cLocTran        , Nil})
	AADD(aItens, {"D3_DOC"		,SD2->D2_DOC     , Nil})
	AADD(aItens, {"D3_EMISSAO"	,SD2->D2_EMISSAO , Nil})
	AADD(aItens, {"D3_FILIAL"	,SD2->D2_FILIAL  , Nil})
	aAdd(aItens, {"D3_NUMSEQ" , cNumSeqD3        , Nil})
	aAdd(aItens, {"INDEX"     , 4                , Nil})

//


	Begin Transaction
			             
		lMsErroAuto := .F.
							                
//		msExecAuto({|x| MATA261(x)},aItens,5) // Transferencias
		msExecAuto({|x,y| MATA240(x,y)}, aItens, 5) // Movimento Interno
					
		If lMsErroAuto 
					
			DisarmTransaction()
		
			Aviso("M460FIM-03", "Será necessário lançar manualmente o estorno do estoque em trânsito..." + chr(10) + chr(13) +;
			"Verifique os CADASTROS... " + chr(10) + chr(13) + chr(10) + chr(13) +;
			"Abaixo, dados da Nota que NÃO gerou estorno do estoque em trânsito: " + chr(10) + chr(13) +;
			"Filial: " + SD2->D2_FILIAL + chr(10) + chr(13) +;
			"Documento: " + SD2->D2_DOC  + chr(10) + chr(13) +;
			"Produto: " + SD2->D2_COD + chr(10) + chr(13) +;
			"Almoxarifado Saída: " + SD2->D2_LOCAL + chr(10) + chr(13) +;
			"Almoxarifado Trânsito: " + cLocTran + chr(10) + chr(13) +;
			"", {"&Ok"}, 3, "ESTORNO do Estoque em Trânsito NÃO foi Gerado! Cadastros inconsistentes!")

			MostraErro()
		
		EndIf
			
	End Transaction		

	aItens    := {}

	SD2->( dbSkip() )

EndDo

RestArea( aAreaSD2 )

Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SF2520E   ºAutor  ³Microsiga           º Data ³  06/04/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function BscD3Seq(cLocTran, cTMPadrao)

Local cSeqD3 := ""
Local cQuery := ""

If Select("Work") > 0
	Work->( dbCloseArea() )
EndIf

cQuery := " SELECT D3_NUMSEQ "
cQuery += " FROM " + RetSqlName("SD3")
cQuery += " WHERE D3_FILIAL='"+SD2->D2_FILIAL+"' "
cQuery += " AND D3_COD='"+SD2->D2_COD+"' "
cQuery += " AND D3_LOCAL='"+cLocTran+"' "
cQuery += " AND D3_EMISSAO='"+DtoS(SD2->D2_EMISSAO)+"' "
cQuery += " AND D3_DOC='"+SD2->D2_DOC+"' "
cQuery += " AND D3_TM='"+cTMPadrao+"' "
cQuery += " AND D3_ESTORNO='' "
cQuery += " AND D_E_L_E_T_='' "
cQuery += " ORDER BY R_E_C_N_O_ DESC "

tcQuery cQuery new alias "Work"

Work->( dbGoTop() )
If Work->( !EOF() )
	cSeqD3 := Work->D3_NUMSEQ
EndIf

If Select("Work") > 0
	Work->( dbCloseArea() )
EndIf

Return cSeqD3
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºAlteração ³Ricardo Lima-17/10/18|CH:037647, exclui integração RNX2     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function INTNFEXL(cF2DOC,cF2SERIE,cF2CLIENTE,cF2LOJA)

	Private lExec    := .F.
	Private cQuery   := ""
	Private aAreaSM0 := {}
	Private cEmpBkp  := ""
	Private cFilBkp  := ""

	Private aCabec   := {}
	Private aItens   := {}
	Private cCnpj    := ""
	Private cEpEntNF := SuperGetMv( "MV_#M46F3" , .F. , '' ,  )
	Private cFlEntNF := SuperGetMv( "MV_#M46F4" , .F. , '' ,  )
	Private cCodFor  := ""
	Private cLojFor  := ""
	Private cNewEmp  := cEpEntNF
	Private cOldEmp  := cEmpAnt

	dbSelectArea("SF2")
	dbSetOrder(1)
	if dbseek( FWxFilial("SF2") + cF2DOC + cF2SERIE + cF2CLIENTE + cF2LOJA )
		
		cCnpj := SM0->M0_CGC

		If EmpChangeTable("SA2",cNewEmp,cOldEmp,3) 
			dbSelectArea("SA2")
			dbSetOrder(3)
			If DbSeek( xFilial( "SA2" ) + cCnpj )
				cCodFor := SA2->A2_COD
				cLojFor := SA2->A2_LOJA
			EndIf
		EmpChangeTable("SA2",cOldEmp,cNewEmp,1 )
		EndIF
		
		aadd(aCabec,{"F1_FORNECE" , cCodFor         , Nil})
		aadd(aCabec,{"F1_LOJA"    , cLojFor         , Nil})
		aadd(aCabec,{"F1_EST"     , SF2->F2_EST     , Nil})
		aadd(aCabec,{"F1_FILIAL"  , cFlEntNF        , Nil})
		aadd(aCabec,{"F1_TIPO"    , SF2->F2_TIPO    , Nil})
		aadd(aCabec,{"F1_FORMUL"  , "N"             , Nil})
		aadd(aCabec,{"F1_DOC"     , SF2->F2_DOC     , Nil})
		aadd(aCabec,{"F1_SERIE"   , SF2->F2_SERIE   , Nil})
		aadd(aCabec,{"F1_EMISSAO" , SF2->F2_EMISSAO , Nil})
		aadd(aCabec,{"F1_ESPECIE" , SF2->F2_ESPECIE , Nil})

		cQuery := " SELECT * "
		cQuery += " FROM "+RetSqlName("SD2")+" D2 "
		cQuery += " WHERE D2_FILIAL = '"+SF2->F2_FILIAL+"' "
		cQuery += " AND D2_CLIENTE = '"+SF2->F2_CLIENTE+"' AND D2_LOJA = '"+SF2->F2_LOJA+"' "
		cQuery += " AND D2_DOC = '"+SF2->F2_DOC+"' AND D2_SERIE = '"+SF2->F2_SERIE+"' "
		cQuery += " AND D2.D_E_L_E_T_ = ' ' "

		If Select("INTNFEXL") > 0
			INTNFEXL->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "INTNFEXL"
		
		While INTNFEXL->(!Eof())

			aadd(aItens,{"D1_ITEM"   , INTNFEXL->D2_ITEM   , Nil})
			aadd(aItens,{"D1_COD"    , INTNFEXL->D2_COD    , Nil})
			aadd(aItens,{"D1_UM"     , INTNFEXL->D2_UM     , Nil})
			aadd(aItens,{"D1_QUANT"  , INTNFEXL->D2_QUANT  , Nil})
			aadd(aItens,{"D1_VUNIT"  , INTNFEXL->D2_PRCVEN , Nil})
			aadd(aItens,{"D1_TOTAL"  , INTNFEXL->D2_TOTAL  , Nil})

			lExec  := .T.
			INTNFEXL->(dbSkip())
		End

		If lExec
			StartJob("U_INTNFEX1",GetEnvServer(), .F.,cEpEntNF, cFlEntNF,aCabec,aItens)
		Endif
	EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºAlteração ³Ricardo Lima-17/10/18|CH:037647, exclui integração RNX2     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function INTNFEX1(cEpEntNF,cFlEntNF,aCabec,aItens)

    Local   nOpc        := 5
	Private aLinha      := {}
    Private lMsErroAuto := .F.
	Private lCheckNF    := .F.
	
	RpcSetType( 3 )
	RpcSetEnv( cEpEntNF, cFlEntNF,,,"COM")

		dbSelectArea("SF1")
		dbSetOrder(1)
		IF dbSeek( aCabec[4][2] + aCabec[7][2] + aCabec[8][2] + aCabec[1][2] + aCabec[2][2] )

			dbSelectArea("SD1")
			dbSetOrder(1)
			if dbSeek( aCabec[4][2] + aCabec[7][2] + aCabec[8][2] + aCabec[1][2] + aCabec[2][2] )
				if Empty(SD1->D1_TES)
					aAdd(aLinha,aItens)
				Else
					aadd(aItens,{"D1_FILIAL"	,SD1->D1_FILIAL		, Nil})
					aadd(aItens,{"D1_ITEM"		,SD1->D1_ITEM		, Nil})
					aadd(aItens,{"D1_COD"		,SD1->D1_COD		, Nil})
					aadd(aItens,{"D1_UM"		,SD1->D1_UM			, Nil})
					aadd(aItens,{"D1_QUANT"		,SD1->D1_QUANT		, Nil})
					aadd(aItens,{"D1_VUNIT"		,SD1->D1_VUNIT		, Nil})
					aadd(aItens,{"D1_TOTAL"		,SD1->D1_TOTAL		, Nil})
					aadd(aItens,{"D1_CF"		,SD1->D1_CF			, Nil})
					aadd(aItens,{"D1_DESC"		,SD1->D1_DESC		, Nil})
					aadd(aItens,{"D1_FORNECE"	,SD1->D1_FORNECE	, Nil})
					aadd(aItens,{"D1_LOJA"		,SD1->D1_LOJA		, Nil})
					aadd(aItens,{"D1_LOCAL"		,SD1->D1_LOCAL		, Nil})
					aadd(aItens,{"D1_DOC"		,SD1->D1_DOC		, Nil})
					aadd(aItens,{"D1_EMISSAO"	,SD1->D1_EMISSAO	, Nil})
					aadd(aItens,{"D1_DTDIGIT"	,SD1->D1_DTDIGIT	, Nil})
					aadd(aItens,{"D1_TIPO"		,SD1->D1_TIPO		, Nil})
					aadd(aItens,{"D1_SERIE"		,SD1->D1_SERIE		, Nil})
					aadd(aItens,{"D1_TP"		,SD1->D1_TP			, Nil})
					aadd(aItens,{"D1_TES"		,SD1->D1_TES		, Nil})
					aAdd(aLinha,aItens)
					lCheckNF := .T.
				Endif
			Endif	

			if lCheckNF
            	MSExecAuto({|x, y, z  | MATA103(x,y,z)    }, aCabec, aLinha, nOpc)
            Else                    
				MSExecAuto({|x,y,z,a,b| MATA140(x,y,z,a,b)}, aCabec, aLinha, nOpc,,)
			Endif

			If lMsErroAuto   
				MostraErro()
				ConOut(MostraErro())
			Endif
		Endif
	RpcClearEnv()
Return(.T.)
/*/{Protheus.doc} grvBarr
    Salva o registro para enviar ao barramento.
	Chamado 18465.
    @type  User Function
    @author Everson
    @since 18/03/2022
    @version 01
/*/
Static Function grvBarr(cOperacao, cNumero, cDoc, cSerie)

    //Variáveis.
    Local aArea     := GetArea()
	Local cFilter	:= ""

	If ! (cFilAnt $"03/05")
		RestArea(aArea)
		Return Nil

	EndIf

	DbSelectArea("SC5")
	SC5->(DbSetOrder(15))
	SC5->(DbGoTop())
	If ! SC5->( DbSeek( FWxFilial("SC5") + cDoc ) )
		RestArea(aArea)
		Return Nil

	EndIf
	
	cFilter := " D2_FILIAL ='" + FWxFilial("SD2") + "' .And. D2_DOC = '" + SF2->F2_DOC + "' .And. D2_SERIE = '" + SF2->F2_SERIE + "' .And. D2_CLIENTE = '" + SF2->F2_CLIENTE + "' .And. D2_LOJA = '" + SF2->F2_LOJA  + "' "
	
	U_ADFAT27D(;
			   "SF2", 1, FWxFilial("SF2") + cNumero,;
			   "SD2", 3, FWxFilial("SD2") + cNumero, "D2_COD+D2_ITEM",cFilter,;
			   "documentos_de_saida_protheus", cOperacao,;
			   .T., .T.,.T., Nil)

	RestArea(aArea)

Return Nil
