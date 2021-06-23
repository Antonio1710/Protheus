#Include "Protheus.CH"
#Include "TopConn.CH"

/*/              
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ADVEN029P ³ Autor ³ ADRIANA OLIVEIRA     ³ Data ³16/08/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Trata gravacao do calendario para TECLAN                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_ADVEN029P(filial,codcli,loja,opcao)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Origem    ³ U_ADOA002 e U_ADOA005   (CHAMADO 029055)                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±  
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ADVEN029P(_cFilial,_cCodCli,_cLoja,_nOpc,nIndice,lSalesForce)  

	Local _aArea    := GetArea()  
	
	Default nIndice	:= 1
	Default lSalesForce := .F.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Trata gravacao do calendario para TECLAN')

	DbSelectArea("ZBC")
	DbSetOrder(nIndice)

	If !(DbSeek(_cFilial+_cCodCli+_cLoja))
		if Reclock("ZBC",.T.)
			ZBC_FILIAL	:= _cFilial
			
			If ! lSalesForce
				ZBC_CODCLI	:= _cCodCli
				ZBC_LOJA	:= _cLoja
				
			Else
				ZBC_CODPB3	:= _cCodCli
				ZBC_LJPB3	:= _cLoja
			
			EndIf
			
			ZBC_SEG		:= PB3->PB3_TELSEG
			ZBC_TER		:= PB3->PB3_TELTER
			ZBC_QUA		:= PB3->PB3_TELQUA
			ZBC_QUI		:= PB3->PB3_TELQUI
			ZBC_SEX		:= PB3->PB3_TELSEX
			ZBC_ULTIMP 	:= ctoD("  /  /    ")
			ZBC_SEMANA  := PB3->PB3_LIGSEM
			ZBC_FREQUE	:= PB3->PB3_LIGFRQ
			ZBC_HORARI	:= PB3->PB3_LIGHOR
			MsUnlock()
		endif
	else
		if Reclock("ZBC",.F.)
			ZBC_SEG		:= PB3->PB3_TELSEG
			ZBC_TER		:= PB3->PB3_TELTER
			ZBC_QUA		:= PB3->PB3_TELQUA
			ZBC_QUI		:= PB3->PB3_TELQUI
			ZBC_SEX		:= PB3->PB3_TELSEX
			ZBC_SEMANA  := PB3->PB3_LIGSEM
			ZBC_FREQUE	:= PB3->PB3_LIGFRQ
			ZBC_HORARI	:= PB3->PB3_LIGHOR
			MsUnlock()
		endif
	endif

	RestArea(_aArea)

Return Nil