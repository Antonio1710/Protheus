#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ADEEC002P  ºAutor  ³Fernando Macieira   º Data ³  07/03/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Utilizado no X3_VLDUSER do campo YE_VLFISCA e tambem  no   º±±
±±º          ³ X3_WHEN d campo YE_TX_COMP                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ºversionamento:                                                         º±±
±±ºEverson - 28/01/2019. Chamado 046725. Removida validação de PTAX       º±±
±±ºmenor que a taxa fiscal.                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADEEC002P()

	Local lRet := .t.
	Local cMoeda := M->YE_MOEDA
	Local nTaxa  := M->YE_VLCON_C
	Local nTxFis := M->YE_VLFISCA

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Utilizado no X3_VLDUSER do campo YE_VLFISCA e tambem  no X3_WHEN d campo YE_TX_COMP')
	
	/*
	criar uma trava para as moedas US$ / EUR / EUV , colocando a condição que a PTAX das moedas sempre serão maiores e diferentes do que a TAXA FISCAL (1,0000) 
	CAMPO YE_VLCON_C > <> YE_VLFISCA
	*/
	
	If AllTrim(cMoeda) $ "US$#EUR#EUV"
		If nTaxa == nTxFis
			lRet := .f.
			Aviso("ADEEC002P-01", "PTAX não pode ser igual a taxa fiscal", {"&Ok"},, "Gravação não permitida!")
		EndIf
	
		//Everson - 28/01/2019. Chamado 046725.
	/*	If lRet
			If nTaxa <= nTxFis
				lRet := .f.
				Aviso("ADEEC002P-02", "PTAX precisa ser maior que a taxa fiscal", {"&Ok"},, "Gravação não permitida!")
			EndIf
		EndIf*/
		//
	
	EndIf

Return lRet