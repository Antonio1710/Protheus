#include 'protheus.ch'

/*/{Protheus.doc} User Function ADFIN081P
	Inclui solicitação de Pagamento Antecipado
	@type  Function
	@author Abel Babini Filho
	@since 08/11/2019
	@version version
	@history Chamado n.043195 - Abel Babini - 13/09/2019 - Ajuste para considerar tabela ZFQ de Pedido de Compra de Pagamento Antecipado
	@history Chamado n.043195 - Abel Babini - 23/09/2019 - Apenas validar parametro de usuário caso o mesmo não esteja em branco.
	@history Chamado n.052421 - Abel Babini - 08/10/2019 - Retira Validação da Condicao de pagamento antecipada
	@history Chamado n.053212 - Abel Babini - 08/11/2019 - Possibilita inclusão de PA em outras moedas
	@history Chamado n.053212 - Abel Babini - 19/11/2019 - Possibilita inclusão de PA com outras datas de vencimento
	@history Chamado n.053482 - Abel Babini - 02/12/2019 - Considerar Valor de Frete, Despesas, IPI e Desconto no Saldo da Solicitação de PA
	@history Chamado n.054139 - FWNM        - 18/12/2019 || OS 055560 || FINANCAS || EDUARDO || 8352 || SOLICITACAO DE PA
	@history Chamado n.057663 - Abel Babini - 27/04/2020 - OS 059175 || SUPRIMENTOS || EVANDRA || 8354 || SOLICITACAO PA - Permitir visualizar solicitações de PA e suas respectivas datas de pagamento mesmo após a inclusão da NF
	@history Chamado n.059471 - Abel Babini - 06/07/2020 - Considerar o Valor do Seguro no Saldo da Solicitação de PA
	@history Ticket  n.5389   - Adriano Savoine - 20/11/2020 - Inserido o item no codigo para filtrar filial mais pedido mesmo quando efetuarem busca por fornecedor.
	@history Ticket  n.9969   - Andre Mendes - 24/02/2021 - Inclusão de PA no sistema - O valor de validação está incorreto.
	@history Ticket  n.11157  - Abel Babini  - 22/03/2021 - Ajuste saldo do pedido - valor frete
	@history Ticket  n.11157  - Abel Babini  - 26/03/2021 - Ajuste saldo do pedido - solicitações de PA compensadas com NF´s atreladas ao mesmo pedido
/*/
User Function ADFIN081P()

	Local aArea		:= GetArea()
	Local nItLib	:= 0
	Local nItQtM	:= 0
	Local nVlSolPA	:= 0
	Local nVlSldPC	:= 0
	Local nValPPA	:= 0
	Local _nNumPed	:= SC7->C7_NUM
	Local nOpcX 	:= 2
	Local nParcPA	:= 0
	Local nMParc	:= 0
	Local nRegSC7	:= SC7->(RecNo())
	Local _cUserPA	:= GETMV("MV_#USERPA",,"|") //Usuarios com permissao de incluir Solicitacao de PA
	Local aBrw01Rs	:= {} 
	Local oBrw01Rs
	Local _nRecSE2
	Local cBordero 	:= ""
	Local nSaldo		:= 0
	Local lSE2Fnd		:= .F.
	Local cStatus		:= ""
	Local dDtBxE2		:= "" //Chamado n.057663 - Abel Babini - 27/04/2020 - OS 059175 || SUPRIMENTOS || EVANDRA || 8354 || SOLICITACAO PA - Permitir visualizar solicitações de PA e suas respectivas datas de pagamento mesmo após a inclusão da NF
	Local nC7VlFre  := 0

	Local nValCMP := 0 //INICIO Ticket  n.11157  - Abel Babini  - 26/03/2021 - Ajuste saldo do pedido - solicitações de PA compensadas com NF´s atreladas ao mesmo pedido
	Local cQryCMP := GetNextAlias() //INICIO Ticket  n.11157  - Abel Babini  - 26/03/2021 - Ajuste saldo do pedido - solicitações de PA compensadas com NF´s atreladas ao mesmo pedido

	Private oDlgAtB
	Private dSrvData	:= CtoD(substr(FwTimeUF('SP')[1],7,2)+"/"+substr(FwTimeUF('SP')[1],5,2)+"/"+substr(FwTimeUF('SP')[1],1,4))
	Private dVencPA	:= dSrvData
	Private cNatureza := Space(TamSX3("ED_CODIGO")[1])

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Inclui solicitação de Pagamento Antecipado')
	
	//Valida acesso do Usuário
	//Ch. 043195 - 23/09/2019 - ABEL BABINI FILHO - Apenas validar parametro de usuário caso o mesmo não esteja em branco. Isso significa que apenas existira regra de usuario
	//se o parametro comecar a ser utilizado.
	
	If !Empty(Alltrim(_cUserPA)) .AND. !(Alltrim(__cUserId) $ _cUserPA)
		Alert('Usuário sem acesso para incluir Solicitação de Pagamento Antecipado!')
		Return
	endif

	If AllTrim(SC7->C7_USER) <> AllTrim(RetCodUsr())
		Aviso(	"ADFIN081P-01",;
				"Somente comprador que incluiu este PC pode incluir Solicitação de PA... Inclusão não permitida!",;
				{ "&Retorna" },,;
				"Solicitação de PA" )
		Return
	EndIf
	
	//Valida Condição de Pagamento
	//Chamado 052421 || OS 053774 || FINANCAS || DRIELE || 8376 || SOLICITACAO PA || ABEL BABINI || 08/10/2019
	//Validação comentada por solicitação do usuário e gestor
	//if Posicione("SE4",1,xFilial("SE4") + SC7->C7_COND,"E4_CTRADT") <> "1"
	//	Alert('Este Pedido de Compra não possui Cond. de Pagamento para Pagamento Antecipado!')
	//	Return
	//endif
	//Chamado 052421 || OS 053774 || FINANCAS || DRIELE || 8376 || SOLICITACAO PA || ABEL BABINI || 08/10/2019

	dbSetOrder(1) // Ticket 5389 - 20/11/2020 - ADRIANO SAVOINE

	SC7->(dbSeek(xFilial('SC7')+_nNumPed)) //Chamado n.053482 - Considerar Valor de Frete, Despesas, IPI e Desconto no Saldo da Solicitação de PA - Abel Babini - 02/12/2019
	
	While ! SC7->(eof()) .AND. SC7->C7_FILIAL == cFilAnt .AND. SC7->C7_NUM == _nNumPed
		
		//Valida se Pedido de compra está liberado
		if (SC7->C7_CONAPRO == 'L') .AND. (SC7->C7_RESIDUO != 'S')
			nItLib += 1		
		endif
		
		if (SC7->C7_QUJE < SC7->C7_QUANT) .AND. (SC7->C7_RESIDUO != 'S')
			nItQtM += 1
		endif
		
		if (SC7->C7_QUJE < SC7->C7_QUANT) .AND. (SC7->C7_CONAPRO == 'L') .AND. (SC7->C7_RESIDUO != 'S')
			//Chamado n.053482 - Considerar Valor de Frete, Despesas, IPI e Desconto no Saldo da Solicitação de PA - Abel Babini - 02/12/2019
			//nVlSldPC += Round((SC7->C7_QUANT - SC7->C7_QUJE )*C7_PRECO ,2)
			nVlSldPC += Round((SC7->C7_QUANT - SC7->C7_QUJE )*C7_PRECO,2)+ROUND(SC7->C7_VALIPI/SC7->C7_QUANT*(SC7->C7_QUANT - SC7->C7_QUJE ),2)
		endif
		
		SC7->(dbSkip())
	EndDo
	
	SC7->(dbGoTo(nRegSC7))
	//Chamado n.059471 - Considerar o Valor do Seguro no Saldo da Solicitação de PA - Abel Babini - 06/07/2019
	//Chamado n.053482 - Considerar Valor de Frete, Despesas, IPI e Desconto no Saldo da Solicitação de PA - Abel Babini - 02/12/2019
	//Ticket  n.9969   - Andre Mendes - 24/02/2021 - Inclusão de PA no sistema
	//Ticket  n.11157  - Abel Babini  - 22/03/2021 - Ajuste saldo do pedido - valor frete
	nVlSldPC += SC7->C7_FRETE + SC7->C7_DESPESA + SC7->C7_SEGURO - SC7->C7_VLDESC
	nC7VlFre := 0
	IF SC7->C7_FRETE == 0
		SC7->(dbSeek(xFilial('SC7')+_nNumPed))
		While ! SC7->(eof()) .AND. SC7->C7_FILIAL == cFilAnt .AND. SC7->C7_NUM == _nNumPed
			nC7VlFre += SC7->C7_VALFRE
			SC7->(dbSkip())
		EndDo
	ENDIF
	IF nC7VlFre > 0
		nVlSldPC += nC7VlFre
	ENDIF
	
	SC7->(dbGoTo(nRegSC7))

	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA))

	if ZFQ->(dbSeek(xFilial('ZFQ')+"MAN"+PADR(SC7->C7_NUM,9)+SC7->C7_FORNECE+SC7->C7_LOJA))
		While !ZFQ->(eof()) .AND. ALLTRIM(ZFQ->ZFQ_PREFIX) == "MAN" .AND. ALLTRIM(ZFQ->ZFQ_NUM) == ALLTRIM(SC7->C7_NUM)

			//INICIO Ticket  n.11157  - Abel Babini  - 26/03/2021 - Ajuste saldo do pedido - solicitações de PA compensadas com NF´s atreladas ao mesmo pedido	
			BeginSQL alias cQryCMP
				column E5_DATA AS DATE
				SELECT SD1.D1_PEDIDO,SD1.D1_ITEMPC,SE5.E5_VALOR,SE5.E5_VLMOED2,SE5.E5_TXMOEDA,SE5.E5_MOEDA,SE5.E5_DATA
				FROM %TABLE:SE5% SE5 (NOLOCK)
				LEFT JOIN %TABLE:SD1% SD1 (NOLOCK) ON
					SD1.D1_FILIAL = SE5.E5_FILIAL
					AND SD1.D1_SERIE = SUBSTRING(SE5.E5_DOCUMEN,1,3)
					AND SD1.D1_DOC = SUBSTRING(SE5.E5_DOCUMEN,4,9)
					AND SD1.D1_FORNECE = SUBSTRING(SE5.E5_DOCUMEN,19,6)
					AND SD1.D1_LOJA = SUBSTRING(SE5.E5_DOCUMEN,25,2)
					AND SD1.%notDel%
				WHERE SE5.E5_FILIAL = %Exp:ZFQ->ZFQ_FILIAL%
					AND SE5.E5_PREFIXO = %Exp:ZFQ->ZFQ_PREFIX%
					AND SE5.E5_NUMERO = %Exp:ZFQ->ZFQ_NUM%
					AND SE5.E5_PARCELA = %Exp:ZFQ->ZFQ_PARCEL%
					AND SE5.E5_TIPO = %Exp:ZFQ->ZFQ_TIPO%
					AND SE5.E5_CLIFOR = %Exp:ZFQ->ZFQ_FORNEC%
					AND SE5.E5_LOJA = %Exp:ZFQ->ZFQ_LOJA%
					AND SE5.E5_TIPODOC = 'BA'
					AND SE5.E5_MOTBX = 'CMP'
					AND SD1.D1_PEDIDO = %Exp:ZFQ->ZFQ_NUM%	
					AND SE5.%notDel%
			EndSQL

			nValCMP := 0
			(cQryCMP)->(dbGoTop())
			While !(cQryCMP)->(eof())
				IF Empty(Alltrim((cQryCMP)->E5_MOEDA)) .or. Alltrim((cQryCMP)->E5_MOEDA) == '01'
					nValCMP := (cQryCMP)->E5_VALOR
				ELSE
					nValCMP := Round(xMoeda((cQryCMP)->E5_VALOR,1,Val((cQryCMP)->E5_MOEDA),(cQryCMP)->E5_DATA,2,0),2)
				ENDIF
				
				(cQryCMP)->(dbSkip())
			EndDo

			(cQryCMP)->(dbCloseArea())

			nValPPA 	+= ZFQ->ZFQ_VALOR - nValCMP
			nParcPA 	+= 1
			if nMParc <= Val(ZFQ->ZFQ_PARCEL)
				nMParc := Val(ZFQ->ZFQ_PARCEL) +1
			endif
			_nRecSE2 	:= RecNo('SE2')
			cBordero 	:= ""
			nSaldo		:= 0
			lSE2Fnd		:= .F.
			dDtBxE2		:= "" //Chamado n.057663 - Abel Babini - 27/04/2020 - OS 059175 || SUPRIMENTOS || EVANDRA || 8354 || SOLICITACAO PA - Permitir visualizar solicitações de PA e suas respectivas datas de pagamento mesmo após a inclusão da NF
			
			IF SE2->(dbSeek(xFilial('SE2')+ZFQ->ZFQ_PREFIX+ZFQ->ZFQ_NUM+ZFQ->ZFQ_PARCEL+ZFQ->ZFQ_TIPO+ZFQ->ZFQ_FORNEC+ZFQ->ZFQ_LOJA))
				cBordero	:= SE2->E2_NUMBOR
				nSaldo		:= SE2->E2_SALDO
				lSE2Fnd		:= .T.
				dDtBxE2		:= dtoc(SE2->E2_BAIXA)
			ENDIF

			IF lSE2Fnd
				cStatus	:= IIF(SE2->E2_SALDO>0, IIF(SE2->E2_SALDO == ZFQ->ZFQ_VALOR,'PENDENTE','PARCIAL'),'FINALIZADO' )
			else
				cStatus	:= 'PA NAO GERADO'
			ENDIF
			
			AADD(aBrw01Rs,{;
							ZFQ->ZFQ_FILIAL,;
							ZFQ->ZFQ_PREFIX,;
							ZFQ->ZFQ_NUM,;
							ZFQ->ZFQ_PARCEL,;
							ZFQ->ZFQ_TIPO,;
							ZFQ->ZFQ_NATURE,;
							ZFQ->ZFQ_EMISSA,;
							ZFQ->ZFQ_VENCRE,;
							ZFQ->ZFQ_MOEDA,; //Chamado n.053212 - Possibilita inclusão de PA em outras moedas - Abel Babini - 08/11/2019
							ZFQ->ZFQ_VALOR,;
							ZFQ->ZFQ_HIST,;
							cBordero,;
							nSaldo,;
							cStatus,;
							dDtBxE2; //Chamado n.057663 - Abel Babini - 27/04/2020 - OS 059175 || SUPRIMENTOS || EVANDRA || 8354 || SOLICITACAO PA - Permitir visualizar solicitações de PA e suas respectivas datas de pagamento mesmo após a inclusão da NF
						})
			SE2->(dbGoTo(_nRecSE2))
							
			ZFQ->(dbSkip())
		EndDo
	endif
	
	//Valida se Pedido de compra está liberado
	if (nItLib == 0)
		Alert('Este pedido não possui itens liberados! Aguarde a liberação para solicitar Adiantamento de Pagamento.')
		// Return
	endif

	//INICIO Ticket  n.11157  - Abel Babini  - 26/03/2021 - Ajuste saldo do pedido - solicitações de PA compensadas com NF´s atreladas ao mesmo pedido
	

	//FIM Ticket  n.11157  - Abel Babini  - 26/03/2021 - Ajuste saldo do pedido - solicitações de PA compensadas com NF´s atreladas ao mesmo pedido

	//INICIO Chamado n.057663 - Abel Babini - 27/04/2020 - OS 059175 || SUPRIMENTOS || EVANDRA || 8354 || SOLICITACAO PA - Permitir visualizar solicitações de PA e suas respectivas datas de pagamento mesmo após a inclusão da NF
	//Valida se Pedido de compra possui saldo
	//if (nItQtM == 0)
	//	Alert('Este pedido já foi entregue totalmente. Não pode receber solicitação de adiantamento.')
	//	Return
	//endif
	//FIM Chamado n.057663 - Abel Babini - 27/04/2020 - OS 059175 || SUPRIMENTOS || EVANDRA || 8354 || SOLICITACAO PA - Permitir visualizar solicitações de PA e suas respectivas datas de pagamento mesmo após a inclusão da NF

	if nValPPA >= nVlSldPC
		Alert('O saldo deste pedido já está atrelado a Solicitações de PA.')
		//Return	
	endif
	
	nVlSolPA := nVlSldPC - nValPPA
	IF nVlSolPA < 0
		nVlSolPA := 0 
	ENDIF
	 
	DEFINE MSDIALOG oDlgAtB TITLE "Solicitação de Adiantamento de Pagamento" FROM 000, 000  TO 540, 640 COLORS 0, 16777215 PIXEL style 128
	oDlgAtB:lEscClose     := .T. //Permite sair ao se pressionar a tecla ESC.
	
	@ 005,010 SAY OemToAnsi('Cod. Forn.')					SIZE 030,025 	OF oDlgAtB COLORS 0 PIXEL
	@ 014,010 MSGET OemToAnsi(SC7->C7_FORNECE)				SIZE 030,008	OF oDlgAtB PIXEL When .F. PICTURE '@!'
	
	@ 005,040 SAY OemToAnsi('Loja Forn.')					SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
	@ 014,040 MSGET OemToAnsi(SC7->C7_LOJA)					SIZE 015,008	OF oDlgAtB PIXEL When .F. PICTURE '@!'
	
	@ 005,070 SAY OemToAnsi('Fornecedor')					SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
	@ 014,070 MSGET OemToAnsi(SA2->A2_NOME)					SIZE 100,008	OF oDlgAtB PIXEL When .F. PICTURE '@!'
	
	@ 005,180 SAY OemToAnsi('Dt. Emissão')					SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
	@ 014,180 MSGET OemToAnsi(DTOC(SC7->C7_EMISSAO))		SIZE 035,008	OF oDlgAtB PIXEL When .F. PICTURE '@!'
	
	@ 005,220 SAY OemToAnsi('Dt. Preferencial')				SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
	@ 014,220 MSGET OemToAnsi(DTOC(SC7->C7_DATPRF))			SIZE 035,008	OF oDlgAtB PIXEL When .F. PICTURE '@!'

	@ 030,010 SAY OemToAnsi('Pedido')						SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
	@ 039,010 MSGET OemToAnsi(SC7->C7_NUM)					SIZE 040,008 	OF oDlgAtB PIXEL When .F. PICTURE '@!'
	
	@ 030,055 SAY OemToAnsi('C.Pagto')						SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
	@ 039,055 MSGET OemToAnsi(SC7->C7_COND)					SIZE 017,008 	OF oDlgAtB PIXEL When .F. PICTURE '@!'

	//Chamado n.053212 - Possibilita inclusão de PA em outras moedas - Abel Babini - 08/11/2019
	@ 030,080 SAY OemToAnsi('Moeda')						SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
	@ 039,080 MSGET OemToAnsi(GetMv("MV_MOEDA" + Alltrim(cValToChar(SC7->C7_MOEDA))))	SIZE 022,008 	OF oDlgAtB PIXEL When .F. PICTURE '@!'
	/*
	@ 030,105 SAY OemToAnsi('Cod. Prod')					SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
	@ 039,105 MSGET OemToAnsi(ALLTRIM(aCab[nPProdut,2]))	SIZE 050,008 	OF oDlgAtB PIXEL When .F. PICTURE '@!'
	
	@ 030,160 SAY OemToAnsi('Produto')						SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
	@ 039,160 MSGET OemToAnsi(ALLTRIM(aCab[nPDescri,2]))	SIZE 110,008 	OF oDlgAtB PIXEL When .F. PICTURE '@!'
	*/

	// Chamado n. 054139 || OS 055560 || FINANCAS || EDUARDO || 8352 || SOLICITACAO DE PA - FWNM - 18/12/2019
	@ 030,110 SAY   OemToAnsi('Natureza') SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
	@ 039,110 MSGET cNatureza             SIZE 050,008 	OF oDlgAtB PIXEL F3 "SEDPA" When .T. PICTURE '@!' VALID ( ExistCpo("SED") .and. !Empty(cNatureza) )
	//

	@ 055,010 SAY OemToAnsi('Observações Ped. Compra')		SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
	@ 064,010 MSGET OemToAnsi(SC7->C7_OBS)						SIZE 300,008 	OF oDlgAtB PIXEL When .F. PICTURE '@!'

	@ 080,010 SAY OemToAnsi('Valor do Adiantamento')	SIZE 080,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
	@ 089,010 MSGET nVlSolPA													SIZE 080,008 	OF oDlgAtB PIXEL  PICTURE '@E 999,999,999.99' //VALID POSITIVO()

	//Chamado n.053212 - Possibilita inclusão de PA com outras datas de vencimento - Abel Babini - 19/11/2019
	@ 080,100 SAY OemToAnsi('Data de Vencimento')			SIZE 080,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
	@ 089,100 MSGET dVencPA														SIZE 080,008 	OF oDlgAtB PIXEL  PICTURE '@!' VALID VerData(dVencPA)

	DEFINE SBUTTON oBtnCan 	FROM 089, 240 TYPE 02 OF oDlgAtB ENABLE Action( oDlgAtB:End() )

	DEFINE SBUTTON oBtnOK 	FROM 089, 270 TYPE 01 OF oDlgAtB ENABLE Action( IIF( ValidAT( nVlSldPC, nVlSolPA, nValPPA, cNatureza), ( nOpcX := 1, oDlgAtB:End() ), .F. ) )

	oBrw01Rs:= TcBrowse():New(110,010,310,150,,,,oDlgAtB,,,,,,,,,,,,.f.,,.t.,,.f.,,,,)
	oBrw01Rs:AddColumn( TcColumn():New( "Filial"	, {|| aBrw01Rs[oBrw01Rs:nAt,01]}	, "@!"					,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )     					
	oBrw01Rs:AddColumn( TcColumn():New( "Prefixo"	, {|| aBrw01Rs[oBrw01Rs:nAt,02]}	, "@!"					,,,"LEFT"	,025,.f.,.f.,,,,.f.,) )     					
	oBrw01Rs:AddColumn( TcColumn():New( "Titulo"	, {|| aBrw01Rs[oBrw01Rs:nAt,03]}	, "@!"					,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw01Rs:AddColumn( TcColumn():New( "Parcela"	, {|| aBrw01Rs[oBrw01Rs:nAt,04]}	, "@!"					,,,"RIGHT"	,020,.f.,.f.,,,,.f.,) )     					
	oBrw01Rs:AddColumn( TcColumn():New( "Tipo"		, {|| aBrw01Rs[oBrw01Rs:nAt,05]}	, "@!"					,,,"RIGHT"	,015,.f.,.f.,,,,.f.,) )     					
	oBrw01Rs:AddColumn( TcColumn():New( "Natureza", {|| aBrw01Rs[oBrw01Rs:nAt,06]}	, "@!"					,,,"RIGHT"	,025,.f.,.f.,,,,.f.,) )     					
	oBrw01Rs:AddColumn( TcColumn():New( "Emissão"	, {|| aBrw01Rs[oBrw01Rs:nAt,07]}	, "@!"					,,,"RIGHT"	,025,.f.,.f.,,,,.f.,) )     					
	oBrw01Rs:AddColumn( TcColumn():New( "Venc.Real"	, {|| aBrw01Rs[oBrw01Rs:nAt,08]}	, "@!"					,,,"RIGHT"	,025,.f.,.f.,,,,.f.,) )     					
	//Chamado n.053212 - Possibilita inclusão de PA em outras moedas - Abel Babini - 08/11/2019
	oBrw01Rs:AddColumn( TcColumn():New( "Moeda"		, {|| aBrw01Rs[oBrw01Rs:nAt,09]}	, "@!"	,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )     					
	oBrw01Rs:AddColumn( TcColumn():New( "Valor"		, {|| aBrw01Rs[oBrw01Rs:nAt,10]}	, "@E 999,999,999.99"	,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw01Rs:AddColumn( TcColumn():New( "Histórico"	, {|| aBrw01Rs[oBrw01Rs:nAt,11]}	, "@!"					,,,"LEFT"	,100,.f.,.f.,,,,.f.,) )     					
	oBrw01Rs:AddColumn( TcColumn():New( "Bordero"	, {|| aBrw01Rs[oBrw01Rs:nAt,12]}	, "@!"					,,,"RIGHT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw01Rs:AddColumn( TcColumn():New( "Saldo"		, {|| aBrw01Rs[oBrw01Rs:nAt,13]}	, "@E 999,999,999.99"	,,,"RIGHT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw01Rs:AddColumn( TcColumn():New( "Status"	, {|| aBrw01Rs[oBrw01Rs:nAt,14]}	, "@!"					,,,"LEFT"	,040,.f.,.f.,,,,.f.,) ) 
	//Chamado n.057663 - Abel Babini - 27/04/2020 - OS 059175 || SUPRIMENTOS || EVANDRA || 8354 || SOLICITACAO PA - Permitir visualizar solicitações de PA e suas respectivas datas de pagamento mesmo após a inclusão da NF    					
	oBrw01Rs:AddColumn( TcColumn():New( "Dt.Pagto", {|| aBrw01Rs[oBrw01Rs:nAt,15]}	, "@!"					,,,"LEFT"	,030,.f.,.f.,,,,.f.,) ) 

	oBrw01Rs:SetArray(aBrw01Rs)
	//oBrw01Rs:Align		:=	CONTROL_ALIGN_ALLCLIENT	
	oBrw01Rs:bLine := {||{ 	aBrw01Rs[oBrw01Rs:nAt]}}

	ACTIVATE MSDIALOG oDlgAtB CENTERED

	if nOpcX == 1
		//GRAVA SOLICITACAO DE PA NA TABELA ZFQ
		
		If RecLock("ZFQ",.t.)
			ZFQ->ZFQ_FILIAL	:= xFilial("ZFQ") 
			ZFQ->ZFQ_PREFIX	:= "MAN"
			ZFQ->ZFQ_NUM	:= SC7->C7_NUM
			ZFQ->ZFQ_PARCEL	:= StrZero(nMParc,3)//StrZero(nParcPA,3)
			ZFQ->ZFQ_TIPO	:= "PA"
			ZFQ->ZFQ_NATURE	:= cNatureza //POSICIONE('SA2',1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NATUREZ") // Chamado n. 054139 || OS 055560 || FINANCAS || EDUARDO || 8352 || SOLICITACAO DE PA - FWNM - 18/12/2019
			ZFQ->ZFQ_FORNEC	:= SC7->C7_FORNECE
			ZFQ->ZFQ_LOJA	:= SC7->C7_LOJA
			ZFQ->ZFQ_EMISSA	:= DATE()
			ZFQ->ZFQ_VENCTO	:= dVencPA //Chamado n.053212 - Possibilita inclusão de PA com outras datas de vencimento - Abel Babini - 19/11/2019
			ZFQ->ZFQ_VENCRE	:= dVencPA //Chamado n.053212 - Possibilita inclusão de PA com outras datas de vencimento - Abel Babini - 19/11/2019
			ZFQ->ZFQ_VALOR	:= nVlSolPA
			ZFQ->ZFQ_HIST	:= SC7->C7_OBS
			ZFQ->ZFQ_MOEDA	:= ALLTRIM(STR(SC7->C7_MOEDA)) //Chamado n.053212 - Possibilita inclusão de PA em outras moedas - Abel Babini - 08/11/2019
			ZFQ->ZFQ_RECORI	:= SC7->(RecNo())
			ZFQ->ZFQ_TABGEN	:= "SC7" 
			ZFQ->ZFQ_STSLIB	:= "1"
			ZFQ->ZFQ_OPEINT	:= "I"
			ZFQ->ZFQ_PRODUT	:= SC7->C7_PRODUTO
			ZFQ->ZFQ_TOTAL	:= nVlSolPA
			ZFQ->ZFQ_PORTAD	:= ""
			ZFQ->ZFQ_AGENCI	:= ""
			ZFQ->ZFQ_CONTA	:= ""
			ZFQ->ZFQ_ORIVEN	:= DATE()
			MsUnLock()
			MsgInfo('Registro Incluído com sucesso!')
		Endif
	endif

	RestArea(aArea)
Return

/*/{Protheus.doc} Static Function VerData
	Valida Data
	@type  Function
	@author user
	@since 19/11/2019
	@version 1
	@history Chamado n.053212 - Possibilita inclusão de PA com outras datas de vencimento - Abel Babini - 19/11/2019
	/*/
Static Function VerData()
	Local lRet := .T.
	IF dVencPA < dSrvData
		lRet := .F.
		dVencPA := dSrvData
		Alert('Não é permitido data de Vencimento menor que a data atual.')
	ENDIF
	
	dVencPA := DataValida(dVencPA, .T.)
	oDlgAtB:Refresh()
Return lRet

/*/{Protheus.doc} Static Function ValidAT
	Valida Valor
	@type  Function
	@author user
	@since 19/11/2019
	@version 1
/*/
Static Function ValidAT (nVlSldPC, nVlSolPA, nValPPA, cNatureza)
	Local lRet := .T.
	
	if nVlSolPA == 0 .or. ; //Valida valor da solicitação de PA maior que zero
		nVlSolPA > (nVlSldPC - nValPPA) //Valida valor da solicitação de PA menor ou igual ao saldo
		
		lRet := .F.	
		Alert('Não é permitido valor igual a zero ou maior que o saldo do Pedido')
	elseif nVlSolPA < 0 
		lRet := .F.	
		Alert('Não é permitido valor menor que zero')
	endif

	// Chamado n. 054139 || OS 055560 || FINANCAS || EDUARDO || 8352 || SOLICITACAO DE PA - FWNM - 18/12/2019
	If lRet
		If Empty(cNatureza)
			lRet := .f.
			Alert("[ADFIN081P-1] - Informe uma natureza financeira!")
		Else
			SED->( dbSetOrder(1) ) // ED_FILIAL + ED_CODIGO
			If SED->( dbSeek(FWxFilial("SED")+cNatureza) ) 
				If SED->ED_MSBLQL <> "1"
					If SED->ED_XSOLIPA <> "S"
						lRet := .f.
						Alert("[ADFIN081P-2] - Natureza financeira informada não está configurada para ser usada na solicitação de PA!")
					EndIf
				Else
					lRet := .f.
					Alert("[ADFIN081P-4] - Natureza financeira informada está bloqueada!")
				EndIf
			Else
				lRet := .f.
				Alert("[ADFIN081P-3] - Natureza financeira informada não está cadastrada!")
			EndIf
		EndIf

	EndIf
	//

Return lRet

