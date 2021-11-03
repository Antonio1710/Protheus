#INCLUDE "RWMAKE.CH"
#INCLUDE "tbiconn.CH"   
#INCLUDE "Protheus.ch"
#INCLUDE "ParmType.ch"
#INCLUDE "topconn.ch" 

STATIC cNumSC := ""

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
Static lRet             := .F. 

/*/{Protheus.doc} User Function MT121BRW
	(Adição de opções no Ações Relacionadas do Pedidos de Compra)
	@type  Function
	@author Fernando Sigoli
	@since 25/09/2017
	@version 01
	@history Chamado 034249 
	@history Chamado 050978 - FWNM                 - 08/08/19 - Altera observacao após aprovado e s/ NF.
	@history Chamado 054127 - ADRIANO SAVOINE      - 20/12/2019 - Alteração da Data de Entrega sem passar pela Alçada de aprovação.
	@history Chamado 055246 - ADRIANO SAVOINE      - 28/01/2020 - VALIDADOR DO PEDIDOS DE COMPRAS QUE CHEGAM NA PORTARIA PARA ELES VERIFICAREM SE EXISTE PEDIDO E LIBERAREM A ENTRADA.
	@history Chamado 055246 - WILLIAM COSTA        - 29/01/2020 - Alterado a chamada do relatório de impressão de MATR110() direto para a função A120Impri.
	@history ticket    3873 - Fernando Macieira    - 23/11/2020 - Projeto - Contrato e Controle de Entradas - São Carlos
	@history Chamado 6716   - ANDRE MENDES (OBIFY) - 20/01/2021 - Criando a opção de alterar a condição de pagamento no pedido de vendas
	@history Ticket TI      - Adriano Savoine      - 04/03/2021 - Alteração da Data de entrega verifica se vai alterar todos itens ou somente o posicionado.
	@history Ticket 43012   - Everson              - 04/10/2021 - Tratamento para que o usuário que incluiu o pedido e o grupo de compras do qual faz parte possa alterar a data de entrega do pedido de compra.
	@history Ticket 43012   - Everson              - 13/10/2021 - Tratamento para que o usuário que incluiu o pedido e o grupo de compras do qual faz parte possa alterar a data de entrega do pedido de compra.
	@history Ticket T.I     - Sigoli               - 21/10/2021 - Tratamento error Log - variable does not exist NOPCA on U_ALTCONPC(MT121BRW.PRW) 13/10/2021 17:25:00 line : 1542
/*/

User Function MT121BRW()

   
	If __cUserID $ GETMV("MV_#USUPCF")   &&usuarios cadastrados/liberado para inclusao de pedidos de frete
		
		aAdd(aRotina, {'GERA PEDIDO.CTE', "u_PCFRETE()", 0, 7, 0, Nil})
		
	Endif
	
	// Chamado n. 050978 || OS 052284 || TECNOLOGIA || LUIZ || 8451 || OBSERV. PEDIDO - FWNM - 08/08/2019 - Permitir alterar observacoes
		aAdd( aRotina, {'Alterar Observação', "u_AltObsPC()", 0, 7, 0, Nil} )
	//

		aAdd( aRotina, {'Alterar DT.ENTREGA', "u_AltDTPC()", 0, 7, 0, Nil} ) // Chamado: 054127 - ADRIANO SAVOINE - 20/12/2019 - Alteração da Data de Entrega sem passar pela Alçada de aprovação.

	
	If __cUserID $ GETMV("MV_#USUPORT")   //USUARIO QUE LIBERAM A ENTRADA DE PRODUTOS NO PEDIDOS DE COMPRAS PARA O RECEBIMENTO
			
			aAdd(aRotina, {'LIBERAÇÃO PORTARIA', "u_LIBPORT()", 0, 7, 0, Nil})
			
	Endif

	// Chamado n. 6716 - Andre Mendes - Alterar a condição de pagamento.
	aAdd( aRotina, {'Alterar Cond. Pagto', "u_AltConPC()", 0, 7, 0, Nil} )

Return    

//------------------------------------------------------------|
//geração do pedido de compra, em cima dos pedido selecionados|
//------------------------------------------------------------|
User Function PCFRETE()    
                       
	Local aArea				:= SaveArea1({"SC7",Alias()})
	Local oArea				:= FWLayer():New()
	Local aCoord			:= FWGetDialogSize(oMainWnd)
	Local nCoefDif			:= 1
	Local ni				:= 0
	Local nx				:= 0
	Local aLstC01			:= {" ","C7_NUM","C7_EMISSAO","C7_FORNECE","A2_NOME","C7_TOTAL"}
	Local cLine01			:= ""
	Local oOk 				:= LoadBitmap(GetResources(),"LBOK")
	Local oNo 				:= LoadBitmap(GetResources(),"LBNO")
	Local lPerg             := .T.
	 
	//Objetos graficos
	Local oTela
	Local oPainel01
	Local oPainel02
	Local oPainel03
	Local oPainelS01
	Local oBot01
	Local oBot02
	
	
	Private oGD01																						
	Private bAtGD		:= {|lAtGD,lFoco| IIf(lAtGD,(oGD01:SetArray(_aDados01),oGD01:bLine := &(cLine01),oGD01:GoTop()),.T.),;
								IIf(ValType(lFoco) == "L" .AND. lFoco,oGD01:SetFocus(),.T.)}
	Private nGet1	  	:= 0
	Private cGet2	 	:= Space(6)
	Private cGet3		:= Space(2)
	Private cGet4	 	:= Space(3)
	Private cRotNome	:= "[" + StrTran(ProcName(0),"U_","") + "]" + Space(1)
	Private cRotDesc	:= "Pedido de Compra - CTE"
	Private cNomeUs		:= Capital(AllTrim(UsrRetName(__cUserID)))
	Private oRegua
	Private aLstPED		:= {}																	
	Private aHeader01	:= {}
	Private _aDados01	:= {}
	
	Private cPerg		:= "SC7CTE01" 
	Private cFilLog     := Substr(CNUMEMP,3,2)
	Private lOk			:= .F.
	Private aPergunte   := {}
	Private aTamObj		:= Array(4)
	
	aFill(aTamObj,0)        
	
	lPerg := Pergunte(cPerg,.T.)
	                            
	If ! lPerg
	
		Return .F.
	
	EndIf
	
	//Montar a lista de campos a utilizar na GD  ?
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
	
	//Montar o codeblock para montar as listas de dados da GD  ?
	cLine01 := "{|| {"
	cLine01 += "IIf(_aDados01[oGD01:nAt,1],oOk,oNo),"
	For ni := 2 to Len(aLstC01)
		cLine01 += "_aDados01[oGD01:nAt," + cValToChar(ni) + "]" + IIf(ni < Len(aLstC01),",","")
	Next ni
	cLine01 += "}}"
	
	//Substituir o nome dos campos pelos titulos  ?
	For ni := 1 to Len(aLstC01)
		aLstC01[ni] := Posicione("SX3",2,PadR(aLstC01[ni],10),"X3Titulo()")
	Next ni
	
	
	//Interface  ?
	aCoord[3] := aCoord[3] * 0.95
	aCoord[4] := aCoord[4] * 0.95
	If U_ApRedFWL(.T.)
		nCoefDif := 0.95
	Endif
	
	CCSP001At(aClone(aHeader01),@_aDados01) 
	
	If Empty(_aDados01)
	
		MsgAlert("Ola" + cNomeUs + ", Pedidos nliberados", "Nao Existe Pedidos Liberados")
		RestArea1(aArea)
	    ProcLogAtu("FIM")
		
		Return Nil
		
	EndIf  
	
	 
		If MsgYesNo(OemToAnsi("Deseja Gerar Pedido de Frete - C.T.E"),OemToAnsi("A T E N Ç Ã O"))
			
			DEFINE MSDIALOG oTela TITLE (Capital(cRotDesc) + " " + cRotNome) FROM aCoord[1],aCoord[2] TO aCoord[3],aCoord[4] OF oMainWnd COLOR "W+/W" PIXEL
	
			oArea:Init(oTela,.F.)
			//Mapeamento da area
			oArea:AddLine("L01",100 * nCoefDif,.T.)
			//oArea:AddLine("L02",050 * nCoefDif,.T.)
			
			//-----------------------------
			//Colunas  
			//-----------------------------
			oArea:AddCollumn("L01C01",LRG_COL01,.F.,"L01")
			oArea:AddCollumn("L01C02",LRG_COL02,.F.,"L01")
			oArea:AddCollumn("L01C03",LRG_COL03,.F.,"L01")
			
			//-----------------------------
			//Paineis
			//-----------------------------
			oArea:AddWindow("L01C01","L01C01P01","Par?etros",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
			oPainel01 := oArea:GetWinPanel("L01C01","L01C01P01","L01")
			
			oArea:AddWindow("L01C02","L01C02P01","Dados adicionais",50,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
			oPainel02 := oArea:GetWinPanel("L01C02","L01C02P01","L01")
			
			oArea:AddWindow("L01C03","L01C03P01","Funcoes",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
			oPainel03 := oArea:GetWinPanel("L01C03","L01C03P01","L01")
			
			oArea:AddWindow("L01C02","L01C02P02","Itens",50,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
			oPainel04 := oArea:GetWinPanel("L01C02","L01C02P02","L01")
			
			
			aAltDet  := {"PCQTD"} 
			aHDet    := {}
			aColsDet := {}   
			
			Aadd(aHDet,{"Item"     ,"PCITE", "", 03, 0,"","" ,"C","",""})
			Aadd(aHDet,{"Codigo"   ,"PCPRD", "", 06, 0,"","" ,"C","",""})
			Aadd(aHDet,{"Produto"  ,"PCDES", "", 40, 0,"","" ,"C","",""})
			Aadd(aHDet,{"Local"    ,"PCLOC", "", 03, 0,"","" ,"C","",""})
			Aadd(aHDet,{"C.Custo"  ,"PCCUS", "", 06, 0,"","" ,"C","",""})
			Aadd(aHDet,{"Qtd"      ,"PCQTD", "@E 999,999,999"    ,11, 0,"","" ,"N","",""})
			Aadd(aHDet,{"R$ Unit"  ,"PCUNI", "@E 999,999,999.99" ,15, 2,"","" ,"N","",""})
			Aadd(aHDet,{"R$ Total" ,"PCTOT", "@E 999,999,999.99" ,15, 2,"","" ,"N","",""})
			
			                                 //l   C   FL  FC
			oDetalhe := MsNewGetDados():New(000,0000,000,000,GD_UPDATE + GD_DELETE,"Allwaystrue()","Allwaystrue()","",aAltDet,,999,"u_gatilho()",Nil,Nil,oPainel04,aHDet,@aColsDet)
			oDetalhe:oBrowse:Align 		:= CONTROL_ALIGN_ALLCLIENT
			
			//-----------------------------
			//Painel 01 - Filtros  ?
			//PERGUNTAS
			//-----------------------------
			U_DefTamObj(@aTamObj,000,000,(oPainel01:nClientHeight / 2) * 0.9,oPainel01:nClientWidth / 2)
			oPainelS01 := tPanel():New(aTamObj[1],aTamObj[2],"",oPainel01,,.F.,.F.,,CLR_WHITE,aTamObj[4],aTamObj[3],.T.,.F.)
			
			Pergunte(cPerg,.T.,,.F.,oPainelS01,,@aPergunte,.T.,.F.)
			
			//BOTAO PESQUISA
			U_DefTamObj(@aTamObj,(oPainel01:nClientHeight / 2) - nAltBot,000,(oPainel01:nClientWidth / 2),nAltBot,.T.)
			
			oBot01 := tButton():New(aTamObj[1],aTamObj[2],cHK + "Pesquisar",oPainel01,;
				{|| IIf(PFATA2VlP(cPerg,@aPergunte),;
				MsAguarde({|| CursorWait(),CCSP001At(aClone(aHeader01),@_aDados01),Eval(bAtGD,.T.,.T.),CursorArrow()},cRotNome,"Pesquisando",.F.),.F.)},;
				aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
			
			//-----------------------------
			//Painel 02 - Lista de dados  
			//-----------------------------
			
			oGD01               := TCBrowse():New(000,000,000,000,/*bLine*/,aLstC01,,oPainel02,,,,/*bChange*/,/*bLDblClick*/,/*bRClick*/,/*oFont*/,,,,,,,.T.,/*bWhen*/,,/*bValid*/,.T.,.T.)
			oGD01:bHeaderClick	:= {|oObj,nCol| CCSP001GD(2,@_aDados01,@oGD01,nCol,aClone(aHeader01)),oGD01:Refresh()}
			oGD01:blDblClick	:= {|| CCSP001GD(1,@_aDados01,@oGD01,,aClone(aHeader01)),oGD01:Refresh()}
			oGD01:Align 		:= CONTROL_ALIGN_ALLCLIENT
			Eval(bAtGD,.T.,.F.)
			
			//-----------------------------
			//Painel 03 - Funcoes  ?
			//-----------------------------
			
			//Gerar Pedido de compra
			U_DefTamObj(@aTamObj,000,000,(oPainel03:nClientWidth / 2),nAltBot,.T.)
			
			oBot01 := tButton():New(aTamObj[1],aTamObj[2],cHK + "Carregar",oPainel03,;
				{|| IIf(!Empty(aLstPED),;
				MsAguarde({|| CursorWait(),lOk := PCFORNEC(@oTela),CursorArrow(),IIf(lOk,(CCSP001At(aClone(aHeader01),@_aDados01),Eval(bAtGD,.T.,.T.)),AllwaysTrue())},;
				cRotNome,"Processando",.F.),MsgAlert(cNomeUs + ", para processar é necessáio que ao menos um registro seja selecionado!",cRotNome))},;
				aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
				
			//Sair
			U_DefTamObj(@aTamObj,aTamObj[1] + nAltBot + nDistPad)
			oBot05 := tButton():New(aTamObj[1],aTamObj[2],cHK + "Sair",oPainel03,{|| oTela:End()},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
			
			//gerar pedido
			U_DefTamObj(@aTamObj,aTamObj[1] + nAltBot + nDistPad)
			oBot06 := tButton():New(aTamObj[1],aTamObj[2],cHK + "Gerar Pedido",oPainel03,;
			{|| IIf(!Empty(aLstPED),;
			MsAguarde({|| CursorWait(),lOk := PCGERAR(@oTela),CursorArrow(),IIf(lOk,(CCSP001At(aClone(aHeader01),@_aDados01),Eval(bAtGD,.T.,.T.)),AllwaysTrue())},;
			cRotNome,"Processando",.F.),MsgAlert(cNomeUs + ", para processar é necessáio que ao menos um registro seja selecionado!",cRotNome))},;
			aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
			
			
			oTela:Activate(,,,.T.,/*valid*/,,{|| .T.})
		
	    
	    EndIF
    
Return

User Function gatilho() 
 
	If M->PCQTD > 0
	          
		oDetalhe:aCols[oDetalhe:nAt,Ascan(aHDet,{|x| AllTrim(x[2]) == "PCTOT" })] := (M->PCQTD * oDetalhe:aCols[oDetalhe:nAt,Ascan(aHDet,{|x| AllTrim(x[2]) == "PCUNI" })])
		oDetalhe:Refresh()
	
	Else         
	
		Alert('Atencao!!. Quantidade nao pode ser (zero)')
		Return
		
	Endif

Return .T.                            

//-----------------------------------------------------|       
// montagem dos arrays                                 |
//-----------------------------------------------------|    
Static Function CCSP001At(aHeader01,_aDados01)  

	Local ni				:= 0
	Local nx				:= 0
	Local cLstC01			:= ""
	Local cAliasT			:= GetNextAlias()
	Local aTMP				:= {}  
	Local cPrdCte        	:= TRATAPED(GETMV("MV_#PRDCTE"))
	
	//Definicoes de filtros  ?
	_aDados01 := Array(0) 
	
	
	//Fazer a pesquisa dos dados  ?
	(cLstC01 := "",aEval(aHeader01,{|x| IIf(!Empty(x[TCB_POS_CMP]),cLstC01 += x[TCB_POS_CMP] + ",","")}),cLstC01 := "%" + Substr(cLstC01,1,Len(cLstC01) - 1) + "%")
	
	BeginSQL Alias cAliasT    
	    
		SELECT 
			FONTES.C7_NUM,FONTES.C7_EMISSAO,FONTES.C7_FORNECE,FONTES.A2_NOME, SUM(FONTES.C7_TOTAL) AS C7_TOTAL
		FROM 
		(
			SELECT 
				C7_NUM,C7_PRODUTO, C7_EMISSAO,C7_FORNECE+'-'+C7_LOJA AS C7_FORNECE,A2_NOME, C7_TOTAL AS C7_TOTAL 
			FROM 
				%table:SC7% SC7 INNER JOIN %table:SA2% SA2 ON SC7.C7_FORNECE = SA2.A2_COD AND SC7.C7_LOJA = SA2.A2_LOJA
				WHERE SA2.D_E_L_E_T_ = '' AND SC7.D_E_L_E_T_ = ''  AND SC7.C7_FILIAL = %exp:cFilLog% AND C7_XTIPCTE = '' //AND SC7.C7_QUJE = 0
				//AND (SC7.C7_XPCORIG = '' OR SC7.C7_PRODUTO IN (%exp:cPrdCte%)) 23/12/2017 Fernando Sigoli
				AND SC7.C7_EMISSAO BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02% 
				AND SC7.C7_FORNECE = %exp:MV_PAR03% 
				AND SC7.C7_LOJA BETWEEN %exp:MV_PAR04% AND %exp:MV_PAR05% 
				AND SC7.C7_NUM BETWEEN  %exp:MV_PAR06% AND %exp:MV_PAR07% 
		) AS FONTES
		GROUP BY FONTES.C7_NUM,FONTES.C7_EMISSAO,FONTES.C7_FORNECE,FONTES.A2_NOME
		
	EndSQL
	
	(cAliasT)->(dbGoTop())
	If !(cAliasT)->(Eof())
		
		//Tratamento de tipo de dados
		DbSelectArea("SX3")
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
			
			aTMP := Array((cAliasT)->(FCount()) + 1)
			aTMP[1] := .F.
			For ni := 1 to (cAliasT)->(FCount())
				aTMP[ni + 1] := (cAliasT)->(FieldGet(ni))
			Next ni
			
			aAdd(_aDados01,aClone(aTMP))			
			                          
			(cAliasT)->(dbSkip())
		EndDo
		
	Else
		
		//Gerar lista de dados  ?
		_aDados01 := Array(1,Len(aHeader01) + 1)
		For ni := 1 to Len(_aDados01)
			_aDados01[ni][1] := .F.
			For nx := 1 to Len(aHeader01)
				_aDados01[ni][nx + 1] := CriaVar(aHeader01[nx][TCB_POS_CMP],.F.)
			Next nx
		Next ni	
		      
	Endif
	
	If Len(aLstPED) > 0
	
	 	aLstPED        := {}
	    oDetalhe:aCols := {}
	    oDetalhe:Refresh()
	
	EndIf
	
	U_FecArTMP(cAliasT)

Return Nil  

    
//-------------------------------------------------------------------------|       
//tela de seleção dos pedidos para geraçã de um unico pedido para o frete  |
//-------------------------------------------------------------------------|       
Static Function CCSP001GD(nOpc,aDados,oGDSel,nColSel,aHead)

	Local ni		:= 0
	Local cNUMPED	:= ""
	Local cCrtMsg   := .T.
	     
	PARAMTYPE 0	VAR nOpc		AS Numeric		OPTIONAL	DEFAULT 0
	PARAMTYPE 1	VAR aDados		AS Array		OPTIONAL	DEFAULT Array(0)
	PARAMTYPE 2	VAR oGDSel		AS Object		OPTIONAL	DEFAULT Nil
	PARAMTYPE 3	VAR nColSel		AS Numeric		OPTIONAL	DEFAULT 1
	PARAMTYPE 4	VAR aHead		AS Array		OPTIONAL	DEFAULT Array(0)
	     
	If nOpc == 1
		
		cNUMPED  := U_GDField(2,aHead,aDados,TCB_POS_CMP,"C7_NUM",oGDSel:nAt,.T.)
		
		If !Empty(cNUMPED)
			aDados[oGDSel:nAt][1] := !aDados[oGDSel:nAt][1]
			For ni := 1 to Len(aDados)
				If oGDSel:nAt<>ni 
					If U_GDField(2,aHead,aDados,TCB_POS_CMP,"C7_NUM",ni,.T.) == cNUMPED
							aDados[ni][1] := !aDados[ni][1]
					EndIf
				Endif
			Next ni
		Endif
	Else
		If nColSel == 1
			For ni := 1 to Len(aDados)
				If !Empty(U_GDField(2,aHead,aDados,TCB_POS_CMP,"C5_NUM",ni,.T.))
					aDados[ni][1] := !aDados[ni][1]
				Endif
			Next ni
		Else
		
			aDados := aSort(aDados,,,{|x,y| x[nColSel] < y[nColSel]})
		
		EndIf
		
	Endif       
	
	//Montar a lista de titulos selecionados  ?
	aLstPED := Array(0)
	For ni := 1 to Len(aDados)
		If aDados[ni][1]
			aAdd(aLstPED,U_GDField(2,aHead,aDados,TCB_POS_CMP,{"C7_NUM","C7_EMISSAO","C7_FORNECE","C7_LOJA","A2_NOME","C7_TOTAL"},ni,.T.))
		Endif
	Next ni
	
	//Forcar a atualizacao do browse
	oGDSel:DrawSelect()

Return Nil

//--------------------------------------------------------------------------------|       
//monta a tela para selecionar o valor , condição de pagamento e fornecedor do CTE|
//--------------------------------------------------------------------------------|       
Static Function PCFORNEC(oTela)

	Local l         	:= 0
	Local cQury         := ""
	
	Private nGet1	  	:= 0
	Private cGet2	  	:= Space(6)
	Private cGet3	  	:= Space(2)
	Private cGet4	  	:= Space(3)
	Private cGet5	  	:= Space(70)
	
	Private aClone    	:= {} 
	private cTotPedids 	:= ""
	                         
	PARAMTYPE 0	VAR oTela	AS Object	OPTIONAL	DEFAULT Nil
	
	If Empty(aLstPED) .OR. ValType(aLstPED) # "A"
		Return !lRet
	Endif
	
	oDetalhe:Acols:={}
	oDetalhe:Refresh()
	
	For l := 1 to Len(aLstPED)
	    
	 	If l = 1
			cTotPedids := "'"+aLstPED[l][1]+"'"
	    Else
	    	cTotPedids := cTotPedids +",'"+aLstPED[l][1]+"'"
	    EndIf
	
	Next l
	   
		//chamado: 038665 - Fernando Sigoli 13/12/2017
		cQury := " SELECT C7_FORNECE, C7_LOJA,C7_LOCAL,C7_PRODUTO,SUM(C7_QUANT) AS C7_QUANT, "
		cQury += " REPLICATE('0', 4 - LEN(ROW_NUMBER() OVER(ORDER BY C7_PRODUTO ASC))) + RTrim(ROW_NUMBER() OVER(ORDER BY C7_PRODUTO ASC)) AS C7_ITEM, "
		cQury += " SUM(C7_PRECO) AS C7_PRECO , SUM(C7_TOTAL) AS C7_TOTAL,C7_CC FROM "+RetSqlName('SC7')+" "
		cQury += " WHERE D_E_L_E_T_ = '' AND C7_NUM IN (" + cTotPedids + ")"
		cQury += " GROUP BY C7_PRODUTO,C7_FORNECE,C7_LOCAL,C7_LOJA,C7_CC "
		
		If Select( "TEMPSC7" ) > 0
			DbSelectArea( "TEMPSC7" )
			DbCloseArea()
		EndIf
		
		TCQUERY cQury NEW ALIAS "TEMPSC7"
	
		DbSelectArea("TEMPSC7")
		Dbgotop()
		While !EOF()
		
			aadd(aClone,{TEMPSC7->C7_FORNECE,TEMPSC7->C7_LOJA,TEMPSC7->C7_CC,TEMPSC7->C7_LOCAL,TEMPSC7->C7_PRODUTO,TEMPSC7->C7_TOTAL,TEMPSC7->C7_ITEM,})
			//
			Aadd(oDetalhe:aCols , Array(Len(aHDet) + 1) )
			oDetalhe:aCols[Len(oDetalhe:aCols), Len(oDetalhe:aCols[1]) ] := .F.
			
			oDetalhe:aCols[Len(oDetalhe:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "PCITE" })] := TEMPSC7->C7_ITEM
			oDetalhe:aCols[Len(oDetalhe:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "PCPRD" })] := TEMPSC7->C7_PRODUTO
			oDetalhe:aCols[Len(oDetalhe:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "PCDES" })] := Posicione('SB1', 1, xFilial('SB1') + TEMPSC7->C7_PRODUTO, 'B1_DESC')
		    oDetalhe:aCols[Len(oDetalhe:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "PCLOC" })] := TEMPSC7->C7_LOCAL
			oDetalhe:aCols[Len(oDetalhe:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "PCCUS" })] := TEMPSC7->C7_CC
			oDetalhe:aCols[Len(oDetalhe:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "PCQTD" })] := TEMPSC7->C7_QUANT
			oDetalhe:aCols[Len(oDetalhe:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "PCUNI" })] := Round(TEMPSC7->C7_PRECO,2)  
			oDetalhe:aCols[Len(oDetalhe:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "PCTOT" })] := Round(TEMPSC7->C7_TOTAL,2)  
				
		TEMPSC7->(dbSkip())
		EndDO
	    //
	    oDetalhe:Refresh()
	   
		If oTela # Nil
			oTela:SetFocus()
		Endif 
	     
Return lRet

//--------------------------------------------------------------------------------|       
//monta a tela para selecionar o valor , condição de pagamento e fornecedor do CTE|
//--------------------------------------------------------------------------------|       
Static Function PCGERAR(oTela)

	Local lVolt 	:= .T.           
	Local lContinua := .T.
	Local i 		:= 1
	
	Private nGet1	:= 0
	Private cGet2	:= Space(6)
	Private cGet3	:= Space(2)
	Private cGet4	:= Space(3)
	Private cGet5	:= Space(70)
	Private nVlrTot := 0
	
	 
	   If Len(oDetalhe:aCols) > 0 
			
			//Verifica se existe itens deletados
			For i= 1 to Len(oDetalhe:aCols)	 
				
				If oDetalhe:aCols[i,Len(aHDet)+1]
		        
					If MsgYesNo("Existem Itens Deletado(s), na qual nao compoem a base para geração do Pedido de CTE","DESEJA CONTINUAR?")
				 		Exit
			 		Else
			 			lContinua := .F.
			 			Exit
			 		EndIf
				
			 	EndIf   
			 	
			
				If oDetalhe:aCols[1][6] <= 0
		  			Alert("Atenção!!Nao existem Itens para geração do pedido de CTE")    
		  			lContinua := .F.
				 	Exit
			 	EndIf 
			 	           
		    
			
			
			Next i 
		    
		    //valor Total dos itens 
		    For i= 1 to Len(oDetalhe:aCols)	 
				
				If !(oDetalhe:aCols[i,Len(aHDet)+1]) //delete
		        
		        	nVlrTot := nVlrTot+oDetalhe:aCols[i][8] //valor total dos itens, exceto  os deletados
			 	
			 	EndIf              
		    
		    Next i 
		Else
		
			Alert("Atenção!!Nao existem Itens para geração do pedido de CTE")  
			lContinua := .F.
		EndIf
	    
		If lContinua
		 
			DEFINE Font oBold14 Name 'Arial' Size 14, 14 Bold  
			DEFINE MSDIALOG oDlg TITLE "CTE" FROM C(178),C(181) TO C(420),C(520) PIXEL
					
				@ C(008),C(052) MsGet nGet1 PICTURE "@E 999,999.99" SIZE C(060),C(016)  FONT oBold14 OF oDlg Color CLR_BLUE PIXEL
		      	@ C(011),C(011) Say "R$ FRETE" Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg
						
				@ C(036),C(010) Say "FORNECEDOR" Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
				@ C(032),C(052) MsGet cGet2 PICTURE "@!" VALID ExistCpo("SA2",cGet2) F3 "SA2A" SIZE C(060),C(016)  FONT oBold14 OF oDlg  PIXEL 
		        @ C(032),C(116) MsGet cGet3 Valid ExistCpo("SA2", cGet2 + cGet3)Size C(020),C(016) FONT oBold14  COLOR CLR_BLACK Picture "@!" PIXEL 
					
				@ C(058),C(010) Say "COND.PAG" Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
				@ C(055),C(052) MsGet cGet4 PICTURE "@!" VALID ExistCpo("SE4",cGet4) F3 "SE4" SIZE C(060),C(016) FONT oBold14 OF oDlg  PIXEL  
				
				@ C(082),C(011) Say "OBSER:" Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg
				@ C(082),C(052) MsGet cGet5 PICTURE "@!" SIZE C(110),C(010) OF oDlg Color CLR_BLUE PIXEL 
				
				@ C(100),C(034) Button "OK"   Size C(042),C(017) PIXEL OF oDlg  ACTION 	(GERADADO()) 
				@ C(100),C(083) Button "SAIR" Size C(042),C(017) PIXEL OF oDlg  ACTION 	(lOk := .F.,oDlg:end())
				
				
						
			ACTIVATE MSDIALOG oDlg CENTERED 
		
		EndIf
		     
	 	If oTela # Nil
			oTela:SetFocus()
		Endif 
		
Return lVolt

//----------------------------------------------------------------|       
// função responsavel pela carga dos dados da geração do pedido   |
//----------------------------------------------------------------|       
Static Function GERADADO()
                             
	Local aDados	:= {}
	Local nVlrCpy   := 0  
	Local aVetor    := {}
	Local lGeraSc   := .T.
	Local lDelete   := .F.
	Local cItem     := ""
	Local i   		:= 1	
	
	Private nQtdIten:= 0
	
		
		If nGet1 <= 0 .or. Empty(cGet2) .or. Empty(cGet3) .or. Empty(cGet4)
	    	Alert("Campos Obrigatórios nao preenchidos.")	
			Return .F.
		
		EndIf
		
		If Len(oDetalhe:aCols) > 0
			             
			For i= 1 to Len(oDetalhe:aCols)	 
			    
			    If ! (oDetalhe:aCols[i,Len(aHDet)+1])
		        
			    	nVlrCpy  := nVlrCpy+Round((nGet1/nVlrTot)* oDetalhe:aCols[i][8],2)
			    	nQtdIten := nQtdIten+1
				 	cItem    := PADL(cValToChar(nQtdIten),4,"0") 
				 	
				    If nGet1 >= nVlrCpy    
					         	
						aadd(aDados,{Alltrim(cGet2),; //fornecedor
					       		     Alltrim(cGet3),; //loja
					       			 Alltrim(oDetalhe:aCols[i][5]),; //c.custo
					       			 Alltrim(oDetalhe:aCols[i][4]),; //local
					       			 Alltrim(oDetalhe:aCols[i][2]),; //produtos
					       			 Round((nGet1/nVlrTot)* oDetalhe:aCols[i][8],2),; //preço unitario,calculado % em cima do pedidos/item origem
					       			 Alltrim(cItem)}) // itens do pedido 
				    Else  
				                	
				       	nVlrCpy := nVlrCpy - nGet1
				       
				        aadd(aDados,{Alltrim(cGet2),; //fornecedor
					       		     Alltrim(cGet3),; //loja
					       			 Alltrim(oDetalhe:aCols[i][5]),; //c.custo
					       			 Alltrim(oDetalhe:aCols[i][4]),; //local
					       			 Alltrim(oDetalhe:aCols[i][2]),; //produtos
					       			 Round(((nGet1/nVlrTot)* oDetalhe:aCols[i][8])-nVlrCpy,2),; //preço unitario,calculado % em cima do pedidos/item origem
				                     Alltrim(cItem)}) // itens do pedido 
				    EndIf
			    
			    EndIF
			         		
			Next i 
			
			//Retorna um array idêntico aDados.
			aVetor 	:= AClone(aDados)
			Processa( {|| lGeraSc := MyMata110(aVetor) }, "Aguarde...", "gerando Solicitação de compra de frete...",.F.)
			
			If lGeraSc 
				//faz chamado para inclusao do pedido de compra
				Processa( {|| MyMata120(aDados) }, "Aguarde...", "gerando Pedido de Frete...",.F.) //Chamado: 037886 - Fernando Sigoli 07/11/2017
	
			Else
			
				MsgStop("Atenção. Solcitação e Pedido de compra não gerado")		
			
			EndIf        
		
		Else
		
			Alert("Nao existe itens para geração do Pedido de CTE")	    
			Return .F.
		 		
		EndIF
		
		
		If Type("oDlg") == "O" 
		
			oDlg:END()//encerra a janela
			
		EndIf 
		
		MsgRun("MsgRun","Processando",{|| MsAguarde({|| CursorWait(),CCSP001At(aClone(aHeader01),@_aDados01),Eval(bAtGD,.T.,.T.),CursorArrow()},cRotNome,"Atualizando",.F.)},;
				aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.})
					
	        
	    aLstPED        := {}
	    oDetalhe:aCols := {}
	    oDetalhe:Refresh()
	    	
	    Pergunte("SC7CTE01" ,.F.)
    
Return .T.  


//-----------------------------------------------------|       
//funcao responsavel pra geração do pedido de compra.  |
//-----------------------------------------------------|       
Static Function MyMata120(aDados)

	Local aCab     := {}
	Local aItens   := {}
	Local aLinha   := {}
		       
	Local cNumPc   := ""
	Local cPedv    := ""
	Local l        := 0
	Local r        := 0
	Local cObserv  := AllTrim(cGet5)
	
	Private lMsHelpAuto := .T.
	Private lMsErroAuto := .F.
	
	
		If Len(aDados) > 0           
	
			//cNumPc := GetSXENum("SC7","C7_NUM")
			cNumPc := u_SXESXF("SC7") // // @history ticket    3873 - Fernando Macieira - 23/11/2020 - Projeto - Contrato e Controle de Entradas - São Carlos
			
			aadd(aCab,{"C7_NUM" 	,cNumPc		 })
			aadd(aCab,{"C7_EMISSAO" ,dDataBase	 })
			aadd(aCab,{"C7_FORNECE" ,cGet2     	 })
			aadd(aCab,{"C7_LOJA" 	,cGet3	     })
			aadd(aCab,{"C7_COND"	,cGet4   	 })
			aadd(aCab,{"C7_CONTATO" ,""			 })
			aadd(aCab,{"C7_FILENT"  ,cFilLog	 })
			
	       	        
		    For l= 1 to Len(aDados)                                                                                             
				
				aLinha := {}
				aadd(aLinha,{"C7_PRODUTO" 	,aDados[l][5]					,Nil})
				aadd(aLinha,{"C7_QUANT" 	,1 		 						,Nil})
				aadd(aLinha,{"C7_PRECO" 	,aDados[l][6] 					,Nil})
				aadd(aLinha,{"C7_TOTAL" 	,aDados[l][6]					,Nil})
				aadd(aLinha,{"C7_CC" 		,aDados[l][3]   				,Nil})
				aadd(aLinha,{"C7_LOCAL" 	,aDados[l][4]   				,Nil})
				aadd(aLinha,{"C7_XRESPON" 	,AllTrim(cUserName)				,Nil})
				aadd(aLinha,{"C7_NUMSC" 	,AllTrim(cNumSC)    			,Nil})
				aadd(aLinha,{"C7_ITEMSC" 	,aDados[l][7]       			,Nil})
				aadd(aLinha,{"C7_XTIPCTE" 	,'CTE'              			,Nil})  
				aadd(aLinha,{"C7_OBS" 	    ,cObserv              			,Nil})  
				
				aadd(aItens,aLinha)
		                           
		    Next l
		                               
			lMsErroAuto := .F.                    
		    MATA120(1,aCab,aItens,3)
		 
			If lMsErroAuto   
			
			     Alert("Erro ao incluir pedido")
			     lErro := .T.
			     MostraErro()
			
			Else 
				
				ConfirmSX8()
				
				For r := 1 to Len(aLstPED)
					
					DbSelectArea("SC7")
					SC7->(dbgotop())
					SC7->(dbSetOrder(1)) 
					If DbSeek(xFilial("SC7") + Alltrim(aLstPED[r][1]))
						While SC7->(!EOF()) .and. SC7->C7_FILIAL == xFilial("SC7") .and. SC7->C7_NUM == Alltrim(aLstPED[r][1])
							
							If !Empty(SC7->C7_XPCORIG)
								cPedv := Alltrim(SC7->C7_XPCORIG)+"/"+cNumPc
							Else
								cPedv := cNumPc
							EndIf                      
							
						   	RecLock("SC7",.F.)
								SC7->C7_XPCORIG	:= Alltrim(cPedv)
							MsunLock()  
							
	   			 		SC7->(DbSkip())	
						EndDo
					
					EndIf	
				
				Next r 
				
				//apos incluir o pedido, faz o fechamento da solicitação de compra 
				DbselectArea("SC1") 
				Dbgotop(1)
				Dbseek(xFilial("SC1")+cNumSC)
				While !Eof() .And. SC1->C1_NUM == cNumSC
	  				RecLock("SC1",.F.)
					Replace SC1->C1_QUJE    With 1   //fixo para sempre gerar apenas quantidade de 1 unidade            
					Replace SC1->C1_APROV   With 'L'
	 				Replace SC1->C1_NOMAPRO With 'AUTOMATICO-CTE'
	 				Replace SC1->C1_OBS     With cObserv
					MsUnlock("SC1") 
				DbSkip()
				End	 
				
				MsgInfo("Gerado Pedido de FRETE com sucesso! "+cNumPc) 
				lOk := .T.
				
			EndIf
			
	    Else 
	    
	    	Alert("Pedidos nao gerado, devido ausência de informacoes")
	    	lOk := .F.
				
	    EndIf           
	    
	    //chamada da pergunta novamente para para posicionar corretamente os parametros
	    Pergunte(cPerg,.F.)
   
Return .T. 
   
               
//-----------------------------------------------------|       
//Funcao responsavel pra geração do pedido de compra.  |
//Chamado: 037886 - Fernando Sigoli 07/11/2017         |
//-----------------------------------------------------|       
Static Function MyMata110(aVetor)

	Local aCabec 	:= {}
	Local aItens 	:= {}
	Local aLinha	:= {}
	Local nX     	:= 0
	Local lRetSc 	:= .T.  
	Local cFunBkp 	:= FunName()  
	Local cMVFil	:= Alltrim(cValToChar(GetMv("MV_#GERCFI"))) 
		             
	Private lMsHelpAuto := .T.
	Private lMsErroAuto := .F.
	Private cNumSC      := ""    
	
	SetFunName("MATA110")
	
	If Len(aVetor) > 0
		
		cNumSC := GetSXENum("SC1","C1_NUM")		
		ConfirmSX8()
		
		aadd(aCabec,{"C1_FILAL"  ,cFilLog     		})	
		aadd(aCabec,{"C1_NUM"    ,cNumSC     		})		
		aadd(aCabec,{"C1_SOLICIT",Alltrim(cUserName)})		
		aadd(aCabec,{"C1_EMISSAO",dDataBase			})		
		If cFilLog $(cMVFil) 
			aadd(aCabec,{"C1_CODCOMP",'001'			    }) //administrador 
	 	EndIF
	 	
		For nX := 1 To Len(aVetor)			
			
			aLinha := {}			
			aadd(aLinha,{"C1_ITEM"   ,StrZero(nx,len(SC1->C1_ITEM)),Nil})			
			aadd(aLinha,{"C1_PRODUTO",aVetor[nX][5]		,Nil})			
			aadd(aLinha,{"C1_QUANT"  ,1   				,Nil})
			aadd(aLinha,{"C1_CC"     ,aVetor[nX][3]  	,Nil})
			aadd(aLinha,{"C1_LOCAL"  ,aVetor[nX][4]    	,Nil})
			aadd(aCabec,{"C1_XHORASC",TIME()		    ,Nil})		
	 		aadd(aCabec,{"C1_XGRCOMP",'1'			    ,Nil}) //1-Normal (classificação de urgencia de compra
	 		aadd(aCabec,{"C1_FILENT" ,cFilLog			,Nil})  
	 	  	aadd(aItens,aLinha)		
			
		Next nX		
			
		MSExecAuto({|x,y| mata110(x,y)},aCabec,aItens)		
			
		If !lMsErroAuto			
			ConfirmSX8()
			MsgInfo(OemToAnsi("Incluido com sucesso SC.Compra! ")+cNumSC)		
		    lRetSc := .T.
	  
		Else			
			MsgStop(OemToAnsi("Erro na inclusao SC.Compra!"))		
		   	MostraErro()
		   	lRetSc := .F.
			
		EndIf	
	
	Else 
	
		Alert("Solicitação de Compra nao gerado, devido ausência de informacoes")
	    lRetSc := .F.
	
	EndIf
	
		SetFunName(cFunBkp)	

Return lRetSc


//-------------------------------------------|       
// valide pergunta                           |
//-------------------------------------------|
Static Function PFATA2VlP(cPerg,aPergunte)

	Local lRetorno	:= .T.
	Local ni		:= 0
	
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
			MsgAlert(cNomeUs + ", inconsistêcia na pergunta " + StrZero(ni,2) + " (" + StrTran(AllTrim(Capital(aPergunte[ni][POS_X1DES])),"?","") + ")")
			Return !lRet
		Endif
	Next ni                               

Return lRetorno  

//-------------------------------------------------------------------------------------------------------------|
//Tratamento dos produtos , relacionado do parametro ("MV_#PRDCTE") necessario para utilização no IN do Select |
//-------------------------------------------------------------------------------------------------------------|
Static Function TRATAPED(cParam)
    
	Local cPedido  := ""
	Local cPedidos := ""
	Local cParam   := alltrim(cParam) + ";"
	Local i		   := 1
	    
		For i:= 1 to Len(alltrim(cParam))
	    
	        If SubStr(cParam,i,1) == "/"
	            cPedido  := StrZero(Val(cPedido),6)
	            cPedidos += cPedido + "','"
	            cPedido := ""
	        ElseIf SubStr(cParam,i,1) == ";"
	            cPedido  := StrZero(Val(cPedido),6)
	            cPedidos += cPedido + ""
	        Else
	            cPedido += SubStr(cParam,i,1)
	        EndIf
	    
	    Next
    
Return cPedidos

/*/{Protheus.doc} User Function AltObsPC
	( Permite alterar observacao seguindo alguns criterios para manter a integridade dos dados)
	@type  Function
	@author Fernando Macieira
	@since 08/08/2019
	@version 01
	/*/

User Function AltObsPC()

	Local lRet       := .t.
	Local aAreaFIE   := FIE->( GetArea() )

	// parametros
	Local lUsrAut    := GetMV("MV_#USRLIG",,.f.) // Ativa controle de usuarios autorizados
	Local cUsrAut    := GetMV("MV_#USRPCF",,"000000") // Usuarios autorizados

	// dialog
	Local oDlgAltObs, OBTNALTOBS
	Local lOKAltObs  := .f.
	Local cNewObs    := SC7->C7_OBS
	Local oCmpNewObs := Array(01)
	Local OBTNALTOBS := Array(02)

	// Consisto usuarios autorizados
	If lUsrAut
		If !(cUsrAut $ RetCodUsr())
			lRet := .f.
			Aviso(	"MT121BRW-01",;
					"Login não autorizado... Alteração da observação não permitida!",;
					{ "&Retorna" },,;
					"Altera Observação" )
		EndIf
	EndIf

	// Consisto comprador com login
	If lRet
		If AllTrim(SC7->C7_USER) <> AllTrim(RetCodUsr())
			lRet := .f.
			Aviso(	"MT121BRW-05",;
					"Somente comprador que incluiu este PC pode alterar a observação... Alteração da observação não permitida!",;
					{ "&Retorna" },,;
					"Altera Observação" )
		EndIf
	EndIf

	// Consisto se o PC teve movimentacoees
	/*
	aAdd(aCores,    { 'C7_QUJE==0 .And. C7_QTDACLA==0'   		, 'ENABLE'})	  	//-- Pendente
	aAdd(aCores,    { 'C7_QUJE<>0.And.C7_QUJE<C7_QUANT'			, 'BR_AMARELO'}) 	//-- Pedido Parcialmente Atendido
	aAdd(aCores,    { 'C7_QUJE>=C7_QUANT'   					, 'DISABLE'})	  	//-- Pedido Atendido
	aAdd(aCores,    { 'C7_QTDACLA >0' 							, 'BR_LARANJA'}) 	//-- Pedido Usado em Pre-Nota
	*/
	If lRet
		If SC7->C7_QUJE <> 0
			lRet := .f.
			Aviso(	"MT121BRW-02",;
					"Pedido de compra atendido ou parcialmente atendido... Alteração da observação não permitida!",;
					{ "&Retorna" },,;
					"Altera Observação" )
		EndIf
	EndIf
		
	If lRet
		If SC7->C7_QTDACLA > 0
			lRet := .f.
			Aviso(	"MT121BRW-03",;
					"Pedido de compra usado em pré-nota... Alteração da observação não permitida!",;
					{ "&Retorna" },,;
					"Altera Observação" )
		EndIf
	EndIf
	
	// Consisto se o PC possui adiantamento incluido ou amarrado pela rotina padrao do pedido de compras
	If lRet
		FIE->( dbSetOrder(1) ) // FIE_FILIAL+FIE_CART+FIE_PEDIDO
		If FIE->( dbSeek( FWxFilial("FIE")+"P"+SC7->C7_NUM ) )
			lRet := .f.
			Aviso(	"MT121BRW-04",;
					"Pedido de compra possui amarração com adiantamento... Alteração da observação não permitida!",;
					{ "&Retorna" },,;
					"Altera Observação" )
		EndIf
	EndIf
		
	// Efetuo a alteracao do fornecedor
	If lRet
	
		Do While .T.
		
			DEFINE MSDIALOG oDlgAltObs TITLE "Nova Observação" FROM 0,0 TO 135,1140  OF oMainWnd PIXEL
				
				@ 003, 003 TO 050,565 PIXEL OF oDlgAltObs
				
				@ 015,018 Say "Observação:" of oDlgAltObs PIXEL
				@ 010,065 MsGet oCmpNewObs Var cNewObs SIZE 470,12 of oDlgAltObs PIXEL Valid !Empty(cNewObs)

				@ 052,215 BUTTON oBtnAltObs[01] PROMPT "Confirma" of oDlgAltObs SIZE 68,12 PIXEL ACTION (lOKAltObs := .t. , oDlgAltObs:End())
				@ 052,289 BUTTON oBtnAltObs[02] PROMPT "Cancela"  of oDlgAltObs SIZE 68,12 PIXEL ACTION oDlgAltObs:End()
				
			ACTIVATE MSDIALOG oDlgAltObs CENTERED
			                                      
			// Botao confirmar
			If lOKAltObs
				// Confirmo com o usuário se realmente deseja alterar a observação do pc/item
				If lRet
					If msgNoYes("Tem certeza de que deseja alterar a observação deste pedido de compra? " + CHR(13) + CHR(10) + "Atenção: A observação será alterado a partir desta confirmação mesmo que você feche o pedido de compras ou clique no botão cancelar...")
						MsgRun( "Efetuando alteração da observação...","Específico - Altera Observação", { || RunAltObsPC(cNewObs) } )
						MessageBox("Entre em visualizar caso queira conferir a nova observação...","Alteração da observação concluída com sucesso!",0)
						Exit
					Else
						Alert("Observação não alterada!")
						Exit
					EndIf
				EndIf
			Else
				Alert("Observação não alterada!")
				Exit
			Endif
		
		EndDo
	
	EndIf

	RestArea( aAreaFIE )

Return lRet


/*/{Protheus.doc} User Function RunAltObsPC
	(Processa alteracao da observacao)
	@type  Function
	@author Fernando Macieira
	@since 08/08/2019
	@version 01
	/*/

Static Function RunAltObsPC(cNewObs)

	Begin Transaction
	
		// Gravo Log ZBE
		u_GrLogZBE (Date(),TIME(),cUserName,"PC/ITEM " + SC7->C7_NUM + "/" + SC7->C7_ITEM + " - VER PC ANTES DA ALTERACAO NA TABELA SCY ","COMPRAS ","MT121BRW ",;
					   		   				"ADORO - ALTERA OBS ",ComputerName(),LogUserName()) 
		
		// PC
		RecLock("SC7", .f.)
			SC7->C7_OBS := cNewObs
		SC7->( msUnLock() )
		
	End Transaction
	
Return

/*/{Protheus.doc} User Function AltDTPC
	(Criado para alterar a Data de entrega no campo C7_DATPRF)
	@type  Function
	@author ADRIANO SAVOINE
	@since 20/12/2019
	@version 01
	@history Chamado 054127 - ADRIANO SAVOINE - 20/12/2019 - Alteração da Data de Entrega sem passar pela Alçada de aprovação.
	/*/

User Function AltDTPC()

	Local lRet       := .t.
	Local aAreaFIE   := FIE->( GetArea() )

	// parametros
	Local lUsrAut    := GetMV("MV_#USRLIG",,.f.) // Ativa controle de usuarios autorizados
	Local cUsrAut    := GetMV("MV_#USRPCF",,"000000") // Usuarios autorizados


//DT.ENTREGA
	Local oDlgAltDtEnt, OBTNALTDT
	Local lOKAltDT   := .f.
	Local cNewDT     := SC7->C7_DATPRF
	Local cPedido    := SC7->C7_NUM
	Local cItem      := SC7->C7_ITEM 
	Local oCmpNewDT  := Array(01)
	Local OBTNALTDT  := Array(02)

	// Consisto usuarios autorizados
	If lUsrAut
		If !(cUsrAut $ RetCodUsr())
			lRet := .f.
			Aviso(	"MT121BRW-01",;
					"Login não autorizado... Alteração da Data de Entrega não permitida!",;
					{ "&Retorna" },,;
					"Altera Data de Entrega" )
		EndIf
	EndIf

	// Consisto comprador com login
	If lRet
		If AllTrim(SC7->C7_USER) <> AllTrim(RetCodUsr()) .And.;
		   ! checkGrp(AllTrim(SC7->C7_USER), AllTrim(RetCodUsr()), "Alteração data de entrega " + cPedido) //Everson. 04/10/2021. Chamado 43012.
			lRet := .f.
			Aviso(	"MT121BRW-05",;
					"Somente comprador que incluiu este PC pode alterar a Data de Entrega... Alteração da Data de Entrega não permitida!",;
					{ "&Retorna" },,;
					"Altera Data de Entrega" )
		EndIf
	EndIf


If lRet
		If SC7->C7_QUJE <> 0
			lRet := .f.
			Aviso(	"MT121BRW-02",;
					"Pedido de compra atendido ou parcialmente atendido... Alteração da Data de Entrega não permitida!",;
					{ "&Retorna" },,;
					"Altera Data de Entrega" )
		EndIf
	EndIf
		
	If lRet
		If SC7->C7_QTDACLA > 0
			lRet := .f.
			Aviso(	"MT121BRW-03",;
					"Pedido de compra usado em pré-nota... Alteração da Data de Entrega não permitida!",;
					{ "&Retorna" },,;
					"Altera Data de Entrega" )
		EndIf
	EndIf
	
	// Consisto se o PC possui adiantamento incluido ou amarrado pela rotina padrao do pedido de compras
	If lRet
		FIE->( dbSetOrder(1) ) // FIE_FILIAL+FIE_CART+FIE_PEDIDO
		If FIE->( dbSeek( FWxFilial("FIE")+"P"+SC7->C7_NUM ) )
			lRet := .f.
			Aviso(	"MT121BRW-04",;
					"Pedido de compra possui amarração com adiantamento... Alteração da Data de Entrega não permitida!",;
					{ "&Retorna" },,;
					"Altera Data de Entrega" )
		EndIf
	EndIf
	
	
	//ALTERA DATA ENTREGA PC

	If lRet
	
		Do While .T.
		
			DEFINE MSDIALOG oDlgAltDtEnt TITLE "Nova DT.Entrega" FROM 0,0 TO 150,385  OF oMainWnd PIXEL
				
				@ 003, 003 TO 050,190 PIXEL OF oDlgAltDtEnt
				
				@ 015,018 Say "DT.Entrega:" of oDlgAltDtEnt PIXEL
				@ 010,065 MsGet oCmpNewDT Var cNewDT SIZE 100,12 of oDlgAltDtEnt PIXEL Valid (cNewDT)

				@ 052,015 BUTTON OBTNALTDT[01] PROMPT "Confirma" of oDlgAltDtEnt SIZE 68,12 PIXEL ACTION (lOKAltDT := .t. , oDlgAltDtEnt:End())
				@ 052,105 BUTTON OBTNALTDT[02] PROMPT "Cancela"  of oDlgAltDtEnt SIZE 68,12 PIXEL ACTION oDlgAltDtEnt:End()
				
			ACTIVATE MSDIALOG oDlgAltDtEnt CENTERED
			                                      
			// Botao confirmar
			If lOKAltDT
				// Confirmo com o usuário se realmente deseja alterar a DT.Entrega do pc/item
				If lRet
					If msgNoYes("Tem certeza de que deseja alterar Data de Entrega do pedido de compra? " + CHR(13) + CHR(10) + "Atenção: A Data de Entrega será alterado a partir desta confirmação, caso não queira alterar clique no botão cancelar...")
						MsgRun( "Efetuando alteração da Dt.Entrega...","Específico - Altera Data Entrega", { || RunAltDTPC(cNewDT,cPedido,cItem) } )
						MessageBox("Entre em visualizar caso queira conferir a nova Data de Entrega...","Alteração da DT.Entrega concluída com sucesso!",0)
						Exit
					Else
						Alert("DT.Entrega não alterada!")
						Exit
					EndIf
				EndIf
			Else
				Alert("DT.Entrega não alterada!")
				Exit
			Endif
		
		EndDo
	
	EndIf
	
RestArea( aAreaFIE )

Return lRet

/*/{Protheus.doc} User Function RunAltDTPC
	(Processa alteracao da Data de Entrega)
	@type  Function
	@author ADRIANO SAVOINE
	@since 20/12/2019
	@version 01
	@history Chamado 054127 - ADRIANO SAVOINE - 20/12/2019 - Alteração da Data de Entrega sem passar pela Alçada de aprovação.
	/*/


Static Function RunAltDTPC(cNewDT,cPedido,cItem)

	LOCAL aAreaAnt := GETAREA()

	Begin Transaction

		// Gravo Log ZBE
		u_GrLogZBE (Date(),TIME(),cUserName,"PC/ITEM " + SC7->C7_NUM + "/" + SC7->C7_ITEM + " - VER PC ANTES DA ALTERACAO NA TABELA SCY ","COMPRAS ","MT121BRW ",;
											"ADORO - ALTERA DT.ENTREGA ",ComputerName(),LogUserName()) 
		//Ticket TI - 04/03/2021 - Adriano Savoine - Inicio
		IF MSGYESNO( '<h1>ATENÇÃO!!!</h1><br> Deseja alterar todos os itens com essa data Click em <font color="#FF0000"> SIM </font>, caso contrario click em <font color="#FF0000"> NAO </font> e será alterado somente o item posicionado.', 'Alterar Data Pedido De Compra.' )
		
		 // PC
		
			dbselectarea("SC7")
			DBSETORDER(1)
			DBSeek(xFilial("SC7")+cPedido)      // Posiciona o Pedido
			WHILE !EOF() .and. SC7->C7_Num == cPedido

				RecLock("SC7",.F.)

					SC7->C7_DATPRF := cNewDT

				MsUnLock()

				DBSkip()
			ENDDO
		ELSE
			dbselectarea("SC7")
			DBSETORDER(1)
			DBSeek(xFilial("SC7")+cPedido+cItem)      // Posiciona o Pedido
			WHILE !EOF() .and. SC7->C7_Num == cPedido .and. C7_ITEM == cItem

				RecLock("SC7",.F.)

					SC7->C7_DATPRF := cNewDT

				MsUnLock()

				DBSkip()
			ENDDO
		ENDIF
		//Ticket TI - 04/03/2021 - Adriano Savoine - FIM
	End Transaction
	RESTAREA(aAreaAnt)   // Retorna o ambiente anterior

Return


/*/{Protheus.doc} User Function LIBPORT
	(Função para gravar o Colaborador que Liberou a entrada dos Produtos na Portaria para o Recebimento)
	@type  Function
	@author ADRIANO SAVOINE
	@since 28/01/2020
	@version 01
	@history Chamado 055246 - ADRIANO SAVOINE - 28/01/2020 - VALIDADOR DO PEDIDOS DE COMPRAS QUE CHEGAM NA PORTARIA PARA ELES VERIFICAREM SE EXISTE PEDIDO E LIBERAREM A ENTRADA.
	/*/

User Function LIBPORT()

	Local lRet        := .T.
	Local aAreaSC7    := SC7->( GetArea() )
	Local oDlgLibPort, OBTLIBPORT
	Local lOKAltDT    := .F.
	Local cNewOBSLIB  := SPACE(254)
	Local cPedido     := SC7->C7_NUM
	Local oCmpLibPort := Array(01)
	Local OBTLIBPORT  := Array(02)

	// Verifico se o Pedido está Liberado

	IF SC7->C7_CONAPRO <> "L"

		lRet := .F.
		Aviso(	"MT121BRW-01",;
				"Pedido de compra Rejeitado ou Bloqueado... Recebimento não permitida!",;
				{ "&Retorna" },,;
				"Checagem Portaria" )

	ENDIF
	

	// Verifico se o Pedido já foi Recebido total

	IF lRet

		IF SC7->C7_QUANT == SC7->C7_QUJE 

			lRet := .F.
			Aviso(	"MT121BRW-02",;
					"Pedido de compra já recebido total... Recebimento não permitida!",;
					{ "&Retorna" },,;
					"Checagem Portaria" )
					
		ENDIF
	ENDIF
	
	// Verifico se o pedido foi recebido total porem parcial.

	IF lRet

		IF SC7->C7_RESIDUO = 'S'

			lRet := .f.
			Aviso(	"MT121BRW-03",;
					"Pedido de compra com eliminação de Residuo... Recebimento não permitida!",;
					{ "&Retorna" },,;
					"Checagem Portaria" )

		ENDIF
	ENDIF

	//Checagem de Pedido de Compra na Portaria

	IF lRet	
			
		DEFINE MSDIALOG oDlgLibPort TITLE "Checagem do Pedido de Compra" FROM 0,0 TO 135,1140  OF oMainWnd PIXEL
			
			@ 003, 003 TO 050,565 PIXEL OF oDlgLibPort
			
			@ 015,018 Say "Observação de Liberação:" of oDlgLibPort PIXEL
			@ 010,095 MsGet oCmpLibPort Var cNewOBSLIB SIZE 420,12 of oDlgLibPort PIXEL Valid (cNewOBSLIB)

			@ 052,215 BUTTON OBTLIBPORT[01] PROMPT "Confirma" of oDlgLibPort SIZE 68,12 PIXEL ACTION (lOKAltDT := .T. , oDlgLibPort:End())
			@ 052,289 BUTTON OBTLIBPORT[02] PROMPT "Cancela"  of oDlgLibPort SIZE 68,12 PIXEL ACTION oDlgLibPort:End()
			
		ACTIVATE MSDIALOG oDlgLibPort CENTERED
												
		// Botao confirmar
		IF lOKAltDT

			// Confirmo com o usuário se realmente deseja Liberar o pc/item
			

			IF msgNoYes("Confirma Liberação de Entrega do Pedido de Compra? " + CHR(13) + CHR(10) + "Atenção: Caso não queira Liberar esse Pedido clique no botão 'NÃO'...")

				MsgRun( "Efetuando Liberação para o Recebimento...","Específico - Checagem do Pedido de Compra", { || RunOBSLIB(cNewOBSLIB,cPedido) } )
				
				//MATR110()  // FUNÇÃO PARA IMPRIMIR PEDIDO DE COMPRA
				A120Impri( 'SC7', SC7->(RECNO()), 4 )

			ELSE

				Alert("Pedido não Liberado!")
				
			ENDIF
		ENDIF
	ENDIF		
	
	RestArea(aAreaSC7)

Return(lRet)

/*/{Protheus.doc} User Function RunOBSLIB
	(Registra quem Liberou)
	@type  Function
	@author ADRIANO SAVOINE
	@since 28/01/2020
	@version 01
	@history 
	/*/

Static Function RunOBSLIB(cNewOBSLIB,cPedido)

	Begin Transaction

		dbselectarea("ZFW")
	
		RecLock("ZFW",.T.)
			
			ZFW->ZFW_FILIAL := FWxFilial("ZFW")
			ZFW->ZFW_NUM  := cPedido
			ZFW->ZFW_DATA := Date()
			ZFW->ZFW_HORA := TIME()
			ZFW->ZFW_USUA := cUserName
			ZFW->ZFW_OBS  := cNewOBSLIB
			
		ZFW-> (MsUnLock())
		
	End Transaction

Return(NIL)




User Function AltConPC()
	
	Local aAreaSC7 		:= SC7->(GetArea())
	Local aArea 		:= GetArea()
	Local cMsgInfo 		:= ""
	Local nOpca    		:= 0
	Private cChaveSC7 	:= SC7->(C7_FILIAL+C7_NUM)
	Private cCondAtual	:= SC7->C7_COND
	Private cDescri 	:= Posicione("SE4", 1, xFilial("SE4")+ C7_COND, "E4_DESCRI") 
	Private cCondNova	:= CriaVar("E4_CODIGO",.f.)
	Private cDesNov		:= CriaVar("E4_DESCRI",.f.)

	nEspLarg := 0
    nEspLin  := 0
	If fValid(1)
		DEFINE MSDIALOG oDlg FROM	15,6 TO 175,562 TITLE OemToAnsi("Alterar Condicao de Pagamento - Pedido No.: " + SC7->C7_FILIAL + "/"+SC7->C7_NUM) PIXEL
		//Painel dos dados
		oPanelD := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,25,25)
		oPanelD:Align := CONTROL_ALIGN_ALLCLIENT

		@ 010, 003+nEspLarg SAY	OemToAnsi("Cond.Pgto De")	SIZE 35, 7 OF oPanelD PIXEL 
		@ 010, 045+nEspLarg MSGET oCondAtual VAR cCondAtual F3 "SE4" ;   
			SIZE 25,10 OF oPanelD PIXEL HASBUTTON WHEN .f.

		@ 010, 068+20+nEspLarg SAY	OemToAnsi("Descricao")	SIZE 26, 7 OF oPanelD PIXEL 
		@ 010, 095+20+nEspLarg MSGET cDescri ;   
			SIZE 70,10 OF oPanelD PIXEL WHEN .f.

		@ 001, 001+nEspLarg TO 060, 280+nEspLarg LABEL OemToAnsi("Transferir para") OF oPanelD PIXEL 	

		@ 025, 003+nEspLarg SAY	OemToAnsi("Cond.Pgto Para")	SIZE 40, 7 OF oPanelD PIXEL  
		@ 025, 045+nEspLarg MSGET oCondNova VAR cCondNova F3 "SE4" Valid (fDescri(cCondNova,@cDesNov));  
			SIZE 25,10 OF oPanelD PIXEL HASBUTTON WHEN .t.

		@ 025, 068+20+nEspLarg SAY	OemToAnsi("Descricao")	SIZE 26, 7 OF oPanelD PIXEL  
		@ 025, 095+20+nEspLarg MSGET oDesNov VAR cDesNov ;   
			SIZE 70,10 OF oPanelD PIXEL WHEN .f.	

		DEFINE SBUTTON FROM 68, 224 TYPE 1 ACTION (nOpca:=1,oDlg:End()	) ENABLE OF oPanelD
					
		DEFINE SBUTTON FROM 68, 251 TYPE 2 ACTION (nOpca:=0,oDlg:End()) ENABLE OF oPanelD
		
		ACTIVATE MSDIALOG oDlg CENTERED

		If nOpca == 1
			If fValid(2)

				SC7->(DbSetOrder(1))
				SC7->(DbSeek(cChaveSC7))
				While !SC7->(Eof()) .and. SC7->(C7_FILIAL+C7_NUM) == cChaveSC7
					RecLock("SC7", .f.)
					SC7->C7_COND := cCondNova
					SC7->(MsUnlock())
					

					SC7->(DbSkip())
				End
				cMsgInfo := "A condição de pagamento no Pedido No.: " + SC7->C7_FILIAL + "/" + SC7->C7_NUM + " foi alterada de [" + cCondAtual + " - " + Alltrim(cDescri) + "] para [" + cCondNova + " - " + Alltrim(cDesNov) + "] com sucesso!"
				MsgInfo(cMsgInfo,"ATenção")
				//User Function GrLogZBE(dDate,cTime,cUser,cLog,cModulo,cRotina,cParamer,cEquipam,cUserRed)
				u_GrLogZBE (Date(),TIME(),cUserName,cMsgInfo,"COMPRAS","MT121BRW",;
									"PEDIDO "+SC7->C7_NUM+" COND PAG "+cCondNova,ComputerName(),LogUserName())
			Endif

		Endif

	Endif
	RestArea(aArea)
	SC7->(RestArea(aAreaSC7))
Return 


Static Function fDescri(cCondNova, cDesNov)


	cDesNov:= Posicione("SE4", 1, xFilial("SE4")+ cCondNova, "E4_DESCRI") 

    oDesNov:Refresh()

Return 


Static Function fValid(nTipo) //1- Antes de exibir a interface ao usuario; 2-Após a confirmação do usuário.
	Local lRet := .t.
	Local cDescErr := ""
	Local nDiasNovo := 0
	Local nDiasAtual := 0
	Local aAreaSC7 := SC7->(GetArea())
	Local aAreaFIE := FIE->(GetArea())
	Local aArea := GetArea()

	Do Case
		Case nTipo == 1

			SC7->(DbSetOrder(1))
			SC7->(DbSeek(cChaveSC7))
			While !SC7->(Eof()) .and. SC7->(C7_FILIAL+C7_NUM) == cChaveSC7


				//só o dono do pedido pode alterar

				If AllTrim(SC7->C7_USER) <> AllTrim(RetCodUsr())
					lRet := .f.
					cDescErr := "Somente comprador que incluiu este PC pode alterar a condição de pagamento... Alteração da condição de pagamento não permitida!"
					Exit
				EndIf

				
				FIE->( dbSetOrder(1) ) // FIE_FILIAL+FIE_CART+FIE_PEDIDO
				If FIE->( dbSeek( FWxFilial("FIE")+"P"+SC7->C7_NUM ) )
					lRet := .f.
					cDescErr := "Pedido de compra possui amarração com adiantamento... Alteração da condição de pagamento não permitida!"
					Exit
				EndIf

				

				IF SC7->C7_QUJE > 0
					lRet := .f.
					cDescErr := "Já existe entrega para esse pedido. A condição de pagamento não pode ser alterada."
					Exit
				Endif

				IF SC7->C7_QTDACLA > 0
					lRet := .f.
					cDescErr := "Esse pedido já foi classificado. A condição de pagamento não pode ser alterada."
					Exit
				Endif

				IF !Empty(C7_RESIDUO)
					lRet := .f.
					cDescErr := "Já foi eliminado resíduo. A condição de pagamento não pode ser alterada."
					Exit
				Endif

				If C7_TIPO == 2
					lRet := .f.
					cDescErr := "Não é um pedido de compras. A condição de pagamento não pode ser alterada."
					Exit

				Endif


				SC7->(DbSkip())
			End


		Case nTipo == 2

			nDiasNovo := fMedPgto(cCondNova)
			nDiasAtual := fMedPgto(cCondAtual)

			If nDiasNovo < nDiasAtual

				lRet := .f.
				cDescErr := "O prazo médio da nova condição de pagamento [" +cCondNova+" - "+Alltrim(cDesNov)+"] é de " +Alltrim(Str(nDiasNovo))+" dia(s) e, portanto, inferior "
				cDescErr += "ao prazo médio da condição de pagamento atual [" +cCondAtual+" - "+Alltrim(cDescri)+"] de " +Alltrim(Str(nDiasAtual))+" dia(s)."
				cDescErr += " A condição de pagamento no Pedido No.: " + SC7->C7_FILIAL + "/"+SC7->C7_NUM +" não será alterada."
				

			Endif

		Otherwise

			lRet := .t.
	EndCase
		If !lRet
			MsgStop(cDescErr, "Alteração na Condição de pagamento proibida!")
		Endif

	RestArea(aArea)
	SC7->(RestArea(aAreaSC7))
	FIE->(RestArea(aAreaFIE))
Return lRet


Static Function fMedPgto(cCond)
	Local aAreaSC7 := SC7->(GetArea())
	Local aArea := GetArea()
	Local nRet
	Local aCond := {}
	Local nValor := 0
	Local nValIpi := 0
	Local nValSolid := 0
	Local nX
	Local nDias := 0
	Local nDiasTot := 0
	Local nTotal := 0

	SC7->(DbSetOrder(1))
	SC7->(DbSeek(cChaveSC7))
	While !SC7->(Eof()) .and. SC7->(C7_FILIAL+C7_NUM) == cChaveSC7
	
		nValor += SC7->C7_TOTAL
		dEmissao := SC7->C7_EMISSAO
		SC7->(DbSkip())
	End

	aCond := Condicao(nValor,cCond,nValIpi,dEmissao,nValSolid)
	For nX := 1 To Len(aCond)

		dDataPar := aCond[nX][01]
		nValPar	:= aCond[nX][02]

		nDias := dDataPar -dEmissao
		nTotal += nDias * nValPar
		nDiasTot += nDias
									
						 
	Next nX

	nRet := nTotal /nValor


	RestArea(aArea)
	SC7->(RestArea(aAreaSC7))
Return nRet

/*/{Protheus.doc} checkGrp
	Função checa se o usuário pode alterar o pedido
	de compra.
	@type  Function
	@author Everson
	@since 04/10/2021
	@version 01
	/*/
Static Function checkGrp(cDono, cUsuario, cMsg)

	//Variáveis.
	Local aArea := GetArea()
	Local cQuery:= "" //Everson. 04/10/2021. Chamado 43012.
	Local lRet  := .T.
	Local cGrup := ""

	//
	If cDono == cUsuario
		RestArea(aArea)
		Return lRet

	EndIf

	//
	cGrup := Alltrim(cValToChar(Posicione("SY1", 3, FWxFilial("SY1") + cDono, "Y1_GRUPCOM")))

	//
	If Empty(cGrup)
		lRet := .F.
		
		U_GrLogZBE(Date(), Time(), cUserName, cMsg + " sem grupo " + " " + cValToChar(lRet),; 
	          "MT121BRW", "", ComputerName(), LogUserName()) 
		RestArea(aArea)
		
		Return lRet

	EndIf

	//
	cQuery += " SELECT  " 
	cQuery += " AJ_GRCOM  " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("SAJ") + " AS SAJ " 
	cQuery += " WHERE " 
	cQuery += " AJ_FILIAL = '" + FWxFilial("SAJ") + "' " 
	cQuery += " AND AJ_GRCOM = '" + cGrup + "' " 
	cQuery += " AND AJ_USER = '" + cUsuario + "' " 
	cQuery += " AND SAJ.D_E_L_E_T_ = '' " 

	//
	TcQuery cQuery New Alias "D_CHECK"
	DbSelectArea("D_CHECK")
	D_CHECK->(DbGoTop())
		If D_CHECK->(Eof())
			lRet := .F.
			
		EndIf
	D_CHECK->(DbCloseArea())

	//
	U_GrLogZBE(Date(), Time(), cUserName, cMsg + " cGrup " + cGrup + " " + cValToChar(lRet),; 
	          "MT121BRW", "", ComputerName(), LogUserName()) 

	//
	RestArea(aArea)

Return lRet
