# include "protheus.ch"
                  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �V160FQTD  �Autor  �FlexProjects           � Data �  18/08/15���
�������������������������������������������������������������������������͹��
���Desc.     � FOR�A O FOCO NA QTD NA TELA DE ARMAZENAGEM ANTES DO PRODUTO ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function V160FQTD() 

Local lRet := .T. // -- Customiza��o de usu�rio...

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'FOR�A O FOCO NA QTD NA TELA DE ARMAZENAGEM ANTES DO PRODUTO')

Return lRet
