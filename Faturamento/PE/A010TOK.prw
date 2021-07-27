#include 'rwmake.ch'
#include 'protheus.ch'
#Include "Topconn.ch"
/*/{Protheus.doc} User Function A010TOK
	Validacao do cadastro de produto para quando for produtos
	tipo PA e almoxarifado 10 nao salvar sem o campo de CODIGO
	de barras para nao problema no EDI chamado n:025338
	SIGAFAT.
	@type  Function
	@author WILLIAM COSTA
	@since 18/12/2015
	@version 01
	@history 049070 - Fernando Sigoli 13/05/2019 - Validação
			 de obrigatoriedade de campos B1_PESO,B1_PESBRU,B1_XALTUR,
			 B1_XALTLAS, B1_PRVALID.
	@history Chamado: ³049875 - Fernando Sigoli 21/06/2019 - Validação
			 Alterado os retornos de Alert por ShowHelpDlg, devido
			 a função alert nao retornar quando chamado por execauto
	@history Chamado: ³049973 - William Costa 21/06/2019 - Validação
		     Adicionado regra para não deixar salvar o produto se não
             tiver a segunda unidade de medida preenchida se for P.A e o
		     Local igual 10.
	@history Chamado:  ³049875 - Fernando Sigoli 24/06/2019
			  Tratamento para passar no P.E quando a rotina diferente
			  de exportação.
	@history Chamado T.I. - Everson - 29/11/2019. Tratamento para enviar produto para aprovação, mediante consulta o Edata.
	@history Chamado T.I. - Everson - 11/12/2019. Chamado 053902, adicionado tratamento no script sql.
	@history Chamado 17407 - Leonardo P. Monteiro - 26/07/2021. - Adição de validação na confirmação do produto para checar se existe outro código EAN vinculado a outro produto.
	/*/
User Function A010TOK()  

	Local lExecuta 	:= .T. // Validações do usuário para inclusão ou alteração do produto 
	Local lAtzEdt	:= GetMv("MV_#ATLEDT",,.F.)  
	
	//Everson - 29/11/2019 - Chamado T.I.
	If Type("aInClApv") == "U"
		Public aInClApv := {}

	EndIf
    
	If !IsInCallStack("EECAC120") //049875 - Fernando Sigoli 24/06/2019 
		
		IF ALLTRIM(M->B1_TIPO)    == 'PA' .AND. ;
		   ALLTRIM(M->B1_LOCPAD)  == '10' .AND. ;
		   ALLTRIM(M->B1_MSBLQL)  == '2'  .AND. ;
		   (ALLTRIM(M->B1_CODBAR) == ''   .OR. ; 
		   LEN(M->B1_CODBAR)      < 13)
		   
		   //Chamado: 049875 - Fernando Sigoli 21/06/2019     
		   ShowHelpDlg("A010TOK-01", {"Obrigatório ter um código de barras para o produto: " + ALLTRIM(M->B1_COD),;
			                          "devido ser um produto acabado no local padrão 10. "},5,;
			                         {"Favor entrar em contato com o fiscal ou comercial"},5)   
			
			lExecuta := .F.   
			
		ENDIF

		IF ALLTRIM(M->B1_TIPO)    == 'PA' .AND. ;
		   ALLTRIM(M->B1_LOCPAD)  == '10' .AND. ;
		   ALLTRIM(M->B1_MSBLQL)  == '2'  .AND. ;
		   ALLTRIM(M->B1_TS)      == '' 
		    
		   //Chamado: 049875 - Fernando Sigoli 21/06/2019      
		   ShowHelpDlg("A010TOK-02", {"Obrigatório ter uma TES para o produto: " + ALLTRIM(M->B1_COD),;
			                          "devido ser um produto acabado no local padrão 10. "},5,;
			                         {"Favor entrar em contato com o fiscal ou comercial"},5)    
			
			lExecuta := .F.   
			
		ENDIF
		
		//Inicio: Chamado: 049070 - Fernando Sigoli 13/05/2019 - Validação de obrigatoriedade de campos
		IF ALLTRIM(M->B1_TIPO) == 'PA' .AND. ;
		   ALLTRIM(M->B1_LOCPAD)   == '10' .AND. ;
	       ALLTRIM(M->B1_MSBLQL)   == '2'  .AND. ;
	       (M->B1_XALTUR = 0 .OR. M->B1_XALTLAS = 0 .OR. M->B1_PRVALID = 0 ) 
	
		   //Chamado: 049875 - Fernando Sigoli 21/06/2019                                                                
		   ShowHelpDlg("A010TOK-03", {"Obrigatório informar [AlturaPalete]",;
			                          "[Lastro Palete] e [Prazo Validade] para o produto: "+ ALLTRIM(M->B1_COD),;
			                          "devido ser um produto acabado no local padrão 10. "},5,;
			                         {"Favor entrar em contato com o fiscal ou comercial"},5)    
	
			
			lExecuta := .F.   
			
		ENDIF
		//Fim: Chamado: 049070 - Fernando Sigoli 13/05/2019 - Validação de obrigatoriedade de campos
		
		// INICIO WILLIAM COSTA 21/06/2019 CHAMADO 049973 || OS 051277 || FISCAL || VALERIA || 8389 || PEDIDO X FATURAMENTO
		
		IF  M->B1_CONV             > 1  .AND. ;
		    ALLTRIM(M->B1_SEGUM)  == ''
		    
		    ShowHelpDlg("A010TOK-04", {"Obrigatório informar [Segunda Unidade de Medida], para o produto: " + ALLTRIM(M->B1_COD),;
			                           "devido a o produto estar com fator de conversão maior que 1. "},5,;
			                          {"Favor entrar em contato com o fiscal ou comercial"},5)   
		    
			lExecuta := .F.
		    
		ENDIF
		
		IF  M->B1_CONV             = 0  .AND. ;
		    ALLTRIM(M->B1_SEGUM)  <> ''
		    
		    ShowHelpDlg("A010TOK-05", {"Obrigatório informar [Fator de Conversão], para o produto: " + ALLTRIM(M->B1_COD),;
			                           "devido o produto estar com segunda unidade de medida preenchida. "},5,;
			                          {"Favor entrar em contato com o fiscal ou comercial"},5)   
		    
			lExecuta := .F.
		    
		ENDIF

		IF ALLTRIM(M->B1_MSBLQL)  == '2'  .AND. ALLTRIM(M->B1_CODBAR)  != ''
		    
			//@history Chamado 17407 - Leonardo P. Monteiro - 26/07/2021. - Adição de validação na confirmação do produto para checar se existe outro código EAN vinculado a outro produto.
		    IF !fDupEAN(M->B1_COD, M->B1_CODBAR)
				
				//Chamado: 049875 - Fernando Sigoli 21/06/2019     
				ShowHelpDlg("A010TOK-06", {"O código de barras informado: " + ALLTRIM(M->B1_CODBAR),;
											" está vinculado a outros produtos ativos. "},5,;
											{"Favor entrar em contato com o fiscal ou comercial"},5)   
					
					lExecuta := .F.   
			ENDIF
		ENDIF
		
		// FINAL WILLIAM COSTA 21/06/2019 CHAMADO 049973 || OS 051277 || FISCAL || VALERIA || 8389 || PEDIDO X FATURAMENTO
	EndIf

	//Everson - 29/11/2019. Chamado T.I.
	If lExecuta .And. lAtzEdt

		//
		If Alltrim(M->B1_TIPO) == "PA"
			lExecuta := chkEdata()

		EndIf

	EndIf
	//
	
Return (lExecuta)

/* fDupEAN - Verifica se o código EAN informado está vinculado a outro produto. */
Static Function fDupEAN(cCod, cCodEAN)
	Local lRet 		:= .T.
	Local cQuery 	:= ""
	Local aArea		:= GetArea()

	cQuery := " SELECT count(*) CONTADOR "
	cQuery += " FROM "+ RetSqlName("SB1") +" "
	cQuery += " WHERE D_E_L_E_T_='' AND B1_COD != '"+ Alltrim(cCod) +"' AND B1_MSBLQL !='1' AND B1_CODBAR = '"+ AllTrim(cCodEAN) +"' "

	tcquery cQuery ALIAS "QSB1" NEW

	IF QSB1->(!EOF())
		IF QSB1->CONTADOR > 0
			lRet := .F.
		ENDIF
	ENDIF

	QSB1->(DbCloseArea())

	RestArea(aArea)
return lRet

/*/{Protheus.doc} chkEdata
	Checa se o produto possui cadastro no Edata.
	@type  Static Function
	@author Everson
	@since 29/11/2019
	@version 01
	/*/
Static Function chkEdata()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:=  GetArea()
	Local lRet 		:= .T.
	Local cCodPrd	:= ""
	Local lAltCmp	:= .F.
	Local cOp 		:= ""
	Local cQuery	:= ""

	//
	Conout( DToC(Date()) + " " + Time() + " A0110TOK - chkEdata - ALTERA - " + cValToChar(ALTERA) )

	//
	Conout( DToC(Date()) + " " + Time() + " A0110TOK - chkEdata - INCLUI - " + cValToChar(INCLUI) )

	//Verifica o campo que foi alterado.
	If ALTERA

		//
		Conout( DToC(Date()) + " " + Time() + " A0110TOK - chkEdata - ALTERA - (M->B1_DESC <> SB1->B1_DESC) " + cValToChar(M->B1_DESC <> SB1->B1_DESC) )

		//
		Conout( DToC(Date()) + " " + Time() + " A0110TOK - chkEdata - ALTERA - (M->B1_DESCOMP <> SB1->B1_DESCOMP) " + cValToChar(M->B1_DESCOMP <> SB1->B1_DESCOMP) )

		//
		If (M->B1_MSBLQL <> SB1->B1_MSBLQL)
			Help(Nil, Nil, "Função chkEdata(A010TOK)", Nil, "Para desativar/ativar cadastro de produto acabado utilize a rotina 'Ativar/Desativar' no menu." + TCSQLError(), 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
			lRet := .F.
			RestArea(aArea)
			Return lRet

		ElseIf (M->B1_DESC <> SB1->B1_DESC) .Or. (M->B1_DESCOMP <> SB1->B1_DESCOMP)

			//
			lAltCmp := .T.
			cOp := "ALTERAÇÃO"
			cCodPrd	:= Alltrim(cValToChar(SB1->B1_COD))

		Endif

	ElseIf INCLUI

		//
		lAltCmp := .T.
		cOp := "INCLUSÃO"
		cCodPrd	:= Alltrim(cValToChar(M->B1_COD))

	Else
		RestArea(aArea)
		Return lRet

	EndIf

	//
	Conout( DToC(Date()) + " " + Time() +  " A010TOK - chkEdata - " + cValToChar(lAltCmp) )

	//
	If ! lAltCmp
		RestArea(aArea)
		Return lRet

	EndIf

	//Verifica se o produto alterado possui cadastro no Edata.
	cQuery := U_A10_02(cCodPrd)

	//
	If Select("D_B1APROV") > 0
		D_B1APROV->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_B1APROV"
	DbSelectArea("D_B1APROV")
	D_B1APROV->(DbGoTop())
	
	//
	If D_B1APROV->(Eof())
		Conout( DToC(Date()) + " " + Time() +  " A010TOK - chkEdata - produto não consta no Edata " + cValToChar(cCodPrd) )
		D_B1APROV->(DbCloseArea())
		RestArea(aArea)
		Return lRet

	EndIf

	//Se o produto alterado possuir cadastro no Edata, ocorre o bloqueio do cadastro no Edata no Protheus e submete e produto para aprovação.
	lRet := U_A10_01(cCodPrd,"N",cOp) //N= Bloqueado, S=Liberado
	If lRet

		//
		If ALTERA .Or. INCLUI

			//
			Aadd(aInClApv,{__cUserId,M->B1_COD})

		EndIf

		//
		Conout( DToC(Date()) + " " + Time() +  " A010TOK - chkEdata - cCodPrd - M->B1_XAPROV - " + cValToChar(cCodPrd) + "/" + cValToChar(M->B1_XAPROV ) )

	EndIf

	//
	D_B1APROV->(DbCloseArea())

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} A10_02
	Script sql, que consulta produto no Edata.
	@type  Static Function
	@author Everson
	@since 29/11/2019
	@version 01
	/*/
User Function A10_02(cCodPrd)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:=  GetArea()
	Local cQuery 	:= ""

	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " FONTE.PRODUTO, FONTE.ACAD_MATERIAL, FONTE.BCAD_MATERIAL_EMBALAGEM, FONTE.CCAD_MATERIAIS_EMBALAGEM " //Everson - 11/12/2019 - Chamado 053902.
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT   " 
	cQuery += " ISNULL(ID_PRODDEFIMATEEMBA,'') AS PRODUTO,   " //Everson - 11/12/2019 - Chamado 053902.
	cQuery += " ISNULL(NM_MATERIAL,'') AS ACAD_MATERIAL,  " //Everson - 11/12/2019 - Chamado 053902.
	cQuery += " ISNULL(NM_PRODDEFIMATEEMBA,'') AS BCAD_MATERIAL_EMBALAGEM,  " //Everson - 11/12/2019 - Chamado 053902.
	cQuery += " ISNULL(GN_DESCETIQLINH1DEFIMATEEMBA,'')  +' '+   " //Everson - 11/12/2019 - Chamado 053902.
	cQuery += " ISNULL(GN_DESCETIQLINH2DEFIMATEEMBA,'')  +' '+   " //Everson - 11/12/2019 - Chamado 053902.
	cQuery += " ISNULL(GN_DESCETIQLINH3DEFIMATEEMBA,'') AS CCAD_MATERIAIS_EMBALAGEM   " //Everson - 11/12/2019 - Chamado 053902.
	cQuery += " FROM   " 
	cQuery += " [LNKMIMS].[SMART].[dbo].[MATERIAL_EMBALAGEM_DEFINICAO] MED   " 
	cQuery += " JOIN   " 
	cQuery += " [LNKMIMS].[SMART].[dbo].[MATERIAL_EMBALAGEM_FILIAL] MEF  " 
	cQuery += " ON MED.ID_DEFIMATEEMBA = MEF.ID_DEFIMATEEMBA   " 
	cQuery += " JOIN   " 
	cQuery += " [LNKMIMS].[SMART].[dbo].[MATERIAL] MA  " 
	cQuery += " ON MA.ID_MATERIAL = MED.ID_MATERIAL   " 
	cQuery += " WHERE  MEF.FILIAL = 2   " 
	cQuery += " AND MED.IE_DEFIMATEEMBA ='" + cValToChar(cCodPrd) + "'  " 
	cQuery += " ) AS FONTE " 	

	//
	Conout( DToC(Date()) + " " + Time() + " A0110TOK - A10_02 - cQuery - " + cValToChar(cQuery) )

	//
	RestArea(aArea)

Return cQuery 
/*/{Protheus.doc} A10_01
	Inativa cadastro de produto no Edata.
	@type  User Function
	@author user
	@since 29/11/2019
	@version 01
	/*/
User Function A10_01(cCodPrd,cOper,cOp)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:=  GetArea()
	Local lRet 		:= .T.
	Local cExec 	:= ""
	Local aResult 	:= Nil

	Default cOp		:= ""

	//
	Conout( DToC(Date()) + " " + Time() + " A0110TOK - A10_01 - cCodPrd/cOper - " + cCodPrd + "/" + cOper)

	cExec := "EXEC [LNKMIMS].[SMART].[dbo].[ADPRODUTO] '"+cCodPrd+"','"+cOper+"';"

	Conout( DToC(Date()) + " " + Time() + " A010TOK - A10_01 - cExec " + cExec)

	TcSQLExec(cExec) 

	//
	Conout( DToC(Date()) + " " + Time() + " A0110TOK - A10_01 - TCSqlExec - OK " + cCodPrd)

	//
	DbSelectArea("ZBE")
		RecLock("ZBE",.T.)
		Replace ZBE_FILIAL 	   	With FWxFilial("ZBE")
		Replace ZBE_DATA 	   	With Date()
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With cOp + " PRODUTO " + cCodPrd
		Replace ZBE_MODULO	    With "CONTROLADORIA"
		Replace ZBE_ROTINA	    With "A010TOK"
		Replace ZBE_PARAME	    With cCodPrd
	ZBE->(MsUnlock())

	//
	RestArea(aArea)

Return lRet
