#Include 'Protheus.ch'
#Include 'TopConn.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADVEN062P   º Autor ³ Everson          º Data ³  17/11/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Preenchimento do agendamento de promotor.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Chamado 037261.                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ADVEN057P(_cFilial,_cCodCli,_cLoja,_nOpc,_cTipo,nIndice,lSalesForce)  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea    := GetArea() 
	
	Default nIndice:= 2 
	Default lSalesForce := .F.
	
	//
	_cTipo := Alltrim(cValToChar(Upper(_cTipo)))
	
	//
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Preenchimento do agendamento de promotor')
	
	//
	DbSelectArea("ZC6")
	ZC6->(DbSetOrder(nIndice))
	ZC6->(DbGoTop())

	If ! ZC6->(DbSeek(_cFilial+ _cTipo + _cCodCli + _cLoja))
		If Reclock("ZC6",.T.)
		
			ZC6->ZC6_FILIAL	:= _cFilial
			
			If ! lSalesForce
				ZC6->ZC6_CODCLI	:= _cCodCli
				ZC6->ZC6_LOJA	:= _cLoja
				
			Else
				ZC6->ZC6_CODPB3	:= _cCodCli
				ZC6->ZC6_LJPB3	:= _cLoja
				
			EndIf
			ZC6->ZC6_TIPO 	    := _cTipo
				ZC6->ZC6_SEG		:= Iif(_cTipo == "P",PB3->PB3_PRMSEG,PB3->PB3_VEDSEG)
				ZC6->ZC6_TER		:= Iif(_cTipo == "P",PB3->PB3_PRMTER,PB3->PB3_VEDTER)
				ZC6->ZC6_QUA		:= Iif(_cTipo == "P",PB3->PB3_PRMQUA,PB3->PB3_VEDQUA)
				ZC6->ZC6_QUI		:= Iif(_cTipo == "P",PB3->PB3_PRMQUI,PB3->PB3_VEDQUI)
				ZC6->ZC6_SEX		:= Iif(_cTipo == "P",PB3->PB3_PRMSEX,PB3->PB3_VEDSEX)
				ZC6->ZC6_SAB		:= Iif(_cTipo == "P",PB3->PB3_PRMSAB,"")
				ZC6->ZC6_ULTIMP 	:= CToD("  /  /    ")
				ZC6->ZC6_SEMANA		:= Iif(_cTipo == "V",PB3->PB3_VRDSEM,PB3->PB3_PRMSEM)
				ZC6->ZC6_FREQUE		:= Iif(_cTipo == "V",PB3->PB3_VEDFRQ,PB3->PB3_PRMFRQ)
				ZC6->ZC6_HORARI  	:= Iif(_cTipo == "V",PB3->PB3_VEDHOR,PB3->PB3_PRMHOR)
			MsUnlock()
			
		EndIf
		
	Else
		
		If Reclock("ZC6",.F.)
		
				ZC6->ZC6_SEG		:= Iif(_cTipo == "P",PB3->PB3_PRMSEG,PB3->PB3_VEDSEG)
				ZC6->ZC6_TER		:= Iif(_cTipo == "P",PB3->PB3_PRMTER,PB3->PB3_VEDTER)
				ZC6->ZC6_QUA		:= Iif(_cTipo == "P",PB3->PB3_PRMQUA,PB3->PB3_VEDQUA)
				ZC6->ZC6_QUI		:= Iif(_cTipo == "P",PB3->PB3_PRMQUI,PB3->PB3_VEDQUI)
				ZC6->ZC6_SEX		:= Iif(_cTipo == "P",PB3->PB3_PRMSEX,PB3->PB3_VEDSEX)
				ZC6->ZC6_SAB		:= Iif(_cTipo == "P",PB3->PB3_PRMSAB,"")
				ZC6->ZC6_SEMANA		:= Iif(_cTipo == "V",PB3->PB3_VRDSEM,PB3->PB3_PRMSEM)
				ZC6->ZC6_FREQUE		:= Iif(_cTipo == "V",PB3->PB3_VEDFRQ,PB3->PB3_PRMFRQ)
				ZC6->ZC6_HORARI  	:= Iif(_cTipo == "V",PB3->PB3_VEDHOR,PB3->PB3_PRMHOR)		
			MsUnlock()
			
		EndIf
		
	EndIf
	
	//
	RestArea(aArea)

Return Nil