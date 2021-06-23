#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "Rwmake.ch"
#Include "Tbiconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADVEN033R     บAutor  ณEverson          บData ณ10/11/2016   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelat๓rio de anแlise de cliente sem compra.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณComercial.                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADVEN033R() // U_ADVEN033R()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cPerg		:= "ADVEN033R"
	
	Private lDiret := .F.
	Private lGerent:= .F.
	Private lSuperv:= .F.
	Private lVended:= .F.
	Private cCodigo:= ""
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relat๓rio de anแlise de cliente sem compra.')
	
	//
	logAcesso("ADVEN033R")
	
	DbSelectArea("SA3")
	SA3->(DbSetOrder(7))
	SA3->(DbGoTop())
	
	If Dbseek(xFilial("SA3") + Alltrim(cValToChar(__cUserID)))
	//If Dbseek(xFilial("SA3") + Alltrim(cValToChar("000835")))
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
	   MsgStop("Seu usuแrio nใo possui cadastro na tabela de vendedores e nใo poderแ emitir este relat๓rio.","Fun็ใo ADVEN033R")
	   Return Nil
	   
	Endif
	
	//Cria a pergunta.
	criarPergunta(cPerg)
	
	//
	If ! Pergunte(cPerg,.T.)
		Return Nil
		
	EndIf
	
	//Executa o relat๓rio.
	processar()

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณprocessar     บAutor  ณEverson          บData ณ10/11/2016   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa relat๓rio de anแlise de clientes sem compra.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณComercial.                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function processar()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local oPrint
	Local oFCabecalho	:= TFont():New('Courier new',,-17,.T.)
	Local oFCabeSub	:= TFont():New('Courier new',,-12,.T.)
	Local oFTexto		:= TFont():New('Courier new',,-10,.T.)
	Local nTotalPDV	:= 0
	Local nTotalSPDV	:= 0
	Local nTotalCPDV:= 0
	Local cPorc		:= ""
	
    //Monta objeto para impressใo.
    oPrint := TMSPrinter():New("ADVEN033R")

    //Define orienta็ใo da pแgina para paisagem.
    oPrint:SetLandScape() 
    
    //Mostra janela de configura็ใo de impressใo.
    //oPrint:Setup()

    //Inicia pแgina.
    oPrint:StartPage()            

    //Insere texto formatado.
    oFCabecalho:Bold := .T.
    oPrint:Say(100,200,"Relat๓rio Resumo - Anแlise de Cliente sem Compra " + cValToChar(MV_PAR01),oFCabecalho)
    
    oPrint:Line(200,10,200,2600)
     
    oFCabeSub:Bold := .T.
    oPrint:Say(300,200,"Resumo Geral",oFCabeSub)
    
    cTotPDV := ttPDV(1)
    oPrint:Say(400,200,"Total de PDV",oFTexto)
    oPrint:Say(400,600,cTotPDV,oFTexto)
    
    cTotPDVS := ttPDV(2)
    oPrint:Say(500,200,"Total sem Mot.",oFTexto)
    oPrint:Say(500,600,cTotPDVS,oFTexto)
    
    cPorc := Iif( Val(cValToChar(cTotPDV)) > 0, cValToChar(Round( (Val(cValToChar(cTotPDVS)) / Val(cValToChar(cTotPDV))) * 100,2)), "0")
    oPrint:Say(600,200,"Percentual(%)",oFTexto)
    oPrint:Say(600,600,cPorc,oFTexto)
    
    oPrint:Line(700,200,700,1000)
    
    oPrint:Say(800,200,"Total por Motivo",oFCabeSub)
    aTTMot := ttPDVPMot()
    
    nLinha := 950
    
    nTotalCPDV := 0
    For i := 1 To Len(aTTMot)
    	nTotalCPDV += Val(cValToChar(aTTMot[i][2]))
    
    Next i
    
    For i := 1 To Len(aTTMot)
    	oPrint:Say(nLinha,200,cValToChar(Alltrim(aTTMot[i][1])),oFTexto)
    	oPrint:Say(nLinha,700,cValToChar(aTTMot[i][2]),oFTexto)
    	oPrint:Say(nLinha,800,Iif(nTotalCPDV > 0, cValToChar( Round((aTTMot[i][2]/nTotalCPDV)*100,2) ) + " %","0"),oFTexto)
    	
    	nLinha += 050
    	
    Next i
    
    nLinha += 050
    oPrint:Say(nLinha,200,"Total: " + cValToChar(nTotalCPDV),oFCabeSub)
    
    oPrint:Say(300,1100,"Resumo por Supervisใo",oFCabeSub)
    oPrint:Say(400,1100,"Cod",oFCabeSub)
    oPrint:Say(400,1300,"Nome",oFCabeSub)
    oPrint:Say(400,1650,"PDV",oFCabeSub)
    oPrint:Say(400,1800,"Sem Mot.",oFCabeSub)
    oPrint:Say(400,2050,"Com Mot.",oFCabeSub)
    oPrint:Say(400,2380,"(%)",oFCabeSub)
	 aTTSuper := ttPDVSuper()
    
    nTotalCPDV := 0
    nLinha := 500
    For i := 1 To Len(aTTSuper)
    	oPrint:Say(nLinha,1100,cValToChar(aTTSuper[i][1]),oFTexto)
    	oPrint:Say(nLinha,1300,Substr(cValToChar(aTTSuper[i][4]),1,15),oFTexto)
    	oPrint:Say(nLinha,1650,cValToChar(aTTSuper[i][2]),oFTexto)
    	oPrint:Say(nLinha,1800,cValToChar(aTTSuper[i][3]),oFTexto)
    	
    	oPrint:Say(nLinha,2050,cValToChar(aTTSuper[i][5]),oFTexto)
    	
    	cPorc := Iif(Val(cValToChar(aTTSuper[i][2])) > 0,cValToChar(Round((Val(cValToChar(aTTSuper[i][5])) / Val(cValToChar(aTTSuper[i][2]))) * 100,2)),"0")
    	oPrint:Say(nLinha,2380,cPorc,oFTexto)
    	
    	nTotalPDV  += Val(cValToChar(aTTSuper[i][2]))
    	nTotalSPDV += Val(cValToChar(aTTSuper[i][3]))
    	nTotalCPDV += Val(cValToChar(aTTSuper[i][5]))
    	
    	nLinha += 050
    	
    Next i
    
    nLinha += 050
    
    oPrint:Line(nLinha,1100,nLinha,2550)
    
    nLinha += 050
    
    cPorc := Iif(nTotalPDV > 0,cValToChar(Round((Val(cValToChar(nTotalCPDV)) / Val(cValToChar(nTotalPDV))) * 100,2)),"0")
    
    oPrint:Say(nLinha,1100,"Totais:",oFCabeSub)
    oPrint:Say(nLinha,1650,cValToChar(nTotalPDV),oFCabeSub)
    oPrint:Say(nLinha,1800,cValToChar(nTotalSPDV),oFCabeSub)
    oPrint:Say(nLinha,2050,cValToChar(nTotalCPDV),oFCabeSub)
    oPrint:Say(nLinha,2380,cPorc,oFCabeSub)
    
    // Visualiza a impressใo
    oPrint:EndPage()

    // Termina a pแgina
    oPrint:EndPage()
                       
    // Mostra tela de visualiza็ใo de impressใo
    oPrint:Preview()
       
	MS_FLUSH() 
  
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณttPDV         บAutor  ณEverson          บData ณ10/11/2016   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTotal de PDV no perํodo.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณComercial.                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ttPDV(nOpc)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cQuery	:= ""
	Local cTT		:= ""
	
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " COUNT(DISTINCT ZBI_CODCLI+ZBI_LOJA) AS TT_PDV " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZBI") + " AS ZBI " 
	cQuery += " WHERE " 
	cQuery += " ZBI.D_E_L_E_T_ = '' " 
	
	If lDiret .Or. lGerent
	
		cQuery += " AND ZBI_CODSUP >= '" + cValtoChar(MV_PAR02) + "' "
		cQuery += " AND ZBI_CODSUP <= '" + cValtoChar(MV_PAR03) + "' "
	
	ElseIf lSuperv
		cQuery += " AND ZBI_CODSUP = '" + cValtoChar(cCodigo) + "' "
	
	ElseIf lVended
		cQuery += " AND ZBI_VEND   = '" + cValtoChar(cCodigo) + "' "
	
	EndIf
	
	If nOpc == 2
		cQuery += " AND ZBI_MOTIVO = '' " 
		
	EndIf
	
	cQuery += " AND ZBI_PERIOD = '" + cValtoChar(MV_PAR01) + "' "
	
	If Select("TT_PDV") > 0
		TT_PDV->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "TT_PDV"
	
	DbSelectArea("TT_PDV")
		cTT := Alltrim(cValToChar(TT_PDV->TT_PDV))
	
	DbCloseArea("TT_PDV")


Return cTT
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณttPDVPMot     บAutor  ณEverson          บData ณ10/11/2016   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTotal de PDV por motivo.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณComercial.                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ttPDVPMot()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cQuery		:= ""
	Local aRetorno	:= {}
	
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " MOTIVOS.X5_DESCRI AS MOTIVO, COUNT(DISTINCT ZBI_CODCLI+ZBI_LOJA) AS TT_MOTIVO " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZBI") + " AS ZBI INNER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " X5_CHAVE, X5_DESCRI " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SX5") + " AS SX5 " 
	cQuery += " WHERE " 
	cQuery += " SX5.D_E_L_E_T_ = '' " 
	cQuery += " AND X5_TABELA = 'ZY' " 
	cQuery += " ) AS MOTIVOS ON " 
	cQuery += " ZBI_MOTIVO = MOTIVOS.X5_CHAVE " 
	cQuery += " WHERE " 
	cQuery += " ZBI.D_E_L_E_T_ = '' " 
	
	cQuery += " AND ZBI_PERIOD = '" + cValtoChar(MV_PAR01) + "' "
	
	If lDiret .Or. lGerent
	
		cQuery += " AND ZBI_CODSUP >= '" + cValtoChar(MV_PAR02) + "' "
		cQuery += " AND ZBI_CODSUP <= '" + cValtoChar(MV_PAR03) + "' "
	
	ElseIf lSuperv
		cQuery += " AND ZBI_CODSUP = '" + cValtoChar(cCodigo) + "' "
	
	ElseIf lVended
		cQuery += " AND ZBI_VEND   = '" + cValtoChar(cCodigo) + "' "
	
	EndIf

	cQuery += " GROUP BY MOTIVOS.X5_DESCRI " 
	cQuery += " ORDER BY COUNT(DISTINCT ZBI_CODCLI+ZBI_LOJA) DESC " 
	
	If Select("TTD_MOTIVO") > 0
		TTD_MOTIVO->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "TTD_MOTIVO"
	
	DbSelectArea("TTD_MOTIVO")
	TTD_MOTIVO->(DbGoTop())
	
	While ! TTD_MOTIVO->(Eof())
		
		Aadd(aRetorno,{;
						TTD_MOTIVO->MOTIVO,;
						TTD_MOTIVO->TT_MOTIVO;
						})
		
		TTD_MOTIVO->(DbSkip())
		
	EndDo
	
	DbCloseArea("TTD_MOTIVO")
	
Return aRetorno
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณttPDVSuper    บAutor  ณEverson          บData ณ10/11/2016   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTotal de PDV por supervisใo.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณComercial.                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ttPDVSuper()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cQuery		:= ""
	Local aRetorno	:= {}
	
	cQuery := ""
	cQuery += " SELECT * "
	cQuery += " FROM "
	cQuery += " (	"
	cQuery += " SELECT " 
	cQuery += " ZBI_CODSUP, ZR_DESCRIC,  " 
	cQuery += " COUNT(DISTINCT ZBI_CODCLI+ZBI_LOJA) AS TT_PDV, " 
	cQuery += " COUNT(DISTINCT CASE WHEN ZBI_MOTIVO =  '' THEN ZBI_CODCLI+ZBI_LOJA END) AS TT_PDVSM, " 
	cQuery += " COUNT(DISTINCT CASE WHEN ZBI_MOTIVO <> '' THEN ZBI_CODCLI+ZBI_LOJA END) AS TT_PDVCM "
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZBI") + " AS ZBI " 
	
	cQuery += " INNER JOIN "
	cQuery += " " + RetSqlName("SZR") + " AS SZR ON "
	cQuery += " ZBI_CODSUP = ZR_CODIGO"
	 
	cQuery += " WHERE " 
	cQuery += " ZBI.D_E_L_E_T_ = '' "
	cQuery += " AND SZR.D_E_L_E_T_ = '' "
	cQuery += " AND ZBI_PERIOD =  '" + cValtoChar(MV_PAR01) + "' " 
	
	If lDiret .Or. lGerent
	
		cQuery += " AND ZBI_CODSUP >= '" + cValtoChar(MV_PAR02) + "' "
		cQuery += " AND ZBI_CODSUP <= '" + cValtoChar(MV_PAR03) + "' "
	
	ElseIf lSuperv
		cQuery += " AND ZBI_CODSUP = '" + cValtoChar(cCodigo) + "' "
	
	ElseIf lVended
		cQuery += " AND ZBI_VEND   = '" + cValtoChar(cCodigo) + "' "
	
	EndIf
	
	cQuery += " GROUP BY ZBI_CODSUP,ZR_DESCRIC "
	cQuery += " ) AS REG "
	cQuery += " ORDER BY ZBI_CODSUP "
	
	If Select("TTD_SUPER") > 0
		TTD_SUPER->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "TTD_SUPER"
	
	DbSelectArea("TTD_SUPER")
	TTD_SUPER->(DbGoTop())
	
	While ! TTD_SUPER->(Eof())
		
		Aadd(aRetorno,{;
						TTD_SUPER->ZBI_CODSUP,;
						TTD_SUPER->TT_PDV,;
						TTD_SUPER->TT_PDVSM,;
						TTD_SUPER->ZR_DESCRIC,;
						TTD_SUPER->TT_PDVCM;
						})
		
		TTD_SUPER->(DbSkip())
		
	EndDo
	
	DbCloseArea("TTD_SUPER")

Return aRetorno
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcriarPergunta บAutor  ณEverson          บData ณ10/11/2016   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria pergunta na SX1.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณComercial.                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function criarPergunta(cPerg)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	Local aArea := GetArea()
	
	PutSx1(cPerg,"01","Perํodo(mmaaaa)  ?"," "," ","mv_ch1","C",6,0,0,	"G","","","","","mv_par01"," "," "," ","",	" "," "," "," "," "," ", " "," "," "," ",	" "," ",{"Informe o perํodo de apura็ใo"} ,{"Informe o perํodo de apura็ใo"}, {"Informe o perํodo de apura็ใo"})
	PutSx1(cPerg,"02","Supervisor de    ?"," "," ","mv_ch2","C",6,0,0,	"G","","","","","mv_par02"," "," "," ","",	" "," "," "," "," "," ", " "," "," "," ",	" "," ",{"Informe o c๓digo do supervisor"},{"Informe o c๓digo do supervisor"},{"Informe o c๓digo do supervisor"})
	PutSx1(cPerg,"03","Supervisor At้   ?"," "," ","mv_ch3","C",6,0,0,	"G","","","","","mv_par03"," "," "," ","",	" "," "," "," "," "," ", " "," "," "," ",	" "," ",{"Informe o c๓digo do supervisor"},{"Informe o c๓digo do supervisor"},{"Informe o c๓digo do supervisor"})
	
	RestArea(aArea)
 
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlogAcesso         บ Autor ณ Everson บ Data ณ  16/06/2017    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณLog de acesso de rotina.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado .                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function logAcesso(cRotina)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
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
		ZBE->ZBE_ROTINA	:= "ADVEN033R"
	MsUnlock()
	
	RestArea(aArea)
	
Return Nil