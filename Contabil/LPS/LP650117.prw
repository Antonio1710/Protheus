#INCLUDE "rwmake.ch" 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � LP650117 � Autor � WILLIAM COSTA        � Data �  07/08/15 ���
�������������������������������������������������������������������������͹��
���Descricao � Retorna a conta do fornecedor lancamento padrao 650-117    ���
���          �                                                            ���
��� Alteracao�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico ADORO                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������

/*/

User Function LP650117()

	Local _aArea   	:= GetArea()
	Local _aAreaSE2	:= SE2->(GetArea())
	Local _aAreaSDE	:= SDE->(GetArea())    
	Local _cContaSED:="" 
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	//ALTERCOES REALIZADAS POR EVERALDO CASAROLI
	
	//SA2->(  dbSetOrder(1) )
	//SA2->( dbSeek(XFILIAL("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA) )
	SE2->(  dbSetOrder(6) )
	SE2->( dbSeek(XFILIAL("SE2")+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_SERIE+SD1->D1_DOC) )
	
	SED->(  dbSetOrder(1) )
	//SED->( dbSeek( XFILIAL("SED")+SA2->A2_NATUREZ) )
	SED->( dbSeek( XFILIAL("SED")+SE2->E2_NATUREZ) )
	
	_cContaSED	:=	SED->ED_CONTA 
	
	RestArea(_aArea)
	RestArea(_aAreaSE2)
	RestArea(_aAreaSDE)

Return (_cContaSED)