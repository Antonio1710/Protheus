#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.CH"
 
static lAuto

/*/{Protheus.doc} User Function nomeFunction
	Relatorio que mostra NF por Recebimento Do Frango Vivo
	@type  Function
	@author Daniel Pitthan Silveira
	@since 09/09/2005
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
	@history Ticket 69574 - Abel Babini       - 25/04/2022 - Projeto FAI
	@history Ticket 74568 - Fernando Macieira - 13/06/2022 - Pedido de Complemento - Filial 0A
	@history Ticket 76197 - ADRIANO SAVOINE   - 11/07/2022 - Corrigido para não gerar pedido sem fechar a Pesagem.
	@hisotry Ticket 76414 - Everson           - 13/07/2022 - Adiciona opção para o usuário selecionar a filial de origem.
/*/ 
User Function AD0143(cNFNot, nTtPLO, cSql, nTtPLP, lAuto)

	// FWNM - 16/04/2018 - CHAMADO 037729
	Default cNFNot  := ""
	Default nTtPLO  := 0
	Default cSql    := ""
	Default nTtPLP  := 0
	Default lAuto   := .F.
	//

	// Define lAuto
	/*
	nArea := Select()
	If nArea > 0
		lAuto := .f.
	EndIf
	*/

	Private cDesc1       	:= "Este programa tem como objetivo imprimir relatorio "
	Private cDesc2       	:= "de acordo com os parametros informados pelo usuario."
	Private cDesc3       	:= "RELAÇÃO DIARIA ORDEM CARREGAMENTO FRANGO VIVO"
	Private cPict      		:= ""
	Private titulo    		:= "RELAÇÃO DIARIA ORDEM CARREGAMENTO FRANGO VIVO"
	Private nLin       		:= 80

	Private Cabec1    		:= ""
	Private Cabec2      	:= ""
	Private imprime     	:= .T.
	Private  aOrd := {}
	Private lEnd             := .F.
	Private lAbortPrint      := .F.
	Private CbTxt            := ""
	Private limite           := 220
	Private tamanho          := "G"
	Private nomeprog         := "AD0143" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 15
	Private aReturn          := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey       	 := 0
	Private cbtxt     		 := Space(10)
	Private cbcont    		 := 00
	Private CONTFL    		 := 01
	Private m_pag     		 := 01
	Private wnrel     		 := "AD0143" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString          := ""
	Public dLin	//transporte de linha

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÔ
	//³VARIAVEIS CRIADAS PELO DANIEL³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÔ

	Private _nDifRPaves         //DIFERENCA DE AVES DA ORIGEM PELA RECEBIDA
	Private _nMulPemRav	        //PESO LIQUIDO DA ORIGEM
	Private _nDif1Pe2Pe		    //DIFERENCA DO PESO 1 PELO PESO 2
	Private _nQuebra  		    //PESO LIQUIDO DA QUEBRA
	Private _nMulMrtPe		    //PESO DA MORTALIDADE
	Private _nSMPesPorc		    //SOMATORIA DAS PORCENTAGEM DE QUEBRA
	Private _nTotFgvOri		    //TOTAL AVES ORIGEM
	Private _nTotFgvRec		    //TOTAL AVES RECEBIMENTO
	Private _nTotFgvDif		    //TOTAL DIFERENCA AVES ORIGEM x RECEBIMENTO
	Private _nTotPesOri		    //TOTAL PESO ORIGEM
	Private _nTotPesRec		    //TOTAL PESO RECEBIMENTO
	Private _nTotPesQbr		    //TOTAL PESO QUEBRA
	Private _nTotPesPrc		    //TOTAL PESO PORCENTAGEM
	Private _nTotMrtQtd		    //TOTAL MORTALIDADE
	Private _nTotMrtPes		    //TOTAL PESO MORTALIDADE
	Private _nTotPesNf		    //TOTAL PESO NF
	Private _nTotValtNf		    //TOTAL VALOR TOTAL NF
	Private _nTotValuNf		    //TOTAL VALOR UNITARIO NF
	Private _nTotDifPeNF        //TOTAL DIFERENCA PESO NF PELO PESO REAL
	Private _nTotDifVNF         //TOTAL COMPLEMENTO
	Private _nNFCompl			//complemento da NF
	Private	_nNfVunit 			//Valor unitario da NF
	Private _nNfTotal 			//Valor Total da NF
	Private _cPGRANJ 			//Integrado
	Private _lReduz:=0          //reduz relatorio
	Private _nVrealNF           //Valor da nf RECEBIDO REAL
	Private _cPar1  := Space(3) //Paramettro da porcentagem de quebra dos integrados da Adoro
	Private _cPar2  := Space(3) //Parametro do codigo de integrado da Adoro
	Private _cNumoc 			//Ordem de Carregamento
	Private _cRGRANJ 			//Integrado programado
	Private _cPplaca 			//placa do veiculo
	Private _nPaves 			//Qtd aves recebidas, programado
	Private _nRaves 			//qtd de aves do contador, realizado
	Private _nPesome 			//peso medio
	Private _n1Peso  			//primeiro peso
	Private _n2peso  			//segundo peso
	Private _nMortal 			//Qtd de mortos
	Private _nPesoNF 			//Peso da NF
	Private _NUMNFS 			//numero da nf
	Private _nlojfor  			//loja
	Private _ncodfor    		//fonecedor
	Private _nNfVunit  			//unitario da Nf
	Private _nNfTotal 			//total da Nf
	Private _cPgranj 			//integrado
	Private _lCalqbr 			//Identifica qual tipo de porcentagem de quebra devo utilisar
	Private _nDifPerPeNf  		//Diferenca de peso da NF pelo peso Real
	Private _nVrealNF 			//Valor real da NF Recebida
	Private _nVDNFREC 			//complemento da NF
	Private _nTotVRec 		:=0 //Valor total Recebido
	Private _nTotVNfRec   		//complemento do valor rec
	Private _nTotVUNFM 			//Unitario atual
	Private _nTotPeCpm          //total peso complemento
	Private _nContFor		    //Parametro do codigo de fornecedor da adoro integrados
	Private _cForRec			//Fornecedor Recebido
	Private _hEntPort			//hora de chegada em vp
	Private _hAbtPla			//hoara de início de abate
	Private _dHresp				//tempo de espera
	Private _dAbtPla  			//DATA DE ABATE EFETIVAMENTE REALIZADA
	Private _dEntPort  			//DATA DE ABATE DA PORTARIA
	Private _dDtaBat  			//DATA DE ABATE
	Private _nPDifNFRec			//complemento da NF
	Private PerMort:=0			//Percentual de Perda
	Private _nTotPmo:=0			//total de Perda
	Private TGPMOT  :=0			//total geral de percentual
	Private _nSomaPeso := 0
	Private _nSomaQtd := 0

	/*CALCULO DE HORAS*/
	Private _cHr1	            //fracao hora 1 ABATE
	Private _cMin1              //fracao minuto	1   ABATE
	Private _nHr1				//Fracao hora numerico 1 ABATE
	Private _nMin1			    //Fracao minuto numerico 1ABATE
	Private _nTotT1				//total do tempo em minuto 1ABATE
	Private _cHr2	            //fracao hora 2 ABATE EFETIVAMENTE REALIZXADO
	Private _cMin2              //fracao minuto	2 ABATE EFETIVAMENTE REALIZXADO
	Private _nHr2				//Fracao hora numerico 2 ABATE EFETIVAMENTE REALIZXADO
	Private _nMin2			    //Fracao minuto numerico 2 ABATE EFETIVAMENTE REALIZXADO
	Private _nTotT2				//total do tempo em minuto 2  ABATE EFETIVAMENTE REALIZXADO
	private _dView 				//hora a visualizar
	Private _nTotDTHR			//valor em minutos dos dias parados
	Private	_nDifDat			//difereca entre as data de abate e abate realizado
	Private	_dHresp 			//calculo do tempo de espera
	Private	_dHMTM				//calculo do minuto de espera
	Private _dRhVp              //Hora de chegada em VP
	Private _dRHAbt             //hora de abate
	Private _dDtaRea            //Data Real de abate
	Private _cSerie:=''         //sERIE DA NF
	Private _cCliVol:=''        //cLIMA NA VOLTA
	Private _nCliqbr        	//QUEBRA DE CLIMA
	Private _TgH:=0             //total de horas
	Private _TgM:=0             //total de Minutos
	Private _RecP:=0            //total de registrios
	private _dhr:=0
	private _dm3:=0
	Private _nMedi_Hr  :=  0
	Private _nCount_Hr := 0
	Private _cMarkS_M  := SPACE(1)
	/*FIM*/

	Private Xlin                //Número de linha
	Private _n2PesoOC           //Segundo Peso, utilizado para vericicar a existencia de segunda pesagem
	Private _cMarkX             //Marca das oc sem segunda pesagem
	Private _nQtdRec			//Quantidade de Registros
	Private _nAjusPS            //Peso ajustado
	Private _nTotMePon          //Total da Media ponderada
	Private _nMepon             //Media Ponderada
	Private _lPriVez			//Verifica se é a primeira vez, utilizado no calculo da media de peso medio
	Private _dEntPort			//Proximo registro data de abate
	Private _dDatEntr 			//Data convertida
	Private _cTexto 			//Texto da data, para quebra de data
	Private _lPriVezD	  		//primeira vez  data
	pRIVATE _nTotPespcT         //MEDIA ARITIMETICA DA PORCENTAGEM
	Public  _nD:=0              //contador de dias
	Private _nNUMNFS:=0         //Numero da Nf
	PRivate _nTURMA := space(02)//Turma
	pRIVATE _cPEDXML:= space(06)//Pedido XML
	Private _lQbrP:=0           //Verifica se houve quebra de pagina
	Private _nCoutD:=1          //conta dias
	Private _nC                 //Posicao da marca em caso de nao existir segunda pesagem
	Private _dRhVp              //Hora de chegada em VP
	Private _nPesNF :=0

	Private cNroFiscal    :=  ""        //numero Nota Fiscal de Apanha  Chamado: 040118 //Fernando Sigoli 05/03/2018
	Private cSerFiscal    :=  ""        //Serie Nota Fiscal de Apanha Chamado: 040118 //Fernando Sigoli 05/03/2018

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRAVANDO TOTAIS PARA O TOTAL GERAL                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private TGAC         //Aves Carregadas
	Private TGAR         //Aves Recebidas
	Private TGDACAR      //Diferenca de aves Carregad e Recebidas
	Private TGPO         //Peso Origem
	Private TGPR         //Peso Recebido
	Private TGPNF        //Peso Nota Fiscal
	Private TGPQ         //quebra de peso
	Private TGPQNF       //quebra NF
	Private TGPP         //Porcentagem de quebra
	Private TGPM         //Peso medio
	Private TGMQ         //Mortalidade
	Private TGMP         //Peso da Mortalidade
	Private TGNFU        //Unitario NF
	Private TGNFV:=0     //Valor da NOTA
	Private TGNFC        //complemento da NF
	Private TGNFA        //Unitario atual
	Private TGNVT		 //TOTAL DO VALOR RECEBIDO
	Private TGCP		 //total do complemento do peso
	Private TGCV		 //total do complemento do valor
	Private nQtdApanha

	Private _nAvesGa     //Aves por gaiola // Chamado:049564 - Fernando Sigoli 09/07/2019  
	Private _cTurAbt     //Turno de abate  // Chamado:049564 - Fernando Sigoli 09/07/2019  

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio que mostra NF por Recebimento Do Frango Vivo')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
	//³PROCURANDO A S PERGUNTAS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|

	cPerg:="AD0143"      

	If lAuto
		nDiasAnt   := GetMV("MV_#LFVDI2",,0)
		
		_dDataini	:=msdate()-nDiasAnt    //GRAVA DATA INICIAL DE ABATE
		_dDataFim	:=msDate()-nDiasAnt  //GRAVA DATA FINAL DE ABATE

		//debug
		//_dDataini	:= CtoD("25/05/18")
		//_dDataFim	:= CtoD("25/05/18")
		//debug

		_lReduz		:=3	  //GRAVA O TIPO DE REALTORIO
		_nUnitAt    :=0    //VALOR UNITARIO AGORA DA NF
		_LTarPadr   :=1    //Usa tara padrao? Sim ou Nao
		_LAjusPe    :=1    //Pergunta se usa ou nao o ajuste do peso
		_lQAvCar    :=1    //Pergunta se usa no calculo do peso medio Qtd aves carregadas ou Recebidas(Contador)
		_nTurno     :=0    //Turno
		_nOrdem     :=2    //Ordem
		_lSint		:=2    //Relatorio/Sintetico-Analítico
		_cGranjF	:=""	  //Filtra granja
		_cPlacF		:=""	  //Filtra Placa
		_cForc		:=""	  //Filtra por fonecedor

	Else
		IF 	pergunte(cPerg,.T.)=.F.
			RETURN
		ENDIF

		//Ticket 76414 - Everson           - 13/07/2022 - Adiciona opção para o usuário selecionar a filial de origem.
			If MV_PAR14 == 1
				cFilPV := "03"

			ElseIf MV_PAR14 == 2
				cFilPV := "0A"

			Else
				Aviso(	"AD0143-01",;
				"Necessário selecionar a filial de origem." ,;
				{ "&OK" },,;
				"PV - Complemento Frango Vivo" )
				Return Nil

			EndIf
		//

		_dDataini	:=mv_par01    //GRAVA DATA INICIAL DE ABATE
		_dDataFim	:=mv_par02    //GRAVA DATA FINAL DE ABATE
		_lReduz		:=mv_par03	  //GRAVA O TIPO DE REALTORIO
		_nUnitAt    :=mv_par04    //VALOR UNITARIO AGORA DA NF
		_LTarPadr   :=mv_par05    //Usa tara padrao? Sim ou Nao
		_LAjusPe    :=mv_par06    //Pergunta se usa ou nao o ajuste do peso
		_lQAvCar    :=mv_par07    //Pergunta se usa no calculo do peso medio Qtd aves carregadas ou Recebidas(Contador)
		_nTurno     :=mv_par08    //Turno
		_nOrdem     :=mv_par09    //Ordem
		_lSint		:=mv_par10    //Relatorio/Sintetico-Analítico
		_cGranjF	:=mv_par11	  //Filtra granja
		_cPlacF		:=mv_par12	  //Filtra Placa
		_cForc		:=mv_par13	  //Filtra por fonecedor

	EndIf
		

	//--------------------------------------------
	//-   _lReduz==1 ; MODELO FISCAL PCP  - MODELO 01
	//-   _lReduz==2 ; MODELO GERAL, TOTAL -MODELO 02
	//-   _lReduz==3 ; MODELO FGV          -MODELO 03
	//-	  _lReduz==3 ; MODELO 04 relatorio de apanha
	//--------------------------------------------
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
	//³Mudando o formato do relatorio.                            ³
	//³                                                           ³
	//³Altero o formato para retrato, onde somente as informacoes ³
	//³fiscais sao impressas.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|

	NOMEEMP:=''
	DBSELECTAREA("SM0")
	NOMEEMP:=M0_NOMECOM

	DO CASE
		CASE _lReduz==1
			limite           := 80
			tamanho          := "M"
			Cabec1			 := NOMEEMP+" -MODELO 01"
			Cabec2 			 := "RELACAO DIARIA DO CARREGAMENTO"
		CASE _lReduz==2
			limite 			 :=220
			tamanho			 :="G"
			Cabec1			 := NOMEEMP+" -MODELO 02"
		CASE _lReduz==3
			limite			 :=220
			tamanho			 :="G"
			Cabec1			 := NOMEEMP+" -MODELO 03"
		CASE _lReduz==4
			limite			 :=80
			tamanho			 :="P"
			Cabec1			 := NOMEEMP+" -MODELO 04"
		OTHERWISE
	ENDCASE

	Private cString := "ZV1"

	dbSelectArea("ZV1")
	dbSetOrder(1)

	If !lAuto
		If AllTrim(FunName()) <> "AD0130" .and. AllTrim(FunName()) <> "ADLFV010P"// FWNM - 16/04/2018 - CHAMADO 037729
			
			wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)
			
			If nLastKey == 27
				Return
			Endif
			
			SetDefault(aReturn,cString)
			
			If nLastKey == 27
				Return
			Endif
			
		EndIf
	EndIf	

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lAuto
		RunReport(Cabec1,Cabec2,Titulo,nLin,lAuto)
	Else
		RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin,lAuto) },Titulo)
	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  09/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin,lAuto)

Local nOrdem

/*PROCURANDO PORCENTAGEM DE QUEBRA*/
_nContudPr := ''
_cPar1   := 'MV_PORCENT'
_nContFor := ''
_cPa2     := 'MV_FORITAD'

DBSELECTAREA("SX6")
DBSETORDER(1)
IF DBSEEK ("  "+_cPar1,.T.)
	_nContudPr :=X6_CONTEUD
ELSE
	_nContudPr:=""
ENDIF
_nContud:=val(_nContudPr)

//Procuro pelo codigo do fornecedor padrao dos integrados
//da adoro nos paramentros e comparo com o codigo atual
//se for igual uso a porcentagem de quebra para integrados
//da adoro, caso nao calculo a porcentagem de quebra

_nContFor:= Getmv("MV_FORITAD")
_nContFor:=alltrim(_nContFor)

//Procuro o parametro de para desconto do peso liquido
//quanto tiver peso da balanca com opcao "M" molhado

_nParQueb:= Getmv("MV_PORQUEB")
_nPrcQueb:= VAL(_nParQueb)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ZERANDO VARIAVEIS UZADAS NOS CALCULOS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_nDifRPaves :=0      	//DIFERENCA DE AVES DA ORIGEM PELA RECEBIDA
_nMulPemRav :=0       	//PESO LIQUIDO DA ORIGEM
_nDif1Pe2Pe :=0	    	//DIFERENCA DO PESO 1 PELO PESO 2
_nQuebra    :=0	     	//PESO LIQUIDO DA QUEBRA
_nMulMrtPe  :=0     	//PESO DA MORTALIDADE
_nSMPesPorc :=0    		//SOMATORIA DAS PORCENTAGEM DE QUEBRA
_nTotFgvOri :=0   		//TOTAL AVES ORIGEM
_nTotFgvRec :=0  		//TOTAL AVES RECEBIMENTO
_nTotFgvDif :=0 	    //TOTAL DIFERENCA AVES ORIGEM x RECEBIMENTO
_nTotPesOri :=0         //TOTAL PESO ORIGEM
_nTotPesRec :=0	     	//TOTAL PESO RECEBIMENTO
_nTotPesQbr :=0	     	//TOTAL PESO QUEBRA
_nTotPesPrc :=0	     	//TOTAL PESO PORCENTAGEM
_nTotMrtQtd :=0     	//TOTAL MORTALIDADE
_nTotMrtPes :=0    		//TOTAL PESO MORTALIDADE
_nTotPesNf  :=0	     	//TOTAL PESO NF
_nTotValtNf :=0	     	//TOTAL VALOR TOTAL NF
_nTotValuNf :=0	     	//TOTAL VALOR UNITARIO NF
_nTotDifPeNF  :=0    	//TOTAL DIFERENCA PESO NF PELO PESO REAL
_nTotDifVNF   :=0   	//TOTAL COMPLEMENTO
_nNFCompl     :=0		//complemento da NF
_nNfVunit     :=0		//Valor unitario da NF
_nNfTotal     :=0		//Valor Total da NF
_nVrealNF     :=0       //Valor da nf RECEBIDO REAL
_nPaves       :=0		//Qtd aves recebidas, programado
_nRaves       :=0		//qtd de aves do contador, realizado
_nPesome      :=0 		//peso medio
_n1Peso       :=0 		//primeiro peso
_n2peso 	  :=0       //segundo peso
_nMortal      :=0		//Qtd de mortos
_nPesoNF	  :=0		//Peso da NF
_nNfVunit	  :=0 		//unitario da Nf
_nNfTotal     :=0		//total da Nf
_nDifPerPeNf  :=0  		//Diferenca de peso da NF pelo peso Real
_nVrealNF     :=0		//Valor real da NF Recebida
_nVDNFREC     :=0		//complemento da NF
_nTotVRec     :=0 		//valor total recebido
_nTotVNfRec   :=0 		//complemento do valor rec
_nTotVUNFM	  :=0 		//Unitariao atual da Nf
_nTotPeCpm    :=0       //Total Peso complemento
_nQtdRec	  :=0		//Quantidade de Registros
_nAjusPS      :=0		//Peso ajustado
_nTotMePon	  :=0       //Total da Media ponderada
_nMepon1	  :=0       //Media Ponderada 1 - primeira vez
_nMepon2	  :=0       //Media Ponderada 2
_nPesAnt      :=0       //Peso anterior
_lPriVez	  :=1		//primeira vez
_lPriVezD	  :=1		//primeira vez
_nTotPespcT   :=0    	//MEDIA AITIMETICA DA PORCENTAGEM
_nPDifNFRec   :=0       //complemento da NF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ZERANDO TOTALIZADORES GERAIS                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

TGAC	:=0
TGAR	:=0
TGDACAR	:=0
TGPO	:=0
TGPR	:=0
TGPQ	:=0
TGPP	:=0
TGMQ	:=0
TGMP	:=0
TGPNF	:=0
TGPQNF	:=0
TGNFU	:=0
TGNFC	:=0
TGNFC	:=0
TGNFA	:=0
TGNVT	:=0
TGCP	:=0
TGCV	:=0
TGPM	:=0

_nAvesGa := ""   //Chamado:049564 - Fernando Sigoli 09/07/2019          
_cTurAbt := ""   //Chamado:049564 - Fernando Sigoli 09/07/2019          


if 	_lReduz==4
	ApnFV5 ()
else
	//MONTA MINHAS MENSAGENS NA TELA COM A REGUA
	If lAuto
		Procrx(lAuto)
	Else
		bBloco := {|lEnd| Procrx(lAuto)}
		//	Processa(bBloco,"Aguarde","Gerando Relatorio",.T.)
		If AllTrim(FunName()) <> "AD0130" .and. AllTrim(FunName()) <> "ADLFV010P" // FWNM - 16/04/2018 - CHAMADO 037729
			MsAguarde(bBloco,"Aguarde, Gerando Relatorio","Processando...",.T.)
		Else
			MsAguarde(bBloco,"Aguarde, Gerando PV","Processando...",.T.)
		EndIf
	EndIf
endif



If !lAuto
	If AllTrim(FunName()) <> "AD0130" .and. AllTrim(FunName()) <> "ADLFV010P"  // FWNM - 16/04/2018 - CHAMADO 037729
		
		SET DEVICE TO SCREEN
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se impressao em disco, chama o gerenciador de impressao...          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If aReturn[5]==1
			dbCommitAll()
			SET PRINTER TO
			OurSpool(wnrel)
		Endif
		MS_FLUSH()
		dbCloseArea("ROC")
		
	EndIf
EndIf
	
Return






Static function Procrx(lAuto)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³NA LINHA DA STRING O SE COMEÇA COM O COMANDO  'WHERE' ³
//³FOI ACRESCENTADO O PARAMETRO DE DATA INICIAL DE ABATE ³
//³E DATA FINAL DE ABATE.                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ALTERADO QUERY PARA ADQUIRIR TARA PADRAO DO ZV1010;  ZV1_TARAPD³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Select("ROC") > 0
	DbSelectArea("ROC")
	ROC->(DbCloseArea())
Endif

cQuery:=" SELECT "
cQuery+=" ZV1_NUMOC, ZV1_RGRANJ, ZV1_CAVES , ZV1_RAVES,ZV1_QTDQBR, ZV1_AVESGA, "
cQuery+=" ZV1_PAVES, ZV1_PESOME, ZV1_MORTAL, ZV1_NUMNFS, ZV1_TURMA, "
cQuery+=" ZV2_1PESO, ZV2_2PESO, ZV1_RPLACA , ZV1_PESONF,  "
cQuery+=" ZV1_VALTNF,ZV1_VALUNF,ZV1_DTABAT , ZV1_DTAREA,  "
cQuery+=" ZV1_LOJFOR, ZV1_CODFOR,ZV1_TARAPD,ZV1_AJUSPS, ZV1_SERIE , "
cQuery+=" ZV1_PGRANJ, ZV1_FORREC,ZV1_LOJREC,ZV1_RHVP,ZV1_RHABAT , ZV2_DATA1 , ZV1_CLIVOL,ZV1_RHESPE,ZV1_CLIBAL "
cQuery+=" FROM " + retsqlname("ZV1")+ " (NOLOCK), " + retsqlname("ZV2")+" (NOLOCK) "
cQuery+=" WHERE ZV1_FILIAL='"+FWxFilial("ZV1")+"' AND ZV1_FILIAL=ZV2_FILIAL " // @history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
cQuery+=" AND (ZV2_GUIA = ZV1_GUIAPE) AND (ZV1_DTABAT >= '"+ DTOS(_dDataIni) +"' AND ZV1_DTABAT <= '"+ DTOS(_dDataFim) +"') "
cQuery+=" AND ZV1_NUMNFS<>'      ' "
cQuery+=" AND ZV2_TIPOPE='F'"
//Filtro por Granja
If !empty(_cGranjF)
	cQuery+=" AND ZV1_RGRANJ='"+_cGranjF+"' "
EndIf
//Filtro por Placa
If !empty(_cPlacF)
	cQuery+=" AND ZV1_RPLACA= '"+_cPlacF+"' "
EndIf
//Filtro por Fonecedor
If !empty(_cForc)
	cQuery+=" AND ZV1_FORREC='"+_cForc+"' "
EndIf
//Turno
If _nTurno<>0
	cQuery+=" AND ZV1_TURNO="+str(_nTurno)+" "
EndIf
cQuery+=" AND "+retsqlname("ZV2")+".D_E_L_E_T_ ='' "
cQuery+=" AND "+retsqlname("ZV1")+".D_E_L_E_T_ ='' "


// FWNM - 17/04/2018 - CHAMADO 037729
If AllTrim(FunName()) == "AD0130" .or. AllTrim(FunName()) == "ADLFV010P"  .or. lAuto // FWNM - 18/04/2018 - CHAMADO 037729
	cQuery += " AND ZV1_FLAGPV='' "
	cQuery += " AND ZV1_FECHA <>'' " // Ticket 76197 - 11/07/2022 - ADRIANO SAVOINE
	cQuery += " AND ZV1_INTEGR = 'I' " // Ticket 76430 - 14/07/2022 - ADRIANO SAVOINE
EndIf

// Variavel que será utilizada na rotina ADLFV010P para fazer o UPDATE no campo ZV1_FLAGPV
cSql := cQuery
//

DO CASE
	CASE _nOrdem=1	//Ordena por Ordem de Carregamento
		cQuery+=" ORDER BY  ZV1_NUMOC"
	CASE _nOrdem=2	//Data Base
		cQuery+=" ORDER BY  ZV1_DTABAT"
	CASE _nOrdem=3  //Placa
		cQuery+=" ORDER BY  ZV1_RPLACA"
	CASE _nOrdem=4	//Granja
		cQuery+=" ORDER BY  ZV1_RGRANJ"
	OTHERWISE
		cQuery+=" ORDER BY  ZV1_DTABAT,  ZV1_NUMOC , ZV1_RGRANJ"
ENDCASE

TCQUERY cQuery new alias "ROC"


DbSelectArea("ROC")
Dbgotop()

//PRIMEIRA VEZ, DATA DE ABATE PROXIMO REGISTRO
//USO PARA FAZER QUEBRA DO RELATORIO POR DATA
_dDTBatF:=ROC->ZV1_DTABAT

While !EOF() .and. !EMPTY(_dDTBatF)       //&& Chamado 004885 - Efetuada correcao para data em branco no final do arquivo
	//&& Qdo parametrizado por ordem = DATA DE ABATE e SINTETICO.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o cancelamento pelo usuario...                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//Incrementadno Regua
	// ProcRegua(RecCount())
	
	nLin:=GETVARS(nLin)				//Obtem campos da query
	
	If !lAuto
		msproctxt ("INT.: "+_cRGRANJ+" OC.: "+_cNUMOC)
	EndIf
	
	//Atualizando regua
	//	IncProc()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho do relatorio. . .                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//covertendo data para formato tradicional
	_dDatEntr:=  SUBSTR (_dDTBatF,7,2)+ "/" + SUBSTR (_dDTBatF,5,2) +"/"+ SUBSTR (_dDTBatF,1,4)
	
	If !lAuto
		If AllTrim(FunName()) <> "AD0130" .and. AllTrim(FunName()) <> "ADLFV010P"  // FWNM - 16/04/2018 - CHAMADO 037729
			
			If (nLin >55 )   //Salto de Página. Neste caso o formulario tem 55 linhas...   &&66
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 8
				nLin := Cabec5 (nLin)  //CABECALHO DO PERIODO DE ABATE  E LEGENDA
				nLin:=nLin+2
				DO CASE  //CABECALHOS
					CASE _lReduz==1
						nLin := Cabec4 (nLin)
						nLin := nLin + 1
					CASE _lReduz==2
						nLin := Cabec3 (nLin)
						nLin := nLin + 1
					CASE _lReduz==3
						nLin := Cabec6 (nLin)
						nLin := nLin + 1
					OTHERWISE
				ENDCASE
				IF	(_lPriVezD==1)  //Verifico se foi alterado a data e faco a quebra
					if _lSint<>1 //Se for Analitico
						nLin:=DtaCorr(nLin)
					EndIf
					_lPriVezD:=0
				ELSE
					nLin:=DtaCorr(nLin)
				EndIF
			Endif
			
		Endif
	Endif
	
	nLin:=PROCFUNCTIONS(nLin)	//Processando calculos
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico se houve quebra de pagina                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	if _lSint<>1 //Se for Analitico imprime detalhes
		nLin:=PRINTREPORT(nLin,lAuto)     //Imprime relatorio
	Else
		ApanhaSint()  &&Chamado 0005271 - Mauricio HC Consys.
	endIf
	
	
	DbSelectArea("ROC")
	
	_lQbrP:=ChkDate(nLin)       	//Verifica se houve quebra de data e imprime totais
	
	if _lQbrP=1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratando o total geral para a ultima pagina³
		//³                                           ³
		//³eof()=.t.                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if !eof()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Trantando o tipo de relatorio ³
			//³Sintetico ou Analitico        ³
			//³Sintetico - Nao quebrar pagina³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If _lSint<>1
				nLin:=99
			else
				nLin:=dLin                   	//retorno da linha
			EndIf
		End
	else
		nLin:=dLin                   	//retorno da linha
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³LIMPANDO VARIAVES de controle                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	_nDif1Pe2Pe	:=0
	_nSMPesPorc	:=0
	_nMulPemRav	:=0
	_nQuebra	:=0
	
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³IMPRIMINDO TOTAIS GERAIS                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_nTotPesOri:=TGPO //RETIRANDO A CASA DECIMAL
_nTotPesRec:=TGPR //RETIRANDO A CASA DECIMAL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³IMPRIMINDO TOTAIS                                          ³
//³
//³SE NAO HAVER AVES NO TOTAL ELE NAO IMPRIME RELATORIO       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//calculo da hora total

hh:=_Tgh+INT(_Tgm/60)					//TOTAL DE HORAS
mm:=INT(((_Tgm/60)-INT(_Tgm/60))*60) 	//TOTAL DE MINUTOS

fhh:=(hh/_RecP)-int(hh/_RecP)	    	//parte fracionada  hora
fhh:=int(fhh*60)                        //minutos da hora

hh:=int(hh/_RecP)				        //parte inteira da hora

mm:=((int((mm)/_RecP))+fhh)			//media dos minutos

if mm>=60
	hh:=hh+int(mm/60)
	mm:=int(((mm/60)-int(mm/60))*60)
endif

TGPP	:=TGPP		/_nCoutD        //Media aritimetica da por centagem de quebra por dias

nlin:=nLin+2

//  LINHA DO TOTAL GERAL DA ULTIMA FOLHA

If !lAuto
	If AllTrim(FunName()) <> "AD0130" .and. AllTrim(FunName()) <> "ADLFV010P"  // FWNM - 16/04/2018 - CHAMADO 037729
		
		IF (TGAR>0)
			DO CASE
				CASE _lReduz==1
					@ nLin,000 PSAY REPLICATE ("=",132)
					nLin++
					@ nLin,000 PSAY "<<TOTAL GERAL>>"
					@ nLin,018 PSAY TGAR  picture "99999999"    //TOTAL AVES ORIGEM
					@ nLin,029 PSAY TGPO  PICTURE "99999999.99"    //TOTAL PESO ORIGEM
					@ nLin,042 PSAY TGNVT PICTURE "9999999999" 	//Total Recebido Valor
					@ nLin,058 PSAY TGCP  PICTURE "99999999"	//Total complemento Peso
					@ nLin,069 Psay TGNFC PICTURE "9999999,99"	//Total complemento Valor
					@ nLin,086 PSAY TGNFU PICTURE "9999.9999"   //TOTAL VALOR UNITARIO NF
					@ nLin,099 Psay TGNFA PICTURE "9999.9999"	//Total unitario Nf agora
					nLin++
					@ nLin,000 PSAY "OCs.: "+alltrim(str(_nQtdRec) )
					nLin++
					@ nLin,000 PSAY REPLICATE ("=",132)
					
				CASE _lReduz==2
					@ nLin,000 PSAY REPLICATE ("=",220)
					nLin++
					@ nLin,000 PSAY "<<TOTAL GERAL>>"
					@ nLin,030 PSAY TGAC	  //TOTAL AVES ORIGEM
					@ nLin,038 PSAY TGAR	  //TOTAL AVES RECEBIDA [INFORMAÇÃO DO CONTADOR]
					@ nLin,049 PSAY TGDACAR   //TOTAL DIFERENCA
					@ nLin,060 PSAY TGPO picture 	'9999999.99'   //TOTAL PESO ORIGEM
					@ nLin,074 PSAY TGPR picture 	'9999999'  //TOTAL PESO RECEBIDO
					@ nLin,088 PSAY TGPNF picture 	'9999999'  //TOTAL NF PESO RECEBIDO
					@ nLin,100 PSAY TGPQ picture 	'9999999'  //TOTAL QUEBRA
					@ nLin,114 PSAY TGPQNF picture 	'9999999'  //TOTAL QUEBRA NF
					//@ nLin,123 PSAY TGPP  picture 	'999.99' //TOTAL PORCENTAGEM
					@ nLin,134 PSAY TGPR/TGAC  picture 	'9999.999' //TOTAL PESO MED
					@ nLin,148 PSAY TGMQ   picture 	'99999' //TOTAL QTD MOTAL
					@ nLin,156 PSAY TGMP   picture 	'@E 99999'//TOTAL PESO MORTAL
					@ nLin,179 PSAY TGNFU PICTURE 	"@E 9999.999"  //TOTAL VALOR UNITARIO NF
					@ nLin,190 PSAY TGNFV PICTURE 	"@E 999999999.99"  //TOTAL VALOR TOTAL NF
					@ nLin,205 PSAY TGNFC PICTURE 	"@E 999999999.99"  //TOTAL COMPLEME. NF
					nLin++
					@ nLin,000 PSAY "OCs.: "+alltrim(str(_nQtdRec) )
					nLin++
					@ nLin,000 PSAY REPLICATE ("=",220)
					
				CASE _lReduz==3
					@ nLin,000 PSAY REPLICATE ("=",220)
					nLin++
					@ nLin,000 PSAY "<<TOTAL GERAL>>"
					@ nLin,026 PSAY TGAC  //TOTAL AVES ORIGEM
					@ nLin,036 PSAY TGAC  //TOTAL AVES RECEBIDA [INFORMAÇÃO DO CONTADOR]
					@ nLin,048 PSAY 0  //TOTAL DIFERENCA
					//			@ nLin,056 PSAY TGPO picture 	'99999999.99'  //TOTAL PESO ORIGEM
					//				@ nLin,056 PSAY TGPO picture 	'99999999'  //TOTAL PESO ORIGEM
					@ nLin,056 PSAY TRANSFORM(TGPO, "@E 999,999,999.99")//TGPO picture 	'99999999.99'  //TOTAL PESO ORIGEM  - FWNM - 25/04/2018 - CHAMADO 041287
					@ nLin,070 PSAY TGPR picture 	'99999999'  //TOTAL PESO RECEBIDO
					@ nLin,087 PSAY TGPQ  picture 	'9999999' //TOTAL QUEBRA
					//@ nLin,100 PSAY TGPP  picture 	'999.99' //TOTAL PORCENTAGEM
					@ nLin,107 PSAY TGPR/TGAC  picture 	'9999.999' //TOTAL PESO MED  //TGPM
					@ nLin,125 PSAY TGMQ  picture 	'99999' //TOTAL QTD MOTAL
					@ nLin,134 PSAY TGMP   picture 	'@E 99999'//TOTAL PESO MORTAL
					@ nlin,168 PSAY alltrim(STR(hh))+":"+alltrim(STR(mm))+"  h"
					nLin++
					@ nLin,000 PSAY "OCs.: "+alltrim(str(_nQtdRec) )
					nLin++
					@ NLin,000 PSAY REPLICATE ("=",220)
				OTHERWISE
			ENDCASE
		ENDIF
		
	EndIf
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// FWNM - 16/04/2018 - CHAMADO
//nQtdRec := _nQtdRec
//nTtPLO  := TGPO
//

return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CABECALHOS                                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
/*Cabecalho modelo 02*/
Static Function Cabec3 (Xlin)
@ Xlin,000 PSAY "_____________________________________________________________________________________________________________________________________________________________________________________________________________________________"
Xlin:=Xlin+1
@ Xlin,000 PSAY "|          |      |         |   QUANTIDADE DE AVES       |                         P E S O   L I Q U I D O                          |            |     MORTALIDADE     |                      N. F.                          |"
Xlin:=Xlin+1
@ Xlin,000 PSAY "| N. DA OC | GRNJ | VEICULO | CARRG.  RECEBIDA  DIFERENÇA| ORIGEM        RECEBIDO      NOTA FISCAL  QUEBRA       QUEBRA NF    PORC. | PESO MEDIO | QUANT.  PESO        | NUMERO TURMA VALOR UNIT VALOR TOTAL  COMPLEMENTOTO  |"
Xlin:=Xlin+1
@ Xlin,000 PSAY "+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
Return (Xlin)


/*Cabecalho modelo 01*/
Static Function Cabec4 (Xlin)
@ Xlin,000 PSAY "________________________________________________________________________________________________________________"
Xlin:=Xlin+1
@ Xlin,000 PSAY "|     |     |    |             ORIGEM                |    COMPLEMENTO APURADO     |                             |"
Xlin:=Xlin+1
@ Xlin,000 PSAY "| GRNJ| NF  |TURM| QTD. AVES  PESO          VALOR    |   PESO        VALOR        |   UNITARIO NF  UNITARIO MES |"
Xlin:=Xlin+1
@ Xlin,000 PSAY "+--------------------------------------------------------------------------------------------------------------+"
Return (Xlin)  //0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//0         1         2         3         4         5         6         7         8         9        10         11        12

/*Cabecalho modelo 03*/
static function cabec6(Xlin)
@ Xlin,000 PSAY "____________________________________________________________________________________________________________________________________________________________________________________________________________________________"
Xlin:=Xlin+1
@ Xlin,000 PSAY "|        |      |         |     QUANTIDADE DE AVES       |       P E S O   L I Q U I D O          |       |            |  AVES  |   MORTALIDADE |      |     |       |TEMPO DE|  HORA  | HORA   |   DATA    |  DATA         |"
Xlin:=Xlin+1
@ Xlin,000 PSAY "|N. DA OC| GRNJ | VEICULO | ORIGEM    RECEBIDA  DIFERENÇA| ORIGEM        RECEBIDO       QUEBRA    | TURNO | PESO MEDIO | GAIOLA |QUANT.    PESO |No NF |TURMA|PedXml | ESPERA |CHEGADA | ABATE  |  CHEGADA  |  ABATE        |"
Xlin:=Xlin+1
@ Xlin,000 PSAY "+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
Return (Xlin)

/*Imprimindo a data de abate*/
static function Cabec5 (xLin)
@ xLin,000 PSAY "PERIODO DE ABATE"
xLin:=xLin+1
@ xLin,000 PSAY REPLICATE ("_",26)
xLin:=xLin+1
@ xLin,000 PSAY "|"
@ xLin,002 PSAY DTOC(_dDataIni)
@ xLin,012 PSAY "-"
@ xLin,014 PSAY DTOC(_dDataFim)
@ xLin,026 PSAY "|"
xLin:=xLin+1
@ xLin,000 PSAY REPLICATE("-",26)
xLin:=xLin+1
@ xLin,000 PSAY "[*] - <<<Veiculo sem SEGUNDA PESAGEM>>>"
xLin:=xLin+1
@ xLin,000 PSAY "      <<<SEGUNDA PESAGEM afeta os calculos quando nao considerado a tara padrao>>>"
Return (xLin)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CÁLCULO DO TEMPO DE ESPERA                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Static function HoraEsp () //Funcao que verifica a Data e Hora de abate e calcula tempo de espera.
//Verifico se as datas sao branco
if 	(_dEntPort="")
	_dEntPort:="00:00"
endif
if (_dAbtPla="")
	_dAbtPla:="00:00"
endif

If 	_dEntPort <> _dAbtPla
	// Dias do Mes  trocar por uma função do Protheus
	_nHorMes1 := 0
	_nHorMes2 := 0
	_cAno1 := Substr(_dEntPort,1,4)     // Ano
	_cDat1 := CtoD(Substr(_dEntPort,5,2)   )
	_cDat1 := CtoD(Substr(_dEntPort,7,2)+'/'+Substr(_dEntPort,5,2)+'/'+_cAno1 )
	_cDat2 := CtoD('01/01/'+ _cAno1)
	_nHorMes1 := ( _cDat1 - _cDat2)
	_nHorMes1 :=  _nHorMes1 * 1440
	//
	_cAno2 := Substr(_dAbtPla,1,4)     // Ano
	_cDat1 := CtoD(Substr(_dAbtPla,5,2)   )
	_cDat1 := CtoD(Substr(_dAbtPla,7,2)+'/'+Substr(_dAbtPla,5,2)+'/'+_cAno2 )
	_cDat2 := CtoD('01/01/'+ _cAno2)
	_nHorMes2 := ( _cDat1 - _cDat2)
	_nHorMes2 :=  _nHorMes2 * 1440
	
	// Calculo as horas de dias diferentes usando a data base de
	_dDat_Cal := CTOD('01/01/2005')
	// Calculo data Base
	_mCal1 :=  2005 * 518400 // Minutos do ano
	// Calculo data Atual de entrada
	_mCalAno1 := val(Substr(_dEntPort,1,4)) * 518400  // Minutos ano
	_mCalMes1 := _nHorMes1  // Minutos do mes conforme o numero de dia do ano
	_mCalDia1 := 0  //   val(Substr(_dEntPort,7,2)) * 1440    // Minutos do mes
	_mCalMin1 :=   val(Right(_hEntPort,2))  + (val(Left(_hEntPort,2))*60 )  // Minutos da hora de portaria
	//
	// Calculo data Atual da plataforma
	_mCalAno2 := val(Substr(_dEntPort,1,4)) * 518400  // Minutos ano
	_mCalMes2 := _nHorMes2   // Minutos do mes conforme o numero de dia do ano
	_mCalDia2 :=  0  //  val(Substr( _dAbtPla,7,2)) * 1440    // Minutos do mes
	_mCalMin2 :=  val(Right(_hAbtPla,2))  + (val(Left(_hAbtPla,2))*60 )  // Minutos da hora de portaria
	
	_nTot_m1 := (_mCalAno1 +	_mCalMes1 + _mCalDia1 +  _mCalMin1) - _mCal1
	_nTot_m2 := (_mCalAno2 +	_mCalMes2 + _mCalDia2 +  _mCalMin2 ) - _mCal1
	
	// Calculo  a diferenca da hora
	_dHresp :=  _nTot_m2    -  _nTot_m1     //voltado para hora fracionada
Else
	_cMin1 := Right(_hEntPort,2)	// MINUTO DA HORA DE ENTRADA
	_cHr1  := Left(_hEntPort,2)  // HORA DA ENTRADA
	//
	_nMin1:= val(_cMin1)     // minutos
	_nHr1  := val(_cHr1)*60  // horas para minutos
	//
	_nTotT1:=_nHr1+_nMin1     //CONVERTIDO EM MINUTOS
	//---------------------------------------------------------------------------
	_cMin2 := Right(_hAbtPla,2)   //minuto da hora de abate
	_cHr2   := Left(_hAbtPla,2)    //hora do abate
	//
	_nMin2 :=val(_cMin2)    //minutos
	_nHr2   :=val(_cHr2)*60  //horas para minutos
	
	_nTotT2 :=_nHr2+_nMin2     //convertendo
	_dHresp := ( _nTotT2 - _nTotT1)    //voltado para hora fracionada
Endif

_dHR  := INT(_dHresp/60)     //calculando a Inteira da hora
_dMR  :=  _dHresp/60
_dM1  := ( (_dHresp/60) - _dHR )*60  //calculando a parte fracionaria dos minutos
_dM2  := str((_dM1+100),3)
_dM3  := substr(_dM2,2,2)
_dView:=alltrim(str(ABS(_dHR )))+":"+_dM3//Mostarndo a data no formato 99:99h
// Faço somatoria para tirar a média aritmetica
_nMedi_Hr := _nMedi_Hr + _dHresp
_nCount_Hr := _nCount_Hr + 1

Return





Static Function PROCFUNCTIONS(xLin)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CALCULOS                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico data de chegada e data abate efetivo                                                       ³
//³Caso a datas sejam as mesmas faco uma simples diferenca                                             ³
//³Caso seja diferentes:                                                                               ³
//³                                                                                                    ³
//³[1] HR chegada - 24:00h                                                                             ³
//³[2] HR ABATE EFETIVO       +                                                                        ³
//³-------------------------------                                                                     ³
//³   HR DE ESPERA                                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HoraEsp ()
Apanha1()
Apanha2()

_nDifRPaves       :=(_nRAVES-_nPAVES)                 				//DIFERENCA DO NUMEROS DE AVES ENVIADAS E RECEBIDAS
//sigoli inicio
IF _cMarkS_M = 'M'
	_nDif1Pe2Pe		  :=Round(((_n1PESO-_n2PESO) - _nSomaPeso)-((((_n1PESO-_n2PESO) - _nSomaPeso)*_nPrcQueb)/100),0) //PESO LIQUIDO DO PESO REAL RECEBIDO 	 = PRIMEIRO PESO - SEGUNDO PESO
eLSE
	_nDif1Pe2Pe		  :=(_n1PESO-_n2PESO) - _nSomaPeso       			//PESO LIQUIDO DO PESO REAL RECEBIDO 	 = PRIMEIRO PESO - SEGUNDO PESO
Endif
//Sigoli fim
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VERIFICO O PARAMETRO E CASO SEJA UTILIZADO O PESO DE AJUSTE ³
//³ACUMULO O PESO DE AJUSTE NO PESO LIQUIDO                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF _LAjusPe=2
	_nDif1Pe2Pe:=_nDif1Pe2Pe+_nAjusPs
EndIF

//VERIFICO SE UTILIZO AVES DO CONTADOR OU CARREGADAS
If (_lQAvCar=2)
	_nPESOME		  :=_nDif1Pe2Pe/(_nRAVES+_nMORTAL)	     //Peso medio real=PESO RECEBIDO/AVES CONTADOR+MORTOS  [CALCULO COM AVES CONTADOR]
else
	_nPESOME		  :=_nDif1Pe2Pe/( _nPAVES )	         //Peso medio real=PESO RECEBIDO/AVES CONTADOR  [CALCULO COM AVES CARREGADAS]
endIF
_nMulMrtPe		  := ROUND((_nMORTAL*_nPESOME),0)           			 //PESO DA MORTALIDADE 	 = PESO MEDIO x QTD DE MORTALIDADE  MAFRA
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VERIFICANDO QUAL O TIPO DA GRANJA                         ³
//³	SE O CODIGO DO FORNECEDOR  DA ADORO FOR IGUAL AO RECEBIDO³
//³	UTILIZO A PORCENTAGEM DE QUEBRA PARA INTEGRADOS DA ADORO ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF (_nContFor==_cForRec)
	_lCalQbr:=1  //Fornecedor adoro
Else
	_lCalQbr:=0 //fornecedor terceiro
EndIf

IF (_lCalQbr = 1)
	_nSMPesPorc:=val(_nContudPr)
	_nContud:=_nSMPesPorc
Else
	_nMulPemRav	      :=_nPesNF                    //peso liquido da origem
	_nQuebra		  :=(_nMulPemRav - _nDif1Pe2Pe)		   //QUEBRA
	_nSMPesPorc:=(_nQuebra/_nPesNF)	*100		   //PORCENTAGEM DA QUEBRA GRANJA TERCEIRA=(quebra/peso origem+quebra/pesorecebido)/2
	_nContud:=_nSMPesPorc							       //SETO A PORCENTAGEM QUE ACABEI DE CALCULAR
EndIf
//Se for granja de terceiro nao aplico porcentagem de quebra no peso dos terceiros
if _lCalQbr=1
	_nMulPemRav	      :=    _nDif1Pe2Pe+(_nDif1Pe2Pe*(_nContud/100))//CALCULANDO A PESO LIQUIDO DA ORIGEM[PESO LIQUIDO RECEBIDO + 0,7%]
	_nQuebra		  :=(_nMulPemRav - _nDif1Pe2Pe)				//QUEBRA
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CALCULOS DA NF                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//se o peso da NF for 0 imprimo no complemento de peso o valor 0
if  _nPesoNf=0
	_nPDifNFRec:=0
else
	_nPDifNFRec       :=_nMulPemRav-_nPesoNf					 //peso recebido - peso NF = peso complemento
endIf

_nVDNFREC   	  :=_nPDifNFRec*_nNfVunit//_nUnitAt	   				 					 //complemento da NF
_nDifPeRPeNf	  :=(_nMulPemRav-_nPesoNf)             		 //DIFERENCA DO PESO REAL PELA NF
_nVrealNF		  :=_nMulPemRav*_nNfVunit					 			 //Valor Real da NF Recebida
_nNFCompl		  :=((_nMulPemRav-_nPesoNf))* _nUnitAt 	 	 //complemento da NF

//calculo da media poderada - Total  %%desabilitado por Mauricio - HC Consys em 05/08/09.
if _lPriVez==1	//primeira vez nao considera o peso anterior
	_nMepon1:=_nPESOME
	_lPriVez:=0
else
	_nTotMePon:=(((_nDif1Pe2Pe )*(_nPESOME))+(_nPesAnt * _nTotMePon))/( _nPesAnt + _nDif1Pe2Pe)
EndIF
_nPesAnt:= 	_nPesAnt + _nDif1Pe2Pe //guarda o peso anterior

//CALCULO DA PERDA DE AVES EM PORCENTAGEM
PerMort:=(_nMORTAL/_nRAVES)*100

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ACUMULANDO RESULTADOS                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

_nTotFgvOri   :=  _nTotFgvOri + _nPAVES + _nSomaQtd	        	//TOTAL DE AVES DA ORIGEM
_nTotFgvRec   :=  _nTotFgvRec + _nRAVES + _nSomaQtd	        	//TOTAL DE AVES DA RECEBIMENTO
_nTotFgvDif   :=  _nTotFgvDif + (_nDifRPaves)     	//TOTAL DE AVES DA DIFERENCA
//
// AQUI !
//_nTotPesOri   :=  _nTotPesOri + _nMulPemRav + (_nSomaPeso*1.007)     	//TOTAL PESO ORIGEM  -- HC CONSYS 14/04/2009

// FWNM - 25/04/2018
_nTotPesOri   :=  _nTotPesOri + _nMulPemRav + (_nSomaPeso*1.007)     	//TOTAL PESO ORIGEM  -- HC CONSYS 14/04/2009
//_nTotPesOri   :=  _nTotPesOri + ROUND(_nMulPemRav + (_nSomaPeso*1.007),0)     	//TOTAL PESO ORIGEM  -- HC CONSYS 14/04/2009

//Ana 16/07/14 - Retirado conforme solicitacao da Silvana PCP pois esta subtraindo o valor de quebra da apanha
_nTotPesRec   :=  _nTotPesRec + (_nDif1Pe2Pe + (_nSomaPeso))     //TOTAL PESO RECEBIMENTO -- HC CONSYS 14/04/2009 e 05/08/09 para somar apanhe.
//_nTotPesRec   :=  _nTotPesRec + ROUND((_nDif1Pe2Pe + (_nSomaPeso*0.993)),0)     //TOTAL PESO RECEBIMENTO -- HC CONSYS 14/04/2009 e 05/08/09 para somar apanhe.

_nTotPesQbr   :=  _nTotPesQbr + _nquebra   			//TOTAL PESO QUEBRA -- HC CONSYS 14/04/2009
_nTotPesPrc   :=  _nTotPesPrc + _nSMPesPorc   		//TOTAL PESO PORCENTAGEM
_nTotMrtQtd   :=  _nTotMrtQtd + _nMORTAL        	//TOTAL MORTALIDADE QUANTIDADE
_nTotMrtPes   :=  ROUND(_nTotMrtPes + (_nMulMrtPe),0)      	//TOTAL MORTALIDADE PESO MAFRA
_nTotPesNf    :=  _nTotPesNf  + (_nPesoNf)	    	//TOTAL DO PESO LIQUIDO NF
_nTotValtNf	  :=  _nTotValtNf + _nNfVunit        	//TOTALIZA VALOR UNITARIOF
_nTotValuNF	  :=  _nTotValuNF + _nNfTotal        	//TOTALIZA VALOR TOTAL DA NF
_nTotDifPeNF  :=  _nTotDifPeNF+ (_nDifPeRPeNf)    	//TOTAL DA DIFERENCA DO PESO REAL PELA NOTA
_nTotDifVNF   :=  _nTotDifVNF + (_nNFCompl) 		//TOTAL DA DIFERENCA DO VALOR DA NOTA PELO REALIZADO --COMPLEMENTO
_nTotVRec	  :=  _nTotVRec   + _nVrealNF           //TOTAL DO VALOR RECEBIDO
_nTotPeCpm	  :=  _nTotPeCpm  + _nPDifNFRec         //total do complemento do peso
_nTotVNfRec   :=  _nTotVNfRec + _nVDNFREC           //total do complemento do valor
_nTotVUNFM    :=  _nTotVUNfM  + _nUnitAt            //total do unitário do mes
_nQtdRec      :=  _nQtdRec	  + 1                   //CONTA REGISTROS
_nTotPmo      +=PerMort								//total de perda

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculando a media aritimetica  --PORCENTAGEM DE QUEBRA     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_nTotPespcT:=_nTotPesPrc/_nQtdRec

Return(xLin)








Static Function GETVARS(xLin)   //obtem dados

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³OBTENDO OS CAMPOS DA QUERY³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//SE FOR CONSIDERADO PESO PADRAO TROCA O VALOR DE _N2PESO POR ZV4_PESO - TARA PADRAO
IF (_LTarPadr=2)
	_n2PESO	  :=ROC->ZV2_2PESO              //OBTEM O SEGUNDO PESO
ELSE
	_n2PESO	  :=ROC->ZV1_TARAPD             //OBTEM TARA PADRAO
ENDIF
_nPesNF   :=ROC->ZV1_PESONF					//PESO NF

//----------------------------------------------------------------------------------------------------------------
// Alteracao efetuada por Celso Costa em 14/12/2007
// A quebra nao deve ser considerada neste momento, pois ja esta embutida na primeira pesagem conforme informacoes
// obtidas com Rosangela, Pamela e Admilson
_n1PESO	  :=ROC->ZV2_1PESO - ROC->ZV1_QTDQBR   //PRIMEIRO PESO - QUEBRA DE BALANCA
//_n1PESO	  :=ROC->ZV2_1PESO
//----------------------------------------------------------------------------------------------------------------

_n2PesoOC :=ROC->ZV2_2PESO               	//OBTEM O SEGUNDO PESO para OC marcar '*'
//VERIFICO SE UTILIZO AVES DO CONTADOR OU CARREGADAS
If (_lQAvCar=1)
	_nRAVES	  :=ROC->ZV1_PAVES                  //OBTEM O NUMERO DE AVES REAIS CONTADOR
Else
	_nRAVES	  :=ROC->ZV1_RAVES                  //OBTEM O NUMERO DE AVES REAIS CONTADOR
EndIf
_nPAVES	  :=ROC->ZV1_CAVES                  //OBTEM O NUMERO DE AVES carregadas
_cNUMOC	  :=ROC->ZV1_NUMOC 	                //OBTEM NUMERO DA OC

//09/09/2016- coloca recurso para mostrar veiculo com a primeira pesagem molhado, aplicado descondo no peso liquido
_cMarkS_M  := " " //zero a variavel

If ROC->ZV1_CLIBAL = 'M'
	_cMarkS_M :=ROC->ZV1_CLIBAL
EndIF

//_cRGRANJ  :=SUBSTR(ROC->ZV1_RGRANJ,1,4)     //OBTEM O INTEGRADO
_cRGRANJ  :=SUBSTR(ROC->ZV1_RGRANJ,1,5)     //OBTEM O INTEGRADO    // Chamado Silvana em 13/10/2014
_cPPLACA  :=ROC->ZV1_RPLACA                 //OBTEM A PLACA
_nMORTAL  :=ROC->ZV1_MORTAL                 //OBTEM A QUANTIDADE DA MORTALIDADE
_nNUMNFS  :=ROC->ZV1_NUMNFS                 //NUMERO DA NF
_nTURMA   :=ROC->ZV1_TURMA
_nVALUNF  :=ROC->ZV1_VALUNF                 //VALOR UNITARIO DA NF
_nLojFor  :=ROC->ZV1_LOJFOR					//LOJA FORNECEDOR
_nCodFor  :=ROC->ZV1_CODFOR					//CODIGO FORNECEDOR
_cPGRANJ  :=ROC->ZV1_PGRANJ					//INTEGRADO
_cForRec  :=ROC->ZV1_FORREC				    //FORNECEDOR RECEBIDO
_cLojRec  :=ROC->ZV1_LOJREC                 //LOJA RECEBIDA
_dRhVp    :=ROC->ZV1_RHVP  					//HORA DE CHEGADA EM VP
_dRhAbt   :=ROC->ZV1_RHABAT                 //HORA DE INICIO DE ABATE
_dDtaRea  :=ROC->ZV1_DTAREA					//DATA DE ABATE EFETIVAMENTE REALIZADA
_dDtaBat  :=ROC->ZV1_DTABAT					//DATA DE ABATE
_nAjusPs  :=ROC->ZV1_AJUSPS                 //Peso Ajustado
_hEntPort :=ROC->ZV1_RHVP  					//HORA DE CHEGADA EM VP
_hAbtPla  :=ROC->ZV1_RHABAT                //HORA DE INICIO DE ABATE
_dEntPort :=ROC->ZV2_DATA1					//DATA DE ABATE em o veiculo chegou na portaria
_dAbtPla  :=ROC->ZV1_DTAREA					//DATA DE DESCAREGAR NA PLATAFORMA
_cSerie	  :=ROC->ZV1_SERIE					//SERIE DA NF
_cCliVol  :=ROC->ZV1_CLIVOL					//CLIMA NA VOLTA

_nAvesGa  :=ROC->ZV1_AVESGA					//Aves por gaiola //Chamado:049564 - Fernando Sigoli 09/07/2019 
_cTurAbt  :=BuscaTur(ROC->ZV1_NUMOC)       //Turno de abate  //Chamado:049564 - Fernando Sigoli 09/07/2019           



&&Chamado 006667 - Mauricio - Busco numero do C5_PEDXML.
DbSelectArea("SC5")
DbSetOrder(15)
if Dbseek("03"+STRZERO(Val(Alltrim(_nNUMNFS)),9)+"01")  &&Conforme informado toda NF vem sempre da filial 03(Frango vivo) e devera sempre procurar por serie 01.
	&&if Dbseek("03"+STRZERO(Val(Alltrim(_nNUMNFS)),9)+_cSerie)
	_cPEDXML := SC5->C5_PEDXML
else
	_cPedXML := space(06)
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VERIFICO SE FOI REALIZADO A SEGUNDA PESAGEM           ³
//³FACO UM AMARCA ONDE NAO FOI REALIZADO A SEGUNDA PESAGEM³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

if (_n2PesoOC=0)
	_cMarkX:='*' //MARCA A OC
	_nC:=001//Coluna
Else
	_cMarkX:=''
	_nC:=002
endIF

// Posiciona nas Notas de Entrada SD1
//para obtermos os valores da NF
DbSelectArea("SD1")
DbSetOrder(1)
// D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
//
//
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
//CORIGIR O SEEK ABAIXO --->+_CSERIE+' '
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
//
//
If DbSeek(xFilial("SD1")+_nNUMNFS+_cSerie+' '+_cForRec+_cLojRec,.T.)
	_nNfVunit :=D1_VUNIT				//VALOR UNITARIO DA NF
	_nNfTotal :=D1_TOTAL                //VALOR TOTAL DA NF
	_nPesoNf  :=D1_QUANT                //OBTEM O PESO DA NF
Else
	_nNfVunit := 0         				//VALOR UNITARIO DA NF
	_nNfTotal := 0                      //VALOR TOTAL DA NF
	_nPesoNf  := 0                      //OBTEM O PESO DA NF
Endif
dbCloseArea("SD1")
DbSelectArea("ROC")//valotano para areal atual
dbSkip() // Avanca o ponteiro do registro no arquivo
_dDTBatF:=ROC->ZV1_DTABAT//RECEBENDO PROXIMO REGISTRO
DbSelectArea("ROC")//valotano para areal atual
&&MsgAlert("OS : "+_cNUMOC+" Abate: "+_dDTBatF)

Return(xLin)






Static Function PRINTREPORT(xLin,lAuto)//Imprime relatorio

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³IMPRIMINDO  RELATORIO                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !lAuto
	If AllTrim(FunName()) <> "AD0130" .and. AllTrim(FunName()) <> "ADLFV010P"  // FWNM - 16/04/2018 - CHAMADO 037729
		
		DO CASE
			CASE _lReduz==1
				
				@ xLin,002 PSAY _cRGRANJ      			//INTEGRADO
				@ xLin,007 PSAY _nNUMNFS      			//NUMERO DA NF
				@ xLin,015 PSAY _nTURMA       			//TURMA
				@ xLin,020 PSAY _nPAVES       			//QTD AVES ORIGEM
				@ xLin,029 PSAY _nMulPemRav PICTURE "@E 999,999"		   		//PESO LIQUIDO ORIGEM
				@ xLin,041 PSAY _nVrealNF   PICTURE "@E 9,999,999.99"	   //RECEBIDO VALOR
				@ xLin,054 PSAY _nPDifNFRec PICTURE "@E 99,999,999"    	//PESO complemento
				@ xLin,063 PSAY _nVDNFREC PICTURE "@E 9,999,999.99"		//VALOR COMPLEMENTO
				@ xLin,080 PSAY _nNfVunit PICTURE "@E 9,999.9999"   		//VALOR UNITARIO DA NF
				
				//se a nota não estiver atualizada não imprimo o unitário atual
				if _nNfVunit=0
					@ xLin,093 PSAY 0  PICTURE "@E 9,999.9999"         //uNITÁRIO aTUAL
				else
					@ xLin,093 PSAY _nUnitAt  PICTURE "@E 9,999.9999"         //uNITÁRIO aTUAL
				endIf
				xLin++
			
			CASE _lReduz==2
				
				@ xLin,000 PSAY _cMarkS_M    						//MARCA SECO / MOLHADO
				@ xLin,_nC PSAY _cMarkX+_cNUMOC       				//NUMERO DA OC
				@ xLin,013 PSAY _cRGRANJ               				//GRANJA/INTEGRADO
				@ xLin,020 PSAY _cPPLACA                			//VEICULO
				@ xLin,030 PSAY _nPAVES 		picture '99999'		//QTD AVES ORIGEM
				@ xLin,038 PSAY _nRAVES			picture '99999'     //QTD AVES RECEBIDAS
				@ xLin,048 PSAY _nDifRPaves 	picture '99999'     //QTD AVES DIFERENCA
				@ xLin,058 PSAY _nMulPemRav 	picture '99999999'  //PESO LIQUIDO ORIGEM
				@ xLin,072 PSAY _nDif1Pe2Pe  	picture '99999999'  //PESO LIQUIDO REAL
				@ xLin,086 PSAY _nPesoNf		picture '99999999'  //PESO INFORMADO NA NF
				@ xLin,100 PSAY _nQuebra 		picture '99999'	 	//QUEBRA (PESO)
				@ xLin,113 PSAY _nDifPeRPeNf 	picture '99999999'  //QUEBRA NF -- DIFERENCA PESO REAL COM O DA NOTA
				//@ xLin,126 PSAY _nSMPesPorc 	PICTURE '99.99'            	//PORCENTAGEM DE QUEBRA
				@ xLin,126 PSAY _cTurAbt             	                  	//TURNO ABATE  //Chamado:049564 - Fernando Sigoli 09/07/2019 
				@ xLin,134 PSAY _nPESOME		PICTURE '@E 99.999' //PESO MEDIO
				@ xLin,148 PSAY _nMORTAL  		picture '99999'     //QTD MORTALIDADE
				@ xLin,156 PSAY _nMulMrtPe 		picture '99999999'  //PESO AVES MORTALIDADE
				@ xLin,168 PSAY _nNUMNFS              	 			//NUMERO DA NF
				@ xLin,177 PSAY _nTURMA                             //TURMA DE CARREGAMENTO
				@ xLin,180 PSAY _nNfVunit PICTURE "@E 9,999.9999"    //VALOR UNITARIO DA NF
				@ xLin,194 PSAY _nNfTotal PICTURE "@E 9,999,999.99"  //VALOR DA NF
				@ xLin,207 PSAY _nNFCompl PICTURE "@E 9,999,999.99"  //COMPLEMENTO
				xlin:=Apanha(xlin) //Checa se houve apanha
				xLin++ 
				
			CASE _lReduz==3
				
				@ xLin,000 PSAY _cMarkS_M    			//MARCA SECO / MOLHADO
				@ xLin,_nC PSAY _cMarkX+_cNUMOC        	//NUMERO DA OC
				@ xLin,011 PSAY _cRGRANJ        		//GRANJA/INTEGRADO     //013
				@ xLin,018 PSAY _cPPLACA        		//VEICULO   020
				@ xLin,028 PSAY _nPAVES         		//QTD AVES ORIGEM  030
				//		@ xLin,040 PSAY _nRAVES        			//QTD AVES RECEBIDAS
				@ xLin,038 PSAY _nPAVES        			//QTD AVES RECEBIDAS 040
				//		@ xLin,050 PSAY _nDifRPaves 			//QTD AVES DIFERENCA
				@ xLin,048 PSAY 0 			//QTD AVES DIFERENCA	050
				//		@ xLin,059 PSAY _nMulPemRav 	//PESO LIQUIDO ORIGEM  061
				@ xLin,056 PSAY TRANSFORM(_nMulPemRav, "@E 999,999,999.99")//_nMulPemRav PICTURE '99999999.99'	//PESO LIQUIDO ORIGEM  061 - FWNM - 25/04/2018 - CHAMADO 041287
				//		@ xLin,059 PSAY _nMulPemRav PICTURE '999999'	//PESO LIQUIDO ORIGEM  061
				//		@ xLin,059 PSAY _nMulPemRav PICTURE '99999.99'	//PESO LIQUIDO ORIGEM  061
				@ xLin,073 PSAY _nDif1Pe2Pe 	//PESO LIQUIDO REAL    075
				@ xLin,090 PSAY _nQuebra 	picture '@eE 999' 	//QUEBRA (PESO)    090
				//@ xLin,101 PSAY _nSMPesPorc PICTURE '99.99' 			//PORCENTAGEM DE QUEBRA   102
		   		@ xLin,101 PSAY	_cTurAbt             	                  	//TURNO ABATE   102   //Chamado:049564 - Fernando Sigoli 09/07/2019 
				@ xLin,109 PSAY _nPESOME 	 PICTURE '@E 99.999' //PESO MEDIO 111
				//@ xLin,122 PSAY _nAjusPs                //PESO DE AJUSTE 124
				@ xLin,122 PSAY _nAvesGa                //aves por gaiola
				@ xLin,130 PSAY _nMORTAL 				//QTD MORTALIDADE 135
				@ xLin,137 PSAY _nMulMrtPe 	PICTURE '@E 99999' //PESO AVES MORTALIDADE 147
				@ xLin,145 PSAY _nNUMNFS        		//NUMERO DA NF 158
				@ xLin,154 PSAY _nTURMA
				@ xLin,158 PSAY _cPEDXML
				@ xLin,168 PSAY _dView					//tempo de espera 168
				@ xlin,177 PSAY _dRHVP					//Hora de Chegada 179
				@ xLin,186 PSAY _dRHAbt					//Hora de Abate 188
				_dDatEntr:=  SUBSTR (_dEntPort,7,2)+ "/" + SUBSTR (_dEntPort,5,2) +"/"+ SUBSTR (_dEntPort,1,4)
				@ xlin,193 PSAY _dDatEntr //DATA DA GUIA 197
				_dDatEntr:=  SUBSTR (_dDtaRea,7,2)+ "/" + SUBSTR (_dDtaRea,5,2) +"/"+ SUBSTR (_dDtaRea,1,4)
				@ xLin,206 PSAY _dDatEntr      //208
				_dDatEntr:=  SUBSTR (_dDTBatF,7,2)+ "/" + SUBSTR (_dDTBatF,5,2) +"/"+ SUBSTR (_dDTBatF,1,4)
				xlin:=Apanha(xlin) //Checa se houve apanha
				xLin++
				
			OTHERWISE
		ENDCASE
		
	EndIF
EndIF


// FWNM - 18/04/2018 - CHAMADO 037729
If AllTrim(FunName()) == "AD0130" .or. AllTrim(FunName()) == "ADLFV010P" .or. lAuto // FWNM - 18/04/2018 - CHAMADO 037729
	
	// cFilPV   := GetMV("MV_#LFVFIL",,"03") // @history Ticket 74568 - Fernando Macieira - 13/06/2022 - Pedido de Complemento - Filial 0A
	cSerNFFV := GetMV("MV_#LFVSER",,"01")
	cCliCod  := GetMV("MV_#LFVCLI",,"027601")
	cCliLoj  := GetMV("MV_#LFVLOJ",,"00")
	cProdPV  := GetMV("MV_#LFVPRD",,"300042")
	
	SD2->( dbSetOrder(3) ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	If SD2->( dbSeek(cFilPV+StrZero(Val(_nNUMNFS),TamSX3("D2_DOC")[1])+PadR(cSerNFFV,TamSX3("D2_SERIE")[1])+cCliCod+cCliLoj+cProdPV) )
		nTtPLP += SD2->D2_QUANT
		nTtPLO += _nMulPemRav
		
		//cNFNot += AllTrim(_nNUMNFS) + "|" -- apenas debug
		
		GrvArquivo( .T., "", _cNumOC, _dDatEntr, _nMulPemRav, _nNUMNFS, "", SD2->D2_QUANT, "" )
		
	Else
		// NF nao encontradas para não gravar ZV1_FLAGPV
		cNFNot += AllTrim(_nNUMNFS) + "|"
		
		GrvArquivo( .T., "", "", "", 0, "", "", 0, _nNUMNFS )
		
	EndIf
	
	Apanha(xLin)
	
EndIf


Return(xLin)





//VERIFICA A TROCA DE DATAS E IMPRIME TOTAIS
Static Function ChkDate(xLin)
IF (_dDTBatF<>_dDtaBat) &&.Or. Eof() //Verifico se foi alterado a data e faco a quebra
	if(_dDatEntr<>'  /  /    ')
		xLin:=IMPTOTS(xLin) //Imprimo os totais
		xLin:=LockSun(xLin) //guardo totais para os totais gerais
		xLin:=ZERATOTS(xlin) //zero totais
	else
		xLin:=LockSun(xLin)
		xLin:=IMPTOTS(xLin)
	endif
	//quebra de pagina
	_lQbrP:=1
	//contando os dias para calculo das medias por dias
	_nCoutD++
else
	_lQbrP:=0
EndIf

dLin:=xLin

Return(_lQbrP)





Static Function DtaCorr(xLin)//Imprime data Corrente
xLin:=xLin+1
@ xLin,000 PSAY REPLICATE("-",220)
xLin:=xLin+1
_cTexto:="DATA: ("+_dDatEntr+")"
@ xLin,(LIMITE/2)-(LEN(_cTexto)/2) PSAY _cTexto
xLin:=xLin+1
@ xLin,000 PSAY REPLICATE("-",220)
xLin:=xLin+1
Return(xLin)






Static Function LockSun(xLin)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVANDO TOTAIS PARA O TOTAL GERAL                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

TGAC		:= TGAC			+_nTotFgvOri				// AVES CARREGADAS
TGAR		:= TGAR			+_nTotFgvRec				// AVES RECEBIDAS
TGDACAR	    := TGDACAR		+_nTotFgvDif				// DIFERENCA DE AVES CARREGADAS E RECEBIDAS

// FWNM - INIBIDO IF - CHAMADO 041092
//If _nTotFgvOri > 0 && HCCONSYS 02/02/09
TGPO		:= TGPO			+_nTotPesOri				// PESO ORIGEM
TGPR		:= TGPR			+_nTotPesRec				// PESO RECEBIMENTO
TGPQ		:= TGPQ			+_nTotPesQbr				// QUEBRA DE PESO
TGPP		:= TGPP			+_nTotPespcT				// PORCENTAGEM DE QUEBRA
TGMQ		:= TGMQ			+_nTotMrtQtd				// MORTALIDADE
TGMP		:= TGMP			+_nTotMrtPes				// PESO DA MORTALIDADE
TGPNF		:= TGPNF		+_nTotPesNf					// PESO NOTA FISCAL
TGPQNF	    := TGPQNF		+_nTotDifPeNF				// QUEBRA DA NF
TGNFU		:= TGNFU		+_nTotValtNf				// UNITARIO NF
TGNFV		:= TGNFV		+_nTotValuNF				// VALOR DA NOTA
TGNFC		:= TGNFC 		+_nTotDifVNF				// COMPLEMENTO DA NF
TGNFA		:= TGNFA		+_nTotVUNFM					// UNITARIO ATUAL
TGNVT		:= TGNVT		+_nTotVRec     			// TOTAL DO VALOR RECEBIDO
TGCP		:= TGCP			+_nTotPeCpm    			// Total do complemento do peso
TGCV		:= TGCV			+_nTotVNfRec   			// Total do complemento do valor
//TGPP	:= TGPP			/_nCoutD        			// Media aritimetica da por centagem de quebra por dias
TGPM    	:= (TGPM     	+_nTotMePon)/_nCoutD  	// Total do peso medio
TGPMOT  	+= _nTotPmo										// TOTAL DE pERDA

//Endif

Return(xLin)






Static Function IMPTOTS(xLin)//Imprimindo totais
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³IMPRIMINDO TOTAIS                                          ³
//³
//³SE NAO HAVER AVES NO TOTAL ELE NAO IMPRIME RELATORIO       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

_nTotPesOri:=_nTotPesOri//RETIRANDO A CASA DECIMAL
_nTotPesRec:=_nTotPesRec//RETIRANDO A CASA DECIMAL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³IMPRIMINDO TOTAIS POR DIA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF (_nTotFgvOri>0)
	
	_dDatEntr:=  SUBSTR (_dDtaBat,7,2)+ "/" + SUBSTR (_dDtaBat,5,2) +"/"+ SUBSTR (_dDtaBat,1,4)
	if _lSint<>1 //Se for Analitico
		@ xLin,000 PSAY REPLICATE ("_",220)
		xLin:=xLin+1
		@ xLin,000 PSAY "TOTAIS ---->"
	else
		@ xlin,000 PSAY	_dDatEntr
	ENDIF
	
	DO CASE
		CASE _lReduz==1
			
			@ xLin,018 PSAY _nTotFgvOri		picture '999999'		//TOTAL AVES ORIGEM
			@ xLin,029 PSAY TRANSFORM(_nTotPesOri, "@E 999,999,999.99")//_nTotPesOri  	picture '999,999,99.99' 	//TOTAL PESO ORIGEM
			@ xLin,041 PSAY _nTotVRec 	   	picture '99,999,999.99'	//Total Recebido Valor
			@ xLin,057 PSAY _nTotPeCpm 										//Total complemento Peso
			@ xLin,066 Psay _nTotVNfRec 	picture '99,999,999.99'	//Total complemento Valor
			@ xLin,083 PSAY _nTotValtNf   	picture '9,999.9999'	//TOTAL VALOR UNITARIO NF
			@ xLin,096 Psay _nTotVUNFM  	picture '9,999.9999'	//Total unitario Nf agora
			xLin++
		CASE _lReduz==2
			
			@ xLin,030 PSAY _nTotFgvOri	picture  '999999'//TOTAL AVES ORIGEM
			@ xLin,038 PSAY _nTotFgvRec	picture  '999999'//TOTAL AVES RECEBIDA [INFORMAÇÃO DO CONTADOR]
			@ xLin,049 PSAY _nTotFgvDif   picture  '999999'//TOTAL DIFERENCA
			@ xLin,060 PSAY TRANSFORM(_nTotPesOri, "@E 999,999,999.99")//_nTotPesOri   picture  '999999.99'//TOTAL PESO ORIGEM
			@ xLin,074 PSAY _nTotPesRec   picture  '999999'//TOTAL PESO RECEBIDO
			@ xLin,088 PSAY _nTotPesNf    picture  '999999'//TOTAL NF PESO RECE
			@ xLin,100 PSAY _nTotPesQbr   picture  '999999'//TOTAL QUEBRA
			@ xLin,114 PSAY _nTotDifPeNF  picture  '999999'//TOTAL QUEBRA NF
			//@ xLin,126 PSAY _nTotPespcT   picture  '9,999.99'//TOTAL PORCENTAGEM
			//@ xLin,134 PSAY _nTotMePon   picture  '9,999.99'//TOTAL PESO MED
			@ xLin,134 PSAY (_nTotPesRec/_nTotFgvOri) picture  '9999.999'//TOTAL PESO MED COnf. Marianen retirar calculo ponderado do total.
			@ xLin,148 PSAY _nTotMrtQtd   picture  '999999'//TOTAL QTD MOTAL
			@ xLin,156 PSAY _nTotMrtPes   picture  '999999'//TOTAL PESO MORTAL
			@ xLin,178 PSAY _nTotValtNf   picture  '9,999.99'//TOTAL VALOR UNITARIO NF
			@ xLin,194 PSAY _nTotValuNF   picture '99,999,999.99'//TOTAL VALOR TOTAL NF
			@ xLin,207 PSAY _nTotDifVNF   picture '99,999,999.99'//TOTAL COMPLEME. NF
			
			xLin:=xLin+1
			
		CASE _lReduz==3
			
			@ xLin,026 PSAY _nTotFgvOri 	picture '999999'  //TOTAL AVES ORIGEM
			//			@ xLin,040 PSAY _nTotFgvRec 	picture '999999' //TOTAL AVES RECEBIDA [INFORMAÇÃO DO CONTADOR]
			@ xLin,036 PSAY _nTotFgvOri  	picture '999999' //TOTAL AVES RECEBIDA [INFORMAÇÃO DO CONTADOR]
			//			@ xLin,050 PSAY _nTotFgvDif 	picture '999999' //TOTAL DIFERENCA
			@ xLin,048 PSAY 0 	 //TOTAL DIFERENCA
			//			@ xLin,058 PSAY _nTotPesOri		picture '999999.99'  //TOTAL PESO ORIGEM
			@ xLin,056 PSAY TRANSFORM(_nTotPesOri, "@E 999,999,999.99")//_nTotPesOri		picture '99999999.99'  //TOTAL PESO ORIGEM
			@ xLin,072 PSAY _nTotPesRec  	picture '999999' //TOTAL PESO RECEBIDO
			@ xLin,088 PSAY _nTotPesQbr  	picture '999999' //TOTAL QUEBRA
			//@ xLin,098 PSAY _nTotPespcT   	picture '9,999.99'//TOTAL PORCENTAGEM
			//@ xLin,111 PSAY _nTotMePon   	picture '9,999.99'//TOTAL PESO MED
			@ xLin,107 PSAY (_nTotPesRec/_nTotFgvOri) picture  '9999.999'//TOTAL PESO MED COnf. Marianen retirar calculo ponderado do total.
			@ xLin,128 PSAY _nTotMrtQtd  	picture '999999' //TOTAL QTD MOTAL
			@ xLin,135 PSAY _nTotMrtPes   	picture '999999'//TOTAL PESO MORTAL
			// Faço somatoria para tirar a média aritmetica
			_dHresp := _nMedi_Hr / _nCount_Hr
			_dHR  := INT(_dHresp/60)     //calculando a Inteira da hora
			_dMR  :=  _dHresp/60
			_dM1  := ( (_dHresp/60) - _dHR )*60  //calculando a parte fracionaria dos minutos
			_dM2  := str((_dM1+100),3)
			_dM3  := substr(_dM2,2,2)
			
			
			_dView:=alltrim(str(ABS(_dHR )))+":"+_dM3+"  h"//Mostarndo a data no formato 99:99h
			
			_TgH+=_dHR//total de horas
			_TgM:=_TgM+val(_dM3)//total de Minutos
			_RecP++//total de registros
			
			@ xLin,168 Psay _dView 			//Total unitario Nf agora
			xLin:=xLin+1
			
		OTHERWISE
	ENDCASE
ENDIF

If _lSint<>1
	xLin:=999
EndIf

Return (xLin)





Static Function ZERATOTS(xLin) //Zerando Variaveis

/*=============
ZERANDO TOTAIS
==============*/

_nTotFgvOri   :=  0       	//TOTAL DE AVES DA ORIGEM
_nTotFgvRec   :=  0	        //TOTAL DE AVES DA RECEBIMENTO
_nTotFgvDif   :=  0     	//TOTAL DE AVES DA DIFERENCA
_nTotPesOri   :=  0     	//TOTAL PESO ORIGEM
_nTotPesRec   :=  0     	//TOTAL PESO RECEBIMENTO
_nTotPesQbr   :=  0 		//TOTAL PESO QUEBRA
_nTotPesPrc   :=  0  		//TOTAL PESO PORCENTAGEM
_nTotMrtQtd   :=  0     	//TOTAL MORTALIDADE QUANTIDADE
_nTotMrtPes   :=  0     	//TOTAL MORTALIDADE PESO
_nTotPesNf    :=  0	    	//TOTAL DO PESO LIQUIDO NF
_nTotValtNf	  :=  0       	//TOTALIZA VALOR UNITARIOF
_nTotValuNF	  :=  0      	//TOTALIZA VALOR TOTAL DA NF
_nTotDifPeNF  :=  0    		//TOTAL DA DIFERENCA DO PESO REAL PELA NOTA
_nTotDifVNF   :=  0			//TOTAL DA DIFERENCA DO VALOR DA NOTA PELO REALIZADO --COMPLEMENTO
_nTotVRec	  :=  0         //TOTAL DO VALOR RECEBIDO
_nTotPeCpm	  :=  0        	//total do complemento do peso
_nTotVNfRec   :=  0         //total do complemento do valor
_nTotVUNFM    :=  0         //total do unitário do mes
_nTotPmo	  :=  0         //Total de Perda
cNroFiscal    :=  ""        //numero Nota Fiscal de Apanha
cSerFiscal    :=  ""        //Serie Nota Fiscal de Apanha


RETURN (xLin)






Static function Apanha(xlin)
// Verifica se tem Apanha
_nQtdave  := 0
_nQtdPeso := 0
DbSelectArea("ZV5")
DbSetOrder(1)

If DbSeek(xFilial("ZV5")+_cNUMOC ,.T.)
	//Do While !Eof() .AND. _cNUMOC=ZV5->ZV5_NUMOC
	Do While !Eof() .AND. _cNUMOC=ZV5->ZV5_NUMOC .and. ZV5->ZV5_FILIAL == FWxFilial("ZV5") // @history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo	
		
		_cNumOc   	:= ZV5_NUMOC
		_cForcod  	:= ZV5_FORCOD
		_cForLoj  	:= ZV5_FORLOJ
		_nQtdave  	:= ZV5_QTDAVE
		nQtdApanha 	:= ZV5_QTDAVE
		_cGranj   	:= ZV5_RGRANJ
		_nQtdPeso 	:= ZV5_PESOAP
		cNroFiscal  := u_TiraZeros(ZV5_NUMNFS)//ZV5_NUMNFS // Chamado 040118 - Fernando Sigoli 
		cSerFiscal	:= ZV5_SERIE  // Chamado 040118 - Fernando Sigoli
		
		
		// Imprime os lancamentos de Apanha
		
		If !lAuto
			If AllTrim(FunName()) <> "AD0130" .and. AllTrim(FunName()) <> "ADLFV010P"  // FWNM - 16/04/2018 - CHAMADO 037729
				
				xLin:=xLin+1
				@ xLin,001 PSAY "[APANHA]"         					//GRANJA/INTEGRADO
				@ xLin,013 PSAY _cGranj          					//GRANJA/INTEGRADO
				@ xLin,030 PSAY _nQtdave  		   	            //QTD AVES ORIGEM
				
				IF _lReduz == 2
					@ xLin,038 PSAY _nQtdave
					//@ xLin,061 PSAY _nQtdPeso  PICTURE "99999999"     //PESO LIQ. DO APANHA
					&& Chamado 005105 - 01/10/09
					@ xLin,061 PSAY ROUND((_nQtdPeso)+ (_nQtdPeso*(_nContud/100)),0) PICTURE "99999999"     //PESO LIQ. DO APANHA
					_nTotPesOri   += ROUND((_nQtdPeso)+ (_nQtdPeso*(_nContud/100)),0) //Chamado 005138.
					
					//Alterado conforme chamado 004841
					//@ xLin,072 PSAY (_nQtdPeso*0.93)  PICTURE "99999999"     //PESO LIQ. DO APANHA
					&& Chamado 005105 - 01/10/09
					@ xLin,072 PSAY (_nQtdPeso)  PICTURE "99999999"     //PESO LIQ. DO APANHA
					
					@ xLin,087 PSAY ROUND((_nQtdPeso*(_nContud/100)),0)    //QUEBRA
					//************************************************************************
					@ xLin,134 PSAY (_nQtdPeso/_nQtdave)  PICTURE "@E 99.999"		   	//QTD AVES ORIGEM
					
					// numero da Nota e Serie de Apanha
					@ xLin,145 PSAY (cNroFiscal) //Nota Fiscal Chamado : 040118 Fernando Sigoli
					
					
				Else
					@ xLin,040 PSAY _nQtdave
					@ xLin,056 PSAY TRANSFORM((_nQtdPeso) + (_nQtdPeso*(_nContud/100)), "@E 999,999,999.99")//(_nQtdPeso) + (_nQtdPeso*(_nContud/100)) Picture "99999999.99"   //PESO LIQ. DO APANHA - FWNM - 02/05/2018 - CHAMADO 041287
					//			@ xLin,061 PSAY ROUND((_nQtdPeso)+ (_nQtdPeso*(_nContud/100)),0)    //PESO LIQ. DO APANHA
					
					//Ana 16/07/14 - Retirado pois estava duplicando o peso da apanha (Peso Liquido Recebido)
					//_nTotPesOri   += ROUND((_nQtdPeso)+ (_nQtdPeso*(_nContud/100)),0) //Chamado 005138.
					
					//Alterado conforme chamado 004841
					@ xLin,075 PSAY ROUND(_nQtdPeso,0)    //PESO LIQ. DO APANHA
					@ xLin,090 PSAY ROUND((_nQtdPeso*(_nContud/100)),0)    //QUEBRA
					//************************
					@ xLin,111 PSAY (_nQtdPeso/_nQtdave)  PICTURE "@E 99.999"		   	//QTD AVES ORIGEM
					
					// numero da Nota e Serie de Apanha
					@ xLin,145 PSAY (cNroFiscal) //Nota Fiscal Chamado : 040118 Fernando Sigoli
					
				EndIf
				
			EndIf
		
		EndIf
		
		// FWNM - 02/05/2018 - Chamado 037729
		If AllTrim(FunName()) == "AD0130" .or. AllTrim(FunName()) == "ADLFV010P" .or. lAuto
			
			// cFilPV   := GetMV("MV_#LFVFIL",,"03") // @history Ticket 74568 - Fernando Macieira - 13/06/2022 - Pedido de Complemento - Filial 0A
			cSerNFFV := GetMV("MV_#LFVSER",,"01")
			cCliCod  := GetMV("MV_#LFVCLI",,"027601")
			cCliLoj  := GetMV("MV_#LFVLOJ",,"00")
			cProdPV  := GetMV("MV_#LFVPRD",,"300042")
			
			SD2->( dbSetOrder(3) ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			If SD2->( dbSeek(cFilPV+StrZero(Val(cNroFiscal),TamSX3("D2_DOC")[1])+PadR(cSerNFFV,TamSX3("D2_SERIE")[1])+cCliCod+cCliLoj+cProdPV) )
				nTtPLP += SD2->D2_QUANT
				nTtPLO += ( (_nQtdPeso) + (_nQtdPeso*(_nContud/100)) )
				
				GrvArquivo( .T., "", "APANHA", _dDatEntr, ( (_nQtdPeso) + (_nQtdPeso*(_nContud/100)) ), cNroFiscal, "", SD2->D2_QUANT, "" )
				
			Else
				// NF nao encontradas para não gravar ZV1_FLAGPV
				cNFNot += AllTrim(cNroFiscal) + "|"
				
				GrvArquivo( .T., "", "APANHA", "", 0, "", "", 0, cNroFiscal )
				
			EndIf
			
		EndIf
		// FWNM - FIM
		
		
		
		xLin:=xLin+1
		DbSelectArea("ZV5")
		DbSkip()
	Enddo
Endif
DbSelectArea("ROC")
Return (xLin)





Static function ApanhaSint()
&&Chamado 005271. Quando relatorio sintetico nao inclui a linha do apanha no total do peso origem. Mauricio - HC Consys.
_nQtdave  := 0
_nQtdPeso := 0
DbSelectArea("ZV5")
DbSetOrder(1)

If DbSeek(xFilial("ZV5")+_cNUMOC ,.T.)
	//Do While !Eof() .AND. _cNUMOC=ZV5->ZV5_NUMOC 
	Do While !Eof() .AND. _cNUMOC=ZV5->ZV5_NUMOC .and. ZV5->ZV5_FILIAL == FWxFilial("ZV5") // @history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo	
		
		_cNumOc   := ZV5_NUMOC
		_cForcod  := ZV5_FORCOD
		_cForLoj  := ZV5_FORLOJ
		_nQtdave  := ZV5_QTDAVE
		nQtdApanha:= ZV5_QTDAVE
		_cGranj   := ZV5_RGRANJ
		_nQtdPeso := ZV5_PESOAP
		
		IF _lReduz == 2
			_nTotPesOri   += (_nQtdPeso)+ (_nQtdPeso*(_nContud/100)) //Chamado 005138.
		Else
			_nTotPesOri   += (_nQtdPeso*(_nContud/100))-(_nQtdPeso*(_nContud/100)) // ESTE ESTÁ QUASE
			//         _nTotPesOri   += (_nQtdPeso) - (nQtdApanha)*(_nContud/100) //Chamado 005138.  ORIGINAL
		Endif
		DbSelectArea("ZV5")
		DbSkip()
	Enddo
Endif
DbSelectArea("ROC")

Return

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
/*/
Static function ApnFV5 () //Monta em ZV5 Apanhas do Periodo

	NLIN:=80
	cQuery3:=" SELECT ZV5_NUMOC,ZV5_RGRANJ,ZV5_QTDAVE,ZV5_DTABAT,ZV5_PESOAP"
	cQuery3+=" FROM "+retsqlname("ZV5")+" (NOLOCK) "
	cQuery3+=" WHERE ZV5_FILIAL='"+FWxFilial("ZV5")+"' " // @history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
	cQuery3+=" AND (ZV5_DTABAT BETWEEN '"+ DTOS(_dDataIni) +"' AND  '"+ DTOS(_dDataFim) +"') "
	cQuery3+=" AND "+RetSqlName("ZV5")+ ".D_E_L_E_T_='' "
	TCQUERY cQuery3 new alias "TMP1"

	DbSelectArea("TMP1")
	Dbgotop()

	_TOTAP:=0 //TOTAL DA APANHA
	_TOTPS:=0

	WHILE !EOF()
		
		If nLin > 60 //.or. (_dDTBatF<>_dDtaBat) // Salto de Página. Neste caso o formulario tem 60 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
			nLin:=nLin+2
			CABEC7()
		ENDIF
		
		_dDatEntr:=  SUBSTR (TMP1->ZV5_DTABAT,7,2)+ "/" + SUBSTR (TMP1->ZV5_DTABAT,5,2) +"/"+ SUBSTR (TMP1->ZV5_DTABAT,1,4)
		
		@ NLIN,002 PSAY TMP1->ZV5_NUMOC
		@ NLIN,012 PSAY TMP1->ZV5_RGRANJ
		@ NLIN,022 PSAY TMP1->ZV5_QTDAVE
		@ NLIN,038 PSAY TMP1->ZV5_PESOAP
		@ NLIN,050 PSAY (TMP1->ZV5_PESOAP/TMP1->ZV5_QTDAVE) PICTURE "9999.999"
		@ NLIN,065 PSAY _dDatEntr
		NLIN++
		_TOTAP+=TMP1->ZV5_QTDAVE
		_TOTPS+=TMP1->ZV5_PESOAP
		DbSelectArea("TMP1")
		DBSKIP()
	ENDDO
	NLIN++          //123456789012345678901234567890123456789012345678901234567890123456789012345678901
	@ nlin,000	PSAY "+-----------------------------------------------------------------------------+"
	NLIN++
	@ nlin,000	PSAY "|TOTAL:   "+STR(_TOTAP)
	@ nlin,038  PSAY _TOTPS
	@ nlin,050  PSAY (_TOTPS/_TOTAP ) PICTURE "9999.999"
	@ nlin,078	PSAY "|"
	NLIN++
	@ nlin,000	PSAY "+-----------------------------------------------------------------------------+"
	NLIN++

	DBCLOSEAREA("TMP1")

Return







/*             RELATORIO DE APANHA
+-------------------------------------------------+
| NUM O.C. | GRANJA |  QUANTIDADE | DATA DE ABATE |
+-------------------------------------------------+
012345678901234567890123456789012345678901234567890
0         1         2         3         4         5
*/
Static Function cabec7()
NLIN++
@ nlin,000	PSAY "*                         RELATORIO DE APANHA                                 *"
NLIN++          //123456789012345678901234567890123456789012345678901234567890123456789012345678901
@ nlin,000	PSAY "+-----------------------------------------------------------------------------+"
NLIN++
@ nlin,000	PSAY "| NUM O.C. | GRANJA |  QUANTIDADE  |  PESO       |  PESO MEDIO |DATA DE ABATE |"
NLIN++
@ nlin,000	PSAY "+-----------------------------------------------------------------------------+"
NLIN++

return





Static function Apanha1()
// Verifica se tem Apanha para trazer o Peso do apanhe e separa-lo do Outro Peso.
DbSelectArea("ZV5")
DbSetOrder(1)
_nSomaPeso := 0
If DbSeek(xFilial("ZV5")+_cNUMOC ,.T.)
	//Do While !Eof() .AND. _cNUMOC=ZV5->ZV5_NUMOC 
	Do While !Eof() .AND. _cNUMOC=ZV5->ZV5_NUMOC .and. ZV5->ZV5_FILIAL == FWxFilial("ZV5") // @history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo	
		_nSomaPeso += ZV5->ZV5_PESOAP
		DbSelectArea("ZV5")
		Dbskip()
	enddo
endif
return(_nSomaPeso)




Static function Apanha2()
// Verifica se tem Apanha para trazer a quantidade do apanhe.
DbSelectArea("ZV5")
DbSetOrder(1)
_nSomaQtd := 0
If DbSeek(xFilial("ZV5")+_cNUMOC ,.T.)
	//Do While !Eof() .AND. _cNUMOC=ZV5->ZV5_NUMOC
	Do While !Eof() .AND. _cNUMOC=ZV5->ZV5_NUMOC .and. ZV5->ZV5_FILIAL == FWxFilial("ZV5") // @history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo	
		_nSomaQtd += ZV5->ZV5_QTDAVE
		DbSelectArea("ZV5")
		Dbskip()
	enddo
endif
return(_nSomaQtd)







/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AD0143    ºAutor  ³Microsiga           º Data ³  04/23/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß


GrvArquivo( .T., "", _cNumOC, _dDatEntr, _nMulPemRav, _nNUMNFS, "", SD2->D2_QUANT, "" )

*/

Static Function GrvArquivo( lReclock, cZV1_FLAGPV, cZV1_NUMOC, cZV1_DTABAT, nZV1_RPESOT, cZV1_NUMNFS, cZV1_SERIE, nD2_QUANT, cNF_NOT  )

Local aAreaAtu  := GetArea()

RecLock(cArquivo, lRecLock)

(cArquivo)->PEDIDO      := cZV1_FLAGPV
(cArquivo)->ORDEMCARGA  := cZV1_NUMOC
(cArquivo)->DATA_ABATE  := cZV1_DTABAT
(cArquivo)->PL_ORIGEM   := nZV1_RPESOT
(cArquivo)->NF          := cZV1_NUMNFS
(cArquivo)->SERIE       := cZV1_SERIE
(cArquivo)->QTD_NF      := nD2_QUANT
(cArquivo)->NF_NAOENCO  := cNF_NOT


(cArquivo)->( msUnLock() )

RestArea( aAreaAtu )

Return

//função retira zero a esquerda
//fernando sigoli 08/08/2018
User Function TiraZeros(cTexto)

	Local aArea     := GetArea()
	Local cRetorno  := ""
	Local lContinua := .T.
	Default cTexto  := ""

	U_ADINF009P('AD0143' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio que mostra NF por Recebimento Do Frango Vivo')

    //Pegando o texto atual
    cRetorno := Alltrim(cTexto)

    //Enquanto existir zeros a esquerda
    While lContinua
        //Se a priemira posição for diferente de 0 ou não existir mais texto de retorno, encerra o laço
        If SubStr(cRetorno, 1, 1) <> "0" .Or. Len(cRetorno) ==0
            lContinua := .f.
        EndIf

        //Se for continuar o processo, pega da próxima posição até o fim
        If lContinua
            cRetorno := Substr(cRetorno, 2, Len(cRetorno))
        EndIf
    EndDo

    RestArea(aArea)

Return cRetorno



//função para buscar o turno do abate, no Edata

Static Function BuscaTur(nOC)

Local cTurno := ""
Local cQury  := "" 
Local cLnkSrv		:= Alltrim(SuperGetMV("MV_#UEPSRV",,"LNKMIMS")) //Ticket 69574   - Abel Babini          - 25/04/2022 - Projeto FAI

If Select("QTRN") > 0
	DbSelectArea("QTRN")
	QTRN->(DbCloseArea())
Endif

cQury := " SELECT TOP 1 "
cQury += " 		ENT.ID_ENTRAVEVIVA AS GUIA, "
cQury += " 		ENT.ID_LOTECRIAEXTEENTRAVEVIVA  AS ORDEM,  "
cQury += " 		GN_PLACCAMIENTRAVEVIVA AS PLACA,  "
cQury += " 		CASE WHEN NR_SEQUTURNENTRAVEVIVA = 1 THEN '1ºT'  "
cQury += " 		WHEN NR_SEQUTURNENTRAVEVIVA = 2 THEN '2ºT'  "
cQury += " 		END TURNO  "	
cQury += " FROM  " 
cQury += " 		["+cLnkSrv+"].[SMART].[dbo].[ENTRADA_AVE_VIVA] ENT INNER JOIN ["+cLnkSrv+"].[SMART].[dbo].ENTRADA_AVE_VIVA_TURNO TURN  "
cQury += " 		ON ENT.ID_ENTRAVEVIVA = TURN.ID_ENTRAVEVIVA  " 
cQury += " WHERE 
cQury += "  ID_LOTECRIAEXTEENTRAVEVIVA = '" +nOC+ "'"

TCQUERY cQury new alias "QTRN"

DbSelectArea("QTRN")
Dbgotop()  

cTurno := QTRN->TURNO

DbcloseArea("QTRN")

Return cTurno
