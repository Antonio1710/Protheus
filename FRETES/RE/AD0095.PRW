#INCLUDE "rwmake.ch"
// // // RFRT521  ==
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AD0095   º Autor ³ Gustavo Gonela     º Data ³  17/01/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Fechamento por Veiculo / Transportadora                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Logistica                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function AD0095


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // Data de                              |
//³ mv_par02             // Data ate                             ³
//| mv_par03             // Transportadora de                    |
//³ mv_par04             // Transportadora ate                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fechamento por Veiculo / Transportadora')

cPerg   := "AD0095"
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cDesc1       := "Este programa tem como objetivo imprimir relatorio "
cDesc2       := "de acordo com os parametros informados pelo usuario."
cDesc3       := "Fechamento Veiculo / Transportadora"
cPict        := ""
titulo       := "Fechamento Veiculo / Transportadora"
nLin         := 65
Cabec1       := ""
Cabec2       := ""
imprime      := .T.
aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 132
Private tamanho      := "P"
Private nomeprog     := "AD0095" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "AD0095" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := "SZK"


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
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  18/07/03   º±±
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

dbSelectArea(cString)
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetRegua(RecCount())

// Parametros
_dDtEntr  := mv_par01
_dDtEntr2 := mv_par02
_cTransp  := mv_par03
_cTransp2 := mv_par04
_cTipFrt  := mv_par05

// Variaveis de Trabalho
_nTotFret   := 0
_nTotPeso   := 0
_nEntr      := 0
_nViag      := 0
_nTotEntr   := 0
_ntTKmpag   := 0
_nTotAcres  := 0
_nTotDesc   := 0
_nTotFret   := 0
_nTotPeso   := 0
_nTotEntr   := 0


//Cabec3  := SPACE(02)+ "Periodo de : " + substr(DTOS(_dDtEntr),7,2)+ "/" + substr(DTOS(_dDtEntr),5,2)+ "/" + substr(DTOS(_dDtEntr),1,4)+ SPACE(5) +  "Ate : " + substr(DTOS(_dDtEntr2),7,2)+ "/" + substr(DTOS(_dDtEntr2),5,2)+ "/" + substr(DTOS(_dDtEntr2),1,4)
//Cabec4  := "Transportador: " + _cTransp_Tit + SPACE(05) +"Veiculo : " + _cVeic_Tit
//Cabec5  := "|-----------------------------------------------------------------------------------------------------------------------------------------------|"
//Cabec6  := "|   DATA    |      TOTAL FRETE       |      PESO       |  ENTR.  |      KM      |       DESCRICAO       |     ACRESCIMO     |     DESCONTO      |"
//Cabec7  := "|-----------------------------------------------------------------------------------------------------------------------------------------------|"

//Cabec7  := "|=============================================================================================================================================|"
//Cabec8  := "|=============================================================================================================================================|"
//Cabec9  := "|=============================================================================================================================================|"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicionamento do primeiro registro e loop principal. Pode-se criar ³
//³ a logica da seguinte maneira: Posiciona-se na filial corrente e pro ³
//³ cessa enquanto a filial do registro for a filial corrente. Por exem ³
//³ plo, substitua o dbGoTop() e o While !EOF() abaixo pela sintaxe:    ³
//³                                                                     ³
//³ dbSeek(xFilial())                                                   ³
//³ While !EOF() .And. xFilial() == A1_FILIAL                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Cabec1  := SPACE(02)+ "Periodo de : " + substr(DTOS(_dDtEntr),7,2)+ "/" + substr(DTOS(_dDtEntr),5,2)+ "/" + substr(DTOS(_dDtEntr),1,4)+ SPACE(5) +  "Ate : " + substr(DTOS(_dDtEntr2),7,2)+ "/" + substr(DTOS(_dDtEntr2),5,2)+ "/" + substr(DTOS(_dDtEntr2),1,4)
//Cabec2  := SPACE(02)+ "Transportador: " + _cTransp + SPACE(07) +"Veiculo : " +_cVeic
Cabec3  := "|----------------------------------------------------------------------|"
Cabec4  := "|   DATA     |   TOTAL FRETE   |     PESO      |  ENTR.  |     KM      |"
Cabec5  := "|----------------------------------------------------------------------|"


Cabec6  := "|----------------------------------------------------------------------|"
Cabec7  := "|   DATA    |                           |   ACRESCIMO   |   DESCONTO   |"
Cabec8  := "|----------------------------------------------------------------------|"

Cabec9   := "Relacao dos Fretes"
Cabec10  := "Relacao dos Descontos e Acrescimos"

//          0         1         2         3         4         5         6         7         8         9         10        11        12        13        14
//          0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234


//Transportadora

_cVeic   := space(7)
_cTra    := space(6)

dbSelectArea("SA4")
dbSetOrder(1)  //   Indice Codigo
DbGoTop()
dbSeek(xFilial("SA4")+_cTransp,.T.)
Do While !EOF() .and. A4_COD >= _cTransp .and. A4_COD <= _cTransp2
	_cTra     := A4_COD
	_cVeicAnt := ''
	dbSelectArea("ZV4")
	dbSetOrder(3)  //   Indice Codigo
	dbSeek(xFilial("ZV4")+_cTra,.T.)
	Do While !EOF() .and. ZV4_FORNEC = _cTra
		
		_cVeic := ZV4_PLACA
		Cabec2  := SPACE(02)+ "Transportador : " + SA4->A4_COD + "  " + SUBSTR(SA4->A4_NOME,1,30) +SPACE(2)+"Veiculo : " + ZV4->ZV4_TIPVEI +" "+_cVeic
		If _cVeic <> _cVeicAnt 
			_cPri := 'S'
		Endif
		// Frete
		dbSelectArea("SZK")
		dbSetOrder(9)  //   Indice PlacaPg + Data Entrega
		dbSeek(xFilial("SZK")+ ZV4->ZV4_PLACA  + dtos(_dDtEntr),.T.)
		DO While !EOF ().and. ZK_PLACAPG = ZV4->ZV4_PLACA .and. DTOS(ZK_DTENTR) >= DTOS(_dDtEntr) .and. +;
			DTOS(ZK_DTENTR) <= DTOS(_dDtEntr2)
			//Despresa os Tipos de Frete que nao esta no parametro
			If !SZK->ZK_TIPFRT $_cTipFrt
				Dbskip()
				Loop
			ENDIF
			// Caso mudou a placa forco imprimir
			If nLin > 60 .OR. _cPri = 'S'                        
				_cPri := 'N'			
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
				@nLin,000 PSAY CABEC9
				nLin := nLin + 1
				@nLin,000 PSAY CABEC3
				nLin := nLin + 1
				@nLin,000 PSAY CABEC4
				nLin := nLin + 1
				@nLin,000 PSAY CABEC5
				nLin := nLin + 1
			Endif
			
			
			@nLin,000 PSAY "|"
			@nLin,002 PSAY SZK->ZK_DTENTR
			@nLin,013 PSAY "|"
			@nLin,016 PSAY SZK->ZK_VALFRET   Picture "@E 999,999.99"
			@nLin,031 PSAY "|"
			@nLin,033 PSAY SZK->ZK_PBRUTO    Picture "@E 999,999.99"
			@nLin,047 PSAY "|"
			_nEntr := SZK->ZK_ENTREGA - SZK->ZK_ENTRDEV
			@nLin,048 PSAY _nEntr Picture "@E 9999"
			@nLin,057 PSAY "|"
			@nLin,058 PSAY SZK->ZK_KMPAG     Picture "@E 999,999.99"
			@nLin,071 PSAY "|"
			nLin := nLin + 1
			
			_nTotFret   += ZK_VALFRET
			_nTotPeso   += ZK_PBRUTO
			_ntTKmpag   += ZK_KMPAG
			_nTotEntr   +=_nEntr
			_nViag      += 1
			_nEntr      := 0
			
			//SZK
			dbSelectArea("SZK")
			DbSkip()
		Enddo
		dbSelectArea("ZV4")
		If (_nTotFret + _nTotPeso + _nTotEntr + _ntTKmpag ) <> 0
			
			@nLin,000 PSAY "|"+ Replicate ("=",70)+ "|"
			nLin := nLin + 1
			@nLin,000 PSAY "|"
			@nLin,002 PSAY " TOTAL "
			@nLin,013 PSAY "|"
			@nLin,016 PSAY _nTotFret Picture "@E 999,999.99"
			@nLin,031 PSAY "|"
			@nLin,033 PSAY _nTotPeso  Picture "@E 999,999.99"
			@nLin,047 PSAY "|"
			@nLin,048 PSAY _nTotEntr  Picture "@E 9999"
			@nLin,057 PSAY "|"
			@nLin,058 PSAY _ntTKmpag   Picture "@E 999,999.99"
			@nLin,071 PSAY "|"
			nLin := nLin + 1
			@nLin,000 PSAY "|"+ Replicate ("=",70)+ "|"
			nLin := nLin + 1
			// Zerando as variaveis
			
			_nTotPeso   := 0
			_ntTKmpag   := 0
			_nTotEntr   := 0
			_nEntr      := 0
			_nViag      := 0
		Endif
		
		// Lancamento de desconto e acrescimo
		dbSelectArea("SZI")
		dbSetOrder(4) // FILIAL + PLACA + DATA LANCAMENTO
		dbSeek(xFilial("SZI")+ZV4->ZV4_PLACA + dtos(_dDtEntr),.T.)
		DO While !EOF ().and. ZI_PLACA = ZV4->ZV4_PLACA .and. DTOS(ZI_DATALAN) >= DTOS(_dDtEntr) .and. DTOS(ZI_DATALAN) <= DTOS(_dDtEntr2)
		//Verifica se o Tipo de Frete
		dbSelectArea("SZK")
		//Indice 2
		//ZK_FILIAL + ZK_GUIA  + ZK_DATA + ZK_PLACA
		dbSetOrder(2)
		If dbSeek(xFilial("SZK")+SZI->ZI_GUIA+DTOS(SZI->ZI_DATALAN)+SZI->ZI_PLACA,.T.)
			//Despresa os Tipos de Frete que nao esta no parametro
			If !SZK->ZK_TIPFRT $_cTipFrt
				dbSelectArea("SZI")
				Dbskip()
				Loop
			ENDIF
			dbSelectArea("SZI")
				
			IF TRIM(ZI_TIPO) = 'A'
				
				@nLin,000 PSAY "|"
				@nLin,002 PSAY ZI_DATALAN
				@nLin,012 PSAY "|"
				@nLin,040 PSAY "|"
				@nLin,041 PSAY ZI_VALOR Picture "@E 9,999,999.99"
				@nLin,056 PSAY "|"
				@nLin,057 PSAY 0 Picture "@E 9,999,999.99"
				@nLin,071 PSAY "|"
				_nTotAcres += ZI_VALOR
				nLin := nLin + 1
			ELSE
				If TRIM(ZI_TIPO) = 'D'
					
					@nLin,000 PSAY "|"
					@nLin,002 PSAY ZI_DATALAN
					@nLin,012 PSAY "|"
					@nLin,040 PSAY "|"
					@nLin,041 PSAY 0 Picture "@E 9,999,999.99"
					@nLin,056 PSAY "|"
					@nLin,057 PSAY ZI_VALOR Picture "@E 9,999,999.99"
					@nLin,071 PSAY "|"
					_nTotDesc += ZI_VALOR
					nLin := nLin + 1
				ENDIF
			ENDIF
			
			If nLin > 60  .and. _nTotDesc > 0
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
				@nLin,000 PSAY CABEC10
				nLin := nLin + 1
				@nLin,000 PSAY CABEC6
				nLin := nLin + 1
				@nLin,000 PSAY CABEC7
				nLin := nLin + 1
				@nLin,000 PSAY CABEC8
				nLin := nLin + 1
			Endif
			Endif
			// SZI
			dbSelectArea("SZI")
			Dbskip()
		Enddo
		If _nTotAcres <> 0 .or. _nTotDesc  <> 0
			
			@nLin,000 PSAY "|"+ Replicate ("=",70)+ "|"
			nLin := nLin + 1
			@nLin,000 PSAY "|"
			@nLin,002 PSAY "TOTAL"
			@nLin,012 PSAY "|"
			@nLin,040 PSAY "|"
			@nLin,041 PSAY _nTotAcres   Picture "@E 9,999,999.99"
			@nLin,056 PSAY "|"
			@nLin,057 PSAY _nTotDesc    Picture "@E 9,999,999.99"
			@nLin,071 PSAY "|"
			nLin := nLin + 1
			@nLin,000 PSAY "|"+ Replicate ("=",70)+ "|"
			nLin := nLin + 1
			@nLin,000 PSAY SPACE(2)+ "TOTAL A PAGAR "
			@nLin,021 PSAY _nTotFret+(_nTotAcres -_nTotDesc) Picture "@E 999,999.99"
			nLin := nLin + 1
			@nLin,000 PSAY Replicate ("_",72)
			nLin := 65
		Endif
		// Zerando as variaveis
		_nTotAcres := 0
		_nTotDesc  := 0
		_nTotFret  := 0
		// Impressao do Total do Veiculo
		dbSelectArea("ZV4")
		_cVeicAnt := ZV4_PLACA		
		Dbskip()
	Enddo
	// Total da Transportadora
	If _nViag <> 0
		@nLin,000 PSAY SPACE(2)+ "TOTAL DE VIAGENS "
		@nLin,021 PSAY _nViag
		nLin := nLin + 1
		@nLin,000 PSAY Replicate ("_",72)
		nLin := nLin + 2
	Endif
	dbSelectArea("SA4")
	Dbskip()
Enddo

dbCloseArea("SZI")
dbCloseArea("SZK")
dbCloseArea("ZV4")
dbCloseArea("SA4")

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



/*

			// Descontos e Acrescimos
			
			_nTotAcres := 0
			_nTotDesc  := 0
			
			
			@nLin,000 PSAY CABEC10
			nLin := nLin + 1
			@nLin,000 PSAY CABEC6
			nLin := nLin + 1
			@nLin,000 PSAY CABEC7
			nLin := nLin + 1
			@nLin,000 PSAY CABEC8
			nLin := nLin + 1


*/

