#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "RwMake.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} User Function MA080MNU
	Ponto entrada utilizado para atualizar SalesForce com inclusao ou alteracao de TES
	@type  Function
	@author Ricardo Lima
	@since 07/03/18
	@version version
	@history Alteração - Adriana Oliveira-09/12/2019-053418, correção error.log na cópia do TES
/*/

USER FUNCTION MA080MNU

	Local aArea	   	:= GetArea()
	Local aRotina	:= ParamIxb[1] //por Adriana em 09/12/2019 - chamado 053418
			
	ADD OPTION aRotina TITLE "Env. SF." ACTION "U_tesSfExp()" OPERATION 9 ACCESS 0

	RestArea(aArea)
	
Return( aRotina )

/*/{Protheus.doc} User Function tesSfExp
	Exporta dados para o Sales Force
	@type  Static Function
	@author Everson
	@since 08/02/17
	@version 01
	/*/

User Function tesSfExp()

	Local aArea		:= GetArea()
	Local cCodLoja	:= ""
	Local cProduto	:= ""

	If ! MsgYesNo("Deseja enviar os registros para o Sales Force?","Função sfExportar")
		RestArea(aArea)
		Return Nil

	EndIf
	
	If FindFunction("U_ADVEN069P")
		U_ADVEN069P( "",.F.," AND B1_TS IN ('" + Alltrim(cValToChar(SF4->F4_CODIGO)) + "') AND B1_XSALES = '2' ")
	
	EndIf

	RestArea(aArea)

Return Nil