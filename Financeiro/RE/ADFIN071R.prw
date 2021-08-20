#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "RWMAKE.CH" 
#INCLUDE "AP5MAIL.CH" 
#INCLUDE "FWBROWSE.CH"   
#Include "TCBrowse.ch"

/*/{Protheus.doc} User Function ADFIN071R
	Relatorio de Titulos Faturados de Rede e Clientes
	@type  Function
	@author William Costa
	@since 08/01/2020
	@version version
	@history Chamado TI    - William Costa   - 29/01/2020 - Retirado o campo A1_MSBLQL para listar todos os clientes até os inativos, para verificar se tem divida financeira.
	@history Ticket 001545 - Abel Babini     - 14/09/2020 - Ajuste no fechamento das tabelas temporárias
	@history Ticket 18602  - Fernando Sigoli - 20/08/2021 - Alterado rotina para trazer como defult nos parametros Ano-1
/*/

User Function ADFIN071R()
	
	Local aArea			:= GetArea()
	Local oGroup1       := NIL
	Local oGroup2       := NIL
	Local oFechar       := NIL
	Local oFont 		:= TFont():New(,,-14,,.T.)
	Local oPnlFiltro    := NIL
	Local oTxtFiltro    := NIL
	Local oOkFiltro     := NIL
	Local aTFFiltro  	:= {}
	Local oPnlFCmp      := NIL
	Local oDtIniFat     := NIL
	Local oDtFinFat     := NIL
	Local oDtIniFin     := NIL
	Local oDtFinFin     := NIL
	Local oGrpTab	    := NIL
	Local oGrpCmp	    := NIL
	Local oPnlFilt1     := NIL
	Local oGrpFCPort    := NIL
	Local oMkFxPort     := NIL
	Local oGRpFCRede    := NIL
	Local oMkRede       := NIL
	Local oGRpFCCli     := NIL
	Local oMkCliente    := NIL
	Local bIFiltro		:= {|| oTFFiltro:SetOption(2),filtro1(@oPnlFilt1,@oMkRede,@oMkCliente,@oMkFxPort),oPnlFiltro:Show()}
	Local i				:= 1
	Private lHistFilt1	:= .F.
	Private cFiltPortad	:= ""
	Private cFiltRede	:= ""
	Private cFiltRedeR	:= ""
	Private cFiltCli	:= ""
	Private cFiltCliR	:= ""
	Private aHistPortad	:= {}
	Private aHistRede	:= {}
	Private aHisTCli	:= {}
	Private oCobranca   := NIL
	Private dDtIniFat	:= CTOD('01/' + '01/' + CVALTOCHAR((YEAR(DATE()) - 1))) //Ticket 18602  - Fernando Sigoli - 20/08/2021 
	Private dDtFinFat	:= CTOD('31/' + '12/' + CVALTOCHAR((YEAR(DATE()))))
	Private dDtIniFin	:= CTOD('01/' + '01/' + CVALTOCHAR((YEAR(DATE()) - 1))) //Ticket 18602  - Fernando Sigoli - 20/08/2021 
	Private dDtFinFin	:= CTOD('31/' + '12/' + CVALTOCHAR((YEAR(DATE()))))
	Private oTFFiltro   := NIL
	Private aplanfat    := {}
	Private nplanfat	:= 2	
	Private oplanfat    := NIL
	Private oGrpplanfat := NIL
	Private aplanfin    := {}
	Private nplanfin	:= 2	
	Private oplanfin    := NIL
	Private oGrpplanfin := NIL
	Private cBuscaRede  := NIL
	Private cBuscaCli   := NIL
	Private oBuscaRede  := NIL
	Private oBuscaCli   := NIL
	Private oBtnBscRede := NIL
	Private oBtnBscCli  := NIL
	Private aTipoRel    := NIL
	Private oTipoRel    := NIL
	Private nTipoRel    := 1
	Private oGrpTipo    := NIL
	Private oCheckZero  := NIL
	Private oCheckNCC   := NIL
	Private lRetirarNCC := .F.
	Private lFiltroZero := .F.
	Private oGrpFiltro  := NIL
	Private oTempMRede  := NIL
	Private oTempMCli   := NIL
	Private oTempMPort  := NIL
	Private oTempFat    := NIL
	Private oTempFin    := NIL
	Private oTempFat1   := NIL
	Private oTempFin1   := NIL
	Private aCampos     := ''

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Titulos Faturados de Rede e Clientes')

	//Log de acesso.
	logAcesso("ADFIN071R")

	oCobranca			:= MsDialog():Create()
	oCobranca:cName     := "oCobranca"
	oCobranca:cCaption  := "REDE SEGMENTO"
	oCobranca:nLeft     := 34
	oCobranca:nTop      := 222
	oCobranca:nWidth    := 1200
	oCobranca:nHeight   := 550
	oCobranca:lShowHint := .F.
	oCobranca:lCentered := .T.
	
	oGroup1  := TGroup():Create(oCobranca,001,545,235,595,"",,,.T.)
	
	//Filtro.
	oPnlFiltro  := TPanel():New(002,005,,oCobranca,,.T.,,CLR_BLACK,CLR_WHITE,535,233,,.T.)
	oPnlFiltro:SetCss("QLabel{background-color: #F9F9F9;}")

	oTxtFiltro := TSay():New(006,005,{||"Filtro de Dados"},oPnlFiltro,,oFont,,,,.T.,CLR_RED,CLR_WHITE,250,20)

	aTFFiltro := {"Filtro SQL","Rede/Cliente/Portador"}
	oTFFiltro := TFolder():New(020,005,aTFFiltro,,oPnlFiltro,,,,.T.,,525,195)

	oPnlFCmp := TPanel():New(000,000,,oTFFiltro:aDialogs[1],,.T.,,CLR_BLACK,CLR_WHITE,535,233,,)
	oGrpTab	 := TGroup():Create(oPnlFCmp,005,005,180,140,"Parâmetros"   ,,,.T.)

	oDtIniFat := TGet():New(020,010,{|u|If(PCount() == 0,dDtIniFat,dDtIniFat := u)},oPnlFCmp,060,010,"@D",;
	{||NaoVazio()},;
	0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtIniFat",,,,.T.,,,"Data Inicial Faturamento",1) 
	 
	oDtFinFat := TGet():New(050,010,{|u|If(PCount() == 0,dDtFinFat,dDtFinFat := u)},oPnlFCmp,060,010,"@D",;
	{||NaoVazio()},;
	0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtFinFat",,,,.T.,,,"Data Final Faturamento",1)

	oDtIniFin := TGet():New(020,070,{|u|If(PCount() == 0,dDtIniFin,dDtIniFin := u)},oPnlFCmp,060,010,"@D",;
	{||NaoVazio()},;
	0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtIniFin",,,,.T.,,,"Data Inicial Financeiro",1) 
	 
	oDtFinFin := TGet():New(050,070,{|u|If(PCount() == 0,dDtFinFin,dDtFinFin := u)},oPnlFCmp,060,010,"@D",;
	{||NaoVazio()},;
	0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtFinFin",,,,.T.,,,"Data Final Financeiro",1)

	oGrpplanfat := TGroup():Create(oPnlFCmp,072,010,110,060,"Planilha Fat"   ,,,.T.)
	oGrpplanfin := TGroup():Create(oPnlFCmp,072,070,110,120,"Planilha Fin"   ,,,.T.)
	
	aplanfat := {"Ano","Mês","Dia"}
	oplanfat := TRadMenu():New (080,020,aplanfat,,oPnlFCmp,,,,,,,,100,12,,,,.T.)     
	oplanfat:bSetGet := {|u| Iif (PCount() == 0, nplanfat, nplanfat := u)}

	aplanfin := {"Ano","Mês","Dia"}
	oplanfin := TRadMenu():New (080,080,aplanfin,,oPnlFCmp,,,,,,,,100,12,,,,.T.)     
	oplanfin:bSetGet := {|u| Iif (PCount() == 0, nplanfin, nplanfin := u)}

	oGrpTipo := TGroup():Create(oPnlFCmp,110,030,140,095,"Tipo Relátorio"   ,,,.T.)

	aTipoRel := {"Rede","Cliente"}
	oTipoRel := TRadMenu():New (120,050,aTipoRel,,oPnlFCmp,,,,,,,,100,12,,,,.T.)     
	oTipoRel:bSetGet := {|u| Iif (PCount() == 0, nTipoRel, nTipoRel := u)}
	
	oGrpFiltro := TGroup():Create(oPnlFCmp,145,030,175,120,"Filtros"   ,,,.T.)
	oCheckZero := TCheckBox():New(152,032,'Retirar Zero',{|u|if( pcount()>0, lFiltroZero:= u, lFiltroZero)},oPnlFCmp,100,210,,,,,,,,.T.,,,)
	oCheckNCC  := TCheckBox():New(162,032,'Retirar Col NCC Financeiro',{|u|if( pcount()>0, lRetirarNCC:= u, lRetirarNCC)},oPnlFCmp,100,210,,,,,,,,.T.,,,)

	oGrpCmp	 := TGroup():Create(oPnlFCmp,010,105,260,100,"Campos"    ,,,.T.)

	oPnlFilt1  := TPanel():New(000,000,,oTFFiltro:aDialogs[2],,.T.,,CLR_BLACK,CLR_WHITE,535,233,,)
	oGRpFCRede := TGroup():Create(oPnlFilt1,005,005,180,175,"Rede",,,.T.)
	oGRpFCCli  := TGroup():Create(oPnlFilt1,005,185,180,352,"Cliente",,,.T.)
	oGrpFCPort := TGroup():Create(oPnlFilt1,005,355,180,522,"Portador",,,.T.)

	cBuscaRede := Space(8)
	oBuscaRede := TGet():New(015,010,{|u|If(PCount() == 0,cBuscaRede,cBuscaRede := u)},oPnlFilt1,145,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cBuscaRede",,,,.T.,,,"Busca:",1) 
	oBtnBscRede:= TButton():New(023,155,"Ok",oPnlFilt1,{|| Iif( Valtype(oMkRede) == "O",;
	MsAguarde({|| bscRede(@oMkRede,cBuscaRede) },"Aguarde","Localizando " + cBuscaRede + "..."),;
	MsgStop("Não há dados carregados.","Função ADFIN071R"))  },018,010,,,.F.,.T.,.F.,,.F.,,,.F. )
    
	cBuscaCli := Space(8)
	oBuscaCli := TGet():New(015,190,{|u|If(PCount() == 0,cBuscaCli,cBuscaCli := u)},oPnlFilt1,143,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cBuscaCli",,,,.T.,,,"Busca:",1) 
	oBtnBscCli:= TButton():New(023,333,"Ok",oPnlFilt1,{|| Iif( Valtype(oMkCliente) == "O",;
	MsAguarde({|| bscCliente(@oMkCliente,cBuscaCli) },"Aguarde","Localizando " + cBuscaCli + "..."),;
	MsgStop("Não há dados carregados.","Função ADFIN071R"))  },018,010,,,.F.,.T.,.F.,,.F.,,,.F. )
    
	oOkFiltro  := TButton():New(219,490,"Gerar Relatorio",oPnlFiltro,{|| filtros(oPnlFiltro,oCobranca,@oPnlFilt1,@oMkRede,@oMkCliente,@oMkFxPort) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oOkFiltro:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #0000CC, stop: 1 #190033);color: white}")

	oPnlFiltro:Hide()
	
	oGroup2	 := TGroup():Create(oCobranca,239,005,260,595,"",,,.T.)

	oFechar	 := TButton():New(245,550,"Fechar",oCobranca,{||oCobranca:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")	

	oCobranca:Activate(,,,.T.,{||.T.},,{|| Eval(bIFiltro) })	
	
	If Select("TPORTAD") > 0
		TPORTAD->(DbCloseArea())

	EndIf

	If Select("TREDE") > 0
		TREDE->(DbCloseArea())

	EndIf

	//INICIO Ticket 001545 - Abel Babini     - 14/09/2020 - Ajuste no fechamento das tabelas temporárias
	IF oTempFat != NIL
		oTempFat:Delete() 
	ENDIF

	IF oTempFin != NIL
		oTempFin:Delete() 
	ENDIF

	IF oTempMPort != NIL
		oTempMPort:Delete() 
	ENDIF

	IF oTempMRede != NIL
		oTempMRede:Delete() 
	ENDIF

	IF oTempMCli != NIL
		oTempMCli:Delete() 
	ENDIF

	IF oTempFat1 != NIL
		oTempFat1:Delete() 
	ENDIF

	IF oTempFin1 != NIL
		oTempFin1:Delete() 
	ENDIF

	//FIM Ticket 001545 - Abel Babini     - 14/09/2020 - Ajuste no fechamento das tabelas temporárias

	RestArea(aArea)

Return Nil

Static Function filtro1(oPnlFilt1,oMkRede,oMkCliente,oMkFxPort)
	
	Local aArea		:= GetArea()

	If Empty(dDtIniFat)
		RestArea(aArea)
		Return Nil

	EndIf

	MsAguarde({||filtRede(@oPnlFilt1,@oMkRede)},"Aguarde","Carregando filtro de rede...")

	MsAguarde({||filtCliente(@oPnlFilt1,@oMkCliente)},"Aguarde","Carregando filtro de Cliente...")

	MsAguarde({||filtPortad(@oPnlFilt1,@oMkFxPort)},"Aguarde","Carregando filtro de portador...")

	RestArea(aArea)

Return(Nil)

Static Function logAcesso(cRotina)

	Local aArea		:= GetArea()

	cRotina := Alltrim(cValToChar(cRotina))

	//Log.
	RecLock("ZBE",.T.)
	ZBE->ZBE_FILIAL := xFilial("SE1")
	ZBE->ZBE_DATA	:= Date()
	ZBE->ZBE_HORA	:= cValToChar(Time())
	ZBE->ZBE_USUARI	:= cUserName
	ZBE->ZBE_LOG	:= "ACESSO A ROTINA " + cRotina
	ZBE->ZBE_MODULO	:= "FINANCEIRO"
	ZBE->ZBE_ROTINA	:= "ADFIN030P"
	MsUnlock()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function geraRelatorio
	Carregar interface com os títulos.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function geraRelatorio(oCobranca,oPnlFilt1,oMkRede,oMkFxPort)

	LOCAL aArea	      := GetArea()
	LOCAL oRelatorio  := NIL
	LOCAL oFecharRel  := NIL
	LOCAL oBrowseFat  := NIL
	LOCAL oBrowseFin  := NIL
	LOCAL oPanelFat   := NIL
	LOCAL oPanelFin   := NIL
	LOCAL nTotfatNf   := 0
	LOCAL nTotfatNcc  := 0
	LOCAL nTotfat     := 0
	LOCAL nTotfinNf   := 0
	LOCAL nTotfinNcc  := 0
	LOCAL nTotfin     := 0
	Local oFontRel    := TFont():New('Courier new',,-18,.T.)
	Local oSayplanfat := NIL
	Local oSayplanfin := NIL
	Local oSayNome    := NIL
	Local cCnpjs      := ''
	Local cAno        := ''
	Local cAnoOld     := ''
	Local cMes        := ''
	Local cMesOld     := ''

	// *** INICIO VALIDACAO *** //

	IF nTipoRel == 1 .AND. ALLTRIM(cFiltRedeR) == "''"

		MSGALERT("Não foi escolhida nenhuma rede, impossivel continuar", "geraRelatorio")
		Return .F.

	ENDIF	

	IF nTipoRel == 2 .AND. ALLTRIM(cFiltCliR) == "''"

		MSGALERT("Não foi escolhida nenhum Cliente, impossivel continuar", "geraRelatorio")
		Return .F.

	ENDIF	

	// *** FINAL VALIDACAO *** //
	
	// INICIO FATURAMENTO

	oTempFat := FWTemporaryTable():New("TEMPFAT")

	// INICIO Monta os campos da tabela
	aCampos := {}
	AADD(aCampos,{"TM_DATA" ,"C",11,0})	
	AADD(aCampos,{"TM_ANO"  ,"C",04,0})
	AADD(aCampos,{"TM_NF"	,"N",17,2})
	AADD(aCampos,{"TM_NCC"  ,"N",17,2})
	AADD(aCampos,{"TM_TOTAL","N",17,2})
	AADD(aCampos,{"TM_MEDIA","N",17,2})
	AADD(aCampos,{"TM_PMV"  ,"N",08,2})
	AADD(aCampos,{"TM_PMVP" ,"N",08,2})
	AADD(aCampos,{"TM_KG"   ,"N",17,2})

	// FINAL Monta os campos da tabela
    
	oTempFat:SetFields(aCampos)
	//oTempFat:AddIndex("01", {"TM_DATA"} )
	
	//------------------
	//Criação da tabela
	//------------------
	oTempFat:Create()
	
	//Obtém o script sql para os CNPJS.
	cQuery := sqlCNPJ(nTipoRel,IIF(nTipoRel == 1,cFiltRedeR,cFiltCliR))
	
	IF EMPTY(cQuery)

		RESTAREA(aArea)
		RETURN .F.

	ENDIF

	IF SELECT("D_CNPJREDE") > 0

		D_CNPJREDE->(DBCLOSEAREA())

	ENDIF

	TCQUERY cQuery NEW ALIAS "D_CNPJREDE"

	DBSELECTAREA("D_CNPJREDE")
	D_CNPJREDE->(DBGOTOP())
	WHILE !D_CNPJREDE->(EOF())
		
		cCnpjs := cCnpjs + "'" + ALLTRIM(D_CNPJREDE->A1_CGC) + "',"

		D_CNPJREDE->(DBSKIP())

	ENDDO

	cCnpjs := Substr(cCnpjs,1,Len(cCnpjs) - 1)

	//Obtém o script sql.
	cQuery := sqlFat(cCnpjs)
	
	IF EMPTY(cQuery)

		RESTAREA(aArea)
		RETURN .F.

	ENDIF

	IF SELECT("D_FATURAMENTO") > 0

		D_FATURAMENTO->(DBCLOSEAREA())

	ENDIF

	TCQUERY cQuery NEW ALIAS "D_FATURAMENTO"
	
	nTotfatNf  := 0
	nTotfatNcc := 0
	nTotfat    := 0
	cAno       := ''
	cAnoOld    := ''
	cMes       := ''
	cMesOld    := ''

	DBSELECTAREA("D_FATURAMENTO")
	D_FATURAMENTO->(DBGOTOP())

	IF nplanfat == 2 // mês

		cAno    := CVALTOCHAR(D_FATURAMENTO->ANO)
		cAnoOld := CVALTOCHAR(D_FATURAMENTO->ANO)

	ENDIF
	
	IF nplanfat == 3 // dia	

		cAno    := SUBSTR(D_FATURAMENTO->E1_EMISSAO,1,4)
		cAnoOld := SUBSTR(D_FATURAMENTO->E1_EMISSAO,1,4)
		cMes    := SUBSTR(D_FATURAMENTO->E1_EMISSAO,5,2)
		cMesOld := SUBSTR(D_FATURAMENTO->E1_EMISSAO,5,2)

	ENDIF

	WHILE !D_FATURAMENTO->(EOF())

		IF lFiltroZero == .T. .AND. D_FATURAMENTO->TOTAL == 0

			D_FATURAMENTO->(DBSKIP())
			LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

		ENDIF

		IF nplanfat == 2 // mês

			cAno        := CVALTOCHAR(D_FATURAMENTO->ANO)

			IF  cAnoOld <> cAno

				cQuery:= SqlAnoFat(cCnpjs,cAnoOld)

				TCQUERY cQuery NEW ALIAS "D_ANOFAT"

				WHILE !D_ANOFAT->(EOF())

					IF lFiltroZero == .T. .AND. D_ANOFAT->TOTAL == 0

						D_ANOFAT->(DBSKIP())
						LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

					ENDIF

					RECLOCK("TEMPFAT",.T.)

						TEMPFAT->TM_DATA  := "ANO " + cAnoOld
						TEMPFAT->TM_ANO   := cAnoOld
						TEMPFAT->TM_NF    := D_ANOFAT->NF
						TEMPFAT->TM_NCC   := D_ANOFAT->NCC
						TEMPFAT->TM_MEDIA := 0
						TEMPFAT->TM_PMV   := PrazoMedia(cAnoOld,'FAT','ANO','VENDA',cCnpjs)
						TEMPFAT->TM_PMVP  := PrazoMedia(cAnoOld,'FAT','ANO','PONDERADA',cCnpjs)
						TEMPFAT->TM_TOTAL := D_ANOFAT->TOTAL
						TEMPFAT->TM_KG    := 0
						
					MSUNLOCK()

					D_ANOFAT->(DBSKIP())

				ENDDO	
				D_ANOFAT->(DBCLOSEAREA())

				cAnoOld     := cAno

			ENDIF
		ENDIF

		IF nplanfat == 3 // dia	

			cMes :=  SUBSTR(D_FATURAMENTO->E1_EMISSAO,5,2)

			IF  cMesOld <> cMes

				cQuery:= SqlMesFat(cCnpjs,cAnoOld,cMesOld)

				TCQUERY cQuery NEW ALIAS "D_MESFAT"

				WHILE !D_MESFAT->(EOF())

					IF lFiltroZero == .T. .AND. D_MESFAT->TOTAL == 0

						D_MESFAT->(DBSKIP())
						LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

					ENDIF

					RECLOCK("TEMPFAT",.T.)

						TEMPFAT->TM_DATA  := "MÊS " + cMesOld
						TEMPFAT->TM_ANO   := cAnoOld
						TEMPFAT->TM_NF    := D_MESFAT->NF
						TEMPFAT->TM_NCC   := D_MESFAT->NCC
						TEMPFAT->TM_MEDIA := 0
						TEMPFAT->TM_PMV   := PrazoMedia(cAnoOld + '/' + cMesOld,'FAT','MES','VENDA',cCnpjs)
						TEMPFAT->TM_PMVP  := PrazoMedia(cAnoOld + '/' + cMesOld,'FAT','MES','PONDERADA',cCnpjs)
						TEMPFAT->TM_TOTAL := D_MESFAT->TOTAL
						TEMPFAT->TM_KG    := 0

					MSUNLOCK()

					D_MESFAT->(DBSKIP())

				ENDDO	
				D_MESFAT->(DBCLOSEAREA())

				cMesOld := cMes

			ENDIF

			cAno :=  SUBSTR(D_FATURAMENTO->E1_EMISSAO,1,4)

			IF  cAnoOld <> cAno

				cQuery:= SqlAnoFat(cCnpjs,cAnoOld)

				TCQUERY cQuery NEW ALIAS "D_ANOFAT"

				WHILE !D_ANOFAT->(EOF())

					IF lFiltroZero == .T. .AND. D_ANOFAT->TOTAL == 0

						D_ANOFAT->(DBSKIP())
						LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

					ENDIF

					RECLOCK("TEMPFAT",.T.)

						TEMPFAT->TM_DATA  := "ANO " + cAnoOld
						TEMPFAT->TM_ANO   := cAnoOld
						TEMPFAT->TM_NF    := D_ANOFAT->NF
						TEMPFAT->TM_NCC   := D_ANOFAT->NCC
						TEMPFAT->TM_MEDIA := 0
						TEMPFAT->TM_PMV   := PrazoMedia(cAnoOld,'FAT','ANO','VENDA',cCnpjs)
						TEMPFAT->TM_PMVP  := PrazoMedia(cAnoOld,'FAT','ANO','PONDERADA',cCnpjs)
						TEMPFAT->TM_TOTAL := D_ANOFAT->TOTAL
						TEMPFAT->TM_KG    := 0

					MSUNLOCK()

					D_ANOFAT->(DBSKIP())

				ENDDO	
				D_ANOFAT->(DBCLOSEAREA())

				cAnoOld     := cAno

			ENDIF

		ENDIF
		
		RECLOCK("TEMPFAT",.T.)

			IF nplanfat == 1 // ano

				TEMPFAT->TM_DATA  := CVALTOCHAR(D_FATURAMENTO->ANO)
				TEMPFAT->TM_ANO   := CVALTOCHAR(D_FATURAMENTO->ANO)

			ELSEIF nplanfat == 2 // mês

				TEMPFAT->TM_DATA  := CVALTOCHAR(D_FATURAMENTO->ANO) + '/' + STRZERO(D_FATURAMENTO->MES,2)
				TEMPFAT->TM_ANO   := CVALTOCHAR(D_FATURAMENTO->ANO)

			ELSE // dia	

				TEMPFAT->TM_DATA  := DTOC(STOD(D_FATURAMENTO->E1_EMISSAO))
				TEMPFAT->TM_ANO   := CVALTOCHAR(YEAR(STOD(D_FATURAMENTO->E1_EMISSAO)))

			ENDIF

			TEMPFAT->TM_NF    := D_FATURAMENTO->NF
			nTotfatNf         := nTotfatNf + D_FATURAMENTO->NF
			TEMPFAT->TM_NCC   := D_FATURAMENTO->NCC
			nTotfatNcc        := nTotfatNcc + D_FATURAMENTO->NCC
			TEMPFAT->TM_MEDIA := 0
			TEMPFAT->TM_PMV   := PrazoMedia(TEMPFAT->TM_DATA,'FAT','NORMAL','VENDA',cCnpjs)
			TEMPFAT->TM_PMVP  := PrazoMedia(TEMPFAT->TM_DATA,'FAT','NORMAL','PONDERADA',cCnpjs)
			TEMPFAT->TM_TOTAL := D_FATURAMENTO->TOTAL
			nTotfat           := nTotfat + D_FATURAMENTO->TOTAL
			TEMPFAT->TM_KG    := 0
		
		MSUNLOCK()

		D_FATURAMENTO->(DBSKIP())

	ENDDO
    
	// *** INICIO TOTAIS FATURAMENTO 
	IF nplanfat == 2 // mês

		cQuery:= SqlAnoFat(cCnpjs,cAnoOld)

		TCQUERY cQuery NEW ALIAS "D_ANOFAT"

		WHILE !D_ANOFAT->(EOF())

			IF lFiltroZero == .T. .AND. D_ANOFAT->TOTAL == 0

				D_ANOFAT->(DBSKIP())
				LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

			ENDIF

			RECLOCK("TEMPFAT",.T.)

				TEMPFAT->TM_DATA  := "ANO " + cAnoOld
				TEMPFAT->TM_ANO   := cAnoOld
				TEMPFAT->TM_NF    := D_ANOFAT->NF
				TEMPFAT->TM_NCC   := D_ANOFAT->NCC
				TEMPFAT->TM_MEDIA := 0
				TEMPFAT->TM_PMV   := PrazoMedia(cAnoOld,'FAT','ANO','VENDA',cCnpjs)
				TEMPFAT->TM_PMVP  := PrazoMedia(cAnoOld,'FAT','ANO','PONDERADA',cCnpjs)
				TEMPFAT->TM_TOTAL := D_ANOFAT->TOTAL
				TEMPFAT->TM_KG    := 0

			MSUNLOCK()

			D_ANOFAT->(DBSKIP())

		ENDDO	
		D_ANOFAT->(DBCLOSEAREA())
	
	ENDIF

	IF nplanfat == 3 // dia	

		cMes :=  SUBSTR(D_FATURAMENTO->E1_EMISSAO,5,2)

		IF  cMesOld <> cMes

			cQuery:= SqlMesFat(cCnpjs,cAnoOld,cMesOld)

			TCQUERY cQuery NEW ALIAS "D_MESFAT"

			WHILE !D_MESFAT->(EOF())

				IF lFiltroZero == .T. .AND. D_MESFAT->TOTAL == 0

					D_MESFAT->(DBSKIP())
					LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

				ENDIF

				RECLOCK("TEMPFAT",.T.)

					TEMPFAT->TM_DATA  := "MÊS " + cMesOld
					TEMPFAT->TM_ANO   := cAnoOld
					TEMPFAT->TM_NF    := D_MESFAT->NF
					TEMPFAT->TM_NCC   := D_MESFAT->NCC
					TEMPFAT->TM_MEDIA := 0
					TEMPFAT->TM_PMV   := PrazoMedia(cAnoOld + '/' + cMesOld,'FAT','MES','VENDA',cCnpjs)
					TEMPFAT->TM_PMVP  := PrazoMedia(cAnoOld + '/' + cMesOld,'FAT','MES','PONDERADA',cCnpjs)
					TEMPFAT->TM_TOTAL := D_MESFAT->TOTAL
					TEMPFAT->TM_KG    := 0

				MSUNLOCK()
				
				D_MESFAT->(DBSKIP())

			ENDDO	
			D_MESFAT->(DBCLOSEAREA())

			cMesOld := cMes

		ENDIF

		cAno :=  SUBSTR(D_FATURAMENTO->E1_EMISSAO,1,4)

		IF  cAnoOld <> cAno

			cQuery:= SqlAnoFat(cCnpjs,cAnoOld)

			TCQUERY cQuery NEW ALIAS "D_ANOFAT"

			WHILE !D_ANOFAT->(EOF())

				IF lFiltroZero == .T. .AND. D_ANOFAT->TOTAL == 0

					D_ANOFAT->(DBSKIP())
					LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

				ENDIF

					RECLOCK("TEMPFAT",.T.)

						TEMPFAT->TM_DATA  := "ANO " + cAnoOld
						TEMPFAT->TM_ANO   := cAnoOld
						TEMPFAT->TM_NF    := D_ANOFAT->NF
						TEMPFAT->TM_NCC   := D_ANOFAT->NCC
						TEMPFAT->TM_MEDIA := 0
						TEMPFAT->TM_PMV   := PrazoMedia(cAnoOld,'FAT','ANO','VENDA',cCnpjs)
						TEMPFAT->TM_PMVP  := PrazoMedia(cAnoOld,'FAT','ANO','PONDERADA',cCnpjs)
						TEMPFAT->TM_TOTAL := D_ANOFAT->TOTAL
						TEMPFAT->TM_KG    := 0

					MSUNLOCK()

				D_ANOFAT->(DBSKIP())

			ENDDO	
			D_ANOFAT->(DBCLOSEAREA())

			cAnoOld     := cAno

		ENDIF

	ENDIF

	RECLOCK("TEMPFAT",.T.)

		TEMPFAT->TM_DATA  := 'TOTAL GERAL'
		TEMPFAT->TM_ANO   := ''
		TEMPFAT->TM_NF    := nTotfatNf
		TEMPFAT->TM_NCC   := nTotfatNcc
		TEMPFAT->TM_MEDIA := 0
		TEMPFAT->TM_PMV   := PrazoMedia(DTOC(dDtIniFat),'FAT','TOTAL','VENDA',cCnpjs)
		TEMPFAT->TM_PMVP  := PrazoMedia(DTOC(dDtIniFat),'FAT','TOTAL','PONDERADA',cCnpjs)
		TEMPFAT->TM_TOTAL := nTotfat
		TEMPFAT->TM_KG    := 0
	
	MSUNLOCK()

	// *** FINAL TOTAIS FATURAMENTO 

	// FINAL FATURAMENTO
	
	//INICIO FINANCEIRO
	//Cria Arquivos Temporários

	oTempFin := FWTemporaryTable():New("TEMPFIN")

	// INICIO Monta os campos da tabela
	aCampos := {}
	AADD(aCampos,{"TM_DATA" ,"C",11,0})	
	AADD(aCampos,{"TM_NF"	,"N",17,2})
	AADD(aCampos,{"TM_NCC"  ,"N",17,2})
	AADD(aCampos,{"TM_TOTAL","N",17,2})

	// FINAL Monta os campos da tabela
    
	oTempFin:SetFields(aCampos)
	//oTempFin:AddIndex("01", {"TM_DATA"} )
	
	//------------------
	//Criação da tabela
	//------------------
	oTempFin:Create()

	//Obtém o script sql.
	cQuery := sqlFin(cCnpjs)
	
	IF EMPTY(cQuery)

		RESTAREA(aArea)
		RETURN .F.

	ENDIF

	IF SELECT("D_FINANCEIRO") > 0

		D_FINANCEIRO->(DBCLOSEAREA())

	ENDIF

	TCQUERY cQuery NEW ALIAS "D_FINANCEIRO"
	
	nTotfinNf  := 0
	nTotfinNcc := 0
	nTotfin    := 0
	cAno       := ''
	cAnoOld    := ''
	cMes       := ''
	cMesOld    := ''

	DBSELECTAREA("D_FINANCEIRO")
	D_FINANCEIRO->(DBGOTOP())

	IF nplanfin == 2 // mês

		cAno    := CVALTOCHAR(D_FINANCEIRO->ANO)
		cAnoOld := CVALTOCHAR(D_FINANCEIRO->ANO)

	ENDIF
	
	IF nplanfin == 3 // dia	

		cAno    := SUBSTR(D_FINANCEIRO->E1_VENCREA,1,4)
		cAnoOld := SUBSTR(D_FINANCEIRO->E1_VENCREA,1,4)
		cMes    := SUBSTR(D_FINANCEIRO->E1_VENCREA,5,2)
		cMesOld := SUBSTR(D_FINANCEIRO->E1_VENCREA,5,2)

	ENDIF

	WHILE !D_FINANCEIRO->(EOF())

		IF lFiltroZero == .T. .AND. D_FINANCEIRO->TOTAL == 0

			D_FINANCEIRO->(DBSKIP())
			LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

		ENDIF

		IF nplanfin == 2 // mês

			cAno := CVALTOCHAR(D_FINANCEIRO->ANO)

			IF  cAnoOld <> cAno

				cQuery:= SqlAnoFin(cCnpjs,cAnoOld)

				TCQUERY cQuery NEW ALIAS "D_ANOFIN"

				WHILE !D_ANOFIN->(EOF())

					IF lFiltroZero == .T. .AND. D_ANOFIN->TOTAL == 0

						D_ANOFIN->(DBSKIP())
						LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

					ENDIF

					RECLOCK("TEMPFIN",.T.)

						TEMPFIN->TM_DATA  := "ANO " + cAnoOld
						TEMPFIN->TM_NF    := D_ANOFIN->NF
						TEMPFIN->TM_NCC   := D_ANOFIN->NCC
						TEMPFIN->TM_TOTAL := D_ANOFIN->TOTAL

					MSUNLOCK()

					D_ANOFIN->(DBSKIP())

				ENDDO	
				D_ANOFIN->(DBCLOSEAREA())

				cAnoOld := cAno

			ENDIF
		ENDIF

		IF nplanfin == 3 // dia	

			cMes :=  SUBSTR(D_FINANCEIRO->E1_VENCREA,5,2)

			IF  cMesOld <> cMes

				cQuery:= SqlMesFin(cCnpjs,cAnoOld,cMesOld)

				TCQUERY cQuery NEW ALIAS "D_MESFIN"

				WHILE !D_MESFIN->(EOF())

					IF lFiltroZero == .T. .AND. D_MESFIN->TOTAL == 0

						D_MESFIN->(DBSKIP())
						LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

					ENDIF

					RECLOCK("TEMPFIN",.T.)

						TEMPFIN->TM_DATA  := "MÊS " + cMesOld
						TEMPFIN->TM_NF    := D_MESFIN->NF
						TEMPFIN->TM_NCC   := D_MESFIN->NCC
						TEMPFIN->TM_TOTAL := D_MESFIN->TOTAL

					MSUNLOCK()

					D_MESFIN->(DBSKIP())

				ENDDO	
				D_MESFIN->(DBCLOSEAREA())

				cMesOld := cMes

			ENDIF

			cAno := SUBSTR(D_FINANCEIRO->E1_VENCREA,1,4)

			IF  cAnoOld <> cAno

				cQuery:= SqlAnoFin(cCnpjs,cAnoOld)

				TCQUERY cQuery NEW ALIAS "D_ANOFIN"

				WHILE !D_ANOFIN->(EOF())

					IF lFiltroZero == .T. .AND. D_ANOFIN->TOTAL == 0

						D_ANOFIN->(DBSKIP())
						LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

					ENDIF

					RECLOCK("TEMPFIN",.T.)

						TEMPFIN->TM_DATA  := "ANO " + cAnoOld
						TEMPFIN->TM_NF    := D_ANOFIN->NF
						TEMPFIN->TM_NCC   := D_ANOFIN->NCC
						TEMPFIN->TM_TOTAL := D_ANOFIN->TOTAL

					MSUNLOCK()

					D_ANOFIN->(DBSKIP())

				ENDDO	
				D_ANOFIN->(DBCLOSEAREA())

				cAnoOld     := cAno

			ENDIF

		ENDIF
		
		RECLOCK("TEMPFIN",.T.)

			IF nplanfin == 1 // ano

				TEMPFIN->TM_DATA  := CVALTOCHAR(D_FINANCEIRO->ANO)

			ELSEIF nplanfin == 2 // mês

				TEMPFIN->TM_DATA  := CVALTOCHAR(D_FINANCEIRO->ANO) + '/' + STRZERO(D_FINANCEIRO->MES,2)

			ELSE // dia	

				TEMPFIN->TM_DATA  := DTOC(STOD(D_FINANCEIRO->E1_VENCREA))

			ENDIF

			TEMPFIN->TM_NF    := D_FINANCEIRO->NF
			nTotfinNf         := nTotfinNf + D_FINANCEIRO->NF
			TEMPFIN->TM_NCC   := D_FINANCEIRO->NCC
			nTotfinNcc        := nTotfinNcc + D_FINANCEIRO->NCC
			TEMPFIN->TM_TOTAL := D_FINANCEIRO->TOTAL
			nTotfin           := nTotfin + D_FINANCEIRO->TOTAL
		
		MSUNLOCK()

		D_FINANCEIRO->(DBSKIP())

	ENDDO

	// *** INICIO TOTAIS FINANCEIRO 
	IF nplanfin == 2 // mês

		cQuery:= SqlAnoFin(cCnpjs,cAnoOld)

		TCQUERY cQuery NEW ALIAS "D_ANOFIN"

		WHILE !D_ANOFIN->(EOF())

			IF lFiltroZero == .T. .AND. D_ANOFIN->TOTAL == 0

				D_ANOFIN->(DBSKIP())
				LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

			ENDIF

				RECLOCK("TEMPFIN",.T.)

					TEMPFIN->TM_DATA  := "ANO " + cAnoOld
					TEMPFIN->TM_NF    := D_ANOFIN->NF
					TEMPFIN->TM_NCC   := D_ANOFIN->NCC
					TEMPFIN->TM_TOTAL := D_ANOFIN->TOTAL

				MSUNLOCK()

			D_ANOFIN->(DBSKIP())

		ENDDO	
		D_ANOFIN->(DBCLOSEAREA())
	
	ENDIF

	IF nplanfin == 3 // dia	

		cMes :=  SUBSTR(D_FINANCEIRO->E1_VENCREA,5,2)

		IF  cMesOld <> cMes

			cQuery:= SqlMesFin(cCnpjs,cAnoOld,cMesOld)

			TCQUERY cQuery NEW ALIAS "D_MESFIN"

			WHILE !D_MESFIN->(EOF())

				IF lFiltroZero == .T. .AND. D_MESFIN->TOTAL == 0

					D_MESFIN->(DBSKIP())
					LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

				ENDIF

				RECLOCK("TEMPFIN",.T.)

					TEMPFIN->TM_DATA  := "MÊS " + cMesOld
					TEMPFIN->TM_NF    := D_MESFIN->NF
					TEMPFIN->TM_NCC   := D_MESFIN->NCC
					TEMPFIN->TM_TOTAL := D_MESFIN->TOTAL

				MSUNLOCK()

				D_MESFIN->(DBSKIP())

			ENDDO	
			D_MESFIN->(DBCLOSEAREA())

			cMesOld := cMes

		ENDIF

		cAno := SUBSTR(D_FINANCEIRO->E1_VENCREA,1,4)

		IF  cAnoOld <> cAno

			cQuery:= SqlAnoFin(cCnpjs,cAnoOld)

			TCQUERY cQuery NEW ALIAS "D_ANOFIN"

			WHILE !D_ANOFIN->(EOF())

				IF lFiltroZero == .T. .AND. D_ANOFIN->TOTAL == 0

					D_ANOFIN->(DBSKIP())
					LOOP // NÃO CARREGA O REGISTRO QUANDO O FILTRO ZERO ESTA MARCADO E O VALOR TOTAL É IGUAL A ZERO

				ENDIF

				RECLOCK("TEMPFIN",.T.)

					TEMPFIN->TM_DATA  := "ANO " + cAnoOld
					TEMPFIN->TM_NF    := D_ANOFIN->NF
					TEMPFIN->TM_NCC   := D_ANOFIN->NCC
					TEMPFIN->TM_TOTAL := D_ANOFIN->TOTAL

				MSUNLOCK()

				D_ANOFIN->(DBSKIP())

			ENDDO	
			D_ANOFIN->(DBCLOSEAREA())

			cAnoOld     := cAno

		ENDIF

	ENDIF

	RECLOCK("TEMPFIN",.T.)

		TEMPFIN->TM_DATA  := 'TOTAL GERAL'
		TEMPFIN->TM_NF    := nTotfinNf
		TEMPFIN->TM_NCC   := nTotfinNcc
		TEMPFIN->TM_TOTAL := nTotfin
	
	MSUNLOCK()

	// *** FINAL TOTAIS FINANCEIRO

	//FINAL FINANCEIRO

	MediaEKgFat(cCnpjs)
	D_FATURAMENTO->(DBGOTOP())
	TEMPFAT->(DBGOTOP())
	D_FINANCEIRO->(DBGOTOP())
	TEMPFIN->(DBGOTOP())

	oRelatorio			 := MsDialog():Create()
	oRelatorio:cName     := "oRelatorio"
	oRelatorio:cCaption  := "Relatorio Gerado em: " + DTOC(DATE()) + " às " + TIME()
	oRelatorio:nLeft     := 0 
	oRelatorio:nTop      := 0 
	oRelatorio:nWidth    := 1340
	oRelatorio:nHeight   := 630
	oRelatorio:lShowHint := .F.
	oRelatorio:lCentered := .T.

	oPanelFat := TPanel():New(000,000,,oRelatorio,,.T.,,CLR_BLACK,CLR_WHITE,420,280,,.T.)
    
	oBrowseFat:= TCBrowse():New(01,01,418,270,,,,oPanelFat,,,,,,,,,,,,,"TEMPFAT",.T.,,,,.T.,)
    oBrowseFat:bLDblClick := {|| MsAguarde({|| DBCLICKFAT(cCnpjs) },"Aguarde","Carregando Dados dos Títulos...") }
	oBrowseFat:AddColumn(TCColumn():New("Data"  ,{|| TEMPFAT->TM_DATA}                                      ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowseFat:AddColumn(TCColumn():New("Vl.NF" ,{|| TRANSFORM(TEMPFAT->TM_NF   ,"@E 999,999,999,999.99")},,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowseFat:AddColumn(TCColumn():New("Vl NCC",{|| TRANSFORM(TEMPFAT->TM_NCC  ,"@E 999,999,999,999.99")},,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowseFat:AddColumn(TCColumn():New("Total" ,{|| TRANSFORM(TEMPFAT->TM_TOTAL,"@E 999,999,999,999.99")},,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowseFat:AddColumn(TCColumn():New("Média" ,{|| TRANSFORM(TEMPFAT->TM_MEDIA,"@E 999,999,999,999.99")},,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowseFat:AddColumn(TCColumn():New("PMV"   ,{|| TRANSFORM(TEMPFAT->TM_PMV  ,"@E 9,999.99"          )},,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowseFat:AddColumn(TCColumn():New("PMVP"  ,{|| TRANSFORM(TEMPFAT->TM_PMVP ,"@E 9,999.99"          )},,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowseFat:AddColumn(TCColumn():New("Kg   " ,{|| TRANSFORM(TEMPFAT->TM_KG   ,"@E 99,999,999,999,999")},,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowseFat:SetBlkColor({|| IIF("T" $ SUBSTR(TEMPFAT->TM_DATA,1,1) .OR. "A" $ SUBSTR(TEMPFAT->TM_DATA,1,1) .OR. "M" $ SUBSTR(TEMPFAT->TM_DATA,1,1), CLR_WHITE, CLR_BLACK)})
	oBrowseFat:SetBlkBackColor({|| IIF("T" $ SUBSTR(TEMPFAT->TM_DATA,1,1), CLR_BLACK , IIF("A" $ SUBSTR(TEMPFAT->TM_DATA,1,1), CLR_BLUE, IIF("M" $ SUBSTR(TEMPFAT->TM_DATA,1,1), CLR_BLUE, Nil)))})

	oPanelFin := TPanel():New(000,420,,oRelatorio,,.T.,,CLR_BLACK,CLR_WHITE,340,280,,.T.)

	oBrowseFin:= TCBrowse():New(01,01,247,270,,,,oPanelFin,,,,,,,,,,,,,"TEMPFIN",.T.,,,,.T.,)
	oBrowseFin:bLDblClick := {|| MsAguarde({|| DBCLICKFIN(cCnpjs) },"Aguarde","Carregando Dados dos Títulos...") }
	oBrowseFin:AddColumn(TCColumn():New("Data"  ,{|| TEMPFIN->TM_DATA}                                    ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowseFin:AddColumn(TCColumn():New("Vl.NF" ,{|| TRANSFORM(TEMPFIN->TM_NF   ,"@E 999,999,999,999.99")},,,,"LEFT",,.F.,.F.,,,,.F.,))

	IF lRetirarNCC == .F.

		oBrowseFin:AddColumn(TCColumn():New("Vl NCC",{|| TRANSFORM(TEMPFIN->TM_NCC  ,"@E 999,999,999,999.99")},,,,"LEFT",,.F.,.F.,,,,.F.,))

	ENDIF

	oBrowseFin:AddColumn(TCColumn():New("Total" ,{|| TRANSFORM(TEMPFIN->TM_TOTAL,"@E 999,999,999,999.99")},,,,"LEFT",,.F.,.F.,,,,.F.,))
    oBrowseFin:SetBlkColor({|| IIF("T" $ SUBSTR(TEMPFIN->TM_DATA,1,1) .OR. "A" $ SUBSTR(TEMPFIN->TM_DATA,1,1) .OR. "M" $ SUBSTR(TEMPFIN->TM_DATA,1,1), CLR_WHITE, CLR_BLACK)})
	oBrowseFin:SetBlkBackColor({|| IIF("T" $ SUBSTR(TEMPFIN->TM_DATA,1,1), CLR_BLACK , IIF("A" $ SUBSTR(TEMPFIN->TM_DATA,1,1), CLR_BLUE, IIF("M" $ SUBSTR(TEMPFIN->TM_DATA,1,1), CLR_BLUE, Nil)))})

	oSayplanfat  := TSay():New(290,010,{||'Planilha 1 - Faturamento'},oRelatorio,,oFontRel,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oSayNome     := TSay():New(290,150,{||IIF(nTipoRel == 1,'Rede: ' + NOMEREDE(),'Cliente: ' + NOMECLIENTE()) },oRelatorio,,oFontRel,,,,.T.,CLR_RED,CLR_WHITE,300,50)
	oSayplanfin  := TSay():New(290,480,{||'Planilha 2 - Financeiro' },oRelatorio,,oFontRel,,,,.T.,CLR_RED,CLR_WHITE,200,20)
    oFecharRel   := TButton():New(290,620,"Fechar",oRelatorio,{||oRelatorio:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oFecharRel:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")	

	oRelatorio:Activate(,,,.T.,{||.T.},,{||.T.})

	//Fecha arquivo temporário.
	DBSELECTAREA("TEMPFAT")
	TEMPFAT->(DBCLOSEAREA())
	DBSELECTAREA("TEMPFIN")
	TEMPFIN->(DBCLOSEAREA())
    
	// Inicio Limpando os campos de OK das redes e clientes
	DBSELECTAREA("TREDE")
	TREDE->(DBGOTOP())
	WHILE !TREDE->(EOF())

		RecLock("TREDE",.F.)		

			TREDE->OK := ""

		MSUNLOCK()

		TREDE->(DBSKIP())

	ENDDO

	DBSELECTAREA("TCLI")
	TCLI->(DBGOTOP())
	WHILE !TCLI->(EOF())

		RecLock("TCLI",.F.)		

			TCLI->OK := ""

		MSUNLOCK()

		TCLI->(DBSKIP())

	ENDDO

	TREDE->(DBGOTOP())
	TCLI->(DBGOTOP())
	// Final Limpando os campos de OK das redes e clientes
	oMkRede:oBrowse:Refresh()

	oPnlFilt1:Refresh()

	RESTAREA(aArea)

Return .T.

/*/{Protheus.doc} Static Function sqlFat
	Script sql base.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function sqlFat(cCnpjs)

	Local cQuery:= ""

	IF nplanfat == 1 // ano

		cQuery := " SELECT YEAR(CAST(E1_EMISSAO AS DATETIME)) AS 'ANO', "

	ELSEIF nplanfat == 2 // mês

		cQuery := " SELECT YEAR(CAST(E1_EMISSAO AS DATETIME)) AS 'ANO', "
		cQuery += " MONTH(CAST(E1_EMISSAO AS DATETIME)) AS 'MES', "  

	ELSE // dia	

		cQuery := " SELECT E1_EMISSAO, "

	ENDIF
	
	cQuery += " SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_VALOR ELSE 0 END) AS 'NF', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_VALOR * (-1) ELSE 0 END),2) AS 'NCC', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_VALOR ELSE 0 END),2) - ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_VALOR ELSE 0 END),2) AS 'TOTAL' "
	cQuery+= "  FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
	cQuery+= " INNER JOIN " + RETSQLNAME("SA1") + " SA1 WITH (NOLOCK) "
	cQuery += "         ON A1_COD          = E1_CLIENTE "
	cQuery += "        AND A1_LOJA         = E1_LOJA "
	cQuery += "        AND A1_CGC         IN (" + cCnpjs + ") "
	cQuery += "        AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += "      WHERE E1_EMISSAO     >= '" + DTOS(dDtIniFat) + "' "
	cQuery += " 	   AND E1_EMISSAO     <= '" + DTOS(dDtFinFat) + "' "
	cQuery += "        AND E1_PORTADO     IN (" + cFiltPortad + ") "
	cQuery += "    	   AND E1_TIPO        IN ('NF','NCC') "
	cQuery += "        AND SE1.D_E_L_E_T_ <> '*' "
		
	IF nplanfat == 1 // ano

		cQuery += " GROUP BY YEAR(CAST(E1_EMISSAO AS DATETIME)) "
		cQuery += " ORDER BY YEAR(CAST(E1_EMISSAO AS DATETIME)) " 

		
	ELSEIF nplanfat == 2 // mês

		cQuery += " GROUP BY MONTH(CAST(E1_EMISSAO AS DATETIME)),YEAR(CAST(E1_EMISSAO AS DATETIME)) "
		cQuery += " ORDER BY YEAR(CAST(E1_EMISSAO AS DATETIME)),MONTH(CAST(E1_EMISSAO AS DATETIME)) " 
		

	ELSE // dia	

		cQuery += " GROUP BY E1_EMISSAO "
		cQuery += " ORDER BY E1_EMISSAO " 
		
	ENDIF

	IIF(Len(cQuery) > 15980,Eval({|| cQuery := "", MsgStop("Não será possível executar a consulta pois o script sql excede o tamanho máximo (15.980).","Função sqlFat")}),Nil)	

Return cQuery

/*/{Protheus.doc} Static Function sqlFin
	Script sql base.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function sqlFin(cCnpjs)

	Local aArea	:= GetArea()
	Local cQuery:= ""

	IF nplanfin == 1 // ano

		cQuery := " SELECT YEAR(CAST(E1_VENCREA AS DATETIME)) AS 'ANO', "

	ELSEIF nplanfin == 2 // mês

		cQuery := " SELECT YEAR(CAST(E1_VENCREA AS DATETIME)) AS 'ANO', "
		cQuery += " MONTH(CAST(E1_VENCREA AS DATETIME)) AS 'MES', "  

	ELSE // dia	

		cQuery := " SELECT E1_VENCREA, "

	ENDIF
	
	cQuery += " SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_SALDO ELSE 0 END) AS 'NF', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_SALDO * (-1) ELSE 0 END),2) AS 'NCC', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_SALDO ELSE 0 END),2) - ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_SALDO ELSE 0 END),2) AS 'TOTAL' "
	cQuery+= "  FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
	cQuery+= " INNER JOIN " + RETSQLNAME("SA1") + " SA1 WITH (NOLOCK) "
	cQuery += "         ON A1_COD          = E1_CLIENTE "
	cQuery += "        AND A1_LOJA         = E1_LOJA "
	cQuery += "        AND A1_CGC         IN (" + cCnpjs + ") "
	cQuery += "        AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += "      WHERE E1_VENCREA     >= '" + DTOS(dDtIniFin) + "' "
	cQuery += " 	   AND E1_VENCREA     <= '" + DTOS(dDtFinFin) + "' "
	cQuery += "        AND E1_PORTADO     IN (" + cFiltPortad + ") "
	cQuery += "    	   AND E1_TIPO        IN ('NF','NCC') "
	cQuery += "        AND SE1.D_E_L_E_T_ <> '*' "
		
	IF nplanfin == 1 // ano

		cQuery += " GROUP BY YEAR(CAST(E1_VENCREA AS DATETIME)) "
		cQuery += " ORDER BY YEAR(CAST(E1_VENCREA AS DATETIME)) " 

		
	ELSEIF nplanfin == 2 // mês

		cQuery += " GROUP BY MONTH(CAST(E1_VENCREA AS DATETIME)),YEAR(CAST(E1_VENCREA AS DATETIME)) "
		cQuery += " ORDER BY YEAR(CAST(E1_VENCREA AS DATETIME)),MONTH(CAST(E1_VENCREA AS DATETIME)) " 
		
	ELSE // dia	

		cQuery += " GROUP BY E1_VENCREA "
		cQuery += " ORDER BY E1_VENCREA " 
		
	ENDIF

	IIF(Len(cQuery) > 15980,Eval({|| cQuery := "", MsgStop("Não será possível executar a consulta pois o script sql excede o tamanho máximo (15.980).","Função sqlFat")}),Nil)

	RestArea(aArea)

Return cQuery

/*/{Protheus.doc} Static Function bscRede
	Busca rede na MsSelect.
	@type  Function
	@author Everson
	@since 27/06/2017
	@version version
/*/

Static Function bscRede(oMkRede,cCodigo)

	Local nAux	:= 1
	Local nPos	:= 1
	
	cCodigo := Alltrim(cValToChar(cCodigo))

	If Empty(cCodigo)
		RestArea(aArea)
		Return Nil

	EndIf

	If Select("TREDE") <= 0
		RestArea(aArea)
		Return Nil

	EndIf

	DbSelectArea("TREDE")
	TREDE->(DbGoTop())

	While ! TREDE->(Eof())

		If cCodigo $(Alltrim(cValToChar(TREDE->TMP_RED))) .OR. ;
		   cCodigo $(Alltrim(cValToChar(TREDE->TMP_DESC)))

			nPos := nAux

			Exit

		EndIf

		TREDE->(DbSkip())

		nAux:= nAux + 1

	EndDo

	If nPos <= 0

		MsgStop("Registro não encontrado","Função bscRede")
		Return Nil

	EndIf

	oMkRede:oBrowse:nPos
	oMkRede:oBrowse:REFRESH()
    	
Return Nil

/*/{Protheus.doc} Static Function filtros
	Aplica filtros. 
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function filtros(oPnlFiltro,oCobranca,oPnlFilt1,oMkRede,oMkCliente,oMkFxPort)

	Local aArea		:= GetArea()
	
	lHistFilt1  := .F.

	//Filtro de rede.
	If Select("TREDE") > 0
		cFiltRede := ""
		cFiltRedeR:= ""
		aHistRede := {}
		DbSelectArea("TREDE")
		TREDE->(DbGoTop())

		If TREDE->(Eof())
			cFiltRede := "''"
			cFiltRedeR:= "''"

		Else

			While ! TREDE->(Eof())

				If Empty(Alltrim(cValToChar(TREDE->OK))) .And. ! Empty(Alltrim(cValToChar(TREDE->TMP_RED)))
					cFiltRede += "'" + Alltrim(cValToChar(TREDE->TMP_RED)) + "',"

				ElseIf ! Empty(Alltrim(cValToChar(TREDE->OK))) .And. ! Empty(Alltrim(cValToChar(TREDE->TMP_RED)))

					cFiltRedeR += "'" + Alltrim(cValToChar(TREDE->TMP_RED)) + "',"

					Aadd(aHistRede,{Alltrim(cValToChar(TREDE->TMP_RED))})

				EndIf

				TREDE->(DbSkip())
			EndDo
			cFiltRede := Substr(cFiltRede,1,Len(cFiltRede) - 1)
			cFiltRedeR:= Substr(cFiltRedeR,1,Len(cFiltRedeR) - 1)

			If Empty(cFiltRede)
				cFiltRede := "''"

			EndIf

			If Empty(cFiltRedeR)
				cFiltRedeR:= "''"

			EndIf

		EndIf

	EndIf

	//Filtro de Cliente.
	If Select("TCLI") > 0

		cFiltCli := ""
		cFiltCliR:= ""
		aHisTCli := {}
		DbSelectArea("TCLI")
		TCLI->(DbGoTop())

		If TCLI->(Eof())
			cFiltCli := "''"
			cFiltCliR:= "''"

		Else

			While ! TCLI->(Eof())

				If Empty(Alltrim(cValToChar(TCLI->OK))) .And. ! Empty(Alltrim(cValToChar(TCLI->TMP_COD)))
					cFiltCli += "'" + Alltrim(cValToChar(TCLI->TMP_COD)) + "',"

				ElseIf ! Empty(Alltrim(cValToChar(TCLI->OK))) .And. ! Empty(Alltrim(cValToChar(TCLI->TMP_COD)))

					cFiltCliR += "'" + Alltrim(cValToChar(TCLI->TMP_COD)) + "',"

					Aadd(aHisTCli,{Alltrim(cValToChar(TCLI->TMP_COD))})

				EndIf

				TCLI->(DbSkip())
			EndDo
			cFiltCli := Substr(cFiltCli,1,Len(cFiltCli) - 1)
			cFiltCliR:= Substr(cFiltCliR,1,Len(cFiltCliR) - 1)

			If Empty(cFiltCli)
				cFiltCli := "''"

			EndIf

			If Empty(cFiltCliR)
				cFiltCliR:= "''"

			EndIf

		EndIf

	EndIf

	//Filtro de Portador.
	cFiltPortad := "''"
	If Select("TPORTAD") > 0
		cFiltPortad := ""
		aHistPortad := {}
		DbSelectArea("TPORTAD")
		TPORTAD->(DbGoTop())

		If TPORTAD->(Eof())
			cFiltPortad := "''"

		Else

			While ! TPORTAD->(Eof())

				If ! Empty(TPORTAD->OK) 
					cFiltPortad += "'" + Alltrim(cValToChar(TPORTAD->TMP_PORT)) + "',"
					Aadd(aHistPortad,{Alltrim(cValToChar(TPORTAD->TMP_PORT))})

				EndIf

				TPORTAD->(DbSkip())
			EndDo
			cFiltPortad := Substr(cFiltPortad,1,Len(cFiltPortad) - 1)
			If Empty(cFiltPortad)
				cFiltPortad := "''"

			EndIf

		EndIf

	EndIf

	TREDE->(DBGOTOP())
	TCLI->(DBGOTOP())
	TPORTAD->(DBGOTOP()) 

	//Carrega Relatorio.
	MsAguarde({|| geraRelatorio(oCobranca,oPnlFilt1,oMkRede,oMkFxPort) },"Aguarde","Carregando dados...")

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function filtPortad
	Filtro por portador.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function filtPortad(oPnlFilt1,oMkFxPort)

	Local aArea		  := GetArea()
	Local cQuery	  := ""
	Local aPortadores := {}
	Local i			  := 1
	Local nLinha	  := 5
	Local nColuna	  := 5
	Local aCpoBro	  := {}
	Local cMark   	  := GetMark() 
	Local nPosPortad
	Local nNomePort	  := ""

	//Valida o objeto.
	If Valtype(oMkFxPort) == "O"
		FreeObj(oMkFxPort:oBrowse)
		FreeObj(oMkFxPort)

	EndIf

	//Obtém o script sql.
	cQuery := sqlPortador()

	//
	If Empty(cQuery)
		RestArea(aArea)
		Return Nil

	EndIf

	If Select("D_FILTPORTA") > 0
		D_FILTPORTA->(DbCloseArea())

	EndIf

	TcQuery cQuery New Alias "D_FILTPORTA"
	DbSelectArea("D_FILTPORTA")
	D_FILTPORTA->(DbGoTop())

	Aadd(aPortadores,"") //GRAVA UM REGISTRO EM BRANCO PARA TITULOS SEM PORTADOR
	While ! D_FILTPORTA->(Eof())

		Aadd(aPortadores,cValToChar(D_FILTPORTA->A6_COD))

		D_FILTPORTA->(DbSkip())

	EndDo

	DbCloseArea("D_FILTPORTA")

	Asort(aPortadores)

	If Select("TPORTAD") > 0

		TPORTAD->(DbCloseArea())

	EndIf

	oTempMPort := FWTemporaryTable():New("TPORTAD")

	// INICIO Monta os campos da tabela
	aCampos := {}
	Aadd(aCampos,{"OK" 	   ,"C",02,0})
	Aadd(aCampos,{"TMP_PORT" ,"C",05,0})
	Aadd(aCampos,{"TMP_NMPT" ,"C",40,0})

	// FINAL Monta os campos da tabela
    
	oTempMPort:SetFields(aCampos)
	oTempMPort:AddIndex("01", {"TMP_PORT"} )
	
	//------------------
	//Criação da tabela
	//------------------
	oTempMPort:Create()

	FOR i := 1 TO Len(aPortadores)

		IF ALLTRIM(aPortadores[i]) == ''

			nNomePort := 'SEM PORTADOR'

		ELSE

			nNomePort := Posicione("SA6",1,xFilial("SA6") + aPortadores[i], "A6_NOME") //CHAMADO; 041135 - FERNANDO SIGOIL 20/04/2018

		ENDIF

		IF lHistFilt1 //Verifica se já foi aplicado filtro.

			//Recarrega filtro de faixa de atraso conforme já aplicado.
			nPosPortad := 0
			nPosPortad := Ascan(aHistPortad,{|x| Alltrim(cValToChar(x[1])) == Alltrim(cValToChar(aPortadores[i])) })

			RecLock("TPORTAD",.T.)		
			TPORTAD->OK			:= cMark //Iif(nPosPortad == 0,"",cMark)
			TPORTAD->TMP_PORT	:= cValToChar(aPortadores[i])
			TPORTAD->TMP_NMPT	:= nNomePort
			MsunLock()

		ELSE

			RecLock("TPORTAD",.T.)		
			TPORTAD->OK			:= cMark
			TPORTAD->TMP_PORT	:= cValToChar(aPortadores[i])
			TPORTAD->TMP_NMPT	:= nNomePort
			MsunLock()

		ENDIF

	NEXT i

	IF Len(aPortadores) == 0

		RecLock("TPORTAD",.T.)		
		TPORTAD->OK			:= ""
		TPORTAD->TMP_PORT	:= ""
		TPORTAD->TMP_NMPT	:= ""
		MsunLock()	

	ENDIF

	Aadd(aCpoBro,{"OK"		 ,, ""})		
	Aadd(aCpoBro,{"TMP_PORT",,"Portador"})
	Aadd(aCpoBro,{"TMP_NMPT",,"Nome"})		

	oMkFxPort := MsSelect():New("TPORTAD","OK","",aCpoBro ,.F.,@cMark ,{037,360,170,520},,,oPnlFilt1,,)
	oMkFxPort:bMark := {| | DispPortad(oMkFxPort,cMark)}
	oMkFxPort:oBrowse:bAllMark := {|| PortadInvert(oMkFxPort,cMark) }
	Eval(oMkFxPort:oBrowse:bGoTop)
	oMkFxPort:oBrowse:Refresh()

	oPnlFilt1:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function filtRede
	Filtro por rede.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function filtRede(oPnlFilt1,oMkRede)

	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local aRedes	:= {}
	Local i			:= 1
	Local nLinha	:= 5
	Local nColuna	:= 5
	Local aCpoBro	:= {}
	Local cMark   	:= GetMark() 
	Local nPosRede
	Local cIndex

	//Valida o objeto.
	If Valtype(oMkRede) == "O"
		FreeObj(oMkRede:oBrowse)
		FreeObj(oMkRede)

	EndIf

	//Valida o objeto.
	If Valtype(oMkRede) == "O"
		FreeObj(oMkRede:oBrowse)
		FreeObj(oMkRede)

	EndIf

	//Obtém o script sql.
	cQuery := sqlRede()

	If Empty(cQuery)
		RestArea(aArea)
		Return Nil

	EndIf

	If Select("D_FILTREDE") > 0
		D_FILTREDE->(DbCloseArea())

	EndIf

	TcQuery cQuery New Alias "D_FILTREDE"
	DbSelectArea("D_FILTREDE")
	D_FILTREDE->(DbGoTop())

	If Select("TREDE") > 0

		TREDE->(DbCloseArea())

	EndIf

	oTempMRede := FWTemporaryTable():New("TREDE")

	// INICIO Monta os campos da tabela
	aCampos := {}
	Aadd(aCampos,{"OK" 	   ,"C",02,0})
	Aadd(aCampos,{"TMP_RED"  ,"C",10,0})
	Aadd(aCampos,{"TMP_DESC" ,"C",40,0})

	// FINAL Monta os campos da tabela
    
	oTempMRede:SetFields(aCampos)
	oTempMRede:AddIndex("01", {"TMP_RED"} )
	
	//------------------
	//Criação da tabela
	//------------------
	oTempMRede:Create()

	DbSelectArea("D_FILTREDE")
	While ! D_FILTREDE->(Eof())

		Aadd(aRedes,{D_FILTREDE->ZF_REDE,Posicione("SZF",3,xFilial("SZF") + D_FILTREDE->ZF_REDE, "ZF_NOMERED")})

		D_FILTREDE->(DbSkip())

	EndDo

	DbCloseArea("D_FILTREDE")

	//
	For i := 1 To Len(aRedes)

		If lHistFilt1 //Verifica se já foi aplicado filtro.
			
			nPosRede := 0
			nPosRede := Ascan(aHistRede,{|x| Alltrim(cValToChar(x[1])) == Alltrim(cValToChar(aRedes[i][1])) })

			RecLock("TREDE",.T.)		
			TREDE->OK		:= ""
			TREDE->TMP_RED	:= Alltrim(cValToChar(aRedes[i][1]))
			TREDE->TMP_DESC	:= Alltrim(cValToChar(aRedes[i][2]))
			MsunLock()

		Else

			RecLock("TREDE",.T.)		
			TREDE->OK		:= ""
			TREDE->TMP_RED	:= Alltrim(cValToChar(aRedes[i][1]))
			TREDE->TMP_DESC	:= Alltrim(cValToChar(aRedes[i][2]))
			MsunLock()

		EndIf

	Next i

	If Len(aRedes) <= 0

		RecLock("TREDE",.T.)		
		TREDE->OK		:= ""
		TREDE->TMP_RED	:= ""
		TREDE->TMP_DESC	:=""
		MsunLock()	

	EndIf

	Aadd(aCpoBro,{"OK"	     ,, ""})		
	Aadd(aCpoBro,{"TMP_RED"  ,,"Rede"})	
	Aadd(aCpoBro,{"TMP_DESC" ,,"Nome"})

	oMkRede := MsSelect():New("TREDE","OK","",aCpoBro ,.F.,@cMark ,{037,010,170,170},,,oPnlFilt1,,)
	oMkRede:bMark := {| | DispRede(oMkRede,cMark)} 
	oMkRede:oBrowse:bAllMark := {|| RedeInvert(oMkRede,cMark) }
	Eval(oMkRede:oBrowse:bGoTop)
	oMkRede:oBrowse:Refresh()

	oPnlFilt1:Refresh()

	RestArea(aArea)

Return Nil


/*/{Protheus.doc} Static Function DispRede
	Marcação de filtro por rede.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version 01
/*/

Static Function DispRede(oMkRede,cMark)

	Local aArea		:= GetArea()

	DbSelectArea("TREDE")
	RecLock("TREDE",.F.)

	If Marked("OK")	
		TREDE->OK := cMark
	Else	
		TREDE->OK := ""
	Endif             

	MsUnlock()

	oMkRede:oBrowse:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function RedeInvert
	Inverter marcação de filtro por rede.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function RedeInvert(oMkRede,cMark) 

	Local aArea		:= GetArea()

	     DbSelectArea( "TREDE" ) 
	     TREDE->(DbGotop())

	     While ! TREDE->(EoF())

	If Marked("OK")	
		RecLock("TREDE",.F.)
		TREDE->OK := ""
		MsUnlock()

	Else
		RecLock("TREDE",.F.)
		TREDE->OK := cMark
		MsUnlock()

	Endif

	     	TREDE->(DbSkip())

	     EndDo 

	Eval(oMkRede:oBrowse:bGoTop)
	oMkRede:oBrowse:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function DispPortad
	Função de marcação   filtro por portador.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function DispPortad(oMkFxPort,cMark)

	Local aArea		:= GetArea()

	DbSelectArea("TPORTAD")

	If TPORTAD->(Eof())
		RestArea(aArea)
		Return Nil

	EndIf

	RecLock("TPORTAD",.F.)

	If Marked("OK")	
		TPORTAD->OK := cMark
	Else	
		TPORTAD->OK := ""
	Endif             

	MsUnlock()

	oMkFxPort:oBrowse:Refresh()

	RestArea(aArea)

Return Nil

STATIC FUNCTION sqlRede()

	Local cQuery := ''

	cQuery:= " SELECT ZF_REDE  "
	cQuery+= "  FROM " + RETSQLNAME("SZF") + " WITH (NOLOCK) "
	cQuery+= " WHERE D_E_L_E_T_ <> '*'  "
	cQuery+= " GROUP BY ZF_REDE  "
	cQuery+= " ORDER BY ZF_REDE  "


RETURN(cQuery)	

STATIC FUNCTION sqlCliente()

	Local cQuery := ''

	cQuery:= " SELECT A1_COD,A1_LOJA,A1_NOME  "
	cQuery+= "  FROM " + RETSQLNAME("SA1") + " WITH (NOLOCK) "
	cQuery+= " WHERE A1_FILIAL = ''  "
	cQuery+= " AND A1_CODRED   = ''  "
	cQuery+= " AND D_E_L_E_T_ <> '*'  "
	cQuery+= " ORDER BY A1_COD,A1_LOJA  "

RETURN(cQuery)	

STATIC FUNCTION sqlPortador()

	Local cQuery := ''

	cQuery:= " SELECT A6_COD  "
	cQuery+= "  FROM " + RETSQLNAME("SA6") + " WITH (NOLOCK) "
	cQuery+= " WHERE D_E_L_E_T_ <> '*'  "
	cQuery+= " GROUP BY A6_COD  "
	cQuery+= " ORDER BY A6_COD  "

RETURN(cQuery)

STATIC FUNCTION sqlCNPJ(nTipoRel,cFiltro)	
	
	Local cQuery:= ""
	
	cQuery += " SELECT A1_CGC "
	cQuery+= "  FROM " + RETSQLNAME("SA1") + " WITH (NOLOCK) "

	IF nTipoRel == 1 // REDE

		cQuery += " WHERE A1_CODRED IN (" + cFiltro + ") "

	ELSE	

		cQuery += " WHERE A1_COD IN (" + cFiltro + ") "

	ENDIF

	cQuery += "   AND D_E_L_E_T_ <> '*' "
	cQuery += "   ORDER BY A1_CGC "
	
Return cQuery

/*/{Protheus.doc} Static Function filtCliente
	Filtro por rede.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function filtCliente(oPnlFilt1,oMkCliente)

	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local aClientes	:= {}
	Local i			:= 1
	Local nLinha	:= 5
	Local nColuna	:= 5
	Local aCpoBro	:= {}
	Local cMark   	:= GetMark() 
	Local nPosCli
	Local cIndex

	//Valida o objeto.
	If Valtype(oMkCliente) == "O"
		FreeObj(oMkCliente:oBrowse)
		FreeObj(oMkCliente)

	EndIf

	//Valida o objeto.
	If Valtype(oMkCliente) == "O"
		FreeObj(oMkCliente:oBrowse)
		FreeObj(oMkCliente)

	EndIf

	//Obtém o script sql.
	cQuery := sqlCliente()

	//
	If Empty(cQuery)
		RestArea(aArea)
		Return Nil

	EndIf

	If Select("D_FILTCLI") > 0
		D_FILTCLI->(DbCloseArea())

	EndIf

	TcQuery cQuery New Alias "D_FILTCLI"
	DbSelectArea("D_FILTCLI")
	D_FILTCLI->(DbGoTop())

	If Select("TCLI") > 0

		TCLI->(DbCloseArea())

	EndIf

	oTempMCli := FWTemporaryTable():New("TCLI")

	// INICIO Monta os campos da tabela
	aCampos := {}
	Aadd(aCampos,{"OK" 	     ,"C",02,0})
	Aadd(aCampos,{"TMP_COD"  ,"C",06,0})
	Aadd(aCampos,{"TMP_LOJA" ,"C",02,0})
	Aadd(aCampos,{"TMP_NOME" ,"C",40,0})

	// FINAL Monta os campos da tabela
    
	oTempMCli:SetFields(aCampos)
	oTempMCli:AddIndex("01", {"TMP_COD"} )
	
	//------------------
	//Criação da tabela
	//------------------
	oTempMCli:Create()

	DbSelectArea("D_FILTCLI")
	While ! D_FILTCLI->(Eof())

		Aadd(aClientes,{D_FILTCLI->A1_COD,D_FILTCLI->A1_LOJA,D_FILTCLI->A1_NOME})

		D_FILTCLI->(DbSkip())

	EndDo

	DbCloseArea("D_FILTCLI")

	//
	For i := 1 To Len(aClientes)

		If lHistFilt1 //Verifica se já foi aplicado filtro.
			
			nPosCli := 0
			nPosCli := Ascan(aHisTCli,{|x| Alltrim(cValToChar(x[1])) == Alltrim(cValToChar(aClientes[i][1])) })

			RecLock("TCLI",.T.)		
			TCLI->OK		:= ''
			TCLI->TMP_COD	:= Alltrim(cValToChar(aClientes[i][1]))
			TCLI->TMP_LOJA	:= Alltrim(cValToChar(aClientes[i][2]))
			TCLI->TMP_NOME	:= Alltrim(cValToChar(aClientes[i][3]))
			MsunLock()

		Else
			RecLock("TCLI",.T.)		
			TCLI->OK		:= ''
			TCLI->TMP_COD	:= Alltrim(cValToChar(aClientes[i][1]))
			TCLI->TMP_LOJA	:= Alltrim(cValToChar(aClientes[i][2]))
			TCLI->TMP_NOME	:= Alltrim(cValToChar(aClientes[i][3]))
			MsunLock()

		EndIf

	Next i

	If Len(aClientes) <= 0

		RecLock("TCLI",.T.)		
		TCLI->OK		:= ""
		TCLI->TMP_COD	:= ""
		TCLI->TMP_LOJA	:= ""
		TCLI->TMP_NOME	:= ""
		MsunLock()	

	EndIf

	Aadd(aCpoBro,{"OK"	     ,, ""})		
	Aadd(aCpoBro,{"TMP_COD"  ,,"Codigo"})	
	Aadd(aCpoBro,{"TMP_LOJA" ,,"Loja"})	
	Aadd(aCpoBro,{"TMP_NOME" ,,"Nome"})

	oMkCliente := MsSelect():New("TCLI","OK","",aCpoBro ,.F.,@cMark ,{037,190,170,350},,,oPnlFilt1,,)
	                                                                 
	oMkCliente:bMark := {| | DispCli(oMkCliente,cMark)} 
	oMkCliente:oBrowse:bAllMark := {|| CliInvert(oMkCliente,cMark) }
	Eval(oMkCliente:oBrowse:bGoTop)
	oMkCliente:oBrowse:Refresh()

	oPnlFilt1:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function DispCli
	Marcação de filtro por rede.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version 01
/*/

Static Function DispCli(oMkCliente,cMark)

	Local aArea		:= GetArea()

	DbSelectArea("TCLI")
	RecLock("TCLI",.F.)

	If Marked("OK")	
		TCLI->OK := cMark
	Else	
		TCLI->OK := ""
	Endif             

	MsUnlock()

	oMkCliente:oBrowse:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function CliInvert
	Inverter marcação de filtro por rede.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function CliInvert(oMkCliente,cMark) 

	Local aArea		:= GetArea()

	     DbSelectArea( "TCLI" ) 
	     TCLI->(DbGotop())

	While ! TCLI->(EoF())

		If Marked("OK")	
			RecLock("TCLI",.F.)
			TCLI->OK := ""
			MsUnlock()

		Else
			RecLock("TCLI",.F.)
			TCLI->OK := cMark
			MsUnlock()

		Endif

		TCLI->(DbSkip())

	EndDo 

	Eval(oMkCliente:oBrowse:bGoTop)
	oMkCliente:oBrowse:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function bscCliente
	Busca rede na MsSelect.
	@type  Function
	@author Everson
	@since 27/06/2017
	@version version
/*/

Static Function bscCliente(oMkCliente,cCodigo)

	Local nAux	:= 1
	Local nPos	:= 1

	cCodigo := Alltrim(cValToChar(cCodigo))
	
	If Empty(cCodigo)
		RestArea(aArea)
		Return Nil

	EndIf
	
	If Select("TCLI") <= 0
		RestArea(aArea)
		Return Nil

	EndIf

	DbSelectArea("TCLI")
	TCLI->(DbGoTop())
	
	While ! TCLI->(Eof())

		If cCodigo $(Alltrim(cValToChar(TCLI->TMP_COD))) .OR. ;
		   cCodigo $(Alltrim(cValToChar(TCLI->TMP_NOME)))

			nPos := nAux
			Exit

		EndIf

		TCLI->(DbSkip())

		nAux := nAux + 1

	EndDo
	
	If nPos <= 0

		MsgStop("Registro não encontrado","Função bscCliente")
		Return Nil

	EndIf
	
	oMkCliente:oBrowse:nPos
	oMkCliente:oBrowse:REFRESH()
	
Return Nil

/*/{Protheus.doc} Static Function PortadInvert
	Função para inverter filtro por portador.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function PortadInvert(oMkFxPort,cMark) 

	Local aArea		:= GetArea()

	     DbSelectArea( "TPORTAD" ) 
	     TPORTAD->(DbGotop())

	If TPORTAD->(Eof())
		RestArea(aArea)
		Return Nil

	EndIf

	While ! TPORTAD->(EoF())

		If Marked("OK")	
			RecLock("TPORTAD",.F.)
			TPORTAD->OK := ""
			MsUnlock()

		Else
			RecLock("TPORTAD",.F.)
			TPORTAD->OK := cMark
			MsUnlock()

		Endif

	    TPORTAD->(DbSkip())

	EndDo 

	Eval(oMkFxPort:oBrowse:bGoTop)
	oMkFxPort:oBrowse:Refresh()

	RestArea(aArea)

Return Nil

STATIC FUNCTION DBCLICKFAT(cCnpjs) 

	LOCAL oTelaTitFat  := NIL
	Local oBrowTitFat  := NIL
	Local cDataIniFat  := ''
	Local cDataFinFat  := ''

	// *** INICIO VALIDACAO

	IF SUBSTR(TEMPFAT->TM_DATA,1,1) $ "M/A/T"  // COMPARACAO COM MÊS/ANO/TOTAL

		MSGALERT("Não é possivel ver detalhes de Titulos de Linhas de Mês Ano e Total eles são somente demonstrativos","DBCLICKFAT")

		RETURN(NIL)

	ENDIF

	// *** FINAL VALIDACAO

	//Cria Arquivos Temporários
	oTempFat1 := FWTemporaryTable():New("TITFAT")

	// INICIO Monta os campos da tabela
	aCampos := {}
	AADD(aCampos,{"TM_FILIAL" ,FWTamSX3("E1_FILIAL")[3]  ,FWTamSX3("E1_FILIAL")[1]  ,FWTamSX3("E1_FILIAL")[2]  })	
	AADD(aCampos,{"TM_PREFIXO",FWTamSX3("E1_PREFIXO")[3] ,FWTamSX3("E1_PREFIXO")[1] ,FWTamSX3("E1_PREFIXO")[2] })
	AADD(aCampos,{"TM_NUM"    ,FWTamSX3("E1_NUM")[3]     ,FWTamSX3("E1_NUM")[1]     ,FWTamSX3("E1_NUM")[2]     })
	AADD(aCampos,{"TM_PARCELA",FWTamSX3("E1_PARCELA")[3] ,FWTamSX3("E1_PARCELA")[1] ,FWTamSX3("E1_PARCELA")[2] })
	AADD(aCampos,{"TM_TIPO"   ,FWTamSX3("E1_TIPO")[3]    ,FWTamSX3("E1_TIPO")[1]    ,FWTamSX3("E1_TIPO")[2]    })
	AADD(aCampos,{"TM_PORTADO",FWTamSX3("E1_PORTADO")[3] ,FWTamSX3("E1_PORTADO")[1] ,FWTamSX3("E1_PORTADO")[2] })
	AADD(aCampos,{"TM_CLIENTE",FWTamSX3("E1_CLIENTE")[3] ,FWTamSX3("E1_CLIENTE")[1] ,FWTamSX3("E1_CLIENTE")[2] })
	AADD(aCampos,{"TM_LOJA"   ,FWTamSX3("E1_LOJA")[3]    ,FWTamSX3("E1_LOJA")[1]    ,FWTamSX3("E1_LOJA")[2]    })
	AADD(aCampos,{"TM_NOMCLI" ,FWTamSX3("E1_NOMCLI")[3]  ,FWTamSX3("E1_NOMCLI")[1]  ,FWTamSX3("E1_NOMCLI")[2]  })
	AADD(aCampos,{"TM_EMISSAO","C"                       ,10                        ,0                         })
	AADD(aCampos,{"TM_VENCREA","C"                       ,10                        ,0                         })
	AADD(aCampos,{"TM_BAIXA"  ,"C"                       ,10                        ,0                         })
	AADD(aCampos,{"TM_DIFPAG" ,"N"                       ,17                        ,0                         })
	AADD(aCampos,{"TM_VALOR"  ,FWTamSX3("E1_VALOR")[3]   ,FWTamSX3("E1_VALOR")[1]   ,FWTamSX3("E1_VALOR")[2]   })
	AADD(aCampos,{"TM_SALDO"  ,FWTamSX3("E1_SALDO")[3]   ,FWTamSX3("E1_SALDO")[1]   ,FWTamSX3("E1_SALDO")[2]   })
	AADD(aCampos,{"TM_VEND1"  ,FWTamSX3("E1_VEND1")[3]   ,FWTamSX3("E1_VEND1")[1]   ,FWTamSX3("E1_VEND1")[2]   })
	AADD(aCampos,{"TM_CGC"    ,FWTamSX3("A1_CGC")[3]     ,FWTamSX3("A1_CGC")[1]     ,FWTamSX3("A1_CGC")[2]     })
	AADD(aCampos,{"TM_SATIV1" ,FWTamSX3("A1_SATIV1")[3]  ,FWTamSX3("A1_SATIV1")[1]  ,FWTamSX3("A1_SATIV1")[2]  })
	AADD(aCampos,{"TM_REDE"   ,FWTamSX3("A1_REDE")[3]    ,FWTamSX3("A1_REDE")[1]    ,FWTamSX3("A1_REDE")[2]    })
	AADD(aCampos,{"TM_NOMREDE",FWTamSX3("ZF_NOMEREDE")[3],FWTamSX3("ZF_NOMEREDE")[1],FWTamSX3("ZF_NOMEREDE")[2]})

	// FINAL Monta os campos da tabela
    
	oTempFat1:SetFields(aCampos)
	//oTempFat1:AddIndex("01", {"TM_FILIAL+TM_PREFIXO+TM_NUM+TM_PARCELA+TM_TIPO"} )
	
	//------------------
	//Criação da tabela
	//------------------
	oTempFat1:Create()

	IF nplanfat == 1 //Ano

		cDataIniFat  := DTOS(FIRSTYDATE(CTOD("01/01/" + SUBSTR(TEMPFAT->TM_DATA,1,4))))
		cDataFinFat  := DTOS(LASTYDATE(CTOD("01/01/" + SUBSTR(TEMPFAT->TM_DATA,1,4))))

	ELSEIF nplanfat == 2 //MES

		cDataIniFat  := DTOS(FIRSTDATE(CTOD("01/" + SUBSTR(TEMPFAT->TM_DATA,6,2) + "/" + SUBSTR(TEMPFAT->TM_DATA,1,4))))
		cDataFinFat  := DTOS(LASTDATE(CTOD( "01/" + SUBSTR(TEMPFAT->TM_DATA,6,2) + "/" + SUBSTR(TEMPFAT->TM_DATA,1,4))))

	ELSE // DIA

		cDataIniFat  := DTOS(CTOD(TEMPFAT->TM_DATA))
		cDataFinFat  := DTOS(CTOD(TEMPFAT->TM_DATA))

	ENDIF
	
	//Obtém o script sql para os CNPJS.
	cQuery := sqlTitFat(cDataIniFat,cDataFinFat,cCnpjs)
	
	IF EMPTY(cQuery)

		RESTAREA(aArea)
		RETURN .F.

	ENDIF

	IF SELECT("D_TITULOS") > 0

		D_TITULOS->(DBCLOSEAREA())

	ENDIF

	TCQUERY cQuery NEW ALIAS "D_TITULOS"

	DBSELECTAREA("D_TITULOS")
	D_TITULOS->(DBGOTOP())
	WHILE !D_TITULOS->(EOF())

		RECLOCK("TITFAT",.T.)

			TITFAT->TM_FILIAL  := D_TITULOS->E1_FILIAL
			TITFAT->TM_PREFIXO := D_TITULOS->E1_PREFIXO
			TITFAT->TM_NUM     := D_TITULOS->E1_NUM 
			TITFAT->TM_PARCELA := D_TITULOS->E1_PARCELA
			TITFAT->TM_TIPO    := D_TITULOS->E1_TIPO
			TITFAT->TM_PORTADO := D_TITULOS->E1_PORTADO
			TITFAT->TM_CLIENTE := D_TITULOS->E1_CLIENTE
			TITFAT->TM_LOJA    := D_TITULOS->E1_LOJA
			TITFAT->TM_NOMCLI  := D_TITULOS->E1_NOMCLI
			TITFAT->TM_EMISSAO := DTOC(STOD(D_TITULOS->E1_EMISSAO))
			TITFAT->TM_VENCREA := DTOC(STOD(D_TITULOS->E1_VENCREA))
			TITFAT->TM_BAIXA   := DTOC(STOD(D_TITULOS->E1_BAIXA))
			TITFAT->TM_DIFPAG  := IIF(ALLTRIM(D_TITULOS->E1_BAIXA) <> '',STOD(D_TITULOS->E1_BAIXA) - STOD(D_TITULOS->E1_VENCREA),0)
			TITFAT->TM_VALOR   := D_TITULOS->E1_VALOR
			TITFAT->TM_SALDO   := D_TITULOS->E1_SALDO
			TITFAT->TM_VEND1   := D_TITULOS->E1_VEND1
			TITFAT->TM_CGC     := D_TITULOS->A1_CGC
			TITFAT->TM_SATIV1  := D_TITULOS->A1_SATIV1
			TITFAT->TM_REDE    := D_TITULOS->A1_CODRED
			TITFAT->TM_NOMREDE := Posicione("SZF",3,xFilial("SZF")+D_TITULOS->A1_CODRED,"ZF_NOMERED")
	
		MSUNLOCK()
		
		D_TITULOS->(DBSKIP())

	ENDDO

	D_TITULOS->(DBGOTOP())
	TITFAT->(DBGOTOP())

	oTelaTitFat			  := MsDialog():Create()
	oTelaTitFat:cName     := "oTelaTit"
	oTelaTitFat:cCaption  := "Detalhe dos Titulos: " + DTOC(DATE()) + " às " + TIME()
	oTelaTitFat:nLeft     := 0 
	oTelaTitFat:nTop      := 0 
	oTelaTitFat:nWidth    := 1340
	oTelaTitFat:nHeight   := 630
	oTelaTitFat:lShowHint := .F.
	oTelaTitFat:lCentered := .T.

	oBrowTitFat:= TCBrowse():New(01,01,665,300,,,,oTelaTitFat,,,,,,,,,,,,,"TITFAT",.T.,,,,.T.,)
    
	oBrowTitFat:AddColumn(TCColumn():New("Filial"      ,{|| TITFAT->TM_FILIAL}                                  ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Prefixo"     ,{|| TITFAT->TM_PREFIXO}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Num"         ,{|| TITFAT->TM_NUM}                                     ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Parcela"     ,{|| TITFAT->TM_PARCELA}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Tipo"        ,{|| TITFAT->TM_TIPO}                                    ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Portador"    ,{|| TITFAT->TM_PORTADO}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Cliente"     ,{|| TITFAT->TM_CLIENTE}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Loja"        ,{|| TITFAT->TM_LOJA}                                    ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Nome Cliente",{|| TITFAT->TM_NOMCLI}                                  ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Emissão"     ,{|| TITFAT->TM_EMISSAO}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Vencimento"  ,{|| TITFAT->TM_VENCREA}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Baixa"       ,{|| TITFAT->TM_BAIXA}                                   ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Dif Pag"     ,{|| TITFAT->TM_DIFPAG}                                  ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Valor"       ,{|| TRANSFORM(TITFAT->TM_VALOR,"@E 999,999,999,999.99")},,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Saldo"       ,{|| TRANSFORM(TITFAT->TM_SALDO,"@E 999,999,999,999.99")},,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Vendedor"    ,{|| TITFAT->TM_VEND1}                                   ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("CGC"         ,{|| TITFAT->TM_CGC}                                     ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("SATIV1"      ,{|| TITFAT->TM_SATIV1}                                  ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Rede"        ,{|| TITFAT->TM_REDE}                                    ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFat:AddColumn(TCColumn():New("Nome Rede"   ,{|| TITFAT->TM_NOMREDE}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
    
	oTelaTitFat:Activate(,,,.T.,{||.T.},,{||.T.})

	D_TITULOS->(DBCLOSEAREA())
	TITFAT->(DBCLOSEAREA())

RETURN(NIL)

STATIC FUNCTION sqlTitFat(cDataIniFat,cDataFinFat,cCnpjs)
	
	Local cQuery:= ""
	
	cQuery += " SELECT E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_VALOR,E1_SALDO,E1_EMISSAO,E1_VENCREA,E1_PORTADO,E1_CLIENTE,E1_LOJA,E1_NOMCLI,E1_BAIXA,E1_VEND1,A1_CGC,A1_SATIV1,A1_CODRED "
	cQuery+= "  FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
	cQuery+= " INNER JOIN " + RETSQLNAME("SA1") + " SA1 WITH (NOLOCK) "
	cQuery += "         ON A1_COD          = E1_CLIENTE "
	cQuery += "        AND A1_LOJA         = E1_LOJA "
	cQuery += "        AND A1_CGC         IN (" + cCnpjs + ") "
	cQuery += "        AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE E1_EMISSAO          >= '" + cDataIniFat + "' " 
	cQuery += "   AND E1_EMISSAO          <= '" + cDataFinFat + "' "
	cQuery += "   AND E1_TIPO              = 'NF' " 
	cQuery += "   AND SE1.D_E_L_E_T_      <> '*' "
	cQuery += "   ORDER BY E1_NUM "
	
Return cQuery

STATIC FUNCTION DBCLICKFIN(cCnpjs) 

	LOCAL oTelaTitFin  := NIL
	Local oBrowTitFin  := NIL
	Local cDataIniFin  := ''
	Local cDataFinFin  := ''

	// *** INICIO VALIDACAO

	IF SUBSTR(TEMPFIN->TM_DATA,1,1) $ "M/A/T" // COMPARACAO COM MÊS/ANO/TOTAL

		MSGALERT("Não é possivel ver detalhes de Titulos de Linhas de Mês Ano e Total eles são somente demonstrativos","DBCLICKFAT")

		RETURN(NIL)

	ENDIF

	// *** FINAL VALIDACAO

	//Cria Arquivos Temporários
	oTempFin1 := FWTemporaryTable():New("TITFIN")

	// INICIO Monta os campos da tabela
	aCampos := {}
	AADD(aCampos,{"TM_FILIAL" ,FWTamSX3("E1_FILIAL")[3]  ,FWTamSX3("E1_FILIAL")[1]  ,FWTamSX3("E1_FILIAL")[2]  })	
	AADD(aCampos,{"TM_PREFIXO",FWTamSX3("E1_PREFIXO")[3] ,FWTamSX3("E1_PREFIXO")[1] ,FWTamSX3("E1_PREFIXO")[2] })
	AADD(aCampos,{"TM_NUM"    ,FWTamSX3("E1_NUM")[3]     ,FWTamSX3("E1_NUM")[1]     ,FWTamSX3("E1_NUM")[2]     })
	AADD(aCampos,{"TM_PARCELA",FWTamSX3("E1_PARCELA")[3] ,FWTamSX3("E1_PARCELA")[1] ,FWTamSX3("E1_PARCELA")[2] })
	AADD(aCampos,{"TM_TIPO"   ,FWTamSX3("E1_TIPO")[3]    ,FWTamSX3("E1_TIPO")[1]    ,FWTamSX3("E1_TIPO")[2]    })
	AADD(aCampos,{"TM_PORTADO",FWTamSX3("E1_PORTADO")[3] ,FWTamSX3("E1_PORTADO")[1] ,FWTamSX3("E1_PORTADO")[2] })
	AADD(aCampos,{"TM_CLIENTE",FWTamSX3("E1_CLIENTE")[3] ,FWTamSX3("E1_CLIENTE")[1] ,FWTamSX3("E1_CLIENTE")[2] })
	AADD(aCampos,{"TM_LOJA"   ,FWTamSX3("E1_LOJA")[3]    ,FWTamSX3("E1_LOJA")[1]    ,FWTamSX3("E1_LOJA")[2]    })
	AADD(aCampos,{"TM_NOMCLI" ,FWTamSX3("E1_NOMCLI")[3]  ,FWTamSX3("E1_NOMCLI")[1]  ,FWTamSX3("E1_NOMCLI")[2]  })
	AADD(aCampos,{"TM_EMISSAO","C"                       ,10                        ,0                         })
	AADD(aCampos,{"TM_VENCREA","C"                       ,10                        ,0                         })
	AADD(aCampos,{"TM_BAIXA"  ,"C"                       ,10                        ,0                         })
	AADD(aCampos,{"TM_DIFPAG" ,"N"                       ,17                        ,0                         })
	AADD(aCampos,{"TM_VALOR"  ,FWTamSX3("E1_VALOR")[3]   ,FWTamSX3("E1_VALOR")[1]   ,FWTamSX3("E1_VALOR")[2]   })
	AADD(aCampos,{"TM_SALDO"  ,FWTamSX3("E1_SALDO")[3]   ,FWTamSX3("E1_SALDO")[1]   ,FWTamSX3("E1_SALDO")[2]   })
	AADD(aCampos,{"TM_VEND1"  ,FWTamSX3("E1_VEND1")[3]   ,FWTamSX3("E1_VEND1")[1]   ,FWTamSX3("E1_VEND1")[2]   })
	AADD(aCampos,{"TM_CGC"    ,FWTamSX3("A1_CGC")[3]     ,FWTamSX3("A1_CGC")[1]     ,FWTamSX3("A1_CGC")[2]     })
	AADD(aCampos,{"TM_SATIV1" ,FWTamSX3("A1_SATIV1")[3]  ,FWTamSX3("A1_SATIV1")[1]  ,FWTamSX3("A1_SATIV1")[2]  })
	AADD(aCampos,{"TM_REDE"   ,FWTamSX3("A1_REDE")[3]    ,FWTamSX3("A1_REDE")[1]    ,FWTamSX3("A1_REDE")[2]    })
	AADD(aCampos,{"TM_NOMREDE",FWTamSX3("ZF_NOMEREDE")[3],FWTamSX3("ZF_NOMEREDE")[1],FWTamSX3("ZF_NOMEREDE")[2]})

	// FINAL Monta os campos da tabela
    
	oTempFin1:SetFields(aCampos)
	//oTempFin1:AddIndex("01", {"TM_FILIAL+TM_PREFIXO+TM_NUM+TM_PARCELA+TM_TIPO"} )
	
	//------------------
	//Criação da tabela
	//------------------
	oTempFin1:Create()

	IF nplanfin == 1 //Ano

		cDataIniFin  := DTOS(FIRSTYDATE(CTOD("01/01/" + SUBSTR(TEMPFIN->TM_DATA,1,4))))
		cDataFinFin  := DTOS(LASTYDATE(CTOD("01/01/" + SUBSTR(TEMPFIN->TM_DATA,1,4))))

	ELSEIF nplanfin == 2 //MES

		cDataIniFin  := DTOS(FIRSTDATE(CTOD("01/" + SUBSTR(TEMPFIN->TM_DATA,6,2) + "/" + SUBSTR(TEMPFIN->TM_DATA,1,4))))
		cDataFinFin  := DTOS(LASTDATE(CTOD( "01/" + SUBSTR(TEMPFIN->TM_DATA,6,2) + "/" + SUBSTR(TEMPFIN->TM_DATA,1,4))))

	ELSE // DIA

		cDataIniFin  := DTOS(CTOD(TEMPFIN->TM_DATA))
		cDataFinFin  := DTOS(CTOD(TEMPFIN->TM_DATA))

	ENDIF
	
	//Obtém o script sql para os CNPJS.
	cQuery := sqlTitFin(cDataIniFin,cDataFinFin,cCnpjs)
	
	IF EMPTY(cQuery)

		RESTAREA(aArea)
		RETURN .F.

	ENDIF

	IF SELECT("D_TITULOS") > 0

		D_TITULOS->(DBCLOSEAREA())

	ENDIF

	TCQUERY cQuery NEW ALIAS "D_TITULOS"

	DBSELECTAREA("D_TITULOS")
	D_TITULOS->(DBGOTOP())
	WHILE !D_TITULOS->(EOF())

		RECLOCK("TITFIN",.T.)

			TITFIN->TM_FILIAL  := D_TITULOS->E1_FILIAL
			TITFIN->TM_PREFIXO := D_TITULOS->E1_PREFIXO
			TITFIN->TM_NUM     := D_TITULOS->E1_NUM 
			TITFIN->TM_PARCELA := D_TITULOS->E1_PARCELA
			TITFIN->TM_TIPO    := D_TITULOS->E1_TIPO
			TITFIN->TM_PORTADO := D_TITULOS->E1_PORTADO
			TITFIN->TM_CLIENTE := D_TITULOS->E1_CLIENTE
			TITFIN->TM_LOJA    := D_TITULOS->E1_LOJA
			TITFIN->TM_NOMCLI  := D_TITULOS->E1_NOMCLI
			TITFIN->TM_EMISSAO := DTOC(STOD(D_TITULOS->E1_EMISSAO))
			TITFIN->TM_VENCREA := DTOC(STOD(D_TITULOS->E1_VENCREA))
			TITFIN->TM_BAIXA   := DTOC(STOD(D_TITULOS->E1_BAIXA))
			TITFIN->TM_DIFPAG  := IIF(ALLTRIM(D_TITULOS->E1_BAIXA) <> '',STOD(D_TITULOS->E1_BAIXA) - STOD(D_TITULOS->E1_VENCREA),0)
			TITFIN->TM_VALOR   := D_TITULOS->E1_VALOR
			TITFIN->TM_SALDO   := D_TITULOS->E1_SALDO
			TITFIN->TM_VEND1   := D_TITULOS->E1_VEND1
			TITFIN->TM_CGC     := D_TITULOS->A1_CGC
			TITFIN->TM_SATIV1  := D_TITULOS->A1_SATIV1
			TITFIN->TM_REDE    := D_TITULOS->A1_CODRED
			TITFIN->TM_NOMREDE := Posicione("SZF",3,xFilial("SZF")+D_TITULOS->A1_CODRED,"ZF_NOMERED")
	
		MSUNLOCK()
		
		D_TITULOS->(DBSKIP())

	ENDDO

	D_TITULOS->(DBGOTOP())
	TITFIN->(DBGOTOP())

	oTelaTitFin			  := MsDialog():Create()
	oTelaTitFin:cName     := "oTelaTit"
	oTelaTitFin:cCaption  := "Detalhe dos Titulos: " + DTOC(DATE()) + " às " + TIME()
	oTelaTitFin:nLeft     := 0 
	oTelaTitFin:nTop      := 0 
	oTelaTitFin:nWidth    := 1340
	oTelaTitFin:nHeight   := 630
	oTelaTitFin:lShowHint := .F.
	oTelaTitFin:lCentered := .T.

	oBrowTitFin:= TCBrowse():New(01,01,665,300,,,,oTelaTitFin,,,,,,,,,,,,,"TITFIN",.T.,,,,.T.,)
    
	oBrowTitFin:AddColumn(TCColumn():New("Filial"      ,{|| TITFIN->TM_FILIAL}                                  ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Prefixo"     ,{|| TITFIN->TM_PREFIXO}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Num"         ,{|| TITFIN->TM_NUM}                                     ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Parcela"     ,{|| TITFIN->TM_PARCELA}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Tipo"        ,{|| TITFIN->TM_TIPO}                                    ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Portador"    ,{|| TITFIN->TM_PORTADO}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Cliente"     ,{|| TITFIN->TM_CLIENTE}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Loja"        ,{|| TITFIN->TM_LOJA}                                    ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Nome Cliente",{|| TITFIN->TM_NOMCLI}                                  ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Emissão"     ,{|| TITFIN->TM_EMISSAO}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Vencimento"  ,{|| TITFIN->TM_VENCREA}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Baixa"       ,{|| TITFIN->TM_BAIXA}                                   ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Dif Pag"     ,{|| TITFIN->TM_DIFPAG}                                  ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Valor"       ,{|| TRANSFORM(TITFIN->TM_VALOR,"@E 999,999,999,999.99")},,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Saldo"       ,{|| TRANSFORM(TITFIN->TM_SALDO,"@E 999,999,999,999.99")},,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Vendedor"    ,{|| TITFIN->TM_VEND1}                                   ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("CGC"         ,{|| TITFIN->TM_CGC}                                     ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("SATIV1"      ,{|| TITFIN->TM_SATIV1}                                  ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Rede"        ,{|| TITFIN->TM_REDE}                                    ,,,,"LEFT",,.F.,.F.,,,,.F.,))
	oBrowTitFin:AddColumn(TCColumn():New("Nome Rede"   ,{|| TITFIN->TM_NOMREDE}                                 ,,,,"LEFT",,.F.,.F.,,,,.F.,))
    
	oTelaTitFin:Activate(,,,.T.,{||.T.},,{||.T.})

	D_TITULOS->(DBCLOSEAREA())
	TITFIN->(DBCLOSEAREA())

RETURN(NIL)

STATIC FUNCTION sqlTitFin(cDataIniFin,cDataFinFin,cCnpjs)
	
	Local cQuery:= ""
	
	cQuery += " SELECT E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_VALOR,E1_SALDO,E1_EMISSAO,E1_VENCREA,E1_PORTADO,E1_CLIENTE,E1_LOJA,E1_NOMCLI,E1_BAIXA,E1_VEND1,A1_CGC,A1_SATIV1,A1_CODRED "
	cQuery += "  FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
	cQuery += " INNER JOIN " + RETSQLNAME("SA1") + " SA1 WITH (NOLOCK) "
	cQuery += "         ON A1_COD          = E1_CLIENTE "
	cQuery += "        AND A1_LOJA         = E1_LOJA "
	cQuery += "        AND A1_CGC         IN (" + cCnpjs + ") "
	cQuery += "        AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE E1_VENCREA          >= '" + cDataIniFin + "' " 
	cQuery += "   AND E1_VENCREA          <= '" + cDataFinFin + "' " 
	cQuery += "   AND E1_SALDO             > 0 "
	cQuery += "   AND E1_TIPO              = 'NF' "
	cQuery += "   AND SE1.D_E_L_E_T_      <> '*' "
	cQuery += "   ORDER BY E1_NUM "
	
Return cQuery

Static Function SqlAnoFat(cCnpjs,cAnoAux)

	Local cQuery:= ""

	cQuery := "SELECT "
	cQuery += " SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_VALOR ELSE 0 END) AS 'NF', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_VALOR * (-1) ELSE 0 END),2) AS 'NCC', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_VALOR ELSE 0 END),2) - ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_VALOR ELSE 0 END),2) AS 'TOTAL' "
	cQuery += "  FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
    cQuery += " INNER JOIN " + RETSQLNAME("SA1") + " SA1 WITH (NOLOCK) "
	cQuery += "         ON A1_COD          = E1_CLIENTE "
	cQuery += "        AND A1_LOJA         = E1_LOJA "
	cQuery += "        AND A1_CGC         IN (" + cCnpjs + ") "
	cQuery += "        AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += "      WHERE E1_EMISSAO     >= '" + cAnoAux + '0101' + "' "
	cQuery += " 	   AND E1_EMISSAO     <= '" + cAnoAux + '1231' + "' "
	cQuery += "        AND E1_PORTADO     IN (" + cFiltPortad + ") "
	cQuery += "    	   AND E1_TIPO        IN ('NF','NCC') "
	cQuery += "        AND SE1.D_E_L_E_T_ <> '*' "
		
Return cQuery

Static Function SqlAnoFin(cCnpjs,cAnoAux)

	Local cQuery:= ""

	cQuery := "SELECT "
	cQuery += " SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_SALDO ELSE 0 END) AS 'NF', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_SALDO * (-1) ELSE 0 END),2) AS 'NCC', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_SALDO ELSE 0 END),2) - ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_SALDO ELSE 0 END),2) AS 'TOTAL' "
	cQuery += "  FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
	cQuery += " INNER JOIN " + RETSQLNAME("SA1") + " SA1 WITH (NOLOCK) "
	cQuery += "         ON A1_COD          = E1_CLIENTE "
	cQuery += "        AND A1_LOJA         = E1_LOJA "
	cQuery += "        AND A1_CGC         IN (" + cCnpjs + ") "
	cQuery += "        AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += "      WHERE E1_VENCREA     >= '" + cAnoAux + '0101' + "' "
	cQuery += " 	   AND E1_VENCREA     <= '" + cAnoAux + '1231' + "' "
	cQuery += "        AND E1_PORTADO     IN (" + cFiltPortad + ") "
	cQuery += "    	   AND E1_TIPO        IN ('NF','NCC') "
	cQuery += "        AND SE1.D_E_L_E_T_ <> '*' "

Return cQuery

STATIC FUNCTION SqlMesFat(cCnpjs,cAnoAux,cMesAux)
	
	Local cQuery:= ""

	cQuery := "SELECT "
	cQuery += " SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_VALOR ELSE 0 END) AS 'NF', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_VALOR * (-1) ELSE 0 END),2) AS 'NCC', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_VALOR ELSE 0 END),2) - ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_VALOR ELSE 0 END),2) AS 'TOTAL' "
	cQuery += "  FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
    cQuery += " INNER JOIN " + RETSQLNAME("SA1") + " SA1 WITH (NOLOCK) "
	cQuery += "         ON A1_COD          = E1_CLIENTE "
	cQuery += "        AND A1_LOJA         = E1_LOJA "
	cQuery += "        AND A1_CGC         IN (" + cCnpjs + ") "
	cQuery += "        AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += "      WHERE E1_EMISSAO     >= '" + cAnoAux + cMesAux + '01' + "' "
	cQuery += " 	   AND E1_EMISSAO     <= '" + cAnoAux + cMesAux + '31' + "' "
	cQuery += "        AND E1_PORTADO     IN (" + cFiltPortad + ") "
	cQuery += "    	   AND E1_TIPO        IN ('NF','NCC') "
	cQuery += "        AND SE1.D_E_L_E_T_ <> '*' "
	
Return cQuery

STATIC FUNCTION SqlMesFin(cCnpjs,cAnoAux,cMesAux)
	
	Local cQuery:= ""

	cQuery := "SELECT "
	cQuery += " SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_SALDO ELSE 0 END) AS 'NF', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_SALDO * (-1) ELSE 0 END),2) AS 'NCC', "
	cQuery += " ROUND(SUM(CASE WHEN E1_TIPO = 'NF' THEN E1_SALDO ELSE 0 END),2) - ROUND(SUM(CASE WHEN E1_TIPO = 'NCC' THEN E1_SALDO ELSE 0 END),2) AS 'TOTAL' "
	cQuery += "  FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
	cQuery += " INNER JOIN " + RETSQLNAME("SA1") + " SA1 WITH (NOLOCK) "
	cQuery += "         ON A1_COD          = E1_CLIENTE "
	cQuery += "        AND A1_LOJA         = E1_LOJA "
	cQuery += "        AND A1_CGC         IN (" + cCnpjs + ") "
	cQuery += "        AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += "      WHERE E1_VENCREA     >= '" + cAnoAux + cMesAux + '01' + "' "
	cQuery += " 	   AND E1_VENCREA     <= '" + cAnoAux + cMesAux + '31' + "' "
	cQuery += "        AND E1_PORTADO     IN (" + cFiltPortad + ") "
	cQuery += "    	   AND E1_TIPO        IN ('NF','NCC') "
	cQuery += "        AND SE1.D_E_L_E_T_ <> '*' "
	
Return cQuery

STATIC FUNCTION PrazoMedia(cData,cRel,cfuncao,cTipoMedia,cCnpjs)

	Local nValor      := 0
	Local cDataIniAux := ''
	Local cDataFinAux := ''
	Local nCont       := 0
	Local nSomaValor  := 0
	Local nSomaMedia  := 0 
	Local nPMPonLinha := 0
	   
	IF cfuncao == 'NORMAL'

		IF nplanfat == 1 .OR. nplanfin == 1 // Ano

			cDataIniAux := ALLTRIM(cData) + '01' + '01'
			cDataFinAux := ALLTRIM(cData) + '12' + '31'

		ELSEIF nplanfat == 2 .OR. nplanfin == 2 // mês

			cDataIniAux := STRTRAN(ALLTRIM(cData),'/','') + '01'
			cDataFinAux := DTOS(LASTDAY(STOD(STRTRAN(ALLTRIM(cData),'/','') + '01')))

		ELSE //dia

			cDataIniAux := DTOS(CTOD(cData))
			cDataFinAux := DTOS(CTOD(cData))

		ENDIF

	ENDIF	

	IF cfuncao == 'MES'

		cDataIniAux := STRTRAN(ALLTRIM(cData),'/','') + '01'
		cDataFinAux := DTOS(LASTDAY(STOD(STRTRAN(ALLTRIM(cData),'/','') + '01')))

	
	ENDIF

	IF cfuncao == 'ANO'

		cDataIniAux := ALLTRIM(cData) + '01' + '01'
		cDataFinAux := ALLTRIM(cData) + '12' + '31'

	
	ENDIF

	IF cfuncao == 'TOTAL'

		IF cRel == 'FAT'

			cDataIniAux := DTOS(dDtIniFat)
			cDataFinAux := DTOS(dDtFinFat)

		ELSE

			cDataIniAux := DTOS(dDtIniFin)
			cDataFinAux := DTOS(dDtFinFin)

		ENDIF	

	
	ENDIF

	IF cRel == 'FAT'

		cQuery:= sqlMVFat(cDataIniAux,cDataFinAux,cCnpjs)

	ELSE

		cQuery:= sqlMVFin(cDataIniAux,cDataFinAux,cCnpjs)

	ENDIF

	IF SELECT("D_MEDVENDA") > 0

		D_MEDVENDA->(DBCLOSEAREA())

	ENDIF

	TCQUERY cQuery NEW ALIAS "D_MEDVENDA"

	nCont       := 0
	nSomaValor  := 0
	nSomaMedia  := 0 
	nPMPonLinha := 0

	DBSELECTAREA("D_MEDVENDA")
	D_MEDVENDA->(DBGOTOP())
	WHILE !D_MEDVENDA->(EOF())

		nCont       := nCont + 1
		nSomaValor  := nSomaValor + D_MEDVENDA->E1_VALOR
		nSomaMedia  := nSomaMedia + D_MEDVENDA->DIF_VENC_EMIS
		nPMPonLinha := nPMPonLinha + (D_MEDVENDA->E1_VALOR * D_MEDVENDA->DIF_VENC_EMIS)
		
		D_MEDVENDA->(DBSKIP())

	ENDDO
	D_MEDVENDA->(DBCLOSEAREA())
		
	IF cTipoMedia == 'VENDA'

		nValor := nSomaMedia / nCont

	ELSE

		nValor := nPMPonLinha / nSomaValor

	ENDIF	

Return(nValor)	

STATIC FUNCTION sqlMVFat(cDataIniFat,cDataFinFat,cCnpjs)
	
	Local cQuery:= ""
	
	cQuery += " SELECT CONVERT(NUMERIC,CONVERT(DATETIME, E1_VENCREA) - CONVERT(DATETIME, E1_EMISSAO)) AS DIF_VENC_EMIS,E1_VALOR "
	cQuery += "  FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
	cQuery += " INNER JOIN " + RETSQLNAME("SA1") + " SA1 WITH (NOLOCK) "
	cQuery += "         ON A1_COD          = E1_CLIENTE "
	cQuery += "        AND A1_LOJA         = E1_LOJA "
	cQuery += "        AND A1_CGC         IN (" + cCnpjs + ") "
	cQuery += "        AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE E1_EMISSAO          >= '" + cDataIniFat + "' " 
	cQuery += "   AND E1_EMISSAO          <= '" + cDataFinFat + "' " 
	cQuery += "   AND SE1.E1_TIPO          = 'NF' "
	cQuery += "   AND SE1.D_E_L_E_T_      <> '*' "
	cQuery += "   ORDER BY E1_NUM "
	
Return cQuery

STATIC FUNCTION sqlMVFin(cDataIniFat,cDataFinFat,cCnpjs)
	
	Local cQuery:= ""
	
	cQuery += " SELECT CONVERT(NUMERIC,CONVERT(DATETIME, E1_VENCREA) - CONVERT(DATETIME, E1_EMISSAO)) AS DIF_VENC_EMIS,E1_VALOR "
	cQuery += "  FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
	cQuery += " INNER JOIN " + RETSQLNAME("SA1") + " SA1 WITH (NOLOCK) "
	cQuery += "         ON A1_COD          = E1_CLIENTE "
	cQuery += "        AND A1_LOJA         = E1_LOJA "
	cQuery += "        AND A1_CGC         IN (" + cCnpjs + ") "
	cQuery += "        AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE E1_VENCREA          >= '" + cDataIniFat + "' " 
	cQuery += "   AND E1_VENCREA          <= '" + cDataFinFat + "' " 
	cQuery += "   AND SE1.E1_TIPO          = 'NF' "
	cQuery += "   AND SE1.D_E_L_E_T_      <> '*' "
	cQuery += "   ORDER BY E1_NUM "
	
Return cQuery

STATIC FUNCTION MediaEKgFat(cCnpjs)

	Local cDataMedIni := ''
	Local cDataMedFin := ''
	Local cDataKgIni  := ''
	Local cDataKgFin  := ''
	Local nContMedia  := 0
	
	IF nplanfat == 1  // Ano

		cDataMedIni := ''
		cDataMedFin := ''
		cDataKgIni  := ''
	    cDataKgFin  := ''
		nContMedia   := 0

		DbSelectArea("TEMPFAT")
		TEMPFAT->(DBGOTOP())

		WHILE !TEMPFAT->(EOF())

			IF SUBSTR(TEMPFAT->TM_DATA,1,4) $ 'TOTAL'
			   
			    cDataMedIni := DTOS(ddtIniFat)
				cDataMedFin := DTOS(ddtFinFat)
				cDataKgIni  := DTOS(ddtIniFat)
	    		cDataKgFin  := DTOS(ddtFinFat)

				RECLOCK("TEMPFAT",.F.)

					TEMPFAT->TM_MEDIA := CALCULAMEDIA(DateDiffMonth(ddtIniFat,ddtFinFat),cDataMedIni,cDataMedFin,cCnpjs)
					TEMPFAT->TM_KG    := CALCULAKG(cDataKgIni,cDataKgFin,cCnpjs)
					
				MSUNLOCK()

				TEMPFAT->(DBSKIP())
			    LOOP

			ENDIF

			cDataMedIni := SUBSTR(TEMPFAT->TM_DATA,1,4) + '0101'
			cDataMedFin := SUBSTR(TEMPFAT->TM_DATA,1,4) + '1231'
			cDataKgIni  := SUBSTR(TEMPFAT->TM_DATA,1,4) + '0101'
			cDataKgFin  := SUBSTR(TEMPFAT->TM_DATA,1,4) + '1231'

			RECLOCK("TEMPFAT",.F.)

				TEMPFAT->TM_MEDIA := CALCULAMEDIA(DateDiffMonth(STOD(cDataMedIni),IIF(STOD(cDataMedFin) > DATE(),DATE(),STOD(cDataMedFin))) + 1,cDataMedIni,cDataMedFin,cCnpjs)
				TEMPFAT->TM_KG    := CALCULAKG(cDataKgIni,cDataKgFin,cCnpjs)
				
			MSUNLOCK()
			
			TEMPFAT->(DBSKIP())

		ENDDO
			
	ELSEIF nplanfat == 2  // mês

		cDataMedIni := ''
		cDataMedFin := ''
		cDataKgIni  := ''
	    cDataKgFin  := ''
		nContMedia  := 0

		DbSelectArea("TEMPFAT")
		TEMPFAT->(DBGOTOP())

		cDataMedIni := DTOS(FIRSTDATE(CTOD("01/" + SUBSTR(TEMPFAT->TM_DATA,6,2) + "/" + SUBSTR(TEMPFAT->TM_DATA,1,4))))
		cDataMedFin := ''
		cDataKgIni  := DTOS(FIRSTDATE(CTOD("01/" + SUBSTR(TEMPFAT->TM_DATA,6,2) + "/" + SUBSTR(TEMPFAT->TM_DATA,1,4))))
	    cDataKgFin  := DTOS(LASTDATE(CTOD("01/" + SUBSTR(TEMPFAT->TM_DATA,6,2) + "/" + SUBSTR(TEMPFAT->TM_DATA,1,4))))

		WHILE !TEMPFAT->(EOF())

			IF SUBSTR(TEMPFAT->TM_DATA,1,3) $ 'ANO'

				cDataMedIni := SUBSTR(TEMPFAT->TM_DATA,5,4) + '0101'
				cDataMedFin := SUBSTR(TEMPFAT->TM_DATA,5,4) + '1231'
				cDataKgIni  := SUBSTR(TEMPFAT->TM_DATA,5,4) + '0101'
	    		cDataKgFin  := SUBSTR(TEMPFAT->TM_DATA,5,4) + '1231'

				RECLOCK("TEMPFAT",.F.)

					TEMPFAT->TM_MEDIA := CALCULAMEDIA(DateDiffMonth(STOD(cDataMedIni),IIF(STOD(cDataMedFin) > DATE(),DATE(),STOD(cDataMedFin))) + 1,cDataMedIni,cDataMedFin,cCnpjs)
					TEMPFAT->TM_KG    := CALCULAKG(cDataKgIni,cDataKgFin,cCnpjs)
					
				MSUNLOCK()

				cDataMedIni := CVALTOCHAR(VAL(SUBSTR(TEMPFAT->TM_DATA,5,4)) + 1) + '0101'

				TEMPFAT->(DBSKIP())
			    LOOP

			ENDIF

			IF SUBSTR(TEMPFAT->TM_DATA,1,4) $ 'TOTAL'
			   
			    cDataMedIni := DTOS(ddtIniFat)
				cDataMedFin := DTOS(ddtFinFat)
				cDataKgIni  := DTOS(ddtIniFat)
	    		cDataKgFin  := DTOS(ddtFinFat)

				RECLOCK("TEMPFAT",.F.)

					TEMPFAT->TM_MEDIA := CALCULAMEDIA(DateDiffMonth(ddtIniFat,IIF(ddtFinFat > DATE(),DATE(),ddtFinFat)) + 1,cDataMedIni,cDataMedFin,cCnpjs)
					TEMPFAT->TM_KG    := CALCULAKG(cDataKgIni,cDataKgFin,cCnpjs)
					
				MSUNLOCK()

				TEMPFAT->(DBSKIP())
			    LOOP

			ENDIF

			cDataKgIni  := DTOS(FIRSTDATE(CTOD("01/" + SUBSTR(TEMPFAT->TM_DATA,6,2) + "/" + SUBSTR(TEMPFAT->TM_DATA,1,4))))
	    	cDataKgFin  := DTOS(LASTDATE(CTOD("01/" + SUBSTR(TEMPFAT->TM_DATA,6,2) + "/" + SUBSTR(TEMPFAT->TM_DATA,1,4))))
			RECLOCK("TEMPFAT",.F.)

				TEMPFAT->TM_KG := CALCULAKG(cDataKgIni,cDataKgFin,cCnpjs)
				
			MSUNLOCK()
			
			nContMedia := nContMedia + 1

			IF nContMedia > 3

				nContMedia := 1

			ENDIF

			IF nContMedia == 3

				cDataMedFin := DTOS(LASTDATE(CTOD( "01/" + SUBSTR(TEMPFAT->TM_DATA,6,2) + "/" + SUBSTR(TEMPFAT->TM_DATA,1,4))))

				RECLOCK("TEMPFAT",.F.)

					TEMPFAT->TM_MEDIA := CALCULAMEDIA(nContMedia,cDataMedIni,cDataMedFin,cCnpjs)
					
				MSUNLOCK()

				cDataMedIni := DTOS(STOD(cDataMedFin) + 1)
				
			ENDIF
			
			TEMPFAT->(DBSKIP())
		ENDDO

	ELSE //dia

		cDataMedIni := ''
		cDataMedFin := ''
		cDataKgIni  := ''
	    cDataKgFin  := ''
		nContMedia  := 0

		DbSelectArea("TEMPFAT")
		TEMPFAT->(DBGOTOP())

		WHILE !TEMPFAT->(EOF())

			IF SUBSTR(TEMPFAT->TM_DATA,1,1) $ 'M'
				
				cDataMedIni := DTOS(FIRSTDAY(STOD(TEMPFAT->TM_ANO + SUBSTR(TEMPFAT->TM_DATA,5,2) + '01')))
				cDataMedFin := DTOS(LASTDAY(STOD(TEMPFAT->TM_ANO + SUBSTR(TEMPFAT->TM_DATA,5,2) + '01')))
				cDataKgIni  := DTOS(FIRSTDAY(STOD(TEMPFAT->TM_ANO + SUBSTR(TEMPFAT->TM_DATA,5,2) + '01')))
	    		cDataKgFin  := DTOS(LASTDAY(STOD(TEMPFAT->TM_ANO + SUBSTR(TEMPFAT->TM_DATA,5,2) + '01')))

				RECLOCK("TEMPFAT",.F.)

					TEMPFAT->TM_MEDIA := CALCULAMEDIA(DateDiffDay(STOD(cDataMedIni),STOD(cDataMedFin)),cDataMedIni,cDataMedFin,cCnpjs)
					TEMPFAT->TM_KG    := CALCULAKG(cDataKgIni,cDataKgFin,cCnpjs)
					
				MSUNLOCK()

				cDataMedIni := CVALTOCHAR(VAL(SUBSTR(TEMPFAT->TM_DATA,5,4)) + 1) + '0101'

				TEMPFAT->(DBSKIP())
			    LOOP
                
			ENDIF

			IF SUBSTR(TEMPFAT->TM_DATA,1,3) $ 'ANO'
                
				cDataMedIni := SUBSTR(TEMPFAT->TM_DATA,5,4) + '0101'
				cDataMedFin := SUBSTR(TEMPFAT->TM_DATA,5,4) + '1231'
				cDataKgIni  := SUBSTR(TEMPFAT->TM_DATA,5,4) + '0101'
	    		cDataKgFin  := SUBSTR(TEMPFAT->TM_DATA,5,4) + '1231'

				RECLOCK("TEMPFAT",.F.)

					TEMPFAT->TM_MEDIA := CALCULAMEDIA(DateDiffMonth(STOD(cDataMedIni),IIF(STOD(cDataMedFin) > DATE(),DATE(),STOD(cDataMedFin))) + 1,cDataMedIni,cDataMedFin,cCnpjs)
					TEMPFAT->TM_KG    := CALCULAKG(cDataKgIni,cDataKgFin,cCnpjs)
					
				MSUNLOCK()

				cDataMedIni := CVALTOCHAR(VAL(SUBSTR(TEMPFAT->TM_DATA,5,4)) + 1) + '0101'

				TEMPFAT->(DBSKIP())
			    LOOP
               
			ENDIF

			IF SUBSTR(TEMPFAT->TM_DATA,1,4) $ 'TOTAL'
			   
			    cDataMedIni := DTOS(ddtIniFat)
				cDataMedFin := DTOS(ddtFinFat)
				cDataKgIni  := DTOS(ddtIniFat)
	    		cDataKgFin  := DTOS(ddtFinFat)

				RECLOCK("TEMPFAT",.F.)

					TEMPFAT->TM_MEDIA := CALCULAMEDIA(DateDiffMonth(ddtIniFat,ddtFinFat),cDataMedIni,cDataMedFin,cCnpjs)
					TEMPFAT->TM_KG    := CALCULAKG(cDataKgIni,cDataKgFin,cCnpjs)
					
				MSUNLOCK()

				TEMPFAT->(DBSKIP())
			    LOOP
                
			ENDIF

			cDataKgIni  := DTOS(CTOD(TEMPFAT->TM_DATA))
	    	cDataKgFin  := DTOS(CTOD(TEMPFAT->TM_DATA))
			RECLOCK("TEMPFAT",.F.)

				TEMPFAT->TM_KG := CALCULAKG(cDataKgIni,cDataKgFin,cCnpjs)
				
			MSUNLOCK()
			
			TEMPFAT->(DBSKIP())

		ENDDO

	ENDIF

RETURN(NIL)

STATIC FUNCTION CALCULAMEDIA(nContMedia,cDataIni,cDataFin,cCnpjs)

	Local nValor     := 0
	Local nSomaValor := 0

	cQuery:= sqlMVFat(cDataIni,cDataFin,cCnpjs)

	IF SELECT("D_MEDIA") > 0

		D_MEDIA->(DBCLOSEAREA())

	ENDIF

	TCQUERY cQuery NEW ALIAS "D_MEDIA"

	DBSELECTAREA("D_MEDIA")
	D_MEDIA->(DBGOTOP())
	WHILE !D_MEDIA->(EOF())

		nSomaValor  := nSomaValor + D_MEDIA->E1_VALOR
		
		D_MEDIA->(DBSKIP())

	ENDDO
	D_MEDIA->(DBCLOSEAREA())

	nValor := nSomaValor / nContMedia

RETURN(nValor)	

STATIC FUNCTION CALCULAKG(cDataIni,cDataFin,cCnpjs)

	Local nValor := 0
	
	cQuery := sqlKgFat(cDataIni,cDataFin,cCnpjs)

	IF SELECT("D_KG") > 0

		D_KG->(DBCLOSEAREA())

	ENDIF

	TCQUERY cQuery NEW ALIAS "D_KG"

	DBSELECTAREA("D_KG")
	D_KG->(DBGOTOP())
	WHILE !D_KG->(EOF())

		nValor  := D_KG->TOT_KG
		
		D_KG->(DBSKIP())

	ENDDO
	D_KG->(DBCLOSEAREA())

RETURN(nValor)	

STATIC FUNCTION sqlKgFat(cDataIniFat,cDataFinFat,cCnpjs)
	
	Local cQuery:= ""

	cQuery += " SELECT  ISNULL(SUM(B_FATURAMENTO.F2_PLIQUI),0) - ISNULL(SUM(B_DEVOLUCAO.D1_QUANT),0) AS TOT_KG "
	cQuery += "   FROM (SELECT A1_FILIAL, A1_COD, A1_LOJA, A1_NOME, A1_VEND, LEFT(A1_CGC,8) AS RAIZ_CGC,A1_MSBLQL "
	cQuery += "           FROM " + RETSQLNAME("SA1") + " SA1 WITH (NOLOCK) "
	cQuery += "			 WHERE SA1.D_E_L_E_T_='' "
	cQuery += "			   AND A1_CGC       IN (" + cCnpjs + ") ""
	cQuery += "		   ) AS B_CLIENTE "
	cQuery += "	  LEFT OUTER JOIN (SELECT BSE1F.E1_FILIAL,BSE1F.E1_CLIENTE,BSE1F.E1_LOJA,BSE1F.PER,SUM(BSE1F.E1_SALDO) AS E1_SALDO,SUM(BSF2.F2_PLIQUI) AS F2_PLIQUI  "
	cQuery += "						 FROM (SELECT E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_NUM,E1_PREFIXO, CAST(YEAR(E1_EMISSAO) AS VARCHAR)+RIGHT('00'+CAST(MONTH(E1_EMISSAO) AS VARCHAR),2) AS PER, E1_VALOR AS E1_SALDO "
	cQuery += "                              FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
	cQuery += "								WHERE SE1.D_E_L_E_T_  = '' "   
	cQuery += "								  AND E1_TIPO        IN ('NF ','NCI','NDC') "
	cQuery += "								  AND E1_EMISSAO     >= '" + cDataIniFat + "' " 
	cQuery += "								  AND E1_EMISSAO     <= '" + cDataFinFat + "' "
	cQuery += "							  ) AS BSE1F "  
	cQuery += "							  LEFT OUTER JOIN (SELECT F2_FILIAL,F2_DUPL, F2_SERIE, SUM(F2_PLIQUI) AS F2_PLIQUI "
    cQuery += "                                              FROM " + RETSQLNAME("SF2") + " SF2 WITH (NOLOCK) "
	cQuery += "												WHERE F2_DUPL        <> '' "
	cQuery += "												  AND SF2.D_E_L_E_T_  = '' "
	cQuery += "										  	 GROUP BY F2_FILIAL,F2_DUPL, F2_SERIE "
	cQuery += "											  ) BSF2 "
	cQuery += "											ON BSE1F.E1_FILIAL  = BSF2.F2_FILIAL " 
	cQuery += "										   AND BSE1F.E1_NUM     = BSF2.F2_DUPL "
	cQuery += "										   AND BSE1F.E1_PREFIXO = BSF2.F2_SERIE "
	cQuery += "									  GROUP BY BSE1F.E1_FILIAL, BSE1F.E1_CLIENTE, BSE1F.E1_LOJA, BSE1F.PER "
	cQuery += "         ) AS B_FATURAMENTO "
	cQuery += "		   ON B_CLIENTE.A1_COD  = B_FATURAMENTO.E1_CLIENTE "   
	cQuery += "		  AND B_CLIENTE.A1_LOJA = B_FATURAMENTO.E1_LOJA "   
	cQuery += "	  LEFT OUTER JOIN (SELECT BSE1D.E1_FILIAL,BSE1D.E1_CLIENTE,BSE1D.E1_LOJA,BSE1D.E1_NUM,BSE1D.PER, SUM(BSE1D.E1_SALDO) AS E1_SALDO, SUM(BSD1.D1_QUANT) AS D1_QUANT  " 
	cQuery += "	 			 FROM (SELECT E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_NUM,E1_PREFIXO,CAST(YEAR(E1_EMISSAO) AS VARCHAR)+RIGHT('00'+CAST(MONTH(E1_EMISSAO) AS VARCHAR),2) AS PER,E1_VALOR AS E1_SALDO "  
	cQuery += "                      FROM " + RETSQLNAME("SE1") + " SE1 WITH (NOLOCK) "
	cQuery += "						WHERE SE1.D_E_L_E_T_  = '' "
	cQuery += "						  AND E1_TIPO        IN ('NCC') "
	cQuery += "						  AND E1_EMISSAO     >= '" + cDataIniFat + "' "
	cQuery += "						  AND E1_EMISSAO     <= '" + cDataFinFat + "' " 
	cQuery += "					  ) AS BSE1D "
	cQuery += "					  LEFT OUTER JOIN ( SELECT D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, SUM(D1_QUANT) AS D1_QUANT "  
	cQuery += "                                       FROM " + RETSQLNAME("SD1") + " SD1 WITH (NOLOCK) "
	cQuery += "												WHERE SD1.D_E_L_E_T_ = '' " 
	cQuery += "										  GROUP BY D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA " 
	cQuery += "									  ) BSD1 "
	cQuery += "									  ON BSE1D.E1_FILIAL  = BSD1.D1_FILIAL "
	cQuery += "									 AND BSE1D.E1_NUM     = BSD1.D1_DOC "
	cQuery += "									 AND BSE1D.E1_PREFIXO = BSD1.D1_SERIE "
	cQuery += "									 AND BSE1D.E1_CLIENTE = BSD1.D1_FORNECE "
	cQuery += "									 AND BSE1D.E1_LOJA    = BSD1.D1_LOJA "
	cQuery += "					 GROUP BY BSE1D.E1_FILIAL,BSE1D.E1_CLIENTE,BSE1D.E1_LOJA,BSE1D.E1_NUM,BSE1D.PER " 
	cQuery += "					 ) AS B_DEVOLUCAO "   
	cQuery += "	                ON B_FATURAMENTO.E1_FILIAL  = B_DEVOLUCAO.E1_FILIAL "
	cQuery += "				   AND B_FATURAMENTO.E1_CLIENTE = B_DEVOLUCAO.E1_CLIENTE "
	cQuery += "				   AND B_FATURAMENTO.E1_LOJA    = B_DEVOLUCAO.E1_LOJA "
	cQuery += "				   AND B_FATURAMENTO.PER        = B_DEVOLUCAO.PER "

Return cQuery

STATIC FUNCTION NOMEREDE()

	Local cNome := ''
	Local aArea	:= TREDE->(GetArea())

	DBSELECTAREA("TREDE")
	TREDE->(DBGOTOP())
	WHILE !TREDE->(EOF())

		IF ALLTRIM(TREDE->OK) <> ''

			cNome := TREDE->TMP_RED + ' '+ TREDE->TMP_DESC
			RestArea(aArea)
			EXIT

		ENDIF

		TREDE->(DBSKIP())

	ENDDO

	RestArea(aArea)

RETURN(cNome)

STATIC FUNCTION NOMECLIENTE()

	Local cNome := ''
	Local aArea	:= TCLI->(GetArea())

	DBSELECTAREA("TCLI")
	TCLI->(DBGOTOP())
	WHILE !TCLI->(EOF())

		IF ALLTRIM(TCLI->OK) <> ''

			cNome := TCLI->TMP_COD + ' '+ TCLI->TMP_LOJA + ' '+ TCLI->TMP_NOME
			RestArea(aArea)
			EXIT

		ENDIF

		TCLI->(DBSKIP())

	ENDDO

	RestArea(aArea)

RETURN(cNome)
