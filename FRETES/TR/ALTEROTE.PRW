#include "rwmake.ch"
#include "TOPCONN.CH"

/*/{Protheus.doc} User Function ALTEROTE
	Alteracao do Roteiro e Sequencia de Entrega de Produtos O Advanced Protheus nao permite alteracao. Especifico Ad'oro Alimenticia 
	@type  Function
	@author Marcos Bido
	@since 20/11/2001
	@version 01
	@history Chamado TI   - DANIEL PITTHAN SILVEIRA - 27/10/2006 - ALTERADO O 'SET FILTER' PELO FILTRO DA MICROSIGA
	@history Chamado 4992 - William Costa           - 24/11/2020 - Adicionado no Filtro para ver notas que estão com 'XXXXXX' que são notas denegadas ou Canceladas, e conseguir limpar a Placa delas.
	@history Chamado 5657 - William Costa           - 26/11/2020 - Voltado versão de limpa placa, pq não deu certo o jeito que foi pensado será feito na tela de Ocorrências de Devoluções.
	@history Chamado TI   - Leonardo P. Monteiro    - 21/01/2022 - Gravação de log de acesso a rotina.
/*/

User Function ALTEROTE()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Alteracao do Roteiro e Sequencia de Entrega de Produtos')
	SetPrvt("CCADASTRO,AROTINA,")

	dbSelectArea("SC5")
	
	SC5->(DBORDERNICKNAME("SC5_6")) //atualização protheus 12 WILLIAM COSTA 28/12/2017 CHAMADO 036032

	//Variaveis utilizadas para parametros                         
	//mv_par01             // Do Roteiro                           
	//mv_par02             // Ate Roteiro                          
	//mv_par03             // Da Emissao                           
	//mv_par04             // Ate Emissao                          
	
	u_GrLogZBE( Date(),;
                TIME(),;
                cUserName,;
                "Altera Roteiro Manual",;
                "LOGISTICA",;
                "ALTEROTE",;
                "Acesso do usuário "+Alltrim(cUserName)+" à rotina para alteração manual dos roteiros.",;
                ComputerName(),;
                LogUserName())

	cPerg   := "GERABO"                                   

	Pergunte(cPerg,.T.)
	Public _DtEntr := MV_PAR05

	//Filtra os pedidos que ja foram liberado pelo credito e nao foram faturados
	//FILTRO MICROSIGA                                                    
	
	Private _cCond     := "C5_FILIAL == '" + xFilial("SC5") + "' .AND. DTOS(C5_DTENTR) >= '"+ALLTRIM(DTOS(MV_PAR03))+"' .AND. DTOS(C5_DTENTR) <= '"+ALLTRIM(DTOS(MV_PAR04))+"' .AND. " + ; 
	                      "C5_ROTEIRO >= '" + ALLTRIM(MV_PAR01)+"' .AND. C5_ROTEIRO <= '" + ALLTRIM(MV_PAR02)+"' .AND. C5_LIBEROK == 'S' .AND. EMPTY(C5_NOTA) .AND. C5_BLQ <> '1' "
	Private aIndSC5    := {}
	Private bFiltraBrw := {|| FilBrowse( "SC5", @aIndSC5, @_cCond ) }


	CCadastro := "Alteracao do Roteiro de Entrega "
	aRotina   := {{ "Pesquisar  "        ,"AxPesqui"               , 0 , 1},;                                         
	              { "Visualizar  "       ,"axVisual"               , 0 , 2},;
	              { "Bairro -> Roteiro"  ,'ExecBlock("ABAIRRO")'   , 0 , 3},;
	              { "Roteiro-> Roteiro"  ,'ExecBlock("AVENDE")'    , 0 , 4},;
	              { "Alterar Roteiro  "  ,'ExecBlock("ARote")'     , 0 , 5},;
	              { "Placa X Roteiro  "  ,'ExecBlock("AD0055")'    , 0 , 6},;
	              { "Limp. Placa "       ,'ExecBlock("UnRote")'    , 0 , 7},;
	              { "Insp. Sanitaria "   ,'ExecBlock("ASIF")'      , 0 , 7},;
	              { "Env. SF. "          ,'U_placaSFexp()'         , 0 , 8}}

	dbSelectArea("SC9")
	Dbsetorder(1)

	dbSelectArea("SZC")
	dbSetOrder(1)

	Eval( bFiltraBrw )
	Processa( {|| ProcX() },"Aguarde Verificando Pedidos ..." )
	dbSelectArea("SC5")
	dbGoTop()

	mBrowse( 06, 01, 22, 75, "SC5" )

	EndFilBrw( "SC5", aIndSC5 )

RETURN

//GRAVA PESO BRUTO NO SC5
STATIC FUNCTION PROCX()

	IF cFILANT <> "06"  //Mauricio somente para teste de correção 06/07/11.

		dbSelectArea("SC5")
		dbGoTop()
		PROCREGUA(RECCOUNT())

		DO WHILE !EOF()

			INCPROC(SC5->C5_NUM+" "+SC5->C5_CLIENTE)

			_cNumPed    := SC5->C5_NUM
			_cCliente   := SC5->C5_CLIENTE
			_cLoja      := SC5->C5_LOJACLI

			_nTotalCx   := 0
			_nTotalPedi := 0
			_nTotalKg   := 0
			_nTotalBr   := 0

			//Posiciona SC5 e SC6, a partir do pedido                             

			dbSelectArea("SC9")
			dbSetOrder(1)
			IF dbSeek( xFilial("SC9") + _cNumPed )

				Do While !Eof() .AND. SC9->C9_PEDIDO == _cNumPed

					dbSelectArea("SB1")
					dbSetOrder(1)
					dbSeek(xFilial("SB1") + SC9->C9_PRODUTO)      

					_nTotalCx   := _nTotalCx   + SC9->C9_QTDLIB2   // Soma qtd caixas (2a. UM)
					_nTotalKg   := _nTotalKg   + IIF(SB1->B1_SEGUM="BS",0,SC9->C9_QTDLIB)   // Soma qtd peso   <1a. UM)//alterado por Adriana, se bolsa nao soma 1a unidade como peso

					//Posiciona Cadastro de Tara                                          
					
					dbSelectArea("SZC")
					dbSetOrder(1)
					IF dbSeek( xFilial("SZC") + SB1->B1_SEGUM )

						_nTotalBr   := _nTotalBr + (SC9->C9_QTDLIB2 * SZC->ZC_TARA) // PESO BRUTO

					ELSE

						IF Alltrim(SB1->B1_SEGUM) <> ""                            //Incluido 12/07/11 - Ana. Tratamento para peso duplicado

							_nTotalBr   := _nTotalBr + (SC9->C9_QTDLIB  * 1)       // PESO BRUTO

						ELSE

							_nTotalBr   := _nTotalBr                               // PESO BRUTO				

						ENDIF
					ENDIF

					dbSelectArea("SC9")
					dbSkip()

				ENDDO
			ENDIF

			//Grava Informacoes em SC5                                            
			
			dbSelectArea("SC5")
			RecLock("SC5",.F.)

				// Ricardo Lima - 23/10/18	  
				IF SC5->C5_EST <> 'EX'

					IF cEmpAnt == "02"	

						Replace C5_PBRUTO  With _nTotalKg

					ELSE

						Replace C5_PBRUTO  With _nTotalBr + _nTotalKg	

					ENDIF
				ENDIF

				// Ricardo Lima - 23/10/18	  

				IF SC5->C5_EST <> 'EX'

					Replace C5_PESOL   With _nTotalKg
					Replace C5_VOLUME1 With _nTotalCx

				ENDIF

			MsUnlock()

			dbskip()
		ENDDO
	ENDIF

RETURN

/*/{Protheus.doc} User Function placaSFexp
	Função para envio de registro ao SalesForce.
	@type  Function
	@author Everson
	@since 02/04/2018
	@version 01
/*/

User Function placaSFexp()

	Local aArea	   	:= GetArea()

	U_ADINF009P('ALTEROTE' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Alteracao do Roteiro e Sequencia de Entrega de Produtos')

	IF !MsgYesNo("Deseja enviar o(s) registro(s) referentes ao roteiro " + Alltrim(cValToChar(SC5->C5_ROTEIRO)) + "-" + Alltrim(DToC(SC5->C5_DTENTR)) + " ao SalesForce?","Função placaSFexp (ALTEROTE)")

		RestArea(aArea)
		RETURN(NIL)

	ENDIF

	IF FindFunction("U_ADVEN050P") .And. cEmpAnt == "01" .And. cFilAnt == "02"

		IF Upper(Alltrim(cValToChar(GetMv("MV_#SFATUL")))) == "S"

			U_ADVEN050P("",,," AND C5_ROTEIRO = '" + Alltrim(cValToChar(SC5->C5_ROTEIRO)) + "' AND C5_DTENTR = '" + Alltrim(DToS(SC5->C5_DTENTR)) + "' AND C5_XPEDSAL <> '' ",,,,,,.T.)
		
		ENDIF
		
	ENDIF

	RestArea(aArea)

RETURN(NIL)
