#INCLUDE "rwmake.ch"
#Include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ?AD0037   ?Autor ?Ricardo Saltorato                         ?Data ?01/12/05    º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ?Comparativo de Vendas                                                             º±?
±±?         ?SP x Interestadual                                                                º±?
±±?         ?                                                                                  º±?
±±?         ?                                                                                  º±?
±±?         ?AZ6 - > TABELA BASE DO RELATORIO (NAO NORMALIZADA)                                º±?
±±?         ?AZ8 - > TABELA DE VALORES FATURADOS PARA AS REDES                                 º±?
±±?         ?AZF - > TABELA BASE PARA IMPRESSAO DO RELATORIO                                   º±?
±±?         ?                                                                                  º±?
±±?         ?                                                                                  º±?
±±?         ?Alteracoes                                                                        º±?
±±?         ?==========                                                                        º±?
±±?         ?                                                                                  º±?
±±?         ?Data       Descricao                                                  Analista    º±?
±±?         ?---------- --------------------------------------------------------   ----------  º±?
±±?         ?06/02/2006 Incluido controle de versao;                               Ricardo     º±?
±±?         ?07/02/2006 Incluida verificacao de consulta sem                                   º±?
±±?         ?           retorno (periodo sem venda);                               Ricardo     º±?
±±?         ?07/02/2006 Incluida pergunta grava dados na tabela (sim ou nao)                   º±?
±±?         ?           para armazenar ou nao os dados nas tabelas utilizadas      Ricardo     º±?
±±?         ?           para o relatorio;                                                      º±?
±±?         ?07/02/2006 Implementado controle de grupos a imprimir;                Ricardo     º±?
±±?         ?09/02/2006 Implementado consistencia CIF / FOB. Quando o frete                    º±?
±±?         ?           for CIF desconta o valor do frete do ZBZ_PUL e se o frete               º±?
±±?         ?           for FOB, nao deve descontar o valor do frete;              Ricardo     º±?
±±?         ?01/06/2007 Correcao do tratamento do tipo de frete no calculo do      Daniel      º±?
±±?         ?           preco liquido                                                          º±?
±±?         ?                                                                                  º±?
±±?         ?07/08/2017 - troca das tabelas                                                    º±?
±±?         ?ZBX - > TABELA BASE DO RELATORIO (NAO NORMALIZADA)                                º±?
±±?         ?ZBY - > TABELA DE VALORES FATURADOS PARA AS REDES                                 º±?
±±?         ?ZBZ - > TABELA BASE PARA IMPRESSAO DO RELATORIO                                   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ?Faturamento                                                                       º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function AD0037()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Declaracao de Variaveis                                             ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?

Local   cDesc1       := "Este programa tem como objetivo imprimir relatorio "
Local   cDesc2       := "de acordo com os parametros informados pelo usuario."
Local   cDesc3       := "Comparativo de Vendas SP x Interestadual"
Local   cPict        := ""
Local   titulo       := "Comparativo de Vendas SP x Interestadual"
Local   nLin         := 80

Local   Cabec1       := ""
Local   Cabec2       := ""
Local   imprime      := .T.
Local   aOrd := {}

Local _cRet := ""

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Comparativo de Vendas SP X INTERESTADUAL')

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 220                          // 132 PARA CONDENSADO RETRATO, 220 PARA PAISAGEM COMPACTADO
Private tamanho      := "G"                          // P, M PARA RETRATO, G PARA PAISAGEM
Private nomeprog     := "AD0037_v6" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 15
Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "AD0037_" + DtoS(DDataBase)  // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString      := "ZBX"

Private cPerg        := ""                           // Contem o nome da relacao de perguntas no arquivo de perguntas
Private _nVersao     := "01"                         // Controla o numero da versao do relatorio
Private _FlagVer     := .F.   
Private _cGrup_Canc  := ''

// +-----------------------------------+
// | Cria Array com Estados Utilizados |
// +-----------------------------------+
public aEstados := {}
// +----------------------------------+
// | Cria Array com Grupos Utilizados |
// +----------------------------------+
PUBLIC aGrupos := {}   

// +-------------------------------------------+
// | Cria Matriz com Grupos a serem cancelados |
// +-------------------------------------------+
Public CancelaGrupo  := {}
Public ContaCaracter := 1
Public xxVarGrupo    := ""

// +-------------------------------------------------------------+
// | Faz Pergunta para selecionar parametros usados no relatorio |
// +-------------------------------------------------------------+
// | mv_par01 - Data de ...                                      |
// | mv_par02 - Data ate ...                                     |
// | mv_par03 - Do grupo ...                                     |
// | mv_par04 - Ate grupo ...                                    |
// | mv_par05 - Grava relatorio no banco (s/n)                   |
// | mv_par06 - Frete real ou frete tabela...                    |
// | mv_par07 - Exclui grupos ...                                |
// | mv_par08 - Continuacao grupos excluidos...                  |//incluido por ADriana em 18/08/2010 chamado 007709 e 007708
// | mv_par09 - Continuacao grupos excluidos...                  |//incluido por ADriana em 18/08/2010 chamado 007709 e 007708
// | mv_par10 - Continuacao grupos excluidos...                  |//incluido por ADriana em 18/08/2010 chamado 007709 e 007708
// +-------------------------------------------------------------+

cPerg := "AD0037"
Pergunte(cPerg, .T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Monta a interface padrao com o usuario...                           ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Processamento. RPTSTATUS monta janela com a regua de processamento. ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem


// +-------------------------------------------------------------------+
// | Efetua controle de Versao                                         |
// | Se nao houve impressao para o periodo informado nos parametros    |
// | mv_par01 e mv_par02, imprime primeira versao do relatorio, caso   |
// | ja exista uma impressao, incrementa a versao.                     |
// +-------------------------------------------------------------------+
If mv_par05 == 1
	ZBX->(DbSetOrder(8)) // Indexa por ZBX_FILIAL, ZBX_DTINI, ZBX_DTFIM, ZBX_VERSAO, ZBX_CODGRP, ZBX_ESTADO, R_E_C_N_O_, D_E_L_E_T_
	ZBX->(DbGoTop())
	If ZBX->(RecCount()) > 0
		While _FlagVer == .F.
			If ZBX->(DbSeek(xFilial("ZBX") + dtos(mv_par01) + dtos(mv_par02) + _nVersao))
				_nVersao := iIf(Len(AllTrim(Str(Val(ZBX->ZBX_VERSAO) + 1))) > 1, AllTrim(Str(Val(ZBX->ZBX_VERSAO) + 1)), "0" + AllTrim(Str(Val(ZBX->ZBX_VERSAO) + 1)))
			Else
				_FlagVer := .T.
			Endif
		EndDo
	Endif
Else
	_nVersao := "NO"
// +------------------------------------------------------------------------------+
// | Limpa os registros marcados como temporarios utilizando comando SQL Truncate |
// | Forco limpar antes de processar
// +------------------------------------------------------------------------------+
	TcSqlExec("DELETE FROM " + RetSqlName("ZBX") + " WHERE ZBX_DTINI = '" + dtos(mv_par01) + "' AND ZBX_DTFIM = '" + dtos(mv_par02) + "' AND ZBX_VERSAO = 'NO'")
	TcSqlExec("DELETE FROM " + RetSqlName("ZBY") + " WHERE ZBY_DTINI = '" + dtos(mv_par01) + "' AND ZBY_DTFIM = '" + dtos(mv_par02) + "' AND ZBY_VERSAO = 'NO'")
	TcSqlExec("DELETE FROM " + RetSqlName("ZBZ") + " WHERE ZBZ_DTINI = '" + dtos(mv_par01) + "' AND ZBZ_DTFIM = '" + dtos(mv_par02) + "' AND ZBZ_VERSAO = 'NO'")
Endif

//MONTA MINHAS MENSAGENS NA TELA COM A REGUA
   	 	bBloco := {|lEnd| PrcRecs ()}
		MsAguarde(bBloco,"Aguarde, Gerando Relatorio","Processando...",.T.)  

&&Mauricio - 02/05/17 - adicionado tipo do cliente e percentual tributo
DbSelectArea("ZBZ")
ZBZ->(DbSetOrder(1)) // filial + data inicio + data fim + versao + codigo do grupo + estado

SetRegua(RecCount())

// +------------------------------------------------------------------+
// | Declara as variaveis utilizadas durante a impressao do relatorio |
// +------------------------------------------------------------------+
Private vEstado      := {}  // Matriz que armazena os estados que serao impressos em ordem alfabetica forcando primeiro o estado de SP
Private aTotLin      := {}
Private aResPMF      := {}  // Matriz com resumos de preco medio e frete

Private _Conta       := 1   // Variave utilizada como contador em estruturas de repeticao
Private _PosI        := 1   // Coluna Inicial da pagina para controle das linhas de detalhe
Private _PosF        := 4   // Coluna Final da pagina para controle das linhas de detalhe
Private _Coluna      := 0   // Coluna Inicial para Impressao
Private ContaEst     := 1   // Conta Esdados
Private ContaGru     := 1   // Conta Grupos
Private SeqEst       := 1   // Conta Estados
Private SeqGrp       := 1   // Conta Grupos
Private _PosIc       := 1   // Coluna Inicial da pagina para controle da impressao do cabecalho
Private _PosFc       := 4   // Coluna Final da pagina para controle da impressao do cabecalho
Private _TotPes1     := 0   // Acumulador de Peso
Private _PXDif1      := 0   // Acumula Peso multiplicado pela diferenca por estado
Private _TotPes2     := 0   // Acumulador de Peso
Private _PXDif2      := 0   // Acumula Peso multiplicado pela diferenca por estado
Private _TotPes3     := 0   // Acumulador de Peso
Private _PXDif3      := 0   // Acumula Peso multiplicado pela diferenca por estado
Private _TotPes4     := 0   // Acumulador de Peso
Private _PXDif4      := 0   // Acumula Peso multiplicado pela diferenca por estado
Private _TPes1       := 0
Private _TPes2       := 0
Private _TPes3       := 0
Private _TPes4       := 0
Private _FrtTbl1     := 0
Private _FrtTbl2     := 0
Private _FrtTbl3     := 0
Private _FrtTbl4     := 0
Private _AGrupo      := ""
Private _APeso       := 0
Private _nValor      := 0
Private _PndTotB     := 0
Private _PndTotL     := 0
Private _PndDif      := 0
Private _PosTotL     := 0
Private _SQtdPMF     := 0
Private _SVlrPM      := 0
Private _SVlrF       := 0
Private _AcumFat     := 0     // Acumulador de Valor Faturado
Private _AcumDes     := 0     // Acumulador de Desconto
Private _AcumQtd     := 0     // Acumulador de Quantidade
Private _FlagPMF     := .F.   // Flag para fim de preco medio e frete
Private _FlagRD      := .F.   // Flag para fim de redes
Private _FlagIT      := .F.   // Flag para fim de impressao de totais
Private _FimIT       := .F.   // Flag para fim de impressao de totais  
Private	_PosIc2		 := 1



// +----------------------------------------------------------------------------+
// | Prepara a matriz vEstado contendo primeiro o estado de sp depois os outros |
// | em order alfabetica                                                        |
// +----------------------------------------------------------------------------+
AADD(vEstado, {"SP"}) // Defino a Primeira posicao como SP na Primeira vez

While _Conta < (Len(aEstados))
	If aEstados[_Conta][1] <> "SP"
		AADD(vEstado, {aEstados[_Conta][1]})
	Endif
	_Conta := _Conta + 1
EndDo

// +-------------------------------------------------------------------------------------------+
// | > > > > > > > > > >          Inicia a Impressao do Relatorio          < < < < < < < < < < |
// +-------------------------------------------------------------------------------------------+
While SeqEst <= Len(vEstado)
	
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	ZBZ->(DbGoTop())
	
	// +---------------------+
	// | Imprime o Cabecalho |
	// +---------------------+
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@ PRow() + 2, _Coluna PSay "Periodo: " + DtoC(mv_par01) + " ~ " + DtoC(mv_par02)
	If _nVersao == "NO"
	   @ PRow()    , _Coluna + 50 PSay "ATENCAO! Informacoes nao persistidas na base de dados."
	Else   
       @ PRow()    , _Coluna + 50 PSay "Versao: " + _nVersao
	Endif
	@ PRow() + 2, _Coluna PSay "+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	@ PRow() + 1, _Coluna PSay "|                                 |"
	
	_Coluna := 57
	
	If (Len(vEstado) - _PosIc) < 4     &&Mauricio 29/11/11 - Trazido if abaixo para antes do while em função de erro no array qdo ha menos do que 4 estados nele.
		_PosFc := Len(vEstado)
	Else
		_PosFc := _PosIc + 3
	Endif
	
  	While _PosIc <= _PosFc
		@ PRow(), _Coluna PSay vEstado[_PosIc][1] + "                   |"
		_Coluna := _Coluna + 44
		_PosIc := _PosIc + 1
	EndDo
	
	// +---------------------+
	// | Checa Fim Cabecalho |
	// +---------------------+
	//If (Len(vEstado) - _PosIc) < 4
	//	_PosFc := Len(vEstado)
	//Else
	//	_PosFc := _PosIc + 3
	//Endif
	
	_Coluna := 0
	
	@ PRow() + 1, _Coluna PSay "|          Grupo                  |   Peso   |   Real    | Vl. Liq. |   Dif.  |   Peso   |   Real    | Vl. Liq. |   Dif.  |   Peso   |   Real    | Vl. Liq. |   Dif.  |   Peso   |   Real    | Vl. Liq. |   Dif.  |"
	@ PRow() + 1, _Coluna PSay "+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	//                          0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//                                    10        20        30        40        50        60        70        80        90        100       110       120       130       140       150       160       170       180       190       200       210
	
	// +------------------------------+
	// | Imprime as linhas de detalhe |
	// +------------------------------+

	While SeqGrp <= Len(aGrupos) 
	
		If PRow() > 65
		     	 
   			@ PRow() + 1, _Coluna PSay "+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"			
			// +---------------------+
			// | Imprime o Cabecalho |
			// +---------------------+
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			@ PRow() + 2, _Coluna PSay "Periodo: " + DtoC(mv_par01) + " ~ " + DtoC(mv_par02)
			If _nVersao == "NO"
			   @ PRow()    , _Coluna + 50 PSay "ATENCAO! Informacoes nao persistidas na base de dados."
			Else   
		       @ PRow()    , _Coluna + 50 PSay "Versao: " + _nVersao
			Endif
			@ PRow() + 2, _Coluna PSay "+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
			@ PRow() + 1, _Coluna PSay "|                                 |"
	
			_Coluna := 57
	                			         
			If (Len(vEstado) - _PosIc2) < 4     &&Mauricio 29/11/11 - Trazido if abaixo para antes do while em função de erro no array qdo ha menos do que 4 estados nele.
				_PosFc := Len(vEstado)
			Else
				_PosFc := _PosIc2 + 3
			Endif
				  				
		  	While _PosIc2 <= _PosFc
				@ PRow(), _Coluna PSay vEstado[_PosIc2][1] + "                   |"
				_Coluna := _Coluna + 44
				_PosIc2 := _PosIc2 + 1
			EndDo 			
	
			_Coluna := 0
	
			@ PRow() + 1, _Coluna PSay "|          Grupo                  |   Peso   |   Real    | Vl. Liq. |   Dif.  |   Peso   |   Real    | Vl. Liq. |   Dif.  |   Peso   |   Real    | Vl. Liq. |   Dif.  |   Peso   |   Real    | Vl. Liq. |   Dif.  |"
			@ PRow() + 1, _Coluna PSay "+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
			//                          0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
			//                                    10        20        30        40        50        60        70        80        90        100       110       120       130       140       150       160       170       180       190       200       210		
		
		Endif
		
		// +----------------------------------------------------------------------------------------------------------+
		// |_GrupoI ->Grupo a imprimir segue sequencia da matriz aGrupos que contem todos os grupos a serem impressos |
		// +----------------------------------------------------------------------------------------------------------+
		_GrupoI  := aGrupos[ContaGru][1]
		// +----------------------------------------------------------------------------------------------------------------------+
		// | _EstadoI -> Estado a imprimir segue sequencia da matriz aEstados que contem todos os estados que devem ser impressos |
		// +----------------------------------------------------------------------------------------------------------------------+
		_EstadoI := vEstado[ContaEst][1]
		
		_cGrupoI := _GrupoI
		_cDesGrp := Left(aGrupos[ContaGru][2], 23)
		
		// +----------------------------------------------------+
		// | Procura pelo primeiro grupo e pelo primeiro estado |
		// +----------------------------------------------------+
		If ZBZ->(DbSeek(xFilial("ZBZ") + DTOS(mv_par01) + DTOS(mv_par02) + _nVersao + _cGrupoI + _EstadoI))
			// +-------------------+
			// | Localizou imprime |
			// +-------------------+
			_nPeso   := ZBZ->ZBZ_QTDVEN - ZBZ->ZBZ_QTDDEV
			_nPUB    := ZBZ->ZBZ_PUB
			_nPUL    := ZBZ->ZBZ_PUL
			_nDifSP  := ZBZ->ZBZ_DIFSP
			_nValor  := (ZBZ->ZBZ_VLRVEN - ZBZ->ZBZ_VLRDEV)
			_nFrete  := ZBZ->ZBZ_VLRFRT
		Else
			// +---------------------+
			// | Nao localizou, zera |
			// +---------------------+
			_nPeso   := 0
			_nPUB    := 0
			_nPUL    := 0
			_nDifSP  := 0
			_nValor  := 0
			_nFrete  := 0
		Endif
		If _cGrupoI $ _cGrup_Canc
		//If Ascan(CancelaGrupo, {|x| x[1] == _cGrupoI}) <> 0
			@ PRow() + 1, _Coluna PSay "| *" + _cGrupoI                   // Codigo do grupo
		Else
			@ PRow() + 1, _Coluna PSay "|  " + _cGrupoI                   // Codigo do grupo
		Endif
		@ PRow(), _Coluna + 9 PSay _cDesGrp                              // Descricao do grupo
		@ PRow(), _Coluna + 34 PSay "|"
		
		_PosI := 1
		
		// +-----------+
		// | Checa Fim |
		// +-----------+
		If (Len(vEstado) - SeqEst) < 4
			_PosF := (Len(vEstado) - SeqEst) + 1
		Endif
		
		Do While _PosI <= _PosF
			@ PRow(), _Coluna + 36 PSay _nPeso     Picture("9999,999")    // Peso
			@ PRow(), _Coluna + 46 PSay _nPUB      Picture("9999.99")     // Real
			@ PRow(), _Coluna + 58 PSay _nPUL      Picture("9999.99")     // Vl. Liq.
			@ PRow(), _Coluna + 70 PSay _nDifSP    Picture("99.99")       // Diferenca Interestadual
			@ PRow(), _Coluna + 78 PSay "|"
			
			// +----------------------------------------------------------------------------+
			// | Calcula os totais por estado                                               |
			// | se nao encontrar o grupo na matriz de grupos excluidos calcula os totais   |
			// +----------------------------------------------------------------------------+
			If !_cGrupoI $ _cGrup_Canc			
			//If Ascan(CancelaGrupo, {|x| x[1] == _cGrupoI}) == 0
				Do Case
					Case _PosI == 1
						_TotPes1 := _TotPes1 + _nPeso
						_PXDif1 := _PXDif1 + (_nPeso * _nDifSP)
					Case _PosI == 2
						_TotPes2 := _TotPes2 + _nPeso
						_PXDif2 := _PXDif2 + (_nPeso * _nDifSP)
					Case _PosI == 3
						_TotPes3 := _TotPes3 + _nPeso
						_PXDif3 := _PXDif3 + (_nPeso * _nDifSP)
					Case _PosI == 4
						_TotPes4 := _TotPes4 + _nPeso
						_PXDif4 := _PXDif4 + (_nPeso * _nDifSP)
				EndCase
			Endif
			
			// +----------------------------+
			// | Calcula os totais de frete |
			// +----------------------------+
			Do Case
				Case _PosI == 1
					_TPes1 := _TPes1 + _nPeso
					If _FrtTbl1 == 0
						_FrtTbl1 := ZBZ->ZBZ_FRTTBL
					Endif
				Case _PosI == 2
					_TPes2 := _TPes2 + _nPeso
					If _FrtTbl2 == 0
						_FrtTbl2 := ZBZ->ZBZ_FRTTBL
					Endif
				Case _PosI == 3
					_TPes3 := _TPes3 + _nPeso
					If _FrtTbl3 == 0
						_FrtTbl3 := ZBZ->ZBZ_FRTTBL
					Endif
				Case _PosI == 4
					_TPes4 := _TPes4 + _nPeso
					If _FrtTbl4 == 0
						_FrtTbl4 := ZBZ->ZBZ_FRTTBL
					Endif
			EndCase
			
			// +----------------------+
			// | Monta matriz aResPMF |
			// +----------------------+
			_PosTotL := aScan(aResPMF, {|x| x[1] == _EstadoI})
			If _PosTotL == 0
				aADD(aResPMF, {_EstadoI, _nPeso, _nValor, _nFrete})
			Else
				
				aResPMF[_PosTotL][2] := aResPMF[_PosTotL][2] + _nPeso
				aResPMF[_PosTotL][3] := aResPMF[_PosTotL][3] + _nValor
				aResPMF[_PosTotL][4] := aResPMF[_PosTotL][4] + _nFrete
			Endif
			
			// +------------------------------------------+
			// | Acumula o total de kilos, real e liquido |
			// | das colunas excluindo SP.                |
			// +------------------------------------------+
			If _EstadoI <> "SP"
				_AGrupo  := _cGrupoI                      // Armazena o grupo
				_APeso   := _APeso   + _nPeso             // Acumula o Peso
				_PndTotB := _PndTotB + (_nPeso * _nPUB)   // Pondera o Preco Bruto
				_PndTotL := _PndTotL + (_nPeso * _nPUL)   // Pondera o Preco Liquido
				_PndDif  := _PndDif  + (_nPeso * _nDifSP) // Pondera a Diferenca
			Endif
			
			_nPeso   := 0
			_nPUB    := 0
			_nPUL    := 0
			_nDifSP  := 0
			_nValor  := 0
			_nFrete  := 0
			
			_Coluna  := _Coluna + 44
			_PosI    := _PosI + 1
			ContaEst := ContaEst + 1
			
			If ContaEst <= Len(vEstado)
				// +----------------------------------------------------------------------------------------------------------------------+
				// | _EstadoI -> Estado a imprimir segue sequencia da matriz aEstados que contem todos os estados que devem ser impressos |
				// +----------------------------------------------------------------------------------------------------------------------+
				_EstadoI := vEstado[ContaEst][1]                    
				
				// +----------------------------------------------------+
				// | Procura pelo primeiro grupo e pelo primeiro estado |
				// +----------------------------------------------------+
				If ZBZ->(DbSeek(xFilial("ZBZ") + DTOS(mv_par01) + DTOS(mv_par02) + _nVersao + _cGrupoI + _EstadoI))
					// +-------------------+
					// | Localizou imprime |
					// +-------------------+
					_nPeso   := ZBZ->ZBZ_QTDVEN - ZBZ->ZBZ_QTDDEV
					_nPUB    := ZBZ->ZBZ_PUB
					_nPUL    := ZBZ->ZBZ_PUL
					_nDifSP  := ZBZ->ZBZ_DIFSP
					_nValor  := (ZBZ->ZBZ_VLRVEN - ZBZ->ZBZ_VLRDEV)
					_nFrete  := ZBZ->ZBZ_VLRFRT
				Else
					// +---------------------+
					// | Nao localizou, zera |
					// +---------------------+
					_nPeso   := 0
					_nPUB    := 0
					_nPUL    := 0
					_nDifSP  := 0
					_nValor  := 0
					_nFrete  := 0
				Endif
			Endif
		EndDo // _PosI <= _PosF
		
		// +-----------------------------------------------------+
		// | Adiciona elementos a matriz aTotLin                 |
		// | ou acumula os valores para impressao do totalizador |
		// | de linha                                            |
		// +-----------------------------------------------------+
		_PosTotL := aScan(aTotLin, {|x| x[1] == _AGrupo})
		If _PosTotL == 0
			aADD(aTotLin, {_AGrupo, _APeso, _PndTotB, _PndTotL, _PndDif})
		Else
			aTotLin[_PosTotL][2] := aTotLin[_PosTotL][2] + _APeso
			aTotLin[_PosTotL][3] := aTotLin[_PosTotL][3] + _PndTotB
			aTotLin[_PosTotL][4] := aTotLin[_PosTotL][4] + _PndTotL
			aTotLin[_PosTotL][5] := aTotLin[_PosTotL][5] + _PndDif
		Endif
		
		_AGrupo  := ""
		_APeso   := 0
		_PndTotB := 0
		_PndTotL := 0
		_PndDif  := 0
		
		_Coluna := 0
		
		_PosI := 1
		
		ContaEst := ContaEst - _PosF
		ContaGru := ContaGru + 1
		SeqGrp := SeqGrp + 1
		
	EndDo // SeqEst <= Len(aGrupos)
	
	@ PRow() + 1, _Coluna PSay "+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	@ PRow() + 1, 00      PSay "|   >>>>>   T O T A L   <<<<<     |"
	@ PRow()    , 37 PSay _TotPes1                         Picture("99,999,999")
	@ PRow()    , 53 PSay _TotPes1 * (_PXDif1 / _TotPes1)  Picture("99999,999.99")
	@ PRow()    , 70 PSay _PXDif1 / _TotPes1               Picture("99.99")
	@ PRow()    , 78 PSay "|"
	@ PRow()    , 81 PSay _TotPes2                         Picture("99,999,999")
	@ PRow()    , 97 PSay _TotPes2 * (_PXDif2 / _TotPes2)  Picture("99999,999.99")
	@ PRow()    ,114 PSay _PXDif2 / _TotPes2               Picture("99.99")
	@ PRow()    ,122 PSay "|"
	@ PRow()    ,125 PSay _TotPes3                         Picture("99,999,999")
	@ PRow()    ,141 PSay _TotPes3 * (_PXDif3 / _TotPes3)  Picture("99999,999.99")
	@ PRow()    ,158 PSay _PXDif3 / _TotPes3               Picture("99.99")
	@ PRow()    ,166 PSay "|"
	@ PRow()    ,169 PSay _TotPes4                         Picture("99,999,999")
	@ PRow()    ,185 PSay _TotPes4 * (_PXDif4 / _TotPes4)  Picture("99999,999.99")
	@ PRow()    ,202 PSay _PXDif4 / _TotPes4               Picture("99.99")
	@ PRow()    ,210 PSay "|"
	@ PRow() + 1, 00 PSay "+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	@ PRow() + 1, 00 PSay "|                                 |     QTD.    |     TOTAL     |   $ MED.    |    QTD.     |     TOTAL     |   $ MED.    |     QTD.    |     TOTAL     |   $ MED.    |     QTD.    |     TOTAL     |   $ MED.    |"
	@ PRow() + 1, 00 PSay "|   >>>>>   F R E T E   <<<<<     |-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	@ PRow() + 1, 00 PSay "|                                 |"
	@ PRow()    , 37 PSay _TPes1              Picture("99,999,999")
	@ PRow()    , 52 PSay _TPes1 * _FrtTbl1   Picture("99,999,999")
	@ PRow()    , 68 PSay _FrtTbl1            Picture("99.99")
	@ PRow()    , 78 PSay "|"
	@ PRow()    , 81 PSay _TPes2              Picture("99,999,999")
	@ PRow()    , 95 PSay _TPes2 * _FrtTbl2   Picture("99,999,999")
	@ PRow()    ,111 PSay _FrtTbl2            Picture("99.99")
	@ PRow()    ,122 PSay "|"
	@ PRow()    ,124 PSay _TPes3              PicTure("99,999,999")
	@ PRow()    ,139 PSay _TPes3 * _FrtTbl3   Picture("99,999,999")
	@ PRow()    ,155 PSay _FrtTbl3            Picture("99.99")
	@ PRow()    ,166 PSay "|"
	@ PRow()    ,168 PSay _TPes4              Picture("99,999,999")
	@ PRow()    ,183 PSay _TPes4 * _FrtTbl4   Picture("99,999,999")
	@ PRow()    ,199 PSay _FrtTbl4            Picture("99.99")
	@ PRow()    ,210 PSay "|"
	@ PRow() + 1, 00 PSay "+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	@ PRow() + 1, 00 PSay ">>>>> (*) Grupos Excluidos. Valores nao influenciam nos calculos totalizadores. <<<<<"
	//                     0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//                               10        20        30        40        50        60        70        80        90        100       110       120       130       140       150       160       170       180       190       200       210
	_TotPes1     := 0
	_PXDif1      := 0
	_TotPes2     := 0
	_PXDif2      := 0
	_TotPes3     := 0
	_PXDif3      := 0
	_TotPes4     := 0
	_PXDif4      := 0
	_TPes1       := 0
	_TPes2       := 0
	_TPes3       := 0
	_TPes4       := 0
	_FrtTbl1     := 0
	_FrtTbl2     := 0
	_FrtTbl3     := 0
	_FrtTbl4     := 0
	
	ContaGru := 1
	ContaEst := ContaEst + 4
	SeqGrp := 1
	SeqEst := ContaEst
EndDo

// +-------------------------------------------------------------------------------------------+
// | Imprime pagina de Resumos   ---   Resumo Preco Medio por Estado, Frete por Estado e Redes |
// +-------------------------------------------------------------------------------------------+

Conta := 1
// +---------------------+
// | Imprime o Cabecalho |
// +---------------------+
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)

// +---------------------------+
// | Imprime o Sub - Cabecalho |
// +---------------------------+
@ Prow() + 1, 00 PSay "+-------------------------------------------------------+  +-------------------------------------------------------+  +---------------------------------------------------------------------------------------------------+"
@ Prow() + 1 ,00 PSay "|                      PRECO MEDIO                      |  |                         FRETE                         |  |                                               REDES                                               |"
@ PRow() + 1, 00 PSay "+----------+----------------+---------------+-----------+  +----------+----------------+---------------+-----------+  +--------+--------------------------------+--------+------------------+---------------+-------------+"
@ PRow() + 1, 00 PSay "|  Estado  |   Quantidade   |     Valor     |  $ Medio  |  |  Estado  |   Quantidade   |     Valor     |  $ Medio  |  | Codigo |              Nome              | Indice |     Faturado     |   Descontos   |    Quant    |"
@ PRow() + 1, 00 PSay "+----------+----------------+---------------+-----------+  +----------+----------------+---------------+-----------+  +--------+--------------------------------+--------+------------------+---------------+-------------+"
//                     012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678
//                               10        20        30        40        50        60        70        80        90        100       110       120       130       140       150       160       170       180       190       200       210
ZBY->(DbGoTop())
ZBY->(DbSeek(xFilial("ZBY") + dtos(mv_par01) + dtos(mv_par02) + _nVersao))

While (Conta <= Len(aResPMF)) .OR. (ZBY->ZBY_DTINI == dtos(mv_par01) .AND. ZBY->ZBY_DTFIM == dtos(mv_par02) .AND. ZBY->ZBY_VERSAO == _nVersao)
	If Conta <= Len(aResPMF)
		If ! ZBY->(Eof())
			@ PRow() + 1, 00 PSay "|    " + aResPMF[Conta][1] + "    |"                   // Estado        Resumo Preco Medio
			@ PRow()    , 14 PSay aResPMF[Conta][2] Picture("999,999,999.99")             // Quantidade    Resumo Preco Medio
			@ PRow()    , 28 PSay "|"
			@ PRow()    , 30 PSay aResPMF[Conta][3] Picture("999,999,999.99")             // Valor         Resumo Preco Medio
			@ PRow()    , 44 PSay "|"
			@ PRow()    , 48 PSay aResPMF[Conta][3] / aResPMF[Conta][2] Picture("99.99")  // Preco Medio   Resumo Preco Medio
			@ PRow()    , 56 PSay "|"
			@ PRow()    , 59 PSay "|    " + aResPMF[Conta][1] + "    |"                   // Estado        Resumo Frete
			@ PRow()    , 73 PSay aResPMF[Conta][2] Picture("999,999,999.99")             // Quantidade    Resumo Frete
			@ PRow()    , 87 PSay "|"
			@ PRow()    , 89 PSay aResPMF[Conta][4] Picture("999,999,999.99")             // Valor Frete   Resumo Frete
			@ PRow()    ,103 PSay "|"
			@ PRow()    ,107 PSay aResPMF[Conta][4] / aResPMF[Conta][2] Picture("99.99")  // Frete Medio   Resumo Frete
			@ PRow()    ,115 PSay "|"
			@ PRow()    ,118 PSay "|"
		Else
			@ PRow() + 1, 00 PSay "|    " + aResPMF[Conta][1] + "    |"                   // Estado        Resumo Preco Medio
			@ PRow()    , 14 PSay aResPMF[Conta][2] Picture("999,999,999.99")             // Quantidade    Resumo Preco Medio
			@ PRow()    , 28 PSay "|"
			@ PRow()    , 30 PSay aResPMF[Conta][3] Picture("999,999,999.99")             // Valor         Resumo Preco Medio
			@ PRow()    , 44 PSay "|"
			@ PRow()    , 48 PSay aResPMF[Conta][3] / aResPMF[Conta][2] Picture("99.99")  // Preco Medio   Resumo Preco Medio
			@ PRow()    , 56 PSay "|"
			@ PRow()    , 59 PSay "|    " + aResPMF[Conta][1] + "    |"                   // Estado        Resumo Frete
			@ PRow()    , 73 PSay aResPMF[Conta][2] Picture("999,999,999.99")             // Quantidade    Resumo Frete
			@ PRow()    , 87 PSay "|"
			@ PRow()    , 89 PSay aResPMF[Conta][4] Picture("999,999,999.99")             // Valor Frete   Resumo Frete
			@ PRow()    ,103 PSay "|"
			@ PRow()    ,107 PSay aResPMF[Conta][4] / aResPMF[Conta][2] Picture("99.99")  // Frete Medio   Resumo Frete
			@ PRow()    ,115 PSay "|"
			@ PRow()    ,118 PSay "|"
		Endif
		
		_SQtdPMF := _SQtdPMF + aResPMF[Conta][2]
		_SVlrPM  := _SVlrPM  + aResPMF[Conta][3]
		_SVlrF   := _SVlrF   + aResPMF[Conta][4]
	Endif
	
	If ! ZBY->(Eof())
		If Conta <= Len(aResPMF)
			@ PRow()    ,120 PSay AllTrim(ZBY->ZBY_REDE)
			@ PRow()    ,127 PSay "|"
			@ PRow()    ,129 PSay Left(AllTrim(ZBY->ZBY_NOME), 31)
			@ PRow()    ,160 PSay "|"
			@ PRow()    ,162 PSay ZBY->ZBY_DESCFI                          Picture("99.99")
			@ PRow()    ,169 PSay "|"
			@ PRow()    ,172 PSay ZBY->ZBY_VALOR                           Picture("99,999,999.99")
			@ PRow()    ,188 PSay "|"
			@ PRow()    ,190 PSay ZBY->ZBY_VALOR * (ZBY->ZBY_DESCFI / 100) Picture("99,999,999.99")
			@ PRow()    ,204 PSay "|"
			@ PRow()    ,205 PSay ZBY->ZBY_QUANT                           Picture("99,999,999.99")
			@ PRow()    ,218 PSay "|"
		Else
			If _FlagPMF == .F.
				@ PRow() + 1, 00 PSay "+----------+----------------+---------------+-----------+  +----------+----------------+---------------+-----------+"
				@ PRow()    ,118 PSay "|"
				@ PRow()    ,120 PSay AllTrim(ZBY->ZBY_REDE)
				_FlagPMF := .T.
			Else
				If _FlagIT == .F.
					If _FlagPMF == .T.
						@ PRow() + 1, 00 PSay "| TOTAL ---->"
						@ PRow()    , 14 PSay _SQtdPMF           Picture("999,999,999.99")
						@ PRow()    , 30 PSay _SVlrPM            Picture("999,999,999.99")
						@ PRow()    , 48 PSay _SVlrPM / _SQtdPMF Picture("99.99")
						@ PRow()    , 56 PSay "|"
						@ PRow()    , 59 PSay "| TOTAL ---->"
						@ PRow()    , 73 PSay _SQtdPMF           Picture("999,999,999.99")
						@ PRow()    , 89 PSay _SVlrF             Picture("999,999,999.99")
						@ PRow()    ,107 PSay _SVlrF / _SQtdPMF  Picture("99.99")
						@ PRow()    ,115 PSay "|"
						@ PRow()    ,118 PSay "|"
						@ PRow()    ,120 PSay AllTrim(ZBY->ZBY_REDE)
					Else
						@ PRow()    ,118 PSay "|"
						@ PRow()    ,120 PSay AllTrim(ZBY->ZBY_REDE)
					Endif
					_FlagIT := .T.
				Else
					If _FimIT == .F.
						@ Prow() + 1, 00 PSay "+-------------------------------------------------------+  +-------------------------------------------------------+"
						@ PRow()    ,118 PSay "|"
						@ PRow()    ,120 PSay AllTrim(ZBY->ZBY_REDE)
						_FimIT := .T.
					Else
						@ PRow() + 1,118 PSay "|"
						@ PRow()    ,120 PSay AllTrim(ZBY->ZBY_REDE)
					Endif
				Endif
			Endif
			@ PRow()    ,127 PSay "|"
			@ PRow()    ,129 PSay Left(AllTrim(ZBY->ZBY_NOME), 31)
			@ PRow()    ,160 PSay "|"
			@ PRow()    ,162 PSay ZBY->ZBY_DESCFI                          Picture("99.99")
			@ PRow()    ,169 PSay "|"
			@ PRow()    ,172 PSay ZBY->ZBY_VALOR                           Picture("99,999,999.99")
			@ PRow()    ,188 PSay "|"
			@ PRow()    ,190 PSay ZBY->ZBY_VALOR * (ZBY->ZBY_DESCFI / 100) Picture("99,999,999.99")
			@ PRow()    ,204 PSay "|"
			@ PRow()    ,205 PSay ZBY->ZBY_QUANT                           Picture("99,999,999.99")
			@ PRow()    ,218 PSay "|"
			
			_AcumFat := _AcumFat + ZBY->ZBY_VALOR
			_AcumDes := _AcumDes + ZBY->ZBY_VALOR * (ZBY->ZBY_DESCFI / 100)
			_AcumQtd := _AcumQtd + ZBY->ZBY_QUANT
		Endif
	Endif
	
	ZBY->(DbSkip())
	Conta := Conta + 1
	
EndDo

@ PRow() + 1,118 PSay "+--------+--------------------------------+--------+------------------+---------------+-------------+"
@ PRow() + 1,118 PSay "| TOTAL  "
@ PRow()    ,172 PSay _AcumFat Picture("99,999,999.99")
@ PRow()    ,190 PSay _AcumDes Picture("99,999,999.99")
@ PRow()    ,205 PSay _AcumQtd Picture("99,999,999.99")
@ PRow()    ,218 PSay "|"
@ PRow() + 1,118 PSay "+---------------------------------------------------------------------------------------------------+"


// +-----------------------------------------------------------------------------------------+
// | Imprime Resumo do InterEstadual - Comparativo do preco medio de todos os estados com SP |
// +-----------------------------------------------------------------------------------------+
Private ContaTLin := 1
Private _nATPeso  := 0
Private _nATDif   := 0

// +---------------------+
// | Imprime o Cabecalho |
// +---------------------+
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)

// +---------------------------+
// | Imprime o Sub - Cabecalho |
// +---------------------------+
@ PRow() + 1, 00 PSay "+---------------------------------+-------------------------------------------+"
//@ PRow() + 1, 00 PSay "|  Grupo  |   Peso   |   Real    | Vl. Liq. |   Dif.  |"
@ PRow() + 1, 00 PSay "|          Grupo                  |   Peso   |   Real    | Vl. Liq. |   Dif.  |"
@ PRow() + 1, 00 PSay "+---------------------------------+-------------------------------------------+"

While ContaTLin <= Len(aTotLin)        
             
	If PRow() > 65
		@ PRow() + 1, 00 PSay "+---------------------------------+-------------------------------------------+"
		// +---------------------+
		// | Imprime o Cabecalho |
		// +---------------------+
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)

		// +---------------------------+
		// | Imprime o Sub - Cabecalho |
		// +---------------------------+
		@ PRow() + 1, 00 PSay "+---------------------------------+-------------------------------------------+"		
		@ PRow() + 1, 00 PSay "|          Grupo                  |   Peso   |   Real    | Vl. Liq. |   Dif.  |"
		@ PRow() + 1, 00 PSay "+---------------------------------+-------------------------------------------+"
	Endif	

	// +------------------------+
	// | Imprime linhas Detalhe |
	// +------------------------+                             
	_cGrupoCan := aTotLin[ContaTLin][1]           
	_cDesGrp := Left(aGrupos[ContaTLin][2], 23)	
	If _cGrupoCan $ _cGrup_Canc
	//If (Ascan(CancelaGrupo, {|x| x[1] == aTotLin[ContaTLin][1]}) <> 0)
		@ PRow() + 1, 00 PSay "| *"
	Else
		@ PRow() + 1, 00 PSay "|  "
	Endif
	@ PRow()    , 03 PSay aTotLin[ContaTLin][1]
	@ PRow()    , 09 PSay _cDesGrp
	@ PRow()    , 34 PSay "|"
	@ PRow()    , 36 PSay aTotLin[ContaTLin][2]                         Picture("9999,999")
	@ PRow()    , 47 PSay aTotLin[ContaTLin][3] / aTotLin[ContaTLin][2] Picture("999.99")
	@ PRow()    , 59 PSay aTotLin[ContaTLin][4] / aTotLin[ContaTLin][2] PicTure("999.99")
	
	// +--------------------------------------------------------------------+
	// | Calcula e imprime a diferenca entre SP e a soma dos demais estados |
	// +--------------------------------------------------------------------+
	@ PRow()    , 70 PSay aTotLin[ContaTLin][5]  / aTotLin[ContaTLin][2] Picture("999.99")
	@ PRow()    , 78 PSay "|"
	
	// +----------------------------------------+
	// | Acumula o Peso e a Diferenca Ponderada |
	// +----------------------------------------+
	_cGrupoCan := aTotLin[ContaTLin][1]
	If !_cGrupoCan $ _cGrup_Canc
	//If Ascan(CancelaGrupo, {|x| x[1] == aTotLin[ContaTLin][1]}) == 0
		_nATPeso := _nATPeso + aTotLin[ContaTLin][2]
		_nATDif  := _nATDif + (aTotLin[ContaTLin][2] * (aTotLin[ContaTLin][5]  / aTotLin[ContaTLin][2]))
	Endif
	
	// +--------------------------------------------+
	// | Incrementa o contado de elementos do array |
	// +--------------------------------------------+
	ContaTLin := ContaTLin + 1
EndDo

// +----------------------------------+
// | Imprime o total do interestadual |
// +----------------------------------+
@ PRow() + 1, 00 PSay "+---------------------------------+-------------------------------------------+"
@ PRow() + 1, 00 PSay "|>         Total                 <|"
@ PRow()    , 36 PSay _nATPeso Picture("9999,999")
@ PRow()    , 49 PSay _nATPeso * (_nATDif / _nATPeso) Picture("999,999,999")
@ PRow()    , 70 PSay (_nATDif / _nATPeso) Picture("999.99")
@ PRow()    , 78 PSay "|"   //54
@ PRow() + 1, 00 PSay "+-----------------------------------------------------------------------------+"
@ PRow() + 1, 00 PSay ">>>>> (*) Grupos Excluidos. Valores nao influenciam nos calculos totalizadores. <<<<<"

// +------------------------------------------------------------------------------+
// | Limpa os registros marcados como temporarios utilizando comando SQL Truncate |
// +------------------------------------------------------------------------------+
If mv_par05 == 2
	TcSqlExec("DELETE FROM " + RetSqlName("ZBX") + " WHERE ZBX_DTINI = '" + dtos(mv_par01) + "' AND ZBX_DTFIM = '" + dtos(mv_par02) + "' AND ZBX_VERSAO = 'NO'")
	TcSqlExec("DELETE FROM " + RetSqlName("ZBY") + " WHERE ZBY_DTINI = '" + dtos(mv_par01) + "' AND ZBY_DTFIM = '" + dtos(mv_par02) + "' AND ZBY_VERSAO = 'NO'")
	TcSqlExec("DELETE FROM " + RetSqlName("ZBZ") + " WHERE ZBZ_DTINI = '" + dtos(mv_par01) + "' AND ZBZ_DTFIM = '" + dtos(mv_par02) + "' AND ZBZ_VERSAO = 'NO'")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Finaliza a execucao do relatorio...                                 ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
Set Device To Screen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Se impressao em disco, chama o gerenciador de impressao...          ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If aReturn[5]==1
	dbCommitAll()
	Set Printer TO
	OurSpool(wnrel)
Endif

Ms_Flush()

Return(.T.) 



//Funcao que exibe as menssagens na Tela
Static Function PrcRecs()
    
//Seleciona Registros Conforme Parametros
SelPar ()       

//Calculando o Valor do Frete
VrFrtC ()

//Criando Matriz com Grupos a serem Cancelados                                       
CMtrC ()


//monta Matris com estados selecionados
MntUF()

//Grupos Utilizados
GrpUtil ()

//Processando Frete Por Produto                
FrtPrd ()

// Montando Matriz Impressao do Relatorio   
MtrImp()
         
//Processando Preco Unitario, Bruto, Unitario Liquido do Grupo para o Estado                      
PrcUBL ()       

//Gerando Diferenca Interestadual SP x Outros Estados      
DifSP ()

/*
	Processa({||SelPar()  }  ,"Selecionando Registros Conforme Parametros...")
    Processa({||VrFrtC()  }  ,"Calculando o Valores do Frete...")
    Processa({||CMtrC()   }  ,"Criando Matriz com Grupos a serem Cancelados...") 
    Processa({||GrpUtil() }  ,"Processando Grupos Utilizados...") 
    Processa({||FrtPrd()  }  ,"Processando Frete Por Produto...") 
    Processa({||MtrImp()  }  ,"Montando Matriz Impressao do Relatorio...")
    Processa({||PrcUBL()  }  ,"Processando Preco Unitario, Bruto, Unitario Liquido do Grupo para o Estado...")      
    Processa({||DifSP()   }  ,"Gerando Diferenca Interestadual SP x Outros Estados...") 	
  */
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
																			FUNCOES
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³MONTA MINHAS MENSAGENS NA TELA COM A REGUA                          ?
//³PRCESSAMENTOS SAO POR FUNCAO                                        ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



Static Function SelPar ()


MsProcTxt("Selecionando Parametros...")

// +------------------------+
// | Seleciona os registros |
// +------------------------+
Private cQuery := ""

&&Chamado 034920 - Trocado para nao ficar chumbado na query abaixo
_cCFOP := Alltrim(GETMV("MV_#037CFO"))

cQuery := "SELECT "                                      + ;
               "D2_FILIAL, "                             + ;
               "D2_GRUPO, "                              + ;
               "D2_CLIENTE, "                            + ;
               "D2_LOJA, "                               + ;
               "D2_PEDIDO, "                             + ;
               "D2_SERIE, "                              + ;
               "D2_DOC, "                                + ;
               "D2_COD, "                                + ;
               "D2_PICM AS D2_PICM, "                    + ;
               "D2_VALICM AS D2_VALICM, "                + ;
               "D2_QUANT AS D2_QUANT, "                  + ;
               "D2_UM, "                                 + ;
               "D2_TOTAL AS D2_TOTAL, "                  + ;
               "D2_EMISSAO, "                            + ;
               "D2_CF, "                                 + ;
               "D2_PEDIDO, "                             + ;
               "D2_TES, "                                + ;
               "D2_QTDEDEV AS D2_QTDEDEV, "              + ;
               "D2_VALDEV AS D2_VALDEV, "                + ;
               "D2_EST "                                 + ;                
          "FROM "                                        + ;
               RetSqlName("SD2") + " "                   + ;
          "WHERE "                                       + ;
               "D2_EMISSAO BETWEEN '" + DtoS(mv_par01) + "' AND '" + DtoS(mv_par02) + "' AND " + ;
               "D2_TP = 'PA' AND "                                                             + ;
               "(D2_GRUPO >= '" + mv_par03 + "' AND D2_GRUPO <= '" + mv_par04 + "') AND "      + ;
               "(D2_CF IN ("+_cCFOP+")) AND "                                                       + ;
               RetSqlName("SD2") + ".D_E_L_E_T_ <> '*'"
               
/*
cQuery := "SELECT "                                      + ;
               "D2_FILIAL, "                             + ;
               "D2_GRUPO, "                              + ;
               "D2_CLIENTE, "                            + ;
               "D2_LOJA, "                               + ;
               "D2_PEDIDO, "                             + ;
               "D2_SERIE, "                              + ;
               "D2_DOC, "                                + ;
               "D2_COD, "                                + ;
               "D2_PICM AS D2_PICM, "                    + ;
               "D2_VALICM AS D2_VALICM, "                + ;
               "D2_QUANT AS D2_QUANT, "                  + ;
               "D2_UM, "                                 + ;
               "D2_TOTAL AS D2_TOTAL, "                  + ;
               "D2_EMISSAO, "                            + ;
               "D2_CF, "                                 + ;
               "D2_PEDIDO, "                             + ;
               "D2_TES, "                                + ;
               "D2_QTDEDEV AS D2_QTDEDEV, "              + ;
               "D2_VALDEV AS D2_VALDEV, "                + ;
               "D2_EST "                                 + ;
          "FROM "                                        + ;
               RetSqlName("SD2") + " "                   + ;
          "WHERE "                                       + ;
               "D2_EMISSAO BETWEEN '" + DtoS(mv_par01) + "' AND '" + DtoS(mv_par02) + "' AND " + ;
               "D2_TP = 'PA' AND "                                                             + ;
               "(D2_GRUPO >= '" + mv_par03 + "' AND D2_GRUPO <= '" + mv_par04 + "') AND "      + ;
               "(D2_CF = '5101' OR D2_CF = '5102' OR D2_CF = '511' "                           + ;
               "OR D2_CF = '5118' OR D2_CF = '512' OR D2_CF = '5401' OR D2_CF = '6401' "                         + ;
               "OR D2_CF = '5922' OR D2_CF = '6922' "                         + ;
               "OR D2_CF = '5501' OR D2_CF = '6501' "                         + ;
               "OR D2_CF = '6101' OR D2_CF = '6102' OR D2_CF = '6107' "                        + ;
               "OR D2_CF = '6109' OR D2_CF = '611' "                         + ;
               "OR D2_CF = '6118') AND "                                                       + ;
               RetSqlName("SD2") + ".D_E_L_E_T_ <> '*'"               
*/
               
TCQUERY cQuery New Alias "TMP01"

// +-------------------------------------------------+
// | Grava um arquivo com o select no SYSTEM/SYSTEM |
// +-------------------------------------------------+
//MemoWrit("XPTO.SQL", cQuery)

SBM->(DbSetOrder(1)) // Indexa por filial + codigo do grupo
SBM->(DbGoTop())
SC5->(DbSetOrder(15)) // Indexa por filia + nota + serie
SC5->(DbGoTop())
SA1->(DbSetOrder(1)) // Indexa por filial + cliente + loja
SA1->(DbGoTop())
SZK->(DbSetOrder(14)) // Indexa por filial + Placa + Roteiro + Data Emissao
SZK->(DbGoTop())
ZV9->(DbSetOrder(5)) // Indexa por filial + regial + data
ZV9->(DbGoTop())
ZBY->(DbSetOrder(1)) // Indexa por filial + data inicio + data fim + versao + codigo da rede
 
Return 



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculando o Valor do Frete                                                               ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


Static Function VrFrtC ()  


msProcTxt("Calculando Valores de Frete...")

DbSelectArea("TMP01") // Abre Arquivo de Vendas + Devolucoes
DbGoTop("TMP01")
While ! TMP01->(Eof())
	//SC5->(DbSeek(xFilial("SC5") + TMP01->D2_DOC + TMP01->D2_SERIE))
	SC5->(DbSeek(TMP01->D2_FILIAL + TMP01->D2_DOC + TMP01->D2_SERIE))  &&Mauricio 12/03/10 - Encontrado e corrigido erro no atendimento do Chamado 006244.
	SBM->(DbSeek(xFilial("SBM") + TMP01->D2_GRUPO))
	SA1->(DbSeek(xFilial("SA1") + TMP01->D2_CLIENTE + TMP01->D2_LOJA))
	SA3->(DbSeek(xFilial("SA3") + SC5->C5_VEND1))
	
	&&Mauricio - 02/05/17 - tratamento para tipo cliente e Percen
	&&inicio
	SF4->(DbSeek(xFilial("SF4") + TMP01->D2_TES))
	If SF4->F4_BASEICM == GETMV("MV_#037RED") &&Condição para aliquota 11 consumidor final....    
	   _nAlqDif := 0.11         
	Else
	   _nAlqDif := 1
	Endif   
	_cTpCli := SA1->A1_TIPO
	
	_lDif := .F.
	If _cTpCli == "F" .And. _nAlqDif == 0.11
	   _lDif := .T.		
	Endif
	&&Fim
	
	// +-----------------------------+
	// | Calculando o Valor do Frete |
	// +-----------------------------+
	Private _nValFrete := 0
	Private _nFrtTbl   := 0  
	
	If ALLTRIM(SA3->A3_REGIAO) = 'EXP'
		TMP01->(DbSkip())
		Loop
	Endif
	
	// +------------+
	// | Frete real |
	// +------------+
	If mv_par06 = 1
		SZK->(DbSeek(xFilial("SZK") + SC5->C5_PLACA + SC5->C5_ROTEIRO + TMP01->(D2_EMISSAO)))
		_nValFrete := SZK->ZK_VALFRET
	Else
		// +----------------------------------+
		// | Calcula com base no Frete Padrao |
		// +----------------------------------+
		
		&&Mauricio - 19/05/17 - Chamado 035246 - retirado sequencia "00", por conta de novo tratamento na gravação da tabela
		&&ZV9 que não era mais atualizada desde 2014 e como não vai haver mais somente a sequencia 00 tive de implementar novo
		&&Tratamento para buscar corretamente a região.		
		_cEst	:= SA1->A1_EST
		_cMunic := SA1->A1_COD_MUN
	
		If !Empty(_cMunic)
		   xxEstFV9 := Posicione('CC2',1,xFilial("CC2")+_cEst+_cMunic,"CC2_XREGIA")  // Localizo a regiao do cliente
		Else
		   xxEstFV9 := TMP01->D2_EST + "00"   &&Jeito anterior ao chamado acima.
		EndIf
			
		xxEmissaoNF := TMP01->D2_EMISSAO
			
		DbSelectArea("ZV9")
		DbSetOrder(5)
		If dbseek(xFilial("ZV9") + xxEstFV9 )
	    
		  While ! ZV9->(Eof()) .and. xxEstFV9 == ZV9->ZV9_REGIAO 			
					
			If  DTOS(ZV9->(ZV9_DTVAL)) <= xxEmissaoNF    
				If ZV9->(ZV9_VLTON) > 0
					_nValFrete := ZV9->(ZV9_VLTON) / 1000
					_nFrtTbl   := ZV9->(ZV9_VLTON) / 1000
				Endif
			Endif
			
			ZV9->(DbSkip())
			
		  EndDo
		  _nValFrete := (_nValFrete * TMP01->D2_QUANT)
		Else
		    _nValFrete := 0
		Endif
	Endif
	
	MsProcTxt ("Processando Cliente:"+SUBSTR(SA1->A1_NREDUZ,1,10) +"   NF.:"+TMP01->D2_DOC)	
	
	dbSelectArea("ZBX")
	RecLock("ZBX", .T.)
	Replace ZBX_VLRFRT      With _nValFrete
	Replace ZBX_FRTTBL      With _nFrtTbl
	Replace ZBX_VERSAO      With _nVersao
	Replace ZBX_NOME        With SA1->A1_NREDUZ
	Replace ZBX_REDE        With SA1->A1_REDE
	Replace ZBX_DESCFI      With SA1->A1_DESC
	Replace ZBX_TIPCLI      With _cTpCli
    Replace ZBX_PERC        With _nAlqDif
	
	// +----------------------------------------------------+
	// | Calcula o valor do desconto financeiro caso exista |
	// +----------------------------------------------------+
	If SA1->A1_DESC > 0
		// Alteração para subtrair a devolução antes do desconto financeiro
		// Werner 14/06/2006
		Replace ZBX_VLRDF  With (TMP01->D2_TOTAL -TMP01->D2_VALDEV) * (SA1->A1_DESC / 100)
	Endif
	Replace ZBX_TPFRT   With SC5->C5_TPFRETE
	Replace ZBX_ROT     With SC5->C5_ROTEIRO
	Replace ZBX_VEND    With SC5->C5_VEND1
	Replace ZBX_DTPED   With DTOS(SC5->C5_EMISSAO)
	Replace ZBX_PLACA   With SC5->C5_PLACA
	Replace ZBX_DESGRP  With SBM->BM_DESC
	Replace ZBX_DTINI   With DtoS(Mv_Par01)
	Replace ZBX_DTFIM   With DtoS(Mv_Par02)
	Replace ZBX_CODGRP  With TMP01->D2_GRUPO
	Replace ZBX_CLIENT  With TMP01->D2_CLIENTE
	Replace ZBX_LOJA    With TMP01->D2_LOJA
	Replace ZBX_PED     With TMP01->D2_PEDIDO
	Replace ZBX_NF      With TMP01->D2_DOC
	Replace ZBX_PRODUT  With TMP01->D2_COD
	Replace ZBX_PICM    With TMP01->D2_PICM
	Replace ZBX_QTDVEN  With TMP01->D2_QUANT
	Replace ZBX_UM      With TMP01->D2_UM
	Replace ZBX_VLRVEN  With TMP01->D2_TOTAL
	Replace ZBX_QTDDEV  With TMP01->D2_QTDEDEV
	Replace ZBX_VLRDEV  With TMP01->D2_VALDEV
	Replace ZBX_DTNF    With TMP01->D2_EMISSAO
	Replace ZBX_CFO     With TMP01->D2_CF
	Replace ZBX_VLAICM  With TMP01->D2_VALICM
	Replace ZBX_ESTADO  With TMP01->D2_EST
	Replace ZBX_FRTKG   With 0
	MsUnlock()
	DbCommit()



	
	// +------------------------------------+
	// | Armazena na ZBY os totais por Rede |
	// +------------------------------------+
	If (SA1->A1_REDE <> '') .and. (SA1->A1_DESC <> 0)
		ZBY->(DbGoTop())
		&&Mauricio - 02/05/17 - tratamento para tipo cliente e Percentual
		IF _lDif
		   _nDif := (TMP01->D2_TOTAL * _nAlqDif) - (TMP01->D2_TOTAL * GETMV("MV_#037ALQ"))      &&criar parametro MV_#037ALQ
		Else
		   _nDif := 0
		Endif   
		
		If ! ZBY->(DbSeek(ZBY->ZBY_FILIAL + dtos(mv_par01) + dtos(mv_par02) + _nVersao + SA1->A1_REDE))
			RecLock("ZBY", .T.)
			Replace ZBY->ZBY_DTINI  With dtos(mv_par01)
			Replace ZBY->ZBY_DTFIM  With dtos(mv_par02)
			Replace ZBY->ZBY_VERSAO With _nVersao
			Replace ZBY->ZBY_REDE   With SA1->A1_REDE
			Replace ZBY->ZBY_NOME   With SA1->A1_NREDUZ
			Replace ZBY->ZBY_DESCFI With SA1->A1_DESC
			Replace ZBY->ZBY_QUANT  With (TMP01->D2_QUANT - TMP01->D2_QTDEDEV)
			//Replace ZBY->ZBY_VALOR  With (TMP01->D2_TOTAL - TMP01->D2_VALDEV)
			Replace ZBY->ZBY_VALOR  With IIF((TMP01->D2_TOTAL - _nDif - TMP01->D2_VALDEV) > 0,(TMP01->D2_TOTAL - _nDif - TMP01->D2_VALDEV),0)
			MsUnlock()
			DbCommit()
		Else
			RecLock("ZBY", .F.)
			Replace ZBY->ZBY_QUANT  With ZBY->ZBY_QUANT + (TMP01->D2_QUANT - TMP01->D2_QTDEDEV)
			//Replace ZBY->ZBY_VALOR  With ZBY->ZBY_VALOR + (TMP01->D2_TOTAL - TMP01->D2_VALDEV)
			Replace ZBY->ZBY_VALOR  With ZBY->ZBY_VALOR + IIF((TMP01->D2_TOTAL - _nDif - TMP01->D2_VALDEV) > 0,(TMP01->D2_TOTAL - _nDif - TMP01->D2_VALDEV),0)
			MsUnlock()
			DbCommit()
		Endif
	Endif
	
	DbSelectArea("TMP01") // Seleciona Arquivo de Vendas + Devolucoes
	DbSkip()
EndDo
DbCloseArea("TMP01") // Fecha arquivo preenchido com vendas

// +--------------------------------------------------------------+
// | Verifica se a consulta retornou dados para gerar o relatorio |
// +--------------------------------------------------------------+
If ZBX->(RecCount()) == 0
	MsgBox("Nao existem dados a serem consultados no periodo de " + dtoc(mv_par01) + " a " + dtoc(mv_par02) + "." + chr(13) + "Informe outro periodo.")
	Return(.T.)
EnDif

Return
              



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//³Criando Matriz com Grupos a serem Cancelados                                       ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
Static Function CMtrC ()

msProcTxt ("Criando Matriz com Grupos Cancelados...")

// +-------------------------------------------+
// | Cria Matriz com Grupos a serem cancelados |
// +-------------------------------------------+

Private CancelaGrupo  := {}
Private ContaCaracter := 1
Private xxVarGrupo    := ""
// Substituido a matriz pela variavel e na comparaçao
// verifica se o grupo esta contido no conteudo do parametro
_cGrup_Canc := Alltrim(mv_par07)+";"+Alltrim(mv_par08)+";"+Alltrim(mv_par09)+";"+Alltrim(mv_par10) //incluido por ADRIANA em 18/08/2010
//While ( Substr(mv_par07, ContaCaracter, 1) <> " " ) .and. ( ContaCaracter <= 40 )
//	If Substr(mv_par07, ContaCaracter, 1) <> "," .AND. Substr(mv_par07, ContaCaracter, 1) <> ";"
//		xxVarGrupo := xxVarGrupo + Substr(mv_par07, ContaCaracter, 1)
//	Else
//		aAdd(CancelaGrupo, {(xxVarGrupo)})
//		xxVarGrupo := ""
//	Endif
//	ContaCaracter := ContaCaracter + 1
//		
//EndDo

return


//Mantando matriz com estados Utilizados
static Function MntUF()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe a Messagem: Montando Matriz com Estados Utilizados      ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MsProcTxt( "Montando Matriz com Estados Utilizados..." )

// +-----------------------------------+
// | Cria Array com Estados Utilizados |
// +-----------------------------------+
aEstados := {}

cQuery := ""

cQuery := "SELECT DISTINCT ZBX_ESTADO AS ESTADO FROM " + RetSqlName("ZBX") + " WHERE ZBX_DTINI = '" + ;
DTOS(mv_par01) + "' AND ZBX_DTFIM = '" + DTOS(mv_par02) + "' AND ZBX_VERSAO = '" + _nVersao + "' ORDER BY ZBX_ESTADO"
TcQuery cQuery New Alias "TMP03"

DbSelectArea("TMP03")
DbGoTop("TMP03")

//tratamento para estados

/*
AADD(aEstados,{('AC')})
AADD(aEstados,{('AL')})
AADD(aEstados,{('AM')})
AADD(aEstados,{('AP')})
AADD(aEstados,{('BA')})
AADD(aEstados,{('CE')})
AADD(aEstados,{('DF')})
AADD(aEstados,{('ES')})
AADD(aEstados,{('EX')}) REMOVIDO CONFORME SOLICITACAO DYOGENES - CHAMADO 006315 - DUPLICANDO ESTADOS E EXIBINDO O ESTADO 'EX'
AADD(aEstados,{('GO')})
AADD(aEstados,{('MA')})
AADD(aEstados,{('MG')})
AADD(aEstados,{('MS')})
AADD(aEstados,{('MT')})
AADD(aEstados,{('PA')})
AADD(aEstados,{('PB')})
AADD(aEstados,{('PE')})
AADD(aEstados,{('PI')})
AADD(aEstados,{('PR')})
AADD(aEstados,{('RJ')})
AADD(aEstados,{('RN')})
AADD(aEstados,{('RO')})
AADD(aEstados,{('RR')})
AADD(aEstados,{('RS')})
AADD(aEstados,{('SC')})
AADD(aEstados,{('SE')})
AADD(aEstados,{('SP')})
AADD(aEstados,{('TO')})
*/


While ! TMP03->(Eof())
	AADD(aEstados,{(TMP03->ESTADO)})
	MsProcTxt ("Processando Estado: "+TMP03->ESTADO)
	TMP03->(DbSkip())
EndDo

DbCloseArea("TMP03")


Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?                : Montando Matriz com Grupos Utilizados      ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


Static Function GrpUtil ()


	MsProcTxt( "Montando Matriz com Grupos Utilizados..." )



cQuery := "SELECT DISTINCT ZBX_CODGRP AS GRUPO, ZBX_DESGRP AS DESCR FROM " + RetSqlName("ZBX") + " WHERE ZBX_DTINI = '" + ;
DTOS(mv_par01) + "' AND ZBX_DTFIM = '" + DTOS(mv_par02) + "' AND ZBX_VERSAO = '" + _nVersao + "' ORDER BY ZBX_CODGRP"
TcQuery cQuery New Alias "TMP04"

DbSelectArea("TMP04")
DbGoTop("TMP04")

While ! TMP04->(Eof())
	AADD(aGrupos,{TMP04->GRUPO, TMP04->DESCR})
	TMP04->(DbSkip())
EndDo
DbCloseArea("TMP04")

// +---------------------------------------------------------------------------------+
// | Grava o Frete por produto (A soma do frete por produto integra o frete da nota) |
// | Calcula o Valor do Frete por Produto utiliza Funcao Processa para exibir regua  |
// | para acompanhamento do processamento                                            |
// +---------------------------------------------------------------------------------+



Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//³Processa Frete Por Produto                                   ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?

Static Function FrtPrd ()
MsProcTxt( "Processando Frete por Produto..." )


Private xxFreteUF := {}
Private nCodGrp  := ""
Private nCodProd := ""
Private nAuxNF   := ""
Private nVlrFrt  := 0              
Private nAcumQtd := 0
Private nEstado  := ""
Private nTotFrt  := 0

DbSelectArea("ZBX")
ZBX->(DbSetOrder(4)) // indexa por filial + data inicio + data fim + versao + nf
ZBX->(DbGoTop())
ZBX->(DbSeek(xFilial("ZBX") + dtos(mv_par01) + dtos(mv_par02) + _nVersao))
While ZBX->ZBX_DTINI == dtos(mv_par01) .AND. ZBX->ZBX_DTFIM == dtos(mv_par02) .AND. ZBX->ZBX_VERSAO == _nVersao
	nAcumQtd := 0
	nCodGrp  := ZBX->ZBX_CODGRP
	nCodProd := ZBX->ZBX_PRODUT
	nAuxNF   := ZBX->ZBX_NF
	nVlrFrt  := ZBX->ZBX_VLRFRT
	nEstado  := ZBX->ZBX_ESTADO 
	
	MsProcTxt("Processando Produtos :"+ZBX->ZBX_PRODUT)
	
	While nAuxNF == ZBX->ZBX_NF
		nAcumQtd := nAcumQtd + ZBX->ZBX_QTDVEN
		ZBX->(DbSkip())
	EndDo
	nTotFrt := nVlrFrt / nAcumQtd                            //Calcula o valor do Frete por Kilo na NF
	ZBX->(DbSeek(xFilial("ZBX") + nAuxNF))
	While nAuxNF == ZBX->ZBX_NF
		RecLock("ZBX", .F.)
		Replace ZBX->ZBX_FRTKG With nTotFrt * ZBX->ZBX_QTDVEN // Calcula e Grava o Valor do Frete por item da NF
		MsUnlock()
		DbCommit()
		ZBX->(DbSkip())
	EndDo
EndDo        


Return



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Montando Matriz Impressao do Relatorio      ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Static Function MtrImp()
Local _ValFrt :=0


  	MsProcTxt( "Montando Matriz para Impressao do Relatorio..." )


// +--------------------------------------------------+
// | Cria Tabela ZBZ Base para Impressao do Relatorio |
// +--------------------------------------------------+
ZBZ->(DbSetOrder(1)) // filial + data inicio + data fim + versao + codigo do grupo + tipocli + estado
DbSelectArea("ZBX")
ZBX->(DbSetOrder(8)) // filial + data inicio + data fim + versao + codigo do grupo + tipoclie + estado
ZBX->(DbGoTop())
ZBX->(DbSeek(xFilial("ZBX") + dtos(mv_par01) + dtos(mv_par02) + _nVersao))
Do While ZBX->ZBX_DTINI == DTOS(MV_PAR01) .AND. ZBX->ZBX_DTFIM == DTOS(MV_PAR02) .AND. ZBX->ZBX_VERSAO == _nVersao
	
	// +----------------------------------------+
	// | Procura tupla na ZBZ seguindo o indice |
	// +----------------------------------------+
	If ! ZBZ->(DbSeek(ZBX->ZBX_FILIAL + ZBX->ZBX_DTINI + ZBX->ZBX_DTFIM + _nVersao + ZBX->ZBX_CODGRP + ZBX->ZBX_ESTADO))
		
		// +-------------------------------------+
		// | Se nao encontrar, cria tupla na ZBZ |
		// +-------------------------------------+
		RecLock("ZBZ", .T.)                           
		//Daniel 01/06/07
		//+-------------------------------------------+
		//|Se for FOB o valor de frete e igual a zero |
		//|Quando havia pedidos CIF e FOB dentro do   |
		//|mesmo grupo de produtos o relatorio estava |
		//|considerando o tipo de frete do primeiro   |
		//|pedido do grupo causando erro no calculo   |
		//|do preco liquido                           |
		//+-------------------------------------------+
		If ZBX->ZBX_TPFRT<>'C'
			_ValFrt:=0
		Else
			_ValFrt:=ZBX->ZBX_VLRFRT	 
		EndIf
		
		Replace ZBZ->ZBZ_FILIAL With ZBX->ZBX_FILIAL
		Replace ZBZ->ZBZ_DTINI  With ZBX->ZBX_DTINI
		Replace ZBZ->ZBZ_DTFIM  With ZBX->ZBX_DTFIM
		Replace ZBZ->ZBZ_VERSAO With _nVersao
		Replace ZBZ->ZBZ_ESTADO With ZBX->ZBX_ESTADO
		Replace ZBZ->ZBZ_CODGRP With ZBX->ZBX_CODGRP
		Replace ZBZ->ZBZ_DESGRP With ZBX->ZBX_DESGRP
		Replace ZBZ->ZBZ_QTDVEN With ZBX->ZBX_QTDVEN
		Replace ZBZ->ZBZ_VLRVEN With ZBX->ZBX_VLRVEN
		Replace ZBZ->ZBZ_QTDDEV With ZBX->ZBX_QTDDEV
		Replace ZBZ->ZBZ_VLRDEV With ZBX->ZBX_VLRDEV
		Replace ZBZ->ZBZ_VLRFRT With _ValFrt//ZBX->ZBX_VLRFRT
		Replace ZBZ->ZBZ_PICM   With ZBX->ZBX_PICM
		Replace ZBZ->ZBZ_VALICM With ZBX->ZBX_VLAICM
		Replace ZBZ->ZBZ_FRTKG  With ZBX->ZBX_FRTKG
		Replace ZBZ->ZBZ_VLRDF  With ZBX->ZBX_VLRDF
		Replace ZBZ->ZBZ_TPFRT  With ZBX->ZBX_TPFRT
		Replace ZBZ->ZBZ_FRTTBL With ZBX->ZBX_FRTTBL
		Replace ZBZ->ZBZ_TIPCLI With ZBX->ZBX_TIPCLI
		Replace ZBZ->ZBZ_PERC   With ZBX->ZBX_PERC
		MsUnlock()
		DbCommit()
	Else                                                                                 
		//Daniel 01/06/07
		//+-------------------------------------------+
		//|Se for FOB o valor de frete e igual a zero |
		//+-------------------------------------------+		
		If ZBX->ZBX_TPFRT<>'C'
			_ValFrt:=0
		Else
			_ValFrt:=ZBX->ZBX_VLRFRT	 
		EndIf

		// +----------------------------------+
		// | Se encontrar, acumula os valores |
		// +----------------------------------+
		RecLock("ZBZ", .F.)
		
		Replace ZBZ->ZBZ_QTDVEN With ZBZ->ZBZ_QTDVEN + ZBX->ZBX_QTDVEN
		Replace ZBZ->ZBZ_VLRVEN With ZBZ->ZBZ_VLRVEN + ZBX->ZBX_VLRVEN
		Replace ZBZ->ZBZ_QTDDEV With ZBZ->ZBZ_QTDDEV + ZBX->ZBX_QTDDEV
		Replace ZBZ->ZBZ_VLRDEV With ZBZ->ZBZ_VLRDEV + ZBX->ZBX_VLRDEV
		Replace ZBZ->ZBZ_VLRFRT With ZBZ->ZBZ_VLRFRT + _ValFrt//ZBX->ZBX_VLRFRT
		Replace ZBZ->ZBZ_VALICM With ZBZ->ZBZ_VALICM + ZBX->ZBX_VLAICM
		Replace ZBZ->ZBZ_VLRDF  With ZBZ->ZBZ_VLRDF  + ZBX->ZBX_VLRDF
		MsUnlock()
		DbCommit()
	Endif
	
	// +--------------------------------------------+
	// | Move para o proximo registro da tabela ZBX |
	// +--------------------------------------------+
	ZBX->(DbSkip())
EndDo

Return




//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//³Exibe a Messagem:Processando Preco Unitario, Bruto, Unitario Liquido do Grupo para o Estado      ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
Static Function PrcUBL ()


MsProcTxt( "Processando Preco Unitario, Bruto, Unitario Liquido do Grupo para o Estado..." )


// +----------------------------------------------------------------------------------+
// | Calcula o Preco Unitario Bruto e o Preco Unitario Liquido do Grupo para o Estado |
// +----------------------------------------------------------------------------------+
ZBZ->(DbSetOrder(1)) // filial + data inicio + data fim + versao + codigo do grupo + estado
ZBZ->(DbGoTop())
ZBZ->(DbSeek(xFilial("ZBZ") + dtos(mv_par01) + dtos(mv_par02) + _nVersao))

Private _ValorB := 0
Private _PesoL  := 0
Private _ValorL := 0

Do While ZBZ->ZBZ_DTINI == dtos(mv_par01) .AND. ZBZ->ZBZ_DTFIM == dtos(mv_par02) .AND. ZBZ->ZBZ_VERSAO == _nVersao
	
	RecLock("ZBZ", .F.)
	
	// +------------------------------------------------+
	// | Calcula o Valor Bruto  ---  Venda  - Devolucao |
	// +------------------------------------------------+
//	_ValorB := ZBZ->ZBZ_VLRVEN - ZBZ->ZBZ_VLRDEV
 	 _ValorB := ZBZ->ZBZ_VLRVEN - ZBZ->ZBZ_VLRDEV

	// +-----------------------------------------------+
	// |Calcula o Peso Liquido  ---  Venda - Devolucao |
	// +-----------------------------------------------+
	_PesoL  := ZBZ->ZBZ_QTDVEN - ZBZ->ZBZ_QTDDEV
	
	// +--------------------------------------------+
	// | Grava o Preco Bruto Unitario na tabela ZBZ |
	// +--------------------------------------------+
	   Replace ZBZ->ZBZ_PUB With _ValorB / _PesoL                         
	
	// +-------------------------------------------------------------------------------------+
	// | Calcula o Valor Liquido  --- Venda - Devolucao - Frete - ICMS - Desconto Financeiro |
	// +-------------------------------------------------------------------------------------+
	//Daniel 01/06/07                                                     
	//+----------------------------------------------------------------------------+
	//|Considerar sempre como CIF, a regra do FOB estou tratando na Funcao MtrImp()|
	//+----------------------------------------------------------------------------+	
	
	&&Mauricio - 02/05/17 - tratamento para tipo cliente e Percen			
	_lDif := .F.
	If ZBZ->ZBZ_TIPCLI == "F" .And. ZBZ->ZBZ_PERC == 0.11
	   _lDif := .T.		
	Endif
	
 	If ZBZ->ZBZ_TPFRT == 'C' // frete CIF
 	//  If ZBZ->ZBZ_ESTADO = 'SP'
    //    _ValorL := ZBZ->ZBZ_VLRVEN - ZBZ->ZBZ_VLRDEV - ZBZ->ZBZ_VLRFRT - ZBZ->ZBZ_VALICM - ZBZ->ZBZ_VLRDF //ALterado conforme chamado 005545 de 14/12/09 - Abatimento de 7% no valor
    // Else
    //    _ValorL := (ZBZ->ZBZ_VLRVEN*1.07) - ZBZ->ZBZ_VLRDEV - ZBZ->ZBZ_VLRFRT - ZBZ->ZBZ_VALICM - ZBZ->ZBZ_VLRDF //ALterado conforme chamado 005545 de 14/12/09 - Abatimento de 7% no valor        
    // EndIf   
       
       //ADICIONADO LEONARDO (HC) PARA A DEVOLUCAO DE 7% REFERENTE A ICMS PARA OUTROS ESTADOS, CHAMADO 006315 DYOGENES
       If ZBZ->ZBZ_ESTADO <> 'SP'
       		//_ValorL := (ZBZ->ZBZ_VLRVEN - ZBZ->ZBZ_VLRDEV - ZBZ->ZBZ_VLRFRT - ZBZ->ZBZ_VALICM - ZBZ->ZBZ_VLRDF)/0.93
       		_ValorL := (ZBZ->ZBZ_VLRVEN - ZBZ->ZBZ_VLRDEV - ZBZ->ZBZ_VLRFRT - ZBZ->ZBZ_VLRDF) &&Chamado 008062 em 05/11/10 retirado desconto e icms para outros estados.
       Else
       	    &&Mauricio - 02/05/17 - tratamento para tipo cliente e Percentual
		    IF _lDif      
		       _nDif := (ZBZ->ZBZ_VLRVEN * ZBZ->ZBZ_PERC) - (ZBZ->ZBZ_VLRVEN * GETMV("MV_#037ALQ"))
		    Else
		       _nDif := 0
		    Endif 
       
       		//_ValorL := ZBZ->ZBZ_VLRVEN - ZBZ->ZBZ_VLRDEV - ZBZ->ZBZ_VLRFRT - ZBZ->ZBZ_VALICM - ZBZ->ZBZ_VLRDF
       		_ValorL := ZBZ->ZBZ_VLRVEN - _nDif - ZBZ->ZBZ_VLRDEV - ZBZ->ZBZ_VLRFRT - ZBZ->ZBZ_VLRDF
       EndIf
    Else   // Frete FOB
   		If ZBZ->ZBZ_ESTADO <> 'SP'
      		//_ValorL := (ZBZ->ZBZ_VLRVEN - ZBZ->ZBZ_VLRDEV - ZBZ->ZBZ_VALICM - ZBZ->ZBZ_VLRDF)/0.93
      		_ValorL := (ZBZ->ZBZ_VLRVEN - ZBZ->ZBZ_VLRDEV - ZBZ->ZBZ_VLRDF)     &&Chamado 008062 em 05/11/10 retirado desconto e icms para outros estados.
     	Else
     	    &&Mauricio - 02/05/17 - tratamento para tipo cliente e Percentual
		    IF _lDif
		       _nDif := (ZBZ->ZBZ_VLRVEN * ZBZ->ZBZ_PERC) - (ZBZ->ZBZ_VLRVEN * GETMV("MV_#037ALQ"))
		    Else
		       _nDif := 0
		    Endif
     		//_ValorL := ZBZ->ZBZ_VLRVEN - ZBZ->ZBZ_VLRDEV - ZBZ->ZBZ_VALICM - ZBZ->ZBZ_VLRDF
     		_ValorL := ZBZ->ZBZ_VLRVEN - _nDif - ZBZ->ZBZ_VLRDEV  - ZBZ->ZBZ_VLRDF
     	EndIf
    Endif	                                                           
	
	// +----------------------------------------------+
	// | Grava o Preco Liquido Unitario na Tabela ZBZ |
	// +----------------------------------------------+

	   Replace ZBZ->ZBZ_PUL With _ValorL / _PesoL
	
	// +-------------------------------------------+
	// | Limpa as variaveis utilizadas no processo |
	// +-------------------------------------------+
	_ValorB := 0
	_PesoL  := 0
	_ValorL := 0
	
	MsUnlock()
	DbCommit()
	
	// +--------------------------------------------+
	// | Move para o proximo registro da tabela ZBZ |
	// +--------------------------------------------+
	ZBZ->(DbSkip())
EndDo

return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//³Exibe a Messagem: Gerando Diferenca Interestadual SP x Outros Estados      ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
Static Function DifSP ()
MsProcTxt( "Gerando Diferenca Interestadual SP x Outros Estados..." )


// +---------------------------------------------------------+
// | Calcula a Diferenca Interestadual - SP x Outros Estados |
// +---------------------------------------------------------+
ZBZ->(DbSetOrder(1)) // filial + data inicio + data fim + versao + codigo do grupo + estado
ZBZ->(DbGoTop())
ZBZ->(DbSeek(xFilial("ZBZ") + dtos(mv_par01) + dtos(mv_par02) + _nVersao))

Private _Filial   := ""
Private _DtIni    := ""
Private _DtFim    := ""
Private _GrupoAnt := ""
Private _EstAnt   := ""
Private _LiqSP    := 0

While ZBZ->ZBZ_DTINI == dtos(mv_par01) .AND. ZBZ->ZBZ_DTFIM == dtos(mv_par02) .AND. ZBZ->ZBZ_VERSAO == _nVersao
	
	_Filial   := ZBZ->ZBZ_FILIAL
	_DtIni    := ZBZ->ZBZ_DTINI
	_DtFim    := ZBZ->ZBZ_DTFIM
	_GrupoAnt := ZBZ->ZBZ_CODGRP
	_EstAnt   := ZBZ->ZBZ_ESTADO
	
	ZBZ->(DbSeek(_Filial + _DtIni + _DtFim + _nVersao + _GrupoAnt + "SP"))
	_LiqSP := ZBZ->ZBZ_PUL
	
	ZBZ->(DbSeek(_Filial + _DtIni + _DtFim + _nVersao + _GrupoAnt + _EstAnt))
	
	Do While _GrupoAnt == ZBZ->ZBZ_CODGRP
		If ZBZ->ZBZ_PUL > 0   // Alex Borges - 28/02/12  Acrescentado o IF para que a coluna Dif. não saia negativo
			RecLock("ZBZ", .F.)   
			Replace ZBZ->ZBZ_DIFSP With ZBZ->ZBZ_PUL - _LiqSP
			MsUnlock()
			DbCommit()
		End If // Alex Borges - 28/02/12
		_GrupoAnt := ""
		_EstAnt   := ""
		_LiqSP    := 0
		
		ZBZ->(DbSkip())
	EndDo
EndDo

return