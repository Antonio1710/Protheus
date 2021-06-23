#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "RwMake.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"

// ######################################################################################################
// Projeto: Projeto SalesForce
// Modulo : SIGAFIS
// Fonte  : MA080BUT
// ---------+-------------------+--------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                              | Chamado
// ---------+-------------------+--------------------------------------------------------+---------------
// 07/03/18 | Ricardo Lima      | Atualiza SalesForce com inclusao ou alteracao de TES   | 
// ---------+-------------------+--------------------------------------------------------+---------------
//          |                   |                                                        |
// ---------+-------------------+--------------------------------------------------------+---------------
// ######################################################################################################


USER FUNCTION MA080BUT
	
	Local aArea	  := GetArea()
	Local aBotao  := {}
	Local cExpresF:= ""
	
	//
	If FindFunction("U_ADVEN069P")
		aBotao := {{"POSCLI",{||  U_ADVEN069P( "",.F.," AND B1_TS IN ('" + Alltrim(cValToChar(SF4->F4_CODIGO)) + "') AND B1_XSALES = '2' ") }, 'Atualiza TES no SalesForce' }}
		
	EndIf
	
	//
	RestArea(aArea)
	
Return(aBotao)