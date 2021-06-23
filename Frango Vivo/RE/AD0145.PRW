//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de Includes                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#Include "Protheus.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AD0145    ³ Autor ³ HCCONSYS Celso Costa ³ Data ³25/09/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Guia de pesagem - Frango Vivo (cupom)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_AD0145()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function AD0145()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _aArea	:= GetArea()
Local nLin		:= 80
Local aOrd		:= {}
Local cDesc1	:= "Este programa tem como objetivo imprimir relatorio "
Local cDesc2	:= "de acordo com os parametros informados pelo usuario."
Local cDesc3	:= "GUIA DE PESAGEM"
Local Titulo	:= "GUIA DE PESAGEM"
Local Cabec1	:= "GUIA DE PESAGEM"
Local Cabec2	:= "GUIA DE PESAGEM"
Local NomeProg	:= "AD0145"  

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Guia de pesagem - Frango Vivo (cupom)')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Private                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nLastKey	:= 00
Private nTipo		:= 18
Private cString	:= ""
Private WnRel		:= "AD0145"
Private aReturn	:= { "Zebrado", 01, "Administracao", 01, 02, 01, "", 01 }
Private _cMotor	:= ""
Private _nPeso1	:= 00
Private _nPeso2	:= 00
Private _cOBS1		:= ""
Private _cOBS2		:= ""
Private _cForNome	:= ""
Private _cResume	:= ""
Private _cNumPeso	:= ""
Private _dData1	:= CtoD( "" )
Private _cHora1	:= ""
Private _dData2	:= CtoD( "" )
Private _cHora2	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona tabelas                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "ZV1" )
dbSetOrder ( 03 )

If !dbSeek( xFilial( "ZV1" ) + ZV1->ZV1_NUMOC )
	Alert( "NAO ENCONTRADO A ORDEM, ABORTANDO" )
	Return ( Nil )
EndIf            

dbSelectArea( "ZV2" )
dbSetOrder( 01 )

If dbSeek( xFilial( "ZV2" ) + ZV1->ZV1_GUIAPE )
	_cMotor	:= ZV2->ZV2_MOTORI
	_nPeso1	:= ZV2->ZV2_1PESO
	_nPeso2	:= ZV2->ZV2_2PESO
	_cOBS1	:= ZV2->ZV2_OBS1
	_cOBS2	:= ZV2->ZV2_OBS2
	_dData1	:= ZV2->ZV2_DATA1
	_cHora1	:= ZV2->ZV2_HORA1
	_dData2	:= ZV2->ZV2_DATA2
	_cHora2	:= ZV2->ZV2_HORA2
EndIf

dbSelectArea( "SA2" )
dbSetOrder( 01 )

If dbSeek( xFilial( "SA2" ) + ZV1->ZV1_CODFOR + ZV1->ZV1_LOJFOR )
	_cForNome	:= SA2->A2_NOME
	_cResume		:= SA2->A2_NREDUZ
EndIf

_cNumPeso := Iif( _nPeso2 > 00, "2", "1" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Emissao                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WnRel := SetPrint( cString, NomeProg, "", @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., "P",, .T. )

If nLastKey == 27
	Return ( Nil )
EndIf

SetDefault( aReturn, cString )

If nLastKey == 27
	Return ( Nil )
EndIf

nTipo := Iif( aReturn[ 04 ] == 01, 15, 18 )

RptStatus( {|| RunReport( Cabec1, Cabec2, Titulo, nLin ) }, Titulo )

RestArea( _aArea )

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RunReport ³ Autor ³ HCCONSYS Celso Costa ³ Data ³25/09/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao auxiliar chamada pela RPTSTATUS                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RunReport()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunReport( Cabec1, Cabec2, Titulo, nLin )

@ 00, 00 PSay Chr( 27 ) + chr( 67 ) + chr( 13 )
@ 00, 00 PSay "==============================================="
@ 01, 00 PSay "       GUIA DE RECEBIMENTO FRANGO VIVO:"
@ 02, 20 PSay ZV1->ZV1_GUIAPE
@ 03, 00 PSay "==============================================="
@ 04, 00 PSay "EMISSAO...:" + Iif( Val( _cNumPeso ) <= 01, DtoC( _dData1 ), DtoC( _dData2 ) )
@ 04, 36 PSay "PESAGEM N. "  + _cNumPeso
@ 05, 00 PSay "-----------------------------------------------"
@ 07, 00 PSay "N. FISCAL...: " + ZV1->ZV1_NUMNFS
@ 07, 22 PSay "ORDEM CARREG...: " + ZV1->ZV1_NUMOC	
@ 09, 00 PSay "COD. PRODUTOR...: " + ZV1->ZV1_PGRANJ
@ 10, 00 PSay "NOME: " + _cForNome
@ 11, 00 PSay "COD. INTEGRADO...:  " + ZV1->ZV1_RGRANJ
@ 12, 00 PSay "NOME: " + _cForNome
@ 13, 00 PSay "VEICULO...: " + ZV1->ZV1_PPLACA
@ 14, 00 PSay "MOTORISTA...: " + _cMotor
@ 16, 00 PSay "-----------------------------------------------"
@ 18, 00 PSay "MATERIAL...: FRANGO VIVO"
	
If _nPeso1 > 00
	@ 19, 00 PSay "1 PESAGEM" + Str( _nPeso1, 08 )
	@ 19, 18 PSay "HORA: " + _cHora1 //Time()
	@ 19, 33 PSay "SECO/MOLHADO: " + ZV1->ZV1_CLIBAL
EndIf
	
If _nPeso2 > 00
	@ 20, 00 PSay "2 PESAGEM" + Str( _nPeso2, 08 )
	@ 20, 18 PSay "HORA...: " + _cHora2 // Time()
	@ 20, 34 PSay "SECO/MOLHADO: " + ZV1->ZV1_CLIBAL
EndIf
	
If _nPeso1 > 00 .And. _nPeso2 > 00
	@ 22, 00 PSay "PESO LIQUIDO" + Str( ( _nPeso1 - _nPeso2 ), 08 )
	@ 22, 22 PSay "HORA...: " + Time()
EndIf
	   
If _cNumPeso == "1"
	@ 23, 00 PSay "==============================================="
	@ 24, 00 PSay "* * * * * * * *  P E N D U R A * * * * * * * * "
	@ 25, 00 PSay "SEQUENCIA DE CHEGADA/DESCARGA.: 1 / ___________"
	@ 26, 00 PSay "DATA   ____/____/____ "
	@ 27, 00 PSay "HORA INICIO ____:____"
	@ 28, 00 PSay "HORA TERM.  ____:____"
	@ 29, 00 PSay "QTD.: _______ MORTOS: _______"
	@ 30, 00 PSay "QTD. D.S.: _______ MORTOS D.S.:_______"
	@ 31, 00 PSay "-----------------------------------------------"
	@ 32, 00 PSay "* * * * * * * O B S E R V A C A O * * * * * * *"
	@ 33, 00 PSay Substr( _cObs1, 01, 46 )
	@ 34, 00 PSay SubStr( _cObs2, 01, 46 )    
	@ 35, 00 PSay "===============================================" 
	@ 36, 00 PSay Chr( 10 ) + Chr( 10 ) + Chr( 10 ) + Chr( 10 )                             
Else
	@ 23, 00 PSay "===============================================" 
	@ 24, 00 PSay Chr( 10 ) + Chr( 10 ) + Chr( 10 ) + Chr( 10 )
EndIf

Set Device to Screen

If aReturn[ 05 ] == 01
	Set Printer To
	Commit
	OurSpool( WnRel )
EndIf

MS_Flush()

Return ( Nil )