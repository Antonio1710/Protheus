#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AD0167    º Autor ³Daniel Pitthan Silveira   º Data 23/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza ZV1010 com o Peso de ajuste                          º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Logística Aves Vivas											 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function AD0167        

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Atualiza ZV1010 com o Peso de ajuste')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guarda ambiente inicial                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetPrvt("_CALIAS,_NINDEX,_NRECNO")

_cAlias := Alias()
_nIndex := IndexOrd()
_nRecno := Recno()

//ÚÄÄÄÄÄÄÄÄÄ¿
//³VARIAVEIS³
//ÀÄÄÄÄÄÄÄÄÄÙ

Private nLin:=5 //Linha
Private _cZV1Plc //Placa do veiculo
Private _cZV1OC  //Ordem de Carregamento
Private _dZV1DtB //Data de Abate
Private _dZV1DtR //Data de Abate Realizada
Private _cZV1Gui //Guia de carregamento
Private _cZV1Nf  //Nota Fiscal
Private _cZV1NSr //Serie da NF
Private _nZVLcr1:=SPACE(10) //Lacre A
Private _nZVLcr2:=SPACE(10) //Lacre B
Private _nZV21Pe:=0 //Primeiro Peso
Private _nZV22Pe:=0 //Primeiro Peso
Private _nPesLiq:=0//Peso liquido
Private _nAjute :=0 //Ajuste
Private _cTabPrd :=SPACE(1)  //Peso de Terceiro
Private _cForRec //Fornecedor em que estou
Private _cContFor //fornecedor da adoro
Private _cZV1OC  :=ZV1->ZV1_NUMOC  //Ordem
Private _cStatus :=  ZV1_STATUS   // STATUS DO FRANGO VIVO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico se já tem frete gerado
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If  _cStatus = 'G'
	Alert ("ABORTANDO O PROCESSO, JA FOI GERADO FRETE O.C. " +_cZV1OC)
	dbSelectArea(_cAlias)
	dbSetOrder(_nIndex)
	dbGoto(_nRecno)
	Return
Endif


//FORNECEDOR DA ADORO
_cContFor:= Getmv("MV_FORITAD")
_cContFor:=substr(_cContFor,1,7)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico se não estou em uma granja da adoro para inclusão do peso de terceiro.³
//³Caso esteja não gravo peso terceiro e emito um alerta                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
//³OBTENDO DE ZV1 OS CAMPOS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|

_cZV1Gui:=ZV1->ZV1_GUIAPE  //Guia
IF (_cZV1Gui<>'')
	
	_cZV1Plc:=ZV1->ZV1_RPLACA //Placa
	_cZV1OC :=ZV1->ZV1_NUMOC  //Ordem
	_dZV1DtB:=ZV1->ZV1_DTABAT //Data Abate
	_dZV1DtR:=ZV1->ZV1_DTAREA //Data Abate Real
	_cZV1Nf :=ZV1->ZV1_NUMNFS //NF
	_cZV1NSr:=ZV1->ZV1_SERIE  //Serie
	_nZVLcr1:=ZV1->ZV1_LACRE1 //Lacre A
	_nZVLcr2:=ZV1->ZV1_LACRE2 //LAcre B
	_nAjute :=ZV1->ZV1_AJUSPS //Peso de Ajuste
	_nPesoter:=ZV1->ZV1_PESONF //PESO DE TERCEIRO
	_cForRec :=ZV1->ZV1_FORREC //FORNECEDOR
	_cTabPrd :=ZV1->ZV1_KMODM  // CONSIDERA ODOMETRO
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³OBETENDO OS CAMPOS EM ZV2010                 ³
	//³VERIFICO  SE A GUIA E PLACA EXISTE EM ZV2010,³
	//³CASO NAO ABOSTO O PROCESSO                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	DBSELECTAREA("ZV2")
	DBSETORDER (1)
	IF DBSEEK(xFilial("ZV2")+_cZV1Gui,.T.)
		_nZV21Pe  :=ZV2_1PESO  //Peso 1
		_nZV22Pe  :=ZV2_2PESO  //Peso 2
		_KmSai	  :=ZV2->ZV2_KMSAI
		_nKmEnt	  :=ZV2->ZV2_KMENT
		
		IF (_nZV22Pe<=0)    //verifico se exite a segunda pesagem
			alert ('NAO GERADO SEGUNDA PESAGEM, ABORTANDO....')     //se nao existe abosto o processo
			DBSELECTAREA (_cAlias)
			DBSETORDER (_nIndex)
			DBGOTO (_nRecno)
			RETURN
		ELSE
			_nPesLiq:=_nZV21Pe-_nZV22Pe //Calculo do Peso Liquido
		ENDIF
	ELSE
		ALERT ('NAO GERADO GUIA E PLACA NA PESAGEM, ABORTANDO....')
		DBSELECTAREA (_cAlias)
		DBSETORDER (_nIndex)
		DBGOTO (_nRecno)
		RETURN
	ENDIF
ELSE
	ALERT ('PRIMEIRA PESAGEM NÃO REALIZADA, ABORTANDO.....')
	DBSELECTAREA (_cAlias)
	DBSETORDER (_nIndex)
	DBGOTO (_nRecno)
	RETURN
ENDIF

@ 0,0 to 300,600 dialog dlg1 title "Ajuste de Peso"
@ nLin,005 SAY "DATA DE ABATE:"
@ nLin,050 SAY DTOC(_dZV1DtB)
@ nLin,100 SAY "DATA DE ABATE REAL:"
@ nLin,170 SAY DTOC(_dZV1DtR)
nLin:=nlin+15
@ nLin,005 SAY "GUIA:"
@ nLin,050 SAY _cZV1Gui
@ nLin,100 SAY "ORDEM:"
@ nLin,150 SAY _cZV1OC
nLin:=nlin+15
@ nLin,005 SAY "NF:"
@ nLin,050 SAY _cZV1Nf
@ nLin,100 SAY "SERIE:"
@ nLin,150 SAY _cZV1NSr
@ nLin,200 SAY "PLACA:"
@ nLin,250 SAY _cZV1Plc
nLin:=nlin+15
@ nLin,005 SAY "LACRE [A]:"
@ nLin,050 GET _nZVLcr1//PICTURE '9999999999'
@ nLin,100 SAY "LACRE [B]:"
@ nLin,150 GET _nZVLcr2// PICTURE '9999999999'
nLin:=nLin+15
@ nLin,005 SAY "1o PESO:"
@ nLin,050 SAY _nZV21Pe
@ nLin,100 SAY "2o PESO:"
@ nLin,150 SAY _nZV22Pe
@ nLin,200 SAY "PESO LIQ.:"
@ nLin,250 SAY _nPesLiq
nLin:=nLin+15
@ nLin,005 SAY "PESO AJUSTADO:"
@ nLin,050 GET _nAjute PICTURE "@E 99999"
//VERIFICO SE A GRANJA NAO E TERCEIRA
//CASO SEJA GRAVO TERCEIRA PESAGEM
@ nLin,100 SAY "CONSIDERA ODOMETRO:"
@ nLIn,170 GET _cTabPrd PICTURE '@!' VALID(Val_Odm(_cTabPrd))
nLin := nLin + 15
@ nLin,005 SAY "KM SAIDA: "
@ nLin,050 GET  _KmSai  Picture "99999999" Valid (VKmSai(_kmSai))
@ nLin,100 SAY "KM ENTRADA: "
@ nLin,150 GET  _nKmEnt Picture "99999999" Valid (VKmEnt(_nKmEnt))
nLin := nLin + 15
@ nLin,180 BUTTON "_Ok" 	 SIZE 35,15 ACTION Grava() //Grava()
@ nLin,250 BUTTON "_Ferchar" SIZE 35,15 ACTION fechar()
Activate dialog dlg1 centered

Return


//STATIC FUNCTION VRfrsh() //CALCULA PESO DE AJUSTE E FAZ Refresh
//_nAjute:=_nPesLiq-_nZV1PeA
//If _nAjute > 0
//	Alert('AJUSTE '+ STR())
//Endif
//RETURN(.T.)



Static Function Grava() //GRAVA VARIAVEIS

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³RETORNADO AMBIENTE                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DBSELECTAREA("ZV2") //GRAVANDO LACRES EM ZV2
DBSETORDER (1)
IF DBSEEK(xFilial("ZV2")+_cZV1Gui,.T.)
	Reclock("ZV2",.F.)
	Replace ZV2_KMSAI  with	_KmSai
	Replace ZV2_KMENT  with	_nKmEnt
	MSUNLOCK()
	DBCOMMIT()
ENDIF


DBSELECTAREA (_cAlias)
DBSETORDER (_nIndex)
DBGOTO (_nRecno)

Reclock("ZV1",.F.)
Replace ZV1_LACRE1 with _nZVLcr1
Replace ZV1_LACRE2 with _nZVLcr2
Replace ZV1_AJUSPS with _nAjute
Replace ZV1_KMODM  with _cTabPrd
MSUNLOCK()
DBCOMMIT()
Close(dlg1)
Return

Static Function VKmSai (_kmSai)                      //VALIDA KM DE SAIDA
//verificando o tipo da variavel e tornando ela numerica
If (_kmSai > 0)
	_cSts:=.T.
Else
	Alert("KM DE SAÍDA DEVE SER MAIOR QUE ZERO")
	_cSts:=.F.
EndIf
Return (_cSts)



Static Function VKmEnt (_nKmEnt)                     //VALIDA KM DE ENTRADA
If (_nKmEnt > _KmSai)
	_cSts:=.T.
Else
	Alert("KM DE ENTRADA DEVE SER MAIOR QUE DE SAÍDA")
	_cSts:=.F.
EndIf
Return (_cSts)




Static Function Val_Odm(_SimNao)                //VALIDA CLIMA NA BALANCA
If (_SimNao="S" .or. _SimNao="N")
	_SimNao := .T.
Else
	_SimNao := .F.
EndIf
Return (_SimNao)

Static Function Fechar() //FECHA DIALOGO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³RETORNADO AMBIENTE                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DBSELECTAREA (_cAlias)
DBSETORDER (_nIndex)
DBGOTO (_nRecno)
Close(dlg1)
Return
