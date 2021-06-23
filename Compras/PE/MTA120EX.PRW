#Include 'Protheus.ch'
#Include "Topconn.ch" 

/*{Protheus.doc} User Function MTA120EX
	Ponto de entrada permite realizar alguma validação antes de confirmar a exclusão do pedido de compra. - Manutenção de frete gerado 
	@type  Function
	@author Ricardo Lima
	@since 08/05/2019
	@version 01
	@history Chamado 044314 - Everson       - 15/07/2019 - Tratamento para desvincular o pedido de compra do registro de CT-e.
	@history Chamado 044314 - Everson       - 25/07/2019 - Tratamento para filtrar os registros que executam update e função para desvincular o pedido de compra dos registros de frete.
	@history Chamado 044314 - Everson       - 26/07/2019 - Correção do DbSeek na tabela ZFA.
	@history Chamado 044314 - Everson       - 26/07/2019 - Adicionado validação de empresa e filial
	@history Chamado 056603 - William Costa - 16/03/2020 - Trava para não deixar excluir pedido de venda que tenha uma P.A com saldo no finaceiro
	
*/ 

User Function MTA120EX()

	Local aArea	:= GetArea()
	Local lRet 	:= .T.
	Local cUpdt	:= ""
	Local cFilGFrt	:= Alltrim(SuperGetMv( "MV_#M46F5" , .F. , '' ,  )) //Everson-CH:044314-06/08/2019.
	Local cEmpFrt	:= Alltrim(SuperGetMv( "MV_#M46F6" , .F. , '' ,  )) //Everson-CH:044314-06/08/2019.
	
	If cEmpAnt == "01"
	
		//Remove o número do pedido de compra e altera o status do registro de reembolso.
		If ! Empty(SC7->C7_XREEMBO)
			cUpdt	:= " UPDATE " + RetSqlName("ZFI") + " SET ZFI_STATUS = '1', ZFI_PEDCOM = '' WHERE ZFI_FILIAL = '" + Alltrim(cValToChar(SC7->C7_FILIAL)) + "' AND ZFI_PEDCOM = '" + Alltrim(cValToChar(SC7->C7_NUM)) + "' AND D_E_L_E_T_ = '' " 
			TCSqlExec(cUpdt)
		
		EndIf
			
	EndIf
	
	//Everson-26/07/2019.Chamado 044314.
	//Remove o número do pedido de compra do registro do CT-e.
	If cEmpAnt $cEmpFrt .And. cFilAnt $cFilGFrt
		If ! Empty(SC7->C7_XNUMCTE) .And. ! Empty(SC7->C7_XNUSCTE)
			updtFrt(SC7->C7_FILIAL,SC7->C7_NUM,.T.)
		
		EndIf
	
	EndIf

	//*** INICIO WILLIAM COSTA CHAMADO 056603 || OS 058047 || TECNOLOGIA || LUIZ || 8451 || PC. SOLICITACAO PA  

	IF lRet := .T.

		SqlBuscaPA(SC7->C7_FILIAL,SC7->C7_NUM)
		While TRB->(!EOF())       

			IF TRB->E2_SALDO > 0

				MsgAlert("OLÁ " + ALLTRIM(cUserName) + ", Pedido não pode ser eliminado resíduo, existe títulos em aberto no financeiro, favor verificar com o financeiro para baixar ou excluir o titulo de P.A"  + CHR(13) + CHR(10) + ;
				"Filial: "     + TRB->E2_FILIAL            + CHR(13) + CHR(10) + ;
				"Prefixo: "    + TRB->E2_PREFIXO           + CHR(13) + CHR(10) + ;
				"Numero: "     + TRB->E2_NUM               + CHR(13) + CHR(10) + ;
				"Parcela: "    + TRB->E2_PARCELA           + CHR(13) + CHR(10) + ;
				"Tipo: "       + TRB->E2_TIPO              + CHR(13) + CHR(10) + ;
				"Natureza: "   + TRB->E2_NATUREZ           + CHR(13) + CHR(10) + ;
				"Fornecedor: " + TRB->E2_FORNECE           + CHR(13) + CHR(10) + ;
				"Loja: "       + TRB->E2_LOJA              + CHR(13) + CHR(10) + ;
				"Valor: "      + CVALTOCHAR(TRB->E2_VALOR) + CHR(13) + CHR(10) + ;
				"Saldo: "      + CVALTOCHAR(TRB->E2_SALDO) + CHR(13) + CHR(10) + ;
				"Num Pedido: " + TRB->ZFQ_NUM              + CHR(13) + CHR(10), "MTA120EX - Ponto de Entrada Eliminação de Pedido de Compra")

				lRet := .F.

			ENDIF
			
			TRB->(dbSkip())
					
		ENDDO
		TRB->(dbCloseArea())

	ENDIF

	//*** FINAL WILLIAM COSTA CHAMADO 056603 || OS 058047 || TECNOLOGIA || LUIZ || 8451 || PC. SOLICITACAO PA  
	
	RestArea(aArea)

Return lRet

/*{Protheus.doc} User Function updtFrt
	Desvincula o pedido dos registros de frete.
	@type  Function
	@author Ricardo Lima
	@since 25/07/2019
	@version 01
*/ 

Static Function updtFrt(cFilPed,cNumPed,lFazUpdt)

	Local aArea			:= GetArea()
	Local cUpdt			:= ""
	Default lFazUpdt	:= .T.
	
	DbSelectArea("ZFK")
	ZFK->(DbSetOrder(9))
	ZFK->(DbGoTop())
	If ! ZFK->( DbSeek( cFilPed + cNumPed ) )
		Conout( DToC(Date()) + " " + Time() + " MTA120EX - updtFrt não encontrou o pedido de compra ZFK " + Alltrim(cNumPed) )
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	DbSelectArea("ZFA")
	ZFA->(DbSetOrder(13))
	If ! ZFA->(DbSeek( cFilPed + Alltrim(ZFK->ZFK_CODZFA) )) //Everson-26/07/2019.Chamado 044314.
		Conout( DToC(Date()) + " " + Time() + " MTA120EX - updtFrt não encontrou o registro ZFA " + Alltrim(ZFK->ZFK_CODZFA) )
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	While ! ZFA->(Eof()) .And. ZFA->ZFA_FILIAL = cFilPed .And. ZFA->ZFA_COD = Alltrim(ZFK->ZFK_CODZFA)
		
		If ZFA->ZFA_FECHA = 'S'
			RestArea(aArea)
			Return .F.
			
		EndIf
	
		ZFA->(DbSkip())
		
	End
	
	Conout( DToC(Date()) + " " + Time() + " MTA120EX - updtFrt checa período fechado " + cValToChar(lFazUpdt) )
	
	If lFazUpdt
		cUpdt := " UPDATE " + RetSqlName("ZFK") + " SET ZFK_PEDCOM = '' WHERE ZFK_FILIAL = '" + cFilPed + "' AND ZFK_PEDCOM = '" + cNumPed + "' AND D_E_L_E_T_ = '' "
		TCSqlExec(cUpdt)
		
		cUpdt := " UPDATE " + RetSqlName("ZFA") + " SET ZFA_PEDADT = '' WHERE ZFA_FILIAL = '" + cFilPed + "' AND ZFA_PEDADT = '" + cNumPed + "' AND D_E_L_E_T_ = '' "
		TCSqlExec(cUpdt)
				
	EndIf
	
	RestArea(aArea)
	
Return .T.

Static Function SqlBuscaPA(cFilAtu,cNum)    

    Local cTeste := ''

	BeginSQL Alias "TRB"
			%NoPARSER%  
			SELECT E2_FILIAL,
                   E2_PREFIXO,
                   E2_NUM,
                   E2_PARCELA,
                   E2_TIPO,
                   E2_NATUREZ,
                   E2_TIPO,
                   E2_VALOR,
                   E2_NATUREZ,
                   E2_FORNECE,
                   E2_SALDO,
                   E2_LOJA,
                   ZFQ_NUM
              FROM %TABLE:ZFQ%
        INNER JOIN %TABLE:SE2%
                ON E2_FILIAL               = ZFQ_FILIAL
               AND E2_PREFIXO              = ZFQ_PREFIX
               AND E2_NUM                  = ZFQ_NUM
               AND E2_PARCELA              = ZFQ_PARCEL
               AND E2_TIPO                 = ZFQ_TIPO
               AND E2_NATUREZ              = ZFQ_NATURE
               AND E2_FORNECE              = ZFQ_FORNEC
               AND E2_LOJA                 = ZFQ_LOJA
               AND E2_SALDO                > 0
               AND %TABLE:SE2%.D_E_L_E_T_ <> '*'
             WHERE ZFQ_FILIAL              = %EXP:cFilAtu%
               AND ZFQ_NUM                 = %EXP:cNum%
               AND %TABLE:ZFQ%.D_E_L_E_T_ <> '*'

 	EndSQl      

RETURN(NIL) 