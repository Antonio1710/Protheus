#Include "rwmake.ch"

/*/{Protheus.doc} User Function FA050INC
	Será executado na validação da Tudo Ok na inclusão do contas a pagar
	@type  Function
	@author Ana Helena
	@since 05/07/2013
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 043195 - Abel Babini - 20/09/2019 - Não permitir incluir PA manualmente após a entrada em producao da Solicitacao de PA
	@history chamado 051833 - FWNM        - 27/09/2019 - || OS 053189 || CONTROLADORIA || MONIK_MACEDO || 8956 || LP'S 590/012
	@history chamado 043195 - Abel Babini - 27/09/2019 - Não permitir incluir PA manualmente após a entrada em producao da Solicitacao de PA
	@history chamado 057682 - FWNM        - 28/04/2020 - || OS 059176 || FINANCAS || ANA || 8384 || LP - PAS
	@history chamado 058888 - FWNM        - 12/06/2020 - || OS 060423 || FINANCAS || ANA || 8384 || STEMAC
	@history chamado 058888 - SIGOLI      - 18/06/2020 - || OS 060423 || FINANCAS || ANA || 8384 ||Açterado validação DE data atual para mv_datfin
	@history ticket 74270 - Fernando Macieira - 06/06/2022 - Criar trava no sistema para impedir lançamentos de titulos vencidos
/*/
User Function FA050INC()  

	Local lRet 	:= .T.
	//Ch.043195 ³ 20/09/2019 - Abel Babini - Não permitir incluir PA
	Local lVldSPA	:= GETMV("MV_#VLDSPA",,".T.") //Permite (.T.) ou não (.F.) a inclusao de PA manual  
	Local cUserSPA	:= GETMV("MV_#UFINPA",,"") //Usuarios com permissao de incluir PA
	Local dDataFin  := GetMV("MV_DATAFIN")

	If cEmpAnt == "01"                  
		If Alltrim(M->E2_CCSOLIC) == "" .and. Alltrim(M->E2_TIPO) == "PA"
			Alert("CC Solicit deve ser preenchido para o Tipo PA")
			lRet := .F.
		Endif	
	Endif	
	
	//INICIO Ch.043195 ³ 27/09/2019 - Abel Babini - Não permitir incluir PA
	IF lRet .AND. ((!lVldSPA .AND. !__cUserID$cUserSPA) .AND. Alltrim(M->E2_TIPO) == "PA" .AND. !IsInCallStack("U_ADFIN053P") )
		Alert("Para incluir PA, utilize a rotina Solicitação de PA no Pedido de Compras")
		lRet := .F.
	ENDIF
	//FIM Ch.043195 ³ 20/09/2019 - Abel Babini - Não permitir incluir PA

	// Chamado n. 051833 || OS 053189 || CONTROLADORIA || MONIK_MACEDO || 8956 || LP'S 590/012 - FWNM - 27/09/2019
	If Alltrim(M->E2_TIPO) == "PA" .and. !IsInCallStack("U_ADFIN053P") .and. !IsInCallStack("U_ADFIN054P")
		M->E2_CREDIT := Posicione("SA6",1,FWxFilial("SA6")+cBancoAdt+cAgenciaAdt+cNumCon,"A6_CONTA")
	EndIf
	// 

	// Chamado n. 057682 || OS 059176 || FINANCAS || ANA || 8384 || LP - PAS - FWNM - 28/04/2020
	If lRet
		If AllTrim(M->E2_TIPO) == "PA"
			If ( M->E2_EMISSAO <> M->E2_VENCTO ) .or. ( M->E2_EMISSAO <> M->E2_VENCREA ) .or. ( M->E2_VENCTO <> M->E2_VENCREA )
				lRet := .f.
				Alert("[FA050INC-01] - Adiantamento a Fornecedor precisa possuir emissão e os vencimentos iguais! Inclusão não permitida...")
			EndIf
		EndIf
	EndIf
	//

	// Chamado n. 058888 || OS 060423 || FINANCAS || ANA || 8384 || STEMAC - FWNM - 12/06/2020
	If lRet
		If AllTrim(M->E2_TIPO) $ GetMV("MV_#SE2BLQ",,"PA")
			If M->E2_EMISSAO < dDataFin  //chamado 058888 - SIGOLI - 18/06/2020 
				lRet := .f.
				Alert("[FA050INC-02] - Data de emissão inferior a data do MV_DATAFIN ! Inclusão não permitida...")
			EndIf
		EndIf
	EndIf
	//

	// @history ticket 74270 - Fernando Macieira - 06/06/2022 - Criar trava no sistema para impedir lançamentos de titulos vencidos
	If lRet
		If M->E2_VENCTO <= msDate()
			lRet := .f.
			Alert("[FA050INC-03] - Inclusão de título vencido não permitido! Verifique...")
		EndIf
	EndIf

Return lRet
