#include "protheus.ch"
#include "topconn.ch"
#Include "MSGRAPHI.CH"
#Include "FINC030.CH"
#INCLUDE "FILEIO.CH"

Static lFc030Con
Static _oFINC0301
Static _oFINC0302
Static _oFINC0303
Static _oFINC0304
Static _oFINC0305
Static _oFINC0306
Static _oFINC0307
Static _oFINC0308
Static _oFINC0309

#DEFINE POS_DATA		1
#DEFINE POS_TIPO		2
#DEFINE POS_CLIFOR		3
#DEFINE POS_LOJA		4
#DEFINE POS_RECPAG		5
#DEFINE POS_BANCO		6
#DEFINE POS_AGENCIA	7
#DEFINE POS_CONTA		8
#DEFINE POS_NUMCHEQ		9
#DEFINE POS_NATUREZ	10
#DEFINE POS_ORDREC		11
#DEFINE POS_MOTBX		12
#DEFINE POS_TIPODOC	13
#DEFINE POS_VALOR		14
#DEFINE POS_TXMOEDA	15
#DEFINE POS_HISTOR		16
#DEFINE POS_VLMOED2	17
#DEFINE POS_VLJUROS	18
#DEFINE POS_VLMULTA	19
#DEFINE POS_VLDESCO	20

#DEFINE STR0145	"Itens"
#DEFINE STR0146 "Entrega no Prazo"
#DEFINE STR0147 "Entrega Atrasada"
#DEFINE STR0148 "Legenda"
#DEFINE STR0138 "Devolução"
#DEFINE STR0139 "Entrega"
#DEFINE STR0140 "Nota"
#DEFINE STR0141 "Pedido"
#DEFINE STR0142 "Dt Prevista"
#DEFINE STR0143 "Dt Realizada"
#DEFINE STR0144 "Diferença Dias"
#DEFINE STR0149 "Criando Arquivo de Trabalho - Devolução"
#DEFINE STR0150 "Criando Arquivo de Trabalho - Entrega"
#DEFINE STR0146 "Entrega no prazo"
#DEFINE STR0147 "Entrega atrasada"
#DEFINE STR0151 "Nota sem pedido"
#DEFINE STR0152 "Consulta Entrega"
#DEFINE STR0153 "A rotina de consulta Posição Fornecedor(FINC030) já está sendo executada"

/*{Protheus.doc} User Function ADPMS005P
	Tela de consulta sintetica e analitica dos projetos de investimentos
	@type  Function
	@author Fernando Macieira
	@since 18/07/2018
	@version 01
	@history Chamado 045962 - FWNM             - 18/08/2019 - Modificado descritivo do campo 'Consumo Projeto' mostrando sua composicao + Criado aba SA - Solicitacao Armazem + Criado botao de consulta projeto + Criado botao para atualizar consumo do projeto manualmente (alem do schedule)  
	@history Chamado 046284 - FWNM             - 08/01/2019 - Novas regras alteracao valor
	@history Chamado 046111 - William Costa    - 08/01/2019 - Relatorio Excel
	@history Chamado TI     - FWNM             - 22/01/2019 - Compatibilizacao regra query SC7 de acordo com a regra contida na funcao ADCOM017P que busca o consumo do projeto
	@history Chamado TI     - FWNM             - 25/02/2019 - Consumo do projeto errado devido eliminacao residuos e valor total da NF
	@history Chamado 047791 - FWNM             - 12/03/2019 - Composicao do pedido de compras nao estava considerando a nova regra (Valor Mercadoria + impostos + frete + despesas)
	@history Chamado 048763 - FWNM             - 24/04/2019 - Relatorio posicao projetos
	@history Chamado TI     - FWNM             - 27/05/2019 - Retirar mensagens para clicar em todas as abas para exportar excel e gerar todos os arquivos temporarios (abas) quando clicar no botao consultar
	@history Chamado 049785 - FWNM             - 11/06/2019 - Posicao Projetos
	@history Chamado 050791 - FWNM             - 30/07/2019 - Consumo Projetos
	@history Chamado 051453 - Adriana Oliveira - 03/09/2019 - Considerar impostos de importacao no consumo do projeto
	@history Chamado 052816 - FWNM             - 23/10/2019 - Controle Projetos
	@history Chamado 053839 - FWNM             - 05/12/2019 - 053839 || OS 055224 || CONTROLADORIA || DAIANE || (16) || REDUCAO VLR PRJ
	@history Chamado 054064 - FWNM             - 11/12/2019 - OS 055455 || CONTROLADORIA || DAIANE || (16) || SALDO DE PROJETO
/*/
User Function ADPMS005P(cRotina, nPosArotina) // PRODUCAO

	Local lPanelFin := IsPanelFin()
	LOCAL xRet := .T.
	Local lPyme    := Iif(Type("__lPyme") <> "U",__lPyme,.F.)
	Local aRotinaNew
	Local cFilter := Nil
	Local lConsVisual	:= .F.
	
	Private aRotina := MenuDef()
	Private lF030TitAb  := .F.
	Private lF030TitPg  := .F.
	Private lF030TitCom := .F.
	Private lF030TitFat := .F.
	Private oRed		:= LoadBitmap(GetResources(), "BR_VERMELHO")
	Private oGre		:= LoadBitmap(GetResources(), "BR_VERDE")
	Private oYel		:= LoadBitmap(GetResources(), "BR_AMARELO")
	
	Private lF030TitAb := .f.
	Private lF030TitPg := .f.
	Private lF030TitCom := .f.
	Private lF030TitFat := .f.
	
	PRIVATE cCadastro  := OemToAnsi("Posi‡„o Projetos")
	PRIVATE nJuros
	PRIVATE nTotal1    := nTotal2 := nTotal3 := nTotal9 := 0
	PRIVATE dBaixa     := dDataBase
	PRIVATE nVlrGerNF := 0
	PRIVATE nVlrGerNF5:= 0
	
	PRIVATE oFolder030
	Private nDest030
	Private cFilCorr	:= cFilAnt
	
	Private aCposBrw := {}
	Private aCores   := {}
	
	DEFAULT nPosArotina := 0

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de consulta sintetica e analitica dos projetos de investimentos')
	
	dbSelectArea("AF8")
	dbSetOrder(1) 
	
	//Monta Arquivo Temporario
	MsgRun( "Carregando dados dos projetos, aguarde...",,{ || MontaTrab() } )
	
	If nPosArotina > 0 // Sera executada uma opcao diretamento de aRotina, sem passar pela mBrowse
		dbSelectArea("TMP")
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPosArotina,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina)
	Else
		mBrowse( 6, 1,22,75,"TMP",aCposBrw,,,,,,,,,,,,,cFilter)
	Endif
		
	If Select("TMP") > 0
		TMP->(dbCloseArea())
	EndIf

Return

/*{Protheus.doc} Static Function MONTATRAB
	Sem detalhamento
	@type  Function
	@author Fernando Macieira
	@since 18/07/2018
	@version 01
	@history 
*/

Static Function MontaTrab()

	Local aEstrut     := {}
	Local cQuery      := ""
	Local cStatus     := ""
	Local cOrdem     := ""
	Local nX          := 0
	Local nConsumoPrj     := 0
	
	// Chamado n. 046284
	Local cFaseRej := GetMV("MV_#FASREJ",,"01")
	Local cFaseApr := GetMV("MV_#FASEOK",,"03")
	Local cFaseIni := GetMV("MV_PRJINIC",,"05")
	//  
	
	aCposBrw := {}
	
	If Select("TRB") > 0
		TRB->(dbCloseArea())
	EndIf
	
	// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 23/10/2019
//	cQuery := " SELECT AF8_PROJET, AF8_REVISA, AF8_DESCRI, AF8_DATA, AF8_XVALOR, AF8_XCONSU, AF8_XDTCON " // PRODUCAO
	cQuery := " SELECT AF8_PROJET, AF8_REVISA, AF8_DESCRI, AF8_DATA, AF8_XVALOR, AF8_XCONSU, AF8_XDTCON, AF8_XTOTAL, AF8_XVLIPI, AF8_XVLFRE, AF8_XVLDES, AF8_XVLSEG, AF8_XICMSR, AF8_XDESCO, AF8_XVLDEV, AF8_XVLPIS, AF8_XVLCOF, AF8_XVLICM, AF8_XVLRSA " //
	cQuery += " FROM " + RetSqlName("AF8")
	cQuery += " WHERE AF8_FILIAL='"+FWxFilial("AF8")+"' "
	cQuery += " AND AF8_XVALOR > 0 "
	cQuery += " AND AF8_ENCPRJ<>'1' "
	cQuery += " AND AF8_FASE='"+AllTrim(cFaseApr)+"' "
	cQuery += " AND D_E_L_E_T_='' "
	
	tcQuery cQuery new alias "TRB"
	
	aTamSX3 := TamSX3("AF8_DATA")
	tcSetField("TRB", "AF8_DATA", aTamSX3[3], aTamSX3[1], aTamSX3[2])
	
	aTamSX3 := TamSX3("AF8_XVALOR")
	tcSetField("TRB", "AF8_XVALOR", aTamSX3[3], aTamSX3[1], aTamSX3[2])
	
	aTamSX3 := TamSX3("AF8_XDTCON")
	tcSetField("TRB", "AF8_XDTCON", aTamSX3[3], aTamSX3[1], aTamSX3[2])
	
	aTamSX3 := TamSX3("AF8_XCONSU")
	tcSetField("TRB", "AF8_XCONSU", aTamSX3[3], aTamSX3[1], aTamSX3[2])                           
	
	// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 23/10/2019
	aTamSX3 := TamSX3("AF8_XTOTAL")
	tcSetField("TRB", "AF8_XTOTAL", aTamSX3[3], aTamSX3[1], aTamSX3[2])                           
	
	aTamSX3 := TamSX3("AF8_XVLIPI")
	tcSetField("TRB", "AF8_XVLIPI", aTamSX3[3], aTamSX3[1], aTamSX3[2])                           

	aTamSX3 := TamSX3("AF8_XVLFRE")
	tcSetField("TRB", "AF8_XVLFRE", aTamSX3[3], aTamSX3[1], aTamSX3[2])                           

	aTamSX3 := TamSX3("AF8_XVLDES")
	tcSetField("TRB", "AF8_XVLDES", aTamSX3[3], aTamSX3[1], aTamSX3[2])                           

	aTamSX3 := TamSX3("AF8_XVLSEG")
	tcSetField("TRB", "AF8_XVLSEG", aTamSX3[3], aTamSX3[1], aTamSX3[2])                           

	aTamSX3 := TamSX3("AF8_XICMSR")
	tcSetField("TRB", "AF8_XICMSR", aTamSX3[3], aTamSX3[1], aTamSX3[2])                           

	aTamSX3 := TamSX3("AF8_XDESCO")
	tcSetField("TRB", "AF8_XDESCO", aTamSX3[3], aTamSX3[1], aTamSX3[2])                           

	aTamSX3 := TamSX3("AF8_XVLDEV")
	tcSetField("TRB", "AF8_XVLDEV", aTamSX3[3], aTamSX3[1], aTamSX3[2])                           

	aTamSX3 := TamSX3("AF8_XVLPIS")
	tcSetField("TRB", "AF8_XVLPIS", aTamSX3[3], aTamSX3[1], aTamSX3[2])                           

	aTamSX3 := TamSX3("AF8_XVLCOF")
	tcSetField("TRB", "AF8_XVLCOF", aTamSX3[3], aTamSX3[1], aTamSX3[2])                           

	aTamSX3 := TamSX3("AF8_XVLICM")
	tcSetField("TRB", "AF8_XVLICM", aTamSX3[3], aTamSX3[1], aTamSX3[2])                           

	aTamSX3 := TamSX3("AF8_XVLRSA")
	tcSetField("TRB", "AF8_XVLRSA", aTamSX3[3], aTamSX3[1], aTamSX3[2])                           

    //
    
	TRB->(dbGoTop())
	
	If !TRB->(Eof())
		
		aAdd(aCposBrw,      { "Projeto"       , "AF8_PROJET"          ,     "C"     , TamSx3("AF8_PROJET")[1]          , 0, ""})
		aAdd(aCposBrw,      { "Revisão"       , "AF8_REVISA"          ,     "C"     , TamSx3("AF8_REVISA")[1]          , 0, ""})
		aAdd(aCposBrw,      { "Descrição"     , "AF8_DESCRI"          ,     "C"     , TamSx3("AF8_DESCRI")[1]          , 0, ""})
		aAdd(aCposBrw,      { "Dt. Inclusão"  , "AF8_DATA"            ,     "D"     , TamSx3("AF8_DATA")[1]            , 0, ""})
		aAdd(aCposBrw,      { "Vlr. Projeto"  , "AF8_XVALOR"          ,     "N"     , TamSx3("AF8_XVALOR")[1]          , 2, "@E 999,999,999.99"})
		aAdd(aCposBrw,      { "Consumo Prj"   , "AF8_XCONSU"          ,     "N"     , TamSx3("AF8_XCONSU")[1]          , 2, "@E 999,999,999.99"})
		aAdd(aCposBrw,      { "Saldo Prj"     , "SALDO"               ,     "N"     , TamSx3("AF8_XVALOR")[1]          , 2, "@E 999,999,999.99"})
	
		// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 23/10/2019
		//AF8_XTOTAL, AF8_XVLIPI, AF8_XVLFRE, AF8_XVLDES, AF8_XVLSEG, AF8_XICMSR, AF8_XDESCO, AF8_XVLDEV, AF8_XVLRSA
		aAdd(aCposBrw,      { "Total Mercadoria"   , "AF8_XTOTAL"      ,     "N"     , TamSx3("AF8_XTOTAL")[1]          , 2, "@E 999,999,999.99"})
		aAdd(aCposBrw,      { "Total IPI       "   , "AF8_XVLIPI"      ,     "N"     , TamSx3("AF8_XVLIPI")[1]          , 2, "@E 999,999,999.99"})
		aAdd(aCposBrw,      { "Total Frete     "   , "AF8_XVLFRE"      ,     "N"     , TamSx3("AF8_XVLFRE")[1]          , 2, "@E 999,999,999.99"})
		aAdd(aCposBrw,      { "Total Despesas  "   , "AF8_XVLDES"      ,     "N"     , TamSx3("AF8_XVLDES")[1]          , 2, "@E 999,999,999.99"})
		aAdd(aCposBrw,      { "Total Seguro    "   , "AF8_XVLSEG"      ,     "N"     , TamSx3("AF8_XVLSEG")[1]          , 2, "@E 999,999,999.99"})
		aAdd(aCposBrw,      { "Total ICMS-ST   "   , "AF8_XICMSR"      ,     "N"     , TamSx3("AF8_XICMSR")[1]          , 2, "@E 999,999,999.99"})
		aAdd(aCposBrw,      { "Total Desconto  "   , "AF8_XDESCO"      ,     "N"     , TamSx3("AF8_XDESCO")[1]          , 2, "@E 999,999,999.99"})
		aAdd(aCposBrw,      { "Total Devolução "   , "AF8_XVLDEV"      ,     "N"     , TamSx3("AF8_XVLDEV")[1]          , 2, "@E 999,999,999.99"})

		aAdd(aCposBrw,      { "Total PIS       "   , "AF8_XVLPIS"      ,     "N"     , TamSx3("AF8_XVLPIS")[1]          , 2, "@E 999,999,999.99"})
		aAdd(aCposBrw,      { "Total COFINS    "   , "AF8_XVLCOF"      ,     "N"     , TamSx3("AF8_XVLCOF")[1]          , 2, "@E 999,999,999.99"})
		aAdd(aCposBrw,      { "Total ICMS      "   , "AF8_XVLICM"      ,     "N"     , TamSx3("AF8_XVLICM")[1]          , 2, "@E 999,999,999.99"})
		
		aAdd(aCposBrw,      { "Total SA        "   , "AF8_XVLRSA"      ,     "N"     , TamSx3("AF8_XVLRSA")[1]          , 2, "@E 999,999,999.99"})
		//
		
		For nX := 1 To Len(aCposBrw)
			aAdd(aEstrut,     { aCposBrw[nX,2], aCposBrw[nX,3], aCposBrw[nX,4], aCposBrw[nX,5]})
		Next nX
		
		If Select("TMP") > 0
			TMP->(dbCloseArea())
		EndIf
		
		cArqTMP := CriaTrab(aEstrut, .T.)
		dbUseArea(.T.,, cArqTMP, "TMP", .T., .F.)
		IndRegua( "TMP", cArqTMP, "AF8_PROJET",,,"Indexando registros..." )
		
		DbSelectArea("TMP")
		TMP->(dbClearIndex())
		TMP->(dbSetIndex(cArqTMP + OrdBagExt()))
		
		Do While TRB->( !EOF() )
			
			nConsumoPrj := 0
			nConsumoPrj := u_ADCOM017P(TRB->AF8_PROJET,"BROWSE") // Chamado n. 054064 || OS 055455 || CONTROLADORIA || DAIANE || (16) || SALDO DE PROJETO - fwnm - 11/12/2019
			//nConsumoPrj := TRB->AF8_XCONSU
			
			RecLock("TMP", .T.)
			
				TMP->AF8_PROJET  := TRB->AF8_PROJET
				TMP->AF8_REVISA  := TRB->AF8_REVISA
				TMP->AF8_DESCRI  := TRB->AF8_DESCRI
				TMP->AF8_DATA    := TRB->AF8_DATA
				TMP->AF8_XVALOR  := TRB->AF8_XVALOR
				TMP->AF8_XCONSU  := nConsumoPrj
				TMP->SALDO       := TRB->AF8_XVALOR - nConsumoPrj
	
				// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 23/10/2019
	
				//AF8_XTOTAL, AF8_XVLIPI, AF8_XVLFRE, AF8_XVLDES, AF8_XVLSEG, AF8_XICMSR, AF8_XDESCO, AF8_XVLDEV, AF8_XVLPIS, AF8_XVLCOF, AF8_XVLICM, AF8_XVLRSA
	
				TMP->AF8_XTOTAL  := TRB->AF8_XTOTAL
				TMP->AF8_XVLIPI  := TRB->AF8_XVLIPI
				TMP->AF8_XVLFRE  := TRB->AF8_XVLFRE
				TMP->AF8_XVLDES  := TRB->AF8_XVLDES
				TMP->AF8_XVLSEG  := TRB->AF8_XVLSEG
				TMP->AF8_XICMSR  := TRB->AF8_XICMSR
				TMP->AF8_XDESCO  := TRB->AF8_XDESCO
				TMP->AF8_XVLDEV  := TRB->AF8_XVLDEV
				TMP->AF8_XVLPIS  := TRB->AF8_XVLPIS
				TMP->AF8_XVLCOF  := TRB->AF8_XVLCOF
				TMP->AF8_XVLICM  := TRB->AF8_XVLICM
				TMP->AF8_XVLRSA  := TRB->AF8_XVLRSA
				
				//
			
			TMP->(msUnlock())
			
			TRB->(DbSkip())
			
		EndDo
		
	EndIf
	
	If Select("TRB") > 0
		TRB->(dbCloseArea())
	EndIf

Return

/*{Protheus.doc} Static Function MENUDEF
	Sem detalhamento
	@type  Function
	@author Fernando Macieira
	@since 18/07/2018
	@version 01
	@history 
*/

Static Function MenuDef()

	Local aRotina  := { {	OemToAnsi("Pesquisar") 			,"u_AF8Pesqui"  , 0 , 1} ,;   
						{	OemToAnsi("Atualizar Consumo")  ,"u_AF8Atu"  	, 0 , 2} ,;   
						{	OemToAnsi("Consultar") 		    ,"u_ADFc030Con"	, 0 , 4} ,;   
						{	OemToAnsi("Relatório Projetos") ,"u_ADMNT008R"	, 0 , 5} ,; // Chamado n. 046111
						{	OemToAnsi("Histórico Revisões") ,"u_yPMS210Hst"	, 0 , 6} ,; // Chamado n. 048763 || OS 050034 || ENGENHARIA || SILVANA || 8406 || REL. POSICAO PROJETO - FWNM - 24/04/2019
						{	OemToAnsi("Aprovações")         ,"u_PosUpZC7"	, 0 , 7} } // Chamado n. 053839 || OS 055224 || CONTROLADORIA || DAIANE || (16) || REDUCAO VLR PRJ

Return (aRotina)

// ------------------------------------------------------------------------------------------------------------------------------------------------------------

/*{Protheus.doc} User Function ADFC030CON
	Sem detalhamento
	@type  Function
	@author Fernando Macieira
	@since 18/07/2018
	@version 01
	@history 
*/

User Function ADFC030CON()

	Local lPanelFin		:= IsPanelFin()
	Local nCont			:= 0
	Local aTamSX3		:= {}
	Local nTamArray		:= 0
	Local cFilBkp		:= cFilAnt
	Local lC7Fiscori	:= SC7->(FieldPos("C7_FISCORI")) > 0
	Local lProc030a		:= .F.  // Carregar dados de Titulos em aberto
	Local lProc030b		:= .F.  // Carregar dados de Titulos Pagos
	Local lProc030c		:= .F.  // Carregar dados de Pedidos e Produtos
	Local lProc030d		:= .F.  // Carregar dados de Faturamento
	Local lProc030e		:= .F.  // Carregar dados da Devolucao
	Local lProc030f		:= .F.  // Carregar dados da Entrega
	Local lProc030G		:= .F.  // Carregar dados da SA
	
	//Private aCampos1	:= {}
	//Private aCampos2	:= {}
	Private aCampos3	:= {}
	Private aCampos4	:= {}
	Private aCampos5	:= {}
	Private aCampos6	:= {}
	Private aCampos7	:= {}
	Private aCampos8	:= {}
	Private aCampos9	:= {} // FWNM - Chamado n. 045962 
	
	Private aNomearq[9]
	Private aTotal6		:= {0.00,0,0.00,0}
	Private nCasas		:= GetMv("MV_CENT")
	Private nTitulos1	:= nTitulos2 := nTitulos3 := nTitulos4 := nTitulos5 := nTitulos6 := nTitulos7 := nTitulos8 := nTitulos9 := 0
	Private nTot1		:= nTot2     := 0
	Private aSelFil		:= {}
	Private aTmpFil		:= {}
	Private aTmpTables	:= {}

	nTotal1    := nTotal2 := nTotal3 := nTotal9 := 0

	U_ADINF009P('ADPMS005P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de consulta sintetica e analitica dos projetos de investimentos')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega as Perguntas                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPanelFin
		lPergunte := PergInPanel("FIC030",.T.)
	Else
		If FunName()=="FINC030"
			lPergunte := Pergunte("FIC030",.T.)
		Else
			Pergunte("FIC030",.F.)
			lPergunte := .T.
		Endif
	Endif
	
	If !lPergunte
		cFilant := cFilBkp
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pedidos de Compras ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lC7Fiscori
		aCampos3 :=	{{"FILORIG"		, "C", FWSizeFilial(), 0, SX3->(RetTitle("C7_FISCORI"))}, ;
		{ "NUMERO"		, "C", 06, 0,OemToAnsi(STR0007) }, ;				 //"Numero"
		{ "EMISSAO"		, "D", 08, 0,OemToAnsi(STR0010) }, ;			     //"Emissao"
		{ "ENTREGA"		, "D", 08, 0,OemToAnsi(STR0135) }, ;				 //"Data de Entrega"
		{ "VALORITEM"	, "N", 16, 2,OemToAnsi("Total PC") }}					 //"Valor Item"
	Else
		aCampos3 :=	{{"NUMERO"	, "C", 06, 0,OemToAnsi(STR0007) }, ;					 //"Numero"
		{ "EMISSAO"		, "D", 08, 0,OemToAnsi(STR0010) }, ;			     //"Emissao"
		{ "ENTREGA"		, "D", 08, 0,OemToAnsi(STR0135) }, ;				 //"Data de Entrega"
		{ "VALORITEM"	, "N", 16, 2,OemToAnsi("Total PC")}}					 //"Valor Item"
	Endif
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faturamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCampos4:=		{{"FILORIG"		, "C", FWSizeFilial(), 0, SX3->(RetTitle("F1_FILORIG"))}, ;
	{ "NUMERO"		, "C", TamSX3("F2_DOC")[1],TamSX3("F2_DOC")[2],OemToAnsi(STR0007)}, ;		//"Numero"
	{ "EMISSAO"		, "D", 08, 0,OemToAnsi(STR0010) }, ;					//"Emissao"
	{ "VALORNOTA"	, "N", 16, 2,OemToAnsi(STR0030) }, ;					//"Valor Nota"
	{ "DUPLICATA"	, "C", TamSX3("E1_NUM")[1], 0,OemToAnsi(STR0031) }, ;			 	//"Duplicata"
	{ "PEDIDO"	    , "C", TamSX3("C7_NUM")[1], 0,OemToAnsi("Pedido") }, ;			 	//"Duplicata"
	{ "ITEMPC"	    , "C", TamSX3("D1_ITEMPC")[1], 0,OemToAnsi("Item PC") }, ;			 	//"Duplicata"
	{ "XX_RECNO"	, "N",12, 0,"RECNO" }}			 						//"Recno"
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Produtos de Compras ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Prd_Sx3  := TamSX3("C7_PRODUTO")
	Qtd_Sx3  := TamSX3("C7_QUANT")
	Prc_Sx3  := TamSX3("C7_PRECO")
	Desc_Sx3  := TamSX3("C7_DESCRI")
	
	If lC7Fiscori
		aCampos5 :=	{{"FILORIG"	, "C", FWSizeFilial(), 0, SX3->(RetTitle("C7_FISCORI"))}, ;
		{"NUMERO"   , "C", 06, 0,OemToAnsi(STR0007) }, ;							//"Numero"
		{"EMISSAO"	, "D", 08, 0,OemToAnsi(STR0010) }, ;							//"Emissao"
		{"PRODUTO"	, "C", Prd_Sx3[1],Prd_Sx3[2],OemToAnsi(STR0032) }, ;			//"Produto"
		{"DESCRI"	, "C", Desc_Sx3[1],Desc_Sx3[2],OemToAnsi(STR0132)  }, ;			//"Descrição"
		{"UM"		, "C", 02, 0,OemToAnsi(STR0033) }, ;						 	//"UM"
		{"SEGUM"	, "C", 02, 0,OemToAnsi(STR0034) }, ;						 	//"2a.UM"
		{"QUANT"	, "N", Qtd_Sx3[1],Qtd_Sx3[2],OemToAnsi(STR0035) }, ;			//"Quantidade"
		{"QTSEGUM"	, "N", Qtd_Sx3[1],Qtd_Sx3[2],OemToAnsi(STR0036) }, ;		 	//"Quant.2a."
		{"PRECO"	, "N", Prc_Sx3[1],Prc_Sx3[2],OemToAnsi(STR0037) }, ; 	    	//"Vlr.Unit."
		{"CONDPAG"	, "C", 03,0,OemToAnsi(STR0038)}} 						 		//"Cond.Pagto."
	Else
		aCampos5 :=	{{"NUMERO"   , "C", 06, 0,OemToAnsi(STR0007) }, ;						 //"Numero"
		{"EMISSAO"	, "D", 08, 0,OemToAnsi(STR0010) }, ;						 //"Emissao"
		{"PRODUTO"	, "C", Prd_Sx3[1],Prd_Sx3[2],OemToAnsi(STR0032) }, ;		 //"Produto"
		{"DESCRI"	, "C", Desc_Sx3[1],Desc_Sx3[2],OemToAnsi(STR0132)  }, ;		//"Descrição"
		{"UM"		, "C", 02, 0,OemToAnsi(STR0033) }, ;						 //"UM"
		{"SEGUM"	, "C", 02, 0,OemToAnsi(STR0034) }, ;						 //"2a.UM"
		{"QUANT"	, "N", Qtd_Sx3[1],Qtd_Sx3[2],OemToAnsi(STR0035) }, ;		 //"Quantidade"
		{"QTSEGUM"	, "N", Qtd_Sx3[1],Qtd_Sx3[2],OemToAnsi(STR0036) }, ;		 //"Quant.2a."
		{"PRECO"	, "N", Prc_Sx3[1],Prc_Sx3[2],OemToAnsi(STR0037) }, ; 	     //"Vlr.Unit."
		{"CONDPAG"	, "C", 03,0,OemToAnsi(STR0038)}} 						 //"Cond.Pagto."
	Endif
	
	If cPaisLoc	!=	"BRA"
		aCampos6 :=	{{"FILORIG"		, "C", FWSizeFilial(), 0, SX3->(RetTitle("E2_FILORIG"))}, ;
		{"SITUACION"	, "C", 08,0,OemToAnsi(STR0039) }, ;							//"Situacao"
		{"NUMERO"		, "C", TamSx3("EF_NUM")[1],0,OemToAnsi(STR0007) }, ;		//"Numero"
		{"EMISSAO"		, "D", 08,0,OemToAnsi(STR0010) }, ;							//"Emissao"
		{"VENCTO"		, "D", 08,0,OemToAnsi(STR0011) }, ;							//"Data Vencimento"
		{"VALOR"		, "N", 16,2,OemToAnsi(STR0040) }, ;							//"Valor T¡tulo"
		{"MONEDA"		, "N", 02,0,OemToAnsi(STR0041) }, ;							//"Moeda"
		{"VLMOED1"		, "N", 16,2,OemToAnsi(STR0042)+Getmv("MV_MOEDAP1") }, ;		//"Valor Pesos"
		{"ORDPAGO"		, "C", TamSx3("E2_ORDPAGO")[1],0,OemToAnsi(STR0020) }, ;	//"Ord. de Pago"
		{"BANCO"		, "C", 03,0,OemToAnsi(STR0024) }, ;							//"Banco"
		{"AGENCIA"		, "C", 05,0,OemToAnsi(STR0025) }, ;							//"Agencia"
		{"CUENTA"		, "C", 10,0,OemToAnsi(STR0026) }, ;							//"Conta"
		{"DTBAIXA"		, "D", 08,0,OemToAnsi(STR0023) }}							//"Data Baixa"
	Endif
	
	aCampos7 :=	{{"FILORIG"		, "C", FWSizeFilial(), 0, SX3->(RetTitle("E2_FILORI"))}, ;
	{ "NUMERO" 	 	, "C", TamSX3("F2_DOC")[1], 0,OemToAnsi(STR0007) }, ;		//"Numero"
	{ "EMISSAO"		, "D", 08, 0,OemToAnsi(STR0010) }, ;		//"Emissao"
	{ "VALORNOTA"	, "N", 16, 2,OemToAnsi("Total PC") },;			//"Valor Item"
	{ "XX_RECNO"	, "N",12, 0,"RECNO"}}
	
	aTamNf   := TamSX3("F1_DOC")
	
	aCampos8 :=	{{"FILORIG"		, "C", FWSizeFilial(), 0, SX3->(RetTitle("E2_FILORI"))}, ;
	{ "NOTA"  	    , "C", TamSX3("F1_DOC")[1], 0,"NOTA"}, ;
	{ "EMISNF"      , "D", 08, 0,"EMISSAO" },;
	{ "PEDIDO"      , "C", TamSX3("C7_NUM")[1], 0,"PEDIDO" },;
	{ "EMISPD"      , "D", 08, 0,"EMISSAO" },;
	{ "PRODUTO"     , "C", TamSX3("D1_COD")[1], 0,"PRODUTO" },;
	{ "DESCR"       , "C", TamSX3("B1_DESC")[1],0,"DESCRICAO"},;
	{ "DT_PREV"     , "D", 08, 0,"PREVISTA" },;
	{ "DT_REAL"     , "D", 08, 0,"REALIZADA" },;
	{ "DIF_DIAS"    , "N", 12, 0,"DIFERENCA" },;
	{ "LEG"         , "C", 1,  0,"LEGENDA" },;
	{ "XX_RECNO"	, "N", 12, 0,"RECNO"}}
	
	
	aCampos9 :=	{{"FILIAL"		, "C", FWSizeFilial(), 0, SX3->(RetTitle("CP_FILIAL"))}, ;
	{ "SA"    	    , "C", TamSX3("CP_NUM")[1], 0,"SA"}, ;
	{ "EMISSAO"     , "D", 08, 0,"EMISSAO" },;
	{ "PRODUTO"     , "C", TamSX3("CP_PRODUTO")[1], 0,"PRODUTO" },;
	{ "DESCR"       , "C", TamSX3("CP_DESCRI")[1],0,"DESCRICAO"},;
	{ "QUANTIDADE"  , "N", 12, 2,"QUANTIDADE" },;
	{ "VALOR"		, "N", 12, 2,"VALOR"},;
	{ "XX_RECNO"	, "N", 12, 0,"RECNO"}}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria os arquivos temporarios ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Processa( { |lEnd| Fc030Procri() } )

	// Chamado TI - incluido mensagem 'todas as outras abas' - FWNM - 27/05/2019
	Processa( { |lEnd| Fc030Gera(6) } ) // ABA ENTREGA      - CARQ8
	Processa( { |lEnd| Fc030Gera(5) } ) // ABA DEVOLUÇÃO    - CARQ7
	Processa( { |lEnd| Fc030Gera(3) } ) // ABA PC + PRENOTA - CARQ3
	Processa( { |lEnd| Fc030Gera(4) } ) // ABA NOTAS CLASSIFICADAS - CARQ4
	Processa( { |lEnd| Fc030Gera(7) } ) // // ABA SA - CARQ9
	//
	
	If Empty(aSelFil)
		If FWModeAccess("AF8",3) == "C"
			aSelFil := FWAllFilial(FWCompany("AF8"),FWUnitBusiness("AF8"),,.F.)
		Else
			Aadd(aSelFil,Xfilial("AF8"))
		EndIf
	Endif
	
	FC030Mostr(lProc030a ,lProc030b,lProc030c,lProc030d,lProc030e,lProc030f,lProc030g)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga os arquivos temporarios ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCont := 1 To Len(aTmpTables)
		If &(aTmpTables[nCont]) <> Nil
			&(aTmpTables[nCont]):Delete()
			&(aTmpTables[nCont]) := Nil
		EndIf
	Next nCont
	
	lProc030a := .F.  // Carregar dados de Titulos em aberto
	lProc030b := .F.  // Carregar dados de Titulos Pagos
	lProc030c := .F.  // Carregar dados de Pedidos e Produtos
	lProc030d := .F.  // Carregar dados de Faturamento
	lProc030e := .F.  // Carregar dados da Devolucao
	lProc030f := .F.  // Carregar dados da Entrega
	lProc030g := .F.  // Carregar dados da SA
	
	FC030QFil(2)
	
	cFilant := cFilBkp

Return

/*{Protheus.doc} Static Function FC030CRIA
	Sem detalhamento
	@type  Function
	@author Fernando Macieira
	@since 18/07/2018
	@version 01
	@history 
*/

Static Function Fc030Cria(aCampos, nCont)

	Local lFc030Ind := Existblock("Fc030Ind")
	Local cCpoUser  := ""
	
	If(nCont == 3)
		
		If(_oFINC0303 <> NIL)
			_oFINC0303:Delete()
			_oFINC0303 := NIL
			
		EndIf
		_oFINC0303 := FwTemporaryTable():New("cArq" + Str(nCont,1))
		_oFINC0303:SetFields(aCampos)
		
	ElseIf(nCont == 4)
		
		If(_oFINC0304 <> NIL)
			_oFINC0304:Delete()
			_oFINC0304 := NIL
		EndIf
		_oFINC0304 := FwTemporaryTable():New("cArq" + Str(nCont,1))
		_oFINC0304:SetFields(aCampos)
		
	ElseIf(nCont == 5)
		
		If(_oFINC0305 <> NIL)
			_oFINC0305:Delete()
			_oFINC0305 := NIL
			
		EndIf
		_oFINC0305 := FwTemporaryTable():New("cArq" + Str(nCont,1))
		_oFINC0305:SetFields(aCampos)
		
	ElseIf(nCont == 6)
		
		If(_oFINC0306 <> NIL)
			_oFINC0306:Delete()
			_oFINC0306 := NIL
		EndIf
		
		_oFINC0306 := FwTemporaryTable():New("cArq" + Str(nCont,1))
		_oFINC0306:SetFields(aCampos)
		
	ElseIf(nCont == 7)
		
		If(_oFINC0307 <> NIL)
			_oFINC0307:Delete()
			_oFINC0307 := NIL
		EndIf
		_oFINC0307 := FwTemporaryTable():New("cArq" + Str(nCont,1))
		_oFINC0307:SetFields(aCampos)
	
	ElseIf(nCont == 9)
		
		If(_oFINC0309 <> NIL)
			_oFINC0309:Delete()
			_oFINC0309 := NIL
		EndIf
		_oFINC0309 := FwTemporaryTable():New("cArq" + Str(nCont,1))
		_oFINC0309:SetFields(aCampos)
		
	Else
		
		If(_oFINC0308 <> NIL)
			_oFINC0308:Delete()
			_oFINC0308 := NIL
		EndIf
		_oFINC0308 := FwTemporaryTable():New("cArq" + Str(nCont,1))
		_oFINC0308:SetFields(aCampos)
		
	EndIf
	
	If(nCont == 1)
		
		_oFINC0301:AddIndex("1",{"DATAVENC"})
		_oFINC0301:Create()
		aAdd(aTmpTables, "_oFINC0301")
		
	ElseIf(nCont == 2)//Titulos a Pagar
		
		If(!Empty(cCpoUser))
			_oFINC0302:AddIndex("1", Strtokarr2( cCpoUser, "+"))
		EndIf
		_oFINC0302:Create()
		aAdd(aTmpTables, "_oFINC0302")
		
	ElseIf(nCont == 3)//Pedidos de Compra
		
		_oFINC0303:AddIndex("1",{"NUMERO"})
		_oFINC0303:Create()
		aAdd(aTmpTables, "_oFINC0303")
		
	ElseIf(nCont == 4 )
		
		If(!Empty(cCpoUser))
			_oFINC0304:AddIndex("1", Strtokarr2( cCpoUser, "+"))
		Else
			_oFINC0304:AddIndex("1", {"FILORIG","NUMERO"})
		EndIf
		_oFINC0304:Create()
		aAdd(aTmpTables, "_oFINC0304")
		
	ElseIf(nCont == 5)
		
		_oFINC0305:AddIndex("1",{"NUMERO"})
		_oFINC0305:Create()
		aAdd(aTmpTables, "_oFINC0305")
		
	ElseIf(cPaisLoc != "BRA" .And. nCont == 6)
		
		_oFINC0306:AddIndex("1",{"DTBAIXA","VENCTO"})
		_oFINC0306:Create()
		aAdd(aTmpTables, "_oFINC0306")
		
	ElseIf(nCont == 7)
		
		_oFINC0307:AddIndex("1",{"NUMERO"})
		_oFINC0307:Create()
		aAdd(aTmpTables, "_oFINC0307")
		
	ElseIf(nCont == 8)
		
		_oFINC0308:AddIndex("1",{"NOTA"})
		_oFINC0308:Create()
		aAdd(aTmpTables, "_oFINC0308")
	
	ElseIf(nCont == 9)
		
		_oFINC0309:AddIndex("1",{"SA"})
		_oFINC0309:Create()
		aAdd(aTmpTables, "_oFINC0309")
		
	EndIf

Return

/*{Protheus.doc} Static Function FC030MOSTR
	Sem detalhamento
	@type  Function
	@author Fernando Macieira
	@since 18/07/2018
	@version 01
	@history 
*/

Static Function FC030Mostr(lProc030a,lProc030b,lProc030c,lProc030d,lProc030e,lProc030f,lProc030g)

	Local lPanelFin := IsPanelFin()
	Local oDlg		:= Nil
	Local cMoeda	:= ""
	Local cPict		:= ""
	Local cRetCGC 	:= RTrim(RetTitle("A2_CGC"))
	Local aObjects	:= {},aPosObj :={}
	Local aSize   	:= MsAdvSize(.f.)
	Local aInfo   	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	Local oBtnNF	:= Nil
	Local nTamArray := 0
	Local lC7Fiscori	:=	SC7->(FieldPos("C7_FISCORI")) > 0
	
	Private oLbx,oLbx1,oLbx2,oLbx3,oLbx4,oLbx5,oLbx6,oLbx7 // Chamado n. 045962 - FWNM
	
	cMoeda   	  := GetMv("MV_MCUSTO")
	cMoeda   	  := SubStr(Getmv("MV_SIMB"+cMoeda)+Space(4),1,4)
	lFc030Con	  := If(lFc030Con==Nil,ExistBlock("FC030CON"),lFc030Con)
	cPict    	  := PesqPict("SA2","A2_CGC")
	
	AADD(aObjects,{100,040,.T.,.F.,.F.})
	AADD(aObjects,{100,100,.T.,.T.,.F.})
	aPosObj:=MsObjSize(aInfo,aObjects)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5]
	oDlg:lMaximized := .T.
	
	@ 001,aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4] OF oDlg PIXEL
	
	@ 004,008 SAY OemToAnsi("Projeto")	 SIZE 021,7 OF oDlg PIXEL			 //"Codigo"
	@ 004,116 SAY OemToAnsi("Revisão")	 SIZE 022,7 OF oDlg PIXEL			 //"Loja"
	@ 004,180 SAY OemtoAnsi("Descrição") SIZE 030,7 OF oDlg PIXEL			 //"Nome"

	@ 012,007 MSGET TMP->AF8_PROJET	SIZE 060,9 OF oDlg PIXEL When .F.
	@ 012,115 MSGET TMP->AF8_REVISA SIZE 020,9 OF oDlg PIXEL When .F.
	@ 012,179 MSGET TMP->AF8_DESCRI SIZE 250,9 OF oDlg PIXEL When .F.
	
	@ 012,450 BUTTON OemToAnsi('Exportar Excel') SIZE 42,13 FONT oDlg:oFont ACTION EXPEXCEL(TMP->AF8_PROJET,TMP->AF8_XVALOR,TMP->AF8_XCONSU,(TMP->AF8_XVALOR - TMP->AF8_XCONSU)) OF oDlg PIXEL //"Exportar Excel"
	@ 012,500 BUTTON OemToAnsi(STR0048)     	 SIZE 42,13 FONT oDlg:oFont ACTION oDlg:End()                OF oDlg PIXEL //"Sair"
	
	@ 028,550 SAY OemtoAnsi("* Valores contidos nas consultas convertidos em R$") SIZE 200,100 COLORS CLR_GREEN OF oDlg PIXEL

	cFolder1 := OemToAnsi("Informacoes Projeto")
	cFolder4 := OemToAnsi("(+) PC Total e Parcial e PreNota")
	cFolder5 := OemToAnsi("(+) Notas Classificadas")
	cFolder6 := OemToAnsi("Produtos")

	cFolder7 := OemToAnsi("(-) Devolucao")
	cFolder8 := OemToAnsi("Entrega")
	cFolder9 := OemToAnsi("(+) Solicitação Armazem")

	/*
	aFolder  := {cFolder1,cFolder4,cFolder5,cFolder6}
	
	cFolder7 := OemToAnsi(STR0138)  //"Devolução"
	aAdd(aFolder,cFolder7)
	
	cFolder8 := OemToAnsi(STR0139) //"Entrega"
	aAdd(aFolder,cFolder8)
	
	cFolder9 := OemToAnsi("SA - Solic. Armazéns")
	aAdd(aFolder,cFolder9)
	*/

	aFolder  := { cFolder1, cFolder5, cFolder4, cFolder9, cFolder7, cFolder6, cFolder8 }

	oFolder030:=TFolder():New(aPosObj[2,1],aPosObj[2,2],aFolder,{},oDlg,,,, .T., .F.,aPosObj[2,4]-5,aPosObj[2,3]-55,)
	oFolder030:bSetOption:={|nDest030| Fc030ChFol(nDest030,oFolder030:nOption,@lProc030a,@lProc030b,@lProc030c,@lProc030d,@lProc030e,@lProc030f,@lProc030g,oLbx,oLbx1,oLbx2,oLbx3,oLbx4,oLbx5,oLbx6,oLbx7)} // Chamado n. 045962 - FWNM
	oFolder030:aDialogs[1]:oFont :=oDlg:oFont
	oFolder030:aDialogs[2]:oFont :=oDlg:oFont
	oFolder030:aDialogs[3]:oFont :=oDlg:oFont
	oFolder030:aDialogs[4]:oFont :=oDlg:oFont
	oFolder030:aDialogs[5]:oFont :=oDlg:oFont
	oFolder030:aDialogs[6]:oFont :=oDlg:oFont
	oFolder030:aDialogs[7]:oFont :=oDlg:oFont
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Informacoes do Folder - Inf.Gerais                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If AF8->(FieldPos("AF8_XCONSU")) > 0
		nConsumo := TMP->AF8_XCONSU
	Else
		nConsumo := 0
	EndIf
	
	nSaldoPrj := TMP->AF8_XVALOR - nConsumo
	
	@ aPosObj[1,1]+05,aPosObj[1,2]+005 SAY OemToAnsi("Limite Atual")								SIZE 155,19 OF oFolder030:aDialogs[1] PIXEL	COLOR CLR_BLUE	 //"Saldo Atual"
	@ aPosObj[1,1]+20,aPosObj[1,2]+005 SAY OemToAnsi("Consumo Atual (NF + PC + SA - Dev)")			SIZE 155,19 OF oFolder030:aDialogs[1] PIXEL	COLOR CLR_BLUE	 //"Consumo atual - // Chamado n. 045962 - FWNM
	@ aPosObj[1,1]+35,aPosObj[1,2]+005 SAY OemToAnsi("Saldo")										SIZE 155,19 OF oFolder030:aDialogs[1] PIXEL	COLOR CLR_BLUE	 //"Maior Nota"
	
	@ aPosObj[1,1]+03,aPosObj[1,2]+165 MSGET TMP->AF8_XVALOR 		SIZE 60,9 OF oFolder030:aDialogs[1] PIXEL When .F. Picture Tm(AF8->AF8_XVALOR,15,2) HASBUTTON
	@ aPosObj[1,1]+18,aPosObj[1,2]+165 MSGET nConsumo        		SIZE 60,9 OF oFolder030:aDialogs[1] PIXEL When .F. Picture Tm(AF8->AF8_XVALOR,15,2) HASBUTTON
	@ aPosObj[1,1]+33,aPosObj[1,2]+165 MSGET nSaldoPrj             SIZE 60,9 OF oFolder030:aDialogs[1] PIXEL When .F. Picture Tm(AF8->AF8_XVALOR,15,2) HASBUTTON
		
	// AQUI!	

	// NOTA FISCAL
	dbSelectArea("cArq4")
	dbGoTop()
	If FWModeAccess("SF1",1) == "E"		/* GESTAO */
		@ aPosObj[2,1]-48,aPosObj[2,2]-2 LISTBOX oLbx3 FIELDS cArq4->FILORIG,cArq4->NUMERO,cArq4->EMISSAO,Transform(cArq4->VALORNOTA,PesqPict("SF1","F1_VALMERC")),cArq4->DUPLICATA,cArq4->PEDIDO,cArq4->ITEMPC;
		HEADER SX3->(RetTitle("E2_FILORIG")),STR0007,STR0010,STR0030,STR0031,"Pedido","Item PC" SIZE aPosObj[2,4]-9,aPosObj[2,3]-82 OF oFolder030:aDialogs[2] PIXEL
	Else
		@ aPosObj[2,1]-48,aPosObj[2,2]-2 LISTBOX oLbx3 FIELDS cArq4->NUMERO,cArq4->EMISSAO,Transform(cArq4->VALORNOTA,PesqPict("SF1","F1_VALMERC")),cArq4->DUPLICATA,cArq4->PEDIDO ;
		HEADER STR0007,STR0010,STR0030,STR0031,"Pedido","Item PC" SIZE aPosObj[2,4]-9,aPosObj[2,3]-82 OF oFolder030:aDialogs[2] PIXEL
	Endif
	@ aPosObj[2,3]-81,aPosObj[2,2]+150 Say OemToAnsi(STR0066+": ") + Str(nTitulos4,5) OF oFolder030:aDialogs[2] PIXEL //"Notas"
	@ aPosObj[2,3]-81,aPosObj[2,2]+300 Say OemToAnsi(STR0067+": ") + Transf(nVlrGerNF,Tm(nVlrGerNF,15,nCasas)) OF oFolder030:aDialogs[2] PIXEL //"Total Geral"
	DEFINE SBUTTON oBtnNF FROM aPosObj[2,3]-81,aPosObj[2,2]+001 TYPE 15 ACTION ( F030VISUAL("SF1",CARQ4->XX_RECNO,0) ) ENABLE OF oFolder030:aDialogs[2] Pixel
	oFolder030:aDialogs[2]:Refresh()
//	oFolder030:aDialogs[3]:Refresh()

	// PC + PRENOTA
	dbSelectArea("cArq3")
	dbGoTop()
	If lC7Fiscori .And. FWModeAccess("SC7",1) == "E"		/* GESTAO */
		@ aPosObj[2,1]-48,aPosObj[2,2]-2 LISTBOX oLbx2 FIELDS cArq3->FILORIG,cArq3->NUMERO,cArq3->EMISSAO,cArq3->ENTREGA,Transform(cArq3->VALORITEM,"@E 999,999,999,999,999,999.99") ;
		HEADER SX3->(RetTitle("C7_FISCORI")),STR0007,STR0010,STR0135,STR0029 SIZE aPosObj[2,4]-9,aPosObj[2,3]-82 OF oFolder030:aDialogs[3] PIXEL
	Else
		@ aPosObj[2,1]-48,aPosObj[2,2]-2 LISTBOX oLbx2 FIELDS cArq3->NUMERO,cArq3->EMISSAO,cArq3->ENTREGA,Transform(cArq3->VALORITEM,"@E 999,999,999,999,999,999.99") ;
		HEADER STR0007,STR0010,STR0135,STR0029 SIZE aPosObj[2,4]-9,aPosObj[2,3]-82 OF oFolder030:aDialogs[3] PIXEL
	Endif
	@ aPosObj[2,3]-81,aPosObj[2,2]+150 Say OemToAnsi("PCs: ") + Str(nTitulos3,5) OF oFolder030:aDialogs[3] PIXEL  //"Notas"
	@ aPosObj[2,3]-81,aPosObj[2,2]+300 Say OemToAnsi("Total PC"+": ") + Transf(nTotal3,Tm(nTotal3,15,nCasas)) OF oFolder030:aDialogs[3] PIXEL //"Total Geral"
	If lC7Fiscori
		DEFINE SBUTTON oBtnNF FROM aPosObj[2,3]-81,aPosObj[2,2]+001 TYPE 15 ACTION ( F030PCVis(cArq3->FILORIG,cArq3->NUMERO) ) ENABLE OF oFolder030:aDialogs[3] Pixel
	Else
		DEFINE SBUTTON oBtnNF FROM aPosObj[2,3]-81,aPosObj[2,2]+001 TYPE 15 ACTION ( F030PCVis(,cArq3->NUMERO) ) ENABLE OF oFolder030:aDialogs[3] Pixel
	Endif
	oFolder030:aDialogs[3]:Refresh()
	//oFolder030:aDialogs[2]:Refresh()
	
	// SA
	dbSelectArea("cArq9")
	dbGoTop()
	@ aPosObj[2,1]-48,aPosObj[2,2]-2 LISTBOX oLbx7 FIELDS cArq9->SA,cArq9->EMISSAO,Transform(cArq9->VALOR,PesqPict("SCP","CP_XPRJVLR")) ;
	HEADER STR0007,STR0010,"Valor SA" SIZE aPosObj[2,4]-9,aPosObj[2,3]-82 OF oFolder030:aDialogs[4] PIXEL
	@ aPosObj[2,3]-81,aPosObj[2,2]+150 Say OemToAnsi("SA"+": ") + Str(nTitulos9,5) OF oFolder030:aDialogs[4] PIXEL //"Notas"
	@ aPosObj[2,3]-81,aPosObj[2,2]+300 Say OemToAnsi(STR0067+": ") + Transf(nTotal9,Tm(nTotal9,15,nCasas)) OF oFolder030:aDialogs[4] PIXEL //"Total Geral"
	DEFINE SBUTTON oBtnNF FROM aPosObj[2,3]-81,aPosObj[2,2]+001 TYPE 15 ENABLE OF oFolder030:aDialogs[4] Pixel
	oFolder030:aDialogs[4]:Refresh()
//	oFolder030:aDialogs[7]:Refresh()

	// DEVOLUCAO
	dbSelectArea("cArq7")
	dbGoTop()
	If FWModeAccess("SF2",1) == "E"		/* GESTAO */
		@ aPosObj[2,1]-48,aPosObj[2,2]-2 LISTBOX oLbx5 FIELDS cArq7->FILORIG,cArq7->NUMERO,cArq7->EMISSAO,Transform(cArq7->VALORNOTA,PesqPict("SF2","F2_VALMERC")) ;
		HEADER SX3->(RetTitle("E2_FILORIG")),STR0007,STR0010,STR0030 SIZE aPosObj[2,4]-9,aPosObj[2,3]-82 OF oFolder030:aDialogs[5] PIXEL
	Else
		@ aPosObj[2,1]-48,aPosObj[2,2]-2 LISTBOX oLbx5 FIELDS cArq7->NUMERO,cArq7->EMISSAO,Transform(cArq7->VALORNOTA,PesqPict("SF2","F2_VALMERC")) ;
		HEADER STR0007,STR0010,STR0030 SIZE aPosObj[2,4]-9,aPosObj[2,3]-82 OF oFolder030:aDialogs[5] PIXEL
	Endif
	@ aPosObj[2,3]-81,aPosObj[2,2]+150 Say OemToAnsi(STR0066+": ") + Str(nTitulos7,5) OF oFolder030:aDialogs[5] PIXEL //"Notas"
	@ aPosObj[2,3]-81,aPosObj[2,2]+300 Say OemToAnsi(STR0067+": ") + Transf(nVlrGerNF5,Tm(nVlrGerNF5,15,nCasas)) OF oFolder030:aDialogs[5] PIXEL //"Total Geral"
	DEFINE SBUTTON oBtnNF FROM aPosObj[2,3]-81,aPosObj[2,2]+001 TYPE 15 ACTION ( F030VISUAL("SF2",CARQ7->XX_RECNO,0) ) ENABLE OF oFolder030:aDialogs[5] Pixel
	oFolder030:aDialogs[5]:Refresh()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Informacoes do Folder - Produtos                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("cArq5")
	dbGoTop()
	If lC7Fiscori .And. FWModeAccess("SC7",1) == "E"		/* GESTAO */
		@ aPosObj[2,1]-48,aPosObj[2,2]-2 LISTBOX oLbx4 FIELDS cArq5->FILORIG,cArq5->NUMERO,cArq5->EMISSAO,cArq5->PRODUTO,cArq5->DESCRI,cArq5->UM,cArq5->SEGUM,Transform(cArq5->QUANT,PesqPictQt("C7_QUANT",15)),Transform(cArq5->QTSEGUM,PesqPictQt("C7_QUANT",15)),Transform(cArq5->PRECO,PesqPict("SC7","C7_TOTAL")),cArq5->CONDPAG ;
		HEADER  SX3->(RetTitle("C7_FISCORI")),STR0007,STR0010,STR0032,STR0132,STR0033,STR0034,STR0035,STR0036,STR0037,STR0038 SIZE aPosObj[2,4]-9,aPosObj[2,3]-82 OF oFolder030:aDialogs[6] PIXEL
		oFolder030:aDialogs[6]:Refresh()
	Else
		@ aPosObj[2,1]-48,aPosObj[2,2]-2 LISTBOX oLbx4 FIELDS cArq5->NUMERO,cArq5->EMISSAO,cArq5->PRODUTO,cArq5->DESCRI,cArq5->UM,cArq5->SEGUM,Transform(cArq5->QUANT,PesqPictQt("C7_QUANT",15)),Transform(cArq5->QTSEGUM,PesqPictQt("C7_QUANT",15)),Transform(cArq5->PRECO,PesqPict("SC7","C7_TOTAL")),cArq5->CONDPAG ;
		HEADER STR0007,STR0010,STR0032,STR0132,STR0033,STR0034,STR0035,STR0036,STR0037,STR0038 SIZE aPosObj[2,4]-9,aPosObj[2,3]-82 OF oFolder030:aDialogs[6] PIXEL
		oFolder030:aDialogs[6]:Refresh()
	Endif
		
	dbSelectArea("cArq8")
	dbGoTop()
	If FWModeAccess("SF1",1) == "E"		/* GESTAO */
		@ aPosObj[2,1]-48,aPosObj[2,2]-2 LISTBOX oLbx6 ;
		FIELDS If(cArq8->Leg=='3',oYel,If(cArq8->Leg=='1',oRed,oGre)),cArq8->FILORIG,;
		cArq8->NOTA,cArq8->EMISNF,cArq8->PEDIDO,cArq8->EMISPD,cArq8->PRODUTO,cArq8->DESCR,cArq8->DT_PREV,cArq8->DT_REAL,cArq8->DIF_DIAS,"" ;
		HEADER "",SX3->(RetTitle("E2_FILORIG")),STR0066,STR0010,"Pedido",STR0010,STR0032,STR0132,"Dt Prevista","Dt Realizada","Diferença Dias","" ;
		SIZE aPosObj[2,4]-9,aPosObj[2,3]-82 OF oFolder030:aDialogs[7] PIXEL
	Else
		@ aPosObj[2,1]-48,aPosObj[2,2]-2 LISTBOX oLbx6 ;
		FIELDS If(cArq8->Leg=='3',oYel,If(cArq8->Leg=='1',oRed,oGre)),;
		cArq8->NOTA,cArq8->EMISNF,cArq8->PEDIDO,cArq8->EMISPD,cArq8->PRODUTO,cArq8->DESCR,cArq8->DT_PREV,cArq8->DT_REAL,cArq8->DIF_DIAS,"" ;
		HEADER "",STR0140,STR0010,STR0141,STR0010,STR0032,STR0132,STR0142,STR0143,STR0144,"" ; //Nota,"Emissao","Pedido","Emissao","Produto","Descrição","Dt Prevista","Dt Realizada","Diferença Dias"
		SIZE aPosObj[2,4]-9,aPosObj[2,3]-82 OF oFolder030:aDialogs[7] PIXEL
	Endif
	@ aPosObj[2,3]-81,aPosObj[2,2]+150 Say OemToAnsi(STR0145+": ") + Str(nTitulos8,5) OF oFolder030:aDialogs[7] PIXEL  // "Itens"
	@ aPosObj[2,3]-81,aPosObj[2,2]+300 Say OemToAnsi(STR0146+": ") + Str(nTot1,10) OF oFolder030:aDialogs[7] PIXEL // "Entrega no Prazo"
	@ aPosObj[2,3]-81,aPosObj[2,2]+500 Say OemToAnsi(STR0147+": ") + Str(nTot2,10) OF oFolder030:aDialogs[7] PIXEL //"Entrega Atrasada"
	@ aPosObj[2,3]-81,aPosObj[2,2]+600 BUTTON STR0148 SIZE 030,09 ACTION LjLeg() OF oFolder030:aDialogs[7] PIXEL //"Legenda"
	oFolder030:aDialogs[7]:Refresh()
				
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Informacoes do PE FC030CON - Usa Botao ao lado do "Sair"     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( lFC030Con )
		@ 028,160 BUTTON OemToAnsi(STR0072) SIZE 42,13 FONT oDlg:oFont ACTION ExecBlock("",.F.,.F.) OF oDlg  PIXEL //"Cons. Especif."
	EndIf
		
	If lPanelFin  //Chamado pelo Painel Financeiro
		aButtonTxt := {}
		AADD(aButtonTxt,{STR0049,STR0049,{||FC030GRF(@lProc030a,@lProc030b)}}) // Financeiro
		ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg,,{||oDlg:End()},,aButtonTxt)
	Else
		ACTIVATE MSDIALOG oDlg
	Endif

Return

/*{Protheus.doc} Static Function FC030GERA
	Gera registros dos arquivos de trabalho
	@type  Function
	@author Fernando Macieira
	@since 18/07/2018
	@version 01
	@history 
*/

Static Function Fc030Gera(nProcess)

	Local nRec, nSalvRec, nTotAbat, nAtraso, nPago, dData, aSE5, nSE5
	Local dVencto, nAtrBai, cMotBx, cBanco, cAgencia, cConta, cHistor,cDescr
	Local nPos		:= 0
	Local aMotBx	:= ReadMotBx()
	Local aStru		:=	{}
	Local cQuery	:= ""
	Local cOrder	:= ""
	Local cFiltro	:= ""
	Local nLaco		:= 0
	Local nCotac	:= 0
	Local nTxMOeda	:= 0
	Local cCheque
	Local nI
	Local cOrdPg :=""
	Local lFC030Ord  := ExistBlock("FC030ORD")
	Local cCpoDisp   := ""
	Local cOrdCustom := ""
	Local lF030Filt  := ExistBlock("F030FILT")
	Local lC7Fiscori	:=	SC7->(FieldPos("C7_FISCORI")) > 0
	
	// GESTAO - inicio */
	Local nPosAlias	:= 0
	Local cFilAtual	:= cFilAnt
	Local cLayoutSM0 := FWSM0Layout()
	Local lGestao	 := Substr(cLayoutSM0,1,1) $ "E|U"
	
	// TOTALMENTE COMPARTILHADO
	Local lSE2Comp	:= .F.
	Local lSE5Comp	:= .F.
	Local lSC7Comp	:= .F.
	Local lSF1Comp	:= .F.
	Local lSD1Comp	:= .F.
	Local nSaldoPG	:= 0
	
	If cPaisLoc!="BRA"
		aTotal6:= {0.00,0,0.00,0}
	Endif
	
	If lGestao
		If Substr(cLayoutSM0,1,1) == "E"
			lSE2Comp := FWModeAccess("SE2",1) == "C"
			lSE5Comp := FWModeAccess("SE5",1) == "C"
			lSC7Comp := FWModeAccess("SC7",1) == "C"
			lSF1Comp := FWModeAccess("SF1",1) == "C"
			lSF2Comp := FWModeAccess("SF2",1) == "C"
		Else
			lSE2Comp := FWModeAccess("SE2",2) == "C"
			lSE5Comp := FWModeAccess("SE5",2) == "C"
			lSC7Comp := FWModeAccess("SC7",2) == "C"
			lSF1Comp := FWModeAccess("SF1",2) == "C"
			lSF2Comp := FWModeAccess("SF2",2) == "C"
		EndIf
	Else
		lSE2Comp := FWModeAccess("SE2",3) == "C"
		lSE5Comp := FWModeAccess("SE5",3) == "C"
		lSC7Comp := FWModeAccess("SC7",3) == "C"
		lSF1Comp := FWModeAccess("SF1",3) == "C"
		lSF2Comp := FWModeAccess("SF2",3) == "C"
	EndIF
	
	/* GESTAO - fim
	*/
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ABA PC + PRENOTA - CARQ3
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nProcess == 3
		IncProc(STR0112) //"Selecionando Dados - Pedidos Colocados / Produtos"
		#IFDEF TOP
			If TcSrvType() != "AS/400"
				aStru := {}
				dbSelectArea("SX3")
				dbSetOrder(2)
				dbSeek("C7_FILIAL")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				
				If lC7Fiscori
					dbSeek("C7_FISCORI")		/* GESTAO */
					aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				Endif
				
				dbSeek("C7_FORNECE")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("C7_LOJA")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("C7_NUM")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("C7_TOTAL")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("C7_PRODUTO")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("C7_DESCRI")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("C7_QUJE")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("C7_EMISSAO")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("C7_DATPRF")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("C7_UM")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("C7_SEGUM")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("C7_QUANT")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("C7_QTSEGUM")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("C7_PRECO")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("C7_COND")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("C7_VLDESC")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("C7_RESIDUO")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

				// Chamado n. 047791 - FWNM - 12/03/2019
				//SC7->C7_TOTAL+SC7->C7_VALFRE+SC7->C7_DESPESA+SC7->C7_SEGURO+SC7->C7_VALIPI+SC7->C7_ICMSRET-SC7->C7_VLDESC
				dbSeek("C7_VALFRE")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("C7_DESPESA")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("C7_SEGURO")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("C7_VALIPI")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("C7_ICMSRET")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				
				dbSelectArea("SC7")
				dbSetOrder(3)
				cQuery := ""
				aEval(aStru,{|x| cQuery += "," + AllTrim(x[1])})
				cCpoDisp := SubStr(cQuery,2)

				// PC
				// Chamado n. 054064 || OS 055455 || CONTROLADORIA || DAIANE || (16) || SALDO DE PROJETO - fwnm - 11/12/2019
				/*
				cQuery := " SELECT C7_FILIAL, C7_NUM, C7_ITEM, C7_PRODUTO, C7_DESCRI, C7_TOTAL, C7_VALFRE, C7_DESPESA, C7_SEGURO, C7_VALIPI, C7_ICMSRET, C7_FISCORI,C7_FORNECE,C7_LOJA,C7_NUM,C7_PRODUTO,C7_DESCRI,C7_QUJE,C7_EMISSAO,C7_DATPRF,C7_UM,C7_SEGUM,C7_QUANT,C7_QTSEGUM,C7_PRECO,C7_COND,C7_VLDESC,C7_RESIDUO, C7_XTXMOED, C7_MOEDA "
				cQuery += " FROM " + RetSqlName("SC7") + " SC7 (NOLOCK) "
				cQuery += " WHERE C7_FILIAL BETWEEN ' ' AND 'z'
				cQuery += " AND C7_PROJETO = '"+TMP->AF8_PROJET+"' "
				cQuery += " AND C7_RESIDUO <> 'S' "
				cQuery += " AND C7_CONAPRO <> 'R' " // Não trazer os pedidos rejeitados 27/12/2018 William Costa chamado 046075 - Inserido por FWNM em 22/01/2019 
				cQuery += " AND D_E_L_E_T_ = '' "

				// FWNM - 25/02/2019
				cQuery += " AND NOT EXISTS "
				cQuery += " ( "
				cQuery += " SELECT 'X' "
				cQuery += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) "
				cQuery += " WHERE D1_FILIAL=C7_FILIAL "
				cQuery += " AND D1_PEDIDO=C7_NUM "
				cQuery += " AND D1_ITEMPC=C7_ITEM "
				cQuery += " AND D_E_L_E_T_='' "
				cQuery += " ) "
	                           
				cQuery += " UNION "
				
				// PC com PRE-NOTA
				cQuery += " SELECT C7_FILIAL, C7_NUM, C7_ITEM, C7_PRODUTO, C7_DESCRI, C7_TOTAL, C7_VALFRE, C7_DESPESA, C7_SEGURO, C7_VALIPI, C7_ICMSRET, C7_FISCORI,C7_FORNECE,C7_LOJA,C7_NUM,C7_PRODUTO,C7_DESCRI,C7_QUJE,C7_EMISSAO,C7_DATPRF,C7_UM,C7_SEGUM,C7_QUANT,C7_QTSEGUM,C7_PRECO,C7_COND,C7_VLDESC,C7_RESIDUO, C7_XTXMOED, C7_MOEDA "

				cQuery += " FROM " + RetSqlName("SC7") + " SC7 (NOLOCK) "
				cQuery += " WHERE C7_FILIAL BETWEEN ' ' AND 'z'
				cQuery += " AND C7_PROJETO = '"+TMP->AF8_PROJET+"' "
				cQuery += " AND C7_RESIDUO <> 'S' "
				cQuery += " AND C7_CONAPRO <> 'R' " // Não trazer os pedidos rejeitados 27/12/2018 William Costa chamado 046075 - Inserido por FWNM em 22/01/2019 
				cQuery += " AND D_E_L_E_T_ = '' "

				// FWNM - 25/02/2019
				cQuery += " AND EXISTS "
				cQuery += " ( "
				cQuery += " SELECT 'X' "
				cQuery += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) "
				cQuery += " WHERE D1_FILIAL=C7_FILIAL "
				cQuery += " AND D1_PEDIDO=C7_NUM "
				cQuery += " AND D1_ITEMPC=C7_ITEM "
				cQuery += " AND D1_TES='' "
				cQuery += " AND D_E_L_E_T_='' "
				cQuery += " ) "
				//

				///////////////////////////
				cQuery += " UNION "
				*/

				// pedido com saldo parcial do item. Exemplo: C7_QUJE < C7_QUANT e C7_QUJE > 0 e C7_ENCER<>E (FWNM - 30/07/2019 - Chamado 050791)
				cQuery := " SELECT C7_FILIAL, C7_NUM, C7_ITEM, C7_PRODUTO, C7_DESCRI, ROUND(((C7_QUANT-C7_QUJE)*C7_PRECO),2) C7_TOTAL, ROUND(((C7_VALFRE/C7_QUANT)*(C7_QUANT-C7_QUJE)),2) C7_VALFRE, ROUND(((C7_DESPESA/C7_QUANT)*(C7_QUANT-C7_QUJE)),2) C7_DESPESA, ROUND(((C7_SEGURO/C7_QUANT)*(C7_QUANT-C7_QUJE)),2) C7_SEGURO, ROUND(((C7_VALIPI/C7_QUANT)*(C7_QUANT-C7_QUJE)),2) C7_VALIPI, ROUND(((C7_ICMSRET/C7_QUANT)*(C7_QUANT-C7_QUJE)),2) C7_ICMSRET, C7_FISCORI,C7_FORNECE,C7_LOJA,C7_NUM,C7_PRODUTO,C7_DESCRI,C7_QUJE,C7_EMISSAO,C7_DATPRF,C7_UM,C7_SEGUM,C7_QUANT,C7_QTSEGUM,C7_PRECO,C7_COND,C7_VLDESC,C7_RESIDUO, C7_XTXMOED, C7_MOEDA "

				cQuery += " FROM " + RetSqlName("SC7") + " SC7 (NOLOCK) "
				cQuery += " WHERE C7_FILIAL BETWEEN ' ' AND 'z'
				cQuery += " AND C7_PROJETO = '"+TMP->AF8_PROJET+"' "
				cQuery += " AND C7_RESIDUO <> 'S' "
				cQuery += " AND C7_CONAPRO <> 'R' "
				//cQuery += " AND C7_ENCER<>'E' "
				//cQuery += " AND C7_QUJE>0 "
				//cQuery += " AND C7_QUANT<>C7_QUJE " 
				cQuery += " AND D_E_L_E_T_ = '' "
				/*
				cQuery += " AND EXISTS "
				cQuery += " ( "
				cQuery += " SELECT 'X' "
				cQuery += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) "
				cQuery += " WHERE D1_FILIAL=C7_FILIAL "
				cQuery += " AND D1_PEDIDO=C7_NUM "
				cQuery += " AND D1_ITEMPC=C7_ITEM "
				cQuery += " AND D_E_L_E_T_='' "
				cQuery += " ) "
				*/
				/////////////////////////

				cQuery += " ORDER BY 1,2,3,4 "
				
				dbSelectArea("SC7")
				dbCloseArea()
				dbSelectArea("SA2")
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SC7', .T., .T.)
				For ni := 1 to Len(aStru)
					If aStru[ni,2] != 'C'
						TCSetField('SC7', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
					Endif
				Next
			EndIf
		#ENDIF
		
		dbSelectArea("SC7")
		If TcSrvType() == "AS/400"
			SC7->(dbSetOrder(3))
			dbSeek(cFilial+SA2->A2_COD+SA2->A2_LOJA)
		Else
			dbGotop()
		EndIf
		nTotal3 := 0
		
		While !Eof()
						
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava registros no arquivo temporario - Pedidos              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("cArq3")

			If MSSeek(SC7->C7_NUM)

				nVlrItem := 0
				If SC7->C7_MOEDA >= 2
					nVlrItem := (SC7->C7_TOTAL+SC7->C7_VALFRE+SC7->C7_DESPESA+SC7->C7_SEGURO+SC7->C7_VALIPI+SC7->C7_ICMSRET-SC7->C7_VLDESC) * SC7->C7_XTXMOED
				Else
					nVlrItem := SC7->C7_TOTAL+SC7->C7_VALFRE+SC7->C7_DESPESA+SC7->C7_SEGURO+SC7->C7_VALIPI+SC7->C7_ICMSRET-SC7->C7_VLDESC 
				EndIf
				
				If nVlrItem > 0
					RecLock("cArq3",.F.)

						If SC7->C7_MOEDA >= 2
							VALORITEM += (SC7->C7_TOTAL+SC7->C7_VALFRE+SC7->C7_DESPESA+SC7->C7_SEGURO+SC7->C7_VALIPI+SC7->C7_ICMSRET-SC7->C7_VLDESC) * SC7->C7_XTXMOED
						Else
							VALORITEM += SC7->C7_TOTAL+SC7->C7_VALFRE+SC7->C7_DESPESA+SC7->C7_SEGURO+SC7->C7_VALIPI+SC7->C7_ICMSRET-SC7->C7_VLDESC 
						EndIf
					
					msUnLock()

				EndIf

			Else

				nVlrItem := 0
				If SC7->C7_MOEDA >= 2
					nVlrItem := (VALORITEM+SC7->C7_TOTAL+SC7->C7_VALFRE+SC7->C7_DESPESA+SC7->C7_SEGURO+SC7->C7_VALIPI+SC7->C7_ICMSRET-SC7->C7_VLDESC) * SC7->C7_XTXMOED
				Else
					nVlrItem := VALORITEM+SC7->C7_TOTAL+SC7->C7_VALFRE+SC7->C7_DESPESA+SC7->C7_SEGURO+SC7->C7_VALIPI+SC7->C7_ICMSRET-SC7->C7_VLDESC
				EndIf

				If nVlrItem > 0
					
					RecLock("cArq3",.T.)
				
						If lC7Fiscori
							Replace FILORIG		With SC7->C7_FISCORI
						Endif
						
						Replace NUMERO		With SC7->C7_NUM
						Replace EMISSAO		With SC7->C7_EMISSAO
						Replace ENTREGA		With SC7->C7_DATPRF

						If SC7->C7_MOEDA >= 2
							Replace VALORITEM   With (VALORITEM+SC7->C7_TOTAL+SC7->C7_VALFRE+SC7->C7_DESPESA+SC7->C7_SEGURO+SC7->C7_VALIPI+SC7->C7_ICMSRET-SC7->C7_VLDESC) * SC7->C7_XTXMOED
						Else
							Replace VALORITEM   With VALORITEM+SC7->C7_TOTAL+SC7->C7_VALFRE+SC7->C7_DESPESA+SC7->C7_SEGURO+SC7->C7_VALIPI+SC7->C7_ICMSRET-SC7->C7_VLDESC
						EndIf

					msUnLock()
				
				EndIf

			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava registros no arquivo temporario - Produtos             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("cArq5")
			RecLock("cArq5",.T.)
			
			If lC7Fiscori
				Replace  FILORIG     With  SC7->C7_FISCORI
			Endif
			
			Replace  NUMERO      With  SC7->C7_NUM
			Replace  EMISSAO     With  SC7->C7_EMISSAO
			Replace  PRODUTO     With  SC7->C7_PRODUTO
			Replace  DESCRI      With  SC7->C7_DESCRI
			Replace  UM          With  SC7->C7_UM
			Replace  SEGUM       With  SC7->C7_SEGUM
			Replace  QUANT       With  SC7->C7_QUANT
			Replace  QTSEGUM     With  SC7->C7_QTSEGUM
			Replace  PRECO       With  SC7->C7_PRECO
			Replace  CONDPAG	 With  SC7->C7_COND
			
			MsUnlock()
			
			If SC7->C7_MOEDA >= 2
				nTotal3 += (SC7->C7_TOTAL+SC7->C7_VALFRE+SC7->C7_DESPESA+SC7->C7_SEGURO+SC7->C7_VALIPI+SC7->C7_ICMSRET-SC7->C7_VLDESC) * SC7->C7_XTXMOED
			Else
				nTotal3 += SC7->C7_TOTAL+SC7->C7_VALFRE+SC7->C7_DESPESA+SC7->C7_SEGURO+SC7->C7_VALIPI+SC7->C7_ICMSRET-SC7->C7_VLDESC
			EndIf

			dbSelectArea("SC7")
			dbSkip()
			
		EndDo
		
		dbSelectArea("SC7")
		dbCloseArea()
		ChKFile("SC7")
		
		dbSelectArea("cArq3")
		dbGoTop()
		nTitulos3 := RecCount()
		
		dbSelectArea("cArq5")
		dbGoTop()
		nTitulos5 := RecCount()
		
		dbSelectArea("SC7")
		dbSetOrder(1)
		
	Endif
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ABA NOTAS CLASSIFICADAS - CARQ4                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nProcess == 4
		IncProc("Carregando dados - Notas Entrada")
		cFiltro := SF1->( dbFilter() )
		aArea   := SF1->( GetArea() )
		#IFDEF TOP
			If TcSrvType() != "AS/400"
				
				aStru := {}
				dbSelectArea("SX3")
				dbSetOrder(2)
				dbSeek("F1_FILIAL")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_FORNECE")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_LOJA")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_EMISSAO")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_TIPO")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_VALMERC")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_FRETE")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_VALIPI")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_ICMSRET")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_DESPESA")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_DESCONT")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_DOC")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_DUPL")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				
				//Incluido por Adriana - 03/09/2019 - Chamado 051453			
				dbSeek("D1_CF") 
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("D1_VALICM")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("D1_VALIMP5")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("D1_VALIMP6")
				//Fim - Chamado 051453
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("D1_TOTAL")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("D1_VALIPI")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("D1_VALFRE")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("D1_DESPESA")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("D1_SEGURO")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("D1_ICMSRET")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("D1_VALDESC")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	
				If cPaisLoc <> "BRA"
					dbSeek("F1_MOEDA")
					aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
					dbSeek("F1_TXMOEDA")
					aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				EndIf
				dbSelectArea("SF1")
				dbSetOrder(2)
				
				cOrder := SqlOrder(IndexKey())
				cQuery := ""
				aEval(aStru,{|x| cQuery += ","+AllTrim(x[1])})
				cCpoDisp := SubStr(cQuery,2)
				If FieldPos("F1_CANCEL") > 0
					cQuery += ",F1_CANCEL"
				Endif
				
				cQuery := " SELECT "+SubStr(cQuery,2)+",SF1.R_E_C_N_O_ SF1RECNO, D1_PEDIDO, D1_ITEMPC "
				cQuery += " FROM " + RetSqlName("SF1") + " SF1 (NOLOCK), " + RetSqlName("SD1") + " SD1 (NOLOCK), " + RetSqlName("SF4") + " SF4 (NOLOCK) "
				cQuery += " WHERE F1_FILIAL=D1_FILIAL AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F1_TIPO=D1_TIPO AND F1_FORNECE=D1_FORNECE AND F1_LOJA=D1_LOJA "
				cQuery += " AND D1_TES=F4_CODIGO "
				cQuery += " AND SF1.D_E_L_E_T_ = '' "
				cQuery += " AND SD1.D1_FILIAL BETWEEN '' AND 'ZZ' "
				cQuery += " AND SD1.D1_TES <> '' "
				cQuery += " AND SD1.D1_PROJETO='"+TMP->AF8_PROJET+"' "
				cQuery += " AND SD1.D_E_L_E_T_ = '' "
				cQuery += " AND F4_FILIAL='"+xFilial("SF4")+"' "
				cQuery += " AND F4_DUPLIC = 'S' "
				cQuery += " AND SF4.D_E_L_E_T_ = '' "
				cQuery += " ORDER BY F1_DTDIGIT, F1_FORNECE, F1_LOJA, F1_FILIAL, F1_DOC, F1_SERIE, F1_TIPO "
			
				cQuery := ChangeQuery(cQuery)
		
				dbSelectArea("SF1")
				dbCloseArea()
				dbSelectArea("SA2")
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SF1', .T., .T.)
				For ni := 1 to Len(aStru)
					If aStru[ni,2] != 'C'
						TCSetField('SF1', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
					Endif
				Next
			EndIf
		#ENDIF
		
		dbSelectArea("SF1")
		dbGoTop()
		
		nVlrGerNF := 0
		Do While !Eof()
	
			//Incluido tratamento para nota de importacao - por Adriana - 03/09/2019 - Chamado 051453
			If Left(D1_CF,1) <> "3"
				// FWNM - 25/02/2019
				//nTotNota:=F1_VALMERC+F1_FRETE+F1_VALIPI+F1_ICMSRET+F1_DESPESA-F1_DESCONT
				nTotNota:=D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA+D1_SEGURO+D1_ICMSRET-D1_VALDESC
			Else  
				nTotNota:=D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA+D1_SEGURO+D1_ICMSRET+D1_VALICM+D1_VALIMP5+D1_VALIMP6-D1_VALDESC
			EndIf
			//Fim - Chamado 051453
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava registros no arquivo temporario                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("cArq4")
			RecLock("cArq4",.T.)
			Replace  FILORIG	With SF1->F1_FILIAL
			Replace  NUMERO		With SF1->F1_DOC
			Replace  EMISSAO	With SF1->F1_EMISSAO
			Replace  VALORNOTA	With nTotNota
			Replace  DUPLICATA	With SF1->F1_DUPL
			Replace  PEDIDO	    With SF1->D1_PEDIDO
			Replace  ITEMPC	    With SF1->D1_ITEMPC
			If TcSrvType() != "AS/400"
				Replace  XX_RECNO    With  SF1->SF1RECNO
			Else
				Replace  XX_RECNO    With  SF1->(RECNO())
			Endif
			
			If cPaisLoc <> "BRA"
				Replace MOEDA With SF1->F1_MOEDA
				Replace TAXA  With SF1->F1_TXMOEDA
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada para incluir campos no arquivo temporario de titulos pagos.                              ³
			//³ Rdmake deve ter 3 etapas, estas, quando Ponto de Entrada passar como referencia o primeiro valor igual a: ³
			//³ (1) - Etapa de Adicionar os campos novos no array de criação do arquivo de dados temporário               ³
			//³ (2) - Etapa de Abastecimento dos campos                                                                   ³
			//³ (3) - Etapa de Tratamento do objeto LISTBOX com os campos que deseja visualizar na aba de Tit Pagos       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			MsUnlock()
			
			If cPaisLoc == "BRA"
				nVlrGerNF += nTotNota
			Else
				nVlrGerNF += Iif(SF1->F1_MOEDA==1,nTotNota,xMoeda(nTotNota,SF1->F1_MOEDA,1,SF1->F1_EMISSAO,MsDecimais(1),Iif(mv_par09==1,SF1->F1_TXMOEDA,0)))
			EndIf
			
			dbSelectArea("SF1")
			dbSkip()
			
		EndDo
		
		#IFDEF TOP
			If TcSrvType() != "AS/400"
				dbSelectArea("SF1")
				dbCloseArea()
				ChKFile("SF1")
			Endif
		#ENDIF
		
		dbSelectArea("cArq4")
		dbGoTop()
		
		nTitulos4 := RecCount()
		dbSelectArea("SF1")
		
		RestArea(aArea)
		Set Filter to &(cFiltro)
		
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ABA DEVOLUÇÃO - CARQ7
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nProcess == 5
		IncProc("Selecionando Dados - Devoluções")
		cFiltro := SF2->( dbFilter() )
		aArea   := SF2->( GetArea() )
		#IFDEF TOP
			If TcSrvType() != "AS/400"
				
				aStru := {}
				dbSelectArea("SX3")
				dbSetOrder(2)
				dbSeek("F2_FILIAL")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F2_CLIENTE")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F2_LOJA")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F2_EMISSAO")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F2_TIPO")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F2_VALMERC")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F2_FRETE")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F2_VALIPI")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F2_DESPESA")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F2_DESCONT")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F2_DOC")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F2_DUPL")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

				dbSeek("D2_TOTAL")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("D2_DESCON")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				
				dbSelectArea("SF2")
				dbSetOrder(2)
				
				cOrder := SqlOrder(IndexKey())
				cQuery := ""
				aEval(aStru,{|x| cQuery += ","+AllTrim(x[1])})
				cCpoDisp := SubStr(cQuery,2)
				cQuery := "SELECT DISTINCT "+SubStr(cQuery,2)+",SF2.R_E_C_N_O_ SF2RECNO FROM " + RetSqlName("SF2") + " SF2, " + RetSqlName("SD2") + " SD2 "
				cquery += " WHERE F2_FILIAL=D2_FILIAL AND F2_DOC=D2_DOC AND F2_SERIE=D2_SERIE AND F2_TIPO=D2_TIPO "
				cQuery += " AND F2_FILIAL BETWEEN ' ' AND 'z' "
				cQuery += " AND F2_TIPO IN ('D') "
				cQuery += " AND SF2.D_E_L_E_T_ = '' "
				cQuery += " AND D2_XPROJET='"+TMP->AF8_PROJET+"' "
				cQuery += " AND SD2.D_E_L_E_T_ = '' "
				//cQuery += " ORDER BY " + cOrder
				cQuery := ChangeQuery(cQuery)
								
			
				dbSelectArea("SF2")
				dbCloseArea()
				dbSelectArea("SA2")
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SF2', .T., .T.)
				For ni := 1 to Len(aStru)
					If aStru[ni,2] != 'C'
						TCSetField('SF2', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
					Endif
				Next
			EndIf
		#ENDIF
		
		dbSelectArea("SF2")
		dbGoTop()
		
		nVlrGerNF5 := 0
		While !Eof()
			//nTotNota:=F2_VALMERC+F2_FRETE+F2_VALIPI+F2_DESPESA-F2_DESCONT
			nTotNota:=D2_TOTAL-D2_DESCON
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava registros no arquivo temporario                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("cArq7")
			RecLock("cArq7",.T.)
			Replace FILORIG		With SF2->F2_FILIAL
			Replace NUMERO		With SF2->F2_DOC
			Replace EMISSAO		With SF2->F2_EMISSAO
			Replace VALORNOTA	With nTotNota
			If TcSrvType() != "AS/400"
				Replace  XX_RECNO    With  SF2->SF2RECNO
			Else
				Replace  XX_RECNO    With  SF2->(RECNO())
			Endif
			
			MsUnlock()
			
			nVlrGerNF5 += nTotNota
			
			dbSelectArea("SF2")
			dbSkip()
			
		EndDO
		
		#IFDEF TOP
			If TcSrvType() != "AS/400"
				dbSelectArea("SF2")
				dbCloseArea()
				ChKFile("SF2")
			Endif
		#ENDIF
		dbSelectArea("cArq7")
		dbGoTop()
		nTitulos7 := RecCount()
		dbSelectArea("SF2")
		RestArea(aArea)
		Set Filter to &(cFiltro)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ABA ENTREGA - CARQ8                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nProcess == 6
		IncProc("Selecionando Dados - Entrega")
		cFiltro := SF1->( dbFilter() )
		aArea   := SF1->( GetArea() )
		#IFDEF TOP
			If TcSrvType() != "AS/400"
				
				aStru := {}
				dbSelectArea("SX3")
				dbSetOrder(2)
				dbSeek("F1_FILIAL")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_FORNECE")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_LOJA")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_EMISSAO")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_TIPO")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_VALMERC")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_FRETE")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_VALIPI")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_DESPESA")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_DESCONT")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_DOC")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("F1_DUPL")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("D1_PEDIDO")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("D1_ITEMPC")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("D1_COD")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("C7_DATPRF")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("C7_EMISSAO")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("D1_DTDIGIT")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				
				dbSelectArea("SF1")
				dbSetOrder(2)
				
				cOrder := SqlOrder(IndexKey())
				cQuery := ""
				aEval(aStru,{|x| cQuery += ","+AllTrim(x[1])})
				cCpoDisp := SubStr(cQuery,2)
				
				cQuery := "SELECT "+SubStr(cQuery,2)+",SF1.R_E_C_N_O_ SF1RECNO FROM " + RetSqlName("SF1") + " SF1 "
				cQuery += " INNER JOIN " + RetSqlName("SD1") + " SD1 ON "
				cQuery += " SD1.D1_FILIAL   = SF1.F1_FILIAL  AND "
				cQuery += " SD1.D1_FORNECE  = SF1.F1_FORNECE AND "
				cQuery += " SD1.D1_LOJA     = SF1.F1_LOJA    AND "
				cQuery += " SD1.D1_DOC      = SF1.F1_DOC     AND "
				cQuery += " SD1.D_E_L_E_T_ <> '*'
				cQuery += " INNER JOIN " +RetSqlName("SC7") + " SC7 ON "
				cQuery += " SC7.C7_FILIAL  = D1_FILIAL AND "
				cQuery += " SC7.C7_NUM     = D1_PEDIDO AND "
				cQuery += " SC7.C7_ITEM = SD1.D1_ITEMPC AND "
				cQuery += " SC7.C7_PROJETO='"+TMP->AF8_PROJET+"' AND "
				cQuery += " SC7.D_E_L_E_T_ = ' '"
				
				nPosAlias := FC030QFil(1,"SF1")
				cQuery += " WHERE F1_FILIAL BETWEEN ' ' AND 'z' "
				cQuery += " AND   SF1.F1_ESPECIE NOT IN('RCN')"
				cQuery += " AND   SF1.F1_TIPO NOT IN ('B','D') "
				cQuery += " AND   SF1.D_E_L_E_T_ = ' '"
				cQuery += " ORDER BY " + cOrder
				cQuery := ChangeQuery(cQuery)
				
				
				dbSelectArea("SF1")
				dbCloseArea()
				dbSelectArea("SA2")
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SF1', .T., .T.)
				For ni := 1 to Len(aStru)
					If aStru[ni,2] != 'C'
						TCSetField('SF1', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
					Endif
				Next
			EndIf
		#ENDIF
		
		dbSelectArea("SF1")
		
		If TcSrvType() == "AS/400"
			SF1->(dbSetOrder(2))
			dbSeek(cFilial+SA2->A2_COD+SA2->A2_LOJA)
		Else
			dbGoTop()
		EndIf
		
		nVlrGerNF6 := 0
		nTot1       := 0
		nTot2       := 0
		While !Eof()
			If !Empty(SF1->D1_PEDIDO)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava registros no arquivo temporario                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cDescr := Posicione("SB1",1,xFilial("SB1")+SF1->D1_COD,"SB1->B1_DESC")
				dbSelectArea("cArq8")
				RecLock("cArq8",.T.)
				REPLACE FILORIG		With  SF1->F1_FILIAL
				Replace NOTA        With  SF1->F1_DOC
				Replace EMISNF      With  SF1->F1_EMISSAO
				Replace PEDIDO      With  SF1->D1_PEDIDO
				Replace EMISPD      With  SF1->C7_EMISSAO
				Replace PRODUTO     With  SF1->D1_COD
				Replace Descr       With  cDescr
				Replace DT_PREV     With  SF1->C7_DATPRF
				Replace DT_REAL     With  SF1->D1_DTDIGIT
				If !Empty(SF1->C7_DATPRF)
					Replace DIF_DIAS With SF1->(C7_DATPRF - D1_DTDIGIT)
					If SF1->(C7_DATPRF - D1_DTDIGIT) >= 0
						Replace LEG   With  "2"
						nTot1++
					Else
						Replace LEG   With  "1"
						nTot2++
					Endif
				Else
					Replace DIF_DIAS With 0
					Replace LEG   With  "3"
					nTot1++
				Endif
				
				MsUnlock()
				
			Endif
			dbSelectArea("SF1")
			dbSkip()
		EndDO
		
		#IFDEF TOP
			If TcSrvType() != "AS/400"
				dbSelectArea("SF1")
				dbCloseArea()
				ChKFile("SF1")
			Endif
		#ENDIF
		dbSelectArea("cArq8")
		dbGoTop()
		nTitulos8 := RecCount()
		dbSelectArea("SF1")
		RestArea(aArea)
		Set Filter to &(cFiltro)
	Endif
		
	// Chamado n. 045962 - FWNM
	// Carrega dados da Solicitacao ao Armazem (SCP)
	If nProcess == 7 // ABA SA - CARQ9
		IncProc("Selecionando Dados - Solicitação ao Armazém")
		#IFDEF TOP
			If TcSrvType() != "AS/400"
				aStru := {}
				dbSelectArea("SX3")
				dbSetOrder(2)
				dbSeek("CP_FILIAL")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("CP_NUM")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("CP_ITEM")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("CP_PRODUTO")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("CP_DESCRI") 
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("CP_QUANT")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("CP_UM")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("CP_EMISSAO")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				dbSeek("CP_XPRJVLR")
				aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				
				dbSelectArea("SCP")
				dbSetOrder(1)
				cQuery := ""
				aEval(aStru,{|x| cQuery += "," + AllTrim(x[1])})
				cCpoDisp := SubStr(cQuery,2)
				cQuery := "SELECT "+SubStr(cQuery,2)+" FROM " + RetSqlName("SCP")
				cQuery += " WHERE CP_FILIAL BETWEEN ' ' AND 'z'
				cQuery += " AND CP_CONPRJ = '"+TMP->AF8_PROJET+"' "
				cQuery += " AND D_E_L_E_T_ = '' "
				
				cOrder := SqlOrder(IndexKey())
				cQuery += " ORDER BY " + cOrder
				
				cQuery := ChangeQuery(cQuery)
				
				dbSelectArea("SCP")
				dbCloseArea()
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SCP', .T., .T.)
				For ni := 1 to Len(aStru)
					If aStru[ni,2] != 'C'
						TCSetField('SCP', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
					Endif
				Next
			EndIf
		#ENDIF
		
		dbSelectArea("SCP")
		dbGotop()
		nTitulos9 := RecCount()
		nTotal9 := 0
		
		While !Eof()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava registros no arquivo temporario - Pedidos              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
			dbSelectArea("cArq9")
			If MSSeek(SCP->CP_NUM)
				RecLock("cArq9",.F.)
				VALOR += SCP->CP_XPRJVLR
			Else
				RecLock("cArq9",.T.)
				
				Replace SA      	With SCP->CP_NUM
				Replace EMISSAO		With SCP->CP_EMISSAO
				Replace PRODUTO     With SCP->CP_PRODUTO
				Replace DESCR       With SCP->CP_DESCRI
				Replace QUANTIDADE  With SCP->CP_QUANT
				Replace VALOR       With VALOR+SCP->CP_XPRJVLR
				Replace XX_RECNO    With SCP->(RECNO())
				
			Endif
			
			MsUnlock()
			
			nTotal9 += SCP->CP_XPRJVLR
			
			dbSelectArea("SCP")
			dbSkip()
			
		EndDo
		
		dbSelectArea("SCP")
		dbCloseArea()
		ChKFile("SCP")
		
		dbSelectArea("cArq3")
		dbGoTop()
		nTitulos3 := RecCount()
		
		dbSelectArea("cArq5")
		dbGoTop()
		nTitulos5 := RecCount()
		
		dbSelectArea("cArq9")
		dbGoTop()
		nTitulos9 := RecCount()
	
		dbSelectArea("SCP")
		dbSetOrder(1)
		
	Endif

Return (.T.)

/*{Protheus.doc} Static Function FC030PROCRI
	Cria estruturas dos arquivos de trabalho
	@type  Function
	@author Fernando Macieira
	@since 18/07/2018
	@version 01
	@history 
*/

Static Function Fc030Procri()

	// Seta tamanho da regua
	ProcRegua(4)
	
	IncProc(OemToAnsi(STR0102)) //"Criando Arquivo de Trabalho - Pedidos Colocados"
	cNomeArq := Fc030Cria(aCampos3,3)
	
	IncProc(OemToAnsi(STR0103)) //"Criando Arquivo de Trabalho - Faturamento"
	cNomeArq := Fc030Cria(aCampos4,4)
	
	IncProc(OemToAnsi(STR0104)) //"Criando Arquivo de Trabalho - Produtos"
	cNomeArq := Fc030Cria(aCampos5,5)
	
	If cPaisLoc != "BRA"
		IncProc(OemToAnsi(STR0105)) //"Criando Arquivo de Trabalho - Cartera de cheques"
		cNomeArq := Fc030Cria(aCampos6,6)
	Endif
	
	IncProc(OemToAnsi(STR0149))  //"Criando Arquivo de Trabalho - Devolução"
	cNomeArq := Fc030Cria(aCampos7,7)
	
	IncProc(OemToAnsi(STR0150)) //"Criando Arquivo de Trabalho - Entrega"
	cNomeArq := Fc030Cria(aCampos8,8)
	
	IncProc(OemToAnsi("Criando Arquivo de Trabalho - SA"))
	cNomeArq := Fc030Cria(aCampos9,9)

Return Nil

/*{Protheus.doc} Static Function FC030CHFOL
	Direcionamento da criacao dos arquivos
	@type  Function
	@author Fernando Macieira
	@since 18/07/2018
	@version 01
	@history 
*/

Static Function Fc030ChFol(nDest030,nAtual,lProc030a,lProc030b,lProc030c,lProc030d,lProc030e,lProc030f,lProc030g,oLbx,oLbx1,oLbx2,oLbx3,oLbx4,oLbx5,oLbx6,oLbx7) // Chamado n. 045962 - FWNM

	If nDest030 != nAtual
		// Carregar dados da Entrega
		If (nDest030 == 6)
			If !lProc030f
				lProc030f := .T.
				//Processa( { |lEnd| Fc030Gera(6) } ) // Chamado n. 049785 || OS 051084 || CONTROLADORIA || DAIANE || (16)2106-3549 || POSICAO PROJETOS - FWNM - 11/06/2019
				
			EndIf
	//		oLbx:Refresh()
			
			oLbx6:Gotop()
			oLbx6:Refresh()
			oLbx6:SetFocus()
		Endif
		
		// Carregar dados de Devolucao
		If (cPaisLoc == "BRA" .and. nDest030 == 5)
			If !lProc030e
				lProc030e := .T.
				//Processa( { |lEnd| Fc030Gera(5) } ) // Chamado n. 049785 || OS 051084 || CONTROLADORIA || DAIANE || (16)2106-3549 || POSICAO PROJETOS - FWNM - 11/06/2019
			EndIf
	//		oLbx:Refresh()
	//		oLbx:SetFocus()
			
			oLbx5:Gotop()
			oLbx5:Refresh()
			
		Endif
		
		// Carregar dados de Faturamento
		If (nDest030 == 2 .or. nDest030 == 4) .and. !lProc030c
			lProc030c := .T.
			//Processa( { |lEnd| Fc030Gera(3) } ) // Chamado n. 049785 || OS 051084 || CONTROLADORIA || DAIANE || (16)2106-3549 || POSICAO PROJETOS - FWNM - 11/06/2019
			oLbx2:Gotop()
			oLbx2:Refresh()
			oLbx4:Refresh()
			oLbx4:SetFocus()
		Endif
		
		// Carregar dados de Pedidos e Produtos
		If nDest030 == 3 .and. !lProc030d
			lProc030d := .T.
			//Processa( { |lEnd| Fc030Gera(4) } ) // Chamado n. 049785 || OS 051084 || CONTROLADORIA || DAIANE || (16)2106-3549 || POSICAO PROJETOS - FWNM - 11/06/2019
			oLbx3:Refresh()
			oLbx3:SetFocus()
		Endif
	
		// Carregar dados da Solicitacao ao Armazem (SCP) // Chamado n. 045962 - FWNM
		If nDest030 == 7 .and. !lProc030g
			lProc030g := .T.
			//Processa( { |lEnd| Fc030Gera(7) } ) // Chamado n. 049785 || OS 051084 || CONTROLADORIA || DAIANE || (16)2106-3549 || POSICAO PROJETOS - FWNM - 11/06/2019
			oLbx7:Refresh()
			oLbx7:SetFocus()
		Endif
	Endif

Return

/*{Protheus.doc} Static Function F030PCVIS
	Exibe a consulta do PC
	@type  Function
	@author Fernando Macieira
	@since 18/07/2018
	@version 01
	@history 
*/

Static Function F030PCVis(cFilOrig,cNumPC)

	Local aArea			:= GetArea()
	Local aAreaSC7		:= SC7->(GetArea())
	Local nSavNF		:= MaFisSave()
	Local cSavCadastro	:= cCadastro
	Local cFilBkp		:= ""		/* GESTAO */
	Local nregSM0		:= 0		/* GESTAO */
	
	PRIVATE nTipoPed	:= 1
	PRIVATE cCadastro	:= "Consulta ao Pedido de Compra"
	PRIVATE l120Auto	:= .F.
	PRIVATE aBackSC7	:= {}  //Sera utilizada na visualizacao do pedido - MATA120
	
	DEFAULT cFilOrig := xFilial("SC7")
	
	/*
	aRotina  := {{	OemToAnsi("Pesquisar") ,"AxPesqui"  , 0 , 1} ,;   //"Pesquisar"
	{	OemToAnsi("Consultar") ,"u_ADFc030Con"  , 0 , 2} }   //"Consultar"
	*/
	
	SaveInter() // Salva variaveis publicas
	
	If !empty(cNumPC)
		cFilBkp := cFilAnt
		MaFisEnd()
		nRegSM0 := SM0->(Recno())
		SM0->(DbSeek(cEmpAnt + AllTrim(cFilOrig)))
		cFilAnt := SM0->M0_CODFIL
		dbSelectArea("SC7")
		dbSetOrder(1)
		dbSeek(cFilOrig+cNumPC)
		A120Pedido(Alias(),RecNo(),2)
		SM0->(DbGoto(nRegSM0))
		cFilAnt := cFilBkp
	Else
		MsgAlert(OemToAnsi(STR0134)) //"Não há registos para consulta."
	EndIf
	
	RestInter() // Restaura variaveis publicas
	
	cCadastro	:= cSavCadastro
	MaFisRestore(nSavNF)
	RestArea(aAreaSC7)
	RestArea(aArea)

Return .T.

/*{Protheus.doc} Static Function F030VISUAL
	Exibe a consulta da NF Entrada
	@type  Function
	@author Fernando Macieira
	@since 18/07/2018
	@version 01
	@history 
*/


Static Function F030Visual(cAlias, nRecno, nOpc)

	Local cFilBkp	:= ""		/* GESTAO */
	Local nRegSM0	:= 0		/* GESTAO */
	
	cFilBkp := cFilAnt
	nRegSM0 := SM0->(Recno())
	SaveInter() // Salva variaveis publicas
	(cAlias)->(MsGoTo(nRecno))
	If cAlias = "SF1"
		SM0->(DbSeek(cEmpAnt + AllTrim((cAlias)->F1_FILIAL)))
		cFilAnt := SM0->M0_CODFIL
		dbSelectArea("SD1")
		dbSetOrder(1)
		lAchou := dbSeek(xFilial(cAlias)+(cAlias)->F1_DOC+(cAlias)->F1_SERIE+(cAlias)->F1_FORNECE+(cAlias)->F1_LOJA)
		dbSelectArea(cAlias)
		If lAchou
			If cPaisLoc == "BRA"
				MATA103(,,2)
			Else
				LOCXNF(Val(SF1->F1_TIPODOC), , , , , , 2)
			EndIf
		Else
			MsgAlert(OemToAnsi(STR0134)) //"Não há registos para consulta."
		EndIF
	Else
		SM0->(DbSeek(cEmpAnt + AllTrim((cAlias)->F2_FILIAL)))
		cFilAnt := SM0->M0_CODFIL
		dbSelectArea("SD2")
		dbSetOrder(3)
		dbSeek(xFilial(cAlias)+(cAlias)->F2_DOC+(cAlias)->F2_SERIE+(cAlias)->F2_CLIENTE+(cAlias)->F2_LOJA,.t.)
		lAchou := If(xFilial(cAlias)+(cAlias)->F2_DOC+(cAlias)->F2_SERIE+(cAlias)->F2_CLIENTE+(cAlias)->F2_LOJA = xFilial("SD2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA,.t.,.f.)
		dbSelectArea(cAlias)
		If lAchou
			Mc090Visual(cAlias,nRecno,2)
		Else
			MsgAlert(OemToAnsi(STR0134)) //"Não há registos para consulta."
		EndIF
	Endif
	SM0->(DbGoTo(nRegSM0))
	cFilAnt := cFilBkp
	RestInter() // Restaura variaveis publicas

Return Nil

/*{Protheus.doc} Static Function FINC030T
	Sem detalhamento
	@type  Function
	@author Fernando Macieira
	@since 18/07/2018
	@version 01
	@history 
*/

Static Function FinC030T(aParam)

	ReCreateBrow("SA2",FinWindow)
	cRotinaExec := "FINC030"
	FinC030(,aParam[1])
	ReCreateBrow("SA2",FinWindow)
	dbSelectArea("SA2")
	
	INCLUI := .F.
	ALTERA := .F.

Return .T.

/*{Protheus.doc} Static Function LJLEG
	Legenda
	@type  Function
	@author Fernando Macieira
	@since 18/07/2018
	@version 01
	@history 
*/

Static Function LjLeg()

	Local  aLegenda := {} //Legenda Entrega
	
	aAdd( aLegenda, { "BR_VERDE"	, STR0146  } ) 	//"Entrega no prazo"
	aAdd( aLegenda, { "BR_VERMELHO"	, STR0147  } )   	//"Entrega atrasada"
	aAdd( aLegenda, { "BR_AMARELO" 	, STR0151  } ) 	//"Nota sem pedido"
	
	BrwLegenda(STR0152,STR0148 ,aLegenda) //"Consulta Entrega" "Legenda"

Return .T.

/*{Protheus.doc} Static Function FC030QFIL
	Sem detalhamento
	@type  Function
	@author Fernando Macieira
	@since 18/07/2018
	@version 01
	@history 
*/

Static Function FC030QFil(nAcao,cAliasFil)

	Local nPosAlias		:= 0
	Local cTmpFil		:= ""
	
	Default cAliasFil	:= ""
	Default nAcao		:= 2
	aTmpFil := {}
	If nAcao == 1
		If !Empty(cAliasFil)
			nPosAlias := Ascan(aTmpFil,{|carq| carq[1] == cAliasFil})
			If nPosAlias == 0
				Aadd(aTmpFil,{"","",""})
				nPosAlias := Len(aTmpFil)
				aTmpFil[nPosAlias,1] := cAliasFil
				MsgRun("Favor Aguardar.....",STR0005 ,{|| aTmpFil[nPosAlias,2] := GetRngFil(aSelFil,cAliasFil,.T.,@cTmpFil)}) //"Favor Aguardar....."###"Consulta Posição fornecedores"
				aTmpFil[nPosAlias,3] := cTmpFil
			Endif
		Endif
	Else
		If nAcao == 2
			If !Empty(aTmpFil)
				MsgRun("Favor Aguardar.....",STR0005 ,{|| AEval(aTmpFil,{|tmpfil| CtbTmpErase(tmpFil[3])})}) //"Favor Aguardar....."###"Consulta Posição fornecedores"
				nPosAlias := Len(aTmpFil)
				aTmpFil := {}
				aSelFil := {}
			Endif
		Endif
	Endif
	
	If nAcao == 1
		If Empty(FWSM0LayOut(,1)) .And. Empty(FWSM0LayOut(,2)) .And. FWModeAccess("SE2", 3) == "C"
			aTmpFil[1,2] := " = '  ' "
		ElseIf ((Empty(aTmpFil[1,2]) .OR. aTmpFil[1,2] == " = '  ' ") .and. FWModeAccess(cAliasFil,1) == "E")
			aTmpFil[1,2] := (AllTrim("0" + AllTrim(STR((Len(aTmpFil))))))
			aTmpFil[1,2] := " = '" + aTmpFil[1,2] + "'"
		EndIf
	EndIf

Return(nPosAlias)

/*{Protheus.doc} User Function AF8PESQUI
	Pesquisa do projetos de investimento no browse 
	@type  Function
	@author Fernando Macieira
	@since 18/07/2018
	@version 01
	@history Chamado 045962 - FWNM - 26/12/2018 - Pesquisa projetos no browse 
*/

User Function AF8PESQUI()

	Local oDlg, oCbx, cOrd, oBigGet
	Local nSavReg, cAlias, ni, nj
	Local cCpofil, dCampo
	Local nOrd    := 1
	Local lSeek   := .F.
	Local aLista  := {}
	Local bSav12  := SetKey(VK_F12)
	Local cCampo  := Space(60)
	
	Local lDetail := .F.
	Local lUseDetail := .F.
	Local aAllLista
	Local oDetail
	Local aMyOrd	:= {}
	Local aScroll	:= {}
	Local lSeeAll   := GetBrwSeeMode()
	Local aPesqVar  := {}
	Local cVar
	Local bBloco
	Local cMsg := ""
	Local oPPreview
	Local oList
	Local aList    := {}
	Local lMenuDef := ( ProcName(1) == "MBRBLIND" ) .Or. RunInMenuDef()
	Local lPreview := .F.
	Local nRet     := 0
	
	Private aOrd     := {}

	U_ADINF009P('ADPMS005P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de consulta sintetica e analitica dos projetos de investimentos')
	
	/*/
	aLista
	[1] := F3
	[2] := tipo
	[3] := tamanho
	[4] := decimais
	[5] := titulo
	/*/
	
	SetKey(VK_F12,{|| NIL})
	
	cAlias := "AF8"
	DbSelectArea(cAlias)
	cCpofil := PrefixoCpo(cAlias)+"_FILIAL"
	nSavReg := Recno()
	
	If At(cCpoFil,Indexkey())==1 .And. !lSeeAll
		If &cCpofil!=cFilial
			DbSeek(cFilial)
		Endif
	Else
		DbGoTop()
	EndIf
	
	If Eof()
		If lMenuDef
			Help(" ",1,"ARQVAZIO")
		Else
			Help(" ",1,"A000FI")
		EndIf
		SetKey(VK_F12,bSav12)
		Return 3
	EndIf
	
	If nSavReg!=Recno()
		DbGoTo(nSavReg)
	Endif
	
	AxPesqOrd(cAlias,@aMyOrd,@lUseDetail,lSeeAll)
	
	nOrd := 1
	cOrd := aOrd[1]
	For nI := 1 To Len(aOrd)
		aOrd[nI] := OemToAnsi(aOrd[nI])
	Next
	
	If IndexOrd() > Len(aOrd)
		cOrd := 1 //aOrd[Len(aOrd)]
		nOrd := 1 //Len(aOrd)
	ElseIf IndexOrd() <= 1
		cOrd := aOrd[1]
		nOrd := 1
	Else
		cOrd := aOrd[IndexOrd()]
		nOrd := IndexOrd()
	EndIf
	
	If lUseDetail .and. !PesqList(cAlias,lSeeAll,@aPesqVar,@aAllLista,@cMsg)
		Help(,,"PESQLIST",,STR0048+cMsg+STR0049,1,1)	//"O campo "###" não foi encontrado no Didionário de Campos (SX3)"
		Return 0
	EndIf
	
	DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE OemToAnsi(STR0010) //"Pesquisa"
	
	@05,05 COMBOBOX oCBX VAR cOrd ITEMS aOrd SIZE 206,36 PIXEL OF oDlg FONT oDlg:oFont
	
	@22,05 MSGET oBigGet VAR cCampo SIZE 206,10 PIXEL
	
	If lMenuDef
		DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ;
			ACTION If(lPreview,( DbGoto(aList[oList:nAt,Len(aList[oList:nAt])]), nRet := 1, oDlg:End() ),;
						(lPreview := AxPreview(cAlias,lDetail,cCampo,aLista,aMyOrd,nOrd,lSeeAll,aPesqVar,@oPPreview,oBigGet,aScroll,nOrd,@oList,@aList), ;
						If(!lPreview,oDlg:End(),(PesqDetail(.F.,oDlg,{},oBigGet),oCBX:Disable(),oDetail:Disable()))))
	
		DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION If(lPreview,(lPreview:= .F.,oPPreview:Hide(),PesqDetail(!lDetail,oDlg,aScroll,oBigGet,nOrd),;
																oCBX:Enable(),oDetail:Enable()),oDlg:End())
	Else
		DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (lSeek := .T.,oDlg:End())
		DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()
	EndIf
	
	If ( lUseDetail )
		@22,05 MSPANEL oPPreview SIZE 205,84 OF oDlg
		oPPreview:Hide()
		DEFINE SBUTTON oDetail FROM 35,215 TYPE 5 OF oDlg ENABLE ONSTOP STR0032 ACTION (lDetail := PesqDetail(lDetail,@oDlg,@aScroll,@oBigGet,nOrd,oPPreview),;
																						If(lMenuDef,(lPreview:= .F.,oPPreview:Hide()),)) //"Detalhes"
	
		For ni := 1 To Len(aAllLista)
			Aadd(aScroll,NIL)
			@22,05 SCROLLBOX aScroll[ni] VERTICAL SIZE 84,205 BORDER
			aScroll[ni]:Hide()
	
			For nj := 1 To Len(aAllLista[ni])
				cVar := "aPesqVar["+StrZero(ni,2)+"]["+StrZero(nj,2)+"]"
				bBloco  := &("{ | u | If( PCount() == 0, "+cVar+","+cVar+" := u)}")
				PesqInit(aAllLista[ni],aScroll[ni],nj,bBloco,cVar)
			Next
		Next
		
		oCbx:bChange := {|| PesqChange(@nOrd,oCbx:nAt,@aLista,cAlias,@aAllLista,@aScroll,@lDetail,@oDetail,@oDlg,@oBigGet) }
		aLista := Aclone(aAllLista[nOrd])
	Else
		oCbx:bChange := {|| nOrd := oCbx:nAt}
	EndIf
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If ( lSeek )
		nRet := 1
		AxPesqSeek("TMP",lDetail,cCampo,aLista,aMyOrd,nOrd,lSeeAll,aPesqVar)
		SetKey(VK_F12,bSav12)
	Else
		SetKey(VK_F12,bSav12)
	EndIf

Return nRet

/*{Protheus.doc} User Function AF8ATU
	Popula campos AF8_XCONSU e AF8_XDTCON utilizados no painel gerencial da diretoria
	@type  Function
	@author Fernando Macieira
	@since 19/07/2018
	@version 01
	@history Chamado 045962 - FWNM - 19/07/2018 - Popula campos para painel gerencial
*/

User Function AF8ATU()

	U_ADINF009P('ADPMS005P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de consulta sintetica e analitica dos projetos de investimentos')

	//Monta Arquivo Temporario
	MsgRun( "Atualizando consumo dos projetos, aguarde...",,{ || AtuAF8() } )
	
Return
	

/*{Protheus.doc} Static Function ATUAF8
	Sem detalhamento
	@type  Function
	@author Fernando Macieira
	@since 19/07/2018
	@version 01
	@history 
*/

Static Function AtuAF8()
	
	Local nConsumo := 0
	
	cFilter := Nil
	
	dbSelectArea("TMP")
	TMP->( dbGoTop() )
	Do While TMP->( !EOF() )
	
		nConsumo := 0
		nConsumo := u_ADCOM017P(TMP->AF8_PROJET,"BROWSE")
		
		// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 23/10/2019
		aDespesas := {}
		aDespesas := u_ADCOM017P(TMP->AF8_PROJET,"BROWSE",,"DESPESAS")
		//
		
		AF8->( dbSetOrder(1) )
		If AF8->( dbSeek(FWxFilial("AF8")+TMP->AF8_PROJET) )
			RecLock("AF8", .f.)
			
				AF8->AF8_XCONSU := nConsumo
				AF8->AF8_XDTCON := msDate()
				
				// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 23/10/2019				
				If Len(aDespesas) > 0
					AF8->AF8_XTOTAL := aDespesas[1]
					AF8->AF8_XVLIPI := aDespesas[2]
					AF8->AF8_XVLFRE := aDespesas[3]
					AF8->AF8_XVLDES := aDespesas[4]
					AF8->AF8_XVLSEG := aDespesas[5]
					AF8->AF8_XICMSR := aDespesas[6]
					AF8->AF8_XDESCO := aDespesas[7]
					AF8->AF8_XVLDEV := aDespesas[8]
					AF8->AF8_XVLPIS := aDespesas[9]
					AF8->AF8_XVLCOF := aDespesas[10]
					AF8->AF8_XVLICM := aDespesas[11]
					AF8->AF8_XVLRSA := aDespesas[12]
					//
				EndIf
				//
			
			AF8->( msUnLock() )
		EndIf
	
		TMP->( dbSkip() )
	
	EndDo
	
	msgInfo("Consumos dos projetos atualizados com sucesso!")
	
	MsgRun( "Carregando dados dos projetos, aguarde...",,{ || MontaTrab() } )
	
	mBrowse( 6, 1,22,75,"TMP",aCposBrw,,,,,,,,,,,,,cFilter)

Return

/*{Protheus.doc} Static Function EXPEXCEL
	Sem detalhamento
	@type  Function
	@author William Costa
	@since Sem data
	@version 01
	@history 
*/

STATIC FUNCTION EXPEXCEL(cProjeto,nLimite,nConsumo,nSaldoPrj)

	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="Relatorio de Projetos"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:=TMSPrinter():New()
	Private nOpca		:=  0
	Private cColunas    := ''
	Private oExcel      := FWMSEXCEL():New()
	Private cArquivo    := 'C:\temp\' + 'REL_PROJETOS' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	Private oMsExcel    := NIL
	Private cPlan1      := "Informacoes Gerais"
    Private cTit1       := "Informacoes Gerais"
    Private aLinha1     := {}
    Private nExcel1     := 0
    Private nLinha1     := 0
    Private cPlan2      := "Pedidos de Compras"
    Private cTit2       := "Pedidos de Compras"
    Private aLinha2     := {}
	Private nExcel2     := 0 
	Private nLinha2     := 0
    Private cPlan3      := "Notas Entrada"
    Private cTit3       := "Notas Entrada"
    Private aLinha3     := {}
	Private nExcel3     := 0 
	Private nLinha3     := 0
	Private cPlan4      := "Produtos - PCs"
    Private cTit4       := "Produtos - PCs"
    Private aLinha4     := {}
	Private nExcel4     := 0 
	Private nLinha4     := 0
	Private cPlan5      := "Devolução"
    Private cTit5       := "Devolução"
    Private aLinha5     := {}
	Private nExcel5     := 0 
	Private nLinha5     := 0
	Private cPlan6      := "Entrega"
    Private cTit6       := "Entrega"
    Private aLinha6     := {}
	Private nExcel6     := 0 
	Private nLinha6     := 0
	Private cPlan7      := "SA - Solic. Armazéns"
    Private cTit7       := "SA - Solic. Armazéns"
    Private aLinha7     := {}
	Private nExcel7     := 0 
	Private nLinha7     := 0
	Private nTotReg     := 0
	
	// Chamado TI - incluido mensagem 'todas as outras abas' - FWNM - 27/05/2019
	//msgInfo("Lembre-se de que para exportar todas as abas para o Excel, você deverá carregá-las na memória antes, clicando em todas elas antes...")
	
	// *** INICIO CHAMADO 046111 - 14/01/2019 - William Costa POSICAO PROJETOS  Criado Relatório em Excel*** //
	/*
	IF cArq3->(EOF()) == .T.
		
		MSGSTOP("OLÁ " + Alltrim(cUserName) + ", favor clicar na aba pedidos de compra e todas as outras abas para processar os dados antes de exportar para excel!!!","ADPMS005-01")
		RETURN(NIL)
	
	ENDIF
	
	IF cArq4->(EOF()) == .T.
		
		MSGSTOP("OLÁ " + Alltrim(cUserName) + ", favor clicar na aba nota fiscal e todas as outras abas para processar os dados antes de exportar para excel!!!","ADPMS005-02")
		RETURN(NIL)
	
	ENDIF
	
	IF cArq5->(EOF()) == .T.
		
		MSGSTOP("OLÁ " + Alltrim(cUserName) + ", favor clicar na aba produtos - PCs e todas as outras abas para processar os dados antes de exportar para excel!!!","ADPMS005-02")
		RETURN(NIL)
	
	ENDIF
	
	IF cArq8->(EOF()) == .T.
		
		MSGSTOP("OLÁ " + Alltrim(cUserName) + ", favor clicar na aba Entrega e todas as outras abas para processar os dados antes de exportar para excel!!!","ADPMS005-02")
		RETURN(NIL)
	
	ENDIF
	
	IF cArq9->(EOF()) == .T.
		
		MSGSTOP("OLÁ " + Alltrim(cUserName) + ", favor clicar na aba SA - Solic. Armazéns e todas as outras abas para processar os dados antes de exportar para excel!!!","ADPMS005-02")
		RETURN(NIL)
	
	ENDIF
	*/
	
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio de Projetos" )
    
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||LogEXPEXCEL(nLimite,nConsumo,nSaldoPrj)},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})	
	FormBatch( cCadastro, aSays, aButtons )
	
	// *** FINAL CHAMADO 046111 - 14/01/2019 - William Costa POSICAO PROJETOS  Criado Relatório em Excel*** //  

RETURN(NIL)

/*{Protheus.doc} Static Function LOGEXPEXCEL
	Sem detalhamento
	@type  Function
	@author William Costa
	@since Sem data
	@version 01
	@history 
*/

Static Function LogEXPEXCEL(nLimite,nConsumo,nSaldoPrj)

	BEGIN SEQUENCE
		
		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("Nao Existe Excel Instalado")
            BREAK
        EndIF
        	
    	Cabec()             
        GeraExcel(nLimite,nConsumo,nSaldoPrj)
        SalvaXml()
		CriaExcel()
	
	    MsgInfo("Arquivo Excel gerado!")    
	    
	END SEQUENCE
	
Return(NIL) 

/*{Protheus.doc} Static Function GERAEXCEL
	Sem detalhamento
	@type  Function
	@author William Costa
	@since Sem data
	@version 01
	@history 
*/

Static Function GeraExcel(nLimite,nConsumo,nSaldoPrj)

	Local aArea := GetArea()
	
	//Conta o Total de registros.
	nTotReg := Contar("cArq3","!Eof()")
	
	// *** INICIO PLANILHA 1 *** //
			
	nLinha1  := nLinha1 + 1                                       

    //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
   	AADD(aLinha1,{ "", ; // 01 A  
   	               "", ; // 02 B   
   	               ""  ; // 03 C  
   	                  })
	//===================== FINAL CRIA VETOR COM POSICAO VAZIA
	
	//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
	aLinha1[nLinha1][01] := TRANSFORM(nLimite,   "@E 999,999,999,999.99" ) //A
	aLinha1[nLinha1][02] := TRANSFORM(nConsumo,  "@E 999,999,999,999.99" ) //B
	aLinha1[nLinha1][03] := TRANSFORM(nSaldoPrj, "@E 999,999,999,999.99" ) //C
	                                  
	//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				
	//============================== INICIO IMPRIME LINHA NO EXCEL
	FOR nExcel1 := 1 TO nLinha1
   	oExcel:AddRow(cPlan1,cTit1,{aLinha1[nExcel1][01],; // 01 A  
	                            aLinha1[nExcel1][02],; // 02 B  
	                            aLinha1[nExcel1][03] ; // 03 C  
	                                                 }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
    NEXT 
 	//============================== FINAL IMPRIME LINHA NO EXCEL
 	// *** FINAL PLANILHA 1 *** //
 	
 	// *** INICIO PLANILHA 2 *** //
 		
	//Atribui a quantidade de registros e regua de processamento.
	DBSELECTAREA("cArq3")
		cArq3->(DBGOTOP())
		WHILE cArq3->(!EOF())
		
			IncProc("Processando Pedidos de Compra: " + cArq3->NUMERO)  
		
        	nLinha2  := nLinha2 + 1                                       
		
            //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
		   	AADD(aLinha2,{ "", ; // 01 A  
		   	               "", ; // 02 B   
		   	               "", ; // 03 C  
		   	               "", ; // 04 D  
		   	               ""  ; // 05 E  
		   	                  })
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			aLinha2[nLinha2][01] := cArq3->FILORIG                                               //A
			aLinha2[nLinha2][02] := cArq3->NUMERO                                                //B
			aLinha2[nLinha2][03] := cArq3->EMISSAO                                               //C
			aLinha2[nLinha2][04] := cArq3->ENTREGA                                               //D
			aLinha2[nLinha2][05] := Transform(cArq3->VALORITEM,"@E 999,999,999,999,999,999.99") //E
			                                  
			//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				
			cArq3->(dbSkip())    
		
		ENDDO //end do while cArq3
	
	oLbx2:Gotop()
	oLbx2:Refresh()
	oLbx4:Refresh()
	oLbx4:SetFocus()	
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	FOR nExcel2 := 1 TO nLinha2
   	oExcel:AddRow(cPlan2,cTit2,{aLinha2[nExcel2][01],; // 01 A  
	                            aLinha2[nExcel2][02],; // 02 B  
	                            aLinha2[nExcel2][03],; // 03 C  
	                            aLinha2[nExcel2][04],; // 04 D  
	                            aLinha2[nExcel2][05] ; // 05 E  
	                                              }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
    NEXT 
 	//============================== FINAL IMPRIME LINHA NO EXCEL
 	
 	// *** FINAL PLANILHA 2 *** //
 	
 	// *** INICIO PLANILHA 3 *** //
 	
 	//Atribui a quantidade de registros e regua de processamento.
	DBSELECTAREA("cArq4")
		cArq4->(DBGOTOP())
		WHILE cArq4->(!EOF())
		
			IncProc("Processando Notas de Entrada: " + cArq4->NUMERO)  
		
        	nLinha3  := nLinha3 + 1                                       
		
            //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
		   	AADD(aLinha3,{ "", ; // 01 A  
		   	               "", ; // 02 B   
		   	               "", ; // 03 C  
		   	               "", ; // 04 D  
		   	               "", ; // 05 E  
		   	               "", ; // 06 F
		   	               ""  ; // 07 G
		   	                  })
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			aLinha3[nLinha3][01] := cArq4->FILORIG                                            //A
			aLinha3[nLinha3][02] := cArq4->NUMERO                                             //B
			aLinha3[nLinha3][03] := cArq4->EMISSAO                                            //C
			aLinha3[nLinha3][04] := Transform(cArq4->VALORNOTA,PesqPict("SF1","F1_VALMERC")) //D
			aLinha3[nLinha3][05] := cArq4->DUPLICATA                                          //E
			aLinha3[nLinha3][06] := cArq4->PEDIDO                                             //F
			aLinha3[nLinha3][07] := cArq4->ITEMPC                                             //G
			                                  
			//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				
			cArq4->(dbSkip())    
		
		ENDDO //end do while cArq3
	
	oLbx3:Gotop()
	oLbx3:Refresh()
	oLbx3:SetFocus()	
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	FOR nExcel3 := 1 TO nLinha3
   	oExcel:AddRow(cPlan3,cTit3,{aLinha3[nExcel3][01],; // 01 A  
	                            aLinha3[nExcel3][02],; // 02 B  
	                            aLinha3[nExcel3][03],; // 03 C  
	                            aLinha3[nExcel3][04],; // 04 D  
	                            aLinha3[nExcel3][05],; // 05 E  
	                            aLinha3[nExcel3][06],; // 06 F
	                            aLinha3[nExcel3][07] ; // 07 G
	                                              }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
    NEXT 
 	//============================== FINAL IMPRIME LINHA NO EXCEL
 	
 	// *** FINAL PLANILHA 3 *** //
 	
 	// *** INICIO PLANILHA 4 *** //
 	
 	//Atribui a quantidade de registros e regua de processamento.
	DBSELECTAREA("cArq5")
		cArq5->(DBGOTOP())
		WHILE cArq5->(!EOF())
		
			IncProc("Processando Produtos - PCs: " + cArq5->NUMERO)  
		
        	nLinha4  := nLinha4 + 1                                       
		
            //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
		   	AADD(aLinha4,{ "", ; // 01 A  
		   	               "", ; // 02 B   
		   	               "", ; // 03 C  
		   	               "", ; // 04 D  
		   	               "", ; // 05 E  
		   	               "", ; // 06 F
		   	               "", ; // 07 G
		   	               "", ; // 08 H
		   	               "", ; // 09 I
		   	               "", ; // 10 J
		   	               ""  ; // 11 K
		   	                   })
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			aLinha4[nLinha4][01] := cArq5->FILORIG                                       //A
			aLinha4[nLinha4][02] := cArq5->NUMERO                                        //B
			aLinha4[nLinha4][03] := cArq5->EMISSAO                                       //C
			aLinha4[nLinha4][04] := cArq5->PRODUTO                                       //D
			aLinha4[nLinha4][05] := cArq5->DESCRI                                        //E
			aLinha4[nLinha4][06] := cArq5->UM                                            //F
			aLinha4[nLinha4][07] := cArq5->SEGUM                                         //G
			aLinha4[nLinha4][08] := Transform(cArq5->QUANT,PesqPictQt("C7_QUANT",15))   //H
			aLinha4[nLinha4][09] := Transform(cArq5->QTSEGUM,PesqPictQt("C7_QUANT",15)) //I
			aLinha4[nLinha4][10] := Transform(cArq5->PRECO,PesqPict("SC7","C7_TOTAL"))  //J
			aLinha4[nLinha4][11] := cArq5->CONDPAG                                       //K
			                                  
			//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				
			cArq5->(dbSkip())    
		
		ENDDO //end do while cArq3
	
	oLbx4:Gotop()
	oLbx4:Refresh()
	oLbx4:SetFocus()	
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	FOR nExcel4 := 1 TO nLinha4
   	oExcel:AddRow(cPlan4,cTit4,{aLinha4[nExcel4][01],; // 01 A  
	                            aLinha4[nExcel4][02],; // 02 B  
	                            aLinha4[nExcel4][03],; // 03 C  
	                            aLinha4[nExcel4][04],; // 04 D  
	                            aLinha4[nExcel4][05],; // 05 E  
	                            aLinha4[nExcel4][06],; // 06 F
	                            aLinha4[nExcel4][07],; // 07 G
	                            aLinha4[nExcel4][08],; // 08 H  
	                            aLinha4[nExcel4][09],; // 09 I  
	                            aLinha4[nExcel4][10],; // 10 J  
	                            aLinha4[nExcel4][11] ; // 11 K
	                                              }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
    NEXT 
 	//============================== FINAL IMPRIME LINHA NO EXCEL
 	
 	// *** FINAL PLANILHA 4 *** //
 	
 	// *** INICIO PLANILHA 5 *** //
 	
 	//Atribui a quantidade de registros e regua de processamento.
	DBSELECTAREA("cArq7")
		cArq7->(DBGOTOP())
		WHILE cArq7->(!EOF())
		
			IncProc("Processando Devolução: " + cArq7->NUMERO)  
		
        	nLinha5  := nLinha5 + 1                                       
		
            //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
		   	AADD(aLinha5,{ "", ; // 01 A  
		   	               "", ; // 02 B   
		   	               "", ; // 03 C  
		   	               ""  ; // 04 D  
		   	                   })
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			aLinha5[nLinha5][01] := cArq7->FILORIG                                            //A
			aLinha5[nLinha5][02] := cArq7->NUMERO                                             //B
			aLinha5[nLinha5][03] := cArq7->EMISSAO                                            //C
			aLinha5[nLinha5][04] := Transform(cArq7->VALORNOTA,PesqPict("SF2","F2_VALMERC")) //D
			                                  
			//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				
			cArq7->(dbSkip())    
		
		ENDDO //end do while cArq7
	
	oLbx5:Gotop()
	oLbx5:Refresh()
	oLbx5:SetFocus()	
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	FOR nExcel5 := 1 TO nLinha5
   	oExcel:AddRow(cPlan5,cTit5,{aLinha5[nExcel5][01],; // 01 A  
	                            aLinha5[nExcel5][02],; // 02 B  
	                            aLinha5[nExcel5][03],; // 03 C  
	                            aLinha5[nExcel5][04] ; // 04 D  
	                                              }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
    NEXT 
 	//============================== FINAL IMPRIME LINHA NO EXCEL
 	
 	// *** FINAL PLANILHA 5 *** //
 	
 	// *** INICIO PLANILHA 6 *** //
 	
 	//Atribui a quantidade de registros e regua de processamento.
	DBSELECTAREA("cArq8")
		cArq8->(DBGOTOP())
		WHILE cArq8->(!EOF())
		
			IncProc("Processando Entraga: " + cArq8->NOTA)  
		
        	nLinha6  := nLinha6 + 1                                       
		
            //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
		   	AADD(aLinha6,{ "", ; // 01 A  
		   	               "", ; // 02 B   
		   	               "", ; // 03 C  
		   	               "", ; // 04 D  
		   	               "", ; // 05 E  
		   	               "", ; // 06 F   
		   	               "", ; // 07 G  
		   	               "", ; // 08 H
		   	               "", ; // 09 I  
		   	               ""  ; // 10 J
		   	                   })
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			aLinha6[nLinha6][01] := cArq8->FILORIG  //A
			aLinha6[nLinha6][02] := cArq8->NOTA     //B
			aLinha6[nLinha6][03] := cArq8->EMISNF   //C
			aLinha6[nLinha6][04] := cArq8->PEDIDO   //D
			aLinha6[nLinha6][05] := cArq8->EMISPD   //E
			aLinha6[nLinha6][06] := cArq8->PRODUTO  //F
			aLinha6[nLinha6][07] := cArq8->DESCR    //G
			aLinha6[nLinha6][08] := cArq8->DT_PREV  //H
			aLinha6[nLinha6][09] := cArq8->DT_REAL  //I
			aLinha6[nLinha6][10] := cArq8->DIF_DIAS //J
			                                  
			//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				
			cArq8->(dbSkip())    
		
		ENDDO //end do while cArq7
	
	oLbx6:Gotop()
	oLbx6:Refresh()
	oLbx6:SetFocus()	
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	FOR nExcel6 := 1 TO nLinha6
   	oExcel:AddRow(cPlan6,cTit6,{aLinha6[nExcel6][01],; // 01 A  
	                            aLinha6[nExcel6][02],; // 02 B  
	                            aLinha6[nExcel6][03],; // 03 C  
	                            aLinha6[nExcel6][04],; // 04 D  
	                            aLinha6[nExcel6][05],; // 05 E  
	                            aLinha6[nExcel6][06],; // 06 F  
	                            aLinha6[nExcel6][07],; // 07 G
	                            aLinha6[nExcel6][08],; // 08 H  
	                            aLinha6[nExcel6][09],; // 09 I  
	                            aLinha6[nExcel6][10] ; // 10 J
	                                              }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
    NEXT 
 	//============================== FINAL IMPRIME LINHA NO EXCEL
 	
 	// *** FINAL PLANILHA 6 *** //
 	
 	// *** INICIO PLANILHA 7 *** //
 	
 	//Atribui a quantidade de registros e regua de processamento.
	DBSELECTAREA("cArq9")
		cArq9->(DBGOTOP())
		WHILE cArq9->(!EOF())
		
			IncProc("Processando S.A: " + cArq9->SA)  
		
        	nLinha7  := nLinha7 + 1                                       
		
            //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
		   	AADD(aLinha7,{ "", ; // 01 A  
		   	               "", ; // 02 B   
		   	               ""  ; // 03 C  
		   	                   })
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			aLinha7[nLinha7][01] := cArq9->SA                                             //A
			aLinha7[nLinha7][02] := cArq9->EMISSAO                                        //B
			aLinha7[nLinha7][03] := Transform(cArq9->VALOR,PesqPict("SCP","CP_XPRJVLR")) //C
			                                  
			//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				
			cArq9->(dbSkip())    
		
		ENDDO //end do while cArq7
	
	oLbx7:Gotop()
	oLbx7:Refresh()
	oLbx7:SetFocus()	
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	FOR nExcel7 := 1 TO nLinha7
   	oExcel:AddRow(cPlan7,cTit7,{aLinha7[nExcel7][01],; // 01 A  
	                            aLinha7[nExcel7][02],; // 02 B  
	                            aLinha7[nExcel7][03] ; // 03 C  
	                                              }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
    NEXT 
 	//============================== FINAL IMPRIME LINHA NO EXCEL
 	
 	// *** FINAL PLANILHA 7 *** //
	 	
 	RestArea(aArea)
	 	
Return()    

/*{Protheus.doc} Static Function SALVAXML
	Sem detalhamento
	@type  Function
	@author William Costa
	@since Sem data
	@version 01
	@history 
*/

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile(cArquivo)

Return()

/*{Protheus.doc} Static Function CRIAEXCEL
	Sem detalhamento
	@type  Function
	@author William Costa
	@since Sem data
	@version 01
	@history 
*/

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open(cArquivo)
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 
                                
/*{Protheus.doc} Static Function CABEC
	Sem detalhamento
	@type  Function
	@author William Costa
	@since Sem data
	@version 01
	@history 
*/
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlan1)
	oExcel:AddTable (cPlan1,cTit1)
	oExcel:AddColumn(cPlan1,cTit1,"Limite Atual "  ,1,1) // 01 A
    oExcel:AddColumn(cPlan1,cTit1,"Consumo Atual " ,1,1) // 02 B
	oExcel:AddColumn(cPlan1,cTit1,"Saldo "         ,1,1) // 03 C
	
	oExcel:AddworkSheet(cPlan2)
	oExcel:AddTable (cPlan2,cTit2)
	oExcel:AddColumn(cPlan2,cTit2,"Filial Origem "   ,1,1) // 01 A
    oExcel:AddColumn(cPlan2,cTit2,"Numero "          ,1,1) // 02 B
	oExcel:AddColumn(cPlan2,cTit2,"Emissao "         ,1,1) // 03 C
	oExcel:AddColumn(cPlan2,cTit2,"Data de Entrega " ,1,1) // 04 D
	oExcel:AddColumn(cPlan2,cTit2,"Total PC   "      ,1,1) // 05 E
	
	oExcel:AddworkSheet(cPlan3)
	oExcel:AddTable (cPlan3,cTit3)
	oExcel:AddColumn(cPlan3,cTit3,"Filial Origem " ,1,1) // 01 A
    oExcel:AddColumn(cPlan3,cTit3,"Numero "        ,1,1) // 02 B
	oExcel:AddColumn(cPlan3,cTit3,"Emissao "       ,1,1) // 03 C
	oExcel:AddColumn(cPlan3,cTit3,"Valor Nota "    ,1,1) // 04 D
	oExcel:AddColumn(cPlan3,cTit3,"Duplicata "     ,1,1) // 05 E
	oExcel:AddColumn(cPlan3,cTit3,"Pedido "        ,1,1) // 04 D
	oExcel:AddColumn(cPlan3,cTit3,"Item PC "       ,1,1) // 05 E
	
	oExcel:AddworkSheet(cPlan4)
	oExcel:AddTable (cPlan4,cTit4)
	oExcel:AddColumn(cPlan4,cTit4,"Filial Origem " ,1,1) // 01 A
    oExcel:AddColumn(cPlan4,cTit4,"Numero "        ,1,1) // 02 B
	oExcel:AddColumn(cPlan4,cTit4,"Emissao "       ,1,1) // 03 C
	oExcel:AddColumn(cPlan4,cTit4,"Produto "       ,1,1) // 04 D
	oExcel:AddColumn(cPlan4,cTit4,"Descrição "     ,1,1) // 05 E
	oExcel:AddColumn(cPlan4,cTit4,"UM "            ,1,1) // 06 F
	oExcel:AddColumn(cPlan4,cTit4,"2.UM "          ,1,1) // 07 G
	oExcel:AddColumn(cPlan4,cTit4,"Quantidade "    ,1,1) // 08 H
	oExcel:AddColumn(cPlan4,cTit4,"Quant. 2.a. "   ,1,1) // 09 I
	oExcel:AddColumn(cPlan4,cTit4,"Vlr. Unit "     ,1,1) // 10 J
	oExcel:AddColumn(cPlan4,cTit4,"Cond. Pagto "   ,1,1) // 11 K
	
	oExcel:AddworkSheet(cPlan5)
	oExcel:AddTable (cPlan5,cTit5)
	oExcel:AddColumn(cPlan5,cTit5,"Filial Origem " ,1,1) // 01 A
    oExcel:AddColumn(cPlan5,cTit5,"Numero "        ,1,1) // 02 B
	oExcel:AddColumn(cPlan5,cTit5,"Emissao "       ,1,1) // 03 C
	oExcel:AddColumn(cPlan5,cTit5,"Valor Nota "    ,1,1) // 04 D
	
	oExcel:AddworkSheet(cPlan6)
	oExcel:AddTable (cPlan6,cTit6)
	oExcel:AddColumn(cPlan6,cTit6,"Filial Origem "  ,1,1) // 01 A
    oExcel:AddColumn(cPlan6,cTit6,"Notas "          ,1,1) // 02 B
	oExcel:AddColumn(cPlan6,cTit6,"Emissao "        ,1,1) // 03 C
	oExcel:AddColumn(cPlan6,cTit6,"Pedido "         ,1,1) // 04 D
	oExcel:AddColumn(cPlan6,cTit6,"Emissao "        ,1,1) // 05 E
	oExcel:AddColumn(cPlan6,cTit6,"Produto "        ,1,1) // 06 F
	oExcel:AddColumn(cPlan6,cTit6,"Descrição "      ,1,1) // 07 G
	oExcel:AddColumn(cPlan6,cTit6,"Dt Prevista "    ,1,1) // 08 H
	oExcel:AddColumn(cPlan6,cTit6,"Dt Realizada "   ,1,1) // 09 I
	oExcel:AddColumn(cPlan6,cTit6,"Diferença Dias " ,1,1) // 10 J
	
	oExcel:AddworkSheet(cPlan7)
	oExcel:AddTable (cPlan7,cTit7)
	oExcel:AddColumn(cPlan7,cTit7,"Numero "    ,1,1) // 01 A
    oExcel:AddColumn(cPlan7,cTit7,"Emissao "   ,1,1) // 02 B
	oExcel:AddColumn(cPlan7,cTit7,"Valor S.A " ,1,1) // 03 C
		
RETURN(NIL)    

/*{Protheus.doc} User Function YPMS210HST
	Consulta detalhes do projeto
	@type  Function
	@author Fernando Macieira
	@since 24/04/2019
	@version 01
	@history Chamado 048763 - FWNM - 24/04/2019 - Rel Posicao Projeto
*/

User Function YPMS210HST()

	Local aRotina   := {}
	Local aUsRotina := {}
	Local aSize		 := MsAdvSize(,.F.,430)

	U_ADINF009P('ADPMS005P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de consulta sintetica e analitica dos projetos de investimentos')

	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro,"AFE",,aRotina,"AFE_TIPO=='2'","Left(AllTrim(TMP->AF8_PROJET),2)+TMP->AF8_PROJET","Left(AllTrim(TMP->AF8_PROJET),2)+TMP->AF8_PROJET",.F.,{{'ENABLE',""},{'BR_CINZA',""}},,{{STR0051,1}},Left(AllTrim(TMP->AF8_PROJET),2)+TMP->AF8_PROJET) //"Versao do projeto" // versao simulada
//	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro,"AFE",,aRotina,"AFE_TIPO=='2'","FWxFilial('AFE')+TMP->AF8_PROJET","FWxFilial('AFE')+TMP->AF8_PROJET",.F.,{{'ENABLE',""},{'BR_CINZA',""}},,{{STR0051,1}},FWxFilial('AFE')+TMP->AF8_PROJET) //"Versao do projeto" // versao simulada

Return .t.

/*/{Protheus.doc} User Function PosUpZC7
	Posiciona tabelas AF8 e ZC7 antes de chamar a rotina de tela de aprovações
	@type  Function
	@author FWNM
	@since 04/12/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 053839 || OS 055224 || CONTROLADORIA || DAIANE || (16) || REDUCAO VLR PRJ
/*/
User Function POSUPZC7()

	Local cTmpPrj := TMP->AF8_PROJET

	U_ADINF009P('ADPMS005P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de consulta sintetica e analitica dos projetos de investimentos')

	AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
	AF8->( dbSeek( FWxFilial("AF8")+cTmpPrj ) )

//	ZC7->( dbSetOrder(3) ) // ZC7_FILIAL+ZC7_PROJET+ZC7_REVPRJ 
//	ZC7->( dbSeek( FWxFilial("ZC7")))

	u_UpZC7()
	
Return