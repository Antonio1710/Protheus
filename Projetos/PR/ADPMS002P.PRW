#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADPMS002P ºAutor  ³Fernando Macieira   º Data ³  01/05/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para efetuar automaticamente o rateio dos projetos  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADPMS002P(cCodPrj, cRevisa, nValor)

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para efetuar automaticamente o rateio dos projetos')

// Popula Cab. Rateio Prj - ZCD
RecLock("ZCD", .T.)

	ZCD->ZCD_FILIAL := xFilial("ZCD")
	ZCD->ZCD_PROJET := cCodPrj
	ZCD->ZCD_REVISA := cRevisa
	ZCD->ZCD_VALOR  := nValor
	
ZCD->( msUnLock() )


// Popula Itens Rateio Prj - ZCE
RecLock("ZCE", .T.)

	ZCE->ZCE_FILIAL := xFilial("ZCE")
	ZCE->ZCE_PROJET := cCodPrj
	ZCE->ZCE_REVISA := cRevisa
	ZCE->ZCE_VALOR  := nValor
	ZCE->ZCE_PERIOD := AnoMes(msDate())
	ZCE->ZCE_DETAIL := "[ DISTRIBUICAO EFETUADA AUTOMATICAMENTE - ADPMS002P ]"
	
ZCE->( msUnLock() )


Aviso(	"ADPMS002P-01",;
"Distribuição realizada automaticamente! " + chr(13) + chr(10) + "Caso desejar realizar manualmente a distribuição dos valores nos períodos vá em: " + chr(13) + chr(10) + "[ Projetos -> Gerenciamento de Projetos -> Ações Relacionadas -> Cronograma Financeiro ]...",;
{ "&OK" },,;
"Cronograma Financeiro Automático - Projetos" )


Return
