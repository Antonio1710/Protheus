#Include 'protheus.ch'
#Include "topconn.ch"

/*/{Protheus.doc} User Function MTA120E
    Ponto de Entrada para Continuar ou nao a Exclusao
	@type  Function
	@author FWNM
	@since 28/02/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 056195 - FWNM - 28/02/2020 - OS 057640 || ADM || EVERTON || 45968485 || PC.ORIGEM SIGAEEC EECAE100
	@chamado 056322 - FWNM - 03/03/2020 - Atendimento presencial Karen na alteração pedido embarcado pelo EEC 
/*/
User Function MTA120E()

    Local lMta120E := .t.
	Local cQuery   := ""

	If !IsInCallStack("EECAE100") // chamado 056322 - FWNM - 03/03/2020 - Atendimento presencial Karen na alteração pedido embarcado pelo EEC

		If Select("Work") > 0
			Work->( dbCloseArea() )
		EndIf

		cQuery := " SELECT COUNT(1) TT 
		cQuery += " FROM " + RetSqlName("SC7") + " (NOLOCK)
		cQuery += " WHERE C7_FILIAL='"+FWxFilial("SC7")+"'
		cQuery += " AND C7_NUM='"+cA120Num+"'
		cQuery += " AND C7_ORIGEM='SIGAEEC'
		cQuery += " AND D_E_L_E_T_=''

		tcQuery cQuery New Alias "Work"

		Work->( dbGoTop() )

		If Work->TT >= 1
			lMta120E := .f.
			Aviso(	"MTA120E-01",;
			"Pedido de Compra n. " +cA120Num+ " foi gerado pelo EEC... Exclusão não permitida por esta rotina!",;
			{ "&Retorna" },,;
			"Origem: SIGAEEC" )
		EndIf

		If Select("Work") > 0
			Work->( dbCloseArea() )
		EndIf
	
	EndIf

Return lMta120E