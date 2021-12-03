#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"

#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

/*/{Protheus.doc} User Function AD0012-DIA
	Relatorio de geracao de realizado de vendas das regioes
	@type  Function
	@author HERALDO C. HEBLING
	@since 12/12/02
	@version 1
	@history Chamado 049140 - DANIEL       - 22/05/2006 - CRIADO TOTALIZADOR POR GRUPOS
	@history Chamado 004655 -              - 22/05/2006 - ADICIONADO MAIS UM TOTALIZADOR POR GRUPO
	@history Chamado 004655 - MAURICIO HC  - 20/07/2009 - CONSYS - FONTE ORIGINAL AD0012, ALTERADO PARA CALCULO DE MEDIA DIARIA
	@history Chamado 049140 - Everson      - 13/05/2019 - REL METRAS
	@history Ticket  TI     - FWNM         - 23/05/2019 - RECLAMACAO USUARIO VJCP15 DE QUE O RELATORIO NAO SAI DO LUGAR
	@history Ticket  14094  - Everson      - 20/05/2021 - Adiconados mais 8 grupos de produtos
	@history Ticket  14631  - Everson      - 27/05/2021 - Adiconado totalizador do grupo 6 no txt
	@history Ticket  15291  - Abel Babini  - 08/06/2021 - Correção de Error.log com a filial sem aspas.
	@history Ticket  64069  - Leonardo P. Monteiro  - 23/11/2021 - Inclusão de alerta referente a problemas na geração do relatório na Cloud.
	@history Ticket  64069  - Leonardo P. Monteiro  - 01/12/2021 - Inclusão das colunas de DSR, valores sem DSR e mudança de orientação na impressão do relatório. Nova compilação em produção.
	@history Ticket  64069  - Leonardo P. Monteiro  - 01/12/2021 - Atualizações pontuais.
	
	/*/
User Function ADVEN106R // U_ADVEN106R()

	SetPrvt("AORD,TAMANHO,LIMITE,NOMEPROG,MV_TABPR,NTIPO")
	SetPrvt("ARETURN,NLASTKEY,NLIN,NITEM,LCONTINUA,M_PAG")
	SetPrvt("IMPRIME,CPERG,CSTRING,TITULO,CDESC1,CDESC2")
	SetPrvt("CDESC3,NOMEREL,CABEC1,CABEC2,CABEC3,CABEC5")
	SetPrvt("CABEC6,CABEC7,ATRASO,POSICA,CVEND,ASTRU")
	SetPrvt("_CNOMTRB,CINDEX,_TOTSAL,_TOTDEV,_CLIENTE,_NOME")
	SetPrvt("_LOJA,_REGVEND,_cVEND,_PREFIXO,CABEC4,")

	Private _prime 		:= 1
	Private _nVenders 	:= 0
	Private _aGrupos	:= {}
	Private _aVendedor	:= {}
	Private cPerg 		:= PADR("AD012B",10," ")
	Private aHelpPor 	:= {}
	Private aHelpSpa 	:= {}
	Private aHelpEng 	:= {}
	Private _Eof  		:= CHR(13)+CHR(10)
	PRIVATE _cFilial 	:= ""
	PRIVATE _lVnd		:= .F.
	Private oTabSZA		:= THashMap():New()
	Private _nXi		:= 0
	Private _nI			:= 0
	Private _nVenders	:= 0
	Private nCol04	:= 093
	Private nCol05	:= 106
	Private nCol06	:= 119
	Private nCol07	:= 130
	Private nCol08	:= 145
	Private nCol09	:= 157
	Private nCol10	:= 168
	Private nCol11	:= 182
	Private nCol12	:= 196
	Private nCol13	:= 211

	//MsgAlert("Erro no ambiente Cloud, tente mais tarde!", "..:: Erro ::..")

	//return .f.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de geracao de realizado de vendas das regioes')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros - AD0012                        ³
	//³ mv_par01             // Periodo De                                   ³
	//³ mv_par02             // Periodo Ate                                  ³
	//³ mv_par03             // Vendedor de                                  ³
	//³ mv_par04             // Vendedor ate                                 ³
	//³ mv_par05             // Ordem do relatorio (Supervisor/Regiao)       ³
	//³ mv_par06             // Supervisor de                                ³
	//³ mv_par07             // Supervisor ate                               ³
	//³ mv_par08             // Regiao de                                    ³
	//³ mv_par09             // Regiao ate                                   ³
	//³ mv_par10             // Classe de Comissao de                        ³ Qual classe da tabela de comissao será utilizada
	//³ mv_par11             // Classe de Comissao ate                       ³
	//³ mv_par12             // Demonstrativo de Vendas por Vendedor         ³
	//³ mv_par13             // Demonstrativo de Vendas por Grupo de Produto ³
	//³ mv_par14             // Demonstrativo de Vendas Vendedor x Produto   ³
	//³ mv_par15             // 1=Analitico/ 2=Sintetico                     ³
	//³ mv_par16             // 1=Arquivo/ 2=Relatorio                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aOrd             	:= {}
	tamanho          	:= "G"
	limite           	:= 132
	nomeprog         	:= "ADVEN106R"
	mv_tabpr         	:= ""
	nTipo            	:= 18
	aReturn 			:= { "Zebrado", 1,"Administracao", 2, 2, 1, "",0 }
	
	nLastKey         	:= 0
	nlin             	:= 80
	nItem            	:= 1
	lContinua        	:= .T.
	
	m_pag	   			:= 01
	imprime    			:= .T.
	_cSupVends			:=""
	_cCodVen			:=""
	_bFlagVend			:=.T.

	VerificaUser()		// Faz a verificacao do usuario - Heraldo 01/12/03
	
	//_lVnd := .T.  //somente teste

	//se nao for vendedor abro a perguntas de grupos de produtos
	If !_lVnd

		Pergunte(cPerg,.T.)

		_cNome1:=mv_par01
		_PERG1:=mv_par02+" "+mv_par03
		
		_cNome2:=mv_par04
		_PERG2:=mv_par05+" "+mv_par06
		
		_cNome3:=mv_par07
		_PERG3:=mv_par08+" "+mv_par09
		
		_cNome4:=mv_par10
		_PERG4:=mv_par11+" "+mv_par12
		
		_cNome5:=mv_par13                 //Mauricio
		_PERG5:=mv_par14+" "+mv_par15     //Mauricio
		
		_cNome6:=mv_par17
		_PERG6:=mv_par18+" "+mv_par19
		
		//Everson - 19/05/2021. Chamado 14094.
		_cNome7 :=mv_par20
		_PERG7 :=mv_par21+" "+mv_par22
		
		_cNome8 :=mv_par23
		_PERG8 :=mv_par24+" "+mv_par25
		
		_cNome9 :=mv_par26
		_PERG9 :=mv_par27+" "+mv_par28
		
		_cNome10:=mv_par29
		_PERG10:=mv_par30+" "+mv_par31
		
		_cNome11:=mv_par32
		_PERG11:=mv_par33+" "+mv_par34
		
		_cNome12:=mv_par35
		_PERG12:=mv_par36+" "+mv_par37
		
		_cNome13:=mv_par38
		_PERG13:=mv_par39+" "+mv_par40
		
		_cNome14:=mv_par41
		_PERG14:=mv_par42+" "+mv_par43
		//

		_cFilial:=Alltrim(mv_par16)
		
		_atualizaSX1()		                &&atualiza o SX1 dos demais usuarios.

	ELSE
		DBSELECTAREA("SX1")
		DBSEEK(cPerg+"01",.T.)
		_cNome1:=X1_CNT01
		DBSEEK(cPerg+"02",.T.)
		_PERG1:=X1_CNT01
		DBSEEK(cPerg+"03",.T.)
		_PERG1+=X1_CNT01
		DBSEEK(cPerg+"04",.T.)
		_cNome2:=X1_CNT01
		DBSEEK(cPerg+"05",.T.)
		_PERG2:=X1_CNT01
		DBSEEK(cPerg+"06",.T.)
		_PERG2+=X1_CNT01
		DBSEEK(cPerg+"07",.T.)
		_cNome3:=X1_CNT01
		DBSEEK(cPerg+"08",.T.)
		_PERG3:=X1_CNT01
		DBSEEK(cPerg+"09",.T.)
		_PERG3+=X1_CNT01
		DBSEEK(cPerg+"10",.T.)
		_cNome4:=X1_CNT01
		DBSEEK(cPerg+"11",.T.)
		_PERG4:=X1_CNT01
		DBSEEK(cPerg+"12",.T.)
		_PERG4+=X1_CNT01
		DBSEEK(cPerg+"13",.T.)
		_cNome5:=X1_CNT01
		DBSEEK(cPerg+"14",.T.)
		_PERG5:=X1_CNT01
		DBSEEK(cPerg+"15",.T.)
		_PERG5+=X1_CNT01
		DBSEEK(cPerg+"17",.T.)
		_cNome6:=X1_CNT01
		DBSEEK(cPerg+"18",.T.)
		_PERG6:=X1_CNT01
		DBSEEK(cPerg+"19",.T.)
		_PERG6+=X1_CNT01	
		
		DBSEEK(cPerg+"16",.T.)
		_cFilial:=X1_CNT01

		//Everson - 19/05/2021. Chamado 14094.
		DBSEEK(cPerg+"20",.T.)
		_cNome7:=X1_CNT01
		DBSEEK(cPerg+"21",.T.)
		_PERG7:=X1_CNT01
		DBSEEK(cPerg+"22",.T.)
		_PERG7+=X1_CNT01

		DBSEEK(cPerg+"23",.T.)
		_cNome8:=X1_CNT01
		DBSEEK(cPerg+"24",.T.)
		_PERG8:=X1_CNT01
		DBSEEK(cPerg+"25",.T.)
		_PERG8+=X1_CNT01

		DBSEEK(cPerg+"26",.T.)
		_cNome9:=X1_CNT01
		DBSEEK(cPerg+"27",.T.)
		_PERG9:=X1_CNT01
		DBSEEK(cPerg+"28",.T.)
		_PERG9+=X1_CNT01

		DBSEEK(cPerg+"29",.T.)
		_cNome10:=X1_CNT01
		DBSEEK(cPerg+"30",.T.)
		_PERG10:=X1_CNT01
		DBSEEK(cPerg+"31",.T.)
		_PERG10+=X1_CNT01

		DBSEEK(cPerg+"32",.T.)
		_cNome11:=X1_CNT01
		DBSEEK(cPerg+"33",.T.)
		_PERG11:=X1_CNT01
		DBSEEK(cPerg+"34",.T.)
		_PERG11+=X1_CNT01

		DBSEEK(cPerg+"35",.T.)
		_cNome12:=X1_CNT01
		DBSEEK(cPerg+"36",.T.)
		_PERG12:=X1_CNT01
		DBSEEK(cPerg+"37",.T.)
		_PERG12+=X1_CNT01

		DBSEEK(cPerg+"38",.T.)
		_cNome13:=X1_CNT01
		DBSEEK(cPerg+"39",.T.)
		_PERG13:=X1_CNT01
		DBSEEK(cPerg+"40",.T.)
		_PERG13+=X1_CNT01

		DBSEEK(cPerg+"41",.T.)
		_cNome14:=X1_CNT01
		DBSEEK(cPerg+"42",.T.)
		_PERG14:=X1_CNT01
		DBSEEK(cPerg+"43",.T.)
		_PERG14+=X1_CNT01
		//

	EndIf
	
	//---------------------------------------------------------
	//  mv_par01			   	Nome do Primeiro Grupo
	//  mv_par02            	Sub Grupos do Primeiro Grupo
	//  mv_par03				Nome do Segundo Grupo
	//	mv_par04				Sub Grupos do segundo Grupo
	//  mv_par05				Nome do terceiro Grupo
	//  mv_par06				Sub Grupos do terceiro Grupo
	//  mv_par07				Nome do Quarto Grupo
	//  mv_par08				Sub Grupos do Quarto grupo
	//---------------------------------------------------------
	//
	
	cPerg   := PADR("AD0012",10," ")    &&Criado manualmente no SX1 pois o programa so olha o cPerg AD012B e nao o AD0012.
	
	Pergunte(cPerg,.F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tela padrao de impressao                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cString := "SD2"
	titulo  := "DEMONSTRATIVO POR REGIOES DE VENDAS"
	cDesc1  := "Este programa tem como objetivo calcular a demonstrativo de "
	cDesc2  := "vendas das regioes "
	cDesc3  := "Equipe Protheus"
	NomeRel := "ADVEN106R"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Totaliza por grupos                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private _Grp1Sms	:=0
	Private _Grp2Sms	:=0
	Private _Grp3Sms	:=0
	Private _Grp4Sms	:=0
	Private _Grp5Sms	:=0
	Private _Grp6Sms	:=0   //Mauricio
	Private _Grp7Sms	:=0

	//Everson - 19/05/2021. Chamado 14094.
	Private _Grp8Sms	:=0 
	Private _Grp9Sms	:=0 
	Private _Grp10Sms	:=0
	Private _Grp11Sms	:=0
	Private _Grp12Sms	:=0
	Private _Grp13Sms	:=0
	Private _Grp14Sms	:=0
	Private _Grp15Sms	:=0
	//
	
	Private _Grp1Pes	:=0
	Private _Grp2Pes	:=0
	Private _Grp3Pes	:=0
	Private _Grp4Pes	:=0
	Private _Grp5Pes	:=0
	Private _Grp6Pes	:=0
	Private _Grp7Pes	:=0

	//Everson - 19/05/2021. Chamado 14094.
	Private _Grp8Pes	:=0
	Private _Grp9Pes	:=0
	Private _Grp10Pes	:=0
	Private _Grp11Pes	:=0
	Private _Grp12Pes	:=0
	Private _Grp13Pes	:=0
	Private _Grp14Pes	:=0
	Private _Grp15Pes	:=0
	//

	Private _Grp1Css	:=0
	Private _Grp2Css	:=0
	Private _Grp3Css	:=0
	Private _Grp4Css	:=0
	Private _Grp5Css	:=0
	Private _Grp6Css	:=0
	Private _Grp7Css	:=0

	//Everson - 19/05/2021. Chamado 14094.
	Private _Grp8Css	:=0
	Private _Grp9Css	:=0
	Private _Grp10Css	:=0
	Private _Grp11Css	:=0
	Private _Grp12Css	:=0
	Private _Grp13Css	:=0
	Private _Grp14Css	:=0
	Private _Grp15Css	:=0
	
	Private _Grp1cDSR	:=0
	Private _Grp2cDSR	:=0
	Private _Grp3cDSR	:=0
	Private _Grp4cDSR	:=0
	Private _Grp5cDSR	:=0
	Private _Grp6cDSR	:=0
	Private _Grp7cDSR	:=0
	Private _Grp8cDSR	:=0
	Private _Grp9cDSR	:=0
	Private _Grp10cDSR	:=0
	Private _Grp11cDSR	:=0
	Private _Grp12cDSR	:=0
	Private _Grp13cDSR	:=0
	Private _Grp14cDSR	:=0
	Private _Grp15cDSR	:=0

	Private _Grp1sDSR	:=0
	Private _Grp2sDSR	:=0
	Private _Grp3sDSR	:=0
	Private _Grp4sDSR	:=0
	Private _Grp5sDSR	:=0
	Private _Grp6sDSR	:=0
	Private _Grp7sDSR	:=0
	Private _Grp8sDSR	:=0
	Private _Grp9sDSR	:=0
	Private _Grp10sDSR	:=0
	Private _Grp11sDSR	:=0
	Private _Grp12sDSR	:=0
	Private _Grp13sDSR	:=0
	Private _Grp14sDSR	:=0
	Private _Grp15sDSR	:=0


	Private _nTot1G1	:= 0
	Private _nTot2G1	:= 0
	Private _nTot3G1	:= 0
	Private _nTot4G1	:= 0
	Private _nTot5G1	:= 0
	Private _nTot6G1	:= 0
	Private _nTot7G1	:= 0

	//Everson - 19/05/2021. Chamado 14094.
	Private _nTot8G1	:=0
	Private _nTot9G1	:=0
	Private _nTot10G1	:=0
	Private _nTot11G1	:=0
	Private _nTot12G1	:=0
	Private _nTot13G1	:=0
	Private _nTot14G1	:=0
	Private _nTot15G1	:=0
	//
	
	Private _nTot1G2	:= 0
	Private _nTot2G2	:= 0
	Private _nTot3G2	:= 0
	Private _nTot4G2	:= 0
	Private _nTot5G2	:= 0
	Private _nTot6G2	:= 0
	Private _nTot7G2	:= 0

	//Everson - 19/05/2021. Chamado 14094.
	Private _nTot8G2	:=0
	Private _nTot9G2	:=0
	Private _nTot10G2	:=0
	Private _nTot11G2	:=0
	Private _nTot12G2	:=0
	Private _nTot13G2	:=0
	Private _nTot14G2	:=0
	Private _nTot15G2	:=0
	//
	
	Private _nTot1G3	:= 0
	Private _nTot2G3	:= 0
	Private _nTot3G3	:= 0
	Private _nTot4G3	:= 0
	Private _nTot5G3	:= 0
	Private _nTot6G3	:= 0
	Private _nTot7G3	:= 0

	//Everson - 19/05/2021. Chamado 14094.
	Private _nTot8G3	:=0
	Private _nTot9G3	:=0
	Private _nTot10G3	:=0
	Private _nTot11G3	:=0
	Private _nTot12G3	:=0
	Private _nTot13G3	:=0
	Private _nTot14G3	:=0
	Private _nTot15G3	:=0
	//
	
	Private _nTot1G4	:= 0
	Private _nTot2G4	:= 0
	Private _nTot3G4	:= 0
	Private _nTot4G4	:= 0
	Private _nTot5G4	:= 0
	Private _nTot6G4	:= 0
	Private _nTot7G4	:= 0

	//Everson - 19/05/2021. Chamado 14094.
	Private _nTot8G4	:=0
	Private _nTot9G4	:=0
	Private _nTot10G4	:=0
	Private _nTot11G4	:=0
	Private _nTot12G4	:=0
	Private _nTot13G4	:=0
	Private _nTot14G4	:=0
	Private _nTot15G4	:=0
	
	Private _nTot1SDSR	:= 0
	Private _nTot2SDSR	:= 0
	Private _nTot3SDSR	:= 0
	Private _nTot4SDSR	:= 0
	Private _nTot5sDSR	:= 0
	Private _nTot6sDSR	:= 0
	Private _nTot7sDSR	:= 0
	Private _nTot8sDSR	:= 0
	Private _nTot9sDSR	:= 0
	Private _nTot10sDSR	:= 0
	Private _nTot11sDSR	:= 0
	Private _nTot12sDSR	:= 0
	Private _nTot13sDSR	:= 0
	Private _nTot14sDSR	:= 0
	Private _nTot15sDSR	:= 0
	
	Private _nTot1CDSR	:= 0
	Private _nTot2CDSR	:= 0
	Private _nTot3CDSR	:= 0
	Private _nTot4CDSR	:= 0
	Private _nTot5CDSR	:= 0
	Private _nTot6CDSR	:= 0
	Private _nTot7CDSR	:= 0
	Private _nTot8CDSR	:= 0
	Private _nTot9CDSR	:= 0
	Private _nTot10CDSR	:= 0
	Private _nTot11CDSR	:= 0
	Private _nTot12CDSR	:= 0
	Private _nTot13CDSR	:= 0
	Private _nTot14CDSR	:= 0
	Private _nTot15CDSR	:= 0


	Private _nTotF1		:= 0
	Private _nTotF2		:= 0
	Private _nTotF3		:= 0
	Private _nTotsDSR	:= 0
	Private _nTotcDSR	:= 0

	Private aDSR	:= {}
	
	nomerel := SetPrint(cString,Nomerel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)
	
	aDSR := fGetDSR(MV_PAR02)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa a regua de processamento                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Processa({|| RunCont()})
	//RunCont()

	//FREEOBJ("oTabSZA")
Return

Static Function fGetDSR(dDtFim)
	Local cQuery 	:= ""
	Local aRet 		:= {}
	Local cDtFim	:= Dtos(dDtFim)

	if !Empty(cDtFim)
		cquery := " SELECT * "
		cquery += " FROM "+ retsqlname("ZHA") +" "
		cquery += " WHERE D_E_L_E_T_='' AND ZHA_FILIAL='"+ xfilial("ZHA") +"' AND ZHA_ANOMES='"+ left(cDtFim,4)+"/"+SubStr(cDtfim, 5, 2) +"'; "
		
		TcQuery cquery ALIAS "QZHA" new

		if qzha->(!eof())
			aRet 		:= array(4)
			aret[1] := QZHA->ZHA_ANOMES
			aret[2] := QZHA->ZHA_DIATOT
			aret[3] := QZHA->ZHA_DUTEIS
			aret[4] := QZHA->ZHA_DSR
		endif

		qzha->(Dbclosearea())
	endif

return aRet

Static Function RunCont()
	ProcRegua(RecCount())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Arquivo Temporario para totalizacao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// ARQUIVO DE TRABALHO PARA RELATORIO DE VENDAS POR VENDEDOR (1)
	aStru := {}
	AADD (aStru,{"T1_SUPER"		, "C",06,0})	// supervisor
	AADD (aStru,{"T1_REGIAO"	, "C",06,0})	// regiao de vendas
	AADD (aStru,{"T1_VEND"		, "C",06,0})	// vendedor
	AADD (aStru,{"T1_NOMSUP"	, "C",30,0})	// Nome do Supervisor
	AADD (aStru,{"T1_NOMREG"	, "C",40,0})	// Descricao da Regiao
	AADD (aStru,{"T1_NOMVEND"	, "C",40,0})	// Nome do vendedor
	AADD (aStru,{"T1_PROD" 		, "C",15,0})	// Produto
	AADD (aStru,{"T1_DESCRIC" 	, "C",30,0})	// Descricao do Produto
	AADD (aStru,{"T1_DATA"	 	, "D",8,0})		// Data Faturamento
	AADD (aStru,{"T1_GRPCOM"	, "C",01,0})	// Grupo de Comissao do vendedor
	AADD (aStru,{"T1_GRUPOP" 	, "C",04,0})	// grupo de produto PAI
	AADD (aStru,{"T1_NOMEGP" 	, "C",30,0})	// Nome grupo de produto PAI
	AADD (aStru,{"T1_GRUPON" 	, "C",04,0})	// grupo de produto NETO
	AADD (aStru,{"T1_NOMEGN" 	, "C",30,0})	// Nome grupo de produto PAI
	AADD (aStru,{"T1_QTDADE" 	, "N",10,2})	// Quantidade vendida
	
	// Chamado n. Chamado  ³ 049140 || OS 050426 || ADM. || VAGNER || 8469 || REL METRAS - FWNM - 13/05/2019
	//AADD (aStru,{"T1_VLMEDIO"  	, "N",09,4})	// Preco medio
	AADD (aStru,{"T1_VLMEDIO"  	, "N",16,4})	// Preco medio
	//
	
	AADD (aStru,{"T1_FATUR" 	, "N",10,2})	// Total Faturado vendida
	AADD (aStru,{"T1_FATBRT" 	, "N",10,2})	// Total Faturado vendida
	AADD (aStru,{"T1_DESFIN" 	, "N",10,2})	// Total Faturado vendida
	AADD (aStru,{"T1_TABELA"	, "C",04,0})	// Tabela de Comissao
	AADD (aStru,{"T1_PERCTAB"	, "N",04,0})	// Percentual de comissão
	
	AADD (aStru,{"T1_POSIN"		, "N",03,0})	// Posicao NETO
	AADD (aStru,{"T1_POSIP"		, "N",03,0})	// Posicao PAI
	AADD (aStru,{"T1_TABFAIN"	, "C",01,0})	// Faixa da tabela NETO
	AADD (aStru,{"T1_TABFAIP"	, "C",01,0})	// Faixa da tabela PAI
	AADD (aStru,{"T1_VALFAIN"	, "N",09,2})	// Valor da comissao  NETO
	AADD (aStru,{"T1_VALFAIP"	, "N",09,2})	// Valor da Comissao PAI
	AADD (aStru,{"T1_CLASS"		, "N",10,4})	// Classificacao no Grupo Neto  //Alterado de 09 para 10 pois estava gerando erro - Ana Helena 12/01/11
	
	_cNomTrb := CriaTrab(aStru)
	
	dbUseArea(.T.,,_cNomTrb,"TEM1",.F.,.F.)
	cIndex   	:=	 "T1_VEND + T1_GRUPON + T1_PROD + DTOS(T1_DATA)"
	IndRegua( "TEM1", _cNomTrb, cIndex,,,"Criando Indice TEMP1..." )
	
	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montando o arquivo de trabalho para identificar a quantidade³
	//³de vendedores que atuarao na venda deste grupo de produtos  ³
	//³Esta quantidade e utilizada para raquear o vendedores dentro³
	//³da tabela de comissao                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ENDDOC
	*/
	aStru := {}
	AADD (aStru,{"T2_PROD" 		, "C",15,0})	// grupo de produto NETO
	AADD (aStru,{"T2_GRPCOM"	, "C",01,0})	// Grupo de Comissao do vendedor
	AADD (aStru,{"T2_DATA" 		, "D",08,0})	// Data faturamento para calculo
	AADD (aStru,{"T2_QTDADE" 	, "N",07,0})	// Quantidade de vendedores do grupo
	_cNomTr2 := CriaTrab(aStru)
	
	dbUseArea(.T.,,_cNomTr2,"TEM2",.F.,.F.)
	cIndex   	:=	 "T2_PROD+T2_GRPCOM+DTOS(T2_DATA)"
	IndRegua( "TEM2", _cNomTr2, cIndex,,,"Criando Indice TEMP2..." )
	
	aStru := {}
	//AADD (aStru,{"T3_GRUPON" 	, "C",04,0})	// grupo de produto NETO
	AADD (aStru,{"T3_VEND"   	, "C",06,0})	// Vendedor
	AADD (aStru,{"T3_GRPCOM"	, "C",01,0})	// Grupo de Comissao do vendedor
	AADD (aStru,{"T3_PROD" 		, "C",15,0})	// Produto
	AADD (aStru,{"T3_DATA" 		, "D",08,0})	// Data faturamento para calculo
	AADD (aStru,{"T3_QTDADE" 	, "N",07,0})	// Quantidade de vendedores do grupo
	_cNomTr3 := CriaTrab(aStru)
	
	dbUseArea(.T.,,_cNomTr3,"TEM3",.F.,.F.)
	cIndex   	:=	 "T3_PROD+T3_VEND+T3_GRPCOM+DTOS(T3_DATA)"
	IndRegua( "TEM3", _cNomTr3, cIndex,,,"Criando Indice TEMP3..." )
	
	aStru := {}
	AADD (aStru,{"T4_GRUPON" 	, "C",04,0})	// grupo de produto PAI
	AADD (aStru,{"T4_TABELA"	, "C",04,0})	// Tabela de Comissao do vendedor
	AADD (aStru,{"T4_GRPCOM"	, "C",01,0})	// Grupo de Comissao do vendedor
	AADD (aStru,{"T4_DATA" 		, "D",08,0})	// Data faturamento para calculo
	AADD (aStru,{"T4_QTDADE" 	, "N",07,0})	// Quantidade de vendedores do grupo
	_cNomTr4 := CriaTrab(aStru)
	
	dbUseArea(.T.,,_cNomTr4,"TEM4",.F.,.F.)
	cIndex   	:=	 "T4_GRUPON+T4_TABELA+T4_GRPCOM+DTOS(T4_DATA)"
	IndRegua( "TEM4", _cNomTr4, cIndex,,,"Criando Indice TEMP4..." )
	
	aStru := {}
	AADD (aStru,{"T5_GRUPON" 	, "C",04,0})	// grupo de produto NETO
	AADD (aStru,{"T5_VEND"   	, "C",06,0})	// Vendedor
	AADD (aStru,{"T5_GRPCOM"	, "C",01,0})	// Grupo de Comissao do vendedor
	AADD (aStru,{"T5_TABELA"	, "C",04,0})	// Tabela de Comissao do vendedor
	AADD (aStru,{"T5_DATA" 		, "D",08,0})	// Data faturamento para calculo
	AADD (aStru,{"T5_QTDADE" 	, "N",07,0})	// Quantidade de vendedores do grupo
	_cNomTr5 := CriaTrab(aStru)
	
	dbUseArea(.T.,,_cNomTr5,"TEM5",.F.,.F.)
	cIndex   	:=	 "T5_GRUPON+T5_TABELA+T5_GRPCOM+T5_VEND+DTOS(T5_DATA)"
	IndRegua( "TEM5", _cNomTr5, cIndex,,,"Criando Indice TEMP5..." )
	
	aStru := {}
	AADD (aStru,{"T6_GRUPON" 	, "C",04,0})	// grupo de produto NETO
	AADD (aStru,{"T6_VEND"   	, "C",06,0})	// Vendedor
	AADD (aStru,{"T6_TABELA"	, "C",04,0})	// Tabela de Comissao do vendedor
	AADD (aStru,{"T6_PERCTAB"	, "N",04,0})	// Percentual de comissão
	AADD (aStru,{"T6_GRPCOM"	, "C",01,0})	// Grupo de Comissao do vendedor
	AADD (aStru,{"T6_DATA" 		, "D",08,0})	// Data faturamento para calculo
	AADD (aStru,{"T6_QTDADE" 	, "N",07,0})	// Quantidade de vendedores do grupo
	AADD (aStru,{"T6_FATUR" 	, "N",10,2})	// Total Faturado vendida
	
	// Chamado n. Chamado  ³ 049140 || OS 050426 || ADM. || VAGNER || 8469 || REL METRAS - FWNM - 13/05/2019
	//AADD (aStru,{"T6_VLMEDIO"  	, "N",09,4})	// Preco medio
	AADD (aStru,{"T6_VLMEDIO"  	, "N",16,4})	// Preco medio
	//
	
	AADD (aStru,{"T6_POSIP"		, "N",03,0})	// Posicao PAI
	AADD (aStru,{"T6_CLASS"		, "N",08,4})	// Classificacao no Grupo Neto
	AADD (aStru,{"T6_TABFAIP"	, "C",01,0})	// Faixa da tabela PAI
	AADD (aStru,{"T6_VLFAI"		, "N",09,4})	// Valor da faixa
	AADD (aStru,{"T6_SUPER"		, "C",06,0})	// supervisor
	AADD (aStru,{"T6_REGIAO"	, "C",06,0})	// regiao de vendas
	AADD (aStru,{"T6_NOMSUP"	, "C",30,0})	// Nome do Supervisor
	AADD (aStru,{"T6_NOMREG"	, "C",40,0})	// Descricao da Regiao
	AADD (aStru,{"T6_NOMVEND"	, "C",40,0})	// Nome do vendedor
	AADD (aStru,{"T6_NOMEGN" 	, "C",30,0})	// Nome grupo de produto PAI
	
	_cNomTr6 := CriaTrab(aStru)
	
	dbUseArea(.T.,,_cNomTr6,"TEM6",.F.,.F.)
	cIndex   	:=	 "T6_GRUPON+T6_TABELA+T6_GRPCOM+T6_VEND+DTOS(T6_DATA)"
	IndRegua( "TEM6", _cNomTr6, cIndex,,,"Criando Indice TEMP6..." )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	dbSelectArea("SA3")
	dbSetOrder(1)
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	
	dbSelectArea("SBM")
	dbSetOrder(1)
	
	dbSelectArea("SD1")
	dbSetOrder(1)
	
	dbSelectArea("SD2")
	dbSetOrder(3)
	
	dbSelectArea("SF1")
	dbSetOrder(1)
	
	dbSelectArea("SF2")
	dbSetOrder(1)
	dbSelectArea("SZR")
	dbSetOrder(1)
	
	Processa({|| Sele1()},"Selecionando registros SF2 ...")
	//MsAguarde({|lFim| Sele1()},"Selecionando registros SF2","Aguarde a finalização do processamento...",.t.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Sele1     ºAutor  ³Heraldo C. Hebling  º Data ³  04/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz select de registros                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Sele1()

	cQuery	:= " SELECT F2_FILIAL, F2_DOC, F2_EMISSAO, F2_VEND1, F2_SERIE, F2_CLIENTE ,F2_LOJA," 
	cQuery	+= "	A1_NOME, A1_DESC, "
	cQuery	+= "	A3_CODSUP, A3_REGIAO, A3_TABELA, A3_NOME, A3_PERCTAB "
	cQuery	+= " FROM "+retsqlname("SF2")+" SF2 (NOLOCK) INNER JOIN " +retsqlname("SA1")+" SA1 (NOLOCK) ON SA1.D_E_L_E_T_='' AND SF2.D_E_L_E_T_='' AND SA1.A1_COD=SF2.F2_CLIENTE AND SA1.A1_LOJA=SF2.F2_LOJA "
	cQuery	+= "  		INNER JOIN "+ RetSqlName("SA3") +" SA3 (NOLOCK) ON SA3.D_E_L_E_T_='' AND SA3.A3_COD=SF2.F2_VEND1	"
	cQuery	+= " WHERE F2_FILIAL IN ("+AllTrim(_cFilial)+") "
	cQuery	+= " 	AND SF2.D_E_L_E_T_= '' "
	cQuery	+= " 	AND F2_EMISSAO BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"' "
	cQuery	+= " 	AND F2_TIPO='N' "
	cQuery	+= " 	AND A3_COMSN !='N' "
	cQuery	+= " 	AND F2_VEND1   BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
	cQuery	+= " 	AND A3_TABELA  BETWEEN '"+mv_par10+"' AND '"+mv_par11+"' "
	//cQuery  += " 	AND F2_DOC='002365590' "
	if (mv_par05 == 1)
		cQuery	+= " AND SA3.A3_CODSUP   BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' "
	endif

	if (mv_par05 == 2)
		cQuery	+= " AND SA3.A3_REGIAO   BETWEEN '"+mv_par08+"' AND '"+mv_par09+"' "
	Endif
	cQuery	+= " ORDER BY F2_EMISSAO,F2_DOC,F2_SERIE"


	TCQUERY cQuery new alias "XF2"
	//return

	dbSelectArea("XF2")

	//Processa({|| MontaTra()},"Processando NF SAIDA ...")
	MsAguarde({|lFim| MontaTra()},"Processando NF SAIDA","Aguarde a finalização do processamento...",.t.)
	//MontaTra()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MontaTra  ºAutor  ³Heraldo C. Hebling  º Data ³  04/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processa registro selecionados, monta arquivos de trabalho º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MontaTra()
	
	//ProcRegua(RecCount())
	XF2->(dbgotop())
	_cTabela:=''
	
	dbSelectArea("TEM1")
	dbSelectArea("TEM2")
	dbSelectArea("TEM3")
	dbSelectArea("TEM4")
	dbSelectArea("TEM5")
	dbSelectArea("TEM6")

	dbSelectArea("SZR")
	dbSelectArea("SZP")

	nCount := 0
	if XF2->(!eof())
		
		fCarSZA()

		While XF2->(!eof())
			nCount++

			If nLastKey == 27
				Return
			Endif
			
			// TABELA DE SUPERVISOR
			SZR->(DbSetOrder(1))
			SZR->(dbSeek(xfilial() + XF2->A3_CODSUP))

			// TABELA DE REGIOES DE MERCADO
			SZP->(DbSetOrder(1))
			SZP->(dbSeek(xfilial() + XF2->A3_REGIAO))


			_cVend	 	:= 	XF2->F2_VEND1
			_cNomeVen	:=	XF2->A3_NOME

			_cVend	 	:= 	XF2->F2_VEND1
			_cSuper		:=	XF2->A3_CODSUP
			_cNomSup	:=	SZR->ZR_DESCRIC
			_cRegiao	:= 	XF2->A3_REGIAO
			_cNomReg	:=	SZP->ZP_DESCRIC
			_cGrpCom	:= 	XF2->A3_TABELA
			_nPerTab	:=  IIF(EMPTY(XF2->A3_PERCTAB), 0, val(XF2->A3_PERCTAB))

			//dbSelectArea("SD2")
			//dbSeek(xfilial("SD2") + XF2->F2_DOC + XF2->F2_SERIE + XF2->F2_CLIENTE + XF2->F2_LOJA)
			//dbSeek(XF2->F2_FILIAL + XF2->F2_DOC + XF2->F2_SERIE + XF2->F2_CLIENTE + XF2->F2_LOJA)   &&Mauricio Chamado 006076.
			
			//MsProcTxt( TIME() )// Chamado n. TI - FWNM - 23/05/2019
			
			cQuery := " SELECT D2_FILIAL, D2_COD, D2_EMISSAO, D2_QUANT, D2_TOTAL, D2_VALDEV, D2_CF, D2_TP, D2_TES, "
			cQuery += " 	B1_GRUPO, B1_DESC, "
			cQuery += " 	ISNULL(BMA.BM_GRUPO,'') GRUPO_N, ISNULL(BMA.BM_DESC,'') DESC_N, ISNULL(BMA.BM_NIVEL,'') NIVEL_N, ISNULL(BMA.BM_TABCOM,'') TABCOM_N, "
			cQuery += " 	ISNULL(BMB.BM_GRUPO,'') GRUPO_2, ISNULL(BMB.BM_DESC,'') DESC_2, ISNULL(BMB.BM_NIVEL,'') NIVEL_2, ISNULL(BMB.BM_TABCOM,'') TABCOM_2, "
			cQuery += " 	ISNULL(BMC.BM_GRUPO,'') GRUPO_1, ISNULL(BMC.BM_DESC,'') DESC_1, ISNULL(BMC.BM_NIVEL,'') NIVEL_1, ISNULL(BMC.BM_TABCOM,'') TABCOM_1 "
			cQuery += " FROM "+ RetSqlName("SD2") +" (NOLOCK) D2 INNER JOIN "+ RetSqlName("SB1") +" (NOLOCK) B1 ON D2.D_E_L_E_T_='' AND D2.D_E_L_E_T_='' AND B1.B1_FILIAL='"+ xFilial("SB1") +"' AND D2.D2_FILIAL='"+ XF2->F2_FILIAL +"' AND D2.D2_COD=B1.B1_COD "
			cQuery += "  LEFT JOIN (SELECT A.BM_GRUPO, A.BM_NIVEL, A.BM_DESC, A.BM_TABCOM, ISNULL(MAX(B.BM_GRUPO),'') MAX_2, ISNULL(MAX(C.BM_GRUPO),'') MAX_1 "
			cQuery += " 				  FROM "+ RetSqlName("SBM") +" (NOLOCK) A LEFT JOIN "+ RetSqlName("SBM") +" (NOLOCK) B ON A.D_E_L_E_T_='' AND B.D_E_L_E_T_='' AND A.BM_GRUPO>B.BM_GRUPO AND A.BM_NIVEL > '2' AND B.BM_NIVEL='2' "
			cQuery += " 								LEFT JOIN "+ RetSqlName("SBM") +" (NOLOCK) C ON A.D_E_L_E_T_='' AND C.D_E_L_E_T_='' AND A.BM_GRUPO>C.BM_GRUPO AND A.BM_NIVEL > '1' AND C.BM_NIVEL='1' "
			cQuery += " 				  WHERE A.D_E_L_E_T_='' "
			cQuery += " 				  GROUP BY A.BM_GRUPO, A.BM_NIVEL, A.BM_DESC, A.BM_TABCOM) BMA ON B1.D_E_L_E_T_='' AND B1.B1_GRUPO=BMA.BM_GRUPO "
			cQuery += " 	   LEFT JOIN "+ RetSqlName("SBM") +" (NOLOCK) BMB ON BMB.D_E_L_E_T_='' AND BMB.BM_GRUPO=BMA.MAX_2 AND BMB.BM_NIVEL='2' "
			cQuery += " 	   LEFT JOIN "+ RetSqlName("SBM") +" (NOLOCK) BMC ON BMC.D_E_L_E_T_='' AND BMC.BM_GRUPO=BMA.MAX_1 AND BMC.BM_NIVEL='1' "
			cQuery += " WHERE D2.D_E_L_E_T_='' "
			cQuery += "  AND D2.D2_FILIAL='"+ XF2->F2_FILIAL +"' "
			cQuery += "  AND D2.D2_DOC='"+ XF2->F2_DOC +"' "
			cQuery += "  AND D2.D2_SERIE='"+ XF2->F2_SERIE +"' "
			cQuery += "  AND D2.D2_CLIENTE='"+ XF2->F2_CLIENTE +"' "
			cQuery += "  AND D2.D2_LOJA='"+ XF2->F2_LOJA +"' "
			cQuery += "  AND D2_TP = 'PA' "
			cQuery += "  AND NOT ( (LEFT(D2_CF,2) = '59' OR LEFT(D2_CF,2) = '69') AND D2_TES <> '526' ) "

			TcQuery cQuery ALIAS "QSD2" NEW

			TCSETFIELD( "QSD2", "D2_EMISSAO", "D", 8, 0 )

			nCount := 0
			While QSD2->(!eof())
			/*
			DO WHILE !EOF() .AND. 	SD2->D2_DOC		  	== XF2->F2_DOC     	.AND. ;
				SD2->D2_FILIAL      == XF2->F2_FILIAL .AND. ;
				SD2->D2_SERIE	  	== XF2->F2_SERIE  	.AND. ;
				SD2->D2_CLIENTE		== XF2->F2_CLIENTE .AND. ;
				SD2->D2_LOJA		== XF2->F2_LOJA
			*/	
				nCount++
				// LPM - Descontinuar esse trecho.
				If (LEFT(QSD2->D2_CF,2) == "59" .OR. LEFT(QSD2->D2_CF,2) == "69") .AND. QSD2->D2_TES <> '526'  //REMESSA DESCONSIDERA
					dbSelectArea("QSD2")
					QSD2->(dbskip())
					LOOP
				Endif
				
				// LPM - Descontinuar esse trecho.
				If QSD2->D2_TP != "PA"		// se nao for produto acabado desconsidera
					dbSelectArea("QSD2")
					QSD2->(dbskip())
					LOOP
				Endif
				
				
				_cProduto 	:= 	QSD2->D2_COD
				_nQtd      	:= 	QSD2->D2_QUANT
				_nVal      	:= 	QSD2->D2_TOTAL
				_dData		:=  QSD2->D2_EMISSAO
				
				_nValLiq    := (QSD2->D2_TOTAL - QSD2->D2_VALDEV)
				_nMedio  	:=	_nVal / _nQtd
				_nDesFin    :=	XF2->A1_DESC
				
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³DESCONTO FINANCEIRO                                                                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IF _nDesFin > 0
					_nVal  :=  _nVal - ((_nDesFin/100)* _nValLiq)
					_nMedio:=  _nVal / _nQtd
				ENDIF
				
				
				//dbSelectArea("SB1")
				//dbSeek(xfilial("SB1") + _cProduto)
				_cGrupoN	:=	QSD2->B1_GRUPO     //ALTERADO EM  28/12/06 - XGRPANT PRESERVA GRUPO
				//		_cGrupoN	:=	SB1->B1_XGRPANT
				_cDescric	:=	QSD2->B1_DESC
				_cGrupoP	:=	""
				_cDescGrN	:=	""
				_cDescGrP	:=	""

					//MsProcTxt( "Procurando grupo... " + time() )// Chamado n. TI - FWNM - 23/05/2019
				//PROCURAGRUPO()

				if !EMPTY(QSD2->TABCOM_N)
					_cTabela	:=	QSD2->TABCOM_N
				elseif !EMPTY(QSD2->TABCOM_2)
					_cTabela	:=	QSD2->TABCOM_2
				elseif !EMPTY(QSD2->TABCOM_1)
					_cTabela	:=	QSD2->TABCOM_1
				ELSE
					_cTabela	:=	"0001"
				endif

				_cDescGrN	:=	QSD2->DESC_N
				_cGrupoF	:=	QSD2->GRUPO_2 // NIVEL 2
				_cGrupoP	:=	QSD2->GRUPO_1
				_cDescGrP	:=	QSD2->DESC_1

				IF TEM1->(!dbSeek(_cVend + _cGrupoN + _cProduto + dtos(_dData)))
					//002365590
					RecLock("TEM1",.T.)
						TEM1->T1_SUPER		:=	_cSuper
						TEM1->T1_REGIAO		:=	_cRegiao
						TEM1->T1_VEND		:=	_cVend
						TEM1->T1_NOMSUP		:=	_cNomSup
						TEM1->T1_NOMREG		:=	_cNomReg
						TEM1->T1_NOMVEND	:=	_cNomeVen
						TEM1->T1_GRPCOM		:=	_cGrpCom
						TEM1->T1_GRUPOP		:=	_cGrupoP
						TEM1->T1_NOMEGP		:=	_cDescGrP
						TEM1->T1_GRUPON		:=	_cGrupoN
						TEM1->T1_NOMEGN		:=	_cDescGrN
						TEM1->T1_PROD		:=	_cProduto
						TEM1->T1_DESCRIC	:=	_cDescric
						TEM1->T1_DATA    	:=	_dData
						TEM1->T1_VLMEDIO  	:= _nMedio
						TEM1->T1_QTDADE  	:= _nQtd
						TEM1->T1_FATUR    	:= _nVal
						TEM1->T1_TABELA    	:= _cTabela
						TEM1->T1_PERCTAB   	:= _nPerTab
					TEM1->(MsUnLock())

				Else
					
					RecLock("TEM1",.F.)
						_nQtdAc      	:= _nQtd	+ TEM1->T1_QTDADE
						_nValAc      	:= _nVal	+ TEM1->T1_FATUR
						_nMedio			:= _nValAc / _nQtdAc
						
						//			_nValbrt+=_nValbrt
						//			TEM1->T1_FATBRT		:=_nValbrt
						TEM1->T1_VLMEDIO  	:= _nMedio
						TEM1->T1_QTDADE  	:= _nQtdAc
						TEM1->T1_FATUR    	:= _nValAc
					TEM1->(MsUnLock())

				endif

				IF TEM3->(!dbSeek(_cProduto+_cVend+_cGrpCom+DTos(_dData)))
	
					RecLock("TEM3",.T.)
						TEM3->T3_VEND  		:= 	_cVend
						TEM3->T3_PROD		:=	_cProduto
						TEM3->T3_GRPCOM		:=	_cGrpCom
						TEM3->T3_DATA		:= 	_dData
						TEM3->T3_QTDADE  	:= 1
					TEM3->(MsUnLock())

					IF TEM2->(!dbSeek(_cProduto+_cGrpCom+DTos(_dData)))
							
						RecLock("TEM2",.T.)
							TEM2->T2_PROD		:=	_cProduto
							TEM2->T2_GRPCOM		:=	_cGrpCom
							TEM2->T2_DATA		:= 	_dData
							TEM2->T2_QTDADE  	:= 1
						TEM2->(MsUnLock())
					Else
								
						RecLock("TEM2",.F.)
							TEM2->T2_QTDADE  	:= TEM2->T2_QTDADE + 1
						MsUnLock()
					Endif

				Else
					
					RecLock("TEM3",.F.)
						TEM3->T3_QTDADE  	:= 	TEM3->T3_QTDADE  + 1
					TEM3->(MsUnLock())
				Endif

				IF TEM5->(!dbSeek(_cGrupoN+_cTabela+_cGrpCom+_cVend+DTos(_dData)))
					
				
					RecLock("TEM5",.T.)
						TEM5->T5_GRUPON		:=	_cGrupoN
						TEM5->T5_VEND  		:= 	_cVend
						TEM5->T5_GRPCOM		:=	_cGrpCom
						TEM5->T5_TABELA		:=	_cTabela
						TEM5->T5_DATA		:= 	_dData
						TEM5->T5_QTDADE  	:= 1
					TEM5->(MsUnLock())

					IF TEM4->(!dbSeek(_cGrupoN+_cTabela+_cGrpCom+DTos(_dData)))
						
						RecLock("TEM4",.T.)
							TEM4->T4_GRUPON		:=	_cGrupoN
							TEM4->T4_TABELA		:=	_cTabela
							TEM4->T4_GRPCOM		:=	_cGrpCom
							TEM4->T4_DATA		:= 	_dData
							TEM4->T4_QTDADE  	:= 1
						TEM4->(MsUnLock())
					Else
					
						RecLock("TEM4",.F.)
							TEM4->T4_QTDADE  	:= TEM4->T4_QTDADE + 1
						TEM4->(MsUnLock())
					Endif
				Else
					
					RecLock("TEM5",.F.)
						TEM5->T5_QTDADE  	:= 	TEM5->T5_QTDADE  + 1
					TEM5->(MsUnLock())
				Endif

				QSD2->(dbskip())
			ENDDO
			QSD2->(DbcloseArea())

			XF2->(dbskip())
		ENDDO

	endif

	XF2->(dbclosearea())
	
	//DEVOLUCOES
	cQuery:="select * "+;
	"from "+retsqlname("SF1")+" (NOLOCK)"+; // Chamado n. TI - FWNM - 23/05/2019
	"where F1_FILIAL IN ('"+AllTrim(_cFilial)+"') and "+; // Chamado n. TI - FWNM - 23/05/2019 //Ticket  15291  - Abel Babini  - 08/06/2021 - Correção de Error.log com a filial sem aspas
	"F1_DTDIGIT between '"+dtos(mv_par01)+"' and '"+dtos(mv_par02)+"' and "+; // Chamado n. TI - FWNM - 23/05/2019
	"F1_TIPO='D' and "+;
	"D_E_L_E_T_= '' "+;
	"order by F1_DTDIGIT,F1_DOC,F1_SERIE"
	
	TCQUERY cQuery new alias "XF1"
	
	XF1->(dbgotop())
	nCount := 0
	ProcRegua(RecCount())

	DO WHILE XF1->(!EOF())
		nCount++
		//  INCREMENTA A BARRA DE EVOLUCAO
		IncProc(" Filial-Devolucao: " + XF1->F1_FILIAL+"-"+XF1->F1_DOC + " - Dt.Emissao : "+XF1->F1_DTDIGIT + " - Regs: " + AllTrim(Str(nCount))) 

		If nLastKey == 27
			Return
		Endif
		/*
		dbSelectArea("SD1")
		SD1->(dbSetOrder(1))
		//dbSeek(xfilial("SD1") + XF1->F1_DOC + XF1->F1_SERIE + XF1->F1_FORNECE +XF1->F1_LOJA)
		dbSeek(XF1->F1_FILIAL + XF1->F1_DOC + XF1->F1_SERIE + XF1->F1_FORNECE +XF1->F1_LOJA)    //&&Mauricio Chamado 006076.
		*/

		cQuery := " SELECT D1_FILIAL, D1_COD, D1_NFORI, D1_SERIORI, D1_FORNECE, D1_LOJA, D1_DTDIGIT, D1_CF, D1_QUANT, D1_TOTAL, D1_VALDEV, F2_VEND1, "
		cQuery += " 	B1_GRUPO, B1_DESC, "
		cQuery += "		A3_NOME, A3_TABELA, A3_CODSUP, A3_REGIAO, A3_PERCTAB, "
		cQuery += " 	ISNULL(BMA.BM_GRUPO,'') GRUPO_N, ISNULL(BMA.BM_DESC,'') DESC_N, ISNULL(BMA.BM_NIVEL,'') NIVEL_N, ISNULL(BMA.BM_TABCOM,'') TABCOM_N, "
		cQuery += " 	ISNULL(BMB.BM_GRUPO,'') GRUPO_2, ISNULL(BMB.BM_DESC,'') DESC_2, ISNULL(BMB.BM_NIVEL,'') NIVEL_2, ISNULL(BMB.BM_TABCOM,'') TABCOM_2, "
		cQuery += " 	ISNULL(BMC.BM_GRUPO,'') GRUPO_1, ISNULL(BMC.BM_DESC,'') DESC_1, ISNULL(BMC.BM_NIVEL,'') NIVEL_1, ISNULL(BMC.BM_TABCOM,'') TABCOM_1 "
		cQuery += " FROM "+ RetSqlName("SD1") +" (NOLOCK) D1 INNER JOIN "+ RetSqlName("SB1") +" (NOLOCK) B1 ON D1.D_E_L_E_T_='' AND D1.D_E_L_E_T_='' AND B1.B1_FILIAL='"+ xFilial("SB1") +"' AND D1.D1_FILIAL='"+ XF1->F1_FILIAL +"' AND D1.D1_COD=B1.B1_COD "
		cQuery += " 								 INNER JOIN "+ RetSqlName("SF2") +" (NOLOCK) F2 ON F2.D_E_L_E_T_='' AND F2.F2_FILIAL=D1.D1_FILIAL AND F2.F2_DOC=D1.D1_NFORI AND F2.F2_SERIE=D1.D1_SERIORI AND F2.F2_CLIENTE=D1.D1_FORNECE AND F2.F2_LOJA=D1.D1_LOJA "
		cQuery += " 								 INNER JOIN "+ RetSqlName("SA3") +" (NOLOCK) A3 ON A3.D_E_L_E_T_='' AND A3.A3_FILIAL='"+ xFilial("SA3") +"' AND F2.F2_VEND1=A3.A3_COD "		
		cQuery += "  LEFT JOIN (SELECT A.BM_GRUPO, A.BM_NIVEL, A.BM_DESC, A.BM_TABCOM, ISNULL(MAX(B.BM_GRUPO),'') MAX_2, ISNULL(MAX(C.BM_GRUPO),'') MAX_1 "
		cQuery += " 				  FROM "+ RetSqlName("SBM") +" (NOLOCK) A LEFT JOIN "+ RetSqlName("SBM") +" (NOLOCK) B ON A.D_E_L_E_T_='' AND B.D_E_L_E_T_='' AND A.BM_GRUPO>B.BM_GRUPO AND A.BM_NIVEL > '2' AND B.BM_NIVEL='2' "
		cQuery += " 								LEFT JOIN "+ RetSqlName("SBM") +" (NOLOCK) C ON A.D_E_L_E_T_='' AND C.D_E_L_E_T_='' AND A.BM_GRUPO>C.BM_GRUPO AND A.BM_NIVEL > '1' AND C.BM_NIVEL='1' "
		cQuery += " 				  WHERE A.D_E_L_E_T_='' "
		cQuery += " 				  GROUP BY A.BM_GRUPO, A.BM_NIVEL, A.BM_DESC, A.BM_TABCOM) BMA ON B1.D_E_L_E_T_='' AND B1.B1_GRUPO=BMA.BM_GRUPO "
		cQuery += " 	   LEFT JOIN "+ RetSqlName("SBM") +" (NOLOCK) BMB ON BMB.D_E_L_E_T_='' AND BMB.BM_GRUPO=BMA.MAX_2 AND BMB.BM_NIVEL='2' "
		cQuery += " 	   LEFT JOIN "+ RetSqlName("SBM") +" (NOLOCK) BMC ON BMC.D_E_L_E_T_='' AND BMC.BM_GRUPO=BMA.MAX_1 AND BMC.BM_NIVEL='1' "
		cQuery += " WHERE D1.D_E_L_E_T_='' AND D1.D1_TIPO='D' AND D1.D1_NFORI !='' "
		cQuery += "  AND D1.D1_FILIAL='"+ XF1->F1_FILIAL +"' "
		cQuery += "  AND D1.D1_DOC='"+ XF1->F1_DOC +"' "
		cQuery += "  AND D1.D1_SERIE='"+ XF1->F1_SERIE +"' "
		cQuery += "  AND D1.D1_FORNECE='"+ XF1->F1_FORNECE +"' "
		cQuery += "  AND D1.D1_LOJA='"+ XF1->F1_LOJA +"' "
		cQuery += "  AND D1_TP = 'PA' "
		
		// CLASSE DE COMISSAO
		cQuery += " AND (A3.A3_TABELA BETWEEN '"+mv_par10+"' AND '"+mv_par11+"') "
		// REGIAO DE VENDAS
		If  (mv_par05 == 2)
			cQuery += " AND (A3.A3_REGIAO BETWEEN '"+mv_par08+"' AND '"+mv_par09+"') "
		endif
		// SUPERVISOR
		If (mv_par05 == 1)
			cQuery += " AND (A3.A3_CODSUP BETWEEN '"+mv_par06+"' AND '"+mv_par07+"') "
		Endif
		// FILTRA VENDEDOR DA NFE DE ORIGEM.
		cQuery += "  AND F2.F2_VEND1 BETWEEN '"+ mv_par03 +"' AND '"+ mv_par04 +"' "
		// FILTRA CLASSES DE CFOPS.
		cQuery += "  AND NOT (LEFT(D1.D1_CF,2) = '19' OR LEFT(D1.D1_CF,2) = '29')"

		TcQuery cQuery ALIAS "QSD1" NEW

		TcsetField("QSD1","D1_DTDIGIT","D", 8, 0)

		nCount := 0
		Do While QSD1->(!eof())
		/*
		DO WHILE !EOF() .AND. 	QSD1->D1_DOC 		== XF1->F1_DOC     	.AND. ;
			QSD1->D1_FILIAL      == XF1->F1_FILIAL .AND. ;
			QSD1->D1_SERIE    	== XF1->F1_SERIE   	.AND. ;
			QSD1->D1_FORNECE  	== XF1->F1_FORNECE .AND. ;
			QSD1->D1_LOJA		== XF1->F1_LOJA
		*/	
			nCount++

			IF !EMPTY(QSD1->D1_NFORI)
				If LEFT(QSD1->D1_CF,2) == "19" .OR. LEFT(QSD1->D1_CF,2) == "29"  //REMESSA DESCONSIDERA
					dbSelectArea("QSD1")
					QSD1->(dbskip())
					LOOP
				Endif
				_cOriDOC   	:= 	QSD1->D1_NFORI
				_cSERIE    	:= 	QSD1->D1_SERIORI
				_cCLIENTE  	:= 	QSD1->D1_FORNECE
				_cLOJA     	:= 	QSD1->D1_LOJA
				
				_cVend	 	:= 	QSD1->F2_VEND1
				_cGrpCom 	:=  QSD1->A3_TABELA
				_cNomeven	:=  QSD1->A3_NOME
				
				_nQtd      	:= QSD1->D1_QUANT	* (-1)
				_nVal      	:= QSD1->D1_TOTAL	* (-1)
				_cProduto 	:= QSD1->D1_COD
				_dData		:= QSD1->D1_DTDIGIT
				
				_cGrupoN	:=	QSD1->B1_GRUPO   //ALTERADO EM  28/12/06 - XGRPANT PRESERVA GRUPO
				_cDescric 	:=	QSD1->B1_DESC
				_cGrupoP	:=	""
				_cDescGrN	:=	""
				_cDescGrP	:=	""
				//
				//PROCURAGRUPO()

				if !EMPTY(QSD1->TABCOM_N)
					_cTabela	:=	QSD1->TABCOM_N
				elseif !EMPTY(QSD1->TABCOM_2)
					_cTabela	:=	QSD1->TABCOM_2
				elseif !EMPTY(QSD1->TABCOM_1)
					_cTabela	:=	QSD1->TABCOM_1
				ELSE
					_cTabela	:=	"0001"
				endif

				_cDescGrN	:=	QSD1->DESC_N
				_cGrupoF	:=	QSD1->GRUPO_2 // NIVEL 2
				_cGrupoP	:=	QSD1->GRUPO_1
				_cDescGrP	:=	QSD1->DESC_1

				// TABELA DE SUPERVISOR
				SZR->(dbSeek(xfilial() + QSD1->A3_CODSUP))
				_cNomSup	:=	SZR->ZR_DESCRIC

				// TABELA DE REGIOES DE MERCADO
				SZP->(dbSeek(xfilial() + QSD1->A3_REGIAO))
				_cNomReg	:=	SZP->ZP_DESCRIC
				
				_cSuper		:=	QSD1->A3_CODSUP
				_cRegiao	:= 	QSD1->A3_REGIAO
				_cGrpCom	:= 	QSD1->A3_TABELA
				_nPerTab	:=  iif(Empty(QSD1->A3_PERCTAB), 0, Val(QSD1->A3_PERCTAB))
				
				//dbSelectArea("TEM1")
				IF TEM1->(!dbSeek(_cVend + _cGrupoN + _cProduto + dtos(_dData)))
					
			
					RecLock("TEM1",.T.)
						_nMedio		:=	_nVal / _nQtd
						TEM1->T1_SUPER		:=	_cSuper
						TEM1->T1_REGIAO		:=	_cRegiao
						TEM1->T1_VEND	    :=	_cVend
						TEM1->T1_NOMSUP		:=	_cNomSup
						TEM1->T1_NOMREG		:=	_cNomReg
						TEM1->T1_NOMVEND	:=	_cNomeven
						TEM1->T1_GRPCOM		:=	_cGrpCom
						TEM1->T1_GRUPOP		:=	_cGrupoP
						TEM1->T1_NOMEGP		:=	_cDescGrP
						TEM1->T1_GRUPON		:=	_cGrupoN
						TEM1->T1_NOMEGN		:=	_cDescGrN
						TEM1->T1_PROD		:=	_cProduto
						TEM1->T1_DESCRIC	:=	_cDescric
						TEM1->T1_DATA   	:=	_dData
						TEM1->T1_VLMEDIO  	:= _nMedio
						TEM1->T1_QTDADE  	:= _nQtd
						TEM1->T1_FATUR    	:= _nVal
						TEM1->T1_TABELA    	:= _cTabela
						TEM1->T1_PERCTAB   	:= _nPerTab
						
					TEM1->(MsUnLock())
				Else
					
					RecLock("TEM1",.F.)
						_nQtdAc      		:= 	_nQtd	+ TEM1->T1_QTDADE
						_nValAc      		:= 	_nVal	+ TEM1->T1_FATUR
						_nMedio				:=	_nValAc / _nQtdAc
						TEM1->T1_VLMEDIO  	:= _nMedio
						TEM1->T1_QTDADE  	:= _nQtdAc
						TEM1->T1_FATUR    	:= _nValAc
					TEM1->(MsUnLock())
				endif
				
				//dbSelectArea("TEM3")
				IF TEM3->(!dbSeek(_cProduto+_cVend+_cGrpCom+dTos(_dData)))
					
				
					RecLock("TEM3",.T.)
						TEM3->T3_VEND  		:= 	_cVend
						TEM3->T3_PROD		:=	_cProduto
						TEM3->T3_GRPCOM		:=	_cGrpCom
						TEM3->T3_DATA		:=  _dData
						TEM3->T3_QTDADE  	:= 0
					TEM3->(MsUnLock())
					
					//dbSelectArea("TEM2")
					IF TEM2->(!dbSeek(_cProduto+_cGrpCom+dTos(_dData)))
				
						RecLock("TEM2",.T.)
							TEM2->T2_PROD		:=	_cProduto
							TEM2->T2_GRPCOM		:=	_cGrpCom
							TEM2->T2_DATA		:=  _dData
							TEM2->T2_QTDADE  	:= 1
						TEM2->(MsUnLock())
					Else
					
						RecLock("TEM2",.F.)
							TEM2->T2_QTDADE  	:= TEM2->T2_QTDADE - 1
						TEM2->(MsUnLock())
					Endif
				Else
					RecLock("TEM3",.F.)
						TEM3->T3_QTDADE  	:= 	TEM3->T3_QTDADE  - 1
					TEM3->(MsUnLock())
				Endif

				//dbSelectArea("TEM5")
				IF TEM5->(!dbSeek(_cGrupoN+_cTabela+_cGrpCom+_cVend+dTos(_dData)))
				
					RecLock("TEM5",.T.)
						TEM5->T5_GRUPON		:=	_cGrupoN
						TEM5->T5_VEND  		:= 	_cVend
						TEM5->T5_GRPCOM		:=	_cGrpCom
						TEM5->T5_TABELA		:=	_cTabela
						TEM5->T5_DATA		:= 	_dData
						TEM5->T5_QTDADE  	:= 1
					TEM5->(MsUnLock())
					
					//dbSelectArea("TEM4")
					IF TEM4->(!dbSeek(_cGrupoN+_cTabela+_cGrpCom+dTos(_dData)))
					
						RecLock("TEM4",.T.)
							TEM4->T4_GRUPON		:=	_cGrupoN
							TEM4->T4_TABELA		:=	_cTabela
							TEM4->T4_GRPCOM		:=	_cGrpCom
							TEM4->T4_DATA		:=  _dData
							TEM4->T4_QTDADE  	:= 1
						TEM4->(MsUnLock())
					Else
						RecLock("TEM4",.F.)
							TEM4->T4_QTDADE  	:= TEM4->T4_QTDADE + 1
						TEM4->(MsUnLock())
					Endif
				Else
					
					RecLock("TEM5",.F.)
						TEM5->T5_QTDADE  	:= 	TEM5->T5_QTDADE  + 1
					TEM5->(MsUnLock())
				Endif
			Endif
			
			//dbSelectArea("QSD1")
			QSD1->(dbskip())
		ENDDO
		QSD1->(DbcloseArea())

		//dbSelectArea("XF1")
		XF1->(dbskip())
	ENDDO
	
	XF1->(dbclosearea())
	
	dbSelectArea("TEM1")
	// Chamado n. Chamado  ³ 049140 || OS 050426 || ADM. || VAGNER || 8469 || REL METRAS - FWNM - 13/05/2019
	//cIndex   	:=	 "T1_PROD + T1_TABELA + T1_GRPCOM + DTOS(T1_DATA) + DESCEND(STR(T1_VLMEDIO,9,4)) + DESCEND(STR(T1_QTDADE,10,2))"
	cIndex   	:=	 "T1_PROD + T1_TABELA + T1_GRPCOM + DTOS(T1_DATA) + DESCEND(STR(T1_VLMEDIO,16,4)) + DESCEND(STR(T1_QTDADE,10,2))"
	//
	IndRegua( "TEM1", _cNomTrb, cIndex,,,"Criando Indice2 ..." )
	
	Processa({|| RunCom()},"Montando Tabelas de Referencia...")
	//RunCom()
	
return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  AQUI TERMINA O PROCESSAMENTO E COMECA A CLASSIFICACAO DO TEMP      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function RunCom()

	TEM1->(ProcRegua(RecCount()))
	TEM1->(dbGoTop())

	_cProduto	:=	""
	_cFaixa		:=	"A"
	_dData		:= ctod("  /  /  ")
	_nClass		:=	0
	_nValor		:=	0
	_nCoef2		:=	0
	_nPerce		:=	0
	_cTabCom	:=	""
	_cGRPCom	:=	""
	_nPerTab	:= 0

	nCount := 0
	DO WHILE TEM1->(!EOF())
		nCount++
		IncProc("Produtos: " + TEM1->T1_PROD +" Data "+dToC(TEM1->T1_DATA))
		////MsProcTxt("Produtos: " + TEM1->T1_PROD +" Data "+dToC(TEM1->T1_DATA) + " Regs: " + AllTrim(Str(nCount)) )

		If	_cProduto	!=	TEM1->T1_PROD .or. _dData <> TEM1->T1_DATA
			_cProduto	:=	TEM1->T1_PROD
			_dData		:= 	TEM1->T1_DATA
			_cTabCom	:=	""
			_cGRPCom	:=	""
			_nPerTab	:=  0	
		Else
			_nPos++
		Endif
		If _cTabCom	!= 	TEM1->T1_TABELA .or. _cGRPCom	!=	TEM1->T1_GRPCOM
			
			_cTabCom	:= 	TEM1->T1_TABELA
			_cGRPCom	:=	TEM1->T1_GRPCOM
			_nClass		:=	0
			_nPos		:=	1
			_nCoef2		:=	0
			_nPerTab	:=  0
			_cFaixa		:=	"A"
			
			////MsProcTxt( "Procurando tabela comissao cadastrada... " + time() )
			LETABELA(TEM1->T1_VEND, TEM1->T1_PERCTAB)					//PROCURA A TABELA DE COMISSAO CADASTRADA
			
			dbSelectArea("TEM2") 		//AQUI EU LEIO A QUANTIDADE DE VENDEDORES QUE ATUOU NESTE GRUPO DE PRODUTOS
			If 	TEM2->(!dbSeek(_cProduto+_cGRPCom+dTos(_dData)))
				MsgStop("ERRO AO LER ARQUIVO DE TRABALHO 2 - "+_cGRPCom+"-"+TEM1->T1_PROD)
				EXIT
			Endif
			_nQuant		:=	TEM2->T2_QTDADE
			_nCoef1		:=	100/_nQuant    				// para classificar o vendedor
		else
			////MsProcTxt( "Procurando tabela comissao cadastrada... " + time() )
			LETABELA(TEM1->T1_VEND, TEM1->T1_PERCTAB)					//PROCURA A TABELA DE COMISSAO CADASTRADA
		Endif
		_nCoef2		:=	INT(_nQuant * (_nPerce/100))
		_nClass		:=	_nClass	+ _nCoef1
		
		//MsProcTxt( "Alterand TEMP1... " + time() )
		dbSelectArea("TEM1")
		RecLock("TEM1",.F.)
			TEM1->T1_VLMEDIO  	        :=  TEM1->T1_FATUR/TEM1->T1_QTDADE
			TEM1->T1_TABFAIN			:=	_cFaixa
			TEM1->T1_VALFAIN     		:=	(TEM1->T1_QTDADE/1000)	*	_nValor
			TEM1->T1_CLASS				:= 	_nClass
			TEM1->T1_POSIN				:=	_nPos
		msunlock()
		// Recalculo o Preço Médio para considerar o desconto financeiro depois da devolução
		// Vou Subtrair o deconto financeito
		// Gravo valor anterior
		IF _nPos	>= _nCoef2
			_cFaixa		:=	CHR(ASC(_cFaixa)+ 1)
			LETABELA(TEM1->T1_VEND, TEM1->T1_PERCTAB)					//PROCURA A TABELA DE COMISSAO CADASTRADA
		ENDIF
		dbSelectArea("TEM1")
		TEM1->(dbskip())
	enddo
	
	dbSelectArea("TEM1")
	// Chamado n. Chamado  ³ 049140 || OS 050426 || ADM. || VAGNER || 8469 || REL METRAS - FWNM - 13/05/2019
	//cIndex   	:=	 "T1_GRUPON + T1_TABELA + T1_GRPCOM + DTOS(T1_DATA) + DESCEND(STR(T1_VLMEDIO,9,4)) + DESCEND(STR(T1_QTDADE,10,2))"
	cIndex   	:=	 "T1_GRUPON + T1_TABELA + T1_GRPCOM + DTOS(T1_DATA) + DESCEND(STR(T1_VLMEDIO,16,4)) + DESCEND(STR(T1_QTDADE,10,2))"
	//
	IndRegua( "TEM1", _cNomTrb, cIndex,,,"Criando Indice3 ..." )
	Processa({|| RunGRP()},"Montando Tabelas de Referencia PAI...")
	//RunGRP()

RETURN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ORGANIZA E TABULA AS COMISSOES POR PRODUTOS         ³
//³PAI                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
STATIC FUNCTION RUNGRP

	dbSelectArea("TEM1")
	TEM1->(ProcRegua(RecCount()))
	TEM1->(dbGoTop())
	
	nCount := 0
	
	DO WHILE TEM1->(!EOF())
		
		nCount++
		////MsProcTxt( "RunGrp: " + AllTrim(Str(nCount)) )
		
		dbSelectArea("TEM6")
		IF TEM6->(!dbSeek(TEM1->T1_GRUPON + TEM1->T1_TABELA + TEM1->T1_GRPCOM + TEM1->T1_VEND + DTOS(TEM1->T1_DATA )))
			RecLock("TEM6",.T.)
			_nQtd      	:= 	TEM1->T1_QTDADE
			_nVal      	:= 	TEM1->T1_FATUR
			_nMedio		:=	_nVal / _nQtd

			TEM6->T6_GRUPON		:=	TEM1->T1_GRUPON
			TEM6->T6_VEND  		:= 	TEM1->T1_VEND
			TEM6->T6_GRPCOM		:=	TEM1->T1_GRPCOM
			TEM6->T6_DATA		:= 	TEM1->T1_DATA
			TEM6->T6_QTDADE  	:= 	TEM1->T1_QTDADE
			TEM6->T6_FATUR		:=	TEM1->T1_FATUR
			TEM6->T6_TABELA		:=	TEM1->T1_TABELA
			TEM6->T6_PERCTAB	:=	TEM1->T1_PERCTAB
			TEM6->T6_VLMEDIO  	:=	_nMedio
			TEM6->T6_SUPER		:=	TEM1->T1_SUPER
			TEM6->T6_REGIAO		:=	TEM1->T1_REGIAO
			TEM6->T6_NOMSUP		:=	TEM1->T1_NOMSUP
			TEM6->T6_NOMREG		:=	TEM1->T1_NOMREG
			TEM6->T6_NOMVEND	:=	TEM1->T1_NOMVEND
			TEM6->T6_NOMEGN		:=	TEM1->T1_NOMEGN
			//		TEM6->T6_DESFIN		:=	TEM1->T1_DESFIN
			
			MsUnLock()
		Else
			RecLock("TEM6",.F.)
				_nQtd      	:= 	TEM6->T6_QTDADE + TEM1->T1_QTDADE
				_nVal      	:= 	TEM6->T6_FATUR	+ TEM1->T1_FATUR
				_nMedio		:=	_nVal / _nQtd
				
				TEM6->T6_QTDADE  	:= 	_nQtd
				TEM6->T6_FATUR    	:= 	_nVal
				TEM6->T6_VLMEDIO  	:=	_nMedio
			MsUnLock()
		Endif

		dbSelectArea("TEM1")
		TEM1->(dbskip())
	Enddo
	dbSelectArea("TEM6")
	// Chamado n. Chamado  ³ 049140 || OS 050426 || ADM. || VAGNER || 8469 || REL METRAS - FWNM - 13/05/2019
	//cIndex   	:=	 "T6_GRUPON + T6_TABELA + T6_GRPCOM + DTOS(T6_DATA) + DESCEND(STR(T6_VLMEDIO,9,4))+ DESCEND(STR(T6_QTDADE,10,2))"
	cIndex   	:=	 "T6_GRUPON + T6_TABELA + T6_GRPCOM + DTOS(T6_DATA) + DESCEND(STR(T6_VLMEDIO,16,4))+ DESCEND(STR(T6_QTDADE,10,2))"
	//
	IndRegua( "TEM6", _cNomTr6, cIndex,,,"Criando Indice 2 ..." )
	
	_cGrupoN	:=	""
	_cFaixa		:=	"A"
	_dData		:= ctod("  /  /  ")
	_nClass		:=	0
	_nPos		:=	0
	_cTabCom	:= 	""
	_cGRPCom	:=	""
	_nPerce		:=	0
	_cTabVen	:=	""
	_nValor		:=	0
	
	nCount:=0
	DO WHILE TEM6->(!EOF())
		
		nCount++
		
		If	_cGrupoN	<>	TEM6->T6_GRUPON .or. _dData <> TEM6->T6_DATA
			_cGrupoN	:=	TEM6->T6_GRUPON
			_dData		:= 	TEM6->T6_DATA
			_cTabCom	:=	""
			_cGRPCom	:=	""
		Else
			_nPos++
		Endif
		
		IncProc("Grupo de Produtos: " + TEM6->T6_GRUPON)
		
		If _cTabCom	!= 	TEM6->T6_TABELA	.or. _cGRPCom	!=	TEM6->T6_GRPCOM
			_cTabCom	:= 	TEM6->T6_TABELA
			_cGRPCom	:=	TEM6->T6_GRPCOM
			_nClass		:=	0
			_nCoef2		:=	0
			_nPos		:=	1
			_cFaixa		:=	"A"
			LETABELA(TEM6->T6_VEND, TEM6->T6_PERCTAB)					//PROCURA A TABELA DE COMISSAO CADASTRADA
			dbSelectArea("TEM4") 		//AQUI EU LEIO A QUANTIDADE DE VENDEDORES QUE ATUOU NESTE GRUPO DE PRODUTOS
			If 	TEM4->(!dbSeek(_cGrupoN+_cTabCom+_cGRPCom+dtos(_dData)))
				MsgStop("ERRO AO LER ARQUIVO DE TRABALHO 2"+_cGrupoN+_cTabCom+_cGRPCom)
				EXIT
			Endif
			_nQVend		:=	TEM4->T4_QTDADE
			_nCoef1		:=	100/_nQVend    				// para classificar o vendedor
		else
			LETABELA(TEM6->T6_VEND, TEM6->T6_PERCTAB)					//PROCURA A TABELA DE COMISSAO CADASTRADA
		Endif
		
		_nCoef2		:=	INT(_nQVend * (_nPerce/100))
		_nClass		:=	_nClass	+ _nCoef1
		
		dbSelectArea("TEM6")
		RecLock("TEM6",.F.)
			TEM6->T6_CLASS				:=	_nClass
			TEM6->T6_POSIP				:=	_nPos
			TEM6->T6_TABFAIP			:=	_cFaixa
			TEM6->T6_VLFAI				:=	_nValor	
		msunlock()

		If _nPos	>= _nCoef2
			_cFaixa		:=	CHR(ASC(_cFaixa)+ 1)
			LETABELA(TEM6->T6_VEND, TEM6->T6_PERCTAB)					//PROCURA A TABELA DE COMISSAO CADASTRADA
		Endif

		dbSelectArea("TEM6")
		TEM6->(dbskip())
		
	enddo
	//³ mv_par12             // Demonstrativo de Vendas por Vendedor         ³
	//³ mv_par13             // Demonstrativo de Vendas por Grupo de Produto ³
	//³ mv_par14             // Demonstrativo de Vendas Vendedor x Produto   ³
	
	If mv_par12	== 1
		Titulo += " - "+iif(mv_par15=1,"Analitico","Sintetico")
		RptStatus({|| iif(mv_par16=1,AD0012EX(),AD0012A()) },Titulo)
	Endif

	If mv_par13	== 1
		Processa({|| AD0012B()},"Gerando Demonstrativo de Vendas por Grupo de Produto ...")
	Endif
	If mv_par14	== 1
		Processa({|| AD0012C()},"Gerando Demonstrativo de Vendas Regiaor x Produto ...")
	Endif

	TEM1->(dbclosearea())
	TEM2->(dbclosearea())
	TEM3->(dbclosearea())
	TEM4->(dbclosearea())
	TEM5->(dbclosearea())
	TEM6->(dbclosearea())
	fErase(_cNomTrb+'.*')
	fErase(_cNomTr2+'.*')
	fErase(_cNomTr3+'.*')
	fErase(_cNomTr4+'.*')
	fErase(_cNomTr5+'.*')
	fErase(_cNomTr6+'.*')

Return


Static function fCarSZA()

	Local cQuery := ""
	
	cQuery := " SELECT ZA_FILIAL, ZA_CODTAB, ZA_TABELA, ZA_FAIXA, ZA_PERCATE, ZA_VLFAIXA "
	cQuery += " FROM "+Retsqlname("SZA")+" ZA "
	cQuery += " WHERE D_E_L_E_T_='' AND ZA_FILIAL='02' "
	cQuery += " ORDER BY ZA_CODTAB, ZA_TABELA, ZA_FAIXA; "

	TcQuery cQuery ALIAS "QSZA" NEW

	While QSZA->(!eof())
		oTabSZA:set(QSZA->ZA_FILIAL+QSZA->ZA_CODTAB+QSZA->ZA_TABELA+QSZA->ZA_FAIXA, {QSZA->ZA_PERCATE, QSZA->ZA_FAIXA, QSZA->ZA_VLFAIXA})
		qsza->(dbskip())
	ENDDO
	
	qsza->(Dbclosearea())
	
return



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ESTA ROTINA BUSCA A TABELA DE COMISSAO CADASTRADA   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
STATIC FUNCTION LETABELA(_cVendedor, _nPercTab)
	
	//Local _nPerTab := Posicione("SA3",1,xFilial("SA3")+_cVendedor,"A3_PERCTAB") //incluido por Adriana em 05/10/10 para atender chamado 008059
	Local _nPerxTab	:= _nPercTab
	Local aVlrRet		:= {}

	//_nPerTab := Val(_nPerTab)
	_nPerTab := iif(_nPerxTab > 0, _nPerxTab / 100, 1)                            //busca percetual para calculo da comissao
	
	if oTabSZA:Get("02"+_cTabcom+_cGRPCom+_cFaixa,@aVlrRet)
		_nPerce		:=	aVlrRet[1]
		_cTabVen	:=	aVlrRet[2]
		_nValor		:=	aVlrRet[3] * _nPerTab //incluido percentual da tabela de comissao por Adriana em 05/10/10 para atender chamado 008059
	else
		_nPerce		:=	0
		_cTabVen	:=	""
		_nValor		:=	0	
	Endif

RETURN


STATIC FUNCTION AD0012A
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se deve comprimir ou nao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTipo   := IIF(aReturn[4]==1,15,18)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Prepara o cabecalho padrao para o relatorio DEMONSTRATIVO DE VENDA VENDEDOR           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*
	|_______________________________________________________________________________________________________________________________________________________________________________________________________________________________|
	|Vendedor: 999999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXX                                                                                                                                                                                |
	|_______________________________________________________________________________________________________________________________________________________________________________________________________________________________|
	| 9999  XXXXXXXXXXXXXXXXXXXX    | 9999  XXXXXXXXXXXXXXXXXXXX    | 9999  XXXXXXXXXXXXXXXXXXXX    | 9999  XXXXXXXXXXXXXXXXXXXX    | 9999  XXXXXXXXXXXXXXXXXXXX    | 9999  XXXXXXXXXXXXXXXXXXXX    | 9999  XXXXXXXXXXXXXXXXXXXX    |
	|  Qtd   | R$/KG  |Tab|   V.R   |  Qtd   | R$/KG  |Tab|   V.R   |  Qtd   | R$/KG  |Tab|   V.R   |  Qtd   | R$/KG  |Tab|   V.R   |  Qtd   | R$/KG  |Tab|   V.R   |  Qtd   | R$/KG  |Tab|   V.R   |  Qtd   | R$/KG  |Tab|   V.R   |
	|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
	| 999999 | 99,999 | X | 9999,99 | 999999 | 99,999 | X | 9999,99 | 999999 | 99,999 | X | 9999,99 | 999999 | 99,999 | X | 9999,99 | 999999 | 99,999 | X | 9999,99 | 999999 | 99,999 | X | 9999,99 | 999999 | 99,999 | X | 9999,99 |
	|===============================================================================================================================================================================================================================|
	| 9999  XXXXXXXXXXXXXXXXXXXX    | 9999  XXXXXXXXXXXXXXXXXXXX    | 9999  XXXXXXXXXXXXXXXXXXXX    | 9999  XXXXXXXXXXXXXXXXXXXX    | 9999  XXXXXXXXXXXXXXXXXXXX    | 9999  XXXXXXXXXXXXXXXXXXXX    | 9999  XXXXXXXXXXXXXXXXXXXX    |
	|  Qtd   | R$/KG  |Tab|   V.R   |  Qtd   | R$/KG  |Tab|   V.R   |  Qtd   | R$/KG  |Tab|   V.R   |  Qtd   | R$/KG  |Tab|   V.R   |  Qtd   | R$/KG  |Tab|   V.R   |  Qtd   | R$/KG  |Tab|   V.R   |  Qtd   | R$/KG  |Tab|   V.R   |
	|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
	| 999999 | 99,999 | X | 9999,99 | 999999 | 99,999 | X | 9999,99 | 999999 | 99,999 | X | 9999,99 | 999999 | 99,999 | X | 9999,99 | 999999 | 99,999 | X | 9999,99 | 999999 | 99,999 | X | 9999,99 | 999999 | 99,999 | X | 9999,99 |
	|===============================================================================================================================================================================================================================|
	| 9999  XXXXXXXXXXXXXXXXXXXX    | 9999  XXXXXXXXXXXXXXXXXXXX    | 9999  XXXXXXXXXXXXXXXXXXXX    | 9999  XXXXXXXXXXXXXXXXXXXX    | 9999  XXXXXXXXXXXXXXXXXXXX    | 9999  XXXXXXXXXXXXXXXXXXXX    | 9999  XXXXXXXXXXXXXXXXXXXX    |
	|  Qtd   | R$/KG  |Tab|   V.R   |  Qtd   | R$/KG  |Tab|   V.R   |  Qtd   | R$/KG  |Tab|   V.R   |  Qtd   | R$/KG  |Tab|   V.R   |  Qtd   | R$/KG  |Tab|   V.R   |  Qtd   | R$/KG  |Tab|   V.R   |  Qtd   | R$/KG  |Tab|   V.R   |
	|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
	| 999999 | 99,999 | X | 9999,99 | 999999 | 99,999 | X | 9999,99 | 999999 | 99,999 | X | 9999,99 | 999999 | 99,999 | X | 9999,99 | 999999 | 99,999 | X | 9999,99 | 999999 | 99,999 | X | 9999,99 | 999999 | 99,999 | X | 9999,99 |
	|===============================================================================================================================================================================================================================|
	|Grupo |   Vlr    | Tonelag |Grupo |   Vlr    | Tonelag |Grupo |   Vlr    | Tonelag |Grupo |   Vlr    | Tonelag |Grupo |   Vlr    | Tonelag |Grupo |   Vlr    | Tonelag |Grupo |   Vlr    | Tonelag |Grupo |   Vlr    | Tonelag |
	|Prod  |Referencia|  Total  |Prod  |Referencia|  Total  |Prod  |Referencia|  Total  |Prod  |Referencia|  Total  |Prod  |Referencia|  Total  |Prod  |Referencia|  Total  |Prod  |Referencia|  Total  |Prod  |Referencia|  Total  |
	|------+----------+---------|------+----------+---------|------+----------+---------|------+----------+---------|------+----------+---------|------+----------+---------|------+----------+---------|------+----------+---------|
	| 9999 | 99,999.99| 9999,999| 9999 | 99,999.99| 9999,999| 9999 | 99,999.99| 9999,999| 9999 | 99,999.99| 9999,999| 9999 | 99,999.99| 9999,999| 9999 | 99,999.99| 9999,999| 9999 | 99,999.99| 9999,999| 9999 | 99,999.99| 9999,999|
	| 9999 | 99,999.99| 9999,999| 9999 | 99,999.99| 9999,999| 9999 | 99,999.99| 9999,999| 9999 | 99,999.99| 9999,999| 9999 | 99,999.99| 9999,999| 9999 | 99,999.99| 9999,999| 9999 | 99,999.99| 9999,999| 9999 | 99,999.99| 9999,999|
	| 9999 | 99,999.99| 9999,999| 9999 | 99,999.99| 9999,999| 9999 | 99,999.99| 9999,999| 9999 | 99,999.99| 9999,999| 9999 | 99,999.99| 9999,999| 9999 | 99,999.99| 9999,999| 9999 | 99,999.99| 9999,999| 9999 | 99,999.99| 9999,999|
	|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
	0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234
	*/

	cabec02	:=	"+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	cabec04	:=	"| COD VEND /       NOME                                                                      |            |            | Posicao/ |    Valor     |    Peso    |         |   Valor     |    Valor    |   Valor      |"
	cabec05	:=	"|   GRUPO /        DESCR                                                                     |Dt. Faturam.| Prec Medio | Tabela   |   Faturado   |  Faturado  | Classif.|Prêmio s/ DSR|     DSR     | Prêmio Total |"
	cabec06	:=	"|-------------------------------------------------------------------------------------------- ------------ ------------ ---------- -------------- ------------ --------- ------------- ------------- --------------|"
	cabec07	:=	"|                                                                                             |            |            |          |              |            |         |             |            |              |"


	dbSelectArea("TEM6")
	
	If mv_par05	== 1		// ordem por supervisor
		cIndex   	:=	 "T6_SUPER + T6_VEND + T6_GRUPON + DTOS(T6_DATA)"
		IndRegua( "TEM6", _cNomTr6, cIndex,,,"Criando Indice3 ..." )
		Cabec2	:=	"Supervisor: " + TEM6->T6_SUPER+ " - " + TEM6->T6_NOMSUP
	else 					// ordem por regiao
		cIndex   	:=	 "T6_REGIAO + T6_VEND + T6_GRUPON + DTOS(T6_DATA)"
		IndRegua( "TEM6", _cNomTr6, cIndex,,,"Criando Indice3 ..." )
		Cabec2	:=	"Regiao: " + 	TEM6->T6_REGIAO+ " - " + TEM6->T6_NOMREG
	Endif
	
	SetRegua(RecCount())
	dbGoTop()
	Cabec1 := "Periodo de : "+dtoc(mv_par01)+" Ate : "+dtoc(mv_par02)
	Cabec1	:= space(61-(len(Cabec1)/2)) + Cabec1
	_cVend	:=	""
	_cSuper		:=	TEM6->T6_SUPER
	_cRegiao	:=	TEM6->T6_REGIAO
	_xVez		:=	.F.
	_nTVFat		:=	0
	_nTQFat		:=	0
	_nTCFat		:=	0
	_nTCsDSR	:=  0
	_nTCcDSR	:=  0
	_xQuebra	:=	.F.
	_cGRUPON 	:= "X99"
	_nTFaturado :=  0
	_nTPeso 	:=  0
	_nTComiss 	:=  0
	_nTComCDSR	:=  0
	_nTComSDSR	:=  0
	_cNomVen	:=	""
	
	While !EOF()
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ESTA ROTINA VALIDA OS PARAMETROS DO SUPERVISOR E REGIAODE MERCADO  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If	!_bFlagVend
			If _cCodVen != TEM6->T6_VEND .and. !empty(_cCodVen)
				dbSelectArea("TEM6")
				dbskip()
				Loop
			Endif
			If 	!TEM6->T6_VEND$_cSupVends .and. !empty(_cSupVends)
				dbSelectArea("TEM6")
				dbskip()
				Loop
			Endif
		Endif
		
		If nLin > 72 .or. _xQuebra
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
			Cabeca2()
			if !Empty(_cVend)
				@nLin,000 PSAY "|"
				@nLin,003 PSAY _cVend
				@nLin,012 PSAY _cNomVen
				@nlin,nCol13 PSAY "|"
				nLin++
				@nLin,000 PSAY  cabec06
				nLin ++
			endif
			_xQuebra	:=	.F.
		Endif
		   
		_cNomVen	:=		LEFT(TEM6->T6_NOMVEND,25)
		
		If mv_par05			== 1 .and. _cSuper	!=	TEM6->T6_SUPER
			_cSuper		:=	TEM6->T6_SUPER
			Cabec2	:=	"Supervisor: " + TEM6->T6_SUPER + " - " + TEM6->T6_NOMSUP
			_cVend	:=	""
			_xQuebra	:=	.T.
		ElseIf	mv_par05	== 2 .and. _cRegiao	!=	TEM6->T6_REGIAO
			_cRegiao	:=	TEM6->T6_REGIAO
			Cabec2	:=	"Regiao: " + 	TEM6->T6_REGIAO+ " - " + TEM6->T6_NOMREG
			_cVend	:=	""
			_xQuebra	:=	.T.
		Endif
			
		If	_cVend	!=	TEM6->T6_VEND				// FAZ A QUEBRA DO VENDEDOR
			If	_xVez			   					// IMPRIME O TOTAL DO VENDEDOR SOMENTE QUANDO NAO É A PRIMEIRA VEZ
				if mv_par15 = 1
					@nlin,000 PSAY "|"
				endif

				@nlin,nCol04 PSAY "|"
				@nlin,nCol04+3 PSAY "TOTAL"
				@nlin,nCol05 PSAY "|"
				@nlin,nCol05+5 PSAY (_nTFaturado/_nTPeso)	PICTURE "@E 99.9999" //Incluido por Adriana HC, para atender chamado 008155 - 19/10/10
				@nlin,nCol06 PSAY "|"
				@nlin,nCol07 PSAY "|"
				@nlin,nCol07+1 PSAY _nTFaturado		PICTURE "@E 99,999,999.99"
				@nlin,nCol08 PSAY "|"
				@nlin,nCol08+1 PSAY _nTPeso			PICTURE "@E 9999,999.99"
				@nlin,nCol09 PSAY "|"
				@nlin,nCol10 PSAY "|"
				@nlin,nCol10+2 PSAY _nTComSDSR		PICTURE "@E 999,999.99"
				@nlin,nCol11 PSAY "|"
				@nlin,nCol11+2 PSAY _nTComCDSR		PICTURE "@E 999,999.99"
				@nlin,nCol12 PSAY "|"
				@nlin,nCol12+2 PSAY _nTComiss		PICTURE "@E 999,999.99"
				@nlin,nCol13 PSAY  "|"

				nLin ++
				@nLin,000 PSAY	cabec02
				nLin := nLin + 1
				nLin := nLin + 1
				@nLin,000 PSAY	cabec02
				nLin := nLin + 1
				@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome1))
				@nlin,nCol07 PSAY "|"
				@nlin,nCol07+1 PSAY Transform(_Grp1Sms,"@E 99,999,999.99")
				@nlin,nCol08 PSAY "|"
				@nlin,nCol08+1 PSAY Transform(_Grp1Pes,"@E 9999,999.99")
				@nlin,nCol09 PSAY "|"
				@nlin,nCol09+2 PSAY ((_Grp1Pes/_nTQFat)*100) picture "@E 999.99%"
				@nlin,nCol10 PSAY "|"
				@nlin,nCol10+2 PSAY Transform(_Grp1sDSR ,"@E 9999,999.99")
				@nlin,nCol11 PSAY "|"
				@nlin,nCol11+2 PSAY Transform(_Grp1cDSR,"@E 9999,999.99")
				@nlin,nCol12 PSAY "|"
				@nlin,nCol12+2 PSAY Transform(_Grp1Css,"@E 999,999.99")
				@nlin,nCol13 PSAY  "|"

				nLin := nLin + 1
				@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome2))
				@nlin,nCol07 PSAY "|"
				@nlin,nCol07+1 PSAY Transform(_Grp2Sms,"@E 99,999,999.99")
				@nlin,nCol08 PSAY "|"
				@nlin,nCol08+1 PSAY Transform(_Grp2Pes,"@E 9999,999.99")
				@nlin,nCol09 PSAY "|"
				@nlin,nCol09+2 PSAY ((_Grp2Pes/_nTQFat)*100) picture "@E 999.99%"
				@nlin,nCol10 PSAY "|"
				@nlin,nCol10+2 PSAY Transform(_Grp2sDSR ,"@E 9999,999.99")
				@nlin,nCol11 PSAY "|"
				@nlin,nCol11+2 PSAY Transform(_Grp2cDSR,"@E 9999,999.99")
				@nlin,nCol12 PSAY "|"
				@nlin,nCol12+2 PSAY Transform(_Grp2Css,"@E 999,999.99")
				@nlin,nCol13 PSAY  "|"

				nLin := nLin + 1
				@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome3))
				@nlin,nCol07 PSAY "|"
				@nlin,nCol07+1 PSAY Transform(_Grp3Sms,"@E 99,999,999.99")
				@nlin,nCol08 PSAY "|"
				@nlin,nCol08+1 PSAY Transform(_Grp3Pes,"@E 9999,999.99")
				@nlin,nCol09 PSAY "|"
				@nlin,nCol09+2 PSAY ((_Grp3Pes/_nTQFat)*100) picture "@E 999.99%"
				@nlin,nCol10 PSAY "|"
				@nlin,nCol10+2 PSAY Transform(_Grp3sDSR ,"@E 9999,999.99")
				@nlin,nCol11 PSAY "|"
				@nlin,nCol11+2 PSAY Transform(_Grp3cDSR,"@E 9999,999.99")
				@nlin,nCol12 PSAY "|"
				@nlin,nCol12+2 PSAY Transform(_Grp3Css,"@E 999,999.99")
				@nlin,nCol13 PSAY  "|"

				nLin := nLin + 1
				@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome4))
				@nlin,nCol07 PSAY "|"
				@nlin,nCol07+1 PSAY Transform(_Grp4Sms,"@E 99,999,999.99")
				@nlin,nCol08 PSAY "|"
				@nlin,nCol08+1 PSAY Transform(_Grp4Pes,"@E 9999,999.99")
				@nlin,nCol09 PSAY "|"
				@nlin,nCol09+2 PSAY ((_Grp4Pes/_nTQFat)*100) picture "@E 999.99%"
				@nlin,nCol10 PSAY "|"
				@nlin,nCol10+2 PSAY Transform(_Grp4sDSR ,"@E 9999,999.99")
				@nlin,nCol11 PSAY "|"
				@nlin,nCol11+2 PSAY Transform(_Grp4cDSR,"@E 9999,999.99")
				@nlin,nCol12 PSAY "|"
				@nlin,nCol12+2 PSAY Transform(_Grp4Css,"@E 999,999.99")
				@nlin,nCol13 PSAY  "|"

				nLin := nLin + 1
				@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome5))
				@nlin,nCol07 PSAY "|"
				@nlin,nCol07+1 PSAY Transform(_Grp6Sms,"@E 99,999,999.99")
				@nlin,nCol08 PSAY "|"
				@nlin,nCol08+1 PSAY Transform(_Grp6Pes,"@E 9999,999.99")
				@nlin,nCol09 PSAY "|"
				@nlin,nCol09+2 PSAY ((_Grp6Pes/_nTQFat)*100) picture "@E 999.99%"
				@nlin,nCol10 PSAY "|"
				@nlin,nCol10+2 PSAY Transform(_Grp6sDSR ,"@E 9999,999.99")
				@nlin,nCol11 PSAY "|"
				@nlin,nCol11+2 PSAY Transform(_Grp6cDSR,"@E 9999,999.99")
				@nlin,nCol12 PSAY "|"
				@nlin,nCol12+2 PSAY Transform(_Grp6Css,"@E 999,999.99")
				@nlin,nCol13 PSAY  "|"

				nLin := nLin + 1
				@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome6))
				@nlin,nCol07 PSAY "|"
				@nlin,nCol07+1 PSAY Transform(_Grp7Sms,"@E 99,999,999.99")
				@nlin,nCol08 PSAY "|"
				@nlin,nCol08+1 PSAY Transform(_Grp7Pes,"@E 9999,999.99")
				@nlin,nCol09 PSAY "|"
				@nlin,nCol09+2 PSAY ((_Grp7Pes/_nTQFat)*100) picture "@E 999.99%"
				@nlin,nCol10 PSAY "|"
				@nlin,nCol10+2 PSAY Transform(_Grp7sDSR ,"@E 9999,999.99")
				@nlin,nCol11 PSAY "|"
				@nlin,nCol11+2 PSAY Transform(_Grp7cDSR,"@E 9999,999.99")
				@nlin,nCol12 PSAY "|"
				@nlin,nCol12+2 PSAY Transform(_Grp7Css,"@E 999,999.99")
				@nlin,nCol13 PSAY  "|"

				//Everson - 19/05/2021. Chamado 14094.

				nLin := nLin + 1
				@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome7))
				@nlin,nCol07 PSAY "|"
				@nlin,nCol07+1 PSAY Transform(_Grp8Sms,"@E 99,999,999.99")
				@nlin,nCol08 PSAY "|"
				@nlin,nCol08+1 PSAY Transform(_Grp8Pes,"@E 9999,999.99")
				@nlin,nCol09 PSAY "|"
				@nlin,nCol09+2 PSAY ((_Grp8Pes/_nTQFat)*100) picture "@E 999.99%"
				@nlin,nCol10 PSAY "|"
				@nlin,nCol10+2 PSAY Transform(_Grp8sDSR ,"@E 9999,999.99")
				@nlin,nCol11 PSAY "|"
				@nlin,nCol11+2 PSAY Transform(_Grp8cDSR,"@E 9999,999.99")
				@nlin,nCol12 PSAY "|"
				@nlin,nCol12+2 PSAY Transform(_Grp8Css,"@E 999,999.99")
				@nlin,nCol13 PSAY  "|"

				nLin := nLin + 1
				@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome8))
				@nlin,nCol07 PSAY "|"
				@nlin,nCol07+1 PSAY Transform(_Grp9Sms,"@E 99,999,999.99")
				@nlin,nCol08 PSAY "|"
				@nlin,nCol08+1 PSAY Transform(_Grp9Pes,"@E 9999,999.99")
				@nlin,nCol09 PSAY "|"
				@nlin,nCol09+2 PSAY ((_Grp9Pes/_nTQFat)*100) picture "@E 999.99%"
				@nlin,nCol10 PSAY "|"
				@nlin,nCol10+2 PSAY Transform(_Grp9sDSR ,"@E 9999,999.99")
				@nlin,nCol11 PSAY "|"
				@nlin,nCol11+2 PSAY Transform(_Grp9cDSR,"@E 9999,999.99")
				@nlin,nCol12 PSAY "|"
				@nlin,nCol12+2 PSAY Transform(_Grp9Css,"@E 999,999.99")
				@nlin,nCol13 PSAY  "|"

				nLin := nLin + 1
				@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome9))
				@nlin,nCol07 PSAY "|"
				@nlin,nCol07+1 PSAY Transform(_Grp10Sms,"@E 99,999,999.99")
				@nlin,nCol08 PSAY "|"
				@nlin,nCol08+1 PSAY Transform(_Grp10Pes,"@E 9999,999.99")
				@nlin,nCol09 PSAY "|"
				@nlin,nCol09+2 PSAY ((_Grp10Pes/_nTQFat)*100) picture "@E 999.99%"
				@nlin,nCol10 PSAY "|"
				@nlin,nCol10+2 PSAY Transform(_Grp10sDSR ,"@E 9999,999.99")
				@nlin,nCol11 PSAY "|"
				@nlin,nCol11+2 PSAY Transform(_Grp10cDSR,"@E 9999,999.99")
				@nlin,nCol12 PSAY "|"
				@nlin,nCol12+2 PSAY Transform(_Grp10Css,"@E 999,999.99")
				@nlin,nCol13 PSAY  "|"

				nLin := nLin + 1
				@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome10))
				@nlin,nCol07 PSAY "|"
				@nlin,nCol07+1 PSAY Transform(_Grp11Sms,"@E 99,999,999.99")
				@nlin,nCol08 PSAY "|"
				@nlin,nCol08+1 PSAY Transform(_Grp11Pes,"@E 9999,999.99")
				@nlin,nCol09 PSAY "|"
				@nlin,nCol09+2 PSAY ((_Grp11Pes/_nTQFat)*100) picture "@E 999.99%"
				@nlin,nCol10 PSAY "|"
				@nlin,nCol10+2 PSAY Transform(_Grp11sDSR ,"@E 9999,999.99")
				@nlin,nCol11 PSAY "|"
				@nlin,nCol11+2 PSAY Transform(_Grp11cDSR,"@E 9999,999.99")
				@nlin,nCol12 PSAY "|"
				@nlin,nCol12+2 PSAY Transform(_Grp11Css,"@E 999,999.99")
				@nlin,nCol13 PSAY  "|"

				nLin := nLin + 1
				@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome11))
				@nlin,nCol07 PSAY "|"
				@nlin,nCol07+1 PSAY Transform(_Grp12Sms,"@E 99,999,999.99")
				@nlin,nCol08 PSAY "|"
				@nlin,nCol08+1 PSAY Transform(_Grp12Pes,"@E 9999,999.99")
				@nlin,nCol09 PSAY "|"
				@nlin,nCol09+2 PSAY ((_Grp12Pes/_nTQFat)*100) picture "@E 999.99%"
				@nlin,nCol10 PSAY "|"
				@nlin,nCol10+2 PSAY Transform(_Grp12sDSR ,"@E 9999,999.99")
				@nlin,nCol11 PSAY "|"
				@nlin,nCol11+2 PSAY Transform(_Grp12cDSR,"@E 9999,999.99")
				@nlin,nCol12 PSAY "|"
				@nlin,nCol12+2 PSAY Transform(_Grp12Css,"@E 999,999.99")
				@nlin,nCol13 PSAY  "|"

				nLin := nLin + 1
				@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome12))
				@nlin,nCol07 PSAY "|"
				@nlin,nCol07+1 PSAY Transform(_Grp13Sms,"@E 99,999,999.99")
				@nlin,nCol08 PSAY "|"
				@nlin,nCol08+1 PSAY Transform(_Grp13Pes,"@E 9999,999.99")
				@nlin,nCol09 PSAY "|"
				@nlin,nCol09+2 PSAY ((_Grp13Pes/_nTQFat)*100) picture "@E 999.99%"
				@nlin,nCol10 PSAY "|"
				@nlin,nCol10+2 PSAY Transform(_Grp13sDSR ,"@E 9999,999.99")
				@nlin,nCol11 PSAY "|"
				@nlin,nCol11+2 PSAY Transform(_Grp13cDSR,"@E 9999,999.99")
				@nlin,nCol12 PSAY "|"
				@nlin,nCol12+2 PSAY Transform(_Grp13Css,"@E 999,999.99")
				@nlin,nCol13 PSAY  "|"

				nLin := nLin + 1
				@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome13))
				@nlin,nCol07 PSAY "|"
				@nlin,nCol07+1 PSAY Transform(_Grp14Sms,"@E 99,999,999.99")
				@nlin,nCol08 PSAY "|"
				@nlin,nCol08+1 PSAY Transform(_Grp14Pes,"@E 9999,999.99")
				@nlin,nCol09 PSAY "|"
				@nlin,nCol09+2 PSAY ((_Grp14Pes/_nTQFat)*100) picture "@E 999.99%"
				@nlin,nCol10 PSAY "|"
				@nlin,nCol10+2 PSAY Transform(_Grp14sDSR ,"@E 9999,999.99")
				@nlin,nCol11 PSAY "|"
				@nlin,nCol11+2 PSAY Transform(_Grp14cDSR,"@E 9999,999.99")
				@nlin,nCol12 PSAY "|"
				@nlin,nCol12+2 PSAY Transform(_Grp14Css,"@E 999,999.99")
				@nlin,nCol13 PSAY  "|"
				
				nLin := nLin + 1
				@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome14))
				@nlin,nCol07 PSAY "|"
				@nlin,nCol07+1 PSAY Transform(_Grp15Sms,"@E 99,999,999.99")
				@nlin,nCol08 PSAY "|"
				@nlin,nCol08+1 PSAY Transform(_Grp15Pes,"@E 9999,999.99")
				@nlin,nCol09 PSAY "|"
				@nlin,nCol09+2 PSAY ((_Grp15Pes/_nTQFat)*100) picture "@E 999.99%"
				@nlin,nCol10 PSAY "|"
				@nlin,nCol10+2 PSAY Transform(_Grp15sDSR ,"@E 9999,999.99")
				@nlin,nCol11 PSAY "|"
				@nlin,nCol11+2 PSAY Transform(_Grp15cDSR,"@E 9999,999.99")
				@nlin,nCol12 PSAY "|"
				@nlin,nCol12+2 PSAY Transform(_Grp15Css,"@E 999,999.99")
				@nlin,nCol13 PSAY  "|"
				//

				nLin := nLin + 1	
				@nlin,000 PSAY "|Outros Grupos: "
				@nlin,nCol07 PSAY "|"
				@nlin,nCol07+1 PSAY Transform(_Grp5Sms,"@E 99,999,999.99")
				@nlin,nCol08 PSAY "|"
				@nlin,nCol08+1 PSAY Transform(_Grp5Pes,"@E 9999,999.99")
				@nlin,nCol09 PSAY "|"
				@nlin,nCol09+2 PSAY ((_Grp5Pes/_nTQFat)*100) picture "@E 999.99%"
				@nlin,nCol10 PSAY "|"
				@nlin,nCol10+2 PSAY Transform(_Grp5sDSR ,"@E 9999,999.99")
				@nlin,nCol11 PSAY "|"
				@nlin,nCol11+2 PSAY Transform(_Grp5cDSR,"@E 9999,999.99")
				@nlin,nCol12 PSAY "|"
				@nlin,nCol12+2 PSAY Transform(_Grp5Css,"@E 999,999.99")
				@nlin,nCol13 PSAY  "|"
				nLin := nLin + 1
				
				@nLin,000 PSAY	"|-------------------------------------------------------------------------------------------- ------------ ------------ ---------- -------------- ------------ --------- ------------- ------------- --------------|"
								 
				nLin := nLin + 1
				
				@nLin,000 PSAY 	"|Total  Sub-Regiao"
				@nlin,nCol07 PSAY "|"
				@nlin,nCol07+1 PSAY	_nTVFat	PICTURE "@E 99,999,999.99"
				@nlin,nCol08 PSAY "|"
				@nlin,nCol08+1 PSAY	_nTQFat	PICTURE "@E 9999,999.99"
				@nlin,nCol09 PSAY "|"
				@nlin,nCol10+2 PSAY Transform(_nTCsDSR ,"@E 9999,999.99")
				@nlin,nCol11 PSAY "|"
				@nlin,nCol11+2 PSAY Transform(_nTCcDSR,"@E 9999,999.99")
				@nlin,nCol11 PSAY "|"
				@nlin,nCol12 PSAY "|"
				@nlin,nCol12+2 PSAY	_nTCFat	PICTURE "@E 999,999.99"
				@nlin,nCol13 PSAY  "|"
				nLin := nLin + 1
				
				@nLin,000 PSAY	cabec02
				nLin := nLin + 1
				
				fAtuTot()		&& Funcao para acumular os subtotais calculados.
				
				_nTVFat		:=	0
				_nTQFat		:=	0
				_nTCFat		:=	0
				_nTCsDSR	:=  0
				_nTCcDSR	:=  0

				_Grp1Sms:=0
				_Grp2Sms:=0
				_Grp3Sms:=0
				_Grp4Sms:=0
				_Grp5Sms:=0
				_Grp6Sms:=0
				_Grp7Sms:=0

				//Everson - 19/05/2021. Chamado 14094.
				_Grp8Sms	:=0 
				_Grp9Sms	:=0 
				_Grp10Sms	:=0
				_Grp11Sms	:=0
				_Grp12Sms	:=0
				_Grp13Sms	:=0
				_Grp14Sms	:=0
				_Grp15Sms	:=0
				//

				_Grp1Pes:=0
				_Grp2Pes:=0
				_Grp3Pes:=0
				_Grp4Pes:=0
				_Grp5Pes:=0
				_Grp6Pes:=0
				_Grp7Pes:=0

				//Everson - 19/05/2021. Chamado 14094.
				_Grp8Pes	:=0
				_Grp9Pes	:=0
				_Grp10Pes	:=0
				_Grp11Pes	:=0
				_Grp12Pes	:=0
				_Grp13Pes	:=0
				_Grp14Pes	:=0
				_Grp15Pes	:=0
				//
				
				_Grp1Css	:=0
				_Grp2Css	:=0
				_Grp3Css	:=0
				_Grp4Css	:=0
				_Grp5Css	:=0
				_Grp6Css	:=0
				_Grp7Css	:=0

				//Everson - 19/05/2021. Chamado 14094.
				_Grp8Css	:=0
				_Grp9Css	:=0
				_Grp10Css	:=0
				_Grp11Css	:=0
				_Grp12Css	:=0
				_Grp13Css	:=0
				_Grp14Css	:=0
				_Grp15Css	:=0
				
				_Grp1cDSR	:=0
				_Grp2cDSR	:=0
				_Grp3cDSR	:=0
				_Grp4cDSR	:=0
				_Grp5cDSR	:=0
				_Grp6cDSR	:=0
				_Grp7cDSR	:=0
				_Grp8cDSR	:=0
				_Grp9cDSR	:=0
				_Grp10cDSR	:=0
				_Grp11cDSR	:=0
				_Grp12cDSR	:=0
				_Grp13cDSR	:=0
				_Grp14cDSR	:=0
				_Grp15cDSR	:=0

				_Grp1sDSR	:=0
				_Grp2sDSR	:=0
				_Grp3sDSR	:=0
				_Grp4sDSR	:=0
				_Grp5sDSR	:=0
				_Grp6sDSR	:=0
				_Grp7sDSR	:=0
				_Grp8sDSR	:=0
				_Grp9sDSR	:=0
				_Grp10sDSR	:=0
				_Grp11sDSR	:=0
				_Grp12sDSR	:=0
				_Grp13sDSR	:=0
				_Grp14sDSR	:=0
				_Grp15sDSR	:=0

				//			If nLin > 64 .or. _xQuebra
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 8
				Cabeca2()
				_xQuebra	:=	.F.
				//			Endif
			Endif
			IF !_xVez
				_xVez	:=	.T.
				_xQuebra	:=	.F.
			Else
				_xVez	:=	.T.
			ENDIF
			_cVend	:=	TEM6->T6_VEND
			@nLin,000 PSAY "|"
			@nLin,003 PSAY _cVend
			@nLin,012 PSAY _cNomVen
			@nlin,nCol13 PSAY "|"
			
			nLin++
			@nLin,000 PSAY  cabec06
			nLin ++
			_cGRUPON 	:= "X99"
			_nTFaturado :=  0
			_nTPeso 	:=  0
			_nTComiss 	:=  0
			_nTComCDSR	:=  0
			_nTComSDSR	:=  0
			
		Endif
		
		if _cGRUPON <> TEM6->T6_GRUPON .and. _cGrupon <> "X99" //.and. _nTFaturado <> 0
			if mv_par15 = 1
				if nlin = 15
					@nlin,000 PSAY "|"
					@nLin,005 PSAY _cGRUPON			PICTURE "@!"
					@nLin,012 PSAY SUBSTR(_cNOMEGN,1,25)
				else
					@nlin,000 PSAY "|"
				endif
			endif
			
			@nlin,nCol04 PSAY "|"
			@nlin,nCol04+3 PSAY "TOTAL"
			@nlin,nCol05 PSAY "|"
			@nlin,nCol05+5 PSAY (_nTFaturado/_nTPeso)	PICTURE "@E 99.9999" //Incluido por Adriana HC, para atender chamado 008155 - 19/10/10
			@nlin,nCol06 PSAY "|"
			@nlin,nCol07 PSAY "|"
			@nlin,nCol07+1 PSAY _nTFaturado		PICTURE "@E 99,999,999.99"
			@nlin,nCol08 PSAY "|"
			@nlin,nCol08+1 PSAY _nTPeso			PICTURE "@E 9999,999.99"
			@nlin,nCol09 PSAY "|"
			@nlin,nCol10 PSAY "|"
			@nlin,nCol10+2 PSAY _nTComSDSR		PICTURE "@E 999,999.99"
			@nlin,nCol11 PSAY "|"
			@nlin,nCol11+2 PSAY _nTComCDSR		PICTURE "@E 999,999.99"
			@nlin,nCol12 PSAY "|"
			@nlin,nCol12+2 PSAY _nTComiss		PICTURE "@E 999,999.99"
			@nlin,nCol13 PSAY  "|"
			nLin ++
			@nLin,000 PSAY  cabec06
			nLin ++
		endif
		if _cGRUPON <> TEM6->T6_GRUPON
			_cGRUPON	:=	TEM6->T6_GRUPON
			_cNOMEGN	:=	TEM6->T6_NOMEGN //LEFT(TEM6->T6_NOMEGN,15)
			_nTFaturado :=  TEM6->T6_FATUR
			_nTPeso 	:=  TEM6->T6_QTDADE
			_nTComiss 	:=  (TEM6->T6_QTDADE / 1000) * TEM6->T6_VLFAI

			if Len(aDSR) > 0
				_nTComSDSR	:= _nTComiss*(aDSR[3]/aDSR[2])
				_nTComCDSR	:= _nTComiss-_nTComSDSR
			endif

			@nlin,000 PSAY "|"
			@nLin,005 PSAY _cGRUPON			PICTURE "@!"
			@nLin,012 PSAY SUBSTR(_cNOMEGN,1,25)
		else
			_nTFaturado +=  TEM6->T6_FATUR
			_nTPeso 	+=  TEM6->T6_QTDADE
			_nTComiss 	+=  (TEM6->T6_QTDADE / 1000) * TEM6->T6_VLFAI

			if Len(aDSR) > 0
				_nTComSDSR	:= _nTComiss*(aDSR[3]/aDSR[2])
				_nTComCDSR	:= _nTComiss-_nTComSDSR
			endif

			if nlin = 15 .and. mv_par15 = 1
				@nlin,000 PSAY "|"
				@nLin,005 PSAY _cGRUPON			PICTURE "@!"
				@nLin,012 PSAY SUBSTR(_cNOMEGN,1,25)
			elseif mv_par15 = 1
				@nlin,000 PSAY "|"
			endif
		endif
		
		_dData		:=		TEM6->T6_DATA
		_nVlMedio	:=		TEM6->T6_VLMEDIO
		_nPosi		:=		TEM6->T6_POSIP
		_cTabela	:=		SUBSTR(TEM6->T6_TABELA,1,2)	+ " " +TEM6->T6_TABFAIP
		_nFaturado	:=		TEM6->T6_FATUR
		_nPeso		:=		TEM6->T6_QTDADE
		_nClass		:=		TEM6->T6_CLASS
		
		_nComiss	:=		(_nPeso / 1000) * TEM6->T6_VLFAI
		_nTComsDSR	:= _nComiss*(aDSR[3]/aDSR[2])
		_nTComcDSR	:= _nComiss-_nTComsDSR

		if mv_par15 = 1 //Analitico - incluido por Adriana HC para atender chamado 008155 - 19/10/10
			@nlin,nCol04 PSAY "|"
			@nlin,nCol04+3 PSAY _dData
			@nlin,nCol05 PSAY "|"
			@nlin,nCol05+5 PSAY _nVlMedio		PICTURE "@E 99.9999"
			@nlin,nCol06 PSAY "|"
			cPosTab := Strzero(_nPosi,2)+"/"+Alltrim(_cTabela)
			@nLin,nCol06+2 PSAY cPosTab
			//@nLin,nCol06+1 PSAY _nPosi			PICTURE "99"
			//@nLin,nCol06+2 PSAY "/"
			//@nLin,nCol06+4 PSAY _cTabela
			@nlin,nCol07 PSAY "|"
			@nlin,nCol07+1 PSAY _nFaturado		PICTURE "@E 99,999,999.99"
			@nlin,nCol08 PSAY "|"
			@nlin,nCol08+1 PSAY _nPeso			PICTURE "@E 9999,999.99"
			@nlin,nCol09 PSAY "|"
			@nlin,nCol09+2 PSAY _nClass			PICTURE "@E 999.99"
			@nlin,nCol10 PSAY "|"
			@nlin,nCol10+2 PSAY _nTComSDSR		PICTURE "@E 999,999.99"
			@nlin,nCol11 PSAY "|"
			@nlin,nCol11+2 PSAY _nTComCDSR		PICTURE "@E 999,999.99"
			@nlin,nCol12 PSAY "|"
			@nlin,nCol12+2 PSAY _nComiss		PICTURE "@E 999,999.99"
			@nlin,nCol13 PSAY  "|"
			nLin := nLin + 1
		endif
		_nTVFat		:=	_nTVFat	+	_nFaturado
		_nTQFat		:=	_nTQFat	+	_nPeso
		_nTCFat		:=	_nTCFat	+	_nComiss

		_nTCsDSR	:=  _nTCFat*(aDSR[3]/aDSR[2])
		_nTCcDSR	:=  _nTCFat-_nTCsDSR

		SmsGrp (_cGRUPON)
		
		dbSelectArea("TEM6")
		dbSkip()
		
	Enddo
	if mv_par15 = 1
		@nlin,000 PSAY "|"
	endif
	@nlin,nCol04 PSAY "|"
	@nlin,nCol04+3 PSAY "TOTAL"
	@nlin,nCol05 PSAY "|"
	@nlin,nCol05+5 PSAY (_nTFaturado/_nTPeso)	PICTURE "@E 99.9999" //Incluido por Adriana HC, para atender chamado 008155 - 19/10/10
	@nlin,nCol06 PSAY "|"
	@nlin,nCol07 PSAY "|"
	@nlin,nCol07+1 PSAY _nTFaturado		PICTURE "@E 99,999,999.99"
	@nlin,nCol08 PSAY "|"
	@nlin,nCol08+1 PSAY _nTPeso			PICTURE "@E 9999,999.99"
	@nlin,nCol09 PSAY "|"
	@nlin,nCol10 PSAY "|"
	@nlin,nCol10+2 PSAY _nTComSDSR		PICTURE "@E 999,999.99"
	@nlin,nCol11 PSAY "|"
	@nlin,nCol11+2 PSAY _nTComCDSR		PICTURE "@E 999,999.99"
	@nlin,nCol12 PSAY "|"
	@nlin,nCol12+2 PSAY _nTComiss		PICTURE "@E 999,999.99"
	@nlin,nCol13 PSAY  "|"
	nLin ++
	
	@nLin,000 PSAY	cabec02
	nLin := nLin + 1
	nLin := nLin + 1
	@nLin,000 PSAY	cabec02
	nLin := nLin + 1
	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome1))
	@nlin,nCol07 PSAY "|"
	@nlin,nCol07+1 PSAY Transform(_Grp1Sms,"@E 99,999,999.99")
	@nlin,nCol08 PSAY "|"
	@nlin,nCol08+1 PSAY Transform(_Grp1Pes,"@E 9999,999.99")
	@nlin,nCol09 PSAY "|"
	@nlin,nCol09+2 PSAY ((_Grp1Pes/_nTQFat)*100) picture "@E 999.99%"
	@nlin,nCol10 PSAY "|"
	@nlin,nCol10+2 PSAY Transform(_Grp1sDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY "|"
	@nlin,nCol11+2 PSAY Transform(_Grp1cDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY "|"
	@nlin,nCol12+2 PSAY Transform(_Grp1Css,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"
	nLin := nLin + 1
	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome2))
	@nlin,nCol07 PSAY "|"
	@nlin,nCol07+1 PSAY Transform(_Grp2Sms,"@E 99,999,999.99")
	@nlin,nCol08 PSAY "|"
	@nlin,nCol08+1 PSAY Transform(_Grp2Pes,"@E 9999,999.99")
	@nlin,nCol09 PSAY "|"
	@nlin,nCol09+2 PSAY ((_Grp2Pes/_nTQFat)*100) picture "@E 999.99%"
	@nlin,nCol10 PSAY "|"
	@nlin,nCol10+2 PSAY Transform(_Grp2sDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY "|"
	@nlin,nCol11+2 PSAY Transform(_Grp2cDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY "|"
	@nlin,nCol12+2 PSAY Transform(_Grp2Css,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"
	nLin := nLin + 1
	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome3))
	@nlin,nCol07 PSAY "|"
	@nlin,nCol07+1 PSAY Transform(_Grp3Sms,"@E 99,999,999.99")
	@nlin,nCol08 PSAY "|"
	@nlin,nCol08+1 PSAY Transform(_Grp3Pes,"@E 9999,999.99")
	@nlin,nCol09 PSAY "|"
	@nlin,nCol09+2 PSAY ((_Grp3Pes/_nTQFat)*100) picture "@E 999.99%"
	@nlin,nCol10 PSAY "|"
	@nlin,nCol10+2 PSAY Transform(_Grp3sDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY "|"
	@nlin,nCol11+2 PSAY Transform(_Grp3cDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY "|"
	@nlin,nCol12+2 PSAY Transform(_Grp3Css,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"
	nLin := nLin + 1
	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome4))
	@nlin,nCol07 PSAY "|"
	@nlin,nCol07+1 PSAY Transform(_Grp4Sms,"@E 99,999,999.99")
	@nlin,nCol08 PSAY "|"
	@nlin,nCol08+1 PSAY Transform(_Grp4Pes,"@E 9999,999.99")
	@nlin,nCol09 PSAY "|"
	@nlin,nCol09+2 PSAY ((_Grp4Pes/_nTQFat)*100) picture "@E 999.99%"
	@nlin,nCol10 PSAY "|"
	@nlin,nCol10+2 PSAY Transform(_Grp4sDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY "|"
	@nlin,nCol11+2 PSAY Transform(_Grp4cDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY "|"
	@nlin,nCol12+2 PSAY Transform(_Grp4Css,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"
	nLin := nLin + 1
	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome5))
	@nlin,nCol07 PSAY "|"
	@nlin,nCol07+1 PSAY Transform(_Grp6Sms,"@E 99,999,999.99")
	@nlin,nCol08 PSAY "|"
	@nlin,nCol08+1 PSAY Transform(_Grp6Pes,"@E 9999,999.99")
	@nlin,nCol09 PSAY "|"
	@nlin,nCol09+2 PSAY ((_Grp6Pes/_nTQFat)*100) picture "@E 999.99%"
	@nlin,nCol10 PSAY "|"
	@nlin,nCol10+2 PSAY Transform(_Grp6sDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY "|"
	@nlin,nCol11+2 PSAY Transform(_Grp6cDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY "|"
	@nlin,nCol12+2 PSAY Transform(_Grp6Css,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"
	nLin := nLin + 1
	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome6))
	@nlin,nCol07 PSAY "|"
	@nlin,nCol07+1 PSAY Transform(_Grp7Sms,"@E 99,999,999.99")
	@nlin,nCol08 PSAY "|"
	@nlin,nCol08+1 PSAY Transform(_Grp7Pes,"@E 9999,999.99")
	@nlin,nCol09 PSAY "|"
	@nlin,nCol09+2 PSAY ((_Grp7Pes/_nTQFat)*100) picture "@E 999.99%"
	@nlin,nCol10 PSAY "|"
	@nlin,nCol10+2 PSAY Transform(_Grp7sDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY "|"
	@nlin,nCol11+2 PSAY Transform(_Grp7cDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY "|"
	@nlin,nCol12+2 PSAY Transform(_Grp7Css,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"

	//Everson - 19/05/2021. Chamado 14094.
	nLin := nLin + 1
	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome7))
	@nlin,nCol07 PSAY "|"
	@nlin,nCol07+1 PSAY Transform(_Grp8Sms,"@E 99,999,999.99")
	@nlin,nCol08 PSAY "|"
	@nlin,nCol08+1 PSAY Transform(_Grp8Pes,"@E 9999,999.99")
	@nlin,nCol09 PSAY "|"
	@nlin,nCol09+2 PSAY ((_Grp8Pes/_nTQFat)*100) picture "@E 999.99%"
	@nlin,nCol10 PSAY "|"
	@nlin,nCol10+2 PSAY Transform(_Grp8sDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY "|"
	@nlin,nCol11+2 PSAY Transform(_Grp8cDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY "|"
	@nlin,nCol12+2 PSAY Transform(_Grp8Css,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"

	nLin := nLin + 1
	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome8))
	@nlin,nCol07 PSAY "|"
	@nlin,nCol07+1 PSAY Transform(_Grp9Sms,"@E 99,999,999.99")
	@nlin,nCol08 PSAY "|"
	@nlin,nCol08+1 PSAY Transform(_Grp9Pes,"@E 9999,999.99")
	@nlin,nCol09 PSAY "|"
	@nlin,nCol09+2 PSAY ((_Grp9Pes/_nTQFat)*100) picture "@E 999.99%"
	@nlin,nCol10 PSAY "|"
	@nlin,nCol10+2 PSAY Transform(_Grp9sDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY "|"
	@nlin,nCol11+2 PSAY Transform(_Grp9cDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY "|"
	@nlin,nCol12+2 PSAY Transform(_Grp9Css,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"

	nLin := nLin + 1
	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome9))
	@nlin,nCol07 PSAY "|"
	@nlin,nCol07+1 PSAY Transform(_Grp10Sms,"@E 99,999,999.99")
	@nlin,nCol08 PSAY "|"
	@nlin,nCol08+1 PSAY Transform(_Grp10Pes,"@E 9999,999.99")
	@nlin,nCol09 PSAY "|"
	@nlin,nCol09+2 PSAY ((_Grp10Pes/_nTQFat)*100) picture "@E 999.99%"
	@nlin,nCol10 PSAY "|"
	@nlin,nCol10+2 PSAY Transform(_Grp10sDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY "|"
	@nlin,nCol11+2 PSAY Transform(_Grp10cDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY "|"
	@nlin,nCol12+2 PSAY Transform(_Grp10Css,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"

	nLin := nLin + 1
	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome10))
	@nlin,nCol07 PSAY "|"
	@nlin,nCol07+1 PSAY Transform(_Grp11Sms,"@E 99,999,999.99")
	@nlin,nCol08 PSAY "|"
	@nlin,nCol08+1 PSAY Transform(_Grp11Pes,"@E 9999,999.99")
	@nlin,nCol09 PSAY "|"
	@nlin,nCol09+2 PSAY ((_Grp11Pes/_nTQFat)*100) picture "@E 999.99%"
	@nlin,nCol10 PSAY "|"
	@nlin,nCol10+2 PSAY Transform(_Grp11sDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY "|"
	@nlin,nCol11+2 PSAY Transform(_Grp11cDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY "|"
	@nlin,nCol12+2 PSAY Transform(_Grp11Css,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"

	nLin := nLin + 1
	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome11))
	@nlin,nCol07 PSAY "|"
	@nlin,nCol07+1 PSAY Transform(_Grp12Sms,"@E 99,999,999.99")
	@nlin,nCol08 PSAY "|"
	@nlin,nCol08+1 PSAY Transform(_Grp12Pes,"@E 9999,999.99")
	@nlin,nCol09 PSAY "|"
	@nlin,nCol09+2 PSAY ((_Grp12Pes/_nTQFat)*100) picture "@E 999.99%"
	@nlin,nCol10 PSAY "|"
	@nlin,nCol10+2 PSAY Transform(_Grp12sDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY "|"
	@nlin,nCol11+2 PSAY Transform(_Grp12cDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY "|"
	@nlin,nCol12+2 PSAY Transform(_Grp12Css,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"

	nLin := nLin + 1
	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome12))
	@nlin,nCol07 PSAY "|"
	@nlin,nCol07+1 PSAY Transform(_Grp13Sms,"@E 99,999,999.99")
	@nlin,nCol08 PSAY "|"
	@nlin,nCol08+1 PSAY Transform(_Grp13Pes,"@E 9999,999.99")
	@nlin,nCol09 PSAY "|"
	@nlin,nCol09+2 PSAY ((_Grp13Pes/_nTQFat)*100) picture "@E 999.99%"
	@nlin,nCol10 PSAY "|"
	@nlin,nCol10+2 PSAY Transform(_Grp13sDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY "|"
	@nlin,nCol11+2 PSAY Transform(_Grp13cDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY "|"
	@nlin,nCol12+2 PSAY Transform(_Grp13Css,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"

	nLin := nLin + 1
	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome13))
	@nlin,nCol07 PSAY "|"
	@nlin,nCol07+1 PSAY Transform(_Grp14Sms,"@E 99,999,999.99")
	@nlin,nCol08 PSAY "|"
	@nlin,nCol08+1 PSAY Transform(_Grp14Pes,"@E 9999,999.99")
	@nlin,nCol09 PSAY "|"
	@nlin,nCol09+2 PSAY ((_Grp14Pes/_nTQFat)*100) picture "@E 999.99%"
	@nlin,nCol10 PSAY "|"
	@nlin,nCol10+2 PSAY Transform(_Grp14sDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY "|"
	@nlin,nCol11+2 PSAY Transform(_Grp14cDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY "|"
	@nlin,nCol12+2 PSAY Transform(_Grp14Css,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"

	nLin := nLin + 1
	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome14))
	@nlin,nCol07 PSAY "|"
	@nlin,nCol07+1 PSAY Transform(_Grp15Sms,"@E 99,999,999.99")
	@nlin,nCol08 PSAY "|"
	@nlin,nCol08+1 PSAY Transform(_Grp15Pes,"@E 9999,999.99")
	@nlin,nCol09 PSAY "|"
	@nlin,nCol09+2 PSAY ((_Grp15Pes/_nTQFat)*100) picture "@E 999.99%"
	@nlin,nCol10 PSAY "|"
	@nlin,nCol10+2 PSAY Transform(_Grp15sDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY "|"
	@nlin,nCol11+2 PSAY Transform(_Grp15cDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY "|"
	@nlin,nCol12+2 PSAY Transform(_Grp15Css,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"
	//

	nLin := nLin + 1
	@nlin,000 PSAY "|Outros Grupos: "
	@nlin,nCol07 PSAY "|"
	@nlin,nCol07+1 PSAY Transform(_Grp5Sms,"@E 99,999,999.99")
	@nlin,nCol08 PSAY "|"
	@nlin,nCol08+1 PSAY Transform(_Grp5Pes,"@E 9999,999.99")
	@nlin,nCol09 PSAY "|"
	@nlin,nCol09+2 PSAY ((_Grp5Pes/_nTQFat)*100) picture "@E 999.99%"
	@nlin,nCol10 PSAY "|"
	@nlin,nCol10+2 PSAY Transform(_Grp5sDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY "|"
	@nlin,nCol11+2 PSAY Transform(_Grp5cDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY "|"
	@nlin,nCol12+2 PSAY Transform(_Grp5Css,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"
	nLin := nLin + 1
	
	@nLin,000 PSAY	"|-------------------------------------------------------------------------------------------- ------------ ------------ ---------- -------------- ------------ --------- ------------- ------------- --------------|"
	nLin := nLin + 1
	
	@nLin,000 PSAY "|Total  Sub-Regiao"
	@nlin,nCol07 PSAY "|"
	@nlin,nCol07+1 PSAY	_nTVFat	PICTURE "@E 99,999,999.99"
	@nlin,nCol08 PSAY "|"
	@nlin,nCol08+1 PSAY _nTQFat	PICTURE "@E 9999,999.99"
	@nlin,nCol09 PSAY "|"
	@nlin,nCol10 PSAY "|"
	@nlin,nCol10+2 PSAY _nTCsDSR	PICTURE "@E 999,999.99"
	@nlin,nCol11 PSAY "|"
	@nlin,nCol11+2 PSAY _nTCcDSR	PICTURE "@E 999,999.99"
	@nlin,nCol12 PSAY "|"
	@nlin,nCol12+2 PSAY _nTCFat	PICTURE "@E 999,999.99"
	@nlin,nCol13 PSAY "|"
	nLin := nLin + 1
	
	@nLin,000 PSAY	cabec02
	nLin := nLin + 1
	
	fAtuTot()		&& Funcao para acumular os subtotais calculados.
	
	fImpTot()		&& Funcao de Impressao com Total Geral
	
	_nTVFat		:=	0
	_nTQFat		:=	0
	_nTCFat		:=	0
	_nTCsDSR	:=  0
	_nTCcDSR	:=  0
	_Grp1Sms:=0
	_Grp2Sms:=0
	_Grp3Sms:=0
	_Grp4Sms:=0
	_Grp5Sms:=0
	_Grp6Sms:=0
	_Grp7Sms:=0

	//Everson - 19/05/2021. Chamado 14094.
	_Grp8Sms:=0
	_Grp9Sms:=0
	_Grp10Sms:=0
	_Grp11Sms:=0
	_Grp12Sms:=0
	_Grp13Sms:=0
	_Grp14Sms:=0
	_Grp15Sms:=0
	//
	
	_Grp1Pes:=0
	_Grp2Pes:=0
	_Grp3Pes:=0
	_Grp4Pes:=0
	_Grp5Pes:=0
	_Grp6Pes:=0
	_Grp7Pes:=0

	//Everson - 19/05/2021. Chamado 14094.
	_Grp8Pes:=0
	_Grp9Pes:=0
	_Grp10Pes:=0
	_Grp11Pes:=0
	_Grp12Pes:=0
	_Grp13Pes:=0
	_Grp14Pes:=0
	_Grp15Pes:=0
	//
	
	_Grp1Css:=0
	_Grp2Css:=0
	_Grp3Css:=0
	_Grp4Css:=0
	_Grp5Css:=0
	_Grp6Css:=0
	_Grp7Css:=0

	//Everson - 19/05/2021. Chamado 14094.
	_Grp8Css:=0
	_Grp9Css:=0
	_Grp10Css:=0
	_Grp11Css:=0
	_Grp12Css:=0
	_Grp13Css:=0
	_Grp14Css:=0
	_Grp15Css:=0
	
	_Grp1cDSR	:=0
	_Grp2cDSR	:=0
	_Grp3cDSR	:=0
	_Grp4cDSR	:=0
	_Grp5cDSR	:=0
	_Grp6cDSR	:=0
	_Grp7cDSR	:=0
	_Grp8cDSR	:=0
	_Grp9cDSR	:=0
	_Grp10cDSR	:=0
	_Grp11cDSR	:=0
	_Grp12cDSR	:=0
	_Grp13cDSR	:=0
	_Grp14cDSR	:=0
	_Grp15cDSR	:=0

	_Grp1sDSR	:=0
	_Grp2sDSR	:=0
	_Grp3sDSR	:=0
	_Grp4sDSR	:=0
	_Grp5sDSR	:=0
	_Grp6sDSR	:=0
	_Grp7sDSR	:=0
	_Grp8sDSR	:=0
	_Grp9sDSR	:=0
	_Grp10sDSR	:=0
	_Grp11sDSR	:=0
	_Grp12sDSR	:=0
	_Grp13sDSR	:=0
	_Grp14sDSR	:=0
	_Grp15sDSR	:=0
	
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
		OurSpool(NomeRel)
	Endif
	
	MS_FLUSH()

RETURN


Static Function Cabeca2

	nLin := nLin + 1
	@nLin,000 PSAY Cabec02
	nLin := nLin + 1
	@nLin,000 PSAY Cabec04
	nLin := nLin + 1
	@nLin,000 PSAY Cabec05
	nLin := nLin + 1
	@nLin,000 PSAY Cabec06
	nLin := nLin + 1
	
Return


STATIC FUNCTION AD0012B
	//cString 		:= "SD2"
	titulo  := "DEMONSTRATIVO DE REGIAO POR GRUPO DE PRODUTO"
	aOrd            := {}
	tamanho         := "G"
	limite          := 220
	nomeprog        := "AD0012B"
	mv_tabpr        := ""
	nTipo         	:= 18
	aReturn := { "Zebrado", 1,"Administracao", 2, 2, 1, "",0 }
	
	nLastKey         := 0
	nlin             := 80
	nItem            := 1
	lContinua        := .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	m_pag	   := 01
	imprime    := .T.
	NomeRel := "AD0012B"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Totaliza por grupos                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Private _Grp1Sms:=0
	Private _Grp2Sms:=0
	Private _Grp3Sms:=0
	Private _Grp4Sms:=0
	Private _Grp5Sms:=0
	Private _Grp6Sms:=0
	Private _Grp7Sms:=0

	//Everson - 19/05/2021. Chamado 14094.
	Private _Grp8Sms:=0
	Private _Grp9Sms:=0
	Private _Grp10Sms:=0
	Private _Grp11Sms:=0
	Private _Grp12Sms:=0
	Private _Grp13Sms:=0
	Private _Grp14Sms:=0
	Private _Grp15Sms:=0
	//
	
	nomerel := SetPrint(cString,Nomerel,,Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se deve comprimir ou nao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTipo   := IIF(aReturn[4]==1,15,18)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Prepara o cabecalho padrao para o relatorio DEMONSTRATIVO DE VENDA VENDEDOR           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cabec02	:=	"|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
	cabec03	:=	"| GRUPO  NOME                                                                                               +--------------------------------------------------------------+--------------+-------------+----------|"
	cabec04	:=	"|                   COD/NOME REGIAO     COD PROD   DESCRICAO                                                |             PRODUTO           |   Valor      |    Peso     |   Valor     |    Valor   |   Valor      |"
	cabec05	:=	"|                      COD PROD        DESCRICAO                                                            | Prec Medio | Posicao | Tabela |  Faturado    |  Faturado   |Prêmio s/ DSR|     DSR    | Prêmio Total |"	
	cabec06	:=	"|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"

	//           0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16
	//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
	
	dbSelectArea("TEM6")
	cIndex   	:=	 "T6_VEND + T6_GRUPON + T6_TABELA + T6_GRPCOM"
	IndRegua( "TEM6", _cNomTr6, cIndex,,,"Criando Indice 2 ..." )
	
	dbSelectArea("TEM1")
	
	If mv_par05	== 1		// ordem por supervisor
		// Chamado n. Chamado  ³ 049140 || OS 050426 || ADM. || VAGNER || 8469 || REL METRAS - FWNM - 13/05/2019
		//cIndex   	:=	 "T1_SUPER + T1_GRUPON + T1_VEND + T1_PROD + DESCEND(STR(T1_VLMEDIO,9,4))"
		cIndex   	:=	 "T1_SUPER + T1_GRUPON + T1_VEND + T1_PROD + DESCEND(STR(T1_VLMEDIO,16,4))"
		//
		IndRegua( "TEM1", _cNomTrb, cIndex,,,"Criando Indice3 ..." )
		Cabec2	:=	"Supervisor: " + TEM1->T1_SUPER + " - " + TEM1->T1_NOMSUP
	else 					// ordem por regiao
		// Chamado n. Chamado  ³ 049140 || OS 050426 || ADM. || VAGNER || 8469 || REL METRAS - FWNM - 13/05/2019
		//cIndex   	:=	 "T1_REGIAO + T1_GRUPON + T1_VEND + T1_PROD + DESCEND(STR(T1_VLMEDIO,9,4))"
		cIndex   	:=	 "T1_REGIAO + T1_GRUPON + T1_VEND + T1_PROD + DESCEND(STR(T1_VLMEDIO,16,4))"
		//
		IndRegua( "TEM1", _cNomTrb, cIndex,,,"Criando Indice3 ..." )
		Cabec2	:=	"Regiao: " + 	TEM1->T1_REGIAO+ " - " + TEM1->T1_NOMREG
	Endif
	
	//SetRegua(RecCount())
	TEM1->(dbGoTop())
	Cabec1 := "Periodo de : "+dtoc(mv_par01)+" Ate : "+dtoc(mv_par02)
	Cabec1	:= space(61-(len(Cabec1)/2)) + Cabec1
	_cVend	:=	""
	_cSuper		:=	TEM1->T1_SUPER
	_cRegiao	:=	TEM1->T1_REGIAO
	_cGRUPON	:=	""
	
	_xVez		:=	.F.
	_nPesoAc	:=	0
	_nFatAc		:=	0
	_xQuebra	:=	.F.
	While !EOF()
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		If	!_bFlagVend
			If _cCodVen != TEM1->T1_VEND .and. !empty(_cCodVen)
				dbSelectArea("TEM1")
				dbskip()
				Loop
			Endif
			If 	!TEM1->T1_VEND$_cSupVends .and. !empty(_cSupVends)
				dbSelectArea("TEM1")
				dbskip()
				Loop
			Endif
		Endif
		
		
		If nLin > 65
			If	_xVez
				@nLin,000 PSAY Cabec06
			Endif
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
			Cabeca2a()
		Endif
		
		If mv_par05			== 1 .and. _cSuper	!=	TEM1->T1_SUPER
			//IMPRIMINDO TOTAL POR GRUPOS
			@nLin,000 PSAY	"+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
			nLin := nLin + 1
			nLin := nLin + 1
			@nLin,000 PSAY	"|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
			nLin := nLin + 1
			@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome1))
			@nlin,nCol08+2 PSAY Transform(_Grp1Sms,"@E 99,999,999.99")
			@nlin,nCol09+2 PSAY Transform(_Grp1Pes,"@E 99,999,999.99")
			@nLin,nCol10+2 PSAY Transform(_Grp1sDSR,"@E 99,999.99")
			@nLin,nCol11+2 PSAY Transform(_Grp1cDSR,"@E 99,999.99")
			@nLin,nCol12+2 PSAY Transform(_Grp1Css,"@E 99,999.99")
			@nLin,nCol13 PSAY  "|"
			nLin := nLin + 1

			@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome2))
			@nlin,nCol08+2 PSAY Transform(_Grp2Sms,"@E 99,999,999.99")
			@nlin,nCol09+2 PSAY Transform(_Grp2Pes,"@E 99,999,999.99")
			@nLin,nCol10+2 PSAY Transform(_Grp2sDSR,"@E 99,999.99")
			@nLin,nCol11+2 PSAY Transform(_Grp2cDSR,"@E 99,999.99")
			@nLin,nCol12+2 PSAY Transform(_Grp2Css,"@E 99,999.99")
			@nLin,nCol13 PSAY  "|"
			nLin := nLin + 1
			
			@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome3))
			@nlin,nCol08+2 PSAY Transform(_Grp3Sms,"@E 99,999,999.99")
			@nlin,nCol09+2 PSAY Transform(_Grp3Pes,"@E 99,999,999.99")
			@nLin,nCol10+2 PSAY Transform(_Grp3sDSR,"@E 99,999.99")
			@nLin,nCol11+2 PSAY Transform(_Grp3cDSR,"@E 99,999.99")
			@nLin,nCol12+2 PSAY Transform(_Grp3Css,"@E 99,999.99")
			@nLin,nCol13 PSAY  "|"
			nLin := nLin + 1

			@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome4))
			@nlin,nCol08+2 PSAY Transform(_Grp4Sms,"@E 99,999,999.99")
			@nlin,nCol09+2 PSAY Transform(_Grp4Pes,"@E 99,999,999.99")
			@nLin,nCol10+2 PSAY Transform(_Grp4sDSR,"@E 99,999.99")
			@nLin,nCol11+2 PSAY Transform(_Grp4cDSR,"@E 99,999.99")
			@nLin,nCol12+2 PSAY Transform(_Grp4Css,"@E 99,999.99")
			@nLin,nCol13 PSAY  "|"
			nLin := nLin + 1

			@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome5))
			@nlin,nCol08+2 PSAY Transform(_Grp6Sms,"@E 99,999,999.99")
			@nlin,nCol09+2 PSAY Transform(_Grp6Pes,"@E 99,999,999.99")
			@nLin,nCol10+2 PSAY Transform(_Grp6sDSR,"@E 99,999.99")
			@nLin,nCol11+2 PSAY Transform(_Grp6cDSR,"@E 99,999.99")
			@nLin,nCol12+2 PSAY Transform(_Grp6Css,"@E 99,999.99")
			@nLin,nCol13 PSAY  "|"
			nLin := nLin + 1

			@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome6))
			@nlin,nCol08+2 PSAY Transform(_Grp7Sms,"@E 99,999,999.99")
			@nlin,nCol09+2 PSAY Transform(_Grp7Pes,"@E 99,999,999.99")
			@nLin,nCol10+2 PSAY Transform(_Grp7sDSR,"@E 99,999.99")
			@nLin,nCol11+2 PSAY Transform(_Grp7cDSR,"@E 99,999.99")
			@nLin,nCol12+2 PSAY Transform(_Grp7Css,"@E 99,999.99")
			@nLin,nCol13 PSAY  "|"
			nLin := nLin + 1	
			
			//Everson - 19/05/2021. Chamado 14094.
			@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome7))
			@nlin,nCol08+2 PSAY Transform(_Grp8Sms,"@E 99,999,999.99")
			@nlin,nCol09+2 PSAY Transform(_Grp8Pes,"@E 99,999,999.99")
			@nLin,nCol10+2 PSAY Transform(_Grp8sDSR,"@E 99,999.99")
			@nLin,nCol11+2 PSAY Transform(_Grp8cDSR,"@E 99,999.99")
			@nLin,nCol12+2 PSAY Transform(_Grp8Css,"@E 99,999.99")
			@nLin,nCol13 PSAY  "|"
			nLin := nLin + 1	
			
			@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome8))
			@nlin,nCol08+2 PSAY Transform(_Grp9Sms,"@E 99,999,999.99")
			@nlin,nCol09+2 PSAY Transform(_Grp9Pes,"@E 99,999,999.99")
			@nLin,nCol10+2 PSAY Transform(_Grp9sDSR,"@E 99,999.99")
			@nLin,nCol11+2 PSAY Transform(_Grp9cDSR,"@E 99,999.99")
			@nLin,nCol12+2 PSAY Transform(_Grp9Css,"@E 99,999.99")
			@nLin,nCol13 PSAY  "|"
			nLin := nLin + 1	
			
			@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome9))
			@nlin,nCol08+2 PSAY Transform(_Grp10Sms,"@E 99,999,999.99")
			@nlin,nCol09+2 PSAY Transform(_Grp10Pes,"@E 99,999,999.99")
			@nLin,nCol10+2 PSAY Transform(_Grp10sDSR,"@E 99,999.99")
			@nLin,nCol11+2 PSAY Transform(_Grp10cDSR,"@E 99,999.99")
			@nLin,nCol12+2 PSAY Transform(_Grp10Css,"@E 99,999.99")
			@nLin,nCol13 PSAY  "|"
			nLin := nLin + 1	
			
			@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome10))
			@nlin,nCol08+2 PSAY Transform(_Grp11Sms,"@E 99,999,999.99")
			@nlin,nCol09+2 PSAY Transform(_Grp11Pes,"@E 99,999,999.99")
			@nLin,nCol10+2 PSAY Transform(_Grp11sDSR,"@E 99,999.99")
			@nLin,nCol11+2 PSAY Transform(_Grp11cDSR,"@E 99,999.99")
			@nLin,nCol12+2 PSAY Transform(_Grp11Css,"@E 99,999.99")
			@nLin,nCol13 PSAY  "|"
			nLin := nLin + 1	
			
			@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome11))
			@nlin,nCol08+2 PSAY Transform(_Grp12Sms,"@E 99,999,999.99")
			@nlin,nCol09+2 PSAY Transform(_Grp12Pes,"@E 99,999,999.99")
			@nLin,nCol10+2 PSAY Transform(_Grp12sDSR,"@E 99,999.99")
			@nLin,nCol11+2 PSAY Transform(_Grp12cDSR,"@E 99,999.99")
			@nLin,nCol12+2 PSAY Transform(_Grp12Css,"@E 99,999.99")
			@nLin,nCol13 PSAY  "|"
			nLin := nLin + 1	
			
			@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome12))
			@nlin,nCol08+2 PSAY Transform(_Grp13Sms,"@E 99,999,999.99")
			@nlin,nCol09+2 PSAY Transform(_Grp13Pes,"@E 99,999,999.99")
			@nLin,nCol10+2 PSAY Transform(_Grp13sDSR,"@E 99,999.99")
			@nLin,nCol11+2 PSAY Transform(_Grp13cDSR,"@E 99,999.99")
			@nLin,nCol12+2 PSAY Transform(_Grp13Css,"@E 99,999.99")
			@nLin,nCol13 PSAY  "|"
			nLin := nLin + 1	
			
			@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome13))
			@nlin,nCol08+2 PSAY Transform(_Grp14Sms,"@E 99,999,999.99")
			@nlin,nCol09+2 PSAY Transform(_Grp14Pes,"@E 99,999,999.99")
			@nLin,nCol10+2 PSAY Transform(_Grp14sDSR,"@E 99,999.99")
			@nLin,nCol11+2 PSAY Transform(_Grp14cDSR,"@E 99,999.99")
			@nLin,nCol12+2 PSAY Transform(_Grp14Css,"@E 99,999.99")
			@nLin,nCol13 PSAY  "|"
			nLin := nLin + 1	
			
			@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome14))
			@nlin,nCol08+2 PSAY Transform(_Grp15Sms,"@E 99,999,999.99")
			@nlin,nCol09+2 PSAY Transform(_Grp15Pes,"@E 99,999,999.99")
			@nLin,nCol10+2 PSAY Transform(_Grp15sDSR,"@E 99,999.99")
			@nLin,nCol11+2 PSAY Transform(_Grp15cDSR,"@E 99,999.99")
			@nLin,nCol12+2 PSAY Transform(_Grp15Css,"@E 99,999.99")
			@nLin,nCol13 PSAY  "|"
			nLin := nLin + 1	
			//	
			
			@nlin,000 PSAY "|Outros Grupos: "
			
			@nlin,nCol08+2 PSAY Transform(_Grp5Sms,"@E 99,999,999.99")
			@nlin,nCol09+2 PSAY Transform(_Grp5Pes,"@E 99,999,999.99")
			@nLin,nCol10+2 PSAY Transform(_Grp5sDSR,"@E 99,999.99")
			@nLin,nCol11+2 PSAY Transform(_Grp5cDSR,"@E 99,999.99")
			@nLin,nCol12+2 PSAY Transform(_Grp5Css,"@E 99,999.99")
			@nLin,nCol13 PSAY  "|"
			
			nLin := nLin + 1
			_nTVFat		:=	0
			_nTQFat		:=	0
			_nTCFat		:=	0
			_nTCsDSR	:=  0
			_nTCcDSR	:=  0
			_Grp1Sms:=0
			_Grp2Sms:=0
			_Grp3Sms:=0
			_Grp4Sms:=0
			_Grp5Sms:=0
			_Grp6Sms:=0
			_Grp7Sms:=0
			
			//Everson - 19/05/2021. Chamado 14094.
			_Grp8Sms:=0
			_Grp9Sms:=0
			_Grp10Sms:=0
			_Grp11Sms:=0
			_Grp12Sms:=0
			_Grp13Sms:=0
			_Grp14Sms:=0
			_Grp15Sms:=0
			//
			
			_Grp1Pes:=0
			_Grp2Pes:=0
			_Grp3Pes:=0
			_Grp4Pes:=0
			_Grp5Pes:=0
			_Grp6Pes:=0
			_Grp7Pes:=0

			//Everson - 19/05/2021. Chamado 14094.
			_Grp8Pes:=0
			_Grp9Pes:=0
			_Grp10Pes:=0
			_Grp11Pes:=0
			_Grp12Pes:=0
			_Grp13Pes:=0
			_Grp14Pes:=0
			_Grp15Pes:=0
			//
			
			_Grp1Css:=0
			_Grp2Css:=0
			_Grp3Css:=0
			_Grp4Css:=0
			_Grp5Css:=0
			_Grp6Css:=0
			_Grp7Css:=0

			//Everson - 19/05/2021. Chamado 14094.
			_Grp8Css:=0
			_Grp9Css:=0
			_Grp10Css:=0
			_Grp11Css:=0
			_Grp12Css:=0
			_Grp13Css:=0
			_Grp14Css:=0
			_Grp15Css:=0
			
			_Grp1cDSR	:=0
			_Grp2cDSR	:=0
			_Grp3cDSR	:=0
			_Grp4cDSR	:=0
			_Grp5cDSR	:=0
			_Grp6cDSR	:=0
			_Grp7cDSR	:=0
			_Grp8cDSR	:=0
			_Grp9cDSR	:=0
			_Grp10cDSR	:=0
			_Grp11cDSR	:=0
			_Grp12cDSR	:=0
			_Grp13cDSR	:=0
			_Grp14cDSR	:=0
			_Grp15cDSR	:=0

			_Grp1sDSR	:=0
			_Grp2sDSR	:=0
			_Grp3sDSR	:=0
			_Grp4sDSR	:=0
			_Grp5sDSR	:=0
			_Grp6sDSR	:=0
			_Grp7sDSR	:=0
			_Grp8sDSR	:=0
			_Grp9sDSR	:=0
			_Grp10sDSR	:=0
			_Grp11sDSR	:=0
			_Grp12sDSR	:=0
			_Grp13sDSR	:=0
			_Grp14sDSR	:=0
			_Grp15sDSR	:=0
			
			_cSuper		:=	TEM1->T1_SUPER
			Cabec2	:=	"Supervisor: " + TEM1->T1_SUPER + " - " + TEM1->T1_NOMSUP
			If	_xVez
				@nLin,000 PSAY Cabec06
			Endif
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
			Cabeca2a()
		ElseIf	mv_par05	== 2 .and. _cRegiao	!=	TEM1->T1_REGIAO
			_cRegiao	:=	TEM1->T1_REGIAO
			Cabec2	:=	"Regiao: " + 	TEM1->T1_REGIAO+ " - " + TEM1->T1_NOMREG
			If	_xVez
				@nLin,000 PSAY Cabec06
			Endif
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
			Cabeca2a()
		Endif
		
		If	_cGRUPON	!=	TEM1->T1_GRUPON		// FAZ A QUEBRA DO GRUPO DE PRODUTO
			If	_xVez
				Cabeca2B()
				@nLin,000 PSAY	"|__________________________________________________________________________________________________________________________________________________________________________________________________________________|"
				nLin := nLin + 1
				@nLin,000 PSAY	"|__________________________________________________________________________________________________________________________________________________________________________________________________________________|"
				nLin := nLin + 1
				_xQuebra	:=	.F.
			Endif
			
			_cGRUPON	:=	TEM1->T1_GRUPON
			_cGRUPOP	:=	TEM1->T1_GRUPOP
			_cNOMEGN	:=	LEFT(TEM1->T1_NOMEGN,15)
			@nLin,000 PSAY "|"
			@nLin,003 PSAY _cGRUPON
			@nLin,010 PSAY _cNOMEGN
			@nLin,081 PSAY "|"
			@nLin,104 PSAY "|"
			@nLin,113 PSAY "|"
			@nLin,128 PSAY "|"
			@nLin,nCol12 PSAY"|"
			@nLin,nCol13 PSAY "|"
			nLin := nLin + 1
			_cVend	:=	""
		Endif
		If	_cVend	!=	TEM1->T1_VEND							    //quebra vendedor
			If	_xVez  .and. _xQuebra			   					// IMPRIME O TOTAL DO VENDEDOR SOMENTE QUANDO NAO É A PRIMEIRA VEZ
				Cabeca2B()
				@nLin,000 PSAY	"|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
				nLin := nLin + 1
				
			Endif
			
			_cVend	:=	TEM1->T1_VEND
			_cNomeVen   :=	TEM1->T1_NOMVEND
			@nLin,000 PSAY "|"
			@nLin,020 PSAY _cVend		PICTURE "@!"
			@nLin,035 PSAY _cNomeVen		PICTURE "@!"
			
			@nLin,nCol07 PSAY "|"
			@nLin,nCol08 PSAY "|"
			@nLin,nCol09 PSAY "|"
			@nLin,nCol10 PSAY "|"
			@nLin,nCol11 PSAY "|"
			@nLin,nCol12 PSAY "|"
			@nLin,nCol13 PSAY "|"
			
			nLin := nLin + 1
			_xVez		:=	.T.
			_xQuebra	:=	.T.
		Endif
		
		_cProduto   :=	TEM1->T1_PROD
		_cDescric	:=	TEM1->T1_DESCRIC
		_nVlMedio   := 	TEM1->T1_VLMEDIO
		_nPos       := 	TEM1->T1_POSIN
		_cFaixa     := 	TEM1->T1_TABELA	+ " " + TEM1->T1_TABFAIN
		_nFaturado  := 	TEM1->T1_FATUR
		_nPeso      := 	TEM1->T1_QTDADE
		_nComiss    :=	TEM1->T1_VALFAIN
		_cTabela	:=	TEM1->T1_TABELA
		_cGrupo		:=	TEM1->T1_GRPCOM
		@nLin,000 PSAY "|"
		@nLin,024 PSAY _cProduto		PICTURE "@!"
		@nLin,040 PSAY _cDescric		PICTURE "@!"
		@nlin,nCol05 PSAY "|"
		@nlin,nCol05+2 PSAY _nVlMedio		PICTURE "@E 99.9999"
		@nlin,nCol06 PSAY "|"
		@nlin,nCol06+2 PSAY _nPos 			PICTURE "999"
		@nlin,nCol07 PSAY "|"
		@nlin,nCol07+2 PSAY _cFaixa			PICTURE "@!"
		@nlin,nCol08 PSAY "|"
		@nlin,nCol08+1 PSAY _nFaturado		PICTURE "@E 9999,999.99"
		@nlin,nCol09 PSAY "|"
		@nlin,nCol09+1 PSAY _nPeso			PICTURE "@E 999,999.99"
		@nLin,nCol10 PSAY"|"
		@nLin,nCol11 PSAY"|"
		@nLin,nCol12 PSAY"|"
		@nLin,nCol12+2 PSAY _nComiss			PICTURE "@E 99,999.99"
		@nLin,nCol13 PSAY "|"
		nLin := nLin + 1
		SmsGrp (_cGRUPON)
		_nPesoAc	:=	_nPesoAc 	+ 	_nPeso
		_nFatAc		:=	_nFatAc		+	_nFaturado
		_nVlMedAc	:=	_nFatAc / _nPesoAc
		dbSelectArea("TEM1")
		dbSkip()
		
	Enddo
	
	//IMPRIMINDO TOTAL POR GRUPOS
	@nLin,000 PSAY	"+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	nLin := nLin + 1
	nLin := nLin + 1
	@nLin,000 PSAY	"|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
	nLin := nLin + 1
	
	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome1))
	@nlin,nCol08+1 PSAY Transform(_Grp1Sms,"@E 99,999,999.99")
	@nlin,nCol09+1 PSAY Transform(_Grp1Pes,"@E 99,999,999.99")
	@nLin,nCol10+1 PSAY Transform(_Grp1sDSR,"@E 99,999.99")
	@nLin,nCol11+1 PSAY Transform(_Grp1cDSR,"@E 99,999.99")
	@nLin,nCol12+1 PSAY Transform(_Grp1Css,"@E 99,999.99")
	@nLin,nCol13 PSAY  "|"
	nLin := nLin + 1

	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome2))
	@nlin,nCol08+2 PSAY Transform(_Grp2Sms,"@E 99,999,999.99")
	@nlin,nCol09+2 PSAY Transform(_Grp2Pes,"@E 99,999,999.99")
	@nLin,nCol10+1 PSAY Transform(_Grp2sDSR,"@E 99,999.99")
	@nLin,nCol11+1 PSAY Transform(_Grp2cDSR,"@E 99,999.99")
	@nLin,nCol12+2 PSAY Transform(_Grp2Css,"@E 99,999.99")
	@nLin,nCol13 PSAY  "|"
	nLin := nLin + 1

	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome3))
	@nlin,nCol08+1 PSAY Transform(_Grp3Sms,"@E 99,999,999.99")
	@nlin,nCol09+1 PSAY Transform(_Grp3Pes,"@E 99,999,999.99")
	@nLin,nCol10+1 PSAY Transform(_Grp3sDSR,"@E 99,999.99")
	@nLin,nCol11+1 PSAY Transform(_Grp3cDSR,"@E 99,999.99")
	@nLin,nCol12+1 PSAY Transform(_Grp3Css,"@E 99,999.99")
	@nLin,nCol13 PSAY  "|"
	nLin := nLin + 1

	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome4))
	@nlin,nCol08+1 PSAY Transform(_Grp4Sms,"@E 99,999,999.99")
	@nlin,nCol09+1 PSAY Transform(_Grp4Pes,"@E 99,999,999.99")
	@nLin,nCol10+1 PSAY Transform(_Grp4sDSR,"@E 99,999.99")
	@nLin,nCol11+1 PSAY Transform(_Grp4cDSR,"@E 99,999.99")
	@nLin,nCol12+1 PSAY Transform(_Grp4Css,"@E 99,999.99")
	@nLin,nCol13 PSAY  "|"
	nLin := nLin + 1

	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome5))
	@nlin,nCol08+1 PSAY Transform(_Grp6Sms,"@E 99,999,999.99")
	@nlin,nCol09+1 PSAY Transform(_Grp6Pes,"@E 99,999,999.99")
	@nLin,nCol10+1 PSAY Transform(_Grp6sDSR,"@E 99,999.99")
	@nLin,nCol11+1 PSAY Transform(_Grp6cDSR,"@E 99,999.99")
	@nLin,nCol12+1 PSAY Transform(_Grp6Css,"@E 99,999.99")
	@nLin,nCol13 PSAY  "|"
	nLin := nLin + 1
	
	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome6))
	@nlin,nCol08+1 PSAY Transform(_Grp7Sms,"@E 99,999,999.99")
	@nlin,nCol09+1 PSAY Transform(_Grp7Pes,"@E 99,999,999.99")
	@nLin,nCol10+1 PSAY Transform(_Grp7sDSR,"@E 99,999.99")
	@nLin,nCol11+1 PSAY Transform(_Grp7cDSR,"@E 99,999.99")
	@nLin,nCol12+1 PSAY Transform(_Grp7Css,"@E 99,999.99")
	@nLin,nCol13 PSAY  "|"
	nLin := nLin + 1

	//Everson - 19/05/2021. Chamado 14094.
	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome7))
	@nlin,nCol08+1 PSAY Transform(_Grp8Sms,"@E 99,999,999.99")
	@nlin,nCol09+1 PSAY Transform(_Grp8Pes,"@E 99,999,999.99")
	@nLin,nCol10+1 PSAY Transform(_Grp8sDSR,"@E 99,999.99")
	@nLin,nCol11+1 PSAY Transform(_Grp8cDSR,"@E 99,999.99")
	@nLin,nCol12+1 PSAY Transform(_Grp8Css,"@E 99,999.99")
	@nLin,nCol13 PSAY  "|"
	nLin := nLin + 1

	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome8))
	@nlin,nCol08+1 PSAY Transform(_Grp9Sms,"@E 99,999,999.99")
	@nlin,nCol09+1 PSAY Transform(_Grp9Pes,"@E 99,999,999.99")
	@nLin,nCol10+1 PSAY Transform(_Grp9sDSR,"@E 99,999.99")
	@nLin,nCol11+1 PSAY Transform(_Grp9cDSR,"@E 99,999.99")
	@nLin,nCol12+1 PSAY Transform(_Grp9Css,"@E 99,999.99")
	@nLin,nCol13 PSAY  "|"
	nLin := nLin + 1

	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome9))
	@nlin,nCol08+1 PSAY Transform(_Grp10Sms,"@E 99,999,999.99")
	@nlin,nCol09+1 PSAY Transform(_Grp10Pes,"@E 99,999,999.99")
	@nLin,nCol10+1 PSAY Transform(_Grp10sDSR,"@E 99,999.99")
	@nLin,nCol11+1 PSAY Transform(_Grp10cDSR,"@E 99,999.99")
	@nLin,nCol12+1 PSAY Transform(_Grp10Css,"@E 99,999.99")
	@nLin,nCol13 PSAY  "|"
	nLin := nLin + 1

	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome10))
	@nlin,nCol08+1 PSAY Transform(_Grp11Sms,"@E 99,999,999.99")
	@nlin,nCol09+1 PSAY Transform(_Grp11Pes,"@E 99,999,999.99")
	@nLin,nCol10+1 PSAY Transform(_Grp11sDSR,"@E 99,999.99")
	@nLin,nCol11+1 PSAY Transform(_Grp11cDSR,"@E 99,999.99")
	@nLin,nCol12+1 PSAY Transform(_Grp11Css,"@E 99,999.99")
	@nLin,nCol13 PSAY  "|"
	nLin := nLin + 1

	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome11))
	@nlin,nCol08+1 PSAY Transform(_Grp12Sms,"@E 99,999,999.99")
	@nlin,nCol09+1 PSAY Transform(_Grp12Pes,"@E 99,999,999.99")
	@nLin,nCol10+1 PSAY Transform(_Grp12sDSR,"@E 99,999.99")
	@nLin,nCol11+1 PSAY Transform(_Grp12cDSR,"@E 99,999.99")
	@nLin,nCol12+1 PSAY Transform(_Grp12Css,"@E 99,999.99")
	@nLin,nCol13 PSAY  "|"
	nLin := nLin + 1

	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome12))
	@nlin,nCol08+1 PSAY Transform(_Grp13Sms,"@E 99,999,999.99")
	@nlin,nCol09+1 PSAY Transform(_Grp13Pes,"@E 99,999,999.99")
	@nLin,nCol10+1 PSAY Transform(_Grp13sDSR,"@E 99,999.99")
	@nLin,nCol11+1 PSAY Transform(_Grp13cDSR,"@E 99,999.99")
	@nLin,nCol12+1 PSAY Transform(_Grp13Css,"@E 99,999.99")
	@nLin,nCol13 PSAY  "|"
	nLin := nLin + 1

	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome13))
	@nlin,nCol08+1 PSAY Transform(_Grp14Sms,"@E 99,999,999.99")
	@nlin,nCol09+1 PSAY Transform(_Grp14Pes,"@E 99,999,999.99")
	@nLin,nCol10+1 PSAY Transform(_Grp14sDSR,"@E 99,999.99")
	@nLin,nCol11+1 PSAY Transform(_Grp14cDSR,"@E 99,999.99")
	@nLin,nCol12+1 PSAY Transform(_Grp14Css,"@E 99,999.99")
	@nLin,nCol13 PSAY  "|"
	nLin := nLin + 1

	@nlin,000 PSAY "|Total "+UPPER(alltrim(_cNome14))
	@nlin,nCol08+1 PSAY Transform(_Grp15Sms,"@E 99,999,999.99")
	@nlin,nCol09+1 PSAY Transform(_Grp15Pes,"@E 99,999,999.99")
	@nLin,nCol10+1 PSAY Transform(_Grp15sDSR,"@E 99,999.99")
	@nLin,nCol11+1 PSAY Transform(_Grp15cDSR,"@E 99,999.99")
	@nLin,nCol12+1 PSAY Transform(_Grp15Css,"@E 99,999.99")
	@nLin,nCol13 PSAY  "|"
	nLin := nLin + 1
	//
	
	@nlin,000 PSAY "|Outros Grupos: "
	@nlin,nCol08+1 PSAY Transform(_Grp5Sms,"@E 99,999,999.99")
	@nlin,nCol09+1 PSAY Transform(_Grp5Pes,"@E 99,999,999.99")
	@nLin,nCol10+1 PSAY Transform(_Grp5sDSR,"@E 99,999.99")
	@nLin,nCol11+1 PSAY Transform(_Grp5cDSR,"@E 99,999.99")
	@nLin,nCol12+1 PSAY Transform(_Grp5Css,"@E 99,999.99")
	@nLin,nCol13 PSAY  "|"
	
	nLin := nLin + 1
	_nTVFat		:=	0
	_nTQFat		:=	0
	_nTCFat		:=	0
	_nTCsDSR	:=  0
	_nTCcDSR	:=  0
	_Grp1Sms:=0
	_Grp2Sms:=0
	_Grp3Sms:=0
	_Grp4Sms:=0
	_Grp5Sms:=0
	_Grp6Sms:=0
	_Grp7Sms:=0

	//Everson - 19/05/2021. Chamado 14094.
	_Grp8Sms:=0
	_Grp9Sms:=0
	_Grp10Sms:=0
	_Grp11Sms:=0
	_Grp12Sms:=0
	_Grp13Sms:=0
	_Grp14Sms:=0
	_Grp15Sms:=0
	//
	
	_Grp1Pes:=0
	_Grp2Pes:=0
	_Grp3Pes:=0
	_Grp4Pes:=0
	_Grp5Pes:=0
	_Grp6Pes:=0
	_Grp7Pes:=0

	//Everson - 19/05/2021. Chamado 14094.
	_Grp8Pes:=0
	_Grp9Pes:=0
	_Grp10Pes:=0
	_Grp11Pes:=0
	_Grp12Pes:=0
	_Grp13Pes:=0
	_Grp14Pes:=0
	_Grp15Pes:=0
	//
	
	_Grp1Css:=0
	_Grp2Css:=0
	_Grp3Css:=0
	_Grp4Css:=0
	_Grp5Css:=0
	_Grp6Css:=0
	_Grp7Css:=0

	//Everson - 19/05/2021. Chamado 14094.
	_Grp8Css:=0
	_Grp9Css:=0
	_Grp10Css:=0
	_Grp11Css:=0
	_Grp12Css:=0
	_Grp13Css:=0
	_Grp14Css:=0
	_Grp15Css:=0
	
	_Grp1cDSR	:=0
	_Grp2cDSR	:=0
	_Grp3cDSR	:=0
	_Grp4cDSR	:=0
	_Grp5cDSR	:=0
	_Grp6cDSR	:=0
	_Grp7cDSR	:=0
	_Grp8cDSR	:=0
	_Grp9cDSR	:=0
	_Grp10cDSR	:=0
	_Grp11cDSR	:=0
	_Grp12cDSR	:=0
	_Grp13cDSR	:=0
	_Grp14cDSR	:=0
	_Grp15cDSR	:=0

	_Grp1sDSR	:=0
	_Grp2sDSR	:=0
	_Grp3sDSR	:=0
	_Grp4sDSR	:=0
	_Grp5sDSR	:=0
	_Grp6sDSR	:=0
	_Grp7sDSR	:=0
	_Grp8sDSR	:=0
	_Grp9sDSR	:=0
	_Grp10sDSR	:=0
	_Grp11sDSR	:=0
	_Grp12sDSR	:=0
	_Grp13sDSR	:=0
	_Grp14sDSR	:=0
	_Grp15sDSR	:=0
	
	@nLin,000 PSAY Cabec06
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
		OurSpool(NomeRel)
	Endif
	
	MS_FLUSH()

RETURN


Static Function Cabeca2a

	nLin := nLin + 1
	@nLin,000 PSAY Cabec02
	nLin := nLin + 1
	@nLin,000 PSAY Cabec03
	nLin := nLin + 1
	@nLin,000 PSAY Cabec04
	nLin := nLin + 1
	@nLin,000 PSAY Cabec05
	nLin := nLin + 1
	@nLin,000 PSAY Cabec06
	nLin := nLin + 1

Return

Static Function Cabeca2B

	_cProduto   :=	">>>"
	_cDescric	:=	" >>  >>  >>  >>"
	@nLin,000 PSAY "|"
	@nLin,050 PSAY _cProduto		PICTURE "@!"
	@nLin,062 PSAY _cDescric		PICTURE "@!"
	@nLin,081 PSAY "|"
	dbSelectArea("TEM6")
	dbSeek(_cVend + _cGRUPON +  _cTabela + _cGrupo)
	_nPosi		:=		TEM6->T6_POSIP
	_cTabela	:=		TEM6->T6_TABELA	+ " " +TEM6->T6_TABFAIP
	_nPesoAc	:=		TEM6->T6_QTDADE
	_nComiss	:=		(_nPesoAc / 1000) * TEM6->T6_VLFAI
	@nLin,nCol05+2 PSAY _nVlMedAc		PICTURE "@E 99.9999"
	@nlin,nCol06 PSAY "|"
	@nLin,nCol06+2 PSAY _nPosi			PICTURE "999"
	@nLin,nCol09 PSAY "|"
	@nlin,nCol09 PSAY _cTabela			PICTURE "@!"
	@nLin,nCol10 PSAY "|"
	@nlin,nCol10+1 PSAY _nFatAc			PICTURE "@E 9999,999.99"
	@nLin,nCol08 PSAY "|"
	@nlin,nCol08+1 PSAY _nPesoAc			PICTURE "@E 999,999.99"
	@nLin,nCol12 PSAY"|"
	@nLin,nCol12+2 PSAY _nComiss			PICTURE "@E 99,999.99"
	@nLin,nCol13 PSAY "|"
	nLin := nLin + 1
	_nPesoAc	:=	0
	_nFatAc		:=	0
	_nVlMedAc	:=	0

return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Totaliza por grupos                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function AD0012C

	Private _Grp1Sms:=0
	Private _Grp2Sms:=0
	Private _Grp3Sms:=0
	Private _Grp4Sms:=0
	Private _Grp5Sms:=0
	Private _Grp6Sms:=0
	Private _Grp7Sms:=0

	//Everson - 19/05/2021. Chamado 14094.
	Private _Grp8Sms :=0
	Private _Grp9Sms :=0
	Private _Grp10Sms:=0
	Private _Grp11Sms:=0
	Private _Grp12Sms:=0
	Private _Grp13Sms:=0
	Private _Grp14Sms:=0
	Private _Grp15Sms:=0
	//
	
	cDesc1       := "Este programa tem como objetivo imprimir relatorio "
	cDesc2       := "de acordo com os parametros informados pelo usuario."
	cDesc3       := ""
	cPict        := ""
	titulo       := "DEMONSTRATIVO DE VENDAS - REGIAO x PRODUTO"
	
	cPerg:=PADR("AD012C",10," ")
	
	Cabec1 		:= "Periodo de : "+dtoc(mv_par01)+" Ate : "+dtoc(mv_par02)
	Cabec1		:= space(61-(len(Cabec1)/2)) + Cabec1
	Cabec2      := ""
	imprime     := .T.
	aOrd 		:= {}
	lEnd        := .F.
	lAbortPrint := .F.
	CbTxt       := ""
	limite      := 250
	tamanho     := "G"
	nomeprog    := "AD0012C" // Coloque aqui o nome do programa para impressao no cabecalho
	nTipo       := 18
	aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	nLastKey    := 0
	cbtxt      	:= Space(10)
	cbcont     	:= 00
	CONTFL     	:= 01
	m_pag      	:= 01
	wnrel      	:= "AD0012C" // Coloque aqui o nome do arquivo usado para impressao em disco
	nomerel		:= "AD0012C"
	cString 	:= "SD2"
	nCol		:= 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nomerel := SetPrint(cString,nomerel,,Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)
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
	//RptStatus ({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	RunRep()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  15/04/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunRep()

	Local nOrdem
	Local _nI 	:= 0
	Local _nCi	:= 0
	nLin:=8
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//SetRegua(RecCount())
	
	DbSelectArea("TEM1")
	
	If mv_par05	== 1		// ordem por supervisor
		cIndex   	:=	 "T1_SUPER + T1_VEND + T1_GRUPOP + T1_GRUPON + T1_PROD"
		IndRegua( "TEM1", _cNomTrb, cIndex,,,"Criando Indice3 ..." )
		Cabec2	:=	"Supervisor: " + TEM1->T1_SUPER + " - " + TEM1->T1_NOMSUP
	else 					// ordem por regiao
		cIndex   	:=	 "T1_REGIAO + T1_VEND + T1_GRUPOP + T1_GRUPON + T1_PROD"
		IndRegua( "TEM1", _cNomTrb, cIndex,,,"Criando Indice3 ..." )
		Cabec2	:=	"Regiao: " + 	TEM1->T1_REGIAO+ " - " + TEM1->T1_NOMREG
	Endif
	_cGrUpoP	:=""
	_cGrupoN	:=""
	_aVend		:={}
	_aAcum		:={}
	_Pos		:=0
	nLin		:= 90
	_nAcVR		:=	0
	_nAcTol		:=	0
	dbgotop()
	_cVend		:=TEM1->T1_VEND
	_cGrupoP	:=TEM1->T1_GRUPOP
	_cGrupoN	:=""
	_nIdx		:= 0
	
	While !EOF()
		If	!_bFlagVend
			If _cCodVen != TEM1->T1_VEND .and. !empty(_cCodVen)
				dbSelectArea("TEM1")
				dbskip()
				Loop
			Endif
			If 	!TEM1->T1_VEND$_cSupVends .and. !empty(_cSupVends)
				dbSelectArea("TEM1")
				dbskip()
				Loop
			Endif
		Endif
		If _cVend	!=TEM1->T1_VEND .OR. _cGrupoP	!=TEM1->T1_GRUPOP
			AADD(_aAcum,{_cVend,_cGrupoP,_nAcVR,_nAcTol})
			_nAcVR	:=	0
			_nAcTol	:=	0
			_cVend	:=TEM1->T1_VEND 
			_cGrupoP	:=TEM1->T1_GRUPOP
		Endif
		If _cGrupoN	!=TEM1->T1_GRUPON
			AADD(_aVend,{T1_VEND,T1_GRUPOP,T1_GRUPON,T1_PROD,T1_NOMVEND,T1_NOMEGN,T1_QTDADE,T1_VLMEDIO,T1_TABFAIN,T1_VALFAIN,T1_SUPER,T1_NOMSUP,T1_REGIAO,T1_NOMREG,T1_FATUR})
			//			********************************************************************************************************
			//              1         2         3        4         5          6         7         8           9          10       11       12       13          14        15
			_cGrupoN	:=TEM1->T1_GRUPON
			_nIdx++
		Else
			_aVend[_nIdx][07]	:= 		_aVend[_nIdx][07] +	T1_QTDADE
			_aVend[_nIdx][15]	:= 		_aVend[_nIdx][15] +	T1_FATUR
			_aVend[_nIdx][08]	:= 		_aVend[_nIdx][15] /	_aVend[_nIdx][07]
		Endif
		_nAcVR	:=	_nAcVR  + T1_VALFAIN
		_nAcTol	:=	_nAcTol + T1_QTDADE
		dbskip()
	Enddo
	_cVend	:=	""
	_nVends	:=	LEN(_aVend)
	_nAcums	:=	LEN(_aAcum)
	_nTi	:=	1
	_nCola	:=  0		// posicao da coluna de impressao
	_xVez	:=	.F.		// se e a primeira vez
	_nConta	:=	1
	_nAcVlr	:=	0
	_nAcTon	:=	0
	For _nI	:=	_nConta to _nVends
		
		If nLin > 55 .or. _aVend[_nI][1]	!=	_cVend
			If _xVez
				Totaliz()
				nlin++
				@nLin,000 PSAY "|__________________________________________________________________________________________________________________________________________________________________________________________________________________|"
				nlin++
				//	_nI	:=	_nCi - 1
			Endif
			If mv_par05	== 1		// ordem por supervisor
				Cabec2	:=	"Supervisor: " + _aVend[_nI][11] + " - " + _aVend[_nI][12]
			else 					// ordem por regiao
				Cabec2	:=	"Regiao: " + 	_aVend[_nI][13]+ " - " + _aVend[_nI][14]
			Endif
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
			@nLin,000 PSAY " __________________________________________________________________________________________________________________________________________________________________________________________________________________ "
			nlin++
			@nLin,000 PSAY "|  REGIAO : " + _aVend[_nI][1] + " - " + _aVend[_nI][5]
			nlin++
			@nLin,000 PSAY "|__________________________________________________________________________________________________________________________________________________________________________________________________________________|"							
			_xVez	:=	.T.
			_cVend	:=	_aVend[_nI][1]
		Endif
		Impcabec()
		_nCola		:= 2
		@nLin,000 	PSAY "|"
		For _nCi	:=	_nI		to	_nVends
			If _aVend[_nI][1]	!=	_aVend[_nCi][1]
				_nI	:=	_nCi - 1
				Exit
			Endif
			@nLin,_nCola 	PSAY _aVend[_nCi][7] PICTURE "999999"
			@nLin,_nCola+07 PSAY "|"
			@nLin,_nCola+09 PSAY _aVend[_nCi][8]PICTURE "@E 99.999"
			@nLin,_nCola+16 PSAY "|"
			@nLin,_nCola+18 PSAY _aVend[_nCi][9]
			@nLin,_nCola+20 PSAY "|"
			@nLin,_nCola+24 PSAY _aVend[_nCi][10]PICTURE "@E 999.99"
			@nLin,_nCola+30 PSAY "|"
			_nCola	:= _nCola + 32
			If _nCola	>= 195
				_nI	:=	_nCi
				Exit
			Endif
		Next _nCi
		nlin++
		@nLin,000 PSAY "|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
		If _nCi > _nVends
			_nI	:=	_nCi - 1
			Totaliz()
			nlin++
			@nLin,000 PSAY "|__________________________________________________________________________________________________________________________________________________________________________________________________________________|"
			Exit
		Endif
	Next _nI
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o cancelamento pelo usuario...                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*
	If lAbortPrint
	@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
	Exit
	Endif
	*/
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho do relatorio. . .                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
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

Static Function ImpCabec()
	
	nLin++
	_nCol		:= 2
	Cabec10		:=	"|"
	@nLin,000	PSAY "|"
	For _nXi 	:=	_nI to _nVends
		If _aVend[_nI][1]	!=	_aVend[_nXi][1]
			Exit
		Endif
		_cText	:=	_aVend[_nXi][3] + " " + alltrim(left(_aVend[_nXi][6],22))
		_nPoC	:=	15 -	(len(_cText)/2)
		@nLin,_nCol+_nPOc 	PSAY _cText
		@nLin,_nCol+30 	PSAY "|"
		_nCol	:= _nCol + 32
		Cabec10	:=	Cabec10 + "  Qtd   | R$/KG  |Tab|   V.R   |"
		If 	_nCol	>= 195
			Exit
		Endif
		
	Next _nXi
	
	nLin++
	@nLin,000 PSAY Cabec10
	nLin++
	@nLin,000 PSAY "|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
	nLin++

Return

Static Function Totaliz

	nLin++
	_nIx	:=	_nI - 1
	
	@nLin,000 PSAY "|==================================================================================================================================================================================================================|"
	_Cabec10		:=	"|"
	_Cabec11		:=	"|"
	_Cabec12		:=	"|"
	_nCtCol			:=	0
	
	For _nXi 	:=	_nTi to _nAcums
		If _aVend[_nIx][1]	!=	_aAcum[_nXi][1]
			_Cabec10	:=	_Cabec10 + "Grupo |   Vlr    | Tonelag |"
			_Cabec11	:=	_Cabec11 + "Prod  |Referencia|  Total  |"
			_Cabec12	:=	_Cabec12 + "------+----------+---------|"
			Exit
		Endif
		_Cabec10	:=	_Cabec10 + "Grupo |   Vlr    | Tonelag |"
		_Cabec11	:=	_Cabec11 + "Prod  |Referencia|  Total  |"
		_Cabec12	:=	_Cabec12 + "------+----------+---------|"
		_nCtCol ++
		If 	_nCtCol	==	7
			Exit
		Endif
		_nCtCol ++
	Next _nXi
	If _nXi	>	_nAcums
		_Cabec10	:=	_Cabec10 + "Grupo |   Vlr    | Tonelag |"
		_Cabec11	:=	_Cabec11 + "Prod  |Referencia|  Total  |"
		_Cabec12	:=	_Cabec12 + "------+----------+---------|"
	Endif
	nLin++
	@nLin,000 PSAY _Cabec10
	nLin++
	@nLin,000 PSAY _Cabec11
	nLin++
	@nLin,000 PSAY _Cabec12
	nLin++
	_nAcVlr		:=	0
	_nAcTon		:=	0
	_nColB		:= 	0
	@nLin,_nColB 		PSAY "|"
	For _nXi	:=	_nTi to _nAcums
		
		If _aVend[_nIx][1]	==	_aAcum[_nXi][1]
			@nLin,_nColB + 02 	PSAY _aAcum[_nXi][2]		//grupo pai
			@nLin,_nColB + 07	PSAY "|"
			@nLin,_nColB + 09 	PSAY _aAcum[_nXi][3]		PICTURE "@E 99,999.99"
			@nLin,_nColB + 18	PSAY "|"
			@nLin,_nColB + 19 	PSAY _aAcum[_nXi][4]		PICTURE "@E 999999.99"
			@nLin,_nColB + 28	PSAY "|"
			_nColB		:= _nColB	+ 28
			_nAcVlr	:=	_nAcVlr	+ _aAcum[_nXi][3]
			_nAcTon	:=	_nAcTon + _aAcum[_nXi][4]
			If _nColB	>= 198
				_nColB	:= 0
				nLin++
				@nLin,_nColB 		PSAY "|"
			Endif
		Else
			@nLin,_nColB + 01 	PSAY "TOTAL"
			@nLin,_nColB + 07	PSAY "|"
			@nLin,_nColB + 08 	PSAY _nAcVlr				PICTURE "@E 999,999.99"
			@nLin,_nColB + 18	PSAY "|"
			@nLin,_nColB + 19 	PSAY _nAcTon				PICTURE "@E 9999999.9"
			@nLin,_nColB + 28	PSAY "|"
			EXIT
		Endif
	Next _nXi
	If _nXi	>	_nAcums
		@nLin,_nColB + 01 	PSAY "TOTAL"
		@nLin,_nColB + 07	PSAY "|"
		@nLin,_nColB + 08 	PSAY _nAcVlr				PICTURE "@E 999,999.99"
		@nLin,_nColB + 18	PSAY "|"
		@nLin,_nColB + 19 	PSAY _nAcTon				PICTURE "@E 9999999.9"
		@nLin,_nColB + 28	PSAY "|"
	Endif
	_nTi	:=		_nXi

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VERIFICA USUARIO                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function VerificaUser()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//_cUserName  := Subs(cUsuario,7,15)   // Nome do Usuario
	_cUserName  := Alltrim(cusername)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 1a. Verificacao - E' Gerente ?                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If ! Alltrim(_cUserName) $ GetMV("MV_GERENTE")         // Se for gerente nao tem Filtro
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ 2a. Verificacao - E' Supervisor ?                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SZR")
		dbSetOrder(2)            // ZR_FILIAL+ZR_DESCRIC
		If dbSeek( xFilial("SZR")+_cUserName )
			_lVnd:=.T.
			_cCodSup := SZR->ZR_CODIGO            // Busca Codigo Supervisor
			
			dbSelectArea("SA3")
			//		dbSetOrder(9)        // A3_FILIAL+A3_SUPER
			dbSetOrder(5)        // A3_FILIAL+A3_SUPER
			If dbSeek( xFilial("SA3")+_cCodSup )
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Armazena em _cSupVends todos os Vendedores do Supervisor     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				_cSupVends  := ""
				Do While !Eof() .and. xFilial("SA3") == SA3->A3_FILIAL	.and. ;
					_cCodSup       == SA3->A3_CODSUP
					
					_cSupVends  :=  _cSupVends + SA3->A3_COD+"/"
					
					dbSelectArea("SA3")
					dbSkip()
				Enddo
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Filtra Clientes pelos Vendedores do Supervisor               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				/*If !Empty(_cSupVends)
				dbSelectArea("SA1")
				Set Filter to A1_VEND  $ _cSupVends
				Endif
				*/
				
			Endif
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ 3a. Verificacao - E' Vendedor ?                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SA3")
			dbSetOrder(2)
			If dbSeek( xFilial("SA3")+_cUserName )
				
				_cCodVen := SA3->A3_COD              // Busca Codigo Vendedor
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Filtra Clientes pelo Codigo do Vendedor                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//	dbSelectArea("SA1")
				//	Set Filter to A1_VEND  == _cCodVen
				
				_lVnd:=.T.
				
			Endif
			
		Endif
		
	Endif
	
	If _cSupVends!='' .or. _cCodVen!=''
		_bFlagVend:=.F.
	Endif

Return(_lVnd)

Static Function SmsGrp (_GrpAT) //SOMA POR GRUPOS

	IF   (_GrpAT$_PERG1)
		_Grp1Sms	+=_nFaturado
		_Grp1Pes	+=_nPeso
		_Grp1Css	+=_nComiss
		
		if Len(aDSR) > 0
			_Grp1sDSR	:= _Grp1Css*(aDSR[3]/aDSR[2])
			_Grp1cDSR	:= _Grp1Css-_Grp1sDSR
		endif
		
	ELSEIF (_GrpAT$_PERG2)
		_Grp2Sms	+=_nFaturado
		_Grp2Pes	+=_nPeso
		_Grp2Css	+=_nComiss

		if Len(aDSR) > 0
			_Grp2sDSR	:= _Grp2Css*(aDSR[3]/aDSR[2])
			_Grp2cDSR	:= _Grp2Css-_Grp2sDSR
		endif

	ELSEIF (_GrpAT$_PERG3)
		_Grp3Sms	+=_nFaturado
		_Grp3Pes	+=_nPeso
		_Grp3Css	+=_nComiss
		
		if Len(aDSR) > 0
			_Grp3sDSR	:= _Grp3Css*(aDSR[3]/aDSR[2])
			_Grp3cDSR	:= _Grp3Css-_Grp3sDSR
		endif

	ELSEIF (_GrpAT$_PERG4)
		_Grp4Sms	+=_nFaturado
		_Grp4Pes	+=_nPeso
		_Grp4Css	+=_nComiss
		
		if Len(aDSR) > 0
			_Grp4sDSR	:= _Grp4Css*(aDSR[3]/aDSR[2])
			_Grp4cDSR	:= _Grp4Css-_Grp4sDSR
		endif

	ELSEIF (_GrpAT$_PERG5)            //Mauricio
		_Grp6Sms	+=_nFaturado
		_Grp6Pes	+=_nPeso
		_Grp6Css	+=_nComiss
		
		if Len(aDSR) > 0
			_Grp6sDSR	:= _Grp6Css*(aDSR[3]/aDSR[2])
			_Grp6cDSR	:= _Grp6Css-_Grp6sDSR
		endif
	
	ELSEIF (_GrpAT$_PERG6)            //Mauricio
		_Grp7Sms	+=_nFaturado
		_Grp7Pes	+=_nPeso
		_Grp7Css	+=_nComiss
		
		if Len(aDSR) > 0
			_Grp7sDSR	:= _Grp7Css*(aDSR[3]/aDSR[2])
			_Grp7cDSR	:= _Grp7Css-_Grp7sDSR
		endif

	//Everson - 19/05/2021. Chamado 14094.	
	ELSEIF (_GrpAT$_PERG7)
		_Grp8Sms	+=_nFaturado
		_Grp8Pes	+=_nPeso
		_Grp8Css	+=_nComiss
		
		if Len(aDSR) > 0
			_Grp8sDSR	:= _Grp8Css*(aDSR[3]/aDSR[2])
			_Grp8cDSR	:= _Grp8Css-_Grp8sDSR
		endif

	ELSEIF (_GrpAT$_PERG8)
		_Grp9Sms	+=_nFaturado
		_Grp9Pes	+=_nPeso
		_Grp9Css	+=_nComiss
		
		if Len(aDSR) > 0
			_Grp9sDSR	:= _Grp9Css*(aDSR[3]/aDSR[2])
			_Grp9cDSR	:= _Grp9Css-_Grp9sDSR
		endif

	ELSEIF (_GrpAT$_PERG9)
		_Grp10Sms	+=_nFaturado
		_Grp10Pes	+=_nPeso
		_Grp10Css	+=_nComiss	
		
		if Len(aDSR) > 0
			_Grp10sDSR	:= _Grp10Css*(aDSR[3]/aDSR[2])
			_Grp10cDSR	:= _Grp10Css-_Grp10sDSR
		endif

	ELSEIF (_GrpAT$_PERG10)
		_Grp11Sms	+=_nFaturado
		_Grp11Pes	+=_nPeso
		_Grp11Css	+=_nComiss
		
		if Len(aDSR) > 0
			_Grp11sDSR	:= _Grp11Css*(aDSR[3]/aDSR[2])
			_Grp11cDSR	:= _Grp11Css-_Grp11sDSR
		endif

	ELSEIF (_GrpAT$_PERG11)
		_Grp12Sms+=_nFaturado
		_Grp12Pes+=_nPeso
		_Grp12Css+=_nComiss

		if Len(aDSR) > 0
			_Grp12sDSR	:= _Grp12Css*(aDSR[3]/aDSR[2])
			_Grp12cDSR	:= _Grp12Css-_Grp12sDSR
		endif

	ELSEIF (_GrpAT$_PERG12)
		_Grp13Sms	+=_nFaturado
		_Grp13Pes	+=_nPeso
		_Grp13Css	+=_nComiss
		
		if Len(aDSR) > 0
			_Grp13sDSR	:= _Grp13Css*(aDSR[3]/aDSR[2])
			_Grp13cDSR	:= _Grp13Css-_Grp13sDSR
		endif

	ELSEIF (_GrpAT$_PERG13)
		_Grp14Sms	+=_nFaturado
		_Grp14Pes	+=_nPeso
		_Grp14Css	+=_nComiss
		
		if Len(aDSR) > 0
			_Grp14sDSR	:= _Grp14Css*(aDSR[3]/aDSR[2])
			_Grp14cDSR	:= _Grp14Css-_Grp14sDSR
		endif

	ELSEIF (_GrpAT$_PERG14)
		_Grp15Sms	+=_nFaturado
		_Grp15Pes	+=_nPeso
		_Grp15Css	+=_nComiss
		
		if Len(aDSR) > 0
			_Grp15sDSR	:= _Grp15Css*(aDSR[3]/aDSR[2])
			_Grp15cDSR	:= _Grp15Css-_Grp15sDSR
		endif
	
	ELSE
		_Grp5Sms	+=_nFaturado
		_Grp5Pes	+=_nPeso
		_Grp5Css	+=_nComiss
		
		if Len(aDSR) > 0
			_Grp5sDSR	:= _Grp5Css*(aDSR[3]/aDSR[2])
			_Grp5cDSR	:= _Grp5Css-_Grp5sDSR
		endif
	End

Return

/* Funcao para acumular os totais processados  */
Static Function fAtuTot()

	_nTot1G1	+=  _Grp1Sms
	_nTot2G1	+=	_Grp2Sms
	_nTot3G1	+=	_Grp3Sms
	_nTot4G1	+=	_Grp4Sms
	_nTot5G1	+=	_Grp5Sms
	_nTot6G1	+=	_Grp6Sms
	_nTot7G1	+=	_Grp7Sms
	
	//Everson - 19/05/2021. Chamado 14094.
	_nTot8G1	+=	_Grp8Sms
	_nTot9G1	+=	_Grp9Sms
	_nTot10G1	+=	_Grp10Sms
	_nTot11G1	+=	_Grp11Sms
	_nTot12G1	+=	_Grp12Sms
	_nTot13G1	+=	_Grp13Sms
	_nTot14G1	+=	_Grp14Sms
	_nTot15G1	+=	_Grp15Sms
	//

	_nTot1G2	+= _Grp1Pes
	_nTot2G2	+= _Grp2Pes
	_nTot3G2	+= _Grp3Pes
	_nTot4G2	+= _Grp4Pes
	_nTot5G2	+= _Grp5Pes
	_nTot6G2	+= _Grp6Pes
	_nTot7G2	+= _Grp7Pes

	//Everson - 19/05/2021. Chamado 14094.
	_nTot8G2	+= _Grp8Pes
	_nTot9G2	+= _Grp9Pes
	_nTot10G2	+= _Grp10Pes
	_nTot11G2	+= _Grp11Pes
	_nTot12G2	+= _Grp12Pes
	_nTot13G2	+= _Grp13Pes
	_nTot14G2	+= _Grp14Pes
	_nTot15G2	+= _Grp15Pes
	//
	
	_nTot1G3	+= _nTQFat 	// (( _Grp1Pes / _nTQFat) * 100)
	_nTot2G3	+= _nTQFat	// (( _Grp2Pes / _nTQFat) * 100)
	_nTot3G3	+= _nTQFat	// (( _Grp3Pes / _nTQFat) * 100)
	_nTot4G3	+= _nTQFat 	// (( _Grp4Pes / _nTQFat) * 100)
	_nTot5G3	+= _nTQFat 	// (( _Grp5Pes / _nTQFat) * 100)
	_nTot6G3	+= _nTQFat 	// (( _Grp5Pes / _nTQFat) * 100)
	_nTot7G3	+= _nTQFat

	//Everson - 19/05/2021. Chamado 14094.
	_nTot8G3	+= _nTQFat
	_nTot9G3	+= _nTQFat
	_nTot10G3	+= _nTQFat
	_nTot11G3	+= _nTQFat
	_nTot12G3	+= _nTQFat
	_nTot13G3	+= _nTQFat
	_nTot14G3	+= _nTQFat
	_nTot15G3	+= _nTQFat
	//
	
	_nTot1G4	+= _Grp1Css
	_nTot2G4	+= _Grp2Css
	_nTot3G4	+= _Grp3Css
	_nTot4G4	+= _Grp4Css
	_nTot5G4	+= _Grp5Css
	_nTot6G4	+= _Grp6Css
	_nTot7G4	+= _Grp7Css

	//Everson - 19/05/2021. Chamado 14094.
	_nTot8G4	+= _Grp8Css
	_nTot9G4	+= _Grp9Css
	_nTot10G4	+= _Grp10Css
	_nTot11G4	+= _Grp11Css
	_nTot12G4	+= _Grp12Css
	_nTot13G4	+= _Grp13Css
	_nTot14G4	+= _Grp14Css
	_nTot15G4	+= _Grp15Css
	
	_nTot1SDSR	+= _Grp1sDSR
	_nTot2SDSR	+= _Grp2sDSR
	_nTot3SDSR	+= _Grp3sDSR
	_nTot4SDSR	+= _Grp4sDSR
	_nTot5SDSR	+= _Grp5sDSR
	_nTot6SDSR	+= _Grp6sDSR
	_nTot7SDSR	+= _Grp7sDSR
	_nTot8SDSR	+= _Grp8sDSR
	_nTot9SDSR	+= _Grp9sDSR
	_nTot10SDSR	+= _Grp10sDSR
	_nTot11SDSR	+= _Grp11sDSR
	_nTot12SDSR	+= _Grp12sDSR
	_nTot13SDSR	+= _Grp13sDSR
	_nTot14SDSR	+= _Grp14sDSR
	_nTot15SDSR	+= _Grp15sDSR

	_nTot1cDSR	+= _Grp1cDSR
	_nTot2cDSR	+= _Grp2cDSR
	_nTot3cDSR	+= _Grp3cDSR
	_nTot4cDSR	+= _Grp4cDSR
	_nTot5cDSR	+= _Grp5cDSR
	_nTot6cDSR	+= _Grp6cDSR
	_nTot7cDSR	+= _Grp7cDSR
	_nTot8cDSR	+= _Grp8cDSR
	_nTot9cDSR	+= _Grp9cDSR
	_nTot10cDSR	+= _Grp10cDSR
	_nTot11cDSR	+= _Grp11cDSR
	_nTot12cDSR	+= _Grp12cDSR
	_nTot13cDSR	+= _Grp13cDSR
	_nTot14cDSR	+= _Grp14cDSR
	_nTot15cDSR	+= _Grp15cDSR
	
	_nTotF1		+= _nTVFat
	_nTotF2		+= _nTQFat
	_nTotF3		+= _nTCFat
	_nTotsDSR	+= _nTCsDSR
	_nTotcDSR	+= _nTCcDSR


Return()

/* Impressao de Quadro Final com Total Geral */
Static Function fImpTot()

	&& Verifica se necessita quebra de pagina e inicia a impressao do quadro final
	
	nLin := 99
	
	If nLin > 72
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
		//	Cabeca2()
	Endif
	
	&& Acrescentadas informacoes referente aos parametros de Vendedor/Supervisor
	
	nLin ++
	@nLin,000 PSAY	cabec02
	nLin ++
	@nlin,000 PSAY "|Vendedor de  : " + MV_PAR03 + " a: " + MV_PAR04 + " "
	@nlin,nCol13 PSAY  "|"
	nLin ++
	@nlin,000 PSAY "|Supervisor de: " + MV_PAR06 + " a: " + MV_PAR07 + " "
	@nlin,nCol13 PSAY  "|"
	nLin++
	
	@nLin,000 PSAY	"|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
	
	nLin ++
	@nlin,000 PSAY "|Total Geral "+UPPER(alltrim(_cNome1))
	@nlin,nCol07 PSAY  "|"
	@nlin,nCol07+1 PSAY Transform(_nTot1G1,"@E 99,999,999.99")
	@nlin,nCol08 PSAY  "|"
	@nlin,nCol08+1 PSAY Transform(_nTot1G2,"@E 9999,999.99")
	@nlin,nCol09 PSAY  "|"
	@nlin,nCol09+2 PSAY ((_nTot1G2 /_nTot1G3)*100) 	picture "@E 999.99%"
	@nlin,nCol10 PSAY  "|"
	@nlin,nCol10+2 PSAY Transform(_nTot1SDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY  "|"
	@nlin,nCol11+2 PSAY Transform(_nTot1CDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY  "|"
	@nlin,nCol12+2 PSAY Transform(_nTot1G4,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"
	
	nLin ++
	@nlin,000 PSAY "|Total Geral "+UPPER(alltrim(_cNome2))
	@nlin,nCol07 PSAY  "|"
	@nlin,nCol07+1 PSAY Transform(_nTot2G1,"@E 99,999,999.99")
	@nlin,nCol08 PSAY  "|"
	@nlin,nCol08+1 PSAY Transform(_nTot2G2,"@E 9999,999.99")
	@nlin,nCol09 PSAY  "|"
	@nlin,nCol09+2 PSAY ((_nTot2G2 /_nTot2G3)*100) 		picture "@E 999.99%"
	@nlin,nCol10 PSAY  "|"
	@nlin,nCol10+2 PSAY Transform(_nTot2SDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY  "|"
	@nlin,nCol11+2 PSAY Transform(_nTot2CDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY  "|"
	@nlin,nCol12+2 PSAY Transform(_nTot2G4,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"
	
	nLin ++
	@nlin,000 PSAY "|Total Geral "+UPPER(alltrim(_cNome3))
	@nlin,nCol07 PSAY  "|"
	@nlin,nCol07+1 PSAY Transform(_nTot3G1,"@E 99,999,999.99")
	@nlin,nCol08 PSAY  "|"
	@nlin,nCol08+1 PSAY Transform(_nTot3G2,"@E 9999,999.99")
	@nlin,nCol09 PSAY  "|"
	@nlin,nCol09+2 PSAY ((_nTot3G2 /_nTot3G3)*100) 	picture "@E 999.99%"
	@nlin,nCol10 PSAY  "|"
	@nlin,nCol10+2 PSAY Transform(_nTot3SDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY  "|"
	@nlin,nCol11+2 PSAY Transform(_nTot3CDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY  "|"
	@nlin,nCol12+2 PSAY Transform(_nTot3G4,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"
	
	nLin ++
	@nlin,000 PSAY "|Total Geral "+UPPER(alltrim(_cNome4))
	@nlin,nCol07 PSAY  "|"
	@nlin,nCol07+1 PSAY Transform(_nTot4G1,"@E 99,999,999.99")
	@nlin,nCol08 PSAY  "|"
	@nlin,nCol08+1 PSAY Transform(_nTot4G2,"@E 9999,999.99")
	@nlin,nCol09 PSAY  "|"
	@nlin,nCol09+2 PSAY ((_nTot4G2 /_nTot4G3)*100) 	picture "@E 999.99%"
	@nlin,nCol10 PSAY  "|"
	@nlin,nCol10+2 PSAY Transform(_nTot4SDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY  "|"
	@nlin,nCol11+2 PSAY Transform(_nTot4CDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY  "|"
	@nlin,nCol12+2 PSAY Transform(_nTot4G4,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"
	
	nLin ++
	@nlin,000 PSAY "|Total Geral "+UPPER(alltrim(_cNome5))
	@nlin,nCol07 PSAY  "|"
	@nlin,nCol07+1 PSAY Transform(_nTot6G1,"@E 99,999,999.99")
	@nlin,nCol08 PSAY  "|"
	@nlin,nCol08+1 PSAY Transform(_nTot6G2,"@E 9999,999.99")
	@nlin,nCol09 PSAY  "|"
	@nlin,nCol09+2 PSAY ((_nTot6G2 /_nTot6G3)*100) 	picture "@E 999.99%"
	@nlin,nCol10 PSAY  "|"
	@nlin,nCol10+2 PSAY Transform(_nTot6SDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY  "|"
	@nlin,nCol11+2 PSAY Transform(_nTot6CDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY  "|"
	@nlin,nCol12+2 PSAY Transform(_nTot6G4,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"
	
	nLin ++
	@nlin,000 PSAY "|Total Geral "+UPPER(alltrim(_cNome6))
	@nlin,nCol07 PSAY  "|"
	@nlin,nCol07+1 PSAY Transform(_nTot7G1,"@E 99,999,999.99")
	@nlin,nCol08 PSAY  "|"
	@nlin,nCol08+1 PSAY Transform(_nTot7G2,"@E 9999,999.99")
	@nlin,nCol09 PSAY  "|"
	@nlin,nCol09+2 PSAY ((_nTot7G2 /_nTot7G3)*100) 	picture "@E 999.99%"
	@nlin,nCol10 PSAY  "|"
	@nlin,nCol10+2 PSAY Transform(_nTot7SDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY  "|"
	@nlin,nCol11+2 PSAY Transform(_nTot7CDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY  "|"
	@nlin,nCol12+2 PSAY Transform(_nTot7G4,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"

	//Everson - 19/05/2021. Chamado 14094.
	nLin ++
	@nlin,000 PSAY "|Total Geral "+UPPER(alltrim(_cNome7))
	@nlin,nCol07 PSAY  "|"
	@nlin,nCol07+1 PSAY Transform(_nTot8G1,"@E 99,999,999.99")
	@nlin,nCol08 PSAY  "|"
	@nlin,nCol08+1 PSAY Transform(_nTot8G2,"@E 9999,999.99")
	@nlin,nCol09 PSAY  "|"
	@nlin,nCol09+2 PSAY ((_nTot8G2 /_nTot8G3)*100) 	picture "@E 999.99%"
	@nlin,nCol10 PSAY  "|"
	@nlin,nCol10+2 PSAY Transform(_nTot8SDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY  "|"
	@nlin,nCol11+2 PSAY Transform(_nTot8CDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY  "|"
	@nlin,nCol12+2 PSAY Transform(_nTot8G4,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"
	
	nLin ++
	@nlin,000 PSAY "|Total Geral "+UPPER(alltrim(_cNome8))
	@nlin,nCol07 PSAY  "|"
	@nlin,nCol07+1 PSAY Transform(_nTot9G1,"@E 99,999,999.99")
	@nlin,nCol08 PSAY  "|"
	@nlin,nCol08+1 PSAY Transform(_nTot9G2,"@E 9999,999.99")
	@nlin,nCol09 PSAY  "|"
	@nlin,nCol09+2 PSAY ((_nTot9G2 /_nTot9G3)*100) 	picture "@E 999.99%"
	@nlin,nCol10 PSAY  "|"
	@nlin,nCol10+2 PSAY Transform(_nTot9SDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY  "|"
	@nlin,nCol11+2 PSAY Transform(_nTot9CDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY  "|"
	@nlin,nCol12+2 PSAY Transform(_nTot9G4,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"

	nLin ++
	@nlin,000 PSAY "|Total Geral "+UPPER(alltrim(_cNome9))
	@nlin,nCol07 PSAY  "|"
	@nlin,nCol07+1 PSAY Transform(_nTot10G1,"@E 99,999,999.99")
	@nlin,nCol08 PSAY  "|"
	@nlin,nCol08+1 PSAY Transform(_nTot10G2,"@E 9999,999.99")
	@nlin,nCol09 PSAY  "|"
	@nLin,nCol09+2 PSAY ((_nTot10G2 /_nTot10G3)*100) 	picture "@E 999.99%"
	@nlin,nCol10 PSAY  "|"
	@nlin,nCol10+2 PSAY Transform(_nTot10SDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY  "|"
	@nlin,nCol11+2 PSAY Transform(_nTot10CDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY  "|"
	@nlin,nCol12+2 PSAY Transform(_nTot10G4,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"

	nLin ++
	@nlin,000 PSAY "|Total Geral "+UPPER(alltrim(_cNome10))
	@nlin,nCol07 PSAY  "|"
	@nlin,nCol07+1 PSAY Transform(_nTot11G1,"@E 99,999,999.99")
	@nlin,nCol08 PSAY  "|"
	@nlin,nCol08+1 PSAY Transform(_nTot11G2,"@E 9999,999.99")
	@nlin,nCol09 PSAY  "|"
	@nLin,nCol09+2 PSAY ((_nTot11G2 /_nTot11G3)*100) 	picture "@E 999.99%"
	@nlin,nCol10 PSAY  "|"
	@nlin,nCol10+2 PSAY Transform(_nTot11SDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY  "|"
	@nlin,nCol11+2 PSAY Transform(_nTot11CDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY  "|"
	@nlin,nCol12+2 PSAY Transform(_nTot11G4,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"

	nLin ++
	@nlin,000 PSAY "|Total Geral "+UPPER(alltrim(_cNome11))
	@nlin,nCol07 PSAY  "|"
	@nlin,nCol07+1 PSAY Transform(_nTot12G1,"@E 99,999,999.99")
	@nlin,nCol08 PSAY  "|"
	@nlin,nCol08+1 PSAY Transform(_nTot12G2,"@E 9999,999.99")
	@nlin,nCol09 PSAY  "|"
	@nLin,nCol09+2 PSAY ((_nTot12G2 /_nTot12G3)*100) 	picture "@E 999.99%"
	@nlin,nCol10 PSAY  "|"
	@nlin,nCol10+2 PSAY Transform(_nTot12SDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY  "|"
	@nlin,nCol11+2 PSAY Transform(_nTot12CDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY  "|"
	@nlin,nCol12+2 PSAY Transform(_nTot12G4,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"

	nLin ++
	@nlin,000 PSAY "|Total Geral "+UPPER(alltrim(_cNome12))
	@nlin,nCol07 PSAY  "|"
	@nlin,nCol07+1 PSAY Transform(_nTot13G1,"@E 99,999,999.99")
	@nlin,nCol08 PSAY  "|"
	@nlin,nCol08+1 PSAY Transform(_nTot13G2,"@E 9999,999.99")
	@nlin,nCol09 PSAY  "|"
	@nLin,nCol09+2 PSAY ((_nTot13G2 /_nTot13G3)*100) 	picture "@E 999.99%"
	@nlin,nCol10 PSAY  "|"
	@nlin,nCol10+2 PSAY Transform(_nTot13SDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY  "|"
	@nlin,nCol11+2 PSAY Transform(_nTot13CDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY  "|"
	@nlin,nCol12+2 PSAY Transform(_nTot13G4,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"

	nLin ++
	@nlin,000 PSAY "|Total Geral "+UPPER(alltrim(_cNome13))
	@nlin,nCol07 PSAY  "|"
	@nlin,nCol07+1 PSAY Transform(_nTot14G1,"@E 99,999,999.99")
	@nlin,nCol08 PSAY  "|"
	@nlin,nCol08+1 PSAY Transform(_nTot14G2,"@E 9999,999.99")
	@nlin,nCol09 PSAY  "|"
	@nLin,nCol09+2 PSAY ((_nTot14G2 /_nTot14G3)*100) 	picture "@E 999.99%"
	@nlin,nCol10 PSAY  "|"
	@nlin,nCol10+2 PSAY Transform(_nTot14SDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY  "|"
	@nlin,nCol11+2 PSAY Transform(_nTot14CDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY  "|"
	@nlin,nCol12+2 PSAY Transform(_nTot14G4,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"

	nLin ++
	@nlin,000 PSAY "|Total Geral "+UPPER(alltrim(_cNome14))
	@nlin,nCol07 PSAY  "|"
	@nlin,nCol07+1 PSAY Transform(_nTot15G1,"@E 99,999,999.99")
	@nlin,nCol08 PSAY  "|"
	@nlin,nCol08+1 PSAY Transform(_nTot15G2,"@E 9999,999.99")
	@nlin,nCol09 PSAY  "|"
	@nLin,nCol09+2 PSAY ((_nTot15G2 /_nTot15G3)*100) 	picture "@E 999.99%"
	@nlin,nCol10 PSAY  "|"
	@nlin,nCol10+2 PSAY Transform(_nTot15SDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY  "|"
	@nlin,nCol11+2 PSAY Transform(_nTot15CDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY  "|"
	@nlin,nCol12+2 PSAY Transform(_nTot15G4,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"
	//
	
	nLin++
	@nlin,000 PSAY "|Total Geral Outros Grupos: "
	@nlin,nCol07 PSAY  "|"
	@nlin,nCol07+1 PSAY Transform(_nTot5G1,"@E 99,999,999.99")
	@nlin,nCol08 PSAY  "|"
	@nlin,nCol08+1 PSAY Transform(_nTot5G2,"@E 9999,999.99")
	@nlin,nCol09 PSAY  "|"
	@nLin,nCol09+2 PSAY ((_nTot5G2 /_nTot5G3)*100) 	picture "@E 999.99%"
	@nlin,nCol10 PSAY  "|"
	@nlin,nCol10+2 PSAY Transform(_nTot5SDSR,"@E 999,999.99")
	@nlin,nCol11 PSAY  "|"
	@nlin,nCol11+2 PSAY Transform(_nTot5CDSR,"@E 999,999.99")
	@nlin,nCol12 PSAY  "|"
	@nlin,nCol12+2 PSAY Transform(_nTot5G4,"@E 999,999.99")
	@nlin,nCol13 PSAY  "|"
	
	nLin ++
	@nLin,000 PSAY	"|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
	
	nLin ++
	@nLin,000 PSAY 	"|Total Geral"
	@nlin,nCol07 PSAY  "|"
	@nlin,nCol07+1 PSAY	_nTotF1	PICTURE "@E 99,999,999.99"
	@nlin,nCol08 PSAY  "|"
	@nlin,nCol08+1 PSAY	_nTotF2	PICTURE "@E 9999,999.99"
	@nlin,nCol09 PSAY  "|"
	@nlin,nCol10 PSAY  "|"
	@nlin,nCol10+2 PSAY _nTotSDSR PICTURE "@E 999,999.99"
	@nlin,nCol11 PSAY  "|"
	@nlin,nCol11+2 PSAY _nTotCDSR PICTURE "@E 999,999.99"
	@nlin,nCol12 PSAY  "|"
	@nlin,nCol12+2 PSAY	_nTotF3	PICTURE "@E 999,999.99"
	@nlin,nCol13 PSAY  "|"
	
	nLin ++
	@nLin,000 PSAY	cabec02
	nLin++

Return()

static function _atualizaSX1()

	cPerg := PADR("AD012B",10," ")
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"01")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par01
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"02")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par02
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"03")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par03
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"04")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par04
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"05")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par05
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"06")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par06
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"07")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par07
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"08")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par08
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"09")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par09
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"10")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par10
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"11")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par11
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"12")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par12
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"13")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par13
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"14")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par14
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"15")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par15
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"17")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par17
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"18")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par18
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"19")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par19
		MsUnlock()
	endif
	
	// ALTERADO LEONARDO (HC) PARA GRAVAR NO SX1 A RESPOSTA DA PERGUNTA DAS FILIAIS
	
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"16")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par16
		MsUnlock()
	endif
	
	//Everson - 19/05/2021. Chamado 14094.
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"20")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par20
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"21")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par21
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"22")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par22
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"23")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par23
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"24")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par24
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"25")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par25
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"26")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par26
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"27")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par27
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"28")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par28
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"29")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par29
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"30")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par30
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"31")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par31
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"32")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par32
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"33")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par33
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"34")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par34
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"35")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par35
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"36")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par36
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"37")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par37
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"38")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par38
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"39")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par39
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"40")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par40
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"41")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par41
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"42")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par42
		MsUnlock()
	endif
	DBSELECTAREA("SX1")
	if dbseek(cPerg+"43")
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := mv_par43
		MsUnlock()
	endif
	//

return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³AD0012EX  ³ Autor ³ADRIANA OLIVEIRA - HC  ³ Data ³ 21/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³GERA ARQUIVO TEXTO DOS DADOS GERADOS CSV                     ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Adoro Alimenticia                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Arquivos ³ SF2/SA3/SD2/SB1/SBM/SF1/SD1                                ³±±
±±³ em Uso   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Manutencao :                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

STATIC FUNCTION AD0012EX
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se deve comprimir ou nao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	_cArqTmp := Alltrim(__RELDIR) //diretorio padrao, do usuario, para gravacao de relatorio em disco
	_cArqTmp += "DV"+DtoS(MV_PAR01)+"a"+DtoS(MV_PAR02)+".TXT"
	
	if file(_cArqTmp)
		ALERT("ARQUIVO "+_CARQTMP+" JA EXISTE, E SERA APAGADO.")
		FErase(_cArqTmp)
	endif
	
	nHdl    := fCreate(_cArqTmp)
	
	cLin    := "" // Variavel para criacao da linha do registros para gravacao
	                             
	While .t.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Prepara o cabecalho padrao para o relatorio DEMONSTRATIVO DE VENDA VENDEDOR           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cLin := "COD.VEND./;GRUPO;;;;;;VALOR;PESO;;VALOR" +_Eof
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		Endif
		
		cLin :=	"SUPERV.;;DESCRICAO;DT.FATURAM.;PREC.MEDIO;POSICAO;TABELA;FATURADO;FATURADO;CLASSIF.;REFERENCIA" +_Eof
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		Endif
		
		dbSelectArea("TEM6")
		
		If mv_par05	== 1		// ordem por supervisor
			cIndex   	:=	 "T6_SUPER + T6_VEND + T6_GRUPON + DTOS(T6_DATA)"
			IndRegua( "TEM6", _cNomTr6, cIndex,,,"Criando Indice3 ..." )
		else 					// ordem por regiao
			cIndex   	:=	 "T6_REGIAO + T6_VEND + T6_GRUPON + DTOS(T6_DATA)"
			IndRegua( "TEM6", _cNomTr6, cIndex,,,"Criando Indice3 ..." )
		Endif
		
		SetRegua(RecCount())
		dbGoTop()
		_cVend 	:=	""
		_cSuper	:=	TEM6->T6_SUPER
		_cRegiao	:=	TEM6->T6_REGIAO
		_xVez		:=	.F.
		_nTVFat		:=	0
		_nTQFat		:=	0
		_nTCFat		:=	0
		_nTCsDSR	:=  0
		_nTCcDSR	:=  0
		_xQuebra	:=	.F.
		While !EOF()
			If lAbortPrint
				Alert("*** CANCELADO PELO OPERADOR ***")
				Exit
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ESTA ROTINA VALIDA OS PARAMETROS DO SUPERVISOR E REGIAODE MERCADO  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			If	!_bFlagVend
				If _cCodVen != TEM6->T6_VEND .and. !empty(_cCodVen)
					dbSelectArea("TEM6")
					dbskip()
					Loop
				Endif
				If 	!TEM6->T6_VEND$_cSupVends .and. !empty(_cSupVends)
					dbSelectArea("TEM6")
					dbskip()
					Loop
				Endif
			Endif
			
			_cNomVen	:=		LEFT(TEM6->T6_NOMVEND,25)
			
			If mv_par05			== 1 .and. _cSuper	!=	TEM6->T6_SUPER
				_cSuper		:=	TEM6->T6_SUPER
				//			_cVend	:=	""
			ElseIf	mv_par05	== 2 .and. _cRegiao	!=	TEM6->T6_REGIAO
				_cRegiao	:=	TEM6->T6_REGIAO
				//			_cVend	:=	""
			Endif
			
			If	_cVend	!=	TEM6->T6_VEND				// FAZ A QUEBRA DO VENDEDOR
				If	_xVez			   					// IMPRIME O TOTAL DO VENDEDOR SOMENTE QUANDO NAO É A PRIMEIRA VEZ
					
					cLin := _cVend+";"+_cGRUPON+";"+_cNOMEGN+";SubTotal;"+STRTRAN(STR((_nTFaturado/_nTPeso)),".",",")+";;;"+;
					STRTRAN(STR(_nTFaturado),".",",")+";"+STRTRAN(STR(_nTPeso),".",",")+";;"+;
					STRTRAN(STR(_nTComiss),".",",") +_Eof
					If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
						If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
							Exit
						Endif
					Endif
	
					cLin :=	_cVend+";;"+"Total "+UPPER(alltrim(_cNome1))+";;;;;"+STRTRAN(STR(_Grp1Sms),".",",")+";"+;
					STRTRAN(STR(_Grp1Pes),".",",")+";"+STRTRAN(STR(((_Grp1Pes/_nTQFat)*100)),".",",")+";"+;
					STRTRAN(STR(_Grp1Css),".",",") +_Eof
					If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
						If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
							Exit
						Endif
					Endif
					
					cLin :=	_cVend+";;"+"Total "+UPPER(alltrim(_cNome2))+";;;;;"+STRTRAN(STR(_Grp2Sms),".",",")+";"+;
					STRTRAN(STR(_Grp2Pes),".",",")+";"+STRTRAN(STR(((_Grp2Pes/_nTQFat)*100)),".",",")+";"+;
					STRTRAN(STR(_Grp2Css),".",",") +_Eof
					If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
						If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
							Exit
						Endif
					Endif
					
					cLin :=	_cVend+";;"+"Total "+UPPER(alltrim(_cNome3))+";;;;;"+STRTRAN(STR(_Grp3Sms),".",",")+";"+;
					STRTRAN(STR(_Grp3Pes),".",",")+";"+STRTRAN(STR(((_Grp3Pes/_nTQFat)*100)),".",",")+";"+;
					STRTRAN(STR(_Grp3Css),".",",") +_Eof
					If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
						If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
							Exit
						Endif
					Endif
					
					cLin :=	_cVend+";;"+"Total "+UPPER(alltrim(_cNome4))+";;;;;"+STRTRAN(STR(_Grp4Sms),".",",")+";"+;
					STRTRAN(STR(_Grp4Pes),".",",")+";"+STRTRAN(STR(((_Grp4Pes/_nTQFat)*100)),".",",")+";"+;
					STRTRAN(STR(_Grp4Css),".",",") +_Eof
					If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
						If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
							Exit
						Endif
					Endif
					
					cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome5))+";;;;;"+STRTRAN(STR(_Grp6Sms),".",",")+";"+;
					STRTRAN(STR(_Grp6Pes),".",",")+";"+STRTRAN(STR(((_Grp6Pes/_nTQFat)*100)),".",",")+";"+;
					STRTRAN(STR(_Grp6Css),".",",") +_Eof
					If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
						If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
							Exit
						Endif
					Endif

					//Everson - 27/05/2021. Chamado 14631.
					cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome6))+";;;;;"+STRTRAN(STR(_Grp7Sms),".",",")+";"+;
					STRTRAN(STR(_Grp7Pes),".",",")+";"+STRTRAN(STR(((_Grp7Pes/_nTQFat)*100)),".",",")+";"+;
					STRTRAN(STR(_Grp7Css),".",",") +_Eof
					If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
						If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
							Exit
						Endif
					Endif
					//

					//Everson - 19/05/2021. Chamado 14094.
					cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome7))+";;;;;"+STRTRAN(STR(_Grp8Sms),".",",")+";"+;
					STRTRAN(STR(_Grp8Pes),".",",")+";"+STRTRAN(STR(((_Grp8Pes/_nTQFat)*100)),".",",")+";"+;
					STRTRAN(STR(_Grp8Css),".",",") +_Eof
					If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
						If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
							Exit
						Endif
					Endif

					cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome8))+";;;;;"+STRTRAN(STR(_Grp9Sms),".",",")+";"+;
					STRTRAN(STR(_Grp9Pes),".",",")+";"+STRTRAN(STR(((_Grp9Pes/_nTQFat)*100)),".",",")+";"+;
					STRTRAN(STR(_Grp9Css),".",",") +_Eof
					If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
						If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
							Exit
						Endif
					Endif

					cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome9))+";;;;;"+STRTRAN(STR(_Grp10Sms),".",",")+";"+;
					STRTRAN(STR(_Grp10Pes),".",",")+";"+STRTRAN(STR(((_Grp10Pes/_nTQFat)*100)),".",",")+";"+;
					STRTRAN(STR(_Grp10Css),".",",") +_Eof
					If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
						If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
							Exit
						Endif
					Endif

					cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome10))+";;;;;"+STRTRAN(STR(_Grp11Sms),".",",")+";"+;
					STRTRAN(STR(_Grp11Pes),".",",")+";"+STRTRAN(STR(((_Grp11Pes/_nTQFat)*100)),".",",")+";"+;
					STRTRAN(STR(_Grp11Css),".",",") +_Eof
					If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
						If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
							Exit
						Endif
					Endif

					cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome11))+";;;;;"+STRTRAN(STR(_Grp12Sms),".",",")+";"+;
					STRTRAN(STR(_Grp12Pes),".",",")+";"+STRTRAN(STR(((_Grp12Pes/_nTQFat)*100)),".",",")+";"+;
					STRTRAN(STR(_Grp12Css),".",",") +_Eof
					If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
						If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
							Exit
						Endif
					Endif

					cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome12))+";;;;;"+STRTRAN(STR(_Grp13Sms),".",",")+";"+;
					STRTRAN(STR(_Grp13Pes),".",",")+";"+STRTRAN(STR(((_Grp13Pes/_nTQFat)*100)),".",",")+";"+;
					STRTRAN(STR(_Grp13Css),".",",") +_Eof
					If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
						If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
							Exit
						Endif
					Endif

					cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome13))+";;;;;"+STRTRAN(STR(_Grp14Sms),".",",")+";"+;
					STRTRAN(STR(_Grp14Pes),".",",")+";"+STRTRAN(STR(((_Grp14Pes/_nTQFat)*100)),".",",")+";"+;
					STRTRAN(STR(_Grp14Css),".",",") +_Eof
					If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
						If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
							Exit
						Endif
					Endif

					cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome14))+";;;;;"+STRTRAN(STR(_Grp15Sms),".",",")+";"+;
					STRTRAN(STR(_Grp15Pes),".",",")+";"+STRTRAN(STR(((_Grp15Pes/_nTQFat)*100)),".",",")+";"+;
					STRTRAN(STR(_Grp15Css),".",",") +_Eof
					If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
						If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
							Exit
						Endif
					Endif
					//
					
					cLin := _cVend+";;"+"Outros Grupos"+";;;;;"+STRTRAN(STR(_Grp5Sms),".",",")+";"+;
					STRTRAN(STR(_Grp5Pes),".",",")+";"+STRTRAN(STR(((_Grp5Pes/_nTQFat)*100)),".",",")+";"+;
					STRTRAN(STR(_Grp5Css),".",",") +_Eof
					If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
						If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
							Exit
						Endif
					Endif
					
					cLin := _cVend+";;"+"Total  Sub-Regiao"+";;;;;"+STRTRAN(STR(_nTVFat),".",",")+";"+;
					STRTRAN(STR(_nTQFat),".",",")+";;"+STRTRAN(STR(_nTCFat),".",",") +_Eof
					If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
						If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
							Exit
						Endif
					Endif
					
					fAtuTot()		&& Funcao para acumular os subtotais calculados.
					
					_nTVFat		:=	0
					_nTQFat		:=	0
					_nTCFat		:=	0
					_nTCsDSR	:=  0
					_nTCcDSR	:=  0
					_Grp1Sms:=0
					_Grp2Sms:=0
					_Grp3Sms:=0
					_Grp4Sms:=0
					_Grp5Sms:=0
					_Grp6Sms:=0

					//Everson - 27/05/2021. Chamado 14631.
					_Grp7Sms:=0
					//

					//Everson - 19/05/2021. Chamado 14094.
					_Grp8Sms:=0
					_Grp9Sms:=0
					_Grp10Sms:=0
					_Grp11Sms:=0
					_Grp12Sms:=0
					_Grp13Sms:=0
					_Grp14Sms:=0
					_Grp15Sms:=0
					//
					
					_Grp1Pes:=0
					_Grp2Pes:=0
					_Grp3Pes:=0
					_Grp4Pes:=0
					_Grp5Pes:=0
					_Grp6Pes:=0

					//Everson - 27/05/2021. Chamado 14631.
					_Grp7Pes:=0
					//

					//Everson - 19/05/2021. Chamado 14094.
					_Grp8Pes:=0
					_Grp9Pes:=0
					_Grp10Pes:=0
					_Grp11Pes:=0
					_Grp12Pes:=0
					_Grp13Pes:=0
					_Grp14Pes:=0
					_Grp15Pes:=0
					//
					
					_Grp1Css:=0
					_Grp2Css:=0
					_Grp3Css:=0
					_Grp4Css:=0
					_Grp5Css:=0
					_Grp6Css:=0

					//Everson - 27/05/2021. Chamado 14631.
					_Grp7Css:=0
					//

					//Everson - 19/05/2021. Chamado 14094.
					_Grp8Css:=0
					_Grp9Css:=0
					_Grp10Css:=0
					_Grp11Css:=0
					_Grp12Css:=0
					_Grp13Css:=0
					_Grp14Css:=0
					_Grp15Css:=0
					//

				Endif
				IF !_xVez
					_xVez	:=	.T.
				Else
					_xVez	:=	.T.
				ENDIF
				_cVend	:=	TEM6->T6_VEND
				_cGrupon := "X99"
				_cNOMEGN	:=	""
				_nTFaturado :=  0
				_nTPeso 	:=  0
				_nTComiss 	:=  0
			Endif
			
			if _cGRUPON <> TEM6->T6_GRUPON .and. _cGrupon <> "X99"
				cLin := _cVend+";"+_cGRUPON+";"+_cNOMEGN+";SubTotal;"+STRTRAN(STR((_nTFaturado/_nTPeso)),".",",")+";;;"+;
					STRTRAN(STR(_nTFaturado),".",",")+";"+STRTRAN(STR(_nTPeso),".",",")+";;"+;
					STRTRAN(STR(_nTComiss),".",",") +_Eof
				If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
					If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
						Exit
					Endif
				Endif
				_nTFaturado :=  TEM6->T6_FATUR
				_nTPeso 	:=  TEM6->T6_QTDADE
				_nTComiss 	:=  (TEM6->T6_QTDADE / 1000) * TEM6->T6_VLFAI

				if Len(aDSR) > 0
					_nTComSDSR	:= _nTComiss*(aDSR[3]/aDSR[2])
					_nTComCDSR	:= _nTComiss-_nTComSDSR
				endif
			else
				_nTFaturado +=  TEM6->T6_FATUR
				_nTPeso 	+=  TEM6->T6_QTDADE
				_nTComiss 	+=  (TEM6->T6_QTDADE / 1000) * TEM6->T6_VLFAI

				if Len(aDSR) > 0
					_nTComSDSR	:= _nTComiss*(aDSR[3]/aDSR[2])
					_nTComCDSR	:= _nTComiss-_nTComSDSR
				endif
			endif
			_cGRUPON	:=		TEM6->T6_GRUPON
			_cNOMEGN	:=		TEM6->T6_NOMEGN //LEFT(TEM6->T6_NOMEGN,15)
			_dData		:=		TEM6->T6_DATA
			_nVlMedio	:=		TEM6->T6_VLMEDIO
			_nPosi		:=		TEM6->T6_POSIP
			_cTabela	:=		TEM6->T6_TABELA	+ " " +TEM6->T6_TABFAIP
			_nFaturado	:=		TEM6->T6_FATUR
			_nPeso		:=		TEM6->T6_QTDADE
			_nClass		:=		TEM6->T6_CLASS
			_nComiss	:=		(_nPeso / 1000) * TEM6->T6_VLFAI
			//_cVLMedio   :=      STR(_nVlMedio)
					
			If MV_PAR15 == 1   &&Mauricio - 27/02/13 - tratamento para parametro sintetico ou analitico...
			   cLin := _cVend+";"+_cGRUPON+";"+_cNOMEGN+";"+dTOc(_dData)+";"+STRTRAN(STR(_nVLMedio),".",",")+";"+Transform(_nPosi, "999")+";"+;
			   _cTabela+";"+STRTRAN(STR(_nFaturado),".",",")+";"+STRTRAN(STR(_nPeso),".",",")+";"+Transform(_nClass, "999.9999")+";"+;
			   STRTRAN(STR(_nComiss),".",",") +_Eof
			   If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				  If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
					Exit
				  Endif
			   Endif
			ENDIF
			
			_nTVFat		:=	_nTVFat	+	_nFaturado
			_nTQFat		:=	_nTQFat	+	_nPeso
			_nTCFat		:=	_nTCFat	+	_nComiss
			
			_nTCsDSR	:=  _nTCFat*(aDSR[3]/aDSR[2])
			_nTCcDSR	:=  _nTCFat-_nTCsDSR
			SmsGrp (_cGRUPON)
			
			dbSelectArea("TEM6")
			dbSkip()
			
		Enddo
		
		cLin :=  _cVend+";;"+"Total "+UPPER(alltrim(_cNome1))+";;;;;"+STRTRAN(STR(_Grp1Sms),".",",")+";"+;
		STRTRAN(STR(_Grp1Pes),".",",")+";"+STRTRAN(STR(((_Grp1Pes/_nTQFat)*100)),".",",")+";"+;
		STRTRAN(STR(_Grp1Css),".",",") +_Eof
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		Endif
		
		cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome2))+";;;;;"+STRTRAN(STR(_Grp2Sms),".",",")+";"+;
		STRTRAN(STR(_Grp2Pes),".",",")+";"+STRTRAN(STR(((_Grp2Pes/_nTQFat)*100)),".",",")+";"+;
		STRTRAN(STR(_Grp2Css),".",",") +_Eof
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		Endif
		
		cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome3))+";;;;;"+STRTRAN(STR(_Grp3Sms),".",",")+";"+;
		STRTRAN(STR(_Grp3Pes),".",",")+";"+STRTRAN(STR(((_Grp3Pes/_nTQFat)*100)),".",",")+";"+;
		STRTRAN(STR(_Grp3Css),".",",") +_Eof
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		Endif
		
		cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome4))+";;;;;"+STRTRAN(STR(_Grp4Sms),".",",")+";"+;
		STRTRAN(STR(_Grp4Pes),".",",")+";"+STRTRAN(STR(((_Grp4Pes/_nTQFat)*100)),".",",")+";"+;
		STRTRAN(STR(_Grp4Css),".",",") +_Eof
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		Endif
		
		cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome5))+";;;;;"+STRTRAN(STR(_Grp6Sms),".",",")+";"+;
		STRTRAN(STR(_Grp6Pes),".",",")+";"+STRTRAN(STR(((_Grp6Pes/_nTQFat)*100)),".",",")+";"+;
		STRTRAN(STR(_Grp6Css),".",",") +_Eof
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		Endif

		//Everson - 27/05/2021. Chamado 14631.
		cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome6))+";;;;;"+STRTRAN(STR(_Grp7Sms),".",",")+";"+;
		STRTRAN(STR(_Grp7Pes),".",",")+";"+STRTRAN(STR(((_Grp7Pes/_nTQFat)*100)),".",",")+";"+;
		STRTRAN(STR(_Grp7Css),".",",") +_Eof
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		Endif
		//

		//Everson - 19/05/2021. Chamado 14094.
		cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome7))+";;;;;"+STRTRAN(STR(_Grp8Sms),".",",")+";"+;
		STRTRAN(STR(_Grp8Pes),".",",")+";"+STRTRAN(STR(((_Grp8Pes/_nTQFat)*100)),".",",")+";"+;
		STRTRAN(STR(_Grp8Css),".",",") +_Eof
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		Endif

		cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome8))+";;;;;"+STRTRAN(STR(_Grp9Sms),".",",")+";"+;
		STRTRAN(STR(_Grp9Pes),".",",")+";"+STRTRAN(STR(((_Grp9Pes/_nTQFat)*100)),".",",")+";"+;
		STRTRAN(STR(_Grp9Css),".",",") +_Eof
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		Endif

		cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome9))+";;;;;"+STRTRAN(STR(_Grp10Sms),".",",")+";"+;
		STRTRAN(STR(_Grp10Pes),".",",")+";"+STRTRAN(STR(((_Grp10Pes/_nTQFat)*100)),".",",")+";"+;
		STRTRAN(STR(_Grp10Css),".",",") +_Eof
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		Endif

		cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome10))+";;;;;"+STRTRAN(STR(_Grp11Sms),".",",")+";"+;
		STRTRAN(STR(_Grp11Pes),".",",")+";"+STRTRAN(STR(((_Grp11Pes/_nTQFat)*100)),".",",")+";"+;
		STRTRAN(STR(_Grp11Css),".",",") +_Eof
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		Endif

		cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome11))+";;;;;"+STRTRAN(STR(_Grp12Sms),".",",")+";"+;
		STRTRAN(STR(_Grp12Pes),".",",")+";"+STRTRAN(STR(((_Grp12Pes/_nTQFat)*100)),".",",")+";"+;
		STRTRAN(STR(_Grp12Css),".",",") +_Eof
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		Endif

		cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome12))+";;;;;"+STRTRAN(STR(_Grp13Sms),".",",")+";"+;
		STRTRAN(STR(_Grp13Pes),".",",")+";"+STRTRAN(STR(((_Grp13Pes/_nTQFat)*100)),".",",")+";"+;
		STRTRAN(STR(_Grp13Css),".",",") +_Eof
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		Endif

		cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome13))+";;;;;"+STRTRAN(STR(_Grp14Sms),".",",")+";"+;
		STRTRAN(STR(_Grp14Pes),".",",")+";"+STRTRAN(STR(((_Grp14Pes/_nTQFat)*100)),".",",")+";"+;
		STRTRAN(STR(_Grp14Css),".",",") +_Eof
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		Endif

		cLin := _cVend+";;"+"Total "+UPPER(alltrim(_cNome14))+";;;;;"+STRTRAN(STR(_Grp15Sms),".",",")+";"+;
		STRTRAN(STR(_Grp15Pes),".",",")+";"+STRTRAN(STR(((_Grp15Pes/_nTQFat)*100)),".",",")+";"+;
		STRTRAN(STR(_Grp15Css),".",",") +_Eof
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		Endif
		//
		
		cLin := _cVend+";;"+"Outros Grupos "+";;;;;"+STRTRAN(STR(_Grp5Sms),".",",")+";"+;
		STRTRAN(STR(_Grp5Pes),".",",")+";"+STRTRAN(STR(((_Grp5Pes/_nTQFat)*100)),".",",")+";"+;
		STRTRAN(STR(_Grp5Css),".",",") +_Eof
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		Endif
		
		cLin := _cVend+";;"+"Total  Sub-Regiao"+";;;;;"+STRTRAN(STR(_nTVFat),".",",")+";"+;
		STRTRAN(STR(_nTQFat),".",",")+";;"+STRTRAN(STR(_nTCFat),".",",") +_Eof
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		Endif
		
		fAtuTot()		&& Funcao para acumular os subtotais calculados.
		
		fImpTotEX()		&& Funcao de Impressao com Total Geral
		
		_nTVFat		:=0
		_nTQFat		:=0
		_nTCFat		:=0
		_nTCsDSR	:= 0
		_nTCcDSR	:= 0
		_Grp1Sms	:=0
		_Grp2Sms	:=0
		_Grp3Sms	:=0
		_Grp4Sms	:=0
		_Grp5Sms	:=0
		_Grp6Sms	:=0

		//Everson - 27/05/2021. Chamado 14631.
		_Grp7Sms:=0
		//

		//Everson - 19/05/2021. Chamado 14094.
		_Grp8Sms:=0
		_Grp9Sms:=0
		_Grp10Sms:=0
		_Grp11Sms:=0
		_Grp12Sms:=0
		_Grp13Sms:=0
		_Grp14Sms:=0
		//
		
		_Grp1Pes:=0
		_Grp2Pes:=0
		_Grp3Pes:=0
		_Grp4Pes:=0
		_Grp5Pes:=0
		_Grp6Pes:=0

		//Everson - 27/05/2021. Chamado 14631.
		_Grp7Pes:=0
		//

		//Everson - 19/05/2021. Chamado 14094.
		_Grp8Pes:=0
		_Grp9Pes:=0
		_Grp10Pes:=0
		_Grp11Pes:=0
		_Grp12Pes:=0
		_Grp13Pes:=0
		_Grp14Pes:=0
		_Grp15Pes:=0
		//
		     
		_Grp1Css:=0
		_Grp2Css:=0
		_Grp3Css:=0
		_Grp4Css:=0
		_Grp5Css:=0
		_Grp6Css:=0

		//Everson - 27/05/2021. Chamado 14631.
		_Grp7Css:=0
		//

		//Everson - 19/05/2021. Chamado 14094.
		_Grp8Css:=0
		_Grp9Css:=0
		_Grp10Css:=0
		_Grp11Css:=0
		_Grp12Css:=0
		_Grp13Css:=0
		_Grp14Css:=0
		_Grp15Css:=0
		//
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ O arquivo texto deve ser fechado, bem como o dialogo criado na fun- ³
		//³ cao anterior.                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		exit
	end
	fClose(nHdl)

Return

/* Impressao de Quadro Final com Total Geral */
Static Function fImpTotEX()

	clin := ";;"+"Total Geral "+UPPER(alltrim(_cNome1))+";;;;;"+STRTRAN(STR(_nTot1G1),".",",")+";"+;
	STRTRAN(STR(_nTot1G2),".",",")+";"+STRTRAN(STR(((_nTot1G2 /_nTot1G3)*100)),".",",")+";"+;
	STRTRAN(STR(_nTot1G4),".",",") +_Eof
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
			return
		Endif
	Endif
	
	clin := ";;"+"Total Geral "+UPPER(alltrim(_cNome2))+";;;;;"+STRTRAN(STR(_nTot2G1),".",",")+";"+;
	STRTRAN(STR(_nTot2G2),".",",")+";"+STRTRAN(STR(((_nTot2G2 /_nTot2G3)*100)),".",",")+";"+;
	STRTRAN(STR(_nTot2G4),".",",") +_Eof
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
			return
		Endif
	Endif
	
	clin := ";;"+"Total Geral "+UPPER(alltrim(_cNome3))+";;;;;"+STRTRAN(STR(_nTot3G1),".",",")+";"+;
	STRTRAN(STR(_nTot3G2),".",",")+";"+STRTRAN(STR(((_nTot3G2 /_nTot3G3)*100)),".",",")+";"+;
	STRTRAN(STR(_nTot3G4),".",",") +_Eof
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
			return
		Endif
	Endif
	
	cLin := ";;"+"Total Geral "+UPPER(alltrim(_cNome4))+";;;;;"+STRTRAN(STR(_nTot4G1,),".",",")+";"+;
	STRTRAN(STR(_nTot4G2),".",",")+";"+STRTRAN(STR(((_nTot4G2 /_nTot4G3)*100)),".",",")+";"+;
	STRTRAN(STR(_nTot4G4),".",",") +_Eof
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
			return
		Endif
	Endif
	
	clin := ";;"+"Total Geral "+UPPER(alltrim(_cNome5))+";;;;;"+STRTRAN(STR(_nTot6G1),".",",")+";"+;
	STRTRAN(STR(_nTot6G2),".",",")+";"+STRTRAN(STR(((_nTot6G2 /_nTot6G3)*100)),".",",")+";"+;
	STRTRAN(STR(_nTot6G4),".",",") +_Eof
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
			return
		Endif
	Endif

	//Everson - 27/05/2021. Chamado 14631.
	clin := ";;"+"Total Geral "+UPPER(alltrim(_cNome6))+";;;;;"+STRTRAN(STR(_nTot7G1),".",",")+";"+;
	STRTRAN(STR(_nTot7G2),".",",")+";"+STRTRAN(STR(((_nTot7G2 /_nTot7G3)*100)),".",",")+";"+;
	STRTRAN(STR(_nTot7G4),".",",") +_Eof
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
			return
		Endif
	Endif
	//

	//Everson - 19/05/2021. Chamado 14094.
	clin := ";;"+"Total Geral "+UPPER(alltrim(_cNome7))+";;;;;"+STRTRAN(STR(_nTot8G1),".",",")+";"+;
	STRTRAN(STR(_nTot8G2),".",",")+";"+STRTRAN(STR(((_nTot8G2 /_nTot8G3)*100)),".",",")+";"+;
	STRTRAN(STR(_nTot8G4),".",",") +_Eof
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
			return
		Endif
	Endif

	clin := ";;"+"Total Geral "+UPPER(alltrim(_cNome8))+";;;;;"+STRTRAN(STR(_nTot9G1),".",",")+";"+;
	STRTRAN(STR(_nTot9G2),".",",")+";"+STRTRAN(STR(((_nTot9G2 /_nTot9G3)*100)),".",",")+";"+;
	STRTRAN(STR(_nTot9G4),".",",") +_Eof
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
			return
		Endif
	Endif

	clin := ";;"+"Total Geral "+UPPER(alltrim(_cNome9))+";;;;;"+STRTRAN(STR(_nTot10G1),".",",")+";"+;
	STRTRAN(STR(_nTot10G2),".",",")+";"+STRTRAN(STR(((_nTot10G2 /_nTot10G3)*100)),".",",")+";"+;
	STRTRAN(STR(_nTot10G4),".",",") +_Eof
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
			return
		Endif
	Endif

	clin := ";;"+"Total Geral "+UPPER(alltrim(_cNome10))+";;;;;"+STRTRAN(STR(_nTot11G1),".",",")+";"+;
	STRTRAN(STR(_nTot11G2),".",",")+";"+STRTRAN(STR(((_nTot11G2 /_nTot11G3)*100)),".",",")+";"+;
	STRTRAN(STR(_nTot11G4),".",",") +_Eof
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
			return
		Endif
	Endif

	clin := ";;"+"Total Geral "+UPPER(alltrim(_cNome11))+";;;;;"+STRTRAN(STR(_nTot12G1),".",",")+";"+;
	STRTRAN(STR(_nTot12G2),".",",")+";"+STRTRAN(STR(((_nTot12G2 /_nTot12G3)*100)),".",",")+";"+;
	STRTRAN(STR(_nTot12G4),".",",") +_Eof
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
			return
		Endif
	Endif

	clin := ";;"+"Total Geral "+UPPER(alltrim(_cNome12))+";;;;;"+STRTRAN(STR(_nTot13G1),".",",")+";"+;
	STRTRAN(STR(_nTot13G2),".",",")+";"+STRTRAN(STR(((_nTot13G2 /_nTot13G3)*100)),".",",")+";"+;
	STRTRAN(STR(_nTot13G4),".",",") +_Eof
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
			return
		Endif
	Endif

	clin := ";;"+"Total Geral "+UPPER(alltrim(_cNome13))+";;;;;"+STRTRAN(STR(_nTot14G1),".",",")+";"+;
	STRTRAN(STR(_nTot14G2),".",",")+";"+STRTRAN(STR(((_nTot14G2 /_nTot14G3)*100)),".",",")+";"+;
	STRTRAN(STR(_nTot14G4),".",",") +_Eof
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
			return
		Endif
	Endif

	clin := ";;"+"Total Geral "+UPPER(alltrim(_cNome14))+";;;;;"+STRTRAN(STR(_nTot15G1),".",",")+";"+;
	STRTRAN(STR(_nTot15G2),".",",")+";"+STRTRAN(STR(((_nTot15G2 /_nTot15G3)*100)),".",",")+";"+;
	STRTRAN(STR(_nTot15G4),".",",") +_Eof
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
			return
		Endif
	Endif
	//
	
	clin := ";;"+"Total Geral Outros Grupos: "+";;;;;"+STRTRAN(STR(_nTot5G1),".",",")+";"+;
	STRTRAN(STR(_nTot5G2),".",",")+";"+STRTRAN(STR(((_nTot5G2 /_nTot5G3)*100)),".",",")+";"+;
	STRTRAN(STR(_nTot5G4),".",",") +_Eof
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
			return
		Endif
	Endif
	
	clin := ";;"+"Total Geral"+";;;;;"+STRTRAN(STR(_nTotF1),".",",")+";"+;
	STRTRAN(STR(_nTotF2),".",",")+";;"+STRTRAN(STR(_nTotF3),".",",") +_Eof
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
			return
		Endif
	Endif

Return()
