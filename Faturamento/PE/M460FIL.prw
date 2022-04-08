#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 23/08/00
#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 23/08/00   
#include "topconn.ch"

/*/{Protheus.doc} User Function M460FIL
	Filtra roteiros antes de preparar a nf
	@type  Function
	@author Rogerio Eduardo Nutti
	@since 13/08/2002
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history Chamado 056247 - FWNM          - 29/05/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history ticket 745 - FWNM - 30/09/2020 - C5_XWSPAGO com identificação para liberação manual
	@history ticket 71027 - Fernando Macieira - 07/04/2022 - Liberação Pedido Antecipado sem Aprovação Financeiro - PV 9BEGCC foi incluído depois que o job do boleto parou, não gerou FIE e SE1 (PR) e foi liberado manualmente pelo financeiro, sendo faturado como pv normal... por isso da dupla checagem
/*/
User Function M460fil()        // incluido pelo assistente de conversao do AP5 IDE em 23/08/00   

	Local cFiltroFIE := ""

	Private _cQuery := ""

	cFilSC9     := ''
	_cMVADFAT   := GETMV("MV_ADFAT")
	_cUsuarios 	:= GETMV("MV_#ESTLIB") //Usuarios que acessam MATA460 para estorno de liberacao de documento //por Adriana chamado 035702 em 20/06/17                                
	lCCSP       := IsInCallStack("U_CCSP_002")

	IF (SM0->M0_CODFIL <> '03' .and. (ALLTRIM(CEMPANT)=="01"  .or. ALLTRIM(CEMPANT)=="02")) .and. !(Alltrim(__CUSERID) $ _cUsuarios) //por Adriana chamado 035702 em 20/06/17
	
		IF lCCSP                                            
			cFilSC9 := "SC9->C9_ROTEIRO >= '" + _cRotIni + "' .and. SC9->C9_ROTEIRO <= '" + _cRotFin + "'"
			cFilSC9 += " .and. DTOS(SC9->C9_DTENTR) >= '" + Dtos(_dDtEntr) + "' .and. DTOS(SC9->C9_DTENTR) <= '" + Dtos(_dDtEntr)  + "'"
			cFilSC9 += " .and. POSICIONE('SC5',1,SC9->C9_FILIAL+SC9->C9_PEDIDO,'C5_X_SQED')<> '          ' "
			cFilSC9 += " .and. POSICIONE('SC5',1,SC9->C9_FILIAL+SC9->C9_PEDIDO,'C5_XINT')== '3' "      
		Else
				if !(__cUSERID $ _cMVADFAT)
					cFilSC9 := "SC9->C9_ROTEIRO >= '" + _cRotIni + "' .and. SC9->C9_ROTEIRO <= '" + _cRotFin + "'"
					cFilSC9 += " .and. DTOS(SC9->C9_DTENTR) >= '" + Dtos(_dDtEntr) + "' .and. DTOS(SC9->C9_DTENTR) <= '" + Dtos(_dDtEntr)  + "'"
				else
				cFilSC9 := "SC9->C9_ROTEIRO >= '" + _cRotIni + "' .and. SC9->C9_ROTEIRO <= '" + _cRotFin + "'"
				cFilSC9 += " .and. DTOS(SC9->C9_DTENTR) >= '" + Dtos(_dDtEntr) + "' .and. DTOS(SC9->C9_DTENTR) <= '" + Dtos(_dDtEntr)  + "'"
				endif
		Endif       

	else
		cFilSC9 := " .T."	
	ENDIF 

	// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 28/05/2020
	cFiltroFIE := ChkFIE()
	If !Empty(cFiltroFIE)
		cFilSC9 += cFiltroFIE
	EndIf
	//

Return(cFilSC9)

/*/{Protheus.doc} Static Function ChkFIE
	Função para checar se existe PV de adiantamento e retirá-lo do faturamento se não estiver pago
	@type  Static Function
	@author FWNM
	@since 28/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	@chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
/*/
Static Function CHKFIE()

	Local cNewFiltro := ""
	Local cQuery     := " SELECT DISTINCT C9_PEDIDO FROM " + RetSqlName("SC9") + " SC9 (NOLOCK) WHERE "

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	tcQuery (cQuery + cQrySC9) New Alias "Work"

	Work->( dbGoTop() )

	Do While Work->( !EOF() )

		FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
		If FIE->( dbSeek(FWxFilial("FIE")+"R"+Work->C9_PEDIDO) )

			SC5->( dbSetOrder(1) ) // C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_
			If SC5->( dbSeek(FWxFilial("SC5")+Work->C9_PEDIDO) )
			
				//If AllTrim(SC5->C5_XWSPAGO) <> "S"
				If Empty(AllTrim(SC5->C5_XWSPAGO)) // ticket 745 - FWNM - 30/09/2020 - C5_XWSPAGO com identificação para liberação manual

					cNewFiltro += " .and. SC9->C9_PEDIDO <> '" + SC5->C5_NUM + "' "

				EndIf

			EndIf

		EndIf

		// @history ticket 71027 - Fernando Macieira - 07/04/2022 - Liberação Pedido Antecipado sem Aprovação Financeiro - PV 9BEGCC foi incluído depois que o job do boleto parou, não gerou FIE e SE1 (PR) e foi liberado manualmente pelo financeiro, sendo faturado como pv normal... por isso da dupla checagem
		SC5->( dbSetOrder(1) ) // C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_
		If SC5->( dbSeek(FWxFilial("SC5")+Work->C9_PEDIDO) )
            If Posicione("SE4",1,FWxFilial("SE4")+SC5->C5_CONDPAG,"E4_CTRADT") == '1' // Condição Pagto Adiantamento
                If Empty(SC5->C5_XWSPAGO)
					cNewFiltro += " .and. SC9->C9_PEDIDO <> '" + SC5->C5_NUM + "' "
                EndIf
            EndIf
        EndIf
        //

		Work->( dbSkip() )

	EndDo

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

Return cNewFiltro
