#include "rwmake.ch"   
#include "topconn.ch"
User Function NOMTAB()  

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de Help sobre as nomenclaturas de pre�os')

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � NOMTAB   � Autor � Alex Borges           � Data � 31/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tela de Help sobre as nomenclaturas de pre�os              ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Uso Comercial                                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

	@ 00,000 TO 400,650 DIALOG oDlg1 TITLE "NOMENCLATURAS DE PRE�OS "
	nLin := 10
	@ nLin,030 SAY "| Nomenclatura"
	@ nLin,70  SAY "| Descri��o" 
	@ nLin,180 SAY "| Defini��o"
	@ nLin,310 SAY "|"
	nLin := nLin + 5  
	@nLin,30 PSAY REPLICATE("-",250)
	nLin := nLin + 10
	@ nLin,030 SAY "|  PB"
	@ nLin,70  SAY "| Pre�o Bruto"
	@ nLin,180 SAY "| Pre�o onde o frete e contrato est�o embutido neste"  
	@ nLin,310 SAY "|"
	nLin := nLin + 15
	@ nLin,030 SAY "|  PL"
	@ nLin,70  SAY "| Pre�o L�quido"
	@ nLin,180 SAY "| Pre�o depois de descontado o Frete"
	@ nLin,310 SAY "|"
	nLin := nLin + 15
	@ nLin,030 SAY "|  TAB" 
	@ nLin,70  SAY "| Tabela"
	@ nLin,180 SAY "| Pre�o da Tabela"
	@ nLin,310 SAY "|"
	nLin := nLin + 15
	@ nLin,030 SAY "|  TVD"
    @ nLin,70  SAY "| Tabela Minima Vendedor"
	@ nLin,180 SAY "| Pre�o da Tabela - % Desconto Vendedor"
	@ nLin,310 SAY "|"
	nLin := nLin + 15
	@ nLin,030 SAY "|  TSP"
	@ nLin,70  SAY "| Tabela Minima Supervisor"
	@ nLin,180 SAY "| Pre�o da Tabela - % Desconto Supervisor"
	@ nLin,310 SAY "|"
	nLin := nLin + 15
	@ nLin,030 SAY "|  TGV" 
	@ nLin,70  SAY "| Tabela Minima Gerente"
	@ nLin,180 SAY "| Pre�o da Tabela - % Desconto Gerente" 
	@ nLin,310 SAY "|"
	nLin := nLin + 15
	@ nLin,030 SAY "|  TTV"
	@ nLin,70  SAY "| Pre�o NF"
	@ nLin,180 SAY "| Pre�o de venda ao varejo"
	@ nLin,310 SAY "|"
	nLin := nLin + 15
	@ nLin,030 SAY "|  EMP"
	@ nLin,70  SAY "| Pre�o Medio Empresa"
	@ nLin,180 SAY "| Pre�o Medio da Empresa no dia" 
	@ nLin,310 SAY "|"
	nLin := nLin + 15
	@ nLin,030 SAY "|  IPTAB"
	@ nLin,70  SAY "| % do Pre�o Praticado em rela��o a Tabela"
	@ nLin,180 SAY "| PLTTV / PLTAB"
	@ nLin,310 SAY "|"
	nLin := nLin + 15
	@ nLin,030 SAY "|  IPT"
	@ nLin,70  SAY "| % do Pre�o liquido Praticado em rela��o ao "
	@ nLin,180 SAY "| PLTTV / PLEMP"  
	@ nLin,310 SAY "|"
    nLin := nLin + 5
    @ nLin,030 SAY "|"
    @ nLin,70  SAY "| pre�o Liquido Medio da empresa no dia"
    @ nLin,180 SAY "|" 
    @ nLin,310 SAY "|"
    nLin := nLin + 15
	//@ nLin,060 BMPBUTTON TYPE 01 ACTION GravaSegPeso()
	@ nLin,250 BMPBUTTON TYPE 02 ACTION Close(oDlg1)
	
	ACTIVATE DIALOG oDlg1 CENTER
	

Return


