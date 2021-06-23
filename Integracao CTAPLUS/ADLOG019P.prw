#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADLOG019P � Autor � WILLIAM COSTA      � Data �  22/06/2016 ���
�������������������������������������������������������������������������͹��
���Descricao �AxCadastro tabela ZB9 - Cadastro de Tabela de pre�o de Oleo ���
���          �utilizado pela Logistica                                    ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFAT                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function ADLOG019P()


	//���������������������������������������������������������������������Ŀ
	//� Declaracao de Variaveis                                             �
	//�����������������������������������������������������������������������
	
	Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
	Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
	
	Private cString := "ZB9"
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'AxCadastro tabela ZB9 - Cadastro de Tabela de pre�o de Oleo')
	
	dbSelectArea("ZB9")
	dbSetOrder(1)
	
	AxCadastro(cString,"Cadastro de Tabela de �leo",cVldExc,cVldAlt)

Return