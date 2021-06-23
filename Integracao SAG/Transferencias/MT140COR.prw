#Include 'Protheus.ch'

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 � MT140COR     � Autor � Leonardo Rios	     � Data � 13.04.16 ���
��������������������������������������������������������������������������Ĵ��
���Desc.     � Efetua tratamento no menu da Rotina de Pr�-Nota para possibi���
���			 � litar o tratamento do estorno de pr�-notas			   	   ���
��������������������������������������������������������������������������Ĵ��
���Uso		 � MATA140 - Pr�-Documento de Entrada						   ���
���			 � Ponto de entrada para manipular o array com as regras e     ���
���			 � cores da Mbrowse											   ���
���			 � Projeto SAG II											   ���
��������������������������������������������������������������������������Ĵ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
User Function MT140COR()

Local aRet	 := paramixb[1]
Local n		 := 0

If Alltrim(cEmpAnt) == "01"
	If ISINCALLSTACK("U_INTNFEB")
		Return aRet
	EndIf

	For n:=1 To Len(aRotina)    
		If aRotina[n][1] $ "Es&torna Classif"	
			aRotina[n][2] := "U_ADSAG001"		
		EndIf
	Next n                 
Endif	

Return aRet