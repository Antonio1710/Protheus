#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ADRFICMR  ³ Autor ³ HCCONSYS           ³ Data ³  16/10/07   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Funcao dispara por Gatilho em C6_PRODUTO a fim de validar   ³±±
±±³          ³e atualizar o campo C5_TIPOCLI com 'S' quando o campo       ³±±
±±³          ³B1_PICMRET for maior do que zero                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Comercial                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
@history Ticket  TI     - Leonardo P. Monteiro - 26/02/2022 - Inclusão de conouts no fonte. 
*/
User Function ADRFICMR()

	Local cRet	:= M->C5_TIPOCLI
	Local aArea	:= GetArea()
	Local nProd	:= aScan(aHeader, {|x| ALLTRIM(x[2]) == "C6_PRODUTO" })               
	//Local nTES	:= aScan(aHeader, {|x| ALLTRIM(x[2]) == "C6_TES" })
	Local cUF	:= ""      
	Local _lConsFinal	:= .F.

	//Conout( DToC(Date()) + " " + Time() + " ADRFICMR >>> INICIO PE" )

	//U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Funcao dispara por Gatilho em C6_PRODUTO a fim de validar e atualizar o campo C5_TIPOCLI com S quando o campo B1_PICMRET for maior do que zero')

	dbSelectArea("SB1")
	SB1->( dbSeek(xFilial("SB1")+aCols[n,nProd]) )

	If M->C5_TIPO $ "D/B"
		dbSelectArea("SA2")
		SA2->( dbSeek(xFilial("SA2")+M->C5_CLIENTE+M->C5_LOJACLI) )          	
		cUF	:= SA2->A2_EST
	Else
		dbSelectArea("SA1")
		SA1->( dbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI) )
		cUF	:= SA1->A1_EST
		if SA1->A1_TIPO = "F"	 //Consumidor Final          
			_lConsFinal	:= .T.
		endif
	Endif	
		
	If cUF == "SP" .Or. cUF == "MG"	.Or. cUF == "RS"  	&&modificacao para atender chamados de Substituicao tributaria - HC Consys.
		If SB1->B1_PICMRET > 0 .and. !_lConsFinal 
		//Incluida verificacao de Consumidor final - por Adriana conforme chamado 020192 de 02/09/2014
			cRet			:= "S"
			M->C5_TIPOCLI	:= "S"
		Endif	
	EndIf

	RestArea(aArea)

	//Conout( DToC(Date()) + " " + Time() + " ADRFICMR >>> FINAL PE" )

Return(cRet)
