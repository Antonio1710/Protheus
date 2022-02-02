#include "protheus.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMA200DEL ºAutor  ³Fernando Macieira   º Data ³  04/22/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto Entrada na exclusao projeto                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºChamado   ³ 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451     º±±
±±º          ³ || APROVACAO PROJETOS - FWNM - 22/04/2019                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PMA200DEL()

	Local lRet   := .t.
	Local cQuery := ""
	Local cProj  := AF8->AF8_PROJET
	Local cRevis := AF8->AF8_REVISA
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'P.E exclusao projeto')

	
	//Checo se existe movimentações
	// SC7 - Pedidos
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT COUNT(1) TT "
	cQuery += " FROM " + RetSqlName("SC7")
	cQuery += " WHERE C7_FILIAL='"+FWxFilial("SC7")+"' "
	cQuery += " AND C7_PROJETO='"+cProj+"' "
	cQuery += " AND D_E_L_E_T_='' "
	
	tcQuery cQuery New Alias "Work"
	
	Work->( dbGoTop() )
	If Work->TT >= 1
		lRet := .f.
		msgAlert("Projeto não pode ser excluído pois possui movimentações nos pedidos de compras! Veja filtrando C7_PROJETO...")
	EndIf

	// SD1 - NF
	If lRet
		If Select("Work") > 0
			Work->( dbCloseArea() )
		EndIf
	
		cQuery := " SELECT COUNT(1) TT "
		cQuery += " FROM " + RetSqlName("SD1")
		cQuery += " WHERE D1_FILIAL='"+FWxFilial("SD1")+"' "
		cQuery += " AND D1_PROJETO='"+cProj+"' "
		cQuery += " AND D_E_L_E_T_='' "
		
		tcQuery cQuery New Alias "Work"
		
		Work->( dbGoTop() )
		If Work->TT >= 1
			lRet := .f.
			msgAlert("Projeto não pode ser excluído pois possui movimentações nas notas fiscais de entrada! Veja filtrando D1_PROJETO...")
		EndIf
	EndIf
	     
	// SCP - SA
	If lRet
		If Select("Work") > 0
			Work->( dbCloseArea() )
		EndIf
	
		cQuery := " SELECT COUNT(1) TT "
		cQuery += " FROM " + RetSqlName("SCP")
		cQuery += " WHERE CP_FILIAL='"+FWxFilial("SCP")+"' "
		cQuery += " AND CP_CONPRJ='"+cProj+"' "
		cQuery += " AND D_E_L_E_T_='' "
		
		tcQuery cQuery New Alias "Work"
		
		Work->( dbGoTop() )
		If Work->TT >= 1
			lRet := .f.
			msgAlert("Projeto não pode ser excluído pois possui movimentações nas solicitações ao armazém! Veja filtrando CP_CONPRJ...")
		EndIf
	EndIf
	
	// Excluo Central de Aprovacao
	If lRet
		If Select("Work") > 0
			Work->( dbCloseArea() )
		EndIf
	
		cQuery := " SELECT ZC7_PROJET, ZC7_REVPRJ, ZC7_USRAPR, ZC7_NOMAPR "
		cQuery += " FROM " + RetSqlName("ZC7")
		cQuery += " WHERE ZC7_FILIAL='"+FWxFilial("ZC7")+"' "
		cQuery += " AND ZC7_PROJET='"+cProj+"' "
		cQuery += " AND ZC7_REVPRJ='"+cRevis+"' "
		cQuery += " AND D_E_L_E_T_='' "
		
		tcQuery cQuery New Alias "Work"
		
		Work->( dbGoTop() )
		Do While Work->( !EOF() )

			aDadWF := {}                                     
	
			cMail        := UsrRetMail(Posicione("AF8", 1, xFilial("AF8")+cProj,"AF8_XUSER"))
			cUsrSol      := AllTrim(AF8->AF8_XUSER)
			cNomSol      := AllTrim(UsrRetName(AF8->AF8_XUSER))
			c_ZC7_DTAPR  := msDate()
			c_ZC7_HRAPR  := Time()
	
			aAdd( aDadWF, { Work->ZC7_PROJET, Work->ZC7_REVPRJ, cUsrSol, cNomSol, c_ZC7_DTAPR, c_ZC7_HRAPR, "", cMail, AF8->AF8_DESCRI, Work->ZC7_USRAPR } )

			ZC7->( dbSetOrder(3) ) //ZC7_FILIAL+ZC7_PROJET+ZC7_REVPRJ
			If ZC7->( dbSeek( FWxFilial("ZC7")+cProj+cRevis ) )
				RecLock("ZC7", .f.)
					ZC7->( dbDelete() )
				ZC7->( msUnLock() )
			EndIf
			
			u_ADPRJ004P(aDadWF, "EXCLUSAO")

			Work->( dbSkip() )

		EndDo
		
	
		// Excluo cronograma financeiro
		// ZCD - Cabecalho
		If Select("Work") > 0
			Work->( dbCloseArea() )
		EndIf
	
		cQuery := " SELECT ZCD_PROJET, ZCD_REVISA "
		cQuery += " FROM " + RetSqlName("ZCD")
		cQuery += " WHERE ZCD_FILIAL='"+FWxFilial("ZCD")+"' "
		cQuery += " AND ZCD_PROJET='"+cProj+"' "
		cQuery += " AND ZCD_REVISA='"+cRevis+"' "
		cQuery += " AND D_E_L_E_T_='' "
		
		tcQuery cQuery New Alias "Work"
		
		Work->( dbGoTop() )
		Do While Work->( !EOF() )
	
			ZCD->( dbSetOrder(1) ) //ZCD_FILIAL+ZCD_PROJET+ZCD_REVISA
			If ZCD->( dbSeek( FWxFilial("ZCD")+cProj+cRevis ) )
				RecLock("ZCD", .f.)
					ZCD->( dbDelete() )
				ZCD->( msUnLock() )
			EndIf
			
			Work->( dbSkip() )
			
		EndDo
	
		// ZCE - Itens
		If Select("Work") > 0
			Work->( dbCloseArea() )
		EndIf
	
		cQuery := " SELECT ZCE_PROJET, ZCE_REVISA "
		cQuery += " FROM " + RetSqlName("ZCE")
		cQuery += " WHERE ZCE_FILIAL='"+FWxFilial("ZCE")+"' "
		cQuery += " AND ZCE_PROJET='"+cProj+"' "
		cQuery += " AND ZCE_REVISA='"+cRevis+"' "
		cQuery += " AND D_E_L_E_T_='' "
		
		tcQuery cQuery New Alias "Work"
		
		Work->( dbGoTop() )
		Do While Work->( !EOF() )
	
			ZCE->( dbSetOrder(2) ) //ZCE_FILIAL+ZCE_PROJET+ZCE_REVISA
			If ZCE->( dbSeek( FWxFilial("ZCE")+cProj+cRevis ) )
				RecLock("ZCE", .f.)
					ZCE->( dbDelete() )
				ZCE->( msUnLock() )
			EndIf
			
			Work->( dbSkip() )
			
		EndDo

	EndIf
	
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

Return lRet