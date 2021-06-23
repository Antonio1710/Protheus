#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADGPE31P  ºAutor  ³Fernando Macieira   º Data ³  02/09/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Formula U_VALERE                                           º±±
±±º          ³ Gera verba 476 - desconto, qdo RA_CARTFRE = S              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function VALERE()

Local nSalDe1   := 0
Local nSalDe2   := 0
Local nSalDe3   := 0
Local nSalDe4   := 0
Local nSalDe5   := 0
Local nSalDe6   := 0
Local nSalAte1  := 0
Local nSalAte2  := 0
Local nSalAte3  := 0
Local nSalAte4  := 0
Local nSalAte5  := 0
Local nSalAte6  := 0
Local nValDesc1 := 0
Local nValDesc2 := 0
Local nValDesc3 := 0
Local nValDesc4 := 0
Local nValDesc5 := 0
Local nValDesc6 := 0
Local nValDesc  := 0
Local nQtFaltas := 0
Local cPDRef 	:= "476" // Verba 476 (Refeicao - Desconto)

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gera verba 476 - desconto, qdo RA_CARTFRE = S')

// Verifica Filial Deve ser Processada
If !( SRA->RA_FILIAL $ "03*05" )
	Return
EndIf

// Executa apenas para o funcionario que possuir Vale Refeição = S
If AllTrim(SRA->RA_CARTFRE) == "S" .and. Empty(SRA->RA_SITFOLH)
	
	// Carrega tabela U002 - Faixas e valores de descontos (RCC)
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
	
	// Define valor desconto
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
	                                      
	//Caso existam faltas, tem que descontar proporcional
	//Por Adriana em 18/09/18 - chamado 043518 
	If Abs(fBuscaPD("409,435")) > 0                             
   		nQtFaltas := Int( Abs(fBuscaPD("409,435","H")) / 7.33 ) //Transforma em dias
	Endif

	nValDesc := nValDesc / 30 * (DiasTrab - nQtFaltas)

	If (DiasTrab - nQtFaltas) > 0
//		fGeraVerba(cPDRef,(nValDesc/30)*DiasTrab,DiasTrab,,,,,,,,.T.)
		fGeraVerba(cPDRef,nValDesc,(DiasTrab - nQtFaltas),,,,,,,,.T.)
	Endif
	
Endif

Return