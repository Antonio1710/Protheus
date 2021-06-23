#include "protheus.ch"        
#include "rwmake.ch"        
#include "topconn.ch"

/*/{Protheus.doc} User Function M460QRY
	Ponto de Entrada rotina MATA461, retorna query para filtrar markbrowse, atua com PE M460FIL
	Utilizada pela Adoro para filtrar roteiros antes de Preparar a NF
	@type  Function
	@author Rogerio Eduardo Nutti 
	@since 13/08/02
	@version 01
	@history 29/08/2002 - Chamado TI RNUTTI -  
	@history 15/12/2010 - Chamado TI Mauricio - para automatizar o seu uso a pedido dos Srs. Evandro e Alex                       
	@history 29/12/2010 - Chamado TI Mauricio - para deletar item do SC9 aonde o item no SC6 foi deletado e contina ativo na tabela SC9
	@history 31/12/2010 - Chamado TI Ana - estava gerando erro, utilizando exemplo do TDN
	@history 19/01/2011 - Chamado TI Alex Borges - atualiza com o lacre do roteiro
	@history 27/01/2015 - Chamado TI Adriana - devido ao erro enviado pelo Raul
	@history 03/02/2016 - Chamado TI Mauricio - Novo tratamento para regra C5_X_SQED preenchido e C5_XINT igual a 3 quando rotina CCSP_002                     
	@history 21/03/2017 - Chamado TI Sigoli - 
	@history 20/06/2017 - Chamado 035702 Adriana - para estorno de liberacao de documento
	@history 11/11/2019 - Chamado 053140 Adriana - para corrigir travamento no retorno PE, quando chamada por CCSP_002 e C5_FRETE > 0
	@history Chamado 056247 - FWNM          - 28/05/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history ticket 745 - FWNM - 30/09/2020 - C5_XWSPAGO com identificação para liberação manual
/*/
User Function M460QRY()

	Local cFiltroFIE := "" // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 28/05/2020

	Public cQrySC9, _cRotIni, _cRotFin, _dDtEntr

	cQrySC9   	:= paramixb[1] // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 28/05/2020 	
	lCheck    	:= .T.
	_cMVADFAT 	:= GETMV("MV_ADFAT")
	_cUsuarios 	:= GETMV("MV_#ESTLIB") 	//Usuarios que acessam MATA460 para estorno de liberacao de documento //por Adriana chamado 035702 em 20/06/2017                                
	_nCodQry	:= paramixb[2]			

	// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 28/05/2020
	/*
	cFiltroFIE := ChkFIE()
	If !Empty(cFiltroFIE)
		cQrySC9 += " AND SC9.C9_PEDIDO NOT IN " + FormatIn(cFiltroFIE,"|")
	EndIf
	*/
	//

	IF Alltrim(Funname())<>"AD0079" .and. Alltrim(Funname())<>"MATA410" .and. !(Alltrim(__CUSERID) $ _cUsuarios) ; //por Adriana chamado 035702 em 20/06/2017
		.and. _nCodQry = 1 //Chamado 053140 Adriana Oliveira - 11/11/2019
		
		// Guarda ambiente inicial                                                  
		_cRotIni := Space(3)
		_cRotFin := Space(3)
		_dDtEntr := dDataBase    // Inc RNUTTI 29/08/2002
		
		lCCSP := IsInCallStack("U_CCSP_002")
		
		If lCCSP
		
			_cRotIni := __Rot
			_cRotFin := __Rot
			_dDtEntr := __dDtEnt

			_Retorna(lCCSP)
			
			Return(cQrySC9)
		
		EndIf
		
		@ 200,001 TO 380,300 DIALOG _oDlg TITLE OemToAnsi("Selecao de Roteiros")
		@ 015,018 Say "Informe o Roteiro Inicial    "
		@ 025,018 Say "Informe o Roteiro Final      "
		@ 035,018 Say "Informe o Data de Entrega    "    
		
		@ 015,100 Get _cRotIni PICTURE "999" when !lCCSP
		@ 025,100 Get _cRotFin PICTURE "999" when !lCCSP
		@ 035,100 Get _dDtEntr PICTURE "@E" when !lCCSP SIZE 40,70   
		
		@ 050,018 SAY "Este procedimento gerara notas fiscais por Roteiro"
		
		@ 065,018 BMPBUTTON TYPE 01 ACTION _Retorna(lCCSP)
		@ 065,058 BMPBUTTON TYPE 02 ACTION Close(_oDlg)

		ACTIVATE DIALOG _oDlg CENTERED

	endif

Return(cQrySC9)

/*/{Protheus.doc} Static Function _Retorna(lCCSP)
	Função complementar
	@type  Function
	@author Rogerio Eduardo Nutti 
	@since 13/08/02
	@version 01
	@history 
/*/
Static Function _Retorna(lCCSP)

	IF ALLTRIM(CEMPANT)=="01" .AND. cFilAnt <> '03'

		nPed := ""

		_cQuery1:= ""
		_cQuery1:= "SELECT C5_NUM FROM "+RETSQLNAME("SC5")+" WHERE C5_ROTEIRO BETWEEN '"+_cRotIni+"' AND '"+_cRotFin+"' AND "
		_cQuery1+= "C5_FILIAL = '"+cFilant+"' AND C5_DTENTR = '"+DTOS(_dDtEntr)+"' AND C5_NOTA = '' AND C5_LIBEROK='S' AND "+RETSQLNAME("SC5")+".D_E_L_E_T_=' ' "

		TcQuery _cQuery1 NEW ALIAS "QRYC5"

		nPed := QRYC5->C5_NUM

		QRYC5->(dbCloseArea())
		
		if !Empty(nPed)

			_cQuery1:=""
			_cQuery1:=" UPDATE 	"+retsqlname("SC6")+" WITH(UPDLOCK) SET C6_ROTEIRO=C5_ROTEIRO, C6_SEQUENC=C5_SEQUENC "
			_cQuery1+=" FROM 	"+RETSQLNAME("SC5")+" "
			_cQuery1+=" WHERE   "
			_cQuery1+=" C6_NUM=C5_NUM 	AND "
			_cQuery1+=" (C5_ROTEIRO BETWEEN '"+_cRotIni+"' AND '"+_cRotFin+"')  AND "
			_cQuery1+=" C5_DTENTR = '"+DTOS(_dDtEntr)+"' AND C5_FILIAL = '"+cFilant+"' AND"
			_cQuery1+=" C5_NOTA=' ' 	AND "
			_cQuery1+=" C5_LIBEROK='S'  "
			_cQuery1+=" AND "+retsqlname("SC6")+".D_E_L_E_T_=' ' "
			_cQuery1+=" AND "+RETSQLNAME("SC5")+".D_E_L_E_T_=' ' "
			
			_cQuery2:=""
			_cQuery2:=" UPDATE 	"+RETSQLNAME("SC9")+" WITH(UPDLOCK) SET C9_ROTEIRO=C5_ROTEIRO, C9_PLACA=C5_PLACA, C9_SEQUENC=C5_SEQUENC, C9_DTENTR=C5_DTENTR "
			_cQuery2+=" FROM 	"+RETSQLNAME("SC5")+" "
			_cQuery2+=" WHERE        "
			_cQuery2+=" C9_PEDIDO=C5_NUM  AND "
			_cQuery2+=" (C5_ROTEIRO BETWEEN '"+_cRotIni+"' AND '"+_cRotFin+"') AND "
			_cQuery2+=" C5_DTENTR = '"+DTOS(_dDtEntr)+"' AND C5_FILIAL = '"+cFilant+"' AND"
			_cQuery2+=" C5_NOTA=' ' 	AND "
			_cQuery2+=" C5_LIBEROK='S' 	"
			_cQuery2+=" AND "+RETSQLNAME("SC9")+".D_E_L_E_T_=' ' "
			_cQuery2+=" AND "+RETSQLNAME("SC5")+".D_E_L_E_T_=' ' "
			
			
			//UPDATE SC6010
			TCSQLExec(_cQuery1)
			
			//UPDATE SC9010
			TCSQLExec(_cQuery2)
			
			//Tratamento para preencher numero de lacre que pode ter ficado em branco - 17/12/2010 - Mauricio.
			//Pego o numero de lacre para o roteiro naquela data de entrega
			if Select("QSC9") > 0
				DbselectArea("QSC9")
				DbCloseArea()
			endif

			_cQuery3 := ""
			_cQuery3 += "SELECT C9_FILIAL, C9_PEDIDO, C9_PLACA, C5_NLACRE1, C9_LACRE1, C9_DTENTR, C5_ROTEIRO, C9_ROTEIRO, (SELECT DISTINCT C5_NLACRE1 "
			_cQuery3 += "                                                                                                    FROM "+RETSQLNAME("SC5")+" C5, "+RETSQLNAME("SC9")+" C9"
			_cQuery3 += "                                                                                                   WHERE C5.C5_NUM = C9.C9_PEDIDO"
			_cQuery3 += "                                                                                                     AND C5.C5_FILIAL = C9.C9_FILIAL"
			_cQuery3 += "                                                                                                     AND C5.C5_FILIAL = '"+cFilant+"' AND (C5_ROTEIRO BETWEEN '"+_cRotIni+"' AND '"+_cRotFin+"')"
			_cQuery3 += "                                                                                                     AND C5.C5_DTENTR = '"+DTOS(_dDtEntr)+"' "
			_cQuery3 += "                                                                                                     AND C9.D_E_L_E_T_=' '"
			_cQuery3 += "                                                                                                     AND C5.D_E_L_E_T_=' '"
			_cQuery3 += "                                                                                                     AND C9.C9_LACRE1 <> '               ') LACRE"
			_cQuery3 += " FROM 	"+RETSQLNAME("SC5")+" C5, "+RETSQLNAME("SC9")+" C9 "
			_cQuery3 += " WHERE C5.C5_NUM = C9.C9_PEDIDO AND C5.C5_FILIAL = C9.C9_FILIAL "
			_cQuery3 += " AND C5.C5_FILIAL = '"+cFilant+"' AND (C5_ROTEIRO BETWEEN '"+_cRotIni+"' AND '"+_cRotFin+"') "
			_cQuery3 += " AND C5.C5_DTENTR = '"+DTOS(_dDtEntr)+"' "
			_cQuery3 += " And C9.C9_LACRE1 = '               '
			_cQuery3 += " AND C9.D_E_L_E_T_=' ' "
			_cQuery3 += " AND C5.D_E_L_E_T_=' ' "
			_cQuery3 += "GROUP BY C9_FILIAL, C9_PEDIDO, C9_PLACA, C5_NLACRE1, C9_LACRE1, C9_DTENTR, C5_ROTEIRO, C9_ROTEIRO "
			
			TcQuery _cQuery3 NEW ALIAS "QSC9"
			
			//Gravo o lacre para os roteiros com itens que tenham o numero de lacre em branco.
			DBSELECTAREA("QSC9")
			DBGOTOP()
			WHILE QSC9->(!EOF())
				_cRoteiro := QSC9->C5_ROTEIRO
				_cLacre   := QSC9->LACRE
				
				If   Empty(_cLacre)
					DBSELECTAREA("ZV2")
					dbSetOrder(5)
					If dbSeek("  "+ QSC9->C9_DTENTR + QSC9->C9_ROTEIRO + QSC9->C9_PLACA)
						_cLacre := ZV2->ZV2_LACRE
						ALERT(_cLacre)
					Endif
				End
				
				_cQuery4:=""
				_cQuery4:=" UPDATE 	"+RETSQLNAME("SC9")+" WITH(UPDLOCK) SET C9_LACRE1='"+_cLacre+"' "
				_cQuery4+=" WHERE        "
				_cQuery4+=" C9_ROTEIRO='"+_cRoteiro+"'  AND C9_FILIAL = '"+cFilant+"' AND"
				_cQuery4+=" C9_DTENTR = '"+DTOS(_dDtEntr)+"' AND "
				_cQuery4+=" C9_LACRE1 = '               ' "
				_cQuery4+=" AND "+RETSQLNAME("SC9")+".D_E_L_E_T_=' ' "
				
				TCSQLExec(_cQuery4)
				
				// Caso o SC5 estiver sem lacre ele atualiza com o lacre do roteiro- Alex Borges - 19/01/2011
				If Empty(QSC9->C5_NLACRE1)
					_cQuery5:=""
					_cQuery5:=" UPDATE 	"+RETSQLNAME("SC5")+" WITH(UPDLOCK) SET C5_NLACRE1='"+_cLacre+"' "
					_cQuery5+=" WHERE        "
					_cQuery5+=" C5_NUM='"+QSC9->C9_PEDIDO+"'  AND C5_FILIAL = '"+cFilant+"' "
					_cQuery5+=" AND "+RETSQLNAME("SC5")+".D_E_L_E_T_=' ' "
					
					TCSQLExec(_cQuery5)
				Endif
				
				QSC9->(dbSkip())

				if _cRoteiro == QSC9->C5_ROTEIRO
					While _cRoteiro == QSC9->C5_ROTEIRO
						QSC9->(dbSkip())
					enddo
				endif

			enddo

		endif
		
		//Tratamento para deletar item do SC9 aonde o item no SC6 foi deletado e contina ativo na tabela SC9
		//Mauricio - 29/12/2010 (Solicitado por Alex Silva).
		if Select("TSC9") > 0
			DbselectArea("TSC9")
			DbCloseArea()
		endif

		_cQuery4 := ""
		_cQuery4 += "SELECT C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_PRODUTO, C9_DTENTR, C9_ROTEIRO "
		_cQuery4 += " FROM 	"+RETSQLNAME("SC9")+" C9 "
		_cQuery4 += " WHERE C9.C9_FILIAL = '"+cFilant+"' AND (C9_ROTEIRO BETWEEN '"+_cRotIni+"' AND '"+_cRotFin+"') "
		_cQuery4 += " AND C9.C9_DTENTR = '"+DTOS(_dDtEntr)+"' "
		_cQuery4 += " AND C9.D_E_L_E_T_=' ' "
		_cQuery4 += " ORDER BY C9_FILIAL, C9_PEDIDO, C9_ITEM "
		
		TcQuery _cQuery4 NEW ALIAS "TSC9"
		
		DbSelectArea("TSC9")
		Dbgotop()
		While TSC9->(!eof())

			DbSelectArea("SC6")
			DbSetOrder(1)

			if dbseek(TSC9->C9_FILIAL+TSC9->C9_PEDIDO+TSC9->C9_ITEM)
				TSC9->(dbSkip())
			Else
				DbSelectArea("SC9")
				DbSetOrder(1)
				if dbseek(TSC9->C9_FILIAL+TSC9->C9_PEDIDO+TSC9->C9_ITEM)
					RecLock("SC9",.F.)
					dbDelete()
					MsUnlock()
				Endif
				TSC9->(dbSkip())
			Endif

		enddo

		TSC9->(DbCloseArea())

	Endif

	IF SM0->M0_CODFIL <> '03' .and. (ALLTRIM(CEMPANT)=="01"  .or. ALLTRIM(CEMPANT)=="02") // sigoli 21/03/2017

		If lCCSP
			cQrySC9 += " AND C9_ROTEIRO BETWEEN '" + _cRotIni + "' AND '" + _cRotFin + "'"
			cQrySC9 += " AND C9_DTENTR = '" + DTOS(_dDtEntr) + "' "
			cQrySC9 += " AND EXISTS(SELECT C5_NUM FROM "+RetSQlname("SC5")+" "
			cQrySC9 += " WHERE C5_NUM = C9_PEDIDO AND C5_FILIAL = C9_FILIAL AND (C5_X_SQED <> ' ' AND C5_XINT = '3')) "
		Else
			if !(__cUSERID $ _cMVADFAT)
				cQrySC9 += " AND C9_ROTEIRO BETWEEN '" + _cRotIni + "' AND '" + _cRotFin + "'"
				cQrySC9 += " AND C9_DTENTR = '" + DTOS(_dDtEntr) + "' "
			else
				cQrySC9 += " AND C9_ROTEIRO BETWEEN '" + _cRotIni + "' AND '" + _cRotFin + "'"
				cQrySC9 += " AND C9_DTENTR = '" + DTOS(_dDtEntr) + "' "
			endif
		Endif   
	
	//ELSE
	//	cQrySC9 := "' ' = ' '"
	ENDIF

	If !lCCSP
		Close(_oDlg)
	EndIf

Return(cQrySC9)

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

					cNewFiltro += SC5->C5_NUM + "|"

				EndIf

			EndIf

		EndIf

		Work->( dbSkip() )

	EndDo

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

Return cNewFiltro
