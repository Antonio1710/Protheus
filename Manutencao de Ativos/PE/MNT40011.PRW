#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} User Function MNT40011
	Ponto de entrada chamado para fazer alguma validação na finalização de uma Ordem de Serviço, antes de montar a tela.
	@type  Function
	@author William Costa
	@since 30/11/2020
	@version 01	
    @history Ticket 4928 - William Costa - 01/12/2020 - Identificado que o campo Tipo da Solicitação de OP, não é utilizado, o que é utilizado mesmo é o numero da Ordem de Solicitação + Fixo 'OS001', então foi alterado o ponto de entrada e o erro solucionado.
/*/
 
USER FUNCTION MNT40011()
 
    Local lRet     := .T.
    Local aArea    := GetArea()
    Local aAreaSTJ := STJ->(GetArea())
    
    // *** INICIO VERIFICA SE A SOLICITACAO DE ARMAZEM FOI BAIXADA OU ENCERRADA
    SqlSCP(STJ->TJ_FILIAL,STJ->TJ_ORDEM + 'OS' + "001")

    TRC->(DbGoTop())
    While !TRC->(EOF()) 
        
        IF lRet == .T.

            MsgStop("OLÁ " + Alltrim(cUserName) + ", S.A da Ordem de Serviço, ainda não foi baixada ou Encerrada, Numero da S.A: " + TRC->CP_NUM + "/" + TRC->CP_ITEM + " por favor, verifique.", "MNT40011-02  - Finalizar Ordem de Serviço ")
            lRet := .F.

        ELSE  

            EXIT  

        ENDIF    

        TRC->(DBSKIP())    

    ENDDO
    TRC->(DbCloseArea())	
    
    // *** FINAL VERIFICA SE A SOLICITACAO DE ARMAZEM FOI BAIXADA OU ENCERRADA
    
    // *** INICIO VERIFICA SE A NOTA FISCAL DE ENTRADA FOI DADA ENTRADA CORRETAMENTE
    IF lRet == .T.

        SqlSD1(STJ->TJ_FILIAL,STJ->TJ_ORDEM + 'OS' + "001")

        TRD->(DbGoTop())
        While !TRD->(EOF()) 

            IF lRet == .T.

                MsgStop("OLÁ " + Alltrim(cUserName) + ", Nota Fiscal de Compra da Ordem de Serviço, ainda não dada Entrada, Numero do P.C: " + TRD->D1_DOC + " por favor, verifique.", "MNT40011-09  - Finalizar Ordem de Serviço ")
                lRet := .F.

            ELSE  

                EXIT  

            ENDIF    
            
            TRD->(DBSKIP())    

        ENDDO
        TRD->(DbCloseArea())

    ENDIF
    // *** FINAL VERIFICA SE A NOTA FISCAL DE ENTRADA FOI DADA ENTRADA CORRETAMENTE
    
    // *** INICIO VERIFICA SE A SOLICITACAO DE COMPRA FOI ENCERRADA OU ELIMINADA RESIDUO
    IF lRet == .T.

        SqlSC1(STJ->TJ_FILIAL,STJ->TJ_ORDEM + 'OS' + "001")

        TRE->(DbGoTop())
        While !TRE->(EOF()) 

            IF lRet == .T.

                MsgStop("OLÁ " + Alltrim(cUserName) + ", S.C da Ordem de Serviço, ainda não foi baixada ou Eliminada Residuo, Numero da S.C: " + TRE->C1_NUM + "/" + TRE->C1_ITEM + " por favor, verifique.", "MNT40011-05  - Finalizar Ordem de Serviço ")
                lRet := .F.

            ELSE  

                EXIT  

            ENDIF   

            TRE->(DBSKIP())    

        ENDDO
        TRE->(DbCloseArea())
    ENDIF
    // *** FINAL VERIFICA SE A SOLICITACAO DE COMPRA FOI ENCERRADA OU ELIMINADA RESIDUO
    
    // *** INICIO VERIFICA SE O PEDIDO DE COMPRA FOI ENCERRADA OU ELIMINADA RESIDUO
    IF lRet == .T.

        SqlSC7(STJ->TJ_FILIAL,STJ->TJ_ORDEM + 'OS' + "001")

        TRF->(DbGoTop())
        While !TRF->(EOF()) 

            IF lRet == .T.

                MsgStop("OLÁ " + Alltrim(cUserName) + ", Pedido de Compra da Ordem de Serviço, ainda não foi baixada ou Eliminada Residuo, Numero do P.C: " + TRF->C7_NUM + "/" + TRF->C7_ITEM + " por favor, verifique.", "MNT40011-07  - Finalizar Ordem de Serviço ")
                lRet := .F.

            ELSE  

                EXIT  

            ENDIF   
            
            TRF->(DBSKIP())    

        ENDDO
        TRF->(DbCloseArea())
    ENDIF
    // *** FINAL VERIFICA SE O PEDIDO DE COMPRA FOI ENCERRADA OU ELIMINADA RESIDUO	

    RestArea(aArea)
    RestArea(aAreaSTJ)
         
RETURN(lRet)

Static Function SqlSCP(cFilAtu,cOp)  

	BeginSQL Alias "TRC"
		     %NoPARSER%
		        SELECT CP_NUM,
                       CP_ITEM,
                       CP_QUANT,
                       CP_QUJE,
                       CP_STATUS 
				  FROM %TABLE:SCP% SCP WITH(NOLOCK)
                   WHERE CP_FILIAL    = %EXP:cFilAtu%
                     AND CP_OP        = %EXP:cOp%
                     AND CP_QUANT    <> CP_QUJE
                     AND CP_STATUS   <> 'E'
                     AND D_E_L_E_T_  <> '*'   
				 
	EndSQl

Return (NIL)

Static Function SqlSD1(cFilAtu,cOp)

	BeginSQL Alias "TRD"
		     %NoPARSER%
             SELECT D1_FILIAL,
                    D1_DOC,
                    D1_SERIE,
                    D1_FORNECE,
                    D1_LOJA,
                    F1_STATUS 
               FROM SD1010 SD1 WITH(NOLOCK)
         INNER JOIN SF1010 SF1 WITH(NOLOCK)
                 ON F1_FILIAL       = D1_FILIAL
                AND F1_DOC          = D1_DOC
                AND F1_SERIE        = D1_SERIE
                AND F1_FORNECE      = D1_FORNECE
                AND F1_LOJA         = D1_LOJA 
                AND F1_STATUS       = ''
                AND SF1.D_E_L_E_T_ <> '*'
              WHERE D1_FILIAL       = %EXP:cFilAtu%
                AND D1_OP           = %EXP:cOp%
                AND SD1.D_E_L_E_T_ <> '*'

             GROUP BY D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,F1_STATUS  
                 
	EndSQl

Return (NIL)

Static Function SqlSC1(cFilAtu,cOp)

	BeginSQL Alias "TRE"
		     %NoPARSER%
             SELECT C1_FILIAL,
                    C1_NUM,
                    C1_ITEM,
                    C1_PRODUTO,
                    C1_QUANT,
                    C1_QUJE,
                    C1_OP,
                    C1_RESIDUO 
               FROM %TABLE:SC1% SC1 WITH(NOLOCK)
              WHERE C1_FILIAL   = %EXP:cFilAtu%
                AND C1_OP       = %EXP:cOp%
                AND C1_QUANT   <> C1_QUJE
                AND C1_RESIDUO <> 'S'
                AND D_E_L_E_T_ <> '*'

	EndSQl

Return (NIL)

Static Function SqlSC7(cFilAtu,cOp)

	BeginSQL Alias "TRF"
		     %NoPARSER%
             SELECT C7_FILIAL,
                    C7_NUM,
                    C7_ITEM,
                    C7_PRODUTO,
                    C7_QUANT,
                    C7_QUJE,
                    C7_OP,
                    C7_RESIDUO 
               FROM %TABLE:SC7% SC7 WITH(NOLOCK)
              WHERE C7_FILIAL   = %EXP:cFilAtu%
                AND C7_OP       = %EXP:cOp%
                AND C7_QUANT   <> C7_QUJE
                AND C7_RESIDUO <> 'S'
                AND D_E_L_E_T_ <> '*'

	EndSQl

Return (NIL)
