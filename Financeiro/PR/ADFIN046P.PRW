#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "RwMake.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} User Function ADFIN046P
	Central de Aprovacao
	@type  Function
	@author Ricardo Lima
	@since 14/11/2017
	@version 01
	@history Chamado 038609
	@history Chamado 042937 - Ricardo Lima  - 03/08/2018 - aprovação do bloqueio manual de contas a pagar
	@history Chamado 046284 - FWNM          - 07/01/2019 - Recusa do projeto mudara fase para 01 = Projeto em atualizacao
	@history Chamado 044314 - Everson       - 18/03/2019 - Aprovacao de Fretes (tabela ZFA)
	@history Chamado 044314 - Everson       - 19/03/2019 - Aprovacao de Fretes pelo APP (tabela ZFA)
	@history Chamado 044314 - Everson       - 28/03/2019 - Aprovacao de Fretes pelo APP (tabela ZFA e ZFF)
	@history Chamado 047440 - FWNM          - 23/04/2019 - Alcada aprovacao projetos investimentos (Vistador/Aprovador)
	@history Chamado TI     - FWNM          - 14/05/2019 - Adaptacao para aprovadores quando rejeitado
	@history Chamado 049774 - FWNM          - 25/06/2019 - OS 051078 || ENGENHARIA || SILVANA || PROJETO ENCERRADO
	@history Chamado 052008 - Abel Filho    - 27/09/2019 - OS 053342 || FINANCAS || LUIZ || 8451 || CENTRAL DE APROVACAO
	@history Chamado 053243 - FWNM          - 08/11/2019 - OS 054600 || CONTROLADORIA || DAIANE || WOKFLOW PROJETOS
	@history Chamado 053839 - FWNM          - 06/12/2019 - 053839 || OS 055224 || CONTROLADORIA || DAIANE || (16) || REDUCAO VLR PRJ
	@history Chamado 053347 - FWNM          - 29/11/2019 - 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL
	@history Chamado 029058 - Everson       - 12/12/2019 - Adicionado tratamento para aprovação de fretes de frango vivo.
	@history Chamado 054538 - FWNM          - 15/01/2020 - OS 055940 || FINANCAS || EDUARDO || 8352 || CENTRAL DE APROVACAO
	@history Chamado 055321 - FWNM          - 05/02/2020 - OS 056879 || FINANCAS || EDUARDO || 8352 || APROVADOR AUSENTE
	@history Chamado 058216 - FWNM          - 15/05/2020 - OS 059676 || FINANCAS || LUIZ || 8451 || CONTAS APAGAR
	@history Chamado 058197 - WILLIAM COSTA - 27/05/2020 - Adicionado regra para Aprovação de Títulos Bloqueados no Contas a Pagar
	@history Chamado 058487 - WILLIAM COSTA - 05/06/2020 - Adicionado tecla de atalho C ou R nos botões de aprovação e Reprovar
	@history Chamado 1997   - Everson       - 21/09/2020 - Tratamento de erro reprovação pelo app.
	@history Ticket  429    - Abel Babini   - 09/10/2020 - Tratamento de bloqueios Painel de pagamento
	@history Ticket  429    - Abel Babini   - 30/10/2020 - Correção na liberação de bloqueios Painel de pagamento
	@history Ticket  429    - Abel Babini   - 09/11/2020 - Aumento da exibição do campo
	@history Ticket 4883    - Abel Babini   - 15/12/2020 - Unificação das tabelas da Central de Aprovação (ZG5 para ZCF)
	@history Ticket 11556   - Fernando Maci - 27/04/2021 - Processo Trabalhista - Títulos
	@history Ticket 15609   - Abel Babini   - 15/06/2021 - Ajuste na validação de datas de vencimento
/*/
User Function ADFIN046P()

	Private cBlqRC1   := GetMV("MV_#ZC7RC1",,"000013") // @history Ticket 11556   - Fernando Maci - 27/04/2021 - Processo Trabalhista - Títulos

	Private oBrowse
	Private cUsrPApr := .F.
	Private cFilTp   := ""
	Private cFilPrj  := ""

	Private nLimMin := 0
	Private nLimMax := 0
	Private nDiasAnt := 0
	Private nDiasPos := 0
	Private nPercJur := 0
	Private nPercAcs := 0
	Private nPercDes := 0
	Private nPercDcs := 0
	private nNivelA  := ""
	Private cTpLimite := ""
	Private cTpLimal := ""
	PRIVATE aRotina
	// Ricardo Lima - 23/03/18
	Private nValApr  := 0
	Private nLimGer  := 0
	Private cAprVcPa := "" // Ricardo Lima - 27/03/18

	Private nValALApr  := 0
	Private nLimAL := 0

	Private nValNSApr  := 0
	Private nLimNS := 0
	Private cTpLimNS := "M"
	Private nLiMinNS := 0
	Private nLiMaxNS := 0
	Private nNVLimNS := "00"
	Private lEnvWFCA := SuperGetMv( "MV_#FA5ENV" , .F. , .T. ,  )
	// Ricardo Lima-14/12/18|CH:044314
	Private nLimOper := 0
	Private nAprFrt  := 0
	
	//Ch. 052008 | 27/09/2019 - Abel Babini Filho | Verifica aprovadores ausentes
	Private lAprAus		:= .F. 
	Private nAprAus		:= 0

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Central Aprovação')
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZC7")
	oBrowse:SetDescription("Central de Aprovação")

	//Definição da legenda
	oBrowse:AddLegend("ZC7_TPBLQ = '000001'", "BR_VERDE"   , "Bloqueio Limite Crédito PA")
	oBrowse:AddLegend("ZC7_TPBLQ = '000003'", "BR_LARANJA" , "Projetos de Investimentos")
	oBrowse:AddLegend("ZC7_TPBLQ = '000004'", "BR_AZUL"    , "Bloqueio Alçada Financeira")
	oBrowse:AddLegend("ZC7_TPBLQ = '000005'", "BR_AMARELO" , "Bloqueio Nivel de Segurança")
	oBrowse:AddLegend("ZC7_TPBLQ = '000006'", "BR_PINK"    , "Bloqueio de Frete Abatido") // Ricardo Lima-29/11/18| Aprovação de Fretes Abatido

	//Everson - 12/12/2019 - Chamado 029058.
	oBrowse:AddLegend("ZC7_TPBLQ = '000007'", "BR_VERDE_ESCURO" , "Bloqueio de Frete FV")       //Frete Frango Vivo.
	oBrowse:AddLegend("ZC7_TPBLQ = '000008'", "BR_CINZA"   		, "Bloqueio de Frete Ovo")      //Frete Ovo.
	oBrowse:AddLegend("ZC7_TPBLQ = '000009'", "BR_MARROM"  		, "Bloqueio de Frete Pintinho") //Frete Pintinho.
	oBrowse:AddLegend("ZC7_TPBLQ = '000010'", "BR_VIOLETA" 		, "Bloqueio de Frete Ração")    //Frete Ração.
	//
 	oBrowse:AddLegend("ZC7_TPBLQ = '000011'", "BR_VERMELHO" 		, "Desbloqueio de Titulos") //Desbloqueio de Titulos.

	//INICIO Ticket  429    - Abel Babini   - 09/10/2020 - Tratamento de bloqueios Painel de pagamento
 	oBrowse:AddLegend("ZC7_TPBLQ = '000020'", "BR_AZUL_CLARO" 		, "Bloqueio Painel de Pagamentos") //Bloqueio Painel de Pagamentos
 	
	oBrowse:AddLegend("ZC7_TPBLQ = '"+cBlqRC1+"'", "BR_PRETO" 		, "Bloqueio Acordo Trabalhista") // @history Ticket 11556   - Fernando Maci - 27/04/2021 - Processo Trabalhista - Títulos
	 
	 // oBrowse:AddLegend("ZC7_TPBLQ = '000012'", "BR_PRETO" 			, "Desbloqueio de Titulos") //Desbloqueio de Titulos.
 	// oBrowse:AddLegend("ZC7_TPBLQ = '000012'", "BR_PRETO_0" 		, "Desbloqueio de Titulos") //Desbloqueio de Titulos.
 	// oBrowse:AddLegend("ZC7_TPBLQ = '000012'", "BR_PRETO_1" 		, "Desbloqueio de Titulos") //Desbloqueio de Titulos.
 	// oBrowse:AddLegend("ZC7_TPBLQ = '000012'", "BR_PRETO_3" 		, "Desbloqueio de Titulos") //Desbloqueio de Titulos.
 	// oBrowse:AddLegend("ZC7_TPBLQ = '000012'", "BR_CANCEL" 		, "Desbloqueio de Titulos") //Desbloqueio de Titulos.
 	// oBrowse:AddLegend("ZC7_TPBLQ = '000012'", "BR_MARROM_OCEAN","Desbloqueio de Titulos") //Desbloqueio de Titulos.
	// oBrowse:AddLegend("ZC7_TPBLQ = '000012'", "BR_BRANCO" , "Desbloqueio de Titulos") //Desbloqueio de Titulos.
	
	//FIM Ticket  429    - Abel Babini   - 09/10/2020 - Tratamento de bloqueios Painel de pagamento

	// Ricardo Lima - 05/03/18
	u_ATUFIL()

	aRotina	:= AdMenuDef()

	// Ricardo Lima - 04/01/18
	if nNivelA = "01"
		//oBrowse:SetFilterDefault( " ( Empty(ZC7_USRAPR) .AND. ZC7_TPBLQ $ '"+cFilTp+"'  .AND. Empty(ZC7_NIVEL) .AND. ZC7_FILIAL='"+FwxFilial("ZC7") +"' ) .OR. ZC7_PROJET $  '"+cFilPrj+"' " )
		oBrowse:SetFilterDefault( " ( Empty(ZC7_USRAPR) .AND. ZC7_TPBLQ $ '"+cFilTp+"'  .AND. Empty(ZC7_NIVEL) ) .OR. ZC7_PROJET $  '"+cFilPrj+"' " ) // Chamado n. 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL - fwnm - 02/12/2019
	else
		//oBrowse:SetFilterDefault( " ( Empty(ZC7_USRAPR) .AND. ZC7_TPBLQ $ '"+cFilTp+"' .AND. ZC7_NIVEL <= nNivelA .AND. ZC7_FILIAL='"+ FwxFilial("ZC7") +"' ) .OR. ZC7_PROJET $ '"+cFilPrj+"' .AND. Empty(ZC7_USRAPR) .AND. Empty(ZC7_REPROV) " ) // FWNM - Chamado n. 046284
		// Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS
				
		//Ch. 052008 | 27/09/2019 - Abel Babini Filho | Verifica aprovadores ausentes
		IF lAprAus
			//oBrowse:SetFilterDefault( " ( Empty(ZC7_USRAPR) .AND. ZC7_TPBLQ $ '"+cFilTp+"' .AND. (ZC7_NIVEL >= '"+IIF(STRZERO(vAL(nNivelA)-1,2)="01","  ",STRZERO(vAL(nNivelA)-1,2))+"' .AND. ZC7_NIVEL <= '"+nNivelA+"' .AND. ZC7_NIVEL <= '"+nNivelA+"' ).AND. ZC7_FILIAL='"+ FwxFilial("ZC7") +"' ) .OR. ( ZC7_PROJET $ '"+cFilPrj+"' .AND. ZC7_USRAPR = '"+__cUserID+"' .AND. Empty(ZC7_DTAPR) .AND. Empty(ZC7_REPROV) ) " )
			oBrowse:SetFilterDefault( " ( Empty(ZC7_USRAPR) .AND. ZC7_TPBLQ $ '"+cFilTp+"' .AND. (ZC7_NIVEL >= '"+IIF(STRZERO(vAL(nNivelA)-1,2)="01","  ",STRZERO(vAL(nNivelA)-1,2))+"' .AND. ZC7_NIVEL <= '"+nNivelA+"' .AND. ZC7_NIVEL <= '"+nNivelA+"' ) ) .OR. ( ZC7_PROJET $ '"+cFilPrj+"' .AND. ZC7_USRAPR = '"+__cUserID+"' .AND. Empty(ZC7_DTAPR) .AND. Empty(ZC7_REPROV) ) " ) // Chamado n. 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL - fwnm - 02/12/2019
			
		ELSE
			//Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
			//Os usuários desejam aprovar apenas o que faz parte do próprio nível, por isso a linha foi comentada
			//oBrowse:SetFilterDefault( " ( Empty(ZC7_USRAPR) .AND. ZC7_TPBLQ $ '"+cFilTp+"' .AND. ZC7_NIVEL == '"+nNivelA+"' .AND. ZC7_FILIAL='"+ FwxFilial("ZC7") +"' ) .OR. ( ZC7_PROJET $ '"+cFilPrj+"' .AND. ZC7_USRAPR = '"+__cUserID+"' .AND. Empty(ZC7_DTAPR) .AND. Empty(ZC7_REPROV) ) " )
			oBrowse:SetFilterDefault( " ( Empty(ZC7_USRAPR) .AND. ZC7_TPBLQ $ '"+cFilTp+"' .AND. ZC7_NIVEL == '"+nNivelA+"' ) .OR. ( ZC7_PROJET $ '"+cFilPrj+"' .AND. ZC7_USRAPR = '"+__cUserID+"' .AND. Empty(ZC7_DTAPR) .AND. Empty(ZC7_REPROV) ) " )  // Chamado n. 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL - fwnm - 02/12/2019
		ENDIF
	endif

	oBrowse:Activate()

Return NIL

/*{Protheus.doc} Static Function ADMENUDEF
	Central Aprovacao Menu
	@type  Function
	@author Ricardo Lima
	@since 14/11/2017
	@version 01
	@history Chamado 038609
*/

STATIC Function AdMenuDef()

	aRotina  := {}

	ADD OPTION aRotina TITLE "Visualizar" ACTION "U_ADFINA46('V')" OPERATION 2 ACCESS 0
	if cUsrPApr
		ADD OPTION aRotina TITLE "Aprovação"                        ACTION "U_ADFINA46('A')" OPERATION 2 ACCESS 0
		ADD OPTION aRotina TITLE "Consulta Aprovações PA"           ACTION "ApMsgInfo('Valor das Aprovações: '+Transform(nValApr,X3Picture('E2_SALDO'))+chr(13)+chr(10)+'Limite para Aprovações: '+Transform(nLimGer,X3Picture('E2_SALDO'))+chr(13)+chr(10)+chr(13)+chr(10)+'Saldo para Aprovação: '+Transform(nLimGer-nValApr,X3Picture('E2_SALDO')) , 'Limites PA')" OPERATION 3 ACCESS 0
		ADD OPTION aRotina TITLE "Consulta Aprovações Alçadas"      ACTION "ApMsgInfo('Valor das Aprovações: '+Transform(nValALApr,X3Picture('E2_SALDO'))+chr(13)+chr(10)+'Limite para Aprovações: '+Transform(nLimAL,X3Picture('E2_SALDO'))+chr(13)+chr(10)+chr(13)+chr(10)+'Saldo para Aprovação: '+Transform(nLimAL-nValALApr,X3Picture('E2_SALDO')) , 'Limites Alçadas')" OPERATION 3 ACCESS 0
		ADD OPTION aRotina TITLE "Consulta Aprovações Nivel Segur." ACTION "ApMsgInfo('Valor das Aprovações: '+Transform(nValNSApr,X3Picture('E2_SALDO'))+chr(13)+chr(10)+'Limite para Aprovações: '+Transform(nLimNS,X3Picture('E2_SALDO'))+chr(13)+chr(10)+chr(13)+chr(10)+'Saldo para Aprovação: '+Transform(nLimNS-nValNSApr,X3Picture('E2_SALDO')) , 'Limites Nivel de Segurança')" OPERATION 3 ACCESS 0
		ADD OPTION aRotina TITLE "Consulta Aprovações Frete"        ACTION "ApMsgInfo('Valor das Aprovações: '+Transform(nAprFrt,X3Picture('E2_SALDO'))+chr(13)+chr(10)+'Limite para Aprovações: '+Transform(nLimOper,X3Picture('E2_SALDO'))+chr(13)+chr(10)+chr(13)+chr(10)+'Saldo para Aprovação: '+Transform(nLimOper-nAprFrt,X3Picture('E2_SALDO')) , 'Limites Fretes')" OPERATION 3 ACCESS 0	
	endif
	ADD OPTION aRotina TITLE "Legenda"    ACTION "U_ADFIN46L()"     OPERATION 9 ACCESS 0

Return aRotina

/*/{Protheus.doc} Static Function ATUFIL
	Central Aprovacao Atualizacao
	@type  Function
	@author Ricardo Lima
	@since 14/11/2017
	@version 01
	@history Chamado 038609
/*/
USER FUNCTION ATUFIL

	Local cQuery  := ""
	// Ricardo Lima - 23/03/18
	Local cQry := ""
	Local cAno := ALLTRIM(STR(YEAR(Date())))
	Local cMes := StrZero( MONTH(DATE()) , 2 )
	Local cDia := StrZero(DAY(DATE()), 2 ) //048042 // Alteracao para levar dois digitos no dia
	Local lAprProj := .F. // Ricardo Lima - 16/04/18
	
	Local lVistador := .t. // Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 29/04/2019

	U_ADINF009P('ADFIN046P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Central Aprovação')

	DbSelectArea("ZCF")
	DbSetOrder(2) //ZCF_FILIAL, ZCF_APROVA
	if DbSeek( FwxFilial("ZCF") + __cUserID )
		nNivelA := ZCF->ZCF_NIVEL
	endif

	IF SELECT("ADFIN146P") > 0
		ADFIN146P->( DBCLOSEAREA() )
	ENDIF

	cQuery := " SELECT ZC3A.*, "
	cQuery += " (SELECT COUNT(*) FROM "+ RetSqlName("ZC3") +" ZC3B WHERE ZC3B.D_E_L_E_T_ = '' AND ZC3B.ZC3_CODUSU <> '"+__cUserID+"' AND ZC3B.ZC3_NIVSEG <> '' AND ZC3B.ZC3_NIVSEG = (ZC3A.ZC3_NIVSEG-1) AND ZC3B.ZC3_APRATV <> '1') AS QTD_APRO " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Verifica aprovadores ausentes
	cQuery += " FROM "+ RetSqlName("ZC3") +" ZC3A (NOLOCK) "
	cQuery += " WHERE ZC3A.ZC3_CODUSU = '"+__cUserID+"' "
	cQuery += " AND ZC3A.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY ZC3A.ZC3_CODUSU "
	//cQuery := ChangeQuery(cQuery)

	TCQUERY cQuery new alias "ADFIN146P"

	DbSelectArea("ADFIN146P")

	while ADFIN146P->( !EOF() )
		cUsrPApr := .T.
		
		//Ch. 052008 | 27/09/2019 - Abel Babini Filho | Verifica aprovadores ausentes
		nAprAus	:= ADFIN146P->QTD_APRO
		If nAprAus = 0
			lAprAus	:= .T.
		endif
		
		IF !EMPTY( ADFIN146P->ZC3_TABALC )
			IF !ADFIN146P->ZC3_TABALC $ cFilTp
				cFilTp += ADFIN146P->ZC3_TABALC + "|"
			ENDIF
		ENDIF
		IF !EMPTY( ADFIN146P->ZC3_TABBLF )
			IF !ADFIN146P->ZC3_TABBLF $ cFilTp
				cFilTp += ADFIN146P->ZC3_TABBLF + "|"
			ENDIF
		ENDIF
		IF !EMPTY( ADFIN146P->ZC3_TABPAF )
			IF !ADFIN146P->ZC3_TABPAF $ cFilTp
				cFilTp += ADFIN146P->ZC3_TABPAF + "|"
			ENDIF
		ENDIF
		IF !EMPTY( ADFIN146P->ZC3_TABCRT )
			IF !ADFIN146P->ZC3_TABCRT $ cFilTp
				cFilTp += ADFIN146P->ZC3_TABCRT + "|"
			ENDIF
		ENDIF
		// Ricardo Lima-14/12/18|CH:044314| Aprovação de Fretes
		IF !EMPTY( ADFIN146P->ZC3_APRASC )
			IF !ADFIN146P->ZC3_APRASC $ cFilTp
				cFilTp += ADFIN146P->ZC3_APRASC + "|"
			ENDIF
		ENDIF

		IF ADFIN146P->ZC3_APDESB == 'S'
			IF !ADFIN146P->ZC3_TABDES $ cFilTp
				cFilTp += ADFIN146P->ZC3_TABDES + "|"
			ENDIF
		ENDIF

		//INICIO Ticket 4883    - Abel Babini   - 15/12/2020 - Unificação das tabelas da Central de Aprovação (ZG5 para ZCF)
		//INICIO Ticket  429    - Abel Babini   - 09/10/2020 - Tratamento de bloqueios Painel de pagamento
		/*
			NOVAS REGRAS DE BLOQUEIO DEVEM SER ACRESCENTADAS NA TABELA SX5->Z9 E RELACIOADAS COM OS APROVADORES (ZC3) NA TABELA ZCF
			AS REGRAS CRIADAS SERÃO ADICIONADAS NO FILTRO NAS LINHAS ABAIXO:
			ADFIN099P APROVADORES X REGRAS - CENTRAL DE APROVAÇÃO
		*/
		cAlsZCF := GetNextAlias()
		cQryZCF := " SELECT ZCF.ZCF_CODIGO "
		cQryZCF += " FROM " + RetSqlName("ZCF") + " ZCF "
		cQryZCF += " WHERE ZCF_FILIAL = '"+ xFilial("ZCF") +"' AND ZCF_APROVA = '"+ __cUserID +"' AND ZCF.D_E_L_E_T_ = '' AND ZCF_CODIGO BETWEEN '000020' AND '000030' "
		DbUseArea(.t., "TOPCONN", TcGenQry(,, cQryZCF), cAlsZCF, .F., .T.)

		While !(cAlsZCF)->(eof())
			cFilTp += (cAlsZCF)->ZCF_CODIGO + "|"
			(cAlsZCF)->(dbSkip())
		EndDo
		(cAlsZCF)->(DBCLOSEAREA())
		//FIM Ticket  429    - Abel Babini   - 09/10/2020 - Tratamento de bloqueios Painel de pagamento
		//FIM Ticket 4883    - Abel Babini   - 15/12/2020 - Unificação das tabelas da Central de Aprovação (ZG5 para ZCF)

		// @history Ticket 11556   - Fernando Maci - 27/04/2021 - Processo Trabalhista - Títulos
		cAlsZCF := GetNextAlias()

		cQryZCF := " SELECT ZCF.ZCF_CODIGO
		cQryZCF += " FROM " + RetSqlName("ZCF") + " ZCF (NOLOCK)
		cQryZCF += " WHERE ZCF_FILIAL = '"+ FWxFilial("ZCF") +"' AND ZCF_APROVA = '"+ __cUserID +"'
		//cQryZCF += " AND ZCF_CODIGO = '"+cBlqRC1+"'
		cQryZCF += " AND ZCF_CODIGO = '000013'
		cQryZCF += " AND ZCF.D_E_L_E_T_ = ''
		
		dbUseArea(.t., "TOPCONN", TcGenQry(,, cQryZCF), cAlsZCF, .F., .T.)

		Do While (cAlsZCF)->( !EOF() )
			cFilTp += (cAlsZCF)->ZCF_CODIGO + "|"
			(cAlsZCF)->( dbSkip() )
		EndDo
		
		(cAlsZCF)->( dbCloseArea() )
		//
		
		If !EMPTY( ADFIN146P->ZC3_TABPRJ )
			lAprProj := .T. // Ricardo Lima - 16/04/18
		Endif

		nLimGer := ADFIN146P->ZC3_OPERLI
		cTpLimite := ADFIN146P->ZC3_TPLIM
		cAprVcPa := ADFIN146P->ZC3_APALVC // Ricardo Lima - 27/03/18

		cTpLimal  := ADFIN146P->ZC3_TLMALC
		nLimAL    := ADFIN146P->ZC3_LIMALC
		// Ricardo Lima-14/12/18|CH:044314
		nLimOper  := ADFIN146P->ZC3_LIMASC

		IF !Empty(ADFIN146P->ZC3_NIVSEG)
			dbSelectArea("ZCK")
			dbSetOrder(1)
			if dbSeek( FWxFilial("ZCK") + ADFIN146P->ZC3_NIVSEG )
				cTpLimNS := ZCK->ZCK_TPLIM
				nLimNS   := ZCK->ZCK_LIMAPR
			endif
		endif

		ADFIN146P->(DbSkip())
	end

	// Ricardo Lima - 04/01/18
	IF lAprProj  // Ricardo Lima - 16/04/18

		// Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 29/04/2019
		// Define Aprovador / Vistador
		lVistador := .t.
		ZCX->( dbSetOrder(1) ) // ZCX_FILIAL + ZCX_USER + ZCX_CODIGO
		If ZCX->( dbSeek( FWxFilial("ZCX")+__cUserID ) )
			lVistador := .f.
		EndIf
		//
		
		IF SELECT("ADFIN046P") > 0
			ADFIN046P->( DBCLOSEAREA() )
		ENDIF

		// Ricardo Lima - 04/09/18 | ajuste na query de filtro de projetos
		cQuery := " SELECT * "
		cQuery += " FROM "+ RetSqlName("ZC7") +" ZC7 "
		cQuery += " INNER JOIN "+ RetSqlName("AF8") +" AF8 ON AF8_PROJET=ZC7_PROJET AND AF8_REVISA=ZC7_REVPRJ AND AF8.D_E_L_E_T_ = ' ' "
	
	    // Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 29/04/2019
		cQuery += " WHERE ZC7_TPBLQ = '000003' AND ZC7_DTAPR = ' ' AND ZC7_REPROV = ' ' AND ZC7_USRAPR = '"+ __cUserID +"' AND ZC7.D_E_L_E_T_ = ' ' "
		//cQuery += " WHERE ZC7_TPBLQ = '000003' AND ZC7_USRAPR = ' ' AND AF8_XCODAP = '"+ __cUserID +"' AND ZC7.D_E_L_E_T_ = ' ' " // Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS
	
		TCQUERY cQuery new alias "ADFIN046P"

		WHILE ADFIN046P->( !EOF() )
			
			// Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 29/04/2019
			If lVistador
				cFilPrj += ADFIN046P->ZC7_PROJET + "|"

			Else

				lOk := .f.
				
				If Select("Work") > 0
					Work->( dbCloseArea() )
				EndIf
				
				cQuery := " SELECT ZC7_REPROV, ZC7_DTAPR, ZC7_HRAPR "
				cQuery += " FROM " + RetSqlName("ZC7") + " ZC7 (NOLOCK) "
				cQuery += " WHERE ZC7_FILIAL='"+FWxFilial("ZC7")+"' "
				cQuery += " AND ZC7_PROJET='"+ADFIN046P->ZC7_PROJET+"' "
				cQuery += " AND ZC7_REVPRJ='"+ADFIN046P->ZC7_REVPRJ+"' "
				cQuery += " AND ZC7_USRAPR<>'"+__cUserID+"' "
				cQuery += " AND D_E_L_E_T_='' "
				cQuery += " ORDER BY 1 DESC "
				
				tcQuery cquery new alias "Work"
				
				Work->( dbGoTop() )
				Do While Work->( !EOF() )
					If !Empty(Work->ZC7_DTAPR) .and. !Empty(Work->ZC7_HRAPR)
						If Empty(Work->ZC7_REPROV)
							lOk := .t.
						Else
							lOk := .f.
							Exit
						EndIf
					EndIf
					
					Work->( dbSkip() )
				EndDo
				
				If lOk
					cFilPrj += ADFIN046P->ZC7_PROJET + "|"
				EndIf
				
				If Select("Work") > 0
					Work->( dbCloseArea() )
				EndIf

			EndIf
			//

			ADFIN046P->( DbSkip() )
		END
	
	ENDIF
	
	// Ricardo Lima - 23/03/18
	IF SELECT("ADFIN46Q") > 0
		ADFIN46Q->( DBCLOSEAREA() )
	ENDIF

	cQry := " SELECT ZC7_FILIAL, SUM( ZC7_VLRBLQ + ZC7_VLRJUR + ZC7_DECRES + ZC7_ACRESC + ZC7_CNABDE + ZC7_CNABAC ) VLR_APR "
	cQry += " FROM "+ RetSqlName("ZC7") +" ZC7 "
	cQry += " WHERE ZC7_USRAPR = '"+ __cUserID +"' "
	IF cTpLimite = 'M'
		cQry += " AND ZC7_DTAPR BETWEEN '"+cAno+cMes+"01' AND '"+cAno+cMes+"31' "
	ELSE
		cQry += " AND ZC7_DTAPR BETWEEN '"+cAno+cMes+cDia+"' AND '"+cAno+cMes+cDia+"' "
	ENDIF
	cQry += " AND ZC7_EFEAPR = 'S' "
	cQry += " AND ZC7_TPBLQ = '000001' "
	cQry += " AND ZC7.D_E_L_E_T_ = ' ' "
	cQry += " GROUP BY ZC7_FILIAL "
	TCQUERY cQry new alias "ADFIN46Q"
	nValApr := ADFIN46Q->VLR_APR

	IF SELECT("ADFIN46Q") > 0
		ADFIN46Q->( DBCLOSEAREA() )
	ENDIF

	cQry := " SELECT ZC7_FILIAL, SUM( ZC7_CUSFIN + ZC7_VLRJUR + ZC7_DECRES + ZC7_ACRESC + ZC7_CNABDE + ZC7_CNABAC ) VLR_APR "
	cQry += " FROM "+ RetSqlName("ZC7") +" ZC7 "
	cQry += " WHERE ZC7_USRAPR = '"+ __cUserID +"' "
	IF cTpLimal = 'M'
		cQry += " AND ZC7_DTAPR BETWEEN '"+cAno+cMes+"01' AND '"+cAno+cMes+"31' "
	ELSE
		cQry += " AND ZC7_DTAPR BETWEEN '"+cAno+cMes+cDia+"' AND '"+cAno+cMes+cDia+"' "
	ENDIF
	cQry += " AND ZC7_EFEAPR = 'S' "
	//cQry += " AND ZC7_TPBLQ = '000004' "
	cQry += " AND ZC7_TPBLQ IN ('000004','000011') " 
	cQry += " AND ZC7.D_E_L_E_T_ = ' ' "
	cQry += " GROUP BY ZC7_FILIAL "
	TCQUERY cQry new alias "ADFIN46Q"
	nValALApr := ADFIN46Q->VLR_APR

	IF SELECT("ADFIN46Q") > 0
		ADFIN46Q->( DBCLOSEAREA() )
	ENDIF

	cQry := " SELECT ZC7_FILIAL, SUM( ZC7_CUSFIN + ZC7_VLRJUR + ZC7_DECRES + ZC7_ACRESC + ZC7_CNABDE + ZC7_CNABAC ) VLR_APR "
	cQry += " FROM "+ RetSqlName("ZC7") +" ZC7 "
	cQry += " WHERE ZC7_USRAPR = '"+ __cUserID +"' "
	IF cTpLimNS = 'M'
		cQry += " AND ZC7_DTAPR BETWEEN '"+cAno+cMes+"01' AND '"+cAno+cMes+"31' "
	ELSE
		cQry += " AND ZC7_DTAPR BETWEEN '"+cAno+cMes+cDia+"' AND '"+cAno+cMes+cDia+"' "
	ENDIF
	cQry += " AND ZC7_EFEAPR = 'S' "
	cQry += " AND ZC7_TPBLQ = '000005' "
	cQry += " AND ZC7.D_E_L_E_T_ = ' ' "
	cQry += " GROUP BY ZC7_FILIAL "
	TCQUERY cQry new alias "ADFIN46Q"
	nValNSApr := ADFIN46Q->VLR_APR

	// Ricardo Lima-14/12/18|CH:044314
	IF SELECT("ADFIN46Q") > 0
		ADFIN46Q->( DBCLOSEAREA() )
	ENDIF
	cQry := " SELECT ZC7_FILIAL, SUM( ZC7_VLRBLQ ) VLR_APR "
	cQry += " FROM "+ RetSqlName("ZC7") +" ZC7 "
	cQry += " WHERE ZC7_USRAPR = '"+ __cUserID +"' "
	IF cTpLimNS = 'M'
		cQry += " AND ZC7_DTAPR BETWEEN '"+cAno+cMes+"01' AND '"+cAno+cMes+"31' "
	ELSE
		cQry += " AND ZC7_DTAPR BETWEEN '"+cAno+cMes+cDia+"' AND '"+cAno+cMes+cDia+"' "
	ENDIF
	cQry += " AND ZC7_EFEAPR = 'S' "
	cQry += " AND ZC7_TPBLQ IN ('000006','000007','000008','000009','000010') " //Everson - 12/12/2019 - Chamado 029058.
	cQry += " AND ZC7.D_E_L_E_T_ = ' ' "
	cQry += " GROUP BY ZC7_FILIAL "
	TCQUERY cQry new alias "ADFIN46Q"
	nAprFrt := ADFIN46Q->VLR_APR

	// Ricardo Lima - 04/01/18
	cFilTp  := substr( Alltrim(cFilTp)  , 1 , len(Alltrim(cFilTp))  -1 )
	cFilPrj := substr( Alltrim(cFilPrj) , 1 , len(Alltrim(cFilPrj)) -1 )

RETURN

/*{Protheus.doc} Static Function ModelDef
	Central Aprovacao Menu
	@type  Function
	@author Ricardo Lima
	@since 14/11/2017
	@version 01
	@history Chamado 038609
*/

STATIC Function ModelDef()

	LOCAL oModel
	LOCAL oStruZC7 := FWFormStruct( 1, "ZC7", /*bAvalCaMPFormModeliewUsado*/ )

	oModel :=MPFormModell():New('ModelDef_MVC', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:SetDescription("Central de Aprovação")
	oModel:AddFields("ZC7MASTER", /*cOwner*/, oStruZC7, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetPrimaryKey( {"ZC7_FILIAL" } )

Return oModel

/*{Protheus.doc} Static Function VIEWDEF
	Central Aprovacao
	@type  Function
	@author Ricardo Lima
	@since 14/11/2017
	@version 01
	@history Chamado 038609
*/

STATIC Function ViewDef()

	Local oView
	Local oModel	:= ModelDef()
	Local oStruZC7	:= FWFormStruct( 2, "ZC7" )

	oView := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField("VIEW_ZC7", oStruZC7, "ZC7MASTER" )
	oView:CreateHorizontalBox("TELA" , 100 )
	oView:EnableTitleView("VIEW_ZC7" , "Central de Aprovação" )

Return oView

/*{Protheus.doc} User Function ADFIN46L
	Central Aprovacao 
	@type  Function
	@author Ricardo Lima
	@since 14/11/2017
	@version 01
	@history Chamado 038609
*/

User Function ADFIN46L()

	Local aLegenda := {}

	U_ADINF009P('ADFIN046P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Central Aprovação')

	aAdd( aLegenda, { "BR_VERDE"   , "Bloqueio Limite - PA" })
	aAdd( aLegenda, { "BR_AZUL"    , "Bloqueio Alçada Financeira" })
	aAdd( aLegenda, { "BR_LARANJA" , "Projetos de Investimentos"})
	aAdd( aLegenda, { "BR_AMARELO" , "Bloqueio Nivel de Segurança"})
	aAdd( aLegenda, { "BR_PINK"    , "Bloqueio de Frete"}) // Ricardo Lima-14/12/18|CH:044314| Aprovação de Fretes

	//Everson - 12/12/2019 - Chamado 029058.
	aAdd( aLegenda, { "BR_VERDE_ESCURO" , "Bloqueio de Frete FV"})       //Frete Frango Vivo.
	aAdd( aLegenda, { "BR_CINZA"   		, "Bloqueio de Frete Ovo"})      //Frete Ovo.
	aAdd( aLegenda, { "BR_MARROM"  		, "Bloqueio de Frete Pintinho"}) //Frete Pintinho.
	aAdd( aLegenda, { "BR_VIOLETA" 		, "Bloqueio de Frete Ração"})    //Frete Ração.
	//

	aAdd( aLegenda, { "BR_VERMELHO" 	, "Desbloqueio de Titulos"})    //Frete Ração.
	
	//INICIO Ticket  429    - Abel Babini   - 09/10/2020 - Tratamento de bloqueios Painel de pagamento
	aAdd( aLegenda, { "BR_AZUL_CLARO" 	, "Bloqueio Painel de Pagamentos"})    //Frete Ração.

	BrwLegenda( "Central de Aprovação", "Legenda", aLegenda )

Return Nil

/*{Protheus.doc} User Function ADFINA46
	Central Aprovacao Menu
	@type  Function
	@author Ricardo Lima
	@since 14/11/2017
	@version 01
	@history Chamado 038609
*/

User Function ADFINA46(nOpc)

	Local aArea:= GetArea()

	PRIVATE sTpApr   := ZC7->ZC7_TPBLQ
	PRIVATE cFilZC7  := ZC7->ZC7_FILIAL
	PRIVATE cCodigo  := ZC7->ZC7_PREFIX
	PRIVATE cEspec   := ""
	PRIVATE nNumTit	 := ZC7->ZC7_NUM
	PRIVATE nParctit := ZC7->ZC7_PARCEL
	PRIVATE nTipTit  := ZC7->ZC7_TIPO
	PRIVATE cCodCli	 := ZC7->ZC7_CLIFOR
	PRIVATE cLojCli  := ZC7->ZC7_LOJA
	PRIVATE cNomCli	 := SPACE( 50 )
	Private cRazao   := Space(TamSX3("A2_NOME")[1]) // Chamado n. 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL - FWNM - 29/11/2019
	PRIVATE cDscSet  := ZC7->ZC7_VLRBLQ
	PRIVATE cDscObs	 := ZC7->ZC7_OBS
	
	//Ticket  429    - Abel Babini   - 09/10/2020 - Tratamento de bloqueios Painel de pagamento
	PRIVATE cMsgSol  := ZC7->ZC7_MSGSOL

	PRIVATE nPerCus  := ALLTRIM(ZC7->ZC7_PERCUS) + '%'
	PRIVATE nNumCal  := ZC7->ZC7_NUMCAL
	PRIVATE nCusEfet := ZC7->ZC7_CUSFIN
	PRIVATE cMesRef	 := SPACE( 30 )
	PRIVATE dApuDe	 := dDataBase
	PRIVATE dApuAte	 := dDataBase

	PRIVATE cNomeUsr	:= SPACE( 15 )
	PRIVATE dDataApr	:= SPACE( 10 )
	PRIVATE tHoraApr	:= SPACE( 08 )
	PRIVATE cMOTORI		:= SPACE( 50 )
	PRIVATE cPLCAVA		:= SPACE( 07 )
	PRIVATE cPLCARR		:= SPACE( 07 )
	PRIVATE cVOLUME		:= SPACE( 30 )
	PRIVATE cNFABAT		:= SPACE( 09 )
	PRIVATE cSRABAT		:= SPACE( 03 )
	PRIVATE cUsrApr		:= SPACE( 06 )

	PRIVATE aCpoBro		:= {}

	Private cCodPrj     := ZC7->ZC7_PROJET
	Private cRevPrj     := ZC7->ZC7_REVPRJ
	Private cNomPrj     := Space( 90 )

	Private TpRecPag    := ZC7->ZC7_RECPAG
	Private cTpAprPA := IIF('Integração SAG' $ Alltrim(ZC7->ZC7_DSCBLQ),.T.,.F.) // Ricardo Lima - 13/03/18
	Private cPAvcALTSAG := IIF( EMPTY(ZC7->ZC7_ODTVEN) , .F. , .T. ) // Ricardo Lima - 28/03/18
	Private cTpAprCF := IIF('Vencimento' $ Alltrim(ZC7->ZC7_DSCBLQ),.T.,.F.) // Ricardo Lima - 18/04/18

	// Ricardo Lima - 06/04/18
	Private MsgCrtPt := ""
	Private cDscTpBlq := ZC7->ZC7_DSCBLQ

	Private lTitPA := Iif( ZC7->ZC7_TPBLQ = '000001',.T.,.F.)
	Private lTpBlNs := .F. // Ricardo Lima - 13/12/18

	U_ADINF009P('ADFIN046P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Central Aprovação')

	IF nOpc = 'V'
		cUsrPApr := .F.
	ELSEIF nOpc = 'A'
		cUsrPApr := .T.

		DbSelectArea("ZC3")
		DbSetorder(1)
		if DbSeek( FwxFilial("ZC3") + __cUserID )
			// LIMITES DO APROVADOR
			nLimMin := ZC3->ZC3_LIMMIN
			nLimMax := ZC3->ZC3_LIMMAX
			nLimGer := ZC3->ZC3_OPERLI // Ricardo Lima - 23/03/18
			nDiasAnt := ZC3->ZC3_NUMDTA
			nDiasPos := ZC3->ZC3_NUMDTP
			nPercJur := ZC3->ZC3_PERJUR
			nPercAcs := ZC3->ZC3_PERACR
			nPercDes := ZC3->ZC3_PERDES
			nPercDcs := ZC3->ZC3_PERDEC
			cAprVcPa := ZC3->ZC3_APALVC // Ricardo Lima - 27/03/18
			// Ricardo Lima-14/12/18|CH:044314
			nLimOper := ZC3->ZC3_LIMASC

			nLimAL := ZC3->ZC3_LIMALC

			IF !Empty(ZC3->ZC3_NIVSEG)
				dbSelectArea("ZCK")
				dbSetOrder(1)
				if dbSeek( FWxFilial("ZCK") + ZC3->ZC3_NIVSEG )
					nLimNS   := ZCK->ZCK_LIMAPR
					nLiMinNS := ZCK->ZCK_LIMMIN
					nLiMaxNS := ZCK->ZCK_LIMMAX
					nNVLimNS := ZCK->ZCK_NIVSEG
				endif
			endif
		endif
	ENDIF

	// Integracao Projetos Investimentos - FWNM em 08/12/2017
	If Empty(cCodPrj)
		// Ricardo Lima - 13/12/2018
		if sTpApr = '000001' .OR. (Alltrim(sTpApr) $'000006/000007/000008/000009/000010')  // Ricardo Lima-14/12/18|CH:044314| Aprovação de Fretes //Everson - 12/12/2019 - Chamado 029058.
			aCpoBro		:= { {"ZC7_PREFIX"	, , "Prefixo"		           , " "   }, ;
			{"ZC7_NUM" 	, , "Numero Titulo"		       , " "   }, ;
			{"ZC7_PARCEL"	, , "Parcela"	               , " "   }, ;
			{"ZC7_CLIFOR"	, , "Cliente|Fornecedor"       , " "   }, ;
			{"ZC7_LOJA"	, , "Loja"			           , " "   }, ;
			{"ZC7_VLRBLQ"	, , "Valor Bloqueado"	       , "@E 999,999,999.99" },;
			{"ZC7_TPBLQ"	, , "Tipo Bloqueio"            , " "   }, ;
			{"ZC7_DSCBLQ"	, , "Desc. Bloqueio"           , " "   }, ;
			{"ZC7_USRAPR"	, , "Codigo Aprovador"         , " "   }, ;
			{"ZC7_NOMAPR"	, , "Nome Aprovador"           , " "   }, ;
			{"ZC7_DTAPR"	, , "Data Aprovação"           , " "   }, ;
			{"ZC7_HRAPR"	, , "Hora Aprovação"           , " "   }, ;
			{"ZC7_OBS"  	, , "Observação"               , " "   } }
		elseif sTpApr = '000004'
			if 'APROVADOR DESBLOQUEIO DE TITULOS PAGAR - BLOQUEADO' $ cDscTpBlq
				aCpoBro		:= { {"ZC7_PREFIX"	, , "Prefixo"		           , " "   }, ;
				{"ZC7_NUM" 	    , , "Numero Titulo"		       , " "   }, ;
				{"ZC7_PARCEL"	, , "Parcela"	               , " "   }, ;
				{"ZC7_CLIFOR"	, , "Cliente|Fornecedor"       , " "   }, ;
				{"ZC7_LOJA"	    , , "Loja"			           , " "   }, ;
				{"ZC7_VLRBLQ"	, , "Valor Bloqueado"	       , "@E 999,999,999.99" },;
				{"ZC7_TPBLQ"	, , "Tipo Bloqueio"            , " "   }, ;
				{"ZC7_DSCBLQ"	, , "Desc. Bloqueio"           , " "   }, ;
				{"ZC7_USRAPR"	, , "Codigo Aprovador"         , " "   }, ;
				{"ZC7_NOMAPR"	, , "Nome Aprovador"           , " "   }, ;
				{"ZC7_DTAPR"	, , "Data Aprovação"           , " "   }, ;
				{"ZC7_HRAPR"	, , "Hora Aprovação"           , " "   }, ;
				{"ZC7_OBS"  	, , "Observação"               , " "   } }
			Elseif 'Dt Vencimento' $ cDscTpBlq
				aCpoBro		:= { {"ZC7_PREFIX"	, , "Prefixo"		           , " "   }, ;
				{"ZC7_NUM" 	, , "Numero Titulo"		       , " "   }, ;
				{"ZC7_PARCEL"	, , "Parcela"	               , " "   }, ;
				{"ZC7_CLIFOR"	, , "Cliente|Fornecedor"       , " "   }, ;
				{"ZC7_LOJA"	, , "Loja"			           , " "   }, ;
				{"ZC7_VLRBLQ"	, , "Valor"         	       , "@E 999,999,999.99" },;
				{"ZC7_TPBLQ"	, , "Tipo Bloqueio"            , " "   }, ;
				{"ZC7_DSCBLQ"	, , "Desc. Bloqueio"           , " "   }, ;
				{"ZC7_NDTVEN"	, , "Vencimento Bloqueado"     , " "   }, ;
				{"ZC7_NDTVCR"	, , "Vencto Real Bloqueado"    , " "   }, ;
				{"ZC7_ODTVEN"	, , "Vencimento Original"      , " "   }, ;
				{"ZC7_ODTVCR"	, , "Vencto Real Original"     , " "   } ,;
				{"ZC7_USRAPR"	, , "Codigo Aprovador"         , " "   }, ;
				{"ZC7_NOMAPR"	, , "Nome Aprovador"           , " "   }, ;
				{"ZC7_DTAPR"	, , "Data Aprovação"           , " "   }, ;
				{"ZC7_HRAPR"	, , "Hora Aprovação"           , " "   }, ;
				{"ZC7_OBS"  	, , "Observação"               , " "   } }
			Elseif 'Juros' $ cDscTpBlq
				aCpoBro		:= { {"ZC7_PREFIX"	, , "Prefixo"		           , " "   }, ;
				{"ZC7_NUM" 	, , "Numero Titulo"		       , " "   }, ;
				{"ZC7_PARCEL"	, , "Parcela"	               , " "   }, ;
				{"ZC7_CLIFOR"	, , "Cliente|Fornecedor"       , " "   }, ;
				{"ZC7_LOJA"	, , "Loja"			           , " "   }, ;
				{"ZC7_VLRBLQ"	, , "Valor"         	       , "@E 999,999,999.99" },;
				{"ZC7_TPBLQ"	, , "Tipo Bloqueio"            , " "   }, ;
				{"ZC7_DSCBLQ"	, , "Desc. Bloqueio"           , " "   }, ;
				{"ZC7_VLRJUR"	, , "Juros Bloqueado"          , "@E 999,999,999.99" }, ;
				{"ZC7_USRAPR"	, , "Codigo Aprovador"         , " "   }, ;
				{"ZC7_NOMAPR"	, , "Nome Aprovador"           , " "   }, ;
				{"ZC7_DTAPR"	, , "Data Aprovação"           , " "   }, ;
				{"ZC7_HRAPR"	, , "Hora Aprovação"           , " "   }, ;
				{"ZC7_OBS"  	, , "Observação"               , " "   } }
			Elseif 'Acrescimo' $ cDscTpBlq
				aCpoBro		:= { {"ZC7_PREFIX"	, , "Prefixo"		           , " "   }, ;
				{"ZC7_NUM" 	, , "Numero Titulo"		       , " "   }, ;
				{"ZC7_PARCEL"	, , "Parcela"	               , " "   }, ;
				{"ZC7_CLIFOR"	, , "Cliente|Fornecedor"       , " "   }, ;
				{"ZC7_LOJA"	, , "Loja"			           , " "   }, ;
				{"ZC7_VLRBLQ"	, , "Valor"         	       , "@E 999,999,999.99" },;
				{"ZC7_TPBLQ"	, , "Tipo Bloqueio"            , " "   }, ;
				{"ZC7_DSCBLQ"	, , "Desc. Bloqueio"           , " "   }, ;
				{"ZC7_ACRESC"	, , "Acrescimo Bloqueado"      , "@E 999,999,999.99" }, ;
				{"ZC7_USRAPR"	, , "Codigo Aprovador"         , " "   }, ;
				{"ZC7_NOMAPR"	, , "Nome Aprovador"           , " "   }, ;
				{"ZC7_DTAPR"	, , "Data Aprovação"           , " "   }, ;
				{"ZC7_HRAPR"	, , "Hora Aprovação"           , " "   }, ;
				{"ZC7_OBS"  	, , "Observação"               , " "   } }
			Elseif 'Descrescimo' $ cDscTpBlq
				aCpoBro		:= { {"ZC7_PREFIX"	, , "Prefixo"		           , " "   }, ;
				{"ZC7_NUM" 	, , "Numero Titulo"		       , " "   }, ;
				{"ZC7_PARCEL"	, , "Parcela"	               , " "   }, ;
				{"ZC7_CLIFOR"	, , "Cliente|Fornecedor"       , " "   }, ;
				{"ZC7_LOJA"	, , "Loja"			           , " "   }, ;
				{"ZC7_VLRBLQ"	, , "Valor"         	       , "@E 999,999,999.99" },;
				{"ZC7_TPBLQ"	, , "Tipo Bloqueio"            , " "   }, ;
				{"ZC7_DSCBLQ"	, , "Desc. Bloqueio"           , " "   }, ;
				{"ZC7_DECRES"	, , "Decrescimo Bloqueado"     , "@E 999,999,999.99" }, ;
				{"ZC7_USRAPR"	, , "Codigo Aprovador"         , " "   }, ;
				{"ZC7_NOMAPR"	, , "Nome Aprovador"           , " "   }, ;
				{"ZC7_DTAPR"	, , "Data Aprovação"           , " "   }, ;
				{"ZC7_HRAPR"	, , "Hora Aprovação"           , " "   }, ;
				{"ZC7_OBS"  	, , "Observação"               , " "   } }
			Elseif 'Desconto' $ cDscTpBlq
				aCpoBro		:= { {"ZC7_PREFIX"	, , "Prefixo"		           , " "   }, ;
				{"ZC7_NUM" 	, , "Numero Titulo"		       , " "   }, ;
				{"ZC7_PARCEL"	, , "Parcela"	               , " "   }, ;
				{"ZC7_CLIFOR"	, , "Cliente|Fornecedor"       , " "   }, ;
				{"ZC7_LOJA"	, , "Loja"			           , " "   }, ;
				{"ZC7_VLRBLQ"	, , "Valor"         	       , "@E 999,999,999.99" },;
				{"ZC7_TPBLQ"	, , "Tipo Bloqueio"            , " "   }, ;
				{"ZC7_DSCBLQ"	, , "Desc. Bloqueio"           , " "   }, ;
				{"ZC7_CNABDE"	, , "Desconto Bloqueado"       , "@E 999,999,999.99" }, ;
				{"ZC7_USRAPR"	, , "Codigo Aprovador"         , " "   }, ;
				{"ZC7_NOMAPR"	, , "Nome Aprovador"           , " "   }, ;
				{"ZC7_DTAPR"	, , "Data Aprovação"           , " "   }, ;
				{"ZC7_HRAPR"	, , "Hora Aprovação"           , " "   }, ;
				{"ZC7_OBS"  	, , "Observação"               , " "   } }
			Else
				aCpoBro		:= { {"ZC7_PREFIX"	, , "Prefixo"		           , " "   }, ;
				{"ZC7_NUM" 	, , "Numero Titulo"		       , " "   }, ;
				{"ZC7_PARCEL"	, , "Parcela"	               , " "   }, ;
				{"ZC7_CLIFOR"	, , "Cliente|Fornecedor"       , " "   }, ;
				{"ZC7_LOJA"	, , "Loja"			           , " "   }, ;
				{"ZC7_VLRBLQ"	, , "Valor Bloqueado"	       , "@E 999,999,999.99" },;
				{"ZC7_TPBLQ"	, , "Tipo Bloqueio"            , " "   }, ;
				{"ZC7_DSCBLQ"	, , "Desc. Bloqueio"           , " "   }, ;
				{"ZC7_ACRESC"	, , "Acrescimo Bloqueado"      , "@E 999,999,999.99" }, ;
				{"ZC7_CNABAC"	, , "Acrescimo Cnab Bloqueado" , "@E 999,999,999.99" }, ;
				{"ZC7_CNABDE"	, , "Desconto Bloqueado"       , "@E 999,999,999.99" }, ;
				{"ZC7_DECRES"	, , "Decrescimo Bloqueado"     , "@E 999,999,999.99" }, ;
				{"ZC7_VLRJUR"	, , "Juros Bloqueado"          , "@E 999,999,999.99" }, ;
				{"ZC7_CUSFIN"	, , "Custo Financeiro"         , "@E 999,999,999.99" }, ;
				{"ZC7_NDTVEN"	, , "Vencimento Bloqueado"     , " "   }, ;
				{"ZC7_NDTVCR"	, , "Vencto Real Bloqueado"    , " "   }, ;
				{"ZC7_ODTVEN"	, , "Vencimento Original"      , " "   }, ;
				{"ZC7_ODTVCR"	, , "Vencto Real Original"     , " "   } ,;
				{"ZC7_USRAPR"	, , "Codigo Aprovador"         , " "   }, ;
				{"ZC7_NOMAPR"	, , "Nome Aprovador"           , " "   }, ;
				{"ZC7_DTAPR"	, , "Data Aprovação"           , " "   }, ;
				{"ZC7_HRAPR"	, , "Hora Aprovação"           , " "   }, ;
				{"ZC7_OBS"  	, , "Observação"               , " "   } }
			Endif				 
		elseif sTpApr = '000005'
			aCpoBro		:= { {"ZC7_PREFIX"	, , "Prefixo"		           , " "   }, ;
			{"ZC7_NUM" 	, , "Numero Titulo"		       , " "   }, ;
			{"ZC7_PARCEL"	, , "Parcela"	               , " "   }, ;
			{"ZC7_CLIFOR"	, , "Cliente|Fornecedor"       , " "   }, ;
			{"ZC7_LOJA"	, , "Loja"			           , " "   }, ;
			{"ZC7_VLRBLQ"	, , "Valor Bloqueado"	       , "@E 999,999,999.99" },;
			{"ZC7_TPBLQ"	, , "Tipo Bloqueio"            , " "   }, ;
			{"ZC7_DSCBLQ"	, , "Desc. Bloqueio"           , " "   }, ;
			{"ZC7_USRAPR"	, , "Codigo Aprovador"         , " "   }, ;
			{"ZC7_NOMAPR"	, , "Nome Aprovador"           , " "   }, ;
			{"ZC7_DTAPR"	, , "Data Aprovação"           , " "   }, ;
			{"ZC7_HRAPR"	, , "Hora Aprovação"           , " "   }, ;
			{"ZC7_OBS"  	, , "Observação"               , " "   } }
		
		elseif sTpApr = '000011'
			aCpoBro		:= { {"ZC7_PREFIX"	, , "Prefixo"		           , " "   }, ;
							 {"ZC7_NUM" 	, , "Numero Titulo"		       , " "   }, ;
							 {"ZC7_PARCEL"	, , "Parcela"	               , " "   }, ;
							 {"ZC7_CLIFOR"	, , "Cliente|Fornecedor"       , " "   }, ;
							 {"ZC7_LOJA"	, , "Loja"			           , " "   }, ;
							 {"ZC7_VLRBLQ"	, , "Valor Bloqueado"	       , "@E 999,999,999.99" },;
							 {"ZC7_TPBLQ"	, , "Tipo Bloqueio"            , " "   }, ;
							 {"ZC7_DSCBLQ"	, , "Desc. Bloqueio"           , " "   }, ;
							 {"ZC7_USRAPR"	, , "Codigo Aprovador"         , " "   }, ;
							 {"ZC7_NOMAPR"	, , "Nome Aprovador"           , " "   }, ;
							 {"ZC7_DTAPR"	, , "Data Aprovação"           , " "   }, ;
							 {"ZC7_HRAPR"	, , "Hora Aprovação"           , " "   }, ;
							 {"ZC7_OBS"  	, , "Observação"               , " "   } }
		//INICIO Ticket  429    - Abel Babini   - 09/10/2020 - Tratamento de bloqueios Painel de pagamento
		else
			aCpoBro		:= { {"ZC7_PREFIX"	, , "Prefixo"		           , " "   }, ;
							 {"ZC7_NUM" 	, , "Numero Titulo"		       , " "   }, ;
							 {"ZC7_PARCEL"	, , "Parcela"	               , " "   }, ;
							 {"ZC7_CLIFOR"	, , "Cliente|Fornecedor"       , " "   }, ;
							 {"ZC7_LOJA"	, , "Loja"			           , " "   }, ;
							 {"ZC7_VLRBLQ"	, , "Valor Bloqueado"	       , "@E 999,999,999.99" },;
							 {"ZC7_TPBLQ"	, , "Tipo Bloqueio"            , " "   }, ;
							 {"ZC7_DSCBLQ"	, , "Desc. Bloqueio"           , " "   }, ;
							 {"ZC7_USRAPR"	, , "Codigo Aprovador"         , " "   }, ;
							 {"ZC7_NOMAPR"	, , "Nome Aprovador"           , " "   }, ;
							 {"ZC7_DTAPR"	, , "Data Aprovação"           , " "   }, ;
							 {"ZC7_HRAPR"	, , "Hora Aprovação"           , " "   }, ;
							 {"ZC7_OBS"  	, , "Observação"               , " "   } }
			//FIM Ticket  429    - Abel Babini   - 09/10/2020 - Tratamento de bloqueios Painel de pagamento
		ENDIF

		SetPrvt("oFont1", "oWindow"	, "oSay1"	, "oSay2"	, "oSay3"	, "oSay4"		, "oSay5"	, "oSay6"	, "oSay7"	, "oSay8"	, "oSay9", "oSay10")
		SetPrvt("oSay12", "oSay13"	, "oSay14"	, "oSay15"	, "oSay16"	, "oSay17"		, "oSay18"	, "oSay19"	, "oSay20"	, "oSay21"	, "oSay22" , "oSay23")
		SetPrvt("oSay24", "oSay25"	, "oSay26"	, "oSay27"	, "oSay28"	, "oBROWSER"	, "oGet1"	, "oGet2"	, "oGet3"	, "oGet4"	, "oGet5")
		SetPrvt("oGet7"	, "oGet8"	, "oGet9"	, "oGet10"	, "oGet11"	, "oGet12"		, "oCBox1"	, "oGet13"	, "oGet14"	, "oGet15"	, "oGet16" , "oGet17")
		SetPrvt("oGet18", "oGet19"	, "oCBox2"	, "oGet20"	, "oGet21"	, "oGet22"		, "oGet23"	, "oGet24")

		SetPrvt( "oBTNConfirma" , "oBTNCancela" )

	Else
		// FWNM - INTEGRACAO PROJETOS DE INVESTIMENTOS (AF8)

		aCpoBro := { {"ZC7_REVPRJ"	, , "Revisão"		    , " "	}, ;
		{"ZC7_VLRBLQ"	, , "Valor Bloqueado"	, "@E 999,999,999.9999"	},;
		{"AFE_USERF"	, , "Usuário Solicitante"	, " "	},;
		{"AFE_DATAF"	, , "Data Solicitação"	, " "	},;
		{"AFE_HORAF"	, , "Hora Solicitação"	, " "	},;
		{"AFE_MEMO"	    , , "Justificativa"	    , " "	} }

	EndIf

	oFont1  := TFont():New( "MS Sans Serif", 0, -19, , .T., 0, , 700, .T., .T., , , , , , )

	oWindow := MSDialog():New( 086, 230, 548, 1358, "Central de Aprovação", , , .F., , , , , , .T., , , .T. )

	// Integracao Projetos Investimentos - FWNM em 08/12/2017
	If Empty(cCodPrj)
		
		// Ricardo Lima-13/12/2018
		//fMontaTMPZC7( FwxFilial("ZC7") , cCodigo , nNumTit , cCodCli , cLojCli, "", nParctit, nTipTit )
		fMontaTMPZC7( cFilZC7 , cCodigo , nNumTit , cCodCli , cLojCli, "", nParctit, nTipTit )
		
		// Ricardo Lima - 06/04/18
		IF (TpRecPag = "P" .AND. sTpApr = "000005") .OR. lTpBlNs // Ricardo Lima-13/12/2018
			DbSelectArea("SE2")
			DbSetorder(6)  // E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
			IF DbSeek( cFilZC7 + cCodCli + cLojCli + cCodigo + nNumTit + nParctit + nTipTit )
			//IF DbSeek( FwxFilial("SE2") + cCodCli + cLojCli + cCodigo + nNumTit + nParctit + nTipTit )
				If Substr(SE2->E2_XPTCRTA,1,1) = 'S'
					MsgCrtPt += '1 - Bloqueio por estar fora da Média de Valor,'+chr(13)+chr(10)
				EndIf
				if Substr(SE2->E2_XPTCRTA,2,1) = 'S'
					MsgCrtPt += '2 - Bloqueio por Lançamento de Nf-e sem XML,'+chr(13)+chr(10)
				EndIf
				If Substr(SE2->E2_XPTCRTA,3,1) = 'S'
					MsgCrtPt += '3 - Bloqueio por Entrada de Nf-e sem Pedido de Compras,'+chr(13)+chr(10)
				EndIf
				If Substr(SE2->E2_XPTCRTA,4,1) = 'S'
					MsgCrtPt += '4 - Bloqueio por Não receber Vistoria Fisica no Recebimento,'+chr(13)+chr(10)
				endif
				If Substr(SE2->E2_XPTCRTA,5,1) = 'S'
					MsgCrtPt += '5 - Bloqueio Aprovação Tecnica do Serviço,'+chr(13)+chr(10)
				endif
				If Substr(SE2->E2_XPTCRTA,6,1) = 'S'
					MsgCrtPt += '6 - Bloqueio Integração por Modulo ou subsistema,'+chr(13)+chr(10)
				endif
				If Substr(SE2->E2_XPTCRTA,7,1) = 'S'
					MsgCrtPt += '7 - Bloqueio Validação de Chave Primaria,'+chr(13)+chr(10)
				endif
				If Substr(SE2->E2_XPTCRTA,8,1) = 'S'
					MsgCrtPt += '8 - Bloqueio por Duplicidade(Fornecedor+Valor+Emissão),'+chr(13)+chr(10)
				endif
				If Substr(SE2->E2_XPTCRTA,9,1) = 'S'
					MsgCrtPt += '9 - Bloqueio Pagamento Posterior a Entrega,'+chr(13)+chr(10)
				endif
			ENDIF
		ENDIF

		if sTpApr = "000004"
			oSay1		:= TSay():New( 008, 008, { || "Aprovação de Alçada Financeira" + IIF( TpRecPag="P" , " - Pagar" , " - Receber" )} , oWindow, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 540, 012 )
		elseif sTpApr = "000001"
			oSay1		:= TSay():New( 008, 008, { || "Aprovação de PA"}	, oWindow, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 540, 012 )
		elseif (Alltrim(sTpApr) $'000006/000007/000008/000009/000010') // Ricardo Lima-14/12/18|CH:044314| Aprovação de Fretes //Everson - 12/12/2019 - Chamado 029058.	
			oSay1		:= TSay():New( 008, 008, { || "Aprovação de Fretes"}, oWindow, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 540, 012 )
		elseif sTpApr = "000005"
			oSay1		:= TSay():New( 008, 008, { || "Aprovação de Nivel de Segurança"}	, oWindow, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 540, 012 )
		elseif sTpApr = "000011"
			oSay1		:= TSay():New( 008, 008, { || "Aprovação desbloqueio de titulos pagar - bloqueado" + IIF( TpRecPag="P" , " - Pagar" , " - Receber" )} , oWindow, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 540, 012 )	
		else
			oSay1		:= TSay():New( 008, 008, { || "Aprovação"}	, oWindow, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 540, 012 )
		endif

		oSay2		:= TSay():New( 027, 008, { || "Prefixo"}			    , oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 036, 008 )
		oSay2		:= TSay():New( 027, 055, { || "Especie"}			    , oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 036, 008 )
		oSay3		:= TSay():New( 027, 115, { || "Nr Titulo"}				, oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 040, 008 )
		oSay4		:= TSay():New( 027, 195, { || "Parcela"}				, oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 022, 010 )
		oSay6		:= TSay():New( 027, 243, { || "Codigo"}                 , oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 032, 010 )
		oSay7		:= TSay():New( 027, 295, { || "Loja"}					, oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 015, 010 )
		oSay8		:= TSay():New( 027, 335, { || "Fantasia"}	            , oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 018, 010 )
		
		// Chamado n. 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL - FWNM - 29/11/2019
		oSay10		:= TSay():New( 040, 335, { || "Razão"}	            , oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 018, 010 )
		//

		if sTpApr = "000001" .or. (Alltrim(sTpApr) $'000006/000007/000008/000009/000010') // Ricardo Lima-14/12/18|CH:044314| Aprovação de Fretes //Everson - 12/12/2019 - Chamado 029058.
			oSay9		:= TSay():New( 040, 008, { || "Valor"}					, oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 018, 010 )
		ENDIF
		//Ticket  429    - Abel Babini   - 09/10/2020 - Tratamento de bloqueios Painel de pagamento
		if (Alltrim(sTpApr) $'000020') // Ricardo Lima-14/12/18|CH:044314| Aprovação de Fretes //Everson - 12/12/2019 - Chamado 029058.
			oSay9	:= TSay():New( 040, 008, { || "Valor"}					, oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 018, 010 )
			//Ticket  429    - Abel Babini   - 09/11/2020 - Aumento da exibição do campo
			oSay24	:= TSay():New( 053, 008, { || "Msg. Solicitante:"}, oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 048, 010 )
		ENDIF

		oSay14		:= TSay():New( 140, 009, { || "Dados da Aprovação"}	    , oWindow, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 540, 012 )
		oSay15		:= TSay():New( 155, 008, { || "Codigo"} 				, oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 032, 008 )
		oSay16		:= TSay():New( 155, 110, { || "Nome"}   				, oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 032, 008 )
		oSay17		:= TSay():New( 155, 194, { || "Data"}					, oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 018, 008 )
		oSay18		:= TSay():New( 155, 247, { || "Hora"}				    , oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 029, 008 )
		oSay19		:= TSay():New( 170, 009, { || "Observação"}				, oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 032, 008 )
		IF cTpAprCF
			oSay20		:= TSay():New( 185, 009, { || "Custo Financeiro"}	    , oWindow, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 540, 012 )
			oSay21		:= TSay():New( 202, 008, { || "Percentual de Calculo"}	, oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 100, 008 )
			oSay22		:= TSay():New( 202, 090, { || "Dias de diferença"}		, oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 100, 008 )
			oSay23		:= TSay():New( 202, 160, { || "Custo da alteração R$ "}	, oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 100, 008 )
		ENDIF

		oBROWSER	:= MsSelect():New( "TMPZC7", "", "", aCpoBro, .F., .F., { 064, 008, 136, 548 }, , ,  oWindow )

		IF TpRecPag = "P"
			cNomCli := Posicione("SA2",1, FwxFilial("SA2") + cCodCli + cLojCli ,"A2_NREDUZ")
			cRazao  := AllTrim(Posicione("SA2",1, FwxFilial("SA2") + cCodCli + cLojCli ,"A2_NOME")) // Chamado n. 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL - FWNM - 29/11/2019
			dbSelectArea("SF1")
			dbSetOrder(1)
			if dbSeek( FWxFilial("SF1") + nNumTit + cCodigo + cCodCli + cLojCli )
				cEspec := SF1->F1_ESPECIE
			Endif
		ELSEIF TpRecPag = "R"
			cNomCli := Posicione("SA1",1, FwxFilial("SA1") + cCodCli + cLojCli ,"A1_NREDUZ")
			cRazao  := AllTrim(Posicione("SA1",1, FwxFilial("SA1") + cCodCli + cLojCli ,"A1_NOME")) // Chamado n. 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL - FWNM - 29/11/2019
		ELSEIF TpRecPag = "F" // Ricardo Lima-14/12/18|CH:044314| Aprovação de Fretes	
			cNomCli := Posicione("SA4",1, FwxFilial("SA4") + cCodCli + cLojCli ,"A4_NOME")
		ENDIF

		//ATRIBUINDO DADOS AS VARIAVEIS
		oGet1	:= TGet():New( 025, 026, { |u| If( PCount() > 0, cCodigo	:= u, cCodigo ) }, oWindow, 020, 008, ""		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cCodigo", , )
		oGet1	:= TGet():New( 025, 080, { |u| If( PCount() > 0, cEspec	    := u, cEspec  ) }, oWindow, 020, 008, ""		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cEspec", , )
		oGet2 	:= TGet():New( 025, 145, { |u| If( PCount() > 0, nNumTit	:= u, nNumTit ) }, oWindow, 041, 008, ""        , , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "nNumTit", , )
		oGet3 	:= TGet():New( 025, 215, { |u| If( PCount() > 0, nParctit	:= u, nParctit) }, oWindow, 026, 008, ''		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "nParctit", , )
		oGet5 	:= TGet():New( 025, 265, { |u| If( PCount() > 0, cCodCli	:= u, cCodCli ) }, oWindow, 028, 008, ''		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cCodCli", , )
		oGet6 	:= TGet():New( 025, 310, { |u| If( PCount() > 0, cLojCli	:= u, cLojCli ) }, oWindow, 019, 008, ''		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cLojCli", , )
		oGet7 	:= TGet():New( 025, 360, { |u| If( PCount() > 0, cNomCli	:= u, cNomCli ) }, oWindow, 126, 008, ''        , , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cNomCli", , )

		// Chamado n. 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL - FWNM - 29/11/2019
		oGet10 	:= TGet():New( 040, 360, { |u| If( PCount() > 0, cRazao	:= u, cRazao ) }, oWindow, 126, 008, ''        , , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cRazao", , )
		//

		if sTpApr = "000001" .OR. (Alltrim(sTpApr) $'000006/000007/000008/000009/000010') // Ricardo Lima-14/12/18|CH:044314| Aprovação de Fretes //Everson - 12/12/2019 - Chamado 029058.	
			oGet8 	:= TGet():New( 040, 027, { |u| If( PCount() > 0, cDscSet	:= u, cDscSet ) }, oWindow, 057, 008, '@E 999,999,999.9999'		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cDscSet", , )
		ENDIF
		//Ticket  429    - Abel Babini   - 09/10/2020 - Tratamento de bloqueios Painel de pagamento
		if (Alltrim(sTpApr) $'000020')
			oGet8 	:= TGet():New( 040, 027, { |u| If( PCount() > 0, cDscSet	:= u, cDscSet ) }, oWindow, 057, 008, '@E 999,999,999.9999'		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cDscSet", , )
			//Ticket  429    - Abel Babini   - 09/11/2020 - Aumento da exibição do campo
			oGet20 	:= TGet():New( 053, 055, { |u| If( PCount() > 0, cMsgSol	:= u, cMsgSol ) }, oWindow, 430, 008, ''		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cMsgSol", , )
		ENDIF

		oCBox1	:= TGet():New( 155, 044, { |u| If( PCount() > 0, cUsrApr	:= u, cUsrApr ) }, oWindow, 039, 008, ""	        , , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cUsrApr", , )
		cUsrApr := AllTrim( __cUserID )

		oGet13	:= TGet():New( 155, 128, { |u| If( PCount() > 0, cNomeUsr	:= u, cNomeUsr ) }, oWindow, 060, 008, ""	        , , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cNomeUsr", , )
		cNomeUsr := AllTrim(UsrRetName(__cUserID))

		oGet14	:= TGet():New( 155, 210, { |u| If( PCount() > 0, dDataApr	:= u, dDataApr ) }, oWindow, 035, 008, ''			, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., ""	, "dDataApr", , )
		dDataApr := DTOC( DATE() )

		oGet15	:= TGet():New( 155, 278, { |u| If( PCount() > 0, tHoraApr	:= u, tHoraApr ) }, oWindow, 034, 008, ''			   , , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "tHoraApr", , )
		tHoraApr := Time()

		oGet16	:= TGet():New( 170, 044, { |u| If( PCount() > 0, cDscObs	:= u, cDscObs ) }, oWindow, 254, 008, ''			, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., ""	, "cDscObs", , )
		IF cTpAprCF
			oGet17	:= TGet():New( 200, 064, { |u| If( PCount() > 0, nPerCus	:= u, nPerCus ) }, oWindow, 015, 008, ''			, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., ""	, "nPerCus", , )
			oGet18	:= TGet():New( 200, 135, { |u| If( PCount() > 0, nNumCal	:= u, nNumCal ) }, oWindow, 015, 008, ''			, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., ""	, "nNumCal", , )
			oGet19	:= TGet():New( 200, 220, { |u| If( PCount() > 0, nCusEfet	:= u, nCusEfet) }, oWindow, 060, 008, '@E 999,999,999.99'			, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., ""	, "nCusEfet", , )
		ENDIF

	Else
		// FWNM - INTEGRACAO PROJETOS DE INVESTIMENTOS (AF8)

		oSay1		:= TSay():New( 008, 008, { || "Projeto de Investimentos"}	, oWindow, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 340, 012 )
		oSay9		:= TSay():New( 044, 008, { || "Limite Atual Autorizado"}    , oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 055, 010 )

		oSay14		:= TSay():New( 145, 009, { || "Aprovador"}	            , oWindow, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 540, 012 )
		oSay15		:= TSay():New( 166, 008, { || "Codigo"} 				, oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 032, 008 )
		oSay16		:= TSay():New( 166, 113, { || "Nome"}   				, oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 032, 008 )
		oSay17		:= TSay():New( 166, 194, { || "Data"}					, oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 018, 008 )
		oSay18		:= TSay():New( 166, 247, { || "Hora"}				    , oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 029, 008 )
		oSay19		:= TSay():New( 183, 008, { || "Digite uma observação"}  , oWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 075, 008 )

		//MONTANDO TABELA TEMPORARIA COM INFORMAÇÕES DO PROJETO
		//fMontaTMPZC7( FwxFilial("ZC7") , cCodigo , nNumTit , cCodCli , cLojCli, cCodPrj )
		fMontaTMPZC7( cFilZC7 , cCodigo , nNumTit , cCodCli , cLojCli, cCodPrj )
		
		oBROWSER	:= MsSelect():New( "TMPZC7", "", "", aCpoBro, .F., .F., { 064, 008, 136, 548 }, , ,  oWindow )

		//ATRIBUINDO DADOS AS VARIAVEIS
		oGet1	:= TGet():New( 027, 008, { |u| If( PCount() > 0, cCodPrj	:= u, cCodPrj ) }, oWindow, 036, 008, ""		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cCodPrj", , )

		oGet2 	:= TGet():New( 027, 050, { |u| If( PCount() > 0, cNomPrj	:= u, cNomPrj ) }, oWindow, 400, 008, ''        , , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cNomPrj", , )
		cNomPrj := AllTrim(Posicione("AF8",1, FwxFilial("AF8") + cCodPrj,"AF8_DESCRI"))

		nVlrPrj := Posicione("AF8",1,FWxFilial("AF8")+cCodPrj,"AF8_XVALOR")
		oGet3 	:= TGet():New( 044, 80, { |u| If( PCount() > 0, nVlrPrj	:= u, nVlrPrj ) }, oWindow, 57, 008, '999,999,999.9999'		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "nVlrPrj", , )

		oCBox1	:= TGet():New( 165, 044, { |u| If( PCount() > 0, cUsrApr	:= u, cUsrApr ) }, oWindow, 039, 008, ""	        , , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cUsrApr", , )
		cUsrApr := AllTrim( __cUserID )

		oGet4	:= TGet():New( 165, 128, { |u| If( PCount() > 0, cNomeUsr	:= u, cNomeUsr ) }, oWindow, 050, 008, ""	        , , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cNomeUsr", , )
		cNomeUsr := AllTrim(UsrRetName(__cUserID))

		oGet5	:= TGet():New( 165, 210, { |u| If( PCount() > 0, dDataApr	:= u, dDataApr ) }, oWindow, 035, 008, ''			, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., ""	, "dDataApr", , )
		dDataApr := DTOC( DATE() )

		oGet6	:= TGet():New( 165, 278, { |u| If( PCount() > 0, tHoraApr	:= u, tHoraApr ) }, oWindow, 034, 008, ''			   , , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "tHoraApr", , )
		tHoraApr := Time()

		oGet7	:= TGet():New( 183, 075, { |u| If( PCount() > 0, cDscObs	:= u, cDscObs ) }, oWindow, 400, 008, ''			, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., ""	, "cDscObs", , )

	EndIf


	if cUsrPApr
		oBTNConfirma := TButton():New( 210, 417, "&Confirma", oWindow, { || U_ADFINL46( cDscObs , TpRecPag , '1' ), oWindow:End() , oBrowse:Refresh( .T. ) }	, 044, 012, , , , .T., , "", , , , .F. )
		oBTNConfirma:SetCSS("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #00FF00, stop: 1 #8C1717);color: white}") // Chamado n. 054538 || OS 055940 || FINANCAS || EDUARDO || 8352 || CENTRAL DE APROVACAO - FWNM - 15/01/2020
		
		oBTNConfirma := TButton():New( 210, 466, "&Reprova",  oWindow, { || U_ADFINR46( cDscObs , TpRecPag , '1' ), oWindow:End() , oBrowse:Refresh( .T. ) }	, 044, 012, , , , .T., , "", , , , .F. )
		oBTNConfirma:SetCSS("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}") // Chamado n. 054538 || OS 055940 || FINANCAS || EDUARDO || 8352 || CENTRAL DE APROVACAO - FWNM - 15/01/2020

		// Integracao Projetos Investimentos - FWNM em 26/12/2017
		If !Empty(cCodPrj)
			//		oBTNConfirma := TButton():New( 210, 417, "Rateio"	, oWindow, { || VerRateio(), /*oWindow:End()*/ }	, 044, 012, , , , .T., , "", , , , .F. )
			//		If AllTrim(cRevPrj) <> "0001"
			//			oBTNConfirma := TButton():New( 210, 368, "Revisão"	, oWindow, { || VerJustRev(), /*oWindow:End()*/ }	, 044, 012, , , , .T., , "", , , , .F. )
			//		EndIf

			//		oBTNConfirma := TButton():New( 210, 319, "Recusa"	, oWindow, { || RecusaPrj(), oWindow:End() }	, 044, 012, , , , .T., , "", , , , .F. )
		EndIf

	endif

	oBTNCancela  := TButton():New( 210, 515, "Cancela"	, oWindow, { || .F., oWindow:End() }	, 044, 012, , , , .T., , "", , , , .F. )
	if cTpAprPA // Ricardo Lima - 13/03/18
		oBTNCancela  := TButton():New( 008,380,"Consulta Status do Pedido no SAG" , oWindow,{ || .F.,U_ADSTS046() } , 95,012,,,,.T.,,"",,,,.F.)
	endif
	IF lTitPA
		oBTNCancela  := TButton():New( 008,480,"Status de PA do Fornecedor",oWindow,{ || .F. , U_ADSTP046() } , 80 , 012,,,,.T.,,"",,,,.F.)
	EndIf
	IF ( cUsrPApr .AND. sTpApr = "000005" ) .OR. lTpBlNs // Ricardo Lima-13/12/2018
		oBTNCancela  := TButton():New( 008, 500, "Consulta Bloqueios" , oWindow, { || .F., ApMsgInfo( MsgCrtPt , 'Bloqueios por Nivel de Segurança') }	, 064, 012, , , , .T., , "", , , , .F. )
	ENDIF

	oWindow:Activate(, , , .T. )

	RestArea(aArea)

Return( .T. )

/*/{Protheus.doc} User Function ADFINL46
	Central Aprovacao Menu
	@type  Function
	@author Ricardo Lima
	@since 14/11/2017
	@version 01
	@history Chamado 038609
/*/
User Function ADFINL46( cDscObs , TpRecPag , cOpc )

	Local aArea:= GetArea()
	Local cAssunto := ""
	Local cMensagem := ""
	Local cCodSup := ""
	Local cNomApr := ""
	Local ZC7ACRESC := 0
	Local ZC7CNABAC := 0
	Local ZC7CNABDE := 0
	Local ZC7DECRES := 0
	Local ZC7VLRJUR := 0
	Local ZC7NDTVEN := Date()
	Local ZC7NDTVCR := Date()
	Local nVlrTit   := 0
	Local lVldApv   := .F.
	Local lAprTit   := .F.
	Local aZC7Novo := {}
	Local nDdif    := 0
	Local nVdif    := 0

	Local cEVALOR   := ""
	Local cEDECRESC := ""
	Local cEACRESC  := ""
	Local cEVALJUR  := ""
	Local cECNABDES := ""
	Local dEVENCTO  := ""
	Local dEVENCREA := ""
	Local sObsZC7   := ""
	Local ldDelReg  := .F.
	Local cOrigem	:= "" 
	Local lZC7OK    := .f.
	Local cOldFase  := ""
	Local cFaseRej  := GetMV("MV_#FASREJ",,"01")	
	Local nVlFuturo := 0
	Local nConsumo  := 0
	Local nVlrBlq   := 0
	Local lTudoOk   := .T.

	U_ADINF009P('ADFIN046P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Central Aprovação')

	//
	Conout( DToC(Date()) + " " + Time() + " ADFIN046P - ADFINL46 - cOpc " + cValToChar(cOpc) )
	Conout( DToC(Date()) + " " + Time() + " ADFIN046P - ADFINL46 - TpRecPag " + cValToChar(TpRecPag) )
	Conout( DToC(Date()) + " " + Time() + " ADFIN046P - ADFINL46 - ZC3 " + cValToChar(RetSqlName("ZC3")) )

	//Everson - 19/03/19. Chamado 044314. Tratamento para aprovação de frete pelo App.
	If Alltrim(cValToChar(cOpc)) == "2" .And. Alltrim(cValToChar(TpRecPag)) == "F"

		cQuery := " SELECT * "
		cQuery += " FROM "+ RetSqlName("ZC3") +" "
		cQuery += " WHERE ZC3_CODUSU = '"+__cUserID+"' "
		cQuery += " AND D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY ZC3_CODUSU "
		cQuery := ChangeQuery(cQuery)

		If Select("ADFIN146P") > 0
			ADFIN146P->(DbCloseArea())

		EndIf

		Conout( DToC(Date()) + " " + Time() + " ADFIN046P - ADFINL46 - cQuery " + cValToChar(cQuery) )

		TCQUERY cQuery new alias "ADFIN146P"

		DbSelectArea("ADFIN146P")

		while ADFIN146P->( !EOF() )
			nLimOper  := ADFIN146P->ZC3_LIMASC

			ADFIN146P->(DbSkip())
		end

		//
		If Type("nLimOper") = "U"
			nLimOper := 0

		EndIf

		cAno := ALLTRIM(STR(YEAR(Date())))
		cMes := StrZero( MONTH(DATE()) , 2 )
		cDia := StrZero(DAY(DATE()), 2 ) //048042 // Alteracao para levar dois digitos no dia

		IF SELECT("ADFIN46Q") > 0
			ADFIN46Q->( DBCLOSEAREA() )
		ENDIF
		cQry := " SELECT ZC7_FILIAL, SUM( ZC7_VLRBLQ ) VLR_APR "
		cQry += " FROM "+ RetSqlName("ZC7") +" ZC7 "
		cQry += " WHERE ZC7_USRAPR = '"+ __cUserID +"' "
		IF cTpLimNS = 'M'
			cQry += " AND ZC7_DTAPR BETWEEN '"+cAno+cMes+"01' AND '"+cAno+cMes+"31' "
		ELSE
			cQry += " AND ZC7_DTAPR BETWEEN '"+cAno+cMes+cDia+"' AND '"+cAno+cMes+cDia+"' "
		ENDIF
		cQry += " AND ZC7_EFEAPR = 'S' "
		cQry += " AND ZC7_TPBLQ = '" + cValToChar(sTpApr) + "' " //Everson - 12/12/2019 - Chamado 029058.
		cQry += " AND ZC7.D_E_L_E_T_ = ' ' "
		cQry += " GROUP BY ZC7_FILIAL "
		TCQUERY cQry new alias "ADFIN46Q"
		nAprFrt := ADFIN46Q->VLR_APR

		//
		Conout( DToC(Date()) + " " + Time() + " ADFIN046P - ADFINL46 - cQry " + cValToChar(cQry) )

	EndIf
	//

	BEGIN TRANSACTION

		// Integracao Projetos Investimentos - FWNM em 08/12/2017
		If Empty(cCodPrj)

			IF TpRecPag = "P"
			
				DbSelectArea("SE2")
				DbSetorder(6)  // E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
				//IF DbSeek( FwxFilial("SE2") + cCodCli + cLojCli + cCodigo + nNumTit + nParctit + nTipTit )
				IF DbSeek( cFilZC7 + cCodCli + cLojCli + cCodigo + nNumTit + nParctit + nTipTit ) // Chamado n. 054538 || OS 055940 || FINANCAS || EDUARDO || 8352 || CENTRAL DE APROVACAO - FWNM - 16/01/2020
					cEVALOR   := SE2->E2_VALOR
					cEDECRESC := SE2->E2_DECRESC
					cEACRESC  := SE2->E2_ACRESC
					cEVALJUR  := SE2->E2_VALJUR
					cECNABDES := SE2->E2_CNABDES
					dEVENCTO  := SE2->E2_VENCTO
					dEVENCREA := SE2->E2_VENCREA

				Else
					dbSelectArea("ZC7")
					dbSetOrder( 2 )  // ZC7_FILIAL+ZC7_CLIFOR+ZC7_LOJA+ZC7_PREFIX+ZC7_NUM+ZC7_PARCEL+ZC7_TIPO
					//If dbSeek( FwxFilial("ZC7") + cCodCli + cLojCli + cCodigo + nNumTit + nParctit + nTipTit )
					If dbSeek( cFilZC7 + cCodCli + cLojCli + cCodigo + nNumTit + nParctit + nTipTit ) // Chamado n. 054538 || OS 055940 || FINANCAS || EDUARDO || 8352 || CENTRAL DE APROVACAO - FWNM - 16/01/2020
					
						WHILE ZC7->(!EOF()) .AND. ZC7->ZC7_FILIAL=cFilZC7/*FwxFilial("ZC7")*/ .AND. ZC7->ZC7_CLIFOR=cCodCli .AND. ZC7->ZC7_LOJA=cLojCli .AND. ZC7->ZC7_PREFIX=cCodigo .AND. ZC7->ZC7_NUM=nNumTit .AND. ZC7->ZC7_PARCEL=nParctit .AND. ZC7->ZC7_TIPO=nTipTit
							IF EMPTY(ZC7->ZC7_USRAPR)
								RecLock("ZC7", .F.)
								ZC7->(dbDelete())
								ZC7->(MsUnlock())
								ldDelReg := .T.
							EndIf	
							DbSkip()
						END
					Endif
				Endif
			
			ELSEIF TpRecPag = "R"

				DbSelectArea("SE1")
				DbSetorder(2)  // E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
				//IF DbSeek( FwxFilial("SE1") + cCodCli + cLojCli + cCodigo + nNumTit + nParctit + nTipTit )
				IF dbSeek( cFilZC7 + cCodCli + cLojCli + cCodigo + nNumTit + nParctit + nTipTit ) // Chamado n. 054538 || OS 055940 || FINANCAS || EDUARDO || 8352 || CENTRAL DE APROVACAO - FWNM - 16/01/2020
					cEVALOR   := SE1->E1_VALOR
					cEDECRESC := SE1->E1_DECRESC
					cEACRESC  := SE1->E1_ACRESC
					cEVALJUR  := SE1->E1_VALJUR
					dEVENCTO  := SE1->E1_VENCTO
					dEVENCREA := SE1->E1_VENCREA
				Else
					dbSelectArea("ZC7")
					dbSetOrder( 2 )  // ZC7_FILIAL+ZC7_CLIFOR+ZC7_LOJA+ZC7_PREFIX+ZC7_NUM+ZC7_PARCEL+ZC7_TIPO
					//If dbSeek( FwxFilial("ZC7") + cCodCli + cLojCli + cCodigo + nNumTit + nParctit + nTipTit )
					If dbSeek( cFilZC7 + cCodCli + cLojCli + cCodigo + nNumTit + nParctit + nTipTit ) // Chamado n. 054538  || OS 055940 || FINANCAS || EDUARDO || 8352 || CENTRAL DE APROVACAO - FWNM - 16/01/2020
						WHILE ZC7->(!EOF()) .AND. ZC7->ZC7_FILIAL=cFilZC7/*FwxFilial("ZC7")*/ .AND. ZC7->ZC7_CLIFOR=cCodCli .AND. ZC7->ZC7_LOJA=cLojCli .AND. ZC7->ZC7_PREFIX=cCodigo .AND. ZC7->ZC7_NUM=nNumTit .AND. ZC7->ZC7_PARCEL=nParctit .AND. ZC7->ZC7_TIPO=nTipTit
							IF EMPTY(ZC7->ZC7_USRAPR)
								RecLock("ZC7", .F.)
								ZC7->(dbDelete())
								ZC7->(MsUnlock())
								ldDelReg := .T.
							EndIf	
							DbSkip()
						END
					Endif
				Endif
			Endif

			dbSelectArea("ZC7")
			dbSetOrder( 2 )  // ZC7_FILIAL+ZC7_CLIFOR+ZC7_LOJA+ZC7_PREFIX+ZC7_NUM+ZC7_PARCEL+ZC7_TIPO
			//If dbSeek( FwxFilial("ZC7") + cCodCli + cLojCli + cCodigo + nNumTit + nParctit + nTipTit) .AND. !ldDelReg
			If dbSeek( cFilZC7 + cCodCli + cLojCli + cCodigo + nNumTit + nParctit + nTipTit) .AND. !ldDelReg // Chamado n. 054538 || OS 055940 || FINANCAS || EDUARDO || 8352 || CENTRAL DE APROVACAO - FWNM - 16/01/2020
				WHILE ZC7->(!EOF()) .AND. ZC7->ZC7_FILIAL=cFilZC7/*FwxFilial("ZC7")*/ .AND. ZC7->ZC7_CLIFOR=cCodCli .AND. ZC7->ZC7_LOJA=cLojCli .AND. ZC7->ZC7_PREFIX=cCodigo .AND. ZC7->ZC7_NUM=nNumTit .AND. ZC7->ZC7_PARCEL=nParctit .AND. ZC7->ZC7_TIPO=nTipTit
					IF EMPTY(ZC7->ZC7_USRAPR)
						IF ZC7->ZC7_TPBLQ = "000001" .OR. "ICMS" $ ALLTRIM(ZC7->ZC7_DSCBLQ) // RICARDO LIMA - 30/01/18
							If cTpAprPA .AND. cPAvcALTSAG // Ricardo Lima - 28/03/18
								IF nLimMax >= ZC7->ZC7_VLRBLQ .AND. nLimGer >= ( nValApr + ZC7->ZC7_VLRBLQ ) .AND. cAprVcPa = 'S' // Ricardo Lima - 22/03/18
									lVldApv := .T.
									nValApr += ZC7->ZC7_VLRBLQ // Ricardo Lima - 23/03/18
								else
									lVldApv := .F.
								endif
							Else
								IF nLimMax >= ZC7->ZC7_VLRBLQ .AND. nLimGer >= ( nValApr + ZC7->ZC7_VLRBLQ ) // Ricardo Lima - 22/03/18
									lVldApv := .T.
									nValApr += ZC7->ZC7_VLRBLQ // Ricardo Lima - 23/03/18
								else
									lVldApv := .F.
								endif
							Endif
						ELSEIF ZC7->ZC7_TPBLQ = "000004"  // alçada
							if !empty(ZC7->ZC7_NDTVEN)
								//INICIO Ticket 15609 - Abel Babini - 15/06/2021 - Ajuste na validação de datas de vencimento
								DbSelectArea("SE1")
								DbSetorder(2)  // E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
								IF SE1->(dbSeek( cFilZC7 + cCodCli + cLojCli + cCodigo + nNumTit + nParctit + nTipTit ))
									if ZC7->ZC7_NDTVEN < SE1->E1_VENCORI
										nDdif := SE1->E1_VENCORI - ZC7->ZC7_NDTVEN
										if nDiasAnt >= nDdif .AND. nLimAL >= (nValALApr + ZC7->ZC7_CUSFIN)
											lVldApv := .T.
											nValALApr += ZC7->ZC7_CUSFIN
										else
											lVldApv := .F.
										endif
									ElseIf ZC7->ZC7_NDTVEN > SE1->E1_VENCORI
										nDdif := ZC7->ZC7_NDTVEN - SE1->E1_VENCORI
										if nDiasPos >= nDdif .AND. nLimAL >= (nValALApr + ZC7->ZC7_CUSFIN)
											lVldApv := .T.
											nValALApr += ZC7->ZC7_CUSFIN
										else
											lVldApv := .F.
										endif
									endif

									/*
									if ZC7->ZC7_NDTVEN < dEVENCTO
										nDdif := dEVENCTO - ZC7->ZC7_NDTVEN
										if nDiasAnt >= nDdif .AND. nLimAL >= (nValALApr + ZC7->ZC7_CUSFIN)
											lVldApv := .T.
											nValALApr += ZC7->ZC7_CUSFIN
										else
											lVldApv := .F.
										endif
									ElseIf ZC7->ZC7_NDTVEN > dEVENCTO
										nDdif := ZC7->ZC7_NDTVEN - dEVENCTO
										if nDiasPos >= nDdif .AND. nLimAL >= (nValALApr + ZC7->ZC7_CUSFIN)
											lVldApv := .T.
											nValALApr += ZC7->ZC7_CUSFIN
										else
											lVldApv := .F.
										endif
									endif
									*/
								ENDIF
								//FIM Ticket 15609 - Abel Babini - 15/06/2021 - Ajuste na validação de datas de vencimento
							endif
							IF !EMPTY(nPercJur) .AND. !EMPTY(ZC7->ZC7_VLRJUR) // Analisa alcada de aprovacao para Juros
								nVdif := cEVALOR + ZC7->ZC7_VLRJUR
								if (nPercJur/100) >= ( Round( (nVdif/cEVALOR)-1 , 2) ) .AND. nLimAL >= ( nValALApr + ZC7->ZC7_VLRJUR ) // Ricardo Lima - 22/03/18
									lVldApv := .T.
									nValALApr += ZC7->ZC7_VLRJUR // Ricardo Lima - 23/03/18
								else
									lVldApv := .F.
								endif
							ENDIF
							IF !EMPTY(nPercAcs) .AND. !EMPTY(ZC7->ZC7_ACRESC)// Analisa alcada de aprovacao para Acrescimo
								nVdif := cEVALOR + ZC7->ZC7_ACRESC
								if (nPercAcs/100) >= ( Round( (nVdif/cEVALOR)-1 , 2) ) .AND. nLimAL >= (nValALApr + ZC7->ZC7_ACRESC ) // Ricardo Lima - 23/03/18
									lVldApv := .T.
									nValALApr += ZC7->ZC7_ACRESC // Ricardo Lima - 23/03/18
								else
									lVldApv := .F.
								endif
							ENDIF
							IF !EMPTY(nPercAcs) .AND. !EMPTY(ZC7->ZC7_CNABAC)// Analisa alcada de aprovacao para Acrescimo Cnab
								nVdif := cEVALOR + ZC7->ZC7_CNABAC
								if (nPercAcs/100) >= ( Round( (nVdif/cEVALOR)-1 , 2) ) .AND. nLimAL >= ( nValALApr + ZC7->ZC7_CNABAC ) // Ricardo Lima - 23/03/18
									lVldApv := .T.
									nValALApr += ZC7->ZC7_CNABAC // Ricardo Lima - 23/03/18
								else
									lVldApv := .F.
								endif
							ENDIF
							IF !EMPTY(nPercDes) .AND. !EMPTY(ZC7->ZC7_CNABDE) // Analisa alcada de aprovacao para Desconto
								nVdif := cEVALOR - ZC7->ZC7_CNABDE
								IF (nPercDes/100) >= ABS( ( Round( (nVdif/cEVALOR)-1 , 2) ) ) .AND. nLimAL >= ( nValALApr + ZC7->ZC7_CNABDE ) // Ricardo lima - 23/03/18
									lVldApv := .T.
									nValALApr += ZC7->ZC7_CNABDE // Ricardo Lima - 23/03/18
								else
									lVldApv := .F.
								ENDIF
							ENDIF
							IF !EMPTY(nPercDcs) .AND. !EMPTY(ZC7->ZC7_DECRES) // Analisa alcada de aprovacao para Decrescimo
								nVdif := cEVALOR - ZC7->ZC7_DECRES
								IF (nPercDcs/100) >= ABS( ( Round( (nVdif/cEVALOR)-1 , 2) ) ) .AND. nLimAL >= ( nValALApr + ZC7->ZC7_DECRES ) // Ricardo Lima - 23/03/18
									lVldApv := .T.
									nValALApr += ZC7->ZC7_DECRES // Ricardo Lima - 23/03/18
								else
									lVldApv := .F.
								ENDIF
							ENDIF
							// Ricardo Lima - 20/02/18
							IF Empty(ZC7->ZC7_VLRJUR) .AND. Empty(ZC7->ZC7_ACRESC) .AND. Empty(ZC7->ZC7_CNABAC) .AND. Empty(ZC7->ZC7_CNABDE) .AND. Empty(ZC7->ZC7_DECRES) .AND. !lVldApv .AND. nLimAL >= ( nValALApr + ZC7->ZC7_VLRJUR + ZC7->ZC7_ACRESC + ZC7->ZC7_CNABAC + ZC7->ZC7_CNABDE + ZC7->ZC7_DECRES ) .AND. empty(ZC7->ZC7_NDTVEN)
								lVldApv := .T.
								nValALApr += ZC7->ZC7_VLRJUR + ZC7->ZC7_ACRESC + ZC7->ZC7_CNABAC + ZC7->ZC7_CNABDE + ZC7->ZC7_DECRES
							ENDIF
						ELSEIF ZC7->ZC7_TPBLQ = "000005"  // Ricardo Lima - 06/04/18
							// Verifica Aprovação do Nivel
							if nLiMaxNS >= ZC7->ZC7_VLRBLQ .AND. nLimNS >= ( nValNSApr + ZC7->ZC7_VLRBLQ) .AND. Val(nNVLimNS) >= Val(ZC7->ZC7_NIVSEG)
								lVldApv := .T.
								nValNSApr += ZC7->ZC7_VLRBLQ
							else
								lVldApv := .F.
							endif
						ELSEIF (Alltrim(ZC7->ZC7_TPBLQ) $'000006/000007/000008/000009/000010') // Ricardo Lima-14/12/18|CH:044314| Aprovação de Fretes //Everson - 12/12/2019 - Chamado 028059.
							IF nLimOper >= ( nAprFrt + ZC7->ZC7_VLRBLQ )
								lVldApv := .T.
								nAprFrt += ZC7->ZC7_VLRBLQ // Ricardo Lima - 23/03/18
							else
								lVldApv := .F.
							endif
						//INICIO Ticket  429    - Abel Babini   - 30/10/2020 - Correção na liberação de bloqueios Painel de pagamento
						ELSEIF Alltrim(ZC7->ZC7_TPBLQ) $ "000011/000020" // @history Ticket 11556   - Fernando Maci - 27/04/2021 - Processo Trabalhista - Títulos
							// Verifica Aprovação do Nivel
							if nLiMaxNS >= ZC7->ZC7_VLRBLQ .AND. nLimNS >= ( nValNSApr + ZC7->ZC7_VLRBLQ) .AND. Val(nNVLimNS) >= Val(ZC7->ZC7_NIVSEG)
								lVldApv := .T.
								nValNSApr += ZC7->ZC7_VLRBLQ
							else
								lVldApv := .F.
							endif	
						//FIM Ticket  429    - Abel Babini   - 30/10/2020 - Correção na liberação de bloqueios Painel de pagamento

						// @history Ticket 11556   - Fernando Maci - 07/05/2021 - Processo Trabalhista - Títulos
						ElseIf Alltrim(ZC7->ZC7_TPBLQ) $ "000013" // Acordo Trabalhista
						
							nVlrMax := GetZFCMAX()
							
							If nVlrMax >= ZC7->ZC7_VLRBLQ
								lVldApv := .T.
								nValNSApr += ZC7->ZC7_VLRBLQ
							Else
								lVldApv := .F.
							EndIf
						//

						ENDIF
						
						//Everson - 28/03/19. Chamado 044314.
						cOrigem := Alltrim(cValToChar(ZC7->ZC7_ORIGEM))
						
						IF lVldApv
							RecLock("ZC7",.F.)
								ZC7->ZC7_USRAPR := AllTrim( __cUserID )
								ZC7->ZC7_NOMAPR := AllTrim(UsrRetName(__cUserID))
								ZC7->ZC7_DTAPR := DATE()
								ZC7->ZC7_HRAPR := TIME()
								ZC7->ZC7_OBS   := cDscObs
								ZC7->ZC7_EFEAPR := 'S' // Ricardo Lima - 23/03/18
							MSUnlock()

							lAprTit   := .T.

						ELSE
							RecLock("ZC7",.F.)
								ZC7->ZC7_USRAPR := AllTrim( __cUserID )
								ZC7->ZC7_NOMAPR := AllTrim(UsrRetName(__cUserID))
								ZC7->ZC7_DTAPR := DATE()
								ZC7->ZC7_HRAPR := TIME()
								ZC7->ZC7_OBS   := cDscObs
							MSUnlock()

							//
							Aadd(aZC7Novo,{ ZC7->ZC7_FILIAL ,;
							ZC7->ZC7_PREFIX  ,;
							ZC7->ZC7_NUM     ,;
							ZC7->ZC7_PARCEL  ,;
							ZC7->ZC7_TIPO    ,;
							ZC7->ZC7_CLIFOR  ,;
							ZC7->ZC7_LOJA    ,;
							ZC7->ZC7_VLRBLQ  ,;
							ZC7->ZC7_DECRES  ,;
							ZC7->ZC7_TPBLQ   ,;
							ZC7->ZC7_DSCBLQ  ,;
							ZC7->ZC7_RECPAG  ,;
							ZC7->ZC7_PROJET  ,;
							ZC7->ZC7_NDTVEN  ,;
							ZC7->ZC7_NDTVCR  ,;
							ZC7->ZC7_VLRJUR  ,;
							ZC7->ZC7_ACRESC  ,;
							ZC7->ZC7_CNABAC  ,;
							ZC7->ZC7_CNABDE  ,;
							ZC7->ZC7_REVPRJ  ,;
							ZC7->ZC7_OBS     ,;
							ZC7->ZC7_NIVEL   ,;
							ZC7->ZC7_CUSFIN  ,;
							ZC7->ZC7_PERCUS  ,;
							ZC7->ZC7_NUMCAL  ,;
							ZC7->ZC7_NIVSEG  ,;
							ZC7->ZC7_ODTVEN  ,; 
							ZC7->ZC7_ODTVCR})
							lAprTit := .F.
						ENDIF

						ZC7ACRESC := ZC7->ZC7_ACRESC
						ZC7CNABAC := ZC7->ZC7_CNABAC
						ZC7CNABDE := ZC7->ZC7_CNABDE
						ZC7DECRES := ZC7->ZC7_DECRES
						ZC7VLRJUR := ZC7->ZC7_VLRJUR
						ZC7NDTVEN := ZC7->ZC7_NDTVEN
						ZC7NDTVCR := ZC7->ZC7_NDTVCR
						sObsZC7   := ZC7->ZC7_DSCBLQ
					ENDIF
					DbSkip()
				END
			ENDIF

			IF TpRecPag = "P" .AND. !ldDelReg

				DbSelectArea("SE2")
				DbSetorder(6)  // E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
				//IF DbSeek( FwxFilial("SE2") + cCodCli + cLojCli + cCodigo + nNumTit + nParctit + nTipTit )
				IF DbSeek( cFilZC7 + cCodCli + cLojCli + cCodigo + nNumTit + nParctit + nTipTit ) 
					IF lAprTit
						RecLock("SE2",.F.)
						SE2->E2_XDIVERG := 'N'
						SE2->E2_XOBSAPR := Alltrim(cDscObs)
						if sTpApr = "000004"
							// Ricardo Lima - 20/02/18
							SE2->E2_CNABACR := ZC7CNABAC
							SE2->E2_CNABDES := ZC7CNABDE
							SE2->E2_DECRESC := ZC7DECRES
							SE2->E2_SDDECRE := ZC7DECRES // Ricardo Lima - 10/03/18
							SE2->E2_VALJUR  := ZC7VLRJUR
							SE2->E2_ACRESC  := ZC7ACRESC
							SE2->E2_SDACRES := ZC7ACRESC
							SE2->E2_VALLIQ  := SE2->E2_VALOR+ZC7ACRESC

							if !Empty(ZC7NDTVEN)
								SE2->E2_VENCTO  := ZC7NDTVEN
							endif
							if !Empty(ZC7NDTVCR)
								SE2->E2_VENCREA := ZC7NDTVCR
							endif
							// Ricardo Lima|03/08/18
							IF 'APROVADOR DESBLOQUEIO DE TITULOS PAGAR - BLOQUEADO' $ UPPER(ALLTRIM(sObsZC7))
								SE2->E2_RJ   := ''
								//SE2->E2_HIST := ''
								SE2->E2_DATALIB := Ddatabase
								IF SE2->E2_TIPO = 'NF'       
									cFil     := SE2->E2_FILIAL
									cSerie   := SE2->E2_PREFIXO
									cDoc     := SE2->E2_NUM
									cFornece := SE2->E2_FORNECE
									cLoja    := SE2->E2_LOJA
									SqlF050Bloq() 
									While TRB->(!EOF())	
										DBSELECTAREA("SF1")
										DbSetOrder(1)
										IF DBSEEK(cFil+cDoc+cSerie+cFornece+cLoja,.T.)          
											RecLock("SF1",.F.)
											SF1->F1_STATUS = SF1->F1_XANTSTA
											SF1->F1_XANTSTA = ''
											DBSELECTAREA("SF1")
											MsUnlock()
										ENDIF 
										SF1->(dbCloseArea())   
										TRB->(dbSkip())
									ENDDO
									TRB->(dbCloseArea())
									cFil     := ''
									cSerie   := ''
									cDoc     := ''
									cFornece := ''
									cLoja    := ''
								ENDIF
							EndIf
						endif
						if sTpApr = "000011"
							// Ricardo Lima - 20/02/18
							SE2->E2_CNABACR := ZC7CNABAC
							SE2->E2_CNABDES := ZC7CNABDE
							SE2->E2_DECRESC := ZC7DECRES
							SE2->E2_SDDECRE := ZC7DECRES // Ricardo Lima - 10/03/18
							SE2->E2_VALJUR  := ZC7VLRJUR
							SE2->E2_ACRESC  := ZC7ACRESC
							SE2->E2_SDACRES := ZC7ACRESC
							SE2->E2_VALLIQ  := SE2->E2_VALOR+ZC7ACRESC

							if !Empty(ZC7NDTVEN)
								SE2->E2_VENCTO  := ZC7NDTVEN
							endif
							if !Empty(ZC7NDTVCR)
								SE2->E2_VENCREA := ZC7NDTVCR
							endif
							// Ricardo Lima|03/08/18
							IF 'APROVADOR DESBLOQUEIO DE TITULOS PAGAR - BLOQUEADO' $ UPPER(ALLTRIM(sObsZC7))
								SE2->E2_RJ   := ''
								//SE2->E2_HIST := ''
								SE2->E2_DATALIB := Ddatabase
								IF SE2->E2_TIPO = 'NF'       
									cFil     := SE2->E2_FILIAL
									cSerie   := SE2->E2_PREFIXO
									cDoc     := SE2->E2_NUM
									cFornece := SE2->E2_FORNECE
									cLoja    := SE2->E2_LOJA
									SqlF050Bloq() 
									While TRB->(!EOF())	
										DBSELECTAREA("SF1")
										DbSetOrder(1)
										IF DBSEEK(cFil+cDoc+cSerie+cFornece+cLoja,.T.)          
											RecLock("SF1",.F.)
											SF1->F1_STATUS = SF1->F1_XANTSTA
											SF1->F1_XANTSTA = ''
											DBSELECTAREA("SF1")
											MsUnlock()
										ENDIF 
										SF1->(dbCloseArea())   
										TRB->(dbSkip())
									ENDDO
									TRB->(dbCloseArea())
									cFil     := ''
									cSerie   := ''
									cDoc     := ''
									cFornece := ''
									cLoja    := ''
								ENDIF
							EndIf
						endif
						nVlrTit := SE2->E2_VALOR
						DBSELECTAREA("SE2")
						MSUnlock()
					ENDIF
				ENDIF

			ELSEIF TpRecPag = "R" .AND. !ldDelReg
				DbSelectArea("SE1")
				DbSetorder(2)  // E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
				//IF DbSeek( FwxFilial("SE1") + cCodCli + cLojCli + cCodigo + nNumTit + nParctit + nTipTit )
				IF DbSeek( cFilZC7 + cCodCli + cLojCli + cCodigo + nNumTit + nParctit + nTipTit )
					IF lAprTit
						RecLock("SE1",.F.)
						SE1->E1_XDIVERG := 'N'
						SE1->E1_XOBSAPR := cDscObs
						if sTpApr = "000004"
							SE1->E1_ACRESC  := ZC7ACRESC
							SE1->E1_SDACRES := ZC7ACRESC
							SE1->E1_DESCFIN := ZC7CNABDE
							SE1->E1_DECRESC := ZC7DECRES
							SE1->E1_VALJUR  := ZC7VLRJUR
							if !Empty(ZC7NDTVEN)
								SE1->E1_VENCTO  := ZC7NDTVEN
							endif
							if !Empty(ZC7NDTVCR)
								SE1->E1_VENCREA := ZC7NDTVCR
							endif
						endif
						if sTpApr = "000011"
							SE1->E1_ACRESC  := ZC7ACRESC
							SE1->E1_SDACRES := ZC7ACRESC
							SE1->E1_DESCFIN := ZC7CNABDE
							SE1->E1_DECRESC := ZC7DECRES
							SE1->E1_VALJUR  := ZC7VLRJUR
							if !Empty(ZC7NDTVEN)
								SE1->E1_VENCTO  := ZC7NDTVEN
							endif
							if !Empty(ZC7NDTVCR)
								SE1->E1_VENCREA := ZC7NDTVCR
							endif
						endif
						nVlrTit := SE1->E1_VALOR
						MSUnlock()
					ENDIF
				ENDIF

			ELSEIF TpRecPag = "F" .AND. !ldDelReg // Ricardo Lima-14/12/18|CH:044314| Aprovação de Fretes

				Conout( DToC(Date()) + " " + Time() + " ADFIN046P - ADFINL46 - cOrigem " + cOrigem )
				If cOrigem = "ADLOG040P" //Everson-28/03/19. Chamado 044314.

					DbSelectArea("ZFA")			
					//Everson-19/03/19. Chamado 044314.
					ZFA->(DbSetOrder(13)) //ZFA_FILIAL, ZFA_COD
					If ZFA->(DbSeek( FWxFilial("ZFA") + Alltrim(nNumTit)  ))
						If lAprTit
							RecLock("ZFA",.F.)
							ZFA->ZFA_APRMOV := 'S'
							ZFA->ZFA_USRAPR := AllTrim( __cUserID )
							ZFA->ZFA_NOMAPR := AllTrim(UsrRetName(__cUserID))
							ZFA->ZFA_DTAPRO := Date()
							ZFA->ZFA_HRAPRO := Time()
							ZFA->ZFA_OBSAPR	:= Alltrim(FwCutOff(cDscObs,.T.)) //Everson-19/03/19. Chamado 044314.
							MSUnlock()
						Endif
					EndIf	

				ElseIf cOrigem = "ADLOG053P"

					//Everson-28/03/19. Chamado 044314.
					DbSelectArea("ZFF")			
					ZFF->(DbSetOrder(3)) //ZFF_FILIAL, ZFF_COD
					If ZFF->(DbSeek( FWxFilial("ZFF") + Alltrim(nNumTit)  ))
						If lAprTit
							RecLock("ZFF",.F.)
							ZFF->ZFF_APROVA := 'S'
							ZFF->ZFF_USRAPR := AllTrim( __cUserID )
							ZFF->ZFF_NOMAPR := AllTrim(UsrRetName(__cUserID))
							ZFF->ZFF_DTAPR  := Date()
							ZFF->ZFF_HRAPRO := Time()
							ZFF->ZFF_OBSAPR	:= Alltrim(FwCutOff(cDscObs,.T.)) //Everson-19/03/19. Chamado 044314.
							MSUnlock()
						Endif
					EndIf					
					//

				EndIf

			ENDIF

			if !ldDelReg
				if cOpc = '2' 
					if lAprTit
						lRetAcaoAR := .T.
						cMsgWBs := "Titulo Nº "+nNumTit+", Aprovado com sucesso!"
					Else
						lRetAcaoAR := .F.
						cMsgWBs := "Sua Alçada não é Suficiente para Finalizar a Aprovação, Titulo n. "+nNumTit+ " encaminhado para Aprovação de Nivel"
					Endif
				Endif

				IF !lAprTit

					if cOpc = '1'
						ApMsgInfo('Sua Alçada não é Suficiente para Finalizar a Aprovação,'+chr(13)+chr(10)+'Titulo n. '+nNumTit+ ' encaminhado para Aprovação de Nivel.','Alçada de Alteração Financeira')
					Endif

					for zc:=1 to len(aZC7Novo)

						RecLock("ZC7",.T.)

							ZC7->ZC7_FILIAL := aZC7Novo[zc,1]
							ZC7->ZC7_PREFIX := aZC7Novo[zc,2]
							ZC7->ZC7_NUM    := aZC7Novo[zc,3]
							ZC7->ZC7_PARCEL := aZC7Novo[zc,4]
							ZC7->ZC7_TIPO   := aZC7Novo[zc,5]
							ZC7->ZC7_CLIFOR := aZC7Novo[zc,6]
							ZC7->ZC7_LOJA   := aZC7Novo[zc,7]
							ZC7->ZC7_VLRBLQ := aZC7Novo[zc,8]
							ZC7->ZC7_DECRES := aZC7Novo[zc,9]
							ZC7->ZC7_TPBLQ  := aZC7Novo[zc,10]
							ZC7->ZC7_DSCBLQ := aZC7Novo[zc,11]
							ZC7->ZC7_RECPAG := aZC7Novo[zc,12]
							ZC7->ZC7_PROJET := aZC7Novo[zc,13]
							ZC7->ZC7_NDTVEN := aZC7Novo[zc,14]
							ZC7->ZC7_NDTVCR := aZC7Novo[zc,15]
							ZC7->ZC7_VLRJUR := aZC7Novo[zc,16]
							ZC7->ZC7_ACRESC := aZC7Novo[zc,17]
							ZC7->ZC7_CNABAC := aZC7Novo[zc,18]
							ZC7->ZC7_CNABDE := aZC7Novo[zc,19]
							ZC7->ZC7_REVPRJ := aZC7Novo[zc,20]
							ZC7->ZC7_NIVEL  := IIF(EMPTY(aZC7Novo[zc,22]) , SOMA1( ALLTRIM( "01" ) ) , SOMA1( ALLTRIM( aZC7Novo[zc,22] ) ) )
							ZC7->ZC7_CUSFIN := aZC7Novo[zc,23]
							ZC7->ZC7_PERCUS := aZC7Novo[zc,24]
							ZC7->ZC7_NUMCAL := aZC7Novo[zc,25]
							ZC7->ZC7_NIVSEG := aZC7Novo[zc,26]
							ZC7->ZC7_ODTVEN := aZC7Novo[zc,27]
							ZC7->ZC7_ODTVCR := aZC7Novo[zc,28]
							ZC7->ZC7_USRALT := __cUserID

						MSUnlock()

					next
					
				ENDIF

				// Envia Workflow para o Superior do Aprovador
				DbSelectArea("ZC3")
				DbSetOrder(1)
				if DbSeek( xFilial("ZC3") + __cUserID )
					cNomApr := AllTrim(UsrRetName(__cUserID))
					cCodSup := ZC3->ZC3_SUPAPR
				endif

				// Chamado n. 055321 || OS 056879 || FINANCAS || EDUARDO || 8352 || APROVADOR AUSENTE - FWNM - 05/02/2020
				aAreaZC3 := ZC3->( GetArea() )

				ZC3->( dbSetOrder(1) )
				If ZC3->( dbSeek( FWxFilial("ZC3")+cCodSup) )
				
					If ZC3->ZC3_APRATV == "1" // Ausente
						
						cDscObs := '[Ausente] - Aprovado automaticamente ' + cDscObs

						// Aprovo nivel ausente
						RecLock("ZC7",.F.)
							
							ZC7->ZC7_USRAPR := AllTrim( cCodSup )
							ZC7->ZC7_NOMAPR := AllTrim(UsrRetName(cCodSup))
							ZC7->ZC7_DTAPR  := Date()
							ZC7->ZC7_HRAPR  := Time()
							ZC7->ZC7_OBS    := cDscObs

							If lVldApv
								ZC7->ZC7_EFEAPR := 'S'
								lAprTit := .t.
							EndIf

						ZC7->( msUnlock() )

						// Se ultimo nivel ele mesmo aprova titulo automaticamente por ausencia
						If ZC3->ZC3_CODUSU == ZC3->ZC3_SUPAPR 

							DbSelectArea("SE2")
							DbSetorder(6)  // E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
							If dbSeek( cFilZC7 + cCodCli + cLojCli + cCodigo + nNumTit + nParctit + nTipTit ) 
								RecLock("SE2",.F.)
									SE2->E2_XDIVERG := 'N'
									SE2->E2_XOBSAPR := Alltrim(cDscObs)

									If sTpApr = "000004"
										SE2->E2_CNABACR := ZC7CNABAC
										SE2->E2_CNABDES := ZC7CNABDE
										SE2->E2_DECRESC := ZC7DECRES
										SE2->E2_SDDECRE := ZC7DECRES
										SE2->E2_VALJUR  := ZC7VLRJUR
										SE2->E2_ACRESC  := ZC7ACRESC
										SE2->E2_SDACRES := ZC7ACRESC
										SE2->E2_VALLIQ  := SE2->E2_VALOR+ZC7ACRESC

										If !Empty(ZC7NDTVEN)
											SE2->E2_VENCTO  := ZC7NDTVEN
										EndIf

										If !Empty(ZC7NDTVCR)
											SE2->E2_VENCREA := ZC7NDTVCR
										EndIf

										If 'APROVADOR DESBLOQUEIO DE TITULOS PAGAR - BLOQUEADO' $ UPPER(ALLTRIM(sObsZC7))
											SE2->E2_RJ   := ''
											SE2->E2_DATALIB := Ddatabase
											If SE2->E2_TIPO == 'NF'       
												cFil     := SE2->E2_FILIAL
												cSerie   := SE2->E2_PREFIXO
												cDoc     := SE2->E2_NUM
												cFornece := SE2->E2_FORNECE
												cLoja    := SE2->E2_LOJA
				
												SqlF050Bloq() 
				
												Do While TRB->( !EOF() ) 	
													DBSELECTAREA("SF1")
													DbSetOrder(1)
													IF DBSEEK(cFil+cDoc+cSerie+cFornece+cLoja,.T.)          
														RecLock("SF1",.F.)
															SF1->F1_STATUS = SF1->F1_XANTSTA
															SF1->F1_XANTSTA = ''
														DBSELECTAREA("SF1")
														MsUnlock()
													ENDIF 
													SF1->(dbCloseArea())   
													TRB->(dbSkip())
												ENDDO
				
												TRB->(dbCloseArea())
			
												cFil     := ''
												cSerie   := ''
												cDoc     := ''
												cFornece := ''
												cLoja    := ''
											ENDIF
										EndIf
									endif

									If sTpApr = "000011"
										SE2->E2_CNABACR := ZC7CNABAC
										SE2->E2_CNABDES := ZC7CNABDE
										SE2->E2_DECRESC := ZC7DECRES
										SE2->E2_SDDECRE := ZC7DECRES
										SE2->E2_VALJUR  := ZC7VLRJUR
										SE2->E2_ACRESC  := ZC7ACRESC
										SE2->E2_SDACRES := ZC7ACRESC
										SE2->E2_VALLIQ  := SE2->E2_VALOR+ZC7ACRESC

										If !Empty(ZC7NDTVEN)
											SE2->E2_VENCTO  := ZC7NDTVEN
										EndIf

										If !Empty(ZC7NDTVCR)
											SE2->E2_VENCREA := ZC7NDTVCR
										EndIf

										If 'APROVADOR DESBLOQUEIO DE TITULOS PAGAR - BLOQUEADO' $ UPPER(ALLTRIM(sObsZC7))
											SE2->E2_RJ   := ''
											SE2->E2_DATALIB := Ddatabase
											If SE2->E2_TIPO == 'NF'       
												cFil     := SE2->E2_FILIAL
												cSerie   := SE2->E2_PREFIXO
												cDoc     := SE2->E2_NUM
												cFornece := SE2->E2_FORNECE
												cLoja    := SE2->E2_LOJA
				
												SqlF050Bloq() 
				
												Do While TRB->( !EOF() ) 	
													DBSELECTAREA("SF1")
													DbSetOrder(1)
													IF DBSEEK(cFil+cDoc+cSerie+cFornece+cLoja,.T.)          
														RecLock("SF1",.F.)
															SF1->F1_STATUS = SF1->F1_XANTSTA
															SF1->F1_XANTSTA = ''
														DBSELECTAREA("SF1")
														MsUnlock()
													ENDIF 
													SF1->(dbCloseArea())   
													TRB->(dbSkip())
												ENDDO
				
												TRB->(dbCloseArea())
			
												cFil     := ''
												cSerie   := ''
												cDoc     := ''
												cFornece := ''
												cLoja    := ''
											ENDIF
										EndIf
									endif

								nVlrTit := SE2->E2_VALOR

								DBSELECTAREA("SE2")
								MSUnlock()
							ENDIF
						
						Else
					
							// Gero proximo nivel
							for zc:=1 to len(aZC7Novo)

								cZC7Nivel  := Soma1(ZC7->ZC7_NIVEL)//IIF(EMPTY(aZC7Novo[zc,22]) , SOMA1( ALLTRIM( "01" ) ) , SOMA1( ALLTRIM( aZC7Novo[zc,22] ) ) )

								RecLock("ZC7",.T.)

									ZC7->ZC7_FILIAL := aZC7Novo[zc,1]
									ZC7->ZC7_PREFIX := aZC7Novo[zc,2]
									ZC7->ZC7_NUM    := aZC7Novo[zc,3]
									ZC7->ZC7_PARCEL := aZC7Novo[zc,4]
									ZC7->ZC7_TIPO   := aZC7Novo[zc,5]
									ZC7->ZC7_CLIFOR := aZC7Novo[zc,6]
									ZC7->ZC7_LOJA   := aZC7Novo[zc,7]
									ZC7->ZC7_VLRBLQ := aZC7Novo[zc,8]
									ZC7->ZC7_DECRES := aZC7Novo[zc,9]
									ZC7->ZC7_TPBLQ  := aZC7Novo[zc,10]
									ZC7->ZC7_DSCBLQ := aZC7Novo[zc,11]
									ZC7->ZC7_RECPAG := aZC7Novo[zc,12]
									ZC7->ZC7_PROJET := aZC7Novo[zc,13]
									ZC7->ZC7_NDTVEN := aZC7Novo[zc,14]
									ZC7->ZC7_NDTVCR := aZC7Novo[zc,15]
									ZC7->ZC7_VLRJUR := aZC7Novo[zc,16]
									ZC7->ZC7_ACRESC := aZC7Novo[zc,17]
									ZC7->ZC7_CNABAC := aZC7Novo[zc,18]
									ZC7->ZC7_CNABDE := aZC7Novo[zc,19]
									ZC7->ZC7_REVPRJ := aZC7Novo[zc,20]
									ZC7->ZC7_NIVEL  := cZC7Nivel
									ZC7->ZC7_CUSFIN := aZC7Novo[zc,23]
									ZC7->ZC7_PERCUS := aZC7Novo[zc,24]
									ZC7->ZC7_NUMCAL := aZC7Novo[zc,25]
									ZC7->ZC7_NIVSEG := aZC7Novo[zc,26]
									ZC7->ZC7_ODTVEN := aZC7Novo[zc,27]
									ZC7->ZC7_ODTVCR := aZC7Novo[zc,28]
									ZC7->ZC7_USRALT := __cUserID

								MSUnlock()

							next

						EndIf
					
					EndIf

				EndIf

				RestArea( aAreaZC3 )
				//
				
				if !empty(cCodSup) .and. !(Alltrim(sTpApr) $'000006/000007/000008/000009/000010') // Ricardo Lima-14/12/18|CH:044314| Aprovação de Fretes //Everson - 12/12/2019 - Chamado 029058.
					if sTpApr = "000001"
						cAssunto := "Aprovação do Titulo de PA"
					elseif sTpApr = "000004"
						cAssunto := "Aprovação de Alçada de Titulo"
					elseif sTpApr = "000005"
						cAssunto := "Aprovação de Nivel de Segurança"
					elseif sTpApr = "000011"
						cAssunto := "Aprovação de Desbloqueio de Titulo"	
					endif

					cMensagem := u_ADFINW46(  cCodigo , nNumTit , nParctit , cCodCli , cLojCli , nVlrTit , cNomApr , sTpApr , lAprTit , 'A' , '' )
					If lEnvWFCA
						u_F050EnvWF( cAssunto , cMensagem , UsrRetMail(cCodSup) , '' )
					Endif
				endif

				cFilZC7     := Space(2)
				cCodigo		:= SPACE(3)
				nNumTit		:= SPACE(9)
				nParctit	:= SPACE(2)
				nTipTit     := SPACE(3)
				cCodCli		:= SPACE(6)
				cLojCli 	:= SPACE(2)
				cCodSup 	:= ""
			Endif	

		Else
		// FWNM - INTEGRACAO PROJETOS DE INVESTIMENTOS (AF8)

			// Define fase do projeto
			//	cNewFase := AltFase() // Inibido conforme diretriz Sr. Eduardo Sta Maria em 21/12/2017
			cNewFase := GetMV("MV_#FASINC",,"03")
			if cOpc = '1'
				cRevPrj := AllTrim(TMPZC7->ZC7_REVPRJ)
			Else
				// Ricardo Lima-22/01/2019	
				dbSelectArea("ZC7")
				dbGoto(val( cRecnoZC ))
				cRevPrj := AllTrim(ZC7->ZC7_REVPRJ)
				cCodPrj := ZC7->ZC7_PROJET
				cRevPrj := ZC7->ZC7_REVPRJ
			Endif
			//

			If AllTrim(cNewFase) <> "INVALIDO"
			
				// Chamado n. 053839 || OS 055224 || CONTROLADORIA || DAIANE || (16) || REDUCAO VLR PRJ - fwnm - 06/12/2019
				If cOpc == '1' // Protheus
					nVlrBlq := TMPZC7->ZC7_VLRBLQ
				Else // APP
					nVlrBlq := ZC7->ZC7_VLRBLQ
				EndIf

				If nVlrBlq < 0 // Suplementaçao negativa

					AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
					If AF8->( dbSeek( FWxFilial("AF8") + cCodPrj ) )

						nVlFuturo := AF8->AF8_XVALOR - Abs(nVlrBlq)
						nConsumo  := u_ADCOM017P(AF8->AF8_PROJET,"BROWSE") 
					
						If nVlFuturo < nConsumo

							lTudoOk := .F.

							If cOpc == '1'
								Aviso("ADFIN046-07", "Esta suplementação negativa deixará o projeto negativo! Valor informado não permitido...", {"OK"}, 3, "Suplementação Negativa- Redução valor projeto")
							Else
								lRetAcaoAR := .F.
								cMsgWBs := "Esta suplementação negativa deixará o projeto negativo (Consumo maior que valor projeto)! Aprovação não será realizada..." +;
								" \nValor Projeto: R$" + Transform(AF8->AF8_XVALOR,"@E 999,999,999,999.99") +;
								" \nConsumo Projeto: R$" + Transform(nConsumo,"@E 999,999,999,999.99") +;
								" \nSaldo Atual: R$" + Transform(AF8->AF8_XVALOR-nConsumo,"@E 999,999,999,999.99") +;
								" \nValor Futuro Projeto: R$" + Transform(nVlFuturo,"@E 999,999,999,999.99") "

								/*
								cMsgWBs := "Esta suplementação negativa deixará o projeto negativo (Consumo maior que valor projeto)! Aprovação não será realizada..." + chr(13) + CHR(10) +;
								"Valor Projeto: " + Transform(AF8->AF8_XVALOR,"@E 999,999,999,999.99") + chr(13) + chr(10) +;
								"Consumo Projeto: " + Transform(nConsumo,"@E 999,999,999,999.99") + chr(13) + chr(10) +;
								"Saldo Atual: " + Transform(AF8->AF8_XVALOR-nConsumo,"@E 999,999,999,999.99") + chr(13) + chr(10) +;
								"Valor Futuro Projeto: " + Transform(nVlFuturo,"@E 999,999,999,999.99") "
								*/
//								cMsgWBs := "Esta suplementação negativa deixará o projeto negativo! Aprovação não será realizada..."
							EndIf

						EndIf

					EndIf
					
				EndIf
				//
			
				If lTudoOk
				
					ZC7->( dbSetOrder(3) ) // ZC7_FILIAL+ZC7_PROJET
					If ZC7->( dbSeek( FWxFilial("ZC7") + cCodPrj + cRevPrj ) )
				
						// Chamado n. 046284 - FWNM
						Do While ZC7->( !EOF() ) .and. ZC7->ZC7_FILIAL == FWxFilial("ZC7") .and. ZC7->ZC7_PROJET == cCodPrj .and. ZC7->ZC7_REVPRJ == cRevPrj
				
							If AllTrim(ZC7->ZC7_USRAPR) == AllTrim( __cUserID ) // Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 29/04/2019
				
								If Empty(ZC7->ZC7_REPROV)

									RecLock("ZC7", .f.)

										ZC7->ZC7_USRAPR := AllTrim( __cUserID )
										ZC7->ZC7_NOMAPR := AllTrim(UsrRetName(__cUserID))
										ZC7->ZC7_DTAPR  := msDate()
										ZC7->ZC7_HRAPR  := Time()
										ZC7->ZC7_OBS    := "[APROVADO] " + cDscObs

									ZC7->( msUnlock() )
									
									// Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 30/04/2019
									If cOpc = '2'
										lRetAcaoAR := .T.
									Endif
									
								EndIf

							EndIf
		
							ZC7->( dbSkip() )
				
						EndDo
						//
				
					ENDIF

					// Libera o Projeto de Investimento para uso
					
					// Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 29/04/2019
					// Define Aprovador / Vistador
					lVistador := .t.
					ZCX->( dbSetOrder(1) ) // ZCX_FILIAL + ZCX_USER + ZCX_CODIGO
					If ZCX->( dbSeek( FWxFilial("ZCX")+__cUserID ) )
						lVistador := .f.
					EndIf
			
					If !lVistador
					
						lZC7OK := ChkAprov(cCodPrj, cRevPrj)
						If lZC7OK
						
							AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
							If AF8->( dbSeek( FWxFilial("AF8") + cCodPrj ) )
								
								cOldFase := AF8->AF8_FASE // Chamado n. 049774 || OS 051078 || ENGENHARIA || SILVANA || 8406 || PROJETO ENCERRADO - FWNM - 25/06/2019
								
								RecLock("AF8", .f.)
			
									AF8->AF8_FASE   := cNewFase
			
									// Ricardo Lima-22/01/2019	
									//dbSelectArea("ZC7")
									//dbGoto(val( cRecnoZC ))
									
									If AllTrim(cRevPrj) <> "0001"
										
										if cOpc = '1'
											If cOldFase == cFaseRej // Chamado n. 049774 || OS 051078 || ENGENHARIA || SILVANA || 8406 || PROJETO ENCERRADO - FWNM - 25/06/2019
												AF8->AF8_XVALOR := TMPZC7->ZC7_VLRBLQ
											Else
												AF8->AF8_XVALOR := AF8->AF8_XVALOR + TMPZC7->ZC7_VLRBLQ
											EndIf
										Else 
											dbSelectArea("ZC7")
											dbGoto(val( cRecnoZC ))
											If cOldFase == cFaseRej // Chamado n. 049774 || OS 051078 || ENGENHARIA || SILVANA || 8406 || PROJETO ENCERRADO - FWNM - 25/06/2019
												AF8->AF8_XVALOR := ZC7->ZC7_VLRBLQ
											Else
												AF8->AF8_XVALOR := AF8->AF8_XVALOR + ZC7->ZC7_VLRBLQ
											EndIf
										Endif	
										
										EndIf
										
									EndIf
				
								AF8->( msUnLock() )
							
							EndIf
						
						EndIf
		
						if cOpc = '1'
							If lZC7OK
								Aviso("ADFIN046-03", "Projeto aprovado com sucesso e liberado para uso!" , {"OK"}, 3, "Aprovação - Projetos Investimentos")
							Else
								Aviso("ADFIN046-03", "Projeto aprovado com sucesso!" , {"OK"}, 3, "Aprovação - Projetos Investimentos")
							EndIf
						Else
							If lVistador
								cMsgWBs := "Projeto aprovado"
							Else
								If lZC7OK 
									cMsgWBs := "Projeto aprovado com sucesso e liberado para uso"
								Else
									cMsgWBs := "Projeto aprovado com sucesso"
								EndIf
							EndIf
						Endif
		
						// Envia email de aviso de aprovação para solicitante
						AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
						If AF8->( dbSeek( FWxFilial("AF8") + cCodPrj ) )

							//If cOpc == "1"
								aDadWF := {}
								cMail  := ""
								cMail  := UsrRetMail(AF8->AF8_XUSER)
								
								// Chamado n. 053243 || OS 054600 || CONTROLADORIA || DAIANE || (11) || WOKFLOW PROJETOS - FWNM - 08/11/2019
								If Left(cCodPrj,2) == "03" // Projetos SC
									If !Empty(cMail)
										cMail  += ";" + GetMV("MV_#AF8MAI",,"daiane.moreira@adoro.com.br")
									Else
										cMail  := GetMV("MV_#AF8MAI",,"daiane.moreira@adoro.com.br")
									EndIf
								EndIf
								
								aAdd( aDadWF, { cCodPrj, cRevPrj, AllTrim( __cUserID ), AllTrim(UsrRetName(__cUserID)), msDate(), Time(), "[APROVADO] " + cDscObs, cMail, AllTrim(AF8->AF8_DESCRI), AF8->AF8_XUSER } )
								u_ADPRJ004P(aDadWF, "APROVACAO") //ALTERACAO WILLIAM COSTA ERRO NA FUNCAO ENVIAWF
							//EndIf
							
						EndIf
						
					EndIf

				EndIf

			EndIf

	END TRANSACTION

	RestArea(aArea)

Return( .T. )

/*{Protheus.doc} Static Function SQLF050BLOQ
	Gera arquivo de trabalho
	@type  Function
	@author Ricardo Lima
	@since 14/11/2017
	@version 01
	@history Chamado 038609
*/

STATIC FUNCTION SqlF050Bloq()  

	BeginSQL Alias "TRB"
		%NoPARSER% 
		SELECT F1_FILIAL,F1_DOC,F1_FORNECE,F1_LOJA,F1_TIPO,F1_STATUS
		FROM %Table:SF1%
		WHERE F1_FILIAL   = %exp:cFil%
		AND F1_SERIE    = %exp:cSerie%
		AND F1_DOC      = %exp:cDoc%
		AND F1_FORNECE  = %exp:cFornece%
		AND F1_LOJA     = %exp:cLoja%
		AND D_E_L_E_T_ <> '*'
	EndSQl             

RETURN(NIL)

/*{Protheus.doc} Static Function FMONTATMPZC7
	Central Aprovacao
	@type  Function
	@author Ricardo Lima
	@since 14/11/2017
	@version 01
	@history Chamado 038609
*/

STATIC Function fMontaTMPZC7( pFilial , ZC7PREFIX , ZC7NUM , ZC7CLIFOR , ZC7LOJA, ZC7PROJET, ZC7PARCEL, ZC7TIPO )

	LOCAL cArq		:= CriaTrab( NIL, .F.)
	PRIVATE aCampos := {}
	Default ZC7PROJET := ""

	If Empty(ZC7PROJET)
		// Ricardo Lima - 13/12/2018
		IF sTpApr = '000001' .or. (Alltrim(sTpApr) $'000006/000007/000008/000009/000010') // Ricardo Lima-14/12/18|CH:044314| Aprovação de Fretes //Everson - 12/12/2019 - Chamado 029058.	
			aCampos := { {"ZC7_PREFIX"	, "C", 3, 0}, ;
			{"ZC7_NUM"	    , "C", 9, 0} , ;
			{"ZC7_PARCEL"	, "C", 2, 4} , ;
			{"ZC7_CLIFOR"	, "C", 6, 4} , ;
			{"ZC7_LOJA"	, "C", 2, 4} , ;
			{"ZC7_VLRBLQ"	, "N",14, 2} , ;
			{"ZC7_TPBLQ"	, "C", 6, 4} , ;
			{"ZC7_DSCBLQ"	, "C", 50, 0}, ;
			{"ZC7_USRAPR"	, "C", 6, 0} , ;
			{"ZC7_NOMAPR"	, "C", 15, 0}, ;
			{"ZC7_DTAPR"	, "D", 8, 0} , ;
			{"ZC7_HRAPR"	, "C", 8, 0} , ;
			{"ZC7_OBS"	    , "C", 254, 0} }
		ElseIf sTpApr = '000004'
			if 'APROVADOR DESBLOQUEIO DE TITULOS PAGAR - BLOQUEADO' $ cDscTpBlq
				aCampos := { {"ZC7_PREFIX"	, "C", 3, 0}, ;
				{"ZC7_NUM"	    , "C", 9, 0} , ;
				{"ZC7_PARCEL"	, "C", 2, 4} , ;
				{"ZC7_CLIFOR"	, "C", 6, 4} , ;
				{"ZC7_LOJA"	    , "C", 2, 4} , ;
				{"ZC7_VLRBLQ"	, "N", 14, 2}, ;
				{"ZC7_TPBLQ"	, "C", 6, 4} , ;
				{"ZC7_DSCBLQ"	, "C", 50, 0}, ;
				{"ZC7_USRAPR"	, "C", 6, 0} , ;
				{"ZC7_NOMAPR"	, "C", 15, 0}, ;
				{"ZC7_DTAPR"	, "D", 8, 0} , ;
				{"ZC7_HRAPR"	, "C", 8, 0} , ;
				{"ZC7_OBS"	    , "C", 254, 0} }
			Elseif 'Dt Vencimento' $ cDscTpBlq
				aCampos := { {"ZC7_PREFIX"	, "C", 3, 0}, ;
				{"ZC7_NUM"	    , "C", 9, 0} , ;
				{"ZC7_PARCEL"	, "C", 2, 4} , ;
				{"ZC7_CLIFOR"	, "C", 6, 4} , ;
				{"ZC7_LOJA"	, "C", 2, 4} , ;
				{"ZC7_VLRBLQ"	, "N", 14, 2}, ;
				{"ZC7_TPBLQ"	, "C", 6, 4} , ;
				{"ZC7_DSCBLQ"	, "C", 50, 0}, ;
				{"ZC7_NDTVEN"	, "D", 8, 0} , ;
				{"ZC7_NDTVCR"	, "D", 8, 0} , ;
				{"ZC7_USRAPR"	, "C", 6, 0} , ;
				{"ZC7_NOMAPR"	, "C", 15, 0}, ;
				{"ZC7_DTAPR"	, "D", 8, 0} , ;
				{"ZC7_HRAPR"	, "C", 8, 0} , ;
				{"ZC7_OBS"	    , "C", 254, 0}, ;
				{"ZC7_ODTVEN"	, "D", 8, 0} , ;
				{"ZC7_ODTVCR"	, "D", 8, 0}  }
			Elseif 'Juros' $ cDscTpBlq
				aCampos := { {"ZC7_PREFIX"	, "C", 3, 0}, ;
				{"ZC7_NUM"	    , "C", 9, 0} , ;
				{"ZC7_PARCEL"	, "C", 2, 4} , ;
				{"ZC7_CLIFOR"	, "C", 6, 4} , ;
				{"ZC7_LOJA"	, "C", 2, 4} , ;
				{"ZC7_VLRBLQ"	, "N", 14, 2}, ;
				{"ZC7_TPBLQ"	, "C", 6, 4} , ;
				{"ZC7_DSCBLQ"	, "C", 50, 0}, ;
				{"ZC7_VLRJUR"	, "N", 14, 4}, ;
				{"ZC7_USRAPR"	, "C", 6, 0} , ;
				{"ZC7_NOMAPR"	, "C", 15, 0}, ;
				{"ZC7_DTAPR"	, "D", 8, 0} , ;
				{"ZC7_HRAPR"	, "C", 8, 0} , ;
				{"ZC7_OBS"	    , "C", 254, 0}}
			Elseif 'Acrescimo' $ cDscTpBlq
				aCampos := { {"ZC7_PREFIX"	, "C", 3, 0}, ;
				{"ZC7_NUM"	    , "C", 9, 0} , ;
				{"ZC7_PARCEL"	, "C", 2, 4} , ;
				{"ZC7_CLIFOR"	, "C", 6, 4} , ;
				{"ZC7_LOJA"	, "C", 2, 4} , ;
				{"ZC7_VLRBLQ"	, "N", 14, 2}, ;
				{"ZC7_TPBLQ"	, "C", 6, 4} , ;
				{"ZC7_DSCBLQ"	, "C", 50, 0}, ;
				{"ZC7_ACRESC"	, "N", 14, 4}, ;
				{"ZC7_USRAPR"	, "C", 6, 0} , ;
				{"ZC7_NOMAPR"	, "C", 15, 0}, ;
				{"ZC7_DTAPR"	, "D", 8, 0} , ;
				{"ZC7_HRAPR"	, "C", 8, 0} , ;
				{"ZC7_OBS"	    , "C", 254, 0}}
			Elseif 'Descrescimo' $ cDscTpBlq
				aCampos := { {"ZC7_PREFIX"	, "C", 3, 0}, ;
				{"ZC7_NUM"	    , "C", 9, 0} , ;
				{"ZC7_PARCEL"	, "C", 2, 4} , ;
				{"ZC7_CLIFOR"	, "C", 6, 4} , ;
				{"ZC7_LOJA"	, "C", 2, 4} , ;
				{"ZC7_VLRBLQ"	, "N", 14, 2}, ;
				{"ZC7_TPBLQ"	, "C", 6, 4} , ;
				{"ZC7_DSCBLQ"	, "C", 50, 0}, ;
				{"ZC7_DECRES"	, "N", 14, 4}, ;
				{"ZC7_USRAPR"	, "C", 6, 0} , ;
				{"ZC7_NOMAPR"	, "C", 15, 0}, ;
				{"ZC7_DTAPR"	, "D", 8, 0} , ;
				{"ZC7_HRAPR"	, "C", 8, 0} , ;
				{"ZC7_OBS"	    , "C", 254, 0} }
			Elseif 'Desconto' $ cDscTpBlq
				aCampos := { {"ZC7_PREFIX"	, "C", 3, 0}, ;
				{"ZC7_NUM"	    , "C", 9, 0} , ;
				{"ZC7_PARCEL"	, "C", 2, 4} , ;
				{"ZC7_CLIFOR"	, "C", 6, 4} , ;
				{"ZC7_LOJA"	, "C", 2, 4} , ;
				{"ZC7_VLRBLQ"	, "N", 14, 2}, ;
				{"ZC7_TPBLQ"	, "C", 6, 4} , ;
				{"ZC7_DSCBLQ"	, "C", 50, 0}, ;
				{"ZC7_CNABDE"	, "N", 14, 4}, ;
				{"ZC7_USRAPR"	, "C", 6, 0} , ;
				{"ZC7_NOMAPR"	, "C", 15, 0}, ;
				{"ZC7_DTAPR"	, "D", 8, 0} , ;
				{"ZC7_HRAPR"	, "C", 8, 0} , ;
				{"ZC7_OBS"	    , "C", 254, 0} }
			Else
				aCampos := { {"ZC7_PREFIX"	, "C", 3, 0}, ;
				{"ZC7_NUM"	    , "C", 9, 0} , ;
				{"ZC7_PARCEL"	, "C", 2, 4} , ;
				{"ZC7_CLIFOR"	, "C", 6, 4} , ;
				{"ZC7_LOJA"	, "C", 2, 4} , ;
				{"ZC7_VLRBLQ"	, "N", 14, 2}, ;
				{"ZC7_TPBLQ"	, "C", 6, 4} , ;
				{"ZC7_DSCBLQ"	, "C", 50, 0}, ;
				{"ZC7_ACRESC"	, "N", 14, 4}, ;
				{"ZC7_CNABAC"	, "N", 14, 4}, ;
				{"ZC7_CNABDE"	, "N", 14, 4}, ;
				{"ZC7_DECRES"	, "N", 14, 4}, ;
				{"ZC7_VLRJUR"	, "N", 14, 4}, ;
				{"ZC7_CUSFIN"	, "N", 14, 4}, ;
				{"ZC7_NDTVEN"	, "D", 8, 0} , ;
				{"ZC7_NDTVCR"	, "D", 8, 0} , ;
				{"ZC7_USRAPR"	, "C", 6, 0} , ;
				{"ZC7_NOMAPR"	, "C", 15, 0}, ;
				{"ZC7_DTAPR"	, "D", 8, 0} , ;
				{"ZC7_HRAPR"	, "C", 8, 0} , ;
				{"ZC7_OBS"	    , "C", 254, 0}, ;
				{"ZC7_ODTVEN"	, "D", 8, 0} , ;
				{"ZC7_ODTVCR"	, "D", 8, 0}  }
			Endif			 
		ElseIf sTpApr = '000005'
			aCampos := { {"ZC7_PREFIX"	, "C", 3, 0}, ;
			{"ZC7_NUM"	    , "C", 9, 0} , ;
			{"ZC7_PARCEL"	, "C", 2, 4} , ;
			{"ZC7_CLIFOR"	, "C", 6, 4} , ;
			{"ZC7_LOJA"	    , "C", 2, 4} , ;
			{"ZC7_VLRBLQ"	, "N", 14, 2}, ;
			{"ZC7_TPBLQ"	, "C", 6, 4} , ;
			{"ZC7_DSCBLQ"	, "C", 50, 0}, ;
			{"ZC7_USRAPR"	, "C", 6, 0} , ;
			{"ZC7_NOMAPR"	, "C", 15, 0}, ;
			{"ZC7_DTAPR"	, "D", 8, 0} , ;
			{"ZC7_HRAPR"	, "C", 8, 0} , ;
			{"ZC7_OBS"	    , "C", 254, 0} }
		ElseIf sTpApr = '000011'
			
			aCampos := { {"ZC7_PREFIX"	, "C", 3, 0}, ;
						 {"ZC7_NUM"	    , "C", 9, 0} , ;
						 {"ZC7_PARCEL"	, "C", 2, 4} , ;
						 {"ZC7_CLIFOR"	, "C", 6, 4} , ;
						 {"ZC7_LOJA"	, "C", 2, 4} , ;
						 {"ZC7_VLRBLQ"	, "N", 14, 2}, ;
						 {"ZC7_TPBLQ"	, "C", 6, 4} , ;
						 {"ZC7_DSCBLQ"	, "C", 50, 0}, ;
						 {"ZC7_USRAPR"	, "C", 6, 0} , ;
						 {"ZC7_NOMAPR"	, "C", 15, 0}, ;
						 {"ZC7_DTAPR"	, "D", 8, 0} , ;
					 	 {"ZC7_HRAPR"	, "C", 8, 0} , ;
					 	 {"ZC7_OBS"	    , "C", 254, 0} }
		//INICIO Ticket  429    - Abel Babini   - 09/10/2020 - Tratamento de bloqueios Painel de pagamento
		Else
			
			aCampos := { {"ZC7_PREFIX"	, "C", 3, 0}, ;
						 {"ZC7_NUM"	    , "C", 9, 0} , ;
						 {"ZC7_PARCEL"	, "C", 2, 4} , ;
						 {"ZC7_CLIFOR"	, "C", 6, 4} , ;
						 {"ZC7_LOJA"	, "C", 2, 4} , ;
						 {"ZC7_VLRBLQ"	, "N", 14, 2}, ;
						 {"ZC7_TPBLQ"	, "C", 6, 4} , ;
						 {"ZC7_DSCBLQ"	, "C", 50, 0}, ;
						 {"ZC7_USRAPR"	, "C", 6, 0} , ;
						 {"ZC7_NOMAPR"	, "C", 15, 0}, ;
						 {"ZC7_DTAPR"	, "D", 8, 0} , ;
					 	 {"ZC7_HRAPR"	, "C", 8, 0} , ;
					 	 {"ZC7_OBS"	    , "C", 254, 0} }
				
		EndIf
		//FIM Ticket  429    - Abel Babini   - 09/10/2020 - Tratamento de bloqueios Painel de pagamento

		// FWNM - INTEGRACAO PROJETOS DE INVESTIMENTOS (AF8)
	Else
		aCampos := { {"ZC7_REVPRJ"	, "C", TamSX3("AF8_PROJET")[1], 0},;
		{"ZC7_VLRBLQ"	, "N", TamSX3("ZC7_VLRBLQ")[1], TamSX3("ZC7_VLRBLQ")[2]},;
		{"AFE_USERF"	, "C", 30, 0},;
		{"AFE_DATAF"	, "D", 10, 0},;
		{"AFE_HORAF"	, "C", 10, 0},;
		{"AFE_MEMO"	    , "C", 50, 0} }

	EndIf

	If ( SELECT("TMPZC7" ) !=  0 )
		dbSelectArea("TMPZC7")
		dbCloseArea()
	Endif

	dbCreate( cArq, aCampos )
	dbUseArea( .T., , cArq, "TMPZC7", .F., .F.)

	If Empty(ZC7PROJET)

		dbSelectArea("ZC7")
		dbSetOrder( 2 )  // ZC7_FILIAL+ZC7_CLIFOR+ZC7_LOJA+ZC7_PREFIX+ZC7_NUM+ZC7_PARCEL
		If dbSeek( pFilial + ZC7CLIFOR + ZC7LOJA + ZC7PREFIX + ZC7NUM + ZC7PARCEL + ZC7TIPO )
			While !EOF() .AND. xFilial("ZC7") == pFilial .AND. ZC7->ZC7_PREFIX == ZC7PREFIX .AND. ZC7->ZC7_NUM = ZC7NUM .AND. ZC7->ZC7_CLIFOR = ZC7CLIFOR .AND. ZC7_PARCEL = ZC7PARCEL .AND. ZC7_TIPO = ZC7TIPO
				dbSelectArea("TMPZC7")
				RecLock("TMPZC7", .T.)
				// Ricardo Lima-13/12/2018
				If ZC7->ZC7_TPBLQ = '000005'
					lTpBlNs := .T.
				EndIf
				IF sTpApr = '000001' .or. (Alltrim(sTpApr) $'000006/000007/000008/000009/000010') // Ricardo Lima-14/12/18|CH:044314| Aprovação de Fretes	//Everson - 12/12/2019. Chamado 029058.
					TMPZC7->ZC7_PREFIX := ZC7->ZC7_PREFIX
					TMPZC7->ZC7_NUM    := ZC7->ZC7_NUM
					TMPZC7->ZC7_PARCEL := ZC7->ZC7_PARCEL
					TMPZC7->ZC7_CLIFOR := ZC7->ZC7_CLIFOR
					TMPZC7->ZC7_LOJA   := ZC7->ZC7_LOJA
					TMPZC7->ZC7_VLRBLQ := ZC7->ZC7_VLRBLQ
					TMPZC7->ZC7_TPBLQ  := ZC7->ZC7_TPBLQ
					TMPZC7->ZC7_DSCBLQ := ZC7->ZC7_DSCBLQ
					TMPZC7->ZC7_USRAPR := ZC7->ZC7_USRAPR
					TMPZC7->ZC7_NOMAPR := ZC7->ZC7_NOMAPR
					TMPZC7->ZC7_DTAPR  := ZC7->ZC7_DTAPR
					TMPZC7->ZC7_HRAPR  := ZC7->ZC7_HRAPR
					TMPZC7->ZC7_OBS    := ZC7->ZC7_OBS	
				ElseIF sTpApr = '000004'
					if 'APROVADOR DESBLOQUEIO DE TITULOS PAGAR - BLOQUEADO' $ cDscTpBlq
						TMPZC7->ZC7_PREFIX := ZC7->ZC7_PREFIX
						TMPZC7->ZC7_NUM	   := ZC7->ZC7_NUM
						TMPZC7->ZC7_PARCEL := ZC7->ZC7_PARCEL
						TMPZC7->ZC7_CLIFOR := ZC7->ZC7_CLIFOR
						TMPZC7->ZC7_LOJA   := ZC7->ZC7_LOJA
						TMPZC7->ZC7_VLRBLQ := ZC7->ZC7_VLRBLQ
						TMPZC7->ZC7_TPBLQ  := ZC7->ZC7_TPBLQ
						TMPZC7->ZC7_DSCBLQ := ZC7->ZC7_DSCBLQ
						TMPZC7->ZC7_USRAPR := ZC7->ZC7_USRAPR
						TMPZC7->ZC7_NOMAPR := ZC7->ZC7_NOMAPR
						TMPZC7->ZC7_DTAPR  := ZC7->ZC7_DTAPR
						TMPZC7->ZC7_HRAPR  := ZC7->ZC7_HRAPR
						TMPZC7->ZC7_OBS    := ZC7->ZC7_OBS	
					Elseif 'Dt Vencimento' $ cDscTpBlq
						TMPZC7->ZC7_PREFIX := ZC7->ZC7_PREFIX
						TMPZC7->ZC7_NUM	   := ZC7->ZC7_NUM
						TMPZC7->ZC7_PARCEL := ZC7->ZC7_PARCEL
						TMPZC7->ZC7_CLIFOR := ZC7->ZC7_CLIFOR
						TMPZC7->ZC7_LOJA   := ZC7->ZC7_LOJA
						TMPZC7->ZC7_VLRBLQ := ZC7->ZC7_VLRBLQ
						TMPZC7->ZC7_TPBLQ  := ZC7->ZC7_TPBLQ
						TMPZC7->ZC7_DSCBLQ := ZC7->ZC7_DSCBLQ
						TMPZC7->ZC7_NDTVEN := ZC7->ZC7_NDTVEN
						TMPZC7->ZC7_NDTVCR := ZC7->ZC7_NDTVCR
						TMPZC7->ZC7_USRAPR := ZC7->ZC7_USRAPR
						TMPZC7->ZC7_NOMAPR := ZC7->ZC7_NOMAPR
						TMPZC7->ZC7_DTAPR  := ZC7->ZC7_DTAPR
						TMPZC7->ZC7_HRAPR  := ZC7->ZC7_HRAPR
						TMPZC7->ZC7_OBS	   := ZC7->ZC7_OBS
						TMPZC7->ZC7_ODTVEN := ZC7->ZC7_ODTVEN
						TMPZC7->ZC7_ODTVCR := ZC7->ZC7_ODTVCR
					Elseif 'Juros' $ cDscTpBlq
						TMPZC7->ZC7_PREFIX := ZC7->ZC7_PREFIX
						TMPZC7->ZC7_NUM	   := ZC7->ZC7_NUM
						TMPZC7->ZC7_PARCEL := ZC7->ZC7_PARCEL
						TMPZC7->ZC7_CLIFOR := ZC7->ZC7_CLIFOR
						TMPZC7->ZC7_LOJA   := ZC7->ZC7_LOJA
						TMPZC7->ZC7_VLRBLQ := ZC7->ZC7_VLRBLQ
						TMPZC7->ZC7_TPBLQ  := ZC7->ZC7_TPBLQ
						TMPZC7->ZC7_DSCBLQ := ZC7->ZC7_DSCBLQ
						TMPZC7->ZC7_VLRJUR := ZC7->ZC7_VLRJUR
						TMPZC7->ZC7_USRAPR := ZC7->ZC7_USRAPR
						TMPZC7->ZC7_NOMAPR := ZC7->ZC7_NOMAPR
						TMPZC7->ZC7_DTAPR  := ZC7->ZC7_DTAPR
						TMPZC7->ZC7_HRAPR  := ZC7->ZC7_HRAPR
						TMPZC7->ZC7_OBS	   := ZC7->ZC7_OBS
					Elseif 'Acrescimo' $ cDscTpBlq
						TMPZC7->ZC7_PREFIX := ZC7->ZC7_PREFIX
						TMPZC7->ZC7_NUM	   := ZC7->ZC7_NUM
						TMPZC7->ZC7_PARCEL := ZC7->ZC7_PARCEL
						TMPZC7->ZC7_CLIFOR := ZC7->ZC7_CLIFOR
						TMPZC7->ZC7_LOJA   := ZC7->ZC7_LOJA
						TMPZC7->ZC7_VLRBLQ := ZC7->ZC7_VLRBLQ
						TMPZC7->ZC7_TPBLQ  := ZC7->ZC7_TPBLQ
						TMPZC7->ZC7_DSCBLQ := ZC7->ZC7_DSCBLQ
						TMPZC7->ZC7_ACRESC := ZC7->ZC7_ACRESC
						TMPZC7->ZC7_USRAPR := ZC7->ZC7_USRAPR
						TMPZC7->ZC7_NOMAPR := ZC7->ZC7_NOMAPR
						TMPZC7->ZC7_DTAPR  := ZC7->ZC7_DTAPR
						TMPZC7->ZC7_HRAPR  := ZC7->ZC7_HRAPR
						TMPZC7->ZC7_OBS	   := ZC7->ZC7_OBS
					Elseif 'Descrescimo' $ cDscTpBlq
						TMPZC7->ZC7_PREFIX := ZC7->ZC7_PREFIX
						TMPZC7->ZC7_NUM	   := ZC7->ZC7_NUM
						TMPZC7->ZC7_PARCEL := ZC7->ZC7_PARCEL
						TMPZC7->ZC7_CLIFOR := ZC7->ZC7_CLIFOR
						TMPZC7->ZC7_LOJA   := ZC7->ZC7_LOJA
						TMPZC7->ZC7_VLRBLQ := ZC7->ZC7_VLRBLQ
						TMPZC7->ZC7_TPBLQ  := ZC7->ZC7_TPBLQ
						TMPZC7->ZC7_DSCBLQ := ZC7->ZC7_DSCBLQ
						TMPZC7->ZC7_DECRES := ZC7->ZC7_DECRES
						TMPZC7->ZC7_USRAPR := ZC7->ZC7_USRAPR
						TMPZC7->ZC7_NOMAPR := ZC7->ZC7_NOMAPR
						TMPZC7->ZC7_DTAPR  := ZC7->ZC7_DTAPR
						TMPZC7->ZC7_HRAPR  := ZC7->ZC7_HRAPR
						TMPZC7->ZC7_OBS	   := ZC7->ZC7_OBS
					Elseif 'Desconto' $ cDscTpBlq
						TMPZC7->ZC7_PREFIX := ZC7->ZC7_PREFIX
						TMPZC7->ZC7_NUM	   := ZC7->ZC7_NUM
						TMPZC7->ZC7_PARCEL := ZC7->ZC7_PARCEL
						TMPZC7->ZC7_CLIFOR := ZC7->ZC7_CLIFOR
						TMPZC7->ZC7_LOJA   := ZC7->ZC7_LOJA
						TMPZC7->ZC7_VLRBLQ := ZC7->ZC7_VLRBLQ
						TMPZC7->ZC7_TPBLQ  := ZC7->ZC7_TPBLQ
						TMPZC7->ZC7_DSCBLQ := ZC7->ZC7_DSCBLQ
						TMPZC7->ZC7_CNABDE := ZC7->ZC7_CNABDE
						TMPZC7->ZC7_USRAPR := ZC7->ZC7_USRAPR
						TMPZC7->ZC7_NOMAPR := ZC7->ZC7_NOMAPR
						TMPZC7->ZC7_DTAPR  := ZC7->ZC7_DTAPR
						TMPZC7->ZC7_HRAPR  := ZC7->ZC7_HRAPR
						TMPZC7->ZC7_OBS	   := ZC7->ZC7_OBS
					Else
						TMPZC7->ZC7_PREFIX := ZC7->ZC7_PREFIX
						TMPZC7->ZC7_NUM	   := ZC7->ZC7_NUM
						TMPZC7->ZC7_PARCEL := ZC7->ZC7_PARCEL
						TMPZC7->ZC7_CLIFOR := ZC7->ZC7_CLIFOR
						TMPZC7->ZC7_LOJA   := ZC7->ZC7_LOJA
						TMPZC7->ZC7_VLRBLQ := ZC7->ZC7_VLRBLQ
						TMPZC7->ZC7_TPBLQ  := ZC7->ZC7_TPBLQ
						TMPZC7->ZC7_DSCBLQ := ZC7->ZC7_DSCBLQ
						TMPZC7->ZC7_ACRESC := ZC7->ZC7_ACRESC
						TMPZC7->ZC7_CNABAC := ZC7->ZC7_CNABAC
						TMPZC7->ZC7_CNABDE := ZC7->ZC7_CNABDE
						TMPZC7->ZC7_DECRES := ZC7->ZC7_DECRES
						TMPZC7->ZC7_VLRJUR := ZC7->ZC7_VLRJUR
						TMPZC7->ZC7_CUSFIN := ZC7->ZC7_CUSFIN
						TMPZC7->ZC7_NDTVEN := ZC7->ZC7_NDTVEN
						TMPZC7->ZC7_NDTVCR := ZC7->ZC7_NDTVCR
						TMPZC7->ZC7_USRAPR := ZC7->ZC7_USRAPR
						TMPZC7->ZC7_NOMAPR := ZC7->ZC7_NOMAPR
						TMPZC7->ZC7_DTAPR  := ZC7->ZC7_DTAPR
						TMPZC7->ZC7_HRAPR  := ZC7->ZC7_HRAPR
						TMPZC7->ZC7_OBS	   := ZC7->ZC7_OBS
						TMPZC7->ZC7_ODTVEN := ZC7->ZC7_ODTVEN
						TMPZC7->ZC7_ODTVCR := ZC7->ZC7_ODTVCR
					Endif
				ElseIF sTpApr = '000005'
					TMPZC7->ZC7_PREFIX := ZC7->ZC7_PREFIX
					TMPZC7->ZC7_NUM    := ZC7->ZC7_NUM
					TMPZC7->ZC7_PARCEL := ZC7->ZC7_PARCEL
					TMPZC7->ZC7_CLIFOR := ZC7->ZC7_CLIFOR
					TMPZC7->ZC7_LOJA   := ZC7->ZC7_LOJA
					TMPZC7->ZC7_VLRBLQ := ZC7->ZC7_VLRBLQ
					TMPZC7->ZC7_TPBLQ  := ZC7->ZC7_TPBLQ
					TMPZC7->ZC7_DSCBLQ := ZC7->ZC7_DSCBLQ
					TMPZC7->ZC7_USRAPR := ZC7->ZC7_USRAPR
					TMPZC7->ZC7_NOMAPR := ZC7->ZC7_NOMAPR
					TMPZC7->ZC7_DTAPR  := ZC7->ZC7_DTAPR
					TMPZC7->ZC7_HRAPR  := ZC7->ZC7_HRAPR
					TMPZC7->ZC7_OBS	   := ZC7->ZC7_OBS
				ElseIF sTpApr = '000011'
					
					TMPZC7->ZC7_PREFIX := ZC7->ZC7_PREFIX
					TMPZC7->ZC7_NUM	   := ZC7->ZC7_NUM
					TMPZC7->ZC7_PARCEL := ZC7->ZC7_PARCEL
					TMPZC7->ZC7_CLIFOR := ZC7->ZC7_CLIFOR
					TMPZC7->ZC7_LOJA   := ZC7->ZC7_LOJA
					TMPZC7->ZC7_VLRBLQ := ZC7->ZC7_VLRBLQ
					TMPZC7->ZC7_TPBLQ  := ZC7->ZC7_TPBLQ
					TMPZC7->ZC7_DSCBLQ := ZC7->ZC7_DSCBLQ
					TMPZC7->ZC7_USRAPR := ZC7->ZC7_USRAPR
					TMPZC7->ZC7_NOMAPR := ZC7->ZC7_NOMAPR
					TMPZC7->ZC7_DTAPR  := ZC7->ZC7_DTAPR
					TMPZC7->ZC7_HRAPR  := ZC7->ZC7_HRAPR
					TMPZC7->ZC7_OBS    := ZC7->ZC7_OBS	
				
				//INICIO Ticket  429    - Abel Babini   - 09/10/2020 - Tratamento de bloqueios Painel de pagamento
				Else
					
					TMPZC7->ZC7_PREFIX := ZC7->ZC7_PREFIX
					TMPZC7->ZC7_NUM	   := ZC7->ZC7_NUM
					TMPZC7->ZC7_PARCEL := ZC7->ZC7_PARCEL
					TMPZC7->ZC7_CLIFOR := ZC7->ZC7_CLIFOR
					TMPZC7->ZC7_LOJA   := ZC7->ZC7_LOJA
					TMPZC7->ZC7_VLRBLQ := ZC7->ZC7_VLRBLQ
					TMPZC7->ZC7_TPBLQ  := ZC7->ZC7_TPBLQ
					TMPZC7->ZC7_DSCBLQ := ZC7->ZC7_DSCBLQ
					TMPZC7->ZC7_USRAPR := ZC7->ZC7_USRAPR
					TMPZC7->ZC7_NOMAPR := ZC7->ZC7_NOMAPR
					TMPZC7->ZC7_DTAPR  := ZC7->ZC7_DTAPR
					TMPZC7->ZC7_HRAPR  := ZC7->ZC7_HRAPR
					TMPZC7->ZC7_OBS    := ZC7->ZC7_OBS	
				//FIM Ticket  429    - Abel Babini   - 09/10/2020 - Tratamento de bloqueios Painel de pagamento
				Endif
				MSUnLock()			
				dbSelectArea("ZC7")
				dbSkip()
			Enddo
		Endif

	Else
		// FWNM - INTEGRACAO PROJETOS DE INVESTIMENTOS (AF8)

		dbSelectArea("ZC7")
		dbSetOrder( 3 )  // ZC7_FILIAL+ZC7_PROJET
		If dbSeek( pFilial + ZC7PROJET )
			Do While !EOF() .AND. xFilial("ZC7") == pFilial .AND. ZC7->ZC7_PROJET == ZC7PROJET

				dbSelectArea("TMPZC7")

				// Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 22/04/2019
				//If Empty(ZC7->ZC7_USRAPR)
				//If Empty(ZC7->ZC7_DTAPR) .AND. ZC7->ZC7_USRAPR == __cUserID 
				If Empty(ZC7->ZC7_DTAPR) .AND. ZC7->ZC7_USRAPR == __cUserID .AND. Empty(ZC7->ZC7_REPROV) // 14/05/19 | FWNM | Adaptacao para aprovadores quando rejeitado | TI

					RecLock("TMPZC7", .T.)

					TMPZC7->ZC7_REVPRJ	:= ZC7->ZC7_REVPRJ
					TMPZC7->ZC7_VLRBLQ	:= ZC7->ZC7_VLRBLQ
					TMPZC7->AFE_USERF   := UsrRetName(Posicione("AFE",1,FWxFilial("AFE")+ZC7PROJET+ZC7->ZC7_REVPRJ,"AFE_USERF"))
					TMPZC7->AFE_DATAF   := Posicione("AFE",1,FWxFilial("AFE")+ZC7PROJET+ZC7->ZC7_REVPRJ,"AFE_DATAF")
					TMPZC7->AFE_HORAF   := Posicione("AFE",1,FWxFilial("AFE")+ZC7PROJET+ZC7->ZC7_REVPRJ,"AFE_HORAF")
					TMPZC7->AFE_MEMO    := Posicione("AFE",1,FWxFilial("AFE")+ZC7PROJET+ZC7->ZC7_REVPRJ,"AFE_MEMO")

					MSUnLock()

				EndIf

				dbSelectArea("ZC7")
				dbSkip()
			Enddo
		Endif

	EndIf

	dbSelectArea("TMPZC7")
	dbGoTop()

Return

/*{Protheus.doc} User Function ADFINW46
	Central Aprovacao Menu
	@type  Function
	@author Ricardo Lima
	@since 14/11/2017
	@version 01
	@history Chamado 038609
*/

User Function ADFINW46( E2PREFIXO , E2NUM , E2PARCELA , E2FORNECE , E2LOJA , E2VALOR , cNomApr , sTpApr , lAprTit , cTpOper , cObsOper )

	Local cMsg := ""
	Local cCplMsg := ""
	local cNomFor := GetAdvFVal( "SA2", "A2_NOME", xFilial("SA2") + E2FORNECE + E2LOJA , 1, "" )

	U_ADINF009P('ADFIN046P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Central Aprovação')

	if !lAprTit .AND. cTpOper = 'A'
		cCplMsg := "Essa operação precisa da sua Aprovação."
	endif

	cMsg := " <head> "
	cMsg += " <meta http-equiv='Content-Language' content='pt-br' /> "
	cMsg += " <meta http-equiv='Content-Type' content='text/html; charset=utf-8' /> "
	cMsg += " <title>Central de Aprovação</title> "
	cMsg += " <style type='text/css'> "
	cMsg += " .style1 { "
	cMsg += " 				font-family: 'Century Gothic'; "
	cMsg += " 				text-align: center; "
	cMsg += " 				text-decoration: underline; "
	cMsg += " 				font-size: x-large; "
	cMsg += " } "
	cMsg += " .style2 { "
	cMsg += " 				text-align: left; "
	cMsg += " 				font-family: 'Century Gothic'; "
	cMsg += " } "
	cMsg += " td "
	cMsg += " 	{border-style: none; "
	cMsg += " 				border-color: inherit; "
	cMsg += " 				border-width: medium; "
	cMsg += " 				padding-top:1px; "
	cMsg += " 					padding-right:1px; "
	cMsg += " 					padding-left:1px; "
	cMsg += " 					color:gray; "
	cMsg += " 					font-size:9.0pt; "
	cMsg += " 					font-weight:400; "
	cMsg += " 					font-style:normal; "
	cMsg += " 					text-decoration:none; "
	cMsg += " 					font-family:'Century Gothic', sans-serif; "
	cMsg += " 					text-align:general; "
	cMsg += " 					vertical-align:middle; "
	cMsg += " 					white-space:nowrap; "
	cMsg += " 	} "
	cMsg += " .style3 { "
	cMsg += " 				border-collapse: collapse; "
	cMsg += " 				margin-bottom: 0px; "
	cMsg += " } "
	cMsg += " .style4 { "
	cMsg += " 				font-family: 'Century Gothic'; "
	cMsg += " } "
	cMsg += " </style> "
	cMsg += " </head> "
	cMsg += " <body> "
	cMsg += " <p><img alt='ADORO' src='http://www.adoro.com.br/images/logo-adoro.png' style='float: left' /></p> "
	cMsg += " <p class='style1'><strong>Central de Aprovação</strong></p> "

	if cTpOper = 'A'
		if sTpApr = "000001"
			cMsg += " <p class='style2'>Caro Gestor, Segue Aprovação de Titulo de PA de Fornecedor do Aprovador: "+ cNomApr +"</p> "
		elseif sTpApr = "000004"
			cMsg += " <p class='style2'>Caro Gestor, Segue Aprovação de Alçada Financeira do Aprovador: "+ cNomApr +"</p> "
		elseif sTpApr = "000005"
			cMsg += " <p class='style2'>Caro Gestor, Segue Aprovação de Nivel de Segurança do Aprovador: "+ cNomApr +"</p> "
		elseif sTpApr = "000011"
			cMsg += " <p class='style2'>Caro Gestor, Segue Aprovação de Alçada Financeira do Aprovador: "+ cNomApr +"</p> "	
		elseif sTpApr = "999999"
			cMsg += " <p class='style2'>Caro Gestor, Segue Titulo com necessidade de sua Analise. "+ cNomApr +"</p> "
		else
			cMsg += " <p class='style2'>Caro Gestor, Segue Aprovação realizada por: "+ cNomApr +"</p> "
		endif
	Else
		if sTpApr = "000001"
			cMsg += " <p class='style2'>Caro Analista, Segue Reprovação de Titulo de PA de Fornecedor do Aprovador: "+ cNomApr +"</p> "
		elseif sTpApr = "000004"
			cMsg += " <p class='style2'>Caro Analista, Segue Reprovação de Alçada Financeira do Aprovador: "+ cNomApr +"</p> "
		elseif sTpApr = "000005"
			cMsg += " <p class='style2'>Caro Analista, Segue Reprovação de Nivel de Segurança do Aprovador: "+ cNomApr +"</p> "
		elseif sTpApr = "000011"
			cMsg += " <p class='style2'>Caro Analista, Segue Reprovação de Alçada Financeira do Aprovador: "+ cNomApr +"</p> "	
		else
			cMsg += " <p class='style2'>Caro Analista, Segue Reprovação realizada por: "+ cNomApr +"</p> "
		endif
	Endif

	cMsg += " <table border='0' cellpadding='0' cellspacing='0' width='1305' style='width: 979pt' class='style3'> "
	cMsg += " 				<tr height='24' style='mso-height-source: userset; height: 18.0pt'> "
	cMsg += " 								<td>Prefixo</td> "
	cMsg += " 								<td>Numero Titulo</td> "
	cMsg += " 								<td>Parcela</td> "
	cMsg += " 								<td>Fornecedor</td> "
	cMsg += " 								<td>Loja</td> "
	cMsg += " 								<td>Nome</td> "
	cMsg += " 								<td>Valor - R$</td> "
	if cTpOper = 'R'
		cMsg += " 							<td>Observação</td> "
	Endif
	cMsg += " 				</tr> "
	cMsg += " 				<tr height='24' style='mso-height-source: userset; height: 18.0pt'> "
	cMsg += " 								<td>"+ E2PREFIXO +"</td> "
	cMsg += " 								<td>"+ E2NUM +"</td> "
	cMsg += " 								<td>"+ E2PARCELA +"</td> "
	cMsg += " 								<td>"+ E2FORNECE +"</td> "
	cMsg += " 								<td>"+ E2LOJA  +"</td> "
	cMsg += " 								<td>"+ cNomFor +"</td> "
	cMsg += " 								<td>"+ Transform( E2VALOR , X3Picture( "E2_SALDO" ) ) +"</td> "
	if cTpOper = 'R'
		cMsg += " 							<td>"+ cObsOper +"</td> "
	Endif
	cMsg += " 				</tr> "
	cMsg += " </table> "
	cMsg += " <p>&nbsp;</p> "
	If !empty(cCplMsg)
		cMsg += " <p class='style4'><strong>"+ cCplMsg +"</strong></p> "
		cMsg += " <p>&nbsp;</p> "
	Endif
	cMsg += " <p class='style4'>Envio Automático - AD&#39;ORO ( Central de Aprovação )</p> "
	cMsg += " </body> "
	cMsg += " </html> "

Return( cMsg )

/*{Protheus.doc} Static Function ALTFASE
	Funcao para alterar a fase do projeto
	@type  Function
	@author FWNM
	@since 12/01/2017
	@version 01
	@history Chamado
*/

Static Function AltFase()

	Local oCmpPrj  := Array(01)
	Local oBtnPrj  := Array(02)
	Local lRetPrj  := .t.
	Local lOKPrj   := .f.
	Local cCodFase := Space(02)

	DEFINE MSDIALOG oDlgPrj TITLE "Fases - Projetos Investimentos" FROM 0,0 TO 100,350  OF oMainWnd PIXEL

	@ 003, 003 TO 050,165 PIXEL OF oDlgPrj

	@ 010,020 Say "Fases:" of oDlgPrj PIXEL
	@ 005,060 MsGet oCmpPrj Var cCodFase SIZE 70,12 of oDlgPrj PIXEL Valid !Empty(cCodFase) .and. VldFase(cCodFase) F3 'AEA'

	@ 030,015 BUTTON oBtnPrj[01] PROMPT "Confirma"     of oDlgPrj   SIZE 68,12 PIXEL ACTION (lOKPrj := .t. , oDlgPrj:End())
	@ 030,089 BUTTON oBtnPrj[02] PROMPT "Cancela"      of oDlgPrj   SIZE 68,12 PIXEL ACTION oDlgPrj:End()

	ACTIVATE MSDIALOG oDlgPrj CENTERED

	If !lOKPrj
		cCodFase := "INVALIDO"
		Aviso("ADFIN046-01", "Projeto não será liberado! " + chr(13) + chr(10) + "Escolha uma fase do projeto..." , {"OK"}, 3, "Fases - Projetos Investimentos")
	Endif

Return cCodFase

/*{Protheus.doc} Static Function VLDFASE
	Funcao para validar a fase do projeto
	@type  Function
	@author FWNM
	@since 12/01/2017
	@version 01
	@history Chamado
*/

Static Function VldFase(cCodFase)

	Local lRet     := .t.
	Local cFaseAtu := ""

	AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
	If AF8->( dbSeek(FWxFilial("AF8")+cCodPrj) )
		cFaseAtu := AF8->AF8_FASE
	EndIf

	// Consiste fase escolhida x fase atual do projeto
	If AllTrim(cCodFase) == AllTrim(cFaseAtu)
		lRet := .f.
		Aviso("ADFIN046-02", "Fase escolhida é a fase atual do projeto! Escolha uma fase diferente para o projeto..." , {"OK"}, 3, "Fases - Projetos Investimentos")
	EndIf

Return lRet

/*{Protheus.doc} Static Function VERRATEIO
	Visualiza rateio do projeto de investimento para o aprovador
	@type  Function
	@author FWNM
	@since 26/12/2017
	@version 01
	@history Chamado
*/

Static Function VerRateio()

	Local aAreaAtu := GetArea()
	Local aPrjBro  := {}

	/*
	Local cCodPrj  := ZCE->ZCE_PROJET
	Local cRevPrj  := ZCE->ZCE_REVISA
	Local cPeriod  := ZCE->ZCE_PERIOD
	Local cVlrRat  := ZCE->ZCE_VALOR
	Local cDetail  := ZCE->ZCE_DETAIL
	*/

	aPrjBro		:= { {"ZCE_PROJET"	, , "Projeto"		    , " "	}, ;
	{"ZCE_REVISA"	, , "Revisão Projeto"	, " "	},;
	{"ZCE_PERIOD"	, , "Periodo"        	, ""	},;
	{"ZCE_VALOR" 	, , "Rateio"         	, "@E 999,999,999.99"	},;
	{"ZCE_DETAIL"   , , "Detalhamento"      , " "   } }


	oFont1		:= TFont():New( "MS Sans Serif", 0, -19, , .T., 0, , 700, .T., .T., , , , , , )

	/*
	MsAdvSize (http://tdn.totvs.com/display/public/mp/MsAdvSize+-+Dimensionamento+de+Janelas)
	aSize[1] = 1 -> Linha inicial área trabalho.
	aSize[2] = 2 -> Coluna inicial área trabalho.
	aSize[3] = 3 -> Linha final área trabalho.
	aSize[4] = 4 -> Coluna final área trabalho.
	aSize[5] = 5 -> Coluna final dialog (janela).
	aSize[6] = 6 -> Linha final dialog (janela).
	aSize[7] = 7 -> Linha inicial dialog (janela).
	*/

	aSize	:= {}
	aSize := MsAdvSize(.T.)

	Define MsDialog oPrjWindow TITLE "Cronograma Financeiro - Visualização" /*STYLE DS_MODALFRAME*/ From aSize[7]-700,0 To aSize[6]-1300,aSize[5]-900 OF oWindow /*oMainWnd*/ PIXEL

	//MONTANDO TABELA TEMPORARIA COM INFORMAÇÕES DO PROJETO
	UpRateio( FwxFilial("ZCE") , cCodPrj, cRevPrj )

	oBROWSER	:= MsSelect():New( "TMPZCE", "", "", aPrjBro, .F., .F., { 17,1,200,600 }, , ,  oPrjWindow )

	ACTIVATE MSDIALOG oPrjWindow ON INIT EnchoiceBar(oPrjWindow,{||oPrjWindow:End()},{|| oPrjWindow:End()}) CENTERED

	RestArea( aAreaAtu )

Return .T.

/*{Protheus.doc} Static Function UPRATEIO
	Funcao para visualizar o rateio do projeto
	@type  Function
	@author FWNM
	@since 26/12/2017
	@version 01
	@history Chamado
*/

STATIC Function UpRateio( pFilial , cCodPrj, cRevPrj )

	Local cArq		:= CriaTrab( NIL, .F.)

	Private aCampos := {}

	aCampos := { {"ZCE_PROJET"	, "C", 10, 0}, ;
	{"ZCE_REVISA"	, "C", 04, 0}, ;
	{"ZCE_PERIOD"	, "C", 06, 0}, ;
	{"ZCE_VALOR"	, "N", 18, 2}, ;
	{"ZCE_DETAIL"	, "C", 254, 0} }

	If ( SELECT("TMPZCE" ) !=  0 )
		dbSelectArea("TMPZCE")
		dbCloseArea()
	Endif

	dbCreate( cArq, aCampos )
	dbUseArea( .T., , cArq, "TMPZCE", .F., .F.)

	dbSelectArea("ZCE")

	dbSetOrder( 2 )  // ZCE_FILIAL+ZCE_PROJET+ZCE_REVISA
	If dbSeek( xFilial("ZCE") + cCodPrj + cRevPrj )

		Do While ZCE->( !EOF() ) .AND. xFilial("ZCE") == pFilial .AND. ZCE->ZCE_PROJET == cCodPrj .and. ZCE->ZCE_REVISA == cRevPrj

			dbSelectArea("TMPZCE")

			RecLock("TMPZCE", .T.)

			TMPZCE->ZCE_PROJET	:= ZCE->ZCE_PROJET
			TMPZCE->ZCE_REVISA	:= ZCE->ZCE_REVISA
			TMPZCE->ZCE_PERIOD	:= ZCE->ZCE_PERIOD
			TMPZCE->ZCE_VALOR	:= ZCE->ZCE_VALOR
			TMPZCE->ZCE_DETAIL	:= ZCE->ZCE_DETAIL

			msUnLock()

			dbSelectArea("ZCE")
			ZCE->( dbSkip() )

		EndDo

	EndIf

	dbSelectArea("TMPZCE")
	dbGoTop()

Return

/*{Protheus.doc} Static Function VERJUSTREV
	Funcao para visualizar justificativas da revisao
	@type  Function
	@author FWNM
	@since 26/12/2017
	@version 01
	@history Chamado
*/

Static Function VerJustRev(cAlias,nReg,nOpcx)

	Local cGetMemo	:= CriaVar("AFE_MEMO")
	Local lContinua	:= .T.
	Local oDlg
	Local oEnch
	Local oMemo
	Local oMemo2
	Local oPanel

	Local nOpcx := 2

	Private M->AFE_COMENT	:= CriaVar("AFE_COMENT")
	PRIVATE cSavScrVT,;
	cSavScrVP,;
	cSavScrHT,;
	cSavScrHP,;
	CurLen,;
	nPosAtu:=0,;
	nPosAnt:=9999,;
	nColAnt:=9999

	If lContinua
		AFE->( dbSetOrder(1) ) // AFE_FILIAL+AFE_PROJET+AFE_REVISA
		AFE->( dbSeek(xFilial("AFE")+cCodPrj+cRevPrj) )
		nReg := RecNo()

		RegToMemory("AFE",.F.)
		M->AFE_COMENT	:= MSMM(AFE->AFE_CODMEM)
		cGetMemo		:= AFE->AFE_MEMO

		DEFINE MSDIALOG oDlg TITLE "Justificativa Revisão" FROM 8,0 TO 31,78 OF oMainWnd

		oEnch := MsMGet():New("AFE",nReg,nOpcx,,,,, {16,1,90,307},,,,,,oDlg)
		oEnch:oBox:Align := CONTROL_ALIGN_TOP

		oPanel := TPanel():New(1,2,"",oDlg,NIL,.T.,.F.,NIL,NIL,2,4,.T.,.F. )
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT

		@ 1,2 Say "Justificativa resumida" of oPanel Pixel
		@ 10,2 GET oMemo VAR M->AFE_MEMO MEMO SIZE 306,20 /*VALID MEMOVALID()*/ PIXEL OF oPanel
		@ 30,2 Say "Justificativa completa" of oPanel Pixel
		@ 40,2 GET oMemo2 VAR M->AFE_COMENT MEMO SIZE 306,55 PIXEL OF oPanel

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{|| oDlg:End()}) CENTERED

	EndIf

Return .T.

/*{Protheus.doc} Static Function RECUSAPRJ
	Rotina para recusar um projeto e disparar email ao responsavel pelo projeto
	@type  Function
	@author FWNM
	@since 05/01/2018
	@version 01
	@history Chamado
*/

Static Function RecusaPrj()

	Local aDadWF   := {}
	Local cMail    := ""
	Local cUsrMail := ""
	Local cCodPrj  := TMPZC7->ZC7_PROJET

	AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
	If AF8->( dbSeek( FWxFilial("AF8") + cCodPrj ) )

		aDadWF := {}
		cMail  := ""
		cMail  := UsrRetMail(AF8->AF8_XUSER)
		cUsrMail := AF8->AF8_XUSER
							
		// Chamado n. 053243 || OS 054600 || CONTROLADORIA || DAIANE || (11) || WOKFLOW PROJETOS - FWNM - 08/11/2019
		If Left(cCodPrj,2) == "03" // Projetos SC
			If !Empty(cMail)
				cMail  += ";" + GetMV("MV_#AF8MAI",,"daiane.moreira@adoro.com.br")
			Else
				cMail  := GetMV("MV_#AF8MAI",,"daiane.moreira@adoro.com.br")
			EndIf
		EndIf
						
		c_ZC7_USRAPR := AllTrim( __cUserID )
		c_ZC7_NOMAPR := AllTrim(UsrRetName(__cUserID))
		c_ZC7_DTAPR := msDate()
		c_ZC7_HRAPR := TIME()
	
		aAdd( aDadWF, { TMPZC7->ZC7_PROJET, TMPZC7->ZC7_REVPRJ, c_ZC7_USRAPR, c_ZC7_NOMAPR, c_ZC7_DTAPR, c_ZC7_HRAPR, cDscObs, cMail, cNomPrj, cUsrMail } )
		u_ADPRJ004P(aDadWF, "RECUSA") //WILLIAM COSTA ERRO DA FUNCAO WF

	EndIf

Return .t.

/*{Protheus.doc} Static Function ADBCO046
	Troca banco da PA em aprovacao
	@type  Function
	@author Ricardo Lima
	@since 13/03/2018
	@version 01
	@history Chamado 038609
*/

Static Function ADBCO046()

	Local lRetP := .F.

	lRetP := Pergunte("ADFIN046P" , .T. , "Altera Banco da PA")

	if lRetP
		DbSelectArea("SE5")
		dbSetOrder(7) // E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_SEQ, R_E_C_N_O_, D_E_L_E_T_
		IF DbSeek( cFilZC7 + cCodigo + nNumTit + nParctit + nTipTit + cCodCli + cLojCli  )
			If MSGYESNO(" Confirma a Alteração do Banco: "+SE5->E5_BANCO+", Agencia: "+SE5->E5_AGENCIA+", Conta: "+SE5->E5_CONTA + CHR(13) + CHR(10) +"Para Banco: "+MV_PAR01+", Agencia: "+MV_PAR02+", Conta: "+MV_PAR03+" ? ")
				RecLock("SE5",.F.)
				SE5->E5_BANCO   := MV_PAR01
				SE5->E5_AGENCIA := MV_PAR02
				SE5->E5_CONTA   := MV_PAR03
				MSUnLock()
			EndIf
		ENDIF
	endif

Return(lRetP)

/*{Protheus.doc} User Function ADSTS046
	Consulta Pedido de PA no SAG
	@type  Function
	@author Ricardo Lima
	@since 13/03/2018
	@version 01
	@history Chamado 
*/
User Function ADSTS046

	Local aAreaAtu   := GetArea()
	Local aCpSAG     := {}
	Local oSay1
	Local oGet1
	Local oSay2
	Local oGet2
	Local oSay3
	Local oGet3

	Private nTotalPD := 0
	Private npPtPD   := 0
	Private npDifPD   := 0

	U_ADINF009P('ADFIN046P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Central Aprovação')

	aCpSAG		:= {{"E2_PREFIXO" , , "Prefixo"		    , " "	}, ;
	{"E2_NUM"     , , "Numero"		    , " "	}, ;
	{"E2_PARCELA" , , "Parcela"		    , " "	}, ;
	{"E2_TIPO"    , , "Tipo"		    , " "	}, ;
	{"E2_NATUREZ" , , "Natureza"		, " "	}, ;
	{"E2_FORNECE" , , "Fornecedor"		, " "	}, ;
	{"E2_LOJA"    , , "Loja"		    , " "	}, ;
	{"E2_NOMFOR"  , , "Nome"		    , " "	}, ;
	{"E2_EMISSAO" , , "Emissao"		    , " "	}, ;
	{"E2_VENCTO"  , , "Vencimento"		, " "	}, ;
	{"E2_VALOR"   , , "Valor"		    , "@E 999,999,999.99"	}, ;
	{"E2_PRODUTO" , , "Produto"		    , " "	} }

	oFont1		:= TFont():New( "MS Sans Serif", 0, -19, , .T., 0, , 700, .T., .T., , , , , , )

	aSize	:= {}
	aSize := MsAdvSize(.T.)

	Define MsDialog oPrjWindow TITLE "Status do Pedido de PA no SAG" STYLE DS_MODALFRAME From aSize[7],0 To aSize[6]-(aSize[6]/3),aSize[5]-(aSize[5]/4) OF oWindow /*oMainWnd*/ PIXEL

	//MONTANDO TABELA TEMPORARIA
	ADQRY046( cFilZC7 , cCodigo , nNumTit , nParctit , nTipTit , cCodCli , cLojCli )

	npDifPD := nTotalPD - npPtPD

	oBROWSER	:= MsSelect():New( "TMPFIN", "", "", aCpSAG, .F., .F., { 33,3,150,500 }, , ,  oPrjWindow )

	oSay1 := TSay():New( 166, 008, { || "Total do Pedido de PA no SAG"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
	oGet1 := TGet():New( 166, 100, { |u| If( PCount() > 0, nTotalPD	:= u, nTotalPD ) }, oPrjWindow, 060, 008, "@E 999,999,999.99"		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "nTotalPD", , )

	oSay2 := TSay():New( 166, 208, { || "Falta Integrar"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
	oGet2 := TGet():New( 166, 270, { |u| If( PCount() > 0, npDifPD	:= u, npDifPD ) }, oPrjWindow, 060, 008, "@E 999,999,999.99"		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "npDifPD", , )

	oSay3 := TSay():New( 180, 008, { || "Total do PA Integrada"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
	oGet3 := TGet():New( 180, 100, { |u| If( PCount() > 0, npPtPD	:= u, npPtPD ) }, oPrjWindow, 060, 008, "@E 999,999,999.99"		, , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "npPtPD", , )


	ACTIVATE MSDIALOG oPrjWindow ON INIT EnchoiceBar(oPrjWindow,{||oPrjWindow:End()},{|| oPrjWindow:End()}) CENTERED

	RestArea( aAreaAtu )

Return .T.

/*{Protheus.doc} Static Function ADQRY046
	Consulta pedido de PA no SAG
	@type  Function
	@author Ricardo Lima
	@since 13/03/2018
	@version 01
	@history Chamado
*/

STATIC Function ADQRY046( cFilZC7 , cCodigo , nNumTit , nParctit , nTipTit , cCodCli , cLojCli )

	Local cArq   := CriaTrab( NIL, .F.)
	Local cQuery := ""

	Private aCampos := {}
	Private cAliasE2 := GetNextAlias()

	aCampos := {{"E2_PREFIXO"	, "C", 3 , 0}, ;
	{"E2_NUM"	    , "C", 9 , 0}, ;
	{"E2_PARCELA"	, "C", 2 , 0}, ;
	{"E2_TIPO"	    , "C", 3 , 0}, ;
	{"E2_NATUREZ"	, "C", 6 , 0}, ;
	{"E2_FORNECE"	, "C", 6 , 0}, ;
	{"E2_LOJA	"	, "C", 2 , 0}, ;
	{"E2_NOMFOR"	, "C", 15, 0}, ;
	{"E2_EMISSAO"	, "D", 8 , 0}, ;
	{"E2_VENCTO	"	, "D", 8 , 0}, ;
	{"E2_VALOR	"	, "N", 16, 2}, ;
	{"E2_PRODUTO"	, "C", 35, 0}}

	If ( SELECT("TMPFIN" ) !=  0 )
		dbSelectArea("TMPFIN")
		dbCloseArea()
	Endif

	dbCreate( cArq, aCampos )
	dbUseArea( .T., , cArq, "TMPFIN", .F., .F.)

	If ( SELECT( (cAliasE2) ) !=  0 )
		dbSelectArea( (cAliasE2) )
		dbCloseArea()
	Endif

	cQuery := " SELECT E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_NATUREZ, E2_FORNECE, E2_LOJA, E2_EMISSAO, E2_VENCTO, E2_VALOR, E2_PRODUTO, E2_TOTAL "
	cQuery += " FROM SGFIN010 "
	cQuery += " WHERE E2_FILIAL = '"+ cFilZC7 +"' AND E2_PREFIXO = '"+ cCodigo +"' AND E2_NUM = '"+ nNumTit +"' AND E2_FORNECE = '"+ cCodCli +"' "
	DbUseArea(.t., "TOPCONN", TcGenQry(,, cQuery), cAliasE2, .F., .T.)

	TcSetField( cAliasE2, "E2_EMISSAO", "D", 8, 0 )
	TcSetField( cAliasE2, "E2_VENCTO" , "D", 8, 0 )

	While !(cAliasE2)->(Eof())

		nTotalPD := (cAliasE2)->E2_TOTAL
		npPtPD   += (cAliasE2)->E2_VALOR

		dbSelectArea("TMPFIN")

		RecLock("TMPFIN", .T.)

		TMPFIN->E2_PREFIXO := (cAliasE2)->E2_PREFIXO
		TMPFIN->E2_NUM     := (cAliasE2)->E2_NUM
		TMPFIN->E2_PARCELA := (cAliasE2)->E2_PARCELA
		TMPFIN->E2_TIPO    := (cAliasE2)->E2_TIPO
		TMPFIN->E2_NATUREZ := (cAliasE2)->E2_NATUREZ
		TMPFIN->E2_FORNECE := (cAliasE2)->E2_FORNECE
		TMPFIN->E2_LOJA	   := (cAliasE2)->E2_LOJA
		TMPFIN->E2_NOMFOR  := GetAdvFVal( "SA2", "A2_NOME", xFilial("SA2") + (cAliasE2)->E2_FORNECE + (cAliasE2)->E2_LOJA , 1, "" )
		TMPFIN->E2_EMISSAO := (cAliasE2)->E2_EMISSAO
		TMPFIN->E2_VENCTO  := (cAliasE2)->E2_VENCTO
		TMPFIN->E2_VALOR   := (cAliasE2)->E2_VALOR
		TMPFIN->E2_PRODUTO := (cAliasE2)->E2_PRODUTO

		msUnLock()

		(cAliasE2)->(DbSkip())

	EndDo

	dbSelectArea("TMPFIN")
	dbGoTop()

Return

/*{Protheus.doc} User Function ADSTP046
	Consulta PA do Fornecedor
	@type  Function
	@author Ricardo Lima
	@since 25/09/2018
	@version 01
	@history Chamado 038609
*/

User Function ADSTP046

	Local aAreaAtu   := GetArea()
	Local oSay1
	Local oGet1
	Local oSay2
	Local oGet2
	Local oSay3
	Local oGet3
	Local cAliasE2 := GetNextAlias()

	Private nLimitPA := 0
	Private nPaAprov := 0
	Private nSaldoPA := 0
	Private nPaAbert := 0
	Private nSlTOTPA := 0

	U_ADINF009P('ADFIN046P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Central Aprovação')

	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek( FWxFilial("SA2") + cCodCli + cLojCli )
	nLimitPA := SA2->A2_XLIMCRD

	If ( SELECT( (cAliasE2) ) !=  0 )
		dbSelectArea( (cAliasE2) )
		dbCloseArea()
	Endif
	cQuery := " SELECT E2_FORNECE, SUM(E2_SALDO) E2_SALDO "
	cQuery += " FROM "+RetSqlName("SE2")+" E2 "
	cQuery += " WHERE E2_FORNECE = '"+cCodCli+"' AND E2_LOJA = '"+cLojCli+"' AND E2_TIPO = 'PA' "
	cQuery += " AND E2_XDIVERG <> 'S' AND E2.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY E2_FORNECE "
	DbUseArea(.t., "TOPCONN", TcGenQry(,, cQuery), cAliasE2, .F., .T.)

	nPaAprov := (cAliasE2)->E2_SALDO
	nSaldoPA := nLimitPA - nPaAprov

	If ( SELECT( (cAliasE2) ) !=  0 )
		dbSelectArea( (cAliasE2) )
		dbCloseArea()
	Endif
	cQuery := " SELECT E2_FORNECE, SUM(E2_SALDO) E2_SALDO "
	cQuery += " FROM "+RetSqlName("SE2")+" E2 "
	cQuery += " WHERE E2_FORNECE = '"+cCodCli+"' AND E2_LOJA = '"+cLojCli+"' AND E2_TIPO = 'PA' "
	cQuery += " AND E2_XDIVERG = 'S' AND E2.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY E2_FORNECE "
	DbUseArea(.t., "TOPCONN", TcGenQry(,, cQuery), cAliasE2, .F., .T.)
	nPaAbert := (cAliasE2)->E2_SALDO

	nSlTOTPA := nLimitPA - (nPaAprov + nPaAbert)

	oFont1 := TFont():New( "MS Sans Serif", 0, -12, , .T., 0, , 700, .T., .F.,.F., , , , , )

	aSize := {}
	aSize := MsAdvSize(.T.)

	Define MsDialog oPrjWindow TITLE "Status de PA do Fornecedor" STYLE DS_MODALFRAME From aSize[7],0 To aSize[6]-(aSize[6]/2),aSize[5]-(aSize[5]/1.5) OF oWindow /*oMainWnd*/ PIXEL

	oSay1 := TSay():New( 35, 008, { || "Limite de Credito para PA"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
	oGet1 := TGet():New( 35, 110, { |u| If( PCount() > 0, nLimitPA	:= u, nLimitPA ) }, oPrjWindow, 060, 008, "@E 999,999,999.99" ,, CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "nLimitPA", , )

	oSay2 := TSay():New( 50, 008, { || "PA em Aberto"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
	oGet2 := TGet():New( 50, 110, { |u| If( PCount() > 0, nPaAprov	:= u, nPaAprov ) }, oPrjWindow, 060, 008, "@E 999,999,999.99" ,, CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "nPaAprov", , )

	oSay3 := TSay():New( 65, 008, { || "Saldo de PA"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
	oGet3 := TGet():New( 65, 110, { |u| If( PCount() > 0, nSaldoPA	:= u, nSaldoPA ) }, oPrjWindow, 060, 008, "@E 999,999,999.99" ,, CLR_BLACK, CLR_WHITE,oFont1 , , , .T., "", , , .F., .F., , .T., .F., "", "nSaldoPA", , )

	oSay3 := TSay():New( 80, 008, { || "PA para Aprovação"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
	oGet3 := TGet():New( 80, 110, { |u| If( PCount() > 0, nPaAbert	:= u, nPaAbert ) }, oPrjWindow, 060, 008, "@E 999,999,999.99" ,, CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "nPaAbert", , )

	oSay3 := TSay():New( 95, 008, { || "Total de PA em Aberto após Aprovação"}  , oPrjWindow, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 140, 008 )
	IF nSlTOTPA > 0
		oGet3 := TGet():New( 95, 110, { |u| If( PCount() > 0, nSlTOTPA	:= u, nSlTOTPA ) }, oPrjWindow, 060, 008, "@E 999,999,999.99" ,, CLR_BLUE, CLR_WHITE,oFont1 , , , .T., "", , , .F., .F., , .T., .F., "", "nSlTOTPA", , )
	Else
		oGet3 := TGet():New( 95, 110, { |u| If( PCount() > 0, nSlTOTPA	:= u, nSlTOTPA ) }, oPrjWindow, 060, 008, "@E 999,999,999.99" ,, CLR_RED , CLR_WHITE,oFont1 , , , .T., "", , , .F., .F., , .T., .F., "", "nSlTOTPA", , )
	EndIf

	ACTIVATE MSDIALOG oPrjWindow ON INIT EnchoiceBar(oPrjWindow,{||oPrjWindow:End()},{|| oPrjWindow:End()}) CENTERED

	RestArea( aAreaAtu )

Return .T.

/*/{Protheus.doc} User Function ADFINR46
	Central Aprovacao - Reprova - Rejeição
	@type  Function
	@author Ricardo Lima
	@since 14/11/2017
	@version 01
	@history Chamado 038609
/*/

User Function ADFINR46( cDscObs , TpRecPag , cOpc )

	Local aArea     := GetArea()
	Local cAssunto  := ""
	Local cMensagem := ""
	Local lAprTit   := .F.
	Local cDestRepr := UsrRetMail(ZC7->ZC7_USRALT)

	Local aAreaAF8  := AF8->( GetArea() ) // fwnm - Chamado n. 046284
	Local cFaseRej  := GetMV("MV_#FASREJ",,"01") // fwnm - Chamado n. 046284
	
	Local cOrigem   := "" //Everson-28/03/19. Chamado 044314.
	Local nConsumo  := 0 // Chamado n. 049774 || OS 051078 || ENGENHARIA || SILVANA || 8406 || PROJETO ENCERRADO - FWNM - 25/06/2019

	U_ADINF009P('ADFIN046P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Central Aprovação')

	// Chamado n. 054538 || OS 055940 || FINANCAS || EDUARDO || 8352 || CENTRAL DE APROVACAO - FWNM - 15/01/2020
	If ! isInCallStack("RESTEXECUTE") //Everson - 21/09/2020. Chamado 1997.
		If  !msgNoYes("Você clicou no botão REPROVA! Continuar? ", '<font color="#FF0000"> Reprova? </font>')
			Return .f.

		EndIf	

	EndIf
	//

	BEGIN TRANSACTION

		// Integracao Projetos Investimentos - FWNM em 08/12/2017
		If Empty(cCodPrj)

			dbSelectArea("ZC7")
			dbSetOrder( 2 )  // ZC7_FILIAL+ZC7_CLIFOR+ZC7_LOJA+ZC7_PREFIX+ZC7_NUM+ZC7_PARCEL+ZC7_TIPO
			If dbSeek( FwxFilial("ZC7") + cCodCli + cLojCli + cCodigo + nNumTit + nParctit + nTipTit)

				WHILE ZC7->(!EOF()) .AND. ZC7->ZC7_FILIAL=FwxFilial("ZC7") .AND. ZC7->ZC7_CLIFOR=cCodCli .AND. ZC7->ZC7_LOJA=cLojCli .AND. ZC7->ZC7_PREFIX=cCodigo .AND. ZC7->ZC7_NUM=nNumTit .AND. ZC7->ZC7_PARCEL=nParctit .AND. ZC7->ZC7_TIPO=nTipTit
					
					cOrigem := Alltrim(cValToChar(ZC7->ZC7_ORIGEM)) //Everson-28/03/19. Chamado 044314.
					
					IF EMPTY(ZC7->ZC7_USRAPR)

						RecLock("ZC7",.F.)
							ZC7->ZC7_USRAPR := AllTrim( __cUserID )
							ZC7->ZC7_NOMAPR := AllTrim(UsrRetName(__cUserID))
							ZC7->ZC7_DTAPR  := DATE()
							ZC7->ZC7_HRAPR  := TIME()
							ZC7->ZC7_OBS    := cDscObs
							ZC7->ZC7_REPROV := AllTrim( __cUserID )
						MSUnlock()

						IF TpRecPag = "P"
							DbSelectArea("SE2")
							DbSetorder(6)  // E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
							IF DbSeek( FwxFilial("SE2") + cCodCli + cLojCli + cCodigo + nNumTit + nParctit + nTipTit )
								RecLock("SE2",.F.)
								//if sTpApr = "000004"
									SE2->E2_XDIVERG := "S" //'N' // Chamado n. 058216 || OS 059676 || FINANCAS || LUIZ || 8451 || CONTAS APAGAR - FWNM - 15/05/2020
									SE2->E2_XOBSAPR := cDscObs
									SE2->E2_RJ      := "X" // Chamado n. 058216 || OS 059676 || FINANCAS || LUIZ || 8451 || CONTAS APAGAR - FWNM - 15/05/2020
								//endif
								MSUnlock()
							ENDIF
						
						ELSEIF TpRecPag = "R"
							DbSelectArea("SE1")
							DbSetorder(2)  // E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
							IF DbSeek( FwxFilial("SE1") + cCodCli + cLojCli + cCodigo + nNumTit + nParctit + nTipTit )
								RecLock("SE1",.F.)
								if sTpApr = "000004"
									SE1->E1_XDIVERG := 'N'
									SE1->E1_XOBSAPR := cDscObs
								endif
								if sTpApr = "000011"
									SE1->E1_XDIVERG := 'N'
									SE1->E1_XOBSAPR := cDscObs
								endif
								MSUnlock()
							ENDIF

						ELSEIF TpRecPag = "F" // Ricardo Lima-14/12/18|CH:044314| Aprovação de Fretes

							Conout( DToC(Date()) + " " + Time() + " ADFIN046P - ADFINR46 - cOrigem " + cOrigem)
							If cOrigem = "ADLOG040P" //Everson-28/03/19. Chamado 044314.

								DbSelectArea("ZFA")
								//Everson-19/03/19. Chamado 044314.
								ZFA->(DbSetOrder(13)) //ZFA_FILIAL, ZFA_COD
								If ZFA->(DbSeek( FWxFilial("ZFA") + Alltrim(nNumTit)  ))
									RecLock("ZFA",.F.)
									ZFA->ZFA_APRMOV := 'R'
									ZFA->ZFA_USRAPR := AllTrim( __cUserID )
									ZFA->ZFA_NOMAPR := AllTrim(UsrRetName(__cUserID))
									ZFA->ZFA_DTAPRO := Date()
									ZFA->ZFA_HRAPRO := Time()	
									ZFA->ZFA_OBSAPR	:= Alltrim(FwCutOff(cDscObs,.T.)) //Everson-19/03/19. Chamado 044314.
									MSUnlock()
								EndIf

							ElseIf cOrigem = "ADLOG053P"

								//Everson-28/03/19. Chamado 044314.
								DbSelectArea("ZFF")			
								ZFF->(DbSetOrder(3)) //ZFF_FILIAL, ZFF_COD
								If ZFF->(DbSeek( FWxFilial("ZFF") + Alltrim(nNumTit)  ))
									RecLock("ZFF",.F.)
									ZFF->ZFF_APROVA := 'R'
									ZFF->ZFF_USRAPR := AllTrim( __cUserID )
									ZFF->ZFF_NOMAPR := AllTrim(UsrRetName(__cUserID))
									ZFF->ZFF_DTAPR  := Date()
									ZFF->ZFF_HRAPRO := Time()
									ZFF->ZFF_OBSAPR	:= Alltrim(FwCutOff(cDscObs,.T.)) //Everson-19/03/19. Chamado 044314.
									MSUnlock()
								EndIf
								//

							EndIf					

						ENDIF

						if cOpc = '2'
							lRetAcaoAR := .T.
						Endif

						if sTpApr = "000001"
							cAssunto := "Reprovação - Titulo de PA"
						elseif sTpApr = "000004"
							cAssunto := "Reprovação - Alçada de Titulo"
						elseif sTpApr = "000005"
							cAssunto := "Reprovação - Nivel de Segurança"
						elseif sTpApr = "000011"
							cAssunto := "Reprovação - Alçada de Desbloqueio de Título"	
						endif

						// Chamado n. 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL - FWNM - 02/12/2019
						cAssunto := cAssunto + " - " + AllTrim(SM0->M0_NOME)
						//
						cMensagem := u_ADFINW46(  cCodigo , nNumTit , nParctit , cCodCli , cLojCli , ZC7->ZC7_VLRBLQ , AllTrim(UsrRetName(__cUserID)) , sTpApr , lAprTit , 'R' , cDscObs )
						if !Empty(cDestRepr)
							If lEnvWFCA
								u_F050EnvWF( cAssunto , cMensagem , cDestRepr , '' )
							Endif
						Endif

					ENDIF
					ZC7->(DbSkip())
				END
			ENDIF

		Else
			// FWNM - INTEGRACAO PROJETOS DE INVESTIMENTOS (AF8) - 12/07/2018

			ConOut("ADFIN046P REPROVA __cUserID " + __cUserID)
			ConOut("ADFIN046P REPROVA UsrRetName(__cUserID) " + UsrRetName(__cUserID))
			
			c_ZC7_USRAPR := AllTrim( __cUserID )
			c_ZC7_NOMAPR := AllTrim(UsrRetName(__cUserID))
			c_ZC7_DTAPR  := msDate()
			c_ZC7_HRAPR  := Time()

			ConOut("ADFIN046P REPROVA COPC " + COPC)

			// Ricardo Lima-22/01/2019	
			if cOpc = '1'
				cRevPrj := AllTrim(TMPZC7->ZC7_REVPRJ)
			Else
				dbSelectArea("ZC7")
				dbGoto(val( cRecnoZC ))
				cCodPrj := ZC7->ZC7_PROJET
				cRevPrj := AllTrim(ZC7->ZC7_REVPRJ)
			Endif	

			ConOut("ADFIN046P REPROVA ZC7 " + FWxFilial("ZC7"))
			
			ZC7->( dbSetOrder(3) ) // ZC7_FILIAL+ZC7_PROJET
			If ZC7->( dbSeek( FWxFilial("ZC7") + cCodPrj + cRevPrj ) )

				// Chamado n. 046284 - FWNM
				Do While ZC7->( !EOF() ) .and. ZC7->ZC7_FILIAL == FWxFilial("ZC7") .and. ZC7->ZC7_PROJET == cCodPrj .and. ZC7->ZC7_REVPRJ == cRevPrj
					
					If AllTrim(ZC7->ZC7_USRAPR) == AllTrim( __cUserID ) // Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 29/04/2019
					
						If Empty(ZC7->ZC7_REPROV)
	
							RecLock("ZC7", .f.)
	
								ZC7->ZC7_REPROV := AllTrim( __cUserID )
								ZC7->ZC7_USRAPR := AllTrim( __cUserID )
								ZC7->ZC7_NOMAPR := AllTrim(UsrRetName(__cUserID))
								ZC7->ZC7_DTAPR  := msDate()
								ZC7->ZC7_HRAPR  := Time()
								ZC7->ZC7_OBS    := "[RECUSADO] " + cDscObs
		
							ZC7->( msUnlock() )
	
							// Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 30/04/2019
							If cOpc = '2'
								lRetAcaoAR := .T.
							Endif
						
						EndIf

					Else
					
						// 14/05/19 | FWNM | Adaptacao para aprovadores quando rejeitado | TI => para nao aparecer as revisoes anteriores quando vistador reprovar! 
						RecLock("ZC7", .f.)
							ZC7->ZC7_REPROV := AllTrim( __cUserID )
						ZC7->( msUnlock() )
						//
					
					EndIf

					ZC7->( dbSkip() )
				
				EndDo
				//

			EndIf

			ConOut("ADFIN046P REPROVA AFE " + cCodPrj)
			
			AFE->( dbSetOrder(1) ) // AFE_FILIAL+AFE_PROJET+AFE_REVISA
			AFE->( dbSeek(xFilial("AFE")+cCodPrj) )         

			// fwnm - Chamado n. 046284
			AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
			If AF8->( dbSeek( FWxFilial("AF8") + cCodPrj ) )
				nConsumo := u_ADCOM017P(AF8->AF8_PROJET,"BROWSE") // Chamado n. 049774 || OS 051078 || ENGENHARIA || SILVANA || 8406 || PROJETO ENCERRADO - FWNM - 25/06/2019
				If nConsumo <= 0
					RecLock("AF8", .f.)
						AF8->AF8_FASE   := cFaseRej
					AF8->( msUnLock() )
				EndIf
			EndIf
			ConOut("ADFIN046P REPROVA AF8 " + cFaseRej)
			//

			// Envia email de aviso de aprovação para solicitante
			ConOut("ADFIN046P EMAIL " + AF8->AF8_XUSER)
			
			aDadWF := {}
			cMail  := ""
			cMail  := UsrRetMail(AF8->AF8_XUSER)
							
			// Chamado n. 053243 || OS 054600 || CONTROLADORIA || DAIANE || (11) || WOKFLOW PROJETOS - FWNM - 08/11/2019
			If Left(cCodPrj,2) == "03" // Projetos SC
				If !Empty(cMail)
					cMail  += ";" + GetMV("MV_#AF8MAI",,"daiane.moreira@adoro.com.br")
				Else
					cMail  := GetMV("MV_#AF8MAI",,"daiane.moreira@adoro.com.br")
				EndIf
			EndIf

			//If cOpc == "1"
				cMail  := UsrRetMail(AF8->AF8_XUSER)
				aAdd( aDadWF, { cCodPrj, cRevPrj, AllTrim( __cUserID ), AllTrim(UsrRetName(__cUserID)), msDate(), Time(), "[RECUSADO] " + cDscObs, cMail, AF8->AF8_DESCRI, AF8->AF8_XUSER } )
				u_ADPRJ004P(aDadWF, "RECUSA") //ALTERACAO WILLIAM COSTA ERRO NA FUNCAO ENVIAWF
			//EndIf

		EndIf

	END TRANSACTION

	RestArea(aArea)
	RestArea(aAreaAF8) // fwnm - Chamado n. 046284

Return( .T. )

/*{Protheus.doc} Static Function CHKAPROV
	Checa aprovacoes para liberar projeto
	@type  Function
	@author FWNM
	@since 06/05/2019
	@version 01
	@history Chamado 047440
*/

Static Function ChkAprov(cCodPrj, cRevPrj)

	Local lRet     := .t.
	Local aAreaZC7 := ZC7->( GetArea() )
	
	ZC7->( dbSetOrder(3) ) // ZC7_FILIAL+ZC7_PROJET
	If ZC7->( dbSeek( FWxFilial("ZC7") + cCodPrj + cRevPrj ) )
			
		Do While ZC7->( !EOF() ) .and. ZC7->ZC7_FILIAL == FWxFilial("ZC7") .and. ZC7->ZC7_PROJET == cCodPrj .and. ZC7->ZC7_REVPRJ == cRevPrj
		
			// projeto possui reprovacoes
			If !Empty(ZC7->ZC7_REPROV)
				lRet := .f.
				Exit
			EndIf
			
			// projeto possui aprovacoes pendentes 
			If Empty(ZC7->ZC7_DTAPR) .and. Empty(ZC7->ZC7_HRAPR)
				lRet := .f.
				Exit
			EndIf 
		
			ZC7->( dbSkip() )
		EndDo

	EndIf

	RestArea( aAreaZC7 )

Return lRet
/*/{Protheus.doc} User Function E2XPTCRTA
	Usado no campo virtual ZC7_XBLQN5
	@type  Function
	@author Fernando Macieira
	@since 02/12/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@Chamado 053347
/*/
User Function E2XPTCRTA()

	Local cRet := ""

	U_ADINF009P('ADFIN046P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Central Aprovação')

	If ZC7->ZC7_RECPAG == "P" .and. ZC7->ZC7_TPBLQ = "000005"
		DbSelectArea("SE2")
		DbSetorder(6)  // E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
		IF DbSeek( ZC7->ZC7_FILIAL + ZC7->ZC7_CLIFOR + ZC7->ZC7_LOJA + ZC7->ZC7_PREFIX + ZC7->ZC7_NUM + ZC7->ZC7_PARCEL + ZC7->ZC7_TIPO )
			If Substr(SE2->E2_XPTCRTA,1,1) = 'S'
				cRet += '1-Bloq p/ estar fora Média Valor,'//+chr(13)+chr(10)
			EndIf
			if Substr(SE2->E2_XPTCRTA,2,1) = 'S'
				cRet += '2-Bloq p/ Lançamento Nfe s/ XML,'//+chr(13)+chr(10)
			EndIf
			If Substr(SE2->E2_XPTCRTA,3,1) = 'S'
				cRet += '3-Bloq p/ Entrada de Nfe s/ PC,'//+chr(13)+chr(10)
			EndIf
			If Substr(SE2->E2_XPTCRTA,4,1) = 'S'
				cRet += '4-Bloq p/ Não receber Vistoria Fisica Recebimento,'//+chr(13)+chr(10)
			endif
			If Substr(SE2->E2_XPTCRTA,5,1) = 'S'
				cRet += '5-Bloq Aprov Tecnica Serviço,'//+chr(13)+chr(10)
			endif
			If Substr(SE2->E2_XPTCRTA,6,1) = 'S'
				cRet += '6-Bloq Integra p/ Modulo/subsistema,'//+chr(13)+chr(10)
			endif
			If Substr(SE2->E2_XPTCRTA,7,1) = 'S'
				cRet += '7-Bloq Valid Chv Primaria,'//+chr(13)+chr(10)
			endif
			If Substr(SE2->E2_XPTCRTA,8,1) = 'S'
				cRet += '8-Bloq p/ Duplicidade(Fornecedor+Valor+Emissão),'//+chr(13)+chr(10)
			endif
			If Substr(SE2->E2_XPTCRTA,9,1) = 'S'
				cRet += '9-Bloq Pagto Posterior Entrega,'//+chr(13)+chr(10)
			endif
		ENDIF
	EndIf

Return cRet

/*/{Protheus.doc} User Function UPNATURE
	Usado no campo (virtual) ZC7_XNATUR
	@type  Function
	@author Fernando Macieira
	@since 02/12/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@Chamado 053347
/*/
User Function UpNature()

	Local cRet := ""

	U_ADINF009P('ADFIN046P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Central Aprovação')

	If !Empty(ZC7->ZC7_NUM)
		If ZC7->ZC7_RECPAG == "P"
			dbSelectArea("SE2")
			dbSetorder(6)  // E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
			If dbSeek( ZC7->ZC7_FILIAL + ZC7->ZC7_CLIFOR + ZC7->ZC7_LOJA + ZC7->ZC7_PREFIX + ZC7->ZC7_NUM + ZC7->ZC7_PARCEL + ZC7->ZC7_TIPO )
				cRet := AllTrim(SE2->E2_NATUREZ + " - " + Posicione("SED",1,FWxFilial("SED")+SE2->E2_NATUREZ,"ED_DESCRIC"))
			EndIf
		EndIf
	EndIf

Return cRet

/*/{Protheus.doc} Static Function GetZFCMAX
	(long_description)
	@type  Function
	@author FWNM
	@since 07/05/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history Ticket 11556   - Fernando Maci - 27/04/2021 - Processo Trabalhista - Títulos
/*/
Static Function GetZFCMAX()

	Local nVlrMax  := 0
	Local aAreaZCF := ZCF->( GetArea() )

	ZCF->( dbSetOrder(1) ) // ZCF_FILIAL, ZCF_CODIGO, ZCF_ITEM, ZCF_APROVA, R_E_C_N_O_, D_E_L_E_T_
	If ZCF->( dbSeek(FWxFilial("ZCF")+ZC7->ZC7_TPBLQ) )

		Do While ZCF->( !EOF() ) .and. ZCF->ZCF_FILIAL==FWxFilial("ZCF") .and. ZCF->ZCF_CODIGO==ZC7->ZC7_TPBLQ

			If AllTrim(ZCF->ZCF_APROVA) == AllTrim(__cUserID)
				nVlrMax := ZCF->ZCF_VLRMAX
				Exit
			EndIf

			ZCF->( dbSkip() )

		EndDo

	EndIf

	RestArea( aAreaZCF )
	
Return nVlrMax
