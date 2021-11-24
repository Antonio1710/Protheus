#INCLUDE "ParmType.ch"
#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"

//Posicao da estrutura TCBrowse
#DEFINE TCB_POS_CMP	1
#DEFINE TCB_POS_PIC	2
#DEFINE TCB_POS_TIT	3
#DEFINE TCB_POS_TAM	4
#DEFINE TCB_POS_TIP	5

//Largura das colunas FWLayer
#DEFINE LRG_COL01		20
#DEFINE LRG_COL02		70
#DEFINE LRG_COL03		10

//Posicoes do pergunte do SX1
#DEFINE POS_X1DES		1
#DEFINE POS_X1TIP		2
#DEFINE POS_X1TAM		3
#DEFINE POS_X1OBJ		6
#DEFINE POS_X1VLD		7
#DEFINE POS_X1VAL		8
#DEFINE POS_X1CB1		9
#DEFINE POS_X1CB2		10
#DEFINE POS_X1CB3		11
#DEFINE POS_X1CB4		12
#DEFINE POS_X1CB5		13
#DEFINE POS_X1VAR		14

//Posicoes da array de controle de NFs selecionadas
#DEFINE POS_NF_NUM		1
#DEFINE POS_NF_SER		2
#DEFINE POS_NF_CLI		3
#DEFINE POS_NF_LOJ		4

Static nQtdePerg		:= 7
Static nTamFil			:= IIf(FindFunction("FWSizeFilial"),FWSizeFilial(),2)
Static nTamArq			:= 500
Static nTopCont			:= 003
Static nEsqCont			:= 001
Static nAltCont			:= 009
Static nDistPad			:= 002
Static nAltBot			:= 013
Static nDistAPad		:= 004
Static nDistEtq			:= 001
Static nAltEtq			:= 007
Static nLargEtq			:= 035 
Static nLargBot			:= 040
Static cHK				:= "&"

/*/{Protheus.doc} User Function CCSP_001
	Rotina para envio de carga ao edata Integracao Protheus x Edata
	@type  Function
	@author CCSKF
	@since 14/06/2012
	@history chamado 048868 - Fernando Sigoli - 02/05/2019 - Adicionado Filial na Query, SqlVerifRoteiro
	@history chamado 049906 - Fernando Sigoli - 27/06/2019 - Na integração valida no Edata, se existe carga diferente de encerrada. Caso exitir, nao deixa integrar!
	@history chamado T.I    - Fernando Sigoli - 01/07/2019 - Nao validar roteiro em Pedido diversos, que ja emitiu nota fiscal saida
	@history chamado 051387 - Fernando Sigoli - 29/08/2019 - Tratamento na query, para pesquisar o roteiro do pedido na tabela SC5
	@history chamado T.I    - Fernando Sigoli - 10/10/2020 - Retorno das funçoes de begintran
	@history TICKET 4276    - William Costa   - 29/10/2020 - Retorno das funçoes de alterado todos os begintran() endTran para begin Transaction END Transaction, não utiliza mais a função
	@history TICKET 4276    - William Costa   - 30/10/2020 - Adicionado mensagem de cErro quando a variavel que validade se o pedido está liberado por credito ou estoque é preenchida com falso
	@history ticket 9122    - Fernando Maciei - 09/02/2021 - melhoria no envio Carga EDATA
	@history ticket 63303   - Leonardo P. Monteiro - 08/11/2021 - Melhoria na validação do estorno de cargas para não permitir a exclusão de cargas que já tenham pallets vinculados ao mesmo.
/*/
User Function CCSP_001()

	LOCAL oSay,oSay2,oSay3
	LOCAL oBtn1,oBtn2,oBtn3
	LOCAL oDlg            
	PRIVATE cPerg     :="CCSP01" 
	Private cCadastro :="Integracao Protheus x Edata"
	Private cErro     := ''

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Integracao Protheus x Edata')

	//Tratamento de uso exclusivo por usuario, evintando que o mesmo consiga abrir mais de uma tela.?

	IF LockByName("CCSP01_"+RetCodUsr())

		//Acerta dicionário de perguntas       
		
		AjustaSX1(cPerg)         

		Pergunte(cPerg,.T.)

		ProcLogIni( {},"CCSP01")

		DEFINE MSDIALOG oDlg FROM  96,9 TO 320,612 TITLE OemToAnsi(cCadastro) PIXEL
		@ 11,6 TO 90,287 LABEL "" OF oDlg  PIXEL
		@ 16, 15 SAY OemToAnsi("Este programa efetua a integracao com o EDATA") SIZE 268, 8 OF oDlg PIXEL			   									

		DEFINE SBUTTON FROM 93, 163 TYPE 15 ACTION ProcLogView() ENABLE OF oDlg
		DEFINE SBUTTON FROM 93, 193 TYPE 5  ACTION Pergunte(cPerg,.T.) ENABLE OF oDlg
		DEFINE SBUTTON FROM 93, 223 TYPE 1  ACTION If(.T.,(Processa({|lEnd| E001Proces()},OemToAnsi("Integracao Protheus x Edata"),OemToAnsi("Selecionando Registros..."),.F.),oDlg:End()),) ENABLE OF oDlg
		DEFINE SBUTTON FROM 93, 253 TYPE 2  ACTION oDlg:End() ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTERED    

	Else
		Aviso("CCSP_001","Rotina j?em uso pelo mesmo usuário!",{"Ok"})    
		Return
	EndIf

	//Destrava a rotina para o usuário	    
	
	UnLockByName("CCSP01_"+RetCodUsr())	

Return       

/*/{Protheus.doc} User Function E001Proces
	Rotina para envio de carga ao edata Integracao Protheus x Edata
	@type  Function
	@author CCSKF
	@since 02/05/10
/*/

Static Function E001Proces()

	Local aArea				:= SaveArea1({"SC5","SC6","SA1","SA2","SX3",Alias()})
	Local oArea				:= FWLayer():New()
	Local aCoord			:= FWGetDialogSize(oMainWnd)
	Local lMDI				:= oAPP:lMDI
	Local aTamObj			:= Array(4)
	Local aParam			:= Array(nQtdePerg)
	Local cTMP				:= ""
	Local cSepara			:= Space(1)
	Local aLstRotAux		:= {"CCSKFXFUN.PRW"}
	Local lTOP				:= .F.
	Local nCoefDif			:= 1
	Local aPergunte			:= {}
	Local cFile				:= Space(nTamArq)
	Local cDrive			:= ""
	Local cDir				:= ""
	Local cArqP				:= ""
	Local cExt				:= ""
	Local cDelim			:= ";"
	Local nRegua			:= 0
	Local ni				:= 0
	Local nx				:= 0
	Local lOk				:= .F.
	Local aLstC01			:= {" ","C5_DTENTR","C5_ROTEIRO","C5_PLACA","C5_NUM","C5_CLIENTE","A1_NREDUZ","C5_X_SQED","C5_XINT","C5_XOBS","C5_FILIAL","C5_XFATANT"}
	Local cLine01			:= ""
	Local oOk 				:= LoadBitmap(GetResources(),"LBOK")
	Local oNo 				:= LoadBitmap(GetResources(),"LBNO")
	Local bAtGD				:= {|lAtGD,lFoco| IIf(lAtGD,(oGD01:SetArray(_aDados01),oGD01:bLine := &(cLine01),oGD01:GoTop()),.T.),;
	IIf(ValType(lFoco) == "L" .AND. lFoco,oGD01:SetFocus(),.T.)}
	//Objetos graficos
	Local oTela
	Local oPainel01
	Local oPainel02
	Local oPainel03
	Local oPainelS01
	Local oBot01
	Local oBot02
	Local oBot03
	Local oBot04
	Local oBot05
	Local oGD01																							//Getdados

	Private cRotNome	:= "[" + StrTran(ProcName(0),"U_","") + "]" + Space(1)
	Private __oDlg
	Private cRotDesc	:= "Integracao Protheus x Edata"
	Private cNomeUs		:= Capital(AllTrim(UsrRetName(__cUserID)))
	Private oRegua
	Private aLstPED		:= {}																		//Lista de notas fiscais selecionadas
	Private aHeader01	:= {}
	Private _aDados01	:= {}
	Private cLnkSrv		:= Alltrim(SuperGetMV("MV_#UEPSRV",,"LNKMIMS"))

	#IFDEF TOP
	lTop := .T.
	#ENDIF
	
	//Validacoes  
	
	If !lTOP 
		MsgAlert(cNomeUs + ", esta rotina s?pode ser executada a partir de um banco de dados relacional.")
		Return Nil
	Endif
	For ni := 1 to Len(aLstRotAux)
		If Empty(GetAPOInfo(aLstRotAux[ni]))
			MsgAlert(cNomeUs + ", uma rotina auxiliar (" + aLstRotAux[ni] + ") necessária para a execução desta rotina não pode ser encontrada!")
			Return Nil		
		Endif
	Next ni

	//Montar o grupo de perguntas  
	
	AjustaSX1(cPerg)

	aFill(aTamObj,0)
	
	//Montar a lista de campos a utilizar na GD  
	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For ni := 1 to Len(aLstC01)
		If !Empty(aLstC01[ni]) .AND. SX3->(dbSeek(PadR(aLstC01[ni],10)))
			aAdd(aHeader01,{SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			AllTrim(X3Titulo()),;
			SX3->X3_TAMANHO,;
			SX3->X3_TIPO})
		Endif
	Next ni
	
	//Montar a lista de dados da GD  
	
	_aDados01 := Array(1,Len(aHeader01) + 1)
	For ni := 1 to Len(_aDados01)
		_aDados01[ni][1] := .F.
		For nx := 1 to Len(aHeader01)
			_aDados01[ni][nx + 1] := CriaVar(aHeader01[nx][TCB_POS_CMP],.F.)
		Next nx
	Next ni
	
	//Montar o codeblock para montar as listas de dados da GD  
	
	cLine01 := "{|| {"
	cLine01 += "IIf(_aDados01[oGD01:nAt,1],oOk,oNo),"
	For ni := 2 to Len(aLstC01)
		cLine01 += "_aDados01[oGD01:nAt," + cValToChar(ni) + "]" + IIf(ni < Len(aLstC01),",","")
	Next ni
	cLine01 += "}}"
	
	//Substituir o nome dos campos pelos titulos  
	
	For ni := 1 to Len(aLstC01)
		aLstC01[ni] := Posicione("SX3",2,PadR(aLstC01[ni],10),"X3Titulo()")
	Next ni
	
	//Interface  
	
	aCoord[3] := aCoord[3] * 0.95
	aCoord[4] := aCoord[4] * 0.95
	If U_ApRedFWL(.T.)
		nCoefDif := 0.95
	Endif

	CCSP001At(aClone(aHeader01),@_aDados01) 

	// **** INICIO VERIFICAR SE OS PEDIDOS ESTAO LIBERADO CHAMADO 031417 - WILLIAM COSTA**** //

	IF EMPTY(_aDados01)

		MsgAlert("Ol?" + cNomeUs + ", Pedidos não liberados", "Não Existe Pedidos Liberados")
		RestArea1(aArea)
		ProcLogAtu("FIM")

		RETURN NIL

	ENDIF  

	// **** FINAL VERIFICAR SE OS PEDIDOS ESTAO LIBERADO CHAMADO 031417 - WILLIAM COSTA**** //

	DEFINE MSDIALOG oTela TITLE (Capital(cRotDesc) + " " + cRotNome) FROM aCoord[1],aCoord[2] TO aCoord[3],aCoord[4] OF oMainWnd COLOR "W+/W" PIXEL

	oArea:Init(oTela,.F.)
	//Mapeamento da area
	oArea:AddLine("L01",100 * nCoefDif,.T.)
	
	//Colunas  
	
	oArea:AddCollumn("L01C01",LRG_COL01,.F.,"L01")
	oArea:AddCollumn("L01C02",LRG_COL02,.F.,"L01")
	oArea:AddCollumn("L01C03",LRG_COL03,.F.,"L01")
	
	//Paineis  
	
	oArea:AddWindow("L01C01","L01C01P01","Parâmetros",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oPainel01 := oArea:GetWinPanel("L01C01","L01C01P01","L01")
	oArea:AddWindow("L01C02","L01C02P01","Dados adicionais",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oPainel02 := oArea:GetWinPanel("L01C02","L01C02P01","L01")
	oArea:AddWindow("L01C03","L01C03P01","Funções",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oPainel03 := oArea:GetWinPanel("L01C03","L01C03P01","L01")
	
	//Painel 01 - Filtros  
	
	//PERGUNTAS
	U_DefTamObj(@aTamObj,000,000,(oPainel01:nClientHeight / 2) * 0.9,oPainel01:nClientWidth / 2)
	oPainelS01 := tPanel():New(aTamObj[1],aTamObj[2],"",oPainel01,,.F.,.F.,,CLR_WHITE,aTamObj[4],aTamObj[3],.T.,.F.)

	Pergunte(cPerg,.T.,,.F.,oPainelS01,,@aPergunte,.T.,.F.)

	//BOTAO PESQUISA
	U_DefTamObj(@aTamObj,(oPainel01:nClientHeight / 2) - nAltBot,000,(oPainel01:nClientWidth / 2),nAltBot,.T.)
	oBot01 := tButton():New(aTamObj[1],aTamObj[2],cHK + "Pesquisar",oPainel01,;
	{|| IIf(PFATA2VlP(cPerg,@aPergunte),;
	MsAguarde({|| CursorWait(),CCSP001At(aClone(aHeader01),@_aDados01),Eval(bAtGD,.T.,.T.),CursorArrow()},cRotNome,"Pesquisando",.F.),.F.)},;
	aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
	
	//Painel 02 - Lista de dados  
	
	oGD01 := TCBrowse():New(000,000,000,000,/*bLine*/,aLstC01,,oPainel02,,,,/*bChange*/,/*bLDblClick*/,/*bRClick*/,/*oFont*/,,,,,,,.T.,/*bWhen*/,,/*bValid*/,.T.,.T.)
	oGD01:bHeaderClick	:= {|oObj,nCol| CCSP001GD(2,@_aDados01,@oGD01,nCol,aClone(aHeader01)),oGD01:Refresh()}
	oGD01:blDblClick	:= {|| CCSP001GD(1,@_aDados01,@oGD01,,aClone(aHeader01)),oGD01:Refresh()}
	oGD01:Align 		:= CONTROL_ALIGN_ALLCLIENT
	Eval(bAtGD,.T.,.F.)

	//Painel 03 - Funcoes  
	
	//ENVIO EDATA
	U_DefTamObj(@aTamObj,000,000,(oPainel03:nClientWidth / 2),nAltBot,.T.)
	oBot01 := tButton():New(aTamObj[1],aTamObj[2],cHK + "Envio Edata",oPainel03,;
	{|| IIf(!Empty(aLstPED),;
	MsAguarde({|| CursorWait(),lOk := CCS_001P(@oTela),CursorArrow(),IIf(lOk,(CCSP001At(aClone(aHeader01),@_aDados01),Eval(bAtGD,.T.,.T.)),AllwaysTrue())},;
	cRotNome,"Processando",.F.),MsgAlert(cNomeUs + ", para processar ?necessário que ao menos um registro seja selecionado!",cRotNome))},;
	aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)

	//ESTORNO EDATA
	U_DefTamObj(@aTamObj,aTamObj[1] + nAltBot + nDistPad)
	oBot02 := tButton():New(aTamObj[1],aTamObj[2],cHK + "Estorno",oPainel03,;
	{|| IIf(!Empty(aLstPED),;
	MsAguarde({|| CursorWait(),lOk := CCS_001E(@oTela),CursorArrow(),IIf(lOk,(CCSP001At(aClone(aHeader01),@_aDados01),Eval(bAtGD,.T.,.T.)),AllwaysTrue())},;
	cRotNome,"Processando",.F.),MsgAlert(cNomeUs + ", para processar ?necessário que ao menos um registro seja selecionado!",cRotNome))},;
	aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)

	//CONSULTA LOG
	U_DefTamObj(@aTamObj,aTamObj[1] + nAltBot + nDistPad)
	oBot03 := tButton():New(aTamObj[1],aTamObj[2],cHK + "ConsultaLog",oPainel03,{||CCS_001L(@oTela) },aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)

	//Troca de Placa
	U_DefTamObj(@aTamObj,aTamObj[1] + nAltBot + nDistPad)
	oBot04 := tButton():New(aTamObj[1],aTamObj[2],cHK + "Troca de Placa",oPainel03,{|| CCS_001T(@oTela)},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
	//Sair
	U_DefTamObj(@aTamObj,aTamObj[1] + nAltBot + nDistPad)
	oBot05 := tButton():New(aTamObj[1],aTamObj[2],cHK + "Sair",oPainel03,{|| oTela:End()},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)

	oTela:Activate(,,,.T.,/*valid*/,,{|| .T.})

	RestArea1(aArea)

	ProcLogAtu("FIM")

Return Nil

/*/{Protheus.doc} User Function CCSP001AT
	Rotina de atualizacao da lista de dados
	@type  Function
	@author Pablo Gollan Carreras
	@since 14/06/2012
	
/*/

Static Function CCSP001At(aHeader01,_aDados01)

	Local ni				:= 0
	Local nx				:= 0
	Local cLstC01			:= ""
	Local cAliasT			:= GetNextAlias()
	Local cTipoNF			:= "%('N')%"
	Local aTMP				:= {}
	Local nCont				:= 0
	Local aDtRef			:= Array(2)
	Local cDtVz				:= Space(8)

	//Definicoes de filtros  
	
	_aDados01 := Array(0)
	aDtRef[1] := DtoS(MV_PAR05)
	aDtRef[2] := DtoS(MV_PAR06)

	If MV_PAR07 == 1		//Pend. classificacao
		cRest01 := "C5_XINT IN ('1', ' ') "
	ElseIf MV_PAR07 == 5		//Pend. classificacao
		cRest01 := " 1 = 1"
	Else
		cRest01 := "C5_XINT = '" + ALLTRIM(STR(MV_PAR07)) + "' "
	EndIf

	cRest01 := "%" + cRest01 + "%"

	//Fazer a pesquisa dos dados  
	
	(cLstC01 := "",aEval(aHeader01,{|x| IIf(!Empty(x[TCB_POS_CMP]),cLstC01 += x[TCB_POS_CMP] + ",","")}),cLstC01 := "%" + Substr(cLstC01,1,Len(cLstC01) - 1) + "%")

	BeginSQL Alias cAliasT    

		SELECT C5_DTENTR,C5_ROTEIRO,C5_PLACA,C5_NUM,C5_CLIENTE,A1_NREDUZ,C5_X_SQED,C5_XINT,C5_XOBS,C5_FILIAL,C5_XFATANT
		FROM %table:SC5% SC5,  %table:SA1% SA1 
		WHERE SC5.%notDel% AND SA1.%notDel% AND SC5.C5_FILIAL = %xFilial:SC5% AND SA1.A1_FILIAL = %xFilial:SA1% 
		AND SC5.C5_CLIENTE = SA1.A1_COD
		AND SC5.C5_LOJACLI = SA1.A1_LOJA
		AND SC5.C5_TIPO = 'N'
		AND SC5.C5_PLACA <> ' '
		AND SC5.C5_NOTA = ' '
		AND SC5.C5_ROTEIRO BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
		AND SC5.C5_PLACA BETWEEN %exp:MV_PAR03% AND %exp:MV_PAR04%	
		AND SC5.C5_DTENTR BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR06%		
		AND %exp:cRest01% 	
		UNION ALL	
		SELECT C5_DTENTR,C5_ROTEIRO,C5_PLACA,C5_NUM,C5_CLIENTE,A2_NREDUZ,C5_X_SQED,C5_XINT,C5_XOBS,C5_FILIAL,C5_XFATANT
		FROM %table:SC5% SC5,  %table:SA2% SA2 
		WHERE SC5.%notDel% AND SA2.%notDel% AND SC5.C5_FILIAL = %xFilial:SC5% AND SA2.A2_FILIAL = %xFilial:SA2% 
		AND SC5.C5_CLIENTE = SA2.A2_COD
		AND SC5.C5_LOJACLI = SA2.A2_LOJA
		AND SC5.C5_TIPO = 'B'
		AND SC5.C5_PLACA <> ' '
		AND SC5.C5_NOTA = ' '
		AND SC5.C5_ROTEIRO BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
		AND SC5.C5_PLACA BETWEEN %exp:MV_PAR03% AND %exp:MV_PAR04%		
		AND SC5.C5_DTENTR BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR06%		
		AND %exp:cRest01% 	
		ORDER BY SC5.C5_DTENTR,SC5.C5_ROTEIRO,SC5.C5_PLACA,SC5.C5_NUM

	EndSQL
	(cAliasT)->(dbGoTop())
	If !(cAliasT)->(Eof())
		
		//Tratamento de tipo de dados  
		
		dbSelectArea("SX3")
		SX3->(dbSetOrder(2))
		For ni := 1 to Len(aHeader01)
			If !Empty(aHeader01[ni][TCB_POS_CMP]) .AND. aHeader01[ni][TCB_POS_TIP] # "C"
				SX3->(dbSeek(PadR(aHeader01[ni][TCB_POS_CMP],10)))
				If SX3->(Found())
					TcSetField(cAliasT,SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL)
				Endif
			Endif
		Next ni
		
		//Alimentar dados  
		
		Do While !(cAliasT)->(Eof())

			_lLib := .T.
			
			//Mauricio 08/01/16 - Novo tratamento para liberacao a integração.
			SC6->(dbSetOrder(1)) // Indice ( pedido )
			If SC6->(dbSeek((cAliasT)->(C5_FILIAL+C5_NUM)))
				While !SC6->(Eof()) .and. SC6->(C6_FILIAL+C6_NUM) == (cAliasT)->(C5_FILIAL+C5_NUM)

					SC9->(dbSetOrder(1)) // Indice ( pedido )
					If SC9->(dbSeek( SC6->(C6_FILIAL+C6_NUM+C6_ITEM)))
						IF SC6->C6_PRODUTO == SC9->C9_PRODUTO	//confiro se o produto eh o mesmo.
							If !Empty(SC9->C9_BLEST ) .OR. !Empty(SC9->C9_BLCRED) 
								
								_lLib := .F.
								cErro += "Ola " + cNomeUs + ", Existe Produto nesse Pedido que não está liberado credito ou Estoque Verifique com o Financeiro, Pedido: " + (cAliasT)->C5_NUM + CHR(13) + CHR(10)


							Endif
						Else
							_lLib := .F.
							cErro += "Ola " + cNomeUs + ", Existe Produto nesse Pedido que não está liberado credito ou Estoque Verifique com o Financeiro, Pedido: " + (cAliasT)->C5_NUM + CHR(13) + CHR(10)
						Endif
					Else
						_lLib := .F.
						cErro += "Ola " + cNomeUs + ", Existe Produto nesse Pedido que não está liberado credito ou Estoque Verifique com o Financeiro, Pedido: " + (cAliasT)->C5_NUM + CHR(13) + CHR(10)
					Endif
					SC6->(dbSkip())
				EndDo
			Else
				_lLib := .F.		
				cErro += "Ola " + cNomeUs + ", Existe Produto nesse Pedido que não está liberado credito ou Estoque Verifique com o Financeiro, Pedido: " + (cAliasT)->C5_NUM + CHR(13) + CHR(10)
			EndIf

			If _lLib
				aTMP := Array((cAliasT)->(FCount()) + 1)
				aTMP[1] := .F.
				For ni := 1 to (cAliasT)->(FCount())
					aTMP[ni + 1] := (cAliasT)->(FieldGet(ni))
				Next ni
				aAdd(_aDados01,aClone(aTMP))			
			EndIf                          
			(cAliasT)->(dbSkip())
		EndDo
	Else
		
		//Zerar lista de dados  
		
		_aDados01 := Array(1,Len(aHeader01) + 1)
		For ni := 1 to Len(_aDados01)
			_aDados01[ni][1] := .F.
			For nx := 1 to Len(aHeader01)
				_aDados01[ni][nx + 1] := CriaVar(aHeader01[nx][TCB_POS_CMP],.F.)
			Next nx
		Next ni	
	Endif
	U_FecArTMP(cAliasT)

Return Nil

/*/{Protheus.doc} User Function CCSP001GD
	Rotina pra fazer o tratamento de selecao de dados
	@type  Function
	@author Pablo Gollan Carreras
	@since 14/06/2012
	
/*/

Static Function CCSP001GD(nOpc,aDados,oGDSel,nColSel,aHead)

	Local ni				:= 0
	Local cRoteiro			:= ""

	PARAMTYPE 0	VAR nOpc		AS Numeric		OPTIONAL	DEFAULT 0
	PARAMTYPE 1	VAR aDados		AS Array		OPTIONAL	DEFAULT Array(0)
	PARAMTYPE 2	VAR oGDSel		AS Object		OPTIONAL	DEFAULT Nil
	PARAMTYPE 3	VAR nColSel		AS Numeric		OPTIONAL	DEFAULT 1
	PARAMTYPE 4	VAR aHead		AS Array		OPTIONAL	DEFAULT Array(0)

	If nOpc == 1
		dData     := U_GDField(2,aHead,aDados,TCB_POS_CMP,"C5_DTENTR",oGDSel:nAt,.T.)
		cRoteiro  := U_GDField(2,aHead,aDados,TCB_POS_CMP,"C5_ROTEIRO",oGDSel:nAt,.T.)
		cPlaca    := U_GDField(2,aHead,aDados,TCB_POS_CMP,"C5_PLACA",oGDSel:nAt,.T.)	
		If !Empty(cRoteiro)
			aDados[oGDSel:nAt][1] := !aDados[oGDSel:nAt][1]
			For ni := 1 to Len(aDados)
				If oGDSel:nAt<>ni 
					If U_GDField(2,aHead,aDados,TCB_POS_CMP,"C5_DTENTR",ni,.T.) == dData .and. ;
					U_GDField(2,aHead,aDados,TCB_POS_CMP,"C5_ROTEIRO",ni,.T.) == cRoteiro .and. ;
					U_GDField(2,aHead,aDados,TCB_POS_CMP,"C5_PLACA",ni,.T.) == cPlaca
						aDados[ni][1] := !aDados[ni][1]
					EndIf
				Endif
			Next ni
		Endif
	Else
		If nColSel == 1
			For ni := 1 to Len(aDados)
				If !Empty(U_GDField(2,aHead,aDados,TCB_POS_CMP,"C5_ROTEIRO",ni,.T.))
					aDados[ni][1] := !aDados[ni][1]
				Endif
			Next ni
		Else
			aDados := aSort(aDados,,,{|x,y| x[nColSel] < y[nColSel]})
		EndIf
	Endif
	
	
	//Montar a lista de titulos selecionados  
	
	aLstPED := Array(0)
	For ni := 1 to Len(aDados)
		If aDados[ni][1]
			aAdd(aLstPED,U_GDField(2,aHead,aDados,TCB_POS_CMP,{"C5_DTENTR","C5_ROTEIRO","C5_PLACA","C5_NUM","C5_CLIENTE","A1_NREDUZ","C5_X_SQED","C5_XINT","C5_XOBS","C5_FILIAL","C5_XFATANT"},ni,.T.))
		Endif
	Next ni
	//Forcar a atualizacao do browse
	oGDSel:DrawSelect()

Return Nil

/*/{Protheus.doc} User Function CCS_001P
	Rotina de processamento de registros selecionados
	@type  Function
	@author Pablo Gollan Carreras
	@since 14/06/2012
	
/*/

Static Function CCS_001P(oTela)

	Local lRet				:= .T.
	Local _nx				:= 0
	Local _xx				:= 0
	Local _nPedDiv			:= 0
	Local aArea				:= {}
	Local ni				:= 0
	Local cChave			:= ""
	Local cMens				:= ""
	Local cRest01			:= ""
	Local cQuery            := "" 
	Local lCargaOk          := .F.
	Local cPed              := ''
	Local cProduto          := ''
	Local ncontPedTot       := 0
	Local ncontPedNor       := 0
	Local ncontPedDiv       := 0
	Local lVldEnv			:= SuperGetMV("MV_ZSP001A",,.T.)

	Private cFilia         	:= ""

	// @history ticket 63303   - Leonardo P. Monteiro - 08/11/2021 - Melhoria na validação do estorno de cargas para não permitir a exclusão de cargas que já tenham pallets vinculados ao mesmo.
	If !LockByName("CCS_001P", .T., .F.) .AND. lVldEnv
	    u_GrLogZBE(Date(),TIME(),cUserName,"Lockbyname executado para a rotina CCS_001P.","SIGAFAT","CCS_001P",;
			    "Rotina já iniciada por outro usuário através da rotina CCS_001P. ",ComputerName(),LogUserName())
        
        MsgInfo("Rotina sendo executada por outro usuário! Aguarde o término da execução.", "..:: Em execução ::.. ")
    else

		PARAMTYPE 0	VAR oTela	AS Object	OPTIONAL	DEFAULT Nil

		If Empty(aLstPED) .OR. ValType(aLstPED) # "A"
			Return !lRet
		Endif

		//Montar a lista de contabilizacao  
		
		cData	 := ""
		cRoteiro := ""
		cPlaca	 := ""

		//Mauricio - 26/06/2017 - chamado 35017 - INICIO - Não processar se existir mais de um pedido DIVERSOS com roteiros iguais. Roteiros devem ser diferentes.
		_aPedDiv := {}
		For _nx := 1 to len(aLstPED)

			fchkped(aLstPED[_nx][4],aLstPED[_nx][5],aLstPED[_nx][10]) 
			cFilia := aLstPED[_nx][10]

		Next _nx

		If Len(_aPedDiv) > 0  // tem pedido diversos. Cada linha eh uma data de entrega + roteiro + pedido diferente.
			_aRotDiv := {}
			l_Ret := .F.
			_nPedDiv	:= _aPedDiv
			For _xx := 1 to _nPedDiv
				_nAscan := Ascan( _aRotDiv, { |x|x[ 01 ] == _aPedDiv[_xx][1]+_aPedDiv[_xx][2] } )
				If _nAscan <= 00
					Aadd( _aRotDiv, { _aPedDiv[_xx][1]+_aPedDiv[_xx][2] } )
				Else             //achou data de entrega + roteiro repetido
					l_Ret := .T.
				Endif
			Next _xx

			If l_Ret
				MsgInfo("Existem pedidos DIVERSOS com roteiros IGUAIS! Corrija isso antes do envio ao Edata.","Atenção")
				Return !lRet   
			Endif
		Endif   

		For ni := 1 to Len(aLstPED)                   

			If !(aLstPED[ni][8] $ "1|2|4| " )
				cMens += "- Roteiro não processado, enviado anteriormente Roteiro: [" + AllTrim(aLstPED[ni][2]) + "]" + CRLF
			Else

				If cData+cRoteiro+cPlaca <> AllTrim(Dtos(aLstPED[ni][1]))+AllTrim(aLstPED[ni][2])+AllTrim(aLstPED[ni][3])

					//Salva Roteiro em processamento
					cData	    := AllTrim(Dtos(aLstPED[ni][1]))
					cRoteiro    := AllTrim(aLstPED[ni][2])
					cPlaca	    := AllTrim(aLstPED[ni][3])
					cErro       := ""      
					lCargaOk    := .F.
					cPed        := ''
					cProduto    := ''
					ncontPedTot := 0
					ncontPedNor := 0
					ncontPedDiv := 0

					// Valida se a carga já existe no eData.
					fExistCarg(@lCargaOk)
					
					// Valida se a carga já existe no eData e não foi encerrada.
					fEnceCarg(@lCargaOk)

					// *** INICIO CHAMADO 038577 WILLIAM COSTA *** //
					// *** INICIO VERIFICA SE EXISTE CARGA DIVERSA EM CARGA NORMAL *** //
					SqlVerifRoteiro(cData,cRoteiro) //ve quantos pedidos tem no roteiro
					
					While TDIX->(!EOF())

						IF TDIX->CONT_PED > 0

							ncontPedTot := ncontPedTot + TDIX->CONT_PED   //Quantidade de Pedidos Normais

						ENDIF     

						IF TDIX->CONT_NORMAL > 0

							ncontPedNor := ncontPedNor + TDIX->CONT_NORMAL   //Quantidade de Pedidos Normais

						ENDIF

						IF TDIX->CONT_DIVERSOS > 0

							ncontPedDiv := ncontPedDiv + TDIX->CONT_DIVERSOS //Quantidade de Pedidos Diversos

						ENDIF     
						TDIX->(dbSkip())

					ENDDO
					TDIX->(dbCloseArea())

					IF ncontPedNor > 0 .AND. ncontPedDiv > 0 //significa que tem mais de um pedido no roteiro

						SqlVerifDiversos(cData,cRoteiro)
						While TDIZ->(!EOF())

							cPed := cPed + TDIZ->C5_NUM + ', '

							TDIZ->(dbSkip())

						ENDDO
						TDIZ->(dbCloseArea())

						cErro += "Olá" + cNomeUs + ", Existem pedidos DIVERSOS e pedidos normais dentro do mesmo Roteiro! Corrija isso antes do envio ao Edata." + " Pedidos: " + cPed + "não pode ficar junto com os outros. Pedidos Diversos C5_XTIPO == 2" + CRLF

					ENDIF

					// *** FINAL VERIFICA SE EXISTE CARGA DIVERSA EM CARGA NORMAL *** //

					// *** INICIO VERIFICA SE TODOS OS PRODUTOS QUE SERAO ENVIADOS ESTAO NO EDATA *** //

					IF ncontPedTot <> ncontPedDiv //significa que o pedidos sao normais

						SqlVerifProdutos(cData,cRoteiro)
						While TDJA->(!EOF())

							IF ALLTRIM(TDJA->IE_MATEEMBA) == '' //significa que o produto não esta cadastrado no Edata

								cProduto := cProduto + ALLTRIM(TDJA->C6_PRODUTO) + ', '

							ENDIF    
							TDJA->(dbSkip())

						ENDDO
						TDJA->(dbCloseArea())

					ENDIF	

					IF !EMPTY(cProduto)

						cErro += "Olá" + cNomeUs + ", Existe Produto nesse Roteiro que não est?cadastrado no Edata! Corrija isso antes do envio ao Edata." + " Produto: " + cProduto + "Verifique com o PCP" + CRLF

					ENDIF	

					// *** FINAL VERIFICA SE TODOS OS PRODUTOS QUE SERAO ENVIADOS ESTAO NO EDATA *** //

					// *** FINAL CHAMADO 038577 WILLIAM COSTA *** //				

					IF Empty(cErro)

						//Cria sequencia edata
						aRet := CCSP_001S (cData,cRoteiro,cPlaca)
						If 	aRet[1]
							cSeq := aRet[2]
						Else
							cMens += "- Roteiro não processado, erro no sequenciamento do edata: [" + AllTrim(aLstPED[ni][2]) + "]" + CRLF			
							loop
						EndIf                 

					ENDIF

					BEGIN TRANSACTION //CHAMADO: T.I FERNANDO SIGOLI 10/02/2020                     

					IF Empty(cErro) 

						//Executa a Stored Procedure
						//TcSQLExec('EXEC [LNKMIMS].[SMART].[dbo].[FI_EXPECARG_01] ' +Str(Val(cSeq)) )  // sigoli 13/02/2017
						TcSQLExec('EXEC ['+cLnkSrv+'].[SMART].[dbo].[FI_EXPECARG_01] ' +Str(Val(cSeq))+","+"'"+cEmpAnt+"'")
						cErro := ""
						cErro := U_RetErroED() 

					ENDIF

					If Empty(cErro)
						// Flag pedido	   
						CCSP_001F (cData,cRoteiro,cPlaca,"3","OK")
						lCargaOk := .T.
					Else
						DisarmTransaction() //CHAMADO: T.I FERNANDO SIGOLI 10/02/2020
						// Flag pedido	   
						cMens += "- Roteiro não processado: [" + AllTrim(aLstPED[ni][2]) + "]" + CRLF + "- Erro : [" + cErro + "]"  + CRLF			

						IF lCargaOk == .F.

							CCSP_001F (cData,cRoteiro,cPlaca,"4",cErro)							

						ENDIF	

					Endif								
					
					END TRANSACTION //CHAMADO: T.I FERNANDO SIGOLI 10/02/2020  					  

				EndIf	        
			Endif

			//envio carga edata
			u_GrLogZBE(Date(),TIME(),cUserName,"INTEGRACAO CARGA EDATA","LOGISTICA","CCS_001P",;
			" CHAVE "+AllTrim(Dtos(aLstPED[ni][1]))+" "+AllTrim(aLstPED[ni][2])+" "+AllTrim(aLstPED[ni][3])+" "+AllTrim(aLstPED[ni][4]),ComputerName(),LogUserName()) 


		Next ni

		If !Empty(cMens)
			cMens := "Lista de itens que não foram processados : " + CRLF + cMens
			U_ExTelaMen(cRotDesc,cMens,"Arial",10,,.F.,.T.)
		Endif

		UnLockByName("CCS_001P")
	endif

	If oTela # Nil
		oTela:SetFocus()
	Endif

Return lRet

Static Function fEnceCarg(lCargaOk)

	//Inicio. Chamado: 049906  Fernando Sigoli 24/06/2019
	cQry := " SELECT IE_PEDIVEND, "
	cQry += "        ID_CARGEXPE, "
	cQry += "        GN_PLACVEICTRAN, "
	cQry += "        ROTEIRO, " 
	cQry += "        DT_ENTRPEDIVEND "
	cQry += "   FROM ["+cLnkSrv+"].[SMART].[dbo].[VW_ERRO_03] "
	cQry += "   WHERE FL_STATCARGEXPE   <> 'FE' "
	cQry += "   AND GN_PLACVEICTRAN = " + "'" + ALLTRIM(cPlaca) + "'"

	dbUseArea( .T., "TOPCONN", TCGenQry( ,, cQry ), "TRF", .F., .T. )             

	While TRF->(!EOF())

		IF TRF->ID_CARGEXPE > 0 //so retorna erro se tiver informacao da carga na tabela do edata

			cErro += "Carga não enviada, carga: " + cvaltochar(TRF->ID_CARGEXPE) + " nao encerrada no EDATA para este veiculo " +ALLTRIM(cPlaca)+ ", favor verificar!!! " + CRLF  //Chamado: 049906  Fernando Sigoli 27/06/2019	

			IF VAL(AllTrim(aLstPED[ni][7])) == TRF->ID_CARGEXPE .OR. ;
			AllTrim(aLstPED[ni][7])      == ''

				lCargaOk := .T.  

			ENDIF	    
		ENDIF
	TRF->(dbSkip())
	ENDDO
	TRF->(dbCloseArea())	
	
	//Fim. Chamado: 049906  Fernando Sigoli 24/06/2019
return


Static Function fExistCarg(lCargaOk)
	// * INICIO VERIFICACAO SE A CARGA JA FOI ENVIADA PARA O  EDATA - WILLIAM COSTA *//
	// ** INICIO VERIFICACAO SE A CARGA FOI DELETADA NO EDATA - WILLIAM COSTA ** //

	cQuery := " SELECT IE_PEDIVEND, "
	cQuery += "        ID_CARGEXPE, "
	cQuery += "        GN_PLACVEICTRAN, "
	cQuery += "        ROTEIRO, " 
	cQuery += "        DT_ENTRPEDIVEND "
	cQuery += "   FROM ["+cLnkSrv+"].[SMART].[dbo].[VW_ERRO_02] "
	cQuery += "  WHERE ROTEIRO         = " + "'" + ALLTRIM(cRoteiro) + "'"
	cQuery += "    AND DT_ENTRPEDIVEND = " + "'" + ALLTRIM(cData)    + "'"

	dbUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )             

	While TRB->(!EOF())

		IF TRB->ID_CARGEXPE > 0 //so retorna erro se tiver informacao da carga na tabela do edata

			cErro += "Carga não enviada para o EDATA, j?existe a carga no Edata, favor estornar antes de enviar novamente, favor verificar!!! " + CRLF

			IF VAL(AllTrim(aLstPED[ni][7])) == TRB->ID_CARGEXPE .OR. ;
			AllTrim(aLstPED[ni][7])      == ''

				lCargaOk := .T.  

			ENDIF	    
		ENDIF
		TRB->(dbSkip())
	ENDDO
	TRB->(dbCloseArea())	
	// ** FINAL VERIFICACAO SE A CARGA FOI DELETADA NO EDATA - WILLIAM COSTA ** //

return

/*/{Protheus.doc} User Function CCS_001E
	Rotina de estorno processamento de registros selecionados
	@type  Function
	@author Pablo Gollan Carreras
	@since 14/06/2012
	
/*/

Static Function CCS_001E(oTela)

	Local lRet				:= .T.
	Local aArea				:= {}
	Local ni				:= 0
	Local cChave		  	:= ""
	Local cMens				:= ""
	Local cRest01			:= ""
	Local cQuery            := "" 

	// @history ticket 63303   - Leonardo P. Monteiro - 08/11/2021 - Melhoria na validação do estorno de cargas para não permitir a exclusão de cargas que já tenham pallets vinculados ao mesmo.
	If !LockByName("CCS_001E", .T., .F.) .AND. lVldEnv
	    u_GrLogZBE(Date(),TIME(),cUserName,"Lockbyname executado para a rotina CCS_001E.","SIGAFAT","CCS_001E",;
			    "Rotina já iniciada por outro usuário através da função CCS_001E. ",ComputerName(),LogUserName())
        
        MsgInfo("Rotina sendo executada por outro usuário! Aguarde o término da execução.", "..:: Em execução ::.. ")
    else

		PARAMTYPE 0	VAR oTela	AS Object	OPTIONAL	DEFAULT Nil

		If Empty(aLstPED) .OR. ValType(aLstPED) # "A"
			Return !lRet
		Endif

		//Montar a lista de contabilizacao  
		
		cSeq	 := ""

		For ni := 1 to Len(aLstPED)                   

			If !(aLstPED[ni][8] $ "3" )
				cMens += "- Roteiro não pode ser estornado pois ainda não foi processado: [" + AllTrim(aLstPED[ni][2]) + "]" + CRLF
			
			// @history ticket 63303   - Leonardo P. Monteiro - 08/11/2021 - Melhoria na validação do estorno de cargas para não permitir a exclusão de cargas que já tenham pallets vinculados ao mesmo.
			elseif fVldEst(aLstPED[ni][7])
				cMens += "- Roteiro não pode ser estornado pois existe paletes vinculados a carga: [" + AllTrim(aLstPED[ni][7]) + "]."+Chr(13)+Chr(10)+" Solicite ao setor de Expedição que estorne as cargas vinculadas." + CRLF
			elseif fVldLei(aLstPED[ni][7])
				cMens += "- Desmarcar no eData a leitura da observação da carga número [" + AllTrim(aLstPED[ni][7]) + "]."+Chr(13)+Chr(10)+" Solicite ao setor de Expedição que retire o registro de leitura." + CRLF
			elseif fVldlPe(aLstPED[ni][7])
				cMens += "- Desmarcar no eData a leitura da observação do pedido contido na carga número [" + AllTrim(aLstPED[ni][7]) + "]."+Chr(13)+Chr(10)+" Solicite ao setor de Expedição que retire o registro de leitura do pedido de venda." + CRLF
			Else

				If cSeq <> AllTrim(aLstPED[ni][7])

					//Salva Roteiro em processamento
					cData	 := AllTrim(Dtos(aLstPED[ni][1]))
					cRoteiro := AllTrim(aLstPED[ni][2])
					cPlaca	 := AllTrim(aLstPED[ni][3])
					cSeq	 := AllTrim(aLstPED[ni][7])

					BEGIN TRANSACTION //CHAMADO: T.I FERNANDO SIGOLI 10/02/2020  
					//Executa a Stored Procedure
					//TcSQLExec('EXEC [LNKMIMS].[SMART].[dbo].[FD_EXPECARG_01] ' +Str(Val(cSeq)) )  // Chamado : 034776 sigoli 19/04/2017
					TcSQLExec('EXEC ['+cLnkSrv+'].[SMART].[dbo].[FD_EXPECARG_01] ' +Str(Val(cSeq))+","+"'"+cEmpAnt+"'") 
					cErro := ""
					cErro := U_RetErroED() 

					END TRANSACTION //CHAMADO: T.I FERNANDO SIGOLI 10/02/2020  	

					// ** INICIO VERIFICACAO SE A CARGA FOI DELETADA NO EDATA - WILLIAM COSTA ** //

					cQuery := " SELECT COUNT(*) AS TOTAL"
					cQuery +=   " FROM ["+cLnkSrv+"].[SMART].[dbo].[VW_ERRO_02] "
					cQuery +=  " WHERE ROTEIRO         = " + "'" + ALLTRIM(cRoteiro) + "'"
					cQuery +=    " AND DT_ENTRPEDIVEND = " + "'" + ALLTRIM(cData)    + "'"

					dbUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )             

					While TRB->(!EOF())

						IF TRB->TOTAL > 0 //so retorna erro se tiver informacao da carga na tabela do edata

							cErro += "Carga não estorna do EDATA, favor verificar!!! (LIGUE PARA O SUPORTE EDATA) "

						Endif
						TRB->(dbSkip())
					ENDDO
					TRB->(dbCloseArea())	

					// ** FINAL VERIFICACAO SE A CARGA FOI DELETADA NO EDATA - WILLIAM COSTA ** //				

					If Empty(cErro)

						// Flag pedido	   
						CCSP_001F (cData,cRoteiro,cPlaca,"2","OK")

					Else

						// Flag pedido	   
						cMens += "- Roteiro não estornado: [" + AllTrim(aLstPED[ni][2]) + "]" + CRLF + "- Erro : [" + cErro + "]"  + CRLF			
						//CCSP_001F (cData,cRoteiro,cPlaca,"4",cErro)							

					Endif
				EndIf	        
			Endif

			u_GrLogZBE(Date(),TIME(),cUserName,"ESTORNO CARGA EDATA","LOGISTICA","CCS_001E",;
			" CHAVE "+AllTrim(Dtos(aLstPED[ni][1]))+" "+AllTrim(aLstPED[ni][2])+" "+AllTrim(aLstPED[ni][3])+" "+AllTrim(aLstPED[ni][4]),ComputerName(),LogUserName()) 

		Next ni

		If !Empty(cMens)
			cMens := "Lista de itens que não foram processados : " + CRLF + cMens
			U_ExTelaMen(cRotDesc,cMens,"Arial",10,,.F.,.T.)
		Endif

		If oTela # Nil
			oTela:SetFocus()
		Endif
		
		UnLockByName("CCS_001E")	
	endif

Return lRet

Static Function fVldEst(cSeqCarg)
	Local lRet := .F.

	cQuery := " SELECT COUNT(*) CONTADOR "
  	cQuery += " FROM ["+ cLnkSrv +"].[SMART].[dbo].[EXPEDICAO_CARGA_PALETE] "
	cQuery += " WHERE [ID_CARGEXPE] = '"+ Alltrim(cSeqCarg) +"'; "

	TCQUERY cQuery ALIAS "TRB" NEW

	While TRB->(!EOF())

		IF TRB->CONTADOR > 0
			lRet := .T.
		ENDIF
		TRB->(dbSkip())
	ENDDO

	TRB->(dbCloseArea())	
	
return lRet

Static Function fVldLei(cSeqCarg)
	Local lRet := .F.

	cQuery := " SELECT COUNT(*) CONTADOR "
  	cQuery += " FROM ["+ cLnkSrv +"].[SMART].[dbo].[EXPEDICAO_CARGA_LEIT_OBSE] "
	cQuery += " WHERE [ID_CARGEXPE] = '"+ Alltrim(cSeqCarg) +"'; "

	TCQUERY cQuery ALIAS "TRB" NEW

	While TRB->(!EOF())

		IF TRB->CONTADOR > 0
			lRet := .T.
		ENDIF
		TRB->(dbSkip())
	ENDDO

	TRB->(dbCloseArea())	
	
return lRet

Static Function fVldlPe(cSeqCarg)
	Local lRet := .F.

	cQuery := " SELECT COUNT(*) CONTADOR "
  	cQuery += " FROM ["+ cLnkSrv +"].[SMART].[dbo].[PEDIDO_VENDA_LEIT_OBSE_EXPE] "
	cQuery += " WHERE [ID_CARGEXPE] = '"+ Alltrim(cSeqCarg) +"'; "

	TCQUERY cQuery ALIAS "TRB" NEW

	While TRB->(!EOF())

		IF TRB->CONTADOR > 0
			lRet := .T.
		ENDIF
		TRB->(dbSkip())
	ENDDO

	TRB->(dbCloseArea())	
	
return lRet

/*/{Protheus.doc} User Function CCS_001T 
	Troca de Placa
	@type  Function
	@author Pablo Gollan Carreras
	@since 14/06/2012
	
/*/

Static Function CCS_001T(oTela)

	Local lRet				:= .T.
	Local aArea				:= {}
	Local ni				:= 0
	Local cChave			:= ""
	Local cMens				:= ""
	Local cRest01			:= ""
	Local cQuery            := ""

	If Empty(aLstPED) .OR. ValType(aLstPED) # "A"
		Return !lRet
	Endif

	cData	  := ""
	cRoteiro := ""
	cPlaca	  := ""
	_NewPlaca:= ""

	For ni := 1 to Len(aLstPED)                   

		If (aLstPED[ni][8] $ "3" .AND. aLstPED[ni][11] $ "1")


			If cData+cRoteiro+cPlaca <> AllTrim(Dtos(aLstPED[ni][1]))+AllTrim(aLstPED[ni][2])+AllTrim(aLstPED[ni][3])

				//Pega a placa substituta           
				
				_NewPlaca:= U_PLACASUB(AllTrim(Dtos(aLstPED[ni][1])),AllTrim(aLstPED[ni][2]),AllTrim(aLstPED[ni][3]))
				If Empty(_NewPlaca)
					U_ExTelaMen("Troca de Placa","Processo cancelado","Arial",12,,.F.,.T.)
					Return !lRet
				EndIf

				//Salva Roteiro em processamento
				cData	 := AllTrim(Dtos(aLstPED[ni][1]))
				cRoteiro := AllTrim(aLstPED[ni][2])
				cPlaca	 := AllTrim(aLstPED[ni][3])
				cSeq	 := AllTrim(aLstPED[ni][7])

				BEGIN TRANSACTION //CHAMADO: T.I FERNANDO SIGOLI 10/02/2020  

				//Executa a Stored Procedure de estorno
				//TcSQLExec('EXEC [LNKMIMS].[SMART].[dbo].[FD_EXPECARG_01] ' +Str(Val(cSeq)) ) // Chamado : 034776 sigoli 19/04/2017
				TcSQLExec('EXEC ['+cLnkSrv+'].[SMART].[dbo].[FD_EXPECARG_01] ' +Str(Val(cSeq))+","+"'"+cEmpAnt+"'") 
				cErro := ""
				cErro := U_RetErroED()

				END TRANSACTION //CHAMADO: T.I FERNANDO SIGOLI 10/02/2020  

				// ** INICIO VERIFICACAO SE A CARGA FOI DELETADA NO EDATA - WILLIAM COSTA ** //

				cQuery := " SELECT COUNT(*) AS TOTAL"
				cQuery +=   " FROM ["+cLnkSrv+"].[SMART].[dbo].[VW_ERRO_02] "
				cQuery +=  " WHERE ROTEIRO         = " + "'" + ALLTRIM(cRoteiro) + "'"
				cQuery +=    " AND DT_ENTRPEDIVEND = " + "'" + ALLTRIM(cData)    + "'"

				dbUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )             

				While TRB->(!EOF())

					IF TRB->TOTAL > 0 //so retorna erro se tiver informacao da carga na tabela do edata

						cErro := "Carga não estorna do EDATA, favor verificar!!! (LIGUE PARA O SUPORTE EDATA) "

					Endif
					TRB->(dbSkip())
				ENDDO
				TRB->(dbCloseArea())	

				// ** FINAL VERIFICACAO SE A CARGA FOI DELETADA NO EDATA - WILLIAM COSTA ** //

				If Empty(cErro)
					// Flag pedido	   
					CCSP_001F (cData,cRoteiro,cPlaca,"2","OK")

					//Cria nova sequencia edata - verificar
					aRet := CCSP_001S (cData,cRoteiro,cPlaca,_NewPlaca)
					If 	aRet[1]
						cSeq := aRet[2]
					Else
						cMens += "- Roteiro não processado, erro no sequenciamento do edata: [" + AllTrim(aLstPED[ni][2]) + "]" + CRLF			
						loop
					EndIf

					BEGIN TRANSACTION //CHAMADO: T.I FERNANDO SIGOLI 10/02/2020  

					//Executa a Stored Procedure de envio
					//TcSQLExec('EXEC [LNKMIMS].[SMART].[dbo].[FI_EXPECARG_01] ' +Str(Val(cSeq)) )  // sigoli 13/02/2017
					TcSQLExec('EXEC ['+cLnkSrv+'].[SMART].[dbo].[FI_EXPECARG_01] ' +Str(Val(cSeq))+","+"'"+cEmpAnt+"'")
					cErro := ""
					cErro := U_RetErroED()

					END TRANSACTION //CHAMADO: T.I FERNANDO SIGOLI 10/02/2020   

					// ** INICIO VERIFICACAO SE A CARGA FOI DELETADA NO EDATA - WILLIAM COSTA ** //

					cQuery := " SELECT COUNT(*) AS TOTAL"
					cQuery +=   " FROM ["+cLnkSrv+"].[SMART].[dbo].[VW_ERRO_02] "
					cQuery +=  " WHERE ROTEIRO         = " + "'" + ALLTRIM(cRoteiro) + "'"
					cQuery +=    " AND DT_ENTRPEDIVEND = " + "'" + ALLTRIM(cData)    + "'"

					dbUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )             

					While TRB->(!EOF())

						IF TRB->TOTAL > 0 //so retorna erro se tiver informacao da carga na tabela do edata

							cErro := "Carga não enviada para o EDATA, j?existe a carga no Edata, favor estornar antes de enviar novamente, favor verificar!!! "

						Endif
						TRB->(dbSkip())
					ENDDO
					TRB->(dbCloseArea())	

					// ** FINAL VERIFICACAO SE A CARGA FOI DELETADA NO EDATA - WILLIAM COSTA ** //

					If Empty(cErro)
						// Flag pedido	   
						CCSP_001F (cData,cRoteiro,cPlaca,"3","OK")
					Else

						// Flag pedido	   
						cMens += "- Roteiro de troca de placa não processado: [" + AllTrim(aLstPED[ni][2]) + "]" + CRLF + "- Erro : [" + cErro + "]"  + CRLF			
						CCSP_001F (cData,cRoteiro,cPlaca,"4",cErro)							
					Endif								
				Else

					// Flag pedido	   
					cMens += "- Roteiro de troca de placa não estornado: [" + AllTrim(aLstPED[ni][2]) + "]" + CRLF + "- Erro : [" + cErro + "]"  + CRLF			
				Endif
			EndIf

			u_GrLogZBE(Date(),TIME(),cUserName,"TROCA DE PLACA - EDATA","LOGISTICA","CCS_001T",;
			" CHAVE "+AllTrim(Dtos(aLstPED[ni][1]))+" "+AllTrim(aLstPED[ni][2])+" "+AllTrim(aLstPED[ni][3])+" "+AllTrim(aLstPED[ni][4]),ComputerName(),LogUserName()) 
			
			//Everson - 02/04/2018. Chamado 037261.
			If FindFunction("U_ADVEN050P") .And. cEmpAnt == "01" .And. cFilAnt == "02"
				If Upper(Alltrim(cValToChar(GetMv("MV_#SFATUL")))) == "S"
					U_ADVEN050P("",,," AND C5_ROTEIRO = '" + Alltrim(cValToChar(aLstPED[ni][2])) + "' AND C5_DTENTR = '" + Alltrim(DToS(aLstPED[ni][1])) + "' AND C5_XPEDSAL <> '' ",,,,,,.T.)
				
				EndIf
			EndIf

		Else
			cMens += "- Opção disponpivel apenas para roteiros integrados do tipo Fat.Antecipado: [" + AllTrim(aLstPED[ni][2]) + "]" + CRLF		        
		Endif

	Next ni

	If !Empty(cMens)
		cMens := "Lista de itens que não foram processados : " + CRLF + cMens
		U_ExTelaMen(cRotDesc,cMens,"Arial",10,,.F.,.T.)
	Endif

	If oTela # Nil
		oTela:SetFocus()
	Endif

Return lRet

/*/{Protheus.doc} User Function PFATA2VlP
	Rotina para validacao do SX1 da rotina
	@type  Function
	@author Pablo Gollan Carreras
	@since 14/06/2012
	
/*/

Static Function PFATA2VlP(cPerg,aPergunte)

	Local lRet				:= .T.
	Local ni				:= 0

	//Gravar variaveis no grupo de perguntas do SX1
	__SaveParam(cPerg,@aPergunte)	
	//Reinicializar as perguntas
	ResetMVRange()
	For ni := 1 to Len(aPergunte)
		//Inicializar as perguntas c/ array caso existam diferencas, para as validacoes
		Do Case
			Case AllTrim(aPergunte[ni][POS_X1OBJ]) == "C"
			aPergunte[ni][POS_X1VAL] := &(aPergunte[ni][POS_X1VAR])
			Otherwise
			&(aPergunte[ni][POS_X1VAR]) := aPergunte[ni][POS_X1VAL]
		EndCase
		//Definir a variavel corrente como sendo o parametro a validar, para aquelas validacoes que utilizar a variavel de campo posicionado
		__ReadVar := aPergunte[ni][POS_X1VAR]
		//Executar validacao
		If !Eval(&("{|| " + aPergunte[ni][POS_X1VLD] + "}"))
			MsgAlert(cNomeUs + ", inconsistência na pergunta " + StrZero(ni,2) + " (" + StrTran(AllTrim(Capital(aPergunte[ni][POS_X1DES])),"?","") + ")")
			Return !lRet
		Endif
	Next ni                               

Return lRet

/*/{Protheus.doc} User Function PFAT2Val
	Rotina que atribui dinamicamente a validacao de cada pergunta
	@type  Function
	@author Pablo Gollan Carreras
	@since 14/06/2012
	
/*/

User Function CCSPVal()

	Local lRet				:= .T.
	Local cVarAt			:= Upper(AllTrim(ReadVar()))
	Local nPos				:= 0
	Local aLstVld			:= {	{1,{|| Vazio() }},;
	{3,{|| Empty(StrTran(Upper(&(cVarAt)),"Z","")) }},;
	{5,{|| NaoVazio()}},;
	{6,{|| NaoVazio()}},;
	{7,{|| cValToChar(&(cVarAt)) $ "12345"}}}
	Local bConvNum			:= {|x| x := GetDToVal(x)}

	U_ADINF009P('CCSP_001' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Integracao Protheus x Edata')

	If "MV_PAR" $ cVarAt
		If !Empty(nPos := aScan(aLstVld,{|x| x[1] == Eval(bConvNum,Right(cVarAt,2))}))
			lRet := Eval(aTail(aLstVld[nPos]))
		Endif
	Endif

Return lRet

/*/{Protheus.doc} User Function CCSP_001F
	Rotina que atribui dinamicamente a validacao de cada pergunta
	@type  Function
	@author Pablo Gollan Carreras
	@since 11/19/13
	
/*/

Static Function CCSP_001F (cData,cRoteiro,cPlaca,cFlag,cObs)

	DbSelectArea("SC5")
	DBORDERNICKNAME("SC5_9")
	DbSeek(xFilial("SC5")+cData+cRoteiro+cPlaca)
	WHile !EOF() .and. xFilial("SC5") + cData+cRoteiro+cPlaca == SC5->C5_FILIAL+DTOS(SC5->C5_DTENTR)+SC5->C5_ROTEIRO+SC5->C5_PLACA

		_lLib:=.T.
		
		//Mauricio 08/01/16 - Novo tratamento para liberacao a integração.
		SC6->(dbSetOrder(1)) // Indice ( pedido )
		SC6->(dbSeek(SC5->(C5_FILIAL+C5_NUM)))
		While !SC6->(Eof()) .and. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)

			SC9->(dbSetOrder(1)) // Indice ( pedido )
			If SC9->(dbSeek( SC6->(C6_FILIAL+C6_NUM+C6_ITEM)))
				IF SC6->C6_PRODUTO == SC9->C9_PRODUTO	//confiro se o produto eh o mesmo.
					If !Empty(SC9->C9_BLEST ) .OR. !Empty(SC9->C9_BLCRED) 
						//!Empty(SC9->C9_BLEST ) .AND. !Empty(SC9->C9_BLCRED) -- alterado para OR para considerar quaisquer bloqueio chamado 032206 por Adriana em 03/01/2017
						_lLib := .F.
						cErro += "Ola " + cNomeUs + ", Existe Produto nesse Pedido que não está liberado credito ou Estoque Verifique com o Financeiro, Pedido: " + SC5->C5_NUM + CHR(13) + CHR(10)

					Endif
				Else
					_lLib := .F.
					cErro += "Ola " + cNomeUs + ", Existe Produto nesse Pedido que não está liberado credito ou Estoque Verifique com o Financeiro, Pedido: " + SC5->C5_NUM + CHR(13) + CHR(10)

				Endif
			Else
				_lLib := .F.
				cErro += "Ola " + cNomeUs + ", Existe Produto nesse Pedido que não está liberado credito ou Estoque Verifique com o Financeiro, Pedido: " + SC5->C5_NUM + CHR(13) + CHR(10)
			Endif
			SC6->(dbSkip())
		EndDo

		If _lLib

			RecLock("SC5",.F.)

				SC5->C5_XOBS	:= cObs
				SC5->C5_XINT	:= cFlag 
				SC5->C5_XERRO   := SC5->C5_XERRO+"// "+cFlag+" - "+DTOC(Ddatabase)+" "+Time()+" por "+Alltrim(cusername)+" // "+cObs //incluido por Adriana em 23/04/15 para gravar log completo

				//If IsInCallStack("CCS_001E") // @history ticket 9122    - Fernando Maciei - 09/02/2021 - melhoria no envio Carga EDATA
				If IsInCallStack("CCS_001E") .or. AllTrim(cFlag) == "4" // @history ticket 9122    - Fernando Maciei - 09/02/2021 - melhoria no envio Carga EDATA
					SC5->C5_X_SQED	:= ""
				EndIf

				If SC5->C5_XFATANT=="1"

					If IsInCallStack("CCS_001P") .and. cFlag=="3"
						SC5->C5_XFLAGE	:= "2"                   
					ElseIf IsInCallStack("CCS_001P")
						SC5->C5_XFLAGE	:= "1"                   			
					EndIf                                               

				EndIf

			SC5->(MsUnlock()) 

		EndIf	 

		DbSelectArea("SC5")
		DbSkip()
	EndDo                    

	//GRAVA LOG
	If cFlag $ "2|3"
		RecLock("ZZ6",.T.)
		ZZ6->ZZ6_FILIAL := XFILIAL("ZZ6")
		ZZ6->ZZ6_CHAVE  := cData+cRoteiro+cPlaca
		ZZ6->ZZ6_DATA 	:= DDATABASE
		ZZ6->ZZ6_HORA 	:= TIME()
		ZZ6->ZZ6_USER 	:= cUserName
		ZZ6->ZZ6_OPER 	:= cFlag
		ZZ6->ZZ6_OBS 	:= cObs
		ZZ6->(MsUnlock())	 
	EndIf

Return

/*/{Protheus.doc} User Function CCSP_001S
	@type  Function
	@author Pablo Gollan Carreras
	@since 11/19/13
	
/*/

Static Function CCSP_001S (cData,cRoteiro,cPlaca,cNewPlaca)

	Local lRet:=.F.
	Default cNewPlaca:=""

	BEGIN TRANSACTION//CHAMADO: T.I FERNANDO SIGOLI 10/02/2020  

	_cSQED:= U_NextNum("SC5","C5_X_SQED",.F.)

	DbSelectArea("SC5")
	DBORDERNICKNAME("SC5_9")
	If DbSeek(xFilial("SC5")+cData+cRoteiro+cPlaca)
		While !EOF() .and. xFilial("SC5")+cData+cRoteiro+cPlaca == SC5->C5_FILIAL+DTOS(SC5->C5_DTENTR)+SC5->C5_ROTEIRO+SC5->C5_PLACA

			_lLib:=.T.
			
			//Mauricio 08/01/16 - Novo tratamento para liberacao a integração.
			SC6->(dbSetOrder(1)) // Indice ( pedido )
			SC6->(dbSeek(SC5->(C5_FILIAL+C5_NUM)))
			While !SC6->(Eof()) .and. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)

				SC9->(dbSetOrder(1)) // Indice ( pedido )
				If SC9->(dbSeek( SC6->(C6_FILIAL+C6_NUM+C6_ITEM)))
					IF SC6->C6_PRODUTO == SC9->C9_PRODUTO	//confiro se o produto eh o mesmo.
						If !Empty(SC9->C9_BLEST ) .OR. !Empty(SC9->C9_BLCRED) 
							//!Empty(SC9->C9_BLEST ) .AND. !Empty(SC9->C9_BLCRED) -- alterado para OR para considerar quaisquer bloqueio chamado 032206 por Adriana em 03/01/2017
							_lLib := .F.
							cErro += "Ola " + cNomeUs + ", Existe Produto nesse Pedido que não está liberado credito ou Estoque Verifique com o Financeiro, Pedido: " + SC5->C5_NUM + CHR(13) + CHR(10)
						Endif
					Else
						_lLib := .F.
						cErro += "Ola " + cNomeUs + ", Existe Produto nesse Pedido que não está liberado credito ou Estoque Verifique com o Financeiro, Pedido: " + SC5->C5_NUM + CHR(13) + CHR(10)
					Endif
				Else
					_lLib := .F.
					cErro += "Ola " + cNomeUs + ", Existe Produto nesse Pedido que não está liberado credito ou Estoque Verifique com o Financeiro, Pedido: " + SC5->C5_NUM + CHR(13) + CHR(10)
				Endif
				SC6->(dbSkip())
			EndDo	

			If _lLib
				RecLock("SC5",.F.)
				SC5->C5_X_SQED	:= _cSQED
				SC5->C5_X_DATA	:= DDATABASE
				SC5->C5_XPLACAS	:= cNewPlaca
				SC5->(MsUnlock())			 
				lRet:=.T.
			EndIf

			DbSelectArea("SC5")			
			DbSkip()
		EndDo
	EndIf

	END TRANSACTION //CHAMADO: T.I FERNANDO SIGOLI 10/02/2020  

Return {lRet,_cSQED}       

/*/{Protheus.doc} User Function CCSP_001
	@type  Function
	@author Pablo Gollan Carreras
	@since 12/02/13
	
/*/

Static Function CCS_001L(oTela)

	Local lRet	:=.T.
	Local cMens :=""
	Local cMens1:=""  
	Local ni

	If Empty(aLstPED) .OR. ValType(aLstPED) # "A"
		Return !lRet
	Endif

	//Montar a lista de contabilizacao  
	
	cData	 := ""
	cRoteiro := ""
	cPlaca	 := ""

	For ni := 1 to Len(aLstPED)                   

		If (aLstPED[ni][8] $ "1| " )
			cMens += "- Roteiro sem Log [" + AllTrim(aLstPED[ni][2]) + "]" + CRLF
		Else

			If cData+cRoteiro+cPlaca <> AllTrim(Dtos(aLstPED[ni][1]))+AllTrim(aLstPED[ni][2])+AllTrim(aLstPED[ni][3])

				//Salva Roteiro em processamento
				cData	 := AllTrim(Dtos(aLstPED[ni][1]))
				cRoteiro := AllTrim(aLstPED[ni][2])
				cPlaca	 := AllTrim(aLstPED[ni][3])

				ZZ6->(dbSetOrder(1)) // Indice ( pedido )
				If ZZ6->(dbSeek(xFilial("ZZ6")+cData+cRoteiro+cPlaca))
					While !ZZ6->(Eof()) .and. Alltrim(ZZ6->(ZZ6_FILIAL+ZZ6_CHAVE)) == Alltrim(xFilial("ZZ6")+cData+cRoteiro+cPlaca)

						cMens  := "Chave	 : " + ZZ6->ZZ6_CHAVE + CRLF
						cMens  += "Data 	 : " + DTOC(ZZ6->ZZ6_DATA) + CRLF
						cMens  += "Hora 	 : " + ZZ6->ZZ6_HORA + CRLF
						cMens  += "Usuário   : " + ZZ6->ZZ6_USER + CRLF
						cMens  += "Operação  : " + IIF(ZZ6->ZZ6_OPER == "2","Estorno","Envio") + CRLF + CRLF

						cMens1 := cMens1 + cMens + CRLF

						ZZ6->(dbSkip())
					EndDo
				EndIf	
			EndIf	        
		Endif

	Next ni

	If !Empty(cMens1)
		U_ExTelaMen(cRotDesc,cMens1,"Arial",10,,.F.,.T.)
	Endif

	If oTela # Nil
		oTela:SetFocus()
	Endif


Return lRet 

Static Function AjustaSX1(cPerg)

	Local aMensHlp			:= Array(nQtdePerg)
	Local cRotVld			:= ""
	Local aOpc				:= Array(2,5)
	Local ni				:= 0

	For ni := 1 to Len(aOpc)
		aFill(aOpc[ni],"")
	Next ni

	aOpc[2][1] := "Pendente"
	aOpc[2][2] := "Estornado"
	aOpc[2][3] := "Integrado"
	aOpc[2][4] := "Erro"
	aOpc[2][5] := "Todos"

	//				PERGUNTA					TIPO	TAM							DEC	OBJETO	PS	COMBO		SXG		F3		VALID				HELP
	aMensHlp[01] := {"Roteiro de?"				,"C"	,TamSX3("C5_ROTEIRO")[1]	,00	,"G"	,0	,aOpc[1]	,"001"	,""		,cRotVld	,"Informe o ROTEIRO inicial do intervalo"}
	aMensHlp[02] := {"Roteiro ate?"				,"C"	,TamSX3("C5_ROTEIRO")[1]	,00	,"G"	,0	,aOpc[1]	,"002"	,""		,cRotVld	,"Informe o ROTEIRO final do intervalo"}
	aMensHlp[03] := {"Placa de ?"				,"C"	,TamSX3("C5_PLACA")[1]		,00	,"G"	,0	,aOpc[1]	,"001"	,""		,cRotVld	,"Informe a PLACA inicial do intervalo"}
	aMensHlp[04] := {"Placa ate?"				,"C"	,TamSX3("C5_PLACA")[1]		,00	,"G"	,0	,aOpc[1]	,"002"	,""		,cRotVld	,"Informe a PLACA final do intervalo"}
	aMensHlp[05] := {"Entrega de?"				,"D"	,008						,00	,"G"	,0	,aOpc[1]	,""		,""		,cRotVld	,"Informe a data inicial de entrega."}
	aMensHlp[06] := {"Entrega ate?"				,"D"	,008						,00	,"G"	,0	,aOpc[1]	,""		,""		,cRotVld	,"Informe a data final de entrega."}
	aMensHlp[07] := {"Status?"					,"N"	,001						,00	,"C"	,1	,aOpc[2]	,""		,""		,cRotVld	,"Informe as opções para o filtro."}

	U_GravaSX1(cPerg,aMensHlp)

Return Nil


//Mauricio - 26/05/2017 - chamado 35017 - Roteiro Pedido "diversos"  
Static Function fchkped(_cNrPd,_cCli,c_Fil)
	
	If Select("TDIV") > 0
		dbSelectArea("TDIV")
		DbCLoseArea("TDIV")
	EndIf 

	//Select para  trazer apenas pedidos diversos da lista
	_cQuery := "SELECT C5_NUM, C5_DTENTR, C5_ROTEIRO FROM "+RetSqlName("SC5")+" C5 WITH(NOLOCK), "+RetSqlName("SC6")+" C6 WITH(NOLOCK), "+RetSqlName("SF4")+" F4 WITH(NOLOCK) "
	_cQuery += "WHERE C5.C5_NUM = '"+_cNrPd+"' AND C5.C5_NUM = C6.C6_NUM AND " 
	_cQuery += "      C5.C5_CLIENTE = '"+_cCli+"' AND C5.C5_FILIAL = '"+c_Fil+"' AND "
	_cQuery += "      C6.C6_TES = F4.F4_CODIGO AND F4.F4_XTIPO = '2' AND "
	_cQuery += "      C5.C5_FILIAL = C6.C6_FILIAL AND "
	_cQuery += "      C6.D_E_L_E_T_ <> '*' AND F4.D_E_L_E_T_ <> '*' AND C5.D_E_L_E_T_ <> '*' "
	_cQuery += "      GROUP BY C5.C5_DTENTR, C5.C5_ROTEIRO, C5.C5_NUM "
	//_cQuery += "ORDER BY C5.C5_NUM,C5.C5_ROTEIRO"
	_cQuery += "ORDER BY C5.C5_DTENTR, C5.C5_ROTEIRO, C5.C5_NUM "

	TCQUERY _cQuery NEW ALIAS "TDIV"

	dbSelectArea("TDIV")
	dbGoTop()

	While TDIV->(!Eof())
		AADD(_aPedDiv,{TDIV->C5_DTENTR,TDIV->C5_ROTEIRO,TDIV->C5_NUM})     
		TDIV->(DbSkip())
	Enddo

	DbCloseArea("TDIV")

Return()

STATIC FUNCTION SqlVerifRoteiro(cDtEntr,cRoteiro)

	BeginSQL Alias "TDIX"
		%NoPARSER% 

		SELECT COUNT(*) AS CONT_PED,
		CASE WHEN C5_XTIPO = '1' THEN COUNT(*) ELSE 0 END AS CONT_NORMAL,
		CASE WHEN C5_XTIPO = '2' THEN COUNT(*) ELSE 0 END AS CONT_DIVERSOS    //Chamado: T.I - Fernando Sigoli - 01/07/2019
		FROM %Table:SC5%  WITH(NOLOCK)
		WHERE C5_FILIAL = %EXP:cFilia%		 //Chamado: 048868 - 02/05/2019 - FERNANDO SIGOLI
		AND C5_DTENTR   = %EXP:cDtEntr%     
		AND C5_ROTEIRO  = %EXP:cRoteiro%
		AND D_E_L_E_T_ <> '*'
		AND C5_NOTA     = ''                //Chamado: T.I - Fernando Sigoli - 01/07/2019
		GROUP BY C5_ROTEIRO,C5_DTENTR,C5_XTIPO

	EndSQl   

RETURN(NIL)

STATIC FUNCTION SqlVerifDiversos(cDtEntr,cRoteiro)

	BeginSQL Alias "TDIZ"
		%NoPARSER% 

		SELECT C5_NUM,C5_XTIPO
		FROM %Table:SC5%  WITH(NOLOCK)
		WHERE C5_FILIAL = %EXP:cFilia% //Chamado: 048868 - 02/05/2019 - FERNANDO SIGOLI
		AND C5_DTENTR   = %EXP:cDtEntr% 
		AND C5_ROTEIRO  = %EXP:cRoteiro% 
		AND C5_XTIPO    = '2'
		AND C5_NOTA     = ''           //Chamado: T.I - Fernando Sigoli - 01/07/2019
		AND D_E_L_E_T_ <> '*'

	EndSQl   

RETURN(NIL)

STATIC FUNCTION SqlVerifProdutos(cDtEntr,cRoteiro)

	BeginSQL Alias "TDJA"
		%NoPARSER% 
		
	    SELECT 
	    	C6_NUM,C6_PRODUTO,IE_MATEEMBA
		FROM %Table:SC6% SC6  WITH(NOLOCK)
		LEFT JOIN [LNKMIMS].[SMART].[dbo].[VW_MATERIAL_EMBALAGEM]
		ON IE_MATEEMBA    = (C6_PRODUTO COLLATE Latin1_General_CI_AS)
		INNER JOIN %Table:SC5% SC5 WITH(NOLOCK) ON SC5.C5_FILIAL = SC6.C6_FILIAL AND SC5.C5_NUM = SC6.C6_NUM  //Chamado: 051387 - Fernando Sigoli - 29/08/2019  
		AND SC5.C5_CLIENTE = SC6.C6_CLI AND SC5.C5_LOJACLI = SC6.C6_LOJA
		WHERE 
		  C6_FILIAL  = %EXP:cFilia% //Chamado: 048868 - 02/05/2019 - FERNANDO SIGOLI
		  AND C6_ENTREG   = %EXP:cDtEntr%  
		  AND C5_ROTEIRO  = %EXP:cRoteiro%
		  AND C6_NOTA     =  ''
		  AND SC6.D_E_L_E_T_ <> '*'
		  AND SC5.D_E_L_E_T_ <> '*'	


	EndSQl   

RETURN(NIL)
