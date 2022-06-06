#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} User Function MSD2520
	Esse ponto de entrada está localizado na função A520Dele(). É chamado antes da exclusão do registro no SD2.
	Gera movimentação de estorno da trasnferência entre armazéns
	@type  Function
	@since  10/2013
	@history Ticket 000001 - Abel Babini - 28/09/2020 - Permitir a exclusão de NF emitidas pelo módulo do Ativo Fixo.
	@history Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
	/*/
User Function MSD2520

	IF !Empty(Alltrim(SD2->D2_PEDIDO)) // @history 058172 - Abel Babini - 22/06/2020 - Permitir a exclusão de NF emitidas pelo módulo do Ativo Fixo.
		If cEmpAnt == "01" //Valida apenas para empresa 01-Adoro //Incluido por Adriana chamado 025947
			
			MSD2_1() // ponto de entrada ja existente na base de dados da Adoro
			
			MSD2_2() // Executara transferencia de ovos para armazem incubatorio conforme parametros
			
		Endif
	ENDIF

Return()

/*/{Protheus.doc} User Function MSD2_1()
	Esse ponto de entrada está localizado na função A520Dele(). É chamado antes da exclusão do registro no SD2.
	@type  Function
	/*/
Static Function MSD2_1()
	Local cFilSF:= GetMv("MV_#SFFIL",,"02|0B|") 	//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
	Local cEmpSF:= GetMv("MV_#SFEMP",,"01|") 		//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI

	// EXECUTADO NA EXCLUSAO DA NOTA
	//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
	if Alltrim(xFilial("SD2")) $ cFilSF .and. ALLTRIM(CEMPANT)$ cEmpSF     //somente para Adoro Varzea
		If VAL(SD2->D2_ITEM) = 1
			DbselectArea("SC5")
			DbSetOrder(1)
			DbSeek(xFilial("SC5")+SD2->D2_PEDIDO)
			if Reclock("SC5",.f.)
				SC5->C5_NLACRE1 := SPACE(10)
				SC5->(MsUnlock())
			endif
			
			dbSelectArea("SC9") // Itens de pedido liberado
			dbSetOrder(1) // Indice ( pedido )
			If dbSeek( xFilial("SC9")+SD2->D2_PEDIDO)
				While !eof() .and. SC9->C9_FILIAL+SC9->C9_PEDIDO = xFilial("SC9")+SD2->D2_PEDIDO
					if Reclock("SC9",.f.)
						SC9->C9_LACRE1 := SPACE(10)
						SC9->C9_VEND1 := SC5->C5_VEND1
						SC9->(MsUnlock())
					endif
					SC9->(Dbskip())
				end
			Endif
		Endif
	Endif
Return()

/*/{Protheus.doc} User Function MSD2_2()
	Gera movimentação de estorno da trasnferência entre armazéns
	este programa estorna fazendo um movimento inverso
	ele nao cancela o movimento original, isso para que fique registrado
	no sistema o estorno
	@type  Function
	@since 10/2013
	/*/
Static Function MSD2_2()
	Local aArea		:= GetArea()
	Local aAreaSA2  := GetARea("SA2")
	Local aAreaSA1  := GetARea("SA1")
	Local cTesRem	:= SuperGetMV("FS_TESREMI" ,,"702|705|735")  // KF 30/11/15
	Local cAlDes	:= cAlOri := ""
	Local lContinua :=.F.
	Local cNumseq   := ""
	Local lRecDif   :=.F.
	Local lGera		:= .T.
	Local cAliasSD3	:= CriaTrab(NIL,.F.)
	Local cQuery	:= ""
	Local cDoc		:= ""
	Local aItens    := {}

	If SF2->F2_TIPO == "N"
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
		If SA1->(!EOF())
			If !Empty(SA1->A1_LOCAL)
				cAlOri := SA1->A1_LOCAL
				lContinua:=.T.
			EndIf
		EndIf
	ElseIf SF2->F2_TIPO == "B"
		SA2->(dbSetOrder(1))
		SA2->(dbSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA))
		If SA2->(!EOF())
			If !Empty(SA2->A2_LOCAL)
				cAlOri := SA2->A2_LOCAL
				lContinua:=.T.
			EndIf
		EndIf
	EndIf

	If lContinua
		
		Private lMsErroAuto := .F.
		
		// avalia se houve a transferência origem -  trava de segurança
		cQuery := "SELECT SD2.R_E_C_N_O_ AS REC "
		cQuery += "FROM " + RetSqlName("SF2") + " SF2," + RetSqlName("SD2")+" SD2 "
		cQuery += "WHERE F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA=D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA AND "
		cQuery += "F2_DOC = '" + SF2->F2_DOC + "' AND "
		cQuery += "F2_SERIE = '" + SF2->F2_SERIE + "' AND "
		cQuery += "F2_CLIENTE = '" + SF2->F2_CLIENTE + "' AND "
		cQuery += "F2_LOJA = '" + SF2->F2_LOJA + "' AND "
		cQuery += "SF2.D_E_L_E_T_ = ' ' AND "
		cQuery += "SD2.D_E_L_E_T_ = '*' "
		cQuery += "	AND NOT EXISTS (SELECT 1 FROM "+RetSqlname("SD3") +" WHERE SD2.R_E_C_N_O_ = D3_XRECSD2 AND D3_XRECSD2 <> '')
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD3,.T.,.F.)
		
		If (cAliasSD3)->REC > 0
			lGera:=.F.
		EndIf
		
		DbSelectArea(cAliasSD3)
		dbCloseArea()

		If lGera
			Begin Transaction
			
			cNumseq := ProxNum()
			
			//valida documento
			//cDoc:=VerDocSD3(GetSXENum("SD3","D3_DOC"))
			cDoc:= GetSXENum("SD3","D3_DOC")
			
			aadd (aItens,{	cDoc ,ddatabase})
			
			aadd (aItens,{})
			
			SB1->(DbSetOrder(1))
			SB1->(DbSeek( xFilial("SB1") + SD2->(D2_COD) ))
			
			aItens[2] :=  {{"D3_COD" 		, SB1->B1_COD			,NIL}}// 01.Produto Origem
			aAdd(aItens[2],{"D3_DESCRI" 	, SB1->B1_DESC			,NIL})// 02.Descricao
			aAdd(aItens[2],{"D3_UM"     	, SB1->B1_UM			,NIL})// 03.Unidade de Medida
			aAdd(aItens[2],{"D3_LOCAL"  	, cAlOri     			,NIL})// 04.Local Origem
			aAdd(aItens[2],{"D3_LOCALIZ"	, CriaVar("D3_LOCALIZ")	,NIL})// 05.Endereco Origem
			aAdd(aItens[2],{"D3_COD"    	, SB1->B1_COD			,NIL})// 06.Produto Destino
			aAdd(aItens[2],{"D3_DESCRI" 	, SB1->B1_DESC			,NIL})// 07.Descricao
			aAdd(aItens[2],{"D3_UM"     	, SB1->B1_UM			,NIL})// 08.Unidade de Medida
			aAdd(aItens[2],{"D3_LOCAL"  	, SD2->D2_LOCAL			,NIL})// 09.Armazem Destino
			aAdd(aItens[2],{"D3_LOCALIZ"	, CriaVar("D3_LOCALIZ")	,NIL})// 10.Endereco Destino
			aAdd(aItens[2],{"D3_NUMSERI"	, CriaVar("D3_NUMSERI")	,NIL})// 11.Numero de Serie
			aAdd(aItens[2],{"D3_LOTECTL"	, CriaVar("D3_LOTECTL")	,NIL})// 12.Lote Origem
			aAdd(aItens[2],{"D3_NUMLOTE"	, CriaVar("D3_NUMLOTE")	,NIL})// 13.Sub-Lote
			aAdd(aItens[2],{"D3_DTVALID"	, CriaVar("D3_DTVALID")	,NIL})// 14.Data de Validade
			aAdd(aItens[2],{"D3_POTENCI"	, CriaVar("D3_POTENCI")	,NIL})// 15.Potencia do Lote
			aAdd(aItens[2],{"D3_QUANT"  	, SD2->(D2_QUANT)		,NIL})// 16.Quantidade
			aAdd(aItens[2],{"D3_QTSEGUM"	, CriaVar("D3_QTSEGUM")	,NIL})// 17.Quantidade na 2 UM
			aAdd(aItens[2],{"D3_ESTORNO"	, CriaVar("D3_ESTORNO")	,NIL})// 18.Estorno
			aAdd(aItens[2],{"D3_NUMSEQ" 	, cNumseq				,NIL})// 19.NumSeq
			aAdd(aItens[2],{"D3_LOTECTL"	, CriaVar("D3_LOTECTL")	,NIL})// 20.Lote Destino
			aAdd(aItens[2],{"D3_DTVALID"	, CriaVar("D3_DTVALID")	,NIL})// 21.Data de Validade Destino
			
			lMsErroAuto := .F.
			
			MsExecAuto({|x| MATA261(x)},aItens)
			
			If lMsErroAuto
				MostraErro()
				DisarmTransaction()
			EndIf
			
			End Transaction
			
		EndIf
	EndIf

	RestArea(aAreaSA2)
	RestArea(aAreaSA1)
	RestArea(aArea)

Return()
