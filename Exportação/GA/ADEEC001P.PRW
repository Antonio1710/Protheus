#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ADEEC001P ³ Autor ³ ADRIANA OLIVEIRA   ³ Data ³  30/01/15   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Funcao disparada por Gatilho em EE7_CONSIG para preencher   ³±±
±±³          ³os campos EE7_MENSG, EE7_MENSG2, EE7_MENSG3                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Exportacao                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³08/03/2019³Adriana 047725 ³Alterada palavra CONSIGNEE para IMPORTADOR  ³±±
±±³          ³               ³                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ADEEC001P(_nSeq)
	Local _cMens	:= ""
	Local _cRet		:= ""
	Local aArea		:= GetArea()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Funcao disparada por Gatilho em EE7_CONSIG para preencher os campos EE7_MENSG, EE7_MENSG2, EE7_MENSG3')
	
	dbSelectArea("SA1")
	if SA1->( dbSeek(XFILIAL("SA1")+M->EE7_CONSIG+IF(!EMPTY(M->EE7_COLOJA),M->EE7_COLOJA,"") ) )
		_cMens := "IMPORTADOR: "+RTRIM(SA1->A1_NOME)+" "+RTRIM(SA1->A1_END)+" "+RTRIM(SA1->A1_COMPLEM)+" "+RTRIM(SA1->A1_BAIRRO) //Alterado por Adriana em 08/03/2019 chamado 047725
		_cMens += iif(Alltrim(SA1->A1_MUN)<>"EXTERIOR"," "+RTRIM(SA1->A1_MUN),"")
		_cMens += iif(!Empty(SA1->A1_TEL)," PHONE: "+ RTRIM(SA1->A1_DDI)+"-"+RTRIM(SA1->A1_DDD)+"-"+RTRIM(SA1->A1_TEL),"")
	Endif	
	                          
	If !Empty(_cMens)
	   _cRet := LTrim(Substr(_cMens,((_nSeq-1)*70)+1,70))
	endif
	
	RestArea(aArea)

Return(_cRet)