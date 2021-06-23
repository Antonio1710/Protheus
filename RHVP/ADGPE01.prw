#include "rwmake.ch" 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � ADGPE01  � Autor � Isamu Kawakami        � Data � 15/08/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula desconto de Contrib. Confederativa                 ���
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
�����������������������������������������������������������������������������*/

User Function ADGPE01()

//��������������������������������������������������������������Ŀ
//� Defini��o de variaveis                                       �
//����������������������������������������������������������������

Local nPercDesc := 0
Local nTetoDesc := 0 
Local cVAssist  := aCodFol[069,1]    
Local cVFerias  := aCodFol[072,1]
Local cVConfed  := aCodFol[175,1]

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Calcula desconto de Contrib. Confederativa')

If SRA->RA_FILIAL $ "04 09"  //incluida filial 09  - chamado 030969 por Adriana
   cVConfed := "487"
EndIf

// Verifica Filial Deve ser Processada (Parte da Reconstrucao do Roteiro de Calculo) - By Asr
If !( SRA->RA_FILIAL $ "03/04/05/09" ) //incluida filial 09 - chamado 030969 por Adriana
   Return("")
EndIf

//��������������������������������������������������������������Ŀ
//� Pesquisa na Tabela RCC Percentual de Desconto e Teto         �
//����������������������������������������������������������������
 RCC->(dbSeek("  U001"+Sra->Ra_Filial)) 
  nPercDesc := Val(Subs(RCC->RCC_Conteu,1,4))
  nTetoDesc := Val(Subs(RCC->RCC_Conteu,5,6)) 

If (Abs(fBuscaPD(cVAssist)) <= 0 .and. DiasTrab > 0) .or. (Abs(fBuscaPD(cVAssist)) <= 0 .and. fBuscaPD(cVFerias) > 0)
   If (nPercDesc/100)*SalMes > nTetoDesc
      fGeraVerba(cVConfed,nTetoDesc,nPercDesc,,,,,,,,.T.)
   Else
      fGeraVerba(cVConfed,SalMes*(nPercDesc/100),nPercDesc,,,,,,,,.T.)
   Endif
Endif      
           
Return("") 
