#include "rwmake.ch"
#include "Protheus.ch"
/*/
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADFIN025P � Autor � Fernando Sigoli    � Data �  03/01/17   ���
�������������������������������������������������������������������������͹��
���Descri��o � Programa para alteracao do parametro MV_BXCONC             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
 
User Function ADFIN025P()

Local aAreaAnt := GetArea()
Local _cCodUser:= RetCodUsr()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa para alteracao do parametro MV_BXCONC')

If Alltrim(_cCodUser) $ GetMV("MV_ALTBX")  

	If MsgBox("O parametro que Permite cancelamento de baixa conciliada esta como: "+IIF(GETMV("MV_BXCONC")== '1','PERMITE','N�O PERMITE')+"."+ CHR(13)+ CHR(13)+ "Deseja alterar o par�metro?"," Altera par�metro MV_BXCONC  ","YESNO")
	
		If Pergunte("ALTBXCON")
			PutMv("MV_BXCONC ",MV_PAR01) 
			MsgAlert("Parametro Alterado")
		EndIf 
		
	Else
		MsgAlert("Processo Cancelado")
	EndIf
Else
	MsgAlert("Aten��o! Acesso N�o autorizado")
EndIF	
RestArea(aAreaAnt)

Return .T.
 