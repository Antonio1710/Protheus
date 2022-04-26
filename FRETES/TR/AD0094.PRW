 #include "rwmake.ch"
#include "topconn.ch"                               

User Function AD0094()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±± ³Programa  ³ AD0094   ³ Autor ³ Gustavo Gonela        ³ Data ³ 24/11/03 ³±±
±± ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±± ³          ³Uso Logistica                                               ³±±
±± ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

_sAlias := Alias()
_nOrder := IndexOrd()
_sRec   := Recno()
_cDOC	:=	""
_cFile	:=	""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aHeader := {}
Private aCols   := {}
Private cTitulo := "Lancamentos de Descontos e Acrescimos"
Private aC		:={}
Private aR		:={}
Private _aDoc	:={}		// array com numeros de documentos do registro


// Variaveis que compoe o Cabecalho do Modelo 2
Private _cPLACAPG := SZK->ZK_PLACAPG 
Private _dDTENTR  := SZK->ZK_DTENTR  
Private _cROTEIRO := SZK->ZK_ROTEIRO 
Private _cTPFRETE := SZK->ZK_TPFRETE 
Private _cGuia    := SZK->ZK_GUIA 

//If Empty(_cGuia)
//	MSGBOX(" ROTEIRO SEM GUIA DE PESAGEM, LANÇAR EM OUTRO ROTEIRO ")     
//	Return
//Endif

_cDoc   := space(6)
_cPlaca	:= space(4)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta GetDados ( aHeader, aC, aR e aCols )                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsAguarde( { || u_Monta() }, "Aguarde", "Selecionando Veiculo....", .F. )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ha' dados para serem exibidos e alterados        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If Empty( aCols)
//	MsgStop( "Nao existem dados para estes parametros  " )
//	dbSelectArea(_sAlias)
//	dbSetOrder( _nOrder )
//	dbGoto(_sRec)
//	Return
//Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcao de acesso para o Modelo 2                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// 1) 3,4 - Permitem alterar getdados e incluir linhas
// 2) 6   - So permite alterar getdados e nao incluir linhas
// 3)     - Qualquer outro numero so visualiza
nOpcx  := 3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com coordenadas da GetDados no modelo2                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCGD    := {120,0,30,30} //{37,9,178,365}               // Tela do GetDados

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacoes na GetDados da Modelo 2                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLinhaOk := "AllWaysTrue()"
cTudoOk  := "AllWaysTrue()"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Modelo2                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// lRetMod2 = .T. se confirmou
// lRetMod2 = .F. se cancelou

// Alteracao RNUTTI
// lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk)
lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,,,,,{125,0,500,750},.T.,.T.)
//           Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLineOk,cAllOk,aGetsGD,bF4,cIniCpos,nMax,aCordW,lDelGetD)
//           aCordW  := {125,0,400,635}   // Tela de Fora (dos botoes) PADRAO MICROSIGA
//           aCordW  := {125,0,500,770}   // Tela de Fora (dos botoes) PADRAO AD'ORO
// Fim das Alteracoes

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava GetDados - Gravacao dos registros a partir de aCols    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsAguarde( { || u_Grava() }, "Aguarde", "Atualizando os Lancamentos...", .F. )

dbSelectArea(_sAlias)
dbSetOrder( _nOrder )
dbGoto(_sRec)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ u_Monta  ³ Autor ³ Rogerio Eduardo Nutti ³ Data ³ 13/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Montagem da Getdados (aHeader, aC, aR, aCols )             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function u_Monta()

_nItem := 0
_nProp := 0
_nUm   := 0
_nNorm := 0
_nEspe := 0                         


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando aHeader                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

MsProcTxt( "Montando Estrutura da Entrada de Dados" )

dbSelectArea("SX3")
dbSetOrder(1)
_aCampos := {{ "ZI_CODIGO "   , 02 },;
{ "ZI_TIPO "     , 01 },;
{ "ZI_DESCRIC "  , 30 },;
{ "ZI_OBS "      , 50 },;
{ "ZI_VALOR "    , 14 }}

nUsado  := 0
aHeader := {}
aC      := {}

For _I := 1 to Len(_aCampos)
	dbSeek("SZI")
	
	Do While X3_ARQUIVO == "SZI" .and. !Eof()
		If Alltrim(X3_CAMPO) == Alltrim(_aCampos[_I,1])
			nUsado += 1
			AADD(aHeader,{ TRIM(X3_TITULO), Alltrim(X3_CAMPO), X3_PICTURE,;
			_aCampos[_I,2], X3_DECIMAL,, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
		Endif
		dbSkip()
	Enddo
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando aCols                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


dbSelectArea("SZK")
Dbgoto(_sRec)

_nlinha  := 0
_dDtFech := SPACE(8)

AADD(aC,{"_cPLACAPG " ,{20,10}, "PLACA       : ",,,,.F.})
AADD(aC,{"_dDTENTR  " ,{20,115},"DT.ENTREGA  : ",,,,.F.})
AADD(aC,{"_cROTEIRO " ,{20,220},"ROTEIRO     : ",,,,.F.})
AADD(aC,{"_cTPFRETE " ,{20,300},"TP.FRETE    : ",,,,.F.})
 
dbSelectArea("SZI")
dbSetOrder(4) // PLACA + DATA + ROTEIRO
IF dbSeek(xFilial("SZI")+SZK->ZK_PLACAPG+DTOS(SZK->ZK_DTENTR)+SZK->ZK_ROTEIRO)
	_cPlaca := ZI_PLACA

    Do While !Eof() .and. SZI->ZI_FILIAL  ==  xFilial("SZI") .and.;
		SZI->ZI_PLACA  ==  SZK->ZK_PLACAPG .and.;
		DTOS(SZI->ZI_DATALAN) == DTOS(SZK->ZK_DTENTR) .and.;
		SZI->ZI_ROTEIRO = SZK->ZK_ROTEIRO
		
		If DTOS(SZI->ZI_DTFECH) = _dDtFech 
			
			MsProcTxt( "Selecionando Itens: " + SZI->ZI_PLACA)
			
			aAdd(aCols,{ SZI->ZI_CODIGO, SZI->ZI_TIPO, SZI->ZI_DESCRIC, SZI->ZI_OBS, SZI->ZI_VALOR, .F.} )
			
			aAdd(_aDoc,{ZI_DOC})
			
		Endif
		dbSkip()
	EndDo
Else
	aAdd(aCols,{ SZI->ZI_CODIGO, SZI->ZI_TIPO, SZI->ZI_DESCRIC, SZI->ZI_OBS, SZI->ZI_VALOR, .F.} )
ENDIF


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com descricao dos campos do Cabecalho do Modelo 2      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.


//AADD(aC,{"_cPLACAPG " ,{20,10} ,"PLACA      : ",,,,.F.})   // .T. pode ser alterado
//AADD(aC,{"_dDTENTR  " ,{20,115},"DT.ENTREGA : ",,,,.F.})   // .T. pode ser alterado
//AADD(aC,{"_cROTEIRO " ,{20,220},"ROTEIRO    : ",,,,.F.})   // .T. pode ser alterado
//AADD(aC,{"_cTPFRETE " ,{20,300},"TIPO FRETE : ",,,,.F.})   // .T. pode ser alterado


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com descricao dos campos do Rodape do Modelo 2         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// aR:={}
// aR[n,1] = Nome da Variavel Ex.:"cCliente"
// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aR[n,3] = Titulo do Campo
// aR[n,4] = Picture
// aR[n,5] = Validacao
// aR[n,6] = F3
// aR[n,7] = Se campo e' editavel .t. se nao .f.
// AADD(aR,{"cObs" ,{20,03},"Observa‡„o"    ,"@!",,,})

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ u_Grava  ³ Autor ³Jose Carlos S.Veloso Jr³ Data ³ 20/05/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao da Getdados                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

// Substituido pelo assistente de conversao do AP5 IDE em 13/08/02 ==> Function u_Grava
Static Function u_Grava()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pegando posicao dos campos na matriz aCols                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

_nPosCOD    := aScan(aHeader,{|x| x[2]== "ZI_CODIGO"  })
_nPosTP     := aScan(aHeader,{|x| x[2]== "ZI_TIPO"    })
_nPosDESC   := aScan(aHeader,{|x| x[2]== "ZI_DESCRIC" })
_nPosOBS    := aScan(aHeader,{|x| x[2]== "ZI_OBS"     })
_nPosVAL    := aScan(aHeader,{|x| x[2]== "ZI_VALOR"   })


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao dos itens a partir da matriz aCols                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetMod2
	
	dbSelectArea("SZI")
	dbSetOrder(7)  // PLACA + DATA LANCTO + No.DOC
	For _I := 1 To Len(aCols)
		// verifica se foi incluido uma linha nova no acols
		If	_I <= len(_aDoc)
			_cFile := _aDoc[_I,1]
		Else
			_cFile := GetSX8NUM("SZI","ZI_DOC")
		Endif
		// verifica se foi deletado uma linha no acols
		IF	aCols[_I,6]
			If dbSeek(xFilial("SZI")+SZK->ZK_PLACAPG+DTOS(SZK->ZK_DTENTR)+_cFile)
			//If dbSeek(xFilial("SZI")+SZK->ZK_PLACAPG+DTOS(aCols[_I,_nPosDTLAN])+_cFile)
				RecLock("SZI",.F.)
				dbdelete()
				MSUNLOCK()
			Endif
		Else
			// verifica se já existe o registro do acols se não inclui
			If dbSeek(xFilial("SZI")+SZK->ZK_PLACAPG+DTOS(SZK->ZK_DTENTR)+_cFile)
			//If dbSeek(xFilial("SZI")+SZK->ZK_PLACAPG+DTOS(aCols[_I,_nPosDTLAN])+_cFile)
				RecLock("SZI",.F.)// Atualiza registro
			Else
				RecLock("SZI",.T.) // Novo Registro
			Endif
			
			Replace ZI_FILIAL   With FwxFilial("SZI")
			Replace ZI_DOC      With _cFile
			Replace ZI_SEQ      With STRZERO(_I,2)
			Replace ZI_DATALAN  With SZK->ZK_DTENTR    //aCols[_I,_nPosDTLAN]
			Replace ZI_PLACA    With SZK->ZK_PLACAPG
			Replace ZI_FORNEC   With SZK->ZK_FORNEC
			Replace ZI_LOJA     With SZK->ZK_LOJA
			Replace ZI_NOMFOR   With SZK->ZK_NOMFOR
			Replace ZI_ROTEIRO  With SZK->ZK_ROTEIRO   //aCols[_I,_nPosROT]
			Replace ZI_GUIA     With SZK->ZK_GUIA 
			Replace ZI_DATAROT  With SZK->ZK_DTENTR    //aCols[_I,_nPosDTLAN]
			Replace ZI_CODIGO   With aCols[_I,_nPosCOD]
			Replace ZI_TIPO     With aCols[_I,_nPosTP]
			Replace ZI_DESCRIC  With aCols[_I,_nPosDESC]
			Replace ZI_OBS      With aCols[_I,_nPosOBS]
			Replace ZI_VALOR    With aCols[_I,_nPosVAL]
			MsUnLock()
			ConfirmSX8()
		Endif
	Next _I
	
Endif
Return
