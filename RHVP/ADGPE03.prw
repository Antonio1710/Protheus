#include "rwmake.ch" 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � ADGPE03  � Autor � Isamu Kawakami        � Data � 24/08/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula desconto de Vale Refeicao por Faixas Salariais     ���
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

User Function ADGPE03()

//��������������������������������������������������������������Ŀ
//� Defini��o de variaveis                                       �
//����������������������������������������������������������������

Local nSalDe1    := 0
Local nSalDe2    := 0
Local nSalDe3    := 0
Local nSalDe4    := 0
Local nSalDe5    := 0
Local nSalDe6    := 0
Local nSalAte1   := 0 
Local nSalAte2   := 0 
Local nSalAte3   := 0 
Local nSalAte4   := 0 
Local nSalAte5   := 0 
Local nSalAte6   := 0 
Local nValDesc1 := 0    
Local nValDesc2 := 0    
Local nValDesc3 := 0    
Local nValDesc4 := 0    
Local nValDesc5 := 0    
Local nValDesc6 := 0 
Local nValDesc   := 0  

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Calcula desconto de Vale Refeicao por Faixas Salariais')

// Verifica Filial Deve ser Processada (Parte da Reconstrucao do Roteiro de Calculo) - By Asr
If !( SRA->RA_FILIAL $ "03*04*05" )
   Return("")
EndIf

//��������������������������������������������������������������Ŀ
//� Pesquisa na Tabela RCC as faixas salariais e o desconto      �
//����������������������������������������������������������������
If Sra->Ra_ValeRef == "03"

	RCC->(dbSeek("  U002"+xFilial("RCC")+"      "+"001")) 
 	 	nSalDe1    := Val(Subs(Rcc->Rcc_Conteu,1,12)) 
  	 	nSalAte1   := Val(Subs(Rcc->Rcc_Conteu,13,12))
	  	nValDesc1 := Val(Subs(Rcc->Rcc_Conteu,25,12))
	RCC->(dbSeek("  U002"+xFilial("RCC")+"      "+"002")) 
  		nSalDe2    := Val(Subs(Rcc->Rcc_Conteu,1,12)) 
  		nSalAte2   := Val(Subs(Rcc->Rcc_Conteu,13,12))
  		nValDesc2 := Val(Subs(Rcc->Rcc_Conteu,25,12))                                                                 
	RCC->(dbSeek("  U002"+xFilial("RCC")+"      "+"003")) 
  		nSalDe3    := Val(Subs(Rcc->Rcc_Conteu,1,12)) 
  		nSalAte3   := Val(Subs(Rcc->Rcc_Conteu,13,12))
  		nValDesc3 := Val(Subs(Rcc->Rcc_Conteu,25,12))                                                                 
	RCC->(dbSeek("  U002"+xFilial("RCC")+"      "+"004")) 
  		nSalDe4    := Val(Subs(Rcc->Rcc_Conteu,1,12)) 
 	    nSalAte4   := Val(Subs(Rcc->Rcc_Conteu,13,12))
	    nValDesc4 := Val(Subs(Rcc->Rcc_Conteu,25,12))                                                                 
	RCC->(dbSeek("  U002"+xFilial("RCC")+"      "+"005")) 
  		nSalDe5    := Val(Subs(Rcc->Rcc_Conteu,1,12)) 
 	    nSalAte5   := Val(Subs(Rcc->Rcc_Conteu,13,12))
		nValDesc5 := Val(Subs(Rcc->Rcc_Conteu,25,12))                                                                 
	RCC->(dbSeek("  U002"+xFilial("RCC")+"      "+"006")) 
		nSalDe6    := Val(Subs(Rcc->Rcc_Conteu,1,12)) 
		nSalAte6   := Val(Subs(Rcc->Rcc_Conteu,13,12))
        nValDesc6 := Val(Subs(Rcc->Rcc_Conteu,25,12))                                                                 

	If SalMes >= nSalDe1 .and. SalMes <= nSalAte1
   		nValDesc := nValDesc1
	ElseIf SalMes >= nSalDe2 .and. SalMes <= nSalAte2
   		nValDesc := nValDesc2
	ElseIf SalMes >= nSalDe3 .and. SalMes <= nSalAte3
   		nValDesc := nValDesc3
	ElseIf SalMes >= nSalDe4 .and. SalMes <= nSalAte4
   		nValDesc := nValDesc4
	ElseIf SalMes >= nSalDe5 .and. SalMes <= nSalAte5
   		nValDesc := nValDesc5
	ElseIf SalMes >= nSalDe6 .and. SalMes <= nSalAte6
   		nValDesc := nValDesc6
	Endif
   
    If DiasTrab > 0
       fGeraVerba("476",(nValDesc/30)*DiasTrab,DiasTrab,,,,,,,,.T.)
    Endif   
          
Endif 
           
Return("")
