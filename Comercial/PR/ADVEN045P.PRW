#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ADVEN045Pº Autor ³ Mauricio - MDS TEC º Data ³  05/04/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Tela para cadastro de valor minimo por segmento para pedidoº±±
±±º          ³ de venda.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ESPECÍFICO A'DORO                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºEverson 15/05/2019. Chamado 049064. Removida rotina de envio de        º±±
±±ºalteração pedido mínimo do segmento. para o Salesforce.                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ADVEN045P() // U_ADVEN045P()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local bNoTTS   := {|| envSF() }    
	Local aButtons := {}
	Local aRotAdic := {}
	//Aadd(aButtons,{ "SALEFORCE", {|| envSFMan() }, "Env. SF", "Env. SF" }  )
	//Aadd(aRotAdic,{ "Env. SF","U_vlrMinSfExp()", 0 , 6 })

	dbSelectArea("ZBP")
	dbSetOrder(1)

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela para cadastro de valor minimo por segmento para pedido de venda')

	//AxCadastro("ZBP",OemToAnsi("Valor minimo por segmento(PV)"),".T.",".T.",aRotAdic,,,, bNoTTS,,,aButtons,,) //Everson 15/05/2019. Chamado 049064.
	AxCadastro("ZBP",OemToAnsi("Valor minimo por segmento(PV)"),".T.",".T.")

Return()

//Everson 15/05/2019. Chamado 049064.
/*User Function vlrMinSfExp()
	
	//
	If MsgYesNo("Deseja enviar os registros relacionados a este segmento " + Alltrim(cValToChar(ZBP->ZBP_CODSEG)) + " para o SalesForce?","Função ADVEN045P")
		envSF()
		
	EndIf

Return Nil

Static Function envSF()
	
	//
	If FindFunction("U_ADVEN076P")
		U_ADVEN076P("","",.F., " AND A1_SATIV1 = '" + Alltrim(cValToChar(ZBP->ZBP_CODSEG)) + "' ","VLRMIN",.T.," Alt - Valor mínimo do pedido ")
	
	EndIf

Retur Nil*/