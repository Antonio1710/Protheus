#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADLOG024P � Autor � WILLIAM COSTA      � Data �  16/08/2016 ���
�������������������������������������������������������������������������͹��
���Descricao �AxCadastro tabela ZBF - Cadastro de Tabela de Cadastro de   ���
���          �Placas gen�ricas do CTAPLUS.                                ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFAT                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function ADLOG024P()


	//���������������������������������������������������������������������Ŀ
	//� Declaracao de Variaveis                                             �
	//�����������������������������������������������������������������������
	
	Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
	Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
	
	Private cString := "ZBF"
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Placas Genericas CTAPLUS')
	
	dbSelectArea("ZBF")
	dbSetOrder(1)
	
	AxCadastro(cString,"Cadastro de Placas Genericas CTAPLUS",cVldExc,cVldAlt)

Return