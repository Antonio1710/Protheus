#include "protheus.ch"
#Include "RwMake.ch"
#Include "topconn.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} User Function FA050UPD
	Ponto Entrada - Contas Pagar 
	@type  Function
	@author Fernando Macieira
	@since 20/03/2019
	@version version
  	@history Chamado 047829 - FWNM				- 20/03/2019 - DATAFIN X EXCLUSAO
  	@history Chamado 050958 - FWNM				- 09/08/2019 - TITULO RH
  	@history Chamado 060490 - Adriana Oliveira	- 11/08/2020 - Exclusao TITULO RH pela Controladoria
  	@history Chamado 546 - Adriana Oliveira	- 31/08/2020 - Exceção para Exclusao TITULO pela rotina RH 
/*/

User Function FA050UPD()

	Local lRet     		:= .t.
	Local dDataEmi 		:= SE2->E2_EMISSAO 
	Local dDataFin 		:= GetMV("MV_DATAFIN")
	Local cUserSE2GPE 	:= GetMV("MV_#SE2GPE") //Chamado 060490 - Adriana Oliveira	- 11/08/2020
	
	If INCLUI .or. ALTERA
		If dDataBase < dDataFin 
			lRet := .f.
			Aviso("FA050UPD-01", "Movimentação não permitida! Financeiro bloqueado nesta data. Mude a database ou contate o departamento financeiro...",{"OK"},, "MV_DATAFIN: " + DtoC(dDataFin))
		EndIf
	Else
		If dDataEmi < dDataFin 
			lRet := .f.
			Aviso("FA050UPD-02", "Movimentação não permitida! Financeiro bloqueado nesta data. Contate o departamento financeiro...",{"OK"},, "MV_DATAFIN: " + DtoC(dDataFin))
		EndIf
	EndIf
	
	// Chamado n. 050958 || OS 052280 || RECURSOS || AMANDA || 8393 || TITULO RH - FWNM - 09/08/2019
	//If AllTrim(SE2->E2_ORIGEM) == "GPEM670" 
	If FunName() <> "GPEM660" // Chamado 546 - Adriana Oliveira - 31/08/2020
		// Inicio: Chamado 060490 - Adriana Oliveira	- 11/08/2020
		If AllTrim(SE2->E2_ORIGEM) == "GPEM670" .and. !(Alltrim(__cuserid) $ cUserSE2GPE) //Com parametro MV_GPEEXTT = .T.
			lRet := .f.
			Aviso("FA050UPD-03", "Movimentação não permitida! Título gerado pelo RH... Contate a Controladoria...",{"OK"},, "Atenção")

		Elseif AllTrim(SE2->E2_ORIGEM) == "GPEM670" .and. (Alltrim(__cuserid) $ cUserSE2GPE)

			if ExistRC1() 
				lRet := .f.
				Aviso("FA050UPD-04", "Movimentação não permitida! Título ainda existe no RH... Contate o Departamento Pessoal...",{"OK"},, "Atenção")

			Else
				u_GrLogZBE (Date(),TIME(),cUserName," EXCLUSAO TITULO GERADO PELO RH ","FINANCEIRO","FINA050",;
					"EXCLUSAO TITULO RH "+SE2->E2_NUM+" SERIE "+SE2->E2_PREFIXO+" FORN.: "+Alltrim(SE2->E2_FORNECE)+" EMISSAO "+DTOC(SE2->E2_EMISSAO),ComputerName(),LogUserName())

			Endif

		EndIf
		// Fim: Chamado 060490 - Adriana Oliveira	- 11/08/2020
	Endif // Chamado 546 - Adriana Oliveira - 31/08/2020

Return lRet

/*/{Protheus.doc} Static Function ExistRC1
	Verifica se existe o titulo gerado pelo SIGAGPE - tabela RC1
	@type  Static Function
	@author Adriana Oliveira
	@since 11/08/20
	@history Chamado 060490 - Adriana Oliveira - 11/08/2020
	/*/

Static Function ExistRC1() 

	Local cRC1 		:= ""
	Local lRet		:= .T.

	cRC1	:=GetNextAlias()

	BeginSQL Alias cRC1
		SELECT
			COUNT(*) AS _NEXIST
		FROM %TABLE:RC1% RC1
		WHERE RC1.RC1_FILTIT = %Exp:SE2->E2_FILIAL%
		AND RC1.RC1_NUMTIT = %Exp:SE2->E2_NUM%
		AND RC1.RC1_PREFIX = %Exp:SE2->E2_PREFIXO%
		AND RC1.RC1_FORNEC = %Exp:SE2->E2_FORNECE%
		AND RC1.RC1_LOJA = %Exp:SE2->E2_LOJA%
		AND RC1.RC1_EMISSA = %Exp:DTOS(SE2->E2_EMISSAO)%
		AND RC1.%notDel%
	EndSQL

	DbSelectArea(cRC1)
	(cRC1)->(dbGoTop())

	lRet := if((cRC1)->_NEXIST>0,.T.,.F.)
	
	(cRC1)->(dbCloseArea())

Return lRet
