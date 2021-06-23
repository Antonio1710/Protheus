#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE nBtnAlt 16

/*/{Protheus.doc} User Function ADFIN109P()
  Tela de acompanhamento e liberação de Crédito de pedidos bloqueados
  @type  Function
  @author Abel Babini
  @since 01/03/2021
  @history Ticket 8      - Abel Babini - 01/03/2021 - Versão inicial
	@history Ticket 8      - Abel Babini - 11/05/2021 - Inclusão da Liberação de Estoque.
	/*/

User Function ADFIN109P()
  Local aArea := GetArea()

  U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de aprovação de crédito de pedidos bloquedos')

  If VerSenha(136)
      fTlAprov()
  Else
	  HELP(" ",1,"SEMPERM")
  Endif

  RestArea(aArea)
Return

/*/{Protheus.doc} User Function fTlAprov
  Função para monstar a tela
  @type  Function
  @author Abel Babini
  @since 01/03/2021
	/*/
Static Function fTlAprov()
  //Variáveis para definição do tamanho da tela
  Local aSize   		:= 	MsAdvSize(nil,.f.,370)
  Local nAltu			  :=	aSize[4]
	Local aObjects    := {}
  Local aPosObj     := {}
  Local aInfo   	  := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}

	//Painel Principal
	Local cEsq
	Local cDir
	Local oTela
  Local oPanelE
  Local oTelaE

  Local oDlgxPg
  Local oFWLSt01
  Local oPnSt01

  Local cPedDe	:= space(6)
  Local cPedAte	:= 'ZZZZZZ'
  Local cCliDe	:= space(6)
  Local cLojDe	:= space(2)
	Local cCliAte	:= 'ZZZZZZ'
  Local cLojAte	:= 'ZZ'
	Local cRedDe	:= space(6)
  Local cRedAte	:= 'ZZZZZZ'


  Local aFolder  := {}
  Local oFolder
  Local cFld02  := 'Liberação'
  Local cFld03  := 'Indicadores'
  Local nLargPE := 16

  // Local aItems := {'Antecipado','Rede','Varejo','Todos'}
  // Local nRadio := 4
  // Local nGrafico := BARCOMPCHART

	Local aBtnPos := {}

	Local aMotLib := {}
	Local oMotLib
	Local nMotLib := 0

	// Private dDtIni 	:= CtoD('01/01/2021')
  // Private dDtFim 	:= CtoD('31/01/2021')
	Private lTESTE := .F.
	Private dDtIni 	:= date()+1
  Private dDtFim 	:= date()+1

	Private oFont000	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	Private oFont001	:= TFont():New( "Arial",,14,,.f.,,,,,.f. )
	Private oFont002	:= TFont():New( "Arial",,15,,.T.,,,,,.f. )
	Private oFont003	:= TFont():New( "Arial",,16,,.T.,,,,,.f. )
	Private oFont004	:= TFont():New( "Arial",,18,,.T.,,,,,.f. )
	// Private oFont003	:= TFont():New( "Arial",,18,,.T.,,,,,.f. )

  //VARIÁVEIS TOTALIZADOS NO PAINEL	
  Private nVlRdBl := 0
  Private nVlRdLb := 0
  Private nVlRdNP := 0
  Private nVlRdTt := 0

  Private nVlVjBl := 0
  Private nVlVjLb := 0
  Private nVlVjNP := 0
  Private nVlVjTt := 0

  Private nVlTtBl := 0
  Private nVlTtLb := 0
  Private nVlTtNP := 0
  Private nVlTtTt := 0

	Private aX3Fil	:= FWTamSX3("C5_FILIAL")
	Private aX3CdRd	:= FWTamSX3("ZF_REDE")
	Private aX3NmRd	:= FWTamSX3("ZF_NOMERED")
	Private aX3Clie	:= FWTamSX3("C5_CLIENTE")
	Private aX3Loja	:= FWTamSX3("C5_LOJACLI")
	Private aX3NomC	:= FWTamSX3("C5_NOMECLI")
	Private aX3TotP	:= FWTamSX3("C5_XTOTPED")
	Private aX3NumP := {7 , 0, "N"}
	Private aX3TpCl	:= {6 , 0, "C"}
	Private aX3TpBl	:= {20 , 0, "C"}
  Private aX3DscBl:= {254, 0, "C"}

	Private aX3BlMt	:= FWTamSX3("ZBH_MOTIVO")
	Private aX3BlCV	:= FWTamSX3("ZBH_CODVEN")
	Private aX3BlNV	:= FWTamSX3("ZBH_NOMVEN")

  Private aX3PdNum:= FWTamSX3("C5_NUM")
	Private aX3PdTp	:= FWTamSX3("C5_TIPO")
	Private aX3PdRot:= FWTamSX3("C5_ROTEIRO")
	Private aX3PdCp	:= FWTamSX3("C5_CONDPAG")
	Private aX3PdCtr:= FWTamSX3("E4_CTRADT")
	Private aX3PdEnt:= FWTamSX3("C5_DTENTR")
	Private aX3PdEmi:= FWTamSX3("C5_EMISSAO")
	Private aX3PdNf	:= FWTamSX3("C5_NOTA")
	Private aX3PdXPA:= FWTamSX3("C5_XPREAPR")
	Private aX3PdXCp:= FWTamSX3("C5_XCOPIA")
	Private aX3PdRft:= FWTamSX3("C5_REFATUR")
	Private aX3PdFlg:= FWTamSX3("C5_FLAGFIN")
	
	Private aX3A1LCr:= FWTamSX3("A1_LC")
	Private aX3A1Rsc:= FWTamSX3("A1_XRISCO")
	Private aX3A1DAt:= FWTamSX3("A1_XDTRISC")
	Private aX3A1DUC:= FWTamSX3("A1_DTULTRE")
	Private aX3A1DMC:= FWTamSX3("A1_DTACUMU")
	Private aX3A1VMA:= FWTamSX3("A1_VLACUMU")

	Private oGrd10
	Private oGrd20
	Private oGrd30
	Private oRelGr12
	Private oRelGr23
	Private cTbClie	:= GetNextAlias()
  Private oTbClie
  Private cTbPed	:= GetNextAlias()
  Private oTbPed
  Private cTbBlq	:= GetNextAlias()
  Private oTbBlq
	
  Private oFWLr02
  Private oP02D101
  Private oP02D102
  Private oP02D201
  Private oP02D202

	Private oP02RE01

	Private cParecer := space(240)
	Private cMotLib := ''

	Private lMkPed := .F.

	cMotLib		:= ''

	SX5->(dbSetOrder(1))
	SX5->(dbGotop())
	IF SX5->(dbSeek(xFilial("SX5")+'_Z'))
		WHILE !SX5->(eof()) .AND. SX5->X5_TABELA == '_Z'
			AADD(aMotLib,SX5->X5_CHAVE+' - '+ALLTRIM(SX5->X5_DESCRI))
			SX5->(dbSkip())
		ENDDO
	ELSE
		Aviso(	"ADFIN109-01",;
						"Não será possível realizar liberação até que exista pelo menos 1 motivo de liberação cadastrado no sistema!",;
						{ "&OK" },,;
						"Aprovação Varejo" )
	ENDIF
	
	//Posicão (linha) dos botões de funções
	AADD(aBtnPos,nAltu - 040)//1
	AADD(aBtnPos,nAltu - 040 - (nBtnAlt*1))//2
	AADD(aBtnPos,nAltu - 040 - (nBtnAlt*2))//3
	AADD(aBtnPos,nAltu - 040 - (nBtnAlt*3))//4
	AADD(aBtnPos,nAltu - 040 - (nBtnAlt*4))//5
	AADD(aBtnPos,nAltu - 040 - (nBtnAlt*5))//6
	AADD(aBtnPos,nAltu - 040 - (nBtnAlt*6))//7
	AADD(aBtnPos,nAltu - 040 - (nBtnAlt*7))//8
	AADD(aBtnPos,nAltu - 040 - (nBtnAlt*8))//9

	IF lTESTE == .T.
		dDtIni 	:= CtoD('01/01/2021')
  	dDtFim 	:= CtoD('31/01/2021')
	ENDIF

  oDlgxPg := MSDialog():New (aSize[7],0, aSize[6],aSize[5], "Liberação de Crédito" ,,, .F.,,,,,, .T.,,, .T. )

    //**********************************************
    //ESTRUTURA DA JANELA  
    //**********************************************
    oDlgxPg:lEscClose 	:= 	.f.
    oDlgxPg:lMaximized := 	.t. 

    // nLargPE := Round(275 / aSize[5] * 100,0)
		nLargPE := Round(200 / aSize[5] * 100,0)

    oTela 	:= 	FwFormContainer():New( oDlgxPg )
		cEsq		:= 	oTela:CreateVerticalBox( nLargPE )
		cDir  	:= 	oTela:CreateVerticalBox( 100-nLargPE )
		oTela:Activate( oDlgxPg , .f. )

		oPanelE		:= 	oTela:GetPanel( cEsq )
		oTelaE		:= 	FwFormContainer():New( oPanelE )
		cSupE    	:= 	oTelaE:CreateHorilontalBox( 50 )
		oTelaE:Activate( oPanelE , .f. )

		oPanelD		:= 	oTela:GetPanel( cDir )
		oTelaD		:= 	FwFormContainer():New( oPanelD )
		cSupD    	:= 	oTelaE:CreateHorilontalBox( 50 )
		// cInfE     	:= 	oTelaE:CreateHorilontalBox( 30 )
		oTelaD:Activate( oPanelD , .f. )

    //**********************************************
    //PAINEL DIREITO
    //**********************************************


    AADD(aObjects,{nLargPE,aSize[4],.F.,.T.,.F.})
    AADD(aObjects,{nLargPE,aSize[4],.T.,.T.,.T.})
    aPosObj:=MsObjSize(aInfo,aObjects)
    
    aFolder  := {cFld02,cFld03}
    
    oFolder:=TFolder():New(0,aPosObj[2,2],aFolder,{},oPanelD,,,, .T., .F.,aPosObj[2,3]-aPosObj[1,3]/2-18,aSize[4],)

    //**********************************************
    //PAINEL ESQUERDO
    //**********************************************
		oFWLSt01	:=	FwLayer():New()
		oFWLSt01:Init(oPanelE,.t.)   
		oFWLSt01:AddCollumn('ColES',100,.f.)
		oFWLSt01:AddWindow('ColES','Win01',"Status",98,.f.,.t.,/*{ || }*/,,/*{ || }*/) 
		oPnSt01	:= 	oFWLSt01:GetWinPanel('ColES','Win01')
		oPnSt01:FreeChildren()

		@ 001,000 TO 132,089 OF oPnSt01 PIXEL
		// @ 001,000 TO 132,129 OF oPnSt01 PIXEL
		@ 002,001 SAY OemToAnsi("Parâmetros")			FONT oFont002 SIZE 200,15 OF oPnSt01 PIXEL

		@ 012,003 SAY OemToAnsi("Dt Entrega De")	FONT oFont001 SIZE 200,18 OF oPnSt01 PIXEL
		@ 024,003 SAY OemToAnsi("Dt Entrega Até")	FONT oFont001 SIZE 200,18 OF oPnSt01 PIXEL
    @ 011,045 MSGET dDtIni									SIZE 035,008 	OF oPnSt01 PIXEL PICTURE '@D'
    @ 023,045 MSGET dDtFim									SIZE 035,008 	OF oPnSt01 PIXEL PICTURE '@D'
    
		@ 036,003 SAY OemToAnsi("Pedido De")	FONT oFont001 SIZE 200,18 OF oPnSt01 PIXEL
		@ 048,003 SAY OemToAnsi("Pedido Até")	FONT oFont001 SIZE 200,18 OF oPnSt01 PIXEL
    @ 035,045 MSGET cPedDe									SIZE 035,008 	OF oPnSt01 PIXEL PICTURE '@D' F3 "SC5"
    @ 047,045 MSGET cPedate									SIZE 035,008 	OF oPnSt01 PIXEL PICTURE '@D' F3 "SC5"

		@ 060,003 SAY OemToAnsi("Cliente De")		FONT oFont001 SIZE 200,18 OF oPnSt01 PIXEL
		@ 072,003 SAY OemToAnsi("Loja De")			FONT oFont001 SIZE 200,10 OF oPnSt01 PIXEL
    @ 059,045 MSGET cCliDe									SIZE 035,008 	OF oPnSt01 PIXEL PICTURE '@!' F3 "SA1"
    @ 071,045 MSGET cLojDe									SIZE 035,008 	OF oPnSt01 PIXEL PICTURE '@!'
    
		@ 084,003 SAY OemToAnsi("Cliente Até")	FONT oFont001 SIZE 200,18 OF oPnSt01 PIXEL
		@ 096,003 SAY OemToAnsi("Loja Até")			FONT oFont001 SIZE 200,10 OF oPnSt01 PIXEL
    @ 083,045 MSGET cCliAte									SIZE 035,008 	OF oPnSt01 PIXEL PICTURE '@!' F3 "SA1"
    @ 095,045 MSGET cLojAte									SIZE 035,008 	OF oPnSt01 PIXEL PICTURE '@!'

		@ 108,003 SAY OemToAnsi("Rede De")			FONT oFont001 SIZE 200,18 OF oPnSt01 PIXEL
		@ 120,003 SAY OemToAnsi("Rede Até")			FONT oFont001 SIZE 200,18 OF oPnSt01 PIXEL
    @ 107,045 MSGET cRedDe									SIZE 035,008 	OF oPnSt01 PIXEL PICTURE '@!' F3 "SZF"
    @ 119,045 MSGET cRedAte									SIZE 035,008 	OF oPnSt01 PIXEL PICTURE '@!' F3 "SZF"

		@ aBtnPos[7],000 BUTTON OemToAnsi('Filtrar')									SIZE 085,nBtnAlt FONT oPnSt01:oFont ACTION (xReStart(cPedDe, cPedAte, cCliDe, cLojDe, cCliAte, cLojAte, cRedDe, cRedAte)) OF oPnSt01 PIXEL //"Exportar Excel"
		@ aBtnPos[6],000 BUTTON OemToAnsi('Libera Pedido')						SIZE 085,nBtnAlt FONT oPnSt01:oFont ACTION (MsAguarde({|| xAprvPed() },"Aguarde","Liberando o Pedido de venda...")) 			OF oPnSt01 PIXEL //"Exportar Excel"
		@ aBtnPos[5],000 BUTTON OemToAnsi('Posição do Cliente')				SIZE 085,nBtnAlt FONT oPnSt01:oFont ACTION (PosicCli((cTbPed)->CODIGO,(cTbPed)->LOJA)) 																		OF oPnSt01 PIXEL //"Exportar Excel"
		@ aBtnPos[4],000 BUTTON OemToAnsi('Liberação de Estoque')			SIZE 085,nBtnAlt FONT oPnSt01:oFont ACTION (xFcLbEst(cPedDe, cPedAte, cCliDe, cLojDe, cCliAte, cLojAte, cRedDe, cRedAte)) OF oPnSt01 PIXEL //"Exportar Excel"
		// @ aBtnPos[3],000 BUTTON OemToAnsi('Painel Contas á Receber')	SIZE 085,nBtnAlt FONT oPnSt01:oFont ACTION (U_ADFIN030P()) 																																OF oPnSt01 PIXEL //"Exportar Excel"
		// @ aBtnPos[3],000 BUTTON OemToAnsi('Rel. Rede Segmento')				SIZE 085,nBtnAlt FONT oPnSt01:oFont ACTION (StaticCall(ADFIN071R,geraRelatorio,nil,nil,nil,nil)) 																																OF oPnSt01 PIXEL //"Exportar Excel"
		@ aBtnPos[3],000 BUTTON OemToAnsi('Rel. Rede Segmento')				SIZE 085,nBtnAlt FONT oPnSt01:oFont ACTION (xRlRdSeg()) 																																OF oPnSt01 PIXEL //"Exportar Excel"
		@ aBtnPos[2],000 BUTTON OemToAnsi('Excluir Pedido')						SIZE 085,nBtnAlt FONT oPnSt01:oFont ACTION (xDelSC5()) 																																		OF oPnSt01 PIXEL //"Exportar Excel"
		@ aBtnPos[1],000 BUTTON OemToAnsi('Sair')											SIZE 085,nBtnAlt FONT oPnSt01:oFont ACTION (oDlgxPg:End()) 																																OF oPnSt01 PIXEL //"Exportar Excel"

    // oTBtn010	:=	tButton():New(aBtnPos[7], 000 ,"Filtrar"		  						,oPnSt01,{ || xReStart(cPedDe, cPedAte, cCliDe, cLojDe, cCliAte, cLojAte, cRedDe, cRedAte) },085,nBtnAlt,,,.f.,.t.,.f.,,.f.,,,.f.)
    // oTBtn020	:=	tButton():New(aBtnPos[6], 000 ,"Aprovar"		  						,oPnSt01,{ || MsAguarde({|| xAprvPed() },"Aguarde","Liberando o Pedido de venda...") },085,nBtnAlt,,,.f.,.t.,.f.,,.f.,,,.f.)
		// oTBtn030	:=	tButton():New(aBtnPos[5], 000 ,"Posição do Cliente"				,oPnSt01,{ || PosicCli((cTbPed)->CODIGO,(cTbPed)->LOJA) },085,nBtnAlt,,,.f.,.t.,.f.,,.f.,,,.f.)
		// oTBtn030	:=	tButton():New(aBtnPos[4], 000 ,"Liberação de Estoque"			,oPnSt01,{ || xFcLbEst(cPedDe, cPedAte, cCliDe, cLojDe, cCliAte, cLojAte, cRedDe, cRedAte) },085,nBtnAlt,,,.f.,.t.,.f.,,.f.,,,.f.)
		// oTBtn040	:=	tButton():New(aBtnPos[3], 000 ,"Painel Contas á Receber "	,oPnSt01,{ || U_ADFIN030P() },085,nBtnAlt,,,.f.,.t.,.f.,,.f.,,,.f.)
    // oTBtn090	:=	tButton():New(aBtnPos[2], 000 ,"Excluir Pedido"		  			,oPnSt01,{ || xDelSC5() },085,nBtnAlt,,,.f.,.t.,.f.,,.f.,,,.f.)
    // oTBtn999	:=	tButton():New(aBtnPos[1], 000 ,"Sair"		  								,oPnSt01,{ || oDlgxPg:End() },085,nBtnAlt,,,.f.,.t.,.f.,,.f.,,,.f.)
		//oWorkFat  := TButton():New(223,005,"Rel Faturamento Rede Segmento",oTelMenu,{|| U_ADFIN071R() },111,nBtnAlt,,,.F.,.T.,.F.,,.F.,,,.F. ) //William Costa - 08/01/2019 Chamado:045047
		
    //**********************************************
    //ABA LIBERAÇÃO
    //**********************************************
			oFWLr02	:= FWLayer():New()
			oFWLr02:Init( oFolder:aDialogs[1], .F., .T.)

			//Define os Paineis
			//TITULO
			oFWLr02:AddLine ('TIT_DET', 3, .F.)
			oFWLr02:AddCollumn('TIT_ESQ',50,.F.,'TIT_DET')
			oFWLr02:AddCollumn('TIT_DIR',50,.F.,'TIT_DET')

			oFWLr02:AddLine ('DET1', 57, .F.)
			oFWLr02:AddCollumn('DET_ESQ1',049,.F.,'DET1')
			oFWLr02:AddCollumn('DET_DIR1',051,.F.,'DET1')

			oFWLr02:AddLine ('DET2', 35, .F.)
			oFWLr02:AddCollumn('DET_ESQ2',060,.F.,'DET2')
			oFWLr02:AddCollumn('DET_DIR2',040,.F.,'DET2')

			oFWLr02:AddLine ('RESUMO', 5, .F.)
			oFWLr02:AddCollumn('RES_ESQ',100,.F.,'RESUMO')

			oP02TE01	:= oFWLr02:GetColPanel('TIT_ESQ','TIT_DET')
			oP02TD01	:= oFWLr02:GetColPanel('TIT_DIR','TIT_DET')

			oP02D101	:= oFWLr02:GetColPanel('DET_ESQ1','DET1')
			oP02D102	:= oFWLr02:GetColPanel('DET_DIR1','DET1')

			oP02D201	:= oFWLr02:GetColPanel('DET_ESQ2','DET2')
			oP02D202	:= oFWLr02:GetColPanel('DET_DIR2','DET2')

			oP02RE01	:= oFWLr02:GetColPanel('RES_ESQ','RESUMO')

			oP02TE01:FreeChildren()
			oP02TD01:FreeChildren()

			oP02D101:FreeChildren()
			oP02D102:FreeChildren()

			oP02D201:FreeChildren()
			oP02D202:FreeChildren()

			oP02RE01:FreeChildren()

			@ 001,001 SAY OemToAnsi("LIBERAÇÃO DE CRÉDITO DE PEDIDOS DE VENDA")	FONT oFont004 SIZE 200,15 OF oP02TE01 PIXEL

			// @ 001,004 TO 022,420 OF oP02RE01 PIXEL
			@ 003,010 SAY OemToAnsi("Motivo Liberação:")				 SIZE 140,15 PIXEL OF oP02RE01  FONT oFont002
			@ 011,010 COMBOBOX oMotLib VAR cMotLib ITEMS aMotLib SIZE 110,08 PIXEL OF oP02RE01 ON CHANGE nMotLib := oMotLib:nAt 
			@ 003,130 SAY OemToAnsi('Parecer da Liberação do Pedido')		SIZE 100,025 	OF oP02RE01 COLORS 0, 16777215 PIXEL FONT oFont002
			@ 011,130 MSGET cParecer	SIZE 285,008 	OF oP02RE01 PIXEL PICTURE '@!'

    //**********************************************
    //ABA INDICADORES
    //**********************************************
			oFWLr03	:= FWLayer():New()
			oFWLr03:Init( oFolder:aDialogs[2], .F., .T.)

			//Define os Paineis
			//TITULO
			oFWLr03:AddLine ('TIT_DET', 6, .F.)
			oFWLr03:AddCollumn('TIT_ESQ',100,.F.,'TIT_DET')

			oFWLr03:AddLine ('DETALHE1', 60, .F.)
			oFWLr03:AddCollumn('DET_ESQ1',100,.F.,'DETALHE1')

			oFWLr03:AddLine ('RESUMO', 34, .F.)
			oFWLr03:AddCollumn('RES_ESQ',100,.F.,'RESUMO')

			oP03TE01	:= oFWLr03:GetColPanel('TIT_ESQ','TIT_DET')
			oP03D101	:= oFWLr03:GetColPanel('DET_ESQ1','DETALHE1')
			oP03RE01	:= oFWLr03:GetColPanel('RES_ESQ','RESUMO')

			oP03TE01:FreeChildren()
			oP03D101:FreeChildren()
			oP03RE01:FreeChildren()

			// @ 001,001 SAY OemToAnsi("PARÂMETROS")	FONT oFont004 SIZE 200,15 OF oP03TE01 PIXEL
			// Prepara o conector WebSocket
			Private oWebChannel := TWebChannel():New()
			Private nPort := oWebChannel::connect()
			Private oWebEngine := TWebEngine():New(oP03D101, 0, 0, 100, 100,, nPort)
			
			// Cria componente
			
			oWebEngine:bLoadFinished := {|self,url| }
			oWebEngine:navigate("https://app.powerbi.com/groups/me/dashboards/543b7ce9-8439-4bfe-9a9d-ddf7dc9f4a3f")
			oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT

  	xReStart(cPedDe, cPedAte, cCliDe, cLojDe, cCliAte, cLojAte, cRedDe, cRedAte)

  Activate MsDialog oDlgxPg Centered 
	
	IF oTbClie != NIL
		oTbClie:Delete() 
	ENDIF

	IF oTbPed != NIL
		oTbPed:Delete() 
	ENDIF

	IF oTbBlq != NIL
		oTbBlq:Delete() 
	ENDIF

Return

/*/{Protheus.doc} User Function xTlCons
	Exibe a Tela com o totalizador de pedidos liberados e bloqueados.
	@type  Function
	@author user
	@since 29/01/2021
	@version version
	/*/
Static Function xTotPeds(cPedDe, cPedAte, cCliDe, cLojDe, cCliAte, cLojAte, cRedDe, cRedAte)
	// Local nOpt := 2
  Local cQuery := GetNextAlias()
	// Local cQryC6
	Local cQryBlq
	// Local _cCdClIn := '%'+''+'%'

  nVlRdBl := 0
  nVlRdLb := 0
  nVlRdNP := 0
  nVlRdTt := 0

  nVlVjBl := 0
  nVlVjLb := 0
  nVlVjNP := 0
  nVlVjTt := 0

  nVlTtBl := 0
  nVlTtLb := 0
  nVlTtNP := 0
  nVlTtTt := 0

  BeginSQL alias cQuery
		column C5_DTENTR as Date
		column C5_EMISSAO as Date
		column A1_XDTRISC as Date
		column A1_DTULTRE as Date
		column A1_DTACUMU as Date
    SELECT 
      SC5.C5_FILIAL,
      SC5.C5_NUM,
      SC5.C5_TIPO,
      SC5.C5_CLIENTE,
      SC5.C5_LOJACLI,
      SC5.C5_NOMECLI,
			SA1.A1_CODRED,
			SA1.A1_XRISCO,
			SA1.A1_XDTRISC,
			SA1.A1_DTULTRE,
			SA1.A1_DTACUMU,
			SA1.A1_VLACUMU,
			SA1.A1_LC,
			ISNULL(SZF.ZF_NOMERED,'') AS ZF_NOMERED,
      SC5.C5_ROTEIRO,
      SC5.C5_CONDPAG,
      SE4.E4_CTRADT,
      SC5.C5_DTENTR,
      SC5.C5_EMISSAO,
      SC5.C5_NOTA,
      SC5.C5_XPREAPR,
      SC5.C5_XCOPIA,
      SC5.C5_REFATUR,
      SC5.C5_FLAGFIN,
			SUM((C6_QTDVEN - C6_QTDENT) * C6_PRCVEN) AS C5_XTOTPED
    FROM %TABLE:SC5% SC5 (NOLOCK)
		INNER JOIN %TABLE:SC6% SC6 (NOLOCK) ON
			SC6.C6_FILIAL = SC5.C5_FILIAL
			AND SC6.C6_NUM = SC5.C5_NUM
			AND SC6.C6_CLI = SC5.C5_CLIENTE
			AND SC6.C6_LOJA = SC5.C5_LOJACLI
			AND SC6.%notDel%
    INNER JOIN %TABLE:SE4% SE4 (NOLOCK) ON
			E4_FILIAL = %xFilial:SE4%
      AND E4_CODIGO = C5_CONDPAG
      AND SE4.%notDel%
    INNER JOIN %TABLE:SA1% SA1 (NOLOCK) ON
			A1_FILIAL = %xFilial:SA1%
      AND A1_COD = C5_CLIENTE
			AND A1_LOJA = C5_LOJACLI
      AND SA1.%notDel%
    LEFT JOIN %TABLE:SZF% SZF (NOLOCK) ON
			ZF_FILIAL = %xFilial:SZF%
      AND ZF_CGCMAT = SUBSTRING(A1_CGC,1,8)
      AND SZF.%notDel%
    WHERE C5_FILIAL = %xFilial:SC5%
			AND SC5.C5_DTENTR BETWEEN %Exp:DTOS(dDtIni)% AND %Exp:DTOS(dDtFim)%
			AND SC5.C5_NUM BETWEEN %Exp:cPedDe% AND %Exp:cPedAte%
			AND SC5.C5_CLIENTE BETWEEN %Exp:cCliDe% AND %Exp:cCliAte%
			AND SC5.C5_LOJACLI BETWEEN %Exp:cLojDe% AND %Exp:cLojAte%
			AND SA1.A1_CODRED BETWEEN %Exp:cRedDe% AND %Exp:cRedAte%
			AND C5_NOTA = ''
			AND C5_TIPO = 'N'
			AND SC5.%notDel%
		GROUP BY 
			SC5.C5_FILIAL,
      SC5.C5_NUM,
      SC5.C5_TIPO,
      SC5.C5_CLIENTE,
      SC5.C5_LOJACLI,
      SC5.C5_NOMECLI,
			SA1.A1_CODRED,
			SA1.A1_LC,
			SA1.A1_XRISCO,
			SA1.A1_XDTRISC,
			SA1.A1_DTULTRE,
			SA1.A1_DTACUMU,
			SA1.A1_VLACUMU,
			ZF_NOMERED,
      SC5.C5_ROTEIRO,
      SC5.C5_CONDPAG,
      SE4.E4_CTRADT,
      SC5.C5_DTENTR,
      SC5.C5_EMISSAO,
      SC5.C5_NOTA,
      SC5.C5_XPREAPR,
      SC5.C5_XCOPIA,
      SC5.C5_REFATUR,
      SC5.C5_FLAGFIN
  EndSQL

	(cQuery)->(dbGoTop())
  While !(cQuery)->(eof())

    // IF (cQuery)->E4_CTRADT == '1' //ANTECIPADO
    IF Alltrim((cQuery)->C5_XPREAPR) == 'B'
      nVlTtBl += 1
    ELSEIF Alltrim((cQuery)->C5_XPREAPR) == 'L'
    	nVlTtLb += 1
    ELSEIF Alltrim((cQuery)->C5_XPREAPR) == ''
      nVlTtNP	+= 1
    ENDIF

		//A condição lTESTE foi criada exclusivamente para testes durante o desenvolvimento da rotina.
		IF Alltrim((cQuery)->C5_XPREAPR) == 'B' .OR. lTESTE

			IF !(cTbClie)->(DbSeek((cQuery)->C5_FILIAL+'REDE  '+(cQuery)->A1_CODRED)) .AND. !Empty(Alltrim((cQuery)->A1_CODRED))

				RECLOCK(cTbClie,.T.)      
					(cTbClie)->RELACAO:= (cQuery)->C5_FILIAL+'REDE  '+(cQuery)->A1_CODRED
					(cTbClie)->FILIAL := (cQuery)->C5_FILIAL
					(cTbClie)->CODIGO := (cQuery)->A1_CODRED
					(cTbClie)->LOJA   := ''
					(cTbClie)->NOME 	:= (cQuery)->ZF_NOMERED
					(cTbClie)->TOTAL  := (cQuery)->C5_XTOTPED
					(cTbClie)->NUMPED	:= 1
					(cTbClie)->TPCLI  := 'REDE  '
					(cTbClie)->TPBLOQ := Alltrim((cQuery)->C5_XPREAPR)
					/*
						1 - FATURADO
						2 - BLOQUEIO DE CREDITO
						3 - BLOQUEIO DE ESTOQUE
					*/
					(cTbClie)->DSCREGRA := ''


					(cTbClie)->XRISCO := (cQuery)->A1_XRISCO
					(cTbClie)->XDTRISC := (cQuery)->A1_XDTRISC
					(cTbClie)->DTULTRE := (cQuery)->A1_DTULTRE
					(cTbClie)->DTACUMU := (cQuery)->A1_DTACUMU
					(cTbClie)->VLACUMU := (cQuery)->A1_VLACUMU

				(cTbClie)->(MSUNLOCK())

			ELSEIF Empty(Alltrim((cQuery)->A1_CODRED)) .AND. !(cTbClie)->(DbSeek((cQuery)->C5_FILIAL+'VAREJO'+(cQuery)->C5_CLIENTE+(cQuery)->C5_LOJACLI))

				RECLOCK(cTbClie,.T.)      
					(cTbClie)->RELACAO			:= (cQuery)->C5_FILIAL+'VAREJO'+(cQuery)->C5_CLIENTE+(cQuery)->C5_LOJACLI
					(cTbClie)->FILIAL   := (cQuery)->C5_FILIAL
					(cTbClie)->CODIGO   := (cQuery)->C5_CLIENTE
					(cTbClie)->LOJA   := (cQuery)->C5_LOJACLI
					(cTbClie)->NOME   := (cQuery)->C5_NOMECLI
					(cTbClie)->TOTAL    := (cQuery)->C5_XTOTPED
					(cTbClie)->NUMPED		:= 1
					(cTbClie)->TPCLI    := 'VAREJO'
					(cTbClie)->TPBLOQ   := Alltrim((cQuery)->C5_XPREAPR)
					(cTbClie)->DSCREGRA   := ''
					(cTbClie)->LIMCRED   := (cQuery)->A1_LC

					(cTbClie)->XRISCO := (cQuery)->A1_XRISCO
					(cTbClie)->XDTRISC := (cQuery)->A1_XDTRISC
					(cTbClie)->DTULTRE := (cQuery)->A1_DTULTRE
					(cTbClie)->DTACUMU := (cQuery)->A1_DTACUMU
					(cTbClie)->VLACUMU := (cQuery)->A1_VLACUMU

				(cTbClie)->(MSUNLOCK())
			ELSE
				RECLOCK(cTbClie,.F.)
					(cTbClie)->TOTAL    += (cQuery)->C5_XTOTPED
					(cTbClie)->NUMPED		+= 1
					// (cTbClie)->TPCLI    := ''
					// (cTbClie)->TPBLOQ   := Alltrim((cQuery)->C5_XPREAPR)
					// (cTbClie)->DSCREGRA   := ''
				(cTbClie)->(MSUNLOCK())

			ENDIF

			RECLOCK(cTbPed,.T.)      
				IF !Empty(Alltrim((cQuery)->A1_CODRED))
					(cTbPed)->RELACAO			:= (cQuery)->C5_FILIAL+'REDE  '+(cQuery)->A1_CODRED
				ELSE
					(cTbPed)->RELACAO			:= (cQuery)->C5_FILIAL+'VAREJO'+(cQuery)->C5_CLIENTE+(cQuery)->C5_LOJACLI
				ENDIF
				(cTbPed)->FILIAL   		:= (cQuery)->C5_FILIAL
				(cTbPed)->REDE   			:= (cQuery)->A1_CODRED
				(cTbPed)->CODIGO   		:= (cQuery)->C5_CLIENTE
				(cTbPed)->LOJA   			:= (cQuery)->C5_LOJACLI
				(cTbPed)->NOME   			:= (cQuery)->C5_NOMECLI
				(cTbPed)->TOTAL    		:= (cQuery)->C5_XTOTPED

				(cTbPed)->NUMERO    	:= (cQuery)->C5_NUM
				(cTbPed)->ROTEIRO    	:= (cQuery)->C5_ROTEIRO
				(cTbPed)->CONDPAG    	:= (cQuery)->C5_CONDPAG
				(cTbPed)->CPANT    		:= (cQuery)->E4_CTRADT
				(cTbPed)->DTENTR    	:= (cQuery)->C5_DTENTR
				(cTbPed)->DTEMIS    	:= (cQuery)->C5_EMISSAO
				(cTbPed)->NOTA    		:= (cQuery)->C5_NOTA
				(cTbPed)->XCOPIA    	:= (cQuery)->C5_XCOPIA
				(cTbPed)->FLAGFIN    	:= (cQuery)->C5_FLAGFIN
				(cTbPed)->REFATUR    	:= (cQuery)->C5_REFATUR

				(cTbPed)->TIPO    		:= ''
				(cTbPed)->TPBLOQ   		:= Alltrim((cQuery)->C5_XPREAPR)
				(cTbPed)->DSCREGRA  	:= ''
			(cTbPed)->(MSUNLOCK())


			// oChart:AddSerie((cTbClie)->TPBLOQ,{ {(cTbClie)->TOTAL} })
			cQryBlq := GetNextAlias()
			
			BeginSQL alias cQryBlq
				SELECT
					ZBH.ZBH_FILIAL,
					ZBH.ZBH_PEDIDO,
					ZBH.ZBH_MOTIVO,
					ZBH.ZBH_CODVEN,
					ZBH.ZBH_NOMVEN
				FROM %TABLE:ZBH% ZBH (NOLOCK)
				WHERE ZBH_FILIAL = %xFilial:ZBH%
				AND ZBH.ZBH_PEDIDO = %Exp:(cQuery)->C5_NUM%
				AND ZBH.%notDel%
			ENDSQL

			WHILE !(cQryBlq)->(eof())
				RECLOCK(cTbBlq,.T.)     
					(cTbBlq)->FILIAL   		:= (cQryBlq)->ZBH_FILIAL
					(cTbBlq)->NUMERO   		:= (cQryBlq)->ZBH_PEDIDO
					(cTbBlq)->MOTIVO   		:= (cQryBlq)->ZBH_MOTIVO
					(cTbBlq)->CODVEN   		:= (cQryBlq)->ZBH_CODVEN
					(cTbBlq)->NOMEVEN   	:= (cQryBlq)->ZBH_NOMVEN
				(cTbBlq)->(MSUNLOCK()) 

				(cQryBlq)->(dbSkip())
			ENDDO
			(cQryBlq)->(dbCloseArea())

		ENDIF

    (cQuery)->(dbSkip())
  ENDDO
	
  nVlTtTt := nVlTtLb + nVlTtBl + nVlTtNP

  (cQuery)->(dbCloseArea())


Return

/*/{Protheus.doc} Static Function xGrdClie
	Adiciona Grid dos Clientes
	@type  Static Function
	@author Abel Babini Filho
	@since 20/04/2021
	@version 1
	/*/
Static Function xGrdClie()
	oGrd10	:= FWMarkBrowse():New()
	oGrd10:SetOwner( oP02D101 )
	oGrd10:SetDescription( 'Clientes' )
	oGrd10:SetMenuDef('')
	oGrd10:DisableDetails()
	oGrd10:SetAlias(cTbClie)
	oGrd10:SetProfileID('1')
	// oGrd10:SetFieldMark('OMARK')
	oGrd10:SetChange({|| xChgLinC() })

	// oGrd10:bAllMark := { || InvSel(cTbClie,oGrd10:Mark(),lMkBord := !lMkBord,.F. ), oGrd10:Refresh(.T.)  }

	oGrd10:AddLegend( "TPCLI == 'REDE  '" , "BR_AMARELO", "Cliente Rede" )
	oGrd10:AddLegend( "TPCLI == 'VAREJO'" , "BR_AZUL", "Cliente Varejo" )
	// oGrd10:AddLegend( "TPCLI == 'REDE' .AND. TPBLOQ <> '' " , "BR_AMARELO", "Borderô com títulos em aprovação" )

	oGrd10:SetColumns(AddCols("FILIAL"		,"Filial"			    ,01,PesqPict("SC5","C5_FILIAL")	  ,1	,aX3Fil[1]	,aX3Fil[2]  , .T.,"C"))
	// oGrd10:SetColumns(AddCols("REDE"			,"Rede"		     	 	,01,PesqPict("SZF","ZF_REDE")			,1	,aX3CdRd[1]	,aX3CdRd[2] , .T.,"C"))
	// oGrd10:SetColumns(AddCols("NOMEREDE"	,"Nome Rede"		  ,01,PesqPict("SZF","ZF_NOMERED")	,1	,aX3NmRd[1]	,aX3NmRd[2] , .T.,"C"))
	oGrd10:SetColumns(AddCols("CODIGO"		,"Código"		      ,01,PesqPict("SC5","C5_CLIENTE")	,1	,aX3Clie[1]	,aX3Clie[2] , .T.,"C"))
	oGrd10:SetColumns(AddCols("LOJA"		  ,"Loja"	          ,01,PesqPict("SC5","C5_LOJACLI")  ,1	,aX3Loja[1]	,aX3Loja[2] , .T.,"C"))
	oGrd10:SetColumns(AddCols("NOME"		  ,"Cliente"			  ,01,PesqPict("SC5","C5_NOMECLI")	,1	,aX3NomC[1]	,aX3NomC[2] , .T.,"C"))
	oGrd10:SetColumns(AddCols("TOTAL"		  ,"Total Ped."	    ,01,PesqPict("SC5","C5_XTOTPED")	,2	,aX3TotP[1] ,aX3TotP[2]	, .T.,"C"))
	oGrd10:SetColumns(AddCols("NUMPED"		,"Num Ped."	    	,01,"@E 999,999"									,2	,aX3NumP[1] ,aX3NumP[2]	, .T.,"C"))
	oGrd10:SetColumns(AddCols("TPCLI"		  ,"Tipo Cliente"	  ,01,"@!"                          ,1	,aX3TpCl[1]	,aX3TpCl[2] , .T.,"C"))
	// oGrd10:SetColumns(AddCols("TPBLOQ"		,"Tipo Bloqueio"	,01,"@!"												  ,1	,aX3TpBl[1]	,aX3TpBl[2] , .T.,"C"))
	// oGrd10:SetColumns(AddCols("DSCREGRA"	,"Bloqueio"       ,01,"@!"												  ,1	,aX3DscBl[1],aX3DscBl[2], .T.,"C"))		

	oGrd10:DisableReport()

	oGrd10:Activate()

Return

/*/{Protheus.doc} Static Function xGrdPed
	Adiciona Grid dos Clientes
	@type  Static Function
	@author Abel Babini Filho
	@since 20/04/2021
	@version 1
	/*/
Static Function xGrdPed()
	oGrd20	:= FWMarkBrowse():New()
	oGrd20:SetOwner( oP02D201 )
	oGrd20:SetDescription( 'Pedidos' )
	oGrd20:SetMenuDef('')
	oGrd20:DisableDetails()
	oGrd20:SetAlias(cTbPed)
	oGrd20:SetProfileID('2')
	oGrd20:SetFieldMark('OMARK')

	oGrd20:bAllMark := { || InvSel(cTbPed,oGrd20:Mark(),lMkPed := !lMkPed,.F. ), oGrd20:Refresh(.T.)  }

	// oGrd20:AddLegend( "REGRA == '  '" , "ENABLE", "Borderô OK" )
	// oGrd20:AddLegend( "REGRA == ' 1'" , "DISABLE", "Borderô com títulos com restrição" )
	// oGrd20:AddLegend( "REGRA == ' 2'" , "BR_AZUL", "Borderô com títulos em aprovação" )

	oGrd20:SetColumns(AddCols("FILIAL"		,"Filial"			    ,01,PesqPict("SC5","C5_FILIAL")	  ,1	,aX3Fil[1]	,aX3Fil[2]  , .T.,"P"))
	// oGrd20:SetColumns(AddCols("REDE"			,"Rede"		     	 	,01,PesqPict("SZF","ZF_REDE")			,1	,aX3CdRd[1]	,aX3CdRd[2] , .T.,"P"))
	oGrd20:SetColumns(AddCols("CODIGO"		,"Código"		      ,01,PesqPict("SC5","C5_CLIENTE")	,1	,aX3Clie[1]	,aX3Clie[2] , .T.,"P"))
	oGrd20:SetColumns(AddCols("LOJA"		  ,"Loja"	          ,01,PesqPict("SC5","C5_LOJACLI")  ,1	,aX3Loja[1]	,aX3Loja[2] , .T.,"P"))
	oGrd20:SetColumns(AddCols("NOME"		  ,"Cliente"			  ,01,PesqPict("SC5","C5_NOMECLI")	,1	,aX3NomC[1]	,aX3NomC[2] , .T.,"P"))
	oGrd20:SetColumns(AddCols("NUMERO"		 ,"Pedido"	  		,01,PesqPict("SC5","C5_NUM")  		,1	,aX3PdNum[1],aX3PdNum[2] , .T.,"P"))
	oGrd20:SetColumns(AddCols("ROTEIRO"		 ,"Roteiro"	  		,01,PesqPict("SC5","C5_ROTEIRO")  ,1	,aX3PdRot[1],aX3PdRot[2] , .T.,"P"))
	oGrd20:SetColumns(AddCols("CONDPAG"		 ,"Cond Pagto"	  ,01,PesqPict("SC5","C5_CONDPAG")  ,1	,aX3PdCp[1] ,aX3PdCp[2]  , .T.,"P"))
	oGrd20:SetColumns(AddCols("CPANT"		 	 ,"Antecipado"	  ,01,PesqPict("SE4","E4_CTRADT")  	,1	,aX3PdCtr[1],aX3PdCtr[2] , .T.,"P"))
	oGrd20:SetColumns(AddCols("DTENTR"		 ,"Entrega"	  		,01,PesqPict("SC5","C5_DTENTR")  	,1	,aX3PdEnt[1],aX3PdEnt[2] , .T.,"P"))
	oGrd20:SetColumns(AddCols("DTEMIS"		 ,"Emissão"	  		,01,PesqPict("SC5","C5_EMISSAO")  ,1	,aX3PdEmi[1],aX3PdEmi[2] , .T.,"P"))
	oGrd20:SetColumns(AddCols("NOTA"		 	 ,"NF"	  				,01,PesqPict("SC5","C5_NOTA")  		,1	,aX3PdNf[1],aX3PdNf[2] , .T.,"P"))
	oGrd20:SetColumns(AddCols("XCOPIA"		 ,"Cópia Ped"	  	,01,PesqPict("SC5","C5_XCOPIA")  	,1	,aX3PdXCp[1],aX3PdXCp[2] , .T.,"P"))
	oGrd20:SetColumns(AddCols("FLAGFIN"		 ,"Flag Financ"	  ,01,PesqPict("SC5","C5_FLAGFIN")  ,1	,aX3PdFlg[1],aX3PdFlg[2] , .T.,"P"))
	oGrd20:SetColumns(AddCols("REFATUR"		 ,"Refatura"	  	,01,PesqPict("SC5","C5_REFATUR")  ,1	,aX3PdFlg[1],aX3PdFlg[2] , .T.,"P"))

	oGrd20:SetColumns(AddCols("TOTAL"		  ,"Total Ped."	    ,01,PesqPict("SC5","C5_XTOTPED")	,2	,aX3TotP[1] ,aX3TotP[2]	, .T.,"P"))

	oGrd20:SetColumns(AddCols("TIPO"		  ,"Tipo Pedido"	  ,01,PesqPict("SC5","C5_TIPO")  		,1	,aX3PdTp[1]	,aX3PdTp[2] , .T.,"P"))
	oGrd20:SetColumns(AddCols("TPBLOQ"		,"Tipo Bloqueio"	,01,"@!"												  ,1	,aX3TpBl[1]	,aX3TpBl[2] , .T.,"P"))
	oGrd20:SetColumns(AddCols("DSCREGRA"	,"Bloqueio"       ,01,"@!"												  ,1	,aX3DscBl[1],aX3DscBl[2], .T.,"P"))		

	oGrd20:DisableReport()

	oGrd20:Activate()

	(cTbPed)->(dbGoTop())
	WHILE !(cTbPed)->(eof())
		IF (cTbPed)->OMARK <> oGrd20:Mark()
			(cTbPed)->OMARK := oGrd20:Mark()
		ENDIF
		(cTbPed)->(dbSkip())
	ENDDO
	(cTbPed)->(dbGoTop())


	oRelGr12:= FWBrwRelation():New()
	oRelGr12:AddRelation(oGrd10 , oGrd20 , { { 'RELACAO','RELACAO'} } )
	oRelGr12:Activate()

Return

/*/{Protheus.doc} Static Function xGrdBlq
	Adiciona Grid dos Bloqueios dos Pedidos
	@type  Static Function
	@author Abel Babini Filho
	@since 20/04/2021
	@version 1
	/*/
Static Function xGrdBlq()
	oGrd30	:= FWMarkBrowse():New()
	oGrd30:SetOwner( oP02D202 )
	oGrd30:SetDescription( 'Bloqueios' )
	oGrd30:SetMenuDef('')
	oGrd30:DisableDetails()
	oGrd30:SetAlias(cTbBlq)
	oGrd30:SetProfileID('3')

	// oGrd20:AddLegend( "REGRA == '  '" , "ENABLE", "Borderô OK" )
	// oGrd20:AddLegend( "REGRA == ' 1'" , "DISABLE", "Borderô com títulos com restrição" )
	// oGrd20:AddLegend( "REGRA == ' 2'" , "BR_AZUL", "Borderô com títulos em aprovação" )

	oGrd30:SetColumns(AddCols("FILIAL"		 ,"Filial"			,01,PesqPict("ZBH","ZBH_FILIAL")	,1	,aX3Fil[1]	,aX3Fil[2]  , .T.,"P"))
	oGrd30:SetColumns(AddCols("NUMERO"		 ,"Pedido"	  	,01,PesqPict("ZBH","ZBH_PEDIDO")  ,1	,aX3PdNum[1],aX3PdNum[2], .T.,"P"))
	oGrd30:SetColumns(AddCols("MOTIVO"		 ,"Motivo"	  	,01,PesqPict("ZBH","ZBH_MOTIVO")  ,1	,aX3BlMt[1] ,aX3BlMt[2] , .T.,"P"))
	oGrd30:SetColumns(AddCols("CODVEN"		 ,"Cod.Vend."	  ,01,PesqPict("ZBH","ZBH_CODVEN")  ,1	,aX3BlCV[1] ,aX3BlCV[2] , .T.,"P"))
	oGrd30:SetColumns(AddCols("NOMEVEN"		 ,"Vendedor"	  ,01,PesqPict("ZBH","ZBH_NOMVEN")  ,1	,aX3BlNV[1] ,aX3BlNV[2] , .T.,"P"))

	oGrd30:DisableReport()

	oGrd30:Activate()

	oRelGr23:= FWBrwRelation():New()
	oRelGr23:AddRelation(oGrd20 , oGrd30 , { { 'FILIAL','FILIAL'}, { 'NUMERO','NUMERO'} } )
	oRelGr23:Activate()

Return

/*/{Protheus.doc} Static Function xGrdLib
	Adiciona Informações da Rede / Cliente e Pedido a ser liberado
	@type  Static Function
	@author Abel Babini Filho
	@since 30/04/2021
	@version 1
	/*/
Static Function xGrdLib()
	Local _cPer := ""
	Local _cPos := ""
	Local cQryRede := GetNextAlias()
	Local cQryVAtr := ''
	Local cQryVAbr := ''
	Local cQryPFtr := ''
	// Local _nMaior := Posicione("SA1",1,xFilial("SA1")+(cTbClie)->CODIGO+(cTbClie)->LOJA,"A1_VLACUMU")

	Local _dDTM := DTOC((cTbClie)->DTACUMU)
	// Local _DtMAcum := DTOC((cTbClie)->DTACUMU)
	Local _nTotRede   := 0
	Local _nTotSdRede := 0
	Local _nTotVenci  := 0
	Local _nTotAVenc  := 0
	Local _nPedFut		:= 0
	Local _nTotMAcum	:= 0

	// Local aMotLib := {}
	// Local oMotLib
	// Local nMotLib := 0

	Local cPerfPgt := ''
	Local nMedAtr	:= 0
	Local aPerPgt	:= {}
	
	// cParecer	:= Space(240)
	// cMotLib		:= ''

	// SX5->(dbSetOrder(1))
	// SX5->(dbGotop())
	// IF SX5->(dbSeek(xFilial("SX5")+'_Z'))
	// 	WHILE !SX5->(eof()) .AND. SX5->X5_TABELA == '_Z'
	// 		AADD(aMotLib,SX5->X5_CHAVE+' - '+ALLTRIM(SX5->X5_DESCRI))
	// 		SX5->(dbSkip())
	// 	ENDDO
	// ELSE
	// 	Aviso(	"ADFIN109-01",;
	// 					"Não será possível realizar liberação até que exista pelo menos 1 motivo de liberação cadastrado no sistema!",;
	// 					{ "&OK" },,;
	// 					"Aprovação Varejo" )
	// ENDIF
	
	//Carrega Perfil de Pagamento
	aPerPgt 	:= StaticCall(ADFIN103P,fMedPgt,(cTbPed)->CODIGO, (cTbPed)->LOJA)
	IF ValType(aPerPgt) = 'A' 
		cPerfPgt	:= IIF(Empty(Alltrim(aPerPgt[2])) .OR. ValType(aPerPgt) != 'A','NDA', aPerPgt[2])
		nMedAtr		:= IIF(ValType(aPerPgt) != 'A',0, aPerPgt[1])
	ELSE
		cPerfPgt	:= 'NDA'
	ENDIF

	IF Alltrim((cTbClie)->TPCLI) == 'REDE' //REDE
		//Informações da Rede
		
		BeginSQL alias cQryRede
			column ZF_DTACUMU as Date
			SELECT
				ZF_REDE,
				ZF_VLACUMU,
				ZF_DTACUMU,
				ZF_LCREDE,
				ZF_SLDREDE,
				ZF_VENCIDO,
				ZF_AVENCER
			FROM %TABLE:SZF% SZF (NOLOCK)
			WHERE 
				SZF.%notDel% AND
				SZF.ZF_REDE = %Exp:(cTbClie)->CODIGO%
			ORDER BY ZF_REDE
		EndSQL
		While !(cQryRede)->(EOf())
			_nTotRede   += (cQryRede)->ZF_LCREDE
			_nTotSdRede += (cQryRede)->ZF_SLDREDE
			_nTotVenci  += (cQryRede)->ZF_VENCIDO
			_nTotAVenc  += (cQryRede)->ZF_AVENCER
			_nTotMAcum	+= (cQryRede)->ZF_VLACUMU

			if !Empty(Alltrim(DTOS((cQryRede)->ZF_DTACUMU))) .and. (cQryRede)->ZF_DTACUMU > CTOD(_dDTM)
				_dDTM := (cQryRede)->ZF_DTACUMU
			endif

			(cQryRede)->(dbskip())
		Enddo
		(cQryRede)->(dbCloseArea())

		// if _DtMAcum > _dDTM
		// 	_dDTM := _DtMAcum
		// endif

		//Pedidos com data de entrega futura
		cQryPFtr := GetNextAlias()
		BeginSQL alias cQryPFtr
			SELECT 
				SUM((C6_QTDVEN - C6_QTDENT) * C6_PRCVEN) AS TOTAL
			FROM %TABLE:SC6% SC6 (NOLOCK)
			INNER JOIN %TABLE:SA1% SA1 (NOLOCK) ON
				A1_FILIAL = %xFilial:SA1%
				AND A1_COD = C6_CLI
				AND A1_LOJA = C6_LOJA
				AND SA1.%notDel%
			LEFT JOIN %TABLE:SZF% SZF (NOLOCK) ON
				ZF_FILIAL = %xFilial:SZF%
				AND ZF_CGCMAT = SUBSTRING(A1_CGC,1,8)
				AND SZF.%notDel%
			WHERE C6_FILIAL = %xFilial:SC6%
				AND SC6.C6_ENTREG > %Exp:DTOS(dDtFim)%
				AND SA1.A1_CODRED = %Exp:(cTbClie)->CODIGO%
				AND (C6_QTDVEN - C6_QTDENT) > 0
				AND SC6.%notDel%
  	EndSQL
		_nPedFut := (cQryPFtr)->TOTAL
		(cQryPFtr)->(dbCloseArea())

	ELSE //VAREJO
		//Valores em aberto , incluindo os valores em atraso
		cQryVAbr := GetNextAlias()
		BeginSQL alias cQryVAbr
			SELECT 
				SUM(E1_SALDO) AS E1_SALDO
			FROM %TABLE:SE1% SE1 (NOLOCK)
			WHERE SE1.E1_CLIENTE = %Exp:(cTbClie)->CODIGO%
				AND SE1.E1_LOJA = %Exp:(cTbClie)->LOJA%
				AND SE1.E1_SALDO > 0 
				AND SE1.E1_TIPO NOT IN ('NCC','RA') 
				AND SE1.E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') 
				AND SE1.%notDel% 
			GROUP BY E1_CLIENTE,E1_LOJA,E1_PORTADO 
			ORDER BY E1_CLIENTE,E1_LOJA,E1_PORTADO 
		EndSQL

		_nTotSdRede := (cQryVAbr)->E1_SALDO
		(cQryVAbr)->(dbCloseArea())

		//Valores em atraso
		cQryVAtr := GetNextAlias()
		BeginSQL alias cQryVAtr
			SELECT 
				SUM(E1_SALDO) AS E1_SALDO
			FROM %TABLE:SE1% SE1 (NOLOCK)
			WHERE SE1.E1_CLIENTE = %Exp:(cTbClie)->CODIGO%
				AND SE1.E1_LOJA = %Exp:(cTbClie)->LOJA%
				AND SE1.E1_SALDO > 0 
				AND (E1_VENCREA < %Exp:msDate()%) 
				AND SE1.E1_TIPO NOT IN ('NCC','RA') 
				AND SE1.E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') 
				AND SE1.%notDel% 
			GROUP BY E1_CLIENTE,E1_LOJA,E1_PORTADO 
			ORDER BY E1_CLIENTE,E1_LOJA,E1_PORTADO 
		EndSQL

		_nTotVenci := (cQryVAtr)->E1_SALDO
		(cQryVAtr)->(dbCloseArea())

		//Pedidos colocados com data de entrega posterior ao período selecionado
		cQryPFtr := GetNextAlias()
		BeginSQL alias cQryPFtr
			SELECT 
				SUM((C6_QTDVEN - C6_QTDENT) * C6_PRCVEN) AS TOTAL
			FROM %TABLE:SC6% SC6 (NOLOCK)
			WHERE 
				SC6.C6_FILIAL = %xFilial:SC6%
				AND SC6.C6_CLI = %Exp:(cTbClie)->CODIGO%
				AND SC6.C6_LOJA = %Exp:(cTbClie)->LOJA%
				AND SC6.C6_ENTREG > %Exp:DTOS(dDtFim)%
				AND ((SC6.C6_QTDVEN - SC6.C6_QTDENT) > 0)
				AND SC6.%notDel% 
		EndSQL

		_nPedFut := (cQryPFtr)->TOTAL
		(cQryPFtr)->(dbCloseArea())

		//Limite de crédito do cliente	
		// IF SA1->(DBSEEK(xFilial("SA1")+(cTbPed)->CODIGO+(cTbPed)->LOJA))
		_nTotRede		:= (cTbClie)->LIMCRED
		// ENDIF
	ENDIF

	@ 000,001 SAY OemToAnsi("Informações Adicionais para Liberação")	FONT oFont004 SIZE 200,15 OF oP02D102 PIXEL

	//
	//COLUNA 01
	//
	@ 010,004 TO 129,160 OF oP02D102 PIXEL
	IF Alltrim((cTbClie)->TPCLI) == 'REDE'
		@ 010,010 SAY "Tipo: REDE" of oP02D102 PIXEL FONT oFont002
		@ 020,010 SAY "Rede: "+(cTbClie)->CODIGO+"-"+(cTbClie)->LOJA+" "+Alltrim((cTbClie)->NOME) of oP02D102 PIXEL

		//VALOR MAIOR ACUMULO
		@ 050,240 SAY Transform(_nTotMAcum,"@E 999,999,999.99") of oP02D102 PIXEL
	ELSE
		@ 010,010 SAY "Tipo: VAREJO" of oP02D102 PIXEL FONT oFont002
		@ 020,010 SAY "Cliente: "+(cTbClie)->CODIGO+"-"+(cTbClie)->LOJA+" "+Alltrim((cTbClie)->NOME) of oP02D102 PIXEL

		//VALOR MAIOR ACUMULO
		@ 050,240 SAY Transform((cTbClie)->VLACUMU,"@E 999,999,999.99") of oP02D102 PIXEL
	ENDIF
	
	@ 030,010 SAY "Qtdade. Pedidos: " of oP02D102 PIXEL
	@ 030,120 SAY Transform((cTbClie)->NUMPED  ,"@E 999,999,999.99") of oP02D102 PIXEL
	
	@ 040,010 SAY "Limite de Credito do Cliente: " of oP02D102 PIXEL
	@ 040,120 SAY Transform(_nTotRede  ,"@E 999,999,999.99") of oP02D102 PIXEL
	
	@ 050,010 SAY "Utilizado deste Cliente:" of oP02D102 PIXEL
	@ 050,120 SAY Transform(_nTotSdRede,"@E 999,999,999.99") of oP02D102 PIXEL
	
	// @ 060,010 SAY "Valor pedidos ja liberados (pre aprovação):" of oP02D102 PIXEL
	// @ 060,130 SAY Transform(_nTtPLib,"@E 999,999,999.99") of oP02D102 PIXEL

	_cPer := "Valor Pedidos entre ("+DTOC(dDtIni)+" e "+DTOC(dDtFim)+"): "
	@ 060,010 SAY _cPer of oP02D102 PIXEL
	@ 060,120 SAY Transform((cTbClie)->TOTAL,"@E 999,999,999.99") of oP02D102 PIXEL

	@ 070,010 SAY "Total utilizado: " of oP02D102 PIXEL
	@ 070,120 SAY Transform((_nTotSdRede)+(cTbClie)->TOTAL,"@E 999,999,999.99") of oP02D102 PIXEL

	@ 079,004 TO 099,160 OF oP02D102 PIXEL
	@ 080,010 SAY "PERCENTUAL" of oP02D102 PIXEL FONT oFont002
	@ 080,120 SAY Transform(((_nTotSdRede+(cTbClie)->TOTAL)/_nTotRede)*100,"@E 999999.99 %") of oP02D102 PIXEL

	@ 090,010 SAY "Valor Total Vencidos: " of oP02D102 PIXEL
	@ 090,120 SAY Transform(_nTotVenci,"@E 999,999,999.99") of oP02D102 PIXEL

	@ 100,010 SAY "Valor Total A Vencer: " of oP02D102 PIXEL
	@ 100,120 SAY Transform(_nTotAvenc,"@E 999,999,999.99") of oP02D102 PIXEL

	_cPos := "Valor Pedidos após "+DTOC(dDtFim)+": "
	@ 110,010 SAY _cPos  of oP02D102 PIXEL
	@ 110,120 SAY Transform(_nPedFut,"@E 999,999,999.99") of oP02D102 PIXEL

	
	// @ 134,004 TO 181,300 OF oP02D102 PIXEL
	// @ 135,010 SAY OemToAnsi("Motivo Liberação:")				 SIZE 140,15 PIXEL OF oP02D102  FONT oFont002
	// @ 143,010 COMBOBOX oMotLib VAR cMotLib ITEMS aMotLib SIZE 110,08 PIXEL OF oP02D102 ON CHANGE nMotLib := oMotLib:nAt 
	// @ 155,010 SAY OemToAnsi('Parecer da Liberação do Pedido')		SIZE 100,025 	OF oP02D102 COLORS 0, 16777215 PIXEL FONT oFont002
	// @ 165,010 MSGET cParecer	SIZE 285,008 	OF oP02D102 PIXEL PICTURE '@!'
	

	//
	//COLUNA 02
	//
	@ 009,165 TO 090,290 OF oP02D102 PIXEL
	@ 010,170 SAY "RISCO: " of oP02D102 PIXEL
	@ 010,240 SAY (cTbClie)->XRISCO of oP02D102 PIXEL
	
	@ 020,170 SAY "Data Ultima Atualiz.:" of oP02D102 PIXEL
	@ 020,240 SAY DTOC((cTbClie)->XDTRISC) of oP02D102 PIXEL
	
	@ 030,170 SAY "Data Ultima Compra:" of oP02D102 PIXEL
	@ 030,240 SAY DTOC((cTbClie)->DTULTRE) of oP02D102 PIXEL
	
	@ 040,170 SAY "Data Maior Acumulo:" of oP02D102 PIXEL
	@ 040,240 SAY _dDTM of oP02D102 PIXEL

	//Valor está sendo exibido dentro do bloco condicional de se é REDE ou VAREJO no início da coluna 01
	@ 050,170 SAY "Valor Maior Acumulo:" of oP02D102 PIXEL
	
	@ 060,170 SAY "Média de Atraso:" of oP02D102 PIXEL 
	@ 060,240 SAY Transform(nMedAtr,"@E 999,999,999.99") of oP02D102 PIXEL

	@ 070,170 SAY "Perfil de Pagamento" of oP02D102 PIXEL FONT oFont002
	@ 078,170 SAY cPerfPgt of oP02D102 PIXEL FONT oFont002

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
	IF _table $ 'CLIENTES'
		// AADD(_aIndex,{'01',{'FILIAL','REDE','CODIGO','LOJA'}})
		// AADD(_aIndex,{'02',{'FILIAL','REDE','NOME'}})
		// AADD(_aIndex,{'03',{'FILIAL','TOTAL','REDE','CODIGO','LOJA'}})
		AADD(_aIndex,{'01',{'FILIAL','TPCLI','CODIGO','LOJA'}})
		AADD(_aIndex,{'02',{'FILIAL','TPCLI','NOME'}})
		AADD(_aIndex,{'03',{'FILIAL','TOTAL','CODIGO','LOJA'}})
	ELSEIF _table $ 'PEDIDOS'
		AADD(_aIndex,{'01',{'FILIAL','REDE','CODIGO','LOJA','NUMERO'}})
		AADD(_aIndex,{'02',{'FILIAL','NUMERO'}})
		AADD(_aIndex,{'03',{'FILIAL','DTENTR','NUMERO'}})
	ELSEIF _table $ 'BLOQUEIOS'
		AADD(_aIndex,{'01',{'FILIAL','NUMERO'}})
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

	IF _table $ 'CLIENTES'
		aadd(_aFields,{"OMARK"			,"C"				,2					,0})
		aadd(_aFields,{"FILIAL"			,aX3Fil[3]	,aX3Fil[1]	,aX3Fil[2]})
		// aadd(_aFields,{"REDE"	  		,aX3CdRd[3]	,aX3CdRd[1]	,aX3CdRd[2]})
		// aadd(_aFields,{"NOMEREDE"	  ,aX3NmRd[3]	,aX3NmRd[1]	,aX3NmRd[2]})
		aadd(_aFields,{"CODIGO"		  ,aX3Clie[3]	,aX3Clie[1]	,aX3Clie[2]})
		aadd(_aFields,{"LOJA"				,aX3Loja[3]	,aX3Loja[1]	,aX3Loja[2]})
		aadd(_aFields,{"NOME"		    ,aX3NomC[3]	,aX3NomC[1]	,aX3NomC[2]})
		aadd(_aFields,{"TOTAL"	    ,aX3TotP[3]	,aX3TotP[1]	,aX3TotP[2]})
		aadd(_aFields,{"NUMPED"	    ,aX3NumP[3]	,aX3NumP[1]	,aX3NumP[2]})
		aadd(_aFields,{"TPCLI"      ,aX3TpCl[3]	,aX3TpCl[1]	,aX3TpCl[2]})
		aadd(_aFields,{"TPBLOQ"     ,aX3TpBl[3]	,aX3TpBl[1]	,aX3TpBl[2]})
		aadd(_aFields,{"DSCREGRA"		,aX3DscBl[3],aX3DscBl[1],aX3DscBl[2]})
		aadd(_aFields,{"RELACAO"		,aX3Fil[3],aX3Fil[1]+aX3CdRd[1]+aX3Clie[1]+aX3Loja[1],aX3Fil[2]})

		aadd(_aFields,{"LIMCRED"		,aX3A1LCr[3],aX3A1LCr[1],aX3A1LCr[2]})
		aadd(_aFields,{"XRISCO"			,aX3A1Rsc[3],aX3A1Rsc[1],aX3A1Rsc[2]})
		aadd(_aFields,{"XDTRISC"		,aX3A1DAt[3],aX3A1DAt[1],aX3A1DAt[2]})
		aadd(_aFields,{"DTULTRE"		,aX3A1DUC[3],aX3A1DUC[1],aX3A1DUC[2]})
		aadd(_aFields,{"DTACUMU"		,aX3A1DMC[3],aX3A1DMC[1],aX3A1DMC[2]})
		aadd(_aFields,{"VLACUMU"		,aX3A1VMA[3],aX3A1VMA[1],aX3A1VMA[2]})

	ELSEIF _table $ 'PEDIDOS'
		aadd(_aFields,{"OMARK"			,"C"				,2					,0})
		aadd(_aFields,{"FILIAL"			,aX3Fil[3]	,aX3Fil[1]	,aX3Fil[2]})
		aadd(_aFields,{"NUMERO"			,aX3PdNum[3],aX3PdNum[1],aX3PdNum[2]})
		aadd(_aFields,{"TIPO"			  ,aX3PdTp[3]	,aX3PdTp[1]	,aX3PdTp[2]})
		aadd(_aFields,{"REDE"	  		,aX3CdRd[3]	,aX3CdRd[1]	,aX3CdRd[2]})
		aadd(_aFields,{"CODIGO"			,aX3Clie[3]	,aX3Clie[1]	,aX3Clie[2]})
		aadd(_aFields,{"LOJA"			  ,aX3Loja[3]	,aX3Loja[1]	,aX3Loja[2]})
		aadd(_aFields,{"NOME"		    ,aX3NomC[3]	,aX3NomC[1]	,aX3NomC[2]})
		aadd(_aFields,{"ROTEIRO"		,aX3PdRot[3],aX3PdRot[1],aX3PdRot[2]})
		aadd(_aFields,{"CONDPAG"		,aX3PdCp[3]	,aX3PdCp[1]	,aX3PdCp[2]})
		aadd(_aFields,{"CPANT"			,aX3PdCtr[3],aX3PdCtr[1],aX3PdCtr[2]})
		aadd(_aFields,{"DTENTR"			,aX3PdEnt[3],aX3PdEnt[1],aX3PdEnt[2]})
		aadd(_aFields,{"DTEMIS"			,aX3PdEmi[3],aX3PdEmi[1],aX3PdEmi[2]})
		aadd(_aFields,{"TOTAL"	    ,aX3TotP[3]	,aX3TotP[1]	,aX3TotP[2]})
		aadd(_aFields,{"NOTA"			  ,aX3PdNf[3],aX3PdNf[1],aX3PdNf[2]})
		aadd(_aFields,{"XPREAPR"		,aX3PdXPA[3],aX3PdXPA[1],aX3PdXPA[2]})
		aadd(_aFields,{"XCOPIA"			,aX3PdXCp[3],aX3PdXCp[1],aX3PdXCp[2]})
		aadd(_aFields,{"FLAGFIN"		,aX3PdFlg[3],aX3PdFlg[1],aX3PdFlg[2]})
		aadd(_aFields,{"REFATUR"		,aX3PdRft[3],aX3PdRft[1],aX3PdRft[2]})
		aadd(_aFields,{"TPBLOQ"     ,aX3TpBl[3]	,aX3TpBl[1]	,aX3TpBl[2]})
		aadd(_aFields,{"DSCREGRA"		,aX3DscBl[3],aX3DscBl[1],aX3DscBl[2]})
		aadd(_aFields,{"RELACAO"		,aX3Fil[3],aX3Fil[1]+aX3CdRd[1]+aX3Clie[1]+aX3Loja[1],aX3Fil[2]})
	ELSEIF _table $ 'BLOQUEIOS'
		aadd(_aFields,{"FILIAL"			,aX3Fil[3]	,aX3Fil[1]	,aX3Fil[2]})
		aadd(_aFields,{"NUMERO"			,aX3PdNum[3],aX3PdNum[1],aX3PdNum[2]})
		aadd(_aFields,{"MOTIVO"     ,aX3BlMt[3]	,aX3BlMt[1]	,aX3BlMt[2]})
		aadd(_aFields,{"CODVEN"     ,aX3BlCV[3]	,aX3BlCV[1]	,aX3BlCV[2]})
		aadd(_aFields,{"NOMEVEN"    ,aX3BlNV[3]	,aX3BlNV[1]	,aX3BlNV[2]})
	ENDIF

Return _aFields

/*/{Protheus.doc} Static Function xReStart()
	Executa funções na carga inicial ou ao clicar no botão Filtrar
	@type  Static Function
	@author Abel Babini Filho
	@since 20/04/2021
	@version 1
	/*/
Static Function xReStart(cPedDe, cPedAte, cCliDe, cLojDe, cCliAte, cLojAte, cRedDe, cRedAte)
  Local _aFields  := {}
  Local _aIndex   := {}

  nRadio := 0

  IF Select(cTbClie) > 0
    (cTbClie)->(dbCloseArea())
    cTbClie:=GetNextAlias()
  ENDIF

  IF Select(cTbPed) > 0
    (cTbPed)->(dbCloseArea())
    cTbPed:=GetNextAlias()
  ENDIF

  IF Select(cTbBlq) > 0
    (cTbBlq)->(dbCloseArea())
    cTbBlq:=GetNextAlias()
  ENDIF

  _aFields	:= CriaExtr("CLIENTES")
	_aIndex		:= CriaInd("CLIENTES")
	oTbClie		:= CriaTmpT(cTbClie, _aFields, _aIndex)

  _aFields	:= CriaExtr("PEDIDOS")
	_aIndex		:= CriaInd("PEDIDOS")
	oTbPed		:= CriaTmpT(cTbPed, _aFields, _aIndex)

  _aFields	:= CriaExtr("BLOQUEIOS")
	_aIndex		:= CriaInd("BLOQUEIOS")
	oTbBlq		:= CriaTmpT(cTbBlq, _aFields, _aIndex)

	oP02D101	:= oFWLr02:GetColPanel('DET_ESQ1','DET1')
	oP02D102	:= oFWLr02:GetColPanel('DET_DIR1','DET1')
	oP02D201	:= oFWLr02:GetColPanel('DET_ESQ2','DET2')
	oP02D202	:= oFWLr02:GetColPanel('DET_DIR2','DET2')

	oP02D101:FreeChildren()
	oP02D201:FreeChildren()
	oP02D102:FreeChildren()
	oP02D202:FreeChildren()

  xTotPeds(cPedDe, cPedAte, cCliDe, cLojDe, cCliAte, cLojAte, cRedDe, cRedAte)

  //Mostra gráfico na tela resumo
  // oChart:build()

  xGrdClie()
	xGrdPed()
	xGrdBlq()
	// xGrdLib()
Return

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
	// aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{|| IIF(lDpClk,xTitSts(cOrig),.T.)},NIL,{||.T.},.F.,.F.,{}}  
	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{|| .T.},NIL,{||.T.},.F.,.F.,{}}  
	
Return {aColumn}

/*/{Protheus.doc} Static Function xChgLinC()
	Atualiza Painel de Informações Complementares
	@type  Static Function
	@author Abel Babini Filho
	@since 30/04/2021
	@version 1
	/*/
Static Function xChgLinC()

	oP02D102	:= oFWLr02:GetColPanel('DET_DIR1','DET1')

	oP02D102:FreeChildren()

	// Executar apenas se cliente posicionado é Rede
	IF (cTbClie)->TPCLI  == 'REDE  '
		bBloco := {|lEnd| xAtuRed((cTbClie)->CODIGO)}  
		MsAguarde(bBloco,"Aguarde, Atualizando o credito da rede","Atualizando...",.F.)

	ENDIF

	//Deixa os pedidos já marcados para liberação
	// WHILE !(cTbPed)->(eof())
	// 	IF (cTbPed)->OMARK <> oGrd20:Mark()
	// 		(cTbPed)->OMARK := oGrd20:Mark()
	// 	ENDIF
	// 	(cTbPed)->(dbSkip())
	// ENDDO
	// (cTbPed)->(dbGoTop())

	// oP02D201	:= oFWLr02:GetColPanel('DET_ESQ2','DET2')
	// oP02D202	:= oFWLr02:GetColPanel('DET_DIR2','DET2')

	// oP02D201:FreeChildren()
	// oP02D202:FreeChildren()

	// xGrdPed()
	// xGrdBlq()
	xGrdLib()

Return

/*/{Protheus.doc} Static Function xDelSC5
	Botão Posição do Cliente
	@type  Function
	@author Abel Babini
	@since 03/05/2021
	// Chamado 057992 - Abel Babini - 02/06/2020 - Adicionar informações na tela de liberação de pedidos
	/*/
Static Function xDelSC5()
	Local aCabec	:= {}
	Local aItens	:= {}
	Local aLinha	:= {}
	Local lExcLt	:= .F.
	Private lMsErroAuto := .F.

	//
	//CRIAR LAÇO FOR PERCORRENDO TODOS OS PEDIDOS DO CLIENTE PARA VERIFICAR OS PEDIDOS MARCADOS.
	//
	IF MsgBox("Deseja excluir os Pedidos em lote?","CONFIRMACAO","YESNO")
		lExcLt	:= .T.
	ENDIF

	(cTbPed)->(dbGoTop())
	While !(cTbPed)->(eof())
		aCabec	:= {}
		aItens	:= {}
		aLinha	:= {}

		IF (cTbPed)->OMARK == oGrd20:Mark() .AND. IIF(lExcLt,.T.,MsgBox("Tem certeza que deseja excluir o Pedido "+Alltrim((cTbPed)->NUMERO)+" ?","CONFIRMACAO","YESNO"))

			If SC5->(dbSeek(xFilial("SC5")+(cTbPed)->NUMERO))
				
				// Exclui Pedido de Venda
				aAdd( aCabec, { "C5_FILIAL"	, xFilial('SC5')	, Nil } )
				aAdd( aCabec, { "C5_NUM"	 	, SC5->C5_NUM			, Nil } )
				aadd( aCabec, { "C5_TIPO"		, SC5->C5_TIPO		, Nil } )
				aadd( aCabec, { "C5_CLIENTE", SC5->C5_CLIENTE	, Nil } )
				aadd( aCabec, { "C5_LOJACLI", SC5->C5_LOJACLI	, Nil } )
				aadd( aCabec, { "C5_LOJAENT", SC5->C5_LOJAENT	, Nil } )
				aadd( aCabec, { "C5_CONDPAG", SC5->C5_CONDPAG	, Nil } )

				dbSelectArea("SC6")
				dbSetOrder(1)
				dbSeek(xFilial("SC6")+SC5->C5_NUM)

				While SC6->(!Eof()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM

					aLinha := {}
					aAdd( aLinha, { "C6_FILIAL"	, xFilial('SC6')	, Nil } )
					aAdd( aLinha, { "C6_NUM"	 	, SC5->C5_NUM			, Nil } )
					aAdd( aLinha, { "C6_ITEM"	 	, SC6->C6_ITEM		, Nil } )
					aAdd( aLinha, { "C6_PRODUTO", SC6->C6_PRODUTO	, Nil } )
					aadd( aLinha, { "C6_QTDVEN"	, SC6->C6_QTDVEN  , Nil } )
					aadd( aLinha, { "C6_PRCVEN"	, SC6->C6_PRCVEN	, Nil } )
					aadd( aLinha, { "C6_PRUNIT"	, SC6->C6_PRUNIT	, Nil } )
					aadd( aLinha, { "C6_VALOR"	, SC6->C6_VALOR		, Nil } )
					aadd( aLinha, { "C6_TES"		, SC6->C6_TES			, Nil } )

					Aadd(aItens, aLinha)
					SC6->(dbSkip())

				Enddo

				Begin Transaction

					lMsErroAuto := .F.
					MSExecAuto({|x, y, z| Mata410(x, y, z) }, aCabec , aItens , 5)
					
					If lMsErroAuto
						MostraErro()
						DisarmTransaction()
					Else

						// Apaga registro do browser de bloqueios
						(cTbBlq)->(dbGoTop())
						WHILE !(cTbBlq)->(eof())
							RECLOCK(cTbBlq,.F.)
								(cTbBlq)->( DbDelete() )
							(cTbBlq)->(MSUnlock())

							(cTbBlq)->(dbSkip())
						ENDDO
						
						RECLOCK(cTbPed,.F.)
							(cTbPed)->( DbDelete() )
						(cTbPed)->(MSUnlock())

						If (cTbPed)->( eof() )
							RECLOCK(cTbClie,.F.)
								(cTbClie)->( DbDelete() )
							(cTbClie)->(MSUnlock())
						else
							RECLOCK(cTbClie,.F.)
								(cTbClie)->NUMPED := (cTbClie)->NUMPED - 1
							(cTbClie)->(MSUnlock())


						Endif

					Endif

					
				End Transaction

			Endif

		ENDIF

		(cTbPed)->(dbSkip())
		(cTbBlq)->(dbGoTop())
	EndDO
	(cTbPed)->(dbGoTop())
	oGrd20:oBrowse:Refresh()
	oGrd20:GoBottom()
	oGrd20:GoTop()
	oGrd20:Refresh(.T.)

	(cTbBlq)->(dbGoTop())
	oGrd30:oBrowse:Refresh()
	oGrd30:GoBottom()
	oGrd30:GoTop()
	oGrd30:Refresh(.T.)
		// oCabD4:oBrowse:Refresh()
	// oCabD4:GoBottom()
	// oCabD4:GoTop()
	// oCabD4:Refresh(.T.)
	// oDlg1:Refresh()

Return

/*/{Protheus.doc} Static Function PosicCli
	Botão Posição do Cliente
	@type  Function
	@author Abel Babini
	@since 03/05/2021
	/*/
Static Function PosicCli(_cCLI, _cLoj)
	SA1->( DbSetOrder( 1 ) )
	If SA1->( DbSeek( xFilial( 'SA1' ) + _cCLI + _cLoj ))
		//chama a funcionalidade de posicao do cliente 
		aRotina	:=	{{"Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
		{"Visualizar", "AxVisual" , 0 , 2},;  //"Visualizar"
		{"Consultar", "FC010CON" , 0 , 2},;  //"Consultar"
		{"Impressao", "FC010IMP" , 0 , 4}}   //"Impressao"
		Pergunte("FIC010",.T.)
		fc010con( 'SA1', SA1->( Recno() ), 2 )
	Endif

Return

/*/{Protheus.doc} Static Function xAtuRed
	Atualiza Dados de Rede
	@type  Function
	@author Abel Babini
	@since 04/05/2021
	/*/
Static Function xAtuRed(cCodRed)
	Local aAreaSZF    := SZF->(GetArea())
	Local cQryAtR := GetNextAlias()
	Local nLC    	:= 0
	Local nSld   	:= 0
	Local _nVenc 	:= 0
	Local _nAVenc	:= 0
	Local _dDT  := Date()
  Local _dDTA := (Date() + 1)

	BeginSQL alias cQryAtR
		SELECT 
			FONTE.ZF_REDE, 
			A1_CGC, 
			MAX(LC) AS LC, 
			SUM(ISNULL(SALDO,0)) AS SALDO, 
			SUM(VENC1+VENC2) AS VENC, 
			SUM(AVENC1+AVENC2) AS AVENC, 
			SZF.ZF_LCREDE, 
			SZF.ZF_SLDREDE, 
			SZF.ZF_VENCIDO, 
			SZF.ZF_AVENCER 
		FROM ( 
      SELECT 
				ZF_REDE,
				ZF_NOMERED,
				SUBSTRING(A1_CGC,1,8) AS A1_CGC, 
				A1_MSBLQL, 
        (CASE WHEN A1_LC>ZF_LCREDE THEN A1_LC         ELSE ZF_LCREDE END) AS LC,
				(CASE WHEN E1_TIPO = 'RA'  THEN E1_SALDO*(-1) ELSE E1_SALDO  END) AS SALDO,
				(CASE WHEN E1_TIPO = 'RA' AND (E1_VENCREA < %Exp:DTOS(_dDT)%) THEN E1_SALDO*(-1) ELSE 0  END) AS VENC1,
				(CASE WHEN E1_TIPO <> 'RA' AND (E1_VENCREA < %Exp:DTOS(_dDT)%) THEN E1_SALDO ELSE 0  END) AS VENC2,
				(CASE WHEN E1_TIPO = 'RA' AND (E1_VENCREA BETWEEN %Exp:DTOS(_dDT)% AND %Exp:DTOS(_dDTA)%) THEN E1_SALDO*(-1) ELSE 0  END) AS AVENC1,
				(CASE WHEN E1_TIPO <> 'RA' AND (E1_VENCREA BETWEEN %Exp:DTOS(_dDT)% AND %Exp:DTOS(_dDTA)%) THEN E1_SALDO ELSE 0  END) AS AVENC2
      FROM %TABLE:SZF% SZF (NOLOCK)
			LEFT JOIN %TABLE:SA1% SA1 (NOLOCK) ON
				LEFT(A1_CGC,8) = ZF_CGCMAT AND 
				SA1.%notDel%
			LEFT OUTER JOIN %TABLE:SE1% SE1 (NOLOCK) ON 
				A1_COD = E1_CLIENTE AND 
				A1_LOJA = E1_LOJA AND 
				E1_TIPO NOT IN ('PR','NCC','AB-') AND 
				E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') AND 
				E1_SALDO > 0  AND 
				SE1.%notDel%
      WHERE 
				ZF_REDE = %Exp:cCodRed% AND
				SZF.%notDel%
			) AS FONTE
		LEFT OUTER JOIN 
			(SELECT 
					SZF.ZF_CGCMAT, 
					SZF.ZF_LCREDE, 
					SZF.ZF_SLDREDE, 
					SZF.ZF_VENCIDO, 
					SZF.ZF_AVENCER  
				FROM %TABLE:SZF% SZF (NOLOCK) 
				WHERE SZF.%NotDel%
				) AS SZF ON  
			FONTE.A1_CGC = ZF_CGCMAT 
		GROUP BY 
			FONTE.ZF_REDE,
			A1_CGC, 
			SZF.ZF_LCREDE,
			SZF.ZF_SLDREDE,
			SZF.ZF_VENCIDO,
			SZF.ZF_AVENCER 
		HAVING 
			( 
				MAX(LC) <> SZF.ZF_LCREDE OR 
				SUM(ISNULL(SALDO,0)) <> SZF.ZF_SLDREDE OR 
				SUM(VENC1+VENC2) <> SZF.ZF_VENCIDO OR 
				SUM(AVENC1+AVENC2) <> SZF.ZF_AVENCER
			) 
		ORDER BY 
			FONTE.ZF_REDE, 
			LC DESC 
	EndSQL
	(cQryAtR)->(dbGoTop())
	WHILE ! (cQryAtR)->(eof())

		//Pula registro se as informações não mudaram
		If (cQryAtR)->LC = (cQryAtR)->ZF_LCREDE .And. (cQryAtR)->SALDO = (cQryAtR)->ZF_SLDREDE .And. (cQryAtR)->VENC = (cQryAtR)->ZF_VENCIDO .And. (cQryAtR)->AVENC = (cQryAtR)->ZF_AVENCER
			(cQryAtR)->(dbSkip())
			Loop 
		EndIf

		nLC    	:= (cQryAtR)->LC
		nSld   	:= (cQryAtR)->SALDO
		_nVenc 	:= (cQryAtR)->VENC
		_nAVenc	:= (cQryAtR)->AVENC

		//Grava Atualização na Rede
		DbSelectArea("SZF")
		SZF->(dbSetOrder(1))
		If SZF->(dbSeek( xFilial() + (cQryAtR)->A1_CGC ))

			u_GrLogZBE (Date(),TIME(),cUserName,"Saldo de Rede ZF_LCREDE","FINANCEIRO","ADFIN109P",;
			"CNPJ: "+ SZF->ZF_CGCMAT + " Saldo de: " + CVALTOCHAR(SZF->ZF_LCREDE) + " Saldo para: " + CVALTOCHAR(nLC),ComputerName(),LogUserName())

			RecLock("SZF",.F.)
				SZF->ZF_LCREDE  := nLC
				SZF->ZF_SLDREDE := nSld
				SZF->ZF_VENCIDO := _nVenc
				SZF->ZF_AVENCER := _nAVENC     
			MsUnlock()

		EndIf
		(cQryAtR)->(dbSkip())
	ENDDO
	(cQryAtR)->(dbCloseArea())

	RestArea(aAreaSZF)
Return

/*/{Protheus.doc} Static Function xAprvPed
	Botão Posição do Cliente
	@type  Function
	@author Abel Babini
	@since 04/05/2021
	/*/
Static Function xAprvPed()
	Local aAreaSC5    := SC5->(GetArea())
	Local aAreaSC9    := SC9->(GetArea())
	Private _nQtdLiber := 0
	Private lLiber	 := .F.
	Private	lTrans	 := .F.
	Private	lCredito := .T.
	Private	lEstoque := .T.
	Private	lAvCred	 := .F.
	Private	lAvEst	 := .F.

	IF Len(Alltrim(cParecer)) > 10 .AND. Len(Alltrim(cMotLib)) > 0
		IF MsgBox("Tem certeza que deseja liberar o(s) Pedido(s) marcados ?","CONFIRMACAO","YESNO")
			(cTbPed)->(dbGoTop())
			While !(cTbPed)->(eof())
				//TODO VERIFICAR O TIPO DE BLOQUEIO E SE O PEDIDO NÃO FOI FATURADO.
				//TODO AS REGRAS ABAIXO SE APLICAM APENAS PARA BLOQUEIO DE CRÉDITO.
				//TODO SE NÃO POSSUIR SC9, CONSIDERAR BLOQUEIO DE ESTOQUE E CRÉDITO. NA LIBERAÇÃO DEVE-SE GERAR O SC9

				IF (cTbPed)->OMARK == oGrd20:Mark() 
				
					If SC5->(dbSeek(xFilial("SC5")+(cTbPed)->NUMERO))

						//TODO NECESSÁRIO AVALIAR O PROPOCESSO DE BLOQUEIO COMERCIAL
						//TODO SUGESTÃO: SE NÃO ESTIVER LIBERADO COMERCIALMENTE, NÃO O FAZ, MAS REGISTRA NA ZEJ A LIBERAÇÃO
						//TODO ASSIM, QUANDO OCORRER A LIBERAÇÃO COMERCIAL E JÁ ESTIVER LIBERADO O CREDITO, NÃO PRECISARÁ MAIS LIBERAR O CRÉDITO, GERANDO SC9 SEM BLOQUEIOS.
						//Força liberação do pedido.
						// RecLock("SC5",.F.)
						// SC5->C5_BLQ     := " "
						// SC5->C5_LIBEROK := "S"
						// SC5->(MsUnlock())
						
						dbSelectArea("ZBE")
						RecLock("ZBE",.T.)
							Replace ZBE_FILIAL WITH xFilial("ZBE")
							Replace ZBE_DATA   WITH dDataBase
							Replace ZBE_HORA   WITH TIME()
							Replace ZBE_USUARI WITH UPPER(Alltrim(cUserName))
							Replace ZBE_LOG    WITH "PEDIDO " + SC5->C5_NUM + " C5_FLAGFIN: "+SC5->C5_FLAGFIN + " C5_XPREAPR: "+SC5->C5_XPREAPR
							Replace ZBE_MODULO WITH "SC5"
							Replace ZBE_ROTINA WITH "ADFIN109P"
						ZBE->(MsUnlock())

						//TODO VERIFICA SE EXISTE SC9. EM CASO AFIRMATIVO, VERIFICA SE POSSUI BLOQUEIO DE CRED E EST E LIBE. EM CASO NEGATIVO EXECUTA MALIBDOFAT ABAIXO
						DbSelectArea("SC9")
						SC9->(dbSetOrder(1))
						IF SC9->(dbseek(xFilial("SC9")+SC5->C5_NUM))
							WHILE SC9->(!Eof()) .And. SC5->C5_NUM == SC9->C9_PEDIDO

								IF Empty(Alltrim(SC9->C9_NFISCAL)) .AND. (!Empty(Alltrim(SC9->C9_BLCRED)) .or. !Empty(Alltrim(SC9->C9_BLEST)))
									RecLock("SC9",.F.)
										SC9->C9_BLEST		:= ''
										SC9->C9_BLCRED	:= ''
									SC9->(MsUnlock())
								ENDIF

								SC9->(dbSkip())
							ENDDO

						ELSE
							dbSelectArea("SC6")
							dbSetOrder(1)
							dbGotop()
							If dbSeek(xFilial("SC6")+SC5->C5_NUM)
								While SC6->(!Eof()) .And. SC5->C5_NUM == SC6->C6_NUM
									_nQtdLiber := SC6->C6_QTDVEN
									// RecLock("SC6")
									// Efetua a liberação item a item de cada pedido
									//Begin transaction
									MaLibDoFat( SC6->( Recno() ), @_nQtdLiber, @lCredito, @lEstoque, lAvCred, lAvEst, lLiber, lTrans )
									// MaLibDoFat( SC6->( RecNo() ), @_nQtdLiber, .F.      , .F.      , .T.    , .T.   , .T.   , .T.    )
									//End transaction
									// SC6->(MsUnLock())

									Begin Transaction
										SC6->(MaLiberOk({SC5->C5_NUM},.F.))
									End Transaction
									SC6->(dbSkip())
								EndDo
							EndIf
							DbSelectArea("SC9") //gravo a data de entrega e vendedor(carteira) para os pedidos liberados
							dbSetOrder(1)
							if dbseek(xFilial("SC9")+SC5->C5_NUM)
								While SC9->(!Eof()) .And. SC5->C5_NUM == SC9->C9_PEDIDO
									RecLock("SC9",.F.)
										SC9->C9_DTENTR := SC5->C5_DTENTR
										SC9->C9_VEND1  := SC5->C5_VEND1
									SC9->(MsUnlock())
									SC9->(dbSkip())
								EndDo
							Endif
						ENDIF
						
						If RecLock("SC5",.F.)
							SC5->C5_XPREAPR := "L"
							SC5->C5_FLAGFIN := "L"
							If Findfunction("U_ADVEN050P") .And. cEmpAnt == "01" .And. cFilAnt = "02" .And. Upper(Alltrim(cValToChar(GetMv("MV_#SFATUF")))) == "S"
								U_ADVEN050P(,.F.,.T., " AND C5_NUM IN ('" + SC5->C5_NUM + "') AND C5_XPEDSAL <> '' " ,.T.)
							EndIf
							SC5->(MsUnlock())

							//GRAVA REGISTRO DA LIBERAÇÃO DE CRÉDITO
							If RecLock("ZEJ",.T.)
								ZEJ->ZEJ_FILIAL	:= SC5->C5_FILIAL
								ZEJ->ZEJ_NUM		:= SC5->C5_NUM
								ZEJ->ZEJ_DTLIB	:= MsDate()
								ZEJ->ZEJ_HRLIB	:= TIME()
								ZEJ->ZEJ_USRLIB	:= cUserName
								ZEJ->ZEJ_VLLIB	:= (cTbPed)->TOTAL
								ZEJ->ZEJ_MOTLIB	:= ''
								ZEJ->ZEJ_PARECE	:= ''

								ZEJ->(MsUnlock())
							Endif

						EndIf
						
						// //WS BRADESCO - Pedidos Vendas com Adiantamento que não foram autorizados pelo retorno do CNAB 
						// FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
						// If FIE->( msSeek(FWxFilial("FIE")+"R"+SC5->C5_NUM) ) .or. AllTrim(Posicione("SE4",1,FWxFilial("SE4")+SC5->C5_CONDPAG,"E4_CTRADT")) == "1" // Cond Adiantamento = SIM 

						// 			// ticket 745 - FWNM - 30/09/2020 - C5_XWSPAGO com identificação para liberação manual
						// 			/*
						// 			RecLock("SC5", .f.)
						// 				SC5->C5_XWSPAGO := "S"
						// 			SC5->( msUnLock() )
						// 			*/

						// 			dbSelectArea("ZBE")
						// 			RecLock("ZBE", .T.)
						// 				Replace ZBE_FILIAL WITH FWxFilial("ZBE")
						// 				Replace ZBE_DATA   WITH msDate()
						// 				Replace ZBE_HORA   WITH TIME()
						// 				Replace ZBE_USUARI WITH UPPER(Alltrim(cUserName))
						// 				Replace ZBE_LOG    WITH "PV ADIANT N " + SC5->C5_NUM + " C5_XWSPAGO: " + SC5->C5_XWSPAGO + " LIBERADO FATURAMENTO MANUALMENTE"
						// 				Replace ZBE_MODULO WITH "SC5"
						// 				Replace ZBE_ROTINA WITH "ADFIN023P"
						// 			ZBE->( msUnLock() )

						// 		EndIf	
						// Apaga registro do browser de bloqueios
						(cTbBlq)->(dbGoTop())
						WHILE !(cTbBlq)->(eof())
							RECLOCK(cTbBlq,.F.)
								(cTbBlq)->( DbDelete() )
							(cTbBlq)->(MSUnlock())

							(cTbBlq)->(dbSkip())
						ENDDO
							
						RECLOCK(cTbPed,.F.)
							(cTbPed)->( DbDelete() )
						(cTbPed)->(MSUnlock())
					Endif

				ENDIF
				(cTbPed)->(dbSkip())
				(cTbBlq)->(dbGoTop())
			EndDO

			// (cTbPed)->(dbGoTop())
			
			IF (cTbPed)->(eof())
				RECLOCK(cTbClie,.F.)
					(cTbClie)->( DbDelete() )
				(cTbClie)->(MSUnlock())

				IF !(cTbClie)->(eof())
					(cTbClie)->(dbSkip())
				ELSE 
					(cTbClie)->(dbGoTop())
				endif

				// nRegTCli := (cTbClie)->(Recno())
				// nRegACli := oGrd10:oBrowse:At()

				(cTbClie)->(dbGoTop())
				oGrd10:oBrowse:Refresh()
				// oGrd10:GoBotom()
				oGrd10:GoTop()
				oGrd10:Refresh(.T.)
				// (cTbClie)->(dbGoTo(nRegTCli))
				
				// oGrd10:GoDown(1)
				// oGrd10:oBrowse:Goto(nRegACli+1, .F.)

			ENDIF

		ENDIF
	ELSE
		Alert('Não é possível liberar pedido sem informar o Parecer de Liberação! (Mínimo de 10 caracteres)')
	ENDIF

	// xChgLinC()	
	(cTbPed)->(dbGoTop())
	oGrd20:oBrowse:Refresh()
	oGrd20:GoBottom()
	oGrd20:GoTop()
	oGrd20:Refresh(.T.)

	(cTbBlq)->(dbGoTop())
	oGrd30:oBrowse:Refresh()
	oGrd30:GoBottom()
	oGrd30:GoTop()
	oGrd30:Refresh(.T.)

	RestArea(aAreaSC9)
	RestArea(aAreaSC5)
Return

/*/{Protheus.doc} Static Function xFcLbEst
	Processa Liberação de Estoque dos Pedidos.
	@type  Function
	@author Abel Babini
	@since 11/05/2021
	/*/
Static Function xFcLbEst(cPedDe, cPedAte, cCliDe, cLojDe, cCliAte, cLojAte, cRedDe, cRedAte)
	Private oProcess	

	oProcess := MsNewProcess():New({|| xLibEst(cPedDe, cPedAte, cCliDe, cLojDe, cCliAte, cLojAte, cRedDe, cRedAte)  },"Liberando Pedidos com bloqueio de estoque...","Liberação de Estoque",.T.)
	oProcess:Activate()
Return 

/*/{Protheus.doc} Static Function xLibEst
	Processa Liberação de Estoque dos Pedidos.
	@type  Function
	@author Abel Babini
	@since 11/05/2021
	/*/
Static Function xLibEst(cPedDe, cPedAte, cCliDe, cLojDe, cCliAte, cLojAte, cRedDe, cRedAte)
	Local aAreaSC5    := SC5->(GetArea())
	Local aAreaSC9    := SC9->(GetArea())
	Local cQryPed 		:= GetNextAlias()
	Local nRegCnt			:=	0
	Local nCount			:=	0

	BeginSQL alias cQryPed
		SELECT
			C5_FILIAL,
			C5_NUM,
			C6_ITEM
		FROM %TABLE:SC5% SC5 (NOLOCK)
		INNER JOIN %TABLE:SC6% SC6 (NOLOCK) ON
			SC6.C6_FILIAL = SC5.C5_FILIAL AND
			SC6.C6_NUM = SC5.C5_NUM AND
			SC6.C6_CLI = SC5.C5_CLIENTE AND
      SC6.C6_LOJA = SC5.C5_LOJACLI AND
			SC6.%notDel%
		LEFT JOIN %TABLE:SC9% SC9 (NOLOCK) ON
			SC9.C9_FILIAL = SC6.C6_FILIAL AND
			SC9.C9_PEDIDO = SC6.C6_NUM AND
			SC9.C9_CLIENTE = SC6.C6_CLI AND 
			SC9.C9_LOJA = SC6.C6_LOJA AND 
			SC9.C9_ITEM = SC6.C6_ITEM AND
			SC9.C9_PRODUTO = SC6.C6_PRODUTO AND
			SC9.%notDel%
    INNER JOIN %TABLE:SA1% SA1 (NOLOCK) ON
			A1_FILIAL = %xFilial:SA1%
      AND A1_COD = C5_CLIENTE
			AND A1_LOJA = C5_LOJACLI
      AND SA1.%notDel%
		WHERE
			SC5.C5_FILIAL = %xFilial:SC5% AND
			SC5.C5_DTENTR BETWEEN %Exp:DTOS(dDtIni)% AND %Exp:DTOS(dDtFim)% AND
			SC5.C5_NUM BETWEEN %Exp:cPedDe% AND %Exp:cPedAte% AND 
			SC5.C5_CLIENTE BETWEEN %Exp:cCliDe% AND %Exp:cCliAte% AND 
			SC5.C5_LOJACLI BETWEEN %Exp:cLojDe% AND %Exp:cLojAte% AND 
			SA1.A1_CODRED BETWEEN %Exp:cRedDe% AND %Exp:cRedAte% AND
			SC5.C5_NOTA = '' AND 
			SC9.C9_BLEST NOT IN ('','10') AND 
			SC5.%notDel%
	EndSQL

	Count to nCount
	oProcess:SetRegua1(nCount)
	(cQryPed)->(dbGoTop())

	WHILE ! (cQryPed)->(eof())	
		oProcess:IncRegua1("Registro " + StrZero( ++ nRegCnt,06) + " de " + StrZero(nCount,06) + " | Pedido: " + (cQryPed)->C5_NUM)

		SC5->(dbSeek(xFilial('SC5')+(cQryPed)->C5_NUM))
		IF SC9->(dbSeek(xFilial('SC9')+(cQryPed)->C5_NUM))

			WHILE ! SC9->(eof()) .AND. SC9->C9_PEDIDO == (cQryPed)->C5_NUM
				IF ALLTRIM(SC9->C9_BLEST) <> '' .AND. ALLTRIM(SC9->C9_BLEST) <> '10'
					MATA455(3,.T.)
				ENDIF
				
				SC9->(dbSkip())
			ENDDO

		ENDIF

		(cQryPed)->(dbSkip())
	ENDDO
	(cQryPed)->(dbCloseArea())

	RestArea(aAreaSC9)
	RestArea(aAreaSC5)
Return

/*/{Protheus.doc} Static Function InvSel
	Inverte Seleção dos Pedidos
	@type  Static Function
	@author Abel Babini Filho
	@since 11/05/2021
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

/*/{Protheus.doc} Static Function xRlRdSeg()
	Faz chamada do relatório Rede Segmento
	@type  Static Function
	@author Abel Babini Filho
	@since 11/05/2021
	@version 1
	/*/
Static Function xRlRdSeg()
	Local aArea  		:= GetArea()
	Local oCobranca	:= nil
	Local oMkRede		:= nil
	Local oMkFxPort	:= nil
	Local aCpoBro	:= {}
	Local oPnlFilt1  := TPanel():New(000,000,,oP02RE01,,.T.,,,,535,233,,)

	Private nTipoRel := 1
	Private cFiltRedeR	:="'"+ (cTbClie)->CODIGO+"'"
	Private cFiltCliR	:= "'"+(cTbClie)->CODIGO+(cTbClie)->LOJA+"'"
	Private nplanfat := 2 //mês
	Private nplanfin := 3 //dia
	Private dDtIniFat	:= CTOD('01/' + '01/' + CVALTOCHAR((YEAR(DATE()) - 1)))
	Private dDtFinFat	:= CTOD('31/' + '12/' + CVALTOCHAR((YEAR(DATE()))))
	Private dDtIniFin	:= CTOD('01/' + '01/' + CVALTOCHAR((YEAR(DATE()) - 1)))
	Private dDtFinFin	:= CTOD('31/' + '12/' + CVALTOCHAR((YEAR(DATE()))))
	Private lRetirarNCC := .T.
	Private lFiltroZero := .T.
	Private cFiltPortad	:= "''"

	Private oPrcRlRd

	If Select("TREDE") > 0
		TREDE->(DbCloseArea())
	EndIf

	oTempMRede := FWTemporaryTable():New("TREDE")
	aCampos := {}
	Aadd(aCampos,{"OK" 	   ,"C",02,0})
	Aadd(aCampos,{"TMP_RED"  ,"C",10,0})
	Aadd(aCampos,{"TMP_DESC" ,"C",40,0})
	oTempMRede:SetFields(aCampos)
	oTempMRede:AddIndex("01", {"TMP_RED"} )
	oTempMRede:Create()

	RecLock("TREDE",.T.)		
	TREDE->OK		:= ""
	TREDE->TMP_RED	:= (cTbClie)->CODIGO
	TREDE->TMP_DESC	:= (cTbClie)->NOME
	MsunLock()

	Aadd(aCpoBro,{"OK"	     ,, ""})		
	Aadd(aCpoBro,{"TMP_RED"  ,,"Rede"})	
	Aadd(aCpoBro,{"TMP_DESC" ,,"Nome"})

	oMkRede := MsSelect():New("TREDE","OK","",aCpoBro ,.F.,gETmARK() ,{1000,1000,1,1},,,oPnlFilt1,,)
	// oMkRede:bMark := {| | DispRede(oMkRede,cMark)} 
	// oMkRede:oBrowse:bAllMark := {|| RedeInvert(oMkRede,cMark) }
	// Eval(oMkRede:oBrowse:bGoTop)
	oMkRede:oBrowse:Refresh()

	If Select("TCLI") > 0
		TCLI->(DbCloseArea())
	EndIf

	oTempMCli := FWTemporaryTable():New("TCLI")
	aCampos := {}
	Aadd(aCampos,{"OK" 	     ,"C",02,0})
	Aadd(aCampos,{"TMP_COD"  ,"C",06,0})
	Aadd(aCampos,{"TMP_LOJA" ,"C",02,0})
	Aadd(aCampos,{"TMP_NOME" ,"C",40,0})
	oTempMCli:SetFields(aCampos)
	oTempMCli:AddIndex("01", {"TMP_COD"} )
	oTempMCli:Create()

	// StaticCall(ADFIN071R,geraRelatorio,oCobranca,oPnlFilt1,oMkRede,oMkFxPort)
	oPrcRlRd := MsNewProcess():New({|| StaticCall(ADFIN071R,geraRelatorio,oCobranca,oPnlFilt1,oMkRede,oMkFxPort)  },"Aguarde a geração do relatório...","Relatório Rede Segmento",.T.)
	oPrcRlRd:Activate()

	oPnlFilt1:FreeChildren()

	RestArea(aArea)
Return
