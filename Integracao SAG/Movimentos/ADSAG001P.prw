#Include 'Protheus.ch'


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função	 ?ADSAG001P    ?Autor ?Leonardo Rios	     ?Data ?13.04.16 	 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ ´±?
±±ºDesc.     ?Fonte chamado no estorno da classificação da pr?nota para    ³±?
±±?		 ?fazer o tratamento de estornar as movimentações e títulos     ³±?
±±?		 ?caso a nota tenha sido gerado a partir da tabela intermediaria³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ?MATA140 - Pr?Documento de Entrada						     ³±?
±±?		 ?Projeto SAG II											     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
User Function ADSAG001P()

Local aArea		:= GetArea() //Everson - 25/09/2017 - 037341.
Local cTM  		:= ""         
Local cNFiscal 	:= SF1->F1_DOC
Local cSerie	:= SF1->F1_SERIE
Local cA100For	:= SF1->F1_FORNECE
Local cLoja		:= SF1->F1_LOJA
Local nOpc		:= 0
Local n
Local cKeyNFE	:= SF1->(F1_FILIAL+F1_DOC+ALLTRIM(F1_SERIE)+F1_FORNECE+F1_LOJA)
Local cKeyFIN	:= SF1->(F1_FILIAL+F1_DOC+"MAN"+F1_FORNECE+F1_LOJA)
// Local _cNomBco2 := GetPvProfString("INTSAGBD","BCO2","ERROR",GetADV97())
// Local _cSrvBco2 := GetPvProfString("INTSAGBD","SRV2","ERROR",GetADV97())
// Local _cPortBco2:= Val(GetPvProfString("INTSAGBD","PRT2","ERROR",GetADV97()))
Local lRet		:= .T.
// Private _nTcConn1 := advConnection()
// Private _nTcConn2 := 0                        
Private aMov	:={}

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fonte chamado no estorno da classificação da pr?nota para fazer o tratamento de estornar as movimentações e títulos caso a nota tenha sido gerado a partir da tabela intermediaria')

// If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2)) < 0
// 	_lRet     := .F.
// 	cMsgError := "Não foi possível  conectar ao banco integração"
// 	MsgInfo("Não foi possível  conectar ao banco integração, verifique com administrador","ERROR")		
// EndIf

//TcSetConn(_nTcConn1)		

For n:=1 to Len(aRotina)	    
	If aRotina[n][2] =="U_ADSAG001P"		
		nOpc := n  
		Exit			
	EndIf		
Next n


BeginTran()
	
	If SF1->F1_TIPO=='N'  .AND. SF1->F1_CODIGEN > 0  .AND. SF1->F1_FORMUL <> 'S'
	
		// Gera estorno das movimentações
		lRet := GeraEstMOV(SF1->F1_CODIGEN)		
	
		// chama rotina padrão
		A140EstCla("SF1",SF1->(Recno()),nOpc)		
		
		//confirma estorno
		If lRet
			SF1->(DbSetOrder(1))
			If SF1->(DbSeek(xFilial("SF1")+ cNFiscal + cSerie + cA100For + cLoja))
	        	If !Empty(ALLTRIM(SF1->F1_STATUS))
					DisarmTransaction() // cancela estorno caso usuário tenha cancelado	        	
	        	Else

					// _nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2)
					//TcSetConn(_nTcConn2)		
					TcSqlExec("UPDATE SGNFE010 SET STATUS_INT = '' , STATUS_PRC = '' WHERE F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA = '" +cKeyNFE + "' " )
					TcSqlExec("UPDATE SGFIN010 SET STATUS_INT = '' , STATUS_PRC = '' , E2_MSEXP ='' WHERE E2_FILIAL+E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA = '" +cKeyFIN + "' " )
					
					For n:=1 to Len (aMov)
						TcSqlExec("UPDATE SGMOV010 SET STATUS_INT='', STATUS_PRC = '', D3_MSEXP ='' WHERE R_E_C_N_O_= '" + ALLTRIM(STR(aMov[n][1])) + "' " )				
					Next n
								
					//TcSetConn(_nTcConn1)		       				
	        	EndIf  
		    EndIf
		EndIf
	
	Else
		// chama rotina padrão
		A140EstCla("SF1",SF1->(Recno()),nOpc)		
		
	EndIf
	
	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
	Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
	Replace ZBE_DATA 	   	WITH Date()
	Replace ZBE_HORA 	   	WITH TIME()
	Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
	Replace ZBE_LOG	        WITH ("Estorno classificação " + cValToChar(SF1->(F1_DOC)) + " Fornecedor: " + cValToChar(SF1->(F1_FORNECE)) )  
	Replace ZBE_MODULO	    WITH "FISCAL"
	Replace ZBE_ROTINA	    WITH "ADSAG001P" 
	MsUnLock()
	
//TcSetConn(_nTcConn2)

//TcUnLink(_nTcConn2) 

//TcSetConn(_nTcConn1)

EndTran()

RestArea(aArea)

Return






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função	 ?GeraEstMOV   ?Autor ?Leonardo Rios	     ?Data ?13.04.16 	 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ ´±?
±±ºDesc.     ?Fonte chamado para gerar o estorno das movimentações relaciona³±?
±±?		 ?das com a pr?nota										     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ?MATA140 - Pr?Documento de Entrada						     ³±?
±±?		 ?Projeto SAG II											     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Static Function GeraEstMOV(nRec)//cProd,cTM,nQuant,cLocal,nRec)

Local aArea		:= GetArea()
Local aCampos	:= {}
Local aMOVRecno	:= {} /* Dados do campo R_E_C_N_O_ da tabela MOV */
Local aNFERecno	:= {} /* Dados do campo R_E_C_N_O_ da tabela NFE */
Local cChv1SE2	:= SF1->F1_FILIAL
Local cChv2SE2	:= SF1->F1_DOC
Local cChv3SE2	:= SF1->F1_SERIE
Local cChv4SE2	:= SF1->F1_FORNECE
Local cChv5SE2	:= SF1->F1_LOJA
Local cQuery  	:= ""
Local lRet		:= .T.

//TcSetConn(_nTcConn2)

/* Query principal para buscar as notas na tabela intermediaria SGNFE010 */
cQuery := " SELECT * "
cQuery += " FROM SGNFE010 "	
cQuery += " WHERE F1_FILIAL = '" +cChv1SE2+ "' "
cQuery += 	"	AND F1_DOC = '" +ALLTRIM(cChv2SE2)+ "' "
cQuery += 	"	AND F1_SERIE = '" +ALLTRIM(cChv3SE2)+ "' "
cQuery += 	"	AND F1_FORNECE = '" +ALLTRIM(cChv4SE2)+ "' "
cQuery += 	"	AND F1_LOJA = '" +ALLTRIM(cChv5SE2)+ "' "

cQuery := ChangeQuery(cQuery)		

If Select("NFE") <> 0
	NFE->(DbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"NFE",.T.,.F.)

aNFERecno := {}
NFE->(Dbgotop())
While !NFE->(Eof())
	AADD(aNFERecno, NFE->R_E_C_N_O_)

	cChv1SE2	:= NFE->F1_FILIAL
	cChv2SE2	:= NFE->F1_DOC
	cChv3SE2	:= NFE->F1_SERIE
	cChv4SE2	:= NFE->F1_FORNECE
	cChv5SE2	:= NFE->F1_LOJA
	
	NFE->(DbSkip())
EndDo	
NFE->(DbCloseArea())


For x:=1 To Len(aNFERecno)

	/* Query para buscar as movimentações na tabela SGMOV010 e estornar os itens filtrados do SGMOV010 */
	cQuery := " SELECT * "
	cQuery += " FROM SGMOV010 "	
	cQuery += " WHERE RECORIGEM = '" + Alltrim(Str(aNFERecno[x])) + "' " //		cQuery += " WHERE CODIGENE = '" + Alltrim(Str(aNFERecno[x])) + "' "
	cQuery += 	" AND STATUS_PRC = 'P' "
	cQuery := ChangeQuery(cQuery)
	
	If Select("MOV") <> 0
		MOV->(DbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"MOV",.T.,.F.)
	
	aMOVRecno 	:= {}
 		
	MOV->(Dbgotop())
	While !MOV->(Eof())
		
		cSD3RecOri 	:= StrZero(MOV->R_E_C_N_O_,10)
		
		AADD(aMOV,{MOV->R_E_C_N_O_})
	
		//TcSetConn(_nTcConn1)
					
		SD3->(DbOrderNickName("RECORI"))
		SD3->(DbSeek( xFilial("SD3") + cSD3RecOri ))
        While SD3->(!EOF()) .and. SD3->(D3_RECORI)==cSD3RecOri
        
			If Empty(SD3->(D3_ESTORNO))
		       	
		       	aCampos	:= {}			
		       	
				AADD(aCampos, {"D3_FILIAL"	,SD3->D3_FILIAL		, Nil})
				AADD(aCampos, {"D3_TM"		,SD3->D3_TM			, Nil})
				AADD(aCampos, {"D3_COD"		,SD3->D3_COD		, Nil})
				AADD(aCampos, {"D3_QUANT"	,SD3->D3_QUANT		, Nil}) 
				AADD(aCampos, {"D3_LOCAL"	,SD3->D3_LOCAL		, Nil})
				AADD(aCampos, {"D3_EMISSAO"	,SD3->D3_EMISSAO	, Nil})
				AADD(aCampos, {"D3_DOC"		,SD3->D3_DOC		, Nil})
				AADD(aCampos, {"D3_NUMSEQ"	,SD3->D3_NUMSEQ		, Nil})
				AADD(aCampos, {"INDEX"     , 4       			, Nil})
							
				lMsErroAuto := .F.
				MSExecAuto({|x,y| MATA240(x,y)}, aCampos, 5)
				
				If lMsErroAuto
					DisarmTransaction()
					MOSTRAERRO()
					lRet:=.F.
				Else
					lRet:=.T.
				EndIf               
			EndIf
			SD3->(Dbskip())
		EndDo
					
		//TcSetConn(_nTcConn2)
		
		MOV->(DbSkip())
	EndDo	
	MOV->(DbCloseArea())

Next x


If Len(aNFERecno) > 0
	
	/* Query para buscar os título na tabela SGFIN010 e estornar os itens filtrados do SGFIN010 */
	cQuery := " SELECT * "
	cQuery += " FROM " + RetSQLName("SE2")
	cQuery += " WHERE E2_FILIAL = '" + cChv1SE2 + "' "
	cQuery += 	" AND E2_NUM = '" + cChv2SE2 + "' "
	cQuery += 	" AND E2_PREFIXO = 'MAN' "
	cQuery += 	" AND E2_FORNECE = '" + cChv4SE2 + "' "
	cQuery += 	" AND E2_LOJA = '" + cChv5SE2 + "' "
	cQuery += 	" AND D_E_L_E_T_=' ' "		
	cQuery := ChangeQuery(cQuery)
	
	If Select("TIT") <> 0
		TIT->(DbCloseArea())
	EndIf
	
	//TcSetConn(_nTcConn1)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TIT",.T.,.F.)
	
	aFINRecno	:= {}
	aCampos		:= {}	
	TIT->(Dbgotop())
	While !TIT->(Eof())

		aCampos :={ { "E2_PREFIXO" , TIT->E2_PREFIXO , NIL },;
        		      	{ "E2_NUM"     , TIT->E2_NUM     , NIL } }
		
		SE2->(DbSetOrder(1))
		SE2->(DbSeek( xFilial("SE2") + TIT->E2_PREFIXO+TIT->E2_NUM+TIT->E2_TIPO ))
		
		lMsErroAuto := .F.
		MSExecAuto({|x,y,z| FINA050(x,y,z)}, aCampos,, 5)
		
		If lMsErroAuto
			DisarmTransaction()
			MOSTRAERRO()
			lRet:=.F.
		Else
			lRet:=.T.
		EndIf			
		
		//TcSetConn(_nTcConn1)
		
		TIT->(DbSkip())
	EndDo	
	TIT->(DbCloseArea())
EndIf				

//TcUnLink(_nTcConn2) 

RestArea(aArea)

Return lRet
