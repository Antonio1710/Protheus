#INCLUDE "totvs.ch"
#INCLUDE "TOPCONN.CH"
#Include "Colors.ch"

/*/{Protheus.doc} User Function ADLFV018R()
  RELATORIO DIARIO DE ORDEM CARREGAMENTO FRANGO VIVO
  @type tkt -  13294
  @author Rodrigo Romão
  @since 20/05/2021
  @history Ticket 13294 - Leonardo P. Monteiro - 13/08/2021 - Melhoria para o projeto apontamento de paradas p/ o recebimento do frango vivo.
  @history Ticket 13294 - Leonardo P. Monteiro - 20/08/2021 - Correção na coluna de tempo de espera.
  @history Ticket 69945 - Fernando Macieira    - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
  @history Ticket 76225 - Everson              - 11/07/2022 - Tratamento para colunas que não estavam saindo no relatório.
/*/
User Function ADLFV018R()

	local cTitulo         := "RELAÇÃO DIARIA ORDEM CARREGAMENTO FRANGO VIVO"

	private cPerg         := "ADLFV018R"//"AD0143"
	private cConcilDe     := ""
	private cConcilAte		:= ""
	private dDataDe       := ctod("")
	private dDataAte      := ctod("")
	Private cAlias    		:= ""
	Private _nOrdem     	:= 2 //Ordem
	Private lAuto					:= .F.
	Private nLin					:= 0
	Private oFont10n 			:= TFont():New("Times New Roman",10,10,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont12n 			:= TFont():New("Times New Roman",12,12,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont14n 			:= TFont():New("Times New Roman",14,14,.T.,.F.,5,.T.,5,.T.,.F.)

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
	Private _cNumGta	:= ""	//Número da GTA
	Private _cNomMun	:= ""	//Nome do município.
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

	//dados perguntas
	Private _dDataini	:= ""	//GRAVA DATA INICIAL DE ABATE
	Private _dDataFim	:= ""	//GRAVA DATA FINAL DE ABATE
	Private _lReduz		:= ""	//GRAVA O TIPO DE REALTORIO
	Private _nUnitAt	:= "" //VALOR UNITARIO AGORA DA NF
	Private _LTarPadr	:= "" //Usa tara padrao? Sim ou Nao
	Private _LAjusPe  := "" //Pergunta se usa ou nao o ajuste do peso
	Private _lQAvCar  := "" //Pergunta se usa no calculo do peso medio Qtd aves carregadas ou Recebidas(Contador)
	Private _nTurno   := "" //Turno
	Private _nOrdem   := "" //Ordem
	Private _lSint		:= "" //Relatorio/Sintetico-Analítico
	Private _cGranjF	:= ""	//Filtra granja
	Private _cPlacF		:= ""	//Filtra Placa
	Private _cForc		:= ""	//Filtra por fonecedor

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),' RELATORIO DIARIO DE ORDEM CARREGAMENTO FRANGO VIVO')
	
	oFont10n:Bold := .f.
	oFont12n:Bold := .f.
	oFont14n:Bold := .f.

	DbSelectArea("ZV2")

	lPerguntas := Perguntas()

	if lPerguntas

		cAlias := GetNextAlias()

		oReport := TReport():New(cPerg,cTitulo,{|| Perguntas() },{|oReport| PrintReport(oReport) })
		oReport:SetTitle(cTitulo)

		oReport:SetLandScape(.T.)

		//Define as seções do relatório
		ReportDef(oReport)

		//Dialogo do TReport
		oReport:PrintDialog()
	endif
Return

/*/{Protheus.doc} ReportDef
  (long_description)
  @type  Static Function
  @author user
  @since 20/05/2021
  @version version
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
Static Function ReportDef(oReport)

	oSection2 := TRSection():New(oReport,"Dados Aves")
	TRCell():New(oSection2,"NUMOC"   	            ,cAlias,"N. DA OC"    	,"@!"               	,010,  ,,"LEFT",,"LEFT",,,,,,,) //01
	TRCell():New(oSection2,"GTA"   	            	,cAlias,"GTA"        	,"@!"               	,TamSX3("ZV1_NUMGTA")[1],  ,,"LEFT",,"LEFT",,,,,,,) //03 //Ticket 76225 - Everson              - 11/07/2022 - Tratamento para colunas que não estavam saindo no relatório.
	TRCell():New(oSection2,"GRNJ"   	            ,cAlias,"GRNJ"        	,"@!"               	,008,  ,,"LEFT",,"LEFT",,,,,,,) //02
	TRCell():New(oSection2,"MUNICIPIO"            	,cAlias,"MUNICÍPIO"    	,"@!"               	,TamSX3("ZV1_PCIDAD")[1],  ,,"LEFT",,"LEFT",,,,,,,) //04 //Ticket 76225 - Everson              - 11/07/2022 - Tratamento para colunas que não estavam saindo no relatório.
	TRCell():New(oSection2,"VEICULO"   	            ,cAlias,"VEICULO"     	,"@!"               	,010,  ,,"LEFT",,"LEFT",,,,,,,) //05
	TRCell():New(oSection2,"QTD_AVES_ORIGEM" 	    ,cAlias,"QTD ORIGEM"   	,"@E 99,999,999" 		,015,  ,,"RIGHT",,"RIGHT",,,,,,,) //06
	TRCell():New(oSection2,"QTD_AVES_RECEBIDA"      ,cAlias,"RECEBIDAV" 	,"@!"               	,015,  ,,"RIGHT",,"RIGHT",,,,,,,) //07
	TRCell():New(oSection2,"QTD_AVES_DIFERENCA"     ,cAlias,"DIFERENÇA" 	,"@!"               	,010,  ,,"RIGHT",,"RIGHT",,,,,,,) //08
	TRCell():New(oSection2,"PESO_LIQUIDO_ORIGEM"    ,cAlias,"PESO ORIGEM"	,"@E 9,999,999.99"		,020,  ,,"RIGHT",,"RIGHT",,,,,,,) //09
	TRCell():New(oSection2,"PESO_LIQUIDO_RECEBIDO"  ,cAlias,"RECEBIDO" 		,"@!"               	,010,  ,,"LEFT",,"LEFT",,,,,,,) //10
	TRCell():New(oSection2,"PESO_LIQUIDO_QUEBRA"    ,cAlias,"QUEBRA" 		,"@E 99999999"			,015,  ,,"RIGHT",,"RIGHT",,,,,,,) //11
	TRCell():New(oSection2,"TURNO"                  ,cAlias,"TURNO" 		,"@!"               	,005,  ,,"LEFT",,"LEFT",,,,,,,) //12
	TRCell():New(oSection2,"PESO_MEDIO"             ,cAlias,"PESO MEDIO"	,"@E 99,999.999"       	,020,  ,,"RIGHT",,"RIGHT",,,,,,,) //13
	TRCell():New(oSection2,"AVES_GAIOLA"            ,cAlias,"GAIOLA" 		,"@!"               	,005,  ,,"LEFT",,"LEFT",,,,,,,) //14
	TRCell():New(oSection2,"MORTALIDADE_QUANT"      ,cAlias,"MORTAL. TOTAL" ,"@!"               	,015,  ,,"RIGHT",,"RIGHT",,,,,,,) //15
	TRCell():New(oSection2,"MORTALIDADE_PESO"       ,cAlias,"PESO MORTALID"	,"@E 99,999.99"        	,010,  ,,"RIGHT",,"RIGHT",,,,,,,) //16
	TRCell():New(oSection2,"NUMERO_NF"              ,cAlias,"No NF" 		,"@!"               	,010,  ,,"LEFT",,"LEFT",,,,,,,) //17
	TRCell():New(oSection2,"TURMA"                  ,cAlias,"TURMA" 		,"@!"               	,005,  ,,"LEFT",,"LEFT",,,,,,,) //18
	TRCell():New(oSection2,"PEDXML"                 ,cAlias,"PedXml" 		,"@!"               	,005,  ,,"LEFT",,"LEFT",,,,,,,) //19
	TRCell():New(oSection2,"TEMPO_ESPERA"           ,cAlias,"ESPERA" 		,"@!"               	,005,  ,,"LEFT",,"LEFT",,,,,,,) //20
	TRCell():New(oSection2,"HORA_CHEGADA"           ,cAlias,"CHEGADA" 		,"@!"               	,005,  ,,"LEFT",,"LEFT",,,,,,,) //21
	TRCell():New(oSection2,"HORA_ABATE"             ,cAlias,"ABATE" 		,"@!"               	,005,  ,,"LEFT",,"LEFT",,,,,,,) //22
	TRCell():New(oSection2,"DATA_CHEGADA"           ,cAlias,"CHEGADA" 		,"@!"               	,015,  ,,"LEFT",,"LEFT",,,,,,,) //23
	TRCell():New(oSection2,"DATA_ABATE"             ,cAlias,"ABATE" 		,"@!"               	,015,  ,,"LEFT",,"LEFT",,,,,,,) //24
	TRCell():New(oSection2,"MORTALIDADE"            ,cAlias,"MORTAL PLATAFO","@R 99999"          	,015,  ,,"LEFT",,"LEFT",,,,,,,) //25
	TRCell():New(oSection2,"CAQUETICOS"             ,cAlias,"CAQUÉTICOS"	,"@R 99999"          	,015,  ,,"LEFT",,"LEFT",,,,,,,) //26

	oSection5 := TRSection():New(oReport,"Dados Apanha")
	TRCell():New(oSection5,"NUMOC"   	            ,cAlias,"N. DA OC"    	,"@!"               	,010,  ,,"LEFT",,"LEFT",,,,,,,) //01
	TRCell():New(oSection5,"GRNJ"   	            ,cAlias,"GRNJ"        	,"@!"               	,008,  ,,"LEFT",,"LEFT",,,,,,,) //02
	TRCell():New(oSection5,"VEICULO"   	            ,cAlias,"VEICULO"     	,"@!"               	,010,  ,,"LEFT",,"LEFT",,,,,,,) //02
	TRCell():New(oSection5,"QTD_AVES_ORIGEM" 	    ,cAlias,"ORIGEM"      	,"@E 99,999,999"	 	,030,  ,,"LEFT",,"LEFT",,,,,,,) //03
	TRCell():New(oSection5,"QTD_AVES_RECEBIDA"      ,cAlias,"RECEBIDAV" 	,"@!"               	,010,  ,,"LEFT",,"LEFT",,,,,,,) //04
	TRCell():New(oSection5,"QTD_AVES_DIFERENCA"     ,cAlias,"DIFERENÇA" 	,"@!"               	,010,  ,,"LEFT",,"LEFT",,,,,,,) //05
	TRCell():New(oSection5,"PESO_LIQUIDO_ORIGEM"    ,cAlias,"ORIGEM" 		,"@E 999,999,999.99"	,030,  ,,"LEFT",,"LEFT",,,,,,,) //06
	TRCell():New(oSection5,"PESO_LIQUIDO_RECEBIDO"  ,cAlias,"RECEBIDO" 		,"@!"               	,010,  ,,"LEFT",,"LEFT",,,,,,,) //07
	TRCell():New(oSection5,"PESO_LIQUIDO_QUEBRA"    ,cAlias,"QUEBRA" 		,"@E 9999"           	,015,  ,,"LEFT",,"LEFT",,,,,,,) //08
	TRCell():New(oSection5,"TURNO"                  ,cAlias,"TURNO" 		,"@!"               	,005,  ,,"LEFT",,"LEFT",,,,,,,) //09
	TRCell():New(oSection5,"PESO_MEDIO"             ,cAlias,"PESO MEDIO"	,"@E 99.999"        	,030,  ,,"LEFT",,"LEFT",,,,,,,) //10

	oBreak1 := TRBreak():New(oSection2,oSection2:Cell("DATA_ABATE"),"Total",.F.)
	oBreak2 := TRBreak():New(oSection2,{|| },"Total Geral",.F.)

	//totalização da oSection1
	// TRFunction():New(oSection2:Cell("QTD_AVES_ORIGEM"	),NIL,"SUM", oBreak1,NIL,NIL,NIL,.T.,.F.,.F.)
	TRFunction():New(oSection2:Cell("QTD_AVES_ORIGEM")			,NIL,"SUM"		,oBreak1,NIL	,"@E 999,999,999"		,NIL,.F.,.F.)
	TRFunction():New(oSection2:Cell("QTD_AVES_RECEBIDA")		,NIL,"SUM"		,oBreak1,NIL	,"@E 999,999,999.99"	,NIL,.F.,.F.)
	TRFunction():New(oSection2:Cell("QTD_AVES_DIFERENCA")		,NIL,"SUM"		,oBreak1,NIL	,"@E 999,999,999.99"	,NIL,.F.,.F.)
	TRFunction():New(oSection2:Cell("PESO_LIQUIDO_ORIGEM")		,NIL,"SUM"		,oBreak1,NIL	,"@E 999,999,999.99"	,NIL,.F.,.F.)
	TRFunction():New(oSection2:Cell("PESO_LIQUIDO_QUEBRA")		,NIL,"SUM"		,oBreak1,NIL	,"@E 9999999"				,NIL,.F.,.F.)
	TRFunction():New(oSection2:Cell("MORTALIDADE_QUANT")		,NIL,"SUM"		,oBreak1,NIL	,"@E 999,999,999.99"	,NIL,.F.,.F.)
	TRFunction():New(oSection2:Cell("MORTALIDADE_PESO")			,NIL,"SUM"		,oBreak1,NIL	,"@E 999,999,999.99"	,NIL,.F.,.F.)
	TRFunction():New(oSection2:Cell("PESO_MEDIO")				,NIL,"AVERAGE",oBreak1,NIL	,"@E 999.999"				,NIL,.F.,.F.)

	TRFunction():New(oSection2:Cell("QTD_AVES_ORIGEM")			,NIL,"SUM"		,oBreak2,NIL	,"@E 999,999,999.99"	,NIL,.F.,.F.)
	TRFunction():New(oSection2:Cell("QTD_AVES_RECEBIDA")		,NIL,"SUM"		,oBreak2,NIL	,"@E 999,999,999.99"	,NIL,.F.,.F.)
	TRFunction():New(oSection2:Cell("QTD_AVES_DIFERENCA")		,NIL,"SUM"		,oBreak2,NIL	,"@E 999,999,999.99"	,NIL,.F.,.F.)
	TRFunction():New(oSection2:Cell("PESO_LIQUIDO_ORIGEM")		,NIL,"SUM"		,oBreak2,NIL	,"@E 999,999,999.99"	,NIL,.F.,.F.)
	TRFunction():New(oSection2:Cell("PESO_LIQUIDO_QUEBRA")		,NIL,"SUM"		,oBreak2,NIL	,"@E 9999999"				,NIL,.F.,.F.)
	TRFunction():New(oSection2:Cell("MORTALIDADE_QUANT")		,NIL,"SUM"		,oBreak2,NIL	,"@E 999,999,999.99"	,NIL,.F.,.F.)
	TRFunction():New(oSection2:Cell("MORTALIDADE_PESO")			,NIL,"SUM"		,oBreak2,NIL	,"@E 999,999,999.99"	,NIL,.F.,.F.)
	TRFunction():New(oSection2:Cell("PESO_MEDIO")				,NIL,"AVERAGE",oBreak2,NIL	,"@E 999.999"				,NIL,.F.,.F.)

	//oSection:Cell("E1_PREFIXO"):SetAlign("CENTER")

Return

/*/{Protheus.doc} PrintReport
  (long_description)
  @type  Static Function
  @author user
  @since 20/05/2021
  @version version
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
Static Function PrintReport(oReport)
	local oSection2 := oReport:Section(1)
	local oSection5 := oReport:Section(2)

	local aDadosRel := {}
	local aItParada := {}
	local aItMortal := {}
	local nX        := 0
	local nP        := 0
	local nM        := 0

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

	_nContFor:= SuperGetmv("MV_FORITAD",.f.,"")
	_nContFor:=alltrim(_nContFor)

	//Procuro o parametro de para desconto do peso liquido
	//quanto tiver peso da balanca com opcao "M" molhado

	_nParQueb:= SuperGetmv("MV_PORQUEB",.f.,"")
	_nPrcQueb:= VAL(_nParQueb)

	aDadosRel := getDadosRel()

	nRegs := Len(aDadosRel)

	oReport:SetMeter(nRegs)
	oSection2:Init()
	nX := 1
	// While nX < Len(aDadosRel)
	For nX := 1 to Len(aDadosRel)

		// dData := aDadosRel[nX][23]

		If nX == 1
			oReport:SkipLine(1)
			oReport:Say(oReport:Row(),15,"PERIODO DE ABATE: ",oFont14n,,,)
			oReport:SkipLine(1)
			oReport:Say(oReport:Row(),15,DtoC(_dDataini) + " - " + dtoC(_dDataFim),oFont14n,,,)
			oReport:SkipLine(1)
			oReport:Say(oReport:Row(),15,"[ * ] - <<<Veiculo sem SEGUNDA PESAGEM>>>",oFont14n,,,)
			oReport:SkipLine(1)
			oReport:Say(oReport:Row(),15,"        <<<SEGUNDA PESAGEM ageta os calculo quando nao considerado a tara padrao>>>",oFont14n,,,)
			oReport:SkipLine(1)
		EndIf

		// oReport:Say(oReport:Row(),10,"|                |      |         |     QUANTIDADE DE AVES       |       P E S O   L I Q U I D O          |       |            |  AVES  |   MORTALIDADE |      |     |       |TEMPO DE|  HORA  | HORA   |   DATA    |  DATA         |",oFont10n,,,)
		// oReport:SkipLine(1)

		// oSection2:Init()

		// While dData == aDadosRel[nX][23]

			oReport:IncMeter()

			oSection2:Cell("NUMOC"   	           ):SetValue(aDadosRel[nX][02])
			oSection2:Cell("GRNJ"   	           ):SetValue(aDadosRel[nX][03])
			oSection2:Cell("VEICULO" 	           ):SetValue(aDadosRel[nX][04])
			oSection2:Cell("QTD_AVES_ORIGEM" 	   ):SetValue(aDadosRel[nX][05])
			oSection2:Cell("QTD_AVES_RECEBIDA"     ):SetValue(aDadosRel[nX][06])
			oSection2:Cell("QTD_AVES_DIFERENCA"    ):SetValue(aDadosRel[nX][07])
			oSection2:Cell("PESO_LIQUIDO_ORIGEM"   ):SetValue(aDadosRel[nX][08])
			oSection2:Cell("PESO_LIQUIDO_RECEBIDO" ):SetValue(aDadosRel[nX][09])
			oSection2:Cell("PESO_LIQUIDO_QUEBRA"   ):SetValue(aDadosRel[nX][10])
			oSection2:Cell("TURNO"                 ):SetValue(aDadosRel[nX][11])
			oSection2:Cell("PESO_MEDIO"            ):SetValue(aDadosRel[nX][12])
			oSection2:Cell("AVES_GAIOLA"           ):SetValue(aDadosRel[nX][13])
			oSection2:Cell("MORTALIDADE_QUANT"     ):SetValue(aDadosRel[nX][14])
			oSection2:Cell("MORTALIDADE_PESO"      ):SetValue(aDadosRel[nX][15])
			oSection2:Cell("NUMERO_NF"             ):SetValue(aDadosRel[nX][16])
			oSection2:Cell("TURMA"                 ):SetValue(aDadosRel[nX][17])
			oSection2:Cell("PEDXML"                ):SetValue(aDadosRel[nX][18])
			oSection2:Cell("TEMPO_ESPERA"          ):SetValue(aDadosRel[nX][19])
			oSection2:Cell("HORA_CHEGADA"          ):SetValue(aDadosRel[nX][20])
			oSection2:Cell("HORA_ABATE"            ):SetValue(aDadosRel[nX][21])
			oSection2:Cell("DATA_CHEGADA"          ):SetValue(aDadosRel[nX][22])
			oSection2:Cell("DATA_ABATE"            ):SetValue(aDadosRel[nX][23])
			oSection2:Cell("MORTALIDADE"           ):SetValue(aDadosRel[nX][24])
			oSection2:Cell("CAQUETICOS"            ):SetValue(aDadosRel[nX][25])
			oSection2:Cell("GTA"		           ):SetValue(aDadosRel[nX][27])
			oSection2:Cell("MUNICIPIO"	           ):SetValue(aDadosRel[nX][28])

			oSection2:PrintLine()

			cNumOrdCarregamento := aDadosRel[nX][02]
			apanha(cNumOrdCarregamento,oReport,oSection5)

			// IF nX < Len(aDadosRel)
			// 	nX++
			// else
			// 	exit
			// endif

		// end

		// oSection2:Finish()

	// End
	Next nX
	oSection2:Finish()

Return



/*/{Protheus.doc} queryRel
  (long_description)
  @type  Static Function
  @author user
  @since 20/05/2021
  @version version
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
Static Function getDadosRel()
	local cAlias  := ""
	local cQuery  := ""
	local aDados  := {}
	local aTemp   := {}

	cAlias := getNextAlias()

	cQuery:=" SELECT "
	cQuery+=" ZV1_NUMOC, ZV1_RGRANJ, ZV1_CAVES , ZV1_RAVES,ZV1_QTDQBR, ZV1_AVESGA, ZV1_TURNO, "
	cQuery+=" ZV1_PAVES, ZV1_PESOME, ZV1_MORTAL, ZV1_NUMNFS, ZV1_TURMA, ZV1_NUMGTA, ZV1_PCIDAD, "
	cQuery+=" ZV2_1PESO, ZV2_2PESO, ZV1_RPLACA , ZV1_PESONF,  "
	cQuery+=" ZV1_VALTNF,ZV1_VALUNF,ZV1_DTABAT , ZV1_DTAREA,  "
	cQuery+=" ZV1_LOJFOR, ZV1_CODFOR,ZV1_TARAPD,ZV1_AJUSPS, ZV1_SERIE , "
	cQuery+=" ZV1_PGRANJ, ZV1_FORREC,ZV1_LOJREC,ZV1_RHVP,ZV1_RHABAT , ZV2_DATA1 , ZV1_CLIVOL,ZV1_RHESPE,ZV1_CLIBAL, "
	cQuery+= "ZV1_MORTAL, ZV1_QTDCAQ "
	cQuery+=" FROM " + retsqlname("ZV1")+ " (NOLOCK), " + retsqlname("ZV2")+" (NOLOCK) "
	cQuery+=" WHERE ZV1_FILIAL='"+FWxFilial("ZV1")+"' AND ZV1_FILIAL=ZV2_FILIAL " // @history Ticket 69945 - Fernando Macieira    - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
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

	TCQUERY cQuery NEW ALIAS (cAlias)
	DbSelectArea(cAlias)

	TCSETFIELD(cAlias,"ZV1_DTABAT"	,"D",08,00)
	TCSETFIELD(cAlias,"ZV1_DTAREA"	,"D",08,00)
	TCSETFIELD(cAlias,"ZV2_DATA1"	,"D",08,00)
	

	If (cAlias)->(!Eof())

		_dDTBatF := (cAlias)->ZV1_DTABAT

		While (cAlias)->(!Eof()) .and. !EMPTY(_dDTBatF)

			//nLin := GETVARS(nLin)
			IF (_LTarPadr=2)
				_n2PESO	  := (cAlias)->ZV2_2PESO              //OBTEM O SEGUNDO PESO
			ELSE
				_n2PESO	  := (cAlias)->ZV1_TARAPD             //OBTEM TARA PADRAO
			ENDIF

			_nPesNF   := (cAlias)->ZV1_PESONF					//PESO NF

			//----------------------------------------------------------------------------------------------------------------
			// Alteracao efetuada por Celso Costa em 14/12/2007
			// A quebra nao deve ser considerada neste momento, pois ja esta embutida na primeira pesagem conforme informacoes
			// obtidas com Rosangela, Pamela e Admilson
			_n1PESO	  :=(cAlias)->ZV2_1PESO - (cAlias)->ZV1_QTDQBR   //PRIMEIRO PESO - QUEBRA DE BALANCA
			//_n1PESO	  :=(cAlias)->ZV2_1PESO
			//----------------------------------------------------------------------------------------------------------------

			_n2PesoOC :=(cAlias)->ZV2_2PESO               	//OBTEM O SEGUNDO PESO para OC marcar '*'
			//VERIFICO SE UTILIZO AVES DO CONTADOR OU CARREGADAS
			If (_lQAvCar=1)
				_nRAVES	  :=(cAlias)->ZV1_PAVES                  //OBTEM O NUMERO DE AVES REAIS CONTADOR
			Else
				_nRAVES	  :=(cAlias)->ZV1_RAVES                  //OBTEM O NUMERO DE AVES REAIS CONTADOR
			EndIf
			_nPAVES	  :=(cAlias)->ZV1_CAVES                  //OBTEM O NUMERO DE AVES carregadas
			_cNUMOC	  :=(cAlias)->ZV1_NUMOC 	                //OBTEM NUMERO DA OC

			//09/09/2016- coloca recurso para mostrar veiculo com a primeira pesagem molhado, aplicado descondo no peso liquido
			_cMarkS_M  := " " //zero a variavel

			If (cAlias)->ZV1_CLIBAL = 'M'
				_cMarkS_M :=(cAlias)->ZV1_CLIBAL
			EndIF

			_cRGRANJ  :=SUBSTR((cAlias)->ZV1_RGRANJ,1,5)     //OBTEM O INTEGRADO    // Chamado Silvana em 13/10/2014
			_cPPLACA  :=(cAlias)->ZV1_RPLACA                 //OBTEM A PLACA
			_nMORTAL  :=(cAlias)->ZV1_MORTAL+(cAlias)->ZV1_QTDCAQ                 //OBTEM A QUANTIDADE DA MORTALIDADE
			_nNUMNFS  :=(cAlias)->ZV1_NUMNFS                 //NUMERO DA NF
			_cNumGta  := (cAlias)->ZV1_NUMGTA                 //NÚMERO DA GTA.
			_cNomMun  := (cAlias)->ZV1_PCIDAD                 //NOME DO MUNICÍPIO.
			_nTURMA   :=(cAlias)->ZV1_TURMA
			_nVALUNF  :=(cAlias)->ZV1_VALUNF                 //VALOR UNITARIO DA NF
			_nLojFor  :=(cAlias)->ZV1_LOJFOR					//LOJA FORNECEDOR
			_nCodFor  :=(cAlias)->ZV1_CODFOR					//CODIGO FORNECEDOR
			_cPGRANJ  :=(cAlias)->ZV1_PGRANJ					//INTEGRADO
			_cForRec  :=(cAlias)->ZV1_FORREC				    //FORNECEDOR RECEBIDO
			_cLojRec  :=(cAlias)->ZV1_LOJREC                 //LOJA RECEBIDA
			_dRhVp    :=(cAlias)->ZV1_RHVP  					//HORA DE CHEGADA EM VP
			_dRhAbt   :=(cAlias)->ZV1_RHABAT                 //HORA DE INICIO DE ABATE
			_dDtaRea  :=(cAlias)->ZV1_DTAREA					//DATA DE ABATE EFETIVAMENTE REALIZADA
			_dDtaBat  :=(cAlias)->ZV1_DTABAT					//DATA DE ABATE
			_nAjusPs  :=(cAlias)->ZV1_AJUSPS                 //Peso Ajustado
			_hEntPort :=(cAlias)->ZV1_RHVP  					//HORA DE CHEGADA EM VP
			_hAbtPla  :=(cAlias)->ZV1_RHABAT                //HORA DE INICIO DE ABATE
			_dEntPort :=(cAlias)->ZV2_DATA1					//DATA DE ABATE em o veiculo chegou na portaria
			_dAbtPla  :=(cAlias)->ZV1_DTAREA					//DATA DE DESCAREGAR NA PLATAFORMA
			_cSerie	  :=(cAlias)->ZV1_SERIE					//SERIE DA NF
			_cCliVol  :=(cAlias)->ZV1_CLIVOL					//CLIMA NA VOLTA

			_nAvesGa  :=(cAlias)->ZV1_AVESGA					//Aves por gaiola //Chamado:049564 - Fernando Sigoli 09/07/2019
			_cTurAbt  := fGetTurno((cAlias)->ZV1_TURNO) //BuscaTur((cAlias)->ZV1_NUMOC)       //Turno de abate  //Chamado:049564 - Fernando Sigoli 09/07/2019



			&&Chamado 006667 - Mauricio - Busco numero do C5_PEDXML.
			SC5->(DbSetOrder(15))
			//DbSetOrder(15)
			if SC5->(Dbseek("03"+STRZERO(Val(Alltrim(_nNUMNFS)),9)+"01"))  &&Conforme informado toda NF vem sempre da filial 03(Frango vivo) e devera sempre p(cAlias)urar por serie 01.
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
			SD1->(DbSetOrder(1))
			// D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			//
			//
			//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
			//CORIGIR O SEEK ABAIXO --->+_CSERIE+' '
			//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
			//
			//
			If SD1->(DbSeek(xFilial("SD1")+_nNUMNFS+_cSerie+' '+_cForRec+_cLojRec,.T.))
				_nNfVunit :=D1_VUNIT				//VALOR UNITARIO DA NF
				_nNfTotal :=D1_TOTAL                //VALOR TOTAL DA NF
				_nPesoNf  :=D1_QUANT                //OBTEM O PESO DA NF
			Else
				_nNfVunit := 0         				//VALOR UNITARIO DA NF
				_nNfTotal := 0                      //VALOR TOTAL DA NF
				_nPesoNf  := 0                      //OBTEM O PESO DA NF
			Endif

			// dbCloseArea("SD1")
			// DbSelectArea("(cAlias)")//valotano para areal atual
			// dbSkip() // Avanca o ponteiro do registro no arquivo

			_dDTBatF := (cAlias)->ZV1_DTABAT//RECEBENDO PROXIMO REGISTRO
			DbSelectArea((cAlias))//valotano para areal atual


			//_dDatEntr :=  _dDTBatF

			nLin := PROCFUNCTIONS(nLin)	//Processando calculos

			// _nMulPemRav := TRANSFORM(_nMulPemRav, "@E 999,999,999.99")
			//_dDtEntPort := SUBSTR(_dEntPort,7,2) + "/" + SUBSTR(_dEntPort,5,2) + "/" + SUBSTR(_dEntPort,1,4)
			//_dDtEntRea  := SUBSTR(_dDtaRea,7,2)  + "/" + SUBSTR(_dDtaRea,5,2)  + "/" + SUBSTR(_dDtaRea,1,4)
			//_dDTBatF    := SUBSTR(_dDTBatF,7,2)  + "/" + SUBSTR(_dDTBatF,5,2)  + "/" + SUBSTR(_dDTBatF,1,4)

			/*
			aItMortal := getMortalidade(_cNUMOC)
			
			if Len(aItMortal) > 1
				nMortalidade := aItMortal[1][6]
				nCaqueticos  := aItMortal[2][6]
			else
				nMortalidade := 0
				nCaqueticos  := 0
			endif
			*/

			nMortalidade := (cAlias)->ZV1_MORTAL
			nCaqueticos  := (cAlias)->ZV1_QTDCAQ

			aTemp := {}
			aAdd(aTemp,_cMarkS_M)    		//01 - MARCA SECO / MOLHADO
			aAdd(aTemp,_cMarkX+_cNUMOC) //02 - NUMERO DA OC
			aAdd(aTemp,_cRGRANJ)        //03 - GRANJA/INTEGRADO     //013
			aAdd(aTemp,_cPPLACA)        //04 - VEICULO   020
			aAdd(aTemp,_nPAVES)         //05 - QTD AVES ORIGEM  030
			aAdd(aTemp,_nPAVES)        	//06 - QTD AVES RECEBIDAS 040
			aAdd(aTemp,0) 			        //07 - QTD AVES DIFERENCA	050
			aAdd(aTemp,_nMulPemRav)     //08 - _nMulPemRav PICTURE '99999999.99'	//PESO LIQUIDO ORIGEM  061 - FWNM - 25/04/2018 - CHAMADO 041287
			aAdd(aTemp,_nDif1Pe2Pe) 	  //09 - PESO LIQUIDO REAL    075
			aAdd(aTemp,_nQuebra) 	      //10 - QUEBRA (PESO)    090
			aAdd(aTemp,_cTurAbt)        //11 - TURNO ABATE   102   //Chamado:049564 - Fernando Sigoli 09/07/2019
			aAdd(aTemp,_nPESOME)        //12 - PESO MEDIO 111
			aAdd(aTemp,_nAvesGa)        //13 - aves por gaiola
			aAdd(aTemp,_nMORTAL) 				//14 - QTD MORTALIDADE 135
			aAdd(aTemp,_nMulMrtPe)      //15 - PESO AVES MORTALIDADE 147
			aAdd(aTemp,_nNUMNFS)        //16 - NUMERO DA NF 158
			aAdd(aTemp,_nTURMA)         //17 - Turma
			aAdd(aTemp,_cPEDXML)        //18 - Pedido XML
			aAdd(aTemp,_dView)					//19 - tempo de espera 168
			aAdd(aTemp,_dRHVP)					//20 - Hora de Chegada 179
			aAdd(aTemp,_dRHAbt)					//21 - Hora de Abate 188
			//aAdd(aTemp,_dDtEntPort)     //22 - DATA DA GUIA 197
			aAdd(aTemp,_dEntPort)     //22 - DATA DA GUIA 197
			// aAdd(aTemp,_dDtEntRea)      //23 - 208
			aAdd(aTemp,_dDTBatF) 	      //23 - 208
			aAdd(aTemp,nMortalidade)    //24 - 208
			aAdd(aTemp,nCaqueticos)     //25 - 208
			aAdd(aTemp,_dDTBatF)        //26 - 208
			aAdd(aTemp,_cNumGta)        //27 - 208
			aAdd(aTemp,_cNomMun)        //28 - 208

			aAdd(aDados, aTemp)

			_lQbrP := 0// ChkDate(nLin)       	//Verifica se houve quebra de data e imprime totais

			_nDif1Pe2Pe	:=0
			_nSMPesPorc	:=0
			_nMulPemRav	:=0
			_nQuebra	:=0

			(cAlias)->(DbSkip())

		end
	Endif

	(cAlias)->(DbCloseArea())

Return (aDados)

Static Function fGetTurno(nturno)
	Local cRet := ""

	if nturno == 1
		cRet := "1º Turno"
	Elseif nturno == 2
		cRet := "2º Turno"
	Elseif nturno == 3
		cRet := "3º Turno"
	endif


return cRet

/*/{Protheus.doc} PROCFUNCTIONS
  (long_description)
  @type  Static Function
  @author user
  @since 20/05/2021
  @version version
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
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
	HoraEsp()
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
		_nMulPemRav	  := _nPesNF                    	//peso liquido da origem
		_nQuebra		  := (_nMulPemRav - _nDif1Pe2Pe)	//QUEBRA
		_nSMPesPorc		:= (_nQuebra/_nPesNF)	*100		  //PORCENTAGEM DA QUEBRA GRANJA TERCEIRA=(quebra/peso origem+quebra/pesorecebido)/2
		_nContud			:= _nSMPesPorc							    //SETO A PORCENTAGEM QUE ACABEI DE CALCULAR
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


/*/{Protheus.doc} Apanha1
  (long_description)
  @type  Static Function
  @author user
  @since 20/05/2021
  @version version
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  Verifica se tem Apanha para trazer o Peso do apanhe e separa-lo do Outro Peso.
 /*/
Static function Apanha1()

	DbSelectArea("ZV5")
	DbSetOrder(1)
	_nSomaPeso := 0
	If DbSeek(xFilial("ZV5")+_cNUMOC ,.T.)
		//Do While !Eof() .AND. _cNUMOC=ZV5->ZV5_NUMOC 
		Do While !Eof() .AND. _cNUMOC=ZV5->ZV5_NUMOC .and. ZV5->ZV5_FILIAL==FWxFilial("ZV5") // @history Ticket 69945 - Fernando Macieira    - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
			_nSomaPeso += ZV5->ZV5_PESOAP
			DbSelectArea("ZV5")
			Dbskip()
		enddo
	endif

return(_nSomaPeso)

/*/{Protheus.doc} Apanha2
  (long_description)
  @type  Static Function
  @author user
  @since 20/05/2021
  @version version
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
Static Function Apanha2()
// Verifica se tem Apanha para trazer a quantidade do apanhe.
	DbSelectArea("ZV5")
	DbSetOrder(1)
	_nSomaQtd := 0
	If DbSeek(xFilial("ZV5")+_cNUMOC ,.T.)
		//Do While !Eof() .AND. _cNUMOC=ZV5->ZV5_NUMOC
		Do While !Eof() .AND. _cNUMOC=ZV5->ZV5_NUMOC .and. ZV5->ZV5_FILIAL==FWxFilial("ZV5") // @history Ticket 69945 - Fernando Macieira    - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
			_nSomaQtd += ZV5->ZV5_QTDAVE
			DbSelectArea("ZV5")
			Dbskip()
		enddo
	endif
return(_nSomaQtd)

/*/{Protheus.doc} HoraEsp
  (long_description)
  @type  Static Function
  @author user
  @since 20/05/2021
  @version version
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
Static function HoraEsp() //Funcao que verifica a Data e Hora de abate e calcula tempo de espera.
	Local nDayDif 	:= 0
	Local nMinutos	:= 0
	Local nSegTmp	:= 0
	Local nSegI		:= 0
	Local nSegF		:= 0
	Local nHora		:= 0
	Local nMinutos	:= 0
	Local nSegundos	:= 0

	//Verifico se as datas sao branco
	
	if !Empty(_dEntPort) .and. !Empty(_dDTBatF) .and.; 
		len(_dRHVP) == 5 .and. len(_dRHAbt) == 5 .and.;
		at(":",_dRHVP) == 3 .and. at(":",_dRHAbt) == 3
	
		nDayDif := DateDiffDay(_dEntPort,_dDTBatF)


		aHorI 	:= Separa(_dRHVP,":")
		nSegI	:= val(aHorI[01])*3600
		nSegI	+= val(aHorI[02])*60

		aHorF 	:= Separa(_dRHAbt,":")
		if _dEntPort == _dDTBatF .AND. aHorF[01] == "00" .AND. aHorI[01] > aHorF[01]
			nSegF	:= 24*3600
		else
			nSegF	:= val(aHorF[01])*3600
		endif
		nSegF	+= val(aHorF[02])*60
		
		//Soma os dias, hora inicial e hora final convertidos em minutos.
		if nDaydif > 0
			nSegTmp := ((nDaydif-1)*(3600))+((86400)-nSegI)+nSegF
		Else
			nSegTmp := (nDaydif*(3600))+nSegF-nSegI
		endif

		nHora 		:= INT(nSegTmp/3600)
		nSegTmp		:= nSegTmp-INT(nSegTmp/3600)*3600
		nMinutos	:= int(nSegTmp/60)
		nSegTmp		:= nSegTmp-INT(nSegTmp/60)*60
		nSegundos	:= nSegTmp

		_dView	:= StrZero(nHora,3)+":"+Strzero(nMinutos,2)

	ELSE
		_dView:= "--:--"
	endif
	/*
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
	*/
	/*
	_dHR  := INT(_dHresp/60)     //calculando a Inteira da hora
	_dMR  :=  _dHresp/60
	_dM1  := ( (_dHresp/60) - _dHR )*60  //calculando a parte fracionaria dos minutos
	_dM2  := str((_dM1+100),3)
	_dM3  := substr(_dM2,2,2)
	_dView:=alltrim(str(ABS(_dHR )))+":"+_dM3//Mostarndo a data no formato 99:99h
	
	// Faço somatoria para tirar a média aritmetica
	_nMedi_Hr := _nMedi_Hr + _dHresp
	_nCount_Hr := _nCount_Hr + 1
	*/



Return

/*/{Protheus.doc} getParadas
  (long_description)
  @type  Static Function
  @author user
  @since 20/05/2021
  @version version
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
Static Function getParadas(cNumOrdCarregamento)
	local aRet    := {}
	local aTemp   := {}
	local cQuery  := ""
	local cAlias  := getNextAlias()

	cQuery := "SELECT " + CRLF
	cQuery += " ZEI.ZEI_ITEM, " + CRLF
	cQuery += " ZEI.ZEI_NUMMP, " + CRLF
	cQuery += " ZEE.ZEE_DESCRI, " + CRLF
	cQuery += " ZEE.ZEE_DEPTO, " + CRLF
	cQuery += " ZEE.ZEE_DESDEP " + CRLF
	cQuery += " FROM " + RetSqlTab("ZEI") + " " + CRLF
	cQuery += "   INNER JOIN " + RetSqlTab("ZEE") + " " + CRLF
	cQuery += "     ON  ZEE.ZEE_CODIGO = ZEI.ZEI_NUMMP " + CRLF
	cQuery += "     AND ZEE.ZEE_FILIAL = '" + xFilial("ZEE") + "'" + CRLF
	cQuery += "     AND ZEE.D_E_L_E_T_ <> '*' " + CRLF
	cQuery += " WHERE ZEI.D_E_L_E_T_ <> '*' " + CRLF
	cQuery += " AND ZEI.ZEI_NUMOC = '" + cNumOrdCarregamento + "'"

	TCQUERY cQuery NEW ALIAS (cAlias)
	DbSelectArea(cAlias)

	While (cAlias)->(!Eof())

		aTemp := {}

		aAdd(aTemp, (cAlias)->ZEI_ITEM)
		aAdd(aTemp, (cAlias)->ZEI_NUMMP)
		aAdd(aTemp, (cAlias)->ZEE_DESCRI)
		aAdd(aTemp, (cAlias)->ZEE_DEPTO)
		aAdd(aTemp, (cAlias)->ZEE_DESDEP)
		aAdd(aRet, aTemp)

		(cAlias)->(DbSkip())
	End

	(cAlias)->(DbCloseArea())

Return aRet

/*/{Protheus.doc} Apanha
	(long_description)
	@type  Static Function
	@author user
	@since 27/05/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static function Apanha(cNumOrdCarregamento,oReport,oSection)

// Verifica se tem Apanha
	_nQtdave  := 0
	_nQtdPeso := 0

	ZV5->(DbSetOrder(1))
	If ZV5->(DbSeek(xFilial("ZV5")+cNumOrdCarregamento ,.T.))

		oSection:init()

		//Do While ZV5->(!Eof()) .AND. cNumOrdCarregamento == ZV5->ZV5_NUMOC
		Do While ZV5->(!Eof()) .AND. cNumOrdCarregamento == ZV5->ZV5_NUMOC .and. ZV5->ZV5_FILIAL==FWxFilial("ZV5") // @history Ticket 69945 - Fernando Macieira    - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo

			_cNumOc   	:= ZV5->ZV5_NUMOC
			_cForcod  	:= ZV5->ZV5_FORCOD
			_cForLoj  	:= ZV5->ZV5_FORLOJ
			_nQtdave  	:= ZV5->ZV5_QTDAVE
			nQtdApanha 	:= ZV5->ZV5_QTDAVE
			_cGranj   	:= ZV5->ZV5_RGRANJ
			_nQtdPeso 	:= ZV5->ZV5_PESOAP
			cNroFiscal  := u_TiraZeros(ZV5->ZV5_NUMNFS)	//ZV5_NUMNFS // Chamado 040118 - Fernando Sigoli
			cSerFiscal	:= ZV5->ZV5_SERIE  							// Chamado 040118 - Fernando Sigoli

			oSection:Cell("NUMOC"   	              ):SetValue("[APANHA]")
			oSection:Cell("GRNJ"   	              	):SetValue(_cGranj)
			oSection:Cell("VEICULO"   	            ):SetValue("")
			oSection:Cell("QTD_AVES_ORIGEM" 	      ):SetValue(Int(_nQtdave))
			oSection:Cell("QTD_AVES_RECEBIDA"      	):SetValue(_nQtdave)
			oSection:Cell("QTD_AVES_DIFERENCA"     	):SetValue(0)
			oSection:Cell("PESO_LIQUIDO_ORIGEM"    	):SetValue(ROUND((_nQtdPeso)+ (_nQtdPeso*(_nContud/100)),0))
			oSection:Cell("PESO_LIQUIDO_RECEBIDO"  	):SetValue(_nQtdPeso)
			oSection:Cell("PESO_LIQUIDO_QUEBRA"    	):SetValue(ROUND((_nQtdPeso*(_nContud/100)),0) )
			oSection:Cell("TURNO"                  	):SetValue("")
			oSection:Cell("PESO_MEDIO"             	):SetValue((_nQtdPeso/_nQtdave))
			oSection:PrintLine()

			ZV5->(DbSkip())
		Enddo

		oSection:Finish()
		oReport:SkipLine()

	Endif

Return

/*/{Protheus.doc} Perguntas
	(long_description)
	@type  Static Function
	@author user
	@since 27/05/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function Perguntas()
	local lPergunta     := .F.
	local aParBox		    := {}
	local dData         := ctod("")
	local nNumber				:= 0
	local aSN1 			    := {"S=Sim","N=Nao"}
	local aSN2 			    := {"1=Sim","2=Nao"}
	local aSNMedio	    := {"1=AVES CARREGADERAS","2=AVES CONTADOR"}
	local aSNSINT	   	 	:= {"1=Sintetico","2=Analitico"}

	aAdd(aParBox, {1, "Datat Inicial "			, dData				, ""					, "", ""		,    "", 100, .F.})		// MV_PAR01
	aAdd(aParBox, {1, "Data Final"					, dData				, ""					, "", ""		,    "", 100, .F.}) 		// MV_PAR02
	aAdd(aParBox, {1, "Valor Unit. "				, nNumber 		, "@E 9.99999", "", ""		,    "", 100, .F.}) 		// MV_PAR03
	AADD(aParBox, {2, "Usa Tara Padrao"    	,"S",aSN2			,100,"",.F.})							   										// MV_PAR04
	AADD(aParBox, {2, "Usa Peso de Ajuste"  ,"S",aSN2			,100,"",.F.})							   										// MV_PAR05
	AADD(aParBox, {2, "Calculo Peso Médio"  ,"S",aSNMedio	,100,"",.F.})							   										// MV_PAR06
	aAdd(aParBox, {1, "Turno"								, nNumber 		, ""				, "", ""		,    "", 100, .F.}) 			// MV_PAR07
	AADD(aParBox, {2, "Sintetico/Analitico"  ,"S",aSNSINT	,100,"",.F.})							   										// MV_PAR08
	aAdd(aParBox, {1, "Filtra por granja"		, SPACE(4)	  , ""				, "", ""		,    "", 100, .F.}) 			// MV_PAR09
	aAdd(aParBox, {1, "Filtra por placa"		, SPACE(7)	  , ""				, "", ""		,    "", 100, .F.}) 			// MV_PAR10
	aAdd(aParBox, {1, "Filtra por Fornece"	, SPACE(6)	  , ""				, "", ""		,    "", 100, .F.}) 			// MV_PAR11

	lPergunta := ParamBox(aParBox,cPerg,,,,,,,,cPerg,.T.,.T.)

	if lPergunta
		_dDataini	:= mv_par01	//GRAVA DATA INICIAL DE ABATE2
		_dDataFim	:= mv_par02	//GRAVA DATA FINAL DE ABATE
		_lReduz		:= 3				//GRAVA O TIPO DE REALTORIO
		_nUnitAt	:= mv_par03 //VALOR UNITARIO AGORA DA NF

		if valtype(mv_par04) == "C"
			_LTarPadr	:= val(mv_par04) 	//Usa tara padrao? Sim ou Nao
		else
			_LTarPadr	:= mv_par04 			//Usa tara padrao? Sim ou Nao
		endif

		if valtype(mv_par05) == "C"
			_LAjusPe  := val(mv_par05) 	//Pergunta se usa ou nao o ajuste do peso
		else
			_LAjusPe  := mv_par05 			//Pergunta se usa ou nao o ajuste do peso
		endif

		if valtype(mv_par06) == "C"
			_lQAvCar  := val(mv_par06) 	//Pergunta se usa no calculo do peso medio Qtd aves carregadas ou Recebidas(Contador)
		else
			_lQAvCar  := mv_par06 			//Pergunta se usa no calculo do peso medio Qtd aves carregadas ou Recebidas(Contador)
		endif

		_nTurno   := mv_par07 //Turno
		_nOrdem   := 2 				//Ordem

		if valtype(mv_par08) == "C"
			_lSint		:= val(mv_par08) 	//Relatorio/Sintetico-Analítico
		else
			_lSint		:= mv_par08 			//Relatorio/Sintetico-Analítico
		endif

		_cGranjF	:= mv_par09	//Filtra granja
		_cPlacF		:= mv_par10	//Filtra Placa
		_cForc		:= mv_par11	//Filtra por fonecedor
	endif

Return lPergunta
