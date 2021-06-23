#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"

/*/{Protheus.doc} User Function LIMPAEST
	(long_description)
	@type  Function
	@author user
	@since 07/05/2021
	@version version
	@history Ticket Interno TI - Abel Babini - 07/05/2021 - Inutilização da rotina
	/*/

User Function LIMPAEST()
	
	Aviso("LIMPAEST", "Esta rotina foi descontinuada. Favor entrar em contato com a TI. (LIMPAEST.PRW)", {"OK"}, 3)
Return

// 	Private _dData1           := CTOD("  /  /  ")     				
// 	Private _dData2	          := CTOD("  /  /  ")                     
// 	Private _cFil1	          := space(02)                           
// 	Private _cFil2	          := space(02)    
// 	Private oCheck1          := NIL
// 	Private lProdComEndereco := .F.   	
	
// 	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
// 	DEFINE MSDIALOG _oDlg TITLE "Eliminacao do bloqueio de estoque" FROM (601),(295) TO (755),(918) PIXEL
	
// 	@ (005),(005) Say "Data entrega De  : " 				Size (070),(009) COLOR CLR_BLACK PIXEL OF _oDlg
// 	@ (005),(080) MsGet o_cBal Var  _dData1				 	Size (042),(009) COLOR CLR_BLACK PIXEL OF _oDlg
// 	@ (005),(150) Say "Data entrega Ate : " 				Size (070),(009) COLOR CLR_BLACK PIXEL OF _oDlg
// 	@ (005),(200) MsGet o_cProd Var _dData2 		 	    Size (042),(009) COLOR CLR_BLACK PIXEL OF _oDlg
// 	@ (025),(005) Say "Filial De : " 						Size (050),(009)COLOR CLR_BLACK PIXEL OF _oDlg
// 	@ (025),(080) MsGet o_cSeq Var _cFil1				 	Size (020),(009) COLOR CLR_BLACK PIXEL OF _oDlg
// 	@ (025),(150) Say "Filial Ate : " 						Size (050),(009) COLOR CLR_BLACK PIXEL OF _oDlg
// 	@ (025),(200) MsGet o_cDta Var _cFil2				 	Size (020),(009) COLOR CLR_BLACK PIXEL OF _oDlg
	
// 	oCheck1 := TCheckBox():New(50,010,'Liberar Estoque com produtos que controla Endereço ?',{|u|if(PCount()>0,lProdComEndereco:=u,lProdComEndereco)},_ODLG,300,110,,,,,,,,.T.,,,) //chamado 034477
	
// 	@ (065),(270) Button "Eliminar" Size (037),(012) ACTION Processa( {|| IIF(lProdComEndereco == .T.,Enderecos(),Elimina()),_ODLG:END() },"eliminando...") PIXEL OF _oDlg
// 	   //
// 	ACTIVATE MSDIALOG _oDlg CENTERED

// Return                  

STATIC FUNCTION Enderecos()

	Local cLog        := ''
	Local nTotSB2     := 0
	Local nTotSBF     := 0
	Local cTes        := ''
	Local cEstoqueTes := ''

	SqlPedidos()
	
    While TRB->(!EOF())
    
    	nTotSB2     := 0
	    nTotSBF     := 0
	    cTes        := ''
	    cEstoqueTes := ''
    
    	SqlSB2(TRB->C9_FILIAL,TRB->C9_PRODUTO,TRB->C9_LOCAL)
    	While TRC->(!EOF())
    	
    		nTotSB2 := TRC->B2_QATU 
                  
            TRC->(dbSkip())
		ENDDO
		TRC->(dbCloseArea())
		
		SqlSBF(TRB->C9_FILIAL,TRB->C9_PRODUTO,TRB->C9_LOCAL)
		While TRD->(!EOF())
		
			nTotSBF := TRD->BF_QUANT
                  
            TRD->(dbSkip())
		ENDDO
		TRD->(dbCloseArea())
		
		// *** INICIO VERIFICA SE A TES ATUALIZA ESTOQUE SIM OU NAO *** //
		
		cTes        := Posicione("SC6",1,TRB->C9_FILIAL+TRB->C9_PEDIDO+TRB->C9_ITEM+TRB->C9_PRODUTO,"C6_TES")
	    cEstoqueTes := Posicione("SF4",1,xFilial("SF4")+cTes,"F4_ESTOQUE")
		
		// *** FINAL VERIFICA SE A TES ATUALIZA ESTOQUE SIM OU NAO *** //
		
		IF nTotSB2                     >= TRB->C9_QTDLIB .AND. ;
		   nTotSBF                     >= TRB->C9_QTDLIB .AND. ;
		   UPPER(ALLTRIM(cEstoqueTes)) == 'S'
		   
		   //QUANDO TEM SALDO NO ESTOQUE FAZ O UPDATE
		   LIMPABLOQUEIO(TRB->C9_FILIAL,TRB->C9_PEDIDO,TRB->C9_ITEM,TRB->C9_CLIENTE,TRB->C9_LOJA,TRB->C9_PRODUTO)
		   
		ELSEIF UPPER(ALLTRIM(cEstoqueTes)) == 'N'
		
		   //QUANDO TES NAO CONTROLA ESTOQUE LIBERA TAMBEM POIS NAO PRECISA DE TRAVA
		   LIMPABLOQUEIO(TRB->C9_FILIAL,TRB->C9_PEDIDO,TRB->C9_ITEM,TRB->C9_CLIENTE,TRB->C9_LOJA,TRB->C9_PRODUTO)
		   
		   
		ELSE
		
		   //QUANDO NAO TEM SALDO NO ESTOQUE SOMA UMA MENSAGEM EM UMA VARIAVEL E MOSTRA NA TELA NO FINAL
		   
		   IF ALLTRIM(cLog) == ''
		   
		   		cLog := "OLÁ " + Alltrim(cUserName) + CHR(13) + CHR(10) + CHR(13) + CHR(10)
		   		
		   ENDIF
		   
		   cLog += 'Filial: '            + TRB->C9_FILIAL             + CHR(13) + CHR(10)
		   cLog += 'Pedido: '            + TRB->C9_PEDIDO             + CHR(13) + CHR(10)
		   cLog += 'Item: '              + TRB->C9_ITEM               + CHR(13) + CHR(10)
		   cLog += 'Produto: '           + TRB->C9_PRODUTO            + CHR(13) + CHR(10)
		   cLog += 'Quantidade: '        + CVALTOCHAR(TRB->C9_QTDLIB) + CHR(13) + CHR(10)
		   cLog += 'Local: '             + TRB->C9_LOCAL              + CHR(13) + CHR(10) + CHR(13) + CHR(10)
		   cLog += 'Saldo Estoque SB2: ' + CVALTOCHAR(nTotSB2)        + CHR(13) + CHR(10)
		   cLog += 'Saldo Estoque SBF: ' + CVALTOCHAR(nTotSBF)        + CHR(13) + CHR(10)
		   cLog += 'ATENCAO PRODUTO SEM SALDO NO ESTOQUE, FAVOR VERIFICAR COM O ALMOXARIFADO PARA PODER CONTINUAR A LIBERACAO DE ESTOQUE DO PEDIDO DE VENDA!!!' + CHR(13) + CHR(10) + CHR(13) + CHR(10)
		   
		ENDIF
		
                  
    	TRB->(dbSkip())
	ENDDO
	TRB->(dbCloseArea())
	
	IF ALLTRIM(cLog) <> ''
	
		U_ExTelaMen("LIMPAEST - Limpa Bloqueio de Estoque de Pedido!!!", cLog, "Arial", 10, , .F., .T.) 
		
	ENDIF
    
RETURN(NIL)

STATIC FUNCTION SqlPedidos()

	BeginSQL Alias "TRB"
			%NoPARSER% 
		       SELECT C9_FILIAL,
				      C9_PEDIDO,
					  C9_ITEM,
					  C9_PRODUTO,
					  C9_QTDLIB,
					  C9_QTDLIB2,
					  C9_LOCAL,
					  C9_CLIENTE,
					  C9_LOJA 
		         FROM %Table:SC9% SC9 WITH (NOLOCK)
		        WHERE C9_FILIAL BETWEEN %EXP:_cFil1% AND %EXP:_cFil2%
			      AND ((C9_DTENTR BETWEEN %EXP:dtos(_dData1)% AND %EXP:dtos(_dData2)%) OR C9_DTENTR = '')  
			      AND C9_BLEST       <> '' 
			      AND SC9.D_E_L_E_T_ <> '*'
			      AND C9_PRODUTO IN (SELECT BE_CODPRO 
			                           FROM %Table:SBE% SBE WITH (NOLOCK)
			                          WHERE BE_FILIAL        = C9_FILIAL
								        AND BE_CODPRO        = C9_PRODUTO
								        AND BE_LOCAL         = C9_LOCAL
								        AND SBE.D_E_L_E_T_  <> '*' )
	EndSQl  
	           
RETURN(NIL)

STATIC FUNCTION SqlSB2(cFil,cCod,cLocal)

	BeginSQL Alias "TRC"
			%NoPARSER% 
			SELECT B2_QATU 
			  FROM %Table:SB2% SB2 WITH (NOLOCK)
			 WHERE B2_FILIAL   = %EXP:cFil%
			   AND B2_COD      = %EXP:cCod%
			   AND B2_LOCAL    = %EXP:cLocal%
			   AND D_E_L_E_T_ <> '*'
			   
	EndSQl  
	           
RETURN(NIL)

STATIC FUNCTION SqlSBF(cFil,cCod,cLocal)

	BeginSQL Alias "TRD"
			%NoPARSER% 
			   SELECT BF_QUANT
				 FROM %Table:SBE% SBE WITH (NOLOCK)
				 INNER JOIN %Table:SBF% SBF WITH (NOLOCK)
				         ON BF_FILIAL       = BE_FILIAL
						AND BF_PRODUTO      = BE_CODPRO
						AND BF_LOCAL        = BE_LOCAL
						AND BF_LOCALIZ      = BE_LOCALIZ
						AND SBF.D_E_L_E_T_ <> '*'
				      WHERE BE_FILIAL       = %EXP:cFil%
				        AND BE_CODPRO       = %EXP:cCod%
				        AND BE_LOCAL        = %EXP:cLocal%
				        AND SBE.D_E_L_E_T_ <> '*'
			   
	EndSQl  
	           
RETURN(NIL)

STATIC FUNCTION Elimina()

	_cSql := " UPDATE " +RetSqlName("SC9")+ " " 
	_cSql += "         SET C9_BLEST = '  ' "
	_cSql += "       WHERE C9_FILIAL BETWEEN '"+ _cFil1 +"' AND '"+ _cFil2 +"' "   
	_cSql += "         AND ((C9_DTENTR BETWEEN '"+ dtos(_dData1) +"' AND '" + dtos(_dData2) +"') OR C9_DTENTR = '')  " // incluida C9_DTENTR = '', pois a rotina de liberacao de credito gera registro no SC9 com este campo em branco
	_cSql += "         AND C9_BLEST <> '' " // para filtrar apenas registros que estao com algum bloqueio (otimizacao da query)
	_cSql += "         AND D_E_L_E_T_ <> '*' "
	_cSql += "         AND C9_PRODUTO NOT IN (SELECT BE_CODPRO FROM " +RetSqlName("SBE") + " "
    _cSql += "                                 WHERE BE_FILIAL   = C9_FILIAL "
    _cSql += "						             AND BE_CODPRO   = C9_PRODUTO "
    _cSql += "						             AND BE_LOCAL    = C9_LOCAL "
    _cSql += "						             AND D_E_L_E_T_ <> '*' ) "
	
	tcSqlExec(_cSql)
   
RETURN(NIL)

STATIC FUNCTION LIMPABLOQUEIO(cFil,cPEDIDO,cITEM,cCLIENTE,cLOJA,cPRODUTO)

	_cSql := " UPDATE " +RetSqlName("SC9")+ " " 
	_cSql += "       SET C9_BLEST    = '  ' "
	_cSql += "     WHERE C9_FILIAL   = '"+ cFil     + "' "   
	_cSql += "       AND C9_PEDIDO   = '"+ cPEDIDO  + "' " 
	_cSql += "       AND C9_ITEM     = '"+ cITEM    + "' "
	_cSql += "       AND C9_CLIENTE  = '"+ cCLIENTE + "' "
	_cSql += "       AND C9_LOJA     = '"+ cLOJA    + "' "
	_cSql += "       AND C9_PRODUTO  = '"+ cPRODUTO + "' "
	_cSql += "       AND D_E_L_E_T_ <> '*' "
	_cSql += "       AND C9_PRODUTO IN (SELECT BE_CODPRO FROM " +RetSqlName("SBE") + " "
    _cSql += "                           WHERE BE_FILIAL   = C9_FILIAL "
    _cSql += "				               AND BE_CODPRO   = C9_PRODUTO "
    _cSql += "				               AND BE_LOCAL    = C9_LOCAL "
    _cSql += "				               AND D_E_L_E_T_ <> '*' ) "
	
	tcSqlExec(_cSql)
   
RETURN(NIL)
