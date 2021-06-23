#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AXFV9    � Autor � Gustavo            � Data �  04/09/03   ���
�������������������������������������������������������������������������͹��
���Descricao � Atualizacao da Tabela de Preco por Tonelada                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Logistica                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AXFV9

_cAlias := Alias()
_nIndex := IndexOrd()
_nRecno := Recno()
//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "ZV9"

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tabela de Preco por Tonelada')

dbSelectArea("ZV9")
DbSetOrder (2)

AxCadastro(cString,"Tabela de Preco por Tonelada",cVldAlt,cVldExc)

Return