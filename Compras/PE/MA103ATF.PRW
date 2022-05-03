#Include 'Protheus.ch'

/*/{Protheus.doc} User Function MA103ATF
	Ponto de Entrada para o usuário do recebimento identificar se o ativo imobilizado é uma benfeitoria ou não
	@type  Function
	@author Abel Babini
	@since 22/07/2019
	@history Chamado 045022 - Abel Babini - 22/07/2019 - Identificaçãr de Benfeitoria de Imob.
	@history Ticket 71120   - Abel Babini - 02/05/2022 - Ajuste na classificação adicionando regra pelo CST
	/*/
User Function MA103ATF()
	Local aCab 		:= ParamIXB[1] 
	Local aItens	:= ParamIXB[2] 
	//Local nItem
	Local oDlgAtB	:= Nil
	Local oBtnCan	:= Nil
	Local oBtnOK	:= Nil
	Local cCbAtfBn	:= ""

	Local nPNSerie	:= ASCAN(aCab, { |X| ALLTRIM(X[1]) == "N1_NSERIE" })
	Local nPNFisca	:= ASCAN(aCab, { |X| ALLTRIM(X[1]) == "N1_NFISCAL" })
	Local nPNFItem	:= ASCAN(aCab, { |X| ALLTRIM(X[1]) == "N1_NFITEM" })
	Local nPFornec	:= ASCAN(aCab, { |X| ALLTRIM(X[1]) == "N1_FORNEC" })
	Local nPLoja	:= ASCAN(aCab, { |X| ALLTRIM(X[1]) == "N1_LOJA" })
	Local nPQuant	:= ASCAN(aCab, { |X| ALLTRIM(X[1]) == "N1_QUANTD" })
	Local nPDescri	:= ASCAN(aCab, { |X| ALLTRIM(X[1]) == "N1_DESCRIC" })
	Local nPProdut	:= ASCAN(aCab, { |X| ALLTRIM(X[1]) == "N1_PRODUTO" })
	
	Local nPAtfTip	:= ASCAN(aItens[1], { |X| ALLTRIM(X[1]) == "N3_TIPO" })
	
	//Ticket 71120   - Abel Babini - 02/05/2022 - Ajuste na classificação adicionando regra pelo CST
	Local nPCSTPis	:= ASCAN(aCab, { |X| ALLTRIM(X[1]) == "N1_CSTPIS" })
	Local lAtuFrc		:= .F.

	Local cXObsPC	:= Posicione("SC7",1,xFilial("SC7")+SD1->(D1_PEDIDO+D1_ITEMPC),"C7_OBS")

	//Definião de Variáveis de classificação
	Local cXBCCBnB	:= '10'//Cod BCC Bens 
	Local cXBCCBnS	:= '10'//Cod BCC Serviços
	Local cXIUtBnB	:= '1'//Indicador de Utilização Bens
	Local cXIUtBnS	:= '2'//Indicador de Utilização Serviços
	Local nXMes		:= 24 //Numero de Meses de Pis e Cofins

	//Definição de Fontes
	Local oFont001	:= TFont():New( "Arial",,14,,.f.,,,,,.f. )
	Local oFont002	:= TFont():New( "Arial",,16,,.T.,,,,,.f. )
	Local oFont003	:= TFont():New( "Arial",,18,,.T.,,,,,.f. )
	
	//Definição da Data para entrada em produção
	Local dDtIniBn	:= GETMV("MV_#DTATBN",,STOD("20190801"))
	Private aCbAtfBn	:= {'','1 - Benfeitoria Bens','2 - Benfeitoria Serviços','3 - Ativo Imobilizado'}
	//
	//Coloca em produção
	IF SD1->D1_DTDIGIT >= dDtIniBn
	
		DEFINE MSDIALOG oDlgAtB TITLE "Classificação de Ativo Imobilizado" FROM 000, 000  TO 240, 640 COLORS 0, 16777215 PIXEL style 128
		oDlgAtB:lEscClose     := .F. //Permite sair ao se pressionar a tecla ESC.
		
		//DEFINE SBUTTON oBtnCan 	FROM 089, 190 TYPE 02 OF oDlgAtB ENABLE Action( oDlgAtB:End() )
		DEFINE SBUTTON oBtnOK 	FROM 089, 240 TYPE 01 OF oDlgAtB ENABLE Action( IIF( ValidAT( cCbAtfBn ), ( nOpcX := 1, oDlgAtB:End() ), .F. ) )
		
		@ 005,010 SAY OemToAnsi('Cod. Forn.')					SIZE 030,025 	OF oDlgAtB COLORS 0 PIXEL
		@ 014,010 MSGET OemToAnsi(ALLTRIM(aCab[nPFornec,2]))	SIZE 030,008	OF oDlgAtB PIXEL When .F. PICTURE '@!'
		
		@ 005,040 SAY OemToAnsi('Loja Forn.')					SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
		@ 014,040 MSGET OemToAnsi(ALLTRIM(aCab[nPLoja,2]))		SIZE 015,008	OF oDlgAtB PIXEL When .F. PICTURE '@!'
		
		@ 005,070 SAY OemToAnsi('Fornecedor')					SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
		@ 014,070 MSGET OemToAnsi(SA2->A2_NOME)					SIZE 100,008	OF oDlgAtB PIXEL When .F. PICTURE '@!'
		
		@ 005,180 SAY OemToAnsi('Dt. Emissão')					SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
		@ 014,180 MSGET OemToAnsi(DTOC(SD1->D1_EMISSAO))		SIZE 035,008	OF oDlgAtB PIXEL When .F. PICTURE '@!'
		
		@ 005,220 SAY OemToAnsi('Dt. Entrada')					SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
		@ 014,220 MSGET OemToAnsi(DTOC(SD1->D1_DTDIGIT))		SIZE 035,008	OF oDlgAtB PIXEL When .F. PICTURE '@!'
		
	
		@ 030,010 SAY OemToAnsi('Nota')							SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
		@ 039,010 MSGET OemToAnsi(ALLTRIM(aCab[nPNFisca,2]))	SIZE 040,008 	OF oDlgAtB PIXEL When .F. PICTURE '@!'
		
		@ 030,055 SAY OemToAnsi('Série')						SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
		@ 039,055 MSGET OemToAnsi(ALLTRIM(aCab[nPNSerie,2]))	SIZE 017,008 	OF oDlgAtB PIXEL When .F. PICTURE '@!'
		
		@ 030,080 SAY OemToAnsi('Item NF')						SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
		@ 039,080 MSGET OemToAnsi(ALLTRIM(aCab[nPNFItem,2]))	SIZE 022,008 	OF oDlgAtB PIXEL When .F. PICTURE '@!'
		
		@ 030,105 SAY OemToAnsi('Cod. Prod')					SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
		@ 039,105 MSGET OemToAnsi(ALLTRIM(aCab[nPProdut,2]))	SIZE 050,008 	OF oDlgAtB PIXEL When .F. PICTURE '@!'
		
		@ 030,160 SAY OemToAnsi('Produto')						SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
		@ 039,160 MSGET OemToAnsi(ALLTRIM(aCab[nPDescri,2]))	SIZE 110,008 	OF oDlgAtB PIXEL When .F. PICTURE '@!'
	
		@ 055,010 SAY OemToAnsi('Observações Ped. Compra')		SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
		@ 064,010 MSGET OemToAnsi(ALLTRIM(cXObsPC))				SIZE 200,008 	OF oDlgAtB PIXEL When .F. PICTURE '@!'
	
		@ 080,010 SAY OemToAnsi('Benfeitoria')					SIZE 080,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
		@ 089,010 ComboBox cCbAtfBn Items aCbAtfBn				SIZE 080,015 	OF oDlgAtB PIXEL 
		
		ACTIVATE MSDIALOG oDlgAtB CENTERED
		
		//Ticket 71120   - Abel Babini - 02/05/2022 - Ajuste na classificação adicionando regra pelo CST
		If nPCSTPis > 0 .AND. aCab[nPCSTPis,2] == '56'
			lAtuFrc := .T.
		Endif

		//Adição de campos customizados - SN1
		IF Alltrim(cCbAtfBn) == aCbAtfBn[2] .AND. lAtuFrc //bens//'1 - Benfeitoria Bens','2 - Benfeitoria Serviços','3 - Ativo Imobilizado'
			aAdd(aCab,{"N1_CALCPIS" , "3" })
			aAdd(aCab,{"N1_MESCPIS" , nXMes })
			aAdd(aCab,{"N1_CODBCC" , cXBCCBnB })
			aAdd(aCab,{"N1_UTIPATR" , cXIUtBnB })		
		ELSEIF Alltrim(cCbAtfBn) == aCbAtfBn[3] .AND. lAtuFrc //servicos //'1 - Benfeitoria Bens','2 - Benfeitoria Serviços','3 - Ativo Imobilizado'
			aAdd(aCab,{"N1_CALCPIS" , "3" })
			aAdd(aCab,{"N1_MESCPIS" , nXMes })
			aAdd(aCab,{"N1_CODBCC" , cXBCCBnS })
			aAdd(aCab,{"N1_UTIPATR" , cXIUtBnS })
		ELSEIF Alltrim(cCbAtfBn) == aCbAtfBn[3] //servicos //'1 - Benfeitoria Bens','2 - Benfeitoria Serviços','3 - Ativo Imobilizado'
			aAdd(aCab,{"N1_CODBCC" , SF4->F4_CODBCC })
		ENDIF
		aAdd(aCab,{"N1_XATFBEN" , Substr(cCbAtfBn,1,1) })

	ENDIF
	
Return({aCab,aItens})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidAT        ºAutor  ³Abel Babini         ºData  ³  22/07/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o preenchimento do campo de benfeitoria                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Adoro S/A                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/Static Function ValidAT( cCbAtfBn )
	Local lRet:= .F.
	IF Alltrim(cCbAtfBn) != '' //'1 - Benfeitoria Bens','2 - Benfeitoria Serviços','3 - Ativo Imobilizado'
		lRet := .T.
	ELSE
		AVISO("ATENÇÃO","É obrigatório a indicação do campo Benfeitoria.")
	ENDIF
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³xGatUtPa       ºAutor  ³Abel Babini         ºData  ³  22/07/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gatilho para manter conteudo do campo N1_UTIPATR conforme clas-  º±±
±±º          ³sificação de benfeitoria no lançamento do Doc. de Entrada        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Adoro S/A                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function xGatUtPa()
	Local lRet		:= .T.
	Local oModel	:= FWModelActive()
	Local cAtfben	:= oModel:GetValue('SN1MASTER','N1_XATFBEN')
	Local cDesc		:= oModel:GetValue('SN1MASTER','N1_DESCRIC')
	
	oModel:SetValue('SN3DETAIL','N3_HISTOR',cDesc)
	
	IF ALLTRIM(SN1->N1_XATFBEN) $ '1/2'
		lRet := oModel:SetValue('SN1MASTER','N1_UTIPATR',cAtfben)
	ENDIF
Return lRet
