#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
/*/{Protheus.doc} User Function ADFIN019P
	Descricao ³Rotina desenvolvida exatamente em cima da rotina ATULIMCRED
	em uso pela Adoro,para sistema de pre analise de aprovacao de credito
	Pre aprova os pedidos de venda por credito
	@type  Function
	@author Mauricio - MDS TEC
	@since 21/10/2016
	@version 01
	@history Chamado 060417 - Everson  - 13/08/2020 - melhoria de performance.
	@history Ticket  8      - Abel B.  - 29/01/2021 - Execução de forma automática na Inclusão e Alteração do Pedido de Venda
	@history Ticket  8      - Abel B.  - 02/02/2021 - Acrescentada informação dos pedidos ainda não processados
	@history Ticket  63149  - Sigoli   - 01/11/2021 - InterFunctionCall: cannot find function TCSQLERRO in AppMap on PROCATU -- Corrigido o nome da função PARA: TCSQLERROR
	@history Ticket  T.I    - Sigoli   - 26/01/2022 -  Adicionado tratamento na query para nao trazer pedido de devolução
/*/

User Function ADFIN019P() // U_ADFIN019P()

	//Variáveis.
	Local aArea  := GetArea()
	Local bBloco := {|lEnd| ProcAtu()}

	//
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina desenvolvida exatamente em cima da rotina ATULIMCRED em uso pela Adoro,para sistema de pre analise de aprovacao de credito')
	
	//
	If !Pergunte("LIBCRED",.T.)
		RestArea(aArea)
		Return Nil

	EndIf
	
	IF xTlCons() //Ticket  8      - Abel B.  - 29/01/2021 - Execução de forma automática na Inclusão e Alteração do Pedido de Venda
	//
		Processa(bBloco,"Aguarde, realizando Pre Aprovação...","Atualizando...",.F.)
	ENDIF

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} ProcAtu

	@type  Static Function
	@author user
	@since 
	@version 01
	/*/
Static Function ProcAtu()

	//Variáveis.
	Local aArea 	:= GetArea()
	Local cQuery	:= ""
	Local cCliente 	:= ""
	Local nTotReg	:= 0
	Local nAux		:= 0

	//
	Private nPedBlq := 0
	Private nPedLib := 0
	Private nPedNao := 0          
	Private nPedTot := 0
	Private cLuc 	:= ' ' 

	//Atualizar C5_XPREAPR para os clientes 031017,030545 somente.
	cQuery := " UPDATE " + RetSqlName("SC5") + " SET C5_XPREAPR = 'L' " //Everson - 13/08/2020. Chamado 060417.
	cQuery += " WHERE "
	cQuery += " C5_DTENTR  BETWEEN '" + DTOS(mv_par01)    + "' AND '" + DTOS(mv_par02)    + "' "
	cQuery += " AND C5_NUM BETWEEN '" + Alltrim(mv_par03) + "' AND '" + Alltrim(mv_par04) + "' "
	cQuery += " AND C5_CLIENTE IN ('031017','030545') "
	cQuery += " AND C5_XPREAPR IN ('') "
	cQuery += " AND C5_NOTA = '' "
	cQuery += " AND D_E_L_E_T_ = '' "

	//Everson - 13/08/2020. Chamado 060417.
	If TcSqlExec(cQuery) < 0 
		MsgStop("Ocorreu erro ao efetuar update." + Chr(13) + Chr(10) + TCSQLERROR(),"Função ProcAtu(ADFIN019P)") // Tkt - 63149 - Fernando Sigoli - Corrigido o nome da função DE :TCSQLERRO  PARA: TCSQLERROR
		RestArea(aArea)
		Return Nil
	EndIf

	//
	cQuery := " SELECT "
	cQuery += " C5_CLIENTE, C5_FILIAL, C5_NUM "
	cQuery += " FROM " + RetSqlName("SC5") + " (NOLOCK) AS SC5 "
	cQuery += " WHERE "
	cQuery += " C5_DTENTR  BETWEEN '"     + DTOS(mv_par01)     + "' AND '" + DTOS(mv_par02) + "' "
	cQuery += " AND C5_NUM BETWEEN '"     + Alltrim(mv_par03)  + "' AND '" + Alltrim(mv_par04) + "' "
	cQuery += " AND C5_CLIENTE BETWEEN '" + Alltrim(mv_par05)  + "' AND '" + Alltrim(mv_par06) + "' "
	cQuery += " AND C5_CLIENTE NOT IN ('031017','030545') "
	cQuery += " AND C5_XPREAPR IN ('','B') "
	cQuery += " AND C5_NOTA = '' "
	cQuery += " AND C5_TIPO NOT IN ('B') " //Ticket  T.I - Sigoli   - 26/01/2022
	cQuery += " AND SC5.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY C5_CLIENTE, C5_FILIAL, C5_NUM "	

	//	
	TcQuery cQuery New Alias "TMPLC"
	DbSelectArea ("TMPLC")
	TMPLC->(DbGoTop())
	nTotReg := Contar("TMPLC","!Eof()")
	ProcRegua(nTotReg)	
	TMPLC->(DbGoTop())

	//
	While ! TMPLC->(Eof())

		//Everson - 13/08/2020. Chamado 060417.
		cCliente :=  TMPLC->C5_CLIENTE

		//
		U_ADFIN020P(cCliente,"Ped","FIN")
			
		//
		While cCliente ==  TMPLC->C5_CLIENTE

			//
			nAux++
			IncProc("Processando cliente|pedido " + cCliente + " | " + TMPLC->C5_NUM + " | " + cValToChar(nAux) + "/" + cValToChar(nTotReg))

			//
			U_ADFIN021P(TMPLC->C5_FILIAL + TMPLC->C5_NUM)

			//
			TMPLC->(dbSkip())

		End

	End

	//
	TMPLC->(DbCloseArea())

	xTlCons() //Ticket  8      - Abel B.  - 29/01/2021 - Execução de forma automática na Inclusão e Alteração do Pedido de Venda

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} User Function xTlCons
	Exibe a Tela com o totalizador de pedidos liberados e bloqueados.
	@type  Function
	@author user
	@since 29/01/2021
	@version version
	/*/
Static Function xTlCons()
	Local nOpt := 2

	cQuery:= " SELECT " 
	cQuery+= " SUM(CASE WHEN C5_XPREAPR ='L' THEN 1 ELSE 0 END) AS C5_FLAGL, " //Everson - 13/08/2020. Chamado 060417.
	cQuery+= " SUM(CASE WHEN C5_XPREAPR ='B' THEN 1 ELSE 0 END) AS C5_FLAGB,  " //Everson - 13/08/2020. Chamado 060417.
	cQuery+= " SUM(CASE WHEN C5_XPREAPR ='' THEN 1 ELSE 0 END) AS C5_FLAGX  " //Everson - 13/08/2020. Chamado 060417.
	cQuery+= " FROM "+RetSqlName("SC5")+ " (NOLOCK) AS SC5 "
	cQuery+= " WHERE C5_DTENTR BETWEEN '" + DTOS(mv_par01)    + "' AND '" + DTOS(mv_par02) + "' "
	cQuery+= " AND C5_NUM BETWEEN '"      + Alltrim(mv_par03) + "' AND '" + Alltrim(mv_par04) + "' "
	cQuery+= " AND C5_CLIENTE BETWEEN '"  + Alltrim(mv_par05) + "' AND '" + Alltrim(mv_par06) + "' "
	cQuery+= " AND C5_CLIENTE NOT IN ('031017','030545') "
	//cQuery+= " AND C5_XPREAPR IN ('L','B') " //Everson - 13/08/2020. Chamado 060417.
	cQuery+= " AND C5_NOTA = '' "
	cQuery+= " AND C5_TIPO NOT IN ('B') " //Ticket  T.I - Sigoli   - 26/01/2022
	cQuery+= " AND SC5.D_E_L_E_T_ = '' "	

	//		
	TcQuery cQuery New Alias "TMPC5"
	TMPC5->(DbGoTop())	 

	//
	nPedLib := TMPC5->C5_FLAGL
	nPedBlq := TMPC5->C5_FLAGB
	nPedX		:= TMPC5->C5_FLAGX
	//
	TMPC5->(DbCloseArea())
			
	// --------------------------------
	// Tela exibição Status de Pedidos
	// --------------------------------
	DEFINE MSDIALOG oDlg FROM	18,1 TO 80,550 TITLE "ADORO S/A  -  STATUS PRE APROVACAO" PIXEL 

		@  2, 3 	TO 29, 242 OF oDlg  PIXEL
		If File("adoro.bmp")
		@ 3,7 BITMAP oBmp FILE "adoro.bmp" OF oDlg NOBORDER SIZE 25,25 PIXEL 
		oBmp:lStretch:=.T.
		EndIf
		@ 005, 047	SAY "BLOQUEADOS"      SIZE 40, 17 OF oDlg PIXEL 
		@ 005, 122	SAY "LIBERADOS"       SIZE 40, 17 OF oDlg PIXEL 
		@ 005, 197	SAY "NAO PROCES."     SIZE 40, 17 OF oDlg PIXEL //Ticket  8      - Abel B.  - 02/02/2021 - Acrescentada informação dos pedidos ainda não processados
		@ 014, 047 	TO 025, 083 OF oDlg  PIXEL
		@ 016, 062  Say nPedBlq  SIZE	40, 9 OF oDlg PIXEL
		@ 014, 120 	TO 025, 153 OF oDlg  PIXEL
		@ 016, 133  Say nPedLib  SIZE	40, 9 OF oDlg PIXEL  
		@ 014, 195 	TO 025, 228 OF oDlg  PIXEL
		@ 016, 208  Say nPedX    SIZE	40, 9 OF oDlg PIXEL  
		DEFINE SBUTTON FROM 03,246 TYPE 1 ACTION (nOpt := 1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM 17,246 TYPE 2 ACTION (nOpt := 2,oDlg:End()) ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED 


Return IIF(nOpt == 1,.T.,.F.)
