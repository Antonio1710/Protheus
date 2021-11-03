#INCLUDE "rwmake.ch"                                         
#INCLUDE "tbiconn.ch" 
#INCLUDE "Topconn.ch"    

/*/{Protheus.doc} User Function nomeFunction
	Grava o numero do projeto no pedido de compra para pedidos gerados a partir da rotina de analise de cotacoes
	@type  Function
	@author Mauricio - HC CONSYS
	@since 06/07/2009
	@version 01
	@history Chamado 055177 - William Costa   - 22/01/2020 - Adicionado campo Observação Interna para gravar no campo de pedido de compra C7_XOBSINT era usado o outro ponto de entrada mas quando o pedido é gerado através de uma cotaçaõ não passava no ponto que foi desenvolvido no começo.
	@history Chamado 2562   - Everson         - 04/11/2020 - Tratamento para gravar número do estudo do projeto.
	@history Chamado 15804  - Leonardo P. Monteiro - 02/09/2021 - Gravação de informações referente ao PC e clientes.
/*/

USER function MT160WF()

	Local _aArea    := GetArea() //salva área atual
	Local lBlqPed	:= .F.
	Local aAprov	:= {}
	Local nTotPed	:= 0
	Local cQry      := ""	
	Local lRet      := .T.
	Local _cPedido	:=	SC7->C7_NUM
	Local aArea		:= GetArea()
	Local SC7AREA	:= SC1->(GetArea())
	Local SC1AREA	:= SC7->(GetArea())
	Local SC8AREA	:= SC8->(GetArea())
	Local _cPedido	:= SC7->C7_NUM
	Local lOkGrv    := .F.
	cOldAreaG	    := GetArea() //Area do programa inicial
	
	if cEmpAnt == "01"
	
		CampoMemo() //chamado 038389 - William Costa 15/12/2017
	
		dbSelectArea("SC8")
		_nCotacao := SC8->C8_NUM
		cOldAreaSC8 := GetArea() //Area inicial do SC8
	
		dbSelectArea("SC7")	
		cOldAreaSC7 := GetArea() //Area inicial do SC7
	 	_nTotal := 0
	 	_cChave := ""
		dbSelectArea("SC1")
		cOldAreaSC1:= GetArea() //Area inicial do SC1	
		dbSetOrder(5)
		If dbSeek(xFilial("SC1") + _nCotacao)
			While xFilial("SC1") + _nCotacao == SC1->C1_FILIAL + SC1->C1_COTACAO
				dbSelectArea("SC7")
				dbSetOrder(1)
				If dbSeek(xFilial("SC7") + SC1->C1_PEDIDO + SC1->C1_ITEMPED)
					If (xFilial("SC7") + SC1->C1_PEDIDO + SC1->C1_ITEMPED <> _cChave)
					
						cFilSC7	:= SC1->C1_FILIAL
						cPedido	:= SC1->C1_PEDIDO
					
						cQry	:= " SELECT ISNULL(SUM(SC7.C7_TOTAL-SC7.C7_VLDESC),0) AS TOTAL
						cQry	+= " FROM " + RetSqlName( "SC7" ) + " SC7(NOLOCK)"
						cQry	+= " WHERE SC7.C7_FILIAL = '" + cFilSC7 + "'"
						cQry	+= " AND SC7.C7_NUM = '" + cPedido + "'"
						cQry	+= " AND SC7.D_E_L_E_T_ = ' '"
	
						If Select( "TMPSC7" ) > 0
							dbSelectArea( "TMPSC7" )
							dbCloseArea()
						EndIf
	
						TCQUERY cQry NEW ALIAS "TMPSC7"
	
						aTamSX3	:= TAMSX3( "C7_TOTAL" )
						TCSETFIELD( "TMPSC7", "TOTAL", aTamSX3[3], aTamSX3[1], aTamSX3[2] )
	
						dbSelectArea( "TMPSC7" )
						dbGoTop()
						nTotPed	:= TMPSC7->TOTAL				
					
						aAprov	:= U_GetAprov( SC7->C7_CC, SC7->C7_ITEMCTA, nTotPed )
						For nLoop1 := 1 To Len( aAprov )
					   		If nTotPed >= aAprov[nLoop1,05]
			   					lBlqPed	:= .T.
		   					EndIf
						Next nLoop1	
	   					_cBL    := IIF(SC7->C7_CONAPRO == 'L', SC7->C7_CONAPRO,IIF(lBlqPed, "B", "L" )) // chamado 033773 WILLIAM COSTA 16/03/2017
	   					
	   					//INICIO CHAMADO 033773 - WILLIAM COSTA
	   					dbSelectArea("ZBE")
						RecLock("ZBE",.T.)
							Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
							Replace ZBE_DATA 	   	WITH dDataBase
							Replace ZBE_HORA 	   	WITH TIME()
							Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
							Replace ZBE_LOG	        WITH ("MT160WF-1 " + " Filal : " + SC7->C7_FILIAL  + " Pedido de Compra : " + SC7->C7_NUM + " CHAVE : " + _cChave + " Campo C7_CONAPRO : "  + SC7->C7_CONAPRO + " Variavel: " + _cBL)  
							Replace ZBE_MODULO	    WITH "COMPRAS"
							Replace ZBE_ROTINA	    WITH "MT160WF" 
						MsUnlock() 
						ZBE->(dbCloseArea())
						
						dbSelectArea( "TMPSC7" )
					    //FINAL CHAMADO 033773 - WILLIAM COSTA 
					
						RecLock("SC7",.F.)
							Replace SC7->C7_PROJETO With SC1->C1_PROJADO             
							Replace SC7->C7_CODPROJ With SC1->C1_CODPROJ             
							REPLACE SC7->C7_CONAPRO	WITH _cBL
							REPLACE SC7->C7_XOBSINT	WITH SC1->C1_XOBSINT
							REPLACE SC7->C7_XITEMST	WITH SC1->C1_XITEMST //Everson, 04/11/2020. Chamado 2562.
						MsUnlock("SC7")    
						
						//INICIO CHAMADO 033773 - WILLIAM COSTA
						dbSelectArea("ZBE")
						RecLock("ZBE",.T.)
							Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
							Replace ZBE_DATA 	   	WITH dDataBase
							Replace ZBE_HORA 	   	WITH TIME()
							Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
							Replace ZBE_LOG	        WITH ("MT160WF-2 " + " Filal : " + SC7->C7_FILIAL  + " Pedido de Compra : " + SC7->C7_NUM + " CHAVE : " + _cChave + " Campo C7_CONAPRO : "  + SC7->C7_CONAPRO + " Variavel: " + _cBL)  
							Replace ZBE_MODULO	    WITH "COMPRAS"
							Replace ZBE_ROTINA	    WITH "MT160WF" 
						MsUnlock()                             
						ZBE->(dbCloseArea())
						
						dbSelectArea( "TMPSC7" )
					    //FINAL CHAMADO 033773 - WILLIAM COSTA 
						
						_cChave := xFilial("SC7") + SC1->C1_PEDIDO + SC1->C1_ITEMPED
					Endif
					
					//-- Gera notificacao - Encerramento de cotacao
    				fGrvInf()
				Endif		
		      dbSelectArea("SC1")
		      dbSkip()   
	      EndDo
	   Endif   
	
		RestArea(cOldAreaSC1)
		RestArea(cOldAreaSC7)
		RestArea(cOldAreaSC8)
	
	endif
	RestArea(cOldAreaG)
	RestArea(_aArea)
Return(Nil)

STATIC FUNCTION CAMPOMEMO()

	// *** INICIO CHA
	IF !EMPTY(SC8->C8_NUM)
		cQuery := " SELECT C8_FILIAL, C8_NUMPED "
		cQuery += " FROM "+RetSQLName("SC8") + " "
		cQuery += " WHERE C8_NUM = '"+SC8->C8_NUM+"' "
		cQuery += " AND C8_FILIAL = '"+xFilial("SC8")+"' "
		cQuery += " AND C8_NUMPED <> 'XXXXXX' "
		cQuery += " AND D_E_L_E_T_ = '' "
		TCQUERY cQuery new alias "qSC8"
	
		_cPedido := qSC8->C8_NUMPED
		qSC8->(dbclosearea())
	ENDIF
	
	//+-----------------------------------------------+
	//|Abre o Alias no indice correto antes do Loop   |
	//| para efeito de performace                     |
	//+-----------------------------------------------+
	dbSelectArea("SC1")
	dbSetOrder(1)
	
	dbSelectArea("SC7")
	dbSetOrder(1)
	If dbseek(xFilial("SC7")+_cPedido,.F.)
		while !eof() .and. _cPedido == SC7->C7_NUM
			//+------------------------------------------------+
			//|Posiciona no Pedido Gerado e grava O memo da SC |
			//+------------------------------------------------+
			dbSelectArea("SC1")
			If dbseek(xFilial("SC7")+SC7->C7_NUMSC+SC7->C7_ITEMSC)
				dbSelectArea("SC7")
				RecLock("SC7",.F.)
				 SC7->C7_XMEMO := ALLTRIM(SC8->C8_XMEMO)+CHR(13)+CHR(10)+"Memo do PC.:"+CHR(13)+CHR(10)
				MsUnlock()
				lOkGrv := .T.
			Else
				dbSelectArea("SC7")
				RecLock("SC7",.F.)
				 SC7->C7_XMEMO := "APLICACAO NAO DIGITADA/LOCALIZADO NO SC1"
				MsUnlock()
				lOkGrv := .T.
			EndIf
			SC7->(dbskip())
		Enddo
	Endif

RETURN(NIL)

Static Function fGrvInf()
    Local cQuery    := ""
    Local cSolic    := ""
    Local cRazao    := ""
    Local cEst      := ""
    Local cMun      := ""
    //Local cNumPC    := SC7->C7_NUM

	cQuery  := " SELECT A2_NOME, A2_EST, A2_MUN "
	cQuery  += " FROM "+ RetSqlName("SA2") +" SA2 "
	cQuery  += " WHERE D_E_L_E_T_='' AND A2_FILIAL='"+ xFilial("SA2") +"' AND A2_COD='"+ SC7->C7_FORNECE +"' AND A2_LOJA='"+ SC7->C7_LOJA +"'; "

	tcQuery cQuery ALIAS "QSA2" NEW

	if QSA2->(!eof())
		cRazao  := QSA2->A2_NOME
		cEst    := QSA2->A2_EST
		cMun    := QSA2->A2_MUN
	endif

	QSA2->(dbCloseArea())

	cSolic := SC1->C1_USER
	cSolic := Alltrim(cSolic)+"-"+AllTrim(UsrFullName(cSolic))

	RecLock("SC7", .f.)

	if !EMPTY(cSolic)
		SC7->C7_XSOLIC := cSolic
	Endif

	if !EMPTY(cRazao)
		SC7->C7_XRAZAO := cRazao
	Endif

	if !EMPTY(cEst)
		SC7->C7_XEST := cEst
	Endif

	if !EMPTY(cMun)
		SC7->C7_XMUN := cMun
	Endif

	SC7->( msUnLock() )

return
