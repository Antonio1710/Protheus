//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de Includes                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#Include "Protheus.CH"
#Include "TopConn.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ADFatDev  ³ Autor ³ Celso Costa          ³ Data ³20/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio - Devolucoes de faturamento                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_ADFatDev()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ADFatDev()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _cReport	:= "ADFATDEV"
Local _cAlias	:= "SD2"
Local _cTitle	:= "Relacao de Devolucoes"
Local _cDesc	:= "Este relatorio apresenta registros para analise de Devolucoes"
Local _lInd		:= .T.
                            
U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Private                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Private _cPerg	:= "RLOGDV"
Private _cPerg	:= PADR("RLOGDV",10," ")
Private _nTipo	:= 18

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pergunte                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ValidPerg()

If !Pergunte( _cPerg, .T. )
	Return ( Nil )
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Emissao                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If FindFunction( "TRepInUse" ) .And. TRepInUse()
//	MPReport( _cReport, _cAlias, _cTitle, _cDesc,, _lInd )	
//Else
ImpRelFatDV()
//EndIf

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ImpRelFatDV³ Autor ³ Celso Costa          ³ Data ³20/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpRelFatDV()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpRelFatDV()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local WnRel		:= "ADFATDEV"
Local cbCont	:= 00
Local Cabec1	:= "RELACAO DE DEVOLUCOES"
Local Cabec2	:= ""
Local Cabec3	:= ""
Local cString	:= "SD2"
Local Tamanho	:= "G"
Local Limite	:= 80
Local cDesc1	:= "Relacao de Devolucoes"
Local cDesc2	:= "Ira imprimir os dados das devolucoes do faturamento"
Local cDesc3	:= "de acordo com a configuracao do usuario."
Local aOrd		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Private                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aReturn	:= { "Zebrado", 01, "Administracao", 02, 02, 01, "", 01 }
Private aLinha		:= {}
Private NomeProg	:= "ADFATDEV"
Private nLastKey	:= 00
Private _nlin		:= 80
Private m_pag		:= 01
Private Titulo		:= "Relacao de Devolucoes"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Emite relatorio                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WnRel := SetPrint( cString, WnRel, _cPerg, @Titulo, cDesc1, cDesc2, cDesc3, .F., aOrd,.T., Tamanho,, .T. )

If nLastKey = 27 
	dbClearFilter()
	Return ( Nil )
EndIf

SetDefault( aReturn, cString )

If nLastKey = 27
    dbClearFilter()
   Return
EndIf

_nTipo := Iif( aReturn[ 04 ] == 01, 15, 18 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime relatorio                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus( {|lEnd| RFatDVImp( @lEnd, Cabec1, Cabec2, Cabec3, Limite, Tamanho, cbCont, WnRel ) }, Titulo )

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RFatDVImp  ³ Autor ³ Celso Costa          ³ Data ³20/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chamado do relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RFatDVImp()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RFatDVImp( lEnd, Cabec1, Cabec2, Cabec3, Limite, Tamanho, cbCont, WnRel )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local Cabec1			:= "Vendedor  Cliente                          Placa    Pedido  N.F.    Produtos                                                 Saida      Devolvido  Motivo                        Responsavel"
Local Cabec2			:= ""
Local cbTxt				:= Space( 10 )
Local _cQuery			:= ""
Local _cChave			:= ""
Local _lImpr			:= .T.
Local _lSomaNF			:= .F.
Local _lSomaNFD			:= .F.
Local _nTotReg			:= 00
Local _nAscan			:= 00
Local _nCtOcorr		:= 00
Local _aOcorrencias	:= {}
Local _cNomeResp		:= ""
Local _nTRNoDev		:= 00
Local _nTRNoPDev		:= 00
Local _nTRKGDev		:= 00
Local _nTRKGPDev		:= 00
Local _nTRReDev		:= 00
Local _nTRRePDev		:= 00
Local _nTRVdDev		:= 00
Local _nTotSaida		:= 00
Local _nTotDevol		:= 00
Local _nNParciais		:= 00
Local _nKParciais		:= 00
Local _nRParciais		:= 00
Local _aNFs				:= {}
Local _aNFsD			:= {}
Local _aTotais			:=	{	{ 00, 00, 00 },;	// 01 - Total das Devolucoes
									{ 00, 00, 00 },;	// 02 - Total das Vendas
									{ 00, 00, 00 },;	// 03 - Longo percurso (fora SP - exceto RJ)
									{ 00, 00, 00 },;	// 04 - Devolucoes parciais
									{ 00, 00, 00 },;	// 05 - Acerto Contabil
									{ 00, 00, 00 },;	// 06 - Venda Acima do Estoque
									{ 00, 00, 00 },;	// 07 - Total das Devolucoes (Estadual - CIF)
									{ 00, 00, 00 },;	// 08 - Total das Devolucoes (Estadual - FOB)
									{ 00, 00, 00 },;	// 09 - Total das Devolucoes (InterEstadual - CIF)
									{ 00, 00, 00 },;	// 10 - Total das Devolucoes (InterEstadual - FOB)
									{ 00, 00, 00 },;	// 11 - Total das Devolucoes (Exportacao - CIF)
									{ 00, 00, 00 },;	// 12 - Total das Devolucoes (Exportacao - FOB)
									{ 00, 00, 00 },;	// 13 - Sinistro
									{ 00, 00, 00 },;	// 14 - Sistema
									{ 00, 00, 00 },;	// 15 - Faturamento
									{ 00, 00, 00 },;	// 16 - Total das Vendas SubProduto
									{ 00, 00, 00 },;	// 17 - Total das Devolucoes SubProduto (Estadual - CIF)
									{ 00, 00, 00 },;	// 18 - Total das Devolucoes SubProduto (Estadual - FOB)
									{ 00, 00, 00 },;	// 19 - Total das Devolucoes SubProduto (InterEstadual - CIF)
									{ 00, 00, 00 },;	// 20 - Total das Devolucoes SubProduto (InterEstadual - FOB) 
									{ 00, 00, 00 },;	// 21 - Total das Devolucoes SubProduto (InterEstadual - FOB)
									{ 00, 00, 00 } }	// 22 - Total de NF´s emitidas de outros meses devolvidos no periodo.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o layout do Cabecalho                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
//000000000011111111112222222222333333333344444444445555555555666666666677777777778888888888999999999900000000001111111111222222222233333333334444444444555555555566666666667777777777888888888899999999
//012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567
//Relacao das Devolucoes no periodo de 99/99/99 ate 99/99/99
//Vendedor  Cliente                          Placa    Pedido  N.F.    Produtos                                                 Saida      Devolvido  Motivo                        Responsavel
//999999    999999/99  XXXXXXXXXXXXXXXXXXXX  DXX9999  999999  999999  999999999999999  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  99.999.999,99  99.999.999,99  999999  XXXXXXXXXXXXXXXXXXXX  999999  XXXXXXXXXXXXXXXXX
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//Ocorrencias de Devolucoes no periodo de 99/99/99
//Responsaveis        Motivos                       Devolucoes                  Devolucoes                  Devolucoes               Vendas
//                                               No.            %            KG             %            R$             %
//XXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXXX  99.999.999,99  99.999,9999  99.999.999,99  99.999,9999  99.999.999,99  99.999,9999  99.999,9999
//-----------------------------------------------------------------------------------------------------------------------------------------
//Resumo das Devolucoes no periodo de 99/99/99 ate 99/99/99
//Resumo                                       Quantidade NFS       Quantidade KG         Valor em R$
//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     999.999.999,99      999.999.999,99      999.999.999,99
//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX        99.999,9999         99.999,9999         99.999,9999
//---------------------------------------------------------------------------------------------------

Titulo := "Relacao de Devolucoes no periodo de " + DtoC( mv_par01 ) + " ate " + DtoC( mv_par02 ) + " - ordem " + Iif( mv_par03 == 01, "Data Digitacao", "Data Emissao NF" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Conta registros que serao processados                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_nTotReg := CntRegs()

If _nTotReg <= 00

	MsgStop( "Nao existem registros para a selecao efetuada", "Atencao" )

	If aReturn[ 05 ] = 01
		Set Printer To
		Commit
		OurSpool( WnRel )
	EndIf

	MS_Flush()

	Return ( Nil )

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona registros                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cQuery := "SELECT C5_VEND1, D2_CLIENTE, D2_LOJA, C5_NOMECLI, C5_PLACA, C5_NUM, D2_DOC, D2_COD, B1_DESC, D2_QUANT, D2_QTDEDEV, D2_VALDEV, D2_TOTAL, ZD_MOTIVO, ZD_DESCMOT, ZD_RESPONS, ZD_RESPNOM, D2_EST, C5_TPFRETE, ZD_DTDEV, D2_EMISSAO, D2_CF, D2_GRUPO "
_cQuery += "FROM "
_cQuery += RetSqlName( "SC5" ) + " C5, "
_cQuery += RetSqlName( "SB1" ) + " B1, "
_cQuery += RetSqlName( "SZD" ) + " ZD RIGHT OUTER JOIN "  
_cQuery += RetSqlName( "SD2" ) + " D2 ON "
//_cQuery += "ZD.ZD_NUMNF = D2.D2_DOC AND ZD.ZD_SERIE = D2.D2_SERIE AND ZD.D_E_L_E_T_ = '' " Alex Borges - 01/12/11
_cQuery += "ZD.ZD_NUMNF = D2.D2_DOC AND ZD.ZD_SERIE = D2.D2_SERIE AND ZD.D_E_L_E_T_ = '' AND ZD.ZD_FILIAL = D2.D2_FILIAL AND ZD.ZD_DEVTOT <> 'E' "
_cQuery += "WHERE "
_cQuery += "D2.D2_EMISSAO BETWEEN '" + DtoS( mv_par01 ) + "' AND '" + DtoS( mv_par02 ) + "' "
_cQuery += "AND D2.D2_TIPO = 'N' " 
_cQuery += "AND D2.D2_EST = 'SP' "
//_cQuery += "AND D2.D2_GRUPO >= '0300' AND D2.D2_GRUPO <= '0911' " 
//_cQuery += "AND D2.D2_GRUPO >= '0110' AND D2.D2_GRUPO <= '0911' "  
_cQuery += "AND D2.D2_GRUPO BETWEEN '0110' AND '0911' " 
//_cQuery += "AND ZD.ZD_RESPONS = '07    ' AND ZD.ZD_DEVTOT IN('P','T') "    
_cQuery += "AND "         
_cQuery += " (D2.D2_CF = '5101'   OR   D2.D2_CF = '5105'   OR   D2.D2_CF = '5116' OR "
_cQuery += " D2.D2_CF = '5401'   OR   D2.D2_CF = '5910'   OR   D2.D2_CF = '5923'  OR "
_cQuery += " D2.D2_CF = '5924'   OR   D2.D2_CF = '6101'   OR   D2.D2_CF = '6105'  OR "
_cQuery += " D2.D2_CF = '6109'   OR   D2.D2_CF = '6116'   OR   D2.D2_CF = '6401'  OR "
_cQuery += " D2.D2_CF = '6501'   OR   D2.D2_CF = '6910'   OR   D2.D2_CF = '7101') " 

/*_cQuery += "(  D2.D2_CF = '5101' OR D2.D2_CF = '5102' OR D2.D2_CF = '511' "
_cQuery += "OR D2.D2_CF = '5922' OR D2.D2_CF = '5118' OR D2.D2_CF = '512' "
_cQuery += "OR D2.D2_CF = '6101' OR D2.D2_CF = '6102' OR D2.D2_CF = '6107' "
_cQuery += "OR D2.D2_CF = '6109' OR D2.D2_CF = '611'  OR D2.D2_CF = '6922' "
_cQuery += "OR D2.D2_CF = '6118' OR D2.D2_CF = '5501' OR D2.D2_CF = '6501' "
_cQuery += "OR D2.D2_CF = '7101' OR D2.D2_CF = '7102' ) "   */
_cQuery += "AND D2.D_E_L_E_T_ = '' "
_cQuery += "AND D2.D2_FILIAL IN (" + ALLTRIM(MV_PAR04) + ") "
_cQuery += "AND C5.C5_FILIAL IN (" + ALLTRIM(MV_PAR04) + ") "
//_cQuery += "AND D2.D2_FILIAL = '" + xFilial( "SD2" ) + "' "
//_cQuery += "AND C5.C5_FILIAL = '" + xFilial( "SC5" ) + "' "
_cQuery += "AND C5.C5_NUM = D2.D2_PEDIDO "
_cQuery += "AND B1.B1_COD = D2.D2_COD "
_cQuery += "AND B1.B1_FILIAL = '" + xFilial( "SB1" ) +  "' "
_cQuery += "AND C5.C5_TPFRETE IN ('C','F') " 
// Alex Borges
_cQuery += "UNION "
_cQuery += "SELECT C5_VEND1, D2_CLIENTE, D2_LOJA, C5_NOMECLI, C5_PLACA, C5_NUM, D2_DOC, D2_COD, B1_DESC, D2_QUANT, D2_QTDEDEV, D2_VALDEV, D2_TOTAL, ZD_MOTIVO, ZD_DESCMOT, ZD_RESPONS, ZD_RESPNOM, D2_EST, C5_TPFRETE, ZD_DTDEV, D2_EMISSAO, D2_CF, D2_GRUPO "
_cQuery += "FROM "
_cQuery += RetSqlName( "SC5" ) + " C5, "
_cQuery += RetSqlName( "SB1" ) + " B1, "
_cQuery += RetSqlName( "SZD" ) + " ZD RIGHT OUTER JOIN "  
_cQuery += RetSqlName( "SD2" ) + " D2 ON "

_cQuery += "ZD.ZD_NUMNF = D2.D2_DOC AND ZD.ZD_SERIE = D2.D2_SERIE AND ZD.D_E_L_E_T_ = '' AND ZD.ZD_FILIAL = D2.D2_FILIAL AND ZD.ZD_DEVTOT <> 'E' "
_cQuery += "WHERE "
_cQuery += "ZD.ZD_DTDEV BETWEEN '" + DtoS( mv_par01 ) + "' AND '" + DtoS( mv_par02 ) + "' "
_cQuery += "AND D2.D2_TIPO = 'N' "
//_cQuery += "AND D2.D2_GRUPO >= '0300' AND D2.D2_GRUPO <= '0911' "  
_cQuery += "AND D2.D2_GRUPO >= '0110' AND D2.D2_GRUPO <= '0911' "
//_cQuery += "AND ZD.ZD_RESPONS = '07    ' AND ZD.ZD_DEVTOT IN('P','T') " 
_cQuery += "AND "
_cQuery += " (D2.D2_CF = '5101'   OR   D2.D2_CF = '5105'   OR   D2.D2_CF = '5116' OR "
_cQuery += " D2.D2_CF = '5401'   OR   D2.D2_CF = '5910'   OR   D2.D2_CF = '5923'  OR "
_cQuery += " D2.D2_CF = '5924'   OR   D2.D2_CF = '6101'   OR   D2.D2_CF = '6105'  OR "
_cQuery += " D2.D2_CF = '6109'   OR   D2.D2_CF = '6116'   OR   D2.D2_CF = '6401'  OR "
_cQuery += " D2.D2_CF = '6501'   OR   D2.D2_CF = '6910'   OR   D2.D2_CF = '7101') " 
_cQuery += "AND D2.D_E_L_E_T_ = '' "
_cQuery += "AND D2.D2_FILIAL IN (" + ALLTRIM(MV_PAR04) + ") "
_cQuery += "AND C5.C5_FILIAL IN (" + ALLTRIM(MV_PAR04) + ") "
_cQuery += "AND C5.C5_NUM = D2.D2_PEDIDO "
_cQuery += "AND B1.B1_COD = D2.D2_COD "
_cQuery += "AND B1.B1_FILIAL = '" + xFilial( "SB1" ) +  "' "
_cQuery += "AND C5.C5_TPFRETE IN ('C','F') "
_cQuery += "ORDER BY C5_VEND1, D2_CLIENTE, D2_LOJA, C5_PLACA, C5_NUM, D2_DOC, D2_COD, " + Iif( mv_par03 == 01, "ZD_DTDEV ", "D2_EMISSAO " )

_cQuery := ChangeQuery( _cQuery )

//Acrescentei a query a pesquisa no ZD com DOC e SERIE, estava somente com o DOC e ocorreu de duas NFs com mesmo numero e serie diferente - Celso - HC 30/06/09

MsAguarde( { ||dbUseArea( .T., "TOPCONN", TCGenQry( ,, _cQuery ), "QRYTMP", .F., .T. ) }, "Selecionando registros ..." )

dbSelectArea( "QRYTMP" )

SetRegua( _nTotReg )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Relacao de Devolucoes                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

While QRYTMP->( !Eof() )

	_cChave	:= QRYTMP->C5_VEND1 + QRYTMP->D2_CLIENTE + QRYTMP->D2_LOJA + QRYTMP->C5_PLACA + QRYTMP->C5_NUM + QRYTMP->D2_DOC
	_lImpr	:= .T.
	
	While QRYTMP->( !Eof() ) .And. _cChave == QRYTMP->C5_VEND1 + QRYTMP->D2_CLIENTE + QRYTMP->D2_LOJA + QRYTMP->C5_PLACA + QRYTMP->C5_NUM + QRYTMP->D2_DOC

		IncRegua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acumula NFs (memoria de calculo)                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Ascan( _aNFs, QRYTMP->D2_DOC ) <= 00
			Aadd( _aNFs, QRYTMP->D2_DOC )	
			_lSomaNF := .T.
		Else		    
			_lSomaNF := .F.
		EndIf 
		&&Mauricio 04/01/12 - tratamento para corrigir soma de quantidade de NFs devolvidas.
		If Ascan( _aNFsD, QRYTMP->D2_DOC ) <= 00 .And. QRYTMP->D2_QTDEDEV > 00
			Aadd( _aNFsD, QRYTMP->D2_DOC )	
			_lSomaNFD := .T.
		Else		    
			_lSomaNFD := .F.
		EndIf 
		
	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acumula - Total das Vendas                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		// Só acumula venda se for emissao no periodo
        IF  QRYTMP->D2_EMISSAO >= DtoS( mv_par01 ) .And.  QRYTMP->D2_EMISSAO <= DtoS( mv_par02 )
			If  ( ALLTRIM(QRYTMP->D2_COD) $ GetMv( "MV_SUBPROD"))
	           
	            _aTotais[ 16 ][ 01 ] += Iif( _lSomaNF, 01, 00 )
				_aTotais[ 16 ][ 02 ] += QRYTMP->D2_QUANT
				_aTotais[ 16 ][ 03 ] += QRYTMP->D2_TOTAL 
				
			Else
			    _aTotais[ 02 ][ 01 ] += Iif( _lSomaNF, 01, 00 )
			    _aTotais[ 02 ][ 02 ] += QRYTMP->D2_QUANT
			    _aTotais[ 02 ][ 03 ] += QRYTMP->D2_TOTAL 
	        End If 
	    End IF
	        
        // Alex Borges - Caso houver uma devolução de uma NF fora do periodo devera subtrair no total das vendas
        If  QRYTMP->D2_EMISSAO < DtoS( mv_par01 )
            _aTotais[ 22 ][ 01 ] += 0 //Iif( _lSomaNF, 01, 00 )
		    _aTotais[ 22 ][ 02 ] += 0 //QRYTMP->D2_QUANT
		    _aTotais[ 22 ][ 03 ] += 0 //QRYTMP->D2_TOTAL 
		
		End If
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acumula - Total das Vendas (SubProdutos)                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//----Retirada a somatoria de devolucoes de sub-produtos, conforme solicitado pelo usuario Elaine em 01/06/2009 - Celso Costa - HCConsys
//		If QRYTMP->D2_GRUPO > "0531"
//			_aTotais[ 16 ][ 01 ] += Iif( _lSomaNF, 01, 00 )
//			_aTotais[ 16 ][ 02 ] += QRYTMP->D2_QUANT
//			_aTotais[ 16 ][ 03 ] += QRYTMP->D2_TOTAL
//		EndIf
//--------------------------------------------------------------------------------------------------------------------------------------
             
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime registros                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If _nLin > 55
			_nLin 	:= Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, _nTipo )
			_lImpr	:= .T.
		EndIf             

		If QRYTMP->D2_QTDEDEV > 00 .And.( QRYTMP->ZD_DTDEV >= DtoS( mv_par01 ) .And.  QRYTMP->ZD_DTDEV <= DtoS( mv_par02 ))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula - Ocorrencias                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  !( ALLTRIM(QRYTMP->D2_COD) $ GetMv( "MV_SUBPROD"))
				_nAscan := aScan( _aOcorrencias, { |x| x[ 01 ] == QRYTMP->ZD_RESPONS + QRYTMP->ZD_MOTIVO } )
            End IF

			If _nAscan <= 00
               If  !( ALLTRIM(QRYTMP->D2_COD) $ GetMv( "MV_SUBPROD"))
				  Aadd( _aOcorrencias,	{	QRYTMP->ZD_RESPONS + QRYTMP->ZD_MOTIVO	,;		// Chave do Ascan
												QRYTMP->ZD_RESPNOM							,;		// Nome do responsavel
												QRYTMP->ZD_DESCMOT							,;		// Descricao do Motivo
												Iif( _lSomaNFD, 01, 00 )						,;		// Numero de NFS devolvidas
												QRYTMP->D2_QTDEDEV							,;		// Devolucoes em KG
												QRYTMP->D2_VALDEV								} )	// Devolucoes em R$
               End If
			Else
				If  !( ALLTRIM(QRYTMP->D2_COD) $ GetMv( "MV_SUBPROD"))
					_aOcorrencias[ _nAscan ][ 04 ]	+= Iif( _lSomaNFD, 01, 00 )
					_aOcorrencias[ _nAscan ][ 05 ]	+= QRYTMP->D2_QTDEDEV
					_aOcorrencias[ _nAscan ][ 06 ]	+= QRYTMP->D2_VALDEV
                End If
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula Totais - Acerto Contabil                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim( QRYTMP->ZD_RESPONS ) == "01" .AND. !( ALLTRIM(QRYTMP->D2_COD) $ GetMv( "MV_SUBPROD"))
				_aTotais[ 05 ][ 01 ] += Iif( _lSomaNFD, 01, 00 )
				_aTotais[ 05 ][ 02 ] += QRYTMP->D2_QTDEDEV
				_aTotais[ 05 ][ 03 ] += QRYTMP->D2_VALDEV
         	EndIf
            
         	// 08/11/10 Ana Helena - retirado "Venda Acima do Estoque" conforme solic chamado 008298
         				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula Totais - Venda Acima do Estoque                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			/*
			If AllTrim( QRYTMP->ZD_RESPONS ) == "18"
				_aTotais[ 06 ][ 01 ] += Iif( _lSomaNFD, 01, 00 )
				_aTotais[ 06 ][ 02 ] += QRYTMP->D2_QTDEDEV
				_aTotais[ 06 ][ 03 ] += QRYTMP->D2_VALDEV
         	EndIf
         	*/

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula Totais - Sinistro                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim( QRYTMP->ZD_RESPONS ) == "02" //"10"//11
				_aTotais[ 13 ][ 01 ] += Iif( _lSomaNFD, 01, 00 )
				_aTotais[ 13 ][ 02 ] += QRYTMP->D2_QTDEDEV
				_aTotais[ 13 ][ 03 ] += QRYTMP->D2_VALDEV
         	EndIf
         
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula Totais - Sistema                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			/*
			If AllTrim( QRYTMP->ZD_RESPONS ) == "04"//16
				_aTotais[ 14 ][ 01 ] += Iif( _lSomaNFD, 01, 00 )
				_aTotais[ 14 ][ 02 ] += QRYTMP->D2_QTDEDEV
				_aTotais[ 14 ][ 03 ] += QRYTMP->D2_VALDEV
         	EndIf
         	*/

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula Totais - Faturamento                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim( QRYTMP->ZD_RESPONS ) == "03" //"12"//13
				_aTotais[ 15 ][ 01 ] += Iif( _lSomaNFD, 01, 00 )
				_aTotais[ 15 ][ 02 ] += QRYTMP->D2_QTDEDEV
				_aTotais[ 15 ][ 03 ] += QRYTMP->D2_VALDEV
         	EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime registros de devolucoes                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   
			If  !( ALLTRIM(QRYTMP->D2_COD) $ GetMv( "MV_SUBPROD"))
				If _lImpr
					_nLin++
					@ _nLin, 000 PSay QRYTMP->C5_VEND1
					@ _nLin, 010 PSay QRYTMP->D2_CLIENTE + "/" + QRYTMP->D2_LOJA
					@ _nLin, 021 PSay QRYTMP->C5_NOMECLI
					@ _nLin, 043 PSay QRYTMP->C5_PLACA
					@ _nLin, 052 PSay QRYTMP->C5_NUM
					@ _nLin, 060 PSay QRYTMP->D2_DOC
				EndIf
					
				@ _nLin, 068 PSay AllTrim( QRYTMP->D2_COD ) + "  " + AllTrim( QRYTMP->B1_DESC )
				@ _nLin, 117 PSay QRYTMP->D2_QUANT		Picture "@E 99,999,999.99"
				@ _nLin, 132 PSay QRYTMP->D2_QTDEDEV	Picture "@E 99,999,999.99"
	
				_nTotSaida	+= QRYTMP->D2_QUANT
				_nTotDevol	+= QRYTMP->D2_QTDEDEV
	
				If _lImpr
					@ _nLin, 147 PSay AllTrim( QRYTMP->ZD_MOTIVO ) + "  " + AllTrim( QRYTMP->ZD_DESCMOT )
					@ _nLin, 177 PSay AllTrim( QRYTMP->ZD_RESPONS ) + "  " + AllTrim( QRYTMP->ZD_RESPNOM )
	      		_lImpr := .F.
	      	    EndIf
      	    End If
			_nLin++

            If  !( ALLTRIM(QRYTMP->D2_COD) $ GetMv( "MV_SUBPROD"))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Acumula - Total das devolucoes                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				_aTotais[ 01 ][ 01 ] += Iif( _lSomaNFD, 01, 00 )
				_aTotais[ 01 ][ 02 ] += QRYTMP->D2_QTDEDEV
				_aTotais[ 01 ][ 03 ] += QRYTMP->D2_VALDEV
			End If
	
			Do Case
				
				Case AllTrim( QRYTMP->D2_EST ) == "SP" .And. AllTrim( QRYTMP->C5_TPFRETE ) == "C" .And.  !( ALLTRIM(QRYTMP->D2_COD) $ GetMv( "MV_SUBPROD"))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumula - Total das Devolucoes (Estadual - CIF)              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					_aTotais[ 07 ][ 01 ] += Iif( _lSomaNFD, 01, 00 )
					_aTotais[ 07 ][ 02 ] += QRYTMP->D2_QTDEDEV
					_aTotais[ 07 ][ 03 ] += QRYTMP->D2_VALDEV
		
				Case AllTrim( QRYTMP->D2_EST ) == "SP" .And. AllTrim( QRYTMP->C5_TPFRETE ) == "F" .And.  !( ALLTRIM(QRYTMP->D2_COD) $ GetMv( "MV_SUBPROD"))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumula - Total das Devolucoes (Estadual - FOB)              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					_aTotais[ 08 ][ 01 ] += Iif( _lSomaNFD, 01, 00 )
					_aTotais[ 08 ][ 02 ] += QRYTMP->D2_QTDEDEV
					_aTotais[ 08 ][ 03 ] += QRYTMP->D2_VALDEV

				Case AllTrim( QRYTMP->D2_EST ) != "SP" .And. AllTrim( QRYTMP->C5_TPFRETE ) == "C" .And. !( QRYTMP->D2_CF $ "7101|7102" ) .And.  !( ALLTRIM(QRYTMP->D2_COD) $ GetMv( "MV_SUBPROD"))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumula - Total das Devolucoes (InterEstadual - CIF)         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					_aTotais[ 09 ][ 01 ] += Iif( _lSomaNFD, 01, 00 )
					_aTotais[ 09 ][ 02 ] += QRYTMP->D2_QTDEDEV
					_aTotais[ 09 ][ 03 ] += QRYTMP->D2_VALDEV

				Case AllTrim( QRYTMP->D2_EST ) != "SP" .And. AllTrim( QRYTMP->C5_TPFRETE ) == "F" .And. !( QRYTMP->D2_CF $ "7101|7102" ) .And.  !( ALLTRIM(QRYTMP->D2_COD) $ GetMv( "MV_SUBPROD"))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumula - Total das Devolucoes (InterEstadual - FOB)         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					_aTotais[ 10 ][ 01 ] += Iif( _lSomaNFD, 01, 00 )
					_aTotais[ 10 ][ 02 ] += QRYTMP->D2_QTDEDEV
					_aTotais[ 10 ][ 03 ] += QRYTMP->D2_VALDEV

				Case AllTrim( QRYTMP->D2_EST ) != "SP" .And. AllTrim( QRYTMP->C5_TPFRETE ) == "C" .And. QRYTMP->D2_CF $ "7101|7102"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumula - Total das Devolucoes (Exportacao - CIF)            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					_aTotais[ 11 ][ 01 ] += Iif( _lSomaNFD, 01, 00 )
					_aTotais[ 11 ][ 02 ] += QRYTMP->D2_QTDEDEV
					_aTotais[ 11 ][ 03 ] += QRYTMP->D2_VALDEV

				Case AllTrim( QRYTMP->D2_EST ) != "SP" .And. AllTrim( QRYTMP->C5_TPFRETE ) == "F" .And. QRYTMP->D2_CF $ "7101|7102"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumula - Total das Devolucoes (Exportacao - FOB)            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					_aTotais[ 12 ][ 01 ] += Iif( _lSomaNFD, 01, 00 )
					_aTotais[ 12 ][ 02 ] += QRYTMP->D2_QTDEDEV
					_aTotais[ 12 ][ 03 ] += QRYTMP->D2_VALDEV   
					
				
				Case AllTrim( QRYTMP->D2_EST ) == "SP" .And. AllTrim( QRYTMP->C5_TPFRETE ) == "C" .And.   ALLTRIM(QRYTMP->D2_COD) $ GetMv( "MV_SUBPROD")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumula - Total das Devolucoes SubProduto(Estadual - CIF)              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					_aTotais[ 17 ][ 01 ] += Iif( _lSomaNFD, 01, 00 )
					_aTotais[ 17 ][ 02 ] += QRYTMP->D2_QTDEDEV
					_aTotais[ 17 ][ 03 ] += QRYTMP->D2_VALDEV
		
				Case AllTrim( QRYTMP->D2_EST ) == "SP" .And. AllTrim( QRYTMP->C5_TPFRETE ) == "F" .And.   ALLTRIM(QRYTMP->D2_COD) $ GetMv( "MV_SUBPROD")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumula - Total das Devolucoes SubProduto(Estadual - FOB)              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					_aTotais[ 18 ][ 01 ] += Iif( _lSomaNFD, 01, 00 )
					_aTotais[ 18 ][ 02 ] += QRYTMP->D2_QTDEDEV
					_aTotais[ 18 ][ 03 ] += QRYTMP->D2_VALDEV

				Case AllTrim( QRYTMP->D2_EST ) != "SP" .And. AllTrim( QRYTMP->C5_TPFRETE ) == "C" .And. !( QRYTMP->D2_CF $ "7101|7102" ) .And.   ALLTRIM(QRYTMP->D2_COD) $ GetMv( "MV_SUBPROD")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumula - Total das Devolucoes SubProduto(InterEstadual - CIF)         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					_aTotais[ 19 ][ 01 ] += Iif( _lSomaNFD, 01, 00 )
					_aTotais[ 19 ][ 02 ] += QRYTMP->D2_QTDEDEV
					_aTotais[ 19 ][ 03 ] += QRYTMP->D2_VALDEV

				Case AllTrim( QRYTMP->D2_EST ) != "SP" .And. AllTrim( QRYTMP->C5_TPFRETE ) == "F" .And. !( QRYTMP->D2_CF $ "7101|7102" ) .And.   ALLTRIM(QRYTMP->D2_COD) $ GetMv( "MV_SUBPROD")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumula - Total das Devolucoes SubProduto(InterEstadual - FOB)         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					_aTotais[ 20 ][ 01 ] += Iif( _lSomaNFD, 01, 00 )
					_aTotais[ 20 ][ 02 ] += QRYTMP->D2_QTDEDEV
					_aTotais[ 20 ][ 03 ] += QRYTMP->D2_VALDEV
					

			EndCase	 
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula - Total das devolucoes de sub Produtos
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	       If ALLTRIM(QRYTMP->D2_COD) $ GetMv( "MV_SUBPROD")
				_aTotais[ 21 ][ 01 ] += Iif( _lSomaNFD, 01, 00 )
				_aTotais[ 21 ][ 02 ] += QRYTMP->D2_QTDEDEV
				_aTotais[ 21 ][ 03 ] += QRYTMP->D2_VALDEV
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula - Longo percurso (Fora SP - exceto RJ)               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim( QRYTMP->D2_EST ) != "SP" .And. AllTrim( QRYTMP->D2_EST ) != "RJ"
				_aTotais[ 03 ][ 01 ] += Iif( _lSomaNFD, 01, 00 )
				_aTotais[ 03 ][ 02 ] += QRYTMP->D2_QTDEDEV
				_aTotais[ 03 ][ 03 ] += QRYTMP->D2_VALDEV
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula - Devolucoes parciais                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If QRYTMP->D2_QTDEDEV < QRYTMP->D2_QUANT
				_aTotais[ 04 ][ 01 ] += Iif( _lSomaNFD, 01, 00 )
				_aTotais[ 04 ][ 02 ] += QRYTMP->D2_QTDEDEV
				_aTotais[ 04 ][ 03 ] += QRYTMP->D2_VALDEV
      	    EndIf
            


		EndIf
	
		QRYTMP->( dbSkip() )

	EndDo
		
EndDo

QRYTMP->( dbCloseArea() )

If _nLin > 50
	_nLin := Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, _nTipo )
EndIf             

_nLin++
@ _nLin, 000 PSay "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

_nLin++
@ _nLin, 000 PSay "Totais"
@ _nLin, 117 PSay _nTotSaida	Picture "@E 99,999,999.99"
@ _nLin, 132 PSay _nTotDevol	Picture "@E 99,999,999.99"

_nLin++
@ _nLin, 000 PSay "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

If _nLin != 80
	Roda( cbCont, cbTxt, "M" )
EndIf

If Len( _aTotais ) <= 00

	If aReturn[ 05 ] = 01
		Set Printer To
		Commit
		OurSpool( WnRel )
	EndIf

	MS_Flush()
   
	Return ( Nil )
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Ocorrencia de Devolucoes                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Titulo	:= "Ocorrencia de Devolucoes no periodo de " + DtoC( mv_par01 ) + " ate " + DtoC( mv_par02 ) + " - ordem " + Iif( mv_par03 == 01, "Data Digitacao", "Data Emissao NF" )
Cabec1	:= "Responsaveis        Motivos                       Devolucoes                  Devolucoes                  Devolucoes               Vendas"
Cabec2	:= "                                               No.            %            KG             %            R$             %"
_nLin := Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, _nTipo )

For _nCtOcorr := 01 To Len( _aOcorrencias )

	If Empty( _aOcorrencias[ _nCtOcorr ][ 02 ] )
		_aOcorrencias[ _nCtOcorr ][ 02 ] := "NAO IDENTIFICADO"
	EndIf

Next _nCtOcorr

&&Mauricio - MDS TEC - 07/08/13 - corrigido ordem do aSort(estava coluna 1 trocado para 2)
aSort( _aOcorrencias,,, { | x,y | x[ 02 ] < y[ 02 ] } )

If Len( _aOcorrencias ) > 00                 
	_nLin++
	@ _nLin, 000 PSay _aOcorrencias[ 01 ][ 02 ]
	_cNomeResp := _aOcorrencias[ 01 ][ 02 ]
EndIf

For _nCtOcorr := 01 To Len( _aOcorrencias )

	If _nLin > 50
		_nLin := Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, _nTipo )
		//_nLin++
	EndIf             

	If AllTrim( _aOcorrencias[ _nCtOcorr ][ 02 ] ) != AllTrim( _cNomeResp )

		_nLin++
		@ _nLin, 000 PSay "Total do Responsavel:"

		@ _nLin, 042 PSay _nTRNoDev	Picture "@E 99,999,999.99"
		@ _nLin, 057 PSay _nTRNoPDev	Picture "@E 99,999.9999"
		@ _nLin, 070 PSay _nTRKGDev	Picture "@E 99,999,999.99"
		@ _nLin, 085 PSay _nTRKGPDev	Picture "@E 99,999.9999"
		@ _nLin, 098 PSay _nTRReDev	Picture "@E 99,999,999.99"
		@ _nLin, 113 PSay _nTRRePDev	Picture "@E 99,999.9999"
		@ _nLin, 126 PSay _nTRVdDev	Picture "@E 99,999.9999"

		_nLin++
		@ _nLin, 000 PSay "-----------------------------------------------------------------------------------------------------------------------------------------"

		_nLin++
		@ _nLin, 000 PSay _aOcorrencias[ _nCtOcorr ][ 02 ]

		_cNomeResp	:= _aOcorrencias[ _nCtOcorr ][ 02 ]
		_nTRNoDev	:= 00
		_nTRNoPDev	:= 00
		_nTRKGDev	:= 00
		_nTRKGPDev	:= 00
		_nTRReDev	:= 00
		_nTRRePDev	:= 00
		_nTRVdDev	:= 00

	EndIf
		
	@ _nLin, 020 PSay _aOcorrencias[ _nCtOcorr ][ 03 ]
	@ _nLin, 042 PSay _aOcorrencias[ _nCtOcorr ][ 04 ]											Picture "@E 99,999,999.99"
	@ _nLin, 057 PSay ( _aOcorrencias[ _nCtOcorr ][ 04 ] / _aTotais[ 01 ][ 01 ] )	Picture "@E 99,999.9999"
	@ _nLin, 070 PSay _aOcorrencias[ _nCtOcorr ][ 05 ]											Picture "@E 99,999,999.99"
	@ _nLin, 085 PSay ( _aOcorrencias[ _nCtOcorr ][ 05 ] / _aTotais[ 01 ][ 01 ] )	Picture "@E 99,999.9999"
	@ _nLin, 098 PSay _aOcorrencias[ _nCtOcorr ][ 06 ]											Picture "@E 99,999,999.99"
	@ _nLin, 113 PSay ( _aOcorrencias[ _nCtOcorr ][ 06 ] / _aTotais[ 01 ][ 01 ] )	Picture "@E 99,999.9999"
	@ _nLin, 126 PSay ( _aOcorrencias[ _nCtOcorr ][ 04 ] / _aTotais[ 02 ][ 01 ] )	Picture "@E 99,999.9999"

	_nTRNoDev	+= _aOcorrencias[ _nCtOcorr ][ 04 ]
	_nTRNoPDev	+= ( _aOcorrencias[ _nCtOcorr ][ 04 ] / _aTotais[ 01 ][ 01 ] )
	_nTRKGDev	+= _aOcorrencias[ _nCtOcorr ][ 05 ]
	_nTRKGPDev	+= ( _aOcorrencias[ _nCtOcorr ][ 05 ] / _aTotais[ 01 ][ 01 ] )
	_nTRReDev	+= _aOcorrencias[ _nCtOcorr ][ 06 ]
	_nTRRePDev	+= ( _aOcorrencias[ _nCtOcorr ][ 06 ] / _aTotais[ 01 ][ 01 ] )
	_nTRVdDev	+= ( _aOcorrencias[ _nCtOcorr ][ 04 ] / _aTotais[ 02 ][ 01 ] )

	_nLin++
	
Next _nCtOcorr

If Len( _aOcorrencias ) > 00

	If _nLin > 50
		_nLin := Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, _nTipo )
	EndIf             

	_nLin++
	@ _nLin, 000 PSay "Total do Responsavel:"

	@ _nLin, 042 PSay _nTRNoDev	Picture "@E 99,999,999.99"
	@ _nLin, 057 PSay _nTRNoPDev	Picture "@E 99,999.9999"
	@ _nLin, 070 PSay _nTRKGDev	Picture "@E 99,999,999.99"
	@ _nLin, 085 PSay _nTRKGPDev	Picture "@E 99,999.9999"
	@ _nLin, 098 PSay _nTRReDev	Picture "@E 99,999,999.99"
	@ _nLin, 113 PSay _nTRRePDev	Picture "@E 99,999.9999"
	@ _nLin, 126 PSay _nTRVdDev	Picture "@E 99,999.9999"

	_nLin++
	@ _nLin, 000 PSay "-----------------------------------------------------------------------------------------------------------------------------------------"

EndIf

_nLin++
@ _nLin, 000 PSay "Total Devolucao:"
@ _nLin, 042 PSay _aTotais[ 01 ][ 01 ]	Picture "@E 99,999,999.99"
@ _nLin, 070 PSay _aTotais[ 01 ][ 02 ]	Picture "@E 99,999,999.99"
@ _nLin, 098 PSay _aTotais[ 01 ][ 03 ]	Picture "@E 99,999,999.99"
 
_nLin++
@ _nLin, 000 PSay "Total Vendas:"
@ _nLin, 042 PSay _aTotais[ 02 ][ 01 ] - _aTotais[ 22 ][ 01 ] Picture "@E 99,999,999.99"//_aTotais[ 02 ][ 01 ]	Picture "@E 99,999,999.99"
@ _nLin, 070 PSay _aTotais[ 02 ][ 02 ] - _aTotais[ 22 ][ 02 ] Picture "@E 99,999,999.99"//_aTotais[ 02 ][ 02 ]	Picture "@E 99,999,999.99"
@ _nLin, 098 PSay _aTotais[ 02 ][ 03 ] - _aTotais[ 22 ][ 03 ] Picture "@E 99,999,999.99"//_aTotais[ 02 ][ 03 ]	Picture "@E 99,999,999.99"

_nLin++
@ _nLin, 000 PSay "Devolucoes / Vendas:"
//@ _nLin, 044 PSay ( ( _aTotais[ 01 ][ 01 ] / (_aTotais[ 02 ][ 01 ] - _aTotais[ 22 ][ 01 ]) ) * 100 )	Picture "@E 99,999.9999"
@ _nLin, 044 PSay ( ( _aTotais[ 01 ][ 01 ] / (_aTotais[ 02 ][ 01 ] ) ) * 100 )	Picture "@E 99,999.9999"
//@ _nLin, 072 PSay ( ( _aTotais[ 01 ][ 02 ] / (_aTotais[ 02 ][ 02 ] - _aTotais[ 22 ][ 02 ]) ) * 100 )	Picture "@E 99,999.9999"
@ _nLin, 072 PSay ( ( _aTotais[ 01 ][ 02 ] / (_aTotais[ 02 ][ 02 ] ) ) * 100 )	Picture "@E 99,999.9999"
//@ _nLin, 100 PSay ( ( _aTotais[ 01 ][ 03 ] / (_aTotais[ 02 ][ 03 ] - _aTotais[ 22 ][ 03 ]) ) * 100 )	Picture "@E 99,999.9999"
@ _nLin, 100 PSay ( ( _aTotais[ 01 ][ 03 ] / (_aTotais[ 02 ][ 03 ] ) ) * 100 )	Picture "@E 99,999.9999"

_nLin++
@ _nLin, 000 PSay "-----------------------------------------------------------------------------------------------------------------------------------------"

If _nLin != 80
	Roda( cbCont, cbTxt, "M" )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Resumo de Devolucoes                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Titulo	:= "Resumo das Devolucoes no periodo de " + DtoC( mv_par01 ) + " ate " + DtoC( mv_par02 ) + " - ordem " + Iif( mv_par03 == 01, "Data Digitacao", "Data Emissao NF" )
Cabec1	:= "Resumo                                       Quantidade NFS       Quantidade KG         Valor em R$"
Cabec2	:= ""
_nLin 	:= Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, _nTipo )

//_nLin++
//@ _nLin, 000 PSay "Total das Devolucoes"
//@ _nLin, 045 PSay _aTotais[ 01 ][ 01 ]	Picture "@E 999,999,999.99"
//@ _nLin, 065 PSay _aTotais[ 01 ][ 02 ]	Picture "@E 999,999,999.99"
//@ _nLin, 085 PSay _aTotais[ 01 ][ 03 ]	Picture "@E 999,999,999.99"

_nLin++
@ _nLin, 000 PSay "Total das Devolucoes (Estadual - CIF)"
@ _nLin, 045 PSay _aTotais[ 07 ][ 01 ]	Picture "@E 999,999,999.99"
@ _nLin, 065 PSay _aTotais[ 07 ][ 02 ]	Picture "@E 999,999,999.99"
@ _nLin, 085 PSay _aTotais[ 07 ][ 03 ]	Picture "@E 999,999,999.99"

_nLin++
@ _nLin, 000 PSay "Total das Devolucoes (Estadual - FOB)"
@ _nLin, 045 PSay _aTotais[ 08 ][ 01 ]	Picture "@E 999,999,999.99"
@ _nLin, 065 PSay _aTotais[ 08 ][ 02 ]	Picture "@E 999,999,999.99"
@ _nLin, 085 PSay _aTotais[ 08 ][ 03 ]	Picture "@E 999,999,999.99"
				
_nLin++
@ _nLin, 000 PSay "Total das Devolucoes (InterEstadual - CIF)"
@ _nLin, 045 PSay _aTotais[ 09 ][ 01 ]	Picture "@E 999,999,999.99"
@ _nLin, 065 PSay _aTotais[ 09 ][ 02 ]	Picture "@E 999,999,999.99"
@ _nLin, 085 PSay _aTotais[ 09 ][ 03 ]	Picture "@E 999,999,999.99"
		
_nLin++
@ _nLin, 000 PSay "Total das Devolucoes (InterEstadual - FOB)"
@ _nLin, 045 PSay _aTotais[ 10 ][ 01 ]	Picture "@E 999,999,999.99"
@ _nLin, 065 PSay _aTotais[ 10 ][ 02 ]	Picture "@E 999,999,999.99"
@ _nLin, 085 PSay _aTotais[ 10 ][ 03 ]	Picture "@E 999,999,999.99"

_nLin++
@ _nLin, 000 PSay "Total das Devolucoes (Exportacao - CIF)"
@ _nLin, 045 PSay _aTotais[ 11 ][ 01 ]	Picture "@E 999,999,999.99"
@ _nLin, 065 PSay _aTotais[ 11 ][ 02 ]	Picture "@E 999,999,999.99"
@ _nLin, 085 PSay _aTotais[ 11 ][ 03 ]	Picture "@E 999,999,999.99"

_nLin++
@ _nLin, 000 PSay "Total das Devolucoes (Exportacao - FOB)"
@ _nLin, 045 PSay _aTotais[ 12 ][ 01 ]	Picture "@E 999,999,999.99"
@ _nLin, 065 PSay _aTotais[ 12 ][ 02 ]	Picture "@E 999,999,999.99"
@ _nLin, 085 PSay _aTotais[ 12 ][ 03 ]	Picture "@E 999,999,999.99"  

_nLin++
@ _nLin, 000 PSay "Total das Devolucoes "
@ _nLin, 045 PSay _aTotais[ 01 ][ 01 ]	Picture "@E 999,999,999.99"
@ _nLin, 065 PSay _aTotais[ 01 ][ 02 ]	Picture "@E 999,999,999.99"
@ _nLin, 085 PSay _aTotais[ 01 ][ 03 ]	Picture "@E 999,999,999.99"   

_nLin++
@ _nLin, 000 PSay "Devolucoes Parciais"
@ _nLin, 045 PSay _aTotais[ 04 ][ 01 ]	Picture "@E 999,999,999.99"
@ _nLin, 065 PSay _aTotais[ 04 ][ 02 ]	Picture "@E 999,999,999.99"
@ _nLin, 085 PSay _aTotais[ 04 ][ 03 ]	Picture "@E 999,999,999.99"

_nLin++
@ _nLin, 000 PSay "Total das Vendas"
@ _nLin, 045 PSay _aTotais[ 02 ][ 01 ] - _aTotais[ 22 ][ 01 ]	Picture "@E 999,999,999.99"
@ _nLin, 065 PSay _aTotais[ 02 ][ 02 ] - _aTotais[ 22 ][ 02 ]	Picture "@E 999,999,999.99"
@ _nLin, 085 PSay _aTotais[ 02 ][ 03 ] - _aTotais[ 22 ][ 03 ]	Picture "@E 999,999,999.99"

_nLin++
@ _nLin, 000 PSay "Devolucoes / Vendas (%)"
//@ _nLin, 048 PSay ( ( _aTotais[ 01 ][ 01 ] / ( _aTotais[ 02 ][ 01 ] - _aTotais[ 22 ][ 01 ] )) * 100 )	Picture "@E 99,999.9999"
@ _nLin, 048 PSay ( ( _aTotais[ 01 ][ 01 ] / ( _aTotais[ 02 ][ 01 ]  )) * 100 )	Picture "@E 99,999.9999"
//@ _nLin, 068 PSay ( ( _aTotais[ 01 ][ 02 ] / ( _aTotais[ 02 ][ 02 ] - _aTotais[ 22 ][ 02 ] )) * 100 )	Picture "@E 99,999.9999"
@ _nLin, 068 PSay ( ( _aTotais[ 01 ][ 02 ] / ( _aTotais[ 02 ][ 02 ]  )) * 100 )	Picture "@E 99,999.9999"
//@ _nLin, 088 PSay ( ( _aTotais[ 01 ][ 03 ] / ( _aTotais[ 02 ][ 03 ] - _aTotais[ 22 ][ 03 ] )) * 100 )	Picture "@E 99,999.9999"
@ _nLin, 088 PSay ( ( _aTotais[ 01 ][ 03 ] / ( _aTotais[ 02 ][ 03 ]  )) * 100 )	Picture "@E 99,999.9999"

_nLin++
@ _nLin, 000 PSay "---------------------------------------------------------------------------------------------------"

_nLin++
@ _nLin, 000 PSay "                ( - )"

_nLin++
@ _nLin, 000 PSay "---------------------------------------------------------------------------------------------------"

_nLin++
@ _nLin, 000 PSay "Acerto Contabil"
@ _nLin, 045 PSay _aTotais[ 05 ][ 01 ]	Picture "@E 999,999,999.99"
@ _nLin, 065 PSay _aTotais[ 05 ][ 02 ]	Picture "@E 999,999,999.99"
@ _nLin, 085 PSay _aTotais[ 05 ][ 03 ]	Picture "@E 999,999,999.99"
               
// 08/11/10 Ana Helena - retirado "Venda Acima do Estoque" conforme solic chamado 008298
/*
_nLin++
@ _nLin, 000 PSay "Venda Acima do Estoque"
@ _nLin, 045 PSay _aTotais[ 06 ][ 01 ]	Picture "@E 999,999,999.99"
@ _nLin, 065 PSay _aTotais[ 06 ][ 02 ]	Picture "@E 999,999,999.99"
@ _nLin, 085 PSay _aTotais[ 06 ][ 03 ]	Picture "@E 999,999,999.99"
*/

_nLin++
@ _nLin, 000 PSay "Sinistro"
@ _nLin, 045 PSay _aTotais[ 13 ][ 01 ]	Picture "@E 999,999,999.99"
@ _nLin, 065 PSay _aTotais[ 13 ][ 02 ]	Picture "@E 999,999,999.99"
@ _nLin, 085 PSay _aTotais[ 13 ][ 03 ]	Picture "@E 999,999,999.99"

_nLin++
@ _nLin, 000 PSay "Sistema"
@ _nLin, 045 PSay _aTotais[ 14 ][ 01 ]	Picture "@E 999,999,999.99"
@ _nLin, 065 PSay _aTotais[ 14 ][ 02 ]	Picture "@E 999,999,999.99"
@ _nLin, 085 PSay _aTotais[ 14 ][ 03 ]	Picture "@E 999,999,999.99"

_nLin++
@ _nLin, 000 PSay "Faturamento"
@ _nLin, 045 PSay _aTotais[ 15 ][ 01 ]	Picture "@E 999,999,999.99"
@ _nLin, 065 PSay _aTotais[ 15 ][ 02 ]	Picture "@E 999,999,999.99"
@ _nLin, 085 PSay _aTotais[ 15 ][ 03 ]	Picture "@E 999,999,999.99"

_nNParciais := ( _aTotais[ 01 ][ 01 ] - ( _aTotais[ 05 ][ 01 ] + _aTotais[ 06 ][ 01 ] + _aTotais[ 13 ][ 01 ] + _aTotais[ 14 ][ 01 ] + _aTotais[ 15 ][ 01 ] ) )
_nKParciais	:= ( _aTotais[ 01 ][ 02 ] - ( _aTotais[ 05 ][ 02 ] + _aTotais[ 06 ][ 02 ] + _aTotais[ 13 ][ 02 ] + _aTotais[ 14 ][ 02 ] + _aTotais[ 15 ][ 02 ] ) )
_nRParciais	:= ( _aTotais[ 01 ][ 03 ] - ( _aTotais[ 05 ][ 03 ] + _aTotais[ 06 ][ 03 ] + _aTotais[ 13 ][ 03 ] + _aTotais[ 14 ][ 03 ] + _aTotais[ 15 ][ 03 ] ) )

//_nLin++
//@ _nLin, 000 PSay "---------------------------------------------------------------------------------------------------"

//_nLin++
//@ _nLin, 000 PSay "                ( - )"

//_nLin++
//@ _nLin, 000 PSay "---------------------------------------------------------------------------------------------------"

//_nLin++
//@ _nLin, 000 PSay "Longo Percurso"
//@ _nLin, 045 PSay _aTotais[ 03 ][ 01 ]	Picture "@E 999,999,999.99"
//@ _nLin, 065 PSay _aTotais[ 03 ][ 02 ]	Picture "@E 999,999,999.99"
//@ _nLin, 085 PSay _aTotais[ 03 ][ 03 ]	Picture "@E 999,999,999.99"

//_nLin++
//@ _nLin, 000 PSay "Parciais"
//@ _nLin, 045 PSay _aTotais[ 04 ][ 01 ]	Picture "@E 999,999,999.99"
//@ _nLin, 065 PSay _aTotais[ 04 ][ 02 ]	Picture "@E 999,999,999.99"
//@ _nLin, 085 PSay _aTotais[ 04 ][ 03 ]	Picture "@E 999,999,999.99"

//_nNParciais	:= _nNParciais - _aTotais[ 03 ][ 01 ] - _aTotais[ 04 ][ 01 ]
//_nKParciais	:= _nKParciais - _aTotais[ 03 ][ 02 ] - _aTotais[ 04 ][ 02 ]
//_nRParciais	:= _nRParciais - _aTotais[ 03 ][ 03 ] - _aTotais[ 04 ][ 03 ]

//_nLin++
//@ _nLin, 000 PSay "PARCIAL"
//@ _nLin, 045 PSay _nNParciais	Picture "@E 999,999,999.99"
//@ _nLin, 065 PSay _nKParciais	Picture "@E 999,999,999.99"
//@ _nLin, 085 PSay _nRParciais	Picture "@E 999,999,999.99"

_nLin++
@ _nLin, 000 PSay "---------------------------------------------------------------------------------------------------"

_nLin++
@ _nLin, 000 PSay "                ( = )"
@ _nLin, 045 PSay _nNParciais	Picture "@E 999,999,999.99"
@ _nLin, 065 PSay _nKParciais	Picture "@E 999,999,999.99"
@ _nLin, 085 PSay _nRParciais	Picture "@E 999,999,999.99"

_nLin++
@ _nLin, 000 PSay "---------------------------------------------------------------------------------------------------"

_nLin++
@ _nLin, 000 PSay "TOTAL (%)"


@ _nLin, 048 PSay ( ( _nNParciais / (_aTotais[ 02 ][ 01 ] - _aTotais[ 22 ][ 01]) ) * 100 )	Picture "@E 99,999.9999"
@ _nLin, 068 PSay ( ( _nKParciais / (_aTotais[ 02 ][ 02 ] - _aTotais[ 22 ][ 02]) ) * 100 )	Picture "@E 99,999.9999"
@ _nLin, 088 PSay ( ( _nRParciais / (_aTotais[ 02 ][ 03 ] - _aTotais[ 22 ][ 03]) ) * 100 )	Picture "@E 99,999.9999"



_nLin++
@ _nLin, 000 PSay "---------------------------------------------------------------------------------------------------"

_nLin++
@ _nLin, 000 PSay "Total Devol. (SubProd) Estadual - CIF"
@ _nLin, 045 PSay _aTotais[ 17 ][ 01 ]	Picture "@E 999,999,999.99"
@ _nLin, 065 PSay _aTotais[ 17 ][ 02 ]	Picture "@E 999,999,999.99"
@ _nLin, 085 PSay _aTotais[ 17 ][ 03 ]	Picture "@E 999,999,999.99"  

_nLin++
@ _nLin, 000 PSay "Total Devol. (SubProd) Estadual - FOB"
@ _nLin, 045 PSay _aTotais[ 18 ][ 01 ]	Picture "@E 999,999,999.99"
@ _nLin, 065 PSay _aTotais[ 18 ][ 02 ]	Picture "@E 999,999,999.99"
@ _nLin, 085 PSay _aTotais[ 18 ][ 03 ]	Picture "@E 999,999,999.99"  

_nLin++
@ _nLin, 000 PSay "Total Devol. (SubProd) InterEstadual - CIF"
@ _nLin, 045 PSay _aTotais[ 19 ][ 01 ]	Picture "@E 999,999,999.99"
@ _nLin, 065 PSay _aTotais[ 19 ][ 02 ]	Picture "@E 999,999,999.99"
@ _nLin, 085 PSay _aTotais[ 19 ][ 03 ]	Picture "@E 999,999,999.99"  

_nLin++
@ _nLin, 000 PSay "Total Devol. (SubProd) InterEstadual - FOB"
@ _nLin, 045 PSay _aTotais[ 20 ][ 01 ]	Picture "@E 999,999,999.99"
@ _nLin, 065 PSay _aTotais[ 20 ][ 02 ]	Picture "@E 999,999,999.99"
@ _nLin, 085 PSay _aTotais[ 20 ][ 03 ]	Picture "@E 999,999,999.99"  

_nLin++
@ _nLin, 000 PSay "Total Devol. (SubProd) "
@ _nLin, 045 PSay _aTotais[ 21 ][ 01 ]	Picture "@E 999,999,999.99"
@ _nLin, 065 PSay _aTotais[ 21 ][ 02 ]	Picture "@E 999,999,999.99"
@ _nLin, 085 PSay _aTotais[ 21 ][ 03 ]	Picture "@E 999,999,999.99"  

_nLin++
@ _nLin, 000 PSay "Total Vendas (SubProd)"
@ _nLin, 045 PSay _aTotais[ 16 ][ 01 ]	Picture "@E 999,999,999.99"
@ _nLin, 065 PSay _aTotais[ 16 ][ 02 ]	Picture "@E 999,999,999.99"
@ _nLin, 085 PSay _aTotais[ 16 ][ 03 ]	Picture "@E 999,999,999.99"  

_nLin++
@ _nLin, 000 PSay "---------------------------------------------------------------------------------------------------"

If _nLin != 80
	Roda( cbCont, cbTxt, "M" )
EndIf

If aReturn[ 05 ] = 01
	Set Printer To
	Commit
	OurSpool( WnRel )
EndIf

MS_Flush()

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ValidPerg ³ Autor ³ Celso Costa          ³ Data ³20/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida Pergunte                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ValidPerg()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _aArea	:= GetArea()
Local _aRegs	:= {}
Local i,j
Local aHelpPor := {}
Local aHelpSpa := {}
Local aHelpEng := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria registros de pergunta                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( _aRegs, {_cPerg,"01","Data de"	       ,"","","mv_ch1","D",08,00,00,"G","","","","","","","","","","","","","","","","","","","","","","","","","","","","S","","",""} )
Aadd( _aRegs, {_cPerg,"02","Data ate"	       ,"","","mv_ch2","D",08,00,00,"G","","","","","","","","","","","","","","","","","","","","","","","","","","","","S","","",""} )
Aadd( _aRegs, {_cPerg,"03","Ordem"		       ,"","","mv_ch3","N",01,00,00,"C","","","Data Digitacao","","","","","Data Emissao NF","","","","","","","","","","","","","","","","","","","","S","","",""} )

Aadd(aHelpPor, 'Selecione as filiais a serem') 
Aadd(aHelpPor, 'utilizadas.')
Aadd( aHelpSpa, '')
Aadd( aHelpEng, '')
PutSx1(_cPerg,"04","Seleciona filiais","","","mv_ch4","C",50,0,0,"G","U_FXFIL()","","","",;
       "mv_par04","","","","","","","","",;
       "","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida/Cria Pergunte                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "SX1" )
dbSetOrder( 01 )

For i := 01 To Len( _aRegs )

	If !dbSeek( _cPerg + _aRegs[ i, 02 ] )

		RecLock( "SX1", .T. )

		For j := 01 To FCount()
		
			If j <= Len( _aRegs[ i ] )
				FieldPut( j, _aRegs[ i, j ] )
			EndIf

		Next

		SX1->( MsUnlock() )

	EndIf

Next

RestArea( _aArea )

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CntRegs   ³ Autor ³ Celso Costa          ³ Data ³03/01/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Conta registros para processamento                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CntRegs()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CntRegs()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _cQuery	:= ""
Local _nTotReg	:= 00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Conta registros                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cQuery := "SELECT COUNT( D2_DOC ) AS TOTREG "
/*SQL 2000
_cQuery += "FROM "
_cQuery += RetSqlName( "SD2" ) + " D2, "
_cQuery += RetSqlName( "SC5" ) + " C5, "
_cQuery += RetSqlName( "SB1" ) + " B1, "
_cQuery += RetSqlName( "SZD" ) + " ZD "
_cQuery += "WHERE "
_cQuery += "D2.D2_EMISSAO BETWEEN '" + DtoS( mv_par01 ) + "' AND '" + DtoS( mv_par02 ) + "' "
_cQuery += "AND D2.D2_TIPO = 'N' "
_cQuery += "AND D2.D2_GRUPO >= '0300' AND D2.D2_GRUPO <= '0911' "
_cQuery += "AND "
_cQuery += "(  D2.D2_CF = '5101' OR D2.D2_CF = '5102' OR D2.D2_CF = '511' "
_cQuery += "OR D2.D2_CF = '5922' OR D2.D2_CF = '5118' OR D2.D2_CF = '512' "
_cQuery += "OR D2.D2_CF = '6101' OR D2.D2_CF = '6102' OR D2.D2_CF = '6107' "
_cQuery += "OR D2.D2_CF = '6109' OR D2.D2_CF = '611'  OR D2.D2_CF = '6922' "
_cQuery += "OR D2.D2_CF = '6118' OR D2.D2_CF = '5501' OR D2.D2_CF = '6501' "
_cQuery += "OR D2.D2_CF = '7101' OR D2.D2_CF = '7102' ) "
_cQuery += "AND D2.D_E_L_E_T_ = '' "
_cQuery += "AND D2.D2_FILIAL = '" + xFilial( "SD2" ) + "' "
_cQuery += "AND C5.C5_FILIAL = '" + xFilial( "SC5" ) + "' "
_cQuery += "AND C5.C5_NUM = D2.D2_PEDIDO "
_cQuery += "AND B1.B1_COD = D2.D2_COD "
_cQuery += "AND B1.B1_FILIAL = '" + xFilial( "SB1" ) +  "' "
_cQuery += "AND ZD.ZD_NUMNF =* D2.D2_DOC "
*/
//SQL 2005
_cQuery += "FROM "
_cQuery += RetSqlName( "SC5" ) + " C5, "
_cQuery += RetSqlName( "SB1" ) + " B1, "
_cQuery += RetSqlName( "SZD" ) + " ZD RIGHT OUTER JOIN "
_cQuery += RetSqlName( "SD2" ) + " D2 ON "
_cQuery += "ZD.ZD_NUMNF = D2.D2_DOC "
_cQuery += "WHERE "
_cQuery += "D2.D2_EMISSAO BETWEEN '" + DtoS( mv_par01 ) + "' AND '" + DtoS( mv_par02 ) + "' "
_cQuery += "AND D2.D2_TIPO = 'N' "
//_cQuery += "AND D2.D2_GRUPO >= '0300' AND D2.D2_GRUPO <= '0911' " 
_cQuery += "AND D2.D2_GRUPO >= '0110' AND D2.D2_GRUPO <= '0911' " 
_cQuery += "AND "
_cQuery += " (D2.D2_CF = '5101'   OR   D2.D2_CF = '5105'   OR   D2.D2_CF = '5116' OR "
_cQuery += " D2.D2_CF = '5401'   OR   D2.D2_CF = '5910'   OR   D2.D2_CF = '5923'  OR "
_cQuery += " D2.D2_CF = '5924'   OR   D2.D2_CF = '6101'   OR   D2.D2_CF = '6105'  OR "
_cQuery += " D2.D2_CF = '6109'   OR   D2.D2_CF = '6116'   OR   D2.D2_CF = '6401'  OR "
_cQuery += " D2.D2_CF = '6501'   OR   D2.D2_CF = '6910'   OR   D2.D2_CF = '7101') " 
/*_cQuery += "(  D2.D2_CF = '5101' OR D2.D2_CF = '5102' OR D2.D2_CF = '511' "
_cQuery += "OR D2.D2_CF = '5922' OR D2.D2_CF = '5118' OR D2.D2_CF = '512' "
_cQuery += "OR D2.D2_CF = '6101' OR D2.D2_CF = '6102' OR D2.D2_CF = '6107' "
_cQuery += "OR D2.D2_CF = '6109' OR D2.D2_CF = '611'  OR D2.D2_CF = '6922' "
_cQuery += "OR D2.D2_CF = '6118' OR D2.D2_CF = '5501' OR D2.D2_CF = '6501' "
_cQuery += "OR D2.D2_CF = '7101' OR D2.D2_CF = '7102' ) "    */
_cQuery += "AND D2.D_E_L_E_T_ = '' "
_cQuery += "AND D2.D2_FILIAL IN (" + ALLTRIM(MV_PAR04) + ") "
_cQuery += "AND C5.C5_FILIAL IN (" + ALLTRIM(MV_PAR04) + ") "
//_cQuery += "AND D2.D2_FILIAL = '" + xFilial( "SD2" ) + "' "
//_cQuery += "AND C5.C5_FILIAL = '" + xFilial( "SC5" ) + "' "
_cQuery += "AND C5.C5_NUM = D2.D2_PEDIDO "
_cQuery += "AND B1.B1_COD = D2.D2_COD " 
_cQuery += "AND C5.C5_TPFRETE IN ('C','F') "
_cQuery += "AND B1.B1_FILIAL = '" + xFilial( "SB1" ) +  "' "

MsAguarde( { ||dbUseArea( .T., "TOPCONN", TCGenQry( ,, _cQuery ), "QRYTMP", .F., .T. ) }, "Contando registros ..." )

dbSelectArea( "QRYTMP" )
_nTotReg := QRYTMP->TOTREG
QRYTMP->( dbCloseArea() )

Return ( _nTotReg )