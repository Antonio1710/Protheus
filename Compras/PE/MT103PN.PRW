#Include "Rwmake.ch"
#include "protheus.ch"

/*/{Protheus.doc} User Function MT103PN
	Executado antes de apresentar a tela para classificacao, a fim de preencher o 
	campo de valor de frete, pois a pre-nota gerada no SAG, embora tenha o campo 
	F1_FRETE preenchido não está levando para a tela.
	@type  Function
	@author ADRIANA OLIVEIRA
	@since 28/05/2015
	@history Ch. 047564 - ABEL BABINI | ALLAN | FISCAL | Impede classif. de documentos com RECUSA ADORO
	@history Ch. 053416 - ABEL BABINI | DEJAIME | FISCAL | Bloqueio de Imposto | 24/01/2020
	@history Ch. 053416 OS 056667 - ABEL BABINI | DEJAIME | FISCAL | Bloqueio de Imposto | 27/01/2020 | Verificado se existe pedido de compra
	@history Tkt:62460 - Fernando Sigoli | 14/10/2021 |  a função RECCOUNT()parou de funcionar  na qual substituímos pela função dbVal
	@history Tkt.62460 - ABEL BABINI - 19/10/2021 - Acrescentado o valor do ICMS ST no valor das despesas para que a comparação com o valor do Pedido fique correta
	@history Tkt.63068 - JONATHAN CARVALHO - 28/10/2021 - Alterado a referencia das tabelas SD1010 E SC7010 no Alias cAl103C7 incluido a funÃ§Ã£o %TABLE:%
	@history Tkt.62460 - ABEL BABINI - 01/11/2021 - Valor da despesa causando erro. O Valor da despesa é rateado por item e deve ser totalizado para a comparação.
/*/

User Function MT103PN     
Local lRet := .T. // ABEL BABINI 23/04/2019 CHAMADO 047564 | FISCAL | ALLAN SANTOS | Impede a classificação de documentos com Recusa Adoro.
//INICIO Ch. 053416 - ABEL BABINI | DEJAIME | FISCAL | Bloqueio de Imposto | 24/01/2020
Local aAreaDC
Local nXMLVDsp		:= 0
Local nSC7VDsp		:= 0
Local cAl103XM, cAl103C7
Local cChvXML		:= SF1->F1_CHVNFE
Local cNfSF1		:= SF1->F1_DOC
Local cSeNFSF1		:= SF1->F1_SERIE
Local cForSF1		:= SF1->F1_FORNECE
Local cLojSF1		:= SF1->F1_LOJA
Local dDtESF1		:= SF1->F1_DTDIGIT
Local dDtEMIS		:= SF1->F1_EMISSAO
Local nVlDesp		:= 0
Local nRgSC7		:= 0
Local nValFrPC	:= 0 //Tkt.62460 - ABEL BABINI - 19/10/2021 - Acrescentado o valor do ICMS ST no valor das despesas para que a comparação com o valor do Pedido fique correta
//FIM Ch. 053416 - ABEL BABINI | DEJAIME | FISCAL | Bloqueio de Imposto | 24/01/2020

If l103Class
	if MAFISRET(,"NF_FRETE") = 0 .and. SF1->F1_FRETE > 0
		MAFISALT("NF_FRETE", SF1->F1_FRETE, )     
	Endif
	//INICIO Ch. 053416 - ABEL BABINI | DEJAIME | FISCAL | Bloqueio de Imposto | 24/01/2020
	aAreaDC := GetArea()

	IF Alltrim(cChvXML) <> ''
		//Retorna valor das despesas do XML
		If Select(cAl103XM) > 0
			(cAl103XM)->(dbCloseArea())
		Endif
		cAl103XM:=GetNextAlias()
		
		//Tkt.62460 - ABEL BABINI - 19/10/2021 - Acrescentado o valor do ICMS ST no valor das despesas para que a comparação com o valor do Pedido fique correta
		BeginSQL  Alias cAl103XM
			SELECT
				SUM(RECNFXMLITENS.XIT_VALIPI + RECNFXMLITENS.XIT_VFRETE + RECNFXMLITENS.XIT_VOUTRO + RECNFXMLITENS.XIT_VALRET)		AS DESPESAS
			FROM RECNFXMLITENS RECNFXMLITENS
			WHERE RECNFXMLITENS.XIT_CHAVE = %Exp:cChvXML%
				AND RECNFXMLITENS.%notDel%
			GROUP BY RECNFXMLITENS.XIT_CHAVE
		EndSQL

		(cAl103XM)->(dbGoTop())
		DbSelectArea(cAl103XM)
		IF !(cAl103XM)->(eof())
			nXMLVDsp := (cAl103XM)->DESPESAS
		ENDIF
		(cAl103XM)->(dbCloseArea())	
	
	ENDIF

	//Retorna valor das despesas do Pedido de Compra
	If Select(cAl103C7) > 0
		(cAl103C7)->(dbCloseArea())
	Endif
	
	cAl103C7:=GetNextAlias()
	
	BeginSQL  Alias cAl103C7
		SELECT 
			SC7.C7_MOEDA,
			SC7.C7_TXMOEDA,
			SD1.D1_PEDIDO,
			SD1.D1_QUANT AS QTDNF,
			ISNULL((SELECT 
				SUM(SC7B.C7_QUANT) AS QTD
				FROM %TABLE:SC7% SC7B
				WHERE SC7B.C7_FILIAL = SC7.C7_FILIAL
				AND SC7B.C7_NUM = SC7.C7_NUM
				AND SC7B.D_E_L_E_T_ = ''), 0) AS QTDPC,
			ISNULL((SELECT 
				SUM(SC7B.C7_VALFRE) AS FRETEPC2
				FROM %TABLE:SC7% SC7B
				WHERE SC7B.C7_FILIAL = SC7.C7_FILIAL
				AND SC7B.C7_NUM = SC7.C7_NUM
				AND SC7B.D_E_L_E_T_ = ''), 0) AS FRETEPC2,
			//Atendendo o ticket 63068 JONATHAN.CARVALHO 28/10/2021	
			//CASE WHEN C7_FRETE > 0 THEN ROUND(((SC7.C7_TOTAL+SC7.C7_FRETE) * C7_IPI)/100,2) ELSE ROUND(((SC7.C7_TOTAL+SC7.C7_VALFRE) * C7_IPI)/100,2) END AS IPIPC,
			(SC7.C7_VALIPI/SC7.C7_QUANT) AS IPIPC,
			(SC7.C7_FRETE) AS FRETEPC,
			//Tkt.62460 - ABEL BABINI - 01/11/2021 - Valor da despesa causando erro. O Valor da despesa é rateado por item e deve ser totalizado para a comparação.
			ISNULL((SELECT 
				SUM(SC7B.C7_DESPESA) AS DESPPC
				FROM %TABLE:SC7% SC7B
				WHERE SC7B.C7_FILIAL = SC7.C7_FILIAL
				AND SC7B.C7_NUM = SC7.C7_NUM
				AND SC7B.D_E_L_E_T_ = ''), 0) AS DESPPC,
			//(SC7.C7_DESPESA) AS DESPPC,
			(SC7.C7_SEGURO) AS SEGUROPC,
			ISNULL((SELECT 
					SUM(SD1B.D1_VALFRE)
				FROM %TABLE:SD1% SD1B
				WHERE SD1B.D1_FILIAL = SD1.D1_FILIAL
				AND SD1B.D1_PEDIDO = SD1.D1_PEDIDO
				AND SD1B.D1_TES <> ''
				AND SD1B.%notDel%	
			), 0) AS FRETEREC,
			ISNULL((SELECT 
					SUM(SD1B.D1_SEGURO)
				FROM %TABLE:SD1% SD1B
				WHERE SD1B.D1_FILIAL = SD1.D1_FILIAL
				AND SD1B.D1_PEDIDO = SD1.D1_PEDIDO
				AND SD1B.D1_TES <> ''
				AND SD1B.%notDel%	
			), 0) AS SEGUROREC,
			ISNULL((SELECT 
					SUM(SD1B.D1_DESPESA)
				FROM %TABLE:SD1% SD1B
				WHERE SD1B.D1_FILIAL = SD1.D1_FILIAL
				AND SD1B.D1_PEDIDO = SD1.D1_PEDIDO
				AND SD1B.D1_TES <> ''
				AND SD1B.%notDel%	
			), 0) AS DESPESAREC			
		FROM %TABLE:SD1% SD1
		INNER JOIN %TABLE:SC7% SC7 ON
			SC7.C7_FILIAL = SD1.D1_FILIAL
			AND SC7.C7_NUM = SD1.D1_PEDIDO
			AND SC7.C7_ITEM = SD1.D1_ITEMPC
			AND SC7.%notDel%	
		WHERE SD1.D1_FILIAL = %xFilial:SD1%
			AND SD1.D1_DOC = %Exp:cNfSF1%
			AND SD1.D1_SERIE = %Exp:cSeNFSF1%
			AND SD1.D1_FORNECE = %Exp:cForSF1%
			AND SD1.D1_LOJA = %Exp:cLojSF1%
			AND SD1.D1_DTDIGIT = %Exp:dDtESF1%
			AND SD1.%notDel%
	EndSQL
	
	DbSelectArea(cAl103C7)
	(cAl103C7)->(dbGoTop())
	(cAl103C7)->( dbEval( { || nRgSC7 ++ },,{ || !Eof() } ) )
	(cAl103C7)->(dbGoTop()) 

	//nRgSC7	:= (cAl103C7)->(RecCount()) //Ch. 053416 OS 056667 - ABEL BABINI | DEJAIME | FISCAL | Bloqueio de Imposto | 27/01/2020 | Verificado se existe pedido de compra

	If nRgSC7 > 0 //Ch. 053416 OS 056667 - ABEL BABINI | DEJAIME | FISCAL | Bloqueio de Imposto | 27/01/2020 | Verificado se existe pedido de compra
		//Tkt.62460 - ABEL BABINI - 19/10/2021 - Acrescentado o valor do ICMS ST no valor das despesas para que a comparação com o valor do Pedido fique correta
		IF (cAl103C7)->FRETEPC2 == 0 .AND. (cAl103C7)->FRETEPC <> 0
			nValFrPC := (cAl103C7)->FRETEPC
		ELSE
			nValFrPC := (cAl103C7)->FRETEPC2
		ENDIF
		//Tkt.62460 - ABEL BABINI - 19/10/2021 - Acrescentado o valor do ICMS ST no valor das despesas para que a comparação com o valor do Pedido fique correta

		nVlDesp	:=	((cAl103C7)->SEGUROPC + (cAl103C7)->DESPPC + nValFrPC) - ;
								((cAl103C7)->SEGUROREC + (cAl103C7)->DESPESAREC + (cAl103C7)->FRETEREC) 
		
		nVlIpi := 0
		while !(cAl103C7)->(eof())
			nVlIpi	:= nVlIpi + Round((cAl103C7)->IPIPC * (cAl103C7)->QTDNF,2)
			(cAl103C7)->(dbSkip())
		EndDo
		(cAl103C7)->(dbGoTop())
		nVlDesp := nVlDesp + nVlIpi

		IF !(cAl103C7)->(eof())
			IF !(cAl103C7)->C7_MOEDA > 1
				nSC7VDsp := round(nVlDesp,2)
			ELSE
				nVlrDlr := 0
				IF (cAl103C7)->C7_TXMOEDA == 0
					DbSelectArea("SM2")
					DbSetOrder(1)
					if DbSeek(Dtos(dDtEMIS))
						nVlrDlr := &("M2_MOEDA"+STR((cAl103C7)->C7_MOEDA,1))
						If nVlrDlr == 0
							MsgInfo("Pedido de compra na moeda "+STR((cAl103C7)->C7_MOEDA,1)+" sem cotacao, verifique no cadastro de moedas dia: "+DTOC(dDtEMIS))
							nVlrDlr := 1
						Endif
					Else
						MsgInfo("Pedido de compra na moeda "+STR((cAl103C7)->C7_MOEDA,1)+" sem cotacao cadastrada na data: "+DTOC(dDtEMIS))
						nVlrDlr := 1
					Endif
				Else
					nVlrDlr := (cAl103C7)->C7_TXMOEDA
				ENDIF

				nSC7VDsp := round(nVlDesp * nVlrDlr,2)
			ENDIF
		ENDIF


		//valida valores
		//IF nXMLVDsp <> nSC7VDsp
		If ABS(Round( ABS(nXMLVDsp) - ABS(nSC7VDsp) ,2)) > Round( GETMV("MV_#VLTOTN") ,2)
			AVISO(	'Pedido de Compra Divergente com XML',;
						'O valor das despesas informada no XML não confere com o valor das despesas informada no Pedido de Compra. Consulte o Depto. Fiscal!'+;
						CRLF+'Pedido de Compra R$'+Alltrim(Str(nSC7VDsp))+' <-> '+'XML R$'+Alltrim(Str(nXMLVDsp))+' || '+'Valores considerados: Frete, Despesas, Seguro, IPI', {"Fechar"}, 2 )   
			lRet:= .F.	
		ENDIF
	ENDIF
	(cAl103C7)->(dbCloseArea())	
	RestArea(aAreaDC)
	//FIM Ch. 053416 - ABEL BABINI | DEJAIME | FISCAL | Bloqueio de Imposto | 24/01/2020
Endif

// INICIO ABEL BABINI 23/04/2019 CHAMADO 047564 | FISCAL | ALLAN SANTOS | Impede a classificação de documentos com Recusa Adoro.
dbSelectArea('ZCW')
dbSetOrder(2)
If ZCW->(dbSeek(xFilial('ZCW')+SF1->F1_CHVNFE))
	AVISO('Bloqueio de Classificação', 'Esta NF foi recusada e não pode ser classificada. Consulte o Depto. Fiscal!', {"Fechar"}, 1 )   
	lRet:= .F.
Else
	dbSelectArea('ZCW')
	dbSetOrder(1)
	If ZCW->(dbSeek(xFilial('ZCW')+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
		AVISO('Bloqueio de Classificação', 'Esta NF foi recusada e não pode ser classificada. Consulte o Depto. Fiscal!', {"Fechar"}, 1 )   
		lRet := .F.		
	Endif
Endif
// FIM ABEL BABINI 23/04/2019 CHAMADO 047564 | FISCAL | ALLAN SANTOS | Impede a classificação de documentos com Recusa Adoro.

Return lRet
