#INCLUDE "EPCP001.CH"
#INCLUDE "PROTHEUS.CH"     
#INCLUDE "topconn.ch"

/*/{Protheus.doc} User Function EPCP001
	Programa de digitacao do inventario dia CMP
	@type  Function
	@author Erike Yuri da Silva
	@since 02/08/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 15798 - Fernando Macieira - 02/08/2021 - OTIMIZAÇÃO ROTINA EPCP001
	@history ticket 18340 - Fernando Macieira - 17/08/2021 - Tratamento de vírgula e pontuação 
	@history ticket 62623 - Fernando Macieira - 19/10/2021 - Check list itens que atrasam o fechamento - Identificar melhorias via TI.
/*/
User Function EPCP001(aRotAuto)

	Local lRet := .T.
	Local aCores	:= {	{'ZAM->ZAM_STATUS=="1"'	, 'ENABLE'    },; // Nao Processado
							{'ZAM->ZAM_STATUS=="2"'	, 'DISABLE'     },; // Processado
							{'ZAM->ZAM_STATUS=="3"'	, 'BR_AMARELO' },; // Estornado						 
							{'ZAM->ZAM_STATUS=="4"'	, 'BR_CINZA' }}  // Erro ao Processar

	Private aRotina := Menudef()
	Private lInvAuto := ( aRotAuto <> NIL )
	Private cCadastro := OemToAnsi(STR0006)   //"Digita‡„o do Invent rio"

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa de digitacao do inventario dia CMP')

	PutSx1("PCP001","01","Sugere informacoes inventario?","¿Sugiere informaciones inventario?","Suggest inventory information?","mv_ch1","N",1,0,1,"C","","","","",	"mv_par01","Sim","Si","Yes","","Nao","No","No","","","","","","","","","")

	Pergunte("PCP001",.F.)

	If lInvAuto .AND. MsRotAuto(3,aRotAuto,"ZAM")
		lRet := .F.
	EndIf

	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ativa tecla F12 para acionar perguntas                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ! lInvAuto
			Set Key VK_F12 To E001PERG()
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Endereca a funcao de BROWSE                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		mBrowse( 6, 1,22,75,"ZAM",,,,,,aCores)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desativa tecla que aciona perguntas                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ! lInvAuto
			Set Key VK_F12 To
		EndIf	
	
	EndIf	

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³EPCP001M  ³ Autor ³Erike Yuri da Silva    ³ Data ³09/02/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de manutencao da digitacao do inventario CMP     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EPCP001M(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EPCP001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function EPCP001M(cAlias,nReg,nOpc)
Local __xRet := NIL    

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa de digitacao do inventario dia CMP')

DO CASE
	Case nOpc==2	//Visualizar
		__xRet := AInvVisu(cAlias,nReg,nOpc)
	Case nOpc==3	//Incluir
		__xRet := AInvIncl(cAlias,nReg,nOpc)  
	Case nOpc==4	//Alterar
		__xRet := AInvAlte(cAlias,nReg,nOpc)
	Case nOpc==5	//Excluir
		__xRet := AInvDele(cAlias,nReg,nOpc)		
	Case nOpc==7
		__xRet := ALegenda()
ENDCASE
Return __xRet   


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³EPCP001X  ³ Autor ³Erike Yuri da Silva    ³ Data ³09/02/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de execucao de rotinas genericas.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EPCP001X(ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EPCP001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function EPCP001X(nOpc)
Local __xRet := NIL  

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa de digitacao do inventario dia CMP')

DO CASE
	Case nOpc==1
		__xRet := AInvProx()                 
	Case nOpc==2
		__xRet := AInvIniC()  
	Case nOpc==3
		__xRet := AInvArm()
	Case nOpc==4
		__xRet := AInvConv() 
	Case nOpc==5
		__xRet := AInvVLot()
	Case nOpc==6
		__xRet := AInvTdOk()	
ENDCASE
Return __xRet   

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AInvAlte  ³ Autor ³Erike Yuri da Silva    ³ Data ³26/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para alteracao da digitacao do Inventario.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AInvAlte(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EPCP001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AInvAlte(cAlias,nReg,nOpc)
Local nOpca:=0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa tecla F4 para comunicacao com Saldos dos Lotes         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! lInvAuto
   Set Key VK_F4 TO ShowF4()
EndIf
dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1")+ZAM->ZAM_COD)
dbSelectArea(cAlias)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para rotina de Alteracao de Acerto do Inventario.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOpca := AxAltera(cAlias,nReg,nOpc,,,,,"u_EPCP001X(6)")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desativa tecla F4 para comunicacao com Saldos dos Lotes      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! lInvAuto
   SET KEY VK_F4 TO
EndIf
Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AInvVisu  ³ Autor ³Erike Yuri da Silva    ³ Data ³26/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para visualizacao da digitacao do inventario.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AInvVisu(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EPCP001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AInvVisu(cAlias,nReg,nOpc)
Local nOpca:=0
dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1")+ZAM->ZAM_COD)
dbSelectArea(cAlias)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para rotina de Alteracao da digitacao do inventario.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOpca := AxVisual(cAlias,nReg,nOpc,,)
Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AInvIncl  ³ Autor ³ Erike Yuri da Silva   ³ Data ³26/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui digitacao do inventario                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AInvIncl(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EPCP001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AInvIncl(cAlias,nReg,nOpc)
Local nOpca		:=0
Local dDataFec	:= GetMV("MV_ULMES")
Local lRet		:= .T.
Local cProduto	:= Space(15)
Local cLocal	:= Space(2)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa tecla F4 para comunicacao com Saldos dos Lotes         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! lInvAuto
   Set Key VK_F4 TO ShowF4()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificar data do ultimo fechamento em SX6.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If dDataFec >= dDataBase
	Help ( " ", 1, "FECHTO" )
	lRet := .F.
EndIf
If lRet
	dbSelectArea("SB2")
	dbSeek(xFilial("SB2"))
	If mv_par01 == 1 .and. Found() .And. !lInvAuto
		While !EOF() .And. B2_FILIAL == xFilial("SB2")
			dbSelectArea("SB1")
			dbSeek(xFilial("SB1")+SB2->B2_COD)
			cProduto:= SB2->B2_COD
			cLocal	:= SB2->B2_LOCAL
			If SldBlqSB2(cProduto,cLocal)
				dbSelectArea(cAlias)
				nOpca := AxInclui(cAlias,nReg,nOpc, ,"u_EPCP001X(1)", ,"u_EPCP001X(6)")
				If nOpca == 1
					dbSelectArea("SB2")				
					dbSeek(xFilial("SB2")+ZAM->ZAM_COD+ZAM->ZAM_LOCAL)
					dbSkip()
				ElseIf nOpca == 3
					Exit
				EndIf
			Else
				dbSelectArea("SB2")				
				dbSkip()
			EndIf	
		EndDo
	Else
		dbSelectArea(cAlias)
		While .T.
			If ( lInvAuto )
				nOpca := AxIncluiAuto(cAlias,"u_EPCP001X(6)")
				Exit
			Else	
				nOpca := AxInclui(cAlias,nReg,nOpc,,,,"u_EPCP001X(6)")
				If nOpca == 3
					Exit
				Endif
			EndIf
		End
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desativa tecla F4 para comunicacao com Saldos dos Lotes      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! lInvAuto
	   SET KEY VK_F4 TO
	Endif
EndIf
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AInvDele  ³ Autor ³Erike Yuri da Silva    ³ Data ³26/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de exclusao de Inventario                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AInvDele(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EPCP001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AInvDele(cAlias,nReg,nOpc)
LOCAL nOpcA,aAC := {OemToAnsi(STR0007),OemToAnsi(STR0008) }   //"Abandona"###"Confirma"
LOCAL dDataFec	:= GetMV("MV_ULMES"),cOldAlias:=Alias()
LOCAL lRet		:= .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificar data do ultimo fechamento em SX6.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If dDataFec >= dDataBase
	Help ( " ", 1, "FECHTO" )
	lRet := .F.
EndIf
                      
If !(ZAM->ZAM_STATUS $ "1|4")
	Aviso("Aviso", "Este lancamento nao pode se excluido, pois ja foi processado!",{"Ok"})
	lRet := .F.
EndIf

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a entrada de dados do arquivo                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aTELA[0][0],aGETS[0]
	While .T.
		dbSelectArea("SB1")
		dbSeek(xFilial("SB1")+ZAM->ZAM_COD)
		dbSelectArea(cOldAlias)
		nOpcA:=0
		DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
		nOpcA:=EnChoice( cAlias, nReg, nOpc, aAC,"AC",OemToAnsi(STR0009) )   //"Quanto … exclus„o?"
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(AInvTOkE(),(nOpca := 2,oDlg:End()),)},{|| nOpca := 1,oDlg:End()})
		DbSelectArea(cAlias)	
		If nOpcA == 2
			Begin Transaction
				DbSelectArea(cAlias)
				RecLock(cAlias,.F.,.T.)
				dbDelete()
			End Transaction
		EndIf
		Exit
	EndDo
EndIf	
DbSelectArea(cAlias)
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AInvProx ³ Autor ³ Erike Yuri da Silva   ³ Data ³26/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apenas para inicializar algumas variaveis                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EPCP001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AInvProx
Local aArea:=GetArea()
M->ZAM_COD   := SB2->B2_COD
M->ZAM_LOCAL := SB2->B2_LOCAL
M->ZAM_TIPO  := SB1->B1_TIPO
dbSelectArea("SX3")
dbSetOrder(2)
If dbSeek("ZAM_DOC") .And. Empty(X3_RELACAO)
	M->ZAM_DOC   := ZAM->ZAM_DOC
EndIf	              
RestArea(aArea)
RETURN

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AInvIniC  ³ Autor ³Erike Yuri da Silva    ³ Data ³26/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicializa campos a partir do codigo do produto            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EPCP001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                 
Static Function AInvIniC()
Local nPos
Local nEnd1,nEnd2,nLinha 
Local aAreaSD3
Local lRet := .T.
If !ExistCpo("SB1")
	lRet := .F.
EndIf
If lRet
	dbSelectArea("SB2")
	If !dbSeek(xFilial("SB2")+M->ZAM_COD) 
		Help(" ",1,"MA270NSB2")
		lRet := .F.
	Else
		M->ZAM_LOCAL := B2_LOCAL	
		If ( nPos := Ascan(aGets,{ |x| Subs(x,9,8) == "ZAM_LOCAL" }) ) > 0
			aTela[Val(Subs(aGets[nPos],1,2))][Val(Subs(aGets[nPos],3,1))*2] := B2_LOCAL
		EndIf
	EndIf
	If lRet
		dbSelectArea("SB1")
		dbSeek(xFilial("SB1")+M->ZAM_COD)
		M->ZAM_DESC := SB1->B1_DESC+" - "+SB1->B1_UM
		If ( nPos := Ascan(aGets,{ |x| Subs(x,9,7) == "ZAM_DESC" }) ) > 0
			aTela[Val(Subs(aGets[nPos],1,2))][Val(Subs(aGets[nPos],3,1))*2] := SB1->B1_DESC+" - "+SB1->B1_UM
		EndIf
		
		M->ZAM_TIPO := B1_TIPO
		If ( nPos := Ascan(aGets,{ |x| Subs(x,9,7) == "ZAM_TIPO" }) ) > 0
			aTela[Val(Subs(aGets[nPos],1,2))][Val(Subs(aGets[nPos],3,1))*2] := B1_TIPO
		EndIf
		M->ZAM_QTSEGU := ConvUm(SB1->B1_COD,M->ZAM_QUANT,M->ZAM_QTSEGU,2)		
		If ( nPos := Ascan(aGets,{ |x| Subs(x,9,10) == "ZAM_QTSEGU" }) ) > 0
			nEnd1 := Val(Subs(aGets[nPos],1,2))
			nEnd2 := Val(Subs(aGets[nPos],3,1))*2
			dbSelectArea("SX3")
			dbSetOrder(2)
			dbSeek("B2_QTSEGUM")
			dbSetOrder(1)
			aTela[nEnd1][nEnd2] := Trans(M->ZAM_QTSEGU,Trim(SX3->X3_PICTURE))
		EndIf
		M->ZAM_NUMLOT := CriaVar("ZAM_NUMLOT")
		If ( nPos := Ascan(aGets,{ |x| Subs(x,9,10) == "ZAM_NUMLOT" }) ) > 0
			aTela[Val(Subs(aGets[nPos],1,2))][Val(Subs(aGets[nPos],3,1))*2] := M->ZAM_NUMLOT
		EndIf
		M->ZAM_LOTECT := CriaVar("ZAM_LOTECT")		
		If (nPos := Ascan(aGets,{ |x| Subs(x,9,10) == "ZAM_LOTECT" })) > 0
			aTela[Val(Subs(aGets[nPos],1,2))][Val(Subs(aGets[nPos],3,1))*2] := M->ZAM_LOTECT
		EndIf
		M->ZAM_DTVALI := CriaVar("ZAM_DTVALI")
		If ( nPos := Ascan(aGets,{ |x| Subs(x,9,10) == "ZAM_DTVALI" }) ) > 0
			aTela[Val(Subs(aGets[nPos],1,2))][Val(Subs(aGets[nPos],3,1))*2] := DTOC(M->ZAM_DTVALI)
		EndIf
	EndIf     
EndIf
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AInvArm   ³ Autor ³Erike Yuri da Silva    ³ Data ³26/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo de armazem                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EPCP001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                
Static Function AInvArm()
Local lRet := .T.
Local lOk  := .F.
Local aAreaSD3
dbSelectArea("SB2")
If !dbSeek(xFilial("SB2")+M->ZAM_COD+M->ZAM_LOCAL) 
	Help(" ",1,"MA270NSB2")
	lRet := .F.
EndIf                        
If lRet
	//Verifica se existe producao para este produto
	DbSelectArea("SD3")
	aAreaSD3 := SD3->(GetArea("SD3"))
	DbSetOrder(7)   
	DbSeek(xFilial("SD3")+M->ZAM_COD+M->ZAM_LOCAL+DTOS(M->ZAM_DATA),.T.) 
	While SD3->(!Eof() .AND. D3_FILIAL+D3_COD+D3_LOCAL==xFilial("SD3")+M->ZAM_COD+M->ZAM_LOCAL .AND. ;
		D3_EMISSAO >= M->ZAM_DATA .And. D3_EMISSAO <= M->ZAM_DTATE)		
		If !Empty(D3_OP) .And. Empty(D3_FLAGINV)
			lOk := .T.
			Exit
		EndIf
		SD3->(DbSkip())	
	EndDo
	If !lOk
		lRet := .F.
		Aviso("Aviso","Não existem consumos em ordens de produção para este Produto/Local no periodo!",{"Ok"})
	EndIf              
	RestArea(aAreaSD3)  	
EndIf

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AInvConv  ³ Autor ³Erike Yuri da Silva    ³ Data ³26/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula e inicializa a quantidade principal ou secundaria  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EPCP001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AInvConv()
Local nPos,nEnd1,nEnd2,nX
Local cQual,nQuant
cQual  := Subs(ReadVar(),4,Len(ReadVar()))
dbSelectArea("SB1")
dbSeek(xFilial("SB1")+M->ZAM_COD)
If cQual == "ZAM_QUANT"
	nQuant := M->ZAM_QTSEGU := ConvUm(B1_COD,M->ZAM_QUANT,M->ZAM_QTSEGU,2)
	cQual  := "ZAM_QTSEGU"
Else
	nQuant := M->ZAM_QUANT   := ConvUm(B1_COD,M->ZAM_QUANT,M->ZAM_QTSEGU,1)
	cQual  := "ZAM_QUANT"
EndIf

//Faz o Arredondamento conforme regra do campo B1_TIPODEC
M->ZAM_QUANT   := A250AvalQt(M->ZAM_QUANT,M->ZAM_COD)
M->ZAM_QTSEGU := A250AvalQt(M->ZAM_QTSEGU,M->ZAM_COD)

nPos := Ascan(aGets,{ |x| Subs(x,9,Len(cQual)) == cQual } )
If nPos > 0
	nEnd1 := Val(Subs(aGets[nPos],1,2))
	nEnd2 := Val(Subs(aGets[nPos],3,1))*2
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek(cQual)
	dbSetOrder(1)
	aTela[nEnd1][nEnd2] := Trans(nQuant,Trim(SX3->X3_PICTURE))
EndIf
Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AInvVLot  ³ Autor ³Erike Yuri da Silva    ³ Data ³26/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o numero do lote com o produto.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EPCP001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/            
Static Function AInvVLot()
LOCAL cLote:=&(ReadVar()),nPos,lRet:=.T.
LOCAL cOldAlias:=Alias(),nOldOrder,nOldRecno
LOCAL cLocalCQ:=GetMV("MV_CQ")
If Rastro(M->ZAM_COD)
	If "M->ZAM_NUMLOT" $ ReadVar()
		If Rastro( M->ZAM_COD, "S" )
			dbSelectArea("SB8")
			nOldOrder:=IndexOrd()
			nOldRecno:=Recno()
			dbSetOrder(2)
			If dbSeek(xFilial("SB8")+cLote) .And. B8_PRODUTO + B8_LOCAL == ;
					M->ZAM_COD + M->ZAM_LOCAL
				If cLocalCQ == B8_LOCAL .And. B8_ORIGLAN != "CQ"
					Help (" ",1,"A270LOTCQ")
					lRet:=.F.
				EndIf
				If lRet
					nPos := Ascan(aGets,{ |x| Subs(x,9,10) == "ZAM_NUMLOT" } )
					If nPos > 0
						aTela[Val(Subs(aGets[nPos],1,2))][Val(Subs(aGets[nPos],3,1))*2] := M->ZAM_NUMLOT
					EndIf
					M->ZAM_LOTECT:=SB8->B8_LOTECTL
					nPos := Ascan(aGets,{ |x| Subs(x,9,10) == "ZAM_LOTECT" } )
					If nPos > 0
						aTela[Val(Subs(aGets[nPos],1,2))][Val(Subs(aGets[nPos],3,1))*2] := B8_LOTECTL
					EndIf
					M->ZAM_DTVALI:=SB8->B8_DTVALID
					nPos := Ascan(aGets,{ |x| Subs(x,9,10) == "ZAM_DTVALI" } )
					If nPos > 0
						aTela[Val(Subs(aGets[nPos],1,2))][Val(Subs(aGets[nPos],3,1))*2] := DTOC(B8_DTVALID)
					EndIf
				EndIf
			Else
				Help (" ",1,"A270LOTERR")
				lRet:=.F.
				nPos := Ascan(aGets,{ |x| Subs(x,9,10) == "ZAM_NUMLOT" } )
				If nPos > 0
					M->ZAM_NUMLOT:=aTela[Val(Subs(aGets[nPos],1,2))][Val(Subs(aGets[nPos],3,1))*2]
				EndIf
				nPos := Ascan(aGets,{ |x| Subs(x,9,10) == "ZAM_LOTECT" } )
				If nPos > 0
					M->ZAM_LOTECT:=aTela[Val(Subs(aGets[nPos],1,2))][Val(Subs(aGets[nPos],3,1))*2]
				EndIf
			EndIf
			dbSetOrder(nOldOrder)
			dbGoto(nOldRecno)
		Else	
			nPos := Ascan(aGets,{ |x| Subs(x,9,10) == "ZAM_NUMLOT" } )
			If nPos > 0
				aTela[Val(Subs(aGets[nPos],1,2))][Val(Subs(aGets[nPos],3,1))*2] := CriaVar("ZAM_NUMLOT")
			EndIf
			M->ZAM_NUMLOT := CriaVar( "ZAM_NUMLOT" )
		EndIf
	Else
		If Rastro( M->ZAM_COD, "S" )
			dbSelectArea( "SB8" )
			dbSetOrder( 3 )
			If dbSeek( xFilial( "SB8" ) + M->ZAM_COD + M->ZAM_LOCAL + cLote + M->ZAM_NUMLOT, .F.) .Or. ;
					dbSeek( xFilial( "SB8" ) + M->ZAM_COD + M->ZAM_LOCAL + cLote, .F.)
				nPos := Ascan(aGets,{ |x| Subs(x,9,10) == "ZAM_NUMLOT" } )
				If nPos > 0
					aTela[Val(Subs(aGets[nPos],1,2))][Val(Subs(aGets[nPos],3,1))*2] := B8_NUMLOTE
				EndIf
				M->ZAM_NUMLOT := SB8->B8_NUMLOTE
				nPos := Ascan(aGets,{ |x| Subs(x,9,10) == "ZAM_DTVALI" } )
				If nPos > 0
					aTela[Val(Subs(aGets[nPos],1,2))][Val(Subs(aGets[nPos],3,1))*2] := DTOC(B8_DTVALID)
				EndIf
				M->ZAM_DTVALI := SB8->B8_DTVALID
			Else
				Help (" ",1,"A270LOTERR")	
				lRet := .F.				
			EndIf
		Else
			dbSelectArea( "SB8" )
			dbSetOrder( 3 )
			If dbSeek( xFilial( "SB8" ) + M->ZAM_COD + M->ZAM_LOCAL + cLote )
				nPos := Ascan(aGets,{ |x| Subs(x,9,10) == "ZAM_DTVALI" } )
				If nPos > 0
					aTela[Val(Subs(aGets[nPos],1,2))][Val(Subs(aGets[nPos],3,1))*2] := DTOC(B8_DTVALID)
				EndIf
				M->ZAM_DTVALI := SB8->B8_DTVALID
			Else
				Help (" ",1,"A270LOTERR")	
				lRet := .F.
			EndIf					
		EndIf
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao utiliza rastreabilidade ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Help (" ",1,"A270LOTEIG")
	M->ZAM_NUMLOT:=CriaVar("B8_NUMLOTE")
	nPos := Ascan(aGets,{ |x| Subs(x,9,10) == "ZAM_NUMLOT" } )
	If nPos > 0
		aTela[Val(Subs(aGets[nPos],1,2))][Val(Subs(aGets[nPos],3,1))*2] := M->ZAM_NUMLOT
	EndIf
	M->ZAM_LOTECT:=CriaVar("B8_LOTECTL")
	nPos := Ascan(aGets,{ |x| Subs(x,9,10) == "ZAM_LOTECT" } )
	If nPos > 0
		aTela[Val(Subs(aGets[nPos],1,2))][Val(Subs(aGets[nPos],3,1))*2] := M->ZAM_LOTECT
	EndIf
	M->ZAM_DTVALI:=CriaVar("B8_DTVALID")
	nPos := Ascan(aGets,{ |x| Subs(x,9,10) == "ZAM_DTVALI" } )
	If nPos > 0
		aTela[Val(Subs(aGets[nPos],1,2))][Val(Subs(aGets[nPos],3,1))*2] := DTOC(M->ZAM_DTVALI)
	EndIf
EndIf
dbSelectArea(cOldAlias)
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AInvTdOk  ³ Autor ³Erike Yuri da Silva    ³ Data ³26/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se o produto ja esta cadastrado nesta data          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EPCP001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/            
Static Function AInvTdOk()
Local lRet	:= .T.
Local lOk	:= .F.
Local cAlias,nOrdem,nRec,nOldOrder,nOldRecno
Local dDataFec := SuperGetMv("MV_ULMES")                                                         
Local cAliasTmp	:= "SQLSD3"
Local cQuery	:= ""
Local lRastro	:= .F.                                                                           
Local lRastroS 	:= .F.
Local lCLocal	:= .F.
Local cEnd,cNumSeri,cLoteCtl,cNumLote
Local aAreaZAM	:= ZAM->(GetArea("ZAM"))
Local aAreaSDB	:= SDB->(GetArea("SDB"))
Local aAreaSD5	:= SD5->(GetArea("SD5"))

cAlias := Alias()
nOrdem := IndexOrd()
nRec   := Recno()  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificar data do ultimo fechamento em SX6.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If dDataFec >= M->ZAM_DATA
	Help ( " ", 1, "FECHTO" )
	lRet := .F.
EndIf

If lRet .And. Rastro(M->ZAM_COD)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida o conteudo dos campos ZAM_LOTECT/ZAM_NUMLOT	 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(M->ZAM_LOTECT)
		Help("",1,"A270LOTOBR")
		lRet:=.F.
	EndIf		
	If lRet .And. Rastro(M->ZAM_COD,"S")
		If Empty(M->ZAM_NUMLOT)
			Help("",1,"A270LOTOBR")
			lRet:=.F.
		EndIf
	ElseIf lRet .And. !Empty(M->ZAM_NUMLOT)
		Help("",1,"A270NLOTE")
		M->ZAM_NUMLOT := CriaVar("ZAM_NUMLOT",.F.)
	EndIf
	
	If lRet
		dbSelectArea("SB8")
		nOldOrder:=IndexOrd()
		nOldRecno:=Recno()
		If Rastro(M->ZAM_COD,"S")
			dbSetOrder(2)
			If dbSeek(xFilial("SB8")+M->ZAM_NUMLOT+M->ZAM_LOTECT+M->ZAM_COD+M->ZAM_LOCAL)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ajusta a data de validade para data original |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !(M->ZAM_DTVALI == SB8->B8_DTVALID)
					Help("",1,"A240DTVALI")
					M->ZAM_DTVALI := SB8->B8_DTVALID
				EndIf
			Else
				lRet:=.F.
			EndIf
		Else
			dbSetOrder(3)
			If dbSeek(xFilial("SB8")+M->ZAM_COD+M->ZAM_LOCAL+M->ZAM_LOTECT)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ajusta a data de validade para data original |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !(M->ZAM_DTVALI == SB8->B8_DTVALID)
					Help("",1,"A240DTVALI")
					M->ZAM_DTVALI := SB8->B8_DTVALID
				EndIf
			Else
				lRet:=.F.
			EndIf
		EndIf
		If !lRet
			Help("",1,"A270LOTERR")
		EndIf
		dbSetOrder(nOldOrder)
		dbGoTo(nOldRecno)
	EndIf

	// Verifica se o produto/local/lote/sub-lote ja esta cadastrado nesta data
	If !ValData(M->ZAM_DATA,M->ZAM_DTATE,M->ZAM_COD,M->ZAM_LOCAL,M->ZAM_LOCALI,M->ZAM_LOTECT,M->ZAM_NUMLOT,M->ZAM_NUM)    
		MsgAlert("Ja existe inventario lancado para este produto/local/lote/sub-lote neste periodo")        
   		lRet := .F.
	Endif 	        			
Else
	lLote:=.T.
	
	// Verifica se o produto/local ja esta cadastrado nesta data
	If !Localiza(M->ZAM_COD)
		If !ValData(M->ZAM_DATA,M->ZAM_DTATE,M->ZAM_COD,M->ZAM_LOCAL,M->ZAM_LOCALI,M->ZAM_LOTECT,M->ZAM_NUMLOT,M->ZAM_NUM)    
			MsgAlert("Ja existe inventario lancado para este produto/local neste periodo")        
   			lRet := .F.
		Endif 	        			
	Endif	
EndIf  

If lRet .And. Localiza(M->ZAM_COD)
	If lRet .And. (Empty(M->ZAM_LOCALI) .And. Empty(M->ZAM_NUMSER))
		Help(" ",1,"LOCALIZOBR")
		lRet:=.F.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia do endereco informado. 	|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. !ExistCpo("SBE",M->ZAM_LOCAL+M->ZAM_LOCALI,1)
		lRet:=.F.	
	EndIf
	If lRet .And. !Empty(M->ZAM_NUMSER)
		dbSelectArea("SB1")
		dbSetOrder(1)
		If dbSeek(xFilial("SB1")+M->ZAM_COD)
			If SB1->B1_QTDSER = 0 .Or. SB1->B1_QTDSER = 1
				If M->ZAM_QUANT # 1 .And. M->ZAM_QUANT # 0
					Help(" ",1,"QUANTSERIE")
					lRet:=.F.
				EndIf
			Else
				If M->ZAM_QTSEGU # 1 .And. M->ZAM_QTSEGU # 0
					Help(" ",1,"QUANTSERIE")
					lRet:=.F.
				EndIf
			EndIf
		EndIf
		// Valida se existe uma digitacao para o mesmo numero de serie na mesma data
		If lRet
			ZAM->(dbSetOrder(1))
			If ZAM->(dbSeek(xFilial("ZAM")+DTOS(M->ZAM_DATA)+M->ZAM_COD+M->ZAM_LOCAL+M->ZAM_LOCALI+M->ZAM_NUMSER+M->ZAM_LOTECT+M->ZAM_NUMLOT))
				Help(" ",1,"QUANTSERIE")
				lRet:=.F.
			Endif			
		EndIf
	EndIf

	// Verifica se o produto/local/endereco ja esta cadastrado nesta data
	If !ValData(M->ZAM_DATA,M->ZAM_DTATE,M->ZAM_COD,M->ZAM_LOCAL,M->ZAM_LOCALI,M->ZAM_LOTECT,M->ZAM_NUMLOT,M->ZAM_NUM)    
		MsgAlert("Ja existe inventario lancado para este produto/local/endereco neste periodo")        
       	lRet := .F.
	Endif 	        			

EndIf

If lRet	
	DbSelectArea("SDB")
	DbSetOrder(1)
	
	DbSelectArea("SD5")
	DbSetOrder(3)
	
	cQuery	:= "SELECT SD3.D3_FILIAL,SD3.D3_COD,SD3.D3_TIPO,SD3.D3_LOCAL,SD3.D3_LOCALIZ,SD3.D3_NUMSERI,SD3.D3_LOTECTL,SD3.D3_NUMLOTE,SD3.D3_NUMSEQ,SD3.D3_OP"
	cQuery	+= " FROM "
	cQuery	+= RetSqlName("SD3")+" SD3,"
	cQuery	+= RetSqlName("SC2")+" SC2 "
	cQuery	+= " WHERE SD3.D3_FILIAL='"+xFilial("SD3")+"' AND" 
	cQuery 	+= " SD3.D3_COD>='"+M->ZAM_COD+"' AND SD3.D3_COD<='"+M->ZAM_COD+"' AND"
	cQuery 	+= " SD3.D3_LOCAL='"+M->ZAM_LOCAL+"' AND"
	cQuery 	+= " SD3.D3_OP<>'' AND"
	cQuery 	+= " SD3.D3_FLAGINV='' AND"
	cQuery	+= " SD3.D3_EMISSAO>='"+DTOS(M->ZAM_DATA)+"' AND SD3.D3_EMISSAO<='"+DTOS(M->ZAM_DTATE)+"' AND" 	
	cQuery 	+= " SD3.D_E_L_E_T_<>'*' AND"
	cQuery 	+= " SC2.C2_FILIAL='"+xFilial("SC2")+"' AND"
	cQuery 	+= " SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN + SC2.C2_GRUPO = SD3.D3_OP AND "
	//cQuery 	+= " SC2.C2_DATRF<>''  AND"
	cQuery 	+= " SC2.D_E_L_E_T_<>'*' "
	
	cQuery	:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
	dbGotop()
	While (cAliasTmp)->(!Eof())		
		lRastro  := Rastro((cAliasTmp)->D3_COD)
		lRastroS := Rastro((cAliasTmp)->D3_COD, 'S')
		lCLocal  := Localiza((cAliasTmp)->D3_COD)
		cEnd	 := (cAliasTmp)->D3_LOCALIZ
		cNumSeri := (cAliasTmp)->D3_NUMSERI
		cLoteCtl := (cAliasTmp)->D3_LOTECTL
		cNumLote := (cAliasTmp)->D3_NUMLOTE     
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o SD3 nao possuir as informacoes de endereco busco no SDB ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   	
		If lCLocal .And. Empty(cEnd) .And. SDB->(DbSeek(xFilial("SDB")+(cAliasTmp)->(D3_COD+D3_LOCAL+D3_NUMSEQ)))
			cEnd 		:= SDB->DB_LOCALIZ
			cNumSeri	:= SDB->DB_NUMSERI
			cLoteCtl	:= SDB->DB_LOTECTL
			cNumLote	:= SDB->DB_NUMLOTE	 
		ElseIf !lCLocal .And. lRastro .And. Empty(cLoteCtl+cNumLote) .And. SD5->(DbSeek(xFilial("SD5")+(cAliasTmp)->(D3_NUMSEQ+D3_COD+D3_LOCAL)))	
			cLoteCtl	:= SD5->D5_LOTECTL
			cNumLote	:= SD5->D5_NUMLOTE
		EndIf  
		
		If (cEnd+cNumSeri+cLoteCtl+cNumLote)==(M->ZAM_LOCALI+M->ZAM_NUMSER+M->ZAM_LOTECT+M->ZAM_NUMLOT)
			lOk := .T.
			Exit
		EndIf
		(cAliasTmp)->(DbSkip())
	EndDo                        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura ambiente                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	(cAliasTmp)->(dbCloseArea())	
	ZAM->(RestArea(aAreaZAM))
	SDB->(RestArea(aAreaSDB))
	SD5->(RestArea(aAreaSD5))
	If !lOk
		lRet := .F.
		Aviso("Aviso","Não existem consumos em ordens de produção para este Produto/Local/Lote/Endereco!",{"Ok"})
	EndIf              
EndIf

dbSelectArea(cAlias)
dbSetOrder(nOrdem)
dbGoto(nRec)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SHOWF4   ³ Autor ³ Erike Yuri da Silva   ³ Data ³26/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada da funcao F4LOTE                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EPCP001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ShowF4()

If AllTrim(Upper(ReadVar())) $ 'M->ZAM_NUMLOTúM->ZAM_LOTECT'
	MyF4Lote(,,,"A270",M->ZAM_COD,M->ZAM_LOCAL,.F.)
ElseIf AllTrim(Upper(ReadVar())) $ 'M->ZAM_LOCALI' 
	MyF4Locali(,,,M->ZAM_COD,M->ZAM_LOCAL)
EndIf	
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ E002PERG ³ Autor ³ Erike Yuri da Silva   ³ Data ³09/02/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada da funcao PERGUNTE                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EPCP001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function E001PERG()
PERGUNTE("PCP001",.T.)
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AInvTOkE  ³ Autor ³ Erike Yuri da Silva   ³ Data ³26/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada da funcao para validar se exclui ou nao registro   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EPCP001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/              
Static Function AInvTOkE()
Local lRet:=.T.        
Local aArea:=GetArea()
dbSelectArea("SB2")
dbSetOrder(1)
If dbSeek(xFilial("SB2")+ZAM->ZAM_COD+ZAM->ZAM_LOCAL) .And. (SB2->B2_DINVENT == ZAM->ZAM_DATA)
	lRet:=(Aviso(OemToAnsi(STR0010),OemToAnsi(STR0011),{OemToAnsi(STR0008),OemToAnsi(STR0007)},1) == 1) //"Atencao"###"Ja foi processado inventario para este produto neste armazem e data , confirma a exclusao ?"
EndIf
RestArea(aArea)
Return lRet



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ALegenda   ³ Autor ³Erike Yuri da Silva   ³ Data ³30/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EPCP001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ALegenda()
Local aLegenda := { {"ENABLE"      ,"Nao Processado"},; 
				     {"DISABLE"    ,"Processado"},;
  					 {"BR_AMARELO" ,"Estornado"},; 				      
				     {"BR_CINZA" ,"Erro ao Processar"} } 

BrwLegenda(cCadastro,"Legenda" ,aLegenda) 

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MyF4Lote ³ Autor ³ Erike Yuri da Silva   ³ Data ³ 06/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a consulta aos Saldos do Lotes da Rastreabilidade      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ F4Lote(a,b,c,ExpC1,ExpC2,ExpC3)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ a,b,c = parametros padroes quando utiliza-se o Set Key     ³±±
±±³          ³ ExpC1 = Programa que chamou a rotina                       ³±±
±±³          ³ ExpC2 = Codigo do Produto                                  ³±±
±±³          ³ ExpC3 = Local                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EPCP001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MyF4Lote(a,b,c,cProg,cCod,cLocal,lParam,cLocaliz)
LOCAL aStruSB8:={} 
LOCAL aArrayF4:={}
LOCAL aHeaderF4:={}
LOCAL nOpt1 := 1,nX, cVar, cSeek, nEndereco
LOCAL cAlias:= Alias(), nOrdem := IndexOrd(), nRec := RecNo()
LOCAL nHdl  := GetFocus(),cCpo
LOCAL oDlg2,cCadastro,nOpca
LOCAL cLoteAnt:="",cLoteFor:="",dDataVali:="",dDataCria:=""
LOCAL lAdd:=.F.,nSalLote:=0, nSalLote2:=0,nPotencia:=0
LOCAL nPos2:=7,nPos3:=5,nPos4:=9
LOCAL aTamSX3:={}, nOAT
LOCAL aCombo1:= {"Lote","Validade","Lote Fornecedor"} 
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := MsAdvSize(.F.)
Local cCombo1		:= ""
Local oCombo1
LOCAL lRastro := Rastro(cCod,"S")						
LOCAL aAreaSBF:={}  
Local cQuery    := ""
Local lQuery    := .F. 
Local cAliasSB8 := "SB8"
Local nLoop     := 0 
Local aUsado     := {}
Local lLote      := .F.
Local lSLote     := .F.
Local nPos       := 0
Local lSelLote := (SuperGetMV("MV_SELLOTE") == "1")

DEFAULT cLocaliz:=""

cCpo := ReadVar()
lParam := IIf(lParam== NIL, .T., lParam) 
SB1->(dbSetOrder(1))
SB1->(MsSeek(xFilial("SB1")+cCod))
lLote  := Rastro(cCod)
lSLote := Rastro(cCod, 'S')
If !lLote
	Help(" ",1,"NAORASTRO")
	Return nil
Endif
If !lRastro
	nPos2:=1;nPos3:=5;nPos4:=8
EndIf	

// Verifica se o arquivo que chamou a consulta tem potencia para informar no lote
If Type("nPosPotenc") != "N"
	nPosPotenc := 0
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o arquivo a ser pesquisado                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB8")
dbSetOrder(1)
cSeek := cCod+cLocal
dbSeek(xFilial("SB8")+cSeek)
If !Found()
	HELP(" ",1,"F4LOTE")
	dbSelectArea(cAlias)
	dbSetOrder(nOrdem)
	dbGoto(nRec)
	Return nil
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem o numero de casas decimais que dever ser utilizado na  ³
//³ consulta.                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTamSX3:=TamSX3(Substr(cCpo,4,3)+"QUANT")
If Empty(aTamSX3)
	aTamSX3:=TamSX3("B8_SALDO")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso utilize controle de enderecamento e tenha endereco      ³
//³ preenchido.                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Localiza(cCod) .And. !Empty(cLocaliz)
	dbSelectArea("SB8")
	dbSetOrder(3)
	dbSelectArea("SBF")
	aAreaSBF:=GetArea()
	dbSetOrder(1)
	cSeek:=xFilial("SBF")+cLocal+cLocaliz+cCod
	dbSeek(cSeek)
	Do While !Eof() .And. cSeek == BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO
		If SB8->(dbSeek(xFilial("SB8")+SBF->BF_PRODUTO+SBF->BF_LOCAL+SBF->BF_LOTECTL+If(!Empty(SBF->BF_NUMLOTE),SBF->BF_NUMLOTE,"")))
			If !Empty(SBF->BF_NUMLOTE) .And. lRastro
				AADD(aArrayF4, {SBF->BF_NUMLOTE,SBF->BF_PRODUTO,Str(SBFSaldo(),14,aTamSX3[2]),Str(SBFSaldo(,,,.T.),14,aTamSX3[2]),SB8->B8_DTVALID,SB8->B8_LOTEFOR,SBF->BF_LOTECTL,SB8->B8_DATA,SB8->B8_POTENCI})
			Else
				AADD(aArrayF4, {SBF->BF_LOTECTL,SBF->BF_PRODUTO,Str(SBFSaldo(),14,aTamSX3[2]),Str(SBFSaldo(,,,.T.),14,aTamSX3[2]),SB8->B8_DTVALID,SB8->B8_LOTEFOR,SB8->B8_DATA,SB8->B8_POTENCI})
			EndIf
		EndIf
		dbSelectArea("SBF")
		dbSkip()
	EndDo
	RestArea(aAreaSBF)
ElseIf lSLote      

	#IFDEF TOP                     

		SB8->( dbSetOrder( 1 ) ) 
	
		lQuery := .T. 
	
		cAliasSB8 := GetNextAlias()
		
		aStruSB8 := SB8->( dbStruct() ) 
		
		cQuery := "SELECT * FROM " + RetSqlName( "SB8" ) + " SB8 "
		cQuery += "WHERE "
		cQuery += "B8_FILIAL='"  + xFilial( "SB8" )+ "' AND " 
		cQuery += "B8_PRODUTO='" + cCod            + "' AND " 
		cQuery += "B8_LOCAL='"   + cLocal          + "' AND "
		cQuery += "D_E_L_E_T_=' ' "
		cQuery += "ORDER BY " + SqlOrder( SB8->( IndexKey() ) ) 		
		
		cQuery := ChangeQuery( cQuery ) 
		
		dbUseArea( .t., "TOPCONN", TcGenQry( ,,cQuery ), cAliasSB8, .f., .t. )
		
		For nLoop := 1 To Len( aStruSB8 ) 			
			If aStruSB8[ nLoop, 2 ] <> "C" 
				TcSetField( cAliasSB8, aStruSB8[nLoop,1],	aStruSB8[nLoop,2],aStruSB8[nLoop,3],aStruSB8[nLoop,4])
			EndIf 		
		Next nLoop 		
		
	#ENDIF		

	While !( cAliasSB8 )->(Eof()) .And. xFilial("SB8")+cSeek == ( cAliasSB8 )->B8_FILIAL+( cAliasSB8 )->B8_PRODUTO+( cAliasSB8 )->B8_LOCAL
		AADD(aArrayF4, {( cAliasSB8 )->B8_NUMLOTE, ( cAliasSB8 )->B8_PRODUTO, Str(SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,NIL,.T.),14,aTamSX3[2]), Str(SB8Saldo(,,,.T.,cAliasSB8,NIL,.T.),14,aTamSX3[2]), ( cAliasSB8 )->B8_DTVALID, ( cAliasSB8 )->B8_LOTEFOR, ( cAliasSB8 )->B8_LOTECTL, ( cAliasSB8 )->B8_DATA,( cAliasSB8 )->B8_POTENCI})
		( cAliasSB8 )->( dbSkip() ) 
	EndDo
	
	If lQuery 
		( cAliasSB8 )->( dbCloseArea() ) 
		dbSelectArea( "SB8" ) 
	EndIf 
	
Else
	#IFDEF TOP 

		SB8->( dbSetOrder( 3 ) ) 
	
		lQuery := .T. 
	
		cAliasSB8 := GetNextAlias()
		
		aStruSB8 := SB8->( dbStruct() ) 
		
		cQuery := "SELECT * FROM " + RetSqlName( "SB8" ) + " SB8 "
		cQuery += "WHERE "
		cQuery += "B8_FILIAL='"  + xFilial( "SB8" )+ "' AND " 
		cQuery += "B8_PRODUTO='" + cCod            + "' AND " 
		cQuery += "B8_LOCAL='"   + cLocal          + "' AND "
		cQuery += "D_E_L_E_T_=' ' "
		cQuery += "ORDER BY " + SqlOrder( SB8->( IndexKey() ) ) 		
		
		cQuery := ChangeQuery( cQuery ) 
		
		dbUseArea( .t., "TOPCONN", TcGenQry( ,,cQuery ), cAliasSB8, .f., .t. )
		
		For nLoop := 1 To Len( aStruSB8 ) 			
			If aStruSB8[ nLoop, 2 ] <> "C" 
				TcSetField( cAliasSB8, aStruSB8[nLoop,1],	aStruSB8[nLoop,2],aStruSB8[nLoop,3],aStruSB8[nLoop,4])
			EndIf 		
		Next nLoop 		
	                                            
	#ELSE
		dbSetOrder(3)
		dbSeek(xFilial("SB8")+cSeek)
	#ENDIF 

	While !( cAliasSB8 )->( Eof()) .And. xFilial("SB8")+cSeek == ( cAliasSB8 )->B8_FILIAL+( cAliasSB8 )->B8_PRODUTO+( cAliasSB8 )->B8_LOCAL
		cLoteAnt:=( cAliasSB8 )->B8_LOTECTL
		cLoteFor:=( cAliasSB8 )->B8_LOTEFOR
		dDataVali:=( cAliasSB8 )->B8_DTVALID
		dDataCria:=( cAliasSB8 )->B8_DATA
		nPotencia:=( cAliasSB8 )->B8_POTENCI
		lAdd:=.F.
		nSalLote :=0
		nSalLote2:=0
		While !( cAliasSB8 )->( Eof() ) .And. xFilial("SB8")+cSeek+cLoteAnt == ( cAliasSB8 )->B8_FILIAL+( cAliasSB8 )->B8_PRODUTO+( cAliasSB8 )->B8_LOCAL+( cAliasSB8 )->B8_LOTECTL
			nSalLote += SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,NIL,.T.)
			nSalLote2+= SB8Saldo(,,,.T.,cAliasSB8,NIL,.T.)
			( cAliasSB8 )->( dbSkip() )
		EndDo
		If QtdComp(nSalLote) > QtdComp(0) .Or. (cProg == "A270" .And. !lParam) 
			AADD(aArrayF4, {cLoteAnt,cCod,Str(nSalLote,14,aTamSX3[2]),Str(nSalLote2,14,aTamSX3[2]), (dDataVali), cLoteFor, dDataCria,nPotencia})
		EndIf
	EndDo
	
	If lQuery 
		( cAliasSB8 )->( dbCloseArea() ) 
		dbSelectArea( "SB8" ) 
	EndIf 
	
EndIf

If !Empty(aArrayF4)

	AAdd( aObjects, { 100, 100, .t., .t.,.t. } )
	AAdd( aObjects, { 100, 30, .t., .f. } )

	aSize[ 3 ] -= 50
	aSize[ 4 ] -= 50 	
	
	aSize[ 5 ] -= 100
	aSize[ 6 ] -= 100
	
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 2 }
	aPosObj := MsObjSize( aInfo, aObjects )

	cCadastro := OemToAnsi("Saldos por Lote")
	nOpca := 0

	DEFINE MSDIALOG oDlg2 TITLE cCadastro From aSize[7],00 To  aSize[6],aSize[5] OF oMainWnd PIXEL	
	@ 7.1,.4 Say OemToAnsi("Pesquisa Por: ")
	If lSLote
		aHeaderF4 := {OemToAnsi("Sub-Lote"),OemToAnsi("Produto"),OemToAnsi("Saldo Atual"),OemToAnsi("Saldo Atual 2aUM"),OemToAnsi("Validade"),OemToAnsi("Lote Fornecedor"),OemToAnsi("Lote"),OemToAnsi("Dt Emissao"),OemToAnsi("Potencia")}
        oQual := VAR := cVar := TWBrowse():New( aPosObj[1][1], aPosObj[1][2], aPosObj[1][3], aPosObj[1][4],,aHeaderF4,,,,,,,{|nRow,nCol,nFlags|(nOpca := 1,oDlg2:End())},,,,,,, .F.,, .T.,, .F.,,, )    
		oQual:SetArray(aArrayF4)
		oQual:bLine := { || aArrayF4[oQual:nAT] }
	Else
		aHeaderF4 := {OemToAnsi("Lote"),OemToAnsi("Produto"),OemToAnsi("Saldo Atual"),OemToAnsi("Saldo Atual 2aUM"),OemToAnsi("Validade"),OemToAnsi("Lote Fornecedor"),OemToAnsi("Dt Emissao"),OemToAnsi("Potencia")}
        oQual := VAR := cVar := TWBrowse():New( aPosObj[1][1], aPosObj[1][2], aPosObj[1][3], aPosObj[1][4],,aHeaderF4,,,,,,,{|nRow,nCol,nFlags|(nOpca := 1,oDlg2:End())},,,,,,, .F.,, .T.,, .F.,,, )    
		oQual:SetArray(aArrayF4)
		oQual:bLine := { || aArrayF4[oQual:nAT] }
	EndIf
	@ aPosObj[2][1]+10,aPosObj[2][2] Say OemToAnsi("Pesquisa Por: ") PIXEL  	
	@ aPosObj[2][1]+10,aPosObj[2][2]+50 MSCOMBOBOX oCombo1 VAR cCombo1 ITEMS aCombo1 SIZE 100,44  VALID F4LotePesq(cCombo1,aArrayF4,oQual,oCombo1) OF oDlg2 FONT oDlg2:oFont PIXEL
	
	DEFINE SBUTTON FROM aPosObj[2][1]+10 ,aPosObj[2][4]-58  TYPE 1 ACTION (nOpca := 1,oDlg2:End()) ENABLE OF oDlg2
	DEFINE SBUTTON FROM aPosObj[2][1]+10 ,aPosObj[2][4]-28   TYPE 2 ACTION oDlg2:End() ENABLE OF oDlg2
	
	ACTIVATE MSDIALOG oDlg2 VALID (nOAT := oQual:nAT,.t.) CENTERED
	
	If nOpca ==1
		If lSLote
			nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "ZAM_NUMLOT" } )
			If nEndereco > 0
				aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][1]
				M->ZAM_NUMLOT := aArrayF4[nOAT][1]
			EndIf
		EndIf
		nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "ZAM_LOTECT" } )
		If nEndereco > 0
			aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][nPos2]
			M->ZAM_LOTECT := aArrayF4[nOAT][nPos2]
		EndIf
		nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "ZAM_DTVALI" } )
		If nEndereco > 0
			M->ZAM_DTVALI := aArrayF4[nOAT][nPos3]
			aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][nPos3]
		EndIf
	EndIf
Else
	HELP(" ",1,"F4LOTE")
Endif
dbSelectArea(cAlias)
dbSetOrder(nOrdem)
dbGoto(nRec)
SetFocus(nHdl)
Return Nil


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MyF4Locali³ Autor ³ Erike Yuri da Silva   ³ Data ³ 06/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a consulta de localizacoes por produto                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ F4Localiz(a,b,c)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ a,b,c = parametros padroes quando utiliza-se o SetKey()    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EPCP001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MyF4Locali( a, b, c, cProd, cLoc, nQtd, cReadVar, lEndOrig )

LOCAL aArrayF4:={},aArrayF4NS:={},nX, cVar
LOCAL cProduto:="" , nPosProd:=0, cLocal:="", nPosLocal:=0, nPosLocaliz:=0, nPosQuant:=0,nPosNumSer:=0
LOCAL nQuant    := 0
LOCAL nQuantLoc := 0
LOCAL nEndereco
LOCAL cChave2
LOCAL cLocaliza  := ""
LOCAL lGetDados := .F.
LOCAL aUsado   := {}
LOCAL nPosNumLote
LOCAL nPosLoteCtl
LOCAL lLote     := .F.
LOCAL cQuant, nOAT
LOCAL lSaida    := .F.
LOCAL oDlg
Local nOpcA      := 0
Local aPosSBF , aArea:=GetArea()
Local lShowNSeri := .F.
Local cNumSerie  := CriaVar( "BF_NUMSERI", .F. ) 
Local nNumSerie  := 0
Local lSelLote   := (SuperGetMV("MV_SELLOTE") == "1")
Local nLoop      := 0
Local dDtValid   := CTOD('  /  /  ')
Local aAreaSB8   := SB8->(GetArea())
Local aDelArrF4  := {}
Local nPos := 0
Default lEndorig := .T.

nQtd := If( ValType( nQtd ) <> "N", 0, nQtd )

lSaida   := .T.
cProduto := M->ZAM_COD
cLocal   := M->ZAM_LOCAL
nQuant   := M->ZAM_QUANT
cNumLote := M->ZAM_NUMLOT
cLoteCtl := M->ZAM_LOTECT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o F4 apenas se o produto tiver controle de localizacao  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Localiza( cProduto )
	If Rastro( cProduto )
		If !Empty( If( Rastro( cProduto, "S" ), cNumLote, cLoteCtl ) )
			lLote := .T.
		EndIf
	EndIf
	aPosSBF := SBF->(GetArea())
	dbSelectArea("SBF")
	cChave2 := xFilial( "SBF" ) + cProduto + cLocal
	cCompara:= "BF_FILIAL+BF_PRODUTO+BF_LOCAL"
	dbSetOrder(2)	
	If lLote
		If Rastro(cProduto,"S")
			cCompara+="+BF_LOTECTL+BF_NUMLOTE"
			cChave2 +=cLoteCtl + cNumLote
		Else
			cCompara+="+BF_LOTECTL"
			cChave2 +=cLoteCtl
		EndIf
	EndIf		
	dbSeek(cChave2)	
	While !SBF->( Eof() ) .And. cChave2 == &(cCompara)	
		nSaldoLoc  := SBF->BF_QUANT - (SBF->BF_EMPENHO+AvalQtdPre("SBF",1))
		nSaldoLoc2 := SBF->BF_QTSEGUM - (SBF->BF_EMPEN2+AvalQtdPre("SBF",1,.T.))
		If QtdComp(nSaldoLoc) > QtdComp(0)
			nScan := AScan( aUsado, { |x| x[1] == SBF->BF_LOCALIZ .And. If(lLote,If(Rastro(cProduto,"S"),x[3]==SBF->BF_LOTECTL.And.x[4]==SBF->BF_NUMLOTE,x[3]==SBF->BF_LOTECTL),.T.) .And. x[5] == If(nPosNumSer>0,SBF->BF_NUMSERI,"")} )
			If nScan <> 0
				nSaldoLoc  -= aUsado[ nScan, 2 ]
				nSaldoLoc2 -= ConvUM(cProduto, aUsado[ nScan, 2 ], 0, 2)
			EndIf
		EndIf		
		If nSaldoLoc > 0
			dDtValid   := CTOD('  /  /  ')
			If Rastro(cProduto)
				dbSelectArea("SB8")
				dbSetOrder(3)                 
				If dbSeek(xFilial("SB8")+cProduto+SBF->BF_LOCAL+SBF->BF_LOTECTL+If(Rastro(cProduto,"S"),SBF->BF_NUMLOTE,""))
					dDtValid:=B8_DTVALID
				EndIf	
			EndIf         
			dbSelectArea("SBF")
			AAdd(aArrayF4NS,{SBF->BF_LOCALIZ,SBF->BF_NUMSERI,TransForm(nSaldoLoc,PesqPict("SBF","BF_QUANT",13)),TransForm(nSaldoLoc2,PesqPict("SBF","BF_QUANT",13)),SBF->BF_LOTECTL,SBF->BF_NUMLOTE,dDtValid})
			AAdd(aArrayF4,{SBF->BF_LOCALIZ,TransForm(nSaldoLoc,PesqPict("SBF","BF_QUANT",13)),TransForm(nSaldoLoc2,PesqPict("SBF","BF_QUANT",13)),SBF->BF_LOTECTL,SBF->BF_NUMLOTE,dDtValid})
			If !Empty(SBF->BF_NUMSERI)
				lShowNSeri := .T.
			EndIf	
		EndIf
		SBF->( dbSkip() )
	EndDo			
	If lShowNSeri
		aArrayF4:=ACLONE(aArrayF4NS)	
	EndIf
	If Len( aArrayF4 ) > 0
		nOpcA := 0
		cCadastro := OemToAnsi("Saldos por Localizacao")
		DEFINE MSDIALOG oDlg TITLE cCadastro From 09,0 To 33,75 OF oMainWnd		
		@ 1.1,  .7  Say OemToAnsi("Produto :")
		@ 1  , 3.8  MSGet cProduto SIZE 150,10 When .F. 
		If lShowNSeri
			@ 2.4,.7 LISTBOX oQual VAR cVar Fields HEADER OemToAnsi("Localizacao"),OemToAnsi("Numero de Serie"),OemToAnsi("Saldo"),OemToAnsi("Saldo 2aUM"),RetTitle("BF_LOTECTL"),RetTitle("BF_NUMLOTE"),RetTitle("B8_DTVALID") SIZE 285,140 ON DBLCLICK (nOpca := 1,oDlg:End())
		Else
			@ 2.4,.7 LISTBOX oQual VAR cVar Fields HEADER OemToAnsi("Localizacao"),OemToAnsi("Saldo"),OemToAnsi("Saldo 2aUM"),RetTitle("BF_LOTECTL"),RetTitle("BF_NUMLOTE"),RetTitle("B8_DTVALID") SIZE 285,140 ON DBLCLICK (nOpca := 1,oDlg:End()) 
		EndIf	
		oQual:SetArray(aArrayF4)
		If lShowNSeri
			oQual:bLine:={ ||{aArrayF4[oQual:nAT,1],aArrayF4[oQual:nAT,2],aArrayF4[oQual:nAT,3],aArrayF4[oQual:nAT,4],aArrayF4[oQual:nAT,5],aArrayF4[oQual:nAT,6],aArrayF4[oQual:nAT,7]}}
		Else
			oQual:bLine:={ ||{aArrayF4[oQual:nAT,1],aArrayF4[oQual:nAT,2],aArrayF4[oQual:nAT,3],aArrayF4[oQual:nAT,4],aArrayF4[oQual:nAT,5],aArrayF4[oQual:nAT,6]}}
		EndIf	
		DEFINE SBUTTON FROM 06  ,264  TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM 18.5,264  TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg VALID (nOAT := oQual:nAT,.t.) CENTERED                 
		
		If nOpca == 1
			If lShowNSeri
				cLocaliza := aArrayF4[ nOAT, 1 ]
				cNumSerie := aArrayF4[ nOAT, 2 ]
				cLoteCtl  := aArrayF4[ nOAT, 5 ]
				cNUMLote  := aArrayF4[ nOAT, 6 ]
				dDtValid  := aArrayF4[ nOAT, 7 ]
				cQuant    := aArrayF4[ nOAT, 3 ]
				cQuant    := StrTran( cQuant, ".", ""  )
				cQuant    := StrTran( cQuant, ",", "." )
				nQuantLoc := Val( cQuant )
			Else
				cLocaliza := aArrayF4[ nOAT, 1 ]
				cLoteCtl  := aArrayF4[ nOAT, 4 ]
				cNUMLote  := aArrayF4[ nOAT, 5 ]
				dDtValid  := aArrayF4[ nOAT, 6 ]
				cQuant    := aArrayF4[ nOAT, 2 ]
				cQuant    := StrTran( cQuant, ".", ""  )
				cQuant    := StrTran( cQuant, ",", "." )
				nQuantLoc := Val( cQuant )
			EndIf	
		EndIf
	Else
		Help( " ", 1, "F4LOCALIZ" )
	EndIf

	If !Empty(cLocaliza) .Or. !Empty(cNumSerie)
		nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "ZAM_LOCALI" } )
		If nEndereco > 0
			aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := cLocaliza
			M->ZAM_LOCALI := cLocaliza
		EndIf

		If nQuant > nQuantLoc
			nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "ZAM_QUANT" } )
			If nEndereco > 0
				aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := nQuantLoc
				M->ZAM_QUANT := nQuantLoc
			EndIf
		EndIf
	EndIf
	RestArea(aPosSBF)
	RestArea(aAreaSB8)
EndIf
RestArea(aArea)
Return .T.           

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ValData   º Autor ³ Eduardo Fernandes  º Data ³  03/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para validar o periodo informado no cadastro de      º±±
±±º          ³ inventario para a chave(produto/local/endereco)    		   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 8.11 - CMP/SA                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValData(dData,dDataAte,cProd,cLocal,cEnderec,cLoteCtl,cNumLote,cNum)

	Local cQuery   := "" 
	Local lRet     := .T.
	Local dUltFech := SuperGetMv("MV_ULMES")

	cQuery := " SELECT ZAM_DATA AS DTAIN, ZAM_DTATE AS DTATE, ZAM_COD AS PROD, "
	cQuery += " ZAM_LOCAL AS LOC, ZAM_LOCALI AS ENDER, ZAM_NUM AS NUM "
	cQuery += " FROM "+ RetSQLName( "ZAM" ) 
	cQuery += " WHERE ZAM_DATA >= '" +Dtos(dUltFech)+ "' AND "
	cQuery += " ZAM_COD = '" +cProd+ "' AND ZAM_LOCAL = '" +cLocal+ "' AND "

	// Filtra por Endereco
	If Localiza(cProd)
		cQuery += " ZAM_LOCALI = '" +cEnderec+ "' AND " 
	Endif

	// Filtra por Lote
	If Rastro(cProd) 
		cQuery += " ZAM_LOTECT = '" +cLoteCtl+ "' AND "
	Endif

	// Filtra por Sub-Lote
	If Rastro(cProd,"S") 
		cQuery += " ZAM_LOTECT = '" +cLoteCtl+ "' AND "
		cQuery += " ZAM_NUMLOT = '" +cNumLote+ "' AND "
	Endif

	cQuery += RetSQLName("ZAM")+ ".D_E_L_E_T_ = ' ' " 
	cQuery += " ORDER BY ZAM_COD,ZAM_LOCAL"
	cQuery := ChangeQuery( cQuery ) 

	If Select("TRBZAM") > 0
		dbSelectArea("TRBZAM")
		dbCloseArea()
	EndIf
		
	TCQUERY cQuery NEW ALIAS "TRBZAM"      
	TcSetField("TRBZAM","DTAIN","D",8,0)
	TcSetField("TRBZAM","DTATE","D",8,0)

	DbSelectArea("TRBZAM")
	TRBZAM->(DBGoTop()) 
		
	If !EOF()
		While !EOF()
			If  (dData >= TRBZAM->DTAIN .And. dData <= TRBZAM->DTATE) .Or.;
				(dDataAte >= TRBZAM->DTAIN .And. dData <= TRBZAM->DTATE)
				If TRBZAM->NUM <> cNum
					lRet:= .F.
					Exit
				Endif	
			Endif
			TRBZAM->(DbSkip())
		End	
	Endif
	TRBZAM->(DbCloseArea())

Return(lRet)            

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 02/08/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function MenuDef()

	Local aRotina :=  {	{"Pesquisar"	,"AxPesqui"   , 0 , 1   },;
						{"Visualizar"	,"u_EPCP001M" , 0 , 2   },;
						{"Incluir"	    ,"u_EPCP001M" , 0 , 3,17},;
						{"Alterar"	    ,"u_EPCP001M" , 0 , 4,17},;
						{"Excluir"	    ,"u_EPCP001M" , 0 , 5,17},;
						{"Historico"	,"u_EPCP005"  , 0 , 6,17},;
						{"Importa XLS"	,"u_ImpXLS1M" , 0 , 7,17},;
						{"Legenda"	    ,"u_EPCP001M" , 0 , 8	} }

RETURN(aRotina)

/*/{Protheus.doc} User Function ImpXLS1M
    Importa Inventário ZAM
    @type  Function
    @author Fernando Macieira
    @since 02/08/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
	@ticket 15798 - Fernando Macieira - 02/08/2021 - OTIMIZAÇÃO ROTINA EPCP001
/*/
User Function ImpXLS1M()

    Local lOk		:= .F.
    Local alSay		:= {}
    Local alButton	:= {}
    Local clTitulo	:= 'IMPORTAÇÃO INVENTÁRIO'
    Local clDesc1   := 'O objetivo desta rotina é gerar o inventário'
    Local clDesc2   := 'na tabela ZAM a partir de um XLS'
    Local clDesc3   := ''
    Local clDesc4   := '( Necessário converter, previamente, esta planilha em arquivo CSV = Separado por ";" )'
    Local clDesc5   := ''

	Private cAliasTRB := ""

    // Garanto uma única thread sendo executada
    If !LockByName("IMPXSL1M", .T., .F.)
        Alert("[IMPXSL1M] - Existe outro processamento sendo executado! Verifique...")
        Return
    EndIf

    // Mensagens de Tela Inicial
    aAdd(alSay, clDesc1)
    aAdd(alSay, clDesc2)
    aAdd(alSay, clDesc3)
    aAdd(alSay, clDesc4)
    aAdd(alSay, clDesc5)

    // Botoes do Formatch
    aAdd(alButton, {1, .T., {|| lOk := .T., FechaBatch()}})
    aAdd(alButton, {2, .T., {|| lOk := .F., FechaBatch()}})

    FormBatch(clTitulo, alSay, alButton)

    If lOk
        Processa( { || RunIMPZAM() }, "Importando inventário..." )
    EndIf

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
    //³Destrava a rotina para o usuário	    ?
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
    UnLockByName("IMPXSL1M")

Return

/*/{Protheus.doc} Static Function RunIMPZAM
    (long_description)
    @type  Static Function
    @author FWNM
    @since 02/08/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function RunIMPZAM()

    Local lFile     := .f.
    Local nCount    := 0
    Local aDadZAM   := {}
    Local aCampos   := {}

    Private cTxt        := ""
    Private cRC1_NUMTIT := ""
    Private nLinhaTXT   := 1 // Começo com 1 devido cabeçalho

    cFile := cGetFile("Arquivos CSV (Separados por Vírgula) | *.CSV",;
    ("Selecione o diretorio onde encontra-se o arquivo a ser processado"), 0, "Servidor\", .t., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE)// + GETF_RETDIRECTORY)

    If At(".CSV", upper(cFile)) > 0
        lFile := .t.
        ft_fUse(cFile)
    Else
        Aviso("EPCP001-01", "Não foi possível abrir o arquivo...", {"&Ok"},, "Arquivo não identificado!")
    EndIf

    // Arquivo TXT
    If lFile
        
        ft_fGoTop()
        
        cVerTab := "DATA INICIAL;DATA FINAL;PRODUTO;ARMAZÉM;DOCUMENTO;QUANTIDADE;ENDEREÇO"
        
        cTxt := AllTrim( ft_fReadLn() )
        
        If cVerTab <> cTXT
            
            Aviso("EPCP001-02", "A importação não será realizada! As colunas do excel precisam ser " + cVerTab, {"&Ok"},, "Versão/Leiaute da planilha incorreta!")
            
        Else
                    
            If Select("TRB") > 0
                TRB->( dbCloseArea() )
            EndIf
                
            // Crio TRB para impressão
            // https://tdn.totvs.com.br/display/framework/FWTemporaryTable
            oTempTable := FWTemporaryTable():New("TRB")
            
            // Arquivo TRB - CONSISTÊNCIAS
            aAdd( aCampos, {'NUMLINHA'   ,"C"    ,10 , 0} )
            aAdd( aCampos, {'STATUS'     ,"C"    ,120, 0} )
            aAdd( aCampos, {'LINHA'      ,"C"    ,254, 0} )
            aAdd( aCampos, {'QUANT'      ,"N"    ,14 , 4} )
            aAdd( aCampos, {'DOC'        ,"C"    ,6  , 0} )
			aAdd( aCampos, {'NUM'        ,"C"    ,6  , 0} )

            oTempTable:SetFields(aCampos)
            oTempTable:AddIndex("01", {"DOC","NUM"} )
            oTempTable:Create()

            ProcRegua(0)

            ft_fSkip() // Pula linha do cabeçalho
            
            // Consistência
            Do While !ft_fEOF()
                
                IncProc( "Consistindo CSV... " + StrZero(nCount++, 9) )
                
                nLinhaTXT++
                cTxt    := ft_fReadLn()
                aDadZAM := Separa(cTxt, ";")

                dZAM_DATA   := CtoD(aDadZAM[1])
                dZAM_DTATE  := CtoD(aDadZAM[2])
				cZAM_COD    := AllTrim(aDadZAM[3])
                cZAMLOCAL   := AllTrim(aDadZAM[4])
                cZAM_DOC    := Left(AllTrim(aDadZAM[5]),6)
                nZAM_QUANT  := Val(StrTran(StrTran(aDadZAM[6],".",""),",",".")) // @history ticket 18340 - Fernando Macieira - 17/08/2021 - Tratamento de vírgula e pontuação 
                cZAMLOCALI  := AllTrim(aDadZAM[7])

                // Efetua consistências
                lZAMOK := ChkDadZAM(aDadZAM)

                aDadZAM := {}
                
                ft_fSkip()
                
            EndDo

            TRB->( dbGoTop() )
            If TRB->( !EOF() )

                If msgYesNo("Consistência finalizada! Existem problemas nos dados que impediram a importação do inventário. Deseja listá-las agora?")
                    ReportZAM()
                EndIf
            
            Else

                // Insere inventário
                ProcRegua(0)

                nCount  := 0
                nLinhaTXT  := 0
                aDadZAM := {}

                ft_fGoTop()
                ft_fSkip() // Pula linha do cabeçalho

                // Importação
                Do While !ft_fEOF()
                    
                    IncProc( "Incluindo inventário, CSV... " + StrZero(nCount++, 9) )
                    
                    nLinhaTXT++
                    cTxt    := ft_fReadLn()
                    aDadZAM := Separa(cTxt, ";")
                    
					dZAM_DATA   := CtoD(aDadZAM[1])
					dZAM_DTATE  := CtoD(aDadZAM[2])
					cZAM_COD    := AllTrim(aDadZAM[3])
					cZAMLOCAL   := AllTrim(aDadZAM[4])
					cZAM_DOC    := Left(AllTrim(aDadZAM[5]),6)
					nZAM_QUANT  := Val(StrTran(aDadZAM[6],",","."))
					cZAMLOCALI  := AllTrim(aDadZAM[7])

					cTipoB1 := Posicione("SB1",1,FWxFilial("SB1")+PadR(cZAM_COD,TamSX3("B1_COD")[1]),"B1_TIPO")

					cZAM_NUM    := u_SXESXF("ZAM")

					RecLock("ZAM", .T.)
						
						ZAM->ZAM_FILIAL   := FWxFilial("ZAM")
						ZAM->ZAM_DATA     := dZAM_DATA
						ZAM->ZAM_DTATE    := dZAM_DTATE
						ZAM->ZAM_COD      := cZAM_COD
						ZAM->ZAM_LOCAL    := cZAMLOCAL
						ZAM->ZAM_DOC      := cZAM_DOC
						ZAM->ZAM_QUANT    := nZAM_QUANT
						ZAM->ZAM_LOCALI   := cZAMLOCALI

						ZAM->ZAM_TIPO     := cTipoB1
						ZAM->ZAM_STATUS   := "1" // Nao Processado
						ZAM->ZAM_USUARI   := cUserName
						ZAM->ZAM_NUM      := cZAM_NUM
						
					ZAM->( msUnLock() )
					
					GrvTRB("Inventário incluído com sucesso no DOC " + cZAM_DOC, AllTrim(Str(nLinhaTXT)), cTXT, nZAM_QUANT, cZAM_DOC, cZAM_NUM)

                    aDadZAM := {}
                    
                    ft_fSkip()
                    
                EndDo
            
                Aviso("EPCP001-03", "Importação finalizada com sucesso! Será gerado um excel com os dados incluídos para sua conferência..." , {"OK"},, "DOC n. " + cZAM_DOC )

                ReportZAM()

            EndIf
            
        EndIf
        
    EndIf
    
Return

/*/{Protheus.doc} Static Function GrvTRB(1, RC1_NUMTIT, cTXT)
    Popula TRB para listagem
    @type  Static Function
    @author FWNM
    @since 23/04/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GrvTRB(cDetalhe, cNumLinha, cTXT, nQtd, cDoc, cNumZAM)

    Default nQtd := 0
    Default cDOC := ""
	Default cNumZAM := ""

    RecLock("TRB", .T.)
	    TRB->NUMLINHA := cNumLinha
		TRB->STATUS   := cDetalhe
		TRB->LINHA    := cTXT
        TRB->QUANT    := nQtd
        TRB->DOC      := cDoc
		TRB->NUM      := cNumZAM
	TRB->( msUnLock() )
	
Return

/*/{Protheus.doc} Static Function ReportZAM
    Gera listagem de inconsistência
    @type  Static Function
    @author user
    @since 23/04/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ReportZAM()

	oReport := ReportDef(@cAliasTRB)
	oReport:PrintDialog()

Return

/*/{Protheus.doc} Static Function ReportDef
	ReportDef
	@type  Function
	@author Fernando Macieira
	@version 01
/*/
Static Function ReportDef(cAliasTRB)
                                   
	Local oReport
	Local oTitulos
	Local aOrdem := {}
	  
	Local cTitulo := "Inclusão Inventário - Resultado"

	cAliasTRB := "TRB"
	
	oReport := TReport():New("IMPZAM",OemToAnsi(cTitulo), /*cPerg*/, ;
	{|oReport| ReportPrint(cAliasTRB)},;
	OemToAnsi(" ")+CRLF+;
	OemToAnsi("")+CRLF+;
	OemToAnsi("") )

	oReport:nDevice     := 4 // XLS

	oReport:SetLandscape()
	//oReport:SetTotalInLine(.F.)
	
	oTitulos := TRSection():New(oReport, OemToAnsi(cTitulo),{"TRB"}, aOrdem /*{}*/, .F., .F.)
	//oReport:SetTotalInLine(.F.)
	
    TRCell():New(oTitulos,	"NUMLINHA"   ,"","Número Linha"                /*Titulo*/,  /*Picture*/ ,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oTitulos,	"STATUS"     ,"","Detalhamento da Ocorrência"  /*Titulo*/,  /*Picture*/ ,70 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oTitulos,	"LINHA"      ,"","Conteúdo Linha"              /*Titulo*/,  /*Picture*/ ,150 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oTitulos,	"QUANT"      ,"","Quantidade Inventário"       /*Titulo*/,  "@E 999,999,999.9999" ,40 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oTitulos,	"DOC"        ,"","Documento Inventário"        /*Titulo*/,   ,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oTitulos,	"NUM"        ,"","Número Inventário"           /*Titulo*/,   ,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

Return oReport

/*/{Protheus.doc} Static Function ReportPrint
	ReportPrint
	@type  Function
	@version 01
/*/
Static Function ReportPrint(cAliasTRB)

	Local oTitulos := oReport:Section(1)
	
	dbSelectArea("TRB")
	TRB->( dbSetOrder(1) )
	
	oTitulos:SetMeter( LastRec() )
	
	TRB->( dbGoTop() )
	Do While TRB->( !EOF() )
		
		oTitulos:IncMeter()
		
		oTitulos:Init()
		
		If oReport:Cancel()
			oReport:PrintText(OemToAnsi("Cancelado"))
			Exit
		EndIf
		
		//Impressao propriamente dita....
		oTitulos:Cell("NUMLINHA")  :SetBlock( {|| TRB->NUMLINHA} )
		oTitulos:Cell("STATUS")    :SetBlock( {|| TRB->STATUS} )
		oTitulos:Cell("LINHA")     :SetBlock( {|| TRB->LINHA} )
		oTitulos:Cell("QUANT")     :SetBlock( {|| TRB->QUANT} )
    	oTitulos:Cell("DOC")       :SetBlock( {|| TRB->DOC} )
    	oTitulos:Cell("NUM")       :SetBlock( {|| TRB->NUM} )

		oTitulos:PrintLine()
		oReport:IncMeter()
	
		TRB->( dbSkip() )
		
	EndDo
	
	oTitulos:Finish()

	If Select("TRB") > 0
		TRB->( dbCloseArea() )
	EndIf
	
	If Select("QRY") > 0
		QRY->( dbCloseArea() )
	EndIf
	
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	
	oTempTable:Delete()

Return

/*/{Protheus.doc} Static Function ChkDadZAM(aDadZAM)
    Checa dados da planilha em busca de inconsistências
    @type  Static Function
    @author FWNM
    @since 02/08/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ChkDadZAM(aDadZAM)

    Local lOk  := .F.
	Local lRet := .t.
	Local lLocaliz := .f.

	// DEBUG
	If nLinhaTXT == 36
		lDebug := .t.
	EndIf

    // Codigo Produto
    If Empty(AllTrim(aDadZAM[3]))
        lRet := .f.
        GrvTRB("Código produto obrigatório", AllTrim(Str(nLinhaTXT)), cTXT, nZAM_QUANT, aDadZAM[5])
    Else
		SB1->( dbSetOrder(1) ) // B1_FILIAL, B1_COD, R_E_C_N_O_, D_E_L_E_T_
		If SB1->( !dbSeek(FWxFilial("SB1")+PadR(aDadZAM[3],TamSX3("B1_COD")[1])) )
			lRet := .f.
			GrvTRB("Código produto não cadastrado", AllTrim(Str(nLinhaTXT)), cTXT, nZAM_QUANT, aDadZAM[5])
		Else
			lLocaliz := AllTrim(SB1->B1_LOCALIZ) == "S"
			If SB1->B1_MSBLQL == "1"
				lRet := .f.
				GrvTRB("Código produto bloqueado", AllTrim(Str(nLinhaTXT)), cTXT, nZAM_QUANT, aDadZAM[5])
			EndIf
		EndIf
	EndIf

    // Codigo Armazém
	If lLocaliz

		If Empty(AllTrim(aDadZAM[4]))
			lRet := .f.
			GrvTRB("Código armazém obrigatório", AllTrim(Str(nLinhaTXT)), cTXT, nZAM_QUANT, aDadZAM[5])
		Else
			NNR->( dbSetOrder(1) ) // NNR_FILIAL, NNR_CODIGO, R_E_C_N_O_, D_E_L_E_T_
			If NNR->( !dbSeek(FWxFilial("NNR")+PadR(aDadZAM[4],TamSX3("NNR_CODIGO")[1])) )
				lRet := .f.
				GrvTRB("Código armazém não cadastrado", AllTrim(Str(nLinhaTXT)), cTXT, nZAM_QUANT, aDadZAM[5])
			EndIf
		EndIf

		// Codigo localizacao
		SBE->( dbSetOrder(1) ) // BE_FILIAL, BE_LOCAL, BE_LOCALIZ, BE_ESTFIS, R_E_C_N_O_, D_E_L_E_T_
		If SBE->( !dbSeek(FWxFilial("SBE")+PadR(aDadZAM[4],TamSX3("NNR_CODIGO")[1])+PadR(aDadZAM[7],TamSX3("BE_LOCALIZ")[1])) )
			lRet := .f.
			GrvTRB("Código endereço não cadastrado neste armazém", AllTrim(Str(nLinhaTXT)), cTXT, nZAM_QUANT, aDadZAM[5])
		EndIf

	Else

		// @history ticket 62623 - Fernando Macieira - 19/10/2021 - Check list itens que atrasam o fechamento - Identificar melhorias via TI.
		If !Empty(AllTrim(aDadZAM[7]))
			lRet := .f.
			GrvTRB("Produto não controla enderaçamento e possui endereço informado", AllTrim(Str(nLinhaTXT)), cTXT, nZAM_QUANT, aDadZAM[5])
		EndIf

	EndIf

    // Documento
    If Empty(AllTrim(aDadZAM[5]))
        lRet := .f.
        GrvTRB("Documento obrigatório", AllTrim(Str(nLinhaTXT)), cTXT, nZAM_QUANT, aDadZAM[5])
    EndIf

    // Valor
    If Val(StrTran(aDadZAM[6],",",".")) < 0
        lRet := .f.
        GrvTRB("Valor negativo", AllTrim(Str(nLinhaTXT)), cTXT, nZAM_QUANT, aDadZAM[5])
    EndIf

    // Dt Inicial
    If CtoD(aDadZAM[1]) < GetMV("MV_ULMES")
        lRet := .f.
        GrvTRB("Dt Inicial inferior MV_ULMES", AllTrim(Str(nLinhaTXT)), cTXT, nZAM_QUANT, aDadZAM[5])
    EndIf

    // Dt Final
    If CtoD(aDadZAM[2]) < GetMV("MV_ULMES")
        lRet := .f.
        GrvTRB("Dt Final inferior MV_ULMES", AllTrim(Str(nLinhaTXT)), cTXT, nZAM_QUANT, aDadZAM[5])
    Else
		If CtoD(aDadZAM[2]) < CtoD(aDadZAM[1])
			lRet := .f.
			GrvTRB("Dt Final inferior inicial", AllTrim(Str(nLinhaTXT)), cTXT, nZAM_QUANT, aDadZAM[5])
		EndIf
	EndIf

	// Invetário Encerrado
	/*
	ZAM->( dbSetOrder(4) ) // ZAM_FILIAL, ZAM_NUM, R_E_C_N_O_, D_E_L_E_T_
	If ZAM->( dbSeek(FWxFilial("ZAM")+cZAM_NUM) )
		If ZAM->ZAM_STATUS=="2" // 1=Nao processado;2=Processado;3=Estornado;4=Erro Processamento
			lRet := .f.
			GrvTRB("Inventário status encerrado", AllTrim(Str(nLinhaTXT)), cTXT, nZAM_QUANT, aDadZAM[5])
		EndIf
	EndIf
	*/

	// Consistência contida na função AInvArm (Verifica se existe producao para este produto)
	SD3->( dbSetOrder(7) )
	If SD3->( dbSeek(FWxFilial("SD3")+PadR(aDadZAM[3],TamSX3("B1_COD")[1])+PadR(aDadZAM[4],TamSX3("NNR_CODIGO")[1])+DtoS(CtoD(aDadZAM[1])),.T.) )
		Do While SD3->( !EOF() .and. SD3->D3_FILIAL+AllTrim(SD3->D3_COD)+AllTrim(SD3->D3_LOCAL) == FWxFilial("SD3")+AllTrim(aDadZAM[3])+AllTrim(aDadZAM[4]) .and. SD3->D3_EMISSAO >= CtoD(aDadZAM[1]) .and. SD3->D3_EMISSAO <= CtoD(aDadZAM[2]) )
			If !Empty(SD3->D3_OP) .and. Empty(SD3->D3_FLAGINV)
				lOk := .T.
				Exit
			EndIf
			SD3->( dbSkip() )
		EndDo

		If !lOk
			lRet := .f.
			GrvTRB("Prod/Local sem consumo em OP no período", AllTrim(Str(nLinhaTXT)), cTXT, nZAM_QUANT, aDadZAM[5])
		EndIf
	EndIf

Return lRet
