#include "protheus.ch"
#include "topconn.ch"

/*{Protheus.doc} User Function PMA200AL
	Ponto de Entrada para popular central de aprovações ZC7 = Central Aprovações (Fonte ADFIN046P.PRW)
	@type  Function
	@author Fernando Macieira
	@since 24/11/2017
	@version 01
	@history Chamado 047440 - FWNM - 17/04/2019 - Aprovacao de Projetos
	@history Chamado 051634 - FWNM - 17/10/2019 - Rel. Investimento
	@history Chamado 054573 - FWNM - 03/01/2020 - OS 056000 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || CLASSE DE VALOR
*/

User Function PMA200AL()

	Local nOpc      := 0
	Local lContinua := .f.
	
	Local lInclui := PARAMIXB[1]
	Local lAltera := PARAMIXB[3]
	Local lExclui := PARAMIXB[4]
	
	// Consiste campo AF8_XVALOR
	If AF8->(FieldPos("AF8_XVALOR")) > 0
		lContinua := .t.
		
	Else
		Aviso(	"PMA200AL-01",;
		"Projeto não possui campo para controle do valor... Contate o administrador do Protheus para criá-lo!",;
		{ "&Retorna" },,;
		"Campo [AF8_XVALOR - N - 18 - 2] editável somente na inclusão" )
		
	EndIf
	
	// Consiste campo ZC7_PROJET
	If ZC7->(FieldPos("ZC7_PROJET")) > 0
		lContinua := .t.
		
	Else
		Aviso(	"PMA200AL-02",;
		"Central de Aprovações não possui campo para controle do projeto... Contate o administrador do Protheus para criá-lo!",;
		{ "&Retorna" },,;
		"Campo [ZC7_PROJET - C - 10] " )
		
	EndIf
		
	// Inicia gerenciamento central aprovacao
	If lContinua
		
		If lInclui
			nOpc := 1
			
		ElseIf lExclui
			nOpc := 3
			
		ElseIf lAltera // fwnm - Chamado 046284
			nOpc := 4
		
		EndIf
		
		Begin Transaction 

			// Grava codigo do usuario
			RecLock("AF8", .f.)
				AF8->AF8_XUSER := __cUserID
			AF8->( msUnLock() )
			
			// Grava valor na inclusao do projeto de investimento
			RecLock("AFE", .f.)
				AFE->AFE_XVLROR := AF8->AF8_XVALOR
			AFE->( msUnLock() )
			
			// Gera central de aprovação do projeto incluído
			u_GeraZC7(nOpc)
		
		End Transaction
		
		// Chama MVC de Rateio do Projeto
		If nOpc == 1 // Inclusao
			
			// Chamado n. 051634 || OS 052955 || FINANCEIRO || LUIZ || 8451 || REL. INVESTIMENTO - fwnm - 17/10/2019
			UpCTH()
			//
		
			// Faz amarração do projeto x CC permitidos
			If MsgYesNo("Projeto de Investimento necessita de CC autorizados!" + chr(13) + chr(10) + "Deseja fazer agora?")
				u_ADPRJ002P()
			EndIf
	
			// Cronograma financeiro
			If MsgYesNo("Projeto de Investimento necessita de cronograma financeiro!" + chr(13) + chr(10) + "Deseja fazer agora?")
				u_ADPMS001P()
			Else
				// Faz o rateio automatico do projeto
				u_ADPMS002P(AF8->AF8_PROJET, AF8->AF8_REVISA, AF8->AF8_XVALOR)
			EndIf
			
		EndIf
			
	EndIf

Return

/*{Protheus.doc} User Function GeraZC7
	Funcao para gerar/excluir a central de aprovacoes (tabela ZC7)
	@type  Function
	@author Fernando Macieira
	@since 24/11/2017
	@version 01
	@history 
*/

User Function GeraZC7(nOpc, nVlr)

	Local cQuery   := ""
	Local cCodSX5  := "Z9"
	Local cCodBlq  := GetMV("MV_#ZC7BLQ",,"000003")
	Local cDscBlq  := AllTrim(Posicione("SX5",1,xFilial("SX5")+cCodSX5+cCodBlq,"X5_DESCRI"))

	// fwnm - Chamado n. 046284
	Local aAreaZC7 := ZC7->( GetArea() ) 
	Local cFaseRej := GetMV("MV_#FASREJ",,"01") 
	Local cFasePrj := GetMV("MV_PRJINIC",,"05")
	//
	
	// Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 06/05/2019
	Local nLimite  := GetMV("MV_#ZC7LIM",,1000000)
	Local nVlrRev  := 0 
	//

	Default nVlr   := AF8->AF8_XVALOR 
	
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	
	// Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 06/05/2019
	If AF8->AF8_REVISA >= "0002"
		nVlrRev := nVlr + AF8->AF8_XVALOR
	EndIf
	//
	
	cQuery := " SELECT ZCX_USER, ZCX_NOME, 'A' AV "
	cQuery += " FROM " + RetSqlName("ZCX") + " ZCX (NOLOCK) "
	cQuery += " WHERE ZCX_FILIAL='"+FWxFilial("ZCX")+"' "
	cQuery += " AND ZCX_USER='"+AF8->AF8_XCODAP+"' "
	cQuery += " AND ZCX_MSBLQL<>'1' "
	cQuery += " AND ZCX.D_E_L_E_T_='' "
	cQuery += " UNION "
	cQuery += " SELECT ZCY_USER, ZCY_NOME, 'V' AV "
	cQuery += " FROM " + RetSqlName("ZCY") + " ZCY (NOLOCK) "
	cQuery += " INNER JOIN " + RetSqlName("ZCX") + " ZCX ON ZCX_FILIAL=ZCY_FILIAL AND ZCX_CODIGO=ZCY_CODIGO AND ZCX_USER='"+AF8->AF8_XCODAP+"' AND ZCX_MSBLQL<>'1' AND ZCX.D_E_L_E_T_='' "
	cQuery += " WHERE ZCY_FILIAL='"+FWxFilial("ZCY")+"' "
	cQuery += " AND ZCY_MSBLQL<>'1' "
	cQuery += " AND ZCY.D_E_L_E_T_='' "

	// Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 06/05/2019
	If nVlr >= nLimite .or. nVlrRev >= nLimite
		cQuery += " UNION "
		cQuery += " SELECT ZCX_USER, ZCX_NOME, 'A' AV "
		cQuery += " FROM " + RetSqlName("ZCX") + " ZCX (NOLOCK) "
		cQuery += " WHERE ZCX_FILIAL='"+FWxFilial("ZCX")+"' "
		cQuery += " AND ZCX_MSBLQL<>'1' "
		cQuery += " AND ZCX.D_E_L_E_T_='' "
	EndIf
	//
	
	cQuery += " ORDER BY 3 "
	
	tcQuery cQuery New Alias "Work"
	
	Work->( dbGoTop() )
	Do While Work->( !EOF() )
	
		If nOpc == 1 .or. nOpc == 4 // INCLUSAO ou ALTERACAO
			
			If nOpc == 4
				If AF8->AF8_FASE == cFaseRej // Somente se houve recusa/reprovacao pela central
					// Restauro fase do projeto da inclusao
					RecLock("AF8", .f.)
						AF8->AF8_FASE := cFasePrj
					AF8->( msUnLock() )
				EndIf
			
				// Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 17/04/2019
				ZC7->( dbSetOrder(3) ) //ZC7_FILIAL+ZC7_PROJET+ZC7_REVPRJ
				If ZC7->( dbSeek( FWxFilial("ZC7")+AF8->AF8_PROJET+AF8->AF8_REVISA ) )
					RecLock("ZC7", .f.)
						ZC7->( dbDelete() )
					ZC7->( msUnLock() )
				EndIf
				//
			
			EndIf
			
			// Insere projeto na central de aprovacoes
			RecLock("ZC7", .t.)
	
				ZC7->ZC7_FILIAL := FWxFilial("ZC7")
				ZC7->ZC7_PROJET := AF8->AF8_PROJET
				ZC7->ZC7_TPBLQ  := cCodBlq
				ZC7->ZC7_DSCBLQ := Iif(Empty(cDscBlq),"APROVADOR PROJETOS INVESTIMENTOS",cDscBlq)
				ZC7->ZC7_VLRBLQ := nVlr
				ZC7->ZC7_REVPRJ := IiF(Empty(AF8->AF8_REVISA), "0001", AF8->AF8_REVISA)
				
				// Insere aprovador/vistador
				ZC7->ZC7_USRAPR := Work->ZCX_USER
				ZC7->ZC7_NOMAPR := Work->ZCX_NOME
	
			ZC7->( msUnLock() )
			
			// Envia email de aviso para aprovador
			aDadWF  := {}
				
			cMail   := UsrRetMail(Work->ZCX_USER)
			cUsrSol := AllTrim( __cUserID )
			cNomSol := AllTrim(UsrRetName(__cUserID))
			dDatSol := msDate()
			cHorSol := TIME()

			aAdd( aDadWF, { ZC7->ZC7_PROJET, ZC7->ZC7_REVPRJ, cUsrSol, cNomSol, dDatSol, cHorSol, nVlr, cMail, AF8->AF8_DESCRI, Work->ZCX_USER } )
				
			u_ADPRJ004P(aDadWF, "INCLUSAO")
			
		EndIf

		Work->( dbSkip() )
		
	EndDo 
	
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	RestArea( aAreaZC7 ) // fwnm - Chamado n. 046284
	
	// Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 06/05/2019
	If nVlr >= nLimite .or. nVlrRev >= nLimite
		Aviso(	"PMA200AL-03",;
		"Limite de alçada do Projeto alcançado! A alçada de aprovação será gerada para todos os aprovadores, além do vistador amarrado ao aprovador principal do projeto... Veja no botão Outras Ações -> Aprovações...",;
		{ "&Ok" },3,;
		"Limite atual (MV_#ZC7LIM): " + Transform(nLimite,"@E 999,999,999.99") )
	EndIf
	

Return

/*{Protheus.doc} User Function UPCTH
	Cria classe de valor com codigo do projeto de investimento
	https://centraldeatendimento.totvs.com/hc/pt-br/articles/360020957052-MP-ADVPL-CONTABILIDADE-GERENCIAL-Exemplo-da-Rotina-autom%C3%A1tica-CTBA060
	@type  Function
	@author Fernando Macieira
	@since 17/10/2019
	@version 01
	@history Chamado 051634 - FWNM - 17/10/2019 - Rel. Investimento
*/

Static Function UpCTH()
      
	Local aClass := {}
	Private lMsErroAuto := .f.

	aAdd(aClass,{"CTH_CLVL"  , AF8->AF8_PROJET		   ,NIL})
	aAdd(aClass,{"CTH_CLASSE","2"			   		   ,NIL})
	aAdd(aClass,{"CTH_DESC01",AllTrim(AF8->AF8_DESCRI) ,NIL})
	aAdd(aClass,{"CTH_NORMAL","2"			   		   ,NIL})
	
	CTBA060(aClass,3)

	If lMsErroAuto
		// Chamado n. 054573 || OS 056000 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || CLASSE DE VALOR - FWNM - 03/01/2020
		//msgAlert("[PMA200AL] - Classe de Valor não incluída! Informe a contabilidade...")
		msgAlert("[PMA200AL-04] - Problema na inclusão da Classe de Valor utilizando rotina padrão! Informe o TI printando a tela de erro que será exibida em seguida, mas a classe de valor será incluída para não impactar as contabilizações...")
		MostraErro()
		
		RecLock("CTH", .T.)
			CTH->CTH_FILIAL := FWxFilial("CTH")
			CTH->CTH_CLVL   := AF8->AF8_PROJET
			CTH->CTH_CLASSE := "2"
			CTH->CTH_DESC01 := AllTrim(AF8->AF8_DESCRI)
			CTH->CTH_NORMAL := "2"
			CTH->CTH_BLOQ   := "2"
			CTH->CTH_DTEXIS := msDate()
			CTH->CTH_CLVLLP := AF8->AF8_PROJET
			CTH->CTH_NORMAL := "2"
		CTH->( msUnLock() )
		//
 	EndIf

Return