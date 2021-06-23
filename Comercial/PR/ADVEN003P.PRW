#INCLUDE "rwmake.ch"

/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±ºPrograma  ³CADTABX5    º Autor ³ Mauricio - MDS TEC Data ³  22/04/15   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±ºDescricao ³ CADASTRO NO SX5                                            º±±
±±º          ³                                                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±ºUso       ³ adoro                                                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CADTABX5()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := "Cadastro de Faixas para preço minimo(PV)"
Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
{"Visualizar","U_O999MANUT(2)",0,2} ,;
{"Incluir","U_O999MANUT(3)",0,3} ,;
{"Alterar","U_O999MANUT(6)",0,4} }
//{"Excluir","U_O999MANUT(5)",0,5} }

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

Private cString := "SX5"

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'CADASTRO NO SX5')

dbSelectArea("SX5")
dbSetOrder(1)
dbSelectArea(cString)
Set Filter To X5_TABELA = "A#"
mBrowse( 6,1,22,75,cString)
Set Filter To
Return

User Function O999MANUT(nOpcX)
//**************************************************
// 3,4 Permitem alterar getdados e incluir linhas
// 6 So permite alterar getdados e nao incluir linhas
// Qualquer outro numero so visualiza

U_ADINF009P('ADVEN003P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'CADASTRO NO SX5')
dbSelectArea("SX5")
aArea := GetArea()
_cTabela := "A#"
cChaveX5 := SX5->X5_CHAVE
aHeader :={}
aCols	:={}

//---------------------------> MONTAGEM DA ESTRUTURA
nUsado:=0
//MONTAGEM DO aHeadServ PARA OS SERVICOS DO POSTO
dbSelectArea("SX3")
dbSeek("SX5")
While !Eof().And.(SX3->x3_arquivo=="SX5")
	If trim(x3_campo)=="X5_CHAVE".or.trim(x3_campo)=="X5_DESCRI"
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,X3_VALID,x3_usado, x3_tipo, x3_arquivo, x3_context} )
	Endif
	dbSkip()
End

//-------> MONTAGEM DO aCols
If nOpcX == 3
	aCols  := {Array(nUsado+1)}
	aCols [1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aCols [1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
Else
	aCols :={}
	dbSelectArea("SX5")
	SX5->(dbsetOrder(1))
	SX5->(dbSeek("02"+_cTabela+cChaveX5))  &&SOMENTE FILIAL 02 TEM A TABELA CADASTRADA...
	lAdicionou := .f.
	While !eof() .and. SX5->X5_FILIAL == "02" .AND. SX5->X5_TABELA+SX5->X5_CHAVE == _cTabela+cChaveX5
		AADD(aCols ,Array(nUsado+1))
		lAdicionou := .t.
		For _ni:=1 to nUsado
			aCols [Len(aCols ),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
		Next
		aCols [Len(aCols ),nUsado+1]:=.F.
		dbSkip()
	End
	if !lAdicionou
		aCols  := {Array(nUsado+1)}
		aCols [1,nUsado+1]:=.F.
		For _ni:=1 to nUsado
			aCols [1,_ni]:=CriaVar(aHeader[_ni,2])
		Next
	endif
Endif

nLinGetD:=0
cTitulo:="Cadastro de Faixas para preço minimo(PV)"
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em
// Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo eí editavel .t. se nao .f.
aR:={}
aCGD:={46,5,118,315}
cLinhaOk := "U_099VLDLIN()" //validacao da linha
cTudoOk := "U_099TDOOK()" //validacao do browse
AADD(aC,{"_cTabela"		,{15,010} 	,"Chave "				,"@!",'.t.',,.f.})

if Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk)
	If nOpcX == 3.or.nOpcX == 6
		For i:=1 to len(aCols)
			if !(aCols[i,len(aHeader)+1])
				if nOpcX == 3
					RecLock("SX5",.T.)
					SX5->X5_TABELA := _cTabela
					SX5->X5_FILIAL := "02"
				else
					SX5->(dbSeek("02"+_cTabela+aCols[i,1]))
					RecLock("SX5",.F.)
				endif
				SX5->X5_CHAVE := aCols[i,1]
				SX5->X5_DESCRI:= aCols[i,2]
				SX5->X5_DESCSPA := aCols[i,2]
				SX5->X5_DESCENG := aCols[i,2]
				msUnlock()
			endif
		next
	elseif nOpcX == 5
		For i:=1 to len(aCols)
			if !(aCols[i,len(aHeader)+1])
				SX5->(dbSetOrder(1))
				if SX5->(dbSeek("02"+_cTabela+aCols[i,1]))
					recLock("SX5",.F.)
					dbDelete()
					msUnlock()
				endif
			endif
		next
	endif
endif

restArea(aArea)
return
/*
VALIDACAO DA LINHA
*/
User Function 099VLDLIN()
local lRet := .t.

U_ADINF009P('ADVEN003P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'CADASTRO NO SX5')

if INCLUI
	if !(aCols[N,len(aHeader)+1])
		SX5->(dbSetOrder(1))
		SX5->(dbGotop())
		if SX5->(dbSeek("02"+_cTabela+aCols[n,1]))
			msgStop("Codigo Existente")
			lRet := .f.
		endif
		if empty(aCols[N,1])
			msgStop("Informe o valor")
			lRet := .f.
		endif
	endif
endif
return(lRet)

/*
VALIDACAO DE TODOS OS ITENS
*/
User Function 099TDOOK()
local lRet := .t.
U_ADINF009P('ADVEN003P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'CADASTRO NO SX5')
if INCLUI
	for _x:=1 to len(aCols)
		if !(aCols[_x,len(aHeader)+1])
			SX5->(dbSetOrder(1))
			SX5->(dbGotop())
			if SX5->(dbSeek("02"+_cTabela+aCols[n,1]))
				msgStop("Codigo Ja Existente no Cadastro...")
				lRet := .f.
			endif
			if empty(aCols[_x,2])
				msgStop("Informe o valor da faixa:"+alltrim(aCols[_x,1]))
				lRet := .f.
			endif
		endif
	next
endif
return(lRet)
