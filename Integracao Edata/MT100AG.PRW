#INCLUDE "rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "ParmType.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT100AG   ºAutor  ³WILLIAM COSTA       º Data ³  15/01/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada utilizado para realizar um procedimento de º±±
±±º          ³execução complementar após a confirmação de "Inclusão,      º±±
±±º          ³Classificação ou exclusão" de um Documento de Entrada.      º±±
±±º          ³Utilizado na troca de serie do tipo VC  (via cega) para a   º±±
±±º          ³Serie 01 solucionando erro que acontecia no momento da      º±±
±±º          ³geracao da nota de devolucao.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºChamado   ³051254 || OS 052617 || FISCAL || DEJAIME || 8921 ||         º±±  
±±º          ³|| PED. COMPRA - FWNM - 23/08/2019                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT100AG()

	// Chamado n. 051254 || OS 052617 || FISCAL || DEJAIME || 8921 || PED. COMPRA - FWNM - 23/08/2019
	Local aAreaSD1 := SD1->( GetArea() ) 
	Local aAreaSF1 := SF1->( GetArea() ) 	
	Local aAreaSC7 := SC7->( GetArea() )
	// 
	
	Local Area := GetArea()
	Local lRet := .T.  
	
	// tratamento formulário proprio
	If ALLTRIM(FunName())    == "MATA103" .AND. ; 
	   SF1->F1_FORMUL        == "S"       .AND. ;
	   SF1->F1_TIPO          == "D"       .AND. ;
	   ALLTRIM(SF1->F1_SERIE)== "VC"      .AND. ;
	   L103CLASS             == .T.       .AND. ;  
	   lRet                  == .T.
	 
		If !NfeNextDoc()
			lRet	:= .F.
   		EndIf
   	Endif
   	
	//19/03/2018 - CHAMADO: 040449 - FERNANDO SIGOLI COMENTANDO DEVIDO A DUPLICIDADE DE ROTINA MT103FIM	
   	//&&Mauricio - 04/08/17 - Chamado 036436 
   	//If Alltrim(cEmpAnt) == "01" .And. Alltrim(cFilAnt) $ "03"  
	//	TrsfEstD3() 	
	//EndIf
   	   	   	     	
   	lRet := .F.
	
	RestArea(Area)
	
	// Chamado n. 051254 || OS 052617 || FISCAL || DEJAIME || 8921 || PED. COMPRA - FWNM - 23/08/2019
	RestArea( aAreaSD1 ) 
	RestArea( aAreaSF1 ) 	
	RestArea( aAreaSC7 )
	//
	 
Return (lRet)       

Static Function NfeNextDoc()

	Local aArea	   := GetArea()
	Local aAreaSF1 := SF1->(GetArea())
	Local lRetorno := .T.
	Local nItensNf := 0
	Local cTipoNf  := SuperGetMv("MV_TPNRNFS")
	Local cNum103  := ""  
	Local cMT103SRI:= ""
	
	If SF1->F1_FORMUL == "S"
		Private cNumero:= ""
		Private cSerie1:= ""

		// FWNM - 16/04/2018 - CHAMADO 040694
		Do While .t.
			lRetorno:= Sx5NumNota(@cSerie1,cTipoNf)
			
			If lRetorno
				Exit
			EndIf
		EndDo
		// FWNM - 16/04/2018 - CHAMADO 040694
		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Validacao da NF informada pelo usuario                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRetorno .And. cTipoNF <> "3"
			SF1->(dbSetOrder(1))
			If SF1->(MsSeek(xFilial("SF1")+PADR(cNumero,TamSx3("F1_DOC")[1])+cSerie1+cA100For+cLoja,.F.))
				Help(" ",1,"EXISTNF")
				lRetorno := .F.
				cNumero := ""
				cSerie1 := ""
			EndIf
		EndIf
		If lRetorno
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o numero de maximo de itens da serie.               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aEval(aCols,{|x| nItensNf += IIF(x[Len(x)],0,1)})
			If nItensNf > 0 	.And. nItensNf > a460NumIt(cSerie1,.T.)
				Help(" ",1,"A100NITENS")
				lRetorno := .F.
			Else
				If cTipoNf <> "3"
					// Se numeracao for SXE/SXF e usuario alterou numero, respeita numero do usuarop
					If cTipoNf <> "2" .OR. !lMudouNum
						cNumero := NxtSX5Nota(cSerie1, NIL, cTipoNf)
					EndIf	
				Else 
					If !lMudouNum	// Verifica se usuario alterou numero da nota fiscal
						cNumero := Space(TamSx3("F1_DOC")[1])
					EndIf	
				EndIf
			EndIf
		EndIf
	
		If lRetorno
			cNFiscal	:= cNumero
			cSerie	    := cSerie1
	    EndIf
	EndIf
	
	RestArea(aAreaSF1)
	RestArea(aArea)
	
Return(lRetorno)

Static Function TrsfEstD3()

Local aArea		:= GetArea()
Local aAreaSA2  := GetARea("SA2")
Local aAreaSA1  := GetARea("SA1")
Local aAreaSF1 := SF1->(GetArea())
Local aAreaSD1 := SD1->( GetArea() ) //SF1->(GetArea()) // ti - fwnm - 04/07/2022
Local cTesRem	:= GetMv("MV_#TESENT")
Local cAlDes	:= cAlOri := ""
Local lContinua :=.F.
Local cNumseq   := ""
Local lRecDif   :=.F.
Local lGera		:= .T.
Local cAliasSD3	:= CriaTrab(NIL,.F.)
Local cQuery	:= ""
Local cDoc		:= ""
Local aItens    := {}
Local cLocPad   := ""
Local cLocSb1   := ""
Local cLocSbz   := ""
Local cLocDest  := ""

If SF1->F1_TIPO == "N"   //Entrada normal Castro de Fornecedor
	SA2->(dbSetOrder(1))
	SA2->(dbSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA))
	If SA2->(!EOF())
		If !Empty(SA2->A2_LOCAL)
			cAlDes := SA2->A2_LOCAL
			lContinua:=.T.
		EndIf
	EndIf
ElseIf SF1->F1_TIPO == "B"  //devolução  - Cadastro de cliente
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA))
	If SA1->(!EOF())
		If !Empty(SA1->A1_LOCAL)
			cAlDes := SA1->A1_LOCAL
			lContinua:=.T.
		EndIf
	EndIf
EndIf

If lContinua
	
	SD1->(dbSetOrder(1))
	SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
	While SD1->(!EOF()) .and. xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
		
		If !Empty(SD1->D1_NFORI) .and. Alltrim(SD1->D1_TES) $ cTesRem
			
			// avalia se houve a transferência origem -  trava de segurança
			cQuery := "SELECT SD1.R_E_C_N_O_ AS REC "
			cQuery += "FROM " + RetSqlName("SF1") + " SF1," + RetSqlName("SD1")+" SD1 "
			cQuery += "WHERE F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA=D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA AND "
			cQuery += "F1_DOC = '" + SF1->F1_DOC + "' AND "
			cQuery += "F1_SERIE = '" + SF1->F1_SERIE + "' AND "
			cQuery += "F1_FORNECE = '" + SF1->F1_FORNECE + "' AND "
			cQuery += "F1_LOJA = '" + SF1->F1_LOJA + "' AND "
			cQuery += "SF1.D_E_L_E_T_ = ' ' AND "
			cQuery += "SD1.D_E_L_E_T_ = '*' "
			cQuery += "	AND NOT EXISTS (SELECT 1 FROM "+RetSqlname("SD3") +" WHERE SD1.R_E_C_N_O_ = D3_XRECSD2 AND D3_XRECSD2 <> '')
			
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD3,.T.,.F.)
			
			If (cAliasSD3)->REC > 0
				lGera:=.F.
			EndIf
			
			DbSelectArea(cAliasSD3)
			dbCloseArea()
			
			If lGera
												
				Begin Transaction
				
				cDoc:= GetSXENum("SD3","D3_DOC")
				
				cNumseq := ProxNum()
				
				aadd (aItens,{cDoc	 ,ddatabase})
				aadd (aItens,{})
				
				SB1->(DbSetOrder(1))
				SB1->(DbSeek( xFilial("SB1") + SD1->(D1_COD) ))
				
				cLocSb1 := SB1->B1_LOCPAD
				
				SBZ->(DbSetOrder(1))
				SBZ->(DbSeek( xFilial("SBZ") + SD1->(D1_COD) ))
				
				cLocSbz := SBZ->BZ_LOCPAD
				
				If Empty(cLocSbz)
					cLocPad := cLocSb1
				Else
					cLocPad := cLocSbz
				EndIf
				
				cLocDest :=IIF(Empty(SD1->D1_LOCAL),cLocPad,SD1->D1_LOCAL)
				
				//tratamento para criar armazem no SB2 - destino
				SB2->(DbSetOrder(1))
				If !SB2->(DbSeek( xFilial("SB2") + SD1->(D1_COD) + cLocDest ))
					CriaSB2(SD1->(D1_COD),cLocDest)
				EndIf
				
				aItens[2] :=  {{"D3_COD" 		, SB1->B1_COD			,NIL}}// 01.Produto Origem
				aAdd(aItens[2],{"D3_DESCRI" 	, SB1->B1_DESC			,NIL})// 02.Descricao
				aAdd(aItens[2],{"D3_UM"     	, SB1->B1_UM			,NIL})// 03.Unidade de Medida
				aAdd(aItens[2],{"D3_LOCAL"  	, cAlDes			    ,NIL})// 04.Local Origem
				aAdd(aItens[2],{"D3_LOCALIZ"	, CriaVar("D3_LOCALIZ")	,NIL})// 05.Endereco Origem
				aAdd(aItens[2],{"D3_COD"    	, SB1->B1_COD			,NIL})// 06.Produto Destino
				aAdd(aItens[2],{"D3_DESCRI" 	, SB1->B1_DESC			,NIL})// 07.Descricao
				aAdd(aItens[2],{"D3_UM"     	, SB1->B1_UM			,NIL})// 08.Unidade de Medida
				
				aAdd(aItens[2],{"D3_LOCAL"  	, cLocDest			    ,NIL})// 09.Armazem Destino
				aAdd(aItens[2],{"D3_LOCALIZ"	, CriaVar("D3_LOCALIZ")	,NIL})// 10.Endereco Destino
				aAdd(aItens[2],{"D3_NUMSERI"	, CriaVar("D3_NUMSERI")	,NIL})// 11.Numero de Serie
				aAdd(aItens[2],{"D3_LOTECTL"	, CriaVar("D3_LOTECTL")	,NIL})// 12.Lote Origem
				aAdd(aItens[2],{"D3_NUMLOTE"	, CriaVar("D3_NUMLOTE")	,NIL})// 13.Sub-Lote
				aAdd(aItens[2],{"D3_DTVALID"	, CriaVar("D3_DTVALID")	,NIL})// 14.Data de Validade
				aAdd(aItens[2],{"D3_POTENCI"	, CriaVar("D3_POTENCI")	,NIL})// 15.Potencia do Lote
				aAdd(aItens[2],{"D3_QUANT"  	, SD1->(D1_QUANT)		,NIL})// 16.Quantidade
				aAdd(aItens[2],{"D3_QTSEGUM"	, CriaVar("D3_QTSEGUM")	,NIL})// 17.Quantidade na 2 UM
				aAdd(aItens[2],{"D3_ESTORNO"	, CriaVar("D3_ESTORNO")	,NIL})// 18.Estorno
				aAdd(aItens[2],{"D3_NUMSEQ" 	, cNumseq				,NIL})// 19.NumSeq
				aAdd(aItens[2],{"D3_LOTECTL"	, CriaVar("D3_LOTECTL")	,NIL})// 20.Lote Destino
				aAdd(aItens[2],{"D3_DTVALID"	, CriaVar("D3_DTVALID")	,NIL})// 21.Data de Validade Destino
				
				lMsErroAuto := .F.
				
				MsExecAuto({|x| MATA261(x)},aItens)
				
				If lMsErroAuto
					DisarmTransaction()
					MostraErro()
				EndIf
				
				End Transaction
				
			Endif
			
		EndIf
		SD1->(dbSkip())
	Enddo
	
EndIf

RestArea(aAreaSA2)
RestArea(aAreaSA1)
RestArea(aAreaSF1)
RestArea(aAreaSD1)
RestArea(aArea)

Return() 
