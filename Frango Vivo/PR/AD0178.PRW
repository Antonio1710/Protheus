#include "rwmake.ch"

User Function AD0178()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AD0178   ³ Autor ³ Werner dos Santos     ³ Data ³ 21/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de Processamento por Periodo do Frete                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AD0178 , Sub-Funcao do Menus do Usuario                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Logistica                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Iniciando Variaveis                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private _dData   := dDatabase
Private _dData2  := dDatabase
Private _dDataF  := dDatabase
Public  _ProcPrd := 'S'

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina de Processamento por Periodo do Frete')

@ 00,000 TO 300,350 DIALOG oDlg1 TITLE "PROCESSAR FRETE FRANGO VIVO"
nLin := 30
@ nLin,030 SAY "Periodo de      : "
@ nLin,090 GET  _dData SIZE 40,70
nLin := nLin + 15
@ nLin,030 SAY "Periodo ate     : "
@ nLin,090 GET _dData2 SIZE 40,70
nLin := nLin + 15
@ nLin,030 SAY "Data Fechamento : "
@ nLin,090 GET _dDataF SIZE 40,70
nLin := nLin + 25

@ nLin,040 BMPBUTTON TYPE 01 ACTION GravaFech()
@ nLin,094 BMPBUTTON TYPE 02 ACTION Close(oDlg1)

ACTIVATE DIALOG oDlg1 CENTER


Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ GravaFech    ³ Gravacao da Informa‡oes                                 ³±±
±±³              ³                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Werner       | 21/02/06 ³ Funcao de Gravacao                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GravaFech()

bBloco := {|lEnd| Proc_Fret()}
MsAguarde(bBloco,"Aguarde, Gerando Valores do Frete ","Processando...",.T.)

//Processa( {|| Proc_Fret() } , " Gerando Valores do Frete ")

Return(.T.)
Close(Odlg1)

Static Function Proc_Fret()

_dDat_Abt  := DTOS(_dData)
_dDat_Abt2 := DTOS(_dData2)

dbSelectArea("ZV1") // Lancamentos de Descontos e Acrescimos
dbSetOrder(4) // data + placa
dbSeek(xFilial("ZV1")+_dDat_Abt ,.F.)

Do While !EOF() .and. DTOS(ZV1_DTABAT) >= (_dDat_Abt)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Guarda ambiente inicial                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cAliasZV1 := Alias()
	_nIndexZV1 := IndexOrd()
	_nRecnoZV1 := Recno()	
	If DTOS(ZV1_DTABAT) > (_dDat_Abt2)
		Exit                
	Endif
	if ALLTRIM(ZV1_STATUS)==''  &&Chamado 005157. Mauricio HC Consys 23/10/09. Ordem nao utilizada.
	   dbSelectArea("ZV1")
	   DbSkip()
	   Loop
	endif   
	if ZV1_CAVES == 0 .and. ZV1_RAVES == 0 &&Chamado 005157. Mauricio HC Consys 23/10/09. Sem preenchimento pelo PCP.
	   dbSelectArea("ZV1")
	   DbSkip()
	   Loop
	endif   
	Execblock("AD0153")
	//Replace ZI_DTFECH  With _dDataF
	//MsUnlock()
	MsprocTxt("Atualizando Frete da O.C.: " + ZV1_NUMOC)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura ambiente inicial                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("ZV1")
	dbSetOrder(_nIndexZV1)
	dbGoto(_nRecnoZV1)
	DbSkip()
Enddo

Return(.T.)

//*//****************************
//*//Verifica se o Tipo de Frete
//*dbSelectArea("SZK")
//*dbgotop()
//*//Indice 2
//*//ZK_FILIAL + ZK_GUIA  + ZK_DATA + ZK_PLACA
//*dbSetOrder(1)
//*Do While !EOF()
//*	//Despresa os Tipos de Frete que nao esta no parametro
//*	dbSelectArea("SZI")
//*	DbSetOrder(4)
//*	If dbSeek(xFilial("SZI")+SZK->ZK_PLACAPG+DTOS(SZK->ZK_DTENTR)+SZK->ZK_ROTEIRO)
//*		Do While !eof() .and. SZI->ZI_PLACA = SZK->ZK_PLACAPG  .and. SZI->ZI_DATALAN =  SZK->ZK_DTENTR //*.and. SZI->ZI_ROTEIRO  = SZK->ZK_ROTEIRO
//*			RecLock("SZI",.F.)// Atualiza registro
//*			Replace ZI_GUIA     With SZK->ZK_GUIA
//*			MsUnlock()
//*			DbSkip()
//*		Enddo
//*	ENDIF
//*	dbSelectArea("SZK")
//*	DbSkip()
//*Enddo
//*
//*MSGBOX("  ACABOU PODE CONTINUAR ")
//*
//*
//****************************

