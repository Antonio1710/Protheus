#INCLUDE "rwmake.ch"
#INCLUDE  "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATEST    บAutor  ณDANIEL              บ Data ณ  01/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFATURADO POR ESTADO                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPCP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


//+---------------------------------------------------+
//|Parametros                                         |
//+---------------------------------------------------+
//|MV_PAR01		-		DATA INICIAL                     |
//|MV_PAR02		-		DATA FINAL                       |
//|MV_PAR03		-		CONSIDERA A TES                  |
//|MV_PAR04		-		DESCONCIDERA OS TIPO DE NF       |
//+---------------------------------------------------+

User Function FATEST


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Vendas x Estado"
Local cPict          := ""
Local titulo       	:= "Vendas x Estado"
Local nLin         	:= 80

Local Cabec1       	:= ""
Local Cabec2       	:= ""
Local imprime      	:= .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "FATEST" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt      	:= Space(10)
Private cbcont     	:= 00
Private CONTFL     	:= 01
Private m_pag      	:= 01
Private wnrel      	:= "FATEST" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := ""    

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'FATURADO POR ESTADO')

Pergunte("FATEST",.F.)


//+-------------------+
//|Query              |
//+-------------------+
Private _xFilial:=xFilial("SD2")
Private cQuery:=""    

//+-------------------+
//|Descricoes         |
//+-------------------+
Private _cEstado  := ''
Private _nCodprod := ''
Private _cDescant := ''

//+-------------------+
//|Totais             |  
//+-------------------+
Private _nSqtd    := 0
Private _nStotal  := 0
Private _nSqtdev  := 0
Private _nSvldev  := 0

Private _nS1qtd   := 0
Private _nS1total := 0
Private _nS1qtdev := 0
Private _nS1vldev := 0 
Private _nCol		:= 0   

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

wnrel := SetPrint(cString,NomeProg,"FATEST",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

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
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  09/01/07   บฑฑ
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

Local nOrdem





//+-----------------------+
//|Montando Query         |
//+-----------------------+

cQuery+=" SELECT D2_EMISSAO, D2_EST , D2_COD, B1_DESC, D2_QUANT, D2_TOTAL, D2_QTDEDEV, D2_VALDEV, D2_TIPO, D2_TES "
cQuery+=" FROM "+RetSqlName("SD2")+ " SD2,"+RetSqlName("SB1")+ " "
cQuery+=" WHERE "
cQuery+=" B1_COD=D2_COD AND "
cQuery+=" D2_FILIAL='"+_xFilial+"' AND "
cQuery+=" (D2_EMISSAO between '"+DTOS(MV_PAR01)+"' AND  '"+DTOS(MV_PAR02)+"' )AND "
cQuery+=" SD2.D_E_L_E_T_= '' "
cQuery+=" AND "+RetSqlName("SB1")+ ".D_E_L_E_T_= '' "
cQuery+=" ORDER BY D2_EST + D2_COD "

TCQUERY cQuery NEW ALIAS "XEST"
DBSELECTAREA("XEST")
dbGoTop()           



//+----------------------------+
//|Imprimindo Relatorio        |
//+----------------------------+

While !EOF()
	
	//+-----------------------------------+
	//|Verificando o TES e o Tipo da Nota |
	//|Se devem ser considerados          |
	//+-----------------------------------+	
	If !(XEST->D2_TES $ MV_PAR03) .and. (XEST->D2_TIPO $ MV_PAR04)  
		dbSkip()
		Loop	
	EndIf    
	
	//+-------------------------+
	//|Cabecalho                |
	//+-------------------------+	
	If nLin > 55 
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 10
		@ nLin,001 PSAY  "|-----------------------------|------------------------------|-------------------------------|------------------------------|------------------------------|-------------------------------|------------------------------|"
		nLin ++
		@ nLin,001 PSAY  "|           Estado            |            Produto           |          Descricao            |          Quantidade          |            Valor             |         Qtd Devolvido         |        Valor Devolvido       |"
		nLin ++
		@ nLin,001 PSAY  "|-----------------------------|------------------------------|-------------------------------|------------------------------|------------------------------|-------------------------------|------------------------------|"
		nLin ++
	Endif
	

	
	If _nCodprod + _cESTado <> XEST->D2_COD + XEST->D2_EST
		
		If (_nS1qtd + _nS1total + _nS1qtdev + _nS1vldev) > 0
		
			//+-----------------------------+			
			//|Imprimindo Totai por Produto | 
			//+-----------------------------+
			_nCol := 1
			@nLin,_nCol PSAY "|" + SUBSTR ((_cESTado),1,5)
			_nCol += 30
			@nLin,_nCol PSAY "|" + (_nCodprod)
			_nCol += 31
			@nLin,_nCol PSAY "|" + _cDescant
			_nCol += 32
			@nLin,_nCol PSAY "|" + TRANSFORM(_nS1qtd,"@E 9999,999,999.99")
			_nCol += 31
			@nLin,_nCol PSAY "|" + TRANSFORM(_nS1total,"@E 9999,999,999.99")
			_nCol += 31
			@nLin,_nCol PSAY "|" + TRANSFORM(_nS1qtdev,"@E 9999,999,999.99")
			_nCol += 32
			@nLin,_nCol PSAY "|" + TRANSFORM(_nS1vldev,"@E 9999,999,999.99")
			_nCol += 31
			@nLin,_nCol PSAY "|"
			nLin++ 						// Avanca a linha de impressao  
			
			//Zerando Variaveis
			_nS1qtd   := 0
			_nS1total  := 0
			_nS1qtdev  := 0
			_nS1vldev  := 0
		Endif
	Endif
	
	
	If XEST->D2_EST <> _cESTado
		
		If (_nSqtd + _nStotal + _nSqtdev + _nSvldev) > 0
			
			//+--------------------------------+
			//|Soma por Estado                 |
			//+--------------------------------+
			@ nLin,001 PSAY   "|-----------------------------|------------------------------|-------------------------------|------------------------------|------------------------------|-------------------------------|------------------------------|"
			nLin++
			@ nLin,001 PSAY   "|           Total             |"
			@ nLin,062 PSAY   "|"
			@ nLin,094 PSAY   "|" + TRANSFORM(_nSqtd,  "@E 9999,999,999.99")
			@ nLin,125 PSAY   "|" + TRANSFORM(_nStotal,"@E 9999,999,999.99")
			@ nLin,156 PSAY   "|" + TRANSFORM(_nSqtdev,"@E 9999,999,999.99")
			@ nLin,188 PSAY   "|" + TRANSFORM(_nSvldev,"@E 9999,999,999.99")
			@ nLin,219 PSAY   "|"
			nLin ++
			@ nLin,001 PSAY   "|-----------------------------|------------------------------|-------------------------------|------------------------------|------------------------------|-------------------------------|------------------------------|"
			nLin++     
			
			//Zera as variaveis 
			_nSqtd    := 0
			_nStotal  := 0
			_nSqtdev  := 0
			_nSvldev  := 0
			
		Endif
		
	Endif

	_cESTado   := XEST->D2_EST
	_nCodprod  := XEST->D2_COD
	_cDescant  := XEST->B1_DESC

	//Acumula a soma por produto
	_nS1qtd   += XEST->D2_Quant
	_nS1total += XEST->D2_Total
	_nS1qtdev += XEST->D2_Qtdedev
	_nS1vldev += XEST->D2_Valdev
	
	//Acumula a soma por Estado
	_nSqtd    += XEST->D2_Quant
	_nStotal  += XEST->D2_Total
	_nSqtdev  += XEST->D2_Qtdedev
	_nSvldev  += XEST->D2_Valdev
	

	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Impressao do cabecalho do relatorio. . .                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	dbSkip() // Avanca o ponteiro do registro no arquivo
EndDo


//Imprime o ultimo total

If (_nS1qtd + _nS1total + _nS1qtdev + _nS1vldev) > 0 

	//Imprime o total por produto
	@ nLin,001 PSAY   "|-----------------------------|------------------------------|-------------------------------|------------------------------|------------------------------|-------------------------------|------------------------------|"
	_nCol := 1
	@nLin,_nCol PSAY "|" + SUBSTR ((_cESTado),1,5)
	_nCol += 30
	@nLin,_nCol PSAY "|" + (_nCodprod)
	_nCol += 31
	@nLin,_nCol PSAY "|" + XEST->B1_DESC
	_nCol += 32
	@nLin,_nCol PSAY "|" + TRANSFORM(_nS1qtd,"@E 9999,999,999.99")
	_nCol += 31
	@nLin,_nCol PSAY "|" + TRANSFORM(_nS1total,"@E 9999,999,999.99")
	_nCol += 31
	@nLin,_nCol PSAY "|" + TRANSFORM(_nS1qtdev,"@E 9999,999,999.99")
	_nCol += 32
	@nLin,_nCol PSAY "|" + TRANSFORM(_nS1vldev,"@E 9999,999,999.99")
	_nCol += 32
	@nLin,_nCol PSAY "|"
	nLin++ // Avanca a linha de impressao
	
	//Zera as variaveis 
	_nS1qtd   := 0
	_nS1total  := 0
	_nS1qtdev  := 0
	_nS1vldev  := 0
Endif

If (_nSqtd + _nStotal + _nSqtdev + _nSvldev) > 0
	
	//Imprime a soma por Estado
	@ nLin,001 PSAY   "|-----------------------------|------------------------------|-------------------------------|------------------------------|------------------------------|-------------------------------|------------------------------|"
	nLin++
	@ nLin,001 PSAY   "|           Total             |"
	@ nLin,062 PSAY   "|"
	@ nLin,094 PSAY   "|" + TRANSFORM(_nSqtd, "@E 9999,999,999.99")
	@ nLin,125 PSAY   "|" + TRANSFORM(_nStotal,"@E 9999,999,999.99")
	@ nLin,156 PSAY   "|" + TRANSFORM(_nSqtdev,"@E 9999,999,999.99")
	@ nLin,188 PSAY   "|" + TRANSFORM(_nSvldev,"@E 9999,999,999.99")
	@ nLin,219 PSAY   "|"
	nLin ++
	@ nLin,001 PSAY   "|-----------------------------|------------------------------|-------------------------------|------------------------------|------------------------------|-------------------------------|------------------------------|"
	
	
	//Zera as variแveis para uma nova soma por XESTado
	_nSqtd    := 0
	_nStotal  := 0
	_nSqtdev  := 0
	_nSvldev  := 0
		
	
Endif

If (_nSqtd + _nStotal + _nSqtdev + _nSvldev) > 0
   NLI++
	@ nLin,002 PSAY  "|-----------------------------|------------------------------|-------------------------------|------------------------------|------------------------------|-------------------------------|------------------------------|"
eNDIF	

DBCLOSEAREA("XEST")
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

Return
