#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
//#Include "TbiConn.CH"

/*/{Protheus.doc} User Function AtuLimCred
    Rotina executada manualmente. Tem o objetivo de liberar/bloquear o credito dos pedidos de venda.
	Libera / Bloqueia os pedidos de venda por credito
    Consulte: http://tdn.totvs.com/pages/releaseview.action?pageId=6071394
    @type  Function
    @author Ana Helena
    @since 21/11/2012
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
	@Chamado xxxxxx - Ana Helena - 21/11/2012 - Desenvolvimento.
    @chamado 6634 - Leonardo P. Monteiro - 30/12/2020 - Correção na rotina para excluir no fluxo de aprovação do financeiro PVs relacionadas a operações intercompany.
    @chamado 6634 - Leonardo P. Monteiro - 06/01/2020 - Correção e revisão da rotina que apresentou problemas em ambiente de produção. A rotina não processava corretamente a liberação dos PVs.
/*/

User Function AtuLimCred()
	//_dDTE1 := mv_par01      &&Mauricio - 23/11/16
	//_dDTE2 := mv_par02
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
		
	If !Pergunte("LIBCRED",.T.)
		Return
	Endif

	bBloco := {|lEnd| ProcAtu()}  
	MsAguarde(bBloco,"Aguarde, Atualizando o credito.","Atualizando...",.F.)
	
Return()

Static Function ProcAtu()
	// Leonardo P. Monteiro - 30/12/20 | Inclui como exceção os PVs do tipo intercompany.
	Local cFilInter	:= fGetInterc()
	//Local lVldInter	:= SuperGetMV("MV_#HEXINT",,.T.)

	MsProcTxt("Analisando Dados  .....")

	&&21/10/16 - incluido tratamento de pre aprovacao
	&&Atualizo todos os flagfin como liberados para os pedidos anteriormente pre aprovados...
	If Select("LSC5") > 0
		DbSelectArea("LSC5")
		LSC5->(DbCloseArea())

	Endif

	cQuery:= " SELECT C5_FILIAL,C5_NUM,C5_XPREAPR "
	cQuery+= " FROM " + RetSqlName("SC5") + " WITH(NOLOCK) "
	cQuery+= " WHERE C5_NOTA = '' AND C5_DTENTR BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "
	cQuery+= " AND C5_NUM BETWEEN '" + Alltrim(mv_par03) + "' AND '" + Alltrim(mv_par04) + "' "
	cQuery+= " AND C5_CLIENTE BETWEEN '" + Alltrim(mv_par05) + "' AND '" + Alltrim(mv_par06) + "' "
	// Leonardo P. Monteiro - 30/12/20 | Inclui como exceção os PVs do tipo intercompany.
	if !Empty(cFilInter)
		cQuery+= " AND C5_CLIENTE NOT IN ("+cFilInter+") "
	endif
	//cQuery+= " AND C5_CLIENTE NOT IN ('031017','030545') "
	
	cQuery+= " AND (C5_XPREAPR = 'L' OR C5_XPREAPR = 'B')"
	cQuery+= " AND " + RetSqlName("SC5") + ".D_E_L_E_T_ <> '*' "
	cQuery+= " ORDER BY C5_FILIAL,C5_NUM "	

	TCQUERY cQuery new alias "LSC5"	

	&&Mauricio - 21/02/17 - Novo tratamento para atualizar corretamente SC5 e SC9		
	DbSelectArea ("LSC5")
	LSC5->(dbgotop())
	Do While LSC5->(!EOF())
		DbSelectArea("SC5")
		SC5->(DbSetOrder(1))
	
		If SC5->(dbseek(LSC5->C5_FILIAL+LSC5->C5_NUM))
			If LSC5->C5_XPREAPR == "L"
				if Reclock("SC5",.F.)
					SC5->C5_FLAGFIN := "L"
					SC5->(Msunlock())
				endif
			Elseif LSC5->C5_XPREAPR == "B"
				if Reclock("SC5",.F.)
					SC5->C5_FLAGFIN := "B"
					SC5->(Msunlock())
				endif
			Endif			
			
			// Leonardo P. Monteiro - 30/12/20 | Inclui como exceção os PVs do tipo intercompany.		
			u_GrLogZBE(	Date(),;
						TIME(),;
						UPPER(Alltrim(cUserName)),;
						"Atualização de Crédito",;
						"FATURAMENTO",;
						"ATULIMCRED",;
			            "PEDIDO " + LSC5->C5_NUM +" STATUS: "+LSC5->C5_XPREAPR,;
			            ComputerName(),;
			            LogUserName())
			

			DbSelectArea("SC9")
			SC9->(DbSetOrder(1))
			
			If SC9->(dbseek(LSC5->C5_FILIAL+LSC5->C5_NUM))
				While SC9->(!Eof()) .And. SC9->(C9_FILIAL+C9_PEDIDO) == LSC5->C5_FILIAL+LSC5->C5_NUM
					If LSC5->C5_XPREAPR == "L"
						if Reclock("SC9",.F.)
							SC9->C9_BLCRED := "  "
							SC9->(Msunlock())
						endif
					Elseif LSC5->C5_XPREAPR == "B"
						if Reclock("SC9",.F.)
							SC9->C9_BLCRED := "01"
							SC9->(Msunlock())
						endif
					Endif				
					SC9->(DbSkip())
				Enddo
			Endif
		Endif
		LSC5->(DbSkip())
	Enddo

	LSC5->(DbcloseArea())

	//Atualizar C5_FLAGFIN para os clientes 031017,030545
	cQuery:= " UPDATE " + RetSqlName("SC5") // + " WITH(UPDLOCK) "
	cQuery+= " SET "  + RetSqlName("SC5") + ".C5_FLAGFIN = 'L' "
	cQuery+= " WHERE C5_DTENTR BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "
	cQuery+= " AND C5_NUM BETWEEN '" + Alltrim(mv_par03) + "' AND '" + Alltrim(mv_par04) + "' "
	// Leonardo P. Monteiro - 30/12/20 | Inclui como exceção os PVs do tipo intercompany.
	if !Empty(cFilInter)
		cQuery+= " AND C5_CLIENTE IN ("+cFilInter+") "
	endif
	//cQuery+= " AND C5_CLIENTE IN ('031017','030545') "
	cQuery+= " AND C5_FLAGFIN IN ('') " 
	cQuery+= " AND C5_NOTA = '' "
	cQuery+= " AND " + RetSqlName("SC5") + ".D_E_L_E_T_ <> '*' "

	TCSQLExec(cQuery)

	cQuery:= " SELECT C5_FILIAL,C5_CLIENTE "
	cQuery+= " FROM " + RetSqlName("SC5") + " WITH(NOLOCK) "
	cQuery+= " WHERE C5_DTENTR BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "
	cQuery+= "  AND C5_NUM BETWEEN '" + Alltrim(mv_par03) + "' AND '" + Alltrim(mv_par04) + "' "
	cQuery+= "  AND C5_CLIENTE BETWEEN '" + Alltrim(mv_par05) + "' AND '" + Alltrim(mv_par06) + "' "
	// Leonardo P. Monteiro - 30/12/20 | Inclui como exceção os PVs do tipo intercompany.
	if !Empty(cFilInter)
		cQuery+= " AND C5_CLIENTE NOT IN ("+cFilInter+") "
	endif
	//cQuery+= "  AND C5_CLIENTE NOT IN ('031017','030545') "
	//cQuery+= " AND C5_NUM = '99X8TY' "
	If mv_par07 == 1
		cQuery+= " AND C5_FLAGFIN IN ('') "
	Else 
		cQuery+= " AND C5_FLAGFIN IN ('','B') "
	Endif 
	cQuery+= " AND C5_NOTA = '' "
	cQuery+= " AND " + RetSqlName("SC5") + ".D_E_L_E_T_ <> '*' "
	cQuery+= " GROUP BY C5_FILIAL,C5_CLIENTE "
	cQuery+= " ORDER BY C5_FILIAL,C5_CLIENTE "	
			
	TCQUERY cQuery new alias "TMPLC"
	TMPLC->(dbgotop())	
			
	DbSelectArea ("TMPLC")
	Do While TMPLC->(!EOF())

		U_ConsLimFin(TMPLC->C5_CLIENTE,"Ped","FIN",mv_par01,mv_par02)
		
		cQuery:= " SELECT C5_FILIAL,C5_CLIENTE,C5_NUM FROM " + RetSqlName("SC5") + " WITH(NOLOCK) "
		cQuery+= " WHERE C5_DTENTR BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "
		cQuery+= " AND C5_NUM BETWEEN '" + Alltrim(mv_par03) + "' AND '" + Alltrim(mv_par04) + "' "
		cQuery+= " AND C5_CLIENTE = '" + TMPLC->C5_CLIENTE + "' "
		// Leonardo P. Monteiro - 30/12/20 | Inclui como exceção os PVs do tipo intercompany.
		if !Empty(cFilInter)
			cQuery+= " AND C5_CLIENTE NOT IN ("+cFilInter+") "
		endif
		//cQuery+= " AND C5_CLIENTE NOT IN ('031017','030545') "
		//cQuery+= " AND C5_NUM = '99X8TY' "
		If mv_par07 == 1
			cQuery+= " AND C5_FLAGFIN IN ('') "
		Else 
			cQuery+= " AND C5_FLAGFIN IN ('','B') "
		Endif
		cQuery+= " AND C5_NOTA = '' "	
		cQuery+= " AND " + RetSqlName("SC5") + ".D_E_L_E_T_ <> '*' "
		cQuery+= " GROUP BY C5_FILIAL,C5_CLIENTE,C5_NUM "
		cQuery+= " ORDER BY C5_FILIAL,C5_CLIENTE,C5_NUM "	
			
		TCQUERY cQuery new alias "T2MPLC"
		T2MPLC->(dbgotop())	
			
		DbSelectArea ("T2MPLC")
		Do While !EOF()

			U_AtuLCPed(T2MPLC->C5_FILIAL+T2MPLC->C5_NUM)

			DbSelectArea ("T2MPLC")
			dbSkip()
		Enddo

		T2MPLC->(DbCloseArea())

		DbSelectArea("TMPLC")
		TMPLC->(dbSkip())
	Enddo

	TMPLC->(DbCloseArea())

	&&Mauricio - 15/02/17 - passado tratamento abaixo para as querys de bloqueio/liberacao aonde efetivamente
	&&este log deve ser gravado

	//Ajuste da tabela SC9, pois ate esta parte soh atualizou o SC5
	//Bloqueio
	//cQuery:= " UPDATE " + RetSqlName("SC9") //+ " WITH(UPDLOCK) "
	cQuery:= " UPDATE C9 " //+ " WITH(UPDLOCK) "
	cQuery+= " SET C9_BLCRED = '01' , " //, C9_ROTEIRO = C5_ROTEIRO, C9_DTENTR = C5_DTENTR, C9_VEND1 = C5_VEND1  "
	cQuery+= "   C9.C9_DTENTR = C5.C5_DTENTR " + ","
	cQuery+= "   C9.C9_XHRAPRO = CONVERT(VARCHAR,GETDATE(),108)," 
	cQuery+= "   C9.C9_XNOMAPR = '" + cUserName + "', "
	cQuery+= "   C9.C9_XROTLIB = 'ATULIMCRED', "
	cQuery+= "   C9.C9_XDATLIB = '"+DTOS(Ddatabase)+"' "
	cQuery+= " FROM " + RetSqlName("SC9") + " C9 INNER JOIN " + RetSqlName("SC5") + " C5 ON C5_FILIAL = C9_FILIAL AND C5_NUM = C9_PEDIDO "
	cQuery+= " WHERE C5_NUM BETWEEN '" + Alltrim(mv_par03) + "' AND '" + Alltrim(mv_par04) + "' "
	cQuery+= " AND C5_CLIENTE BETWEEN '" + Alltrim(mv_par05) + "' AND '" + Alltrim(mv_par06) + "' "
	cQuery+= " AND C9.D_E_L_E_T_ <> '*' "  
	cQuery+= " AND C5.D_E_L_E_T_ <> '*' " 
	cQuery+= " AND C5_NOTA = '' "       
	cQuery+= " AND C5_DTENTR BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "
	cQuery+= " AND C5_FLAGFIN = 'B' "		
			
	TCSQLExec(cQuery)

	// Ricardo Lima - 09/03/18 | Atualiza SalesForce com status de credito
	If cEmpAnt == "01" .And. cFilAnt == "02" .And. Findfunction("U_ADVEN050P")
		If Upper(Alltrim(cValToChar(GetMv("MV_#SFATUF")))) == "S"
			U_ADVEN050P(,.F.,.T., " AND C5_NUM BETWEEN '" + Alltrim(mv_par03) + "' AND '" + Alltrim(mv_par04) + "' AND C5_CLIENTE BETWEEN '" + Alltrim(mv_par05) + "' AND '" + Alltrim(mv_par06) + "' AND C5_NOTA = '' AND C5_DTENTR BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' AND C5_FLAGFIN = 'B' AND C5_XPEDSAL <> '' " ,.F.)
		
		EndIf

	EndIf

	//Desbloqueio
	//cQuery:= " UPDATE " + RetSqlName("SC9") //+ " WITH(UPDLOCK) "
	cQuery:= " UPDATE C9 " //+ " WITH(UPDLOCK) "
	cQuery+= " SET C9_BLCRED = '' , " //, C9_ROTEIRO = C5_ROTEIRO, C9_DTENTR = C5_DTENTR, C9_VEND1 = C5_VEND1  "
	cQuery+= "   C9.C9_DTENTR = C5.C5_DTENTR " + ","
	cQuery+= "   C9.C9_XHRAPRO = CONVERT(VARCHAR,GETDATE(),108)," 
	cQuery+= "   C9.C9_XNOMAPR = '" + cUserName + "', "
	cQuery+= "   C9.C9_XROTLIB = 'ATULIMCRED', "
	cQuery+= "   C9.C9_XDATLIB = '"+DTOS(Ddatabase)+"' "
	cQuery+= " FROM " + RetSqlName("SC9") + " C9 INNER JOIN " + RetSqlName("SC5") + " C5 ON C5_FILIAL = C9_FILIAL AND C5_NUM = C9_PEDIDO "
	cQuery+= " WHERE C5_NUM BETWEEN '" + Alltrim(mv_par03) + "' AND '" + Alltrim(mv_par04) + "' "
	cQuery+= " AND C5_CLIENTE BETWEEN '" + Alltrim(mv_par05) + "' AND '" + Alltrim(mv_par06) + "' "
	cQuery+= " AND C9.D_E_L_E_T_ <> '*' "  
	cQuery+= " AND C5.D_E_L_E_T_ <> '*' " 
	cQuery+= " AND C5_NOTA = '' "       
	cQuery+= " AND C5_DTENTR BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "
	cQuery+= " AND C5_FLAGFIN = 'L' "		
			
	TCSQLExec(cQuery)

	// Ricardo Lima - 09/03/18 | Atualiza SalesForce com status de credito
	If cEmpAnt == "01" .And. cFilAnt == "02" .And. Findfunction("U_ADVEN050P")
		If Upper(Alltrim(cValToChar(GetMv("MV_#SFATUF")))) == "S"
			U_ADVEN050P(,.F.,.T., " AND C5_NUM BETWEEN '" + Alltrim(mv_par03) + "' AND '" + Alltrim(mv_par04) + "' AND C5_CLIENTE BETWEEN '" + Alltrim(mv_par05) + "' AND '" + Alltrim(mv_par06) + "' AND C5_NOTA = '' AND C5_DTENTR BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' AND C5_FLAGFIN = 'L' AND C5_XPEDSAL <> '' " ,.T.)				

		EndIf

	EndIf
						
	//Liberação de Estoque para todos os pedidos
	cQuery:= " UPDATE " + RetSqlName("SC9") // + " WITH(UPDLOCK) SET C9_BLEST = '' "
	cQuery+= " SET C9_BLEST = '' WHERE C9_PEDIDO BETWEEN '" + Alltrim(mv_par03) + "' AND '" + Alltrim(mv_par04) + "' "
	cQuery+= " AND C9_CLIENTE BETWEEN '" + Alltrim(mv_par05) + "' AND '" + Alltrim(mv_par06) + "' "
	cQuery+= " AND " + RetSqlName("SC9") + ".D_E_L_E_T_ <> '*' "
	cQuery+= " AND C9_DTENTR BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "
	cQuery+= " AND C9_BLEST <> '' "  
	cQuery+= " AND C9_NFISCAL = '' "		
	cQuery+= " AND C9_FILIAL <> '07' "
			
	TCSQLExec(cQuery) 		

	//
	// Inicialização de Variáveis 
	//
	nPedBlq := 0
	nPedLib := 0
	nPedNao := 0          
	nPedTot := 0
	cLuc := ' ' 
	//      
	// Contabiliza Status dos Pedidos Processados
	//             
	cQuery:= " SELECT COUNT(*) AS C5_FLAGV "
	cQuery+= " FROM "+RetSqlName("SC5")+ " WITH(NOLOCK) "
	cQuery+= " WHERE C5_DTENTR BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "
	cQuery+= "  AND C5_NUM BETWEEN '" + Alltrim(mv_par03) + "' AND '" + Alltrim(mv_par04) + "' "
	cQuery+= "  AND C5_CLIENTE BETWEEN '" + Alltrim(mv_par05) + "' AND '" + Alltrim(mv_par06) + "' "
	// Leonardo P. Monteiro - 30/12/20 | Inclui como exceção os PVs do tipo intercompany.
	if !Empty(cFilInter)
		cQuery+= " AND C5_CLIENTE NOT IN ("+cFilInter+") "
	endif
	//cQuery+= "  AND C5_CLIENTE NOT IN ('031017','030545') "
	cQuery+= "  AND C5_FLAGFIN IN ('') " 
	cQuery+= "  AND C5_NOTA = '' "
	cQuery+= "  AND " + RetSqlName("SC5") + ".D_E_L_E_T_ <> '*' "	
			
	TCQUERY cQuery new alias "TMPC5"
	TMPC5->(dbgotop())	 

	nPedNao := TMPC5->C5_FLAGV

	TMPC5->(DbCloseArea())

	cQuery:= " SELECT COUNT(*) AS C5_FLAGL "
	cQuery+= " FROM "+RetSqlName("SC5")+ " WITH(NOLOCK) "
	cQuery+= " WHERE C5_DTENTR BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "
	cQuery+= " AND C5_NUM BETWEEN '" + Alltrim(mv_par03) + "' AND '" + Alltrim(mv_par04) + "' "
	cQuery+= " AND C5_CLIENTE BETWEEN '" + Alltrim(mv_par05) + "' AND '" + Alltrim(mv_par06) + "' "
	// Leonardo P. Monteiro - 30/12/20 | Inclui como exceção os PVs do tipo intercompany.
	if !Empty(cFilInter)
		cQuery+= " AND C5_CLIENTE NOT IN ("+cFilInter+") "
	endif
	//cQuery+= " AND C5_CLIENTE NOT IN ('031017','030545') "
	cQuery+= " AND C5_FLAGFIN IN ('L') " 
	cQuery+= " AND C5_NOTA = '' "
	cQuery+= " AND " + RetSqlName("SC5") + ".D_E_L_E_T_ <> '*' "	
			
	TCQUERY cQuery new alias "TMPC5"
	TMPC5->(dbgotop())	 

	nPedLib := TMPC5->C5_FLAGL

	TMPC5->(DbCloseArea())

	cQuery:= " SELECT COUNT(*) AS C5_FLAGB "
	cQuery+= " FROM "+RetSqlName("SC5")+ " WITH(NOLOCK) "
	cQuery+= " WHERE C5_DTENTR BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "
	cQuery+= " AND C5_NUM BETWEEN '" + Alltrim(mv_par03) + "' AND '" + Alltrim(mv_par04) + "' "
	cQuery+= " AND C5_CLIENTE BETWEEN '" + Alltrim(mv_par05) + "' AND '" + Alltrim(mv_par06) + "' "
	// Leonardo P. Monteiro - 30/12/20 | Inclui como exceção os PVs do tipo intercompany.
	if !Empty(cFilInter)
		cQuery+= " AND C5_CLIENTE NOT IN ("+cFilInter+") "
	endif
	//cQuery+= " AND C5_CLIENTE NOT IN ('031017','030545') "
	cQuery+= " AND C5_FLAGFIN IN ('B') " 
	cQuery+= " AND C5_NOTA = '' "
	cQuery+= " AND " + RetSqlName("SC5") + ".D_E_L_E_T_ <> '*' "	
			
	TCQUERY cQuery new alias "TMPC5"
	TMPC5->(dbgotop())	 

	nPedBlq := TMPC5->C5_FLAGB

	TMPC5->(DbCloseArea())
			
	//   
	// --------------------------------
	// Tela exibição Status de Pedidos
	// --------------------------------
	//
	DEFINE MSDIALOG oDlg FROM	18,1 TO 80,550 TITLE "ADORO S/A  -  STATUS DOS PEDIDOS" PIXEL  
	@  2, 3 	TO 29, 242 OF oDlg  PIXEL
	If File("adoro.bmp")
	@ 3,7 BITMAP oBmp FILE "adoro.bmp" OF oDlg NOBORDER SIZE 25,25 PIXEL 
	oBmp:lStretch:=.T.
	EndIf
	@ 005, 047	SAY "BLOQUEADOS"      SIZE 40, 17 OF oDlg PIXEL 
	@ 005, 122	SAY "LIBERADOS"       SIZE 40, 17 OF oDlg PIXEL 
	@ 005, 180	SAY "NÃO PROCESSADOS" SIZE 80, 17 OF oDlg PIXEL 
	@ 014, 047 	TO 025, 083 OF oDlg  PIXEL
	@ 016, 062  Say nPedBlq  SIZE	40, 9 OF oDlg PIXEL
	@ 014, 120 	TO 025, 153 OF oDlg  PIXEL
	@ 016, 133  Say nPedLib  SIZE	40, 9 OF oDlg PIXEL  
	@ 014, 190 	TO 025, 224 OF oDlg  PIXEL
	@ 016, 205  Say nPedNao  SIZE	40, 9 OF oDlg PIXEL
	DEFINE SBUTTON FROM 10,246 TYPE 1 ACTION (nOpt := 1,oDlg:End()) ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED 

Return

// Leonardo P. Monteiro - 30/12/20 | Função responsável por retornar os clientes do tipo intercompany.
Static Function fGetInterc()
	Local cQuery 	:= ""
	Local cRet		:= ""
	Local cInter 	:= SuperGetMV("MV_#FEXCRD",,"60037058#02090384#12097672#20052541#14137141")
	
	cQuery := " SELECT DISTINCT A1_COD "
	cQuery += " FROM "+ RetSqlName("SA1") +" WITH(NOLOCK) "
	cQuery += " WHERE D_E_L_E_T_='' AND A1_FILIAL='"+ XFILIAL("SA1") +"' AND left(A1_CGC,8) IN "+ FormatIn(cInter,"#") +" "

	Tcquery cQuery ALIAS "QA1" new

	While QA1->(!EOF())
		//cRet += iif(Empty(cRet), "",",") + "'"+ QA1->A1_COD+QA1->A1_LOJA + "'"
		cRet += iif(Empty(cRet),"",",")+"'"+ QA1->A1_COD + "'"
		QA1->(DbSkip())
	enddo

	QA1->(DbcloseArea())

return cRet
