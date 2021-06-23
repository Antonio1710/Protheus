#include "PROTHEUS.CH"
#include "rwmake.ch"  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA050ROT  � Autor �Fernando Sigoli       Data �  03/07/17   ���
�������������������������������������������������������������������������͹��
���Descricao � rotina que disponibiliza quais os campos que o usuario     ���
���          � dever� ter acessa na tabela SA2                            ���
�������������������������������������������������������������������������͹��
���Uso       � ADORO  - chamado: 036079                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function ADFIN038P()
	Local aArea			:= GetArea()
	Local nOpca 		:= 0  
	Local aParam 		:= {} 
	
	Private aCpos 		:= {"A2_NATUREZ","A2_CONTA","A2_BANCO","A2_COND","A2_MATR","A2_MCOMPRA","A2_METR",;
							"A2_MSALDO","A2_NROCOM","A2_SALDUP","A2_SALDUPM","A2_AGENCIA","A2_NUMCON",;
							"A2_DIGAG","A2_DIGCTA","A2_CLIQF","A2_CONTAB","A2_OBSFIN","A2_CPF","A2_TIPCTA",;
							"A2_IRPROG","A2_CODADM","A2_TPCONTA"}
	  
	Private  aButtons 	:= {}
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'rotina que disponibiliza quais os campos que o usuario dever� ter acessa na tabela SA2')
	
	//
	dbSelectArea("SA2")
	//AxAltera(cAlias,nReg,nOpc,aAcho,aCpos,nColMens,cMensagem,cTudoOk,cTransact,cFunc, aButtons, aParam, aAuto, lVirtual, lMaximized, cTela,lPanelFin,oFather,aDim,uArea)
	nOpca := AxAltera("SA2",SA2->(Recno()),4,,aCpos,,,,,,,,,,.T.,,,,,)
	
	RestArea( aArea )
	
Return(.T.)
