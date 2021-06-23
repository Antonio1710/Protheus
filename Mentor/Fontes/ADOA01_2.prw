#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*��������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ADOA01_2 � Autor � Vogas Junior          � Data � 08/09/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de permissoes.	                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Adoro - Cadastro espelho de ciente e aprovacao de credito  ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function ADOA01_2

	Local aArea			:= GetArea()

	Private cCadastro	:= "Cadastro de Permiss�es"
	Private cString		:= "PB2"

	Private aRotina		:=	{	{"Pesquisar"	,"AxPesqui"							,0,1} ,;
								{"Visualizar"	,"AxVisual(cString, RecNo(), 2)"	,0,2} ,;
								{"Incluir"		,"AxInclui(cString, RecNo(), 3)"	,0,3} ,;
								{"Alterar"		,"AxAltera(cString, RecNo(), 4)"	,0,4} ,;
								{"Excluir"		,"AxDeleta(cString, RecNo(), 5)"	,0,5} }

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Permiss�es')

	dbSelectArea(cString)
	dbSetOrder(1)
	mBrowse( 6,1,22,75,cString)
	RestArea( aArea )

Return Nil       

