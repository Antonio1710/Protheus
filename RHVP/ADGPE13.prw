#include "rwmake.ch" 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � ADGPE13  � Autor � Isamu Kawakami        � Data � 13/10/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera Base FGTS funcionarios afastados (Acidente)           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RDMake ( DOS e Windows )                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico para AD'ORO ALIMENTOS                           ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function ADGPE13

//��������������������������������������������������������������Ŀ
//� Defini��o de variaveis                                       �
//����������������������������������������������������������������
Local cTipoAfas := ""
Local cFolMes   := GetMV("MV_FOLMES")
Local dDataRefe := StoD(cFolMes+"01")

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gera Base FGTS funcionarios afastados (Acidente)')
      
fChkAfas(Sra->Ra_Filial,Sra->Ra_Mat,dDataRefe,,,@cTipoAfas)

If cTipoAfas == "O"
   fGeraVerba("851",fBuscaPD("731"),nDiasAfas,,,,,,,,.T.)
Endif


Return   
