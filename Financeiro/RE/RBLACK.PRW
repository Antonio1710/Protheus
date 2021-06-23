#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/05/01
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

User Function RBLACK()   

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio Black List ( Contas a  Receber)')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("AORD,TAMANHO,LIMITE,NOMEPROG,MV_TABPR,NTIPO")
SetPrvt("ARETURN,NLASTKEY,NLIN,NITEM,LCONTINUA,M_PAG")
SetPrvt("IMPRIME,CPERG,CSTRING,TITULO,CDESC1,CDESC2")
SetPrvt("CDESC3,NOMEREL,CABEC1,CABEC2,CABEC3,CABEC5")
SetPrvt("CABEC6,CABEC7,ATRASO,POSICA,CVEND,ASTRU")
SetPrvt("_CNOMTRB,CINDEX,_TOTSAL,_TOTDEV,_CLIENTE,_NOME")
SetPrvt("_LOJA,_REGVEND,_VENDE,_PREFIXO,CABEC4,")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  RBLACK  ³ Autor ³  Marcos Bido          ³ Data ³ 26/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio Black List ( Contas a  Receber)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Adoro Alimenticia                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Manutecao³ 22/10 Incluido Set Order no Seek do Vendedores             ³±±
±±³          ³ 22/10 Incluido consulta por supervisor de/ate              ³±±
±±³          ³                                           Heraldo          ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // Do Vendedor                          ³
//³ mv_par02             // Ate Vendedor                         ³
//³ mv_par03             // Do Vencto                            ³
//³ mv_par04             // Do Prefixo                           ³
//³ mv_par05             // Do Supervisor                        ³
//³ mv_par06             // Ate Supervisor                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aOrd             := {}
tamanho          := "P"
limite           := 80
nomeprog         := "RBLACK"
mv_tabpr         := ""
nTipo            := 18
aReturn          := { "Zebrado", 1,"Administracao", 2, 2, 1,"",1}
nLastKey         := 0
nlin             := 80
nItem            := 1
lContinua        := .T.
_bCabec			 := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
m_pag	   := 01
imprime    := .T.
_bTot	   := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPerg   := "RBLACK"
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela padrao de impressao                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cString := "SA1"
titulo  := "POSICAO FINANCEIRA DOS CLIENTES ( BLACK LIST )"
cPerg   := "RBLACK"
cDesc1  := "Este programa tem como objetivo imprimir posicao financeira"
cDesc2  := "dos clientes - por Vendedor"
cDesc3  := " "
NomeRel := "RBLACK"

_cSupVends	:=""
_cCodVen	:=""

nomerel := SetPrint(cString,Nomerel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prepara o cabecalho padrao para o relatorio                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Cabec1 := "| RBLACK "+SPACE(030)+"ADORO ALIMENTICIA" + SPACE(21) + "EMISSAO : " +DTOC(DATE())+SPACE(07)+"|"
Cabec2 := "| "+SPACE(30) + TITULO + SPACE(26)+"|"
Cabec3 := "|-------------------------------------------------------------------------------------------------------|"
Cabec5 := "|-------------------------------------------------------------------------------------------------------|"
Cabec6 := "| Cliente                           | Dt.Vali.|RISCO| Limite Cred.| Pos.Cliente | Sl. Devedor | % Deved.|"
Cabec7 := "|-------------------------------------------------------------------------------------------------------|"

atraso := 0
posica := 0
cVend  := SPACE(03)

dbSelectArea("SE1")
dbSetOrder(2)
dbGotop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a regua de processamento                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

#IFDEF WINDOWS
	Processa({|| RunCont()},Titulo )// Substituido pelo assistente de conversao do AP5 IDE em 14/05/01 ==>     Processa({|| Execute(RunCont)},Titulo )
	Return
	// Substituido pelo assistente de conversao do AP5 IDE em 14/05/01 ==>     Function RunCont
	Static Function RunCont()
	ProcRegua(RecCount())
#ELSE
	SetRegua(RecCount())
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo Temporario para totalizacao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

VerificaUser()

aStru := {}
AADD (aStru,{"TR_FILIAL"  , "C",02,0})
AADD (aStru,{"TR_CODCLI"  , "C",06,0})
AADD (aStru,{"TR_NOME"    , "C",20,0})
AADD (aStru,{"TR_LOJA"    , "C",02,0})
AADD (aStru,{"TR_PREFIXO" , "C",03,0})
AADD (aStru,{"TR_VEND"    , "C",06,0})
AADD (aStru,{"TR_DATA"    , "D",08,0})
AADD (aStru,{"TR_REGven"  , "C",03,0})
AADD (aStru,{"TR_RISCO "  , "C",03,0})
AADD (aStru,{"TR_LIMITE"  , "N",17,2})
AADD (aStru,{"TR_POSICAO" , "N",17,2})
AADD (aStru,{"TR_SALDEV"  , "N",17,2})
AADD (aStru,{"TR_PERCE"   , "N",09,2})

_cNomTrb := CriaTrab(aStru)
dbUseArea(.T.,,_cNomTrb,"TEMP",.F.,.F.)
cIndex   := "TR_VEND "
IndRegua( "TEMP", _cNomTrb, cIndex,,,"Criando Indice ..." )

_TotSal  := 0
_TotDev  := 0
_Cliente := space(06)
_Nome    := space(20)
_Open 	:= 0		//LINHA INCLUIDA

dbSelectArea("SA1")
dbSetOrder(5)

SET FILTER TO A1_SALDUP > A1_LC

dbGotop()

While !EOF()
	
	_TotSal  := 0
	_TotDev  := 0
	_Cliente := space(06)
	_LOJA    := SPACE(02)
	_RegVend := space(03)
	_Vende   := space(03)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Incrementa a regua                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	#IFnDEF WINDOWS
		IncRegua()
	#ELSE
		IncProc(1)
	#ENDIF
	
	dbSelectArea("SA1")
	
	_Cliente := SA1->A1_COD
	_loja    := SA1->A1_LOJA
	_Vende   := SA1->A1_VEND
	_Risco   := SA1->A1_RISCO
	_cCgc    := SA1->A1_CGC
	_Limite  := SA1->A1_LC
	_Limi    := 0
	
	
	// PESQUISAR SALDO DE REDE
	
	DbSelectArea("SZF")
	DbSetOrder(1)
	
	IF (dbSeek(xfilial("SZF") + _cCGC ))
		
		_Rede := ZF_REDE
		_Limi := 0
		_Open := 0
		
		DbSetOrder(3)
		dbSeek(xfilial("SZF") + _rede )
		
		Do While .not. eof() .and. ZF_REDE == _rede
			
			if ZF_LCREDE > _LIMI
				_Limi := ZF_LCREDE
				_Open := ZF_SLDREDE
			endif
			
			DbSkip()
		enddo
		
	ENDIF
	
	
	dbSelectArea("SA3")
	dbsetorder(1)				// incluido por heraldo 22/10/03
	
	
	
	IF SA3->(dbSeek(xfilial("SE1") + _Vende ))
		_RegVend := SA3->A3_REGIAO
	ENDIF
	// Incluido a consulta por supervisor  22/10/03 heraldo
	// Inicio	
/*	If SA3->A3_CODSUP < MV_PAR05 .OR.  SA3->A3_CODSUP > MV_PAR06
		dbSelectArea("SA1")
		dbskip()
	    Loop
	Endif
  */	// fim
	if substr(_RegVend,1,2) == substr(MV_PAR04,1,2)
		
		dbSelectArea("SE1")
		dbSeek(xfilial("SE1") + _cliente )
		
		_Prefixo := SE1->E1_PREFIXO
		_nome    := SE1->E1_NOMCLI
		
		while _cliente + _LOJA == SE1->E1_CLIENTE + SE1->E1_LOJA .and. _Prefixo == SE1->E1_PREFIXO
			if E1_VENCREA < MV_PAR03
				_TotDev := _TotDev + E1_SALDO
			endif
			dbskip()
		enddo
		
		// Verifica se e Rede
		If _Open <> 0
			_TotDev := _Open
			_Limite := _Limi
		endif
		
		dbSelectArea("TEMP")
		RecLock("TEMP",.T.)
		Repl TR_filial    with xFilial("SE1")
		Repl TR_codcli    with _Cliente
		Repl TR_LOJA      with _Loja
		Repl TR_nome      with _Nome
		Repl TR_prefixo   with _Prefixo
		Repl TR_vend      with _Vende
		Repl TR_regven    with _RegVend
		Repl TR_risco     with _risco
		Repl TR_saldev    with _TotDev
		Repl TR_data      with SA1->A1_VENCLC
		Repl TR_limite    with _Limite
		Repl TR_posicao   with SA1->A1_SALDUP
		
		if SA1->A1_LC > 1
			IF SA1->A1_SALDUP > 1
				Repl TR_perce with ((SA1->A1_SALDUP / SA1->A1_LC)*100)-100
			ENDIF
		ENDIF
		
		_Limi := 0
		_Open := 0
		
		MsUnLock()
	endif
	dbSelectArea("SA1")
	dbskip()
ENDDO

dbSelectArea("SA1")
SET FILTER TO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  AQUI TERMINA O PROCESSAMENTO E COMECA A IMPRESSAO DO TEMP          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SA3")
SET FILTER TO substr(MV_PAR04,1,2) == SUBSTR(SA3->A3_REGIAO,1,2)
dbGoTop()

dbSelectArea("TEMP")
dbGoTop()

_bFlagVend	:=	.F.
_bTot		:=	.F.

While !SA3->(EOF())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Incrementa a regua                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	#IFnDEF WINDOWS
		IncRegua()
	#ELSE
		IncProc(1)
	#ENDIF
	
	cabec4 := " Vendedor : " + SA3->A3_COD +" - " + SA3->A3_NOME +"  REGIAO : "+ TEMP->TR_REGVEN + "  PREFIXO : "+TEMP->TR_PREFIXO
	
	
	If nLin > 60 .and.  _cCodVen!=''
		ImpCabec()
		nLin := nLin + 1
	Endif
	
	If nLin > 60 .and. _cCodVen==''
		ImpCabec()
		nLin := nLin + 1
	Endif
	
	dbSelectArea("TEMP")
	
	If _cSupVends=='' .and. _cCodVen==''
		IF TEMP->(DbSeek(SA3->A3_cod))
			
			DO WHILE !TEMP->(EOF()) .AND. TEMP->TR_VEND == SA3->A3_COD
				@nLin,00 PSAY "|"
				@nLin,02 PSAY  TEMP->TR_CODCLI +"-"+ TEMP->TR_LOJA+" - "+TEMP->TR_NOME
				@nLin,37 PSAY  TEMP->TR_DATA
				@nLin,48 PSAY  TEMP->TR_RISCO
				@nLin,52 PSAY  TEMP->TR_LIMITE  PICTURE '@z 999,999,999.99'
				@nLin,66 PSAY  TEMP->TR_POSICAO PICTURE '@z 999,999,999.99'
				@nLin,80 PSAY  TEMP->TR_SALDEV  PICTURE '@z 999,999,999.99'
				atraso := atraso + TEMP->TR_SALDEV
				posica := posica + TEMP->TR_POSICAO
				@nLin,97 PSAY  TEMP->TR_PERCE   PICTURE '@z 999.99'
				@nLin,104 PSAY "|"
				nLin := nLin + 1
				TEMP->(dBSkip())
			ENDDO
			@nLin,00 PSAY "|"+Replic("-",103)+"|"
			nLin := nLin + 1
			@nLin,05 PSAY ' T O T A L ..............................................'
			@nLin,66 PSAY POSICA PICTURE '@z 999,999,999.99'
			@nLin,80 PSAY ATRASO PICTURE '@z 999,999,999.99'
			ATRASO := 0
			POSICA := 0
		ELSE
			nLin := nLin + 1
			@nLin,05 PSAY ' *************  NAO HA MOVIMENTO PARA ESTE VENDEDOR  ************* '
			nLin := nLin + 1
		ENDIF
	Endif

	If _cCodVen!=''
		IF TEMP->(DbSeek(SA3->A3_cod))
			
			DO WHILE !TEMP->(EOF()) .AND. TEMP->TR_VEND == SA3->A3_COD .AND. TEMP->TR_VEND==_cCodVen
				@nLin,00 PSAY "|"
				@nLin,02 PSAY  TEMP->TR_CODCLI +"-"+ TEMP->TR_LOJA+" - "+TEMP->TR_NOME
				@nLin,37 PSAY  TEMP->TR_DATA
				@nLin,48 PSAY  TEMP->TR_RISCO
				@nLin,52 PSAY  TEMP->TR_LIMITE  PICTURE '@z 999,999,999.99'
				@nLin,66 PSAY  TEMP->TR_POSICAO PICTURE '@z 999,999,999.99'
				@nLin,80 PSAY  TEMP->TR_SALDEV  PICTURE '@z 999,999,999.99'
				atraso := atraso + TEMP->TR_SALDEV
				posica := posica + TEMP->TR_POSICAO
				@nLin,97 PSAY  TEMP->TR_PERCE   PICTURE '@z 999.99'
				@nLin,104 PSAY "|"
				nLin := nLin + 1
				TEMP->(dBSkip())
			ENDDO
			If _bTot!=.T.
				@nLin,00 PSAY "|"+Replic("-",103)+"|"
				nLin := nLin + 1
				@nLin,05 PSAY ' T O T A L ..............................................'
				@nLin,66 PSAY POSICA PICTURE '@z 999,999,999.99'
				@nLin,80 PSAY ATRASO PICTURE '@z 999,999,999.99'
				ATRASO := 0
				POSICA := 0
				_bTot:=.T.
			Endif
		Endif
	Endif
	
	dbSelectArea("SA3")
	DBSKIP()
	
	If _cCodVen==''
		nLin := nLin + 1
		@nLin,00 PSAY "|"+Replic("-",103)+"|"
		nLin := nLin + 1
		nLin := 80
	Endif
	
EndDo

If _cCodVen==''
	Roda(0,"","M")
Endif

Set Device to Screen

If aReturn[5]==1
	Set Printer to
	OurSpool(NomeRel)
endif

dbSelectArea('TEMP')
dbclosearea("TEMP")
fErase(_cNomTrb+'.*')

return

******************************************************************************
// Substituido pelo assistente de conversao do AP5 IDE em 14/05/01 ==> Function ImpCabec
Static Function ImpCabec()
******************************************************************************

If _cSupVends=='' .and. _cCodVen==''
	nLin := 1
	
	@nLin,00 PSAY CHR(15)+"|"+Replic("-",103)+"|"
	nLin := nLin + 1
	
	@ nlin,00 PSAY Cabec1
	nLin := nLin + 1
	
	@nLin,00 PSAY Cabec2
	nLin := nLin + 1
	
	@nLin,00 PSAY Cabec3
	nLin := nLin + 1
	
	
	@nLin,00 PSAY Cabec4
	nLin := nLin + 1
	
	@nLin,00 PSAY Cabec5
	nLin := nLin + 1
	
	@nLin,00 PSAY Cabec6
	nLin := nLin + 1
	
	@nLin,00 PSAY Cabec7
	//nLin := nLin + 1
Endif

If _bCabec!=.T. .and. _cCodVen!=''
	nLin := 1
	
	@nLin,00 PSAY CHR(15)+"|"+Replic("-",103)+"|"
	nLin := nLin + 1
	
	@ nlin,00 PSAY Cabec1
	nLin := nLin + 1
	
	@nLin,00 PSAY Cabec2
	nLin := nLin + 1
	
	@nLin,00 PSAY Cabec3
	nLin := nLin + 1
	
	
	@nLin,00 PSAY Cabec4
	nLin := nLin + 1
	
	@nLin,00 PSAY Cabec5
	nLin := nLin + 1
	
	@nLin,00 PSAY Cabec6
//	nLin := nLin + 1
	
	@nLin,00 PSAY Cabec7
	//nLin := nLin + 1
	_bCabec:=.T.
Endif

Return

Static Function VerificaUser()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cUserName  := Subs(cUsuario,7,15)   // Nome do Usuario

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
			
		Endif
		
	Endif
	
Endif

If _cSupVends!='' .or. _cCodVen!=''
	_bFlagVend:=.F.
Endif

Return
