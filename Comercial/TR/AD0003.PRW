#include "rwmake.ch"  

User Function AD0003 

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Menu inicial do sistema de comissao de vendedores')

SetPrvt("CCADASTRO,AROTINA,")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ AD0003.PRW   ³ Menu inicial do sistema de comissao de vendedores       ³±±
±±³              ³                                                         ³±±
±±³              ³ Especifico Ad'oro Alimenticia                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

dbSelectArea("SZA")
dbSetOrder(1)
dbGoTop()

CCadastro := "Tabela de Comissoes "
aRotina := {  { "Pesquisar"    	,"AxPesqui"           	, 0 , 1},;
              { "Visualizar"		,"axVisual"           	, 0 , 2},;
              { "Incluir"     	,"EXECBLOCK('AD0002')"	, 0 , 3},;
              { "Alterar"     	,"EXECBLOCK('AD0004')"	, 0 , 4},;
              { "Excluir" 			,"EXECBLOCK('AD0006')"	, 0 , 5}  }
mBrowse( 6, 1,22,75,"SZA")
dbSelectArea("SZA")
dbSetOrder(1)

Return

//ESTA FUNCAO FAZ INCLUSAO NA TABELA SZA DE FAIXAS DE COMISSAO DE VENDAS
USER FUNCTION AD0002 ()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  AD0002  ³ Autor ³  HERALDO C. HEBLING   ³ Data ³ 12/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclusao da tabela de comissoes de vendedores               ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Adoro Alimenticia                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Arquivos ³ SZA                                                        ³±±
±±³ em Uso   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Manutencao :                                                          ³±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcao de acesso para o Modelo 2                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// 3,4 Permitem alterar getdados e incluir linhas
// 6 So permite alterar getdados e nao incluir linhas
// Qualquer outro numero so visualiza
nOpcx:=3
Public _nPerce  := 0
Public _cFaixa  := "A"
Public _nPerc
Private _valor
Private _nPercen

U_ADINF009P('AD0003' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Menu inicial do sistema de comissao de vendedores')
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando aHeader                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SZA")
nUsado:=0
aHeader:={}
While !Eof() .And. (x3_arquivo == "SZA")
	IF ALLTRIM(X3_CAMPO)!= "ZA_FILIAL" .AND. ALLTRIM(X3_CAMPO)!= "ZA_CODTAB" .AND. ALLTRIM(X3_CAMPO)!= "ZA_DTTAB";
										.AND. ALLTRIM(X3_CAMPO)!= "ZA_TABELA"
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			nUsado	:=	nUsado	+	1
			AADD(aHeader,{ TRIM(x3_titulo), alltrim(x3_campo), x3_picture,;
           	x3_tamanho, x3_decimal,"ExecBlock('AD2VALID',.f.,.f.)",;
			x3_usado, x3_tipo, x3_arquivo, x3_context } )
		Endif
	Endif
	dbSkip()
End

_nPosFAIXA   	:= aScan(aHeader,{|x| x[2]=="ZA_FAIXA"})
_nPosDE	    	:= aScan(aHeader,{|x| x[2]=="ZA_PERCDE"})
_nPosATE	    := aScan(aHeader,{|x| x[2]=="ZA_PERCATE"})
_nPosVL      	:= aScan(aHeader,{|x| x[2]=="ZA_VLFAIXA"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando aCols                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols:=Array(1,nUsado+1)
dbSelectArea("Sx3")
dbSeek("SZA")
nUsado:=0
While !Eof() .And. (x3_arquivo == "SZA")
	IF ALLTRIM(X3_CAMPO)!= "ZA_FILIAL" .AND. ALLTRIM(X3_CAMPO)!= "ZA_CODTAB" .AND. ALLTRIM(X3_CAMPO)!= "ZA_DTTAB";
     									.AND. ALLTRIM(X3_CAMPO)!= "ZA_TABELA"
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			nUsado:=nUsado+1
			IF nOpcx == 3
				IF x3_tipo == "C"
					aCOLS[1][nUsado] := SPACE(x3_tamanho)
				Elseif x3_tipo == "N"
					aCOLS[1][nUsado] := 0
				Elseif x3_tipo == "D"
					aCOLS[1][nUsado] := dDataBase
				Elseif x3_tipo == "M"
					aCOLS[1][nUsado] := ""
				Else
					aCOLS[1][nUsado] := .F.
				Endif
			ENDIF			
		Endif
	endif
	dbSkip()
End
aCOLS[1][nUsado+1] := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis do Rodape do Modelo 2                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLinGetD:=0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Titulo da Janela                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo:="TABELA DE PRECOS"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis do Cabecalho do Modelo 2                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cCodigo	:=	Space(4)
_cTabela	:=	Space(1)
_dData		:= 	DDATABASE
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com descricao dos campos do Cabecalho do Modelo 2      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aC:={}
AADD(aC,{"_cCodigo"	,{15,10} ,"Tabela de Comissao"	,"@!"			,,,})
AADD(aC,{"_cTabela"	,{15,100},"Faixa de Comissao"	,"@!"			,"U_AD2Vl1(_cCodigo,_cTabela)",,})
AADD(aC,{"_dData"	,{15,200},"Data da Tabela"			,"@D"			,,,})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com descricao dos campos do Rodape do Modelo 2         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aR:={}
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com coordenadas da GetDados no modelo2                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCGD:={44,5,118,315}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacoes na GetDados da Modelo 2                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLinhaOk:="U_AD2LinOk()
cTudoOk:="U_AD2TudoOk()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Modelo2                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava tabela                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetMod2
	_nCtlin := 0
	For _I := 1 To Len(aCols)
		IF	!aCols[_I,5]
			_nCtlin++
			RecLock("SZA",.T.)
			SZA->ZA_FILIAL		:=	xFilial("SZA")
			SZA->ZA_CODTAB		:=  _cCodigo
			SZA->ZA_TABELA		:=  _cTabela
			SZA->ZA_DTTAB		:=	_dData
			SZA->ZA_FAIXA		:=	U_FLETRA(_nCtlin)
			SZA->ZA_PERCDE		:=	aCols[_I,_nPosDE]
			SZA->ZA_PERCATE		:=	aCols[_I,_nPosATE]
			SZA->ZA_VLFAIXA		:=	aCols[_I,_nPosVL]
			MSUNLOCK()
		Endif
    NEXT _I
Endif

Return
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao para montar as letras da faixa                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

USER FUNCTION FLETRA(_nI)

	U_ADINF009P('AD0003' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Menu inicial do sistema de comissao de vendedores')
    If 		_nI == 1
    		_cFaixa := 'A'
    ElseIf 	_nI == 2
    		_cFaixa := 'B'
    ElseIf 	_nI == 3
    		_cFaixa := 'C'
    ElseIf 	_nI == 4
    		_cFaixa := 'D'
    ElseIf 	_nI == 5
    		_cFaixa := 'E'
    ElseIf 	_nI == 6
    		_cFaixa := 'F'
    ElseIf 	_nI == 7
    		_cFaixa := 'G'
    ElseIf 	_nI == 8
    		_cFaixa := 'H'
    ElseIf 	_nI == 9
    		_cFaixa := 'I'
    ElseIf 	_cnI == 10
    		_cFaixa := 'J'
    ElseIf 	_cnI == 11
    		_cFaixa := 'K'
    ElseIf 	_cnI == 12
    		_cFaixa := 'L'
    ElseIf 	_cnI == 13
    		_cFaixa := 'M'
    ElseIf 	_cnI == 14
    		_cFaixa := 'N'
    ElseIf 	_cnI == 15
    		_cFaixa := 'O'
    ElseIf 	_cnI == 16
       		_cFaixa := 'P'
    ElseIf 	_cnI == 17
    		_cFaixa := 'Q'
    ElseIf 	_cnI == 18
    		_cFaixa := 'R'
    ElseIf 	_cnI == 19
    		_cFaixa := 'S'
    ElseIf 	_cnI == 20
    		_cFaixa := 'T'
    ElseIf 	_cnI == 21
    		_cFaixa := 'U'
    ElseIf 	_cnI == 22
    		_cFaixa := 'V'
    ElseIf 	_cnI == 23
    		_cFaixa := 'W'
    ElseIf 	_cnI == 24
    		_cFaixa := 'X'
    ElseIf 	_cnI == 25
    		_cFaixa := 'Y'
    ElseIf 	_cnI == 26
    		_cFaixa := 'Z'
    Endif
Return(_cFaixa)





//ESTA FUNCAO ALTERA A TABELA SZA DE FAIXAS DE COMISSAO DE VENDAS
USER  FUNCTION AD0004
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  AD0004  ³ Autor ³  HERALDO C. HEBLING   ³ Data ³ 12/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao da tabela de comissoes de vendedores             ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Adoro Alimenticia                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Arquivos ³ SZA                                                        ³±±
±±³ em Uso   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Manutencao :                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcao de acesso para o Modelo 2                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// 3,4 Permitem alterar getdados e incluir linhas
// 6 So permite alterar getdados e nao incluir linhas
// Qualquer outro numero so visualiza
nOpcx:=3
Public _nPerce  := 0
Public _nPerc
Public _cFaixa  := "A"
Private aCols    := {}
Private _valor
Private _nPercen
_cAlias	:=alias()
_corder:=indexord()
_nrecno:=	recno()	
// Montando aHeader                                           
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SZA")
nUsado:=0
aHeader:={}
While !Eof() .And. (x3_arquivo == "SZA")
	IF ALLTRIM(X3_CAMPO)!= "ZA_FILIAL" .AND. ALLTRIM(X3_CAMPO)!= "ZA_CODTAB" .AND. ALLTRIM(X3_CAMPO)!= "ZA_DTTAB";
										.AND. ALLTRIM(X3_CAMPO)!= "ZA_TABELA"
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			nUsado	:=	nUsado	+	1
			AADD(aHeader,{ TRIM(x3_titulo), alltrim(x3_campo), x3_picture,;
           	x3_tamanho, x3_decimal,"ExecBlock('AD2VALID',.f.,.f.)",;
			x3_usado, x3_tipo, x3_arquivo, x3_context } )
		Endif
	Endif
	dbSkip()
End

_nPosFAIXA   	:= aScan(aHeader,{|x| x[2]=="ZA_FAIXA"})
_nPosDE	    	:= aScan(aHeader,{|x| x[2]=="ZA_PERCDE"})
_nPosATE	    := aScan(aHeader,{|x| x[2]=="ZA_PERCATE"})
_nPosVL      	:= aScan(aHeader,{|x| x[2]=="ZA_VLFAIXA"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando aCols                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis do Rodape do Modelo 2                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLinGetD:=0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Titulo da Janela                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo:="TABELA DE PRECOS"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis do Cabecalho do Modelo 2                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SZA")
dbSetOrder(1)
dbgoto(_nrecno)
_cCodigo	:=	SZA->ZA_CODTAB
_cTabela	:=	SZA->ZA_TABELA
_dData		:= 	SZA->ZA_DTTAB
dbseek(xFilial("SZA")+_cCodigo+_cTabela)
Do while	!eof()	.and.	(SZA->ZA_CODTAB==_cCodigo .and. _cTabela	==	SZA->ZA_TABELA)

   aAdd(aCols,{SZA->ZA_FAIXA,SZA->ZA_PERCDE,SZA->ZA_PERCATE,SZA->ZA_VLFAIXA, .F.} )

   dbSkip()

EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com descricao dos campos do Cabecalho do Modelo 2      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aC:={}
AADD(aC,{"_cCodigo"	,{15,10} ,"Tabela de Comissao"	,"@!"			,,,.f.})
AADD(aC,{"_cTabela"	,{15,100},"Faixa de Comissao"	,"@!"			,"U_AD2Vl2(_cCodigo+_cTabela)",,.f.})
AADD(aC,{"_dData"	,{15,200},"Data da Tabela"			,"@D"		,,,.f.})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com descricao dos campos do Rodape do Modelo 2         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aR:={}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com coordenadas da GetDados no modelo2                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCGD:={44,5,118,315}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacoes na GetDados da Modelo 2                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLinhaOk:="U_AD2LinOk()"
cTudoOk:= "U_AD2TudoOk()"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Modelo2                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk)

If lRetMod2
	If  dbSeek( xFilial("SZA") + _cCodigo+_cTabela+"A"  )
		Do while (SZA->ZA_CODTAB == _cCodigo .and. SZA->ZA_TABELA == _cTabela)
			RecLock("SZA",.F.)
			dbdelete()
			MSUNLOCK()
			dbskip()
		enddo
	Endif
	_nCtlin := 0
	For _I := 1 To Len(aCols)
		IF	!aCols[_I,5]
			_nCtlin++
			RecLock("SZA",.T.)
			SZA->ZA_FILIAL		:=	xFilial("SZA")
			SZA->ZA_CODTAB		:=  _cCodigo
			SZA->ZA_TABELA		:=	_cTabela
			SZA->ZA_DTTAB		:=	_dData
			SZA->ZA_FAIXA		:=	U_FLETRA(_nCtlin)
			SZA->ZA_PERCDE		:=	aCols[_I,_nPosDE]
			SZA->ZA_PERCATE		:=	aCols[_I,_nPosATE]
			SZA->ZA_VLFAIXA		:=	aCols[_I,_nPosVL]
			MSUNLOCK()
		Endif
    NEXT _I
Endif
RETURN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao para montar as letras da faixa                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*STATIC FUNCTION FLETRA(_nI)
    If 		_nI == 1
    		_cFaixa := 'A'
    ElseIf 	_nI == 2
    		_cFaixa := 'B'
    ElseIf 	_nI == 3
    		_cFaixa := 'C'
    ElseIf 	_nI == 4
    		_cFaixa := 'D'
    ElseIf 	_nI == 5
    		_cFaixa := 'E'
    ElseIf 	_nI == 6
    		_cFaixa := 'F'
    ElseIf 	_nI == 7
    		_cFaixa := 'G'
    ElseIf 	_nI == 8
    		_cFaixa := 'H'
    ElseIf 	_nI == 9
    		_cFaixa := 'I'
    ElseIf 	_cnI == 10
    		_cFaixa := 'J'
    ElseIf 	_cnI == 11
    		_cFaixa := 'K'
    ElseIf 	_cnI == 12
    		_cFaixa := 'L'
    ElseIf 	_cnI == 13
    		_cFaixa := 'M'
    ElseIf 	_cnI == 14
    		_cFaixa := 'N'
    ElseIf 	_cnI == 15
    		_cFaixa := 'O'
    ElseIf 	_cnI == 16
       		_cFaixa := 'P'
    ElseIf 	_cnI == 17
    		_cFaixa := 'Q'
    ElseIf 	_cnI == 18
    		_cFaixa := 'R'
    ElseIf 	_cnI == 19
    		_cFaixa := 'S'
    ElseIf 	_cnI == 20
    		_cFaixa := 'T'
    ElseIf 	_cnI == 21
    		_cFaixa := 'U'
    ElseIf 	_cnI == 22
    		_cFaixa := 'V'
    ElseIf 	_cnI == 23
    		_cFaixa := 'W'
    ElseIf 	_cnI == 24
    		_cFaixa := 'X'
    ElseIf 	_cnI == 25
    		_cFaixa := 'Y'
    ElseIf 	_cnI == 26
    		_cFaixa := 'Z'
    Endif
Return(_cFaixa)
*/
                                                   
//EXCLUSAO
USER  FUNCTION AD0006
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  AD0006  ³ Autor ³  HERALDO C. HEBLING   ³ Data ³ 12/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclusao de tabela de comissoes de vendedores               ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Adoro Alimenticia                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Arquivos ³ SZA                                                        ³±±
±±³ em Uso   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Manutencao :                                                          ³±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcao de acesso para o Modelo 2                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// 3,4 Permitem alterar getdados e incluir linhas
// 6 So permite alterar getdados e nao incluir linhas
// Qualquer outro numero so visualiza
nOpcx:=3
Public _nPerce  := 0
Public _nPerc
Public _cFaixa  := "A"
Private aCols    := {}
Private _valor
Private _nPercen
_cAlias	:=alias()
_corder:=indexord()
_nrecno:=	recno()	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando aHeader                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SZA")
nUsado:=0
aHeader:={}
While !Eof() .And. (x3_arquivo == "SZA")
	IF ALLTRIM(X3_CAMPO)!= "ZA_FILIAL" .AND. ALLTRIM(X3_CAMPO)!= "ZA_CODTAB" .AND. ALLTRIM(X3_CAMPO)!= "ZA_DTTAB";
										.AND. ALLTRIM(X3_CAMPO)!= "ZA_TABELA"
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			nUsado	:=	nUsado	+	1
			AADD(aHeader,{ TRIM(x3_titulo), alltrim(x3_campo), x3_picture,;
           	x3_tamanho, x3_decimal,"ExecBlock('AD2VALID',.f.,.f.)",;
			x3_usado, x3_tipo, x3_arquivo, x3_context } )
		Endif
	Endif
	dbSkip()
End

_nPosFAIXA   	:= aScan(aHeader,{|x| x[2]=="ZA_FAIXA"})
_nPosDE	    	:= aScan(aHeader,{|x| x[2]=="ZA_PERCDE"})
_nPosATE	    	:= aScan(aHeader,{|x| x[2]=="ZA_PERCATE"})
_nPosVL      	:= aScan(aHeader,{|x| x[2]=="ZA_VLFAIXA"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando aCols                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis do Rodape do Modelo 2                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLinGetD:=0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Titulo da Janela                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo:="TABELA DE PRECOS"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis do Cabecalho do Modelo 2                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SZA")
dbSetOrder(1)
dbgoto(_nrecno)
_cCodigo	:=	SZA->ZA_CODTAB
_cTabela	:=	SZA->ZA_TABELA
_dData		:= 	SZA->ZA_DTTAB
dbseek(xFilial("SZA")+_cCodigo+_cTabela)
Do while	!eof()	.and.	(SZA->ZA_CODTAB==_cCodigo .and. _cTabela	==	SZA->ZA_TABELA)

   aAdd(aCols,{SZA->ZA_FAIXA,SZA->ZA_PERCDE,SZA->ZA_PERCATE,SZA->ZA_VLFAIXA, .F.} )

   dbSkip()

EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com descricao dos campos do Cabecalho do Modelo 2      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aC:={}
AADD(aC,{"_cCodigo"	,{15,10} ,"Tabela de Comissao"	,"@!"			,"U_AD2Vl2(_cCodigo)",,.f.})
AADD(aC,{"_cTabela"	,{15,100},"Faixa de Comissao"	,"@!"			,,,.f.})
AADD(aC,{"_dData"	,{15,200},"Data da Tabela"			,"@D"		,,,.f.})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com descricao dos campos do Rodape do Modelo 2         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aR:={}
//AADD(aR,{"_nPercen"	,{120,10},"Percentual"	,"@E 999.999",,,.F.})
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com coordenadas da GetDados no modelo2                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCGD:={44,5,118,315}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacoes na GetDados da Modelo 2                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLinhaOk:="U_AD2LinOk()"
cTudoOk:= "U_AD2TudoOk()"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Modelo2                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk)
//FAZ A DELECAO
If lRetMod2
	If  dbSeek( xFilial("SZA") + _cCodigo+_cTabela+"A"  )
		Do while (SZA->ZA_CODTAB == _cCodigo .and. SZA->ZA_TABELA == _cTabela)
			RecLock("SZA",.F.)
			dbdelete()
			MSUNLOCK()
			dbskip()
		enddo
	Endif
Endif
RETURN

//
USER FUNCTION AD2VALID

U_ADINF009P('AD0003' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Menu inicial do sistema de comissao de vendedores')
nLinGetD:=n
_nPos	:= aScan(aHeader,{|x| x[2]=="ZA_PERCATE"})

_nPerce	:=	aCols[n,_nPos]
RETURN(.T.)

//
USER FUNCTION AD2LINOK

U_ADINF009P('AD0003' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Menu inicial do sistema de comissao de vendedores')
nLinGetD:=n 
	_nPerce := _nPerce + 0.001
	_cFaixa := CHR(ASC(_cFaixa)+1)
RETURN(.T.)	

//
USER FUNCTION AD2TUDOOK
//	MsgStop("Existem "+Str(Len(aCols))+" linhas na GetDados")
RETURN(.T.)

//
USER FUNCTION AD2VL1 (_Codigo,_Tabela)

U_ADINF009P('AD0003' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Menu inicial do sistema de comissao de vendedores')
dbSelectArea("SZA")
dbSetOrder(1)
if !dbSeek(xFilial()+_cCodigo+_Tabela)
	RETURN(.T.)
ELSE
	MSGSTOP("TABELA EXISTENTE! ENTRE COM OUTRO CODIGO")
	RETURN(.F.)
Endif
RETURN(.T.)
//
USER FUNCTION AD2VL2 (_Codigo,_Tabela)

U_ADINF009P('AD0003' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Menu inicial do sistema de comissao de vendedores')
dbSelectArea("SZA")
dbSetOrder(1)
if  dbSeek(xfilial()+_Codigo,_Tabela)
	RETURN(.T.)
ELSE
	MSGSTOP("TABELA NAO EXISTE! ENTRE COM OUTRO CODIGO")
	RETURN(.F.)
Endif
RETURN(.T.)