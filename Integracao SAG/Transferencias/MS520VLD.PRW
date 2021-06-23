#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#Include 'Topconn.ch'

/*/{Protheus.doc} User Function MS520VLD
	Valida a exclusão da nota de saída no caso de uma operacao de remessa de ovos para incubatorio
	@type  Function
	@author Microsiga
	@since 01/10/2013
	@history Chamado 046817 - Everson - 30/01/2019 - Valida exclusão da nota fiscal pelo parâmetro MV_SPEDEXC.
	@history Chamado 059025 - Abel    - 30/06/2020 - Valida se a Emissão da NF está  dentro do parâmetro MV_#DTEMIS
	/*/
User Function MS520VLD

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local aAreaSA2  := GetARea("SA2")
	Local aAreaSA1  := GetARea("SA1")
	Local cTesRem	:= SuperGetMV("FS_TESREMI" ,,"702|705|735")  // trata todas as operacoes de remessa para industrialização
	Local cAlDes	:= cAlOri := ""
	Local lContinua :=.F.
	Local nHorCanc	:= GetMv("MV_SPEDEXC",,24) //Everson - 30/01/2019. Chamado 046817.

	Local dDtLEmis	:= GetMV('MV_#DTEMIS') //Chamado 059025 - Abel    - 30/06/2020 - Valida se a Emissão da NF está  dentro do parâmetro MV_#DTEMIS

	//Everson - 30/01/2019. Chamado 046817.
	If ! Empty(Alltrim(cValToChar(SF2->F2_DAUTNFE))) .And. ! Empty(Alltrim(cValToChar(SF2->F2_HAUTNFE)))
		If ! vldHoras(nHorCanc,SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE)
			MsgStop("Nota fiscal não pode ser excluída/cancelada, pois o tempo de cancelamento já foi excedido.","Função MS520VLD-1")
			RestArea(aAreaSA2)
			RestArea(aAreaSA1)
			RestArea(aArea)	
			Return .F.
					
		EndIf
		
	EndIf
	//

	//INICIO Chamado 059025 - Abel    - 30/06/2020 - Valida se a Emissão da NF está  dentro do parâmetro MV_#DTEMIS
	IF SF2->F2_EMISSAO <= dDtLEmis
		MsgStop("Nota fiscal não pode ser excluída/cancelada, pois a data de emissão está bloqueada, Consulte o Depto. Fiscal (MV_#DTEMIS).","Função MS520VLD-2")
		RestArea(aAreaSA2)
		RestArea(aAreaSA1)
		RestArea(aArea)	
		Return .F.
	ENDIF
	//FIM Chamado 059025 - Abel    - 30/06/2020 - Valida se a Emissão da NF está  dentro do parâmetro MV_#DTEMIS

	If Alltrim(cEmpAnt) == "01"
		If SF2->F2_TIPO == "N"
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
			If SA1->(!EOF())
				If !Empty(SA1->A1_LOCAL)
					cAlDes := SA1->A1_LOCAL
					lContinua:=.T.
				EndIf
			EndIf
		ElseIf SF2->F2_TIPO == "B"
			SA2->(dbSetOrder(1))
			SA2->(dbSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA))
			If SA2->(!EOF())
				If !Empty(SA2->A2_LOCAL)
					cAlDes := SA2->A2_LOCAL
					lContinua:=.T.
				EndIf
			EndIf
		EndIf

		If lContinua

			SD2->(DbSetOrder(3))
			SD2->(DbSeek( SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
			While SD2->(!EOF()) .and. SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) == SD2->(D2_FILIAL+ D2_DOC+ D2_SERIE+ D2_CLIENTE+ D2_LOJA)
				If SD2->D2_TES $cTesRem
					/*//tratamento para deleter movimento sem saldo
					dbSelectArea("SB2")
					dbSeek(xFilial("SB2")+SD2->(D2_COD)+cAlDes)
					If (SaldoMov(Nil,Nil,Nil,.T.,Nil,Nil,Nil,dDatabase) - SD2->(D2_QUANT)) < 0 .and. GetMV("MV_ESTNEG") == "N"
					MsgInfo("Exclusão NF Operacao de Remessa Ovos Incubatorio não permitida. Sem saldo para estornar trasnferência produto/armazem. " + "["+ SD2->(D2_COD)+"/"+cAlDes + "]" ,"Atencao")
					Return(.F.)
					EndIf*/
				EndIf
				SD2->(DbSkip())
			EndDo
		EndIf

	Endif
	RestArea(aAreaSA2)
	RestArea(aAreaSA1)
	RestArea(aArea)

Return(.T.)

/*/{Protheus.doc} User Function vldHoras
	Funçao calcula as horas transcorridas desde a autorização da nota fiscal de saída.
	@type  Function
	@author Everson
	@since 30/01/2019
	@history Chamado 046817 - Everson - 30/01/2019 - Valida exclusão da nota fiscal pelo parâmetro MV_SPEDEXC.
	/*/
Static Function vldHoras(nHorCanc,cFil,cDoc,cSerie)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	:= GetArea()
	Local lRet	:= .T.

	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " CASE WHEN  " 
	cQuery += " ( " 
	cQuery += " DATEDIFF( " 
	cQuery += " SECOND,  " 
	cQuery += " DATETIMEFROMPARTS (YEAR(F2_DAUTNFE), MONTH(F2_DAUTNFE) , DAY(F2_DAUTNFE) , DATEPART(HOUR,F2_HAUTNFE), DATEPART(MINUTE,F2_HAUTNFE), DATEPART(SECOND,F2_HAUTNFE), DATEPART(MILLISECOND,F2_HAUTNFE) ),  " 
	cQuery += " SYSDATETIME()) / 3600.0) > " + cValToChar(nHorCanc) + " " 
	cQuery += " THEN 0  " 
	cQuery += " ELSE 1  " 
	cQuery += " END AS EXCLUI_NOTA " 
	cQuery += " FROM " + RetSqlName("SF2") + "  " 
	cQuery += " WHERE  " 
	cQuery += " F2_FILIAL = '" + cFil + "'  " 
	cQuery += " AND F2_DOC = '" + cDoc + "' " 
	cQuery += " AND F2_SERIE = '" + cSerie + "' " 
	cQuery += " AND D_E_L_E_T_ = '' " 

	//
	If Select("CHK_NF") > 0
		CHK_NF->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "CHK_NF"
	DbSelectArea("CHK_NF")
	CHK_NF->(DbGoTop())

	lRet := Iif( Val(cValToChar(CHK_NF->EXCLUI_NOTA)) == 0, .F., .T.)

	CHK_NF->(DbCloseArea())
	
	//
	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
		ZBE->ZBE_FILIAL 	:= xFilial("ZBE")
		ZBE->ZBE_DATA 	   	:= dDataBase
		ZBE->ZBE_HORA 	   	:= Time()
		ZBE->ZBE_USUARI	    := Upper(Alltrim(cUserName))
		ZBE->ZBE_LOG	    := "Exclusão de nota fiscal de saída parâmetro MV_SPEDEXC " + cValToChar(nHorCanc) + " ret. " + cValToChar(lRet)
		ZBE->ZBE_PARAME		:= "filial/nota/serie " + cFil + "/" + cDoc + "/" + cSerie
		ZBE->ZBE_MODULO	    := "FISCAL"
		ZBE->ZBE_ROTINA	    := "MS520VLD" 
	ZBE->( MsUnlock() )

	//
	RestArea(aArea)

Return lRet
