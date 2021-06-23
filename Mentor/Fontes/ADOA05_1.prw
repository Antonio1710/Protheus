/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADOA05_1  �Autor  �Vogas Junior        � Data �  16/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de Providencias. Trata-se das providencias a serem ���
���          �tomadas no momento do encaminhamento do cliente ao aprovador���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function ADOA05_1

	Local aArea			:= GetArea()

	Private cCadastro	:= "Cadastro de Provid�ncias"
	Private cString		:= "PB8"

	Private aRotina		:=	{	{"Pesquisar"	,"AxPesqui"							,0,1} ,;
								{"Visualizar"	,"AxVisual(cString, RecNo(), 2)"	,0,2} ,;
								{"Incluir"		,"AxInclui(cString, RecNo(), 3)"	,0,3} ,;
								{"Alterar"		,"AxAltera(cString, RecNo(), 4)"	,0,4} ,;
								{"Excluir"		,"AxDeleta(cString, RecNo(), 5)"	,0,5} }

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Providencias. Trata-se das providencias a serem tomadas no momento do encaminhamento do cliente ao aprovador')

	dbSelectArea(cString)
	dbSetOrder(1)
	mBrowse( 6,1,22,75,cString)
	RestArea( aArea )

Return Nil       
