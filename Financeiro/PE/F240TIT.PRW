#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} User Function F240TIT
	Nao Permitido baixa de titulo gerados por pedido de compra com a condicao de pagamento "ICM", tera que ser feito por Compensacao - Projeto Financas 
	@type  Function
	@author Ricardo Lima
	@since 03/01/2018
	@chamado 038611
	@history Chamado 051044 - Adriana      - 27/08/2019 - SafEgg
	@history Chamado 053347 - FWNM         - 29/11/2019 - 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL
	@history Ticket    4883 - Abel Babini  - 04/01/2021 - Geração de borderôs automática
/*/
User Function F240TIT 

	Local lRet       := .T.
	Local E2NUM     := SE2->E2_NUM 
	Local E2PREFIXO := SE2->E2_PREFIXO 
	Local E2FORNECE := SE2->E2_FORNECE 
	Local E2LOJA    := SE2->E2_LOJA
	Local E2DIVERG  := SE2->E2_XDIVERG
	Local lPgICM    := .F.
	Local cTpDivf   := "000004"


	// Ricardo Lima - 16/11/17 - nao permite baixa de titulo com divergencia financeira
	//if cEmpAnt = '01' .or. cEmpAnt = '02' .or. cEmpAnt = '09' //Alterado por Adriana chamado 051044 em 27/08/2019 SAFEGG - // Chamado n. 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL - FWNM - 02/12/2019 
	If SE2->E2_XDIVERG == 'S'
		If !FWIsInCallStack("xAutBor")
			MsgInfo("Titulo Com divergencia, Necessário Aprovação!", "Informacao")
		Endif
		lRet := .F.
	ENDIF	

	// RICARDO LIMA - 03/01/18
	IF lRet
		DbSelectArea("SF1")
		DbSetOrder(1) // SF10101 F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO, R_E_C_N_O_, D_E_L_E_T_
		if DbSeek( FwxFilial("SF1") +  E2NUM + E2PREFIXO + E2FORNECE + E2LOJA  )
			IF SF1->F1_COND = "ICM"
				IF EMPTY(E2DIVERG)
				lPgICM := .T.
				ENDIF
			ENDIF			
		endif
	ENDIF

	IF lPgICM
		If !FWIsInCallStack("xAutBor") //@history Ticket   4883 - Abel Babini - 04/01/2021 - Geração de borderôs automática
			If MsgYesNo("Titulo gerado a partir de um Pedido de Compra de ICMS, antes de Realizar a Baixa é necessario enviar para aprovação, Deseja Enviar?")
				lRet := .F.
				
				SE2->E2_XDIVERG := 'S'
				DbSelectArea("SX5")
				DbSetOrder(1)
				DbSeek( FwxFilial("SX5") + 'Z9' + cTpDivf )
				
				// gera registro para aprovacao		
				RecLock("ZC7",.T.)
					ZC7->ZC7_FILIAL := FwxFilial("SE2")
					ZC7->ZC7_PREFIX	:= SE2->E2_PREFIXO
					ZC7->ZC7_NUM   	:= SE2->E2_NUM
					ZC7->ZC7_PARCEL	:= SE2->E2_PARCELA
					ZC7->ZC7_TIPO   := SE2->E2_TIPO // Ricardo Lima - 27/03/18
					ZC7->ZC7_CLIFOR	:= SE2->E2_FORNECE
					ZC7->ZC7_LOJA  	:= SE2->E2_LOJA
					ZC7->ZC7_VLRBLQ	:= SE2->E2_VALOR 
					ZC7->ZC7_TPBLQ 	:= cTpDivf
					ZC7->ZC7_DSCBLQ	:= ALLTRIM(SX5->X5_DESCRI) + " - " + "TITULOS DE ICMS"
					ZC7->ZC7_RECPAG := "P"	 
					ZC7->ZC7_USRALT := __cUserID						 		
				MSUnlock()    	     	
			Endif
		Endif   	 	
		lRet := .F.
	ENDIF
	
	IF lRet .AND. FWIsInCallStack("xAutBor") //@history Ticket   4883 - Abel Babini - 04/01/2021 - Geração de borderôs automática
		
		If aBACBord[nItBAC,9] + SE2->E2_SALDO <=  aBACBord[nItBAC,8]
			aBACBord[nItBAC,9]	+= SE2->E2_SALDO
		Else
			lRet := .F.
		Endif

	ENDIF
Return lRet
