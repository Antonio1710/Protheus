
#INCLUDE "PROTHEUS.CH"  
#INCLUDE "WINAPI.CH"
#INCLUDE "FIVEWIN.CH"
#include "topconn.ch"

/*/{Protheus.doc} User Function nomeFunction
	Primeira Pesagem (Peso da Tara do Veiculo )
	@type  Function
	@author Daniel Pitthan Silveira
	@since 11/07/2005
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
/*/
User Function AD0131()  

	Local _cRet := ""

	U_ADINF009P('AD0130' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Primeira Pesagem (Peso da Tara do Veiculo ) ')

	SetPrvt("_CALIAS,_NINDEX,_NRECNO")

	_aArea:=GetArea()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Iniciando Variaveis                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private _cContrSeq :=  'MV_SEQGUIA'

	//Incluido 26/09/11 - Ana. Atendendo chamado 010470. Pois de um dia para outro o sistema nao atualiza a data base, gravando sempre a data do dia de logon no sistema.
	DDATABASE := Date() 

	Public  _dDatGuia  :=  DDATABASE
	Private _dDatTela  :=  DTOC(DDATABASE)


	dbSelectArea("ZV1")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Iniciando Variaveis                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//_nGuia  := GETSXENUM("ZV2",NIL)   //STRZERO(VAL(ZV2->ZV2_GUIA) + 1,6)
	// Pegar numero de parametro para sequencia de guia
	// Incrementa para cada Pesagem
	Public _nGuia  := space(6)            //Número da Guia
	Public _cPlac  := space(07)           //Número da Placa
	Public  _kmSai := 0                   //KM de Saída da Granja

	Private _Obs    :=space(100)          //OBS
	Private _Motori :=space(50)           //Nome do Motorista
	Private _Ordem  := space(06)          //Número da Ordem
	Private nTamLin := 12				  // Tamanho da linha no arquivo texto
	Private cBuffer := Space(nTamLin+2)   // Variavel para leitura
	Private _cText  := Space(50)
	Private _cLinha := space(50)
	Private _cCaract:= space(1)
	Private _hora   := TIME()             //Hora de pesagem
	Private _PriPeso:= 0                  //Primeiro Peso
	Private nHdl    := NIL                // Handle para abertura do arquivo
	Private nBytes  := 0                  // Variavel para verificacao do fim de arquivo

	Private nContr	   := 0
	Private _hPort 	   := 1
	Private _nTempo    := 500
	//Private _cPorta    := "COM1:9600,n,8,1"
	Private _cPorta := Iif(cFilAnt == '06',"COM1:4800,e,7,2","COM1:9600,n,8,1") // LEONARDO (HC) PARA ALTERAR OS PARAMETROS DA BALANCA DE ITUPEVA (06)
	Private _cConfirm  := 'S'
	Private _dData    :=  Date()

	//VAR		TIPO	        CAMPO DO SX3010         DESCRIÇÃO

	Private  _dDatBat		:=Space(8) 	//ZV1_DTAABAT  			DATA DE ABATE
	Private  _cRGranj		:=""		//ZV1_RGRANJ			INTEGRADO
	Private  _nPeso1		:=Space(6)	//ZV1_PESO1				PRIMEIRO PESO
	Private  _nKmEnt		:=0			//ZV2_KmEnt				KM ENTRADA
	Private  _dRhCarr    	:=Space(5)	//ZV1_RhCarr			HORÁRIO DE CHEGADA NA GRANJA
	Private  _dRhVP 		:=Space(5)	//ZV1_RhVP		    	HORÁRIO DE CHEGADA EM VP
	Private  _cCliBal    	:=Space(1)	//ZV1_CliBal            CLIMA NA BALANÇA
	Private  _cCliCar    	:=Space(1)  //ZV1_CliCar            CLIMA NO CARREGAMENTO
	Private  _cCliVol		:=Space(1)	//ZV1_CliVol			CLIMA NA VOLTA
	Private  _nNumNfsF	    :=Space(6)	//ZV1_NumNfs            NÚMERO DA NOTA FISCAL
	Private  _cTBal	    	:=Space(1)  //ZV2_TIPOPE			TIPO DE BALANÇA
	Private  _nCODFOR		:=SPACE (6) //Codigo do Fornecedor
	Private  _nLOJFOR		:=SPACE (6) //Loja do Fornecedor
	Private  _nLacreA		:=space(15) //Numero de Lacre
	Private  _nLacreB		:=space(15) //Numero de Lacre
	Private  _cPlacR		:=space(8)  //Placa Realizada
	Private  _cSerie		:=SPACE(4)  //serie da NF
	Private  _dDtaBtR  	                //data de abate eftivamente realizada
	Private  _nNumNf 	            	//NF
	Private  _nCODFNF               	//fornecedor da NF
	Private  _cSerie		:=SPACE(2)  //serie da NF
	Private  _nLojNF 		            //loja da NF


	//FIM


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ATRIBUINDO VARIAVEIS DA TABELA DE FRANGO VIVO  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private  _ORDEM	   :=ZV1->ZV1_NUMOC      //Retorna o numero da ordem
	Private  _dDatBat  :=ZV1->ZV1_DTABAT     //Retorna a data de abate
	Private  _cRGranj  :=ZV1->ZV1_RGRANJ     //Retorna o Integrado
	Private  _cPlac    :=ZV1->ZV1_PPLACA     //Retorna a Placa
	Private  _cPlacP   :=ZV1->ZV1_PPLACA     //Retorna a Placa
	Private  _cPlacR   :=ZV1->ZV1_RPLACA     //Retorna a Placa
	Private  _nGuia    :=ZV1->ZV1_GUIAPE     //Numero da Guia de Pesagem
	Private  _dRhCarr  :=ZV1->ZV1_RHCARR     //HORA DE CARREGAMENTO
	Private  _dRhVP	   :=ZV1->ZV1_RHVP	     //HORA DE CHEGADA EM VP
	Private  _cCliBal  :=ZV1->ZV1_CLIBAL     //CLIMA NA BALANCA
	Private  _cCliCar  :=ZV1->ZV1_CLICAR     //CLIMA NO CARREGAMENTO
	Private  _cCliVol  :=ZV1->ZV1_CLIVOL     //CLIMA NA VOLTA
	Private  _nNumNfsF :=ZV1->ZV1_NUMNFSF    //NUMERO DA NF
	Private  _nCODFOR  :=ZV1->ZV1_CODFOR     //Codigo do Fornecedor
	Private  _nLOJFOR  :=ZV1->ZV1_LOJFOR     //Loja  do Fornecedor
	Private  _nLojNf   :=ZV1->ZV1_LOJREC     //LOJA RECEBIDA
	Private  _nCODFNF  :=ZV1->ZV1_FORREC     //FORNECEDOR RECEBIDO
	Private  _nNumNf   :=ZV1->ZV1_NUMNFSF    //NF
	Private  _cSerie   :=ZV1->ZV1_SERIE      //SERIE DA NF
	Private  _cRGranj  :=ZV1->ZV1_RGRANJ     //Integrado Realizado
	Private  _cStatus  :=ZV1_STATUS          //STATUS DO FRANGO VIVO
	PRIVATE cFlgInt  := ZV1->ZV1_INTEGR  ///chamado 043188 20/08/2018 -Fernando Sigoli
	PRIVATE cNumOC   := ZV1->ZV1_NUMOC //fernando sigoli 21/08/2018

	//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ sH¿
	//³Na base de dados do Configurador o campo ZV2_Obs1 teve seu³
	//³tamanho do campo aumentado para 100 para não estorar      ³
	//³o tamanho do campo na hora de gravação.                   ³
	//³                                                          ³
	//³Acrescentado ZV1_Horeg -> registra a hora da guia,        ³
	//³ZV1_Guiape -> registra o número da guia                   ³
	//³                                                          ³
	//³                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ sHÙ
	//

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico se já tem frete gerado
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If  _cStatus = 'G'
		Alert ("ABORTANDO O PROCESSO, JA FOI GERADO FRETE O.C. " +_ORDEM)
		RestArea(_aArea)
		Return(.T.)	
	Endif

	If cFlgInt = 'I'
		MsgAlert ("Atenção, Ordem ja integrada no SAG. Alteração nao permitida! " + cvaltochar(cNumOC)) //chamado 043188 20/08/2018 -Fernando Sigoli
		RestArea(_aArea)
		Return  .F.
	EndIf



	/////   *** /// ****
	// Texto da balança
	//  00000900010000090000000001
	//  12345687901234568790123456
	//           10        20
	// Abrir porta

	_nResult := -1
	If cFilAnt == '06' // LEONARDO (HC) PARA AJUSTAR O TAMANHO DO RETORNO DA BALANCA DE ITUPEVA (FILIAL 06)
		If MsOpenPort(_hPort, _cPorta )
			Do While _nResult < 0
				_cText := ''
				MSRead(_hPort, @_cText)
				// Forço mensagem para ver o retorno
				_nPos   := 1
				_nPosFin := Len(_cText)
				Do While _nPos <= _nPosFin
					_cCaract = substr(_cText,_nPos,2)
					If  _cCaract = "  "
						_nPosStr = _nPos+2
						_PriPeso  := VAL(SUBSTR(_cText,_nPosStr,5))
						Exit
					Endif
					_nPos++
				Enddo
				// Faço ler a serial por quinze vezes
				If AllTrim(_cText)== ""
					Sleep(_ntempo)
					If !MsgBox(" Deseja Continuar ? ", " Atenção " , "YESNO")
						_nResult := 0
						_cConfirm := 'N'
					End
				Else
					_nResult := 0
				Endif
				_nTempo += 500
			Enddo
			Mscloseport(_hport)
		else
			msgbox("Não Conectou!")
		End
	Else //OUTRAS FILIAIS
		If MsOpenPort(_hPort, _cPorta )      //   .and.   _nResult = 10000
			
			Do While _nResult < 0
				_cText := ''
				MSRead(_hPort,@_cText)
				
				
				_nPos    := 1
				_nPosFin := Len(_cText)
			
				Do While _nPos <= _nPosFin
					_cCaract = substr(_cText,_nPos,2)
					If  _cCaract = "  "
						_nPosStr = _nPos+2
						
						_PriPeso  :=VAL(SUBSTR(_cText,_nPosStr,9))
						
						Exit
					Endif
					_nPos++
				Enddo
						
				If AllTrim(_cText)== ""
					Sleep(_ntempo) 
					If !_MsgBox(" Deseja Continuar ? ", " Atenção ")
						_nResult := 0
						_cConfirm := 'N'
					End
					
				Else
					_nResult := 0
				Endif
				_nTempo += 500
			Enddo
			Mscloseport(_hport)
		else
			MsgInfo("Não Conectou!")
		End
	EndIf

	If _cConfirm = 'S'	
		If _PriPeso >= 60000  // Limite maximo da balança
			Alert("Peso NAO estabilizado, ou cabo desconectado !!")
		Endif
		// Se já tem primeira pesagem pego o numero da guia anterior
		If val(_nGuia) = 0		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³SEQUENCIAL DA GUIA                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SX6")
			DbSetorder(1)
			
			If dbSeek("  "+_cContrSeq)
				RecLock("SX6",.F.)  // com .f. sem append blank
				Replace  X6_CONTEUD   With STRZERO(VAL(X6_CONTEUD)+1,6)              // Guia da Portaria
				_nGuia  := strzero(val(X6_CONTEUD),6)
				MsUnlock()
			Endif
		Else
			
			// Atualizo as variaveis conforme digitacao anterior
			dbSelectArea("ZV2")
			dbSetOrder(1)
			If DbSeek(xFilial("ZV2") +_nGuia)
				_KmSai    := ZV2_KMSAI
				_nKmEnt   := ZV2_KMENT
				_PriPeso  := ZV2_1PESO
				_cTBal	  :=SUBSTR(ZV2->ZV2_OBS3,1,1) // TIPO DA BALANCA
				_Obs	  := ZV2->ZV2_OBS1
			Endif
		Endif
		dbSelectArea("ZV1") 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³MONTANDO A TELA DE AQUISICOES DE DADOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	DEFINE MSDIALOG _oDlg TITLE "Primeira Pesagem Frango Vivo             "+DTOC(DATE())+" - "+TIME()+"" FROM (356),(304) TO (676),(780) PIXEL
		// Cria as Groups do Sistema
		@001,002 TO 039,240 LABEL "Ordem de Carregamento:                         " PIXEL OF _oDlg
		@  (002), (173) TO  (038), (239) LABEL ""  PIXEL OF _oDlg
		// Cria Componentes Padroes do Sistema 
		@  (000), (070) Say _ORDEM 									Size  (020), (008) COLOR CLR_RED   PIXEL OF _oDlg
		@  (006), (197) Say "PESO" 									Size  (016), (008) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (009), (140) Say _cPlacP				 					Size  (033), (008) COLOR CLR_GREEN PIXEL OF _oDlg
		@  (010), (091) Say "Placa Programada:" 					Size  (047), (008) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (011), (050) Say _nGuia	 								Size  (035), (008) COLOR CLR_GREEN PIXEL OF _oDlg
		@  (012), (030) Say "Guia:" 								Size  (014), (008) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (019), (187) Say _PriPeso 								Size  (038), (008) COLOR CLR_RED   PIXEL OF _oDlg
		@  (020), (049) Say _dDatBat  PICTURE "D99/99/9999"			Size  (043), (008) COLOR CLR_GREEN PIXEL OF _oDlg
		@  (020), (140) Say SUBSTR (_cRGranj,1,4)					Size  (026), (008) COLOR CLR_GREEN PIXEL OF _oDlg
		@  (021), (112) Say "Integrado:" 							Size  (026), (008) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (022), (007) Say "Data de Abate:" 						Size  (038), (008) COLOR CLR_BLACK PIXEL OF _oDlg 
		@  (042), (015) Say "Nota Fiscal" 							Size  (028), (008) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (042), (050) MsGet o_nNumNf Var _nNumNf PICTURE '999999'	Size  (060), (009) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (042), (175) MsGet o_cSerie Var _cSerie 					Size  (060), (009) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (043), (155) Say "Série" 								Size  (014), (008) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (053), (050) MsGet o_nCodFor Var _nCodFor F3 "INT" PICTURE '999999' 	Size  (060), (009) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (053), (159) Say "Loja" 												Size  (012), (008) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (053), (175) MsGet o_nLojFor Var _nLojFor  PICTURE '99'  Valid(VFornec(_nCODFOR,_nLOJFOR))	Size  (060), (009) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (054), (006) Say "Integrado Rec." 									Size  (037), (008) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (064), (007) Say "Fornecedor NF" 									Size  (037), (008) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (064), (050) MsGet o_nCodFnF Var _nCodFnF PICTURE '999999'			Size  (060), (009) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (064), (175) MsGet o_nLojNf Var _nLojNf 	PICTURE '99' 				Size  (060), (009) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (065), (158) Say "Loja" 												Size  (012), (008) COLOR CLR_BLACK 	PIXEL OF _oDlg
		@  (076), (003) Say "Placa Recebida" 									Size  (040), (008) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (076), (050) MsGet o_cPlacR Var _cPlacR F3 "A05" 					Size  (060), (009) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (086), (151) Say "Lacre B" 											Size  (020), (008) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (087), (050) MsGet o_nLacreA Var _nLacreA PICTURE '99999999999999'	Size  (060), (009) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (086), (175) MsGet o_nLacreB Var _nLacreB PICTURE '99999999999999'  Size  (060), (009) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (088), (023) Say "Lacre A" 											Size  (020), (008) COLOR CLR_BLACK 	PIXEL OF _oDlg
		@  (098), (050) MsGet o_KmSai Var _KmSai  picture '999999999999' Valid (VKmSai(_kmSai))		Size  (060), (009) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (097), (175) MsGet o_KmEnt Var _nKmEnt picture '999999999999' Valid (VKmEnt(_nKmEnt))		Size  (060), (009) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (098), (142) Say "Km Entrada" 										Size  (029), (008) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (099), (018) Say "Km Saída" 											Size  (025), (008) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (108), (017) Say "Hora Carr." 										Size  (026), (008) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (108), (135) Say "Hora Chegada" 										Size  (036), (008) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (109), (050) MsGet o_dRhCarr Var _dRhCarr Picture "99:99"    Valid((substr(_dRhCarr,1,2)<"24"  .or.  substr(_dRhCarr,3,2)<"60") .and. empty()) 	Size  (060), (009) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (109), (175) MsGet o_drhVp Var 	_drhVp    Picture "99:99"    Valid((substr(_drhVp,1,2)<"24"  .or.  substr(_drhVp,3,2)<"60") .and. empty())		Size  (060), (009) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (120), (017) Say "Clima Carr." 										Size  (027), (008) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (120), (143) Say "Clima Volta" 										Size  (028), (008) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (121), (050) MsGet o_cClicar Var _cClicar Valid (VClima(_cCliCar))	Size  (060), (009) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (120), (175) MsGet o_cClivol Var _cClivol Valid (VClima(_cClivol))	Size  (060), (009) COLOR CLR_BLACK PIXEL OF _oDlg	
		@  (132), (028) Say "OBS." 												Size  (014), (008) COLOR CLR_BLACK PIXEL OF _oDlg
		@  (132), (050) MsGet o_Obs Var _Obs 									Size  (186), (009) COLOR CLR_BLACK PIXEL OF _oDlg  
		DEFINE SBUTTON FROM  (150), (184) TYPE 1 ENABLE OF _oDlg ACTION (GravaPriPeso())
		DEFINE SBUTTON FROM  (150), (212) TYPE 2 ENABLE OF _oDlg ACTION  Close()
		ACTIVATE MSDIALOG _oDlg CENTERED    
	Endif

	RestArea(_aArea)

Return

	/*	
	@ 000,000 TO 500,750 DIALOG TelaZVi1 TITLE "PRIMEIRA PESAGEM FRANGO VIVO - GUIA DE PESAGEM"
	nLin := 5
	@ nLin,005 SAY "DATA       : "
	@ nLin,030 SAY _dDatTela
	@ nLin,070 say _hora
	@ nLin,100 SAY "DATA GUIA: "
	//	@ nLin,135 SAY DTOC(_dDatGuia)
	@ nLin,135 SAY DTOC(_dData)
	@ nLin,165 SAY "Data Abate Prevista: "
	@ nLin,220 SAY DTOC(_dDatBat )
	//	@ nLin,250 SAY "Data Abate Realizada: "
	//	@ nLin,320 GET _dDtaBtR  PICTURE "D99/99/9999"
	nLin := nLin + 20
	@ nlin,005 SAY "ORDEM CARREG.: "
	@ nLin,050 SAY _ORDEM
	@ nLin,070 SAY "NUMERO GUIA: "
	@ nLin,120 SAY _nGuia
	@ nLin,150 SAY "NF.:"
	@ nLin,170 GET _nNumNf PICTURE '999999'
	@ nLin,200 SAY "SERIE:"
	@ nLin,240 GET _cSerie
	nLin := nLin + 20
	@ nLin,005 SAY "Integrado: "
	@ nLin,030 SAY  SUBSTR (_cRGranj,1,4)
	@ nLin,050 SAY "INT. REC."
	@ nLin,080 GET _nCODFOR F3 ("INT") PICTURE '999999'
	@ nLin,120 SAY "Loja Rec.: "
	@ nLin,155 GET _nLOJFOR  PICTURE '99'   Valid(VFornec(_nCODFOR,_nLOJFOR))
	@ nLin,185 SAY "FORNEC. NF:"
	@ nLin,225 GET _nCODFNF  PICTURE '999999'
	@ nLin,260 SAY "Loja: "
	@ nLin,285 GET _nLojNF  PICTURE '99'
	nLin := nLin + 20
	@ nLin,005 SAY "PLACA: "
	@ nLin,050 SAY  _cPlac
	@ nLin,100 SAY "PLACA REC."
	@ nLin,150 GET _cPlacR F3("A05")
	@ nLin,200 SAY "LACRE [A]: "
	@ nLin,240 GET _nLacreA
	@ nLin,270 SAY "LACRE [B]: "
	@ nLin,310 GET _nLacreB
	nLin := nLin + 20
	@ nLin,100 SAY "PESO: "
	@ nLin,150 SAY _PriPeso
	nLin := nLin + 20
	@ nLin,005 SAY "KM SAIDA: "
	@ nLin,050 GET  _KmSai  Picture "9999999999" Valid (VKmSai(_kmSai))
	@ nLin,100 SAY "KM ENTRADA: "
	@ nLin,150 GET  _nKmEnt  Picture "9999999999" Valid (VKmEnt(_nKmEnt))
	nLin := nLin + 20
	@ nLin,005 SAY "HORÁRIOS"
	nLin := nLin + 20
	@ nLin,005 SAY "CHEGADA:"
	@ nLin,050 SAY "GRANJA:"
	@ nLin,100 GET _dRhCarr Picture "99:99" Valid((substr(_dRhCarr,1,2)<"24"  .or.  substr(_dRhCarr,3,2)<"60") .and. empty())
	@ nLin,150 SAY "VÁRZEA PTA.:"
	@ nLin,200 GET _DrHvp   Picture "99:99" Valid((substr(_DrHvp,1,2)<"24"  .or.  substr(_DrHvp,3,2)<"60").and. empty())
	nLin := nLin + 20
	@ nLin,005 SAY "CLIMA SECO [S] MOLHADO [M]"
	nLin := nLin + 20
	@ nLin,070 SAY "TEMPO CARRREGAMENTO:"
	@ nLin,150 GET _cCliCar 				Valid (VClima(_cCliCar))
	@ nLin,200 SAY "CLIMA NA VOLTA:"
	@ nLin,250 GET _cCliVol  				Valid (VClima(_cCliVol))
	nLin := nLin + 20
	@ nLin,005 SAY "OBS1:"
	@ nLin,050 get _Obs Picture "@!"
	nLin := nLin + 20
	@ nLin,260 BMPBUTTON TYPE 01 ACTION GravaPriPeso()
	@ nLin,290 BMPBUTTON TYPE 02 ACTION Close(TelaZVi1)
	
	ACTIVATE DIALOG TelaZVi1 CENTER
	*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ GravPriPeso  ³ Gravacao da Informa‡oes                                 ³±±
±±³              ³                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Marcos Bido  | 20/07/02 ³ Funcao de Gravacao                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 

Static Function GravaPriPeso()

//&&Chamado 005670 - Mauricio 13/01/10. Nao permitir inclusao de NF/SERIE/FORNEC/LOJA ja utilizada em outra OC.
IF SELECT("VZV1") > 0
   DbSelectArea("VZV1")
   VZV1->(DbCloseArea())
ENDIF   

_cQuery := " SELECT ZV1_NUMOC, ZV1_NUMNFS, ZV1_SERIE, ZV1_CODFOR, ZV1_LOJFOR "
_cQuery += " FROM "+retsqlname("ZV1") +" (NOLOCK) 
_cQuery += " WHERE ZV1_FILIAL='"+FWxFilial("ZV1")+"' " // @history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
_cQuery += " AND RTRIM(LTRIM(ZV1_NUMNFS)) = '"+ALLTRIM(_nNumNF)+"' and "
_cQuery += " RTRIM(LTRIM(ZV1_SERIE)) = '"+ALLTRIM(_cSerie)+"' and "
_cQuery += " ZV1_FORREC = '"+_nCodFnf+"' and ZV1_LOJREC = '"+_nLojNf+"' and "
_cQuery += " D_E_L_E_T_ <> '*' ORDER BY ZV1_NUMOC"

TcQuery _cQuery New Alias "VZV1"
 
DbSelectArea("VZV1")
VZV1->(dbGoTop())
If !eof()
   If VZV1->ZV1_NUMOC <> _ORDEM      && Verifica se nao esta alterando uma OC.
      MsgInfo("A NF/SERIE "+_nNumNf+" / "+_cSerie+" informada ja foi utilizada na OC: "+VZV1->ZV1_NUMOC+" para o Fornecedor/loja: "+_nCodFor+" / "+_nLojFor+" .A Pesagem nao foi gravada.")
      VZV1->(DbCloseArea())
      _oDlg:END()
      Return(.T.)
   endif     
Endif
//&& fim chamado 005670.

DBSELECTAREA("SA2")
DBSETORDER(1)
IF DBSEEK(Xfilial("SA2") + _nCODFOR,.T.)
	_nLoj:=A2_LOJA
	_cIntReal:=A2_INTCOD
ELSE
	_cIntReal:=_cRGranj
ENDIF
DBCLOSEAREA("SA2")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ATUALIZADO TABELA ZV2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("ZV2")
dbSetOrder(1)
If DbSeek(xFilial("ZV2") +_nGuia)
	MsgInfo("Ja existe 1a. pesagem para placa "+Transform(_cPlac,"@R !!!-9999")+" nesta data."+Chr(10))
	RecLock("ZV2",.F.)
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ANALISO TIPO DE BALANCA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cDesTip := ''
	If _cTBal = 'E'
		_cDesTip := _cTBal + "ELETRONICA"
	Else
		If _cTBal = 'M'
			_cDesTip := _cTBal + "MECANICA"
		Else
			_cDesTip := _cTBal + "NAO TEM "
		Endif
	Endif
	
	RecLock("ZV2",.T.)
		ZV2->ZV2_FILIAL := FWxFilial("ZV2") // @history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
		Replace ZV2_TIPOPE	With	"F"
		Replace ZV2_GUIA    With _nGuia
		Replace ZV2_HORA1   With _hora
		Replace ZV2_DATA1   With _dData
		Replace ZV2_PLACA   With _cPlac
		Replace ZV2_KMSAI   With _KmSai
		Replace ZV2_KMENT	With _nKmEnt
		Replace ZV2_1PESO   With _PriPeso
		Replace ZV2_OBS1	With _Obs
		Replace ZV2_OBS3    With _cDesTip  //TIPO DE BALANCA
		Replace ZV2_ROTEIRO With _Ordem
		Replace ZV2_LACRE   With _nLacreA
		Replace ZV2_LACREB  With _nLacreB
	ZV2->( MsUnlock() )

Endif


DbSelectArea("ZV1")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ATUALIZANDO TABELA ZV1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura ambiente inicial                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(_aArea)

RecLock("ZV1", .F.)
	Replace ZV1_DATA 		With _dDatGuia
	Replace ZV1_GUIAPE		With _nGuia
	Replace ZV1_DTABAT  	With _dDatBat
	Replace ZV1_RHCARR		with _dRhCarr
	Replace ZV1_RHVP		with _dRhVP
	Replace ZV1_CLIBAL      With _cCliBal
	Replace ZV1_CLICAR      With _cCliCar
	Replace ZV1_CLIVOL		With _cCliVol
	Replace ZV1_NUMNFSF     With _nNumNf
	Replace ZV1_SERIE 		With _cSerie
	Replace ZV1_CODFOR		With _nCODFOR
	Replace ZV1_LOJFOR      with _nLOJFOR
	Replace ZV1_RPLACA		With _cPlacR
	Replace ZV1_LACRE1  	With _nLacreA
	Replace ZV1_LACRE2  	With _nLacreB
	Replace ZV1_LOJREC		with _nLojNf
	Replace ZV1_FORREC		with _nCODFNF
	Replace ZV1_RGRANJ	   	with  _cIntReal
	REPLACE ZV1_STATUS 		WITH 'I'  
	REPLACE ZV1_TARAPD		WITH TARAPD(_cPlacR)
ZV1->( MsUnlock() )
//endif

	_oDlg:END()
Return(.T.)  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³PROCURA A TARA PADRAO PARA O VEICULO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

STATIC FUNCTION TARAPD(_placa)
	Local _tara:=0
    DBSELECTAREA("ZV4")
    DBSETORDER(1)
    IF DBSEEK(xFilial("ZV1")+_placa,.T.)
	     _TARA:=ZV4->ZV4_PESO
    ELSE 
         _TARA:=0
    ENDIF            
    RESTAREA(_aArea)
Return (_tara)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
//³VERIFICA A VALIDACAO DE CAMPO E EXIBE A MSN NA TELA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
//validacao do clima
Static Function VClima (_cSts)
	If (_cSts="S" .or. _cSts="M")
		_cSts:=.T.
	Else
		_cSts:=.F.
	EndIf
Return (_cSts)

//validacao do tipo de pesagem
Static Function VTbalanca (_cSts)
	If (_cTBal="E" .or. _cTBal="M" .or. _cTBal="N")
		_cSts:=.T.
	Else
		_cSts:=.F.
	EndIf
Return (_cSts)

//validacao do KM
Static Function VKmSai (_cSts)
	If (_cSts > 0)
		_cSts:=.T.
	Else
		Alert("KM DE SAÍDA DEVE SER MAIOR QUE ZERO")
		_cSts:=.F.
	EndIf
Return (_cSts)

Static Function VKmEnt (_cSts)
	If (_cSts > _KmSai)
		_cSts:=.T.
	Else
		Alert("KM DE ENTRADA DEVE SER MAIOR QUE DE SAÍDA")
		_cSts:=.F.
	EndIf
Return (_cSts)

//VALIDA FORNECEDOR DO INTEGRADO/FORNECEDOR PRODUTO
Static Function VFornec (_nCODFOR , _nLOJFOR )
//verificando o tipo da variavel e tornando ela numerica
DbSelectArea("SA2")
DbSetOrder(1)
If DbSeek(xFilial("SA2") +_nCODFOR + _nLOJFOR  )
	_cSts =  .T.
Else
	Alert(" FORNECEDOR INVALIDO ! ! ! ")
	_nCODFOR  := '  '
	_nLOJFOR 	:= ' '
	_cSts =  .F.
ENDIF
Return (_cSts)          

//Fecha a janela
Static Function Close()
    RestArea(_aArea)
	_oDlg:END()
Return (.T.)

Static Function _MSGBOX(cMsm,cTit)
 Local _lRet:=.F.                           	//retorno                       
 Local _stopBlc:={|| _lRet:=.F.,_oMsg:END()}	//retorno falso
 Local _GoBlc:=  {|| _lRet:=.T.,_oMsg:END()}  	//retorno verdadeiro

	DEFINE MSDIALOG _oMsg TITLE cTit FROM (178),(181) TO (246),(526) PIXEL
		// Cria Componentes Padroes do Sistema
		@ (007),(004) Say cMsm Size (166),(011) COLOR CLR_BLACK PIXEL OF _oMsg
		DEFINE SBUTTON FROM (022),(115) TYPE 1 ENABLE OF _oMsg ACTION (Eval(_GoBlc))
		DEFINE SBUTTON FROM (022),(143) TYPE 2 ENABLE OF _oMsg ACTION (Eval(_stopBlc))		
	ACTIVATE MSDIALOG _oMsg CENTERED  
	
Return (_lRet) 
