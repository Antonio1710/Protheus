#Include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F100TOK   º Autor ³ Everson            º Data ³  26/10/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Ponto de entrada .                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Chamado 037320.                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function F100TOK()
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local cNaturezas:= GetMv("MV_#TARIFA")
	Local nVlrTar   := 0              //Chamado:038828  fernando Sigoli 09/01/2017
	
	//Everson - 14/12/2017. Chamado 038693.
	If !( cEmpAnt $"01/02/03/06" )
		RestArea(aArea)
		Return .T.
		
	EndIf
	
	//Valida se o campo de tarifa foi informado.
	If IsInCallStaCk("FA100PAG") .And. (Alltrim(cValToChar(M->E5_NATUREZ)) $cNaturezas) .And.;
	   (Empty(Alltrim(cValTochar(M->E5_XTARIFA))) .Or. M->E5_XQTDTAR <= 0)
	   
	   MsgStop("Para a natureza informada é necessário informar o código da tarifa bancária e quantidade da mesma.","Função F100TOK")
	   RestArea(aArea)
	   Return .F.
	   
	ElseIf ! IsInCallStaCk("FA100PAG") .And.;
	   (! Empty(Alltrim(cValTochar(M->E5_XTARIFA))) .Or. M->E5_XQTDTAR > 0)
	   
	   MsgStop("Para esta operação não é necessário informar o código da tarifa bancária e quantidade da mesma.","Função F100TOK")
	   RestArea(aArea)
	   Return .F.
	   	
	EndIf
	
	//Chamado: 038828 09/01/18 - Fernado Sigoli
	//Inicio
	If IsInCallStaCk("FA100PAG") .And. (Alltrim(cValToChar(M->E5_NATUREZ)) $cNaturezas) .And.;
	   (!Empty(Alltrim(cValTochar(M->E5_XTARIFA))) .Or. M->E5_XQTDTAR > 0)
	
		nVlrTar := Posicione('ZC2',1,xFilial("ZC2")+Alltrim(M->E5_XTARIFA),"ZC2_VALOR")
		nVlrTar := (nVlrTar*M->E5_XQTDTAR)
		
		If nVlrTar <> M->E5_VALOR
			
			If !MsgYesNo("Atenção! Existe divergência de valores Total X Cadastro de Tarifa ","DESEJA CONTINUAR?")
				RestArea(aArea)
				Return .F.
			EndIf
			
		EndIf
	
	EndIf
	//Fim
	
	RestArea(aArea)
	
Return .T.