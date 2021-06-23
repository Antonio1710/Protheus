#include "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MTA456I  ³ Autor ³ hcconsys  - heverson  ³ Data ³ 04/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ponto de Entrada no MATA456 (Liberacao de Credito e estoque³±±
±±³          ³ gravar SC9, para gravar o campo C9_ROTEIRO,C9_DTENTR       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Ad'oro Alimenticia                              ³±±
±±³          ³ Usuarios FAT - MATA456 - Liberacao de Credito              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Revis„o  ³                                          ³ Data ³          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MTA456I()      // DELMTA450T()  RENOMEADA PARA DEL PARA TESTAR

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Guarda ambiente inicial                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local _aArea		:= GetArea() 
	Local lAtuSAG := SuperGetMv( "MV_#ATUSAG" , .F. , .F. ,  )
	
	// ALTERADO EM 27/01/09 PARA FORCAR POSICIONAMENTO NO PEDIDO PARA GRAVAR ROTEIRO E DATA DE ENTREGA NO SC9 , POR HCCONSYS 
	// CHAMADO 003736 
	
	
	dbSelectArea("SC5")
	dbSetOrder(1)
	IF dbSeek(xFilial("SC5")+SC9->C9_PEDIDO)
		
		dbSelectArea("SC9")
		RecLock("SC9",.F.)
			Replace C9_ROTEIRO With SC5->C5_ROTEIRO
			Replace C9_DTENTR  with SC5->C5_DTENTR    // ALTERADO EM 29/10/08 POR HCCONSYS P/ TRATAR NUMERO DO LACRE NA ROTINA MENUBALA()
			Replace C9_VEND1   with SC5->C5_VEND1 
			Replace C9_VEND1   with SC5->C5_VEND1
			SC9->C9_XHRAPRO := TIME()
			SC9->C9_XNOMAPR := cUserName
		MsUnlock()
		
		If Alltrim(FunName()) == "MATA456" .And. Empty(SC9->C9_BLCRED)  &&Mauricio 22/09/2017 - Chamado 37173
		   RecLock("SC5",.F.) 
		   SC5->C5_XPREAPR := "L"
		   SC5->C5_FLAGFIN := "L"
		   SC5->(MsUnLock())
		Endif
		
		// *** INICIO CHAMADO WILLIAM 043390 || SUPRIMENTOS || LUIS || 3525 || APROV X SAG *** //
		IF cEmpAnt == "01"
		
			IF ALLTRIM(SC5->C5_PEDSAG) <> '' 
			
				IF lAtuSAG
				
					cUpdate := " UPDATE PED SET STATUS_PRC= CASE WHEN SC5.D_E_L_E_T_ = '' THEN 'S' ELSE 'N' END, STATUS_INT='' " 
					cUpdate += " FROM SGPED010 PED WITH(NOLOCK) " 
					cUpdate += " INNER JOIN " + RetSqlName("SC5") + " SC5 WITH(NOLOCK) ON PED.C5_FILIAL = '" + SC5->C5_FILIAL + "' COLLATE Latin1_General_CI_AS AND PED.C5_NUM = '" + SC5->C5_PEDSAG + "' COLLATE Latin1_General_CI_AS  AND PED.C5_CLIENTE = '" + SC5->C5_CLIENTE  + "' COLLATE Latin1_General_CI_AS  AND PED.C5_LOJACLI = '" + SC5->C5_LOJACLI + "' COLLATE Latin1_General_CI_AS  AND PED.TABEGENE = '" + SC5->C5_TABEGEN + "' COLLATE Latin1_General_CI_AS  " 
					cUpdate += " INNER JOIN " + RetSqlName("SC6") + " SC6 WITH(NOLOCK) ON SC5.C5_FILIAL = SC6.C6_FILIAL AND SC5.C5_NUM = SC6.C6_NUM AND SC5.C5_CLIENTE = C6_CLI AND SC5.C5_LOJACLI = C6_LOJA  AND PED.CODIGENE = SC6.C6_XCODIGE " 
					cUpdate += " INNER JOIN " + RetSqlName("SC9") + " SC9 WITH(NOLOCK) ON SC6.C6_FILIAL = C9_FILIAL AND SC6.C6_NUM = C9_PEDIDO AND SC6.C6_CLI = C9_CLIENTE AND SC6.C6_LOJA = C9_LOJA AND SC6.C6_ITEM = C9_ITEM AND SC6.C6_PRODUTO = C9_PRODUTO AND SC9.D_E_L_E_T_ <> '*' " 
					cUpdate += " WHERE PED.C5_FILIAL = '" +SC5->C5_FILIAL+ "' AND PED.C5_NUM = '" +SC5->C5_PEDSAG+ "' AND PED.STATUS_PRC='A' AND SC5.C5_XLIBSAG = '1' AND SC5.C5_PEDSAG <> '' AND SC6.C6_XCODIGE <> ''  " 
				
					IF TcSqlExec(cUpdate) < 0
						ConOut( "MTA456I - Não foi possível atualizar os status de liberação dos movimentos 'Saída por venda'" + "Num Filial: " + SC5->C5_FILIAL + " Num Pedido: " + SC5->C5_NUM + "||" + SC5->C5_PEDSAG)
					ELSE	
						ConOut( "MTA456I - Atualizado os status de liberação dos movimentos 'Saída por venda'" + "Num Filial: " + SC5->C5_FILIAL + " Num Pedido: " + SC5->C5_NUM + "||" + SC5->C5_PEDSAG)
					ENDIF
				ENDIF 
			ENDIF
		ENDIF
		// *** FINAL CHAMADO WILLIAM 043390 || SUPRIMENTOS || LUIS || 3525 || APROV X SAG *** //  
		
		&&Mauricio - 15/02/17 - log de registro		  
	    dbSelectArea("ZBE")
	    RecLock("ZBE",.T.)
	    Replace ZBE_FILIAL WITH xFilial("ZBE")
	    Replace ZBE_DATA   WITH dDataBase
	    Replace ZBE_HORA   WITH TIME()
	    Replace ZBE_USUARI WITH UPPER(Alltrim(cUserName))
	    Replace ZBE_LOG    WITH "PEDIDO " + SC5->C5_NUM + " C5_FLAGFIN: "+SC5->C5_FLAGFIN + " C5_XPREAPR: "+SC5->C5_XPREAPR+ " C9_BLCRED: "+SC9->C9_BLCRED+ " C9_BLEST: "+SC9->C9_BLEST
	    Replace ZBE_MODULO WITH "SC5"
	    Replace ZBE_ROTINA WITH "MTA456I PADRAO"
	    ZBE->(MsUnlock())
		
	ENDIF
	
	RestArea( _aArea )

Return()

