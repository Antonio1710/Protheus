#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "RwMake.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"

// ######################################################################################################
// Projeto: Projeto SalesForce
// Modulo : SIGAFIS
// Fonte  : MT080GRV
// ---------+-------------------+--------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                              | Chamado
// ---------+-------------------+--------------------------------------------------------+---------------
// 07/03/18 | Ricardo Lima      | Atualiza SalesForce com inclusao ou alteracao de TES   | 
// ---------+-------------------+--------------------------------------------------------+---------------
//          |                   |                                                        |
// ---------+-------------------+--------------------------------------------------------+---------------
// ######################################################################################################

USER FUNCTION MT080GRV

	Local aArea	:= GetArea()

//	IF INCLUI .OR. ALTERA .And. FindFunction("U_ADVEN069P")
	IF (INCLUI .OR. ALTERA) .And. FindFunction("U_ADVEN069P")    //Alterado por Adriana em 14/03/2018 - chamado  040380
		U_ADVEN069P("",.F.," AND B1_TS IN ('" + Alltrim(cValToChar(SF4->F4_CODIGO)) + "') AND B1_XSALES = '2' ")

	ENDIF
	
	//
	RestArea(aArea)

Return(.T.)