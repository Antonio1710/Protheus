#Include "Protheus.ch"  
#Include "Fileio.ch"
#Include "TopConn.ch"  
#Include "Rwmake.ch"  

/*/
{Protheus.doc} User Function MT106VGR
	Permite que as pré requisições do departamento fiscal sejam geradas apenas pela Viviane e pela Rosângela
	@type  Function
	@author Luciano Mafra
	@since 23/12/2013
	@version 01
	@history Chamado 047330 - WILLIAM COSTA       - 20/02/2019 - Estoq Negat
	@history Chamado 047330 - Fernando Sigoli     - 01/03/2019 - Estoq Negat
	@history Chamado 048118 - William Costa       - 26/03/2019 - Retirado Regra de Estoque negativo por solicitacado do Fabio Souza
	@history Chamado 054491 - William Costa       - 27/12/2019 - Adicionado trava quando o parametro MV_PAR03 estiver igual a Sim, não pode se não gera uma solicitação de compras automática tem que ser sempre igual a Não
/*/
USER FUNCTION MT106VGR()

	Local lRet      := .T.	
	Local aParamIXB := PARAMIXB
	Local _cAlias   := Alias()
	Local _cIndex   := IndexOrd()
	Local _cRecno   := Recno()
	Local nQtdSol   := SCP->CP_QUANT   //quantidade solicitada
	Local nQtdEst   := 0              //Quantidade no estoque
	Private aArea   := GetArea() 
	
	//INICIO CHAMADO 033863 - WILLIAM COSTA Verificao de Centro de Custo
	
	IF SCP->CP_CC = "2202" .and. ! Alltrim(__cUserID) $ GETMV("MV_#USUREQ") 
	
		MsgAlert("OLÁ " + Alltrim(cUserName) + ", VOCÊ NÃO TEM PERMISSÃO PARA GERAR PRÉ REQUISIÇÕES DESTE CENTRO DE CUSTO 2202", "MT106VGR - Liberaçao Centro de Custo")
		
		lRet := .F.
		
	ENDIF	 
	              
	//FINAL CHAMADO 033863 - WILLIAM COSTA Verificao de Centro de Custo
		
	//INICIO CHAMADO 047330 - WILLIAM COSTA Verificao de Estoque Negativo
	
	//INICIO Solicitacao no chamado - WILLIAM COSTA 26/03/2019 048116 para retirar essa validacao de estoque feita pelo Fabio Souza Coordenador do Estoque 
	
	/*
	IF lRet == .T.
		
		IF GetMv( "MV_#LIBEST" , .F. , .T.) == .T.   
		    
			nQtdEst := SqlSaldoEstoque(SCP->CP_PRODUTO,SCP->CP_LOCAL)
			
			IF nQtdSol > nQtdEst    //Chamado 047330 - Fernando Sigoli - Estoque Negativo
						
				MsgStop("OLÁ " + Alltrim(cUserName) + ", não é permitido gerar pré-requisão com produto sem estoque, favor verificar com o Almoxarifado!!!" + CHR(13) + CHR(10) + "Produto: "+ ALLTRIM(SCP->CP_PRODUTO) + " Saldo: " + cValToChar(nQtdSol-nQtdEst), "MT106VGR-01")
				lRet      := .F. 
			
			ENDIF
			
		ENDIF
	
	ENDIF
	*/

	IF MV_PAR03 == 1

		MsgAlert("OLÁ " + Alltrim(cUserName) + ", VOCÊ NÃO TEM PERMISSÃO PARA GERAR PRÉ REQUISIÇÕES COM O PARAMETRO Gera Sol. Compras/Aut.Entrega Igual a Sim, altere para Não para Continuar", "MT106VGR - Aperte F12 ou Botao Parametros Item 3")
		
		lRet := .F.

	ENDIF	
	
	RestArea(aArea)
	
	//FINAL Solicitacao no chamado - WILLIAM COSTA 26/03/2019 048116 para retirar essa validacao de estoque feita pelo Fabio Souza Coordenador do Estoque
	//FINAL CHAMADO 047330 - WILLIAM COSTA Estoque Negativo
	
RETURN(lRet)  

Static Function SqlSaldoEstoque(cProduto,cLocal)

	Local nEstoque := 0
	Local cQryEst  := 0                
	
	cQryEst := " SELECT B2_QATU " 
	cQryEst += " FROM "+RetSqlName("SB2")+" B2 "
	cQryEst += " WHERE B2_FILIAL   = '" + FWxFilial("SB2")+ "' " 
	cQryEst += "   AND B2_COD      = '" + cProduto        + "' " 
	cQryEst += "   AND B2_LOCAL    = '" + cLocal          + "' " 
	cQryEst += "   AND D_E_L_E_T_ <> '*' "
	
	TCQUERY cQryEst new alias "TRB"
	
	DbSelectArea("TRB")
	DbGoTop()
	While TRB->(!EOF())
	
		nEstoque := TRB->B2_QATU 
	
		TRB->(DBSKIP())
		
	ENDDO
	
	TRB->(DBCLOSEAREA())
	
Return(nEstoque)