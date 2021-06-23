#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ATULIMCRED   ³ Autor ³ Ana Helena           ³ Data ³21.11.12³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina executada manualmente. Tem o objetivo de liberar /   ³±±
±±³ bloquear o credito dos pedidos de venda.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Libera / Bloqueia os pedidos de venda por credito                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function VENATULC()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina executada manualmente. Tem o objetivo de liberar / bloquear o credito dos pedidos de venda.')
      
//If !Pergunte("LIBCRED",.T.)
//	Return
//Endif

cQuery:= " SELECT C5_FILIAL,C5_CLIENTE FROM " + RetSqlName("SC5") + " WITH(NOLOCK) "
cQuery+= " INNER JOIN " + RetSqlName("SA3") + " ON A3_COD = C5_VEND1 "
cQuery+= " WHERE C5_DTENTR >= '" + DTOS(DATE()) + "' "
//cQuery+= " AND C5_NUM BETWEEN '" + Alltrim(mv_par03) + "' AND '" + Alltrim(mv_par04) + "' "
//cQuery+= " AND C5_CLIENTE BETWEEN '" + Alltrim(mv_par05) + "' AND '" + Alltrim(mv_par06) + "' "
cQuery+= " AND C5_CLIENTE NOT IN ('031017','030545') "
//If mv_par07 == 1
//	cQuery+= " AND C5_FLAGFIN IN ('') "
//Else 
	cQuery+= " AND C5_FLAGFIN IN ('','B') "
//Endif 
cQuery+= " AND C5_NOTA = '' "
cQuery+= " AND A3_CODUSR = '" + Alltrim(__cUserID) + "' "
cQuery+= " AND " + RetSqlName("SC5") + ".D_E_L_E_T_ <> '*' "
cQuery+= " AND " + RetSqlName("SA3") + ".D_E_L_E_T_ <> '*' "
cQuery+= " GROUP BY C5_FILIAL,C5_CLIENTE "
cQuery+= " ORDER BY C5_FILIAL,C5_CLIENTE "	
		
TCQUERY cQuery new alias "TMPLC"
TMPLC->(dbgotop())	
		
DbSelectArea ("TMPLC")
Do While !EOF()

	U_ConsLimFin(TMPLC->C5_CLIENTE,"Ped","VEN")
	
	cQuery:= " SELECT C5_FILIAL,C5_CLIENTE,C5_NUM FROM " + RetSqlName("SC5") + " WITH(NOLOCK) "
	cQuery+= " INNER JOIN " + RetSqlName("SA3") + " ON A3_COD = C5_VEND1 "	
	cQuery+= " WHERE C5_DTENTR >= '" + DTOS(DATE()) + "' "
	//cQuery+= " AND C5_NUM BETWEEN '" + Alltrim(mv_par03) + "' AND '" + Alltrim(mv_par04) + "' "
	cQuery+= " AND C5_CLIENTE = '" + TMPLC->C5_CLIENTE + "' "
	cQuery+= " AND C5_CLIENTE NOT IN ('031017','030545') "
	//If mv_par07 == 1
	//	cQuery+= " AND C5_FLAGFIN IN ('') "
    //	Else 
		cQuery+= " AND C5_FLAGFIN IN ('','B') "
	//Endif
	cQuery+= " AND C5_NOTA = '' "
	cQuery+= " AND A3_CODUSR = '" + Alltrim(__cUserID) + "' "		
	cQuery+= " AND " + RetSqlName("SC5") + ".D_E_L_E_T_ <> '*' "
	cQuery+= " AND " + RetSqlName("SA3") + ".D_E_L_E_T_ <> '*' "	
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
	
	DbCloseArea("T2MPLC")	

	DbSelectArea ("TMPLC")
	dbSkip()
Enddo

DbCloseArea("TMPLC")

//Atualizar C9_DTENTR - Utilizado no filtro da Rotina Liberação de Crédito
cQuery:= " UPDATE " + RetSqlName("SC9") + " WITH(UPDLOCK) "
cQuery+= " SET "  + RetSqlName("SC9") + ".C9_DTENTR = " + RetSqlName("SC5") + ".C5_DTENTR "
cQuery+= " FROM " + RetSqlName("SC9") + " INNER JOIN " + RetSqlName("SC5") + " ON C5_FILIAL = C9_FILIAL AND C5_NUM = C9_PEDIDO "
cQuery+= " INNER JOIN " + RetSqlName("SA3") + " ON A3_COD = C5_VEND1 "
cQuery+= " WHERE C5_DTENTR >= '" + DTOS(DATE()) + "' "
cQuery+= " AND " + RetSqlName("SC5") + ".D_E_L_E_T_ <> '*' "
cQuery+= " AND " + RetSqlName("SA3") + ".D_E_L_E_T_ <> '*' "
//cQuery+= " AND C5_NUM BETWEEN '" + Alltrim(mv_par03) + "' AND '" + Alltrim(mv_par04) + "' "
//cQuery+= " AND C5_CLIENTE BETWEEN '" + Alltrim(mv_par05) + "' AND '" + Alltrim(mv_par06) + "' "
cQuery+= " AND C5_NOTA = '' "
cQuery+= " AND A3_CODUSR = '" + Alltrim(__cUserID) + "' "

TCSQLExec(cQuery)

//Ajuste da tabela SC9, pois ate esta parte soh atualizou o SC5

//Bloqueio
cQuery:= " UPDATE " + RetSqlName("SC9") + " WITH(UPDLOCK) "
cQuery+= " SET C9_BLCRED = '01' " //, C9_ROTEIRO = C5_ROTEIRO, C9_DTENTR = C5_DTENTR, C9_VEND1 = C5_VEND1  "
cQuery+= " FROM " + RetSqlName("SC9") + " INNER JOIN " + RetSqlName("SC5") + " ON C5_FILIAL = C9_FILIAL AND C5_NUM = C9_PEDIDO "
cQuery+= " INNER JOIN " + RetSqlName("SA3") + " ON A3_COD = C5_VEND1 "
//cQuery+= " WHERE C5_NUM BETWEEN '" + Alltrim(mv_par03) + "' AND '" + Alltrim(mv_par04) + "' "
//cQuery+= " AND C5_CLIENTE BETWEEN '" + Alltrim(mv_par05) + "' AND '" + Alltrim(mv_par06) + "' "
cQuery+= " WHERE " + RetSqlName("SC9") + ".D_E_L_E_T_ <> '*' "  
cQuery+= " AND " + RetSqlName("SC5") + ".D_E_L_E_T_ <> '*' " 
cQuery+= " AND " + RetSqlName("SA3") + ".D_E_L_E_T_ <> '*' "
cQuery+= " AND C5_NOTA = '' "       
cQuery+= " AND C5_DTENTR >= '" + DTOS(DATE()) + "' "
cQuery+= " AND C5_FLAGFIN = 'B' "
cQuery+= " AND A3_CODUSR = '" + Alltrim(__cUserID) + "' "		
		
TCSQLExec(cQuery)

//Desbloqueio
cQuery:= " UPDATE " + RetSqlName("SC9") + " WITH(UPDLOCK) "
cQuery+= " SET C9_BLCRED = '' " //, C9_ROTEIRO = C5_ROTEIRO, C9_DTENTR = C5_DTENTR, C9_VEND1 = C5_VEND1  "
cQuery+= " FROM " + RetSqlName("SC9") + " INNER JOIN " + RetSqlName("SC5") + " ON C5_FILIAL = C9_FILIAL AND C5_NUM = C9_PEDIDO "
cQuery+= " INNER JOIN " + RetSqlName("SA3") + " ON A3_COD = C5_VEND1 "
//cQuery+= " WHERE C5_NUM BETWEEN '" + Alltrim(mv_par03) + "' AND '" + Alltrim(mv_par04) + "' "
//cQuery+= " AND C5_CLIENTE BETWEEN '" + Alltrim(mv_par05) + "' AND '" + Alltrim(mv_par06) + "' "
cQuery+= " WHERE " + RetSqlName("SC9") + ".D_E_L_E_T_ <> '*' "  
cQuery+= " AND " + RetSqlName("SC5") + ".D_E_L_E_T_ <> '*' "
cQuery+= " AND " + RetSqlName("SA3") + ".D_E_L_E_T_ <> '*' " 
cQuery+= " AND C5_NOTA = '' "       
cQuery+= " AND C5_DTENTR >= '" + DTOS(DATE()) + "' "
cQuery+= " AND C5_FLAGFIN = 'L' "
cQuery+= " AND A3_CODUSR = '" + Alltrim(__cUserID) + "' "		
		
TCSQLExec(cQuery)

Alert("Rotina de Credito - Processo Finalizado")

Return
