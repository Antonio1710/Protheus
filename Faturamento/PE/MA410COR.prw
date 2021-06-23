#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA410COR  � Autor � MAURICIO-MDS TEC   � Data �  01/10/15   ���
�������������������������������������������������������������������������͹��
���Descricao � Cores de legenda customizadas para usuario Caio            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MA410COR()

	Local _aCores := PARAMIXB
	
	If __cUserID == "000559"
	   _aCores := {}
	   _aCores := {{"deleted()"                                                  ,'BR_PRETO'  },;
	               {"Empty(C5_LIBEROK) .And. Empty(C5_NOTA) .And. Empty(C5_BLQ)" ,'ENABLE'    },;
	               {"!Empty(C5_NOTA) .Or. C5_LIBEROK=='E' .And. Empty(C5_BLQ)"   ,'DISABLE'   },;
	               {"!Empty(C5_LIBEROK) .And. Empty(C5_NOTA) .And. Empty(C5_BLQ)",'BR_AMARELO'},;
	               {"C5_BLQ == '1'"                                              ,'BR_AZUL'   },;
	               {"C5_BLQ == '2'"                                              ,'BR_LARANJA'}} 
	               
    ELSE

    	AINS(_aCores,3)
    	_aCores[3] := {"C5_STATDOA <> '' .AND. C5_STATDOA == 'B' .AND. Empty(C5_NOTA) ", 'BR_VIOLETA'}
    	
	Endif

Return(_aCores)