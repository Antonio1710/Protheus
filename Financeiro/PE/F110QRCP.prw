#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F110QRCP  �Autor  �Fernando Macieira   � Data � 06/12/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada para manipular query de filtro markbrowse ���
���          � - CHAMADO N. 045499                                        ���
�������������������������������������������������������������������������͹��
���Uso       � ADORO                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function F110QRCP()

	Local cNewQuery  := ""
	Local cNewCampos := ""
	
	cNewQuery  := PARAMIXB[1]
	
	cNewCampos += " E1_SALDO, "
	cNewCampos += " ISNULL((SELECT SUM(E1_SALDO) E1_SALDO FROM " + RetSqlName("SE1") + " SE1AB WHERE SE1.E1_FILIAL=SE1AB.E1_FILIAL AND SE1.E1_PREFIXO=SE1AB.E1_PREFIXO AND SE1.E1_NUM=SE1AB.E1_NUM AND SE1.E1_PARCELA=SE1AB.E1_PARCELA AND SE1AB.E1_TIPO='AB-' AND SE1.E1_CLIENTE=SE1AB.E1_CLIENTE AND SE1.E1_LOJA=SE1AB.E1_LOJA AND D_E_L_E_T_=''),0) E1_XAB, "
	
	cNewQuery := Stuff (cNewQuery, 8, 0, cNewCampos)

Return cNewQuery