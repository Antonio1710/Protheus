#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍ ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValInf1   ºAutor  ³Vogas Junior        º Data ³  19/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida as informacoes digitadas na enchoice.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
*************Ao fazer alterações neste fonte, verificar o fonte ADVEN051P (serviço Rest para inclusão de pré-cadastro).

*/

User Function ValInf1(oEnchADO002)

	Local aArea			:= getArea()
	Local lRetorno 		:= .T.
	Local nQuant		:= 0
	Local nNivelCred  	:= Val( SuperGetMv("FS_NIVCRED", .F., 0 ) )
	Local aAreaPB3		:= PB3->( GetArea() )
	Local cCodVen       := Posicione("SA3",7,xFilial("SA3")+M->PB3_VEND,"A3_COD")     &&Mauricio - 09/06/2017 - Chamado 035643 - imperativo uso do vendedor para determinaçao das regras passadas

	U_ADINF009P('ADOA02_3' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Valida as informacoes digitadas na enchoice.')

	If INCLUI .and. empty(cCodVen) 	   //Sigoli 06/12/2016 Chamado: 031597
		cCodVen := Getmv("MV_VALVEND") //Se o usuario não estiver cadastrado como Vendedor, o cadastro assumi a carteira MV_VALVEND 
	EndIF 

	if !Empty( M->PB3_INSCR ) .and. !Ie(M->PB3_INSCR,M->PB3_EST)

		If IsInCallStack('RESTEXECUTE')
			Aadd(aRestErro,{400,'Inscrição estadual não é válida.'}) //Everson - 12/10/2017. Chamado 037261. 
		Else
			Alert( 'Inscrição estadual não é valida')

		EndIf

		lRetorno := .F.
	endif

	//Inicio - tratarmento de Inscrição Estadual SIGOLI 28/11/2016  - Chamado 029362
	If !Empty(M->PB3_INSCR) .and. Alltrim(M->PB3_PESSOA) = 'F'
 		       
        If M->PB3_TIPO  <>  'L'
		
			If IsInCallStack('RESTEXECUTE')
				Aadd(aRestErro,{400,'Cadastro de cliente pessoa Fisica, a inscrição estadual deverá ficar em branco.'}) //Everson - 12/10/2017. Chamado 037261. 
			Else
				Alert(ALLTRIM(cusername)+", Cadastro de Cliente Pessoa Fisica, a Inscrição Estadual deverá ficar em branco" )

			EndIf
        
        lRetorno := .F.
        
        EndIf
        
		
	EndIF

	If Empty(M->PB3_INSCR) .and. Alltrim(M->PB3_PESSOA) = 'J' .and. AllTrim( M->PB3_EST ) != 'EX'

		If IsInCallStack('RESTEXECUTE')
			Aadd(aRestErro,{400,'Informe a inscrição estadual.'}) //Everson - 12/10/2017. Chamado 037261. 
		Else
			Alert(ALLTRIM(cusername)+", por favor, informa a Inscrição Estadual" )

		EndIf

		lRetorno := .F.
	EndIF
	//Fim - tratarmento de Inscrição Estadual SIGOLI 28/11/2016 Chamado 029362

	// Bloqueia alteracoes qdo registro esta encaminhado Para outra pessoa
	If M->PB3_VENENC <> __cUserId .And. !Empty(M->PB3_VENENC)

		If IsInCallStack('RESTEXECUTE')
			Aadd(aRestErro,{400,'Este Cliente não pode ser alterado pois foi encaminhado para outro usuário.'}) //Everson - 12/10/2017. Chamado 037261. 
		Else
			Alert( 'Este Cliente não pode ser alterado pois foi encaminhado para outro usuário')

		EndIf

		lRetorno := .F.
	Endif

	// Registro esta em analise, somente podera ser alterado por um usuario com nivel de credito ou superior
	If M->PB3_SITUAC $ '1/4'    &&Mauricio - Chamado 035857 - 14/07/17
		DbSelectArea('PB1')
		PB1->( DbSetOrder( 1 ) )
		PB1->( DbSeek( xFilial( 'PB1' ) + __cUserId ))
		If Val( PB1->PB1_NIVEL ) < nNivelCred

			If IsInCallStack('RESTEXECUTE')
				Aadd(aRestErro,{400,'O Cadastro alterado está em andamento e somente poderá ser alterado por usuários do setor de crédito.'}) //Everson - 12/10/2017. Chamado 037261. 
			Else
				Alert( 'O Cadastro alterado está em andamento e somente poderá ser alterado por usuários do setor de crédito.' )

			EndIf

			lRetorno := .F.
		Endif
	Endif

	DbSelectArea('PB3')
	PB3->( DbSetOrder( 3 ))

	If AllTrim( M->PB3_EST ) != 'EX'
		IF Empty(M->PB3_CGC)

			If IsInCallStack('RESTEXECUTE')
				Aadd(aRestErro,{400,'Não é cliente estrangeiro, obrigado a informar o CGC/CPF.'}) //Everson - 12/10/2017. Chamado 037261. 
			Else
				Alert( 'Não é cliente estrangeiro, obrigado a informar o CGC/CPF!')

			EndIf

			lRetorno := .F.
		Endif
	Endif

	// Regras para clientes com o mesmo CPF/CNPJ
	If PB3->( DbSeek( xFilial('PB3') + M->PB3_CGC )) .and. lRetorno


		If lRetorno
			// Nao e Exportacao nem Cozinha Industrial
			If AllTrim( M->PB3_EST ) != 'EX' .And. Empty( M->PB3_REGESP ) .and. M->PB3_COD <> PB3->PB3_COD .and. M->PB3_LOJA <> PB3->PB3_LOJA

				If IsInCallStack('RESTEXECUTE')
					Aadd(aRestErro,{400,'CPF/CNPJ jà Cadastrado.'}) //Everson - 12/10/2017. Chamado 037261. 
				Else
					Alert( 'CPF/CNPJ jà Cadastrado ' )

				EndIf

				lRetorno := .F.
				// E cozinha industrial porem, o codigo do sub-segmento esta errado
			ElseIf !Empty( M->PB3_REGESP ) .And. !(AllTrim( M->PB3_SUBSEG ) $ '51$52$53') // VALIDACAO FRACA DE SUBSEGMENTO DE COZINHA INDUSTRIAL DEVERA HAVER UM CODIGO ESPECIFICO PARA COZINHA INDUSTRIAL

				If IsInCallStack('RESTEXECUTE')
					Aadd(aRestErro,{400,'Para Cadastrar uma Cozinha Industrial, deve-se utilizar o codigo de Subsegmento 51, 52 ou 53.'}) //Everson - 12/10/2017. Chamado 037261. 
				Else
					Alert( 'Para Cadastrar uma Cozinha Industrial, deve-se utilizar o codigo de Subsegmento 51, 52 ou 53 ' )

				EndIf

				lRetorno := .F.
			Endif

			// Validacao da pasta Socios
			If Empty( M->PB3_NOMSO1 ) .And. Empty( M->PB3_NOMSO2 ) .And. Empty( M->PB3_NOMSO3 ) .And. ! IsInCallStack('RESTEXECUTE')  //Everson - 12/10/2017. Chamado 037261. 

				Alert( 'É necessário informar ao menos 1 (um) sócio')

				lRetorno := .F.
			Endif

			While !PB3->( EOF()) .AND. xFilial('PB3') == PB3->PB3_FILIAL .AND. PB3->PB3_CGC == M->PB3_CGC
				nQuant += 1
				PB3->( DbSkip())
			Enddo

			If nQuant > 1
				If !Empty( M->PB3_REGESP ) .And. M->PB3_SUBSEG  $ '51$52$53' // VALIDACAO FRACA DE SUBSEGMENTO DE COZINHA INDUSTRIAL DEVERA HAVER UM CODIGO ESPECIFICO PARA COZINHA INDUSTRIAL

					If IsInCallStack('RESTEXECUTE')
						Aadd(aRestErro,{400,'Para Cadastrar uma Cozinha Industrial, deve-se utilizar o codigo de Subsegmento 51, 52 ou 53 '}) //Everson - 12/10/2017. Chamado 037261. 
					Else
						Alert( 'Para Cadastrar uma Cozinha Industrial, deve-se utilizar o codigo de Subsegmento 51, 52 ou 53 ' )

					EndIf

					lRetorno := .F.
				Endif
				if (AllTrim( M->PB3_SUBSEG ) $ '51&52&53') .and. Empty(M->PB3_CODMAT)

					If IsInCallStack('RESTEXECUTE')
						Aadd(aRestErro,{400,'Filial de Cozinha Industrial deve ter o Codigo da Matriz preenchido.'}) //Everson - 12/10/2017. Chamado 037261. 
					Else
						Alert( 'Filial de Cozinha Industrial deve ter o Codigo da Matriz preenchido' )

					EndIf

					lRetorno := .F.
				Endif
			Endif

		Endif
	Endif

	if !Empty(M->PB3_CPFENT) .and. M->PB3_CGC <> M->PB3_CPFENT .and. Empty(M->PB3_NOMEEN)

		If IsInCallStack('RESTEXECUTE')
			Aadd(aRestErro,{400,'Insira o Nome para Entrega.'}) //Everson - 12/10/2017. Chamado 037261. 
		Else
			Alert( 'Insira o Nome para Entrega.')

		EndIf

		lRetorno := .F.
	endif


	If !Alltrim( M->PB3_SUBSEG ) $ '51$52$53' // Verifica se não é cozinha industrial
		If !Empty( M->PB3_REGESP ) .And. !Alltrim( M->PB3_SUBSEG ) $ '51$52$53' // VALICACAO FRACA DE SUBSEGMENTO DE COZINHA INDUSTRIAL DEVERA HAVER UM CODIGO ESPECIFICO PBRA COZINHA INDUSTRIAL

			If IsInCallStack('RESTEXECUTE')
				Aadd(aRestErro,{400,'Para Cadastrar uma Cozinha Industrial, deve-se utilizar o codigo de Subsegmento 51, 52 ou 53.'}) //Everson - 12/10/2017. Chamado 037261. 
			Else
				Alert( 'Para Cadastrar uma Cozinha Industrial, deve-se utilizar o codigo de Subsegmento 51, 52 ou 53' )

			EndIf

			lRetorno := .F.
		Endif
	Else
		If Alltrim( M->PB3_SUBSEG ) $ '51$52$53' .And. Empty( M->PB3_REGESP )

			If IsInCallStack('RESTEXECUTE')
				Aadd(aRestErro,{400,'Para uma Cozinha Industrial, o campo Regime Especial é obrigatório.'}) //Everson - 12/10/2017. Chamado 037261. 
			Else
				Alert( 'Para uma Cozinha Industrial, o campo Regime Especial é obrigatório. ' )

			EndIf

			lRetorno := .F.
		Endif
	Endif

	// Quando Nao tiver Inscricao Estadual, PB3_GRPTRIB deve ser == 1 
	&&Mauricio - Chamado 036154 - Conforme acordado com Fernando incluido tratamento para GRP TRIB 005 e retirado o em uso(conforme Adriana).
	&&Inicio
	/*
	If Empty( M->PB3_INSCR ) .And. M->PB3_GRPTRIB != '001' .AND. M->PB3_EST <> "EX"
	//Alert( 'Insira a Inscrição Estadual, ou código de Grupo de Clientes = 001.')
	Alert( 'Para clientes sem Inscrição Estadual, por favor, informa o código de Grupo de Clientes = 001.') //sigoli 28/11/2016 Chamado 029362
	lRetorno := .F.
	Endif
	Endif
	*/
	If IsInCallStack('RESTEXECUTE') .And. M->PB3_TIPO == "F"
		M->PB3_GRPTRIB := '005'

	EndIf 

	IF M->PB3_TIPO == "F" .And. M->PB3_GRPTRIB != '005'        //Por Mauricio em 11/07/17

		If IsInCallStack('RESTEXECUTE')
			Aadd(aRestErro,{400,'Para clientes consumidor final,o Grupo de Clientes é 005.'}) //Everson - 12/10/2017. Chamado 037261. 
		Else
			Alert( 'Para clientes consumidor final,o Grupo de Clientes é 005.') 

		EndIf

		lRetorno := .F.
	Endif

	IF M->PB3_TIPO <> "F" .And. M->PB3_GRPTRIB = '005'         //Por Adriana em 11/07/17

		If IsInCallStack('RESTEXECUTE')
			Aadd(aRestErro,{400,'Grp.Clientes = 005, somente para clientes com Tipo = F-Cons.Final.'}) //Everson - 12/10/2017. Chamado 037261. 
		Else
			Alert( 'Grp.Clientes = 005, somente para clientes com Tipo = F-Cons.Final') 

		EndIf

		lRetorno := .F.
	Endif

	&&fim

	// Validacao do Telefone
	If LEN(AllTrim(M->PB3_TEL)) < 11

		If IsInCallStack('RESTEXECUTE')
			Aadd(aRestErro,{400,'Erro no cadastro do Telefone.'}) //Everson - 12/10/2017. Chamado 037261. 
		Else
			Alert( 'Erro no cadastro do Telefone' ) 

		EndIf

		lRetorno := .F.
	Endif

	// Validacao do Sub-Segmento
	If !Empty( M->PB3_SEGTO ) .AND. !Empty( M->PB3_SUBSEG )
		If Substr( M->PB3_SEGTO,1,1 ) != Substr( M->PB3_SUBSEG,1,1 )

			If IsInCallStack('RESTEXECUTE')
				Aadd(aRestErro,{400,'Erro no cadastro do Sub-Segmento.'}) //Everson - 12/10/2017. Chamado 037261. 
			Else
				Alert( 'Erro no cadastro do Sub-Segmento' ) 

			EndIf

			lRetorno := .F.
		Endif
	Endif

	DbSelectArea('PB3')
	PB3->( DbSetOrder( 1 ))
	if dbSeek(xFilial("PB3")+M->PB3_COD + M->PB3_LOJA) .and. INCLUI

		If IsInCallStack('RESTEXECUTE')
			Aadd(aRestErro,{400,'O codigo do pre-cliente ja existe no cadastro e esta tentando incluir novamente.'}) //Everson - 12/10/2017. Chamado 037261. 
		Else
			Alert( 'O codigo do pre-cliente ja existe no cadastro e esta tentando incluir novamente.' )

		EndIf

		lRetorno := .F.
	endif

	&&Mauricio - 09/06/2017 - Chamado 035643 - Novas Regras Definidas para a gravação da PB3... - Inicio
	If (Inclui .Or. Altera)
		If !Empty(cCodVen) .AND. M->PB3_EST <> 'EX' // Ricardo Lima - 16/10/18 | não valida para exportacao
			IF (Alltrim(cCodVen) $ Alltrim(GETMV("MV_#VDDTRP")))
				If M->PB3_TIPO <> "F"

					If IsInCallStack('RESTEXECUTE')
						Aadd(aRestErro,{400,'Para o vendedor '+cCodVen+' é obrigatório o tipo consumidor final!'}) //Everson - 12/10/2017. Chamado 037261. 
					Else
						Alert( 'Para o vendedor '+cCodVen+' é obrigatório o tipo consumidor final!' )

					EndIf

					lRetorno := .F.
				Endif
			Elseif (Alltrim(cCodVen) $ Alltrim(GETMV("MV_#VDDDOA")))
				If M->PB3_TIPO <> "F"

					If IsInCallStack('RESTEXECUTE')
						Aadd(aRestErro,{400,'Para o vendedor '+cCodVen+' é obrigatório o tipo consumidor final!'}) //Everson - 12/10/2017. Chamado 037261. 
					Else
						Alert( 'Para o vendedor '+cCodVen+' é obrigatório o tipo consumidor final!' )

					EndIf

					lRetorno := .F.
				Endif
			Elseif (Alltrim(cCodVen) $ Alltrim(GETMV("MV_#VDDSUC")))
				If M->PB3_TIPO <> "F"

					If IsInCallStack('RESTEXECUTE')
						Aadd(aRestErro,{400,'Para o vendedor '+cCodVen+' é obrigatório o tipo consumidor final!'}) //Everson - 12/10/2017. Chamado 037261. 
					Else
						Alert( 'Para o vendedor '+cCodVen+' é obrigatório o tipo consumidor final!' )

					EndIf

					lRetorno := .F.
				Endif
			Elseif (Alltrim(cCodVen) $ Alltrim(GETMV("MV_#VDDFIN")))
				If M->PB3_TIPO <> "F"

					If IsInCallStack('RESTEXECUTE')
						Aadd(aRestErro,{400,'Para o vendedor '+cCodVen+' é obrigatório o tipo CONSUMIDOR FINAL!'}) //Everson - 12/10/2017. Chamado 037261. 
					Else
						Alert( 'Para o vendedor '+cCodVen+' é obrigatório o tipo CONSUMIDOR FINAL!' )

					EndIf

					lRetorno := .F.
				Endif
			Endif
		Endif

		IF Alltrim(M->PB3_SEGTO) == "50" .And. Alltrim(M->PB3_SUBSEG) == "51" .and. Substr(M->PB3_INSCR,1,5) <> 'ISENT'
			If M->PB3_TIPO <> "R" 

				If IsInCallStack('RESTEXECUTE')
					Aadd(aRestErro,{400,'Para o segmento e subsegmento utilizado é obrigatório o tipo REVENDEDOR!'}) //Everson - 12/10/2017. Chamado 037261. 
				Else
					Alert( 'Para o segmento e subsegmento utilizado é obrigatório o tipo REVENDEDOR!' )

				EndIf

				lRetorno := .F.
			Endif
		EndIf

		If Alltrim(M->PB3_SEGTO) == "50" .And. (Alltrim(M->PB3_SUBSEG) $ "52/53")
			If !(M->PB3_TIPO $ "R/F")

				If IsInCallStack('RESTEXECUTE')
					Aadd(aRestErro,{400,'Para o segmento e subsegmento utilizado é obrigatório o tipo REVENDEDOR ou CONSUMIDOR FINAL!'}) //Everson - 12/10/2017. Chamado 037261. 
				Else
					Alert( 'Para o segmento e subsegmento utilizado é obrigatório o tipo REVENDEDOR ou CONSUMIDOR FINAL!' )

				EndIf

				lRetorno := .F.
			Endif
		Endif

		If Alltrim(M->PB3_PESSOA) == 'J' .and. (!Empty(M->PB3_INSCR) .AND. (Alltrim(UPPER(M->PB3_INSCR))) <> "ISENTO" )
			IF M->PB3_CONTRI <> '1'

				If IsInCallStack('RESTEXECUTE')
					Aadd(aRestErro,{400,'Pessoa Juridica com inscrição preenchida é contribuinte SIM!'}) //Everson - 12/10/2017. Chamado 037261. 
				Else
					Alert( 'Pessoa Juridica com inscrição preenchida é contribuinte SIM!' )

				EndIf

				lRetorno := .F.
			Endif
		EndIF

		If Alltrim(M->PB3_PESSOA) == 'J' .and. (Empty(M->PB3_INSCR) .OR. (Alltrim(UPPER(M->PB3_INSCR))) == "ISENTO" )
			IF M->PB3_CONTRI <> '2'

				If IsInCallStack('RESTEXECUTE')
					Aadd(aRestErro,{400,'Pessoa Juridica sem inscrição preenchida  ou isento é contribuinte NÃO!'}) //Everson - 12/10/2017. Chamado 037261. 
				Else
					Alert( 'Pessoa Juridica sem inscrição preenchida  ou isento é contribuinte NÃO!' )

				EndIf

				lRetorno := .F.
			Endif

			//IF M->PB3_TIPO <> 'F'
			//	Alert( 'Pessoa Juridica sem inscrição preenchida  ou isento é CONSUMIDOR FINAL!' )
			//	lRetorno := .F.
			//Endif
		EndIF

		If Alltrim(M->PB3_PESSOA) == 'F'
			//IF M->PB3_CONTRI <> '2' //v
			IF M->PB3_CONTRI <> '2'.and. M->PB3_TIPO <> 'L'

				If IsInCallStack('RESTEXECUTE')
					Aadd(aRestErro,{400,'PESSOA FISICA é obrigatoriamente contribuinte NÃO!'}) //Everson - 12/10/2017. Chamado 037261. 
				Else
					Alert( 'PESSOA FISICA é obrigatoriamente contribuinte NÃO!' )

				EndIf

				lRetorno := .F.
			Endif
			//IF M->PB3_TIPO <> 'F' 
			If !(M->PB3_TIPO $ "F/L") //chamado :042869 - 30/07/2018 - fernando sigoli
				
				If IsInCallStack('RESTEXECUTE')
					Aadd(aRestErro,{400,'PESSOA FISICA é obrigatoriamente CONSUMIDOR FINAL!'}) //Everson - 12/10/2017. Chamado 037261. 
				Else
				
					Alert( 'PESSOA FISICA é obrigatoriamente CONSUMIDOR FINAL!' )
				
				EndIf

				lRetorno := .F.
			Endif

		EndIF

		If M->PB3_EST == "EX"
			IF Alltrim(M->PB3_PESSOA) <> 'J'

				If IsInCallStack('RESTEXECUTE')
					Aadd(aRestErro,{400,'Para cliente ESTRANGEIRO é obrigatorio PESSOA JURIDICA!'}) //Everson - 12/10/2017. Chamado 037261. 
				Else
					Alert( 'Para cliente ESTRANGEIRO é obrigatorio PESSOA JURIDICA!' )

				EndIf

				lRetorno := .F.
			Endif
			IF M->PB3_CONTRI <> '2'

				If IsInCallStack('RESTEXECUTE')
					Aadd(aRestErro,{400,'Para cliente ESTRANGEIRO é obrigatorio CONTRIBUINTE NÃO!'}) //Everson - 12/10/2017. Chamado 037261. 
				Else
					Alert( 'Para cliente ESTRANGEIRO é obrigatorio CONTRIBUINTE NÃO!' )

				EndIf

				lRetorno := .F.
			Endif
			IF M->PB3_TIPO <> "X"

				If IsInCallStack('RESTEXECUTE')
					Aadd(aRestErro,{400,'Para cliente ESTRANGEIRO é obrigatorio tipo igual a X(exportacao)!'}) //Everson - 12/10/2017. Chamado 037261. 
				Else
					Alert( 'Para cliente ESTRANGEIRO é obrigatorio tipo igual a X(exportacao)!' )

				EndIf

				lRetorno := .F.
			Endif
			IF Empty(M->PB3_CONDPA) .Or. Empty(M->PB3_DIASPA)

				If IsInCallStack('RESTEXECUTE')
					Aadd(aRestErro,{400,'Para cliente ESTRANGEIRO é obrigatorio preencer campos Cond.Pagto e Dias pagto!'}) //Everson - 12/10/2017. Chamado 037261. 
				Else
					Alert( 'Para cliente ESTRANGEIRO é obrigatorio preencer campos Cond.Pagto e Dias pagto!' )

				EndIf

				lRetorno := .F.
			Endif
		Endif
	Endif


	&&Fim Chamado 035643

	&&Mauricio - 18/04/17 - chamado 034381
	If INCLUI .OR. ALTERA //nOpc == 3 //Inclusao

		/*IF M->PB3_CENTRA == "N" .Or. M->PB3_CENTRA == " "
			_nCont := 0
			IF M->PB3_TELSEG == "S"
				_nCont ++
			Endif
			IF M->PB3_TELTER == "S"
				_nCont ++
			Endif
			IF M->PB3_TELQUA =="S"
				_nCont ++
			Endif
			IF M->PB3_TELQUI == "S"
				_nCont ++
			Endif
			IF M->PB3_TELSEX == "S"
				_nCont ++
			Endif
			IF _nCont < 1

				If IsInCallStack('RESTEXECUTE')
					Aadd(aRestErro,{400,'Pelo menos um dia da semana de ligação é obrigatorio!'}) //Everson - 12/10/2017. Chamado 037261. 
				Else
					MsgInfo("Pelo menos um dia da semana de ligação é obrigatorio!")

				EndIf

				lRetorno := .F.			
			Endif
		Endif*/

	Endif		

	if U_Ado5Edit() .and. Empty(M->PB3_INSCEN)

		If IsInCallStack('RESTEXECUTE')
			Aadd(aRestErro,{400,'A Inscrição Estadual do Local de Entrega deve ser preenchida.'}) //Everson - 12/10/2017. Chamado 037261. 
		Else
			Alert("A Inscrição Estadual do Local de Entrega deve ser preenchida")

		EndIf

		lRetorno := .F.
	endif

	if U_Ado5Edit() .and. Empty(M->PB3_CPFENT)

		If IsInCallStack('RESTEXECUTE')
			Aadd(aRestErro,{400,'Insira o CNPJ/CPF para Entrega.'}) //Everson - 12/10/2017. Chamado 037261. 
		Else
			Alert( 'Insira o CNPJ/CPF para Entrega.')

		EndIf

		lRetorno := .F.
	Endif

	if U_Ado5Edit() .and. Empty(M->PB3_NOMEEN)

		If IsInCallStack('RESTEXECUTE')
			Aadd(aRestErro,{400,'Insira o Nome para Entrega.'}) //Everson - 12/10/2017. Chamado 037261. 
		Else
			Alert( 'Insira o Nome para Entrega.')

		EndIf

		lRetorno := .F.
	Endif

	If M->PB3_IMPEND <> "2" .and. lRetorno
		if Empty(M->PB3_CPFENT)

			If IsInCallStack('RESTEXECUTE')
				Aadd(aRestErro,{400,'Insira o CNPJ/CPF para Entrega.'}) //Everson - 12/10/2017. Chamado 037261. 
			Else
				Alert( 'Insira o CNPJ/CPF para Entrega.')

			EndIf

			lRetorno := .F.
		Endif
		if Empty(M->PB3_INSCEN)

			If IsInCallStack('RESTEXECUTE')
				Aadd(aRestErro,{400,'Insira o Inscrição estadual para Entrega.'}) //Everson - 12/10/2017. Chamado 037261. 
			Else
				Alert( 'Insira o Inscrição estadual para Entrega.')

			EndIf

			lRetorno := .F.
		Endif
		if Empty(M->PB3_NOMEEN) .and. M->PB3_IMPEND == '1' //fernando sigoli - 22/06/2017

			If IsInCallStack('RESTEXECUTE')
				Aadd(aRestErro,{400,'Insira o Nome para Entrega.'}) //Everson - 12/10/2017. Chamado 037261. 
			Else
				Alert( 'Insira o Nome para Entrega.')

			EndIf

			lRetorno := .F.
		Endif
	endif

	If Empty( M->PB3_CEP ) .and. Alltrim(M->PB3_EST) <> "EX"

		If IsInCallStack('RESTEXECUTE')
			Aadd(aRestErro,{400,'É obrigatorio o preenchimento do CEP.'}) //Everson - 12/10/2017. Chamado 037261. 
		Else
			Alert( 'É obrigatorio o preenchimento do CEP.')

		EndIf

		lRetorno := .F.
	Endif

	// Validacao do Bairro -- Incluido por Adriana em 22/04/16
	If Empty( M->PB3_BAIRRO ) .and. Alltrim(M->PB3_EST) <> "EX"

		If IsInCallStack('RESTEXECUTE')
			Aadd(aRestErro,{400,'É obrigatorio o preenchimento do BAIRRO.'}) //Everson - 12/10/2017. Chamado 037261. 
		Else
			Alert( 'É obrigatorio o preenchimento do BAIRRO')

		EndIf

		lRetorno := .F.
	Endif

	DbSelectArea('PB3')
	PB3->( DbSetOrder( 1 ))

	RestArea( aAreaPB3 )

	RestArea( aArea )
Return( lRetorno )
