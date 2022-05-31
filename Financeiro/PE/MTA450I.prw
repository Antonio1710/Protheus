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
	@history Ticket 69574   - Abel Babini       - 21/03/2022 - Projeto FAI
	@history Ticket 1562    - Abel Babini       - 30/05/2022 - RELATORIO DE PEDIDOS LIBERADOS
/*/
User Function MTA450I()

	Local _cStAntPed := ""
	Local nOpc	     := PARAMIXB[1]
	Local lAtuSAG    := SuperGetMv( "MV_#ATUSAG" , .F. , .F. ,  )
	Local cEmpSF	:= GetMv("MV_#SFEMP",,"01|") 		//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
	Local cFilSF	:= GetMv("MV_#SFFIL",,"02|0B|") 	//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI

	Local _cRisco 		:= '' 	//Ticket 1562    - Abel Babini       - 30/05/2022 - RELATORIO DE PEDIDOS LIBERADOS
	Local cPerfPgt 		:= ''	//Ticket 1562    - Abel Babini       - 30/05/2022 - RELATORIO DE PEDIDOS LIBERADOS
	Local nMedAtr			:= 0		//Ticket 1562    - Abel Babini       - 30/05/2022 - RELATORIO DE PEDIDOS LIBERADOS
	Local aPerPgt			:= {}		//Ticket 1562    - Abel Babini       - 30/05/2022 - RELATORIO DE PEDIDOS LIBERADOS
	Local _cTpCli 		:= ''		//Ticket 1562    - Abel Babini       - 30/05/2022 - RELATORIO DE PEDIDOS LIBERADOS
	Local _cCodRed		:= ''		//Ticket 1562    - Abel Babini       - 30/05/2022 - RELATORIO DE PEDIDOS LIBERADOS
	Local cQryRede 		:= GetNextAlias()	//Ticket 1562    - Abel Babini       - 30/05/2022 - RELATORIO DE PEDIDOS LIBERADOS
	Local cQryPFtr 		:= ''
	Local cQryVAbr 		:= ''
	Local _nTotSdRede := 0
	Local _nTotVenci  := 0
	Local _nTotAVenc  := 0
	Local _nPedFut 		:= 0
	Local _nTotRede 	:= 0

	If Alltrim(cEmpAnt) == "01"

		_cDtEntr  := DTOC(SC5->C5_DTENTR)
		_cCliente := SC5->C5_CLIENTE
		_cNomeCli := ""
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbGoTop()
		If dbSeek(xFilial("SA1")+Alltrim(_cCliente))
			_cNomeCli := SA1->A1_NOME
			//Ticket 1562    - Abel Babini       - 30/05/2022 - RELATORIO DE PEDIDOS LIBERADOS
			_cRisco := SA1->A1_XRISCO
			IF !Empty(Alltrim(SA1->A1_CODRED))
				_cTpCli := 'REDE'
				_cCodRed := Alltrim(SA1->A1_CODRED)
			ELSE
				_cTpCli := 'VAREJO'
			ENDIF
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

			//INICIO Ticket 1562    - Abel Babini       - 30/05/2022 - RELATORIO DE PEDIDOS LIBERADOS
			cPerfPgt := ''
			nMedAtr	:= 0
			aPerPgt	:= {}

			//Carrega Perfil de Pagamento
			aPerPgt 	:= StaticCall(ADFIN103P,fMedPgt,SC5->C5_CLIENTE, SC5->C5_LOJACLI)
			IF ValType(aPerPgt) = 'A' 
				cPerfPgt	:= IIF(Empty(Alltrim(aPerPgt[2])) .OR. ValType(aPerPgt) != 'A','NDA', aPerPgt[2])
				nMedAtr		:= IIF(ValType(aPerPgt) != 'A',0, aPerPgt[1])
			ELSE
				cPerfPgt	:= 'NDA'
			ENDIF

			IF _cTpCli == 'REDE' //REDE
				//Informações da Rede
				
				BeginSQL alias cQryRede
					column ZF_DTACUMU as Date
					SELECT
						ZF_REDE,
						ZF_VLACUMU,
						ZF_DTACUMU,
						ZF_LCREDE,
						ZF_SLDREDE,
						ZF_VENCIDO,
						ZF_AVENCER
					FROM %TABLE:SZF% SZF (NOLOCK)
					WHERE 
						SZF.%notDel% AND
						SZF.ZF_REDE = %Exp:_cCodRed%
					ORDER BY ZF_REDE
				EndSQL
				While !(cQryRede)->(EOf())
					_nTotRede   += (cQryRede)->ZF_LCREDE
					_nTotSdRede += (cQryRede)->ZF_SLDREDE
					_nTotVenci  += (cQryRede)->ZF_VENCIDO
					_nTotAVenc  += (cQryRede)->ZF_AVENCER

					(cQryRede)->(dbskip())
				Enddo
				(cQryRede)->(dbCloseArea())

				//Pedidos com data de entrega futura
				cQryPFtr := GetNextAlias()
				BeginSQL alias cQryPFtr
					SELECT 
						SUM((C6_QTDVEN - C6_QTDENT) * C6_PRCVEN) AS TOTAL
					FROM %TABLE:SC6% SC6 (NOLOCK)
					INNER JOIN %TABLE:SA1% SA1 (NOLOCK) ON
						A1_FILIAL = %xFilial:SA1%
						AND A1_COD = C6_CLI
						AND A1_LOJA = C6_LOJA
						AND SA1.%notDel%
					LEFT JOIN %TABLE:SZF% SZF (NOLOCK) ON
						ZF_FILIAL = %xFilial:SZF%
						AND ZF_CGCMAT = SUBSTRING(A1_CGC,1,8)
						AND SZF.%notDel%
					WHERE C6_FILIAL = %xFilial:SC6%
						AND SC6.C6_ENTREG > %Exp:DTOS(SC5->C5_DTENTR)%
						AND SA1.A1_CODRED = %Exp:_cCodRed%
						AND (C6_QTDVEN - C6_QTDENT) > 0
						AND SC6.%notDel%
				EndSQL
				_nPedFut := (cQryPFtr)->TOTAL
				(cQryPFtr)->(dbCloseArea())

			ELSE //VAREJO
				//Valores em aberto , incluindo os valores em atraso
				cQryVAbr := GetNextAlias()
				BeginSQL alias cQryVAbr
					SELECT 
						SUM(E1_SALDO) AS E1_SALDO
					FROM %TABLE:SE1% SE1 (NOLOCK)
					WHERE SE1.E1_CLIENTE = %Exp:SC5->C5_CLIENTE%
						AND SE1.E1_LOJA = %Exp:SC5->C5_LOJACLI%
						AND SE1.E1_SALDO > 0 
						AND SE1.E1_TIPO NOT IN ('NCC','RA') 
						AND SE1.E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') 
						AND SE1.%notDel% 
					GROUP BY E1_CLIENTE,E1_LOJA
					ORDER BY E1_CLIENTE,E1_LOJA
				EndSQL

				_nTotSdRede := (cQryVAbr)->E1_SALDO
				(cQryVAbr)->(dbCloseArea())

				//Valores em atraso
				cQryVAtr := GetNextAlias()
				BeginSQL alias cQryVAtr
					SELECT 
						SUM(E1_SALDO) AS E1_SALDO
					FROM %TABLE:SE1% SE1 (NOLOCK)
					WHERE SE1.E1_CLIENTE = %Exp:SC5->C5_CLIENTE%
						AND SE1.E1_LOJA = %Exp:SC5->C5_LOJACLI%
						AND SE1.E1_SALDO > 0 
						AND (E1_VENCREA < %Exp:msDate()%) 
						AND SE1.E1_TIPO NOT IN ('NCC','RA') 
						AND SE1.E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') 
						AND SE1.%notDel% 
					GROUP BY E1_CLIENTE,E1_LOJA
					ORDER BY E1_CLIENTE,E1_LOJA
				EndSQL

				_nTotVenci := (cQryVAtr)->E1_SALDO
				(cQryVAtr)->(dbCloseArea())

				_nTotAvenc := _nTotSdRede - _nTotVenci //Ticket 8      - Abel Babini - 08/03/2022 - Ajustes na tela e inclusão de novas funcionalidades
				//Pedidos colocados com data de entrega posterior ao período selecionado
				cQryPFtr := GetNextAlias()
				BeginSQL alias cQryPFtr
					SELECT 
						SUM((C6_QTDVEN - C6_QTDENT) * C6_PRCVEN) AS TOTAL
					FROM %TABLE:SC6% SC6 (NOLOCK)
					WHERE 
						SC6.C6_FILIAL = %xFilial:SC6%
						AND SC6.C6_CLI = %Exp:(cTbClie)->CODIGO%
						AND SC6.C6_LOJA = %Exp:(cTbClie)->LOJA%
						AND SC6.C6_ENTREG > %Exp:DTOS(dDtFim)%
						AND ((SC6.C6_QTDVEN - SC6.C6_QTDENT) > 0)
						AND SC6.%notDel% 
				EndSQL

				_nPedFut := (cQryPFtr)->TOTAL
				(cQryPFtr)->(dbCloseArea())

				//Limite de crédito do cliente	
				// IF SA1->(DBSEEK(xFilial("SA1")+(cTbPed)->CODIGO+(cTbPed)->LOJA))
				_nTotRede		:= SA1->A1_LC
				// ENDIF
			ENDIF


			//GRAVA REGISTRO DA LIBERAÇÃO DE CRÉDITO
			If RecLock("ZEJ",.T.)
				ZEJ->ZEJ_FILIAL	:= SC5->C5_FILIAL					//
				ZEJ->ZEJ_NUM		:= SC5->C5_NUM						//
				ZEJ->ZEJ_DTLIB	:= MsDate()								//
				ZEJ->ZEJ_HRLIB	:= TIME()									//
				ZEJ->ZEJ_USRLIB	:= cUserName							//
				ZEJ->ZEJ_VLLIB	:= SC5->C5_XTOTPED				//
				ZEJ->ZEJ_MOTLIB	:= 'MTA450'								//
				ZEJ->ZEJ_PARECE	:= ''											//
				ZEJ->ZEJ_PERFPG	:= cPerfPgt								//	
				ZEJ->ZEJ_RATCIS	:= _cRisco								//
				ZEJ->ZEJ_MEDATR	:= nMedAtr								//
				ZEJ->ZEJ_VLPED	:= _nPedFut								//

				ZEJ->ZEJ_VLAVEN	:= _nTotAVenc	//
				ZEJ->ZEJ_VLVENC	:= _nTotVenci							//
				ZEJ->ZEJ_VLPESP	:= 0											//
				ZEJ->ZEJ_TTACUM	:= _nTotVenci+_nTotAVenc+_nPedFut+SC5->C5_XTOTPED
				ZEJ->ZEJ_LIMCRD	:= _nTotRede							//
				ZEJ->ZEJ_PERCEN := iif(((_nTotSdRede+SC5->C5_XTOTPED)/_nTotRede)*100 > 999, 999, ((_nTotSdRede+SC5->C5_XTOTPED)/_nTotRede)*100) //Ticket 69699   - Abel Babini   - 14/03/2022 - Correção ErrorLog //Ticket 69816   - Abel Babini   - 15/03/2022 - Correção ErrorLog 
				ZEJ->ZEJ_VLUTIL := _nTotSdRede
				ZEJ->ZEJ_QTDPED := 1
				ZEJ->ZEJ_TTUTIL := (_nTotSdRede+SC5->C5_XTOTPED)

				ZEJ->(MsUnlock())
			Endif


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
		If Findfunction("U_ADVEN050P") .And. nOpc == 4 .And. Alltrim(cEmpAnt) $ cEmpSF .And. Alltrim(cFilAnt) $ cFilSF
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
