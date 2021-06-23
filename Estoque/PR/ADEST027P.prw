#INCLUDE "rwmake.ch"
#INCLUDE "Protheus.ch"

/*/
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADEST027P � Autor � WILLIAM COSTA      � Data �  17/04/2018 ���
�������������������������������������������������������������������������͹��
���Descri��o � Programa para alteracao do parametro MV_DBLQMOV            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
User Function ADEST027P()

	Local aAreaAnt := GetArea()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa para alteracao do parametro MV_DBLQMOV')
	
	IF MsgBox("O per�odo atualmente esta fechado at� o dia: " + (DTOC(STOD(DTOS(GETMV("MV_DBLQMOV")))))+"."+ CHR(13)+ CHR(13)+ "Deseja alterar o par�metro?"," Altera par�metro MV_DBLQMOV ","YESNO")
	
		IF(PERGUNTE(PADR("ADEST027P",10,"")))
		
			PutMv("MV_DBLQMOV",	DTOC(MV_PAR01))
		 
		ENDIF
	
	ENDIF
	
	RestArea(aAreaAnt)

Return 