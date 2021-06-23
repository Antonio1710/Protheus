#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "Rwmake.ch"
#Include "Tbiconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADVEN034P     ºAutor  ³Everson          ºData ³  08/11/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função de análise de clientes sem compra.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Comercial.                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºAdriana     ³24/05/2019³TI-Devido a substituicao email para shared     º±±
±±º            ³          ³relay, substituido MV_RELACNT p/ MV_RELFROM    º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ADVEN034P() // U_ADVEN034P()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	Local oButton1
	Local oButton2
	Local oButton3
	Local oButton4
	Local oSay1
	Local oDlg
	Local oGroup1
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Função de análise de clientes sem compra.')

	Define MSDIALOG oDlg Title "Operações" From 000, 000  TO 220, 295 COLORS 0, 16777215 PIXEL Style 128
    
    @ 012, 004 GROUP oGroup1 TO 085, 144 OF oDlg COLOR 0, 16777215 PIXEL
    @ 018, 008 BUTTON oButton1 PROMPT "Motivos de Não Compra" SIZE 132, 023 OF oDlg PIXEL Action(motivoDeNCmp(oDlg))
    @ 055, 008 BUTTON oButton2 PROMPT "Gerar Análise" SIZE 132, 023 OF oDlg PIXEL Action(telaGeraTicket())
    
    @ 092, 102 BUTTON oButton4 PROMPT "Fechar" SIZE 038, 013 OF oDlg PIXEL Action(oDlg:End())
    
	Activate MSDIALOG oDlg Centered

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³motivoDeNCmp   ºAutor  ³Everson         ºData ³  08/11/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³CRUD de motivos de não compra.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Comercial.                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function motivoDeNCmp(oTela)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aMotivos 		:= {}
	Local oGridMotivos
	
	Local aAltMotivo		:= {}
	Local aHMotivo		:= {}
	Local aColsMotivo		:= {}
	
	Local oDlgMotivo
	Local oSBtn01
	Local oSBtn02
	
	//
	logAcesso("MOTIVO NAO COMPRA")
	
	//Cria objeto MsDialog.
	oDlgMotivo:= MsDialog():Create()
	oDlgMotivo:cName     := "oDlgMotivo"
	oDlgMotivo:cCaption  := "Parâmetros da Rotina de Emplacamento"
	oDlgMotivo:nLeft     := 34
	oDlgMotivo:nTop      := 222
	oDlgMotivo:nWidth    := 900
	oDlgMotivo:nHeight   := 450
	oDlgMotivo:lShowHint := .F.
	oDlgMotivo:lCentered := .T.
	
	//Cria botão de confirmação.
	oSBtn01:= SBUTTON():Create(oDlgMotivo)
	oSBtn01:cName := "oSBtn01"
	oSBtn01:cCaption := "Novo"
	oSBtn01:nLeft := 765
	oSBtn01:nTop := 390
	oSBtn01:nWidth := 50
	oSBtn01:nHeight := 20
	oSBtn01:lShowHint := .F.
	oSBtn01:lReadOnly := .F.
	oSBtn01:Align := 0
	oSBtn01:lVisibleControl := .T.
	oSBtn01:bAction := {|| telaDeEdicao(oGridMotivos,aHMotivo,1)}
	
	//Cria botão de cancelamento.
	oSBtn02:= SBUTTON():Create(oDlgMotivo)
	oSBtn02:cName := "oSBtn02"
	oSBtn02:cCaption := "Fechar"
	oSBtn02:nLeft := 833
	oSBtn02:nTop := 390
	oSBtn02:nWidth := 50
	oSBtn02:nHeight := 20
	oSBtn02:lShowHint := .F.
	oSBtn02:lReadOnly := .F.
	oSBtn02:Align := 0
	oSBtn02:lVisibleControl := .T.
	oSBtn02:bAction := {||oDlgMotivo:End()}
	
	//Cria Header.
	Aadd(aHMotivo,{"Codigo" 	,"CODIGO"	,""	, 03,0,"","" ,"C","",""})
	Aadd(aHMotivo,{"Ativo" 	,"ATIVO"	,""	, 01,0,"","" ,"C","",""})
	Aadd(aHMotivo,{"Motivo" 	,"MOTIVO"	,""	, 50,0,"","" ,"C","",""})
	
	oGridMotivos := MsNewGetDados():New(005,004,180,445,GD_UPDATE + GD_INSERT,;
					  "Allwaystrue()","Allwaystrue()","",aAltMotivo,Nil,999,Nil,Nil,Nil,oDlgMotivo,aHMotivo,@aColsMotivo)
	oGridMotivos:oBrowse:bLDblClick := {||telaDeEdicao(oGridMotivos,aHMotivo,2)}
	
	oDlgMotivo:Activate(,,,.T.,{||.T.},,{|| cargaMotivos(oGridMotivos,aHMotivo)})
	
Return Nil

Static Function telaDeEdicao(oGridMotivos,aHMotivo,nOpc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local oButton1
	Local oButton2
	Local oComboBo1
	Local nComboBo1 := 1
	Local oGet1
	Local cGet1 := "Define variable value"
	Local oGet2
	Local cGet2 := Space(20)
	Local oGroup1
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oDlg
	Local aComboBox	:= {}
	Local cAtivo		:= ""
	Local cMotivo		:= ""
	
	Aadd(aComboBox,"1=Sim")
	Aadd(aComboBox,"2=Não")
	
	If nOpc == 2
		cGet1     := oGridMotivos:aCols[oGridMotivos:nat][Ascan(aHMotivo,{|x| AllTrim(x[2]) == "CODIGO"})]
		cMotivo   := Alltrim(cValtoChar(oGridMotivos:aCols[oGridMotivos:nat][Ascan(aHMotivo,{|x| AllTrim(x[2]) == "MOTIVO"})]))
		cGet2     := cMotivo + Space(10 - Len(cMotivo))
		
		cAtivo := Alltrim(cValToChar(oGridMotivos:aCols[oGridMotivos:nat][Ascan(aHMotivo,{|x| AllTrim(x[2]) == "ATIVO"})]))
		
		If cAtivo == "Sim"
			nComboBo1 := 1
			
		Else
			nComboBo1 := 2
			
		EndIf
		
	Else
		//Obté o próximo número.
		cGet1 := proximoNum()
		
	EndIf
	
	//
	If Val(cValToChar(cGet1)) > 99
		MsgStop("Número máximo de motivos atingido.","Função telaDeEdicao")
		Return Nil
		
	EndIf

  DEFINE MSDIALOG oDlg TITLE "" FROM 000, 000  TO 250, 350 COLORS 0, 16777215 PIXEL Style 128
    
    @ 011, 003 GROUP oGroup1 TO 096, 172 OF oDlg COLOR 0, 16777215 PIXEL
    
    @ 019, 008 SAY oSay1 PROMPT "Código:" SIZE 041, 011 OF oDlg COLORS 0, 16777215 PIXEL
    @ 032, 007 MSGET oGet1 VAR cGet1 SIZE 042, 010 OF oDlg COLORS 0, 16777215 PIXEL When .F.
    
    @ 020, 061 SAY oSay2 PROMPT "Motivo:" SIZE 104, 012 OF oDlg COLORS 0, 16777215 PIXEL
    @ 032, 060 MSGET oGet2 VAR cGet2 SIZE 107, 010 OF oDlg COLORS 0, 16777215 PIXEL
    
    @ 053, 008 SAY oSay3 PROMPT "Ativo:" SIZE 039, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 064, 007 MSCOMBOBOX oComboBo1 VAR nComboBo1 ITEMS aComboBox SIZE 044, 010 OF oDlg COLORS 0, 16777215 PIXEL
    
    //
    @ 105, 067 BUTTON oButton1 PROMPT "Ok"       SIZE 044, 014 OF oDlg PIXEL Action(oDlg:End(),grvMotivos(cGet1,cGet2,nComboBo1,oGridMotivos,aHMotivo,nOpc))
    @ 105, 125 BUTTON oButton2 PROMPT "Cancelar" SIZE 044, 014 OF oDlg PIXEL Action(oDlg:End())

  ACTIVATE MSDIALOG oDlg CENTERED
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³proximoNum   ºAutor  ³Everson           ºData ³  08/11/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Obtém o próximo número (código).                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Comercial.                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function proximoNum()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cQuery	:= ""
	Local cNum		:= 1
	
	cQuery += " SELECT " 
	cQuery += " MAX(CAST(X5_CHAVE AS NUMERIC)) AS ULTPOS " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("SX5") + " AS SX5 " 
	cQuery += " WHERE  " 
	cQuery += " X5_TABELA = 'ZY'  " 
	cQuery += " AND SX5.D_E_L_E_T_ = '' " 
	
	If Select("PRX_NUM") > 0
		PRX_NUM->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "PRX_NUM"
	
	DbSelectArea("PRX_NUM")
		
		cNum := cValToChar(Val(cValToChar(PRX_NUM->ULTPOS)) + 1)
	
	DbCloseArea("PRX_NUM")


Return cNum
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³cargaMotivos   ºAutor  ³Everson         ºData ³  08/11/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua carga dos motivos de não compra dos clientes.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Comercial.                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function cargaMotivos(oGridMotivos,aHMotivo)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	:= GetArea()
	Local aDados	:= {}
	Local i		:= 1
	Local cRotaDe := ""
	Local cRotaAte:= ""
	Local cTaFrt	:= ""
	Local cDescTa	:= ""
	Local cTiFrt	:= ""
	Local cDescTi	:= ""
	Local cAtivo	:= ""
	
	//Zera aCols.
	oGridMotivos:aCols := {}
	
	//Obtém dados de parâmetros.
	aDados := sqlMotDeNCmp()
	
	If Len(aDados) > 0
		
		For i := 1 To Len(aDados)
			
			If Alltrim(cValToChar(aDados[i][3])) == "1"
				cAtivo := "Sim"
				
			Else	
				cAtivo := "Não"
				
			EndIf
			
			Aadd(oGridMotivos:aCols , Array(Len(aHMotivo)+1) )
			oGridMotivos:aCols[Len(oGridMotivos:aCols), Len(oGridMotivos:aCols[1]) ] := .F.
			oGridMotivos:aCols[Len(oGridMotivos:aCols),Ascan(aHMotivo,{|x| AllTrim(x[2]) == "CODIGO" })] := aDados[i][1]
			oGridMotivos:aCols[Len(oGridMotivos:aCols),Ascan(aHMotivo,{|x| AllTrim(x[2]) == "ATIVO"  })] := cAtivo
			oGridMotivos:aCols[Len(oGridMotivos:aCols),Ascan(aHMotivo,{|x| AllTrim(x[2]) == "MOTIVO" })] := aDados[i][2]
		
		Next i
	
	Else
		Aadd(oGridMotivos:aCols , Array(Len(aHMotivo)+1) )
		oGridMotivos:aCols[Len(oGridMotivos:aCols), Len(oGridMotivos:aCols[1]) ] := .F.
		oGridMotivos:aCols[Len(oGridMotivos:aCols),Ascan(aHMotivo,{|x| AllTrim(x[2]) == "CODIGO" })] := ""
		oGridMotivos:aCols[Len(oGridMotivos:aCols),Ascan(aHMotivo,{|x| AllTrim(x[2]) == "ATIVO"  })] := ""
		oGridMotivos:aCols[Len(oGridMotivos:aCols),Ascan(aHMotivo,{|x| AllTrim(x[2]) == "MOTIVO" })] := ""
	
	EndIf
	
	oGridMotivos:Refresh()
	
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³grvMotivos     ºAutor  ³Everson         ºData ³  08/11/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava alterações dos motivos de não compra dos clientes.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Comercial.                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function grvMotivos(cCodigo,cMotivo,nOpcAtivo,oGridMotivos,aHMotivo,nOpc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	Local cUpdate := "UPDATE " + RetSqlName("SX5") + " SET X5_DESCRI = '" +;
						cMotivo + "', X5_DESCSPA = '" + Alltrim(cValToChar(nOpcAtivo)) +;
						"' WHERE X5_TABELA = 'ZY' AND X5_CHAVE = '" + Alltrim(cValToChar(cCodigo)) + "' "	
	
	
	If nOpc == 1 //Inclusão.
		DbSelectArea("SX5")
		
		RecLock("SX5",.T.)
			SX5->X5_FILIAL  = xFilial("SX5")
			SX5->X5_TABELA  =  "ZY"
			SX5->X5_CHAVE	  = cCodigo
			SX5->X5_DESCRI  = cMotivo
			SX5->X5_DESCSPA = Alltrim(cValToChar(nOpcAtivo))
		MsUnlock()
	
	Else //Atualização.
	
		If TcSqlExec(cUpdate) < 0
			MsgStop("Não foi possível atualizar o registro." + Chr(13) + Chr(10) +;
					 "TCSQLError() " + TCSQLError(),"Função grvMotivos")
			Return Nil
			
		EndIf
	
	EndIf
	
	MsgInfo("Operação realizada.","Função grvMotivos")
	
	//Atualiza a grid.
	cargaMotivos(oGridMotivos,aHMotivo)
	oGridMotivos:Refresh()

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³sqlMotDeNCmp   ºAutor  ³Everson         ºData ³  08/11/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³script sql de motivos de não compra de clientes.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Comercial.                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function sqlMotDeNCmp()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	Local cQuery	:= ""
	Local aRetorno:= {}
	
	//Monta script sql.
	cQuery := ""
	cQuery += " SELECT * " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SX5") + " AS SX5 " 
	cQuery += " WHERE " 
	cQuery += " SX5.D_E_L_E_T_ = '' " 
	cQuery += " AND X5_FILIAL = '" + xFilial("SX5") + "' " 
	cQuery += " AND X5_TABELA = 'ZY' ORDER BY CAST(X5_CHAVE AS NUMERIC) " 
	
	//Checa se o alias existe.
	If Select("MOT_NC") > 0
		MOT_NC->(DbCloseArea())
		
	EndIf
	
	//Executa consulta no BD.
	TcQuery cQuery New Alias "MOT_NC"
	
	
	//Preenche variável de retorno.
	DbSelectArea("MOT_NC")
	MOT_NC->(DbGoTop())
	
	While ! MOT_NC->(Eof())
		
		Aadd(aRetorno,{;
							MOT_NC->X5_CHAVE,;
							MOT_NC->X5_DESCRI,;
							MOT_NC->X5_DESCSPA;
						})
		
		MOT_NC->(DbSkip())
		
	EndDo
	
	DbCloseArea("MOT_NC")

Return aRetorno
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADMCLISCOMP   ºAutor  ³Everson          ºData ³  08/11/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função de análise de clientes sem compra.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Comercial.                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function telaGeraTicket()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                         
	Local oButton1
	Local oButton2
	Local oGet1
	Local cGet1 := Date()
	Local oGet2
	Local cGet2 := Date()
	Local oGet3
	Local cGet3 := Date()
	Local oGet4
	Local cGet4 := Date()
	Local oGet5
	Local cGet5 := Space(6)
	Local oGet6
	Local cGet6 := Space(6)
	Local oGroup1
	Local oGroup2
	Local oGroup3
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local oSay7
	Local oSay8
	Local oSay9
	Local oDlg
	Local nOpc := 0
	
	//
	logAcesso("GERA ANALISE")

  DEFINE MSDIALOG oDlg TITLE "Clientes Sem Compra" FROM 000, 000  TO 245, 375 COLORS 0, 16777215 PIXEL Style 128
  
    @ 002, 020 SAY oSay7 PROMPT "Parâmetros para Geração de Análise de Clientes Sem Compras" SIZE 200, 011 OF oDlg COLORS 0, 16777215 PIXEL
    
    //Data de apuração.
    @ 015, 004 GROUP oGroup1 TO 066, 089 PROMPT "Data de Apuração" OF oDlg COLOR 0, 16777215 PIXEL
    @ 026, 008 SAY oSay2 PROMPT "De:" SIZE 014, 009 OF oSay1 COLORS 0, 16777215 PIXEL
    @ 026, 022 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 044, 008 SAY oSay5 PROMPT "Até:" SIZE 014, 009 OF oSay3 COLORS 0, 16777215 PIXEL
    @ 043, 022 MSGET oGet2 VAR cGet2 SIZE 059, 010 OF oDlg COLORS 0, 16777215 PIXEL
    
    //Data de preenchimento
    @ 015, 096 GROUP oGroup2 TO 066, 181 PROMPT "Data de Preenchimento" OF oDlg COLOR 0, 16777215 PIXEL
    @ 026, 100 SAY oSay4 PROMPT "De:" SIZE 014, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 026, 114 MSGET oGet3 VAR cGet3 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 044, 100 SAY oSay6 PROMPT "Até:" SIZE 013, 009 OF oDlg COLORS 0, 16777215 PIXEL
    @ 043, 114 MSGET oGet4 VAR cGet4 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    
    //Vendedores.
    @ 073, 004 GROUP oGroup3 TO 115, 088 PROMPT "Vendedores" OF oDlg COLOR 0, 16777215 PIXEL
    @ 082, 008 SAY oSay8 PROMPT "De:" SIZE 014, 009 OF oGroup3 COLORS 0, 16777215 PIXEL 
    @ 083, 022 MSGET oGet5 VAR cGet5 SIZE 059, 010 OF oDlg COLORS 0, 16777215 PIXEL F3 "SA3"
    @ 100, 008 SAY oSay9 PROMPT "Até:" SIZE 012, 008 OF oDlg COLORS 0, 16777215 PIXEL
    @ 099, 022 MSGET oGet6 VAR cGet6 SIZE 059, 010 OF oDlg COLORS 0, 16777215 PIXEL F3 "SA3"
    
    //Botões.
    @ 085, 109 BUTTON oButton1 PROMPT "Ok" SIZE 062, 014 OF oDlg PIXEL Action(oDlg:End(),nOpc := 1)
    @ 101, 109 BUTTON oButton2 PROMPT "Cancelar" SIZE 062, 014 OF oDlg PIXEL Action(oDlg:End())

  ACTIVATE MSDIALOG oDlg CENTERED
  
  If nOpc == 1
	Processa({||ok_gerarTicket(cGet1,cGet2,cGet3,cGet4,cGet5,cGet6)},"Aguarde")
	
	MsgInfo("Processamento concluído.","Função telaGeraTicket")
	
  EndIf	

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ok_gerarTicket ºAutor  ³Everson         ºData ³  08/11/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para gerar registros para análise de não compra.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Comercial.                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ok_gerarTicket(dDtApDe,dDtApAte,dDtPrDe,dDtPrAte,cVendDe,cVendAte)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	Local cQuery 		:= ""
	Local cDtLimite	:= ""
	Local cPeriodo	:= ""
	Local nTotRot		:= 0
	Local aEMailVend	:= {}
	Local aEmailSuper	:= {}
	Local nPos			:= 0
	Local cValPer		:= ""
	
	//Periodo de apuração.
	cPeriodo := Substr(DToS(dDtApAte),5,2) + Substr(DToS(dDtApAte),1,4)
	
	//Verifica se já o período lançado.
	cValPer := Alltrim(cValToChar(Posicione("ZBI",4,xFilial("ZBI") + cPeriodo,"ZBI_PERIOD")))
	If ! Empty(cValPer)
		MsgStop("Já há lançamento efetuado para o período " + cValPer + ".","Função ok_gerarTicket")
		Return Nil
		
	EndIf
	
	//Obtém o script sql.
	cQuery := sqlRegistros(dDtApDe,dDtApAte,cVendDe,cVendAte)
	
	//Verifica se o alias já existe.
	If Select("CLIENTES") > 0
		CLIENTES->(DbCloseArea())
		
	EndIf
	
	//Executa consulta no BD.
	TcQuery cQuery New Alias "CLIENTES"
	
	//Obtém os dados do BD.
	DbSelectArea("CLIENTES")
	CLIENTES->(DbGoTop())
	
	nTotRot := Contar("CLIENTES","!Eof()")
	
	//Pedi confirmação ao usuário.
	If ! MsgYesNo("Serão gerados " + cValToChar(nTotRot) + " registros para análise. Deseja prosseguir?","Função ok_gerarTicket")
		Return Nil
		
	EndIf
	
	ProcRegua(nTotRot)
	
	CLIENTES->(DbGoTop())
	While ! CLIENTES->(Eof())
	
		IncProc("Carteira " + cValToChar(CLIENTES->CART) + " | PDV " + cValToChar(CLIENTES->PDV))
		
		//Cria registro na tabela.
		criarRegistro(;
						CLIENTES->CART,;
						CLIENTES->CODSUPER,;
						CLIENTES->CODSUPER2,; 
						CLIENTES->PDV,;
						CLIENTES->LOJA,;
						dDtApDe,dDtApAte,dDtPrDe,dDtPrAte,cPeriodo)
		
		//Adiciona e-mail do vendedor.
		nPos := 0
		nPos := Ascan(aEMailVend,{|x| Alltrim(cValToChar(x[1])) == Alltrim(cValToChar(CLIENTES->CART))})
		If nPos == 0
			Aadd(aEMailVend,{CLIENTES->CART,CLIENTES->EMAILVEND})
			//Aadd(aEMailVend,{CLIENTES->CART,"everson.silva@adoro.com.br"})
			
		EndIf
		
		//Adiciona e-mail do supervisor.
		nPos := 0
		nPos := Ascan(aEmailSuper,{|x| Alltrim(cValToChar(x[1])) == Alltrim(cValToChar(CLIENTES->CODSUPER))})
		If nPos == 0
			Aadd(aEmailSuper,{CLIENTES->CODSUPER,CLIENTES->EMAILSUPER})
			//Aadd(aEmailSuper,{CLIENTES->CODSUPER,"vagner.correia@adoro.com.br"})
			
		EndIf
		
		CLIENTES->(DbSkip())
		
	EndDo
	
	DbCloseArea("CLIENTES")
	
	//
	cDtLimite := DTos(dDtPrDe) + "/" + DTos(dDtPrAte)
	PutMv("MV_#PZCSCP",cDtLimite)
	
	//Enviar e-mail as vendedores e supervisores.
	enviarEmail(aEMailVend,aEmailSuper,cPeriodo,dDtPrDe,dDtPrAte)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³sqlRegistros   ºAutor  ³Everson         ºData ³  09/11/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Script sql com os clientes que não efeturam compras.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Comercial.                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function sqlRegistros(dDtApDe,dDtApAte,cVendDe,cVendAte)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	Local cQuery	:= ""
	
	//Remove espaços em branco.
	cVendDe	:= Alltrim(cValToChar(cVendDe))
	cVendAte:= Alltrim(cValToChar(cVendAte))
	
	//Monta script sql.
	cQuery := ""
	cQuery += " SELECT    " 
	cQuery += " A1_COD AS 'PDV',   " 
	cQuery += " A1_LOJA AS 'LOJA',       " 
	cQuery += " A1_VEND AS 'CART',   " 
	cQuery += " A3_EMAIL AS 'EMAILVEND',   " 
	cQuery += " SUPER.CODSUPER AS 'CODSUPER',   " 
	cQuery += " SUPER.NOMESUPER AS 'NOMESUPER',   " 
	cQuery += " SUPER.EMAILSUPER AS 'EMAILSUPER', SZR.ZR_CODIGO AS 'CODSUPER2', " 
	cQuery += " A1_ULTCOM, " 
	cQuery += " A1_DTCAD, " 
	cQuery += " A1_MSBLQL " 
	cQuery += " FROM     " 
	cQuery += " " + RetSqlName("SA1") + "  AS SA1     " 
	cQuery += " INNER JOIN   " 
	cQuery += " " + RetSqlName("SA3") + "  AS SA3 ON   " 
	cQuery += " A1_VEND = A3_COD   " 
	cQuery += " INNER JOIN   " 
	cQuery += " (SELECT A3_COD AS CODSUPER, A3_NOME AS NOMESUPER, A3_EMAIL AS EMAILSUPER FROM  " + RetSqlName("SA3") + "  AS SUPER WHERE SUPER.D_E_L_E_T_ = '') AS SUPER ON   " 
	cQuery += " A3_SUPER = SUPER.CODSUPER   " 
	cQuery += "  " 
	cQuery += " INNER JOIN  " 
	cQuery += " " + RetSqlName("SZR") + "  AS SZR ON  " 
	cQuery += " A3_CODSUP = ZR_CODIGO  " 
	cQuery += "  " 
	cQuery += " WHERE     " 
	cQuery += " SA1.D_E_L_E_T_ = ''   " 
	cQuery += " AND SZR.D_E_L_E_T_ = ''  " 
	cQuery += " AND SA3.D_E_L_E_T_ = ''   " 
	cQuery += "  " 
	cQuery += " AND A1_COD+A1_LOJA NOT IN " 
	cQuery += " ( " 

	cQuery += " SELECT "
	cQuery += " DISTINCT A1_COD+A1_LOJA "
	cQuery += " FROM "
	cQuery += " " + RetSqlName("SE1") + " AS SE1 "
	cQuery += " INNER JOIN "
	cQuery += "  " + RetSqlName("SA1") + "  AS SA1 "
	cQuery += " ON A1_COD = E1_CLIENTE "
	cQuery += " AND A1_LOJA = E1_LOJA "
	cQuery += " WHERE "
	cQuery += " SE1.D_E_L_E_T_ = '' "
	cQuery += " AND SA1.D_E_L_E_T_ = '' "
	cQuery += " AND E1_EMISSAO >= '" + DToS(dDtApDe) + "' "
	cQuery += " AND E1_EMISSAO <= '" + DToS(dDtApAte) + "' "
	cQuery += " AND A1_DTCAD   <= '" + DToS(dDtApAte) + "' "
	cQuery += " AND E1_TIPO    = 'NF' "
	cQuery += " ) " 
	cQuery += "  " 
	cQuery += " AND A1_DTCAD  <= '" + DToS(dDtApAte) + "'   " 
	cQuery += "  " 
	cQuery += " AND A1_COD <> ''   " 
	cQuery += "  " 
	cQuery += " AND A3_COD >= '" + cVendDe  + "'  " 
	cQuery += " AND A3_COD <= '" + cVendAte + "'  " 
	cQuery += "  " 
	cQuery += " ORDER BY SUPER.CODSUPER,A1_VEND, A1_COD " 
 
Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³criarRegistro  ºAutor  ³Everson         ºData ³  09/11/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria registro na tabela.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Comercial.                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function criarRegistro(cCodVend,cCodSuper,cCodSuper2,cCodCli,cLojaCli,dDtApDe,dDtApAte,dDtPrDe,dDtPrAte,cPeriodo)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	
	ChkFile("ZBI")
	
	RecLock("ZBI",.T.)
		ZBI->ZBI_FILIAL 	:= xFilial("ZBI")
		ZBI->ZBI_VEND		:= cCodVend
		ZBI->ZBI_SUPER	:= cCodSuper
		ZBI->ZBI_CODSUP	:= cCodSuper2
		ZBI->ZBI_CODCLI	:= cCodCli
		ZBI->ZBI_LOJA		:= cLojaCli
		ZBI->ZBI_DTAPDE 	:= dDtApAte
		ZBI->ZBI_DTAPAT 	:= dDtApAte
		ZBI->ZBI_DTPRDE	:= dDtPrDe
		ZBI->ZBI_DTPRAT	:= dDtPrAte
		ZBI->ZBI_PERIOD	:= Alltrim(cValToChar(cPeriodo))
		ZBI->ZBI_MOTIVO	:= ""
		ZBI->ZBI_OBS		:= ""
	MsUnlock()
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³enviarEmail    ºAutor  ³Everson         ºData ³  09/11/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para enviar e-mail ao vendedores e supervisores.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Comercial.                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function enviarEmail(aEMailVend,aEmailSuper,cPeriodo,dDtPrDe,dDtPrAte)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cMensagem	:= ""
	Local cAssunto	:= "Análise de Clientes sem Compras - " + Alltrim(cValToChar(cPeriodo))
	Local i			:= 1
	Local cEmail	:= ""
	
	//
	cMensagem	:= "Está disponível no Protheus (Faturamento > Atualizações > Justif PDV S/Compra) a análise de clientes que não efetuaram compra no período " + Alltrim(cValToChar(cPeriodo)) + "." + Chr(13) + Chr(10)
	cMensagem	+= "O preenchimento deve ocorrer clicando duas vezes sobre a linha do cliente selecionado, escolher um dos motivos da lista (preenchimento obrigatório) o campo " + Chr(13) + Chr(10)
	cMensagem   += "observações serve para incluir algum comentário. " + Chr(13) + Chr(10)
	cMensagem   += "A consolidação será feita pelos motivos selecionados, o status deve ficar verde, caso contrário não será contabilizado como justificado." + Chr(13) + Chr(10)
	cMensagem	+= "Prazo de preenchimento até " + DToC(dDtPrAte) + "."
	
	//Envia e-mail aos vendedores.
	For i := 1 To Len(aEMailVend)
		cEmail := cValToChar(aEMailVend[i][2])
		MsAguarde({||processarEmail(cAssunto,cMensagem,cEmail)},"Aguarde","Vend: " +;
						cValToChar(aEMailVend[i][1]) + " | " + cValToChar(aEMailVend[i][2]))
		
	Next i
	
	//Envia e-mail aos supervisores.
	For i := 1 To Len(aEmailSuper)
		cEmail := cValToChar(aEmailSuper[i][2])
		MsAguarde({||processarEmail(cAssunto,cMensagem,cEmail)},"Aguarde","Super: " +;
						cValToChar(aEmailSuper[i][1]) + " | " + cValToChar(aEmailSuper[i][2]))
		
	Next i
	 
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³processarEmail ºAutor  ³Everson         ºData ³  09/11/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Configurações de e-mail.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Comercial.                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function processarEmail(cAssunto,cMensagem,email)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 Local lOk           := .T.
	 Local cBody         := cMensagem
	 Local cErrorMsg     := ""
	 Local aFiles        := {}
	 Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	 Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
	 Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
	 Local cFrom         := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
	 Local cTo           := email
	 Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)
	 Local lAutOk        := .F.
	 Local cAtach        := ""   
	 Local cSubject      := ""
	
	//Assunto do e-mail.
	 cSubject := cAssunto
	 
	 //Conecta ao servidor SMTP.
	 Connect Smtp Server cServer Account cAccount  Password cPassword Result lOk
	 
	 If !lAutOk
	    If ( lSmtpAuth )
	       lAutOk := MailAuth(cAccount,cPassword)
	       
	    Else
	       lAutOk := .T.
	       
	    EndIf
	    
	 EndIf
	 
	 If lOk .And. lAutOk   
	    
	    //Envia o e-mail.     
	    Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk  
	     
	    //Tratamento de erro no envio do e-mail.          
	    If !lOk
	       Get Mail Error cErrorMsg
	       ConOut("3 - " + cErrorMsg)
	       
	    EndIf
	    
	 Else
	    Get Mail Error cErrorMsg
	    ConOut("4 - " + cErrorMsg)
	    
	 EndIf
	 
	 If lOk
	    Disconnect Smtp Server
	    
	 EndIf
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³logAcesso         º Autor ³ Everson º Data ³  16/06/2017    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Log de acesso de rotina.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Chamado 035397.                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function logAcesso(cRotina)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea		:= GetArea()
	
	cRotina := Alltrim(cValToChar(cRotina))

	//Log.
	RecLock("ZBE",.T.)
		ZBE->ZBE_FILIAL := xFilial("SE1")
		ZBE->ZBE_DATA	:= Date()
		ZBE->ZBE_HORA	:= cValToChar(Time())
		ZBE->ZBE_USUARI	:= cUserName
		ZBE->ZBE_LOG	:= "ACESSO A ROTINA " + cRotina
		ZBE->ZBE_MODULO	:= "COMERCIAL"
		ZBE->ZBE_ROTINA	:= "ADVEN034P"
	MsUnlock()
	
	RestArea(aArea)
	
Return Nil