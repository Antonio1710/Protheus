#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADOA2_2   �Autor  �Vogas Junior        � Data �  09/24/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de Sub-Segmentos.                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function ADOA02_2

Local aArea			:= GetArea()

Private cCadastro	:= "Cadastro de Sub-Segmentos"
Private cString		:= "PBC"

Private aRotina		:=	{	{"Pesquisar"	,"AxPesqui"							,0,1} ,;
							{"Visualizar"	,"AxVisual(cString, RecNo(), 2)"	,0,2} ,;
							{"Incluir"		,"AxInclui(cString, RecNo(), 3)"	,0,3} ,;
							{"Alterar"		,"AxAltera(cString, RecNo(), 4)"	,0,4} ,;
							{"Excluir"		,"AxDeleta(cString, RecNo(), 5)"	,0,5} }

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Sub-Segmentos')

dbSelectArea(cString)
dbSetOrder(1)
mBrowse( 6,1,22,75,cString)
RestArea( aArea )
Return Nil       
