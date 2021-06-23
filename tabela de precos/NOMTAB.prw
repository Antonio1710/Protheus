#include "rwmake.ch"   
#include "topconn.ch"
User Function NOMTAB()  

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de Help sobre as nomenclaturas de preços')

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NOMTAB   ³ Autor ³ Alex Borges           ³ Data ³ 31/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela de Help sobre as nomenclaturas de preços              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Uso Comercial                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

	@ 00,000 TO 400,650 DIALOG oDlg1 TITLE "NOMENCLATURAS DE PREÇOS "
	nLin := 10
	@ nLin,030 SAY "| Nomenclatura"
	@ nLin,70  SAY "| Descrição" 
	@ nLin,180 SAY "| Definição"
	@ nLin,310 SAY "|"
	nLin := nLin + 5  
	@nLin,30 PSAY REPLICATE("-",250)
	nLin := nLin + 10
	@ nLin,030 SAY "|  PB"
	@ nLin,70  SAY "| Preço Bruto"
	@ nLin,180 SAY "| Preço onde o frete e contrato estão embutido neste"  
	@ nLin,310 SAY "|"
	nLin := nLin + 15
	@ nLin,030 SAY "|  PL"
	@ nLin,70  SAY "| Preço Líquido"
	@ nLin,180 SAY "| Preço depois de descontado o Frete"
	@ nLin,310 SAY "|"
	nLin := nLin + 15
	@ nLin,030 SAY "|  TAB" 
	@ nLin,70  SAY "| Tabela"
	@ nLin,180 SAY "| Preço da Tabela"
	@ nLin,310 SAY "|"
	nLin := nLin + 15
	@ nLin,030 SAY "|  TVD"
    @ nLin,70  SAY "| Tabela Minima Vendedor"
	@ nLin,180 SAY "| Preço da Tabela - % Desconto Vendedor"
	@ nLin,310 SAY "|"
	nLin := nLin + 15
	@ nLin,030 SAY "|  TSP"
	@ nLin,70  SAY "| Tabela Minima Supervisor"
	@ nLin,180 SAY "| Preço da Tabela - % Desconto Supervisor"
	@ nLin,310 SAY "|"
	nLin := nLin + 15
	@ nLin,030 SAY "|  TGV" 
	@ nLin,70  SAY "| Tabela Minima Gerente"
	@ nLin,180 SAY "| Preço da Tabela - % Desconto Gerente" 
	@ nLin,310 SAY "|"
	nLin := nLin + 15
	@ nLin,030 SAY "|  TTV"
	@ nLin,70  SAY "| Preço NF"
	@ nLin,180 SAY "| Preço de venda ao varejo"
	@ nLin,310 SAY "|"
	nLin := nLin + 15
	@ nLin,030 SAY "|  EMP"
	@ nLin,70  SAY "| Preço Medio Empresa"
	@ nLin,180 SAY "| Preço Medio da Empresa no dia" 
	@ nLin,310 SAY "|"
	nLin := nLin + 15
	@ nLin,030 SAY "|  IPTAB"
	@ nLin,70  SAY "| % do Preço Praticado em relação a Tabela"
	@ nLin,180 SAY "| PLTTV / PLTAB"
	@ nLin,310 SAY "|"
	nLin := nLin + 15
	@ nLin,030 SAY "|  IPT"
	@ nLin,70  SAY "| % do Preço liquido Praticado em relação ao "
	@ nLin,180 SAY "| PLTTV / PLEMP"  
	@ nLin,310 SAY "|"
    nLin := nLin + 5
    @ nLin,030 SAY "|"
    @ nLin,70  SAY "| preço Liquido Medio da empresa no dia"
    @ nLin,180 SAY "|" 
    @ nLin,310 SAY "|"
    nLin := nLin + 15
	//@ nLin,060 BMPBUTTON TYPE 01 ACTION GravaSegPeso()
	@ nLin,250 BMPBUTTON TYPE 02 ACTION Close(oDlg1)
	
	ACTIVATE DIALOG oDlg1 CENTER
	

Return


