#INCLUDE "rwmake.ch"
#Define CRLF  Chr( 13 ) + Chr( 10 )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRomaneio  บ Autor ณ Ricardo Baldoni    บ Data ณ  24/12/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio enviado a expedicao para conferencia dos dados   บฑฑ
ฑฑบ          ณ da Devolucao                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Logistica                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function ROMANEIO(_cTyp)
                              
U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSalvo a Area para impressao em Browseณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
_aArea:=GetArea()
//RETIRADO POR RAFAEL EM 20071119 PORQUE CAUSA PROBLEMAS EM TODO SISTEMA
//	Putmv("MV_IMPSX1","N") //PARAMETRO - IMPRIME PERGUNTAS S/N

cPerg   := PADR("DEVOL2",10," ")



Private cString
_cPerg:=""
aOrd := {}
Private CbTxt        := ""
cDesc1         := "Este programa tem como objetivo imprimir relatorio "
cDesc2         := "de Romaneio de acordo com os parametros informados pelo usuario."
cDesc3         := "Relatorio de Romaneio"
cPict          := ""
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite           := 80
Private tamanho          := "M"
Private nomeprog         := "ROMANEIO.PRW" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18

Private aReturn          := { "Zebrado", 2, "Administracao", 2, 2, 1, "", 1}

Private nLastKey        := 0
titulo       := "Romaneio"
nLin         :=80

Cabec1       := SM0->M0_CODIGO+" "+SM0->M0_CODFIL+" "+SM0->M0_NOMECOM
Cabec2       := ""
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
imprime      := .T.
Private wnrel      := "ROMANEIO" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := "SZD"
aItens:={}



//Cabec11 := "|____________________________________|_____|_______________________|_______________________|_______________________|"
Cabec11 := "___________________________________________________________________________________________________________________________________"
Cabec12 := "|              PRODUTO                      | UNI.|     SAIDA       |     DEVOLVIDO       |     RECEBIDO          |      Quebra   |"
Cabec13 := "|                                           |     |CX.         PESO |CX.             PESO |CX.               PESO |       PESO    |"
Cabec14 := "|___________________________________________|_____|_________________|_____________________|_______________________|_______________|"
Cabec15 := "|                                           |     |                 |                     |                       |               |"
//                                   999,999,9999 99999,999.999 99999,999.99   9999.99
//         1 3            16 19     26           39            53           66            80




//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifico se estou imprimindo de um Browse, caso sim pego ณ
//ณo numero que estou posicionado                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If _cTyp=="B"
	mv_par01:=C5_NUM
	mv_par02:=1
Else
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
EndIf

wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd ,.T.,Tamanho,,.T.)
//Este 1o. .T. ,logo em seguida do Desc3, abilita a opcao de Impressao no Servidor/Cliente

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP5 IDE            บ Data ณ  24/12/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)


Local lQuebra := .F.
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SetRegua(RecCount())



If nLin > 68 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin :=8
Endif

aStru := {}

_cNumNf			:= Space(6)
_cSerie			:= Space(3)
_cCodCli		:= Space(6)
_cNomeCli		:= Space(20)
_dData			:= Space(8)
_cCodRespons	:= Space(6)
_cMotivo		:= Space(6)
_cAutNome		:= Space(20)
_cRespNome		:= Space(20)
_cDescMotiv		:= Space(20)
_cDevTotal		:= Space(1)
_cNumPedido		:= Space(6)
_cPlaca			:= Space(7)
_cRoteiro		:= Space(3)
_cSequencia		:= Space(2)
_cObs1			:= Space(80)


dbSelectArea("SZD")
dbSetOrder(2)
//dbSetOrder(1)

If DbSeek(xfilial("SZD")+ mv_par01)
	
	// primeiro verifica parametro pergunte
	lQuebra := MV_PAR02==1 //( (iif(MV_PAR02==1,.F.,.T.)) == (SZD->ZD_DEVTOT = "Q")) // SE QUEBRA, .T., SE NAO QUEBRA .T. :-)
	
	If lQuebra
		While !EOF() .and. alltrim(ZD_PEDIDO) == alltrim(mv_par01).AND. lQuebra
			
			_cNumNf			:= SZD->ZD_NUMNF
			_cSerie			:= SZD->ZD_SERIE
			_cCodCli		   := SZD->ZD_CODCLI
			_cNomeCli		:= SZD->ZD_NOMECLI
			_dData			:= dtos(SZD->ZD_DTDEV)
			_cCodRespons	:= SZD->ZD_RESPONS
			_cMotivo		   := SZD->ZD_MOTIVO
			_cAutNome		:= SZD->ZD_AUTNOME
			_cRespNome		:= SZD->ZD_RESPNOM
			_cDescMotiv		:= SZD->ZD_DESCMOT
			_cDevTotal		:= SZD->ZD_DEVTOT
			_cNumPedido    := SZD->ZD_PEDIDO
			_cPlaca   		:= SZD->ZD_PLACA
			_cRoteiro  		:= SZD->ZD_ROTEIRO
			_cSequencia		:= SZD->ZD_SEQUENC
			_cObs1			:= SZD->ZD_OBSER   //SZD->ZD_OBSHST
			
			DbSkip()
		ENDDO
	Else
		While !EOF() .and. alltrim(ZD_PEDIDO) == alltrim(mv_par01)//.AND. lQuebra
			
			_cNumNf			:= SZD->ZD_NUMNF
			_cSerie			:= SZD->ZD_SERIE
			_cCodCli		   := SZD->ZD_CODCLI
			_cNomeCli		:= SZD->ZD_NOMECLI
			_dData			:= dtos(SZD->ZD_DTDEV)
			_cCodRespons	:= SZD->ZD_RESPONS
			_cMotivo		   := SZD->ZD_MOTIVO
			_cAutNome		:= SZD->ZD_AUTNOME
			_cRespNome		:= SZD->ZD_RESPNOM
			_cDescMotiv		:= SZD->ZD_DESCMOT
			_cDevTotal		:= SZD->ZD_DEVTOT
			_cNumPedido    := SZD->ZD_PEDIDO
			_cPlaca   		:= SZD->ZD_PLACA
			_cRoteiro  		:= SZD->ZD_ROTEIRO
			_cSequencia		:= SZD->ZD_SEQUENC
			_cObs1			:= SZD->ZD_OBSER   //SZD->ZD_OBSHST
			
			DbSkip()
		ENDDO
		
	EndIf
	
	dbSelectArea("SZX")
	dbSetOrder(1)
	If DbSeek(xFilial("SZX")+_cNumNf+_cSerie)
		While !EOF() .and. alltrim(ZX_NF) == alltrim(_cNumNf) .and. alltrim(ZX_SERIE) == alltrim(_cSerie)
			
			if lQuebra .or. (!lQuebra .and. ZX_QTDEV2U > 0)
				_cCodProd	:= substr(ZX_CODPROD,1,6)
				_cDescProd	:= substr(ZX_DESCRIC,1,30)
				_cQtde		:= str(ZX_QTDE,11,2)
				_cQtdeDevol	:= str(ZX_QTDEV2U,11,2)
				_cUm		   := ZX_UNIDADE
				_cSegum		:= ZX_SEGUM
				_cQtdeSegum	:= str(ZX_QTSEGUM,11,2)
				//			_cAux		:= ZX_QTDEV2U * 18
				//_cAux		:= ZX_QTDEV2U * (ZX_QTDE / ZX_QTSEGUM)
				_cAux		:= ZX_QTDE
				_cQtdUm		:= str(_cAux,11,2)
				_nQuebra       := ZX_QUEBRA
				aadd(aItens,{_cCodProd,_cDescProd,_cQtde,_cQtdeDevol,_cUm,_cSegum,_cQtdeSegum,_cQtdUm,_nQuebra,.F.})
				//              1         2          3      4           5    6       7           8
			endif
			DBSkip()
		End
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica o cancelamento pelo usuario...                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		//	Exit
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Impressao do cabecalho do relatorio. . .                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
		//	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
	
	
	nLin:=8
	
	//Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	
	@nLin,000 PSAY "Cliente     : "+_cCodCli+Space(3)+_cNomeCli
	@nLin,050 PSAY "Data De devolucao: "+substr(_dData,7,2)+"/"+substr(_dData,5,2)+"/"+substr(_dData,1,4)
	nLin++
	@nLin,000 PSAY "Num Pedido  : "+_cNumPedido
	@nLin,050 PSAY "Nota Fiscal : "+_cNumNf+"/"+_cSerie
	nLin++
	@nLin,000 PSAY "Entrega     : "+_cRoteiro
	@nLin,050 PSAY "Sequencia   : "+_cSequencia
	nLin++
	@nLin,000 PSAY "Placa       : "+_cPlaca
	nLin:=nLin+2
	
	@nLin,000 PSAY "Autorizacao : "+_cAutNome
	nLin++
	@nLin,000 PSAY "Responsavel : "+_cCodRespons+Space(2)+_cRespNome
	If _cDevTotal = "T"
		@nLin,050 PSAY "'DEVOLUCAO TOTAL'"
	ElseIf _cDevTotal = "P"
		@nLin,050 PSAY "'DEVOLUCAO PARCIAL'"
	ElseIf _cDevTotal = "Q"
		@nLin,050 PSAY "'Ocorrencias de QUEBRA'"
	Else
		@nLin,050 PSAY "'Ocorrencias do Atendimento'"
	Endif
	nLin++
	@nLin,000 PSAY "Motivo      : "+_cMotivo+Space(2)+_cDescMotiv
	nLin++
	
	nLin := nLin + 1 // Avanca a linha de impressao
	@nLin,000 PSAY Cabec11
	nLin++
	@nLin,000 PSAY Cabec12
	nLin++
	@nLin,000 PSAY Cabec13
	nLin++
	@nLin,000 PSAY Cabec14
	nLin++
	@nLin,000 PSAY Cabec15
	nLin++
	For _I:=1 to len(aItens)
		//	aadd(aItens,{_cCodProd,_cDescProd,_cQtde,_cQtdeDevol,_cUm,_cSegum,_cQtdeSegum,_cQtdeDevol1u,.F.})
		@nLin,000 PSAY "|"
		@nLin,002 PSAY aItens[_I][1]	 // _cCodProd
		@nLin,010 PSAY aItens[_I][2]	 // _cDescProd
		@nLin,044 PSAY "|"  //37
		@nLin,046 PSAY aItens[_I][6]	 //_cSegum  40
		@nLin,050 PSAY "|"  //43
		@nLin,052 PSAY alltrim(aItens[_I][7])	//_cQtdeSegum  44
		@nLin,060 PSAY alltrim(aItens[_I][3])	//_cQtde
		@nLin,068 PSAY "|"
		@nLin,070 PSAY alltrim(aItens[_I][4])   //_cQtdeDevol
		@nLin,082 PSAY alltrim(aItens[_I][8])   //_cQtdeDevol*18//
		@nLin,090 PSAY "|"+Space(2)+replicate("-",9)
		@nLin,103 PSAY replicate("-",9)
		@nLin,114 PSAY "|"
		IF lQuebra
			@nLIn,117 Psay aItens[_I][9] Picture "@E 9,999.99999"
		endIF
		@nLin,130 PSAY "|"
		nLin++
		@nLin,000 PSAY "|"
		@nLin,044 PSAY "|"
		@nLin,050 PSAY "|"
		@nLin,068 PSAY "|"
		@nLin,090 PSAY "|"
		@nLin,114 PSAY "|"
		@nLin,130 PSAY "|"
		nLin++
	Next
	
	@nlin,000 PSAY REPLICATE("_",132)
	nLin:=nLin+3
	col:=007
    /*
	TEXTO:=''
	col:=007
	
	For I:=0 to LEN(_cObs1)
		TEXTO+=SUBSTR(_cObs1,I,1)
		
		If nLin > 68
			nLin :=10
		Endif
		
		// Exclui o caracter posicionado
		If chr(13)== SUBSTR(_cObs1,I,1) .or. chr(10)== SUBSTR(_cObs1,I,1)
			@ nlin,col Psay TEXTO
			TEXTO:=""
			I++
			nlin++
		Endif
	Next
	
	
	rTAMANHO:=LEN(ALLTRIM(TEXTO))
	INICIO:=1
	FIM:=80
	
	@ nlin,COL Psay SUBSTR(ALLTRIM(TEXTO),INICIO,FIM)
	
	IF rTAMANHO>FIM
		rTAMANHO:=rTAMANHO-FIM
		INICIO:=INICIO+FIM
		WHILE !EMPTY(rTAMANHO)
			NLIN:=NLIN+1
			@ nlin,COL Psay SUBSTR(ALLTRIM(TEXTO),INICIO,FIM)
			INICIO:=INICIO+FIM
			rTAMANHO:=rTAMANHO-FIM
			IF rTAMANHO<0
				rTAMANHO:=0
			ENDIF
			
		END
	ENDIF
	
	*/
	
    &&Mauricio - MDS TEC - 07/08/13 - a parte abaixo se encontrava comentada.....
	nLinhasMemo := MLCOUNT(_cObs1,100)
	For LinhaCorrente := 1 To nLinhasMemo       

		If nLin > 68
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin :=8
		Endif
		
		@ nlin,col Psay MemoLine(_cObs1,100,LinhaCorrente)
		nlin++
	Next
	
	nLin:=nLin+4
	If nLin > 68
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin :=8
	Endif

	@nLin,010 PSAY "Expedicao: "+replicate("_",40)
	
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

//Putmv("MV_IMPSX1","S")
RestArea(_aArea)
Return
