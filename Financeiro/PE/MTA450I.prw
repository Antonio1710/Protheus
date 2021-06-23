#include "rwmake.ch"
#include "protheus.ch"    
#include "topconn.ch"                    
#include "AP5MAIL.CH"

/*/{Protheus.doc} User Function MT450I
	APOS ATUALIZACAO DA LIBERACAO DO PEDIDO. Executado apos atualizacao da liberacao de pedido. PE para gerar workflow apos liberação manual de credito para os pedidos de venda.
	@type  Function
	@author Ana Helena
	@since 11/08/2013
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 059415 - FWNM - 11/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO
	@history chamado TI     - FWNM - 14/08/2020 - Desativação devido impactos de block no SF
/*/
User Function MTA450I()

	Local _cStAntPed := ""
	Local nOpc	     := PARAMIXB[1]
	Local lAtuSAG    := SuperGetMv( "MV_#ATUSAG" , .F. , .F. ,  )

	If Alltrim(cEmpAnt) == "01"

		_cDtEntr  := DTOC(SC5->C5_DTENTR)
		_cCliente := SC5->C5_CLIENTE
		_cNomeCli := ""
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbGoTop()
		If dbSeek(xFilial("SA1")+Alltrim(_cCliente))
			_cNomeCli := SA1->A1_NOME
		Endif

		DbSelectArea("SA3")
		DbSetOrder(1)
		DbSeek(Xfilial("SA3")+SC5->C5_VEND1)
		_eMailVend := SA3->A3_EMAIL

		DbSelectArea("SZR")
		DbSetOrder(1)
		DbSeek(Xfilial("SZR")+SA3->A3_CODSUP)
		_eMailSup := alltrim(UsrRetMail(SZR->ZR_USER))

		If Alltrim(SC5->C5_VEND1) $ "000001/000002/000003/000004/000005/000092"
			_cRotina := "VEN"
		Else
			_cRotina := "FIN"	
		Endif	       

		_cStAntPed := SC5->C5_FLAGFIN
		If AlLtrim(_cStAntPed) <> "L"
			U_SendMlLC(SC5->C5_NUM,"LIB",_cRotina,_eMailVend,_eMailSup)
		Endif	

		RecLock("SC5",.F.)
			SC5->C5_FLAGFIN := "L"
		SC5->(MsUnLock())

		If Alltrim(FunName()) == "MATA450"

			RecLock("SC5",.F.) 
				SC5->C5_XPREAPR := "L"   //Mauricio 22/09/2017 - Chamado 37173
				//SC5->C5_XWSPAGO := "S"   // @history chamado 059415 - FWNM - 11/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO
			SC5->(MsUnLock())

			// @history chamado TI     - FWNM - 14/08/2020 - Desativação devido impactos de block no SF
			/*
			// @history chamado 059415 - FWNM - 11/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO
			RecLock("ZBE", .T.)
				ZBE_FILIAL := FWxFilial("ZBE")
				ZBE_DATA   := dDataBase
				ZBE_HORA   := TIME()
				ZBE_USUARI := UPPER(Alltrim(cUserName))
				ZBE_LOG    := "PEDIDO " + SC5->C5_NUM + " C5_XWSPAGO: " + SC5->C5_XWSPAGO + " PREENCHIDO MANUALMENTE PELO USUARIO"
				ZBE_MODULO := "SC5"
				ZBE_ROTINA := "ADFIN018P"
			ZBE->( msUnlock() )
			//
			*/

		Endif   

		//Mauricio - 15/02/17 - log de registro
		_cRotina := "MTA450I LIB PADRAO"
		IF IsInCallStack('U_ADFIN006P')
			_cRotina := "MTA450I ADFIN006P"
		Elseif IsInCallStack('U_ADFIN018P')
			_cRotina := "MTA450I ADFIN018P"
		Else 
			_cRotina := "MTA450I MATA450"
		Endif

		dbSelectArea("ZBE")
		RecLock("ZBE",.T.)
			Replace ZBE_FILIAL WITH xFilial("ZBE")
			Replace ZBE_DATA   WITH dDataBase
			Replace ZBE_HORA   WITH TIME()
			Replace ZBE_USUARI WITH UPPER(Alltrim(cUserName))
			Replace ZBE_LOG    WITH "PEDIDO " + SC5->C5_NUM + " C5_FLAGFIN: "+SC5->C5_FLAGFIN + " C5_XPREAPR: "+SC5->C5_XPREAPR
			Replace ZBE_MODULO WITH "SC5"
			Replace ZBE_ROTINA WITH _cRotina
		ZBE->(MsUnlock())
		
		// Ricardo Lima - 07/03/18 - Atualiza SalesForce com status de aprovação ou reprovação de credito
		If Findfunction("U_ADVEN050P") .And. nOpc == 4 .And. cEmpAnt == "01" .And. cFilAnt = "02"
	    	//if empty(SC9->C9_BLCRED)
	    	If Upper(Alltrim(cValToChar(GetMv("MV_#SFATUF")))) == "S"
		    	U_ADVEN050P(,.F.,.T., " AND C5_NUM IN ('" + SC9->C9_PEDIDO + "') AND C5_XPEDSAL <> '' " ,.T.)
		    	
		    EndIf				
		EndIf	
		
		// *** INICIO CHAMADO WILLIAM 043390 || SUPRIMENTOS || LUIS || 3525 || APROV X SAG *** //
		IF cEmpAnt == "01"
		
			IF ALLTRIM(SC5->C5_PEDSAG) <> '' .AND. nOpc == 4
			
				IF lAtuSAG
				
					cUpdate := " UPDATE PED SET STATUS_PRC= CASE WHEN SC5.D_E_L_E_T_ = '' THEN 'S' ELSE 'N' END, STATUS_INT='' " 
					cUpdate += " FROM SGPED010 PED WITH(NOLOCK) " 
					cUpdate += " INNER JOIN " + RetSqlName("SC5") + " SC5 WITH(NOLOCK) ON PED.C5_FILIAL = '" + SC5->C5_FILIAL + "' COLLATE Latin1_General_CI_AS AND PED.C5_NUM = '" + SC5->C5_PEDSAG + "' COLLATE Latin1_General_CI_AS  AND PED.C5_CLIENTE = '" + SC5->C5_CLIENTE  + "' COLLATE Latin1_General_CI_AS  AND PED.C5_LOJACLI = '" + SC5->C5_LOJACLI + "' COLLATE Latin1_General_CI_AS  AND PED.TABEGENE = '" + SC5->C5_TABEGEN + "' COLLATE Latin1_General_CI_AS  " 
					cUpdate += " INNER JOIN " + RetSqlName("SC6") + " SC6 WITH(NOLOCK) ON SC5.C5_FILIAL = SC6.C6_FILIAL AND SC5.C5_NUM = SC6.C6_NUM AND SC5.C5_CLIENTE = C6_CLI AND SC5.C5_LOJACLI = C6_LOJA  AND PED.CODIGENE = SC6.C6_XCODIGE " 
					cUpdate += " INNER JOIN " + RetSqlName("SC9") + " SC9 WITH(NOLOCK) ON SC6.C6_FILIAL = C9_FILIAL AND SC6.C6_NUM = C9_PEDIDO AND SC6.C6_CLI = C9_CLIENTE AND SC6.C6_LOJA = C9_LOJA AND SC6.C6_ITEM = C9_ITEM AND SC6.C6_PRODUTO = C9_PRODUTO AND SC9.D_E_L_E_T_ <> '*' " 
					cUpdate += " WHERE PED.C5_FILIAL = '" +SC5->C5_FILIAL+ "' AND PED.C5_NUM = '" +SC5->C5_PEDSAG+ "' AND PED.STATUS_PRC='A' AND SC5.C5_XLIBSAG = '1' AND SC5.C5_PEDSAG <> '' AND SC6.C6_XCODIGE <> ''  " 
				
					IF TcSqlExec(cUpdate) < 0
						ConOut( "MTA450I - Não foi possível atualizar os status de liberação dos movimentos 'Saída por venda'" + "Num Filial: " + SC5->C5_FILIAL + " Num Pedido: " + SC5->C5_NUM + "||" + SC5->C5_PEDSAG)
					ELSE	
						ConOut( "MTA450I - Atualizado os status de liberação dos movimentos 'Saída por venda'" + "Num Filial: " + SC5->C5_FILIAL + " Num Pedido: " + SC5->C5_NUM + "||" + SC5->C5_PEDSAG)
					ENDIF
				ENDIF 
			ENDIF
		ENDIF
		// *** FINAL CHAMADO WILLIAM 043390 || SUPRIMENTOS || LUIS || 3525 || APROV X SAG *** //  
	    
	Endif

Return() 
