#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CADFXPS  � Autor � Lt. Paulo - TDS    � Data �  18/05/11   ���
�������������������������������������������������������������������������͹��
���Descricao � Tela para cadastro das tabelas por faixa de pesos          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ESPEC�FICO A'DORO                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function CADFXPS()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela para cadastro das tabelas por faixa de pesos')

dbSelectArea("ZZP")
dbSetOrder(1)

AxCadastro("ZZP",OemToAnsi("Cadastro de Tabela x Faixa de Pesos"),".T.",".T.")

Return