#include "FiveWin.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function nomeFunction
	Pesagem Manual
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
	@history Ticket TI    - Adriano Savoine - 08/04/2022 - Correção para o Error Log Alias already in use: VZV1
/*/
User Function AD0144()  

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Pesagem Manual')

	SetPrvt("_CALIAS,_NINDEX,_NRECNO")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Guarda ambiente inicial                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_aArea:=GetArea()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Iniciando Variaveis                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//Incluido 26/09/11 - Ana. Atendendo chamado 010470. Pois de um dia para outro o sistema nao atualiza a data base, gravando sempre a data do dia de logon no sistema.
	DDATABASE := Date() 

	Private _cContrSeq :=  'MV_SEQGUIA'
	Public  _dDatGuia  :=  DDATABASE
	Private _dDatTela  :=  DTOC(DDATABASE)
	Public _nGuia  := space(6)            //Número da Guia
	Public _nGuiaV1:= space(6)
	Public _cPlac  				          //Número da Placa
	Public  _kmSai := 0                   //KM de Saída da Granja

	Private _hora   := TIME()             //Hora de pesagem

	Private _cSts     := .F.
	PRIVATE _dDatBat	:=Space(8) 		//ZV1_DTAABAT  			DATA DE ABATE
	PRIVATE _cRGranj	:=""			//ZV1_RGRANJ			INTEGRADO
	PRIVATE _nPeso1		:=Space(6)		//ZV1_PESO1				PRIMEIRO PESO
	PRIVATE _nKmEnt		:=0				//ZV2_KmEnt				KM ENTRADA
	PRIVATE _dRhCarr 	:=Space(5)		//ZV1_RhCarr			HORÁRIO DE CHEGADA NA GRANJA
	PRIVATE _dRhVP 		:=Space(5)		//ZV1_RhVP		    	HORÁRIO DE CHEGADA EM VP
	PRIVATE _cCliBal    :=Space(1)		//ZV1_CliBal            CLIMA NA BALANÇA
	PRIVATE _cCliCar    :=Space(1)      //ZV1_CliCar            CLIMA NO CARREGAMENTO
	PRIVATE _cCliVol	:=Space(1)		//ZV1_CliVol			CLIMA NA VOLTA
	PRIVATE _nNumNfsF	:=Space(6)		//ZV1_NumNfs            NÚMERO DA NOTA FISCAL
	PRIVATE _cTBal		:=Space(1)      //ZV2_TIPOPE			TIPO DE BALANÇA
	PRIVATE _PriPeso    :=0         	          		   			//Primeiro Peso
	PRIVATE _SegPeso    :=0  					  		   			//Segundo Peso
	PRIVATE _nCODFOR	:= SPACE(6)                    				//CODIGO FORNECEDOR
	PRIVATE _nLOJFOR 	:= SPACE(2)                    				//LOJA  FORNECEDOR
	Private _nLacre1	:=space(15)									//Lacre
	Private _nLacre2	:=space(15)									//Lacre
	Private _cPlacR		:=space(8)									//Placa recebida
	Public _dDtaBtR     := DDATABASE   	//data realizada de abate
	Public _nPesTer     := 0   			// Peso de Terceiros
	Private _nLiq     := 0				//peso liquido
	Private _nLoj					//loja do fornecedor  realisado
	Private _nCODFNF 				//fornecedor da NF
	Private	_nLojNF	 				//loja de NF
	Private	_nNumNf  := Space(6) 	//numero da NF
	Private	_cSerie  := Space(3) 	//Serie da NF
	pRIVATE _nPesTP:=0
	PRIVATE _nPesTR:=0
	Private _cTipPes := 'F'      		// Tipo da Pesagem
	PRIVATE _cStatus :=ZV1_STATUS   	// STATUS DO FRANGO VIVO
	PRIVATE _ORDEM 	:=ZV1->ZV1_NUMOC 	// Numero Ordem
	PRIVATE _dRhAbt//HORA DE ABATE
	PRIVATE _Obs:=SPACE(100)
	PRIVATE _PCIDAD:=""					//CIDADE PROGRAMADA
	PRIVATE _cContrSeq := 'MV_SEQGUIA'//PARAMETRO SEQUENCIA DA GUIA   
	PRIVATE _nPesOrig:=0
	PRIVATE cFlgInt  := ZV1->ZV1_INTEGR  ///chamado 043188 20/08/2018 -Fernando Sigoli
	PRIVATE cNumOC   := ZV1->ZV1_NUMOC //fernando sigoli 21/08/2018

	If cFlgInt = 'I'
		MsgAlert ("Atenção, Ordem ja integrada no SAG. Alteração nao permitida! " + cvaltochar(cNumOC)) //chamado 043188 20/08/2018 -Fernando Sigoli
		RestArea(_aArea)
		Return  .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico se já tem frete gerado
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If  _cStatus = 'G'
		Alert ("ABORTANDO O PROCESSO, JA FOI GERADO FRETE O.C. " +_ORDEM)
		RestArea(_aArea)
		Return
	Endif


	//Procuro o parametro de para desconto do peso liquido
	//quanto tiver peso da balanca com opcao "M" molhado

	_nParQueb:= Getmv("MV_PORQUEB")
	_nPrcQueb:= VAL(_nParQueb)

	//Procuro o parametro de para calculo do peso  liquido
	//de origem
	_nPesOrig:= Getmv("MV_PORCENT")


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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³OBTENDO VARIAVEIS DA GUIA DE CARREGAMENTO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Private cAliasZV1   := Alias()
	Private cOrderZV1  := IndexOrd()
	Private cRecnoZV1 := Recno()


	_nGuia 	  	:=ZV1->ZV1_GUIAPE
	_nGuiaV1    :=ZV1->ZV1_GUIAPE
	_nCODFOR	:=ZV1->ZV1_CODFOR
	_nLOJFOR    :=ZV1->ZV1_LOJFOR
	_nCODFNF	:=ZV1->ZV1_FORREC
	_nLojNF		:=ZV1->ZV1_LOJREC
	_cSerie   	:=ZV1->ZV1_SERIE
	If  DTOS(ZV1->ZV1_DTAREA) > "20060101"
		_dDtaBtR    :=ZV1->ZV1_DTAREA		  //DATA DE ABATE REALIZADA
	Endif
	_dDatGuia	:=ZV1->ZV1_DATA
	_dDatBat	:=ZV1->ZV1_DTABAT
	_dRhCarr	:=ZV1->ZV1_RHCARR
	_dRhVP		:=ZV1->ZV1_RHVP
	_cCliBal	:=ZV1->ZV1_CLIBAL
	_cCliCar	:=ZV1->ZV1_CLICAR
	_cCliVol	:=ZV1->ZV1_CLIVOL
	_nNumNf     :=ZV1->ZV1_NUMNFS
	_nPesTer    :=ZV1->ZV1_PESONF //PESO DE TERCEIRO
	_cPlac		:=ZV1->ZV1_PPLACA
	_ORDEM		:=ZV1->ZV1_NUMOC
	_cRGranj 	:=ZV1->ZV1_RGRANJ
	_nPESLIQ	:=ZV1->ZV1_PESLIQ
	_cPlacR		:=ZV1->ZV1_RPLACA
	_nPesTR		:=ZV1->ZV1_PESOME*ZV1->ZV1_RAVES //Peso Total REALIZADO
	_nPesTP		:=ZV1->ZV1_PESOME*ZV1->ZV1_RAVES //Peso Total  PROGRAMADO
	_dRhAbt		:=ZV1->ZV1_RHABAT				  //hora de abate
	_PCIDAD		:=ZV1->ZV1_PCIDAD                //CIDADE PROGRAMADA
	_nLacre1	:=ZV1->ZV1_LACRE1
	_nLacre2	:=ZV1->ZV1_LACRE2
	_Obs	    :=ZV1->ZV1_OBS
	_cQuery     := ""


	dbSelectArea("ZV2")
	dbSetOrder(1)
	If DbSeek(xFilial("ZV2") + _nGuia,.T.)
		_hora		:=ZV2->ZV2_HORA1
		_KmSai		:=ZV2->ZV2_KMSAI
		_nKmEnt		:=ZV2->ZV2_KMENT
		_PriPeso	:=ZV2->ZV2_1PESO
		_SegPeso	:=ZV2->ZV2_2PESO
		_cTBal		:=SUBSTR(ZV2->ZV2_OBS3,1,1) // TIPO DA BALANCA
	Endif

	IF EMPTY(_nGuia)
		_cQuery := " SELECT MAX(ZV2_GUIA) AS ZV2_GUIA "
		_cQuery += " FROM "+retsqlname("ZV2") + " (NOLOCK) "
		_cQuery += " WHERE ZV2_FILIAL='"+FWxFilial("ZV2")+"' " // @history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
		_cQuery += " AND D_E_L_E_T_='' "
		
		TcQuery _cQuery New Alias "VZV2"
	
		DbSelectArea("VZV2")
		VZV2->(dbGoTop())	
		
		_nGuia:= ALLTRIM(STR(VAL(VZV2->ZV2_GUIA)+1))
		
		DbCloseArea("VZV2")
	ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³MONTANDO A TELA DE AQUISICOES DE DADOS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	EndDlg := {||RestArea(_aArea),_oDlg:End()}

	_cSerie := "01"

	DEFINE MSDIALOG _oDlg TITLE "Pesagem Manual      " +DTOC(Date())+" - " +TIME()  FROM (247),(412) TO (734),(757) PIXEL
	// Cria as Groups do Sistema
	@ (000),(003) TO (040),(175) LABEL "Ordem de Carregamento:                             " PIXEL OF _oDlg

	// Cria Componentes Padroes do Sistema
	@ (000),(070) Say _ORDEM 																	Size (025),(008) COLOR CLR_RED PIXEL OF _oDlg
	@ (007),(005) Say "Guia:" 																	Size (014),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (007),(057) Say _nGuia 																	Size (019),(008) COLOR CLR_GREEN PIXEL OF _oDlg
	@ (020),(005) Say "Data do Programa" 														Size (045),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (020),(057) Say _dDatGuia 																Size (031),(008) COLOR CLR_GREEN PIXEL OF _oDlg
	@ (020),(092) Say "Data Abate " 															Size (030),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (020),(125) Say _dDatBat 																	Size (031),(008) COLOR CLR_GREEN PIXEL OF _oDlg
	@ (030),(005) Say "Integrado Prog." 														Size (038),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (030),(057) Say _cRgranj 																	Size (023),(008) COLOR CLR_GREEN PIXEL OF _oDlg
	@ (030),(092) Say "Placa Prog:" 															Size (029),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (030),(125) Say _cPlac 																	Size (018),(008) COLOR CLR_GREEN PIXEL OF _oDlg
	@ (045),(005) Say "Número da NF" 															Size (036),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (045),(047) MsGet o_nNumNF Var _nNumNF valid	NumNfs(_nNumNF)								Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (045),(092) Say "Série" 																	Size (014),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (045),(125) Say _cSerie 																	Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (060),(005) Say "Data Abt Real" 															Size (035),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (060),(047) MsGet o_dDtaBtR Var _dDtaBtR PICTURE 'D99/99/9999'								Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (060),(092) Say "Hora Abt" 																	Size (013),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (060),(125) MsGet o_hora Var _dRhAbt PICTURE '99:99'	Valid((substr( _dRhAbt,1,2)<"24"  .or.  substr(_dRhAbt,3,2)<"60") .and. empty())		Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (071),(047) MsGet oEdit3 Var _nCODFNF 													Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (071),(124) MsGet oEdit4 Var _nLojNF 														Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (075),(005) Say "Fornecedor NF:" 															Size (039),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (075),(092) Say "Loja" 																	Size (012),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (083),(047) MsGet o_nCODFOR Var _nCODFOR F3 "INT" Size (040),(009) Valid GetLjForn( _nCODFOR ) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (083),(125) MsGet o_nLOJFOR Var _nLOJFOR Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (085),(005) Say "Integrado Rec." 																Size (037),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (088),(092) Say "Loja" 																		Size (012),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (097),(005) Say "Placa Rec." 																	Size (028),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (097),(047) MsGet o_cPlacR Var _cPlacR F3 "A05" 												Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (110),(005) Say "Lacre A" 																	Size (020),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (110),(047) MsGet o_nLacre1 Var _nLacre1 PICTURE '99999999999999999'							Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (110),(092) Say "Lacre B" 																	Size (020),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (110),(125) MsGet o_nLacre2 Var _nLacre2 PICTURE '99999999999999999'							Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (124),(005) Say "1° Peso" 																	Size (020),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (124),(047) MsGet o_PriPeso Var _PriPeso PICTURE '99999999999' Valid(VPriPeso(_PriPeso))		Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (124),(092) Say "2° Peso" 																	Size (020),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (124),(125) MsGet o_SegPeso Var _SegPeso PICTURE '99999999999' Valid(VSegPeso(_SegPeso))		Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (137),(005) Say "Peso Terceiro" 																Size (035),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (137),(047) MsGet o_nPesTer Var _nPesTer 	PICTURE '99999999999'													Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (150),(005) Say "KM Saida" 																	Size (025),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (150),(047) MsGet o_KmSai Var _KmSai PICTURE '999999' Valid (VKmSai(_kmSai))															Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (150),(092) Say "KM Entrada" 																	Size (030),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (150),(125) MsGet o_nKmEnt Var _nKmEnt PICTURE '999999' Valid (VKmEnt(_nKmEnt))														Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (163),(005) Say "Chegada Granj." 																Size (039),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (163),(047) MsGet o_dRhCarr Var _dRhCarr PICTURE '99:99'  	Valid((substr(_dRhCarr,1,2)<"24"  .or.  substr(_dRhCarr,3,2)<"60") .and. empty())									Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (163),(092) Say "Chegada VP" 																	Size (032),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (163),(125) MsGet o_dRhVp Var _dRhVp 	PICTURE '99:99'	Valid((substr(_DrHvp,1,2)<"24"  .or.  substr(_DrHvp,3,2)<"60").and. empty())										Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (176),(005) Say "Tipo Balanca" 																Size (033),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (176),(047) MsGet o_cTbal Var _cTbal 		Valid (VTbalanca(_cTBal))							Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (189),(005) Say "Clima Carr." 																Size (027),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (189),(047) MsGet o_cClicar Var _cClicar 	Valid (VClima(_cCliCar))							Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (189),(092) Say "Clima Volta" 																Size (028),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (189),(125) MsGet o_cCliVol Var _cCliVol 	Valid (VClima(_cCliVol))							Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (203),(005) Say "Clima Balanca" 																Size (035),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (203),(047) MsGet o_cCliBal Var _cCliBal 	Valid (VClima(_cCliBal))							Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (216),(005) Say "OBS:" 																		Size (014),(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ (216),(027) MsGet o_Obs Var _Obs 																Size (138),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	DEFINE SBUTTON FROM (229),(109) TYPE 2 ENABLE OF _oDlg ACTION Eval(EndDlg)
	DEFINE SBUTTON FROM (229),(139) TYPE 1 ENABLE OF _oDlg ACTION (Grava())
	ACTIVATE MSDIALOG _oDlg CENTERED
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura ambiente inicial                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea(cAliasZV1)
	dbSetOrder(cOrderZV1)
	dbGoto(cRecnoZV1)


	RestArea(_aArea)

Return

/*
@000,000 TO 500,750  DIALOG TelaZVi1 TITLE "PESAGEM MANUAL"
nLin := 5
@ nLin,005 SAY "DATA       : "
@ nLin,030 SAY _dDatTela
@ nLin,070 GET _hora
@ nLin,100 SAY "DATA GUIA: "
@ nLin,135 SAY DTO(_dDatGuia)
@ nLin,165 SAY "Data Abate Prevista: "
@ nLin,220 SAY DTO(_dDatBat )
@ nLin,250 SAY "Data Abate Realizada: "
@ nLin,320 GET _dDtaBtR  PICTURE "99/99/9999"
nLin := nLin + 20
@ nlin,005 SAY "ORDEM CARREG.: "
@ nLin,050 SAY _ORDEM
@ nLin,070 SAY "NUMERO GUIA: "
@ nLin,120 SAY _nGuia
@ nLin,150 SAY "NF.:"
@ nLin,170 GET _nNumNf picture '999999'
@ nLin,200 SAY "SERIE:"
@ nLin,240 GET _cSerie picture '@!'
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
@ nLin,230 GET _nLacre1
@ nLin,260 SAY "LACRE [B]: "
@ nLin,300 GET _nLacre2
nLin := nLin + 20
@ nLin,005 SAY "1º PESO: "
@ nLin,040 GET _PriPeso Picture "999999"  Valid(VPriPeso(_PriPeso))
@ nLin,070 SAY "2º PESO: "
@ nLin,110 GET _SegPeso Picture "999999"  Valid(VSegPeso(_SegPeso))
@ nLin,150 SAY "KM SAIDA: "
@ nLin,180 GET  _KmSai  Picture "99999999" Valid (VKmSai(_kmSai))
@ nLin,220 SAY "KM ENTRADA: "
@ nLin,270 GET  _nKmEnt Picture "99999999" Valid (VKmEnt(_nKmEnt))
nLin := nLin + 20
@ nLin,005 SAY "                             HORÁRIOS"
@ nLin,220 SAY " PESO TERC./ORI."
@ nLin,270 GET  _nPesTer  Picture "999,999"
nLin := nLin + 25
@ nLin,005 SAY "CHEGADA:"
@ nLin,050 SAY "GRANJA:"
@ nLin,100 GET _dRhCarr Picture "99:99" Valid((substr(_dRhCarr,1,2)<"24"  .or.  substr(_dRhCarr,3,2)<"60") .and. empty())
@ nLin,150 SAY "VÁRZEA PTA.:"
@ nLin,200 GET _DrHvp   Picture "99:99" Valid((substr(_DrHvp,1,2)<"24"  .or.  substr(_DrHvp,3,2)<"60").and. empty())
nLin := nLin + 20
@ nLin,005 SAY "BALANÇA ELETRONICA [E]   MECANICA [M]   NÃO TEM [N]"
@ nLin,250 SAY "CLIMA SECO [S] MOLHADO [M]"
nLin := nLin + 20
@ nLin,005 SAY "BALANÇA: "
@ nLin,050 GET _cTBal     			    Valid (VTbalanca(_cTBal))
@ nLin,070 SAY "TEMPO CARRREGAMENTO:"
@ nLin,150 GET _cCliCar 				Valid (VClima(_cCliCar))
@ nLin,200 SAY "CLIMA NA VOLTA:"
@ nLin,250 GET _cCliVol  				Valid (VClima(_cCliVol))
@ nLin,290 SAY "CLIMA NA BALANÇA:"
@ nLin,350 GET _cCliBal                	Valid (VClima(_cCliBal))
nLin := nLin + 20
@ nLin,005 SAY "OBS1:"
@ nLin,050 get _Obs Picture "@!"
nLin := nLin + 30
@ nLin,300 BMPBUTTON TYPE 01 ACTION GravaPriPeso()
@ nLin,340 BMPBUTTON TYPE 02 ACTION Close(TelaZVi1)

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
Static Function Grava()
_PesOrigem := 0
//Calculo peso liquido
_nPESLIQ := (_PriPeso)-(_SegPeso)
_nQbr := 0
//CALCULA A QUEBRA CASO O PARAMETRO SE MOLHADO
//VERIFICO SE TEM O VALOR DO PERCENTUAL DE QUEBRA NO PARAMETRO
IF _nPrcQueb <> 0 .AND. _cCliVol = "M"
	// Forco subtrair o percentual de quebra
	_nVlrPerc := 1 - (_nPrcQueb / 100)
	// Multiplico pelo fator de quebra
	_nQbr := (_nLiq - (_nLiq * _nVlrPerc))  // "E R R A D O"
	//_nQbr := (_nPESLIQ - (_nPESLIQ * _nVlrPerc))          "C E R T O"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do Tempo de espera              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_hEsp:=SUBTHORAS(_dDatBat,_dRHVP,_dDtaBtR ,_dRhAbt)



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


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ATUALIZADO TABELA ZV2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("ZV2")
dbSetOrder(2)
//If DbSeek(xFilial("ZV2") +'F'+ _cPlac +DTOS(dDatabase))

/*VERIFICANDDO SE EXITE 1o PESAGEM  E ATUALIZANDO DADOS*/
                                                 
/*
Ana - 25/07/14. Ajustado para não considerar o ZV1_PPLACA (programado) e sim o ZV1_RPLACA (realizado), pois após integração entre edata x protheus foi
identificado que o sistema criava a ZV2 com a placa incorreta quando ZV1_PPLACA <> ZV1_RPLACA, o correto é criar a guia ZV2 com base no ZV1_RPLACA (realizado)
//If Dbseek(xFilial("ZV2") + _nGuia + _cPlac,.T.)
*/
If Dbseek(xFilial("ZV2") + _nGuia + _cPlacR,.T.)
	
	MSGINFO("Ja existe 1a. pesagem para placa "+Transform(_cPlac,"@!")+" nesta data."+Chr(10))

	RecLock("ZV2",.F.)
		Replace ZV2_TIPOPE	With _cTipPes  // Pesagem Frango Vivo
		Replace ZV2_HORA1   With _dRhAbt	   //HORA DE ABATE
		Replace ZV2_PLACA   With _cPlacR //_cPlac    //PLACA  --22/08/14 - ANA. Ajustado pois houve mais casos de duplicidade
		Replace ZV2_KMSAI   With _KmSai    //KM SAI
		Replace ZV2_KMENT	With _nKmEnt   //KM DE ENTRATA
		Replace ZV2_1PESO   With _PriPeso  //PRIMEIRO PESO
		Replace ZV2_2PESO   With _SegPeso  //SEGUNDO PESO
		Replace ZV2_OBS1	With _Obs      //OBS
		Replace ZV2_OBS3    With _cDesTip  //TIPO DE BALANCA
		Replace ZV2_LACRE   With _nLacre1  //LACRE FRENTE
		Replace ZV2_LACREB  With _nLacre2  //LCRE TRAZ
		Replace ZV2_PERDIF  With 0 //este campo e obrigatorio
		Replace ZV2_MANUAL  With 'S'  //este campo e obrigatorio
	ZV2->( MsUnlock() )

Else 

	RecLock("ZV2",.T.)
		ZV2->ZV2_FILIAL := FWxFilial("ZV2") // @history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
		Replace ZV2_TIPOPE	With _cTipPes
		Replace ZV2_GUIA    With _nGuia     //GUIA
		Replace ZV2_HORA1   With _dRhAbt      //HORA
		Replace ZV2_DATA1   With _dDatGuia  //DATA DA GUIA
		Replace ZV2_PLACA   With _cPlacR //_cPlac    //PLACA  --22/08/14 - ANA. Ajustado pois houve mais casos de duplicidade
		Replace ZV2_KMSAI   With _KmSai     //KM SAI
		Replace ZV2_KMENT	With _nKmEnt    //KM ENT
		Replace ZV2_1PESO   With _PriPeso   //PRIMEIRO PESO
		Replace ZV2_2PESO   With _SegPeso   //SEGUNDO PESO
		Replace ZV2_OBS1	With _Obs       //OBS
		Replace ZV2_OBS3    With Alltrim(_cDesTip) + " ORD: " + Alltrim(_ORDEM) + " USU: "+ Alltrim(__CUSERID) //TIPO DE BALANCA
		Replace ZV2_LACRE   With _nLacre1   //LACRE FRENTE
		Replace ZV2_LACREB  With _nLacre2   //LACRE TRAZ
		Replace ZV2_PERDIF  With 0     //este campo e obrigatorio
		Replace ZV2_MANUAL  With 'S'  //este campo e obrigatorio
	ZV2->( MsUnlock() )

Endif

dbCloseArea("ZV2")


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ATUALIZANDO TABELA ZV1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DBSELECTAREA("SA2")
DBSETORDER(1)
IF DBSEEK(Xfilial("SA2") + _nCODFOR + _nLOJFOR ,.T.)
	_nLoj:=A2_LOJA
	_cIntReal:=A2_INTCOD
ELSE
	_cIntReal:=_cRGranj
ENDIF
DBCLOSEAREA("SA2")


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura ambiente inicial                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(_aArea)

// Calculo o peso de Origem
_PesOrigem :=  (   _PriPeso  -  ZV1_TARAPD + ZV1_QTDQBR ) + ( (_PriPeso -  ZV1_TARAPD + ZV1_QTDQBR )  *  VAL( _nPesOrig)/100 )

RecLock("ZV1", .F.)
Replace ZV1_GUIAPE 		with _nGuia
Replace ZV1_RHCARR		with _dRhCarr     //HOARA DE CARREGAMENTO
Replace ZV1_RHVP		with _dRhVP       //HORA DE CHGADA EM VP
Replace ZV1_CLIBAL      With _cCliBal     //CLIMA NA BALANÇA
Replace ZV1_CLICAR      With _cCliCar     //CLIMA NO CARREGAMENTO
Replace ZV1_CLIVOL		With _cCliVol     //CLIMA NA VOLTA
Replace ZV1_PPLACA      With _cPlac       //PLACA PREVISTA
Replace ZV1_RPLACA		With _cPlacR      //PLACA REALIZADA
Replace ZV1_RGRANJ	    With _cIntReal    //INTEGRADO REALIZADO
Replace ZV1_CODFOR		with _nCODFOR     //INTEGRADO REALIZADO
Replace ZV1_PESONF      with _nPesTer     //PESO DE TERCEIRO
Replace ZV1_FORREC		with _nCODFNF     //FORNECEDOR
Replace ZV1_LOJREC		With _nLojNF        //LOJA RECEBIDA
Replace ZV1_LACRE1  	With _nLacre1     //LACRE FRENTE
Replace ZV1_LACRE2  	With _nLacre2     //LACRE TRAZ
Replace ZV1_DTAREA		with _dDtaBtR     //DATA DE ABATE REALIZADA
Replace ZV1_LOJFOR      with _nLOJFOR    //Joja Produtor
Replace ZV1_NUMNFS      with _nNumNf		//NF
Replace ZV1_SERIE       with _cSerie 		//serie da NF
Replace ZV1_QTDQBR      with _nQbr        //QUEBRA
REPLACE ZV1_RHABAT		WITH _dRhAbt		//HORA DE ABATE
REPLACE ZV1_STATUS 		WITH 'M'		//STATUS
Replace ZV1_PESLIQ		with _nPESLIQ	//PESO LIQUIDO
Replace ZV1_PPESOT		WITH _nPesTP	//PESO TOTAL PROGRAMADO
Replace ZV1_RPESOT		with  _PesOrigem 	//PESO TOTAL REALIZADO
Replace ZV1_RHESPE		WITH STR(_hEsp) //TEMPO DE ESPERA
REPLACE ZV1_OBS			WITH _Obs		//OBS
//REPLACE ZV1_DERMAT		with 0.01		//CAMPO OBRIGATÓRIO
REPLACE ZV1_RCIDAD		WITH _PCIDAD  	//cidade
REPLACE ZV1_TARAPD		WITH TARAPD(_cPlacR)
MsUnlock()

DbCloseArea("ZV1")
Eval(EndDlg)
Return(.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
//³VERIFICA A VALIDACAO DE CAMPO E EXIBE A MSN NA TELA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|

Static Function VClima (_cSts)    //VALIDA CLIMA
If (_cSts="S" .or. _cSts="M")
	_cSts:=.T.
Else
	_cSts:=.F.
EndIf
Return (_cSts)



Static Function VTbalanca (_cSts)                //VALIDA CLIMA NA BALANCA
If (_cTBal="E" .or. _cTBal="M" .or. _cTBal="N")
	_cSts:=.T.
Else
	_cSts:=.F.
EndIf
Return (_cSts)



Static Function VKmSai (_kmSai)                      //VALIDA KM DE SAIDA
//verificando o tipo da variavel e tornando ela numerica
If (_kmSai > 0)
	_cSts:=.T.
Else
	Alert("KM DE SAÍDA DEVE SER MAIOR QUE ZERO")
	_cSts:=.F.
EndIf
Return (_cSts)



Static Function VKmEnt (_nKmEnt)                     //VALIDA KM DE ENTRADA
If (_nKmEnt > _KmSai)
	_cSts:=.T.
Else
	Alert("KM DE ENTRADA DEVE SER MAIOR QUE DE SAÍDA")
	_cSts:=.F.
EndIf
Return (_cSts)



Static Function VPriPeso (_PriPeso)                    //VALIDA PRIMEIRO PESO
//verificando o tipo da variavel e tornando ela numerica

If (_PriPeso>= 60000)  // Limite maximo da balança
	Alert("PESO MÁXIMO ATINGIDO")
	_cSts:=.F.
Else
	_cSts:=.T.
EndIf
Return (_cSts)



Static Function VSegPeso (_SegPeso)                //VALIDA SEGUNDO PESO
//verificando o tipo da variavel e tornando ela numerica
If  (_SegPeso  > _PriPeso)
	Alert("SEGUNDO PESO MAIOR QUE O PRIMEIRO")
	_cSts:=.F.
Else
	_cSts:=.T.
ENDIF
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
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GetLjForn  ³ Autor ³ HCConsys - Celso    ³ Data ³02/04/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que retorna a loja do Fornecedor posicionado        ³±±
±±³          ³ referente chamado 004061                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Adoro                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ parm01 = Codigo do Fornecedor                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GetLjForn( _nCODFOR )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _aArea		:= GetArea()
Local _aAreaSA2	:= SA2->( GetArea() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida Loja do Fornecedor                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "SA2" )
dbSetOrder( 01 )
 
If SA2->A2_COD != _nCODFOR
	SA2->( dbSeek( xFilial( "SA2" ) + _nCODFOR ) )
EndIf

_nLOJFOR := SA2->A2_LOJA

RestArea( _aAreaSA2 )

RestArea( _aArea )

Return ( .T. )
/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 21/03/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
/*/
static function NumNfs(_nNumNF)

	Local _lRet := .T.
	Local _cQuery := ""

	//Ticket TI    - Adriano Savoine - 08/04/2022
	IF SELECT ("VZV1") > 0
		VZV1->(DbCloseArea())
	ENDIF	

	_cQuery := " SELECT ZV1_NUMOC, ZV1_NUMNFS, ZV1_SERIE, ZV1_CODFOR, ZV1_LOJFOR "
	_cQuery += " FROM "+retsqlname("ZV1") +" (NOLOCK)
	_cQuery += " WHERE ZV1_FILIAL='"+FWxFilial("ZV1")+"' AND " // @history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
	_cQuery += " RTRIM(LTRIM(ZV1_NUMNFS)) = '"+ALLTRIM(_nNumNF)+"' and "
	_cQuery += " RTRIM(LTRIM(ZV1_SERIE)) = '"+ALLTRIM(_cSerie)+"' and "
	_cQuery += " ZV1_FORREC = '"+_nCODFNF+"' and ZV1_LOJREC = '"+_nLojNF+"' and "
	_cQuery += " D_E_L_E_T_ <> '*' ORDER BY ZV1_NUMOC"

	TcQuery _cQuery New Alias "VZV1"
	
	DbSelectArea("VZV1")
	VZV1->(dbGoTop())
	While !VZV1->(eof())
	If VZV1->ZV1_NUMOC <> _ORDEM      //&& Verifica se nao esta alterando uma OC.
		MsgInfo("A NF/SERIE "+_nNumNf+" / "+_cSerie+" informada ja foi utilizada na OC: "+VZV1->ZV1_NUMOC+" para o Fornecedor/loja: "+_nCODFNF+" / "+_nLojNF+" .Favor Verificar!!!")
		VZV1->(DbCloseArea())
		Return(.F.)
	endif
	VZV1->(dbSkip())
	EndDo
	VZV1->(DbCloseArea())

return(_lRet)
