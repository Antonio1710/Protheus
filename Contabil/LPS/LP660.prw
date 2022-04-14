#INCLUDE "rwmake.ch"

/*/{Protheus.doc} User Function nomeFunction
	Retorna o numero do item contabeil de SD1 para o lp 660-000
	@type  Function
	@author hcconsys
	@since 21/05/07
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 71057 - Fernando Macieira - 08/04/2022 - Item contábil Lançamentos da Filial 0B - Itapira
/*/
User Function LP660()

	Local  _aArea   := GetArea()
	Local _aAreaSF1 := SF1->(GetArea())
	Local _aAreaSD1 := SD1->(GetArea())
	Local _aAreaSDE := SDE->(GetArea())

	Local _cItemCta := ""  

	U_ADINF009P('LP660' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	dbSelectArea("SD1")
	dbSetOrder(1)
	dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA,.T.)

	If SD1->D1_RATEIO <> "1"
		_cItemCta	:= SD1->D1_ITEMCTA
		If empty(_cItemCta)
			_cItemCta := iif(SD1->D1_FILIAL=="02","121",iif(SD1->D1_FILIAL=="06","122",iif(SD1->D1_FILIAL=="07","123",iif(SD1->D1_FILIAL=="08","115",iif(SD1->D1_FILIAL=="09","116","114")))))
		EndIf

	Else
		
		//LER ARQUIVO DE RATEIO
		
		dbSelectArea("SDE")
		dbSetOrder(1)
		dbSeek(xFilial("SDE") + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_ITEM,.T.)
		
		_cItemCta	:= SDE->DE_ITEMCTA
		If empty(_cItemCta)
			_cItemCta := iif(SDE->DE_FILIAL=="02","121",iif(SDE->DE_FILIAL=="06","122",iif(SD1->D1_FILIAL=="07","123",iif(SD1->D1_FILIAL=="08","115",iif(SD1->D1_FILIAL=="09","123","116")))))
		EndIf
		
	Endif

	// @history ticket 71057 - Fernando Macieira - 08/04/2022 - Item contábil Lançamentos da Filial 0B - Itapira
	If AllTrim(cEmpAnt) == "01" .and. AllTrim(cFilAnt) == "0B"
		_cItemCta := AllTrim(GetMV("MV_#ITAFIL",,"125"))
	EndIf
	//

	RestArea(_aArea)
	RestArea(_aAreaSF1)
	RestArea(_aAreaSD1)
	RestArea(_aAreaSDE)

Return(_cItemCta) 
					

// Rotina para tratar o retorno da Natureza de opercao para LP 660.
// *******************************************************************
User Function LP660SED()

// *******************************************************************
	Local  _aArea   		:= GetArea()
	Local _aAreaSE2	:= SE2->(GetArea())
	Local _aAreaSDE	:= SDE->(GetArea())    
	Local _cContaSED:="" 

	U_ADINF009P('LP660' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	// ***************** INICIO ALTERACAO CHAMADO 024322 ********************************************** //
	SqlTitPag(Xfilial("SE2"),SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_SERIE,SF1->F1_DOC)
		
	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³apos a atualizacao do sistema protheus no dia 03/08/2015, passou-se no momento do estorno da classificacao³
	//³da nota de entrada foi alterado pela totvs, anteriormente fazia o seguinte processo:                      ³
	//³ESTORNO NF COMPRAS -> LANCAMENTOS PADROES -> EXCLUSAO DO TITULO                                           ³
	//³agora com a alteracao ficou assim                                                                         ³
	//³ESTORNO NF COMPRAS -> EXCLUSAO DO TITULO -> LANCAMENTOS PADROES                                           ³
	//³portanto foi refeito esse select para ler arquivos do SE2 deletados mais ordenado por R_E_C_N_O_          ³
	//³para garantir que pegue o ultimo excluido.                                                                ³
	//³EXPLICACAO POR WILLIAM COSTA                                                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ENDDOC*/
	
	While TRB->(!EOF())
					
		_cContaSED	:=	TRB->ED_CONTA 
				
		TRB->(dbSkip())
	ENDDO
	TRB->(dbCloseArea()) 
	// ***************** INICIO ALTERACAO CHAMADO 024322 ********************************************** //


	/*
	//SA2->(  dbSetOrder(1) )
	//SA2->( dbSeek(XFILIAL("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA) )
	SE2->(  dbSetOrder(6) )
	SE2->( dbSeek(XFILIAL("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC) )

	SED->(  dbSetOrder(1) )
	//SED->( dbSeek( XFILIAL("SED")+SA2->A2_NATUREZ) )
	SED->( dbSeek( XFILIAL("SED")+SE2->E2_NATUREZ) )

	_cContaSED	:=	SED->ED_CONTA 

	RestArea(_aArea)
	RestArea(_aAreaSE2)
	RestArea(_aAreaSDE)
	*/
Return (_cContaSED)

Static Function SqlTitPag(cFil,cFornece,cLoja,cPrefixo,cDoc)                        

	BeginSQL Alias "TRB"
			%NoPARSER% 
			SELECT TOP(1) SED.ED_CONTA
					FROM %Table:SE2% SE2 WITH(NOLOCK), %Table:SED% SED WITH(NOLOCK) 
					WHERE SE2.E2_FILIAL  = %EXP:cFil%
					AND SE2.E2_FORNECE = %EXP:cFornece%
					AND SE2.E2_LOJA    = %EXP:cLoja%
					AND SE2.E2_PREFIXO = %EXP:cPrefixo%
					AND SE2.E2_NUM     = %EXP:cDoc%
					AND SE2.E2_NATUREZ = SED.ED_CODIGO

			ORDER BY SE2.R_E_C_N_O_ DESC
	EndSQl             

RETURN(NIL) 
