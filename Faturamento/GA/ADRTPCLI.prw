#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ADRTPCLI  ³ Autor ³ HCCONSYS           ³ Data ³  14/05/09   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Funcao dispara por Gatilho em C6_CF a fim de validar        ³±±
±±³          ³e atualizar o campo C5_TIPOCLI com conteudo de A1_TIPO      ³±±
±±³          ³ para os CFOPS iguais a 5401/5910                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Comercial                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
@history Ticket  TI     - Leonardo P. Monteiro - 26/02/2022 - Inclusão de conouts no fonte. 
*/
User Function ADRTPCLI()

	Local cRet	:= M->C5_TIPOCLI
	Local aArea	:= GetArea()
	Local nProd	:= aScan(aHeader, {|x| ALLTRIM(x[2]) == "C6_PRODUTO" })
	//Local nTES	:= aScan(aHeader, {|x| ALLTRIM(x[2]) == "C6_TES" })
	Local cUF	:= ""      
	Local _lConsFinal	:= .F.
	Local _CFST 		:= GetMV("MV_XCFST") //CFOP Venda de embutidos com ICMS ST    5401/5910/5118   - incluido por Adriana em 05/06/2017 - chamado 035483

	//Conout( DToC(Date()) + " " + Time() + " ADRTPCLI >>> INICIO PE" )

	//U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Funcao dispara por Gatilho em C6_CF a fim de validar e atualizar o campo C5_TIPOCLI com conteudo de A1_TIPO para os CFOPS iguais a 5401/5910')

	dbSelectArea("SB1")
	SB1->( dbSeek(xFilial("SB1")+aCols[n,nProd]) )

	If M->C5_TIPO $ "D/B"
		RestArea(aArea)

		//Conout( DToC(Date()) + " " + Time() + " ADRTPCLI >>> FINAL PE" )
		Return(cRet)
	Else
		dbSelectArea("SA1")
		SA1->( dbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI) )
		
		dbSelectArea("SF4")
		//SF4->( dbSeek(xFilial("SF4")+aCols[n,nTES]) )
		SF4->( dbSeek(xFilial("SF4")+M->C6_TES) )
		
		cUF	:= SA1->A1_EST    
		if SA1->A1_TIPO = "F"  //Consumidor Final          
			_lConsFinal	:= .T.
		endif
		
		If cUF == "SP"
			//		If Alltrim(SF4->F4_CF) $ '5401/5910' .and. (!_lConsFinal .or. (_lConsFinal .and. !SF4->F4_CODIGO$GETMV("MV_XTESDOA")))	//Por Adriana em 05/06/17 - chamado 035483
			If Alltrim(SF4->F4_CF) $ _CFST .and. ;
				SB1->B1_PICMRET > 0 .and. (!_lConsFinal .or. (_lConsFinal .and. !SF4->F4_CODIGO$(Alltrim(GETMV("MV_XTESDOA"))+Alltrim(GETMV("MV_XTESBOQ"))))) //Por Adriana em 05/06/17 - chamado 035483
				//CFOP Venda de embutidos com ICMS ST    5401/5910/5118   - incluido por Adriana em 12/04/2017 - chamado 034546
				//Incluida verificacao de Consumidor final com TES Doacao nao calcula - por Adriana conforme chamado 020192 de 02/09/2014
				//Incluido parametro MV_XTESBOQ, para não calcular ST para consumidor final de bonificacao qualidade por Adriana em 02/12/2016 chamado 031656
				cRet			:= "S"
				M->C5_TIPOCLI	:= "S"
			Else
				cRet			:= SA1->A1_TIPO
				M->C5_TIPOCLI	:= SA1->A1_TIPO
			Endif
		EndIf

		If cUF == "MG" .Or. cUF == "RS"
			//		If Alltrim(SF4->F4_CF) $ '5401/5910' .and. (!_lConsFinal .or. (_lConsFinal .and. !SF4->F4_CODIGO$GETMV("MV_XTESDOA")))	//Por Adriana em 05/06/17 - chamado 035483
			If Alltrim(SF4->F4_CF) $ _CFST .and. ;
				SB1->B1_PICMRET > 0 .and. (!_lConsFinal .or. (_lConsFinal .and. !SF4->F4_CODIGO$(Alltrim(GETMV("MV_XTESDOA"))+Alltrim(GETMV("MV_XTESBOQ"))))) //Por Adriana em 05/06/17 - chamado 035483
				//CFOP Venda de embutidos com ICMS ST    5401/5910/5118   - incluido por Adriana em 12/04/2017 - chamado 034546
				//Incluida verificacao de Consumidor final com TES Doacao nao calcula - por Adriana conforme chamado 020192 de 02/09/2014
				//Incluido parametro MV_XTESBOQ, para não calcular ST para consumidor final de bonificacao qualidade por Adriana em 02/12/2016 chamado 031656
				cRet			:= "S"
				M->C5_TIPOCLI	:= "S"
			Else
				cRet			:= SA1->A1_TIPO
				M->C5_TIPOCLI	:= SA1->A1_TIPO
			Endif
		EndIf

	EndIf

	RestArea(aArea)

	//Conout( DToC(Date()) + " " + Time() + " ADRTPCLI >>> FINAL PE" )
	
Return(cRet)

