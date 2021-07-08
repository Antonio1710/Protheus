#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"

/*/{Protheus.doc} User Function ADEST065P
    Rotina para seleção de cliente.
    Chamado 8465
    @type  Function
    @author Leonardo P. Monteiro
    @since 07/07/2021
    @version 01
	@history Chamado 8465 - Leonardo P. Monteiro - 07/07/2021 - Desenvolvimento inicial.
	
    /*/

User Function ADEST068P(cZEDCod)

	//Define quais colunas (campos da TTRB) serao exibidas na MsSelect
	Local cCampos			:= "A1_COD, A1_LOJA, A1_NOME"
	
	Private oGetPesq
	Private oGroup1
	Private oGet
	Private oDlg
	Private oOrdem
	Private oButton
	Private aCampos 		:= {}
	Private aColsBco		:= {}
	Private aHeaderBco		:= {}
	Private aItens			:= {"Código/Loja","Nome"}
	Private cPesquisa		:= space(60)
	Private cOrdem			:= ""
	Private aButtons		:= {}
	Private nCont			:= 0
	Private nRetorno		:= 1

	Private cFOpen			:= ""
	Private oOk 			:=	LoadBitmap( GetResources(), "LBOK")
	Private oNo 			:=	LoadBitmap( GetResources(), "LBNO")
	Private bOk				:= {|| nRetorno := fOk(cZEDCod),odlg:End()}
	
	Default cZEDCod			:= ""
	//Default cZE2Reg			:= ""

	aHeaderBco 	:= MontCabec(cCampos, , 1)
	aColsBco	:= MontDados(cZEDCod)

	if !Empty(aColsBco[1][2])
		@ 050,001 TO 600, 600 DIALOG oDlg TITLE "..:: Seleção de Clientes ::.."

		oGroup1 	:= tGroup():New(033,002,75,300,'Pesquisar',oDlg,,,.T.)
		oOrdem 		:= tComboBox():New(43,10,{|u|if(PCount()>0,cOrdem:=u,cOrdem)},aItens,80,20,oGroup1,,{|| fOrdena()},,,,.T.,,,,,,,,,'nOrdem')
		oGetPesq	:= TGet():New(43,90,{|u| if(PCount()>0,cPesquisa:=u,cPesquisa)}, oGroup1,133,14,'',,,,,,,.T.,,,,,,,,,,'cPesquisa')
		oButton		:=tButton():New(43,227,'Pesquisa',oDlg,{||fPesquisa(1)},70,14,,,,.T.)
		oGet		:= MsNewGetDados():New(077,003,260,300, 2,"AllwaysTrue","AllwaysTrue",,{"A1_NOME"},,nCont,"AllwaysTrue", "AllwaysTrue","", oDlg, aHeaderBco, aColsBco, "AllwaysTrue")	
		oGet:oBrowse:BldBlclick := {|| fSeleciona()}
		
		ACTIVATE DIALOG oDlg On Init (EnchoiceBar(oDlg,{|| MsAguarde(bOk,"Processando, aguarde...","Aguarde..." )},{|| cRetorno := "", oDlg:End()},,aButtons)) CENTER
	else
		msginfo("Não existe itens disponíveis para inclusão.")
	endif

	IF Select("Query1") > 1
	    DbCloseArea("Query1")
	EndIF

Return nRetorno

Static Function fOk(cZEDCod)
	Local nRet := 0

	Local nPosOk		:= Ascan( oGet:aHeader, { |x| Alltrim(x[2]) == "OK"  })
	Local nPosCod		:= Ascan( oGet:aHeader, { |x| Alltrim(x[2]) == "A1_COD" })
	Local nPosLoja		:= Ascan( oGet:aHeader, { |x| Alltrim(x[2]) == "A1_LOJA" })
	local nA			:= 0
	
	DbSelectArea("SA1")
	SA1->(DbsetOrder(1))

	For nA := 1 TO Len(oGet:aCols)  
		If oGet:aCols[nA][nPosOk] == oOk
			
			if (SA1->(Dbseek(xFilial("SA1")+ALLTRIM(oGet:aCols[nA][nPosCod])+ALLTRIM(oGet:aCols[nA][nPosLoja])) ))
				if Reclock("SA1",.F.)
					SA1->A1_XGRPINS := cZEDCod
					SA1->(MsUnlock())
				endif
			Endif
		EndIf
	Next nA

return nRet

Static Function fSeleciona()
	Local nPosOk			:= Ascan( oGet:aHeader, { |x| Alltrim(x[2]) == "OK"	})
	//Local lRet 			:= .T.

	If oGet:aCols[oGet:oBrowse:nAt][nPosOk] == oNo
		oGet:aCols[oGet:oBrowse:nAt][nPosOk] := oOk
	Else 
		oGet:aCols[oGet:oBrowse:nAt][nPosOk] := oNo
	EndIf


Return

//Função responsável pela criação dos arquivos de trabalho.
Static Function fCriaTrab(cAlias)

	Local cArqTrab 	:= NIL  

	cArqTrab			:= FWTemporaryTable():New(cAlias, aStrut)
	cArqTrab:AddIndex("01",{"A1_COD","A1_LOJA"})
    cArqTrab:AddIndex("02",{"A1_NOME"})
	
	cArqTrab:Create()
 
	cAlias 		:= cArqTrab:GetAlias()
	cTableName 	:= cArqTrab:GetRealName()
  
	DbSelectArea(cAlias)
	
	(cAlias)->(DbSetOrder(1))
Return cArqTrab

/* fOrdena */
Static Function fOrdena()
	//alert("Ordena")
	//Código
	If oOrdem:Nat == 1
		aSort(oGet:aCols,,,{|x,y| x[1]+x[2]<y[1]+y[2]})
	ElseIf oOrdem:Nat == 2
		aSort(oGet:aCols,,,{|x,y| x[3]<y[3]})
	EndIf

	oGet:oBrowse:refresh()
Return

/* fPesquisa */
Static Function fPesquisa(nTipo, cAlias)
	Local nPos	:= 0
	Local cPesq := Alltrim(cPesquisa)

	If nTipo == 1
		If !Empty(cPesq)

			If oOrdem:Nat == 1
				nPos := aScanX( oGet:aCols, { |X,Y| UPPER(cPesq) == Left( UPPER(Alltrim(X[2]))+UPPER(Alltrim(X[3])),Len(cPesq) ) })
			ElseIf oOrdem:Nat == 2
				nPos := aScanX( oGet:aCols, { |X,Y| UPPER(cPesq) == Left( UPPER(Alltrim(X[4])),Len(cPesq) ) })
			EndIf                                                                               

			oGet:goTo(nPos)
			oGet:oBrowse:refresh()
		EndIf

	EndIf

Return .T.

//*** Função MontCabec - Monta o cabeçalho.
Static Function MontCabec(cCampos, cAlias,nTipoArray)
	Local aArea 	:= GetArea()
	Local X			:= 0
	Local aHeaderA	:= {}
	Local aCampo	:= {}
	Local nX		:= 0
	Local aHeaderA	:= {}

	IF nTipoArray == 1
		AADD( aHeaderA,{"",;
		"OK",;
		"@BMP",;
		2,;
		0,;
		/*X3_VALID*/,;
		"",;
		"C",;
		"",;
		"V"})
	ElseIF nTipoArray == 2
		AADD(aHeaderA,{ "OK",,"Mark","@!"})
	ElseIf nTipoArray == 3
		AADD(aHeaderA,{"OK"     ,"L"	,1		,0		})
	ElseIf nTipoArray == 4
		AADD(aHeaderA,{""     ,{||IIF((cAlias)->OK,oOK,oNO)}	,"@!"	,"CENTER"	,02		,.T.})
	EndIF

	aCampos := Separa(cCampos,",",.F.)

	For nX	:= 1 TO Len(aCampos)
		aCampo	:= Separa(aCampos[nX]," AS ",.F.)
		IF LEN(aCampo) > 1
			aCampos[nX]	:= Alltrim(aCampo[2])
		ElseIf LEN(aCampo) == 1
			aCampos[nX]	:= allTrim(aCampo[1])
		EndIF

		aCampo	:= Separa(aCampos[nX],".",.F.)
		IF LEN(aCampo) > 1
			aCampos[nX]	:= AllTrim(aCampo[2])
		ElseIf LEN(aCampo) == 1
			aCampos[nX]	:= allTrim(aCampo[1])
		EndIF

	NExt nX


	dbselectArea("SX3")
	DbSetOrder(2)
	//WHILE !EOF() .AND. X3_ARQUIVO == cAlias
	For X := 1 TO LEN(aCampos)
		cCampos := Alltrim(aCampos[X])
		
		IF dbSeek(cCampos,.T.) 
			IF cNivel >= GetSX3Cache(cCampos, "X3_NIVEL")
				// Objetos normais que utilizam os dados completo do dicionário.
				If nTipoArray = 1
					AADD(aHeaderA, { TRIM(X3Titulo()),;
					GetSX3Cache(cCampos, "X3_CAMPO"),;
					GetSX3Cache(cCampos, "X3_PICTURE"),;
					IIF(GetSX3Cache(cCampos, "X3_TAMANHO") > 40 .AND. Alltrim(GetSX3Cache(cCampos, "X3_CAMPO")) != "ZM2_CHAVE",40, GetSX3Cache(cCampos, "X3_TAMANHO")),;
					GetSX3Cache(cCampos, "X3_DECIMAL"),;
					GetSX3Cache(cCampos, "X3_VALID"),;
					GetSX3Cache(cCampos, "X3_USADO"),;
					GetSX3Cache(cCampos, "X3_TIPO"),;
					GetSX3Cache(cCampos, "X3_F3"),;
					GetSX3Cache(cCampos, "X3_CONTEXT")}) 
					// Utilizado somente MsSelect
				ElseIf nTipoArray == 2
					AADD( aHeaderA, { GetSX3Cache(cCampos, "X3_CAMPO"),;
					,;
					TRIM(X3Titulo()),;
					GetSX3Cache(cCampos, "X3_PICTURE"),})
					// Utilizado Para crição de arquivos de trabalho.
				ElseIF nTipoArray == 3
					AADD( aHeaderA, { GetSX3Cache(cCampos, "X3_CAMPO"),;
					GetSX3Cache(cCampos, "X3_TIPO"),;
					GetSX3Cache(cCampos, "X3_TAMANHO"),;
					GetSX3Cache(cCampos, "X3_DECIMAL")})			   
				ElseIF nTipoArray == 4
					AADD( aHeaderA, { TRIM(X3Titulo()),;
					&("{| | "+ Alltrim(cAlias) +"->"+Alltrim(GetSX3Cache(cCampos, "X3_CAMPO"))+" }"),;
					Alltrim(GetSX3Cache(cCampos, "X3_PICTURE")),;
					IIF(GetSX3Cache(cCampos, "X3_TAMANHO") > 40 .AND. Alltrim(GetSX3Cache(cCampos, "X3_CAMPO")) != "ZM2_CHAVE",40, GetSX3Cache(cCampos, "X3_TAMANHO")),;
					IIF(GetSX3Cache(cCampos, "X3_TIPO") == "N", "RIGHT","CENTER"),;
					.F.})			   
					// AADD(aHeaderA,{"ST"     ,{|| GetStatus() 		}	,"@!"	,"CENTER"	,02		,.T.})			        				        	
				EndIF
			ENDIF
		Endif
	Next nI


	RestArea(aArea)
return aHeaderA



Static Function PosCampo(cCampo)
	Local nPos	:= 0

	nPos := Ascan(aCampos,Alltrim(cCampo))

	//RestArea(aArea)
Return nPos


//LPM 2012-04-16 - Função para montagem do Cabeçalho. 
//*** Função MontDados - Monta a consulta e preenche a array.
STATIC FUNCTION MontDados(cZEDCod)
	Local cEOL			:= chr(13) + chr(10)
	Local cQry			:= ""
	Local cWhere		:= ""
	Local aColsA		:= {}
	Local nI			:= 0
	Private aParamBox   := {}
    Private aRet        := {}

	// Eetua a consulta 

	If Select("QRY") > 0 
		QRY->(DBCLOSEAREA())
	EndIF

	Aadd( aParamBox ,{1,"Cliente De"  					,Space(06)	,"" ,'.T.',"SA1",'.T.',80,.F.})
	Aadd( aParamBox ,{1,"Loja De"  						,Space(02)	,"" ,'.T.',"",'.T.',80,.F.})
	Aadd( aParamBox ,{1,"Cliente Até"  					,Space(06)	,"" ,'.T.',"SA1",'.T.',80,.F.})
	Aadd( aParamBox ,{1,"Loja Até" 						,Space(02)	,"" ,'.T.',"",'.T.',80,.F.})
	Aadd( aParamBox ,{1,"Nome" 							,Space(40)	,"" ,'.T.',"",'.T.',80,.F.})
	
    if ParamBox(aParamBox,"Parâmetros",@aRet)
			cWhere := " AND A1_COD  BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR03 +"' "
			cWhere += " AND A1_LOJA BETWEEN '"+ MV_PAR02 +"' AND '"+ MV_PAR04 +"' "
			if !Empty(MV_PAR05)
				cWhere += " AND A1_NOME '%"+ MV_PAR05 +"%' "
			Endif
	endif

	cQry := " SELECT TOP 3000 A1.A1_COD, A1.A1_LOJA, A1.A1_NOME " + cEOL
	cQry += " FROM "+ RetSqlName("SA1") +" (NOLOCK) A1 " + cEOL
	cQry += " WHERE A1.D_E_L_E_T_='' AND A1.A1_FILIAL = '"+ xFilial("SA1") +"' AND A1.A1_COD !='' AND A1.A1_MSBLQL !='1' AND A1.A1_EST='EX' AND A1.A1_MSBLQL !='1' " + cEOL
	cQry += " 		AND A1.A1_XGRPINS !='"+cZEDCod+"' " + cEOL
	cQry += cWhere
	cQry += " ORDER BY A1.A1_COD, A1.A1_LOJA; " + cEOL

	TcQuery cQry alias "QRY" new
	
	Count TO nCont

	QRY->(DBGOTOP())

	IF nCont != 0
		WHILE qry->(!EOF())
			AADD( aColsA, Array(LEN(aHeaderBco) + 1 ) )	
			FOR nI := 1 TO LEN(aHeaderBco)

				If nI == 1
					/*
					if QRY->RE3REG != 0
						aColsA[LEN(aColsA),nI] := oOk
					else
					*/
					aColsA[LEN(aColsA),nI] := oNO
					//endif
				Else
					aColsA[LEN(aColsA),nI] := &("QRY->"+alltrim(aHeaderBco[nI,2])) 	
				EndIf
			Next nI

			aColsA[Len(aColsA), Len(aHeaderBco) +1 ] := .F.
			QRY->(dbSkip())
		END		

	ELSE
		AADD(aColsA, Array(LEN(aHeaderBco)+1))
		FOR nI := 1 TO LEN(aHeaderBco)
			If !"OK"$aHeaderBco[nI,2]
				aColsA[1, nI] := CriaVar(aHeaderBco[nI,2], .F.)
			Else
				aColsA[LEN(aColsA),nI] := oNO
			EndIf
		NEXT nI                                       

		aColsA[1, LEN(aHeaderBco)+1] := .F.
	ENDIF

	If Select("QRY") > 0 
		DBCLOSEAREA("QRY")
	EndIF

RETURN aColsA


// --------------------------------------------------------------------------------------------------------
// InÃ­cio da ViewDef e ModelDef.
// --------------------------------------------------------------------------------------------------------
Static Function ModelDef()
 Local oModel		:= MPFormModel():New("mdlADEST068P",, {|| .T.})
 Local oStrutSA1	:= FWFormStruct(1,"SA1")
 
 oModel:SetDescription("..:: Cadastro de Cliente ::..")
 
 // CabeÃ§alho ZT3 (Pedidos)
 oModel:addFields("CABEC_SA1",nil,oStrutSA1)

 oModel:setPrimaryKey({"SA1_FILIAL","SA1_CODGI"})

return oModel


Static Function viewDef()
 Local oView		:= Nil
 Local oModel		:= FWLoadModel("ADEST068P")
 Local oStrutSA1	:= FWFormStruct(2,"SA1")
  
 DbSelectArea("SA1")
 
 SA1->(DbSetOrder(1))
  
 oView	:= FWFormView():New()
 oView:setModel(oModel)
 
 oView:GetProgressBar(.T.)
 
 oView:addField("V_CABEC_SA1",oStrutSA1,"CABEC_SA1")
   
 oView:createHorizontalBox("H_CABEC",100)
 oView:createVerticalBox("V_CABEC",100	,"H_CABEC")
 
 oView:setOwnerView("V_CABEC_SA1","V_CABEC")
  
Return oView
