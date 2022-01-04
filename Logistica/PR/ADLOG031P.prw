#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

#Define STR_PULA    Chr(13)+Chr(10)
/*/{Protheus.doc} User Function ADLOG031P
	Monitoramento Liberação Credito Pedido de Venda.
	@type  Function
	@author Fernando
	@since 24/03/2017
	@version 01
	@history Chamado - 049470 || OS 050752 || LOGISTICA || HELDER_SILVA 8425 || Criado no Relatorio visual e no excel os campos
	Endereco e Bairro.  - Atendido por Adriano Savoine
	@history Chamado 052236 || OS 053576 || ADM || DAVI || 8372 || MONITOR ENTREGAS - FWNM - 14/10/2019
	@history Chamado 059728 - Everson    , 17/07/2020, Tratamento para nOpc = 3 (pedidos bloqueados por crédito).
	@history Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido e acrescentar nOpc = 4 (pedidos Bloqueador por Regra)
	@history ticket    9930 - Macieira   , 23/02/2021, array out of bounds ( 10 of 9 )  on { || {_aDet[oDet:nAt,1],_aDet[oDet:nAt][2],_aDet[oDet:nAt][3],_aDet[oDet:nAt][4],_aDet[oDet:nAt][5],_aDet[oDet:nAt][6],_aDet[oDet:nAt][7],_aDet[oDet:nAt][8],_aDet[oDet:nAt][9],_aDet[oDet:nAt][10]}}(ADLOG031P.PRW) 14/09/2020 08:37:18 line : 367
	@history TICKET   10851 - ADRIANO SAVOINE - 19/03/2021 - Ajustado o campo de Pedidos Liberados para abrir a Janela ao clicar sobre e imprimir o excel.
	@history TICKET   63590 - Everson - 12/11/2021 - Adicionado openquery para melhorar o desempenho do relatório.
	@history TICKET   T.I   - Fernando Sigoli 03/01/2022 - Removido atualização automatica e adicionado para atualizar no botao
/*/
User Function ADLOG031P() //U_ADLOG031P()

	//Variáveis.
	Local oDlg     := Nil
	Local cTitulo  := "Monitoramento Liberação Credito P.V"
	Local i        := 0
	Local cLine    := "" 

	Private oOk    := LoadBitmap( GetResources(), "BR_VERMELHO")
	Private oNo    := LoadBitmap( GetResources(), "BR_AMARELO" )
	Private oLbx   := Nil
	Private aVetor := {}
	//Private oTimer := Nil   
	Private cPerg  := "META01"
	Private oDlg1  := Nil
	Private _cLin  := ""

	Private oDet   := Nil     &&Mauricio - 18/08/17 - Chamado 036794
	Private _aDet  := {}      &&Mauricio - 18/08/17 - Chamado 036794

	Private nTotalCX  := 0
	Private nTotalKG  := 0
	Private nTotalPed := 0 
	Private nVlrTotal := 0

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Monitoramento Liberação Credito Pedido de Venda')

	cLine := "{IIf(aVetor[oLbx:nAt,1],oOk,oNo)"

	For i:=2 To 7
		cLine += ",aVetor[oLbx:nAt]["+AllTrim(Str(i))+"]"
	Next

	cLine += "}"
	bLine := &("{|| "+cLine+"}")

	&& chamada da pergunta
	If !Pergunte(cPerg,.T.) 
		Return Nil

	EndIf 

	/******
	* Monta a tela para usuario visualizar consulta |
	******/
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 290,720 PIXEL

	@ 10,10 LISTBOX oLbx FIELDS HEADER " ","Situacao","Pedido(s)","Caixa(s)", "  KG  ","  R$  "," % ", SIZE 340,100 OF oDlg PIXEL 

	//DEFINE TIMER oTimer INTERVAL 40000 ACTION  LoadArq(2) OF oDlg

	//oTimer:Activate()
	LoadArq(2) 

	@ 120,20 SAY "Entrega De : "+Dtoc(Mv_Par01) SIZE 100,007 OF oDlg PIXEL
	@ 130,20 SAY "Entrega Ate: "+Dtoc(Mv_Par02) SIZE 100,007 OF oDlg PIXEL 

	DEFINE SBUTTON FROM 120,260 TYPE 15 ACTION Processa({|lEnd| LoadArq(2) },OemToAnsi("Atualiza"),OemToAnsi("Processando..."),.F.) ENABLE OF oDlg //Removido atualização automatica e adicionado para atualizar no botao
	DEFINE SBUTTON FROM 120,300 TYPE 2  ACTION oDlg:End() ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTER

Return Nil
/*/{Protheus.doc} LoadArq
	Função para atualizar o vetor e o Listbox.
	@type  Static Function
	@author user
	@since 
	@version 01
	/*/
Static Function LoadArq(nTp) 

	//Variáveis.
	//Local cQuery := ""

	aVetor := {} 

	//If nTp==2
	//	oTimer:Deactivate()
	//Endif 

	nTotalCX  := 0
	nTotalKG  := 0
	nTotalPed := 0 
	nVlrTotal := 0

	If nTp==2 

		If SELECT("TMP1") > 0
			TMP1->(DBCLOSEAREA())
		Endif 
		//

		Query := " SELECT "  
		Query += " COUNT(FONTES2.PED) AS PEDIDOS,"
		Query += " SUM(FONTES2.QTDCX) AS QTDCX, "
		Query += " SUM(FONTES2.QTDKG) AS QTDKG, "
		Query += " SUM(FONTES2.VALOR) AS VALOR, "
		Query += " FONTES2.SITUACAO AS SITUACAO "
		Query += " FROM "
		Query += " ( "

		Query += " SELECT " 

		Query += " FONTES.PED, "
		Query += " FONTES.QTDCX, " 
		Query += " FONTES.QTDKG, "
		Query += " FONTES.VALOR, "

		Query += " CASE " 
		
		//INICIO Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido
		// Query += " WHEN FONTES.C9PEDIDO =  '' and FONTES.PREAPROV <> 'L' THEN 'EM ANALISE' "  
		// Query += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO NOT IN ('10','') and FONTES.ESTOQUE  = '' THEN 'BLOQ.CREDITO' "
		// Query += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO NOT IN ('10','') and FONTES.ESTOQUE <> '' THEN 'BLOQ.CREDITO' " 
		// Query += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO = '  ' and FONTES.ESTOQUE <> '' THEN 'BLOQ.ESTOQUE' " 
		Query += " WHEN FONTES.C9PEDIDO =  '' and FONTES.PREAPROV <> 'L' THEN 'PRE-APROVADO' "  
		Query += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO NOT IN ('10','') and FONTES.ESTOQUE  = '' THEN 'BLOQ.REGRA FINANCEIRA' "
		Query += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO NOT IN ('10','') and FONTES.ESTOQUE <> '' THEN 'BLOQ.REGRA FINANCEIRA' " 
		Query += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO = '  ' and FONTES.ESTOQUE <> '' THEN 'BLOQ.REGRA ESTOQUE' " 
		Query += " WHEN FONTES.C9PEDIDO = '' and FONTES.C5BLQ <> '' THEN 'BLOQ.REGRA COMERCIAL' " 
		//FIM Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido

		Query += " ELSE 'LIBERADO'  END 'SITUACAO', "

		Query += " FONTES.PREAPROV  "

		Query += " FROM "
		Query += " ( "

		Query += " SELECT "
		Query += " DADOS.PED, "
		Query += " SUM(DADOS.QTDCX) QTDCX, "
		Query += " SUM(DADOS.QTDKG) QTDKG, "
		Query += " SUM(DADOS.VALOR) VALOR, "	
		Query += " DADOS.VENDEDOR, "
		Query += " DADOS.PREAPROV, "

		//Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido
		Query += " DADOS.C5BLQ, "

		Query += " ISNULL(DADOS.C9PEDIDO,'') C9PEDIDO, "
		Query += " ISNULL((SELECT TOP 1 C9_BLCRED FROM "+retsqlname("SC9")+"  SC9 WITH (NOLOCK) WHERE SC9.C9_PEDIDO = DADOS.PED  AND SC9.C9_FILIAL = '02' AND SC9.D_E_L_E_T_ = '' ),'') AS CREDITO, " 
		Query += " ISNULL((SELECT TOP 1 C9_BLEST  FROM "+retsqlname("SC9")+"  SC9 WITH (NOLOCK) WHERE SC9.C9_PEDIDO = DADOS.PED  AND SC9.C9_FILIAL = '02' AND SC9.D_E_L_E_T_ = '' ),'') AS ESTOQUE " 

		Query += " FROM "
		Query += " (SELECT "  
		Query += " Distinct(C6_PRODUTO)AS PRODUTO, "  
		Query += " C5_VEND1   AS VENDEDOR, " 
		Query += " C6_NUM     as PED, "

		Query += " (C6_UNSVEN)  as QTDCX, "  
		Query += " (C6_QTDVEN)  as QTDKG, "  
		Query += " (C6_VALOR)   as VALOR, "  

		Query += " (C6_QTDORI)  as KGORI, "  
		Query += " (C6_QTDORI2) as CXORI, " 

		Query += " C9_PEDIDO AS C9PEDIDO, "

		//Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido
		Query += " C5_BLQ AS C5BLQ, "
		
		Query += " C5_XPREAPR AS PREAPROV " 

		Query += " FROM "+retsqlname("SC6")+"  SC6 WITH (NOLOCK) " 

		Query += " LEFT JOIN "+retsqlname("SC9")+"  SC9 WITH (NOLOCK) " 
		Query += " ON  SC6.C6_FILIAL = SC9.C9_FILIAL  "  
		Query += " AND SC6.C6_NUM    = SC9.C9_PEDIDO "  
		Query += " AND SC6.C6_CLI    = SC9.C9_CLIENTE "  
		Query += " AND SC6.C6_LOJA   = SC9.C9_LOJA "   
		Query += " AND SC9.D_E_L_E_T_ <> '*' " 

		Query += " INNER JOIN "+retsqlname("SC5")+"  SC5 WITH (NOLOCK) " 
		Query += " ON  SC6.C6_FILIAL  = SC5.C5_FILIAL "  
		Query += " AND SC6.C6_NUM     = SC5.C5_NUM "   
		Query += " AND SC6.C6_CLI     = SC5.C5_CLIENTE " 
		Query += " AND SC6.C6_LOJA    = SC5.C5_LOJACLI "  
		Query += " AND SC5.D_E_L_E_T_ <> '*' " 

		Query += " INNER JOIN "+retsqlname("SA3")+"  SA3 WITH (NOLOCK) "
		Query += " ON SC5.C5_VEND1 = SA3.A3_COD "      
		Query += " AND SA3.D_E_L_E_T_ <> '*' "  

		Query += " INNER JOIN "+retsqlname("SZR")+"  SZR WITH (NOLOCK) " 
		Query += " ON SA3.A3_CODSUP = SZR.ZR_CODIGO  "
		Query += " AND SZR.D_E_L_E_T_ <> '*' " 

		Query += " WHERE SC6.C6_SEGUM NOT IN ('KG','') "
		Query += " AND SC5.C5_FILIAL   = '"+xFilial("SC5")+"'"
		Query += " AND SC5.C5_DTENTR   >=  '"+Dtos(Mv_Par01)+"' AND SC5.C5_DTENTR <= '"+Dtos(Mv_Par02)+"'
		Query += " AND SC6.D_E_L_E_T_  <> '*' "
		Query += " AND SC5.C5_TIPO     =  'N' " 
		Query += " AND SC6.C6_UNSVEN   >  0 "
		Query += " AND SZR.ZR_SEGMERC  >= '"+Mv_Par05+"' AND SZR.ZR_SEGMERC <= '"+Mv_Par06+"'"
		Query += " AND SA3.A3_CODSUP   >= '"+Mv_Par03+"' AND SA3.A3_CODSUP  <= '"+Mv_Par04+"'"     
		// Chamado n. 052236 || OS 053576 || ADM || DAVI || 8372 || MONITOR ENTREGAS - FWNM - 14/10/2019
		If MV_PAR07 == 1 // Desconsiderar FOB? = 1 = SIM
			Query += " AND SC5.C5_TPFRETE <> 'F' "
		EndIf
		//
		Query += " ) as DADOS  "
		Query += " GROUP BY PED, VENDEDOR,C9PEDIDO,PREAPROV, C5BLQ) AS FONTES "
		Query += " ) AS FONTES2 "
		Query += " GROUP BY SITUACAO  "

		TCQUERY Query new alias "TMP1"    

		TMP1->(dbgotop())
		While !EOF()  
			nTotalPed := nTotalPed+TMP1->PEDIDOS 
			nTotalCX  := nTotalCX+TMP1->QTDCX
			nTotalKG  := nTotalKG+TMP1->QTDKG
			nVlrTotal := nVlrTotal+TMP1->VALOR
			DbSkip()
		End

		TMP1->(dbgotop())
		While !EOF()  
			aAdd(aVetor,{.F.,TMP1->SITUACAO,TMP1->PEDIDOS,Transform(TMP1->QTDCX, "@E 999,999,999") ,Transform(TMP1->QTDKG,"@E 999,999,999.99"),Transform(TMP1->VALOR,"@E 999,999,999.99"),IIF(TMP1->SITUACAO <> 'CORTE',ROUND((TMP1->PEDIDOS/nTotalPed)*100,3),),})
			DbSkip()
		End 

		If Select("QRYEDT") > 0
			QRYEDT->(DbCloseArea())
		Endif
		
		//
		// cQry := " SELECT "
		// cQry += " COUNT(DISTINCT(IE_PEDIVEND)) AS PEDI, "  
		// cQry += " ISNULL(SUM(PVI.QN_EMBAITEMPEDIVEND)- SUM(QN_EMBAEXPEITEMPEDIVEND) ,0) AS CXCORTE, "
		// cQry += " ISNULL(SUM(QN_ITEMPEDIVEND) - SUM(QN_EXPEITEMPEDIVEND),0) AS KGCORTE "
		// cQry += " FROM "
		// cQry += " [LNKMIMS].SMART.dbo.PEDIDO_VENDA PVV WITH (NOLOCK) INNER JOIN [LNKMIMS].SMART.dbo.PEDIDO_VENDA_ITEM PVI WITH (NOLOCK) "
		// cQry += " ON PVV.FILIAL = PVI.FILIAL AND PVV.ID_PEDIVEND = PVI.ID_PEDIVEND "
		// cQry += " WHERE PVV.FL_STATPEDIVEND IN ('FE', 'EX', 'ZR') "
		// cQry += " AND (COALESCE(PVI.QN_CAIXCORTITEMPEDIVEND, 0) > 0 "
		// cQry += " OR  (PVI.QN_EMBAITEMPEDIVEND - COALESCE(QN_EMBAEXPEITEMPEDIVEND, 0)) >0) "
		// cQry += " AND DT_ENTRPEDIVEND >= '"+Dtos(Mv_Par01)+"' AND DT_ENTRPEDIVEND <= '"+Dtos(Mv_Par02)+"'"
		//

		//Everson - 12/11/2021. Chamado 63590.
		cQry := " SELECT * FROM OPENQUERY(LNKMIMS,' " 
		cQry += " SELECT  " 
		cQry += " COUNT(DISTINCT(IE_PEDIVEND)) AS PEDI,    " 
		cQry += " ISNULL(SUM(PVI.QN_EMBAITEMPEDIVEND)- SUM(QN_EMBAEXPEITEMPEDIVEND) ,0) AS CXCORTE,  " 
		cQry += " ISNULL(SUM(QN_ITEMPEDIVEND) - SUM(QN_EXPEITEMPEDIVEND),0) AS KGCORTE  " 
		cQry += " FROM  " 
		cQry += " SMART.dbo.PEDIDO_VENDA PVV WITH (NOLOCK) INNER JOIN SMART.dbo.PEDIDO_VENDA_ITEM PVI WITH (NOLOCK)  " 
		cQry += " ON PVV.FILIAL = PVI.FILIAL AND PVV.ID_PEDIVEND = PVI.ID_PEDIVEND  " 
		cQry += " WHERE PVV.FL_STATPEDIVEND IN (''FE'', ''EX'', ''ZR'')  " 
		cQry += " AND (COALESCE(PVI.QN_CAIXCORTITEMPEDIVEND, 0) > 0  " 
		cQry += " OR  (PVI.QN_EMBAITEMPEDIVEND - COALESCE(QN_EMBAEXPEITEMPEDIVEND, 0)) >0)  " 
		cQry += " AND DT_ENTRPEDIVEND >= ''"+Dtos(Mv_Par01)+"'' AND DT_ENTRPEDIVEND <= ''"+Dtos(Mv_Par02)+"'' " 
		cQry += " ') " 

		TCQUERY cQry NEW ALIAS "QRYEDT"

		DbSelectArea("QRYEDT")       
		DbGoTop() 

		//tela de cortes
		aAdd(aVetor,{.F.,"CORTE.EXPED ->",QRYEDT->PEDI,Transform(QRYEDT->CXCORTE, "@E 999,999,999") ,Transform(QRYEDT->KGCORTE,"@E 999,999,999.99"),0,0})

		//total
		aAdd(aVetor,{.F.,"TOTAL ->",nTotalPed,Transform(nTotalCX, "@E 999,999,999") ,Transform(nTotalKG,"@E 999,999,999.99"),Transform(nVlrTotal,"@E 999,999,999.99"),,})


	Else                                                 
		aAdd(aVetor,{.F.,"","","","","", }) 

	EndIF 	


	/******
	* Carrega o vetor conforme a condicao |
	******/

	If nTp==2 

		oLbx:SetArray(aVetor) 
		oLbx:bLine := {||{If(aVetor[oLbx:nAt,01],oOK,oNO),aVetor[oLbx:nAt,02],;                      
		aVetor[oLbx:nAt,03]         ,aVetor[oLbx:nAt,04],;
		aVetor[oLbx:nAt,05]         ,aVetor[oLbx:nAt,06],;
		aVetor[oLbx:nAt,07]}}  
		oLbx:BLdbLclick := { || ftela() }      &&Mauricio - 18/08/17 - Chamado 036794
		oLbx:GoBottom()
		oLbx:Refresh()
		//oTimer:Activate()

	Endif

Return Nil
/*/{Protheus.doc} fTela
	Chamado 036794.
	@type  Static Function
	@author Mauricio
	@since 18/08/2017
	@version 01
	/*/
Static function fTela()
  Local aSize := MsAdvSize(.F.)

	//Variáveis.
	Local oButton1
	Local oButton2
	Local nOpc := 1
	Local j	   := 1

	//
	If ValType(oDet) == "O"
		FreeObj(oDet)

	EndIf

	_cTitulo := "Detalhes dos Pedidos"

	if aVetor[oLbx:nAt,2]                      == "CORTE.EXPED ->" .Or. ;
	   Alltrim(cValToChar(aVetor[oLbx:nAt,2])) == "PRE-APROVADO"     .Or. ; //Everson - 09/11/2017. Chamado 037937, adicionado "EM ANALISE ->". //FIM Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido
	   Alltrim(cValToChar(aVetor[oLbx:nAt,2])) == "BLOQ.REGRA FINANCEIRA" .Or.; //William - 18/07/2018. Chamado 039700, adicionado "BLOQ.CREDITO".
		 Alltrim(cValToChar(aVetor[oLbx:nAt,2])) == "BLOQ.REGRA ESTOQUE" .Or.; //Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido
		 Alltrim(cValToChar(aVetor[oLbx:nAt,2])) == "LIBERADO" .Or.; 			//TICKET 10851 - ADRIANO SAVOINE - 19/03/2021
		 Alltrim(cValToChar(aVetor[oLbx:nAt,2])) == "BLOQ.REGRA COMERCIAL" //Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido
		_cLin := "{_aDet[oDet:nAt,1]"

		If aVetor[oLbx:nAt,2] == "CORTE.EXPED ->"

			For j:=2 To 9
				_cLin += ",_aDet[oDet:nAt]["+AllTrim(Str(j))+"]"
			Next
			nOpc := 1

		ElseIf Alltrim(cValToChar(aVetor[oLbx:nAt,2])) == "PRE-APROVADO" //FIM Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido

			For j:=2 To 10
				_cLin += ",_aDet[oDet:nAt]["+AllTrim(Str(j))+"]"
			Next		
			nOpc := 2
			
		ElseIf Alltrim(cValToChar(aVetor[oLbx:nAt,2])) == "BLOQ.REGRA FINANCEIRA" //William - 18/07/2018. Chamado 039700, adicionado "BLOQ.CREDITO". //FIM Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido

			For j:=2 To 10
				_cLin += ",_aDet[oDet:nAt]["+AllTrim(Str(j))+"]"
			Next		
			nOpc := 3	

		//Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido e acrescentar nOpc = 4 (pedidos Bloqueador por Regra)
		ElseIf Alltrim(cValToChar(aVetor[oLbx:nAt,2])) == "BLOQ.REGRA COMERCIAL"

			For j:=2 To 10
				_cLin += ",_aDet[oDet:nAt]["+AllTrim(Str(j))+"]"
			Next		
			nOpc := 4

		//Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido e acrescentar nOpc = 4 (pedidos Bloqueador por Regra)
		ElseIf Alltrim(cValToChar(aVetor[oLbx:nAt,2])) == "BLOQ.REGRA ESTOQUE"

			For j:=2 To 10
				_cLin += ",_aDet[oDet:nAt]["+AllTrim(Str(j))+"]"
			Next		
			nOpc := 5

		//TICKET 10851 - ADRIANO SAVOINE - 19/03/2021
		ElseIf Alltrim(cValToChar(aVetor[oLbx:nAt,2])) == "LIBERADO"

			For j:=2 To 10
				_cLin += ",_aDet[oDet:nAt]["+AllTrim(Str(j))+"]"
			Next		
			nOpc := 6	

		EndIf

		_cLin += "}"
		bLine := &("{|| "+_cLin+"}")

		DEFINE MSDIALOG oDlg1 TITLE _cTitulo FROM aSize[7], 0 TO aSize[6],aSize[5] PIXEL                                                                                                                

		//
		If nOpc == 1
			@ 10,10 LISTBOX oDet FIELDS HEADER "Pedido", "Cliente", "Loja", "Nome","Carga","CX(s) Solicitadas","CX(s) Enviadas", "CX(s) Corte ", "KG(s) Corte ", SIZE 660,260 OF oDlg1 PIXEL	

		ElseIf nOpc == 2 //Everson - 09/11/2017. Chamado 037937.// CHAMADO 049470 ADRIANO S.
			@ 10,10 LISTBOX oDet FIELDS HEADER "Pedido", "Cliente", "Loja", "Nome","Carga","CX(s)","KG(s)","Endereco","Bairro","Cidade", SIZE 660,260 OF oDlg1 PIXEL	
		
		ElseIf nOpc == 3 //William - 18/07/2018. Chamado 039700 // CHAMADO 049470 ADRIANO S.
			@ 10,10 LISTBOX oDet FIELDS HEADER "Pedido", "Cliente", "Loja", "Nome","Carga","CX(s)","KG(s)","Endereco","Bairro","Cidade", SIZE 660,260 OF oDlg1 PIXEL	

		//Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido e acrescentar nOpc = 4 (pedidos Bloqueador por Regra)
		ElseIf nOpc == 4 
			@ 10,10 LISTBOX oDet FIELDS HEADER "Pedido", "Cliente", "Loja", "Nome","Carga","CX(s)","KG(s)","Endereco","Bairro","Cidade", SIZE 660,260 OF oDlg1 PIXEL	

		ElseIf nOpc == 5
			@ 10,10 LISTBOX oDet FIELDS HEADER "Pedido", "Cliente", "Loja", "Nome","Carga","CX(s)","KG(s)","Endereco","Bairro","Cidade", SIZE 660,260 OF oDlg1 PIXEL	
		
		//TICKET 10851 - ADRIANO SAVOINE - 19/03/2021
		ElseIf nOpc == 6
			@ 10,10 LISTBOX oDet FIELDS HEADER "Pedido", "Cliente", "Loja", "Nome","Carga","CX(s)","KG(s)","Endereco","Bairro","Cidade", SIZE 660,260 OF oDlg1 PIXEL	

		EndIf

		MsAguarde( {||leDetalhe(nOpc) }, OemToAnsi( "Aguarde..." ) )	   		

		//DEFINE SBUTTON FROM 100,360 TYPE 1 ACTION oDlg1:End() ENABLE OF oDlg1
		@ 280, 50 BUTTON oButton1 PROMPT "Excel"  SIZE 038, 013 OF oDlg1 PIXEL Action(Processa({||AD031EXC(nOpc)},"Gerando arquivo","Aguarde..."))
		@ 280, 10 BUTTON oButton2 PROMPT "Fechar" SIZE 038, 013 OF oDlg1 PIXEL Action(oDlg1:End())

		//AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||LogAdLog004R()},"Gerando arquivo","Aguarde...")    }})

		ACTIVATE MSDIALOG oDlg1 CENTER

	Endif

Return() 
/*/{Protheus.doc} LeDetalhe
	Chamado 036794.
	@type  Static Function
	@author Mauricio
	@since 18/08/2017
	@version 01
	/*/
Static Function LeDetalhe(nOpc) 

	//Variáveis.
	Local aArea	   := GetArea()
	Local cCliente := ""
	Local cLoja    := ""
	Local cCarga   := ""
	Local cCidade  := ""
	Local cBairro  := ""
	Local cEndereco:= ""

	_aDet := {}    

	If Select("DETPED") > 0
		DETPED->(DbCloseArea())

	Endif

	If nOpc == 1

		_cQuery := ""
		_cQuery += " SELECT "

		_cquery += " IE_PEDIVEND		AS PEDIDO, "
		_cquery += " SC5.C5_CLIENTE		AS CLIENTE, "
		_cquery += " SC5.C5_LOJACLI     AS LOJA, "  
		_cquery += " SC5.C5_X_SQED      AS CARGA, " 

		_cquery += " ISNULL(SUM(PVI.QN_EMBAITEMPEDIVEND),0) AS QTDCXSOL, "
		_cquery += " ISNULL(SUM(QN_EMBAEXPEITEMPEDIVEND),0) AS QTDCXENV, "
		_cquery += " ISNULL(SUM(PVI.QN_EMBAITEMPEDIVEND)-SUM(QN_EMBAEXPEITEMPEDIVEND),0) AS QTDCXCORT, "  
		_cquery += " ISNULL(SUM(QN_ITEMPEDIVEND) - SUM(QN_EXPEITEMPEDIVEND),0) AS QTDKGCORT "

		_cquery += " FROM "                                                                                                              
		_cquery += " [LNKMIMS].SMART.dbo.PEDIDO_VENDA PVV WITH (NOLOCK) INNER JOIN [LNKMIMS].SMART.dbo.PEDIDO_VENDA_ITEM PVI WITH (NOLOCK) "
		_cquery += " ON PVV.FILIAL = PVI.FILIAL AND PVV.ID_PEDIVEND = PVI.ID_PEDIVEND "
		_cquery += " INNER JOIN SC5010 SC5 WITH (NOLOCK)   ON PVV.IE_PEDIVEND COLLATE SQL_Latin1_General_CP1_CS_AS = SC5.C5_NUM COLLATE SQL_Latin1_General_CP1_CS_AS "
		_cquery += " AND SC5.C5_FILIAL COLLATE SQL_Latin1_General_CP1_CS_AS = '02' "
		_cquery += " WHERE PVV.FL_STATPEDIVEND IN ('FE', 'EX', 'ZR') "
		_cquery += " AND (COALESCE(PVI.QN_CAIXCORTITEMPEDIVEND, 0) > 0 "
		_cquery += " OR  (PVI.QN_EMBAITEMPEDIVEND - COALESCE(QN_EMBAEXPEITEMPEDIVEND, 0)) >0) "
		_cquery += " AND DT_ENTRPEDIVEND >= '"+Dtos(Mv_Par01)+"' AND DT_ENTRPEDIVEND <= '"+Dtos(Mv_Par02)+"'"
		_cquery += " GROUP BY IE_PEDIVEND,C5_CLIENTE,C5_LOJACLI,C5_X_SQED "

		TCQUERY _cquery NEW ALIAS "DETPED"

		DbSelectArea("DETPED")       
		DbGoTop()
		While DETPED->(!Eof())
			aAdd(_aDet,{Alltrim(DETPED->PEDIDO),DETPED->CLIENTE,DETPED->LOJA,Posicione("SA1",1,xFilial("SA1")+DETPED->CLIENTE+DETPED->LOJA,"A1_NOME"),Substr(DETPED->CARGA,5,6),Transform(DETPED->QTDCXSOL, "@E 999,999,999") ,Transform(DETPED->QTDCXENV,"@E 999,999,999"),Transform(DETPED->QTDCXCORT,"@E 999,999,999"),Transform(DETPED->QTDKGCORT,"@E 999,999,999")})
			DETPED->(dbSkip())

		Enddo

		If Len(_aDet) == 0
			aAdd(_aDet,{"","","","","","","","","", })

		Endif

	ElseIf nOpc == 2 //Everson - 09/11/2017. Chamado 037937.

		_cquery := ""
		_cquery := " SELECT "  
		_cquery += " FONTES2.PED AS PEDIDO,"
		_cquery += " SUM(FONTES2.QTDCX) AS QTDCX, "
		_cquery += " SUM(FONTES2.QTDKG) AS QTDKG, "
		_cquery += " SUM(FONTES2.VALOR) AS VALOR, "
		_cquery += " FONTES2.SITUACAO AS SITUACAO "
		_cquery += " FROM "
		_cquery += " ( "

		_cquery += " SELECT " 

		_cquery += " FONTES.PED, "
		_cquery += " FONTES.QTDCX, " 
		_cquery += " FONTES.QTDKG, "
		_cquery += " FONTES.VALOR, "

		_cquery += " CASE " 
		//INICIO Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido
		// _cquery += " WHEN FONTES.C9PEDIDO =  '' and FONTES.PREAPROV <> 'L' THEN 'EM ANALISE' "  
		// _cquery += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO NOT IN ('10','') and FONTES.ESTOQUE  = '' THEN 'BLOQ.CREDITO' "
		// _cquery += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO NOT IN ('10','') and FONTES.ESTOQUE <> '' THEN 'BLOQ.CREDITO' " 
		// _cquery += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO = '  ' and FONTES.ESTOQUE <> '' THEN 'BLOQ.ESTOQUE' " 
		_cquery += " WHEN FONTES.C9PEDIDO =  '' and FONTES.PREAPROV <> 'L' THEN 'PRE-APROVADO' "  
		_cquery += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO NOT IN ('10','') and FONTES.ESTOQUE  = '' THEN 'BLOQ.REGRA FINANCEIRA' "
		_cquery += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO NOT IN ('10','') and FONTES.ESTOQUE <> '' THEN 'BLOQ.REGRA FINANCEIRA' " 
		_cquery += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO = '  ' and FONTES.ESTOQUE <> '' THEN 'BLOQ.REGRA ESTOQUE' " 
		//FIM Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido

		_cquery += " ELSE 'LIBERADO'  END 'SITUACAO', "

		_cquery += " FONTES.PREAPROV  "

		_cquery += " FROM "
		_cquery += " ( "

		_cquery += " SELECT "
		_cquery += " DADOS.PED, "
		_cquery += " SUM(DADOS.QTDCX) QTDCX, "
		_cquery += " SUM(DADOS.QTDKG) QTDKG, "
		_cquery += " SUM(DADOS.VALOR) VALOR, "	
		_cquery += " DADOS.VENDEDOR, "
		_cquery += " DADOS.PREAPROV,"
		_cquery += " ISNULL(DADOS.C9PEDIDO,'') C9PEDIDO, "
		_cquery += " ISNULL((SELECT TOP 1 C9_BLCRED FROM "+retsqlname("SC9")+"  SC9 WITH (NOLOCK) WHERE SC9.C9_PEDIDO = DADOS.PED  AND SC9.C9_FILIAL = '02' AND SC9.D_E_L_E_T_ = '' ),'') AS CREDITO, " 
		_cquery += " ISNULL((SELECT TOP 1 C9_BLEST  FROM "+retsqlname("SC9")+"  SC9 WITH (NOLOCK) WHERE SC9.C9_PEDIDO = DADOS.PED  AND SC9.C9_FILIAL = '02' AND SC9.D_E_L_E_T_ = '' ),'') AS ESTOQUE " 

		_cquery += " FROM "
		_cquery += " (SELECT "  
		_cquery += " Distinct(C6_PRODUTO)AS PRODUTO, "  
		_cquery += " C5_VEND1   AS VENDEDOR, " 
		_cquery += " C6_NUM     as PED, "

		_cquery += " (C6_UNSVEN)  as QTDCX, "  
		_cquery += " (C6_QTDVEN)  as QTDKG, "  
		_cquery += " (C6_VALOR)   as VALOR, "  

		_cquery += " (C6_QTDORI)  as KGORI, "  
		_cquery += " (C6_QTDORI2) as CXORI, " 

		_cquery += " C9_PEDIDO AS C9PEDIDO, "

		_cquery += " C5_XPREAPR AS PREAPROV " 

		_cquery += " FROM "+retsqlname("SC6")+"  SC6 WITH (NOLOCK) " 

		_cquery += " LEFT JOIN "+retsqlname("SC9")+"  SC9 WITH (NOLOCK) " 
		_cquery += " ON  SC6.C6_FILIAL = SC9.C9_FILIAL  "  
		_cquery += " AND SC6.C6_NUM    = SC9.C9_PEDIDO "  
		_cquery += " AND SC6.C6_CLI    = SC9.C9_CLIENTE "  
		_cquery += " AND SC6.C6_LOJA   = SC9.C9_LOJA "   
		_cquery += " AND SC9.D_E_L_E_T_ <> '*' " 

		_cquery += " INNER JOIN "+retsqlname("SC5")+"  SC5 WITH (NOLOCK) " 
		_cquery += " ON  SC6.C6_FILIAL  = SC5.C5_FILIAL "  
		_cquery += " AND SC6.C6_NUM     = SC5.C5_NUM "   
		_cquery += " AND SC6.C6_CLI     = SC5.C5_CLIENTE " 
		_cquery += " AND SC6.C6_LOJA    = SC5.C5_LOJACLI "  
		_cquery += " AND SC5.D_E_L_E_T_ <> '*' " 

		_cquery += " INNER JOIN "+retsqlname("SA3")+"  SA3 WITH (NOLOCK) "
		_cquery += " ON SC5.C5_VEND1 = SA3.A3_COD "      
		_cquery += " AND SA3.D_E_L_E_T_ <> '*' "  

		_cquery += " INNER JOIN "+retsqlname("SZR")+"  SZR WITH (NOLOCK) " 
		_cquery += " ON SA3.A3_CODSUP = SZR.ZR_CODIGO  "
		_cquery += " AND SZR.D_E_L_E_T_ <> '*' " 

		_cquery += " WHERE SC6.C6_SEGUM NOT IN ('KG','') "
		_cquery += " AND SC5.C5_FILIAL   = '"+xFilial("SC5")+"'"
		_cquery += " AND SC5.C5_DTENTR   >=  '"+Dtos(Mv_Par01)+"' AND SC5.C5_DTENTR <= '"+Dtos(Mv_Par02)+"'
		_cquery += " AND SC6.D_E_L_E_T_  <> '*' "
		_cquery += " AND SC5.C5_TIPO     =  'N' " 
		_cquery += " AND SC6.C6_UNSVEN   >  0 "
		_cquery += " AND SZR.ZR_SEGMERC  >= '"+Mv_Par05+"' AND SZR.ZR_SEGMERC <= '"+Mv_Par06+"'"
		_cquery += " AND SA3.A3_CODSUP   >= '"+Mv_Par03+"' AND SA3.A3_CODSUP  <= '"+Mv_Par04+"'"
		// Chamado n. 052236 || OS 053576 || ADM || DAVI || 8372 || MONITOR ENTREGAS - FWNM - 14/10/2019
		If MV_PAR07 == 1 // Desconsiderar FOB? = 1 = SIM
			_cquery += " AND SC5.C5_TPFRETE <> 'F' "
		EndIf
		//
		_cquery += " ) as DADOS  "
		_cquery += " GROUP BY PED, VENDEDOR,C9PEDIDO,PREAPROV) AS FONTES "
		_cquery += " ) AS FONTES2 " 
		_cquery += " WHERE "
		_cquery += " FONTES2.SITUACAO = 'PRE-APROVADO' "
		_cquery += " GROUP BY SITUACAO, "
		_cquery += " FONTES2.PED "

		TCQUERY _cquery NEW ALIAS "DETPED"

		DbSelectArea("DETPED")       
		DbGoTop()
		While DETPED->(!Eof())

			cCliente := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_CLIENTE" )
			cLoja    := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_LOJACLI" )
			cCarga   := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_X_SQED" )
			cEndereco:= Posicione("SA1",1,xFilial("SA1") + Alltrim(cCliente)+Alltrim(cLoja), "A1_ENDENT" ) // CHAMADO 049470 ADRIANO S.
			cBairro  := Posicione("SA1",1,xFilial("SA1") + Alltrim(cCliente)+Alltrim(cLoja), "A1_BAIRROE" ) // CHAMADO 049470 ADRIANO S.
			cCidade  := Posicione("SA1",1,xFilial("SA1") + Alltrim(cCliente)+Alltrim(cLoja), "A1_MUNE" ) // CHAMADO 039700 WILL
			
			aAdd(_aDet,{;
			Alltrim(DETPED->PEDIDO),;
			cCliente,;
			cLoja,;
			Posicione("SA1",1,xFilial("SA1") + cCliente + cLoja ,"A1_NOME"),;
			Substr(cCarga,5,6),Transform(DETPED->QTDCX, "@E 999,999,999") ,;
			Transform(DETPED->QTDKG,"@E 999,999,999"),;
			cEndereco,; // CHAMADO 049470 ADRIANO S.
			cBairro,; // CHAMADO 049470 ADRIANO S.
			cCidade,; // CHAMADO 039700 WILL
			})

			DETPED->(dbSkip())

		Enddo

		If Len(_aDet) == 0
			aAdd(_aDet,{"","","","","","","","", })

		Endif
		
	ElseIf nOpc == 3 //William - 18/07/2018. Chamado 039700

		_cquery := ""
		_cquery := " SELECT "  
		_cquery += " FONTES2.PED AS PEDIDO,"
		_cquery += " SUM(FONTES2.QTDCX) AS QTDCX, "
		_cquery += " SUM(FONTES2.QTDKG) AS QTDKG, "
		_cquery += " SUM(FONTES2.VALOR) AS VALOR, "
		_cquery += " FONTES2.SITUACAO AS SITUACAO "
		_cquery += " FROM "
		_cquery += " ( "

		_cquery += " SELECT " 

		_cquery += " FONTES.PED, "
		_cquery += " FONTES.QTDCX, " 
		_cquery += " FONTES.QTDKG, "
		_cquery += " FONTES.VALOR, "

		_cquery += " CASE " 
		//INICIO Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido
		// _cquery += " WHEN FONTES.C9PEDIDO =  '' and FONTES.PREAPROV <> 'L' THEN 'EM ANALISE' "  
		// _cquery += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO NOT IN ('10','') and FONTES.ESTOQUE  = '' THEN 'BLOQ.CREDITO' "
		// _cquery += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO NOT IN ('10','') and FONTES.ESTOQUE <> '' THEN 'BLOQ.CREDITO' " 
		// _cquery += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO = '  ' and FONTES.ESTOQUE <> '' THEN 'BLOQ.ESTOQUE' " 
		_cquery += " WHEN FONTES.C9PEDIDO =  '' and FONTES.PREAPROV <> 'L' THEN 'PRE-APROVADO' "  
		_cquery += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO NOT IN ('10','') and FONTES.ESTOQUE  = '' THEN 'BLOQ.REGRA FINANCEIRA' "
		_cquery += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO NOT IN ('10','') and FONTES.ESTOQUE <> '' THEN 'BLOQ.REGRA FINANCEIRA' " 
		_cquery += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO = '  ' and FONTES.ESTOQUE <> '' THEN 'BLOQ.REGRA ESTOQUE' " 
		//FIM Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido

		_cquery += " ELSE 'LIBERADO'  END 'SITUACAO', "

		_cquery += " FONTES.PREAPROV  "

		_cquery += " FROM "
		_cquery += " ( "

		_cquery += " SELECT "
		_cquery += " DADOS.PED, "
		_cquery += " SUM(DADOS.QTDCX) QTDCX, "
		_cquery += " SUM(DADOS.QTDKG) QTDKG, "
		_cquery += " SUM(DADOS.VALOR) VALOR, "	
		_cquery += " DADOS.VENDEDOR, "
		_cquery += " DADOS.PREAPROV,"
		_cquery += " ISNULL(DADOS.C9PEDIDO,'') C9PEDIDO, "
		_cquery += " ISNULL((SELECT TOP 1 C9_BLCRED FROM "+retsqlname("SC9")+"  SC9 WITH (NOLOCK) WHERE SC9.C9_PEDIDO = DADOS.PED  AND SC9.C9_FILIAL = '02' AND SC9.D_E_L_E_T_ = '' ),'') AS CREDITO, " 
		_cquery += " ISNULL((SELECT TOP 1 C9_BLEST  FROM "+retsqlname("SC9")+"  SC9 WITH (NOLOCK) WHERE SC9.C9_PEDIDO = DADOS.PED  AND SC9.C9_FILIAL = '02' AND SC9.D_E_L_E_T_ = '' ),'') AS ESTOQUE " 

		_cquery += " FROM "
		_cquery += " (SELECT "  
		_cquery += " Distinct(C6_PRODUTO)AS PRODUTO, "  
		_cquery += " C5_VEND1   AS VENDEDOR, " 
		_cquery += " C6_NUM     as PED, "

		_cquery += " (C6_UNSVEN)  as QTDCX, "  
		_cquery += " (C6_QTDVEN)  as QTDKG, "  
		_cquery += " (C6_VALOR)   as VALOR, "  

		_cquery += " (C6_QTDORI)  as KGORI, "  
		_cquery += " (C6_QTDORI2) as CXORI, " 

		_cquery += " C9_PEDIDO AS C9PEDIDO, "

		_cquery += " C5_XPREAPR AS PREAPROV " 

		_cquery += " FROM "+retsqlname("SC6")+"  SC6 WITH (NOLOCK) " 

		_cquery += " LEFT JOIN "+retsqlname("SC9")+"  SC9 WITH (NOLOCK) " 
		_cquery += " ON  SC6.C6_FILIAL = SC9.C9_FILIAL  "  
		_cquery += " AND SC6.C6_NUM    = SC9.C9_PEDIDO "  
		_cquery += " AND SC6.C6_CLI    = SC9.C9_CLIENTE "  
		_cquery += " AND SC6.C6_LOJA   = SC9.C9_LOJA "   
		_cquery += " AND SC9.D_E_L_E_T_ <> '*' " 

		_cquery += " INNER JOIN "+retsqlname("SC5")+"  SC5 WITH (NOLOCK) " 
		_cquery += " ON  SC6.C6_FILIAL  = SC5.C5_FILIAL "  
		_cquery += " AND SC6.C6_NUM     = SC5.C5_NUM "   
		_cquery += " AND SC6.C6_CLI     = SC5.C5_CLIENTE " 
		_cquery += " AND SC6.C6_LOJA    = SC5.C5_LOJACLI "  
		_cquery += " AND SC5.D_E_L_E_T_ <> '*' " 

		_cquery += " INNER JOIN "+retsqlname("SA3")+"  SA3 WITH (NOLOCK) "
		_cquery += " ON SC5.C5_VEND1 = SA3.A3_COD "      
		_cquery += " AND SA3.D_E_L_E_T_ <> '*' "  

		_cquery += " INNER JOIN "+retsqlname("SZR")+"  SZR WITH (NOLOCK) " 
		_cquery += " ON SA3.A3_CODSUP = SZR.ZR_CODIGO  "
		_cquery += " AND SZR.D_E_L_E_T_ <> '*' " 

		_cquery += " WHERE SC6.C6_SEGUM NOT IN ('KG','') "
		_cquery += " AND SC5.C5_FILIAL   = '"+xFilial("SC5")+"'"
		_cquery += " AND SC5.C5_DTENTR   >=  '"+Dtos(Mv_Par01)+"' AND SC5.C5_DTENTR <= '"+Dtos(Mv_Par02)+"'
		_cquery += " AND SC6.D_E_L_E_T_  <> '*' "
		_cquery += " AND SC5.C5_TIPO     =  'N' " 
		_cquery += " AND SC6.C6_UNSVEN   >  0 "
		_cquery += " AND SZR.ZR_SEGMERC  >= '"+Mv_Par05+"' AND SZR.ZR_SEGMERC <= '"+Mv_Par06+"'"
		_cquery += " AND SA3.A3_CODSUP   >= '"+Mv_Par03+"' AND SA3.A3_CODSUP  <= '"+Mv_Par04+"'"
		// Chamado n. 052236 || OS 053576 || ADM || DAVI || 8372 || MONITOR ENTREGAS - FWNM - 14/10/2019
		If MV_PAR07 == 1 // Desconsiderar FOB? = 1 = SIM
			_cquery += " AND SC5.C5_TPFRETE <> 'F' "
		EndIf
		//
		_cquery += " ) as DADOS  "
		_cquery += " GROUP BY PED, VENDEDOR,C9PEDIDO,PREAPROV) AS FONTES "
		_cquery += " ) AS FONTES2 " 
		_cquery += " WHERE "
		_cquery += " FONTES2.SITUACAO = 'BLOQ.REGRA FINANCEIRA' "
		_cquery += " GROUP BY SITUACAO, "
		_cquery += " FONTES2.PED "

		TCQUERY _cquery NEW ALIAS "DETPED"

		DbSelectArea("DETPED")       
		DbGoTop()
		While DETPED->(!Eof())

			cCliente := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_CLIENTE" )
			cLoja    := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_LOJACLI" )
			cCarga   := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_X_SQED" )
			cEndereco:= Posicione("SA1",1,xFilial("SA1") + Alltrim(cCliente)+Alltrim(cLoja), "A1_ENDENT" ) // CHAMADO 049470 ADRIANO S.
			cBairro  := Posicione("SA1",1,xFilial("SA1") + Alltrim(cCliente)+Alltrim(cLoja), "A1_BAIRROE" ) // CHAMADO 049470 ADRIANO S.
			cCidade  := Posicione("SA1",1,xFilial("SA1") + Alltrim(cCliente)+Alltrim(cLoja), "A1_MUNE" ) // CHAMADO 039700 WILL
			
			aAdd(_aDet,{;
			Alltrim(DETPED->PEDIDO),;
			cCliente,;
			cLoja,;
			Posicione("SA1",1,xFilial("SA1") + cCliente + cLoja ,"A1_NOME"),;
			Substr(cCarga,5,6),Transform(DETPED->QTDCX, "@E 999,999,999") ,;
			Transform(DETPED->QTDKG,"@E 999,999,999"),;
			cEndereco,; // CHAMADO 049470 ADRIANO S.
			cBairro,; // CHAMADO 049470 ADRIANO S.
			cCidade,; // CHAMADO 039700 WILL
			})

			DETPED->(dbSkip())

		Enddo

		If Len(_aDet) == 0
			aAdd(_aDet,{"","","","","","","","", })

		Endif
	
	//INICIO Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido e acrescentar nOpc = 4 (pedidos Bloqueador por Regra)
	ElseIf nOpc == 4 

		_cquery := ""
		_cquery := " SELECT "  
		_cquery += " FONTES2.PED AS PEDIDO,"
		_cquery += " SUM(FONTES2.QTDCX) AS QTDCX, "
		_cquery += " SUM(FONTES2.QTDKG) AS QTDKG, "
		_cquery += " SUM(FONTES2.VALOR) AS VALOR, "
		_cquery += " FONTES2.SITUACAO AS SITUACAO "
		_cquery += " FROM "
		_cquery += " ( "

		_cquery += " SELECT " 

		_cquery += " FONTES.PED, "
		_cquery += " FONTES.QTDCX, " 
		_cquery += " FONTES.QTDKG, "
		_cquery += " FONTES.VALOR, "

		_cquery += " CASE " 
		_cquery += " WHEN FONTES.C9PEDIDO =  '' and FONTES.PREAPROV <> 'L' THEN 'PRE-APROVADO' "  
		_cquery += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO NOT IN ('10','') and FONTES.ESTOQUE  = '' THEN 'BLOQ.REGRA FINANCEIRA' "
		_cquery += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO NOT IN ('10','') and FONTES.ESTOQUE <> '' THEN 'BLOQ.REGRA FINANCEIRA' " 
		_cquery += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO = '  ' and FONTES.ESTOQUE <> '' THEN 'BLOQ.REGRA ESTOQUE' " 
		_cquery += " WHEN FONTES.C9PEDIDO = '' and FONTES.C5BLQ <> '' THEN 'BLOQ.REGRA COMERCIAL' " 

		_cquery += " ELSE 'LIBERADO'  END 'SITUACAO', "

		_cquery += " FONTES.PREAPROV  "

		_cquery += " FROM "
		_cquery += " ( "

		_cquery += " SELECT "
		_cquery += " DADOS.PED, "
		_cquery += " SUM(DADOS.QTDCX) QTDCX, "
		_cquery += " SUM(DADOS.QTDKG) QTDKG, "
		_cquery += " SUM(DADOS.VALOR) VALOR, "	
		_cquery += " DADOS.VENDEDOR, "
		_cquery += " DADOS.PREAPROV, "
		_cquery += " DADOS.C5BLQ, "
		_cquery += " ISNULL(DADOS.C9PEDIDO,'') C9PEDIDO, "
		_cquery += " ISNULL((SELECT TOP 1 C9_BLCRED FROM "+retsqlname("SC9")+"  SC9 WITH (NOLOCK) WHERE SC9.C9_PEDIDO = DADOS.PED  AND SC9.C9_FILIAL = '02' AND SC9.D_E_L_E_T_ = '' ),'') AS CREDITO, " 
		_cquery += " ISNULL((SELECT TOP 1 C9_BLEST  FROM "+retsqlname("SC9")+"  SC9 WITH (NOLOCK) WHERE SC9.C9_PEDIDO = DADOS.PED  AND SC9.C9_FILIAL = '02' AND SC9.D_E_L_E_T_ = '' ),'') AS ESTOQUE " 

		_cquery += " FROM "
		_cquery += " (SELECT "  
		_cquery += " Distinct(C6_PRODUTO)AS PRODUTO, "  
		_cquery += " C5_VEND1   AS VENDEDOR, " 
		_cquery += " C6_NUM     as PED, "

		_cquery += " (C6_UNSVEN)  as QTDCX, "  
		_cquery += " (C6_QTDVEN)  as QTDKG, "  
		_cquery += " (C6_VALOR)   as VALOR, "  

		_cquery += " (C6_QTDORI)  as KGORI, "  
		_cquery += " (C6_QTDORI2) as CXORI, " 

		_cquery += " C9_PEDIDO AS C9PEDIDO, "

		_cquery += " C5_BLQ AS C5BLQ, " 

		_cquery += " C5_XPREAPR AS PREAPROV " 

		_cquery += " FROM "+retsqlname("SC6")+"  SC6 WITH (NOLOCK) " 

		_cquery += " LEFT JOIN "+retsqlname("SC9")+"  SC9 WITH (NOLOCK) " 
		_cquery += " ON  SC6.C6_FILIAL = SC9.C9_FILIAL  "  
		_cquery += " AND SC6.C6_NUM    = SC9.C9_PEDIDO "  
		_cquery += " AND SC6.C6_CLI    = SC9.C9_CLIENTE "  
		_cquery += " AND SC6.C6_LOJA   = SC9.C9_LOJA "   
		_cquery += " AND SC9.D_E_L_E_T_ <> '*' " 

		_cquery += " INNER JOIN "+retsqlname("SC5")+"  SC5 WITH (NOLOCK) " 
		_cquery += " ON  SC6.C6_FILIAL  = SC5.C5_FILIAL "  
		_cquery += " AND SC6.C6_NUM     = SC5.C5_NUM "   
		_cquery += " AND SC6.C6_CLI     = SC5.C5_CLIENTE " 
		_cquery += " AND SC6.C6_LOJA    = SC5.C5_LOJACLI "  
		_cquery += " AND SC5.D_E_L_E_T_ <> '*' " 

		_cquery += " INNER JOIN "+retsqlname("SA3")+"  SA3 WITH (NOLOCK) "
		_cquery += " ON SC5.C5_VEND1 = SA3.A3_COD "      
		_cquery += " AND SA3.D_E_L_E_T_ <> '*' "  

		_cquery += " INNER JOIN "+retsqlname("SZR")+"  SZR WITH (NOLOCK) " 
		_cquery += " ON SA3.A3_CODSUP = SZR.ZR_CODIGO  "
		_cquery += " AND SZR.D_E_L_E_T_ <> '*' " 

		_cquery += " WHERE SC6.C6_SEGUM NOT IN ('KG','') "
		_cquery += " AND SC5.C5_FILIAL   = '"+xFilial("SC5")+"'"
		_cquery += " AND SC5.C5_DTENTR   >=  '"+Dtos(Mv_Par01)+"' AND SC5.C5_DTENTR <= '"+Dtos(Mv_Par02)+"'
		_cquery += " AND SC6.D_E_L_E_T_  <> '*' "
		_cquery += " AND SC5.C5_TIPO     =  'N' " 
		_cquery += " AND SC5.C5_BLQ     IN  ('1','2') " 
		_cquery += " AND SC6.C6_UNSVEN   >  0 "
		_cquery += " AND SZR.ZR_SEGMERC  >= '"+Mv_Par05+"' AND SZR.ZR_SEGMERC <= '"+Mv_Par06+"'"
		_cquery += " AND SA3.A3_CODSUP   >= '"+Mv_Par03+"' AND SA3.A3_CODSUP  <= '"+Mv_Par04+"'"
		If MV_PAR07 == 1 // Desconsiderar FOB? = 1 = SIM
			_cquery += " AND SC5.C5_TPFRETE <> 'F' "
		EndIf
		//
		_cquery += " ) as DADOS  "
		_cquery += " GROUP BY PED, VENDEDOR,C9PEDIDO,PREAPROV,C5BLQ) AS FONTES "
		_cquery += " ) AS FONTES2 " 
		_cquery += " WHERE "
		_cquery += " FONTES2.SITUACAO = 'BLOQ.REGRA COMERCIAL' "
		_cquery += " GROUP BY SITUACAO, "
		_cquery += " FONTES2.PED "

		TCQUERY _cquery NEW ALIAS "DETPED"

		DbSelectArea("DETPED")       
		DbGoTop()
		While DETPED->(!Eof())

			cCliente := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_CLIENTE" )
			cLoja    := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_LOJACLI" )
			cCarga   := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_X_SQED" )
			cEndereco:= Posicione("SA1",1,xFilial("SA1") + Alltrim(cCliente)+Alltrim(cLoja), "A1_ENDENT" ) // CHAMADO 049470 ADRIANO S.
			cBairro  := Posicione("SA1",1,xFilial("SA1") + Alltrim(cCliente)+Alltrim(cLoja), "A1_BAIRROE" ) // CHAMADO 049470 ADRIANO S.
			cCidade  := Posicione("SA1",1,xFilial("SA1") + Alltrim(cCliente)+Alltrim(cLoja), "A1_MUNE" ) // CHAMADO 039700 WILL
			
			aAdd(_aDet,{;
			Alltrim(DETPED->PEDIDO),;
			cCliente,;
			cLoja,;
			Posicione("SA1",1,xFilial("SA1") + cCliente + cLoja ,"A1_NOME"),;
			Substr(cCarga,5,6),Transform(DETPED->QTDCX, "@E 999,999,999") ,;
			Transform(DETPED->QTDKG,"@E 999,999,999"),;
			cEndereco,; // CHAMADO 049470 ADRIANO S.
			cBairro,; // CHAMADO 049470 ADRIANO S.
			cCidade,; // CHAMADO 039700 WILL
			})

			DETPED->(dbSkip())

		Enddo

		If Len(_aDet) == 0
			aAdd(_aDet,{"","","","","","","","","", })

		Endif
	
	ElseIf nOpc == 5

		_cquery := ""
		_cquery := " SELECT "  
		_cquery += " FONTES2.PED AS PEDIDO,"
		_cquery += " SUM(FONTES2.QTDCX) AS QTDCX, "
		_cquery += " SUM(FONTES2.QTDKG) AS QTDKG, "
		_cquery += " SUM(FONTES2.VALOR) AS VALOR, "
		_cquery += " FONTES2.SITUACAO AS SITUACAO "
		_cquery += " FROM "
		_cquery += " ( "

		_cquery += " SELECT " 

		_cquery += " FONTES.PED, "
		_cquery += " FONTES.QTDCX, " 
		_cquery += " FONTES.QTDKG, "
		_cquery += " FONTES.VALOR, "

		_cquery += " CASE " 
		_cquery += " WHEN FONTES.C9PEDIDO =  '' and FONTES.PREAPROV <> 'L' THEN 'PRE-APROVADO' "  
		_cquery += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO NOT IN ('10','') and FONTES.ESTOQUE  = '' THEN 'BLOQ.REGRA FINANCEIRA' "
		_cquery += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO NOT IN ('10','') and FONTES.ESTOQUE <> '' THEN 'BLOQ.REGRA FINANCEIRA' " 
		_cquery += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO = '  ' and FONTES.ESTOQUE <> '' THEN 'BLOQ.REGRA ESTOQUE' " 

		_cquery += " ELSE 'LIBERADO'  END 'SITUACAO', "

		_cquery += " FONTES.PREAPROV  "

		_cquery += " FROM "
		_cquery += " ( "

		_cquery += " SELECT "
		_cquery += " DADOS.PED, "
		_cquery += " SUM(DADOS.QTDCX) QTDCX, "
		_cquery += " SUM(DADOS.QTDKG) QTDKG, "
		_cquery += " SUM(DADOS.VALOR) VALOR, "	
		_cquery += " DADOS.VENDEDOR, "
		_cquery += " DADOS.PREAPROV,"
		_cquery += " ISNULL(DADOS.C9PEDIDO,'') C9PEDIDO, "
		_cquery += " ISNULL((SELECT TOP 1 C9_BLCRED FROM "+retsqlname("SC9")+"  SC9 WITH (NOLOCK) WHERE SC9.C9_PEDIDO = DADOS.PED  AND SC9.C9_FILIAL = '02' AND SC9.D_E_L_E_T_ = '' ),'') AS CREDITO, " 
		_cquery += " ISNULL((SELECT TOP 1 C9_BLEST  FROM "+retsqlname("SC9")+"  SC9 WITH (NOLOCK) WHERE SC9.C9_PEDIDO = DADOS.PED  AND SC9.C9_FILIAL = '02' AND SC9.D_E_L_E_T_ = '' ),'') AS ESTOQUE " 

		_cquery += " FROM "
		_cquery += " (SELECT "  
		_cquery += " Distinct(C6_PRODUTO)AS PRODUTO, "  
		_cquery += " C5_VEND1   AS VENDEDOR, " 
		_cquery += " C6_NUM     as PED, "

		_cquery += " (C6_UNSVEN)  as QTDCX, "  
		_cquery += " (C6_QTDVEN)  as QTDKG, "  
		_cquery += " (C6_VALOR)   as VALOR, "  

		_cquery += " (C6_QTDORI)  as KGORI, "  
		_cquery += " (C6_QTDORI2) as CXORI, " 

		_cquery += " C9_PEDIDO AS C9PEDIDO, "

		_cquery += " C5_XPREAPR AS PREAPROV " 

		_cquery += " FROM "+retsqlname("SC6")+"  SC6 WITH (NOLOCK) " 

		_cquery += " LEFT JOIN "+retsqlname("SC9")+"  SC9 WITH (NOLOCK) " 
		_cquery += " ON  SC6.C6_FILIAL = SC9.C9_FILIAL  "  
		_cquery += " AND SC6.C6_NUM    = SC9.C9_PEDIDO "  
		_cquery += " AND SC6.C6_CLI    = SC9.C9_CLIENTE "  
		_cquery += " AND SC6.C6_LOJA   = SC9.C9_LOJA "   
		_cquery += " AND SC9.D_E_L_E_T_ <> '*' " 

		_cquery += " INNER JOIN "+retsqlname("SC5")+"  SC5 WITH (NOLOCK) " 
		_cquery += " ON  SC6.C6_FILIAL  = SC5.C5_FILIAL "  
		_cquery += " AND SC6.C6_NUM     = SC5.C5_NUM "   
		_cquery += " AND SC6.C6_CLI     = SC5.C5_CLIENTE " 
		_cquery += " AND SC6.C6_LOJA    = SC5.C5_LOJACLI "  
		_cquery += " AND SC5.D_E_L_E_T_ <> '*' " 

		_cquery += " INNER JOIN "+retsqlname("SA3")+"  SA3 WITH (NOLOCK) "
		_cquery += " ON SC5.C5_VEND1 = SA3.A3_COD "      
		_cquery += " AND SA3.D_E_L_E_T_ <> '*' "  

		_cquery += " INNER JOIN "+retsqlname("SZR")+"  SZR WITH (NOLOCK) " 
		_cquery += " ON SA3.A3_CODSUP = SZR.ZR_CODIGO  "
		_cquery += " AND SZR.D_E_L_E_T_ <> '*' " 

		_cquery += " WHERE SC6.C6_SEGUM NOT IN ('KG','') "
		_cquery += " AND SC5.C5_FILIAL   = '"+xFilial("SC5")+"'"
		_cquery += " AND SC5.C5_DTENTR   >=  '"+Dtos(Mv_Par01)+"' AND SC5.C5_DTENTR <= '"+Dtos(Mv_Par02)+"'
		_cquery += " AND SC6.D_E_L_E_T_  <> '*' "
		_cquery += " AND SC5.C5_TIPO     =  'N' " 
		_cquery += " AND SC6.C6_UNSVEN   >  0 "
		_cquery += " AND SZR.ZR_SEGMERC  >= '"+Mv_Par05+"' AND SZR.ZR_SEGMERC <= '"+Mv_Par06+"'"
		_cquery += " AND SA3.A3_CODSUP   >= '"+Mv_Par03+"' AND SA3.A3_CODSUP  <= '"+Mv_Par04+"'"
		// Chamado n. 052236 || OS 053576 || ADM || DAVI || 8372 || MONITOR ENTREGAS - FWNM - 14/10/2019
		If MV_PAR07 == 1 // Desconsiderar FOB? = 1 = SIM
			_cquery += " AND SC5.C5_TPFRETE <> 'F' "
		EndIf
		//
		_cquery += " ) as DADOS  "
		_cquery += " GROUP BY PED, VENDEDOR,C9PEDIDO,PREAPROV) AS FONTES "
		_cquery += " ) AS FONTES2 " 
		_cquery += " WHERE "
		_cquery += " FONTES2.SITUACAO = 'BLOQ.REGRA ESTOQUE' "
		_cquery += " GROUP BY SITUACAO, "
		_cquery += " FONTES2.PED "

		TCQUERY _cquery NEW ALIAS "DETPED"

		DbSelectArea("DETPED")       
		DbGoTop()
		While DETPED->(!Eof())

			cCliente := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_CLIENTE" )
			cLoja    := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_LOJACLI" )
			cCarga   := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_X_SQED" )
			cEndereco:= Posicione("SA1",1,xFilial("SA1") + Alltrim(cCliente)+Alltrim(cLoja), "A1_ENDENT" ) // CHAMADO 049470 ADRIANO S.
			cBairro  := Posicione("SA1",1,xFilial("SA1") + Alltrim(cCliente)+Alltrim(cLoja), "A1_BAIRROE" ) // CHAMADO 049470 ADRIANO S.
			cCidade  := Posicione("SA1",1,xFilial("SA1") + Alltrim(cCliente)+Alltrim(cLoja), "A1_MUNE" ) // CHAMADO 039700 WILL
			
			aAdd(_aDet,{;
			Alltrim(DETPED->PEDIDO),;
			cCliente,;
			cLoja,;
			Posicione("SA1",1,xFilial("SA1") + cCliente + cLoja ,"A1_NOME"),;
			Substr(cCarga,5,6),Transform(DETPED->QTDCX, "@E 999,999,999") ,;
			Transform(DETPED->QTDKG,"@E 999,999,999"),;
			cEndereco,; // CHAMADO 049470 ADRIANO S.
			cBairro,; // CHAMADO 049470 ADRIANO S.
			cCidade,; // CHAMADO 039700 WILL
			})

			DETPED->(dbSkip())

		Enddo

		If Len(_aDet) == 0
			//aAdd(_aDet,{"","","","","","","","", })

			// @history ticket 9930 - Macieira   , 23/02/2021, array out of bounds ( 10 of 9 )  on { || {_aDet[oDet:nAt,1],_aDet[oDet:nAt][2],_aDet[oDet:nAt][3],_aDet[oDet:nAt][4],_aDet[oDet:nAt][5],_aDet[oDet:nAt][6],_aDet[oDet:nAt][7],_aDet[oDet:nAt][8],_aDet[oDet:nAt][9],_aDet[oDet:nAt][10]}}(ADLOG031P.PRW) 14/09/2020 08:37:18 line : 367
			aAdd(_aDet,{;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",; 
				"",; 
				"",; 
				})
		Endif
		//FIM Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido e acrescentar nOpc = 4 (pedidos Bloqueador por Regra)
	//TICKET 10851 - ADRIANO SAVOINE - 19/03/2021
	ElseIf nOpc == 6

		_cquery := ""
		_cquery := " SELECT "  
		_cquery += " FONTES2.PED AS PEDIDO,"
		_cquery += " SUM(FONTES2.QTDCX) AS QTDCX, "
		_cquery += " SUM(FONTES2.QTDKG) AS QTDKG, "
		_cquery += " SUM(FONTES2.VALOR) AS VALOR, "
		_cquery += " FONTES2.SITUACAO AS SITUACAO "
		_cquery += " FROM "
		_cquery += " ( "

		_cquery += " SELECT " 

		_cquery += " FONTES.PED, "
		_cquery += " FONTES.QTDCX, " 
		_cquery += " FONTES.QTDKG, "
		_cquery += " FONTES.VALOR, "

		_cquery += " CASE " 
		_cquery += " WHEN FONTES.C9PEDIDO =  '' and FONTES.PREAPROV <> 'L' THEN 'PRE-APROVADO' "  
		_cquery += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO NOT IN ('10','') and FONTES.ESTOQUE  = '' THEN 'BLOQ.REGRA FINANCEIRA' "
		_cquery += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO NOT IN ('10','') and FONTES.ESTOQUE <> '' THEN 'BLOQ.REGRA FINANCEIRA' " 
		_cquery += " WHEN FONTES.C9PEDIDO <> '' and FONTES.CREDITO = '  ' and FONTES.ESTOQUE <> '' THEN 'BLOQ.REGRA ESTOQUE' " 

		_cquery += " ELSE 'LIBERADO'  END 'SITUACAO', "

		_cquery += " FONTES.PREAPROV  "

		_cquery += " FROM "
		_cquery += " ( "

		_cquery += " SELECT "
		_cquery += " DADOS.PED, "
		_cquery += " SUM(DADOS.QTDCX) QTDCX, "
		_cquery += " SUM(DADOS.QTDKG) QTDKG, "
		_cquery += " SUM(DADOS.VALOR) VALOR, "	
		_cquery += " DADOS.VENDEDOR, "
		_cquery += " DADOS.PREAPROV,"
		_cquery += " ISNULL(DADOS.C9PEDIDO,'') C9PEDIDO, "
		_cquery += " ISNULL((SELECT TOP 1 C9_BLCRED FROM "+retsqlname("SC9")+"  SC9 WITH (NOLOCK) WHERE SC9.C9_PEDIDO = DADOS.PED  AND SC9.C9_FILIAL = '02' AND SC9.D_E_L_E_T_ = '' ),'') AS CREDITO, " 
		_cquery += " ISNULL((SELECT TOP 1 C9_BLEST  FROM "+retsqlname("SC9")+"  SC9 WITH (NOLOCK) WHERE SC9.C9_PEDIDO = DADOS.PED  AND SC9.C9_FILIAL = '02' AND SC9.D_E_L_E_T_ = '' ),'') AS ESTOQUE " 

		_cquery += " FROM "
		_cquery += " (SELECT "  
		_cquery += " Distinct(C6_PRODUTO)AS PRODUTO, "  
		_cquery += " C5_VEND1   AS VENDEDOR, " 
		_cquery += " C6_NUM     as PED, "

		_cquery += " (C6_UNSVEN)  as QTDCX, "  
		_cquery += " (C6_QTDVEN)  as QTDKG, "  
		_cquery += " (C6_VALOR)   as VALOR, "  

		_cquery += " (C6_QTDORI)  as KGORI, "  
		_cquery += " (C6_QTDORI2) as CXORI, " 

		_cquery += " C9_PEDIDO AS C9PEDIDO, "

		_cquery += " C5_XPREAPR AS PREAPROV " 

		_cquery += " FROM "+retsqlname("SC6")+"  SC6 WITH (NOLOCK) " 

		_cquery += " LEFT JOIN "+retsqlname("SC9")+"  SC9 WITH (NOLOCK) " 
		_cquery += " ON  SC6.C6_FILIAL = SC9.C9_FILIAL  "  
		_cquery += " AND SC6.C6_NUM    = SC9.C9_PEDIDO "  
		_cquery += " AND SC6.C6_CLI    = SC9.C9_CLIENTE "  
		_cquery += " AND SC6.C6_LOJA   = SC9.C9_LOJA "   
		_cquery += " AND SC9.D_E_L_E_T_ <> '*' " 

		_cquery += " INNER JOIN "+retsqlname("SC5")+"  SC5 WITH (NOLOCK) " 
		_cquery += " ON  SC6.C6_FILIAL  = SC5.C5_FILIAL "  
		_cquery += " AND SC6.C6_NUM     = SC5.C5_NUM "   
		_cquery += " AND SC6.C6_CLI     = SC5.C5_CLIENTE " 
		_cquery += " AND SC6.C6_LOJA    = SC5.C5_LOJACLI "  
		_cquery += " AND SC5.D_E_L_E_T_ <> '*' " 

		_cquery += " INNER JOIN "+retsqlname("SA3")+"  SA3 WITH (NOLOCK) "
		_cquery += " ON SC5.C5_VEND1 = SA3.A3_COD "      
		_cquery += " AND SA3.D_E_L_E_T_ <> '*' "  

		_cquery += " INNER JOIN "+retsqlname("SZR")+"  SZR WITH (NOLOCK) " 
		_cquery += " ON SA3.A3_CODSUP = SZR.ZR_CODIGO  "
		_cquery += " AND SZR.D_E_L_E_T_ <> '*' " 

		_cquery += " WHERE SC6.C6_SEGUM NOT IN ('KG','') "
		_cquery += " AND SC5.C5_FILIAL   = '"+xFilial("SC5")+"'"
		_cquery += " AND SC5.C5_DTENTR   >=  '"+Dtos(Mv_Par01)+"' AND SC5.C5_DTENTR <= '"+Dtos(Mv_Par02)+"'
		_cquery += " AND SC6.D_E_L_E_T_  <> '*' "
		_cquery += " AND SC5.C5_TIPO     =  'N' " 
		_cquery += " AND SC5.C5_BLQ      =  '' "
		_cquery += " AND SC6.C6_UNSVEN   >  0 "
		_cquery += " AND SZR.ZR_SEGMERC  >= '"+Mv_Par05+"' AND SZR.ZR_SEGMERC <= '"+Mv_Par06+"'"
		_cquery += " AND SA3.A3_CODSUP   >= '"+Mv_Par03+"' AND SA3.A3_CODSUP  <= '"+Mv_Par04+"'"
		// Chamado n. 052236 || OS 053576 || ADM || DAVI || 8372 || MONITOR ENTREGAS - FWNM - 14/10/2019
		If MV_PAR07 == 1 // Desconsiderar FOB? = 1 = SIM
			_cquery += " AND SC5.C5_TPFRETE <> 'F' "
		EndIf
		//
		_cquery += " ) as DADOS  "
		_cquery += " GROUP BY PED, VENDEDOR,C9PEDIDO,PREAPROV) AS FONTES "
		_cquery += " ) AS FONTES2 " 
		_cquery += " WHERE "
		_cquery += " FONTES2.SITUACAO = 'LIBERADO' "
		_cquery += " GROUP BY SITUACAO, "
		_cquery += " FONTES2.PED "

		TCQUERY _cquery NEW ALIAS "DETPED"

		DbSelectArea("DETPED")       
		DbGoTop()
		While DETPED->(!Eof())

			cCliente := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_CLIENTE" )
			cLoja    := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_LOJACLI" )
			cCarga   := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_X_SQED" )
			cEndereco:= Posicione("SA1",1,xFilial("SA1") + Alltrim(cCliente)+Alltrim(cLoja), "A1_ENDENT" ) // CHAMADO 049470 ADRIANO S.
			cBairro  := Posicione("SA1",1,xFilial("SA1") + Alltrim(cCliente)+Alltrim(cLoja), "A1_BAIRROE" ) // CHAMADO 049470 ADRIANO S.
			cCidade  := Posicione("SA1",1,xFilial("SA1") + Alltrim(cCliente)+Alltrim(cLoja), "A1_MUNE" ) // CHAMADO 039700 WILL
			
			aAdd(_aDet,{;
			Alltrim(DETPED->PEDIDO),;
			cCliente,;
			cLoja,;
			Posicione("SA1",1,xFilial("SA1") + cCliente + cLoja ,"A1_NOME"),;
			Substr(cCarga,5,6),Transform(DETPED->QTDCX, "@E 999,999,999") ,;
			Transform(DETPED->QTDKG,"@E 999,999,999"),;
			cEndereco,; // CHAMADO 049470 ADRIANO S.
			cBairro,; // CHAMADO 049470 ADRIANO S.
			cCidade,; // CHAMADO 039700 WILL
			})

			DETPED->(dbSkip())

		Enddo

		If Len(_aDet) == 0
			//aAdd(_aDet,{"","","","","","","","", })

			// @history ticket 9930 - Macieira   , 23/02/2021, array out of bounds ( 10 of 9 )  on { || {_aDet[oDet:nAt,1],_aDet[oDet:nAt][2],_aDet[oDet:nAt][3],_aDet[oDet:nAt][4],_aDet[oDet:nAt][5],_aDet[oDet:nAt][6],_aDet[oDet:nAt][7],_aDet[oDet:nAt][8],_aDet[oDet:nAt][9],_aDet[oDet:nAt][10]}}(ADLOG031P.PRW) 14/09/2020 08:37:18 line : 367
			aAdd(_aDet,{;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",; 
				"",; 
				"",; 
				})
		Endif
		//FIM Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido e acrescentar nOpc = 4 (pedidos Bloqueador por Regra)
	
	EndIf

	oDet:SetArray(_aDet)
	oDet:bLine := bLine
	oDet:GoBottom()
	oDet:Refresh() 

	RestArea(aArea)

Return Nil  
/*/{Protheus.doc} AD031EXC
	
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static Function AD031EXC(nOpc)

	//Variáveis.
	Private oExcel      := FWMSEXCEL():New()
	Private cPath       := 'D:\Totvs\Protheus11_Homolog\protheus_data\system\'
	Private oMsExcel

	Private aLinhas     := {}

	Private cArquivo    := ""
	Private cPlanilha   := ""
	Private cTitulo     := ""

	If nOpc == 1
		cArquivo    := 'REL_CORTE_EXPED.XML'
		cPlanilha   := "Pedidos Cortados"
		cTitulo     := "Rel.Pedidos Cortados"

	ElseIf nOpc == 2
		cArquivo    := 'REL_EM_ANALISE.XML'
		cPlanilha   := "Pedidos Em Análise"
		cTitulo     := "Rel.Pedidos Em Análise"

	ElseIf nOpc == 3 //Everson - 17/07/2020. Chamado 059728.
		cArquivo    := 'REL_BLOQ_CREDITO.XML'
		cPlanilha   := "Pedidos Bloqueados Crédito"
		cTitulo     := "Rel.Pedidos Bloqueados Crédito"

	//Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido e acrescentar nOpc = 4 (pedidos Bloqueador por Regra)
	ElseIf nOpc == 4 
		cArquivo    := 'REL_BLOQ_COMERCIAL.XML'
		cPlanilha   := "Pedidos Bloqueados Comercial"
		cTitulo     := "Rel.Pedidos Bloqueados Comercial"

	ElseIf nOpc == 5
		cArquivo    := 'REL_BLOQ_ESTOQUE.XML'
		cPlanilha   := "Pedidos Bloqueados Estoque"
		cTitulo     := "Rel.Pedidos Bloqueados Estoque"

	//Ticket 10851 - ADRIANO SAVOINE - 19/03/2021
	ElseIf nOpc == 6
		cArquivo    := 'REL_PEDIDOS_LIBERADOS.XML'
		cPlanilha   := "Pedidos Liberados"
		cTitulo     := "Rel.Pedidos Liberados"	

	EndIf

	BEGIN SEQUENCE

		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
			Alert("Não Existe Excel Instalado")
			BREAK
		EndIF

		Cabec(nOpc)             
		GeraExcel(nOpc)

		SalvaXml(nOpc)
		CriaExcel(nOpc)

		MsgInfo("Arquivo Excel gerado!")    

	END SEQUENCE

Return Nil 
/*/{Protheus.doc} GeraExcel
	
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static Function GeraExcel(nOpc)

	//Variáveis.
	Local aArea		  := GetArea()
	//Local cNomeRegiao := ''
	Local nLinha      := 0
	Local nExcel      := 0 
	Local nTotReg	  := 0
	Local cNumPV      := ''
	Local cCliente    := ""
	Local cLoja       := ""

	//Conta o Total de registros.
	nTotReg := Contar("DETPED","!Eof()")

	//Atribui a quantidade de registros à régua de processamento.
	ProcRegua(nTotReg)
	DBSELECTAREA("DETPED")
	DETPED->(DBGOTOP())
	WHILE DETPED->(!EOF())

		cNumPV := Alltrim(cValToChar(DETPED->PEDIDO ))
		
		//
		If nOpc == 1
			IncProc("Processando Ped.Cortado. "+cNumPV)
		
		ElseIf nOpc == 2
			IncProc("Processando Ped. Pre-aprovados. "+cNumPV) //INICIO Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido

		ElseIf nOpc == 3 //Everson - 17/07/2020. Chamado 059728.
			IncProc("Processando Ped. bloqueados por regra financeira. "+cNumPV) //INICIO Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido

		//Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido e acrescentar nOpc = 4 (pedidos Bloqueador por Regra)
		ElseIf nOpc == 4
			IncProc("Processando Ped. bloqueados por regra comercial. "+cNumPV) //INICIO Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido

		ElseIf nOpc == 5
			IncProc("Processando Ped. bloqueados por estoque. "+cNumPV) //INICIO Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido
		
		ElseIf nOpc == 6
			IncProc("Processando Ped. Liberados. "+cNumPV)
		EndIf  

		nLinha  := nLinha + 1                                       

		//===================== INICIO CRIA VETOR COM POSICAO VAZIA 
		
		//
		If nOpc == 1
		
			AADD(aLinhas,{ "", ; // 01 A  
				"", ; // 02 B   
				"", ; // 03 C  
				"", ; // 04 D  
				"", ; // 05 E  
				"", ; // 06 F   
				"", ; // 07 G  
				"", ; // 08 H 
				"";   // 09 I 
				})
				
		ElseIf nOpc == 2
		
			AADD(aLinhas,{ "", ; // 01 A  
				"", ; // 02 B   
				"", ; // 03 C  
				"", ; // 04 D  
				"", ; // 05 E  
				"", ; // 06 F
				"", ; // 04 G  
				"", ; // 05 H  
				"", ; // 06 I     
				""  ; // 07 J  
				})

		ElseIf nOpc == 3 //Everson - 17/07/2020. Chamado 059728.
		
			AADD(aLinhas,{ "", ; // 01 A  
				"", ; // 02 B   
				"", ; // 03 C  
				"", ; // 04 D  
				"", ; // 05 E  
				"", ; // 06 F
				"", ; // 04 G  
				"", ; // 05 H  
				"", ; // 06 I     
				""  ; // 07 J  
				})
		
		//Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido e acrescentar nOpc = 4 (pedidos Bloqueador por Regra)
		ElseIf nOpc == 4
		
			AADD(aLinhas,{ "", ; // 01 A  
				"", ; // 02 B   
				"", ; // 03 C  
				"", ; // 04 D  
				"", ; // 05 E  
				"", ; // 06 F
				"", ; // 04 G  
				"", ; // 05 H  
				"", ; // 06 I     
				""  ; // 07 J  
				})
		ElseIf nOpc == 5
		
			AADD(aLinhas,{ "", ; // 01 A  
				"", ; // 02 B   
				"", ; // 03 C  
				"", ; // 04 D  
				"", ; // 05 E  
				"", ; // 06 F
				"", ; // 04 G  
				"", ; // 05 H  
				"", ; // 06 I     
				""  ; // 07 J  
				})
		//TICKET 10851 - ADRIANO SAVOINE 19/03/2021
		ElseIf nOpc == 6
		
			AADD(aLinhas,{ "", ; // 01 A  
				"", ; // 02 B   
				"", ; // 03 C  
				"", ; // 04 D  
				"", ; // 05 E  
				"", ; // 06 F
				"", ; // 04 G  
				"", ; // 05 H  
				"", ; // 06 I     
				""  ; // 07 J  
				})
		
		EndIf
		

		//===================== FINAL CRIA VETOR COM POSICAO VAZIA

		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
		
		If nOpc == 1
		
			aLinhas[nLinha][01] := DETPED->PEDIDO                                                   		//A
			aLinhas[nLinha][02] := DETPED->CLIENTE                                                  		//B
			aLinhas[nLinha][03] := DETPED->LOJA                                                     		//C
			aLinhas[nLinha][04] := Posicione("SA1",1,xFilial("SA1")+DETPED->CLIENTE+DETPED->LOJA ,"A1_NOME")//D
			aLinhas[nLinha][05] := DETPED->CARGA   												 		    //E
			aLinhas[nLinha][06] := DETPED->QTDCXSOL                                                 		//F
			aLinhas[nLinha][07] := DETPED->QTDCXENV 											     		//G
			aLinhas[nLinha][08] := DETPED->QTDCXCORT                                               		    //H
			aLinhas[nLinha][09] := DETPED->QTDKGCORT                                                		//I
			
		ElseIf nOpc == 2
			
			cCliente := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_CLIENTE" )
			cLoja    := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_LOJACLI" )
			
			aLinhas[nLinha][01] := DETPED->PEDIDO                                                   		 //A
			aLinhas[nLinha][02] := cCliente                                                            		 //B
			aLinhas[nLinha][03] := cLoja                                                               		 //C
			aLinhas[nLinha][04] := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja ,"A1_NOME")               //D
			aLinhas[nLinha][05] := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_X_SQED" ) //E 												 		    //E
			aLinhas[nLinha][06] := DETPED->QTDCX                                                 		     //F
			aLinhas[nLinha][07] := DETPED->QTDKG     											     		 //G
			aLinhas[nLinha][08] := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja ,"A1_ENDENT")             //H
			aLinhas[nLinha][09] := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja ,"A1_BAIRROE")            //I
			aLinhas[nLinha][10] := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja ,"A1_MUNE")               //J

		ElseIf nOpc == 3 //Everson - 17/07/2020. Chamado 059728.
			
			cCliente := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_CLIENTE" )
			cLoja    := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_LOJACLI" )
			
			aLinhas[nLinha][01] := DETPED->PEDIDO                                                   		 //A
			aLinhas[nLinha][02] := cCliente                                                            		 //B
			aLinhas[nLinha][03] := cLoja                                                               		 //C
			aLinhas[nLinha][04] := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja ,"A1_NOME")               //D
			aLinhas[nLinha][05] := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_X_SQED" ) //E 												 		    //E
			aLinhas[nLinha][06] := DETPED->QTDCX                                                 		     //F
			aLinhas[nLinha][07] := DETPED->QTDKG     											     		 //G
			aLinhas[nLinha][08] := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja ,"A1_ENDENT")             //H
			aLinhas[nLinha][09] := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja ,"A1_BAIRROE")            //I
			aLinhas[nLinha][10] := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja ,"A1_MUNE")               //J

		//Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido e acrescentar nOpc = 4 (pedidos Bloqueador por Regra)
		ElseIf nOpc == 4
			
			cCliente := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_CLIENTE" )
			cLoja    := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_LOJACLI" )
			
			aLinhas[nLinha][01] := DETPED->PEDIDO                                                   		 //A
			aLinhas[nLinha][02] := cCliente                                                            		 //B
			aLinhas[nLinha][03] := cLoja                                                               		 //C
			aLinhas[nLinha][04] := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja ,"A1_NOME")               //D
			aLinhas[nLinha][05] := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_X_SQED" ) //E 												 		    //E
			aLinhas[nLinha][06] := DETPED->QTDCX                                                 		     //F
			aLinhas[nLinha][07] := DETPED->QTDKG     											     		 //G
			aLinhas[nLinha][08] := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja ,"A1_ENDENT")             //H
			aLinhas[nLinha][09] := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja ,"A1_BAIRROE")            //I
			aLinhas[nLinha][10] := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja ,"A1_MUNE")               //J

		ElseIf nOpc == 5
			
			cCliente := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_CLIENTE" )
			cLoja    := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_LOJACLI" )
			
			aLinhas[nLinha][01] := DETPED->PEDIDO                                                   		 //A
			aLinhas[nLinha][02] := cCliente                                                            		 //B
			aLinhas[nLinha][03] := cLoja                                                               		 //C
			aLinhas[nLinha][04] := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja ,"A1_NOME")               //D
			aLinhas[nLinha][05] := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_X_SQED" ) //E 												 		    //E
			aLinhas[nLinha][06] := DETPED->QTDCX                                                 		     //F
			aLinhas[nLinha][07] := DETPED->QTDKG     											     		 //G
			aLinhas[nLinha][08] := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja ,"A1_ENDENT")             //H
			aLinhas[nLinha][09] := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja ,"A1_BAIRROE")            //I
			aLinhas[nLinha][10] := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja ,"A1_MUNE")               //J
		
		 // TICKET 10851 - ADRIANO SAVOINE - 19/03/2021
		ElseIf nOpc == 6
			
			cCliente := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_CLIENTE" )
			cLoja    := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_LOJACLI" )
			
			aLinhas[nLinha][01] := DETPED->PEDIDO                                                   		 //A
			aLinhas[nLinha][02] := cCliente                                                            		 //B
			aLinhas[nLinha][03] := cLoja                                                               		 //C
			aLinhas[nLinha][04] := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja ,"A1_NOME")               //D
			aLinhas[nLinha][05] := Posicione("SC5",1,xFilial("SC5") + Alltrim(DETPED->PEDIDO), "C5_X_SQED" ) //E 												 		    //E
			aLinhas[nLinha][06] := DETPED->QTDCX                                                 		     //F
			aLinhas[nLinha][07] := DETPED->QTDKG     											     		 //G
			aLinhas[nLinha][08] := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja ,"A1_ENDENT")             //H
			aLinhas[nLinha][09] := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja ,"A1_BAIRROE")            //I
			aLinhas[nLinha][10] := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja ,"A1_MUNE")               //J
		
		EndIf
		//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			

		DETPED->(dbSkip())    

	END //end do while TRB
	//DETPED->( DBCLOSEAREA() )   

	//============================== INICIO IMPRIME LINHA NO EXCEL
	FOR nExcel := 1 TO nLinha
	
		If nOpc == 1
		
			oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],; // 01 A  
			aLinhas[nExcel][02],; // 02 B  
			aLinhas[nExcel][03],; // 03 C  
			aLinhas[nExcel][04],; // 04 D  
			aLinhas[nExcel][05],; // 05 E  
			aLinhas[nExcel][06],; // 06 F  
			aLinhas[nExcel][07],; // 07 G  
			aLinhas[nExcel][08],; // 08 H  
			aLinhas[nExcel][09] ; // 09 I 
			})  //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
			
		ElseIf nOpc == 2
		
			oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],; // 01 A  
			aLinhas[nExcel][02],; // 02 B  
			aLinhas[nExcel][03],; // 03 C  
			aLinhas[nExcel][04],; // 04 D  
			aLinhas[nExcel][05],; // 05 E  
			aLinhas[nExcel][06],; // 06 F  
			aLinhas[nExcel][07],; // 07 G
			aLinhas[nExcel][08],; // 08 H  
			aLinhas[nExcel][09],; // 09 I  
			aLinhas[nExcel][10] ; // 10 J    
			})  //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS	


		ElseIf nOpc == 3 //Everson - 17/07/2020. Chamado 059728.
		
			oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],; // 01 A  
			aLinhas[nExcel][02],; // 02 B  
			aLinhas[nExcel][03],; // 03 C  
			aLinhas[nExcel][04],; // 04 D  
			aLinhas[nExcel][05],; // 05 E  
			aLinhas[nExcel][06],; // 06 F  
			aLinhas[nExcel][07],; // 07 G
			aLinhas[nExcel][08],; // 08 H  
			aLinhas[nExcel][09],; // 09 I  
			aLinhas[nExcel][10] ; // 10 J    
			})  //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS	

		//Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido e acrescentar nOpc = 4 (pedidos Bloqueador por Regra)
		ElseIf nOpc == 4
		
			oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],; // 01 A  
			aLinhas[nExcel][02],; // 02 B  
			aLinhas[nExcel][03],; // 03 C  
			aLinhas[nExcel][04],; // 04 D  
			aLinhas[nExcel][05],; // 05 E  
			aLinhas[nExcel][06],; // 06 F  
			aLinhas[nExcel][07],; // 07 G
			aLinhas[nExcel][08],; // 08 H  
			aLinhas[nExcel][09],; // 09 I  
			aLinhas[nExcel][10] ; // 10 J    
			})
		ElseIf nOpc == 5
		
			oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],; // 01 A  
			aLinhas[nExcel][02],; // 02 B  
			aLinhas[nExcel][03],; // 03 C  
			aLinhas[nExcel][04],; // 04 D  
			aLinhas[nExcel][05],; // 05 E  
			aLinhas[nExcel][06],; // 06 F  
			aLinhas[nExcel][07],; // 07 G
			aLinhas[nExcel][08],; // 08 H  
			aLinhas[nExcel][09],; // 09 I  
			aLinhas[nExcel][10] ; // 10 J    
			})
		ElseIf nOpc == 6 // TICKET 10851 - ADRIANO SAVOINE - 19/03/2021
		
			oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],; // 01 A  
			aLinhas[nExcel][02],; // 02 B  
			aLinhas[nExcel][03],; // 03 C  
			aLinhas[nExcel][04],; // 04 D  
			aLinhas[nExcel][05],; // 05 E  
			aLinhas[nExcel][06],; // 06 F  
			aLinhas[nExcel][07],; // 07 G
			aLinhas[nExcel][08],; // 08 H  
			aLinhas[nExcel][09],; // 09 I  
			aLinhas[nExcel][10] ; // 10 J    
			})

		EndIf
		
	NEXT 
	//============================== FINAL IMPRIME LINHA NO EXCEL
	
	RestArea(aArea)
	
Return Nil   
/*/{Protheus.doc} SalvaXml
	
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static Function SalvaXml(nOpc)

	//Variáveis.

	oExcel:Activate()
	
	If nOpc == 1
		oExcel:GetXMLFile("C:\temp\REL_CORT_EXP.XML")
	
	ElseIf nOpc == 2
		oExcel:GetXMLFile("C:\temp\REL_PED_AN.XML")

	ElseIf nOpc == 3 //Everson - 17/07/2020. Chamado 059728.
		oExcel:GetXMLFile("C:\temp\REL_PED_BLQ.XML")

	//Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido e acrescentar nOpc = 4 (pedidos Bloqueador por Regra)
	ElseIf nOpc == 4
		oExcel:GetXMLFile("C:\temp\REL_PED_CIA.XML")
	ElseIf nOpc == 5
		oExcel:GetXMLFile("C:\temp\REL_PED_EST.XML")
	//TICKET 10851 - ADRIANO SAVOINE - 19/03/2021
	ElseIf nOpc == 6
		oExcel:GetXMLFile("C:\temp\REL_PED_LIB.XML")
	EndIf

Return Nil
/*/{Protheus.doc} CriaExcel
	
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static Function CriaExcel(nOpc)              

	//Variáveis.

	oMsExcel := MsExcel():New()
	
	If nOpc == 1
		oMsExcel:WorkBooks:Open("C:\temp\REL_CORT_EXP.XML")
		
	ElseIf nOpc == 2
		oMsExcel:WorkBooks:Open("C:\temp\REL_PED_AN.XML")

	ElseIf nOpc == 3 //Everson - 17/07/2020. Chamado 059728.
		oMsExcel:WorkBooks:Open("C:\temp\REL_PED_BLQ.XML")

	//Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido e acrescentar nOpc = 4 (pedidos Bloqueador por Regra)
	ElseIf nOpc == 4
		oMsExcel:WorkBooks:Open("C:\temp\REL_PED_CIA.XML")
	ElseIf nOpc == 5
		oMsExcel:WorkBooks:Open("C:\temp\REL_PED_EST.XML")

	ElseIf nOpc == 6
		oMsExcel:WorkBooks:Open("C:\temp\REL_PED_LIB.XML")	

	EndIf
	
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return Nil
/*/{Protheus.doc} Cabec
	
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static Function Cabec(nOpc)

	//Variáveis.

	//Pedido", "Cliente", "Loja", "Nome","Carga","CX(s) Solicitadas","CX(s) Enviadas", "CX(s) Corte ", "KG(s) Corte "

	oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)

	If nOpc == 1

		oExcel:AddColumn(cPlanilha,cTitulo,"Pedido "               	,1,1) // 01 A
		oExcel:AddColumn(cPlanilha,cTitulo,"Cliente "          		,1,1) // 02 B
		oExcel:AddColumn(cPlanilha,cTitulo,"Loja "              	,1,1) // 03 C
		oExcel:AddColumn(cPlanilha,cTitulo,"Nome "                	,1,1) // 04 D
		oExcel:AddColumn(cPlanilha,cTitulo,"Carga"				   	,1,1) // 05 E
		oExcel:AddColumn(cPlanilha,cTitulo,"CX(s).Solicitadas"    	,1,1) // 06 F
		oExcel:AddColumn(cPlanilha,cTitulo,"CX(s).Enviadas"         ,1,1) // 07 G
		oExcel:AddColumn(cPlanilha,cTitulo,"CX(s).Corte "    		,1,1) // 08 H
		oExcel:AddColumn(cPlanilha,cTitulo,"KG(s).Corte "     		,1,1) // 09 I 

	ElseIf nOpc == 2

		oExcel:AddColumn(cPlanilha,cTitulo,"Pedido "               	,1,1) // 01 A
		oExcel:AddColumn(cPlanilha,cTitulo,"Cliente "          		,1,1) // 02 B
		oExcel:AddColumn(cPlanilha,cTitulo,"Loja "              	,1,1) // 03 C
		oExcel:AddColumn(cPlanilha,cTitulo,"Nome "                	,1,1) // 04 D
		oExcel:AddColumn(cPlanilha,cTitulo,"Carga"				   	,1,1) // 05 E
		oExcel:AddColumn(cPlanilha,cTitulo,"CX(s)"    	            ,1,1) // 06 F
		oExcel:AddColumn(cPlanilha,cTitulo,"KG(s)"                  ,1,1) // 07 G
		oExcel:AddColumn(cPlanilha,cTitulo,"Endereco"               ,1,1) // 08 H
		oExcel:AddColumn(cPlanilha,cTitulo,"Bairro"                 ,1,1) // 09 I
		oExcel:AddColumn(cPlanilha,cTitulo,"Cidade"                 ,1,1) // 10 J 

	ElseIf nOpc == 3 //Everson - 17/07/2020. Chamado 059728.

		oExcel:AddColumn(cPlanilha,cTitulo,"Pedido "               	,1,1) // 01 A
		oExcel:AddColumn(cPlanilha,cTitulo,"Cliente "          		,1,1) // 02 B
		oExcel:AddColumn(cPlanilha,cTitulo,"Loja "              	,1,1) // 03 C
		oExcel:AddColumn(cPlanilha,cTitulo,"Nome "                	,1,1) // 04 D
		oExcel:AddColumn(cPlanilha,cTitulo,"Carga"				   	,1,1) // 05 E
		oExcel:AddColumn(cPlanilha,cTitulo,"CX(s)"    	            ,1,1) // 06 F
		oExcel:AddColumn(cPlanilha,cTitulo,"KG(s)"                  ,1,1) // 07 G
		oExcel:AddColumn(cPlanilha,cTitulo,"Endereco"               ,1,1) // 08 H
		oExcel:AddColumn(cPlanilha,cTitulo,"Bairro"                 ,1,1) // 09 I
		oExcel:AddColumn(cPlanilha,cTitulo,"Cidade"                 ,1,1) // 10 J 

	//Chamado 060113 - Abel Babini, 04/08/2020, Redefinição da situação do pedido e acrescentar nOpc = 4 (pedidos Bloqueador por Regra)
	ElseIf nOpc == 4

		oExcel:AddColumn(cPlanilha,cTitulo,"Pedido "               	,1,1) // 01 A
		oExcel:AddColumn(cPlanilha,cTitulo,"Cliente "          		,1,1) // 02 B
		oExcel:AddColumn(cPlanilha,cTitulo,"Loja "              	,1,1) // 03 C
		oExcel:AddColumn(cPlanilha,cTitulo,"Nome "                	,1,1) // 04 D
		oExcel:AddColumn(cPlanilha,cTitulo,"Carga"				   	,1,1) // 05 E
		oExcel:AddColumn(cPlanilha,cTitulo,"CX(s)"    	            ,1,1) // 06 F
		oExcel:AddColumn(cPlanilha,cTitulo,"KG(s)"                  ,1,1) // 07 G
		oExcel:AddColumn(cPlanilha,cTitulo,"Endereco"               ,1,1) // 08 H
		oExcel:AddColumn(cPlanilha,cTitulo,"Bairro"                 ,1,1) // 09 I
		oExcel:AddColumn(cPlanilha,cTitulo,"Cidade"                 ,1,1) // 10 J 

	ElseIf nOpc == 5
		oExcel:AddColumn(cPlanilha,cTitulo,"Pedido "               	,1,1) // 01 A
		oExcel:AddColumn(cPlanilha,cTitulo,"Cliente "          		,1,1) // 02 B
		oExcel:AddColumn(cPlanilha,cTitulo,"Loja "              	,1,1) // 03 C
		oExcel:AddColumn(cPlanilha,cTitulo,"Nome "                	,1,1) // 04 D
		oExcel:AddColumn(cPlanilha,cTitulo,"Carga"				   	,1,1) // 05 E
		oExcel:AddColumn(cPlanilha,cTitulo,"CX(s)"    	            ,1,1) // 06 F
		oExcel:AddColumn(cPlanilha,cTitulo,"KG(s)"                  ,1,1) // 07 G
		oExcel:AddColumn(cPlanilha,cTitulo,"Endereco"               ,1,1) // 08 H
		oExcel:AddColumn(cPlanilha,cTitulo,"Bairro"                 ,1,1) // 09 I
		oExcel:AddColumn(cPlanilha,cTitulo,"Cidade"                 ,1,1) // 10 J 

		//TICKET 10851 - ADRIANO SAVOINE - 19/03/2021
	ElseIf nOpc == 6
		oExcel:AddColumn(cPlanilha,cTitulo,"Pedido "               	,1,1) // 01 A
		oExcel:AddColumn(cPlanilha,cTitulo,"Cliente "          		,1,1) // 02 B
		oExcel:AddColumn(cPlanilha,cTitulo,"Loja "              	,1,1) // 03 C
		oExcel:AddColumn(cPlanilha,cTitulo,"Nome "                	,1,1) // 04 D
		oExcel:AddColumn(cPlanilha,cTitulo,"Carga"				   	,1,1) // 05 E
		oExcel:AddColumn(cPlanilha,cTitulo,"CX(s)"    	            ,1,1) // 06 F
		oExcel:AddColumn(cPlanilha,cTitulo,"KG(s)"                  ,1,1) // 07 G
		oExcel:AddColumn(cPlanilha,cTitulo,"Endereco"               ,1,1) // 08 H
		oExcel:AddColumn(cPlanilha,cTitulo,"Bairro"                 ,1,1) // 09 I
		oExcel:AddColumn(cPlanilha,cTitulo,"Cidade"                 ,1,1) // 10 J 

	EndIf

Return Nil
