#include "rwmake.ch" 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � ADGPE02  � Autor � Isamu Kawakami        � Data � 15/08/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera Base Salario Contribuicao SAT Diferenciado            ���
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

User Function ADGPE02()

//��������������������������������������������������������������Ŀ
//� Defini��o de variaveis                                       �
//����������������������������������������������������������������
Local nPercSat   := Sra->Ra_PercSat
Local nTotInss   := 0
Local nTotInss13 := 0
Local nBaseAte   := fBuscaPD("721")
Local nBaseAte13 := fBuscaPD("723")

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gera Base Salario Contribuicao SAT Diferenciado')

// Verifica Filial Deve ser Processada (Parte da Reconstrucao do Roteiro de Calculo) - By Asr
If cEmpAnt == '01'
   If !( SRA->RA_FILIAL $ "02/03/04" )
      Return("")
   EndIf
EndIf

// Soma verbas com incidencia para INSS s/ 13o
aEVal(aPD,{|X|SomaInc(X,4,@nTotInss,12,"N",,,,,aCodFol)})

// Soma verbas com incidencia para INSS p/ 13o
aEVal(aPD,{|X|SomaInc(X,4,@nTotInss13,12,"S",,,,,aCodFol)})

// Grava Base Salario Contribuicao SAT Ate Limite
If ( nTotInss+nTotInss13) > 0
   fGeraVerba("833",nBaseAte+nBaseAte13,,,,,,,,,.T.)
EndIf

// Grava Base Salario Contribuicao SAT Acima do Limite
If ( nTotInss+nTotInss13) > (nBaseAte+nBaseAte13)
   fGeraVerba("834",(nTotInss+nTotInss13) - (nBaseAte+nBaseAte13),,,,,,,,,.T.)
Endif
           
Return("")
