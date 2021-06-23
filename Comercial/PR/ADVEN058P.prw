#Include "PROTHEUS.CH" 
#Include "RWMAKE.CH"
                       
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADVEN058P �Autor    �Fernando Sigoli  � Data �  18/10/17    ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina de valida��o de campo C ���
���          �                   ���
�������������������������������������������������������������������������͹��
���Uso       � ADORO                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function ADVEN058P()
       
Local lRet 		:= .F.
Local i    		:= 0
Local nVlPrc    := Ascan(aHeader, { |x| Alltrim(x[2]) == "C6_PRCVEN" }) 
Local nVlTot    := Ascan(aHeader, { |x| Alltrim(x[2]) == "C6_VALOR"  }) 

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina de valida��o de campo C')

If aCols[1,nVlPrc] > 0 
	
	For i := 1 to Len(aCols)
	   	acols[i][nVlPrc] := 0
		acols[i][nVlTot] := 0 
	  	
	  	lRet := .T.
		  	
	Next i  
 	
EndIf
	
If lRet
	GETDREFRESH()
   	A410LinOk(oGetDad)	
EndIf

Return .T.