#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} User Function nomeFunction
	Programado X Realizado
	@type  Function
	@author Daniel Pitthan
	@since 22/12/2005
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
/*/
User Function AD0157()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Programado X Realizado"
	Local cPict          := ""
	Local titulo       := "Programado X Realizado"
	Local nLin         := 80
	Local Cabec1       := "Relatório por Periodo"
	Local Cabec2       := "ADORO S/A"
	Local imprime      := .T.
	Local aOrd := {} 

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'ProgramadoX Realizado')

	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 220
	Private tamanho          := "G"
	Private nomeprog         := "AD0157" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 15
	Private aReturn          := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "AD0157" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private _nSomaQTD
	Private cString := ""
	Private _nZV1PAVES //aves programadas
	Private _nZV1RAVES //aves recebidas
	Private _nZV1PESLIQ//peso liq
	Private _nZV1PESOME//peso medio
	Private _nZV1PGRANJ//integrado
	Private _nPrxGranj //gRANJA FUTURA
	Private _nPprog//peso programado
	Private _nTotAveP//total de aves programadas
	Private _nTotAveR//total de aves recebidas
	Private _nTotPLiq//total de peso liquido
	Private _nTotPMed//total de peso medio
	Private _nTotPpro//total do peso programado
	Private _nTotDifA//dife total aves rec e realiz
	Private _nTotDifP //dife pes liq e peso prog
	Private _dDtaIni //data de abate inicial
	Private _dDtaFim //data final de abate
	Private _nTotPMP//total do peso medio programado
	Private _nTotPMR//total peso medio recebido
	Private _ZV4Peso//peso padrao em ZV4
	Private _nTotPesP//Total peso padrao
	Private _ZV21PESO//Primeira pesagem
	Private  _ZV22PESO//SEGUNDA PESAGEM
	Private _nQtdV //numero de viagens
	Private _ZV1NUMOC := ' '  // Numero Ordem
	Private _DIFPme:=0 //DIFERENCA PESO MEDIO
	Private _ntotM:=0//acumula motalidade
	Private _ZV1Peso //Peso 1
	Private _ZV1MORTAL //Mortalidade
	Private _nDifA	//diferenca de aves recebida/programado
	Private  _nDifP  //diferenca do peso programado/recebido
	Private _nPMP	//TOTAL PESO MEDIO PROGRAMADO
	Private _nPMR //TOTAL PESO MEDIO REALIZADO
	Private _TDIFPme //DIFERENCA DE PESO MEDIO - total
	Private _ADIFPme //DIFERENCA DE PESO MEDIO - analitico
	Private _xLinha:= "__________________________________________________________________________________________________________________________________________________________"

	//total geral

	Private	TGAVP:=0//TOTAL GERAL AVES PROGRAMADAS
	Private	TGVIA:=0//TOTAL GERAL DE VIAGENS
	Private	TGAVR:=0//TOTAL GERAL DE AVES RECEBIDAS
	Private	TGAVM:=0//TOTAL GERAL DE MORTOS
	Private	TGDAV:=0//TOTAL GERAL DA DIFERENCA DE AVES REC. PROG.
	Private	TGPPR:=0//TOTAL GERAL DE PESO PROGRAMADO
	Private	TGPRC:=0//TOTAL GERAL DO PESO LIQUIDO
	Private	TGDPP:=0//TOTAL GERAL DA DIFERENCA DO PESO LIQUIDO PROGRAMADO COM O RECEBIDO
	Private	TGPMP:=0//TOTAL GERAL DO PESO MEDIO PROGRAMADO
	Private	TGPMR:=0//TOTAL GERAL DO PESO MEDIO REALIZADO
	Private	TGPMD:=0//TOTAL GERAL DA DIFERENCA DO PESO MEDIO

	cPerg:="AD0157"
	pergunte (cPerg,.T.)

	_dDtaIni:=MV_PAR01 //data inicial
	_dDtaFim:=MV_PAR02 //data final
	_lTarPad:=MV_PAR03 //Usa Tara padrao, sim|nao
	//_lPrtPAr:=MV_PAR04 //PARAMETROS
	_lAnlStc:=MV_PAR04 //Analitico  ou Sintetico

	//Forço mostrar o parametro da data
	_lPrtPAr := 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  22/12/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Zerando totais
_nTotAveP:=0
_nTotAveR:=0
_nTotPLiq:=0
_nTotPMed:=0
_nPprog:=0
_nTotPpro:=0
_nTotPesP:=0
_nTotPMP:=0
_nTotPMR:=0
_nQtdV:=0  
_CALCULO1:=0
_CALCULO2:=0
SetRegua(RecCount())

/*
Cquery := " SELECT "+;
" ZV1_NUMOC, "+;
" ZV1_QTDQBR, "+;
" ZV1_PAVES, "+;
" ZV1_CAVES, "+;
" ZV1_RAVES, "+;
" ZV1_PESLIQ, "+;
" ZV1_PESOME, "+;
" ZV1_RGRANJ, "+;
" ZV1_RPLACA, "+;
" ZV1_TARAPD, "+;
" ZV2_1PESO, "+;
" ZV2_2PESO, "+;
" ZV1_MORTAL "+;
" FROM "+retsqlname("ZV1")+","+retsqlname("ZV2")+" "+;
" WHERE (ZV1_DTABAT>='"+DTOS(_dDtaIni)+"' AND ZV1_DTABAT<='"+DTOS(_dDtaFim)+"') "+;
" AND ZV1_GUIAPE=ZV2_GUIA  "+;
" AND ZV2_TIPOPE='F' "+;   
" AND "+retsqlname("ZV1")+".D_E_L_E_T_ <>'*' "+;
" AND "+retsqlname("ZV2")+".D_E_L_E_T_ <>'*' "+;
" ORDER BY ZV1_RGRANJ, ZV1_NUMOC "

Cquery := " SELECT "+;
" ZV1_NUMOC, "+;
" ZV1_QTDQBR, "+;
" ZV1_PAVES, "+;
" ZV1_CAVES, "+;
" ZV1_RAVES, "+;
" ZV1_PESLIQ, "+;
" ZV1_PESOME, "+;
" ZV1_RGRANJ, "+;
" ZV1_RPLACA, "+;
" ZV1_TARAPD, "+;
" ZV2_1PESO, "+;
" ZV2_2PESO, "+;
" ZV1_MORTAL "+;
" , CASE WHEN ZV1_FORREC = '000217' THEN  ((ZV2_1PESO - ZV1_QTDQBR)-ZV1_TARAPD)+((((ZV2_1PESO - ZV1_QTDQBR)-ZV1_TARAPD)*0.7)/100) ELSE ZK_PBRUTO END CALCULO1, "+;
" CASE WHEN ZV1_FORREC = '000217' THEN  ((ZV2_1PESO - ZV1_QTDQBR)-ZV2_2PESO)+((((ZV2_1PESO - ZV1_QTDQBR)-ZV2_2PESO)*0.7)/100) ELSE ZK_PBRUTO END CALCULO2 "+;
" FROM "+retsqlname("ZV1")+","+retsqlname("ZV2")+" "+","+retsqlname("SZK")+" "+;
" WHERE ZK_GUIA = ZV1_GUIAPE AND (ZV1_DTABAT>='"+DTOS(_dDtaIni)+"' AND ZV1_DTABAT<='"+DTOS(_dDtaFim)+"') "+;
" AND ZV1_GUIAPE=ZV2_GUIA  "+;
" AND ZV2_TIPOPE='F' "+;   
" AND "+retsqlname("ZV1")+".D_E_L_E_T_ <>'*' "+;
" AND "+retsqlname("ZV2")+".D_E_L_E_T_ <>'*' "+;     
" AND "+retsqlname("SZK")+".D_E_L_E_T_ <>'*' "+;
" ORDER BY ZV1_RGRANJ, ZV1_NUMOC "
*/

Cquery := " SELECT "+;
" ZV1_NUMOC, "+;
" ZV1_QTDQBR, "+;
" ZV1_PAVES, "+;
" ZV1_CAVES, "+;
" ZV1_RAVES, "+;
" ZV1_PESLIQ, "+;
" ZV1_PESOME, "+;
" ZV1_RGRANJ, "+;
" ZV1_RPLACA, "+;
" ZV1_TARAPD, "+;
" ZV2_1PESO, "+;
" ZV2_2PESO, "+;
" ZV1_MORTAL "+;
" , CASE WHEN ZV1_FORREC = '000217' THEN  ((ZV2_1PESO - ZV1_QTDQBR)-ZV1_TARAPD)+((((ZV2_1PESO - ZV1_QTDQBR)-ZV1_TARAPD)*0.7)/100) ELSE ZK_PBRUTO END CALCULO1, "+;
" CASE WHEN ZV1_FORREC = '000217' THEN  ((ZV2_1PESO - ZV1_QTDQBR)-ZV2_2PESO)+((((ZV2_1PESO - ZV1_QTDQBR)-ZV2_2PESO)*0.7)/100) ELSE ZK_PBRUTO END CALCULO2 "+;
" FROM "+retsqlname("ZV1")+" (NOLOCK),"+retsqlname("ZV2")+" (NOLOCK)"+","+retsqlname("SZK")+" (NOLOCK)"+;
" WHERE ZV1_FILIAL='"+FWxFilial("ZV1")+"' AND ZV1_FILIAL=ZV2_FILIAL " // @history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
" AND ZK_NUMOC = ZV1_NUMOC AND (ZV1_DTABAT>='"+DTOS(_dDtaIni)+"' AND ZV1_DTABAT<='"+DTOS(_dDtaFim)+"') "+;
" AND ZV1_GUIAPE=ZV2_GUIA  "+;
" AND ZV2_TIPOPE='F' "+;   
" AND "+retsqlname("ZV1")+".D_E_L_E_T_ <>'*' "+;
" AND "+retsqlname("ZV2")+".D_E_L_E_T_ <>'*' "+;     
" AND "+retsqlname("SZK")+".D_E_L_E_T_ <>'*' "+;
" ORDER BY ZV1_RGRANJ, ZV1_NUMOC "

TCQUERY cQuery new alias "CMP"
//PRIMEIRA VEZ
_nZV1PGRANJ:=CMP->ZV1_RGRANJ //PARA PRIMEIRA GRANJA ADQUIRO O INTEGRADO
_nPrxGranj:=_nZV1PGRANJ

// " WHERE ZK_GUIA = ZV1_GUIAPE AND (ZV1_DTABAT>='"+DTOS(_dDtaIni)+"' AND ZV1_DTABAT<='"+DTOS(_dDtaFim)+"') "+; ORIGINAL EM 12/02/2014
DBSELECTAREA("CMP")
dbGoTop()
While !EOF()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o cancelamento pelo usuario...                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho do relatorio. . .                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
		if _lPrtPAr=1
			nLin:=PrintOp(nLin)
		EndIf
		nLin:=cabec4(nLin)
	Endif
	
	//Primeira Granja
	_nPrxGranj:=_nZV1PGRANJ
	
	WHILE (_nPrxGranj ==_nZV1PGRANJ)
		
  		GetVars()	//Adquiro os campos

_CALCULO1:=CALCULO1
_CALCULO2:=CALCULO2

		dbSkip()

		
		//registro futuro para comparar se houve troca de granja
		_nPrxGranj:=CMP->ZV1_RGRANJ

						MakePrc ()//processando acumuladores
		
		//detalhe do relatorio
		IF _lAnlStc = 2 //[1]SINTETICO OU [2]ANALITICO
			
			MakeCalc ()//faz os calculos
			
			@nLin,002 PSAY _nZV1PGRANJ  						//granja
			@nLin,011 PSAY _nZV1PAVES   						//aves programadas
			@nLin,023 PSAY _nQtdV      							//NUMERO DE VIAGENS
			@nLin,030 PSAY _nZV1RAVES   						//aves recebidas
			@nLin,043 PSAY _ZV1MORTAL   						//mortos
			@nLin,052 PSAY  _nDifA picture '@E@Z 9999,9999.99'    		//diferenca de aves recebida/programado
			@nLin,064 PSAY _nPprog  picture '@E 99999999'   	//peso progrado
//			@nLin,077 PSAY round(_nZV1PESLIQ,0) picture '@E 99999999'  	//peso recebido
			@nLin,077 PSAY _CALCULO1 picture '@E 99999999'  	//peso recebido
			@nLin,090 PSAY  _nDifP picture '@E@Z 9999,999.99'   			//diferenca do peso programado/recebido
			@nLin,101 PSAY _nPMP picture '@E@Z 9999.999'					//TOTAL PESO MEDIO PROGRAMADO
			@nLin,117 PSAY _nPMR picture '@E@Z 9999.999'    				//TOTAL PESO MEDIO REALIZADO
			@nLin,133 PSAY _ADIFPme picture '@E@Z 99,999.999' 	//DIFERENCA DE PESO MEDIO
			@nLin,145 PSAY _ZV1NUMOC      								//NUMERO DA ORDEM
			nLin:=nlin+1
			
		ENDIF
		
	
	ENDDO

	
	MakeCalc ()
	
	
	//total da granja por periodo
	IF _lAnlStc = 2 //[1]SINTETICO OU [2]ANALITICO
		
		nlin++
		@ nLin,000 PSAY Replicate ("_",len(_xLinha))
		nlin++
	Endif
	@nLin,002 PSAY _nZV1PGRANJ 							//granja
	@nLin,011 PSAY _nTotAveP   							//aves programadas
	@nLin,023 PSAY _nQtdV      							//NUMERO DE VIAGENS
	@nLin,030 PSAY _nTotAveR   							//aves recebidas
	@nLin,043 PSAY _ntotM   							//mortos
	@nLin,052 PSAY _nTotDifA   		  picture '@E@Z 9999,9999.99'					//diferenca de aves recebida/programado
	@nLin,064 PSAY _nTotPpro picture '@E@Z 99999999'   //peso progrado
	@nLin,077 PSAY _nTotPLiq picture '@E@Z 99999999'  	//peso recebido
	@nLin,090 PSAY _nTotDifP   		  PICTURE '@E@Z 9999,999.99'						//diferenca do peso programado/recebido
	@nLin,101 PSAY _nTotPMP	picture '@E@Z 9999.999'				//TOTAL PESO MEDIO PROGRAMADO
	@nLin,117 PSAY _nTotPMR picture '@E@Z 9999.999'    			//TOTAL PESO MEDIO REALIZADO
	@nLin,133 PSAY _TDIFPme PICTURE '@E@Z 99,999.999'		//DIFERENCA DE PESO MEDIO
	
	IF _lAnlStc = 2 //[1]SINTETICO OU [2]ANALITICO
		nlin++
		@ nLin,000 PSAY Replicate ("_",len(_xLinha))
		nlin++
		nlin++
	Else
		nLin++
	Endif
	
	
	
	
	/*
	| GRANJA | AVES PROG. |  V  | AVES CARR. | MORTAL | DIFERENCA | PESO PROG. | PESO REC. | DIFERENCA | P. MED. PROG. | P. MED. REAL | DIF P. MED |   O.C.  |
	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345679012345678901234567890123456789
	0         1         2         3         4         5         6         7         8         9         10        11       12       13        14
	*/
	
	TGAVP:=TGAVP+_nTotAveP  //TOTAL GERAL AVES PROGRAMADAS
	TGVIA:=TGVIA+_nQtdV     //TOTAL GERAL DE VIAGENS
	TGAVR:=TGAVR+_nTotAveR  //TOTAL GERAL DE AVES RECEBIDAS
	TGAVM:=TGAVM+_ntotM	  	//TOTAL GERAL DE MORTOS
	TGDAV:=TGDAV+_nTotDifA  //TOTAL GERAL DA DIFERENCA DE AVES REC. PROG.
	TGPPR:=TGPPR+_nTotPpro  //TOTAL GERAL DE PESO PROGRAMADO
	TGPRC:=TGPRC+_nTotPLiq  //TOTAL GERAL DO PESO LIQUIDO
	TGDPP:=TGDPP+_nTotDifP  //TOTAL GERAL DA DIFERENCA DO PESO LIQUIDO PROGRAMADO COM O RECEBIDO
	TGPMP:=TGPMP+_nTotPMP   //TOTAL GERAL DO PESO MEDIO PROGRAMADO
	TGPMR:=TGPMR+_nTotPMR   //TOTAL GERAL DO PESO MEDIO REALIZADO
	TGPMD:=TGPMD+_TDIFPme   //TOTAL GERAL DA DIFERENCA DO PESO MEDIO
	
	//ZERANDO CONTADORES
	_nTotAveP:=0
	_nTotAveR:=0
	_nTotPLiq:=0
	_nTotPMed:=0
	_nPprog:=0
	_nTotPpro:=0
	_nTotPesP:=0
	_nTotPMP:=0
	_nTotPMR:=0
	_nQtdV:=0 //zero contador para proxima granja
	_ntotM:=0
	
EndDo
dbclosearea("CMP")


//total geral

IF _lAnlStc = 1 .or. _lAnlStc = 2 //[1]SINTETICO OU [2]ANALITICO
	
	IF 	TGAVP<>0
		nlin++
		@ nLin,000 PSAY Replicate ("_",len(_xLinha))
		nlin++
	
		@nLin,011 PSAY TGAVP      //aves programadas
		@nLin,023 PSAY TGVIA      //NUMERO DE VIAGENS
		@nLin,030 PSAY 	TGAVR     //aves recebidas
		@nLin,043 PSAY 	TGAVM     //mortos
		@nLin,052 PSAY 	TGDAV     //diferenca de aves recebida/programado
		@nLin,064 PSAY TGPPR  picture '99999999'   //peso progrado
		@nLin,077 PSAY TGPRC picture '99999999'  //peso recebido
		@nLin,090 PSAY 	TGDPP picture '99999999.99'   //diferenca do peso programado/recebido
		//peso medio programado=total do peso programado/total de aves programadas
		TGPMP := TGPPR / TGAVP		
		@nLin,101 PSAY 	TGPMP	picture '@E@Z 9999.999'	//TOTAL PESO MEDIO PROGRAMADO
   		//peso medio recebido= total do peso liquido/pelo numero de aves do contador.		
		TGPMR :=  TGPRC	/ TGAVR
		@nLin,117 PSAY TGPMR picture '@E@Z 9999.999'    //TOTAL PESO MEDIO REALIZADO
		TGPMD := TGPMP - TGPMR			//PESO MEDIO REALIZADO - PROGRAMADO		
		@nLin,133 PSAY TGPMD PICTURE '@E@Z 99,999.999'    //DIFERENCA DE PESO MEDIO
	
		nlin++
		@ nLin,000 PSAY Replicate ("-",len(_xLinha))
		nlin++
	ENDIF
	
Endif




//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

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

Return

Static  function Cabec4(xLin)
xLin++
@ xLin,000 PSAY _xLinha
xLin++
@ xLin,000 PSAY "| GRANJA | AVES PROG. |  V  | AVES CARR. | MORTAL | DIFERENCA | PESO PROG. | PESO ORIG | DIFERENCA | P. MED. PROG. | P. MED. REAL | DIF P. MED |   O.C.  |"
xLin++
@ xLin,000 PSAY "----------------------------------------------------------------------------------------------------------------------------------------------------------"
xLin++
Return (xLin)


Static Function GetVars()	//Adquiro os campos

Apanha()  &&Verifica apanha para somar na quantidade de aves carregadas Chamado 005128 (_nSomaQTD) - Mauricio HC Consys.
DBSELECTAREA("CMP")
_nZV1PAVES :=CMP->ZV1_PAVES   //aves programadas
IF MV_PAR05=2
	_nZV1RAVES :=CMP->ZV1_CAVES + _nSomaQTD  //aves recebidas
ELSE
	_nZV1RAVES :=CMP->ZV1_RAVES + _nSomaQTD   //aves recebidas
ENDIF
_nZV1PESOME:=CMP->ZV1_PESOME  //peso medio
_nZV1PGRANJ:=CMP->ZV1_RGRANJ  //integrado
_ZV1Peso   :=CMP->ZV1_TARAPD  //PESO PADRAO
_ZV21PESO  :=CMP->ZV2_1PESO - CMP->ZV1_QTDQBR  //PRIMEIRA PESAGEM - QUEBRA
_ZV22PESO  :=CMP->ZV2_2PESO   //SEGUNDA PESAGEM
_ZV1MORTAL :=CMP->ZV1_MORTAL  //MORTALIDADE
_ZV1NUMOC  :=CMP->ZV1_NUMOC	  //NUMERO DE OC
_CALCULO1:=CMP->CALCULO1
_CALCULO2:=CMP->CALCULO2
Return()

Static Function MakeCalc () //calculos
_nDifA:=  _nZV1PAVES-(_nZV1RAVES+_ZV1MORTAL)//AVES PROGRAMADO - REALIZADO
_nDifP:=  _nPprog-_nZV1PESLIQ    	//diferenca peso liquido e peso prog

_nPMP	:=  _nPprog/_nZV1PAVES      //Peso medio PROGRAMADO
_nPMR   := _nZV1PESLIQ/ _nZV1RAVES  //Peso medio Realizado

_nTotPMR:=_nTotPLiq/_nTotAveR		//peso medio recebido= total do peso liquido/pelo numero de aves do contador.
_nTotPMP:=_nTotPpro/_nTotAveP		//peso medio programado=total do peso programado/total de aves programadas

_TDIFPme:=_nTotPMP-_nTotPMR			//PESO MEDIO REALIZADO - PROGRAMADO

_ADIFPme:=_nPMP-_nPMR				//PESO MEDIO REALIZADO - PROGRAMADO


//Calculos das diferencas
if 	(_nTotAveR=0)
	_nTotDifA:=0
else
	_nTotDifA:=_nTotAveR-_nTotAveP  //diferenca total aves rec e realiz
endif
if (_nTotPLiq=0)
	_nTotDifP:=0
else
	_nTotDifP:=_nTotPLiq-_nTotPpro  //diferenca peso liquido e peso prog
endif

Return

Static Function MakePrc ()

_nPprog:=_nZV1PAVES*_nZV1PESOME  //peso programado

//Condicao da tara padrao
//CALCULO DO PESO LIQUIDO
if (_lTarPad=1)
//	_nZV1PESLIQ:=_ZV21PESO-_ZV1Peso
_nZV1PESLIQ:= _CALCULO1
else
_nZV1PESLIQ:=_CALCULO2
endif

//Totalizando
_nTotAveP:=_nTotAveP+_nZV1PAVES 				//total de aves programadas
_nTotAveR:=_nTotAveR+_nZV1RAVES		      //total de aves recebidas
_nTotPLiq:=_nTotPLiq+_nZV1PESLIQ    			//total de peso liquido
_nTotPMed:=_nTotPMed+_nZV1PESOME    			//total de peso medio programado
_nTotPpro:=_nTotPpro+_nPprog        			//total do peso programado
_ntotM   :=_ntotM+_ZV1MORTAL                    //acumula mortalidade
_nQtdV++                            			//numero de viagens
Return

Static function PrintOp(xLin) //imprime os parametros

//Private _carr //Resposta
//PARAMETROS//
//Private par01
//Private par02
//Private par03
//Private par04


//MONTANDO PARAMETROS
Par01:="| DATA INICIAL        :"+DTOC(_dDtaIni)+REPLICATE(" ",30)+"    |"
par02:="| DATA FINAL          :"+DTOC(_dDtaFim)+REPLICATE(" ",30)+"    |"
/*
if _lTarPad=1
	_carr:="SIM"
else
	_carr:="NAO"
endif
par03:="| USA TARA PADRAO     :"+_carr+REPLICATE(" ",30+len(DTOC(_dDtaFim)))+" |"

if _lPrtPAr=1
	_carr:="TODAS AS FOLHAS       "
else
	_carr:="SOMENTE FOLHA DE ROSTO"
endif
par04:="| PARAMETROS          :"+_carr+REPLICATE(" ",11+len(DTOC(_dDtaFim)))+" |"

if _lAnlStc=1
	_carr:="SINTETICO"
else
	_carr:="ANALITICO"
EndIf
par05:="| TIPO DE RELATORIO   :"+_carr+REPLICATE(" ",11+len(DTOC(_dDtaFim)))+"              |"
/*

//IMPRIMINDO PARARAMETROS
xlin++
@ xlin,000 PSAY "+------------------------------------------------------------------+"
xlin++
@ xLin,000 PSAY "|                        PARAMETROS                                |"
xlin++
@ xlin,000 PSAY par01
xlin++
@ xlin,000 PSAY par02
xlin++
@ xlin,000 PSAY par03
xlin++
@ xlin,000 PSAY par04
xlin++
@ xlin,000 PSAY par05
xlin++
@ xLin,000 PSAY "+------------------------------------------------------------------+"
*/

Return (xLin)

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
Static Function PrintOpp (YLIN)

	//VARIAVEIS LOCAIS
	//CAL per //nome da pergunta

	Ylin++
	@ Ylin,000 PSAY "+-------------------------------------------------------------------+"
	YLIN++
	@ Ylin,000 PSAY "|                          PARAMETROS                               |"
	YLIN++
	YLIN++

Return(XLIN)
            
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
Static function Apanha()

	//&&Verifica se tem Apanha para trazer a quantidade do apanhe.
	DbSelectArea("ZV5")
	DbSetOrder(1)
	_nSomaQtd := 0
	If DbSeek(xFilial("ZV5")+CMP->ZV1_NUMOC ,.T.)
		//Do While !Eof() .AND. CMP->ZV1_NUMOC=ZV5->ZV5_NUMOC
		Do While !Eof() .AND. CMP->ZV1_NUMOC=ZV5->ZV5_NUMOC .and. ZV5->ZV5_FILIAL==FWxFilial("ZV5") // @history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
		_nSomaQtd += ZV5->ZV5_QTDAVE
		DbSelectArea("ZV5")
		Dbskip()
	enddo
	endif      
return(_nSomaQtd)
