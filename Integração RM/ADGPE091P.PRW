#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"

/*/{Protheus.doc} User Function ADGPE091P
    Retorna os kits disponíveis.
    Chamado 8465
    @type  Function
    @author Leonardo P. Monteiro
    @since 18/02/2022
    @version 01
	@history Chamado 16833 - Leonardo P. Monteiro - 18/02/2022 - Desenvolvimento inicial.
	@history Chamado 16833 - Leonardo P. Monteiro - 10/03/2022 - Correção de error.log.
	
    /*/

User Function ADGPE091P()

	//Define quais colunas (campos da TTRB) serao exibidas na MsSelect
	Local cCampos			:= "ZHN_CODIGO, ZHN_DESCRI"
	
	Private oGetPesq
	Private oGroup1
	Private oGet
	Private oDlg
	Private oOrdem
	Private oButton
	Private aCampos 		:= {}
	Private aColsBco		:= {}
	Private aHeaderBco		:= {}
	Private aItens			:= {"Código","Descrição"}
	Private cPesquisa		:= space(60)
	Private cOrdem			:= ""
	Private aButtons		:= {}
	Private nCont			:= 0
	Private cRetorno		:= ""

	Private cFOpen			:= ""
	Private oOk 			:=	LoadBitmap( GetResources(), "LBOK")
	Private oNo 			:=	LoadBitmap( GetResources(), "LBNO")
	Private bOk				:= {|| cRetorno := fOk(),odlg:End()}
	
	aHeaderBco 	:= MontCabec(cCampos, , 1)
	aColsBco	:= MontDados()

	if !Empty(aColsBco[1][2])
		@ 050,001 TO 600, 600 DIALOG oDlg TITLE "..:: Seleção de Kits ::.."

		oGroup1 	:= tGroup():New(033,002,75,300,'Pesquisar',oDlg,,,.T.)
		oOrdem 		:= tComboBox():New(43,10,{|u|if(PCount()>0,cOrdem:=u,cOrdem)},aItens,80,20,oGroup1,,{|| fOrdena()},,,,.T.,,,,,,,,,'nOrdem')
		oGetPesq	:= TGet():New(43,90,{|u| if(PCount()>0,cPesquisa:=u,cPesquisa)}, oGroup1,133,14,'',,,,,,,.T.,,,,,,,,,,'cPesquisa')
		oButton		:=tButton():New(43,227,'Pesquisa',oDlg,{||fPesquisa(1)},70,14,,,,.T.)
		oGet		:= MsNewGetDados():New(077,003,260,300, 2,"AllwaysTrue","AllwaysTrue",,{"ZHN_CODIGO"},,nCont,"AllwaysTrue", "AllwaysTrue","", oDlg, aHeaderBco, aColsBco, "AllwaysTrue")	
		oGet:oBrowse:BldBlclick := {|| fSeleciona()}
		
		ACTIVATE DIALOG oDlg On Init (EnchoiceBar(oDlg,{|| MsAguarde(bOk,"Processando, aguarde...","Aguarde..." )},{|| cRetorno := "", oDlg:End()},,aButtons)) CENTER
	else
		msginfo("Não existe itens disponíveis para inclusão.")
	endif

	IF Select("Query1") > 1
	    DbCloseArea("Query1")
	EndIF

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para seleção de cliente')
	

Return cRetorno

Static Function fOk()
	Local cRet := ""

	Local nPosOk		:= Ascan( oGet:aHeader, { |x| Alltrim(x[2]) == "OK"  })
	Local nPosCod		:= Ascan( oGet:aHeader, { |x| Alltrim(x[2]) == "ZHN_CODIGO" })
	local nA			:= 0
	
	DbSelectArea("ZHN")
	ZHN->(DbsetOrder(1))

	For nA := 1 TO Len(oGet:aCols)  
		If oGet:aCols[nA][nPosOk] == oOk

            cRet += iif(Empty(cRet),"'",",'")+ALLTRIM(oGet:aCols[nA][nPosCod])+"'"
			
		EndIf
	Next nA

return cRet

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
	cArqTrab:AddIndex("01",{"ZHN_CODIGO"})
    cArqTrab:AddIndex("02",{"ZHN_DESCRI"})
	
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
		aSort(oGet:aCols,,,{|x,y| x[1]<y[1]})
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
STATIC FUNCTION MontDados()
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

	cQry := " SELECT ZHN_CODIGO, ZHN_DESCRI " + cEOL
	cQry += " FROM "+ RetSqlName("ZHN") +" (NOLOCK) ZHN " + cEOL
	cQry += " WHERE ZHN.D_E_L_E_T_='' AND ZHN.ZHN_MSBLQL !='1' " + cEOL
	cQry += " ORDER BY ZHN.ZHN_CODIGO; " + cEOL

	TcQuery cQry alias "QRY" new
	
	Count TO nCont

	QRY->(DBGOTOP())

	IF nCont != 0
		WHILE qry->(!EOF())
			AADD( aColsA, Array(LEN(aHeaderBco) + 1 ) )	
			FOR nI := 1 TO LEN(aHeaderBco)

				If nI == 1

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

