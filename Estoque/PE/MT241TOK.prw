#include 'rwmake.ch'
#include 'protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT241TOK ºAutor  ³Wellington Santos   º Data ³ 19/01/2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PE das Requisicoes Internas (Mod.2) antes da gravacao (valiº±±
±±º          ³ dacao da tela) usado para validar a C.Contabil (Investimen-º±±
±±º          ³ to ou Resultado) e o No. Projeto quando o CCusto = 9xxx    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT241TOK 

	Private _nTpConta, _lOk
	_lOk := .T.
	// Recuperar a posicao dos campos CContabil e Projeto no aHeader
	_nPCContab := aScan( aHeader, {|x| x[2] = "D3_CONTA" } )
	_nPProjeto := aScan( aHeader, {|x| x[2] = "D3_PROJETO" } )
	_nPProduto := aScan( aHeader, {|x| x[2] = "D3_COD" } )
	
	For i = 1 To Len(aCols)
		dbSelectArea('SB1')
		dbSetOrder(1)
		dbSeek( xFilial('SB1') + aCols[i][_nPProduto] )
		_cProd := Trim(B1_COD) + ' - ' + subStr(Trim(B1_DESC),1,18)
		
		// Verifica se CContabil esta como Resultado ou Investimento
		If aCols[i][_nPCContab] <> SB1->B1_CONTAA .and. aCols[i][_nPCContab] <> SB1->B1_CONTAR
			_lOk := .F.
			If SubStr(CCC,1,1) = '9'
		      _nTpConta := 0
			   Do While _nTpConta <> 1 .and. _nTpConta <> 2
				   _nTpConta := escolhe()
				   Do Case
				      Case _nTpConta = 1
						   aCols[i][_nPCContab] := SB1->B1_CONTAR
						   _lOk := .T.
				      Case _nTpConta = 2
						   aCols[i][_nPCContab] := SB1->B1_CONTAA
						   _lOk := .T.						   
					EndCase
				EndDo
				// Verifica se Projeto nao foi informado
				If Empty(aCols[i][_nPProjeto])
				   MsgAlert('Informe o Codigo do Projeto !!!', _cProd )
				   _lOk := .F.
				EndIf
			Else
			   aCols[i][_nPCContab] := SB1->B1_CONTAR
				_lOk := .T.				   	
			EndIf
		EndIf
	Next
Return(_lOk)

Static Function Escolhe
	// Variaveis Locais da Funcao
	Local nRadioGrp1	:= 0
	Local oRadioGrp1
	Local aOptions 	:= {'Resultado','Investimento'}
	
	// Variaveis Private da Funcao
	Private _oDlg				// Dialog Principal

	DEFINE MSDIALOG _oDlg TITLE "Conta Contabil" FROM C(329),C(333) TO C(470),C(497) PIXEL
		// Cria Componentes Padroes do Sistema
		@ C(003),C(005) Say _cProd Size C(092),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(014),C(003) TO C(050),C(080) LABEL "Escolha a Conta: " PIXEL OF _oDlg
		@ C(021),C(006) Radio oRadioGrp1 Var nRadioGrp1 Items "Resultado","Investimento" 3D Size C(056),C(010) PIXEL OF _oDlg
		DEFINE SBUTTON FROM C(055),C(032) TYPE 1 ENABLE OF _oDlg ACTION (_oDlg:End())
	ACTIVATE MSDIALOG _oDlg CENTERED 
Return(nRadioGrp1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C(nTam)                                                         
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
		nTam *= 1                                                                  
	Else	// Resolucao 1024x768 e acima                                           
		nTam *= 1.28                                                               
	EndIf                                                                         
                                                                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                               
	//³Tratamento para tema "Flat"³                                               
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                               
	If "MP8" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
Return Int(nTam)