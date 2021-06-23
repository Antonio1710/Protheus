#INCLUDE "rwmake.ch"

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
��� Programa � AD0165      � Autor �Werner dos Santos� Data � 23/03/2006 ���
������������������������������������������������������������������������͹��
���Desc.     �Realiza consula ao Pedido de venda                         ���
������������������������������������������������������������������������͹��
���Uso       � Depto. de Logistica                                       ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
USER FUNCTION AD0165 

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Realiza consula ao Pedido de venda')

//��������������������������������������������������������������Ŀ
//� Opcao de acesso para o Modelo 2                              �
//����������������������������������������������������������������
// 3,4 Permitem alterar getdados e incluir linhas
// 6 So permite alterar getdados e nao incluir linhas
// Qualquer outro numero so visualiza
_aArea:=GetArea()
//�����������������������������������������������������������Ŀ
//� Opcoes de acesso para a Modelo 3                          �
//�������������������������������������������������������������
cOpcao := "VISUALIZAR"
nOpcE  := nOpcG := 2

//�����������������������������������������������������������Ŀ
//� Cria variaveis M->????? da Enchoice                       �
//�������������������������������������������������������������
RegToMemory("SC5",(cOpcao=="INCLUIR"))
//�����������������������������������������������������������Ŀ
//� Cria aHeader e aCols da GetDados                          �
//�������������������������������������������������������������
nUsado := 0					//NUMERO DE CAMPOS DO SC6
dbSelectArea("SX3")
DBGOTOP()
DBSETORDER(1)
dbSeek("SC6")
aHeader := {}
While !Eof().And.(x3_arquivo=="SC6")
	If Alltrim(x3_campo)=="C6_ITEM"
		dbSkip()
		Loop
	Endif
	If X3USO(x3_usado).And.cNivel>=x3_nivel
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,"AllwaysTrue()",;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
	dbSkip()
End
/*If cOpcao == "INCLUIR"
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next*/
//Else
	aCols:={}
	dbSelectArea("SC6")
	dbSetOrder(1) 
	dbSeek(xFilial()+SC5->C5_NUM)
	While !eof().and.C6_NUM==SC5->C5_NUM
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 to nUsado
			aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
		Next
		aCols[Len(aCols),nUsado+1]:=.F.
		dbSkip()
	End
//Endif

If Len(aCols)>0
	//�����������������������������������������������������������Ŀ
	//� Executa a Modelo 3 �
	//�������������������������������������������������������������
	cTitulo        := " Cliente " + SC5->C5_CLIENTE + "-" + SC5->C5_NOMECLI
	cAliasEnchoice := "SC5"
	cAliasGetD     := "SC6"
	cLinOk         := "AllwaysTrue()"
	cTudOk         := "AllwaysTrue()"
	cFieldOk       := "AllwaysTrue()"
   aCpoEnchoice   := {"C5_NUM","C5_CLIENTE","C5_LOJA","C5_TIPO","C5_NOMECLI","C5_ENDERE","C5_BAIRRO","C5_CIDADE",;
                      "C5_ROTEIRO","C5_PBRUTO","C5_DTENTR","C5_TRANSP","C5_PLACA","C5_VEND1"}
	_lRet          := Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)
Endif
RestArea(_aArea)
Return