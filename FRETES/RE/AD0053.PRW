#INCLUDE "rwmake.ch"
#include 'topconn.ch'

/*/{Protheus.doc} User Function AD0053
	Fechamento por Tipo de Frete ( A1, A2 e etc...)
	@type  Function
	@author Gustavo e Werner
	@since 22/08/03
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
/*/
User Function AD0053()

	cPerg   := "AD0053"
	Pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01             // Data de                              |
	//³ mv_par02             // Data ate                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	cDesc2         := "de acordo com os parametros informados pelo usuario."
	cDesc3         := "Fechamento por Tipo de Frete"
	cPict          := ""
	titulo         := "Fechamento por Tipo de Frete"
	nLin           := 80
	Cabec1         := ""
	Cabec2         := ""
	imprime        := .T.
	aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 220
	Private tamanho      := "G"
	Private nomeprog     := "AD0053" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "AD0053" // Coloque aqui o nome do arquivo usado para impressao em disco     
	Private _lPrim       := .T.

	Private cString := "SZK"

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fechamento por Tipo de Frete ( A1, A2 e etc...)')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  22/08/03   º±±
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

SetRegua(RecCount())

_dDtIni  := mv_par01
_dDtFim  := mv_par02
_cTipFrt := mv_par03

Cabec6  := space(60)+ "Periodo de : " + DTOC(_dDtIni) + " Ate : " + DTOC(_dDtFim)
Cabec3  := "|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
Cabec4  := "|   TIPO   |  TP.VEIC.  | VIAGENS | No.ENTR. |  PESO BRUTO  |   PESO LIQ.  |    KM     |  VL.TOT.FRETE  |   %   |   DESCONTO   |  ACRESCIMO   |  VL.TOT.LIQ. |   R$ TONEL.   |"
Cabec5  := "|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
//          0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22        23
//          01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//Cabec7  := "|===============================================================================================================================================================|"
//Cabec8  := "|          |   TOTAL    |         |                                                                                                                             |"
//Cabec9  := "|===============================================================================================================================================================|"

// variaveis da linha detalhe
_nEntr     := 0
_nViag     := 0
_nPesBr    := 0
_nPesLiq   := 0
_nKm       := 0
_nFret     := 0
_nPerc     := 0
_nDesc     := 0
_nAcr      := 0
_nLiq      := 0
_nTon      := 0

// Totais {viagens, no.entregas, peso bruto, peso liquido, km, Vl Bruto Frete, %, Desc, Acres, Tot Liq Frete, Vl Ton }

_cDescTipo  := ""
aTotTabela  := {0,0,0,0,0,0,0,0,0,0,0}
aTotTipo    := {0,0,0,0,0,0,0,0,0,0,0}
aTotTpFrete := {0,0,0,0,0,0,0,0,0,0,0}
aTotGeral   := {0,0,0,0,0,0,0,0,0,0,0}

//

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montando as Query de consulta                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³chamado 022891 - WILLIAM COSTA                                     ³
//³                                                                   ³
//³obs: TI, foi criado varias tabelas de frete para poder reorganizar ³
//³valores de frete na logistica entre tanto foi necessário           ³
//³alterar o select para poder pegar o campo ZV4_TIPVEI               ³
//³ao invés de ZK_tabela.                                             ³
//³                                                                   ³
//³Portanto foram adicionado as seguintes campos para                 ³
//³poder cumpri este chamado.                                         ³
//³                                                                   ³
//³ZV4_TIPVEI AS ZK_TABELA,                                           ³
//³FROM SZK010 SZK, ZV4010 ZV4                                        ³
//³ AND SZK.ZK_FILIAL  = ZV4.ZV4_FILIAL                               ³
//³ AND SZK.ZK_PLACAPG = ZV4.ZV4_PLACA                                ³
//³ AND ZV4.D_E_L_E_T_ = ' '                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/


cQuery := 	" SELECT ZK_TIPFRT, ZK_TPFRETE, ZK_DESCRI, ZV4_TIPVEI AS ZK_TABELA, ZK_ENTREGA, ZK_PLACAPG, ZK_PBRUTO, ZK_PESOL, "
cQuery +=	" ZK_KMPAG, ZK_DTENTR , ZK_VALFRET, ZK_GUIA "
cQuery +=	" FROM " + RetSQLName("SZK") + " SZK, " +  RetSQLName("ZV4") + " ZV4 " 
cQuery +=	" WHERE (ZK_DTENTR BETWEEN '"+DTOS(_dDtIni) +"' AND '"+DTOS(_dDtFim)+"')"
cQuery +=	" AND ZK_TIPFRT ='"+ALLTRIM(_cTipFrt)+"'"
cQuery +=	" AND SZK.D_E_L_E_T_=' '"  
cQuery +=	" AND SZK.ZK_FILIAL  = ZV4.ZV4_FILIAL "
cQuery +=	" AND SZK.ZK_PLACAPG = ZV4.ZV4_PLACA "
cQuery +=	" AND ZV4.D_E_L_E_T_ = ' ' "
cQuery +=	" ORDER BY ZK_TIPFRT, ZK_TPFRETE, ZK_TABELA, ZK_PLACAPG, ZK_GUIA "

TCQUERY cQuery new alias "ZK1"


dbSelectArea("ZK1")
dbgotop()
While !EOF()
	_cTpFrete := ZK1->ZK_TIPFRT
	Do While ZK1->ZK_TIPFRT == _cTpFrete //.or. ZK1->( !EOF() )
	
		_cTipo := ZK1->ZK_TPFRETE
		Do While ZK1->ZK_TPFRETE == _cTipo .and. ZK1->ZK_TIPFRT == _cTpFrete //.or. ZK1->( !EOF() )

			_cTpVeic := ZK1->ZK_TABELA
			Do While ZK1->ZK_TABELA == _cTpVeic .and. ZK1->ZK_TIPFRT == _cTpFrete .and. ZK1->ZK_TPFRETE == _cTipo //;
			         //.or. ZK1->( !EOF() )

				_cPlacaVei := ZK1->ZK_PLACAPG
				Do While ZK_PLACAPG == _cPlacaVei .and. ZK1->ZK_TABELA == _cTpVeic .and. ZK1->ZK_TIPFRT == _cTpFrete;
				        .and. ZK1->ZK_TPFRETE == _cTipo //.or. ZK1->( !EOF() )
				    
								      
					//INCLUIDO EM 010208 PARA COMPATIBILIZAR COM OS RELATORIOS AD0170 E AD0143

				   //_qry := "SELECT ZV1_QTDQBR FROM "+RetSQLName("ZV1")+" WHERE ZV1_GUIAPE = '"+ZK1->ZK_GUIA+"' AND D_E_L_E_T_ <> '*'"
				   _qry := "SELECT ZV1_QTDQBR FROM "+RetSQLName("ZV1")+" (NOLOCK) WHERE ZV1_FILIAL='"+FWxFilial("ZV1")+"' AND ZV1_GUIAPE = '"+ZK1->ZK_GUIA+"' AND D_E_L_E_T_ <> '*' " // @history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
				   TCQUERY _qry new alias "XZV1"
								                  
    
// Alterado em 13/12/13 Luciano Mafra - Retirada a rotina que calcula a quebra, relatório não batia com a planilha da Fernanda - Chamado 				    
					_nViag 	 += 1
					_nEntr   += ZK1->ZK_ENTREGA
					_nPesBr  += (ZK1->ZK_PBRUTO+IIF(ALLTRIM(ZK1->ZK_TIPFRT) = 'ZV',XZV1->ZV1_QTDQBR,0)) // EM 010208
//					_nPesBr  += ZK1->ZK_PBRUTO
					_nPesLiq += (ZK1->ZK_PESOL+IIF(ALLTRIM(ZK1->ZK_TIPFRT) = 'ZV',XZV1->ZV1_QTDQBR,0)) //EM 010208
//                  _nPesLiq += ZK1->ZK_PESOL
					_nKM     += ZK1->ZK_KMPAG
					_nFret   += ZK1->ZK_VALFRET
//					_nViag 	 += 1
//					_nEntr   += ZK1->ZK_ENTREGA
//					_nPesBr  += ZK1->ZK_PBRUTO
//					_nPesLiq += ZK1->ZK_PESOL
//					_nKM     += ZK1->ZK_KMPAG
//					_nFret   += ZK1->ZK_VALFRET					
					
					DBSELECTAREA("XZV1")
					DBCLOSEAREA()
					
                  // Descricao do Tipo de Frete
				  If !Empty(ZK1->ZK_DESCRI)
						_cDescTipo := ZK1->ZK_DESCRI
			      EndIf
			      
					// Verifica se ha acrescimos/descontos
					_cGuia   := ZK1->ZK_GUIA					
					If !Empty(_cGuia)
					   QrySZI(_cGuia) //busca os acrescimos/descontos  - daniel 05/01/07
					   Do While !Eof() //.and. ZI1->ZI_GUIA == _cGuia .and. ZI1->ZI_PLACA == _cPlacaVei
					      If ZI1->ZI_TIPO = "A"
					      	_nAcr  += ZI1->ZI_VALOR
					      Else
					      	_nDesc += ZI1->ZI_VALOR
					      EndIf
					      ZI1->( dbSkip())
					   EndDo
					   IF ALIAS()=="ZI1"
					   	  DBCLOSEAREA("ZI1")
					   ENDIF	
					EndIf
					
					dbSelectArea("ZK1")
					dbSkip()
				EndDo
			EndDo
//		    Imprime a Linha         
		    PrintLinha()
		EndDo
//		Imprimir Total por Tipo
		PrintTotTab()
	EndDo
//	Imprimir o Total por Tipo de Frete ( parametro mv_par03 )
	PrintTotTipo()
EndDo

// Verificar se ha algum total entre os Tipos de Frete ( parametro mv_parm3 )	
// Imprimir o Total Geral

If !EMPTY(ZK1->ZK_TIPFRT)
	PrintTotGeral()
EndIf
    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³fechando as areas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbselectarea("ZK1")
	dbCloseArea("ZK1")
//dbselectarea("ZI1")
//dbCloseArea("ZI1")

Return
	
Static Function PrintLinha()	
	If nLin > 60
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8 
		@nLin,000 PSAY CABEC6
		nLin := nLin + 1
		@nLin,000 PSAY CABEC3
		nLin := nLin + 1
		@nLin,000 PSAY CABEC4
		nLin := nLin + 1
		@nLin,000 PSAY CABEC5
		nLin := nLin + 1
	Endif
			
	// Imprime o Tipo na primeira linha
	If _lPrim
		@nLin,000 PSAY "|"	
		@nLin,002 PSAY _cTipo
		@nLin,005 PSAY _cDescTipo
		@nLin,173 PSAY "|"	
		nLin++
		_lPrim := .F.
	EndIf
	
	// Detalhe do Tipo do Veiculo
	@nLin,000 PSAY "|"
	@nLin,011 PSAY "|"
	@nLin,016 PSAY _cTpVeic
	@nLin,024 PSAY "|"
	@nLin,027 PSAY _nViag
	@nLin,034 PSAY "|"
	@nLin,037 PSAY _nEntr
	@nLin,045 PSAY "|" 
	@nLin,047 PSAY _nPesBr  PICTURE "@E 9,999,999.99"
	@nLin,060 PSAY "|"
	@nLin,062 PSAY _nPesLiq PICTURE "@E 9,999,999.99"
	@nLin,075 PSAY "|"
	@nLin,076 PSAY _nKM     PICTURE "@E 9,999,999 "
	@nLin,087 PSAY "|"
	@nLin,090 PSAY _nFret   PICTURE "@E 9,999,999.99"
	@nLin,104 PSAY "|"
	@nLin,107 PSAY _nPerc
	@nLin,112 PSAY "|"
	@nLin,114 PSAY _nDesc   PICTURE "@E 9,999,999.99"
	@nLin,127 PSAY "|"
	@nLin,129 PSAY _nAcr    PICTURE "@E 9,999,999.99"
	@nLin,142 PSAY "|"
	_nLiq := ( _nFret + _nAcr ) - _nDesc
	@nLin,144 PSAY _nLiq    PICTURE "@E 9,999,999.99"
	@nLin,157 PSAY "|"
	_nTon := (_nLiq / _nPesLiq)*1000
	@nLin,159 PSAY _nTon    PICTURE "@E 999,999.99"
	@nLin,173 PSAY "|"
	nLin := nLin + 1

	// Controla total por Tipo de Veiculo (Tabela)
	aTotTabela[1]  += _nViag
	aTotTabela[2]  += _nEntr
	aTotTabela[3]  += _nPesBr
	aTotTabela[4]  += _nPesLiq
	aTotTabela[5]  += _nKm
	aTotTabela[6]  += _nFret
	aTotTabela[7]  += _nPerc
	aTotTabela[8]  += _nDesc
	aTotTabela[9]  += _nAcr
	aTotTabela[10] += _nLiq
	aTotTabela[11] := ( aTotTabela[06] / aTotTabela[04] )*1000

	// Zerando as variaveis
	_nViag     := 0	
	_nEntr     := 0
	_nPesBr    := 0
	_nPesLiq   := 0
	_nKM       := 0
	_nFret     := 0
	_nDesc     := 0
	_nAcr      := 0
	_nLiq      := 0
	_nTon      := 0
Return
			
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao   ³ PrintTotTab                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Impressao dos Totais por Tipo de Frete                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrintTotTab()	
	// Imprime Total do tipo

	@nLin,000 PSAY "|"+ Replicate ("=",172)+ "|"
	nLin := nLin + 1
	@nLin,000 PSAY "|"
	@nLin,002 PSAY "TOTAL"
	@nLin,008 PSAY _cTipo
	@nLin,011 PSAY "|"
	@nLin,016 PSAY "==>"
	@nLin,024 PSAY "|"
	@nLin,027 PSAY aTotTabela[1]
	@nLin,034 PSAY "|"
	@nLin,037 PSAY aTotTabela[2]
	@nLin,045 PSAY "|"                     
    @nLin,046 PSAY aTotTabela[3] PICTURE "@E 99,999,999.99"
	@nLin,060 PSAY "|"
	@nLin,061 PSAY aTotTabela[4]  PICTURE "@E 99,999,999.99"
    @nLin,075 PSAY "|" 	   
	@nLin,076 PSAY aTotTabela[5]  PICTURE "@E 9,999,999"
	@nLin,087 PSAY "|"
	@nLin,090 PSAY aTotTabela[6] PICTURE "@E 9,999,999.99"
	@nLin,104 PSAY "|"
	@nLin,107 PSAY aTotTabela[7]
	@nLin,112 PSAY "|"
	@nLin,114 PSAY aTotTabela[8] PICTURE "@E 9,999,999.99"
	@nLin,127 PSAY "|"
	@nLin,129 PSAY aTotTabela[9] PICTURE "@E 9,999,999.99"
	@nLin,142 PSAY "|"
	@nLin,144 PSAY aTotTabela[10] PICTURE "@E 9,999,999.99"
	@nLin,157 PSAY "|"
	@nLin,159 PSAY (aTotTabela[06]/aTotTabela[04])*1000 PICTURE "@E 999,999.99"
	@nLin,173 PSAY "|"
	nLin := nLin + 1
	@nLin,000 PSAY "|"+ Replicate ("=",172)+ "|"
	nLin := nLin + 1

	// Controla Totais por Tipo
	For i = 1 To 10
		aTotTipo[i] += aTotTabela[i]
		// Zera os Totais da Tabela
		aTotTabela[i] := 0
	Next
	aTotTipo[11]   := ( aTotTipo[06] / aTotTipo[4] )
	aTotTabela[11] := 0
	_lPrim := .T.
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao   ³PrintTotTipo                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Impressao do Total Geral do tipo de frete                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrintTotTipo()

	@nLin,000 PSAY "|"+ Replicate ("=",172)+ "|"
	nLin := nLin + 1
	@nLin,000 PSAY "|"
	@nLin,002 PSAY "   TOTAL GERAL  =>  "
	@nLin,024 PSAY "|"
	@nLin,027 PSAY aTotTipo[1]
	@nLin,034 PSAY "|"
	@nLin,037 PSAY aTotTipo[2]
	@nLin,045 PSAY "|"
	@nLin,046 PSAY aTotTipo[3] PICTURE "@E 99,999,999.99"
	@nLin,060 PSAY "|"
	@nLin,061 PSAY aTotTipo[4]  PICTURE "@E 99,999,999.99"
	@nLin,075 PSAY "|" 
	@nLin,076 PSAY aTotTipo[5]  PICTURE "@E 9,999,999"
	@nLin,087 PSAY "|"
	@nLin,090 PSAY aTotTipo[6] PICTURE "@E 9,999,999.99"
	@nLin,104 PSAY "|"
	@nLin,107 PSAY aTotTipo[7]
	@nLin,112 PSAY "|"
	@nLin,114 PSAY aTotTipo[8] PICTURE "@E 9,999,999.99"
	@nLin,127 PSAY "|"
	@nLin,129 PSAY aTotTipo[9] PICTURE "@E 9,999,999.99"
	@nLin,142 PSAY "|"
	@nLin,144 PSAY aTotTipo[10] PICTURE "@E 9,999,999.99"
	@nLin,157 PSAY "|"
	@nLin,159 PSAY (aTotTipo[06]/aTotTipo[04])*1000 PICTURE "@E 999,999.99"
	@nLin,173 PSAY "|"
	nLin := nLin + 1
	@nLin,000 PSAY "|"+ Replicate ("=",172)+ "|"
	nLin := nLin + 1

	// Controla Totais por Tipo de Frete
	For i = 1 To  10
		aTotTpFrete[i] += aTotTipo[i]
		// Zera os Totais da Tabela
		aTotTipo[i] := 0
	Next
	aTotTpFrete[11] := ( aTotTpFrete[04] / aTotTpFrete[4] )*1000 
	aTotTipo[11] := 0
	
	// Controla total por Tipo de Veiculo (Tabela)
	aTotGeral[1]  += aTotTipo[1]
	aTotGeral[2]  += aTotTipo[2]
	aTotGeral[3]  += aTotTipo[3]
	aTotGeral[4]  += aTotTipo[4]
	aTotGeral[5]  += aTotTipo[5]
	aTotGeral[6]  += aTotTipo[6]
	aTotGeral[7]  += aTotTipo[7]
	aTotGeral[8]  += aTotTipo[8]
	aTotGeral[9]  += aTotTipo[9]
	aTotGeral[10] += aTotTipo[10]
	aTotGeral[11] +=(aTotTipo[06] / aTotTipo[04] )*1000 
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AD0053B   ºAutor  ³Microsiga           º Data ³  12/18/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime Total Geral                                         º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Static Function PrintTotGeral()  

	@nLin,000 PSAY "|"+ Replicate ("=",172)+ "|"
	nLin := nLin + 1
	@nLin,000 PSAY "|"
	@nLin,002 PSAY "   TOTAL GERAL  =>  "
	@nLin,024 PSAY "|"
	@nLin,027 PSAY aTotGeral[1]
	@nLin,034 PSAY "|"
	@nLin,037 PSAY aTotGeral[2]
	@nLin,045 PSAY "|"
	@nLin,046 PSAY aTotGeral[3] PICTURE "@E 99,999,999.99"
	@nLin,060 PSAY "|"
	@nLin,061 PSAY aTotGeral[4] PICTURE "@E 99,999,999.99"
	@nLin,075 PSAY "|"
	@nLin,076 PSAY aTotGeral[5]  PICTURE "@E 9,999,999"
	@nLin,087 PSAY "|"
	@nLin,090 PSAY aTotGeral[6] PICTURE "@E 9,999,999.99"
	@nLin,104 PSAY "|"
	@nLin,107 PSAY aTotGeral[7]
	@nLin,112 PSAY "|"
	@nLin,114 PSAY aTotGeral[8] PICTURE "@E 9,999,999.99"
	@nLin,127 PSAY "|"
	@nLin,129 PSAY aTotGeral[9] PICTURE "@E 9,999,999.99"
	@nLin,142 PSAY "|"
	@nLin,144 PSAY aTotGeral[10] PICTURE "@E 9,999,999.99"
	@nLin,157 PSAY "|"
	@nLin,159 PSAY (aTotGeral[06]/aTotGeral[04])*1000 PICTURE "@E 999,999.99"
	@nLin,173 PSAY "|"
	nLin := nLin + 1
	@nLin,000 PSAY "|"+ Replicate ("=",172)+ "|"
	nLin := nLin + 1
Return 

//+-----------------------------+
//|seleciona as guias no SZI    |
//+-----------------------------+
Static Function QrySZI(cGuia)		
		cQuery1 := 	" SELECT ZI_GUIA, ZI_PLACA, ZI_DATALAN,ZI_TIPO, ZI_VALOR "
		cQuery1 +=	" FROM "+RetSQLName("SZI")+" "
		cQuery1 +=	" WHERE (ZI_DATALAN BETWEEN '"+DTOS(_dDtIni) +"' AND '"+DTOS(_dDtFim)+"')"
		cQuery1 +=	" AND D_E_L_E_T_=' ' AND "	
		cQuery1 +=	" ZI_GUIA IN( "
		cQuery1 +=	"	SELECT ZK_GUIA  "
		cQuery1 +=	"	FROM "+RetSqlName("SZK")+ "  WHERE (ZK_DTENTR BETWEEN '"+DTOS(_dDtIni) +"' AND '"+DTOS(_dDtFim)+"') AND ZK_TIPFRT ='"+ALLTRIM(_cTipFrt)+"' AND D_E_L_E_T_=' ' "
		cQuery1 +=	"	)
		cQuery1 +=	"	AND ZI_GUIA='"+cGuia+"' " 
		cQuery1 +=	" ORDER BY ZI_GUIA "
		TCQuery cQuery1 new alias "ZI1"
		DBSELECTAREA("ZI1")
		DBGOTOP()
Return
