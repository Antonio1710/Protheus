#include 'topconn.ch'
#include 'protheus.ch'
#include 'fwbrowse.ch'          		
#include "rwmake.ch"

// #define MB_OK                 00         		
// #define MB_OKCANCEL           01
// #define MB_YESNO              04
// #define MB_ICONHAND           16
// #define MB_ICONQUESTION       32
// #define MB_ICONEXCLAMATION    48
// #define MB_ICONASTERISK       64

/*/{Protheus.doc} User Function ADFIN101P
  Tela de visualização de Pagamentos
  @type  Function
  @author Abel Babini
  @since 01/09/2020
  @history Ticket    429 - Abel Babini - 01/09/2020 - Tela de visualização de pagamentos
	@history Ticket    429 - Abel Babini - 03/11/2020 - Ajustes na gravação da solicitação de aprovação de pagamento (Central de Aprovação) e mensagem obrigatória
	@history Ticket    429 - Abel Babini - 09/11/2020 - Ajuste na verificação do Status na Central de Aprovação
	@history Ticket    429 - Abel Babini - 10/11/2020 - Ajuste na query de seleção de registros para filtrar os registro que já tiveram arquivo gerado (E2_IDCNAB preenchido)
	@history Ticket   4883 - Abel Babini - 01/12/2020 - Geração de borderôs automática
	@history Ticket    429 - Abel Babini - 01/12/2020 - Ajuste no fonte para reposicionar o Alias SM0
	@history Ticket   6266 - Abel Babini - 08/12/2020 - Erro na gravação do registro na Central de Aprovação
	@history Ticket   4883 - Abel Babini - 08/12/2020 - Relatório Análise Modelo Pagamento
	@history Ticket 6543   - Abel Babini - 14/12/2020 - Ajuste nos campos de informações bancárias do fornecedor no título a pagar
	@history Ticket   4883 - Abel Babini - 08/01/2021 - Implementação de novas modalidades de pagamento
	@history Ticket   8061 - Abel Babini - 19/01/2021 - Desabilitar regra 01 no Painel de Pagamentos
  /*/
User Function ADFIN101P()
  Local aArea   := GetArea()
  Local nTF     := FwSizeFilial()
  Local aPergs	:= {}

  Private aRet			:= {}
	Private lRldDlg		:= .F.
	Private cVencIni	:= ''
	Private cVencFim	:= ''
	
	//Ticket   4883 - Abel Babini - 01/12/2020 - Geração de borderôs automática
	//Controla o número de execução para não entrar em loop automático
	Private nExecBor	:= 0
	Private cFilAdic	:= '%'+""+'%' //Parâmetro para filtrar Apenas títulos sem Arq CNAB gerado

	aAdd( aPergs ,{1,"Filial de         "     ,space(nTF),"" ,'.T.',,'.T.',20,.T.})
	aAdd( aPergs ,{1,"Filial até        "     ,space(nTF),"" ,'.T.',,'.T.',20,.T.})
	aAdd( aPergs ,{1,"Vencimento de     "     ,Ctod(space(8)),"" ,'.T.',,'.T.',80,.T.})
	aAdd( aPergs ,{1,"Vencimento ate    "     ,Ctod(space(8)),"" ,'.T.',,'.T.',80,.T.})
	aAdd( aPergs ,{6,"Local de Gravação",Space(50),"","","",50,.T.,"Todos os arquivos (*.*) |*.*","C:\TEMP\",GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE})
	aAdd( aPergs ,{2,"Trazer Títulos    "     ,1, {"1=Todos", "2=Sem Arq. CNAB"},090, ".T.", .T.})

	//Executa as perguntas ao usuário e só executa o relatório caso o usuário confirme a tela de parâmetros;
	If ParamBox(aPergs ,"Parâmetros ",aRet,,,,,,,,.T.,.T.)
		cVencIni := DtoC(aRet[3])
		cVencFim := DtoC(aRet[4])
		//Parâmetro para filtrar Apenas títulos sem Arq CNAB gerado
		IF aRet[6] == 2
			cFilAdic := '%'+" AND SE2.E2_IDCNAB = '' " + '%'
		ENDIF

		StaticCall(ADFIN100P,xVrfData,CtoD(cVencFim))
		// alert('teste')
    fPnPagto()
  Endif
	
	If Select("TRB") > 0
		TRB->( dbCloseArea() )
	EndIf

	If Select("cTbBord") > 0
		(cTbBord)->( dbCloseArea() )
	EndIf

	If Select("cTbTit") > 0
		(cTbTit)->( dbCloseArea() )
	EndIf

  RestArea(aArea)

	IF lRldDlg
		lRldDlg := .F.
		U_ADFIN101P()
	ENDIF
Return 

/*/{Protheus.doc} User Function fPnPagto
  Monta Tela de Pagamentos
  @type  Function
  @author Abel Babini
  @since 01/09/2020
  @history Ticket    429 - Abel Babini - 01/09/2020 - Tela de visualização de pagamentos
  /*/
Static Function fPnPagto
  
  // *** VARIÁVEIS LOCAIS ***
  //Variáveis para definição do tamanho da tela
  Local aSize   		:= 	MsAdvSize(nil,.f.,370)
  Local nAltu			  :=	aSize[4]

	//Painel Principal
	Local cEsq
	Local cDir
	Local oTela
	//Painel Esquerdo
	Local cSupE
	// Local cInfE
	Local oTelaE
	Local oPanelE
	//Painel Direito
	Local cSupD
	Local cInfD
	Local oTelaD
	Local oPanelD
/*
	//Variaveis utilizadas no MarkBrowser
  Local oNo			    :=	LoadBitmap( GetResources() , "LBNO"			)
  Local oOk	    	  := 	LoadBitmap( GetResources() , "LBOK"			)
	//Legenda do MarkBrowse
  Local oVerd    		:=	LoadBitmap( GetResources() , "ENABLE"		)
  Local oVerm    		:=	LoadBitmap( GetResources() , "DISABLE"	)
  Local oAzul    		:=	LoadBitmap( GetResources() , "BR_AZUL"	)
  Local oCinz    		:=	LoadBitmap( GetResources() , "BR_CINZA"	)
	Local oPret      	:=	LoadBitmap( GetResources() , "BR_PRETO"	)
  Local oBran    		:=	LoadBitmap( GetResources() , "BR_BRANCO")
  Local oAmar    		:=	LoadBitmap( GetResources() , "BR_AMARELO"	)
  Local oLara    		:=	LoadBitmap( GetResources() , "BR_LARANJA"	)
  Local oMarr    		:=	LoadBitmap( GetResources() , "BR_MARROM"	)
  Local oRosa    		:=	LoadBitmap( GetResources() , "BR_PINK"	)
*/
	Local _nRecSM0	:= SM0->(Recno()) //Ticket    429 - Abel Babini - 01/12/2020 - Ajuste no fonte para reposicionar o Alias SM0

	//Perfil de Usuário
	Local cPerApr			:=	GetMv("MV_#PRFAPR",,"000000,")  
	Private lAprov			:= IIF(__cUserID $ cPerApr, .T., .F.)

  //Fontes
	Private oFont001	:= TFont():New( "Arial",,14,,.f.,,,,,.f. )
	Private oFont002	:= TFont():New( "Arial",,16,,.T.,,,,,.f. )
	Private oFont003	:= TFont():New( "Arial",,18,,.T.,,,,,.f. )
	Private oProcess	

	Private cTbBord	:= GetNextAlias()
	Private oTbBord
	Private cTbTit	:= GetNextAlias()
	Private oTbTit
	Private cTbRest	:= GetNextAlias()
	Private oTbRest
	Private aTbRest	:= {}

	Private oTempTable

	Private aX3Fil	:= FWTamSX3("E2_FILIAL")
	Private aX3Bord	:= FWTamSX3("EA_NUMBOR")
	Private aX3Port	:= FWTamSX3("EA_PORTADO")
	Private aX3Agen	:= FWTamSX3("EA_AGEDEP")
	Private aX3NCon	:= FWTamSX3("EA_NUMCON")
	Private aX3DtBo	:= FWTamSX3("EA_DATABOR")
	Private aX3Modl	:= FWTamSX3("EA_MODELO")
	Private aX3TpPg	:= FWTamSX3("EA_TIPOPAG")

	Private aX3Pref	:= FWTamSX3("E2_PREFIXO")
	Private aX3NTit	:= FWTamSX3("E2_NUM")
	Private aX3Parc	:= FWTamSX3("E2_PARCELA")
	Private aX3Tipo	:= FWTamSX3("E2_TIPO")
	Private aX3Forn	:= FWTamSX3("E2_FORNECE")
	Private aX3Loja	:= FWTamSX3("E2_LOJA")
	Private aX3NomF	:= FWTamSX3("E2_NOMFOR")
	Private aX3VcRe	:= FWTamSX3("E2_VENCREA")
	Private aX3Val	:= FWTamSX3("E2_VALOR")
	Private aX3Sald	:= FWTamSX3("E2_SALDO")
	Private aX3Moed	:= FWTamSX3("E2_MOEDA")
	Private aX3CodB	:= FWTamSX3("E2_CODBAR")

	Private nTotBor	:= 0
	Private nQtdBor	:= 0
	Private nTotTit	:= 0
	Private nQtdTit	:= 0

	Private oGrd10
	Private oGrd20
	Private lMkBord := .F.
	Private lMkTit	:= .F.

	Private oDlgxPg		:= nil

	//INICIO Ticket   4883 - Abel Babini - 01/12/2020 - Geração de borderôs automática
	Private xConteudo
	Private cPadrao 	:= ""
	Private cBanco   	:= CriaVar("E1_PORTADO")
	Private cAgencia 	:= CriaVar("E1_AGEDEP")
	Private cConta 		:= CriaVar("E1_CONTA")
	Private cCtBaixa 	:= GetMv("MV_CTBAIXA")
	Private cAgen240 	:= CriaVar("A6_AGENCIA")
	Private cConta240	:= CriaVar("A6_NUMCON")
	Private cModPgto  := CriaVar("EA_MODELO")
	Private cTipoPag 	:= CriaVar("EA_TIPOPAG")
	Private cMarca   	:= GetMark( )
	Private cCadastro   
	Private aGetMark 	:= {}
	Private c240FilBT	:= space(60)
	//FIM Ticket   4883 - Abel Babini - 01/12/2020 - Geração de borderôs automática

	Private aEmpresas	:= {} //Ticket    429 - Abel Babini - 01/12/2020 - Ajuste no fonte para reposicionar o Alias SM0
	Private cStartPath := GetSrvProfString("Startpath","")

	Private dDtBordI	:= StaticCall(ADFIN100P,xVrfData,msdate())
	Private dDtBordF	:= StaticCall(ADFIN100P,xVrfData,msdate()+1)

	//Cria Array de Títulos
	aBord := {}
	aTit	:= {}

	//INICIO Ticket    429 - Abel Babini - 01/12/2020 - Ajuste no fonte para validar multiempresas
	// Carrego empresas do grupo para utilizar nas regras 02 e 03
	SM0->( dbSetOrder(1) )
	SM0->( dbGoTop() )
	Do While SM0->( !EOF() )

 		If AllTrim(SM0->M0_CODIGO) <> cEmpAnt //Ticket   8093 - Abel Babini - 15/01/2021 - Erro na verificação de títulos em outras unidades

			nPos := aScan(aEmpresas, {|x| AllTrim(x) == AllTrim(SM0->M0_CODIGO)})
			If nPos <= 0
				aAdd( aEmpresas, { SM0->M0_CODIGO } )
			EndIf
		
		EndIf

		SM0->( dbSkip() )
	
	EndDo
	SM0->(DBGoTo(_nRecSM0))
	//FIM Ticket    429 - Abel Babini - 01/12/2020 - Ajuste no fonte para validar multiempresas

	//Carrega Dados
	//FWMsgRun(, {|| LoadBord() }, "Processando", "Carregando Dados, Aguarde...")
	MsgRun( "Processando", "Carregando Dados, Aguarde...", { || LoadBord() } )

	oDlgxPg := MSDialog():New (aSize[7],0, aSize[6],aSize[5], "Painel de Pagamentos" ,,, .F.,,,,,, .T.,,, .T. )
  // DEFINE MSDIALOG oDlgxPg TITLE "Painel de Pagamentos" OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5]

    oDlgxPg:lEscClose 	:= 	.f.
    oDlgxPg:lMaximized := 	.t. 
    
		oTela 	:= 	FwFormContainer():New( oDlgxPg )
		cEsq		:= 	oTela:CreateVerticalBox( 16 )
		cDir  	:= 	oTela:CreateVerticalBox( 84 )
		oTela:Activate( oDlgxPg , .f. )

		oPanelE		:= 	oTela:GetPanel( cEsq )
		oTelaE		:= 	FwFormContainer():New( oPanelE )
		cSupE    	:= 	oTelaE:CreateHorilontalBox( 70 )
		// cInfE     	:= 	oTelaE:CreateHorilontalBox( 30 )
		oTelaE:Activate( oPanelE , .f. )

		oFWLSt01	:=	FwLayer():New()
		oFWLSt01:Init(oPanelE,.t.)   
		oFWLSt01:AddCollumn('ColES',100,.f.)
		oFWLSt01:AddWindow('ColES','Win01',"Status",96,.f.,.t.,/*{ || }*/,,/*{ || }*/) 
		oPnSt01	:= 	oFWLSt01:GetWinPanel('ColES','Win01')
		oPnSt01:FreeChildren()

		//Painel Status
		@ 000,000 TO 010,096 OF oPnSt01 PIXEL
		@ 001,001 SAY OemToAnsi("Usuário: ")	FONT oFont002 SIZE 100,15 OF oPnSt01 PIXEL
		@ 002,032 SAY OemToAnsi(__cUserID + " - " + cUsername)	FONT oFont001 SIZE 100,15 OF oPnSt01 PIXEL

		// @ 010,001 SAY OemToAnsi("Perfil: ")	FONT oFont002 SIZE 200,15 OF oPnSt01 PIXEL
		// @ 011,032 SAY OemToAnsi(IIF(lAprov,"Aprovador","Usuário"))	FONT oFont001 SIZE 100,15 OF oPnSt01 PIXEL

		@ 024,000 TO 065,096 OF oPnSt01 PIXEL
		@ 054,000 TO 065,096 OF oPnSt01 PIXEL
		
		@ 025,001 SAY OemToAnsi("Totais")					FONT oFont002 SIZE 200,15 OF oPnSt01 PIXEL
		@ 025,056 SAY OemToAnsi("Valor")					FONT oFont002 SIZE 200,15 OF oPnSt01 PIXEL
		@ 025,077 SAY OemToAnsi("Qtd")						FONT oFont002 SIZE 200,15 OF oPnSt01 PIXEL

		@ 035,002 SAY OemToAnsi("Borderôs:") 			FONT oFont001 SIZE 100,15 OF oPnSt01 PIXEL
		@ 045,002 SAY OemToAnsi("Sem Bord.: ")	  FONT oFont001 SIZE 100,15 OF oPnSt01 PIXEL
		@ 055,002 SAY OemToAnsi("Total: ")				FONT oFont001 SIZE 100,15 OF oPnSt01 PIXEL

		@ 035,041 SAY OemToAnsi(TRANSFORM(nTotBor, "@E 999,999,999.99")) 	FONT oFont001 SIZE 100,15 OF oPnSt01 PIXEL
		@ 035,077 SAY OemToAnsi(TRANSFORM(nQtdBor, "@E 999,999"))					FONT oFont001 SIZE 100,15 OF oPnSt01 PIXEL
		@ 045,041 SAY OemToAnsi(TRANSFORM(nTotTit-nTotBor, "@E 999,999,999.99"))	FONT oFont001 SIZE 100,15 OF oPnSt01 PIXEL
		@ 045,077 SAY OemToAnsi(TRANSFORM(nQtdTit-nQtdBor, "@E 999,999"))	FONT oFont001 SIZE 100,15 OF oPnSt01 PIXEL
		@ 055,041 SAY OemToAnsi(TRANSFORM(nTotTit, "@E 999,999,999.99"))	FONT oFont001 SIZE 100,15 OF oPnSt01 PIXEL
		@ 055,077 SAY OemToAnsi(TRANSFORM(nQtdTit, "@E 999,999"))	FONT oFont001 SIZE 100,15 OF oPnSt01 PIXEL

		@ 069,000 TO 110,096 OF oPnSt01 PIXEL
		@ 070,001 SAY OemToAnsi("Parâmetros")		FONT oFont002 SIZE 200,15 OF oPnSt01 PIXEL
		@ 080,005 SAY OemToAnsi("Filial")				FONT oFont001 SIZE 200,15 OF oPnSt01 PIXEL
		@ 090,005 SAY OemToAnsi("Vencimento")		FONT oFont001 SIZE 200,15 OF oPnSt01 PIXEL
		@ 100,005 SAY OemToAnsi("Bord. Aut.")			FONT oFont001 SIZE 200,15 OF oPnSt01 PIXEL

		@ 080,041 SAY OemToAnsi(aRet[1] + " - " + aRet[2])		FONT oFont001 SIZE 200,15 OF oPnSt01 PIXEL
		@ 090,041 SAY OemToAnsi(cVencIni + " - " + cVencFim)	FONT oFont001 SIZE 200,15 OF oPnSt01 PIXEL
		@ 100,041 SAY OemToAnsi(DtoC(dDtBordI) + " - " + DtoC(dDtBordF))	FONT oFont001 SIZE 200,15 OF oPnSt01 PIXEL

    Menu xMnOpc PopUp
			MenuItem "Recarrega página" 										Action Eval ( { || xRldFnc() } )
    EndMenu

    oTButton1	:=	tButton():New(nAltu - 040, 005 ,"Sair"		  					,oPnSt01,{ || oDlgxPg:End() },088,015,,,.f.,.t.,.f.,,.f.,,,.f.)  

    //oTButton8	:=	tButton():New(nAltu - 145, 005 ,"Aprovar"							,oPnSt01,{ || Alert("Função Não Disponível") 	  }					 ,080,015,,,.f.,.t.,.f.,,.f.,{|| lAprov },,.f.)
    oTButton7	:=	tButton():New(nAltu - 130, 005 ,"Solicitar Aprovação"		,oPnSt01,{ || xSolApr() 	},088,015,,,.f.,.t.,.f.,,.f.,{|| !lAprov },,.f.)
    oTButton6	:=	tButton():New(nAltu - 115, 005 ,"Borderô Manual"	  		,oPnSt01,{ || BordPgt()		},088,015,,,.f.,.t.,.f.,,.f.,,,.f.)
    oTButton4	:=	tButton():New(nAltu - 100, 005 ,"Borderô Automático"		,oPnSt01,{ || MsgRun( "Processando", "Criando Borderôs automaticamente, Aguarde...", { || xAutBor() } )   },088,015,,,.f.,.t.,.f.,,.f.,{||.t.}/*{|| lAprov }*/,,.f.)
    oTButton5	:=	tButton():New(nAltu - 085, 005 ,"Gerar CNAB"						,oPnSt01,{ || .T.  				},088,015,,,.f.,.t.,.f.,,.f.,,,.f.)
    oTButton3	:=	tButton():New(nAltu - 070, 005 ,"Relatórios"						,oPnSt01,{ || .T. 				},088,015,,,.f.,.t.,.f.,,.f.,,,.f.)
    oTButton2	:=	tButton():New(nAltu - 055, 005 ,"Opcoes"								,oPnSt01,{ || .t.         },088,015,,,.f.,.t.,.f.,,.f.,,,.f.)

    Menu xMnRel PopUp
      MenuItem "Rel. Analise Modelo Pgto."  		Action Eval( { || U_xRelTpPg() 	} )
      // MenuItem "Rel. Títulos"				Action Eval( { || Alert("Função Não Disponível") 	} )
      // MenuItem "Rel. Completo"   		Action Eval( { || Alert("Função Não Disponível") 	} )
    EndMenu
		 oTButton3:SetPopUpMenu(xMnRel)

    oTButton2:SetPopUpMenu(xMnOpc)

   	Menu xMnArq PopUp
      MenuItem "Arq. Pagamentos"  	Action Eval( { || FINA420()	} )
      MenuItem "Sispag"							Action Eval( { || FINA300() } )
    EndMenu
		oTButton5:SetPopUpMenu(xMnArq)


		oPanelD		:= 	oTela:GetPanel( cDir )
		oTelaD 		:= 	FwFormContainer():New( oPanelD )
		cSupD     	:= 	oTelaD:CreateHorilontalBox( 40 )
		cInfD     	:= 	oTelaD:CreateHorilontalBox( 60 )
		oTelaD:Activate( oPanelD , .f. )

		oPnSD  	:= 	oTelaD:GetPanel( cSupD )
		oFWLBr01	:=	FwLayer():New()
		oFWLBr01:Init(oPnSD,.t.)   
		oFWLBr01:AddCollumn('ColDB',100,.f.)
		oFWLBr01:AddWindow('ColDB','Win03',"Borderôs de Pagamento",100,.f.,.t.,/*{ || }*/,,/*{ || }*/) 
		oPnBr01	:= 	oFWLBr01:GetWinPanel('ColDB','Win03')
		oPnBr01:FreeChildren()	   

		oPnID  		:= 	oTelaD:GetPanel( cInfD )
		oFWLTt01	:=	FwLayer():New()
		oFWLTt01:Init(oPnID,.t.)   
		oFWLTt01:AddCollumn('ColDT',100,.f.)
		oFWLTt01:AddWindow('ColDT','Win04',"Títulos em Borderô",93,.f.,.t.,/*{ || }*/,,/*{ || }*/) 
		oPnTt01		:= 	oFWLTt01:GetWinPanel('ColDT','Win04')
		oPnTt01:FreeChildren()	   
	
		//Borderôs
		GrdBord()
	
		//Títulos
		GrdTit()

  Activate MsDialog oDlgxPg Centered 

Return

/*/{Protheus.doc} Static Function xSolApr()
  Função executada ao clicar no botão de Solicita Aprovação
  @type  Static Function
  @author Abel Babini
  @since 09/10/2020
  /*/
Static Function xSolApr()
	Local cMarca	:= oGrd20:Mark()
	Local cTpDivf	:= '000020'
	Local cMsgSol := Space(250)
	Local oDlgAtB
	Local nOpcX := 0

	DbSelectArea("SX5")
	DbSetOrder(1)
	DbSeek( FwxFilial("SX5") + 'Z9' + cTpDivf )

	DEFINE MSDIALOG oDlgAtB TITLE "Solicitação de Aprovação para Pagamento" FROM 000, 000  TO 140, 630 COLORS 0, 16777215 PIXEL style 128
	oDlgAtB:lEscClose     := .F. //Permite sair ao se pressionar a tecla ESC.
	@ 005,010 SAY OemToAnsi('Observações para Aprovador')		SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
	@ 014,010 MSGET cMsgSol																	SIZE 300,008 	OF oDlgAtB PIXEL PICTURE '@!'

	@ 025,010 SAY OemToAnsi('ATENÇÃO: Todos os títulos selecionados serão enviados para aprovação com essa observação!')		SIZE 300,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
	
	@ 038,240 SAY OemToAnsi('Deseja continuar?')		FONT oFont002 SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL 

	DEFINE SBUTTON oBtnCan 	FROM 049, 240 TYPE 02 OF oDlgAtB ENABLE Action( oDlgAtB:End() )
	
	//Ticket    429 - Abel Babini - 03/11/2020 - Ajustes na gravação da solicitação de aprovação de pagamento (Central de Aprovação) e mensagem obrigatória
	DEFINE SBUTTON oBtnOK 	FROM 049, 270 TYPE 01 OF oDlgAtB ENABLE Action( nOpcX := 1, IIF(Alltrim(cMsgSol)=='',Alert('A mensagem para o aprovador é obrigatória.'),oDlgAtB:End()) )

	ACTIVATE MSDIALOG oDlgAtB CENTERED

	IF nOpcX == 1
		IF msgYesNo("Deseja enviar os títulos selecionados para aprovação?")
			(cTbTit)->(dbGoTop())
			While !(cTbTit)->(eof())

				IF oGrd20:IsMark(cMarca) .AND. (cTbTit)->REGRA == '01'
					RECLOCK(cTbTit,.F.)
						(cTbTit)->REGRA 	:= '02'
						(cTbTit)->OMARK		:= ''
					MSUNLOCK()	

					DbSelectArea("SE2")
					DbSetOrder(1)
					IF MSSeek( (cTbTit)->FILIAL + (cTbTit)->PREFIXO + (cTbTit)->TITULO + (cTbTit)->PARCELA + (cTbTit)->TIPO + (cTbTit)->CODFORN + (cTbTit)->LOJA )
						xGeraLog()

						RecLock("SE2",.F.)
							SE2->E2_XDIVERG := 'S'
						MsUnlock()

						RecLock("ZC7",.T.)
							ZC7->ZC7_FILIAL := SE2->E2_FILIAL //Ticket   6266 - Abel Babini - 08/12/2020 - Erro na gravação do registro na Central de Aprovação
							ZC7->ZC7_PREFIX	:= SE2->E2_PREFIXO
							ZC7->ZC7_NUM   	:= SE2->E2_NUM
							ZC7->ZC7_PARCEL	:= SE2->E2_PARCELA
							ZC7->ZC7_TIPO   := SE2->E2_TIPO
							ZC7->ZC7_CLIFOR	:= SE2->E2_FORNECE
							ZC7->ZC7_LOJA  	:= SE2->E2_LOJA
							ZC7->ZC7_VLRBLQ	:= SE2->E2_VALOR
							ZC7->ZC7_TPBLQ 	:= cTpDivf
							ZC7->ZC7_DSCBLQ	:= Alltrim(SX5->X5_DESCRI) +' - '+ RetBlqs((cTbTit)->CODBLOQ) ////INICIO Ticket    429 - Abel Babini - 03/11/2020 - Ajustes na gravação da solicitação de aprovação de pagamento (Central de Aprovação) e mensagem obrigatória
							ZC7->ZC7_RECPAG := "P"
							ZC7->ZC7_OBS		:= ''
							ZC7->ZC7_USRALT := __cUserID
							ZC7->ZC7_MSGSOL := cMsgSol
						MSUnlock()	
					ENDIF

				ENDIF
				
				(cTbTit)->(dbSkip())
			EndDo
			oGrd20:Refresh(.T.)
		Endif
	ENDIF
Return

/*/{Protheus.doc} Static Function BordPgt()
  Função executada ao clicar no botão de borderôs de pagamento
  @type  Static Function
  @author Abel Babini
  @since 06/10/2020
  /*/
Static Function BordPgt()
	FINA241(2)
	// If msgYesNo("Deseja recarregar a página?")
		// lRldDlg := .T.
		// oTButton1:click()
		// xRldFnc()
	// Endif

Return

/*/{Protheus.doc} Static Function BordPgt()
  Função executada ao clicar no botão de borderôs de pagamento
  @type  Static Function
  @author Abel Babini
  @since 06/10/2020
  /*/
	Static Function xRldFnc()
		lRldDlg := .T.
		oTButton1:click()
	Return

/*/{Protheus.doc} Static Function LoadBord()
  Função para carregar registros para os Browsers
  @type  Static Function
  @author Abel Babini
  @since 14/09/2020
  /*/
Static Function LoadBord()
	Local cQuery1	:=  GetNextAlias()
	Local cBorMin	:= ''
	Local cBorMax	:= ''
	

	//Identifica Borderô Inicial e Final para as Datas informadas
	BeginSql Alias cQuery1
		SELECT 
			MIN(E2_NUMBOR) AS MIN, 
			MAX(E2_NUMBOR) AS MAX 
		FROM %TABLE:SE2% AS SE2 (NOLOCK)
		WHERE 
			SE2.E2_FILIAL BETWEEN %Exp:aRet[1]% AND %Exp:aRet[2]%
		AND SE2.E2_VENCREA BETWEEN %Exp:aRet[3]% AND %Exp:aRet[4]%
		AND SE2.E2_NUMBOR <> ''
		AND SE2.%notDel%
	EndSql
	IF !(cQuery1)->(eof())
		cBorMin	:= (cQuery1)->MIN
		cBorMax	:= (cQuery1)->MAX
	ENDIF
	(cQuery1)->(dbCloseArea())
	IF Alltrim(cBorMin) == '' .and. Alltrim(cBorMax)!=''
		cBorMin := cBorMax
	ENDIF
		IF Alltrim(cBorMax) == '' .and. Alltrim(cBorMin)!=''
		cBorMax := cBorMin
	ENDIF
	//Cria Estrutura de Tabelas Temporárias para Armazenar Informações
	_aFields	:= CriaExtr("BORDERO")
	_aIndex		:= CriaInd("BORDERO")
	oTbBord		:= CriaTmpT(cTbBord, _aFields, _aIndex)

	_aFields	:= CriaExtr("TITULOS")
	_aIndex		:= CriaInd("TITULOS")
	oTbTit		:= CriaTmpT(cTbTit, _aFields, _aIndex)

	_aFields	:= CriaExtr("RESTRICAO")
	_aIndex		:= CriaInd("RESTRICAO")
	oTbRest		:= CriaTmpT(cTbRest, _aFields, _aIndex)

	// Processa( { || CursorWait() , fCarga(cTbBord,cTbTit) , CursorArrow() } , "Buscando Títulos com Saldo para o Período...")
	// oProcess := MsNewProcess():New({|lEnd| CursorWait() , fCarga(cTbBord,cTbTit, @oProcess, @lEnd) , CursorArrow() },"Buscando Títulos com Saldo para o Período...","Selecionando títulos à pagar",.T.) 
	oProcess := MsNewProcess():New({|| fCarga(cTbBord,cTbTit)  },"Buscando Títulos com Saldo para o Período...","Selecionando títulos à pagar",.T.) 
	oProcess:Activate()
Return

/*/{Protheus.doc} Static Function GrvRestr
  Grava registro na tabela temporária de Restrições dos títulos
  @type  Static Function
  @author Abel Babini
  @since 14/09/2020
  /*/
Static Function GrvRestr()
	Local lRet := .F.
	If Select("TRB") > 0
		
		TRB->(dbGoTop())
		While !TRB->(eof())
			IF !lRet 
				IF (cTbRest)->REGRA != '  ' .AND. Substr(TRB->ZC7_STATUS,1,2) != "02"
					lRet := .T.
				ENDIF
			ENDIF
			RecLock(cTbRest, .T.)
				//Título possui restrição: Carrega Status de aprovação
				//00- Aprovação de pagamento não solicitada
				//01- Aprovação de pagamento solicitada
				//02- Aprovação de pagamento realizada
				//03- Solicitação rejeitada
				(cTbRest)->REGRA		:= Alltrim(SUBSTR(TRB->REGRA,1,2))
				(cTbRest)->DSCREGRA	:= Alltrim(SUBSTR(TRB->REGRA,6,250))

				//Título que está no borderô
				(cTbRest)->FILIAL		:= TRB->E2_FILIAL
				(cTbRest)->PREFIXO	:= TRB->E2_PREFIXO
				(cTbRest)->TITULO		:= TRB->E2_NUM
				(cTbRest)->PARCELA	:= TRB->E2_PARCELA
				(cTbRest)->TIPO			:= TRB->E2_TIPO
				(cTbRest)->CODFORN	:= TRB->E2_FORNECE
				(cTbRest)->LOJA			:= TRB->E2_LOJA
				(cTbRest)->FORNECE	:= TRB->E2_NOMFOR
				(cTbRest)->VENCREA	:= TRB->E2_VENCREA
				(cTbRest)->VALOR		:= TRB->E2_VALOR
				(cTbRest)->SALDO		:= TRB->E2_SALDO
				(cTbRest)->BORDERO	:= TRB->EA_NUMBOR

				//Título que não está no borderô mas que gerou a restrição
				(cTbRest)->RECPAG 	:= TRB->RECPAG  
				(cTbRest)->BLQFIL 	:= TRB->FILIAL  
				(cTbRest)->BLQPRE		:= TRB->PREFIXO 
				(cTbRest)->BLQTIT 	:= TRB->NUM     
				(cTbRest)->BLQPAR 	:= TRB->PARCELA 
				(cTbRest)->BLQTIP 	:= TRB->TIPO    
				(cTbRest)->BLQCLFR 	:= TRB->CLIFOR  
				(cTbRest)->BLQLOJ 	:= TRB->LOJA    
				(cTbRest)->BLQNOM 	:= TRB->FANTASIA
				(cTbRest)->BLQVAL 	:= TRB->VALOR   
				(cTbRest)->BLQSAL 	:= TRB->SALDO   
				(cTbRest)->BLQMOE 	:= TRB->MOEDA   
				(cTbRest)->BLQCBR		:= TRB->CODBAR  
				(cTbRest)->LIVRE		:= TRB->LIVRE   

			(cTbRest)->( msUnLock() )

			TRB->(dbSkip())
		EndDo
		TRB->( dbCloseArea() )
	ENDIF

Return lRet

/*/{Protheus.doc} Static Function fCarga
  Carrega Títulos sem borderô
  @type  Static Function
  @author Abel Babini
  @since 14/09/2020
  /*/
Static Function fCarga(cTbBord,cTbTit)
  Local nSaldo
  // Local cQuery	
  Local nCount	:=	0
  Local nRegCnt	:=	0
	// Local lRegra01	:= .F.
	// Local lRegra02	:= .F.
	// Local lRegra03	:= .F.
	// Local lRegra04	:= .F.
	// Local lRegra05	:= .F.
	// Local lRegra06	:= .F.
	// Local lRegra07	:= .F.
	// Local lRegra08	:= .F.
	// Local lRegra09	:= .F.
	Local lDiverg		:= .F.
	
	Private cAlias := GetNextAlias()

	////Ticket 6543   - Abel Babini - 13/12/2020 - Ajuste nos campos de informações bancárias do fornecedor no título a pagar
  BEGINSQL ALIAS cAlias
    COLUMN E2_VENCREA AS DATE
		COLUMN EA_DATABOR AS DATE
    SELECT 
      SE2.E2_FILIAL,
      SE2.E2_PREFIXO,
      SE2.E2_NUM,
      SE2.E2_PARCELA,
      SE2.E2_TIPO,
      SE2.E2_FORNECE,
      SE2.E2_LOJA,
      SE2.E2_NOMFOR,
      SE2.E2_VENCREA,
      SE2.E2_SALDO,
      SE2.E2_CODBAR,
      SE2.E2_NUMBOR,
      SE2.E2_IDCNAB,
      SE2.E2_XDIVERG,
			SE2.E2_RJ,
      SE2.E2_SDACRES,
      SE2.E2_SDDECRE,
      SE2.E2_MOEDA,
      SE2.E2_VALOR,
			SEA.EA_PORTADO,
			SEA.EA_AGEDEP,
			SEA.EA_NUMCON,
			SEA.EA_MODELO,
			SEA.EA_TIPOPAG,
			SEA.EA_DATABOR,
			SE2.E2_FORMPAG,
			CASE WHEN A2_CGC = '' THEN SUBSTRING(E2_CGC,1,8) ELSE SUBSTRING(A2_CGC,1,8) END AS A2_CGC,
			SE2.E2_ORIGEM, 
			SE2.E2_BANCO, 
			SE2.E2_AGEN,
			SE2.E2_NOCTA, 
			SA2.A2_BANCO, 
			SA2.A2_AGENCIA, 
			SA2.A2_NUMCON, 
			SE2.E2_FATURA, 
			SE2.E2_FATPREF, 
			SE2.E2_XRECORI
    FROM %TABLE:SE2% SE2 (NOLOCK)
		LEFT JOIN %TABLE:SEA% SEA (NOLOCK) ON
			SEA.EA_FILIAL = SE2.E2_FILIAL
		AND SEA.EA_NUMBOR = SE2.E2_NUMBOR
		AND SEA.EA_PREFIXO = SE2.E2_PREFIXO
		AND SEA.EA_NUM = SE2.E2_NUM
		AND SEA.EA_PARCELA = SE2.E2_PARCELA
		AND SEA.EA_TIPO = SE2.E2_TIPO
		AND SEA.EA_FORNECE = SE2.E2_FORNECE
		AND SEA.EA_LOJA = SE2.E2_LOJA
		AND SEA.%notDel%
		LEFT JOIN %TABLE:SA2% SA2 (NOLOCK) ON 
			SA2.A2_FILIAL = %xFilial:SA2% 
		AND SA2.A2_COD = SE2.E2_FORNECE 
		AND SA2.A2_LOJA = SE2.E2_LOJA 
		AND SA2.%notDel%
    WHERE SE2.%notDel%
      AND SE2.E2_FILIAL  BETWEEN %Exp:aRet[1]% AND %Exp:aRet[2]%
      AND SE2.E2_VENCREA BETWEEN %Exp:aRet[3]% AND %Exp:aRet[4]%
      AND SE2.E2_SALDO > 0 %Exp:cFilAdic%
  ENDSQL
	//Ticket    429 - Abel Babini - 10/11/2020 - Ajuste na query de seleção de registros para filtrar os registro que já tiveram arquivo gerado (E2_IDCNAB preenchido)

  Count to nCount

  (cAlias)->(dbgotop())

	oProcess:SetRegua1(nCount)
	nTotBor	:= 0
	nQtdBor	:= 0
	nTotTit	:= 0
	nQtdTit	:= 0
	
  WHILE (cAlias)->(!Eof())
		oProcess:IncRegua1("Registro " + StrZero( ++ nRegCnt,06) + " de " + StrZero(nCount,06))             	
		oProcess:SetRegua2(7)	

		nSaldo 	:= Round(NoRound(xMoeda((cAlias)->E2_SALDO + (cAlias)->E2_SDACRES - (cAlias)->E2_SDDECRE,(cAlias)->E2_MOEDA,1,dDataBase),3),2)

		StaticCall(ADFIN100P,CriaTRB)
		aRetRegr	:= {.t., .t., .t., .t., .t., .t., .t., .t., .t.}
		
		//Ticket 6543   - Abel Babini - 13/12/2020 - Ajuste nos campos de informações bancárias do fornecedor no título a pagar
		aRetRegr	:= StaticCall(ADFIN100P,ChkRegras, ;
								(cAlias)->E2_NUMBOR, ;
								(cAlias)->E2_FILIAL, ;
								(cAlias)->E2_PREFIXO, ;
								(cAlias)->E2_NUM, ;
								(cAlias)->E2_PARCELA, ;
								(cAlias)->E2_TIPO, ;
								(cAlias)->E2_FORNECE, ;
								(cAlias)->E2_LOJA, ;
								(cAlias)->E2_VENCREA, ;
								nSaldo, ;
								(cAlias)->EA_PORTADO, ;
								(cAlias)->EA_AGEDEP, ;
								(cAlias)->EA_NUMCON, ;
								(cAlias)->E2_NOMFOR, ;
								(cAlias)->E2_VALOR, ;
								(cAlias)->E2_MOEDA, ;
								(cAlias)->E2_CODBAR, ;
								Alltrim((cAlias)->A2_CGC), ;
								(cAlias)->E2_ORIGEM, ;
								(cAlias)->E2_BANCO, ;
								(cAlias)->E2_AGEN, ;
								(cAlias)->E2_NOCTA, ;
								(cAlias)->A2_BANCO, ;
								(cAlias)->A2_AGENCIA, ;
								(cAlias)->A2_NUMCON, ;
								(cAlias)->E2_FATURA, ;
								(cAlias)->E2_FATPREF, ;
								(cAlias)->E2_XRECORI, ;
								(cAlias)->EA_MODELO )
								
		GrvRestr()
		//@history Ticket    429 - Abel Babini - 09/11/2020 - Ajuste na verificação do Status na Central de Aprovação
		lDiverg	:= IIF((cAlias)->E2_XDIVERG == 'S' .AND. (cAlias)->E2_RJ != 'X' ,.T.,.F.)

		cRegrBor:= RegraBor(!aRetRegr[1],!aRetRegr[2],!aRetRegr[3],!aRetRegr[4],!aRetRegr[5],!aRetRegr[6],!aRetRegr[7],!aRetRegr[8],!aRetRegr[9],lDiverg)
		aRegrTit:= RegraTit(!aRetRegr[1],!aRetRegr[2],!aRetRegr[3],!aRetRegr[4],!aRetRegr[5],!aRetRegr[6],!aRetRegr[7],!aRetRegr[8],!aRetRegr[9],lDiverg)
		// '01',{'FILIAL','BORDERO','BANCO','AGENCIA','CONTA'}
		// '02',{'REGRA','FILIAL','BORDERO','BANCO','AGENCIA','CONTA'}
		// '03',{'FILIAL','DATABOR','BORDERO','BANCO','AGENCIA','CONTA'}
		// '04',{'FILIAL','DATABOR','MODELO','TIPOPAG','BORDERO','BANCO','AGENCIA','CONTA'}
		(cTbBord)->(dbSetOrder(1))
		IF !(cTbBord)->(MsSeek((cAlias)->E2_FILIAL+(cAlias)->E2_NUMBOR+(cAlias)->EA_PORTADO+(cAlias)->EA_AGEDEP+(cAlias)->EA_NUMCON))
			RecLock(cTbBord, .T.)
				(cTbBord)->FILIAL			:= (cAlias)->E2_FILIAL
				(cTbBord)->BORDERO		:= (cAlias)->E2_NUMBOR
				(cTbBord)->DATABOR		:= (cAlias)->EA_DATABOR
				(cTbBord)->MODELO			:= (cAlias)->EA_MODELO
				(cTbBord)->TIPOPAG		:= (cAlias)->EA_TIPOPAG
				(cTbBord)->BANCO			:= (cAlias)->EA_PORTADO
				(cTbBord)->AGENCIA		:= (cAlias)->EA_AGEDEP
				(cTbBord)->CONTA			:= (cAlias)->EA_NUMCON
				(cTbBord)->VALOR			:= nSaldo
				(cTbBord)->QTDTIT			:= 1			
				(cTbBord)->REGRA			:= cRegrBor
			(cTbBord)->( msUnLock() )
		ELSE
			RecLock(cTbBord, .F.)
				(cTbBord)->VALOR		+= nSaldo
				(cTbBord)->QTDTIT		+= 1
				IF (cTbBord)->REGRA = '  ' .and. cRegrBor != '  '
					(cTbBord)->REGRA			:= cRegrBor
				ENDIF
			(cTbBord)->( msUnLock() )
		ENDIF

		RecLock(cTbTit, .T.)
			(cTbTit)->REGRA		:= aRegrTit[1]
			(cTbTit)->CODBLOQ := aRegrTit[2]
			(cTbTit)->FILIAL	:= (cAlias)->E2_FILIAL
			(cTbTit)->BORDERO	:= (cAlias)->E2_NUMBOR
			(cTbTit)->DATABOR	:= (cAlias)->EA_DATABOR
			(cTbTit)->BANCO		:= (cAlias)->EA_PORTADO
			(cTbTit)->AGENCIA	:= (cAlias)->EA_AGEDEP
			(cTbTit)->CONTA		:= (cAlias)->EA_NUMCON
			(cTbTit)->PREFIXO	:= (cAlias)->E2_PREFIXO
			(cTbTit)->TITULO	:= (cAlias)->E2_NUM
			(cTbTit)->PARCELA	:= (cAlias)->E2_PARCELA
			(cTbTit)->TIPO		:= (cAlias)->E2_TIPO
			(cTbTit)->CODFORN	:= (cAlias)->E2_FORNECE
			(cTbTit)->LOJA		:= (cAlias)->E2_LOJA
			(cTbTit)->FORNECE	:= (cAlias)->E2_NOMFOR
			(cTbTit)->VENCREA	:= (cAlias)->E2_VENCREA
			(cTbTit)->VALOR		:= (cAlias)->E2_VALOR
			(cTbTit)->SALDO		:= nSaldo
			(cTbTit)->MOEDA		:= (cAlias)->E2_MOEDA
			(cTbTit)->CODBAR	:= (cAlias)->E2_CODBAR
		(cTbTit)->( msUnLock() )
		// ENDIF

		IF Alltrim((cAlias)->E2_NUMBOR) != ''
			nTotBor	+= nSaldo
			nQtdBor	+= 1
		ENDIF
		nTotTit	+= nSaldo
		nQtdTit	+= 1
    
    (cAlias)->(dbSkip())
  ENDDO
  (cAlias)->(dbCloseArea())

	If Select("TRB") > 0
		TRB->( dbCloseArea() )
	EndIf

Return

/*/{Protheus.doc} Static Function CriaTmpT
	Cria Tabela Temporária no Banco de Dados.
	@type  Static Function
	@author Abel Babini Filho
	@since 15/09/2020
	@version 1
	/*/
Static Function CriaTmpT(_oTable, _aFields, _aIndex)
	Local oTmpTb
	Local i
	oTmpTb := FWTemporaryTable():New(_oTable)

	oTmpTb:SetFields( _aFields )
	For i:=1 to Len(_aIndex)
		oTmpTb:AddIndex(_aIndex[i,1], _aIndex[i,2] )
		//oTmpTb:AddIndex("indice2", {"CONTR", "ALIAS"} )
	Next i
	oTmpTb:Create()

Return oTmpTb

/*/{Protheus.doc} Static Function CriaInd
	Cria Array com a extrutura para criação da Tabela Temporária no Banco de Dados.
	@type  Static Function
	@author Abel Babini Filho
	@since 15/09/2020
	@version 1
	/*/
Static Function CriaInd(_table)
	Local _aIndex := {}
	IF _table $ 'BORDERO'
		AADD(_aIndex,{'01',{'FILIAL','BORDERO','BANCO','AGENCIA','CONTA'}})
		AADD(_aIndex,{'02',{'REGRA','FILIAL','BORDERO','BANCO','AGENCIA','CONTA'}})
		AADD(_aIndex,{'03',{'FILIAL','DATABOR','BORDERO','BANCO','AGENCIA','CONTA'}})
		AADD(_aIndex,{'04',{'FILIAL','DATABOR','MODELO','TIPOPAG','BORDERO','BANCO','AGENCIA','CONTA'}})
	ELSEIF _table $ 'TITULOS'
		AADD(_aIndex,{'01',{'FILIAL','BORDERO','PREFIXO','TITULO','PARCELA','TIPO','CODFORN','LOJA','VENCREA'}})
		AADD(_aIndex,{'02',{'FILIAL','BORDERO','REGRA','PREFIXO','TITULO','PARCELA','TIPO','CODFORN','LOJA','VENCREA'}})
		AADD(_aIndex,{'03',{'FILIAL','BORDERO','CODFORN','LOJA','PREFIXO','TITULO','PARCELA','TIPO','VENCREA','REGRA'}})
		AADD(_aIndex,{'04',{'FILIAL','BORDERO','FORNECE','PREFIXO','TITULO','PARCELA','TIPO','VENCREA','REGRA'}})
		AADD(_aIndex,{'05',{'FILIAL','BORDERO','VENCREA','FORNECE','REGRA'}})
	ELSEIF _table $ 'RESTRICAO'
		AADD(_aIndex,{'01',{'FILIAL','BORDERO','REGRA','PREFIXO','TITULO','PARCELA','TIPO','CODFORN','LOJA','VENCREA','SALDO'}})
	ENDIF
Return _aIndex

/*/{Protheus.doc} Static Function CriaExtr
	Cria Array com a extrutura para criação da Tabela Temporária no Banco de Dados.
	@type  Static Function
	@author Abel Babini Filho
	@since 15/09/2020
	@version 1
	/*/
Static Function CriaExtr(_table)
	Local _aFields := {}

	IF _table $ 'TITULOS'
		aadd(_aFields,{"OMARK"			,"C"				,2					,0})
		aadd(_aFields,{"FILIAL"			,aX3Fil[3]	,aX3Fil[1]	,aX3Fil[2]})
		aadd(_aFields,{"PREFIXO"		,aX3Pref[3]	,aX3Pref[1]	,aX3Pref[2]})
		aadd(_aFields,{"TITULO"			,aX3NTit[3]	,aX3NTit[1]	,aX3NTit[2]})
		aadd(_aFields,{"PARCELA"		,aX3Parc[3]	,aX3Parc[1]	,aX3Parc[2]})
		aadd(_aFields,{"TIPO"				,aX3Tipo[3]	,aX3Tipo[1]	,aX3Tipo[2]})
		aadd(_aFields,{"CODFORN"		,aX3Forn[3]	,aX3Forn[1]	,aX3Forn[2]})
		aadd(_aFields,{"LOJA"				,aX3Loja[3]	,aX3Loja[1]	,aX3Loja[2]})
		aadd(_aFields,{"FORNECE"		,aX3NomF[3]	,aX3NomF[1]	,aX3NomF[2]})
		aadd(_aFields,{"VENCREA"		,aX3VcRe[3]	,aX3VcRe[1]	,aX3VcRe[2]})
		aadd(_aFields,{"VALOR"			,aX3Val[3]	,aX3Val[1]	,aX3Val[2]})
		aadd(_aFields,{"SALDO"			,aX3Sald[3]	,aX3Sald[1]	,aX3Sald[2]})
		aadd(_aFields,{"MOEDA"			,aX3Moed[3]	,aX3Moed[1]	,aX3Moed[2]})
		aadd(_aFields,{"BANCO"			,aX3Port[3]	,aX3Port[1]	,aX3Port[2]})
		aadd(_aFields,{"AGENCIA"		,aX3Agen[3]	,aX3Agen[1]	,aX3Agen[2]})
		aadd(_aFields,{"CONTA"			,aX3NCon[3]	,aX3NCon[1]	,aX3NCon[2]})
		aadd(_aFields,{"CODBAR"			,aX3CodB[3]	,aX3CodB[1]	,aX3CodB[2]})
		aadd(_aFields,{"BORDERO"		,aX3Bord[3]	,aX3Bord[1]	,aX3Bord[2]})
		aadd(_aFields,{"DATABOR"		,aX3DtBo[3]	,aX3DtBo[1]	,aX3DtBo[2]})
		aadd(_aFields,{"REGRA"			,"C"				,2					,0})
		aadd(_aFields,{"DSCREGRA"		,"C"				,254				,0})
		aadd(_aFields,{"CODBLOQ"		,"C"				,9					,0})

	ELSEIF _table $ 'BORDERO'
		aadd(_aFields,{"OMARK"			,"C"				,2					,0})
		aadd(_aFields,{"REGRA"			,"C"				,2					,0})
		// aadd(_aFields,{"DSCREGRA"		,"C"				,254				,0})
		aadd(_aFields,{"FILIAL"			,aX3Fil[3]	,aX3Fil[1]	,aX3Fil[2]})
		aadd(_aFields,{"BORDERO"		,aX3Bord[3]	,aX3Bord[1]	,aX3Bord[2]})
		aadd(_aFields,{"DATABOR"		,aX3DtBo[3]	,aX3DtBo[1]	,aX3DtBo[2]})
		aadd(_aFields,{"MODELO"			,aX3Modl[3]	,aX3Modl[1]	,aX3Modl[2]})
		aadd(_aFields,{"DSMODEL"		,"C"				,200				,0})
		aadd(_aFields,{"TIPOPAG"		,aX3TpPg[3]	,aX3TpPg[1]	,aX3TpPg[2]})
		aadd(_aFields,{"DSTPPAG"		,"C"				,200				,0})
		aadd(_aFields,{"BANCO"			,aX3Port[3]	,aX3Port[1]	,aX3Port[2]})
		aadd(_aFields,{"AGENCIA"		,aX3Agen[3]	,aX3Agen[1]	,aX3Agen[2]})
		aadd(_aFields,{"CONTA"			,aX3NCon[3]	,aX3NCon[1]	,aX3NCon[2]})
		aadd(_aFields,{"VALOR"			,aX3Val[3]	,aX3Val[1]	,aX3Val[2]})
		aadd(_aFields,{"QTDTIT"			,aX3Sald[3]	,aX3Sald[1]	,0})
	
	ELSEIF _table $ 'RESTRICAO'
		aadd(_aFields,{"FILIAL"			,aX3Fil[3]	,aX3Fil[1]	,aX3Fil[2]})
		aadd(_aFields,{"PREFIXO"		,aX3Pref[3]	,aX3Pref[1]	,aX3Pref[2]})
		aadd(_aFields,{"TITULO"			,aX3NTit[3]	,aX3NTit[1]	,aX3NTit[2]})
		aadd(_aFields,{"PARCELA"		,aX3Parc[3]	,aX3Parc[1]	,aX3Parc[2]})
		aadd(_aFields,{"TIPO"				,aX3Tipo[3]	,aX3Tipo[1]	,aX3Tipo[2]})
		aadd(_aFields,{"CODFORN"		,aX3Forn[3]	,aX3Forn[1]	,aX3Forn[2]})
		aadd(_aFields,{"LOJA"				,aX3Loja[3]	,aX3Loja[1]	,aX3Loja[2]})
		aadd(_aFields,{"FORNECE"		,aX3NomF[3]	,aX3NomF[1]	,aX3NomF[2]})
		aadd(_aFields,{"VENCREA"		,aX3VcRe[3]	,aX3VcRe[1]	,aX3VcRe[2]})
		aadd(_aFields,{"VALOR"			,aX3Val[3]	,aX3Val[1]	,aX3Val[2]})
		aadd(_aFields,{"SALDO"			,aX3Sald[3]	,aX3Sald[1]	,aX3Sald[2]})
		aadd(_aFields,{"MOEDA"			,aX3Moed[3]	,aX3Moed[1]	,aX3Moed[2]})
		aadd(_aFields,{"BORDERO"		,aX3Bord[3]	,aX3Bord[1]	,aX3Bord[2]})
		aadd(_aFields,{"DATABOR"		,aX3DtBo[3]	,aX3DtBo[1]	,aX3DtBo[2]})
		aadd(_aFields,{"REGRA"			,"C"				,2					,0})
		aadd(_aFields,{"DSCREGRA"		,"C"				,254				,0})
		// aadd(_aFields,{"CODBLOQ"		,"C"				,9					,0})

		aadd(_aFields,{"RECPAG"			,"C"				,1				,0})
		aadd(_aFields,{"BLQFIL"			,aX3Fil[3]	,aX3Fil[1]	,aX3Fil[2]})
		aadd(_aFields,{"BLQPRE"			,aX3Pref[3]	,aX3Pref[1]	,aX3Pref[2]})
		aadd(_aFields,{"BLQTIT"			,aX3NTit[3]	,aX3NTit[1]	,aX3NTit[2]})
		aadd(_aFields,{"BLQPAR"			,aX3Parc[3]	,aX3Parc[1]	,aX3Parc[2]})
		aadd(_aFields,{"BLQTIP"			,aX3Tipo[3]	,aX3Tipo[1]	,aX3Tipo[2]})
		aadd(_aFields,{"BLQCLFR"		,aX3Forn[3]	,aX3Forn[1]	,aX3Forn[2]})
		aadd(_aFields,{"BLQLOJ"			,aX3Loja[3]	,aX3Loja[1]	,aX3Loja[2]})
		aadd(_aFields,{"BLQNOM"			,aX3NomF[3]	,aX3NomF[1]	,aX3NomF[2]})
		aadd(_aFields,{"BLQVAL"			,aX3Val[3]	,aX3Val[1]	,aX3Val[2]})
		aadd(_aFields,{"BLQSAL"			,aX3Sald[3]	,aX3Sald[1]	,aX3Sald[2]})
		aadd(_aFields,{"BLQMOE"			,aX3Moed[3]	,aX3Moed[1]	,aX3Moed[2]})
		aadd(_aFields,{"BLQCBR"			,aX3CodB[3]	,aX3CodB[1]	,aX3CodB[2]})
		aadd(_aFields,{"LIVRE"			,"C"				,254				,0})

	ENDIF

Return _aFields

/*/{Protheus.doc} Static Function AddCols
	Adiciona colunas na estrutura do FWMBrowse 
	@type  Static Function
	@author Abel Babini Filho
	@since 15/09/2020
	@version 1
	/*/
Static Function AddCols(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal,lDpClk, cOrig)
	
	Local aColumn
	Local bData 	 		:= {||}

	Default nAlign 		:= 1
	Default nSize 		:= 20
	Default nDecimal	:= 0
	Default nArrData	:= 0
	Default lDpClk		:= .F.
	Default cOrig			:= "T"
	
	If nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
	EndIf
	
	/* Array da coluna
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edição
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Variável a ser utilizada na edição (ReadVar)
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
	*/
	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{|| IIF(lDpClk,xTitSts(cOrig),.T.)},NIL,{||.T.},.F.,.F.,{}}  
	
Return {aColumn}

/*/{Protheus.doc} Static Function GrdBord
	Adiciona Grid dos Borderôs
	@type  Static Function
	@author Abel Babini Filho
	@since 15/09/2020
	@version 1
	/*/
Static Function GrdBord()
	oGrd10	:= FWMarkBrowse():New()
	oGrd10:SetOwner( oPnBr01 )
	// oGrd10:SetDescription( 'Borderôs' )
	oGrd10:SetMenuDef('')
	oGrd10:DisableDetails()
	oGrd10:SetAlias(cTbBord)
	oGrd10:SetProfileID('1')
	oGrd10:SetFieldMark('OMARK')

	// oGrd10:SetMark(oGrd10:Mark(), cTbBord, "OMARK")
	// oGrd10:SetAllMark( { || .T. } )
	oGrd10:bAllMark := { || InvSel(cTbBord,oGrd10:Mark(),lMkBord := !lMkBord,.F. ), oGrd10:Refresh(.T.)  }
	// // oGrd10:AddButton("Inverter Seleção", { || InvSel(cTbBord,oMrkBrowse:Mark(),lMkBord := !lMkBord,.T. ),oMrkBrowse:Refresh(.T.)},,2 )
	// oGrd10:AddButton("Rel. Borderôs", { || InvSel(cTbBord,oMrkBrowse:Mark(),lMkBord := !lMkBord,.T. ),oMrkBrowse:Refresh(.T.)},,2 )

	oGrd10:AddLegend( "REGRA == '  '" , "ENABLE", "Borderô OK" )
	oGrd10:AddLegend( "REGRA == ' 1'" , "DISABLE", "Borderô com títulos com restrição" )
	oGrd10:AddLegend( "REGRA == ' 2'" , "BR_AZUL", "Borderô com títulos em aprovação" )

	oGrd10:SetColumns(AddCols("FILIAL"		,"Filial"			,01,PesqPict("SE2","E2_FILIAL")	,0	,aX3Fil[1]	,aX3Fil[2] , .T.,"B"))
	oGrd10:SetColumns(AddCols("BORDERO"		,"Borderô"		,01,PesqPict("SE2","E2_NUMBOR")	,1	,aX3Bord[1]	,aX3Bord[2], .T.,"B"))
	oGrd10:SetColumns(AddCols("DATABOR"		,"Data Bord."	,01,PesqPict("SEA","EA_DATABOR"),1	,aX3DtBo[1]	,aX3DtBo[2], .T.,"B"))
	oGrd10:SetColumns(AddCols("MODELO"		,"Modelo"			,01,PesqPict("SEA","EA_MODELO")	,1	,aX3Modl[1]	,aX3Modl[2], .T.,"B"))
	oGrd10:SetColumns(AddCols("DSMODEL"		,"Dsc.Modelo"	,01,"@!"												,1	,100				,0				 , .T.,"B"))
	oGrd10:SetColumns(AddCols("TIPOPAG"		,"Tipo Pgto"	,01,PesqPict("SEA","EA_TIPOPAG"),1	,aX3TpPg[1]	,aX3TpPg[2], .T.,"B"))
	oGrd10:SetColumns(AddCols("DSTPPAG"		,"Dsc.Pgto"		,01,"@!"												,1	,100				,0				 , .T.,"B"))
	oGrd10:SetColumns(AddCols("BANCO"			,"Banco"			,01,PesqPict("SEA","EA_PORTADO"),1	,aX3Port[1]	,aX3Port[2], .T.,"B"))
	oGrd10:SetColumns(AddCols("AGENCIA"		,"Agência"		,01,PesqPict("SEA","EA_AGEDEP")	,1	,aX3Agen[1]	,aX3Agen[2], .T.,"B"))
	oGrd10:SetColumns(AddCols("CONTA"			,"Conta"			,01,PesqPict("SEA","EA_NUMCON")	,1	,aX3NCon[1]	,aX3NCon[2], .T.,"B"))
	oGrd10:SetColumns(AddCols("VALOR"			,"Valor"			,01,PesqPict("SE2","E2_SALDO")	,2	,aX3Val[1]	,aX3Val[2] , .T.,"B"))
	oGrd10:SetColumns(AddCols("QTDTIT"		,"Qtd.Titulos",01,'@E 999,999,999'						,2	,aX3Sald[1]	,0				 , .T.,"B"))
	// oGrd10:SetColumns(AddCols("REGRA"	,"# Regra"    ,01,"@!"												,0	,02					,0				 , .T.,"B"))		

	oGrd10:DisableReport()
	// oGrd10:SetAfterMark({||xAtuInf('DP')})
	// Menu oMnBor PopUp
	// 	MenuItem "Marca Todos" 													Action Eval( { || aEval( aArray , { |x| x[nPosFlg] := .t. 						} ) , xRetValues(@oTotal,@nTotal,@oQtd,@nQtd,aArray) , oGrd20:Refresh() })
	// 	MenuItem "Desmarca Todos"  											Action Eval( { || aEval( aArray , { |x| x[nPosFlg] := .f. 						} ) , xRetValues(@oTotal,@nTotal,@oQtd,@nQtd,aArray) , oGrd20:Refresh() })
	// 	MenuItem "Marcar Borderôs Liberados"  					Action Eval( { || aEval( aArray , { |x| x[nPosFlg] := ( x[nPosStt] $  "1/5" ) 	} ) , xRetValues(@oTotal,@nTotal,@oQtd,@nQtd,aArray) , oGrd20:Refresh() })
	// 	MenuItem "Marcar Borderôs Aguardando Liberação" Action Eval( { || aEval( aArray , { |x| x[nPosFlg] := ( x[nPosStt] == "2" ) 	} ) , xRetValues(@oTotal,@nTotal,@oQtd,@nQtd,aArray) , oGrd20:Refresh() })
	// 	MenuItem "Inverter Seleção"  										Action Eval( { || InvSel(cAliasTemp,oGrd10:Mark(),lMarcar := !lMarcar,.T. ),oGrd10:Refresh(.T.)})
	// //  MenuItem "Marcar Títulos Vinculados a Borderô"  	Action Eval( { || aEval( aArray , { |x| x[nPosFlg] := ( x[nPosStt] == "4" ) 	} ) , xRetValues(@oTotal,@nTotal,@oQtd,@nQtd,aArray) , oGrd20:Refresh() })
	// //  MenuItem "Desmarcar Títulos com Dados Faltantes"	Action Eval( { || fCleanTit(@oDlgxPg,@oGrd20,@aArray) 									, xRetValues(@oTotal,@nTotal,@oQtd,@nQtd,aArray) , oGrd20:Refresh() })
	// EndMenu

	// oTButton2:SetPopUpMenu(oMnBor)
	oGrd10:Activate()

Return

/*/{Protheus.doc} Static Function GrdTit
	Adiciona Grid dos Borderôs
	@type  Static Function
	@author Abel Babini Filho
	@since 15/09/2020
	@version 1
	/*/
Static Function GrdTit()
	oGrd20	:= FWMarkBrowse():New()
	oGrd20:SetOwner( oPnTt01 )
	// oGrd20:SetDescription('Títulos')
	oGrd20:SetMenuDef('')
	oGrd20:DisableDetails()
	oGrd20:SetAlias(cTbTit)
	oGrd20:SetProfileID('2')
	oGrd20:SetFieldMark('OMARK')

	oGrd20:AddLegend( "REGRA == '  '" , "ENABLE", "Título OK" )
	oGrd20:AddLegend( "REGRA == '01'" , "DISABLE", "Título com restrição" )
	oGrd20:AddLegend( "REGRA == '02'" , "BR_AZUL", "Título aguardando aprovação" )
	
	/*
	oGrd20:AddLegend( "REGRA == '  '" , "ENABLE", "Título OK" )
	oGrd20:AddLegend( "REGRA == '01'" , "DISABLE", "Título em Borderô maior que D+1" )
	oGrd20:AddLegend( "REGRA == '02'" , "BR_AZUL", "Título com Devoluções ou adiantamentos" )
	oGrd20:AddLegend( "REGRA == '03'" , "BR_CINZA", "CNPJ Raíz com Títulos a Receber" )
	oGrd20:AddLegend( "REGRA == '04'" , "BR_BRANCO", "Título com risco de Duplicidade de Pagamento" )
	oGrd20:AddLegend( "REGRA == '05'" , "BR_AMARELO", "Condição de Pagamento ICM não permite pagamento" )
	oGrd20:AddLegend( "REGRA == '06'" , "BR_LARANJA", "Saldo do Título diferente do valor em borderô" )
	oGrd20:AddLegend( "REGRA == '07'" , "BR_PRETO", "Dados bancários diferentes entre Cad. Cliente e Borderô" )
	oGrd20:AddLegend( "REGRA == '08'" , "BR_MARROM", "Título incluído manualmente sem aprovação" )
	oGrd20:AddLegend( "REGRA == '09'" , "BR_PINK", "Título com alteração na forma de pagamento" )
	oGrd20:AddLegend( "REGRA == '99'" , "BR_VIOLETA", "Título várias inconsistências." )
	*/

	oGrd20:SetColumns(AddCols("FILIAL"		,"Filial"			,01,PesqPict("SE2","E2_FILIAL")	,0	,aX3Fil[1]	,aX3Fil[2] , .T.,"T"))
	oGrd20:SetColumns(AddCols("PREFIXO"		,"Prefixo"		,01,PesqPict("SE2","E2_PREFIXO"),1	,aX3Pref[1]	,aX3Pref[2], .T.,"T"))
	oGrd20:SetColumns(AddCols("TITULO"		,"Título"			,01,PesqPict("SE2","E2_NUM")		,1	,aX3NTit[1]	,aX3NTit[2], .T.,"T"))
	oGrd20:SetColumns(AddCols("PARCELA"		,"Parcela"		,01,PesqPict("SE2","E2_PARCELA"),1	,aX3Parc[1]	,aX3Parc[2], .T.,"T"))
	oGrd20:SetColumns(AddCols("TIPO"			,"Tipo"				,01,PesqPict("SE2","E2_TIPO")		,1	,aX3Tipo[1]	,aX3Tipo[2], .T.,"T"))		
	oGrd20:SetColumns(AddCols("CODFORN"		,"Código"			,01,PesqPict("SE2","E2_FORNECE"),1	,aX3Forn[1]	,aX3Forn[2], .T.,"T"))
	oGrd20:SetColumns(AddCols("LOJA"			,"Loja"				,01,PesqPict("SE2","E2_LOJA")		,1	,aX3Loja[1]	,aX3Loja[2], .T.,"T"))
	oGrd20:SetColumns(AddCols("FORNECE"		,"Fornecedor"	,01,PesqPict("SE2","E2_NOMFOR")	,1	,aX3NomF[1]	,aX3NomF[2], .T.,"T"))
	oGrd20:SetColumns(AddCols("VENCREA"		,"Venc.Real"	,01,PesqPict("SE2","E2_VENCREA"),1	,aX3VcRe[1]	,aX3VcRe[2], .T.,"T"))
	oGrd20:SetColumns(AddCols("VALOR"			,"Valor"			,01,PesqPict("SE2","E2_VALOR")	,2	,aX3Val[1]	,aX3Val[2] , .T.,"T"))
	oGrd20:SetColumns(AddCols("SALDO"			,"Saldo"			,01,PesqPict("SE2","E2_SALDO")	,2	,aX3Sald[1]	,aX3Sald[2], .T.,"T"))
	oGrd20:SetColumns(AddCols("MOEDA"			,"Moeda"			,01,PesqPict("SE2","E2_MOEDA")	,1	,aX3Moed[1]	,aX3Moed[2], .T.,"T"))
	oGrd20:SetColumns(AddCols("CODBAR"		,"Cod.Barras"	,01,PesqPict("SE2","E2_CODBAR")	,1	,aX3CodB[1]	,aX3CodB[2], .T.,"T"))
	oGrd20:SetColumns(AddCols("CODBLOQ"		,"Bloqueios"  ,01,"@!",0,09,0))		

	oGrd20:DisableReport()
	// oGrd20:SetAfterMark({||xAtuInf('CC')})
	// oGrd20:bHeaderClick	:= 	{ |o,x,y|  iif( x == 1 , oMenu:Activate(x,y,oGrd20) , fChgOrT(x)/*fChgOrT(@oDlgxPg,@oGrd20,@aArray,x)*/ ) }
	// oGrd20:bLDblClick	:=	{ || SE2->(dbgoto(aArray[oGrd20:nAt,nPosRec])) , fSelect(@oDlgxPg,@oGrd20,@aArray) , xRetValues(@oTotal,@nTotal,@oQtd,@nQtd,aArray) }

	oGrd20:SetLineHeight(12)
	oGrd20:Activate()

	oRelacGrd:= FWBrwRelation():New()
	oRelacGrd:AddRelation(oGrd10 , oGrd20 , { { 'FILIAL','FILIAL'} , {'BORDERO','BORDERO' } } )
	oRelacGrd:Activate()

Return

/*/{Protheus.doc} Static Function xTitSts
	Existe status dos títulos
	@type  Static Function
	@author Abel Babini Filho
	@since 15/09/2020
	@version 1
	/*/
Static Function xTitSts(cOrig)
	Default cOrig := "T"

	aTbRest	:= {}

	IF cOrig == "T"
		(cTbRest)->(DBSetFilter( {|| FILIAL+PREFIXO+TITULO+PARCELA+TIPO+CODFORN+LOJA = (cTbTit)->FILIAL+(cTbTit)->PREFIXO+(cTbTit)->TITULO+(cTbTit)->PARCELA+(cTbTit)->TIPO+(cTbTit)->CODFORN+(cTbTit)->LOJA}, "FILIAL+PREFIXO+TITULO+PARCELA+TIPO+CODFORN+LOJA = (cTbTit)->FILIAL+(cTbTit)->PREFIXO+(cTbTit)->TITULO+(cTbTit)->PARCELA+(cTbTit)->TIPO+(cTbTit)->CODFORN+(cTbTit)->LOJA" ))
	ELSE //cOrig == "B"
		(cTbRest)->(DBSetFilter( {|| FILIAL+BORDERO = (cTbTit)->FILIAL+(cTbTit)->BORDERO}, "FILIAL+BORDERO = (cTbTit)->FILIAL+(cTbTit)->BORDERO" ))
	ENDIF
	// Alert('teste')
	(cTbRest)->(dbGoTop())

	While !(cTbRest)->(eof())

		If !ASCAN(aTbRest,{|X| X[1] == (cTbRest)->REGRA}) > 0
			AADD(aTbRest,{	(cTbRest)->REGRA,;
											(cTbRest)->DSCREGRA,;
											(cTbRest)->FILIAL		,;
											(cTbRest)->PREFIXO	,;
											(cTbRest)->TITULO		,;
											(cTbRest)->PARCELA	,;
											(cTbRest)->TIPO			,;
											(cTbRest)->CODFORN	,;
											(cTbRest)->LOJA			,;
											(cTbRest)->FORNECE	,;
											(cTbRest)->VENCREA	,;
											(cTbRest)->VALOR		,;
											(cTbRest)->SALDO		,;
											(cTbRest)->BORDERO	,;
											(cTbRest)->RECPAG 	,;
											(cTbRest)->BLQFIL 	,;
											(cTbRest)->BLQPRE		,;
											(cTbRest)->BLQTIT 	,;
											(cTbRest)->BLQPAR 	,;
											(cTbRest)->BLQTIP 	,;
											(cTbRest)->BLQCLFR 	,;
											(cTbRest)->BLQLOJ 	,;
											(cTbRest)->BLQNOM 	,;
											(cTbRest)->BLQVAL 	,;
											(cTbRest)->BLQSAL 	,;
											(cTbRest)->BLQMOE 	,;
											(cTbRest)->BLQCBR		,;
											(cTbRest)->LIVRE		;
										})

		ENDIF
		(cTbRest)->(dbSkip())
	EndDo
	(cTbRest)->(dbGoTop())

	DEFINE MSDIALOG oDlgTSts TITLE "Análise de Restrições no Título" OF oDlgxPg PIXEL FROM 0/*aSize[7]*/,0 TO 400,900/*aSize[6],aSize[5]	*/
		oDlgTSts:lEscClose     := .T. //Permite sair ao se pressionar a tecla ESC.

		oBrwReg:= TcBrowse():New(010,010,100,150,,{'Regra','Descrição'},{50,150},oDlgTSts,,,,,,,,,,,,.F.,,.T.,,.F.,,,,)
		oBrwReg:AddColumn( TcColumn():New( "Regra"			,{ || aTbRest[oBrwReg:nAt,01]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Descrição"	,{ || aTbRest[oBrwReg:nAt,02]}	, "@!"						,,,"LEFT"	,150,.f.,.f.,,,,.f.,) )     					

		oBrwReg:AddColumn( TcColumn():New( "Filial"			,{ || aTbRest[oBrwReg:nAt,03]}	, "@!"						,,,"LEFT"	,010,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Prefixo"		,{ || aTbRest[oBrwReg:nAt,04]}	, "@!"						,,,"LEFT"	,010,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Título"			,{ || aTbRest[oBrwReg:nAt,05]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Parcela"		,{ || aTbRest[oBrwReg:nAt,06]}	, "@!"						,,,"LEFT"	,010,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Tipo"				,{ || aTbRest[oBrwReg:nAt,07]}	, "@!"						,,,"LEFT"	,010,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Cod.Forn."	,{ || aTbRest[oBrwReg:nAt,08]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Loja"				,{ || aTbRest[oBrwReg:nAt,09]}	, "@!"						,,,"LEFT"	,010,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Fornecedor"	,{ || aTbRest[oBrwReg:nAt,10]}	, "@!"						,,,"LEFT"	,050,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Venc.Real"	,{ || aTbRest[oBrwReg:nAt,11]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Valor"			,{ || aTbRest[oBrwReg:nAt,12]}	, PesqPict("SE2","E2_VALOR"),,,"RIGHT"	,035,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Saldo"			,{ || aTbRest[oBrwReg:nAt,13]}	, PesqPict("SE2","E2_SALDO"),,,"RIGHT"	,035,.f.,.f.,,,,.f.,) )     					

		oBrwReg:AddColumn( TcColumn():New( "Borderô"	,{ || aTbRest[oBrwReg:nAt,14]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )     					

		oBrwReg:AddColumn( TcColumn():New( "R/P.Tit.Incons"			,{ || aTbRest[oBrwReg:nAt,15]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Filial.Tit.Incons"	,{ || aTbRest[oBrwReg:nAt,16]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Pref.Tit.Incons"		,{ || aTbRest[oBrwReg:nAt,17]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Num.Tit.Incons"			,{ || aTbRest[oBrwReg:nAt,18]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Parc.Tit.Incons"		,{ || aTbRest[oBrwReg:nAt,19]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Tip.Tit.Incons"			,{ || aTbRest[oBrwReg:nAt,20]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Cod.Tit.Incons"			,{ || aTbRest[oBrwReg:nAt,21]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Loj.Tit.Incons"			,{ || aTbRest[oBrwReg:nAt,22]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Nome.Tit.Incons"		,{ || aTbRest[oBrwReg:nAt,23]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Val.Tit.Incons"			,{ || aTbRest[oBrwReg:nAt,24]}	, PesqPict("SE2","E2_VALOR"),,,"RIGHT"	,035,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Sald.Tit.Incons"		,{ || aTbRest[oBrwReg:nAt,25]}	, PesqPict("SE2","E2_SALDO"),,,"RIGHT"	,035,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Moed.Tit.Incons"		,{ || aTbRest[oBrwReg:nAt,26]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )     					
		// oBrwReg:AddColumn( TcColumn():New( "Cod.Bar.Tit.Incons."	,{ || aTbRest[oBrwReg:nAt,27]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )     					
		oBrwReg:AddColumn( TcColumn():New( "Observação"					,{ || aTbRest[oBrwReg:nAt,28]}	, "@!"						,,,"LEFT"	,200,.f.,.f.,,,,.f.,) )     					

		oBrwReg:SetArray(aTbRest)
		oBrwReg:Align		:=	CONTROL_ALIGN_ALLCLIENT //CONTROL_ALIGN_TOP

	Activate MsDialog oDlgTSts Centered 
Return

/*/{Protheus.doc} Static Function InvSel
	Adiciona Grid dos Borderôs
	@type  Static Function
	@author Abel Babini Filho
	@since 15/09/2020
	@version 1
	/*/
Static Function InvSel(cAlias,cMarca,lMarcar, lInvert)

	Local aAreaLc  := (cAlias)->( GetArea() )

	(cAlias)->( dbGoTop() )

	Do While !(cAlias)->( EOF() )
		
		RecLock( (cAlias), .F. )
		
			If lInvert
				(cAlias)->OMARK := IIf( (cAlias)->OMARK == cMarca , '  ',cMarca )
			Else
				(cAlias)->OMARK := IIf( lMarcar, cMarca, '  ' )
			Endif
		
		(cAlias)->( MsUnlock() )
		
		(cAlias)->( dbSkip() )
		
	EndDo

	RestArea( aAreaLc )

Return .T.


/*/{Protheus.doc} Static Function RegraBor
	Retorna descrição da Regra Bloqueada
	@type  Static Function
	@author Abel Babini Filho
	@since 15/09/2020
	@version 1
	/*/
Static Function RegraBor(lRegra01,lRegra02,lRegra03,lRegra04,lRegra05,lRegra06,lRegra07,lRegra08,lRegra09,lDiverg)
	Local cRet := '  '
	If lRegra01 .or. lRegra02 .or. lRegra03 .or. lRegra04 .or. lRegra05 .or. lRegra06 .or. lRegra07 .or. lRegra08 .or. lRegra09 .or. lDiverg
		cRet := ' 1'
	Endif
Return cRet

/*/{Protheus.doc} Static Function RegraTit
	Retorna descrição da Regra Bloqueada
	@type  Static Function
	@author Abel Babini Filho
	@since 15/09/2020
	@version 1
	/*/
Static Function RegraTit(lRegra01,lRegra02,lRegra03,lRegra04,lRegra05,lRegra06,lRegra07,lRegra08,lRegra09,lDiverg)
	Local cRet := '  '
	Local nBlq := 0
	Local cCodBlq := '000000000'//Space(9)
	/**/
	//Ticket   8061 - Abel Babini - 19/01/2021 - Desabilitar regra 01 no Painel de Pagamentos
	//manterei o fonte comentado para caso o usuário resolva habilitar novamente o recurso.
	/*
	IF lRegra01
		nBlq += 1
		cRet := '01'
		cCodBlq := '1'+Substr(cCodBlq,2,8)
	ENDIF
	*/
	IF lRegra02
		nBlq += 1
		cRet := '02'
		cCodBlq := Substr(cCodBlq,1,1)+'1'+Substr(cCodBlq,3,7)
	ENDIF
	IF lRegra03
		nBlq += 1
		cRet := '03'
		cCodBlq := Substr(cCodBlq,1,2)+'1'+Substr(cCodBlq,4,6)
	ENDIF
	IF lRegra04
		nBlq += 1
		cRet := '04'
		cCodBlq := Substr(cCodBlq,1,3)+'1'+Substr(cCodBlq,5,5)
	ENDIF
	IF lRegra05
		nBlq += 1
		cRet := '05'
		cCodBlq := Substr(cCodBlq,1,4)+'1'+Substr(cCodBlq,6,4)
	ENDIF
	IF lRegra06
		nBlq += 1
		cRet := '06'
		cCodBlq := Substr(cCodBlq,1,5)+'1'+Substr(cCodBlq,7,3)
	ENDIF
	IF lRegra07
		nBlq += 1
		cRet := '07'
		cCodBlq := Substr(cCodBlq,1,6)+'1'+Substr(cCodBlq,8,2)
	ENDIF
	IF lRegra08
		nBlq += 1
		cRet := '08'
		cCodBlq := Substr(cCodBlq,1,7)+'1'+Substr(cCodBlq,9,1)
	ENDIF
	IF lRegra09
		nBlq += 1
		cRet := '09'
		cCodBlq := Substr(cCodBlq,1,8)+'1'
	ENDIF

	IF lDiverg
		cRet := '02'
	ElseIf nBlq >= 1
		// cRet := '99'
		cRet := '01'
	ENDIF
	/*	*/
	/*IF lRegra01 .OR. lRegra02 .OR. lRegra03 .OR. lRegra04 .OR. lRegra05 .OR. lRegra06 .OR. lRegra07 .OR. lRegra08 .OR. lRegra09
		cRet := '01'
	ENDIF*/
Return {cRet,cCodBlq}

/*/{Protheus.doc} Static Function xGeraLog()
	Grava Log na tabela ZBE
	@type  Static Function
	@author Abel Babini Filho
	@since 18/09/2020
	@version 1
	/*/
Static Function xGeraLog()
	RecLock("ZBE",.T.)
		ZBE->ZBE_FILIAL	:= FWxFilial("ZBE")
		ZBE->ZBE_DATA 	:= msDate()
		ZBE->ZBE_HORA 	:= cValToChar(Time())
		ZBE->ZBE_USUARI := cUserName
		ZBE->ZBE_LOG 		:= "Solicita Aprovação pelo Painel Pagamento"
		ZBE->ZBE_MODULO := "FINANCEIRO"
		ZBE->ZBE_ROTINA := "ADFIN101P"
		ZBE->ZBE_PARAME := "Título SE2: "+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA
	ZBE->( msUnLock() )
  
Return

//INICIO Ticket    429 - Abel Babini - 03/11/2020 - Ajustes na gravação da solicitação de aprovação de pagamento (Central de Aprovação) e mensagem obrigatória
/*/{Protheus.doc} Static Function RetBlqs()
	Cria TRB
	@type  Static Function
	@author Abel Babini Filho
	@since 18/09/2020
	@version 1
	/*/
Static Function RetBlqs(cCodBlq)
	Local cRet := ''

	If Substr(cCodBlq,1,1) == '1'
		cRet += "Bord > 1d - "
	End
	If Substr(cCodBlq,2,1) == '1'
		cRet += "Tem dev. ou adiant. - "
	End
	If Substr(cCodBlq,3,1) == '1'
		cRet += "Tem tít. receber - "
	End
	If Substr(cCodBlq,4,1) == '1'
		cRet += "Risco duplic. - "
	End
	If Substr(cCodBlq,5,1) == '1'
		cRet += "CondPgto ICM - "
	End
	If Substr(cCodBlq,6,1) == '1'
		cRet += "Saldo tit dif. do bord. - "
	End
	If Substr(cCodBlq,7,1) == '1'
		cRet += "Dados banc. dif. - "
	End
	If Substr(cCodBlq,8,1) == '1'
		cRet += "Tit inc manual - "
	End
	If Substr(cCodBlq,9,1) == '1'
		cRet += "Alter. forma pagto"
	EndIf

Return cRet
//FIM Ticket    429 - Abel Babini - 03/11/2020 - Ajustes na gravação da solicitação de aprovação de pagamento (Central de Aprovação) e mensagem obrigatória

//INICIO Ticket   4883 - Abel Babini - 01/12/2020 - Geração de borderôs automática
/*/{Protheus.doc} Static Function xAutBor()
	Chama rotina de geração automática de borderôs
	@type  Static Function
	@author Abel Babini Filho
	@since 18/09/2020
	@version 1
	/*/
Static Function xAutBor()
	Local aArea				:= GetArea()
	Local cAlsBACB 		:= GetNextAlias()
	Local cAlsVUti		:= ''
	// Local dDtSrv 			:= StaticCall(ADFIN100P,xVrfData,msDate() + 1)
	Local cCodCart		:=	GetMv("MV_#CDCART",,"01,30,31,41,11,13,16,17,35,91")  	
	Local InCdCart		:= '%'+FormatIn(cCodCart,",")+'%'
	Local _i					:= 0
  // Local nCount	:=	0
  // Local nRegCnt	:=	0

	Private aBACBord 	:= {}
	Private nItBAC 		:= 0
	
	// If CtoD(cVencIni) < msDate() .AND. CtoD(cVencFim) > dDtSrv
	// 	AVISO("ADFIN101P-01","Só é possível gerar borderô quando as datas de início e fim foram igual a D+0 ou D+1")
	// 	Return
	// Endif

	BeginSql alias cAlsBACB

		SELECT *
		FROM %TABLE:ZG5% ZG5 (NOLOCK)
		WHERE
			ZG5.%notDel%
		AND ZG5.ZG5_DTINI <= %Exp:DtoS(aRet[3])%
		AND (ZG5.ZG5_DTFIM >= %Exp:DtoS(aRet[4])% OR ZG5.ZG5_DTFIM = '')
		AND ZG5.ZG5_MODALI IN %Exp:InCdCart%
		ORDER BY ZG5_FILIAL, ZG5_MODALI, ZG5_TIPOPG, ZG5_ORDEM
	EndSql

  // Count to nCount
  (cAlsBACB)->(dbgotop())
	// oProcess:SetRegua1(nCount)
  
	While ! (cAlsBACB)->(eof())
		// oProcess:IncRegua1("Borderôs de Modelo Pagamento " + StrZero( ++ nRegCnt,06) + " de " + StrZero(nCount,06))

		cAlsVUti		:= GetNextAlias()
		BeginSql alias cAlsVUti
			SELECT SUM(E2_SALDO) AS UTILIZADO
			FROM %TABLE:SE2% SE2 (NOLOCK) 
			INNER JOIN %TABLE:SEA% SEA (NOLOCK)  ON
				SEA.EA_FILIAL = SE2.E2_FILIAL
			AND SEA.EA_NUM = SE2.E2_NUM
			AND SEA.EA_PREFIXO = SE2.E2_PREFIXO
			AND SEA.EA_PARCELA = SE2.E2_PARCELA
			AND SEA.EA_TIPO = SE2.E2_TIPO
			AND SEA.%notDel%
			WHERE E2_VENCREA BETWEEN %Exp:DtoS(aRet[3])% AND %Exp:DtoS(aRet[4])%
			AND E2_NUMBOR <> ''
			AND EA_MODELO = %Exp:(cAlsBACB)->ZG5_MODALI%
			AND EA_TIPOPAG = %Exp:(cAlsBACB)->ZG5_TIPOPG%
			AND SE2.%notDel%
		EndSql

		If xVrfBrd((cAlsBACB)->ZG5_MODALI, (cAlsBACB)->ZG5_BANCO, (cAlsBACB)->ZG5_AGEN, (cAlsBACB)->ZG5_NOCTA)
			aAdd(aBACBord , {(cAlsBACB)->ZG5_FILIAL,;
											(cAlsBACB)->ZG5_MODALI,;
											(cAlsBACB)->ZG5_TIPOPG,;
											(cAlsBACB)->ZG5_ORDEM,;
											(cAlsBACB)->ZG5_BANCO,;
											(cAlsBACB)->ZG5_AGEN,;
											(cAlsBACB)->ZG5_NOCTA,;
											(cAlsBACB)->ZG5_VALOR,;
											(cAlsVUti)->UTILIZADO }) //VALOR JÁ UTILIZADO
		Endif
		(cAlsVUti)->(dbCloseArea())

		(cAlsBACB)->(dbSkip())
	EndDo

	(cAlsBACB)->(dbCloseArea())
	IF Len(aBACBord) = 0 
		AVISO("ADFIN101P-02","Não foram localizados títulos ou configuração de borderô automático. Reveja as configurações e o status dos títulos e tente novamente!")
	ENDIF
	For _i:= 1 to Len(aBACBord)
		nItBAC := _i
		nExecBor	:= 0
		FA240Borde("SE2",0,2,.T.)
		// Startjob("U_ADLOG058P()",getenvserver(),.F.,cRoteiro,cData)

	Next _i

	RestArea(aArea)
Return
//FIM Ticket   4883 - Abel Babini - 01/12/2020 - Geração de borderôs automática

/*/{Protheus.doc} Static Function xVrfBrd()
	Verifica se existem títulos para a configuração de borderô selecionada.
	@type  Static Function
	@author Abel Babini Filho
	@since 29/12/2020
	@version 1
	/*/
Static Function xVrfBrd(cModBrdA, cBcoBrdA, cAgeBrdA, cCtaBrdA)
	Local lRet	:= .T.
	Local cQryVrfB	:= GetNextAlias()
	Local cFlAdBA	:= '%'+""+'%'

	//Ticket    4883 - Abel Babini  - 08/01/2021 - Implementação de novas modalidades de pagamento
	Local cNatGPS := FormatIn(GetMV("MV_#BORGPS",,"22406,"),',')
	Local cNatDRF := FormatIn(GetMV("MV_#BORDRF",,"22307,22406,22404,22603,22604,22606,22607,"),',')
	Local cNatCON := FormatIn(GetMV("MV_#BORCON",,"20503,"),',')
	Local cNatIMP := FormatIn(GetMV("MV_#BORIMP",,"22406,22610,22608,"),',')
	Local cNatFGT := FormatIn(GetMV("MV_#BORFGT",,"22306,"),',')


	IF cModBrdA == '01'
		cFlAdBA := '%'+" AND SE2.E2_BANCO = '"+cBcoBrdA+"' AND SE2.E2_CODBAR = '' " + '%'
		IF Alltrim(cBcoBrdA) == '' .or. Alltrim(cAgeBrdA) == '' .or. Alltrim(cCtaBrdA) == ''
			lRet := .F.
		ENDIF
	ELSEIF cModBrdA == '41'
		cFlAdBA := '%'+" AND SE2.E2_BANCO <> '"+cBcoBrdA+"' AND SE2.E2_CODBAR = '' " + '%'	
		IF Alltrim(cBcoBrdA) == '' .or. Alltrim(cAgeBrdA) == '' .or. Alltrim(cCtaBrdA) == ''
			lRet := .F.
		ENDIF
	ELSEIF cModBrdA == '30'
		cFlAdBA := '%'+" AND SE2.E2_CODBAR <> '' AND SUBSTRING(SE2.E2_CODBAR,1,3) = '"+cBcoBrdA+"' " + '%'	
	ELSEIF cModBrdA == '31'
		cFlAdBA := '%'+" AND SE2.E2_CODBAR <> '' AND SUBSTRING(SE2.E2_CODBAR,1,3) <> '"+cBcoBrdA+"' " + '%'	
	
	//INICIO Ticket    4883 - Abel Babini  - 08/01/2021 - Implementação de novas modalidades de pagamento
	ELSEIF cModBrdA == '13'
		cFlAdBA := '%'+" AND SE2.E2_CODBAR <> '' AND SUBSTRING(SE2.E2_CODBAR,1,2)='84' AND SE2.E2_NATUREZ IN "+cNatCON + '%'	
	ELSEIF cModBrdA == '16'
		cFlAdBA := '%'+" AND SE2.E2_CODBAR <> '' AND SUBSTRING(SE2.E2_CODBAR,1,3)='856' AND SE2.E2_NATUREZ IN "+cNatDRF + '%'	
	ELSEIF cModBrdA == '17'
		cFlAdBA := '%'+" AND SE2.E2_CODBAR <> '' AND SUBSTRING(SE2.E2_CODBAR,1,2)='81' AND SE2.E2_NATUREZ IN "+cNatGPS + '%'	
	ELSEIF cModBrdA == '11'
		cFlAdBA := '%'+" AND SE2.E2_CODBAR <> '' AND SUBSTRING(SE2.E2_CODBAR,1,3)='858' AND SE2.E2_PORTADO = '237' AND SE2.E2_NATUREZ IN "+cNatFGT + '%'	
	ELSEIF cModBrdA == '35'
		cFlAdBA := '%'+" AND SE2.E2_CODBAR <> '' AND SUBSTRING(SE2.E2_CODBAR,1,3)='858' AND SE2.E2_PORTADO IN ('341','422') AND SE2.E2_NATUREZ IN "+cNatFGT + '%'	
	ELSEIF cModBrdA == '91'
		cFlAdBA := '%'+" AND SE2.E2_CODBAR <> '' AND SUBSTRING(SE2.E2_CODBAR,1,3)='858' AND SE2.E2_NATUREZ IN "+cNatIMP + '%'	
	//FIM Ticket    4883 - Abel Babini  - 08/01/2021 - Implementação de novas modalidades de pagamento
	
	ELSE
		lRet := .F.
	ENDIF

	IF lRet
		BeginSql alias cQryVrfB
			SELECT Count(*) AS NUM
			FROM %TABLE:SE2% SE2 (NOLOCK)
			WHERE
					SE2.E2_FILIAL BETWEEN %Exp:aRet[1]% AND %Exp:aRet[2]%
				AND SE2.E2_VENCREA BETWEEN %Exp:dDtBordI% AND %Exp:dDtBordF%
				AND SE2.E2_NUMBOR = ''
				AND SE2.E2_SALDO > 0 %Exp:cFlAdBA%
				AND SE2.%notDel%
		EndSql
		(cQryVrfB)->(dbGoTop())
		IF (cQryVrfB)->NUM > 0
			lRet := .T.
		ELSE
			lRet := .F.
		ENDIF
		(cQryVrfB)->(dbCloseArea())
	ENDIF
Return lRet

//INICIO Ticket   4883 - Abel Babini - 08/12/2020 - Relatório Análise Modelo Pagamento
/*/{Protheus.doc} Static Function xRelTpPg()
	Relatório de Análise de Modelos de Pagamento.
	@type  Static Function
	@author Abel Babini Filho
	@since 18/09/2020
	@version 1
	/*/
User Function xRelTpPg
	Local oReport	:= Nil

	oReport	:= RptDef01()
	oReport:PrintDialog()	
Return

/*/{Protheus.doc} RptDef01
@description 	Definicoes do Relatorio
@author 		Abel Babini
@type 			Function
/*/
Static Function RptDef01()
	// Local oCabec	 	:= Nil
	Local cDescr	 	:= "Este programa irá imprimir o Relatório de Análise de Tipos de Pagamento por Fornecedor"
	Local cTitulo	 	:= "Relatório de Análise de Métodos de Pagamento"
	Local cAliasRep	:= GetNextAlias()
	Local cAliasDt	:= GetNextAlias()
	

	//Não é necessário perguntas / parâmetros uma vez que já possui as informações

	oReport := TReport():New("ADFIN100P_R01",cTitulo,'',{|oReport| RptPr01(oReport,@cAliasRep,@cAliasDt)},cDescr)
	oReport:SetLandscape()
	oReport:HideParamPage()

	oForn := TRSection():New(oReport,"Nota Fiscal",{(cAliasRep)},,/*Campos do SX3*/,/*Campos do SIX*/)
	oForn:SetTotalInLine(.F.)
	TRCell():New(oForn,"EA_FILIAL"	,"SEA"		,/*Titulo*/		,/*Mascara*/	,/*Tamanho*/	,/*lPixel*/	,		)
	TRCell():New(oForn,"EA_FORNECE"	,"SEA"		,/*Titulo*/		,/*Mascara*/	,/*Tamanho*/	,/*lPixel*/	,		)
	TRCell():New(oForn,"EA_LOJA"		,"SEA"		,/*Titulo*/		,/*Mascara*/	,/*Tamanho*/	,/*lPixel*/	,		)
	TRCell():New(oForn,"A2_NOME"		,"SA2"		,/*Titulo*/		,/*Mascara*/	,/*Tamanho*/	,/*lPixel*/	,		)
	TRCell():New(oForn,"EA_PREFIXO"	,"SEA"		,/*Titulo*/		,/*Mascara*/	,/*Tamanho*/	,/*lPixel*/	,		)
	TRCell():New(oForn,"EA_NUM"			,"SEA"		,/*Titulo*/		,/*Mascara*/	,/*Tamanho*/	,/*lPixel*/	,		)
	TRCell():New(oForn,"EA_PARCELA"	,"SEA"		,/*Titulo*/		,/*Mascara*/	,/*Tamanho*/	,/*lPixel*/	,		)
	TRCell():New(oForn,"EA_MODELO"	,"SEA"		,/*Titulo*/		,/*Mascara*/	,/*Tamanho*/	,/*lPixel*/	,		)
	TRCell():New(oForn,"EA_TIPOPAG"	,"SEA"		,/*Titulo*/		,/*Mascara*/	,/*Tamanho*/	,/*lPixel*/	,		)

	oItens := TRSection():New(oReport,"Modelos de Pagamento utilizados",{(cAliasRep)},,/*Campos do SX3*/,/*Campos do SIX*/)	
	oItens:SetTotalInLine(.F.)
	TRCell():New(oItens,"MODELO"		,"SEA"		,/*Titulo*/			,/*Mascara*/	,/*Tamanho*/			,/*lPixel*/	,		)
	TRCell():New(oItens,"TIPOPG"		,"SEA"		,/*Titulo*/			,/*Mascara*/	,/*TamSx3("D1_COD")[1]*/	,/*lPixel*/	,		)
	TRCell():New(oItens,"MODPERCENT",""				,/*Titulo*/			,/*Mascara*/	,/*Tamanho*/			,/*lPixel*/	,		)
	// TRCell():New(oItens,"OBSERVACAO",""				,"Observações"	,"@!"					,30						,/*lPixel*/	,		)

Return oReport

/*/{Protheus.doc} RptPr01
@description 	Definicoes do Relatorio
@author 		Abel Babini
@type 			Function
/*/
Static Function RptPr01(oReport, cAliasRep, cAliasDt)
	Local oSection1		:= oReport:Section(1)
	Local oSection2		:= oReport:Section(2)

	//Pega os fornecedores utilizados no período considerado no Painel de Pagamento
	BeginSql alias cAliasRep

		SELECT 
			SEA.EA_FILIAL, 
			SEA.EA_FORNECE, 
			SEA.EA_LOJA, 
			SA2.A2_NOME,
			SEA.EA_PREFIXO, 
			SEA.EA_NUM, 
			SEA.EA_PARCELA, 
			SEA.EA_MODELO, 
			SEA.EA_TIPOPAG
		FROM %TABLE:SEA% SEA (NOLOCK)
		INNER JOIN %TABLE:SE2% SE2 (NOLOCK) ON
			SE2.E2_FILIAL = SEA.EA_FILIAL
			AND SE2.E2_PREFIXO = SEA.EA_PREFIXO
			AND SE2.E2_NUM = SEA.EA_NUM
			AND SE2.E2_PARCELA = SEA.EA_PARCELA
			AND SE2.E2_FORNECE = SEA.EA_FORNECE
			AND SE2.E2_LOJA = SEA.EA_LOJA
			AND SE2.%notDel%
		LEFT JOIN %TABLE:SA2% SA2 (NOLOCK) ON
			SA2.A2_COD = SE2.E2_FORNECE
			AND SA2.A2_LOJA = SE2.E2_LOJA
			AND SA2.%notDel%
		WHERE 
      	  SE2.E2_FILIAL  BETWEEN %Exp:aRet[1]% AND %Exp:aRet[2]%
      AND SE2.E2_VENCREA BETWEEN %Exp:aRet[3]% AND %Exp:aRet[4]%
			AND SEA.%notDel%
		GROUP BY SEA.EA_FILIAL, SEA.EA_FORNECE, SEA.EA_LOJA, SA2.A2_NOME, SEA.EA_PREFIXO, SEA.EA_NUM, SEA.EA_PARCELA, SEA.EA_MODELO, SEA.EA_TIPOPAG
		ORDER BY EA_FORNECE, EA_LOJA
	EndSql

	oReport:SetMeter( (cAliasRep)->(RecCount()) )

	While !(cAliasRep)->( Eof() )

		oSection1:Init()
		oSection1:Cell("EA_FILIAL"	):SetValue( (cAliasRep)->EA_FILIAL	)
		oSection1:Cell("EA_FORNECE"	):SetValue( (cAliasRep)->EA_FORNECE	)
		oSection1:Cell("EA_LOJA"		):SetValue( (cAliasRep)->EA_LOJA		)
		oSection1:Cell("A2_NOME"		):SetValue( (cAliasRep)->A2_NOME		)
		oSection1:Cell("EA_PREFIXO"	):SetValue( (cAliasRep)->EA_PREFIXO	)
		oSection1:Cell("EA_NUM"			):SetValue( (cAliasRep)->EA_NUM			)
		oSection1:Cell("EA_PARCELA"	):SetValue( (cAliasRep)->EA_PARCELA	)
		oSection1:Cell("EA_MODELO"	):SetValue( xRetModP( (cAliasRep)->EA_MODELO )	)
		oSection1:Cell("EA_TIPOPAG"	):SetValue( xRetTipP( (cAliasRep)->EA_TIPOPAG )	)
		oSection1:PrintLine() 
		oSection1:Finish()

		BeginSql Alias cAliasDt
			SELECT EA_MODELO, EA_TIPOPAG, CAST(COUNT(*) AS DECIMAL(5,2))/10*100 AS OCORR_PERCENT
			FROM (
			SELECT TOP 10 SEA.EA_MODELO, SEA.EA_TIPOPAG
			FROM %TABLE:SEA% SEA (NOLOCK)
			WHERE 
				SEA.EA_FILIAL = %Exp:(cAliasRep)->EA_FILIAL%
				AND SEA.EA_FORNECE = %Exp:(cAliasRep)->EA_FORNECE%
				AND SEA.EA_LOJA = %Exp:(cAliasRep)->EA_LOJA%
				AND SEA.%notDel%
			ORDER BY SEA.EA_DATABOR DESC
			) AS RES
			GROUP BY EA_MODELO, EA_TIPOPAG
		EndSql

		While !(cAliasDt)->(Eof())

			oSection2:Init()
			oSection2:Cell("MODELO"	):SetValue( xRetModP((cAliasDt)->EA_MODELO)	)
			oSection2:Cell("TIPOPG"	):SetValue( xRetTipP((cAliasDt)->EA_TIPOPAG)	)
			oSection2:Cell("MODPERCENT"		):SetValue( (cAliasDt)->OCORR_PERCENT		)
			// oSection2:Cell("OBSERVACAO"	):SetValue( '' )
			oSection2:PrintLine() 
			
			(cAliasDt)->(DbSkip())
		EndDo
		oSection2:Finish() 

		(cAliasDt)->(DbCloseArea())

		(cAliasRep)->(DbSkip())

	EndDo
	
	(cAliasRep)->(DbCloseArea())

Return Nil

Static Function xRetModP(cMod)
	Local cDescMod	:= cMod
	Local aModPg	:= {}
	Local i

	Aadd( aModPg, {'01','CREDITO EM CONTA CORRENTE'})
	Aadd( aModPg, {'02','CHEQUE PAGAMENTO/ADMINISTRATIVO'})
	Aadd( aModPg, {'03','DOC'})
	Aadd( aModPg, {'04','OP A DISPOSICAO COM AVISO PARA O FAVORECIDO'})
	Aadd( aModPg, {'05','CREDITO EM CONTA POUPANCA'})
	Aadd( aModPg, {'10','OP `A DISPOSICAO SEM AVISO PARA O FAVORECIDO'})
	Aadd( aModPg, {'11','PAGAMENTO DE CONTAS E TRIBUTOS COM CODIGO DE BARRAS'})
	Aadd( aModPg, {'13','PAGAMENTO A CONCESSIONARIAS'})
	Aadd( aModPg, {'16','PAGAMENTO DE TRIBUTOS - DARF NORMAL'})
	Aadd( aModPg, {'17','PAGAMENTO DE TRIBUTOS - GPS'})
	Aadd( aModPg, {'18','PAGAMENTO DE TRIBUTOS - DARF SIMPLES'})
	Aadd( aModPg, {'21','PAGAMENTO DE TRIBUTOS - DARJ'})
	Aadd( aModPg, {'22','TRIBUTOS'})
	Aadd( aModPg, {'23','PAGAMENTO DE TRIBUTOS - GARE DARE'})
	Aadd( aModPg, {'30','LIQUIDACAO DE TITULOS DO PROPRIO BANCO'})
	Aadd( aModPg, {'31','PAGAMENTO DE TITULOS EM OUTRO BANCO'})
	Aadd( aModPg, {'35','FGTS – GFIP'})
	Aadd( aModPg, {'41','TED - Outro Titular'})
	Aadd( aModPg, {'43','TED - Mesmo titular'})
	Aadd( aModPg, {'58','TITULOS SEM BORDERO'})
	Aadd( aModPg, {'91','GNRE E TRIBUTOS COM CODIGO DE BARRAS'})
	Aadd( aModPg, {'99','RH'})

	For i := 1 to Len(aModPg)
		IF aModPg[i,1] == cMod
			cDescMod := aModPg[i,1] +' - '+aModPg[i,2]
			EXIT
		ENDIF
	Next i

Return cDescMod

Static Function xRetTipP(cTip)
	Local cDescTip	:= cTip
	Local aTipPg	:= {}
	Local i

	Aadd( aTipPg, {'05','CREDITO EM POUPANCA'})
	Aadd( aTipPg, {'10','PAGAMENTO DIVIDENDOS'})
	Aadd( aTipPg, {'15','DEBENTURES'})
	Aadd( aTipPg, {'20','PAGAMENTO FORNECEDORES'})
	Aadd( aTipPg, {'22','TRIBUTOS'})
	Aadd( aTipPg, {'30','PAGAMENTO SALARIOS'})
	Aadd( aTipPg, {'40','PAGAMENTO FUNDOS DE INVESTIMENTOS'})
	Aadd( aTipPg, {'50','PAGAMENTO SINISTROS SEGURADOS'})
	Aadd( aTipPg, {'60','PAGAMENTO DESPESAS VIAJANTE EM TRANSITO'})
	Aadd( aTipPg, {'80','PAGAMENTO REPRESENTANTES/VENDEDORES AUTORIZADOS'})
	Aadd( aTipPg, {'90','PAGAMENTO BENEFICIOS'})
	Aadd( aTipPg, {'98','PAGAMENTO DIVERSOS'})


	For i := 1 to Len(aTipPg)
		IF aTipPg[i,1] == cTip
			cDescTip := aTipPg[i,1] +' - '+aTipPg[i,2]
			EXIT
		ENDIF
	Next i

Return cDescTip
//FIM Ticket   4883 - Abel Babini - 08/12/2020 - Relatório Análise Modelo Pagamento
