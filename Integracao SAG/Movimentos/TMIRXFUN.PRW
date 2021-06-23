#INCLUDE "Protheus.ch"
#INCLUDE "ParmType.ch"

//Estrutura de arquivo
#DEFINE POS_CMP		1
#DEFINE POS_TIP		2
#DEFINE POS_TAM		3
#DEFINE POS_DEC		4

#DEFINE nTAMSX1H		35	//Tamanho da descricao help SX1

Static nEsqCont			:= 001
Static nAltCont			:= 009
Static nDistPad			:= 002
Static nAltBot			:= 013
Static nDistAPad		:= 004
Static nDistEtq			:= 001
Static nAltEtq			:= 007
Static nLargEtq			:= 035 
Static nLargBot			:= 040
Static cHK				:= "&"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TExTelaMen  ºAutor  ³Pablo Gollan Carreras º Data ³03/02/2012      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para montar uma tela para apresentacao de mensagem         º±±
±±º          ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp01[C] : Titulo da janela                                       º±±
±±º          ³Exp02[C] : Texto a ser apresentado                                º±±
±±º          ³Exp03[C] : Nome da fonte                                          º±±
±±º          ³Exp04[N] : Tamanho da fonte                                       º±±
±±º          ³Exp05[L] : Dar foco no botao fechar                               º±±
±±º          ³Exp06[L] : Dar foco no botao cancelar                             º±±
±±º          ³Exp07[L] : Exibir a combinacao de botoes : OK e Cancelar          º±±
±±º          ³Exp08[C] : Acao a ser executada pelo Timer da rotina (opcional)   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TExTelaMen(cTitulo,cTexto,cFonte,nTamFonte,lFocoFec,lFocoCanc,lOkCanc,cAcaoTimer)

Local lRet				:= .T.
Local aCoord			:= FWGetDialogSize(oMainWnd)
Local aTamObj			:= Array(4)
Local nCoefDif			:= 1
Local cLOGArq			:= ""
Local cTipoArq    		:= "Arquivos Texto (*.TXT) |*.txt|"
Local cAcao				:= "oMemo:SetFocus()"
Local cGET01	
Local cGET02
Local bAcao01			:= {|| }
Local bAcao02			:= {|| }
//Objetos graficos
Local oDlg
Local oEtq01
Local oFont
Local oTimerTE

Private oMemo
Private oBot01
Private oBot02

U_ADINF009P('TMIRXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para montar uma tela para apresentacao de mensagem')

PARAMTYPE 0 VAR cTitulo		AS Character	OPTIONAL	DEFAULT ""
PARAMTYPE 1 VAR cTexto		AS Character	OPTIONAL	DEFAULT ""
PARAMTYPE 2 VAR cFonte		AS Character	OPTIONAL	DEFAULT "Mono AS"
PARAMTYPE 3 VAR nTamFonte	AS Numeric		OPTIONAL	DEFAULT 0
PARAMTYPE 4	VAR lFocoFec	AS Logical		OPTIONAL	DEFAULT .F.
PARAMTYPE 5	VAR lFocoCanc	AS Logical		OPTIONAL	DEFAULT .F.
PARAMTYPE 6	VAR lOkCanc		AS Logical		OPTIONAL	DEFAULT .F.
PARAMTYPE 7	VAR cAcaoTimer	AS Character	OPTIONAL	DEFAULT ""

If lFocoFec .OR. lFocoCanc
	cAcao := "oBot02:SetFocus()"
Endif
oFont := tFont():New(cFonte,,IIf(!Empty(nTamFonte),Abs(nTamFonte),5) * -1,.T.)
If FindFunction("U_ApRedFWL") .AND. U_ApRedFWL(.F.)
	nCoefDif := 0.95
Endif
aCoord[3] := aCoord[3] * 0.6
aCoord[4] := aCoord[4] * 0.4
DEFINE MSDIALOG oTela TITLE cTitulo FROM aCoord[1],aCoord[2] To aCoord[3],aCoord[4] PIXEL 

aTamObj[1] := 005
aTamObj[2] := 005
aTamObj[3] := (oTela:nWidth / 2) - aTamObj[2] * 2
aTamObj[4] := ((oTela:nHeight * nCoefDif) / 2) - ((aTamObj[1] * 2) + nDistAPad + nAltBot + aTamObj[1])
oMemo := tMultiGet():New(aTamObj[1],aTamObj[2],{|x| IIf(PCount() > 0,cTexto := x,cTexto)},oTela,aTamObj[3],aTamObj[4],oFont,.T.,,,,.T.,,,{|| .T.},,,.T.,/*bValid*/,,,.F.,.F.)
oMemo:bRClicked := {|| AllwaysTrue()}
If !lOkCanc
	bAcao01	:= {|| cArqLOG := cGetFile(cTipoArq,""),IIf(Empty(cArqLOG),.T.,MemoWrite(cArqLOG,cTexto))} 
	bAcao02	:= {|| oTela:End()}
	cTAG01	:= "Gravar"
	cTAG02	:= "Fechar"
Else
	bAcao01	:= {|| lRet := .T.,oTela:End()}
	bAcao02	:= {|| lRet := .F.,oTela:End()}
	cTAG01	:= "Ok"
	cTAG02	:= "Cancelar"
Endif
aTamObj[1] := ((oMemo:nTop + oMemo:nHeight) / 2) + nDistAPad
aTamObj[2] := 005
aTamObj[3] := ((oTela:nWidth / 2) - ((aTamObj[2] * 2) + nDistAPad)) / 2
aTamObj[4] := nAltBot
oBot01 := tButton():New(aTamObj[1],aTamObj[2],cHK + cTAG01,oTela,bAcao01,aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
aTamObj[2] := ((oBot01:nLeft + oBot01:nWidth) / 2) + nDistAPad
oBot02 := tButton():New(aTamObj[1],aTamObj[2],cHK + cTAG02,oTela,bAcao02,aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
If !Empty(cAcaoTimer)
	oTimerTE := tTimer():New(3000,&("{|| " + cAcaoTimer + "}"),oTela)
	oTimerTE:Activate() 
Endif

oTela:Activate(,,,.T.,/*valid*/,,&("{|| " + cAcao + "}"))

Return lRet