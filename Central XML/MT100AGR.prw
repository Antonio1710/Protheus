#INCLUDE "Protheus.ch"
#INCLUDE "XmlXFun.Ch"
#Include 'Topconn.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAMT100AGR บAutor  ณFabritech           บ Data ณ  02/03/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPE funcionalidades de inclusใo, altera็ใo, exclusใo de notasบฑฑ
ฑฑบ          ณfiscais de entrada, chamado ap๓s a confirma็ใo da NF,       บฑฑ
ฑฑบ          ณpor้m fora da transa็ใo                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACOM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบversionamento ณ                                                        บฑฑ
ฑฑEverson 20/11/2018 chamado 045271. Tratamento para remover flag         บฑฑ
ฑฑno banco integra็ใo Protheus x SAG para que o SAG possa reprocessar o   บฑฑ
ฑฑregitro.                                                                บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function MT100AGR()

	//Validar apenas chamada da Rotina de CT-e
	If IsInCallStack( "U_RECNFECTE" ) .And. Type( "aCtePriv" ) <> "U" .And. ValType( aCtePriv[01] ) == "D"
		AltVencSe2()
	EndIf	
	
	//
	if FindFunction("U_ADVEN077P") .And. Alltrim(cValToChar(SF1->F1_TIPO)) == "D" .And. (INCLUI .Or. ALTERA)
		U_ADVEN077P(cEmpAnt,cFilAnt,FWxFilial("SF1") + Alltrim(cValToChar(SF1->F1_FORNECE)) + Alltrim(cValToChar(SF1->F1_LOJA)) + Alltrim(cValToChar(SF1->F1_DOC)) + Alltrim(cValToChar(SF1->F1_SERIE)) ,.F.,"",.F.)
	endif
	
	//Everson - 20/11/2018.
	If cEmpAnt == "01" .And. Alltrim(cValToChar(SF1->F1_FORMUL)) == "S"
		chkSag(Alltrim(cValToChar(SF1->F1_FORNECE)), Alltrim(cValToChar(SF1->F1_LOJA)), Alltrim(cValToChar(SF1->F1_DOC)), Alltrim(cValToChar(SF1->F1_SERIE)) )
	
	EndIf

Return Nil

Static Function AltVencSe2()  
	Local aAreaATU	:= GetArea()
	Local aAreaSE2	:= SE2->( GetArea() )
	Local aAreaSF1	:= SF1->( GetArea() )
	Local aAreaSD1	:= SD1->( GetArea() )
	Local aSE2Vet 	:= {}

	Local cAliasSE2 := GetNextAlias()
	Local cTitulo	:= SF1->F1_DUPL
	Local cPrefixo	:= SF1->F1_PREFIXO 	
	Local cFornece	:= SF1->F1_FORNECE
	Local cLoja		:= SF1->F1_LOJA 
	Local cMsgErro	:= ""

	Private lMsErroAuto	:= .F.


	BeginSql Alias cAliasSE2
		SELECT	E2_NUM, 	E2_PREFIXO, E2_PARCELA, E2_TIPO, 	E2_NATUREZ
		,		E2_FORNECE, E2_LOJA,	E2_EMISSAO, E2_VALOR,	R_E_C_N_O_ AS RECE2
		FROM 	%Table:SE2% SE2
		WHERE 	E2_FILIAL   = %xFilial:SE2%
		AND 	E2_NUM 		= %Exp:cTitulo%
		AND 	E2_PREFIXO 	= %Exp:cPrefixo%
		AND 	E2_FORNECE 	= %Exp:cFornece%
		AND 	E2_LOJA		= %Exp:cLoja%
		AND 	SE2.%NotDel%
		ORDER 	BY E2_PARCELA
	EndSql

	While ( cAliasSE2 )->( !EoF() )	

		//Ajustado para Reclock devido a Contabilizacao
		DbSelectarea("SE2")
		SE2->( DbGoto( ( cAliasSE2 )->RECE2 ) )
		RecLock( "SE2", .F. )
		SE2->E2_VENCTO	:= aCtePriv[01]
		SE2->E2_VENCREA	:= aCtePriv[01]
		MsUnlock()

		( cAliasSE2 )->( DbSkip() )
	End	   		

	( cAliasSE2 )->( DbCloseArea() )

	RestArea( aAreaSF1 )
	RestArea( aAreaSD1 )
	RestArea( aAreaSE2 )
	RestArea( aAreaATU )

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณchkSag    บAutor  ณEverson             บ Data ณ  20/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCheca se a devolu็ใo ้ total para marcar a tabela de        บฑฑ
ฑฑบ          ณintegra็ใo Protheus x SAG.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 045271                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function chkSag(cFornec,cLoja,cNf,cSerie)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea	:= GetArea()
	Local cQuery:= ""
	Local cDoc	:= ""
	Local cSer  := ""
	
	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " D2_DOC, D2_SERIE, SUM(D2_QTSEGUM) AS TOT_SAIDA , SUM(D1_QUANT) AS TOT_ENTRADA " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SD1") + " (NOLOCK) AS SD1 " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SD2") + " (NOLOCK) AS SD2 " 
	cQuery += " ON D1_FILIAL = D2_FILIAL " 
	cQuery += " AND D1_NFORI = D2_DOC " 
	cQuery += " AND D1_SERIORI = D2_SERIE " 
	cQuery += " AND D1_FORNECE = D2_CLIENTE " 
	cQuery += " AND D1_LOJA = D2_LOJA " 
	cQuery += " WHERE " 
	cQuery += " D1_FILIAL = '" + cFilAnt + "' " 
	cQuery += " AND D1_DOC = '" + cNf + "' " 
	cQuery += " AND D1_SERIE = '" + cSerie + "' " 
	cQuery += " AND D1_FORNECE = '" + cFornec + "' " 
	cQuery += " AND D1_LOJA = '" + cLoja + "' " 
	cQuery += " AND D1_FORMUL = 'S' " 
	cQuery += " AND SD1.D_E_L_E_T_ = '' " 
	cQuery += " AND SD2.D_E_L_E_T_ = '' " 
	cQuery += " GROUP BY D2_DOC, D2_SERIE " 
	cQuery += " HAVING SUM(D2_QTSEGUM) = SUM(D1_QUANT) " 

	//
	If Select("CHK_SAG") > 0
		CHK_SAG->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "CHK_SAG"
	DbSelectArea("CHK_SAG")
	CHK_SAG->(DbGoTop())
	
	While ! CHK_SAG->(Eof())
		
		cDoc 	:= Alltrim(cValToChar(CHK_SAG->D2_DOC))
		cSer	:= Alltrim(cValToChar(CHK_SAG->D2_SERIE))

		StaticCall(M521DNFS,flagSag,cDoc,cSer)
		
		CHK_SAG->(DbSkip())
	End
	CHK_SAG->(DbCloseArea())

	//
	RestArea(aArea)
	
Return Nil