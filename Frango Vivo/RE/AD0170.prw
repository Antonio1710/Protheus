#INCLUDE "rwmake.ch"
#include "Topconn.ch"

/*/{Protheus.doc} User Function AD0170
	Relatoriode frete do Frango Vivo
	@type  Function
	@author DANIEL
	@since 26/09/2005
	@version 01
	@history Chamado T.I    - DANIEL P. S.  - 06/03/2006 - CORRECAO DA QUERY; RETIRADO A BUSCA DE ZV4_NOMFOR POR PESQUISA DIRETA EM ZV4
	@history Chamado T.I    - DANIEL P. S.  - 06/03/2006 - INCLUIDO PARAMETRO DE PLACA A SER ANALIZADA
	@history Chamado T.I    - DANIEL P. S.  - 20/06/2006 - CORRIGIDO CALCULO DA PORCENTAGEM
	@history Chamado T.I    - LUCIANO MAFRA - 23/01/2014 - INCLUIDO TOTALIZADOR GERAL PESO LIQUIDO
	@history Chamado 019051 - LUCIANO MAFRA - 26/03/2014 - ORDEM DE IMPRESSÃO
	@history Chamado 056283 - William Costa - 03/03/2020 - Ajustado o tamanho do campo de KM de Saida de 7 para 8, pois os ODOMETROS dos KM começaram a ficar muito alto.
	@history ticket 69945   - Fern Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
	@history ticket 69945   - Fern Macieira - 22/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo - Z1_FILIAL onde o correto é ZV1_FILIAL
/*/
User Function AD0170

	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2        := "de acordo com os parametros informados pelo usuario."
	Local cDesc3        := "DIARIO FRANGO VIVO"
	Local cPict         := ""
	Local titulo       	:= "DIARIO FRANGO VIVO"
	Local nLin         	:= 80
	Local Cabec1       	:= "FRETE FRANGO VIVO"
	Local Cabec2       	:= ""
	Local imprime      	:= .T.
	Local aOrd := {}  
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 220
	Private tamanho     := "G"
	Private nomeprog    := "AD0170" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "AD0170" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString 		:= ""
	Private _cPLACA		:=space(7)  //PLACA
	Private _cNOMFOR	:=space(30) //NOME DO FORNECEDOR
	Private _cMOTORI	:=space(20) //MOTORISTA
	Private _cRGRANJ	:=space(20) //GRANJA/INTEGRADO
	Private _nPESOl		:=0         //PRIMEIRA PESAGEM
	Private _nKMSAI		:=0         //KM DE SAIDA
	Private _nKMENT		:=0         //KM DE ENTRADA
	Private _cTPFRETE	:=space(2)	//TIPO DE FRETE
	Private _dDatEntr	:=''		//DATA DE ABATE
	Private _nRange		:=0			//Range de KM, KM Rodado
	Private _nAZ3KMINI	:=0		 	//KM INICIAL
	Private _nAZ3KMFIM	:=0 		//KM FINAL
	Private _nAZ3FRTTON	:=0  		//TARIFA POR RANGE DE KM
	Private _nDistAbt	:=0			//Distancia do abatedouro
	Private _nValFrt	:=0			//Valor do Frete
	Private _cNoTrans	:=space(30) //nome da transportadora
	Private _cPrxInt				//futuro da granja
	Private	_cRetorno				//Tipo de viagem
	Private	_nPOS                   //posicao do cursor
	Private _lPvez		:=1			//PRIMEIRA VEZ
	Private Cabec4		:="DATA DE ABATE: "
	Private _dDtaIni	:=DDATABASE //data inical de abate
	Private _dDtaFim	:=DDATABASE //data final de abate
	Private _lAnKM					//analiza se usa ou nao km com frete com base em szk
	Private	_dDTBatF 				//Data futura
	Private _dDtaBat 				//Data de abate - para quebra de pagina
	Private _cPLACAF				//Placa futura
	Private _nAjusPS				//ajuste de Peso
	Private _n1peso					//primeiro peso
	Private _n2Peso					//segundo peso
	Private _cRetPrx	:="N"		//Proximo retorno
	Private _nCoutRec	:=0  		//Conta o numero de registros
	Private _DtaF					//Data Futura da impressao
	Private _nPercent	:=0         //Percentual de Aves Perdidas
	Private _cMark					//Marca de Terceiros
	Private _cApanh					//Marca se existe apanha
	Private _nDays					//Conta os Dias
	Private _hTime					//ve a hora de abate
	Private _cCodFor				//codigo do fornecedor
	Private _lojfor					//Loja do fornecedor
	Private _nGuia					//Guia
	Private _nTaraPD				//Tara Padrao
	Private _nMortal				//Mortalidade
	Private _nAves					//Aves
	Private _cOrdem					//Ordem
	Private _cCidade				//Cidade
	Private _cMarkS_M				//Marca de seco ou molhado
	Private _nVlrPerc		:=0     //Valor da Porcentagem de Clima
	Private _cCliVol                //Clima na volta  
	private TQREC	:=0 //TOTAL DE VIAGENS
	PRIVATE TPESOL	:=0 //TOTAL PESO L
	PRIVATE TKMS	:=0	//TOTAL KM SAI
	PRIVATE TKMR	:=0	//TOTAL KM ENT
	PRIVATE TKMT	:=0	//TOTAL KM TOTAL
	PRIVATE TKMTB	:=0	//TOTAL KM TABELA
	PRIVATE TVFRT	:=0	//TOTAL VALOR FRETE
	PRIVATE TAVR    :=0	//TOTAL DE aVES RECEBIDAS
	PRIVATE TAVM    :=0	//Total de Aves Mortas
	PRIVATE TPORC   :=0 //TOTAL DO PERCENTUAL
	Private TGQREC	:=0 //TOTAL DE VIAGENS
	Private TGPESOL	:=0 //TOTAL PESO L
	Private TGKMS	:=0 //TOTAL KM SAI
	Private TGKMR	:=0	//TOTAL KM ENT
	Private TGKMT	:=0	//TOTAL KM TOTAL
	Private TGKMTB	:=0	//TOTAL KM TABELA
	Private TGVFRT	:=0	//TOTAL VALOR FRETE
	Private TGAVR 	:=0 //total aves contador
	private TGAVM	:=0 //total aves mortalidade
	private TGPORC	:=0 //total de aves perdeidas em %                              
	PRIVATE TGPESOLM:=0 // total geral peso líquido Mafra

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatoriode frete do Frango Vivo')

	//nome da empresa
	NOMEEMP:=''
	DBSELECTAREA("SM0")
	NOMEEMP:=M0_NOMECOM    
	titulo:=ALLTRIM(NOMEEMP)+" - "+titulo

	/*VARIAVES DO VETOR DE CONSULTA*/
	Private dZV := {} //resultado da consulta

	//PERGUNTAS

	cPerg:="AD0170"
	IF pergunte(cPerg,.T.)=.F.
		RETURN
	ENDIF	

	_dDtaIni:=MV_PAR01 //data inicial de abate
	_dDtaFim:=MV_PAR02 //data final de abate
	_lAnKM  :=MV_PAR03 //Pergunta se analisa KM apenas
	_lTaraPd:=MV_PAR04 //PERGUNTA SE UTILIZA TARA PADRAO
	_lAjusPL:=MV_PAR05 //Pergunta se ajusta peso liquido
	_lDiskF :=MV_PAR06 //PERGUNTA SE GERA ARQUIVO EM DISCO
	_lsint  :=MV_PAR07 //PERGUNTA SE UTILIZA RELATORIO SINTETICO/ANALITICO
	_cPlac  :=MV_PAR08 //PLACA A SER ANALIZADA
	/* CHAMADO 019051*/
	_nOrdem :=MV_PAR09 //Ordem de Impressão

	IF _lDiskF=1
		_Path :=Getmv("MV_DISKIOS") //PARAMETRO COM O PATH DE GRAVACAO DO ARQUIVO
		_Path :=alltrim(_Path)
		_Ext  :=Getmv("MV_FILEEXT") //PARAMETRO COM A EXTENSAO DO ARQUIVO
		_Ext  :=alltrim(_Ext)
	endif

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


	//Monta a interface padrao com o usuario

	wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	// Processamento. RPTSTATUS monta janela com a regua de processamento. 

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

	FRT->(DbCloseArea())

Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem

	//CRIANDO MATRIZ DE TRABALHO
	AADD(DZV,{'TERCEIR'	 ,"C",01})
	AADD(DZV,{'DATAAB'	 ,"C",08})
	AADD(DZV,{'PLACA'	 ,"C",07})
	AADD(DZV,{'ORDEM'	 ,"C",06})
	AADD(DZV,{'FORNECE'	 ,"C",40})
	AADD(DZV,{'CIDADE'	 ,"C",40})
	AADD(DZV,{'TRANSPOR' ,"C",30})
	AADD(DZV,{'INTEGRA'	 ,"C",06})
	AADD(DZV,{'RETORNO'	 ,"C",01})
	AADD(DZV,{'APANHA'	 ,"C",01})
	AADD(DZV,{'PESOL'	 ,"N",13})
	AADD(DZV,{'KMSAI'	 ,"N",08})			//alterado por Adriana em 18/08/16 - chamado 030187
	AADD(DZV,{'KMENT'	 ,"N",08})		 	//alterado por Adriana em 18/08/16 - chamado 030187
	AADD(DZV,{'RANGE'	 ,"N",08})			//alterado por Sigoli em      22/12/16 - chamado 032044	
	AADD(DZV,{'DISTABT'	 ,"N",06})
	AADD(DZV,{'VFRETE'	 ,"N",08,02})
	AADD(DZV,{'AVCARR'	 ,"N",13})
	AADD(DZV,{'MORTAL'	 ,"N",13})
	AADD(DZV,{'PERDA'	 ,"N",10,02})
	AADD(DZV,{'HORAAB'	 ,"C",05})
	AADD(DZV,{'CLIMAV'	 ,"C",01})

	//CRIANDO ARQUIVO DE TRABALHO
	cArqTmp :=CriaTrab(DZV)

	//SELECIONANDO AREA
	DbUseArea(.T.,,cArqTmp,"cArqT",.F.,.F.)
	///cIndex:="_dDtaBat+_cRGRANJ+_cPLACA"
	//cIndex:="DATAAB+INTEGRA+PLACA"

	DO CASE 
	CASE _nOrdem=1	//Ordena por Ordem de Carregamento      
			cIndex:="DATAAB+ORDEM"  		
	CASE _nOrdem=2	//Data De Abate    
			cIndex:="DATAAB"
	CASE _nOrdem=3  //Placa           
			cIndex:="DATAAB+PLACA"
	CASE _nOrdem=4	//Granja          
			cIndex:="DATAAB+INTEGRA"
	OTHERWISE
			cIndex:="DATAAB+ORDEM+INTEGRA+PLACA"		
	ENDCASE	

	// SETREGUA -> Indica quantos registros serao processados para a regua 

	indRegua("cArqT",cArqTmp,cIndex,,,"Criando Indices...")

	DBSELECTAREA("cArqT")
	DBSETORDER(1)

	CQuery:=" SELECT ZV1_NUMOC, ZV1_FORREC, ZV1_LOJREC,"
	CQuery+=" ZV1_DTABAT,ZV1_RPLACA,ZV2_GUIA,ZV1_QTDQBR , "
	CQuery+=" ZV1_CODFOR, ZV1_LOJFOR, ZV1_RGRANJ, "
	CQuery+=" ZV2_KMSAI, ZV1_RHABAT, ZV1_CLIVOL, "
	CQuery+=" ZV2_KMENT, ZV2_1PESO, "
	CQuery+=" ZV2_2PESO, ZV1_TARAPD, "
	CQuery+=" ZV1_AJUSPS, ZV1_QTDAPN ,ZV1_KMODM, "
	CQuery+=" ZV1_PCIDAD, ZV1_CAVES, ZV1_MORTAL, ZV1_QTDAPN "
	CQuery+=" FROM " + retsqlname("ZV1")+ " (NOLOCK), " + retsqlname("ZV2")+" (NOLOCK) "
	CQuery+=" WHERE ZV1_FILIAL='"+FWxFilial("ZV1")+"' AND ZV1_FILIAL=ZV2_FILIAL " // @history ticket 69945   - Fern Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo // @history ticket 69945   - Fern Macieira - 22/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo - Z1_FILIAL onde o correto é ZV1_FILIAL
	CQuery+=" AND (ZV2_GUIA = ZV1_GUIAPE) AND (ZV1_DTABAT >= '"+ DTOS(_dDtaIni) +"' AND ZV1_DTABAT <= '"+ DTOS(_dDtaFim) +"') " 
	CQuery+=" AND ZV1_GUIAPE<>'      ' "
	CQuery+=" AND ZV1_NUMNFS<>'      ' "    
	cQuery+=" AND ZV2_TIPOPE='F'"          
	If _cPlac<>'       '
		CQuery+=" AND ZV1_RPLACA='"+_cPlac+"' "
	EndIf
	CQuery+=" AND "+retsqlname("ZV1")+".D_E_L_E_T_ ='' "
	CQuery+=" AND "+retsqlname("ZV2")+".D_E_L_E_T_ ='' "         

	CQuery+=" ORDER BY ZV1_NUMOC" 

	TCQUERY cQuery new alias "FRT"

	DbSelectArea("FRT")
	Dbgotop()

	//Primeira vez
	//Adquiro os campos futuros
	_cPrxInt := FRT->ZV1_RGRANJ
	_dDTBatF := FRT->ZV1_DTABAT
	_cPLACAF := FRT->ZV1_RPLACA
	_dDtaBat := FRT->ZV1_DTABAT

	While !EOF()

		GetData()    //Adquire Dados

		ProcTrApFt() //Processa Terceiros ; Apanha ; Frete

		Retorno ()   //Processa Retorno
		
		ProcCalc ()  //Processa Calculos
		
		DBSELECTAREA("cArqT")
		RecLock("cArqT",.T.)

			cArqT->TERCEIR  := _cMark
			cArqT->DATAAB   := _dDtaBat
			cArqT->PLACA    := _cPlaca
			cArqT->ORDEM    := _cOrdem
			cArqT->FORNECE  := _cNOMFOR
			cArqT->CIDADE   := _cCidade
			cArqT->TRANSPOR := _cNoTrans
			cArqT->INTEGRA  := _cRGRANJ
			cArqT->RETORNO  := _cRetorno
			cArqT->APANHA   := _cApanh
			cArqT->PESOL    := _nPesoL
			cArqT->KMSAI    := _nKmSai
			cArqT->KMENT    := _nKMENT
			cArqT->RANGE    := _nRange
			cArqT->DISTABT  := _nDistABT
			cArqT->VFRETE   := _nValFrt
			cArqT->AVCARR   := _nAves
			cArqT->MORTAL   := _nMortal
			cArqT->PERDA    := _nPercent
			cArqT->CLIMAV   := _cMarkS_M

		MSUNLOCK()
			
		//RETORNADO A AREA ANTERIOR
		DBSELECTAREA ("FRT")

		dbSkip()
		
		//DADOS FUTUROS
		_cPrxInt:=FRT->ZV1_RGRANJ //Granja
		_dDTBatF:=FRT->ZV1_DTABAT //Data
		_cPLACAF:=FRT->ZV1_RPLACA //Placa
		_dDtaBat:=FRT->ZV1_DTABAT //DATA DE ABATE

		// Verifica o cancelamento pelo usuario...
		
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

	EndDo

	//IMPRIMINDO RELATORIO 

	dbSelectArea("cArqT")
	dbgotop()  //descomentei esta linha em 16/06, e o relatorio voltou a funcionar com os logs habilitados - HC

	//Primeiro Registro
	_DtaF := cArqT->DATAAB

	while !Eof()
		
		//Data Passada
		_DtaF := cArqT->DATAAB
		
		//Impressao do cabecalho do relatorio. . .                            
		
		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			if _lsint<>1
					CABEC2:= "|   DATA   |                  |          VIAGEM                                                                   | PESO L. |                    | KM TOT. | TOT. GRAN. | TOTAL R$ | AVES CARR. | MORTAL | % PERD. |"
			else
				IF (_lAnKM=1)
					CABEC2:= "|   DATA   |  PLACA  | ORDEM  |      FORNECEDOR               |         TRANSPORTADORA         | DESTINO | R/N  AP  M| PESO L. | KM SAIDA | KM RET. | KM TOT. | TOT. GRAN. | TOTAL R$ | AVES CARR. | MORTAL | % PERD. |"
				ELSE
					
					CABEC2:= "|   DATA   |  PLACA  | ORDEM  |         CIDADE                |         TRANSPORTADORA         | DESTINO | R/N  AP  M| PESO L. | KM SAIDA | KM RET. | KM TOT. | TOT. GRAN. | TOTAL R$ | AVES CARR. | MORTAL | % PERD. |"
				ENDIF
			EndIf
			
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
			nLin:= CABEC5(nLin)
			nLin:=nLin +1
			@ nLin,000 PSAY REPLICATE ("-",220)
			nLin:=nLin +1
			
		Endif
		
		_dDatEntr:=  SUBSTR (cArqT->DATAAB,7,2)+ "/" + SUBSTR (cArqT->DATAAB,5,2) +"/"+ SUBSTR (cArqT->DATAAB,1,4)
		
		if _lsint==1

			@ nlin,000 PSAY cArqT->TERCEIR
			@ nlin,002 PSAY _dDatEntr
			@ nlin,014 PSAY cArqT->PLACA
			@ nlin,023 PSAY cArqT->ORDEM
			IF (_lAnKM=1)
				@ nlin,031 PSAY substr(cArqT->FORNECE,1,30)
			ELSE
				@ nlin,031 PSAY substr(cArqT->CIDADE,1,30)
			ENDIF
			@ nlin,064 PSAY cArqT->TRANSPOR
			@ nlin,097 PSAY cArqT->INTEGRA
			@ nlin,107 PSAY cArqT->RETORNO
			@ nlin,112 PSAY cArqT->APANHA
			@ nlin,115 PSAY cArqT->CLIMAV
			@ nlin,118 PSAY cArqT->PESOL PICTURE '@E 999999'
			@ nlin,128 PSAY cArqT->KMSAI
			@ nlin,139 PSAY cArqT->KMENT
			@ nlin,149 PSAY cArqT->RANGE
			@ nlin,158 PSAY cArqT->DISTABT
			@ nlin,171 PSAY cArqT->VFRETE		
			@ nlin,182 PSAY cArqT->AVCARR
			@ nlin,196 PSAY cArqT->MORTAL
			@ nlin,203 PSAY cArqT->PERDA PICTURE '@E 999.99'
			nlin++

		ENDIF
		
		//TOTALIZANDO
		
		TQREC++								   	//TOTAL DE VIAGENS
		TPESOL += cArqT->PESOL                  //TOTAL PESO L
		TKMS   += cArqT->KMSAI					//TOTAL KM SAI
		TKMR   += cArqT->KMENT					//TOTAL KM ENT
		TKMT   += cArqT->RANGE					//TOTAL KM TOTAL
		TKMTB  += cArqT->DISTABT				//TOTAL KM TABELA
		TVFRT  += cArqT->VFRETE					//TOTAL VALOR FRETE
		TAVR   += cArqT->AVCARR					//TOTAL DE aVES RECEBIDAS
		TAVM   += cArqT->MORTAL                 //Total de Aves Mortas
		TPORC  += cArqT->PERDA                  //TOTAL PORCENTAGEM DAS PERDAS
		dbSelectArea("cArqT")
		dbskip()
		
		//Quebrando por data o total
		if (_DtaF<>cArqT->DATAAB)
			//Vereficando se sabado
				
			IF _lsint == 1  //ANALITICO
				nlin++
				@ nLin,000 PSAY REPLICATE("-",220)
				nLin++
				@ nLin,000 PSAY "<<<TOTAIS>>>"
			ENDIF
			if _lsint == 1        //Se for sitetico não imprimo a palavra viagens
				@ nlin,020 PSAY "Viagens : " +str(TQREC)
			else
				@ nlin,002 PSAY _dDatEntr
				@ nlin,020 PSAY str(TQREC)
			EndIf
			@ nlin,116 PSAY ROUND(TPESOL,0)
			@ nlin,147 PSAY TKMT
			@ nlin,156 PSAY TKMTB
			@ nlin,170 PSAY TVFRT
			@ nlin,180 PSAY TAVR
			@ nlin,194 PSAY TAVM
			//@ nlin,201 PSAY TPORC/TQREC PICTURE '@E 999.99'
			@ nlin,201 PSAY (TAVM/TAVR)*100 PICTURE '@E 999.99'
			IF _lsint == 1  //ANALITICO
				nlin++
				@ nLin,000 PSAY REPLICATE("-",220)
				nLin++
			endIF
			nlin++
		
			//GUARDANDO TOTAIS PARA O TOTAL GERAL
			IF _lsint<>1 //SINTETICO
				TGQREC +=TQREC  //TOTAL DE VIAGENS
				TGPESOL+=TPESOL //TOTAL PESO L
				TGKMS  +=TKMS  	//TOTAL KM SAI
				TGKMR  +=TKMR	//TOTAL KM ENT
				TGKMT  +=TKMT	//TOTAL KM TOTAL
				TGKMTB +=TKMTB	//TOTAL KM TABELA
				TGVFRT +=TVFRT	//TOTAL VALOR FRETE
	//			TGPORC +=TPORC  //TOTAL GERAL PORCENTAGEM DE PERDA			
				TGPORC +=(TAVM/TAVR)*100  //TOTAL GERAL PORCENTAGEM DE PERDA			
				TGAVR  += TAVR
				TGAVM  += TAVM                
				TGPESOLM+=TPESOL //TOTAL GERAL PESO LIQUIDO MAFRA
				
			ENDIF
			
			//zerando totais
			TQREC	:=0					//TOTAL DE VIAGENS
			TPESOL	:=0                 //TOTAL PESO L
			TKMS  	:=0					//TOTAL KM SAI
			TKMR	:=0					//TOTAL KM ENT
			TKMT	:=0					//TOTAL KM TOTAL
			TKMTB	:=0					//TOTAL KM TABELA
			TVFRT	:=0					//TOTAL VALOR FRETE
			TAVR    :=0					//TOTAL DE aVES RECEBIDAS
			TAVM    :=0                 //Total de Aves Mortas
		IF 	_lsint ==2
		else
			nLin:=99	
			endif 
		
		endif
	EndDo

	//IMPRIMINDO TOTAL GERAL
	IF _lsint<>1  //SINTETICO
		nlin++
		@ nLin,000 PSAY REPLICATE("=",220)
		nLin++
		@ nLin,000 PSAY "<<<TOTAIS>>>"
		@ nlin,020 PSAY "Viagens : " +str(TGQREC)
		@ nlin,116 PSAY TGPESOL
		@ nlin,147 PSAY TGKMT
		@ nlin,156 PSAY TGKMTB
		@ nlin,170 PSAY TGVFRT
		@ nlin,180 PSAY TGAVR
		@ nlin,194 PSAY TGAVM
			@ nlin,201 PSAY (TGAVM/TGAVR)*100 picture '@E 999.99' //TGAVM/TGAVR PICTURE '@Z 999.99'//TGPORC/TGQREC 
		nlin++
		@ nLin,000 PSAY REPLICATE("=",220)
		nLin++
	ENDIF

	IF _lDiskF=1
		//COPIA PARA ARQUIVO
		dbselectarea("cArqT")
		dbgotop()
		_cArq:=_Path+cArqTmp+"_"+DTOS(DDATABASE)+_Ext
		COPY  TO &(_cArq)
	endif

	//fechando tabela da query
	cArqT->(DbCloseArea("cArqT"))
	if _lDiskF=1
		FErase(_cArq)  //aCRESCENTEI EM 16/06 PARA EXCLUIR O ARQ TEMPORARIO, DEVIDO AO CONSUMO DE ESPAÇO E BACKUP - HC - CELSO
	endif
		
	// ___________________________________________________________________________________________________________________________________________________________________________________________________________________________
	//
	// |   DATA   |  PLACA  | ORDEM  |         CIDADE                |         TRANSPORTADORA         | DESTINO | R    N | PESO L. | KM SAIDA | KM RET. | KM TOT. | TOT. GRAN. | TOTAL R$ | AVES CARR. | MORTAL |
	// XX/XX/XXXX  XXXXXXX   XXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XXXXXX             XXXXXX    XXXXXX     XXXXXX    XXXXXX    XXXXXX       XXXXXX     xxxxxxx      xxxxxx
	// ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	// 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890901234567890901234567890123456789012345678901234567890123456789
	// 0         1         2         3         4         5         6         7         8         9        10        11         12       13        14           15         16        17        18        19
	// ____________________________________________________________________________________________________________________________________________________________________________________________________________________________
	//
	// *
	// ___________________________________________________________________________________________________________________________________________________________________________________________________________________________
	// |   DATA   |  PLACA  | ORDEM  |     FORNECEDOR               |         TRANSPORTADORA         | DESTINO | R    N | PESO L. | KM SAIDA | KM RET. | KM TOT. | TOT. GRAN. | TOTAL R$ | AVES CARR. | MORTAL |
	// XX/XX/XXXX  XXXXXXX   XXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XXXXXX             XXXXXX    XXXXXX     XXXXXX    XXXXXX    XXXXXX       XXXXXX     xxxxxxxx     xxxxxx
	// ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	// 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890901234567890901234567890123456789012345678901234567890123456789
	// 0         1         2         3         4         5         6         7         8         9        10        11         12       13        14           15         16        17        18        19
	// ____________________________________________________________________________________________________________________________________________________________________________________________________________________________
	//*/

	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// ³ Finaliza a execucao do relatorio...                                 ³
	// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Fechando aquivos de trabalho

	SET DEVICE TO SCREEN

	//Se impressao em disco, chama o gerenciador de impressao

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

/*Imprimindo a data de abate*/

static function Cabec5 (xLin)

	xLin:=xLin+1
	@ xLin,000 PSAY "+" + REPLICATE ("-",24)+"+"
	xLin:=xLin+1
	@ xLin,000 PSAY "|"
	@ xLin,002 PSAY DTOC(_dDtaIni)
	@ xLin,012 PSAY "-"
	@ xLin,014 PSAY DTOC(_dDtaFim)
	@ xLin,025 PSAY "|"+ "      [*]Terceiros"

Return (xLin)

Static Function ProcTrApFt()//Processa Terceiros ; Apanha ; Frete

	//VERIFICANDO QUAL O TIPO DA GRANJA                         
	//SE O CODIGO DO FORNECEDOR  DA ADORO FOR IGUAL AO RECEBIDO
	//UTILIZO A PORCENTAGEM DE QUEBRA PARA INTEGRADOS DA ADORO 

	// Se flag de Odometro estiver sim considerar Km do Odometro
	// Verifica se considera Odmometro

	If FRT->ZV1_KMODM = 'S'
		_cKmOdm := 'S'
	Else
		_cKmOdm := ' '
	Endif

	//Fazendo a busca em SA2 pela                                       
	//a distancia do abatedouro ate a granja                            

	DbSelectArea("SA2")
	DbSetOrder(1)

	IF DBSEEK (xFilial("SA2")+_cCodFor+_LojFor,.T.)

		// Se flag de Odometro estiver sim considerar Km do Odometro
		IF _cKmOdm = 'S'
			_nDistAbt:= _nKMENT - _nKMSAI        //DISTANCIA DO ABATEDOURO
		Else
			_nDistAbt	:=A2_KMABT	  //DISTANCIA DO ABATEDOURO
		Endif
		_cNOMFOR :=A2_NOME	  //NOME DO FORNECEDOR

	Else
		_nDistAbt:=0

	EndIf

	_cMark := ''

	// Se for terceiros despresa distancia

	IF (_nContFor<>FRT->ZV1_FORREC)
		// Se for Terceiros considera odometro
		_nDistAbt:= _nKMENT - _nKMSAI        //DISTANCIA DO ABATEDOURO
		_cMark := '*'

	ENDIF

	//AQUI EU FACO OS CALCULOS

	_nRange:=_nKMENT - _nKMSAI      //Km total

	// Verifica se tem Apanha
	If FRT->ZV1_QTDAPN > 0
		_cApanh := 'A'
	Else
		_cApanh := ''
	Endif

	DBSELECTAREA("FRT")

Return

Static Function Retorno () //Processa Retorno

	//MARCACAO DE RETORNO OU NORMAL - -VIAGEM

	if (_lPvez==1) //verifico se eo primeiro registro- normal
		_cRetorno:="N"
		_nPOS:=112
		_lPvez:=0
	else
		
		//Estou verificando sempre se o proximo caminhao e retorno ou nao, comparando 
		//a prox placa com atual. caso sejam iguais marco a proxima placa como retorno
		
		if _cRetPrx="R" // vejo se devo marcar o proximo veiculo como retorno
			//			_nPOS:=107
			_cRetorno:="R"
			_cRetPrx="N"
		else
			if (_dDTBatF==_dDtaBat) //verifico se e a mesma data
				
				//vejo se e a prox placa e = a anterior, sendo a mesma placa             
				//no mesmo dia marco R para a placa futura                               
				
				IF (_cPLACAF==_cPLACA) // Se for igual marco a placa atual como normal e a proxima como retorno
					_cRetorno:="N"
					//_nPOS:=112
					_cRetPrx:="R"
				ELSE                  // caso contrario marco a atual como normal e a proxima tambem como NORMAL
					_cRetorno:="N"
					//	_nPOS:=112
					_cRetPrx:="N"
				ENDIF
			Else  					//Se a data nao for a mesma a viagem e NORMAL
				_cRetorno:="N"
				//	_nPOS:=112
			EndIf
		EndIF
	endif

	DBSELECTAREA("FRT")

Return

Static Function ProcCalc () //Processa Calculos

	//VERIFICO SE E CONSIDERADO PESO PADRAO                            
	//VERIFICO SE E CONSIDERADO PESO DE AJUSTE                         
	//Caso nao utilizado peso padrao  uso peso liquido                 

	IF 	(_lTaraPd=1)
		_nPESOl:=_n1peso-_n2peso
	Else
		_nPESOl:=_n1peso-_nTaraPD
	Endif
	If (_lAjusPL=1)
		_nPESOl:=_nPESOl+_nAjusPS
	Endif

	//CALCULO DA PERDA DE AVES EM PORCENTAGEM
	_nPercent:=(_nMortal/_nAves)*100

	//VERIFICO SE TEM O VALOR DE QUEBRA 
	_cMarkS_M := ' '

	//PESO LIQUIDO          
	_nPESOl := _nPESOl - _nVlrPerc

	// Pega o Valor do Frete se tiver gerado frete
	_nValFrt := 0
	dbselectarea("SZK")
	DbsetOrder(2)
	If DbSeek(xFilial("SZK") + _nGuia + _dDtaBat + _cPLACA,.T.)
		_nValFrt  := SZK->ZK_VALFRET
		_nDistAbt := SZK->ZK_KMPAG
	//	_nPESOl   := SZK->ZK_PBRUTO //desabilitado para compatibilizar relatório AD0143
	Endif
	DbSelectArea("FRT")

Return

Static Function GetData() //Adquire dados

	//OBTENDO VALORES³

	_cPLACA  := FRT->ZV1_RPLACA                         //PLACA
	_nTaraPD := FRT->ZV1_TARAPD	                        //TARA PADRAO
	_nAjusPS := FRT->ZV1_AJUSPS                         //PESO DE AJUSTE
	//Retirado em 28/01/08 para compatibilizar com o relatorio AD0143 de carregamento de frango 
	//_n1peso   :=FRT->ZV2_1PESO - FRT->ZV1_QTDQBR      //PRIMEIRO PESO - QUEBRA DE BALANCA
	_n1peso  := FRT->ZV2_1PESO                          //PRIMEIRO PESO 
	_n2peso  := FRT->ZV2_2PESO                          //SEGUNDO PESO
	_cCidade := FRT->ZV1_PCIDADE                        //CIDADE
	_nMortal := FRT->ZV1_MORTAL                         //MORTALIDADE
	_nAves   := (FRT->ZV1_CAVES + FRT->ZV1_QTDAPN)      //Aves Carregadas  && INCLUIDO QUANTIDADE DA APANHA 01/10/09 CHAMADO 
	_cRGRANJ := FRT->ZV1_RGRANJ                         //GRANJA/INTEGRADO
	_nKMSAI	 := FRT->ZV2_KMSAI                          //KM DE SAIDA
	_nKMENT	 := FRT->ZV2_KMENT                          //KM DE ENTRADA
	_dDtaBat := FRT->ZV1_DTABAT	                        //DATA DE ABATE
	_cOrdem  := FRT->ZV1_NUMOC	                        //ORDEM
	_nGuia   := FRT->ZV2_GUIA                           //NUMERO DA GUIA
	_nAjusPS := FRT->ZV1_AJUSPS                         //PSEO DE AJUSTE
	_cCodFor := FRT->ZV1_CODFOR	                        //CODIGO FORNECEDOR RECEBIDO
	_LojFor	 := FRT->ZV1_LOJFOR                         //LOJA FORNECEDOR RECEBIDO
	_cClivol := FRT->ZV1_CLIVOL                         //CLIMA NA VOLTA

	//Faco a busca pela transportadora em ZV4

	DbSelectArea("ZV4")
	DbSetOrder(1)
	IF DBSEEK (xFilial("ZV4")+_cPLACA,.T.)
		_cNoTrans	:= ZV4_NOMFOR	  //TRANSPORTADORA
		IF ZV4->ZV4_NOMFOR == '                              '
			_cNoTrans := '(             -              )'
		ENDIF
	ELSE
		_cNoTrans := '(             -              )'
	endIf

	//Fazendo a busca em SA2 pela                                       
	//a distancia do abatedouro ate a granja                            

	DBSELECTAREA("FRT")//RETORNANDO A AREA DA QUERY

Return
