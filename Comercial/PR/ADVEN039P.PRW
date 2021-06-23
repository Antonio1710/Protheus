#Include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADVEN039P ºAutor  ³Everson             º Data ³02/01/2016   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta cliente.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Chamado 032041.                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADVEN039P()  // U_ADVEN039P()

 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Declaração de variáveis.                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                    
	Local oButton1
	Local oComboBo1
	Local nComboBo1 := 1
	Local oGet1
	Local cGet1 := Space(20)
	Local oGet2
	Local cGet2 := ""
	Local oGet3
	Local cGet3 := ""
	Local oGet4
	Local cGet4 := ""
	Local oGet5
	Local cGet5 := ""
	Local oGroup1
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Static oDlg

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Consulta cliente.')
	
	Define MsDialog oDlg Title "Consulta Cliente" From 000, 000  To 380, 495 COLORS 0, 16777215 Pixel Style 128
  	
	  	@ 007, 071 Say oSay4 PROMPT "Por favor, informe o código ou CNPJ do cliente." SIZE 115, 013 OF oDlg COLORS 0, 16777215 Pixel
	  	nComboBo1 := 1
	    @ 051, 004 GROUP oGroup1 To 167, 244 PROMPT "Dados do Cliente" OF oDlg COLOR 0, 16777215 Pixel
	    @ 030, 004 MSCOMBOBOX oComboBo1 Var nComboBo1 ITEMS {'1=Código (SA1)','2=CNPJ'} SIZE 079, 010 OF oDlg COLORS 0, 16777215 Pixel
	    @ 030, 092 MSGET oGet1 Var cGet1 SIZE 095, 010 OF oDlg COLORS 0, 16777215 Pixel
	    @ 029, 200 BUTTON oButton1 PROMPT "Buscar" SIZE 043, 014 OF oDlg Pixel Action(buscarInfo(nComboBo1,cGet1,oGet2,@cGet2,oGet3,@cGet3,oGet4,@cGet4,oGet5,@cGet5))
	    
	    @ 068, 012 Say oSay1 PROMPT "Código (SA1)" SIZE 040, 012 OF oDlg COLORS 0, 16777215 Pixel
	    @ 068, 052 MSGET oGet2 Var cGet2 SIZE 068, 010 OF oDlg COLORS 0, 16777215 Pixel When .F.
	    
	    @ 089, 012 Say oSay2 PROMPT "Nome" SIZE 023, 007 OF oDlg COLORS 0, 16777215 Pixel
	    @ 089, 052 MSGET oGet3 Var cGet3 SIZE 150, 010 OF oDlg COLORS 0, 16777215 Pixel When .F.
	    
	    @ 109, 012 Say oSay3 PROMPT "Vendedor" SIZE 025, 013 OF oDlg COLORS 0, 16777215 Pixel
	    @ 109, 052 MSGET oGet4 Var cGet4 SIZE 150, 010 OF oDlg COLORS 0, 16777215 Pixel When .F.
	    
	    @ 129, 012 Say oSay5 PROMPT "Status Financeiro" SIZE 025, 013 OF oDlg COLORS 0, 16777215 Pixel
	    @ 129, 052 MSGET oGet5 Var cGet5 SIZE 150, 010 OF oDlg COLORS 0, 16777215 Pixel When .F.
	    
	    @ 169, 195 BUTTON oButton1 PROMPT "Fechar" SIZE 048, 014 OF oDlg Pixel Action(oDlg:End())
    
    Activate MsDialog oDlg Centered

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³buscarInfoºAutor  ³Everson             ºData  ³02/01/2016   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Obtém os dados do cliente.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Chamado 032041.                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function buscarInfo(nOpcao,string,oCodCli,cCodCli,oNomeCli,cNomeCli,oVend,cVend,oMotivo,cMotivo)

 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Declaração de variáveis.                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	Local aArea	:= GetArea()
	
	//Remove espaços em branco.
	string := Alltrim(cValToChar(string))
	
	//
	If Empty(string)
		MsgStop("É necessário informar o código ou o CNPJ do cliente.","Função buscarInfo")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	DbSelectArea("PB3")
	if cValToChar(nOpcao) == "1"
		PB3->(DbSetOrder(11)) //Busca por código do cliente.
		PB3->(DbGoTop())
		
	Else
		PB3->(DbSetOrder(3)) //Busca por CNPJ do cliente.
		PB3->(DbGoTop())
	
	EndIf
	
	//		
	If  ! PB3->(DbSeek(xFilial("PB3") + string))
		MsgStop("Não foi possível localizar o cadastro do cliente.","Função buscarInfo")
		RestArea(aArea)
		Return Nil
		
	EndIf
			
	cCodCli 	:= PB3->PB3_CODSA1
	cNomeCli	:= PB3->PB3_NOME
	cVend		:= cValToChar(Alltrim(PB3->PB3_CODVEN)) + "-" + cValToChar(Alltrim(Posicione("SA3",1,xFilial("SA3") + Alltrim(cValToChar(PB3->PB3_CODVEN)),"A3_NOME")))
	cMotivo     := ALLTRIM(PB3->PB3_MOTBLQ) + ' - ' + ALLTRIM(POSICIONE("PB5",1,xFilial("PB5")+PB3->PB3_MOTBLQ,"PB5_DESCRI"))
	
	oCodCli:Refresh()
	oNomeCli:Refresh()
	oVend:Refresh()
	oMotivo:Refresh()
	
	RestArea(aArea)
	
Return Nil