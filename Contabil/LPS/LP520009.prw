#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � LP520009 � Autor � William Costa        � Data �01/10/2015 ���
�������������������������������������������������������������������������͹��
���Descricao � Retorna o numero da conta credito e CENTRO DE CUSTO        ���
���          � correta lp 520-009                                         ���
��� Alteracao�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACTB LANCAMENTOS PADROES                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������

/*/

User Function LP520009(cParam)
      
	/*BEGINDOC
	//������������������������������������������������������Ŀ
	//�cParam pode receber CONTA que sera preenchido a conta �
	//�credito do LP 520-009 ou CUSTO que ser� preenchido o  �
	//�CENTRO DE CUSTO CREDITO do LP 520-009                 �
	//��������������������������������������������������������
	ENDDOC*/

	Local  _aArea     := GetArea()
	Local  cContaCred := '' 
	Local  cCustoCred := ''
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	IF ALLTRIM(SE5->E5_BANCO) == 'P98'
		cContaCred := '191110097'
		cCustoCred := '1303'
	ELSEIF ALLTRIM(SE5->E5_BANCO) <> '' .AND. ALLTRIM(SE5->E5_BANCO) <> 'P98'
		cContaCred := '191110095'
		cCustoCred := ''
	ELSE 
		cContaCred := '191110097'
		cCustoCred := '1302'
	ENDIF
	
	IF ALLTRIM(cParam) == 'CONTA'	 	
		Return (cContaCred)
	ELSE	
		Return (cCustoCred)
	ENDIF	


Return (cContaCred)