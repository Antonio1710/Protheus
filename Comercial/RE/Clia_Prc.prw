#include "rwmake.ch"
#include "topconn.ch"
User Function CLIA_PRC      //// (_dDataIni , _dDatafim )


//
//  Primeira Parte......
//
//
// ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
// ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
// ±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
// ±±³Fun‡ao    ³ CLIATI1a ³ Autor ³ Rogerio Eduardo Nutti ³ Data ³          ³±±
// ±±³          ³ CLIATI1a ³Alerado³ Werner dos Santos     ³ Data ³07/04/2003³±±
// ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
// ±±³Descri‡ao ³ Resumo de Clientes Ativos                                  ³±±
// ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
// ±±³ Uso      ³ Espec¡fico ADORO ALIMENTICIA                               ³±±
// ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
// ±±³Observacao³ Inicio em Outubro/2002                                     ³±±
// ±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
// ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
// ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
// Relatorio em Adoro / Comercial / Geral
//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



Public titulo  :="Processo de CLIENTES ATIVOS"
Public cDesc1  :="Relatorios de Clientes Ativos"
Public cDesc2  :=""
Public cDesc3  :=""
Public cbCont  :=""
Public cabec1  :=""
Public cabec2  :=""
Public cString :="SD2"
Public cPerg   :="CLIAT3"
Public aReturn := { "LandScap", 1,"Administracao", 1, 2, 1, "",0 }
Private aOrd    := {}
Public nomeprog:="CLIAT3"
Public nLastKey:=0
Public Tamanho :="G"
Public li      :=50
Public limite  :=220
Public lRodape :=.F.
Public wnrel   :="CLIAT3"
Public lEnd         := .F.
Public lAbortPrint  := .F.
Public CbTxt        := ""
Public  nTipo       := 15
//Private cbtxt      := Space(10)
Public  cbcont      := 00
Public  CONTFL      := 01
Public  m_pag       := 01
Private _cTesValid  := Space(1)
Private	_cPrdValid  := Space(1)

Private _cContrSeq  := 'MV_CLIATI '
Private 		_nValFrete := 0  

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Resumo de Clientes Ativos')
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CATVIMP  ³ Autor ³ Rogerio Eduardo Nutti ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CLIATIV                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Arquivos TEMPORARIO -  Precos Medios            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo TEMPORARIO - Precos Medios Empresa ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/

/*/

//_aEmpProd := {}

//Aadd( _aEmpProd, {"PE_FILIAL" ,"C",02,0} )   // Filial
//Aadd( _aEmpProd, {"PE_DATA" ,"D",08,0} )     // Data
//Aadd( _aEmpProd, {"PE_CODIGO"  ,"C",15,0} )  // Codigo do Produto
//Aadd( _aEmpProd, {"PE_QUANT"  ,"N",12,4} )   // Quantidade
//Aadd( _aEmpProd, {"PE_VALOR"  ,"N",12,4} )   // Valor
//Aadd( _aEmpProd, {"PE_PMGRUPO","N",09,4} )   // Preco Medio Grupo
//_cFilePE    := CriaTrab(_aEmpProd,.T.)
//_cIndexPE   := "PE_FILIAL+DTOS(PE_DATA)+PE_CODIGO"
//dbUseArea(.T.,,_cFilePE,"PE",.T.,.F.)
//IndRegua( "PE", _cFilePE, _cIndexPE,,,"Criando Indice ..." )
// Forco processar sem pedir as perguntas
// parametro "_cPrcPrec" recebido o programa "CLIATI1a"




If	pergunte(cPerg,.T.)=.f.
	Return
Endif

_Processa := mv_par03
_dDATAINI  := mv_par01
_dDATAFIM := mv_par02

If nLastKey == 27
	Return
Endif

//IF _Processa = 1
//    _dDataIni := DDATABASE - 1
//    _dDatafim := DDATABASE
//Endif

nTipo := If(aReturn[4]==1,15,18)


// Incrementa para cada Relatorio Gerado
dbSelectArea("SX6")
DbSetorder(1)
If dbSeek("  "+_cContrSeq)
	RecLock("SX6",.F.)  // com .f. sem append blank
	_cTesValid := SUBSTR(X6_CONTEUD,11,200)
	_cPrdValid := SUBSTR(X6_CONTSPA,1,100)
	
	MsUnlock()
Endif


dbSelectArea("SZ4")
dbSetOrder(2)
Processa({|| RunCon0a()},"Excluindo  Preco Medio  ...")


Static Function RunCon0a()
ProcRegua(RecCount())

// Verifica se tem o periodo e exclui para gerar novamente
dbGoTop()
dbSeek( xFilial("SZ4")+DTOS(_dDataIni)  )
Do While !Eof() .and. SZ4->Z4_FILIAL == xFilial("SZ4") .and.;
	SZ4->Z4_DATA <= _dDatafim
	IncProc("Excluindo Preco Medio do dia "+DTOC(SZ4->Z4_DATA)+" Prd: "+SZ4->Z4_CODIGO)
	RecLock("SZ4",.f.)
	DBDELETE()
	MsUnlock()
	dbskip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo TEMPORARIO - Precos Medios Regiao  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//_aRegProd := {}
//Aadd( _aRegProd, {"Z5_FILIAL" ,"C",02,0} )  // Filial
//Aadd( _aRegProd, {"Z5_DATA" ,"D",08,0} )    // Data
//Aadd( _aRegProd, {"Z5_SEGTO" ,"C",03,0} )   // Data
//Aadd( _aRegProd, {"Z5_CODIGO"  ,"C",15,0} )  // Codigo do Produto
//Aadd( _aRegProd, {"Z5_QUANT","N",12,4} )     // Quantidade
//Aadd( _aRegProd, {"Z5_VALOR","N",12,4} )     // Valor
//Aadd( _aRegProd, {"Z5_PMGRUPO","N",09,4} )  // Preco Medio Grupo
//_cIndexPR   := "Z5_FILIAL+DTOS(Z5_DATA)+Z5_SEGTO+Z5_CODIGO"
//_cFilePR    := CriaTrab(_aRegProd,.T.)
//dbUseArea(.T.,,_cFilePR,"PR",.T.,.F.)
//IndRegua( "PR", _cFilePR, _cIndexPR,,,"Criando Indice ..." )
dbSelectArea("SZ5")
dbSetOrder(2)
Processa({|| RunCon0b()},"Excluindo  Preco Medio  ...")


Static Function RunCon0b()
ProcRegua(RecCount())

// Verifica se tem o periodo e exclui para gerar novamente
dbGoTop()
dbSeek( xFilial("SZ5")+DTOS(_dDataIni)  )
Do While !Eof() .and. SZ5->Z5_FILIAL == xFilial("SZ5") .and.;
	SZ5->Z5_DATA <= _dDatafim
	IncProc("Excluindo Preco Medio do dia "+DTOC(SZ5->Z5_DATA)+" Prd: "+SZ5->Z5_CODIGO)
	RecLock("SZ5",.f.)
	DBDELETE()
	MsUnlock()
	dbskip()
Enddo



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo TEMPORARIO - Precos Medios Vendedor³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//_aVedProd := {}
//Aadd( _aVedProd, {"PV_FILIAL"   ,"C",02,0} )  // Filial
//Aadd( _aVedProd, {"PV_DATA"     ,"D",08,0} )    // Data
//Aadd( _aVedProd, {"PV_SEGTO"    ,"C",03,0} )    // Segmento
//Aadd( _aVedProd, {"PV_REGIAO"   ,"C",06,0} )  // Regiao
//Aadd( _aVedProd, {"PV_CODIGO"   ,"C",15,0} )  // Codigo do Produto
//Aadd( _aVedProd, {"PV_QUANT"    ,"N",12,4} )     // Quantidade
//Aadd( _aVedProd, {"PV_VALOR"    ,"N",12,4} )     // Valor
//Aadd( _aVedProd, {"PV_PMGRUPO"  ,"N",09,4} )   // Preco Medio Grupo
//_cIndexPV   := "PV_FILIAL+DTOS(PV_DATA)+PV_SEGTO+PV_REGIAO+PV_CODIGO"
//_cFilePV    := CriaTrab(_aVedProd,.T.)
//dbUseArea(.T.,,_cFilePV,"PV",.F.,.F.)
//IndRegua( "PV", _cFilePV, _cIndexPV,,,"Criando Indice ..." )
dbSelectArea("SZ6")
dbSetOrder(2)
Processa({|| RunCon0c()},"Excluindo  Preco Medio  ...")


Static Function RunCon0c()
ProcRegua(RecCount())

// Verifica se tem o periodo e exclui para gerar novamente
dbGoTop()
dbSeek( xFilial("SZ6")+DTOS(_dDataIni)  )
Do While !Eof() .and. SZ6->Z6_FILIAL == xFilial("SZ6") .and.;
	SZ6->Z6_DATA <= _dDatafim
	IncProc("Excluindo Preco Medio do dia "+DTOC(SZ6->Z6_DATA)+" Prd: "+SZ6->Z6_CODIGO)
	RecLock("SZ6",.f.)
	DBDELETE()
	MsUnlock()
	dbskip()
Enddo


dbSelectArea("SZ4")
dbSetOrder(1)
dbGoTop()


dbSelectArea("SZ5")
dbSetOrder(1)
dbGoTop()


dbSelectArea("SZ6")
dbSetOrder(1)
dbGoTop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa Notas Fiscais de Saida para Atualizar Preço Medio  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ * * *   N F ' S   S A I D A   * * *                                                         ³
//³                                                                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
&&Chamado 006302 Mauricio - tratamento para escolher filiais-implementado Select.
//dbSelectArea("SD2")
//dbSetOrder(5)       // 5 na 5.08    e    7 na 6.09  D2_FILIAL+DTOS(D2_EMISSAO)+D2_NUMSEQ

If Select ("NSD2") > 0
   DbSelectArea("NSD2")
   NSD2->(DbCloseArea())
Endif   
					
_cQueryTRB := "SELECT * FROM "+RetSqlName("SD2")+ " WHERE D2_FILIAL IN ("+ALLTRIM(MV_PAR04)+") AND "+;
"D2_EMISSAO BETWEEN '"+dtos(_dDataIni)+"' AND '"+dtos(_dDataFim)+"' AND "+;
""+RetSqlName("SD2")+ ".D_E_L_E_T_= '' ORDER BY D2_EMISSAO, D2_NUMSEQ"
					          
TCQUERY _cQueryTRB new alias "NSD2"

Processa({|| RunCon1()},"Gerando Preco Medio  ...")
Return

Static Function RunCon1()
ProcRegua(RecCount())

///////////If _cMataVar > 100   //   Depois mata
DBSELECTAREA("NSD2")
dbGoTop()
//dbSeek( xFilial("SD2")+DtoS(_dDataIni), .T.)

Do While !Eof() //.and. SD2->D2_FILIAL == xFilial("SD2") .and.;
	//SD2->D2_EMISSAO <= _dDatafim
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Despresa operacoes que nao sao Saidas            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Se Tes nao e valido nao considera
	_cValido := NSD2->D2_TES $_cTesValid
	_cTpPrd  := NSD2->D2_TP  $_cPrdValid
	If NSD2->D2_Tipo $"DB" .or. ! _cValido .or. (NSD2->D2_QUANT +  NSD2->D2_TOTAL) <= 0  .or. ! _cTpPrd
		dbSelectArea("NSD2")
		Dbskip()
		Loop
	Endif
	
	IncProc("Preço Medio do dia "+DTOC(STOD(NSD2->D2_EMISSAO))+" Prd: "+NSD2->D2_Cod)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza as variaveis do Arquivo SD2                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cD2Cliente   := NSD2->D2_Cliente
	_cD2Loja       := NSD2->D2_Loja
	_cD2Prodcod := NSD2->D2_Cod
	_dD2Data	     := STOD(NSD2->D2_Emissao)
	_nD2QtdEntr  := NSD2->D2_QUANT
	_nD2VlrTotal  := NSD2->D2_TOTAL
	_cGrupo        := NSD2->D2_GRUPO
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona SD2 com dados da NF Venda gravados a  devolucao                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  NSD2->D2_QTDEDEV +  NSD2->D2_VALDEV > 0
		_nD2QtdDev   := NSD2->D2_QTDEDEV
		_nD2VlrDev   := NSD2->D2_VALDEV
	Else
		_cD2Pedido   := Space(6)
		_cD2ItemPV   := Space(2)
		_nD2QtdDev   := 0
		_nD2VlrDev   := 0
	Endif
	// Posiciona no Pedido para pegar o Tipo de Frete
	dbSelectArea("SC5")
	dbSetOrder(1) // A1_FILIAL + C5_NUM
	//If dbSeek( xFilial("SC5") +  SD2->D2_PEDIDO )
	If dbSeek( NSD2->D2_FILIAL +  NSD2->D2_PEDIDO )
		_cTip_Frt := C5_TPFRETE
	Else
		_cTip_Frt := ''
	Endif
	// Descrição do Produto
	_cAlias  := "SB1"      
	_cChave := xFilial("SB1")+NSD2->D2_COD
	_cBusca:= "B1_DESC"
	_cDescProd := 	Posicione(_cAlias,1,_cChave ,_cBusca)
	// Calcular o Valor do Desconto Finaceiro
	// Posiciona no Cadastro de Clientes
	dbSelectArea("SA1")
	dbSetOrder(1) // A1_FILIAL + A1_COD + A1_LOJA
	If dbSeek( xFilial("SA1") +  NSD2->D2_CLIENTE + NSD2->D2_LOJA )
		// desconto financeiro após subtrair as devoluções.
		_nVal_Fin :=  ( _nD2VlrTotal -  _nD2VlrDev ) * (SA1->A1_DESC / 100)
	Else
		_nVal_Fin :=  0
	Endif
	_cA3Regiao  := Space(6)
	_cCodSup	   := Space(6)
	dbSelectArea("SF2")
	dbSetOrder(1)   // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA
	//If dbSeek( xFilial("SF2") + SD2->(D2_DOC + D2_SERIE + D2_CLIENTE  + D2_LOJA ) )
	If dbSeek( NSD2->D2_FILIAL + NSD2->(D2_DOC + D2_SERIE + D2_CLIENTE  + D2_LOJA ) )
		_cF2Vend1   := SF2->F2_VEND1   //No caso dos precos medios considera a venda realizada
		_cPlaca        := SF2->F2_PLACA
	Else
		_cF2Vend1   := Space(6)
		_cPlaca        := Space(6)
	Endif
	
	// Valor do Frete
	//*****************//**************
	// +------------+
	// | Frete real |
	// +------------+
	// Verifica o tipo de Frete conforme pedido de venda
	If _cTip_Frt =  'C'  // frete CIF
		_nValFrete := 0
		////If mv_par06 = 1 // Parâmetro para saber se frete real ou tabela
		If _nValFrete > 1000000
			SZK->(DbSetOrder(14)) // Filial + Placa + Roteiro + Data Emissao
			SZK->(DbGoTop())
			FV9->(DbSetOrder(5)) // Indexa por filial + regial + data
			FV9->(DbGoTop())
			//Estou posicionado no pedido
			//SZK->(DbSeek(xFilial("SZK") + SC5->C5_PLACA + SC5->C5_ROTEIRO + TMP01->(D2_EMISSAO)))
			SZK->(DbSeek(xFilial("SZK") + SC5->C5_PLACA + SC5->C5_ROTEIRO + NSD2->(D2_EMISSAO)))
			_nValFrete := SZK->ZK_VALFRET
		Else
			dbSelectArea("FV9")		
			FV9->(DbSetOrder(5)) // Indexa por filial + regial + data												
			// +----------------------------------+
			// | Calcula com base no Frete Padrao |
			// +----------------------------------+
			_cEstFV9 := NSD2->D2_EST + "00"
			_dEmisNF := STOD(NSD2->D2_EMISSAO)
			//Posiciona no primeiro registro da tabela
			FV9->(DbSeek(xFilial("FV9") + _cEstFV9,.T.))
			// Verifico se esta dentro da data da nota fiscal
			While ! FV9->(Eof()) .and. _cEstFV9 == FV9->(FV9_REGIAO)
				If  DTOS(FV9->(FV9_DTVAL)) <= DTOS(_dEmisNF)
					If FV9->(FV9_VLTON) > 0
						_nValFrete := FV9->(FV9_VLTON) / 1000
						_nFrtTbl   := FV9->(FV9_VLTON) / 1000
					Endif
				Endif
				FV9->(DbSkip())
			EndDo
			// Valor do Frete por Quilo
			_nValFrete := (_nValFrete * NSD2->D2_QUANT)
		Endif
	Endif
	
	dbSelectArea("NSD2")
	// Desconto ICMS
	// +-------------------------------------------------------------------------------------+
	// | Calcula o Valor Liquido  --- Venda - Devolucao - Frete - ICMS - Desconto Financeiro |
	// +-------------------------------------------------------------------------------------+
	//
	_nValImcs    := 0
	_nPerc_Dev  := 0
	// Verifico se a Devolução não é total, se for não desconto ICMS e se tiver desconto proporcionalmente
	If  NSD2->D2_VALDEV > 0
		// Verifico a proporção da devolução
		If  NSD2->D2_VALDEV / NSD2->D2_TOTAL=1
			// Se é total é zero
			_nPerc_Dev   := 0
		Else
			// Calculo da proporção
			_nPerc_Dev   :=  1 - ( NSD2->D2_VALDEV / NSD2->D2_TOTAL )
		Endif
	Else
		_nPerc_Dev   :=  1
	Endif
	// Calculo do Valor do ICM
	_nValImcs :=  (NSD2->D2_BASEICM * _nPerc_Dev   * NSD2->D2_PICM /100)
	// Valor do Preço total do Item descontando:
	//  Frete
	//  Desconto Financeito
	//  Icms
	_nD2VlrTotal  := NSD2->D2_TOTAL - _nD2VlrDev             // Valor da venda menos os descontos
	_nD2VlrLiqu   := NSD2->D2_TOTAL - _nD2VlrDev -  _nValFrete - _nValImcs -  _nVal_Fin    // Valor da venda menos os descontos
	
	//*****************//**************
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona em SA3010 para buscar dados do Vendedor                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA3")         // // Nao pegar direto do SF2-F2_REGIAO pois nao esta atualizado (Porque)
	dbSetOrder(1)         // A3_FILIAL+A3_COD
	If dbSeek( xFilial("SA3")+ _cF2VEND1 )
		_cA3Regiao  := SA3->A3_REGIAO
		_cCodSup    :=	SA3->A3_CODSUP		
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona em SZR010 para buscar dados do Segmento no Supervisor     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SZR")
	dbSetOrder(1)         // ZR_FILIAL+ZR_CODIGO
	If dbSeek( xFilial("SZR") + SA3->A3_CODSUP )          // SA3->A3_SUPER
		_cZRSegMerc := SZR->ZR_SEGMERC  // O Segmento de mercado esta debaixo do supervisor !!!
	Else
		_cZRSegMerc := Space(3)
	Endif
	
	
	// Vou forcar voltar para SD2
	dbSelectArea("NSD2")
	&&Mauricio 14/03/12 - apenas utilizado para debug e achar o problema - vide OS.
	//IF ALLTRIM(_cD2Prodcod) <> "189916"
	//   dbSelectArea("NSD2")
	//   dbSkip()
	//   loop
	//Endif

	If _cZRSegMerc = "000"    // Alex Borges - 15/03/2012
     	dbSkip()
	   loop
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Preco Medio Empresa        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	
	dbSelectArea("SZ4")         //  "Z4_FILIAL+DTOC(Z4_DATA)+Z4_SEGTO+Z4_CODIGO"
	dbSetOrder(1)
	If dbSeek( xFilial("SZ4")+DTOS(_dD2Data) + _cD2Prodcod )
		RecLock("SZ4",.F.)  // com .f. sem append blank
		Replace  Z4_QUANT      With Z4_QUANT + (_nD2QtdEntr - _nD2QtdDev)      // Quantidade vendida menos a devolvida
		Replace  Z4_VALOR      With Z4_VALOR +  _nD2VlrTotal       // Valor da venda menos os descontos
		Replace  Z4_VALLIQ      With Z4_VALLIQ + _nD2VlrLiqu 		 //  Valor da venda menos os descontos
		IF Z4_VALOR > 0 .AND. Z4_QUANT > 0
			Replace  Z4_PMGRUPO    With (Z4_VALLIQ / Z4_QUANT)           // Prelo medio
			Replace  Z4_PMBRT          With (Z4_VALOR / Z4_QUANT)           // Prelo medio			
		ENDIF
	Else
		RecLock("SZ4",.T.)   // com .t. com append blank
		Replace  Z4_FILIAL        With xFilial("SZ4")                 // Filial
		Replace  Z4_DATA         With  _dD2Data                       // Data de emissao
		Replace  Z4_CODIGO     With  _cD2Prodcod                   // Codigo do Produto
		Replace  Z4_DESPRD    With  _cDescProd                    // Descrição do Produto
		Replace  Z4_GRUPO      With	 _cGrupo                       // Grupo do Produto
		Replace  Z4_QUANT      With _nD2QtdEntr - _nD2QtdDev        // Quantidade vendida menos a devolvida
		Replace  Z4_VALOR      With  _nD2VlrTotal       // Valor da venda Bruta
		Replace  Z4_VALLIQ      With  _nD2VlrLiqu 		 //  Valor da venda menos os descontos
		IF Z4_VALLIQ > 0 .AND. Z4_QUANT > 0
			Replace  Z4_PMGRUPO    With Z4_VALLIQ / Z4_QUANT            // Prelo medio Liquido      
			Replace  Z4_PMBRT          With Z4_VALOR / Z4_QUANT           // Prelo medio Bruto						
		Endif
	Endif
	MsUnlock() // // //  Rogerio Ok ???
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Preco Medio Regiao           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SZ5")             // "Z5_FILIAL+DTOS(Z5_DATA)+Z5_SEGTO+Z5_SUPERV+Z5_CODIGO"
	dbSetOrder(1)
	If dbSeek( xFilial("SZ5")+ DTOS(_dD2Data) +_cZRSegMerc +_cD2Prodcod)
		RecLock("SZ5",.F.)  // com .f. sem append blank
		Replace  Z5_QUANT      With  Z5_QUANT +(_nD2QtdEntr  - _nD2QtdDev )      // Quantidade vendida menos a devolvida
		Replace  Z5_VALOR      With  Z5_VALOR + _nD2VlrTotal       // Valor da venda Bruta
		Replace  Z5_VALLIQ      With  Z5_VALLIQ + _nD2VlrLiqu 		 //  Valor da venda menos os descontos
		IF Z5_VALLIQ > 0 .AND. Z5_QUANT > 0
			Replace  Z5_PMGRUPO    With  Z5_VALLIQ / Z5_QUANT           // Prelo medio Liquido
			Replace  Z5_PMBRT          With Z5_VALOR / Z5_QUANT           // Prelo medio	Bruto					
		Endif
	Else
		RecLock("SZ5",.T.)   // com .t. com append blank
		Replace  Z5_FILIAL      With xFilial("SZ5")                // Filial
		Replace  Z5_DATA        With _dD2Data                      // Data de emissao
		Replace  Z5_SEGTO      With _cZRSegMerc                   // Segmento    
		Replace  Z5_CODIGO     With _cD2Prodcod                   // Codigo do Produto
		Replace  Z5_DESPRD    With  _cDescProd                    // Descrição do Produto
		Replace  Z5_GRUPO      With	 _cGrupo                       // Grupo do Produto
		Replace  Z5_QUANT      With _nD2QtdEntr - _nD2QtdDev     // Quantidade vendida menos a devolvida
		Replace  Z5_VALOR      With _nD2VlrTotal        // Valor da venda menos os descontos
		Replace  Z5_VALLIQ      With  _nD2VlrLiqu 	 	 //  Valor da venda menos os descontos
		IF Z5_VALLIQ > 0 .AND. Z5_QUANT > 0
			Replace  Z5_PMGRUPO    With  Z5_VALLIQ / Z5_QUANT          // Prelo medio Liquido
			Replace  Z5_PMBRT          With  Z5_VALOR / Z5_QUANT           // Prelo medio Bruto									
		Endif
	Endif
	MsUnlock()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Preco Medio Regiao           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SZ6")             // Z6_FILIAL+Z6_DATA+Z6_SEGTO+Z6_CODIGO
	dbSetOrder(1)
	If dbSeek( xFilial("SZ6")+DTOS(_dD2Data) +_cZRSegMerc + _cA3Regiao +_cD2Prodcod )
		RecLock("SZ6",.F.)  // com .f. sem append blank
		Replace  Z6_QUANT      With  Z6_QUANT + (_nD2QtdEntr  - _nD2QtdDev)     // Quantidade vendida menos a devolvida
		Replace  Z6_VALOR      With  Z6_VALOR +  _nD2VlrTotal       // Valor da venda menos os descontos
		Replace  Z6_VALLIQ      With  Z6_VALLIQ + _nD2VlrLiqu 	 	 //  Valor da venda menos os descontos
		IF Z6_VALOR > 0 .AND. Z6_QUANT > 0
			Replace  Z6_PMGRUPO    With Z6_VALLIQ  / Z6_QUANT           // Prelo medio Liquido
			Replace  Z6_PMBRT          With Z6_VALOR / Z6_QUANT           // Prelo medio	Bruto								
		Endif
	Else
		RecLock("SZ6",.T.)   // com .t. com append blank
		Replace  Z6_FILIAL       With xFilial("SZ6")                 // Filial
		Replace  Z6_DATA        With _dD2Data                       // Data de emissao
		Replace  Z6_SEGTO      With _cZRSegMerc                    // Divisao do Segmento
		Replace  Z6_REGIAO     With _cA3Regiao                     // Regiao
		Replace  Z6_CODIGO     With _cD2Prodcod                    // Codigo do Produto
		Replace  Z6_DESPRD    With  _cDescProd                    // Descrição do Produto
		Replace  Z6_GRUPO      With	 _cGrupo                       // Grupo do Produto
		Replace  Z6_QUANT      With _nD2QtdEntr  - _nD2QtdDev      // Quantidade vendida menos a devolvida
		Replace  Z6_VALOR      With  _nD2VlrTotal      // Valor da venda menos os descontos
		Replace  Z6_VALLIQ      With  _nD2VlrLiqu 	 	 //  Valor da venda menos os descontos
		IF Z6_VALLIQ > 0 .AND. Z6_QUANT > 0
			Replace  Z6_PMGRUPO    With Z6_VALLIQ / Z6_QUANT            // Prelo medio Liquido
			Replace  Z6_PMBRT          With Z6_VALOR / Z6_QUANT           // Prelo medio	Bruto											
		Endif
	Endif
	MsUnlock()
	dbSelectArea("NSD2")
	dbSkip()
Enddo

Return
