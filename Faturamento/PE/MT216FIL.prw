#INCLUDE "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT216FIL �Autor  �KF		            � Data �  11/12/2015  ���
�������������������������������������������������������������������������͹��
���Desc.     � PONTO DE ENTRADA: MT216FIL para filtrar as movimenta��o na ���
���          � rotina de REFAZ PODER.                                     ���
�������������������������������������������������������������������������͹��
���Uso       � P11 - Adoro                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
User Function MT216FIL()

Local _lRet        := .T.
Local aFiltro      := {} 

aAdd(aFiltro,"") //-- Filtro adicional na tabela SB2
aAdd(aFiltro,"") //-- Filtro adicional na tabela SB6 
aAdd(aFiltro,"D1_XFLAG3 =' '") //-- Filtro adicional na tabela SD1 
aAdd(aFiltro,"D2_XFLAG3 =' '") //-- Filtro adicional na tabela SD2 
aAdd(aFiltro,"C6_XFLAG3 =' '") //-- Filtro adicional na tabela SC6
  
Return(aFiltro)