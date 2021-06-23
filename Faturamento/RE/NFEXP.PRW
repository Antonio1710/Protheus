#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/05/01
User Function NFEXP()        // incluido pelo assistente de conversao do AP5 IDE em 14/05/01  

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Nota Fiscal de Entrada/Saida')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
SetPrvt("CNATUREZA,ARETURN,NOMEPROG,CPERG,NLASTKEY,LCONTINUA")
SetPrvt("NLIN,WNREL,NTAMNF,CSTRING,CPEDANT,NLININI")
SetPrvt("XNUM_NF,XSERIE,XEMISSAO,XTOT_FAT,XLOJA,XFRETE")
SetPrvt("XSEGURO,XBASE_ICMS,XBASE_IPI,XVALOR_ICMS,XICMS_RET,XVALOR_IPI")
SetPrvt("XVALOR_MRC,XNUM_DUPLIC,XCOND_PAG,XPBRUTO,XPLIQUI,XTIPO")
SetPrvt("XESPECIE,XVOLUME,CPEDATU,CITEMATU,XPED_VEND,XITEM_PED")
SetPrvt("XNUM_NFDV,XPREF_DV,XICMS,XCOD_PRO,XQTD_PRO,XUNI_PRO,XPRE_UNI")
SetPrvt("XPRE_TAB,XIPI,XVAL_IPI,XDESC,XVAL_DESC,XVAL_MERC")
SetPrvt("_XTES,XCF,XICMSOL,XICM_PROD,XPESO_PRO,XPESO_UNIT")
SetPrvt("XDESCRICAO,XCOD_TRIB,XMEN_TRIB,XCOD_FIS,XCLAS_FIS")
SetPrvt("XMEN_POS,XISS,XTIPO_PRO,XLUCRO,XCLFISCAL,XPESO_LIQ")
SetPrvt("I,NPELEM,_CLASFIS,NPTESTE,XPESO_LIQUID,XPED")
SetPrvt("XPESO_BRUTO,XP_LIQ_PED,XCLIENTE,XTIPO_NF,XTIPO_CLI,XCOD_MENS")
SetPrvt("XMENSAGEM,XTPFRETE,XCONDPAG,XCOD_VEND,XDESC_NF,XDESC_PAG")
SetPrvt("XMENSAGE2,XMENSAGE3,XMENSAGE4,XMENSAGE5")
//SetPrvt("XPED_CLI,XDESC_PRO,,J,XCOD_CLI,XNOME_CLI,XLOJ_CLI,XEND_CLI")
SetPrvt("XPED_CLI,XDESC_PRO,XCFOP,J,XCOD_CLI,XNOME_CLI,XLOJ_CLI,XEND_CLI")
SetPrvt("XBAIRRO,XCEP_CLI,XCOB_CLI,XREC_CLI,XRAZENT,XCGCENT,XINSENT,XMUN_CLI,XEST_CLI")
SetPrvt("XCGC_CLI,XINSC_CLI,XTRAN_CLI,XTEL_CLI,XFAX_CLI,XSUFRAMA")
SetPrvt("XCALCSUF,XIMPENT,ZFRANCA,XVENDEDOR,XBSICMRET,XNOME_TRANSP,XEND_TRANSP")
SetPrvt("XMUN_TRANSP,XEST_TRANSP,XVIA_TRANSP,XCGC_TRANSP,XINS_TRANSP,XTEL_TRANSP")
SetPrvt("XPARC_DUP,XVENC_DUP,XVALOR_DUP,XDUPLICATAS,XNATUREZA,XFORNECE")
SetPrvt("XNFORI,XPEDIDO,XPESOPROD,XFAX,NOPC,CCOR")
SetPrvt("_nTamDet,XB_ICMS_SOL,XV_ICMS_SOL,NCONT,NCOL,NTAMOBS")
SetPrvt("NAJUSTE,BB,")
SetPrvt("_Desc_Item,_Cod_NCM")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  Nfiscal ³ Autor ³   Marcos Simidu       ³ Data ³ 20/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Nota Fiscal de Entrada/Saida                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ALTERACOES³ 10/04/2003 - Heraldo                                       ³±±
±±³          ³ Acertado para impfressao de CFOP na frente da descricao do ³±±
±±³          ³ produto, necessario quando sai mais que um CFOP na mesma   ³±±
±±³          ³ nota.                                                      ³±±
±±³          ³ Alterado indice do SE1, para pegar o correto na geracao    ³±±
±±³          ³ do vencimento da NF.                                       ³±±
±±³          ³ Acerto no total da NF quando 2 CFOP's, deve ser incorporado³±±
±±³          ³ ao total o valor do produto de bonificacao, porem nao deve ³±±
±±³          ³ gerar financeiro.                                          ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Ambientais                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // Da Nota Fiscal                       ³
//³ mv_par02             // Ate a Nota Fiscal                    ³
//³ mv_par03             // Da Serie                             ³
//³ mv_par04             // Nota Fiscal de Entrada/Saida         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CbTxt:=""
CbCont:=""
nOrdem :=0
Alfa := 0
Z:=0
M:=0
tamanho:="M"
limite:=132
titulo :=PADC("Nota Fiscal - Nfiscal",74)
cDesc1 :=PADC("Este programa ira emitir a Nota Fiscal de Entrada/Saida",74)
cDesc2 :=""
cDesc3 :=PADC("da Nfiscal",74)
cNatureza :=""
aReturn   := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog  :="nfiscal"
cPerg:="NFSIGZ"
nLastKey  := 0
lContinua := .T.
nLin:=0
wnrel     := "siganf"
xIMPENT   := " "
xPED_VEND :={}
PNOTA:=1
xCONTAIN := space(15)
xLACRE1   := space(15)
xLACRE2 :=  space(15)
xTEMPERA := 0
xNFORI:= SPACE(06)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tamanho do Formulario de Nota Fiscal (em Linhas)          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nTamNf:=63

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas, busca o padrao da Nfiscal           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte(cPerg,.F.)               // Pergunta no SX1

cString:="SF2"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)
If nLastKey == 27
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
	Return
Endif

VerImp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do Processamento da Nota Fiscal                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RptDetail()})// Substituido pelo assistente de conversao do AP5 IDE em 14/05/01 ==>       RptStatus({|| Execute(RptDetail)})
Return
Static Function RptDetail()

If mv_par04 == 2
	dbSelectArea("SF2")                // * Cabecalho da Nota Fiscal Saida
	// Alt RNUTTI 27/05/2002
	dbSetOrder(1)
	dbSeek(xFilial("SF2")+mv_par01+mv_par03,.t.)
	// dbSetOrder(6)
	// dbSeek(xFilial("SF2")+mv_par05+"  "+mv_par01+mv_par03,.t.)
	// FA
	
	dbSelectArea("SD2")                // * Itens de Venda da Nota Fiscal
	dbSetOrder(3)
	// Alt RNUTTI 27/05/2002
	dbSeek(xFilial("SD2")+mv_par01+mv_par03)
	// dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE)
	// FA
	cPedant := SD2->D2_PEDIDO
Else
	dbSelectArea("SF1")                // * Cabecalho da Nota Fiscal Entrada
	DbSetOrder(1)
	dbSeek(xFilial("SF1")+mv_par01+mv_par03,.t.)
	
	dbSelectArea("SD1")                // * Itens da Nota Fiscal de Entrada
	dbSetOrder(3)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetRegua(Val(mv_par02)-Val(mv_par01))

If mv_par04 == 2
	
	dbSelectArea("SF2")
	
	Do While !Eof() .and. SF2->F2_FILIAL==xFilial("SF2") .and. ;
		SF2->F2_DOC <= mv_par02  .and. lContinua
		
		//  .and. SF2->F2_ROTEIRO>=mv_par05 .and. SF2->F2_ROTEIRO<=mv_par06;
		
		If SF2->F2_SERIE #mv_par03
			DbSkip()
			Loop
		Endif
		
		//          If SF2->F2_DOC < mv_par01 .or.  SF2->F2_DOC > mv_par02
		//                  DbSkip()
		//                  Loop
		//          Endif
		
		If SF2->F2_ROTEIRO < mv_par05 .or.;
			SF2->F2_ROTEIRO > mv_par06
			DbSkip()
			Loop
		Endif
		
		IF lAbortPrint
			@ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
			lContinua := .F.
			Exit
		Endif
		
		nLinIni:=nLin                         // Linha Inicial da Impressao
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicio de Levantamento dos Dados da N`ota Fiscal              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		// * Cabecalho da Nota Fiscal
		
		xNUM_NF     :=SF2->F2_DOC             // Numero
		xSERIE      :=SF2->F2_SERIE           // Serie
		xEMISSAO    :=SF2->F2_EMISSAO         // Data de Emissao
		// alteracao HERALDO - 10/04/2003
		//		xTOT_FAT    :=SF2->F2_VALFAT          // Valor Total da Fatura
		xTOT_FAT    :=SF2->F2_VALBRUT          // Valor Total da Fatura
		// FIM DA ALTERACAO
		if xTOT_FAT == 0
			xTOT_FAT := SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_SEGURO+SF2->F2_FRETE
		endif
		xRota       :=" Roteiro:"+SF2->F2_ROTEIRO+" Seq:"+SF2->F2_SEQUENC  // Roteiro + Sequencia
		xCLIENTE    :=SF2->F2_CLIENTE         // Código do Cliente
		xLOJA       :=SF2->F2_LOJA            // Loja do Cliente
		xFRETE      :=SF2->F2_FRETE           // Frete
		xSEGURO     :=SF2->F2_SEGURO          // Seguro
		xBASE_ICMS  :=SF2->F2_BASEICM         // Base   do ICMS
		xBASE_IPI   :=SF2->F2_BASEIPI         // Base   do IPI
		xVALOR_ICMS :=SF2->F2_VALICM          // Valor  do ICMS
		xICMS_RET   :=SF2->F2_ICMSRET         // Valor  do ICMS Retido
		xVALOR_IPI  :=SF2->F2_VALIPI          // Valor  do IPI
		xVALOR_MERC :=SF2->F2_VALMERC         // Valor  da Mercadoria
		xNUM_DUPLIC :=SF2->F2_DUPL            // Numero da Duplicata
		xCOND_PAG   :=SF2->F2_COND            // Condicao de Pagamento
		xTIPO       :=SF2->F2_TIPO            // Tipo do Cliente
		xESPECIE    :=SF2->F2_ESPECI1         // Especie 1 no Pedido
		xVOLUME     :=SF2->F2_VOLUME1         // Volume 1 no Pedido
		xCONTAIN := SF2->F2_CONTAIN       //Container de Exportação
		xLACRE1   :=  	SF2->F2_NLACRE1                       // Lacre do Container
		xLACRE2 :=   SF2->F2_NLACRE2                              //Lacre do SIF
		xTEMPERA := SF2->F2_TEMPERA          //Temperatura Exportação
		xDTPROD:= SF2->F2_DTPROD
		
		dbSelectArea("SD2")                   // * Itens de Venda da N.F.
		dbSetOrder(3)
		dbSeek(xFilial("SD2")+xNUM_NF+xSERIE)
		
		cPedAtu  := SD2->D2_PEDIDO
		cItemAtu := SD2->D2_ITEMPV
		xPED_VEND:={}                         // Numero do Pedido de Venda
		xITEM_PED:={}                         // Numero do Item do Pedido de Venda
		xNUM_NFDV:={}                         // nUMERO QUANDO HOUVER DEVOLUCAO
		xPREF_DV :={}                         // Serie  quando houver devolucao
		xICMS    :={}                         // Porcentagem do ICMS
		xCOD_PRO :={}                         // Codigo  do Produto
		xUNI_PRO :={}
		xQTD_PRO :={}                         // Peso/Quantidade do Produto
		xPRE_UNI :={}                         // Preco Unitario de Venda
		xPRE_TAB :={}                         // Preco Unitario de Tabela
		xIPI     :={}                         // Porcentagem do IPI
		xVAL_IPI :={}                         // Valor do IPI
		xDESC    :={}                         // Desconto por Item
		xVAL_DESC:={}                         // Valor do Desconto
		xSITTRIB :={}                         // Codigo de Situacao Tributaria do
		xVAL_MERC:={}                         // Valor da Mercadoria
		_xTES    :={}                         // TES
		xCFOP    :={}
		xFORMULA  :={}                       // Formula
		xCF      :={}                         // Classificacao quanto natureza da Operacao
		xICMSOL  :={}                         // Base do ICMS Solidario
		xICM_PROD:={}                         // ICMS do Produto
		xCLAS_FIS:={}                           // Classificacao Fiscal
		
		Do While !eof() .and. SD2->D2_DOC==xNUM_NF .and. SD2->D2_SERIE==xSERIE
			
			If SD2->D2_SERIE # mv_par03
				DbSkip()
				Loop
			Endif
			
			AADD(xPED_VEND ,SD2->D2_PEDIDO)
			AADD(xITEM_PED ,SD2->D2_ITEMPV)
			AADD(xNUM_NFDV ,IIF(Empty(SD2->D2_NFORI),"",SD2->D2_NFORI))
			AADD(xPREF_DV  ,SD2->D2_SERIORI)
			AADD(xICMS     ,IIf(Empty(SD2->D2_PICM),0,SD2->D2_PICM))
			AADD(xCOD_PRO  ,SD2->D2_COD)
			AADD(xQTD_PRO  ,SD2->D2_QUANT)     // Guarda as quant. da NF
			AADD(xUNI_PRO  ,SD2->D2_UM)
			AADD(xPRE_UNI  ,SD2->D2_PRCVEN)
			AADD(xPRE_TAB  ,SD2->D2_PRUNIT)
			AADD(xIPI      ,IIF(Empty(SD2->D2_IPI),0,SD2->D2_IPI))
			AADD(xVAL_IPI  ,SD2->D2_VALIPI)
			AADD(xDESC     ,SD2->D2_DESC)
			AADD(xVAL_MERC ,SD2->D2_TOTAL)
			AADD(_xTES     ,SD2->D2_TES)
			AADD(xCF       ,SD2->D2_CF)
			AADD(xICM_PROD ,IIf(Empty(SD2->D2_PICM),0,SD2->D2_PICM))
			AADD(xCFOP 		,SD2->D2_CF)
			//	AADD(xCLAS_FIS, SB1->B1_POSIPI)                           // Classificacao Fiscal
			
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek( xFilial("SF4")+SD2->D2_TES )
			AADD(xSITTRIB  ,SF4->F4_SITTRIB)        // Situacao Tributaria
			AADD(xFORMULA  ,SF4->F4_FORMULA)        // Formula
			dbSelectArea("SD2")
			
			dbskip()
		Enddo
		
		dbSelectArea("SB1")                     // * Desc. Generica do Produto
		dbSetOrder(1)
		
		xDESC_PRO:={}                         // Descricao do Produto
		xCOD_TRIB:={}                           // Codigo de Tributacao
		xMEN_TRIB:={}                           // Mensagens de Tributacao
		xCOD_FIS :={}                           // Cogigo Fiscal
		xCLAS_FIS:={}                           // Classificacao Fiscal
		xMEN_POS :={}                           // Mensagem da Posicao IPI
		xISS     :={}                           // Aliquota de ISS
		xTIPO_PRO:={}                           // Tipo do Produto
		xLUCRO   :={}                           // Margem de Lucro p/ ICMS Solidario
		xCLFISCAL   :={}
		I:=1
		
		For I:=1 to Len(xCOD_PRO)
			
			dbSeek(xFilial()+xCOD_PRO[I])
			// Werner (teste) 19/03/2003
			// Posiciono no item do pedido para pegar o CFOP
			//			dbSelectArea("SD2")                   // * Itens da N.F. de Compra
			//			dbSetOrder(3)
			//			dbSeek(xFilial()+xNUM_NF+xSERIE+xCliente+xLOJA+xCOD_PRO[I]+STR(I,2))
			// Indice dos itens
			// D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			// Alterado por Werner em 20/092006 para pegar a descrição da tabela SB5
			_cDesc_Prd :=  SB1->B1_DESCOMP
			AADD(xDESC_PRO ,_cDesc_Prd)
			AADD(xCOD_TRIB ,SB1->B1_ORIGEM)
			AADD(xCLAS_FIS  ,SB1->B1_POSIPI)
			//			AADD(xCFOP , SD2->D2_CF)
			If Ascan(xMEN_TRIB,SB1->B1_ORIGEM)==0
				AADD(xMEN_TRIB ,SB1->B1_ORIGEM)
			Endif
			
			//npElem := ascan(xCLAS_FIS,SB1->B1_POSIPI)
			//if npElem == 0
			//	AADD(xCLAS_FIS  ,SB1->B1_POSIPI)
			//endif
			//npElem := ascan(xCLAS_FIS,SB1->B1_POSIPI)
			
			DO CASE
				CASE npElem == 1
					_CLASFIS := "A"
					
				CASE npElem == 2
					_CLASFIS := "B"
					
				CASE npElem == 3
					_CLASFIS := "C"
					
				CASE npElem == 4
					_CLASFIS := "D"
					
				CASE npElem == 5
					_CLASFIS := "E"
					
				CASE npElem == 6
					_CLASFIS := "F"
					
			ENDCASE
			
			nPteste := Ascan(xCLFISCAL,_CLASFIS)
			If nPteste == 0
				AADD(xCLFISCAL,_CLASFIS)
			Endif
			
			AADD(xCOD_FIS ,_CLASFIS)
			If SB1->B1_ALIQISS > 0
				AADD(xISS ,SB1->B1_ALIQISS)
			Endif
			AADD(xTIPO_PRO ,SB1->B1_TIPO)
			AADD(xLUCRO    ,SB1->B1_PICMRET)
			
		Next
		
		dbSelectArea("SC5")                            // * Pedidos de Venda
		dbSetOrder(1)
		
		xPED := {}
		
		xPESO_LIQUID:=0                                 // Peso Liquido da Nota Fiscal
		xPESO_BRUTO := 0
		
		For I:=1 to Len(xPED_VEND)
			
			dbSeek(xFilial()+xPED_VEND[I])
			
			If ASCAN(xPED,xPED_VEND[I])==0
				dbSeek(xFilial()+xPED_VEND[I])
				xCLIENTE    :=SC5->C5_CLIENTE            // Codigo do Cliente
				xTIPO_NF    :=SC5->C5_TIPO               // Tipo da Nota Fiscal
				xTIPO_CLI   :=SC5->C5_TIPOCLI            // Tipo de Cliente
				// xCOD_MENS   :=SC5->C5_MENPAD             // Codigo da Mensagem Padrao
				xMENSAGEM   :=SC5->C5_MENNOTA            // Mensagem para a Nota Fiscal
				
				// Inclusao RNUTTI 10/10/2001 - Mensagens Adicionais
				xMENSAGE2   :=SC5->C5_MENNOT2           // Mensagem 2 para a Nota Fiscal
				xMENSAGE3   :=SC5->C5_MENNOT3           // Mensagem 3 para a Nota Fiscal
				xMENSAGE4   :=SC5->C5_MENNOT4           // Mensagem 4 para a Nota Fiscal
				xMENSAGE5   :=SC5->C5_MENNOT5           // Mensagem 5 para a Nota Fiscal
				// Fim das Inclusoes
				
				xTPFRETE    :=SC5->C5_TPFRETE            // Tipo de Entrega
				xCONDPAG    :=SC5->C5_CONDPAG            // Condicao de Pagamento
				xPESO_BRUTO :=SC5->C5_PBRUTO             // Peso Bruto
				xPESO_LIQUID:=SC5->C5_PESOL              // Peso Liquido
				xVOLUME     :=SC5->C5_VOLUME1            // QTDE CAIXAS
				
				xCOD_VEND:= {SC5->C5_VEND1,;             // Codigo do Vendedor 1
				SC5->C5_VEND2,;             // Codigo do Vendedor 2
				SC5->C5_VEND3,;             // Codigo do Vendedor 3
				SC5->C5_VEND4,;             // Codigo do Vendedor 4
				SC5->C5_VEND5}              // Codigo do Vendedor 5
				xDESC_NF := {SC5->C5_DESC1,;             // Desconto Global 1
				SC5->C5_DESC2,;             // Desconto Global 2
				SC5->C5_DESC3,;             // Desconto Global 3
				SC5->C5_DESC4}              // Desconto Global 4
				AADD(xPED,xPED_VEND[I])
			Endif
			
		Next
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pesquisa da Condicao de Pagto               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		
		dbSelectArea("SE4")                    // Condicao de Pagamento
		dbSetOrder(1)
		IF dbSeek(xFilial("SE4")+xCONDPAG)
			xDESC_PAG := SE4->E4_DESCRI
		ELSE
			xDESC_PAG := ''
		ENDIF
		
		dbSelectArea("SC6")                    // * Itens de Pedido de Venda
		dbSetOrder(1)
		xPED_CLI :={}                          // Numero de Pedido
		xDESC_PRO:={}                          // escricao aux do produto
		xUNIDADE :={}
		xCAIXAS   :={}
		J:=Len(xPED_VEND)
		
		For I:=1 to J
			dbSeek(xFilial()+xPED_VEND[I]+xITEM_PED[I])
			AADD(xPED_CLI ,SC6->C6_PEDCLI)
			// Descrição do Produto alterado em 20/09/2006 para ter a descrição cientifica
			_cDesc_Prd := SC6->C6_DESCRI
			dbSelectArea("SB1")                     // * Desc. Generica do Produto
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+SC6->C6_PRODUTO)
			_cDesc_Prd :=  SB1->B1_DESCOMP
			AADD(xDESC_PRO ,_cDesc_Prd)
			dbSelectArea("SC6")                    // * Itens de Pedido de Venda
			dbSetOrder(1)
			AADD(xVAL_DESC,SC6->C6_VALDESC)
			AADD(xCAIXAS  ,SC6->C6_UNSVEN)
			AADD(xUNIDADE ,SC6->C6_SEGUM)
		Next
		
		If xTIPO=='N' .OR. xTIPO=='C' .OR. xTIPO=='P' .OR. xTIPO=='I' .OR. xTIPO=='S' .OR. xTIPO=='T' .OR. xTIPO=='O'
			
			dbSelectArea("SA1")                // * Cadastro de Clientes
			dbSetOrder(1)
			dbSeek(xFilial()+xCLIENTE+xLOJA)
			xCOD_CLI :=SA1->A1_COD             // Codigo do Cliente
			xLOJ_CLI :=SA1->A1_LOJA            // loja do Cliente
			xNOME_CLI:=SA1->A1_NOME            // Nome
			xEND_CLI :=SA1->A1_END             // Endereco
			xBAIRRO  :=SA1->A1_BAIRRO          // Bairro
			xCEP_CLI :=SA1->A1_CEP             // CEP
			xCOB_CLI :=SA1->A1_ENDCOB          // Endereco de Cobranca
			xREC_CLI :=SA1->A1_ENDENT             // Endereco de Entrega
			xINSENT  :=SA1->A1_INSENT             // Inscricao entrega Entrega
			xCGCENT  :=SA1->A1_CGCENT             // cgc   Entrega
			xRAZENT  :=SA1->A1_RAZENT             // Razao Entrega
			xMUN_CLI :=SA1->A1_MUN             // Municipio
			xEST_CLI :=SA1->A1_EST             // Estado
			xCGC_CLI :=SA1->A1_CGC             // CGC
			xINSC_CLI:=SA1->A1_INSCR           // Inscricao estadual
			xTRAN_CLI:=SA1->A1_TRANSP          // Transportadora
			xTEL_CLI :=SA1->A1_TEL             // Telefone
			xFAX_CLI :=SA1->A1_FAX             // Fax
			xSUFRAMA :=SA1->A1_SUFRAMA            // Codigo Suframa
			xCALCSUF :=SA1->A1_CALCSUF            // Calcula Suframa
			// Inclusao RNUTTI 30/07/2002
			xIMPENT  :=SA1->A1_IMPENT             // Imprime Endereco de Entrega
			xREC_CLI :=SA1->A1_ENDENT             // Endereco Entrega
			xRAZENT  :=SA1->A1_RAZENT             // Razao Entrega
			xINSENT  :=SA1->A1_INSENT             // Inscricao entrega Entrega
			xCGCENT  :=SA1->A1_CGCENT             // cgc   Entrega
			xBAIRROE :=SA1->A1_BAIRROE            // Bairro Entrega
			xCEPE    :=SA1->A1_CEPE               // CEP Entrega
			xMUNE    :=SA1->A1_MUNE               // Municipio Entrega
			xESTE    :=SA1->A1_ESTE               // Estado Entrega
			xNRE     :=SA1->A1_NRE                // No. Regime Especial
			// Fim Inclusoes
			
			if !empty(xSUFRAMA) .and. xCALCSUF =="S"
				IF XTIPO == 'D' .OR. XTIPO == 'B'
					zFranca := .F.
				else
					zFranca := .T.
				endif
			Else
				zfranca:= .F.
			endif
			
		Else
			zFranca:=.F.
			dbSelectArea("SA2")                // * Cadastro de Fornecedores
			dbSetOrder(1)
			dbSeek(xFilial()+xCLIENTE+xLOJA)
			xCOD_CLI :=SA2->A2_COD             // Codigo do Fornecedor
			xLOJ_CLI :=SA2->A2_LOJA            // loja do Cliente
			xNOME_CLI:=SA2->A2_NOME            // Nome Fornecedor
			xEND_CLI :=SA2->A2_END             // Endereco
			xBAIRRO  :=SA2->A2_BAIRRO          // Bairro
			xCEP_CLI :=SA2->A2_CEP             // CEP
			xCOB_CLI :=""                      // Endereco de Cobranca
			xREC_CLI :=""                      // Endereco de Entrega
			xCGCENT  :=""                      // CGC de Entrega
			xINSENT  :=""                      // INSCRICAO de Entrega
			xRAZENT  :=""                      // Razao Social de Entrega
			xMUN_CLI :=SA2->A2_MUN             // Municipio
			xEST_CLI :=SA2->A2_EST             // Estado
			xCGC_CLI :=SA2->A2_CGC             // CGC
			xINSC_CLI:=SA2->A2_INSCR           // Inscricao estadual
			xTRAN_CLI:=SA2->A2_TRANSP          // Transportadora
			xTEL_CLI :=SA2->A2_TEL             // Telefone
			xFAX_CLI :=SA2->A2_FAX             // Fax
			
		Endif
		
		dbSelectArea("SA3")                   // * Cadastro de Vendedores
		dbSetOrder(1)
		xVENDEDOR:={}                         // Nome do Vendedor
		I:=1
		J:=Len(xCOD_VEND)
		For I:=1 to J
			dbSeek(xFilial()+xCOD_VEND[I])
			Aadd(xVENDEDOR,SA3->A3_NREDUZ)
		Next
		
		If xICMS_RET >0                          // Apenas se ICMS Retido > 0
			dbSelectArea("SF3")              // * Cadastro de Livros Fiscais
			dbSetOrder(4)
			dbSeek(xFilial()+SA1->A1_COD+SA1->A1_LOJA+SF2->F2_DOC+SF2->F2_SERIE)
			If Found()
				xBSICMRET:=F3_VALOBSE
			Else
				xBSICMRET:=0
			Endif
		Else
			xBSICMRET:=0
		Endif
		dbSelectArea("SA4")                   // * Transportadoras
		dbSetOrder(1)
		dbSeek(xFilial("SA4")+SF2->F2_TRANSP)
		
		xNOME_TRANSP :=SA4->A4_NOME           // Nome Transportadora
		xEND_TRANSP  :=SA4->A4_END            // Endereco
		xMUN_TRANSP  :=SA4->A4_MUN            // Municipio
		xEST_TRANSP  :=SA4->A4_EST            // Estado
		xVIA_TRANSP  :=SA4->A4_VIA            // Via de Transporte
		xCGC_TRANSP  :=SA4->A4_CGC            // CGC
		xINS_TRANSP  :=SA4->A4_INSEST         // INSCRICAO ESTADUAL
		xTEL_TRANSP  :=SA4->A4_TEL            // Fone
		
		dbSelectArea("SE1")                   // * Contas a Receber
		
		// Alteracao RNUTTI 30/07/2002 - Na Ad'oro chave nao e' Pref+Num
		// dbSetOrder(1)
		// dbSetOrder(14) - ALTERADO POR HERALDO 10/04/2003
		dbSetOrder(28) //dbSetOrder(20) - Alterado 16/02/13. Ana - Ajuste para atualizacao Protheus 11
		// Fim Alteracoes
		
		xPARC_DUP  :={}                       // Parcela
		xVENC_DUP  :={}                       // Vencimento
		PRIVATE dVENC:=""
		//PRIVATE dVENC02:=''
		//PRIVATE dVENC03:=''
		xVALOR_DUP :={}                       // Valor
		
		// Alteracao RNUTTI 30/07/2002 - Na Ad'oro chave nao e' Pref+Num
		// xDUPLICATAS:=IIF(dbSeek(xFilial("SE1")+xSERIE+xNUM_DUPLIC,.T.),.T.,.F.) // Flag p/Impressao de Duplicatas
		xDUPLICATAS:=IIF(dbSeek(xFilial("SE1")+xNUM_DUPLIC,.T.),.T.,.F.) // Flag p/Impressao de Duplicatas
		// Fim Alteracoes
		
		Do While !Eof() .and. SE1->E1_NUM==xNUM_DUPLIC .and. xDUPLICATAS==.T.
			If !("NF" $ SE1->E1_TIPO)
				dbSkip()
				Loop
			Endif
			
			If 	SE1->E1_EMISSAO<>XEMISSAO
				dbSkip()
				Loop
			Endif
			
			
			//Verifica se vencimento é maior que data e emissao
			IF SE1->E1_VENCTO >= xEMISSAO
				AADD(xPARC_DUP ,SE1->E1_PARCELA)
				dVENC:=dVENC+  SUBSTR (DTOS(SE1->E1_VENCTO),7,2)+ "/" + SUBSTR (DTOS(SE1->E1_VENCTO),5,2) +"/"+ SUBSTR (DTOS(SE1->E1_VENCTO),1,4)+" "
				AADD(xVALOR_DUP,SE1->E1_VALOR)
			Endif
			dbSkip()
		EndDo
		
		dbSelectArea("SF4")                   // * Tipos de Entrada e Saida
		DbSetOrder(1)
		dbSeek(xFilial("SF4")+_xTES[1])
		xNATUREZA:=SF4->F4_TEXTO              // Natureza da Operacao
		
		Imprime()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Termino da Impressao da Nota Fiscal                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		IncRegua()
		
		nLin:=0
		
		dbSelectArea("SF2")
		dbSkip()
		
	EndDo
Else
	
	dbSelectArea("SF1")
	
	dbSeek(xFilial()+mv_par01+mv_par03,.t.)
	
	Do While !Eof() .and.  SF1->F1_FILIAL == xFilial("SF1") .and.;
		SF1->F1_DOC <= mv_par02 .and. lContinua
		//SF1->F1_DOC <= mv_par02 .and. SF1->F1_SERIE == mv_par03 .and. lContinua
		
		If SF1->F1_SERIE #mv_par03
			DbSkip()
			Loop
		Endif
		
		// Inclusao RNUTTI 06/08/2002 - Tratar Formulario Proprio
		If SF1->F1_FORMUL # "S"
			DbSkip()
			Loop
		Endif
		//
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa  regua de impressao                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SetRegua(Val(mv_par02)-Val(mv_par01))
		
		#IFNDEF WINDOWS
			IF LastKey()==286
				@ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
				lContinua := .F.
				Exit
			Endif
		#ELSE
			IF lAbortPrint
				@ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
				lContinua := .F.
				Exit
			Endif
		#ENDIF
		
		nLinIni:=nLin                         // Linha Inicial da Impressao
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicio de Levantamento dos Dados da Nota Fiscal              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		xNUM_NF     :=SF1->F1_DOC             // Numero
		xSERIE      :=SF1->F1_SERIE           // Serie
		xFORNECE    :=SF1->F1_FORNECE         // Cliente/Fornecedor
		xEMISSAO    :=SF1->F1_EMISSAO         // Data de Emissao
		xTOT_FAT    :=SF1->F1_VALBRUT         // Valor Bruto da Compra
		xLOJA       :=SF1->F1_LOJA            // Loja do Cliente
		xFRETE      :=SF1->F1_FRETE           // Frete
		xSEGURO     :=SF1->F1_DESPESA         // Despesa
		xBASE_ICMS  :=SF1->F1_BASEICM         // Base   do ICMS
		xBASE_IPI   :=SF1->F1_BASEIPI         // Base   do IPI
		xBSICMRET   :=SF1->F1_BRICMS          // Base do ICMS Retido
		xVALOR_ICMS :=SF1->F1_VALICM          // Valor  do ICMS
		xICMS_RET   :=SF1->F1_ICMSRET         // Valor  do ICMS Retido
		xVALOR_IPI  :=SF1->F1_VALIPI          // Valor  do IPI
		xVALOR_MERC :=SF1->F1_VALMERC         // Valor  da Mercadoria
		xNUM_DUPLIC :=SF1->F1_DUPL            // Numero da Duplicata
		xCOND_PAG   :=SF1->F1_COND            // Condicao de Pagamento
		xTIPO       :=SF1->F1_TIPO            // Tipo do Cliente
		//		xNFORI      :=SF1->F1_NFORI           // NF Original
		//		xPREF_DV    :=SF1->F1_SERIORI         // Serie Original
		
		// Inclusao RNUTTI 10/09/2002  (Antes em 15/03/2002)
		xDESCSF1    :=SF1->F1_DESCONT         // NF Original
		xMENSAGEM   :=SF1->F1_MENNOTA         // Mensagem 1 para a NFE
		xMENSAGE2   :=SF1->F1_MENNOTB         // Mensagem 2 para a NFE
		xMENSAGE3   :=" "
		xMENSAGE4   :=" "
		xMENSAGE5   :=" "
		// Fim Inclusoes
		
		dbSelectArea("SD1")                   // * Itens da N.F. de Compra
		dbSetOrder(1)
		dbSeek(xFilial()+xNUM_NF+xSERIE+xFORNECE+xLOJA)
		
		cPedAtu := SD1->D1_PEDIDO
		cItemAtu:= SD1->D1_ITEMPC
		xNFORI      :=SD1->D1_NFORI           // NF Original
		xPREF_DV    :=SD1->D1_SERIORI         // Serie O
		
		xPEDIDO  :={}                         // Numero do Pedido de Compra
		xITEM_PED:={}                         // Numero do Item do Pedido de Compra
		xNUM_NFDV:={}                         // Numero quando houver devolucao
		xPREF_DV :={}                         // Serie  quando houver devolucao
		xICMS    :={}                         // Porcentagem do ICMS
		xCOD_PRO :={}                         // Codigo  do Produto
		xQTD_PRO :={}                         // Peso/Quantidade do Produto
		xUNI_PRO :={}
		xPRE_UNI :={}                         // Preco Unitario de Compra
		xIPI     :={}                         // Porcentagem do IPI
		xPESOPROD:={}                         // Peso do Produto
		xVAL_IPI :={}                         // Valor do IPI
		xDESC    :={}                         // Desconto por Item
		xVAL_DESC:={}                         // Valor do Desconto
		xSITTRIB :={}                         // Codigo de Situacao Tributaria do
		xSITTRIB :={}                         // Codigo de Situacao Tributaria do
		xCFOP    :={}					// - INCLUIDO HERALDO 10/04/2003
		xCLAS_FIS:={}                           // Classificacao Fiscal
		xFORMULA :={}                         // Formula
		xVAL_MERC:={}                         // Valor da Mercadoria
		_xTES     :={}                         // TES
		xCF      :={}                         // Classificacao quanto natureza da Operacao
		xICMSOL  :={}                         // Base do ICMS Solidario
		xICM_PROD:={}                         // ICMS do Produto
		
		Do While !eof() .and. SD1->D1_DOC==xNUM_NF
			If SD1->D1_SERIE #mv_par03        // Se a Serie do Arquivo for Diferente
				DbSkip()                      // do Parametro Informado !!!
				Loop
			Endif
			//HERALDO 16/05/03 - CHECA SE E O MESMO FORNECEDOR/CLIENTE
			If SD1->D1_FORNECE # SF1->F1_FORNECE .OR. SD1->D1_LOJA # SF1->F1_LOJA
				DbSkip()
				Loop
			Endif
			// FIM DA ALTERACAO
			AADD(xPEDIDO ,SD1->D1_PEDIDO)           // Ordem de Compra
			AADD(xITEM_PED ,SD1->D1_ITEMPC)         // Item da O.C.
			AADD(xNUM_NFDV ,IIF(Empty(SD1->D1_NFORI),"",SD1->D1_NFORI))
			AADD(xPREF_DV  ,SD1->D1_SERIORI)        // Serie Original
			AADD(xICMS     ,IIf(Empty(SD1->D1_PICM),0,SD1->D1_PICM))
			AADD(xCOD_PRO  ,SD1->D1_COD)            // Produto
			AADD(xQTD_PRO  ,SD1->D1_QUANT)          // Guarda as quant. da NF
			AADD(xUNI_PRO  ,SD1->D1_UM)
			AADD(xPRE_UNI  ,SD1->D1_VUNIT)          // Valor Unitario
			// Alteracao RNUTTI 14/10/2002 - Argument #0
			//	AADD(xIPI      ,SD1->D1_IPI             // % IPI
			AADD(xIPI      ,IIf(Empty(SD1->D1_IPI),0,SD1->D1_IPI))    // % IPI
			// Fim das Alteracoes
			AADD(xVAL_IPI  ,SD1->D1_VALIPI)         // Valor do IPI
			AADD(xPESOPROD ,SD1->D1_PESO)           // Peso do Produto
			AADD(xDESC     ,SD1->D1_DESC)           // % Desconto
			AADD(xVAL_MERC ,SD1->D1_TOTAL)          // Valor Total
			AADD(_xTES     ,SD1->D1_TES)            // Tipo de Entrada/Saida
			AADD(xCF       ,SD1->D1_CF)             // Codigo Fiscal
			AADD(xICM_PROD ,IIf(Empty(SD1->D1_PICM),0,SD1->D1_PICM))
			AADD(xCFOP 	   , SD1->D1_CF)  // - INCLUIDO HERALDO 10/04/2003
			
			
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek( xFilial("SF4")+SD1->D1_TES )
			AADD(xSITTRIB  ,SF4->F4_SITTRIB)        // Situacao Tributaria
			AADD(xFORMULA  ,SF4->F4_FORMULA )       // Formula
			dbSelectArea("SD1")
			dbskip()
			
		End
		
		dbSelectArea("SB1")                     // * Desc. Generica do Produto
		dbSetOrder(1)
		
		// Alt RNUTTI 09/10/2001 - UNI_PRO deve trazer informacoes do SD2, e nao do SB1
		// xUNI_PRO:={}                           // Unidade do Produto
		
		xDESC_PRO:={}                           // Descricao do Produto
		xMEN_POS :={}                           // Mensagem da Posicao IPI
		xDESCRICAO :={}                         // Descricao do Produto
		xCOD_TRIB:={}                           // Codigo de Tributacao
		xMEN_TRIB:={}                           // Mensagens de Tributacao
		xCOD_FIS :={}                           // Cogigo Fiscal
		xCLAS_FIS:={}                           // Classificacao Fiscal
		xISS     :={}                           // Aliquota de ISS
		xTIPO_PRO:={}                           // Tipo do Produto
		xLUCRO   :={}                           // Margem de Lucro p/ ICMS Solidario
		xCLFISCAL   :={}
		xSUFRAMA :=""
		xCALCSUF :=""
		
		I:=1
		For I:=1 to Len(xCOD_PRO)
			
			dbSeek(xFilial()+xCOD_PRO[I])
			// Werner (teste) 19/03/2003
			// Posiciono no item do pedido para pegar o CFOP
			dbSelectArea("SD1")                   // * Itens da N.F. de Compra
			dbSetOrder(3)
			dbSeek(xFilial()+xNUM_NF+xSERIE+xFORNECE+xLOJA+xCOD_PRO[I]+STR(I,2))
			// Indice dos itens
			// D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			
			// Alterado por Werner em 20/092006 para pegar a descrição da tabela SB5
			_cDesc_Prd :=  SB1->B1_DESCOMP
			AADD(xDESC_PRO ,_cDesc_Prd)
			dbSelectArea("SD1")                   // * Itens da N.F. de Compra
			dbSetOrder(3)
			
			//AADD(xCFOP , SD1->D1_CF)
			AADD(xDESCRICAO ,SB1->B1_DESC)
			//    	    AADD(xCFOP , SD1->D1_CF)  - HERALDO 10/04/2003
			
			// Alt RNUTTI 09/10/2001 - UNI_PRO deve trazer informacoes do SD2, e nao do SB1
			//     AADD(xUNI_PRO  ,SB1->B1_UM)
			dbSelectArea("SB1")
			AADD(xCOD_TRIB ,SB1->B1_ORIGEM)
			
			If Ascan(xMEN_TRIB, SB1->B1_ORIGEM)==0
				AADD(xMEN_TRIB ,SB1->B1_ORIGEM)
			Endif
			
			AADD(xMEN_POS  ,SB1->B1_POSIPI)
			
			If SB1->B1_ALIQISS > 0
				AADD(xISS,SB1->B1_ALIQISS)
			Endif
			AADD(xTIPO_PRO ,SB1->B1_TIPO)
			AADD(xLUCRO    ,SB1->B1_PICMRET)
			///*/*/*
			AADD(xCLAS_FIS  ,SB1->B1_POSIPI)
			///*/*/*/*/
			//npElem := ascan(xCLAS_FIS,SB1->B1_POSIPI)
			
			//if npElem == 0
			//	AADD(xCLAS_FIS  ,SB1->B1_POSIPI)
			//endif
			//npElem := ascan(xCLAS_FIS,SB1->B1_POSIPI)
			
			
			DO CASE
				CASE npElem == 1
					_CLASFIS := "A"
				CASE npElem == 2
					_CLASFIS := "B"
				CASE npElem == 3
					_CLASFIS := "C"
				CASE npElem == 4
					_CLASFIS := "D"
				CASE npElem == 5
					_CLASFIS := "E"
				CASE npElem == 6
					_CLASFIS := "F"
			EndCase
			
			
			nPteste := Ascan(xCLFISCAL,_CLASFIS)
			If nPteste == 0
				AADD(xCLFISCAL,_CLASFIS)
			Endif
			AADD(xCOD_FIS ,_CLASFIS)
			
		Next
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pesquisa da Condicao de Pagto               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		dbSelectArea("SE4")                    // Condicao de Pagamento
		dbSetOrder(1)
		dbSeek(xFilial("SE4")+xCOND_PAG)
		xDESC_PAG := SE4->E4_DESCRI
		
		If xTIPO == "D"
			
			dbSelectArea("SA1")                // * Cadastro de Clientes
			dbSetOrder(1)
			dbSeek(xFilial()+xFORNECE)
			xCOD_CLI :=SA1->A1_COD             // Codigo do Cliente
			xLOJ_CLI :=SA1->A1_LOJA            // loja do Cliente
			xNOME_CLI:=SA1->A1_NOME            // Nome
			xEND_CLI :=SA1->A1_END             // Endereco
			xBAIRRO  :=SA1->A1_BAIRRO          // Bairro
			xCEP_CLI :=SA1->A1_CEP             // CEP
			xCOB_CLI :=SA1->A1_ENDCOB          // Endereco de Cobranca
			xREC_CLI :=SA1->A1_ENDENT          // Endereco de Entrega
			xINSENT  :=SA1->A1_INSENT             // Inscricao entrega Entrega
			xCGCENT  :=SA1->A1_CGCENT             // cgc   Entrega
			xRAZENT  :=SA1->A1_RAZENT          // Razao Social de Entrega
			xMUN_CLI :=SA1->A1_MUN             // Municipio
			xEST_CLI :=SA1->A1_EST             // Estado
			xCGC_CLI :=SA1->A1_CGC             // CGC
			xINSC_CLI:=SA1->A1_INSCR           // Inscricao estadual
			xTRAN_CLI:=SA1->A1_TRANSP          // Transportadora
			xTEL_CLI :=SA1->A1_TEL             // Telefone
			xFAX_CLI :=SA1->A1_FAX             // Fax
		Else
			dbSelectArea("SA2")                // * Cadastro de Fornecedores
			dbSetOrder(1)
			dbSeek(xFilial()+xFORNECE+xLOJA)
			xCOD_CLI :=SA2->A2_COD                // Codigo do Cliente
			xLOJ_CLI :=SA2->A2_LOJA            // loja do Cliente
			xNOME_CLI:=SA2->A2_NOME               // Nome
			xEND_CLI :=SA2->A2_END                // Endereco
			xBAIRRO  :=SA2->A2_BAIRRO             // Bairro
			xCEP_CLI :=SA2->A2_CEP                // CEP
			xCOB_CLI :=""                         // Endereco de Cobranca
			xREC_CLI :=""                         // Endereco de Entrega
			xINSENT  :=""                         // Razao Social de Entrega
			xCGCENT  :=""                         // Razao Social de Entrega
			xRAZENT  :=""                         // Razao Social de Entrega
			xMUN_CLI :=SA2->A2_MUN                // Municipio
			xEST_CLI :=SA2->A2_EST                // Estado
			xCGC_CLI :=SA2->A2_CGC                // CGC
			xINSC_CLI:=SA2->A2_INSCR              // Inscricao estadual
			xTRAN_CLI:=SA2->A2_TRANSP             // Transportadora
			xTEL_CLI :=SA2->A2_TEL                // Telefone
			xFAX     :=SA2->A2_FAX                // Fax
			
		EndIf
		
		dbSelectArea("SE1")                   // * Contas a Receber
		dbSetOrder(1)
		xPARC_DUP  :={}                       // Parcela
		xVENC_DUP  :={}                       // Vencimento
		PRIVATE dVENC:=""
		xVALOR_DUP :={}                       // Valor
		
		xDUPLICATAS:=IIF(dbSeek(xFilial()+xSERIE+xNUM_DUPLIC,.T.),.T.,.F.) // Flag p/Impressao de Duplicatas
		
		Do While !eof() .and. SE1->E1_NUM==xNUM_DUPLIC .and. xDUPLICATAS==.T.
			AADD(xPARC_DUP ,SE1->E1_PARCELA)
			//			AADD(xVENC_DUP ,SE1->E1_VENCTO)
			dVENC:=dVENC+  SUBSTR (DTOS(SE1->E1_VENCTO),7,2)+ "/" + SUBSTR (DTOS(SE1->E1_VENCTO),5,2) +"/"+ SUBSTR (DTOS(SE1->E1_VENCTO),1,4)+" "
			AADD(xVALOR_DUP,SE1->E1_VALOR)
			dbSkip()
		EndDo
		
		dbSelectArea("SF4")                   // * Tipos de Entrada e Saida
		dbSetOrder(1)
		dbSeek(xFilial("SF4")+_xTES[1])
		
		xNATUREZA:=SF4->F4_TEXTO     // Natureza da Operacao
		xNOME_TRANSP :=" "           // Nome Transportadora
		xEND_TRANSP  :=" "           // Endereco
		xMUN_TRANSP  :=" "           // Municipio
		xEST_TRANSP  :=" "           // Estado
		xVIA_TRANSP  :=" "           // Via de Transporte
		xCGC_TRANSP  :=" "           // CGC
		xINS_TRANSP  :=" "           // Inscricao Estadual
		xTEL_TRANSP  :=" "           // Fone
		xTPFRETE     :=" "           // Tipo de Frete
		xVOLUME      := 0            // Volume
		xESPECIE     :=" "           // Especie
		xPESO_LIQ    := 0            // Peso Liquido
		xPESO_BRUTO  := 0            // Peso Bruto
		xCOD_MENS    := SF4->F4_FORMULA  // Codigo da Mensagem
		// Exclusao RNUTTI 10/09/2002 - Mensagens Adicionais ja definidas anteriormente
		//xMENSAGEM    :=" "           // Mensagem da Nota
		//xMENSAGE2    :=" "           // Mensagem 2 da Nota
		//xMENSAGE3    :=" "           // Mensagem 3 da Nota
		//xMENSAGE4    :=" "           // Mensagem 4 da Nota
		//xMENSAGE5    :=" "           // Mensagem 5 da Nota
		// Fim das Inclusoes
		
		// xPESO_LIQUID :=" "
		
		Imprime()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Termino da Impressao da Nota Fiscal                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		IncRegua()                    // Termometro de Impressao
		
		nLin:=0
		dbSelectArea("SF1")
		dbSkip()                     // e passa para a proxima Nota Fiscal
		
	EndDo
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                              ³
//³                      FIM DA IMPRESSAO                        ³
//³                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fechamento do Programa da Nota Fiscal                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SF2")
Retindex("SF2")
dbSelectArea("SF1")
Retindex("SF1")
dbSelectArea("SD2")
Retindex("SD2")
dbSelectArea("SD1")
Retindex("SD1")
Set Device To Screen

If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do Programa                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                              ³
//³                   FUNCOES ESPECIFICAS                        ³
//³                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VERIMP   ³ Autor ³   Marcos Simidu       ³ Data ³ 20/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica posicionamento de papel na Impressora             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Nfiscal                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da Funcao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Substituido pelo assistente de conversao do AP5 IDE em 14/05/01 ==> Function VerImp
Static Function VerImp()

nLin:= 0                // Contador de Linhas
nLinIni:=0
If aReturn[5]==2
	
	nOpc       := 1
	#IFNDEF WINDOWS
		cCor       := "B/BG"
	#ENDIF
	Do While .T.
		
		SetPrc(0,0)
		dbCommitAll()
		
		@ nLin ,000 PSAY " "
		@ nLin ,004 PSAY "*"
		@ nLin ,022 PSAY "."
		#IFNDEF WINDOWS
			Set Device to Screen
			DrawAdvWindow(" Formulario ",10,25,14,56)
			SetColor(cCor)
			@ 12,27 Say "Formulario esta posicionado?"
			nOpc:=Menuh({"Sim","Nao","Cancela Impressao"},14,26,"b/w,w+/n,r/w","SNC","",1)
			Set Device to Print
		#ELSE
			IF MsgYesNo("Fomulario esta posicionado ? ")
				nOpc := 1
			ElseIF MsgYesNo("Tenta Novamente ? ")
				nOpc := 2
			Else
				nOpc := 3
			Endif
		#ENDIF
		
		Do Case
			Case nOpc==1
				lContinua:=.T.
				Exit
			Case nOpc==2
				Loop
			Case nOpc==3
				lContinua:=.F.
				Return
		EndCase
	End
Endif

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Funcao       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ IMPDET   ³ Autor ³   Marcos Simidu       ³ Data ³ 20/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao de Linhas de Detalhe da Nota Fiscal              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Nfiscal                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da Funcao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Static Function IMPDET()

IF xTIPO_CLI='X'
	_nTamDet := GetMV("MV_ITEMEXP")
ELSE
	_nTamDet := GetMV("MV_NUMITEN")          // Tamanho da Area de Detalhe
ENDIF

I:=1
J:=1
xB_ICMS_SOL:=0          // Base  do ICMS Solidario
xV_ICMS_SOL:=0          // Valor do ICMS Solidario

For I := 1 to _nTamDet
	
	If I<= Len(xCOD_PRO)
		//DANIEL 14/02/07
		//+----------------------------------------------+
		//|Tratamento de Amarracao Produto x Cliente SA7 |
		//|Incluido para tratar Nf de Exportacao         |
		//+----------------------------------------------+
		
		//	If !ImpProdCli(xCLIENTE,xLOJA,xCOD_PRO[I])
		//+------------------------------------------+
		//|Se nao encontrei o cliente+produto na SA7 |
		//|imprimo normal, caso contrario imprimo    |
		//|codigo+descricao da SA7                   |
		//+------------------------------------------+
		
		@ nLin, 012  PSAY Alltrim(xCOD_PRO[I])
		
		IF xTIPO_CLI='X'
			_Desc_Item := ALLTRIM(Alltrim(xDESC_PRO[I])+" "+xCFOP[I])
			_Cod_NCM   := "NCM:"+(xCLAS_FIS[I])
		ELSE
			_Desc_Item := ALLTRIM( Alltrim(xDESC_PRO[I]) +" "+xCFOP[I])
			_Cod_NCM   := ""
		ENDIF
		
		//Alterado para permitir que a descrição possa ter até 180 caracteres - Werner 20/09/2006
		
		IF xTIPO = 'C'
			
			_Desc_Item:= _Desc_Item+", REF. COMPLEMENTO DA NF "+SC6->C6_NFORI+" SERIE "+SC6->C6_SERIORI
			_Cod_NCM   := ""
			
		ENDIF
		
		_Tam_desc := LEN(_Desc_Item)
		If _Tam_desc < 60 .and. _Cod_NCM = ""
			@ nLin, 021  PSAY alltrim(_Desc_Item)
		Else
			@ nLin, 021  PSAY alltrim(SUBSTR(_Desc_Item,1,64))
			nLin := nLin + 1
			@ nLin, 021  PSAY alltrim(SUBSTR(_Desc_Item,65,60))
			If  len(ALLTRIM(SUBSTR(_Desc_Item,122,60))) > 0
				nLin := nLin + 1
				@ nLin, 021  PSAY alltrim(SUBSTR(_Desc_Item,126,60))
			Endif
			if _Cod_NCM <> ""
				nLin := nLin + 1
				@ nLin, 021  PSAY _Cod_NCM
			endif
		Endif
		
		If mv_par04 == 2                   // Inclusao RNUTTI 19/02/2002 - Inclusao deste IF para que seja impresso apenas quando NF Saida
			If	len(Alltrim(STR(xCAIXAS[I],9))) <= 3
				@ nLin, 085  PSAY ALLTRIM(STR(xCAIXAS[I])) //+" "+ SUBSTR(xUnidade[I],1,2)    // C6_UNSVEN + C6_SEGUM
				@ nLin, 089  PSAY SUBSTR(xUnidade[I],1,2)
				//				@ nLin, 094  PSAY ALLTRIM(STR(xCAIXAS[I])) //+" "+ SUBSTR(xUnidade[I],1,2)    // C6_UNSVEN + C6_SEGUM
				//				@ nLin, 098  PSAY SUBSTR(xUnidade[I],1,2)
				
			Else
				@ nLin, 085  PSAY ALLTRIM(STR(xCAIXAS[I])) + SUBSTR(xUnidade[I],1,2)    // C6_UNSVEN + C6_SEGUM
			Endif
		Endif
		
		//		@ nLin, 093  PSAY xCFOP[I]
		@ nLin, 098  PSAY xCOD_TRIB[I]+xSITTRIB[I]
		@ nLin, 103  PSAY xUNI_PRO[I]
		
		// Alteracoes RNUTTI 06/08/2002 - Complentos C-Preco I-ICMS P-IPI
		//Alteracao Ricardo Baldoni 15/05/2003 - Deve fazer excecao apenas para I-ICMS e P -IPI (Tipo C Nao eh excecao
		If xTIPO#'I' .and. xTIPO#'P'
			@ nLin, 105  PSAY xQTD_PRO[I]               Picture"@E 999,999.999"
			@ nLin, 115  PSAY xPRE_UNI[I]               Picture"@E 999,999.9999"
			@ nLin, 129  PSAY xVAL_MERC[I]              Picture"@E 99,999,999.99"
		Endif
		// Fim Alteracoes
		//Alterado por Gustavo a impressão do campo aliq.Icm quando nota tipo I Data : 30/11/02
		if xTipo#'I'
			@ nLin, 148  PSAY xICM_PROD[I]              Picture"99"
		Endif
		J:=J+1
		//		xVOLUME := xVOLUME + xQTD_PRO[I]
	Endif
	nLin := nLin + 1
Next

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Funcao       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMPPRODCLIºAutor  ³DANIEL              º Data ³  02/14/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime o codigo do produto e descricao do cliente          º±±
±±º          ³Busca na Tabela SA7 - Amarracao Produto x Cliente           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºPARAMETROS³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º_cCli     ³Cliente                                                     º±±
±±º_cLoj     ³Loja                                                        º±±
±±º_cProd    ³Produto                                                     º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRETORNO   ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ImpProdCli(_cCli,_cLoj,_cProd)
//+---------------------------------+
//|Declaracao de variaveis          |
//+---------------------------------+
Local _aArea:=GetArea()
Local _lRet	:=.F.

DbSelectArea("SA7")
dbSetOrder(1)//A7_FILIAL+A7_CLIENTE+A7_LOJA+A7_PRODUTO

If DbSeek(xFilial("SA7")+_cCli+_cLoj+_cProd,.T.)
	
	_lRet:=.T.
	
	@ nLin, 012  PSAY SA7->A7_CODCLI
	_Desc_Item := SA7->A7_DESCCLI
	
Else
	_lRet:=.F.
EndIf

RestArea(_aArea)
Return(_lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CLASFIS  ³ Autor ³   Marcos Simidu       ³ Data ³ 16/11/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao de Array com as Classificacoes Fiscais       *   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Nfiscal                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CLASFIS()
@ nLin,002 PSAY "Classificacao Fiscal"
nLin := nLin + 1
For nCont := 1 to Len(xCLFISCAL) .And. nCont <= 12
	nCol := If(Mod(nCont,2) != 0, 06, 33)
	@ nLin, nCol   PSAY xCLFISCAL[nCont] + "-"
	@ nLin, nCol+ 05 PSAY Transform(xCLAS_FIS[nCont],"@r 99.99.99.99.99")
	nLin := nLin + If(Mod(nCont,2) != 0, 0, 1)
Next
Return



STATIC FUNCTION COZIND()  // INFORMACOES DE COZINHA INDUSTRIAL
@ nLin, nCol PSAY "Local de Entrega Conf. Port. CAT 37/02:"
ORICAB()
nLin++
@ nLin, nCol PSAY SUBSTR(xRAZENT,1,40)
ORICAB()
nLin++
@ nLin, nCol PSAY Alltrim(xREC_CLI) + " - " + xBAIRROE   // Endereco+Bairro Entrega
ORICAB()
nLin++
@ nLin, nCol PSAY Alltrim(xMUNE) + " - " + xESTE         // Municipio+Estado Entrega
ORICAB()
nLin++
@ nLin, nCol PSAY Transform(SA1->A1_CEPE,"@R 99999-99")  // CEP Entrega
ORICAB()
nLin++
RETURN

STATIC FUNCTION CABECL7()  //INICIO DA FUNCAO DE IMPRESSAO DA LINHA 7 NO CABEC DA NF - RAFAEL H. SILVEIRA EM 07/03/2006
@ 7, 055 PSAY xNATUREZA               // Texto da Natureza de Operacao
@ 7, 085 PSAY _cCFOPs   // Codigo da Natureza de Operacao

RETURN // FIM DA FUNCAO DE IMPRESSAO DA LINHA 7 NO CABEC DA NF - RAFAEL H. SILVEIRA EM 07/03/2006

STATIC FUNCTION CABECL11() //INICIO DA FUNCAO DE IMPRESSAO DA LINHA 11 NO CABEC DA NF - RAFAEL H. SILVEIRA EM 07/03/2006
@ 11, 055 PSAY xCod_Cli +"  "+xLoj_cli + "  "+ alltrim(xNOME_CLI) //Nome do Cliente
If xIMPENT == "S"  // Inclusao RNUTTI 28/08/2002 - Somente inclusao deste "IF" - Cozinha Industrial
	@ 11, 114 PSAY xCGCENT Picture"@R 99.999.999/9999-99"
Else
	If !EMPTY(xCGC_CLI)                   // Se o C.G.C. do Cli/Forn nao for Vazio
		@ 11, 114 PSAY xCGC_CLI Picture"@R 99.999.999/9999-99"
	Else
		@ 11, 114 PSAY " "                              // Caso seja vazio
	Endif
Endif
@ 11, 140 PSAY xEMISSAO                                 // Data da Emissao do Documento
RETURN //FIM DA FUNCAO DE IMPRESSAO DA LINHA 11 NO CABEC DA NF - RAFAEL H. SILVEIRA EM 07/03/2006

STATIC FUNCTION CABECL13() //INICIO DA FUNCAO DE IMPRESSAO DA LINHA 13 NO CABEC DA NF - RAFAEL H. SILVEIRA EM 07/03/2006

@ 13, 012 PSAY MV_PAR07//DANIEL 05/03/07 IMPRESSAO DAS OBSERVACOES DA NF

@ 13, 055 PSAY alltrim(xEND_CLI)                                 // Endereco

IF !EMPTY(xBAIRRO)
	@ 13, 104 PSAY alltrim(xBAIRRO)                                  // Bairro
ELSE
	@ 13, 104 PSAY SPACE(10)
ENDIF

@ 13, 124 PSAY xCEP_CLI Picture"@R 99999-999"           // CEP
@ 13, 140 PSAY dDataBase                                // Data da Saida
RETURN //FIM DA FUNCAO DE IMPRESSAO DA LINHA 13 NO CABEC DA NF - RAFAEL H. SILVEIRA EM 07/03/2006

STATIC FUNCTION CABECL15() //INICIO DA FUNCAO DE IMPRESSAO DA LINHA 15 NO CABEC DA NF - RAFAEL H. SILVEIRA EM 07/03/2006

@ 15, 012 PSAY MV_PAR08//DANIEL 05/03/07 IMPRESSAO DAS OBSERVACOES DA NF

@ 15, 055 PSAY alltrim(xMUN_CLI)                               // Municipio
@ 15, 090 PSAY xTEL_CLI                               // Telefone/FAX
@ 15, 108 PSAY xEST_CLI                               // U.F.
@ 15, 114 PSAY xINSC_CLI                              // Insc. Estadual
RETURN //FIM DA FUNCAO DE IMPRESSAO DA LINHA 11 NO CABEC DA NF - RAFAEL H. SILVEIRA EM 07/03/2006

STATIC FUNCTION ORICAB() //INICIO DA FUNCAO DE ORIENTACAO DA IMPRESSAO DO CABECALHO CONFORME VARIACAO DA OBSERVACAO - RAFAEL H. SILVEIRA EM 07/03/2006
IF nLin = 7
	CABECL7()
ENDIF
IF nLin=11
	CABECL11()
endif
IF nLin=13
	CABECL13()
ENDIF
IF nLin = 15
	CABECL15()
ENDIF//INICIO DA FUNCAO DE ORIENTACAO DA IMPRESSAO DO CABECALHO CONFORME VARIACAO DA OBSERVACAO - RAFAEL H. SILVEIRA EM 07/03/2006



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MENSOBS  ³ Autor ³   Marcos Simidu       ³ Data ³ 20/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao Mensagem no Campo Observacao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Nfiscal                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MENSOBS() //INICIO DA FUNCAO DE IMPRESSAO DA OBSERVACAO (SC5) NO CABEC DA NF - RAFAEL H. SILVEIRA EM 07/03/2006

//SE HOUVER MENSAGEM NO SC5, IMPRIME AS MENSAGENS NAS LINHAS CORRENTES. CASO NAO, IMPRIME ESPACOS EM BRANCO
//CABECALHO ESTA PROJETADO PARA DIRIGIR AS LINHAS CONFORME A VARIACAO DAS INFORMACOES DE OBSERVACAO APONTADAS NOS CADASTROS E
//NOS CAMPOS DE OBSERVACAO DO SC5.

nTamObs:=40

IF !EMPTY(xMENSAGEM)
	@ nLin, nCol PSAY alltrim(UPPER(SUBSTR(xMENSAGEM,1,nTamObs)))
ELSE
	@ nLin, nCol PSAY SPACE(40)
ENDIF
ORICAB()
nlin:=nlin+1

IF !EMPTY(xMENSAGE2)
	@ nLin, nCol PSAY alltrim(UPPER(SUBSTR(xMENSAGE2,1,nTamObs)))
ELSE
	@ nLin, nCol PSAY SPACE(40)
ENDIF
ORICAB()
nlin:=nlin+1

IF !EMPTY(xMENSAGE3)
	@ nLin, nCol PSAY alltrim(UPPER(SUBSTR(xMENSAGE3,1,nTamObs)))
ELSE
	@ nLin, nCol PSAY SPACE(40)
ENDIF
ORICAB()
nlin:=nlin+1

IF !EMPTY(xMENSAGE4)
	@ nLin, nCol PSAY alltrim(UPPER(SUBSTR(xMENSAGE4,1,nTamObs)))
ELSE
	@ nLin, nCol PSAY SPACE(40)
ENDIF
ORICAB()
nlin:=nlin+1

IF !EMPTY(xMENSAGE5)
	@ nLin, nCol PSAY alltrim(UPPER(SUBSTR(xMENSAGE5,1,nTamObs)))
ELSE
	@ nLin, nCol PSAY space(40)
ENDIF
ORICAB()
nlin:=nlin+1

RETURN //FIM DA FUNCAO DE IMPRESSAO DA OBSERVACAO (SC5) NO CABEC DA NF - RAFAEL H. SILVEIRA EM 07/03/2006


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ IMPMENP  ³ Autor ³   Marcos Simidu       ³ Data ³ 20/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao Mensagem Padrao da Nota Fiscal                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Nfiscal                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function IMPMENP() //INICIO DA FUNCAO DE IMPRESSAO DOS TEXTOS LEGAIS E FORMULAS NO CABEC DA NF - RAFAEL H. SILVEIRA EM 07/03/2006
//SE HOUVER TEXTOS E FORMULAS, IMPRIME AS MENSAGENS NAS LINHAS CORRENTES. CASO NAO, IMPRIME ESPACOS EM BRANCO
//CABECALHO ESTA PROJETADO PARA DIRIGIR AS LINHAS CONFORME A VARIACAO DAS INFORMACOES DE OBSERVACAO APONTADAS NOS CADASTROS E
//NOS CAMPOS DE OBSERVACAO DO SC5.

// Inclusao RNUTTI 23/07/2002 - Mensagens de Situacao Tributaria
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tabela A                                                                           ³
//³  0 - Nacional                                                                      ³
//³  1 - Estrangeira - Importacao Direta                                               ³
//³  2 - Estrangeira - Adquirida no Mercado Interno                                    ³
//³                                                                                    ³
//³ Tabela B                                                                           ³
//³  00 - Tributada Integralmente                                                      ³
//³  10 - Tributada e com cobranca do ICMS por Substituicao Tributaria                 ³
//³  20 - Com reducao de base de calculo                                               ³
//³  30 - Isenta ou nao tributada e com cobranca do ICMS por Substituicao Tributaria   ³
//³  40 - Isenta                                                                       ³
//³  41 - Nao Tributada                                                                ³
//³  50 - Suspensao                                                                    ³
//³  51 - Diferimento                                                                  ³
//³  60 - ICMS cobrado anteriormente por Substituicao Tributaria                       ³
//³  70 - Com reducao de base de Calculo e cobranca do ICMS por Substituicao Tributaria³
//³  90 - Outras                                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Cria matriz dos TES. Se forem diferentes, senao entra apenas 1, pois nao repete
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria matriz dos TES.                                                               ³
//³  -  Se houver mais de 1, carrega apenas 1 vez a Sit Trib do mesmo TES              ³
//³  -  Se houver apenas 1, carrega apenas uma Sit Trib                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_aTES_ST := {}
For _nx := 1 to Len(_xTES)
	If aScan (_aTES_ST , "0"+ xSITTRIB[_nx] ) == 0
		AADD (_aTES_ST , "0"+ xSITTRIB[_nx] )
	Endif
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Le a matriz carregada acima e imprime as Sit Trib de acordo com os TES             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For _nx := 1 to Len (_aTES_ST)
	@ nLin, nCol PSAY SUBSTR((alltrim(Tabela("ST",_aTES_ST[_nx]))),1,40)
	ORICAB()
	IF !EMPTY(SUBSTR((alltrim(Tabela("ST",_aTES_ST[_nx]))),41,20)) // SE A MENSAGEM EXCEDER LIMITE DE 40 COLUNAS, AVANCA LINHA E CONCLUI.
		nLin++
		@ nLin, nCol PSAY SUBSTR((alltrim(Tabela("ST",_aTES_ST[_nx]))),41,20)
		ORICAB()
	ENDIF
	nLin++
Next

// Cria matriz das Formulas. Se forem diferentes, senao entra apenas 1, pois nao repete
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria matriz das Formulas.                                                               ³
//³  -  Se houver mais de 1, carrega apenas
//1 vez a Sit Trib do mesmo TES              ³
//³  -  Se houver apenas 1, carrega apenas uma Sit Trib                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_aFORMULA := {}

IF xEST_CLI <> "SP" .AND. xEST_CLI <> "EX"
	IF xEST_CLI =  "AM"
		xFORMULA[1]:="104"
	ELSE
		xFORMULA[1]:="102"
	ENDIF
ENDIF


For _nx := 1 to Len(_xTES)
	If aScan (_aFORMULA , xFORMULA[_nx] ) == 0
		AADD (_aFORMULA , xFORMULA[_nx] )
	Endif
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Le a matriz carregada acima e imprime as Formulas (SM4) de acordo com os TES       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CONTA:=1


For _nx := 1 to Len(_xTES)
	IF _xTES[_nx] <> '630' .AND. _xTES[_nx] <>  '597'
		
		
		
		For _nx := 1 to Len (_aFORMULA)
			
			IF CONTA<>1
				Return
			ENDIF
			
			IF !EMPTY(substr((alltrim(Formula(_aFORMULA[_nx]))),1,40))
				@ nLin, nCol PSAY substr((alltrim(Formula(_aFORMULA[_nx]))),1,40)
			ELSE
				@ nLin, nCol PSAY SPACE(40)
			ENDIF
			
			ORICAB()
			IF !EMPTY(substr((alltrim(Formula(_aFORMULA[_nx]))),41,20)) //SE A FORMULA EXCEDER LIMITE DE 40 COLUNAS, AVANCA LINHA E CONCLUI.
				nLin++
				@ nLin, nCol PSAY substr((alltrim(Formula(_aFORMULA[_nx]))),41,20)
				ORICAB()
			ENDIF
			nLin := nLin + 1
			CONTA:=2
		Next
		Return
	ENDIF
	
Next

// Fim das Inclusoes

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DUPLIC   ³ Autor ³   Marcos Simidu       ³ Data ³ 20/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Parcelamento das Duplicacatas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Nfiscal                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da Funcao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Substituido pelo assistente de conversao do AP5 IDE em 14/05/01 ==> Function DUPLIC
Static Function DUPLIC()
nCol := 7
nAjuste := 0
For BB:= 1 to Len(xVALOR_DUP)
	If xDUPLICATAS==.T. .and. BB<=Len(xVALOR_DUP)
		@ nLin, nCol + nAjuste      PSAY xNUM_DUPLIC + " " + xPARC_DUP[BB]
		@ nLin, nCol + 16 + nAjuste      PSAY xVENC_DUP[BB]
		@ nLin, nCol + 31 + nAjuste PSAY xVALOR_DUP[BB] Picture("@E 9,999,999.99")
		nAjuste := nAjuste + 50
	Endif
Next

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Funcao       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LI       ³ Autor ³   Marcos Simidu       ³ Data ³ 20/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pula 1 linha                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico RDMAKE                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da Funcao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ IMPRIME  ³ Autor ³   Marcos Simidu       ³ Data ³ 20/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime a Nota Fiscal de Entrada e de Saida                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico RDMAKE                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 14/05/01 ==> Function Imprime

Static Function Imprime()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                              ³
//³              IMPRESSAO DA N.F. DA Nfiscal                    ³
//³                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do Cabecalho da N.F.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 00,000 psay Chr(15)+Chr(27)+Chr(48)+Chr(27)+chr(27)+"C"+chr(63)  // compactacao da NF --Daniel

//IF PNOTA=1
nLin:=1
//ELSE
//nLin:=PROW()+6
//ENDIF

PNOTA:=2

nCol = 12

IF mv_par04 == 2
	
	IF xTIPO = 'C'
		_CTEXTO1:="Venc(s):" + " Vide NF Original "
	ELSE
		_CTEXTO1:="Venc(s):" + dVENC
	ENDIF
	
ELSE
	_CTEXTO1:= SPACE(40)
ENDIF

@ nLin,nCol PSAY SUBSTR(_CTEXTO1,1,40)

@ nLin,141 PSAY xNUM_NF
nLin++

IF xTIPO = "D"
	_CTEXTO2:="NF. Original N.o "+xNFORI
ELSE
	If mv_par04 == 2
		_CTEXTO2:="Pedido:"+ xPed_Vend[1]+' '+xRota
	ELSE
		
		If mv_par04 == 1 .and. xDESCSF1 > 0
			_CTEXTO2:= "DESCONTO:  "+Transform(xDESCSF1,"@E@Z 999,999,999.99")   // Desconto total da NF
		ELSE
			_CTEXTO2:= SPACE(40)
		ENDIF
		
	Endif
ENDIF

@ nLin,nCol PSAY SUBSTR(_CTEXTO2,1,40)

If mv_par04 == 1
	@ nLin, 125 PSAY "X"
Else
	@ nLin, 115 PSAY "XX"
Endif

nLin++

IF mv_par04 == 2
	@ nLin,nCol  PSAY "Fone Cobranca "+GetMV("MV_FONECOB")
	nLin++
ENDIF


_cCFOPs := ""

For _nx := 1 to Len(xCF)
	_cCFOPs := IIF( AT( Transform(xCF[_nx],"@R 9999"), _cCFOPs )==0 , _cCFOPs+" "+Transform(xCF[_nx],"@R 9999") , _cCFOPs )
Next

If len(_cCFOPs) > 5
	
	xNATUREZA1 := " "
	xNATUREZA2 := " "
	dbSelectArea("SF4") // * Tipos de Entrada e Saida
	dbSetOrder(2)       // Indice CFOP
	If dbSeek(xFilial("SF4")+_cCFOPs)
		xNATUREZA := F4_TEXTO
	Else
		_cCFOP1 := SUBSTR(_cCFOPs,2,4)
		_cCFOP2 := SUBSTR(_cCFOPs,7,4)
		
		dbSeek(xFilial("SF4")+_cCFOP1) // posiciona no 1o.CFOP
		xNATUREZA1 := SF4->(POSICIONE("SF4",3,XFILIAL("SF4")+_cCFOP1,"F4_TEXTO"))
		
		dbSeek(xFilial("SF4")+_cCFOP2) // posiciona no 2o.CFOP
		xNATUREZA2 := SF4->(POSICIONE("SF4",3,XFILIAL("SF4")+_cCFOP2,"F4_TEXTO"))
		xNATUREZA  := TRIM(xNATUREZA1)+"/"+TRIM(xNATUREZA2)
		
	Endif
Endif


ImpMenp()
If xIMPENT == "S"
	COZIND()
Endif
MensObs()






IF nLin <=7
	CABECL7()
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao dos Dados do Cliente      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF nLin<=11
	CABECL11()
ENDIF

IF nLin<=13
	CABECL13()
ENDIF

IF nLin<=15
	CABECL15()
ENDIF



nLin := 20

ImpDet()                 // Detalhe da NF

IF xTIPO_CLI='X'
	@ nLin, 021  PSAY "Container: "+ALLTRIM(xCONTAIN)
	@ nLin+2, 021  PSAY "Lacre: "+ALLTRIM(xLACRE1)+" Lacre SIF: "+ALLTRIM(xLACRE2)
	@ nLin+4, 021  PSAY "Temperatura: "+ALLTRIM(xTEMPERA)+" ºC"
	@ nLin+6, 021 PSAY "Data de producao: "+ALLTRIM(xDTPROD)
	
	DBSELECTAREA("SM2")
	DBSETORDER(1)
	DBSEEK(DTOS(xEMISSAO))
	_nCOTAC  := SM2->M2_MOEDA2
	
	@ nLin+8, 021 PSAY "PTAX: R$ "+STR( _nCOTAC,6,4)
	
	DBSELECTAREA("EE7")
	DBSETORDER(10)                 //DANIE 19/03/07 ALTERADO INDICE FILIAL+CLIENTE+PEDIDO
	dbSeek('  '+xCLIENTE+cPedAtu) // ISSO SE DEVE AO FATO DE O EE7 ESTAR COMPARTILHADO
	
	xINVOICE:= EE7_PEDIDO
	
	@ nLin+10, 021 PSAY "Proc. Export.: "+ALLTRIM(xINVOICE)
	
	
ENDIF






//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calculo dos Impostos                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

@ 47, 009  PSAY xBASE_ICMS  Picture "@E@Z 999,999,999.99"  // Base do ICMS
@ 47, 022  PSAY xVALOR_ICMS Picture "@E@Z 999,999,999.99"  // Valor do ICMS
@ 47, 035  PSAY xBSICMRET   Picture "@E@Z 999,999,999.99"  // Base ICMS Ret.
@ 47, 048  PSAY xICMS_RET   Picture "@E@Z 999,999,999.99"  // Valor  ICMS Ret.


//INICIO DA CONDICAO PARA TRATAR FRETE DE EXPORTACAO FOB - RAFAEL H. SILVEIRA EM 22/02/2006 - VER TRATAMENTO EM MTASF2.PRW

IF xTIPO_CLI='X' .OR. xTPFRETE='C'
	xTOT_FAT:=xVALOR_MERC+xFRETE
ENDIF

//FIM DA CONDICAO PARA TRATAR FRETE DE EXPORTACAO FOB - RAFAEL H. SILVEIRA EM 22/02/2006  - VER TRATAMENTO EM MTASF2.PRW

If xTIPO#'C' .and. xTIPO#'I' .and. xTIPO#'P'
	//	@ 48, 076  PSAY xVALOR_MERC Picture "@E@Z 999,999,999.99"  // Valor Tot. Prod.
	@ 47, 076  PSAY xVALOR_MERC Picture "@E@Z 999,999,999.99"  // Valor Tot. Prod.
Endif

IF !EMPTY(xFRETE)
	@ 49, 009  PSAY xFRETE Picture "@E@Z 999,999,999.99"  // Valor Tot. Prod.
ENDIF
IF !EMPTY(xSEGURO)
	@ 49, 022  PSAY xSEGURO Picture "@E@Z 999,999,999.99"  // Valor Seguro
ELSE
	@ 49, 022  PSAY SPACE(2)
ENDIF
IF !EMPTY(xVALOR_IPI)
	@ 49, 061  PSAY xVALOR_IPI Picture "@E@Z 999,999,999.99"  // Valor do IPI
ELSE
	@ 49, 061  PSAY SPACE(2)
ENDIF

If xTIPO#'I' .and. xTIPO#'P'
	@ 49, 076  PSAY xTOT_FAT    Picture "@E@Z 999,999,999.99"  // Valor Total NF
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao Dados da Transportadora  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF !EMPTY(xNOME_TRANSP)
	@ 53, 011  PSAY alltrim(xNOME_TRANSP)                       // Nome da Transport.
ELSE
	@ 53, 011  PSAY SPACE(15)
ENDIF

If xTPFRETE=='C'                                   // Frete por conta do
	@ 53, 060 PSAY "1"                              // Emitente (1)
Else                                               //     ou
	@ 53, 060 PSAY "2"                              // Destinatario (2)
Endif

@ 53, 066 PSAY SF2->F2_PLACA                        // Placa do Veiculo

If !EMPTY(xCGC_TRANSP)                              // Se C.G.C. Transportador nao for Vazio
	@ 53, 084 PSAY xCGC_TRANSP Picture"@R 99.999.999/9999-99"
Else
	@ 53, 084 PSAY " "                               // Caso seja vazio
Endif

@ 55, 011 PSAY alltrim(xEND_TRANSP)                          // Endereco Transp.
@ 55, 055 PSAY xMUN_TRANSP                          // Municipio
@ 55, 079 PSAY xEST_TRANSP                          // U.F.
@ 55, 084 PSAY xINS_TRANSP
@ 57, 010 PSAY xVOLUME Picture"@E@Z 999,999"                 // Quant. Caixas
@ 57, 026 PSAY "** VOLUMES **" //xESPECIE Picture"@!"  // Especie
@ 57, 072 PSAY xPESO_BRUTO     Picture"@E@Z 999,999.99"      // Res para Peso Bruto
@ 57, 083 PSAY xPESO_LIQUID    Picture"@E@Z 999,999.99"      // Res para Peso Liquido
@ 63, 138 PSAY xNUM_NF
@ 68,0 PSAY SPACE(10)

SETPRC(0,0)


Return .t.
