#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "MATR110.CH"
#INCLUDE "REPORT.CH"

#DEFINE GD_INSERT	1
#DEFINE GD_DELETE	4	
#DEFINE GD_UPDATE	2

#DEFINE STR0082 "Legendas da Aprovacao :"
#DEFINE STR0060 "BLQ:Bloqueado"
#DEFINE STR0061 "Ok:Liberado"
#DEFINE STR0131 "Ok:REJEITADO"
#DEFINE STR0062 "??:Aguar.Lib"
#DEFINE STR0067 "##:Nivel Lib"
#DEFINE STR0081 "NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
#DEFINE STR0083 "NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero da Autorizacao de Entrega."
#DEFINE STR0125 "1- "
#DEFINE STR0126 "2- "
#DEFINE STR0127 "3- "
#DEFINE STR0128 "1, 2, 3"
#DEFINE STR0110 " "
#DEFINE STR0111 " "
#DEFINE STR0112 " "
#DEFINE STR0124 ":"
#DEFINE STR0129 " "
#DEFINE STR0130 " "
#DEFINE STR0131 " "
#DEFINE STR0132 "Por conta remetente"
#DEFINE STR0133 "Por conta destinatario"
#DEFINE STR0134 "Por Conta Terceiros"

/*/{Protheus.doc} User Function ADOA040
	Liberacao Pedido Compra
	@type  Function
	@author Almir Bandina
	@since 03/05/2008
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado TI     - Ricardo Lima - 31/01/2018 - Ajuste no tamanho da variavel cObs
	@chamado TI     - FWNM         - 27/03/2019 - Inclusao de historico de aprovacoes - SCR
	@chamado 053321 - FWNM         - 18/11/2019 - 053321 || OS 054677 || TECNOLOGIA || LUIZ || 8451 || ENVIAR PEDIDO COMPRA
	@chamado 051895 - FWNM         - 25/11/2019 - 051895 || OS 053235 || SUPRIMENTOS || LUIS || 3525 || WORKFLOW PEDIDOS
	@chamado 051895 - FWNM         - 26/11/2019 - Retirar envio email aprovador
	@chamado 054308 - FWNM         - 19/12/2019 - OS 055703 || SUPRIMENTOS || RACHEL || 1621063514 || PEDIDO DE COMPRA
	@chamado TI     - FWNM         - 19/12/2019 - Desativar envio email devido lentidão
	@history Chamado 057440 - FWNM         - 04/05/2020 - || OS 058919 || TECNOLOGIA || LUIZ || 8451 || HIST. APROVACAO
	@history chamado TI     - FWNM         - 14/05/2020 - Modificado filtro para gravar campo customizado CR_XLEGAPP
	@history CHAMADO 058461 - ADRIANO SAVOINE - 26/05/2020 - ALTERADO PARA DENTRO DO IF A CONDIÇÃO ABAIXO POIS ELA ESTAVA FORA E NAO CONSIDERAVA DBF.
/*/
User Function ADOA040()

	Local aAreaAtu	:= GetArea()
	Local bFiltSCR

	// Chamado n. 057440 || OS 058919 || TECNOLOGIA || LUIZ || 8451 || HIST. APROVACAO - FWNM - 04/05/2020
	
	Local aCores 	:= {	{ "CR_STATUS == '01'", "BR_AZUL"		},;  // Aguardando Outros Níveis
							{ "CR_STATUS == '02'", "BR_VERMELHO"	},;  // Aguardando liberação do Usuário
							{ "CR_STATUS == '03'", "BR_VERDE"		},;  // Liberado Pelo Usuário Usuário
							{ "CR_STATUS == '04'", "BR_PRETO"		},;  // Bloqueado Pelo Usuário
							{ "CR_STATUS == '05'", "BR_CINZA"		} ;  // Liberado por Outro Usuário
							}
	/*
	Local aCores 	:= {	{ "CR_XLEGAPP == '1'", "BR_VERDE"		},;  // Primeira aprovação
							{ "CR_XLEGAPP == '2'", "BR_AMARELO"		},;  // Alteração sem mudanca de valor
							{ "CR_XLEGAPP == '3'", "BR_VERMELHO"	},;  // Alteração com mudanca de valor
							{ "CR_XLEGAPP == '4'", "BR_VERMELHO"	} ;  // Substituição PC
							}
	*/

	Local aIndexSCR	:= {}
	Local lWhen		:= .T.
	Local cQuerySCR	:= ""
	Local cFilMbSCR	:= ""
	Local cPerg			:= PadR( "ADOA04", 10, " " )
	Private NAUTOADT    := 0
	Private cString		:= "SCR"
	Private cCadastro 	:= OemtoAnsi( Alltrim( Posicione( "SX2", 1, cString, "X2_NOME" ) ) )
	Private aRotina		:= MenuDef()
	Private nTipoPed	:= 1											// Usado na Visualização do Pedido de Compra
	Private l120auto	:= .F.											// Usado na Visualização do Pedido de Compra
	Private l120Pedido	:= .T.											// Usado na Visualização do Pedido de Compra
	Private lGatilha	:= .F.											// Usado na Visualização do Pedido de Compra
	Private lVldHead	:= .F.											// Usado na Visualização do Pedido de Compra   
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	CriaSX1( cPerg )
	Pergunte( cPerg, .T. )

	//cDebug := ""

	#IFDEF TOP
		If __cUserId <> "000000"
			cQuerySCR	:= "CR_TIPO = 'PC' AND CR_USER = '" + __cUserId + "' "
		Else
			cQuerySCR	:= "CR_TIPO = 'PC' "
		EndIf
		If mv_par01 == 1	// só bloqueados
			cQuerySCR	+= " AND CR_STATUS = '02' "
		EndIf
	#ELSE
		If __cUserId <> "000000"
			cQuerySCR   := "CR_TIPO = 'PC' AND CR_USER = '" + __cUserId + "' "
			cFilMbSCR	:= "CR_TIPO = 'PC' .AND. CR_USER == '" + __cUserId + "' "
		Else
			cQuerySCR   := "CR_TIPO = 'PC' "
			cFilMbSCR	:= "CR_TIPO == 'PC' "
		EndIf
		If mv_par01 == 1	// só bloqueados
			cQuerySCR	+= " AND CR_STATUS = '02' "
			cFilMbSCR	+= " .AND. CR_STATUS == '02' "
		EndIf
		// CHAMADO: 058461 - ADRIANO SAVOINE - ALTERADO PARA DENTRO DO IF A CONDIÇÃO ABAIXO POIS ELA ESTAVA FORA E NAO CONSIDERAVA DBF.
		bFiltSCR	:= {|x| If( x == Nil, FilBrowse( "SCR", @aIndexSCR, @cFilMbSCR ),If(x == 1, cFilMbSCR, cQuerySCR ) ) }
		Eval(bFiltSCR)

	#ENDIF

	// Chamado n. 057440 || OS 058919 || TECNOLOGIA || LUIZ || 8451 || HIST. APROVACAO - FWNM - 04/05/2020
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT CR_FILIAL, CR_NUM, R_E_C_N_O_ SCR_RECNO
	cQuery += " FROM " + RetSqlName("SCR") + " SCR (NOLOCK)
	cQuery += " WHERE " + cQuerySCR
	//cQuery += " AND CR_STATUS='02' // Chamado n. TI - FWNM - 14/05/2020
	cQuery += " AND CR_XLEGAPP=''  
	cQuery += " AND D_E_L_E_T_=''

	tcQuery cQuery New Alias "Work"

	Do While Work->( !EOF() )

		SC7->( dbSetOrder(1) ) // C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN, R_E_C_N_O_, D_E_L_E_T_
		If SC7->( dbSeek( Work->CR_FILIAL+AllTrim(Work->CR_NUM) ) )

			dbSelectArea("SCR")
			dbGoto(Work->SCR_RECNO)

			If Empty(SC7->C7_XLEGAPP)
				cQtdLegApp := "1"
			Else
				cQtdLegApp := SC7->C7_XLEGAPP
			EndIf

			RecLock("SCR", .f.)
				SCR->CR_XLEGAPP := cQtdLegApp
			SCR->( msUnLock() )
		
		EndIf

		Work->( dbSkip() )

	EndDo

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	//
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no arquivo de usuários x centro de custo                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SCR" )
	dbSetOrder( 1 )
	dbGoTop() 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a interface com o usuário dos registros já cadastrados                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF TOP
		mBrowse(6,1,22,75,"SCR",,,,,,aCores,,,,,,,,cQuerySCR)
	#ELSE
		mBrowse(6,1,22,75,"SCR",,,,,,aCores)
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna os indices originais                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SCR" )
	RetIndex( "SCR" )
	#IFNDEF TOP
		dbClearFilter()
		aEval( aIndexSCR, {|x| Ferase( x[1] + OrdBagExt() ) } )
	#ENDIF

Return( Nil )

/*/{Protheus.doc} User Function ADO04VPC
	Visualiza Pedido Compra
	@type  Function
	@author Almir Bandina
	@since 03/05/2008
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function Ado04VPC( cAlias, nReg, nOpcx )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define as variáveis da rotina                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aAreaAtu	:= GetArea()
	Local aAreaSC7	:= SC7->( GetArea() )

	U_ADINF009P('ADOA040' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no pedido de compra                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SC7" )
	dbSetOrder( 1 )
	If MsSeek( xFilial( "SC7" ) + Left( SCR->CR_NUM, TAMSX3( "C7_NUM" )[1] ) )
		A120Pedido( "SC7", SC7->( Recno() ), 2, Nil, .F., .F. )
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura as áreas originais                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestArea( aAreaSC7 )
	RestArea( aAreaAtu )

Return( Nil )

/*/{Protheus.doc} User Function ADO04LIB
	Visualiza Liberacao Pedido Compra
	@type  Function
	@author Almir Bandina
	@since 03/05/2008
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function Ado04LIB( cAlias, nReg, nOpcx , sMetodo )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define as variáveis da rotina                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local oDlg
	Local aAreaAtu	:= GetArea()
	Local aAreaSC7	:= SC7->( GetArea() )
	Local aAreaSA2	:= SA2->( GetArea() )
	Local dDatLib	:= IIF (NOPCX == 6,DATE(),CTOD("  /  /  ")) //CASAROLI
	//Local dDatLib	:= SCR->CR_DATALIB 
	//Local dDatRej	:= SCR->CR_DATREJ
	Local dDatRej	:= IIF (NOPCX == 8,DATE(),CTOD("  /  /  ")) //CASAROLI
	Local nLimMin	:= 0
	Local nLimMax	:= 0
	Local nOpc		:= 0
	Local cQry		:= ""
	Local cStatus	:= ""
	Local cTpLib	:= ""
	Local cObs		:= Space(254) //SCR->CR_OBS // Ricardo Lima - 31/01/18
	Local cNewApr	:= CriaVar( "CR_USER", .F. )
	Local cMailPC   := ""
	//Local cMailCR   := "" // Chamado n. 051895 || OS 053235 || SUPRIMENTOS || LUIS || 3525 || WORKFLOW PEDIDOS - FWNM - 26/11/2019
	Private cCodGrp := ""

	U_ADINF009P('ADOA040' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	if sMetodo = 'M'
		dbSelectArea("SCR")
		dbGoto(val(nReg))  
		IF SCR->CR_STATUS <> '02'
			Return(.F.)
		EndIf
	EndIf
	
	cTpLib	:= If( SCR->CR_XTPLIB == "A", "Aprovação", "Visto" )
	cCodGrp := SCR->CR_APROV
	
	if sMetodo = 'P'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define o status para o bloqueio                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do Case
			Case SCR->CR_STATUS == "01"
				cStatus	:= "Aguardando Outros Níveis"
			Case SCR->CR_STATUS == "02"
				cStatus	:= "Aguardando liberação do Usuário"
			Case SCR->CR_STATUS == "03"
				cStatus	:= "Liberado Pelo Usuário"
			Case SCR->CR_STATUS == "04"
				cStatus	:= "Rejeitado por Usuário"
			Case SCR->CR_STATUS == "05"
				cStatus	:= "Liberado por Outro Usuário"
		OtherWise
			cStatus	:= "A Definir"
		EndCase
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se for opção de liberação só deixa quando status for 02 - aguardando liberação usuário  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpcX == 6 .Or. nOpcX == 7 .Or. nOpcX == 8
			If SCR->CR_STATUS <> "02"
				Aviso(	cCadastro,;
						"Status não permite que seja efetuado a liberação.",;
						{ "&Retorna" },,;
						"Status: " + cStatus )
				Return( .F. )
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no arquivo de pedidos                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SC7" )
	dbSetOrder( 1 )
	MsSeek( xFilial( "SC7" )+ Substr( SCR->CR_NUM, 1, Len( SC7->C7_NUM ) ) )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no arquivo de fornecedores                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SA2" )
	dbSetOrder( 1 )
	MsSeek( xFilial( "SA2" ) + SC7->C7_FORNECE + SC7->C7_LOJA )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no arquivo de grupo de aprovadores                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "PAF" )
	dbSetOrder( 1 )
	MsSeek( xFilial( "PAF" ) + SCR->CR_APROV )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no arquivo de grupo de aprovadores                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQry	:= " SELECT PAG.PAG_VLRINI, PAG.PAG_VLRFIM"
	cQry	+= " FROM " + RetSqlName( "PAG" ) + " PAG (NOLOCK)"
	cQry	+= " WHERE PAG.PAG_FILIAL = '" + xFilial( "PAG" ) + "'"
	cQry	+= " AND PAG.PAG_CODGRP = '" + SCR->CR_APROV + "'"
	cQry	+= " AND PAG.PAG_IDUSER = '" + SCR->CR_USER + "'"
	cQry	+= " AND PAG.D_E_L_E_T_ = ' '"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o alias esta em uso                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Select( "ADOA040A" ) > 0
		dbSelectArea( "ADOA040A" )
		dbCloseArea()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a query                                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TCQUERY cQry NEW ALIAS " ADOA040A"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Obtem os valores iniciais e finais                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "ADOA040A" )
	dbGoTop()
	While !Eof()
		If Empty( nLimMin ) .Or. ( !Empty( nLimMin ) .And. ADOA040A->PAG_VLRINI < nLimMin )
			nLimMin	:= ADOA040A->PAG_VLRINI
		EndIf
		If Empty( nLimMax ) .Or. ( !Empty( nLimMax ) .And. ADOA040A->PAG_VLRFIM > nLimMax )
			nLimMax	:= ADOA040A->PAG_VLRFIM
		EndIf
		dbSkip()
	EndDo
	dbSelectArea( "ADOA040A" )
	dbCloseArea()
	dbSelectArea( "SCR" )
	if sMetodo = 'P' // Aprovação Protheus

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta interface com o usuário                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//DEFINE MSDIALOG oDlg FROM 000,000 TO 335,510 TITLE "Liberação do Pedido de Compra" PIXEL
	DEFINE MSDIALOG oDlg FROM 000,000 TO 435,510 TITLE "Liberação do Pedido de Compra" PIXEL
	
		@ 001,003 TO 044,254 LABEL "" OF oDlg PIXEL
		@ 045,003 TO 150,254 LABEL "" OF oDlg PIXEL
		@ 151,003 TO 195,254 LABEL "" OF oDlg PIXEL // Chamado n. 057440 || OS 058919 || TECNOLOGIA || LUIZ || 8451 || HIST. APROVACAO - FWNM - 04/05/2020
	
		@ 007,140 SAY "Emissão:"							SIZE 050,08 OF oDlg PIXEL
		@ 019,006 SAY "Fornecedor:"							SIZE 050,08 OF oDlg PIXEL
		@ 032,006 SAY "Status:"								SIZE 050,08 OF oDlg PIXEL
		@ 032,140 SAY "Valor Total:"						SIZE 050,08 OF oDlg PIXEL
		@ 006,055 MSGET SCR->CR_NUM	  		WHEN .F.		SIZE 065,08 OF oDlg PIXEL
		@ 006,185 MSGET SCR->CR_EMISSAO		WHEN .F.		SIZE 065,08 OF oDlg PIXEL
		@ 018,055 MSGET SA2->A2_NOME		WHEN .F.		SIZE 195,08 OF oDlg PIXEL
		@ 031,055 MSGET cStatus				WHEN .F.		SIZE 065,08 OF oDlg PIXEL
		@ 031,185 MSGET SCR->CR_TOTAL		PICTURE PesqPict( "SCR", "CR_TOTAL", 14 ) ;
											WHEN .F.		SIZE 065,08 OF oDlg PIXEL
		
		@ 053,006 SAY "Grp.Aprovação:"						SIZE 050,08 OF oDlg PIXEL
		@ 065,006 SAY "C.Custo Pedido:"						SIZE 050,08 OF oDlg PIXEL
		//@ 065,140 SAY "Desc C.Custo:"						SIZE 050,08 OF oDlg PIXEL
		@ 077,006 SAY "It.Contab.Inicial:"					SIZE 050,08 OF oDlg PIXEL
		@ 077,140 SAY "It.Contab.Final:"						SIZE 050,08 OF oDlg PIXEL
		@ 089,006 SAY "Limite Inicial:"						SIZE 050,08 OF oDlg PIXEL
		@ 089,140 SAY "Limite Final:"							SIZE 050,08 OF oDlg PIXEL
		@ 101,006 SAY "Tipo Liberação:"						SIZE 050,08 OF oDlg PIXEL
		@ 101,140 SAY "Data Liberação:"						SIZE 050,08 OF oDlg PIXEL
		@ 113,006 SAY "Observações:"							SIZE 100,08 OF oDlg PIXEL
		@ 125,006 SAY "Novo Aprovador:"						SIZE 050,08 OF oDlg PIXEL
		@ 125,140 SAY "Data Rejeição:"						SIZE 050,08 OF oDlg PIXEL
		
		@ 052,055 MSGET SCR->CR_APROV		WHEN .F.		SIZE 065,008 OF oDlg PIXEL
		@ 052,125 MSGET PAF->PAF_DESCRI		WHEN .F.		SIZE 120,008 OF oDlg PIXEL
		@ 064,055 MSGET SC7->C7_CC			WHEN .F.		SIZE 065,008 OF oDlg PIXEL
		@ 064,125 MSGET Posicione("CTT",1,xFilial("CTT")+SC7->C7_CC,"CTT_DESC01")		WHEN .F.		SIZE 120,008 OF oDlg PIXEL
		@ 076,055 MSGET PAF->PAF_ITINI		WHEN .F.		SIZE 065,008 OF oDlg PIXEL
		@ 076,185 MSGET PAF->PAF_ITFIM		WHEN .F.		SIZE 065,008 OF oDlg PIXEL
		@ 088,055 MSGET nLimMin					PICTURE PesqPict( "PAG", "PAG_VLRINI", 14) ;
														WHEN .F.		SIZE 065,008 OF oDlg PIXEL RIGHT
		@ 088,185 MSGET nLimMax					PICTURE PesqPict( "PAG", "PAG_VLRINI", 14) ;
														WHEN .F.		SIZE 065,008 OF oDlg PIXEL RIGHT
		@ 100,055 MSGET cTpLib					WHEN .F.		SIZE 065,008 OF oDlg PIXEL RIGHT
	
		@ 100,185 MSGET oDatLib VAR dDatLib		WHEN .F. SIZE 065,008 OF oDlg PIXEL CENTERED //CASAROLI
	
		@ 112,055 MSGET oObs VAR cObs			WHEN nOpcX == 6 .Or. nOpcX == 8	SIZE 195,008 OF oDlg PIXEL RIGHT
		@ 124,055 MSGET oNewApr VAR cNewApr	F3 "PAG" VALID( VldUsr( cNewApr ) ) ;
														WHEN nOpcX == 7	SIZE 065,008 OF oDlg PIXEL CENTERED
		@ 124,185 MSGET oDatRej VAR dDatRej		WHEN .F. SIZE 065,008 OF oDlg PIXEL CENTERED
		
		@ 136,006 SAY "Lote Granja:"	         SIZE 050,08 OF oDlg PIXEL
		@ 135,055 MSGET SC7->C7_XLOTECC		WHEN .F. SIZE 065,008 OF oDlg PIXEL
		@ 135,125 MSGET SC7->C7_XDLOTCC		WHEN .F. SIZE 120,008 OF oDlg PIXEL

		// Chamado n. 057440 || OS 058919 || TECNOLOGIA || LUIZ || 8451 || HIST. APROVACAO - FWNM - 04/05/2020

		@ 156,006 SAY "Qtd Aprovações:"	        SIZE 050,08 OF oDlg PIXEL
		@ 155,055 MSGET SC7->C7_XQTDAPR			WHEN .F. SIZE 065,008 OF oDlg PIXEL

		cLegAPP := ""
		If AllTrim(SC7->C7_XLEGAPP) == "1"
			cLegAPP := "1 - Primeira aprovação"
		
		ElseIf AllTrim(SC7->C7_XLEGAPP) == "2"
			cLegAPP := "2 - Alteração sem mudanca de valor"

		ElseIf AllTrim(SC7->C7_XLEGAPP) == "3"
			cLegAPP := "3 - Alteração com mudanca de valor"

		ElseIf AllTrim(SC7->C7_XLEGAPP) == "4"
			cLegAPP := "4 - Substituição PC ( PC original n. " + AllTrim(SC7->C7_XPEDORI) + " )"

		EndIf

		@ 168,006 SAY "Legenda APP:"	        SIZE 050,08 OF oDlg PIXEL
		@ 167,055 MSGET cLegAPP			WHEN .F. SIZE 195,008 OF oDlg PIXEL 

		@ 180,006 SAY "Obs Internas:"	SIZE 050,008 OF oDlg PIXEL
		@ 179,055 MSGET SC7->C7_XOBSINT			WHEN .F. SIZE 195,008 OF oDlg PIXEL
		
		//

		If nOpcX == 6 .Or. nOpcX == 7 .Or. nOpcX == 8
			@ 200,167 BUTTON OemToAnsi("&Confirma")			SIZE 040,011 FONT oDlg:oFont ACTION ( nOpc := 1, oDlg:End() ) OF oDlg PIXEL
		EndIf
		@ 200,212 BUTTON OemToAnsi("&Retorna")			SIZE 040,011 FONT oDlg:oFont ACTION ( nOpc := 0, oDlg:End() ) OF oDlg PIXEL
	
		//Chamado TI - 27/03/2019 - FWNM - Inclusao de historico de aprovacoes - SCR
		@ 200,006 BUTTON OemToAnsi("&Visualiza aprovações anteriores")			SIZE 090,011 FONT oDlg:oFont ACTION ( u_VisualSCR("SC7", SC7->( Recno() ), 2, "PC") ) OF oDlg PIXEL
		//
	
	ACTIVATE MSDIALOG oDlg CENTERED
	EndIf
	IF sMetodo = 'M'  // Aprovação Mobile
		nOpc := 1
		cObs := sObsSCR
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se confirmar o processo efetua as gravações                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 1
		Begin Transaction
			dbSelectArea( "SCR" )
			RecLock( "SCR", .F. )
				If nOpcX == 6
					SCR->CR_STATUS		:= "03"
					SCR->CR_DATALIB		:= MsDate()
					SCR->CR_VALLIB		:= SCR->CR_TOTAL
					SCR->CR_OBS			:= cObs
					SCR->CR_XHORA		:= Substr(cValToChar(Time()),1,8) //Everson - 22/05/2017. Adicionado campo com a hora da liberação do pedido de compra.
					nRecSCR				:= SCR->( RecNo() )
					cChaveSCR			:= SCR->( CR_FILIAL + CR_TIPO + CR_NUM )
					dbSelectArea( "SCR" )
					dbSetOrder( 1 )
					MsSeek( cChaveSCR )
					While !Eof() .And. SCR->( CR_FILIAL + CR_TIPO + CR_NUM ) == cChaveSCR
						If SCR->CR_STATUS == "01"
							RecLock( "SCR", .F. )
								SCR->CR_STATUS	:= "02"
							MsUnLock()
							Exit
						EndIf
						dbSkip()
					EndDo
					dbSelectArea( "SCR" )
					dbGoTo( nRecSCR )
					If SCR->CR_XTPLIB == "A"
						dbSelectArea( "SC7" )
						dbSetorder( 1 )
						MsSeek( xFilial( "SC7" ) + PadR( SCR->CR_NUM, TAMSX3( "C7_NUM" )[1] ) )
						While !Eof() .And. SC7->C7_FILIAL == xFilial( "SC7" ) .And. SC7->C7_NUM == PadR( SCR->CR_NUM, TAMSX3( "C7_NUM" )[1] )
						    
						    //INICIO CHAMADO 033773 - WILLIAM COSTA
						    dbSelectArea("ZBE")
							RecLock("ZBE",.T.)
								Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
								Replace ZBE_DATA 	   	WITH dDataBase
								Replace ZBE_HORA 	   	WITH TIME()
								Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
								Replace ZBE_LOG	        WITH ("ADOA040-1 " + " Filal : " + SC7->C7_FILIAL  + " Pedido de Compra : " + SC7->C7_NUM + " SCR->CR_NUM : " + SCR->CR_NUM + " Campo C7_CONAPRO : "  + SC7->C7_CONAPRO + " Variavel: " + 'L, Metodo de Aprovação: ' + iif(sMetodo = 'M','Mobile','Protheus') )  
								Replace ZBE_MODULO	    WITH "COMPRAS"
								Replace ZBE_ROTINA	    WITH "ADOA040" 
							MsUnlock() 
							ZBE->(dbCloseArea())
							
							dbSelectArea( "SC7" )
							
							//FINAL CHAMADO 033773 - WILLIAM COSTA
							
							RecLock( "SC7", .F. )
								SC7->C7_CONAPRO := "L"
							MsUnLock()

							//INICIO CHAMADO 033773 - WILLIAM COSTA
							dbSelectArea("ZBE")
							RecLock("ZBE",.T.)
								Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
								Replace ZBE_DATA 	   	WITH dDataBase
								Replace ZBE_HORA 	   	WITH TIME()
								Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
								Replace ZBE_LOG	        WITH ("ADOA040-2 " + " Filal : " + SC7->C7_FILIAL  + " Pedido de Compra : " + SC7->C7_NUM + " SCR->CR_NUM : " + SCR->CR_NUM + " Campo C7_CONAPRO : "  + SC7->C7_CONAPRO + " Variavel: " + 'L, Metodo de Aprovação: ' + iif(sMetodo = 'M','Mobile','Protheus'))  
								Replace ZBE_MODULO	    WITH "COMPRAS"
								Replace ZBE_ROTINA	    WITH "ADOA040" 
							MsUnlock() 
							ZBE->(dbCloseArea())
							//FINAL CHAMADO 033773 - WILLIAM COSTA
							
							dbSelectArea( "SC7" )
							
							dbSkip()
						EndDo
					
						// Chamado TI || Desativar envio email devido lentidão - FWNM - 19/12/2019
						/*
						// Chamado n. 053321 || OS 054677 || TECNOLOGIA || LUIZ || 8451 || ENVIAR PEDIDO COMPRA - fwnm - 18/11/2019
						dbSelectArea( "SC7" )
						dbSetorder( 1 )
						If MsSeek( xFilial( "SC7" ) + PadR( SCR->CR_NUM, TAMSX3( "C7_NUM" )[1] ) )

							If AllTrim(SC7->C7_CONAPRO) == "L"
								cMailPC := AllTrim(Posicione("SY1",3,FWxFilial("SY1")+SC7->C7_USER,"Y1_EMAIL")) //UsrRetMail( SC7->C7_USER )
								//cMailCR := UsrRetMail( SCR->CR_USER ) // Chamado n. 051895 || OS 053235 || SUPRIMENTOS || LUIS || 3525 || WORKFLOW PEDIDOS - FWNM - 26/11/2019
								aParamJob := { cEmpAnt, SCR->CR_FILIAL, SCR->CR_NUM, SA2->A2_EMAIL, cMailPC, SCR->CR_TIPO, SC7->(Recno()), sMetodo }
								StartJob("U_ADMATR110", GetEnvServer(), .T., aParamJob)
								//u_ADMATR110(aParamJob) // debug
							EndIf

						EndIf
						//
						*/
						//
					EndIf

					dbSelectArea( "SCR" )			

				ElseIf nOpcX == 7
					SCR->CR_USER		:= cNewApr
					SCR->CR_WF			:= Space( TAMSX3( "CR_WF" )[1] )
					SCR->CR_WFID		:= Space( TAMSX3( "CR_WFID" )[1] )
				ElseIf nOpcX == 8
					SCR->CR_STATUS		:= "04"
					SCR->CR_DATREJ		:= dDatRej
					SCR->CR_WF			:= Space( TAMSX3( "CR_WF" )[1] )
					SCR->CR_OBS			:= cObs
					nRecSCR				:= SCR->( RecNo() )
					cChaveSCR			:= SCR->( CR_FILIAL + CR_TIPO + CR_NUM )
					dbSelectArea( "SCR" )
					dbSetOrder( 1 )
					MsSeek( cChaveSCR )
					While !Eof() .And. SCR->( CR_FILIAL + CR_TIPO + CR_NUM ) == cChaveSCR
						If SCR->CR_STATUS <> "04"
							RecLock( "SCR", .F. )
								SCR->CR_STATUS	:= "04"
							MsUnLock()
						EndIf
						dbSkip()
					EndDo
					dbSelectArea( "SCR" )
					dbGoTo( nRecSCR )
					dbSelectArea( "SC7" )
					dbSetorder( 1 )
					MsSeek( xFilial( "SC7" ) + PadR( SCR->CR_NUM, TAMSX3( "C7_NUM" )[1] ) )
					While !Eof() .And. SC7->C7_FILIAL == xFilial( "SC7" ) .And. SC7->C7_NUM == PadR( SCR->CR_NUM, TAMSX3( "C7_NUM" )[1] )
					    
					    //INICIO CHAMADO 033773 - WILLIAM COSTA
						dbSelectArea("ZBE")
						RecLock("ZBE",.T.)
							Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
							Replace ZBE_DATA 	   	WITH dDataBase
							Replace ZBE_HORA 	   	WITH TIME()
							Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
							Replace ZBE_LOG	        WITH ("ADOA040-3 " + " Filal : " + SC7->C7_FILIAL  + " Pedido de Compra : " + SC7->C7_NUM + " SCR->CR_NUM : " + SCR->CR_NUM + " Campo C7_CONAPRO : "  + SC7->C7_CONAPRO + " Variavel: " + 'R, Metodo de Reprovação: ' + iif(sMetodo = 'M','Mobile','Protheus'))  
							Replace ZBE_MODULO	    WITH "COMPRAS"
							Replace ZBE_ROTINA	    WITH "ADOA040" 
						MsUnlock() 
						ZBE->(dbCloseArea())
						
						dbSelectArea( "SC7" )
						
						//FINAL CHAMADO 033773 - WILLIAM COSTA
					
						RecLock( "SC7", .F. )
							SC7->C7_CONAPRO := "R"
						MsUnLock()
						
						//INICIO CHAMADO 033773 - WILLIAM COSTA
						dbSelectArea("ZBE")
						RecLock("ZBE",.T.)
							Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
							Replace ZBE_DATA 	   	WITH dDataBase
							Replace ZBE_HORA 	   	WITH TIME()
							Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
							Replace ZBE_LOG	        WITH ("ADOA040-4 " + " Filal : " + SC7->C7_FILIAL  + " Pedido de Compra : " + SC7->C7_NUM + " SCR->CR_NUM : " + SCR->CR_NUM + " Campo C7_CONAPRO : "  + SC7->C7_CONAPRO + " Variavel: " + 'R, Metodo de Reprovação: ' + iif(sMetodo = 'M','Mobile','Protheus') )  
							Replace ZBE_MODULO	    WITH "COMPRAS"
							Replace ZBE_ROTINA	    WITH "ADOA040" 
						MsUnlock() 
						ZBE->(dbCloseArea())
						
						dbSelectArea( "SC7" )
						
						//FINAL CHAMADO 033773 - WILLIAM COSTA
						
						dbSkip()
					EndDo
					dbSelectArea( "SCR" )
				EndIf
			MsUnLock()
		End Transaction
	EndIf
	
	if sMetodo = 'M'
		Return(.T.)
	EndIf

Return( Nil )

/*/{Protheus.doc} Static Function VLDUSR
	Valida digitacao usuario
	@type  Function
	@author Almir Bandina
	@since 03/05/2008
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function VldUsr( cNewApr )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define as variáveis da rotina                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local lRetorno	:= .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida se o id informado existe no cadastro de usuário                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRetorno	:= UsrExist( cNewApr )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida se o id informado é o mesmo do atual                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno
		If SCR->CR_USER == cNewApr
			Aviso(	cCadastro,;
					"Novo aprovador é igual ao atual. Transferência não permitida.",;
					{ "&Retorna" },,;
					"Aprovador Atual: " + SCR->CR_USER )
			lRetorno	:= .F.
		EndIf
	EndIf

Return( lRetorno )

/*/{Protheus.doc} User Function ADO04LEG
	Legenda
	@type  Function
	@author Almir Bandina
	@since 03/05/2008
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function Ado04Leg()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define as legandas para a rotina                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	U_ADINF009P('ADOA040' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	/*
		Local aCores 	:= {	{ "C7_XLEGAPP == '1'", "BR_VERDE"		},;  // Primeira aprovação
							{ "C7_XLEGAPP == '2'", "BR_AMARELO"	    },;  // Alteração sem mudanca de valor
							{ "C7_XLEGAPP == '3'", "BR_VERMELHO"	},;  // Alteração com mudanca de valor
							{ "C7_XLEGAPP == '4'", "BR_VERMELHO"	} ;  // Substituição PC
							}

	*/

	// Chamado n. 057440 || OS 058919 || TECNOLOGIA || LUIZ || 8451 || HIST. APROVACAO - FWNM - 04/05/2020
	
	BrwLegenda("Legenda", cCadastro,{	{ "BR_AZUL", 		"Aguardando Outros Níveis"	},;
				 									{ "BR_VERMELHO",	"Aguardando liberação do Usuário" },;
													{ "BR_VERDE",		"Liberado Pelo Usuário" },;
													{ "BR_PRETO",		"Bloqueado Pelo Usuário" },;
													{ "BR_CINZA",		"Liberado por Outro Usuário" } ;
													} )

	/*
	BrwLegenda("Legenda", cCadastro,{	{ "BR_VERDE"   , "Primeira aprovação"			  },;
				 						{ "BR_AMARELO" , "Alteração sem mudanca de valor" },;
										{ "BR_VERMELHO", "Alteração com mudanca de valor" },;
										{ "BR_VERMELHO", "Substituição PC" 				  } ;
																						  } )
	*/

Return( Nil )

/*/{Protheus.doc} Static Function MENUDEF
	Menu
	@type  Function
	@author Almir Bandina
	@since 03/05/2008
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function MenuDef()

	Private aRotina	:= {}     
	
	If( AllTrim( cVersao ) ) == "P10"
		aRotina		:= {	{ "Pesquisar",		"PesqBrw()",										0, 1, 0, Nil },;
							{ "vis.Pedido",		"U_Ado04VPC('SCR', SCR->( Recno() ), 2)",	0, 2, 0, Nil },;
							{ "Vis.liberação",	"U_Ado04LIB('SCR', SCR->( Recno() ), 2 , 'P')",	0, 2, 0, Nil },;
							{ "liBeração",			"U_Ado04LIB('SCR', SCR->( Recno() ), 6 , 'P')",	0, 6, 0, Nil },;
							{ "Transfere",			"U_Ado04LIB('SCR', SCR->( Recno() ), 7 , 'P')",	0, 6, 0, Nil },;
							{ "Rejeita",			"U_Ado04LIB('SCR', SCR->( Recno() ), 8 , 'P')",	0, 6, 0, Nil },;
							{ "Legenda",			"U_Ado04LEG()",									0, 6, 0, Nil } }
	Else
		aRotina		:= {	{ "Pesquisar",		"AxPesqui()",							 			0, 1 },;
							{ "vis.Pedido",		"U_Ado04VPC('SCR', SCR->( Recno() ), 2)",	0, 2 },;
							{ "Vis.liberação",	"U_Ado04LIB('SCR', SCR->( Recno() ), 2 , 'P')",	0, 3 },;
							{ "liBeração",			"U_Ado04LIB('SCR', SCR->( Recno() ), 6 , 'P')",	0, 5 },;
							{ "Transfere",			"U_Ado04LIB('SCR', SCR->( Recno() ), 7 , 'P')",	0, 4 },;
							{ "Rejeita",			"U_Ado04LIB('SCR', SCR->( Recno() ), 8 , 'P')",	0, 4 },;
							{ "Legenda",			"U_Ado04LEG()",							 		0, 6 } }
	EndIf

Return( aRotina )

/*/{Protheus.doc} Static Function CRIASX1
	Cria grupo perguntas
	@type  Function
	@author Almir Bandina
	@since 03/05/2008
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function CriaSX1( cPerg )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define as variáveis da rotina                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aAreaAtu	:= GetArea()
	Local aAreaSX1	:= SX1->( GetArea() )
	Local aTamSX3	:= {}
	Local aHelp		:= {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define os títulos e Help das perguntas                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//												  						"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
	aAdd(aHelp,{	"Somente os Bloqueados",	"",	"", {	"Informe Sim caso deseja trazer na tela  ",	"apenas os registros com bloqueio ou não ",	"para todos.                             " },	{""},	{""} } )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava as perguntas no arquivo SX1                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//		cGrupo	cOrde	cDesPor			cDesSpa			cDesEng			cVar		cTipo		cTamanho	cDecimal	nPreSel	cGSC	cValid	cF3			cGrpSXG	cPyme	cVar01		cDef1Por		cDef1Spa	cDef1Eng	cCnt01	  					cDef2Por	cDef2Spa	cDef2Eng	cDef3Por	cDef3Spa	cDef3Eng	cDef4Por		cDef4Spa	cDef4Eng	cDef5Por	cDef5Spa	cDef5Eng	aHelpPor		aHelpEng		aHelpSpa		cHelp)
	PutSx1(	cPerg,	"01",	aHelp[01,1],	aHelp[01,2],	aHelp[01,3],	"mv_ch1",	"N",		1,			0,			2,		"C",	"",		"",			"",		"N",	"mv_par01",	"Sim",			"Si",		"Yes",		"",							"Não",		"No",		"No",		"",			"",			"",			"",				"",			"",			"",			"",			"",			aHelp[01,4],	aHelp[01,5],	aHelp[01,6],	"" )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva as áreas originais                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestArea( aAreaSX1 )
	RestArea( aAreaAtu )

Return( Nil )

/*/{Protheus.doc} User Function VisualSCR
	Visualiza alcada
	@type  Function
	@author Almir Bandina
	@since 03/05/2008
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function VisualSCR( cAlias, nReg, nOpcx, cTipoDoc )

	Local aArea		:= GetArea()
	Local cHelpApv  := OemToAnsi("Este documento nao possui controle de aprovacao.")
	Local cAliasSCR := "TMP"
	Local cComprador:= ""
	Local cSituaca  := ""
	Local cNumDoc   := ""
	Local cStatus   := ""
	Local cTitle    := ""
	Local cTitDoc   := ""
	Local cAddHeader:= ""
	Local lBloq     := .F.
	Local nUsado	:= 0
	Local nX   		:= 0
	Local nY        := 0
	Local oDlg
	Local oGet
	Local oBold
	Local cQuery   := ""
	Local aStruSCR := {}
	
	U_ADINF009P('ADOA040' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	DEFAULT cTipoDoc := "PC"
	
	IF cTipoDoc == "PC" .Or. cTipoDoc == "AE"
		cTitle    := OemToAnsi("Histórico Aprovações")
		cTitDoc   := OemToAnsi("Pedido")
		cHelpApv  := OemToAnsi("Este pedido nao possui controle de aprovacao." )
		cNumDoc   := SC7->C7_NUM
		cComprador:= UsrRetName(SC7->C7_USER)
		cStatus   := OemToAnsi( "PEDIDO LIBERADO" )
	EndIf
	
	If !Empty(cNumDoc)
		
		aHeader:= {}
		aCols  := {}
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem do aHeader com os campos fixos.               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX3")
		dbSetOrder(1)
		MsSeek("SCR")
		While !Eof() .And. (SX3->X3_ARQUIVO == "SCR")
			IF AllTrim(X3_CAMPO)$"CR_NIVEL/CR_OBS/CR_DATALIB/CR_DATREJ" + cAddHeader
				nUsado++
				AADD(aHeader,{	TRIM(X3Titulo()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT } )
				
				If AllTrim(x3_campo) == "CR_NIVEL"
					nUsado++
					AADD(aHeader,{ OemToAnsi( "Usuário" ),"bCR_NOME",   "",15,0,"","","C","",""} )
					nUsado++
					AADD(aHeader,{ OemToAnsi( "Situação" ),"bCR_SITUACA","",20,0,"","","C","",""} )
					nUsado++
					AADD(aHeader,{ OemToAnsi( "Tp.Aprovação" ),"bCR_TPAPROV","",15,0,"","","C","",""} )
				EndIf
				
			Endif
			
			dbSelectArea("SX3")
			dbSkip()
		EndDo
		
		#IFDEF TOP
			
			IF cTipoDoc == "PC" .Or. cTipoDoc == "AE"
				
				aStruSCR := SCR->(dbStruct())
				cTipoDoc := "PC"
				cAliasSCR := GetNextAlias()
				cQuery    := "SELECT * FROM "+RetSqlName("SCR")+" SCR "
				cQuery    += "WHERE SCR.CR_FILIAL='"+xFilial("SCR")+"' AND "
				cQuery    += "SCR.CR_NUM = '"+Padr(SC7->C7_NUM,Len(SCR->CR_NUM))+"' AND "
				cQuery    += "SCR.CR_TIPO = 'PC' AND "
				cQuery    += "( SCR.CR_DATALIB<>' ' OR SCR.CR_DATREJ<>'') AND "
				cQuery    += "SCR.CR_USER='"+RetCodUsr()+"' AND "
				cQuery    += "SCR.D_E_L_E_T_='*' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCR)
				
				If (cAliasSCR)->(Eof())
					(cAliasSCR)->(dbCloseArea())
					cTipoDoc  := "AE"
					cAliasSCR := GetNextAlias()
					cQuery    := "SELECT * FROM "+RetSqlName("SCR")+" SCR "
					cQuery    += "WHERE SCR.CR_FILIAL='"+xFilial("SCR")+"' AND "
					cQuery    += "SCR.CR_NUM = '"+Padr(SC7->C7_NUM,Len(SCR->CR_NUM))+"' AND "
					cQuery    += "SCR.CR_TIPO = 'AE' AND "
					cQuery    += "( SCR.CR_DATALIB<>' ' OR SCR.CR_DATREJ<>'') AND "
					cQuery    += "SCR.CR_USER='"+RetCodUsr()+"' AND "
					cQuery    += "SCR.D_E_L_E_T_='*' "
					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCR)
				EndIf
				
			EndIf
			
			For nX := 1 To Len(aStruSCR)
				If aStruSCR[nX][2]<>"C"
					TcSetField(cAliasSCR,aStruSCR[nX][1],aStruSCR[nX][2],aStruSCR[nX][3],aStruSCR[nX][4])
				EndIf
			Next nX
		#ENDIF
		
		dbSelectArea(cAliasSCR)
		
		While !Eof() .And.(cAliasSCR)->CR_FILIAL+(cAliasSCR)->CR_TIPO+Substr((cAliasSCR)->CR_NUM,1,;
			len(IIF(cTipoDoc == "PC" .Or. cTipoDoc == "AE",SC7->C7_NUM ,IIF(cTipoDoc == "CP",SC3->C3_NUM,SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA )))) ;
			== xFilial("SCR") + cTipoDoc + cNumDoc
			
			aadd(aCols,Array(nUsado+1))
			nY++
			For nX := 1 to Len(aHeader)
				If aHeader[nX][02] == "bCR_NOME"
					aCols[nY][nX] := UsrRetName((cAliasSCR)->CR_USER)
				ElseIf aHeader[nX][02] == "bCR_SITUACA"
					Do Case
						Case (cAliasSCR)->CR_STATUS == "01"
							cSituaca := OemToAnsi("Aguardando")
						Case (cAliasSCR)->CR_STATUS == "02"
							cSituaca := OemToAnsi("Em Aprovacao")
						Case (cAliasSCR)->CR_STATUS == "03"
							cSituaca := IIF(cTipoDoc == "PC" .Or. cTipoDoc == "AE",OemToAnsi("Aprovado"),IIF(cTipoDoc == "CP",OemToAnsi("Aprovado"),OemToAnsi("Aprovado")))
						Case (cAliasSCR)->CR_STATUS == "04"
							cSituaca := IIF(cTipoDoc == "PC" .Or. cTipoDoc == "AE",OemToAnsi("Rejeitado"),IIF(cTipoDoc == "CP",OemToAnsi("Rejeitado"),OemToAnsi("Rejeitado")))
							lBloq := .T.
						Case (cAliasSCR)->CR_STATUS == "05"
							cSituaca := OemToAnsi("Nivel Liberado ")
					EndCase
					aCols[nY][nX] := cSituaca
				ElseIf aHeader[nX][02] == "bCR_TPAPROV"
					aCols[nY][nX] := If( (cAliasSCR)->CR_XTPLIB == "V", "Vistador", "Aprovador" )
				ElseIf ( aHeader[nX][10] != "V")
					aCols[nY][nX] := FieldGet(FieldPos(aHeader[nX][2]))
				EndIf
			Next nX
			aCols[nY][nUsado+1] := .F.
			dbSkip()
		EndDo
		
		If !Empty(aCols)
			If lBloq
				cStatus := IIF(cTipoDoc == "PC" .Or. cTipoDoc == "AE",OemToAnsi("REJEITADO"),IIF(cTipoDoc == "CP",OemToAnsi("REJEITADO"),OemToAnsi("REJEITADO")))
			EndIf
			DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
			DEFINE MSDIALOG oDlg TITLE cTitle From 109,095 To 400,600 OF oMainWnd PIXEL	 //"Aprovacao do Pedido de Compra // Contrato"
			@ 005,003 TO 032,250 LABEL "" OF oDlg PIXEL
			@ 015,007 SAY cTitDoc OF oDlg FONT oBold PIXEL SIZE 046,009 // "Pedido" / "Contrato" / "Nota Fiscal"
			@ 014,041 MSGET cNumDoc PICTURE "" WHEN .F. PIXEL SIZE 050,009 OF oDlg FONT oBold
			If cTipoDoc <> "NF"
				@ 015,103 SAY OemToAnsi("Comprador") OF oDlg PIXEL SIZE 033,009 FONT oBold
				@ 014,138 MSGET cComprador PICTURE "" WHEN .F. of oDlg PIXEL SIZE 103,009 FONT oBold
			EndIF
			/*
			@ 132,008 SAY 'Situacao :' OF oDlg PIXEL SIZE 052,009
			If lBloq
				@ 132,038 SAY cStatus OF oDlg PIXEL SIZE 120,009 FONT oBold COLOR CLR_HRED
			Else
				@ 132,038 SAY cStatus OF oDlg PIXEL SIZE 120,009 FONT oBold COLOR CLR_HBLUE
			EndIf
			*/
			@ 132,210 BUTTON 'Fechar' SIZE 035 ,010  FONT oDlg:oFont ACTION (oDlg:End()) OF oDlg PIXEL
			oGet:= MSGetDados():New(038,003,120,250,nOpcx,,,"")
			oGet:Refresh()
			@ 126,002 TO 127,250 LABEL "" OF oDlg PIXEL
			ACTIVATE MSDIALOG oDlg CENTERED
		Else
			Aviso("Atencao",cHelpApv,{"Voltar"}) //###"Este pedido nao possui controle de aprovacao."###
		EndIf
		
		dbSelectArea(cAliasSCR)
		dbCloseArea()
	Else
		Aviso("Atencao",cHelpApv,{"Voltar"}) //###"Este Documento nao possui controle de aprovacao."###
	EndIf
	
	dbSelectArea(cAlias)
	RestArea(aArea)

Return

/*/{Protheus.doc} User Function APPDesc
	Usado no campo virtual CR_XLEGDES - Inic Browse
	@type  Function
	@author FWNM
	@since 07/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function APPDesc()

	Local cRet := ""

	/*
	Local aCores 	:= {	{ "CR_XLEGAPP == '1'", "BR_VERDE"		},;  // Primeira aprovação
							{ "CR_XLEGAPP == '2'", "BR_AMARELO"		},;  // Alteração sem mudanca de valor
							{ "CR_XLEGAPP == '3'", "BR_VERMELHO"	},;  // Alteração com mudanca de valor
							{ "CR_XLEGAPP == '4'", "BR_VERMELHO"	} ;  // Substituição PC
							}
	*/

	If SCR->CR_XLEGAPP == "1"
		cRet := "Primeira aprovacao"

	ElseIf SCR->CR_XLEGAPP == "2"
		cRet := "Alteracao sem mudanca de valor"

	ElseIf SCR->CR_XLEGAPP == "3"
		cRet := "Alteracao com mudanca de valor"

	ElseIf SCR->CR_XLEGAPP == "4"
		cRet := "Substituicao PC"

	EndIf
	
Return cRet