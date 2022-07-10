#Include "RwMake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"

/*/{Protheus.doc} User Function M310CABEC
	Ponto de Entrada para realizar a transmissao e impressao da danfe da nota de saida de transferencia  
	@type  Function 
	@author Andre Mendes - Obify
	@since  28/04/21 
	@version 01
	@history Chamado 8566 	- André Mendes 	- 29/04/2021 - Transferência entre Filiais 
	@history ticket   TI    - Everson           - 10/07/2022 - Removida transmissão automática de NF.
/*/
User Function M310CABEC
    Local cProg := PARAMIXB[1]
    Local aCabec := PARAMIXB[2]
    //Local aPar := PARAMIXB[3]
    Local nPos1 := 0
    Local nPos2 := 0
    Local aNFTrans	:= {}
    Local lAut := .f.


    If cProg $ "MATA140,MATA103"
        nPos1 := aScan(aCabec, {|x| x[01]=="F1_DOC"})
        If nPos1 > 0
            cNota := aCabec[nPos1][02]

        Endif
        nPos2 := aScan(aCabec, {|x| x[01]=="F1_SERIE"})
        If nPos2 > 0
            cSerie := aCabec[nPos2][02]

        Endif

        If !Empty(cNota) .and. !Empty(cSerie)

            Aadd(aNFTrans,{cNota,cSerie})
        Endif 

        If Len(aNFTrans) > 0
            //MsAguarde({|| transmNF(@aNFTrans,cSerie,lAut) },"Aguarde","Transmitindo NF's") //Everson - 10/07/2022. Chamado TI

        EndIf
		
		If !Empty(SF2->F2_CHVNFE)
			aadd(aCabec,{"F1_CHVNFE", SF2->F2_CHVNFE})
		Endif

	ElseIf cProg $ "MATA410"
        If MsgYesNo("Deseja incluir informações complementares do pedido de venda?", "Informações Complementares")
            aCpos:={"C5_TPFRETE","C5_TRANSP","C5_PLACA","C5_UFPLACA","C5_MENNOTA", "C5_MENNOT2"}
			
            
            lRet := fGetCps(@aCabec, aCpos, cProg)
        Endif
    EndIf
		
 Return(aCabec)


Static Function transmNF(aNFTrans,cSerie,lAut)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local cIdent    := ""
    Local oWs       := Nil
	Local cURL		:= ""
	Local cNFIni	:= aNFTrans[1][1]
	Local cNFFim	:= aNFTrans[Len(aNFTrans)][1]
	Local cNFT 		:= ""
	Local cAmbiTrans:= ""
	Local nAux		:= 1
	Local lTAut  	:= GetMv("MV_#TRAUT",,.F.)

	//Everson - 03/06/2020. Chamado T.I.
	If lAut .And. ! lTAut
		aNFTrans := {}
		RestArea(aArea)
		Return .F.

	EndIf

	//
	Default lAut	:= .F.
	
	//
	MsgInfo("Notas geradas de " + cNFIni + " até " + cNFFim + ".","Função transmNF")

	//Everson - 26/05/2020. Chamado 058120.
    If ! CTIsReady()
		Conout( DToC(Date()) + " " + Time() + " INTEPEDB - transmNF - CTIsReady retornou .F. " )
        MsgSTop( "A função CTIsReady retornou .F. . Não será possível fazer a transmissão automática, faça a transmissão manual." ,"Função transmNF(INTEPEDB)")
		RestArea(aArea)
        Return .F. 

    EndIf

	//
    cIdent := RetIdEnti()

    //
    oWs := WsSpedCfgNFe():New()

    //
    cURL := PadR(GetMv("MV_SPEDURL"),250)

    //
    oWS:cUSERTOKEN := "TOTVS"
    oWS:cID_ENT := cIdent
    oWS:nAmbiente := 0
    oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
    
    //
    If oWS:CFGAMBIENTE()
        cAmbiTrans := oWS:cCfgAmbienteResult
        cAmbiTrans := Substr(cAmbiTrans,1,1)

    EndIf

    //
    Conout( DToC(Date()) + " " + Time() + " INTEPEDB - transmNF - ambiente para transmissão NF " + cAmbiTrans)
	
	//
	If Empty(cAmbiTrans)
		Conout( DToC(Date()) + " " + Time() + " INTEPEDB - transmNF - Não foi possível obter o ambiente de transmissão de nota fiscal.")
		MsgStop("Não foi possível obter o ambiente de transmissão de nota fiscal.","Função transmNF")
		RestArea(aArea)
		Return .F.
		
	EndIf

	//
	DbSelectArea("SF2")
	SF2->(DbSetOrder(1))
	
	//
	For nAux := 1 To Len(aNFTrans) 

		//
		cNFT := aNFTrans[nAux][1]

		//
		SF2->(DbGoTop())
		If SF2->(DbSeek( xFilial("SF2") + cNFT + cSerie ))
			
			MsAguarde({|| AutoNfeEnv(FWCodEmp(),SF2->F2_FILIAL,"1",cAmbiTrans,SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_DOC) },"Transmitindo NF","De " + cNFT + " até " + cNFT + " Série: " + cSerie + " ..." )
		

		Else 
			MsgStop("NF não encontrada para transmissão " + cNFT + cSerie + ".", "Função transmNF(INTEPEDB)")
			

		EndIf 

	Next nAux 

	//Everson - 26/05/2020. Chamado 058120.
	If ! lAut
		MsAguarde({|| imprimeNF(cValToChar(aNFTrans[1][1]),cValToChar(aNFTrans[Len(aNFTrans)][1])) },"Aguarde","Imprimindo notas fiscais...")

	EndIf
	
	//
	RestArea(aArea)
	
Return .T.
/*/{Protheus.doc} imprimeNF
	Carrega o conteúdo na variável da pergunta. Chamado 033511.
	@type  Static Function
	@author Everson
	@since 23/10/2018
	@version 01
	/*/
Static Function imprimeNF(cNFIni,cNFFim)

	//Variáveis.
	Local aArea 	:= GetArea()
	Local cCondicao := "F2_FILIAL=='"+xFilial("SF2")+"'"

	//Variável necessária para função SpedDanfe.
	Private aFilBrw	:=	{'SF2',cCondicao}

	//
	Default cNFIni	:= ""
	Default cNFFim	:= ""
	
	//
	If ! Empty(cNFIni) .And. ! Empty(cNFFim)
		zAtuPerg("NFSIGW", "MV_PAR01", cNFIni)
		zAtuPerg("NFSIGW", "MV_PAR02", cNFFim)
		
	EndIf
	
	//
	SpedDanfe()
	
	//
	RestArea(aArea)
	
Return Nil


/*/{Protheus.doc} zAtuPerg
	Carrega o conteúdo na variável da pergunta. Chamado 033511. 
	@type  Static Function
	@author Everson
	@since 27/07/2017
	@version 01
	/*/
Static Function zAtuPerg(cPergAux, cParAux, xConteud)

	//Variáveis.
	Local aArea      := GetArea()
	Local nPosPar    := 14
	Local nLinEncont := 0
	Local aPergAux   := {}

	//
	Default xConteud := ''

	//Se não tiver pergunta, ou não tiver ordem.
	If Empty(cPergAux) .Or. Empty(cParAux)
		Return Nil

	EndIf

	//Chama a pergunta em memória.
	Pergunte(cPergAux, .F., /*cTitle*/, /*lOnlyView*/, /*oDlg*/, /*lUseProf*/, @aPergAux)

	//Procura a posição do MV_PAR.
	nLinEncont := aScan(aPergAux, {|x| Upper(Alltrim(x[nPosPar])) == Upper(cParAux) })

	//Se encontrou o parâmetro
	If nLinEncont > 0
		//Caracter
		If ValType(xConteud) == 'C'
			&(cParAux+" := '"+xConteud+"'")

		//Data
		ElseIf ValType(xConteud) == 'D'
			&(cParAux+" := sToD("+dToS(xConteud)+")")

		//Numérico ou Lógico
		ElseIf ValType(xConteud) == 'N' .Or. ValType(xConteud) == 'L'
			&(cParAux+" := "+cValToChar(xConteud)+"")

		EndIf

		//Chama a rotina para salvar os parâmetros
		__SaveParam(cPergAux, aPergAux)

	EndIf

	//
	RestArea(aArea)

Return Nil



Static Function fGetCps(aItens, aCpos, cPrograma)
Local aArea := GetArea()

Local nX := 0
//Local nTamAc := 0
//Local nDel := 0
Local nOpc := 0
Local oDlg, oGetD1
Local lRet := .F.
Local nz
Local nC
Local aAlter
Local aHTab := {}

If Empty(aHTab)
	
    aAlter := aClone(aCpos)
    For nx:=1 to Len(aItens)

        aAdd(aCpos,aItens[nx,1])
         

    Next nx

	aHTab:={}
	aCTab:={}
	DbSelectArea("SX3")
	DbSetOrder(2)
	For nX:=1 To Len(aCpos)
		If MsSeek(aCpos[nX])
			If (X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL )
				Aadd(aHTab,{AllTrim(X3Titulo()),;
								SX3->X3_CAMPO,;
								SX3->X3_PICTURE,;
								SX3->X3_TAMANHO,;
								SX3->X3_DECIMAL,;
								SX3->X3_VALID,;
								SX3->X3_USADO,;
								SX3->X3_TIPO,;
								SX3->X3_F3,;
								SX3->X3_CONTEXT,;
								X3CBOX(),;
								SX3->X3_RELACAO,;
								".T."})
			EndIf
		Endif
	Next

	Aadd(aCTab,Array(Len(aHTab)+1))
	For nX:=1 To Len(aHTab)
		nC := aScan( aItens,{ | x | x[01] == Alltrim(aHTab[nX][2])  }) 
		If  nC > 0
			aCTab[01][nX]:= aItens[nC][02]
		Else
			aCTab[01][nX]:=Criavar(aHTab[nX][2])
		Endif
	Next
	aCTab[1][Len(aCTab[1])]:=.F.

Endif

DEFINE MSDIALOG oDlg TITLE "Informar Campos Complementares - Cabeçalho "+cPrograma From 0,0 To 400,400 Of oMainWnd Pixel
	oGetD1 := MsNewGetDados():New(050,030,175,175,GD_UPDATE,,"AllwaysTrue()" ,,aAlter,/*freeze*/,,/*fieldok*/,/*superdel*/,/*delok*/,oDlg,@aHTab,@aCTab)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||aCTab:=oGetD1:aCols,nOpc:=1,oDlg:End()},{||nOpc:=0,oDlg:End()}) CENTERED

lRet:=(nOpc==1)
If nOpc==1

    For nX := 1 To Len(aAlter)
        nC := aScan(aHTab, { |x| Alltrim(x[2]) ==  Alltrim(aAlter[nX])  })
        If nC >0
            aAdd(aItens, {aAlter[nX]	,aCTab[01][nC],Nil} )
                



        Endif
    Next nX

/*
	nOpc:=Len(aCTab)
	nLenAc:=Len(aCTab[1])
	nDel:=0
	For nX:=nOpc To 1 Step -1
		If aCTab[nX][nLenAc]
			nDel++
			Adel(aCTab,nX)
		Endif
	Next
	If nDel>0
		aCTab:=aSize(aCTab,nOpc-nDel)
	Endif
    */
Endif

RestArea(aArea)
Return(lRet)
