#Include "Totvs.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A103CLAS  �Autor  � Fabritech          � Data �  01/03/2018 ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada na Classificacao da NF-e                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ADORO                                                      ���
���Chamado   �                                                            ���
���048558    � ABEL BABINI - AJUSTE NO TES DE DEVOLU��O CONFORME TES      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function A103CLAS()
	Local cCondAT	:= CCONDICAO	//Variavel Private da Rotina MATA103
	
	// *** Espec�fico ADORO - INICIO ABEL BABINI 23/04/2019 CHAMADO 048558 || FISCAL || RENATA || CORRIGIR A TES DE DEVOLU��O CONFORME TES DO DOC. DE SA�DA
	Local cAliasSD1 := PARAMIXB[1] //ABEL BABINI
	
	IF (cAliasSD1)->D1_TIPO == 'D' .AND. ALLTRIM((cAliasSD1)->D1_NFORI)!=''
		nPos:=Len(aCols)
		aCols[nPos,10]	:= Posicione('SF4',1,xFilial('SF4')+Posicione('SD2',3,xFilial('SD2')+(cAliasSD1)->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEMORI),"D2_TES"),'F4_TESDV')
	ENDIF
	// *** Espec�fico ADORO - FIM ABEL BABINI 23/04/2019 CHAMADO 048558 || FISCAL || RENATA || CORRIGIR A TES DE DEVOLU��O CONFORME TES DO DOC. DE SA�DA
	
	//Caso venha da Central XML, verifica se a condicao de pagamento foi alterada
	If IsInCallStack( "U_CENTNFEXM" )
		If Alltrim( SF1->F1_COND ) <> Alltrim( cCondAT )
			CCONDICAO	:= SF1->F1_COND
		EndIf
	EndIf
	
Return Nil
